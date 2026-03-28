`timescale 1ns/1ps

module Top_tb;
reg clk;
reg reset;
reg start;
reg signed [7:0] A_in;
reg signed [7:0] B_in;
reg [2:0] opcode;

wire signed [7:0] result_out;
wire carry;
wire zero_flag;
wire overflow_flag;
wire done;

Top dut(
.clk(clk),.reset(reset),.start(start),.A_in(A_in),.B_in(B_in),.opcode(opcode),.result_out(result_out),.carry(carry),.zero_flag(zero_flag),.overflow_flag(overflow_flag),.done(done));

initial 
begin
$dumpfile("wave.vcd");   
$dumpvars(0, Top_tb);    
end



always #5 clk = ~clk; 
initial begin
clk = 0;
reset = 1;
start = 0;
A_in = 0;
B_in = 0;
opcode = 0;
#20 reset = 0;
$display("\n  TEST 1: ADD ");
A_in = 8'd10;
B_in = 8'd5;
opcode = 3'b000;
start = 1;
#10 start = 0;
wait(done);
#2;
$display("Time=%0dns | A=%0d | B=%0d | opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b | done=%b",$time, A_in, B_in, opcode, result_out, carry, zero_flag, overflow_flag, done);
 

$display("\n  TEST 2: SUB ");
 A_in = 8'd20;
 B_in = 8'd25;
 opcode = 3'b001;
 start = 1;
 #10 start = 0;
 wait(done);
 #2;
$display("Time=%0dns | A=%0d | B=%0d | opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b | done=%b",$time, A_in, B_in, opcode, result_out, carry, zero_flag, overflow_flag, done);

$display("\n   TEST 3: AND  ");
A_in = 8'd7;
B_in = 8'd6;
opcode = 3'b010;
start = 1;
#10 start = 0;
wait(done);
#2;
$display("Time=%0dns | A=%0d | B=%0d | opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b | done=%b",$time, A_in, B_in, opcode, result_out, carry, zero_flag, overflow_flag, done);

$display("\n   TEST 4: OR  ");
A_in = 8'd50;
B_in = 8'd10;
opcode = 3'b011;
start = 1;
#10 start = 0;
wait(done);
#2;
$display("Time=%0dns | A=%0d | B=%0d | opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b | done=%b",$time, A_in, B_in, opcode, result_out, carry, zero_flag, overflow_flag, done);


$display("\n ALL TESTS FINISHED \n");
$finish;
end


endmodule