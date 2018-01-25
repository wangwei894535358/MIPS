module singleMips(input wire clk,
			input wire rst
			);
			
wire [5:0] op;
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [15:0] immediate_16;
wire [31:0] immediate_32; //signext

//Control
wire regDst;
wire memtoReg;
wire regWrite;
wire memRead;
wire memWrite;
wire branch;
wire jump;
wire [1:0] ALUOp;
wire ALUSrc;

//AluCtr
wire [5:0]funct;
wire [3:0]aluCtr;

//ALU
wire zero;
wire [31:0] aluRes;
wire [31:0] ALUInput2;
wire [31:0] ALUInput1;


//Register
wire [4:0] regReadReg1;
wire [4:0] regReadReg2;
wire [31:0] regReadData1;
wire [31:0] regReadData2;
wire [4:0] regWriteReg;
wire [31:0] regWriteData;


//Memory
wire [31:0] memReadData;
wire [31:0] memWriteData;
wire [31:0] memAddress;

//cache
wire cache_stall;
wire	[256-1:0]	mem_data_i; 
wire				mem_ack_i; 	
wire	[256-1:0]	mem_data_o; 
wire	[32-1:0]	mem_addr_o; 	
wire				mem_enable_o; 
wire				mem_write_o;


//pc & instruction
reg [31:0] pc;
wire [31:0] pc2;
wire [31:0] jumpAddress;
wire [31:0] addAluResult;
wire [31:0] muxPc1;
wire [31:0] muxPc2;

wire [31:0] instruction;


//pc logic
assign pc2 = pc + 4;
assign jumpAddress = {pc2[31:28], instruction[25:0],2'b0};
assign addAluResult = pc2 + (immediate_32<<2);
assign muxPc1 = (branch & zero)?addAluResult:pc2;
assign muxPc2 = jump?jumpAddress:muxPc1;

always@(posedge clk or posedge rst)
begin
    if (rst == 1)
        pc <= 0;
    else
		begin
			if(cache_stall)
				pc <= pc;
			else
				pc <= muxPc2;
		end
end

//instruction
InstructionMem instructionMem(.address(pc),
                       .instruction(instruction));

//control logic
assign op = instruction[31:26];
assign rs = instruction[25:21];
assign rt = instruction[20:16];
assign rd = instruction[15:11];
assign funct = instruction[5:0];
assign immediate_16 = instruction[15:0];

control ctr(.opCode(op),
    .regDst(regDst),
    .jump(jump),
    .branch(branch),
    .memRead(memRead),
    .memWrite(memWrite),
    .memtoReg(memtoReg),
    .ALUOp(ALUOp),
    .ALUSrc(ALUSrc),
    .regWrite(regWrite));


//register logic
assign regReadReg1 = rs;
assign regReadReg2 = rt;
assign regWriteReg = regDst?rd:rt;
assign regWriteData = memtoReg?memReadData:aluRes;
regFile regfile(.clock_in(clk),
    .rst(rst),
    .readReg1(regReadReg1),
    .readReg2(regReadReg2),
    .writeReg(regWriteReg),
    .writeData(regWriteData),
    .regWrite(regWrite),
    .readData1(regReadData1),
    .readData2(regReadData2));

//alu & aluctr logic
AluCtr aluctr(.aluOp(ALUOp),
    .funct(funct),
    .aluCtr(aluCtr));

assign ALUInput1 = regReadData1;
assign ALUInput2 = ALUSrc?immediate_32:regReadData2;
Alu alu(.input1(ALUInput1),
    .input2(ALUInput2),
    .aluCtr(aluCtr),
    .zero(zero),
    .aluRes(aluRes));

//signext
signext ext(.inst(immediate_16),
    .data(immediate_32));

//mem logic


assign memWriteData = regReadData2;
assign memAddress = aluRes;

cache cache
(
    // System clock, reset and stall
	.clk_i(clk), 
	.rst_i(rst),
	
	
	// to CPU interface	
	.p1_data_i(memWriteData), 
	.p1_addr_i(memAddress), 	
	.p1_MemRead_i(memRead), 
	.p1_MemWrite_i(memWrite), 
	.p1_data_o(memReadData), 
	.p1_stall_o(cache_stall),
	
	// to Data Memory interface		
	.mem_data_i(mem_data_i), 
	.mem_ack_i(mem_ack_i), 	
	.mem_data_o(mem_data_o), 
	.mem_addr_o(mem_addr_o), 	
	.mem_enable_o(mem_enable_o), 
	.mem_write_o(mem_write_o)
);


Data_Memory Data_Memory
(
	.clk_i    (clk),
	.rst_i    (rst),
	.addr_i   (mem_addr_o),
	.data_i   (mem_data_o),
	.enable_i (mem_enable_o),
	.write_i  (mem_write_o),
	.ack_o    (mem_ack_i),
	.data_o   (mem_data_i)
);


endmodule
