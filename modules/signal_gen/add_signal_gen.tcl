set path [file dirname [info script]]

set xci_defaultlib "
    $path/ip/dds_compiler/dds_compiler.xci
    $path/ip/axil_ila/axil_ila.xci
"

add_files -norecurse $xci_defaultlib

set xil_defaultlib "
    $path/rtl/axil_reg_file.sv
    $path/rtl/axis_dw_conv.v
    $path/rtl/axis_fifo.v
    $path/rtl/sync_fifo.v
    $path/rtl/ram_sdp.v
    $path/rtl/dds.sv
"

add_files -norecurse $xil_defaultlib
