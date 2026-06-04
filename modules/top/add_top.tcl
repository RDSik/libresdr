set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/axi_ad9361_wrap.sv
    $path/rtl/axi_dmac_wrap.sv
    $path/rtl/libre_top.sv
"

add_files -norecurse $xil_defaultlib
