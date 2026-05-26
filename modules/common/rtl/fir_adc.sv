module fir_adc #(
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

    input logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] adc_tdata_i,
    input logic                                   adc_tvalid_i,

    axis_if.master adc_axis
);

    logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] dec_tdata;
    logic [CH_NUM-1:0]                      dec_tvalid;

    for (genvar ch_indx = 0; ch_indx < CH_NUM; ch_indx++) begin : g_ch
        fir_decimator i_fir_decimator (
            .aresetn           (arstn_i),
            .aclk              (clk_i),
            .s_axis_data_tvalid(adc_tvalid_i),
            .s_axis_data_tready(),
            .s_axis_data_tdata (adc_tdata_i[ch_indx]),
            .m_axis_data_tvalid(dec_tvalid[ch_indx]),
            .m_axis_data_tdata (dec_tdata[ch_indx])
        );
    end

    axis_if #(
        .DATA_WIDTH(CH_NUM * DATA_WIDTH * 2)
    ) fir_axis (
        .clk_i  (clk_i),
        .arstn_i(arstn_i)
    );

    always_comb begin
        if (fir_en_i) begin
            fir_axis.tdata  = dec_tdata;
            fir_axis.tvalid = |dec_tvalid;
        end else begin
            fir_axis.tdata  = adc_tdata_i;
            fir_axis.tvalid = adc_tvalid_i;
        end
    end

    localparam logic [31:0] S_AXIS_SIGNAL_SET = 32'h03;
    localparam USE_ADV_FEATURES = "1000";

    axis_data_fifo_wrap #(
        .AXIS_SIGNAL_SET   (S_AXIS_SIGNAL_SET),
        .FIFO_DEPTH        (FIFO_DEPTH),
        .FIFO_MEM_TYPE     (FIFO_MEM_TYPE),
        .FAMILY            (FAMILY),
        .ASYNC_MODE_EN     (ASYNC_MODE_EN),
        .SYNCHRONIZER_STAGE(SYNC_STAGE_NUM),
        .USE_ADV_FEATURES  (USE_ADV_FEATURES)
    ) i_adc_fifo (
        .s_en_i(1'b1),
        .m_en_i(1'b1),
        .s_axis(fir_axis),
        .m_axis(adc_axis)
    );

endmodule
