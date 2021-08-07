-- © IBM Corp. 2020
-- Licensed under the Apache License, Version 2.0 (the "License"), as modified by
-- the terms below; you may not use the files in this repository except in
-- compliance with the License as modified.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
--
-- Modified Terms:
--
--    1) For the purpose of the patent license granted to you in Section 3 of the
--    License, the "Work" hereby includes implementations of the work of authorship
--    in physical form.
--
--    2) Notwithstanding any terms to the contrary in the License, any licenses
--    necessary for implementation of the Work that are available from OpenPOWER
--    via the Power ISA End User License Agreement (EULA) are explicitly excluded
--    hereunder, and may be obtained from OpenPOWER under the terms and conditions
--    of the EULA.  
--
-- Unless required by applicable law or agreed to in writing, the reference design
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
-- for the specific language governing permissions and limitations under the License.
-- 
-- Additional rights, including the ability to physically implement a softcore that
-- is compliant with the required sections of the Power ISA Specification, are
-- available at no cost under the terms of the OpenPOWER Power ISA EULA, which can be
-- obtained (along with the Power ISA) here: https://openpowerfoundation.org. 

			
--********************************************************************
--* TITLE: I-ERAT CAM Tri-Library Model
--* NAME: tri_cam_16x143_1r1w1c

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
entity tri_cam_16x143_1r1w1c  is

  generic (cam_data_width : natural := 84;
           array_data_width : natural := 68;
           rpn_width : natural := 30;
           num_entry : natural := 16;
           num_entry_log2 : natural := 4;
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
   regfile_scan_in    	          : in  std_ulogic_vector(0 TO 4);   
   regfile_scan_out    	          : out std_ulogic_vector(0 TO 4); 
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
end entity tri_cam_16x143_1r1w1c;
architecture tri_cam_16x143_1r1w1c of tri_cam_16x143_1r1w1c is
component tri_cam_16x143_1r1w1c_matchline
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
-- Latches
signal sreset_q                           : std_ulogic;
signal gate_fq,         gate_d            : std_ulogic;
signal comp_addr_np1_d, comp_addr_np1_q  : std_ulogic_vector(52-rpn_width to 51);
signal rpn_np2_d,rpn_np2_q               : std_ulogic_vector(52-rpn_width to 51);
signal attr_np2_d,attr_np2_q             : std_ulogic_vector(0 to 20);
-- CAM entry signals
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
signal     cam_cmp_data_muxsel  : std_ulogic_vector(0 to 4);
signal     rd_cam_data_muxsel  : std_ulogic_vector(0 to 4);
signal     cam_cmp_data_np1      : std_ulogic_vector(0 to cam_data_width-1);
signal     array_cmp_data_np1    : std_ulogic_vector(0 to array_data_width-1);
signal wr_array_data_bram  : std_ulogic_vector(0 to 72);
signal rd_array_data_d_std      : std_logic_vector(0 to 72);
signal array_cmp_data_bram_std  : std_logic_vector(0 to 55);
signal array_cmp_data_bramp_std : std_logic_vector(66 to 72);
-- latch signals
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
end if;
end if;
end process;
-----------------------------------------------------------------------
-- latch input logic
-----------------------------------------------------------------------
comp_addr_np1_d <= comp_addr(52-rpn_width to 51);
cam_hit_d <= '1' when (match_vec /= "0000000000000000" and comp_request='1') else '0';
cam_hit_entry_d <= "0001" when match_vec(0 to 1)="01" else
                    "0010" when match_vec(0 to  2)="001" else
                    "0011" when match_vec(0 to  3)="0001" else
                    "0100" when match_vec(0 to  4)="00001" else
                    "0101" when match_vec(0 to  5)="000001" else
                    "0110" when match_vec(0 to  6)="0000001" else
                    "0111" when match_vec(0 to  7)="00000001" else
                    "1000" when match_vec(0 to  8)="000000001" else
                    "1001" when match_vec(0 to  9)="0000000001" else
                    "1010" when match_vec(0 to 10)="00000000001" else
                    "1011" when match_vec(0 to 11)="000000000001" else
                    "1100" when match_vec(0 to 12)="0000000000001" else
                    "1101" when match_vec(0 to 13)="00000000000001" else
                    "1110" when match_vec(0 to 14)="000000000000001" else
                    "1111" when match_vec(0 to 15)="0000000000000001" else
                    "0000";
entry_match_d <= match_vec when (comp_request='1') else (others => '0');
wr_entry0_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="0000"))   else '0';
wr_entry0_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="0000"))   else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry1_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="0001"))   else '0';
wr_entry1_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="0001"))   else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry2_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="0010"))   else '0';
wr_entry2_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="0010"))   else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry3_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="0011"))   else '0';
wr_entry3_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="0011"))   else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry4_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="0100"))   else '0';
wr_entry4_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="0100"))   else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry5_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="0101"))   else '0';
wr_entry5_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="0101"))   else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry6_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="0110"))   else '0';
wr_entry6_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="0110"))   else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry7_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="0111"))   else '0';
wr_entry7_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="0111"))   else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry8_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="1000"))   else '0';
wr_entry8_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="1000"))   else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry9_sel(0)   <= '1' when ((wr_cam_val(0)='1') and (rw_entry="1001"))   else '0';
wr_entry9_sel(1)   <= '1' when ((wr_cam_val(1)='1') and (rw_entry="1001"))   else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry10_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="1010"))  else '0';
wr_entry10_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="1010"))  else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry11_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="1011"))  else '0';
wr_entry11_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="1011"))  else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry12_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="1100"))  else '0';
wr_entry12_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="1100"))  else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry13_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="1101"))  else '0';
wr_entry13_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="1101"))  else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry14_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="1110"))  else '0';
wr_entry14_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="1110"))  else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
wr_entry15_sel(0)  <= '1' when ((wr_cam_val(0)='1') and (rw_entry="1111"))  else '0';
wr_entry15_sel(1)  <= '1' when ((wr_cam_val(1)='1') and (rw_entry="1111"))  else '0';
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
-- the cam parity bits.. some wr_array_data bits contain parity for cam
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
-- entry valid and thdid next state logic
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
-- CAM compare data out mux
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
cam_cmp_data_muxsel <= not(comp_request) & cam_hit_entry_d;
with cam_cmp_data_muxsel select
  cam_cmp_data_d <= entry0_cam_vec when "00000",
                     entry1_cam_vec   when "00001",
                     entry2_cam_vec   when "00010",
                     entry3_cam_vec   when "00011",
                     entry4_cam_vec   when "00100",
                     entry5_cam_vec   when "00101",
                     entry6_cam_vec   when "00110",
                     entry7_cam_vec   when "00111",
                     entry8_cam_vec   when "01000",
                     entry9_cam_vec   when "01001",
                     entry10_cam_vec  when "01010",
                     entry11_cam_vec  when "01011",
                     entry12_cam_vec  when "01100",
                     entry13_cam_vec  when "01101",
                     entry14_cam_vec  when "01110",
                     entry15_cam_vec  when "01111",
                     cam_cmp_data_q  when others;
cam_cmp_data_np1 <= cam_cmp_data_q;
-- CAM read data out mux
rd_cam_data_muxsel <= not(rd_val) & rw_entry;
with rd_cam_data_muxsel select
   rd_cam_data_d <= entry0_cam_vec when "00000",
                     entry1_cam_vec   when "00001",
                     entry2_cam_vec   when "00010",
                     entry3_cam_vec   when "00011",
                     entry4_cam_vec   when "00100",
                     entry5_cam_vec   when "00101",
                     entry6_cam_vec   when "00110",
                     entry7_cam_vec   when "00111",
                     entry8_cam_vec   when "01000",
                     entry9_cam_vec   when "01001",
                     entry10_cam_vec  when "01010",
                     entry11_cam_vec  when "01011",
                     entry12_cam_vec  when "01100",
                     entry13_cam_vec  when "01101",
                     entry14_cam_vec  when "01110",
                     entry15_cam_vec  when "01111",
                     rd_cam_data_q  when others;
-- CAM compare parity out mux
with cam_cmp_data_muxsel select
  cam_cmp_parity_d <= entry0_parity_q when "00000",
                     entry1_parity_q   when "00001",
                     entry2_parity_q   when "00010",
                     entry3_parity_q   when "00011",
                     entry4_parity_q   when "00100",
                     entry5_parity_q   when "00101",
                     entry6_parity_q   when "00110",
                     entry7_parity_q   when "00111",
                     entry8_parity_q   when "01000",
                     entry9_parity_q   when "01001",
                     entry10_parity_q  when "01010",
                     entry11_parity_q  when "01011",
                     entry12_parity_q  when "01100",
                     entry13_parity_q  when "01101",
                     entry14_parity_q  when "01110",
                     entry15_parity_q  when "01111",
                     cam_cmp_parity_q  when others;
array_cmp_data_np1(0 to 50) <= array_cmp_data_bram(2 to 31) & array_cmp_data_bram(34 to 39) & array_cmp_data_bram(41 to 55);
array_cmp_data_np1(51 to 60) <= cam_cmp_parity_q;
array_cmp_data_np1(61 to 67) <= array_cmp_data_bramp(66 to 72);
array_cmp_data <= array_cmp_data_np1;
with rd_cam_data_muxsel select
   rd_array_data_d(51 to 60) <= entry0_parity_q when "00000",
                     entry1_parity_q   when "00001",
                     entry2_parity_q   when "00010",
                     entry3_parity_q   when "00011",
                     entry4_parity_q   when "00100",
                     entry5_parity_q   when "00101",
                     entry6_parity_q   when "00110",
                     entry7_parity_q   when "00111",
                     entry8_parity_q   when "01000",
                     entry9_parity_q   when "01001",
                     entry10_parity_q  when "01010",
                     entry11_parity_q  when "01011",
                     entry12_parity_q  when "01100",
                     entry13_parity_q  when "01101",
                     entry14_parity_q  when "01110",
                     entry15_parity_q  when "01111",
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
-----------------------------------------------------------------------
-- matchline component instantiations
-----------------------------------------------------------------------
matchline_comb0   : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb1   : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb2   : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb3   : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb4   : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb5   : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb6   : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb7   : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb8   : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb9   : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb10  : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb11  : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb12  : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb13  : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb14  : tri_cam_16x143_1r1w1c_matchline
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
matchline_comb15  : tri_cam_16x143_1r1w1c_matchline
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
-----------------------------------------------------------------------
-- BRAM signal assignments
-----------------------------------------------------------------------
bram0_wea   <= wr_array_val(0) and gate_fq;
bram1_wea   <= wr_array_val(1) and gate_fq;
bram2_wea   <= wr_array_val(1) and gate_fq;
bram0_addra(9-num_entry_log2 to 8)    <= rw_entry(0 to num_entry_log2-1);
bram1_addra(11-num_entry_log2 to 10)  <= rw_entry(0 to num_entry_log2-1);
bram2_addra(10-num_entry_log2 to 9)   <= rw_entry(0 to num_entry_log2-1);
bram0_addrb(9-num_entry_log2 to 8)    <= cam_hit_entry_q;
bram1_addrb(11-num_entry_log2 to 10)  <= cam_hit_entry_q;
bram2_addrb(10-num_entry_log2 to 9)   <= cam_hit_entry_q;
-- Unused Address Bits
bram0_addra(0 to 8-num_entry_log2) <= (others => '0');
bram0_addrb(0 to 8-num_entry_log2) <= (others => '0');
bram1_addra(0 to 10-num_entry_log2) <= (others => '0');
bram1_addrb(0 to 10-num_entry_log2) <= (others => '0');
bram2_addra(0 to 9-num_entry_log2) <= (others => '0');
bram2_addrb(0 to 9-num_entry_log2) <= (others => '0');
-- This ram houses the RPN(20:51) bits, wr_array_data_bram(0:31)
--   uses wr_array_val(0), parity is wr_array_data_bram(66:69)
bram0 : ramb16_s36_s36

-- pragma translate_off
generic map(

-- all, none, warning_only, generate_x_only
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
-- This ram houses the RPN(18:19),R,C,4xResv bits, wr_array_data_bram(32:39)
--   uses wr_array_val(1), parity is wr_array_data_bram(70)
bram1 : ramb16_s9_s9

-- pragma translate_off
generic map(

-- all, none, warning_only, generate_x_only
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
-- This ram houses the 1xResv,U0-U3,WIMGE,UX,UW,UR,SX,SW,SR bits, wr_array_data_bram(40:55)
--   uses wr_array_val(1), parity is wr_array_data_bram(71:72)
bram2 : ramb16_s18_s18

-- pragma translate_off
generic map(

-- all, none, warning_only, generate_x_only
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
-- array write data swizzle -> convert 68-bit data to 73-bit bram data
-- 32x143 version, 42b RA
-- wr_array_data
--  0:29  - RPN
--  30:31  - R,C
--  32:35  - ResvAttr
--  36:39  - U0-U3
--  40:44  - WIMGE
--  45:47  - UX,UW,UR
--  48:50  - SX,SW,SR
--  51:60  - CAM parity
--  61:67  - Array parity
-- RTX layout in A2_AvpEratHelper.C
--  ram0(0:31):  00  & RPN(0:29)
--  ram1(0:7) :  00  & R,C,ResvAttr(0:3)
--  ram2(0:15): '0' & U(0:3),WIMGE,UX,UW,UR,SX,SW,SR
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
-----------------------------------------------------------------------
-- entity output assignments
-----------------------------------------------------------------------
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
entry_match <= entry_match_q;
cam_hit_entry <= cam_hit_entry_q;
cam_hit <= cam_hit_q;
func_scan_out <= func_scan_in;
regfile_scan_out <= regfile_scan_in;
time_scan_out <= time_scan_in;
end generate;
end tri_cam_16x143_1r1w1c;
