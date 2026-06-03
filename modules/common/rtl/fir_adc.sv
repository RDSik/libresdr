module fir_adc #(
    parameter int CH_NUM     = 2,
    parameter int DATA_WIDTH = 16
) (
    input logic clk_i,
    input logic arstn_i,

    input logic fir_en_i,

    input logic                                   adc_tvalid_i,
    input logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] adc_tdata_i,

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

    always_comb begin
        if (fir_en_i) begin
            adc_axis.tdata  = dec_tdata;
            adc_axis.tvalid = |dec_tvalid;
        end else begin
            adc_axis.tdata  = adc_tdata_i;
            adc_axis.tvalid = adc_tvalid_i;
        end
    end

endmodule
