module fir_adc_dac #(
    parameter int CH_NUM     = 2,
    parameter int DATA_WIDTH = 16
) (
    input logic clk_i,
    input logic arstn_i,

    input logic fir_en_i,

    input logic [CH_NUM-1:0][1:0]                 adc_tvalid_i,
    input logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] adc_tdata_i,

    input  logic [CH_NUM-1:0][1:0]                 dac_tready_i,
    output logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] dac_tdata_o,

    axis_if.slave  dac_axis,
    axis_if.master adc_axis
);

    localparam int FULL_DATA_WIDH = CH_NUM * DATA_WIDTH * 2;

    logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] dec_tdata;
    logic [CH_NUM-1:0]                      dec_tvalid;

    logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] int_tdata;
    logic [CH_NUM-1:0]                      int_tvalid;

    logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] dac_tdata;
    assign dac_tdata = dac_axis.tdata;

    logic pulse;

    util_pulse_gen #(
        .PULSE_WIDTH (7),
        .PULSE_PERIOD(1)
    ) i_util_pulse_gen (
        .clk          (clk_i),
        .rstn         (arstn_i),
        .pulse_width  ('0),
        .pulse_period ('0),
        .load_config  ('0),
        .pulse_counter(),
        .pulse        (pulse),
    );

    for (genvar ch_indx = 0; ch_indx < CH_NUM; ch_indx++) begin : g_ch
        fir_decimator i_fir_decimator (
            .aresetn           (arstn_i),
            .aclk              (clk_i),
            .s_axis_data_tvalid(|adc_tvalid_i[ch_indx]),
            .s_axis_data_tready(),
            .s_axis_data_tdata (adc_tdata_i[ch_indx]),
            .m_axis_data_tvalid(dec_tvalid[ch_indx]),
            .m_axis_data_tdata (dec_tdata[ch_indx])
        );

        logic [DATA_WIDTH*2-1:0] s_axis_data_tdata;
        logic                    s_axis_tvalid;

        assign s_axis_data_tdata = dac_tdata[ch_indx];
        assign s_axis_tvalid     = |dac_tready_i[ch_indx] & pulse;

        fir_interpolator i_fir_interpolator (
            .aresetn           (arstn_i),
            .aclk              (clk_i),
            .s_axis_data_tvalid(s_axis_tvalid),
            .s_axis_data_tready(),
            .s_axis_data_tdata (s_axis_data_tdata),
            .m_axis_data_tvalid(int_tvalid[ch_indx]),
            .m_axis_data_tdata (int_tdata[ch_indx])
        );
    end

    logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] adc_tdata;
    logic                                   adc_tvalid;

    ad_bus_mux #(
        .DATA_WIDTH(FULL_DATA_WIDH)
    ) i_adc_mux (
        .select_path(fir_en_i),
        .valid_in_0 (|adc_tvalid_i),
        .enable_in_0(),
        .data_in_0  (adc_tdata_i),
        .valid_in_1 (|dec_tvalid),
        .enable_in_1(),
        .data_in_1  (dec_tdata),
        .valid_out  (adc_tvalid),
        .enable_out (),
        .data_out   (adc_tdata)
    );

    assign adc_axis.tdata  = adc_tdata;
    assign adc_axis.tvalid = adc_tvalid;

    ad_bus_mux #(
        .DATA_WIDTH(FULL_DATA_WIDH)
    ) i_dac_mux (
        .select_path(fir_en_i),
        .valid_in_0 (dac_axis.tvalid),
        .enable_in_0(),
        .data_in_0  (dac_axis.tdata),
        .valid_in_1 (|int_tvalid),
        .enable_in_1(),
        .data_in_1  (int_tdata),
        .valid_out  (),
        .enable_out (),
        .data_out   (dac_tdata_o)
    );

endmodule
