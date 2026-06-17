module bd_top #(
    parameter bit ASYNC_MODE_EN      = 1,
    parameter int SYNCHRONIZER_STAGE = 3,
    parameter int FIFO_DEPTH         = 256,
    parameter int FIFO_WIDTH         = 64,
    parameter     FIFO_MEM_TYPE      = "block"
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

    input  logic i2c_scl_i,
    output logic i2c_scl_o,
    output logic i2c_scl_t,
    input  logic i2c_sda_i,
    output logic i2c_sda_o,
    output logic i2c_sda_t,

    input  logic [24:0] gpio_i,
    output logic [24:0] gpio_o,
    output logic [24:0] gpio_t,

    output logic ps_spi_csn_o,
    output logic ps_spi_clk_o,
    output logic ps_spi_mosi_o,
    input  logic ps_spi_miso_i,

    output logic pl_spi_clk_o,
    output logic pl_spi_mosi_o,
    input  logic pl_spi_miso_i,

    input logic pps_irq_i,

    output logic ps_clk1_o,
    output logic ps_clk2_o,
    output logic ps_arstn_o,

    axil_if.master ad_axil,
    axil_if.master ext_axil,

    axis_if.slave  s2mm_axis,
    axis_if.master mm2s_axis
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

        .FCLK_CLK0_0    (ps_clk1_o),
        .FCLK_CLK1_0    (ps_clk2_o),
        .FCLK_RESET0_N_0(ps_arstn_o),

        .FIXED_IO_0_ddr_vrn (fixed_io_ddr_vrn),
        .FIXED_IO_0_ddr_vrp (fixed_io_ddr_vrp),
        .FIXED_IO_0_mio     (fixed_io_mio),
        .FIXED_IO_0_ps_clk  (fixed_io_ps_clk),
        .FIXED_IO_0_ps_porb (fixed_io_ps_porb),
        .FIXED_IO_0_ps_srstb(fixed_io_ps_srstb),

        .GPIO_0_0_tri_i(gpio_i),
        .GPIO_0_0_tri_o(gpio_o),
        .GPIO_0_0_tri_t(gpio_t),

        .IIC_0_scl_i(i2c_scl_i),
        .IIC_0_scl_o(i2c_scl_o),
        .IIC_0_scl_t(i2c_scl_t),
        .IIC_0_sda_i(i2c_sda_i),
        .IIC_0_sda_o(i2c_sda_o),
        .IIC_0_sda_t(i2c_sda_t),

        .AXI_AD9361_0_araddr (ad_axil.araddr),
        .AXI_AD9361_0_arprot (ad_axil.arprot),
        .AXI_AD9361_0_arready(ad_axil.arready),
        .AXI_AD9361_0_arvalid(ad_axil.arvalid),
        .AXI_AD9361_0_awaddr (ad_axil.awaddr),
        .AXI_AD9361_0_awprot (ad_axil.awprot),
        .AXI_AD9361_0_awready(ad_axil.awready),
        .AXI_AD9361_0_awvalid(ad_axil.awvalid),
        .AXI_AD9361_0_bready (ad_axil.bready),
        .AXI_AD9361_0_bresp  (ad_axil.bresp),
        .AXI_AD9361_0_bvalid (ad_axil.bvalid),
        .AXI_AD9361_0_rdata  (ad_axil.rdata),
        .AXI_AD9361_0_rready (ad_axil.rready),
        .AXI_AD9361_0_rresp  (ad_axil.rresp),
        .AXI_AD9361_0_rvalid (ad_axil.rvalid),
        .AXI_AD9361_0_wdata  (ad_axil.wdata),
        .AXI_AD9361_0_wready (ad_axil.wready),
        .AXI_AD9361_0_wstrb  (ad_axil.wstrb),
        .AXI_AD9361_0_wvalid (ad_axil.wvalid),

        .M04_AXI_0_araddr (ext_axil.araddr),
        .M04_AXI_0_arprot (ext_axil.arprot),
        .M04_AXI_0_arready(ext_axil.arready),
        .M04_AXI_0_arvalid(ext_axil.arvalid),
        .M04_AXI_0_awaddr (ext_axil.awaddr),
        .M04_AXI_0_awprot (ext_axil.awprot),
        .M04_AXI_0_awready(ext_axil.awready),
        .M04_AXI_0_awvalid(ext_axil.awvalid),
        .M04_AXI_0_bready (ext_axil.bready),
        .M04_AXI_0_bresp  (ext_axil.bresp),
        .M04_AXI_0_bvalid (ext_axil.bvalid),
        .M04_AXI_0_rdata  (ext_axil.rdata),
        .M04_AXI_0_rready (ext_axil.rready),
        .M04_AXI_0_rresp  (ext_axil.rresp),
        .M04_AXI_0_rvalid (ext_axil.rvalid),
        .M04_AXI_0_wdata  (ext_axil.wdata),
        .M04_AXI_0_wready (ext_axil.wready),
        .M04_AXI_0_wstrb  (ext_axil.wstrb),
        .M04_AXI_0_wvalid (ext_axil.wvalid),

        .SPI_0_0_io0_i('0),
        .SPI_0_0_io0_o(ps_spi_mosi_o),
        .SPI_0_0_io0_t(),
        .SPI_0_0_io1_i(ps_spi_miso_i),
        .SPI_0_0_io1_o(),
        .SPI_0_0_io1_t(),
        .SPI_0_0_sck_i('0),
        .SPI_0_0_sck_o(ps_spi_clk_o),
        .SPI_0_0_sck_t(),
        .SPI_0_0_ss1_o(),
        .SPI_0_0_ss2_o(),
        .SPI_0_0_ss_i ('1),
        .SPI_0_0_ss_o (ps_spi_csn_o),
        .SPI_0_0_ss_t (),

        .SPI_0_1_io0_i('0),
        .SPI_0_1_io0_o(pl_spi_mosi_o),
        .SPI_0_1_io0_t(),
        .SPI_0_1_io1_i(pl_spi_miso_i),
        .SPI_0_1_io1_o(),
        .SPI_0_1_io1_t(),
        .SPI_0_1_sck_i('0),
        .SPI_0_1_sck_o(pl_spi_clk_o),
        .SPI_0_1_sck_t(),
        .SPI_0_1_ss_i ('1),
        .SPI_0_1_ss_o (),
        .SPI_0_1_ss_t (),

        .M_AXIS_MM2S_0_tdata (mm2s_axis.tdata),
        .M_AXIS_MM2S_0_tkeep (mm2s_axis.tkeep),
        .M_AXIS_MM2S_0_tlast (mm2s_axis.tlast),
        .M_AXIS_MM2S_0_tready(mm2s_axis.tready),
        .M_AXIS_MM2S_0_tvalid(mm2s_axis.tvalid),

        .S_AXIS_S2MM_0_tdata (s2mm_axis.tdata),
        .S_AXIS_S2MM_0_tkeep (s2mm_axis.tkeep),
        .S_AXIS_S2MM_0_tlast (s2mm_axis.tlast),
        .S_AXIS_S2MM_0_tready(s2mm_axis.tready),
        .S_AXIS_S2MM_0_tvalid(s2mm_axis.tvalid),

        .pps_irq(pps_irq_i)
    );

    localparam logic [31:0] AXIS_SIGNAL_SET = 32'h03;

    axis_data_fifo_wrap #(
        .ASYNC_MODE_EN     (ASYNC_MODE_EN),
        .SYNCHRONIZER_STAGE(SYNCHRONIZER_STAGE),
        .AXIS_SIGNAL_SET   (AXIS_SIGNAL_SET),
        .FIFO_DEPTH        (FIFO_DEPTH),
        .FIFO_MEM_TYPE     (FIFO_MEM_TYPE),
        .FAMILY            (FAMILY),
        .USE_ADV_FEATURES  ("1000")
    ) i_s2mm_fifo (
        .s_en_i(1'b1),
        .m_en_i(1'b1),
        .s_axis(),
        .m_axis()
    );

    axis_data_fifo_wrap #(
        .ASYNC_MODE_EN     (ASYNC_MODE_EN),
        .SYNCHRONIZER_STAGE(SYNCHRONIZER_STAGE),
        .AXIS_SIGNAL_SET   (AXIS_SIGNAL_SET),
        .FIFO_DEPTH        (FIFO_DEPTH),
        .FIFO_MEM_TYPE     (FIFO_MEM_TYPE),
        .FAMILY            (FAMILY),
        .USE_ADV_FEATURES  ("1000")
    ) i_mm2s_fifo (
        .s_en_i(1'b1),
        .m_en_i(1'b1),
        .s_axis(),
        .m_axis()
    );

    axis_tlast_gen #(
        .TLAST_VAL(FIFO_DEPTH)
    ) i_axis_tlast_gen (
        .s_axis(),
        .m_axis()
    );

endmodule
