module Top(
    input clk,
    input reset,
    input start,              
    input [7:0] A_in,         
    input [7:0] B_in,    
    input [2:0] opcode,      

    output [7:0] result_out, 
    output carry,
    output zero_flag,
    output overflow_flag,
    output div_by_zero,
    output done
);

wire load_A, load_B, load_result;
wire [2:0] alu_opcode;
wire signed [7:0] A_out, B_out, alu_result;


Control_unit cu_unit(
    .clk(clk),
    .reset(reset),
    .opcode(opcode),
    .start(start),
    .load_A(load_A),
    .load_B(load_B),
    .load_result(load_result),
    .alu_opcode(alu_opcode),
    .done(done)
);


Registers reg_unit(
    .load_A(load_A),
    .load_B(load_B),
    .load_result(load_result),
    .A_in(A_in),
    .B_in(B_in),
    .alu_result(alu_result),
    .A_out(A_out),
    .B_out(B_out),
    .result_out(result_out),
    .clk(clk),
    .reset(reset)
);


Alu alu_unit(
    .A(A_out),
    .B(B_out),
    .alu_opcode(alu_opcode),
    .result(alu_result),
    .carry(carry),
    .zero_flag(zero_flag),
    .overflow_flag(overflow_flag),
    .div_by_zero(div_by_zero)
);

endmodule





