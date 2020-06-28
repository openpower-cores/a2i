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
use ieee.numeric_std.all;
library ibm;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity iuq_ic_ierat is
  generic(thdid_width        : integer := 4;
            ttype_width        : integer := 6;
            state_width        : integer := 4;
            pid_width          : integer := 14;
            pid_width_erat     : integer := 8;
            extclass_width     : integer := 2;
            tlbsel_width       : integer := 2;
            epn_width          : integer := 52;
            vpn_width          : integer := 61;
            rpn_width          : integer := 30;  
            ws_width           : integer := 2;
            rs_is_width        : integer := 9;
            ra_entry_width     : integer := 4;
            rs_data_width      : integer := 64;  
            data_out_width     : integer := 64;  
            error_width        : integer := 3;
            cam_data_width     : natural := 84;    
            array_data_width   : natural := 68;  
            num_entry          : natural := 16; 
            num_entry_log2     : natural := 4; 
            por_seq_width      : integer := 3;
            watermark_width    : integer := 4;
            eptr_width         : integer := 4;
            lru_width          : integer := 15;
            bcfg_width         : integer := 123;
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
     pc_iu_init_reset           : in std_ulogic;

tc_ccflush_dc             : in std_ulogic;
tc_scan_dis_dc_b          : in std_ulogic;
tc_scan_diag_dc           : in std_ulogic;
tc_lbist_en_dc            : in std_ulogic;
an_ac_atpg_en_dc          : in std_ulogic;
an_ac_grffence_en_dc      : in std_ulogic;
lcb_d_mode_dc              : in std_ulogic;
lcb_clkoff_dc_b            : in std_ulogic;
lcb_act_dis_dc             : in std_ulogic;
lcb_mpw1_dc_b              : in std_ulogic_vector(0 to 1);
lcb_mpw2_dc_b              : in std_ulogic;
lcb_delay_lclkr_dc         : in std_ulogic_vector(0 to 1);
pc_iu_func_sl_thold_2      : in std_ulogic;
pc_iu_func_slp_sl_thold_2  : in std_ulogic;
pc_iu_func_slp_nsl_thold_2 : in std_ulogic;
pc_iu_cfg_slp_sl_thold_2   : in std_ulogic;
pc_iu_regf_slp_sl_thold_2  : in std_ulogic;
pc_iu_time_sl_thold_2      : in std_ulogic;
pc_iu_sg_2                 : in std_ulogic;
pc_iu_fce_2                : in std_ulogic;
cam_clkoff_b               : in std_ulogic;
cam_act_dis                : in std_ulogic;
cam_d_mode                 : in std_ulogic;
cam_delay_lclkr            : in std_ulogic_vector(0 to 4);
cam_mpw1_b                 : in std_ulogic_vector(0 to 4);
cam_mpw2_b                 : in std_ulogic;
ac_func_scan_in          : in   std_ulogic_vector(0 to 1);
ac_func_scan_out         : out  std_ulogic_vector(0 to 1);
ac_ccfg_scan_in          : in   std_ulogic;
ac_ccfg_scan_out         : out  std_ulogic;
func_scan_in_cam          : in   std_ulogic;
func_scan_out_cam         : out  std_ulogic;
time_scan_in               : in std_ulogic;
time_scan_out              : out std_ulogic;
regf_scan_in             : in   std_ulogic_vector(0 to 4);
regf_scan_out            : out  std_ulogic_vector(0 to 4);
iu_ierat_iu0_val        : in std_ulogic;
iu_ierat_iu0_thdid      : in std_ulogic_vector(0 to thdid_width-1);
iu_ierat_iu0_ifar       : in std_ulogic_vector(0 to 51);
iu_ierat_iu0_flush      : in std_ulogic_vector(0 to thdid_width-1);
iu_ierat_iu1_flush      : in std_ulogic_vector(0 to thdid_width-1);
iu_ierat_iu1_back_inv   : in std_ulogic;
iu_ierat_ium1_back_inv  : in std_ulogic;
spr_ic_clockgate_dis    : in std_ulogic;
ierat_iu_iu2_rpn           : out std_ulogic_vector(22 to 51);
ierat_iu_iu2_wimge         : out std_ulogic_vector(0 to 4);
ierat_iu_iu2_u             : out std_ulogic_vector(0 to 3);
ierat_iu_iu2_error         : out std_ulogic_vector(0 to 2);
ierat_iu_iu2_miss          : out std_ulogic;
ierat_iu_iu2_multihit      : out std_ulogic;
ierat_iu_iu2_isi           : out std_ulogic;
xu_iu_rf1_val           : in std_ulogic_vector(0 to thdid_width-1);
xu_iu_rf1_is_eratre     : in std_ulogic;
xu_iu_rf1_is_eratwe     : in std_ulogic;
xu_iu_rf1_is_eratsx     : in std_ulogic;
xu_iu_rf1_is_eratilx    : in std_ulogic;
xu_iu_ex1_is_isync      : in std_ulogic;
xu_iu_ex1_is_csync      : in std_ulogic;
xu_iu_rf1_ws            : in std_ulogic_vector(0 to ws_width-1);
xu_iu_rf1_t             : in std_ulogic_vector(0 to 2);
xu_iu_ex1_rs_is         : in std_ulogic_vector(0 to rs_is_width-1);
xu_iu_ex1_ra_entry      : in std_ulogic_vector(0 to ra_entry_width-1);
xu_iu_ex1_rb            : in std_ulogic_vector(64-rs_data_width to 51);
xu_iu_flush             : in std_ulogic_vector(0 to thdid_width-1);
xu_rf1_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex1_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex2_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex3_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex4_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex5_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_iu_ex4_rs_data       : in std_ulogic_vector(64-rs_data_width to 63);
xu_iu_msr_hv            : in std_ulogic_vector(0 to thdid_width-1);
xu_iu_msr_pr            : in std_ulogic_vector(0 to thdid_width-1);
xu_iu_msr_is            : in std_ulogic_vector(0 to thdid_width-1);
xu_iu_msr_cm            : in std_ulogic_vector(0 to thdid_width-1);
xu_iu_hid_mmu_mode      : in std_ulogic;
xu_iu_spr_ccr2_ifrat       : in std_ulogic;
xu_iu_spr_ccr2_ifratsc     : in std_ulogic_vector(0 to 8);
xu_iu_xucr4_mmu_mchk       : in std_ulogic;
ierat_iu_hold_req          : out std_ulogic_vector(0 to thdid_width-1);
ierat_iu_iu2_flush_req     : out std_ulogic_vector(0 to thdid_width-1);
iu_xu_ex4_data             : out std_ulogic_vector(64-data_out_width to 63);
iu_xu_ierat_ex3_par_err    : out std_ulogic_vector(0 to thdid_width-1);
iu_xu_ierat_ex4_par_err    : out std_ulogic_vector(0 to thdid_width-1);
iu_xu_ierat_ex2_flush_req  : out std_ulogic_vector(0 to thdid_width-1);
iu_mm_ierat_req            : out std_ulogic;
iu_mm_ierat_thdid          : out std_ulogic_vector(0 to thdid_width-1);
iu_mm_ierat_state          : out std_ulogic_vector(0 to state_width-1);
iu_mm_ierat_tid            : out std_ulogic_vector(0 to pid_width-1);
iu_mm_ierat_flush          : out std_ulogic_vector(0 to thdid_width-1);
mm_iu_ierat_rel_val        : in std_ulogic_vector(0 to 4);
mm_iu_ierat_rel_data       : in std_ulogic_vector(0 to 131);
mm_iu_ierat_pid0           : in std_ulogic_vector(0 to pid_width-1);
mm_iu_ierat_pid1           : in std_ulogic_vector(0 to pid_width-1);
mm_iu_ierat_pid2           : in std_ulogic_vector(0 to pid_width-1);
mm_iu_ierat_pid3           : in std_ulogic_vector(0 to pid_width-1);
mm_iu_ierat_mmucr0_0         : in std_ulogic_vector(0 to 19);
mm_iu_ierat_mmucr0_1         : in std_ulogic_vector(0 to 19);
mm_iu_ierat_mmucr0_2         : in std_ulogic_vector(0 to 19);
mm_iu_ierat_mmucr0_3         : in std_ulogic_vector(0 to 19);
iu_mm_ierat_mmucr0          : out std_ulogic_vector(0 to 17);
iu_mm_ierat_mmucr0_we       : out std_ulogic_vector(0 to 3);
mm_iu_ierat_mmucr1          : in std_ulogic_vector(0 to 8);
iu_mm_ierat_mmucr1          : out std_ulogic_vector(0 to 3);
iu_mm_ierat_mmucr1_we       : out std_ulogic;
mm_iu_ierat_snoop_coming   : in std_ulogic;
mm_iu_ierat_snoop_val      : in std_ulogic;
mm_iu_ierat_snoop_attr     : in std_ulogic_vector(0 to 25);
mm_iu_ierat_snoop_vpn      : in std_ulogic_vector(52-epn_width to 51);
iu_mm_ierat_snoop_ack      : out std_ulogic;
pc_iu_trace_bus_enable     : in std_ulogic;
ierat_iu_debug_group0      : out std_ulogic_vector(0 to 87);
ierat_iu_debug_group1      : out std_ulogic_vector(0 to 87);
ierat_iu_debug_group2      : out std_ulogic_vector(0 to 87);
ierat_iu_debug_group3      : out std_ulogic_vector(0 to 87)

);
end iuq_ic_ierat;
ARCHITECTURE IUQ_IC_IERAT
          OF IUQ_IC_IERAT
          IS
SIGNAL CAM_MASK_BITS_PT                  : STD_ULOGIC_VECTOR(1 TO 19)  := 
(OTHERS=> 'U');
SIGNAL IU1_FIRST_HIT_ENTRY_PT            : STD_ULOGIC_VECTOR(1 TO 15)  := 
(OTHERS=> 'U');
SIGNAL IU1_MULTIHIT_B_PT                 : STD_ULOGIC_VECTOR(1 TO 16)  := 
(OTHERS=> 'U');
SIGNAL LRU_RMT_VEC_PT                    : STD_ULOGIC_VECTOR(1 TO 17)  := 
(OTHERS=> 'U');
SIGNAL LRU_SET_RESET_VEC_PT              : STD_ULOGIC_VECTOR(1 TO 80)  := 
(OTHERS=> 'U');
SIGNAL LRU_WATERMARK_MASK_PT             : STD_ULOGIC_VECTOR(1 TO 15)  := 
(OTHERS=> 'U');
SIGNAL LRU_WAY_ENCODE_PT                 : STD_ULOGIC_VECTOR(1 TO 15)  := 
(OTHERS=> 'U');
component tri_cam_16x143_1r1w1c
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
   regfile_scan_in                :  in   std_ulogic_vector(0 to 4);  
   regfile_scan_out               :  out  std_ulogic_vector(0 to 4);
   time_scan_in                   :  in   std_ulogic;
   time_scan_out                  :  out  std_ulogic;


   rd_val                         :  in   std_ulogic;
   rd_val_late                    :  in   std_ulogic;
   rw_entry                       :  in   std_ulogic_vector(0 to 3);

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
   cam_hit_entry                  :  out  std_ulogic_vector(0 to 3);
   entry_match                    :  out  std_ulogic_vector(0 to 15);
   entry_valid                    :  out  std_ulogic_vector(0 to 15);
   rd_cam_data                    :  out  std_ulogic_vector(0 to cam_data_width-1);

  bypass_mux_enab_np1   :  in  std_ulogic;		   
  bypass_attr_np1       :  in  std_ulogic_vector(0 to 20); 
  attr_np2	        :  out std_ulogic_vector(0 to 20);
  rpn_np2	        :  out std_ulogic_vector(22 to 51)

  );
END component;
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
constant Por_Wr_Entry_Num1   : std_ulogic_vector(0 to num_entry_log2-1) := "1110";
constant Por_Wr_Entry_Num2   : std_ulogic_vector(0 to num_entry_log2-1) := "1111";
constant Por_Wr_Cam_Data1   : std_ulogic_vector(0 to 83) := "0000000000000000000000000000000011111111111111111111" &
                                   '0' & "001" & '1' & "1111" & "00" & "00" & "00" & "00000000" & "11110000" & '0';
constant Por_Wr_Cam_Data2   : std_ulogic_vector(0 to 83) := "0000000000000000000000000000000000000000000000000000" &
                                   '0' & "001" & '1' & "1111" & "00" & "10" & "00" & "00000000" & "11110000" & '0';
constant Por_Wr_Array_Data1 : std_ulogic_vector(0 to 67) := "111111111111111111111111111111" &
                                   "00" & "0000" & "0000" & "01010" & "01" & "00" & "01" & "0000001000" & "0000000";
constant Por_Wr_Array_Data2 : std_ulogic_vector(0 to 67) := "000000000000000000000000000000" &
                                   "00" & "0000" & "0000" & "01010" & "01" & "00" & "01" & "0000001010" & "0000000";
constant ex1_valid_offset           : natural := 0;
constant ex1_ttype_offset           : natural := ex1_valid_offset + thdid_width;
constant ex1_ws_offset              : natural := ex1_ttype_offset + ttype_width+1;
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
constant ex3_extclass_offset        : natural := ex3_pid_offset + pid_width;
constant ex3_tlbsel_offset          : natural := ex3_extclass_offset + extclass_width;
constant ex3_eratsx_data_offset     : natural := ex3_tlbsel_offset + tlbsel_width;
constant ex4_valid_offset           : natural := ex3_eratsx_data_offset + 2 + num_entry_log2;
constant ex4_ttype_offset           : natural := ex4_valid_offset + thdid_width;
constant ex4_ws_offset              : natural := ex4_ttype_offset + ttype_width;
constant ex4_rs_is_offset           : natural := ex4_ws_offset + ws_width;
constant ex4_ra_entry_offset        : natural := ex4_rs_is_offset + rs_is_width;
constant ex4_state_offset           : natural := ex4_ra_entry_offset + ra_entry_width;
constant ex4_pid_offset             : natural := ex4_state_offset + state_width;
constant ex4_extclass_offset        : natural := ex4_pid_offset + pid_width;
constant ex4_tlbsel_offset          : natural := ex4_extclass_offset + extclass_width;
constant ex4_data_out_offset        : natural := ex4_tlbsel_offset + tlbsel_width;
constant ex5_valid_offset           : natural := ex4_data_out_offset + data_out_width;
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
constant iu1_flush_enab_offset      : natural := ex6_data_in_offset + rs_data_width;
constant iu2_n_flush_req_offset     : natural := iu1_flush_enab_offset + 1;
constant hold_req_offset            : natural := iu2_n_flush_req_offset + thdid_width;
constant tlb_miss_offset            : natural := hold_req_offset + thdid_width;
constant tlb_req_inprogress_offset  : natural := tlb_miss_offset + thdid_width;
constant iu1_valid_offset           : natural := tlb_req_inprogress_offset + thdid_width;
constant iu1_state_offset           : natural := iu1_valid_offset + thdid_width;
constant iu1_pid_offset             : natural := iu1_state_offset + state_width;
constant iu2_valid_offset           : natural := iu1_pid_offset + pid_width;
constant iu2_state_offset           : natural := iu2_valid_offset + thdid_width;
constant iu2_pid_offset             : natural := iu2_state_offset + state_width;
constant iu2_miss_offset           : natural := iu2_pid_offset + pid_width;
constant iu2_multihit_offset       : natural := iu2_miss_offset + 2;
constant iu2_parerr_offset         : natural := iu2_multihit_offset + 2;
constant iu2_isi_offset            : natural := iu2_parerr_offset + 2;
constant iu2_tlbreq_offset          : natural := iu2_isi_offset + 6;
constant iu2_multihit_b_pt_offset   : natural := iu2_tlbreq_offset + 1;
constant iu2_first_hit_entry_pt_offset  : natural := iu2_multihit_b_pt_offset + num_entry;
constant iu2_cam_cmp_data_offset    : natural := iu2_first_hit_entry_pt_offset + num_entry-1;
constant iu2_array_cmp_data_offset  : natural := iu2_cam_cmp_data_offset + cam_data_width;
constant ex4_rd_cam_data_offset     : natural := iu2_array_cmp_data_offset + array_data_width;
constant ex4_rd_array_data_offset   : natural := ex4_rd_cam_data_offset + cam_data_width;
constant ex3_parerr_offset          : natural := ex4_rd_array_data_offset + array_data_width;
constant ex4_parerr_offset          : natural := ex3_parerr_offset + thdid_width + 1;
constant ex4_ieen_offset            : natural := ex4_parerr_offset + thdid_width + 2;
constant ex5_ieen_offset            : natural := ex4_ieen_offset + thdid_width + num_entry_log2;
constant ex6_ieen_offset            : natural := ex5_ieen_offset + thdid_width + num_entry_log2;
constant mmucr1_offset              : natural := ex6_ieen_offset + 1 + num_entry_log2;
constant rpn_holdreg0_offset        : natural := mmucr1_offset + 9;
constant rpn_holdreg1_offset        : natural := rpn_holdreg0_offset + 64;
constant rpn_holdreg2_offset        : natural := rpn_holdreg1_offset + 64;
constant rpn_holdreg3_offset        : natural := rpn_holdreg2_offset + 64;
constant entry_valid_offset         : natural := rpn_holdreg3_offset + 64;
constant entry_match_offset         : natural := entry_valid_offset + 16;
constant watermark_offset           : natural := entry_match_offset + 16;
constant eptr_offset                : natural := watermark_offset + watermark_width;
constant lru_offset                 : natural := eptr_offset + eptr_width;
constant lru_update_event_offset    : natural := lru_offset + lru_width;
constant lru_debug_offset           : natural := lru_update_event_offset + 9;
constant scan_right_0               : natural := lru_debug_offset + 24 -1;
constant snoop_val_offset           : natural := 0;
constant spare_a_offset             : natural := snoop_val_offset + 3;
constant snoop_attr_offset          : natural := spare_a_offset + 16;
constant snoop_addr_offset          : natural := snoop_attr_offset + 26;
constant spare_b_offset             : natural := snoop_addr_offset + epn_width;
constant por_seq_offset             : natural := spare_b_offset + 16;
constant tlb_rel_val_offset           : natural := por_seq_offset + 3;
constant tlb_rel_data_offset          : natural := tlb_rel_val_offset + thdid_width + 1;
constant iu_mm_ierat_flush_offset     : natural := tlb_rel_data_offset + 132;
constant iu_xu_ierat_ex2_flush_offset : natural := iu_mm_ierat_flush_offset + thdid_width;
constant ccr2_frat_paranoia_offset    : natural := iu_xu_ierat_ex2_flush_offset + thdid_width;
constant ccr2_notlb_offset            : natural := ccr2_frat_paranoia_offset + 10;
constant xucr4_mmu_mchk_offset        : natural := ccr2_notlb_offset + 1;
constant mchk_flash_inv_offset        : natural := xucr4_mmu_mchk_offset + 1;
constant ex7_valid_offset           : natural := mchk_flash_inv_offset + 4;
constant ex7_ttype_offset           : natural := ex7_valid_offset + thdid_width;
constant ex7_tlbsel_offset          : natural := ex7_ttype_offset + ttype_width;
constant iu1_debug_offset         : natural := ex7_tlbsel_offset + 2;
constant iu2_debug_offset         : natural := iu1_debug_offset + 11;
constant iu1_stg_act_offset            : natural := iu2_debug_offset + 17;
constant iu2_stg_act_offset            : natural := iu1_stg_act_offset + 1;
constant iu3_stg_act_offset            : natural := iu2_stg_act_offset + 1;
constant iu4_stg_act_offset            : natural := iu3_stg_act_offset + 1;
constant ex1_stg_act_offset            : natural := iu4_stg_act_offset + 1;
constant ex2_stg_act_offset            : natural := ex1_stg_act_offset + 1;
constant ex3_stg_act_offset            : natural := ex2_stg_act_offset + 1;
constant ex4_stg_act_offset            : natural := ex3_stg_act_offset + 1;
constant ex5_stg_act_offset            : natural := ex4_stg_act_offset + 1;
constant ex6_stg_act_offset            : natural := ex5_stg_act_offset + 1;
constant ex7_stg_act_offset            : natural := ex6_stg_act_offset + 1;
constant tlb_rel_act_offset            : natural := ex7_stg_act_offset + 1;
constant snoop_act_offset              : natural := tlb_rel_act_offset + 1;
constant trace_bus_enable_offset       : natural := snoop_act_offset + 1;
constant an_ac_grffence_en_dc_offset   : natural := trace_bus_enable_offset + 1;
constant scan_right_1               : natural := an_ac_grffence_en_dc_offset + 1 -1;
constant bcfg_offset           : natural := 0;
constant boot_scan_right       : natural := bcfg_offset + bcfg_width - 1;
signal ex1_valid_d,    ex1_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex1_ttype_d,    ex1_ttype_q           : std_ulogic_vector(0 to ttype_width);
signal ex1_ws_d,       ex1_ws_q              : std_ulogic_vector(0 to ws_width-1);
signal ex1_rs_is_d,    ex1_rs_is_q           : std_ulogic_vector(0 to rs_is_width-1);
signal ex1_ra_entry_d, ex1_ra_entry_q        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex1_state_d,    ex1_state_q           : std_ulogic_vector(0 to state_width-1);
signal ex1_pid_d,      ex1_pid_q             : std_ulogic_vector(0 to pid_width-1);
signal ex1_extclass_d, ex1_extclass_q        : std_ulogic_vector(0 to extclass_width-1);
signal ex1_tlbsel_d,   ex1_tlbsel_q          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex2_valid_d,    ex2_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex2_ttype_d,    ex2_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex2_ws_d,       ex2_ws_q              : std_ulogic_vector(0 to ws_width-1);
signal ex2_rs_is_d,    ex2_rs_is_q           : std_ulogic_vector(0 to rs_is_width-1);
signal ex2_ra_entry_d, ex2_ra_entry_q        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex2_state_d,    ex2_state_q           : std_ulogic_vector(0 to state_width-1);
signal ex2_pid_d,      ex2_pid_q             : std_ulogic_vector(0 to pid_width-1);
signal ex2_extclass_d, ex2_extclass_q        : std_ulogic_vector(0 to extclass_width-1);
signal ex2_tlbsel_d,   ex2_tlbsel_q          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex3_valid_d,    ex3_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex3_ttype_d,    ex3_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex3_ws_d,       ex3_ws_q              : std_ulogic_vector(0 to ws_width-1);
signal ex3_rs_is_d,    ex3_rs_is_q           : std_ulogic_vector(0 to rs_is_width-1);
signal ex3_ra_entry_d, ex3_ra_entry_q        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex3_state_d,    ex3_state_q           : std_ulogic_vector(0 to state_width-1);
signal ex3_pid_d,      ex3_pid_q             : std_ulogic_vector(0 to pid_width-1);
signal ex3_extclass_d, ex3_extclass_q        : std_ulogic_vector(0 to extclass_width-1);
signal ex3_tlbsel_d,   ex3_tlbsel_q          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex3_eratsx_data_d, ex3_eratsx_data_q  : std_ulogic_vector(0 to 2+num_entry_log2-1);
signal ex4_valid_d,    ex4_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex4_ttype_d,    ex4_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex4_ws_d,       ex4_ws_q              : std_ulogic_vector(0 to ws_width-1);
signal ex4_rs_is_d,    ex4_rs_is_q           : std_ulogic_vector(0 to rs_is_width-1);
signal ex4_ra_entry_d, ex4_ra_entry_q        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex4_state_d,    ex4_state_q           : std_ulogic_vector(0 to state_width-1);
signal ex4_pid_d,      ex4_pid_q             : std_ulogic_vector(0 to pid_width-1);
signal ex4_extclass_d, ex4_extclass_q        : std_ulogic_vector(0 to extclass_width-1);
signal ex4_tlbsel_d,   ex4_tlbsel_q          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex4_data_out_d, ex4_data_out_q        : std_ulogic_vector(64-data_out_width to 63);
signal ex5_valid_d,    ex5_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex5_ttype_d,    ex5_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex5_ws_d,       ex5_ws_q              : std_ulogic_vector(0 to ws_width-1);
signal ex5_rs_is_d,    ex5_rs_is_q           : std_ulogic_vector(0 to rs_is_width-1);
signal ex5_ra_entry_d, ex5_ra_entry_q        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex5_state_d,    ex5_state_q           : std_ulogic_vector(0 to state_width-1);
signal ex5_pid_d,      ex5_pid_q             : std_ulogic_vector(0 to pid_width-1);
signal ex5_extclass_d, ex5_extclass_q        : std_ulogic_vector(0 to extclass_width-1);
signal ex5_tlbsel_d,   ex5_tlbsel_q          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex5_data_in_d, ex5_data_in_q          : std_ulogic_vector(64-rs_data_width to 63);
signal ex6_valid_d,    ex6_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex6_ttype_d,    ex6_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex6_ws_d,       ex6_ws_q              : std_ulogic_vector(0 to ws_width-1);
signal ex6_rs_is_d,    ex6_rs_is_q           : std_ulogic_vector(0 to rs_is_width-1);
signal ex6_ra_entry_d, ex6_ra_entry_q        : std_ulogic_vector(0 to ra_entry_width-1);
signal ex6_state_d,    ex6_state_q           : std_ulogic_vector(0 to state_width-1);
signal ex6_pid_d,      ex6_pid_q             : std_ulogic_vector(0 to pid_width-1);
signal ex6_extclass_d, ex6_extclass_q        : std_ulogic_vector(0 to extclass_width-1);
signal ex6_tlbsel_d,   ex6_tlbsel_q          : std_ulogic_vector(0 to tlbsel_width-1);
signal ex6_data_in_d, ex6_data_in_q          : std_ulogic_vector(64-rs_data_width to 63);
signal ex7_valid_d,    ex7_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex7_ttype_d,    ex7_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex7_tlbsel_d,   ex7_tlbsel_q          : std_ulogic_vector(0 to tlbsel_width-1);
signal iu1_valid_d, iu1_valid_q         : std_ulogic_vector(0 to thdid_width-1);
signal iu1_state_d, iu1_state_q         : std_ulogic_vector(0 to state_width-1);
signal iu1_pid_d,   iu1_pid_q           : std_ulogic_vector(0 to pid_width-1);
signal iu2_valid_d, iu2_valid_q         : std_ulogic_vector(0 to thdid_width-1);
signal iu2_state_d, iu2_state_q         : std_ulogic_vector(0 to state_width-1);
signal iu2_pid_d,   iu2_pid_q           : std_ulogic_vector(0 to pid_width-1);
signal iu1_flush_enab_d, iu1_flush_enab_q : std_ulogic;
signal iu2_n_flush_req_d, iu2_n_flush_req_q   : std_ulogic_vector(0 to thdid_width-1);
signal hold_req_d,        hold_req_q          : std_ulogic_vector(0 to thdid_width-1);
signal tlb_miss_d,        tlb_miss_q          : std_ulogic_vector(0 to thdid_width-1);
signal tlb_req_inprogress_d, tlb_req_inprogress_q : std_ulogic_vector(0 to thdid_width-1);
signal iu2_tlbreq_d, iu2_tlbreq_q       : std_ulogic;
signal iu2_miss_d, iu2_miss_q           : std_ulogic_vector(0 to 1);
signal iu2_multihit_d, iu2_multihit_q   : std_ulogic_vector(0 to 1);
signal iu2_parerr_d, iu2_parerr_q       : std_ulogic_vector(0 to 1);
signal iu2_isi_d, iu2_isi_q             : std_ulogic_vector(0 to 5);
signal iu1_debug_d, iu1_debug_q         : std_ulogic_vector(0 to 10);
signal iu2_debug_d, iu2_debug_q         : std_ulogic_vector(0 to 16);
signal iu2_multihit_b_pt_d, iu2_multihit_b_pt_q         : std_ulogic_vector(1 to num_entry);
signal iu2_first_hit_entry_pt_d, iu2_first_hit_entry_pt_q  : std_ulogic_vector(1 to num_entry-1);
signal iu2_cam_cmp_data_d, iu2_cam_cmp_data_q         : std_ulogic_vector(0 to cam_data_width-1);
signal iu2_array_cmp_data_d, iu2_array_cmp_data_q         : std_ulogic_vector(0 to array_data_width-1);
signal ex4_rd_cam_data_d, ex4_rd_cam_data_q         : std_ulogic_vector(0 to cam_data_width-1);
signal ex4_rd_array_data_d, ex4_rd_array_data_q         : std_ulogic_vector(0 to array_data_width-1);
signal por_seq_d, por_seq_q    : std_ulogic_vector(0 to 2);
signal ex3_parerr_d, ex3_parerr_q   : std_ulogic_vector(0 to thdid_width);
signal ex4_parerr_d, ex4_parerr_q   : std_ulogic_vector(0 to thdid_width+1);
signal ex4_ieen_d, ex4_ieen_q       : std_ulogic_vector(0 to thdid_width+num_entry_log2-1);
signal ex5_ieen_d, ex5_ieen_q       : std_ulogic_vector(0 to thdid_width+num_entry_log2-1);
signal ex6_ieen_d, ex6_ieen_q       : std_ulogic_vector(0 to num_entry_log2);
signal mmucr1_d, mmucr1_q       : std_ulogic_vector(0 to 8);
signal rpn_holdreg0_d, rpn_holdreg0_q    : std_ulogic_vector(0 to 63);
signal rpn_holdreg1_d, rpn_holdreg1_q    : std_ulogic_vector(0 to 63);
signal rpn_holdreg2_d, rpn_holdreg2_q    : std_ulogic_vector(0 to 63);
signal rpn_holdreg3_d, rpn_holdreg3_q    : std_ulogic_vector(0 to 63);
signal watermark_d, watermark_q    : std_ulogic_vector(0 to watermark_width-1);
signal eptr_d,      eptr_q         : std_ulogic_vector(0 to eptr_width-1);
signal lru_d,       lru_q          : std_ulogic_vector(1 to lru_width);
signal lru_update_event_d, lru_update_event_q  : std_ulogic_vector(0 to 8);
signal lru_debug_d, lru_debug_q  : std_ulogic_vector(0 to 23);
signal snoop_val_d,  snoop_val_q       : std_ulogic_vector(0 to 2);
signal snoop_attr_d, snoop_attr_q      : std_ulogic_vector(0 to 25);
signal snoop_addr_d, snoop_addr_q      : std_ulogic_vector(52-epn_width to 51);
signal tlb_rel_val_d, tlb_rel_val_q   : std_ulogic_vector(0 to 4);
signal tlb_rel_data_d, tlb_rel_data_q : std_ulogic_vector(0 to 131);
signal iu_mm_ierat_flush_d, iu_mm_ierat_flush_q : std_ulogic_vector(0 to thdid_width-1);
signal iu_xu_ierat_ex2_flush_d, iu_xu_ierat_ex2_flush_q : std_ulogic_vector(0 to thdid_width-1);
signal ccr2_frat_paranoia_d, ccr2_frat_paranoia_q : std_ulogic_vector(0 to 9);
signal ccr2_notlb_q, xucr4_mmu_mchk_q     : std_ulogic;
signal mchk_flash_inv_d, mchk_flash_inv_q    : std_ulogic_vector(0 to 3);
signal mchk_flash_inv_enab  : std_ulogic;
signal spare_q : std_ulogic_vector(0 to 31);
signal bcfg_q, bcfg_q_b : std_ulogic_vector(0 to bcfg_width-1);
signal iu2_isi_sig        : std_ulogic;
signal iu2_miss_sig       : std_ulogic;
signal iu2_parerr_sig     : std_ulogic;
signal iu2_multihit_sig   : std_ulogic;
signal iu1_multihit       : std_ulogic;
signal iu1_multihit_b     : std_ulogic;
signal iu1_first_hit_entry  :  std_ulogic_vector(0 to num_entry_log2-1);
signal iu2_first_hit_entry  :  std_ulogic_vector(0 to num_entry_log2-1);
signal iu2_multihit_enab     : std_ulogic;
signal por_wr_cam_val           :  std_ulogic_vector(0 to 1);
signal por_wr_array_val         :  std_ulogic_vector(0 to 1);
signal por_wr_cam_data           :  std_ulogic_vector(0 to cam_data_width-1);
signal por_wr_array_data         :  std_ulogic_vector(0 to array_data_width-1);
signal por_wr_entry           :  std_ulogic_vector(0 to num_entry_log2-1);
signal por_hold_req             : std_ulogic_vector(0 to thdid_width-1);
signal lru_way_encode    : std_ulogic_vector(0 to num_entry_log2-1);
signal lru_rmt_vec     : std_ulogic_vector(0 to lru_width);
signal lru_reset_vec, lru_set_vec    : std_ulogic_vector(1 to lru_width);
signal lru_op_vec, lru_vp_vec    : std_ulogic_vector(1 to lru_width);
signal lru_eff    : std_ulogic_vector(1 to lru_width);
signal lru_watermark_mask : std_ulogic_vector(0 to lru_width);
signal entry_valid_watermarked : std_ulogic_vector(0 to lru_width);
signal eptr_p1    : std_ulogic_vector(0 to eptr_width-1);
signal ex1_ieratre, ex1_ieratwe, ex1_ieratsx        : std_ulogic;
signal ex3_parerr_enab    : std_ulogic;
signal ex4_parerr_enab    : std_ulogic;
signal ex3_ieratwe, ex4_ieratwe, ex5_ieratwe, ex6_ieratwe, ex7_ieratwe  : std_ulogic;
signal ex6_ieratwe_ws3    : std_ulogic;
signal iu2_cmp_data_calc_par       :  std_ulogic_vector(50 to 67);
-- synopsys translate_off
-- synopsys translate_on
signal iu2_cmp_data_parerr_epn         :  std_ulogic;
signal iu2_cmp_data_parerr_rpn         :  std_ulogic;
signal ex4_rd_data_calc_par        :  std_ulogic_vector(50 to 67);
signal ex4_rd_data_parerr_epn          :  std_ulogic;
signal ex4_rd_data_parerr_rpn          :  std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
signal unused_dc  :  std_ulogic_vector(0 to 29);
-- synopsys translate_off
-- synopsys translate_on
signal mmucr0_gs_vec  : std_ulogic_vector(0 to thdid_width-1);
signal mmucr0_ts_vec  : std_ulogic_vector(0 to thdid_width-1);
signal tlb_rel_cmpmask  : std_ulogic_vector(0 to 3);
signal tlb_rel_xbitmask  : std_ulogic_vector(0 to 3);
signal tlb_rel_maskpar  : std_ulogic;
signal ex6_data_cmpmask  : std_ulogic_vector(0 to 3);
signal ex6_data_xbitmask  : std_ulogic_vector(0 to 3);
signal ex6_data_maskpar  : std_ulogic;
signal comp_addr_mux1     : std_ulogic_vector(0 to 51);
signal comp_addr_mux1_sel : std_ulogic;
signal lru_way_is_written  : std_ulogic;
signal lru_way_is_hit_entry  : std_ulogic;
signal ex1_pid_0,      ex1_pid_1             : std_ulogic_vector(0 to pid_width-1);
signal   rd_val                         :  std_ulogic;
signal   rw_entry                       :  std_ulogic_vector(0 to 3);
signal   wr_array_par                   :  std_ulogic_vector(51 to 67);
signal   wr_array_data_nopar            :  std_ulogic_vector(0 to array_data_width-1-10-7);
signal   wr_array_data                  :  std_ulogic_vector(0 to array_data_width-1);
signal   wr_cam_data                    :  std_ulogic_vector(0 to cam_data_width-1);
signal   wr_array_val                   :  std_ulogic_vector(0 to 1);
signal   wr_cam_val                     :  std_ulogic_vector(0 to 1);
signal   wr_val_early                   :  std_ulogic;
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
signal   array_cmp_data                 :  std_ulogic_vector(0 to array_data_width-1);
signal   rd_array_data                  :  std_ulogic_vector(0 to array_data_width-1);
signal   cam_cmp_data                   :  std_ulogic_vector(0 to cam_data_width-1);
signal   cam_hit                        :  std_ulogic;
signal   cam_hit_entry                  :  std_ulogic_vector(0 to 3);
signal   entry_match, entry_match_q     :  std_ulogic_vector(0 to 15);
signal   entry_valid, entry_valid_q     :  std_ulogic_vector(0 to 15);
signal   rd_cam_data                    :  std_ulogic_vector(0 to cam_data_width-1);
-- synopsys translate_off
-- synopsys translate_on
signal   cam_pgsize                     :  std_ulogic_vector(0 to 2);
signal   ws0_pgsize                     :  std_ulogic_vector(0 to 3);
signal bypass_mux_enab_np1 : std_ulogic;
signal bypass_attr_np1     : std_ulogic_vector(0 to 20);
signal attr_np2            : std_ulogic_vector(0 to 20);
signal rpn_np2             : std_ulogic_vector(22 to 51);
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
signal iu1_stg_act_d, iu1_stg_act_q            :std_ulogic;
signal iu2_stg_act_d, iu2_stg_act_q            :std_ulogic;
signal iu3_stg_act_d, iu3_stg_act_q            :std_ulogic;
signal iu4_stg_act_d, iu4_stg_act_q            :std_ulogic;
signal ex1_stg_act_d, ex1_stg_act_q            :std_ulogic;
signal ex2_stg_act_d, ex2_stg_act_q            :std_ulogic;
signal ex3_stg_act_d, ex3_stg_act_q            :std_ulogic;
signal ex4_stg_act_d, ex4_stg_act_q            :std_ulogic;
signal ex5_stg_act_d, ex5_stg_act_q            :std_ulogic;
signal ex6_stg_act_d, ex6_stg_act_q            :std_ulogic;
signal ex7_stg_act_d, ex7_stg_act_q            :std_ulogic;
signal iu1_cmp_data_act, iu1_grffence_act, iu1_or_iu2_grffence_act, iu2_to_iu4_grffence_act            :std_ulogic;
signal ex3_rd_data_act, ex3_data_out_act             :std_ulogic;
signal ex2_grffence_act, ex3_grffence_act             :std_ulogic;
signal an_ac_grffence_en_dc_q, trace_bus_enable_q      :std_ulogic;
signal entry_valid_act, entry_match_act  :std_ulogic;
signal not_grffence_act, notlb_grffence_act  :std_ulogic;
signal tlb_rel_act_d, tlb_rel_act_q, tlb_rel_act     :std_ulogic;
signal snoop_act_q     :std_ulogic;
signal lru_update_act, debug_grffence_act, eratsx_data_act  :std_ulogic;
signal siv_0                      : std_ulogic_vector(0 to scan_right_0);
signal sov_0                      : std_ulogic_vector(0 to scan_right_0);
signal siv_1                      : std_ulogic_vector(0 to scan_right_1);
signal sov_1                      : std_ulogic_vector(0 to scan_right_1);
signal bsiv                     : std_ulogic_vector(0 to boot_scan_right);
signal bsov                     : std_ulogic_vector(0 to boot_scan_right);
signal tiup                     : std_ulogic;
  BEGIN 

iu1_stg_act_d  <=  comp_request or spr_ic_clockgate_dis;
iu2_stg_act_d  <=  iu1_stg_act_q;
iu3_stg_act_d  <=  iu2_stg_act_q;
iu4_stg_act_d  <=  iu3_stg_act_q;
ex1_stg_act_d  <=  or_reduce(xu_iu_rf1_val) or spr_ic_clockgate_dis;
ex2_stg_act_d  <=  ex1_stg_act_q;
ex3_stg_act_d  <=  ex2_stg_act_q;
ex4_stg_act_d  <=  ex3_stg_act_q;
ex5_stg_act_d  <=  ex4_stg_act_q;
ex6_stg_act_d  <=  ex5_stg_act_q;
ex7_stg_act_d  <=  ex6_stg_act_q;
iu1_cmp_data_act  <=  iu1_stg_act_q and not(an_ac_grffence_en_dc);
iu1_grffence_act  <=  iu1_stg_act_q and not(an_ac_grffence_en_dc);
iu1_or_iu2_grffence_act  <=  (iu1_stg_act_q or iu2_stg_act_q) and not(an_ac_grffence_en_dc);
iu2_to_iu4_grffence_act  <=  (iu2_stg_act_q or iu3_stg_act_q or iu4_stg_act_q) and not(an_ac_grffence_en_dc);
ex2_grffence_act  <=  ex2_stg_act_q and not(an_ac_grffence_en_dc);
ex3_rd_data_act   <=  ex3_stg_act_q and not(an_ac_grffence_en_dc);
ex3_data_out_act  <=  ex3_stg_act_q and not(an_ac_grffence_en_dc);
ex3_grffence_act  <=  ex3_stg_act_q and not(an_ac_grffence_en_dc);
entry_valid_act   <=  not an_ac_grffence_en_dc;
entry_match_act   <=  not an_ac_grffence_en_dc;
not_grffence_act  <=  not an_ac_grffence_en_dc;
lru_update_act  <=  ex6_stg_act_q or ex7_stg_act_q or lru_update_event_q(4) or lru_update_event_q(8) or flash_invalidate or ex6_ieratwe_ws3;
notlb_grffence_act  <=  (not(ccr2_notlb_q) or spr_ic_clockgate_dis) and not(an_ac_grffence_en_dc);
debug_grffence_act  <=   trace_bus_enable_q and not(an_ac_grffence_en_dc);
eratsx_data_act  <=   (iu1_stg_act_q or ex2_stg_act_q) and not(an_ac_grffence_en_dc);
tiup  <=  '1';
init_alias  <=  pc_iu_init_reset;
tlb_rel_val_d   <=  mm_iu_ierat_rel_val;
tlb_rel_data_d  <=  mm_iu_ierat_rel_data;
tlb_rel_act_d   <=  mm_iu_ierat_rel_data(eratpos_relsoon);
tlb_rel_act     <=  (tlb_rel_act_q and not(ccr2_notlb_q));
ccr2_frat_paranoia_d(0 TO 8) <=   xu_iu_spr_ccr2_ifratsc;
ccr2_frat_paranoia_d(9) <=   xu_iu_spr_ccr2_ifrat;
ex1_valid_d  <=  xu_iu_rf1_val and not(xu_rf1_flush);
ex1_ttype_d(0 TO ttype_width-3) <=  xu_iu_rf1_is_eratre & xu_iu_rf1_is_eratwe & xu_iu_rf1_is_eratsx & xu_iu_rf1_is_eratilx;
ex1_ttype_d(ttype_width-2 TO ttype_width) <=  xu_iu_rf1_t;
ex1_ws_d  <=  xu_iu_rf1_ws;
ex1_rs_is_d  <=  (others => '0');
ex1_ra_entry_d  <=  (others => '0');
ex1_state_d(0) <=  or_reduce(xu_iu_msr_pr and xu_iu_rf1_val);
ex1_state_d(1) <=  (or_reduce(xu_iu_msr_hv and xu_iu_rf1_val) and not xu_iu_rf1_is_eratsx) or 
                   (or_reduce(mmucr0_gs_vec and xu_iu_rf1_val) and xu_iu_rf1_is_eratsx);
ex1_state_d(2) <=  (or_reduce(xu_iu_msr_is and xu_iu_rf1_val) and not xu_iu_rf1_is_eratsx) or
                   (or_reduce(mmucr0_ts_vec and xu_iu_rf1_val) and xu_iu_rf1_is_eratsx);
ex1_state_d(3) <=  or_reduce(xu_iu_msr_cm and xu_iu_rf1_val);
mmucr0_gs_vec  <=  mm_iu_ierat_mmucr0_0(2) & mm_iu_ierat_mmucr0_1(2) & mm_iu_ierat_mmucr0_2(2) & mm_iu_ierat_mmucr0_3(2);
mmucr0_ts_vec  <=  mm_iu_ierat_mmucr0_0(3) & mm_iu_ierat_mmucr0_1(3) & mm_iu_ierat_mmucr0_2(3) & mm_iu_ierat_mmucr0_3(3);
ex1_extclass_d  <=  mm_iu_ierat_mmucr0_1(0 to 1) when xu_iu_rf1_val(1)='1' 
             else mm_iu_ierat_mmucr0_2(0 to 1) when xu_iu_rf1_val(2)='1'
              else mm_iu_ierat_mmucr0_3(0 to 1) when xu_iu_rf1_val(3)='1'
               else mm_iu_ierat_mmucr0_0(0 to 1);
ex1_tlbsel_d  <=  mm_iu_ierat_mmucr0_1(4 to 5) when xu_iu_rf1_val(1)='1' 
             else mm_iu_ierat_mmucr0_2(4 to 5) when xu_iu_rf1_val(2)='1'
              else mm_iu_ierat_mmucr0_3(4 to 5) when xu_iu_rf1_val(3)='1'
               else mm_iu_ierat_mmucr0_0(4 to 5);
ex1_pid_d  <=  gate_and((xu_iu_rf1_is_eratsx='1'), ex1_pid_0) or gate_and((xu_iu_rf1_is_eratsx='0'), ex1_pid_1);
ex1_pid_0  <=  gate_and((xu_iu_rf1_val(0)='1'),mm_iu_ierat_mmucr0_0(6 to 19)) or
             gate_and((xu_iu_rf1_val(1)='1'),mm_iu_ierat_mmucr0_1(6 to 19)) or 
             gate_and((xu_iu_rf1_val(2)='1'),mm_iu_ierat_mmucr0_2(6 to 19)) or 
             gate_and((xu_iu_rf1_val(3)='1'),mm_iu_ierat_mmucr0_3(6 to 19));
ex1_pid_1  <=  gate_and((xu_iu_rf1_val(0)='1'),mm_iu_ierat_pid0) or
             gate_and((xu_iu_rf1_val(1)='1'),mm_iu_ierat_pid1) or
             gate_and((xu_iu_rf1_val(2)='1'),mm_iu_ierat_pid2) or
             gate_and((xu_iu_rf1_val(3)='1'),mm_iu_ierat_pid3);
ex1_ieratre  <=  or_reduce(ex1_valid_q) and ex1_ttype_q(0) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1);
ex1_ieratwe  <=  or_reduce(ex1_valid_q) and ex1_ttype_q(1) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1);
ex1_ieratsx  <=  or_reduce(ex1_valid_q) and ex1_ttype_q(2) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1);
ex2_valid_d  <=  ex1_valid_q and not(xu_ex1_flush);
ex2_ttype_d(0 TO ttype_width-3) <=  ex1_ttype_q(0 to ttype_width-3);
ex2_ttype_d(ttype_width-2 TO ttype_width-1) <=  xu_iu_ex1_is_csync & xu_iu_ex1_is_isync;
ex2_ws_d  <=  ex1_ws_q;
ex2_rs_is_d  <=  xu_iu_ex1_rs_is;
ex2_ra_entry_d  <=  xu_iu_ex1_ra_entry;
ex2_state_d  <=  ex1_state_q;
ex2_pid_d  <=  ex1_pid_q;
ex2_extclass_d  <=  ex1_extclass_q;
ex2_tlbsel_d  <=  ex1_tlbsel_q;
ex3_valid_d  <=  ex2_valid_q and not(xu_ex2_flush);
ex3_ttype_d  <=  ex2_ttype_q;
ex3_ws_d  <=  ex2_ws_q;
ex3_rs_is_d  <=  ex2_rs_is_q;
ex3_ra_entry_d  <=  iu1_first_hit_entry when ex2_ttype_q(2 to 3)/="00" else ex2_ra_entry_q;
ex3_tlbsel_d  <=  ex2_tlbsel_q;
ex3_extclass_d  <=  ex2_extclass_q;
ex3_state_d  <=  ex2_state_q;
ex3_pid_d  <=   ex2_pid_q;
ex3_ieratwe  <=  or_reduce(ex3_valid_q) and ex3_ttype_q(1) and ex3_tlbsel_q(0) and not ex3_tlbsel_q(1);
ex4_valid_d  <=  ex3_valid_q and not(xu_ex3_flush);
ex4_ttype_d  <=  ex3_ttype_q;
ex4_ws_d  <=  ex3_ws_q;
ex4_rs_is_d  <=  ex3_rs_is_q;
ex4_ra_entry_d  <=  ex3_ra_entry_q;
ex4_tlbsel_d  <=  ex3_tlbsel_q;
ex4_extclass_d  <=  rd_cam_data(63 to 64) when (ex3_valid_q/="0000" and ex3_ttype_q(0)='1' and ex3_ws_q="00")  
         else ex3_extclass_q;
ex4_state_d  <=  ex3_state_q(0) & rd_cam_data(65 to 66) & ex3_state_q(3) when (ex3_valid_q/="0000" and ex3_ttype_q(0)='1' and ex3_ws_q="00")  
         else ex3_state_q;
ex4_pid_d  <=  rd_cam_data(61 to 62) & rd_cam_data(57 to 60) & rd_cam_data(67 to 74) 
               when (ex3_valid_q/="0000" and ex3_ttype_q(0)='1' and ex3_ws_q="00")  
         else ex3_pid_q;
ex4_ieratwe  <=  or_reduce(ex4_valid_q) and ex4_ttype_q(1) and ex4_tlbsel_q(0) and not ex4_tlbsel_q(1);
ex5_valid_d  <=  ex4_valid_q and not(xu_ex4_flush);
ex5_ws_d  <=  ex4_ws_q;
ex5_rs_is_d  <=  ex4_rs_is_q;
ex5_ra_entry_d  <=  ex4_ra_entry_q;
ex5_ttype_d(0 TO 5) <=  ex4_ttype_q(0 to 5);
ex5_extclass_d  <=  ex4_extclass_q;
ex5_state_d  <=  ex4_state_q;
ex5_pid_d  <=   ex4_pid_q;
ex5_tlbsel_d  <=  ex4_tlbsel_q;
ex5_data_in_d  <=  xu_iu_ex4_rs_data;
ex5_ieratwe  <=  or_reduce(ex5_valid_q) and ex5_ttype_q(1) and ex5_tlbsel_q(0) and not ex5_tlbsel_q(1);
ex6_valid_d  <=  ex5_valid_q and not(xu_ex5_flush);
ex6_ws_d  <=  ex5_ws_q;
ex6_rs_is_d  <=  ex5_rs_is_q;
ex6_ra_entry_d  <=  ex5_ra_entry_q;
ex6_ttype_d(0 TO 3) <=  ex5_ttype_q(0 to 3);
ex6_ttype_d(4) <=  '1' when (ex5_ttype_q(4)='1' and mmucr1_q(3)='0' and ccr2_notlb_q=MMU_Mode_Value) 
              else '0';
ex6_ttype_d(5) <=  '1' when (ex5_ttype_q(5)='1' and mmucr1_q(4)='0' and ccr2_notlb_q=MMU_Mode_Value) 
              else '0';
ex6_extclass_d  <=  mm_iu_ierat_mmucr0_0(0 to 1) 
                 when (ex5_valid_q="1000" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_iu_ierat_mmucr0_1(0 to 1) 
                 when (ex5_valid_q="0100" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_iu_ierat_mmucr0_2(0 to 1) 
                 when (ex5_valid_q="0010" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_iu_ierat_mmucr0_3(0 to 1) 
                 when (ex5_valid_q="0001" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
       else ex5_extclass_q;
ex6_state_d  <=  xu_iu_msr_pr(0) & mm_iu_ierat_mmucr0_0(2 to 3) & xu_iu_msr_cm(0) 
                 when (ex5_valid_q="1000" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else xu_iu_msr_pr(1) & mm_iu_ierat_mmucr0_1(2 to 3) & xu_iu_msr_cm(1) 
                 when (ex5_valid_q="0100" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else xu_iu_msr_pr(2) & mm_iu_ierat_mmucr0_2(2 to 3) & xu_iu_msr_cm(2) 
                 when (ex5_valid_q="0010" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else xu_iu_msr_pr(3) & mm_iu_ierat_mmucr0_3(2 to 3) & xu_iu_msr_cm(3) 
                 when (ex5_valid_q="0001" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
       else ex5_state_q;
ex6_pid_d  <=   mm_iu_ierat_mmucr0_0(6 to 19) 
                 when (ex5_valid_q="1000" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_iu_ierat_mmucr0_1(6 to 19) 
                 when (ex5_valid_q="0100" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_iu_ierat_mmucr0_2(6 to 19) 
                 when (ex5_valid_q="0010" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_iu_ierat_mmucr0_3(6 to 19) 
                 when (ex5_valid_q="0001" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
       else ex5_pid_q;
ex6_tlbsel_d  <=  mm_iu_ierat_mmucr0_0(4 to 5) 
                 when (ex5_valid_q="1000" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_iu_ierat_mmucr0_1(4 to 5) 
                 when (ex5_valid_q="0100" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_iu_ierat_mmucr0_2(4 to 5) 
                 when (ex5_valid_q="0010" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
                 else mm_iu_ierat_mmucr0_3(4 to 5) 
                 when (ex5_valid_q="0001" and ex5_ttype_q(1)='1' and ex5_ws_q="00")  
       else ex5_tlbsel_q;
ex6_data_in_d  <=  ex5_data_in_q;
ex6_ieratwe  <=  or_reduce(ex6_valid_q) and ex6_ttype_q(1) and ex6_tlbsel_q(0) and not ex6_tlbsel_q(1);
ex7_valid_d  <=  ex6_valid_q;
ex7_ttype_d  <=  ex6_ttype_q;
ex7_tlbsel_d  <=  ex6_tlbsel_q;
ex7_ieratwe  <=  or_reduce(ex7_valid_q) and ex7_ttype_q(1) and ex7_tlbsel_q(0) and not ex7_tlbsel_q(1);
iu1_valid_d  <=  iu_ierat_iu0_thdid and (0 to thdid_width-1 => iu_ierat_iu0_val) and not(iu_ierat_iu0_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q);
iu1_state_d(0) <=  or_reduce(xu_iu_msr_pr and iu_ierat_iu0_thdid);
iu1_state_d(1) <=  or_reduce(xu_iu_msr_hv and iu_ierat_iu0_thdid);
iu1_state_d(2) <=  or_reduce(xu_iu_msr_is and iu_ierat_iu0_thdid);
iu1_state_d(3) <=  or_reduce(xu_iu_msr_cm and iu_ierat_iu0_thdid);
iu1_pid_d  <=  ( mm_iu_ierat_pid0 and (0 to pid_width-1 => iu_ierat_iu0_thdid(0)) ) or
              ( mm_iu_ierat_pid1 and (0 to pid_width-1 => iu_ierat_iu0_thdid(1)) ) or
              ( mm_iu_ierat_pid2 and (0 to pid_width-1 => iu_ierat_iu0_thdid(2)) ) or
              ( mm_iu_ierat_pid3 and (0 to pid_width-1 => iu_ierat_iu0_thdid(3)) );
iu2_valid_d  <=  iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q);
iu2_state_d  <=  iu1_state_q;
iu2_pid_d    <=  iu1_pid_q;
iu_mm_ierat_flush_d  <=  iu_ierat_iu1_flush;
mmucr1_d  <=  mm_iu_ierat_mmucr1;
MQQ1:IU1_MULTIHIT_B_PT(1) <=
    Eq(( ENTRY_MATCH(1) & ENTRY_MATCH(2) & 
    ENTRY_MATCH(3) & ENTRY_MATCH(4) & 
    ENTRY_MATCH(5) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ2:IU1_MULTIHIT_B_PT(2) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(2) & 
    ENTRY_MATCH(3) & ENTRY_MATCH(4) & 
    ENTRY_MATCH(5) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ3:IU1_MULTIHIT_B_PT(3) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(3) & ENTRY_MATCH(4) & 
    ENTRY_MATCH(5) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ4:IU1_MULTIHIT_B_PT(4) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(4) & 
    ENTRY_MATCH(5) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ5:IU1_MULTIHIT_B_PT(5) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(5) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ6:IU1_MULTIHIT_B_PT(6) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(6) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ7:IU1_MULTIHIT_B_PT(7) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(7) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ8:IU1_MULTIHIT_B_PT(8) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(8) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ9:IU1_MULTIHIT_B_PT(9) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(9) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ10:IU1_MULTIHIT_B_PT(10) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(10) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ11:IU1_MULTIHIT_B_PT(11) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(11) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ12:IU1_MULTIHIT_B_PT(12) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(12) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ13:IU1_MULTIHIT_B_PT(13) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(13) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ14:IU1_MULTIHIT_B_PT(14) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(14) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ15:IU1_MULTIHIT_B_PT(15) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(15) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ16:IU1_MULTIHIT_B_PT(16) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ17:IU1_MULTIHIT_B <= 
    (IU1_MULTIHIT_B_PT(1) OR IU1_MULTIHIT_B_PT(2)
     OR IU1_MULTIHIT_B_PT(3) OR IU1_MULTIHIT_B_PT(4)
     OR IU1_MULTIHIT_B_PT(5) OR IU1_MULTIHIT_B_PT(6)
     OR IU1_MULTIHIT_B_PT(7) OR IU1_MULTIHIT_B_PT(8)
     OR IU1_MULTIHIT_B_PT(9) OR IU1_MULTIHIT_B_PT(10)
     OR IU1_MULTIHIT_B_PT(11) OR IU1_MULTIHIT_B_PT(12)
     OR IU1_MULTIHIT_B_PT(13) OR IU1_MULTIHIT_B_PT(14)
     OR IU1_MULTIHIT_B_PT(15) OR IU1_MULTIHIT_B_PT(16)
    );

iu1_multihit  <=  not iu1_multihit_b;
iu2_multihit_b_pt_d  <=  iu1_multihit_b_pt;
iu2_multihit_enab  <=  not or_reduce(iu2_multihit_b_pt_q);
MQQ18:IU1_FIRST_HIT_ENTRY_PT(1) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) & ENTRY_MATCH(15)
     ) , STD_ULOGIC_VECTOR'("0000000000000001"));
MQQ19:IU1_FIRST_HIT_ENTRY_PT(2) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13) & 
    ENTRY_MATCH(14) ) , STD_ULOGIC_VECTOR'("000000000000001"));
MQQ20:IU1_FIRST_HIT_ENTRY_PT(3) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) & ENTRY_MATCH(13)
     ) , STD_ULOGIC_VECTOR'("00000000000001"));
MQQ21:IU1_FIRST_HIT_ENTRY_PT(4) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11) & 
    ENTRY_MATCH(12) ) , STD_ULOGIC_VECTOR'("0000000000001"));
MQQ22:IU1_FIRST_HIT_ENTRY_PT(5) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) & ENTRY_MATCH(11)
     ) , STD_ULOGIC_VECTOR'("000000000001"));
MQQ23:IU1_FIRST_HIT_ENTRY_PT(6) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9) & 
    ENTRY_MATCH(10) ) , STD_ULOGIC_VECTOR'("00000000001"));
MQQ24:IU1_FIRST_HIT_ENTRY_PT(7) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) & ENTRY_MATCH(9)
     ) , STD_ULOGIC_VECTOR'("0000000001"));
MQQ25:IU1_FIRST_HIT_ENTRY_PT(8) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7) & 
    ENTRY_MATCH(8) ) , STD_ULOGIC_VECTOR'("000000001"));
MQQ26:IU1_FIRST_HIT_ENTRY_PT(9) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) & ENTRY_MATCH(7)
     ) , STD_ULOGIC_VECTOR'("00000001"));
MQQ27:IU1_FIRST_HIT_ENTRY_PT(10) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5) & 
    ENTRY_MATCH(6) ) , STD_ULOGIC_VECTOR'("0000001"));
MQQ28:IU1_FIRST_HIT_ENTRY_PT(11) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) & ENTRY_MATCH(5)
     ) , STD_ULOGIC_VECTOR'("000001"));
MQQ29:IU1_FIRST_HIT_ENTRY_PT(12) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3) & 
    ENTRY_MATCH(4) ) , STD_ULOGIC_VECTOR'("00001"));
MQQ30:IU1_FIRST_HIT_ENTRY_PT(13) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) & ENTRY_MATCH(3)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ31:IU1_FIRST_HIT_ENTRY_PT(14) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1) & 
    ENTRY_MATCH(2) ) , STD_ULOGIC_VECTOR'("001"));
MQQ32:IU1_FIRST_HIT_ENTRY_PT(15) <=
    Eq(( ENTRY_MATCH(0) & ENTRY_MATCH(1)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ33:IU1_FIRST_HIT_ENTRY(0) <= 
    (IU1_FIRST_HIT_ENTRY_PT(1) OR IU1_FIRST_HIT_ENTRY_PT(2)
     OR IU1_FIRST_HIT_ENTRY_PT(3) OR IU1_FIRST_HIT_ENTRY_PT(4)
     OR IU1_FIRST_HIT_ENTRY_PT(5) OR IU1_FIRST_HIT_ENTRY_PT(6)
     OR IU1_FIRST_HIT_ENTRY_PT(7) OR IU1_FIRST_HIT_ENTRY_PT(8)
    );
MQQ34:IU1_FIRST_HIT_ENTRY(1) <= 
    (IU1_FIRST_HIT_ENTRY_PT(1) OR IU1_FIRST_HIT_ENTRY_PT(2)
     OR IU1_FIRST_HIT_ENTRY_PT(3) OR IU1_FIRST_HIT_ENTRY_PT(4)
     OR IU1_FIRST_HIT_ENTRY_PT(9) OR IU1_FIRST_HIT_ENTRY_PT(10)
     OR IU1_FIRST_HIT_ENTRY_PT(11) OR IU1_FIRST_HIT_ENTRY_PT(12)
    );
MQQ35:IU1_FIRST_HIT_ENTRY(2) <= 
    (IU1_FIRST_HIT_ENTRY_PT(1) OR IU1_FIRST_HIT_ENTRY_PT(2)
     OR IU1_FIRST_HIT_ENTRY_PT(5) OR IU1_FIRST_HIT_ENTRY_PT(6)
     OR IU1_FIRST_HIT_ENTRY_PT(9) OR IU1_FIRST_HIT_ENTRY_PT(10)
     OR IU1_FIRST_HIT_ENTRY_PT(13) OR IU1_FIRST_HIT_ENTRY_PT(14)
    );
MQQ36:IU1_FIRST_HIT_ENTRY(3) <= 
    (IU1_FIRST_HIT_ENTRY_PT(1) OR IU1_FIRST_HIT_ENTRY_PT(3)
     OR IU1_FIRST_HIT_ENTRY_PT(5) OR IU1_FIRST_HIT_ENTRY_PT(7)
     OR IU1_FIRST_HIT_ENTRY_PT(9) OR IU1_FIRST_HIT_ENTRY_PT(11)
     OR IU1_FIRST_HIT_ENTRY_PT(13) OR IU1_FIRST_HIT_ENTRY_PT(15)
    );

iu2_first_hit_entry_pt_d  <=  iu1_first_hit_entry_pt;
iu2_first_hit_entry(0) <=  
    (iu2_first_hit_entry_pt_q(1) or iu2_first_hit_entry_pt_q(2)
     or iu2_first_hit_entry_pt_q(3) or iu2_first_hit_entry_pt_q(4)
     or iu2_first_hit_entry_pt_q(5) or iu2_first_hit_entry_pt_q(6)
     or iu2_first_hit_entry_pt_q(7) or iu2_first_hit_entry_pt_q(8));
iu2_first_hit_entry(1) <=  
    (iu2_first_hit_entry_pt_q(1) or iu2_first_hit_entry_pt_q(2)
     or iu2_first_hit_entry_pt_q(3) or iu2_first_hit_entry_pt_q(4)
     or iu2_first_hit_entry_pt_q(9) or iu2_first_hit_entry_pt_q(10)
     or iu2_first_hit_entry_pt_q(11) or iu2_first_hit_entry_pt_q(12));
iu2_first_hit_entry(2) <=  
    (iu2_first_hit_entry_pt_q(1) or iu2_first_hit_entry_pt_q(2)
     or iu2_first_hit_entry_pt_q(5) or iu2_first_hit_entry_pt_q(6)
     or iu2_first_hit_entry_pt_q(9) or iu2_first_hit_entry_pt_q(10)
     or iu2_first_hit_entry_pt_q(13) or iu2_first_hit_entry_pt_q(14));
iu2_first_hit_entry(3) <=  
    (iu2_first_hit_entry_pt_q(1) or iu2_first_hit_entry_pt_q(3)
     or iu2_first_hit_entry_pt_q(5) or iu2_first_hit_entry_pt_q(7)
     or iu2_first_hit_entry_pt_q(9) or iu2_first_hit_entry_pt_q(11)
     or iu2_first_hit_entry_pt_q(13) or iu2_first_hit_entry_pt_q(15));
iu2_cam_cmp_data_d    <=  cam_cmp_data;
iu2_array_cmp_data_d  <=  array_cmp_data;
iu2_miss_d(0) <=  (  or_reduce(iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) and 
                             not iu1_flush_enab_q and not ccr2_frat_paranoia_q(9) );
iu2_miss_d(1) <=  not cam_hit;
iu2_miss_sig  <=  iu2_miss_q(0) and iu2_miss_q(1);
iu2_multihit_d(0) <=  ( cam_hit and iu1_multihit and 
                          or_reduce(iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) and 
                            not iu1_flush_enab_q and not ccr2_frat_paranoia_q(9) );
iu2_multihit_d(1) <=  iu1_multihit;
iu2_multihit_sig  <=  iu2_multihit_q(0) and iu2_multihit_q(1);
iu2_parerr_d(0) <=  ( cam_hit and iu1_multihit_b and 
                          or_reduce(iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) and 
                            not iu1_flush_enab_q  and not ccr2_frat_paranoia_q(9) );
iu2_parerr_d(1) <=  ( cam_hit and iu1_multihit_b and 
                          or_reduce(iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) and 
                            not iu1_flush_enab_q  and not ccr2_frat_paranoia_q(9) );
iu2_parerr_sig  <=  (iu2_parerr_q(0) and iu2_cmp_data_parerr_epn) or   
                  (iu2_parerr_q(1) and iu2_cmp_data_parerr_rpn);
iu2_isi_d(0) <=  ( or_reduce(iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) 
                             and not iu1_flush_enab_q and  iu1_state_q(0) and not ccr2_frat_paranoia_q(9) );
iu2_isi_d(2) <=  ( or_reduce(iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) 
                             and not iu1_flush_enab_q and  not iu1_state_q(0) and not ccr2_frat_paranoia_q(9) );
iu2_isi_d(4) <=  ( or_reduce(iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) 
                             and not iu1_flush_enab_q and  mmucr1_q(1) and not ccr2_frat_paranoia_q(9) );
iu2_isi_d(1) <=  not array_cmp_data(45);
iu2_isi_d(3) <=  not array_cmp_data(46);
iu2_isi_d(5) <=  not array_cmp_data(30);
iu2_isi_sig  <=  (iu2_isi_q(0) and iu2_isi_q(1)) or 
                (iu2_isi_q(2) and iu2_isi_q(3)) or 
                 (iu2_isi_q(4) and iu2_isi_q(5));
ex3_eratsx_data_d  <=  iu1_multihit & cam_hit & iu1_first_hit_entry;
ex3_parerr_d(0 TO thdid_width-1) <=  ex2_valid_q and not(xu_ex2_flush);
ex3_parerr_d(thdid_width) <=  ( cam_hit and iu1_multihit_b and ex2_ttype_q(2) and ex2_tlbsel_q(0) and not(ex2_tlbsel_q(1)) 
              and not(ex3_ieratwe or ex4_ieratwe or ex5_ieratwe or ex6_ieratwe or ex7_ieratwe) 
              and or_reduce(ex2_valid_q and not(xu_ex2_flush)) );
ex3_parerr_enab  <=  ex3_parerr_q(thdid_width) and iu2_cmp_data_parerr_epn;
ex4_rd_array_data_d  <=  rd_array_data;
ex4_rd_cam_data_d    <=  rd_cam_data;
ex4_parerr_d(0 TO thdid_width-1) <=  ex3_valid_q and not(xu_ex3_flush);
ex4_parerr_d(thdid_width) <=  (ex3_ttype_q(0) and not ex3_ws_q(0) and not ex3_ws_q(1) and ex3_tlbsel_q(0) and not ex3_tlbsel_q(1) 
                                  and not(ex4_ieratwe or ex5_ieratwe or ex6_ieratwe));
ex4_parerr_d(thdid_width+1) <=  (ex3_ttype_q(0) and xor_reduce(ex3_ws_q)  and ex3_tlbsel_q(0) and not ex3_tlbsel_q(1) 
                                  and not(ex4_ieratwe or ex5_ieratwe or ex6_ieratwe));
ex4_parerr_enab  <=  (ex4_parerr_q(thdid_width)   and ex4_rd_data_parerr_epn) or
                   (ex4_parerr_q(thdid_width+1) and ex4_rd_data_parerr_rpn);
ex4_ieen_d(0 TO thdid_width-1) <=  (ex3_parerr_q(0 to thdid_width-1) and (0 to thdid_width-1 => ex3_parerr_enab) and not(xu_ex3_flush)) 
                when (ex3_ttype_q(2)='1' ) 
      else (iu2_valid_q and not iu2_n_flush_req_q)
                when (iu2_multihit_sig='1' or iu2_parerr_sig='1') 
      else (others => '0');
ex4_ieen_d(thdid_width TO thdid_width+num_entry_log2-1) <=   ex3_eratsx_data_q(2 to 2+num_entry_log2-1)
                when (ex3_ttype_q(2)='1') 
      else ex3_ra_entry_q  
                when (ex3_ttype_q(0)='1' and ex3_ws_q="00" and ex3_tlbsel_q=TlbSel_IErat) 
      else ex3_ra_entry_q  
                when (ex3_ttype_q(0)='1' and (ex3_ws_q="01" or ex3_ws_q="10") and ex3_tlbsel_q=TlbSel_IErat) 
      else ex3_eratsx_data_q(2 to 2+num_entry_log2-1)
                when (iu2_multihit_sig='1' or iu2_parerr_sig='1') 
      else (others => '0');
ex5_ieen_d(0 TO thdid_width-1) <=  (ex4_ieen_q(0 to thdid_width-1) and not(xu_ex4_flush)) or
                                  (ex4_parerr_q(0 to thdid_width-1) and (0 to thdid_width-1 => ex4_parerr_enab) and not(xu_ex4_flush));
ex5_ieen_d(thdid_width TO thdid_width+num_entry_log2-1) <=  ex4_ieen_q(thdid_width to thdid_width+num_entry_log2-1);
ex6_ieen_d  <=  or_reduce(ex5_ieen_q(0 to thdid_width-1)) & 
                    ex5_ieen_q(thdid_width to thdid_width+num_entry_log2-1);
mchk_flash_inv_d(0) <=  or_reduce(iu2_valid_q and not(xu_iu_flush) and not(iu2_n_flush_req_q));
mchk_flash_inv_d(1) <=  iu2_parerr_sig;
mchk_flash_inv_d(2) <=  iu2_multihit_sig;
mchk_flash_inv_d(3) <=  mchk_flash_inv_enab;
mchk_flash_inv_enab  <=  mchk_flash_inv_q(0) and (mchk_flash_inv_q(1) or mchk_flash_inv_q(2)) and not(ccr2_notlb_q) and not(xucr4_mmu_mchk_q);
iu1_flush_enab_d  <=  '1' when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1') 
               else '1' when snoop_val_q(0 to 1)="11"  
               else '1' when (ex1_valid_q/="0000" and ex1_ttype_q(2)='1' and ex1_tlbsel_q=TlbSel_IErat) 
               else '1' when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                    and ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_IErat)   
               else '1' when ((ex6_valid_q/="0000" and ex6_ttype_q(4 to 5)/="00") or mchk_flash_inv_enab='1' or mchk_flash_inv_q(3)='1')  
               else '0';
iu2_n_flush_req_d  <=  (iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) 
                         when iu1_flush_enab_q='1' 
                else (iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q) and not(tlb_miss_q)) 
                         when (cam_hit='0' and ccr2_notlb_q=MMU_Mode_Value and ccr2_frat_paranoia_q(9)='0')  
                else (others => '0');
hold_req_d(0) <=  '1' when por_hold_req(0)='1'
         else  '0' when ccr2_frat_paranoia_q(9)='1'
         else  '0' when (xu_iu_flush(0)='1'   or iu_ierat_iu1_flush(0)='1')
         else  '0' when (tlb_rel_val_q(0)='1'   and ccr2_notlb_q=MMU_Mode_Value)
         else  '1' when (cam_hit='0' and iu1_valid_q(0)='1'   
                             and iu_ierat_iu1_flush(0)='0'   and xu_iu_flush(0)='0'   and iu1_flush_enab_q='0'  
                              and iu2_n_flush_req_q(0)='0'   and tlb_miss_q(0)='0'   and ccr2_notlb_q=MMU_Mode_Value)
         else  '1' when (iu1_valid_q(0)='1'   and iu_ierat_iu1_flush(0)='0'   and xu_iu_flush(0)='0'   and iu1_flush_enab_q='0'  
                              and iu2_n_flush_req_q(0)='0'   and tlb_miss_q(0)='1'   and ccr2_notlb_q=MMU_Mode_Value)  
         else hold_req_q(0);
hold_req_d(1) <=  '1' when por_hold_req(1)='1'
         else  '0' when ccr2_frat_paranoia_q(9)='1'
         else  '0' when (xu_iu_flush(1)='1'   or iu_ierat_iu1_flush(1)='1')
         else  '0' when (tlb_rel_val_q(1)='1'   and ccr2_notlb_q=MMU_Mode_Value)
         else  '1' when (cam_hit='0' and iu1_valid_q(1)='1'   
                             and iu_ierat_iu1_flush(1)='0'   and xu_iu_flush(1)='0'   and iu1_flush_enab_q='0'  
                              and iu2_n_flush_req_q(1)='0'   and tlb_miss_q(1)='0'   and ccr2_notlb_q=MMU_Mode_Value)
         else  '1' when (iu1_valid_q(1)='1'   and iu_ierat_iu1_flush(1)='0'   and xu_iu_flush(1)='0'   and iu1_flush_enab_q='0'  
                              and iu2_n_flush_req_q(1)='0'   and tlb_miss_q(1)='1'   and ccr2_notlb_q=MMU_Mode_Value)  
         else hold_req_q(1);
hold_req_d(2) <=  '1' when por_hold_req(2)='1'
         else  '0' when ccr2_frat_paranoia_q(9)='1'
         else  '0' when (xu_iu_flush(2)='1'   or iu_ierat_iu1_flush(2)='1')
         else  '0' when (tlb_rel_val_q(2)='1'   and ccr2_notlb_q=MMU_Mode_Value)
         else  '1' when (cam_hit='0' and iu1_valid_q(2)='1'   
                             and iu_ierat_iu1_flush(2)='0'   and xu_iu_flush(2)='0'   and iu1_flush_enab_q='0'  
                              and iu2_n_flush_req_q(2)='0'   and tlb_miss_q(2)='0'   and ccr2_notlb_q=MMU_Mode_Value)
         else  '1' when (iu1_valid_q(2)='1'   and iu_ierat_iu1_flush(2)='0'   and xu_iu_flush(2)='0'   and iu1_flush_enab_q='0'  
                              and iu2_n_flush_req_q(2)='0'   and tlb_miss_q(2)='1'   and ccr2_notlb_q=MMU_Mode_Value)  
         else hold_req_q(2);
hold_req_d(3) <=  '1' when por_hold_req(3)='1'
         else  '0' when ccr2_frat_paranoia_q(9)='1'
         else  '0' when (xu_iu_flush(3)='1'   or iu_ierat_iu1_flush(3)='1')
         else  '0' when (tlb_rel_val_q(3)='1'   and ccr2_notlb_q=MMU_Mode_Value)
         else  '1' when (cam_hit='0' and iu1_valid_q(3)='1'   
                             and iu_ierat_iu1_flush(3)='0'   and xu_iu_flush(3)='0'   and iu1_flush_enab_q='0'  
                              and iu2_n_flush_req_q(3)='0'   and tlb_miss_q(3)='0'   and ccr2_notlb_q=MMU_Mode_Value)
         else  '1' when (iu1_valid_q(3)='1'   and iu_ierat_iu1_flush(3)='0'   and xu_iu_flush(3)='0'   and iu1_flush_enab_q='0'  
                              and iu2_n_flush_req_q(3)='0'   and tlb_miss_q(3)='1'   and ccr2_notlb_q=MMU_Mode_Value)  
         else hold_req_q(3);
tlb_miss_d(0) <=  '0' when (ccr2_notlb_q/=MMU_Mode_Value or por_seq_q/=PorSeq_Idle or ccr2_frat_paranoia_q(9)='1')
               else '0' when xu_iu_flush(0)='1'
               else hold_req_q(0)   when (tlb_miss_q(0)='0'   and tlb_rel_val_q(0)='1'   and tlb_rel_val_q(4)='0')  
               else tlb_miss_q(0);
tlb_miss_d(1) <=  '0' when (ccr2_notlb_q/=MMU_Mode_Value or por_seq_q/=PorSeq_Idle or ccr2_frat_paranoia_q(9)='1')
               else '0' when xu_iu_flush(1)='1'
               else hold_req_q(1)   when (tlb_miss_q(1)='0'   and tlb_rel_val_q(1)='1'   and tlb_rel_val_q(4)='0')  
               else tlb_miss_q(1);
tlb_miss_d(2) <=  '0' when (ccr2_notlb_q/=MMU_Mode_Value or por_seq_q/=PorSeq_Idle or ccr2_frat_paranoia_q(9)='1')
               else '0' when xu_iu_flush(2)='1'
               else hold_req_q(2)   when (tlb_miss_q(2)='0'   and tlb_rel_val_q(2)='1'   and tlb_rel_val_q(4)='0')  
               else tlb_miss_q(2);
tlb_miss_d(3) <=  '0' when (ccr2_notlb_q/=MMU_Mode_Value or por_seq_q/=PorSeq_Idle or ccr2_frat_paranoia_q(9)='1')
               else '0' when xu_iu_flush(3)='1'
               else hold_req_q(3)   when (tlb_miss_q(3)='0'   and tlb_rel_val_q(3)='1'   and tlb_rel_val_q(4)='0')  
               else tlb_miss_q(3);
tlb_req_inprogress_d(0) <=  '0' when (ccr2_frat_paranoia_q(9)='1' or por_hold_req(0)='1'   or ccr2_notlb_q/=MMU_Mode_Value or tlb_rel_val_q(0)='1')   
         else  '0' when (xu_iu_flush(0)='0'   and iu2_valid_q(0)='1'   and hold_req_q(0)='0')    
         else  '1' when (iu2_tlbreq_q='1' and iu2_valid_q(0)='1'   and ccr2_notlb_q=MMU_Mode_Value)   
         else tlb_req_inprogress_q(0);
tlb_req_inprogress_d(1) <=  '0' when (ccr2_frat_paranoia_q(9)='1' or por_hold_req(1)='1'   or ccr2_notlb_q/=MMU_Mode_Value or tlb_rel_val_q(1)='1')   
         else  '0' when (xu_iu_flush(1)='0'   and iu2_valid_q(1)='1'   and hold_req_q(1)='0')    
         else  '1' when (iu2_tlbreq_q='1' and iu2_valid_q(1)='1'   and ccr2_notlb_q=MMU_Mode_Value)   
         else tlb_req_inprogress_q(1);
tlb_req_inprogress_d(2) <=  '0' when (ccr2_frat_paranoia_q(9)='1' or por_hold_req(2)='1'   or ccr2_notlb_q/=MMU_Mode_Value or tlb_rel_val_q(2)='1')   
         else  '0' when (xu_iu_flush(2)='0'   and iu2_valid_q(2)='1'   and hold_req_q(2)='0')    
         else  '1' when (iu2_tlbreq_q='1' and iu2_valid_q(2)='1'   and ccr2_notlb_q=MMU_Mode_Value)   
         else tlb_req_inprogress_q(2);
tlb_req_inprogress_d(3) <=  '0' when (ccr2_frat_paranoia_q(9)='1' or por_hold_req(3)='1'   or ccr2_notlb_q/=MMU_Mode_Value or tlb_rel_val_q(3)='1')   
         else  '0' when (xu_iu_flush(3)='0'   and iu2_valid_q(3)='1'   and hold_req_q(3)='0')    
         else  '1' when (iu2_tlbreq_q='1' and iu2_valid_q(3)='1'   and ccr2_notlb_q=MMU_Mode_Value)   
         else tlb_req_inprogress_q(3);
iu2_tlbreq_d  <=  '1' when (cam_hit='0' and iu1_flush_enab_q='0' and ccr2_notlb_q=MMU_Mode_Value and ccr2_frat_paranoia_q(9)='0' and
                     (iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q) and not(tlb_miss_q) and not(hold_req_q))/="0000") 
           else '0';
snoop_val_d(0) <=  mm_iu_ierat_snoop_val when snoop_val_q(0)='0'
           else '0' when (tlb_rel_val_q(4)='0' and snoop_val_q(1)='1')  
           else snoop_val_q(0);
snoop_val_d(1) <=  not iu_ierat_ium1_back_inv;
snoop_val_d(2) <=  '0' when (tlb_rel_val_q(4)='1' or snoop_val_q(1)='0') 
             else snoop_val_q(0);
snoop_attr_d  <=  mm_iu_ierat_snoop_attr when snoop_val_q(0)='0'
           else snoop_attr_q;
snoop_addr_d  <=  mm_iu_ierat_snoop_vpn when snoop_val_q(0)='0'
           else snoop_addr_q;
iu_mm_ierat_snoop_ack  <=  snoop_val_q(2);
gen64_holdreg: if rs_data_width = 64 generate
rpn_holdreg0_d(0 TO 19) <=  ex6_data_in_q(0 to 19) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg0_q(0   to 19);
rpn_holdreg0_d(20 TO 31) <=  ex6_data_in_q(20 to 31) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg0_q(20   to 31);
rpn_holdreg0_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg0_q(32   to 51);
rpn_holdreg0_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg0_q(52   to 63);
rpn_holdreg1_d(0 TO 19) <=  ex6_data_in_q(0 to 19) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg1_q(0   to 19);
rpn_holdreg1_d(20 TO 31) <=  ex6_data_in_q(20 to 31) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg1_q(20   to 31);
rpn_holdreg1_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg1_q(32   to 51);
rpn_holdreg1_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg1_q(52   to 63);
rpn_holdreg2_d(0 TO 19) <=  ex6_data_in_q(0 to 19) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg2_q(0   to 19);
rpn_holdreg2_d(20 TO 31) <=  ex6_data_in_q(20 to 31) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg2_q(20   to 31);
rpn_holdreg2_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg2_q(32   to 51);
rpn_holdreg2_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg2_q(52   to 63);
rpn_holdreg3_d(0 TO 19) <=  ex6_data_in_q(0 to 19) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg3_q(0   to 19);
rpn_holdreg3_d(20 TO 31) <=  ex6_data_in_q(20 to 31) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg3_q(20   to 31);
rpn_holdreg3_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(32 to 51) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg3_q(32   to 51);
rpn_holdreg3_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='1') 
                  else ex6_data_in_q(52 to 63) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat and ex6_state_q(3)='0') 
                  else rpn_holdreg3_q(52   to 63);
end generate gen64_holdreg;
gen32_holdreg: if rs_data_width = 32 generate
rpn_holdreg0_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg0_q(32   to 51);
rpn_holdreg0_d(20 TO 31) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg0_q(20   to 31);
rpn_holdreg0_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg0_q(52   to 63);
rpn_holdreg0_d(0 TO 19) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(0)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg0_q(0   to 19);
rpn_holdreg1_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg1_q(32   to 51);
rpn_holdreg1_d(20 TO 31) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg1_q(20   to 31);
rpn_holdreg1_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg1_q(52   to 63);
rpn_holdreg1_d(0 TO 19) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(1)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg1_q(0   to 19);
rpn_holdreg2_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg2_q(32   to 51);
rpn_holdreg2_d(20 TO 31) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg2_q(20   to 31);
rpn_holdreg2_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg2_q(52   to 63);
rpn_holdreg2_d(0 TO 19) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(2)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg2_q(0   to 19);
rpn_holdreg3_d(32 TO 51) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg3_q(32   to 51);
rpn_holdreg3_d(20 TO 31) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="01" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg3_q(20   to 31);
rpn_holdreg3_d(52 TO 63) <=  ex6_data_in_q(52 to 63) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg3_q(52   to 63);
rpn_holdreg3_d(0 TO 19) <=  ex6_data_in_q(32 to 51) when (ex6_valid_q(3)='1'   and ex6_ttype_q(1)='1' and 
                                           ex6_ws_q="10" and ex6_tlbsel_q=TlbSel_IErat) 
                  else rpn_holdreg3_q(0   to 19);
end generate gen32_holdreg;
ex6_ieratwe_ws3    <=  or_reduce(ex6_valid_q) and ex6_ttype_q(1) and Eq(ex6_ws_q,"11") and Eq(ex6_tlbsel_q,TlbSel_IErat);
watermark_d    <=  ex6_data_in_q(64-watermark_width to 63) when ex6_ieratwe_ws3='1'  
                  else watermark_q;
eptr_d  <=  (others => '0') when (ex6_ieratwe_ws3='1' and mmucr1_q(0)='1') 
    else  (others => '0') when (eptr_q="1111" or eptr_q=watermark_q) and 
                          ( (ex6_valid_q /= "0000" and ex6_ttype_q(1)='1' and ex6_ws_q="00" and 
                               ex6_tlbsel_q=TlbSel_IErat and mmucr1_q(0)='1') or 
                            (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1' and 
                               tlb_rel_data_q(eratpos_wren)='1' and mmucr1_q(0)='1') ) 
    else eptr_p1    when   ( (ex6_valid_q /= "0000" and ex6_ttype_q(1)='1' and ex6_ws_q="00" and 
                               ex6_tlbsel_q=TlbSel_IErat and mmucr1_q(0)='1') or  
                            (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1' and 
                               tlb_rel_data_q(eratpos_wren)='1' and mmucr1_q(0)='1') ) 
    else eptr_q;
eptr_p1  <=  "0001" when eptr_q="0000"
      else "0010" when eptr_q="0001"
      else "0011" when eptr_q="0010"
      else "0100" when eptr_q="0011"
      else "0101" when eptr_q="0100"
      else "0110" when eptr_q="0101"
      else "0111" when eptr_q="0110"
      else "1000" when eptr_q="0111"
      else "1001" when eptr_q="1000"
      else "1010" when eptr_q="1001"
      else "1011" when eptr_q="1010"
      else "1100" when eptr_q="1011"
      else "1101" when eptr_q="1100"
      else "1110" when eptr_q="1101"
      else "1111" when eptr_q="1110"
      else "0000";
lru_way_is_written    <=  Eq(lru_way_encode, ex6_ra_entry_q);
lru_way_is_hit_entry  <=  Eq(lru_way_encode, iu1_first_hit_entry);
lru_update_event_d(0) <=  ( tlb_rel_data_q(eratpos_wren) and or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4) );
lru_update_event_d(1) <=   ( snoop_val_q(0) and snoop_val_q(1)  );
lru_update_event_d(2) <=   ( or_reduce(ex6_valid_q) and (ex6_ttype_q(4) or ex6_ttype_q(5)) );
lru_update_event_d(3) <=   ( or_reduce(ex6_valid_q) and ex6_ttype_q(1) and not ex6_ws_q(0) and not ex6_ws_q(1) 
                               and ex6_tlbsel_q(0) and not ex6_tlbsel_q(1) and lru_way_is_written );
lru_update_event_d(4) <=   ( or_reduce(iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) 
                                   and not iu1_flush_enab_q and cam_hit and lru_way_is_hit_entry );
lru_update_event_d(5) <=  lru_update_event_q(0) or lru_update_event_q(3);
lru_update_event_d(6) <=  lru_update_event_q(1) or lru_update_event_q(2);
lru_update_event_d(7) <=  ( or_reduce(iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) 
                                   and not iu1_flush_enab_q and cam_hit and lru_way_is_hit_entry );
lru_update_event_d(8) <=  lru_update_event_q(0) or lru_update_event_q(1) or lru_update_event_q(2) or lru_update_event_q(3);
lru_d(1) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(1)='1'   and mmucr1_q(0)='0' and lru_op_vec(1)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(1)='1'   and mmucr1_q(0)='0' and lru_op_vec(1)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(1);
lru_eff(1) <=  (lru_vp_vec(1)   and lru_op_vec(1))   or (lru_q(1)   and not lru_op_vec(1));
lru_d(2) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(2)='1'   and mmucr1_q(0)='0' and lru_op_vec(2)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(2)='1'   and mmucr1_q(0)='0' and lru_op_vec(2)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(2);
lru_eff(2) <=  (lru_vp_vec(2)   and lru_op_vec(2))   or (lru_q(2)   and not lru_op_vec(2));
lru_d(3) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(3)='1'   and mmucr1_q(0)='0' and lru_op_vec(3)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(3)='1'   and mmucr1_q(0)='0' and lru_op_vec(3)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(3);
lru_eff(3) <=  (lru_vp_vec(3)   and lru_op_vec(3))   or (lru_q(3)   and not lru_op_vec(3));
lru_d(4) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(4)='1'   and mmucr1_q(0)='0' and lru_op_vec(4)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(4)='1'   and mmucr1_q(0)='0' and lru_op_vec(4)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(4);
lru_eff(4) <=  (lru_vp_vec(4)   and lru_op_vec(4))   or (lru_q(4)   and not lru_op_vec(4));
lru_d(5) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(5)='1'   and mmucr1_q(0)='0' and lru_op_vec(5)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(5)='1'   and mmucr1_q(0)='0' and lru_op_vec(5)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(5);
lru_eff(5) <=  (lru_vp_vec(5)   and lru_op_vec(5))   or (lru_q(5)   and not lru_op_vec(5));
lru_d(6) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(6)='1'   and mmucr1_q(0)='0' and lru_op_vec(6)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(6)='1'   and mmucr1_q(0)='0' and lru_op_vec(6)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(6);
lru_eff(6) <=  (lru_vp_vec(6)   and lru_op_vec(6))   or (lru_q(6)   and not lru_op_vec(6));
lru_d(7) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(7)='1'   and mmucr1_q(0)='0' and lru_op_vec(7)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(7)='1'   and mmucr1_q(0)='0' and lru_op_vec(7)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(7);
lru_eff(7) <=  (lru_vp_vec(7)   and lru_op_vec(7))   or (lru_q(7)   and not lru_op_vec(7));
lru_d(8) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(8)='1'   and mmucr1_q(0)='0' and lru_op_vec(8)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(8)='1'   and mmucr1_q(0)='0' and lru_op_vec(8)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(8);
lru_eff(8) <=  (lru_vp_vec(8)   and lru_op_vec(8))   or (lru_q(8)   and not lru_op_vec(8));
lru_d(9) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(9)='1'   and mmucr1_q(0)='0' and lru_op_vec(9)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(9)='1'   and mmucr1_q(0)='0' and lru_op_vec(9)='0'   and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(9);
lru_eff(9) <=  (lru_vp_vec(9)   and lru_op_vec(9))   or (lru_q(9)   and not lru_op_vec(9));
lru_d(10) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(10)='1'  and mmucr1_q(0)='0' and lru_op_vec(10)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(10)='1'  and mmucr1_q(0)='0' and lru_op_vec(10)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(10);
lru_eff(10) <=  (lru_vp_vec(10)  and lru_op_vec(10))  or (lru_q(10)  and not lru_op_vec(10));
lru_d(11) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(11)='1'  and mmucr1_q(0)='0' and lru_op_vec(11)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(11)='1'  and mmucr1_q(0)='0' and lru_op_vec(11)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(11);
lru_eff(11) <=  (lru_vp_vec(11)  and lru_op_vec(11))  or (lru_q(11)  and not lru_op_vec(11));
lru_d(12) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(12)='1'  and mmucr1_q(0)='0' and lru_op_vec(12)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(12)='1'  and mmucr1_q(0)='0' and lru_op_vec(12)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(12);
lru_eff(12) <=  (lru_vp_vec(12)  and lru_op_vec(12))  or (lru_q(12)  and not lru_op_vec(12));
lru_d(13) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(13)='1'  and mmucr1_q(0)='0' and lru_op_vec(13)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(13)='1'  and mmucr1_q(0)='0' and lru_op_vec(13)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(13);
lru_eff(13) <=  (lru_vp_vec(13)  and lru_op_vec(13))  or (lru_q(13)  and not lru_op_vec(13));
lru_d(14) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(14)='1'  and mmucr1_q(0)='0' and lru_op_vec(14)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(14)='1'  and mmucr1_q(0)='0' and lru_op_vec(14)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(14);
lru_eff(14) <=  (lru_vp_vec(14)  and lru_op_vec(14))  or (lru_q(14)  and not lru_op_vec(14));
lru_d(15) <=  '0' when ((ex6_ieratwe_ws3='1' and mmucr1_q(0)='0') or flash_invalidate='1') 
        else  '0' when lru_reset_vec(15)='1'  and mmucr1_q(0)='0' and lru_op_vec(15)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1')
        else  '1' when lru_set_vec(15)='1'  and mmucr1_q(0)='0' and lru_op_vec(15)='0'  and ccr2_frat_paranoia_q(9)='0' and 
                            (lru_update_event_q(8)='1' or (lru_update_event_q(4) and not(iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig))='1') 
        else lru_q(15);
lru_eff(15) <=  (lru_vp_vec(15)  and lru_op_vec(15))  or (lru_q(15)  and not lru_op_vec(15));
lru_op_vec(1) <=  (lru_rmt_vec(0) or lru_rmt_vec(1) or lru_rmt_vec(2) or lru_rmt_vec(3) or 
                      lru_rmt_vec(4) or lru_rmt_vec(5) or lru_rmt_vec(6) or lru_rmt_vec(7)) xor 
                 (lru_rmt_vec(8) or lru_rmt_vec(9) or lru_rmt_vec(10) or lru_rmt_vec(11) or 
                      lru_rmt_vec(12) or lru_rmt_vec(13) or lru_rmt_vec(14) or lru_rmt_vec(15));
lru_op_vec(2) <=  (lru_rmt_vec(0) or lru_rmt_vec(1) or lru_rmt_vec(2) or lru_rmt_vec(3)) xor 
                      (lru_rmt_vec(4) or lru_rmt_vec(5) or lru_rmt_vec(6) or lru_rmt_vec(7));
lru_op_vec(3) <=  (lru_rmt_vec(8) or lru_rmt_vec(9) or lru_rmt_vec(10) or lru_rmt_vec(11)) xor 
                      (lru_rmt_vec(12) or lru_rmt_vec(13) or lru_rmt_vec(14) or lru_rmt_vec(15));
lru_op_vec(4) <=  (lru_rmt_vec(0) or lru_rmt_vec(1)) xor (lru_rmt_vec(2) or lru_rmt_vec(3));
lru_op_vec(5) <=  (lru_rmt_vec(4) or lru_rmt_vec(5)) xor (lru_rmt_vec(6) or lru_rmt_vec(7));
lru_op_vec(6) <=  (lru_rmt_vec(8) or lru_rmt_vec(9)) xor (lru_rmt_vec(10) or lru_rmt_vec(11));
lru_op_vec(7) <=  (lru_rmt_vec(12) or lru_rmt_vec(13)) xor (lru_rmt_vec(14) or lru_rmt_vec(15));
lru_op_vec(8) <=  lru_rmt_vec(0) xor lru_rmt_vec(1);
lru_op_vec(9) <=  lru_rmt_vec(2) xor lru_rmt_vec(3);
lru_op_vec(10) <=  lru_rmt_vec(4) xor lru_rmt_vec(5);
lru_op_vec(11) <=  lru_rmt_vec(6) xor lru_rmt_vec(7);
lru_op_vec(12) <=  lru_rmt_vec(8) xor lru_rmt_vec(9);
lru_op_vec(13) <=  lru_rmt_vec(10) xor lru_rmt_vec(11);
lru_op_vec(14) <=  lru_rmt_vec(12) xor lru_rmt_vec(13);
lru_op_vec(15) <=  lru_rmt_vec(14) xor lru_rmt_vec(15);
lru_vp_vec(1) <=  (lru_rmt_vec(8) or lru_rmt_vec(9) or lru_rmt_vec(10) or lru_rmt_vec(11) or 
                      lru_rmt_vec(12) or lru_rmt_vec(13) or lru_rmt_vec(14) or lru_rmt_vec(15));
lru_vp_vec(2) <=  (lru_rmt_vec(4) or lru_rmt_vec(5) or lru_rmt_vec(6) or lru_rmt_vec(7));
lru_vp_vec(3) <=  (lru_rmt_vec(12) or lru_rmt_vec(13) or lru_rmt_vec(14) or lru_rmt_vec(15));
lru_vp_vec(4) <=  (lru_rmt_vec(2) or lru_rmt_vec(3));
lru_vp_vec(5) <=  (lru_rmt_vec(6) or lru_rmt_vec(7));
lru_vp_vec(6) <=  (lru_rmt_vec(10) or lru_rmt_vec(11));
lru_vp_vec(7) <=  (lru_rmt_vec(14) or lru_rmt_vec(15));
lru_vp_vec(8) <=  lru_rmt_vec(1);
lru_vp_vec(9) <=  lru_rmt_vec(3);
lru_vp_vec(10) <=  lru_rmt_vec(5);
lru_vp_vec(11) <=  lru_rmt_vec(7);
lru_vp_vec(12) <=  lru_rmt_vec(9);
lru_vp_vec(13) <=  lru_rmt_vec(11);
lru_vp_vec(14) <=  lru_rmt_vec(13);
lru_vp_vec(15) <=  lru_rmt_vec(15);
MQQ37:LRU_RMT_VEC_PT(1) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(1) & 
    WATERMARK_Q(2) & WATERMARK_Q(3)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ38:LRU_RMT_VEC_PT(2) <=
    Eq(( WATERMARK_Q(1) & WATERMARK_Q(2) & 
    WATERMARK_Q(3) ) , STD_ULOGIC_VECTOR'("111"));
MQQ39:LRU_RMT_VEC_PT(3) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(2) & 
    WATERMARK_Q(3) ) , STD_ULOGIC_VECTOR'("111"));
MQQ40:LRU_RMT_VEC_PT(4) <=
    Eq(( WATERMARK_Q(2) & WATERMARK_Q(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ41:LRU_RMT_VEC_PT(5) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(1) & 
    WATERMARK_Q(3) ) , STD_ULOGIC_VECTOR'("111"));
MQQ42:LRU_RMT_VEC_PT(6) <=
    Eq(( WATERMARK_Q(1) & WATERMARK_Q(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ43:LRU_RMT_VEC_PT(7) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ44:LRU_RMT_VEC_PT(8) <=
    Eq(( WATERMARK_Q(3) ) , STD_ULOGIC'('1'));
MQQ45:LRU_RMT_VEC_PT(9) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(1) & 
    WATERMARK_Q(2) ) , STD_ULOGIC_VECTOR'("111"));
MQQ46:LRU_RMT_VEC_PT(10) <=
    Eq(( WATERMARK_Q(1) & WATERMARK_Q(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ47:LRU_RMT_VEC_PT(11) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ48:LRU_RMT_VEC_PT(12) <=
    Eq(( WATERMARK_Q(2) ) , STD_ULOGIC'('1'));
MQQ49:LRU_RMT_VEC_PT(13) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(1)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ50:LRU_RMT_VEC_PT(14) <=
    Eq(( WATERMARK_Q(1) ) , STD_ULOGIC'('1'));
MQQ51:LRU_RMT_VEC_PT(15) <=
    Eq(( WATERMARK_Q(0) ) , STD_ULOGIC'('1'));
MQQ52:LRU_RMT_VEC_PT(16) <=
    Eq(( MMUCR1_Q(0) ) , STD_ULOGIC'('1'));
MQQ53:LRU_RMT_VEC_PT(17) <=
    '1';
MQQ54:LRU_RMT_VEC(0) <= 
    (LRU_RMT_VEC_PT(17));
MQQ55:LRU_RMT_VEC(1) <= 
    (LRU_RMT_VEC_PT(8) OR LRU_RMT_VEC_PT(12)
     OR LRU_RMT_VEC_PT(14) OR LRU_RMT_VEC_PT(15)
     OR LRU_RMT_VEC_PT(16));
MQQ56:LRU_RMT_VEC(2) <= 
    (LRU_RMT_VEC_PT(12) OR LRU_RMT_VEC_PT(14)
     OR LRU_RMT_VEC_PT(15) OR LRU_RMT_VEC_PT(16)
    );
MQQ57:LRU_RMT_VEC(3) <= 
    (LRU_RMT_VEC_PT(4) OR LRU_RMT_VEC_PT(14)
     OR LRU_RMT_VEC_PT(15) OR LRU_RMT_VEC_PT(16)
    );
MQQ58:LRU_RMT_VEC(4) <= 
    (LRU_RMT_VEC_PT(14) OR LRU_RMT_VEC_PT(15)
     OR LRU_RMT_VEC_PT(16));
MQQ59:LRU_RMT_VEC(5) <= 
    (LRU_RMT_VEC_PT(6) OR LRU_RMT_VEC_PT(10)
     OR LRU_RMT_VEC_PT(15) OR LRU_RMT_VEC_PT(16)
    );
MQQ60:LRU_RMT_VEC(6) <= 
    (LRU_RMT_VEC_PT(10) OR LRU_RMT_VEC_PT(15)
     OR LRU_RMT_VEC_PT(16));
MQQ61:LRU_RMT_VEC(7) <= 
    (LRU_RMT_VEC_PT(2) OR LRU_RMT_VEC_PT(15)
     OR LRU_RMT_VEC_PT(16));
MQQ62:LRU_RMT_VEC(8) <= 
    (LRU_RMT_VEC_PT(15) OR LRU_RMT_VEC_PT(16)
    );
MQQ63:LRU_RMT_VEC(9) <= 
    (LRU_RMT_VEC_PT(7) OR LRU_RMT_VEC_PT(11)
     OR LRU_RMT_VEC_PT(13) OR LRU_RMT_VEC_PT(16)
    );
MQQ64:LRU_RMT_VEC(10) <= 
    (LRU_RMT_VEC_PT(11) OR LRU_RMT_VEC_PT(13)
     OR LRU_RMT_VEC_PT(16));
MQQ65:LRU_RMT_VEC(11) <= 
    (LRU_RMT_VEC_PT(3) OR LRU_RMT_VEC_PT(13)
     OR LRU_RMT_VEC_PT(16));
MQQ66:LRU_RMT_VEC(12) <= 
    (LRU_RMT_VEC_PT(13) OR LRU_RMT_VEC_PT(16)
    );
MQQ67:LRU_RMT_VEC(13) <= 
    (LRU_RMT_VEC_PT(5) OR LRU_RMT_VEC_PT(9)
     OR LRU_RMT_VEC_PT(16));
MQQ68:LRU_RMT_VEC(14) <= 
    (LRU_RMT_VEC_PT(9) OR LRU_RMT_VEC_PT(16)
    );
MQQ69:LRU_RMT_VEC(15) <= 
    (LRU_RMT_VEC_PT(1) OR LRU_RMT_VEC_PT(16)
    );

MQQ70:LRU_WATERMARK_MASK_PT(1) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(1) & 
    WATERMARK_Q(2) & WATERMARK_Q(3)
     ) , STD_ULOGIC_VECTOR'("0000"));
MQQ71:LRU_WATERMARK_MASK_PT(2) <=
    Eq(( WATERMARK_Q(1) & WATERMARK_Q(2) & 
    WATERMARK_Q(3) ) , STD_ULOGIC_VECTOR'("000"));
MQQ72:LRU_WATERMARK_MASK_PT(3) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(2) & 
    WATERMARK_Q(3) ) , STD_ULOGIC_VECTOR'("000"));
MQQ73:LRU_WATERMARK_MASK_PT(4) <=
    Eq(( WATERMARK_Q(2) & WATERMARK_Q(3)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ74:LRU_WATERMARK_MASK_PT(5) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(1) & 
    WATERMARK_Q(3) ) , STD_ULOGIC_VECTOR'("000"));
MQQ75:LRU_WATERMARK_MASK_PT(6) <=
    Eq(( WATERMARK_Q(1) & WATERMARK_Q(3)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ76:LRU_WATERMARK_MASK_PT(7) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(3)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ77:LRU_WATERMARK_MASK_PT(8) <=
    Eq(( WATERMARK_Q(3) ) , STD_ULOGIC'('0'));
MQQ78:LRU_WATERMARK_MASK_PT(9) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(1) & 
    WATERMARK_Q(2) ) , STD_ULOGIC_VECTOR'("000"));
MQQ79:LRU_WATERMARK_MASK_PT(10) <=
    Eq(( WATERMARK_Q(1) & WATERMARK_Q(2)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ80:LRU_WATERMARK_MASK_PT(11) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(2)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ81:LRU_WATERMARK_MASK_PT(12) <=
    Eq(( WATERMARK_Q(2) ) , STD_ULOGIC'('0'));
MQQ82:LRU_WATERMARK_MASK_PT(13) <=
    Eq(( WATERMARK_Q(0) & WATERMARK_Q(1)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ83:LRU_WATERMARK_MASK_PT(14) <=
    Eq(( WATERMARK_Q(1) ) , STD_ULOGIC'('0'));
MQQ84:LRU_WATERMARK_MASK_PT(15) <=
    Eq(( WATERMARK_Q(0) ) , STD_ULOGIC'('0'));
MQQ85:LRU_WATERMARK_MASK(0) <= 
    ('0');
MQQ86:LRU_WATERMARK_MASK(1) <= 
    (LRU_WATERMARK_MASK_PT(1));
MQQ87:LRU_WATERMARK_MASK(2) <= 
    (LRU_WATERMARK_MASK_PT(9));
MQQ88:LRU_WATERMARK_MASK(3) <= 
    (LRU_WATERMARK_MASK_PT(5) OR LRU_WATERMARK_MASK_PT(9)
    );
MQQ89:LRU_WATERMARK_MASK(4) <= 
    (LRU_WATERMARK_MASK_PT(13));
MQQ90:LRU_WATERMARK_MASK(5) <= 
    (LRU_WATERMARK_MASK_PT(3) OR LRU_WATERMARK_MASK_PT(13)
    );
MQQ91:LRU_WATERMARK_MASK(6) <= 
    (LRU_WATERMARK_MASK_PT(11) OR LRU_WATERMARK_MASK_PT(13)
    );
MQQ92:LRU_WATERMARK_MASK(7) <= 
    (LRU_WATERMARK_MASK_PT(7) OR LRU_WATERMARK_MASK_PT(11)
     OR LRU_WATERMARK_MASK_PT(13));
MQQ93:LRU_WATERMARK_MASK(8) <= 
    (LRU_WATERMARK_MASK_PT(15));
MQQ94:LRU_WATERMARK_MASK(9) <= 
    (LRU_WATERMARK_MASK_PT(2) OR LRU_WATERMARK_MASK_PT(15)
    );
MQQ95:LRU_WATERMARK_MASK(10) <= 
    (LRU_WATERMARK_MASK_PT(10) OR LRU_WATERMARK_MASK_PT(15)
    );
MQQ96:LRU_WATERMARK_MASK(11) <= 
    (LRU_WATERMARK_MASK_PT(6) OR LRU_WATERMARK_MASK_PT(10)
     OR LRU_WATERMARK_MASK_PT(15));
MQQ97:LRU_WATERMARK_MASK(12) <= 
    (LRU_WATERMARK_MASK_PT(14) OR LRU_WATERMARK_MASK_PT(15)
    );
MQQ98:LRU_WATERMARK_MASK(13) <= 
    (LRU_WATERMARK_MASK_PT(4) OR LRU_WATERMARK_MASK_PT(14)
     OR LRU_WATERMARK_MASK_PT(15));
MQQ99:LRU_WATERMARK_MASK(14) <= 
    (LRU_WATERMARK_MASK_PT(12) OR LRU_WATERMARK_MASK_PT(14)
     OR LRU_WATERMARK_MASK_PT(15));
MQQ100:LRU_WATERMARK_MASK(15) <= 
    (LRU_WATERMARK_MASK_PT(8) OR LRU_WATERMARK_MASK_PT(12)
     OR LRU_WATERMARK_MASK_PT(14) OR LRU_WATERMARK_MASK_PT(15)
    );

entry_valid_watermarked  <=  entry_valid_q or lru_watermark_mask;
MQQ101:LRU_SET_RESET_VEC_PT(1) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14) & 
    ENTRY_MATCH_Q(15) ) , STD_ULOGIC_VECTOR'("00111111111111111110000000000000001"));
MQQ102:LRU_SET_RESET_VEC_PT(2) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) & ENTRY_MATCH_Q(14)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111000000000000001"));
MQQ103:LRU_SET_RESET_VEC_PT(3) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_MATCH_Q(0) & ENTRY_MATCH_Q(1) & 
    ENTRY_MATCH_Q(2) & ENTRY_MATCH_Q(3) & 
    ENTRY_MATCH_Q(4) & ENTRY_MATCH_Q(5) & 
    ENTRY_MATCH_Q(6) & ENTRY_MATCH_Q(7) & 
    ENTRY_MATCH_Q(8) & ENTRY_MATCH_Q(9) & 
    ENTRY_MATCH_Q(10) & ENTRY_MATCH_Q(11) & 
    ENTRY_MATCH_Q(12) & ENTRY_MATCH_Q(13) & 
    ENTRY_MATCH_Q(14) ) , STD_ULOGIC_VECTOR'("001111111111111111000000000000001"));
MQQ104:LRU_SET_RESET_VEC_PT(4) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12) & 
    ENTRY_MATCH_Q(13) ) , STD_ULOGIC_VECTOR'("001111111111111111100000000000001"));
MQQ105:LRU_SET_RESET_VEC_PT(5) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(13)
     ) , STD_ULOGIC_VECTOR'("001111111111111110000000000001"));
MQQ106:LRU_SET_RESET_VEC_PT(6) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) & ENTRY_MATCH_Q(12)
     ) , STD_ULOGIC_VECTOR'("00111111111111111110000000000001"));
MQQ107:LRU_SET_RESET_VEC_PT(7) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10) & 
    ENTRY_MATCH_Q(11) ) , STD_ULOGIC_VECTOR'("0011111111111111111000000000001"));
MQQ108:LRU_SET_RESET_VEC_PT(8) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(11)
     ) , STD_ULOGIC_VECTOR'("001111111111111000000001"));
MQQ109:LRU_SET_RESET_VEC_PT(9) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) & ENTRY_MATCH_Q(10)
     ) , STD_ULOGIC_VECTOR'("001111111111111111100000000001"));
MQQ110:LRU_SET_RESET_VEC_PT(10) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8) & 
    ENTRY_MATCH_Q(9) ) , STD_ULOGIC_VECTOR'("00111111111111111110000000001"));
MQQ111:LRU_SET_RESET_VEC_PT(11) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(9)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111000000001"));
MQQ112:LRU_SET_RESET_VEC_PT(12) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111000000001"));
MQQ113:LRU_SET_RESET_VEC_PT(13) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) & ENTRY_MATCH_Q(8)
     ) , STD_ULOGIC_VECTOR'("00111111111000000001"));
MQQ114:LRU_SET_RESET_VEC_PT(14) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6) & 
    ENTRY_MATCH_Q(7) ) , STD_ULOGIC_VECTOR'("001111111111111111100000001"));
MQQ115:LRU_SET_RESET_VEC_PT(15) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_MATCH_Q(7)
     ) , STD_ULOGIC_VECTOR'("001111111111"));
MQQ116:LRU_SET_RESET_VEC_PT(16) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) & ENTRY_MATCH_Q(6)
     ) , STD_ULOGIC_VECTOR'("00111111111111111110000001"));
MQQ117:LRU_SET_RESET_VEC_PT(17) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4) & 
    ENTRY_MATCH_Q(5) ) , STD_ULOGIC_VECTOR'("0011111111111111111000001"));
MQQ118:LRU_SET_RESET_VEC_PT(18) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(5)
     ) , STD_ULOGIC_VECTOR'("001111111111111111100001"));
MQQ119:LRU_SET_RESET_VEC_PT(19) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4)
     ) , STD_ULOGIC_VECTOR'("001111111111111111100001"));
MQQ120:LRU_SET_RESET_VEC_PT(20) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) & ENTRY_MATCH_Q(4)
     ) , STD_ULOGIC_VECTOR'("00111111111111100001"));
MQQ121:LRU_SET_RESET_VEC_PT(21) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2) & 
    ENTRY_MATCH_Q(3) ) , STD_ULOGIC_VECTOR'("00111111111111111110001"));
MQQ122:LRU_SET_RESET_VEC_PT(22) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(3)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111"));
MQQ123:LRU_SET_RESET_VEC_PT(23) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2)
     ) , STD_ULOGIC_VECTOR'("0011111111111111111001"));
MQQ124:LRU_SET_RESET_VEC_PT(24) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0) & 
    ENTRY_MATCH_Q(1) & ENTRY_MATCH_Q(2)
     ) , STD_ULOGIC_VECTOR'("00111111111111111001"));
MQQ125:LRU_SET_RESET_VEC_PT(25) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    ENTRY_MATCH_Q(0) & ENTRY_MATCH_Q(1)
     ) , STD_ULOGIC_VECTOR'("00111111111111111101"));
MQQ126:LRU_SET_RESET_VEC_PT(26) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(1)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111"));
MQQ127:LRU_SET_RESET_VEC_PT(27) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & LRU_UPDATE_EVENT_Q(6) & 
    LRU_UPDATE_EVENT_Q(7) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & ENTRY_MATCH_Q(0)
     ) , STD_ULOGIC_VECTOR'("00111111111111111111"));
MQQ128:LRU_SET_RESET_VEC_PT(28) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(15)
     ) , STD_ULOGIC_VECTOR'("11111111111111111110"));
MQQ129:LRU_SET_RESET_VEC_PT(29) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(15)
     ) , STD_ULOGIC_VECTOR'("11111111111111111111"));
MQQ130:LRU_SET_RESET_VEC_PT(30) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(14)
     ) , STD_ULOGIC_VECTOR'("11111111111111111100"));
MQQ131:LRU_SET_RESET_VEC_PT(31) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(7) & LRU_Q(14)
     ) , STD_ULOGIC_VECTOR'("11111111111111111101"));
MQQ132:LRU_SET_RESET_VEC_PT(32) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(13)
     ) , STD_ULOGIC_VECTOR'("11111111111111111010"));
MQQ133:LRU_SET_RESET_VEC_PT(33) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(13)
     ) , STD_ULOGIC_VECTOR'("11111111111111111011"));
MQQ134:LRU_SET_RESET_VEC_PT(34) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(12)
     ) , STD_ULOGIC_VECTOR'("11111111111111111000"));
MQQ135:LRU_SET_RESET_VEC_PT(35) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(3) & 
    LRU_Q(6) & LRU_Q(12)
     ) , STD_ULOGIC_VECTOR'("11111111111111111001"));
MQQ136:LRU_SET_RESET_VEC_PT(36) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(11)
     ) , STD_ULOGIC_VECTOR'("11111111111111110110"));
MQQ137:LRU_SET_RESET_VEC_PT(37) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(11)
     ) , STD_ULOGIC_VECTOR'("11111111111111110111"));
MQQ138:LRU_SET_RESET_VEC_PT(38) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(10)
     ) , STD_ULOGIC_VECTOR'("11111111111111110100"));
MQQ139:LRU_SET_RESET_VEC_PT(39) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(5) & LRU_Q(10)
     ) , STD_ULOGIC_VECTOR'("11111111111111110101"));
MQQ140:LRU_SET_RESET_VEC_PT(40) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(9)
     ) , STD_ULOGIC_VECTOR'("11111111111111110010"));
MQQ141:LRU_SET_RESET_VEC_PT(41) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(9)
     ) , STD_ULOGIC_VECTOR'("11111111111111110011"));
MQQ142:LRU_SET_RESET_VEC_PT(42) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(8)
     ) , STD_ULOGIC_VECTOR'("11111111111111110000"));
MQQ143:LRU_SET_RESET_VEC_PT(43) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15) & 
    LRU_Q(1) & LRU_Q(2) & 
    LRU_Q(4) & LRU_Q(8)
     ) , STD_ULOGIC_VECTOR'("11111111111111110001"));
MQQ144:LRU_SET_RESET_VEC_PT(44) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(7)
     ) , STD_ULOGIC_VECTOR'("111111111111111110"));
MQQ145:LRU_SET_RESET_VEC_PT(45) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(7)
     ) , STD_ULOGIC_VECTOR'("111111111111111111"));
MQQ146:LRU_SET_RESET_VEC_PT(46) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(6)
     ) , STD_ULOGIC_VECTOR'("111111111111111100"));
MQQ147:LRU_SET_RESET_VEC_PT(47) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1) & 
    LRU_Q(3) & LRU_Q(6)
     ) , STD_ULOGIC_VECTOR'("111111111111111101"));
MQQ148:LRU_SET_RESET_VEC_PT(48) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(5)
     ) , STD_ULOGIC_VECTOR'("111111111111111010"));
MQQ149:LRU_SET_RESET_VEC_PT(49) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(5)
     ) , STD_ULOGIC_VECTOR'("111111111111111011"));
MQQ150:LRU_SET_RESET_VEC_PT(50) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(4)
     ) , STD_ULOGIC_VECTOR'("111111111111111000"));
MQQ151:LRU_SET_RESET_VEC_PT(51) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1) & 
    LRU_Q(2) & LRU_Q(4)
     ) , STD_ULOGIC_VECTOR'("111111111111111001"));
MQQ152:LRU_SET_RESET_VEC_PT(52) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & LRU_Q(1) & 
    LRU_Q(3) ) , STD_ULOGIC_VECTOR'("111111111111110"));
MQQ153:LRU_SET_RESET_VEC_PT(53) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1) & 
    LRU_Q(3) ) , STD_ULOGIC_VECTOR'("111111111111111"));
MQQ154:LRU_SET_RESET_VEC_PT(54) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1) & 
    LRU_Q(2) ) , STD_ULOGIC_VECTOR'("111111111111100"));
MQQ155:LRU_SET_RESET_VEC_PT(55) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1) & 
    LRU_Q(2) ) , STD_ULOGIC_VECTOR'("111111111111101"));
MQQ156:LRU_SET_RESET_VEC_PT(56) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(0) & 
    ENTRY_VALID_WATERMARKED(1) & ENTRY_VALID_WATERMARKED(2) & 
    ENTRY_VALID_WATERMARKED(3) & ENTRY_VALID_WATERMARKED(4) & 
    ENTRY_VALID_WATERMARKED(5) & ENTRY_VALID_WATERMARKED(6) & 
    ENTRY_VALID_WATERMARKED(7) & LRU_Q(1)
     ) , STD_ULOGIC_VECTOR'("1111111110"));
MQQ157:LRU_SET_RESET_VEC_PT(57) <=
    Eq(( LRU_UPDATE_EVENT_Q(5) & ENTRY_VALID_WATERMARKED(8) & 
    ENTRY_VALID_WATERMARKED(9) & ENTRY_VALID_WATERMARKED(10) & 
    ENTRY_VALID_WATERMARKED(11) & ENTRY_VALID_WATERMARKED(12) & 
    ENTRY_VALID_WATERMARKED(13) & ENTRY_VALID_WATERMARKED(14) & 
    ENTRY_VALID_WATERMARKED(15) & LRU_Q(1)
     ) , STD_ULOGIC_VECTOR'("1111111111"));
MQQ158:LRU_SET_RESET_VEC_PT(58) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) & ENTRY_VALID_WATERMARKED(15)
     ) , STD_ULOGIC_VECTOR'("1111111111111110"));
MQQ159:LRU_SET_RESET_VEC_PT(59) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13) & 
    ENTRY_VALID_WATERMARKED(14) ) , STD_ULOGIC_VECTOR'("111111111111110"));
MQQ160:LRU_SET_RESET_VEC_PT(60) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) & ENTRY_VALID_WATERMARKED(13)
     ) , STD_ULOGIC_VECTOR'("11111111111110"));
MQQ161:LRU_SET_RESET_VEC_PT(61) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(13) ) , STD_ULOGIC_VECTOR'("1111111111110"));
MQQ162:LRU_SET_RESET_VEC_PT(62) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11) & 
    ENTRY_VALID_WATERMARKED(12) ) , STD_ULOGIC_VECTOR'("1111111111110"));
MQQ163:LRU_SET_RESET_VEC_PT(63) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) & ENTRY_VALID_WATERMARKED(11)
     ) , STD_ULOGIC_VECTOR'("111111111110"));
MQQ164:LRU_SET_RESET_VEC_PT(64) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(11) ) , STD_ULOGIC_VECTOR'("111111110"));
MQQ165:LRU_SET_RESET_VEC_PT(65) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9) & 
    ENTRY_VALID_WATERMARKED(10) ) , STD_ULOGIC_VECTOR'("11111111110"));
MQQ166:LRU_SET_RESET_VEC_PT(66) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) & ENTRY_VALID_WATERMARKED(9)
     ) , STD_ULOGIC_VECTOR'("1111111110"));
MQQ167:LRU_SET_RESET_VEC_PT(67) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(9) ) , STD_ULOGIC_VECTOR'("111111110"));
MQQ168:LRU_SET_RESET_VEC_PT(68) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7) & 
    ENTRY_VALID_WATERMARKED(8) ) , STD_ULOGIC_VECTOR'("111111110"));
MQQ169:LRU_SET_RESET_VEC_PT(69) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) & ENTRY_VALID_WATERMARKED(7)
     ) , STD_ULOGIC_VECTOR'("11111110"));
MQQ170:LRU_SET_RESET_VEC_PT(70) <=
    Eq(( ENTRY_VALID_WATERMARKED(7) ) , STD_ULOGIC'('0'));
MQQ171:LRU_SET_RESET_VEC_PT(71) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5) & 
    ENTRY_VALID_WATERMARKED(6) ) , STD_ULOGIC_VECTOR'("1111110"));
MQQ172:LRU_SET_RESET_VEC_PT(72) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) & ENTRY_VALID_WATERMARKED(5)
     ) , STD_ULOGIC_VECTOR'("111110"));
MQQ173:LRU_SET_RESET_VEC_PT(73) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(5) ) , STD_ULOGIC_VECTOR'("11110"));
MQQ174:LRU_SET_RESET_VEC_PT(74) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3) & 
    ENTRY_VALID_WATERMARKED(4) ) , STD_ULOGIC_VECTOR'("11110"));
MQQ175:LRU_SET_RESET_VEC_PT(75) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) & ENTRY_VALID_WATERMARKED(3)
     ) , STD_ULOGIC_VECTOR'("1110"));
MQQ176:LRU_SET_RESET_VEC_PT(76) <=
    Eq(( ENTRY_VALID_WATERMARKED(3) ) , STD_ULOGIC'('0'));
MQQ177:LRU_SET_RESET_VEC_PT(77) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1) & 
    ENTRY_VALID_WATERMARKED(2) ) , STD_ULOGIC_VECTOR'("110"));
MQQ178:LRU_SET_RESET_VEC_PT(78) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) & ENTRY_VALID_WATERMARKED(1)
     ) , STD_ULOGIC_VECTOR'("10"));
MQQ179:LRU_SET_RESET_VEC_PT(79) <=
    Eq(( ENTRY_VALID_WATERMARKED(1) ) , STD_ULOGIC'('0'));
MQQ180:LRU_SET_RESET_VEC_PT(80) <=
    Eq(( ENTRY_VALID_WATERMARKED(0) ) , STD_ULOGIC'('0'));
MQQ181:LRU_RESET_VEC(1) <= 
    (LRU_SET_RESET_VEC_PT(1) OR LRU_SET_RESET_VEC_PT(2)
     OR LRU_SET_RESET_VEC_PT(4) OR LRU_SET_RESET_VEC_PT(6)
     OR LRU_SET_RESET_VEC_PT(7) OR LRU_SET_RESET_VEC_PT(9)
     OR LRU_SET_RESET_VEC_PT(10) OR LRU_SET_RESET_VEC_PT(13)
     OR LRU_SET_RESET_VEC_PT(57) OR LRU_SET_RESET_VEC_PT(70)
     OR LRU_SET_RESET_VEC_PT(71) OR LRU_SET_RESET_VEC_PT(73)
     OR LRU_SET_RESET_VEC_PT(74) OR LRU_SET_RESET_VEC_PT(76)
     OR LRU_SET_RESET_VEC_PT(77) OR LRU_SET_RESET_VEC_PT(79)
     OR LRU_SET_RESET_VEC_PT(80));
MQQ182:LRU_RESET_VEC(2) <= 
    (LRU_SET_RESET_VEC_PT(14) OR LRU_SET_RESET_VEC_PT(16)
     OR LRU_SET_RESET_VEC_PT(17) OR LRU_SET_RESET_VEC_PT(20)
     OR LRU_SET_RESET_VEC_PT(55) OR LRU_SET_RESET_VEC_PT(76)
     OR LRU_SET_RESET_VEC_PT(77) OR LRU_SET_RESET_VEC_PT(79)
     OR LRU_SET_RESET_VEC_PT(80));
MQQ183:LRU_RESET_VEC(3) <= 
    (LRU_SET_RESET_VEC_PT(1) OR LRU_SET_RESET_VEC_PT(2)
     OR LRU_SET_RESET_VEC_PT(4) OR LRU_SET_RESET_VEC_PT(6)
     OR LRU_SET_RESET_VEC_PT(53) OR LRU_SET_RESET_VEC_PT(64)
     OR LRU_SET_RESET_VEC_PT(65) OR LRU_SET_RESET_VEC_PT(67)
     OR LRU_SET_RESET_VEC_PT(68));
MQQ184:LRU_RESET_VEC(4) <= 
    (LRU_SET_RESET_VEC_PT(21) OR LRU_SET_RESET_VEC_PT(24)
     OR LRU_SET_RESET_VEC_PT(51) OR LRU_SET_RESET_VEC_PT(79)
     OR LRU_SET_RESET_VEC_PT(80));
MQQ185:LRU_RESET_VEC(5) <= 
    (LRU_SET_RESET_VEC_PT(14) OR LRU_SET_RESET_VEC_PT(16)
     OR LRU_SET_RESET_VEC_PT(49) OR LRU_SET_RESET_VEC_PT(73)
     OR LRU_SET_RESET_VEC_PT(74));
MQQ186:LRU_RESET_VEC(6) <= 
    (LRU_SET_RESET_VEC_PT(7) OR LRU_SET_RESET_VEC_PT(9)
     OR LRU_SET_RESET_VEC_PT(47) OR LRU_SET_RESET_VEC_PT(67)
     OR LRU_SET_RESET_VEC_PT(68));
MQQ187:LRU_RESET_VEC(7) <= 
    (LRU_SET_RESET_VEC_PT(1) OR LRU_SET_RESET_VEC_PT(2)
     OR LRU_SET_RESET_VEC_PT(45) OR LRU_SET_RESET_VEC_PT(61)
     OR LRU_SET_RESET_VEC_PT(62));
MQQ188:LRU_RESET_VEC(8) <= 
    (LRU_SET_RESET_VEC_PT(25) OR LRU_SET_RESET_VEC_PT(43)
     OR LRU_SET_RESET_VEC_PT(80));
MQQ189:LRU_RESET_VEC(9) <= 
    (LRU_SET_RESET_VEC_PT(21) OR LRU_SET_RESET_VEC_PT(41)
     OR LRU_SET_RESET_VEC_PT(77));
MQQ190:LRU_RESET_VEC(10) <= 
    (LRU_SET_RESET_VEC_PT(17) OR LRU_SET_RESET_VEC_PT(39)
     OR LRU_SET_RESET_VEC_PT(74));
MQQ191:LRU_RESET_VEC(11) <= 
    (LRU_SET_RESET_VEC_PT(14) OR LRU_SET_RESET_VEC_PT(37)
     OR LRU_SET_RESET_VEC_PT(71));
MQQ192:LRU_RESET_VEC(12) <= 
    (LRU_SET_RESET_VEC_PT(10) OR LRU_SET_RESET_VEC_PT(35)
     OR LRU_SET_RESET_VEC_PT(68));
MQQ193:LRU_RESET_VEC(13) <= 
    (LRU_SET_RESET_VEC_PT(7) OR LRU_SET_RESET_VEC_PT(33)
     OR LRU_SET_RESET_VEC_PT(65));
MQQ194:LRU_RESET_VEC(14) <= 
    (LRU_SET_RESET_VEC_PT(4) OR LRU_SET_RESET_VEC_PT(31)
     OR LRU_SET_RESET_VEC_PT(62));
MQQ195:LRU_RESET_VEC(15) <= 
    (LRU_SET_RESET_VEC_PT(1) OR LRU_SET_RESET_VEC_PT(29)
     OR LRU_SET_RESET_VEC_PT(59));
MQQ196:LRU_SET_VEC(1) <= 
    (LRU_SET_RESET_VEC_PT(15) OR LRU_SET_RESET_VEC_PT(16)
     OR LRU_SET_RESET_VEC_PT(18) OR LRU_SET_RESET_VEC_PT(19)
     OR LRU_SET_RESET_VEC_PT(22) OR LRU_SET_RESET_VEC_PT(23)
     OR LRU_SET_RESET_VEC_PT(26) OR LRU_SET_RESET_VEC_PT(27)
     OR LRU_SET_RESET_VEC_PT(56) OR LRU_SET_RESET_VEC_PT(58)
     OR LRU_SET_RESET_VEC_PT(59) OR LRU_SET_RESET_VEC_PT(60)
     OR LRU_SET_RESET_VEC_PT(62) OR LRU_SET_RESET_VEC_PT(63)
     OR LRU_SET_RESET_VEC_PT(65) OR LRU_SET_RESET_VEC_PT(66)
     OR LRU_SET_RESET_VEC_PT(68));
MQQ197:LRU_SET_VEC(2) <= 
    (LRU_SET_RESET_VEC_PT(22) OR LRU_SET_RESET_VEC_PT(23)
     OR LRU_SET_RESET_VEC_PT(26) OR LRU_SET_RESET_VEC_PT(27)
     OR LRU_SET_RESET_VEC_PT(54) OR LRU_SET_RESET_VEC_PT(69)
     OR LRU_SET_RESET_VEC_PT(71) OR LRU_SET_RESET_VEC_PT(72)
     OR LRU_SET_RESET_VEC_PT(74));
MQQ198:LRU_SET_VEC(3) <= 
    (LRU_SET_RESET_VEC_PT(8) OR LRU_SET_RESET_VEC_PT(9)
     OR LRU_SET_RESET_VEC_PT(11) OR LRU_SET_RESET_VEC_PT(12)
     OR LRU_SET_RESET_VEC_PT(52) OR LRU_SET_RESET_VEC_PT(58)
     OR LRU_SET_RESET_VEC_PT(59) OR LRU_SET_RESET_VEC_PT(60)
     OR LRU_SET_RESET_VEC_PT(62));
MQQ199:LRU_SET_VEC(4) <= 
    (LRU_SET_RESET_VEC_PT(26) OR LRU_SET_RESET_VEC_PT(27)
     OR LRU_SET_RESET_VEC_PT(50) OR LRU_SET_RESET_VEC_PT(75)
     OR LRU_SET_RESET_VEC_PT(77));
MQQ200:LRU_SET_VEC(5) <= 
    (LRU_SET_RESET_VEC_PT(18) OR LRU_SET_RESET_VEC_PT(19)
     OR LRU_SET_RESET_VEC_PT(48) OR LRU_SET_RESET_VEC_PT(69)
     OR LRU_SET_RESET_VEC_PT(71));
MQQ201:LRU_SET_VEC(6) <= 
    (LRU_SET_RESET_VEC_PT(11) OR LRU_SET_RESET_VEC_PT(12)
     OR LRU_SET_RESET_VEC_PT(46) OR LRU_SET_RESET_VEC_PT(63)
     OR LRU_SET_RESET_VEC_PT(65));
MQQ202:LRU_SET_VEC(7) <= 
    (LRU_SET_RESET_VEC_PT(5) OR LRU_SET_RESET_VEC_PT(6)
     OR LRU_SET_RESET_VEC_PT(44) OR LRU_SET_RESET_VEC_PT(58)
     OR LRU_SET_RESET_VEC_PT(59));
MQQ203:LRU_SET_VEC(8) <= 
    (LRU_SET_RESET_VEC_PT(27) OR LRU_SET_RESET_VEC_PT(42)
     OR LRU_SET_RESET_VEC_PT(78));
MQQ204:LRU_SET_VEC(9) <= 
    (LRU_SET_RESET_VEC_PT(23) OR LRU_SET_RESET_VEC_PT(40)
     OR LRU_SET_RESET_VEC_PT(75));
MQQ205:LRU_SET_VEC(10) <= 
    (LRU_SET_RESET_VEC_PT(19) OR LRU_SET_RESET_VEC_PT(38)
     OR LRU_SET_RESET_VEC_PT(72));
MQQ206:LRU_SET_VEC(11) <= 
    (LRU_SET_RESET_VEC_PT(16) OR LRU_SET_RESET_VEC_PT(36)
     OR LRU_SET_RESET_VEC_PT(69));
MQQ207:LRU_SET_VEC(12) <= 
    (LRU_SET_RESET_VEC_PT(12) OR LRU_SET_RESET_VEC_PT(34)
     OR LRU_SET_RESET_VEC_PT(66));
MQQ208:LRU_SET_VEC(13) <= 
    (LRU_SET_RESET_VEC_PT(9) OR LRU_SET_RESET_VEC_PT(32)
     OR LRU_SET_RESET_VEC_PT(63));
MQQ209:LRU_SET_VEC(14) <= 
    (LRU_SET_RESET_VEC_PT(6) OR LRU_SET_RESET_VEC_PT(30)
     OR LRU_SET_RESET_VEC_PT(60));
MQQ210:LRU_SET_VEC(15) <= 
    (LRU_SET_RESET_VEC_PT(3) OR LRU_SET_RESET_VEC_PT(28)
     OR LRU_SET_RESET_VEC_PT(58));

MQQ211:LRU_WAY_ENCODE_PT(1) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(7) & LRU_EFF(15)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ212:LRU_WAY_ENCODE_PT(2) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(7) & LRU_EFF(14)
     ) , STD_ULOGIC_VECTOR'("1101"));
MQQ213:LRU_WAY_ENCODE_PT(3) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(6) & LRU_EFF(13)
     ) , STD_ULOGIC_VECTOR'("1011"));
MQQ214:LRU_WAY_ENCODE_PT(4) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(6) & LRU_EFF(12)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ215:LRU_WAY_ENCODE_PT(5) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(5) & LRU_EFF(11)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ216:LRU_WAY_ENCODE_PT(6) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(5) & LRU_EFF(10)
     ) , STD_ULOGIC_VECTOR'("0101"));
MQQ217:LRU_WAY_ENCODE_PT(7) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(4) & LRU_EFF(9)
     ) , STD_ULOGIC_VECTOR'("0011"));
MQQ218:LRU_WAY_ENCODE_PT(8) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(4) & LRU_EFF(8)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ219:LRU_WAY_ENCODE_PT(9) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(7) ) , STD_ULOGIC_VECTOR'("111"));
MQQ220:LRU_WAY_ENCODE_PT(10) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3) & 
    LRU_EFF(6) ) , STD_ULOGIC_VECTOR'("101"));
MQQ221:LRU_WAY_ENCODE_PT(11) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(5) ) , STD_ULOGIC_VECTOR'("011"));
MQQ222:LRU_WAY_ENCODE_PT(12) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2) & 
    LRU_EFF(4) ) , STD_ULOGIC_VECTOR'("001"));
MQQ223:LRU_WAY_ENCODE_PT(13) <=
    Eq(( LRU_EFF(1) & LRU_EFF(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ224:LRU_WAY_ENCODE_PT(14) <=
    Eq(( LRU_EFF(1) & LRU_EFF(2)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ225:LRU_WAY_ENCODE_PT(15) <=
    Eq(( LRU_EFF(1) ) , STD_ULOGIC'('1'));
MQQ226:LRU_WAY_ENCODE(0) <= 
    (LRU_WAY_ENCODE_PT(15));
MQQ227:LRU_WAY_ENCODE(1) <= 
    (LRU_WAY_ENCODE_PT(13) OR LRU_WAY_ENCODE_PT(14)
    );
MQQ228:LRU_WAY_ENCODE(2) <= 
    (LRU_WAY_ENCODE_PT(9) OR LRU_WAY_ENCODE_PT(10)
     OR LRU_WAY_ENCODE_PT(11) OR LRU_WAY_ENCODE_PT(12)
    );
MQQ229:LRU_WAY_ENCODE(3) <= 
    (LRU_WAY_ENCODE_PT(1) OR LRU_WAY_ENCODE_PT(2)
     OR LRU_WAY_ENCODE_PT(3) OR LRU_WAY_ENCODE_PT(4)
     OR LRU_WAY_ENCODE_PT(5) OR LRU_WAY_ENCODE_PT(6)
     OR LRU_WAY_ENCODE_PT(7) OR LRU_WAY_ENCODE_PT(8)
    );

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
cam_pgsize(0 TO 2) <=  (CAM_PgSize_1GB  and (0 to 2 => Eq(ex6_data_in_q(56 to 59),WS0_PgSize_1GB)))
                  or (CAM_PgSize_16MB and (0 to 2 => Eq(ex6_data_in_q(56 to 59),WS0_PgSize_16MB)))
                  or (CAM_PgSize_1MB  and (0 to 2 => Eq(ex6_data_in_q(56 to 59),WS0_PgSize_1MB)))
                  or (CAM_PgSize_64KB and (0 to 2 => Eq(ex6_data_in_q(56 to 59),WS0_PgSize_64KB)))
                  or (CAM_PgSize_4KB and (0 to 2 => not(Eq(ex6_data_in_q(56 to 59),WS0_PgSize_1GB) or 
                                                        Eq(ex6_data_in_q(56 to 59),WS0_PgSize_16MB) or 
                                                        Eq(ex6_data_in_q(56 to 59),WS0_PgSize_1MB) or 
                                                        Eq(ex6_data_in_q(56 to 59),WS0_PgSize_64KB))));
ws0_pgsize(0 TO 3) <=  (WS0_PgSize_1GB  and (0 to 3 => Eq(rd_cam_data(53 to 55),CAM_PgSize_1GB)))
                   or (WS0_PgSize_16MB and (0 to 3 => Eq(rd_cam_data(53 to 55),CAM_PgSize_16MB)))
                   or (WS0_PgSize_1MB  and (0 to 3 => Eq(rd_cam_data(53 to 55),CAM_PgSize_1MB)))
                   or (WS0_PgSize_64KB and (0 to 3 => Eq(rd_cam_data(53 to 55),CAM_PgSize_64KB)))
                   or (WS0_PgSize_4KB  and (0 to 3 => Eq(rd_cam_data(53 to 55),CAM_PgSize_4KB)));
rd_val             <=  or_reduce(ex2_valid_q) and ex2_ttype_q(0) and Eq(ex2_tlbsel_q, TlbSel_IErat);
rw_entry           <=  ( por_wr_entry and (0 to 3 => or_reduce(por_seq_q)) )
               or (  eptr_q         and (0 to 3 => (or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4) and mmucr1_q(0))) )  
               or (  lru_way_encode and (0 to 3 => (or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4) and not mmucr1_q(0))) )  
               or (  eptr_q         and (0 to 3 => (or_reduce(ex6_valid_q) and ex6_ttype_q(1) and Eq(ex6_tlbsel_q, TlbSel_IErat) and not tlb_rel_val_q(4) and mmucr1_q(0))) )  
               or (  ex6_ra_entry_q and (0 to 3 => (or_reduce(ex6_valid_q) and ex6_ttype_q(1) and Eq(ex6_tlbsel_q, TlbSel_IErat) and not tlb_rel_val_q(4) and not mmucr1_q(0))) )  
               or (  ex2_ra_entry_q and (0 to 3 => (or_reduce(ex2_valid_q) and ex2_ttype_q(0) and not(or_reduce(ex6_valid_q) and ex6_ttype_q(1) and Eq(ex6_tlbsel_q, TlbSel_IErat)) and not tlb_rel_val_q(4))) );
wr_cam_val            <=  por_wr_cam_val  when por_seq_q/=PorSeq_Idle 
                     else (others => '0') when (ex6_valid_q/="0000" and ex6_ttype_q(4 to 5)/="00")  
                     else (others => tlb_rel_data_q(eratpos_wren)) when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1')  
                     else (others => '1') when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_IErat)   
                     else  (others => '0');
wr_val_early        <=  or_reduce(por_seq_q) or 
                      or_reduce(tlb_req_inprogress_q) or 
                       (or_reduce(ex5_valid_q) and ex5_ttype_q(1) and Eq(ex5_ws_q,"00") and Eq(ex5_tlbsel_q,TlbSel_IErat)) or  
                       (or_reduce(ex6_valid_q) and ex6_ttype_q(1) and Eq(ex6_ws_q,"00") and Eq(ex6_tlbsel_q,TlbSel_IErat));
gen64_wr_cam_data: if rs_data_width = 64 generate
wr_cam_data        <=  por_wr_cam_data when por_seq_q/=PorSeq_Idle 
              else (tlb_rel_data_q(0 to 64) & tlb_rel_data_q(122 to 131) & 
                     tlb_rel_cmpmask(0 to 3) & tlb_rel_xbitmask(0 to 3) & tlb_rel_maskpar )
                            when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1')  
               else  ( (ex6_data_in_q(0 to 31) and (0 to 31 => ex6_state_q(3))) & ex6_data_in_q(32 to 51) & ex6_data_in_q(55) & 
                          cam_pgsize(0 to 2) & ex6_data_in_q(54) & ex6_data_in_q(60 to 63) & ex6_data_in_q(52 to 53) & 
                            ex6_extclass_q & ex6_state_q(1 to 2) & ex6_pid_q(pid_width-8 to pid_width-1) & 
                              ex6_data_cmpmask(0 to 3) & ex6_data_xbitmask(0 to 3) & ex6_data_maskpar ) 
                               when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_ws_q="00")  
                else  (others => '0');
end generate gen64_wr_cam_data;
gen32_wr_cam_data: if rs_data_width = 32 generate
wr_cam_data        <=  por_wr_cam_data when por_seq_q/=PorSeq_Idle 
              else (tlb_rel_data_q(0 to 64) & tlb_rel_data_q(122 to 131) & 
                     tlb_rel_cmpmask(0 to 3) & tlb_rel_xbitmask(0 to 3) & tlb_rel_maskpar ) 
                            when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1')  
               else  ((0 to 31 => '0') & ex6_data_in_q(32 to 51) & ex6_data_in_q(55) & cam_pgsize(0 to 2) & ex6_data_in_q(54) & 
                          ex6_data_in_q(60 to 63) & ex6_data_in_q(52 to 53) & 
                            ex6_extclass_q & ex6_state_q(1 to 2) & ex6_pid_q(pid_width-8 to pid_width-1) & 
                              ex6_data_cmpmask(0 to 3) & ex6_data_xbitmask(0 to 3) & ex6_data_maskpar ) 
                               when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_ws_q="00")  
                else  (others => '0');
end generate gen32_wr_cam_data;
MQQ230:CAM_MASK_BITS_PT(1) <=
    Eq(( EX6_DATA_IN_Q(55) & EX6_DATA_IN_Q(56) & 
    EX6_DATA_IN_Q(57) & EX6_DATA_IN_Q(58) & 
    EX6_DATA_IN_Q(59) ) , STD_ULOGIC_VECTOR'("11010"));
MQQ231:CAM_MASK_BITS_PT(2) <=
    Eq(( EX6_DATA_IN_Q(56) & EX6_DATA_IN_Q(59)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ232:CAM_MASK_BITS_PT(3) <=
    Eq(( EX6_DATA_IN_Q(55) & EX6_DATA_IN_Q(56) & 
    EX6_DATA_IN_Q(57) & EX6_DATA_IN_Q(58) & 
    EX6_DATA_IN_Q(59) ) , STD_ULOGIC_VECTOR'("10101"));
MQQ233:CAM_MASK_BITS_PT(4) <=
    Eq(( EX6_DATA_IN_Q(55) & EX6_DATA_IN_Q(56) & 
    EX6_DATA_IN_Q(57) & EX6_DATA_IN_Q(58) & 
    EX6_DATA_IN_Q(59) ) , STD_ULOGIC_VECTOR'("10011"));
MQQ234:CAM_MASK_BITS_PT(5) <=
    Eq(( EX6_DATA_IN_Q(55) & EX6_DATA_IN_Q(56) & 
    EX6_DATA_IN_Q(57) & EX6_DATA_IN_Q(58) & 
    EX6_DATA_IN_Q(59) ) , STD_ULOGIC_VECTOR'("10111"));
MQQ235:CAM_MASK_BITS_PT(6) <=
    Eq(( EX6_DATA_IN_Q(55) & EX6_DATA_IN_Q(56) & 
    EX6_DATA_IN_Q(58) & EX6_DATA_IN_Q(59)
     ) , STD_ULOGIC_VECTOR'("0011"));
MQQ236:CAM_MASK_BITS_PT(7) <=
    Eq(( EX6_DATA_IN_Q(56) & EX6_DATA_IN_Q(59)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ237:CAM_MASK_BITS_PT(8) <=
    Eq(( EX6_DATA_IN_Q(57) & EX6_DATA_IN_Q(58)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ238:CAM_MASK_BITS_PT(9) <=
    Eq(( EX6_DATA_IN_Q(58) ) , STD_ULOGIC'('0'));
MQQ239:CAM_MASK_BITS_PT(10) <=
    Eq(( EX6_DATA_IN_Q(56) & EX6_DATA_IN_Q(57)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ240:CAM_MASK_BITS_PT(11) <=
    Eq(( EX6_DATA_IN_Q(56) & EX6_DATA_IN_Q(57)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ241:CAM_MASK_BITS_PT(12) <=
    Eq(( TLB_REL_DATA_Q(52) & TLB_REL_DATA_Q(55)
     ) , STD_ULOGIC_VECTOR'("10"));
MQQ242:CAM_MASK_BITS_PT(13) <=
    Eq(( TLB_REL_DATA_Q(52) & TLB_REL_DATA_Q(53) & 
    TLB_REL_DATA_Q(54) & TLB_REL_DATA_Q(55)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ243:CAM_MASK_BITS_PT(14) <=
    Eq(( TLB_REL_DATA_Q(52) & TLB_REL_DATA_Q(54) & 
    TLB_REL_DATA_Q(55) ) , STD_ULOGIC_VECTOR'("011"));
MQQ244:CAM_MASK_BITS_PT(15) <=
    Eq(( TLB_REL_DATA_Q(53) & TLB_REL_DATA_Q(54)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ245:CAM_MASK_BITS_PT(16) <=
    Eq(( TLB_REL_DATA_Q(52) & TLB_REL_DATA_Q(53) & 
    TLB_REL_DATA_Q(54) ) , STD_ULOGIC_VECTOR'("110"));
MQQ246:CAM_MASK_BITS_PT(17) <=
    Eq(( TLB_REL_DATA_Q(54) ) , STD_ULOGIC'('0'));
MQQ247:CAM_MASK_BITS_PT(18) <=
    Eq(( TLB_REL_DATA_Q(52) & TLB_REL_DATA_Q(53) & 
    TLB_REL_DATA_Q(54) ) , STD_ULOGIC_VECTOR'("101"));
MQQ248:CAM_MASK_BITS_PT(19) <=
    Eq(( TLB_REL_DATA_Q(53) ) , STD_ULOGIC'('0'));
MQQ249:TLB_REL_CMPMASK(0) <= 
    (CAM_MASK_BITS_PT(13) OR CAM_MASK_BITS_PT(14)
     OR CAM_MASK_BITS_PT(17) OR CAM_MASK_BITS_PT(18)
    );
MQQ250:TLB_REL_CMPMASK(1) <= 
    (CAM_MASK_BITS_PT(17) OR CAM_MASK_BITS_PT(19)
    );
MQQ251:TLB_REL_CMPMASK(2) <= 
    (CAM_MASK_BITS_PT(19));
MQQ252:TLB_REL_CMPMASK(3) <= 
    (CAM_MASK_BITS_PT(15));
MQQ253:TLB_REL_XBITMASK(0) <= 
    (CAM_MASK_BITS_PT(12));
MQQ254:TLB_REL_XBITMASK(1) <= 
    (CAM_MASK_BITS_PT(13));
MQQ255:TLB_REL_XBITMASK(2) <= 
    (CAM_MASK_BITS_PT(16));
MQQ256:TLB_REL_XBITMASK(3) <= 
    (CAM_MASK_BITS_PT(18));
MQQ257:TLB_REL_MASKPAR <= 
    (CAM_MASK_BITS_PT(12) OR CAM_MASK_BITS_PT(14)
     OR CAM_MASK_BITS_PT(16));
MQQ258:EX6_DATA_CMPMASK(0) <= 
    (CAM_MASK_BITS_PT(2) OR CAM_MASK_BITS_PT(4)
     OR CAM_MASK_BITS_PT(5) OR CAM_MASK_BITS_PT(6)
     OR CAM_MASK_BITS_PT(7) OR CAM_MASK_BITS_PT(9)
     OR CAM_MASK_BITS_PT(11));
MQQ259:EX6_DATA_CMPMASK(1) <= 
    (CAM_MASK_BITS_PT(2) OR CAM_MASK_BITS_PT(7)
     OR CAM_MASK_BITS_PT(9) OR CAM_MASK_BITS_PT(10)
     OR CAM_MASK_BITS_PT(11));
MQQ260:EX6_DATA_CMPMASK(2) <= 
    (CAM_MASK_BITS_PT(2) OR CAM_MASK_BITS_PT(7)
     OR CAM_MASK_BITS_PT(8) OR CAM_MASK_BITS_PT(10)
     OR CAM_MASK_BITS_PT(11));
MQQ261:EX6_DATA_CMPMASK(3) <= 
    (CAM_MASK_BITS_PT(2) OR CAM_MASK_BITS_PT(7)
     OR CAM_MASK_BITS_PT(8) OR CAM_MASK_BITS_PT(11)
    );
MQQ262:EX6_DATA_XBITMASK(0) <= 
    (CAM_MASK_BITS_PT(1));
MQQ263:EX6_DATA_XBITMASK(1) <= 
    (CAM_MASK_BITS_PT(5));
MQQ264:EX6_DATA_XBITMASK(2) <= 
    (CAM_MASK_BITS_PT(3));
MQQ265:EX6_DATA_XBITMASK(3) <= 
    (CAM_MASK_BITS_PT(4));
MQQ266:EX6_DATA_MASKPAR <= 
    (CAM_MASK_BITS_PT(1) OR CAM_MASK_BITS_PT(3)
     OR CAM_MASK_BITS_PT(6));

wr_array_val       <=  por_wr_array_val  when por_seq_q/=PorSeq_Idle
              else  (others => '0') when (ex6_valid_q/="0000" and ex6_ttype_q(4 to 5)/="00")  
               else  (others => tlb_rel_data_q(eratpos_wren)) 
                          when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1')  
                else  (others => '1') when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                              and ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_IErat)  
                 else  (others => '0');
wr_array_data_nopar       <=  por_wr_array_data(0 to 50) when por_seq_q/=PorSeq_Idle
                  else (tlb_rel_data_q(70 to 101) & tlb_rel_data_q(103 to 121)) 
                                when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1')   
                  else (rpn_holdreg0_q(22 to 51) & rpn_holdreg0_q(16 to 17) & rpn_holdreg0_q(8 to 10) & '0' & 
                             rpn_holdreg0_q(12 to 15) & rpn_holdreg0_q(52 to 56) & rpn_holdreg0_q(58 to 63)) 
                                  when (ex6_valid_q(0)='1' and ex6_ttype_q(1)='1' and ex6_ws_q="00")   
                  else (rpn_holdreg1_q(22 to 51) & rpn_holdreg1_q(16 to 17) & rpn_holdreg1_q(8 to 10) & '0' &
                             rpn_holdreg1_q(12 to 15) & rpn_holdreg1_q(52 to 56) & rpn_holdreg1_q(58 to 63)) 
                                  when (ex6_valid_q(1)='1' and ex6_ttype_q(1)='1' and ex6_ws_q="00")   
                  else (rpn_holdreg2_q(22 to 51) & rpn_holdreg2_q(16 to 17) & rpn_holdreg2_q(8 to 10) & '0' &
                             rpn_holdreg2_q(12 to 15) & rpn_holdreg2_q(52 to 56) & rpn_holdreg2_q(58 to 63)) 
                                  when (ex6_valid_q(2)='1' and ex6_ttype_q(1)='1' and ex6_ws_q="00")   
                  else (rpn_holdreg3_q(22 to 51) & rpn_holdreg3_q(16 to 17) & rpn_holdreg3_q(8 to 10) & '0' &
                             rpn_holdreg3_q(12 to 15) & rpn_holdreg3_q(52 to 56) & rpn_holdreg3_q(58 to 63)) 
                                  when (ex6_valid_q(3)='1' and ex6_ttype_q(1)='1' and ex6_ws_q="00")   
                  else  (others => '0');
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
unused_dc(22) <=  lcb_delay_lclkr_dc(1) or lcb_mpw1_dc_b(1);
iu2_cmp_data_calc_par(50) <=  xor_reduce(iu2_cam_cmp_data_q(75 to 82));
iu2_cmp_data_calc_par(51) <=  xor_reduce(iu2_cam_cmp_data_q(0 to 7));
iu2_cmp_data_calc_par(52) <=  xor_reduce(iu2_cam_cmp_data_q(8 to 15));
iu2_cmp_data_calc_par(53) <=  xor_reduce(iu2_cam_cmp_data_q(16 to 23));
iu2_cmp_data_calc_par(54) <=  xor_reduce(iu2_cam_cmp_data_q(24 to 31));
iu2_cmp_data_calc_par(55) <=  xor_reduce(iu2_cam_cmp_data_q(32 to 39));
iu2_cmp_data_calc_par(56) <=  xor_reduce(iu2_cam_cmp_data_q(40 to 47));
iu2_cmp_data_calc_par(57) <=  xor_reduce(iu2_cam_cmp_data_q(48 to 55));
iu2_cmp_data_calc_par(58) <=  xor_reduce(iu2_cam_cmp_data_q(57 to 62));
iu2_cmp_data_calc_par(59) <=  xor_reduce(iu2_cam_cmp_data_q(63 to 66));
iu2_cmp_data_calc_par(60) <=  xor_reduce(iu2_cam_cmp_data_q(67 to 74));
iu2_cmp_data_calc_par(61) <=  xor_reduce(iu2_array_cmp_data_q(0 to 5));
iu2_cmp_data_calc_par(62) <=  xor_reduce(iu2_array_cmp_data_q(6 to 13));
iu2_cmp_data_calc_par(63) <=  xor_reduce(iu2_array_cmp_data_q(14 to 21));
iu2_cmp_data_calc_par(64) <=  xor_reduce(iu2_array_cmp_data_q(22 to 29));
iu2_cmp_data_calc_par(65) <=  xor_reduce(iu2_array_cmp_data_q(30 to 37));
iu2_cmp_data_calc_par(66) <=  xor_reduce(iu2_array_cmp_data_q(38 to 44));
iu2_cmp_data_calc_par(67) <=  xor_reduce(iu2_array_cmp_data_q(45 to 50));
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
iu2_cmp_data_parerr_epn     <=  '0';
iu2_cmp_data_parerr_rpn     <=  '0';
end generate parerr_gen0;
parerr_gen1: if check_parity = 1 generate
iu2_cmp_data_parerr_epn      <=  or_reduce(iu2_cmp_data_calc_par(50 to 60) xor (iu2_cam_cmp_data_q(83) & iu2_array_cmp_data_q(51 to 60)));
iu2_cmp_data_parerr_rpn      <=  or_reduce(iu2_cmp_data_calc_par(61 to 67) xor iu2_array_cmp_data_q(61 to 67));
end generate parerr_gen1;
parerr_gen2: if check_parity = 0 generate
ex4_rd_data_parerr_epn      <=  '0';
ex4_rd_data_parerr_rpn      <=  '0';
end generate parerr_gen2;
parerr_gen3: if check_parity = 1 generate
ex4_rd_data_parerr_epn      <=  or_reduce(ex4_rd_data_calc_par(50 to 60) xor (ex4_rd_cam_data_q(83) & ex4_rd_array_data_q(51 to 60)));
ex4_rd_data_parerr_rpn      <=  or_reduce(ex4_rd_data_calc_par(61 to 67) xor ex4_rd_array_data_q(61 to 67));
end generate parerr_gen3;
flash_invalidate                <=   Eq(por_seq_q,PorSeq_Stg1) or mchk_flash_inv_enab;
comp_invalidate                 <=  '1' when (ex6_valid_q/="0000" and ex6_ttype_q(4 to 5)/="00")  
                             else '0' when (tlb_rel_val_q(0 to 3)/="0000" and tlb_rel_val_q(4)='1')   
                             else '1' when snoop_val_q(0 to 1)="11"  
                             else '0';
comp_request                    <=  ( or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5)) )  
                             or ( snoop_val_q(0) and snoop_val_q(1) and not(or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4)) )  
                             or ( ex1_ieratsx ) 
                             or ( iu_ierat_iu0_val );
gen64_comp_addr: if rs_data_width = 64 generate
comp_addr_mux1   <=  ( snoop_addr_q and (52-epn_width to 51 => (snoop_val_q(0) and snoop_val_q(1))) ) 
                or ( xu_iu_ex1_rb and (64-rs_data_width to 51 => (not(snoop_val_q(0) and snoop_val_q(1)) and ex1_ieratsx)) );
comp_addr_mux1_sel   <=  (snoop_val_q(0) and snoop_val_q(1)) or (ex1_ieratsx and snoop_val_q(1));
comp_addr        <=  ( comp_addr_mux1 and (52-epn_width to 51 => comp_addr_mux1_sel) ) or 
                    ( iu_ierat_iu0_ifar and (52-epn_width to 51 => not comp_addr_mux1_sel) );
end generate gen64_comp_addr;
iu_xu_ierat_ex2_flush_d  <=  ( ex1_valid_q and not(xu_ex1_flush) and (0 to 3 => (ex1_ieratsx and not snoop_val_q(1))) ) 
                         or ( ex1_valid_q and not(xu_ex1_flush) and (0 to 3 => ((ex1_ieratre or ex1_ieratwe or ex1_ieratsx) and tlb_rel_data_q(eratpos_relsoon))) );
iu_xu_ierat_ex2_flush_req  <=  iu_xu_ierat_ex2_flush_q;
gen32_comp_addr: if rs_data_width = 32 generate
comp_addr_mux1   <=  ( ((0 to 31 => '0') & snoop_addr_q) and (52-epn_width to 51 => (snoop_val_q(0) and snoop_val_q(1))) ) 
                or ( ((0 to 31 => '0') & xu_iu_ex1_rb) and (64-rs_data_width to 51 => (not(snoop_val_q(0) and snoop_val_q(1)) and ex1_ieratsx)) );
comp_addr_mux1_sel   <=  (snoop_val_q(0) and snoop_val_q(1)) or ex1_ieratsx;
comp_addr            <=  ( comp_addr_mux1 and (0 to 51 => comp_addr_mux1_sel) ) 
                    or ( ((0 to 31 => '0') & iu_ierat_iu0_ifar(32 to 51)) and (0 to 51 => not comp_addr_mux1_sel) );
end generate gen32_comp_addr;
addr_enable(0) <=   not(or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5))) and    
                    ( (snoop_val_q(0) and snoop_val_q(1) and not snoop_attr_q(1) and snoop_attr_q(2) and snoop_attr_q(3))  
                   or (or_reduce(ex1_valid_q) and ex1_ttype_q(2) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1) and not(snoop_val_q(0) and snoop_val_q(1))) 
                   or (iu_ierat_iu0_val and not(snoop_val_q(0) and snoop_val_q(1))) );
addr_enable(1) <=   not(or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5))) and    
                    ( (snoop_val_q(0) and snoop_val_q(1) and snoop_attr_q(0) and not snoop_attr_q(1) and snoop_attr_q(2) and snoop_attr_q(3))  
                   or (or_reduce(ex1_valid_q) and ex1_ttype_q(2) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1) and not(snoop_val_q(0) and snoop_val_q(1))) 
                   or (iu_ierat_iu0_val and not(snoop_val_q(0) and snoop_val_q(1))) );
comp_pgsize          <=  CAM_PgSize_1GB  when snoop_attr_q(14 to 17)=WS0_PgSize_1GB
                 else  CAM_PgSize_16MB when snoop_attr_q(14 to 17)=WS0_PgSize_16MB
                 else  CAM_PgSize_1MB  when snoop_attr_q(14 to 17)=WS0_PgSize_1MB
                 else  CAM_PgSize_64KB when snoop_attr_q(14 to 17)=WS0_PgSize_64KB
                 else  CAM_PgSize_4KB;
pgsize_enable                   <=  '0' when (ex6_valid_q/="0000" and ex6_ttype_q(4 to 5)/="00")  
                             else '1' when (snoop_val_q(0 to 1)="11" and snoop_attr_q(0 to 3)="0011") 
                             else '0';
comp_class        <=  ( snoop_attr_q(20 to 21) and (0 to 1 => (snoop_val_q(0) and snoop_val_q(1) and mmucr1_q(7))) )      
                or  ( snoop_attr_q(2 to 3)   and (0 to 1 => (snoop_val_q(0) and snoop_val_q(1) and not mmucr1_q(7))) ) 
                or  ( ex1_pid_q(pid_width-14 to pid_width-13) and (0 to 1 => (not(snoop_val_q(0) and snoop_val_q(1)) and mmucr1_q(7) and ex1_ieratsx)) ) 
                or  ( iu1_pid_d(pid_width-14 to pid_width-13) and (0 to 1 => (not(snoop_val_q(0) and snoop_val_q(1)) and mmucr1_q(7) and not(ex1_ieratsx))) );
class_enable(0) <=  '0' when (mmucr1_q(7)='1')  
                else '0' when (ex6_valid_q/="0000" and ex6_ttype_q(4 to 5)/="00")  
                else '1' when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1)='1') 
                else '0';
class_enable(1) <=  '0' when (mmucr1_q(7)='1')  
                else '0' when (ex6_valid_q/="0000" and ex6_ttype_q(4 to 5)/="00")  
                else '1' when (snoop_val_q(0 to 1)="11" and snoop_attr_q(1)='1') 
                else '0';
class_enable(2) <=  '0' when (mmucr1_q(7)='0')  
                else pid_enable;
comp_extclass(0) <=  '0';
comp_extclass(1) <=  snoop_attr_q(19);
extclass_enable(0) <=  ( or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5)) )  
                               or ( snoop_val_q(0) and snoop_val_q(1) and snoop_attr_q(18) );
extclass_enable(1) <=  ( snoop_val_q(0) and snoop_val_q(1) and not snoop_attr_q(1) and snoop_attr_q(3) );
comp_state         <=  ( snoop_attr_q(4 to 5) and (0 to 1 => (snoop_val_q(0) and snoop_val_q(1) and not snoop_attr_q(1) and snoop_attr_q(2))) ) 
                  or ( ex1_state_q(1 to 2)  and (0 to 1 => (not(snoop_val_q(0) and snoop_val_q(1)) and ex1_ieratsx)) )  
                  or ( iu1_state_d(1 to 2)  and (0 to 1 => (not(snoop_val_q(0) and snoop_val_q(1)) and not ex1_ieratsx)) ) ;
state_enable(0) <=   not(or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5))) and    
                    ( (snoop_val_q(0) and snoop_val_q(1) and not snoop_attr_q(1) and snoop_attr_q(2) )  
                   or (or_reduce(ex1_valid_q) and ex1_ttype_q(2) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1) and not(snoop_val_q(0) and snoop_val_q(1))) 
                   or (iu_ierat_iu0_val and not(snoop_val_q(0) and snoop_val_q(1))) );
state_enable(1) <=   not(or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5))) and    
                    ( (snoop_val_q(0) and snoop_val_q(1) and not snoop_attr_q(1) and snoop_attr_q(2) and snoop_attr_q(3))  
                   or (or_reduce(ex1_valid_q) and ex1_ttype_q(2) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1) and not(snoop_val_q(0) and snoop_val_q(1))) 
                   or (iu_ierat_iu0_val and not(snoop_val_q(0) and snoop_val_q(1))) );
comp_thdid         <=  ( snoop_attr_q(22 to 25) and (0 to 3 => (mmucr1_q(8) and snoop_val_q(0) and snoop_val_q(1))) ) 
                  or ( ex1_pid_q(pid_width-12 to pid_width-9) and (0 to 3 => (mmucr1_q(8) and not(snoop_val_q(0) and snoop_val_q(1)) and ex1_ieratsx)) ) 
                  or ( iu1_pid_d(pid_width-12 to pid_width-9) and (0 to 3 => (mmucr1_q(8) and not(snoop_val_q(0) and snoop_val_q(1)) and not ex1_ieratsx)) ) 
                  or ( 0 to 3 =>  (snoop_val_q(0) and snoop_val_q(1) and not mmucr1_q(8)) ) 
                  or ( ex1_valid_q        and (0 to 3 => (ex1_ttype_q(2) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1) and not(snoop_val_q(0) and snoop_val_q(1)) and not mmucr1_q(8))) )  
                  or ( iu_ierat_iu0_thdid and (0 to 3 => ((not or_reduce(ex1_valid_q) or not ex1_ttype_q(2) or not Eq(ex1_tlbsel_q,TlbSel_IErat)) 
                         and not(snoop_val_q(0) and snoop_val_q(1)) and not mmucr1_q(8))) );
thdid_enable(0) <=  ( (iu_ierat_iu0_val or (or_reduce(ex1_valid_q) and ex1_ttype_q(2) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1))) and 
                         (not mmucr1_q(8) and not(snoop_val_q(0) and snoop_val_q(1)) and not(or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5)))) );
thdid_enable(1) <=  pid_enable and mmucr1_q(8);
comp_pid      <=  ( snoop_attr_q(6 to 13) and (0 to 7 => (snoop_val_q(0) and snoop_val_q(1))) )  
             or ( ex1_pid_q(pid_width-8 to pid_width-1) and 
                    (0 to 7 => (or_reduce(ex1_valid_q) and ex1_ttype_q(2) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1) and not(snoop_val_q(0) and snoop_val_q(1)))) ) 
             or ( iu1_pid_d(pid_width-8 to pid_width-1) and 
                    (0 to 7 => (not(or_reduce(ex1_valid_q) and ex1_ttype_q(2) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1)) and not(snoop_val_q(0) and snoop_val_q(1)))) );
pid_enable     <=   not(or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5))) and    
                    ( (snoop_val_q(0) and snoop_val_q(1) and not snoop_attr_q(1) and snoop_attr_q(3))  
                   or (or_reduce(ex1_valid_q) and ex1_ttype_q(2) and ex1_tlbsel_q(0) and not ex1_tlbsel_q(1) and not(snoop_val_q(0) and snoop_val_q(1))) 
                   or (iu_ierat_iu0_val and not(snoop_val_q(0) and snoop_val_q(1))) );
gen64_data_out: if data_out_width = 64 generate
ex4_data_out_d  <=  ( ((0 to 31 => '0') & rd_cam_data(32 to 51) & rd_cam_data(61 to 62) & rd_cam_data(56) & 
                   rd_cam_data(52) & ws0_pgsize(0 to 3) & rd_cam_data(57 to 60)) 
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and not ex3_ws_q(0) and not ex3_ws_q(1) and not ex3_state_q(3))) )  
            or  ( ((0 to 31 => '0') & rd_array_data(10 to 29) & "00" & rd_array_data(0 to 9))
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and not ex3_ws_q(0) and ex3_ws_q(1) and not ex3_state_q(3))) )  
            or  ( ((0 to 31 => '0') & "00000000" & rd_array_data(32 to 34) & '0' & rd_array_data(36 to 39) &  rd_array_data(30 to 31) &
                   "00" & rd_array_data(40 to 44) & '0' & rd_array_data(45 to 50))                                                     
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and not ex3_ws_q(1) and not ex3_state_q(3))) )  
            or  ( (rd_cam_data(0 to 51) & rd_cam_data(61 to 62) & rd_cam_data(56) & 
                   rd_cam_data(52) & ws0_pgsize(0 to 3) & rd_cam_data(57 to 60)) 
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and not ex3_ws_q(0) and not ex3_ws_q(1) and ex3_state_q(3))) )  
            or  ( ("00000000" & rd_array_data(32 to 34) & '0' & rd_array_data(36 to 39) &  rd_array_data(30 to 31) &
                   "0000" & rd_array_data(0 to 29) & rd_array_data(40 to 44) & '0' & rd_array_data(45 to 50))                           
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and not ex3_ws_q(0) and ex3_ws_q(1) and ex3_state_q(3))) )  
            or  ( ((0 to 47-watermark_width => '0') & (watermark_q and (48-watermark_width to 47 => bcfg_q(107))) & (48 to 63-eptr_width => '0') & eptr_q)
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and ex3_ws_q(1) and mmucr1_q(0))) )  
            or  ( ((0 to 47-watermark_width => '0') & (watermark_q and (48-watermark_width to 47 => bcfg_q(107))) & (48 to 63-num_entry_log2 => '0') & lru_way_encode)
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and ex3_ws_q(1) and not mmucr1_q(0))) )  
            or  ( ((0 to 49 => '0') & ex3_eratsx_data_q(0 to 1) & (52 to 59 => '0') & ex3_eratsx_data_q(2 to 2+num_entry_log2-1))
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
            or  ( ((32 to 47-watermark_width => '0') & (watermark_q and (48-watermark_width to 47 => bcfg_q(107))) & (48 to 63-eptr_width => '0') & eptr_q)
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and ex3_ws_q(1) and mmucr1_q(0))) )  
            or  ( ((32 to 47-watermark_width => '0') & (watermark_q and (48-watermark_width to 47 => bcfg_q(107))) & (48 to 63-num_entry_log2 => '0') & lru_way_encode)
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(0) and ex3_ws_q(0) and ex3_ws_q(1) and not mmucr1_q(0))) )  
            or  ( ((32 to 49 => '0') & ex3_eratsx_data_q(0 to 1) & (52 to 59 => '0') & ex3_eratsx_data_q(2 to 2+num_entry_log2-1))
                 and (64-data_out_width to 63 => (or_reduce(ex3_valid_q) and ex3_ttype_q(2))) );
end generate gen32_data_out;
bypass_mux_enab_np1  <=  (ccr2_frat_paranoia_q(9) or iu_ierat_iu1_back_inv or an_ac_grffence_en_dc);
bypass_attr_np1(0 TO 5) <=  (others => '0');
bypass_attr_np1(6 TO 9) <=  ccr2_frat_paranoia_q(5 to 8);
bypass_attr_np1(10 TO 14) <=  ccr2_frat_paranoia_q(0 to 4);
bypass_attr_np1(15 TO 20) <=  "111111";
ierat_iu_iu2_error(0) <=  iu2_miss_sig or iu2_multihit_sig or iu2_parerr_sig or iu2_isi_sig;
ierat_iu_iu2_error(1) <=  iu2_miss_sig or iu2_multihit_sig;
ierat_iu_iu2_error(2) <=  iu2_miss_sig or iu2_parerr_sig;
ierat_iu_iu2_miss          <=  iu2_miss_sig;
ierat_iu_iu2_multihit      <=  iu2_multihit_sig;
ierat_iu_iu2_isi           <=  iu2_isi_sig;
ierat_iu_hold_req           <=  hold_req_q;
ierat_iu_iu2_flush_req      <=  iu2_n_flush_req_q;
iu_xu_ex4_data              <=  ex4_data_out_q;
iu_mm_ierat_req             <=  iu2_tlbreq_q;
iu_mm_ierat_thdid           <=  iu2_valid_q;
iu_mm_ierat_state           <=  iu2_state_q;
iu_mm_ierat_tid             <=  iu2_pid_q;
iu_mm_ierat_flush           <=  iu_mm_ierat_flush_q;
iu_mm_ierat_mmucr0           <=  ex6_extclass_q & ex6_state_q(1 to 2) & ex6_pid_q;
iu_mm_ierat_mmucr0_we        <=  ex6_valid_q when (ex6_ttype_q(0)='1' and ex6_ws_q="00" and ex6_tlbsel_q=TlbSel_IErat) 
                             else (others => '0');
iu_mm_ierat_mmucr1           <=  ex6_ieen_q(1 to num_entry_log2);
iu_mm_ierat_mmucr1_we        <=  ex6_ieen_q(0);
iu_xu_ierat_ex3_par_err  <=  ex3_parerr_q(0 to thdid_width-1) and (0 to thdid_width-1 => ex3_parerr_enab);
iu_xu_ierat_ex4_par_err  <=  ex4_parerr_q(0 to thdid_width-1) and (0 to thdid_width-1 => ex4_parerr_enab);
ierat_cam: entity tri.tri_cam_16x143_1r1w1c
  generic map (expand_type => expand_type)
  port map (
   gnd                => gnd,
   vdd                => vdd,
   vcs                => vcs,
   nclk                           =>  nclk,


   tc_ccflush_dc                  =>  tc_ccflush_dc,
   tc_scan_dis_dc_b               =>  tc_scan_dis_dc_b,
   tc_scan_diag_dc                =>  tc_scan_diag_dc,
   tc_lbist_en_dc                 =>  tc_lbist_en_dc,
   an_ac_atpg_en_dc               =>  an_ac_atpg_en_dc,


   lcb_d_mode_dc                  =>  cam_d_mode,
   lcb_clkoff_dc_b                =>  cam_clkoff_b,
   lcb_act_dis_dc                 =>  cam_act_dis,
   lcb_mpw1_dc_b                  =>  cam_mpw1_b(0 to 3),  
   lcb_mpw2_dc_b                  =>  cam_mpw2_b,
   lcb_delay_lclkr_dc             =>  cam_delay_lclkr(0 to 3), 

   pc_sg_2                        =>  pc_iu_sg_2,
   pc_func_slp_sl_thold_2         =>  pc_iu_func_slp_sl_thold_2,
   pc_func_slp_nsl_thold_2        =>  pc_iu_func_slp_nsl_thold_2,
   pc_regf_slp_sl_thold_2         =>  pc_iu_regf_slp_sl_thold_2,
   pc_time_sl_thold_2             =>  pc_iu_time_sl_thold_2,
   pc_fce_2                       =>  pc_iu_fce_2,

   func_scan_in  	          => func_scan_in_cam,
   func_scan_out 	          => func_scan_out_cam,
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


bypass_mux_enab_np1            =>  bypass_mux_enab_np1,   
   bypass_attr_np1                =>  bypass_attr_np1,       
   attr_np2	                  =>  attr_np2,              
   rpn_np2	                  =>  rpn_np2         

  );
ierat_iu_iu2_rpn            <=  rpn_np2;
ierat_iu_iu2_wimge          <=  attr_np2(10 to 14);
ierat_iu_iu2_u              <=  attr_np2(6 to 9);
iu1_debug_d(0) <=  comp_request;
iu1_debug_d(1) <=  comp_invalidate;
iu1_debug_d(2) <=  ( or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(4 to 5)) );
iu1_debug_d(3) <=  '0';
iu1_debug_d(4) <=  ( snoop_val_q(0) and snoop_val_q(1) and not(or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4)) );
iu1_debug_d(5) <=  ( ex1_ieratsx );
iu1_debug_d(6) <=  ( iu_ierat_iu0_val );
iu1_debug_d(7) <=  ( or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4) );
iu1_debug_d(8) <=  ( or_reduce(tlb_rel_val_q(0 to 3)) );
iu1_debug_d(9) <=  ( snoop_val_q(0) and snoop_val_q(1) );
iu1_debug_d(10) <=  '0';
iu2_debug_d(0 TO 10) <=  iu1_debug_q(0 to 10);
iu2_debug_d(11 TO 15) <=  '0' & iu1_first_hit_entry;
iu2_debug_d(16) <=  iu1_multihit;
lru_debug_d(0) <=  ( tlb_rel_data_q(eratpos_wren) and or_reduce(tlb_rel_val_q(0 to 3)) and tlb_rel_val_q(4) );
lru_debug_d(1) <=  ( snoop_val_q(0) and snoop_val_q(1)  );
lru_debug_d(2) <=  ( or_reduce(ex6_valid_q) and (ex6_ttype_q(4) or ex6_ttype_q(5)) );
lru_debug_d(3) <=  ( or_reduce(ex6_valid_q) and ex6_ttype_q(1) and not ex6_ws_q(0) and not ex6_ws_q(1) 
                               and ex6_tlbsel_q(0) and not ex6_tlbsel_q(1) and lru_way_is_written );
lru_debug_d(4) <=  ( or_reduce(iu1_valid_q and not(iu_ierat_iu1_flush) and not(xu_iu_flush) and not(iu2_n_flush_req_q)) 
                                   and not iu1_flush_enab_q and cam_hit and lru_way_is_hit_entry );
lru_debug_d(5 TO 19) <=  lru_eff;
lru_debug_d(20 TO 23) <=  lru_way_encode;
ierat_iu_debug_group0(0 TO 83) <=  iu2_cam_cmp_data_q(0 to 83);
ierat_iu_debug_group0(84) <=  ex3_eratsx_data_q(1);
ierat_iu_debug_group0(85) <=  iu2_debug_q(0);
ierat_iu_debug_group0(86) <=  iu2_debug_q(1);
ierat_iu_debug_group0(87) <=  iu2_debug_q(9);
ierat_iu_debug_group1(0 TO 67) <=  iu2_array_cmp_data_q(0 to 67);
ierat_iu_debug_group1(68) <=  ex3_eratsx_data_q(1);
ierat_iu_debug_group1(69) <=  iu2_debug_q(16);
ierat_iu_debug_group1(70 TO 74) <=  iu2_debug_q(11 to 15);
ierat_iu_debug_group1(75) <=  iu2_debug_q(0);
ierat_iu_debug_group1(76) <=  iu2_debug_q(1);
ierat_iu_debug_group1(77) <=  iu2_debug_q(2);
ierat_iu_debug_group1(78) <=  iu2_debug_q(3);
ierat_iu_debug_group1(79) <=  iu2_debug_q(4);
ierat_iu_debug_group1(80) <=  iu2_debug_q(5);
ierat_iu_debug_group1(81) <=  iu2_debug_q(6);
ierat_iu_debug_group1(82) <=  iu2_debug_q(7);
ierat_iu_debug_group1(83) <=  iu2_debug_q(8);
ierat_iu_debug_group1(84) <=  iu2_debug_q(9);
ierat_iu_debug_group1(85) <=  iu2_debug_q(10);
ierat_iu_debug_group1(86) <=  '0';
ierat_iu_debug_group1(87) <=  lru_update_event_q(7) or lru_update_event_q(8);
ierat_iu_debug_group2(0 TO 15) <=  entry_valid_q(0 to 15);
ierat_iu_debug_group2(16 TO 31) <=  entry_match_q(0 to 15);
ierat_iu_debug_group2(32 TO 47) <=  '0' & lru_q(1 to 15);
ierat_iu_debug_group2(48 TO 63) <=  '0' & lru_debug_q(5 to 19);
ierat_iu_debug_group2(64 TO 73) <=  lru_update_event_q(0 to 8) & iu2_debug_q(16);
ierat_iu_debug_group2(74 TO 78) <=  '0' & lru_debug_q(20 to 23);
ierat_iu_debug_group2(79 TO 83) <=  '0' & watermark_q(0 to 3);
ierat_iu_debug_group2(84) <=  ex3_eratsx_data_q(1);
ierat_iu_debug_group2(85) <=  iu2_debug_q(0);
ierat_iu_debug_group2(86) <=  iu2_debug_q(1);
ierat_iu_debug_group2(87) <=  iu2_debug_q(9);
ierat_iu_debug_group3(0) <=  ex3_eratsx_data_q(1);
ierat_iu_debug_group3(1) <=  iu2_debug_q(0);
ierat_iu_debug_group3(2) <=  iu2_debug_q(1);
ierat_iu_debug_group3(3) <=  iu2_debug_q(9);
ierat_iu_debug_group3(4 TO 8) <=  iu2_debug_q(11 to 15);
ierat_iu_debug_group3(9) <=  lru_update_event_q(7) or lru_update_event_q(8);
ierat_iu_debug_group3(10 TO 14) <=  lru_debug_q(0 to 4);
ierat_iu_debug_group3(15 TO 19) <=  '0' & watermark_q(0 to 3);
ierat_iu_debug_group3(20 TO 35) <=  entry_valid_q(0 to 15);
ierat_iu_debug_group3(36 TO 51) <=  entry_match_q(0 to 15);
ierat_iu_debug_group3(52 TO 67) <=  '0' & lru_q(1 to 15);
ierat_iu_debug_group3(68 TO 83) <=  '0' & lru_debug_q(5 to 19);
ierat_iu_debug_group3(84 TO 87) <=  lru_debug_q(20 to 23);
unused_dc(0) <=  mmucr1_q(2);
unused_dc(1) <=  iu2_multihit_enab and or_reduce(iu2_first_hit_entry);
unused_dc(2) <=  or_reduce(ex6_ttype_q(2 to 3)) and ex6_state_q(0);
unused_dc(3) <=  or_reduce(tlb_rel_data_q(eratpos_rpnrsvd to eratpos_rpnrsvd+3));
unused_dc(4) <=  iu2_cam_cmp_data_q(56) or ex4_rd_cam_data_q(56);
unused_dc(5) <=  or_reduce(attr_np2(0 to 5));
unused_dc(6) <=  or_reduce(attr_np2(15 to 20));
unused_dc(7) <=  or_reduce(cam_hit_entry);
unused_dc(8) <=  or_reduce(bcfg_q_b(0 to 15));
unused_dc(9) <=  or_reduce(bcfg_q_b(16 to 31));
unused_dc(10) <=  or_reduce(bcfg_q_b(32 to 47));
unused_dc(11) <=  or_reduce(bcfg_q_b(48 to 51));
unused_dc(12) <=  or_reduce(bcfg_q_b(52 to 61));
unused_dc(13) <=  or_reduce(bcfg_q_b(62 to 77));
unused_dc(14) <=  or_reduce(bcfg_q_b(78 to 81));
unused_dc(15) <=  or_reduce(bcfg_q_b(82 to 86));
unused_dc(16) <=  or_reduce(ex1_ra_entry_q);
unused_dc(17) <=  or_reduce(ex1_rs_is_q);
unused_dc(18) <=  or_reduce(ex6_rs_is_q);
unused_dc(19) <=  pc_func_sl_thold_0_b or pc_func_sl_force;
unused_dc(20) <=  cam_mpw1_b(4) or cam_delay_lclkr(4);
unused_dc(21) <=  or_reduce(ex1_ttype_q(ttype_width-2 to ttype_width));
unused_dc(23) <=  ex7_ttype_q(0);
unused_dc(24) <=  or_reduce(ex7_ttype_q(2 TO 5));
unused_dc(25) <=  or_reduce(por_wr_array_data(51 to 67));
unused_dc(26) <=  or_reduce(bcfg_q_b(87 to 102));
unused_dc(27) <=  or_reduce(bcfg_q_b(103 to 106));
unused_dc(28) <=  or_reduce(bcfg_q(108 to 122));
unused_dc(29) <=  or_reduce(bcfg_q_b(107 to 122));
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
            act     => tiup,
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
            act     => tiup,
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
            act     => tiup,
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
            act     => tiup,
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
            act     => tiup,
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
            act     => tiup,
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
            act     => tiup,
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
            act     => ex2_grffence_act,
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
ex3_eratsx_data_latch: tri_rlmreg_p
  generic map (width => ex3_eratsx_data_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => eratsx_data_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(ex3_eratsx_data_offset to ex3_eratsx_data_offset+ex3_eratsx_data_q'length-1),
            scout   => sov_0(ex3_eratsx_data_offset to ex3_eratsx_data_offset+ex3_eratsx_data_q'length-1),
            din     => ex3_eratsx_data_d(0 to 2+num_entry_log2-1),
            dout    => ex3_eratsx_data_q(0 to 2+num_entry_log2-1)  );
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
            scin    => siv_1(ex7_valid_offset to ex7_valid_offset+ex7_valid_q'length-1),
            scout   => sov_1(ex7_valid_offset to ex7_valid_offset+ex7_valid_q'length-1),
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
            scin    => siv_1(ex7_ttype_offset to ex7_ttype_offset+ex7_ttype_q'length-1),
            scout   => sov_1(ex7_ttype_offset to ex7_ttype_offset+ex7_ttype_q'length-1),
            din     => ex7_ttype_d(0 to ttype_width-1),
            dout    => ex7_ttype_q(0 to ttype_width-1)  );
ex7_tlbsel_latch: tri_rlmreg_p
  generic map (width => ex7_tlbsel_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(ex7_tlbsel_offset to ex7_tlbsel_offset+ex7_tlbsel_q'length-1),
            scout   => sov_1(ex7_tlbsel_offset to ex7_tlbsel_offset+ex7_tlbsel_q'length-1),
            din     => ex7_tlbsel_d(0 to tlbsel_width-1),
            dout    => ex7_tlbsel_q(0 to tlbsel_width-1)  );
iu1_flush_enab_latch: tri_rlmlatch_p
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
            scin    => siv_0(iu1_flush_enab_offset),
            scout   => sov_0(iu1_flush_enab_offset),
            din     => iu1_flush_enab_d,
            dout    => iu1_flush_enab_q);
iu2_n_flush_req_latch: tri_rlmreg_p
  generic map (width => iu2_n_flush_req_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => iu1_or_iu2_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(iu2_n_flush_req_offset to iu2_n_flush_req_offset+iu2_n_flush_req_q'length-1),
            scout   => sov_0(iu2_n_flush_req_offset to iu2_n_flush_req_offset+iu2_n_flush_req_q'length-1),
            din     => iu2_n_flush_req_d(0 to thdid_width-1),
            dout    => iu2_n_flush_req_q(0 to thdid_width-1)  );
hold_req_latch: tri_rlmreg_p
  generic map (width => hold_req_q'length, init => 15, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(hold_req_offset to hold_req_offset+hold_req_q'length-1),
            scout   => sov_0(hold_req_offset to hold_req_offset+hold_req_q'length-1),
            din     => hold_req_d(0 to thdid_width-1),
            dout    => hold_req_q(0 to thdid_width-1)  );
tlb_miss_latch: tri_rlmreg_p
  generic map (width => tlb_miss_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(tlb_miss_offset to tlb_miss_offset+tlb_miss_q'length-1),
            scout   => sov_0(tlb_miss_offset to tlb_miss_offset+tlb_miss_q'length-1),
            din     => tlb_miss_d(0 to thdid_width-1),
            dout    => tlb_miss_q(0 to thdid_width-1)  );
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
iu1_valid_latch: tri_rlmreg_p
  generic map (width => iu1_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(iu1_valid_offset to iu1_valid_offset+iu1_valid_q'length-1),
            scout   => sov_0(iu1_valid_offset to iu1_valid_offset+iu1_valid_q'length-1),
            din     => iu1_valid_d(0 to thdid_width-1),
            dout    => iu1_valid_q(0 to thdid_width-1)  );
iu1_state_latch: tri_rlmreg_p
  generic map (width => iu1_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(iu1_state_offset to iu1_state_offset+iu1_state_q'length-1),
            scout   => sov_0(iu1_state_offset to iu1_state_offset+iu1_state_q'length-1),
            din     => iu1_state_d(0 to state_width-1),
            dout    => iu1_state_q(0 to state_width-1)  );
iu1_pid_latch: tri_rlmreg_p
  generic map (width => iu1_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(iu1_pid_offset to iu1_pid_offset+iu1_pid_q'length-1),
            scout   => sov_0(iu1_pid_offset to iu1_pid_offset+iu1_pid_q'length-1),
            din     => iu1_pid_d,
            dout    => iu1_pid_q  );
iu2_valid_latch: tri_rlmreg_p
  generic map (width => iu2_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(iu2_valid_offset to iu2_valid_offset+iu2_valid_q'length-1),
            scout   => sov_0(iu2_valid_offset to iu2_valid_offset+iu2_valid_q'length-1),
            din     => iu2_valid_d(0 to thdid_width-1),
            dout    => iu2_valid_q(0 to thdid_width-1)  );
iu2_state_latch: tri_rlmreg_p
  generic map (width => iu2_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => iu1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(iu2_state_offset to iu2_state_offset+iu2_state_q'length-1),
            scout   => sov_0(iu2_state_offset to iu2_state_offset+iu2_state_q'length-1),
            din     => iu2_state_d(0 to state_width-1),
            dout    => iu2_state_q(0 to state_width-1)  );
iu2_pid_latch: tri_rlmreg_p
  generic map (width => iu2_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => iu1_stg_act_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(iu2_pid_offset to iu2_pid_offset+iu2_pid_q'length-1),
            scout   => sov_0(iu2_pid_offset to iu2_pid_offset+iu2_pid_q'length-1),
            din     => iu2_pid_d,
            dout    => iu2_pid_q  );
iu2_miss_latch: tri_rlmreg_p
  generic map (width => iu2_miss_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => iu1_or_iu2_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(iu2_miss_offset to iu2_miss_offset+iu2_miss_q'length-1),
            scout   => sov_0(iu2_miss_offset to iu2_miss_offset+iu2_miss_q'length-1),
            din     => iu2_miss_d,
            dout    => iu2_miss_q  );
iu2_multihit_latch: tri_rlmreg_p
  generic map (width => iu2_multihit_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => iu1_or_iu2_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(iu2_multihit_offset to iu2_multihit_offset+iu2_multihit_q'length-1),
            scout   => sov_0(iu2_multihit_offset to iu2_multihit_offset+iu2_multihit_q'length-1),
            din     => iu2_multihit_d,
            dout    => iu2_multihit_q  );
iu2_parerr_latch: tri_rlmreg_p
  generic map (width => iu2_parerr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => iu1_or_iu2_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(iu2_parerr_offset to iu2_parerr_offset+iu2_parerr_q'length-1),
            scout   => sov_0(iu2_parerr_offset to iu2_parerr_offset+iu2_parerr_q'length-1),
            din     => iu2_parerr_d,
            dout    => iu2_parerr_q  );
iu2_isi_latch: tri_rlmreg_p
  generic map (width => iu2_isi_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(iu2_isi_offset to iu2_isi_offset+iu2_isi_q'length-1),
            scout   => sov_0(iu2_isi_offset to iu2_isi_offset+iu2_isi_q'length-1),
            din     => iu2_isi_d,
            dout    => iu2_isi_q  );
iu2_tlbreq_latch: tri_rlmlatch_p
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
            scin    => siv_0(iu2_tlbreq_offset),
            scout   => sov_0(iu2_tlbreq_offset),
            din     => iu2_tlbreq_d,
            dout    => iu2_tlbreq_q);
iu2_multihit_b_pt_latch: tri_rlmreg_p
  generic map (width => iu2_multihit_b_pt_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => iu1_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(iu2_multihit_b_pt_offset to iu2_multihit_b_pt_offset+iu2_multihit_b_pt_q'length-1),
            scout   => sov_0(iu2_multihit_b_pt_offset to iu2_multihit_b_pt_offset+iu2_multihit_b_pt_q'length-1),
            din     => iu2_multihit_b_pt_d,
            dout    => iu2_multihit_b_pt_q  );
iu2_first_hit_entry_pt_latch: tri_rlmreg_p
  generic map (width => iu2_first_hit_entry_pt_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => iu1_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(iu2_first_hit_entry_pt_offset to iu2_first_hit_entry_pt_offset+iu2_first_hit_entry_pt_q'length-1),
            scout   => sov_0(iu2_first_hit_entry_pt_offset to iu2_first_hit_entry_pt_offset+iu2_first_hit_entry_pt_q'length-1),
            din     => iu2_first_hit_entry_pt_d,
            dout    => iu2_first_hit_entry_pt_q  );
iu2_cam_cmp_data_latch: tri_rlmreg_p
  generic map (width => iu2_cam_cmp_data_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu1_cmp_data_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(iu2_cam_cmp_data_offset to iu2_cam_cmp_data_offset+iu2_cam_cmp_data_q'length-1),
            scout   => sov_0(iu2_cam_cmp_data_offset to iu2_cam_cmp_data_offset+iu2_cam_cmp_data_q'length-1),
            din     => iu2_cam_cmp_data_d(0 to cam_data_width-1),
            dout    => iu2_cam_cmp_data_q(0 to cam_data_width-1));
iu2_array_cmp_data_latch: tri_rlmreg_p
  generic map (width => iu2_array_cmp_data_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu1_cmp_data_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(iu2_array_cmp_data_offset to iu2_array_cmp_data_offset+iu2_array_cmp_data_q'length-1),
            scout   => sov_0(iu2_array_cmp_data_offset to iu2_array_cmp_data_offset+iu2_array_cmp_data_q'length-1),
            din     => iu2_array_cmp_data_d(0 to array_data_width-1),
            dout    => iu2_array_cmp_data_q(0 to array_data_width-1));
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
            scin    => siv_0(ex4_rd_cam_data_offset to ex4_rd_cam_data_offset+ex4_rd_cam_data_q'length-1),
            scout   => sov_0(ex4_rd_cam_data_offset to ex4_rd_cam_data_offset+ex4_rd_cam_data_q'length-1),
            din     => ex4_rd_cam_data_d(0 to cam_data_width-1),
            dout    => ex4_rd_cam_data_q(0 to cam_data_width-1));
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
            scin    => siv_0(ex4_rd_array_data_offset to ex4_rd_array_data_offset+ex4_rd_array_data_q'length-1),
            scout   => sov_0(ex4_rd_array_data_offset to ex4_rd_array_data_offset+ex4_rd_array_data_q'length-1),
            din     => ex4_rd_array_data_d(0 to array_data_width-1),
            dout    => ex4_rd_array_data_q(0 to array_data_width-1));
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
            dout    => ex3_parerr_q );
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
            scin    => siv_0(ex4_parerr_offset to ex4_parerr_offset+ex4_parerr_q'length-1),
            scout   => sov_0(ex4_parerr_offset to ex4_parerr_offset+ex4_parerr_q'length-1),
            din     => ex4_parerr_d,
            dout    => ex4_parerr_q );
ex4_ieen_latch: tri_rlmreg_p
  generic map (width => ex4_ieen_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(ex4_ieen_offset to ex4_ieen_offset+ex4_ieen_q'length-1),
            scout   => sov_0(ex4_ieen_offset to ex4_ieen_offset+ex4_ieen_q'length-1),
            din     => ex4_ieen_d(0 to ex4_ieen_d'length-1),
            dout    => ex4_ieen_q(0 to ex4_ieen_q'length-1));
ex5_ieen_latch: tri_rlmreg_p
  generic map (width => ex5_ieen_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(ex5_ieen_offset to ex5_ieen_offset+ex5_ieen_q'length-1),
            scout   => sov_0(ex5_ieen_offset to ex5_ieen_offset+ex5_ieen_q'length-1),
            din     => ex5_ieen_d(0 to ex5_ieen_d'length-1),
            dout    => ex5_ieen_q(0 to ex5_ieen_q'length-1));
ex6_ieen_latch: tri_rlmreg_p
  generic map (width => ex6_ieen_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(ex6_ieen_offset to ex6_ieen_offset+ex6_ieen_q'length-1),
            scout   => sov_0(ex6_ieen_offset to ex6_ieen_offset+ex6_ieen_q'length-1),
            din     => ex6_ieen_d(0 to ex6_ieen_d'length-1),
            dout    => ex6_ieen_q(0 to ex6_ieen_q'length-1));
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
            scin    => siv_0(mmucr1_offset to mmucr1_offset+mmucr1_q'length-1),
            scout   => sov_0(mmucr1_offset to mmucr1_offset+mmucr1_q'length-1),
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
            scin    => siv_0(rpn_holdreg0_offset to rpn_holdreg0_offset+rpn_holdreg0_q'length-1),
            scout   => sov_0(rpn_holdreg0_offset to rpn_holdreg0_offset+rpn_holdreg0_q'length-1),
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
            scin    => siv_0(rpn_holdreg1_offset to rpn_holdreg1_offset+rpn_holdreg1_q'length-1),
            scout   => sov_0(rpn_holdreg1_offset to rpn_holdreg1_offset+rpn_holdreg1_q'length-1),
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
            scin    => siv_0(rpn_holdreg2_offset to rpn_holdreg2_offset+rpn_holdreg2_q'length-1),
            scout   => sov_0(rpn_holdreg2_offset to rpn_holdreg2_offset+rpn_holdreg2_q'length-1),
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
            scin    => siv_0(rpn_holdreg3_offset to rpn_holdreg3_offset+rpn_holdreg3_q'length-1),
            scout   => sov_0(rpn_holdreg3_offset to rpn_holdreg3_offset+rpn_holdreg3_q'length-1),
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
            scin    => siv_0(entry_valid_offset to entry_valid_offset+entry_valid_q'length-1),
            scout   => sov_0(entry_valid_offset to entry_valid_offset+entry_valid_q'length-1),
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
            scin    => siv_0(entry_match_offset to entry_match_offset+entry_match_q'length-1),
            scout   => sov_0(entry_match_offset to entry_match_offset+entry_match_q'length-1),
            din     => entry_match,
            dout    => entry_match_q  );
watermark_latch: tri_rlmreg_p
  generic map (width => watermark_q'length, init => 13, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(watermark_offset to watermark_offset+watermark_q'length-1),
            scout   => sov_0(watermark_offset to watermark_offset+watermark_q'length-1),
            din     => watermark_d(0 to watermark_width-1),
            dout    => watermark_q(0 to watermark_width-1)  );
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
            scin    => siv_0(eptr_offset to eptr_offset+eptr_q'length-1),
            scout   => sov_0(eptr_offset to eptr_offset+eptr_q'length-1),
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
            scin    => siv_0(lru_offset to lru_offset+lru_q'length-1),
            scout   => sov_0(lru_offset to lru_offset+lru_q'length-1),
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
            scin    => siv_0(lru_update_event_offset to lru_update_event_offset+lru_update_event_q'length-1),
            scout   => sov_0(lru_update_event_offset to lru_update_event_offset+lru_update_event_q'length-1),
            din     => lru_update_event_d,
            dout    => lru_update_event_q  );
lru_debug_latch: tri_rlmreg_p
  generic map (width => lru_debug_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(lru_debug_offset to lru_debug_offset+lru_debug_q'length-1),
            scout   => sov_0(lru_debug_offset to lru_debug_offset+lru_debug_q'length-1),
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
            act     => snoop_act_q,
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
            act     => snoop_act_q,
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
iu_mm_ierat_flush_latch: tri_rlmreg_p
  generic map (width => iu_mm_ierat_flush_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(iu_mm_ierat_flush_offset to iu_mm_ierat_flush_offset+iu_mm_ierat_flush_q'length-1),
            scout   => sov_1(iu_mm_ierat_flush_offset to iu_mm_ierat_flush_offset+iu_mm_ierat_flush_q'length-1),
            din     => iu_mm_ierat_flush_d(0 to thdid_width-1),
            dout    => iu_mm_ierat_flush_q(0 to thdid_width-1)  );
iu_xu_ierat_ex2_flush_latch: tri_rlmreg_p
  generic map (width => iu_xu_ierat_ex2_flush_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(iu_xu_ierat_ex2_flush_offset to iu_xu_ierat_ex2_flush_offset+iu_xu_ierat_ex2_flush_q'length-1),
            scout   => sov_1(iu_xu_ierat_ex2_flush_offset to iu_xu_ierat_ex2_flush_offset+iu_xu_ierat_ex2_flush_q'length-1),
            din     => iu_xu_ierat_ex2_flush_d(0 to thdid_width-1),
            dout    => iu_xu_ierat_ex2_flush_q(0 to thdid_width-1)  );
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
            din     => xu_iu_hid_mmu_mode,
            dout    => ccr2_notlb_q);
mchk_flash_inv_latch: tri_rlmreg_p
  generic map (width => mchk_flash_inv_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => iu2_to_iu4_grffence_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mchk_flash_inv_offset to mchk_flash_inv_offset+mchk_flash_inv_q'length-1),
            scout   => sov_1(mchk_flash_inv_offset to mchk_flash_inv_offset+mchk_flash_inv_q'length-1),
            din     => mchk_flash_inv_d,
            dout    => mchk_flash_inv_q  );
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
            din     => xu_iu_xucr4_mmu_mchk,
            dout    => xucr4_mmu_mchk_q);
iu1_debug_latch: tri_rlmreg_p
  generic map (width => iu1_debug_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(iu1_debug_offset to iu1_debug_offset+iu1_debug_q'length-1),
            scout   => sov_1(iu1_debug_offset to iu1_debug_offset+iu1_debug_q'length-1),
            din     => iu1_debug_d,
            dout    => iu1_debug_q);
iu2_debug_latch: tri_rlmreg_p
  generic map (width => iu2_debug_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(iu2_debug_offset to iu2_debug_offset+iu2_debug_q'length-1),
            scout   => sov_1(iu2_debug_offset to iu2_debug_offset+iu2_debug_q'length-1),
            din     => iu2_debug_d,
            dout    => iu2_debug_q);
iu1_stg_act_latch: tri_rlmlatch_p
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
            scin    => siv_1(iu1_stg_act_offset),
            scout   => sov_1(iu1_stg_act_offset),
            din     => iu1_stg_act_d,
            dout    => iu1_stg_act_q);
iu2_stg_act_latch: tri_rlmlatch_p
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
            scin    => siv_1(iu2_stg_act_offset),
            scout   => sov_1(iu2_stg_act_offset),
            din     => iu2_stg_act_d,
            dout    => iu2_stg_act_q);
iu3_stg_act_latch: tri_rlmlatch_p
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
            scin    => siv_1(iu3_stg_act_offset),
            scout   => sov_1(iu3_stg_act_offset),
            din     => iu3_stg_act_d,
            dout    => iu3_stg_act_q);
iu4_stg_act_latch: tri_rlmlatch_p
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
            scin    => siv_1(iu4_stg_act_offset),
            scout   => sov_1(iu4_stg_act_offset),
            din     => iu4_stg_act_d,
            dout    => iu4_stg_act_q);
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
            din     => mm_iu_ierat_snoop_coming,
            dout    => snoop_act_q);
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
            din     => pc_iu_trace_bus_enable,
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
  generic map (width => 16, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(spare_a_offset to spare_a_offset+15),
            scout   => sov_1(spare_a_offset to spare_a_offset+15),
            din     => spare_q(0 to 15),
            dout    => spare_q(0 to 15)  );
spare_b_latch: tri_rlmreg_p
  generic map (width => 16, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(spare_b_offset to spare_b_offset+15),
            scout   => sov_1(spare_b_offset to spare_b_offset+15),
            din     => spare_q(16 to 31),
            dout    => spare_q(16 to 31)  );
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
perv_2to1_reg: tri_plat
  generic map (width => 4, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_2,
            din(1)      => pc_iu_func_slp_sl_thold_2,
            din(2)      => pc_iu_cfg_slp_sl_thold_2,
            din(3)      => pc_iu_sg_2,
            q(0)        => pc_func_sl_thold_1,
            q(1)        => pc_func_slp_sl_thold_1,
            q(2)        => pc_cfg_slp_sl_thold_1,
            q(3)        => pc_sg_1);
perv_1to0_reg: tri_plat
  generic map (width => 4, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ccflush_dc,
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
siv_0(0 TO scan_right_0) <=  sov_0(1 to scan_right_0) & ac_func_scan_in(0);
ac_func_scan_out(0) <=  sov_0(0);
siv_1(0 TO scan_right_1) <=  sov_1(1 to scan_right_1) & ac_func_scan_in(1);
ac_func_scan_out(1) <=  sov_1(0);
bsiv(0 TO boot_scan_right) <=  bsov(1 to boot_scan_right) & ac_ccfg_scan_in;
ac_ccfg_scan_out  <=  bsov(0);
END IUQ_IC_IERAT;

