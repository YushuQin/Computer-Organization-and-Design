module Cpu(
clk,reset,         
pc_out,            
cpu_data_in,               
cpu_data_out,
op,                                 
mem_w,                              
ireg_w,                         
disp_num_addr,
disp_num,
state                              
);
input clk,reset;

output reg[31:0] pc_out;

input [31:0] cpu_data_in;
output [31:0] cpu_data_out;
output [5:0]op;
output mem_w;wire mem_r;
output ireg_w;
output [3:0]state;

reg [31:0]ireg;
assign op=ireg[31:26];

input [4:0] disp_num_addr;
output [31:0] disp_num;
 
reg [31:0] memdatareg;   

wire [4:0]  reg_addr_w_in,reg_addr_rs_in, reg_addr_rt_in, reg_addr_rd_in;
wire [31:0] reg_data_w_in,reg_data_rs_out,reg_data_rt_out;

reg [31:0] alu_out; 
reg [31:0] alu_a_in,alu_b_in;
wire [31:0] alu_result_out; 
wire [2:0]alu_oper_in;
wire alu_zero_out,alu_overflow_out ;//Alu

wire [31:0] pc_4;
reg [31:0] pc;
 
assign cpu_data_out=reg_data_rt_out;  

wire reg_w,ireg_w,memtoreg,regdst;

wire pc_w,pc_wc,pc_res;
wire [1:0]pc_src;

wire alu_srca;
wire [1:0]alu_srcb,alu_op;
wire [3:0]state;

Control control(
clk,reset,op,
pc_res,pc_w,pc_wc,pc_src,
mem_r,mem_w,ireg_w,regdst,reg_w,memtoreg,
alu_srca,alu_srcb,alu_op,state);

initial begin pc_out=32'h00000000; end
always @(posedge clk or posedge reset)
begin
   if(reset==1)
	begin
		pc=32'h00000000;
	end
   else 
	begin
		if(pc_w||(alu_zero_out&pc_wc))
		begin
			case(pc_src)
			2'b00:pc=alu_result_out;
			2'b01:pc=alu_out;
			2'b10:pc={pc[31:28],ireg[25:0],2'b00};
			endcase
		end
	end
end
always @*
begin
	if(pc_res==0)
	pc_out=pc;
	if(pc_res==1)
	pc_out=alu_out;
end

Alucontrol alucontrol(
.op(alu_op),
.func(ireg[5:0]),
.ALUoper(alu_oper_in)
);
always @*
begin
   
   case(alu_srcb)
	2'b00:begin alu_b_in=reg_data_rt_out ;end
	2'b01:begin alu_b_in=32'b00000100 ;end
	2'b10:begin alu_b_in={{16{ireg[15]}},ireg[15:0]};end
	2'b11:alu_b_in={{14{ireg[15]}},ireg[15:0],2'b00};
	endcase
	
	if(alu_srca==0)
	begin
	alu_a_in=pc;
	end
	else
	begin
	alu_a_in=reg_data_rs_out;
	end
	
end

Alu alu(
.alu_a_in(alu_a_in),
.alu_b_in(alu_b_in),
.alu_oper_in(alu_oper_in),
.alu_result_out(alu_result_out),
.alu_zero_out(alu_zero_out),
.alu_overflow_out(alu_overflow_out)
);

always @(posedge clk or posedge reset)
begin
if(reset==1)
begin
	memdatareg=32'b00000000;
	ireg=32'b00000000;
end
else
begin
	if(ireg_w==1)
	begin
   ireg=cpu_data_in;
	end
	memdatareg=cpu_data_in;
	alu_out=alu_result_out;
end
end
assign reg_addr_rs_in=ireg[25:21];  
assign reg_addr_rt_in=ireg[20:16];  
assign reg_addr_rd_in=ireg[15:11];  

assign reg_addr_w_in=(regdst)? reg_addr_rd_in:reg_addr_rt_in;
assign reg_data_w_in=(memtoreg)? memdatareg : alu_out ;

RegisterFile reg_files(
.clk(clk),
.reset(reset),
.reg_addr_rs_in(reg_addr_rs_in),
.reg_addr_rt_in(reg_addr_rt_in),
.reg_addr_w_in(reg_addr_w_in),
.reg_data_w_in(reg_data_w_in),
.reg_w_in(reg_w),
.reg_data_rs_out(reg_data_rs_out),
.reg_data_rt_out(reg_data_rt_out),
.disp_num_addr(disp_num_addr),
.disp_num(disp_num)
);
endmodule

