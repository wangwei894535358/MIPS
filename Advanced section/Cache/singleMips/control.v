//control blk
//convert instruction's opcode to control signal
//yi

module control(
			input wire [5:0] opCode,
			output reg regDst,
			output reg jump,
			output reg branch,
			output reg memRead,
			output reg memtoReg,
			output reg [1:0] ALUOp,
			output reg memWrite,
			output reg ALUSrc,
			output reg regWrite
			);

//regDst
always @(opCode)
begin
	case(opCode)
		6'b000000: //R format:add,sub,and,or,slt
			regDst<=1;

		6'b100011: //lw
			regDst<=0;

		6'b101011://sw
			regDst<=0;

		6'b000100://beq
			regDst<=0;

		6'b000010://j
			regDst<=0;

		6'b001000: //addi    ....!!!
			regDst<=0;
		
		6'b001100: //andi
			regDst<=0;

		default:
			regDst<=0;

	endcase
end

//ALUSrc
always @(opCode)
begin
	case(opCode)
		6'b000000: //R format:add,sub,and,or,slt
			ALUSrc<=0;

		6'b100011: //lw
			ALUSrc<=1;

		6'b101011://sw
			ALUSrc<=1;

		6'b000100://beq
			ALUSrc<=0;

		6'b000010://j
			ALUSrc<=0;

		6'b001000: //addi
		  ALUSrc<=1;
		  
		6'b001100: //andi
		  ALUSrc<=1;

		default:
			ALUSrc<=0;

	endcase
end

//memtoReg
always @(opCode)
begin
	case(opCode)
		6'b000000: //R format:add,sub,and,or,slt
			memtoReg<=0;

		6'b100011: //lw
			memtoReg<=1;

		6'b101011://sw
			memtoReg<=0;

		6'b000100://beq
			memtoReg<=0;

		6'b000010://j
			memtoReg<=0;

		6'b001000: //addi
			memtoReg<=0;
			
		6'b001100: //andi
			memtoReg<=0;

		default:
			memtoReg<=0;

	endcase
end

//regWrite
always @(opCode)
begin
	case(opCode)
		6'b000000: //R format:add,sub,and,or,slt
			regWrite<=1;

		6'b100011: //lw
			regWrite<=1;

		6'b101011://sw
			regWrite<=0;

		6'b000100://beq
			regWrite<=0;

		6'b000010://j
			regWrite<=0;
			
		6'b001000: //addi
			regWrite<=1;
			
		6'b001100: //andi
			regWrite<=1;

		default:
			regWrite<=0;

	endcase
end

//memRead
always @(opCode)
begin
	case(opCode)
		6'b000000: //R format:add,sub,and,or,slt
			memRead<=0;

		6'b100011: //lw
			memRead<=1;

		6'b101011://sw
			memRead<=0;

		6'b000100://beq
			memRead<=0;

		6'b000010://j
			memRead<=0;

		6'b001000: //addi
			memRead<=0;
				
		6'b001100: //andi
			memRead<=0;
				
		default:
			memRead<=0;

	endcase
end

//memWrite
always @(opCode)
begin
	case(opCode)
		6'b000000: //R format:add,sub,and,or,slt
			memWrite<=0;

		6'b100011: //lw
			memWrite<=0;

		6'b101011://sw
			memWrite<=1;

		6'b000100://beq
			memWrite<=0;

		6'b000010://j
			memWrite<=0;

		6'b001000: //addi
			memWrite<=0;
			
		6'b001100: //andi
			memWrite<=0;
			
		default:
			memWrite<=0;

	endcase
end

//branch
always @(opCode)
begin
	case(opCode)
		6'b000000: //R format:add,sub,and,or,slt
			branch<=0;

		6'b100011: //lw
			branch<=0;

		6'b101011://sw
			branch<=0;

		6'b000100://beq
			branch<=1;

		6'b000010://j
			branch<=0;
			
		6'b001000: //addi
			branch<=0;
			
		6'b001100: //andi
			branch<=0;
		default:
			branch<=0;

	endcase
end

//ALUOp
always @(opCode)
begin
	case(opCode)
		6'b000000: //R format:add,sub,and,or,slt
			ALUOp<=2'b10;

		6'b100011: //lw
			ALUOp<=2'b00;

		6'b101011://sw
			ALUOp<=2'b00;

		6'b000100://beq
			ALUOp<=2'b01;

		6'b000010://j
			ALUOp<=2'b00;
			
		6'b001000: //addi
			ALUOp<=2'b00;
			
		6'b001100: //andi
			ALUOp<=2'b11;
			
		default:
			ALUOp<=2'b00;

	endcase
end

//jump
always @(opCode)
begin
	case(opCode)
		6'b000000: //R format:add,sub,and,or,slt
			jump<=0;

		6'b100011: //lw
			jump<=0;

		6'b101011://sw
			jump<=0;

		6'b000100://beq
			jump<=0;

		6'b000010://j
			jump<=1;
			
		6'b001000: //addi
			jump<=0;
			
		6'b001100: //andi
			jump<=0;

		default:
			jump<=0;

	endcase
end

endmodule
