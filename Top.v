module Top(clk1,
button_in,switch,
led,dig_seg,dig_seg_anode    
);

//Clk,Cpu,memory
wire [5:0]op;
wire [31:0]cpu_data_out;
wire [31:0]cpu_data_in1,cpu_data_in2;
reg [31:0]cpu_data_in;

wire [31:0]pc_out;reg [31:0]pc;

wire mem_w;wire ireg_w;

wire[3:0]state;reg [3:0]beat=0;reg [1:0]type=0;



reg [31:0]disp_num=32'h00000000;
wire [31:0]disp_num1;

always @*
begin
	if(ireg_w==1)
	cpu_data_in=cpu_data_in1;
	else
	cpu_data_in=cpu_data_in2;
end

input clk1;
input [3:0] button_in;wire [3:0] button_out;
input [7:0] switch;
output reg [7:0] led;
output [7:0] dig_seg;
output [3:0] dig_seg_anode;

wire reset;wire clk;wire clk1,clk2;
wire [31:0]clk_div,clk_div1;

always @*
begin
if(reset==1)
pc=0;
else
begin
if(state==1)
pc=pc_out;
end
end

Clk clkclk(
.clk1(clk1),
.clk(clk),
.reset(reset),
.clk_div1(clk_div1),
.clk_div(clk_div)
);
mem_i mem_i (
  .a(pc_out[10:2]), // input [8 : 0] a
  .spo(cpu_data_in1) // output [31 : 0] spo
);
mem_data mem_data (
  .a(pc_out[8:0]), // input [8 : 0] a
  .d(cpu_data_out), // input [31 : 0] d
  .clk(clk), // input clk
  .we(mem_w), // input we
  .spo(cpu_data_in2) // output [31 : 0] spo
);
Cpu cpu(
.clk(clk),
.reset(reset),                 
.pc_out(pc_out),            
.cpu_data_in(cpu_data_in),               
.cpu_data_out(cpu_data_out),
.op(op),
.mem_w(mem_w),
.ireg_w(ireg_w),
//.reg_w(reg_w),.ireg_w(ireg_w),.memtoreg(memtoreg),.regdst(regdst),
//.pc_w(pc_w),.pc_wc(pc_wc),.pc_res(pc_res),.pc_src(pc_src),
//.alu_srca(alu_srca),.alu_srcb(alu_srcb),.alu_op(alu_op),
.disp_num_addr(switch[4:0]),
.disp_num(disp_num1),
.state(state)
);


//led灯，手控Clk和重置，数字管

//led灯
always @*
begin
   case(state)
   4'b0000:begin led[4:0]=	5'b00001; beat=4'b0000;end
	4'b0001:begin led[4:0]=	5'b00010; beat=4'b0001;end
	4'b0010:begin led[4:0]=	5'b00100; beat=4'b0010;end
	4'b0110:begin led[4:0]=	5'b00100; beat=4'b0010;end
	4'b1000:begin led[4:0]=	5'b00100; beat=4'b0010;end
	4'b1001:begin led[4:0]=	5'b00100; beat=4'b0010;end
	4'b0011:begin led[4:0]=	5'b01000; beat=4'b0011;end
	4'b0101:begin led[4:0]=	5'b01000; beat=4'b0011;end
	4'b0111:begin led[4:0]=	5'b01000; beat=4'b0011;end
	4'b0100:begin led[4:0]=	5'b10000; beat=4'b0100;end
	endcase
	led[7]=~switch[7];//手动
   led[6]=switch[7];//自动
   led[5]=button_out[2];
end

//手控Clk和重置
pbdebounce b2(clk1, button_in[2], button_out[2]);
pbdebounce b3(clk1, button_in[3], button_out[3]);
assign reset=button_out[2];//手控重置赋值

assign clk=(~switch[7]&button_out[3])|(clk_div1[27]&switch[7]);//手控或者自动Clk赋值

//数码管
always @*
begin
   case(op[5:0])
         6'b000000:
			type=2'b01;
			6'b100011:
			type=2'b10;
			6'b101011:
			type=2'b10;
			6'b000100:
			type=2'b10;
			6'b000010:
			type=2'b11;
	endcase
end
always @(posedge clk1 or posedge reset) 
begin
	if(reset)
	
	   disp_num <= 32'h00000000;
   
	else 
	begin
		case(switch[6:5])
		2'b00: disp_num <= disp_num1;
		2'b01: disp_num <= {16'h0000,disp_num1[31:16]};
		//显示制定寄存器内的值
		2'b10: 
		   begin
		   disp_num[3:0]   <= pc[5:2];
			disp_num[7:4]   <= beat;
			disp_num[11:8]  <= {2'b00,type[1:0]};
			disp_num[15:12] <= clk_div[3:0];
			end
		//显示 PC 值，字地址
		2'b11: disp_num <= clk_div[31:0];
		
		endcase
	end
end
Hex7seg hexH7seg(
.disp_num(disp_num),
.reset(reset),
.scanning(clk_div1[19:18]),
.digit_seg(dig_seg),
.dig_seg_anode(dig_seg_anode)
);
endmodule
