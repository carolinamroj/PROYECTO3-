module core_riscv (clk, reset, idata, ddata_r, iaddr, daddr, ddata_w, reg_data_in, reg_write_en, d_w, d_r);
input clk, reset;
input [31:0] idata, ddata_r;
output [31:0] iaddr, daddr, ddata_w, reg_data_in;
output reg_write_en, d_w, d_r;


logic [4:0] alu_control;
logic zero;
//SUMADOR 1
logic [31:0] out_pc; // out program counter
//SUMADOR2
logic [31:0] out_gen;
logic [31:0] sum1;
logic [31:0] sum2;
//MULTI1
logic [31:0] out_and;
logic [31:0] out_mux1;
//MULTI2
logic [31:0] out_mux2;
logic [31:0] ReadData1;
//MULT3
logic [31:0] ReadData2;
logic ALUSrc;
logic [31:0] out_mux3;

//MULTI4
logic MemtoReg;
logic [31:0] alu_result;
logic [31:0] data_out; //salida RAM ¿donde lo conecto?
logic [31:0] out_mux4;

//
logic ALUOp;
logic Branch;
logic MemRead;
logic MemWrite;
logic RegWrite;
logic AuipcLui;


//PC
always_ff @(posedge clk or negedge reset)
begin
	if (!reset)
		out_pc <= 0;
	else
		out_pc <= out_mux1;
end

	
// SUMADORES

always_ff @(posedge clk or negedge reset)

begin
	if (!reset)
	begin
		sum1 <= 0;
		sum2 <=0;
	end
	
	else
	begin
		sum1 <= out_pc + 3'b100;
		sum2 <= out_pc + out_gen;
	end
end


//AND
assign out_and = Branch & zero;
//MULTIPLEXOR1

always_comb //(out_and, sum1, sum2)

begin
	if(out_and) //activo
		out_mux1 = sum2;
	else
		out_mux1 = sum1;
end

//MULTIPLEXOR2, 3a1

always_comb //AuipcLui, out_pc, read_data1)
begin
	case(AuipcLui)
		2'b00: out_mux2 = out_pc;
		2'b01: out_mux2 = 32'd0;
		2'b10: out_mux2 = ReadData1;
		default: out_mux2 = 32'd0;
	endcase
end

//MULTI3

always_comb //(ALUSrc, ReadData2, out_gen)	

begin
	if (ALUSrc)
		out_mux3 = out_gen;
	else 
		out_mux3 = ReadData2;
end

//MULTI4

always_comb //(MemtoReg, data_out, alu_result)
begin
	if (MemtoReg)
		out_mux4 = alu_result;
	else
		out_mux4 = data_out;
end




//INSTANCIOA REGISTRO

register register_inst(
	.CLK(clk),
	.RESET_N(reset),
	.RegWrite(RegWrite),
	.ReadRegister1(iaddr [19:15]),
	.ReadRegister2(iaddr [24:20]),
	.WriteRegister(iaddr [11:7]),
	.WriteData(out_mux4),
	.ReadData1(ReadData1),
	.ReadData2(ReadData2)
);

alu alu_inst(
	.src_a(out_mux2),
	.src_b(out_mux3),
	.alu_control(alu_control),
	.alu_result(alu_result),
	.zero(zero)
);


//INSTANCIA GEN

imm_gen imm_gen_inst(
	.instr(iaddr),
	. imm(out_gen)
);


//INSTANCIA ALU CONTROL

ALU_control alu_control_inst(
	.alu_op(ALUOp),
	.funct7(iaddr [31:25]),
	.funct3(iaddr [14:12]),
	.alu_control_out(alu_control)
);

Control control_inst(
	.Instruction(iaddr [6:0]),
	.Branch(Branch),
	.MemRead(MemRead),
	.MemtoReg(MemtoReg),
	.ALUOp(ALUOp),
	.MemWrite(MemWrite),
	.ALUSrc(ALUSrc),
	.RegWrite(RegWrite),
	.AuipcLui(AuipcLui)
);

endmodule
