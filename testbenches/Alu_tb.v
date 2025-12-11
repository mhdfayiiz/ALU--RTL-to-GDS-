module Alu_tb;

reg [7:0] A;
reg [7:0] B;
reg [2:0] alu_opcode;
wire [7:0] result;
wire carry;
wire zero_flag;
wire overflow_flag;
wire div_by_zero;



Alu uut(.A(A),.B(B),.alu_opcode(alu_opcode),.result(result),.carry(carry),.zero_flag(zero_flag),.overflow_flag(overflow_flag),.div_by_zero(div_by_zero));





initial begin
$display("\n  TEST 1: ADD ");
A  = 8'd5;
B  = 8'd5;
alu_opcode = 3'b000;
#10;
$display("Time=%0dns | A=%0d | B=%0d | alu_opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b | div0=%b ",$time, A, B, alu_opcode, result, carry, zero_flag, overflow_flag, div_by_zero);

$display("\n  TEST 2: SUBSTRACT ");
A  = 8'd20;
B  = 8'd5;
alu_opcode = 3'b001;
#10;
$display("Time=%0dns | A=%0d | B=%0d | alu_opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b | div0=%b ",$time, A, B, alu_opcode, result, carry, zero_flag, overflow_flag, div_by_zero);


$display("\n  TEST 3: MULTIPLICATION ");
A  = 8'd6;
B  = 8'd3;
alu_opcode = 3'b010;
#10;
$display("Time=%0dns | A=%0d | B=%0d | alu_opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b | div0=%b ",$time, A, B, alu_opcode, result, carry, zero_flag, overflow_flag, div_by_zero);


$display("\n  TEST 4: DIVISION ");
A  = 8'd7;
B  = 8'd2;
alu_opcode = 3'b011;
#10;
$display("Time=%0dns | A=%0d | B=%0d | alu_opcode=%b | result=%0d | carry=%b | zero=%b | overflow=%b | div0=%b ",$time, A, B, alu_opcode, result, carry, zero_flag, overflow_flag, div_by_zero);



$finish;
end

endmodule