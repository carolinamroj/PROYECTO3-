// Unidad de Control Principal - Decodifica instrucciones y genera señales de control
 
 module Control (
	input logic [6:0] Instruction,
	output logic Branch,
	output logic MemRead, 
	output logic MemtoReg,
	output logic [1:0] ALUOp,
	output logic MemWrite,
	output logic ALUSrc,
	output logic RegWrite,
	output logic AuipcLui
	);
	
 localparam [6:0] R_TYPE = 7'b0110011,
						I_TYPE = 7'b0010011,
						LOAD = 7'b0000011,
						STORE = 7'b0100011,
						BRANCH = 7'b1100011,
						LUI = 7'b0110111,
						AUIPC = 7'b0010111;
	
 always
	begin
		Branch = 1'b0;
		MemRead = 1'b0;
		MemtoReg = 1'b0;
		ALUOp = 2'b00;
		MemWrite = 1'b0;
		ALUSrc = 1'b0;
		RegWrite = 1'b0;
		AuipcLui = 1'b0;
	
		case (Instruction)
			R_TYPE:
				begin
					MemtoReg = 1'b0;
					ALUOp = 2'b10;
					ALUSrc = 1'b0;
					RegWrite = 1'b1;
				end
			
			I_TYPE:
				begin 
					MemtoReg = 1'b0;
					ALUOp = 2'b10;
					ALUSrc = 1'b1;
					RegWrite = 1'b1;
				end
			LOAD:
				begin
					RegWrite = 1'b1;
					ALUSrc = 1'b1;
					MemtoReg = 1'b1;
					MemRead = 1'b1;
					ALUOp = 2'b00;
				end
			
			STORE:
				begin
					ALUSrc = 1'b1;
					MemWrite = 1'b1;
					ALUOp = 2'b00;
				end

			BRANCH:
				begin
					Branch = 1'b1;
					ALUSrc = 1'b0;
					ALUOp = 2'b01;
				end				
					
			LUI:
				begin
					RegWrite = 1'b1;
					ALUSrc = 1'b1;
					AuipcLui = 1'b1;
					ALUOp = 2'b00;
				end 
				
			AUIPC:
				begin 
					RegWrite = 1'b1;
					ALUSrc = 1'b1
					AuipcLui = 1'b1;
					ALUOp = 2'b00;
				end
			
			default:
				begin
					{Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, AuipcLui} = 7'b0;
					ALUOp = 2'b00;
				end
		endcase
 end
 
 endmodule 
 
 
 