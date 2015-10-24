module RegisterFile(clk,reset,
reg_addr_rs_in,reg_addr_rt_in,
reg_w_in,reg_data_w_in,reg_addr_w_in,
reg_data_rs_out,reg_data_rt_out,
disp_num_addr,disp_num
    );
input clk,reset; 
input [4:0]reg_addr_rs_in,reg_addr_rt_in; 
input reg_w_in;            
input [4:0]reg_addr_w_in;
input [31:0]reg_data_w_in;    

 
output [31:0]reg_data_rs_out,reg_data_rt_out; //data read out
	
input [4:0] disp_num_addr;
output [31:0] disp_num;


reg[31:0]register[1:15];  
integer i ;
assign reg_data_rs_out=(reg_addr_rs_in==0)?0:register[reg_addr_rs_in];
assign reg_data_rt_out=(reg_addr_rt_in==0)?0:register[reg_addr_rt_in];
assign disp_num=(disp_num_addr==0)?0:register[disp_num_addr];

always @(posedge clk or posedge reset)
begin
	 if(reset==1)
		 begin
			for (i=1;i<16;i=i+1)
			register[i]<=0;
		 end 
	 else 
		 begin 
			 if((reg_addr_w_in!=0)&&(reg_w_in==1))
			  register[reg_addr_w_in]<=reg_data_w_in;
		 end		 
end
endmodule

