
 module pipelined_core (
    input  logic        CLK,
    input  logic        RESET_N,
    input  logic [31:0] idata,      // Instrucción desde IMEM
    input  logic [31:0] ddata_r,    // Dato leído desde DMEM
    output logic [31:0] iaddr,      // Dirección IMEM
    output logic [31:0] daddr,      // Dirección DMEM
    output logic [31:0] ddata_w,    // Dato a escribir en DMEM
    output logic        d_w,        // Señal de escritura DMEM
    output logic        d_r,        // Señal de lectura DMEM
    output logic        reg_write_en// Señal de escritura en banco de regs (para debug)
);

    // ETAPA IF 
    logic [31:0] pc_next, pc_curr;
    logic [31:0] pc_plus_4;

    assign pc_plus_4 = pc_curr + 32'd4;
    assign pc_next   = pc_plus_4;  // Por ahora, sin saltos ni branches

    always_ff @(posedge CLK or negedge RESET_N) begin
        if (!RESET_N) pc_curr <= 32'h00000000;
        else          pc_curr <= pc_next;
    end

    assign iaddr = pc_curr;

    // REGISTRO IF/ID 
    logic [31:0] if_id_instr;
    logic [31:0] if_id_pc_plus_4;

    always_ff @(posedge CLK or negedge RESET_N) begin
        if (!RESET_N) begin
            if_id_instr    <= 32'b0;
            if_id_pc_plus_4 <= 32'b0;
        end else begin
            if_id_instr    <= idata;
            if_id_pc_plus_4 <= pc_plus_4;
        end
    end

    // ETAPA ID 
    logic [31:0] id_rs1_data, id_rs2_data;
    logic [31:0] id_imm;
    logic        id_branch, id_memread, id_memtoreg, id_memwrite, id_alusrc, id_regwrite, id_jump, id_jalr;
    logic [1:0]  id_aluop, id_auipclui;
    logic [4:0]  id_aluctrl;


    Control control_unit (
        .Instruction(if_id_instr[6:0]),
        .Branch     (id_branch),
        .MemRead    (id_memread),
        .MemtoReg   (id_memtoreg),
        .ALUOp      (id_aluop),
        .MemWrite   (id_memwrite),
        .ALUSrc     (id_alusrc),
        .RegWrite   (id_regwrite),
        .AuipcLui   (id_auipclui),
        .Jump       (id_jump),
        .Jalr       (id_jalr)
    );

 
    imm_gen imm_gen_unit (
        .instr(if_id_instr),
        .imm  (id_imm)
    );


    ALU_control alu_ctrl_unit (
        .alu_op            (id_aluop),
        .funct7            (if_id_instr[31:25]),
        .funct3            (if_id_instr[14:12]),
        .alu_control_out   (id_aluctrl)
    );


    register reg_file (
        .CLK           (CLK),
        .RESET_N       (RESET_N),
        .RegWrite      (wb_regwrite),  // Escritura desde WB
        .ReadRegister1 (if_id_instr[19:15]),
        .ReadRegister2 (if_id_instr[24:20]),
        .WriteRegister (wb_rd_addr),
        .WriteData     (wb_write_data),
        .ReadData1     (id_rs1_data),
        .ReadData2     (id_rs2_data)
    );

    // REGISTRO ID/EX
    logic [31:0] id_ex_pc_plus_4, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    logic [4:0]  id_ex_rd_addr, id_ex_rs1_addr, id_ex_rs2_addr;
    logic        id_ex_memread, id_ex_memtoreg, id_ex_memwrite, id_ex_alusrc, id_ex_regwrite;
    logic [1:0]  id_ex_auipclui;
    logic [4:0]  id_ex_aluctrl;

    always_ff @(posedge CLK or negedge RESET_N) begin
        if (!RESET_N) begin
            {id_ex_pc_plus_4, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm} <= '0;
            {id_ex_rd_addr, id_ex_rs1_addr, id_ex_rs2_addr} <= '0;
            {id_ex_memread, id_ex_memtoreg, id_ex_memwrite, id_ex_alusrc, id_ex_regwrite} <= '0;
            id_ex_auipclui <= '0;
            id_ex_aluctrl  <= '0;
        end else begin
            id_ex_pc_plus_4 <= if_id_pc_plus_4;
            id_ex_rs1_data  <= id_rs1_data;
            id_ex_rs2_data  <= id_rs2_data;
            id_ex_imm       <= id_imm;
            id_ex_rd_addr   <= if_id_instr[11:7];
            id_ex_rs1_addr  <= if_id_instr[19:15];
            id_ex_rs2_addr  <= if_id_instr[24:20];
            id_ex_memread   <= id_memread;
            id_ex_memtoreg  <= id_memtoreg;
            id_ex_memwrite  <= id_memwrite;
            id_ex_alusrc    <= id_alusrc;
            id_ex_regwrite  <= id_regwrite;
            id_ex_auipclui  <= id_auipclui;
            id_ex_aluctrl   <= id_aluctrl;
        end
    end

    // ETAPA EX
    logic [31:0] ex_alu_a, ex_alu_b, ex_alu_result;
    logic        ex_zero;

    // Mux para ALU a
    assign ex_alu_a = (id_ex_auipclui == 2'b01) ? 32'b0 :            // LUI
                      (id_ex_auipclui == 2'b10) ? id_ex_pc_plus_4 : // AUIPC
                      id_ex_rs1_data;                               // Normal

    // Mux para ALU b
    assign ex_alu_b = id_ex_alusrc ? id_ex_imm : id_ex_rs2_data;

    alu alu_unit (
        .src_a       (ex_alu_a),
        .src_b       (ex_alu_b),
        .alu_control (id_ex_aluctrl),
        .alu_result  (ex_alu_result),
        .zero        (ex_zero)
    );

    // REGISTRO EX/MEM
    logic [31:0] ex_mem_alu_result, ex_mem_rs2_data;
    logic [4:0]  ex_mem_rd_addr;
    logic        ex_mem_memread, ex_mem_memtoreg, ex_mem_memwrite, ex_mem_regwrite;

    always_ff @(posedge CLK or negedge RESET_N) begin
        if (!RESET_N) begin
            {ex_mem_alu_result, ex_mem_rs2_data} <= '0;
            ex_mem_rd_addr   <= '0;
            {ex_mem_memread, ex_mem_memtoreg, ex_mem_memwrite, ex_mem_regwrite} <= '0;
        end else begin
            ex_mem_alu_result <= ex_alu_result;
            ex_mem_rs2_data   <= id_ex_rs2_data;
            ex_mem_rd_addr    <= id_ex_rd_addr;
            ex_mem_memread    <= id_ex_memread;
            ex_mem_memtoreg   <= id_ex_memtoreg;
            ex_mem_memwrite   <= id_ex_memwrite;
            ex_mem_regwrite   <= id_ex_regwrite;
        end
    end

    // ETAPA MEM
    assign daddr   = ex_mem_alu_result;
    assign ddata_w = ex_mem_rs2_data;
    assign d_w     = ex_mem_memwrite;
    assign d_r     = ex_mem_memread;

    // REGISTRO MEM/WB
    logic [31:0] mem_wb_alu_result, mem_wb_ddata_r;
    logic [4:0]  mem_wb_rd_addr;
    logic        mem_wb_memtoreg, mem_wb_regwrite;

    always_ff @(posedge CLK or negedge RESET_N) begin
        if (!RESET_N) begin
            {mem_wb_alu_result, mem_wb_ddata_r} <= '0;
            mem_wb_rd_addr   <= '0;
            {mem_wb_memtoreg, mem_wb_regwrite} <= '0;
        end else begin
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_ddata_r    <= ddata_r;
            mem_wb_rd_addr    <= ex_mem_rd_addr;
            mem_wb_memtoreg   <= ex_mem_memtoreg;
            mem_wb_regwrite   <= ex_mem_regwrite;
        end
    end

    // ETAPA WB 
    logic [31:0] wb_write_data;
    logic        wb_regwrite;
    logic [4:0]  wb_rd_addr;

    assign wb_write_data = mem_wb_memtoreg ? mem_wb_ddata_r : mem_wb_alu_result;
    assign wb_regwrite   = mem_wb_regwrite;
    assign wb_rd_addr    = mem_wb_rd_addr;

    assign reg_write_en = wb_regwrite; // Para debug

endmodule 



