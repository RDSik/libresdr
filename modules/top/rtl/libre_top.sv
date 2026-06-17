module libre_top #(
    parameter bit ILA_EN    = 1,
    parameter bit PPS_EN    = 0,
    parameter bit CLK10M_EN = 0
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
    logic rstn;

    if (CLK10M_EN) begin : g_clk10m
        assign clk = clk_10m;
    end else begin : g_rx_clk
        assign clk = l_clk;
    end

    axil_if #(
        .DATA_WIDTH(AXIL_DATA_WIDTH),
        .ADDR_WIDTH(AXIL_ADDR_WIDTH)
    ) ad_axil (
        .clk_i  (ps_clk),
        .arstn_i(ps_arstn)
    );

    axil_if #(
        .DATA_WIDTH(AXIL_DATA_WIDTH),
        .ADDR_WIDTH(AXIL_ADDR_WIDTH)
    ) sig_gen_axil (
        .clk_i  (ps_clk),
        .arstn_i(ps_arstn)
    );

    axis_if #(
        .DATA_WIDTH(FULL_DATA_WIDH)
    ) mm2s_axis (
        .clk_i  (l_clk),
        .arstn_i(rstn)
    );

    axis_if #(
        .DATA_WIDTH(FULL_DATA_WIDH)
    ) s2mm_axis (
        .clk_i  (l_clk),
        .arstn_i(rstn)
    );

    axis_if #(
        .DATA_WIDTH(FULL_DATA_WIDH)
    ) dac_axis (
        .clk_i  (l_clk),
        .arstn_i(rstn)
    );

    logic i2c_scl_i;
    logic i2c_scl_o;
    logic i2c_scl_t;

    logic i2c_sda_i;
    logic i2c_sda_o;
    logic i2c_sda_t;

    IOBUF i_scl_IOBUF (
        .O (i2c_scl_i),
        .IO(iic_scl),
        .I (i2c_scl_o),
        .T (i2c_scl_t)
    );

    IOBUF i_sda_IOBUF (
        .O (i2c_sda_i),
        .IO(iic_sda),
        .I (i2c_sda_o),
        .T (i2c_sda_t)
    );

    logic [24:0] gpio_i;
    logic [24:0] gpio_o;
    logic [24:0] gpio_t;

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

    logic pps_irq;

    bd_top i_bd_top (
        .ddr_addr   (ddr_addr),
        .ddr_ba     (ddr_ba),
        .ddr_cas_n  (ddr_cas_n),
        .ddr_ck_n   (ddr_ck_n),
        .ddr_ck_p   (ddr_ck_p),
        .ddr_cke    (ddr_cke),
        .ddr_cs_n   (ddr_cs_n),
        .ddr_dm     (ddr_dm),
        .ddr_dq     (ddr_dq),
        .ddr_odt    (ddr_odt),
        .ddr_we_n   (ddr_we_n),
        .ddr_dqs_n  (ddr_dqs_n),
        .ddr_dqs_p  (ddr_dqs_p),
        .ddr_ras_n  (ddr_ras_n),
        .ddr_reset_n(ddr_reset_n),

        .fixed_io_mio     (fixed_io_mio),
        .fixed_io_ps_clk  (fixed_io_ps_clk),
        .fixed_io_ddr_vrn (fixed_io_ddr_vrn),
        .fixed_io_ddr_vrp (fixed_io_ddr_vrp),
        .fixed_io_ps_porb (fixed_io_ps_porb),
        .fixed_io_ps_srstb(fixed_io_ps_srstb),

        .pps_irq_i (pps_irq),

        .ps_clk1_o (ps_clk),
        .ps_clk2_o (delay_clk),
        .ps_arstn_o(ps_arstn),

        .gpio_o(gpio_o),
        .gpio_i(gpio_i),
        .gpio_t(gpio_t),

        .i2c_scl_i(i2c_scl_i),
        .i2c_scl_o(i2c_scl_o),
        .i2c_scl_t(i2c_scl_t),

        .i2c_sda_i(i2c_sda_i),
        .i2c_sda_o(i2c_sda_o),
        .i2c_sda_t(i2c_sda_t),

        .ps_spi_csn_o (spi_csn),
        .ps_spi_clk_o (spi_clk),
        .ps_spi_mosi_o(spi_mosi),
        .ps_spi_miso_i(spi_miso),

        .pl_spi_clk_o (pl_spi_clk_o),
        .pl_spi_mosi_o(pl_spi_mosi),
        .pl_spi_miso_i(pl_spi_miso),

        .ad_axil (ad_axil),
        .ext_axil(sig_gen_axil),

        .s2mm_axis(s2mm_axis),
        .mm2s_axis(mm2s_axis)
    );

    localparam bit ASYNC_MODE_EN = 1;
    localparam int FIFO_DEPTH = 256;
    localparam FAMILY = "zynq";

    axi_ad9361_wrap #(
        .DATA_WIDTH(IQ_DATA_WIDTH),
        .TLAST_VAL (FIFO_DEPTH),
        .ILA_EN    (ILA_EN),
        .FAMILY    (FAMILY),
        .CH_NUM    (CH_NUM),
        .CLK10M_EN (CLK10M_EN),
        .PPS_EN    (PPS_EN)
    ) i_axi_ad9361_wrap (
        .s_axil(ad_axil),

        .txnrx_o       (txnrx),
        .enable_o      (enable),
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

        .up_txnrx_i   (gpio_o[16]),
        .up_enable_i  (gpio_o[15]),
        .gps_pps_i    (pps),
        .gps_pps_irq_o(pps_irq),
        .delay_clk_i  (delay_clk),
        .l_clk_o      (l_clk),
        .clk_i        (clk),
        .rstn_o       (rstn),

        .adc_axis(s2mm_axis),
        .dac_axis(dac_axis)
    );

    localparam int SYNC_STAGE_NUM = 3;
    localparam FIFO_MEM_TYPE = "block";

    signal_gen #(
        .ILA_EN         (ILA_EN),
        .CH_NUM         (CH_NUM),
        .DATA_WIDTH     (IQ_DATA_WIDTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .SYNC_STAGE_NUM (SYNC_STAGE_NUM),
        .ASYNC_MODE_EN  (ASYNC_MODE_EN),
        .FIFO_DEPTH     (FIFO_DEPTH),
        .FIFO_MEM_TYPE  (FIFO_MEM_TYPE),
        .FAMILY         (FAMILY)
    ) i_signal_gen (
        .clk_i  (l_clk),
        .arstn_i(rstn),
        .s_axil (sig_gen_axil),
        .s_axis (mm2s_axis),
        .m_axis (dac_axis)
    );

endmodule
