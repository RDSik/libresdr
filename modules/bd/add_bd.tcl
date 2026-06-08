set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/bd_top.sv
"

add_files -norecurse $xil_defaultlib

source $path/bd/libre_bd.tcl