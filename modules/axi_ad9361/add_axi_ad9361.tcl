set path [file dirname [info script]]

set xil_defaultlib "
    $path/hdl/library/axi_ad9361/axi_ad9361_rx_pnmon.v
    $path/hdl/library/axi_ad9361/axi_ad9361_rx_channel.v
    $path/hdl/library/axi_ad9361/axi_ad9361_rx.v
    $path/hdl/library/axi_ad9361/axi_ad9361_tx_channel.v
    $path/hdl/library/axi_ad9361/axi_ad9361_tx.v
    $path/hdl/library/axi_ad9361/axi_ad9361_tdd.v
    $path/hdl/library/axi_ad9361/axi_ad9361_tdd_if.v
    $path/hdl/library/axi_ad9361/axi_ad9361.v
    $path/hdl/library/axi_ad9361/xilinx/axi_ad9361_lvds_if.v
    $path/hdl/library/axi_ad9361/xilinx/axi_ad9361_cmos_if.v
    $path/hdl/library/common/ad_rst.v
    $path/hdl/library/common/ad_pnmon.v
    $path/hdl/library/common/ad_bus_mux.v
    $path/hdl/library/common/ad_dds_cordic_pipe.v
    $path/hdl/library/common/ad_dds_sine_cordic.v
    $path/hdl/library/common/ad_dds_sine.v
    $path/hdl/library/common/ad_dds_2.v
    $path/hdl/library/common/ad_dds_1.v
    $path/hdl/library/common/ad_dds.v
    $path/hdl/library/common/ad_datafmt.v
    $path/hdl/library/common/ad_iqcor.v
    $path/hdl/library/common/ad_addsub.v
    $path/hdl/library/common/ad_tdd_control.v
    $path/hdl/library/common/ad_pps_receiver.v
    $path/hdl/library/common/up_axi.v
    $path/hdl/library/common/ad_iobuf.v
    $path/hdl/library/common/util_pulse_gen.v
    $path/hdl/library/common/up_xfer_cntrl.v
    $path/hdl/library/common/up_xfer_status.v
    $path/hdl/library/common/up_clock_mon.v
    $path/hdl/library/common/up_delay_cntrl.v
    $path/hdl/library/common/up_adc_common.v
    $path/hdl/library/common/up_adc_channel.v
    $path/hdl/library/common/up_dac_common.v
    $path/hdl/library/common/up_dac_channel.v
    $path/hdl/library/common/up_tdd_cntrl.v
    $path/hdl/library/xilinx/common/ad_data_clk.v
    $path/hdl/library/xilinx/common/ad_data_in.v
    $path/hdl/library/xilinx/common/ad_data_out.v
    $path/hdl/library/xilinx/common/ad_dcfilter.v
    $path/hdl/library/xilinx/common/ad_mul.v
"

add_files -norecurse $xil_defaultlib
add_files -norecurse $path/hdl/library/axi_ad9361/axi_ad9361_constr.xdc
add_files -norecurse $path/hdl/library/xilinx/common/ad_rst_constr.xdc
add_files -norecurse $path/hdl/library/xilinx/common/up_xfer_status_constr.xdc
add_files -norecurse $path/hdl/library/xilinx/common/up_clock_mon_constr.xdc
add_files -norecurse $path/hdl/library/xilinx/common/up_xfer_cntrl_constr.xdc
