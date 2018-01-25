module Alu(
	input      [31:0] input1,
	input      [31:0] input2,
	input      [3:0]  aluCtr,
	output            zero,
	output reg [31:0] aluRes
);

assign zero = (aluRes==0)?1:0;

always @ (input1 or input2 or aluCtr)
begin
	if(aluCtr == 4'b0000)
		aluRes = input1 & input2;
	else if(aluCtr == 4'b0001)
		aluRes = input1 | input2;
	else if(aluCtr == 4'b0010)
		aluRes = input1 + input2;
	else if(aluCtr == 4'b0110)
		aluRes = input1 - input2;
	else if(aluCtr == 4'b0111)
		aluRes = (input1 < input2)?1:0;
	else if(aluCtr == 4'b1100)
		aluRes = ~(input1 | input2);
end

endmodule
