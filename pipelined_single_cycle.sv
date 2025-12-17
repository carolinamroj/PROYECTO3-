

module pipelined_single_cycle (
    input logic CLK,
    input logic RESET_N
);
    logic [31:0] iaddr, idata, daddr, ddata_w, ddata_r;
    logic d_w, d_r, reg_write_debug;
    parameter ficheroram = "basura.txt";
    parameter ficherorom = "basura2.txt";

    pipelined_core core (
        .CLK          (CLK),
        .RESET_N      (RESET_N),
        .idata        (idata),
        .ddata_r      (ddata_r),
        .iaddr        (iaddr),
        .daddr        (daddr),
        .ddata_w      (ddata_w),
        .d_w          (d_w),
        .d_r          (d_r),
        .reg_write_en (reg_write_debug)
    );

    ROM #(.fichero2(ficherorom)) imem (
        .ADDR (iaddr[11:2]),
        .DOUT (idata)
    );

    RAM #(.fichero(ficheroram)) dmem (
        .CLOCK   (CLK),
        .wren    (d_w),
        .addr    (daddr[11:2]),
        .data_in (ddata_w),
        .data_out(ddata_r)
    );
endmodule 


