module axi_ad9361_top #(
    parameter logic ILA_EN         = 1,
    parameter logic PPS_EN         = 1,
    parameter logic CLK10M_EN      = 1,
    parameter int   CH_NUM         = 2,
    parameter int   DATA_WIDTH     = 16,
    parameter logic ASYNC_MODE_EN  = 0,
    parameter int   SYNC_STAGE_NUM = 3,
    parameter int   FIFO_DEPTH     = 4096,
    parameter       FIFO_MEM_TYPE  = "block",
    parameter       FAMILY         = "zynq"
) (

    // physical interface (receive-lvds)

    input logic       rx_clk_in_p,
    input logic       rx_clk_in_n,
    input logic       rx_frame_in_p,
    input logic       rx_frame_in_n,
    input logic [5:0] rx_data_in_p,
    input logic [5:0] rx_data_in_n,

    // physical interface (transmit-lvds)

    output logic       tx_clk_out_p,
    output logic       tx_clk_out_n,
    output logic       tx_frame_out_p,
    output logic       tx_frame_out_n,
    output logic [5:0] tx_data_out_p,
    output logic [5:0] tx_data_out_n,

    // ensm control

    output logic enable,
    output logic txnrx,

    input  logic gps_pps,
    output logic gps_pps_irq,

    // delay clock

    input logic delay_clk,

    // master interface

    output logic l_clk,
    input  logic clk,
    output logic rst,

    // gpio

    input logic up_enable,
    input logic up_txnrx,

    axil_if.slave s_axil,

    axis_if.slave  dac_axis,
    axis_if.master adc_axis
);

    logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] dac_tdata;
    logic [CH_NUM-1:0][1:0]                 dac_tready;
    logic [CH_NUM-1:0][1:0][DATA_WIDTH-1:0] adc_tdata;
    logic [CH_NUM-1:0][1:0]                 adc_tvalid;

    axi_ad9361 #(
        .ID                      (0),
        .MODE_1R1T               (0),
        .FPGA_TECHNOLOGY         (0),
        .FPGA_FAMILY             (0),
        .SPEED_GRADE             (0),
        .DEV_PACKAGE             (0),
        .TDD_DISABLE             (0),
        .PPS_RECEIVER_ENABLE     (PPS_EN),
        .CMOS_OR_LVDS_N          (0),
        .ADC_INIT_DELAY          (30),
        .ADC_DATAPATH_DISABLE    (0),
        .ADC_USERPORTS_DISABLE   (0),
        .ADC_DATAFORMAT_DISABLE  (0),
        .ADC_DCFILTER_DISABLE    (0),
        .ADC_IQCORRECTION_DISABLE(0),
        .DAC_INIT_DELAY          (0),
        .DAC_CLK_EDGE_SEL        (0),
        .DAC_IODELAY_ENABLE      (0),
        .DAC_DATAPATH_DISABLE    (0),
        .DAC_DDS_DISABLE         (0),
        .DAC_DDS_TYPE            (1),
        .DAC_DDS_CORDIC_DW       (14),
        .DAC_DDS_CORDIC_PHASE_DW (13),
        .DAC_USERPORTS_DISABLE   (0),
        .DAC_IQCORRECTION_DISABLE(0),
        .IO_DELAY_GROUP          ("dev_if_delay_group"),
        .IODELAY_CTRL            (1),
        .MIMO_ENABLE             (0),
        .USE_SSI_CLK             (!CLK10M_EN),
        .DELAY_REFCLK_FREQUENCY  (200),
        .RX_NODPA                (0)
    ) i_axi_ad9361 (
        .s_axi_aclk   (s_axil.clk_i),
        .s_axi_aresetn(s_axil.arstn_i),
        .s_axi_awvalid(s_axil.awvalid),
        .s_axi_awaddr (s_axil.awaddr),
        .s_axi_awprot (s_axil.awprot),
        .s_axi_awready(s_axil.awready),
        .s_axi_wvalid (s_axil.wvalid),
        .s_axi_wdata  (s_axil.wdata),
        .s_axi_wstrb  (s_axil.wstrb),
        .s_axi_wready (s_axil.wready),
        .s_axi_bvalid (s_axil.bvalid),
        .s_axi_bresp  (s_axil.bresp),
        .s_axi_bready (s_axil.bready),
        .s_axi_arvalid(s_axil.arvalid),
        .s_axi_araddr (s_axil.araddr),
        .s_axi_arprot (s_axil.arprot),
        .s_axi_arready(s_axil.arready),
        .s_axi_rvalid (s_axil.rvalid),
        .s_axi_rdata  (s_axil.rdata),
        .s_axi_rresp  (s_axil.rresp),
        .s_axi_rready (s_axil.rready),

        .txnrx         (txnrx),
        .enable        (enable),
        .rx_clk_in_n   (rx_clk_in_n),
        .rx_clk_in_p   (rx_clk_in_p),
        .rx_data_in_n  (rx_data_in_n),
        .rx_data_in_p  (rx_data_in_p),
        .tx_clk_out_n  (tx_clk_out_n),
        .tx_clk_out_p  (tx_clk_out_p),
        .rx_frame_in_n (rx_frame_in_n),
        .rx_frame_in_p (rx_frame_in_p),
        .tx_data_out_n (tx_data_out_n),
        .tx_data_out_p (tx_data_out_p),
        .tx_frame_out_n(tx_frame_out_n),
        .tx_frame_out_p(tx_frame_out_p),

        .up_txnrx     (up_txnrx),
        .up_enable    (up_enable),
        .rx_clk_in    ('0),
        .rx_frame_in  ('0),
        .rx_data_in   ('0),
        .tx_clk_out   (),
        .tx_frame_out (),
        .tx_data_out  (),
        .dac_sync_in  ('0),
        .dac_sync_out (),
        .tdd_sync     ('0),
        .tdd_sync_cntr(),
        .gps_pps      (gps_pps),
        .gps_pps_irq  (gps_pps_irq),
        .delay_clk    (delay_clk),
        .l_clk        (l_clk),
        .clk          (clk),
        .rst          (rst),

        .adc_enable_i0(),
        .adc_valid_i0 (adc_tvalid[0][0]),
        .adc_data_i0  (adc_tdata[0][0]),
        .adc_enable_q0(),
        .adc_valid_q0 (adc_tvalid[0][1]),
        .adc_data_q0  (adc_tdata[0][1]),
        .adc_enable_i1(),
        .adc_valid_i1 (adc_tvalid[1][0]),
        .adc_data_i1  (adc_tdata[1][0]),
        .adc_enable_q1(),
        .adc_valid_q1 (adc_tvalid[1][1]),
        .adc_data_q1  (adc_tdata[1][1]),
        .adc_dovf     ('0),
        .adc_r1_mode  (),

        .dac_enable_i0(),
        .dac_valid_i0 (dac_tready[0][0]),
        .dac_data_i0  (dac_tdata[0][0]),
        .dac_enable_q0(),
        .dac_valid_q0 (dac_tready[0][1]),
        .dac_data_q0  (dac_tdata[0][1]),
        .dac_enable_i1(),
        .dac_valid_i1 (dac_tready[1][0]),
        .dac_data_i1  (dac_tdata[1][0]),
        .dac_enable_q1(),
        .dac_valid_q1 (dac_tready[1][1]),
        .dac_data_q1  (dac_tdata[1][1]),
        .dac_dunf     ('0),
        .dac_r1_mode  (),

        .up_dac_gpio_in ('0),
        .up_dac_gpio_out(),
        .up_adc_gpio_in ('0),
        .up_adc_gpio_out()
    );

    localparam int FULL_DATA_WIDTH = CH_NUM * DATA_WIDTH * 2;
    localparam logic [31:0] AXIS_SIGNAL_SET = 32'h03;
    localparam USE_ADV_FEATURES = "1000";

    axis_if #(
        .DATA_WIDTH(FULL_DATA_WIDTH)
    ) dac_if (
        .clk_i  (l_clk),
        .arstn_i(~rst)
    );

    axis_if #(
        .DATA_WIDTH(FULL_DATA_WIDTH)
    ) adc_if (
        .clk_i  (l_clk),
        .arstn_i(~rst)
    );

    axis_data_fifo_wrap #(
        .AXIS_SIGNAL_SET   (AXIS_SIGNAL_SET),
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
        .m_axis(dac_if)
    );

    assign dac_tdata     = dac_if.tdata;
    assign dac_if.tready = |dac_tready;

    axis_data_fifo_wrap #(
        .AXIS_SIGNAL_SET   (AXIS_SIGNAL_SET),
        .FIFO_DEPTH        (FIFO_DEPTH),
        .FIFO_MEM_TYPE     (FIFO_MEM_TYPE),
        .FAMILY            (FAMILY),
        .ASYNC_MODE_EN     (ASYNC_MODE_EN),
        .SYNCHRONIZER_STAGE(SYNC_STAGE_NUM),
        .USE_ADV_FEATURES  (USE_ADV_FEATURES)
    ) i_adc_fifo (
        .s_en_i(1'b1),
        .m_en_i(1'b1),
        .s_axis(adc_if),
        .m_axis(adc_axis)
    );

    assign adc_if.tdata  = adc_tdata;
    assign adc_if.tvalid = |adc_tvalid;

    if (ILA_EN) begin : g_ila
        axil_ila i_axil_ila (
            .clk    (s_axil.clk_i),
            .probe0 (s_axil.awvalid),
            .probe1 (s_axil.awaddr),
            .probe2 (s_axil.bresp),
            .probe3 (s_axil.bvalid),
            .probe4 (s_axil.bready),
            .probe5 (s_axil.wdata),
            .probe6 (s_axil.wvalid),
            .probe7 (s_axil.wready),
            .probe8 (s_axil.awready),
            .probe9 (s_axil.rready),
            .probe10(s_axil.araddr),
            .probe11(s_axil.arvalid),
            .probe12(s_axil.arready),
            .probe13(s_axil.rresp),
            .probe14(s_axil.rdata),
            .probe15(s_axil.wstrb),
            .probe16(s_axil.rvalid),
            .probe17(s_axil.arprot),
            .probe18(s_axil.awprot)
        );
    end

endmodule
