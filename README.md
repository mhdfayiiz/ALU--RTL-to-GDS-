# 8-bit ALU — RTL to GDS2

A hands-on learning project where I take an 8-bit ALU through the complete ASIC design flow — from writing the RTL all the way down to a physical GDS2 layout — using nothing but open-source tools. The goal is to actually understand every stage of the flow, not just simulate some Verilog and stop there.

**Toolchain:** Yosys · Icarus Verilog · GTKWave · Sky130 PDK

---

## Design Overview

Three modules under a single top-level wrapper:

```
Top
├── Control_unit   — 4-state FSM (IDLE → LOAD → EXECUTE → WRITEBK)
├── Registers      — 8-bit register bank (A, B, result)
└── Alu            — combinational datapath
```

### Operations

| opcode | operation | flags generated                |
|--------|-----------|-----------------               |
| 3'b000 | ADD       | carry, zero, overflow          |
| 3'b001 | SUB       | carry (borrow), zero, overflow |
| 3'b010 | AND       | zero                           |
| 3'b011 | OR        | zero                           |

Overflow uses the standard two's-complement check — comparing the sign bits of the inputs against the sign bit of the result.

### FSM

A Moore machine with 4 states. One operation takes exactly 3 clock cycles after start goes high:

- **IDLE**    — waits for start. done is asserted here, meaning the previous result is valid and stable on the output
- **LOAD**    — latches A_in and B_in into the register bank
- **EXECUTE** — ALU computes; result sits on the combinational wire
- **WRITEBK** — writes the result into the output register, then returns to IDLE

### Top-level ports

|    port       | dir | width |        description         |
|---------------|-----|-------|----------------------------|
| clk           | in  | 1     | clock                      |
| reset         | in  | 1     | asynchronous reset         |
| start         | in  | 1     | begin a new operation      |
| A_in          | in  | 8     | first operand              |
| B_in          | in  | 8     | second operand             |
|opcode         | in  | 3     | selects operation          |
|result_out     | out | 8     | computed result            |
| carry         | out | 1     | carry / borrow flag        |
| zero_flag     | out | 1     | result == 0                |
| overflow_flag | out | 1     | signed overflow detected   |
| done          | out | 1     | result is valid and stable |

---

## Phase 1 — RTL Design ✓

Wrote the RTL in Verilog across three modules (Alu.v, Control_unit.v, registermodule.v) with TopModule.v wiring them together. The ALU is purely combinational; all state lives in the register bank and the FSM.

**Simulation:** IVerilog + GTKWave. Wrote a testbench that ran all four operations, checked flag behavior (including edge cases like 0x7F + 0x01 for overflow and 0x05 - 0x0A for borrow), and verified the FSM cycling correctly through all four states.

**What I saw:**

All four operations produced correct results. The done signal toggled exactly as expected — low for 3 cycles during execution, high in IDLE. Overflow detection behaved correctly for both ADD and SUB edge cases. Waveforms confirmed the 3-cycle latency from start to a valid result_out.

---

## Phase 2 — Synthesis ✓

Synthesized with Yosys targeting the sky130_fd_sc_hd standard cell library at the TT corner (25C, 1.8V). The synthesis script (synthesis/synth.ys) runs this flow:

```
read_verilog → hierarchy → proc → flatten → opt_expr → opt_clean
→ opt -full → dfflibmap → abc → opt_clean → write_verilog
```

dfflibmap must come before abc — hard ordering requirement. When you pass a Liberty file to abc, it handles combinational cell mapping internally, so no separate techmap pass is needed.

After synthesis, ran gate-level simulation (GLS) using the generated netlist (synthesis/Top_netlist.v) against the same testbench, compiled with -DFUNCTIONAL -DUNIT_DELAY="#1" and the Sky130 cell models.

**What I saw:**

|         metric       | value |
|----------------------|-------|
| Total cells          | 211   |
| Flip-flops (dfrtp_1) | 26    |
| Combinational cells  | 185   |
| Unique cell types    | 33    |

The 26 flip-flops break down exactly as expected: 8 for register A, 8 for register B, 8 for the result register, and 2 for the 2-bit FSM state. The dominant combinational cells were clkinv_1 (32), nand2_1 (26), and nor2_1 (18). Yosys also used maj3_1 cells for the adder carry chain — it maps carry propagation to majority-gate primitives in Sky130 rather than a naive chain of full adders.

GLS passed cleanly. All four operations matched the RTL simulation output.

---


## Repo Structure

```
.
├── Rtl/
│   ├── TopModule.v
│   ├── Alu.v
│   ├── Control_unit.v
│   └── registermodule.v
├── synthesis/
│   ├── synth.ys          — Yosys synthesis script
│   ├── Top_netlist.v     — synthesized gate-level netlist
│   └── wave.vcd          — GLS waveform dump
├── pnr/                  — (in progress)
└── signoff/              — (upcoming)
```

---

## Running It

**Requirements:** OSS CAD Suite, Sky130 PDK installed via volare

```bash
source ~/oss-cad-suite/environment

# RTL simulation
iverilog -o sim.out Rtl/TopModule.v Rtl/Alu.v Rtl/Control_unit.v Rtl/registermodule.v testbench.v
vvp sim.out && gtkwave dump.vcd

# Synthesis — always run from a fresh shell after sourcing the environment
yosys -s synthesis/synth.ys

# Gate-level simulation
iverilog -DFUNCTIONAL -DUNIT_DELAY="#1" \
  -o gls.out \
  synthesis/Top_netlist.v testbench.v \
  ~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v \
  ~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
vvp gls.out && gtkwave synthesis/wave.vcd
```

