set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/signal_gen_pkg.svh
    $path/rtl/signal_gen.sv
"

add_files -norecurse $xil_defaultlib

set xil_defaultlib "
    $path/tb/signal_gen_tb.sv
"
add_files -fileset sim_1 $xil_defaultlib
