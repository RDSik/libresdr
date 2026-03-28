module libre_top #(
    parameter logic ILA_EN    = 1,
    parameter logic PPS_EN    = 0,
    parameter logic CLK10M_EN = 0
) (
    inout [14:0] ddr_addr,
    inout [ 2:0] ddr_ba,
    inout        ddr_cas_n,
    inout        ddr_ck_n,
    inout        ddr_ck_p,
    inout        ddr_cke,
    inout        ddr_cs_n,
    inout [ 3:0] ddr_dm,
    inout [31:0] ddr_dq,
    inout [ 3:0] ddr_dqs_n,
    inout [ 3:0] ddr_dqs_p,
    inout        ddr_odt,
    inout        ddr_ras_n,
    inout        ddr_reset_n,
    inout        ddr_we_n,

    inout        fixed_io_ddr_vrn,
    inout        fixed_io_ddr_vrp,
    inout [53:0] fixed_io_mio,
    inout        fixed_io_ps_clk,
    inout        fixed_io_ps_porb,
    inout        fixed_io_ps_srstb,

    inout iic_scl,
    inout iic_sda,

    input        rx_clk_in_p,
    input        rx_clk_in_n,
    input        rx_frame_in_p,
    input        rx_frame_in_n,
    input  [5:0] rx_data_in_p,
    input  [5:0] rx_data_in_n,
    output       tx_clk_out_p,
    output       tx_clk_out_n,
    output       tx_frame_out_p,
    output       tx_frame_out_n,
    output [5:0] tx_data_out_p,
    output [5:0] tx_data_out_n,

    output enable,
    output txnrx,

    inout       gpio_resetb,
    inout       gpio_en_agc,
    inout [3:0] gpio_ctl,
    inout [7:0] gpio_status,

    output spi_csn,
    output spi_clk,
    output spi_mosi,
    input  spi_miso,

    output pl_spi_clk_o,
    output pl_spi_mosi,
    input  pl_spi_miso,

    input clk_10m,
    input pps
);

    // internal signals

    logic [24:0] gpio_i;
    logic [24:0] gpio_o;
    logic [24:0] gpio_t;

    // instantiations

    ad_iobuf #(
        .DATA_WIDTH(14)
    ) i_iobuf (
        .dio_t(gpio_t[13:0]),
        .dio_i(gpio_o[13:0]),
        .dio_o(gpio_i[13:0]),
        .dio_p({gpio_resetb,  // 13:13
 gpio_en_agc,  // 12:12
 gpio_ctl,  // 11: 8
 gpio_status})
    );  //  7: 0

    assign gpio_i[16:14] = gpio_o[16:14];

    localparam int CH_NUM = 2;
    localparam int IQ_DATA_WIDTH = 16;
    localparam int FULL_DATA_WIDH = CH_NUM * IQ_DATA_WIDTH * 2;
    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;

    logic ps_clk;
    logic ps_arstn;

    logic delay_clk;
    logic l_clk;
    logic clk;
    logic rst;

    if (CLK10M_EN) begin : g_clk10m
        assign clk = clk_10m;
    end else begin : g_rx_clk
        assign clk = l_clk;
    end

    axil_if #(
        .DATA_WIDTH(AXIL_DATA_WIDTH),
        .ADDR_WIDTH(AXIL_ADDR_WIDTH)
    ) axil_ad (
        .clk_i  (ps_clk),
        .arstn_i(ps_arstn)
    );

    axil_if #(
        .DATA_WIDTH(AXIL_DATA_WIDTH),
        .ADDR_WIDTH(AXIL_ADDR_WIDTH)
    ) axil_sig_gen (
        .clk_i  (ps_clk),
        .arstn_i(ps_arstn)
    );

    axis_if #(
        .DATA_WIDTH(FULL_DATA_WIDH)
    ) axis_mm2s (
        .clk_i  (ps_clk),
        .arstn_i(ps_arstn)
    );

    axis_if #(
        .DATA_WIDTH(FULL_DATA_WIDH)
    ) axis_s2mm (
        .clk_i  (ps_clk),
        .arstn_i(ps_arstn)
    );

    axis_if #(
        .DATA_WIDTH(FULL_DATA_WIDH)
    ) adc_axis (
        .clk_i  (ps_clk),
        .arstn_i(ps_arstn)
    );

    axis_if #(
        .DATA_WIDTH(FULL_DATA_WIDH)
    ) dac_axis (
        .clk_i  (ps_clk),
        .arstn_i(ps_arstn)
    );

    logic                                      pps_irq;

    logic [CH_NUM-1:0][1:0][IQ_DATA_WIDTH-1:0] adc_tdata;
    logic [CH_NUM-1:0][1:0]                    adc_tvalid;

    logic [CH_NUM-1:0][1:0][IQ_DATA_WIDTH-1:0] dac_tdata;
    logic [CH_NUM-1:0][1:0]                    dac_tready;

    logic                                      scl_i;
    logic                                      scl_o;
    logic                                      scl_t;

    logic                                      sda_i;
    logic                                      sda_o;
    logic                                      sda_t;

    IOBUF i_scl_IOBUF (
        .O (scl_i),
        .IO(iic_scl),
        .I (scl_o),
        .T (scl_t)
    );

    IOBUF i_sda_IOBUF (
        .O (sda_i),
        .IO(iic_sda),
        .I (sda_o),
        .T (sda_t)
    );

    libre_bd i_libre_bd (
        .DDR_0_addr   (ddr_addr),
        .DDR_0_ba     (ddr_ba),
        .DDR_0_cas_n  (ddr_cas_n),
        .DDR_0_ck_n   (ddr_ck_n),
        .DDR_0_ck_p   (ddr_ck_p),
        .DDR_0_cke    (ddr_cke),
        .DDR_0_cs_n   (ddr_cs_n),
        .DDR_0_dm     (ddr_dm),
        .DDR_0_dq     (ddr_dq),
        .DDR_0_dqs_n  (ddr_dqs_n),
        .DDR_0_dqs_p  (ddr_dqs_p),
        .DDR_0_odt    (ddr_odt),
        .DDR_0_ras_n  (ddr_ras_n),
        .DDR_0_reset_n(ddr_reset_n),
        .DDR_0_we_n   (ddr_we_n),

        .FCLK_CLK0_0    (ps_clk),
        .FCLK_CLK1_0    (delay_clk),
        .FCLK_RESET0_N_0(ps_arstn),

        .FIXED_IO_0_ddr_vrn (fixed_io_ddr_vrn),
        .FIXED_IO_0_ddr_vrp (fixed_io_ddr_vrp),
        .FIXED_IO_0_mio     (fixed_io_mio),
        .FIXED_IO_0_ps_clk  (fixed_io_ps_clk),
        .FIXED_IO_0_ps_porb (fixed_io_ps_porb),
        .FIXED_IO_0_ps_srstb(fixed_io_ps_srstb),

        .GPIO_0_0_tri_i(gpio_i),
        .GPIO_0_0_tri_o(gpio_o),
        .GPIO_0_0_tri_t(gpio_t),

        .IIC_0_scl_i(scl_i),
        .IIC_0_scl_o(scl_o),
        .IIC_0_scl_t(scl_t),
        .IIC_0_sda_i(sda_i),
        .IIC_0_sda_o(sda_o),
        .IIC_0_sda_t(sda_t),

        .AXI_AD9361_0_araddr (axil_ad.araddr),
        .AXI_AD9361_0_arprot (axil_ad.arprot),
        .AXI_AD9361_0_arready(axil_ad.arready),
        .AXI_AD9361_0_arvalid(axil_ad.arvalid),
        .AXI_AD9361_0_awaddr (axil_ad.awaddr),
        .AXI_AD9361_0_awprot (axil_ad.awprot),
        .AXI_AD9361_0_awready(axil_ad.awready),
        .AXI_AD9361_0_awvalid(axil_ad.awvalid),
        .AXI_AD9361_0_bready (axil_ad.bready),
        .AXI_AD9361_0_bresp  (axil_ad.bresp),
        .AXI_AD9361_0_bvalid (axil_ad.bvalid),
        .AXI_AD9361_0_rdata  (axil_ad.rdata),
        .AXI_AD9361_0_rready (axil_ad.rready),
        .AXI_AD9361_0_rresp  (axil_ad.rresp),
        .AXI_AD9361_0_rvalid (axil_ad.rvalid),
        .AXI_AD9361_0_wdata  (axil_ad.wdata),
        .AXI_AD9361_0_wready (axil_ad.wready),
        .AXI_AD9361_0_wstrb  (axil_ad.wstrb),
        .AXI_AD9361_0_wvalid (axil_ad.wvalid),

        .M_AXI_1_araddr (axil_sig_gen.araddr),
        .M_AXI_1_arprot (axil_sig_gen.arprot),
        .M_AXI_1_arready(axil_sig_gen.arready),
        .M_AXI_1_arvalid(axil_sig_gen.arvalid),
        .M_AXI_1_awaddr (axil_sig_gen.awaddr),
        .M_AXI_1_awprot (axil_sig_gen.awprot),
        .M_AXI_1_awready(axil_sig_gen.awready),
        .M_AXI_1_awvalid(axil_sig_gen.awvalid),
        .M_AXI_1_bready (axil_sig_gen.bready),
        .M_AXI_1_bresp  (axil_sig_gen.bresp),
        .M_AXI_1_bvalid (axil_sig_gen.bvalid),
        .M_AXI_1_rdata  (axil_sig_gen.rdata),
        .M_AXI_1_rready (axil_sig_gen.rready),
        .M_AXI_1_rresp  (axil_sig_gen.rresp),
        .M_AXI_1_rvalid (axil_sig_gen.rvalid),
        .M_AXI_1_wdata  (axil_sig_gen.wdata),
        .M_AXI_1_wready (axil_sig_gen.wready),
        .M_AXI_1_wstrb  (axil_sig_gen.wstrb),
        .M_AXI_1_wvalid (axil_sig_gen.wvalid),

        .M_AXIS_MM2S_0_tdata (axis_mm2s.tdata),
        .M_AXIS_MM2S_0_tkeep (axis_mm2s.tkeep),
        .M_AXIS_MM2S_0_tlast (axis_mm2s.tlast),
        .M_AXIS_MM2S_0_tready(axis_mm2s.tready),
        .M_AXIS_MM2S_0_tvalid(axis_mm2s.tvalid),

        .SPI_0_0_io0_i('0),
        .SPI_0_0_io0_o(spi_mosi),
        .SPI_0_0_io0_t(),
        .SPI_0_0_io1_i(spi_miso),
        .SPI_0_0_io1_o(),
        .SPI_0_0_io1_t(),
        .SPI_0_0_sck_i('0),
        .SPI_0_0_sck_o(spi_clk),
        .SPI_0_0_sck_t(),
        .SPI_0_0_ss1_o(),
        .SPI_0_0_ss2_o(),
        .SPI_0_0_ss_i ('1),
        .SPI_0_0_ss_o (spi_csn),
        .SPI_0_0_ss_t (),

        .SPI_0_1_io0_i('0),
        .SPI_0_1_io0_o(pl_spi_mosi),
        .SPI_0_1_io0_t(),
        .SPI_0_1_io1_i(pl_spi_miso),
        .SPI_0_1_io1_o(),
        .SPI_0_1_io1_t(),
        .SPI_0_1_sck_i('0),
        .SPI_0_1_sck_o(pl_spi_clk_o),
        .SPI_0_1_sck_t(),
        .SPI_0_1_ss_i ('1),
        .SPI_0_1_ss_o (),
        .SPI_0_1_ss_t (),

        .S_AXIS_S2MM_0_tdata (axis_s2mm.tdata),
        .S_AXIS_S2MM_0_tkeep (axis_s2mm.tkeep),
        .S_AXIS_S2MM_0_tlast (axis_s2mm.tlast),
        .S_AXIS_S2MM_0_tready(axis_s2mm.tready),
        .S_AXIS_S2MM_0_tvalid(axis_s2mm.tvalid),

        .pps_irq(pps_irq)
    );

    localparam int SYNC_STAGE_NUM = 3;
    localparam int ASYNC_MODE_EN = 1;
    localparam int FIFO_DEPTH = 256;
    localparam FIFO_MEM_TYPE = "block";
    localparam FAMILY = "zynq";

    localparam logic [31:0] S_AXIS_SIGNAL_SET = 32'h03;
    localparam logic [31:0] M_AXIS_SIGNAL_SET = 32'h1B;

    axis_subset_converter_wrap #(
        .FAMILY           (FAMILY),
        .DEFAULT_TLAST    (FIFO_DEPTH),
        .S_AXIS_SIGNAL_SET(S_AXIS_SIGNAL_SET),
        .M_AXIS_SIGNAL_SET(M_AXIS_SIGNAL_SET)
    ) i_axis_subset_converter_wrap (
        .en_i  (1'b1),
        .s_axis(adc_axis),
        .m_axis(axis_s2mm)
    );

    axi_ad9361_top #(
        .DATA_WIDTH    (IQ_DATA_WIDTH),
        .ILA_EN        (ILA_EN),
        .FAMILY        (FAMILY),
        .FIFO_DEPTH    (FIFO_DEPTH),
        .ASYNC_MODE_EN (ASYNC_MODE_EN),
        .FIFO_MEM_TYPE (FIFO_MEM_TYPE),
        .CH_NUM        (CH_NUM),
        .CLK10M_EN     (CLK10M_EN),
        .PPS_EN        (PPS_EN),
        .SYNC_STAGE_NUM(SYNC_STAGE_NUM)
    ) i_axi_ad9361_top (
        .s_axil(axil_ad),

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

        .up_txnrx   (gpio_o[16]),
        .up_enable  (gpio_o[15]),
        .gps_pps    (pps),
        .gps_pps_irq(pps_irq),
        .delay_clk  (delay_clk),
        .l_clk      (l_clk),
        .clk        (clk),
        .rst        (rst),

        .adc_axis(adc_axis),
        .dac_axis(dac_axis)
    );

    signal_gen #(
        .ILA_EN         (ILA_EN),
        .CH_NUM         (CH_NUM),
        .DATA_WIDTH     (IQ_DATA_WIDTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .SYNC_STAGE_NUM (SYNC_STAGE_NUM),
        .ASYNC_MODE_EN  (0),
        .FIFO_DEPTH     (FIFO_DEPTH),
        .FIFO_MEM_TYPE  (FIFO_MEM_TYPE),
        .FAMILY         (FAMILY)
    ) i_signal_gen (
        .clk_i  (ps_clk),
        .arstn_i(ps_arstn),
        .s_axil (axil_sig_gen),
        .s_axis (axis_mm2s),
        .m_axis (dac_axis)
    );

endmodule
