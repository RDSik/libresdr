`include "../../../../../modules/signal_gen/rtl/signal_gen_pkg.svh"

module signal_gen
    import signal_gen_pkg::*;
#(
    parameter logic ILA_EN          = 0,
    parameter logic ASYNC_MODE_EN   = 0,
    parameter int   SYNC_STAGE_NUM  = 3,
    parameter int   CH_NUM          = 2,
    parameter int   DATA_WIDTH      = 16,
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter int   FIFO_DEPTH      = 4096,
    parameter       FIFO_MEM_TYPE   = "block",
    parameter       FAMILY          = "zynq"
) (
    input logic clk_i,
    input logic arstn_i,

    axil_if.slave s_axil,

    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    localparam int FULL_DATA_WIDTH = CH_NUM * DATA_WIDTH * 2;

    signal_gen_regs_t                                  rd_regs;
    signal_gen_regs_t                                  wr_regs;

    logic                     [SIGNAL_GEN_REG_NUM-1:0] rd_request;
    logic                     [SIGNAL_GEN_REG_NUM-1:0] rd_valid;
    logic                     [SIGNAL_GEN_REG_NUM-1:0] wr_valid;

    signal_gen_settings_reg_t [            CH_NUM-1:0] settings;
    logic                     [            CH_NUM-1:0] dds_reset;
    logic                     [            CH_NUM-1:0] dds_enable;
    logic                     [    $clog2(CH_NUM)-1:0] select;

    assign dds_reset  = wr_regs.control.dds_reset;
    assign dds_enable = wr_regs.control.dds_enable;
    assign select     = wr_regs.dds.select;

    logic one_dds_en;
    logic all_dds_rst;

    always_ff @(posedge clk_i) begin
        one_dds_en  <= |dds_enable;
        all_dds_rst <= &dds_reset;
    end

    axis_if #(
        .DATA_WIDTH(FULL_DATA_WIDTH)
    ) dds_axis (
        .clk_i  (clk_i),
        .arstn_i(~all_dds_rst)
    );

    always_ff @(posedge clk_i) begin
        if (~arstn_i) begin
            settings <= '0;
        end else begin
            if (wr_valid[SIGNAL_GEN_PINC_REG_POS]) begin
                settings[select].pinc <= wr_regs.dds.settings.pinc;
            end

            if (wr_valid[SIGNAL_GEN_POFF_REG_POS]) begin
                settings[select].poff <= wr_regs.dds.settings.poff;
            end

            if (wr_valid[SIGNAL_GEN_AMPL_REG_POS]) begin
                settings[select].ampl       <= wr_regs.dds.settings.ampl;
                settings[select].round_type <= wr_regs.dds.settings.round_type;
            end
        end
    end

    logic [$clog2(FIFO_DEPTH):0] data_cnt;
    logic [          CH_NUM-1:0] ampl_ovf;

    assign rd_valid = '1;

    always_ff @(posedge clk_i) begin
        rd_regs                         <= wr_regs;

        rd_regs.param.ch_num            <= CH_NUM;
        rd_regs.param.fifo_depth        <= FIFO_DEPTH;
        rd_regs.param.reg_num           <= SIGNAL_GEN_REG_NUM;

        rd_regs.status.fifo_empty       <= ~m_axis.tvalid;
        rd_regs.status.fifo_full        <= ~dds_axis.tready;
        rd_regs.status.fifo_cnt         <= data_cnt;
        rd_regs.status.ampl_ovf         <= ampl_ovf;

        rd_regs.dds.settings.poff       <= settings[select].poff;
        rd_regs.dds.settings.pinc       <= settings[select].pinc;
        rd_regs.dds.settings.ampl       <= settings[select].ampl;
        rd_regs.dds.settings.round_type <= settings[select].round_type;
    end

    axil_reg_file_wrap #(
        .REG_DATA_WIDTH(AXIL_DATA_WIDTH),
        .REG_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .REG_NUM       (SIGNAL_GEN_REG_NUM),
        .reg_t         (signal_gen_regs_t),
        .REG_INIT      (SIGNAL_GEN_REG_INIT),
        .ASYNC_MODE_EN (ASYNC_MODE_EN),
        .ILA_EN        (ILA_EN)
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

    logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] ampl_tdata;
    logic [CH_NUM-1:0]                      ampl_tvalid;

    for (genvar ch_indx = 0; ch_indx < CH_NUM; ch_indx++) begin : g_ch
        logic [1:0][DATA_WIDTH-1:0] dds_tdata;
        logic                       dds_tvalid;

        dds #(
            .PHASE_WIDTH(DDS_PHASE_WIDTH),
            .DATA_WIDTH (DATA_WIDTH)
        ) i_dds (
            .clk_i   (clk_i),
            .rst_i   (dds_reset[ch_indx]),
            .en_i    (dds_enable[ch_indx]),
            .pinc_i  (settings[ch_indx].pinc),
            .poff_i  (settings[ch_indx].poff),
            .tdata_o (dds_tdata),
            .tvalid_o(dds_tvalid)
        );

        amplitude #(
            .CH_NUM    (2),
            .DATA_WIDTH(DATA_WIDTH)
        ) i_amplitude (
            .clk_i       (clk_i),
            .rst_i       (dds_reset[ch_indx]),
            .round_type_i(settings[ch_indx].round_type),
            .ampl_i      (settings[ch_indx].ampl),
            .tdata_i     (dds_tdata),
            .tvalid_i    (dds_tvalid),
            .tdata_o     (ampl_tdata[ch_indx]),
            .tvalid_o    (ampl_tvalid[ch_indx]),
            .ovf_o       (ampl_ovf[ch_indx])
        );
    end

    always_comb begin
        if (one_dds_en) begin
            dds_axis.tdata  = ampl_tdata;
            dds_axis.tvalid = |ampl_tvalid;
            s_axis.tready   = 1'b0;
        end else begin
            dds_axis.tdata  = s_axis.tdata;
            dds_axis.tvalid = s_axis.tvalid;
            s_axis.tready   = dds_axis.tready;
        end
    end

    localparam logic [31:0] AXIS_SIGNAL_SET = 32'h03;

    axis_data_fifo_wrap #(
        .AXIS_SIGNAL_SET (AXIS_SIGNAL_SET),
        .FIFO_DEPTH      (FIFO_DEPTH),
        .FIFO_MEM_TYPE   (FIFO_MEM_TYPE),
        .FAMILY          (FAMILY),
        .USE_ADV_FEATURES("1004")
    ) i_dds_fifo (
        .s_en_i            (one_dds_en),
        .m_en_i            (one_dds_en),
        .s_axis            (dds_axis),
        .m_axis            (m_axis),
        .axis_rd_data_count(),
        .axis_wr_data_count(data_cnt)
    );

endmodule
