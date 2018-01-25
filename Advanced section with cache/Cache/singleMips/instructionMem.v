`timescale 1ns / 1ps
module InstructionMem(instruction,address);
input[31:0] address;
output reg [31:0] instruction;
reg[31:0] Imemory[63:0];

integer k;

initial begin
	for(k=0;k<64;k=k+1)begin
		Imemory[k] = 32'b0;
	end
	//You can give your own code block here.
	//$t0: 01000 8, $t1: 01001: 9, $s0: 10000 16, $s1: 10001 17, $s2 10010 18 $s3 10011 19
	//
		Imemory[0]  = 32'b10001100000010010000000000101000; //lw $10 , 40($0)	
		Imemory[1]  = 32'b10001100000010100000000000101100; //addi $t0, $zero, 32
		Imemory[2]  = 32'b10001100000010110000000000110000; //andi 
		Imemory[3]  = 32'b00000001001010100110000000100000;
		Imemory[4]  = 32'b10101100000011000000000000101000;
		Imemory[5]  = 32'b00000001011010010110100000100010;
		Imemory[6]  = 32'b10101100000011010000000000101100;
		Imemory[7]  = 32'b00000001010010010111000000100100;
		Imemory[8]  = 32'b10101100000011100000000000110000;
		Imemory[9]  = 32'b00000001001010100110000000100000;
		Imemory[10]  = 32'b10101100000011000000000000101000;
		Imemory[11]  = 32'b10001100000010110000000000101000;
		Imemory[12]  = 32'b00000001011010010110100000100010;
		Imemory[13]  = 32'b10101100000011010000000000101100;
		Imemory[14]  = 32'b10001100000010010000000000101100;
		Imemory[15]  = 32'b10001100000010100000000000101000;
		Imemory[16]  = 32'b00000001010010010111000000100100;
		Imemory[17]  = 32'b10101100000011100000000000101000;
		Imemory[18]  = 32'b00000001110000001001100000100000;
		Imemory[19]  = 32'b10001100000100110000000000101000;
		Imemory[20]  = 32'b10001100000100110000000000101000;
		Imemory[21]  = 32'b10001100000100110000000000101000;
		Imemory[22]  = 32'b00000001011010010111100000100101;
		Imemory[23]  = 32'b00000001011010011000000000101010;
		Imemory[24]  = 32'b00010010011000000000000000000001;
		Imemory[25]  = 32'b00000001111100001000000000100000;
		Imemory[26]  = 32'b10001100000100110000000000010000;
		Imemory[27]  = 32'b00001000000000000000000000011010;
		
		
		


end

always @ (address)
	begin
		instruction <= Imemory[address[13:2]];
end
endmodule
