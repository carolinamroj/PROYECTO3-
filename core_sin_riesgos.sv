module core_sin_riesgos (clk, reset, idata, ddata_r, iaddr,daddr, ddata_w,  reg_write_en, d_w, d_r);


input logic clk, reset;
input logic [31:0] idata;
input logic [31:0] ddata_r;
output logic [31:0] iaddr;
output logic [31:0] daddr;
output logic [31:0] ddata_w;
output logic reg_write_en;
output logic d_w;
output logic d_r;

 
// -- Etapa IF --
logic [31:0] pc_next, pc_current;
logic [31:0] pc_plus_4;

// -- Etapa ID --
logic [31:0] id_pc, id_instr;
logic [31:0] read_data1, read_data2, imm_gen_out;
logic [31:0] branch_target; 
logic branch_taken;

// Control en ID
logic ctrl_Branch, ctrl_MemRead, ctrl_MemtoReg, ctrl_MemWrite, ctrl_ALUSrc, ctrl_RegWrite, ctrl_Jump, ctrl_Jalr;
logic [1:0] ctrl_ALUOp, ctrl_AuipcLui;

// -- Etapa EX --
logic [31:0] ex_pc, ex_imm, ex_read_data1, ex_read_data2;
logic [4:0]  ex_rd, ex_rs1, ex_rs2; 
logic [31:0] alu_in_a, alu_in_b, alu_result;
logic [4:0]  alu_ctrl;
logic        alu_zero;

// Control en EX
logic ex_MemRead, ex_MemtoReg, ex_MemWrite, ex_ALUSrc, ex_RegWrite;
logic [1:0] ex_ALUOp, ex_AuipcLui;
logic [2:0] ex_funct3;
logic [6:0] ex_funct7;

// -- Etapa MEM --
logic [31:0] mem_alu_result, mem_write_data;
logic [4:0]  mem_rd;
logic mem_RegWrite, mem_MemtoReg, mem_MemRead, mem_MemWrite;

// -- Etapa WB --
logic [31:0] wb_read_data, wb_alu_result;
logic [4:0]  wb_rd;
logic wb_RegWrite, wb_MemtoReg;
logic [31:0] wb_final_data; 


// hazards
logic stall; 
logic [1:0] forward1, forward2;
logic [31:0] alu_src1, alu_src2;


// Etapa IF
assign iaddr = pc_current;
assign pc_plus_4 = pc_current + 32'd4;


// Lógica del PC (Prioridad: Saltos > PC+4)
always_comb begin
  if (branch_taken)      
	pc_next = branch_target;           // Salto Condicional (BEQ...)
  else if (ctrl_Jump)    
	pc_next = id_pc + imm_gen_out;     // JAL
  else if (ctrl_Jalr)    
	pc_next = (read_data1 + imm_gen_out) & 32'hFFFFFFFE; // JALR
  else                   
	pc_next = pc_plus_4;
end

always_ff @(posedge clk or negedge reset) begin
  if (!reset) 
	pc_current <= 32'b0;
  else if (!stall)        
	pc_current <= pc_next;
end

// Registro IF / ID
always_ff @(posedge clk or negedge reset) begin
  if (!reset) 
  begin
		id_pc    <= 32'b0;
		id_instr <= 32'h00000013; // NOP
  end
  else if (!stall)
  begin
	  // FLUSH: Si hay salto, matamos la instrucción que viene detrás convirtiéndola en NOP
		if (branch_taken || ctrl_Jump || ctrl_Jalr) begin
			 id_pc    <= 32'b0;
			 id_instr <= 32'h00000013; // Inyectar NOP
		end 
		else 
		begin
			 id_pc    <= pc_current;
			 id_instr <= idata;
		end
  end
end

// Etapa ID (DECODE)
register register_inst (
  .CLK(clk),
  .RESET_N(reset),
  .RegWrite(wb_RegWrite),
  .ReadRegister1(id_instr[19:15]),
  .ReadRegister2(id_instr[24:20]),
  .WriteRegister(wb_rd),
  .WriteData(wb_final_data),
  .ReadData1(read_data1),
  .ReadData2(read_data2)
);

imm_gen imm_gen_inst (
  .instr(id_instr),
  .imm(imm_gen_out)
);

Control control_inst (
  .Instruction(id_instr[6:0]),
  .Branch(ctrl_Branch),
  .MemRead(ctrl_MemRead),
  .MemtoReg(ctrl_MemtoReg),
  .ALUOp(ctrl_ALUOp),
  .MemWrite(ctrl_MemWrite),
  .ALUSrc(ctrl_ALUSrc),
  .RegWrite(ctrl_RegWrite),
  .AuipcLui(ctrl_AuipcLui),
  .Jump(ctrl_Jump),
  .Jalr(ctrl_Jalr)
);

assign branch_target = id_pc + imm_gen_out;

always_comb begin
  branch_taken = 1'b0;
  if (ctrl_Branch) begin
		case (id_instr[14:12]) 
			 3'b000: branch_taken = (read_data1 == read_data2); // BEQ
			 3'b001: branch_taken = (read_data1 != read_data2); // BNE
			 3'b100: branch_taken = ($signed(read_data1) < $signed(read_data2)); // BLT
			 3'b101: branch_taken = ($signed(read_data1) >= $signed(read_data2)); // BGE
			 3'b110: branch_taken = (read_data1 < read_data2); // BLTU
			 3'b111: branch_taken = (read_data1 >= read_data2); // BGEU
			 default: branch_taken = 1'b0;
		endcase
  end
end


// hazard detection

assign stall = ex_MemRead && ((ex_rd == id_instr[19:15]) || (ex_rd == id_instr[24:20])) && (ex_rd !=0);
// Registro ID / EX
 

always_ff @(posedge clk or negedge reset) 
begin
  if (!reset) 
  begin
	ex_MemRead <= 0; ex_MemtoReg <= 0; ex_MemWrite <= 0;
	ex_ALUSrc <= 0; ex_RegWrite <= 0; ex_ALUOp <= 0; ex_AuipcLui <= 0;
	ex_pc <= 0; ex_imm <= 0; ex_read_data1 <= 0; ex_read_data2 <= 0; ex_rd <= 0;
	ex_funct3 <= 0; ex_funct7 <= 0;
  end 
  else if (stall)
  begin 
	ex_RegWrite <= 0;
	ex_MemWrite <= 0; 
	ex_MemRead <= 0; // Señales peligrosas a 0
	ex_MemtoReg <= 0;
  end 
  else 
  begin
	 ex_MemRead  <= ctrl_MemRead;
	 ex_MemtoReg <= ctrl_MemtoReg;
	 ex_MemWrite <= ctrl_MemWrite;
	 ex_ALUSrc   <= ctrl_ALUSrc;
	 ex_RegWrite <= ctrl_RegWrite;
	 ex_ALUOp    <= ctrl_ALUOp;
	 ex_AuipcLui <= ctrl_AuipcLui;
			 
	 ex_pc         <= id_pc;
	 ex_imm        <= imm_gen_out;
	 ex_read_data1 <= read_data1;
	 ex_read_data2 <= read_data2;
	 ex_rd         <= id_instr[11:7];
	 ex_rs1 			<= id_instr [19:15];
	 ex_rs2 			<= id_instr [24:20];
	 ex_funct3     <= id_instr[14:12];
	 ex_funct7     <= id_instr[31:25];
	end

end
	
// forwarding

always_comb 
begin
	forward1 = 2'b00;
	forward2 = 2'b00;
	
	if (mem_RegWrite && (mem_rd != 0) && (mem_rd == ex_rs1))
		forward1 = 2'b10;
	
	if (mem_RegWrite && (mem_rd != 0) && (mem_rd == ex_rs2))
		forward2 = 2'b10;
		
	if (wb_RegWrite && (wb_rd != 0) && !(mem_RegWrite && (mem_rd == ex_rs1)) && (wb_rd == ex_rs1))
		forward1 = 2'b01;
		
	if (wb_RegWrite && (wb_rd != 0) && !(mem_RegWrite && (mem_rd == ex_rs2)) && (wb_rd == ex_rs2))
		forward2 = 2'b01;
end
// Etapa EX 
ALU_control alu_control_inst (
  .alu_op(ex_ALUOp),
  .funct7(ex_funct7),
  .funct3(ex_funct3),
  .alu_control_out(alu_ctrl)
);

always_comb 
begin
	case (forward1)
		2'b00: alu_in_a = ex_read_data1;
		2'b10: alu_in_a = mem_alu_result;
		2'b01: alu_in_a = wb_final_data;
		default: alu_in_a = ex_read_data1;
	endcase
end

always_comb 
begin
	case (forward2)
		2'b00: alu_in_b = ex_ALUSrc ? ex_imm : ex_read_data2;
		2'b10: alu_in_b = mem_alu_result;
		2'b01: alu_in_b = wb_final_data;
		default: alu_in_b = ex_read_data2;
	endcase
end

alu alu_inst (
  .src_a(alu_in_a),
  .src_b(alu_in_b),
  .alu_control(alu_ctrl),
  .alu_result(alu_result),
  .zero(alu_zero)
);

// registro EX / MEM 
always_ff @(posedge clk or negedge reset) 
begin
  if (!reset) 
  begin
		mem_RegWrite <= 0; mem_MemtoReg <= 0; 
		mem_MemRead <= 0; mem_MemWrite <= 0;
		mem_alu_result <= 0; mem_write_data <= 0; 
		mem_rd <= 0;
  end 
  else 
  begin
		mem_RegWrite  <= ex_RegWrite;
		mem_MemtoReg  <= ex_MemtoReg;
		mem_MemRead   <= ex_MemRead;
		mem_MemWrite  <= ex_MemWrite;
		
		mem_alu_result <= alu_result;
		mem_write_data <= ex_read_data2;
		mem_rd         <= ex_rd;
  end
end

// Etapa MEM (MEMORY)
assign daddr   = mem_alu_result;
assign ddata_w = mem_write_data;
assign d_w     = mem_MemWrite;
assign d_r     = mem_MemRead;

// registro MEM / WB
always_ff @(posedge clk or negedge reset) 
begin
  if (!reset) 
  begin
		wb_RegWrite <= 0; 
		wb_MemtoReg <= 0;
		wb_read_data <= 0; 
		wb_alu_result <= 0; 
		wb_rd <= 0;
  end 
  else 
  begin
		wb_RegWrite  <= mem_RegWrite;
		wb_MemtoReg  <= mem_MemtoReg;
		
		wb_read_data <= ddata_r;
		wb_alu_result<= mem_alu_result;
		wb_rd        <= mem_rd;
  end
end

// Etapa WB
assign wb_final_data = (wb_MemtoReg) ? wb_read_data : wb_alu_result;
assign reg_write_en  = wb_RegWrite;

endmodule
 