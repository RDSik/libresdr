set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/axi_ad9361_rx_pnmon.v
    $path/rtl/axi_ad9361_rx_channel.v
    $path/rtl/axi_ad9361_rx.v
    $path/rtl/axi_ad9361_tx_channel.v
    $path/rtl/axi_ad9361_tx.v
    $path/rtl/axi_ad9361_tdd.v
    $path/rtl/axi_ad9361_tdd_if.v
    $path/rtl/axi_ad9361.v
    $path/rtl/ad_rst.v
    $path/rtl/ad_pnmon.v
    $path/rtl/ad_bus_mux.v
    $path/rtl/ad_dds_cordic_pipe.v
    $path/rtl/ad_dds_sine_cordic.v
    $path/rtl/ad_dds_sine.v
    $path/rtl/ad_dds_2.v
    $path/rtl/ad_dds_1.v
    $path/rtl/ad_dds.v
    $path/rtl/ad_datafmt.v
    $path/rtl/ad_iqcor.v
    $path/rtl/ad_addsub.v
    $path/rtl/ad_tdd_control.v
    $path/rtl/ad_pps_receiver.v
    $path/rtl/up_axi.v
    $path/rtl/up_xfer_cntrl.v
    $path/rtl/up_xfer_status.v
    $path/rtl/up_clock_mon.v
    $path/rtl/up_delay_cntrl.v
    $path/rtl/up_adc_common.v
    $path/rtl/up_adc_channel.v
    $path/rtl/up_dac_common.v
    $path/rtl/up_dac_channel.v
    $path/rtl/up_tdd_cntrl.v
    $path/rtl/ad_iobuf.v
    $path/rtl/ad_data_clk.v
    $path/rtl/ad_data_in.v
    $path/rtl/ad_data_out.v
    $path/rtl/ad_dcfilter.v
    $path/rtl/ad_mul.v
    $path/rtl/axi_ad9361_lvds_if.v
    $path/rtl/axi_ad9361_cmos_if.v
"

add_files -norecurse $xil_defaultlib
add_files -norecurse $path/xdc/axi_ad9361_constr.xdc
add_files -norecurse $path/xdc/ad_rst_constr.xdc
add_files -norecurse $path/xdc/up_xfer_status_constr.xdc
add_files -norecurse $path/xdc/up_clock_mon_constr.xdc
add_files -norecurse $path/xdc/up_xfer_cntrl_constr.xdc
