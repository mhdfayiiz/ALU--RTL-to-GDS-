module Control_unit(input clk,input reset,input [2:0]opcode,input start, output reg load_A,output reg load_B,output reg load_result, output reg [2:0] alu_opcode,output reg done);



parameter IDLE=2'b00;
parameter LOAD=2'b01;
parameter EXECUTE=2'b10;
parameter WRITEBK=2'b11; 

reg[1:0] state ,next_state;

always @(posedge clk or posedge reset)
begin 
if(reset)
state<=IDLE;
else
state<=next_state;
end


always @(*)
begin 
case(state)

IDLE:begin
if(start)
next_state=LOAD;
else
next_state=IDLE;
end

LOAD:
next_state=EXECUTE;

EXECUTE:
next_state=WRITEBK;

WRITEBK:
next_state=IDLE;

default:
next_state=IDLE;


endcase
end


always @(*)
begin 
load_A=1'b0;
load_B=1'b0;
load_result=1'b0;
alu_opcode=opcode;
done=1'b0;

case(state)


IDLE:begin
done=1'b1;
end
LOAD:begin
load_A=1'b1;
load_B=1'b1; 
end
EXECUTE:
begin
alu_opcode=opcode;
end

WRITEBK:begin 
load_result=1'b1;
end
default:begin
end

endcase

end
endmodule
