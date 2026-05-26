module fir_dac #(
    parameter int   CH_NUM         = 2,
    parameter int   DATA_WIDTH     = 16,
    parameter logic ASYNC_MODE_EN  = 0,
    parameter int   SYNC_STAGE_NUM = 3,
    parameter int   FIFO_DEPTH     = 4096,
    parameter       FIFO_MEM_TYPE  = "block",
    parameter       FAMILY         = "zynq"
) (
    input logic clk_i,
    input logic arstn_i,

    input logic fir_en_i,

    input  logic                                   dac_tready_i,
    output logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] dac_tdata_o,

    axis_if.slave dac_axis
);

    localparam logic [31:0] S_AXIS_SIGNAL_SET = 32'h03;
    localparam USE_ADV_FEATURES = "1000";

    axis_if #(
        .DATA_WIDTH(CH_NUM * DATA_WIDTH * 2)
    ) fir_axis (
        .clk_i  (clk_i),
        .arstn_i(arstn_i)
    );

    axis_data_fifo_wrap #(
        .AXIS_SIGNAL_SET   (S_AXIS_SIGNAL_SET),
        .FIFO_DEPTH        (FIFO_DEPTH),
        .FIFO_MEM_TYPE     (FIFO_MEM_TYPE),
        .FAMILY            (FAMILY),
        .ASYNC_MODE_EN     (ASYNC_MODE_EN),
        .SYNCHRONIZER_STAGE(SYNC_STAGE_NUM),
        .USE_ADV_FEATURES  (USE_ADV_FEATURES)
    ) i_dac_fifo (
        .s_en_i(1'b1),
        .m_en_i(1'b1),
        .s_axis(dac_axis),
        .m_axis(fir_axis)
    );

    logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] dac_tdata;
    logic                                   dac_tvalid;
    logic [CH_NUM-1:0]                      dac_tready;

    assign dac_tdata       = fir_axis.tdata;
    assign dac_tvalid      = fir_axis.tvalid;
    assign fir_axis.tready = (fir_en_i) ? |dac_tready : dac_tready_i;

    logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] int_tdata;
    logic [CH_NUM-1:0]                      int_tvalid;

    for (genvar ch_indx = 0; ch_indx < CH_NUM; ch_indx++) begin : g_ch
        fir_interpolator i_fir_interpolator (
            .aresetn           (arstn_i),
            .aclk              (clk_i),
            .s_axis_data_tvalid(dac_tvalid),
            .s_axis_data_tready(dac_tready[ch_indx]),
            .s_axis_data_tdata (dac_tdata[ch_indx]),
            .m_axis_data_tvalid(int_tvalid[ch_indx]),
            .m_axis_data_tready(dac_tready_i),
            .m_axis_data_tdata (int_tdata[ch_indx])
        );
    end

    always_comb begin
        if (fir_en_i) begin
            dac_tdata_o = int_tdata;
        end else begin
            dac_tdata_o = dac_tdata;
        end
    end

endmodule
