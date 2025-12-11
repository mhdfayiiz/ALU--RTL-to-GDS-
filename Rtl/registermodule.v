module Registers(
input signed [7:0] A_in,
input signed [7:0]B_in,
input signed [7:0]alu_result,
input clk,reset,
input load_A,
input load_B,
input load_result,
output reg signed [7:0]A_out,
output reg signed [7:0]B_out,
output reg signed [7:0]result_out);


always @ (posedge clk or posedge reset)
begin 
if(reset)
begin 
A_out<=8'b0;
B_out<=8'b0;
result_out<=8'b0;
end

else
begin
if(load_A) A_out<=A_in;
if(load_B) B_out<=B_in;
if(load_result) result_out<=alu_result;
end

end

endmodule