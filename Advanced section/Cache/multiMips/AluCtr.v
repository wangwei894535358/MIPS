module AluCtr(aluOp,funct,aluCtr);

input      [1:0] aluOp;
input      [5:0] funct;
output reg [3:0] aluCtr;

always @ (aluOp or funct)
	casex ({aluOp,funct})
		8'b00xxxxxx:aluCtr=4'b0010;
		8'bx1xxxxxx:aluCtr=4'b0110;
		8'b1xxx0000:aluCtr=4'b0010;
		8'b1xxx0010:aluCtr=4'b0110;
		8'b1xxx0100:aluCtr=4'b0000;
		8'b1xxx0101:aluCtr=4'b0001;
		8'b1xxx1010:aluCtr=4'b0111;
	endcase
	
endmodule