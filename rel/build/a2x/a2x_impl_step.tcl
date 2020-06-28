#synth_design -top a2x_axi_bd_wrapper -part xcvu3p-ffvc1517-2-e -verbose
#source ila_axi.tcl
set version v0

write_checkpoint -force a2x_axi_synth_${version}.dcp

opt_design -retarget -propconst -bram_power_opt 
place_design -directive Explore
phys_opt_design -directive Explore
route_design -directive Explore
phys_opt_design -directive Explore
write_checkpoint -force a2x_axi_routed_${version}.dcp 

report_utilization -file  utilization_route_design_${version}.rpt
report_timing_summary -max_paths 100 -file timing_routed_summary_${version}.rpt

write_bitstream -force -bin_file a2x_axi_${version}
write_debug_probes -force a2x_axi_${version}
write_cfgmem -force -format BIN -interface SPIx8 -size 256 -loadbit "up 0 a2x_axi_${version}.bit" a2x_axi_${version}

