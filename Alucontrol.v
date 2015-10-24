module Alucontrol(op,func,ALUoper);
input wire [1:0] op;
input wire [5:0] func;
output wire [2:0] ALUoper;

assign ALUoper[2]=op[0]+op[1]&((~func[3]&~func[2]&func[1]&~func[0])
+(func[3]&~func[2]&func[1]&~func[0])+(~func[3]&func[2]&func[1]&func[0]));

assign ALUoper[1]=~((op[1]&~func[3]&func[2]&~func[1]&~func[0])
+(op[1]&~func[3]&func[2]&~func[1]&func[0])+(op[1]&~func[3]&func[2]&func[1]&func[0]));

assign ALUoper[0]=(op[1]&~func[3]&func[2]&~func[1]&func[0])
+(op[1]&func[3]&~func[2]&func[1]&~func[0]);
endmodule
