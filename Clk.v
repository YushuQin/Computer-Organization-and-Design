module Clk(
input wire clk1,
input wire clk,
input wire reset,
output reg [31:0]clk_div1,
output reg [31:0]clk_div
);
always @ (posedge clk1 or posedge reset) 
begin
	if (reset) 
		begin
		clk_div1 <= 0;
		end 
	else 
		begin
		clk_div1 <= clk_div1 + 1'b1;
		end
end
always @ (posedge clk or posedge reset) 
begin
	if (reset) 
		begin
		clk_div <= 0;
		end 
	else 
		begin
		clk_div <= clk_div + 1'b1;
		end
end

endmodule
