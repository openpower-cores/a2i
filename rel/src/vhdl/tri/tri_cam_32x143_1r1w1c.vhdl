-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

			

library ieee;
use ieee.std_logic_1164.all;
library ibm;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on
entity tri_cam_32x143_1r1w1c  is

  generic (cam_data_width : natural := 84;
           array_data_width : natural := 68;
           rpn_width : natural := 30;
           num_entry : natural := 32;
           num_entry_log2 : natural := 5;
           expand_type : integer := 1);         
  port(
    gnd                : inout power_logic;
    vdd                : inout power_logic;
    vcs                : inout power_logic;

   nclk                           :  in   clk_logic;
   tc_ccflush_dc                  :  in   std_ulogic;
   tc_scan_dis_dc_b               :  in   std_ulogic;
   tc_scan_diag_dc                :  in   std_ulogic;
   tc_lbist_en_dc                 :  in   std_ulogic; 
   an_ac_atpg_en_dc               :  in   std_ulogic; 

   lcb_d_mode_dc                  :  in   std_ulogic;
   lcb_clkoff_dc_b                :  in   std_ulogic;
   lcb_act_dis_dc                 :  in   std_ulogic;
   lcb_mpw1_dc_b                  :  in   std_ulogic_vector(0 to 3);
   lcb_mpw2_dc_b                  :  in   std_ulogic;
   lcb_delay_lclkr_dc             :  in   std_ulogic_vector(0 to 3);

   pc_sg_2                        :  in   std_ulogic;
   pc_func_slp_sl_thold_2         :  in   std_ulogic;
   pc_func_slp_nsl_thold_2        :  in   std_ulogic;
   pc_regf_slp_sl_thold_2         :  in   std_ulogic; 
   pc_time_sl_thold_2             :  in   std_ulogic; 
   pc_fce_2                       :  in   std_ulogic;

   func_scan_in  	          : in  std_ulogic;
   func_scan_out 	          : out std_ulogic;
   regfile_scan_in    	          : in  std_ulogic_vector(0 TO 6);   
   regfile_scan_out    	          : out std_ulogic_vector(0 TO 6); 
   time_scan_in  	          : in  std_ulogic; 
   time_scan_out 	          : out std_ulogic; 


   rd_val                         :  in   std_ulogic;
   rd_val_late                    :  in   std_ulogic;
   rw_entry                       :  in   std_ulogic_vector(0 to num_entry_log2-1);

   wr_array_data                  :  in   std_ulogic_vector(0 to array_data_width-1);
   wr_cam_data                    :  in   std_ulogic_vector(0 to cam_data_width-1);
   wr_array_val                   :  in   std_ulogic_vector(0 to 1);  
   wr_cam_val                     :  in   std_ulogic_vector(0 to 1);  
   wr_val_early                   :  in   std_ulogic;

   comp_request                   :  in   std_ulogic;
   comp_addr                      :  in   std_ulogic_vector(0 to 51);
   addr_enable                    :  in   std_ulogic_vector(0 to 1);
   comp_pgsize                    :  in   std_ulogic_vector(0 to 2);
   pgsize_enable                  :  in   std_ulogic;
   comp_class                     :  in   std_ulogic_vector(0 to 1);
   class_enable                   :  in   std_ulogic_vector(0 to 2);
   comp_extclass                  :  in   std_ulogic_vector(0 to 1);
   extclass_enable                :  in   std_ulogic_vector(0 to 1);
   comp_state                     :  in   std_ulogic_vector(0 to 1);
   state_enable                   :  in   std_ulogic_vector(0 to 1);
   comp_thdid                     :  in   std_ulogic_vector(0 to 3);
   thdid_enable                   :  in   std_ulogic_vector(0 to 1);
   comp_pid                       :  in   std_ulogic_vector(0 to 7);
   pid_enable                     :  in   std_ulogic;
   comp_invalidate                :  in   std_ulogic;
   flash_invalidate               :  in   std_ulogic;

   array_cmp_data                 :  out  std_ulogic_vector(0 to array_data_width-1);
   rd_array_data                  :  out  std_ulogic_vector(0 to array_data_width-1);

   cam_cmp_data                   :  out  std_ulogic_vector(0 to cam_data_width-1);
   cam_hit                        :  out  std_ulogic;
   cam_hit_entry                  :  out  std_ulogic_vector(0 to num_entry_log2-1);
   entry_match                    :  out  std_ulogic_vector(0 to num_entry-1);
   entry_valid                    :  out  std_ulogic_vector(0 to num_entry-1);
   rd_cam_data                    :  out  std_ulogic_vector(0 to cam_data_width-1);


bypass_mux_enab_np1   :  in  std_ulogic;
bypass_attr_np1       :  in  std_ulogic_vector(0 to 20);
attr_np2	        :  out std_ulogic_vector(0 to 20);
rpn_np2	        :  out std_ulogic_vector(22 to 51)

  );
-- synopsys translate_off
-- synopsys translate_on
end entity tri_cam_32x143_1r1w1c;
architecture tri_cam_32x143_1r1w1c of tri_cam_32x143_1r1w1c is
component tri_cam_32x143_1r1w1c_matchline
  generic (have_xbit : integer := 1;
             num_pgsizes : integer := 5;
             have_cmpmask         : integer := 1;
             cmpmask_width        : integer := 4);
port(
    addr_in                          : in std_ulogic_vector(0 to 51);
    addr_enable                      : in std_ulogic_vector(0 to 1);
    comp_pgsize                      : in std_ulogic_vector(0 to 2);
    pgsize_enable                    : in std_ulogic;
    entry_size                       : in std_ulogic_vector(0 to 2);
    entry_cmpmask                    : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_xbit                       : in std_ulogic;
    entry_xbitmask                   : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_epn                        : in std_ulogic_vector(0 to 51);
    comp_class                       : in std_ulogic_vector(0 to 1);
    entry_class                      : in std_ulogic_vector(0 to 1);
    class_enable                     : in std_ulogic_vector(0 to 2);
    comp_extclass                    : in std_ulogic_vector(0 to 1);
    entry_extclass                   : in std_ulogic_vector(0 to 1);
    extclass_enable                  : in std_ulogic_vector(0 to 1);
    comp_state                       : in std_ulogic_vector(0 to 1);
    entry_hv                         : in std_ulogic;
    entry_ds                         : in std_ulogic;
    state_enable                     : in std_ulogic_vector(0 to 1);
    entry_thdid                      : in std_ulogic_vector(0 to 3);
    comp_thdid                       : in std_ulogic_vector(0 to 3);
    thdid_enable                     : in std_ulogic_vector(0 to 1);
    entry_pid                        : in std_ulogic_vector(0 to 7);
    comp_pid                         : in std_ulogic_vector(0 to 7);
    pid_enable                       : in std_ulogic;
    entry_v                          : in std_ulogic;
    comp_invalidate                  : in std_ulogic;

    match                            : out std_ulogic
);
end component;
begin
a : if expand_type = 1 generate
component RAMB16_S9_S9
-- pragma translate_off
	generic
	(
		SIM_COLLISION_CHECK : string := "none"); 
-- pragma translate_on
	port
	(
		DOA : out std_logic_vector(7 downto 0);
		DOB : out std_logic_vector(7 downto 0);
		DOPA : out std_logic_vector(0 downto 0);
		DOPB : out std_logic_vector(0 downto 0);
		ADDRA : in std_logic_vector(10 downto 0);
		ADDRB : in std_logic_vector(10 downto 0);
		CLKA : in std_ulogic;
		CLKB : in std_ulogic;
		DIA : in std_logic_vector(7 downto 0);
		DIB : in std_logic_vector(7 downto 0);
		DIPA : in std_logic_vector(0 downto 0);
		DIPB : in std_logic_vector(0 downto 0);
		ENA : in std_ulogic;
		ENB : in std_ulogic;
		SSRA : in std_ulogic;
		SSRB : in std_ulogic;
		WEA : in std_ulogic;
		WEB : in std_ulogic
	);
end component;
component RAMB16_S18_S18
-- pragma translate_off
	generic(
		SIM_COLLISION_CHECK : string := "none"); 
-- pragma translate_on
	port(
	    DOA  : out std_logic_vector(15 downto 0);
	    DOB  : out std_logic_vector(15 downto 0);
	    DOPA : out std_logic_vector(1 downto 0);
	    DOPB : out std_logic_vector(1 downto 0);

	    ADDRA : in std_logic_vector(9 downto 0);
	    ADDRB : in std_logic_vector(9 downto 0);
	    CLKA  : in std_ulogic;
	    CLKB  : in std_ulogic;
	    DIA   : in std_logic_vector(15 downto 0);
	    DIB   : in std_logic_vector(15 downto 0);
	    DIPA  : in std_logic_vector(1 downto 0);
	    DIPB  : in std_logic_vector(1 downto 0);
	    ENA   : in std_ulogic;
	    ENB   : in std_ulogic;
	    SSRA  : in std_ulogic;
	    SSRB  : in std_ulogic;
	    WEA   : in std_ulogic;
	    WEB   : in std_ulogic);
	end component;
component RAMB16_S36_S36
-- pragma translate_off
	generic(
		SIM_COLLISION_CHECK : string := "none"); 
-- pragma translate_on
	port(
		DOA : out std_logic_vector(31 downto 0);
		DOB : out std_logic_vector(31 downto 0);
		DOPA : out std_logic_vector(3 downto 0);
		DOPB : out std_logic_vector(3 downto 0);
		ADDRA : in std_logic_vector(8 downto 0);
		ADDRB : in std_logic_vector(8 downto 0);
		CLKA : in std_ulogic;
		CLKB : in std_ulogic;
		DIA : in std_logic_vector(31 downto 0);
		DIB : in std_logic_vector(31 downto 0);
		DIPA : in std_logic_vector(3 downto 0);
		DIPB : in std_logic_vector(3 downto 0);
		ENA : in std_ulogic;
		ENB : in std_ulogic;
		SSRA : in std_ulogic;
		SSRB : in std_ulogic;
		WEA : in std_ulogic;
		WEB : in std_ulogic);
	end component;
-- pragma translate_off
-- pragma translate_on
signal clk,clk2x                          : std_ulogic;
signal bram0_addra,   bram0_addrb         : std_ulogic_vector(0 to 8);
signal bram1_addra,   bram1_addrb         : std_ulogic_vector(0 to 10);
signal bram2_addra,   bram2_addrb         : std_ulogic_vector(0 to 9);
signal bram0_wea, bram1_wea, bram2_wea   : std_ulogic;
signal array_cmp_data_bram    : std_ulogic_vector(0 to 55);
signal array_cmp_data_bramp    : std_ulogic_vector(66 to 72);
signal sreset_q                           : std_ulogic;
signal gate_fq,         gate_d            : std_ulogic;
signal comp_addr_np1_d, comp_addr_np1_q  : std_ulogic_vector(52-rpn_width to 51);
signal rpn_np2_d,rpn_np2_q               : std_ulogic_vector(52-rpn_width to 51);
signal attr_np2_d,attr_np2_q             : std_ulogic_vector(0 to 20);
signal     entry0_epn_d,   entry0_epn_q        : std_ulogic_vector(0 to 51);
signal     entry0_xbit_d,   entry0_xbit_q      : std_ulogic;
signal     entry0_size_d,   entry0_size_q      : std_ulogic_vector(0 to 2);
signal     entry0_v_d,   entry0_v_q            : std_ulogic;
signal     entry0_thdid_d,   entry0_thdid_q    : std_ulogic_vector(0 to 3);
signal     entry0_class_d,   entry0_class_q    : std_ulogic_vector(0 to 1);
signal     entry0_extclass_d,   entry0_extclass_q    : std_ulogic_vector(0 to 1);
signal     entry0_hv_d,   entry0_hv_q          : std_ulogic;
signal     entry0_ds_d,   entry0_ds_q          : std_ulogic;
signal     entry0_pid_d,   entry0_pid_q        : std_ulogic_vector(0 to 7);
signal     entry0_cmpmask_d,   entry0_cmpmask_q        : std_ulogic_vector(0 to 8);
signal     entry0_parity_d,   entry0_parity_q   : std_ulogic_vector(0 to 9);
signal     wr_entry0_sel           : std_ulogic_vector(0 to 1);
signal     entry0_inval            : std_ulogic;
signal     entry0_v_muxsel         : std_ulogic_vector(0 to 1);
signal     entry0_cam_vec      : std_ulogic_vector(0 to cam_data_width-1);
signal     entry0_array_vec    : std_ulogic_vector(0 to array_data_width-1);
signal     entry1_epn_d,   entry1_epn_q        : std_ulogic_vector(0 to 51);
signal     entry1_xbit_d,   entry1_xbit_q      : std_ulogic;
signal     entry1_size_d,   entry1_size_q      : std_ulogic_vector(0 to 2);
signal     entry1_v_d,   entry1_v_q            : std_ulogic;
signal     entry1_thdid_d,   entry1_thdid_q    : std_ulogic_vector(0 to 3);
signal     entry1_class_d,   entry1_class_q    : std_ulogic_vector(0 to 1);
signal     entry1_extclass_d,   entry1_extclass_q    : std_ulogic_vector(0 to 1);
signal     entry1_hv_d,   entry1_hv_q          : std_ulogic;
signal     entry1_ds_d,   entry1_ds_q          : std_ulogic;
signal     entry1_pid_d,   entry1_pid_q        : std_ulogic_vector(0 to 7);
signal     entry1_cmpmask_d,   entry1_cmpmask_q        : std_ulogic_vector(0 to 8);
signal     entry1_parity_d,   entry1_parity_q   : std_ulogic_vector(0 to 9);
signal     wr_entry1_sel           : std_ulogic_vector(0 to 1);
signal     entry1_inval            : std_ulogic;
signal     entry1_v_muxsel         : std_ulogic_vector(0 to 1);
signal     entry1_cam_vec      : std_ulogic_vector(0 to cam_data_width-1);
signal     entry1_array_vec    : std_ulogic_vector(0 to array_data_width-1);
signal     entry2_epn_d,   entry2_epn_q        : std_ulogic_vector(0 to 51);
signal     entry2_xbit_d,   entry2_xbit_q      : std_ulogic;
signal     entry2_size_d,   entry2_size_q      : std_ulogic_vector(0 to 2);
signal     entry2_v_d,   entry2_v_q            : std_ulogic;
signal     entry2_thdid_d,   entry2_thdid_q    : std_ulogic_vector(0 to 3);
signal     entry2_class_d,   entry2_class_q    : std_ulogic_vector(0 to 1);
signal     entry2_extclass_d,   entry2_extclass_q    : std_ulogic_vector(0 to 1);
signal     entry2_hv_d,   entry2_hv_q          : std_ulogic;
signal     entry2_ds_d,   entry2_ds_q          : std_ulogic;
signal     entry2_pid_d,   entry2_pid_q        : std_ulogic_vector(0 to 7);
signal     entry2_cmpmask_d,   entry2_cmpmask_q        : std_ulogic_vector(0 to 8);
signal     entry2_parity_d,   entry2_parity_q   : std_ulogic_vector(0 to 9);
signal     wr_entry2_sel           : std_ulogic_vector(0 to 1);
signal     entry2_inval            : std_ulogic;
signal     entry2_v_muxsel         : std_ulogic_vector(0 to 1);
signal     entry2_cam_vec      : std_ulogic_vector(0 to cam_data_width-1);
signal     entry2_array_vec    : std_ulogic_vector(0 to array_data_width-1);
signal     entry3_epn_d,   entry3_epn_q        : std_ulogic_vector(0 to 51);
signal     entry3_xbit_d,   entry3_xbit_q      : std_ulogic;
signal     entry3_size_d,   entry3_size_q      : std_ulogic_vector(0 to 2);
signal     entry3_v_d,   entry3_v_q            : std_ulogic;
signal     entry3_thdid_d,   entry3_thdid_q    : std_ulogic_vector(0 to 3);
signal     entry3_class_d,   entry3_class_q    : std_ulogic_vector(0 to 1);
signal     entry3_extclass_d,   entry3_extclass_q    : std_ulogic_vector(0 to 1);
signal     entry3_hv_d,   entry3_hv_q          : std_ulogic;
signal     entry3_ds_d,   entry3_ds_q          : std_ulogic;
signal     entry3_pid_d,   entry3_pid_q        : std_ulogic_vector(0 to 7);
signal     entry3_cmpmask_d,   entry3_cmpmask_q        : std_ulogic_vector(0 to 8);
signal     entry3_parity_d,   entry3_parity_q   : std_ulogic_vector(0 to 9);
signal     wr_entry3_sel           : std_ulogic_vector(0 to 1);
signal     entry3_inval            : std_ulogic;
signal     entry3_v_muxsel         : std_ulogic_vector(0 to 1);
signal     entry3_cam_vec      : std_ulogic_vector(0 to cam_data_width-1);
signal     entry3_array_vec    : std_ulogic_vector(0 to array_data_width-1);
signal     entry4_epn_d,   entry4_epn_q        : std_ulogic_vector(0 to 51);
signal     entry4_xbit_d,   entry4_xbit_q      : std_ulogic;
signal     entry4_size_d,   entry4_size_q      : std_ulogic_vector(0 to 2);
signal     entry4_v_d,   entry4_v_q            : std_ulogic;
signal     entry4_thdid_d,   entry4_thdid_q    : std_ulogic_vector(0 to 3);
signal     entry4_class_d,   entry4_class_q    : std_ulogic_vector(0 to 1);
signal     entry4_extclass_d,   entry4_extclass_q    : std_ulogic_vector(0 to 1);
signal     entry4_hv_d,   entry4_hv_q          : std_ulogic;
signal     entry4_ds_d,   entry4_ds_q          : std_ulogic;
signal     entry4_pid_d,   entry4_pid_q        : std_ulogic_vector(0 to 7);
signal     entry4_cmpmask_d,   entry4_cmpmask_q        : std_ulogic_vector(0 to 8);
signal     entry4_parity_d,   entry4_parity_q   : std_ulogic_vector(0 to 9);
signal     wr_entry4_sel           : std_ulogic_vector(0 to 1);
signal     entry4_inval            : std_ulogic;
signal     entry4_v_muxsel         : std_ulogic_vector(0 to 1);
signal     entry4_cam_vec      : std_ulogic_vector(0 to cam_data_width-1);
signal     entry4_array_vec    : std_ulogic_vector(0 to array_data_width-1);
signal     entry5_epn_d,   entry5_epn_q        : std_ulogic_vector(0 to 51);
signal     entry5_xbit_d,   entry5_xbit_q      : std_ulogic;
signal     entry5_size_d,   entry5_size_q      : std_ulogic_vector(0 to 2);
signal     entry5_v_d,   entry5_v_q            : std_ulogic;
signal     entry5_thdid_d,   entry5_thdid_q    : std_ulogic_vector(0 to 3);
signal     entry5_class_d,   entry5_class_q    : std_ulogic_vector(0 to 1);
signal     entry5_extclass_d,   entry5_extclass_q    : std_ulogic_vector(0 to 1);
signal     entry5_hv_d,   entry5_hv_q          : std_ulogic;
signal     entry5_ds_d,   entry5_ds_q          : std_ulogic;
signal     entry5_pid_d,   entry5_pid_q        : std_ulogic_vector(0 to 7);
signal     entry5_cmpmask_d,   entry5_cmpmask_q        : std_ulogic_vector(0 to 8);
signal     entry5_parity_d,   entry5_parity_q   : std_ulogic_vector(0 to 9);
signal     wr_entry5_sel           : std_ulogic_vector(0 to 1);
signal     entry5_inval            : std_ulogic;
signal     entry5_v_muxsel         : std_ulogic_vector(0 to 1);
signal     entry5_cam_vec      : std_ulogic_vector(0 to cam_data_width-1);
signal     entry5_array_vec    : std_ulogic_vector(0 to array_data_width-1);
signal     entry6_epn_d,   entry6_epn_q        : std_ulogic_vector(0 to 51);
signal     entry6_xbit_d,   entry6_xbit_q      : std_ulogic;
signal     entry6_size_d,   entry6_size_q      : std_ulogic_vector(0 to 2);
signal     entry6_v_d,   entry6_v_q            : std_ulogic;
signal     entry6_thdid_d,   entry6_thdid_q    : std_ulogic_vector(0 to 3);
signal     entry6_class_d,   entry6_class_q    : std_ulogic_vector(0 to 1);
signal     entry6_extclass_d,   entry6_extclass_q    : std_ulogic_vector(0 to 1);
signal     entry6_hv_d,   entry6_hv_q          : std_ulogic;
signal     entry6_ds_d,   entry6_ds_q          : std_ulogic;
signal     entry6_pid_d,   entry6_pid_q        : std_ulogic_vector(0 to 7);
signal     entry6_cmpmask_d,   entry6_cmpmask_q        : std_ulogic_vector(0 to 8);
signal     entry6_parity_d,   entry6_parity_q   : std_ulogic_vector(0 to 9);
signal     wr_entry6_sel           : std_ulogic_vector(0 to 1);
signal     entry6_inval            : std_ulogic;
signal     entry6_v_muxsel         : std_ulogic_vector(0 to 1);
signal     entry6_cam_vec      : std_ulogic_vector(0 to cam_data_width-1);
signal     entry6_array_vec    : std_ulogic_vector(0 to array_data_width-1);
signal     entry7_epn_d,   entry7_epn_q        : std_ulogic_vector(0 to 51);
signal     entry7_xbit_d,   entry7_xbit_q      : std_ulogic;
signal     entry7_size_d,   entry7_size_q      : std_ulogic_vector(0 to 2);
signal     entry7_v_d,   entry7_v_q            : std_ulogic;
signal     entry7_thdid_d,   entry7_thdid_q    : std_ulogic_vector(0 to 3);
signal     entry7_class_d,   entry7_class_q    : std_ulogic_vector(0 to 1);
signal     entry7_extclass_d,   entry7_extclass_q    : std_ulogic_vector(0 to 1);
signal     entry7_hv_d,   entry7_hv_q          : std_ulogic;
signal     entry7_ds_d,   entry7_ds_q          : std_ulogic;
signal     entry7_pid_d,   entry7_pid_q        : std_ulogic_vector(0 to 7);
signal     entry7_cmpmask_d,   entry7_cmpmask_q        : std_ulogic_vector(0 to 8);
signal     entry7_parity_d,   entry7_parity_q   : std_ulogic_vector(0 to 9);
signal     wr_entry7_sel           : std_ulogic_vector(0 to 1);
signal     entry7_inval            : std_ulogic;
signal     entry7_v_muxsel         : std_ulogic_vector(0 to 1);
signal     entry7_cam_vec      : std_ulogic_vector(0 to cam_data_width-1);
signal     entry7_array_vec    : std_ulogic_vector(0 to array_data_width-1);
signal     entry8_epn_d,   entry8_epn_q        : std_ulogic_vector(0 to 51);
signal     entry8_xbit_d,   entry8_xbit_q      : std_ulogic;
signal     entry8_size_d,   entry8_size_q      : std_ulogic_vector(0 to 2);
signal     entry8_v_d,   entry8_v_q            : std_ulogic;
signal     entry8_thdid_d,   entry8_thdid_q    : std_ulogic_vector(0 to 3);
signal     entry8_class_d,   entry8_class_q    : std_ulogic_vector(0 to 1);
signal     entry8_extclass_d,   entry8_extclass_q    : std_ulogic_vector(0 to 1);
signal     entry8_hv_d,   entry8_hv_q          : std_ulogic;
signal     entry8_ds_d,   entry8_ds_q          : std_ulogic;
signal     entry8_pid_d,   entry8_pid_q        : std_ulogic_vector(0 to 7);
signal     entry8_cmpmask_d,   entry8_cmpmask_q        : std_ulogic_vector(0 to 8);
signal     entry8_parity_d,   entry8_parity_q   : std_ulogic_vector(0 to 9);
signal     wr_entry8_sel           : std_ulogic_vector(0 to 1);
signal     entry8_inval            : std_ulogic;
signal     entry8_v_muxsel         : std_ulogic_vector(0 to 1);
signal     entry8_cam_vec      : std_ulogic_vector(0 to cam_data_width-1);
signal     entry8_array_vec    : std_ulogic_vector(0 to array_data_width-1);
signal     entry9_epn_d,   entry9_epn_q        : std_ulogic_vector(0 to 51);
signal     entry9_xbit_d,   entry9_xbit_q      : std_ulogic;
signal     entry9_size_d,   entry9_size_q      : std_ulogic_vector(0 to 2);
signal     entry9_v_d,   entry9_v_q            : std_ulogic;
signal     entry9_thdid_d,   entry9_thdid_q    : std_ulogic_vector(0 to 3);
signal     entry9_class_d,   entry9_class_q    : std_ulogic_vector(0 to 1);
signal     entry9_extclass_d,   entry9_extclass_q    : std_ulogic_vector(0 to 1);
signal     entry9_hv_d,   entry9_hv_q          : std_ulogic;
signal     entry9_ds_d,   entry9_ds_q          : std_ulogic;
signal     entry9_pid_d,   entry9_pid_q        : std_ulogic_vector(0 to 7);
signal     entry9_cmpmask_d,   entry9_cmpmask_q        : std_ulogic_vector(0 to 8);
signal     entry9_parity_d,   entry9_parity_q   : std_ulogic_vector(0 to 9);
signal     wr_entry9_sel           : std_ulogic_vector(0 to 1);
signal     entry9_inval            : std_ulogic;
signal     entry9_v_muxsel         : std_ulogic_vector(0 to 1);
signal     entry9_cam_vec      : std_ulogic_vector(0 to cam_data_width-1);
signal     entry9_array_vec    : std_ulogic_vector(0 to array_data_width-1);
signal     entry10_epn_d,  entry10_epn_q       : std_ulogic_vector(0 to 51);
signal     entry10_xbit_d,  entry10_xbit_q     : std_ulogic;
signal     entry10_size_d,  entry10_size_q     : std_ulogic_vector(0 to 2);
signal     entry10_v_d,  entry10_v_q           : std_ulogic;
signal     entry10_thdid_d,  entry10_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry10_class_d,  entry10_class_q   : std_ulogic_vector(0 to 1);
signal     entry10_extclass_d,  entry10_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry10_hv_d,  entry10_hv_q         : std_ulogic;
signal     entry10_ds_d,  entry10_ds_q         : std_ulogic;
signal     entry10_pid_d,  entry10_pid_q       : std_ulogic_vector(0 to 7);
signal     entry10_cmpmask_d,  entry10_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry10_parity_d,  entry10_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry10_sel          : std_ulogic_vector(0 to 1);
signal     entry10_inval           : std_ulogic;
signal     entry10_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry10_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry10_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry11_epn_d,  entry11_epn_q       : std_ulogic_vector(0 to 51);
signal     entry11_xbit_d,  entry11_xbit_q     : std_ulogic;
signal     entry11_size_d,  entry11_size_q     : std_ulogic_vector(0 to 2);
signal     entry11_v_d,  entry11_v_q           : std_ulogic;
signal     entry11_thdid_d,  entry11_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry11_class_d,  entry11_class_q   : std_ulogic_vector(0 to 1);
signal     entry11_extclass_d,  entry11_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry11_hv_d,  entry11_hv_q         : std_ulogic;
signal     entry11_ds_d,  entry11_ds_q         : std_ulogic;
signal     entry11_pid_d,  entry11_pid_q       : std_ulogic_vector(0 to 7);
signal     entry11_cmpmask_d,  entry11_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry11_parity_d,  entry11_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry11_sel          : std_ulogic_vector(0 to 1);
signal     entry11_inval           : std_ulogic;
signal     entry11_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry11_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry11_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry12_epn_d,  entry12_epn_q       : std_ulogic_vector(0 to 51);
signal     entry12_xbit_d,  entry12_xbit_q     : std_ulogic;
signal     entry12_size_d,  entry12_size_q     : std_ulogic_vector(0 to 2);
signal     entry12_v_d,  entry12_v_q           : std_ulogic;
signal     entry12_thdid_d,  entry12_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry12_class_d,  entry12_class_q   : std_ulogic_vector(0 to 1);
signal     entry12_extclass_d,  entry12_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry12_hv_d,  entry12_hv_q         : std_ulogic;
signal     entry12_ds_d,  entry12_ds_q         : std_ulogic;
signal     entry12_pid_d,  entry12_pid_q       : std_ulogic_vector(0 to 7);
signal     entry12_cmpmask_d,  entry12_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry12_parity_d,  entry12_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry12_sel          : std_ulogic_vector(0 to 1);
signal     entry12_inval           : std_ulogic;
signal     entry12_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry12_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry12_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry13_epn_d,  entry13_epn_q       : std_ulogic_vector(0 to 51);
signal     entry13_xbit_d,  entry13_xbit_q     : std_ulogic;
signal     entry13_size_d,  entry13_size_q     : std_ulogic_vector(0 to 2);
signal     entry13_v_d,  entry13_v_q           : std_ulogic;
signal     entry13_thdid_d,  entry13_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry13_class_d,  entry13_class_q   : std_ulogic_vector(0 to 1);
signal     entry13_extclass_d,  entry13_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry13_hv_d,  entry13_hv_q         : std_ulogic;
signal     entry13_ds_d,  entry13_ds_q         : std_ulogic;
signal     entry13_pid_d,  entry13_pid_q       : std_ulogic_vector(0 to 7);
signal     entry13_cmpmask_d,  entry13_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry13_parity_d,  entry13_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry13_sel          : std_ulogic_vector(0 to 1);
signal     entry13_inval           : std_ulogic;
signal     entry13_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry13_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry13_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry14_epn_d,  entry14_epn_q       : std_ulogic_vector(0 to 51);
signal     entry14_xbit_d,  entry14_xbit_q     : std_ulogic;
signal     entry14_size_d,  entry14_size_q     : std_ulogic_vector(0 to 2);
signal     entry14_v_d,  entry14_v_q           : std_ulogic;
signal     entry14_thdid_d,  entry14_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry14_class_d,  entry14_class_q   : std_ulogic_vector(0 to 1);
signal     entry14_extclass_d,  entry14_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry14_hv_d,  entry14_hv_q         : std_ulogic;
signal     entry14_ds_d,  entry14_ds_q         : std_ulogic;
signal     entry14_pid_d,  entry14_pid_q       : std_ulogic_vector(0 to 7);
signal     entry14_cmpmask_d,  entry14_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry14_parity_d,  entry14_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry14_sel          : std_ulogic_vector(0 to 1);
signal     entry14_inval           : std_ulogic;
signal     entry14_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry14_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry14_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry15_epn_d,  entry15_epn_q       : std_ulogic_vector(0 to 51);
signal     entry15_xbit_d,  entry15_xbit_q     : std_ulogic;
signal     entry15_size_d,  entry15_size_q     : std_ulogic_vector(0 to 2);
signal     entry15_v_d,  entry15_v_q           : std_ulogic;
signal     entry15_thdid_d,  entry15_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry15_class_d,  entry15_class_q   : std_ulogic_vector(0 to 1);
signal     entry15_extclass_d,  entry15_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry15_hv_d,  entry15_hv_q         : std_ulogic;
signal     entry15_ds_d,  entry15_ds_q         : std_ulogic;
signal     entry15_pid_d,  entry15_pid_q       : std_ulogic_vector(0 to 7);
signal     entry15_cmpmask_d,  entry15_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry15_parity_d,  entry15_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry15_sel          : std_ulogic_vector(0 to 1);
signal     entry15_inval           : std_ulogic;
signal     entry15_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry15_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry15_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry16_epn_d,  entry16_epn_q       : std_ulogic_vector(0 to 51);
signal     entry16_xbit_d,  entry16_xbit_q     : std_ulogic;
signal     entry16_size_d,  entry16_size_q     : std_ulogic_vector(0 to 2);
signal     entry16_v_d,  entry16_v_q           : std_ulogic;
signal     entry16_thdid_d,  entry16_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry16_class_d,  entry16_class_q   : std_ulogic_vector(0 to 1);
signal     entry16_extclass_d,  entry16_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry16_hv_d,  entry16_hv_q         : std_ulogic;
signal     entry16_ds_d,  entry16_ds_q         : std_ulogic;
signal     entry16_pid_d,  entry16_pid_q       : std_ulogic_vector(0 to 7);
signal     entry16_cmpmask_d,  entry16_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry16_parity_d,  entry16_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry16_sel          : std_ulogic_vector(0 to 1);
signal     entry16_inval           : std_ulogic;
signal     entry16_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry16_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry16_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry17_epn_d,  entry17_epn_q       : std_ulogic_vector(0 to 51);
signal     entry17_xbit_d,  entry17_xbit_q     : std_ulogic;
signal     entry17_size_d,  entry17_size_q     : std_ulogic_vector(0 to 2);
signal     entry17_v_d,  entry17_v_q           : std_ulogic;
signal     entry17_thdid_d,  entry17_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry17_class_d,  entry17_class_q   : std_ulogic_vector(0 to 1);
signal     entry17_extclass_d,  entry17_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry17_hv_d,  entry17_hv_q         : std_ulogic;
signal     entry17_ds_d,  entry17_ds_q         : std_ulogic;
signal     entry17_pid_d,  entry17_pid_q       : std_ulogic_vector(0 to 7);
signal     entry17_cmpmask_d,  entry17_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry17_parity_d,  entry17_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry17_sel          : std_ulogic_vector(0 to 1);
signal     entry17_inval           : std_ulogic;
signal     entry17_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry17_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry17_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry18_epn_d,  entry18_epn_q       : std_ulogic_vector(0 to 51);
signal     entry18_xbit_d,  entry18_xbit_q     : std_ulogic;
signal     entry18_size_d,  entry18_size_q     : std_ulogic_vector(0 to 2);
signal     entry18_v_d,  entry18_v_q           : std_ulogic;
signal     entry18_thdid_d,  entry18_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry18_class_d,  entry18_class_q   : std_ulogic_vector(0 to 1);
signal     entry18_extclass_d,  entry18_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry18_hv_d,  entry18_hv_q         : std_ulogic;
signal     entry18_ds_d,  entry18_ds_q         : std_ulogic;
signal     entry18_pid_d,  entry18_pid_q       : std_ulogic_vector(0 to 7);
signal     entry18_cmpmask_d,  entry18_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry18_parity_d,  entry18_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry18_sel          : std_ulogic_vector(0 to 1);
signal     entry18_inval           : std_ulogic;
signal     entry18_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry18_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry18_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry19_epn_d,  entry19_epn_q       : std_ulogic_vector(0 to 51);
signal     entry19_xbit_d,  entry19_xbit_q     : std_ulogic;
signal     entry19_size_d,  entry19_size_q     : std_ulogic_vector(0 to 2);
signal     entry19_v_d,  entry19_v_q           : std_ulogic;
signal     entry19_thdid_d,  entry19_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry19_class_d,  entry19_class_q   : std_ulogic_vector(0 to 1);
signal     entry19_extclass_d,  entry19_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry19_hv_d,  entry19_hv_q         : std_ulogic;
signal     entry19_ds_d,  entry19_ds_q         : std_ulogic;
signal     entry19_pid_d,  entry19_pid_q       : std_ulogic_vector(0 to 7);
signal     entry19_cmpmask_d,  entry19_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry19_parity_d,  entry19_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry19_sel          : std_ulogic_vector(0 to 1);
signal     entry19_inval           : std_ulogic;
signal     entry19_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry19_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry19_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry20_epn_d,  entry20_epn_q       : std_ulogic_vector(0 to 51);
signal     entry20_xbit_d,  entry20_xbit_q     : std_ulogic;
signal     entry20_size_d,  entry20_size_q     : std_ulogic_vector(0 to 2);
signal     entry20_v_d,  entry20_v_q           : std_ulogic;
signal     entry20_thdid_d,  entry20_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry20_class_d,  entry20_class_q   : std_ulogic_vector(0 to 1);
signal     entry20_extclass_d,  entry20_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry20_hv_d,  entry20_hv_q         : std_ulogic;
signal     entry20_ds_d,  entry20_ds_q         : std_ulogic;
signal     entry20_pid_d,  entry20_pid_q       : std_ulogic_vector(0 to 7);
signal     entry20_cmpmask_d,  entry20_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry20_parity_d,  entry20_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry20_sel          : std_ulogic_vector(0 to 1);
signal     entry20_inval           : std_ulogic;
signal     entry20_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry20_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry20_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry21_epn_d,  entry21_epn_q       : std_ulogic_vector(0 to 51);
signal     entry21_xbit_d,  entry21_xbit_q     : std_ulogic;
signal     entry21_size_d,  entry21_size_q     : std_ulogic_vector(0 to 2);
signal     entry21_v_d,  entry21_v_q           : std_ulogic;
signal     entry21_thdid_d,  entry21_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry21_class_d,  entry21_class_q   : std_ulogic_vector(0 to 1);
signal     entry21_extclass_d,  entry21_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry21_hv_d,  entry21_hv_q         : std_ulogic;
signal     entry21_ds_d,  entry21_ds_q         : std_ulogic;
signal     entry21_pid_d,  entry21_pid_q       : std_ulogic_vector(0 to 7);
signal     entry21_cmpmask_d,  entry21_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry21_parity_d,  entry21_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry21_sel          : std_ulogic_vector(0 to 1);
signal     entry21_inval           : std_ulogic;
signal     entry21_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry21_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry21_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry22_epn_d,  entry22_epn_q       : std_ulogic_vector(0 to 51);
signal     entry22_xbit_d,  entry22_xbit_q     : std_ulogic;
signal     entry22_size_d,  entry22_size_q     : std_ulogic_vector(0 to 2);
signal     entry22_v_d,  entry22_v_q           : std_ulogic;
signal     entry22_thdid_d,  entry22_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry22_class_d,  entry22_class_q   : std_ulogic_vector(0 to 1);
signal     entry22_extclass_d,  entry22_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry22_hv_d,  entry22_hv_q         : std_ulogic;
signal     entry22_ds_d,  entry22_ds_q         : std_ulogic;
signal     entry22_pid_d,  entry22_pid_q       : std_ulogic_vector(0 to 7);
signal     entry22_cmpmask_d,  entry22_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry22_parity_d,  entry22_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry22_sel          : std_ulogic_vector(0 to 1);
signal     entry22_inval           : std_ulogic;
signal     entry22_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry22_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry22_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry23_epn_d,  entry23_epn_q       : std_ulogic_vector(0 to 51);
signal     entry23_xbit_d,  entry23_xbit_q     : std_ulogic;
signal     entry23_size_d,  entry23_size_q     : std_ulogic_vector(0 to 2);
signal     entry23_v_d,  entry23_v_q           : std_ulogic;
signal     entry23_thdid_d,  entry23_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry23_class_d,  entry23_class_q   : std_ulogic_vector(0 to 1);
signal     entry23_extclass_d,  entry23_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry23_hv_d,  entry23_hv_q         : std_ulogic;
signal     entry23_ds_d,  entry23_ds_q         : std_ulogic;
signal     entry23_pid_d,  entry23_pid_q       : std_ulogic_vector(0 to 7);
signal     entry23_cmpmask_d,  entry23_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry23_parity_d,  entry23_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry23_sel          : std_ulogic_vector(0 to 1);
signal     entry23_inval           : std_ulogic;
signal     entry23_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry23_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry23_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry24_epn_d,  entry24_epn_q       : std_ulogic_vector(0 to 51);
signal     entry24_xbit_d,  entry24_xbit_q     : std_ulogic;
signal     entry24_size_d,  entry24_size_q     : std_ulogic_vector(0 to 2);
signal     entry24_v_d,  entry24_v_q           : std_ulogic;
signal     entry24_thdid_d,  entry24_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry24_class_d,  entry24_class_q   : std_ulogic_vector(0 to 1);
signal     entry24_extclass_d,  entry24_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry24_hv_d,  entry24_hv_q         : std_ulogic;
signal     entry24_ds_d,  entry24_ds_q         : std_ulogic;
signal     entry24_pid_d,  entry24_pid_q       : std_ulogic_vector(0 to 7);
signal     entry24_cmpmask_d,  entry24_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry24_parity_d,  entry24_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry24_sel          : std_ulogic_vector(0 to 1);
signal     entry24_inval           : std_ulogic;
signal     entry24_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry24_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry24_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry25_epn_d,  entry25_epn_q       : std_ulogic_vector(0 to 51);
signal     entry25_xbit_d,  entry25_xbit_q     : std_ulogic;
signal     entry25_size_d,  entry25_size_q     : std_ulogic_vector(0 to 2);
signal     entry25_v_d,  entry25_v_q           : std_ulogic;
signal     entry25_thdid_d,  entry25_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry25_class_d,  entry25_class_q   : std_ulogic_vector(0 to 1);
signal     entry25_extclass_d,  entry25_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry25_hv_d,  entry25_hv_q         : std_ulogic;
signal     entry25_ds_d,  entry25_ds_q         : std_ulogic;
signal     entry25_pid_d,  entry25_pid_q       : std_ulogic_vector(0 to 7);
signal     entry25_cmpmask_d,  entry25_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry25_parity_d,  entry25_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry25_sel          : std_ulogic_vector(0 to 1);
signal     entry25_inval           : std_ulogic;
signal     entry25_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry25_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry25_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry26_epn_d,  entry26_epn_q       : std_ulogic_vector(0 to 51);
signal     entry26_xbit_d,  entry26_xbit_q     : std_ulogic;
signal     entry26_size_d,  entry26_size_q     : std_ulogic_vector(0 to 2);
signal     entry26_v_d,  entry26_v_q           : std_ulogic;
signal     entry26_thdid_d,  entry26_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry26_class_d,  entry26_class_q   : std_ulogic_vector(0 to 1);
signal     entry26_extclass_d,  entry26_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry26_hv_d,  entry26_hv_q         : std_ulogic;
signal     entry26_ds_d,  entry26_ds_q         : std_ulogic;
signal     entry26_pid_d,  entry26_pid_q       : std_ulogic_vector(0 to 7);
signal     entry26_cmpmask_d,  entry26_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry26_parity_d,  entry26_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry26_sel          : std_ulogic_vector(0 to 1);
signal     entry26_inval           : std_ulogic;
signal     entry26_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry26_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry26_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry27_epn_d,  entry27_epn_q       : std_ulogic_vector(0 to 51);
signal     entry27_xbit_d,  entry27_xbit_q     : std_ulogic;
signal     entry27_size_d,  entry27_size_q     : std_ulogic_vector(0 to 2);
signal     entry27_v_d,  entry27_v_q           : std_ulogic;
signal     entry27_thdid_d,  entry27_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry27_class_d,  entry27_class_q   : std_ulogic_vector(0 to 1);
signal     entry27_extclass_d,  entry27_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry27_hv_d,  entry27_hv_q         : std_ulogic;
signal     entry27_ds_d,  entry27_ds_q         : std_ulogic;
signal     entry27_pid_d,  entry27_pid_q       : std_ulogic_vector(0 to 7);
signal     entry27_cmpmask_d,  entry27_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry27_parity_d,  entry27_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry27_sel          : std_ulogic_vector(0 to 1);
signal     entry27_inval           : std_ulogic;
signal     entry27_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry27_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry27_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry28_epn_d,  entry28_epn_q       : std_ulogic_vector(0 to 51);
signal     entry28_xbit_d,  entry28_xbit_q     : std_ulogic;
signal     entry28_size_d,  entry28_size_q     : std_ulogic_vector(0 to 2);
signal     entry28_v_d,  entry28_v_q           : std_ulogic;
signal     entry28_thdid_d,  entry28_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry28_class_d,  entry28_class_q   : std_ulogic_vector(0 to 1);
signal     entry28_extclass_d,  entry28_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry28_hv_d,  entry28_hv_q         : std_ulogic;
signal     entry28_ds_d,  entry28_ds_q         : std_ulogic;
signal     entry28_pid_d,  entry28_pid_q       : std_ulogic_vector(0 to 7);
signal     entry28_cmpmask_d,  entry28_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry28_parity_d,  entry28_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry28_sel          : std_ulogic_vector(0 to 1);
signal     entry28_inval           : std_ulogic;
signal     entry28_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry28_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry28_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry29_epn_d,  entry29_epn_q       : std_ulogic_vector(0 to 51);
signal     entry29_xbit_d,  entry29_xbit_q     : std_ulogic;
signal     entry29_size_d,  entry29_size_q     : std_ulogic_vector(0 to 2);
signal     entry29_v_d,  entry29_v_q           : std_ulogic;
signal     entry29_thdid_d,  entry29_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry29_class_d,  entry29_class_q   : std_ulogic_vector(0 to 1);
signal     entry29_extclass_d,  entry29_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry29_hv_d,  entry29_hv_q         : std_ulogic;
signal     entry29_ds_d,  entry29_ds_q         : std_ulogic;
signal     entry29_pid_d,  entry29_pid_q       : std_ulogic_vector(0 to 7);
signal     entry29_cmpmask_d,  entry29_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry29_parity_d,  entry29_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry29_sel          : std_ulogic_vector(0 to 1);
signal     entry29_inval           : std_ulogic;
signal     entry29_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry29_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry29_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry30_epn_d,  entry30_epn_q       : std_ulogic_vector(0 to 51);
signal     entry30_xbit_d,  entry30_xbit_q     : std_ulogic;
signal     entry30_size_d,  entry30_size_q     : std_ulogic_vector(0 to 2);
signal     entry30_v_d,  entry30_v_q           : std_ulogic;
signal     entry30_thdid_d,  entry30_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry30_class_d,  entry30_class_q   : std_ulogic_vector(0 to 1);
signal     entry30_extclass_d,  entry30_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry30_hv_d,  entry30_hv_q         : std_ulogic;
signal     entry30_ds_d,  entry30_ds_q         : std_ulogic;
signal     entry30_pid_d,  entry30_pid_q       : std_ulogic_vector(0 to 7);
signal     entry30_cmpmask_d,  entry30_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry30_parity_d,  entry30_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry30_sel          : std_ulogic_vector(0 to 1);
signal     entry30_inval           : std_ulogic;
signal     entry30_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry30_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry30_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     entry31_epn_d,  entry31_epn_q       : std_ulogic_vector(0 to 51);
signal     entry31_xbit_d,  entry31_xbit_q     : std_ulogic;
signal     entry31_size_d,  entry31_size_q     : std_ulogic_vector(0 to 2);
signal     entry31_v_d,  entry31_v_q           : std_ulogic;
signal     entry31_thdid_d,  entry31_thdid_q   : std_ulogic_vector(0 to 3);
signal     entry31_class_d,  entry31_class_q   : std_ulogic_vector(0 to 1);
signal     entry31_extclass_d,  entry31_extclass_q   : std_ulogic_vector(0 to 1);
signal     entry31_hv_d,  entry31_hv_q         : std_ulogic;
signal     entry31_ds_d,  entry31_ds_q         : std_ulogic;
signal     entry31_pid_d,  entry31_pid_q       : std_ulogic_vector(0 to 7);
signal     entry31_cmpmask_d,  entry31_cmpmask_q       : std_ulogic_vector(0 to 8);
signal     entry31_parity_d,  entry31_parity_q  : std_ulogic_vector(0 to 9);
signal     wr_entry31_sel          : std_ulogic_vector(0 to 1);
signal     entry31_inval           : std_ulogic;
signal     entry31_v_muxsel        : std_ulogic_vector(0 to 1);
signal     entry31_cam_vec     : std_ulogic_vector(0 to cam_data_width-1);
signal     entry31_array_vec   : std_ulogic_vector(0 to array_data_width-1);
signal     cam_cmp_data_muxsel  : std_ulogic_vector(0 to 5);
signal     rd_cam_data_muxsel  : std_ulogic_vector(0 to 5);
signal     cam_cmp_data_np1      : std_ulogic_vector(0 to cam_data_width-1);
signal     array_cmp_data_np1    : std_ulogic_vector(0 to array_data_width-1);
signal wr_array_data_bram  : std_ulogic_vector(0 to 72);
signal rd_array_data_d_std      : std_logic_vector(0 to 72);
signal array_cmp_data_bram_std  : std_logic_vector(0 to 55);
signal array_cmp_data_bramp_std : std_logic_vector(66 to 72);
signal rd_array_data_d         : std_ulogic_vector(0 to array_data_width-1);
signal rd_array_data_q        : std_ulogic_vector(0 to array_data_width-1);
signal cam_cmp_data_d          : std_ulogic_vector(0 to cam_data_width-1);
signal cam_cmp_data_q         : std_ulogic_vector(0 to cam_data_width-1);
signal cam_cmp_parity_d          : std_ulogic_vector(0 to 9);
signal cam_cmp_parity_q         : std_ulogic_vector(0 to 9);
signal rd_cam_data_d           : std_ulogic_vector(0 to cam_data_width-1);
signal rd_cam_data_q          : std_ulogic_vector(0 to cam_data_width-1);
signal entry_match_d           : std_ulogic_vector(0 to num_entry-1);
signal entry_match_q          : std_ulogic_vector(0 to num_entry-1);
signal match_vec             : std_ulogic_vector(0 to num_entry-1);
signal cam_hit_entry_d         : std_ulogic_vector(0 to num_entry_log2-1);
signal cam_hit_entry_q        : std_ulogic_vector(0 to num_entry_log2-1);
signal cam_hit_d               : std_ulogic;
signal cam_hit_q              : std_ulogic;
signal toggle_d     : std_ulogic;
signal toggle_q     : std_ulogic;
signal toggle2x_d   : std_ulogic;
signal toggle2x_q   : std_ulogic;
begin

clk   <= not nclk.clk;
clk2x <= nclk.clk2x;
rlatch: process (clk)
begin
if(rising_edge(clk)) then
sreset_q             <= nclk.sreset;
end if;
end process;
tlatch: process (nclk.clk,sreset_q)
begin
if(rising_edge(nclk.clk)) then
if (sreset_q = '1') then
toggle_q  <= '1';
else
toggle_q  <= toggle_d;
end if;
end if;
end process;
flatch: process (nclk.clk2x)
begin
if(rising_edge(nclk.clk2x)) then
toggle2x_q <= toggle2x_d;
gate_fq  <= gate_d;
end if;
end process;
toggle_d   <= not toggle_q;
toggle2x_d <= toggle_q;
gate_d <= toggle_q xor toggle2x_q;
slatch: process (nclk,sreset_q)
begin
if(rising_edge(nclk.clk)) then
if (sreset_q = '1') then
cam_cmp_data_q   <= (others => '0');
cam_cmp_parity_q <= (others => '0');
rd_cam_data_q    <= (others => '0');
rd_array_data_q  <= (others => '0');
entry_match_q    <= (others => '0');
cam_hit_entry_q  <= (others => '0');
cam_hit_q        <= '0';
comp_addr_np1_q  <= (others => '0');
rpn_np2_q        <= (others => '0');
attr_np2_q       <= (others => '0');
entry0_size_q        <= (others => '0');
entry0_xbit_q        <= '0';
entry0_epn_q         <= (others => '0');
entry0_class_q       <= (others => '0');
entry0_extclass_q    <= (others => '0');
entry0_hv_q          <= '0';
entry0_ds_q          <= '0';
entry0_thdid_q       <= (others => '0');
entry0_pid_q         <= (others => '0');
entry0_v_q           <= '0';
entry0_parity_q      <= (others => '0');
entry0_cmpmask_q     <= (others => '0');
entry1_size_q        <= (others => '0');
entry1_xbit_q        <= '0';
entry1_epn_q         <= (others => '0');
entry1_class_q       <= (others => '0');
entry1_extclass_q    <= (others => '0');
entry1_hv_q          <= '0';
entry1_ds_q          <= '0';
entry1_thdid_q       <= (others => '0');
entry1_pid_q         <= (others => '0');
entry1_v_q           <= '0';
entry1_parity_q      <= (others => '0');
entry1_cmpmask_q     <= (others => '0');
entry2_size_q        <= (others => '0');
entry2_xbit_q        <= '0';
entry2_epn_q         <= (others => '0');
entry2_class_q       <= (others => '0');
entry2_extclass_q    <= (others => '0');
entry2_hv_q          <= '0';
entry2_ds_q          <= '0';
entry2_thdid_q       <= (others => '0');
entry2_pid_q         <= (others => '0');
entry2_v_q           <= '0';
entry2_parity_q      <= (others => '0');
entry2_cmpmask_q     <= (others => '0');
entry3_size_q        <= (others => '0');
entry3_xbit_q        <= '0';
entry3_epn_q         <= (others => '0');
entry3_class_q       <= (others => '0');
entry3_extclass_q    <= (others => '0');
entry3_hv_q          <= '0';
entry3_ds_q          <= '0';
entry3_thdid_q       <= (others => '0');
entry3_pid_q         <= (others => '0');
entry3_v_q           <= '0';
entry3_parity_q      <= (others => '0');
entry3_cmpmask_q     <= (others => '0');
entry4_size_q        <= (others => '0');
entry4_xbit_q        <= '0';
entry4_epn_q         <= (others => '0');
entry4_class_q       <= (others => '0');
entry4_extclass_q    <= (others => '0');
entry4_hv_q          <= '0';
entry4_ds_q          <= '0';
entry4_thdid_q       <= (others => '0');
entry4_pid_q         <= (others => '0');
entry4_v_q           <= '0';
entry4_parity_q      <= (others => '0');
entry4_cmpmask_q     <= (others => '0');
entry5_size_q        <= (others => '0');
entry5_xbit_q        <= '0';
entry5_epn_q         <= (others => '0');
entry5_class_q       <= (others => '0');
entry5_extclass_q    <= (others => '0');
entry5_hv_q          <= '0';
entry5_ds_q          <= '0';
entry5_thdid_q       <= (others => '0');
entry5_pid_q         <= (others => '0');
entry5_v_q           <= '0';
entry5_parity_q      <= (others => '0');
entry5_cmpmask_q     <= (others => '0');
entry6_size_q        <= (others => '0');
entry6_xbit_q        <= '0';
entry6_epn_q         <= (others => '0');
entry6_class_q       <= (others => '0');
entry6_extclass_q    <= (others => '0');
entry6_hv_q          <= '0';
entry6_ds_q          <= '0';
entry6_thdid_q       <= (others => '0');
entry6_pid_q         <= (others => '0');
entry6_v_q           <= '0';
entry6_parity_q      <= (others => '0');
entry6_cmpmask_q     <= (others => '0');
entry7_size_q        <= (others => '0');
entry7_xbit_q        <= '0';
entry7_epn_q         <= (others => '0');
entry7_class_q       <= (others => '0');
entry7_extclass_q    <= (others => '0');
entry7_hv_q          <= '0';
entry7_ds_q          <= '0';
entry7_thdid_q       <= (others => '0');
entry7_pid_q         <= (others => '0');
entry7_v_q           <= '0';
entry7_parity_q      <= (others => '0');
entry7_cmpmask_q     <= (others => '0');
entry8_size_q        <= (others => '0');
entry8_xbit_q        <= '0';
entry8_epn_q         <= (others => '0');
entry8_class_q       <= (others => '0');
entry8_extclass_q    <= (others => '0');
entry8_hv_q          <= '0';
entry8_ds_q          <= '0';
entry8_thdid_q       <= (others => '0');
entry8_pid_q         <= (others => '0');
entry8_v_q           <= '0';
entry8_parity_q      <= (others => '0');
entry8_cmpmask_q     <= (others => '0');
entry9_size_q        <= (others => '0');
entry9_xbit_q        <= '0';
entry9_epn_q         <= (others => '0');
entry9_class_q       <= (others => '0');
entry9_extclass_q    <= (others => '0');
entry9_hv_q          <= '0';
entry9_ds_q          <= '0';
entry9_thdid_q       <= (others => '0');
entry9_pid_q         <= (others => '0');
entry9_v_q           <= '0';
entry9_parity_q      <= (others => '0');
entry9_cmpmask_q     <= (others => '0');
entry10_size_q       <= (others => '0');
entry10_xbit_q       <= '0';
entry10_epn_q        <= (others => '0');
entry10_class_q      <= (others => '0');
entry10_extclass_q   <= (others => '0');
entry10_hv_q         <= '0';
entry10_ds_q         <= '0';
entry10_thdid_q      <= (others => '0');
entry10_pid_q        <= (others => '0');
entry10_v_q          <= '0';
entry10_parity_q     <= (others => '0');
entry10_cmpmask_q    <= (others => '0');
entry11_size_q       <= (others => '0');
entry11_xbit_q       <= '0';
entry11_epn_q        <= (others => '0');
entry11_class_q      <= (others => '0');
entry11_extclass_q   <= (others => '0');
entry11_hv_q         <= '0';
entry11_ds_q         <= '0';
entry11_thdid_q      <= (others => '0');
entry11_pid_q        <= (others => '0');
entry11_v_q          <= '0';
entry11_parity_q     <= (others => '0');
entry11_cmpmask_q    <= (others => '0');
entry12_size_q       <= (others => '0');
entry12_xbit_q       <= '0';
entry12_epn_q        <= (others => '0');
entry12_class_q      <= (others => '0');
entry12_extclass_q   <= (others => '0');
entry12_hv_q         <= '0';
entry12_ds_q         <= '0';
entry12_thdid_q      <= (others => '0');
entry12_pid_q        <= (others => '0');
entry12_v_q          <= '0';
entry12_parity_q     <= (others => '0');
entry12_cmpmask_q    <= (others => '0');
entry13_size_q       <= (others => '0');
entry13_xbit_q       <= '0';
entry13_epn_q        <= (others => '0');
entry13_class_q      <= (others => '0');
entry13_extclass_q   <= (others => '0');
entry13_hv_q         <= '0';
entry13_ds_q         <= '0';
entry13_thdid_q      <= (others => '0');
entry13_pid_q        <= (others => '0');
entry13_v_q          <= '0';
entry13_parity_q     <= (others => '0');
entry13_cmpmask_q    <= (others => '0');
entry14_size_q       <= (others => '0');
entry14_xbit_q       <= '0';
entry14_epn_q        <= (others => '0');
entry14_class_q      <= (others => '0');
entry14_extclass_q   <= (others => '0');
entry14_hv_q         <= '0';
entry14_ds_q         <= '0';
entry14_thdid_q      <= (others => '0');
entry14_pid_q        <= (others => '0');
entry14_v_q          <= '0';
entry14_parity_q     <= (others => '0');
entry14_cmpmask_q    <= (others => '0');
entry15_size_q       <= (others => '0');
entry15_xbit_q       <= '0';
entry15_epn_q        <= (others => '0');
entry15_class_q      <= (others => '0');
entry15_extclass_q   <= (others => '0');
entry15_hv_q         <= '0';
entry15_ds_q         <= '0';
entry15_thdid_q      <= (others => '0');
entry15_pid_q        <= (others => '0');
entry15_v_q          <= '0';
entry15_parity_q     <= (others => '0');
entry15_cmpmask_q    <= (others => '0');
entry16_size_q       <= (others => '0');
entry16_xbit_q       <= '0';
entry16_epn_q        <= (others => '0');
entry16_class_q      <= (others => '0');
entry16_extclass_q   <= (others => '0');
entry16_hv_q         <= '0';
entry16_ds_q         <= '0';
entry16_thdid_q      <= (others => '0');
entry16_pid_q        <= (others => '0');
entry16_v_q          <= '0';
entry16_parity_q     <= (others => '0');
entry16_cmpmask_q    <= (others => '0');
entry17_size_q       <= (others => '0');
entry17_xbit_q       <= '0';
entry17_epn_q        <= (others => '0');
entry17_class_q      <= (others => '0');
entry17_extclass_q   <= (others => '0');
entry17_hv_q         <= '0';
entry17_ds_q         <= '0';
entry17_thdid_q      <= (others => '0');
entry17_pid_q        <= (others => '0');
entry17_v_q          <= '0';
entry17_parity_q     <= (others => '0');
entry17_cmpmask_q    <= (others => '0');
entry18_size_q       <= (others => '0');
entry18_xbit_q       <= '0';
entry18_epn_q        <= (others => '0');
entry18_class_q      <= (others => '0');
entry18_extclass_q   <= (others => '0');
entry18_hv_q         <= '0';
entry18_ds_q         <= '0';
entry18_thdid_q      <= (others => '0');
entry18_pid_q        <= (others => '0');
entry18_v_q          <= '0';
entry18_parity_q     <= (others => '0');
entry18_cmpmask_q    <= (others => '0');
entry19_size_q       <= (others => '0');
entry19_xbit_q       <= '0';
entry19_epn_q        <= (others => '0');
entry19_class_q      <= (others => '0');
entry19_extclass_q   <= (others => '0');
entry19_hv_q         <= '0';
entry19_ds_q         <= '0';
entry19_thdid_q      <= (others => '0');
entry19_pid_q        <= (others => '0');
entry19_v_q          <= '0';
entry19_parity_q     <= (others => '0');
entry19_cmpmask_q    <= (others => '0');
entry20_size_q       <= (others => '0');
entry20_xbit_q       <= '0';
entry20_epn_q        <= (others => '0');
entry20_class_q      <= (others => '0');
entry20_extclass_q   <= (others => '0');
entry20_hv_q         <= '0';
entry20_ds_q         <= '0';
entry20_thdid_q      <= (others => '0');
entry20_pid_q        <= (others => '0');
entry20_v_q          <= '0';
entry20_parity_q     <= (others => '0');
entry20_cmpmask_q    <= (others => '0');
entry21_size_q       <= (others => '0');
entry21_xbit_q       <= '0';
entry21_epn_q        <= (others => '0');
entry21_class_q      <= (others => '0');
entry21_extclass_q   <= (others => '0');
entry21_hv_q         <= '0';
entry21_ds_q         <= '0';
entry21_thdid_q      <= (others => '0');
entry21_pid_q        <= (others => '0');
entry21_v_q          <= '0';
entry21_parity_q     <= (others => '0');
entry21_cmpmask_q    <= (others => '0');
entry22_size_q       <= (others => '0');
entry22_xbit_q       <= '0';
entry22_epn_q        <= (others => '0');
entry22_class_q      <= (others => '0');
entry22_extclass_q   <= (others => '0');
entry22_hv_q         <= '0';
entry22_ds_q         <= '0';
entry22_thdid_q      <= (others => '0');
entry22_pid_q        <= (others => '0');
entry22_v_q          <= '0';
entry22_parity_q     <= (others => '0');
entry22_cmpmask_q    <= (others => '0');
entry23_size_q       <= (others => '0');
entry23_xbit_q       <= '0';
entry23_epn_q        <= (others => '0');
entry23_class_q      <= (others => '0');
entry23_extclass_q   <= (others => '0');
entry23_hv_q         <= '0';
entry23_ds_q         <= '0';
entry23_thdid_q      <= (others => '0');
entry23_pid_q        <= (others => '0');
entry23_v_q          <= '0';
entry23_parity_q     <= (others => '0');
entry23_cmpmask_q    <= (others => '0');
entry24_size_q       <= (others => '0');
entry24_xbit_q       <= '0';
entry24_epn_q        <= (others => '0');
entry24_class_q      <= (others => '0');
entry24_extclass_q   <= (others => '0');
entry24_hv_q         <= '0';
entry24_ds_q         <= '0';
entry24_thdid_q      <= (others => '0');
entry24_pid_q        <= (others => '0');
entry24_v_q          <= '0';
entry24_parity_q     <= (others => '0');
entry24_cmpmask_q    <= (others => '0');
entry25_size_q       <= (others => '0');
entry25_xbit_q       <= '0';
entry25_epn_q        <= (others => '0');
entry25_class_q      <= (others => '0');
entry25_extclass_q   <= (others => '0');
entry25_hv_q         <= '0';
entry25_ds_q         <= '0';
entry25_thdid_q      <= (others => '0');
entry25_pid_q        <= (others => '0');
entry25_v_q          <= '0';
entry25_parity_q     <= (others => '0');
entry25_cmpmask_q    <= (others => '0');
entry26_size_q       <= (others => '0');
entry26_xbit_q       <= '0';
entry26_epn_q        <= (others => '0');
entry26_class_q      <= (others => '0');
entry26_extclass_q   <= (others => '0');
entry26_hv_q         <= '0';
entry26_ds_q         <= '0';
entry26_thdid_q      <= (others => '0');
entry26_pid_q        <= (others => '0');
entry26_v_q          <= '0';
entry26_parity_q     <= (others => '0');
entry26_cmpmask_q    <= (others => '0');
entry27_size_q       <= (others => '0');
entry27_xbit_q       <= '0';
entry27_epn_q        <= (others => '0');
entry27_class_q      <= (others => '0');
entry27_extclass_q   <= (others => '0');
entry27_hv_q         <= '0';
entry27_ds_q         <= '0';
entry27_thdid_q      <= (others => '0');
entry27_pid_q        <= (others => '0');
entry27_v_q          <= '0';
entry27_parity_q     <= (others => '0');
entry27_cmpmask_q    <= (others => '0');
entry28_size_q       <= (others => '0');
entry28_xbit_q       <= '0';
entry28_epn_q        <= (others => '0');
entry28_class_q      <= (others => '0');
entry28_extclass_q   <= (others => '0');
entry28_hv_q         <= '0';
entry28_ds_q         <= '0';
entry28_thdid_q      <= (others => '0');
entry28_pid_q        <= (others => '0');
entry28_v_q          <= '0';
entry28_parity_q     <= (others => '0');
entry28_cmpmask_q    <= (others => '0');
entry29_size_q       <= (others => '0');
entry29_xbit_q       <= '0';
entry29_epn_q        <= (others => '0');
entry29_class_q      <= (others => '0');
entry29_extclass_q   <= (others => '0');
entry29_hv_q         <= '0';
entry29_ds_q         <= '0';
entry29_thdid_q      <= (others => '0');
entry29_pid_q        <= (others => '0');
entry29_v_q          <= '0';
entry29_parity_q     <= (others => '0');
entry29_cmpmask_q    <= (others => '0');
entry30_size_q       <= (others => '0');
entry30_xbit_q       <= '0';
entry30_epn_q        <= (others => '0');
entry30_class_q      <= (others => '0');
entry30_extclass_q   <= (others => '0');
entry30_hv_q         <= '0';
entry30_ds_q         <= '0';
entry30_thdid_q      <= (others => '0');
entry30_pid_q        <= (others => '0');
entry30_v_q          <= '0';
entry30_parity_q     <= (others => '0');
entry30_cmpmask_q    <= (others => '0');
entry31_size_q       <= (others => '0');
entry31_xbit_q       <= '0';
entry31_epn_q        <= (others => '0');
entry31_class_q      <= (others => '0');
entry31_extclass_q   <= (others => '0');
entry31_hv_q         <= '0';
entry31_ds_q         <= '0';
entry31_thdid_q      <= (others => '0');
entry31_pid_q        <= (others => '0');
entry31_v_q          <= '0';
entry31_parity_q     <= (others => '0');
entry31_cmpmask_q    <= (others => '0');
else
cam_cmp_data_q   <= cam_cmp_data_d;
rd_cam_data_q    <= rd_cam_data_d;
rd_array_data_q  <= rd_array_data_d;
entry_match_q    <= entry_match_d;
cam_hit_entry_q  <= cam_hit_entry_d;
cam_hit_q        <= cam_hit_d;
cam_cmp_parity_q <= cam_cmp_parity_d;
comp_addr_np1_q  <= comp_addr_np1_d;
rpn_np2_q        <= rpn_np2_d;
attr_np2_q       <= attr_np2_d;
entry0_size_q   <= entry0_size_d;
entry0_xbit_q   <= entry0_xbit_d;
entry0_epn_q   <= entry0_epn_d;
entry0_class_q   <= entry0_class_d;
entry0_extclass_q   <= entry0_extclass_d;
entry0_hv_q   <= entry0_hv_d;
entry0_ds_q   <= entry0_ds_d;
entry0_thdid_q   <= entry0_thdid_d;
entry0_pid_q   <= entry0_pid_d;
entry0_v_q   <= entry0_v_d;
entry0_parity_q   <= entry0_parity_d;
entry0_cmpmask_q   <= entry0_cmpmask_d;
entry1_size_q   <= entry1_size_d;
entry1_xbit_q   <= entry1_xbit_d;
entry1_epn_q   <= entry1_epn_d;
entry1_class_q   <= entry1_class_d;
entry1_extclass_q   <= entry1_extclass_d;
entry1_hv_q   <= entry1_hv_d;
entry1_ds_q   <= entry1_ds_d;
entry1_thdid_q   <= entry1_thdid_d;
entry1_pid_q   <= entry1_pid_d;
entry1_v_q   <= entry1_v_d;
entry1_parity_q   <= entry1_parity_d;
entry1_cmpmask_q   <= entry1_cmpmask_d;
entry2_size_q   <= entry2_size_d;
entry2_xbit_q   <= entry2_xbit_d;
entry2_epn_q   <= entry2_epn_d;
entry2_class_q   <= entry2_class_d;
entry2_extclass_q   <= entry2_extclass_d;
entry2_hv_q   <= entry2_hv_d;
entry2_ds_q   <= entry2_ds_d;
entry2_thdid_q   <= entry2_thdid_d;
entry2_pid_q   <= entry2_pid_d;
entry2_v_q   <= entry2_v_d;
entry2_parity_q   <= entry2_parity_d;
entry2_cmpmask_q   <= entry2_cmpmask_d;
entry3_size_q   <= entry3_size_d;
entry3_xbit_q   <= entry3_xbit_d;
entry3_epn_q   <= entry3_epn_d;
entry3_class_q   <= entry3_class_d;
entry3_extclass_q   <= entry3_extclass_d;
entry3_hv_q   <= entry3_hv_d;
entry3_ds_q   <= entry3_ds_d;
entry3_thdid_q   <= entry3_thdid_d;
entry3_pid_q   <= entry3_pid_d;
entry3_v_q   <= entry3_v_d;
entry3_parity_q   <= entry3_parity_d;
entry3_cmpmask_q   <= entry3_cmpmask_d;
entry4_size_q   <= entry4_size_d;
entry4_xbit_q   <= entry4_xbit_d;
entry4_epn_q   <= entry4_epn_d;
entry4_class_q   <= entry4_class_d;
entry4_extclass_q   <= entry4_extclass_d;
entry4_hv_q   <= entry4_hv_d;
entry4_ds_q   <= entry4_ds_d;
entry4_thdid_q   <= entry4_thdid_d;
entry4_pid_q   <= entry4_pid_d;
entry4_v_q   <= entry4_v_d;
entry4_parity_q   <= entry4_parity_d;
entry4_cmpmask_q   <= entry4_cmpmask_d;
entry5_size_q   <= entry5_size_d;
entry5_xbit_q   <= entry5_xbit_d;
entry5_epn_q   <= entry5_epn_d;
entry5_class_q   <= entry5_class_d;
entry5_extclass_q   <= entry5_extclass_d;
entry5_hv_q   <= entry5_hv_d;
entry5_ds_q   <= entry5_ds_d;
entry5_thdid_q   <= entry5_thdid_d;
entry5_pid_q   <= entry5_pid_d;
entry5_v_q   <= entry5_v_d;
entry5_parity_q   <= entry5_parity_d;
entry5_cmpmask_q   <= entry5_cmpmask_d;
entry6_size_q   <= entry6_size_d;
entry6_xbit_q   <= entry6_xbit_d;
entry6_epn_q   <= entry6_epn_d;
entry6_class_q   <= entry6_class_d;
entry6_extclass_q   <= entry6_extclass_d;
entry6_hv_q   <= entry6_hv_d;
entry6_ds_q   <= entry6_ds_d;
entry6_thdid_q   <= entry6_thdid_d;
entry6_pid_q   <= entry6_pid_d;
entry6_v_q   <= entry6_v_d;
entry6_parity_q   <= entry6_parity_d;
entry6_cmpmask_q   <= entry6_cmpmask_d;
entry7_size_q   <= entry7_size_d;
entry7_xbit_q   <= entry7_xbit_d;
entry7_epn_q   <= entry7_epn_d;
entry7_class_q   <= entry7_class_d;
entry7_extclass_q   <= entry7_extclass_d;
entry7_hv_q   <= entry7_hv_d;
entry7_ds_q   <= entry7_ds_d;
entry7_thdid_q   <= entry7_thdid_d;
entry7_pid_q   <= entry7_pid_d;
entry7_v_q   <= entry7_v_d;
entry7_parity_q   <= entry7_parity_d;
entry7_cmpmask_q   <= entry7_cmpmask_d;
entry8_size_q   <= entry8_size_d;
entry8_xbit_q   <= entry8_xbit_d;
entry8_epn_q   <= entry8_epn_d;
entry8_class_q   <= entry8_class_d;
entry8_extclass_q   <= entry8_extclass_d;
entry8_hv_q   <= entry8_hv_d;
entry8_ds_q   <= entry8_ds_d;
entry8_thdid_q   <= entry8_thdid_d;
entry8_pid_q   <= entry8_pid_d;
entry8_v_q   <= entry8_v_d;
entry8_parity_q   <= entry8_parity_d;
entry8_cmpmask_q   <= entry8_cmpmask_d;
entry9_size_q   <= entry9_size_d;
entry9_xbit_q   <= entry9_xbit_d;
entry9_epn_q   <= entry9_epn_d;
entry9_class_q   <= entry9_class_d;
entry9_extclass_q   <= entry9_extclass_d;
entry9_hv_q   <= entry9_hv_d;
entry9_ds_q   <= entry9_ds_d;
entry9_thdid_q   <= entry9_thdid_d;
entry9_pid_q   <= entry9_pid_d;
entry9_v_q   <= entry9_v_d;
entry9_parity_q   <= entry9_parity_d;
entry9_cmpmask_q   <= entry9_cmpmask_d;
entry10_size_q  <= entry10_size_d;
entry10_xbit_q  <= entry10_xbit_d;
entry10_epn_q  <= entry10_epn_d;
entry10_class_q  <= entry10_class_d;
entry10_extclass_q  <= entry10_extclass_d;
entry10_hv_q  <= entry10_hv_d;
entry10_ds_q  <= entry10_ds_d;
entry10_thdid_q  <= entry10_thdid_d;
entry10_pid_q  <= entry10_pid_d;
entry10_v_q  <= entry10_v_d;
entry10_parity_q  <= entry10_parity_d;
entry10_cmpmask_q  <= entry10_cmpmask_d;
entry11_size_q  <= entry11_size_d;
entry11_xbit_q  <= entry11_xbit_d;
entry11_epn_q  <= entry11_epn_d;
entry11_class_q  <= entry11_class_d;
entry11_extclass_q  <= entry11_extclass_d;
entry11_hv_q  <= entry11_hv_d;
entry11_ds_q  <= entry11_ds_d;
entry11_thdid_q  <= entry11_thdid_d;
entry11_pid_q  <= entry11_pid_d;
entry11_v_q  <= entry11_v_d;
entry11_parity_q  <= entry11_parity_d;
entry11_cmpmask_q  <= entry11_cmpmask_d;
entry12_size_q  <= entry12_size_d;
entry12_xbit_q  <= entry12_xbit_d;
entry12_epn_q  <= entry12_epn_d;
entry12_class_q  <= entry12_class_d;
entry12_extclass_q  <= entry12_extclass_d;
entry12_hv_q  <= entry12_hv_d;
entry12_ds_q  <= entry12_ds_d;
entry12_thdid_q  <= entry12_thdid_d;
entry12_pid_q  <= entry12_pid_d;
entry12_v_q  <= entry12_v_d;
entry12_parity_q  <= entry12_parity_d;
entry12_cmpmask_q  <= entry12_cmpmask_d;
entry13_size_q  <= entry13_size_d;
entry13_xbit_q  <= entry13_xbit_d;
entry13_epn_q  <= entry13_epn_d;
entry13_class_q  <= entry13_class_d;
entry13_extclass_q  <= entry13_extclass_d;
entry13_hv_q  <= entry13_hv_d;
entry13_ds_q  <= entry13_ds_d;
entry13_thdid_q  <= entry13_thdid_d;
entry13_pid_q  <= entry13_pid_d;
entry13_v_q  <= entry13_v_d;
entry13_parity_q  <= entry13_parity_d;
entry13_cmpmask_q  <= entry13_cmpmask_d;
entry14_size_q  <= entry14_size_d;
entry14_xbit_q  <= entry14_xbit_d;
entry14_epn_q  <= entry14_epn_d;
entry14_class_q  <= entry14_class_d;
entry14_extclass_q  <= entry14_extclass_d;
entry14_hv_q  <= entry14_hv_d;
entry14_ds_q  <= entry14_ds_d;
entry14_thdid_q  <= entry14_thdid_d;
entry14_pid_q  <= entry14_pid_d;
entry14_v_q  <= entry14_v_d;
entry14_parity_q  <= entry14_parity_d;
entry14_cmpmask_q  <= entry14_cmpmask_d;
entry15_size_q  <= entry15_size_d;
entry15_xbit_q  <= entry15_xbit_d;
entry15_epn_q  <= entry15_epn_d;
entry15_class_q  <= entry15_class_d;
entry15_extclass_q  <= entry15_extclass_d;
entry15_hv_q  <= entry15_hv_d;
entry15_ds_q  <= entry15_ds_d;
entry15_thdid_q  <= entry15_thdid_d;
entry15_pid_q  <= entry15_pid_d;
entry15_v_q  <= entry15_v_d;
entry15_parity_q  <= entry15_parity_d;
entry15_cmpmask_q  <= entry15_cmpmask_d;
entry16_size_q  <= entry16_size_d;
entry16_xbit_q  <= entry16_xbit_d;
entry16_epn_q  <= entry16_epn_d;
entry16_class_q  <= entry16_class_d;
entry16_extclass_q  <= entry16_extclass_d;
entry16_hv_q  <= entry16_hv_d;
entry16_ds_q  <= entry16_ds_d;
entry16_thdid_q  <= entry16_thdid_d;
entry16_pid_q  <= entry16_pid_d;
entry16_v_q  <= entry16_v_d;
entry16_parity_q  <= entry16_parity_d;
entry16_cmpmask_q  <= entry16_cmpmask_d;
entry17_size_q  <= entry17_size_d;
entry17_xbit_q  <= entry17_xbit_d;
entry17_epn_q  <= entry17_epn_d;
entry17_class_q  <= entry17_class_d;
entry17_extclass_q  <= entry17_extclass_d;
entry17_hv_q  <= entry17_hv_d;
entry17_ds_q  <= entry17_ds_d;
entry17_thdid_q  <= entry17_thdid_d;
entry17_pid_q  <= entry17_pid_d;
entry17_v_q  <= entry17_v_d;
entry17_parity_q  <= entry17_parity_d;
entry17_cmpmask_q  <= entry17_cmpmask_d;
entry18_size_q  <= entry18_size_d;
entry18_xbit_q  <= entry18_xbit_d;
entry18_epn_q  <= entry18_epn_d;
entry18_class_q  <= entry18_class_d;
entry18_extclass_q  <= entry18_extclass_d;
entry18_hv_q  <= entry18_hv_d;
entry18_ds_q  <= entry18_ds_d;
entry18_thdid_q  <= entry18_thdid_d;
entry18_pid_q  <= entry18_pid_d;
entry18_v_q  <= entry18_v_d;
entry18_parity_q  <= entry18_parity_d;
entry18_cmpmask_q  <= entry18_cmpmask_d;
entry19_size_q  <= entry19_size_d;
entry19_xbit_q  <= entry19_xbit_d;
entry19_epn_q  <= entry19_epn_d;
entry19_class_q  <= entry19_class_d;
entry19_extclass_q  <= entry19_extclass_d;
entry19_hv_q  <= entry19_hv_d;
entry19_ds_q  <= entry19_ds_d;
entry19_thdid_q  <= entry19_thdid_d;
entry19_pid_q  <= entry19_pid_d;
entry19_v_q  <= entry19_v_d;
entry19_parity_q  <= entry19_parity_d;
entry19_cmpmask_q  <= entry19_cmpmask_d;
entry20_size_q  <= entry20_size_d;
entry20_xbit_q  <= entry20_xbit_d;
entry20_epn_q  <= entry20_epn_d;
entry20_class_q  <= entry20_class_d;
entry20_extclass_q  <= entry20_extclass_d;
entry20_hv_q  <= entry20_hv_d;
entry20_ds_q  <= entry20_ds_d;
entry20_thdid_q  <= entry20_thdid_d;
entry20_pid_q  <= entry20_pid_d;
entry20_v_q  <= entry20_v_d;
entry20_parity_q  <= entry20_parity_d;
entry20_cmpmask_q  <= entry20_cmpmask_d;
entry21_size_q  <= entry21_size_d;
entry21_xbit_q  <= entry21_xbit_d;
entry21_epn_q  <= entry21_epn_d;
entry21_class_q  <= entry21_class_d;
entry21_extclass_q  <= entry21_extclass_d;
entry21_hv_q  <= entry21_hv_d;
entry21_ds_q  <= entry21_ds_d;
entry21_thdid_q  <= entry21_thdid_d;
entry21_pid_q  <= entry21_pid_d;
entry21_v_q  <= entry21_v_d;
entry21_parity_q  <= entry21_parity_d;
entry21_cmpmask_q  <= entry21_cmpmask_d;
entry22_size_q  <= entry22_size_d;
entry22_xbit_q  <= entry22_xbit_d;
entry22_epn_q  <= entry22_epn_d;
entry22_class_q  <= entry22_class_d;
entry22_extclass_q  <= entry22_extclass_d;
entry22_hv_q  <= entry22_hv_d;
entry22_ds_q  <= entry22_ds_d;
entry22_thdid_q  <= entry22_thdid_d;
entry22_pid_q  <= entry22_pid_d;
entry22_v_q  <= entry22_v_d;
entry22_parity_q  <= entry22_parity_d;
entry22_cmpmask_q  <= entry22_cmpmask_d;
entry23_size_q  <= entry23_size_d;
entry23_xbit_q  <= entry23_xbit_d;
entry23_epn_q  <= entry23_epn_d;
entry23_class_q  <= entry23_class_d;
entry23_extclass_q  <= entry23_extclass_d;
entry23_hv_q  <= entry23_hv_d;
entry23_ds_q  <= entry23_ds_d;
entry23_thdid_q  <= entry23_thdid_d;
entry23_pid_q  <= entry23_pid_d;
entry23_v_q  <= entry23_v_d;
entry23_parity_q  <= entry23_parity_d;
entry23_cmpmask_q  <= entry23_cmpmask_d;
entry24_size_q  <= entry24_size_d;
entry24_xbit_q  <= entry24_xbit_d;
entry24_epn_q  <= entry24_epn_d;
entry24_class_q  <= entry24_class_d;
entry24_extclass_q  <= entry24_extclass_d;
entry24_hv_q  <= entry24_hv_d;
entry24_ds_q  <= entry24_ds_d;
entry24_thdid_q  <= entry24_thdid_d;
entry24_pid_q  <= entry24_pid_d;
entry24_v_q  <= entry24_v_d;
entry24_parity_q  <= entry24_parity_d;
entry24_cmpmask_q  <= entry24_cmpmask_d;
entry25_size_q  <= entry25_size_d;
entry25_xbit_q  <= entry25_xbit_d;
entry25_epn_q  <= entry25_epn_d;
entry25_class_q  <= entry25_class_d;
entry25_extclass_q  <= entry25_extclass_d;
entry25_hv_q  <= entry25_hv_d;
entry25_ds_q  <= entry25_ds_d;
entry25_thdid_q  <= entry25_thdid_d;
entry25_pid_q  <= entry25_pid_d;
entry25_v_q  <= entry25_v_d;
entry25_parity_q  <= entry25_parity_d;
entry25_cmpmask_q  <= entry25_cmpmask_d;
entry26_size_q  <= entry26_size_d;
entry26_xbit_q  <= entry26_xbit_d;
entry26_epn_q  <= entry26_epn_d;
entry26_class_q  <= entry26_class_d;
entry26_extclass_q  <= entry26_extclass_d;
entry26_hv_q  <= entry26_hv_d;
entry26_ds_q  <= entry26_ds_d;
entry26_thdid_q  <= entry26_thdid_d;
entry26_pid_q  <= entry26_pid_d;
entry26_v_q  <= entry26_v_d;
entry26_parity_q  <= entry26_parity_d;
entry26_cmpmask_q  <= entry26_cmpmask_d;
entry27_size_q  <= entry27_size_d;
entry27_xbit_q  <= entry27_xbit_d;
entry27_epn_q  <= entry27_epn_d;
entry27_class_q  <= entry27_class_d;
entry27_extclass_q  <= entry27_extclass_d;
entry27_hv_q  <= entry27_hv_d;
entry27_ds_q  <= entry27_ds_d;
entry27_thdid_q  <= entry27_thdid_d;
entry27_pid_q  <= entry27_pid_d;
entry27_v_q  <= entry27_v_d;
entry27_parity_q  <= entry27_parity_d;
entry27_cmpmask_q  <= entry27_cmpmask_d;
entry28_size_q  <= entry28_size_d;
entry28_xbit_q  <= entry28_xbit_d;
entry28_epn_q  <= entry28_epn_d;
entry28_class_q  <= entry28_class_d;
entry28_extclass_q  <= entry28_extclass_d;
entry28_hv_q  <= entry28_hv_d;
entry28_ds_q  <= entry28_ds_d;
entry28_thdid_q  <= entry28_thdid_d;
entry28_pid_q  <= entry28_pid_d;
entry28_v_q  <= entry28_v_d;
entry28_parity_q  <= entry28_parity_d;
entry28_cmpmask_q  <= entry28_cmpmask_d;
entry29_size_q  <= entry29_size_d;
entry29_xbit_q  <= entry29_xbit_d;
entry29_epn_q  <= entry29_epn_d;
entry29_class_q  <= entry29_class_d;
entry29_extclass_q  <= entry29_extclass_d;
entry29_hv_q  <= entry29_hv_d;
entry29_ds_q  <= entry29_ds_d;
entry29_thdid_q  <= entry29_thdid_d;
entry29_pid_q  <= entry29_pid_d;
entry29_v_q  <= entry29_v_d;
entry29_parity_q  <= entry29_parity_d;
entry29_cmpmask_q  <= entry29_cmpmask_d;
entry30_size_q  <= entry30_size_d;
entry30_xbit_q  <= entry30_xbit_d;
entry30_epn_q  <= entry30_epn_d;
entry30_class_q  <= entry30_class_d;
entry30_extclass_q  <= entry30_extclass_d;
entry30_hv_q  <= entry30_hv_d;
entry30_ds_q  <= entry30_ds_d;
entry30_thdid_q  <= entry30_thdid_d;
entry30_pid_q  <= entry30_pid_d;
entry30_v_q  <= entry30_v_d;
entry30_parity_q  <= entry30_parity_d;
entry30_cmpmask_q  <= entry30_cmpmask_d;
entry31_size_q  <= entry31_size_d;
entry31_xbit_q  <= entry31_xbit_d;
entry31_epn_q  <= entry31_epn_d;
entry31_class_q  <= entry31_class_d;
entry31_extclass_q  <= entry31_extclass_d;
entry31_hv_q  <= entry31_hv_d;
entry31_ds_q  <= entry31_ds_d;
entry31_thdid_q  <= entry31_thdid_d;
entry31_pid_q  <= entry31_pid_d;
entry31_v_q  <= entry31_v_d;
entry31_parity_q  <= entry31_parity_d;
entry31_cmpmask_q  <= entry31_cmpmask_d;
end if;
end if;
end process;
comp_addr_np1_d <= comp_addr(52-rpn_width to 51);
cam_hit_d <= '1' when (match_vec /= "00000000000000000000000000000000" and comp_request='1') else '0';
cam_hit_entry_d <= "00001" when match_vec(0 to 1)="01" else
                    "00010" when match_vec(0 to  2)="001" else
                    "00011" when match_vec(0 to  3)="0001" else
                    "00100" when match_vec(0 to  4)="00001" else
                    "00101" when match_vec(0 to  5)="000001" else
                    "00110" when match_vec(0 to  6)="0000001" else
                    "00111" when match_vec(0 to  7)="00000001" else
                    "01000" when match_vec(0 to  8)="000000001" else
                    "01001" when match_vec(0 to  9)="0000000001" else
                    "01010" when match_vec(0 to 10)="00000000001" else
                    "01011" when match_vec(0 to 11)="000000000001" else
                    "01100" when match_vec(0 to 12)="0000000000001" else
                    "01101" when match_vec(0 to 13)="00000000000001" else
                    "01110" when match_vec(0 to 14)="000000000000001" else
                    "01111" when match_vec(0 to 15)="0000000000000001" else
                    "10000" when match_vec(0 to 16)="00000000000000001" else
                    "10001" when match_vec(0 to 17)="000000000000000001" else
                    "10010" when match_vec(0 to 18)="0000000000000000001" else
                    "10011" when match_vec(0 to 19)="00000000000000000001" else
                    "10100" when match_vec(0 to 20)="000000000000000000001" else
                    "10101" when match_vec(0 to 21)="0000000000000000000001" else
                    "10110" when match_vec(0 to 22)="00000000000000000000001" else
                    "10111" when match_vec(0 to 23)="000000000000000000000001" else
                    "11000" when match_vec(0 to 24)="0000000000000000000000001" else
                    "11001" when match_vec(0 to 25)="00000000000000000000000001" else
                    "11010" when match_vec(0 to 26)="000000000000000000000000001" else
                    "11011" when match_vec(0 to 27)="0000000000000000000000000001" else
                    "11100" when match_vec(0 to 28)="00000000000000000000000000001" else
                    "11101" when match_vec(0 to 29)="000000000000000000000000000001" else
                    "11110" when match_vec(0 to 30)="0000000000000000000000000000001" else
                    "11111" when match_vec(0 to 31)="00000000000000000000000000000001" else
                    "00000";
entry_match_d <= match_vec when (comp_request='1') else (others => '0');
wr_entry0_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="00000"))   else '0';
wr_entry0_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="00000"))   else '0';
with wr_entry0_sel(0)   select
 entry0_epn_d(0   to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry0_epn_q(0   to 31)   when others;
with wr_entry0_sel(0)   select
 entry0_epn_d(32   to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry0_epn_q(32   to 51)  when others;
with wr_entry0_sel(0)   select
 entry0_xbit_d        <= wr_cam_data(52)  when '1',
                          entry0_xbit_q    when others;
with wr_entry0_sel(0)   select
 entry0_size_d        <= wr_cam_data(53 to 55)  when '1',
                          entry0_size_q(0   to 2)  when others;
with wr_entry0_sel(0)   select
 entry0_class_d       <= wr_cam_data(61 to 62)     when '1',
                          entry0_class_q(0   to 1)  when others;
with wr_entry0_sel(1)   select
 entry0_extclass_d    <= wr_cam_data(63 to 64)     when '1',
                          entry0_extclass_q(0   to 1)  when others;
with wr_entry0_sel(1)   select
 entry0_hv_d          <= wr_cam_data(65)   when '1',
                          entry0_hv_q       when others;
with wr_entry0_sel(1)   select
 entry0_ds_d          <= wr_cam_data(66)   when '1',
                          entry0_ds_q       when others;
with wr_entry0_sel(1)   select
 entry0_pid_d         <= wr_cam_data(67 to 74)     when '1',
                          entry0_pid_q(0   to 7)  when others;
with wr_entry0_sel(0)   select
 entry0_cmpmask_d       <= wr_cam_data(75 to 83)     when '1',
                          entry0_cmpmask_q    when others;
with wr_entry0_sel(0)   select
 entry0_parity_d(0   to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry0_parity_q(0   to 3)   when others;
with wr_entry0_sel(0)   select
 entry0_parity_d(4   to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry0_parity_q(4   to 6)  when others;
with wr_entry0_sel(0)   select
 entry0_parity_d(7)     <= wr_array_data(rpn_width+28)     when '1',
                          entry0_parity_q(7)    when others;
with wr_entry0_sel(1)   select
 entry0_parity_d(8)    <= wr_array_data(rpn_width+29)     when '1',
                            entry0_parity_q(8)    when others;
with wr_entry0_sel(1)   select
 entry0_parity_d(9)     <= wr_array_data(rpn_width+30)     when '1',
                          entry0_parity_q(9)    when others;
wr_entry1_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="00001"))   else '0';
wr_entry1_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="00001"))   else '0';
with wr_entry1_sel(0)   select
 entry1_epn_d(0   to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry1_epn_q(0   to 31)   when others;
with wr_entry1_sel(0)   select
 entry1_epn_d(32   to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry1_epn_q(32   to 51)  when others;
with wr_entry1_sel(0)   select
 entry1_xbit_d        <= wr_cam_data(52)  when '1',
                          entry1_xbit_q    when others;
with wr_entry1_sel(0)   select
 entry1_size_d        <= wr_cam_data(53 to 55)  when '1',
                          entry1_size_q(0   to 2)  when others;
with wr_entry1_sel(0)   select
 entry1_class_d       <= wr_cam_data(61 to 62)     when '1',
                          entry1_class_q(0   to 1)  when others;
with wr_entry1_sel(1)   select
 entry1_extclass_d    <= wr_cam_data(63 to 64)     when '1',
                          entry1_extclass_q(0   to 1)  when others;
with wr_entry1_sel(1)   select
 entry1_hv_d          <= wr_cam_data(65)   when '1',
                          entry1_hv_q       when others;
with wr_entry1_sel(1)   select
 entry1_ds_d          <= wr_cam_data(66)   when '1',
                          entry1_ds_q       when others;
with wr_entry1_sel(1)   select
 entry1_pid_d         <= wr_cam_data(67 to 74)     when '1',
                          entry1_pid_q(0   to 7)  when others;
with wr_entry1_sel(0)   select
 entry1_cmpmask_d       <= wr_cam_data(75 to 83)     when '1',
                          entry1_cmpmask_q    when others;
with wr_entry1_sel(0)   select
 entry1_parity_d(0   to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry1_parity_q(0   to 3)   when others;
with wr_entry1_sel(0)   select
 entry1_parity_d(4   to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry1_parity_q(4   to 6)  when others;
with wr_entry1_sel(0)   select
 entry1_parity_d(7)     <= wr_array_data(rpn_width+28)     when '1',
                          entry1_parity_q(7)    when others;
with wr_entry1_sel(1)   select
 entry1_parity_d(8)    <= wr_array_data(rpn_width+29)     when '1',
                            entry1_parity_q(8)    when others;
with wr_entry1_sel(1)   select
 entry1_parity_d(9)     <= wr_array_data(rpn_width+30)     when '1',
                          entry1_parity_q(9)    when others;
wr_entry2_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="00010"))   else '0';
wr_entry2_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="00010"))   else '0';
with wr_entry2_sel(0)   select
 entry2_epn_d(0   to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry2_epn_q(0   to 31)   when others;
with wr_entry2_sel(0)   select
 entry2_epn_d(32   to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry2_epn_q(32   to 51)  when others;
with wr_entry2_sel(0)   select
 entry2_xbit_d        <= wr_cam_data(52)  when '1',
                          entry2_xbit_q    when others;
with wr_entry2_sel(0)   select
 entry2_size_d        <= wr_cam_data(53 to 55)  when '1',
                          entry2_size_q(0   to 2)  when others;
with wr_entry2_sel(0)   select
 entry2_class_d       <= wr_cam_data(61 to 62)     when '1',
                          entry2_class_q(0   to 1)  when others;
with wr_entry2_sel(1)   select
 entry2_extclass_d    <= wr_cam_data(63 to 64)     when '1',
                          entry2_extclass_q(0   to 1)  when others;
with wr_entry2_sel(1)   select
 entry2_hv_d          <= wr_cam_data(65)   when '1',
                          entry2_hv_q       when others;
with wr_entry2_sel(1)   select
 entry2_ds_d          <= wr_cam_data(66)   when '1',
                          entry2_ds_q       when others;
with wr_entry2_sel(1)   select
 entry2_pid_d         <= wr_cam_data(67 to 74)     when '1',
                          entry2_pid_q(0   to 7)  when others;
with wr_entry2_sel(0)   select
 entry2_cmpmask_d       <= wr_cam_data(75 to 83)     when '1',
                          entry2_cmpmask_q    when others;
with wr_entry2_sel(0)   select
 entry2_parity_d(0   to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry2_parity_q(0   to 3)   when others;
with wr_entry2_sel(0)   select
 entry2_parity_d(4   to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry2_parity_q(4   to 6)  when others;
with wr_entry2_sel(0)   select
 entry2_parity_d(7)     <= wr_array_data(rpn_width+28)     when '1',
                          entry2_parity_q(7)    when others;
with wr_entry2_sel(1)   select
 entry2_parity_d(8)    <= wr_array_data(rpn_width+29)     when '1',
                            entry2_parity_q(8)    when others;
with wr_entry2_sel(1)   select
 entry2_parity_d(9)     <= wr_array_data(rpn_width+30)     when '1',
                          entry2_parity_q(9)    when others;
wr_entry3_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="00011"))   else '0';
wr_entry3_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="00011"))   else '0';
with wr_entry3_sel(0)   select
 entry3_epn_d(0   to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry3_epn_q(0   to 31)   when others;
with wr_entry3_sel(0)   select
 entry3_epn_d(32   to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry3_epn_q(32   to 51)  when others;
with wr_entry3_sel(0)   select
 entry3_xbit_d        <= wr_cam_data(52)  when '1',
                          entry3_xbit_q    when others;
with wr_entry3_sel(0)   select
 entry3_size_d        <= wr_cam_data(53 to 55)  when '1',
                          entry3_size_q(0   to 2)  when others;
with wr_entry3_sel(0)   select
 entry3_class_d       <= wr_cam_data(61 to 62)     when '1',
                          entry3_class_q(0   to 1)  when others;
with wr_entry3_sel(1)   select
 entry3_extclass_d    <= wr_cam_data(63 to 64)     when '1',
                          entry3_extclass_q(0   to 1)  when others;
with wr_entry3_sel(1)   select
 entry3_hv_d          <= wr_cam_data(65)   when '1',
                          entry3_hv_q       when others;
with wr_entry3_sel(1)   select
 entry3_ds_d          <= wr_cam_data(66)   when '1',
                          entry3_ds_q       when others;
with wr_entry3_sel(1)   select
 entry3_pid_d         <= wr_cam_data(67 to 74)     when '1',
                          entry3_pid_q(0   to 7)  when others;
with wr_entry3_sel(0)   select
 entry3_cmpmask_d       <= wr_cam_data(75 to 83)     when '1',
                          entry3_cmpmask_q    when others;
with wr_entry3_sel(0)   select
 entry3_parity_d(0   to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry3_parity_q(0   to 3)   when others;
with wr_entry3_sel(0)   select
 entry3_parity_d(4   to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry3_parity_q(4   to 6)  when others;
with wr_entry3_sel(0)   select
 entry3_parity_d(7)     <= wr_array_data(rpn_width+28)     when '1',
                          entry3_parity_q(7)    when others;
with wr_entry3_sel(1)   select
 entry3_parity_d(8)    <= wr_array_data(rpn_width+29)     when '1',
                            entry3_parity_q(8)    when others;
with wr_entry3_sel(1)   select
 entry3_parity_d(9)     <= wr_array_data(rpn_width+30)     when '1',
                          entry3_parity_q(9)    when others;
wr_entry4_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="00100"))   else '0';
wr_entry4_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="00100"))   else '0';
with wr_entry4_sel(0)   select
 entry4_epn_d(0   to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry4_epn_q(0   to 31)   when others;
with wr_entry4_sel(0)   select
 entry4_epn_d(32   to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry4_epn_q(32   to 51)  when others;
with wr_entry4_sel(0)   select
 entry4_xbit_d        <= wr_cam_data(52)  when '1',
                          entry4_xbit_q    when others;
with wr_entry4_sel(0)   select
 entry4_size_d        <= wr_cam_data(53 to 55)  when '1',
                          entry4_size_q(0   to 2)  when others;
with wr_entry4_sel(0)   select
 entry4_class_d       <= wr_cam_data(61 to 62)     when '1',
                          entry4_class_q(0   to 1)  when others;
with wr_entry4_sel(1)   select
 entry4_extclass_d    <= wr_cam_data(63 to 64)     when '1',
                          entry4_extclass_q(0   to 1)  when others;
with wr_entry4_sel(1)   select
 entry4_hv_d          <= wr_cam_data(65)   when '1',
                          entry4_hv_q       when others;
with wr_entry4_sel(1)   select
 entry4_ds_d          <= wr_cam_data(66)   when '1',
                          entry4_ds_q       when others;
with wr_entry4_sel(1)   select
 entry4_pid_d         <= wr_cam_data(67 to 74)     when '1',
                          entry4_pid_q(0   to 7)  when others;
with wr_entry4_sel(0)   select
 entry4_cmpmask_d       <= wr_cam_data(75 to 83)     when '1',
                          entry4_cmpmask_q    when others;
with wr_entry4_sel(0)   select
 entry4_parity_d(0   to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry4_parity_q(0   to 3)   when others;
with wr_entry4_sel(0)   select
 entry4_parity_d(4   to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry4_parity_q(4   to 6)  when others;
with wr_entry4_sel(0)   select
 entry4_parity_d(7)     <= wr_array_data(rpn_width+28)     when '1',
                          entry4_parity_q(7)    when others;
with wr_entry4_sel(1)   select
 entry4_parity_d(8)    <= wr_array_data(rpn_width+29)     when '1',
                            entry4_parity_q(8)    when others;
with wr_entry4_sel(1)   select
 entry4_parity_d(9)     <= wr_array_data(rpn_width+30)     when '1',
                          entry4_parity_q(9)    when others;
wr_entry5_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="00101"))   else '0';
wr_entry5_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="00101"))   else '0';
with wr_entry5_sel(0)   select
 entry5_epn_d(0   to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry5_epn_q(0   to 31)   when others;
with wr_entry5_sel(0)   select
 entry5_epn_d(32   to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry5_epn_q(32   to 51)  when others;
with wr_entry5_sel(0)   select
 entry5_xbit_d        <= wr_cam_data(52)  when '1',
                          entry5_xbit_q    when others;
with wr_entry5_sel(0)   select
 entry5_size_d        <= wr_cam_data(53 to 55)  when '1',
                          entry5_size_q(0   to 2)  when others;
with wr_entry5_sel(0)   select
 entry5_class_d       <= wr_cam_data(61 to 62)     when '1',
                          entry5_class_q(0   to 1)  when others;
with wr_entry5_sel(1)   select
 entry5_extclass_d    <= wr_cam_data(63 to 64)     when '1',
                          entry5_extclass_q(0   to 1)  when others;
with wr_entry5_sel(1)   select
 entry5_hv_d          <= wr_cam_data(65)   when '1',
                          entry5_hv_q       when others;
with wr_entry5_sel(1)   select
 entry5_ds_d          <= wr_cam_data(66)   when '1',
                          entry5_ds_q       when others;
with wr_entry5_sel(1)   select
 entry5_pid_d         <= wr_cam_data(67 to 74)     when '1',
                          entry5_pid_q(0   to 7)  when others;
with wr_entry5_sel(0)   select
 entry5_cmpmask_d       <= wr_cam_data(75 to 83)     when '1',
                          entry5_cmpmask_q    when others;
with wr_entry5_sel(0)   select
 entry5_parity_d(0   to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry5_parity_q(0   to 3)   when others;
with wr_entry5_sel(0)   select
 entry5_parity_d(4   to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry5_parity_q(4   to 6)  when others;
with wr_entry5_sel(0)   select
 entry5_parity_d(7)     <= wr_array_data(rpn_width+28)     when '1',
                          entry5_parity_q(7)    when others;
with wr_entry5_sel(1)   select
 entry5_parity_d(8)    <= wr_array_data(rpn_width+29)     when '1',
                            entry5_parity_q(8)    when others;
with wr_entry5_sel(1)   select
 entry5_parity_d(9)     <= wr_array_data(rpn_width+30)     when '1',
                          entry5_parity_q(9)    when others;
wr_entry6_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="00110"))   else '0';
wr_entry6_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="00110"))   else '0';
with wr_entry6_sel(0)   select
 entry6_epn_d(0   to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry6_epn_q(0   to 31)   when others;
with wr_entry6_sel(0)   select
 entry6_epn_d(32   to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry6_epn_q(32   to 51)  when others;
with wr_entry6_sel(0)   select
 entry6_xbit_d        <= wr_cam_data(52)  when '1',
                          entry6_xbit_q    when others;
with wr_entry6_sel(0)   select
 entry6_size_d        <= wr_cam_data(53 to 55)  when '1',
                          entry6_size_q(0   to 2)  when others;
with wr_entry6_sel(0)   select
 entry6_class_d       <= wr_cam_data(61 to 62)     when '1',
                          entry6_class_q(0   to 1)  when others;
with wr_entry6_sel(1)   select
 entry6_extclass_d    <= wr_cam_data(63 to 64)     when '1',
                          entry6_extclass_q(0   to 1)  when others;
with wr_entry6_sel(1)   select
 entry6_hv_d          <= wr_cam_data(65)   when '1',
                          entry6_hv_q       when others;
with wr_entry6_sel(1)   select
 entry6_ds_d          <= wr_cam_data(66)   when '1',
                          entry6_ds_q       when others;
with wr_entry6_sel(1)   select
 entry6_pid_d         <= wr_cam_data(67 to 74)     when '1',
                          entry6_pid_q(0   to 7)  when others;
with wr_entry6_sel(0)   select
 entry6_cmpmask_d       <= wr_cam_data(75 to 83)     when '1',
                          entry6_cmpmask_q    when others;
with wr_entry6_sel(0)   select
 entry6_parity_d(0   to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry6_parity_q(0   to 3)   when others;
with wr_entry6_sel(0)   select
 entry6_parity_d(4   to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry6_parity_q(4   to 6)  when others;
with wr_entry6_sel(0)   select
 entry6_parity_d(7)     <= wr_array_data(rpn_width+28)     when '1',
                          entry6_parity_q(7)    when others;
with wr_entry6_sel(1)   select
 entry6_parity_d(8)    <= wr_array_data(rpn_width+29)     when '1',
                            entry6_parity_q(8)    when others;
with wr_entry6_sel(1)   select
 entry6_parity_d(9)     <= wr_array_data(rpn_width+30)     when '1',
                          entry6_parity_q(9)    when others;
wr_entry7_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="00111"))   else '0';
wr_entry7_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="00111"))   else '0';
with wr_entry7_sel(0)   select
 entry7_epn_d(0   to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry7_epn_q(0   to 31)   when others;
with wr_entry7_sel(0)   select
 entry7_epn_d(32   to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry7_epn_q(32   to 51)  when others;
with wr_entry7_sel(0)   select
 entry7_xbit_d        <= wr_cam_data(52)  when '1',
                          entry7_xbit_q    when others;
with wr_entry7_sel(0)   select
 entry7_size_d        <= wr_cam_data(53 to 55)  when '1',
                          entry7_size_q(0   to 2)  when others;
with wr_entry7_sel(0)   select
 entry7_class_d       <= wr_cam_data(61 to 62)     when '1',
                          entry7_class_q(0   to 1)  when others;
with wr_entry7_sel(1)   select
 entry7_extclass_d    <= wr_cam_data(63 to 64)     when '1',
                          entry7_extclass_q(0   to 1)  when others;
with wr_entry7_sel(1)   select
 entry7_hv_d          <= wr_cam_data(65)   when '1',
                          entry7_hv_q       when others;
with wr_entry7_sel(1)   select
 entry7_ds_d          <= wr_cam_data(66)   when '1',
                          entry7_ds_q       when others;
with wr_entry7_sel(1)   select
 entry7_pid_d         <= wr_cam_data(67 to 74)     when '1',
                          entry7_pid_q(0   to 7)  when others;
with wr_entry7_sel(0)   select
 entry7_cmpmask_d       <= wr_cam_data(75 to 83)     when '1',
                          entry7_cmpmask_q    when others;
with wr_entry7_sel(0)   select
 entry7_parity_d(0   to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry7_parity_q(0   to 3)   when others;
with wr_entry7_sel(0)   select
 entry7_parity_d(4   to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry7_parity_q(4   to 6)  when others;
with wr_entry7_sel(0)   select
 entry7_parity_d(7)     <= wr_array_data(rpn_width+28)     when '1',
                          entry7_parity_q(7)    when others;
with wr_entry7_sel(1)   select
 entry7_parity_d(8)    <= wr_array_data(rpn_width+29)     when '1',
                            entry7_parity_q(8)    when others;
with wr_entry7_sel(1)   select
 entry7_parity_d(9)     <= wr_array_data(rpn_width+30)     when '1',
                          entry7_parity_q(9)    when others;
wr_entry8_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="01000"))   else '0';
wr_entry8_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="01000"))   else '0';
with wr_entry8_sel(0)   select
 entry8_epn_d(0   to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry8_epn_q(0   to 31)   when others;
with wr_entry8_sel(0)   select
 entry8_epn_d(32   to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry8_epn_q(32   to 51)  when others;
with wr_entry8_sel(0)   select
 entry8_xbit_d        <= wr_cam_data(52)  when '1',
                          entry8_xbit_q    when others;
with wr_entry8_sel(0)   select
 entry8_size_d        <= wr_cam_data(53 to 55)  when '1',
                          entry8_size_q(0   to 2)  when others;
with wr_entry8_sel(0)   select
 entry8_class_d       <= wr_cam_data(61 to 62)     when '1',
                          entry8_class_q(0   to 1)  when others;
with wr_entry8_sel(1)   select
 entry8_extclass_d    <= wr_cam_data(63 to 64)     when '1',
                          entry8_extclass_q(0   to 1)  when others;
with wr_entry8_sel(1)   select
 entry8_hv_d          <= wr_cam_data(65)   when '1',
                          entry8_hv_q       when others;
with wr_entry8_sel(1)   select
 entry8_ds_d          <= wr_cam_data(66)   when '1',
                          entry8_ds_q       when others;
with wr_entry8_sel(1)   select
 entry8_pid_d         <= wr_cam_data(67 to 74)     when '1',
                          entry8_pid_q(0   to 7)  when others;
with wr_entry8_sel(0)   select
 entry8_cmpmask_d       <= wr_cam_data(75 to 83)     when '1',
                          entry8_cmpmask_q    when others;
with wr_entry8_sel(0)   select
 entry8_parity_d(0   to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry8_parity_q(0   to 3)   when others;
with wr_entry8_sel(0)   select
 entry8_parity_d(4   to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry8_parity_q(4   to 6)  when others;
with wr_entry8_sel(0)   select
 entry8_parity_d(7)     <= wr_array_data(rpn_width+28)     when '1',
                          entry8_parity_q(7)    when others;
with wr_entry8_sel(1)   select
 entry8_parity_d(8)    <= wr_array_data(rpn_width+29)     when '1',
                            entry8_parity_q(8)    when others;
with wr_entry8_sel(1)   select
 entry8_parity_d(9)     <= wr_array_data(rpn_width+30)     when '1',
                          entry8_parity_q(9)    when others;
wr_entry9_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="01001"))   else '0';
wr_entry9_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="01001"))   else '0';
with wr_entry9_sel(0)   select
 entry9_epn_d(0   to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry9_epn_q(0   to 31)   when others;
with wr_entry9_sel(0)   select
 entry9_epn_d(32   to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry9_epn_q(32   to 51)  when others;
with wr_entry9_sel(0)   select
 entry9_xbit_d        <= wr_cam_data(52)  when '1',
                          entry9_xbit_q    when others;
with wr_entry9_sel(0)   select
 entry9_size_d        <= wr_cam_data(53 to 55)  when '1',
                          entry9_size_q(0   to 2)  when others;
with wr_entry9_sel(0)   select
 entry9_class_d       <= wr_cam_data(61 to 62)     when '1',
                          entry9_class_q(0   to 1)  when others;
with wr_entry9_sel(1)   select
 entry9_extclass_d    <= wr_cam_data(63 to 64)     when '1',
                          entry9_extclass_q(0   to 1)  when others;
with wr_entry9_sel(1)   select
 entry9_hv_d          <= wr_cam_data(65)   when '1',
                          entry9_hv_q       when others;
with wr_entry9_sel(1)   select
 entry9_ds_d          <= wr_cam_data(66)   when '1',
                          entry9_ds_q       when others;
with wr_entry9_sel(1)   select
 entry9_pid_d         <= wr_cam_data(67 to 74)     when '1',
                          entry9_pid_q(0   to 7)  when others;
with wr_entry9_sel(0)   select
 entry9_cmpmask_d       <= wr_cam_data(75 to 83)     when '1',
                          entry9_cmpmask_q    when others;
with wr_entry9_sel(0)   select
 entry9_parity_d(0   to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry9_parity_q(0   to 3)   when others;
with wr_entry9_sel(0)   select
 entry9_parity_d(4   to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry9_parity_q(4   to 6)  when others;
with wr_entry9_sel(0)   select
 entry9_parity_d(7)     <= wr_array_data(rpn_width+28)     when '1',
                          entry9_parity_q(7)    when others;
with wr_entry9_sel(1)   select
 entry9_parity_d(8)    <= wr_array_data(rpn_width+29)     when '1',
                            entry9_parity_q(8)    when others;
with wr_entry9_sel(1)   select
 entry9_parity_d(9)     <= wr_array_data(rpn_width+30)     when '1',
                          entry9_parity_q(9)    when others;
wr_entry10_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="01010"))  else '0';
wr_entry10_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="01010"))  else '0';
with wr_entry10_sel(0)  select
 entry10_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry10_epn_q(0  to 31)   when others;
with wr_entry10_sel(0)  select
 entry10_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry10_epn_q(32  to 51)  when others;
with wr_entry10_sel(0)  select
 entry10_xbit_d       <= wr_cam_data(52)  when '1',
                          entry10_xbit_q   when others;
with wr_entry10_sel(0)  select
 entry10_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry10_size_q(0  to 2)  when others;
with wr_entry10_sel(0)  select
 entry10_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry10_class_q(0  to 1)  when others;
with wr_entry10_sel(1)  select
 entry10_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry10_extclass_q(0  to 1)  when others;
with wr_entry10_sel(1)  select
 entry10_hv_d         <= wr_cam_data(65)   when '1',
                          entry10_hv_q      when others;
with wr_entry10_sel(1)  select
 entry10_ds_d         <= wr_cam_data(66)   when '1',
                          entry10_ds_q      when others;
with wr_entry10_sel(1)  select
 entry10_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry10_pid_q(0  to 7)  when others;
with wr_entry10_sel(0)  select
 entry10_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry10_cmpmask_q   when others;
with wr_entry10_sel(0)  select
 entry10_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry10_parity_q(0  to 3)   when others;
with wr_entry10_sel(0)  select
 entry10_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry10_parity_q(4  to 6)  when others;
with wr_entry10_sel(0)  select
 entry10_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry10_parity_q(7)   when others;
with wr_entry10_sel(1)  select
 entry10_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry10_parity_q(8)   when others;
with wr_entry10_sel(1)  select
 entry10_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry10_parity_q(9)   when others;
wr_entry11_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="01011"))  else '0';
wr_entry11_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="01011"))  else '0';
with wr_entry11_sel(0)  select
 entry11_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry11_epn_q(0  to 31)   when others;
with wr_entry11_sel(0)  select
 entry11_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry11_epn_q(32  to 51)  when others;
with wr_entry11_sel(0)  select
 entry11_xbit_d       <= wr_cam_data(52)  when '1',
                          entry11_xbit_q   when others;
with wr_entry11_sel(0)  select
 entry11_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry11_size_q(0  to 2)  when others;
with wr_entry11_sel(0)  select
 entry11_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry11_class_q(0  to 1)  when others;
with wr_entry11_sel(1)  select
 entry11_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry11_extclass_q(0  to 1)  when others;
with wr_entry11_sel(1)  select
 entry11_hv_d         <= wr_cam_data(65)   when '1',
                          entry11_hv_q      when others;
with wr_entry11_sel(1)  select
 entry11_ds_d         <= wr_cam_data(66)   when '1',
                          entry11_ds_q      when others;
with wr_entry11_sel(1)  select
 entry11_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry11_pid_q(0  to 7)  when others;
with wr_entry11_sel(0)  select
 entry11_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry11_cmpmask_q   when others;
with wr_entry11_sel(0)  select
 entry11_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry11_parity_q(0  to 3)   when others;
with wr_entry11_sel(0)  select
 entry11_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry11_parity_q(4  to 6)  when others;
with wr_entry11_sel(0)  select
 entry11_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry11_parity_q(7)   when others;
with wr_entry11_sel(1)  select
 entry11_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry11_parity_q(8)   when others;
with wr_entry11_sel(1)  select
 entry11_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry11_parity_q(9)   when others;
wr_entry12_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="01100"))  else '0';
wr_entry12_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="01100"))  else '0';
with wr_entry12_sel(0)  select
 entry12_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry12_epn_q(0  to 31)   when others;
with wr_entry12_sel(0)  select
 entry12_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry12_epn_q(32  to 51)  when others;
with wr_entry12_sel(0)  select
 entry12_xbit_d       <= wr_cam_data(52)  when '1',
                          entry12_xbit_q   when others;
with wr_entry12_sel(0)  select
 entry12_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry12_size_q(0  to 2)  when others;
with wr_entry12_sel(0)  select
 entry12_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry12_class_q(0  to 1)  when others;
with wr_entry12_sel(1)  select
 entry12_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry12_extclass_q(0  to 1)  when others;
with wr_entry12_sel(1)  select
 entry12_hv_d         <= wr_cam_data(65)   when '1',
                          entry12_hv_q      when others;
with wr_entry12_sel(1)  select
 entry12_ds_d         <= wr_cam_data(66)   when '1',
                          entry12_ds_q      when others;
with wr_entry12_sel(1)  select
 entry12_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry12_pid_q(0  to 7)  when others;
with wr_entry12_sel(0)  select
 entry12_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry12_cmpmask_q   when others;
with wr_entry12_sel(0)  select
 entry12_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry12_parity_q(0  to 3)   when others;
with wr_entry12_sel(0)  select
 entry12_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry12_parity_q(4  to 6)  when others;
with wr_entry12_sel(0)  select
 entry12_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry12_parity_q(7)   when others;
with wr_entry12_sel(1)  select
 entry12_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry12_parity_q(8)   when others;
with wr_entry12_sel(1)  select
 entry12_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry12_parity_q(9)   when others;
wr_entry13_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="01101"))  else '0';
wr_entry13_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="01101"))  else '0';
with wr_entry13_sel(0)  select
 entry13_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry13_epn_q(0  to 31)   when others;
with wr_entry13_sel(0)  select
 entry13_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry13_epn_q(32  to 51)  when others;
with wr_entry13_sel(0)  select
 entry13_xbit_d       <= wr_cam_data(52)  when '1',
                          entry13_xbit_q   when others;
with wr_entry13_sel(0)  select
 entry13_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry13_size_q(0  to 2)  when others;
with wr_entry13_sel(0)  select
 entry13_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry13_class_q(0  to 1)  when others;
with wr_entry13_sel(1)  select
 entry13_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry13_extclass_q(0  to 1)  when others;
with wr_entry13_sel(1)  select
 entry13_hv_d         <= wr_cam_data(65)   when '1',
                          entry13_hv_q      when others;
with wr_entry13_sel(1)  select
 entry13_ds_d         <= wr_cam_data(66)   when '1',
                          entry13_ds_q      when others;
with wr_entry13_sel(1)  select
 entry13_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry13_pid_q(0  to 7)  when others;
with wr_entry13_sel(0)  select
 entry13_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry13_cmpmask_q   when others;
with wr_entry13_sel(0)  select
 entry13_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry13_parity_q(0  to 3)   when others;
with wr_entry13_sel(0)  select
 entry13_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry13_parity_q(4  to 6)  when others;
with wr_entry13_sel(0)  select
 entry13_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry13_parity_q(7)   when others;
with wr_entry13_sel(1)  select
 entry13_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry13_parity_q(8)   when others;
with wr_entry13_sel(1)  select
 entry13_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry13_parity_q(9)   when others;
wr_entry14_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="01110"))  else '0';
wr_entry14_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="01110"))  else '0';
with wr_entry14_sel(0)  select
 entry14_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry14_epn_q(0  to 31)   when others;
with wr_entry14_sel(0)  select
 entry14_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry14_epn_q(32  to 51)  when others;
with wr_entry14_sel(0)  select
 entry14_xbit_d       <= wr_cam_data(52)  when '1',
                          entry14_xbit_q   when others;
with wr_entry14_sel(0)  select
 entry14_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry14_size_q(0  to 2)  when others;
with wr_entry14_sel(0)  select
 entry14_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry14_class_q(0  to 1)  when others;
with wr_entry14_sel(1)  select
 entry14_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry14_extclass_q(0  to 1)  when others;
with wr_entry14_sel(1)  select
 entry14_hv_d         <= wr_cam_data(65)   when '1',
                          entry14_hv_q      when others;
with wr_entry14_sel(1)  select
 entry14_ds_d         <= wr_cam_data(66)   when '1',
                          entry14_ds_q      when others;
with wr_entry14_sel(1)  select
 entry14_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry14_pid_q(0  to 7)  when others;
with wr_entry14_sel(0)  select
 entry14_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry14_cmpmask_q   when others;
with wr_entry14_sel(0)  select
 entry14_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry14_parity_q(0  to 3)   when others;
with wr_entry14_sel(0)  select
 entry14_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry14_parity_q(4  to 6)  when others;
with wr_entry14_sel(0)  select
 entry14_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry14_parity_q(7)   when others;
with wr_entry14_sel(1)  select
 entry14_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry14_parity_q(8)   when others;
with wr_entry14_sel(1)  select
 entry14_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry14_parity_q(9)   when others;
wr_entry15_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="01111"))  else '0';
wr_entry15_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="01111"))  else '0';
with wr_entry15_sel(0)  select
 entry15_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry15_epn_q(0  to 31)   when others;
with wr_entry15_sel(0)  select
 entry15_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry15_epn_q(32  to 51)  when others;
with wr_entry15_sel(0)  select
 entry15_xbit_d       <= wr_cam_data(52)  when '1',
                          entry15_xbit_q   when others;
with wr_entry15_sel(0)  select
 entry15_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry15_size_q(0  to 2)  when others;
with wr_entry15_sel(0)  select
 entry15_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry15_class_q(0  to 1)  when others;
with wr_entry15_sel(1)  select
 entry15_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry15_extclass_q(0  to 1)  when others;
with wr_entry15_sel(1)  select
 entry15_hv_d         <= wr_cam_data(65)   when '1',
                          entry15_hv_q      when others;
with wr_entry15_sel(1)  select
 entry15_ds_d         <= wr_cam_data(66)   when '1',
                          entry15_ds_q      when others;
with wr_entry15_sel(1)  select
 entry15_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry15_pid_q(0  to 7)  when others;
with wr_entry15_sel(0)  select
 entry15_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry15_cmpmask_q   when others;
with wr_entry15_sel(0)  select
 entry15_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry15_parity_q(0  to 3)   when others;
with wr_entry15_sel(0)  select
 entry15_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry15_parity_q(4  to 6)  when others;
with wr_entry15_sel(0)  select
 entry15_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry15_parity_q(7)   when others;
with wr_entry15_sel(1)  select
 entry15_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry15_parity_q(8)   when others;
with wr_entry15_sel(1)  select
 entry15_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry15_parity_q(9)   when others;
wr_entry16_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="10000"))  else '0';
wr_entry16_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="10000"))  else '0';
with wr_entry16_sel(0)  select
 entry16_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry16_epn_q(0  to 31)   when others;
with wr_entry16_sel(0)  select
 entry16_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry16_epn_q(32  to 51)  when others;
with wr_entry16_sel(0)  select
 entry16_xbit_d       <= wr_cam_data(52)  when '1',
                          entry16_xbit_q   when others;
with wr_entry16_sel(0)  select
 entry16_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry16_size_q(0  to 2)  when others;
with wr_entry16_sel(0)  select
 entry16_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry16_class_q(0  to 1)  when others;
with wr_entry16_sel(1)  select
 entry16_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry16_extclass_q(0  to 1)  when others;
with wr_entry16_sel(1)  select
 entry16_hv_d         <= wr_cam_data(65)   when '1',
                          entry16_hv_q      when others;
with wr_entry16_sel(1)  select
 entry16_ds_d         <= wr_cam_data(66)   when '1',
                          entry16_ds_q      when others;
with wr_entry16_sel(1)  select
 entry16_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry16_pid_q(0  to 7)  when others;
with wr_entry16_sel(0)  select
 entry16_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry16_cmpmask_q   when others;
with wr_entry16_sel(0)  select
 entry16_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry16_parity_q(0  to 3)   when others;
with wr_entry16_sel(0)  select
 entry16_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry16_parity_q(4  to 6)  when others;
with wr_entry16_sel(0)  select
 entry16_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry16_parity_q(7)   when others;
with wr_entry16_sel(1)  select
 entry16_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry16_parity_q(8)   when others;
with wr_entry16_sel(1)  select
 entry16_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry16_parity_q(9)   when others;
wr_entry17_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="10001"))  else '0';
wr_entry17_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="10001"))  else '0';
with wr_entry17_sel(0)  select
 entry17_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry17_epn_q(0  to 31)   when others;
with wr_entry17_sel(0)  select
 entry17_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry17_epn_q(32  to 51)  when others;
with wr_entry17_sel(0)  select
 entry17_xbit_d       <= wr_cam_data(52)  when '1',
                          entry17_xbit_q   when others;
with wr_entry17_sel(0)  select
 entry17_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry17_size_q(0  to 2)  when others;
with wr_entry17_sel(0)  select
 entry17_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry17_class_q(0  to 1)  when others;
with wr_entry17_sel(1)  select
 entry17_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry17_extclass_q(0  to 1)  when others;
with wr_entry17_sel(1)  select
 entry17_hv_d         <= wr_cam_data(65)   when '1',
                          entry17_hv_q      when others;
with wr_entry17_sel(1)  select
 entry17_ds_d         <= wr_cam_data(66)   when '1',
                          entry17_ds_q      when others;
with wr_entry17_sel(1)  select
 entry17_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry17_pid_q(0  to 7)  when others;
with wr_entry17_sel(0)  select
 entry17_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry17_cmpmask_q   when others;
with wr_entry17_sel(0)  select
 entry17_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry17_parity_q(0  to 3)   when others;
with wr_entry17_sel(0)  select
 entry17_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry17_parity_q(4  to 6)  when others;
with wr_entry17_sel(0)  select
 entry17_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry17_parity_q(7)   when others;
with wr_entry17_sel(1)  select
 entry17_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry17_parity_q(8)   when others;
with wr_entry17_sel(1)  select
 entry17_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry17_parity_q(9)   when others;
wr_entry18_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="10010"))  else '0';
wr_entry18_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="10010"))  else '0';
with wr_entry18_sel(0)  select
 entry18_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry18_epn_q(0  to 31)   when others;
with wr_entry18_sel(0)  select
 entry18_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry18_epn_q(32  to 51)  when others;
with wr_entry18_sel(0)  select
 entry18_xbit_d       <= wr_cam_data(52)  when '1',
                          entry18_xbit_q   when others;
with wr_entry18_sel(0)  select
 entry18_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry18_size_q(0  to 2)  when others;
with wr_entry18_sel(0)  select
 entry18_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry18_class_q(0  to 1)  when others;
with wr_entry18_sel(1)  select
 entry18_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry18_extclass_q(0  to 1)  when others;
with wr_entry18_sel(1)  select
 entry18_hv_d         <= wr_cam_data(65)   when '1',
                          entry18_hv_q      when others;
with wr_entry18_sel(1)  select
 entry18_ds_d         <= wr_cam_data(66)   when '1',
                          entry18_ds_q      when others;
with wr_entry18_sel(1)  select
 entry18_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry18_pid_q(0  to 7)  when others;
with wr_entry18_sel(0)  select
 entry18_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry18_cmpmask_q   when others;
with wr_entry18_sel(0)  select
 entry18_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry18_parity_q(0  to 3)   when others;
with wr_entry18_sel(0)  select
 entry18_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry18_parity_q(4  to 6)  when others;
with wr_entry18_sel(0)  select
 entry18_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry18_parity_q(7)   when others;
with wr_entry18_sel(1)  select
 entry18_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry18_parity_q(8)   when others;
with wr_entry18_sel(1)  select
 entry18_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry18_parity_q(9)   when others;
wr_entry19_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="10011"))  else '0';
wr_entry19_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="10011"))  else '0';
with wr_entry19_sel(0)  select
 entry19_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry19_epn_q(0  to 31)   when others;
with wr_entry19_sel(0)  select
 entry19_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry19_epn_q(32  to 51)  when others;
with wr_entry19_sel(0)  select
 entry19_xbit_d       <= wr_cam_data(52)  when '1',
                          entry19_xbit_q   when others;
with wr_entry19_sel(0)  select
 entry19_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry19_size_q(0  to 2)  when others;
with wr_entry19_sel(0)  select
 entry19_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry19_class_q(0  to 1)  when others;
with wr_entry19_sel(1)  select
 entry19_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry19_extclass_q(0  to 1)  when others;
with wr_entry19_sel(1)  select
 entry19_hv_d         <= wr_cam_data(65)   when '1',
                          entry19_hv_q      when others;
with wr_entry19_sel(1)  select
 entry19_ds_d         <= wr_cam_data(66)   when '1',
                          entry19_ds_q      when others;
with wr_entry19_sel(1)  select
 entry19_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry19_pid_q(0  to 7)  when others;
with wr_entry19_sel(0)  select
 entry19_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry19_cmpmask_q   when others;
with wr_entry19_sel(0)  select
 entry19_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry19_parity_q(0  to 3)   when others;
with wr_entry19_sel(0)  select
 entry19_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry19_parity_q(4  to 6)  when others;
with wr_entry19_sel(0)  select
 entry19_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry19_parity_q(7)   when others;
with wr_entry19_sel(1)  select
 entry19_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry19_parity_q(8)   when others;
with wr_entry19_sel(1)  select
 entry19_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry19_parity_q(9)   when others;
wr_entry20_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="10100"))  else '0';
wr_entry20_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="10100"))  else '0';
with wr_entry20_sel(0)  select
 entry20_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry20_epn_q(0  to 31)   when others;
with wr_entry20_sel(0)  select
 entry20_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry20_epn_q(32  to 51)  when others;
with wr_entry20_sel(0)  select
 entry20_xbit_d       <= wr_cam_data(52)  when '1',
                          entry20_xbit_q   when others;
with wr_entry20_sel(0)  select
 entry20_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry20_size_q(0  to 2)  when others;
with wr_entry20_sel(0)  select
 entry20_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry20_class_q(0  to 1)  when others;
with wr_entry20_sel(1)  select
 entry20_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry20_extclass_q(0  to 1)  when others;
with wr_entry20_sel(1)  select
 entry20_hv_d         <= wr_cam_data(65)   when '1',
                          entry20_hv_q      when others;
with wr_entry20_sel(1)  select
 entry20_ds_d         <= wr_cam_data(66)   when '1',
                          entry20_ds_q      when others;
with wr_entry20_sel(1)  select
 entry20_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry20_pid_q(0  to 7)  when others;
with wr_entry20_sel(0)  select
 entry20_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry20_cmpmask_q   when others;
with wr_entry20_sel(0)  select
 entry20_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry20_parity_q(0  to 3)   when others;
with wr_entry20_sel(0)  select
 entry20_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry20_parity_q(4  to 6)  when others;
with wr_entry20_sel(0)  select
 entry20_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry20_parity_q(7)   when others;
with wr_entry20_sel(1)  select
 entry20_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry20_parity_q(8)   when others;
with wr_entry20_sel(1)  select
 entry20_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry20_parity_q(9)   when others;
wr_entry21_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="10101"))  else '0';
wr_entry21_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="10101"))  else '0';
with wr_entry21_sel(0)  select
 entry21_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry21_epn_q(0  to 31)   when others;
with wr_entry21_sel(0)  select
 entry21_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry21_epn_q(32  to 51)  when others;
with wr_entry21_sel(0)  select
 entry21_xbit_d       <= wr_cam_data(52)  when '1',
                          entry21_xbit_q   when others;
with wr_entry21_sel(0)  select
 entry21_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry21_size_q(0  to 2)  when others;
with wr_entry21_sel(0)  select
 entry21_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry21_class_q(0  to 1)  when others;
with wr_entry21_sel(1)  select
 entry21_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry21_extclass_q(0  to 1)  when others;
with wr_entry21_sel(1)  select
 entry21_hv_d         <= wr_cam_data(65)   when '1',
                          entry21_hv_q      when others;
with wr_entry21_sel(1)  select
 entry21_ds_d         <= wr_cam_data(66)   when '1',
                          entry21_ds_q      when others;
with wr_entry21_sel(1)  select
 entry21_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry21_pid_q(0  to 7)  when others;
with wr_entry21_sel(0)  select
 entry21_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry21_cmpmask_q   when others;
with wr_entry21_sel(0)  select
 entry21_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry21_parity_q(0  to 3)   when others;
with wr_entry21_sel(0)  select
 entry21_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry21_parity_q(4  to 6)  when others;
with wr_entry21_sel(0)  select
 entry21_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry21_parity_q(7)   when others;
with wr_entry21_sel(1)  select
 entry21_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry21_parity_q(8)   when others;
with wr_entry21_sel(1)  select
 entry21_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry21_parity_q(9)   when others;
wr_entry22_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="10110"))  else '0';
wr_entry22_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="10110"))  else '0';
with wr_entry22_sel(0)  select
 entry22_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry22_epn_q(0  to 31)   when others;
with wr_entry22_sel(0)  select
 entry22_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry22_epn_q(32  to 51)  when others;
with wr_entry22_sel(0)  select
 entry22_xbit_d       <= wr_cam_data(52)  when '1',
                          entry22_xbit_q   when others;
with wr_entry22_sel(0)  select
 entry22_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry22_size_q(0  to 2)  when others;
with wr_entry22_sel(0)  select
 entry22_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry22_class_q(0  to 1)  when others;
with wr_entry22_sel(1)  select
 entry22_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry22_extclass_q(0  to 1)  when others;
with wr_entry22_sel(1)  select
 entry22_hv_d         <= wr_cam_data(65)   when '1',
                          entry22_hv_q      when others;
with wr_entry22_sel(1)  select
 entry22_ds_d         <= wr_cam_data(66)   when '1',
                          entry22_ds_q      when others;
with wr_entry22_sel(1)  select
 entry22_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry22_pid_q(0  to 7)  when others;
with wr_entry22_sel(0)  select
 entry22_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry22_cmpmask_q   when others;
with wr_entry22_sel(0)  select
 entry22_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry22_parity_q(0  to 3)   when others;
with wr_entry22_sel(0)  select
 entry22_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry22_parity_q(4  to 6)  when others;
with wr_entry22_sel(0)  select
 entry22_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry22_parity_q(7)   when others;
with wr_entry22_sel(1)  select
 entry22_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry22_parity_q(8)   when others;
with wr_entry22_sel(1)  select
 entry22_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry22_parity_q(9)   when others;
wr_entry23_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="10111"))  else '0';
wr_entry23_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="10111"))  else '0';
with wr_entry23_sel(0)  select
 entry23_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry23_epn_q(0  to 31)   when others;
with wr_entry23_sel(0)  select
 entry23_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry23_epn_q(32  to 51)  when others;
with wr_entry23_sel(0)  select
 entry23_xbit_d       <= wr_cam_data(52)  when '1',
                          entry23_xbit_q   when others;
with wr_entry23_sel(0)  select
 entry23_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry23_size_q(0  to 2)  when others;
with wr_entry23_sel(0)  select
 entry23_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry23_class_q(0  to 1)  when others;
with wr_entry23_sel(1)  select
 entry23_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry23_extclass_q(0  to 1)  when others;
with wr_entry23_sel(1)  select
 entry23_hv_d         <= wr_cam_data(65)   when '1',
                          entry23_hv_q      when others;
with wr_entry23_sel(1)  select
 entry23_ds_d         <= wr_cam_data(66)   when '1',
                          entry23_ds_q      when others;
with wr_entry23_sel(1)  select
 entry23_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry23_pid_q(0  to 7)  when others;
with wr_entry23_sel(0)  select
 entry23_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry23_cmpmask_q   when others;
with wr_entry23_sel(0)  select
 entry23_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry23_parity_q(0  to 3)   when others;
with wr_entry23_sel(0)  select
 entry23_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry23_parity_q(4  to 6)  when others;
with wr_entry23_sel(0)  select
 entry23_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry23_parity_q(7)   when others;
with wr_entry23_sel(1)  select
 entry23_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry23_parity_q(8)   when others;
with wr_entry23_sel(1)  select
 entry23_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry23_parity_q(9)   when others;
wr_entry24_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="11000"))  else '0';
wr_entry24_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="11000"))  else '0';
with wr_entry24_sel(0)  select
 entry24_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry24_epn_q(0  to 31)   when others;
with wr_entry24_sel(0)  select
 entry24_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry24_epn_q(32  to 51)  when others;
with wr_entry24_sel(0)  select
 entry24_xbit_d       <= wr_cam_data(52)  when '1',
                          entry24_xbit_q   when others;
with wr_entry24_sel(0)  select
 entry24_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry24_size_q(0  to 2)  when others;
with wr_entry24_sel(0)  select
 entry24_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry24_class_q(0  to 1)  when others;
with wr_entry24_sel(1)  select
 entry24_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry24_extclass_q(0  to 1)  when others;
with wr_entry24_sel(1)  select
 entry24_hv_d         <= wr_cam_data(65)   when '1',
                          entry24_hv_q      when others;
with wr_entry24_sel(1)  select
 entry24_ds_d         <= wr_cam_data(66)   when '1',
                          entry24_ds_q      when others;
with wr_entry24_sel(1)  select
 entry24_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry24_pid_q(0  to 7)  when others;
with wr_entry24_sel(0)  select
 entry24_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry24_cmpmask_q   when others;
with wr_entry24_sel(0)  select
 entry24_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry24_parity_q(0  to 3)   when others;
with wr_entry24_sel(0)  select
 entry24_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry24_parity_q(4  to 6)  when others;
with wr_entry24_sel(0)  select
 entry24_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry24_parity_q(7)   when others;
with wr_entry24_sel(1)  select
 entry24_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry24_parity_q(8)   when others;
with wr_entry24_sel(1)  select
 entry24_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry24_parity_q(9)   when others;
wr_entry25_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="11001"))  else '0';
wr_entry25_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="11001"))  else '0';
with wr_entry25_sel(0)  select
 entry25_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry25_epn_q(0  to 31)   when others;
with wr_entry25_sel(0)  select
 entry25_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry25_epn_q(32  to 51)  when others;
with wr_entry25_sel(0)  select
 entry25_xbit_d       <= wr_cam_data(52)  when '1',
                          entry25_xbit_q   when others;
with wr_entry25_sel(0)  select
 entry25_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry25_size_q(0  to 2)  when others;
with wr_entry25_sel(0)  select
 entry25_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry25_class_q(0  to 1)  when others;
with wr_entry25_sel(1)  select
 entry25_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry25_extclass_q(0  to 1)  when others;
with wr_entry25_sel(1)  select
 entry25_hv_d         <= wr_cam_data(65)   when '1',
                          entry25_hv_q      when others;
with wr_entry25_sel(1)  select
 entry25_ds_d         <= wr_cam_data(66)   when '1',
                          entry25_ds_q      when others;
with wr_entry25_sel(1)  select
 entry25_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry25_pid_q(0  to 7)  when others;
with wr_entry25_sel(0)  select
 entry25_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry25_cmpmask_q   when others;
with wr_entry25_sel(0)  select
 entry25_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry25_parity_q(0  to 3)   when others;
with wr_entry25_sel(0)  select
 entry25_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry25_parity_q(4  to 6)  when others;
with wr_entry25_sel(0)  select
 entry25_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry25_parity_q(7)   when others;
with wr_entry25_sel(1)  select
 entry25_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry25_parity_q(8)   when others;
with wr_entry25_sel(1)  select
 entry25_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry25_parity_q(9)   when others;
wr_entry26_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="11010"))  else '0';
wr_entry26_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="11010"))  else '0';
with wr_entry26_sel(0)  select
 entry26_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry26_epn_q(0  to 31)   when others;
with wr_entry26_sel(0)  select
 entry26_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry26_epn_q(32  to 51)  when others;
with wr_entry26_sel(0)  select
 entry26_xbit_d       <= wr_cam_data(52)  when '1',
                          entry26_xbit_q   when others;
with wr_entry26_sel(0)  select
 entry26_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry26_size_q(0  to 2)  when others;
with wr_entry26_sel(0)  select
 entry26_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry26_class_q(0  to 1)  when others;
with wr_entry26_sel(1)  select
 entry26_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry26_extclass_q(0  to 1)  when others;
with wr_entry26_sel(1)  select
 entry26_hv_d         <= wr_cam_data(65)   when '1',
                          entry26_hv_q      when others;
with wr_entry26_sel(1)  select
 entry26_ds_d         <= wr_cam_data(66)   when '1',
                          entry26_ds_q      when others;
with wr_entry26_sel(1)  select
 entry26_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry26_pid_q(0  to 7)  when others;
with wr_entry26_sel(0)  select
 entry26_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry26_cmpmask_q   when others;
with wr_entry26_sel(0)  select
 entry26_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry26_parity_q(0  to 3)   when others;
with wr_entry26_sel(0)  select
 entry26_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry26_parity_q(4  to 6)  when others;
with wr_entry26_sel(0)  select
 entry26_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry26_parity_q(7)   when others;
with wr_entry26_sel(1)  select
 entry26_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry26_parity_q(8)   when others;
with wr_entry26_sel(1)  select
 entry26_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry26_parity_q(9)   when others;
wr_entry27_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="11011"))  else '0';
wr_entry27_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="11011"))  else '0';
with wr_entry27_sel(0)  select
 entry27_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry27_epn_q(0  to 31)   when others;
with wr_entry27_sel(0)  select
 entry27_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry27_epn_q(32  to 51)  when others;
with wr_entry27_sel(0)  select
 entry27_xbit_d       <= wr_cam_data(52)  when '1',
                          entry27_xbit_q   when others;
with wr_entry27_sel(0)  select
 entry27_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry27_size_q(0  to 2)  when others;
with wr_entry27_sel(0)  select
 entry27_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry27_class_q(0  to 1)  when others;
with wr_entry27_sel(1)  select
 entry27_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry27_extclass_q(0  to 1)  when others;
with wr_entry27_sel(1)  select
 entry27_hv_d         <= wr_cam_data(65)   when '1',
                          entry27_hv_q      when others;
with wr_entry27_sel(1)  select
 entry27_ds_d         <= wr_cam_data(66)   when '1',
                          entry27_ds_q      when others;
with wr_entry27_sel(1)  select
 entry27_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry27_pid_q(0  to 7)  when others;
with wr_entry27_sel(0)  select
 entry27_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry27_cmpmask_q   when others;
with wr_entry27_sel(0)  select
 entry27_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry27_parity_q(0  to 3)   when others;
with wr_entry27_sel(0)  select
 entry27_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry27_parity_q(4  to 6)  when others;
with wr_entry27_sel(0)  select
 entry27_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry27_parity_q(7)   when others;
with wr_entry27_sel(1)  select
 entry27_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry27_parity_q(8)   when others;
with wr_entry27_sel(1)  select
 entry27_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry27_parity_q(9)   when others;
wr_entry28_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="11100"))  else '0';
wr_entry28_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="11100"))  else '0';
with wr_entry28_sel(0)  select
 entry28_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry28_epn_q(0  to 31)   when others;
with wr_entry28_sel(0)  select
 entry28_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry28_epn_q(32  to 51)  when others;
with wr_entry28_sel(0)  select
 entry28_xbit_d       <= wr_cam_data(52)  when '1',
                          entry28_xbit_q   when others;
with wr_entry28_sel(0)  select
 entry28_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry28_size_q(0  to 2)  when others;
with wr_entry28_sel(0)  select
 entry28_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry28_class_q(0  to 1)  when others;
with wr_entry28_sel(1)  select
 entry28_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry28_extclass_q(0  to 1)  when others;
with wr_entry28_sel(1)  select
 entry28_hv_d         <= wr_cam_data(65)   when '1',
                          entry28_hv_q      when others;
with wr_entry28_sel(1)  select
 entry28_ds_d         <= wr_cam_data(66)   when '1',
                          entry28_ds_q      when others;
with wr_entry28_sel(1)  select
 entry28_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry28_pid_q(0  to 7)  when others;
with wr_entry28_sel(0)  select
 entry28_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry28_cmpmask_q   when others;
with wr_entry28_sel(0)  select
 entry28_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry28_parity_q(0  to 3)   when others;
with wr_entry28_sel(0)  select
 entry28_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry28_parity_q(4  to 6)  when others;
with wr_entry28_sel(0)  select
 entry28_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry28_parity_q(7)   when others;
with wr_entry28_sel(1)  select
 entry28_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry28_parity_q(8)   when others;
with wr_entry28_sel(1)  select
 entry28_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry28_parity_q(9)   when others;
wr_entry29_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="11101"))  else '0';
wr_entry29_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="11101"))  else '0';
with wr_entry29_sel(0)  select
 entry29_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry29_epn_q(0  to 31)   when others;
with wr_entry29_sel(0)  select
 entry29_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry29_epn_q(32  to 51)  when others;
with wr_entry29_sel(0)  select
 entry29_xbit_d       <= wr_cam_data(52)  when '1',
                          entry29_xbit_q   when others;
with wr_entry29_sel(0)  select
 entry29_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry29_size_q(0  to 2)  when others;
with wr_entry29_sel(0)  select
 entry29_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry29_class_q(0  to 1)  when others;
with wr_entry29_sel(1)  select
 entry29_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry29_extclass_q(0  to 1)  when others;
with wr_entry29_sel(1)  select
 entry29_hv_d         <= wr_cam_data(65)   when '1',
                          entry29_hv_q      when others;
with wr_entry29_sel(1)  select
 entry29_ds_d         <= wr_cam_data(66)   when '1',
                          entry29_ds_q      when others;
with wr_entry29_sel(1)  select
 entry29_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry29_pid_q(0  to 7)  when others;
with wr_entry29_sel(0)  select
 entry29_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry29_cmpmask_q   when others;
with wr_entry29_sel(0)  select
 entry29_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry29_parity_q(0  to 3)   when others;
with wr_entry29_sel(0)  select
 entry29_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry29_parity_q(4  to 6)  when others;
with wr_entry29_sel(0)  select
 entry29_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry29_parity_q(7)   when others;
with wr_entry29_sel(1)  select
 entry29_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry29_parity_q(8)   when others;
with wr_entry29_sel(1)  select
 entry29_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry29_parity_q(9)   when others;
wr_entry30_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="11110"))  else '0';
wr_entry30_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="11110"))  else '0';
with wr_entry30_sel(0)  select
 entry30_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry30_epn_q(0  to 31)   when others;
with wr_entry30_sel(0)  select
 entry30_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry30_epn_q(32  to 51)  when others;
with wr_entry30_sel(0)  select
 entry30_xbit_d       <= wr_cam_data(52)  when '1',
                          entry30_xbit_q   when others;
with wr_entry30_sel(0)  select
 entry30_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry30_size_q(0  to 2)  when others;
with wr_entry30_sel(0)  select
 entry30_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry30_class_q(0  to 1)  when others;
with wr_entry30_sel(1)  select
 entry30_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry30_extclass_q(0  to 1)  when others;
with wr_entry30_sel(1)  select
 entry30_hv_d         <= wr_cam_data(65)   when '1',
                          entry30_hv_q      when others;
with wr_entry30_sel(1)  select
 entry30_ds_d         <= wr_cam_data(66)   when '1',
                          entry30_ds_q      when others;
with wr_entry30_sel(1)  select
 entry30_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry30_pid_q(0  to 7)  when others;
with wr_entry30_sel(0)  select
 entry30_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry30_cmpmask_q   when others;
with wr_entry30_sel(0)  select
 entry30_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry30_parity_q(0  to 3)   when others;
with wr_entry30_sel(0)  select
 entry30_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry30_parity_q(4  to 6)  when others;
with wr_entry30_sel(0)  select
 entry30_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry30_parity_q(7)   when others;
with wr_entry30_sel(1)  select
 entry30_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry30_parity_q(8)   when others;
with wr_entry30_sel(1)  select
 entry30_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry30_parity_q(9)   when others;
wr_entry31_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="11111"))  else '0';
wr_entry31_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="11111"))  else '0';
with wr_entry31_sel(0)  select
 entry31_epn_d(0  to 31)  <= wr_cam_data(0 to 31)      when '1',
                               entry31_epn_q(0  to 31)   when others;
with wr_entry31_sel(0)  select
 entry31_epn_d(32  to 51)  <= wr_cam_data(32 to 51)    when '1',
                               entry31_epn_q(32  to 51)  when others;
with wr_entry31_sel(0)  select
 entry31_xbit_d       <= wr_cam_data(52)  when '1',
                          entry31_xbit_q   when others;
with wr_entry31_sel(0)  select
 entry31_size_d       <= wr_cam_data(53 to 55)  when '1',
                          entry31_size_q(0  to 2)  when others;
with wr_entry31_sel(0)  select
 entry31_class_d      <= wr_cam_data(61 to 62)     when '1',
                          entry31_class_q(0  to 1)  when others;
with wr_entry31_sel(1)  select
 entry31_extclass_d   <= wr_cam_data(63 to 64)     when '1',
                          entry31_extclass_q(0  to 1)  when others;
with wr_entry31_sel(1)  select
 entry31_hv_d         <= wr_cam_data(65)   when '1',
                          entry31_hv_q      when others;
with wr_entry31_sel(1)  select
 entry31_ds_d         <= wr_cam_data(66)   when '1',
                          entry31_ds_q      when others;
with wr_entry31_sel(1)  select
 entry31_pid_d        <= wr_cam_data(67 to 74)     when '1',
                          entry31_pid_q(0  to 7)  when others;
with wr_entry31_sel(0)  select
 entry31_cmpmask_d      <= wr_cam_data(75 to 83)     when '1',
                          entry31_cmpmask_q   when others;
with wr_entry31_sel(0)  select
 entry31_parity_d(0  to 3)  <= wr_array_data(rpn_width+21 to rpn_width+24)      when '1',
                               entry31_parity_q(0  to 3)   when others;
with wr_entry31_sel(0)  select
 entry31_parity_d(4  to 6)  <= wr_array_data(rpn_width+25 to rpn_width+27)    when '1',
                               entry31_parity_q(4  to 6)  when others;
with wr_entry31_sel(0)  select
 entry31_parity_d(7)    <= wr_array_data(rpn_width+28)     when '1',
                          entry31_parity_q(7)   when others;
with wr_entry31_sel(1)  select
 entry31_parity_d(8)   <= wr_array_data(rpn_width+29)     when '1',
                            entry31_parity_q(8)   when others;
with wr_entry31_sel(1)  select
 entry31_parity_d(9)    <= wr_array_data(rpn_width+30)     when '1',
                          entry31_parity_q(9)   when others;
entry0_inval   <= (comp_invalidate and match_vec(0))   or flash_invalidate;
entry0_v_muxsel(0   to 1) <= (entry0_inval   & wr_entry0_sel(0));
with entry0_v_muxsel(0   to 1) select
 entry0_v_d           <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry0_v_q       when others;
with wr_entry0_sel(0)   select
 entry0_thdid_d(0   to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry0_thdid_q(0   to 3)  when others;
entry1_inval   <= (comp_invalidate and match_vec(1))   or flash_invalidate;
entry1_v_muxsel(0   to 1) <= (entry1_inval   & wr_entry1_sel(0));
with entry1_v_muxsel(0   to 1) select
 entry1_v_d           <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry1_v_q       when others;
with wr_entry1_sel(0)   select
 entry1_thdid_d(0   to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry1_thdid_q(0   to 3)  when others;
entry2_inval   <= (comp_invalidate and match_vec(2))   or flash_invalidate;
entry2_v_muxsel(0   to 1) <= (entry2_inval   & wr_entry2_sel(0));
with entry2_v_muxsel(0   to 1) select
 entry2_v_d           <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry2_v_q       when others;
with wr_entry2_sel(0)   select
 entry2_thdid_d(0   to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry2_thdid_q(0   to 3)  when others;
entry3_inval   <= (comp_invalidate and match_vec(3))   or flash_invalidate;
entry3_v_muxsel(0   to 1) <= (entry3_inval   & wr_entry3_sel(0));
with entry3_v_muxsel(0   to 1) select
 entry3_v_d           <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry3_v_q       when others;
with wr_entry3_sel(0)   select
 entry3_thdid_d(0   to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry3_thdid_q(0   to 3)  when others;
entry4_inval   <= (comp_invalidate and match_vec(4))   or flash_invalidate;
entry4_v_muxsel(0   to 1) <= (entry4_inval   & wr_entry4_sel(0));
with entry4_v_muxsel(0   to 1) select
 entry4_v_d           <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry4_v_q       when others;
with wr_entry4_sel(0)   select
 entry4_thdid_d(0   to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry4_thdid_q(0   to 3)  when others;
entry5_inval   <= (comp_invalidate and match_vec(5))   or flash_invalidate;
entry5_v_muxsel(0   to 1) <= (entry5_inval   & wr_entry5_sel(0));
with entry5_v_muxsel(0   to 1) select
 entry5_v_d           <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry5_v_q       when others;
with wr_entry5_sel(0)   select
 entry5_thdid_d(0   to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry5_thdid_q(0   to 3)  when others;
entry6_inval   <= (comp_invalidate and match_vec(6))   or flash_invalidate;
entry6_v_muxsel(0   to 1) <= (entry6_inval   & wr_entry6_sel(0));
with entry6_v_muxsel(0   to 1) select
 entry6_v_d           <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry6_v_q       when others;
with wr_entry6_sel(0)   select
 entry6_thdid_d(0   to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry6_thdid_q(0   to 3)  when others;
entry7_inval   <= (comp_invalidate and match_vec(7))   or flash_invalidate;
entry7_v_muxsel(0   to 1) <= (entry7_inval   & wr_entry7_sel(0));
with entry7_v_muxsel(0   to 1) select
 entry7_v_d           <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry7_v_q       when others;
with wr_entry7_sel(0)   select
 entry7_thdid_d(0   to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry7_thdid_q(0   to 3)  when others;
entry8_inval   <= (comp_invalidate and match_vec(8))   or flash_invalidate;
entry8_v_muxsel(0   to 1) <= (entry8_inval   & wr_entry8_sel(0));
with entry8_v_muxsel(0   to 1) select
 entry8_v_d           <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry8_v_q       when others;
with wr_entry8_sel(0)   select
 entry8_thdid_d(0   to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry8_thdid_q(0   to 3)  when others;
entry9_inval   <= (comp_invalidate and match_vec(9))   or flash_invalidate;
entry9_v_muxsel(0   to 1) <= (entry9_inval   & wr_entry9_sel(0));
with entry9_v_muxsel(0   to 1) select
 entry9_v_d           <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry9_v_q       when others;
with wr_entry9_sel(0)   select
 entry9_thdid_d(0   to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry9_thdid_q(0   to 3)  when others;
entry10_inval  <= (comp_invalidate and match_vec(10))  or flash_invalidate;
entry10_v_muxsel(0  to 1) <= (entry10_inval  & wr_entry10_sel(0));
with entry10_v_muxsel(0  to 1) select
 entry10_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry10_v_q      when others;
with wr_entry10_sel(0)  select
 entry10_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry10_thdid_q(0  to 3)  when others;
entry11_inval  <= (comp_invalidate and match_vec(11))  or flash_invalidate;
entry11_v_muxsel(0  to 1) <= (entry11_inval  & wr_entry11_sel(0));
with entry11_v_muxsel(0  to 1) select
 entry11_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry11_v_q      when others;
with wr_entry11_sel(0)  select
 entry11_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry11_thdid_q(0  to 3)  when others;
entry12_inval  <= (comp_invalidate and match_vec(12))  or flash_invalidate;
entry12_v_muxsel(0  to 1) <= (entry12_inval  & wr_entry12_sel(0));
with entry12_v_muxsel(0  to 1) select
 entry12_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry12_v_q      when others;
with wr_entry12_sel(0)  select
 entry12_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry12_thdid_q(0  to 3)  when others;
entry13_inval  <= (comp_invalidate and match_vec(13))  or flash_invalidate;
entry13_v_muxsel(0  to 1) <= (entry13_inval  & wr_entry13_sel(0));
with entry13_v_muxsel(0  to 1) select
 entry13_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry13_v_q      when others;
with wr_entry13_sel(0)  select
 entry13_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry13_thdid_q(0  to 3)  when others;
entry14_inval  <= (comp_invalidate and match_vec(14))  or flash_invalidate;
entry14_v_muxsel(0  to 1) <= (entry14_inval  & wr_entry14_sel(0));
with entry14_v_muxsel(0  to 1) select
 entry14_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry14_v_q      when others;
with wr_entry14_sel(0)  select
 entry14_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry14_thdid_q(0  to 3)  when others;
entry15_inval  <= (comp_invalidate and match_vec(15))  or flash_invalidate;
entry15_v_muxsel(0  to 1) <= (entry15_inval  & wr_entry15_sel(0));
with entry15_v_muxsel(0  to 1) select
 entry15_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry15_v_q      when others;
with wr_entry15_sel(0)  select
 entry15_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry15_thdid_q(0  to 3)  when others;
entry16_inval  <= (comp_invalidate and match_vec(16))  or flash_invalidate;
entry16_v_muxsel(0  to 1) <= (entry16_inval  & wr_entry16_sel(0));
with entry16_v_muxsel(0  to 1) select
 entry16_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry16_v_q      when others;
with wr_entry16_sel(0)  select
 entry16_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry16_thdid_q(0  to 3)  when others;
entry17_inval  <= (comp_invalidate and match_vec(17))  or flash_invalidate;
entry17_v_muxsel(0  to 1) <= (entry17_inval  & wr_entry17_sel(0));
with entry17_v_muxsel(0  to 1) select
 entry17_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry17_v_q      when others;
with wr_entry17_sel(0)  select
 entry17_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry17_thdid_q(0  to 3)  when others;
entry18_inval  <= (comp_invalidate and match_vec(18))  or flash_invalidate;
entry18_v_muxsel(0  to 1) <= (entry18_inval  & wr_entry18_sel(0));
with entry18_v_muxsel(0  to 1) select
 entry18_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry18_v_q      when others;
with wr_entry18_sel(0)  select
 entry18_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry18_thdid_q(0  to 3)  when others;
entry19_inval  <= (comp_invalidate and match_vec(19))  or flash_invalidate;
entry19_v_muxsel(0  to 1) <= (entry19_inval  & wr_entry19_sel(0));
with entry19_v_muxsel(0  to 1) select
 entry19_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry19_v_q      when others;
with wr_entry19_sel(0)  select
 entry19_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry19_thdid_q(0  to 3)  when others;
entry20_inval  <= (comp_invalidate and match_vec(20))  or flash_invalidate;
entry20_v_muxsel(0  to 1) <= (entry20_inval  & wr_entry20_sel(0));
with entry20_v_muxsel(0  to 1) select
 entry20_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry20_v_q      when others;
with wr_entry20_sel(0)  select
 entry20_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry20_thdid_q(0  to 3)  when others;
entry21_inval  <= (comp_invalidate and match_vec(21))  or flash_invalidate;
entry21_v_muxsel(0  to 1) <= (entry21_inval  & wr_entry21_sel(0));
with entry21_v_muxsel(0  to 1) select
 entry21_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry21_v_q      when others;
with wr_entry21_sel(0)  select
 entry21_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry21_thdid_q(0  to 3)  when others;
entry22_inval  <= (comp_invalidate and match_vec(22))  or flash_invalidate;
entry22_v_muxsel(0  to 1) <= (entry22_inval  & wr_entry22_sel(0));
with entry22_v_muxsel(0  to 1) select
 entry22_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry22_v_q      when others;
with wr_entry22_sel(0)  select
 entry22_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry22_thdid_q(0  to 3)  when others;
entry23_inval  <= (comp_invalidate and match_vec(23))  or flash_invalidate;
entry23_v_muxsel(0  to 1) <= (entry23_inval  & wr_entry23_sel(0));
with entry23_v_muxsel(0  to 1) select
 entry23_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry23_v_q      when others;
with wr_entry23_sel(0)  select
 entry23_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry23_thdid_q(0  to 3)  when others;
entry24_inval  <= (comp_invalidate and match_vec(24))  or flash_invalidate;
entry24_v_muxsel(0  to 1) <= (entry24_inval  & wr_entry24_sel(0));
with entry24_v_muxsel(0  to 1) select
 entry24_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry24_v_q      when others;
with wr_entry24_sel(0)  select
 entry24_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry24_thdid_q(0  to 3)  when others;
entry25_inval  <= (comp_invalidate and match_vec(25))  or flash_invalidate;
entry25_v_muxsel(0  to 1) <= (entry25_inval  & wr_entry25_sel(0));
with entry25_v_muxsel(0  to 1) select
 entry25_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry25_v_q      when others;
with wr_entry25_sel(0)  select
 entry25_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry25_thdid_q(0  to 3)  when others;
entry26_inval  <= (comp_invalidate and match_vec(26))  or flash_invalidate;
entry26_v_muxsel(0  to 1) <= (entry26_inval  & wr_entry26_sel(0));
with entry26_v_muxsel(0  to 1) select
 entry26_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry26_v_q      when others;
with wr_entry26_sel(0)  select
 entry26_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry26_thdid_q(0  to 3)  when others;
entry27_inval  <= (comp_invalidate and match_vec(27))  or flash_invalidate;
entry27_v_muxsel(0  to 1) <= (entry27_inval  & wr_entry27_sel(0));
with entry27_v_muxsel(0  to 1) select
 entry27_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry27_v_q      when others;
with wr_entry27_sel(0)  select
 entry27_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry27_thdid_q(0  to 3)  when others;
entry28_inval  <= (comp_invalidate and match_vec(28))  or flash_invalidate;
entry28_v_muxsel(0  to 1) <= (entry28_inval  & wr_entry28_sel(0));
with entry28_v_muxsel(0  to 1) select
 entry28_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry28_v_q      when others;
with wr_entry28_sel(0)  select
 entry28_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry28_thdid_q(0  to 3)  when others;
entry29_inval  <= (comp_invalidate and match_vec(29))  or flash_invalidate;
entry29_v_muxsel(0  to 1) <= (entry29_inval  & wr_entry29_sel(0));
with entry29_v_muxsel(0  to 1) select
 entry29_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry29_v_q      when others;
with wr_entry29_sel(0)  select
 entry29_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry29_thdid_q(0  to 3)  when others;
entry30_inval  <= (comp_invalidate and match_vec(30))  or flash_invalidate;
entry30_v_muxsel(0  to 1) <= (entry30_inval  & wr_entry30_sel(0));
with entry30_v_muxsel(0  to 1) select
 entry30_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry30_v_q      when others;
with wr_entry30_sel(0)  select
 entry30_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry30_thdid_q(0  to 3)  when others;
entry31_inval  <= (comp_invalidate and match_vec(31))  or flash_invalidate;
entry31_v_muxsel(0  to 1) <= (entry31_inval  & wr_entry31_sel(0));
with entry31_v_muxsel(0  to 1) select
 entry31_v_d          <= '0'  when "10",
                          '0'  when "11",
                          wr_cam_data(56)  when "01",
                          entry31_v_q      when others;
with wr_entry31_sel(0)  select
 entry31_thdid_d(0  to 3) <= wr_cam_data(57 to 60)  when '1',
                               entry31_thdid_q(0  to 3)  when others;
entry0_cam_vec   <= entry0_epn_q   & entry0_xbit_q   & entry0_size_q   & entry0_v_q   & entry0_thdid_q   &
                      entry0_class_q   & entry0_extclass_q   & entry0_hv_q   & entry0_ds_q   & entry0_pid_q   & entry0_cmpmask_q;
entry1_cam_vec   <= entry1_epn_q   & entry1_xbit_q   & entry1_size_q   & entry1_v_q   & entry1_thdid_q   &
                      entry1_class_q   & entry1_extclass_q   & entry1_hv_q   & entry1_ds_q   & entry1_pid_q   & entry1_cmpmask_q;
entry2_cam_vec   <= entry2_epn_q   & entry2_xbit_q   & entry2_size_q   & entry2_v_q   & entry2_thdid_q   &
                      entry2_class_q   & entry2_extclass_q   & entry2_hv_q   & entry2_ds_q   & entry2_pid_q   & entry2_cmpmask_q;
entry3_cam_vec   <= entry3_epn_q   & entry3_xbit_q   & entry3_size_q   & entry3_v_q   & entry3_thdid_q   &
                      entry3_class_q   & entry3_extclass_q   & entry3_hv_q   & entry3_ds_q   & entry3_pid_q   & entry3_cmpmask_q;
entry4_cam_vec   <= entry4_epn_q   & entry4_xbit_q   & entry4_size_q   & entry4_v_q   & entry4_thdid_q   &
                      entry4_class_q   & entry4_extclass_q   & entry4_hv_q   & entry4_ds_q   & entry4_pid_q   & entry4_cmpmask_q;
entry5_cam_vec   <= entry5_epn_q   & entry5_xbit_q   & entry5_size_q   & entry5_v_q   & entry5_thdid_q   &
                      entry5_class_q   & entry5_extclass_q   & entry5_hv_q   & entry5_ds_q   & entry5_pid_q   & entry5_cmpmask_q;
entry6_cam_vec   <= entry6_epn_q   & entry6_xbit_q   & entry6_size_q   & entry6_v_q   & entry6_thdid_q   &
                      entry6_class_q   & entry6_extclass_q   & entry6_hv_q   & entry6_ds_q   & entry6_pid_q   & entry6_cmpmask_q;
entry7_cam_vec   <= entry7_epn_q   & entry7_xbit_q   & entry7_size_q   & entry7_v_q   & entry7_thdid_q   &
                      entry7_class_q   & entry7_extclass_q   & entry7_hv_q   & entry7_ds_q   & entry7_pid_q   & entry7_cmpmask_q;
entry8_cam_vec   <= entry8_epn_q   & entry8_xbit_q   & entry8_size_q   & entry8_v_q   & entry8_thdid_q   &
                      entry8_class_q   & entry8_extclass_q   & entry8_hv_q   & entry8_ds_q   & entry8_pid_q   & entry8_cmpmask_q;
entry9_cam_vec   <= entry9_epn_q   & entry9_xbit_q   & entry9_size_q   & entry9_v_q   & entry9_thdid_q   &
                      entry9_class_q   & entry9_extclass_q   & entry9_hv_q   & entry9_ds_q   & entry9_pid_q   & entry9_cmpmask_q;
entry10_cam_vec  <= entry10_epn_q  & entry10_xbit_q  & entry10_size_q  & entry10_v_q  & entry10_thdid_q  &
                      entry10_class_q  & entry10_extclass_q  & entry10_hv_q  & entry10_ds_q  & entry10_pid_q  & entry10_cmpmask_q;
entry11_cam_vec  <= entry11_epn_q  & entry11_xbit_q  & entry11_size_q  & entry11_v_q  & entry11_thdid_q  &
                      entry11_class_q  & entry11_extclass_q  & entry11_hv_q  & entry11_ds_q  & entry11_pid_q  & entry11_cmpmask_q;
entry12_cam_vec  <= entry12_epn_q  & entry12_xbit_q  & entry12_size_q  & entry12_v_q  & entry12_thdid_q  &
                      entry12_class_q  & entry12_extclass_q  & entry12_hv_q  & entry12_ds_q  & entry12_pid_q  & entry12_cmpmask_q;
entry13_cam_vec  <= entry13_epn_q  & entry13_xbit_q  & entry13_size_q  & entry13_v_q  & entry13_thdid_q  &
                      entry13_class_q  & entry13_extclass_q  & entry13_hv_q  & entry13_ds_q  & entry13_pid_q  & entry13_cmpmask_q;
entry14_cam_vec  <= entry14_epn_q  & entry14_xbit_q  & entry14_size_q  & entry14_v_q  & entry14_thdid_q  &
                      entry14_class_q  & entry14_extclass_q  & entry14_hv_q  & entry14_ds_q  & entry14_pid_q  & entry14_cmpmask_q;
entry15_cam_vec  <= entry15_epn_q  & entry15_xbit_q  & entry15_size_q  & entry15_v_q  & entry15_thdid_q  &
                      entry15_class_q  & entry15_extclass_q  & entry15_hv_q  & entry15_ds_q  & entry15_pid_q  & entry15_cmpmask_q;
entry16_cam_vec  <= entry16_epn_q  & entry16_xbit_q  & entry16_size_q  & entry16_v_q  & entry16_thdid_q  &
                      entry16_class_q  & entry16_extclass_q  & entry16_hv_q  & entry16_ds_q  & entry16_pid_q  & entry16_cmpmask_q;
entry17_cam_vec  <= entry17_epn_q  & entry17_xbit_q  & entry17_size_q  & entry17_v_q  & entry17_thdid_q  &
                      entry17_class_q  & entry17_extclass_q  & entry17_hv_q  & entry17_ds_q  & entry17_pid_q  & entry17_cmpmask_q;
entry18_cam_vec  <= entry18_epn_q  & entry18_xbit_q  & entry18_size_q  & entry18_v_q  & entry18_thdid_q  &
                      entry18_class_q  & entry18_extclass_q  & entry18_hv_q  & entry18_ds_q  & entry18_pid_q  & entry18_cmpmask_q;
entry19_cam_vec  <= entry19_epn_q  & entry19_xbit_q  & entry19_size_q  & entry19_v_q  & entry19_thdid_q  &
                      entry19_class_q  & entry19_extclass_q  & entry19_hv_q  & entry19_ds_q  & entry19_pid_q  & entry19_cmpmask_q;
entry20_cam_vec  <= entry20_epn_q  & entry20_xbit_q  & entry20_size_q  & entry20_v_q  & entry20_thdid_q  &
                      entry20_class_q  & entry20_extclass_q  & entry20_hv_q  & entry20_ds_q  & entry20_pid_q  & entry20_cmpmask_q;
entry21_cam_vec  <= entry21_epn_q  & entry21_xbit_q  & entry21_size_q  & entry21_v_q  & entry21_thdid_q  &
                      entry21_class_q  & entry21_extclass_q  & entry21_hv_q  & entry21_ds_q  & entry21_pid_q  & entry21_cmpmask_q;
entry22_cam_vec  <= entry22_epn_q  & entry22_xbit_q  & entry22_size_q  & entry22_v_q  & entry22_thdid_q  &
                      entry22_class_q  & entry22_extclass_q  & entry22_hv_q  & entry22_ds_q  & entry22_pid_q  & entry22_cmpmask_q;
entry23_cam_vec  <= entry23_epn_q  & entry23_xbit_q  & entry23_size_q  & entry23_v_q  & entry23_thdid_q  &
                      entry23_class_q  & entry23_extclass_q  & entry23_hv_q  & entry23_ds_q  & entry23_pid_q  & entry23_cmpmask_q;
entry24_cam_vec  <= entry24_epn_q  & entry24_xbit_q  & entry24_size_q  & entry24_v_q  & entry24_thdid_q  &
                      entry24_class_q  & entry24_extclass_q  & entry24_hv_q  & entry24_ds_q  & entry24_pid_q  & entry24_cmpmask_q;
entry25_cam_vec  <= entry25_epn_q  & entry25_xbit_q  & entry25_size_q  & entry25_v_q  & entry25_thdid_q  &
                      entry25_class_q  & entry25_extclass_q  & entry25_hv_q  & entry25_ds_q  & entry25_pid_q  & entry25_cmpmask_q;
entry26_cam_vec  <= entry26_epn_q  & entry26_xbit_q  & entry26_size_q  & entry26_v_q  & entry26_thdid_q  &
                      entry26_class_q  & entry26_extclass_q  & entry26_hv_q  & entry26_ds_q  & entry26_pid_q  & entry26_cmpmask_q;
entry27_cam_vec  <= entry27_epn_q  & entry27_xbit_q  & entry27_size_q  & entry27_v_q  & entry27_thdid_q  &
                      entry27_class_q  & entry27_extclass_q  & entry27_hv_q  & entry27_ds_q  & entry27_pid_q  & entry27_cmpmask_q;
entry28_cam_vec  <= entry28_epn_q  & entry28_xbit_q  & entry28_size_q  & entry28_v_q  & entry28_thdid_q  &
                      entry28_class_q  & entry28_extclass_q  & entry28_hv_q  & entry28_ds_q  & entry28_pid_q  & entry28_cmpmask_q;
entry29_cam_vec  <= entry29_epn_q  & entry29_xbit_q  & entry29_size_q  & entry29_v_q  & entry29_thdid_q  &
                      entry29_class_q  & entry29_extclass_q  & entry29_hv_q  & entry29_ds_q  & entry29_pid_q  & entry29_cmpmask_q;
entry30_cam_vec  <= entry30_epn_q  & entry30_xbit_q  & entry30_size_q  & entry30_v_q  & entry30_thdid_q  &
                      entry30_class_q  & entry30_extclass_q  & entry30_hv_q  & entry30_ds_q  & entry30_pid_q  & entry30_cmpmask_q;
entry31_cam_vec  <= entry31_epn_q  & entry31_xbit_q  & entry31_size_q  & entry31_v_q  & entry31_thdid_q  &
                      entry31_class_q  & entry31_extclass_q  & entry31_hv_q  & entry31_ds_q  & entry31_pid_q  & entry31_cmpmask_q;
cam_cmp_data_muxsel <= not(comp_request) & cam_hit_entry_d;
with cam_cmp_data_muxsel select
  cam_cmp_data_d <= entry0_cam_vec when "000000",
                     entry1_cam_vec   when "000001",
                     entry2_cam_vec   when "000010",
                     entry3_cam_vec   when "000011",
                     entry4_cam_vec   when "000100",
                     entry5_cam_vec   when "000101",
                     entry6_cam_vec   when "000110",
                     entry7_cam_vec   when "000111",
                     entry8_cam_vec   when "001000",
                     entry9_cam_vec   when "001001",
                     entry10_cam_vec  when "001010",
                     entry11_cam_vec  when "001011",
                     entry12_cam_vec  when "001100",
                     entry13_cam_vec  when "001101",
                     entry14_cam_vec  when "001110",
                     entry15_cam_vec  when "001111",
                     entry16_cam_vec  when "010000",
                     entry17_cam_vec  when "010001",
                     entry18_cam_vec  when "010010",
                     entry19_cam_vec  when "010011",
                     entry20_cam_vec  when "010100",
                     entry21_cam_vec  when "010101",
                     entry22_cam_vec  when "010110",
                     entry23_cam_vec  when "010111",
                     entry24_cam_vec  when "011000",
                     entry25_cam_vec  when "011001",
                     entry26_cam_vec  when "011010",
                     entry27_cam_vec  when "011011",
                     entry28_cam_vec  when "011100",
                     entry29_cam_vec  when "011101",
                     entry30_cam_vec  when "011110",
                     entry31_cam_vec  when "011111",
                     cam_cmp_data_q  when others;
cam_cmp_data_np1 <= cam_cmp_data_q;
rd_cam_data_muxsel <= not(rd_val) & rw_entry;
with rd_cam_data_muxsel select
   rd_cam_data_d <= entry0_cam_vec when "000000",
                     entry1_cam_vec   when "000001",
                     entry2_cam_vec   when "000010",
                     entry3_cam_vec   when "000011",
                     entry4_cam_vec   when "000100",
                     entry5_cam_vec   when "000101",
                     entry6_cam_vec   when "000110",
                     entry7_cam_vec   when "000111",
                     entry8_cam_vec   when "001000",
                     entry9_cam_vec   when "001001",
                     entry10_cam_vec  when "001010",
                     entry11_cam_vec  when "001011",
                     entry12_cam_vec  when "001100",
                     entry13_cam_vec  when "001101",
                     entry14_cam_vec  when "001110",
                     entry15_cam_vec  when "001111",
                     entry16_cam_vec  when "010000",
                     entry17_cam_vec  when "010001",
                     entry18_cam_vec  when "010010",
                     entry19_cam_vec  when "010011",
                     entry20_cam_vec  when "010100",
                     entry21_cam_vec  when "010101",
                     entry22_cam_vec  when "010110",
                     entry23_cam_vec  when "010111",
                     entry24_cam_vec  when "011000",
                     entry25_cam_vec  when "011001",
                     entry26_cam_vec  when "011010",
                     entry27_cam_vec  when "011011",
                     entry28_cam_vec  when "011100",
                     entry29_cam_vec  when "011101",
                     entry30_cam_vec  when "011110",
                     entry31_cam_vec  when "011111",
                     rd_cam_data_q  when others;
with cam_cmp_data_muxsel select
  cam_cmp_parity_d <= entry0_parity_q when "000000",
                     entry1_parity_q   when "000001",
                     entry2_parity_q   when "000010",
                     entry3_parity_q   when "000011",
                     entry4_parity_q   when "000100",
                     entry5_parity_q   when "000101",
                     entry6_parity_q   when "000110",
                     entry7_parity_q   when "000111",
                     entry8_parity_q   when "001000",
                     entry9_parity_q   when "001001",
                     entry10_parity_q  when "001010",
                     entry11_parity_q  when "001011",
                     entry12_parity_q  when "001100",
                     entry13_parity_q  when "001101",
                     entry14_parity_q  when "001110",
                     entry15_parity_q  when "001111",
                     entry16_parity_q  when "010000",
                     entry17_parity_q  when "010001",
                     entry18_parity_q  when "010010",
                     entry19_parity_q  when "010011",
                     entry20_parity_q  when "010100",
                     entry21_parity_q  when "010101",
                     entry22_parity_q  when "010110",
                     entry23_parity_q  when "010111",
                     entry24_parity_q  when "011000",
                     entry25_parity_q  when "011001",
                     entry26_parity_q  when "011010",
                     entry27_parity_q  when "011011",
                     entry28_parity_q  when "011100",
                     entry29_parity_q  when "011101",
                     entry30_parity_q  when "011110",
                     entry31_parity_q  when "011111",
                     cam_cmp_parity_q  when others;
array_cmp_data_np1(0 to 50) <= array_cmp_data_bram(2 to 31) & array_cmp_data_bram(34 to 39) & array_cmp_data_bram(41 to 55);
array_cmp_data_np1(51 to 60) <= cam_cmp_parity_q;
array_cmp_data_np1(61 to 67) <= array_cmp_data_bramp(66 to 72);
array_cmp_data <= array_cmp_data_np1;
with rd_cam_data_muxsel select
   rd_array_data_d(51 to 60) <= entry0_parity_q when "000000",
                     entry1_parity_q   when "000001",
                     entry2_parity_q   when "000010",
                     entry3_parity_q   when "000011",
                     entry4_parity_q   when "000100",
                     entry5_parity_q   when "000101",
                     entry6_parity_q   when "000110",
                     entry7_parity_q   when "000111",
                     entry8_parity_q   when "001000",
                     entry9_parity_q   when "001001",
                     entry10_parity_q  when "001010",
                     entry11_parity_q  when "001011",
                     entry12_parity_q  when "001100",
                     entry13_parity_q  when "001101",
                     entry14_parity_q  when "001110",
                     entry15_parity_q  when "001111",
                     entry16_parity_q  when "010000",
                     entry17_parity_q  when "010001",
                     entry18_parity_q  when "010010",
                     entry19_parity_q  when "010011",
                     entry20_parity_q  when "010100",
                     entry21_parity_q  when "010101",
                     entry22_parity_q  when "010110",
                     entry23_parity_q  when "010111",
                     entry24_parity_q  when "011000",
                     entry25_parity_q  when "011001",
                     entry26_parity_q  when "011010",
                     entry27_parity_q  when "011011",
                     entry28_parity_q  when "011100",
                     entry29_parity_q  when "011101",
                     entry30_parity_q  when "011110",
                     entry31_parity_q  when "011111",
                     rd_array_data_q(51 to 60) when others;
rpn_np2_d(22 to 33)   <= ( comp_addr_np1_q(22 to 33) and (22 to 33 => bypass_mux_enab_np1 ) ) or
                                       ( array_cmp_data_np1(0 to 11) and (0 to 11 => not(bypass_mux_enab_np1)) );
rpn_np2_d(34 to 39)   <= ( comp_addr_np1_q(34 to 39) and (34 to 39 => (not(cam_cmp_data_np1(75)) or bypass_mux_enab_np1)) ) or 
                                       ( array_cmp_data_np1(12 to 17) and (12 to 17 => (cam_cmp_data_np1(75) and not bypass_mux_enab_np1)) );
rpn_np2_d(40 to 43)   <= ( comp_addr_np1_q(40 to 43) and (40 to 43 => (not(cam_cmp_data_np1(76)) or bypass_mux_enab_np1)) ) or
                                       ( array_cmp_data_np1(18 to 21) and (18 to 21 => (cam_cmp_data_np1(76) and not bypass_mux_enab_np1)) );
rpn_np2_d(44 to 47)   <= ( comp_addr_np1_q(44 to 47) and (44 to 47 => (not(cam_cmp_data_np1(77)) or bypass_mux_enab_np1)) ) or
                                       ( array_cmp_data_np1(22 to 25) and (22 to 25 => (cam_cmp_data_np1(77) and not bypass_mux_enab_np1)) );
rpn_np2_d(48 to 51)   <= ( comp_addr_np1_q(48 to 51) and (48 to 51 => (not(cam_cmp_data_np1(78)) or bypass_mux_enab_np1)) ) or
                                       ( array_cmp_data_np1(26 to 29) and (26 to 29 => (cam_cmp_data_np1(78) and not bypass_mux_enab_np1)) );
attr_np2_d(0 to 20)         <= ( bypass_attr_np1(0 to 20) and (0 to 20 => bypass_mux_enab_np1) ) or
                                       ( array_cmp_data_np1(30 to 50) and (30 to 50 => not bypass_mux_enab_np1) );
rpn_np2(22 to 51)  <=  rpn_np2_q(22 to 51);
attr_np2(0 to 20)  <=  attr_np2_q(0 to 20);
matchline_comb0   : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry0_size_q,       
    entry_cmpmask                    => entry0_cmpmask_q(0   to 3),     
    entry_xbit                       => entry0_xbit_q,       
    entry_xbitmask                   => entry0_cmpmask_q(4   to 7),     
    entry_epn                        => entry0_epn_q,        
    comp_class                       => comp_class,          
    entry_class                      => entry0_class_q,      
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry0_extclass_q,   
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry0_hv_q,         
    entry_ds                         => entry0_ds_q,         
    state_enable                     => state_enable,        
    entry_thdid                      => entry0_thdid_q,      
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry0_pid_q,        
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry0_v_q,          
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(0)         
  );
matchline_comb1   : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry1_size_q,       
    entry_cmpmask                    => entry1_cmpmask_q(0   to 3),     
    entry_xbit                       => entry1_xbit_q,       
    entry_xbitmask                   => entry1_cmpmask_q(4   to 7),     
    entry_epn                        => entry1_epn_q,        
    comp_class                       => comp_class,          
    entry_class                      => entry1_class_q,      
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry1_extclass_q,   
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry1_hv_q,         
    entry_ds                         => entry1_ds_q,         
    state_enable                     => state_enable,        
    entry_thdid                      => entry1_thdid_q,      
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry1_pid_q,        
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry1_v_q,          
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(1)         
  );
matchline_comb2   : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry2_size_q,       
    entry_cmpmask                    => entry2_cmpmask_q(0   to 3),     
    entry_xbit                       => entry2_xbit_q,       
    entry_xbitmask                   => entry2_cmpmask_q(4   to 7),     
    entry_epn                        => entry2_epn_q,        
    comp_class                       => comp_class,          
    entry_class                      => entry2_class_q,      
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry2_extclass_q,   
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry2_hv_q,         
    entry_ds                         => entry2_ds_q,         
    state_enable                     => state_enable,        
    entry_thdid                      => entry2_thdid_q,      
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry2_pid_q,        
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry2_v_q,          
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(2)         
  );
matchline_comb3   : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry3_size_q,       
    entry_cmpmask                    => entry3_cmpmask_q(0   to 3),     
    entry_xbit                       => entry3_xbit_q,       
    entry_xbitmask                   => entry3_cmpmask_q(4   to 7),     
    entry_epn                        => entry3_epn_q,        
    comp_class                       => comp_class,          
    entry_class                      => entry3_class_q,      
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry3_extclass_q,   
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry3_hv_q,         
    entry_ds                         => entry3_ds_q,         
    state_enable                     => state_enable,        
    entry_thdid                      => entry3_thdid_q,      
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry3_pid_q,        
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry3_v_q,          
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(3)         
  );
matchline_comb4   : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry4_size_q,       
    entry_cmpmask                    => entry4_cmpmask_q(0   to 3),     
    entry_xbit                       => entry4_xbit_q,       
    entry_xbitmask                   => entry4_cmpmask_q(4   to 7),     
    entry_epn                        => entry4_epn_q,        
    comp_class                       => comp_class,          
    entry_class                      => entry4_class_q,      
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry4_extclass_q,   
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry4_hv_q,         
    entry_ds                         => entry4_ds_q,         
    state_enable                     => state_enable,        
    entry_thdid                      => entry4_thdid_q,      
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry4_pid_q,        
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry4_v_q,          
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(4)         
  );
matchline_comb5   : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry5_size_q,       
    entry_cmpmask                    => entry5_cmpmask_q(0   to 3),     
    entry_xbit                       => entry5_xbit_q,       
    entry_xbitmask                   => entry5_cmpmask_q(4   to 7),     
    entry_epn                        => entry5_epn_q,        
    comp_class                       => comp_class,          
    entry_class                      => entry5_class_q,      
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry5_extclass_q,   
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry5_hv_q,         
    entry_ds                         => entry5_ds_q,         
    state_enable                     => state_enable,        
    entry_thdid                      => entry5_thdid_q,      
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry5_pid_q,        
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry5_v_q,          
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(5)         
  );
matchline_comb6   : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry6_size_q,       
    entry_cmpmask                    => entry6_cmpmask_q(0   to 3),     
    entry_xbit                       => entry6_xbit_q,       
    entry_xbitmask                   => entry6_cmpmask_q(4   to 7),     
    entry_epn                        => entry6_epn_q,        
    comp_class                       => comp_class,          
    entry_class                      => entry6_class_q,      
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry6_extclass_q,   
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry6_hv_q,         
    entry_ds                         => entry6_ds_q,         
    state_enable                     => state_enable,        
    entry_thdid                      => entry6_thdid_q,      
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry6_pid_q,        
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry6_v_q,          
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(6)         
  );
matchline_comb7   : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry7_size_q,       
    entry_cmpmask                    => entry7_cmpmask_q(0   to 3),     
    entry_xbit                       => entry7_xbit_q,       
    entry_xbitmask                   => entry7_cmpmask_q(4   to 7),     
    entry_epn                        => entry7_epn_q,        
    comp_class                       => comp_class,          
    entry_class                      => entry7_class_q,      
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry7_extclass_q,   
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry7_hv_q,         
    entry_ds                         => entry7_ds_q,         
    state_enable                     => state_enable,        
    entry_thdid                      => entry7_thdid_q,      
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry7_pid_q,        
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry7_v_q,          
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(7)         
  );
matchline_comb8   : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry8_size_q,       
    entry_cmpmask                    => entry8_cmpmask_q(0   to 3),     
    entry_xbit                       => entry8_xbit_q,       
    entry_xbitmask                   => entry8_cmpmask_q(4   to 7),     
    entry_epn                        => entry8_epn_q,        
    comp_class                       => comp_class,          
    entry_class                      => entry8_class_q,      
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry8_extclass_q,   
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry8_hv_q,         
    entry_ds                         => entry8_ds_q,         
    state_enable                     => state_enable,        
    entry_thdid                      => entry8_thdid_q,      
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry8_pid_q,        
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry8_v_q,          
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(8)         
  );
matchline_comb9   : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry9_size_q,       
    entry_cmpmask                    => entry9_cmpmask_q(0   to 3),     
    entry_xbit                       => entry9_xbit_q,       
    entry_xbitmask                   => entry9_cmpmask_q(4   to 7),     
    entry_epn                        => entry9_epn_q,        
    comp_class                       => comp_class,          
    entry_class                      => entry9_class_q,      
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry9_extclass_q,   
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry9_hv_q,         
    entry_ds                         => entry9_ds_q,         
    state_enable                     => state_enable,        
    entry_thdid                      => entry9_thdid_q,      
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry9_pid_q,        
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry9_v_q,          
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(9)         
  );
matchline_comb10  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry10_size_q,      
    entry_cmpmask                    => entry10_cmpmask_q(0  to 3),     
    entry_xbit                       => entry10_xbit_q,      
    entry_xbitmask                   => entry10_cmpmask_q(4  to 7),     
    entry_epn                        => entry10_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry10_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry10_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry10_hv_q,        
    entry_ds                         => entry10_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry10_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry10_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry10_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(10)        
  );
matchline_comb11  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry11_size_q,      
    entry_cmpmask                    => entry11_cmpmask_q(0  to 3),     
    entry_xbit                       => entry11_xbit_q,      
    entry_xbitmask                   => entry11_cmpmask_q(4  to 7),     
    entry_epn                        => entry11_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry11_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry11_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry11_hv_q,        
    entry_ds                         => entry11_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry11_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry11_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry11_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(11)        
  );
matchline_comb12  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry12_size_q,      
    entry_cmpmask                    => entry12_cmpmask_q(0  to 3),     
    entry_xbit                       => entry12_xbit_q,      
    entry_xbitmask                   => entry12_cmpmask_q(4  to 7),     
    entry_epn                        => entry12_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry12_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry12_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry12_hv_q,        
    entry_ds                         => entry12_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry12_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry12_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry12_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(12)        
  );
matchline_comb13  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry13_size_q,      
    entry_cmpmask                    => entry13_cmpmask_q(0  to 3),     
    entry_xbit                       => entry13_xbit_q,      
    entry_xbitmask                   => entry13_cmpmask_q(4  to 7),     
    entry_epn                        => entry13_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry13_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry13_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry13_hv_q,        
    entry_ds                         => entry13_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry13_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry13_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry13_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(13)        
  );
matchline_comb14  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry14_size_q,      
    entry_cmpmask                    => entry14_cmpmask_q(0  to 3),     
    entry_xbit                       => entry14_xbit_q,      
    entry_xbitmask                   => entry14_cmpmask_q(4  to 7),     
    entry_epn                        => entry14_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry14_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry14_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry14_hv_q,        
    entry_ds                         => entry14_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry14_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry14_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry14_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(14)        
  );
matchline_comb15  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry15_size_q,      
    entry_cmpmask                    => entry15_cmpmask_q(0  to 3),     
    entry_xbit                       => entry15_xbit_q,      
    entry_xbitmask                   => entry15_cmpmask_q(4  to 7),     
    entry_epn                        => entry15_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry15_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry15_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry15_hv_q,        
    entry_ds                         => entry15_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry15_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry15_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry15_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(15)        
  );
matchline_comb16  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry16_size_q,      
    entry_cmpmask                    => entry16_cmpmask_q(0  to 3),     
    entry_xbit                       => entry16_xbit_q,      
    entry_xbitmask                   => entry16_cmpmask_q(4  to 7),     
    entry_epn                        => entry16_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry16_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry16_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry16_hv_q,        
    entry_ds                         => entry16_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry16_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry16_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry16_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(16)        
  );
matchline_comb17  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry17_size_q,      
    entry_cmpmask                    => entry17_cmpmask_q(0  to 3),     
    entry_xbit                       => entry17_xbit_q,      
    entry_xbitmask                   => entry17_cmpmask_q(4  to 7),     
    entry_epn                        => entry17_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry17_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry17_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry17_hv_q,        
    entry_ds                         => entry17_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry17_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry17_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry17_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(17)        
  );
matchline_comb18  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry18_size_q,      
    entry_cmpmask                    => entry18_cmpmask_q(0  to 3),     
    entry_xbit                       => entry18_xbit_q,      
    entry_xbitmask                   => entry18_cmpmask_q(4  to 7),     
    entry_epn                        => entry18_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry18_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry18_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry18_hv_q,        
    entry_ds                         => entry18_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry18_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry18_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry18_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(18)        
  );
matchline_comb19  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry19_size_q,      
    entry_cmpmask                    => entry19_cmpmask_q(0  to 3),     
    entry_xbit                       => entry19_xbit_q,      
    entry_xbitmask                   => entry19_cmpmask_q(4  to 7),     
    entry_epn                        => entry19_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry19_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry19_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry19_hv_q,        
    entry_ds                         => entry19_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry19_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry19_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry19_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(19)        
  );
matchline_comb20  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry20_size_q,      
    entry_cmpmask                    => entry20_cmpmask_q(0  to 3),     
    entry_xbit                       => entry20_xbit_q,      
    entry_xbitmask                   => entry20_cmpmask_q(4  to 7),     
    entry_epn                        => entry20_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry20_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry20_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry20_hv_q,        
    entry_ds                         => entry20_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry20_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry20_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry20_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(20)        
  );
matchline_comb21  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry21_size_q,      
    entry_cmpmask                    => entry21_cmpmask_q(0  to 3),     
    entry_xbit                       => entry21_xbit_q,      
    entry_xbitmask                   => entry21_cmpmask_q(4  to 7),     
    entry_epn                        => entry21_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry21_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry21_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry21_hv_q,        
    entry_ds                         => entry21_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry21_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry21_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry21_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(21)        
  );
matchline_comb22  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry22_size_q,      
    entry_cmpmask                    => entry22_cmpmask_q(0  to 3),     
    entry_xbit                       => entry22_xbit_q,      
    entry_xbitmask                   => entry22_cmpmask_q(4  to 7),     
    entry_epn                        => entry22_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry22_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry22_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry22_hv_q,        
    entry_ds                         => entry22_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry22_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry22_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry22_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(22)        
  );
matchline_comb23  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry23_size_q,      
    entry_cmpmask                    => entry23_cmpmask_q(0  to 3),     
    entry_xbit                       => entry23_xbit_q,      
    entry_xbitmask                   => entry23_cmpmask_q(4  to 7),     
    entry_epn                        => entry23_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry23_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry23_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry23_hv_q,        
    entry_ds                         => entry23_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry23_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry23_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry23_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(23)        
  );
matchline_comb24  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry24_size_q,      
    entry_cmpmask                    => entry24_cmpmask_q(0  to 3),     
    entry_xbit                       => entry24_xbit_q,      
    entry_xbitmask                   => entry24_cmpmask_q(4  to 7),     
    entry_epn                        => entry24_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry24_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry24_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry24_hv_q,        
    entry_ds                         => entry24_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry24_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry24_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry24_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(24)        
  );
matchline_comb25  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry25_size_q,      
    entry_cmpmask                    => entry25_cmpmask_q(0  to 3),     
    entry_xbit                       => entry25_xbit_q,      
    entry_xbitmask                   => entry25_cmpmask_q(4  to 7),     
    entry_epn                        => entry25_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry25_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry25_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry25_hv_q,        
    entry_ds                         => entry25_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry25_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry25_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry25_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(25)        
  );
matchline_comb26  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry26_size_q,      
    entry_cmpmask                    => entry26_cmpmask_q(0  to 3),     
    entry_xbit                       => entry26_xbit_q,      
    entry_xbitmask                   => entry26_cmpmask_q(4  to 7),     
    entry_epn                        => entry26_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry26_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry26_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry26_hv_q,        
    entry_ds                         => entry26_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry26_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry26_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry26_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(26)        
  );
matchline_comb27  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry27_size_q,      
    entry_cmpmask                    => entry27_cmpmask_q(0  to 3),     
    entry_xbit                       => entry27_xbit_q,      
    entry_xbitmask                   => entry27_cmpmask_q(4  to 7),     
    entry_epn                        => entry27_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry27_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry27_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry27_hv_q,        
    entry_ds                         => entry27_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry27_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry27_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry27_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(27)        
  );
matchline_comb28  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry28_size_q,      
    entry_cmpmask                    => entry28_cmpmask_q(0  to 3),     
    entry_xbit                       => entry28_xbit_q,      
    entry_xbitmask                   => entry28_cmpmask_q(4  to 7),     
    entry_epn                        => entry28_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry28_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry28_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry28_hv_q,        
    entry_ds                         => entry28_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry28_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry28_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry28_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(28)        
  );
matchline_comb29  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry29_size_q,      
    entry_cmpmask                    => entry29_cmpmask_q(0  to 3),     
    entry_xbit                       => entry29_xbit_q,      
    entry_xbitmask                   => entry29_cmpmask_q(4  to 7),     
    entry_epn                        => entry29_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry29_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry29_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry29_hv_q,        
    entry_ds                         => entry29_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry29_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry29_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry29_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(29)        
  );
matchline_comb30  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry30_size_q,      
    entry_cmpmask                    => entry30_cmpmask_q(0  to 3),     
    entry_xbit                       => entry30_xbit_q,      
    entry_xbitmask                   => entry30_cmpmask_q(4  to 7),     
    entry_epn                        => entry30_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry30_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry30_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry30_hv_q,        
    entry_ds                         => entry30_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry30_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry30_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry30_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(30)        
  );
matchline_comb31  : tri_cam_32x143_1r1w1c_matchline
 generic map (have_xbit => 1,
             num_pgsizes => 5,
             have_cmpmask => 1,
             cmpmask_width => 4)
  port map (
    addr_in                          => comp_addr,           
    addr_enable                      => addr_enable,         
    comp_pgsize                      => comp_pgsize,         
    pgsize_enable                    => pgsize_enable,       
    entry_size                       => entry31_size_q,      
    entry_cmpmask                    => entry31_cmpmask_q(0  to 3),     
    entry_xbit                       => entry31_xbit_q,      
    entry_xbitmask                   => entry31_cmpmask_q(4  to 7),     
    entry_epn                        => entry31_epn_q,       
    comp_class                       => comp_class,          
    entry_class                      => entry31_class_q,     
    class_enable                     => class_enable,        
    comp_extclass                    => comp_extclass,       
    entry_extclass                   => entry31_extclass_q,  
    extclass_enable                  => extclass_enable,     
    comp_state                       => comp_state,          
    entry_hv                         => entry31_hv_q,        
    entry_ds                         => entry31_ds_q,        
    state_enable                     => state_enable,        
    entry_thdid                      => entry31_thdid_q,     
    comp_thdid                       => comp_thdid,          
    thdid_enable                     => thdid_enable,        
    entry_pid                        => entry31_pid_q,       
    comp_pid                         => comp_pid,            
    pid_enable                       => pid_enable,          
    entry_v                          => entry31_v_q,         
    comp_invalidate                  => comp_invalidate,     

    match                            => match_vec(31)        
  );
bram0_wea   <= wr_array_val(0) and gate_fq;
bram1_wea   <= wr_array_val(1) and gate_fq;
bram2_wea   <= wr_array_val(1) and gate_fq;
bram0_addra(9-num_entry_log2 to 8)    <= rw_entry(0 to num_entry_log2-1);
bram1_addra(11-num_entry_log2 to 10)  <= rw_entry(0 to num_entry_log2-1);
bram2_addra(10-num_entry_log2 to 9)   <= rw_entry(0 to num_entry_log2-1);
bram0_addrb(9-num_entry_log2 to 8)    <= cam_hit_entry_q;
bram1_addrb(11-num_entry_log2 to 10)  <= cam_hit_entry_q;
bram2_addrb(10-num_entry_log2 to 9)   <= cam_hit_entry_q;
bram0_addra(0 to 8-num_entry_log2) <= (others => '0');
bram0_addrb(0 to 8-num_entry_log2) <= (others => '0');
bram1_addra(0 to 10-num_entry_log2) <= (others => '0');
bram1_addrb(0 to 10-num_entry_log2) <= (others => '0');
bram2_addra(0 to 9-num_entry_log2) <= (others => '0');
bram2_addrb(0 to 9-num_entry_log2) <= (others => '0');
bram0 : ramb16_s36_s36

-- pragma translate_off
generic map(

sim_collision_check => "none")

-- pragma translate_on
port map(
                  clka  => clk2x,
	               clkb  => clk2x,
	               ssra  => sreset_q,
	               ssrb  => sreset_q,
	               addra => std_logic_vector(bram0_addra),
	               addrb => std_logic_vector(bram0_addrb),
	               dia   => std_logic_vector(wr_array_data_bram(0 to 31)),
	               dib   => (others => '0'),
                       doa   => rd_array_data_d_std(0 to 31),
                       dob   => array_cmp_data_bram_std(0 to 31),
                       dopa  => rd_array_data_d_std(66 to 69),
                       dopb  => array_cmp_data_bramp_std(66 to 69),
	               dipa  => std_logic_vector(wr_array_data_bram(66 to 69)),
	               dipb  => (others => '0'),
	               ena   => '1',
	               enb   => '1',
	               wea   => bram0_wea,
	               web   => '0'
	               );
bram1 : ramb16_s9_s9

-- pragma translate_off
generic map(

sim_collision_check => "none")

-- pragma translate_on
port map(
                  clka  => clk2x,
	               clkb  => clk2x,
	               ssra  => sreset_q,
	               ssrb  => sreset_q,
	               addra => std_logic_vector(bram1_addra),
	               addrb => std_logic_vector(bram1_addrb),
	               dia   => std_logic_vector(wr_array_data_bram(32 to 39)),
	               dib   => (others => '0'),
                       doa   => rd_array_data_d_std(32 to 39),
                       dob   => array_cmp_data_bram_std(32 to 39),
                       dopa  => rd_array_data_d_std(70 to 70),
                       dopb  => array_cmp_data_bramp_std(70 to 70),
	               dipa  => std_logic_vector(wr_array_data_bram(70 to 70)),
	               dipb  => (others => '0'),
	               ena   => '1',
	               enb   => '1',
	               wea   => bram1_wea,
	               web   => '0'
	               );
bram2 : ramb16_s18_s18

-- pragma translate_off
generic map(

sim_collision_check => "none")

-- pragma translate_on
port map(
                  clka  => clk2x,
	               clkb  => clk2x,
	               ssra  => sreset_q,
	               ssrb  => sreset_q,
	               addra => std_logic_vector(bram2_addra),
	               addrb => std_logic_vector(bram2_addrb),
	               dia   => std_logic_vector(wr_array_data_bram(40 to 55)),
	               dib   => (others => '0'),
                       doa   => rd_array_data_d_std(40 to 55),
                       dob   => array_cmp_data_bram_std(40 to 55),
                       dopa  => rd_array_data_d_std(71 to 72),
                       dopb  => array_cmp_data_bramp_std(71 to 72),
	               dipa  => std_logic_vector(wr_array_data_bram(71 to 72)),
	               dipb  => (others => '0'),
	               ena   => '1',
	               enb   => '1',
	               wea   => bram2_wea,
	               web   => '0'
	               );
wr_array_data_bram(0 to 72) <= "00" & wr_array_data(0 to 29) & 
                                 "00" & wr_array_data(30 to 35) & 
                                 '0' & wr_array_data(36 to 50) &
                                 wr_array_data(51 to 60) & wr_array_data(61 to 67);
rd_array_data_d_std(56 to 65)  <= (others => '0');
rd_array_data_d(0 to 29)        <= std_ulogic_vector(rd_array_data_d_std(2 to 31));
rd_array_data_d(30 to 35)       <= std_ulogic_vector(rd_array_data_d_std(34 to 39));
rd_array_data_d(36 to 50)       <= std_ulogic_vector(rd_array_data_d_std(41 to 55));
rd_array_data_d(61 to 67)      <= std_ulogic_vector(rd_array_data_d_std(66 to 72));
array_cmp_data_bram             <= std_ulogic_vector(array_cmp_data_bram_std);
array_cmp_data_bramp            <= std_ulogic_vector(array_cmp_data_bramp_std);
rd_array_data <= rd_array_data_q;
cam_cmp_data <= cam_cmp_data_q;
rd_cam_data <= rd_cam_data_q;
entry_valid(0)      <= entry0_v_q;
entry_valid(1)      <= entry1_v_q;
entry_valid(2)      <= entry2_v_q;
entry_valid(3)      <= entry3_v_q;
entry_valid(4)      <= entry4_v_q;
entry_valid(5)      <= entry5_v_q;
entry_valid(6)      <= entry6_v_q;
entry_valid(7)      <= entry7_v_q;
entry_valid(8)      <= entry8_v_q;
entry_valid(9)      <= entry9_v_q;
entry_valid(10)     <= entry10_v_q;
entry_valid(11)     <= entry11_v_q;
entry_valid(12)     <= entry12_v_q;
entry_valid(13)     <= entry13_v_q;
entry_valid(14)     <= entry14_v_q;
entry_valid(15)     <= entry15_v_q;
entry_valid(16)     <= entry16_v_q;
entry_valid(17)     <= entry17_v_q;
entry_valid(18)     <= entry18_v_q;
entry_valid(19)     <= entry19_v_q;
entry_valid(20)     <= entry20_v_q;
entry_valid(21)     <= entry21_v_q;
entry_valid(22)     <= entry22_v_q;
entry_valid(23)     <= entry23_v_q;
entry_valid(24)     <= entry24_v_q;
entry_valid(25)     <= entry25_v_q;
entry_valid(26)     <= entry26_v_q;
entry_valid(27)     <= entry27_v_q;
entry_valid(28)     <= entry28_v_q;
entry_valid(29)     <= entry29_v_q;
entry_valid(30)     <= entry30_v_q;
entry_valid(31)     <= entry31_v_q;
entry_match <= entry_match_q;
cam_hit_entry <= cam_hit_entry_q;
cam_hit <= cam_hit_q;
func_scan_out <= func_scan_in;
regfile_scan_out <= regfile_scan_in;
time_scan_out <= time_scan_in;
end generate;
end tri_cam_32x143_1r1w1c;

