module axis_subset_converter_wrap #(
    parameter logic [31:0] S_AXIS_SIGNAL_SET = 32'h03,
    parameter logic [31:0] M_AXIS_SIGNAL_SET = 32'h03,
    parameter int          DEFAULT_TLAST     = 256,
    parameter              FAMILY            = "zynq"
) (
    input logic en_i,

    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    axis_subset_converter #(
        .C_FAMILY            (FAMILY),
        .C_S_AXIS_TDATA_WIDTH(s_axis.DATA_WIDTH),
        .C_S_AXIS_TID_WIDTH  (s_axis.ID_WIDTH),
        .C_S_AXIS_TDEST_WIDTH(s_axis.DEST_WIDTH),
        .C_S_AXIS_TUSER_WIDTH(s_axis.USER_WIDTH),
        .C_S_AXIS_SIGNAL_SET (S_AXIS_SIGNAL_SET),
        .C_M_AXIS_TDATA_WIDTH(m_axis.DATA_WIDTH),
        .C_M_AXIS_TID_WIDTH  (m_axis.ID_WIDTH),
        .C_M_AXIS_TDEST_WIDTH(m_axis.DEST_WIDTH),
        .C_M_AXIS_TUSER_WIDTH(m_axis.USER_WIDTH),
        .C_M_AXIS_SIGNAL_SET (M_AXIS_SIGNAL_SET),
        .C_DEFAULT_TLAST     (DEFAULT_TLAST)
    ) i_axis_subset_converter (
        .aclk         (s_axis.clk_i),
        .aresetn      (s_axis.arstn_i),
        .aclken       (en_i),
        .s_axis_tvalid(s_axis.tvalid),
        .s_axis_tready(s_axis.tready),
        .s_axis_tdata (s_axis.tdata),
        .s_axis_tstrb (s_axis.tstrb),
        .s_axis_tkeep (s_axis.tkeep),
        .s_axis_tlast (s_axis.tlast),
        .s_axis_tid   (s_axis.tid),
        .s_axis_tdest (s_axis.tdest),
        .s_axis_tuser (s_axis.tuser),
        .m_axis_tvalid(m_axis.tvalid),
        .m_axis_tready(m_axis.tready),
        .m_axis_tdata (m_axis.tdata),
        .m_axis_tstrb (m_axis.tstrb),
        .m_axis_tkeep (m_axis.tkeep),
        .m_axis_tlast (m_axis.tlast),
        .m_axis_tid   (m_axis.tid),
        .m_axis_tdest (m_axis.tdest),
        .m_axis_tuser (m_axis.tuser)
    );

endmodule
