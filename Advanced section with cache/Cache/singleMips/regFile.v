//regFile
//register file
//yi

module regFile(input wire clock_in,
			input wire rst,
			input wire[4:0]readReg1,
			input wire[4:0]readReg2,
			input wire[4:0]writeReg,
			input wire[31:0]writeData,
			input wire regWrite,
			output reg[31:0]readData1,
			output reg[31:0]readData2
			);

reg [31:0] regs[31:0];


always@(*)
begin
	readData1<=regs[readReg1];
end

always@(*)
begin
	readData2<=regs[readReg2];
end

always@(negedge clock_in or posedge rst)
begin
	if(rst==1)
		begin
		regs[0]<=0;regs[1]<=0;regs[2]<=0;regs[3]<=0;regs[4]<=0;regs[5]<=0;regs[6]<=0;regs[7]<=0;
		regs[8]<=0;regs[9]<=0;regs[10]<=0;regs[11]<=0;regs[12]<=0;regs[13]<=0;regs[14]<=0;regs[15]<=0;
		regs[16]<=0;regs[17]<=0;regs[18]<=0;regs[19]<=0;regs[20]<=0;regs[21]<=0;regs[22]<=0;regs[23]<=0;
		regs[24]<=0;regs[25]<=0;regs[26]<=0;regs[27]<=0;regs[28]<=0;regs[29]<=0;regs[30]<=0;regs[31]<=0;
		end
	else if(regWrite==1)
		regs[writeReg]<=writeData;
end

//export the result of regfiles
integer outfile;
integer timeCount;
initial begin
  outfile = $fopen("output.txt","a"); //location is the modelsim project
	timeCount = 0;
end

endmodule
