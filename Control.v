module Control(
clk,reset,
op,
pc_res,pc_w,pc_wc,pc_src,
mem_r,mem_w,ireg_w,regdst,reg_w,memtoreg,
alu_srca,alu_srcb,alu_op,state
    );
input clk;
input reset;
input [5:0]op;	 
output reg pc_res,pc_w,pc_wc;
output reg [1:0]pc_src;

output reg mem_r,mem_w,ireg_w,regdst,reg_w,memtoreg;

output reg alu_srca;
output reg [1:0]alu_srcb,alu_op;

output reg [3:0]state;

parameter IF=4'b0000,ID=4'b0001,
EX_I=4'b0010,
MEM_R=4'b0011,MEMtoREG=4'b0100,
MEM_W=4'b0101,

EX_R=4'b0110,
ALUtoREG=4'b0111,

EX_B=4'b1000,EX_J=4'b1001;

always @(negedge clk or posedge reset)
if (reset==1)
begin
	state=IF;
	reg_w=1'b0;
	mem_r=1'b0;
	mem_w=1'b0;
	ireg_w=1'b0;
	pc_w=1'b0;
	pc_wc=1'b0;
end
else
begin
	case(state)
	IF:
	begin
	   pc_res=1'b0;
		mem_r=1'b1;
		ireg_w=1'b1;
		alu_srca=1'b0;
		alu_srcb=2'b01;
		alu_op=2'b00;
		pc_src=2'b00;
		pc_w=1'b1;
		state=ID;
		
		reg_w=1'b0;
		mem_w=1'b0;
		pc_wc=1'b0;
	end
	ID:
	begin
	  case(op[5:0])
			6'b000000:
			state=EX_R;
			6'b100011:
			state=EX_I;
			6'b101011:
			state=EX_I;
			6'b000010:
			state=EX_J;
			6'b000100:
			state=EX_B;
			default:state=EX_R;
		endcase
	   alu_srca=1'b0;
		alu_srcb=2'b11;
		alu_op=2'b00;
		
		reg_w=1'b0;
		mem_r=1'b0;
		mem_w=1'b0;
		ireg_w=1'b0;
		pc_w=1'b0;
		pc_wc=1'b0;
	end
	EX_I:
	begin
		alu_srca=1'b1;
		alu_srcb=2'b10;
		alu_op=2'b00;
		if(op[5:0]==6'b100011)
		state=MEM_R;
		else
		state=MEM_W;
	end
	MEM_R:
	begin
		pc_res=1'b1;
		mem_r=1'b1;
		state=MEMtoREG;
	end
	MEMtoREG:
	begin
	   memtoreg=1'b1;
		regdst=1'b0;
		reg_w=1'b1;
		state=IF;
		
		mem_r=1'b0;
		mem_w=1'b0;
		ireg_w=1'b0;
		pc_w=1'b0;
		pc_wc=1'b0;
	end
	MEM_W:
	begin
	   pc_res=1'b1;
		mem_w=1'b1;
		state=IF;
	end
	EX_R:
	begin
	   alu_srca=1'b1;
		alu_srcb=2'b00;
		alu_op=2'b10;
	   state=ALUtoREG;
	end
	ALUtoREG:
	begin
	   memtoreg=1'b0;
		regdst=1'b1;
		reg_w=1'b1;
		state=IF;
	end
	EX_B:
	begin
	   alu_srca=1'b1;
		alu_srcb=2'b00;
		alu_op=2'b01;
		pc_wc=1'b1;
		state=IF;
	end
	EX_J:
	begin
	   pc_src=2'b10;
		pc_w=1'b1;
	   state=IF;
	end
	endcase
end
endmodule
