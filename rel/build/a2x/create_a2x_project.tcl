# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "./"

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Set the project name
set _xil_proj_name_ "proj_a2x_axi"

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set _xil_proj_name_ $::user_project_name
}

variable script_file
set script_file "create_a2x_project.tcl"

# Help information for this script
proc print_help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set _xil_proj_name_ [lindex $::argv $i] }
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"

# Create project
create_project ${_xil_proj_name_} -force "./proj" -part xcvu3p-ffvc1517-2-e

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "board_part" -value "" -objects $obj
set_property -name "compxlib.activehdl_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/activehdl" -objects $obj
set_property -name "compxlib.funcsim" -value "1" -objects $obj
set_property -name "compxlib.ies_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/ies" -objects $obj
set_property -name "compxlib.modelsim_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/modelsim" -objects $obj
set_property -name "compxlib.overwrite_libs" -value "0" -objects $obj
set_property -name "compxlib.questa_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/questa" -objects $obj
set_property -name "compxlib.riviera_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/riviera" -objects $obj
set_property -name "compxlib.timesim" -value "1" -objects $obj
set_property -name "compxlib.vcs_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/vcs" -objects $obj
set_property -name "compxlib.xsim_compiled_library_dir" -value "" -objects $obj
set_property -name "corecontainer.enable" -value "0" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "dsa.accelerator_binary_content" -value "bitstream" -objects $obj
set_property -name "dsa.accelerator_binary_format" -value "xclbin2" -objects $obj
set_property -name "dsa.description" -value "Vivado generated DSA" -objects $obj
set_property -name "dsa.dr_bd_base_address" -value "0" -objects $obj
set_property -name "dsa.emu_dir" -value "emu" -objects $obj
set_property -name "dsa.flash_interface_type" -value "bpix16" -objects $obj
set_property -name "dsa.flash_offset_address" -value "0" -objects $obj
set_property -name "dsa.flash_size" -value "1024" -objects $obj
set_property -name "dsa.host_architecture" -value "x86_64" -objects $obj
set_property -name "dsa.host_interface" -value "pcie" -objects $obj
set_property -name "dsa.num_compute_units" -value "60" -objects $obj
set_property -name "dsa.platform_state" -value "pre_synth" -objects $obj
set_property -name "dsa.rom.debug_type" -value "0" -objects $obj
set_property -name "dsa.rom.prom_type" -value "0" -objects $obj
set_property -name "dsa.vendor" -value "xilinx" -objects $obj
set_property -name "dsa.version" -value "0.0" -objects $obj
set_property -name "enable_optional_runs_sta" -value "0" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "generate_ip_upgrade_log" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_interface_inference_priority" -value "" -objects $obj
set_property -name "ip_output_repo" -value [file normalize "../ip_cache"] -objects $obj
set_property -name "legacy_ip_repo_paths" -value "" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "part" -value "xcvu3p-ffvc1517-2-e" -objects $obj
set_property -name "project_type" -value "Default" -objects $obj
set_property -name "pr_flow" -value "0" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "sim.use_ip_compiled_libs" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "source_mgmt_mode" -value "All" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj
set_property -name "target_simulator" -value "XSim" -objects $obj
set_property -name "tool_flow" -value "Vivado" -objects $obj
set_property -name "webtalk.activehdl_export_sim" -value "55" -objects $obj
set_property -name "webtalk.ies_export_sim" -value "55" -objects $obj
set_property -name "webtalk.modelsim_export_sim" -value "55" -objects $obj
set_property -name "webtalk.questa_export_sim" -value "55" -objects $obj
set_property -name "webtalk.riviera_export_sim" -value "55" -objects $obj
set_property -name "webtalk.vcs_export_sim" -value "55" -objects $obj
set_property -name "webtalk.xsim_export_sim" -value "55" -objects $obj
set_property -name "webtalk.xsim_launch_sim" -value "27" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_FIFO XPM_MEMORY" -objects $obj
set_property -name "xsim.array_display_limit" -value "1024" -objects $obj
set_property -name "xsim.radix" -value "hex" -objects $obj
set_property -name "xsim.time_unit" -value "ns" -objects $obj
set_property -name "xsim.trace_limit" -value "65536" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" [file normalize "../ip_repo"] $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Import local files from the original project
set files [list \
 [file normalize "${origin_dir}/bd/hdl/a2x_axi_bd_wrapper.v" ]\
]
set imported_files [import_files -fileset sources_1 $files]

# Set 'sources_1' fileset file properties for remote files
# None

# Set 'sources_1' fileset file properties for local files
set file "hdl/a2x_axi_bd_wrapper.v"
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "Verilog" -objects $file_obj
set_property -name "is_enabled" -value "1" -objects $file_obj
set_property -name "is_global_include" -value "0" -objects $file_obj
set_property -name "library" -value "xil_defaultlib" -objects $file_obj
set_property -name "path_mode" -value "RelativeFirst" -objects $file_obj
set_property -name "used_in" -value "synthesis implementation simulation" -objects $file_obj
set_property -name "used_in_implementation" -value "1" -objects $file_obj
set_property -name "used_in_simulation" -value "1" -objects $file_obj
set_property -name "used_in_synthesis" -value "1" -objects $file_obj


# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "design_mode" -value "RTL" -objects $obj
set_property -name "edif_extra_search_paths" -value "" -objects $obj
set_property -name "elab_link_dcps" -value "1" -objects $obj
set_property -name "elab_load_timing_constraints" -value "1" -objects $obj
set_property -name "generic" -value "" -objects $obj
set_property -name "include_dirs" -value "" -objects $obj
set_property -name "lib_map_file" -value "" -objects $obj
set_property -name "loop_count" -value "1000" -objects $obj
set_property -name "name" -value "sources_1" -objects $obj
set_property -name "top" -value "a2x_axi_bd_wrapper" -objects $obj
set_property -name "verilog_define" -value "" -objects $obj
set_property -name "verilog_uppercase" -value "0" -objects $obj
set_property -name "verilog_version" -value "verilog_2001" -objects $obj
set_property -name "vhdl_version" -value "vhdl_2k" -objects $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize ${origin_dir}/xdc/main_pinout.xdc]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/xdc/main_pinout.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "is_enabled" -value "1" -objects $file_obj
set_property -name "is_global_include" -value "0" -objects $file_obj
set_property -name "library" -value "xil_defaultlib" -objects $file_obj
set_property -name "path_mode" -value "RelativeFirst" -objects $file_obj
set_property -name "processing_order" -value "NORMAL" -objects $file_obj
set_property -name "scoped_to_cells" -value "" -objects $file_obj
set_property -name "scoped_to_ref" -value "" -objects $file_obj
set_property -name "used_in" -value "synthesis implementation" -objects $file_obj
set_property -name "used_in_implementation" -value "1" -objects $file_obj
set_property -name "used_in_synthesis" -value "1" -objects $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize ${origin_dir}/xdc/main_spi.xdc]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/xdc/main_spi.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "is_enabled" -value "1" -objects $file_obj
set_property -name "is_global_include" -value "0" -objects $file_obj
set_property -name "library" -value "xil_defaultlib" -objects $file_obj
set_property -name "path_mode" -value "RelativeFirst" -objects $file_obj
set_property -name "processing_order" -value "NORMAL" -objects $file_obj
set_property -name "scoped_to_cells" -value "" -objects $file_obj
set_property -name "scoped_to_ref" -value "" -objects $file_obj
set_property -name "used_in" -value "synthesis implementation" -objects $file_obj
set_property -name "used_in_implementation" -value "1" -objects $file_obj
set_property -name "used_in_synthesis" -value "1" -objects $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize ${origin_dir}/xdc/main_timing.xdc]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/xdc/main_timing.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "is_enabled" -value "1" -objects $file_obj
set_property -name "is_global_include" -value "0" -objects $file_obj
set_property -name "library" -value "xil_defaultlib" -objects $file_obj
set_property -name "path_mode" -value "RelativeFirst" -objects $file_obj
set_property -name "processing_order" -value "NORMAL" -objects $file_obj
set_property -name "scoped_to_cells" -value "" -objects $file_obj
set_property -name "scoped_to_ref" -value "" -objects $file_obj
set_property -name "used_in" -value "synthesis implementation" -objects $file_obj
set_property -name "used_in_implementation" -value "1" -objects $file_obj
set_property -name "used_in_synthesis" -value "1" -objects $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/xdc/main_extras.xdc"]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/xdc/main_extras.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "is_enabled" -value "1" -objects $file_obj
set_property -name "is_global_include" -value "0" -objects $file_obj
set_property -name "library" -value "xil_defaultlib" -objects $file_obj
set_property -name "path_mode" -value "RelativeFirst" -objects $file_obj
set_property -name "processing_order" -value "NORMAL" -objects $file_obj
set_property -name "scoped_to_cells" -value "" -objects $file_obj
set_property -name "scoped_to_ref" -value "" -objects $file_obj
set_property -name "used_in" -value "synthesis implementation" -objects $file_obj
set_property -name "used_in_implementation" -value "1" -objects $file_obj
set_property -name "used_in_synthesis" -value "1" -objects $file_obj

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property -name "constrs_type" -value "XDC" -objects $obj
set_property -name "name" -value "constrs_1" -objects $obj
set_property -name "target_constrs_file" -value [file normalize "xdc/main_extras.xdc"] -objects $obj
set_property -name "target_part" -value "xcvu3p-ffvc1517-2-e" -objects $obj
set_property -name "target_ucf" -value [file normalize "xdc/main_extras.xdc"] -objects $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property -name "32bit" -value "0" -objects $obj
set_property -name "generic" -value "" -objects $obj
set_property -name "include_dirs" -value "" -objects $obj
set_property -name "incremental" -value "1" -objects $obj
set_property -name "name" -value "sim_1" -objects $obj
set_property -name "nl.cell" -value "" -objects $obj
set_property -name "nl.incl_unisim_models" -value "0" -objects $obj
set_property -name "nl.mode" -value "funcsim" -objects $obj
set_property -name "nl.process_corner" -value "slow" -objects $obj
set_property -name "nl.rename_top" -value "" -objects $obj
set_property -name "nl.sdf_anno" -value "1" -objects $obj
set_property -name "nl.write_all_overrides" -value "0" -objects $obj
set_property -name "source_set" -value "sources_1" -objects $obj
set_property -name "systemc_include_dirs" -value "" -objects $obj
set_property -name "top" -value "a2x_axi_bd_wrapper" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj
set_property -name "transport_int_delay" -value "0" -objects $obj
set_property -name "transport_path_delay" -value "0" -objects $obj
set_property -name "verilog_define" -value "" -objects $obj
set_property -name "verilog_uppercase" -value "0" -objects $obj
set_property -name "xelab.dll" -value "0" -objects $obj
set_property -name "xsim.compile.tcl.pre" -value "" -objects $obj
set_property -name "xsim.compile.xsc.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvhdl.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvhdl.nosort" -value "1" -objects $obj
set_property -name "xsim.compile.xvhdl.relax" -value "1" -objects $obj
set_property -name "xsim.compile.xvlog.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvlog.nosort" -value "1" -objects $obj
set_property -name "xsim.compile.xvlog.relax" -value "1" -objects $obj
set_property -name "xsim.elaborate.debug_level" -value "typical" -objects $obj
set_property -name "xsim.elaborate.load_glbl" -value "1" -objects $obj
set_property -name "xsim.elaborate.mt_level" -value "auto" -objects $obj
set_property -name "xsim.elaborate.rangecheck" -value "0" -objects $obj
set_property -name "xsim.elaborate.relax" -value "1" -objects $obj
set_property -name "xsim.elaborate.sdf_delay" -value "sdfmax" -objects $obj
set_property -name "xsim.elaborate.snapshot" -value "" -objects $obj
set_property -name "xsim.elaborate.xelab.more_options" -value "" -objects $obj
set_property -name "xsim.elaborate.xsc.more_options" -value "" -objects $obj
set_property -name "xsim.simulate.add_positional" -value "0" -objects $obj
set_property -name "xsim.simulate.custom_tcl" -value "" -objects $obj
set_property -name "xsim.simulate.log_all_signals" -value "0" -objects $obj
set_property -name "xsim.simulate.no_quit" -value "0" -objects $obj
set_property -name "xsim.simulate.runtime" -value "1000ns" -objects $obj
set_property -name "xsim.simulate.saif" -value "" -objects $obj
set_property -name "xsim.simulate.saif_all_signals" -value "0" -objects $obj
set_property -name "xsim.simulate.saif_scope" -value "" -objects $obj
set_property -name "xsim.simulate.tcl.post" -value "" -objects $obj
set_property -name "xsim.simulate.wdb" -value "" -objects $obj
set_property -name "xsim.simulate.xsim.more_options" -value "" -objects $obj

# Set 'utils_1' fileset object
set obj [get_filesets utils_1]
# Empty (no sources present)

# Set 'utils_1' fileset properties
set obj [get_filesets utils_1]
set_property -name "name" -value "utils_1" -objects $obj


# Adding sources referenced in BDs, if not already added


# Proc to create BD a2x_axi_bd
proc cr_bd_a2x_axi_bd { parentCell } {

  # CHANGE DESIGN NAME HERE
  set design_name a2x_axi_bd

  common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  user.org:user:a2x_axi:1.0\
  user.org:user:a2x_axi_reg:1.0\
  user.org:user:a2x_dbug:1.0\
  user.org:user:a2x_reset:1.0\
  user.org:user:reverserator_3:1.0\
  user.org:user:reverserator_4:1.0\  
  user.org:user:reverserator_32:1.0\
  user.org:user:reverserator_64:1.0\
  xilinx.com:ip:axi_bram_ctrl:4.1\
  xilinx.com:ip:axi_protocol_checker:2.0\
  xilinx.com:ip:smartconnect:1.0\
  xilinx.com:ip:blk_mem_gen:8.4\
  xilinx.com:ip:clk_wiz:6.0\
  xilinx.com:ip:system_ila:1.1\
  xilinx.com:ip:jtag_axi:1.2\
  xilinx.com:ip:xlconstant:1.1\
  xilinx.com:ip:vio:3.0\
  "

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

  }

  if { $bCheckIPsPassed != 1 } {
    common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set clk_in1_n_0 [ create_bd_port -dir I -type clk clk_in1_n_0 ]
  set clk_in1_p_0 [ create_bd_port -dir I -type clk clk_in1_p_0 ]

  # Create instance: a2x_axi_1, and set properties
  set a2x_axi_1 [ create_bd_cell -type ip -vlnv user.org:user:a2x_axi:1.0 a2x_axi_1 ]

  # Create instance: a2x_axi_reg_0, and set properties
  set a2x_axi_reg_0 [ create_bd_cell -type ip -vlnv user.org:user:a2x_axi_reg:1.0 a2x_axi_reg_0 ]

  # Create instance: a2x_dbug, and set properties
  set a2x_dbug [ create_bd_cell -type ip -vlnv user.org:user:a2x_dbug:1.0 a2x_dbug ]

  # Create instance: a2x_reset_0, and set properties
  set a2x_reset_0 [ create_bd_cell -type ip -vlnv user.org:user:a2x_reset:1.0 a2x_reset_0 ]

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_1 ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_1

  # Create instance: axi_bram_ctrl_2, and set properties
  set axi_bram_ctrl_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_2 ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_2

  # Create instance: axi_protocol_checker, and set properties
  set axi_protocol_checker [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_checker:2.0 axi_protocol_checker ]
  set_property -dict [ list \
   CONFIG.ENABLE_CONTROL {1} \
   CONFIG.ENABLE_MARK_DEBUG {0} \
   CONFIG.HAS_SYSTEM_RESET {1} \
   CONFIG.MAX_RD_BURSTS {4} \
   CONFIG.MAX_WR_BURSTS {4} \
 ] $axi_protocol_checker

  # Create instance: axi_reg00_rv, and set properties
  set axi_reg00_rv [ create_bd_cell -type ip -vlnv user.org:user:reverserator_32:1.0 axi_reg00_rv ]

  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property -dict [ list \
   CONFIG.HAS_ARESETN {1} \
   CONFIG.NUM_MI {5} \
   CONFIG.NUM_SI {2} \
 ] $axi_smc

  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_1 ]

  # Create instance: blk_mem_gen_2, and set properties
  set blk_mem_gen_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_2 ]

  # Create instance: checkstop_rv, and set properties
  set checkstop_rv [ create_bd_cell -type ip -vlnv user.org:user:reverserator_3:1.0 checkstop_rv ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
   CONFIG.CLKOUT1_DRIVES {Buffer} \
   CONFIG.CLKOUT1_JITTER {143.207} \
   CONFIG.CLKOUT1_PHASE_ERROR {114.212} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100.000} \
   CONFIG.CLKOUT2_DRIVES {Buffer} \
   CONFIG.CLKOUT2_JITTER {125.285} \
   CONFIG.CLKOUT2_PHASE_ERROR {114.212} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_DRIVES {Buffer} \
   CONFIG.CLKOUT4_DRIVES {Buffer} \
   CONFIG.CLKOUT5_DRIVES {Buffer} \
   CONFIG.CLKOUT6_DRIVES {Buffer} \
   CONFIG.CLKOUT7_DRIVES {Buffer} \
   CONFIG.CLK_OUT1_PORT {clk} \
   CONFIG.CLK_OUT2_PORT {clk2x} \
   CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {8} \
   CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {8} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {4} \
   CONFIG.MMCM_COMPENSATION {AUTO} \
   CONFIG.MMCM_DIVCLK_DIVIDE {3} \
   CONFIG.NUM_OUT_CLKS {2} \
   CONFIG.PRIMITIVE {PLL} \
   CONFIG.PRIM_IN_FREQ {300.000} \
   CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
   CONFIG.RESET_PORT {resetn} \
   CONFIG.RESET_TYPE {ACTIVE_LOW} \
   CONFIG.USE_LOCKED {false} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: ila_axi, and set properties
  set ila_axi [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 ila_axi ]
  set_property -dict [ list \
   CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
   CONFIG.C_ADV_TRIGGER {true} \
   CONFIG.C_BRAM_CNT {48} \
   CONFIG.C_DATA_DEPTH {8192} \
   CONFIG.C_EN_STRG_QUAL {1} \
   CONFIG.C_INPUT_PIPE_STAGES {3} \
   CONFIG.C_PROBE0_MU_CNT {2} \
   CONFIG.C_SLOT_0_APC_EN {1} \
   CONFIG.C_SLOT_0_MAX_RD_BURSTS {8} \
   CONFIG.C_SLOT_0_MAX_WR_BURSTS {16} \
   CONFIG.C_TRIGIN_EN {true} \
   CONFIG.C_TRIGOUT_EN {true} \
 ] $ila_axi

  # Create instance: ila_axi_protocol, and set properties
  set ila_axi_protocol [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 ila_axi_protocol ]
  set_property -dict [ list \
   CONFIG.ALL_PROBE_SAME_MU_CNT {4} \
   CONFIG.C_BRAM_CNT {0.5} \
   CONFIG.C_DATA_DEPTH {2048} \
   CONFIG.C_EN_STRG_QUAL {1} \
   CONFIG.C_MON_TYPE {NATIVE} \
   CONFIG.C_NUM_MONITOR_SLOTS {2} \
   CONFIG.C_NUM_OF_PROBES {2} \
   CONFIG.C_PROBE0_MU_CNT {4} \
   CONFIG.C_PROBE1_MU_CNT {4} \
   CONFIG.C_TRIGIN_EN {false} \
   CONFIG.C_TRIGOUT_EN {true} \
 ] $ila_axi_protocol

  # Create instance: jtag_axi_0, and set properties
  set jtag_axi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi:1.2 jtag_axi_0 ]

  # Create instance: mchk_rv, and set properties
  set mchk_rv [ create_bd_cell -type ip -vlnv user.org:user:reverserator_4:1.0 mchk_rv ]

  # Create instance: pain, and set properties
  set pain [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 pain ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {1} \
 ] $pain

  # Create instance: rcov_rv, and set properties
  set rcov_rv [ create_bd_cell -type ip -vlnv user.org:user:reverserator_3:1.0 rcov_rv ]

  # Create instance: reverserator_4_0, and set properties
  set reverserator_4_0 [ create_bd_cell -type ip -vlnv user.org:user:reverserator_4:1.0 reverserator_4_0 ]

  # Create instance: scomdata_rv, and set properties
  set scomdata_rv [ create_bd_cell -type ip -vlnv user.org:user:reverserator_64:1.0 scomdata_rv ]

  # Create instance: thold_0, and set properties
  set thold_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 thold_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $thold_0

  # Create instance: thread_running_rv, and set properties
  set thread_running_rv [ create_bd_cell -type ip -vlnv user.org:user:reverserator_4:1.0 thread_running_rv ]

  # Create instance: vio_ctrl, and set properties
  set vio_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_ctrl ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_IN {16} \
   CONFIG.C_NUM_PROBE_OUT {17} \
   CONFIG.C_PROBE_OUT0_INIT_VAL {0xf} \
   CONFIG.C_PROBE_OUT0_WIDTH {4} \
   CONFIG.C_PROBE_OUT12_WIDTH {4} \
   CONFIG.C_PROBE_OUT13_WIDTH {4} \
   CONFIG.C_PROBE_OUT15_WIDTH {4} \
   CONFIG.C_PROBE_OUT1_INIT_VAL {0x1} \
   CONFIG.C_PROBE_OUT3_WIDTH {8} \
   CONFIG.C_PROBE_OUT4_WIDTH {4} \
   CONFIG.C_PROBE_OUT6_WIDTH {4} \
   CONFIG.C_PROBE_OUT7_WIDTH {4} \
   CONFIG.C_PROBE_OUT8_WIDTH {4} \
   CONFIG.C_PROBE_OUT9_INIT_VAL {0001} \
 ] $vio_ctrl

  # Create instance: vio_dbug, and set properties
  set vio_dbug [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_dbug ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_IN {3} \
   CONFIG.C_NUM_PROBE_OUT {5} \
   CONFIG.C_PROBE_OUT1_INIT_VAL {0x1} \
   CONFIG.C_PROBE_OUT2_WIDTH {4} \
   CONFIG.C_PROBE_OUT3_WIDTH {6} \
   CONFIG.C_PROBE_OUT4_WIDTH {64} \
 ] $vio_dbug

  # Create instance: vio_reg, and set properties
  set vio_reg [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_reg ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_IN {2} \
   CONFIG.C_NUM_PROBE_OUT {2} \
   CONFIG.C_PROBE_OUT0_INIT_VAL {00000000000000000000000000000000} \
   CONFIG.C_PROBE_OUT0_WIDTH {32} \
   CONFIG.C_PROBE_OUT1_INIT_VAL {00} \
   CONFIG.C_PROBE_OUT1_WIDTH {2} \
 ] $vio_reg

  # Create instance: vio_terror, and set properties
  set vio_terror [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_terror ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_IN {4} \
   CONFIG.C_NUM_PROBE_OUT {0} \
 ] $vio_terror

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {2} \
 ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {32} \
 ] $xlconstant_1

  # Create interface connections
  connect_bd_intf_net -intf_net a2x_axi_1_m00_axi [get_bd_intf_pins a2x_axi_1/m00_axi] [get_bd_intf_pins axi_smc/S00_AXI]
connect_bd_intf_net -intf_net [get_bd_intf_nets a2x_axi_1_m00_axi] [get_bd_intf_pins axi_protocol_checker/PC_AXI] [get_bd_intf_pins axi_smc/S00_AXI]
connect_bd_intf_net -intf_net [get_bd_intf_nets a2x_axi_1_m00_axi] [get_bd_intf_pins axi_smc/S00_AXI] [get_bd_intf_pins ila_axi/SLOT_0_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_2_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_2/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_2/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins a2x_axi_reg_0/s_axi_intr] [get_bd_intf_pins axi_smc/M00_AXI]
  connect_bd_intf_net -intf_net axi_smc_M01_AXI [get_bd_intf_pins axi_bram_ctrl_1/S_AXI] [get_bd_intf_pins axi_smc/M01_AXI]
  connect_bd_intf_net -intf_net axi_smc_M02_AXI [get_bd_intf_pins axi_bram_ctrl_2/S_AXI] [get_bd_intf_pins axi_smc/M02_AXI]
  connect_bd_intf_net -intf_net axi_smc_M03_AXI [get_bd_intf_pins a2x_axi_reg_0/s00_axi] [get_bd_intf_pins axi_smc/M03_AXI]
  connect_bd_intf_net -intf_net axi_smc_M04_AXI [get_bd_intf_pins axi_protocol_checker/S_AXI] [get_bd_intf_pins axi_smc/M04_AXI]
  connect_bd_intf_net -intf_net jtag_axi_0_M_AXI [get_bd_intf_pins axi_smc/S01_AXI] [get_bd_intf_pins jtag_axi_0/M_AXI]

  # Create port connections
  connect_bd_net -net a2l2_err_rv [get_bd_pins reverserator_4_0/outtie] [get_bd_pins vio_ctrl/probe_in14]
  connect_bd_net -net a2x_axi_1_a2l2_axi_err [get_bd_pins a2x_axi_1/a2l2_axi_err] [get_bd_pins reverserator_4_0/innnie]
  connect_bd_net -net a2x_axi_1_checkstop [get_bd_pins a2x_axi_1/checkstop] [get_bd_pins checkstop_rv/outdoor]
  connect_bd_net -net a2x_axi_1_scom_cch_out [get_bd_pins a2x_axi_1/scom_cch_out] [get_bd_pins a2x_dbug/cch_in]
  connect_bd_net -net a2x_axi_1_scom_dch_out [get_bd_pins a2x_axi_1/scom_dch_out] [get_bd_pins a2x_dbug/dch_in]
  connect_bd_net -net a2x_axi_1_thread_running [get_bd_pins a2x_axi_1/thread_running] [get_bd_pins thread_running_rv/innnie]
  connect_bd_net -net a2x_axi_reg_0_irq [get_bd_pins a2x_axi_reg_0/irq] [get_bd_pins vio_reg/probe_in0]
  connect_bd_net -net a2x_axi_reg_0_reg_out_00 [get_bd_pins a2x_axi_reg_0/reg_out_00] [get_bd_pins axi_reg00_rv/hell]
  connect_bd_net -net a2x_dbug_0_cch_out [get_bd_pins a2x_axi_1/scom_cch_in] [get_bd_pins a2x_dbug/cch_out]
  connect_bd_net -net a2x_dbug_0_dch_out [get_bd_pins a2x_axi_1/scom_dch_in] [get_bd_pins a2x_dbug/dch_out]
  connect_bd_net -net a2x_dbug_0_err [get_bd_pins a2x_dbug/err] [get_bd_pins vio_dbug/probe_in1]
  connect_bd_net -net a2x_dbug_0_rsp_valid [get_bd_pins a2x_dbug/rsp_valid] [get_bd_pins vio_dbug/probe_in0]
  connect_bd_net -net a2x_dbug_1_rsp_data [get_bd_pins a2x_dbug/rsp_data] [get_bd_pins scomdata_rv/parkavenue]
  connect_bd_net -net a2x_dbug_threadstop_out [get_bd_pins a2x_axi_1/thread_stop] [get_bd_pins a2x_dbug/threadstop_out]
  connect_bd_net -net a2x_dbug_trigger_out [get_bd_pins a2x_dbug/trigger_out] [get_bd_pins ila_axi/TRIG_IN_trig]
  connect_bd_net -net a2x_reset_0_reset [get_bd_pins a2x_axi_1/reset_n] [get_bd_pins a2x_axi_reg_0/s00_axi_aresetn] [get_bd_pins a2x_axi_reg_0/s_axi_intr_aresetn] [get_bd_pins a2x_dbug/reset_n] [get_bd_pins a2x_reset_0/reset] [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_2/s_axi_aresetn] [get_bd_pins axi_protocol_checker/aresetn] [get_bd_pins axi_smc/aresetn] [get_bd_pins ila_axi/resetn] [get_bd_pins jtag_axi_0/aresetn]
  connect_bd_net -net axi_protocol_checker_pc_asserted [get_bd_pins axi_protocol_checker/pc_asserted] [get_bd_pins ila_axi_protocol/probe1] [get_bd_pins vio_ctrl/probe_in0]
  connect_bd_net -net axi_protocol_checker_pc_status [get_bd_pins axi_protocol_checker/pc_status] [get_bd_pins ila_axi_protocol/probe0]
  connect_bd_net -net axi_reg00_rv [get_bd_pins axi_reg00_rv/cowboys] [get_bd_pins vio_reg/probe_in1]
  connect_bd_net -net checkstop_rv [get_bd_pins checkstop_rv/inndoor] [get_bd_pins vio_terror/probe_in2]
  connect_bd_net -net clk_in1_n_0_1 [get_bd_ports clk_in1_n_0] [get_bd_pins clk_wiz_0/clk_in1_n]
  connect_bd_net -net clk_in1_p_0_1 [get_bd_ports clk_in1_p_0] [get_bd_pins clk_wiz_0/clk_in1_p]
  connect_bd_net -net clk_wiz_0_clk [get_bd_pins a2x_axi_1/clk] [get_bd_pins a2x_axi_reg_0/s00_axi_aclk] [get_bd_pins a2x_axi_reg_0/s_axi_intr_aclk] [get_bd_pins a2x_dbug/clk] [get_bd_pins a2x_reset_0/clk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_bram_ctrl_2/s_axi_aclk] [get_bd_pins axi_protocol_checker/aclk] [get_bd_pins axi_smc/aclk] [get_bd_pins clk_wiz_0/clk] [get_bd_pins ila_axi/clk] [get_bd_pins ila_axi_protocol/clk] [get_bd_pins jtag_axi_0/aclk] [get_bd_pins vio_ctrl/clk] [get_bd_pins vio_dbug/clk] [get_bd_pins vio_reg/clk] [get_bd_pins vio_terror/clk]
  connect_bd_net -net clk_wiz_0_clk2x [get_bd_pins a2x_axi_1/clk2x] [get_bd_pins clk_wiz_0/clk2x]
  connect_bd_net -net ila_axi_protocol_TRIG_OUT_trig [get_bd_pins a2x_dbug/trigger_in] [get_bd_pins ila_axi_protocol/TRIG_OUT_trig] [get_bd_pins vio_ctrl/probe_in1]
  connect_bd_net -net marvio_probe_out0 [get_bd_pins a2x_dbug/threadstop_in] [get_bd_pins vio_ctrl/probe_out0]
  connect_bd_net -net marvio_probe_out2 [get_bd_pins ila_axi_protocol/TRIG_OUT_ack] [get_bd_pins vio_ctrl/probe_out2]
  connect_bd_net -net marvio_probe_out14 [get_bd_pins a2x_dbug/trigger_ack_enable] [get_bd_pins vio_ctrl/probe_out14]
  connect_bd_net -net marvio_probe_out15 [get_bd_pins a2x_dbug/trigger_threadstop] [get_bd_pins vio_ctrl/probe_out15]
  connect_bd_net -net marvio_probe_out16 [get_bd_pins a2x_axi_1/debug_stop] [get_bd_pins vio_ctrl/probe_out16]
  connect_bd_net -net mch [get_bd_pins a2x_axi_1/mchk] [get_bd_pins mchk_rv/innnie]
  connect_bd_net -net mchk_rv [get_bd_pins mchk_rv/outtie] [get_bd_pins vio_terror/probe_in0]
  connect_bd_net -net rcov_r [get_bd_pins a2x_axi_1/recov_err] [get_bd_pins rcov_rv/outdoor]
  connect_bd_net -net rcov_rv [get_bd_pins rcov_rv/inndoor] [get_bd_pins vio_terror/probe_in1]
  connect_bd_net -net scomdata_rv [get_bd_pins scomdata_rv/skidrowwww] [get_bd_pins vio_dbug/probe_in2]
  connect_bd_net -net thread_running_rv [get_bd_pins thread_running_rv/outtie] [get_bd_pins vio_ctrl/probe_in2]
  connect_bd_net -net unused_zero [get_bd_pins pain/dout] [get_bd_pins vio_ctrl/probe_in3] [get_bd_pins vio_ctrl/probe_in4] [get_bd_pins vio_ctrl/probe_in5] [get_bd_pins vio_ctrl/probe_in6] [get_bd_pins vio_ctrl/probe_in7] [get_bd_pins vio_ctrl/probe_in8] [get_bd_pins vio_ctrl/probe_in9] [get_bd_pins vio_ctrl/probe_in10] [get_bd_pins vio_ctrl/probe_in11] [get_bd_pins vio_ctrl/probe_in12] [get_bd_pins vio_ctrl/probe_in13] [get_bd_pins vio_ctrl/probe_in15] [get_bd_pins vio_terror/probe_in3]
  connect_bd_net -net vio_0_probe_out0 [get_bd_pins a2x_dbug/req_valid] [get_bd_pins vio_dbug/probe_out0]
  connect_bd_net -net vio_0_probe_out1 [get_bd_pins a2x_reset_0/reset_in] [get_bd_pins vio_ctrl/probe_out1]
  connect_bd_net -net vio_0_probe_out2 [get_bd_pins a2x_dbug/req_id] [get_bd_pins vio_dbug/probe_out2]
  connect_bd_net -net vio_0_probe_out3 [get_bd_pins a2x_axi_1/core_id] [get_bd_pins vio_ctrl/probe_out3]
  connect_bd_net -net vio_0_probe_out4 [get_bd_pins a2x_axi_1/ext_mchk] [get_bd_pins vio_ctrl/probe_out4]
  connect_bd_net -net vio_0_probe_out5 [get_bd_pins a2x_axi_1/ext_checkstop] [get_bd_pins vio_ctrl/probe_out5]
  connect_bd_net -net vio_0_probe_out6 [get_bd_pins a2x_axi_1/crit_interrupt] [get_bd_pins vio_ctrl/probe_out6]
  connect_bd_net -net vio_0_probe_out7 [get_bd_pins a2x_axi_1/ext_interrupt] [get_bd_pins vio_ctrl/probe_out7]
  connect_bd_net -net vio_0_probe_out8 [get_bd_pins a2x_axi_1/perf_interrupt] [get_bd_pins vio_ctrl/probe_out8]
  connect_bd_net -net vio_0_probe_out9 [get_bd_pins a2x_axi_1/tb_update_enable] [get_bd_pins vio_ctrl/probe_out9]
  connect_bd_net -net vio_0_probe_out10 [get_bd_pins a2x_axi_1/tb_update_pulse] [get_bd_pins vio_ctrl/probe_out10]
  connect_bd_net -net vio_0_probe_out11 [get_bd_pins a2x_axi_1/flh2l2_gate] [get_bd_pins vio_ctrl/probe_out11]
  connect_bd_net -net vio_0_probe_out12 [get_bd_pins a2x_axi_1/hang_pulse] [get_bd_pins vio_ctrl/probe_out12]
  connect_bd_net -net vio_0_probe_out13 [get_bd_pins a2x_axi_1/scom_sat_id] [get_bd_pins vio_ctrl/probe_out13]
  connect_bd_net -net vio_0_probe_out14 [get_bd_pins a2x_dbug/req_wr_data] [get_bd_pins vio_dbug/probe_out4]
  connect_bd_net -net vio_0_probe_out15 [get_bd_pins a2x_dbug/req_addr] [get_bd_pins vio_dbug/probe_out3]
  connect_bd_net -net vio_0_probe_out16 [get_bd_pins a2x_dbug/req_rw] [get_bd_pins vio_dbug/probe_out1]
  connect_bd_net -net vio_0_probe_out17 [get_bd_pins a2x_axi_reg_0/reg_in_00] [get_bd_pins vio_reg/probe_out0]
  connect_bd_net -net vio_0_probe_out18 [get_bd_pins a2x_axi_reg_0/reg_cmd_00] [get_bd_pins vio_reg/probe_out1]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins a2x_axi_reg_0/reg_cmd_01] [get_bd_pins a2x_axi_reg_0/reg_cmd_02] [get_bd_pins a2x_axi_reg_0/reg_cmd_03] [get_bd_pins a2x_axi_reg_0/reg_cmd_04] [get_bd_pins a2x_axi_reg_0/reg_cmd_05] [get_bd_pins a2x_axi_reg_0/reg_cmd_06] [get_bd_pins a2x_axi_reg_0/reg_cmd_07] [get_bd_pins a2x_axi_reg_0/reg_cmd_08] [get_bd_pins a2x_axi_reg_0/reg_cmd_09] [get_bd_pins a2x_axi_reg_0/reg_cmd_0A] [get_bd_pins a2x_axi_reg_0/reg_cmd_0B] [get_bd_pins a2x_axi_reg_0/reg_cmd_0C] [get_bd_pins a2x_axi_reg_0/reg_cmd_0D] [get_bd_pins a2x_axi_reg_0/reg_cmd_0E] [get_bd_pins a2x_axi_reg_0/reg_cmd_0F] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins a2x_axi_reg_0/reg_in_01] [get_bd_pins a2x_axi_reg_0/reg_in_02] [get_bd_pins a2x_axi_reg_0/reg_in_03] [get_bd_pins a2x_axi_reg_0/reg_in_04] [get_bd_pins a2x_axi_reg_0/reg_in_05] [get_bd_pins a2x_axi_reg_0/reg_in_06] [get_bd_pins a2x_axi_reg_0/reg_in_07] [get_bd_pins a2x_axi_reg_0/reg_in_08] [get_bd_pins a2x_axi_reg_0/reg_in_09] [get_bd_pins a2x_axi_reg_0/reg_in_0A] [get_bd_pins a2x_axi_reg_0/reg_in_0B] [get_bd_pins a2x_axi_reg_0/reg_in_0C] [get_bd_pins a2x_axi_reg_0/reg_in_0D] [get_bd_pins a2x_axi_reg_0/reg_in_0E] [get_bd_pins a2x_axi_reg_0/reg_in_0F] [get_bd_pins xlconstant_1/dout]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins a2x_axi_1/thold] [get_bd_pins thold_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00001000 -offset 0xFFFFE000 [get_bd_addr_spaces a2x_axi_1/m00_axi] [get_bd_addr_segs a2x_axi_reg_0/s_axi_intr/reg0] SEG_a2x_axi_reg_0_reg0
  create_bd_addr_seg -range 0x00001000 -offset 0xFFFFF000 [get_bd_addr_spaces a2x_axi_1/m00_axi] [get_bd_addr_segs a2x_axi_reg_0/s00_axi/reg0] SEG_a2x_axi_reg_0_reg01
  create_bd_addr_seg -range 0x00040000 -offset 0x00000000 [get_bd_addr_spaces a2x_axi_1/m00_axi] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x00100000 -offset 0x10000000 [get_bd_addr_spaces a2x_axi_1/m00_axi] [get_bd_addr_segs axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0xFE000000 [get_bd_addr_spaces a2x_axi_1/m00_axi] [get_bd_addr_segs axi_protocol_checker/S_AXI/Reg] SEG_axi_protocol_checker_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0xFFFFE000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs a2x_axi_reg_0/s_axi_intr/reg0] SEG_a2x_axi_reg_0_reg0
  create_bd_addr_seg -range 0x00001000 -offset 0xFFFFF000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs a2x_axi_reg_0/s00_axi/reg0] SEG_a2x_axi_reg_0_reg03
  create_bd_addr_seg -range 0x00040000 -offset 0x00000000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x00100000 -offset 0x10000000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0xFE000000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs axi_protocol_checker/S_AXI/Reg] SEG_axi_protocol_checker_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_a2x_axi_bd()
cr_bd_a2x_axi_bd ""
set_property EXCLUDE_DEBUG_LOGIC "0" [get_files a2x_axi_bd.bd ] 
set_property GENERATE_SYNTH_CHECKPOINT "0" [get_files a2x_axi_bd.bd ] 
set_property IS_ENABLED "1" [get_files a2x_axi_bd.bd ] 
set_property IS_GLOBAL_INCLUDE "0" [get_files a2x_axi_bd.bd ] 
set_property IS_LOCKED "0" [get_files a2x_axi_bd.bd ] 
set_property LIBRARY "xil_defaultlib" [get_files a2x_axi_bd.bd ] 
set_property PATH_MODE "RelativeFirst" [get_files a2x_axi_bd.bd ] 
set_property PFM_NAME "" [get_files a2x_axi_bd.bd ] 
set_property REGISTERED_WITH_MANAGER "1" [get_files a2x_axi_bd.bd ] 
set_property SYNTH_CHECKPOINT_MODE "None" [get_files a2x_axi_bd.bd ] 
set_property USED_IN "synthesis implementation simulation" [get_files a2x_axi_bd.bd ] 
set_property USED_IN_IMPLEMENTATION "1" [get_files a2x_axi_bd.bd ] 
set_property USED_IN_SIMULATION "1" [get_files a2x_axi_bd.bd ] 
set_property USED_IN_SYNTHESIS "1" [get_files a2x_axi_bd.bd ] 

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part xcvu3p-ffvc1517-2-e -flow {Vivado Synthesis 2019} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2019" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'synth_1_synth_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0] "" ] } {
  create_report_config -report_name synth_1_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs synth_1
}
set obj [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.pblocks" -value "" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.slr" -value "0" -objects $obj
set_property -name "options.packthru" -value "0" -objects $obj
set_property -name "options.hierarchical" -value "0" -objects $obj
set_property -name "options.hierarchical_depth" -value "" -objects $obj
set_property -name "options.hierarchical_percentages" -value "0" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
set obj [get_runs synth_1]
set_property -name "constrset" -value "constrs_1" -objects $obj
set_property -name "description" -value "Vivado Synthesis Defaults" -objects $obj
set_property -name "flow" -value "Vivado Synthesis 2019" -objects $obj
set_property -name "name" -value "synth_1" -objects $obj
set_property -name "needs_refresh" -value "0" -objects $obj
set_property -name "part" -value "xcvu3p-ffvc1517-2-e" -objects $obj
set_property -name "srcset" -value "sources_1" -objects $obj
set_property -name "auto_incremental_checkpoint" -value "0" -objects $obj
set_property -name "incremental_checkpoint" -value "" -objects $obj
set_property -name "incremental_checkpoint.more_options" -value "" -objects $obj
set_property -name "include_in_archive" -value "1" -objects $obj
set_property -name "gen_full_bitstream" -value "1" -objects $obj
set_property -name "write_incremental_synth_checkpoint" -value "0" -objects $obj
set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj
set_property -name "steps.synth_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.synth_design.tcl.post" -value "" -objects $obj
set_property -name "steps.synth_design.args.flatten_hierarchy" -value "rebuilt" -objects $obj
set_property -name "steps.synth_design.args.gated_clock_conversion" -value "off" -objects $obj
set_property -name "steps.synth_design.args.bufg" -value "12" -objects $obj
set_property -name "steps.synth_design.args.fanout_limit" -value "10000" -objects $obj
set_property -name "steps.synth_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.synth_design.args.retiming" -value "0" -objects $obj
set_property -name "steps.synth_design.args.fsm_extraction" -value "auto" -objects $obj
set_property -name "steps.synth_design.args.keep_equivalent_registers" -value "0" -objects $obj
set_property -name "steps.synth_design.args.resource_sharing" -value "auto" -objects $obj
set_property -name "steps.synth_design.args.control_set_opt_threshold" -value "auto" -objects $obj
set_property -name "steps.synth_design.args.no_lc" -value "0" -objects $obj
set_property -name "steps.synth_design.args.no_srlextract" -value "0" -objects $obj
set_property -name "steps.synth_design.args.shreg_min_size" -value "3" -objects $obj
set_property -name "steps.synth_design.args.max_bram" -value "-1" -objects $obj
set_property -name "steps.synth_design.args.max_uram" -value "-1" -objects $obj
set_property -name "steps.synth_design.args.max_dsp" -value "-1" -objects $obj
set_property -name "steps.synth_design.args.max_bram_cascade_height" -value "-1" -objects $obj
set_property -name "steps.synth_design.args.max_uram_cascade_height" -value "-1" -objects $obj
set_property -name "steps.synth_design.args.cascade_dsp" -value "auto" -objects $obj
set_property -name "steps.synth_design.args.assert" -value "0" -objects $obj
set_property -name "steps.synth_design.args.more options" -value "-verbose" -objects $obj

# Create 'synth_2' run (if not found)
if {[string equal [get_runs -quiet synth_2] ""]} {
    create_run -name synth_2 -part xcvu3p-ffvc1517-2-e -flow {Vivado Synthesis 2019} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_2]
  set_property flow "Vivado Synthesis 2019" [get_runs synth_2]
}
set obj [get_runs synth_2]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'synth_2_synth_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs synth_2] synth_2_synth_report_utilization_0] "" ] } {
  create_report_config -report_name synth_2_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs synth_2
}
set obj [get_report_configs -of_objects [get_runs synth_2] synth_2_synth_report_utilization_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.pblocks" -value "" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.slr" -value "0" -objects $obj
set_property -name "options.packthru" -value "0" -objects $obj
set_property -name "options.hierarchical" -value "0" -objects $obj
set_property -name "options.hierarchical_depth" -value "" -objects $obj
set_property -name "options.hierarchical_percentages" -value "0" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
set obj [get_runs synth_2]
set_property -name "constrset" -value "constrs_1" -objects $obj
set_property -name "description" -value "Vivado Synthesis Defaults" -objects $obj
set_property -name "flow" -value "Vivado Synthesis 2019" -objects $obj
set_property -name "name" -value "synth_2" -objects $obj
set_property -name "needs_refresh" -value "0" -objects $obj
set_property -name "part" -value "xcvu3p-ffvc1517-2-e" -objects $obj
set_property -name "srcset" -value "sources_1" -objects $obj
set_property -name "auto_incremental_checkpoint" -value "0" -objects $obj
set_property -name "incremental_checkpoint" -value "" -objects $obj
set_property -name "incremental_checkpoint.more_options" -value "" -objects $obj
set_property -name "include_in_archive" -value "1" -objects $obj
set_property -name "gen_full_bitstream" -value "1" -objects $obj
set_property -name "write_incremental_synth_checkpoint" -value "0" -objects $obj
set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj
set_property -name "steps.synth_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.synth_design.tcl.post" -value "" -objects $obj
set_property -name "steps.synth_design.args.flatten_hierarchy" -value "none" -objects $obj
set_property -name "steps.synth_design.args.gated_clock_conversion" -value "off" -objects $obj
set_property -name "steps.synth_design.args.bufg" -value "12" -objects $obj
set_property -name "steps.synth_design.args.fanout_limit" -value "10000" -objects $obj
set_property -name "steps.synth_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.synth_design.args.retiming" -value "0" -objects $obj
set_property -name "steps.synth_design.args.fsm_extraction" -value "auto" -objects $obj
set_property -name "steps.synth_design.args.keep_equivalent_registers" -value "0" -objects $obj
set_property -name "steps.synth_design.args.resource_sharing" -value "auto" -objects $obj
set_property -name "steps.synth_design.args.control_set_opt_threshold" -value "auto" -objects $obj
set_property -name "steps.synth_design.args.no_lc" -value "0" -objects $obj
set_property -name "steps.synth_design.args.no_srlextract" -value "0" -objects $obj
set_property -name "steps.synth_design.args.shreg_min_size" -value "3" -objects $obj
set_property -name "steps.synth_design.args.max_bram" -value "-1" -objects $obj
set_property -name "steps.synth_design.args.max_uram" -value "-1" -objects $obj
set_property -name "steps.synth_design.args.max_dsp" -value "-1" -objects $obj
set_property -name "steps.synth_design.args.max_bram_cascade_height" -value "-1" -objects $obj
set_property -name "steps.synth_design.args.max_uram_cascade_height" -value "-1" -objects $obj
set_property -name "steps.synth_design.args.cascade_dsp" -value "auto" -objects $obj
set_property -name "steps.synth_design.args.assert" -value "0" -objects $obj
set_property -name "steps.synth_design.args.more options" -value "-verbose" -objects $obj

# set the current synth run
current_run -synthesis [get_runs synth_2]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part xcvu3p-ffvc1517-2-e -flow {Vivado Implementation 2019} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2019" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'impl_1_init_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_init_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_init_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps init_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_init_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_opt_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_drc_0] "" ] } {
  create_report_config -report_name impl_1_opt_report_drc_0 -report_type report_drc:1.0 -steps opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_drc_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.upgrade_cw" -value "0" -objects $obj
set_property -name "options.checks" -value "" -objects $obj
set_property -name "options.ruledecks" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps power_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_place_report_io_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_io_0] "" ] } {
  create_report_config -report_name impl_1_place_report_io_0 -report_type report_io:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_io_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_place_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_utilization_0] "" ] } {
  create_report_config -report_name impl_1_place_report_utilization_0 -report_type report_utilization:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_utilization_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.pblocks" -value "" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.slr" -value "0" -objects $obj
set_property -name "options.packthru" -value "0" -objects $obj
set_property -name "options.hierarchical" -value "0" -objects $obj
set_property -name "options.hierarchical_depth" -value "" -objects $obj
set_property -name "options.hierarchical_percentages" -value "0" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_place_report_control_sets_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_control_sets_0] "" ] } {
  create_report_config -report_name impl_1_place_report_control_sets_0 -report_type report_control_sets:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_control_sets_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.verbose" -value "1" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_place_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name impl_1_place_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.hierarchical" -value "0" -objects $obj
set_property -name "options.hierarchical_depth" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_place_report_incremental_reuse_1' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_1] "" ] } {
  create_report_config -report_name impl_1_place_report_incremental_reuse_1 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_1]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.hierarchical" -value "0" -objects $obj
set_property -name "options.hierarchical_depth" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_place_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_place_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_post_place_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_place_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_post_place_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_place_power_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_place_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_route_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_drc_0] "" ] } {
  create_report_config -report_name impl_1_route_report_drc_0 -report_type report_drc:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_drc_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.upgrade_cw" -value "0" -objects $obj
set_property -name "options.checks" -value "" -objects $obj
set_property -name "options.ruledecks" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_route_report_methodology_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_methodology_0] "" ] } {
  create_report_config -report_name impl_1_route_report_methodology_0 -report_type report_methodology:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_methodology_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.checks" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_route_report_power_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_power_0] "" ] } {
  create_report_config -report_name impl_1_route_report_power_0 -report_type report_power:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_power_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.advisory" -value "0" -objects $obj
set_property -name "options.xpe" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_route_report_route_status_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_route_status_0] "" ] } {
  create_report_config -report_name impl_1_route_report_route_status_0 -report_type report_route_status:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_route_status_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.of_objects" -value "" -objects $obj
set_property -name "options.route_type" -value "" -objects $obj
set_property -name "options.list_all_nets" -value "0" -objects $obj
set_property -name "options.show_all" -value "0" -objects $obj
set_property -name "options.has_routing" -value "0" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_route_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_route_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_route_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name impl_1_route_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_incremental_reuse_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.hierarchical" -value "0" -objects $obj
set_property -name "options.hierarchical_depth" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_route_report_clock_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_clock_utilization_0] "" ] } {
  create_report_config -report_name impl_1_route_report_clock_utilization_0 -report_type report_clock_utilization:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_clock_utilization_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.write_xdc" -value "0" -objects $obj
set_property -name "options.clock_roots_only" -value "0" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_route_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_1_route_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_bus_skew_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.slack_greater_than" -value "" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_post_route_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_post_route_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_1_post_route_phys_opt_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_1_post_route_phys_opt_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_bus_skew_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.slack_greater_than" -value "" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
set obj [get_runs impl_1]
set_property -name "constrset" -value "constrs_1" -objects $obj
set_property -name "description" -value "Default settings for Implementation." -objects $obj
set_property -name "flow" -value "Vivado Implementation 2019" -objects $obj
set_property -name "name" -value "impl_1" -objects $obj
set_property -name "needs_refresh" -value "0" -objects $obj
set_property -name "part" -value "xcvu3p-ffvc1517-2-e" -objects $obj
set_property -name "pr_configuration" -value "" -objects $obj
set_property -name "srcset" -value "sources_1" -objects $obj
set_property -name "auto_incremental_checkpoint" -value "0" -objects $obj
set_property -name "incremental_checkpoint" -value "" -objects $obj
set_property -name "incremental_checkpoint.more_options" -value "" -objects $obj
set_property -name "include_in_archive" -value "1" -objects $obj
set_property -name "gen_full_bitstream" -value "1" -objects $obj
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.init_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.init_design.tcl.post" -value "" -objects $obj
set_property -name "steps.opt_design.is_enabled" -value "1" -objects $obj
set_property -name "steps.opt_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.opt_design.tcl.post" -value "" -objects $obj
set_property -name "steps.opt_design.args.verbose" -value "0" -objects $obj
set_property -name "steps.opt_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.opt_design.args.more options" -value "" -objects $obj
set_property -name "steps.power_opt_design.is_enabled" -value "0" -objects $obj
set_property -name "steps.power_opt_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.power_opt_design.tcl.post" -value "" -objects $obj
set_property -name "steps.power_opt_design.args.more options" -value "" -objects $obj
set_property -name "steps.place_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.place_design.tcl.post" -value "" -objects $obj
set_property -name "steps.place_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.place_design.args.more options" -value "" -objects $obj
set_property -name "steps.post_place_power_opt_design.is_enabled" -value "0" -objects $obj
set_property -name "steps.post_place_power_opt_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.post_place_power_opt_design.tcl.post" -value "" -objects $obj
set_property -name "steps.post_place_power_opt_design.args.more options" -value "" -objects $obj
set_property -name "steps.phys_opt_design.is_enabled" -value "0" -objects $obj
set_property -name "steps.phys_opt_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.phys_opt_design.tcl.post" -value "" -objects $obj
set_property -name "steps.phys_opt_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.phys_opt_design.args.more options" -value "" -objects $obj
set_property -name "steps.route_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.route_design.tcl.post" -value "" -objects $obj
set_property -name "steps.route_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.route_design.args.more options" -value "" -objects $obj
set_property -name "steps.post_route_phys_opt_design.is_enabled" -value "0" -objects $obj
set_property -name "steps.post_route_phys_opt_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.post_route_phys_opt_design.tcl.post" -value "" -objects $obj
set_property -name "steps.post_route_phys_opt_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.post_route_phys_opt_design.args.more options" -value "" -objects $obj
set_property -name "steps.write_bitstream.tcl.pre" -value "" -objects $obj
set_property -name "steps.write_bitstream.tcl.post" -value "" -objects $obj
set_property -name "steps.write_bitstream.args.raw_bitfile" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.mask_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.no_binary_bitfile" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.bin_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.logic_location_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.more options" -value "" -objects $obj

# Create 'impl_2' run (if not found)
if {[string equal [get_runs -quiet impl_2] ""]} {
    create_run -name impl_2 -part xcvu3p-ffvc1517-2-e -flow {Vivado Implementation 2019} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_2
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_2]
  set_property flow "Vivado Implementation 2019" [get_runs impl_2]
}
set obj [get_runs impl_2]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'impl_2_init_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_init_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_2_init_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps init_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_init_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_opt_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_opt_report_drc_0] "" ] } {
  create_report_config -report_name impl_2_opt_report_drc_0 -report_type report_drc:1.0 -steps opt_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_opt_report_drc_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.upgrade_cw" -value "0" -objects $obj
set_property -name "options.checks" -value "" -objects $obj
set_property -name "options.ruledecks" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_2_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps opt_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_2_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps power_opt_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_place_report_io_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_io_0] "" ] } {
  create_report_config -report_name impl_2_place_report_io_0 -report_type report_io:1.0 -steps place_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_io_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_place_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_utilization_0] "" ] } {
  create_report_config -report_name impl_2_place_report_utilization_0 -report_type report_utilization:1.0 -steps place_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_utilization_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.pblocks" -value "" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.slr" -value "0" -objects $obj
set_property -name "options.packthru" -value "0" -objects $obj
set_property -name "options.hierarchical" -value "0" -objects $obj
set_property -name "options.hierarchical_depth" -value "" -objects $obj
set_property -name "options.hierarchical_percentages" -value "0" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_place_report_control_sets_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_control_sets_0] "" ] } {
  create_report_config -report_name impl_2_place_report_control_sets_0 -report_type report_control_sets:1.0 -steps place_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_control_sets_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.verbose" -value "1" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_place_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name impl_2_place_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_incremental_reuse_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.hierarchical" -value "0" -objects $obj
set_property -name "options.hierarchical_depth" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_place_report_incremental_reuse_1' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_incremental_reuse_1] "" ] } {
  create_report_config -report_name impl_2_place_report_incremental_reuse_1 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_incremental_reuse_1]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.hierarchical" -value "0" -objects $obj
set_property -name "options.hierarchical_depth" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_place_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_2_place_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps place_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_place_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_post_place_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_post_place_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_2_post_place_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_place_power_opt_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_post_place_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_2_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps phys_opt_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_route_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_drc_0] "" ] } {
  create_report_config -report_name impl_2_route_report_drc_0 -report_type report_drc:1.0 -steps route_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_drc_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.upgrade_cw" -value "0" -objects $obj
set_property -name "options.checks" -value "" -objects $obj
set_property -name "options.ruledecks" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_route_report_methodology_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_methodology_0] "" ] } {
  create_report_config -report_name impl_2_route_report_methodology_0 -report_type report_methodology:1.0 -steps route_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_methodology_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.checks" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_route_report_power_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_power_0] "" ] } {
  create_report_config -report_name impl_2_route_report_power_0 -report_type report_power:1.0 -steps route_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_power_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.advisory" -value "0" -objects $obj
set_property -name "options.xpe" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_route_report_route_status_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_route_status_0] "" ] } {
  create_report_config -report_name impl_2_route_report_route_status_0 -report_type report_route_status:1.0 -steps route_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_route_status_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.of_objects" -value "" -objects $obj
set_property -name "options.route_type" -value "" -objects $obj
set_property -name "options.list_all_nets" -value "0" -objects $obj
set_property -name "options.show_all" -value "0" -objects $obj
set_property -name "options.has_routing" -value "0" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_route_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_2_route_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps route_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "0" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_route_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name impl_2_route_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps route_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_incremental_reuse_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.cells" -value "" -objects $obj
set_property -name "options.hierarchical" -value "0" -objects $obj
set_property -name "options.hierarchical_depth" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_route_report_clock_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_clock_utilization_0] "" ] } {
  create_report_config -report_name impl_2_route_report_clock_utilization_0 -report_type report_clock_utilization:1.0 -steps route_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_clock_utilization_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.write_xdc" -value "0" -objects $obj
set_property -name "options.clock_roots_only" -value "0" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_route_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_2_route_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps route_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_route_report_bus_skew_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.slack_greater_than" -value "" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_post_route_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_post_route_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_2_post_route_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_route_phys_opt_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_post_route_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.check_timing_verbose" -value "0" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.report_unconstrained" -value "0" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.cell" -value "" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
# Create 'impl_2_post_route_phys_opt_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_2] impl_2_post_route_phys_opt_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_2_post_route_phys_opt_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps post_route_phys_opt_design -runs impl_2
}
set obj [get_report_configs -of_objects [get_runs impl_2] impl_2_post_route_phys_opt_report_bus_skew_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "1" -objects $obj
set_property -name "options.delay_type" -value "" -objects $obj
set_property -name "options.setup" -value "0" -objects $obj
set_property -name "options.hold" -value "0" -objects $obj
set_property -name "options.max_paths" -value "" -objects $obj
set_property -name "options.nworst" -value "" -objects $obj
set_property -name "options.unique_pins" -value "0" -objects $obj
set_property -name "options.path_type" -value "" -objects $obj
set_property -name "options.slack_lesser_than" -value "" -objects $obj
set_property -name "options.slack_greater_than" -value "" -objects $obj
set_property -name "options.significant_digits" -value "" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj
set_property -name "options.more_options" -value "" -objects $obj

}
set obj [get_runs impl_2]
set_property -name "constrset" -value "constrs_1" -objects $obj
set_property -name "description" -value "Default settings for Implementation." -objects $obj
set_property -name "flow" -value "Vivado Implementation 2019" -objects $obj
set_property -name "name" -value "impl_2" -objects $obj
set_property -name "needs_refresh" -value "0" -objects $obj
set_property -name "part" -value "xcvu3p-ffvc1517-2-e" -objects $obj
set_property -name "pr_configuration" -value "" -objects $obj
set_property -name "srcset" -value "sources_1" -objects $obj
set_property -name "auto_incremental_checkpoint" -value "0" -objects $obj
set_property -name "incremental_checkpoint" -value "" -objects $obj
set_property -name "incremental_checkpoint.more_options" -value "" -objects $obj
set_property -name "include_in_archive" -value "1" -objects $obj
set_property -name "gen_full_bitstream" -value "1" -objects $obj
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.init_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.init_design.tcl.post" -value "" -objects $obj
set_property -name "steps.opt_design.is_enabled" -value "1" -objects $obj
set_property -name "steps.opt_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.opt_design.tcl.post" -value "" -objects $obj
set_property -name "steps.opt_design.args.verbose" -value "0" -objects $obj
set_property -name "steps.opt_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.opt_design.args.more options" -value "" -objects $obj
set_property -name "steps.power_opt_design.is_enabled" -value "0" -objects $obj
set_property -name "steps.power_opt_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.power_opt_design.tcl.post" -value "" -objects $obj
set_property -name "steps.power_opt_design.args.more options" -value "" -objects $obj
set_property -name "steps.place_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.place_design.tcl.post" -value "" -objects $obj
set_property -name "steps.place_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.place_design.args.more options" -value "" -objects $obj
set_property -name "steps.post_place_power_opt_design.is_enabled" -value "0" -objects $obj
set_property -name "steps.post_place_power_opt_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.post_place_power_opt_design.tcl.post" -value "" -objects $obj
set_property -name "steps.post_place_power_opt_design.args.more options" -value "" -objects $obj
set_property -name "steps.phys_opt_design.is_enabled" -value "0" -objects $obj
set_property -name "steps.phys_opt_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.phys_opt_design.tcl.post" -value "" -objects $obj
set_property -name "steps.phys_opt_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.phys_opt_design.args.more options" -value "" -objects $obj
set_property -name "steps.route_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.route_design.tcl.post" -value "" -objects $obj
set_property -name "steps.route_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.route_design.args.more options" -value "" -objects $obj
set_property -name "steps.post_route_phys_opt_design.is_enabled" -value "0" -objects $obj
set_property -name "steps.post_route_phys_opt_design.tcl.pre" -value "" -objects $obj
set_property -name "steps.post_route_phys_opt_design.tcl.post" -value "" -objects $obj
set_property -name "steps.post_route_phys_opt_design.args.directive" -value "Default" -objects $obj
set_property -name "steps.post_route_phys_opt_design.args.more options" -value "" -objects $obj
set_property -name "steps.write_bitstream.tcl.pre" -value "" -objects $obj
set_property -name "steps.write_bitstream.tcl.post" -value "" -objects $obj
set_property -name "steps.write_bitstream.args.raw_bitfile" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.mask_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.no_binary_bitfile" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.bin_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.logic_location_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.more options" -value "" -objects $obj

# set the current impl run
current_run -implementation [get_runs impl_2]

puts "INFO: Project created:${_xil_proj_name_}"
# Create 'drc_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "drc_1" ] ] ""]} {
create_dashboard_gadget -name {drc_1} -type drc
}
set obj [get_dashboard_gadgets [ list "drc_1" ] ]
set_property -name "active_reports" -value "" -objects $obj
set_property -name "active_reports_invalid" -value "" -objects $obj
set_property -name "active_run" -value "0" -objects $obj
set_property -name "hide_unused_data" -value "1" -objects $obj
set_property -name "incl_new_reports" -value "0" -objects $obj
set_property -name "reports" -value "" -objects $obj
set_property -name "run.step" -value "route_design" -objects $obj
set_property -name "run.type" -value "implementation" -objects $obj
set_property -name "statistics.critical_warning" -value "1" -objects $obj
set_property -name "statistics.error" -value "1" -objects $obj
set_property -name "statistics.info" -value "1" -objects $obj
set_property -name "statistics.warning" -value "1" -objects $obj
set_property -name "view.orientation" -value "Horizontal" -objects $obj
set_property -name "view.type" -value "Graph" -objects $obj

# Create 'methodology_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "methodology_1" ] ] ""]} {
create_dashboard_gadget -name {methodology_1} -type methodology
}
set obj [get_dashboard_gadgets [ list "methodology_1" ] ]
set_property -name "active_reports" -value "" -objects $obj
set_property -name "active_reports_invalid" -value "" -objects $obj
set_property -name "active_run" -value "0" -objects $obj
set_property -name "hide_unused_data" -value "1" -objects $obj
set_property -name "incl_new_reports" -value "0" -objects $obj
set_property -name "reports" -value "" -objects $obj
set_property -name "run.step" -value "route_design" -objects $obj
set_property -name "run.type" -value "implementation" -objects $obj
set_property -name "statistics.critical_warning" -value "1" -objects $obj
set_property -name "statistics.error" -value "1" -objects $obj
set_property -name "statistics.info" -value "1" -objects $obj
set_property -name "statistics.warning" -value "1" -objects $obj
set_property -name "view.orientation" -value "Horizontal" -objects $obj
set_property -name "view.type" -value "Graph" -objects $obj

# Create 'power_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "power_1" ] ] ""]} {
create_dashboard_gadget -name {power_1} -type power
}
set obj [get_dashboard_gadgets [ list "power_1" ] ]
set_property -name "active_reports" -value "" -objects $obj
set_property -name "active_reports_invalid" -value "" -objects $obj
set_property -name "active_run" -value "0" -objects $obj
set_property -name "hide_unused_data" -value "1" -objects $obj
set_property -name "incl_new_reports" -value "0" -objects $obj
set_property -name "reports" -value "" -objects $obj
set_property -name "run.step" -value "route_design" -objects $obj
set_property -name "run.type" -value "implementation" -objects $obj
set_property -name "statistics.bram" -value "1" -objects $obj
set_property -name "statistics.clocks" -value "1" -objects $obj
set_property -name "statistics.dsp" -value "1" -objects $obj
set_property -name "statistics.gth" -value "1" -objects $obj
set_property -name "statistics.gtp" -value "1" -objects $obj
set_property -name "statistics.gtx" -value "1" -objects $obj
set_property -name "statistics.gtz" -value "1" -objects $obj
set_property -name "statistics.io" -value "1" -objects $obj
set_property -name "statistics.logic" -value "1" -objects $obj
set_property -name "statistics.mmcm" -value "1" -objects $obj
set_property -name "statistics.pcie" -value "1" -objects $obj
set_property -name "statistics.phaser" -value "1" -objects $obj
set_property -name "statistics.pll" -value "1" -objects $obj
set_property -name "statistics.pl_static" -value "1" -objects $obj
set_property -name "statistics.ps7" -value "1" -objects $obj
set_property -name "statistics.ps" -value "1" -objects $obj
set_property -name "statistics.ps_static" -value "1" -objects $obj
set_property -name "statistics.signals" -value "1" -objects $obj
set_property -name "statistics.total_power" -value "1" -objects $obj
set_property -name "statistics.transceiver" -value "1" -objects $obj
set_property -name "statistics.xadc" -value "1" -objects $obj
set_property -name "view.orientation" -value "Horizontal" -objects $obj
set_property -name "view.type" -value "Graph" -objects $obj

# Create 'timing_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "timing_1" ] ] ""]} {
create_dashboard_gadget -name {timing_1} -type timing
}
set obj [get_dashboard_gadgets [ list "timing_1" ] ]
set_property -name "active_reports" -value "" -objects $obj
set_property -name "active_reports_invalid" -value "" -objects $obj
set_property -name "active_run" -value "0" -objects $obj
set_property -name "hide_unused_data" -value "1" -objects $obj
set_property -name "incl_new_reports" -value "0" -objects $obj
set_property -name "reports" -value "" -objects $obj
set_property -name "run.step" -value "route_design" -objects $obj
set_property -name "run.type" -value "implementation" -objects $obj
set_property -name "statistics.ths" -value "1" -objects $obj
set_property -name "statistics.tns" -value "1" -objects $obj
set_property -name "statistics.tpws" -value "1" -objects $obj
set_property -name "statistics.whs" -value "1" -objects $obj
set_property -name "statistics.wns" -value "1" -objects $obj
set_property -name "view.orientation" -value "Horizontal" -objects $obj
set_property -name "view.type" -value "Table" -objects $obj

# Create 'utilization_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "utilization_1" ] ] ""]} {
create_dashboard_gadget -name {utilization_1} -type utilization
}
set obj [get_dashboard_gadgets [ list "utilization_1" ] ]
set_property -name "active_reports" -value "" -objects $obj
set_property -name "active_reports_invalid" -value "" -objects $obj
set_property -name "active_run" -value "0" -objects $obj
set_property -name "hide_unused_data" -value "1" -objects $obj
set_property -name "incl_new_reports" -value "0" -objects $obj
set_property -name "reports" -value "" -objects $obj
set_property -name "run.step" -value "synth_design" -objects $obj
set_property -name "run.type" -value "synthesis" -objects $obj
set_property -name "statistics.bram" -value "1" -objects $obj
set_property -name "statistics.bufg" -value "1" -objects $obj
set_property -name "statistics.dsp" -value "1" -objects $obj
set_property -name "statistics.ff" -value "1" -objects $obj
set_property -name "statistics.gt" -value "1" -objects $obj
set_property -name "statistics.io" -value "1" -objects $obj
set_property -name "statistics.lut" -value "1" -objects $obj
set_property -name "statistics.lutram" -value "1" -objects $obj
set_property -name "statistics.mmcm" -value "1" -objects $obj
set_property -name "statistics.pcie" -value "1" -objects $obj
set_property -name "statistics.pll" -value "1" -objects $obj
set_property -name "statistics.uram" -value "1" -objects $obj
set_property -name "view.orientation" -value "Horizontal" -objects $obj
set_property -name "view.type" -value "Graph" -objects $obj

# Create 'utilization_2' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "utilization_2" ] ] ""]} {
create_dashboard_gadget -name {utilization_2} -type utilization
}
set obj [get_dashboard_gadgets [ list "utilization_2" ] ]
set_property -name "active_reports" -value "" -objects $obj
set_property -name "active_reports_invalid" -value "" -objects $obj
set_property -name "active_run" -value "0" -objects $obj
set_property -name "hide_unused_data" -value "1" -objects $obj
set_property -name "incl_new_reports" -value "0" -objects $obj
set_property -name "reports" -value "" -objects $obj
set_property -name "run.step" -value "place_design" -objects $obj
set_property -name "run.type" -value "implementation" -objects $obj
set_property -name "statistics.bram" -value "1" -objects $obj
set_property -name "statistics.bufg" -value "1" -objects $obj
set_property -name "statistics.dsp" -value "1" -objects $obj
set_property -name "statistics.ff" -value "1" -objects $obj
set_property -name "statistics.gt" -value "1" -objects $obj
set_property -name "statistics.io" -value "1" -objects $obj
set_property -name "statistics.lut" -value "1" -objects $obj
set_property -name "statistics.lutram" -value "1" -objects $obj
set_property -name "statistics.mmcm" -value "1" -objects $obj
set_property -name "statistics.pcie" -value "1" -objects $obj
set_property -name "statistics.pll" -value "1" -objects $obj
set_property -name "statistics.uram" -value "1" -objects $obj
set_property -name "view.orientation" -value "Horizontal" -objects $obj
set_property -name "view.type" -value "Graph" -objects $obj

move_dashboard_gadget -name {utilization_1} -row 0 -col 0
move_dashboard_gadget -name {power_1} -row 1 -col 0
move_dashboard_gadget -name {drc_1} -row 2 -col 0
move_dashboard_gadget -name {timing_1} -row 0 -col 1
move_dashboard_gadget -name {utilization_2} -row 1 -col 1
move_dashboard_gadget -name {methodology_1} -row 2 -col 1
