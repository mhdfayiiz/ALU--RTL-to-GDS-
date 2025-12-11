module Alu(
input signed [7:0]A,
input signed [7:0]B,
input [2:0]alu_opcode,
output reg signed [7:0]result,
output reg carry,
output reg zero_flag,
output reg overflow_flag,
output reg div_by_zero );

always @ (*)
begin
result=8'b0;
carry=1'b0;
zero_flag=1'b0;
overflow_flag=1'b0;
div_by_zero =1'b0;

case(alu_opcode)

3'b000:
begin 
{carry,result}=A+B;
overflow_flag = (A[7] == B[7]) && (result[7] != A[7]);
zero_flag = (result ==8'b0);
end

3'b001:
begin
{carry,result}=A-B;
carry=(A<B);
overflow_flag = (A[7] != B[7]) && (result[7] != A[7]);
zero_flag = (result == 8'b0);
end

3'b010:
begin
result=A*B & 8'hFF;
zero_flag=(result==0);
end

3'b011:
begin
if(B==8'b0)
begin
div_by_zero=1'b1;
result=8'b0;
end
else
begin
result=A/B;
zero_flag=(result==8'b0);
end

end

endcase

end

endmodule