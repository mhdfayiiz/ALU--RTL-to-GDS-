module Alu_tb;

reg signed [7:0] A;
reg signed [7:0] B;
reg [2:0] alu_opcode;
wire signed [7:0] result;
wire carry;
wire zero_flag;
wire overflow_flag;



Alu uut(.A(A),.B(B),.alu_opcode(alu_opcode),.result(result),.carry(carry),.zero_flag(zero_flag),.overflow_flag(overflow_flag));





initial begin
$display("\n  TEST 1: ADD ");
A  = 8'd5;
B  = 8'd5;
alu_opcode = 3'b000;
#10;
$display("Time=%0dns | A=%0d | B=%0d | alu_opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b  ",$time, A, B, alu_opcode, result, carry, zero_flag, overflow_flag);

$display("\n  TEST 2: SUBSTRACT ");
A  = 8'd5;
B  = 8'd10;
alu_opcode = 3'b001;
#10;
$display("Time=%0dns | A=%0d | B=%0d | alu_opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b  ",$time, A, B, alu_opcode, result, carry, zero_flag, overflow_flag);


$display("\n  TEST 3: AND OPERATION ");
A  = 8'd6;
B  = 8'd3;
alu_opcode = 3'b010;
#10;
$display("Time=%0dns | A=%0d | B=%0d | alu_opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b ",$time, A, B, alu_opcode, result, carry, zero_flag, overflow_flag);


$display("\n  TEST 4: OR OPERATION ");
A  = 8'd7;
B  = 8'd2;
alu_opcode = 3'b011;
#10;
$display("Time=%0dns | A=%0d | B=%0d | alu_opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b",$time, A, B, alu_opcode, result, carry, zero_flag, overflow_flag);



$finish;
end

endmodule