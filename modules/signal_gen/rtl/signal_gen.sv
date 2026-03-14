`include "../rtl/signal_gen_pkg.svh"

module signal_gen
    import signal_gen_pkg::*;
#(
    parameter int   CH_NUM          = 2,
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   DATA_WIDTH      = 64,
    parameter int   FIFO_DEPTH      = 4096,
    parameter logic ILA_EN          = 0,
    parameter       MODE            = "sync"
) (

    input logic clk_i,
    input logic arstn_i,

    axil_if.slave s_axil,

    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    signal_gen_regs_t                                  rd_regs;
    signal_gen_regs_t                                  wr_regs;

    logic                     [SIGNAL_GEN_REG_NUM-1:0] rd_request;
    logic                     [SIGNAL_GEN_REG_NUM-1:0] rd_valid;
    logic                     [SIGNAL_GEN_REG_NUM-1:0] wr_valid;

    signal_gen_settings_reg_t [            CH_NUM-1:0] dds;
    logic                                              resetn;
    logic                                              enable;
    logic                                              bypass_en;
    logic                                              select;

    assign resetn    = ~wr_regs.control.reset;
    assign enable    = wr_regs.control.enable;
    assign bypass_en = wr_regs.control.bypass_en;
    assign select    = wr_regs.dds.select;

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) s_fifo_axis (
        .clk_i  (clk_i),
        .arstn_i(resetn)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) m_fifo_axis (
        .clk_i  (clk_i),
        .arstn_i(resetn)
    );

    always_ff @(posedge clk_i) begin
        if (~arstn_i) begin
            dds <= '0;
        end else begin
            if (wr_valid[SIGNAL_GEN_PINC_REG_POS]) begin
                dds[select].pinc <= wr_regs.dds.settings.pinc;
            end

            if (wr_valid[SIGNAL_GEN_POFF_REG_POS]) begin
                dds[select].poff <= wr_regs.dds.settings.poff;
            end
        end
    end

    logic [$clog2(FIFO_DEPTH):0] data_cnt;
    logic [          CH_NUM-1:0] dds_tready;

    always_comb begin
        rd_valid                  = '1;
        rd_regs                   = wr_regs;

        rd_regs.param.ch_num      = CH_NUM;
        rd_regs.param.fifo_depth  = FIFO_DEPTH;
        rd_regs.param.reg_num     = SIGNAL_GEN_REG_NUM;

        rd_regs.status.fifo_empty = ~m_fifo_axis.tvalid;
        rd_regs.status.fifo_full  = ~s_fifo_axis.tready;
        rd_regs.status.dds_ready  = |dds_tready;
        rd_regs.status.data_cnt   = data_cnt;
    end

    axil_reg_file_wrap #(
        .REG_DATA_WIDTH(AXIL_DATA_WIDTH),
        .REG_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .REG_NUM       (SIGNAL_GEN_REG_NUM),
        .reg_t         (signal_gen_regs_t),
        .REG_INIT      (SIGNAL_GEN_REG_INIT),
        .ILA_EN        (ILA_EN),
        .MODE          (MODE)
    ) i_axil_reg_file (
        .clk_i       (clk_i),
        .arstn_i     (arstn_i),
        .s_axil      (s_axil),
        .rd_regs_i   (rd_regs),
        .rd_valid_i  (rd_valid),
        .rd_request_o(rd_request),
        .wr_regs_o   (wr_regs),
        .wr_valid_o  (wr_valid)
    );

    localparam int IQ_DATA_WIDTH = 16;

    logic [CH_NUM-1:0][1:0][IQ_DATA_WIDTH-1:0] dds_tdata;
    logic [CH_NUM-1:0]                         dds_tvalid;

    for (genvar ch_indx = 0; ch_indx < CH_NUM; ch_indx++) begin : g_ch
        axis_if #(
            .DATA_WIDTH(IQ_DATA_WIDTH * 2)
        ) dds_axis (
            .clk_i  (clk_i),
            .arstn_i(resetn)
        );

        dds #(
            .PHASE_WIDTH(DDS_PHASE_WIDTH)
        ) i_dds (
            .clk_i       (clk_i),
            .rstn_i      (resetn),
            .en_i        (enable),
            .pinc_i      (dds[ch_indx].pinc),
            .poff_i      (dds[ch_indx].poff),
            .dds_tready_o(dds_tready[ch_indx]),
            .m_axis      (dds_axis)
        );

        assign dds_tdata[ch_indx]  = dds_axis.tdata;
        assign dds_tvalid[ch_indx] = dds_axis.tvalid;
        assign dds_axis.tready     = s_fifo_axis.tready;
    end

    assign s_fifo_axis.tdata  = dds_tdata;
    assign s_fifo_axis.tvalid = |dds_tvalid;

    localparam logic [31:0] AXIS_SIGNAL_SET = 32'h03;

    axis_data_fifo_wrap #(
        .AXIS_SIGNAL_SET (AXIS_SIGNAL_SET),
        .FIFO_DEPTH      (FIFO_DEPTH),
        .FIFO_MEM_TYPE   ("block"),
        .FAMILY          ("virtex7"),
        .USE_ADV_FEATURES("1004")
    ) i_axis_fifo (
        .en_i              (enable),
        .s_axis            (s_fifo_axis),
        .m_axis            (m_fifo_axis),
        .axis_rd_data_count(),
        .axis_wr_data_count(data_cnt)
    );

    logic load_reg;
    assign load_reg = m_axis.tready | ~m_axis.tvalid;

    always_ff @(posedge clk_i) begin
        if (~resetn) begin
            m_axis.tdata  <= '0;
            m_axis.tvalid <= '0;
        end else begin
            if (bypass_en) begin
                m_axis.tdata  <= s_axis.tdata;
                m_axis.tvalid <= s_axis.tvalid;
            end else begin
                if (load_reg) begin
                    m_axis.tdata  <= m_fifo_axis.tdata;
                    m_axis.tvalid <= m_fifo_axis.tvalid;
                end
            end
        end
    end

    assign s_axis.tready      = bypass_en & resetn;
    assign m_fifo_axis.tready = bypass_en ? 1'b0 : load_reg;

endmodule
