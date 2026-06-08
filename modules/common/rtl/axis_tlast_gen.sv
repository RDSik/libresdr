module axis_tlast_gen #(
    parameter int TLAST_VAL = 256
) (
    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    logic handshake;
    assign handshake = m_axis.tvalid & m_axis.tready;

    logic cnt_last;

    cnt #(
        .MAX_VAL(TLAST_VAL)
    ) i_cnt (
        .clk_i     (m_axis.clk_i),
        .rst_i     (~m_axis.arstn_i),
        .en_i      (handshake),
        .cnt_last_o(cnt_last),
        .cnt_o     ()
    );

    assign s_axis.tdata  = m_axis.tdata;
    assign s_axis.tvalid = m_axis.tvalid;
    assign s_axis.tlast  = cnt_last;
    assign s_axis.tid    = m_axis.tid;
    assign s_axis.tdest  = m_axis.tdest;
    assign s_axis.tstrb  = m_axis.tstrb;
    assign s_axis.tuser  = m_axis.tuser;
    assign s_axis.tkeep  = m_axis.tkeep;

    assign m_axis.tready = s_axis.tready;

endmodule
