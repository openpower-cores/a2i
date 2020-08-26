-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

			
--********************************************************************
--* TITLE: Data Side Effective to Real Address Translation
--* NAME: xuq_lsu_derat.vhdl
--*********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ibm;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity xuq_lsu_derat is
  generic(thdid_width       : integer := 4;
            ttype_width        : integer := 12;
            state_width        : integer := 4;
            lpid_width         : integer := 8;
            pid_width          : integer := 14;
            pid_width_erat     : integer := 8;
            extclass_width     : integer := 2;
            tlbsel_width       : integer := 2;
            epn_width          : integer := 52;
            vpn_width          : integer := 61;
            rpn_width          : integer := 30;  
            ws_width           : integer := 2;
            rs_is_width        : integer := 9;
            ra_entry_width     : integer := 5;
            rs_data_width      : integer := 64;  
            data_out_width     : integer := 64;  
            error_width        : integer := 3;
            cam_data_width     : natural := 84;    
            array_data_width   : natural := 68; 
            num_entry          : natural := 32; 
            num_entry_log2     : natural := 5; 
            por_seq_width      : integer := 3;
            watermark_width    : integer := 5;
            eptr_width         : integer := 5;
            lru_width          : integer := 31;
            bcfg_width         : integer := 123;
            ex2_epn_width      : integer := 30; 
            bcfg_epn_0to15     : integer := 0;
            bcfg_epn_16to31    : integer := 0;
            bcfg_epn_32to47    : integer := (2**16)-1;  
            bcfg_epn_48to51    : integer := (2**4)-1; 
            bcfg_rpn_22to31    : integer := (2**10)-1;
            bcfg_rpn_32to47    : integer := (2**16)-1;  
            bcfg_rpn_48to51    : integer := (2**4)-1; 
            bcfg_rpn2_32to47   : integer := 0;  
            bcfg_rpn2_48to51   : integer := 0;  
            bcfg_attr          : integer := 0;  
            check_parity       : integer := 1;  
            expand_type        : integer := 2 );
port(
     gnd                : inout power_logic;
     vdd                : inout power_logic;
     vcs                : inout power_logic;
     nclk                       : in clk_logic;
     pc_xu_init_reset           : in std_ulogic;

pc_xu_ccflush_dc             : in std_ulogic;
tc_scan_dis_dc_b          : in std_ulogic;
tc_scan_diag_dc           : in std_ulogic;
tc_lbist_en_dc            : in std_ulogic;
an_ac_atpg_en_dc          : in std_ulogic;
an_ac_grffence_en_dc      : in std_ulogic;
lcb_d_mode_dc              : in std_ulogic;
lcb_clkoff_dc_b            : in std_ulogic;
lcb_act_dis_dc             : in std_ulogic;
lcb_mpw1_dc_b              : in std_ulogic_vector(0 to 4);
lcb_mpw2_dc_b              : in std_ulogic;
lcb_delay_lclkr_dc         : in std_ulogic_vector(0 to 4);
pc_func_sl_thold_2         : in std_ulogic;
pc_func_slp_sl_thold_2     : in std_ulogic;
pc_func_slp_nsl_thold_2    : in std_ulogic;
pc_cfg_slp_sl_thold_2      : in std_ulogic;
pc_regf_slp_sl_thold_2     : in std_ulogic;
pc_time_sl_thold_2         : in std_ulogic;
pc_sg_2                    : in std_ulogic;
pc_fce_2                   : in std_ulogic;
cam_clkoff_dc_b            : in std_ulogic;
cam_act_dis_dc             : in std_ulogic;
cam_d_mode_dc              : in std_ulogic;
cam_delay_lclkr_dc         : in std_ulogic_vector(0 to 4);
cam_mpw1_dc_b              : in std_ulogic_vector(0 to 4);
cam_mpw2_dc_b              : in std_ulogic;
ac_func_scan_in          : in   std_ulogic_vector(0 to 1);
ac_func_scan_out         : out  std_ulogic_vector(0 to 1);
ac_ccfg_scan_in          : in   std_ulogic;
ac_ccfg_scan_out         : out  std_ulogic;
time_scan_in             : in   std_ulogic;
time_scan_out            : out  std_ulogic;
regf_scan_in             : in   std_ulogic_vector(0 to 6);
regf_scan_out            : out  std_ulogic_vector(0 to 6);
spr_xucr0_clkg_ctl_b1      : in std_ulogic;
spr_xucr4_mmu_mchk         : in std_ulogic;
xu_derat_rf0_val           : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_rf0_is_extload    : in std_ulogic;
xu_derat_rf0_is_extstore   : in std_ulogic;
xu_derat_rf1_is_load       : in std_ulogic;
xu_derat_rf1_is_store      : in std_ulogic;
xu_derat_rf1_is_eratre     : in std_ulogic;
xu_derat_rf1_is_eratwe     : in std_ulogic;
xu_derat_rf1_is_eratsx     : in std_ulogic;
xu_derat_rf1_is_eratilx    : in std_ulogic;
xu_derat_ex1_is_isync      : in std_ulogic;
xu_derat_ex1_is_csync      : in std_ulogic;
xu_derat_rf1_is_touch      : in std_ulogic;
xu_derat_rf1_icbtls_instr  : in std_ulogic;
xu_derat_rf1_icblc_instr   : in std_ulogic;
xu_derat_rf1_act           : in std_ulogic;
xu_derat_rf1_ra_eq_ea      : in std_ulogic;
xu_derat_rf1_ws            : in std_ulogic_vector(0 to ws_width-1);
xu_derat_rf1_t             : in std_ulogic_vector(0 to 2);
xu_derat_rf1_binv_val      : in std_ulogic;
xu_derat_ex1_rs_is         : in std_ulogic_vector(0 to rs_is_width-1);
xu_derat_ex1_ra_entry      : in std_ulogic_vector(0 to ra_entry_width-1);
xu_derat_ex1_epn_arr       : in std_ulogic_vector(64-rs_data_width to 51);
xu_derat_ex1_epn_nonarr    : in std_ulogic_vector(64-rs_data_width to 51);
snoop_addr                 : out std_ulogic_vector(64-rs_data_width to 51);
snoop_addr_sel             : out std_ulogic;
xu_derat_rf0_n_flush       : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_rf1_n_flush       : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_ex1_n_flush       : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_ex2_n_flush       : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_ex3_n_flush       : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_ex4_n_flush       : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_ex5_n_flush       : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_ex4_rs_data       : in std_ulogic_vector(64-rs_data_width to 63);
xu_derat_msr_hv            : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_msr_pr            : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_msr_ds            : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_msr_cm            : in std_ulogic_vector(0 to thdid_width-1);
xu_derat_hid_mmu_mode      : in std_ulogic;
xu_derat_spr_ccr2_dfrat       : in std_ulogic;
xu_derat_spr_ccr2_dfratsc     : in std_ulogic_vector(0 to 8);
derat_xu_ex2_miss          : out std_ulogic_vector(0 to thdid_width-1);
derat_xu_ex2_rpn           : out std_ulogic_vector(22 to 51);
derat_xu_ex2_wimge         : out std_ulogic_vector(0 to 4);
derat_xu_ex2_u             : out std_ulogic_vector(0 to 3);
derat_xu_ex2_wlc           : out std_ulogic_vector(0 to 1);
derat_xu_ex2_attr          : out std_ulogic_vector(0 to 5);
derat_xu_ex2_vf            : out std_ulogic;
derat_xu_ex3_rpn           : out std_ulogic_vector(22 to 51);
derat_xu_ex3_wimge         : out std_ulogic_vector(0 to 4);
derat_xu_ex3_u             : out std_ulogic_vector(0 to 3);
derat_xu_ex3_wlc           : out std_ulogic_vector(0 to 1);
derat_xu_ex3_attr          : out std_ulogic_vector(0 to 5);
derat_xu_ex3_vf            : out std_ulogic;
derat_xu_ex3_miss          : out std_ulogic_vector(0 to thdid_width-1);
derat_xu_ex3_dsi           : out std_ulogic_vector(0 to thdid_width-1);
derat_xu_ex3_par_err       : out std_ulogic_vector(0 to thdid_width-1);
derat_xu_ex3_multihit_err  : out std_ulogic_vector(0 to thdid_width-1);
derat_xu_ex3_noop_touch    : out std_ulogic_vector(0 to thdid_width-1);
derat_xu_ex3_n_flush_req   : out std_ulogic_vector(0 to thdid_width-1);
derat_xu_ex4_data          : out std_ulogic_vector(64-data_out_width to 63);
derat_xu_ex4_par_err       : out std_ulogic_vector(0 to thdid_width-1);
derat_iu_barrier_done      : out std_ulogic_vector(0 to thdid_width-1);
derat_fir_par_err          : out std_ulogic_vector(0 to thdid_width-1);
derat_fir_multihit         : out std_ulogic_vector(0 to thdid_width-1);
xu_derat_epsc_wr           : in std_ulogic_vector(0 to 3);
xu_derat_eplc_wr           : in std_ulogic_vector(0 to 3);
xu_derat_eplc0_epr         : in std_ulogic;
xu_derat_eplc0_eas         : in std_ulogic;
xu_derat_eplc0_egs         : in std_ulogic;
xu_derat_eplc0_elpid       : in std_ulogic_vector(40 to 47);
xu_derat_eplc0_epid        : in std_ulogic_vector(50 to 63);
xu_derat_eplc1_epr         : in std_ulogic;
xu_derat_eplc1_eas         : in std_ulogic;
xu_derat_eplc1_egs         : in std_ulogic;
xu_derat_eplc1_elpid       : in std_ulogic_vector(40 to 47);
xu_derat_eplc1_epid        : in std_ulogic_vector(50 to 63);
xu_derat_eplc2_epr         : in std_ulogic;
xu_derat_eplc2_eas         : in std_ulogic;
xu_derat_eplc2_egs         : in std_ulogic;
xu_derat_eplc2_elpid       : in std_ulogic_vector(40 to 47);
xu_derat_eplc2_epid        : in std_ulogic_vector(50 to 63);
xu_derat_eplc3_epr         : in std_ulogic;
xu_derat_eplc3_eas         : in std_ulogic;
xu_derat_eplc3_egs         : in std_ulogic;
xu_derat_eplc3_elpid       : in std_ulogic_vector(40 to 47);
xu_derat_eplc3_epid        : in std_ulogic_vector(50 to 63);
xu_derat_epsc0_epr         : in std_ulogic;
xu_derat_epsc0_eas         : in std_ulogic;
xu_derat_epsc0_egs         : in std_ulogic;
xu_derat_epsc0_elpid       : in std_ulogic_vector(40 to 47);
xu_derat_epsc0_epid        : in std_ulogic_vector(50 to 63);
xu_derat_epsc1_epr         : in std_ulogic;
xu_derat_epsc1_eas         : in std_ulogic;
xu_derat_epsc1_egs         : in std_ulogic;
xu_derat_epsc1_elpid       : in std_ulogic_vector(40 to 47);
xu_derat_epsc1_epid        : in std_ulogic_vector(50 to 63);
xu_derat_epsc2_epr         : in std_ulogic;
xu_derat_epsc2_eas         : in std_ulogic;
xu_derat_epsc2_egs         : in std_ulogic;
xu_derat_epsc2_elpid       : in std_ulogic_vector(40 to 47);
xu_derat_epsc2_epid        : in std_ulogic_vector(50 to 63);
xu_derat_epsc3_epr         : in std_ulogic;
xu_derat_epsc3_eas         : in std_ulogic;
xu_derat_epsc3_egs         : in std_ulogic;
xu_derat_epsc3_elpid       : in std_ulogic_vector(40 to 47);
xu_derat_epsc3_epid        : in std_ulogic_vector(50 to 63);
xu_mm_derat_req            : out std_ulogic;
xu_mm_derat_thdid          : out std_ulogic_vector(0 to thdid_width-1);
xu_mm_derat_ttype          : out std_ulogic_vector(0 to 1);
xu_mm_derat_state          : out std_ulogic_vector(0 to state_width-1);
xu_mm_derat_lpid           : out std_ulogic_vector(0 to lpid_width-1);
xu_mm_derat_tid            : out std_ulogic_vector(0 to pid_width-1);
mm_xu_derat_rel_val        : in std_ulogic_vector(0 to 4);
mm_xu_derat_rel_data       : in std_ulogic_vector(0 to 131);
mm_xu_derat_pid0           : in std_ulogic_vector(0 to pid_width-1);
mm_xu_derat_pid1           : in std_ulogic_vector(0 to pid_width-1);
mm_xu_derat_pid2           : in std_ulogic_vector(0 to pid_width-1);
mm_xu_derat_pid3           : in std_ulogic_vector(0 to pid_width-1);
mm_xu_derat_mmucr0_0         : in std_ulogic_vector(0 to 19);
mm_xu_derat_mmucr0_1         : in std_ulogic_vector(0 to 19);
mm_xu_derat_mmucr0_2         : in std_ulogic_vector(0 to 19);
mm_xu_derat_mmucr0_3         : in std_ulogic_vector(0 to 19);
xu_mm_derat_mmucr0          : out std_ulogic_vector(0 to 17);
xu_mm_derat_mmucr0_we       : out std_ulogic_vector(0 to 3);
mm_xu_derat_mmucr1          : in std_ulogic_vector(0 to 9);
xu_mm_derat_mmucr1          : out std_ulogic_vector(0 to 4);
xu_mm_derat_mmucr1_we       : out std_ulogic;
mm_xu_derat_snoop_coming   : in std_ulogic;
mm_xu_derat_snoop_val      : in std_ulogic;
mm_xu_derat_snoop_attr     : in std_ulogic_vector(0 to 25);
mm_xu_derat_snoop_vpn      : in std_ulogic_vector(52-epn_width to 51);
xu_mm_derat_snoop_ack      : out std_ulogic;
pc_xu_trace_bus_enable     : in  std_ulogic;
derat_xu_debug_group0      : out std_ulogic_vector(0 to 87);
derat_xu_debug_group1      : out std_ulogic_vector(0 to 87);
derat_xu_debug_group2      : out std_ulogic_vector(0 to 87);
derat_xu_debug_group3      : out std_ulogic_vector(0 to 87)
);
end xuq_lsu_derat;
ARCHITECTURE XUQ_LSU_DERAT
          OF XUQ_LSU_DERAT
          IS
--@@  Signal Declarations
SIGNAL CAM_MASK_BITS_PT                  : STD_ULOGIC_VECTOR(1 TO 19)  := 
(OTHERS=> 'U');
SIGNAL EX2_FIRST_HIT_ENTRY_PT            : STD_ULOGIC_VECTOR(1 TO 31)  := 
(OTHERS=> 'U');
SIGNAL EX2_MULTIHIT_B_PT                 : STD_ULOGIC_VECTOR(1 TO 32)  := 
(OTHERS=> 'U');
SIGNAL LRU_RMT_VEC_D_PT                  : STD_ULOGIC_VECTOR(1 TO 32)  := 
(OTHERS=> 'U');
SIGNAL LRU_SET_RESET_VEC_PT              : STD_ULOGIC_VECTOR(1 TO 161)  := 
(OTHERS=> 'U');
SIGNAL LRU_WAY_ENCODE_PT                 : STD_ULOGIC_VECTOR(1 TO 31)  := 
(OTHERS=> 'U');
----------------------------
-- components
----------------------------
-- Data ERAT CAM/Array, 32-entry
component tri_cam_32x143_1r1w1c
  generic (expand_type : integer := 2);  
  port (
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

   func_scan_in                   :  in   std_ulogic;
   func_scan_out                  :  out  std_ulogic;
   regfile_scan_in                :  in   std_ulogic_vector(0 to 6);  
   regfile_scan_out               :  out  std_ulogic_vector(0 to 6);
   time_scan_in                   :  in   std_ulogic;
   time_scan_out                  :  out  std_ulogic;

   rd_val                         :  in   std_ulogic;
   rd_val_late                    :  in   std_ulogic;
   rw_entry                       :  in   std_ulogic_vector(0 to 4);

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
   cam_hit_entry                  :  out  std_ulogic_vector(0 to 4);
   entry_match                    :  out  std_ulogic_vector(0 to 31);
   entry_valid                    :  out  std_ulogic_vector(0 to 31);
   rd_cam_data                    :  out  std_ulogic_vector(0 to cam_data_width-1);

----- new ports for IO plus -----------------------
  bypass_mux_enab_np1   :  in  std_ulogic;		   
  bypass_attr_np1       :  in  std_ulogic_vector(0 to 20); 
  attr_np2	        :  out std_ulogic_vector(0 to 20);
  rpn_np2	        :  out std_ulogic_vector(22 to 51)

  );
END component;
component tri_cam_parerr_mac
  generic (expand_type : integer := 2);  
  port (
   gnd                          :inout power_logic;
   vdd                          :inout power_logic;
   nclk                         :in  std_ulogic;
   lcb_act_dis_dc               :in  std_ulogic;
   lcb_delay_lclkr_dc           :in  std_ulogic;
   lcb_clkoff_dc_b_0            :in  std_ulogic;
   lcb_mpw1_dc_b                :in  std_ulogic;
   lcb_mpw2_dc_b                :in  std_ulogic;
   act                          :in  std_ulogic;
   lcb_sg_0                     :in  std_ulogic;
   lcb_func_sl_thold_0          :in  std_ulogic; 

   func_scan_in                 :in  std_ulogic;
   func_scan_out                :out std_ulogic;

   np1_cam_cmp_data             :in  std_ulogic_vector(0 to 83);
   np1_array_cmp_data           :in  std_ulogic_vector(0 to 67);

   np2_cam_cmp_data             :out std_ulogic_vector(0 to 83);
   np2_array_cmp_data           :out std_ulogic_vector(0 to 67);
   np2_cmp_data_parerr_epn      :out std_ulogic; 
   np2_cmp_data_parerr_rpn      :out std_ulogic 
  );
END component;
----------------------------
-- constants
----------------------------
constant MMU_Mode_Value : std_ulogic := '0';
constant TlbSel_Tlb : std_ulogic_vector(0 to 1) := "00";
constant TlbSel_IErat : std_ulogic_vector(0 to 1) := "10";
constant TlbSel_DErat : std_ulogic_vector(0 to 1) := "11";
constant CAM_PgSize_1GB  : std_ulogic_vector(0 to 2) := "110";
constant CAM_PgSize_16MB : std_ulogic_vector(0 to 2) := "111";
constant CAM_PgSize_1MB  : std_ulogic_vector(0 to 2) := "101";
constant CAM_PgSize_64KB : std_ulogic_vector(0 to 2) := "011";
constant CAM_PgSize_4KB  : std_ulogic_vector(0 to 2) := "001";
constant WS0_PgSize_1GB  : std_ulogic_vector(0 to 3) := "1010";
constant WS0_PgSize_16MB : std_ulogic_vector(0 to 3) := "0111";
constant WS0_PgSize_1MB  : std_ulogic_vector(0 to 3) := "0101";
constant WS0_PgSize_64KB : std_ulogic_vector(0 to 3) := "0011";
constant WS0_PgSize_4KB  : std_ulogic_vector(0 to 3) := "0001";
constant eratpos_epn      : natural  := 0;
constant eratpos_x        : natural  := 52;
constant eratpos_size     : natural  := 53;
constant eratpos_v        : natural  := 56;
constant eratpos_thdid    : natural  := 57;
constant eratpos_class    : natural  := 61;
constant eratpos_extclass : natural  := 63;
constant eratpos_wren     : natural  := 65;
constant eratpos_rpnrsvd  : natural  := 66;
constant eratpos_rpn      : natural  := 70;
constant eratpos_r        : natural  := 100;
constant eratpos_c        : natural  := 101;
constant eratpos_relsoon  : natural  := 102;
constant eratpos_wlc      : natural  := 103;
constant eratpos_resvattr : natural  := 105;
constant eratpos_vf       : natural  := 106;
constant eratpos_ubits    : natural  := 107;
constant eratpos_wimge    : natural  := 111;
constant eratpos_usxwr    : natural  := 116;
constant eratpos_gs       : natural  := 122;
constant eratpos_ts       : natural  := 123;
constant eratpos_tid      : natural  := 124;
constant PorSeq_Idle : std_ulogic_vector(0 to 2) := "000";
constant PorSeq_Stg1 : std_ulogic_vector(0 to 2) := "001";
constant PorSeq_Stg2 : std_ulogic_vector(0 to 2) := "011";
constant PorSeq_Stg3 : std_ulogic_vector(0 to 2) := "010";
constant PorSeq_Stg4 : std_ulogic_vector(0 to 2) := "110";
constant PorSeq_Stg5 : std_ulogic_vector(0 to 2) := "100";
constant PorSeq_Stg6 : std_ulogic_vector(0 to 2) := "101";
constant PorSeq_Stg7 : std_ulogic_vector(0 to 2) := "111";
constant Por_Wr_Entry_Num1   : std_ulogic_vector(0 to num_entry_log2-1) := "11110";
constant Por_Wr_Entry_Num2   : std_ulogic_vector(0 to num_entry_log2-1) := "11111";
-- wr_cam_data
--  0:51  - EPN
--  52  - X
--  53:55  - SIZE
--  56  - V
--  57:60  - ThdID
--  61:62  - Class
--  63:64  - ExtClass | TID_NZ
--  65  - TGS
--  66  - TS
--  67:74  - TID
--  75:78  - epn_cmpmasks:  34_39, 40_43, 44_47, 48_51
--  79:82  - xbit_cmpmasks: 34_51, 40_51, 44_51, 48_51
--  83  - parity for 75:82
constant Por_Wr_Cam_Data1   : std_ulogic_vector(0 to 83) := "0000000000000000000000000000000011111111111111111111" &
                                   '0' & "001" & '1' & "1111" & "00" & "00" & "00" & "00000000" & "11110000" & '0';
constant Por_Wr_Cam_Data2   : std_ulogic_vector(0 to 83) := "0000000000000000000000000000000000000000000000000000" &
                                   '0' & "001" & '1' & "1111" & "00" & "10" & "00" & "00000000" & "11110000" & '0';
-- 16x143 version, 42b RA
-- wr_array_data
--  0:29  - RPN
--  30:31  - R,C
--  32:35  - ResvAttr
--  36:39  - U0-U3
--  40:44  - WIMGE
--  45:46  - UX,SX
--  47:48  - UW,SW
--  49:50  - UR,SR
--  51:60  - CAM parity
--  61:67  - Array parity
constant Por_Wr_Array_Data1 : std_ulogic_vector(0 to 67) := "111111111111111111111111111111" &
                                   "00" & "0000" & "0000" & "01010" & "01" & "00" & "01" & "0000001000" & "0000000";
constant Por_Wr_Array_Data2 : std_ulogic_vector(0 to 67) := "000000000000000000000000000000" &
                                   "00" & "0000" & "0000" & "01010" & "01" & "00" & "01" & "0000001010" & "0000000";
constant rf1_valid_offset           : natural := 0;
constant rf1_ttype_offset           : natural := rf1_valid_offset + thdid_width;
constant ex1_valid_offset           : natural := rf1_ttype_offset + 2;
constant ex1_ttype_offset           : natural := ex1_valid_offset + thdid_width;
constant ex1_ws_offset              : natural := ex1_ttype_offset + ttype_width;
constant ex1_rs_is_offset           : natural := ex1_ws_offset + ws_width;
constant ex1_ra_entry_offset        : natural := ex1_rs_is_offset + rs_is_width;
constant ex1_state_offset           : natural := ex1_ra_entry_offset + ra_entry_width;
constant ex1_pid_offset             : natural := ex1_state_offset + state_width;
constant ex1_extclass_offset        : natural := ex1_pid_offset + pid_width;
constant ex1_tlbsel_offset          : natural := ex1_extclass_offset + extclass_width;
constant ex2_valid_offset           : natural := ex1_tlbsel_offset + tlbsel_width;
constant ex2_ttype_offset           : natural := ex2_valid_offset + thdid_width;
constant ex2_ws_offset              : natural := ex2_ttype_offset + ttype_width;
constant ex2_rs_is_offset           : natural := ex2_ws_offset + ws_width;
constant ex2_ra_entry_offset        : natural := ex2_rs_is_offset + rs_is_width;
constant ex2_state_offset           : natural := ex2_ra_entry_offset + ra_entry_width;
constant ex2_pid_offset             : natural := ex2_state_offset + state_width;
constant ex2_extclass_offset        : natural := ex2_pid_offset + pid_width;
constant ex2_tlbsel_offset          : natural := ex2_extclass_offset + extclass_width;
constant ex3_valid_offset           : natural := ex2_tlbsel_offset + tlbsel_width;
constant ex3_ttype_offset           : natural := ex3_valid_offset + thdid_width;
constant ex3_ws_offset              : natural := ex3_ttype_offset + ttype_width;
constant ex3_rs_is_offset           : natural := ex3_ws_offset + ws_width;
constant ex3_ra_entry_offset        : natural := ex3_rs_is_offset + rs_is_width;
constant ex3_state_offset           : natural := ex3_ra_entry_offset + ra_entry_width;
constant ex3_pid_offset             : natural := ex3_state_offset + state_width;
constant ex3_lpid_offset            : natural := ex3_pid_offset + pid_width;
constant ex3_extclass_offset        : natural := ex3_lpid_offset + lpid_width;
constant ex3_tlbsel_offset          : natural := ex3_extclass_offset + extclass_width;
constant ex4_valid_offset           : natural := ex3_tlbsel_offset + tlbsel_width;
constant ex4_ttype_offset           : natural := ex4_valid_offset + thdid_width;
constant ex4_ws_offset              : natural := ex4_ttype_offset + ttype_width;
constant ex4_rs_is_offset           : natural := ex4_ws_offset + ws_width;
constant ex4_ra_entry_offset        : natural := ex4_rs_is_offset + rs_is_width;
constant ex4_state_offset           : natural := ex4_ra_entry_offset + ra_entry_width;
constant ex4_pid_offset             : natural := ex4_state_offset + state_width;
constant ex4_extclass_offset        : natural := ex4_pid_offset + pid_width;
constant ex4_tlbsel_offset          : natural := ex4_extclass_offset + extclass_width;
constant ex5_valid_offset           : natural := ex4_tlbsel_offset + tlbsel_width;
constant ex5_ttype_offset           : natural := ex5_valid_offset + thdid_width;
constant ex5_ws_offset              : natural := ex5_ttype_offset + ttype_width;
constant ex5_rs_is_offset           : natural := ex5_ws_offset + ws_width;
constant ex5_ra_entry_offset        : natural := ex5_rs_is_offset + rs_is_width;
constant ex5_state_offset           : natural := ex5_ra_entry_offset + ra_entry_width;
constant ex5_pid_offset             : natural := ex5_state_offset + state_width;
constant ex5_extclass_offset        : natural := ex5_pid_offset + pid_width;
constant ex5_tlbsel_offset          : natural := ex5_extclass_offset + extclass_width;
constant ex5_data_in_offset         : natural := ex5_tlbsel_offset + tlbsel_width;
constant ex6_valid_offset           : natural := ex5_data_in_offset + rs_data_width;
constant ex6_ttype_offset           : natural := ex6_valid_offset + thdid_width;
constant ex6_ws_offset              : natural := ex6_ttype_offset + ttype_width;
constant ex6_rs_is_offset           : natural := ex6_ws_offset + ws_width;
constant ex6_ra_entry_offset        : natural := ex6_rs_is_offset + rs_is_width;
constant ex6_state_offset           : natural := ex6_ra_entry_offset + ra_entry_width;
constant ex6_pid_offset             : natural := ex6_state_offset + state_width;
constant ex6_extclass_offset        : natural := ex6_pid_offset + pid_width;
constant ex6_tlbsel_offset          : natural := ex6_extclass_offset + extclass_width;
constant ex6_data_in_offset         : natural := ex6_tlbsel_offset + tlbsel_width;
constant ex7_valid_offset           : natural := ex6_data_in_offset + rs_data_width;
constant ex7_ttype_offset           : natural := ex7_valid_offset + thdid_width;
constant ex7_tlbsel_offset          : natural := ex7_ttype_offset + ttype_width;
constant ex4_data_out_offset        : natural := ex7_tlbsel_offset + tlbsel_width;
constant ex2_n_flush_req_offset     : natural := ex4_data_out_offset + data_out_width;
constant ex3_n_flush_req_offset     : natural := ex2_n_flush_req_offset + thdid_width;
constant hold_req_reset_offset      : natural := ex3_n_flush_req_offset + thdid_width;
constant hold_req_pot_set_offset    : natural := hold_req_reset_offset + thdid_width;
constant hold_req_por_offset        : natural := hold_req_pot_set_offset + thdid_width;
constant hold_req_offset            : natural := hold_req_por_offset + thdid_width;
constant tlb_req_inprogress_offset  : natural := hold_req_offset + thdid_width;
constant ex2_dsi_offset             : natural := tlb_req_inprogress_offset + thdid_width;
constant ex2_noop_touch_offset      : natural := ex2_dsi_offset + 16;
constant ex3_miss_offset            : natural := ex2_noop_touch_offset + 16;
constant ex3_dsi_offset             : natural := ex3_miss_offset + thdid_width;
constant ex3_noop_touch_offset      : natural := ex3_dsi_offset + 16;
constant ex3_multihit_offset        : natural := ex3_noop_touch_offset + 16;
constant ex3_multihit_b_pt_offset   : natural := ex3_multihit_offset + thdid_width;
constant ex3_first_hit_entry_pt_offset  : natural := ex3_multihit_b_pt_offset + num_entry;
constant ex3_parerr_offset          : natural := ex3_first_hit_entry_pt_offset + num_entry-1;
constant ex3_attr_offset            : natural := ex3_parerr_offset + thdid_width + 2;
constant ex3_tlbreq_offset          : natural := ex3_attr_offset + 6;
constant ex3_hit_offset             : natural := ex3_tlbreq_offset + 1;
constant ex3_cam_hit_offset         : natural := ex3_hit_offset + 1;
constant ex2_debug_offset           : natural := ex3_cam_hit_offset + 1;
constant ex3_debug_offset           : natural := ex2_debug_offset + 11;
constant spare_a_offset             : natural := ex3_debug_offset + 17;
constant scan_right_0               : natural := spare_a_offset + 16 -1;
constant erat_parerr_mac_offset     : natural := 0;
constant ex4_rd_cam_data_offset     : natural := erat_parerr_mac_offset + 1;
constant ex4_rd_array_data_offset   : natural := ex4_rd_cam_data_offset + cam_data_width;
constant ex4_parerr_offset          : natural := ex4_rd_array_data_offset + array_data_width;
constant ex4_fir_parerr_offset      : natural := ex4_parerr_offset + thdid_width + 2;
constant ex4_fir_multihit_offset    : natural := ex4_fir_parerr_offset + thdid_width + 3;
constant ex4_deen_offset            : natural := ex4_fir_multihit_offset + thdid_width;
constant ex4_hit_offset             : natural := ex4_deen_offset + num_entry_log2 + thdid_width;
constant ex5_deen_offset            : natural := ex4_hit_offset + 1;
constant ex5_hit_offset             : natural := ex5_deen_offset + num_entry_log2 + thdid_width;
constant ex6_deen_offset            : natural := ex5_hit_offset + 1;
constant ex6_hit_offset             : natural := ex6_deen_offset + num_entry_log2 + 1;
constant barrier_done_offset        : natural := ex6_hit_offset + 1;
constant mmucr1_offset              : natural := barrier_done_offset + thdid_width;
constant rpn_holdreg0_offset        : natural := mmucr1_offset + 10;
constant rpn_holdreg1_offset        : natural := rpn_holdreg0_offset + 64;
constant rpn_holdreg2_offset        : natural := rpn_holdreg1_offset + 64;
constant rpn_holdreg3_offset        : natural := rpn_holdreg2_offset + 64;
constant entry_valid_offset         : natural := rpn_holdreg3_offset + 64;
constant entry_match_offset         : natural := entry_valid_offset + 32;
constant watermark_offset           : natural := entry_match_offset + 32;
constant mmucr1_b0_cpy_offset       : natural := watermark_offset + watermark_width;
constant lru_rmt_vec_offset         : natural := mmucr1_b0_cpy_offset + 1;
constant eptr_offset                : natural := lru_rmt_vec_offset + lru_width+1;
constant lru_offset                 : natural := eptr_offset + eptr_width;
constant lru_update_event_offset    : natural := lru_offset + lru_width;
constant lru_debug_offset           : natural := lru_update_event_offset + 10;
constant snoop_val_offset           : natural := lru_debug_offset + 41;
constant snoop_attr_offset          : natural := snoop_val_offset + 3;
constant snoop_addr_offset          : natural := snoop_attr_offset + 26;
constant ex2_epn_offset             : natural := snoop_addr_offset + epn_width;
constant por_seq_offset             : natural := ex2_epn_offset + ex2_epn_width;
constant pc_xu_init_reset_offset    : natural := por_seq_offset + 3;
constant tlb_rel_val_offset         : natural := pc_xu_init_reset_offset + 1;
constant tlb_rel_data_offset        : natural := tlb_rel_val_offset + thdid_width + 1;
constant eplc_wr_offset             : natural := tlb_rel_data_offset + 132;
constant epsc_wr_offset             : natural := eplc_wr_offset + 2*thdid_width + 1;
constant ccr2_frat_paranoia_offset  : natural := epsc_wr_offset + 2*thdid_width + 1;
constant ccr2_notlb_offset          : natural := ccr2_frat_paranoia_offset + 12;
constant xucr4_mmu_mchk_offset      : natural := ccr2_notlb_offset + 1;
constant mchk_flash_inv_offset      : natural := xucr4_mmu_mchk_offset + 1;
constant clkg_ctl_override_offset   : natural := mchk_flash_inv_offset + 4;
constant rf1_stg_act_offset         : natural := clkg_ctl_override_offset + 1;
constant ex1_stg_act_offset         : natural := rf1_stg_act_offset + 1;
constant ex2_stg_act_offset         : natural := ex1_stg_act_offset + 1;
constant ex3_stg_act_offset         : natural := ex2_stg_act_offset + 1;
constant ex4_stg_act_offset         : natural := ex3_stg_act_offset + 1;
constant ex5_stg_act_offset         : natural := ex4_stg_act_offset + 1;
constant ex6_stg_act_offset         : natural := ex5_stg_act_offset + 1;
constant ex7_stg_act_offset         : natural := ex6_stg_act_offset + 1;
constant tlb_rel_act_offset         : natural := ex7_stg_act_offset + 1;
constant snoop_act_offset           : natural := tlb_rel_act_offset + 1;
constant trace_bus_enable_offset    : natural := snoop_act_offset + 1;
constant an_ac_grffence_en_dc_offset  : natural := trace_bus_enable_offset + 1;
constant spare_b_offset  : natural := an_ac_grffence_en_dc_offset + 1;
constant scan_right_1               : natural := spare_b_offset + 16 -1;
constant bcfg_offset           : natural := 0;
constant boot_scan_right       : natural := bcfg_offset + bcfg_width - 1;
----------------------------
-- signals
----------------------------
-- Latch signals
signal rf1_valid_d, rf1_valid_q          : std_ulogic_vector(0 to thdid_width-1);
signal rf1_ttype_d, rf1_ttype_q          : std_ulogic_vector(10 to 11);
signal ex1_valid_d           : std_ulogic_vector(0 to thdid_width-1);
signal ex1_valid_q          : std_ulogic_vector(0 to thdid_width-1);
signal ex1_ttype_d           : std_ulogic_vector(0 to ttype_width-1);
signal ex1_ttype_q          : std_ulogic_vector(0 to ttype_width-1);
signal ex1_ws_d              : std_ulogic_vector(0 to ws_width-1);
signal ex1_ws_q             : std_ulogic_vector(0 to ws_width-1);
signal ex1_rs_is_d           : std_ulogic_vector(0 to rs_is_width-1);
signal ex1_rs_is_q          : std_ulogic_vector(0 to rs_is_width-1);
signal ex1_ra_entry_d        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex1_ra_entry_q       : std_ulogic_vector(0 to ra_entry_width-1);
signal ex1_state_d           : std_ulogic_vector(0 to state_width-1);
signal ex1_state_q          : std_ulogic_vector(0 to state_width-1);
signal ex1_pid_d             : std_ulogic_vector(0 to pid_width-1);
signal ex1_pid_q            : std_ulogic_vector(0 to pid_width-1);
signal ex1_extclass_d        : std_ulogic_vector(0 to extclass_width-1);
signal ex1_extclass_q       : std_ulogic_vector(0 to extclass_width-1);
signal ex1_tlbsel_d          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex1_tlbsel_q         : std_ulogic_vector(0 to tlbsel_width-1);
signal ex2_valid_d           : std_ulogic_vector(0 to thdid_width-1);
signal ex2_valid_q          : std_ulogic_vector(0 to thdid_width-1);
signal ex2_ttype_d           : std_ulogic_vector(0 to ttype_width-1);
signal ex2_ttype_q          : std_ulogic_vector(0 to ttype_width-1);
signal ex2_ws_d              : std_ulogic_vector(0 to ws_width-1);
signal ex2_ws_q             : std_ulogic_vector(0 to ws_width-1);
signal ex2_rs_is_d           : std_ulogic_vector(0 to rs_is_width-1);
signal ex2_rs_is_q          : std_ulogic_vector(0 to rs_is_width-1);
signal ex2_ra_entry_d        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex2_ra_entry_q       : std_ulogic_vector(0 to ra_entry_width-1);
signal ex2_state_d           : std_ulogic_vector(0 to state_width-1);
signal ex2_state_q          : std_ulogic_vector(0 to state_width-1);
signal ex2_pid_d             : std_ulogic_vector(0 to pid_width-1);
signal ex2_pid_q            : std_ulogic_vector(0 to pid_width-1);
signal ex2_extclass_d        : std_ulogic_vector(0 to extclass_width-1);
signal ex2_extclass_q       : std_ulogic_vector(0 to extclass_width-1);
signal ex2_tlbsel_d          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex2_tlbsel_q         : std_ulogic_vector(0 to tlbsel_width-1);
signal ex3_valid_d           : std_ulogic_vector(0 to thdid_width-1);
signal ex3_valid_q          : std_ulogic_vector(0 to thdid_width-1);
signal ex3_ttype_d           : std_ulogic_vector(0 to ttype_width-1);
signal ex3_ttype_q          : std_ulogic_vector(0 to ttype_width-1);
signal ex3_ws_d              : std_ulogic_vector(0 to ws_width-1);
signal ex3_ws_q             : std_ulogic_vector(0 to ws_width-1);
signal ex3_rs_is_d           : std_ulogic_vector(0 to rs_is_width-1);
signal ex3_rs_is_q          : std_ulogic_vector(0 to rs_is_width-1);
signal ex3_ra_entry_d        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex3_ra_entry_q       : std_ulogic_vector(0 to ra_entry_width-1);
signal ex3_state_d           : std_ulogic_vector(0 to state_width-1);
signal ex3_state_q          : std_ulogic_vector(0 to state_width-1);
signal ex3_pid_d             : std_ulogic_vector(0 to pid_width-1);
signal ex3_pid_q            : std_ulogic_vector(0 to pid_width-1);
signal ex3_lpid_d             : std_ulogic_vector(0 to lpid_width-1);
signal ex3_lpid_q            : std_ulogic_vector(0 to lpid_width-1);
signal ex3_extclass_d        : std_ulogic_vector(0 to extclass_width-1);
signal ex3_extclass_q       : std_ulogic_vector(0 to extclass_width-1);
signal ex3_tlbsel_d          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex3_tlbsel_q         : std_ulogic_vector(0 to tlbsel_width-1);
signal ex4_valid_d           : std_ulogic_vector(0 to thdid_width-1);
signal ex4_valid_q          : std_ulogic_vector(0 to thdid_width-1);
signal ex4_ttype_d           : std_ulogic_vector(0 to ttype_width-1);
signal ex4_ttype_q          : std_ulogic_vector(0 to ttype_width-1);
signal ex4_ws_d              : std_ulogic_vector(0 to ws_width-1);
signal ex4_ws_q             : std_ulogic_vector(0 to ws_width-1);
signal ex4_rs_is_d           : std_ulogic_vector(0 to rs_is_width-1);
signal ex4_rs_is_q          : std_ulogic_vector(0 to rs_is_width-1);
signal ex4_ra_entry_d        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex4_ra_entry_q       : std_ulogic_vector(0 to ra_entry_width-1);
signal ex4_state_d           : std_ulogic_vector(0 to state_width-1);
signal ex4_state_q          : std_ulogic_vector(0 to state_width-1);
signal ex4_pid_d             : std_ulogic_vector(0 to pid_width-1);
signal ex4_pid_q            : std_ulogic_vector(0 to pid_width-1);
signal ex4_extclass_d        : std_ulogic_vector(0 to extclass_width-1);
signal ex4_extclass_q       : std_ulogic_vector(0 to extclass_width-1);
signal ex4_tlbsel_d          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex4_tlbsel_q         : std_ulogic_vector(0 to tlbsel_width-1);
signal ex5_valid_d,    ex5_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex5_ttype_d,    ex5_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex5_ws_d,       ex5_ws_q              : std_ulogic_vector(0 to ws_width-1);
signal ex5_rs_is_d,    ex5_rs_is_q           : std_ulogic_vector(0 to rs_is_width-1);
signal ex5_ra_entry_d, ex5_ra_entry_q        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex5_state_d,    ex5_state_q           : std_ulogic_vector(0 to state_width-1);
signal ex5_pid_d,      ex5_pid_q             : std_ulogic_vector(0 to pid_width-1);
signal ex5_extclass_d, ex5_extclass_q        : std_ulogic_vector(0 to extclass_width-1);
signal ex5_tlbsel_d,   ex5_tlbsel_q          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex6_valid_d,    ex6_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex6_ttype_d,    ex6_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex6_ws_d,       ex6_ws_q              : std_ulogic_vector(0 to ws_width-1);
signal ex6_rs_is_d,    ex6_rs_is_q           : std_ulogic_vector(0 to rs_is_width-1);
signal ex6_ra_entry_d, ex6_ra_entry_q        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex6_state_d,    ex6_state_q           : std_ulogic_vector(0 to state_width-1);
signal ex6_pid_d,      ex6_pid_q             : std_ulogic_vector(0 to pid_width-1);
signal ex6_extclass_d, ex6_extclass_q        : std_ulogic_vector(0 to extclass_width-1);
signal ex6_tlbsel_d,   ex6_tlbsel_q          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex7_valid_d,    ex7_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex7_ttype_d,    ex7_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex7_tlbsel_d,   ex7_tlbsel_q          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex5_data_in_d, ex5_data_in_q          : std_ulogic_vector(64-rs_data_width to 63);
signal ex6_data_in_d, ex6_data_in_q          : std_ulogic_vector(64-rs_data_width to 63);
signal ex4_data_out_d, ex4_data_out_q      : std_ulogic_vector(64-data_out_width to 63);
signal ex2_n_flush_req_d, ex2_n_flush_req_q   : std_ulogic_vector(0 to thdid_width-1);
signal ex3_n_flush_req_d, ex3_n_flush_req_q   : std_ulogic_vector(0 to thdid_width-1);
signal hold_req_d, hold_req_q          : std_ulogic_vector(0 to thdid_width-1);
signal hold_req_reset_d, hold_req_reset_q               : std_ulogic_vector(0 to thdid_width-1);
signal hold_req_pot_set_d, hold_req_pot_set_q           : std_ulogic_vector(0 to thdid_width-1);
signal hold_req_por_d, hold_req_por_q                   : std_ulogic_vector(0 to thdid_width-1);
signal tlb_req_inprogress_d, tlb_req_inprogress_q          : std_ulogic_vector(0 to thdid_width-1);
signal ex1_deratre, ex1_deratwe, ex1_deratsx        : std_ulogic;
signal ex2_dsi_d, ex2_dsi_q           : std_ulogic_vector(0 to 15);
signal ex2_noop_touch_d, ex2_noop_touch_q : std_ulogic_vector(0 to 15);
signal ex3_miss_d, ex3_miss_q      : std_ulogic_vector(0 to thdid_width-1);
signal ex3_dsi_d, ex3_dsi_q           : std_ulogic_vector(0 to 15);
signal ex3_noop_touch_d, ex3_noop_touch_q     : std_ulogic_vector(0 to 15);
signal ex3_multihit_d, ex3_multihit_q         : std_ulogic_vector(0 to thdid_width-1);
signal ex3_multihit_b_pt_d, ex3_multihit_b_pt_q         : std_ulogic_vector(1 to num_entry);
signal ex3_first_hit_entry_pt_d, ex3_first_hit_entry_pt_q  : std_ulogic_vector(1 to num_entry-1);
signal ex3_parerr_d, ex3_parerr_q   : std_ulogic_vector(0 to thdid_width+1);
signal ex3_attr_d, ex3_attr_q       : std_ulogic_vector(0 to 5);
signal ex3_tlbreq_d, ex3_tlbreq_q   : std_ulogic;
signal ex3_hit_d, ex3_hit_q         : std_ulogic;
signal ex3_cam_hit_q         : std_ulogic;
signal ex2_debug_d, ex2_debug_q         : std_ulogic_vector(0 to 10);
signal ex3_debug_d, ex3_debug_q         : std_ulogic_vector(0 to 16);
signal ex3_cam_cmp_data_q         : std_ulogic_vector(0 to cam_data_width-1);
signal ex3_array_cmp_data_q         : std_ulogic_vector(0 to array_data_width-1);
signal ex4_rd_array_data_d, ex4_rd_array_data_q         : std_ulogic_vector(0 to array_data_width-1);
signal ex4_rd_cam_data_d, ex4_rd_cam_data_q         : std_ulogic_vector(0 to cam_data_width-1);
signal ex4_parerr_d, ex4_parerr_q   : std_ulogic_vector(0 to thdid_width+1);
signal ex4_fir_parerr_d, ex4_fir_parerr_q           : std_ulogic_vector(0 to thdid_width+2);
signal ex4_fir_multihit_d, ex4_fir_multihit_q       : std_ulogic_vector(0 to thdid_width-1);
signal ex4_deen_d, ex4_deen_q       : std_ulogic_vector(0 to thdid_width+num_entry_log2-1);
signal ex4_hit_d, ex4_hit_q         : std_ulogic;
signal ex5_deen_d, ex5_deen_q       : std_ulogic_vector(0 to thdid_width+num_entry_log2-1);
signal ex5_hit_d, ex5_hit_q         : std_ulogic;
signal ex6_deen_d, ex6_deen_q       : std_ulogic_vector(0 to num_entry_log2);
signal ex6_hit_d, ex6_hit_q         : std_ulogic;
signal ex3_deratwe, ex4_deratwe, ex5_deratwe, ex6_deratwe, ex7_deratwe        : std_ulogic;
signal ex6_deratwe_ws3    : std_ulogic;
signal barrier_done_d, barrier_done_q           : std_ulogic_vector(0 to thdid_width-1);
signal mmucr1_d,    mmucr1_q           : std_ulogic_vector(0 to 9);
signal mmucr1_b0_cpy_d, mmucr1_b0_cpy_q : std_ulogic;
signal lru_rmt_vec_d, lru_rmt_vec_q     : std_ulogic_vector(0 to lru_width);
signal ex3_dsi                          : std_ulogic_vector(0 to 7);
signal ex3_noop_touch                   : std_ulogic_vector(0 to 7);
signal por_seq_d, por_seq_q    : std_ulogic_vector(0 to 2);
signal rpn_holdreg0_d, rpn_holdreg0_q    : std_ulogic_vector(0 to 63);
signal rpn_holdreg1_d, rpn_holdreg1_q    : std_ulogic_vector(0 to 63);
signal rpn_holdreg2_d, rpn_holdreg2_q    : std_ulogic_vector(0 to 63);
signal rpn_holdreg3_d, rpn_holdreg3_q    : std_ulogic_vector(0 to 63);
signal watermark_d, watermark_q    : std_ulogic_vector(0 to watermark_width-1);
signal eptr_d, eptr_q    : std_ulogic_vector(0 to eptr_width-1);
signal lru_d, lru_q    : std_ulogic_vector(1 to lru_width);
signal lru_update_event_d, lru_update_event_q  : std_ulogic_vector(0 to 9);
signal lru_debug_d, lru_debug_q  : std_ulogic_vector(0 to 40);
signal snoop_val_d, snoop_val_q        : std_ulogic_vector(0 to 2);
signal snoop_attr_d, snoop_attr_q      : std_ulogic_vector(0 to 25);
signal snoop_addr_d, snoop_addr_q      : std_ulogic_vector(52-epn_width to 51);
signal ex2_epn_d, ex2_epn_q    : std_ulogic_vector(52-ex2_epn_width to 51);
signal pc_xu_init_reset_q             : std_ulogic;
signal tlb_rel_val_d, tlb_rel_val_q   : std_ulogic_vector(0 to 4);
signal tlb_rel_data_d, tlb_rel_data_q : std_ulogic_vector(0 to 131);
signal eplc_wr_d, eplc_wr_q : std_ulogic_vector(0 to 2*thdid_width);
signal epsc_wr_d, epsc_wr_q : std_ulogic_vector(0 to 2*thdid_width);
signal ccr2_frat_paranoia_d, ccr2_frat_paranoia_q : std_ulogic_vector(0 to 11);
signal ccr2_notlb_q, xucr4_mmu_mchk_q         : std_ulogic;
signal mchk_flash_inv_d, mchk_flash_inv_q    : std_ulogic_vector(0 to 3);
signal mchk_flash_inv_enab  : std_ulogic;
signal bcfg_q, bcfg_q_b : std_ulogic_vector(0 to bcfg_width-1);
-- logic signals
signal por_wr_cam_val           :  std_ulogic_vector(0 to 1);
signal por_wr_array_val         :  std_ulogic_vector(0 to 1);
signal por_wr_cam_data           :  std_ulogic_vector(0 to cam_data_width-1);
signal por_wr_array_data         :  std_ulogic_vector(0 to array_data_width-1);
signal por_wr_entry           :  std_ulogic_vector(0 to num_entry_log2-1);
signal por_hold_req             : std_ulogic_vector(0 to thdid_width-1);
signal ex2_multihit_b     : std_ulogic;
signal ex2_first_hit_entry  :  std_ulogic_vector(0 to num_entry_log2-1);
signal ex3_first_hit_entry  :  std_ulogic_vector(0 to num_entry_log2-1);
signal ex3_dsi_enab    : std_ulogic;
signal ex3_noop_touch_enab    : std_ulogic;
signal ex3_multihit_enab         : std_ulogic;
signal ex3_parerr_enab    : std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
signal ex3_eratsx_data  : std_ulogic_vector(0 to 2+num_entry_log2-1);
signal hold_req_set                     : std_ulogic_vector(0 to thdid_width-1);
signal hold_req                         : std_ulogic_vector(0 to thdid_width-1);
signal lru_way_encode    : std_ulogic_vector(0 to num_entry_log2-1);
signal lru_rmt_vec     : std_ulogic_vector(0 to lru_width);
signal lru_reset_vec, lru_set_vec    : std_ulogic_vector(1 to lru_width);
signal lru_op_vec, lru_vp_vec    : std_ulogic_vector(1 to lru_width);
signal lru_eff    : std_ulogic_vector(1 to lru_width);
signal lru_watermark_mask : std_ulogic_vector(0 to lru_width);
signal entry_valid_watermarked : std_ulogic_vector(0 to lru_width);
signal eptr_p1    : std_ulogic_vector(0 to eptr_width-1);
signal xu_derat_rf1_is_icbtlslc  : std_ulogic;
signal ex3_cmp_data_parerr_epn_mac         :  std_ulogic;
signal ex3_cmp_data_parerr_rpn_mac         :  std_ulogic;
signal ex3_cmp_data_parerr_epn         :  std_ulogic;
signal ex3_cmp_data_parerr_rpn         :  std_ulogic;
signal ex4_rd_data_calc_par        :  std_ulogic_vector(50 to 67);
signal ex4_rd_data_parerr_epn          :  std_ulogic;
signal ex4_rd_data_parerr_rpn          :  std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
signal ex4_parerr_enab          :  std_ulogic;
signal ex4_fir_parerr_enab      :  std_ulogic;
signal rf1_mmucr0_gs, rf1_mmucr0_ts  : std_ulogic;
signal rf1_eplc_epr, rf1_epsc_epr, rf1_eplc_egs, rf1_epsc_egs, rf1_eplc_eas, rf1_epsc_eas: std_ulogic;
signal rf1_pid, rf1_mmucr0_pid, rf1_eplc_epid, rf1_epsc_epid   :  std_ulogic_vector(0 to pid_width-1);
signal tlb_rel_cmpmask  : std_ulogic_vector(0 to 3);
signal tlb_rel_xbitmask  : std_ulogic_vector(0 to 3);
signal tlb_rel_maskpar  : std_ulogic;
signal ex6_data_cmpmask  : std_ulogic_vector(0 to 3);
signal ex6_data_xbitmask  : std_ulogic_vector(0 to 3);
signal ex6_data_maskpar  : std_ulogic;
-- CAM/Array signals
-- Read Port
signal   rd_val                         :  std_ulogic;
signal   rw_entry                       :  std_ulogic_vector(0 to 4);
-- Write Port
signal   wr_array_par                   :  std_ulogic_vector(51 to 67);
signal   wr_array_data_nopar            :  std_ulogic_vector(0 to array_data_width-1-10-7);
signal   wr_array_data                  :  std_ulogic_vector(0 to array_data_width-1);
signal   wr_cam_data                    :  std_ulogic_vector(0 to cam_data_width-1);
signal   wr_array_val                   :  std_ulogic_vector(0 to 1);
signal   wr_cam_val                     :  std_ulogic_vector(0 to 1);
signal   wr_val_early                   :  std_ulogic;
-- CAM Port
signal   comp_request                   :  std_ulogic;
signal   comp_addr                      :  std_ulogic_vector(0 to 51);
signal   addr_enable                    :  std_ulogic_vector(0 to 1);
signal   comp_pgsize                    :  std_ulogic_vector(0 to 2);
signal   pgsize_enable                  :  std_ulogic;
signal   comp_class                     :  std_ulogic_vector(0 to 1);
signal   class_enable                   :  std_ulogic_vector(0 to 2);
signal   comp_extclass                  :  std_ulogic_vector(0 to 1);
signal   extclass_enable                :  std_ulogic_vector(0 to 1);
signal   comp_state                     :  std_ulogic_vector(0 to 1);
signal   state_enable                   :  std_ulogic_vector(0 to 1);
signal   comp_thdid                     :  std_ulogic_vector(0 to 3);
signal   thdid_enable                   :  std_ulogic_vector(0 to 1);
signal   comp_pid                       :  std_ulogic_vector(0 to 7);
signal   pid_enable                     :  std_ulogic;
signal   comp_invalidate                :  std_ulogic;
signal   flash_invalidate               :  std_ulogic;
-- Array Outputs
signal   array_cmp_data                 :  std_ulogic_vector(0 to array_data_width-1);
signal   rd_array_data                  :  std_ulogic_vector(0 to array_data_width-1);
-- CAM Outputs
signal   cam_cmp_data                   :  std_ulogic_vector(0 to cam_data_width-1);
signal   cam_hit                        :  std_ulogic;
signal   cam_hit_entry                  :  std_ulogic_vector(0 to 4);
signal   entry_match, entry_match_q     :  std_ulogic_vector(0 to 31);
signal   entry_valid, entry_valid_q     :  std_ulogic_vector(0 to 31);
signal   rd_cam_data                    :  std_ulogic_vector(0 to cam_data_width-1);
-- synopsys translate_off
-- synopsys translate_on
signal   cam_pgsize                     :  std_ulogic_vector(0 to 2);
signal   ws0_pgsize                     :  std_ulogic_vector(0 to 3);
signal bypass_mux_enab_np1 : std_ulogic;
signal bypass_attr_np1     : std_ulogic_vector(0 to 20);
signal attr_np2            : std_ulogic_vector(0 to 20);
signal rpn_np2             : std_ulogic_vector(22 to 51);
-- Pervasive
signal pc_sg_1         : std_ulogic;
signal pc_sg_0         : std_ulogic;
signal pc_func_sl_thold_1        : std_ulogic;
signal pc_func_sl_thold_0        : std_ulogic;
signal pc_func_sl_thold_0_b      : std_ulogic;
signal pc_func_slp_sl_thold_1    : std_ulogic;
signal pc_func_slp_sl_thold_0    : std_ulogic;
signal pc_func_slp_sl_thold_0_b  : std_ulogic;
signal pc_func_sl_force     : std_ulogic;
signal pc_func_slp_sl_force : std_ulogic;
signal pc_cfg_slp_sl_thold_1        : std_ulogic;
signal pc_cfg_slp_sl_thold_0        : std_ulogic;
signal pc_cfg_slp_sl_thold_0_b      : std_ulogic;
signal pc_cfg_slp_sl_force          : std_ulogic;
signal lcb_dclk  : std_ulogic;
signal lcb_lclk   : clk_logic;
signal init_alias         : std_ulogic;
signal clkg_ctl_override_d      :std_ulogic;
signal clkg_ctl_override_q      :std_ulogic;
signal rf1_stg_act_d, rf1_stg_act_q            :std_ulogic;
signal ex1_stg_act_d, ex1_stg_act_q            :std_ulogic;
signal ex2_stg_act_d, ex2_stg_act_q            :std_ulogic;
signal ex3_stg_act_d, ex3_stg_act_q            :std_ulogic;
signal ex4_stg_act_d, ex4_stg_act_q            :std_ulogic;
signal ex5_stg_act_d, ex5_stg_act_q            :std_ulogic;
signal ex6_stg_act_d, ex6_stg_act_q            :std_ulogic;
signal ex7_stg_act_d, ex7_stg_act_q            :std_ulogic;
signal tlb_rel_act_d, tlb_rel_act_q, tlb_rel_act     :std_ulogic;
signal an_ac_grffence_en_dc_q, trace_bus_enable_q     :std_ulogic;
signal ex2_cmp_data_act, ex3_grffence_act, ex2_or_ex3_grffence_act, ex3_to_ex6_grffence_act     :std_ulogic;
signal ex3_rd_data_act, ex3_data_out_act      :std_ulogic;
signal entry_valid_act, entry_match_act  :std_ulogic;
signal snoop_act_q, snoop_act     :std_ulogic;
signal not_grffence_act, lru_update_act, notlb_grffence_act, debug_grffence_act  :std_ulogic;
signal spare_a_q     :std_ulogic_vector(0 to 15);
signal spare_b_q     :std_ulogic_vector(0 to 15);
signal unused_dc  :  std_ulogic_vector(0 to 39);
-- synopsys translate_off
-- synopsys translate_on
signal siv_0                      : std_ulogic_vector(0 to scan_right_0);
signal sov_0                      : std_ulogic_vector(0 to scan_right_0);
signal siv_1                      : std_ulogic_vector(0 to scan_right_1);
signal sov_1                      : std_ulogic_vector(0 to scan_right_1);
signal bsiv                     : std_ulogic_vector(0 to boot_scan_right);
signal bsov                     : std_ulogic_vector(0 to boot_scan_right);
-- cam component scan chains
signal   func_si_cam_int, func_so_cam_int     : std_ulogic;
signal tiup                     : std_ulogic;
  BEGIN --@@ START OF EXECUTABLE CODE FOR XUQ_LSU_DERAT

-----------------------------------------------------------------------
-- ACT Generation
-----------------------------------------------------------------------
clkg_ctl_override_d  <=  spr_xucr0_clkg_ctl_b1;
rf1_stg_act_d  <=  or_reduce(xu_derat_rf0_val) or clkg_ctl_override_q;
ex1_stg_act_d  <=  rf1_stg_act_q or xu_derat_rf1_act or xu_derat_rf1_ra_eq_ea;
ex2_stg_act_d  <=  ex1_stg_act_q;
ex3_stg_act_d  <=  ex2_stg_act_q;
ex4_stg_act_d  <=  ex3_stg_act_q;
ex5_stg_act_d  <=  ex4_stg_act_q;
ex6_stg_act_d  <=  ex5_stg_act_q;
ex7_stg_act_d  <=  ex6_stg_act_q;
ex2_cmp_data_act  <=  ex2_stg_act_q and not(an_ac_grffence_en_dc);
ex3_rd_data_act   <=  ex3_stg_act_q and not(an_ac_grffence_en_dc);
ex3_data_out_act  <=  ex3_stg_act_q and not(an_ac_grffence_en_dc);
ex3_grffence_act  <=  ex3_stg_act_q and not(an_ac_grffence_en_dc);
ex2_or_ex3_grffence_act  <=  (ex2_stg_act_q or ex3_stg_act_q) and not(an_ac_grffence_en_dc);
ex3_to_ex6_grffence_act  <=  (ex3_stg_act_q or ex4_stg_act_q or ex5_stg_act_q or ex6_stg_act_q) and not(an_ac_grffence_en_dc);
entry_valid_act  <=  not an_ac_grffence_en_dc;
entry_match_act  <=  not an_ac_grffence_en_dc;
not_grffence_act  <=  not an_ac_grffence_en_dc;
lru_update_act  <=  ex6_stg_act_q or ex7_stg_act_q or lru_update_event_q(8) or lru_update_event_q(9) or flash_invalidate or ex6_deratwe_ws3;
snoop_act  <=  snoop_act_q or clkg_ctl_override_q;
notlb_grffence_act  <=  (not(ccr2_notlb_q) or clkg_ctl_override_q) and not(an_ac_grffence_en_dc);
debug_grffence_act  <=   trace_bus_enable_q and not(an_ac_grffence_en_dc);
-----------------------------------------------------------------------
-- Logic
-----------------------------------------------------------------------
tiup  <=  '1';
init_alias  <=  pc_xu_init_reset_q;
-- timing latches for the reloads
tlb_rel_val_d   <=  mm_xu_derat_rel_val;
tlb_rel_data_d  <=  mm_xu_derat_rel_data;
tlb_rel_act_d   <=  mm_xu_derat_rel_data(eratpos_relsoon);
tlb_rel_act     <=  (tlb_rel_act_q and not(ccr2_notlb_q)) or clkg_ctl_override_q;
-- timing latches for the ifrat delusional paranoia real mode
ccr2_frat_paranoia_d(0 TO 8) <=   xu_derat_spr_ccr2_dfratsc;
ccr2_frat_paranoia_d(9) <=   xu_derat_spr_ccr2_dfrat;
ccr2_frat_paranoia_d(10) <=   xu_derat_rf1_ra_eq_ea;
ccr2_frat_paranoia_d(11) <=   ccr2_frat_paranoia_q(10);
xu_derat_rf1_is_icbtlslc  <=  xu_derat_rf1_icbtls_instr or xu_derat_rf1_icblc_instr;
rf1_valid_d  <=  xu_derat_rf0_val and not(xu_derat_rf0_n_flush);
rf1_ttype_d  <=  xu_derat_rf0_is_extload & xu_derat_rf0_is_extstore;
rf1_eplc_epr  <=  (xu_derat_eplc0_epr and rf1_valid_q(0)) or   
                (xu_derat_eplc1_epr and rf1_valid_q(1)) or
                (xu_derat_eplc2_epr and rf1_valid_q(2)) or
                (xu_derat_eplc3_epr and rf1_valid_q(3));
rf1_epsc_epr  <=  (xu_derat_epsc0_epr and rf1_valid_q(0)) or   
                (xu_derat_epsc1_epr and rf1_valid_q(1)) or
                (xu_derat_epsc2_epr and rf1_valid_q(2)) or
                (xu_derat_epsc3_epr and rf1_valid_q(3));
rf1_eplc_egs  <=  (xu_derat_eplc0_egs and rf1_valid_q(0)) or   
                (xu_derat_eplc1_egs and rf1_valid_q(1)) or
                (xu_derat_eplc2_egs and rf1_valid_q(2)) or
                (xu_derat_eplc3_egs and rf1_valid_q(3));
rf1_epsc_egs  <=  (xu_derat_epsc0_egs and rf1_valid_q(0)) or   
                (xu_derat_epsc1_egs and rf1_valid_q(1)) or
                (xu_derat_epsc2_egs and rf1_valid_q(2)) or
                (xu_derat_epsc3_egs and rf1_valid_q(3));
rf1_eplc_eas  <=  (xu_derat_eplc0_eas and rf1_valid_q(0)) or   
                (xu_derat_eplc1_eas and rf1_valid_q(1)) or
                (xu_derat_eplc2_eas and rf1_valid_q(2)) or
                (xu_derat_eplc3_eas and rf1_valid_q(3));
rf1_epsc_eas  <=  (xu_derat_epsc0_eas and rf1_valid_q(0)) or   
                (xu_derat_epsc1_eas and rf1_valid_q(1)) or
                (xu_derat_epsc2_eas and rf1_valid_q(2)) or
                (xu_derat_epsc3_eas and rf1_valid_q(3));
rf1_mmucr0_gs  <=  (mm_xu_derat_mmucr0_0(2) and rf1_valid_q(0)) or 
                 (mm_xu_derat_mmucr0_1(2) and rf1_valid_q(1)) or 
                 (mm_xu_derat_mmucr0_2(2) and rf1_valid_q(2)) or
                 (mm_xu_derat_mmucr0_3(2) and rf1_valid_q(3));
rf1_mmucr0_ts  <=  (mm_xu_derat_mmucr0_0(3) and rf1_valid_q(0)) or
                 (mm_xu_derat_mmucr0_1(3) and rf1_valid_q(1)) or
                 (mm_xu_derat_mmucr0_2(3) and rf1_valid_q(2)) or
                 (mm_xu_derat_mmucr0_3(3) and rf1_valid_q(3));
rf1_eplc_epid  <=  (xu_derat_eplc0_epid(50 to 63) and (0 to 13 => rf1_valid_q(0))) or   
                (xu_derat_eplc1_epid(50 to 63) and (0 to 13 => rf1_valid_q(1))) or
                (xu_derat_eplc2_epid(50 to 63) and (0 to 13 => rf1_valid_q(2))) or
                (xu_derat_eplc3_epid(50 to 63) and (0 to 13 => rf1_valid_q(3)));
rf1_epsc_epid  <=  (xu_derat_epsc0_epid(50 to 63) and (0 to 13 => rf1_valid_q(0))) or   
                (xu_derat_epsc1_epid(50 to 63) and (0 to 13 => rf1_valid_q(1))) or
                (xu_derat_epsc2_epid(50 to 63) and (0 to 13 => rf1_valid_q(2))) or
                (xu_derat_epsc3_epid(50 to 63) and (0 to 13 => rf1_valid_q(3)));
rf1_mmucr0_pid  <=  (mm_xu_derat_mmucr0_0(6 to 19) and (0 to 13 => rf1_valid_q(0))) or   
                  (mm_xu_derat_mmucr0_1(6 to 19) and (0 to 13 => rf1_valid_q(1))) or
                  (mm_xu_derat_mmucr0_2(6 to 19) and (0 to 13 => rf1_valid_q(2))) or
                  (mm_xu_derat_mmucr0_3(6 to 19) and (0 to 13 => rf1_valid_q(3)));
rf1_pid  <=  (mm_xu_derat_pid0 and (0 to 13 => rf1_valid_q(0))) or   
           (mm_xu_derat_pid1 and (0 to 13 => rf1_valid_q(1))) or
           (mm_xu_derat_pid2 and (0 to 13 => rf1_valid_q(2))) or
           (mm_xu_derat_pid3 and (0 to 13 => rf1_valid_q(3)));
---------------------------------------
-- ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
ex1_valid_d  <=  rf1_valid_q and not(xu_derat_rf1_n_flush);
ex1_ttype_d  <=  xu_derat_rf1_is_eratre & xu_derat_rf1_is_eratwe & xu_derat_rf1_is_eratsx & xu_derat_rf1_is_eratilx &
                xu_derat_rf1_is_load & xu_derat_rf1_is_store & '0' & '0' & 
                xu_derat_rf1_is_icbtlslc & xu_derat_rf1_is_touch & rf1_ttype_q(10) & rf1_ttype_q(11);
ex1_ws_d  <=  xu_derat_rf1_ws;
ex1_rs_is_d  <=  (others => '0');
ex1_ra_entry_d  <=  (others => '0');
-- state: 0:pr 1:gs 2:ds 3:cm
ex1_state_d(0) <=  rf1_eplc_epr when rf1_ttype_q(10)='1' 
              else rf1_epsc_epr when rf1_ttype_q(11)='1'
              else or_reduce(xu_derat_msr_pr and rf1_valid_q);
ex1_state_d(1) <=  rf1_eplc_egs when rf1_ttype_q(10)='1' 
              else rf1_epsc_egs when rf1_ttype_q(11)='1'
              else rf1_mmucr0_gs when xu_derat_rf1_is_eratsx='1'
              else or_reduce(xu_derat_msr_hv and rf1_valid_q);
ex1_state_d(2) <=  rf1_eplc_eas when rf1_ttype_q(10)='1' 
              else rf1_epsc_eas when rf1_ttype_q(11)='1'
              else rf1_mmucr0_ts when xu_derat_rf1_is_eratsx='1'
              else or_reduce(xu_derat_msr_ds and rf1_valid_q);
ex1_state_d(3) <=  or_reduce(xu_derat_msr_cm and rf1_valid_q);
-- mmucr0: 0:1-ECL|TID_NZ, 2:3-tgs/ts, 4:5-tlbsel, 6:19-tid,
ex1_extclass_d  <=  mm_xu_derat_mmucr0_1(0 to 1) when rf1_valid_q(1)='1' 
             else mm_xu_derat_mmucr0_2(0 to 1) when rf1_valid_q(2)='1'
              else mm_xu_derat_mmucr0_3(0 to 1) when rf1_valid_q(3)='1'
               else mm_xu_derat_mmucr0_0(0 to 1);
ex1_tlbsel_d  <=  mm_xu_derat_mmucr0_1(4 to 5) when rf1_valid_q(1)='1' 
             else mm_xu_derat_mmucr0_2(4 to 5) when rf1_valid_q(2)='1'
              else mm_xu_derat_mmucr0_3(4 to 5) when rf1_valid_q(3)='1'
               else mm_xu_derat_mmucr0_0(4 to 5);
ex1_pid_d  <=  rf1_eplc_epid when rf1_ttype_q(10)='1' 
         else rf1_epsc_epid when rf1_ttype_q(11)='1' 
          else rf1_mmucr0_pid when xu_derat_rf1_is_eratsx='1' 
           else rf1_pid;
ex1_deratre  <=  or_reduce(ex1_valid_q) and ex1_ttype_q(0) and ex1_tlbsel_q(0) and ex1_tlbsel_q(1);
ex1_deratwe  <=  or_reduce(ex1_valid_q) and ex1_ttype_q(1) and ex1_tlbsel_q(0) and ex1_tlbsel_q(1);
ex1_deratsx  <=  or_reduce(ex1_valid_q) and ex1_ttype_q(2) and ex1_tlbsel_q(0) and ex1_tlbsel_q(1);
---------------------------------------
ex2_valid_d  <=  ex1_valid_q and not(xu_derat_ex1_n_flush);
ex2_ttype_d(0 TO ttype_width-7) <=  ex1_ttype_q(0 to ttype_width-7);
ex2_ttype_d(ttype_width-6 TO ttype_width-5) <=  xu_derat_ex1_is_csync & xu_derat_ex1_is_isync;
ex2_ttype_d(ttype_width-4 TO ttype_width-1) <=  ex1_ttype_q(ttype_width-4 to ttype_width-1);
ex2_ws_d  <=  ex1_ws_q;
ex2_rs_is_d  <=  xu_derat_ex1_rs_is;
ex2_ra_entry_d  <=  xu_derat_ex1_ra_entry;
ex2_state_d  <=  ex1_state_q;
ex2_pid_d  <=  ex1_pid_q;
ex2_extclass_d  <=  ex1_extclass_q;
ex2_tlbsel_d  <=  ex1_tlbsel_q;
---------------------------------------
-- ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
ex3_valid_d  <=  ex2_valid_q and not(xu_derat_ex2_n_flush);
ex3_ttype_d  <=  ex2_ttype_q;
ex3_ws_d  <=  ex2_ws_q;
ex3_rs_is_d  <=  ex2_rs_is_q;
ex3_ra_entry_d  <=  ex2_ra_entry_q;
ex3_tlbsel_d  <=  ex2_tlbsel_q;
ex3_extclass_d  <=  ex2_extclass_q;
-- state: 0:pr 1:gs 2:ds 3:cm
ex3_state_d  <=  ex2_state_q;
ex3_pid_d  <=   ex2_pid_q;
ex3_lpid_d(0 TO lpid_width-1) <=  
          ( xu_derat_eplc0_elpid(40 to 47) and (40 to 47 => (ex2_valid_q(0) and ex2_ttype_q(10))) ) 
        or ( xu_derat_eplc1_elpid(40 to 47) and (40 to 47 => (ex2_valid_q(1) and ex2_ttype_q(10))) )
         or ( xu_derat_eplc2_elpid(40 to 47) and (40 to 47 => (ex2_valid_q(2) and ex2_ttype_q(10))) )
          or ( xu_derat_eplc3_elpid(40 to 47) and (40 to 47 => (ex2_valid_q(3) and ex2_ttype_q(10))) )
           or ( xu_derat_epsc0_elpid(40 to 47) and (40 to 47 => (ex2_valid_q(0) and ex2_ttype_q(11))) ) 
            or ( xu_derat_epsc1_elpid(40 to 47) and (40 to 47 => (ex2_valid_q(1) and ex2_ttype_q(11))) )
             or ( xu_derat_epsc2_elpid(40 to 47) and (40 to 47 => (ex2_valid_q(2) and ex2_ttype_q(11))) )
              or ( xu_derat_epsc3_elpid(40 to 47) and (40 to 47 => (ex2_valid_q(3) and ex2_ttype_q(11))) );
ex3_deratwe  <=  or_reduce(ex3_valid_q) and ex3_ttype_q(1) and ex3_tlbsel_q(0) and ex3_tlbsel_q(1);
ex4_valid_d  <=  ex3_valid_q and not(xu_derat_ex3_n_flush) and not(ex3_n_flush_req_q) and not(ex3_miss_q);
ex4_ttype_d  <=  ex3_ttype_q;
ex4_ws_d  <=  ex3_ws_q;
ex4_rs_is_d  <=  ex3_rs_is_q;
ex4_ra_entry_d  <=  ex3_first_hit_entry when ex3_ttype_q(2 to 5)/="0000" else ex3_ra_entry_q;
ex4_tlbsel_d  <=  ex3_tlbsel_q;
-- muxes for tlbre and sending mmucr0 ExtClass,State,TID
ex4_extclass_d  <=  rd_cam_data(63 to 64) when (ex3_valid_q/="0000" and ex3_ttype_q(0)='1' and ex3_ws_q="00")  
         else ex3_extclass_q;
-- state: 0:pr 1:gs 2:ds 3:cm
ex4_state_d  <=  ex3_state_q(0) & rd_cam_data(65 to 66) & ex3_state_q(3) when (ex3_valid_q/="0000" and ex3_ttype_q(0)='1' and ex3_ws_q="00")  
         else ex3_state_q;
ex4_pid_d  <=  rd_cam_data(61 to 62) & rd_cam_data(57 to 60) & rd_cam_data(67 to 74)  
               when (ex3_valid_q/="0000" and ex3_ttype_q(0)='1' and ex3_ws_q="00")  
         else ex3_pid_q;
ex4_deratwe  <=  or_reduce(ex4_valid_q) and ex4_ttype_q(1) and ex4_tlbsel_q(0) and ex4_tlbsel_q(1);
---------------------------------------
ex5_valid_d  <=  ex4_valid_q and not(xu_derat_ex4_n_flush);
ex5_ws_d  <=  ex4_ws_q;
ex5_rs_is_d  <=  ex4_rs_is_q;
ex5_ra_entry_d  <=  ex4_ra_entry_q;
ex5_ttype_d  <=  ex4_ttype_q;
ex5_extclass_d  <=  ex4_extclass_q;
-- state: 0:pr 1:gs 2:ds 3:cm
ex5_state_d  <=  ex4_state_q;
ex5_pid_d  <=   ex4_pid_q;
ex5_tlbsel_d  <=  ex4_tlbsel_q;
ex5_data_in_d  <=  xu_derat_ex4_rs_data;
ex5_deratwe  <=  or_reduce(ex5_valid_q) and ex5_ttype_q(1) and ex5_tlbsel_q(0) and ex5_tlbsel_q(1);
---------------------------------------
ex6_valid_d  <=  ex5_valid_q and not(xu_derat_ex5_n_flush);
ex6_ws_d  <=  ex5_ws_q;
ex6_rs_is_d  <=  ex5_rs_is_q;
ex6_ra_entry_d  <=  ex5_ra_entry_q;
-- mmucr1: 0-DRRE, 1-REE, 2-CEE,
--         3-Disable any context sync inst from invalidating extclass=0 erat entries,
--         4-Disable isync inst from invalidating extclass=0 erat entries,
--         5:6-PEI, 7:8-DCTID|DTTID, 9-DCCD
-- ttype <= 0-eratre & 1-eratwe & 2-eratsx & 3-eratilx & 4-load & 5-store &
--          6-csync & 7-isync & 8-icbtlslc & 9-touch & 10-extload & 11-extstore;
ex6_ttype_d(0 TO 5) <=  ex5_ttype_q(0 to 5);
ex6_ttype_d(6) <=  '1' when (ex5_ttype_q(6)='1' and mmucr1_q(3)='0' and ccr2_notlb_q=MMU_Mode_Value)  
              else '0';
ex6_ttype_d(7) <=  '1' when (ex5_ttype_q(7)='1' and mmucr1_q(4)='0' and ccr2_notlb_q=MMU_Mode_Value)  
              else '0';
ex6_ttype_d(8 TO ttype_width-1) <=  ex5_ttype_q(8 to ttype_width-1);
-- mmucr0: 0:1-ECL|TID_NZ, 2:3-tgs/ts, 4:5-tlbsel, 6:19-tid,
ex6_extclass_d  <=  mm_xu_derat_mmucr0_0(0 to 1) 
                 when (ex5_valid_q="1000" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_xu_derat_mmucr0_1(0 to 1) 
                 when (ex5_valid_q="0100" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_xu_derat_mmucr0_2(0 to 1) 
                 when (ex5_valid_q="0010" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_xu_derat_mmucr0_3(0 to 1) 
                 when (ex5_valid_q="0001" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
       else ex5_extclass_q;
-- state: 0:pr 1:gs 2:ds 3:cm
ex6_state_d  <=  xu_derat_msr_pr(0) & mm_xu_derat_mmucr0_0(2 to 3) & xu_derat_msr_cm(0) 
                 when (ex5_valid_q="1000" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else xu_derat_msr_pr(1) & mm_xu_derat_mmucr0_1(2 to 3) & xu_derat_msr_cm(1) 
                 when (ex5_valid_q="0100" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else xu_derat_msr_pr(2) & mm_xu_derat_mmucr0_2(2 to 3) & xu_derat_msr_cm(2) 
                 when (ex5_valid_q="0010" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else xu_derat_msr_pr(3) & mm_xu_derat_mmucr0_3(2 to 3) & xu_derat_msr_cm(3) 
                 when (ex5_valid_q="0001" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
       else ex5_state_q;
ex6_pid_d  <=   mm_xu_derat_mmucr0_0(6 to 19) 
                 when (ex5_valid_q="1000" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_xu_derat_mmucr0_1(6 to 19) 
                 when (ex5_valid_q="0100" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_xu_derat_mmucr0_2(6 to 19) 
                 when (ex5_valid_q="0010" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_xu_derat_mmucr0_3(6 to 19) 
                 when (ex5_valid_q="0001" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
       else ex5_pid_q;
ex6_tlbsel_d  <=  mm_xu_derat_mmucr0_0(4 to 5) 
                 when (ex5_valid_q="1000" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_xu_derat_mmucr0_1(4 to 5) 
                 when (ex5_valid_q="0100" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_xu_derat_mmucr0_2(4 to 5) 
                 when (ex5_valid_q="0010" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_xu_derat_mmucr0_3(4 to 5) 
                 when (ex5_valid_q="0001" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
       else ex5_tlbsel_q;
ex6_data_in_d  <=  ex5_data_in_q;
ex6_deratwe  <=  or_reduce(ex6_valid_q) and ex6_ttype_q(1) and ex6_tlbsel_q(0) and ex6_tlbsel_q(1);
---------------------------------------
-- for flushing
ex7_valid_d  <=  ex6_valid_q;
ex7_ttype_d  <=  ex6_ttype_q;
ex7_tlbsel_d  <=  ex6_tlbsel_q;
ex7_deratwe  <=  or_reduce(ex7_valid_q) and ex7_ttype_q(1) and ex7_tlbsel_q(0) and ex7_tlbsel_q(1);
mmucr1_d  <=  mm_xu_derat_mmucr1;
-- formation of ex2 phase multihit complement signal
--
-- Final Table Listing
--      *INPUTS*==============================*OUTPUTS*==========*
--      |                                     |                  |
--      | entry_match                         |  ex2_multihit_b  |
--      | |                                   |  |               |
--      | |                                   |  |               |
--      | |                                   |  |               |
--      | |         1111111111222222222233    |  |               |
--      | 01234567890123456789012345678901    |  |               |
--      *TYPE*================================+==================+
--      | PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP    |  P               |
--      *POLARITY*--------------------------->|  +               |
--      *PHASE*------------------------------>|  T               |
--      *OPTIMIZE*--------------------------->|   A                |
--      *TERMS*===============================+==================+
--    1 | -0000000000000000000000000000000    |  1               |
--    2 | 0-000000000000000000000000000000    |  1               |
--    3 | 00-00000000000000000000000000000    |  1               |
--    4 | 000-0000000000000000000000000000    |  1               |
--    5 | 0000-000000000000000000000000000    |  1               |
--    6 | 00000-00000000000000000000000000    |  1               |
--    7 | 000000-0000000000000000000000000    |  1               |
--    8 | 0000000-000000000000000000000000    |  1               |
--    9 | 00000000-00000000000000000000000    |  1               |
--   10 | 000000000-0000000000000000000000    |  1               |
--   11 | 0000000000-000000000000000000000    |  1               |
--   12 | 00000000000-00000000000000000000    |  1               |
--   13 | 000000000000-0000000000000000000    |  1               |
--   14 | 0000000000000-000000000000000000    |  1               |
--   15 | 00000000000000-00000000000000000    |  1               |
--   16 | 000000000000000-0000000000000000    |  1               |
--   17 | 0000000000000000-000000000000000    |  1               |
--   18 | 00000000000000000-00000000000000    |  1               |
--   19 | 000000000000000000-0000000000000    |  1               |
--   20 | 0000000000000000000-000000000000    |  1               |
--   21 | 00000000000000000000-00000000000    |  1               |
--   22 | 000000000000000000000-0000000000    |  1               |
--   23 | 0000000000000000000000-000000000    |  1               |
--   24 | 00000000000000000000000-00000000    |  1               |
--   25 | 000000000000000000000000-0000000    |  1               |
--   26 | 0000000000000000000000000-000000    |  1               |
--   27 | 00000000000000000000000000-00000    |  1               |
--   28 | 000000000000000000000000000-0000    |  1               |
--   29 | 0000000000000000000000000000-000    |  1               |
--   30 | 00000000000000000000000000000-00    |  1               |
--   31 | 000000000000000000000000000000-0    |  1               |
--   32 | 0000000000000000000000000000000-    |  1               |
--      *========================================================*
--
-- Table EX2_MULTIHIT_B Signal Assignments for Product Terms
MQQ1:EX2_MULTIHIT_B_PT(1) <=
    Eq(( ENTRY_MATCH(1) & ENTRY_MATCH(2) & 
    ENTRY_MATCH(3) & ENTRY_MATCH(4) & 
    ENTRY_MATCH(5) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ2:EX2_MULTIHIT_B_PT(2) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(2) & 
    ENTRY_MATCH(3) & ENTRY_MATCH(4) & 
    ENTRY_MATCH(5) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ3:EX2_MULTIHIT_B_PT(3) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(3) & ENTRY_MATCH(4) & 
    ENTRY_MATCH(5) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ4:EX2_MULTIHIT_B_PT(4) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(4) & 
    ENTRY_MATCH(5) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ5:EX2_MULTIHIT_B_PT(5) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(5) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ6:EX2_MULTIHIT_B_PT(6) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ7:EX2_MULTIHIT_B_PT(7) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ8:EX2_MULTIHIT_B_PT(8) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ9:EX2_MULTIHIT_B_PT(9) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ10:EX2_MULTIHIT_B_PT(10) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ11:EX2_MULTIHIT_B_PT(11) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ12:EX2_MULTIHIT_B_PT(12) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ13:EX2_MULTIHIT_B_PT(13) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ14:EX2_MULTIHIT_B_PT(14) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ15:EX2_MULTIHIT_B_PT(15) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(15) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ16:EX2_MULTIHIT_B_PT(16) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(16) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ17:EX2_MULTIHIT_B_PT(17) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(17) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ18:EX2_MULTIHIT_B_PT(18) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(18) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ19:EX2_MULTIHIT_B_PT(19) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(19) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ20:EX2_MULTIHIT_B_PT(20) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(20) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ21:EX2_MULTIHIT_B_PT(21) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(21) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ22:EX2_MULTIHIT_B_PT(22) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(22) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ23:EX2_MULTIHIT_B_PT(23) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(23) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ24:EX2_MULTIHIT_B_PT(24) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(24) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ25:EX2_MULTIHIT_B_PT(25) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(25) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ26:EX2_MULTIHIT_B_PT(26) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(26) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ27:EX2_MULTIHIT_B_PT(27) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(27) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ28:EX2_MULTIHIT_B_PT(28) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) & ENTRY_MATCH(28) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ29:EX2_MULTIHIT_B_PT(29) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) & ENTRY_MATCH(27) & 
    ENTRY_MATCH(29) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ30:EX2_MULTIHIT_B_PT(30) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) & ENTRY_MATCH(27) & 
    ENTRY_MATCH(28) & ENTRY_MATCH(30) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ31:EX2_MULTIHIT_B_PT(31) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) & ENTRY_MATCH(27) & 
    ENTRY_MATCH(28) & ENTRY_MATCH(29) & 
    ENTRY_MATCH(31) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
MQQ32:EX2_MULTIHIT_B_PT(32) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) & ENTRY_MATCH(27) & 
    ENTRY_MATCH(28) & ENTRY_MATCH(29) & 
    ENTRY_MATCH(30) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000000"));
-- Table EX2_MULTIHIT_B Signal Assignments for Outputs
MQQ33:EX2_MULTIHIT_B <= 
    (EX2_MULTIHIT_B_PT(1) OR EX2_MULTIHIT_B_PT(2)
     OR EX2_MULTIHIT_B_PT(3) OR EX2_MULTIHIT_B_PT(4)
     OR EX2_MULTIHIT_B_PT(5) OR EX2_MULTIHIT_B_PT(6)
     OR EX2_MULTIHIT_B_PT(7) OR EX2_MULTIHIT_B_PT(8)
     OR EX2_MULTIHIT_B_PT(9) OR EX2_MULTIHIT_B_PT(10)
     OR EX2_MULTIHIT_B_PT(11) OR EX2_MULTIHIT_B_PT(12)
     OR EX2_MULTIHIT_B_PT(13) OR EX2_MULTIHIT_B_PT(14)
     OR EX2_MULTIHIT_B_PT(15) OR EX2_MULTIHIT_B_PT(16)
     OR EX2_MULTIHIT_B_PT(17) OR EX2_MULTIHIT_B_PT(18)
     OR EX2_MULTIHIT_B_PT(19) OR EX2_MULTIHIT_B_PT(20)
     OR EX2_MULTIHIT_B_PT(21) OR EX2_MULTIHIT_B_PT(22)
     OR EX2_MULTIHIT_B_PT(23) OR EX2_MULTIHIT_B_PT(24)
     OR EX2_MULTIHIT_B_PT(25) OR EX2_MULTIHIT_B_PT(26)
     OR EX2_MULTIHIT_B_PT(27) OR EX2_MULTIHIT_B_PT(28)
     OR EX2_MULTIHIT_B_PT(29) OR EX2_MULTIHIT_B_PT(30)
     OR EX2_MULTIHIT_B_PT(31) OR EX2_MULTIHIT_B_PT(32)
    );

ex3_multihit_b_pt_d  <=  ex2_multihit_b_pt;
ex3_multihit_enab  <=  not or_reduce(ex3_multihit_b_pt_q);
-- Encoder for the ex2 phase first hit entry number
--
-- Final Table Listing
--      *INPUTS*==============================*OUTPUTS*==============*
--      |                                     |                      |
--      | entry_match                         |  ex2_first_hit_entry |
--      | |                                   |  |                   |
--      | |                                   |  |                   |
--      | |                                   |  |                   |
--      | |         1111111111222222222233    |  |                   |
--      | 01234567890123456789012345678901    |  01234               |
--      *TYPE*================================+======================+
--      | PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP    |  PPPPP               |
--      *POLARITY*--------------------------->|  +++++               |
--      *PHASE*------------------------------>|  TTTTT               |
--      *OPTIMIZE*--------------------------->|   AAAAA                |
--      *TERMS*===============================+======================+
--    1 | 00000000000000000000000000000001    |  11111               |
--    2 | 0000000000000000000000000000001-    |  1111.               |
--    3 | 000000000000000000000000000001--    |  111.1               |
--    4 | 00000000000000000000000000001---    |  111..               |
--    5 | 0000000000000000000000000001----    |  11.11               |
--    6 | 000000000000000000000000001-----    |  11.1.               |
--    7 | 00000000000000000000000001------    |  11..1               |
--    8 | 0000000000000000000000001-------    |  11...               |
--    9 | 000000000000000000000001--------    |  1.111               |
--   10 | 00000000000000000000001---------    |  1.11.               |
--   11 | 0000000000000000000001----------    |  1.1.1               |
--   12 | 000000000000000000001-----------    |  1.1..               |
--   13 | 00000000000000000001------------    |  1..11               |
--   14 | 0000000000000000001-------------    |  1..1.               |
--   15 | 000000000000000001--------------    |  1...1               |
--   16 | 00000000000000001---------------    |  1....               |
--   17 | 0000000000000001----------------    |  .1111               |
--   18 | 000000000000001-----------------    |  .111.               |
--   19 | 00000000000001------------------    |  .11.1               |
--   20 | 0000000000001-------------------    |  .11..               |
--   21 | 000000000001--------------------    |  .1.11               |
--   22 | 00000000001---------------------    |  .1.1.               |
--   23 | 0000000001----------------------    |  .1..1               |
--   24 | 000000001-----------------------    |  .1...               |
--   25 | 00000001------------------------    |  ..111               |
--   26 | 0000001-------------------------    |  ..11.               |
--   27 | 000001--------------------------    |  ..1.1               |
--   28 | 00001---------------------------    |  ..1..               |
--   29 | 0001----------------------------    |  ...11               |
--   30 | 001-----------------------------    |  ...1.               |
--   31 | 01------------------------------    |  ....1               |
--      *============================================================*
--
-- Table EX2_FIRST_HIT_ENTRY Signal Assignments for Product Terms
MQQ34:EX2_FIRST_HIT_ENTRY_PT(1) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) & ENTRY_MATCH(27) & 
    ENTRY_MATCH(28) & ENTRY_MATCH(29) & 
    ENTRY_MATCH(30) & ENTRY_MATCH(31)
     ) , STD_ULOGIC_VECTOR'("00000000000000000000000000000001"));
MQQ35:EX2_FIRST_HIT_ENTRY_PT(2) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) & ENTRY_MATCH(27) & 
    ENTRY_MATCH(28) & ENTRY_MATCH(29) & 
    ENTRY_MATCH(30) ) , STD_ULOGIC_VECTOR'("0000000000000000000000000000001"));
MQQ36:EX2_FIRST_HIT_ENTRY_PT(3) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) & ENTRY_MATCH(27) & 
    ENTRY_MATCH(28) & ENTRY_MATCH(29)
     ) , STD_ULOGIC_VECTOR'("000000000000000000000000000001"));
MQQ37:EX2_FIRST_HIT_ENTRY_PT(4) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) & ENTRY_MATCH(27) & 
    ENTRY_MATCH(28) ) , STD_ULOGIC_VECTOR'("00000000000000000000000000001"));
MQQ38:EX2_FIRST_HIT_ENTRY_PT(5) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) & ENTRY_MATCH(27)
     ) , STD_ULOGIC_VECTOR'("0000000000000000000000000001"));
MQQ39:EX2_FIRST_HIT_ENTRY_PT(6) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25) & 
    ENTRY_MATCH(26) ) , STD_ULOGIC_VECTOR'("000000000000000000000000001"));
MQQ40:EX2_FIRST_HIT_ENTRY_PT(7) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) & ENTRY_MATCH(25)
     ) , STD_ULOGIC_VECTOR'("00000000000000000000000001"));
MQQ41:EX2_FIRST_HIT_ENTRY_PT(8) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23) & 
    ENTRY_MATCH(24) ) , STD_ULOGIC_VECTOR'("0000000000000000000000001"));
MQQ42:EX2_FIRST_HIT_ENTRY_PT(9) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) & ENTRY_MATCH(23)
     ) , STD_ULOGIC_VECTOR'("000000000000000000000001"));
MQQ43:EX2_FIRST_HIT_ENTRY_PT(10) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21) & 
    ENTRY_MATCH(22) ) , STD_ULOGIC_VECTOR'("00000000000000000000001"));
MQQ44:EX2_FIRST_HIT_ENTRY_PT(11) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) & ENTRY_MATCH(21)
     ) , STD_ULOGIC_VECTOR'("0000000000000000000001"));
MQQ45:EX2_FIRST_HIT_ENTRY_PT(12) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19) & 
    ENTRY_MATCH(20) ) , STD_ULOGIC_VECTOR'("000000000000000000001"));
MQQ46:EX2_FIRST_HIT_ENTRY_PT(13) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) & ENTRY_MATCH(19)
     ) , STD_ULOGIC_VECTOR'("00000000000000000001"));
MQQ47:EX2_FIRST_HIT_ENTRY_PT(14) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17) & 
    ENTRY_MATCH(18) ) , STD_ULOGIC_VECTOR'("0000000000000000001"));
MQQ48:EX2_FIRST_HIT_ENTRY_PT(15) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) & ENTRY_MATCH(17)
     ) , STD_ULOGIC_VECTOR'("000000000000000001"));
MQQ49:EX2_FIRST_HIT_ENTRY_PT(16) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15) & 
    ENTRY_MATCH(16) ) , STD_ULOGIC_VECTOR'("00000000000000001"));
MQQ50:EX2_FIRST_HIT_ENTRY_PT(17) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15)
     ) , STD_ULOGIC_VECTOR'("0000000000000001"));
MQQ51:EX2_FIRST_HIT_ENTRY_PT(18) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) ) , STD_ULOGIC_VECTOR'("000000000000001"));
MQQ52:EX2_FIRST_HIT_ENTRY_PT(19) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13)
     ) , STD_ULOGIC_VECTOR'("00000000000001"));
MQQ53:EX2_FIRST_HIT_ENTRY_PT(20) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) ) , STD_ULOGIC_VECTOR'("0000000000001"));
MQQ54:EX2_FIRST_HIT_ENTRY_PT(21) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11)
     ) , STD_ULOGIC_VECTOR'("000000000001"));
MQQ55:EX2_FIRST_HIT_ENTRY_PT(22) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) ) , STD_ULOGIC_VECTOR'("00000000001"));
MQQ56:EX2_FIRST_HIT_ENTRY_PT(23) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9)
     ) , STD_ULOGIC_VECTOR'("0000000001"));
MQQ57:EX2_FIRST_HIT_ENTRY_PT(24) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) ) , STD_ULOGIC_VECTOR'("000000001"));
MQQ58:EX2_FIRST_HIT_ENTRY_PT(25) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7)
     ) , STD_ULOGIC_VECTOR'("00000001"));
MQQ59:EX2_FIRST_HIT_ENTRY_PT(26) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) ) , STD_ULOGIC_VECTOR'("0000001"));
MQQ60:EX2_FIRST_HIT_ENTRY_PT(27) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5)
     ) , STD_ULOGIC_VECTOR'("000001"));
MQQ61:EX2_FIRST_HIT_ENTRY_PT(28) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) ) , STD_ULOGIC_VECTOR'("00001"));
MQQ62:EX2_FIRST_HIT_ENTRY_PT(29) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ63:EX2_FIRST_HIT_ENTRY_PT(30) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) ) , STD_ULOGIC_VECTOR'("001"));
MQQ64:EX2_FIRST_HIT_ENTRY_PT(31) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1)
     ) , STD_ULOGIC_VECTOR'("01"));
-- Table EX2_FIRST_HIT_ENTRY Signal Assignments for Outputs
MQQ65:EX2_FIRST_HIT_ENTRY(0) <= 
    (EX2_FIRST_HIT_ENTRY_PT(1) OR EX2_FIRST_HIT_ENTRY_PT(2)
     OR EX2_FIRST_HIT_ENTRY_PT(3) OR EX2_FIRST_HIT_ENTRY_PT(4)
     OR EX2_FIRST_HIT_ENTRY_PT(5) OR EX2_FIRST_HIT_ENTRY_PT(6)
     OR EX2_FIRST_HIT_ENTRY_PT(7) OR EX2_FIRST_HIT_ENTRY_PT(8)
     OR EX2_FIRST_HIT_ENTRY_PT(9) OR EX2_FIRST_HIT_ENTRY_PT(10)
     OR EX2_FIRST_HIT_ENTRY_PT(11) OR EX2_FIRST_HIT_ENTRY_PT(12)
     OR EX2_FIRST_HIT_ENTRY_PT(13) OR EX2_FIRST_HIT_ENTRY_PT(14)
     OR EX2_FIRST_HIT_ENTRY_PT(15) OR EX2_FIRST_HIT_ENTRY_PT(16)
    );
MQQ66:EX2_FIRST_HIT_ENTRY(1) <= 
    (EX2_FIRST_HIT_ENTRY_PT(1) OR EX2_FIRST_HIT_ENTRY_PT(2)
     OR EX2_FIRST_HIT_ENTRY_PT(3) OR EX2_FIRST_HIT_ENTRY_PT(4)
     OR EX2_FIRST_HIT_ENTRY_PT(5) OR EX2_FIRST_HIT_ENTRY_PT(6)
     OR EX2_FIRST_HIT_ENTRY_PT(7) OR EX2_FIRST_HIT_ENTRY_PT(8)
     OR EX2_FIRST_HIT_ENTRY_PT(17) OR EX2_FIRST_HIT_ENTRY_PT(18)
     OR EX2_FIRST_HIT_ENTRY_PT(19) OR EX2_FIRST_HIT_ENTRY_PT(20)
     OR EX2_FIRST_HIT_ENTRY_PT(21) OR EX2_FIRST_HIT_ENTRY_PT(22)
     OR EX2_FIRST_HIT_ENTRY_PT(23) OR EX2_FIRST_HIT_ENTRY_PT(24)
    );
MQQ67:EX2_FIRST_HIT_ENTRY(2) <= 
    (EX2_FIRST_HIT_ENTRY_PT(1) OR EX2_FIRST_HIT_ENTRY_PT(2)
     OR EX2_FIRST_HIT_ENTRY_PT(3) OR EX2_FIRST_HIT_ENTRY_PT(4)
     OR EX2_FIRST_HIT_ENTRY_PT(9) OR EX2_FIRST_HIT_ENTRY_PT(10)
     OR EX2_FIRST_HIT_ENTRY_PT(11) OR EX2_FIRST_HIT_ENTRY_PT(12)
     OR EX2_FIRST_HIT_ENTRY_PT(17) OR EX2_FIRST_HIT_ENTRY_PT(18)
     OR EX2_FIRST_HIT_ENTRY_PT(19) OR EX2_FIRST_HIT_ENTRY_PT(20)
     OR EX2_FIRST_HIT_ENTRY_PT(25) OR EX2_FIRST_HIT_ENTRY_PT(26)
     OR EX2_FIRST_HIT_ENTRY_PT(27) OR EX2_FIRST_HIT_ENTRY_PT(28)
    );
MQQ68:EX2_FIRST_HIT_ENTRY(3) <= 
    (EX2_FIRST_HIT_ENTRY_PT(1) OR EX2_FIRST_HIT_ENTRY_PT(2)
     OR EX2_FIRST_HIT_ENTRY_PT(5) OR EX2_FIRST_HIT_ENTRY_PT(6)
     OR EX2_FIRST_HIT_ENTRY_PT(9) OR EX2_FIRST_HIT_ENTRY_PT(10)
     OR EX2_FIRST_HIT_ENTRY_PT(13) OR EX2_FIRST_HIT_ENTRY_PT(14)
     OR EX2_FIRST_HIT_ENTRY_PT(17) OR EX2_FIRST_HIT_ENTRY_PT(18)
     OR EX2_FIRST_HIT_ENTRY_PT(21) OR EX2_FIRST_HIT_ENTRY_PT(22)
     OR EX2_FIRST_HIT_ENTRY_PT(25) OR EX2_FIRST_HIT_ENTRY_PT(26)
     OR EX2_FIRST_HIT_ENTRY_PT(29) OR EX2_FIRST_HIT_ENTRY_PT(30)
    );
MQQ69:EX2_FIRST_HIT_ENTRY(4) <= 
    (EX2_FIRST_HIT_ENTRY_PT(1) OR EX2_FIRST_HIT_ENTRY_PT(3)
     OR EX2_FIRST_HIT_ENTRY_PT(5) OR EX2_FIRST_HIT_ENTRY_PT(7)
     OR EX2_FIRST_HIT_ENTRY_PT(9) OR EX2_FIRST_HIT_ENTRY_PT(11)
     OR EX2_FIRST_HIT_ENTRY_PT(13) OR EX2_FIRST_HIT_ENTRY_PT(15)
     OR EX2_FIRST_HIT_ENTRY_PT(17) OR EX2_FIRST_HIT_ENTRY_PT(19)
     OR EX2_FIRST_HIT_ENTRY_PT(21) OR EX2_FIRST_HIT_ENTRY_PT(23)
     OR EX2_FIRST_HIT_ENTRY_PT(25) OR EX2_FIRST_HIT_ENTRY_PT(27)
     OR EX2_FIRST_HIT_ENTRY_PT(29) OR EX2_FIRST_HIT_ENTRY_PT(31)
    );

ex3_first_hit_entry_pt_d  <=  ex2_first_hit_entry_pt;
ex3_first_hit_entry(0) <=  
    (ex3_first_hit_entry_pt_q(1) or ex3_first_hit_entry_pt_q(2)
     or ex3_first_hit_entry_pt_q(3) or ex3_first_hit_entry_pt_q(4)
     or ex3_first_hit_entry_pt_q(5) or ex3_first_hit_entry_pt_q(6)
     or ex3_first_hit_entry_pt_q(7) or ex3_first_hit_entry_pt_q(8)
     or ex3_first_hit_entry_pt_q(9) or ex3_first_hit_entry_pt_q(10)
     or ex3_first_hit_entry_pt_q(11) or ex3_first_hit_entry_pt_q(12)
     or ex3_first_hit_entry_pt_q(13) or ex3_first_hit_entry_pt_q(14)
     or ex3_first_hit_entry_pt_q(15) or ex3_first_hit_entry_pt_q(16));
ex3_first_hit_entry(1) <=  
    (ex3_first_hit_entry_pt_q(1) or ex3_first_hit_entry_pt_q(2)
     or ex3_first_hit_entry_pt_q(3) or ex3_first_hit_entry_pt_q(4)
     or ex3_first_hit_entry_pt_q(5) or ex3_first_hit_entry_pt_q(6)
     or ex3_first_hit_entry_pt_q(7) or ex3_first_hit_entry_pt_q(8)
     or ex3_first_hit_entry_pt_q(17) or ex3_first_hit_entry_pt_q(18)
     or ex3_first_hit_entry_pt_q(19) or ex3_first_hit_entry_pt_q(20)
     or ex3_first_hit_entry_pt_q(21) or ex3_first_hit_entry_pt_q(22)
     or ex3_first_hit_entry_pt_q(23) or ex3_first_hit_entry_pt_q(24));
ex3_first_hit_entry(2) <=  
    (ex3_first_hit_entry_pt_q(1) or ex3_first_hit_entry_pt_q(2)
     or ex3_first_hit_entry_pt_q(3) or ex3_first_hit_entry_pt_q(4)
     or ex3_first_hit_entry_pt_q(9) or ex3_first_hit_entry_pt_q(10)
     or ex3_first_hit_entry_pt_q(11) or ex3_first_hit_entry_pt_q(12)
     or ex3_first_hit_entry_pt_q(17) or ex3_first_hit_entry_pt_q(18)
     or ex3_first_hit_entry_pt_q(19) or ex3_first_hit_entry_pt_q(20)
     or ex3_first_hit_entry_pt_q(25) or ex3_first_hit_entry_pt_q(26)
     or ex3_first_hit_entry_pt_q(27) or ex3_first_hit_entry_pt_q(28));
ex3_first_hit_entry(3) <=  
    (ex3_first_hit_entry_pt_q(1) or ex3_first_hit_entry_pt_q(2)
     or ex3_first_hit_entry_pt_q(5) or ex3_first_hit_entry_pt_q(6)
     or ex3_first_hit_entry_pt_q(9) or ex3_first_hit_entry_pt_q(10)
     or ex3_first_hit_entry_pt_q(13) or ex3_first_hit_entry_pt_q(14)
     or ex3_first_hit_entry_pt_q(17) or ex3_first_hit_entry_pt_q(18)
     or ex3_first_hit_entry_pt_q(21) or ex3_first_hit_entry_pt_q(22)
     or ex3_first_hit_entry_pt_q(25) or ex3_first_hit_entry_pt_q(26)
     or ex3_first_hit_entry_pt_q(29) or ex3_first_hit_entry_pt_q(30));
ex3_first_hit_entry(4) <=  
    (ex3_first_hit_entry_pt_q(1) or ex3_first_hit_entry_pt_q(3)
     or ex3_first_hit_entry_pt_q(5) or ex3_first_hit_entry_pt_q(7)
     or ex3_first_hit_entry_pt_q(9) or ex3_first_hit_entry_pt_q(11)
     or ex3_first_hit_entry_pt_q(13) or ex3_first_hit_entry_pt_q(15)
     or ex3_first_hit_entry_pt_q(17) or ex3_first_hit_entry_pt_q(19)
     or ex3_first_hit_entry_pt_q(21) or ex3_first_hit_entry_pt_q(23)
     or ex3_first_hit_entry_pt_q(25) or ex3_first_hit_entry_pt_q(27)
     or ex3_first_hit_entry_pt_q(29) or ex3_first_hit_entry_pt_q(31)
    );
-- ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
ex3_miss_d  <=  (ex2_valid_q and not(xu_derat_ex2_n_flush) and not(ex2_n_flush_req_q)) 
                  when (cam_hit='0' and ex2_ttype_q(4 to 5) /= "00" and ex2_ttype_q(9)='0' and ccr2_frat_paranoia_q(9)='0') 
      else (others => '0');
ex3_hit_d  <=  or_reduce(ex2_valid_q and not(xu_derat_ex2_n_flush) and not(ex2_n_flush_req_q)) 
                  when (cam_hit='1' and ex2_ttype_q(2 to 5) /= "0000") 
      else '0';
ex3_eratsx_data    <=  ex3_multihit_enab & ex3_hit_q & ex3_first_hit_entry;
ex3_tlbreq_d  <=  '1' when ((ex2_valid_q and not(xu_derat_ex2_n_flush) and not(ex2_n_flush_req_q) and not(hold_req))/="0000" 
                              and ex2_ttype_q(4 to 5) /= "00" and ex2_ttype_q(9)='0' and cam_hit='0' and ccr2_notlb_q=MMU_Mode_Value
                               and ccr2_frat_paranoia_q(9)='0') 
          else '0';
-- Cancel Hold Request
hold_req_reset_d(0) <=  ccr2_frat_paranoia_q(9) or xu_derat_ex2_n_flush(0)   or xu_derat_ex3_n_flush(0)   or xu_derat_ex4_n_flush(0)   or 
                        (tlb_rel_val_q(0)   and (ccr2_notlb_q=MMU_Mode_Value));
-- Hold Request due to ERAT MISS
hold_req_pot_set_d(0) <=  ex2_valid_q(0)   and not xu_derat_ex2_n_flush(0)   and not ex2_n_flush_req_q(0)   and
                          (ex2_ttype_q(4 to 5)/="00") and not ex2_ttype_q(9) and (ccr2_notlb_q=MMU_Mode_Value);
-- Hold Request due to POR
hold_req_por_d(0) <=  por_hold_req(0);
hold_req_set(0) <=  (hold_req_pot_set_q(0)   and not ex3_cam_hit_q);
hold_req(0) <=  '1' when hold_req_por_q(0)   = '1'   else
                 '0' when hold_req_reset_q(0)   = '1' else
                 '1' when hold_req_set(0)   = '1'     else
                  hold_req_q(0);
-- Cancel Hold Request
hold_req_reset_d(1) <=  ccr2_frat_paranoia_q(9) or xu_derat_ex2_n_flush(1)   or xu_derat_ex3_n_flush(1)   or xu_derat_ex4_n_flush(1)   or 
                        (tlb_rel_val_q(1)   and (ccr2_notlb_q=MMU_Mode_Value));
-- Hold Request due to ERAT MISS
hold_req_pot_set_d(1) <=  ex2_valid_q(1)   and not xu_derat_ex2_n_flush(1)   and not ex2_n_flush_req_q(1)   and
                          (ex2_ttype_q(4 to 5)/="00") and not ex2_ttype_q(9) and (ccr2_notlb_q=MMU_Mode_Value);
-- Hold Request due to POR
hold_req_por_d(1) <=  por_hold_req(1);
hold_req_set(1) <=  (hold_req_pot_set_q(1)   and not ex3_cam_hit_q);
hold_req(1) <=  '1' when hold_req_por_q(1)   = '1'   else
                 '0' when hold_req_reset_q(1)   = '1' else
                 '1' when hold_req_set(1)   = '1'     else
                  hold_req_q(1);
-- Cancel Hold Request
hold_req_reset_d(2) <=  ccr2_frat_paranoia_q(9) or xu_derat_ex2_n_flush(2)   or xu_derat_ex3_n_flush(2)   or xu_derat_ex4_n_flush(2)   or 
                        (tlb_rel_val_q(2)   and (ccr2_notlb_q=MMU_Mode_Value));
-- Hold Request due to ERAT MISS
hold_req_pot_set_d(2) <=  ex2_valid_q(2)   and not xu_derat_ex2_n_flush(2)   and not ex2_n_flush_req_q(2)   and
                          (ex2_ttype_q(4 to 5)/="00") and not ex2_ttype_q(9) and (ccr2_notlb_q=MMU_Mode_Value);
-- Hold Request due to POR
hold_req_por_d(2) <=  por_hold_req(2);
hold_req_set(2) <=  (hold_req_pot_set_q(2)   and not ex3_cam_hit_q);
hold_req(2) <=  '1' when hold_req_por_q(2)   = '1'   else
                 '0' when hold_req_reset_q(2)   = '1' else
                 '1' when hold_req_set(2)   = '1'     else
                  hold_req_q(2);
-- Cancel Hold Request
hold_req_reset_d(3) <=  ccr2_frat_paranoia_q(9) or xu_derat_ex2_n_flush(3)   or xu_derat_ex3_n_flush(3)   or xu_derat_ex4_n_flush(3)   or 
                        (tlb_rel_val_q(3)   and (ccr2_notlb_q=MMU_Mode_Value));
-- Hold Request due to ERAT MISS
hold_req_pot_set_d(3) <=  ex2_valid_q(3)   and not xu_derat_ex2_n_flush(3)   and not ex2_n_flush_req_q(3)   and
                          (ex2_ttype_q(4 to 5)/="00") and not ex2_ttype_q(9) and (ccr2_notlb_q=MMU_Mode_Value);
-- Hold Request due to POR
hold_req_por_d(3) <=  por_hold_req(3);
hold_req_set(3) <=  (hold_req_pot_set_q(3)   and not ex3_cam_hit_q);
hold_req(3) <=  '1' when hold_req_por_q(3)   = '1'   else
                 '0' when hold_req_reset_q(3)   = '1' else
                 '1' when hold_req_set(3)   = '1'     else
                  hold_req_q(3);
hold_req_d  <=  hold_req;
tlb_req_inprogress_d(0) <=  '0' when (ccr2_frat_paranoia_q(9)='1' or por_hold_req(0)='1'   or ccr2_notlb_q/=MMU_Mode_Value or tlb_rel_val_q(0)='1')   
         else  '0' when (xu_derat_ex3_n_flush(0)='0'   and ex3_valid_q(0)='1'   and hold_req(0)='0')    
         else  '1' when (ex3_tlbreq_q='1' and ex3_valid_q(0)='1'   and ccr2_notlb_q=MMU_Mode_Value) 
         else tlb_req_inprogress_q(0);
tlb_req_inprogress_d(1) <=  '0' when (ccr2_frat_paranoia_q(9)='1' or por_hold_req(1)='1'   or ccr2_notlb_q/=MMU_Mode_Value or tlb_rel_val_q(1)='1')   
         else  '0' when (xu_derat_ex3_n_flush(1)='0'   and ex3_valid_q(1)='1'   and hold_req(1)='0')    
         else  '1' when (ex3_tlbreq_q='1' and ex3_valid_q(1)='1'   and ccr2_notlb_q=MMU_Mode_Value) 
         else tlb_req_inprogress_q(1);
tlb_req_inprogress_d(2) <=  '0' when (ccr2_frat_paranoia_q(9)='1' or por_hold_req(2)='1'   or ccr2_notlb_q/=MMU_Mode_Value or tlb_rel_val_q(2)='1')   
         else  '0' when (xu_derat_ex3_n_flush(2)='0'   and ex3_valid_q(2)='1'   and hold_req(2)='0')    
         else  '1' when (ex3_tlbreq_q='1' and ex3_valid_q(2)='1'   and ccr2_notlb_q=MMU_Mode_Value) 
         else tlb_req_inprogress_q(2);
tlb_req_inprogress_d(3) <=  '0' when (ccr2_frat_paranoia_q(9)='1' or por_hold_req(3)='1'   or ccr2_notlb_q/=MMU_Mode_Value or tlb_rel_val_q(3)='1')   
         else  '0' when (xu_derat_ex3_n_flush(3)='0'   and ex3_valid_q(3)='1'   and hold_req(3)='0')    
         else  '1' when (ex3_tlbreq_q='1' and ex3_valid_q(3)='1'   and ccr2_notlb_q=MMU_Mode_Value) 
         else tlb_req_inprogress_q(3);
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--ttype: 0-eratre,   1-eratwe, 2-eratsx,   3-eratilx,
--       4-load,     5-store,  6-csync,    7-isync,
--       8-icbtlslc, 9-touch, 10-extload, 11-extstore
ex3_multihit_d  <=  (ex2_valid_q and not(xu_derat_ex2_n_flush) and not(ex2_n_flush_req_q)) when 
                      (cam_hit='1' and ex2_ttype_q(4 to 5) /= "00" and ex2_ttype_q(9)='0' and ccr2_frat_paranoia_q(9)='0') 
      else (others => '0');
ex3_parerr_d(0 TO thdid_width-1) <=  (ex2_valid_q and not(xu_derat_ex2_n_flush) and not(ex2_n_flush_req_q));
ex3_parerr_d(thdid_width) <=  (cam_hit and (ex2_ttype_q(4) or ex2_ttype_q(5)) and not ex2_ttype_q(9) and not ccr2_frat_paranoia_q(9));
ex3_parerr_d(thdid_width+1) <=  (cam_hit and ex2_ttype_q(2) and ex2_tlbsel_q(0) and ex2_tlbsel_q(1)
                                  and not(ex3_deratwe or ex4_deratwe or ex5_deratwe or ex6_deratwe or ex7_deratwe));
ex3_parerr_enab  <=  ((ex3_parerr_q(thdid_width) and (ex3_cmp_data_parerr_epn or ex3_cmp_data_parerr_rpn)) or
                   (ex3_parerr_q(thdid_width+1) and ex3_cmp_data_parerr_epn)) and not ex3_multihit_enab;
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ex4_rd_array_data_d  <=  rd_array_data;
ex4_rd_cam_data_d    <=  rd_cam_data;
ex4_parerr_d(0 TO thdid_width-1) <=  (ex3_valid_q and not(xu_derat_ex3_n_flush) and not(ex3_n_flush_req_q));
ex4_parerr_d(thdid_width) <=  (ex3_ttype_q(0) and not ex3_ws_q(0) and not ex3_ws_q(1) and ex3_tlbsel_q(0) and ex3_tlbsel_q(1)
                                  and not(ex4_deratwe or ex5_deratwe or ex6_deratwe));
ex4_parerr_d(thdid_width+1) <=  (ex3_ttype_q(0) and xor_reduce(ex3_ws_q) and ex3_tlbsel_q(0) and ex3_tlbsel_q(1)
                                  and not(ex4_deratwe or ex5_deratwe or ex6_deratwe));
ex4_parerr_enab  <=  (ex4_parerr_q(thdid_width) and ex4_rd_data_parerr_epn) or 
                   (ex4_parerr_q(thdid_width+1) and ex4_rd_data_parerr_rpn);
ex4_fir_parerr_d(0 TO thdid_width-1) <=  (ex3_valid_q and not(xu_derat_ex3_n_flush) and not(ex3_n_flush_req_q));
ex4_fir_parerr_d(thdid_width) <=  (ex3_ttype_q(0) and not ex3_ws_q(0) and not ex3_ws_q(1) and ex3_tlbsel_q(0) and ex3_tlbsel_q(1)
                                       and not(ex4_deratwe or ex5_deratwe or ex6_deratwe));
ex4_fir_parerr_d(thdid_width+1) <=  (ex3_ttype_q(0) and xor_reduce(ex3_ws_q) and ex3_tlbsel_q(0) and ex3_tlbsel_q(1) 
                                       and not(ex4_deratwe or ex5_deratwe or ex6_deratwe));
ex4_fir_parerr_d(thdid_width+2) <=  ex3_parerr_enab;
ex4_fir_parerr_enab  <=   (ex4_fir_parerr_q(thdid_width) and  ex4_rd_data_parerr_epn) or
                        (ex4_fir_parerr_q(thdid_width+1) and  ex4_rd_data_parerr_rpn) or
                         ex4_fir_parerr_q(thdid_width+2);
ex4_fir_multihit_d   <=  (ex3_multihit_q and not(xu_derat_ex3_n_flush) and not(ex3_n_flush_req_q)) when 
                          (ex3_ttype_q(4 to 5) /= "00" and ex3_ttype_q(9)='0' and ex3_multihit_enab='1') 
                 else (others => '0');
ex4_deen_d(0 TO thdid_width-1) <=  (ex3_multihit_q and not(xu_derat_ex3_n_flush) and not(ex3_n_flush_req_q)) 
                         when ((ex3_ttype_q(4)='1' or ex3_ttype_q(5)='1') and ex3_ttype_q(9)='0' and ex3_multihit_enab='1') 
      else (others => '0');
ex4_deen_d(thdid_width TO thdid_width+num_entry_log2-1) <=   ex3_eratsx_data(2 to 2+num_entry_log2-1)
                         when ((ex3_ttype_q(2)='1' or ex3_ttype_q(4)='1' or ex3_ttype_q(5)='1') and ex3_ttype_q(9)='0') 
      else ex3_ra_entry_q  
                         when (ex3_ttype_q(0)='1' and (ex3_ws_q="00" or ex3_ws_q="01" or ex3_ws_q="10") and ex3_tlbsel_q=TlbSel_DErat) 
      else (others => '0');
ex4_hit_d  <=  ex3_hit_q when or_reduce(ex3_valid_q and not(xu_derat_ex3_n_flush))='1' 
      else '0';
ex5_deen_d(0 TO thdid_width-1) <=  (ex4_deen_q(0 to thdid_width-1) and not(xu_derat_ex4_n_flush)) or
                                  (ex4_fir_parerr_q(0 to thdid_width-1) and not(xu_derat_ex4_n_flush) and (0 to thdid_width-1 => ex4_fir_parerr_enab));
ex5_deen_d(thdid_width TO thdid_width+num_entry_log2-1) <=  ex4_deen_q(thdid_width to thdid_width+num_entry_log2-1);
ex5_hit_d  <=  ex4_hit_q when or_reduce(ex4_valid_q and not(xu_derat_ex4_n_flush))='1' 
      else '0';
ex6_deen_d  <=  or_reduce(ex5_deen_q(0 to thdid_width-1)) & 
                    ex5_deen_q(thdid_width to thdid_width+num_entry_log2-1);
ex6_hit_d  <=  ex5_hit_q when or_reduce(ex5_valid_q and not(xu_derat_ex5_n_flush))='1' 
      else '0';
barrier_done_d  <=  ex6_valid_q when (ex6_ttype_q(0)='1') 
      else (others => '0');
-- 16x143 version, 42b RA
-- wr_array_data
--  0:29  - RPN
--  30:31  - R,C
--  32:35  - ResvAttr
--  36:39  - U0-U3
--  40:44  - WIMGE
--  45:46  - UX,SX
--  47:48  - UW,SW
--  49:50  - UR,SR
--  51:60  - CAM parity
--  61:67  - Array parity
ex2_dsi_d(0) <=  (ex1_ttype_q(5) and not ex1_ttype_q(8) and not ex1_ttype_q(9) and ex1_state_q(0) and not ccr2_frat_paranoia_q(9));
ex2_dsi_d(1) <=  (ex1_ttype_q(4) and not ex1_ttype_q(8) and not ex1_ttype_q(9) and ex1_state_q(0) and not ccr2_frat_paranoia_q(9));
ex2_dsi_d(2) <=  (ex1_ttype_q(4) and ex1_ttype_q(8) and not ex1_ttype_q(9) and ex1_state_q(0) and not ccr2_frat_paranoia_q(9));
ex2_dsi_d(3) <=  (ex1_ttype_q(5) and not ex1_ttype_q(8) and not ex1_ttype_q(9) and not ex1_state_q(0) and not ccr2_frat_paranoia_q(9));
ex2_dsi_d(4) <=  (ex1_ttype_q(4) and not ex1_ttype_q(8) and not ex1_ttype_q(9) and not ex1_state_q(0) and not ccr2_frat_paranoia_q(9));
ex2_dsi_d(5) <=  (ex1_ttype_q(4) and ex1_ttype_q(8) and not ex1_ttype_q(9) and not ex1_state_q(0) and not ccr2_frat_paranoia_q(9));
ex2_dsi_d(6) <=  (ex1_ttype_q(5) and  not ex1_ttype_q(9) and mmucr1_q(2) and not ccr2_frat_paranoia_q(9));
ex2_dsi_d(7) <=  (ex1_ttype_q(4) and not ex1_ttype_q(9) and mmucr1_q(1) and not ccr2_frat_paranoia_q(9));
ex2_dsi_d(8 TO 11) <=  (ex1_valid_q and not(xu_derat_ex1_n_flush) and not(ex2_n_flush_req_d));
ex2_dsi_d(12 TO 15) <=  (ex1_valid_q and not(xu_derat_ex1_n_flush) and not(ex2_n_flush_req_d));
ex3_dsi_d(0 TO 7) <=  ex2_dsi_q(0 to 7);
ex3_dsi_d(8 TO 11) <=  (ex2_dsi_q(8 to 11)  and not(xu_derat_ex2_n_flush) and not(ex2_n_flush_req_q));
ex3_dsi_d(12 TO 15) <=  (ex2_dsi_q(12 to 15) and not(xu_derat_ex2_n_flush) and not(ex2_n_flush_req_q));
ex3_dsi(0) <=  ex3_dsi_q(0) and not ex3_array_cmp_data_q(47);
ex3_dsi(1) <=  ex3_dsi_q(1) and not ex3_array_cmp_data_q(49);
ex3_dsi(2) <=  ex3_dsi_q(2) and not ex3_array_cmp_data_q(45) and not ex3_array_cmp_data_q(49);
ex3_dsi(3) <=  ex3_dsi_q(3) and not ex3_array_cmp_data_q(48);
ex3_dsi(4) <=  ex3_dsi_q(4) and not ex3_array_cmp_data_q(50);
ex3_dsi(5) <=  ex3_dsi_q(5) and not ex3_array_cmp_data_q(46) and not ex3_array_cmp_data_q(50);
ex3_dsi(6) <=  ex3_dsi_q(6) and not ex3_array_cmp_data_q(31);
ex3_dsi(7) <=  ex3_dsi_q(7) and not ex3_array_cmp_data_q(30);
ex3_dsi_enab  <=  or_reduce(ex3_dsi) and not(or_reduce(ex3_miss_q));
ex2_noop_touch_d(0) <=  ((ex1_ttype_q(4) or ex1_ttype_q(5)) and ex1_ttype_q(9));
ex2_noop_touch_d(1) <=  ((ex1_ttype_q(4) or ex1_ttype_q(5)) and ex1_ttype_q(9));
ex2_noop_touch_d(2) <=  ((ex1_ttype_q(4) or ex1_ttype_q(5)) and ex1_ttype_q(9));
ex2_noop_touch_d(3) <=  (ex1_ttype_q(4) and not ex1_ttype_q(8) and ex1_ttype_q(9) and ex1_state_q(0));
ex2_noop_touch_d(4) <=  (ex1_ttype_q(4) and not ex1_ttype_q(8) and ex1_ttype_q(9) and not ex1_state_q(0));
ex2_noop_touch_d(5) <=  (ex1_ttype_q(5) and not ex1_ttype_q(8) and ex1_ttype_q(9) and ex1_state_q(0));
ex2_noop_touch_d(6) <=  (ex1_ttype_q(5) and not ex1_ttype_q(8) and ex1_ttype_q(9) and not ex1_state_q(0));
ex2_noop_touch_d(7) <=  (ex1_ttype_q(4) and ex1_ttype_q(8) and ex1_ttype_q(9));
ex2_noop_touch_d(8 TO 11) <=  (ex1_valid_q and not(xu_derat_ex1_n_flush) and not(ex2_n_flush_req_d));
ex2_noop_touch_d(12 TO 15) <=  (ex1_valid_q and not(xu_derat_ex1_n_flush) and not(ex2_n_flush_req_d));
ex3_noop_touch_d(0) <=  ex2_noop_touch_q(0) and not cam_hit;
--  bits 2:3 used to be multihit/parerr, but not needed for noop_touch because they are flushed by xu regardless of noop_touch
ex3_noop_touch_d(1) <=  ex2_noop_touch_q(1) and mmucr1_q(1);
ex3_noop_touch_d(2) <=  ex2_noop_touch_q(2) and mmucr1_q(2);
ex3_noop_touch_d(3 TO 7) <=  ex2_noop_touch_q(3 to 7);
ex3_noop_touch(0) <=  ex3_noop_touch_q(0);
ex3_noop_touch(1) <=  ex3_noop_touch_q(1) and not ex3_array_cmp_data_q(30);
ex3_noop_touch(2) <=  ex3_noop_touch_q(2) and not ex3_array_cmp_data_q(31);
ex3_noop_touch(3) <=  ex3_noop_touch_q(3) and not ex3_array_cmp_data_q(49);
ex3_noop_touch(4) <=  ex3_noop_touch_q(4) and not ex3_array_cmp_data_q(50);
ex3_noop_touch(5) <=  ex3_noop_touch_q(5) and not ex3_array_cmp_data_q(47);
ex3_noop_touch(6) <=  ex3_noop_touch_q(6) and not ex3_array_cmp_data_q(48);
ex3_noop_touch(7) <=  ex3_noop_touch_q(7);
ex3_noop_touch_d(8 TO 11) <=  (ex2_noop_touch_q(8 to 11) and not(xu_derat_ex2_n_flush) and not(ex2_n_flush_req_q));
ex3_noop_touch_d(12 TO 15) <=  (ex2_noop_touch_q(12 to 15) and not(xu_derat_ex2_n_flush) and not(ex2_n_flush_req_q));
ex3_noop_touch_enab  <=  or_reduce(ex3_noop_touch(0 to 7));
ex3_attr_d  <=  array_cmp_data(45 to 50) or (0 to 5 => ccr2_frat_paranoia_q(9));
--  This function is controlled by XUCR4.MMU_MCHK and CCR2.NOTLB  bits.
mchk_flash_inv_d(0) <=  ex3_parerr_q(thdid_width) and (ex3_cmp_data_parerr_epn or ex3_cmp_data_parerr_rpn);
mchk_flash_inv_d(1) <=  ex3_parerr_q(thdid_width) and ex3_multihit_enab;
mchk_flash_inv_d(2) <=  (mchk_flash_inv_q(0) or mchk_flash_inv_q(1)) and or_reduce(ex4_parerr_q(0 to thdid_width-1) and not(xu_derat_ex4_n_flush));
mchk_flash_inv_d(3) <=  mchk_flash_inv_enab;
mchk_flash_inv_enab  <=  mchk_flash_inv_q(2) and not(ccr2_notlb_q) and not(xucr4_mmu_mchk_q);
--       0        1        2        3         4      5       6       7       8
--ttype: eratre & eratwe & eratsx & eratilx & load & store & csync & isync & icbtlslc;
ex2_n_flush_req_d    <=  ex1_valid_q and not(xu_derat_ex1_n_flush) 
                         when ( (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1') 
                              or ((epsc_wr_q(8)='1' or eplc_wr_q(8)='1') and mmucr1_q(7)='0')  
                              or   snoop_val_q(0 to 1)="11"  
                              or   ((ex1_deratre or ex1_deratwe or ex1_deratsx)='1' and tlb_rel_data_q(eratpos_relsoon)='1')  ) 
                  else ex1_valid_q  when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_DErat)  
                  else ex1_valid_q when ((ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00") or mchk_flash_inv_enab='1' or mchk_flash_inv_q(3)='1')  
                  else (others => '0');
--       0        1        2        3         4      5       6       7       8
--ttype: eratre & eratwe & eratsx & eratilx & load & store & csync & isync & icbtlslc;
-- ex3 flush conditions:
--  ex2 flush
--  tlbwe followed by tlbre, to same hw structure, within 4 cycs
--  tlbwe followed by tlbsx, to same hw structure, within 5 cycs
ex3_n_flush_req_d  <=  (ex2_valid_q and not(xu_derat_ex2_n_flush)) 
                            when ex2_n_flush_req_q /= "0000"  or
                                     (ex3_valid_q /= "0000" and ex3_ttype_q(1)='1' and 
                                       ex2_valid_q /= "0000" and ex2_ttype_q(0)='1' and
                                       ex3_tlbsel_q=ex2_tlbsel_q) or
                                        (ex4_valid_q /= "0000" and ex4_ttype_q(1)='1' and 
                                         ex2_valid_q /= "0000" and ex2_ttype_q(0)='1' and
                                         ex4_tlbsel_q=ex2_tlbsel_q) or
                                          (ex5_valid_q /= "0000" and ex5_ttype_q(1)='1' and 
                                           ex2_valid_q /= "0000" and ex2_ttype_q(0)='1' and
                                           ex5_tlbsel_q=ex2_tlbsel_q) or
                                            (ex6_valid_q /= "0000" and ex6_ttype_q(1)='1' and 
                                             ex2_valid_q /= "0000" and ex2_ttype_q(0)='1' and
                                             ex6_tlbsel_q=ex2_tlbsel_q) or
                                  (ex3_valid_q /= "0000" and ex3_ttype_q(1)='1' and 
                                   ex2_valid_q /= "0000" and ex2_ttype_q(2)='1' and
                                   ex3_tlbsel_q=ex2_tlbsel_q) or
                                    (ex4_valid_q /= "0000" and ex4_ttype_q(1)='1' and 
                                     ex2_valid_q /= "0000" and ex2_ttype_q(2)='1' and
                                     ex4_tlbsel_q=ex2_tlbsel_q) or
                                      (ex5_valid_q /= "0000" and ex5_ttype_q(1)='1' and 
                                       ex2_valid_q /= "0000" and ex2_ttype_q(2)='1' and
                                       ex5_tlbsel_q=ex2_tlbsel_q) or
                                       (ex6_valid_q /= "0000" and ex6_ttype_q(1)='1' and 
                                         ex2_valid_q /= "0000" and ex2_ttype_q(2)='1' and
                                          ex6_tlbsel_q=ex2_tlbsel_q) or
                                           (ex7_valid_q /= "0000" and ex7_ttype_q(1)='1' and 
                                             ex2_valid_q /= "0000" and ex2_ttype_q(2)='1' and
                                              ex7_tlbsel_q=ex2_tlbsel_q) or
                                  (ex3_valid_q /= "0000" and ex3_ttype_q(4 to 5)/="00" and 
                                   ex2_valid_q /= "0000" and ex2_ttype_q(0)='1' and
                                    ex2_ws_q="11" and ex2_tlbsel_q=TlbSel_DErat) or
                                    (ex4_valid_q /= "0000" and ex4_ttype_q(4 to 5)/="00" and 
                                     ex2_valid_q /= "0000" and ex2_ttype_q(0)='1' and
                                      ex2_ws_q="11" and ex2_tlbsel_q=TlbSel_DErat) or
                                      (ex5_valid_q /= "0000" and ex5_ttype_q(4 to 5)/="00" and 
                                       ex2_valid_q /= "0000" and ex2_ttype_q(0)='1' and
                                        ex2_ws_q="11" and ex2_tlbsel_q=TlbSel_DErat) or
                                        (ex6_valid_q /= "0000" and ex6_ttype_q(4 to 5)/="00" and 
                                          ex2_valid_q /= "0000" and ex2_ttype_q(0)='1' and
                                           ex2_ws_q="11" and ex2_tlbsel_q=TlbSel_DErat)
                  else (others => '0');
snoop_val_d(0) <=  mm_xu_derat_snoop_val when snoop_val_q(0)='0'
           else '0' when (tlb_rel_val_q(4)='0' and epsc_wr_q(8)='0' and eplc_wr_q(8)='0' and snoop_val_q(1)='1') 
           else snoop_val_q(0);
snoop_val_d(1) <=  not xu_derat_rf1_binv_val;
snoop_val_d(2) <=  '0' when (tlb_rel_val_q(4)='1' or epsc_wr_q(8)='1' or eplc_wr_q(8)='1' or snoop_val_q(1)='0') 
             else snoop_val_q(0);
snoop_attr_d  <=  mm_xu_derat_snoop_attr when snoop_val_q(0)='0'
           else snoop_attr_q;
snoop_addr_d  <=  mm_xu_derat_snoop_vpn when snoop_val_q(0)='0'
           else snoop_addr_q;
xu_mm_derat_snoop_ack  <=  snoop_val_q(2);
gen64_holdreg: if rs_data_width = 64 generate
rpn_holdreg0_d(0 TO 19) <=  ex6_data_in_q(0 to 19) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg0_q(0   to 19);
rpn_holdreg0_d(20 TO 31) <=  ex6_data_in_q(20 to 31) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg0_q(20   to 31);
rpn_holdreg0_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg0_q(32   to 51);
rpn_holdreg0_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg0_q(52   to 63);
rpn_holdreg1_d(0 TO 19) <=  ex6_data_in_q(0 to 19) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg1_q(0   to 19);
rpn_holdreg1_d(20 TO 31) <=  ex6_data_in_q(20 to 31) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg1_q(20   to 31);
rpn_holdreg1_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg1_q(32   to 51);
rpn_holdreg1_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg1_q(52   to 63);
rpn_holdreg2_d(0 TO 19) <=  ex6_data_in_q(0 to 19) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg2_q(0   to 19);
rpn_holdreg2_d(20 TO 31) <=  ex6_data_in_q(20 to 31) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg2_q(20   to 31);
rpn_holdreg2_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg2_q(32   to 51);
rpn_holdreg2_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg2_q(52   to 63);
rpn_holdreg3_d(0 TO 19) <=  ex6_data_in_q(0 to 19) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg3_q(0   to 19);
rpn_holdreg3_d(20 TO 31) <=  ex6_data_in_q(20 to 31) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg3_q(20   to 31);
rpn_holdreg3_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg3_q(32   to 51);
rpn_holdreg3_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat and ex6_state_q(3)='0') 
                  else rpn_holdreg3_q(52   to 63);
end generate gen64_holdreg;
gen32_holdreg: if rs_data_width = 32 generate
rpn_holdreg0_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg0_q(32   to 51);
rpn_holdreg0_d(20 TO 31) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg0_q(20   to 31);
rpn_holdreg0_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg0_q(52   to 63);
rpn_holdreg0_d(0 TO 19) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg0_q(0   to 19);
rpn_holdreg1_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg1_q(32   to 51);
rpn_holdreg1_d(20 TO 31) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg1_q(20   to 31);
rpn_holdreg1_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg1_q(52   to 63);
rpn_holdreg1_d(0 TO 19) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg1_q(0   to 19);
rpn_holdreg2_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg2_q(32   to 51);
rpn_holdreg2_d(20 TO 31) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg2_q(20   to 31);
rpn_holdreg2_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg2_q(52   to 63);
rpn_holdreg2_d(0 TO 19) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg2_q(0   to 19);
rpn_holdreg3_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg3_q(32   to 51);
rpn_holdreg3_d(20 TO 31) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg3_q(20   to 31);
rpn_holdreg3_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg3_q(52   to 63);
rpn_holdreg3_d(0 TO 19) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_DErat) 
                  else rpn_holdreg3_q(0   to 19);
end generate gen32_holdreg;
ex6_deratwe_ws3    <=  or_reduce(ex6_valid_q) and ex6_ttype_q(1) and Eq(ex6_ws_q,"11") and Eq(ex6_tlbsel_q,TlbSel_DErat);
watermark_d    <=  ex6_data_in_q(64-watermark_width to 63) when ex6_deratwe_ws3='1'  
                  else watermark_q;
-- entry pointer for round-robin mode
eptr_d  <=  (others => '0') when (ex6_deratwe_ws3='1' and mmucr1_q(0)='1') 
    else  (others => '0') when (eptr_q="11111" or eptr_q=watermark_q) and 
                          ( (ex6_valid_q /= "0000" and ex6_ttype_q(1)='1' and 
                              ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_DErat and mmucr1_q(0)='1') or  
                            (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1' and 
                              tlb_rel_data_q(eratpos_wren)='1' and mmucr1_q(0)='1') ) 
    else eptr_p1      when ( (ex6_valid_q /= "0000" and ex6_ttype_q(1)='1' and 
                              ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_DErat and mmucr1_q(0)='1') or  
                            (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1' and 
                              tlb_rel_data_q(eratpos_wren)='1' and mmucr1_q(0)='1') ) 
    else eptr_q;
eptr_p1  <=  "00001" when eptr_q="00000"
      else "00010" when eptr_q="00001"
      else "00011" when eptr_q="00010"
      else "00100" when eptr_q="00011"
      else "00101" when eptr_q="00100"
      else "00110" when eptr_q="00101"
      else "00111" when eptr_q="00110"
      else "01000" when eptr_q="00111"
      else "01001" when eptr_q="01000"
      else "01010" when eptr_q="01001"
      else "01011" when eptr_q="01010"
      else "01100" when eptr_q="01011"
      else "01101" when eptr_q="01100"
      else "01110" when eptr_q="01101"
      else "01111" when eptr_q="01110"
      else "10000" when eptr_q="01111"
      else "10001" when eptr_q="10000"
      else "10010" when eptr_q="10001"
      else "10011" when eptr_q="10010"
      else "10100" when eptr_q="10011"
      else "10101" when eptr_q="10100"
      else "10110" when eptr_q="10101"
      else "10111" when eptr_q="10110"
      else "11000" when eptr_q="10111"
      else "11001" when eptr_q="11000"
      else "11010" when eptr_q="11001"
      else "11011" when eptr_q="11010"
      else "11100" when eptr_q="11011"
      else "11101" when eptr_q="11100"
      else "11110" when eptr_q="11101"
      else "11111" when eptr_q="11110"
      else "00000";
ex2_epn_d   <=   xu_derat_ex1_epn_nonarr(52-ex2_epn_width to 51);
-- lru_update_event
-- 0: tlb reload
-- 1: invalidate snoop
-- 2: csync or isync enabled
-- 3: eratwe WS=0
-- 4: load or store hit
-- 5: ex3 cam write type events
-- 6: ex3 cam invalidate type events
-- 7: ex3 cam translation type events
-- 8: superset, ex2
-- 9: superset, delayed to ex3
lru_update_event_d(0) <=  (tlb_rel_data_q(eratpos_wren) and or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4));
lru_update_event_d(1) <=  (snoop_val_q(0) and snoop_val_q(1));
lru_update_event_d(2) <=  (or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(6 to 7)));
lru_update_event_d(3) <=  (or_reduce(ex6_valid_q) and ex6_ttype_q(1) 
                           and Eq(ex6_ws_q,"00") and Eq(ex6_tlbsel_q,TlbSel_DErat) and Eq(lru_way_encode,ex6_ra_entry_q));
lru_update_event_d(4) <=  (or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5)) and ex6_hit_q );
lru_update_event_d(5) <=  lru_update_event_q(0) or lru_update_event_q(3);
lru_update_event_d(6) <=  lru_update_event_q(1) or lru_update_event_q(2);
lru_update_event_d(7) <=  lru_update_event_q(4);
lru_update_event_d(8) <=  (tlb_rel_data_q(eratpos_wren) and or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4))  
                     or  (snoop_val_q(0) and snoop_val_q(1))  
                     or  (or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(6 to 7)))  
                     or  (or_reduce(ex6_valid_q) and ex6_ttype_q(1) 
                           and Eq(ex6_ws_q,"00") and Eq(ex6_tlbsel_q,TlbSel_DErat) and Eq(lru_way_encode,ex6_ra_entry_q))  
                     or  (or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5)) and ex6_hit_q );
lru_update_event_d(9) <=  lru_update_event_q(8);
-- LRU next state.. update bits for which override is zero (Op=0)
--   effective LRU is what is used to choose entry to update
--     lru new value is valid 2 clocks after reload, invalidate, eratwe, or fetch hit
lru_d(1) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(1)='1'   and lru_op_vec(1)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(1)='1'   and lru_op_vec(1)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(1);
lru_eff(1) <=  (lru_vp_vec(1)   and lru_op_vec(1))   or (lru_q(1)   and not lru_op_vec(1));
lru_d(2) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(2)='1'   and lru_op_vec(2)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(2)='1'   and lru_op_vec(2)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(2);
lru_eff(2) <=  (lru_vp_vec(2)   and lru_op_vec(2))   or (lru_q(2)   and not lru_op_vec(2));
lru_d(3) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(3)='1'   and lru_op_vec(3)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(3)='1'   and lru_op_vec(3)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(3);
lru_eff(3) <=  (lru_vp_vec(3)   and lru_op_vec(3))   or (lru_q(3)   and not lru_op_vec(3));
lru_d(4) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(4)='1'   and lru_op_vec(4)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(4)='1'   and lru_op_vec(4)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(4);
lru_eff(4) <=  (lru_vp_vec(4)   and lru_op_vec(4))   or (lru_q(4)   and not lru_op_vec(4));
lru_d(5) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(5)='1'   and lru_op_vec(5)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(5)='1'   and lru_op_vec(5)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(5);
lru_eff(5) <=  (lru_vp_vec(5)   and lru_op_vec(5))   or (lru_q(5)   and not lru_op_vec(5));
lru_d(6) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(6)='1'   and lru_op_vec(6)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(6)='1'   and lru_op_vec(6)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(6);
lru_eff(6) <=  (lru_vp_vec(6)   and lru_op_vec(6))   or (lru_q(6)   and not lru_op_vec(6));
lru_d(7) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(7)='1'   and lru_op_vec(7)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(7)='1'   and lru_op_vec(7)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(7);
lru_eff(7) <=  (lru_vp_vec(7)   and lru_op_vec(7))   or (lru_q(7)   and not lru_op_vec(7));
lru_d(8) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(8)='1'   and lru_op_vec(8)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(8)='1'   and lru_op_vec(8)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(8);
lru_eff(8) <=  (lru_vp_vec(8)   and lru_op_vec(8))   or (lru_q(8)   and not lru_op_vec(8));
lru_d(9) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(9)='1'   and lru_op_vec(9)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(9)='1'   and lru_op_vec(9)='0'   and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(9);
lru_eff(9) <=  (lru_vp_vec(9)   and lru_op_vec(9))   or (lru_q(9)   and not lru_op_vec(9));
lru_d(10) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(10)='1'  and lru_op_vec(10)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(10)='1'  and lru_op_vec(10)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(10);
lru_eff(10) <=  (lru_vp_vec(10)  and lru_op_vec(10))  or (lru_q(10)  and not lru_op_vec(10));
lru_d(11) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(11)='1'  and lru_op_vec(11)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(11)='1'  and lru_op_vec(11)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(11);
lru_eff(11) <=  (lru_vp_vec(11)  and lru_op_vec(11))  or (lru_q(11)  and not lru_op_vec(11));
lru_d(12) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(12)='1'  and lru_op_vec(12)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(12)='1'  and lru_op_vec(12)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(12);
lru_eff(12) <=  (lru_vp_vec(12)  and lru_op_vec(12))  or (lru_q(12)  and not lru_op_vec(12));
lru_d(13) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(13)='1'  and lru_op_vec(13)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(13)='1'  and lru_op_vec(13)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(13);
lru_eff(13) <=  (lru_vp_vec(13)  and lru_op_vec(13))  or (lru_q(13)  and not lru_op_vec(13));
lru_d(14) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(14)='1'  and lru_op_vec(14)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(14)='1'  and lru_op_vec(14)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(14);
lru_eff(14) <=  (lru_vp_vec(14)  and lru_op_vec(14))  or (lru_q(14)  and not lru_op_vec(14));
lru_d(15) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(15)='1'  and lru_op_vec(15)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(15)='1'  and lru_op_vec(15)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(15);
lru_eff(15) <=  (lru_vp_vec(15)  and lru_op_vec(15))  or (lru_q(15)  and not lru_op_vec(15));
lru_d(16) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(16)='1'  and lru_op_vec(16)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(16)='1'  and lru_op_vec(16)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(16);
lru_eff(16) <=  (lru_vp_vec(16)  and lru_op_vec(16))  or (lru_q(16)  and not lru_op_vec(16));
lru_d(17) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(17)='1'  and lru_op_vec(17)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(17)='1'  and lru_op_vec(17)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(17);
lru_eff(17) <=  (lru_vp_vec(17)  and lru_op_vec(17))  or (lru_q(17)  and not lru_op_vec(17));
lru_d(18) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(18)='1'  and lru_op_vec(18)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(18)='1'  and lru_op_vec(18)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(18);
lru_eff(18) <=  (lru_vp_vec(18)  and lru_op_vec(18))  or (lru_q(18)  and not lru_op_vec(18));
lru_d(19) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(19)='1'  and lru_op_vec(19)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(19)='1'  and lru_op_vec(19)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(19);
lru_eff(19) <=  (lru_vp_vec(19)  and lru_op_vec(19))  or (lru_q(19)  and not lru_op_vec(19));
lru_d(20) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(20)='1'  and lru_op_vec(20)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(20)='1'  and lru_op_vec(20)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(20);
lru_eff(20) <=  (lru_vp_vec(20)  and lru_op_vec(20))  or (lru_q(20)  and not lru_op_vec(20));
lru_d(21) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(21)='1'  and lru_op_vec(21)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(21)='1'  and lru_op_vec(21)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(21);
lru_eff(21) <=  (lru_vp_vec(21)  and lru_op_vec(21))  or (lru_q(21)  and not lru_op_vec(21));
lru_d(22) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(22)='1'  and lru_op_vec(22)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(22)='1'  and lru_op_vec(22)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(22);
lru_eff(22) <=  (lru_vp_vec(22)  and lru_op_vec(22))  or (lru_q(22)  and not lru_op_vec(22));
lru_d(23) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(23)='1'  and lru_op_vec(23)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(23)='1'  and lru_op_vec(23)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(23);
lru_eff(23) <=  (lru_vp_vec(23)  and lru_op_vec(23))  or (lru_q(23)  and not lru_op_vec(23));
lru_d(24) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(24)='1'  and lru_op_vec(24)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(24)='1'  and lru_op_vec(24)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(24);
lru_eff(24) <=  (lru_vp_vec(24)  and lru_op_vec(24))  or (lru_q(24)  and not lru_op_vec(24));
lru_d(25) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(25)='1'  and lru_op_vec(25)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(25)='1'  and lru_op_vec(25)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(25);
lru_eff(25) <=  (lru_vp_vec(25)  and lru_op_vec(25))  or (lru_q(25)  and not lru_op_vec(25));
lru_d(26) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(26)='1'  and lru_op_vec(26)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(26)='1'  and lru_op_vec(26)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(26);
lru_eff(26) <=  (lru_vp_vec(26)  and lru_op_vec(26))  or (lru_q(26)  and not lru_op_vec(26));
lru_d(27) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(27)='1'  and lru_op_vec(27)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(27)='1'  and lru_op_vec(27)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(27);
lru_eff(27) <=  (lru_vp_vec(27)  and lru_op_vec(27))  or (lru_q(27)  and not lru_op_vec(27));
lru_d(28) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(28)='1'  and lru_op_vec(28)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(28)='1'  and lru_op_vec(28)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(28);
lru_eff(28) <=  (lru_vp_vec(28)  and lru_op_vec(28))  or (lru_q(28)  and not lru_op_vec(28));
lru_d(29) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(29)='1'  and lru_op_vec(29)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(29)='1'  and lru_op_vec(29)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(29);
lru_eff(29) <=  (lru_vp_vec(29)  and lru_op_vec(29))  or (lru_q(29)  and not lru_op_vec(29));
lru_d(30) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(30)='1'  and lru_op_vec(30)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(30)='1'  and lru_op_vec(30)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(30);
lru_eff(30) <=  (lru_vp_vec(30)  and lru_op_vec(30))  or (lru_q(30)  and not lru_op_vec(30));
lru_d(31) <=  '0' when ((ex6_deratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(31)='1'  and lru_op_vec(31)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else  '1' when lru_set_vec(31)='1'  and lru_op_vec(31)='0'  and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
        else lru_q(31);
lru_eff(31) <=  (lru_vp_vec(31)  and lru_op_vec(31))  or (lru_q(31)  and not lru_op_vec(31));
-- RMT override enable:  Op= OR(all RMT entries below and left of p) XOR OR(all RMT entries below and right of p)
lru_op_vec(1) <=  (lru_rmt_vec(0) or lru_rmt_vec(1) or lru_rmt_vec(2) or lru_rmt_vec(3) or 
                    lru_rmt_vec(4) or lru_rmt_vec(5) or lru_rmt_vec(6) or lru_rmt_vec(7) or 
                      lru_rmt_vec(8) or lru_rmt_vec(9) or lru_rmt_vec(10) or lru_rmt_vec(11) or 
                        lru_rmt_vec(12) or lru_rmt_vec(13) or lru_rmt_vec(14) or lru_rmt_vec(15))  xor
                 (lru_rmt_vec(16) or lru_rmt_vec(17) or lru_rmt_vec(18) or lru_rmt_vec(19) or 
                    lru_rmt_vec(20) or lru_rmt_vec(21) or lru_rmt_vec(22) or lru_rmt_vec(23) or 
                      lru_rmt_vec(24) or lru_rmt_vec(25) or lru_rmt_vec(26) or lru_rmt_vec(27) or 
                        lru_rmt_vec(28) or lru_rmt_vec(29) or lru_rmt_vec(30) or lru_rmt_vec(31));
lru_op_vec(2) <=  (lru_rmt_vec(0) or lru_rmt_vec(1) or lru_rmt_vec(2) or lru_rmt_vec(3) or 
                    lru_rmt_vec(4) or lru_rmt_vec(5) or lru_rmt_vec(6) or lru_rmt_vec(7))  xor
                      (lru_rmt_vec(8) or lru_rmt_vec(9) or lru_rmt_vec(10) or lru_rmt_vec(11) or 
                         lru_rmt_vec(12) or lru_rmt_vec(13) or lru_rmt_vec(14) or lru_rmt_vec(15));
lru_op_vec(3) <=  (lru_rmt_vec(16) or lru_rmt_vec(17) or lru_rmt_vec(18) or lru_rmt_vec(19) or 
                    lru_rmt_vec(20) or lru_rmt_vec(21) or lru_rmt_vec(22) or lru_rmt_vec(23))  xor
                      (lru_rmt_vec(24) or lru_rmt_vec(25) or lru_rmt_vec(26) or lru_rmt_vec(27) or 
                         lru_rmt_vec(28) or lru_rmt_vec(29) or lru_rmt_vec(30) or lru_rmt_vec(31));
lru_op_vec(4) <=  (lru_rmt_vec(0) or lru_rmt_vec(1) or lru_rmt_vec(2) or lru_rmt_vec(3))   xor
                 (lru_rmt_vec(4) or lru_rmt_vec(5) or lru_rmt_vec(6) or lru_rmt_vec(7));
lru_op_vec(5) <=  (lru_rmt_vec(8) or lru_rmt_vec(9) or lru_rmt_vec(10) or lru_rmt_vec(11))   xor
                 (lru_rmt_vec(12) or lru_rmt_vec(13) or lru_rmt_vec(14) or lru_rmt_vec(15));
lru_op_vec(6) <=  (lru_rmt_vec(16) or lru_rmt_vec(17) or lru_rmt_vec(18) or lru_rmt_vec(19))   xor
                 (lru_rmt_vec(20) or lru_rmt_vec(21) or lru_rmt_vec(22) or lru_rmt_vec(23));
lru_op_vec(7) <=  (lru_rmt_vec(24) or lru_rmt_vec(25) or lru_rmt_vec(26) or lru_rmt_vec(27))   xor
                 (lru_rmt_vec(28) or lru_rmt_vec(29) or lru_rmt_vec(30) or lru_rmt_vec(31));
lru_op_vec(8) <=  (lru_rmt_vec(0) or lru_rmt_vec(1)) xor (lru_rmt_vec(2) or lru_rmt_vec(3));
lru_op_vec(9) <=  (lru_rmt_vec(4) or lru_rmt_vec(5)) xor (lru_rmt_vec(6) or lru_rmt_vec(7));
lru_op_vec(10) <=  (lru_rmt_vec(8) or lru_rmt_vec(9)) xor (lru_rmt_vec(10) or lru_rmt_vec(11));
lru_op_vec(11) <=  (lru_rmt_vec(12) or lru_rmt_vec(13)) xor (lru_rmt_vec(14) or lru_rmt_vec(15));
lru_op_vec(12) <=  (lru_rmt_vec(16) or lru_rmt_vec(17)) xor (lru_rmt_vec(18) or lru_rmt_vec(19));
lru_op_vec(13) <=  (lru_rmt_vec(20) or lru_rmt_vec(21)) xor (lru_rmt_vec(22) or lru_rmt_vec(23));
lru_op_vec(14) <=  (lru_rmt_vec(24) or lru_rmt_vec(25)) xor (lru_rmt_vec(26) or lru_rmt_vec(27));
lru_op_vec(15) <=  (lru_rmt_vec(28) or lru_rmt_vec(29)) xor (lru_rmt_vec(30) or lru_rmt_vec(31));
lru_op_vec(16) <=  lru_rmt_vec(0) xor lru_rmt_vec(1);
lru_op_vec(17) <=  lru_rmt_vec(2) xor lru_rmt_vec(3);
lru_op_vec(18) <=  lru_rmt_vec(4) xor lru_rmt_vec(5);
lru_op_vec(19) <=  lru_rmt_vec(6) xor lru_rmt_vec(7);
lru_op_vec(20) <=  lru_rmt_vec(8) xor lru_rmt_vec(9);
lru_op_vec(21) <=  lru_rmt_vec(10) xor lru_rmt_vec(11);
lru_op_vec(22) <=  lru_rmt_vec(12) xor lru_rmt_vec(13);
lru_op_vec(23) <=  lru_rmt_vec(14) xor lru_rmt_vec(15);
lru_op_vec(24) <=  lru_rmt_vec(16) xor lru_rmt_vec(17);
lru_op_vec(25) <=  lru_rmt_vec(18) xor lru_rmt_vec(19);
lru_op_vec(26) <=  lru_rmt_vec(20) xor lru_rmt_vec(21);
lru_op_vec(27) <=  lru_rmt_vec(22) xor lru_rmt_vec(23);
lru_op_vec(28) <=  lru_rmt_vec(24) xor lru_rmt_vec(25);
lru_op_vec(29) <=  lru_rmt_vec(26) xor lru_rmt_vec(27);
lru_op_vec(30) <=  lru_rmt_vec(28) xor lru_rmt_vec(29);
lru_op_vec(31) <=  lru_rmt_vec(30) xor lru_rmt_vec(31);
-- RMT override value: Vp= OR(all RMT entries below and right of p)
lru_vp_vec(1) <=  (lru_rmt_vec(16) or lru_rmt_vec(17) or lru_rmt_vec(18) or lru_rmt_vec(19) or 
                    lru_rmt_vec(20) or lru_rmt_vec(21) or lru_rmt_vec(22) or lru_rmt_vec(23) or 
                      lru_rmt_vec(24) or lru_rmt_vec(25) or lru_rmt_vec(26) or lru_rmt_vec(27) or 
                        lru_rmt_vec(28) or lru_rmt_vec(29) or lru_rmt_vec(30) or lru_rmt_vec(31));
lru_vp_vec(2) <=  (lru_rmt_vec(8) or lru_rmt_vec(9) or lru_rmt_vec(10) or lru_rmt_vec(11) or 
                         lru_rmt_vec(12) or lru_rmt_vec(13) or lru_rmt_vec(14) or lru_rmt_vec(15));
lru_vp_vec(3) <=  (lru_rmt_vec(24) or lru_rmt_vec(25) or lru_rmt_vec(26) or lru_rmt_vec(27) or 
                         lru_rmt_vec(28) or lru_rmt_vec(29) or lru_rmt_vec(30) or lru_rmt_vec(31));
lru_vp_vec(4) <=  (lru_rmt_vec(4) or lru_rmt_vec(5) or lru_rmt_vec(6) or lru_rmt_vec(7));
lru_vp_vec(5) <=  (lru_rmt_vec(12) or lru_rmt_vec(13) or lru_rmt_vec(14) or lru_rmt_vec(15));
lru_vp_vec(6) <=  (lru_rmt_vec(20) or lru_rmt_vec(21) or lru_rmt_vec(22) or lru_rmt_vec(23));
lru_vp_vec(7) <=  (lru_rmt_vec(28) or lru_rmt_vec(29) or lru_rmt_vec(30) or lru_rmt_vec(31));
lru_vp_vec(8) <=  (lru_rmt_vec(2) or lru_rmt_vec(3));
lru_vp_vec(9) <=  (lru_rmt_vec(6) or lru_rmt_vec(7));
lru_vp_vec(10) <=  (lru_rmt_vec(10) or lru_rmt_vec(11));
lru_vp_vec(11) <=  (lru_rmt_vec(14) or lru_rmt_vec(15));
lru_vp_vec(12) <=  (lru_rmt_vec(18) or lru_rmt_vec(19));
lru_vp_vec(13) <=  (lru_rmt_vec(22) or lru_rmt_vec(23));
lru_vp_vec(14) <=  (lru_rmt_vec(26) or lru_rmt_vec(27));
lru_vp_vec(15) <=  (lru_rmt_vec(30) or lru_rmt_vec(31));
lru_vp_vec(16) <=  lru_rmt_vec(1);
lru_vp_vec(17) <=  lru_rmt_vec(3);
lru_vp_vec(18) <=  lru_rmt_vec(5);
lru_vp_vec(19) <=  lru_rmt_vec(7);
lru_vp_vec(20) <=  lru_rmt_vec(9);
lru_vp_vec(21) <=  lru_rmt_vec(11);
lru_vp_vec(22) <=  lru_rmt_vec(13);
lru_vp_vec(23) <=  lru_rmt_vec(15);
lru_vp_vec(24) <=  lru_rmt_vec(17);
lru_vp_vec(25) <=  lru_rmt_vec(19);
lru_vp_vec(26) <=  lru_rmt_vec(21);
lru_vp_vec(27) <=  lru_rmt_vec(23);
lru_vp_vec(28) <=  lru_rmt_vec(25);
lru_vp_vec(29) <=  lru_rmt_vec(27);
lru_vp_vec(30) <=  lru_rmt_vec(29);
lru_vp_vec(31) <=  lru_rmt_vec(31);
-- mmucr1_q: 0-DRRE, 1-REE, 2-CEE, 3-csync, 4-isync, 5:6-DPEI, 7:8-DCTID/DTTID, 9-DCCD
-- Encoder for the LRU watermark psuedo-RMT
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--?TABLE lru_rmt_vec LISTING(final) OPTIMIZE PARMS(ON-SET, OFF-SET);
--*INPUTS*===================*OUTPUTS*============================*
--|                          |                                    |
--| mmucr1_q                 |  lru_rmt_vec                       |
--| |         watermark_q    |  |                                 |
--| |         |              |  |                                 |
--| |         |              |  |                                 |
--| |         |              |  |         1111111111222222222233  |
--| 012345678 01234          |  01234567890123456789012345678901  |
--*TYPE*=====================+====================================+
--| PPPPPPPPP PPPPP          |  PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP  |
--*OPTIMIZE*---------------->|  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  |
--*TERMS*====================+====================================+
--| 1-------- -----          |  11111111111111111111111111111111  |  round-robin enabled
--| 0-------- 00000          |  10000000000000000000000000000000  |
--| 0-------- 00001          |  11000000000000000000000000000000  |
--| 0-------- 00010          |  11100000000000000000000000000000  |
--| 0-------- 00011          |  11110000000000000000000000000000  |
--| 0-------- 00100          |  11111000000000000000000000000000  |
--| 0-------- 00101          |  11111100000000000000000000000000  |
--| 0-------- 00110          |  11111110000000000000000000000000  |
--| 0-------- 00111          |  11111111000000000000000000000000  |
--| 0-------- 01000          |  11111111100000000000000000000000  |
--| 0-------- 01001          |  11111111110000000000000000000000  |
--| 0-------- 01010          |  11111111111000000000000000000000  |
--| 0-------- 01011          |  11111111111100000000000000000000  |
--| 0-------- 01100          |  11111111111110000000000000000000  |
--| 0-------- 01101          |  11111111111111000000000000000000  |
--| 0-------- 01110          |  11111111111111100000000000000000  |
--| 0-------- 01111          |  11111111111111110000000000000000  |
--| 0-------- 10000          |  11111111111111111000000000000000  |
--| 0-------- 10001          |  11111111111111111100000000000000  |
--| 0-------- 10010          |  11111111111111111110000000000000  |
--| 0-------- 10011          |  11111111111111111111000000000000  |
--| 0-------- 10100          |  11111111111111111111100000000000  |
--| 0-------- 10101          |  11111111111111111111110000000000  |
--| 0-------- 10110          |  11111111111111111111111000000000  |
--| 0-------- 10111          |  11111111111111111111111100000000  |
--| 0-------- 11000          |  11111111111111111111111110000000  |
--| 0-------- 11001          |  11111111111111111111111111000000  |
--| 0-------- 11010          |  11111111111111111111111111100000  |
--| 0-------- 11011          |  11111111111111111111111111110000  |
--| 0-------- 11100          |  11111111111111111111111111111000  |
--| 0-------- 11101          |  11111111111111111111111111111100  |
--| 0-------- 11110          |  11111111111111111111111111111110  |
--| 0-------- 11111          |  11111111111111111111111111111111  |
--*END*======================+====================================+
--?TABLE END lru_rmt_vec;
--?TABLE lru_watermark_mask LISTING(final) OPTIMIZE PARMS(ON-SET, OFF-SET);
--*INPUTS*===================*OUTPUTS*============================*
--|                          |                                    |
--| mmucr1_q                 |  lru_watermark_mask                |
--| |         watermark_q    |  |                                 |
--| |         |              |  |                                 |
--| |         |              |  |                                 |
--| |         |              |  |         1111111111222222222233  |
--| 012345678 01234          |  01234567890123456789012345678901  |
--*TYPE*=====================+====================================+
--| PPPPPPPPP PPPPP          |  PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP  |
--*OPTIMIZE*---------------->|  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  |
--*TERMS*====================+====================================+
--| --------- 00000          |  01111111111111111111111111111111  |
--| --------- 00001          |  00111111111111111111111111111111  |
--| --------- 00010          |  00011111111111111111111111111111  |
--| --------- 00011          |  00001111111111111111111111111111  |
--| --------- 00100          |  00000111111111111111111111111111  |
--| --------- 00101          |  00000011111111111111111111111111  |
--| --------- 00110          |  00000001111111111111111111111111  |
--| --------- 00111          |  00000000111111111111111111111111  |
--| --------- 01000          |  00000000011111111111111111111111  |
--| --------- 01001          |  00000000001111111111111111111111  |
--| --------- 01010          |  00000000000111111111111111111111  |
--| --------- 01011          |  00000000000011111111111111111111  |
--| --------- 01100          |  00000000000001111111111111111111  |
--| --------- 01101          |  00000000000000111111111111111111  |
--| --------- 01110          |  00000000000000011111111111111111  |
--| --------- 01111          |  00000000000000001111111111111111  |
--| --------- 10000          |  00000000000000000111111111111111  |
--| --------- 10001          |  00000000000000000011111111111111  |
--| --------- 10010          |  00000000000000000001111111111111  |
--| --------- 10011          |  00000000000000000000111111111111  |
--| --------- 10100          |  00000000000000000000011111111111  |
--| --------- 10101          |  00000000000000000000001111111111  |
--| --------- 10110          |  00000000000000000000000111111111  |
--| --------- 10111          |  00000000000000000000000011111111  |
--| --------- 11000          |  00000000000000000000000001111111  |
--| --------- 11001          |  00000000000000000000000000111111  |
--| --------- 11010          |  00000000000000000000000000011111  |
--| --------- 11011          |  00000000000000000000000000001111  |
--| --------- 11100          |  00000000000000000000000000000111  |
--| --------- 11101          |  00000000000000000000000000000011  |
--| --------- 11110          |  00000000000000000000000000000001  |
--| --------- 11111          |  00000000000000000000000000000000  |
--*END*======================+====================================+
--?TABLE END lru_watermark_mask;
--
-- Final Table Listing
--      *INPUTS*=========*OUTPUTS*============================*
--      |                |                                    |
--      |                |  lru_rmt_vec_d                     |
--      | watermark_d    |  |                                 |
--      | |              |  |                                 |
--      | |              |  |                                 |
--      | |              |  |         1111111111222222222233  |
--      | 01234          |  01234567890123456789012345678901  |
--      *TYPE*===========+====================================+
--      | PPPPP          |  PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP  |
--      *POLARITY*------>|  ++++++++++++++++++++++++++++++++  |
--      *PHASE*--------->|  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT  |
--      *OPTIMIZE*------>|   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
--      *TERMS*==========+====================================+
--    1 | 11111          |  ...............................1  |
--    2 | -1111          |  ...............1................  |
--    3 | 1-111          |  .......................1........  |
--    4 | --111          |  .......1........................  |
--    5 | 11-11          |  ...........................1....  |
--    6 | -1-11          |  ...........1....................  |
--    7 | 1--11          |  ...................1............  |
--    8 | ---11          |  ...1............................  |
--    9 | 111-1          |  .............................1..  |
--   10 | -11-1          |  .............1..................  |
--   11 | 1-1-1          |  .....................1..........  |
--   12 | --1-1          |  .....1..........................  |
--   13 | 11--1          |  .........................1......  |
--   14 | -1--1          |  .........1......................  |
--   15 | 1---1          |  .................1..............  |
--   16 | ----1          |  .1..............................  |
--   17 | 1111-          |  .............................11.  |
--   18 | -111-          |  .............11.................  |
--   19 | 1-11-          |  .....................11.........  |
--   20 | --11-          |  .....11.........................  |
--   21 | 11-1-          |  .........................11.....  |
--   22 | -1-1-          |  .........11.....................  |
--   23 | 1--1-          |  .................11.............  |
--   24 | ---1-          |  .11.............................  |
--   25 | 111--          |  .........................1111...  |
--   26 | -11--          |  .........1111...................  |
--   27 | 1-1--          |  .................1111...........  |
--   28 | --1--          |  .1111...........................  |
--   29 | 11---          |  .................11111111.......  |
--   30 | -1---          |  .11111111.......................  |
--   31 | 1----          |  .1111111111111111...............  |
--   32 | -----          |  1...............................  |
--      *=====================================================*
--
-- Table LRU_RMT_VEC_D Signal Assignments for Product Terms
MQQ70:LRU_RMT_VEC_D_PT(1) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(1) & 
    WATERMARK_D(2) & WATERMARK_D(3) & 
    WATERMARK_D(4) ) , STD_ULOGIC_VECTOR'("11111"));
MQQ71:LRU_RMT_VEC_D_PT(2) <=
    Eq(( WATERMARK_D(1) & WATERMARK_D(2) & 
    WATERMARK_D(3) & WATERMARK_D(4)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ72:LRU_RMT_VEC_D_PT(3) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(2) & 
    WATERMARK_D(3) & WATERMARK_D(4)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ73:LRU_RMT_VEC_D_PT(4) <=
    Eq(( WATERMARK_D(2) & WATERMARK_D(3) & 
    WATERMARK_D(4) ) , STD_ULOGIC_VECTOR'("111"));
MQQ74:LRU_RMT_VEC_D_PT(5) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(1) & 
    WATERMARK_D(3) & WATERMARK_D(4)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ75:LRU_RMT_VEC_D_PT(6) <=
    Eq(( WATERMARK_D(1) & WATERMARK_D(3) & 
    WATERMARK_D(4) ) , STD_ULOGIC_VECTOR'("111"));
MQQ76:LRU_RMT_VEC_D_PT(7) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(3) & 
    WATERMARK_D(4) ) , STD_ULOGIC_VECTOR'("111"));
MQQ77:LRU_RMT_VEC_D_PT(8) <=
    Eq(( WATERMARK_D(3) & WATERMARK_D(4)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ78:LRU_RMT_VEC_D_PT(9) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(1) & 
    WATERMARK_D(2) & WATERMARK_D(4)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ79:LRU_RMT_VEC_D_PT(10) <=
    Eq(( WATERMARK_D(1) & WATERMARK_D(2) & 
    WATERMARK_D(4) ) , STD_ULOGIC_VECTOR'("111"));
MQQ80:LRU_RMT_VEC_D_PT(11) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(2) & 
    WATERMARK_D(4) ) , STD_ULOGIC_VECTOR'("111"));
MQQ81:LRU_RMT_VEC_D_PT(12) <=
    Eq(( WATERMARK_D(2) & WATERMARK_D(4)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ82:LRU_RMT_VEC_D_PT(13) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(1) & 
    WATERMARK_D(4) ) , STD_ULOGIC_VECTOR'("111"));
MQQ83:LRU_RMT_VEC_D_PT(14) <=
    Eq(( WATERMARK_D(1) & WATERMARK_D(4)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ84:LRU_RMT_VEC_D_PT(15) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(4)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ85:LRU_RMT_VEC_D_PT(16) <=
    Eq(( WATERMARK_D(4) ) , STD_ULOGIC'('1'));
MQQ86:LRU_RMT_VEC_D_PT(17) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(1) & 
    WATERMARK_D(2) & WATERMARK_D(3)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ87:LRU_RMT_VEC_D_PT(18) <=
    Eq(( WATERMARK_D(1) & WATERMARK_D(2) & 
    WATERMARK_D(3) ) , STD_ULOGIC_VECTOR'("111"));
MQQ88:LRU_RMT_VEC_D_PT(19) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(2) & 
    WATERMARK_D(3) ) , STD_ULOGIC_VECTOR'("111"));
MQQ89:LRU_RMT_VEC_D_PT(20) <=
    Eq(( WATERMARK_D(2) & WATERMARK_D(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ90:LRU_RMT_VEC_D_PT(21) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(1) & 
    WATERMARK_D(3) ) , STD_ULOGIC_VECTOR'("111"));
MQQ91:LRU_RMT_VEC_D_PT(22) <=
    Eq(( WATERMARK_D(1) & WATERMARK_D(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ92:LRU_RMT_VEC_D_PT(23) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ93:LRU_RMT_VEC_D_PT(24) <=
    Eq(( WATERMARK_D(3) ) , STD_ULOGIC'('1'));
MQQ94:LRU_RMT_VEC_D_PT(25) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(1) & 
    WATERMARK_D(2) ) , STD_ULOGIC_VECTOR'("111"));
MQQ95:LRU_RMT_VEC_D_PT(26) <=
    Eq(( WATERMARK_D(1) & WATERMARK_D(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ96:LRU_RMT_VEC_D_PT(27) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ97:LRU_RMT_VEC_D_PT(28) <=
    Eq(( WATERMARK_D(2) ) , STD_ULOGIC'('1'));
MQQ98:LRU_RMT_VEC_D_PT(29) <=
    Eq(( WATERMARK_D(0) & WATERMARK_D(1)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ99:LRU_RMT_VEC_D_PT(30) <=
    Eq(( WATERMARK_D(1) ) , STD_ULOGIC'('1'));
MQQ100:LRU_RMT_VEC_D_PT(31) <=
    Eq(( WATERMARK_D(0) ) , STD_ULOGIC'('1'));
MQQ101:LRU_RMT_VEC_D_PT(32) <=
    '1';
-- Table LRU_RMT_VEC_D Signal Assignments for Outputs
MQQ102:LRU_RMT_VEC_D(0) <= 
    (LRU_RMT_VEC_D_PT(32));
MQQ103:LRU_RMT_VEC_D(1) <= 
    (LRU_RMT_VEC_D_PT(16) OR LRU_RMT_VEC_D_PT(24)
     OR LRU_RMT_VEC_D_PT(28) OR LRU_RMT_VEC_D_PT(30)
     OR LRU_RMT_VEC_D_PT(31));
MQQ104:LRU_RMT_VEC_D(2) <= 
    (LRU_RMT_VEC_D_PT(24) OR LRU_RMT_VEC_D_PT(28)
     OR LRU_RMT_VEC_D_PT(30) OR LRU_RMT_VEC_D_PT(31)
    );
MQQ105:LRU_RMT_VEC_D(3) <= 
    (LRU_RMT_VEC_D_PT(8) OR LRU_RMT_VEC_D_PT(28)
     OR LRU_RMT_VEC_D_PT(30) OR LRU_RMT_VEC_D_PT(31)
    );
MQQ106:LRU_RMT_VEC_D(4) <= 
    (LRU_RMT_VEC_D_PT(28) OR LRU_RMT_VEC_D_PT(30)
     OR LRU_RMT_VEC_D_PT(31));
MQQ107:LRU_RMT_VEC_D(5) <= 
    (LRU_RMT_VEC_D_PT(12) OR LRU_RMT_VEC_D_PT(20)
     OR LRU_RMT_VEC_D_PT(30) OR LRU_RMT_VEC_D_PT(31)
    );
MQQ108:LRU_RMT_VEC_D(6) <= 
    (LRU_RMT_VEC_D_PT(20) OR LRU_RMT_VEC_D_PT(30)
     OR LRU_RMT_VEC_D_PT(31));
MQQ109:LRU_RMT_VEC_D(7) <= 
    (LRU_RMT_VEC_D_PT(4) OR LRU_RMT_VEC_D_PT(30)
     OR LRU_RMT_VEC_D_PT(31));
MQQ110:LRU_RMT_VEC_D(8) <= 
    (LRU_RMT_VEC_D_PT(30) OR LRU_RMT_VEC_D_PT(31)
    );
MQQ111:LRU_RMT_VEC_D(9) <= 
    (LRU_RMT_VEC_D_PT(14) OR LRU_RMT_VEC_D_PT(22)
     OR LRU_RMT_VEC_D_PT(26) OR LRU_RMT_VEC_D_PT(31)
    );
MQQ112:LRU_RMT_VEC_D(10) <= 
    (LRU_RMT_VEC_D_PT(22) OR LRU_RMT_VEC_D_PT(26)
     OR LRU_RMT_VEC_D_PT(31));
MQQ113:LRU_RMT_VEC_D(11) <= 
    (LRU_RMT_VEC_D_PT(6) OR LRU_RMT_VEC_D_PT(26)
     OR LRU_RMT_VEC_D_PT(31));
MQQ114:LRU_RMT_VEC_D(12) <= 
    (LRU_RMT_VEC_D_PT(26) OR LRU_RMT_VEC_D_PT(31)
    );
MQQ115:LRU_RMT_VEC_D(13) <= 
    (LRU_RMT_VEC_D_PT(10) OR LRU_RMT_VEC_D_PT(18)
     OR LRU_RMT_VEC_D_PT(31));
MQQ116:LRU_RMT_VEC_D(14) <= 
    (LRU_RMT_VEC_D_PT(18) OR LRU_RMT_VEC_D_PT(31)
    );
MQQ117:LRU_RMT_VEC_D(15) <= 
    (LRU_RMT_VEC_D_PT(2) OR LRU_RMT_VEC_D_PT(31)
    );
MQQ118:LRU_RMT_VEC_D(16) <= 
    (LRU_RMT_VEC_D_PT(31));
MQQ119:LRU_RMT_VEC_D(17) <= 
    (LRU_RMT_VEC_D_PT(15) OR LRU_RMT_VEC_D_PT(23)
     OR LRU_RMT_VEC_D_PT(27) OR LRU_RMT_VEC_D_PT(29)
    );
MQQ120:LRU_RMT_VEC_D(18) <= 
    (LRU_RMT_VEC_D_PT(23) OR LRU_RMT_VEC_D_PT(27)
     OR LRU_RMT_VEC_D_PT(29));
MQQ121:LRU_RMT_VEC_D(19) <= 
    (LRU_RMT_VEC_D_PT(7) OR LRU_RMT_VEC_D_PT(27)
     OR LRU_RMT_VEC_D_PT(29));
MQQ122:LRU_RMT_VEC_D(20) <= 
    (LRU_RMT_VEC_D_PT(27) OR LRU_RMT_VEC_D_PT(29)
    );
MQQ123:LRU_RMT_VEC_D(21) <= 
    (LRU_RMT_VEC_D_PT(11) OR LRU_RMT_VEC_D_PT(19)
     OR LRU_RMT_VEC_D_PT(29));
MQQ124:LRU_RMT_VEC_D(22) <= 
    (LRU_RMT_VEC_D_PT(19) OR LRU_RMT_VEC_D_PT(29)
    );
MQQ125:LRU_RMT_VEC_D(23) <= 
    (LRU_RMT_VEC_D_PT(3) OR LRU_RMT_VEC_D_PT(29)
    );
MQQ126:LRU_RMT_VEC_D(24) <= 
    (LRU_RMT_VEC_D_PT(29));
MQQ127:LRU_RMT_VEC_D(25) <= 
    (LRU_RMT_VEC_D_PT(13) OR LRU_RMT_VEC_D_PT(21)
     OR LRU_RMT_VEC_D_PT(25));
MQQ128:LRU_RMT_VEC_D(26) <= 
    (LRU_RMT_VEC_D_PT(21) OR LRU_RMT_VEC_D_PT(25)
    );
MQQ129:LRU_RMT_VEC_D(27) <= 
    (LRU_RMT_VEC_D_PT(5) OR LRU_RMT_VEC_D_PT(25)
    );
MQQ130:LRU_RMT_VEC_D(28) <= 
    (LRU_RMT_VEC_D_PT(25));
MQQ131:LRU_RMT_VEC_D(29) <= 
    (LRU_RMT_VEC_D_PT(9) OR LRU_RMT_VEC_D_PT(17)
    );
MQQ132:LRU_RMT_VEC_D(30) <= 
    (LRU_RMT_VEC_D_PT(17));
MQQ133:LRU_RMT_VEC_D(31) <= 
    (LRU_RMT_VEC_D_PT(1));

mmucr1_b0_cpy_d     <=  mmucr1_d(0);
lru_rmt_vec         <=  lru_rmt_vec_q;
lru_watermark_mask  <=  not lru_rmt_vec_q;
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
entry_valid_watermarked  <=  entry_valid_q or lru_watermark_mask;
-- lru_update_event
-- 0: tlb reload
-- 1: invalidate snoop
-- 2: csync or isync enabled
-- 3: eratwe WS=0
-- 4: load or store hit
-- 5: cam write type events
-- 6: cam invalidate type events
-- 7: cam translation type events
-- 8: superset, ex2
-- 9: superset, delayed to ex3
-- logic for the LRU reset and set bit vectors
-- ?TABLE lru_set_reset_vec LISTING(final) OPTIMIZE PARMS(ON-SET, OFF-SET);
--
-- Final Table Listing
--      *INPUTS*========================================================================================================*OUTPUTS*=============================================================*
--      |                                                                                                               |                                                                     |
--      | lru_update_event_q                                                                                            |  lru_reset_vec                                                      |
--      | |         entry_valid_watermarked                                                                             |  |                                 lru_set_vec                      |
--      | |         |                                lru_q                                                              |  |                                 |                                |
--      | |         |                                |                               entry_match_q                      |  |                                 |                                |
--      | |         |                                |                               |                                  |  |                                 |                                |
--      | |         |                                |                               |                                  |  |                                 |                                |
--      | |         |         1111111111222222222233 |        1111111111222222222233 |         1111111111222222222233   |  |        1111111111222222222233   |        1111111111222222222233  |
--      | 012345678 01234567890123456789012345678901 1234567890123456789012345678901 01234567890123456789012345678901   |  1234567890123456789012345678901   1234567890123456789012345678901  |
--      *TYPE*==========================================================================================================+=====================================================================+
--      | PPPPPPPPP PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP   |  PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP   PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP  |
--      *POLARITY*----------------------------------------------------------------------------------------------------->|  +++++++++++++++++++++++++++++++   +++++++++++++++++++++++++++++++  |
--      *PHASE*-------------------------------------------------------------------------------------------------------->|  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT   TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT  |
--      *OPTIMIZE*----------------------------------------------------------------------------------------------------->|   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB   |
--      *TERMS*=========================================================================================================+=====================================================================+
--    1 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000000000000000001   |  1.1...1.......1...............1   ...............................  |
--    2 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000000000000000001-   |  1.1...1.......1................   ...............................  |
--    3 | -----001- 1111111111111111111111111111111- ------------------------------- 0000000000000000000000000000001-   |  ...............................   ..............................1  |
--    4 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000000000000000001--   |  1.1...1......................1.   ...............................  |
--    5 | -----001- 111111111111111111111111111111-- ------------------------------- 0000000000000000000000000000-1--   |  ...............................   ..............1................  |
--    6 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000000000000001---   |  1.1...1........................   ..............1..............1.  |
--    7 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000000000000001----   |  1.1..........1..............1..   ...............................  |
--    8 | -----001- 1111111111111111111111111111---- ------------------------------- 000000000000000000000000---1----   |  ...............................   ......1........................  |
--    9 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000000000000001-----   |  1.1..........1.................   ......1.....................1..  |
--   10 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000000000001------   |  1.1........................1...   ...............................  |
--   11 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000000000000-1------   |  ...............................   ......1......1.................  |
--   12 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000000000001-------   |  1.1............................   ......1......1.............1...  |
--   13 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000000000001--------   |  1....1......1.............1....   ...............................  |
--   14 | -----001- 111111111111111111111111-------- ------------------------------- 0000000000000000-------1--------   |  ...............................   ..1............................  |
--   15 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000000001---------   |  1....1......1..................   ..1.......................1....  |
--   16 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000000001----------   |  1....1...................1.....   ...............................  |
--   17 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000000-1----------   |  ...............................   ..1.........1..................  |
--   18 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000000001-----------   |  1....1.........................   ..1.........1............1.....  |
--   19 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000001------------   |  1..........1............1......   ...............................  |
--   20 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000---1------------   |  ...............................   ..1..1.........................  |
--   21 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000001-------------   |  1..........1...................   ..1..1..................1......  |
--   22 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000001--------------   |  1......................1.......   ...............................  |
--   23 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000-1--------------   |  ...............................   ..1..1.....1...................  |
--   24 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000001---------------   |  ...............................   ..1..1.....1...........1.......  |
--   25 | -----001- ----------------1111111111111111 ------------------------------- 00000000000000001---------------   |  1..............................   ...............................  |
--   26 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000001----------------   |  .1..1.....1...........1........   ...............................  |
--   27 | -----001- 1111111111111111---------------- ------------------------------- ---------------1----------------   |  ...............................   1..............................  |
--   28 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000001-----------------   |  .1..1.....1....................   1.....................1........  |
--   29 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000001------------------   |  .1..1................1.........   ...............................  |
--   30 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000-1------------------   |  ...............................   1.........1....................  |
--   31 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000001-------------------   |  .1..1..........................   1.........1..........1.........  |
--   32 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000001--------------------   |  .1.......1..........1..........   ...............................  |
--   33 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000---1--------------------   |  ...............................   1...1..........................  |
--   34 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000001---------------------   |  .1.......1.....................   1...1...............1..........  |
--   35 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000001----------------------   |  .1.................1...........   ...............................  |
--   36 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000-1----------------------   |  ...............................   1...1....1.....................  |
--   37 | -----001- 11111111111111111111111111111111 ------------------------------- 000000001-----------------------   |  ...............................   1...1....1.........1...........  |
--   38 | -----001- --------111111111111111111111111 ------------------------------- 000000001-----------------------   |  .1.............................   ...............................  |
--   39 | -----001- 11111111111111111111111111111111 ------------------------------- 00000001------------------------   |  ...1....1.........1............   ...............................  |
--   40 | -----001- 11111111111111111111111111111111 ------------------------------- -------1------------------------   |  ...............................   11.............................  |
--   41 | -----001- 11111111111111111111111111111111 ------------------------------- 0000001-------------------------   |  ...1....1......................   11................1............  |
--   42 | -----001- 11111111111111111111111111111111 ------------------------------- 000001--------------------------   |  ...1.............1.............   ...............................  |
--   43 | -----001- 11111111111111111111111111111111 ------------------------------- 0000-1--------------------------   |  ...............................   11......1......................  |
--   44 | -----001- 11111111111111111111111111111111 ------------------------------- 00001---------------------------   |  ...............................   11......1........1.............  |
--   45 | -----001- ----1111111111111111111111111111 ------------------------------- 00001---------------------------   |  ...1...........................   ...............................  |
--   46 | -----001- 11111111111111111111111111111111 ------------------------------- 0001----------------------------   |  .......1........1..............   ...............................  |
--   47 | -----001- 11111111111111111111111111111111 ------------------------------- ---1----------------------------   |  ...............................   11.1...........................  |
--   48 | -----001- 11111111111111111111111111111111 ------------------------------- 001-----------------------------   |  ...............................   11.1............1..............  |
--   49 | -----001- --111111111111111111111111111111 ------------------------------- 001-----------------------------   |  .......1.......................   ...............................  |
--   50 | -----001- -1111111111111111111111111111111 ------------------------------- 01------------------------------   |  ...............1...............   ...............................  |
--   51 | -----001- 11111111111111111111111111111111 ------------------------------- -1------------------------------   |  ...............................   11.1...1.......................  |
--   52 | -----001- 11111111111111111111111111111111 ------------------------------- 1-------------------------------   |  ...............................   11.1...1.......1...............  |
--   53 | -----1--- 1111111111111111111111111111111- 1-1---1-------1---------------0 --------------------------------   |  ...............................   ..............................1  |
--   54 | -----1--- 111111111111111111111111111111-1 1-1---1-------1---------------1 --------------------------------   |  ..............................1   ...............................  |
--   55 | -----1--- 11111111111111111111111111111-11 1-1---1-------0--------------0- --------------------------------   |  ...............................   .............................1.  |
--   56 | -----1--- 1111111111111111111111111111-111 1-1---1-------0--------------1- --------------------------------   |  .............................1.   ...............................  |
--   57 | -----1--- 111111111111111111111111111-1111 1-1---0------1--------------0-- --------------------------------   |  ...............................   ............................1..  |
--   58 | -----1--- 11111111111111111111111111-11111 1-1---0------1--------------1-- --------------------------------   |  ............................1..   ...............................  |
--   59 | -----1--- 1111111111111111111111111-111111 1-1---0------0-------------0--- --------------------------------   |  ...............................   ...........................1...  |
--   60 | -----1--- 111111111111111111111111-1111111 1-1---0------0-------------1--- --------------------------------   |  ...........................1...   ...............................  |
--   61 | -----1--- 11111111111111111111111-11111111 1-0--1------1-------------0---- --------------------------------   |  ...............................   ..........................1....  |
--   62 | -----1--- 1111111111111111111111-111111111 1-0--1------1-------------1---- --------------------------------   |  ..........................1....   ...............................  |
--   63 | -----1--- 111111111111111111111-1111111111 1-0--1------0------------0----- --------------------------------   |  ...............................   .........................1.....  |
--   64 | -----1--- 11111111111111111111-11111111111 1-0--1------0------------1----- --------------------------------   |  .........................1.....   ...............................  |
--   65 | -----1--- 1111111111111111111-111111111111 1-0--0-----1------------0------ --------------------------------   |  ...............................   ........................1......  |
--   66 | -----1--- 111111111111111111-1111111111111 1-0--0-----1------------1------ --------------------------------   |  ........................1......   ...............................  |
--   67 | -----1--- 11111111111111111-11111111111111 1-0--0-----0-----------0------- --------------------------------   |  ...............................   .......................1.......  |
--   68 | -----1--- 1111111111111111-111111111111111 1-0--0-----0-----------1------- --------------------------------   |  .......................1.......   ...............................  |
--   69 | -----1--- 111111111111111-1111111111111111 01--1-----1-----------0-------- --------------------------------   |  ...............................   ......................1........  |
--   70 | -----1--- 11111111111111-11111111111111111 01--1-----1-----------1-------- --------------------------------   |  ......................1........   ...............................  |
--   71 | -----1--- 1111111111111-111111111111111111 01--1-----0----------0--------- --------------------------------   |  ...............................   .....................1.........  |
--   72 | -----1--- 111111111111-1111111111111111111 01--1-----0----------1--------- --------------------------------   |  .....................1.........   ...............................  |
--   73 | -----1--- 11111111111-11111111111111111111 01--0----1----------0---------- --------------------------------   |  ...............................   ....................1..........  |
--   74 | -----1--- 1111111111-111111111111111111111 01--0----1----------1---------- --------------------------------   |  ....................1..........   ...............................  |
--   75 | -----1--- 111111111-1111111111111111111111 01--0----0---------0----------- --------------------------------   |  ...............................   ...................1...........  |
--   76 | -----1--- 11111111-11111111111111111111111 01--0----0---------1----------- --------------------------------   |  ...................1...........   ...............................  |
--   77 | -----1--- 1111111-111111111111111111111111 00-1----1---------0------------ --------------------------------   |  ...............................   ..................1............  |
--   78 | -----1--- 111111-1111111111111111111111111 00-1----1---------1------------ --------------------------------   |  ..................1............   ...............................  |
--   79 | -----1--- 11111-11111111111111111111111111 00-1----0--------0------------- --------------------------------   |  ...............................   .................1.............  |
--   80 | -----1--- 1111-111111111111111111111111111 00-1----0--------1------------- --------------------------------   |  .................1.............   ...............................  |
--   81 | -----1--- 111-1111111111111111111111111111 00-0---1--------0-------------- --------------------------------   |  ...............................   ................1..............  |
--   82 | -----1--- 11-11111111111111111111111111111 00-0---1--------1-------------- --------------------------------   |  ................1..............   ...............................  |
--   83 | -----1--- 1-111111111111111111111111111111 00-0---0-------0--------------- --------------------------------   |  ...............................   ...............1...............  |
--   84 | -----1--- -1111111111111111111111111111111 00-0---0-------1--------------- --------------------------------   |  ...............1...............   ...............................  |
--   85 | -----1--- 111111111111111111111111111111-- 1-1---1-------0---------------- --------------------------------   |  ...............................   ..............1................  |
--   86 | -----1--- 1111111111111111111111111111--11 1-1---1-------1---------------- --------------------------------   |  ..............1................   ...............................  |
--   87 | -----1--- 11111111111111111111111111--1111 1-1---0------0----------------- --------------------------------   |  ...............................   .............1.................  |
--   88 | -----1--- 111111111111111111111111--111111 1-1---0------1----------------- --------------------------------   |  .............1.................   ...............................  |
--   89 | -----1--- 1111111111111111111111--11111111 1-0--1------0------------------ --------------------------------   |  ...............................   ............1..................  |
--   90 | -----1--- 11111111111111111111--1111111111 1-0--1------1------------------ --------------------------------   |  ............1..................   ...............................  |
--   91 | -----1--- 111111111111111111--111111111111 1-0--0-----0------------------- --------------------------------   |  ...............................   ...........1...................  |
--   92 | -----1--- 1111111111111111--11111111111111 1-0--0-----1------------------- --------------------------------   |  ...........1...................   ...............................  |
--   93 | -----1--- 11111111111111--1111111111111111 01--1-----0-------------------- --------------------------------   |  ...............................   ..........1....................  |
--   94 | -----1--- 111111111111--111111111111111111 01--1-----1-------------------- --------------------------------   |  ..........1....................   ...............................  |
--   95 | -----1--- 1111111111--11111111111111111111 01--0----0--------------------- --------------------------------   |  ...............................   .........1.....................  |
--   96 | -----1--- 11111111--1111111111111111111111 01--0----1--------------------- --------------------------------   |  .........1.....................   ...............................  |
--   97 | -----1--- 111111--111111111111111111111111 00-1----0---------------------- --------------------------------   |  ...............................   ........1......................  |
--   98 | -----1--- 1111--11111111111111111111111111 00-1----1---------------------- --------------------------------   |  ........1......................   ...............................  |
--   99 | -----1--- 11--1111111111111111111111111111 00-0---0----------------------- --------------------------------   |  ...............................   .......1.......................  |
--   100 | -----1--- --111111111111111111111111111111 00-0---1----------------------- --------------------------------   |  .......1.......................   ...............................  |
--   101 | -----1--- 1111111111111111111111111111---- 1-1---0------------------------ --------------------------------   |  ...............................   ......1........................  |
--   102 | -----1--- 111111111111111111111111----1111 1-1---1------------------------ --------------------------------   |  ......1........................   ...............................  |
--   103 | -----1--- 11111111111111111111----11111111 1-0--0------------------------- --------------------------------   |  ...............................   .....1.........................  |
--   104 | -----1--- 1111111111111111----111111111111 1-0--1------------------------- --------------------------------   |  .....1.........................   ...............................  |
--   105 | -----1--- 111111111111----1111111111111111 01--0-------------------------- --------------------------------   |  ...............................   ....1..........................  |
--   106 | -----1--- 11111111----11111111111111111111 01--1-------------------------- --------------------------------   |  ....1..........................   ...............................  |
--   107 | -----1--- 1111----111111111111111111111111 00-0--------------------------- --------------------------------   |  ...............................   ...1...........................  |
--   108 | -----1--- ----1111111111111111111111111111 00-1--------------------------- --------------------------------   |  ...1...........................   ...............................  |
--   109 | -----1--- 111111111111111111111111-------- 1-0---------------------------- --------------------------------   |  ...............................   ..1............................  |
--   110 | -----1--- 1111111111111111--------11111111 1-1---------------------------- --------------------------------   |  ..1............................   ...............................  |
--   111 | -----1--- 11111111--------1111111111111111 00----------------------------- --------------------------------   |  ...............................   .1.............................  |
--   112 | -----1--- --------111111111111111111111111 01----------------------------- --------------------------------   |  .1.............................   ...............................  |
--   113 | -----1--- 1111111111111111---------------- 0------------------------------ --------------------------------   |  ...............................   1..............................  |
--   114 | -----1--- ----------------1111111111111111 1------------------------------ --------------------------------   |  1..............................   ...............................  |
--   115 | --------- 11111111111111111111111111111110 ------------------------------- --------------------------------   |  ...............................   1.1...1.......1...............1  |
--   116 | --------- 1111111111111111111111111111110- ------------------------------- --------------------------------   |  ..............................1   1.1...1.......1................  |
--   117 | --------- 111111111111111111111111111110-- ------------------------------- --------------------------------   |  ...............................   1.1...1......................1.  |
--   118 | --------- 1111111111111111111111111111-0-- ------------------------------- --------------------------------   |  ..............1................   ...............................  |
--   119 | --------- 11111111111111111111111111110--- ------------------------------- --------------------------------   |  ..............1..............1.   1.1...1........................  |
--   120 | --------- 1111111111111111111111111110---- ------------------------------- --------------------------------   |  ...............................   1.1..........1..............1..  |
--   121 | --------- 111111111111111111111111---0---- ------------------------------- --------------------------------   |  ......1........................   ...............................  |
--   122 | --------- 111111111111111111111111110----- ------------------------------- --------------------------------   |  ......1.....................1..   1.1..........1.................  |
--   123 | --------- 11111111111111111111111110------ ------------------------------- --------------------------------   |  ...............................   1.1........................1...  |
--   124 | --------- 111111111111111111111111-0------ ------------------------------- --------------------------------   |  ......1......1.................   ...............................  |
--   125 | --------- 1111111111111111111111110------- ------------------------------- --------------------------------   |  ......1......1.............1...   1.1............................  |
--   126 | --------- 111111111111111111111110-------- ------------------------------- --------------------------------   |  ...............................   1....1......1.............1....  |
--   127 | --------- 1111111111111111-------0-------- ------------------------------- --------------------------------   |  ..1............................   ...............................  |
--   128 | --------- 11111111111111111111110--------- ------------------------------- --------------------------------   |  ..1.......................1....   1....1......1..................  |
--   129 | --------- 1111111111111111111110---------- ------------------------------- --------------------------------   |  ...............................   1....1...................1.....  |
--   130 | --------- 11111111111111111111-0---------- ------------------------------- --------------------------------   |  ..1.........1..................   ...............................  |
--   131 | --------- 111111111111111111110----------- ------------------------------- --------------------------------   |  ..1.........1............1.....   1....1.........................  |
--   132 | --------- 11111111111111111110------------ ------------------------------- --------------------------------   |  ...............................   1..........1............1......  |
--   133 | --------- 1111111111111111---0------------ ------------------------------- --------------------------------   |  ..1..1.........................   ...............................  |
--   134 | --------- 1111111111111111110------------- ------------------------------- --------------------------------   |  ..1..1..................1......   1..........1...................  |
--   135 | --------- 111111111111111110-------------- ------------------------------- --------------------------------   |  ...............................   1......................1.......  |
--   136 | --------- 1111111111111111-0-------------- ------------------------------- --------------------------------   |  ..1..1.....1...................   ...............................  |
--   137 | --------- 11111111111111110--------------- ------------------------------- --------------------------------   |  ..1..1.....1...........1.......   1..............................  |
--   138 | --------- 1111111111111110---------------- ------------------------------- --------------------------------   |  ...............................   .1..1.....1...........1........  |
--   139 | --------- ---------------0---------------- ------------------------------- --------------------------------   |  1..............................   ...............................  |
--   140 | --------- 111111111111110----------------- ------------------------------- --------------------------------   |  1.....................1........   .1..1.....1....................  |
--   141 | --------- 11111111111110------------------ ------------------------------- --------------------------------   |  ...............................   .1..1................1.........  |
--   142 | --------- 111111111111-0------------------ ------------------------------- --------------------------------   |  1.........1....................   ...............................  |
--   143 | --------- 1111111111110------------------- ------------------------------- --------------------------------   |  1.........1..........1.........   .1..1..........................  |
--   144 | --------- 111111111110-------------------- ------------------------------- --------------------------------   |  ...............................   .1.......1..........1..........  |
--   145 | --------- 11111111---0-------------------- ------------------------------- --------------------------------   |  1...1..........................   ...............................  |
--   146 | --------- 11111111110--------------------- ------------------------------- --------------------------------   |  1...1...............1..........   .1.......1.....................  |
--   147 | --------- 1111111110---------------------- ------------------------------- --------------------------------   |  ...............................   .1.................1...........  |
--   148 | --------- 11111111-0---------------------- ------------------------------- --------------------------------   |  1...1....1.....................   ...............................  |
--   149 | --------- 111111110----------------------- ------------------------------- --------------------------------   |  1...1....1.........1...........   .1.............................  |
--   150 | --------- 11111110------------------------ ------------------------------- --------------------------------   |  ...............................   ...1....1.........1............  |
--   151 | --------- -------0------------------------ ------------------------------- --------------------------------   |  11.............................   ...............................  |
--   152 | --------- 1111110------------------------- ------------------------------- --------------------------------   |  11................1............   ...1....1......................  |
--   153 | --------- 111110-------------------------- ------------------------------- --------------------------------   |  ...............................   ...1.............1.............  |
--   154 | --------- 1111-0-------------------------- ------------------------------- --------------------------------   |  11......1......................   ...............................  |
--   155 | --------- 11110--------------------------- ------------------------------- --------------------------------   |  11......1........1.............   ...1...........................  |
--   156 | --------- 1110---------------------------- ------------------------------- --------------------------------   |  ...............................   .......1........1..............  |
--   157 | --------- ---0---------------------------- ------------------------------- --------------------------------   |  11.1...........................   ...............................  |
--   158 | --------- 110----------------------------- ------------------------------- --------------------------------   |  11.1............1..............   .......1.......................  |
--   159 | --------- 10------------------------------ ------------------------------- --------------------------------   |  ...............................   ...............1...............  |
--   160 | --------- -0------------------------------ ------------------------------- --------------------------------   |  11.1...1.......................   ...............................  |
--   161 | --------- 0------------------------------- ------------------------------- --------------------------------   |  11.1...1.......1...............   ...............................  |
--      *=====================================================================================================================================================================================*
--
-- Table LRU_SET_RESET_VEC Signal Assignments for Product Terms
MQQ134:LRU_SET_RESET_VEC_PT(1) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(24) & 
    ENTRY_MATCH_Q(25) & ENTRY_MATCH_Q(26) & 
    ENTRY_MATCH_Q(27) & ENTRY_MATCH_Q(28) & 
    ENTRY_MATCH_Q(29) & ENTRY_MATCH_Q(30) & 
    ENTRY_MATCH_Q(31) ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000000000" &
"000000000001"));
MQQ135:LRU_SET_RESET_VEC_PT(2) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(24) & 
    ENTRY_MATCH_Q(25) & ENTRY_MATCH_Q(26) & 
    ENTRY_MATCH_Q(27) & ENTRY_MATCH_Q(28) & 
    ENTRY_MATCH_Q(29) & ENTRY_MATCH_Q(30)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111110000000000000000000000000000001"));
MQQ136:LRU_SET_RESET_VEC_PT(3) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_MATCH_Q(0) & ENTRY_MATCH_Q(1) & 
    ENTRY_MATCH_Q(2) & ENTRY_MATCH_Q(3) & 
    ENTRY_MATCH_Q(4) & ENTRY_MATCH_Q(5) & 
    ENTRY_MATCH_Q(6) & ENTRY_MATCH_Q(7) & 
    ENTRY_MATCH_Q(8) & ENTRY_MATCH_Q(9) & 
    ENTRY_MATCH_Q(10) & ENTRY_MATCH_Q(11) & 
    ENTRY_MATCH_Q(12) & ENTRY_MATCH_Q(13) & 
    ENTRY_MATCH_Q(14) & ENTRY_MATCH_Q(15) & 
    ENTRY_MATCH_Q(16) & ENTRY_MATCH_Q(17) & 
    ENTRY_MATCH_Q(18) & ENTRY_MATCH_Q(19) & 
    ENTRY_MATCH_Q(20) & ENTRY_MATCH_Q(21) & 
    ENTRY_MATCH_Q(22) & ENTRY_MATCH_Q(23) & 
    ENTRY_MATCH_Q(24) & ENTRY_MATCH_Q(25) & 
    ENTRY_MATCH_Q(26) & ENTRY_MATCH_Q(27) & 
    ENTRY_MATCH_Q(28) & ENTRY_MATCH_Q(29) & 
    ENTRY_MATCH_Q(30) ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111000000000000000000000" &
"0000000001"));
MQQ137:LRU_SET_RESET_VEC_PT(4) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(24) & 
    ENTRY_MATCH_Q(25) & ENTRY_MATCH_Q(26) & 
    ENTRY_MATCH_Q(27) & ENTRY_MATCH_Q(28) & 
    ENTRY_MATCH_Q(29) ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000000000" &
"0000000001"));
MQQ138:LRU_SET_RESET_VEC_PT(5) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(24) & 
    ENTRY_MATCH_Q(25) & ENTRY_MATCH_Q(26) & 
    ENTRY_MATCH_Q(27) & ENTRY_MATCH_Q(29)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111100000000000000000000000000001"));
MQQ139:LRU_SET_RESET_VEC_PT(6) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(24) & 
    ENTRY_MATCH_Q(25) & ENTRY_MATCH_Q(26) & 
    ENTRY_MATCH_Q(27) & ENTRY_MATCH_Q(28)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000000000000000001"));
MQQ140:LRU_SET_RESET_VEC_PT(7) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(24) & 
    ENTRY_MATCH_Q(25) & ENTRY_MATCH_Q(26) & 
    ENTRY_MATCH_Q(27) ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000000000" &
"00000001"));
MQQ141:LRU_SET_RESET_VEC_PT(8) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(27)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111110000000000000000000000001"));
MQQ142:LRU_SET_RESET_VEC_PT(9) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(24) & 
    ENTRY_MATCH_Q(25) & ENTRY_MATCH_Q(26)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111000000000000000000000000001"));
MQQ143:LRU_SET_RESET_VEC_PT(10) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(24) & 
    ENTRY_MATCH_Q(25) ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000000000" &
"000001"));
MQQ144:LRU_SET_RESET_VEC_PT(11) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(25)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111110000000000000000000000001"));
MQQ145:LRU_SET_RESET_VEC_PT(12) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) & ENTRY_MATCH_Q(24)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111110000000000000000000000001"));
MQQ146:LRU_SET_RESET_VEC_PT(13) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22) & 
    ENTRY_MATCH_Q(23) ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000000000" &
"0001"));
MQQ147:LRU_SET_RESET_VEC_PT(14) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(23)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111100000000000000001"));
MQQ148:LRU_SET_RESET_VEC_PT(15) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) & ENTRY_MATCH_Q(22)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000000000001"));
MQQ149:LRU_SET_RESET_VEC_PT(16) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20) & 
    ENTRY_MATCH_Q(21) ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000000000" &
"01"));
MQQ150:LRU_SET_RESET_VEC_PT(17) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(21)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111000000000000000000001"));
MQQ151:LRU_SET_RESET_VEC_PT(18) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) & ENTRY_MATCH_Q(20)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111000000000000000000001"));
MQQ152:LRU_SET_RESET_VEC_PT(19) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18) & 
    ENTRY_MATCH_Q(19) ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000000001")
);
MQQ153:LRU_SET_RESET_VEC_PT(20) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(19)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000001"));
MQQ154:LRU_SET_RESET_VEC_PT(21) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) & ENTRY_MATCH_Q(18)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111110000000000000000001"));
MQQ155:LRU_SET_RESET_VEC_PT(22) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16) & 
    ENTRY_MATCH_Q(17) ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111000000000000000001")
);
MQQ156:LRU_SET_RESET_VEC_PT(23) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(17)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000001"));
MQQ157:LRU_SET_RESET_VEC_PT(24) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000000001"));
MQQ158:LRU_SET_RESET_VEC_PT(25) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) & ENTRY_MATCH_Q(16)
     ) , STD_ULOGIC_VECTOR'("001111111111111111100000000000000001"));
MQQ159:LRU_SET_RESET_VEC_PT(26) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111110000000000000001"));
MQQ160:LRU_SET_RESET_VEC_PT(27) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(15)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111"));
MQQ161:LRU_SET_RESET_VEC_PT(28) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111000000000000001"));
MQQ162:LRU_SET_RESET_VEC_PT(29) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000000001"));
MQQ163:LRU_SET_RESET_VEC_PT(30) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(13)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111110000000000001"));
MQQ164:LRU_SET_RESET_VEC_PT(31) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111110000000000001"));
MQQ165:LRU_SET_RESET_VEC_PT(32) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111000000000001"));
MQQ166:LRU_SET_RESET_VEC_PT(33) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(11)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111000000001"));
MQQ167:LRU_SET_RESET_VEC_PT(34) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000000001"));
MQQ168:LRU_SET_RESET_VEC_PT(35) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111110000000001"));
MQQ169:LRU_SET_RESET_VEC_PT(36) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(9)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111000000001"));
MQQ170:LRU_SET_RESET_VEC_PT(37) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111000000001"));
MQQ171:LRU_SET_RESET_VEC_PT(38) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111000000001"));
MQQ172:LRU_SET_RESET_VEC_PT(39) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100000001"));
MQQ173:LRU_SET_RESET_VEC_PT(40) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(7)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111111"));
MQQ174:LRU_SET_RESET_VEC_PT(41) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111110000001"));
MQQ175:LRU_SET_RESET_VEC_PT(42) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111000001"));
MQQ176:LRU_SET_RESET_VEC_PT(43) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(5)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100001"));
MQQ177:LRU_SET_RESET_VEC_PT(44) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111111111111111111100001"));
MQQ178:LRU_SET_RESET_VEC_PT(45) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111100001"));
MQQ179:LRU_SET_RESET_VEC_PT(46) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111110001"));
MQQ180:LRU_SET_RESET_VEC_PT(47) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(3)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111111"));
MQQ181:LRU_SET_RESET_VEC_PT(48) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111111111111111111001"));
MQQ182:LRU_SET_RESET_VEC_PT(49) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111001"));
MQQ183:LRU_SET_RESET_VEC_PT(50) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    ENTRY_MATCH_Q(0) & ENTRY_MATCH_Q(1)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111101"));
MQQ184:LRU_SET_RESET_VEC_PT(51) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(1)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111111"));
MQQ185:LRU_SET_RESET_VEC_PT(52) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & ENTRY_MATCH_Q(0)
     ) , STD_ULOGIC_VECTOR'("001111111111111111111111111111111111"));
MQQ186:LRU_SET_RESET_VEC_PT(53) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(15) & 
    LRU_Q(31) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111111110"));
MQQ187:LRU_SET_RESET_VEC_PT(54) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(15) & 
    LRU_Q(31) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111111111"));
MQQ188:LRU_SET_RESET_VEC_PT(55) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(15) & 
    LRU_Q(30) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111111100"));
MQQ189:LRU_SET_RESET_VEC_PT(56) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(15) & 
    LRU_Q(30) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111111101"));
MQQ190:LRU_SET_RESET_VEC_PT(57) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(14) & 
    LRU_Q(29) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111111010"));
MQQ191:LRU_SET_RESET_VEC_PT(58) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(14) & 
    LRU_Q(29) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111111011"));
MQQ192:LRU_SET_RESET_VEC_PT(59) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(14) & 
    LRU_Q(28) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111111000"));
MQQ193:LRU_SET_RESET_VEC_PT(60) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(14) & 
    LRU_Q(28) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111111001"));
MQQ194:LRU_SET_RESET_VEC_PT(61) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(13) & 
    LRU_Q(27) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111110110"));
MQQ195:LRU_SET_RESET_VEC_PT(62) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(13) & 
    LRU_Q(27) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111110111"));
MQQ196:LRU_SET_RESET_VEC_PT(63) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(13) & 
    LRU_Q(26) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111110100"));
MQQ197:LRU_SET_RESET_VEC_PT(64) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(13) & 
    LRU_Q(26) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111110101"));
MQQ198:LRU_SET_RESET_VEC_PT(65) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(12) & 
    LRU_Q(25) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111110010"));
MQQ199:LRU_SET_RESET_VEC_PT(66) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(12) & 
    LRU_Q(25) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111110011"));
MQQ200:LRU_SET_RESET_VEC_PT(67) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(12) & 
    LRU_Q(24) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111110000"));
MQQ201:LRU_SET_RESET_VEC_PT(68) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(12) & 
    LRU_Q(24) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111110001"));
MQQ202:LRU_SET_RESET_VEC_PT(69) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(11) & 
    LRU_Q(23) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111101110"));
MQQ203:LRU_SET_RESET_VEC_PT(70) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(11) & 
    LRU_Q(23) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111101111"));
MQQ204:LRU_SET_RESET_VEC_PT(71) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(11) & 
    LRU_Q(22) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111101100"));
MQQ205:LRU_SET_RESET_VEC_PT(72) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(11) & 
    LRU_Q(22) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111101101"));
MQQ206:LRU_SET_RESET_VEC_PT(73) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(10) & 
    LRU_Q(21) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111101010"));
MQQ207:LRU_SET_RESET_VEC_PT(74) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(10) & 
    LRU_Q(21) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111101011"));
MQQ208:LRU_SET_RESET_VEC_PT(75) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(10) & 
    LRU_Q(20) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111101000"));
MQQ209:LRU_SET_RESET_VEC_PT(76) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(10) & 
    LRU_Q(20) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111101001"));
MQQ210:LRU_SET_RESET_VEC_PT(77) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(9) & 
    LRU_Q(19) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111100110"));
MQQ211:LRU_SET_RESET_VEC_PT(78) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(9) & 
    LRU_Q(19) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111100111"));
MQQ212:LRU_SET_RESET_VEC_PT(79) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(9) & 
    LRU_Q(18) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111100100"));
MQQ213:LRU_SET_RESET_VEC_PT(80) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(9) & 
    LRU_Q(18) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111100101"));
MQQ214:LRU_SET_RESET_VEC_PT(81) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(8) & 
    LRU_Q(17) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111100010"));
MQQ215:LRU_SET_RESET_VEC_PT(82) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(8) & 
    LRU_Q(17) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111100011"));
MQQ216:LRU_SET_RESET_VEC_PT(83) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(8) & 
    LRU_Q(16) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111100000"));
MQQ217:LRU_SET_RESET_VEC_PT(84) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(8) & 
    LRU_Q(16) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111111100001"));
MQQ218:LRU_SET_RESET_VEC_PT(85) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(7) & 
    LRU_Q(15) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111111110"));
MQQ219:LRU_SET_RESET_VEC_PT(86) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(7) & 
    LRU_Q(15) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111111111"));
MQQ220:LRU_SET_RESET_VEC_PT(87) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(7) & 
    LRU_Q(14) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111111100"));
MQQ221:LRU_SET_RESET_VEC_PT(88) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(7) & 
    LRU_Q(14) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111111101"));
MQQ222:LRU_SET_RESET_VEC_PT(89) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(6) & 
    LRU_Q(13) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111111010"));
MQQ223:LRU_SET_RESET_VEC_PT(90) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(6) & 
    LRU_Q(13) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111111011"));
MQQ224:LRU_SET_RESET_VEC_PT(91) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(6) & 
    LRU_Q(12) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111111000"));
MQQ225:LRU_SET_RESET_VEC_PT(92) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(6) & 
    LRU_Q(12) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111111001"));
MQQ226:LRU_SET_RESET_VEC_PT(93) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(5) & 
    LRU_Q(11) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111110110"));
MQQ227:LRU_SET_RESET_VEC_PT(94) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(5) & 
    LRU_Q(11) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111110111"));
MQQ228:LRU_SET_RESET_VEC_PT(95) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(5) & 
    LRU_Q(10) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111110100"));
MQQ229:LRU_SET_RESET_VEC_PT(96) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(5) & 
    LRU_Q(10) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111110101"));
MQQ230:LRU_SET_RESET_VEC_PT(97) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(4) & 
    LRU_Q(9) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111110010"));
MQQ231:LRU_SET_RESET_VEC_PT(98) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(4) & 
    LRU_Q(9) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111110011"));
MQQ232:LRU_SET_RESET_VEC_PT(99) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(4) & 
    LRU_Q(8) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111110000"));
MQQ233:LRU_SET_RESET_VEC_PT(100) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(4) & 
    LRU_Q(8) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111110001"));
MQQ234:LRU_SET_RESET_VEC_PT(101) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(7)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111110"));
MQQ235:LRU_SET_RESET_VEC_PT(102) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(7)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111111"));
MQQ236:LRU_SET_RESET_VEC_PT(103) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(6)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111100"));
MQQ237:LRU_SET_RESET_VEC_PT(104) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(6)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111101"));
MQQ238:LRU_SET_RESET_VEC_PT(105) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(5)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111010"));
MQQ239:LRU_SET_RESET_VEC_PT(106) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(5)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111011"));
MQQ240:LRU_SET_RESET_VEC_PT(107) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(4)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111000"));
MQQ241:LRU_SET_RESET_VEC_PT(108) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(4)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111001"));
MQQ242:LRU_SET_RESET_VEC_PT(109) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & LRU_Q(1) & 
    LRU_Q(3) ) , STD_ULOGIC_VECTOR'("111111111111111111111111110"));
MQQ243:LRU_SET_RESET_VEC_PT(110) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(3) ) , STD_ULOGIC_VECTOR'("111111111111111111111111111"));
MQQ244:LRU_SET_RESET_VEC_PT(111) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) ) , STD_ULOGIC_VECTOR'("111111111111111111111111100"));
MQQ245:LRU_SET_RESET_VEC_PT(112) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1) & 
    LRU_Q(2) ) , STD_ULOGIC_VECTOR'("111111111111111111111111101"));
MQQ246:LRU_SET_RESET_VEC_PT(113) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1)
     ) , STD_ULOGIC_VECTOR'("111111111111111110"));
MQQ247:LRU_SET_RESET_VEC_PT(114) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(16) & 
    ENTRY_VALID_WATERMARKED(17) & ENTRY_VALID_WATERMARKED(18) & 
    ENTRY_VALID_WATERMARKED(19) & ENTRY_VALID_WATERMARKED(20) & 
    ENTRY_VALID_WATERMARKED(21) & ENTRY_VALID_WATERMARKED(22) & 
    ENTRY_VALID_WATERMARKED(23) & ENTRY_VALID_WATERMARKED(24) & 
    ENTRY_VALID_WATERMARKED(25) & ENTRY_VALID_WATERMARKED(26) & 
    ENTRY_VALID_WATERMARKED(27) & ENTRY_VALID_WATERMARKED(28) & 
    ENTRY_VALID_WATERMARKED(29) & ENTRY_VALID_WATERMARKED(30) & 
    ENTRY_VALID_WATERMARKED(31) & LRU_Q(1)
     ) , STD_ULOGIC_VECTOR'("111111111111111111"));
MQQ248:LRU_SET_RESET_VEC_PT(115) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) & ENTRY_VALID_WATERMARKED(31)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111111111111110"));
MQQ249:LRU_SET_RESET_VEC_PT(116) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29) & 
    ENTRY_VALID_WATERMARKED(30) ) , STD_ULOGIC_VECTOR'("1111111111111111111111111111110"));
MQQ250:LRU_SET_RESET_VEC_PT(117) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) & ENTRY_VALID_WATERMARKED(29)
     ) , STD_ULOGIC_VECTOR'("111111111111111111111111111110"));
MQQ251:LRU_SET_RESET_VEC_PT(118) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(29) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111110"));
MQQ252:LRU_SET_RESET_VEC_PT(119) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27) & 
    ENTRY_VALID_WATERMARKED(28) ) , STD_ULOGIC_VECTOR'("11111111111111111111111111110"));
MQQ253:LRU_SET_RESET_VEC_PT(120) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) & ENTRY_VALID_WATERMARKED(27)
     ) , STD_ULOGIC_VECTOR'("1111111111111111111111111110"));
MQQ254:LRU_SET_RESET_VEC_PT(121) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(27) ) , STD_ULOGIC_VECTOR'("1111111111111111111111110"));
MQQ255:LRU_SET_RESET_VEC_PT(122) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25) & 
    ENTRY_VALID_WATERMARKED(26) ) , STD_ULOGIC_VECTOR'("111111111111111111111111110"));
MQQ256:LRU_SET_RESET_VEC_PT(123) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) & ENTRY_VALID_WATERMARKED(25)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111111110"));
MQQ257:LRU_SET_RESET_VEC_PT(124) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(25) ) , STD_ULOGIC_VECTOR'("1111111111111111111111110"));
MQQ258:LRU_SET_RESET_VEC_PT(125) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23) & 
    ENTRY_VALID_WATERMARKED(24) ) , STD_ULOGIC_VECTOR'("1111111111111111111111110"));
MQQ259:LRU_SET_RESET_VEC_PT(126) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) & ENTRY_VALID_WATERMARKED(23)
     ) , STD_ULOGIC_VECTOR'("111111111111111111111110"));
MQQ260:LRU_SET_RESET_VEC_PT(127) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(23) ) , STD_ULOGIC_VECTOR'("11111111111111110"));
MQQ261:LRU_SET_RESET_VEC_PT(128) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21) & 
    ENTRY_VALID_WATERMARKED(22) ) , STD_ULOGIC_VECTOR'("11111111111111111111110"));
MQQ262:LRU_SET_RESET_VEC_PT(129) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) & ENTRY_VALID_WATERMARKED(21)
     ) , STD_ULOGIC_VECTOR'("1111111111111111111110"));
MQQ263:LRU_SET_RESET_VEC_PT(130) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(21) ) , STD_ULOGIC_VECTOR'("111111111111111111110"));
MQQ264:LRU_SET_RESET_VEC_PT(131) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19) & 
    ENTRY_VALID_WATERMARKED(20) ) , STD_ULOGIC_VECTOR'("111111111111111111110"));
MQQ265:LRU_SET_RESET_VEC_PT(132) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) & ENTRY_VALID_WATERMARKED(19)
     ) , STD_ULOGIC_VECTOR'("11111111111111111110"));
MQQ266:LRU_SET_RESET_VEC_PT(133) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(19) ) , STD_ULOGIC_VECTOR'("11111111111111110"));
MQQ267:LRU_SET_RESET_VEC_PT(134) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17) & 
    ENTRY_VALID_WATERMARKED(18) ) , STD_ULOGIC_VECTOR'("1111111111111111110"));
MQQ268:LRU_SET_RESET_VEC_PT(135) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) & ENTRY_VALID_WATERMARKED(17)
     ) , STD_ULOGIC_VECTOR'("111111111111111110"));
MQQ269:LRU_SET_RESET_VEC_PT(136) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(17) ) , STD_ULOGIC_VECTOR'("11111111111111110"));
MQQ270:LRU_SET_RESET_VEC_PT(137) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_VALID_WATERMARKED(16) ) , STD_ULOGIC_VECTOR'("11111111111111110"));
MQQ271:LRU_SET_RESET_VEC_PT(138) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15)
     ) , STD_ULOGIC_VECTOR'("1111111111111110"));
MQQ272:LRU_SET_RESET_VEC_PT(139) <=
    Eq(( ENTRY_VALID_WATERMARKED(15) ) , STD_ULOGIC'('0'));
MQQ273:LRU_SET_RESET_VEC_PT(140) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) ) , STD_ULOGIC_VECTOR'("111111111111110"));
MQQ274:LRU_SET_RESET_VEC_PT(141) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13)
     ) , STD_ULOGIC_VECTOR'("11111111111110"));
MQQ275:LRU_SET_RESET_VEC_PT(142) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(13) ) , STD_ULOGIC_VECTOR'("1111111111110"));
MQQ276:LRU_SET_RESET_VEC_PT(143) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) ) , STD_ULOGIC_VECTOR'("1111111111110"));
MQQ277:LRU_SET_RESET_VEC_PT(144) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11)
     ) , STD_ULOGIC_VECTOR'("111111111110"));
MQQ278:LRU_SET_RESET_VEC_PT(145) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(11) ) , STD_ULOGIC_VECTOR'("111111110"));
MQQ279:LRU_SET_RESET_VEC_PT(146) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) ) , STD_ULOGIC_VECTOR'("11111111110"));
MQQ280:LRU_SET_RESET_VEC_PT(147) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9)
     ) , STD_ULOGIC_VECTOR'("1111111110"));
MQQ281:LRU_SET_RESET_VEC_PT(148) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(9) ) , STD_ULOGIC_VECTOR'("111111110"));
MQQ282:LRU_SET_RESET_VEC_PT(149) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) ) , STD_ULOGIC_VECTOR'("111111110"));
MQQ283:LRU_SET_RESET_VEC_PT(150) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7)
     ) , STD_ULOGIC_VECTOR'("11111110"));
MQQ284:LRU_SET_RESET_VEC_PT(151) <=
    Eq(( ENTRY_VALID_WATERMARKED(7) ) , STD_ULOGIC'('0'));
MQQ285:LRU_SET_RESET_VEC_PT(152) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) ) , STD_ULOGIC_VECTOR'("1111110"));
MQQ286:LRU_SET_RESET_VEC_PT(153) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5)
     ) , STD_ULOGIC_VECTOR'("111110"));
MQQ287:LRU_SET_RESET_VEC_PT(154) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(5) ) , STD_ULOGIC_VECTOR'("11110"));
MQQ288:LRU_SET_RESET_VEC_PT(155) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) ) , STD_ULOGIC_VECTOR'("11110"));
MQQ289:LRU_SET_RESET_VEC_PT(156) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3)
     ) , STD_ULOGIC_VECTOR'("1110"));
MQQ290:LRU_SET_RESET_VEC_PT(157) <=
    Eq(( ENTRY_VALID_WATERMARKED(3) ) , STD_ULOGIC'('0'));
MQQ291:LRU_SET_RESET_VEC_PT(158) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) ) , STD_ULOGIC_VECTOR'("110"));
MQQ292:LRU_SET_RESET_VEC_PT(159) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1)
     ) , STD_ULOGIC_VECTOR'("10"));
MQQ293:LRU_SET_RESET_VEC_PT(160) <=
    Eq(( ENTRY_VALID_WATERMARKED(1) ) , STD_ULOGIC'('0'));
MQQ294:LRU_SET_RESET_VEC_PT(161) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) ) , STD_ULOGIC'('0'));
-- Table LRU_SET_RESET_VEC Signal Assignments for Outputs
MQQ295:LRU_RESET_VEC(1) <= 
    (LRU_SET_RESET_VEC_PT(1) OR LRU_SET_RESET_VEC_PT(2)
     OR LRU_SET_RESET_VEC_PT(4) OR LRU_SET_RESET_VEC_PT(6)
     OR LRU_SET_RESET_VEC_PT(7) OR LRU_SET_RESET_VEC_PT(9)
     OR LRU_SET_RESET_VEC_PT(10) OR LRU_SET_RESET_VEC_PT(12)
     OR LRU_SET_RESET_VEC_PT(13) OR LRU_SET_RESET_VEC_PT(15)
     OR LRU_SET_RESET_VEC_PT(16) OR LRU_SET_RESET_VEC_PT(18)
     OR LRU_SET_RESET_VEC_PT(19) OR LRU_SET_RESET_VEC_PT(21)
     OR LRU_SET_RESET_VEC_PT(22) OR LRU_SET_RESET_VEC_PT(25)
     OR LRU_SET_RESET_VEC_PT(114) OR LRU_SET_RESET_VEC_PT(139)
     OR LRU_SET_RESET_VEC_PT(140) OR LRU_SET_RESET_VEC_PT(142)
     OR LRU_SET_RESET_VEC_PT(143) OR LRU_SET_RESET_VEC_PT(145)
     OR LRU_SET_RESET_VEC_PT(146) OR LRU_SET_RESET_VEC_PT(148)
     OR LRU_SET_RESET_VEC_PT(149) OR LRU_SET_RESET_VEC_PT(151)
     OR LRU_SET_RESET_VEC_PT(152) OR LRU_SET_RESET_VEC_PT(154)
     OR LRU_SET_RESET_VEC_PT(155) OR LRU_SET_RESET_VEC_PT(157)
     OR LRU_SET_RESET_VEC_PT(158) OR LRU_SET_RESET_VEC_PT(160)
     OR LRU_SET_RESET_VEC_PT(161));
MQQ296:LRU_RESET_VEC(2) <= 
    (LRU_SET_RESET_VEC_PT(26) OR LRU_SET_RESET_VEC_PT(28)
     OR LRU_SET_RESET_VEC_PT(29) OR LRU_SET_RESET_VEC_PT(31)
     OR LRU_SET_RESET_VEC_PT(32) OR LRU_SET_RESET_VEC_PT(34)
     OR LRU_SET_RESET_VEC_PT(35) OR LRU_SET_RESET_VEC_PT(38)
     OR LRU_SET_RESET_VEC_PT(112) OR LRU_SET_RESET_VEC_PT(151)
     OR LRU_SET_RESET_VEC_PT(152) OR LRU_SET_RESET_VEC_PT(154)
     OR LRU_SET_RESET_VEC_PT(155) OR LRU_SET_RESET_VEC_PT(157)
     OR LRU_SET_RESET_VEC_PT(158) OR LRU_SET_RESET_VEC_PT(160)
     OR LRU_SET_RESET_VEC_PT(161));
MQQ297:LRU_RESET_VEC(3) <= 
    (LRU_SET_RESET_VEC_PT(1) OR LRU_SET_RESET_VEC_PT(2)
     OR LRU_SET_RESET_VEC_PT(4) OR LRU_SET_RESET_VEC_PT(6)
     OR LRU_SET_RESET_VEC_PT(7) OR LRU_SET_RESET_VEC_PT(9)
     OR LRU_SET_RESET_VEC_PT(10) OR LRU_SET_RESET_VEC_PT(12)
     OR LRU_SET_RESET_VEC_PT(110) OR LRU_SET_RESET_VEC_PT(127)
     OR LRU_SET_RESET_VEC_PT(128) OR LRU_SET_RESET_VEC_PT(130)
     OR LRU_SET_RESET_VEC_PT(131) OR LRU_SET_RESET_VEC_PT(133)
     OR LRU_SET_RESET_VEC_PT(134) OR LRU_SET_RESET_VEC_PT(136)
     OR LRU_SET_RESET_VEC_PT(137));
MQQ298:LRU_RESET_VEC(4) <= 
    (LRU_SET_RESET_VEC_PT(39) OR LRU_SET_RESET_VEC_PT(41)
     OR LRU_SET_RESET_VEC_PT(42) OR LRU_SET_RESET_VEC_PT(45)
     OR LRU_SET_RESET_VEC_PT(108) OR LRU_SET_RESET_VEC_PT(157)
     OR LRU_SET_RESET_VEC_PT(158) OR LRU_SET_RESET_VEC_PT(160)
     OR LRU_SET_RESET_VEC_PT(161));
MQQ299:LRU_RESET_VEC(5) <= 
    (LRU_SET_RESET_VEC_PT(26) OR LRU_SET_RESET_VEC_PT(28)
     OR LRU_SET_RESET_VEC_PT(29) OR LRU_SET_RESET_VEC_PT(31)
     OR LRU_SET_RESET_VEC_PT(106) OR LRU_SET_RESET_VEC_PT(145)
     OR LRU_SET_RESET_VEC_PT(146) OR LRU_SET_RESET_VEC_PT(148)
     OR LRU_SET_RESET_VEC_PT(149));
MQQ300:LRU_RESET_VEC(6) <= 
    (LRU_SET_RESET_VEC_PT(13) OR LRU_SET_RESET_VEC_PT(15)
     OR LRU_SET_RESET_VEC_PT(16) OR LRU_SET_RESET_VEC_PT(18)
     OR LRU_SET_RESET_VEC_PT(104) OR LRU_SET_RESET_VEC_PT(133)
     OR LRU_SET_RESET_VEC_PT(134) OR LRU_SET_RESET_VEC_PT(136)
     OR LRU_SET_RESET_VEC_PT(137));
MQQ301:LRU_RESET_VEC(7) <= 
    (LRU_SET_RESET_VEC_PT(1) OR LRU_SET_RESET_VEC_PT(2)
     OR LRU_SET_RESET_VEC_PT(4) OR LRU_SET_RESET_VEC_PT(6)
     OR LRU_SET_RESET_VEC_PT(102) OR LRU_SET_RESET_VEC_PT(121)
     OR LRU_SET_RESET_VEC_PT(122) OR LRU_SET_RESET_VEC_PT(124)
     OR LRU_SET_RESET_VEC_PT(125));
MQQ302:LRU_RESET_VEC(8) <= 
    (LRU_SET_RESET_VEC_PT(46) OR LRU_SET_RESET_VEC_PT(49)
     OR LRU_SET_RESET_VEC_PT(100) OR LRU_SET_RESET_VEC_PT(160)
     OR LRU_SET_RESET_VEC_PT(161));
MQQ303:LRU_RESET_VEC(9) <= 
    (LRU_SET_RESET_VEC_PT(39) OR LRU_SET_RESET_VEC_PT(41)
     OR LRU_SET_RESET_VEC_PT(98) OR LRU_SET_RESET_VEC_PT(154)
     OR LRU_SET_RESET_VEC_PT(155));
MQQ304:LRU_RESET_VEC(10) <= 
    (LRU_SET_RESET_VEC_PT(32) OR LRU_SET_RESET_VEC_PT(34)
     OR LRU_SET_RESET_VEC_PT(96) OR LRU_SET_RESET_VEC_PT(148)
     OR LRU_SET_RESET_VEC_PT(149));
MQQ305:LRU_RESET_VEC(11) <= 
    (LRU_SET_RESET_VEC_PT(26) OR LRU_SET_RESET_VEC_PT(28)
     OR LRU_SET_RESET_VEC_PT(94) OR LRU_SET_RESET_VEC_PT(142)
     OR LRU_SET_RESET_VEC_PT(143));
MQQ306:LRU_RESET_VEC(12) <= 
    (LRU_SET_RESET_VEC_PT(19) OR LRU_SET_RESET_VEC_PT(21)
     OR LRU_SET_RESET_VEC_PT(92) OR LRU_SET_RESET_VEC_PT(136)
     OR LRU_SET_RESET_VEC_PT(137));
MQQ307:LRU_RESET_VEC(13) <= 
    (LRU_SET_RESET_VEC_PT(13) OR LRU_SET_RESET_VEC_PT(15)
     OR LRU_SET_RESET_VEC_PT(90) OR LRU_SET_RESET_VEC_PT(130)
     OR LRU_SET_RESET_VEC_PT(131));
MQQ308:LRU_RESET_VEC(14) <= 
    (LRU_SET_RESET_VEC_PT(7) OR LRU_SET_RESET_VEC_PT(9)
     OR LRU_SET_RESET_VEC_PT(88) OR LRU_SET_RESET_VEC_PT(124)
     OR LRU_SET_RESET_VEC_PT(125));
MQQ309:LRU_RESET_VEC(15) <= 
    (LRU_SET_RESET_VEC_PT(1) OR LRU_SET_RESET_VEC_PT(2)
     OR LRU_SET_RESET_VEC_PT(86) OR LRU_SET_RESET_VEC_PT(118)
     OR LRU_SET_RESET_VEC_PT(119));
MQQ310:LRU_RESET_VEC(16) <= 
    (LRU_SET_RESET_VEC_PT(50) OR LRU_SET_RESET_VEC_PT(84)
     OR LRU_SET_RESET_VEC_PT(161));
MQQ311:LRU_RESET_VEC(17) <= 
    (LRU_SET_RESET_VEC_PT(46) OR LRU_SET_RESET_VEC_PT(82)
     OR LRU_SET_RESET_VEC_PT(158));
MQQ312:LRU_RESET_VEC(18) <= 
    (LRU_SET_RESET_VEC_PT(42) OR LRU_SET_RESET_VEC_PT(80)
     OR LRU_SET_RESET_VEC_PT(155));
MQQ313:LRU_RESET_VEC(19) <= 
    (LRU_SET_RESET_VEC_PT(39) OR LRU_SET_RESET_VEC_PT(78)
     OR LRU_SET_RESET_VEC_PT(152));
MQQ314:LRU_RESET_VEC(20) <= 
    (LRU_SET_RESET_VEC_PT(35) OR LRU_SET_RESET_VEC_PT(76)
     OR LRU_SET_RESET_VEC_PT(149));
MQQ315:LRU_RESET_VEC(21) <= 
    (LRU_SET_RESET_VEC_PT(32) OR LRU_SET_RESET_VEC_PT(74)
     OR LRU_SET_RESET_VEC_PT(146));
MQQ316:LRU_RESET_VEC(22) <= 
    (LRU_SET_RESET_VEC_PT(29) OR LRU_SET_RESET_VEC_PT(72)
     OR LRU_SET_RESET_VEC_PT(143));
MQQ317:LRU_RESET_VEC(23) <= 
    (LRU_SET_RESET_VEC_PT(26) OR LRU_SET_RESET_VEC_PT(70)
     OR LRU_SET_RESET_VEC_PT(140));
MQQ318:LRU_RESET_VEC(24) <= 
    (LRU_SET_RESET_VEC_PT(22) OR LRU_SET_RESET_VEC_PT(68)
     OR LRU_SET_RESET_VEC_PT(137));
MQQ319:LRU_RESET_VEC(25) <= 
    (LRU_SET_RESET_VEC_PT(19) OR LRU_SET_RESET_VEC_PT(66)
     OR LRU_SET_RESET_VEC_PT(134));
MQQ320:LRU_RESET_VEC(26) <= 
    (LRU_SET_RESET_VEC_PT(16) OR LRU_SET_RESET_VEC_PT(64)
     OR LRU_SET_RESET_VEC_PT(131));
MQQ321:LRU_RESET_VEC(27) <= 
    (LRU_SET_RESET_VEC_PT(13) OR LRU_SET_RESET_VEC_PT(62)
     OR LRU_SET_RESET_VEC_PT(128));
MQQ322:LRU_RESET_VEC(28) <= 
    (LRU_SET_RESET_VEC_PT(10) OR LRU_SET_RESET_VEC_PT(60)
     OR LRU_SET_RESET_VEC_PT(125));
MQQ323:LRU_RESET_VEC(29) <= 
    (LRU_SET_RESET_VEC_PT(7) OR LRU_SET_RESET_VEC_PT(58)
     OR LRU_SET_RESET_VEC_PT(122));
MQQ324:LRU_RESET_VEC(30) <= 
    (LRU_SET_RESET_VEC_PT(4) OR LRU_SET_RESET_VEC_PT(56)
     OR LRU_SET_RESET_VEC_PT(119));
MQQ325:LRU_RESET_VEC(31) <= 
    (LRU_SET_RESET_VEC_PT(1) OR LRU_SET_RESET_VEC_PT(54)
     OR LRU_SET_RESET_VEC_PT(116));
MQQ326:LRU_SET_VEC(1) <= 
    (LRU_SET_RESET_VEC_PT(27) OR LRU_SET_RESET_VEC_PT(28)
     OR LRU_SET_RESET_VEC_PT(30) OR LRU_SET_RESET_VEC_PT(31)
     OR LRU_SET_RESET_VEC_PT(33) OR LRU_SET_RESET_VEC_PT(34)
     OR LRU_SET_RESET_VEC_PT(36) OR LRU_SET_RESET_VEC_PT(37)
     OR LRU_SET_RESET_VEC_PT(40) OR LRU_SET_RESET_VEC_PT(41)
     OR LRU_SET_RESET_VEC_PT(43) OR LRU_SET_RESET_VEC_PT(44)
     OR LRU_SET_RESET_VEC_PT(47) OR LRU_SET_RESET_VEC_PT(48)
     OR LRU_SET_RESET_VEC_PT(51) OR LRU_SET_RESET_VEC_PT(52)
     OR LRU_SET_RESET_VEC_PT(113) OR LRU_SET_RESET_VEC_PT(115)
     OR LRU_SET_RESET_VEC_PT(116) OR LRU_SET_RESET_VEC_PT(117)
     OR LRU_SET_RESET_VEC_PT(119) OR LRU_SET_RESET_VEC_PT(120)
     OR LRU_SET_RESET_VEC_PT(122) OR LRU_SET_RESET_VEC_PT(123)
     OR LRU_SET_RESET_VEC_PT(125) OR LRU_SET_RESET_VEC_PT(126)
     OR LRU_SET_RESET_VEC_PT(128) OR LRU_SET_RESET_VEC_PT(129)
     OR LRU_SET_RESET_VEC_PT(131) OR LRU_SET_RESET_VEC_PT(132)
     OR LRU_SET_RESET_VEC_PT(134) OR LRU_SET_RESET_VEC_PT(135)
     OR LRU_SET_RESET_VEC_PT(137));
MQQ327:LRU_SET_VEC(2) <= 
    (LRU_SET_RESET_VEC_PT(40) OR LRU_SET_RESET_VEC_PT(41)
     OR LRU_SET_RESET_VEC_PT(43) OR LRU_SET_RESET_VEC_PT(44)
     OR LRU_SET_RESET_VEC_PT(47) OR LRU_SET_RESET_VEC_PT(48)
     OR LRU_SET_RESET_VEC_PT(51) OR LRU_SET_RESET_VEC_PT(52)
     OR LRU_SET_RESET_VEC_PT(111) OR LRU_SET_RESET_VEC_PT(138)
     OR LRU_SET_RESET_VEC_PT(140) OR LRU_SET_RESET_VEC_PT(141)
     OR LRU_SET_RESET_VEC_PT(143) OR LRU_SET_RESET_VEC_PT(144)
     OR LRU_SET_RESET_VEC_PT(146) OR LRU_SET_RESET_VEC_PT(147)
     OR LRU_SET_RESET_VEC_PT(149));
MQQ328:LRU_SET_VEC(3) <= 
    (LRU_SET_RESET_VEC_PT(14) OR LRU_SET_RESET_VEC_PT(15)
     OR LRU_SET_RESET_VEC_PT(17) OR LRU_SET_RESET_VEC_PT(18)
     OR LRU_SET_RESET_VEC_PT(20) OR LRU_SET_RESET_VEC_PT(21)
     OR LRU_SET_RESET_VEC_PT(23) OR LRU_SET_RESET_VEC_PT(24)
     OR LRU_SET_RESET_VEC_PT(109) OR LRU_SET_RESET_VEC_PT(115)
     OR LRU_SET_RESET_VEC_PT(116) OR LRU_SET_RESET_VEC_PT(117)
     OR LRU_SET_RESET_VEC_PT(119) OR LRU_SET_RESET_VEC_PT(120)
     OR LRU_SET_RESET_VEC_PT(122) OR LRU_SET_RESET_VEC_PT(123)
     OR LRU_SET_RESET_VEC_PT(125));
MQQ329:LRU_SET_VEC(4) <= 
    (LRU_SET_RESET_VEC_PT(47) OR LRU_SET_RESET_VEC_PT(48)
     OR LRU_SET_RESET_VEC_PT(51) OR LRU_SET_RESET_VEC_PT(52)
     OR LRU_SET_RESET_VEC_PT(107) OR LRU_SET_RESET_VEC_PT(150)
     OR LRU_SET_RESET_VEC_PT(152) OR LRU_SET_RESET_VEC_PT(153)
     OR LRU_SET_RESET_VEC_PT(155));
MQQ330:LRU_SET_VEC(5) <= 
    (LRU_SET_RESET_VEC_PT(33) OR LRU_SET_RESET_VEC_PT(34)
     OR LRU_SET_RESET_VEC_PT(36) OR LRU_SET_RESET_VEC_PT(37)
     OR LRU_SET_RESET_VEC_PT(105) OR LRU_SET_RESET_VEC_PT(138)
     OR LRU_SET_RESET_VEC_PT(140) OR LRU_SET_RESET_VEC_PT(141)
     OR LRU_SET_RESET_VEC_PT(143));
MQQ331:LRU_SET_VEC(6) <= 
    (LRU_SET_RESET_VEC_PT(20) OR LRU_SET_RESET_VEC_PT(21)
     OR LRU_SET_RESET_VEC_PT(23) OR LRU_SET_RESET_VEC_PT(24)
     OR LRU_SET_RESET_VEC_PT(103) OR LRU_SET_RESET_VEC_PT(126)
     OR LRU_SET_RESET_VEC_PT(128) OR LRU_SET_RESET_VEC_PT(129)
     OR LRU_SET_RESET_VEC_PT(131));
MQQ332:LRU_SET_VEC(7) <= 
    (LRU_SET_RESET_VEC_PT(8) OR LRU_SET_RESET_VEC_PT(9)
     OR LRU_SET_RESET_VEC_PT(11) OR LRU_SET_RESET_VEC_PT(12)
     OR LRU_SET_RESET_VEC_PT(101) OR LRU_SET_RESET_VEC_PT(115)
     OR LRU_SET_RESET_VEC_PT(116) OR LRU_SET_RESET_VEC_PT(117)
     OR LRU_SET_RESET_VEC_PT(119));
MQQ333:LRU_SET_VEC(8) <= 
    (LRU_SET_RESET_VEC_PT(51) OR LRU_SET_RESET_VEC_PT(52)
     OR LRU_SET_RESET_VEC_PT(99) OR LRU_SET_RESET_VEC_PT(156)
     OR LRU_SET_RESET_VEC_PT(158));
MQQ334:LRU_SET_VEC(9) <= 
    (LRU_SET_RESET_VEC_PT(43) OR LRU_SET_RESET_VEC_PT(44)
     OR LRU_SET_RESET_VEC_PT(97) OR LRU_SET_RESET_VEC_PT(150)
     OR LRU_SET_RESET_VEC_PT(152));
MQQ335:LRU_SET_VEC(10) <= 
    (LRU_SET_RESET_VEC_PT(36) OR LRU_SET_RESET_VEC_PT(37)
     OR LRU_SET_RESET_VEC_PT(95) OR LRU_SET_RESET_VEC_PT(144)
     OR LRU_SET_RESET_VEC_PT(146));
MQQ336:LRU_SET_VEC(11) <= 
    (LRU_SET_RESET_VEC_PT(30) OR LRU_SET_RESET_VEC_PT(31)
     OR LRU_SET_RESET_VEC_PT(93) OR LRU_SET_RESET_VEC_PT(138)
     OR LRU_SET_RESET_VEC_PT(140));
MQQ337:LRU_SET_VEC(12) <= 
    (LRU_SET_RESET_VEC_PT(23) OR LRU_SET_RESET_VEC_PT(24)
     OR LRU_SET_RESET_VEC_PT(91) OR LRU_SET_RESET_VEC_PT(132)
     OR LRU_SET_RESET_VEC_PT(134));
MQQ338:LRU_SET_VEC(13) <= 
    (LRU_SET_RESET_VEC_PT(17) OR LRU_SET_RESET_VEC_PT(18)
     OR LRU_SET_RESET_VEC_PT(89) OR LRU_SET_RESET_VEC_PT(126)
     OR LRU_SET_RESET_VEC_PT(128));
MQQ339:LRU_SET_VEC(14) <= 
    (LRU_SET_RESET_VEC_PT(11) OR LRU_SET_RESET_VEC_PT(12)
     OR LRU_SET_RESET_VEC_PT(87) OR LRU_SET_RESET_VEC_PT(120)
     OR LRU_SET_RESET_VEC_PT(122));
MQQ340:LRU_SET_VEC(15) <= 
    (LRU_SET_RESET_VEC_PT(5) OR LRU_SET_RESET_VEC_PT(6)
     OR LRU_SET_RESET_VEC_PT(85) OR LRU_SET_RESET_VEC_PT(115)
     OR LRU_SET_RESET_VEC_PT(116));
MQQ341:LRU_SET_VEC(16) <= 
    (LRU_SET_RESET_VEC_PT(52) OR LRU_SET_RESET_VEC_PT(83)
     OR LRU_SET_RESET_VEC_PT(159));
MQQ342:LRU_SET_VEC(17) <= 
    (LRU_SET_RESET_VEC_PT(48) OR LRU_SET_RESET_VEC_PT(81)
     OR LRU_SET_RESET_VEC_PT(156));
MQQ343:LRU_SET_VEC(18) <= 
    (LRU_SET_RESET_VEC_PT(44) OR LRU_SET_RESET_VEC_PT(79)
     OR LRU_SET_RESET_VEC_PT(153));
MQQ344:LRU_SET_VEC(19) <= 
    (LRU_SET_RESET_VEC_PT(41) OR LRU_SET_RESET_VEC_PT(77)
     OR LRU_SET_RESET_VEC_PT(150));
MQQ345:LRU_SET_VEC(20) <= 
    (LRU_SET_RESET_VEC_PT(37) OR LRU_SET_RESET_VEC_PT(75)
     OR LRU_SET_RESET_VEC_PT(147));
MQQ346:LRU_SET_VEC(21) <= 
    (LRU_SET_RESET_VEC_PT(34) OR LRU_SET_RESET_VEC_PT(73)
     OR LRU_SET_RESET_VEC_PT(144));
MQQ347:LRU_SET_VEC(22) <= 
    (LRU_SET_RESET_VEC_PT(31) OR LRU_SET_RESET_VEC_PT(71)
     OR LRU_SET_RESET_VEC_PT(141));
MQQ348:LRU_SET_VEC(23) <= 
    (LRU_SET_RESET_VEC_PT(28) OR LRU_SET_RESET_VEC_PT(69)
     OR LRU_SET_RESET_VEC_PT(138));
MQQ349:LRU_SET_VEC(24) <= 
    (LRU_SET_RESET_VEC_PT(24) OR LRU_SET_RESET_VEC_PT(67)
     OR LRU_SET_RESET_VEC_PT(135));
MQQ350:LRU_SET_VEC(25) <= 
    (LRU_SET_RESET_VEC_PT(21) OR LRU_SET_RESET_VEC_PT(65)
     OR LRU_SET_RESET_VEC_PT(132));
MQQ351:LRU_SET_VEC(26) <= 
    (LRU_SET_RESET_VEC_PT(18) OR LRU_SET_RESET_VEC_PT(63)
     OR LRU_SET_RESET_VEC_PT(129));
MQQ352:LRU_SET_VEC(27) <= 
    (LRU_SET_RESET_VEC_PT(15) OR LRU_SET_RESET_VEC_PT(61)
     OR LRU_SET_RESET_VEC_PT(126));
MQQ353:LRU_SET_VEC(28) <= 
    (LRU_SET_RESET_VEC_PT(12) OR LRU_SET_RESET_VEC_PT(59)
     OR LRU_SET_RESET_VEC_PT(123));
MQQ354:LRU_SET_VEC(29) <= 
    (LRU_SET_RESET_VEC_PT(9) OR LRU_SET_RESET_VEC_PT(57)
     OR LRU_SET_RESET_VEC_PT(120));
MQQ355:LRU_SET_VEC(30) <= 
    (LRU_SET_RESET_VEC_PT(6) OR LRU_SET_RESET_VEC_PT(55)
     OR LRU_SET_RESET_VEC_PT(117));
MQQ356:LRU_SET_VEC(31) <= 
    (LRU_SET_RESET_VEC_PT(3) OR LRU_SET_RESET_VEC_PT(53)
     OR LRU_SET_RESET_VEC_PT(115));

-- Encoder for the LRU selected entry
--
-- Final Table Listing
--      *INPUTS*=======================================*OUTPUTS*==========*
--      |                                              |                  |
--      | mmucr1_q                                     |  lru_way_encode  |
--      | |         lru_eff                            |  |               |
--      | |         |                                  |  |               |
--      | |         |                                  |  |               |
--      | |         |        1111111111222222222233    |  |               |
--      | 012345678 1234567890123456789012345678901    |  01234           |
--      *TYPE*=========================================+==================+
--      | PPPPPPPPP PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP    |  PPPPP           |
--      *POLARITY*------------------------------------>|  +++++           |
--      *PHASE*--------------------------------------->|  TTTTT           |
--      *OPTIMIZE*------------------------------------>|   AAAAA            |
--      *TERMS*========================================+==================+
--    1 | --------- 1-1---1-------1---------------1    |  ....1           |
--    2 | --------- 1-1---1-------0--------------1-    |  ....1           |
--    3 | --------- 1-1---0------1--------------1--    |  ....1           |
--    4 | --------- 1-1---0------0-------------1---    |  ....1           |
--    5 | --------- 1-0--1------1-------------1----    |  ....1           |
--    6 | --------- 1-0--1------0------------1-----    |  ....1           |
--    7 | --------- 1-0--0-----1------------1------    |  ....1           |
--    8 | --------- 1-0--0-----0-----------1-------    |  ....1           |
--    9 | --------- 01--1-----1-----------1--------    |  ....1           |
--   10 | --------- 01--1-----0----------1---------    |  ....1           |
--   11 | --------- 01--0----1----------1----------    |  ....1           |
--   12 | --------- 01--0----0---------1-----------    |  ....1           |
--   13 | --------- 00-1----1---------1------------    |  ....1           |
--   14 | --------- 00-1----0--------1-------------    |  ....1           |
--   15 | --------- 00-0---1--------1--------------    |  ....1           |
--   16 | --------- 00-0---0-------1---------------    |  ....1           |
--   17 | --------- 1-1---1-------1----------------    |  ...1.           |
--   18 | --------- 1-1---0------1-----------------    |  ...1.           |
--   19 | --------- 1-0--1------1------------------    |  ...1.           |
--   20 | --------- 1-0--0-----1-------------------    |  ...1.           |
--   21 | --------- 01--1-----1--------------------    |  ...1.           |
--   22 | --------- 01--0----1---------------------    |  ...1.           |
--   23 | --------- 00-1----1----------------------    |  ...1.           |
--   24 | --------- 00-0---1-----------------------    |  ...1.           |
--   25 | --------- 1-1---1------------------------    |  ..1..           |
--   26 | --------- 1-0--1-------------------------    |  ..1..           |
--   27 | --------- 01--1--------------------------    |  ..1..           |
--   28 | --------- 00-1---------------------------    |  ..1..           |
--   29 | --------- 1-1----------------------------    |  .1...           |
--   30 | --------- 01-----------------------------    |  .1...           |
--   31 | --------- 1------------------------------    |  1....           |
--      *=================================================================*
--
-- Table LRU_WAY_ENCODE Signal Assignments for Product Terms
MQQ357:LRU_WAY_ENCODE_PT(1) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(7) & LRU_EFF(15) & 
    LRU_EFF(31) ) , STD_ULOGIC_VECTOR'("11111"));
MQQ358:LRU_WAY_ENCODE_PT(2) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(7) & LRU_EFF(15) & 
    LRU_EFF(30) ) , STD_ULOGIC_VECTOR'("11101"));
MQQ359:LRU_WAY_ENCODE_PT(3) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(7) & LRU_EFF(14) & 
    LRU_EFF(29) ) , STD_ULOGIC_VECTOR'("11011"));
MQQ360:LRU_WAY_ENCODE_PT(4) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(7) & LRU_EFF(14) & 
    LRU_EFF(28) ) , STD_ULOGIC_VECTOR'("11001"));
MQQ361:LRU_WAY_ENCODE_PT(5) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(6) & LRU_EFF(13) & 
    LRU_EFF(27) ) , STD_ULOGIC_VECTOR'("10111"));
MQQ362:LRU_WAY_ENCODE_PT(6) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(6) & LRU_EFF(13) & 
    LRU_EFF(26) ) , STD_ULOGIC_VECTOR'("10101"));
MQQ363:LRU_WAY_ENCODE_PT(7) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(6) & LRU_EFF(12) & 
    LRU_EFF(25) ) , STD_ULOGIC_VECTOR'("10011"));
MQQ364:LRU_WAY_ENCODE_PT(8) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(6) & LRU_EFF(12) & 
    LRU_EFF(24) ) , STD_ULOGIC_VECTOR'("10001"));
MQQ365:LRU_WAY_ENCODE_PT(9) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(5) & LRU_EFF(11) & 
    LRU_EFF(23) ) , STD_ULOGIC_VECTOR'("01111"));
MQQ366:LRU_WAY_ENCODE_PT(10) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(5) & LRU_EFF(11) & 
    LRU_EFF(22) ) , STD_ULOGIC_VECTOR'("01101"));
MQQ367:LRU_WAY_ENCODE_PT(11) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(5) & LRU_EFF(10) & 
    LRU_EFF(21) ) , STD_ULOGIC_VECTOR'("01011"));
MQQ368:LRU_WAY_ENCODE_PT(12) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(5) & LRU_EFF(10) & 
    LRU_EFF(20) ) , STD_ULOGIC_VECTOR'("01001"));
MQQ369:LRU_WAY_ENCODE_PT(13) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(4) & LRU_EFF(9) & 
    LRU_EFF(19) ) , STD_ULOGIC_VECTOR'("00111"));
MQQ370:LRU_WAY_ENCODE_PT(14) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(4) & LRU_EFF(9) & 
    LRU_EFF(18) ) , STD_ULOGIC_VECTOR'("00101"));
MQQ371:LRU_WAY_ENCODE_PT(15) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(4) & LRU_EFF(8) & 
    LRU_EFF(17) ) , STD_ULOGIC_VECTOR'("00011"));
MQQ372:LRU_WAY_ENCODE_PT(16) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(4) & LRU_EFF(8) & 
    LRU_EFF(16) ) , STD_ULOGIC_VECTOR'("00001"));
MQQ373:LRU_WAY_ENCODE_PT(17) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(7) & LRU_EFF(15)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ374:LRU_WAY_ENCODE_PT(18) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(7) & LRU_EFF(14)
     ) , STD_ULOGIC_VECTOR'("1101"));
MQQ375:LRU_WAY_ENCODE_PT(19) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(6) & LRU_EFF(13)
     ) , STD_ULOGIC_VECTOR'("1011"));
MQQ376:LRU_WAY_ENCODE_PT(20) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(6) & LRU_EFF(12)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ377:LRU_WAY_ENCODE_PT(21) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(5) & LRU_EFF(11)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ378:LRU_WAY_ENCODE_PT(22) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(5) & LRU_EFF(10)
     ) , STD_ULOGIC_VECTOR'("0101"));
MQQ379:LRU_WAY_ENCODE_PT(23) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(4) & LRU_EFF(9)
     ) , STD_ULOGIC_VECTOR'("0011"));
MQQ380:LRU_WAY_ENCODE_PT(24) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(4) & LRU_EFF(8)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ381:LRU_WAY_ENCODE_PT(25) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(7) ) , STD_ULOGIC_VECTOR'("111"));
MQQ382:LRU_WAY_ENCODE_PT(26) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(6) ) , STD_ULOGIC_VECTOR'("101"));
MQQ383:LRU_WAY_ENCODE_PT(27) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(5) ) , STD_ULOGIC_VECTOR'("011"));
MQQ384:LRU_WAY_ENCODE_PT(28) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(4) ) , STD_ULOGIC_VECTOR'("001"));
MQQ385:LRU_WAY_ENCODE_PT(29) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ386:LRU_WAY_ENCODE_PT(30) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ387:LRU_WAY_ENCODE_PT(31) <=
    Eq(( LRU_EFF(1) ) , STD_ULOGIC'('1'));
-- Table LRU_WAY_ENCODE Signal Assignments for Outputs
MQQ388:LRU_WAY_ENCODE(0) <= 
    (LRU_WAY_ENCODE_PT(31));
MQQ389:LRU_WAY_ENCODE(1) <= 
    (LRU_WAY_ENCODE_PT(29) OR LRU_WAY_ENCODE_PT(30)
    );
MQQ390:LRU_WAY_ENCODE(2) <= 
    (LRU_WAY_ENCODE_PT(25) OR LRU_WAY_ENCODE_PT(26)
     OR LRU_WAY_ENCODE_PT(27) OR LRU_WAY_ENCODE_PT(28)
    );
MQQ391:LRU_WAY_ENCODE(3) <= 
    (LRU_WAY_ENCODE_PT(17) OR LRU_WAY_ENCODE_PT(18)
     OR LRU_WAY_ENCODE_PT(19) OR LRU_WAY_ENCODE_PT(20)
     OR LRU_WAY_ENCODE_PT(21) OR LRU_WAY_ENCODE_PT(22)
     OR LRU_WAY_ENCODE_PT(23) OR LRU_WAY_ENCODE_PT(24)
    );
MQQ392:LRU_WAY_ENCODE(4) <= 
    (LRU_WAY_ENCODE_PT(1) OR LRU_WAY_ENCODE_PT(2)
     OR LRU_WAY_ENCODE_PT(3) OR LRU_WAY_ENCODE_PT(4)
     OR LRU_WAY_ENCODE_PT(5) OR LRU_WAY_ENCODE_PT(6)
     OR LRU_WAY_ENCODE_PT(7) OR LRU_WAY_ENCODE_PT(8)
     OR LRU_WAY_ENCODE_PT(9) OR LRU_WAY_ENCODE_PT(10)
     OR LRU_WAY_ENCODE_PT(11) OR LRU_WAY_ENCODE_PT(12)
     OR LRU_WAY_ENCODE_PT(13) OR LRU_WAY_ENCODE_PT(14)
     OR LRU_WAY_ENCODE_PT(15) OR LRU_WAY_ENCODE_PT(16)
    );

-- power-on reset sequencer to load initial erat entries
Por_Sequencer: PROCESS (por_seq_q, init_alias, bcfg_q(0 to 106))
BEGIN
por_wr_cam_val  <=  (others => '0');
por_wr_array_val  <=  (others => '0');
por_wr_cam_data  <=  (others => '0');
por_wr_array_data  <=  (others => '0');
por_wr_entry  <=  (others => '0');
CASE por_seq_q IS
        WHEN PorSeq_Idle =>
          por_wr_cam_val <= (others => '0'); por_wr_array_val <= (others => '0');
          por_hold_req <= (others => init_alias);

          if init_alias ='1' then
                    por_seq_d <=  PorSeq_Stg1;
          else
                    por_seq_d <=  PorSeq_Idle;
          end if;  
        WHEN PorSeq_Stg1 =>
          por_wr_cam_val <= (others => '0'); por_wr_array_val <= (others => '0');
          por_seq_d <=  PorSeq_Stg2;  por_hold_req <= (others => '1');

        WHEN PorSeq_Stg2 =>
          por_wr_cam_val <= (others => '1'); por_wr_array_val <= (others => '1');
          por_wr_entry <= Por_Wr_Entry_Num1;  
          por_wr_cam_data <= bcfg_q(0 to 51) & Por_Wr_Cam_Data1(52 to 83); 
-- 16x143 version, 42b RA
-- wr_array_data
--  0:29  - RPN
--  30:31  - R,C
--  32:35  - ResvAttr
--  36:39  - U0-U3
--  40:44  - WIMGE
--  45:46  - UX,SX
--  47:48  - UW,SW
--  49:50  - UR,SR
--  51:60  - CAM parity
--  61:67  - Array parity
          por_wr_array_data <= bcfg_q(52 to 81) & Por_Wr_Array_Data1(30 to 35) & bcfg_q(82 to 85) & 
                                Por_Wr_Array_Data1(40 to 43) & bcfg_q(86) & Por_Wr_Array_Data1(45 to 67); 
          por_hold_req <= (others => '1');
          por_seq_d <=  PorSeq_Stg3;

        WHEN PorSeq_Stg3 =>
          por_wr_cam_val <= (others => '0'); por_wr_array_val <= (others => '0');
          por_hold_req <= (others => '1');
          por_seq_d <=  PorSeq_Stg4; 

        WHEN PorSeq_Stg4 =>
          por_wr_cam_val <= (others => '1'); por_wr_array_val <= (others => '1');
          por_wr_entry <= Por_Wr_Entry_Num2;  
          por_wr_cam_data <= Por_Wr_Cam_Data2; 
          por_wr_array_data <= bcfg_q(52 to 61) & bcfg_q(87 to 106) & Por_Wr_Array_Data2(30 to 35) & bcfg_q(82 to 85) & 
                                Por_Wr_Array_Data2(40 to 43) & bcfg_q(86) & Por_Wr_Array_Data2(45 to 67); 
          por_hold_req <= (others => '1');
          por_seq_d <=  PorSeq_Stg5; 

        WHEN PorSeq_Stg5 =>
          por_wr_cam_val <= (others => '0'); por_wr_array_val <= (others => '0');
          por_hold_req <= (others => '1');
          por_seq_d <=  PorSeq_Stg6;

        WHEN PorSeq_Stg6 =>
          por_wr_cam_val <= (others => '0'); por_wr_array_val <= (others => '0');
          por_hold_req <= (others => '0'); 
          por_seq_d <=  PorSeq_Stg7;

        WHEN PorSeq_Stg7 =>
          por_wr_cam_val <= (others => '0'); por_wr_array_val <= (others => '0');
          por_hold_req <= (others => '0');
          if init_alias ='0' then
                    por_seq_d <=  PorSeq_Idle;
          else
                    por_seq_d <=  PorSeq_Stg7;
          end if;  

        WHEN OTHERS =>
          por_seq_d <=  PorSeq_Idle;  
    END CASE;
END PROCESS Por_Sequencer;
-- page size 4b to 3b swizzles for cam write
cam_pgsize(0 TO 2) <=  (CAM_PgSize_1GB  and (0 to 2 => Eq(ex6_data_in_q(56 to 59),WS0_PgSize_1GB)))
                  or (CAM_PgSize_16MB and (0 to 2 => Eq(ex6_data_in_q(56 to 59),WS0_PgSize_16MB)))
                  or (CAM_PgSize_1MB  and (0 to 2 => Eq(ex6_data_in_q(56 to 59),WS0_PgSize_1MB)))
                  or (CAM_PgSize_64KB and (0 to 2 => Eq(ex6_data_in_q(56 to 59),WS0_PgSize_64KB)))
                  or (CAM_PgSize_4KB and (0 to 2 => not(Eq(ex6_data_in_q(56 to 59),WS0_PgSize_1GB) or 
                                                        Eq(ex6_data_in_q(56 to 59),WS0_PgSize_16MB) or 
                                                        Eq(ex6_data_in_q(56 to 59),WS0_PgSize_1MB) or 
                                                        Eq(ex6_data_in_q(56 to 59),WS0_PgSize_64KB))));
-- page size 3b to 4b swizzles for cam read
ws0_pgsize(0 TO 3) <=  (WS0_PgSize_1GB  and (0 to 3 => Eq(rd_cam_data(53 to 55),CAM_PgSize_1GB)))
                   or (WS0_PgSize_16MB and (0 to 3 => Eq(rd_cam_data(53 to 55),CAM_PgSize_16MB)))
                   or (WS0_PgSize_1MB  and (0 to 3 => Eq(rd_cam_data(53 to 55),CAM_PgSize_1MB)))
                   or (WS0_PgSize_64KB and (0 to 3 => Eq(rd_cam_data(53 to 55),CAM_PgSize_64KB)))
                   or (WS0_PgSize_4KB  and (0 to 3 => Eq(rd_cam_data(53 to 55),CAM_PgSize_4KB)));
-- CAM control signal assignments
rd_val             <=  or_reduce(ex2_valid_q) and ex2_ttype_q(0) and Eq(ex2_tlbsel_q, TlbSel_DErat);
rw_entry           <=  ( por_wr_entry and (0 to 4 => or_reduce(por_seq_q)) )
               or (  eptr_q         and (0 to 4 => (or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4) and mmucr1_q(0))) )  
               or (  lru_way_encode and (0 to 4 => (or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4) and not mmucr1_q(0))) )  
               or (  eptr_q         and (0 to 4 => (or_reduce(ex6_valid_q) and ex6_ttype_q(1) and Eq(ex6_tlbsel_q, TlbSel_DErat) and not tlb_rel_val_q(4) and mmucr1_q(0))) )  
               or (  ex6_ra_entry_q and (0 to 4 => (or_reduce(ex6_valid_q) and ex6_ttype_q(1) and Eq(ex6_tlbsel_q, TlbSel_DErat) and not tlb_rel_val_q(4) and not mmucr1_q(0))) )  
               or (  ex2_ra_entry_q and (0 to 4 => (or_reduce(ex2_valid_q) and ex2_ttype_q(0) and not(or_reduce(ex6_valid_q) and ex6_ttype_q(1) and Eq(ex6_tlbsel_q, TlbSel_DErat)) and not tlb_rel_val_q(4))) );
-- Write Port
wr_cam_val     <=  por_wr_cam_val  when por_seq_q/=PorSeq_Idle 
           else (others => '0') when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
           else  (others => tlb_rel_data_q(eratpos_wren)) when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1')  
           else  (others => '1') when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_DErat)  
            else (others => '0');
-- write port act pin
wr_val_early        <=  or_reduce(por_seq_q) or 
                      or_reduce(tlb_req_inprogress_q) or 
                       (or_reduce(ex5_valid_q) and ex5_ttype_q(1) and Eq(ex5_ws_q,"00") and Eq(ex5_tlbsel_q,TlbSel_DErat)) or  
                       (or_reduce(ex6_valid_q) and ex6_ttype_q(1) and Eq(ex6_ws_q,"00") and Eq(ex6_tlbsel_q,TlbSel_DErat));
-- state <= PR & GS or mmucr0(8) & IS or mmucr0(9) & CM
-- tlb_low_data
--  0:51  - EPN
--  52:55  - SIZE (4b)
--  56:59  - ThdID
--  60:61  - Class
--  62  - ExtClass
--  63  - TID_NZ
--  64:65  - reserved (2b)
--  66:73  - 8b for LPID
--  74:83  - parity 10bits
-- wr_ws0_data (LO)
--  0:51  - EPN
--  52:53  - Class
--  54  - V
--  55  - X
--  56:59  - SIZE
--  60:63  - ThdID
-- wr_cam_data
--  0:51  - EPN
--  52  - X
--  53:55  - SIZE
--  56  - V
--  57:60  - ThdID
--  61:62  - Class
--  63:64  - ExtClass | TID_NZ
--  65  - TGS
--  66  - TS
--  67:74  - TID
--  75:78  - epn_cmpmasks:  34_39, 40_43, 44_47, 48_51
--  79:82  - xbit_cmpmasks: 34_51, 40_51, 44_51, 48_51
--  83  - parity for 75:82
----------- this is what the erat expects on reload bus
--  0:51  - EPN
--  52  - X
--  53:55  - SIZE
--  56  - V
--  57:60  - ThdID
--  61:62  - Class
--  63:64  - ExtClass | TID_NZ
--  65  - write enable
--  0:3 66:69 - reserved RPN
--  4:33 70:99 - RPN
--  34:35 100:101 - R,C
--  36 102 - reserved
--  37:38 103:104 - WLC
--  39 105 - ResvAttr
--  40 106 - VF
--  41:44 107:110 - U0-U3
--  45:49 111:115 - WIMGE
--  50:51 116:117 - UX,SX
--  52:53 118:119 - UW,SW
--  54:55 120:121 - UR,SR
--  56 122 - GS
--  57 123 - TS
--  58:65 124:131 - TID lsbs
gen64_wr_cam_data: if rs_data_width = 64 generate
wr_cam_data         <=  ( por_wr_cam_data and (0 to 83 => (por_seq_q(0) or por_seq_q(1) or por_seq_q(2))) )
                or ( (tlb_rel_data_q(0 to 64) & tlb_rel_data_q(122 to 131) & 
                       tlb_rel_cmpmask(0 to 3) & tlb_rel_xbitmask(0 to 3) & tlb_rel_maskpar)
                             and (0 to 83 => ((tlb_rel_val_q(0) or tlb_rel_val_q(1) or tlb_rel_val_q(2) or tlb_rel_val_q(3)) and tlb_rel_val_q(4))) )  
                 or ( ((ex6_data_in_q(0 to 31) and (0 to 31 => ex6_state_q(3))) & ex6_data_in_q(32 to 51) & ex6_data_in_q(55) & 
                             cam_pgsize(0 to 2) & ex6_data_in_q(54) & ex6_data_in_q(60 to 63) & ex6_data_in_q(52 to 53) & 
                                 ex6_extclass_q & ex6_state_q(1 to 2) & ex6_pid_q(pid_width-8 to pid_width-1) & 
                              ex6_data_cmpmask(0 to 3) & ex6_data_xbitmask(0 to 3) & ex6_data_maskpar) 
                                   and (0 to 83 => ((ex6_valid_q(0) or ex6_valid_q(1) or ex6_valid_q(2) or ex6_valid_q(3)) 
                                         and ex6_ttype_q(1) and not ex6_ws_q(0) and not ex6_ws_q(1) and not tlb_rel_val_q(4))) );
end generate gen64_wr_cam_data;
gen32_wr_cam_data: if rs_data_width = 32 generate
wr_cam_data        <=  ( por_wr_cam_data and (0 to 83 => (por_seq_q(0) or por_seq_q(1) or por_seq_q(2))) )
              or ( (tlb_rel_data_q(0 to 64) & tlb_rel_data_q(122 to 131) & 
                     tlb_rel_cmpmask(0 to 3) & tlb_rel_xbitmask(0 to 3) & tlb_rel_maskpar) 
                            and (0 to 83 => ((tlb_rel_val_q(0) or tlb_rel_val_q(1) or tlb_rel_val_q(2) or tlb_rel_val_q(3)) and tlb_rel_val_q(4))) ) 
               or ( ((0 to 31 => '0') & ex6_data_in_q(32 to 51) & ex6_data_in_q(55) & cam_pgsize(0 to 2) & ex6_data_in_q(54) & 
                          ex6_data_in_q(60 to 63) & ex6_data_in_q(52 to 53) & 
                            ex6_extclass_q & ex6_state_q(1 to 2) & ex6_pid_q(pid_width-8 to pid_width-1) & 
                              ex6_data_cmpmask(0 to 3) & ex6_data_xbitmask(0 to 3) & ex6_data_maskpar) 
                                   and (0 to 83 => ((ex6_valid_q(0) or ex6_valid_q(1) or ex6_valid_q(2) or ex6_valid_q(3)) 
                                         and ex6_ttype_q(1) and not ex6_ws_q(0) and not ex6_ws_q(1) and not tlb_rel_val_q(4))) );
end generate gen32_wr_cam_data;
--        wr_cam_data(75)   (76)    (77)   (78)           (79)   (80)   (81)   (82)
--             cmpmask(0)    (1)     (2)    (3)    xbitmask(0)    (1)    (2)    (3)
--   xbit  pgsize      34_39  40_43  44_47  48_51           34_39  40_43  44_47  48_51    size
--    0     001          1      1      1      1               0      0      0      0       4K
--    0     011          1      1      1      0               0      0      0      0       64K
--    0     101          1      1      0      0               0      0      0      0       1M
--    0     111          1      0      0      0               0      0      0      0       16M
--    0     110          0      0      0      0               0      0      0      0       1G
--    1     001          1      1      1      1               0      0      0      0       4K
--    1     011          1      1      1      0               0      0      0      1       64K
--    1     101          1      1      0      0               0      0      1      0       1M
--    1     111          1      0      0      0               0      1      0      0       16M
--    1     110          0      0      0      0               1      0      0      0       1G
-- Encoder for the cam compare mask bits write data
--
-- Final Table Listing
--      *INPUTS*==================*OUTPUTS*===================================*
--      |                         |                                           |
--      | tlb_rel_data_q          |  tlb_rel_cmpmask                          |
--      | |    ex6_data_in_q      |  |    tlb_rel_xbitmask                    |
--      | |    |                  |  |    |    tlb_rel_maskpar                |
--      | |    |                  |  |    |    |  ex6_data_cmpmask            |
--      | |    |                  |  |    |    |  |    ex6_data_xbitmask      |
--      | |    |                  |  |    |    |  |    |    ex6_data_maskpar  |
--      | |    |                  |  |    |    |  |    |    |                 |
--      | 5555 55555              |  |    |    |  |    |    |                 |
--      | 2345 56789              |  0123 0123 |  0123 0123 |                 |
--      *TYPE*====================+===========================================+
--      | PPPP PPPPP              |  PPPP PPPP P  PPPP PPPP P                 |
--      *POLARITY*--------------->|  ++++ ++++ +  ++++ ++++ +                 |
--      *PHASE*------------------>|  TTTT TTTT T  TTTT TTTT T                 |
--      *OPTIMIZE*--------------->|   AAAA AAAA A  AAAA AAAA A                  |
--      *TERMS*===================+===========================================+
--    1 | ---- 11010              |  .... .... .  .... 1... 1                 |
--    2 | ---- -0--0              |  .... .... .  1111 .... .                 |
--    3 | ---- 10101              |  .... .... .  .... ..1. 1                 |
--    4 | ---- 10011              |  .... .... .  1... ...1 .                 |
--    5 | ---- 10111              |  .... .... .  1... .1.. .                 |
--    6 | ---- 00-11              |  .... .... .  1... .... 1                 |
--    7 | ---- -1--1              |  .... .... .  1111 .... .                 |
--    8 | ---- --00-              |  .... .... .  ..11 .... .                 |
--    9 | ---- ---0-              |  .... .... .  11.. .... .                 |
--   10 | ---- -00--              |  .... .... .  .11. .... .                 |
--   11 | ---- -11--              |  .... .... .  1111 .... .                 |
--   12 | 1--0 -----              |  .... 1... 1  .... .... .                 |
--   13 | 1111 -----              |  1... .1.. .  .... .... .                 |
--   14 | 0-11 -----              |  1... .... 1  .... .... .                 |
--   15 | -00- -----              |  ...1 .... .  .... .... .                 |
--   16 | 110- -----              |  .... ..1. 1  .... .... .                 |
--   17 | --0- -----              |  11.. .... .  .... .... .                 |
--   18 | 101- -----              |  1... ...1 .  .... .... .                 |
--   19 | -0-- -----              |  .11. .... .  .... .... .                 |
--      *=====================================================================*
--
-- Table CAM_MASK_BITS Signal Assignments for Product Terms
MQQ393:CAM_MASK_BITS_PT(1) <=
    Eq(( EX6_DATA_IN_Q(55) & EX6_DATA_IN_Q(56) & 
    EX6_DATA_IN_Q(57) & EX6_DATA_IN_Q(58) & 
    EX6_DATA_IN_Q(59) ) , STD_ULOGIC_VECTOR'("11010"));
MQQ394:CAM_MASK_BITS_PT(2) <=
    Eq(( EX6_DATA_IN_Q(56) & EX6_DATA_IN_Q(59)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ395:CAM_MASK_BITS_PT(3) <=
    Eq(( EX6_DATA_IN_Q(55) & EX6_DATA_IN_Q(56) & 
    EX6_DATA_IN_Q(57) & EX6_DATA_IN_Q(58) & 
    EX6_DATA_IN_Q(59) ) , STD_ULOGIC_VECTOR'("10101"));
MQQ396:CAM_MASK_BITS_PT(4) <=
    Eq(( EX6_DATA_IN_Q(55) & EX6_DATA_IN_Q(56) & 
    EX6_DATA_IN_Q(57) & EX6_DATA_IN_Q(58) & 
    EX6_DATA_IN_Q(59) ) , STD_ULOGIC_VECTOR'("10011"));
MQQ397:CAM_MASK_BITS_PT(5) <=
    Eq(( EX6_DATA_IN_Q(55) & EX6_DATA_IN_Q(56) & 
    EX6_DATA_IN_Q(57) & EX6_DATA_IN_Q(58) & 
    EX6_DATA_IN_Q(59) ) , STD_ULOGIC_VECTOR'("10111"));
MQQ398:CAM_MASK_BITS_PT(6) <=
    Eq(( EX6_DATA_IN_Q(55) & EX6_DATA_IN_Q(56) & 
    EX6_DATA_IN_Q(58) & EX6_DATA_IN_Q(59)
     ) , STD_ULOGIC_VECTOR'("0011"));
MQQ399:CAM_MASK_BITS_PT(7) <=
    Eq(( EX6_DATA_IN_Q(56) & EX6_DATA_IN_Q(59)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ400:CAM_MASK_BITS_PT(8) <=
    Eq(( EX6_DATA_IN_Q(57) & EX6_DATA_IN_Q(58)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ401:CAM_MASK_BITS_PT(9) <=
    Eq(( EX6_DATA_IN_Q(58) ) , STD_ULOGIC'('0'));
MQQ402:CAM_MASK_BITS_PT(10) <=
    Eq(( EX6_DATA_IN_Q(56) & EX6_DATA_IN_Q(57)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ403:CAM_MASK_BITS_PT(11) <=
    Eq(( EX6_DATA_IN_Q(56) & EX6_DATA_IN_Q(57)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ404:CAM_MASK_BITS_PT(12) <=
    Eq(( TLB_REL_DATA_Q(52) & TLB_REL_DATA_Q(55)
     ) , STD_ULOGIC_VECTOR'("10"));
MQQ405:CAM_MASK_BITS_PT(13) <=
    Eq(( TLB_REL_DATA_Q(52) & TLB_REL_DATA_Q(53) & 
    TLB_REL_DATA_Q(54) & TLB_REL_DATA_Q(55)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ406:CAM_MASK_BITS_PT(14) <=
    Eq(( TLB_REL_DATA_Q(52) & TLB_REL_DATA_Q(54) & 
    TLB_REL_DATA_Q(55) ) , STD_ULOGIC_VECTOR'("011"));
MQQ407:CAM_MASK_BITS_PT(15) <=
    Eq(( TLB_REL_DATA_Q(53) & TLB_REL_DATA_Q(54)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ408:CAM_MASK_BITS_PT(16) <=
    Eq(( TLB_REL_DATA_Q(52) & TLB_REL_DATA_Q(53) & 
    TLB_REL_DATA_Q(54) ) , STD_ULOGIC_VECTOR'("110"));
MQQ409:CAM_MASK_BITS_PT(17) <=
    Eq(( TLB_REL_DATA_Q(54) ) , STD_ULOGIC'('0'));
MQQ410:CAM_MASK_BITS_PT(18) <=
    Eq(( TLB_REL_DATA_Q(52) & TLB_REL_DATA_Q(53) & 
    TLB_REL_DATA_Q(54) ) , STD_ULOGIC_VECTOR'("101"));
MQQ411:CAM_MASK_BITS_PT(19) <=
    Eq(( TLB_REL_DATA_Q(53) ) , STD_ULOGIC'('0'));
-- Table CAM_MASK_BITS Signal Assignments for Outputs
MQQ412:TLB_REL_CMPMASK(0) <= 
    (CAM_MASK_BITS_PT(13) OR CAM_MASK_BITS_PT(14)
     OR CAM_MASK_BITS_PT(17) OR CAM_MASK_BITS_PT(18)
    );
MQQ413:TLB_REL_CMPMASK(1) <= 
    (CAM_MASK_BITS_PT(17) OR CAM_MASK_BITS_PT(19)
    );
MQQ414:TLB_REL_CMPMASK(2) <= 
    (CAM_MASK_BITS_PT(19));
MQQ415:TLB_REL_CMPMASK(3) <= 
    (CAM_MASK_BITS_PT(15));
MQQ416:TLB_REL_XBITMASK(0) <= 
    (CAM_MASK_BITS_PT(12));
MQQ417:TLB_REL_XBITMASK(1) <= 
    (CAM_MASK_BITS_PT(13));
MQQ418:TLB_REL_XBITMASK(2) <= 
    (CAM_MASK_BITS_PT(16));
MQQ419:TLB_REL_XBITMASK(3) <= 
    (CAM_MASK_BITS_PT(18));
MQQ420:TLB_REL_MASKPAR <= 
    (CAM_MASK_BITS_PT(12) OR CAM_MASK_BITS_PT(14)
     OR CAM_MASK_BITS_PT(16));
MQQ421:EX6_DATA_CMPMASK(0) <= 
    (CAM_MASK_BITS_PT(2) OR CAM_MASK_BITS_PT(4)
     OR CAM_MASK_BITS_PT(5) OR CAM_MASK_BITS_PT(6)
     OR CAM_MASK_BITS_PT(7) OR CAM_MASK_BITS_PT(9)
     OR CAM_MASK_BITS_PT(11));
MQQ422:EX6_DATA_CMPMASK(1) <= 
    (CAM_MASK_BITS_PT(2) OR CAM_MASK_BITS_PT(7)
     OR CAM_MASK_BITS_PT(9) OR CAM_MASK_BITS_PT(10)
     OR CAM_MASK_BITS_PT(11));
MQQ423:EX6_DATA_CMPMASK(2) <= 
    (CAM_MASK_BITS_PT(2) OR CAM_MASK_BITS_PT(7)
     OR CAM_MASK_BITS_PT(8) OR CAM_MASK_BITS_PT(10)
     OR CAM_MASK_BITS_PT(11));
MQQ424:EX6_DATA_CMPMASK(3) <= 
    (CAM_MASK_BITS_PT(2) OR CAM_MASK_BITS_PT(7)
     OR CAM_MASK_BITS_PT(8) OR CAM_MASK_BITS_PT(11)
    );
MQQ425:EX6_DATA_XBITMASK(0) <= 
    (CAM_MASK_BITS_PT(1));
MQQ426:EX6_DATA_XBITMASK(1) <= 
    (CAM_MASK_BITS_PT(5));
MQQ427:EX6_DATA_XBITMASK(2) <= 
    (CAM_MASK_BITS_PT(3));
MQQ428:EX6_DATA_XBITMASK(3) <= 
    (CAM_MASK_BITS_PT(4));
MQQ429:EX6_DATA_MASKPAR <= 
    (CAM_MASK_BITS_PT(1) OR CAM_MASK_BITS_PT(3)
     OR CAM_MASK_BITS_PT(6));

wr_array_val        <=  por_wr_array_val  when por_seq_q/=PorSeq_Idle 
                else (others => '0') when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
                 else  (others => tlb_rel_data_q(eratpos_wren)) 
                            when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1')  
                  else  (others => '1') when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                              and ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_DErat)  
                   else  (others => '0');
-- tlb_high_data
--  84       -  0      - X-bit
--  85:87    -  1:3    - reserved (3b)
--  88:117   -  4:33   - RPN (30b)
--  118:119  -  34:35  - R,C
--  120:121  -  36:37  - WLC (2b)
--  122      -  38     - ResvAttr
--  123      -  39     - VF
--  124      -  40     - IND
--  125:128  -  41:44  - U0-U3
--  129:133  -  45:49  - WIMGE
--  134:136  -  50:52  - UX,UW,UR
--  137:139  -  53:55  - SX,SW,SR
--  140      -  56  - GS
--  141      -  57  - TS
--  142:143  -  58:59  - reserved (2b)
--  144:149  -  60:65  - 6b TID msbs
--  150:157  -  66:73  - 8b TID lsbs
--  158:167  -  74:83  - parity 10bits
-- 16x143 version, 42b RA
-- wr_array_data
--  0:29  - RPN
--  30:31  - R,C
--  32:35  - ResvAttr
--  36:39  - U0-U3
--  40:44  - WIMGE
--  45:46  - UX,SX
--  47:48  - UW,SW
--  49:50  - UR,SR
--  51:60  - CAM parity
--  61:67  - Array parity
-- wr_ws1_data (HI)
--  0:7  - unused
--  8:9  - WLC
--  10  - ResvAttr
--  11  - unused
--  12:15  - U0-U3
--  16:17  - R,C
--  18:21  - unused
--  22:51  - RPN
--  52:56  - WIMGE
--  57  - VF
--  58:59  - UX,SX
--  60:61  - UW,SW
--  62:63  - UR,SR
wr_array_data_nopar       <=  ( por_wr_array_data(0 to 50) and (0 to 50 => (por_seq_q(0) or por_seq_q(1) or por_seq_q(2))) )
                  or ( (tlb_rel_data_q(70 to 101) & tlb_rel_data_q(103 to 121)) 
                          and (0 to 50 => ((tlb_rel_val_q(0) or tlb_rel_val_q(1) or tlb_rel_val_q(2) or tlb_rel_val_q(3)) and tlb_rel_val_q(4))) )   
                  or ( (rpn_holdreg0_q(22 to 51) & rpn_holdreg0_q(16 to 17) & rpn_holdreg0_q(8 to 10) & rpn_holdreg0_q(57) &
                             rpn_holdreg0_q(12 to 15) & rpn_holdreg0_q(52 to 56) & rpn_holdreg0_q(58 to 63)) 
                                  and (0 to 50 => (ex6_valid_q(0) and ex6_ttype_q(1) and not ex6_ws_q(0) and not ex6_ws_q(1) and not tlb_rel_val_q(4))) )   
                  or ( (rpn_holdreg1_q(22 to 51) & rpn_holdreg1_q(16 to 17) & rpn_holdreg1_q(8 to 10) & rpn_holdreg1_q(57) &
                             rpn_holdreg1_q(12 to 15) & rpn_holdreg1_q(52 to 56) & rpn_holdreg1_q(58 to 63)) 
                                  and (0 to 50 => (ex6_valid_q(1) and ex6_ttype_q(1) and not ex6_ws_q(0) and not ex6_ws_q(1) and not tlb_rel_val_q(4))) )   
                  or ( (rpn_holdreg2_q(22 to 51) & rpn_holdreg2_q(16 to 17) & rpn_holdreg2_q(8 to 10) & rpn_holdreg2_q(57) &
                             rpn_holdreg2_q(12 to 15) & rpn_holdreg2_q(52 to 56) & rpn_holdreg2_q(58 to 63)) 
                                  and (0 to 50 => (ex6_valid_q(2) and ex6_ttype_q(1) and not ex6_ws_q(0) and not ex6_ws_q(1) and not tlb_rel_val_q(4))) )   
                  or ( (rpn_holdreg3_q(22 to 51) & rpn_holdreg3_q(16 to 17) & rpn_holdreg3_q(8 to 10) & rpn_holdreg3_q(57) &
                             rpn_holdreg3_q(12 to 15) & rpn_holdreg3_q(52 to 56) & rpn_holdreg3_q(58 to 63)) 
                                  and (0 to 50 => (ex6_valid_q(3) and ex6_ttype_q(1) and not ex6_ws_q(0) and not ex6_ws_q(1) and not tlb_rel_val_q(4))) );
wr_array_par(51) <=  xor_reduce(wr_cam_data(0 to 7));
wr_array_par(52) <=  xor_reduce(wr_cam_data(8 to 15));
wr_array_par(53) <=  xor_reduce(wr_cam_data(16 to 23));
wr_array_par(54) <=  xor_reduce(wr_cam_data(24 to 31));
wr_array_par(55) <=  xor_reduce(wr_cam_data(32 to 39));
wr_array_par(56) <=  xor_reduce(wr_cam_data(40 to 47));
wr_array_par(57) <=  xor_reduce(wr_cam_data(48 to 55));
wr_array_par(58) <=  xor_reduce(wr_cam_data(57 to 62));
wr_array_par(59) <=  xor_reduce(wr_cam_data(63 to 66));
wr_array_par(60) <=  xor_reduce(wr_cam_data(67 to 74));
wr_array_par(61) <=  xor_reduce(wr_array_data_nopar(0 to 5));
wr_array_par(62) <=  xor_reduce(wr_array_data_nopar(6 to 13));
wr_array_par(63) <=  xor_reduce(wr_array_data_nopar(14 to 21));
wr_array_par(64) <=  xor_reduce(wr_array_data_nopar(22 to 29));
wr_array_par(65) <=  xor_reduce(wr_array_data_nopar(30 to 37));
wr_array_par(66) <=  xor_reduce(wr_array_data_nopar(38 to 44));
wr_array_par(67) <=  xor_reduce(wr_array_data_nopar(45 to 50));
wr_array_data(0 TO 50) <=  wr_array_data_nopar;
wr_array_data(51 TO 67) <=  (wr_array_par(51 to 60) & wr_array_par(61 to 67)) 
                                 when ((tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1') or  
                                           por_seq_q/=PorSeq_Idle)                                    
                      else ((wr_array_par(51) xor mmucr1_q(5)) & wr_array_par(52 to 60) & 
                            (wr_array_par(61) xor mmucr1_q(6)) & wr_array_par(62 to 67))
                                   when (ex6_valid_q(0 to 3)/="0000" and ex6_ttype_q(1)='1' and ex6_ws_q="00")   
                      else (others => '0');
-- Parity Checking
ex4_rd_data_calc_par(50) <=  xor_reduce(ex4_rd_cam_data_q(75 to 82));
ex4_rd_data_calc_par(51) <=  xor_reduce(ex4_rd_cam_data_q(0 to 7));
ex4_rd_data_calc_par(52) <=  xor_reduce(ex4_rd_cam_data_q(8 to 15));
ex4_rd_data_calc_par(53) <=  xor_reduce(ex4_rd_cam_data_q(16 to 23));
ex4_rd_data_calc_par(54) <=  xor_reduce(ex4_rd_cam_data_q(24 to 31));
ex4_rd_data_calc_par(55) <=  xor_reduce(ex4_rd_cam_data_q(32 to 39));
ex4_rd_data_calc_par(56) <=  xor_reduce(ex4_rd_cam_data_q(40 to 47));
ex4_rd_data_calc_par(57) <=  xor_reduce(ex4_rd_cam_data_q(48 to 55));
ex4_rd_data_calc_par(58) <=  xor_reduce(ex4_rd_cam_data_q(57 to 62));
ex4_rd_data_calc_par(59) <=  xor_reduce(ex4_rd_cam_data_q(63 to 66));
ex4_rd_data_calc_par(60) <=  xor_reduce(ex4_rd_cam_data_q(67 to 74));
ex4_rd_data_calc_par(61) <=  xor_reduce(ex4_rd_array_data_q(0 to 5));
ex4_rd_data_calc_par(62) <=  xor_reduce(ex4_rd_array_data_q(6 to 13));
ex4_rd_data_calc_par(63) <=  xor_reduce(ex4_rd_array_data_q(14 to 21));
ex4_rd_data_calc_par(64) <=  xor_reduce(ex4_rd_array_data_q(22 to 29));
ex4_rd_data_calc_par(65) <=  xor_reduce(ex4_rd_array_data_q(30 to 37));
ex4_rd_data_calc_par(66) <=  xor_reduce(ex4_rd_array_data_q(38 to 44));
ex4_rd_data_calc_par(67) <=  xor_reduce(ex4_rd_array_data_q(45 to 50));
parerr_gen0: if check_parity = 0 generate
ex3_cmp_data_parerr_epn     <=  '0';
ex3_cmp_data_parerr_rpn     <=  '0';
end generate parerr_gen0;
parerr_gen1: if check_parity = 1 generate
ex3_cmp_data_parerr_epn      <=  ex3_cmp_data_parerr_epn_mac;
ex3_cmp_data_parerr_rpn      <=  ex3_cmp_data_parerr_rpn_mac;
end generate parerr_gen1;
parerr_gen2: if check_parity = 0 generate
ex4_rd_data_parerr_epn      <=  '0';
ex4_rd_data_parerr_rpn      <=  '0';
end generate parerr_gen2;
parerr_gen3: if check_parity = 1 generate
ex4_rd_data_parerr_epn      <=  or_reduce(ex4_rd_data_calc_par(50 to 60) xor (ex4_rd_cam_data_q(83) & ex4_rd_array_data_q(51 to 60)));
ex4_rd_data_parerr_rpn      <=  or_reduce(ex4_rd_data_calc_par(61 to 67) xor ex4_rd_array_data_q(61 to 67));
end generate parerr_gen3;
-- ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
-- end of parity checking
-- epsc waits for tlb_reloads
epsc_wr_d(0 TO thdid_width-1) <=  xu_derat_epsc_wr and (0 to thdid_width-1 => not bcfg_q(108));
epsc_wr_d(thdid_width TO 2*thdid_width-1) <=  (epsc_wr_q(0 to thdid_width-1) or epsc_wr_q(thdid_width to 2*thdid_width-1)) 
                                                when or_reduce(tlb_rel_val_q(0 to 4))='1'   
                          else epsc_wr_q(0 to thdid_width-1);
epsc_wr_d(2*thdid_width) <=  (or_reduce(epsc_wr_q(0 to thdid_width-1)) or epsc_wr_q(2*thdid_width)) 
                                               when or_reduce(tlb_rel_val_q(0 to 4))='1'   
                          else or_reduce(epsc_wr_q(0 to thdid_width-1));
-- eplc waits for tlb_reloads and epsc accesses
eplc_wr_d(0 TO thdid_width-1) <=  xu_derat_eplc_wr and (0 to thdid_width-1 => not bcfg_q(109));
eplc_wr_d(thdid_width TO 2*thdid_width-1) <=  (eplc_wr_q(0 to thdid_width-1) or eplc_wr_q(thdid_width to 2*thdid_width-1)) 
                                                when (or_reduce(tlb_rel_val_q(0 to 4))='1' or epsc_wr_q(2*thdid_width)='1')   
                          else eplc_wr_q(0 to thdid_width-1);
eplc_wr_d(2*thdid_width) <=  (or_reduce(eplc_wr_q(0 to thdid_width-1)) or eplc_wr_q(2*thdid_width)) 
                                               when (or_reduce(tlb_rel_val_q(0 to 4))='1' or epsc_wr_q(2*thdid_width)='1')   
                          else or_reduce(eplc_wr_q(0 to thdid_width-1));
-- CAM Port
flash_invalidate                <=  Eq(por_seq_q,PorSeq_Stg1) or mchk_flash_inv_enab;
comp_invalidate                 <=  '1' when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
                             else '0' when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1')
                             else '1' when ((eplc_wr_q(8)='1' or epsc_wr_q(8)='1') and tlb_rel_val_q(4)='0' and mmucr1_q(7)='0')  
                             else '1' when snoop_val_q(0 to 1)="11"  
                             else '0';
comp_request                    <=  '1' when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
                             else '1' when ((eplc_wr_q(8)='1' or epsc_wr_q(8)='1') and tlb_rel_val_q(4)='0' and mmucr1_q(7)='0')  
                             else '1' when (snoop_val_q(0 to 1)="11" and (tlb_rel_val_q(0 to 3)="0000" or tlb_rel_val_q(4)='0'))  
                             else '1' when (ex1_valid_q/="0000" and ex1_ttype_q(2)='1' and ex1_tlbsel_q=TlbSel_DErat) 
                             else '1' when (ex1_valid_q/="0000" and ex1_ttype_q(4 to 5)/="00" )  
                             else '0';
gen64_comp_addr: if rs_data_width = 64 generate
comp_addr        <=   xu_derat_ex1_epn_arr;
snoop_addr       <=  snoop_addr_q;
snoop_addr_sel   <=  snoop_val_q(0) and snoop_val_q(1);
end generate gen64_comp_addr;
gen32_comp_addr: if rs_data_width = 32 generate
comp_addr        <=   (0 to 31 => '0') & xu_derat_ex1_epn_arr(32 to 51);
snoop_addr       <=  (0 to 31 => '0') & snoop_addr_q(32 to 51);
snoop_addr_sel   <=  snoop_val_q(0) and snoop_val_q(1);
end generate gen32_comp_addr;
-- ex1_rs_is(0 to 9) from erativax instr.
--   RS(55)    -> ex1_rs_is(0)   -> snoop_attr(0)     -> Local
--   RS(56:57) -> ex1_rs_is(1:2) -> snoop_attr(0:1)   -> IS
--   RS(58:59) -> ex1_rs_is(3:4) -> snoop_attr(2:3)   -> Class
--   n/a       ->  n/a           -> snoop_attr(4:5)   -> State
--   n/a       ->  n/a           -> snoop_attr(6:13)  -> TID(6:13)
--   RS(60:63) -> ex1_rs_is(5:8) -> snoop_attr(14:17) -> Size
--   n/a       ->  n/a           -> snoop_attr(20:25) -> TID(0:5)
-- snoop_attr:
--          0 -> Local
--        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
--        4:5 -> GS/TS
--       6:13 -> TID(6:13)
--      14:17 -> Size
--      18    -> reserved for tlb, extclass_enable(0) for erats
--      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
--      20:25 -> TID(0:5)
-- ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
addr_enable                     <=  "00" when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
                             else "00" when (epsc_wr_q(8)='1' or eplc_wr_q(8)='1') 
                             else "00" when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1 to 3)/="011") 
                             else "10" when (snoop_val_q(0 to 1)="11" and snoop_attr_q(0 to 3)="0011") 
                             else "11" when (snoop_val_q(0 to 1)="11" and snoop_attr_q(0 to 3)="1011") 
                             else "11" when (ex1_valid_q/="0000" and ex1_ttype_q(2)='1' and ex1_tlbsel_q=TlbSel_DErat) 
                             else "11" when (ex1_valid_q/="0000" and ex1_ttype_q(4 to 5)/="00" )  
                             else "00";
comp_pgsize          <=  CAM_PgSize_1GB  when snoop_attr_q(14 to 17)=WS0_PgSize_1GB
                 else  CAM_PgSize_16MB when snoop_attr_q(14 to 17)=WS0_PgSize_16MB
                 else  CAM_PgSize_1MB  when snoop_attr_q(14 to 17)=WS0_PgSize_1MB
                 else  CAM_PgSize_64KB when snoop_attr_q(14 to 17)=WS0_PgSize_64KB
                 else  CAM_PgSize_4KB;
pgsize_enable                   <=  '0' when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
                             else '0' when (epsc_wr_q(8)='1' or eplc_wr_q(8)='1') 
                             else '1' when (snoop_val_q(0 to 1)="11" and snoop_attr_q(0 to 3)="0011") 
                             else '0';
-- ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
--  mmucr1_q: 0-DRRE, 1-REE, 2-CEE, 3-csync, 4-isync, 5:6-DPEI, 7:8-DCTID/DTTID, 9:DCCD
comp_class        <=   "11" when (epsc_wr_q(8)='1' and mmucr1_q(7)='0')  
                else "10" when (epsc_wr_q(8)='0' and eplc_wr_q(8)='1' and mmucr1_q(7)='0')  
                else snoop_attr_q(20 to 21) when (snoop_val_q(0 to 1)="11" and mmucr1_q(7)='1') 
                else snoop_attr_q(2 to 3) when (snoop_val_q(0 to 1)="11") 
                else ex1_pid_q(pid_width-14 to pid_width-13) when mmucr1_q(7)='1' 
                else ((ex1_ttype_q(10) or ex1_ttype_q(11)) & ex1_ttype_q(11));
class_enable(0) <=  '0' when (mmucr1_q(7)='1')  
                else '0' when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
                else '1' when ((eplc_wr_q(8)='1' or epsc_wr_q(8)='1') and tlb_rel_val_q(4)='0' and mmucr1_q(7)='0')  
                else '1' when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1)='1') 
                else '1' when (ex1_valid_q/="0000" and ex1_ttype_q(10 to 11)/="00" and mmucr1_q(9)='0')  
                else '1' when (ex1_valid_q/="0000" and ex1_ttype_q(4 to 5)/="00" and mmucr1_q(9)='0')   
                else '0';
class_enable(1) <=  '0' when (mmucr1_q(7)='1')  
                else '0' when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
                else '1' when ((eplc_wr_q(8)='1' or epsc_wr_q(8)='1') and tlb_rel_val_q(4)='0' and mmucr1_q(7)='0')  
                else '1' when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1)='1') 
                else '1' when (ex1_valid_q/="0000" and ex1_ttype_q(10 to 11)/="00" and mmucr1_q(9)='0')   
                else '0';
class_enable(2) <=  '0' when (mmucr1_q(7)='0')  
                else pid_enable;
-- snoop_attr:
--          0 -> Local
--        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
--        4:5 -> GS/TS
--       6:13 -> TID(6:13)
--      14:17 -> Size
--      18    -> reserved for tlb, extclass_enable(0) for erats
--      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
--      20:25 -> TID(0:5)
--extclass_enable                <=  10  when (ex6_valid_q/= 0000  and ex6_ttype_q(6 to 7)/= 00 )  -- csync or isync enabled
--                             else  10  when (epsc_wr_q(8)='1' or eplc_wr_q(8)='1') -- write to epsc or eplc
--                             else  10  when (snoop_val_q(0 to 1)= 11 ) -- any invalidate snoop
--                             else  00 ; -- std_ulogic;
comp_extclass(0) <=  '0';
comp_extclass(1) <=  snoop_attr_q(19);
extclass_enable(0) <=  ( or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(6 to 7)) )  
                               or ( (eplc_wr_q(8) or epsc_wr_q(8)) and not mmucr1_q(7) )  
                               or ( snoop_val_q(0) and snoop_attr_q(18) );
extclass_enable(1) <=  ( snoop_val_q(0) and not snoop_attr_q(1) and snoop_attr_q(3) );
-- state: 0:pr 1:gs 2:is 3:cm
-- cam state bits are 0:HS, 1:AS
comp_state                      <=  snoop_attr_q(4 to 5) when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1 to 2)="01") 
                             else ex1_state_q(1 to 2);
state_enable                    <=  "00" when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
                             else "00" when (epsc_wr_q(8)='1' or eplc_wr_q(8)='1') 
                             else "00" when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1 to 2)/="01") 
                             else "10" when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1 to 3)="010") 
                             else "11" when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1 to 3)="011") 
                             else "11" when (ex1_valid_q/="0000" and ex1_ttype_q(2)='1' and ex1_tlbsel_q=TlbSel_DErat) 
                             else "11" when (ex1_valid_q/="0000" and ex1_ttype_q(4 to 5)/="00" )  
                             else "00";
--  mmucr1_q: 0-DRRE, 1-REE, 2-CEE, 3-csync, 4-isync, 5:6-DPEI, 7:8-DCTID/DTTID, 9-DCCD
comp_thdid         <=  snoop_attr_q(22 to 25) when (snoop_val_q(0 to 1)="11" and mmucr1_q(8)='1') 
                else ex1_pid_q(pid_width-12 to pid_width-9) when (mmucr1_q(8)='1')  
                else epsc_wr_q(4 to 7) when (epsc_wr_q(8)='1' and mmucr1_q(8)='0')  
                else eplc_wr_q(4 to 7) when (epsc_wr_q(8)='0' and eplc_wr_q(8)='1' and mmucr1_q(8)='0')  
                else (others => '1') when (snoop_val_q(0 to 1)="11" and mmucr1_q(8)='0')
                else ex1_valid_q;
thdid_enable(0) <=  '0' when (mmucr1_q(8)='1')  
                else '0' when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
                else '1' when (epsc_wr_q(8)='1' and tlb_rel_val_q(4)='0' and mmucr1_q(8)='0')  
                else '1' when (epsc_wr_q(8)='0' and eplc_wr_q(8)='1' and tlb_rel_val_q(4)='0' and mmucr1_q(8)='0')  
                else '0' when (snoop_val_q(0 to 1)="11")
                else '1' when (ex1_valid_q/="0000" and ((ex1_ttype_q(2)='1' and ex1_tlbsel_q=TlbSel_DErat) or or_reduce(ex1_ttype_q(4 to 5))='1')) 
                else '0';
thdid_enable(1) <=  '0' when (mmucr1_q(8)='0')  
                else pid_enable;
comp_pid                        <=  snoop_attr_q(6 to 13) when (snoop_val_q(0 to 1)="11") 
                             else ex1_pid_q(pid_width-8 to pid_width-1);
pid_enable                      <=  '0' when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00")  
                             else '0' when (epsc_wr_q(8)='1' or eplc_wr_q(8)='1') 
                             else '0' when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1)='1') 
                             else '0' when (snoop_val_q(0 to 1)="11" and snoop_attr_q(3)='0') 
                             else '1' when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1 to 3)="001") 
                             else '1' when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1 to 3)="011") 
                             else '1' when (ex1_valid_q/="0000" and ex1_ttype_q(2)='1' and ex1_tlbsel_q=TlbSel_DErat) 
                             else '1' when (ex1_valid_q/="0000" and ex1_ttype_q(4 to 5)/="00" )  
                             else '0';
-- wr_cam_data
--  0:51  - EPN
--  52  - X
--  53:55  - SIZE
--  56  - V
--  57:60  - ThdID
--  61:62  - Class
--  63:64  - ExtClass | TID_NZ
--  65  - TGS
--  66  - TS
--  67:74  - TID
--  75:78  - epn_cmpmasks:  34_39, 40_43, 44_47, 48_51
--  79:82  - xbit_cmpmasks: 34_51, 40_51, 44_51, 48_51
--  83  - parity for 75:82
-- 16x143 version, 42b RA
-- wr_array_data
--  0:29  - RPN
--  30:31  - R,C
--  32:35  - ResvAttr
--  36:39  - U0-U3
--  40:44  - WIMGE
--  45:46  - UX,SX
--  47:48  - UW,SW
--  49:50  - UR,SR
--  51:60  - CAM parity
--  61:67  - Array parity
-- wr_ws0_data (LO)
--  0:51  - EPN
--  52:53  - Class
--  54  - V
--  55  - X
--  56:59  - SIZE
--  60:63  - ThdID
-- CAM.ExtClass - MMUCR ExtClass
-- CAM.TS - MMUCR TS
-- CAM.TID - MMUCR TID
-- wr_ws1_data (HI)
--  0:7  - unused
--  8:9  - WLC
--  10  - ResvAttr
--  11  - unused
--  12:15  - U0-U3
--  16:17  - R,C
--  18:21  - unused
--  22:51  - RPN
--  52:56  - WIMGE
--  57  - VF
--  58:59  - UX,SX
--  60:61  - UW,SW
--  62:63  - UR,SR
-- state: 0:pr 1:gs 2:ds 3:cm
-- ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
--                EPN                    Class                   V
--                 X                 SIZE                 ThdID
--                Unused      ResvAttr                  U0-U3                       R,C
--                 RPN                      WIMGE                     Unused   UX,SW,UW,SW,UR,SR
gen64_data_out: if data_out_width = 64 generate
ex4_data_out_d  <=  ( ((0 to 31 => '0') & rd_cam_data(32 to 51) & rd_cam_data(61 to 62) & rd_cam_data(56) & 
                   rd_cam_data(52) & ws0_pgsize(0 to 3) & rd_cam_data(57 to 60)) 
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and not ex3_ws_q(0) and not ex3_ws_q(1) and not ex3_state_q(3))) )  
            or  ( ((0 to 31 => '0') & rd_array_data(10 to 29) & "00" & rd_array_data(0 to 9))
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and not ex3_ws_q(0) and ex3_ws_q(1) and not ex3_state_q(3))) )  
            or  ( ((0 to 31 => '0') & "00000000" & rd_array_data(32 to 34) & '0' & rd_array_data(36 to 39) &  rd_array_data(30 to 31) &
                   "00" & rd_array_data(40 to 44) & rd_array_data(35) & rd_array_data(45 to 50)) 
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and not ex3_ws_q(1) and not ex3_state_q(3))) )  
            or  ( (rd_cam_data(0 to 51) & rd_cam_data(61 to 62) & rd_cam_data(56) & 
                   rd_cam_data(52) & ws0_pgsize(0 to 3) & rd_cam_data(57 to 60)) 
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and not ex3_ws_q(0) and not ex3_ws_q(1) and ex3_state_q(3))) )  
            or  ( ("00000000" & rd_array_data(32 to 34) & '0' & rd_array_data(36 to 39) &  rd_array_data(30 to 31) &
                   "0000" & rd_array_data(0 to 29) & rd_array_data(40 to 44) & rd_array_data(35) & rd_array_data(45 to 50)) 
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and not ex3_ws_q(0) and ex3_ws_q(1) and ex3_state_q(3))) )  
            or  ( ((0 to 47-watermark_width => '0') & (watermark_q and (48-watermark_width to 47 => bcfg_q(107))) & (48 to 63-eptr_width => '0') & eptr_q)
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and ex3_ws_q(1) and mmucr1_q(0))) )  
            or  ( ((0 to 47-watermark_width => '0') & (watermark_q and (48-watermark_width to 47 => bcfg_q(107))) & (48 to 63-num_entry_log2 => '0') & lru_way_encode)
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and ex3_ws_q(1) and not mmucr1_q(0))) )  
            or  ( ((0 to 49 => '0') & ex3_eratsx_data(0 to 1) & (52 to 58 => '0') & ex3_eratsx_data(2 to 2+num_entry_log2-1))
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(2))) );
end generate gen64_data_out;
gen32_data_out: if data_out_width = 32 generate
ex4_data_out_d  <=  ( (rd_cam_data(32 to 51) & rd_cam_data(61 to 62) & rd_cam_data(56) & 
                   rd_cam_data(52) & ws0_pgsize(0 to 3) & rd_cam_data(57 to 60)) 
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and not ex3_ws_q(0) and not ex3_ws_q(1))) )  
            or  ( (rd_array_data(10 to 29) & "00" & rd_array_data(0 to 9))
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and not ex3_ws_q(0) and ex3_ws_q(1))) )  
            or  ( ("00000000" & rd_array_data(32 to 34) & '0' & rd_array_data(36 to 39) &  rd_array_data(30 to 31) &
                   "00" & rd_array_data(40 to 44) & rd_array_data(35) & rd_array_data(45 to 50)) 
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and not ex3_ws_q(1))) )  
            or   ( ((32 to 47-watermark_width => '0') & (watermark_q and (48-watermark_width to 47 => bcfg_q(107))) & (48 to 58 => '0') & eptr_q)
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and ex3_ws_q(1) and mmucr1_q(0))) )  
            or   ( ((32 to 47-watermark_width => '0') & (watermark_q and (48-watermark_width to 47 => bcfg_q(107))) & (48 to 58 => '0') & lru_way_encode)
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and ex3_ws_q(1) and not mmucr1_q(0))) )  
            or   ( ((32 to 49 => '0') & ex3_eratsx_data(0 to 1) & (52 to 58 => '0') & ex3_eratsx_data(2 to 2+num_entry_log2-1))
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(2))) );
end generate gen32_data_out;
-- ERAT outputs
derat_xu_ex2_miss           <=  ex2_valid_q and (0 to thdid_width-1 => (not cam_hit and or_reduce(ex2_ttype_q(4 to 5)) and not ex2_ttype_q(9) and not ccr2_frat_paranoia_q(9)));
-- 16x143 version
-- pass thru epn offset bits depending on page size from cam entry
-- adding frat paranoia bypass bit 9 for ra=ea... bit 10 also bypass ra=ea for other xu reasons
gen_mcompar_breaks_timing_1: if ex2_epn_width = rpn_width generate
derat_xu_ex2_rpn(22 TO 33) <=  ( ex2_epn_q(22 to 33) and (22 to 33 => (ccr2_frat_paranoia_q(9) or ccr2_frat_paranoia_q(11))) ) or
                                       ( array_cmp_data(0 to 11) and (0 to 11 => (not ccr2_frat_paranoia_q(9) and not ccr2_frat_paranoia_q(11))) );
derat_xu_ex2_rpn(34 TO 39) <=  ( ex2_epn_q(34 to 39) and (34 to 39 => (not(cam_cmp_data(75)) or ccr2_frat_paranoia_q(9) or ccr2_frat_paranoia_q(11))) ) or 
                                       ( array_cmp_data(12 to 17) and (12 to 17 => (cam_cmp_data(75) and not ccr2_frat_paranoia_q(9) and not ccr2_frat_paranoia_q(11))) );
derat_xu_ex2_rpn(40 TO 43) <=  ( ex2_epn_q(40 to 43) and (40 to 43 => (not(cam_cmp_data(76)) or ccr2_frat_paranoia_q(9) or ccr2_frat_paranoia_q(11))) ) or
                                       ( array_cmp_data(18 to 21) and (18 to 21 => (cam_cmp_data(76) and not ccr2_frat_paranoia_q(9) and not ccr2_frat_paranoia_q(11))) );
derat_xu_ex2_rpn(44 TO 47) <=  ( ex2_epn_q(44 to 47) and (44 to 47 => (not(cam_cmp_data(77)) or ccr2_frat_paranoia_q(9) or ccr2_frat_paranoia_q(11))) ) or
                                       ( array_cmp_data(22 to 25) and (22 to 25 => (cam_cmp_data(77) and not ccr2_frat_paranoia_q(9) and not ccr2_frat_paranoia_q(11))) );
derat_xu_ex2_rpn(48 TO 51) <=  ( ex2_epn_q(48 to 51) and (48 to 51 => (not(cam_cmp_data(78)) or ccr2_frat_paranoia_q(9) or ccr2_frat_paranoia_q(11))) ) or
                                       ( array_cmp_data(26 to 29) and (26 to 29 => (cam_cmp_data(78) and not ccr2_frat_paranoia_q(9) and not ccr2_frat_paranoia_q(11))) );
derat_xu_ex2_u              <=  ( ccr2_frat_paranoia_q(5 to 8) and (5 to 8 => ccr2_frat_paranoia_q(9)) ) or
                                    ( array_cmp_data(36 to 39) and (36 to 39 => not ccr2_frat_paranoia_q(9)) );
derat_xu_ex2_wimge          <=  ( ccr2_frat_paranoia_q(0 to 4) and (0 to 4 => ccr2_frat_paranoia_q(9)) ) or
                                    ( array_cmp_data(40 to 44) and (40 to 44 => not ccr2_frat_paranoia_q(9)) );
derat_xu_ex2_wlc            <=  array_cmp_data(32 to 33) and (32 to 33 => not ccr2_frat_paranoia_q(9));
derat_xu_ex2_vf             <=  array_cmp_data(35) and not ccr2_frat_paranoia_q(9);
end generate gen_mcompar_breaks_timing_1;
gen_no_frat_1: if ex2_epn_width = 18 generate
derat_xu_ex2_rpn(22 TO 33) <=  array_cmp_data(0 to 11);
derat_xu_ex2_rpn(34 TO 39) <=  ( ex2_epn_q(34 to 39) and (34 to 39 => (cam_cmp_data(53) and cam_cmp_data(54) and not cam_cmp_data(55))) ) or 
                                       ( array_cmp_data(12 to 17) and (12 to 17 => (not(cam_cmp_data(53)) or not(cam_cmp_data(54)) or cam_cmp_data(55))) );
derat_xu_ex2_rpn(40 TO 43) <=  ( ex2_epn_q(40 to 43) and (40 to 43 => (cam_cmp_data(53) and cam_cmp_data(54))) ) or  
                                       ( array_cmp_data(18 to 21) and (18 to 21 => (not cam_cmp_data(53) or not cam_cmp_data(54))) );
derat_xu_ex2_rpn(44 TO 47) <=  ( ex2_epn_q(44 to 47) and (44 to 47 => cam_cmp_data(53)) ) or 
                                       ( array_cmp_data(22 to 25) and (22 to 25 => not cam_cmp_data(53)) );
derat_xu_ex2_rpn(48 TO 51) <=  ( ex2_epn_q(48 to 51) and (48 to 51 => (cam_cmp_data(53) or cam_cmp_data(54))) ) or 
                                       ( array_cmp_data(26 to 29) and (26 to 29 => (not cam_cmp_data(53) and not cam_cmp_data(54))) );
derat_xu_ex2_u              <=  array_cmp_data(36 to 39);
derat_xu_ex2_wimge          <=  array_cmp_data(40 to 44);
derat_xu_ex2_wlc            <=  array_cmp_data(32 to 33);
derat_xu_ex2_vf             <=  array_cmp_data(35);
end generate gen_no_frat_1;
-- new cam _np2  bypass attributes (bit numbering per array)
--  30:31  - R,C
--  32:33  - WLC
--  34  - ResvAttr
--  35  - VF
--  36:39  - U0-U3
--  40:44  - WIMGE
--  45:46  - UX,SX
--  47:48  - UW,SW
--  49:50  - UR,SR
bypass_mux_enab_np1  <=  (ccr2_frat_paranoia_q(9) or ccr2_frat_paranoia_q(11) or an_ac_grffence_en_dc);
bypass_attr_np1(0 TO 5) <=  (others => '0');
bypass_attr_np1(6 TO 9) <=  ccr2_frat_paranoia_q(5 to 8);
bypass_attr_np1(10 TO 14) <=  ccr2_frat_paranoia_q(0 to 4);
bypass_attr_np1(15 TO 20) <=  "111111";
derat_xu_ex2_attr           <=  ex3_attr_d;
derat_xu_ex3_miss           <=  ex3_miss_q;
derat_xu_ex3_dsi            <=  ex3_dsi_q(12 to 15) and (0 to 3 => ex3_dsi_enab);
derat_xu_ex3_noop_touch     <=  ex3_noop_touch_q(12 to 15) and (0 to 3 => ex3_noop_touch_enab);
derat_xu_ex3_multihit_err   <=  ex3_multihit_q and (0 to 3 => ex3_multihit_enab);
derat_xu_ex3_par_err        <=  ex3_parerr_q(0 to thdid_width-1) and (0 to thdid_width-1 => ex3_parerr_enab);
derat_xu_ex3_n_flush_req    <=  ex3_n_flush_req_q;
derat_xu_ex4_data           <=  ex4_data_out_q;
derat_xu_ex4_par_err        <=  ex4_parerr_q(0 to thdid_width-1) and (0 to thdid_width-1 => ex4_parerr_enab);
derat_fir_par_err           <=  ex4_fir_parerr_q(0 to thdid_width-1) and (0 to thdid_width-1 => ex4_fir_parerr_enab);
derat_fir_multihit          <=  ex4_fir_multihit_q;
derat_iu_barrier_done       <=  barrier_done_q;
xu_mm_derat_req             <=  ex3_tlbreq_q;
xu_mm_derat_thdid           <=  ex3_valid_q;
xu_mm_derat_state           <=  ex3_state_q;
xu_mm_derat_ttype           <=  "11" when ex3_ttype_q(11)='1'  
                               else "10" when ex3_ttype_q(10)='1' 
                               else "01" when ex3_ttype_q(5)='1'   
                               else "00";
xu_mm_derat_tid             <=  ex3_pid_q;
xu_mm_derat_lpid            <=  ex3_lpid_q;
xu_mm_derat_mmucr0           <=  ex6_extclass_q & ex6_state_q(1 to 2) & ex6_pid_q;
xu_mm_derat_mmucr0_we        <=  ex6_valid_q when (ex6_ttype_q(0)='1' and ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_DErat) 
                             else (others => '0');
xu_mm_derat_mmucr1           <=  ex6_deen_q(1 to num_entry_log2);
xu_mm_derat_mmucr1_we        <=  ex6_deen_q(0);
-- NOTE: example parity generation/checks in iuq_ic_dir.vhdl or xuq_lsu_dc_arr.vhdl.
-----------------------------------------------------------------------
-- CAM Instantiation
-----------------------------------------------------------------------
derat_cam: entity tri.tri_cam_32x143_1r1w1c
  generic map (expand_type => expand_type)
  port map (
   gnd                => gnd,
   vdd                => vdd,
   vcs                => vcs,
   nclk                           =>  nclk,


   tc_ccflush_dc                  =>  pc_xu_ccflush_dc,
   tc_scan_dis_dc_b               =>  tc_scan_dis_dc_b,
   tc_scan_diag_dc                =>  tc_scan_diag_dc,
   tc_lbist_en_dc                 =>  tc_lbist_en_dc,
   an_ac_atpg_en_dc               =>  an_ac_atpg_en_dc,

   lcb_d_mode_dc                  =>  cam_d_mode_dc,
   lcb_clkoff_dc_b                =>  cam_clkoff_dc_b,
   lcb_act_dis_dc                 =>  cam_act_dis_dc,
   lcb_mpw1_dc_b                  =>  cam_mpw1_dc_b(0 to 3),  
   lcb_mpw2_dc_b                  =>  cam_mpw2_dc_b,
   lcb_delay_lclkr_dc             =>  cam_delay_lclkr_dc(0 to 3),  

   pc_sg_2                        =>  pc_sg_2,
   pc_func_slp_sl_thold_2         =>  pc_func_slp_sl_thold_2, 
   pc_func_slp_nsl_thold_2        =>  pc_func_slp_nsl_thold_2,
   pc_regf_slp_sl_thold_2         =>  pc_regf_slp_sl_thold_2,
   pc_time_sl_thold_2             =>  pc_time_sl_thold_2,
   pc_fce_2                       =>  pc_fce_2,

   func_scan_in  	          => func_si_cam_int,
   func_scan_out 	          => func_so_cam_int,
   regfile_scan_in    	          => regf_scan_in, 
   regfile_scan_out    	          => regf_scan_out, 
   time_scan_in  	          => time_scan_in,
   time_scan_out 	          => time_scan_out,


   rd_val                         =>  rd_val,            
   rd_val_late                    =>  tiup,              
   rw_entry                       =>  rw_entry,          

   wr_array_data                  =>  wr_array_data,     
   wr_cam_data                    =>  wr_cam_data,       
   wr_array_val                   =>  wr_array_val,      
   wr_cam_val                     =>  wr_cam_val,        
   wr_val_early                   =>  wr_val_early,      

   comp_request                   =>  comp_request,
   comp_addr                      =>  comp_addr,         
   addr_enable                    =>  addr_enable,       
   comp_pgsize                    =>  comp_pgsize,       
   pgsize_enable                  =>  pgsize_enable,
   comp_class                     =>  comp_class,        
   class_enable                   =>  class_enable,      
   comp_extclass                  =>  comp_extclass,     
   extclass_enable                =>  extclass_enable,   
   comp_state                     =>  comp_state,        
   state_enable                   =>  state_enable,      
   comp_thdid                     =>  comp_thdid,        
   thdid_enable                   =>  thdid_enable,      
   comp_pid                       =>  comp_pid,          
   pid_enable                     =>  pid_enable,
   comp_invalidate                =>  comp_invalidate,
   flash_invalidate               =>  flash_invalidate,

   array_cmp_data                 => array_cmp_data,   
   rd_array_data                  => rd_array_data,   

   cam_cmp_data                   => cam_cmp_data,   
   cam_hit                        => cam_hit,   
   cam_hit_entry                  => cam_hit_entry,   
   entry_match                    => entry_match,   
   entry_valid                    => entry_valid,   
   rd_cam_data                    => rd_cam_data,   


----- new ports for IO plus -----------------------
bypass_mux_enab_np1            =>  bypass_mux_enab_np1,   
   bypass_attr_np1                =>  bypass_attr_np1,       
   attr_np2	                  =>  attr_np2,              
   rpn_np2	                  =>  rpn_np2         

  );
derat_cmp_parerr_mac: entity tri.tri_cam_parerr_mac
  port map (
   gnd               => gnd,
   vdd               => vdd,

   nclk             => nclk,
   lcb_act_dis_dc                 => cam_act_dis_dc,  
   lcb_delay_lclkr_dc             => cam_delay_lclkr_dc(4),  
   lcb_clkoff_dc_b_0              => cam_clkoff_dc_b,  
   lcb_mpw1_dc_b                  => cam_mpw1_dc_b(4),  
   lcb_mpw2_dc_b                  => cam_mpw2_dc_b,  

   act                            => ex2_cmp_data_act,  
   lcb_sg_0                       => pc_sg_0,  
   lcb_func_sl_thold_0            => pc_func_slp_sl_thold_0,  

   func_scan_in                   => siv_1(erat_parerr_mac_offset),  
   func_scan_out                  => sov_1(erat_parerr_mac_offset),  

   np1_cam_cmp_data         => cam_cmp_data,  
   np1_array_cmp_data       => array_cmp_data,  

   np2_cam_cmp_data         => ex3_cam_cmp_data_q,  
   np2_array_cmp_data       => ex3_array_cmp_data_q,  
   np2_cmp_data_parerr_epn  => ex3_cmp_data_parerr_epn_mac,  
   np2_cmp_data_parerr_rpn  => ex3_cmp_data_parerr_rpn_mac  

  );
-- bypass attributes (bit numbering per array)
--  30:31  - R,C
--  32:33  - WLC
--  34  - ResvAttr
--  35  - VF
--  36:39  - U0-U3
--  40:44  - WIMGE
--  45:46  - UX,SX
--  47:48  - UW,SW
--  49:50  - UR,SR
derat_xu_ex3_rpn            <=  rpn_np2;
derat_xu_ex3_wimge          <=  attr_np2(10 to 14);
derat_xu_ex3_u              <=  attr_np2(6 to 9);
derat_xu_ex3_wlc            <=  attr_np2(2 to 3);
derat_xu_ex3_attr           <=  attr_np2(15 to 20);
derat_xu_ex3_vf             <=  attr_np2(5);
-- debug bus outputs
ex2_debug_d(0) <=  comp_request;
ex2_debug_d(1) <=  comp_invalidate;
ex2_debug_d(2) <=  ( or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(6 to 7)) );
ex2_debug_d(3) <=  ( (eplc_wr_q(8) or epsc_wr_q(8)) and not(tlb_rel_val_q(4)) and not(mmucr1_q(7)) );
ex2_debug_d(4) <=  ( snoop_val_q(0) and snoop_val_q(1) and not(or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4)) );
ex2_debug_d(5) <=  ( or_reduce(ex1_valid_q) and ex1_ttype_q(2) and Eq(ex1_tlbsel_q,TlbSel_DErat));
ex2_debug_d(6) <=  ( or_reduce(ex1_valid_q) and or_reduce(ex1_ttype_q(4 to 5)) );
ex2_debug_d(7) <=  ( or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4) );
ex2_debug_d(8) <=  ( or_reduce(tlb_rel_val_q(0 to 3)) );
ex2_debug_d(9) <=  ( snoop_val_q(0) and snoop_val_q(1) );
ex2_debug_d(10) <=  ( eplc_wr_q(8) or epsc_wr_q(8) );
ex3_debug_d(0 TO 10) <=  ex2_debug_q(0 to 10);
ex3_debug_d(11 TO 15) <=  ex3_first_hit_entry;
ex3_debug_d(16) <=  ex3_multihit_enab;
lru_debug_d(0) <=  tlb_rel_data_q(eratpos_wren)  when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1') else '0';
lru_debug_d(1) <=  '1' when snoop_val_q(0 to 1)="11" else '0';
lru_debug_d(2) <=  '1' when (ex6_valid_q/="0000" and ex6_ttype_q(6 to 7)/="00") else '0';
lru_debug_d(3) <=  '1' when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_DErat and lru_way_encode=ex6_ra_entry_q) else '0';
lru_debug_d(4) <=  '1' when (ex6_valid_q/="0000" and ex6_ttype_q(4 to 5)/="00" and ex6_hit_q='1' ) else '0';
lru_debug_d(5 TO 35) <=  lru_eff;
lru_debug_d(36 TO 40) <=  lru_way_encode;
derat_xu_debug_group0(0 TO 83) <=  ex3_cam_cmp_data_q(0 to 83);
derat_xu_debug_group0(84) <=  ex3_cam_hit_q;
derat_xu_debug_group0(85) <=  ex3_debug_q(0);
derat_xu_debug_group0(86) <=  ex3_debug_q(1);
derat_xu_debug_group0(87) <=  ex3_debug_q(9);
derat_xu_debug_group1(0 TO 67) <=  ex3_array_cmp_data_q(0 to 67);
derat_xu_debug_group1(68) <=  ex3_cam_hit_q;
derat_xu_debug_group1(69) <=  ex3_debug_q(16);
derat_xu_debug_group1(70 TO 74) <=  ex3_debug_q(11 to 15);
derat_xu_debug_group1(75) <=  ex3_debug_q(0);
derat_xu_debug_group1(76) <=  ex3_debug_q(1);
derat_xu_debug_group1(77) <=  ex3_debug_q(2);
derat_xu_debug_group1(78) <=  ex3_debug_q(3);
derat_xu_debug_group1(79) <=  ex3_debug_q(4);
derat_xu_debug_group1(80) <=  ex3_debug_q(5);
derat_xu_debug_group1(81) <=  ex3_debug_q(6);
derat_xu_debug_group1(82) <=  ex3_debug_q(7);
derat_xu_debug_group1(83) <=  ex3_debug_q(8);
derat_xu_debug_group1(84) <=  ex3_debug_q(9);
derat_xu_debug_group1(85) <=  ex3_debug_q(10);
derat_xu_debug_group1(86) <=  ex3_ttype_q(8);
derat_xu_debug_group1(87) <=  ex3_ttype_q(9);
derat_xu_debug_group2(0 TO 31) <=  entry_valid_q(0 to 31);
derat_xu_debug_group2(32 TO 63) <=  entry_match_q(0 to 31);
derat_xu_debug_group2(64 TO 73) <=  lru_update_event_q(0 to 9);
derat_xu_debug_group2(74 TO 78) <=  lru_debug_q(36 to 40);
derat_xu_debug_group2(79 TO 83) <=  watermark_q(0 to 4);
derat_xu_debug_group2(84) <=  ex3_cam_hit_q;
derat_xu_debug_group2(85) <=  ex3_debug_q(0);
derat_xu_debug_group2(86) <=  ex3_debug_q(1);
derat_xu_debug_group2(87) <=  ex3_debug_q(9);
derat_xu_debug_group3(0) <=  ex3_cam_hit_q;
derat_xu_debug_group3(1) <=  ex3_debug_q(0);
derat_xu_debug_group3(2) <=  ex3_debug_q(1);
derat_xu_debug_group3(3) <=  ex3_debug_q(9);
derat_xu_debug_group3(4 TO 8) <=  ex3_debug_q(11 to 15);
derat_xu_debug_group3(9) <=  lru_update_event_q(9);
derat_xu_debug_group3(10 TO 14) <=  lru_debug_q(0 to 4);
derat_xu_debug_group3(15 TO 19) <=  watermark_q(0 to 4);
derat_xu_debug_group3(20) <=  '0';
derat_xu_debug_group3(21 TO 51) <=  lru_q(1 to 31);
derat_xu_debug_group3(52 TO 82) <=  lru_debug_q(5 to 35);
derat_xu_debug_group3(83 TO 87) <=  lru_debug_q(36 to 40);
-- unused spare signal assignments
unused_dc(0) <=  or_reduce(LCB_DELAY_LCLKR_DC(1 TO 4));
unused_dc(1) <=  or_reduce(LCB_MPW1_DC_B(1 TO 4));
unused_dc(2) <=   '0';
unused_dc(3) <=   '0';
unused_dc(4) <=  PC_FUNC_SL_FORCE;
unused_dc(5) <=  PC_FUNC_SL_THOLD_0_B;
unused_dc(6) <=  or_reduce(EX1_TTYPE_Q(6 TO 7));
unused_dc(7) <=  or_reduce(EX1_RS_IS_Q);
unused_dc(8) <=  or_reduce(EX1_RA_ENTRY_Q);
unused_dc(9) <=  or_reduce(cam_hit_entry);
unused_dc(10) <=  or_reduce(ex2_first_hit_entry) or ex2_multihit_b;
unused_dc(11) <=  or_reduce(EX3_DSI_Q(8 TO 11));
unused_dc(12) <=  EX3_NOOP_TOUCH_Q(1);
unused_dc(13) <=  or_reduce(EX3_NOOP_TOUCH_Q(8 TO 11));
unused_dc(14) <=  or_reduce(EX3_ATTR_Q);
unused_dc(15) <=  EX4_RD_CAM_DATA_Q(56);
unused_dc(16) <=  or_reduce(EX6_RS_IS_Q);
unused_dc(17) <=  EX6_STATE_Q(0);
unused_dc(18) <=  EX7_TTYPE_Q(0);
unused_dc(19) <=  or_reduce(EX7_TTYPE_Q(2 TO 11));
unused_dc(20) <=  or_reduce(tlb_rel_data_q(eratpos_rpnrsvd TO eratpos_rpnrsvd+3));
unused_dc(21) <=  or_reduce(XU_DERAT_EX1_EPN_NONARR(0 TO 15));
unused_dc(22) <=  or_reduce(XU_DERAT_EX1_EPN_NONARR(16 TO 21));
unused_dc(23) <=  or_reduce(XU_DERAT_RF1_T);
unused_dc(24) <=  or_reduce(ATTR_NP2(0 TO 1));
unused_dc(25) <=  ATTR_NP2(4);
unused_dc(26) <=  mmucr1_b0_cpy_q;
unused_dc(27) <=  or_reduce(BCFG_Q_B(0 to 15));
unused_dc(28) <=  or_reduce(BCFG_Q_B(16 to 31));
unused_dc(29) <=  or_reduce(BCFG_Q_B(32 to 47));
unused_dc(30) <=  or_reduce(BCFG_Q_B(48 to 51));
unused_dc(31) <=  or_reduce(bcfg_q_b(52 to 61));
unused_dc(32) <=  or_reduce(bcfg_q_b(62 to 77));
unused_dc(33) <=  or_reduce(bcfg_q_b(78 to 81));
unused_dc(34) <=  or_reduce(bcfg_q_b(82 to 86));
unused_dc(35) <=  or_reduce(por_wr_array_data(51 to 67));
unused_dc(36) <=  or_reduce(bcfg_q_b(87 to 102));
unused_dc(37) <=  or_reduce(bcfg_q_b(103 to 106));
unused_dc(38) <=  or_reduce(bcfg_q(110 to 122));
unused_dc(39) <=  or_reduce(bcfg_q_b(107 to 122));
-----------------------------------------------------------------------
-- Latches
-----------------------------------------------------------------------
rf1_valid_latch: tri_rlmreg_p
  generic map (width => rf1_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(rf1_valid_offset to rf1_valid_offset+rf1_valid_q'length-1),
            scout   => sov_0(rf1_valid_offset to rf1_valid_offset+rf1_valid_q'length-1),
            din     => rf1_valid_d(0 to thdid_width-1),
            dout    => rf1_valid_q(0 to thdid_width-1)  );
rf1_ttype_latch: tri_rlmreg_p
  generic map (width => rf1_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(rf1_ttype_offset to rf1_ttype_offset+rf1_ttype_q'length-1),
            scout   => sov_0(rf1_ttype_offset to rf1_ttype_offset+rf1_ttype_q'length-1),
            din     => rf1_ttype_d,
            dout    => rf1_ttype_q  );
ex1_valid_latch: tri_rlmreg_p
  generic map (width => ex1_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex1_valid_offset to ex1_valid_offset+ex1_valid_q'length-1),
            scout   => sov_0(ex1_valid_offset to ex1_valid_offset+ex1_valid_q'length-1),
            din     => ex1_valid_d(0 to thdid_width-1),
            dout    => ex1_valid_q(0 to thdid_width-1)  );
ex1_ttype_latch: tri_rlmreg_p
  generic map (width => ex1_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex1_ttype_offset to ex1_ttype_offset+ex1_ttype_q'length-1),
            scout   => sov_0(ex1_ttype_offset to ex1_ttype_offset+ex1_ttype_q'length-1),
            din     => ex1_ttype_d,
            dout    => ex1_ttype_q  );
ex1_ws_latch: tri_rlmreg_p
  generic map (width => ex1_ws_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => rf1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex1_ws_offset to ex1_ws_offset+ex1_ws_q'length-1),
            scout   => sov_0(ex1_ws_offset to ex1_ws_offset+ex1_ws_q'length-1),
            din     => ex1_ws_d(0 to ws_width-1),
            dout    => ex1_ws_q(0 to ws_width-1)  );
ex1_rs_is_latch: tri_rlmreg_p
  generic map (width => ex1_rs_is_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => rf1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex1_rs_is_offset to ex1_rs_is_offset+ex1_rs_is_q'length-1),
            scout   => sov_0(ex1_rs_is_offset to ex1_rs_is_offset+ex1_rs_is_q'length-1),
            din     => ex1_rs_is_d(0 to rs_is_width-1),
            dout    => ex1_rs_is_q(0 to rs_is_width-1)  );
ex1_ra_entry_latch: tri_rlmreg_p
  generic map (width => ex1_ra_entry_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => rf1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex1_ra_entry_offset to ex1_ra_entry_offset+ex1_ra_entry_q'length-1),
            scout   => sov_0(ex1_ra_entry_offset to ex1_ra_entry_offset+ex1_ra_entry_q'length-1),
            din     => ex1_ra_entry_d(0 to ra_entry_width-1),
            dout    => ex1_ra_entry_q(0 to ra_entry_width-1)  );
ex1_state_latch: tri_rlmreg_p
  generic map (width => ex1_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => rf1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex1_state_offset to ex1_state_offset+ex1_state_q'length-1),
            scout   => sov_0(ex1_state_offset to ex1_state_offset+ex1_state_q'length-1),
            din     => ex1_state_d(0 to state_width-1),
            dout    => ex1_state_q(0 to state_width-1)  );
ex1_pid_latch: tri_rlmreg_p
  generic map (width => ex1_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => rf1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex1_pid_offset to ex1_pid_offset+ex1_pid_q'length-1),
            scout   => sov_0(ex1_pid_offset to ex1_pid_offset+ex1_pid_q'length-1),
            din     => ex1_pid_d,
            dout    => ex1_pid_q  );
ex1_extclass_latch: tri_rlmreg_p
  generic map (width => ex1_extclass_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => rf1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex1_extclass_offset to ex1_extclass_offset+ex1_extclass_q'length-1),
            scout   => sov_0(ex1_extclass_offset to ex1_extclass_offset+ex1_extclass_q'length-1),
            din     => ex1_extclass_d(0 to extclass_width-1),
            dout    => ex1_extclass_q(0 to extclass_width-1)  );
ex1_tlbsel_latch: tri_rlmreg_p
  generic map (width => ex1_tlbsel_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => rf1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex1_tlbsel_offset to ex1_tlbsel_offset+ex1_tlbsel_q'length-1),
            scout   => sov_0(ex1_tlbsel_offset to ex1_tlbsel_offset+ex1_tlbsel_q'length-1),
            din     => ex1_tlbsel_d(0 to tlbsel_width-1),
            dout    => ex1_tlbsel_q(0 to tlbsel_width-1)  );
-------------------------------------------------------------------------------
ex2_valid_latch: tri_rlmreg_p
  generic map (width => ex2_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_valid_offset to ex2_valid_offset+ex2_valid_q'length-1),
            scout   => sov_0(ex2_valid_offset to ex2_valid_offset+ex2_valid_q'length-1),
            din     => ex2_valid_d(0 to thdid_width-1),
            dout    => ex2_valid_q(0 to thdid_width-1)  );
ex2_ttype_latch: tri_rlmreg_p
  generic map (width => ex2_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_ttype_offset to ex2_ttype_offset+ex2_ttype_q'length-1),
            scout   => sov_0(ex2_ttype_offset to ex2_ttype_offset+ex2_ttype_q'length-1),
            din     => ex2_ttype_d(0 to ttype_width-1),
            dout    => ex2_ttype_q(0 to ttype_width-1)  );
ex2_ws_latch: tri_rlmreg_p
  generic map (width => ex2_ws_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_ws_offset to ex2_ws_offset+ex2_ws_q'length-1),
            scout   => sov_0(ex2_ws_offset to ex2_ws_offset+ex2_ws_q'length-1),
            din     => ex2_ws_d(0 to ws_width-1),
            dout    => ex2_ws_q(0 to ws_width-1)  );
ex2_rs_is_latch: tri_rlmreg_p
  generic map (width => ex2_rs_is_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_rs_is_offset to ex2_rs_is_offset+ex2_rs_is_q'length-1),
            scout   => sov_0(ex2_rs_is_offset to ex2_rs_is_offset+ex2_rs_is_q'length-1),
            din     => ex2_rs_is_d(0 to rs_is_width-1),
            dout    => ex2_rs_is_q(0 to rs_is_width-1)  );
ex2_ra_entry_latch: tri_rlmreg_p
  generic map (width => ex2_ra_entry_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_ra_entry_offset to ex2_ra_entry_offset+ex2_ra_entry_q'length-1),
            scout   => sov_0(ex2_ra_entry_offset to ex2_ra_entry_offset+ex2_ra_entry_q'length-1),
            din     => ex2_ra_entry_d(0 to ra_entry_width-1),
            dout    => ex2_ra_entry_q(0 to ra_entry_width-1)  );
ex2_state_latch: tri_rlmreg_p
  generic map (width => ex2_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_state_offset to ex2_state_offset+ex2_state_q'length-1),
            scout   => sov_0(ex2_state_offset to ex2_state_offset+ex2_state_q'length-1),
            din     => ex2_state_d(0 to state_width-1),
            dout    => ex2_state_q(0 to state_width-1)  );
ex2_pid_latch: tri_rlmreg_p
  generic map (width => ex2_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_pid_offset to ex2_pid_offset+ex2_pid_q'length-1),
            scout   => sov_0(ex2_pid_offset to ex2_pid_offset+ex2_pid_q'length-1),
            din     => ex2_pid_d,
            dout    => ex2_pid_q  );
ex2_extclass_latch: tri_rlmreg_p
  generic map (width => ex2_extclass_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_extclass_offset to ex2_extclass_offset+ex2_extclass_q'length-1),
            scout   => sov_0(ex2_extclass_offset to ex2_extclass_offset+ex2_extclass_q'length-1),
            din     => ex2_extclass_d(0 to extclass_width-1),
            dout    => ex2_extclass_q(0 to extclass_width-1)  );
ex2_tlbsel_latch: tri_rlmreg_p
  generic map (width => ex2_tlbsel_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_tlbsel_offset to ex2_tlbsel_offset+ex2_tlbsel_q'length-1),
            scout   => sov_0(ex2_tlbsel_offset to ex2_tlbsel_offset+ex2_tlbsel_q'length-1),
            din     => ex2_tlbsel_d(0 to tlbsel_width-1),
            dout    => ex2_tlbsel_q(0 to tlbsel_width-1)  );
-------------------------------------------------------------------------------
ex3_valid_latch: tri_rlmreg_p
  generic map (width => ex3_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_valid_offset to ex3_valid_offset+ex3_valid_q'length-1),
            scout   => sov_0(ex3_valid_offset to ex3_valid_offset+ex3_valid_q'length-1),
            din     => ex3_valid_d(0 to thdid_width-1),
            dout    => ex3_valid_q(0 to thdid_width-1)  );
ex3_ttype_latch: tri_rlmreg_p
  generic map (width => ex3_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_ttype_offset to ex3_ttype_offset+ex3_ttype_q'length-1),
            scout   => sov_0(ex3_ttype_offset to ex3_ttype_offset+ex3_ttype_q'length-1),
            din     => ex3_ttype_d(0 to ttype_width-1),
            dout    => ex3_ttype_q(0 to ttype_width-1)  );
ex3_ws_latch: tri_rlmreg_p
  generic map (width => ex3_ws_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex2_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_ws_offset to ex3_ws_offset+ex3_ws_q'length-1),
            scout   => sov_0(ex3_ws_offset to ex3_ws_offset+ex3_ws_q'length-1),
            din     => ex3_ws_d(0 to ws_width-1),
            dout    => ex3_ws_q(0 to ws_width-1)  );
ex3_rs_is_latch: tri_rlmreg_p
  generic map (width => ex3_rs_is_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex2_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_rs_is_offset to ex3_rs_is_offset+ex3_rs_is_q'length-1),
            scout   => sov_0(ex3_rs_is_offset to ex3_rs_is_offset+ex3_rs_is_q'length-1),
            din     => ex3_rs_is_d(0 to rs_is_width-1),
            dout    => ex3_rs_is_q(0 to rs_is_width-1)  );
ex3_ra_entry_latch: tri_rlmreg_p
  generic map (width => ex3_ra_entry_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex2_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_ra_entry_offset to ex3_ra_entry_offset+ex3_ra_entry_q'length-1),
            scout   => sov_0(ex3_ra_entry_offset to ex3_ra_entry_offset+ex3_ra_entry_q'length-1),
            din     => ex3_ra_entry_d(0 to ra_entry_width-1),
            dout    => ex3_ra_entry_q(0 to ra_entry_width-1)  );
ex3_state_latch: tri_rlmreg_p
  generic map (width => ex3_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex2_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_state_offset to ex3_state_offset+ex3_state_q'length-1),
            scout   => sov_0(ex3_state_offset to ex3_state_offset+ex3_state_q'length-1),
            din     => ex3_state_d(0 to state_width-1),
            dout    => ex3_state_q(0 to state_width-1)  );
ex3_pid_latch: tri_rlmreg_p
  generic map (width => ex3_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex2_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_pid_offset to ex3_pid_offset+ex3_pid_q'length-1),
            scout   => sov_0(ex3_pid_offset to ex3_pid_offset+ex3_pid_q'length-1),
            din     => ex3_pid_d,
            dout    => ex3_pid_q  );
ex3_lpid_latch: tri_rlmreg_p
  generic map (width => ex3_lpid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex2_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_lpid_offset to ex3_lpid_offset+ex3_lpid_q'length-1),
            scout   => sov_0(ex3_lpid_offset to ex3_lpid_offset+ex3_lpid_q'length-1),
            din     => ex3_lpid_d,
            dout    => ex3_lpid_q  );
ex3_extclass_latch: tri_rlmreg_p
  generic map (width => ex3_extclass_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex2_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_extclass_offset to ex3_extclass_offset+ex3_extclass_q'length-1),
            scout   => sov_0(ex3_extclass_offset to ex3_extclass_offset+ex3_extclass_q'length-1),
            din     => ex3_extclass_d(0 to extclass_width-1),
            dout    => ex3_extclass_q(0 to extclass_width-1)  );
ex3_tlbsel_latch: tri_rlmreg_p
  generic map (width => ex3_tlbsel_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex2_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_tlbsel_offset to ex3_tlbsel_offset+ex3_tlbsel_q'length-1),
            scout   => sov_0(ex3_tlbsel_offset to ex3_tlbsel_offset+ex3_tlbsel_q'length-1),
            din     => ex3_tlbsel_d(0 to tlbsel_width-1),
            dout    => ex3_tlbsel_q(0 to tlbsel_width-1)  );
-------------------------------------------------------------------------------
ex4_valid_latch: tri_rlmreg_p
  generic map (width => ex4_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex4_valid_offset to ex4_valid_offset+ex4_valid_q'length-1),
            scout   => sov_0(ex4_valid_offset to ex4_valid_offset+ex4_valid_q'length-1),
            din     => ex4_valid_d(0 to thdid_width-1),
            dout    => ex4_valid_q(0 to thdid_width-1)  );
ex4_ttype_latch: tri_rlmreg_p
  generic map (width => ex4_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex4_ttype_offset to ex4_ttype_offset+ex4_ttype_q'length-1),
            scout   => sov_0(ex4_ttype_offset to ex4_ttype_offset+ex4_ttype_q'length-1),
            din     => ex4_ttype_d(0 to ttype_width-1),
            dout    => ex4_ttype_q(0 to ttype_width-1)  );
ex4_ws_latch: tri_rlmreg_p
  generic map (width => ex4_ws_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex3_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex4_ws_offset to ex4_ws_offset+ex4_ws_q'length-1),
            scout   => sov_0(ex4_ws_offset to ex4_ws_offset+ex4_ws_q'length-1),
            din     => ex4_ws_d(0 to ws_width-1),
            dout    => ex4_ws_q(0 to ws_width-1)  );
ex4_rs_is_latch: tri_rlmreg_p
  generic map (width => ex4_rs_is_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex3_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex4_rs_is_offset to ex4_rs_is_offset+ex4_rs_is_q'length-1),
            scout   => sov_0(ex4_rs_is_offset to ex4_rs_is_offset+ex4_rs_is_q'length-1),
            din     => ex4_rs_is_d(0 to rs_is_width-1),
            dout    => ex4_rs_is_q(0 to rs_is_width-1)  );
ex4_ra_entry_latch: tri_rlmreg_p
  generic map (width => ex4_ra_entry_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex3_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex4_ra_entry_offset to ex4_ra_entry_offset+ex4_ra_entry_q'length-1),
            scout   => sov_0(ex4_ra_entry_offset to ex4_ra_entry_offset+ex4_ra_entry_q'length-1),
            din     => ex4_ra_entry_d(0 to ra_entry_width-1),
            dout    => ex4_ra_entry_q(0 to ra_entry_width-1)  );
ex4_state_latch: tri_rlmreg_p
  generic map (width => ex4_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex3_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex4_state_offset to ex4_state_offset+ex4_state_q'length-1),
            scout   => sov_0(ex4_state_offset to ex4_state_offset+ex4_state_q'length-1),
            din     => ex4_state_d(0 to state_width-1),
            dout    => ex4_state_q(0 to state_width-1)  );
ex4_pid_latch: tri_rlmreg_p
  generic map (width => ex4_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex3_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex4_pid_offset to ex4_pid_offset+ex4_pid_q'length-1),
            scout   => sov_0(ex4_pid_offset to ex4_pid_offset+ex4_pid_q'length-1),
            din     => ex4_pid_d,
            dout    => ex4_pid_q  );
ex4_extclass_latch: tri_rlmreg_p
  generic map (width => ex4_extclass_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex3_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex4_extclass_offset to ex4_extclass_offset+ex4_extclass_q'length-1),
            scout   => sov_0(ex4_extclass_offset to ex4_extclass_offset+ex4_extclass_q'length-1),
            din     => ex4_extclass_d(0 to extclass_width-1),
            dout    => ex4_extclass_q(0 to extclass_width-1)  );
ex4_tlbsel_latch: tri_rlmreg_p
  generic map (width => ex4_tlbsel_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex3_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex4_tlbsel_offset to ex4_tlbsel_offset+ex4_tlbsel_q'length-1),
            scout   => sov_0(ex4_tlbsel_offset to ex4_tlbsel_offset+ex4_tlbsel_q'length-1),
            din     => ex4_tlbsel_d(0 to tlbsel_width-1),
            dout    => ex4_tlbsel_q(0 to tlbsel_width-1)  );
-------------------------------------------------------------------------------
ex5_valid_latch: tri_rlmreg_p
  generic map (width => ex5_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex5_valid_offset to ex5_valid_offset+ex5_valid_q'length-1),
            scout   => sov_0(ex5_valid_offset to ex5_valid_offset+ex5_valid_q'length-1),
            din     => ex5_valid_d(0 to thdid_width-1),
            dout    => ex5_valid_q(0 to thdid_width-1)  );
ex5_ttype_latch: tri_rlmreg_p
  generic map (width => ex5_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex5_ttype_offset to ex5_ttype_offset+ex5_ttype_q'length-1),
            scout   => sov_0(ex5_ttype_offset to ex5_ttype_offset+ex5_ttype_q'length-1),
            din     => ex5_ttype_d(0 to ttype_width-1),
            dout    => ex5_ttype_q(0 to ttype_width-1)  );
ex5_ws_latch: tri_rlmreg_p
  generic map (width => ex5_ws_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex4_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex5_ws_offset to ex5_ws_offset+ex5_ws_q'length-1),
            scout   => sov_0(ex5_ws_offset to ex5_ws_offset+ex5_ws_q'length-1),
            din     => ex5_ws_d(0 to ws_width-1),
            dout    => ex5_ws_q(0 to ws_width-1)  );
ex5_rs_is_latch: tri_rlmreg_p
  generic map (width => ex5_rs_is_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex4_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex5_rs_is_offset to ex5_rs_is_offset+ex5_rs_is_q'length-1),
            scout   => sov_0(ex5_rs_is_offset to ex5_rs_is_offset+ex5_rs_is_q'length-1),
            din     => ex5_rs_is_d(0 to rs_is_width-1),
            dout    => ex5_rs_is_q(0 to rs_is_width-1)  );
ex5_ra_entry_latch: tri_rlmreg_p
  generic map (width => ex5_ra_entry_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex4_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex5_ra_entry_offset to ex5_ra_entry_offset+ex5_ra_entry_q'length-1),
            scout   => sov_0(ex5_ra_entry_offset to ex5_ra_entry_offset+ex5_ra_entry_q'length-1),
            din     => ex5_ra_entry_d(0 to ra_entry_width-1),
            dout    => ex5_ra_entry_q(0 to ra_entry_width-1)  );
ex5_state_latch: tri_rlmreg_p
  generic map (width => ex5_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex4_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex5_state_offset to ex5_state_offset+ex5_state_q'length-1),
            scout   => sov_0(ex5_state_offset to ex5_state_offset+ex5_state_q'length-1),
            din     => ex5_state_d(0 to state_width-1),
            dout    => ex5_state_q(0 to state_width-1)  );
ex5_pid_latch: tri_rlmreg_p
  generic map (width => ex5_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex4_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex5_pid_offset to ex5_pid_offset+ex5_pid_q'length-1),
            scout   => sov_0(ex5_pid_offset to ex5_pid_offset+ex5_pid_q'length-1),
            din     => ex5_pid_d,
            dout    => ex5_pid_q  );
ex5_extclass_latch: tri_rlmreg_p
  generic map (width => ex5_extclass_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex4_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex5_extclass_offset to ex5_extclass_offset+ex5_extclass_q'length-1),
            scout   => sov_0(ex5_extclass_offset to ex5_extclass_offset+ex5_extclass_q'length-1),
            din     => ex5_extclass_d(0 to extclass_width-1),
            dout    => ex5_extclass_q(0 to extclass_width-1)  );
ex5_tlbsel_latch: tri_rlmreg_p
  generic map (width => ex5_tlbsel_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex4_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex5_tlbsel_offset to ex5_tlbsel_offset+ex5_tlbsel_q'length-1),
            scout   => sov_0(ex5_tlbsel_offset to ex5_tlbsel_offset+ex5_tlbsel_q'length-1),
            din     => ex5_tlbsel_d(0 to tlbsel_width-1),
            dout    => ex5_tlbsel_q(0 to tlbsel_width-1)  );
--------------------------------------------------
ex5_data_in_latch: tri_rlmreg_p
  generic map (width => ex5_data_in_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex4_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex5_data_in_offset to ex5_data_in_offset+ex5_data_in_q'length-1),
            scout   => sov_0(ex5_data_in_offset to ex5_data_in_offset+ex5_data_in_q'length-1),
            din     => ex5_data_in_d(64-rs_data_width to 63),
            dout    => ex5_data_in_q(64-rs_data_width to 63)  );
-------------------------------------------------------------------------------
ex6_valid_latch: tri_rlmreg_p
  generic map (width => ex6_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex6_valid_offset to ex6_valid_offset+ex6_valid_q'length-1),
            scout   => sov_0(ex6_valid_offset to ex6_valid_offset+ex6_valid_q'length-1),
            din     => ex6_valid_d(0 to thdid_width-1),
            dout    => ex6_valid_q(0 to thdid_width-1)  );
ex6_ttype_latch: tri_rlmreg_p
  generic map (width => ex6_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex6_ttype_offset to ex6_ttype_offset+ex6_ttype_q'length-1),
            scout   => sov_0(ex6_ttype_offset to ex6_ttype_offset+ex6_ttype_q'length-1),
            din     => ex6_ttype_d(0 to ttype_width-1),
            dout    => ex6_ttype_q(0 to ttype_width-1)  );
ex6_ws_latch: tri_rlmreg_p
  generic map (width => ex6_ws_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex5_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex6_ws_offset to ex6_ws_offset+ex6_ws_q'length-1),
            scout   => sov_0(ex6_ws_offset to ex6_ws_offset+ex6_ws_q'length-1),
            din     => ex6_ws_d(0 to ws_width-1),
            dout    => ex6_ws_q(0 to ws_width-1)  );
ex6_rs_is_latch: tri_rlmreg_p
  generic map (width => ex6_rs_is_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex5_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex6_rs_is_offset to ex6_rs_is_offset+ex6_rs_is_q'length-1),
            scout   => sov_0(ex6_rs_is_offset to ex6_rs_is_offset+ex6_rs_is_q'length-1),
            din     => ex6_rs_is_d(0 to rs_is_width-1),
            dout    => ex6_rs_is_q(0 to rs_is_width-1)  );
ex6_ra_entry_latch: tri_rlmreg_p
  generic map (width => ex6_ra_entry_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex5_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex6_ra_entry_offset to ex6_ra_entry_offset+ex6_ra_entry_q'length-1),
            scout   => sov_0(ex6_ra_entry_offset to ex6_ra_entry_offset+ex6_ra_entry_q'length-1),
            din     => ex6_ra_entry_d(0 to ra_entry_width-1),
            dout    => ex6_ra_entry_q(0 to ra_entry_width-1)  );
ex6_state_latch: tri_rlmreg_p
  generic map (width => ex6_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex5_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex6_state_offset to ex6_state_offset+ex6_state_q'length-1),
            scout   => sov_0(ex6_state_offset to ex6_state_offset+ex6_state_q'length-1),
            din     => ex6_state_d(0 to state_width-1),
            dout    => ex6_state_q(0 to state_width-1)  );
ex6_pid_latch: tri_rlmreg_p
  generic map (width => ex6_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex5_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex6_pid_offset to ex6_pid_offset+ex6_pid_q'length-1),
            scout   => sov_0(ex6_pid_offset to ex6_pid_offset+ex6_pid_q'length-1),
            din     => ex6_pid_d,
            dout    => ex6_pid_q  );
ex6_extclass_latch: tri_rlmreg_p
  generic map (width => ex6_extclass_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex5_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex6_extclass_offset to ex6_extclass_offset+ex6_extclass_q'length-1),
            scout   => sov_0(ex6_extclass_offset to ex6_extclass_offset+ex6_extclass_q'length-1),
            din     => ex6_extclass_d(0 to extclass_width-1),
            dout    => ex6_extclass_q(0 to extclass_width-1)  );
ex6_tlbsel_latch: tri_rlmreg_p
  generic map (width => ex6_tlbsel_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex5_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex6_tlbsel_offset to ex6_tlbsel_offset+ex6_tlbsel_q'length-1),
            scout   => sov_0(ex6_tlbsel_offset to ex6_tlbsel_offset+ex6_tlbsel_q'length-1),
            din     => ex6_tlbsel_d(0 to tlbsel_width-1),
            dout    => ex6_tlbsel_q(0 to tlbsel_width-1)  );
--------------------------------------------------
ex6_data_in_latch: tri_rlmreg_p
  generic map (width => ex6_data_in_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex5_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex6_data_in_offset to ex6_data_in_offset+ex6_data_in_q'length-1),
            scout   => sov_0(ex6_data_in_offset to ex6_data_in_offset+ex6_data_in_q'length-1),
            din     => ex6_data_in_d(64-rs_data_width to 63),
            dout    => ex6_data_in_q(64-rs_data_width to 63)  );
-------------------------------------------------------------------------------
ex7_valid_latch: tri_rlmreg_p
  generic map (width => ex7_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex7_valid_offset to ex7_valid_offset+ex7_valid_q'length-1),
            scout   => sov_0(ex7_valid_offset to ex7_valid_offset+ex7_valid_q'length-1),
            din     => ex7_valid_d(0 to thdid_width-1),
            dout    => ex7_valid_q(0 to thdid_width-1)  );
ex7_ttype_latch: tri_rlmreg_p
  generic map (width => ex7_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex7_ttype_offset to ex7_ttype_offset+ex7_ttype_q'length-1),
            scout   => sov_0(ex7_ttype_offset to ex7_ttype_offset+ex7_ttype_q'length-1),
            din     => ex7_ttype_d(0 to ttype_width-1),
            dout    => ex7_ttype_q(0 to ttype_width-1)  );
ex7_tlbsel_latch: tri_rlmreg_p
  generic map (width => ex7_tlbsel_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex7_tlbsel_offset to ex7_tlbsel_offset+ex7_tlbsel_q'length-1),
            scout   => sov_0(ex7_tlbsel_offset to ex7_tlbsel_offset+ex7_tlbsel_q'length-1),
            din     => ex7_tlbsel_d(0 to tlbsel_width-1),
            dout    => ex7_tlbsel_q(0 to tlbsel_width-1)  );
--------------------------------------------------
ex4_data_out_latch: tri_rlmreg_p
  generic map (width => ex4_data_out_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex3_data_out_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex4_data_out_offset to ex4_data_out_offset+ex4_data_out_q'length-1),
            scout   => sov_0(ex4_data_out_offset to ex4_data_out_offset+ex4_data_out_q'length-1),
            din     => ex4_data_out_d(64-data_out_width to 63),
            dout    => ex4_data_out_q(64-data_out_width to 63)  );
ex2_n_flush_req_latch: tri_rlmreg_p
  generic map (width => ex2_n_flush_req_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_n_flush_req_offset to ex2_n_flush_req_offset+ex2_n_flush_req_q'length-1),
            scout   => sov_0(ex2_n_flush_req_offset to ex2_n_flush_req_offset+ex2_n_flush_req_q'length-1),
            din     => ex2_n_flush_req_d(0 to thdid_width-1),
            dout    => ex2_n_flush_req_q(0 to thdid_width-1)  );
ex3_n_flush_req_latch: tri_rlmreg_p
  generic map (width => ex3_n_flush_req_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_n_flush_req_offset to ex3_n_flush_req_offset+ex3_n_flush_req_q'length-1),
            scout   => sov_0(ex3_n_flush_req_offset to ex3_n_flush_req_offset+ex3_n_flush_req_q'length-1),
            din     => ex3_n_flush_req_d(0 to thdid_width-1),
            dout    => ex3_n_flush_req_q(0 to thdid_width-1)  );
hold_req_reset_latch: tri_rlmreg_p
  generic map (width => hold_req_reset_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(hold_req_reset_offset to hold_req_reset_offset+hold_req_reset_q'length-1),
            scout   => sov_0(hold_req_reset_offset to hold_req_reset_offset+hold_req_reset_q'length-1),
            din     => hold_req_reset_d(0 to thdid_width-1),
            dout    => hold_req_reset_q(0 to thdid_width-1)  );
hold_req_pot_set_latch: tri_rlmreg_p
  generic map (width => hold_req_pot_set_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(hold_req_pot_set_offset to hold_req_pot_set_offset+hold_req_pot_set_q'length-1),
            scout   => sov_0(hold_req_pot_set_offset to hold_req_pot_set_offset+hold_req_pot_set_q'length-1),
            din     => hold_req_pot_set_d(0 to thdid_width-1),
            dout    => hold_req_pot_set_q(0 to thdid_width-1)  );
hold_req_por_latch: tri_rlmreg_p
  generic map (width => hold_req_por_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(hold_req_por_offset to hold_req_por_offset+hold_req_por_q'length-1),
            scout   => sov_0(hold_req_por_offset to hold_req_por_offset+hold_req_por_q'length-1),
            din     => hold_req_por_d(0 to thdid_width-1),
            dout    => hold_req_por_q(0 to thdid_width-1)  );
hold_req_latch: tri_rlmreg_p
  generic map (width => hold_req_q'length, init => 15, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(hold_req_offset to hold_req_offset+hold_req_q'length-1),
            scout   => sov_0(hold_req_offset to hold_req_offset+hold_req_q'length-1),
            din     => hold_req_d(0 to thdid_width-1),
            dout    => hold_req_q(0 to thdid_width-1)  );
tlb_req_inprogress_latch: tri_rlmreg_p
  generic map (width => tlb_req_inprogress_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_req_inprogress_offset to tlb_req_inprogress_offset+tlb_req_inprogress_q'length-1),
            scout   => sov_0(tlb_req_inprogress_offset to tlb_req_inprogress_offset+tlb_req_inprogress_q'length-1),
            din     => tlb_req_inprogress_d(0 to thdid_width-1),
            dout    => tlb_req_inprogress_q(0 to thdid_width-1)  );
ex2_dsi_latch: tri_rlmreg_p
  generic map (width => ex2_dsi_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_dsi_offset to ex2_dsi_offset+ex2_dsi_q'length-1),
            scout   => sov_0(ex2_dsi_offset to ex2_dsi_offset+ex2_dsi_q'length-1),
            din     => ex2_dsi_d,
            dout    => ex2_dsi_q);
ex2_noop_touch_latch: tri_rlmreg_p
  generic map (width => ex2_noop_touch_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_noop_touch_offset to ex2_noop_touch_offset+ex2_noop_touch_q'length-1),
            scout   => sov_0(ex2_noop_touch_offset to ex2_noop_touch_offset+ex2_noop_touch_q'length-1),
            din     => ex2_noop_touch_d,
            dout    => ex2_noop_touch_q);
ex3_miss_latch: tri_rlmreg_p
  generic map (width => ex3_miss_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_or_ex3_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_miss_offset to ex3_miss_offset+ex3_miss_q'length-1),
            scout   => sov_0(ex3_miss_offset to ex3_miss_offset+ex3_miss_q'length-1),
            din     => ex3_miss_d(0 to thdid_width-1),
            dout    => ex3_miss_q(0 to thdid_width-1));
ex3_dsi_latch: tri_rlmreg_p
  generic map (width => ex3_dsi_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_dsi_offset to ex3_dsi_offset+ex3_dsi_q'length-1),
            scout   => sov_0(ex3_dsi_offset to ex3_dsi_offset+ex3_dsi_q'length-1),
            din     => ex3_dsi_d,
            dout    => ex3_dsi_q);
ex3_noop_touch_latch: tri_rlmreg_p
  generic map (width => ex3_noop_touch_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_or_ex3_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_noop_touch_offset to ex3_noop_touch_offset+ex3_noop_touch_q'length-1),
            scout   => sov_0(ex3_noop_touch_offset to ex3_noop_touch_offset+ex3_noop_touch_q'length-1),
            din     => ex3_noop_touch_d,
            dout    => ex3_noop_touch_q);
ex3_multihit_latch: tri_rlmreg_p
  generic map (width => ex3_multihit_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_or_ex3_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_multihit_offset to ex3_multihit_offset+ex3_multihit_q'length-1),
            scout   => sov_0(ex3_multihit_offset to ex3_multihit_offset+ex3_multihit_q'length-1),
            din     => ex3_multihit_d(0 to thdid_width-1),
            dout    => ex3_multihit_q(0 to thdid_width-1));
ex3_multihit_b_pt_latch: tri_rlmreg_p
  generic map (width => ex3_multihit_b_pt_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_or_ex3_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_multihit_b_pt_offset to ex3_multihit_b_pt_offset+ex3_multihit_b_pt_q'length-1),
            scout   => sov_0(ex3_multihit_b_pt_offset to ex3_multihit_b_pt_offset+ex3_multihit_b_pt_q'length-1),
            din     => ex3_multihit_b_pt_d,
            dout    => ex3_multihit_b_pt_q);
ex3_first_hit_entry_pt_latch: tri_rlmreg_p
  generic map (width => ex3_first_hit_entry_pt_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_or_ex3_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_first_hit_entry_pt_offset to ex3_first_hit_entry_pt_offset+ex3_first_hit_entry_pt_q'length-1),
            scout   => sov_0(ex3_first_hit_entry_pt_offset to ex3_first_hit_entry_pt_offset+ex3_first_hit_entry_pt_q'length-1),
            din     => ex3_first_hit_entry_pt_d,
            dout    => ex3_first_hit_entry_pt_q);
ex3_parerr_latch: tri_rlmreg_p
  generic map (width => ex3_parerr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => not_grffence_act,  
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_parerr_offset to ex3_parerr_offset+ex3_parerr_q'length-1),
            scout   => sov_0(ex3_parerr_offset to ex3_parerr_offset+ex3_parerr_q'length-1),
            din     => ex3_parerr_d,
            dout    => ex3_parerr_q);
ex3_attr_latch: tri_rlmreg_p
  generic map (width => ex3_attr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_attr_offset to ex3_attr_offset+ex3_attr_q'length-1),
            scout   => sov_0(ex3_attr_offset to ex3_attr_offset+ex3_attr_q'length-1),
            din     => ex3_attr_q(0 to 5),    
            dout    => ex3_attr_q(0 to 5));
ex3_tlbreq_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => notlb_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_tlbreq_offset),
            scout   => sov_0(ex3_tlbreq_offset),
            din     => ex3_tlbreq_d,
            dout    => ex3_tlbreq_q);
ex3_cam_hit_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex2_or_ex3_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_cam_hit_offset),
            scout   => sov_0(ex3_cam_hit_offset),
            din     => cam_hit,
            dout    => ex3_cam_hit_q);
ex3_hit_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex2_or_ex3_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_hit_offset),
            scout   => sov_0(ex3_hit_offset),
            din     => ex3_hit_d,
            dout    => ex3_hit_q);
ex2_debug_latch: tri_rlmreg_p
  generic map (width => ex2_debug_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex2_debug_offset to ex2_debug_offset+ex2_debug_q'length-1),
            scout   => sov_0(ex2_debug_offset to ex2_debug_offset+ex2_debug_q'length-1),
            din     => ex2_debug_d,
            dout    => ex2_debug_q);
ex3_debug_latch: tri_rlmreg_p
  generic map (width => ex3_debug_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => debug_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_debug_offset to ex3_debug_offset+ex3_debug_q'length-1),
            scout   => sov_0(ex3_debug_offset to ex3_debug_offset+ex3_debug_q'length-1),
            din     => ex3_debug_d,
            dout    => ex3_debug_q);
ex4_rd_array_data_latch: tri_rlmreg_p
  generic map (width => ex4_rd_array_data_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_rd_data_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex4_rd_array_data_offset to ex4_rd_array_data_offset+ex4_rd_array_data_q'length-1),
            scout   => sov_1(ex4_rd_array_data_offset to ex4_rd_array_data_offset+ex4_rd_array_data_q'length-1),
            din     => ex4_rd_array_data_d(0 to array_data_width-1),
            dout    => ex4_rd_array_data_q(0 to array_data_width-1));
ex4_rd_cam_data_latch: tri_rlmreg_p
  generic map (width => ex4_rd_cam_data_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_rd_data_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex4_rd_cam_data_offset to ex4_rd_cam_data_offset+ex4_rd_cam_data_q'length-1),
            scout   => sov_1(ex4_rd_cam_data_offset to ex4_rd_cam_data_offset+ex4_rd_cam_data_q'length-1),
            din     => ex4_rd_cam_data_d(0 to cam_data_width-1),
            dout    => ex4_rd_cam_data_q(0 to cam_data_width-1));
ex4_parerr_latch: tri_rlmreg_p
  generic map (width => ex4_parerr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex4_parerr_offset to ex4_parerr_offset+ex4_parerr_q'length-1),
            scout   => sov_1(ex4_parerr_offset to ex4_parerr_offset+ex4_parerr_q'length-1),
            din     => ex4_parerr_d,
            dout    => ex4_parerr_q);
ex4_fir_parerr_latch: tri_rlmreg_p
  generic map (width => ex4_fir_parerr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex4_fir_parerr_offset to ex4_fir_parerr_offset+ex4_fir_parerr_q'length-1),
            scout   => sov_1(ex4_fir_parerr_offset to ex4_fir_parerr_offset+ex4_fir_parerr_q'length-1),
            din     => ex4_fir_parerr_d,
            dout    => ex4_fir_parerr_q);
ex4_fir_multihit_latch: tri_rlmreg_p
  generic map (width => ex4_fir_multihit_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex4_fir_multihit_offset to ex4_fir_multihit_offset+ex4_fir_multihit_q'length-1),
            scout   => sov_1(ex4_fir_multihit_offset to ex4_fir_multihit_offset+ex4_fir_multihit_q'length-1),
            din     => ex4_fir_multihit_d(0 to thdid_width-1),
            dout    => ex4_fir_multihit_q(0 to thdid_width-1));
ex4_deen_latch: tri_rlmreg_p
  generic map (width => ex4_deen_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex4_deen_offset to ex4_deen_offset+ex4_deen_q'length-1),
            scout   => sov_1(ex4_deen_offset to ex4_deen_offset+ex4_deen_q'length-1),
            din     => ex4_deen_d(0 to ex4_deen_d'length-1),
            dout    => ex4_deen_q(0 to ex4_deen_q'length-1));
ex4_hit_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex4_hit_offset),
            scout   => sov_1(ex4_hit_offset),
            din     => ex4_hit_d,
            dout    => ex4_hit_q);
ex5_deen_latch: tri_rlmreg_p
  generic map (width => ex5_deen_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex5_deen_offset to ex5_deen_offset+ex5_deen_q'length-1),
            scout   => sov_1(ex5_deen_offset to ex5_deen_offset+ex5_deen_q'length-1),
            din     => ex5_deen_d(0 to ex5_deen_d'length-1),
            dout    => ex5_deen_q(0 to ex5_deen_q'length-1));
ex5_hit_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex5_hit_offset),
            scout   => sov_1(ex5_hit_offset),
            din     => ex5_hit_d,
            dout    => ex5_hit_q);
ex6_deen_latch: tri_rlmreg_p
  generic map (width => ex6_deen_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex6_deen_offset to ex6_deen_offset+ex6_deen_q'length-1),
            scout   => sov_1(ex6_deen_offset to ex6_deen_offset+ex6_deen_q'length-1),
            din     => ex6_deen_d(0 to ex6_deen_d'length-1),
            dout    => ex6_deen_q(0 to ex6_deen_q'length-1));
ex6_hit_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex6_hit_offset),
            scout   => sov_1(ex6_hit_offset),
            din     => ex6_hit_d,
            dout    => ex6_hit_q);
barrier_done_latch: tri_rlmreg_p
  generic map (width => barrier_done_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(barrier_done_offset to barrier_done_offset+barrier_done_q'length-1),
            scout   => sov_1(barrier_done_offset to barrier_done_offset+barrier_done_q'length-1),
            din     => barrier_done_d(0 to barrier_done_d'length-1),
            dout    => barrier_done_q(0 to barrier_done_q'length-1));
mchk_flash_inv_latch: tri_rlmreg_p
  generic map (width => mchk_flash_inv_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_to_ex6_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mchk_flash_inv_offset to mchk_flash_inv_offset+mchk_flash_inv_q'length-1),
            scout   => sov_1(mchk_flash_inv_offset to mchk_flash_inv_offset+mchk_flash_inv_q'length-1),
            din     => mchk_flash_inv_d(0 to mchk_flash_inv_d'length-1),
            dout    => mchk_flash_inv_q(0 to mchk_flash_inv_q'length-1));
mmucr1_latch: tri_rlmreg_p
  generic map (width => mmucr1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mmucr1_offset to mmucr1_offset+mmucr1_q'length-1),
            scout   => sov_1(mmucr1_offset to mmucr1_offset+mmucr1_q'length-1),
            din     => mmucr1_d,
            dout    => mmucr1_q  );
rpn_holdreg0_latch: tri_rlmreg_p
  generic map (width => rpn_holdreg0_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex6_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(rpn_holdreg0_offset to rpn_holdreg0_offset+rpn_holdreg0_q'length-1),
            scout   => sov_1(rpn_holdreg0_offset to rpn_holdreg0_offset+rpn_holdreg0_q'length-1),
            din     => rpn_holdreg0_d(0 to 63),
            dout    => rpn_holdreg0_q(0 to 63)  );
rpn_holdreg1_latch: tri_rlmreg_p
  generic map (width => rpn_holdreg1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex6_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(rpn_holdreg1_offset to rpn_holdreg1_offset+rpn_holdreg1_q'length-1),
            scout   => sov_1(rpn_holdreg1_offset to rpn_holdreg1_offset+rpn_holdreg1_q'length-1),
            din     => rpn_holdreg1_d(0 to 63),
            dout    => rpn_holdreg1_q(0 to 63)  );
rpn_holdreg2_latch: tri_rlmreg_p
  generic map (width => rpn_holdreg2_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex6_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(rpn_holdreg2_offset to rpn_holdreg2_offset+rpn_holdreg2_q'length-1),
            scout   => sov_1(rpn_holdreg2_offset to rpn_holdreg2_offset+rpn_holdreg2_q'length-1),
            din     => rpn_holdreg2_d(0 to 63),
            dout    => rpn_holdreg2_q(0 to 63)  );
rpn_holdreg3_latch: tri_rlmreg_p
  generic map (width => rpn_holdreg3_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex6_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(rpn_holdreg3_offset to rpn_holdreg3_offset+rpn_holdreg3_q'length-1),
            scout   => sov_1(rpn_holdreg3_offset to rpn_holdreg3_offset+rpn_holdreg3_q'length-1),
            din     => rpn_holdreg3_d(0 to 63),
            dout    => rpn_holdreg3_q(0 to 63)  );
entry_valid_latch: tri_rlmreg_p
  generic map (width => entry_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => entry_valid_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(entry_valid_offset to entry_valid_offset+entry_valid_q'length-1),
            scout   => sov_1(entry_valid_offset to entry_valid_offset+entry_valid_q'length-1),
            din     => entry_valid,
            dout    => entry_valid_q  );
entry_match_latch: tri_rlmreg_p
  generic map (width => entry_match_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => entry_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(entry_match_offset to entry_match_offset+entry_match_q'length-1),
            scout   => sov_1(entry_match_offset to entry_match_offset+entry_match_q'length-1),
            din     => entry_match,
            dout    => entry_match_q  );
watermark_latch: tri_rlmreg_p
  generic map (width => watermark_q'length, init => 29, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex6_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(watermark_offset to watermark_offset+watermark_q'length-1),
            scout   => sov_1(watermark_offset to watermark_offset+watermark_q'length-1),
            din     => watermark_d(0 to watermark_width-1),
            dout    => watermark_q(0 to watermark_width-1)  );
mmucr1_b0_cpy_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mmucr1_b0_cpy_offset),
            scout   => sov_1(mmucr1_b0_cpy_offset),
            din     => mmucr1_b0_cpy_d,
            dout    => mmucr1_b0_cpy_q);
lru_rmt_vec_latch: tri_rlmreg_p
  generic map (width => lru_rmt_vec_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex6_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lru_rmt_vec_offset to lru_rmt_vec_offset+lru_rmt_vec_q'length-1),
            scout   => sov_1(lru_rmt_vec_offset to lru_rmt_vec_offset+lru_rmt_vec_q'length-1),
            din     => lru_rmt_vec_d,
            dout    => lru_rmt_vec_q  );
eptr_latch: tri_rlmreg_p
  generic map (width => eptr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => mmucr1_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(eptr_offset to eptr_offset+eptr_q'length-1),
            scout   => sov_1(eptr_offset to eptr_offset+eptr_q'length-1),
            din     => eptr_d(0 to eptr_width-1),
            dout    => eptr_q(0 to eptr_width-1)  );
lru_latch: tri_rlmreg_p
  generic map (width => lru_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lru_update_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lru_offset to lru_offset+lru_q'length-1),
            scout   => sov_1(lru_offset to lru_offset+lru_q'length-1),
            din     => lru_d(1 to lru_width),
            dout    => lru_q(1 to lru_width)  );
lru_update_event_latch: tri_rlmreg_p
  generic map (width => lru_update_event_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => not_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lru_update_event_offset to lru_update_event_offset+lru_update_event_q'length-1),
            scout   => sov_1(lru_update_event_offset to lru_update_event_offset+lru_update_event_q'length-1),
            din     => lru_update_event_d,
            dout    => lru_update_event_q  );
lru_debug_latch: tri_rlmreg_p
  generic map (width => lru_debug_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lru_debug_offset to lru_debug_offset+lru_debug_q'length-1),
            scout   => sov_1(lru_debug_offset to lru_debug_offset+lru_debug_q'length-1),
            din     => lru_debug_d,
            dout    => lru_debug_q  );
snoop_val_latch: tri_rlmreg_p
  generic map (width => snoop_val_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,       
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(snoop_val_offset to snoop_val_offset+snoop_val_q'length-1),
            scout   => sov_1(snoop_val_offset to snoop_val_offset+snoop_val_q'length-1),
            din     => snoop_val_d,
            dout    => snoop_val_q  );
snoop_attr_latch: tri_rlmreg_p
  generic map (width => snoop_attr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => snoop_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(snoop_attr_offset to snoop_attr_offset+snoop_attr_q'length-1),
            scout   => sov_1(snoop_attr_offset to snoop_attr_offset+snoop_attr_q'length-1),
            din     => snoop_attr_d,
            dout    => snoop_attr_q  );
snoop_addr_latch: tri_rlmreg_p
  generic map (width => snoop_addr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => snoop_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(snoop_addr_offset to snoop_addr_offset+snoop_addr_q'length-1),
            scout   => sov_1(snoop_addr_offset to snoop_addr_offset+snoop_addr_q'length-1),
            din     => snoop_addr_d(52-epn_width to 51),
            dout    => snoop_addr_q(52-epn_width to 51)  );
ex2_epn_latch: tri_rlmreg_p
  generic map (width => ex2_epn_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ex1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex2_epn_offset to ex2_epn_offset+ex2_epn_q'length-1),
            scout   => sov_1(ex2_epn_offset to ex2_epn_offset+ex2_epn_q'length-1),
            din     => ex2_epn_d(52-ex2_epn_width to 51),
            dout    => ex2_epn_q(52-ex2_epn_width to 51)  );
por_seq_latch: tri_rlmreg_p
  generic map (width => por_seq_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(por_seq_offset to por_seq_offset+por_seq_q'length-1),
            scout   => sov_1(por_seq_offset to por_seq_offset+por_seq_q'length-1),
            din     => por_seq_d(0 to por_seq_width-1),
            dout    => por_seq_q(0 to por_seq_width-1)  );
pc_xu_init_reset_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pc_xu_init_reset_offset),
            scout   => sov_1(pc_xu_init_reset_offset),
            din     => pc_xu_init_reset,
            dout    => pc_xu_init_reset_q);
-- timing latches for reloads
tlb_rel_val_latch: tri_rlmreg_p
  generic map (width => tlb_rel_val_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(tlb_rel_val_offset to tlb_rel_val_offset+tlb_rel_val_q'length-1),
            scout   => sov_1(tlb_rel_val_offset to tlb_rel_val_offset+tlb_rel_val_q'length-1),
            din     => tlb_rel_val_d,
            dout    => tlb_rel_val_q  );
tlb_rel_data_latch: tri_rlmreg_p
  generic map (width => tlb_rel_data_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_rel_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(tlb_rel_data_offset to tlb_rel_data_offset+tlb_rel_data_q'length-1),
            scout   => sov_1(tlb_rel_data_offset to tlb_rel_data_offset+tlb_rel_data_q'length-1),
            din     => tlb_rel_data_d,
            dout    => tlb_rel_data_q  );
eplc_wr_latch: tri_rlmreg_p
  generic map (width => eplc_wr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(eplc_wr_offset to eplc_wr_offset+eplc_wr_q'length-1),
            scout   => sov_1(eplc_wr_offset to eplc_wr_offset+eplc_wr_q'length-1),
            din     => eplc_wr_d,
            dout    => eplc_wr_q  );
epsc_wr_latch: tri_rlmreg_p
  generic map (width => epsc_wr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(epsc_wr_offset to epsc_wr_offset+epsc_wr_q'length-1),
            scout   => sov_1(epsc_wr_offset to epsc_wr_offset+epsc_wr_q'length-1),
            din     => epsc_wr_d,
            dout    => epsc_wr_q  );
ccr2_frat_paranoia_latch: tri_rlmreg_p
  generic map (width => ccr2_frat_paranoia_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ccr2_frat_paranoia_offset to ccr2_frat_paranoia_offset+ccr2_frat_paranoia_q'length-1),
            scout   => sov_1(ccr2_frat_paranoia_offset to ccr2_frat_paranoia_offset+ccr2_frat_paranoia_q'length-1),
            din     => ccr2_frat_paranoia_d,
            dout    => ccr2_frat_paranoia_q  );
ccr2_notlb_latch: tri_rlmlatch_p
  generic map (init => 1, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ccr2_notlb_offset),
            scout   => sov_1(ccr2_notlb_offset),
            din     => xu_derat_hid_mmu_mode,
            dout    => ccr2_notlb_q);
xucr4_mmu_mchk_latch: tri_rlmlatch_p
  generic map (init => 1, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(xucr4_mmu_mchk_offset),
            scout   => sov_1(xucr4_mmu_mchk_offset),
            din     => spr_xucr4_mmu_mchk,  
            dout    => xucr4_mmu_mchk_q);
clkg_ctl_override_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(clkg_ctl_override_offset),
            scout   => sov_1(clkg_ctl_override_offset),
            din     => clkg_ctl_override_d,
            dout    => clkg_ctl_override_q);
rf1_stg_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(rf1_stg_act_offset),
            scout   => sov_1(rf1_stg_act_offset),
            din     => rf1_stg_act_d,
            dout    => rf1_stg_act_q);
ex1_stg_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex1_stg_act_offset),
            scout   => sov_1(ex1_stg_act_offset),
            din     => ex1_stg_act_d,
            dout    => ex1_stg_act_q);
ex2_stg_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex2_stg_act_offset),
            scout   => sov_1(ex2_stg_act_offset),
            din     => ex2_stg_act_d,
            dout    => ex2_stg_act_q);
ex3_stg_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex3_stg_act_offset),
            scout   => sov_1(ex3_stg_act_offset),
            din     => ex3_stg_act_d,
            dout    => ex3_stg_act_q);
ex4_stg_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex4_stg_act_offset),
            scout   => sov_1(ex4_stg_act_offset),
            din     => ex4_stg_act_d,
            dout    => ex4_stg_act_q);
ex5_stg_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex5_stg_act_offset),
            scout   => sov_1(ex5_stg_act_offset),
            din     => ex5_stg_act_d,
            dout    => ex5_stg_act_q);
ex6_stg_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex6_stg_act_offset),
            scout   => sov_1(ex6_stg_act_offset),
            din     => ex6_stg_act_d,
            dout    => ex6_stg_act_q);
ex7_stg_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(ex7_stg_act_offset),
            scout   => sov_1(ex7_stg_act_offset),
            din     => ex7_stg_act_d,
            dout    => ex7_stg_act_q);
tlb_rel_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(tlb_rel_act_offset),
            scout   => sov_1(tlb_rel_act_offset),
            din     => tlb_rel_act_d,
            dout    => tlb_rel_act_q);
snoop_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(snoop_act_offset),
            scout   => sov_1(snoop_act_offset),
            din     => mm_xu_derat_snoop_coming,
            dout    => snoop_act_q);
-- for debug trace bus latch act
trace_bus_enable_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(trace_bus_enable_offset),
            scout   => sov_1(trace_bus_enable_offset),
            din     => pc_xu_trace_bus_enable,
            dout    => trace_bus_enable_q);
an_ac_grffence_en_dc_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(an_ac_grffence_en_dc_offset),
            scout   => sov_1(an_ac_grffence_en_dc_offset),
            din     => an_ac_grffence_en_dc_q,
            dout    => an_ac_grffence_en_dc_q);
spare_a_latch: tri_rlmreg_p
  generic map (width => spare_a_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spare_a_offset to spare_a_offset+spare_a_q'length-1),
            scout   => sov_0(spare_a_offset to spare_a_offset+spare_a_q'length-1),
            din     => spare_a_q,
            dout    => spare_a_q  );
spare_b_latch: tri_rlmreg_p
  generic map (width => spare_b_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spare_b_offset to spare_b_offset+spare_b_q'length-1),
            scout   => sov_1(spare_b_offset to spare_b_offset+spare_b_q'length-1),
            din     => spare_b_q,
            dout    => spare_b_q  );
--------------------------------------------------
-- scan only latches for boot config
--------------------------------------------------
mpg_bcfg_gen: if expand_type /= 1 generate
bcfg_epn_0to15_latch: tri_slat_scan
  generic map (width => 16, init => std_ulogic_vector( to_unsigned( bcfg_epn_0to15, 16 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset to bcfg_offset+15),
            scan_out   => bsov(bcfg_offset to bcfg_offset+15),
            q      => bcfg_q(0 to 15),
            q_b    => bcfg_q_b(0 to 15)  );
bcfg_epn_16to31_latch: tri_slat_scan
  generic map (width => 16, init => std_ulogic_vector( to_unsigned( bcfg_epn_16to31, 16 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset+16 to bcfg_offset+31),
            scan_out   => bsov(bcfg_offset+16 to bcfg_offset+31),
            q      => bcfg_q(16 to 31),
            q_b    => bcfg_q_b(16 to 31)  );
bcfg_epn_32to47_latch: tri_slat_scan
  generic map (width => 16, init => std_ulogic_vector( to_unsigned( bcfg_epn_32to47, 16 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset+32 to bcfg_offset+47),
            scan_out   => bsov(bcfg_offset+32 to bcfg_offset+47),
            q      => bcfg_q(32 to 47),
            q_b    => bcfg_q_b(32 to 47)  );
bcfg_epn_48to51_latch: tri_slat_scan
  generic map (width => 4, init => std_ulogic_vector( to_unsigned( bcfg_epn_48to51, 4 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset+48 to bcfg_offset+51),
            scan_out   => bsov(bcfg_offset+48 to bcfg_offset+51),
            q      => bcfg_q(48 to 51),
            q_b    => bcfg_q_b(48 to 51)  );
bcfg_rpn_22to31_latch: tri_slat_scan
  generic map (width => 10, init => std_ulogic_vector( to_unsigned( bcfg_rpn_22to31, 10 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset+52 to bcfg_offset+61),
            scan_out   => bsov(bcfg_offset+52 to bcfg_offset+61),
            q      => bcfg_q(52 to 61),
            q_b    => bcfg_q_b(52 to 61)  );
bcfg_rpn_32to47_latch: tri_slat_scan
  generic map (width => 16, init => std_ulogic_vector( to_unsigned( bcfg_rpn_32to47, 16 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset+62 to bcfg_offset+77),
            scan_out   => bsov(bcfg_offset+62 to bcfg_offset+77),
            q      => bcfg_q(62 to 77),
            q_b    => bcfg_q_b(62 to 77)  );
bcfg_rpn_48to51_latch: tri_slat_scan
  generic map (width => 4, init => std_ulogic_vector( to_unsigned( bcfg_rpn_48to51, 4 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset+78 to bcfg_offset+81),
            scan_out   => bsov(bcfg_offset+78 to bcfg_offset+81),
            q      => bcfg_q(78 to 81),
            q_b    => bcfg_q_b(78 to 81)  );
bcfg_attr_latch: tri_slat_scan
  generic map (width => 5, init => std_ulogic_vector( to_unsigned( bcfg_attr, 5 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset+82 to bcfg_offset+86),
            scan_out   => bsov(bcfg_offset+82 to bcfg_offset+86),
            q      => bcfg_q(82 to 86),
            q_b    => bcfg_q_b(82 to 86)  );
bcfg_rpn2_32to47_latch: tri_slat_scan
  generic map (width => 16, init => std_ulogic_vector( to_unsigned( bcfg_rpn2_32to47, 16 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset+87 to bcfg_offset+102),
            scan_out   => bsov(bcfg_offset+87 to bcfg_offset+102),
            q      => bcfg_q(87 to 102),
            q_b    => bcfg_q_b(87 to 102)  );
bcfg_rpn2_48to51_latch: tri_slat_scan
  generic map (width => 4, init => std_ulogic_vector( to_unsigned( bcfg_rpn2_48to51, 4 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset+103 to bcfg_offset+106),
            scan_out   => bsov(bcfg_offset+103 to bcfg_offset+106),
            q      => bcfg_q(103 to 106),
            q_b    => bcfg_q_b(103 to 106)  );
bcfg_spare_latch: tri_slat_scan
  generic map (width => 16, init => std_ulogic_vector( to_unsigned( 0, 16 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_offset+107 to bcfg_offset+122),
            scan_out   => bsov(bcfg_offset+107 to bcfg_offset+122),
            q      => bcfg_q(107 to 122),
            q_b    => bcfg_q_b(107 to 122)  );
end generate mpg_bcfg_gen;
fpga_bcfg_gen: if expand_type = 1 generate
bcfg_epn_0to15_latch: tri_rlmreg_p
  generic map (width => 16, init => bcfg_epn_0to15, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(0 to 15),
            scout   => bsov(0 to 15),
            din     => bcfg_q(0 to 15),
            dout    => bcfg_q(0 to 15)  );
bcfg_epn_16to31_latch: tri_rlmreg_p
  generic map (width => 16, init => bcfg_epn_16to31, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(16 to 31),
            scout   => bsov(16 to 31),
            din     => bcfg_q(16 to 31),
            dout    => bcfg_q(16 to 31)  );
bcfg_epn_32to47_latch: tri_rlmreg_p
  generic map (width => 16, init => bcfg_epn_32to47, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(32 to 47),
            scout   => bsov(32 to 47),
            din     => bcfg_q(32 to 47),
            dout    => bcfg_q(32 to 47)  );
bcfg_epn_48to51_latch: tri_rlmreg_p
  generic map (width => 4, init => bcfg_epn_48to51, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(48 to 51),
            scout   => bsov(48 to 51),
            din     => bcfg_q(48 to 51),
            dout    => bcfg_q(48 to 51)  );
bcfg_rpn_22to31_latch: tri_rlmreg_p
  generic map (width => 10, init => bcfg_rpn_22to31, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(52 to 61),
            scout   => bsov(52 to 61),
            din     => bcfg_q(52 to 61),
            dout    => bcfg_q(52 to 61)  );
bcfg_rpn_32to47_latch: tri_rlmreg_p
  generic map (width => 16, init => bcfg_rpn_32to47, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(62 to 77),
            scout   => bsov(62 to 77),
            din     => bcfg_q(62 to 77),
            dout    => bcfg_q(62 to 77)  );
bcfg_rpn_48to51_latch: tri_rlmreg_p
  generic map (width => 4, init => bcfg_rpn_48to51, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(78 to 81),
            scout   => bsov(78 to 81),
            din     => bcfg_q(78 to 81),
            dout    => bcfg_q(78 to 81)  );
bcfg_attr_latch: tri_rlmreg_p
  generic map (width => 5, init => bcfg_attr, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(82 to 86),
            scout   => bsov(82 to 86),
            din     => bcfg_q(82 to 86),
            dout    => bcfg_q(82 to 86)  );
bcfg_rpn2_32to47_latch: tri_rlmreg_p
  generic map (width => 16, init => bcfg_rpn2_32to47, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(87 to 102),
            scout   => bsov(87 to 102),
            din     => bcfg_q(87 to 102),
            dout    => bcfg_q(87 to 102)  );
bcfg_rpn2_48to51_latch: tri_rlmreg_p
  generic map (width => 4, init => bcfg_rpn2_48to51, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(103 to 106),
            scout   => bsov(103 to 106),
            din     => bcfg_q(103 to 106),
            dout    => bcfg_q(103 to 106)  );
bcfg_spare_latch: tri_rlmreg_p
  generic map (width => 16, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(107 to 122),
            scout   => bsov(107 to 122),
            din     => bcfg_q(107 to 122),
            dout    => bcfg_q(107 to 122)  );
end generate fpga_bcfg_gen;
--------------------------------------------------
-- thold/sg latches
--------------------------------------------------
perv_2to1_reg: tri_plat
  generic map (width => 4, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => pc_func_sl_thold_2,
            din(1)      => pc_func_slp_sl_thold_2,
            din(2)      => pc_cfg_slp_sl_thold_2,
            din(3)      => pc_sg_2,
            q(0)        => pc_func_sl_thold_1,
            q(1)        => pc_func_slp_sl_thold_1,
            q(2)        => pc_cfg_slp_sl_thold_1,
            q(3)        => pc_sg_1);
perv_1to0_reg: tri_plat
  generic map (width => 4, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => pc_func_sl_thold_1,
            din(1)      => pc_func_slp_sl_thold_1,
            din(2)      => pc_cfg_slp_sl_thold_1,
            din(3)      => pc_sg_1,
            q(0)        => pc_func_sl_thold_0,
            q(1)        => pc_func_slp_sl_thold_0,
            q(2)        => pc_cfg_slp_sl_thold_0,
            q(3)        => pc_sg_0);
perv_lcbor_func_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_sl_thold_0,
            sg          => pc_sg_0,
            act_dis     => lcb_act_dis_dc,
            forcee => pc_func_sl_force,
            thold_b     => pc_func_sl_thold_0_b);
perv_lcbor_func_slp_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_slp_sl_thold_0,
            sg          => pc_sg_0,
            act_dis     => lcb_act_dis_dc,
            forcee => pc_func_slp_sl_force,
            thold_b     => pc_func_slp_sl_thold_0_b);
mpg_bcfg_lcb_gen: if expand_type /= 1 generate
--------------------------------------------------
-- local clock buffer for boot config
--------------------------------------------------
bcfg_lcb: tri_lcbs
  generic map (expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            nclk        => nclk,
            forcee => pc_cfg_slp_sl_force,
            thold_b     => pc_cfg_slp_sl_thold_0_b,
            dclk        => lcb_dclk,
            lclk        => lcb_lclk  );
-- these terms in the absence of another lcbor component
--  that drives the thold_b and force into the bcfg_lcb for slat's
pc_cfg_slp_sl_thold_0_b  <=  NOT pc_cfg_slp_sl_thold_0;
pc_cfg_slp_sl_force    <=  pc_sg_0;
end generate mpg_bcfg_lcb_gen;
fpga_bcfg_lcb_gen: if expand_type = 1 generate
perv_lcbor_cfg_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_cfg_slp_sl_thold_0,
            sg          => pc_sg_0,
            act_dis     => lcb_act_dis_dc,
            forcee => pc_cfg_slp_sl_force,
            thold_b     => pc_cfg_slp_sl_thold_0_b);
end generate fpga_bcfg_lcb_gen;
-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
siv_0(0 TO scan_right_0) <=  sov_0(1 to scan_right_0) & ac_func_scan_in(0);
func_si_cam_int  <=  sov_0(0);
ac_func_scan_out(0) <=  func_so_cam_int;
siv_1(0 TO scan_right_1) <=  sov_1(1 to scan_right_1) & ac_func_scan_in(1);
ac_func_scan_out(1) <=  sov_1(0);
bsiv(0 TO boot_scan_right) <=  bsov(1 to boot_scan_right) & ac_ccfg_scan_in;
ac_ccfg_scan_out  <=  bsov(0);
END XUQ_LSU_DERAT;
