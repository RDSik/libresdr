set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/ad_data_clk.v
    $path/rtl/ad_data_in.v
    $path/rtl/ad_data_out.v
    $path/rtl/ad_dcfilter.v
    $path/rtl/ad_mul.v
    $path/rtl/axi_ad9361_lvds_if.v
    $path/rtl/axi_ad9361_cmos_if.v
"

add_files -norecurse $xil_defaultlib
add_files -norecurse $path/xdc/ad_rst_constr.xdc
add_files -norecurse $path/xdc/up_xfer_status_constr.xdc
add_files -norecurse $path/xdc/up_clock_mon_constr.xdc
add_files -norecurse $path/xdc/up_xfer_cntrl_constr.xdc
