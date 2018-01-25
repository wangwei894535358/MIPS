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
	
multiMips multiMips(.clk(clk), .rst(rst));

integer k;
initial begin
	k = 0;
end

always @ (clk2, k) 
begin
	$display("Time  = %d, [clk] = %d", k, clk);		
	$display("[$s0] = %d, [$s1] = %d, [$s2] = %d", multiMips.regfile.regs[16], multiMips.regfile.regs[17], multiMips.regfile.regs[18]);	
	$display("[$s3] = %d, [$s4] = %d, [$s5] = %d", multiMips.regfile.regs[19], multiMips.regfile.regs[20], multiMips.regfile.regs[21]);
	$display("[$s6] = %d, [$s7] = %d, [$t0] = %d", multiMips.regfile.regs[22], multiMips.regfile.regs[23], multiMips.regfile.regs[8]);
	$display("[$t1] = %d, [$t2] = %d, [$t3] = %d", multiMips.regfile.regs[9],  multiMips.regfile.regs[10], multiMips.regfile.regs[11]);
	$display("[$t4] = %d, [$t5] = %d, [$t6] = %d", multiMips.regfile.regs[12], multiMips.regfile.regs[13], multiMips.regfile.regs[14]);
	$display("[$t7] = %d, [$t8] = %d, [$t9] = %d", multiMips.regfile.regs[15], multiMips.regfile.regs[24], multiMips.regfile.regs[25]);
	$display();
	if(clk == 0) begin
		k = k+1;
	end	
end

integer i;
initial
begin
	for(i = 0; i < 32; i = i + 1) begin
		multiMips.regfile.regs[i] = 32'b0;
	end
	
	for(i = 0; i < 64; i = i + 1) begin
		multiMips.mem.DataMem[i] = 0;
	end
	multiMips.mem.DataMem[0] = 32'h00000001;
	multiMips.mem.DataMem[2] = 32'h00000003;
	multiMips.mem.DataMem[3] = 32'h00000004;
end

endmodule
