set syn_top     "libre_top"
set platform    ${syn_top}_hw_platform_0
set app         $syn_top
set cpu         "ps7_cortexa9_0"
set domain      "standalone_domain"
set dt_domain   "device_tree_domain"
set modules_dir [file normalize "modules"]
set project_dir [file normalize "project"]
set sdk_dir     [file normalize "$project_dir/$syn_top.sdk"]
set no_os_dir   [file normalize "no-OS"]

file delete -force $sdk_dir/SDK.log
file delete -force $sdk_dir/.metadata
file delete -force $sdk_dir/RemoteSystemsTempFiles
file delete -force $sdk_dir/$platform
file delete -force $sdk_dir/$domain
file delete -force $sdk_dir/$app
file delete -force $sdk_dir/$dt_domain

setws $sdk_dir

repo -set "device-tree-xlnx"

platform create -name $platform -hw $sdk_dir/$syn_top.xsa

domain create -name $domain -proc $cpu -os standalone
domain create -name $dt_domain -os device_tree -proc $cpu

platform generate

app create -name $app -domain $domain -platform $platform -template {Empty Application}

file copy -force $project_dir/$syn_top.runs/impl_1/$syn_top.bit $sdk_dir/$platform

set dac_dir     [glob -nocomplain -type d [file join $no_os_dir */axi_core/axi_dac_core]]
set adc_dir     [glob -nocomplain -type d [file join $no_os_dir */axi_core/axi_adc_core]]
set ad_dir      [glob -nocomplain -type d [file join $no_os_dir */rf-transceiver/ad9361]]
set xilinx_dir  [glob -nocomplain -type d [file join $no_os_dir */platform/xilinx]]
set drivers_dir [glob -nocomplain -type d [file join $no_os_dir */drivers/api]]
set include_dir [glob -nocomplain -type d [file join $no_os_dir */include]]

proc import_sources {app current_dir} {
    foreach sdk_path $current_dir  {
        if {[file isdirectory $sdk_path]} {
            puts "Current dir: $sdk_path"
            # configapp -app $app -add include-path $sdk_path
            importsources -name $app -path $sdk_path
        }
    }
}

import_sources $app $dac_dir
import_sources $app $adc_dir
import_sources $app $ad_dir
import_sources $app $xilinx_dir
import_sources $app $drivers_dir
import_sources $app $include_dir

app build -name $app
