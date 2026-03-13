set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/libre_top.sv
"

add_files -norecurse $xil_defaultlib
