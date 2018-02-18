module multiMips(input wire clk,
			input wire rst
			);

wire [5:0] op;
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [15:0] immediate_16;
wire [31:0] immediate_32; //signext
wire [31:0] ALUInput2tmp;


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
//!!!!

//ALU
wire zero;
wire [31:0] aluRes;
wire [31:0] ALUInput2;
wire [31:0] ALUInput1;

//cache
wire cache_stall;

//pc & instruction
reg [31:0] pc;
wire [31:0] pcAdd4;
wire [31:0] jumpAddress;
wire [31:0] branchAddress;
wire [31:0] nextPc;

wire [31:0] instruction;

//Register
wire [4:0] regReadReg1;
wire [4:0] regReadReg2;
wire [31:0] regReadData1;
wire [31:0] regReadData2;
wire [4:0] regWriteReg;
wire [31:0] regWriteData;

//Memory
wire [31:0] memReadData;
//wire [31:0] memWriteData;
//wire [31:0] memAddress;
//!!!!



//1.0 for stage IF to ID
reg [31:0] IF_ID_PcAdd4;
reg [31:0] IF_ID_Instruction;

//2.0 for stage ID to Ex
reg [31:0] ID_EX_RegReadData1;
reg [31:0] ID_EX_RegReadData2;
reg [31:0] ID_EX_Immediate_32;
reg [4:0] ID_EX_RegisterRt;
reg [4:0] ID_EX_RegisterRd;
reg [4:0] ID_EX_RegisterRs; //??
reg [5:0] ID_EX_Funct;

//2.1 to EX
reg ID_EX_RegDst;
reg [31:0] ID_EX_PcAdd4;
reg [1:0] ID_EX_ALUOp;
reg ID_EX_ALUSrc;
//2.2 to Mem
reg ID_EX_Branch;
reg ID_EX_MemRead;
reg ID_EX_MemWrite;
//2.3 to WB
reg ID_EX_MemtoReg;
reg ID_EX_RegWrite;

//3.0
reg [31:0] EX_MEM_ALURes;
reg [31:0] EX_MEM_regRead;
//reg [31:0] EX_MEM_ALUInput2;
reg [31:0] EX_MEM_addAluResult;
reg [4:0] EX_MEM_RegWriteReg;
reg EX_MEM_zero;

//3.1 to Mem
reg EX_MEM_Branch;
reg EX_MEM_MemRead;
reg EX_MEM_MemWrite;
//3.2 to WB
reg EX_MEM_MemtoReg;
reg EX_MEM_RegWrite;
//for branch
reg [1:0]EX_MEM_ALUOp;

//4.0
reg [31:0] MEM_WB_MemReadData;
reg [31:0] MEM_WB_ALURes;
reg [4:0] MEM_WB_RegWriteReg;

//4.1 to WB
reg MEM_WB_MemtoReg;
reg MEM_WB_RegWrite;///<------

reg DataHazardFlush;
reg [1:0]ForwardA;
reg [1:0]ForwardB;



wire	[256-1:0]	mem_data_i; 
wire				mem_ack_i; 	
wire	[256-1:0]	mem_data_o; 
wire	[32-1:0]	mem_addr_o; 	
wire				mem_enable_o; 
wire				mem_write_o; 



//branch begin

//detect
/* in order to put branch from MEM to ID, we need solve datahazard problem for branch.
case 0: no datahazard
case 1: one of beq srcs is the rd of last last R-type instruction | solve：bypass from EX_MEM_ALURes
case 2: one of beq srcs is the rd of last R-type instruction | solve：bypass from ALURes
case 3: one of beq srcs is the rd of last last lw instruction | solve: bypass from memReadData
case 4: one of beq srcs is the rd of last lw instruction | solve: stall.the stall would change case2->case1->case0 and case4->case3. 
so the source num of branch detect is 4*/
reg [1:0]Br_ForwardA;
reg [1:0]Br_ForwardB;
reg Br_StallA;
reg Br_StallB;
always@(*)begin
	if(branch == 1 && EX_MEM_ALUOp == 2'b10 && rs == EX_MEM_RegWriteReg)//case 1
		Br_ForwardA <= 2'b01;
	else if(branch == 1 && ID_EX_ALUOp == 2'b10 && rs == ID_EX_RegisterRd) // case 2
		Br_ForwardA <= 2'b10;
	else if(branch == 1 && EX_MEM_MemRead == 1 && rs == EX_MEM_RegWriteReg)//case 3
		Br_ForwardA <= 2'b11;
	else if(branch == 1 && ID_EX_MemRead == 1 && rs == regWriteReg)//case 4
		Br_StallA <= 1;
	else begin											//case 0 and default
		Br_ForwardA <= 0;
		Br_StallA <= 0;
		end
end

always@(*)begin
	if(branch == 1 && EX_MEM_ALUOp == 2'b10 && rt == EX_MEM_RegWriteReg)//case 1
		Br_ForwardB <= 2'b01;
	else if(branch == 1 && ID_EX_ALUOp == 2'b10 && rt == ID_EX_RegisterRd) // case 2
		Br_ForwardB <= 2'b10;
	else if(branch == 1 && EX_MEM_MemRead == 1 && rt == EX_MEM_RegWriteReg)//case 3
		Br_ForwardB <= 2'b11;
	else if(branch == 1 && ID_EX_MemRead == 1 && rt == regWriteReg)//case 4
		Br_StallB <= 1;
	else begin											//case 0 and default
		Br_ForwardB <= 0;
		Br_StallB <= 0;
		end
end

//mux
wire [31:0]cmp_in1;
wire [31:0]cmp_in2;
assign cmp_in1 = Br_ForwardA[1]?(Br_ForwardA[0]?memReadData:aluRes):(Br_ForwardA[0]?EX_MEM_ALURes:regReadData1);
assign cmp_in2 = Br_ForwardB[1]?(Br_ForwardB[0]?memReadData:aluRes):(Br_ForwardB[0]?EX_MEM_ALURes:regReadData2);

//cmp
wire ID_Zero;
assign ID_Zero = (cmp_in1==cmp_in2)?1:0;

//branch end
	
//flush data hazard
always@(*)
	if(ID_EX_MemRead && !op &&((ID_EX_RegisterRt == rs) ||
	    (ID_EX_RegisterRt == rt)))
		DataHazardFlush = 1;
	else
		DataHazardFlush = 0;
//flush data hazard end

//bypass begin
wire [31:0]EX_MEM_RegisterRd;
wire [31:0]MEM_WB_RegisterRd;
assign EX_MEM_RegisterRd = EX_MEM_RegWriteReg;
assign MEM_WB_RegisterRd = MEM_WB_RegWriteReg;
always@(*) begin
	if((EX_MEM_RegWrite == 1) && 
		(EX_MEM_RegisterRd != 0) &&
		(EX_MEM_RegisterRd == ID_EX_RegisterRs))
			ForwardA<=2'b10;
	else if((MEM_WB_RegWrite == 1) && 
		(MEM_WB_RegisterRd != 0) &&
		(MEM_WB_RegisterRd == ID_EX_RegisterRs))
			ForwardA<=2'b01;
	else 
			ForwardA<=2'b00;
end

always@(*) begin
	if((EX_MEM_RegWrite == 1) &&
		(ID_EX_ALUSrc == 0) &&
    	(EX_MEM_RegisterRd != 0) &&
    	(EX_MEM_RegisterRd == ID_EX_RegisterRt))
    		ForwardB<=2'b10;
    else if((MEM_WB_RegWrite == 1) &&
		(ID_EX_ALUSrc == 0) &&
    	(MEM_WB_RegisterRd != 0) &&
    	(MEM_WB_RegisterRd == ID_EX_RegisterRt))
    		ForwardB<=2'b01;
    else
    		ForwardB<=2'b00;

end
//bypass end


 //data DataHazardFlush link IF ID ???IF_ID need cache_stall???
always@(posedge clk or posedge rst)
begin
  if(rst == 1)
    begin
      IF_ID_PcAdd4 <= 0;
      IF_ID_Instruction <= 0;
    end
  else if(!cache_stall && ((branch & ID_Zero) || jump))
	begin
	  IF_ID_PcAdd4 <= 0;
      IF_ID_Instruction <= 0;
    end
  else
	begin
		if(cache_stall)
			begin
				IF_ID_PcAdd4 			<= IF_ID_PcAdd4			;			
				IF_ID_Instruction 		<= IF_ID_Instruction 	;		
			end
		else
			begin
				IF_ID_PcAdd4 <= pcAdd4;
			    IF_ID_Instruction <= instruction;
			end
	end     
end 

//DataHazardFlush link ID_EX;
always@(posedge clk or posedge rst)
begin
	if(rst == 1)
		begin
            ID_EX_RegReadData1<=0;
            ID_EX_RegReadData2<=0;
            ID_EX_Immediate_32<=0;
            ID_EX_RegisterRt<=0;
            ID_EX_RegisterRd<=0;
            ID_EX_RegisterRs<=0; 
			ID_EX_Funct<=0;
            ID_EX_RegDst<=0;
			ID_EX_ALUOp<=0;
            ID_EX_ALUSrc<=0;
            ID_EX_Branch<=0;
            ID_EX_MemRead<=0;
            ID_EX_MemWrite<=0;
            ID_EX_MemtoReg<=0;
            ID_EX_RegWrite<=0;
			ID_EX_PcAdd4<=0;
		end
	else
		begin
			if( cache_stall )
			begin
					ID_EX_RegReadData1	<= ID_EX_RegReadData1	;
                   ID_EX_RegReadData2	<= ID_EX_RegReadData2	;
                   ID_EX_Immediate_32	<= ID_EX_Immediate_32	;
                   ID_EX_RegisterRt		<= ID_EX_RegisterRt		;
                   ID_EX_RegisterRd		<= ID_EX_RegisterRd		;
                   ID_EX_RegisterRs		<= ID_EX_RegisterRs		;
                   ID_EX_Funct			<= ID_EX_Funct			;
                   ID_EX_RegDst			<= ID_EX_RegDst			;
                   ID_EX_ALUOp			<= ID_EX_ALUOp			;
                   ID_EX_ALUSrc			<= ID_EX_ALUSrc			;
                   ID_EX_Branch			<= ID_EX_Branch			;
                   ID_EX_MemRead		<= ID_EX_MemRead		;
                   ID_EX_MemWrite		<= ID_EX_MemWrite		;
                   ID_EX_MemtoReg		<= ID_EX_MemtoReg		;
                   ID_EX_RegWrite		<= ID_EX_RegWrite		;
                   ID_EX_PcAdd4			<= ID_EX_PcAdd4			;	
			end
			else
			begin
				if(DataHazardFlush | Br_StallA | Br_StallB)
					begin
							ID_EX_RegReadData1<=0;
				           ID_EX_RegReadData2<=0;
		                   ID_EX_Immediate_32<=0;
		                   ID_EX_RegisterRt<=0;
                           ID_EX_RegisterRd<=0;
                           ID_EX_RegisterRs<=0; 
                		   ID_EX_Funct<=0;
                           ID_EX_RegDst<=0;
                           ID_EX_ALUOp<=0;
                           ID_EX_ALUSrc<=0;
		                   ID_EX_Branch<=0;
                           ID_EX_MemRead<=0;
		                   ID_EX_MemWrite<=0;
                           ID_EX_MemtoReg<=0;
                           ID_EX_RegWrite<=0;
                		   ID_EX_PcAdd4<=0;
                	
                		   
                	end
		        else
		        	begin
		                ID_EX_RegReadData1<=regReadData1;
		                ID_EX_RegReadData2<=regReadData2;
		                ID_EX_Immediate_32<=immediate_32;
		                ID_EX_RegisterRt<=rt;
                        ID_EX_RegisterRd<=rd;
                        ID_EX_RegisterRs<=rs; 
                		ID_EX_Funct<=funct;
                        ID_EX_RegDst<=regDst;
                        ID_EX_ALUOp<=ALUOp;
                        ID_EX_ALUSrc<=ALUSrc;
		                ID_EX_Branch<=branch;
                        ID_EX_MemRead<=memRead;
		                ID_EX_MemWrite<=memWrite;
                        ID_EX_MemtoReg<=memtoReg;
                        ID_EX_RegWrite<=regWrite;
                		ID_EX_PcAdd4<=IF_ID_PcAdd4;
                	end
			end
		end
        
		
		
end

//DataHazardFlush EX_MEM          //EX_MEM need stall??
always@(posedge clk or posedge rst)
begin
	if(rst == 1)
		begin
			EX_MEM_ALURes     <= 0;
			EX_MEM_regRead    <= 0;
			EX_MEM_RegWriteReg<= 0;
			EX_MEM_zero		  <= 0;
			EX_MEM_addAluResult<=0;

			EX_MEM_Branch	  <= 0;
			EX_MEM_MemRead	  <= 0;
			EX_MEM_MemWrite	  <= 0;
			
			EX_MEM_MemtoReg   <= 0;
			EX_MEM_RegWrite   <= 0;
			
			EX_MEM_ALUOp	  <= 0;
		end
	else
		begin
			if( cache_stall )
				begin
					EX_MEM_ALURes     	<= EX_MEM_ALURes     	;
					EX_MEM_regRead  	<= EX_MEM_regRead		;
					EX_MEM_RegWriteReg	<= EX_MEM_RegWriteReg	;
					EX_MEM_zero		  	<= EX_MEM_zero		  	;
					EX_MEM_addAluResult	<= EX_MEM_addAluResult	;
																
					EX_MEM_Branch	  	<= EX_MEM_Branch	  	;
					EX_MEM_MemRead	  	<= EX_MEM_MemRead	  	;
					EX_MEM_MemWrite	  	<= EX_MEM_MemWrite	  	;
																
					EX_MEM_MemtoReg   	<= EX_MEM_MemtoReg   	;
					EX_MEM_RegWrite   	<= EX_MEM_RegWrite   	;
																
					EX_MEM_ALUOp	  	<= EX_MEM_ALUOp	  	    ;
				end
			else	
				begin
					EX_MEM_ALURes     <= aluRes;
					EX_MEM_regRead  <= ((EX_MEM_RegWrite == 1) && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRt))?(EX_MEM_MemRead?memReadData:EX_MEM_ALURes):ID_EX_RegReadData2;
					EX_MEM_RegWriteReg<= regWriteReg;
					EX_MEM_zero		  <= zero;
					EX_MEM_addAluResult<=branchAddress;
		
					EX_MEM_Branch	  <= ID_EX_Branch;
					EX_MEM_MemRead	  <= ID_EX_MemRead;
					EX_MEM_MemWrite	  <= ID_EX_MemWrite;
					
					EX_MEM_MemtoReg   <= ID_EX_MemtoReg;
					EX_MEM_RegWrite   <= ID_EX_RegWrite;
					
					EX_MEM_ALUOp	  <= ID_EX_ALUOp;
				end
		end
end

//DataHazardFlush MEM_WB
always@(posedge clk or posedge rst)
begin
	if(rst == 1)
		begin
			MEM_WB_MemReadData  <= 0;
			MEM_WB_ALURes <= 0;
			MEM_WB_RegWriteReg  <= 0;

			MEM_WB_MemtoReg     <= 0;
			MEM_WB_RegWrite     <= 0;
		end
	else
		begin
			MEM_WB_MemReadData  <= memReadData;
			MEM_WB_ALURes <= EX_MEM_ALURes;
			MEM_WB_RegWriteReg  <= EX_MEM_RegWriteReg;

			MEM_WB_MemtoReg     <= EX_MEM_MemtoReg;
			MEM_WB_RegWrite     <= EX_MEM_RegWrite;
		end
end

//pc logic
assign pcAdd4 = pc + 4;
assign jumpAddress = {IF_ID_PcAdd4[31:28], IF_ID_Instruction[25:0],2'b0};
assign branchAddress = IF_ID_PcAdd4 + (immediate_32<<2);
assign nextPc = jump?jumpAddress:((branch & ID_Zero)?branchAddress:pcAdd4);


always@(posedge clk or posedge rst)
begin
    if (rst == 1)
        pc <= 0;
	else if( (memRead && !instruction[31:26] && ((rt == instruction[25:21]) ||(rt == instruction[20:16]))) || //stall for datahazard
		(instruction[31:26]==6'b000100 && memRead == 1 && (instruction[20:16]==(regDst?rd:rt)||instruction[25:21]==(regDst?rd:rt))) ||
			cache_stall
		)//stall for branchhazard
															//(branch == 1 && ID_EX_MemRead == 1 && (rt == regWriteReg||rs == regWriteReg) ) one period ahead
		pc<=pc;
	else pc <= nextPc;
		
   // else if(!DataHazardFlush)
    //    pc <= muxPc2;
	//else
	//	pc <= pc;
end

//instruction
InstructionMem instructionMem(.address(pc),
                       .instruction(instruction));

//control logic
assign op = IF_ID_Instruction[31:26];
assign rs = IF_ID_Instruction[25:21];
assign rt = IF_ID_Instruction[20:16];
assign rd = IF_ID_Instruction[15:11];
assign funct = IF_ID_Instruction[5:0];
assign immediate_16 = IF_ID_Instruction[15:0];

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
assign regWriteReg = ID_EX_RegDst?ID_EX_RegisterRd:ID_EX_RegisterRt;
assign regWriteData = MEM_WB_MemtoReg?MEM_WB_MemReadData:MEM_WB_ALURes;
regFile regfile(.clock_in(clk),
    .rst(rst),
    .readReg1(regReadReg1),
    .readReg2(regReadReg2),
    .writeReg(MEM_WB_RegWriteReg),
    .writeData(regWriteData),
    .regWrite(MEM_WB_RegWrite),
    .readData1(regReadData1),
    .readData2(regReadData2));

//alu & aluctr logic
AluCtr aluctr(.aluOp(ID_EX_ALUOp),
    .funct(ID_EX_Funct),
    .aluCtr(aluCtr));

assign ALUInput1 = (ForwardA[1])?EX_MEM_ALURes:((ForwardA[0])?regWriteData:ID_EX_RegReadData1);

assign ALUInput2tmp = ID_EX_ALUSrc?ID_EX_Immediate_32:ID_EX_RegReadData2;
assign ALUInput2 = (ForwardB[1])?EX_MEM_ALURes:((ForwardB[0])?regWriteData:ALUInput2tmp);

Alu alu(.input1(ALUInput1),
    .input2(ALUInput2),
    .aluCtr(aluCtr),
    .zero(zero),
    .aluRes(aluRes));

//signext
signext ext(.inst(immediate_16),
    .data(immediate_32));



cache cache
(
    // System clock, reset and stall
	.clk_i(clk), 
	.rst_i(rst),
	
	
	// to CPU interface	
	.p1_data_i(EX_MEM_regRead), 
	.p1_addr_i(EX_MEM_ALURes), 	
	.p1_MemRead_i(EX_MEM_MemRead), 
	.p1_MemWrite_i(EX_MEM_MemWrite), 
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
