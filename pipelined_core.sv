
 module pipelined_core (
	input  logic        clk,
	input  logic        reset,
	input  logic [31:0] idata,
	input  logic [31:0] ddata_r,
	output logic [31:0] iaddr,
	output logic [31:0] daddr,
	output logic [31:0] ddata_w,
	output logic        reg_write_en,
	output logic        d_w,
	output logic        d_r
	);
	
	logic [31:0] out_pc, pc_next, sum1, sum2;
	logic Branch, MemRead, MemtoReg, MemWrite, RegWrite, ALUSrc, Jump, Jalr;
	logic [1:0] ALUOp, AuipcLui;
	logic [2:0] funct3;
	
	logic [31:0] IF_ID_pc, IF_ID_instruction;
	
	logic [31:0] ID_out_gen, ID_ReadData1, ID_ReadData2, WB_out_mux4, pc_jalr, ID_EX_out_gen, ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_pc;
	logic [6:0] ID_EX_funct7;
	logic [4:0] WB_WriteRegister, ID_EX_rd, ID_EX_rs1, ID_EX_rs2;
	logic [2:0] ID_EX_funct3;
	logic [1:0] ID_EX_ALUOp, ID_EX_AuipcLui;
	logic WB_RegWrite, branch_taken, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite;
	
	logic [31:0] EX_out_mux2, EX_out_mux3, EX_alu_result, EX_MEM_alu_result, EX_MEM_ReadData2;
	logic [4:0] EX_alu_control, EX_MEM_rd;
	logic EX_zero, EX_MEM_MemRead, EX_MEM_MemtoReg, EX_MEM_MemWrite, EX_MEM_RegWrite;
	
	logic [31:0] MEM_WB_alu_result, MEM_WB_ddata_r;
	logic [4:0] MEM_WB_rd;
	logic MEM_WB_MemtoReg, MEM_WB_RegWrite;
	 
		// Etapa IF
	always_ff @(posedge clk or negedge reset)
		begin
			if(!reset) out_pc <= 32'b0;
			else out_pc <= pc_next;
		end
		
	assign iaddr = out_pc 
	assign sum1 = out_pc + 32'd4;
	
	always_ff @(posedge clk or negedge reset)
		begin
			if (!reset)
				begin
					IF_ID_pc <= 32'b0;
					IF_ID_instruction <= 32'b0;
				end
			else
				begin
					IF_ID_pc <= out_pc;
					IF_ID_instruction <= idata;
				end
		end
		
		// Etapa ID
	assign funct3 = IF_ID_instruction[14:12];
	
	Control control_inst (
	.Instruction(idata[6:0]),
	.Branch(Branch),
	.MemRead(MemRead),
	.MemtoReg(MemtoReg),
	.ALUOp(ALUOp),
	.MemWrite(MemWrite),
	.ALUSrc(ALUSrc),
	.RegWrite(RegWrite),
	.AuipcLui(AuipcLui),
	.Jump(Jump),
	.Jalr(Jalr)
	);
	
	imm_gen imm_gen_inst (
	.instr(IF_ID_instruction),
	.imm(ID_out_gen)
	);
	
	register register_inst (
	.CLK(clk),
	.RESET_N(reset),
	.RegWrite(WB_RegWrite),
	.ReadRegister1(IF_ID_instruction[19:15]),
	.ReadRegister2(IF_ID_instruction[24:20]),
	.WriteRegister(WB_WriteRegister),
	.WriteData(WB_out_mux4),
	.ReadData1(ID_ReadData1),
	.ReadData2(ID_ReadData2)
	);
	
	assign sum2 = IF_ID_pc + ID_out_gen;
	assign pc_jalr = (ID_ReadData1 + ID_out_gen) & 32'hFFFFFFFE;
	
	always_comb
		begin
			branch_taken = 1'b0;
			if (Branch)
				begin
					case (funct3)
						3'b000: branch_taken = (ID_ReadData1 == ID_ReadData2); // BEQ
						3'b001: branch_taken = (ID_ReadData1 != ID_ReadData2); // BNE
						3'b100: branch_taken = ($signed(ID_ReadData1) < $signed(ID_ReadData2)); // BLT
						3'b101: branch_taken = ($signed(ID_ReadData1) >= $signed(ID_ReadData2)); // BGE
						3'b110: branch_taken = (ID_ReadData1 < ID_ReadData2); // BLTU
						3'b111: branch_taken = (ID_ReadData1 >= ID_ReadData2); // BGEU
						default: branch_taken = 1'b0;
					endcase
				end
		end
	
	always_comb 
		begin
			case({Jalr, Jump, branch_taken})
				3'b100, 3'b101, 3'b110, 3'b111: pc_next = pc_jalr;  // Jalr tiene prioridad
				3'b010, 3'b011:                 pc_next = sum2;     // Jump
				3'b001:                         pc_next = sum2;     // Branch
				default:                        pc_next = sum1;     // PC+4
			endcase
		end
		
	always_ff @posedge clk or negedge reset)
		begin
			if (!reset)
				begin
					ID_EX_out_gen    <= 32'b0;
					ID_EX_ReadData1  <= 32'b0;
					ID_EX_ReadData2  <= 32'b0;
					ID_EX_pc         <= 32'b0;
					ID_EX_rd         <= 5'b0;
					ID_EX_rs1        <= 5'b0;
					ID_EX_rs2        <= 5'b0;
					ID_EX_funct3     <= 3'b0;
					ID_EX_funct7     <= 7'b0;
					
					ID_EX_MemRead    <= 1'b0;
					ID_EX_MemtoReg   <= 1'b0;
					ID_EX_MemWrite   <= 1'b0;
					ID_EX_ALUSrc     <= 1'b0;
					ID_EX_RegWrite   <= 1'b0;
					ID_EX_ALUOp      <= 2'b0;
					ID_EX_AuipcLui   <= 2'b0;
				end
			else
				begin
					ID_EX_out_gen    <= ID_out_gen;
					ID_EX_ReadData1  <= ID_ReadData1;
					ID_EX_ReadData2  <= ID_ReadData2;
					ID_EX_pc         <= IF_ID_pc;
					ID_EX_rd         <= IF_ID_instruction[11:7];
					ID_EX_rs1        <= IF_ID_instruction[19:15];
					ID_EX_rs2        <= IF_ID_instruction[24:20];
					ID_EX_funct3     <= funct3;
					ID_EX_funct7     <= IF_ID_instruction[31:25];
					
					ID_EX_MemRead    <= MemRead;
					ID_EX_MemtoReg   <= MemtoReg;
					ID_EX_MemWrite   <= MemWrite;
					ID_EX_ALUSrc     <= ALUSrc;
					ID_EX_RegWrite   <= RegWrite;
					ID_EX_ALUOp      <= ALUOp;
					ID_EX_AuipcLui   <= AuipcLui;
				end
		end
		
		// Etapa EX
	always_comb 
		begin
			if (ID_EX_AuipcLui == 2'b01) EX_out_mux2 = 32'b0; // LUI
			else if (ID_EX_AuipcLui == 2'b10) EX_out_mux2 = ID_EX_pc; // AUIPC
			else EX_out_mux2 = ID_EX_ReadData1; // Normal
		end
		
	assign EX_out_mux3 = ID_EX_ALUSrc ? ID_EX_out_gen : ID_EX_ReadData2;
	
	ALU_control alu_control_inst (
	.alu_op(ID_EX_ALUOp),
	.funct7(ID_EX_funct7),
	.funct3(ID_EX_funct3),
	.alu_control_out(EX_alu_control)
	);
	
	alu alu_inst (
	.src_a(EX_out_mux2),
	.src_b(EX_out_mux3),
	.alu_control(EX_alu_control),
	.alu_result(EX_alu_result),
	.zero(EX_zero)
	);
	
	always_ff @(posedge clk or negedge reset) 
		begin
			if (!reset) 
				begin
					EX_MEM_alu_result <= 32'b0;
					EX_MEM_ReadData2  <= 32'b0;
					EX_MEM_rd         <= 5'b0;
            
					EX_MEM_MemRead    <= 1'b0;
					EX_MEM_MemtoReg   <= 1'b0;
					EX_MEM_MemWrite   <= 1'b0;
					EX_MEM_RegWrite   <= 1'b0;
				end 
			else 
				begin
					EX_MEM_alu_result <= EX_alu_result;
					EX_MEM_ReadData2  <= ID_EX_ReadData2;
					EX_MEM_rd         <= ID_EX_rd;
            
					EX_MEM_MemRead    <= ID_EX_MemRead;
					EX_MEM_MemtoReg   <= ID_EX_MemtoReg;
					EX_MEM_MemWrite   <= ID_EX_MemWrite;
					EX_MEM_RegWrite   <= ID_EX_RegWrite;
				end
		end
		
		// Etapa MEM
	assign daddr   = EX_MEM_alu_result;
	assign ddata_w = EX_MEM_ReadData2;
	assign d_w     = EX_MEM_MemWrite;
	assign d_r     = EX_MEM_MemRead;
	
	always_ff @(posedge clk or negedge reset) 
		begin
			if (!reset) 
				begin	
					MEM_WB_alu_result <= 32'b0;
					MEM_WB_ddata_r    <= 32'b0;
					MEM_WB_rd         <= 5'b0;
					MEM_WB_MemtoReg   <= 1'b0;
					MEM_WB_RegWrite   <= 1'b0;
				end 
			else 
				begin
					MEM_WB_alu_result <= EX_MEM_alu_result;
					MEM_WB_ddata_r    <= ddata_r;
					MEM_WB_rd         <= EX_MEM_rd;
					MEM_WB_MemtoReg   <= EX_MEM_MemtoReg;
					MEM_WB_RegWrite   <= EX_MEM_RegWrite;
				end
		end
		
	assign WB_out_mux4 = MEM_WB_MemtoReg ? MEM_WB_ddata_r : MEM_WB_alu_result;
	assign WB_RegWrite = MEM_WB_RegWrite;
	assign WB_WriteRegister = MEM_WB_rd
	assign reg_write_en = WB_RegWrite;
	
 endmodule 
 
 
 
 
