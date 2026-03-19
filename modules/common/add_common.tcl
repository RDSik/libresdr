set path [file dirname [info script]]

set xci_defaultlib "
    $path/ip/axi_clock_converter/axi_clock_converter.xci
    $path/ip/axis_data_fifo/axis_data_fifo.xci
    $path/ip/fir_interpolator/fir_interpolator.xci
    $path/ip/fir_decimator/fir_decimator.xci
    $path/ip/dds_compiler/dds_compiler.xci
    $path/ip/axil_ila/axil_ila.xci
"

add_files -norecurse $xci_defaultlib

set xil_defaultlib "
    $path/rtl/axil_reg_file_wrap.sv
    $path/rtl/axil_reg_file.sv
    $path/rtl/axis_data_fifo_wrap.sv
    $path/rtl/dds.sv
"

add_files -norecurse $xil_defaultlib

set xil_defaultlib "
    $path/tb/axil_master.sv
"

add_files -fileset sim_1 $xil_defaultlib
