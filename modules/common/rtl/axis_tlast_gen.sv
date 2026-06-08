module axis_tlast_gen #(
    parameter int TLAST_VAL = 256
) (
    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    logic handshake;
    assign handshake = s_axis.tvalid & s_axis.tready;

    logic cnt_last;

    cnt #(
        .MAX_VAL(TLAST_VAL)
    ) i_cnt (
        .clk_i     (s_axis.clk_i),
        .rst_i     (~s_axis.arstn_i),
        .en_i      (handshake),
        .cnt_last_o(cnt_last),
        .cnt_o     ()
    );

    assign m_axis.tdata  = s_axis.tdata;
    assign m_axis.tvalid = s_axis.tvalid;
    assign m_axis.tlast  = cnt_last;
    assign m_axis.tid    = s_axis.tid;
    assign m_axis.tdest  = s_axis.tdest;
    assign m_axis.tstrb  = s_axis.tstrb;
    assign m_axis.tuser  = s_axis.tuser;
    assign m_axis.tkeep  = s_axis.tkeep;

    assign s_axis.tready = m_axis.tready;

endmodule
