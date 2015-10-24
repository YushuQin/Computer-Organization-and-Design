module Alu(alu_a_in,alu_b_in,alu_oper_in,
alu_result_out,alu_zero_out,alu_overflow_out);
input [31:0] alu_a_in,alu_b_in;
input [2:0]alu_oper_in;
output reg[31:0]alu_result_out;
output alu_zero_out;
output reg alu_overflow_out;

wire [31:0]res_and,res_or,res_add,res_sub,res_nor,res_slt,res_xor,res_srl;
wire [31:0]a,b;
assign a=alu_a_in;
assign b=alu_b_in;

assign res_and=a&b;
assign res_or=a|b;
assign res_add=a+b;
assign res_sub=a-b;
assign res_nor=~(a|b);
assign res_slt=(a<b)?32'h00000001:32'h00000000;
assign res_xor=a^b;
assign res_srl=b>>1;

always @* 
begin
   alu_overflow_out=0;
   case(alu_oper_in)
	  3'b000:alu_result_out=res_and;
	  3'b001:alu_result_out=res_or;
	  3'b010:alu_result_out=res_add;    
	  3'b110:alu_result_out=res_sub;  
	  3'b100:alu_result_out=res_nor;
	  3'b111:alu_result_out=res_slt;
	  3'b011:alu_result_out=res_xor;
	  3'b101:alu_result_out=res_srl;
	  default:alu_result_out=res_add;
	endcase
	if(alu_oper_in==3'b010)
	  if((a[31]==0&&b[31]==0)||(a[31]==1&&b[31]==1))
			if(alu_result_out[31]==1)alu_overflow_out=1;
			else alu_overflow_out=0;
	if(alu_oper_in==3'b110)
   begin	
     if(a[31]==1&&b[31]==0)
			if(alu_result_out[31]==0)alu_overflow_out=1;
		   else alu_overflow_out=0; 
     if(a[31]==0&&b[31]==1)
			if(alu_result_out[31]==1)alu_overflow_out=1;
		   else alu_overflow_out=0;			     
	end
end	 
	assign alu_zero_out=(alu_result_out==0)? 1:0;
endmodule
