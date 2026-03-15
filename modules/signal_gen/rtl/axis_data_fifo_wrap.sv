module axis_data_fifo_wrap #(
    parameter logic [31:0] AXIS_SIGNAL_SET    = 32'h03,
    parameter int          ASYNC_MODE_EN      = 0,
    parameter int          SYNCHRONIZER_STAGE = 3,
    parameter int          ECC_MODE_EN        = 0,
    parameter int          FIFO_DEPTH         = 128,
    parameter int          FIFO_MODE          = 1,
    parameter int          PROG_EMPTY_THRESH  = 5,
    parameter int          PROG_FULL_THRESH   = 11,
    parameter int          ACLKEN_CONV_MODE   = 0,
    parameter              USE_ADV_FEATURES   = "1000",
    parameter              FIFO_MEM_TYPE      = "block",
    parameter              FAMILY             = ""
) (
    input logic s_en_i,
    input logic m_en_i,

    axis_if.slave  s_axis,
    axis_if.master m_axis,

    output logic almost_full,
    output logic almost_empty,

    output logic prog_full,
    output logic prog_empty,

    output logic [31:0] axis_wr_data_count,
    output logic [31:0] axis_rd_data_count

);

    axis_data_fifo #(
        .C_FAMILY            (FAMILY),
        .C_AXIS_TDATA_WIDTH  (s_axis.DATA_WIDTH),
        .C_AXIS_TID_WIDTH    (s_axis.ID_WIDTH),
        .C_AXIS_TDEST_WIDTH  (s_axis.DEST_WIDTH),
        .C_AXIS_TUSER_WIDTH  (s_axis.USER_WIDTH),
        .C_AXIS_SIGNAL_SET   (AXIS_SIGNAL_SET),
        .C_FIFO_DEPTH        (FIFO_DEPTH),
        .C_FIFO_MODE         (FIFO_MODE),
        .C_IS_ACLK_ASYNC     (ASYNC_MODE_EN),
        .C_SYNCHRONIZER_STAGE(SYNCHRONIZER_STAGE),
        .C_ACLKEN_CONV_MODE  (ACLKEN_CONV_MODE),
        .C_PROG_EMPTY_THRESH (PROG_EMPTY_THRESH),
        .C_PROG_FULL_THRESH  (PROG_FULL_THRESH),
        .C_ECC_MODE          (ECC_MODE_EN),
        .C_FIFO_MEMORY_TYPE  (FIFO_MEM_TYPE),
        .C_USE_ADV_FEATURES  (USE_ADV_FEATURES)
    ) i_axis_data_fifo (
        .s_axis_aclk       (s_axis.clk_i),
        .s_axis_aresetn    (s_axis.arstn_i),
        .s_axis_aclken     (s_en_i),
        .s_axis_tvalid     (s_axis.tvalid),
        .s_axis_tready     (s_axis.tready),
        .s_axis_tdata      (s_axis.tdata),
        .s_axis_tstrb      (s_axis.tstrb),
        .s_axis_tkeep      (s_axis.tkeep),
        .s_axis_tlast      (s_axis.tlast),
        .s_axis_tid        (s_axis.tid),
        .s_axis_tdest      (s_axis.tdest),
        .s_axis_tuser      (s_axis.tuser),
        .almost_full       (almost_full),
        .prog_full         (prog_full),
        .almost_empty      (almost_empty),
        .prog_empty        (prog_empty),
        .axis_wr_data_count(axis_wr_data_count),
        .axis_rd_data_count(axis_rd_data_count),
        .injectsbiterr     ('0),
        .injectdbiterr     ('0),
        .m_axis_aclk       (m_axis.clk_i),
        .m_axis_aclken     (m_en_i),
        .m_axis_tvalid     (m_axis.tvalid),
        .m_axis_tready     (m_axis.tready),
        .m_axis_tdata      (m_axis.tdata),
        .m_axis_tstrb      (m_axis.tstrb),
        .m_axis_tkeep      (m_axis.tkeep),
        .m_axis_tlast      (m_axis.tlast),
        .m_axis_tid        (m_axis.tid),
        .m_axis_tdest      (m_axis.tdest),
        .m_axis_tuser      (m_axis.tuser),
        .sbiterr           (),
        .dbiterr           ()
    );

endmodule
