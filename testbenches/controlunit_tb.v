module controlunit_tb;

reg clk;
reg reset;
reg [2:0]opcode;
reg start; wire load_A;
wire load_B;
wire load_result;
wire [2:0] alu_opcode;
wire done;

Control_unit dut(.clk(clk),.reset(reset),.opcode(opcode),.start(start), .load_A(load_A),.load_B(load_B),.load_result(load_result), .alu_opcode(alu_opcode),.done(done));

always #5 clk = ~clk;
initial 
begin 
$monitor("load_A=%b , load_B=%b , load_result=%b,alu_opcode=%b ,done = %b",load_A,load_B,load_result,alu_opcode,done);
end

initial 
begin
clk=0;
start =0;
opcode=3'b000;
reset =1;
#10;
reset=0;

#10;

start =1;
#10;
start=0;

#50;
$finish;

end
endmodule




