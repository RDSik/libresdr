set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/ad_rst.v
    $path/rtl/ad_pnmon.v
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
"

add_files -norecurse $xil_defaultlib
