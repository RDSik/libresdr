set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/axi_ad9361_top.sv
    $path/rtl/libre_top.sv
    $path/rtl/fir_adc_dac.sv
"

add_files -norecurse $xil_defaultlib
