module Mem(clock_in,rst,addr, writeData, memRead, memWrite, readData);

input clock_in;
input rst;
input [31:0] addr;
input [31:0] writeData;
input memRead;
input memWrite;

output reg[31:0] readData;

reg [31:0] DataMem [0:63];

always@(negedge clock_in or posedge rst)
begin
	if(rst==1)
	readData<=0;
	else if(memRead==1)
	readData<=DataMem[addr/4];
end

always@(negedge clock_in or posedge rst)
if(memWrite==1)
		DataMem[addr/4] <= writeData;


endmodule
