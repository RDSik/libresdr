`include "../rtl/signal_gen_pkg.svh"

module signal_gen
    import signal_gen_pkg::*;
#(
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   DATA_WIDTH      = 64,
    parameter int   FIFO_DEPTH      = 4096,
    parameter logic ILA_EN          = 0
) (
    axil_if.slave s_axil,

    axis_if.master m_axis
);

    logic                                      clk_i;
    asiign                                     clk_i = s_axil.clk_i;

    signal_gen_regs_t                          rd_regs;
    signal_gen_regs_t                          wr_regs;

    logic             [SIGNAL_GEN_REG_NUM-1:0] rd_request;
    logic             [SIGNAL_GEN_REG_NUM-1:0] rd_valid;
    logic             [SIGNAL_GEN_REG_NUM-1:0] wr_valid;

    logic                                      reset;
    logic                                      enable;

    assign reset  = wr_regs.control.reset;
    assign enable = wr_regs.control.enable;

    localparam int DDS_DATA_WIDTH = 32;

    axis_if #(
        .DATA_WIDTH(DDS_DATA_WIDTH)
    ) dds_axis (
        .clk_i(clk_i),
        .rst_i(reset)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) fifo_axis (
        .clk_i(clk_i),
        .rst_i(reset)
    );

    logic [$clog2(FIFO_DEPTH):0] data_cnt;
    logic                        dds_tready;

    always_comb begin
        rd_valid                  = '1;
        rd_regs                   = wr_regs;

        rd_regs.param.data_width  = DATA_WIDTH;
        rd_regs.param.fifo_depth  = FIFO_DEPTH;
        rd_regs.param.reg_num     = SIGNAL_GEN_REG_NUM;

        rd_regs.status.fifo_empty = ~m_axis.tvalid;
        rd_regs.status.fifo_full  = ~fifo_axis.tready;
        rd_regs.status.dds_ready  = dds_tready;
        rd_regs.status.data_cnt   = data_cnt;
    end

    axil_reg_file #(
        .REG_DATA_WIDTH(AXIL_DATA_WIDTH),
        .REG_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .REG_NUM       (SIGNAL_GEN_REG_NUM),
        .reg_t         (signal_gen_regs_t),
        .REG_INIT      (SIGNAL_GEN_REG_INIT),
        .ILA_EN        (ILA_EN)
    ) i_axil_reg_file (
        .s_axil      (s_axil),
        .rd_regs_i   (rd_regs),
        .rd_valid_i  (rd_valid),
        .rd_request_o(rd_request),
        .wr_regs_o   (wr_regs),
        .wr_valid_o  (wr_valid)
    );

    localparam logic TLAST_EN = 0;

    dds #(
        .PHASE_WIDTH(DDS_PHASE_WIDTH)
    ) i_dds (
        .clk_i       (s_axil.clk_i),
        .rst_i       (reset),
        .en_i        (enable),
        .pinc_i      (wr_regs.settings.pinc),
        .poff_i      (wr_regs.settings.poff),
        .dds_tready_o(dds_tready),
        .m_axis      (dds_axis)
    );

    axis_dw_conv #(
        .DATA_WIDTH_OUT(DATA_WIDTH),
        .DATA_WIDTH_IN (DDS_DATA_WIDTH),
        .TLAST_EN      (TLAST_EN)
    ) i_axis_dw_conv (
        .s_axis(dds_axis),
        .m_axis(fifo_axis)
    );

    axis_fifo #(
        .FIFO_WIDTH  (DATA_WIDTH),
        .FIFO_DEPTH  (FIFO_DEPTH),
        .TLAST_EN    (TLAST_EN),
        .READ_LATENCY(1),
        .RAM_STYLE   ("block"),
    ) i_axis_fifo (
        .s_axis    (fifo_axis),
        .m_axis    (m_axis),
        .a_full_o  (),
        .a_empty_o (),
        .data_cnt_o(data_cnt)
    );

endmodule
