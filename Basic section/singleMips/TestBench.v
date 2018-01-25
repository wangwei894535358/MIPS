`timescale 1ns/1ps
module TestBench;

reg clk;
reg clk2;
reg rst;

initial begin
    clk = 1;
	clk2 = 1;
    rst = 0;
    #0.1 rst = 1;
    #0.2 rst = 0;             
end

always #1	begin
    clk = ~clk;
	#0.1 clk2 = ~clk2;
end
	
singleMips singleMips(.clk(clk), .rst(rst));

integer k;
initial begin
	k = 0;
end

always @ (clk2, k) 
begin
	$display("Time  = %d, [clk] = %d", k, clk);		
	$display("[$s0] = %d, [$s1] = %d, [$s2] = %d", singleMips.regfile.regs[16], singleMips.regfile.regs[17], singleMips.regfile.regs[18]);	
	$display("[$s3] = %d, [$s4] = %d, [$s5] = %d", singleMips.regfile.regs[19], singleMips.regfile.regs[20], singleMips.regfile.regs[21]);
	$display("[$s6] = %d, [$s7] = %d, [$t0] = %d", singleMips.regfile.regs[22], singleMips.regfile.regs[23], singleMips.regfile.regs[8]);
	$display("[$t1] = %d, [$t2] = %d, [$t3] = %d", singleMips.regfile.regs[9],  singleMips.regfile.regs[10], singleMips.regfile.regs[11]);
	$display("[$t4] = %d, [$t5] = %d, [$t6] = %d", singleMips.regfile.regs[12], singleMips.regfile.regs[13], singleMips.regfile.regs[14]);
	$display("[$t7] = %d, [$t8] = %d, [$t9] = %d", singleMips.regfile.regs[15], singleMips.regfile.regs[24], singleMips.regfile.regs[25]);
	$display();
	if(clk == 0) begin
		k = k+1;
	end	
end

integer i;
initial
begin
	for(i = 0; i < 32; i = i + 1) begin
		singleMips.regfile.regs[i] = 32'b0;
	end
	
	for(i = 0; i < 64; i = i + 1) begin
		singleMips.mem.DataMem[i] = 0;
	end
	singleMips.mem.DataMem[2] = 32'h00001111;
	singleMips.mem.DataMem[5] = 32'h00001011;
	
end

endmodule
