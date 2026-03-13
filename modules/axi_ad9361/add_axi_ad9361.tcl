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
"

add_files -norecurse $xil_defaultlib
add_files -norecurse $path/xdc/axi_ad9361_constr.xdc
