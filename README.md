# 8-bit ALU: RTL to GDS2

I'm taking a small 8-bit ALU through the whole ASIC flow, from Verilog to a GDS2 layout, using only open-source tools. The point is to understand each stage properly, not to simulate some RTL and call it done.

**Tools:** Yosys, Icarus Verilog, GTKWave, OpenROAD, Sky130 PDK

**Progress:** RTL, synthesis and timing constraints are done. Place & route and signoff are next.

---

## Design

Three modules under one top-level wrapper:

```
Top
├── Control_unit   - 4-state FSM (IDLE -> LOAD -> EXECUTE -> WRITEBK)
├── Registers      - 8-bit register bank (A, B, result)
└── Alu            - combinational datapath
```

### Operations

| opcode | operation | flags                          |
|--------|-----------|--------------------------------|
| 3'b000 | ADD       | carry, zero, overflow          |
| 3'b001 | SUB       | carry (borrow), zero, overflow |
| 3'b010 | AND       | zero                           |
| 3'b011 | OR        | zero                           |

Overflow is the usual two's-complement check: compare the sign bits of the inputs with the sign bit of the result.

### FSM

A Moore machine with 4 states. An operation takes 3 clock cycles after `start` goes high.

- **IDLE**: waits for `start`. `done` is high here, so the last result is valid on the output.
- **LOAD**: latches `A_in` and `B_in` into the register bank.
- **EXECUTE**: the ALU computes and the result sits on the combinational wire.
- **WRITEBK**: writes the result into the output register and goes back to IDLE.

### Ports

| port          | dir | width | description                |
|---------------|-----|-------|----------------------------|
| clk           | in  | 1     | clock                      |
| reset         | in  | 1     | asynchronous reset         |
| start         | in  | 1     | begin a new operation      |
| A_in          | in  | 8     | first operand              |
| B_in          | in  | 8     | second operand             |
| opcode        | in  | 3     | selects operation          |
| result_out    | out | 8     | computed result            |
| carry         | out | 1     | carry / borrow flag        |
| zero_flag     | out | 1     | result == 0                |
| overflow_flag | out | 1     | signed overflow            |
| done          | out | 1     | result is valid and stable |

---

## Phase 1: RTL

The Verilog is split into `Alu.v`, `Control_unit.v` and `registermodule.v`, wired together in `TopModule.v`. The ALU is purely combinational. All the state is in the register bank and the FSM.

I simulated with Icarus Verilog and GTKWave. The testbench runs all four operations and checks the flags, including `0x7F + 0x01` for overflow and `0x05 - 0x0A` for borrow. It also checks that the FSM goes through all four states.

Results: all four operations gave correct results and the flags were right for both ADD and SUB edge cases. `done` stays low for 3 cycles while an operation runs and goes high in IDLE. The waveforms show 3 cycles from `start` to a valid `result_out`.

---

## Phase 2: Synthesis

Synthesized with Yosys against `sky130_fd_sc_hd` at the TT corner (25C, 1.8V). The script is `synthesis/synth.ys`:

```
read_verilog -> hierarchy -> proc -> flatten -> opt_expr -> opt_clean
-> opt -full -> dfflibmap -> abc -> opt_clean -> write_verilog
```

`dfflibmap` has to run before `abc`. Once `abc` is given the Liberty file it maps the combinational logic itself, so no separate `techmap` step is needed.

I then ran gate-level simulation on the netlist (`synthesis/Top_netlist.v`) with the same testbench, using `-DFUNCTIONAL -DUNIT_DELAY="#1"` and the Sky130 cell models.

| metric               | value |
|----------------------|-------|
| Total cells          | 211   |
| Flip-flops (dfrtp_1) | 26    |
| Combinational cells  | 185   |
| Unique cell types    | 33    |

The 26 flip-flops are 8 for register A, 8 for register B, 8 for the result register and 2 for the FSM state. The most common combinational cells are `clkinv_1` (32), `nand2_1` (26) and `nor2_1` (18). Yosys also mapped the adder carry chain onto `maj3_1` cells instead of a plain chain of full adders.

GLS passed and matched the RTL simulation for all four operations.

---

## Phase 3: Timing constraints (SDC)

`constraints/top.sdc` is the pre-CTS setup pass. I checked it in OpenROAD against the synthesized netlist.

| constraint         | value                                                                 |
|--------------------|-----------------------------------------------------------------------|
| Clock `clk`        | 10 ns (100 MHz)                                                       |
| Clock uncertainty  | 0.5 ns                                                                |
| Input delay (max)  | 3.0 ns on `start`, `A_in`, `B_in`, `opcode`                           |
| Output delay (max) | 3.0 ns on `result_out`, `carry`, `zero_flag`, `overflow_flag`, `done` |
| False path         | from `reset`                                                          |
| Driving cell       | `sky130_fd_sc_hd__buf_1` on all inputs, including `reset`             |
| Output load        | 0.05 pF on all outputs                                                |

These values are my own assumptions. There's no spec or board behind this design, so I picked reasonable numbers to get a working pre-CTS setup pass:

- 10 ns is the clock I'm targeting. The 0.5 ns uncertainty is an assumed margin for skew and jitter, since there's no clock tree yet.
- The 3.0 ns input and output delays are assumed. They stand in for whatever logic sits outside the chip.
- `reset` is asynchronous, so I false-pathed it instead of timing it against `clk`.
- The driving cell gives the input nets a realistic slew. `reset` gets one too because its net is still checked for design rules even though its timing is excluded.
- 0.05 pF is an assumed placeholder load on the outputs.

I'll revisit these once there's a real clock tree and a more realistic I/O environment.

The checks live in `scripts/verify_sdc.tcl` (run from the repo root, see [Running it](#running-it)). It reads the PDK location from `PDK_DIR`. Full output is in `logs/sdc_verify.log`.

What came out:

- `read_sdc` ran with no errors.
- `report_clock_properties` shows `clk` with period 10.00 and waveform 0.00 / 5.00.
- `check_setup -verbose` gives one warning: `reset` has no input delay. That's expected, since it's false-pathed.
- The worst setup path is `opcode[1]` to `carry`, going through `nor2`, `nand2` and `o32ai`. Arrival is 4.65 ns, required is 6.50 ns, so slack is **+1.85 ns (met)**. Most of the delay is `o32ai_1` driving the 0.05 pF load.

Not covered yet:

- Hold-side (`-min`) I/O delays, which wait until after CTS.
- Real clock network delay. It's ideal (0 ns) until there's a clock tree.
- Reset recovery/removal timing, because `reset` is false-pathed. I'll come back to this at signoff.

---

## Repo structure

```
├── Rtl/
├── testbenches/
├── simulations/
├── synthesis/
│   ├── synth.ys
│   ├── Top_netlist.v
│   └── wave.vcd
├── constraints/
│   └── top.sdc           - pre-CTS timing constraints
├── scripts/
│   └── verify_sdc.tcl    - OpenROAD SDC check
├── pnr/                  - upcoming
└── signoff/              - upcoming
```

---

## Running it

Tested on Ubuntu 22.04.

You need:

- OSS CAD Suite (Yosys, Icarus Verilog, GTKWave)
- OpenROAD
- Sky130 PDK installed with volare (`~/.volare/sky130A/...`), used for the gate-level sim cell models
- Sky130 HD platform files (`lef/`, `lib/`) for OpenROAD, expected at `$PDK_DIR` (defaults to `~/vlsi/pdk/sky130hd`)

The PDK is not in this repo.

```bash
source ~/oss-cad-suite/environment

# RTL simulation
iverilog -o sim.out Rtl/TopModule.v Rtl/Alu.v Rtl/Control_unit.v Rtl/registermodule.v testbench.v
vvp sim.out && gtkwave dump.vcd

# Synthesis (run from a fresh shell after sourcing the environment)
yosys -s synthesis/synth.ys

# Gate-level simulation
iverilog -DFUNCTIONAL -DUNIT_DELAY="#1" \
  -o gls.out \
  synthesis/Top_netlist.v testbench.v \
  ~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v \
  ~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
vvp gls.out && gtkwave synthesis/wave.vcd

# SDC check (from repo root)
export PDK_DIR=~/vlsi/pdk/sky130hd
openroad -no_init -exit scripts/verify_sdc.tcl 
```
