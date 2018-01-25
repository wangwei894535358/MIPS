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
		 Imemory[0]  = 32'b10001100000010000000000000001000; //lw $10 , 40($0)	
		 Imemory[1]  = 32'b00100000000010010000000000000100; //addi $t0, $zero, 32
		 Imemory[2]  = 32'b10001101001010010000000000010000; //andi 
		 Imemory[3]  = 32'b00010001100010010000000000000101;
		 Imemory[4]  = 32'b00000001000010010101000000100000;
		 Imemory[5]  = 32'b00000001000010010101100000100010;
		 Imemory[6]  = 32'b00000001000010010110000000100100;
		 Imemory[7]  = 32'b00000001000010010110100000100101;
		 Imemory[8]  = 32'b00001000000000000000000000000011;
		 Imemory[9]  = 32'b00110001000011100000000000000001;
		Imemory[10]  = 32'b00000001001010000111100000101010;
		Imemory[11]  = 32'b10101100000011110000000000000100;
		Imemory[12]  = 32'b0;
		Imemory[13]  = 32'b0;
		Imemory[14]  = 32'b0;
		Imemory[15]  = 32'b0;
		Imemory[16]  = 32'b0;
		Imemory[17]  = 32'b0;
		Imemory[18]  = 32'b0;
		Imemory[19]  = 32'b0;
		Imemory[20]  = 32'b0;
		Imemory[21]  = 32'b0;
		Imemory[22]  = 32'b0;
		Imemory[23]  = 32'b0;
		Imemory[24]  = 32'b0;
		Imemory[25]  = 32'b0;
		Imemory[26]  = 32'b0;
		Imemory[27]  = 32'b0;
		
	// lw $8,8($0) 
	// addi $9,$0,4
	// lw $9,16($9) 
	// beq $12,$9,flag2
	// add $10,$8,$9  
	// sub $11,$8,$9  
	// and $12,$8,$9  
	// or $13,$8,$9  
	// j flag1
	// addi $14,$8,1 
	// slt $15,$9,$8	
	// sw $15,4($0)

	
		


end

always @ (address)
	begin
		instruction <= Imemory[address[13:2]];
end
endmodule
