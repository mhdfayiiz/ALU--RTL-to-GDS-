module regm_tb;

reg  signed [7:0] A_in;
reg signed [7:0]B_in;
reg signed [7:0]alu_result;
reg clk;
reg reset;
reg load_A;
reg load_B;
reg load_result;
wire signed [7:0]A_out;
wire signed [7:0]B_out;
wire signed [7:0]result_out;

Registers dut(.A_in(A_in),
.B_in(B_in),
.alu_result(alu_result),
.clk(clk),.reset(reset),
.load_A(load_A),.load_B(load_B),
.load_result(load_result),
.A_out(A_out),
.B_out(B_out),
.result_out(result_out));

always #5 clk= ~clk;
initial 
begin 
$monitor("t=%0t A=%0d B=%0d RES=%0d | A_out=%0d B_out=%0d R_out=%0d",
$time,A_in,B_in,alu_result,A_out,B_out,result_out);

clk = 0;
reset = 1;
load_A = 0;
load_B = 0;
load_result = 0;

#10 reset = 0;

#10 A_in = 10; load_A = 1;
#10 load_A = 0;

#10 B_in = -5; load_B = 1;
#10 load_B = 0;

#10 alu_result = 20; load_result = 1;
#10 load_result = 0;

#40 $finish;
end

endmodule
