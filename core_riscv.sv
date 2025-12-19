module core_riscv (
	input logic clk, reset,
	input logic [31:0] idata, ddata_r,
	output logic [31:0] iaddr, daddr, ddata_w,
	output logic reg_write_en, d_w, d_r
);
	
	// Señales internas
	logic [31:0] out_pc, out_gen, sum1, sum2, out_mux1, out_mux2, ReadData1, ReadData2, out_mux3, alu_result, out_mux4;
	logic [4:0] alu_control;
	logic zero;
	logic [1:0] ALUOp_bus;
	logic Branch, MemRead, MemtoReg, MemWrite, RegWrite, ALUSrc, Jump, Jalr;
	logic [1:0] AuipcLui;
	logic [2:0] funct3;
	
	assign funct3 = idata[14:12];
	assign iaddr = out_pc;
	assign daddr = alu_result;
	assign ddata_w = ReadData2;
	assign d_w = MemWrite;
	assign d_r = MemRead;
	assign reg_write_en = RegWrite;
	
	// PC
	always_ff @(posedge clk or negedge reset) begin
		if (!reset) out_pc <= 32'b0;
		else out_pc <= out_mux1;
	end
	
	// Sumadores
	assign sum1 = out_pc + 32'd4;
	assign sum2 = out_pc + out_gen;
	
	// Lógica de branch EXTENDIDA
	logic branch_taken;
	logic [31:0] pc_jalr;
	
	// JALR: PC = rs1 + imm (bit 0 = 0)
	assign pc_jalr = (ReadData1 + out_gen) & 32'hFFFFFFFE;
	
	always_comb 
		begin
			branch_taken = 1'b0;
			if (Branch)
				begin
					case (funct3)
						3'b000: branch_taken = zero; // BEQ
						3'b001: branch_taken = ~zero; // BNE
						3'b100: branch_taken = ($signed(ReadData1) < $signed(ReadData2)); // BLT
						3'b101: branch_taken = ($signed(ReadData1) >= $signed(ReadData2)); // BGE
						3'b110: branch_taken = (ReadData1 < ReadData2); // BLTU
						3'b111: branch_taken = (ReadData1 >= ReadData2); // BGEU
						default: 
							branch_taken = 1'b0;
					endcase
				end
		end
	
	// Mux PC (prioridad: Jalr > Jump > Branch > PC+4)
	always_comb 
		begin
			case ({Jalr, Jump, branch_taken})
				3'b100, 3'b101, 3'b110, 3'b111: out_mux1 = pc_jalr; // Jalr tiene prioridad
				3'b010, 3'b011: out_mux1 = sum2; // Jump
				3'b001: out_mux1 = sum2; // Branch
				default: 
					out_mux1 = sum1; // PC+4
			endcase
		end
	
	// Muxes de datos
	always_comb 
		begin
			if (AuipcLui == 2'b01) out_mux2 = 32'b0; // LUI
			else if (AuipcLui == 2'b10) out_mux2 = out_pc; // AUIPC
			else out_mux2 = ReadData1; // Normal
		end

	assign out_mux3 = (ALUSrc) ? out_gen : ReadData2;
	assign out_mux4 = (MemtoReg) ? ddata_r : alu_result;
	
	register register_inst (
	.CLK(clk),
	.RESET_N(reset),
	.RegWrite(RegWrite),
	.ReadRegister1(idata[19:15]),
	.ReadRegister2(idata[24:20]),
	.WriteRegister(idata[11:7]),
	.WriteData(out_mux4),
	.ReadData1(ReadData1),
	.ReadData2(ReadData2)
	);
	
	alu alu_inst (
	.src_a(out_mux2),
	.src_b(out_mux3),
	.alu_control(alu_control),
	.alu_result(alu_result),
	.zero(zero)
	);
	
	imm_gen imm_gen_inst (
	.instr(idata),
	.imm(out_gen)
	);
	
	ALU_control alu_control_inst (
	.alu_op(ALUOp_bus),
	.funct7(idata[31:25]),
	.funct3(funct3),
	.alu_control_out(alu_control)
	);
	
	Control control_inst (
	.Instruction(idata[6:0]),
	.Branch(Branch),
	.MemRead(MemRead),
	.MemtoReg(MemtoReg),
	.ALUOp(ALUOp_bus),
	.MemWrite(MemWrite),
	.ALUSrc(ALUSrc),
	.RegWrite(RegWrite),
	.AuipcLui(AuipcLui),
	.Jump(Jump),
	.Jalr(Jalr)
	);
	
 endmodule 
 

