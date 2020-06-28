-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

			

library ieee, ibm;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;
library work;
use work.iuq_pkg.all;

entity iuq_fxu_issue is
  generic(expand_type           : integer := 2  ); 
port(vdd                                        : inout power_logic;
     gnd                                        : inout power_logic;
     nclk                                       : in  clk_logic;  
     pc_iu_sg_2                                 : in std_ulogic;
     pc_iu_func_sl_thold_2                      : in std_ulogic;
     clkoff_b                                   : in std_ulogic;
     an_ac_scan_dis_dc_b                        : in std_ulogic;
     tc_ac_ccflush_dc                           : in std_ulogic;
     delay_lclkr                                : in std_ulogic;
     mpw1_b                                     : in std_ulogic;
     scan_in                                    : in std_ulogic;
     scan_out                                   : out std_ulogic;

     fiss_dbg_data                              : out std_ulogic_vector(0 to 87);
     pc_iu_trace_bus_enable                     : in  std_ulogic;

     pc_iu_event_bus_enable                     : in  std_ulogic;
     fiss_perf_event_t0                         : out std_ulogic_vector(0 to 7);
     fiss_perf_event_t1                         : out std_ulogic_vector(0 to 7);
     fiss_perf_event_t2                         : out std_ulogic_vector(0 to 7);
     fiss_perf_event_t3                         : out std_ulogic_vector(0 to 7);

     xu_iu_need_hole                            : in  std_ulogic;
     xu_iu_xucr0_rel                            : in  std_ulogic;

     an_ac_reld_data_vld                        : in  std_ulogic;
     an_ac_reld_core_tag                        : in  std_ulogic_vector(1 to 4);
     an_ac_reld_ditc                            : in  std_ulogic;
     an_ac_reld_data_coming                     : in  std_ulogic;
     an_ac_back_inv                             : in  std_ulogic;
     an_ac_back_inv_target                      : in  std_ulogic;

     fiss_uc_is2_ucode_vld                      : out std_ulogic;


     fdep_fiss_t0_is2_instr                     : in std_ulogic_vector(0 to 31);
     fdep_fiss_t0_is2_ta_vld                    : in std_ulogic;
     fdep_fiss_t0_is2_ta                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t0_is2_s1_vld                    : in std_ulogic;
     fdep_fiss_t0_is2_s1                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t0_is2_s2_vld                    : in std_ulogic;
     fdep_fiss_t0_is2_s2                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t0_is2_s3_vld                    : in std_ulogic;
     fdep_fiss_t0_is2_s3                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t0_is2_pred_update               : in std_ulogic;
     fdep_fiss_t0_is2_pred_taken_cnt            : in std_ulogic_vector(0 to 1);
     fdep_fiss_t0_is2_gshare                    : in std_ulogic_vector(0 to 3);
     fdep_fiss_t0_is2_ifar                      : in eff_ifar;
     fdep_fiss_t0_is2_error                     : in std_ulogic_vector(0 to 2);
     fdep_fiss_t0_is2_axu_ld_or_st              : in std_ulogic;                       
     fdep_fiss_t0_is2_axu_store                 : in std_ulogic;                       
     fdep_fiss_t0_is2_axu_ldst_indexed          : in std_ulogic;        
     fdep_fiss_t0_is2_axu_ldst_tag              : in std_ulogic_vector(0 to 8);        
     fdep_fiss_t0_is2_axu_ldst_size             : in std_ulogic_vector(0 to 5);        
     fdep_fiss_t0_is2_axu_ldst_update           : in std_ulogic;                       
     fdep_fiss_t0_is2_axu_ldst_extpid           : in std_ulogic;                       
     fdep_fiss_t0_is2_axu_ldst_forcealign       : in std_ulogic;                       
     fdep_fiss_t0_is2_axu_ldst_forceexcept      : in std_ulogic;                       
     fdep_fiss_t0_is2_axu_mftgpr                : in std_ulogic;                       
     fdep_fiss_t0_is2_axu_mffgpr                : in std_ulogic;                       
     fdep_fiss_t0_is2_axu_movedp               : in std_ulogic;                       
     fdep_fiss_t0_is2_axu_instr_type            : in std_ulogic_vector(0 to 2);                       
     fdep_fiss_t0_is2_match                     : in std_ulogic;                       
     fdep_fiss_t0_is2_2ucode                    : in std_ulogic;                       
     fdep_fiss_t0_is2_2ucode_type               : in std_ulogic;                       
     fdep_fiss_t0_is2_hole_delay                : in std_ulogic_vector(0 to 2);
     fdep_fiss_t0_is2_to_ucode                  : in std_ulogic;
     fdep_fiss_t0_is2_is_ucode                  : in std_ulogic;
     fdep_fiss_t0_is2early_vld                  : in std_ulogic;
     fdep_fiss_t0_is1_xu_dep_hit_b              : in std_ulogic;
     fdep_fiss_t1_is2_instr                     : in std_ulogic_vector(0 to 31);
     fdep_fiss_t1_is2_ta_vld                    : in std_ulogic;
     fdep_fiss_t1_is2_ta                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t1_is2_s1_vld                    : in std_ulogic;
     fdep_fiss_t1_is2_s1                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t1_is2_s2_vld                    : in std_ulogic;
     fdep_fiss_t1_is2_s2                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t1_is2_s3_vld                    : in std_ulogic;
     fdep_fiss_t1_is2_s3                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t1_is2_pred_update               : in std_ulogic;
     fdep_fiss_t1_is2_pred_taken_cnt            : in std_ulogic_vector(0 to 1);
     fdep_fiss_t1_is2_gshare                    : in std_ulogic_vector(0 to 3);
     fdep_fiss_t1_is2_ifar                      : in eff_ifar;
     fdep_fiss_t1_is2_error                     : in std_ulogic_vector(0 to 2);
     fdep_fiss_t1_is2_axu_ld_or_st              : in std_ulogic;                       
     fdep_fiss_t1_is2_axu_store                 : in std_ulogic;                       
     fdep_fiss_t1_is2_axu_ldst_indexed          : in std_ulogic;        
     fdep_fiss_t1_is2_axu_ldst_tag              : in std_ulogic_vector(0 to 8);        
     fdep_fiss_t1_is2_axu_ldst_size             : in std_ulogic_vector(0 to 5);        
     fdep_fiss_t1_is2_axu_ldst_update           : in std_ulogic;                       
     fdep_fiss_t1_is2_axu_ldst_extpid           : in std_ulogic;                       
     fdep_fiss_t1_is2_axu_ldst_forcealign       : in std_ulogic;                       
     fdep_fiss_t1_is2_axu_ldst_forceexcept      : in std_ulogic;                       
     fdep_fiss_t1_is2_axu_mftgpr                : in std_ulogic;                       
     fdep_fiss_t1_is2_axu_mffgpr                : in std_ulogic;                       
     fdep_fiss_t1_is2_axu_movedp               : in std_ulogic;                       
     fdep_fiss_t1_is2_axu_instr_type            : in std_ulogic_vector(0 to 2);                       
     fdep_fiss_t1_is2_match                     : in std_ulogic;                       
     fdep_fiss_t1_is2_2ucode                    : in std_ulogic;                       
     fdep_fiss_t1_is2_2ucode_type               : in std_ulogic;                       
     fdep_fiss_t1_is2_hole_delay                : in std_ulogic_vector(0 to 2);
     fdep_fiss_t1_is2_to_ucode                  : in std_ulogic;
     fdep_fiss_t1_is2_is_ucode                  : in std_ulogic;
     fdep_fiss_t1_is2early_vld                  : in std_ulogic;
     fdep_fiss_t1_is1_xu_dep_hit_b              : in std_ulogic;
     fdep_fiss_t2_is2_instr                     : in std_ulogic_vector(0 to 31);
     fdep_fiss_t2_is2_ta_vld                    : in std_ulogic;
     fdep_fiss_t2_is2_ta                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t2_is2_s1_vld                    : in std_ulogic;
     fdep_fiss_t2_is2_s1                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t2_is2_s2_vld                    : in std_ulogic;
     fdep_fiss_t2_is2_s2                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t2_is2_s3_vld                    : in std_ulogic;
     fdep_fiss_t2_is2_s3                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t2_is2_pred_update               : in std_ulogic;
     fdep_fiss_t2_is2_pred_taken_cnt            : in std_ulogic_vector(0 to 1);
     fdep_fiss_t2_is2_gshare                    : in std_ulogic_vector(0 to 3);
     fdep_fiss_t2_is2_ifar                      : in eff_ifar;
     fdep_fiss_t2_is2_error                     : in std_ulogic_vector(0 to 2);
     fdep_fiss_t2_is2_axu_ld_or_st              : in std_ulogic;                       
     fdep_fiss_t2_is2_axu_store                 : in std_ulogic;                       
     fdep_fiss_t2_is2_axu_ldst_indexed          : in std_ulogic;        
     fdep_fiss_t2_is2_axu_ldst_tag              : in std_ulogic_vector(0 to 8);        
     fdep_fiss_t2_is2_axu_ldst_size             : in std_ulogic_vector(0 to 5);        
     fdep_fiss_t2_is2_axu_ldst_update           : in std_ulogic;                       
     fdep_fiss_t2_is2_axu_ldst_extpid           : in std_ulogic;                       
     fdep_fiss_t2_is2_axu_ldst_forcealign       : in std_ulogic;                       
     fdep_fiss_t2_is2_axu_ldst_forceexcept      : in std_ulogic;                       
     fdep_fiss_t2_is2_axu_mftgpr                : in std_ulogic;                       
     fdep_fiss_t2_is2_axu_mffgpr                : in std_ulogic;                       
     fdep_fiss_t2_is2_axu_movedp               : in std_ulogic;                       
     fdep_fiss_t2_is2_axu_instr_type            : in std_ulogic_vector(0 to 2);                       
     fdep_fiss_t2_is2_match                     : in std_ulogic;                       
     fdep_fiss_t2_is2_2ucode                    : in std_ulogic;                       
     fdep_fiss_t2_is2_2ucode_type               : in std_ulogic;                       
     fdep_fiss_t2_is2_hole_delay                : in std_ulogic_vector(0 to 2);
     fdep_fiss_t2_is2_to_ucode                  : in std_ulogic;
     fdep_fiss_t2_is2_is_ucode                  : in std_ulogic;
     fdep_fiss_t2_is2early_vld                  : in std_ulogic;
     fdep_fiss_t2_is1_xu_dep_hit_b              : in std_ulogic;
     fdep_fiss_t3_is2_instr                     : in std_ulogic_vector(0 to 31);
     fdep_fiss_t3_is2_ta_vld                    : in std_ulogic;
     fdep_fiss_t3_is2_ta                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t3_is2_s1_vld                    : in std_ulogic;
     fdep_fiss_t3_is2_s1                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t3_is2_s2_vld                    : in std_ulogic;
     fdep_fiss_t3_is2_s2                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t3_is2_s3_vld                    : in std_ulogic;
     fdep_fiss_t3_is2_s3                        : in std_ulogic_vector(0 to 5);
     fdep_fiss_t3_is2_pred_update               : in std_ulogic;
     fdep_fiss_t3_is2_pred_taken_cnt            : in std_ulogic_vector(0 to 1);
     fdep_fiss_t3_is2_gshare                    : in std_ulogic_vector(0 to 3);
     fdep_fiss_t3_is2_ifar                      : in eff_ifar;
     fdep_fiss_t3_is2_error                     : in std_ulogic_vector(0 to 2);
     fdep_fiss_t3_is2_axu_ld_or_st              : in std_ulogic;                       
     fdep_fiss_t3_is2_axu_store                 : in std_ulogic;                       
     fdep_fiss_t3_is2_axu_ldst_indexed          : in std_ulogic;        
     fdep_fiss_t3_is2_axu_ldst_tag              : in std_ulogic_vector(0 to 8);        
     fdep_fiss_t3_is2_axu_ldst_size             : in std_ulogic_vector(0 to 5);        
     fdep_fiss_t3_is2_axu_ldst_update           : in std_ulogic;                       
     fdep_fiss_t3_is2_axu_ldst_extpid           : in std_ulogic;                       
     fdep_fiss_t3_is2_axu_ldst_forcealign       : in std_ulogic;                       
     fdep_fiss_t3_is2_axu_ldst_forceexcept      : in std_ulogic;                       
     fdep_fiss_t3_is2_axu_mftgpr                : in std_ulogic;                       
     fdep_fiss_t3_is2_axu_mffgpr                : in std_ulogic;                       
     fdep_fiss_t3_is2_axu_movedp               : in std_ulogic;                       
     fdep_fiss_t3_is2_axu_instr_type            : in std_ulogic_vector(0 to 2);                       
     fdep_fiss_t3_is2_match                     : in std_ulogic;                       
     fdep_fiss_t3_is2_2ucode                    : in std_ulogic;                       
     fdep_fiss_t3_is2_2ucode_type               : in std_ulogic;                       
     fdep_fiss_t3_is2_hole_delay                : in std_ulogic_vector(0 to 2);
     fdep_fiss_t3_is2_to_ucode                  : in std_ulogic;
     fdep_fiss_t3_is2_is_ucode                  : in std_ulogic;
     fdep_fiss_t3_is2early_vld                  : in std_ulogic;
     fdep_fiss_t3_is1_xu_dep_hit_b              : in std_ulogic;

     fiss_fdep_is2_take0                        : out std_ulogic;
     fiss_fdep_is2_take1                        : out std_ulogic;
     fiss_fdep_is2_take2                        : out std_ulogic;
     fiss_fdep_is2_take3                        : out std_ulogic;

     spr_issue_high_mask                        : in std_ulogic_vector(0 to 3);
     spr_issue_med_mask                         : in std_ulogic_vector(0 to 3);
     spr_fiss_count0_max                        : in std_ulogic_vector(0 to 5);
     spr_fiss_count1_max                        : in std_ulogic_vector(0 to 5);
     spr_fiss_count2_max                        : in std_ulogic_vector(0 to 5);
     spr_fiss_count3_max                        : in std_ulogic_vector(0 to 5);

     spr_fiss_pri_rand                          : in std_ulogic_vector(0 to 4);
     spr_fiss_pri_rand_always                   : in std_ulogic;
     spr_fiss_pri_rand_flush                    : in std_ulogic;

     iu_au_hi_pri_mask                          : out std_ulogic_vector(0 to 3);
     iu_au_md_pri_mask                          : out std_ulogic_vector(0 to 3);
     i_afi_is2_take_t                           : in  std_ulogic_vector(0 to 3);
     i_afd_is2_t0_instr_v                       : in  std_ulogic;
     i_afd_is2_t1_instr_v                       : in  std_ulogic;
     i_afd_is2_t2_instr_v                       : in  std_ulogic;
     i_afd_is2_t3_instr_v                       : in  std_ulogic;
     i_axu_is1_dep_hit_t0_b                     : in  std_ulogic;
     i_axu_is1_dep_hit_t1_b                     : in  std_ulogic;
     i_axu_is1_dep_hit_t2_b                     : in  std_ulogic;
     i_axu_is1_dep_hit_t3_b                     : in  std_ulogic;

     xu_iu_is2_flush_tid                        : in std_ulogic_vector(0 to 3);
     xu_iu_rf0_flush_tid                        : in std_ulogic_vector(0 to 3);
     xu_iu_rf1_flush_tid                        : in std_ulogic_vector(0 to 3);
     xu_iu_ex1_flush_tid                        : in std_ulogic_vector(0 to 3);
     xu_iu_ex2_flush_tid                        : in std_ulogic_vector(0 to 3);
     xu_iu_ex3_flush_tid                        : in std_ulogic_vector(0 to 3);
     xu_iu_ex4_flush_tid                        : in std_ulogic_vector(0 to 3);
     xu_iu_ex5_flush_tid                        : in std_ulogic_vector(0 to 3);
     xu_iu_ex5_ppc_cpl                          : in std_ulogic_vector(0 to 3);

     iu_xu_is2_vld                              : out std_ulogic;
     iu_xu_is2_tid                              : out std_ulogic_vector(0 to 3);
     iu_xu_is2_instr                            : out std_ulogic_vector(0 to 31);
     iu_xu_is2_ta_vld                           : out std_ulogic;
     iu_xu_is2_ta                               : out std_ulogic_vector(0 to 5);
     iu_xu_is2_s1_vld                           : out std_ulogic;
     iu_xu_is2_s1                               : out std_ulogic_vector(0 to 5);
     iu_xu_is2_s2_vld                           : out std_ulogic;
     iu_xu_is2_s2                               : out std_ulogic_vector(0 to 5);
     iu_xu_is2_s3_vld                           : out std_ulogic;
     iu_xu_is2_s3                               : out std_ulogic_vector(0 to 5);
     iu_xu_is2_pred_update                      : out std_ulogic;
     iu_xu_is2_pred_taken_cnt                   : out std_ulogic_vector(0 to 1);
     iu_xu_is2_gshare                           : out std_ulogic_vector(0 to 3);
     iu_xu_is2_ifar                             : out eff_ifar;
     iu_xu_is2_error                            : out std_ulogic_vector(0 to 2);    
     iu_xu_is2_is_ucode                         : out std_ulogic;
     iu_xu_is2_axu_ld_or_st                     : out std_ulogic;                       
     iu_xu_is2_axu_store                        : out std_ulogic;                       
     iu_xu_is2_axu_ldst_indexed                 : out std_ulogic;        
     iu_xu_is2_axu_ldst_tag                     : out std_ulogic_vector(0 to 8);        
     iu_xu_is2_axu_ldst_size                    : out std_ulogic_vector(0 to 5);        
     iu_xu_is2_axu_ldst_update                  : out std_ulogic;                       
     iu_xu_is2_axu_ldst_extpid                  : out std_ulogic;                       
     iu_xu_is2_axu_ldst_forcealign              : out std_ulogic;                       
     iu_xu_is2_axu_ldst_forceexcept             : out std_ulogic;                       
     iu_xu_is2_axu_mftgpr                       : out std_ulogic;                       
     iu_xu_is2_axu_mffgpr                       : out std_ulogic;                       
     iu_xu_is2_axu_movedp                      : out std_ulogic;                       
     iu_xu_is2_axu_instr_type                   : out std_ulogic_vector(0 to 2);               
     iu_xu_is2_match                            : out std_ulogic;
     fiss_uc_is2_2ucode                         : out std_ulogic;
     fiss_uc_is2_2ucode_type                    : out std_ulogic;
     iu_fu_rf0_str_val                          : out std_ulogic;
     iu_fu_rf0_ldst_val                         : out std_ulogic;
     iu_fu_rf0_ldst_tid                         : out std_ulogic_vector(0 to 1);
     iu_fu_rf0_ldst_tag                         : out std_ulogic_vector(0 to 8));
-- synopsys translate_off
-- synopsys translate_on
end iuq_fxu_issue;
ARCHITECTURE IUQ_FXU_ISSUE
          OF IUQ_FXU_ISSUE
          IS
constant uc_flush_tid_offset            : natural := 0;
constant xu_iu_need_hole_offset         : natural := uc_flush_tid_offset + 4;
constant xu_iu_xucr0_rel_offset         : natural := xu_iu_need_hole_offset + 1;
constant an_ac_back_inv_offset          : natural := xu_iu_xucr0_rel_offset + 1;
constant an_ac_back_inv_target_offset   : natural := an_ac_back_inv_offset + 1;
constant gap_l2_rel_hole_dly1_offset    : natural := an_ac_back_inv_target_offset + 1;
constant gap_l2_rel_hole_dly2_offset    : natural := gap_l2_rel_hole_dly1_offset + 1;
constant gap_l2_tag_dly1_offset         : natural := gap_l2_rel_hole_dly2_offset + 1;
constant gap_l2_tag_dly2_offset         : natural := gap_l2_tag_dly1_offset + 3;
constant low_pri_rf0_offset     : natural := gap_l2_tag_dly2_offset + 3;
constant low_pri_rf1_offset     : natural := low_pri_rf0_offset + 4;
constant low_pri_ex1_offset     : natural := low_pri_rf1_offset + 4;
constant low_pri_ex2_offset     : natural := low_pri_ex1_offset + 4;
constant low_pri_ex3_offset     : natural := low_pri_ex2_offset + 4;
constant low_pri_ex4_offset     : natural := low_pri_ex3_offset + 4;
constant low_pri_ex5_offset     : natural := low_pri_ex4_offset + 4;
constant low_pri_ex6_offset     : natural := low_pri_ex5_offset + 4;
constant xu_iu_ex6_ppc_cpl_offset: natural := low_pri_ex6_offset + 4;
constant low_pri_counter0_offset: natural := xu_iu_ex6_ppc_cpl_offset + 4;
constant low_pri_counter1_offset: natural := low_pri_counter0_offset + 8;
constant low_pri_counter2_offset: natural := low_pri_counter1_offset + 8;
constant low_pri_counter3_offset: natural := low_pri_counter2_offset + 8;
constant low_pri_max0_offset    : natural := low_pri_counter3_offset + 8;
constant low_pri_max1_offset    : natural := low_pri_max0_offset + 6;
constant low_pri_max2_offset    : natural := low_pri_max1_offset + 6;
constant low_pri_max3_offset    : natural := low_pri_max2_offset + 6;
constant high_pri_mask_offset   : natural := low_pri_max3_offset + 6;
constant med_pri_mask_offset    : natural := high_pri_mask_offset + 4;
constant spr_high_mask_offset   : natural := med_pri_mask_offset  + 4;
constant spr_med_mask_offset    : natural := spr_high_mask_offset + 4;
constant hole_delay0_offset     : natural := spr_med_mask_offset  + 4;
constant hole_delay1_offset     : natural := hole_delay0_offset + 2;
constant hole_delay2_offset     : natural := hole_delay1_offset + 2;
constant hole_delay3_offset     : natural := hole_delay2_offset + 2;
constant is2_vld_offset         : natural := hole_delay3_offset + 2;
constant perf_event_offset      : natural := is2_vld_offset + 4;
constant fiss_dbg_data_offset   : natural := perf_event_offset + 32;
constant rf0_str_val_offset     : natural := fiss_dbg_data_offset + 44;
constant rf0_ldst_val_offset    : natural := rf0_str_val_offset + 1;
constant rf0_ldst_tid_offset    : natural := rf0_ldst_val_offset + 1;
constant rf0_ldst_tag_offset    : natural := rf0_ldst_tid_offset + 2;
constant rf0_took_offset        : natural := rf0_ldst_tag_offset + 9;
constant spare_offset           : natural := rf0_took_offset + 12;
constant trace_bus_enable_offset        : natural := spare_offset + 4;
constant event_bus_enable_offset        : natural := trace_bus_enable_offset + 1;
constant scan_right                     : natural := event_bus_enable_offset + 1 - 1;
signal act_dis                          : std_ulogic;
signal d_mode                           : std_ulogic;
signal mpw2_b                           : std_ulogic;
signal spare_l2                 : std_ulogic_vector(0 to 3);
signal trace_bus_enable_d                   : std_ulogic;
signal trace_bus_enable_q                   : std_ulogic;
signal event_bus_enable_d                   : std_ulogic;
signal event_bus_enable_q                   : std_ulogic;
signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);
signal tiup                     : std_ulogic;
signal pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0    : std_ulogic;
signal pc_iu_func_sl_thold_0_b  : std_ulogic;
signal pc_iu_sg_1               : std_ulogic;
signal pc_iu_sg_0               : std_ulogic;
signal forcee                    : std_ulogic;
signal xu_iu_need_hole_d        : std_ulogic;
signal xu_iu_need_hole_l2       : std_ulogic;
signal xu_iu_xucr0_rel_d        : std_ulogic;
signal xu_iu_xucr0_rel_l2       : std_ulogic;
signal an_ac_back_inv_d         : std_ulogic;
signal an_ac_back_inv_l2        : std_ulogic;
signal an_ac_back_inv_target_d  : std_ulogic;
signal an_ac_back_inv_target_l2 : std_ulogic;
signal gap_l2_rel_hole_dly1_d   : std_ulogic;
signal gap_l2_rel_hole_dly1_l2  : std_ulogic;
signal gap_l2_rel_hole_dly2_d   : std_ulogic;
signal gap_l2_rel_hole_dly2_l2  : std_ulogic;
signal gap_l2_tag_dly1_d        : std_ulogic_vector(2 to 4);
signal gap_l2_tag_dly1_l2       : std_ulogic_vector(2 to 4);
signal gap_l2_tag_dly2_d        : std_ulogic_vector(2 to 4);
signal gap_l2_tag_dly2_l2       : std_ulogic_vector(2 to 4);
signal need_hole                : std_ulogic;
signal gap_l2_rel_hole          : std_ulogic;
signal dcache_rel_hole          : std_ulogic;
signal dcache_rel_tag_2nd_beat  : std_ulogic;
signal dcache_binv_hole         : std_ulogic;
signal is2_vld_d                : std_ulogic_vector(0 to 3);
signal hole_delay0_d            : std_ulogic_vector(0 to 1);
signal hole_delay1_d            : std_ulogic_vector(0 to 1);
signal hole_delay2_d            : std_ulogic_vector(0 to 1);
signal hole_delay3_d            : std_ulogic_vector(0 to 1);
signal is2_vld_l2               : std_ulogic_vector(0 to 3);
signal hole_delay0_l2           : std_ulogic_vector(0 to 1);
signal hole_delay1_l2           : std_ulogic_vector(0 to 1);
signal hole_delay2_l2           : std_ulogic_vector(0 to 1);
signal hole_delay3_l2           : std_ulogic_vector(0 to 1);
signal hole0                    : std_ulogic;
signal hole1                    : std_ulogic;
signal hole2                    : std_ulogic;
signal hole3                    : std_ulogic;
signal hole0_b                  : std_ulogic;
signal hole1_b                  : std_ulogic;
signal hole2_b                  : std_ulogic;
signal hole3_b                  : std_ulogic;
signal low_pri_rf0_d          : std_ulogic_vector(0 to 3);
signal low_pri_rf1_d          : std_ulogic_vector(0 to 3);
signal low_pri_ex1_d          : std_ulogic_vector(0 to 3);
signal low_pri_ex2_d          : std_ulogic_vector(0 to 3);
signal low_pri_ex3_d          : std_ulogic_vector(0 to 3);
signal low_pri_ex4_d          : std_ulogic_vector(0 to 3);
signal low_pri_ex5_d          : std_ulogic_vector(0 to 3);
signal low_pri_ex6_d          : std_ulogic_vector(0 to 3);
signal xu_iu_ex6_ppc_cpl_d    : std_ulogic_vector(0 to 3);
signal low_pri_counter0_d     : std_ulogic_vector(0 to 7);
signal low_pri_counter1_d     : std_ulogic_vector(0 to 7);
signal low_pri_counter2_d     : std_ulogic_vector(0 to 7);
signal low_pri_counter3_d     : std_ulogic_vector(0 to 7);
signal low_pri_max0_d         : std_ulogic_vector(0 to 5);
signal low_pri_max1_d         : std_ulogic_vector(0 to 5);
signal low_pri_max2_d         : std_ulogic_vector(0 to 5);
signal low_pri_max3_d         : std_ulogic_vector(0 to 5);
signal high_pri_mask_d        : std_ulogic_vector(0 to 3);
signal med_pri_mask_d         : std_ulogic_vector(0 to 3);
signal spr_high_mask_d        : std_ulogic_vector(0 to 3);
signal spr_med_mask_d         : std_ulogic_vector(0 to 3);
signal fiss_dbg_data_d        : std_ulogic_vector(44 to 87);
signal low_pri_rf0_l2         : std_ulogic_vector(0 to 3);
signal low_pri_rf1_l2         : std_ulogic_vector(0 to 3);
signal low_pri_ex1_l2         : std_ulogic_vector(0 to 3);
signal low_pri_ex2_l2         : std_ulogic_vector(0 to 3);
signal low_pri_ex3_l2         : std_ulogic_vector(0 to 3);
signal low_pri_ex4_l2         : std_ulogic_vector(0 to 3);
signal low_pri_ex5_l2         : std_ulogic_vector(0 to 3);
signal low_pri_ex6_l2         : std_ulogic_vector(0 to 3);
signal xu_iu_ex6_ppc_cpl_l2   : std_ulogic_vector(0 to 3);
signal low_pri_counter0_l2    : std_ulogic_vector(0 to 7);
signal low_pri_counter1_l2    : std_ulogic_vector(0 to 7);
signal low_pri_counter2_l2    : std_ulogic_vector(0 to 7);
signal low_pri_counter3_l2    : std_ulogic_vector(0 to 7);
signal low_pri_max0_l2        : std_ulogic_vector(0 to 5);
signal low_pri_max1_l2        : std_ulogic_vector(0 to 5);
signal low_pri_max2_l2        : std_ulogic_vector(0 to 5);
signal low_pri_max3_l2        : std_ulogic_vector(0 to 5);
signal high_pri_mask_l2       : std_ulogic_vector(0 to 3);
signal med_pri_mask_l2        : std_ulogic_vector(0 to 3);
signal spr_high_mask_l2       : std_ulogic_vector(0 to 3);
signal spr_med_mask_l2        : std_ulogic_vector(0 to 3);
signal fiss_dbg_data_l2       : std_ulogic_vector(44 to 87);
signal low_pri_counter0_act   : std_ulogic;
signal low_pri_counter1_act   : std_ulogic;
signal low_pri_counter2_act   : std_ulogic;
signal low_pri_counter3_act   : std_ulogic;
signal low_pri_rf1_act        : std_ulogic;
signal low_pri_ex1_act        : std_ulogic;
signal low_pri_ex2_act        : std_ulogic;
signal low_pri_ex3_act        : std_ulogic;
signal low_pri_ex4_act        : std_ulogic;
signal low_pri_ex5_act        : std_ulogic;
signal low_pri_ex6_act        : std_ulogic;
signal high_pri_mask_din      : std_ulogic_vector(0 to 3);
signal med_pri_mask_din       : std_ulogic_vector(0 to 3);
signal low_pri_en               : std_ulogic_vector(0 to 3);
signal low_pri_val              : std_ulogic_vector(0 to 3);
signal pri_rand                 : std_ulogic_vector(0 to 5);
signal high_priority_valids     : std_ulogic_vector(0 to 3);
signal med_priority_valids      : std_ulogic_vector(0 to 3);
signal n_thread                 : std_ulogic_vector(0 to 3);
signal uc_flush_tid_d           : std_ulogic_vector(0 to 3);
signal uc_flush_tid_l2          : std_ulogic_vector(0 to 3);
signal int_is2_vld              : std_ulogic;
signal iss_is2_vld              : std_ulogic;
signal int_is2_to_ucode         : std_ulogic;
signal is1_dep_hit              : std_ulogic_vector(0 to 3);
signal is2_stall                : std_ulogic_vector(0 to 3);
signal perf_event_d             : std_ulogic_vector(0 to 31);
signal perf_event_l2            : std_ulogic_vector(0 to 31);
signal iu_xu_is2_axu_ldst_tag_int       : std_ulogic_vector(0 to 8);
signal iu_xu_is2_axu_store_int          : std_ulogic;
signal iu_xu_is2_axu_ld_or_st_int       : std_ulogic;
signal iu_xu_is2_instr_int              : std_ulogic_vector(0 to 31);
signal iu_xu_is2_vld_int                : std_ulogic;
signal iu_xu_is2_tid_int                : std_ulogic_vector(0 to 3);
signal iu_xu_is2_error_int              : std_ulogic_vector(0 to 2);
signal iu_xu_is2_pred_update_int        : std_ulogic;
signal iu_xu_is2_pred_taken_cnt_int     : std_ulogic_vector(0 to 1);
signal fiss_uc_is2_ucode_vld_int        : std_ulogic;
signal rf0_str_val_d                    : std_ulogic;
signal rf0_str_val_l2                   : std_ulogic;
signal rf0_ldst_val_d                   : std_ulogic;
signal rf0_ldst_val_l2                  : std_ulogic;
signal rf0_ldst_tid_d                   : std_ulogic_vector(0 to 1);
signal rf0_ldst_tid_l2                  : std_ulogic_vector(0 to 1);
signal rf0_ldst_tag_d                   : std_ulogic_vector(0 to 8);
signal rf0_ldst_tag_l2                  : std_ulogic_vector(0 to 8);
signal rf0_ldst_act                     : std_ulogic;
signal next_tid                         : std_ulogic_vector(0 to 3);
signal hi_did3no0_d   : std_ulogic;
signal hi_did3no1_d   : std_ulogic;
signal hi_did3no2_d   : std_ulogic;
signal hi_did2no0_d   : std_ulogic;
signal hi_did2no1_d   : std_ulogic;
signal hi_did1no0_d   : std_ulogic;
signal md_did3no0_d   : std_ulogic;
signal md_did3no1_d   : std_ulogic;
signal md_did3no2_d   : std_ulogic;
signal md_did2no0_d   : std_ulogic;
signal md_did2no1_d   : std_ulogic;
signal md_did1no0_d   : std_ulogic;
signal hi_n230, hi_n231, hi_n232    : std_ulogic;
signal hi_n220, hi_n221, hi_n210    : std_ulogic;
signal md_n230, md_n231, md_n232    : std_ulogic;
signal md_n220, md_n221, md_n210    : std_ulogic;
signal medpri_v, medpri_v_b, highpri_v, highpri_v_b    : std_ulogic_vector(0 to 3);
signal medpri_v_b0, highpri_v_b0                       : std_ulogic_vector(0 to 3);
signal hi_did0no1, hi_did0no2, hi_did0no3   : std_ulogic;
signal hi_did1no0, hi_did1no2, hi_did1no3   : std_ulogic;
signal hi_did2no1, hi_did2no0, hi_did2no3   : std_ulogic;
signal hi_did3no1, hi_did3no2, hi_did3no0   : std_ulogic;
signal md_did0no1, md_did0no2, md_did0no3   : std_ulogic;
signal md_did1no0, md_did1no2, md_did1no3   : std_ulogic;
signal md_did2no1, md_did2no0, md_did2no3   : std_ulogic;
signal md_did3no1, md_did3no2, md_did3no0   : std_ulogic;
signal hi_sel, hi_sel_b, md_sel, md_sel_b, hi_later, md_later      : std_ulogic_vector(0 to 3);
signal hi_did3no0_din   : std_ulogic;
signal hi_did3no1_din   : std_ulogic;
signal hi_did3no2_din   : std_ulogic;
signal hi_did2no0_din   : std_ulogic;
signal hi_did2no1_din   : std_ulogic;
signal hi_did1no0_din   : std_ulogic;
signal md_did3no0_din   : std_ulogic;
signal md_did3no1_din   : std_ulogic;
signal md_did3no2_din   : std_ulogic;
signal md_did2no0_din   : std_ulogic;
signal md_did2no1_din   : std_ulogic;
signal md_did1no0_din   : std_ulogic;
signal issselhi_b, issselmd_b : std_ulogic_vector(0 to 3);
signal no_hi_v,no_hi_v_n01, no_hi_v_n23 : std_ulogic;
signal hi_l30,  hi_l31,  hi_l32 : std_ulogic;
signal hi_l23,  hi_l20,  hi_l21 : std_ulogic;
signal hi_l12,  hi_l13,  hi_l10 : std_ulogic;
signal hi_l01,  hi_l02,  hi_l03 : std_ulogic;
signal md_l30,  md_l31,  md_l32 : std_ulogic;
signal md_l23,  md_l20,  md_l21 : std_ulogic;
signal md_l12,  md_l13,  md_l10 : std_ulogic;
signal md_l01,  md_l02,  md_l03 : std_ulogic;
signal take, take_b : std_ulogic_vector(0 to 3);
signal no_hi_v_b : std_ulogic;
  BEGIN 

tiup  <=  '1';
act_dis  <=  '0';
d_mode   <=  '0';
mpw2_b   <=  '1';
perv_2to1_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_2,
            din(1)      => pc_iu_sg_2,
            q(0)        => pc_iu_func_sl_thold_1,
            q(1)        => pc_iu_sg_1);
perv_1to0_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_1,
            din(1)      => pc_iu_sg_1,
            q(0)        => pc_iu_func_sl_thold_0,
            q(1)        => pc_iu_sg_0);
perv_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_func_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee => forcee,
            thold_b     => pc_iu_func_sl_thold_0_b);
uc_flush_tid_latch: tri_rlmreg_p
  generic map (width => uc_flush_tid_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(uc_flush_tid_offset to uc_flush_tid_offset + uc_flush_tid_l2'length-1),
            scout   => sov(uc_flush_tid_offset to uc_flush_tid_offset + uc_flush_tid_l2'length-1),
            din     => uc_flush_tid_d,
            dout    => uc_flush_tid_l2);
xu_iu_need_hole_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_iu_need_hole_offset),
            scout   => sov(xu_iu_need_hole_offset),
            din     => xu_iu_need_hole_d,
            dout    => xu_iu_need_hole_l2);
xu_iu_xucr0_rel_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_iu_xucr0_rel_offset),
            scout   => sov(xu_iu_xucr0_rel_offset),
            din     => xu_iu_xucr0_rel_d,
            dout    => xu_iu_xucr0_rel_l2);
an_ac_back_inv_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(an_ac_back_inv_offset),
            scout   => sov(an_ac_back_inv_offset),
            din     => an_ac_back_inv_d,
            dout    => an_ac_back_inv_l2);
an_ac_back_inv_target_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(an_ac_back_inv_target_offset),
            scout   => sov(an_ac_back_inv_target_offset),
            din     => an_ac_back_inv_target_d,
            dout    => an_ac_back_inv_target_l2);
gap_l2_rel_hole_dly1_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(gap_l2_rel_hole_dly1_offset),
            scout   => sov(gap_l2_rel_hole_dly1_offset),
            din     => gap_l2_rel_hole_dly1_d,
            dout    => gap_l2_rel_hole_dly1_l2);
gap_l2_rel_hole_dly2_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(gap_l2_rel_hole_dly2_offset),
            scout   => sov(gap_l2_rel_hole_dly2_offset),
            din     => gap_l2_rel_hole_dly2_d,
            dout    => gap_l2_rel_hole_dly2_l2);
gap_l2_tag_dly1_latch: tri_rlmreg_p
  generic map (width => gap_l2_tag_dly1_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(gap_l2_tag_dly1_offset to gap_l2_tag_dly1_offset + gap_l2_tag_dly1_l2'length-1),
            scout   => sov(gap_l2_tag_dly1_offset to gap_l2_tag_dly1_offset + gap_l2_tag_dly1_l2'length-1),
            din     => gap_l2_tag_dly1_d,
            dout    => gap_l2_tag_dly1_l2);
gap_l2_tag_dly2_latch: tri_rlmreg_p
  generic map (width => gap_l2_tag_dly2_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(gap_l2_tag_dly2_offset to gap_l2_tag_dly2_offset + gap_l2_tag_dly2_l2'length-1),
            scout   => sov(gap_l2_tag_dly2_offset to gap_l2_tag_dly2_offset + gap_l2_tag_dly2_l2'length-1),
            din     => gap_l2_tag_dly2_d,
            dout    => gap_l2_tag_dly2_l2);
is2_vld: tri_rlmreg_p
  generic map (width => is2_vld_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_vld_offset to is2_vld_offset + is2_vld_l2'length-1),
            scout   => sov(is2_vld_offset to is2_vld_offset + is2_vld_l2'length-1),
            din     => is2_vld_d,
            dout    => is2_vld_l2);
hole_delay0:   tri_rlmreg_p
  generic map (width => hole_delay0_l2'length,   init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(hole_delay0_offset   to hole_delay0_offset   + hole_delay0_l2'length-1),
            scout   => sov(hole_delay0_offset   to hole_delay0_offset   + hole_delay0_l2'length-1),
            din     => hole_delay0_d,
            dout    => hole_delay0_l2);
hole_delay1:   tri_rlmreg_p
  generic map (width => hole_delay1_l2'length,   init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(hole_delay1_offset   to hole_delay1_offset   + hole_delay1_l2'length-1),
            scout   => sov(hole_delay1_offset   to hole_delay1_offset   + hole_delay1_l2'length-1),
            din     => hole_delay1_d,
            dout    => hole_delay1_l2);
hole_delay2:   tri_rlmreg_p
  generic map (width => hole_delay2_l2'length,   init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(hole_delay2_offset   to hole_delay2_offset   + hole_delay2_l2'length-1),
            scout   => sov(hole_delay2_offset   to hole_delay2_offset   + hole_delay2_l2'length-1),
            din     => hole_delay2_d,
            dout    => hole_delay2_l2);
hole_delay3:   tri_rlmreg_p
  generic map (width => hole_delay3_l2'length,   init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(hole_delay3_offset   to hole_delay3_offset   + hole_delay3_l2'length-1),
            scout   => sov(hole_delay3_offset   to hole_delay3_offset   + hole_delay3_l2'length-1),
            din     => hole_delay3_d,
            dout    => hole_delay3_l2);
med_pri_mask: tri_rlmreg_p
  generic map (width => med_pri_mask_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(med_pri_mask_offset to med_pri_mask_offset + med_pri_mask_l2'length-1),
            scout   => sov(med_pri_mask_offset to med_pri_mask_offset + med_pri_mask_l2'length-1),
            din     => med_pri_mask_d,
            dout    => med_pri_mask_l2);
high_pri_mask: tri_rlmreg_p
  generic map (width => high_pri_mask_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(high_pri_mask_offset to high_pri_mask_offset + high_pri_mask_l2'length-1),
            scout   => sov(high_pri_mask_offset to high_pri_mask_offset + high_pri_mask_l2'length-1),
            din     => high_pri_mask_d,
            dout    => high_pri_mask_l2);
spr_high_mask: tri_rlmreg_p
  generic map (width => spr_high_mask_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(spr_high_mask_offset to spr_high_mask_offset + spr_high_mask_l2'length-1),
            scout   => sov(spr_high_mask_offset to spr_high_mask_offset + spr_high_mask_l2'length-1),
            din     => spr_high_mask_d,
            dout    => spr_high_mask_l2);
spr_med_mask: tri_rlmreg_p
  generic map (width => spr_med_mask_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(spr_med_mask_offset to spr_med_mask_offset + spr_med_mask_l2'length-1),
            scout   => sov(spr_med_mask_offset to spr_med_mask_offset + spr_med_mask_l2'length-1),
            din     => spr_med_mask_d,
            dout    => spr_med_mask_l2);
low_pri_max0: tri_rlmreg_p
  generic map (width => low_pri_max0_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_max0_offset to low_pri_max0_offset + low_pri_max0_l2'length-1),
            scout   => sov(low_pri_max0_offset to low_pri_max0_offset + low_pri_max0_l2'length-1),
            din     => low_pri_max0_d,
            dout    => low_pri_max0_l2);
low_pri_max1: tri_rlmreg_p
  generic map (width => low_pri_max1_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_max1_offset to low_pri_max1_offset + low_pri_max1_l2'length-1),
            scout   => sov(low_pri_max1_offset to low_pri_max1_offset + low_pri_max1_l2'length-1),
            din     => low_pri_max1_d,
            dout    => low_pri_max1_l2);
low_pri_max2: tri_rlmreg_p
  generic map (width => low_pri_max2_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_max2_offset to low_pri_max2_offset + low_pri_max2_l2'length-1),
            scout   => sov(low_pri_max2_offset to low_pri_max2_offset + low_pri_max2_l2'length-1),
            din     => low_pri_max2_d,
            dout    => low_pri_max2_l2);
low_pri_max3: tri_rlmreg_p
  generic map (width => low_pri_max3_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_max3_offset to low_pri_max3_offset + low_pri_max3_l2'length-1),
            scout   => sov(low_pri_max3_offset to low_pri_max3_offset + low_pri_max3_l2'length-1),
            din     => low_pri_max3_d,
            dout    => low_pri_max3_l2);
low_pri_counter0: tri_rlmreg_p
  generic map (width => low_pri_counter0_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_counter0_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_counter0_offset to low_pri_counter0_offset + low_pri_counter0_l2'length-1),
            scout   => sov(low_pri_counter0_offset to low_pri_counter0_offset + low_pri_counter0_l2'length-1),
            din     => low_pri_counter0_d,
            dout    => low_pri_counter0_l2);
low_pri_counter1: tri_rlmreg_p
  generic map (width => low_pri_counter1_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_counter1_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_counter1_offset to low_pri_counter1_offset + low_pri_counter1_l2'length-1),
            scout   => sov(low_pri_counter1_offset to low_pri_counter1_offset + low_pri_counter1_l2'length-1),
            din     => low_pri_counter1_d,
            dout    => low_pri_counter1_l2);
low_pri_counter2: tri_rlmreg_p
  generic map (width => low_pri_counter2_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_counter2_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_counter2_offset to low_pri_counter2_offset + low_pri_counter2_l2'length-1),
            scout   => sov(low_pri_counter2_offset to low_pri_counter2_offset + low_pri_counter2_l2'length-1),
            din     => low_pri_counter2_d,
            dout    => low_pri_counter2_l2);
low_pri_counter3: tri_rlmreg_p
  generic map (width => low_pri_counter3_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_counter3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_counter3_offset to low_pri_counter3_offset + low_pri_counter3_l2'length-1),
            scout   => sov(low_pri_counter3_offset to low_pri_counter3_offset + low_pri_counter3_l2'length-1),
            din     => low_pri_counter3_d,
            dout    => low_pri_counter3_l2);
low_pri_rf0: tri_rlmreg_p
  generic map (width => low_pri_rf0_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_rf0_offset to low_pri_rf0_offset + low_pri_rf0_l2'length-1),
            scout   => sov(low_pri_rf0_offset to low_pri_rf0_offset + low_pri_rf0_l2'length-1),
            din     => low_pri_rf0_d,
            dout    => low_pri_rf0_l2);
low_pri_rf1: tri_rlmreg_p
  generic map (width => low_pri_rf1_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_rf1_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_rf1_offset to low_pri_rf1_offset + low_pri_rf1_l2'length-1),
            scout   => sov(low_pri_rf1_offset to low_pri_rf1_offset + low_pri_rf1_l2'length-1),
            din     => low_pri_rf1_d,
            dout    => low_pri_rf1_l2);
low_pri_ex1: tri_rlmreg_p
  generic map (width => low_pri_ex1_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_ex1_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_ex1_offset to low_pri_ex1_offset + low_pri_ex1_l2'length-1),
            scout   => sov(low_pri_ex1_offset to low_pri_ex1_offset + low_pri_ex1_l2'length-1),
            din     => low_pri_ex1_d,
            dout    => low_pri_ex1_l2);
low_pri_ex2: tri_rlmreg_p
  generic map (width => low_pri_ex2_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_ex2_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_ex2_offset to low_pri_ex2_offset + low_pri_ex2_l2'length-1),
            scout   => sov(low_pri_ex2_offset to low_pri_ex2_offset + low_pri_ex2_l2'length-1),
            din     => low_pri_ex2_d,
            dout    => low_pri_ex2_l2);
low_pri_ex3: tri_rlmreg_p
  generic map (width => low_pri_ex3_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_ex3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_ex3_offset to low_pri_ex3_offset + low_pri_ex3_l2'length-1),
            scout   => sov(low_pri_ex3_offset to low_pri_ex3_offset + low_pri_ex3_l2'length-1),
            din     => low_pri_ex3_d,
            dout    => low_pri_ex3_l2);
low_pri_ex4: tri_rlmreg_p
  generic map (width => low_pri_ex4_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_ex4_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_ex4_offset to low_pri_ex4_offset + low_pri_ex4_l2'length-1),
            scout   => sov(low_pri_ex4_offset to low_pri_ex4_offset + low_pri_ex4_l2'length-1),
            din     => low_pri_ex4_d,
            dout    => low_pri_ex4_l2);
low_pri_ex5: tri_rlmreg_p
  generic map (width => low_pri_ex5_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_ex5_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_ex5_offset to low_pri_ex5_offset + low_pri_ex5_l2'length-1),
            scout   => sov(low_pri_ex5_offset to low_pri_ex5_offset + low_pri_ex5_l2'length-1),
            din     => low_pri_ex5_d,
            dout    => low_pri_ex5_l2);
low_pri_ex6: tri_rlmreg_p
  generic map (width => low_pri_ex6_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => low_pri_ex6_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(low_pri_ex6_offset to low_pri_ex6_offset + low_pri_ex6_l2'length-1),
            scout   => sov(low_pri_ex6_offset to low_pri_ex6_offset + low_pri_ex6_l2'length-1),
            din     => low_pri_ex6_d,
            dout    => low_pri_ex6_l2);
xu_iu_ex6_ppc_cpl_reg: tri_rlmreg_p
  generic map (width => xu_iu_ex6_ppc_cpl_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_iu_ex6_ppc_cpl_offset to xu_iu_ex6_ppc_cpl_offset + xu_iu_ex6_ppc_cpl_l2'length-1),
            scout   => sov(xu_iu_ex6_ppc_cpl_offset to xu_iu_ex6_ppc_cpl_offset + xu_iu_ex6_ppc_cpl_l2'length-1),
            din     => xu_iu_ex6_ppc_cpl_d,
            dout    => xu_iu_ex6_ppc_cpl_l2);
event_bus_enable_d  <=  pc_iu_event_bus_enable;
event_enable_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(event_bus_enable_offset),
            scout   => sov(event_bus_enable_offset),
            din     => event_bus_enable_d,
            dout    => event_bus_enable_q);
trace_bus_enable_d  <=  pc_iu_trace_bus_enable;
trace_enable_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => trace_bus_enable_d,
            dout    => trace_bus_enable_q);
perf_event: tri_rlmreg_p
  generic map (width => perf_event_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => event_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_event_offset to perf_event_offset + perf_event_l2'length-1),
            scout   => sov(perf_event_offset to perf_event_offset + perf_event_l2'length-1),
            din     => perf_event_d,
            dout    => perf_event_l2);
fiss_dbg_data_latch: tri_rlmreg_p
  generic map (width => fiss_dbg_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(fiss_dbg_data_offset to fiss_dbg_data_offset + fiss_dbg_data_l2'length-1),
            scout   => sov(fiss_dbg_data_offset to fiss_dbg_data_offset + fiss_dbg_data_l2'length-1),
            din     => fiss_dbg_data_d,
            dout    => fiss_dbg_data_l2);
spare_latch: tri_rlmreg_p
  generic map (width => spare_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(spare_offset to spare_offset + spare_l2'length-1),
            scout   => sov(spare_offset to spare_offset + spare_l2'length-1),
            din     => spare_l2,
            dout    => spare_l2);
rf0_str_val: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(rf0_str_val_offset),
            scout   => sov(rf0_str_val_offset),
            din     => rf0_str_val_d,
            dout    => rf0_str_val_l2);
rf0_ldst_val: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(rf0_ldst_val_offset),
            scout   => sov(rf0_ldst_val_offset),
            din     => rf0_ldst_val_d,
            dout    => rf0_ldst_val_l2);
rf0_ldst_tid: tri_rlmreg_p
  generic map (width => rf0_ldst_tid_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf0_ldst_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(rf0_ldst_tid_offset to rf0_ldst_tid_offset + rf0_ldst_tid_l2'length-1),
            scout   => sov(rf0_ldst_tid_offset to rf0_ldst_tid_offset + rf0_ldst_tid_l2'length-1),
            din     => rf0_ldst_tid_d,
            dout    => rf0_ldst_tid_l2);
rf0_ldst_tag: tri_rlmreg_p
  generic map (width => rf0_ldst_tag_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf0_ldst_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(rf0_ldst_tag_offset to rf0_ldst_tag_offset + rf0_ldst_tag_l2'length-1),
            scout   => sov(rf0_ldst_tag_offset to rf0_ldst_tag_offset + rf0_ldst_tag_l2'length-1),
            din     => rf0_ldst_tag_d,
            dout    => rf0_ldst_tag_l2);
rf0_took_latch:  tri_rlmreg_p 
  generic map (init => 65, expand_type => expand_type, width => 12)
  port map (
            nclk     => nclk,
            act      => tiup,
            vd       => vdd,
            gd       => gnd,      
            forcee => forcee,
            thold_b  => pc_iu_func_sl_thold_0_b,
            sg       => pc_iu_sg_0,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin     => siv(rf0_took_offset to rf0_took_offset + 12-1),
            scout    => sov(rf0_took_offset to rf0_took_offset + 12-1),
            din(00)  => hi_did3no0_d,
            din(01)  => hi_did3no1_d,
            din(02)  => hi_did3no2_d,
            din(03)  => hi_did2no0_d,
            din(04)  => hi_did2no1_d,
            din(05)  => hi_did1no0_d,
            din(06)  => md_did3no0_d,
            din(07)  => md_did3no1_d,
            din(08)  => md_did3no2_d,
            din(09)  => md_did2no0_d,
            din(10)  => md_did2no1_d,
            din(11)  => md_did1no0_d,                                              
            dout(00) => hi_did3no0,
            dout(01) => hi_did3no1,
            dout(02) => hi_did3no2,
            dout(03) => hi_did2no0,
            dout(04) => hi_did2no1,
            dout(05) => hi_did1no0,
            dout(06) => md_did3no0,
            dout(07) => md_did3no1,
            dout(08) => md_did3no2,
            dout(09) => md_did2no0,
            dout(10) => md_did2no1,
            dout(11) => md_did1no0                                       
            );
hi_did3no0_d     <=  pri_rand(0) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else hi_did3no0_din;
hi_did3no1_d     <=  pri_rand(1) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else hi_did3no1_din;
hi_did3no2_d     <=  pri_rand(2) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else hi_did3no2_din;
hi_did2no0_d     <=  pri_rand(3) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else hi_did2no0_din;
hi_did2no1_d     <=  pri_rand(4) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else hi_did2no1_din;
hi_did1no0_d     <=  pri_rand(5) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else hi_did1no0_din;
md_did3no0_d     <=  pri_rand(0) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else md_did3no0_din;
md_did3no1_d     <=  pri_rand(1) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else md_did3no1_din;
md_did3no2_d     <=  pri_rand(2) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else md_did3no2_din;
md_did2no0_d     <=  pri_rand(3) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else md_did2no0_din;
md_did2no1_d     <=  pri_rand(4) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else md_did2no1_din;
md_did1no0_d     <=  pri_rand(5) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush_tid(0 to 3)))) = '1' else md_did1no0_din;
pri_rand(0 TO 5) <=  "001000" when spr_fiss_pri_rand(0 to 4) = "00000" else  
                    "100111" when spr_fiss_pri_rand(0 to 4) = "00001" else  
                    "110111" when spr_fiss_pri_rand(0 to 4) = "00010" else  
                    "000001" when spr_fiss_pri_rand(0 to 4) = "00011" else  
                    "000110" when spr_fiss_pri_rand(0 to 4) = "00100" else  
                    "001001" when spr_fiss_pri_rand(0 to 4) = "00101" else  
                    "011000" when spr_fiss_pri_rand(0 to 4) = "00110" else  
                    "111101" when spr_fiss_pri_rand(0 to 4) = "00111" else  
                    "100101" when spr_fiss_pri_rand(0 to 4) = "01000" else  
                    "010110" when spr_fiss_pri_rand(0 to 4) = "01001" else  
                    "101101" when spr_fiss_pri_rand(0 to 4) = "01010" else  
                    "111110" when spr_fiss_pri_rand(0 to 4) = "01011" else  
                    "110110" when spr_fiss_pri_rand(0 to 4) = "01100" else  
                    "101001" when spr_fiss_pri_rand(0 to 4) = "01101" else  
                    "000000" when spr_fiss_pri_rand(0 to 4) = "01110" else  
                    "111010" when spr_fiss_pri_rand(0 to 4) = "01111" else  
                    "000111" when spr_fiss_pri_rand(0 to 4) = "10000" else  
                    "111001" when spr_fiss_pri_rand(0 to 4) = "10001" else  
                    "111000" when spr_fiss_pri_rand(0 to 4) = "10010" else  
                    "011010" when spr_fiss_pri_rand(0 to 4) = "10011" else  
                    "111111" when spr_fiss_pri_rand(0 to 4) = "10100" else  
                    "010010" when spr_fiss_pri_rand(0 to 4) = "10101" else  
                    "000010" when spr_fiss_pri_rand(0 to 4) = "10110" else  
                    "000101" when spr_fiss_pri_rand(0 to 4) = "10111" else  
                    "111111" when spr_fiss_pri_rand(0 to 4) = "11000" else  
                    "000000" when spr_fiss_pri_rand(0 to 4) = "11001" else  
                    "011010" when spr_fiss_pri_rand(0 to 4) = "11010" else  
                    "100101" when spr_fiss_pri_rand(0 to 4) = "11011" else  
                    "001001" when spr_fiss_pri_rand(0 to 4) = "11100" else  
                    "110110" when spr_fiss_pri_rand(0 to 4) = "11101" else  
                    "000111" when spr_fiss_pri_rand(0 to 4) = "11110" else  
                    "111000" ;
hole0_nor2:   hole0      <=  not (hole0_b   or xu_iu_is2_flush_tid(0));
hole0_b                  <=  not (((n_thread(0)   and fdep_fiss_t0_is2_hole_delay(0))   or hole_delay0_l2(0))   and not uc_flush_tid_l2(0));
hole_delay0_d(0) <=       ((n_thread(0)   and fdep_fiss_t0_is2_hole_delay(1))   or hole_delay0_l2(1))   and not uc_flush_tid_l2(0)   and not xu_iu_is2_flush_tid(0);
hole_delay0_d(1) <=        (n_thread(0)   and fdep_fiss_t0_is2_hole_delay(2))                           and not uc_flush_tid_l2(0)   and not xu_iu_is2_flush_tid(0);
hole1_nor2:   hole1      <=  not (hole1_b   or xu_iu_is2_flush_tid(1));
hole1_b                  <=  not (((n_thread(1)   and fdep_fiss_t1_is2_hole_delay(0))   or hole_delay1_l2(0))   and not uc_flush_tid_l2(1));
hole_delay1_d(0) <=       ((n_thread(1)   and fdep_fiss_t1_is2_hole_delay(1))   or hole_delay1_l2(1))   and not uc_flush_tid_l2(1)   and not xu_iu_is2_flush_tid(1);
hole_delay1_d(1) <=        (n_thread(1)   and fdep_fiss_t1_is2_hole_delay(2))                           and not uc_flush_tid_l2(1)   and not xu_iu_is2_flush_tid(1);
hole2_nor2:   hole2      <=  not (hole2_b   or xu_iu_is2_flush_tid(2));
hole2_b                  <=  not (((n_thread(2)   and fdep_fiss_t2_is2_hole_delay(0))   or hole_delay2_l2(0))   and not uc_flush_tid_l2(2));
hole_delay2_d(0) <=       ((n_thread(2)   and fdep_fiss_t2_is2_hole_delay(1))   or hole_delay2_l2(1))   and not uc_flush_tid_l2(2)   and not xu_iu_is2_flush_tid(2);
hole_delay2_d(1) <=        (n_thread(2)   and fdep_fiss_t2_is2_hole_delay(2))                           and not uc_flush_tid_l2(2)   and not xu_iu_is2_flush_tid(2);
hole3_nor2:   hole3      <=  not (hole3_b   or xu_iu_is2_flush_tid(3));
hole3_b                  <=  not (((n_thread(3)   and fdep_fiss_t3_is2_hole_delay(0))   or hole_delay3_l2(0))   and not uc_flush_tid_l2(3));
hole_delay3_d(0) <=       ((n_thread(3)   and fdep_fiss_t3_is2_hole_delay(1))   or hole_delay3_l2(1))   and not uc_flush_tid_l2(3)   and not xu_iu_is2_flush_tid(3);
hole_delay3_d(1) <=        (n_thread(3)   and fdep_fiss_t3_is2_hole_delay(2))                           and not uc_flush_tid_l2(3)   and not xu_iu_is2_flush_tid(3);
is1_dep_hit(0) <=  not(fdep_fiss_t0_is1_xu_dep_hit_b) or not(i_axu_is1_dep_hit_t0_b);
is1_dep_hit(1) <=  not(fdep_fiss_t1_is1_xu_dep_hit_b) or not(i_axu_is1_dep_hit_t1_b);
is1_dep_hit(2) <=  not(fdep_fiss_t2_is1_xu_dep_hit_b) or not(i_axu_is1_dep_hit_t2_b);
is1_dep_hit(3) <=  not(fdep_fiss_t3_is1_xu_dep_hit_b) or not(i_axu_is1_dep_hit_t3_b);
is2_vld_d(0) <=  fdep_fiss_t0_is2early_vld and not is1_dep_hit(0) and not xu_iu_is2_flush_tid(0) and not uc_flush_tid_l2(0) when is2_stall(0) = '0' else
                is2_vld_l2(0)                                    and not xu_iu_is2_flush_tid(0) and not uc_flush_tid_l2(0);
is2_vld_d(1) <=  fdep_fiss_t1_is2early_vld and not is1_dep_hit(1) and not xu_iu_is2_flush_tid(1) and not uc_flush_tid_l2(1) when is2_stall(1) = '0' else
                is2_vld_l2(1)                                    and not xu_iu_is2_flush_tid(1) and not uc_flush_tid_l2(1);
is2_vld_d(2) <=  fdep_fiss_t2_is2early_vld and not is1_dep_hit(2) and not xu_iu_is2_flush_tid(2) and not uc_flush_tid_l2(2) when is2_stall(2) = '0' else
                is2_vld_l2(2)                                    and not xu_iu_is2_flush_tid(2) and not uc_flush_tid_l2(2);
is2_vld_d(3) <=  fdep_fiss_t3_is2early_vld and not is1_dep_hit(3) and not xu_iu_is2_flush_tid(3) and not uc_flush_tid_l2(3) when is2_stall(3) = '0' else
                is2_vld_l2(3)                                    and not xu_iu_is2_flush_tid(3) and not uc_flush_tid_l2(3);
is2_stall(0) <=  (not next_tid(0) and is2_vld_l2(0)) or (not i_afi_is2_take_t(0) and i_afd_is2_t0_instr_v);
is2_stall(1) <=  (not next_tid(1) and is2_vld_l2(1)) or (not i_afi_is2_take_t(1) and i_afd_is2_t1_instr_v);
is2_stall(2) <=  (not next_tid(2) and is2_vld_l2(2)) or (not i_afi_is2_take_t(2) and i_afd_is2_t2_instr_v);
is2_stall(3) <=  (not next_tid(3) and is2_vld_l2(3)) or (not i_afi_is2_take_t(3) and i_afd_is2_t3_instr_v);
high_priority_valids     <=  high_pri_mask_l2;
med_priority_valids      <=  med_pri_mask_l2;
highpri_v_b0      <=  not high_priority_valids;
medpri_v_b0       <=  not med_priority_valids;
highpri0v_inv:  highpri_v(0) <=  not highpri_v_b0(0);
highpri1v_inv:  highpri_v(1) <=  not highpri_v_b0(1);
highpri2v_inv:  highpri_v(2) <=  not highpri_v_b0(2);
highpri3v_inv:  highpri_v(3) <=  not highpri_v_b0(3);
highpri0vb_inv: highpri_v_b(0) <=  not highpri_v(0);
highpri1vb_inv: highpri_v_b(1) <=  not highpri_v(1);
highpri2vb_inv: highpri_v_b(2) <=  not highpri_v(2);
highpri3vb_inv: highpri_v_b(3) <=  not highpri_v(3);
hi_sel_nor23:   hi_sel(3) <=  not (highpri_v_b(3) or hi_later(3));
hi_sel_nand33:  hi_later(3) <=  not (hi_l30 and hi_l31 and hi_l32);
hi_sel_nand230: hi_l30           <=  not (hi_did3no0 and highpri_v(0));
hi_sel_nand231: hi_l31           <=  not (hi_did3no1 and highpri_v(1));
hi_sel_nand232: hi_l32           <=  not (hi_did3no2 and highpri_v(2));
hi_sel_nor22:   hi_sel(2) <=  not (highpri_v_b(2) or hi_later(2));
hi_sel_nand32:  hi_later(2) <=  not (hi_l23 and hi_l20 and hi_l21);
hi_sel_nand223: hi_l23           <=  not (hi_did2no3 and highpri_v(3));
hi_sel_nand220: hi_l20           <=  not (hi_did2no0 and highpri_v(0));
hi_sel_nand221: hi_l21           <=  not (hi_did2no1 and highpri_v(1));
hi_sel_nor21:   hi_sel(1) <=  not (highpri_v_b(1) or hi_later(1));
hi_sel_nand31:  hi_later(1) <=  not (hi_l12 and hi_l13 and hi_l10);
hi_sel_nand212: hi_l12           <=  not (hi_did1no2 and highpri_v(2));
hi_sel_nand213: hi_l13           <=  not (hi_did1no3 and highpri_v(3));
hi_sel_nand210: hi_l10           <=  not (hi_did1no0 and highpri_v(0));
hi_sel_nor20:   hi_sel(0) <=  not (highpri_v_b(0) or hi_later(0));
hi_sel_nand30:  hi_later(0) <=  not (hi_l01 and hi_l02 and hi_l03);
hi_sel_nand201: hi_l01           <=  not (hi_did0no1 and highpri_v(1));
hi_sel_nand202: hi_l02           <=  not (hi_did0no2 and highpri_v(2));
hi_sel_nand203: hi_l03           <=  not (hi_did0no3 and highpri_v(3));
medpri0v_inv:   medpri_v(0) <=  not medpri_v_b0(0);
medpri1v_inv:   medpri_v(1) <=  not medpri_v_b0(1);
medpri2v_inv:   medpri_v(2) <=  not medpri_v_b0(2);
medpri3v_inv:   medpri_v(3) <=  not medpri_v_b0(3);
medpri0vb_inv:  medpri_v_b(0) <=  not medpri_v(0);
medpri1vb_inv:  medpri_v_b(1) <=  not medpri_v(1);
medpri2vb_inv:  medpri_v_b(2) <=  not medpri_v(2);
medpri3vb_inv:  medpri_v_b(3) <=  not medpri_v(3);
md_sel_nor23:   md_sel(3) <=  not (medpri_v_b(3) or md_later(3));
md_sel_nand33:  md_later(3) <=  not (md_l30 and md_l31 and md_l32);
md_sel_nand230: md_l30           <=  not (md_did3no0 and medpri_v(0));
md_sel_nand231: md_l31           <=  not (md_did3no1 and medpri_v(1));
md_sel_nand232: md_l32           <=  not (md_did3no2 and medpri_v(2));
md_sel_nor22:   md_sel(2) <=  not (medpri_v_b(2) or md_later(2));
md_sel_nand32:  md_later(2) <=  not (md_l23 and md_l20 and md_l21);
md_sel_nand223: md_l23           <=  not (md_did2no3 and medpri_v(3));
md_sel_nand220: md_l20           <=  not (md_did2no0 and medpri_v(0));
md_sel_nand221: md_l21           <=  not (md_did2no1 and medpri_v(1));
md_sel_nor21:   md_sel(1) <=  not (medpri_v_b(1) or md_later(1));
md_sel_nand31:  md_later(1) <=  not (md_l12 and md_l13 and md_l10);
md_sel_nand212: md_l12           <=  not (md_did1no2 and medpri_v(2));
md_sel_nand213: md_l13           <=  not (md_did1no3 and medpri_v(3));
md_sel_nand210: md_l10           <=  not (md_did1no0 and medpri_v(0));
md_sel_nor20:   md_sel(0) <=  not (medpri_v_b(0) or md_later(0));
md_sel_nand30:  md_later(0) <=  not (md_l01 and md_l02 and md_l03);
md_sel_nand201: md_l01           <=  not (md_did0no1 and medpri_v(1));
md_sel_nand202: md_l02           <=  not (md_did0no2 and medpri_v(2));
md_sel_nand203: md_l03           <=  not (md_did0no3 and medpri_v(3));
hi_sel_inv0:            hi_sel_b(0) <=  not hi_sel(0);
hi_sel_inv1:            hi_sel_b(1) <=  not hi_sel(1);
hi_sel_inv2:            hi_sel_b(2) <=  not hi_sel(2);
hi_sel_inv3:            hi_sel_b(3) <=  not hi_sel(3);
hi_reordf_nand230:      hi_did3no0_din   <=  not (hi_sel_b(3) and hi_n230);
hi_reordf_nand231:      hi_did3no1_din   <=  not (hi_sel_b(3) and hi_n231);
hi_reordf_nand232:      hi_did3no2_din   <=  not (hi_sel_b(3) and hi_n232);
hi_reord_nand230:       hi_n230          <=  not (hi_sel_b(0) and hi_did3no0);
hi_reord_nand231:       hi_n231          <=  not (hi_sel_b(1) and hi_did3no1);
hi_reord_nand232:       hi_n232          <=  not (hi_sel_b(2) and hi_did3no2);
hi_reordf_nand220:      hi_did2no0_din   <=  not(hi_sel_b(2) and hi_n220);
hi_reord_nand220:       hi_n220          <=  not(hi_sel_b(0) and hi_did2no0);
hi_reordf_nand221:      hi_did2no1_din   <=  not(hi_sel_b(2) and hi_n221);
hi_reord_nand221:       hi_n221          <=  not(hi_sel_b(1) and hi_did2no1);
hi_reord_inv23:         hi_did2no3       <=  not hi_did3no2;
hi_reordf_nand210:      hi_did1no0_din   <=  not(hi_sel_b(1) and hi_n210);
hi_reord_nand210:       hi_n210          <=  not(hi_sel_b(0) and hi_did1no0);
hi_reord_inv12:         hi_did1no2       <=  not hi_did2no1;
hi_reord_inv13:         hi_did1no3       <=  not hi_did3no1;
hi_reord_inv01:         hi_did0no1       <=  not hi_did1no0;
hi_reord_inv02:         hi_did0no2       <=  not hi_did2no0;
hi_reord_inv03:         hi_did0no3       <=  not hi_did3no0;
md_sel_inv0:            md_sel_b(0) <=  not md_sel(0);
md_sel_inv1:            md_sel_b(1) <=  not md_sel(1);
md_sel_inv2:            md_sel_b(2) <=  not md_sel(2);
md_sel_inv3:            md_sel_b(3) <=  not md_sel(3);
md_reordf_nand230:      md_did3no0_din   <=  not (md_sel_b(3) and md_n230);
md_reordf_nand231:      md_did3no1_din   <=  not (md_sel_b(3) and md_n231);
md_reordf_nand232:      md_did3no2_din   <=  not (md_sel_b(3) and md_n232);
md_reord_nand230:       md_n230          <=  not (md_sel_b(0) and md_did3no0);
md_reord_nand231:       md_n231          <=  not (md_sel_b(1) and md_did3no1);
md_reord_nand232:       md_n232          <=  not (md_sel_b(2) and md_did3no2);
md_reordf_nand220:      md_did2no0_din   <=  not(md_sel_b(2) and md_n220);
md_reord_nand220:       md_n220          <=  not(md_sel_b(0) and md_did2no0);
md_reordf_nand221:      md_did2no1_din   <=  not(md_sel_b(2) and md_n221);
md_reord_nand221:       md_n221          <=  not(md_sel_b(1) and md_did2no1);
md_reord_inv23:         md_did2no3       <=  not md_did3no2;
md_reordf_nand210:      md_did1no0_din   <=  not(md_sel_b(1) and md_n210);
md_reord_nand210:       md_n210          <=  not(md_sel_b(0) and md_did1no0);
md_reord_inv12:         md_did1no2       <=  not md_did2no1;
md_reord_inv13:         md_did1no3       <=  not md_did3no1;
md_reord_inv01:         md_did0no1       <=  not md_did1no0;
md_reord_inv02:         md_did0no2       <=  not md_did2no0;
md_reord_inv03:         md_did0no3       <=  not md_did3no0;
nohi_nor21:     no_hi_v_n01              <=  not (highpri_v(0) or highpri_v(1));
nohi_nor22:     no_hi_v_n23              <=  not (highpri_v(2) or highpri_v(3));
nohi_nand2:     no_hi_v_b                <=  not (no_hi_v_n01 and no_hi_v_n23);
nohi_inv:       no_hi_v                  <=  not (no_hi_v_b);
isssel0_inv:    issselhi_b(0) <=  not (hi_sel(0));
isssel1_inv:    issselhi_b(1) <=  not (hi_sel(1));
isssel2_inv:    issselhi_b(2) <=  not (hi_sel(2));
isssel3_inv:    issselhi_b(3) <=  not (hi_sel(3));
isssel0_bnand2: issselmd_b(0) <=  not (md_sel(0) and no_hi_v);
isssel1_bnand2: issselmd_b(1) <=  not (md_sel(1) and no_hi_v);
isssel2_bnand2: issselmd_b(2) <=  not (md_sel(2) and no_hi_v);
isssel3_bnand2: issselmd_b(3) <=  not (md_sel(3) and no_hi_v);
isssel0_fnand2: take(0) <=  not (issselhi_b(0) and issselmd_b(0));
isssel1_fnand2: take(1) <=  not (issselhi_b(1) and issselmd_b(1));
isssel2_fnand2: take(2) <=  not (issselhi_b(2) and issselmd_b(2));
isssel3_fnand2: take(3) <=  not (issselhi_b(3) and issselmd_b(3));
nexttid0_fnand2: next_tid(0) <=  not (issselhi_b(0) and issselmd_b(0));
nexttid1_fnand2: next_tid(1) <=  not (issselhi_b(1) and issselmd_b(1));
nexttid2_fnand2: next_tid(2) <=  not (issselhi_b(2) and issselmd_b(2));
nexttid3_fnand2: next_tid(3) <=  not (issselhi_b(3) and issselmd_b(3));
take0_rp1_inv: take_b(0) <=  not(take(0));
take1_rp1_inv: take_b(1) <=  not(take(1));
take2_rp1_inv: take_b(2) <=  not(take(2));
take3_rp1_inv: take_b(3) <=  not(take(3));
take0_rp2_inv: fiss_fdep_is2_take0       <=  not(take_b(0));
take1_rp2_inv: fiss_fdep_is2_take1       <=  not(take_b(1));
take2_rp2_inv: fiss_fdep_is2_take2       <=  not(take_b(2));
take3_rp2_inv: fiss_fdep_is2_take3       <=  not(take_b(3));
xu_iu_ex6_ppc_cpl_d              <=  xu_iu_ex5_ppc_cpl;
low_pri_en(0) <=  low_pri_counter0_l2(0 to 5) = low_pri_max0_l2(0 to 5) and not (next_tid(0) = '1' or i_afi_is2_take_t(0) = '1') and not low_pri_val(0);
low_pri_en(1) <=  low_pri_counter1_l2(0 to 5) = low_pri_max1_l2(0 to 5) and not (next_tid(1) = '1' or i_afi_is2_take_t(1) = '1') and not low_pri_val(1);
low_pri_en(2) <=  low_pri_counter2_l2(0 to 5) = low_pri_max2_l2(0 to 5) and not (next_tid(2) = '1' or i_afi_is2_take_t(2) = '1') and not low_pri_val(2);
low_pri_en(3) <=  low_pri_counter3_l2(0 to 5) = low_pri_max3_l2(0 to 5) and not (next_tid(3) = '1' or i_afi_is2_take_t(3) = '1') and not low_pri_val(3);
low_pri_counter0_d(0 TO 7) <=  "00000000"           when xu_iu_ex6_ppc_cpl_l2(0) = '1'                              else
                                   low_pri_counter0_l2 + 1;
low_pri_counter1_d(0 TO 7) <=  "00000000"           when xu_iu_ex6_ppc_cpl_l2(1) = '1'                              else
                                   low_pri_counter1_l2 + 1;
low_pri_counter2_d(0 TO 7) <=  "00000000"           when xu_iu_ex6_ppc_cpl_l2(2) = '1'                              else
                                   low_pri_counter2_l2 + 1;
low_pri_counter3_d(0 TO 7) <=  "00000000"           when xu_iu_ex6_ppc_cpl_l2(3) = '1'                              else
                                   low_pri_counter3_l2 + 1;
low_pri_counter0_act             <=  (xu_iu_ex6_ppc_cpl_l2(0) = '1') or (low_pri_counter0_l2(0 to 5) /= low_pri_max0_l2(0 to 5));
low_pri_counter1_act             <=  (xu_iu_ex6_ppc_cpl_l2(1) = '1') or (low_pri_counter1_l2(0 to 5) /= low_pri_max1_l2(0 to 5));
low_pri_counter2_act             <=  (xu_iu_ex6_ppc_cpl_l2(2) = '1') or (low_pri_counter2_l2(0 to 5) /= low_pri_max2_l2(0 to 5));
low_pri_counter3_act             <=  (xu_iu_ex6_ppc_cpl_l2(3) = '1') or (low_pri_counter3_l2(0 to 5) /= low_pri_max3_l2(0 to 5));
low_pri_rf0_d(0 TO 3) <=  (next_tid(0 to 3) or i_afi_is2_take_t(0 to 3)) and not xu_iu_is2_flush_tid(0 to 3);
low_pri_rf1_d(0 TO 3) <=  low_pri_rf0_l2(0 to 3) and not xu_iu_rf0_flush_tid(0 to 3);
low_pri_ex1_d(0 TO 3) <=  low_pri_rf1_l2(0 to 3) and not xu_iu_rf1_flush_tid(0 to 3);
low_pri_ex2_d(0 TO 3) <=  low_pri_ex1_l2(0 to 3) and not xu_iu_ex1_flush_tid(0 to 3);
low_pri_ex3_d(0 TO 3) <=  low_pri_ex2_l2(0 to 3) and not xu_iu_ex2_flush_tid(0 to 3);
low_pri_ex4_d(0 TO 3) <=  low_pri_ex3_l2(0 to 3) and not xu_iu_ex3_flush_tid(0 to 3);
low_pri_ex5_d(0 TO 3) <=  low_pri_ex4_l2(0 to 3) and not xu_iu_ex4_flush_tid(0 to 3);
low_pri_ex6_d(0 TO 3) <=  low_pri_ex5_l2(0 to 3) and not xu_iu_ex5_flush_tid(0 to 3);
low_pri_rf1_act                  <=  or_reduce(low_pri_rf0_l2(0 to 3)) or or_reduce(low_pri_rf1_l2(0 to 3));
low_pri_ex1_act                  <=  or_reduce(low_pri_rf1_l2(0 to 3)) or or_reduce(low_pri_ex1_l2(0 to 3));
low_pri_ex2_act                  <=  or_reduce(low_pri_ex1_l2(0 to 3)) or or_reduce(low_pri_ex2_l2(0 to 3));
low_pri_ex3_act                  <=  or_reduce(low_pri_ex2_l2(0 to 3)) or or_reduce(low_pri_ex3_l2(0 to 3));
low_pri_ex4_act                  <=  or_reduce(low_pri_ex3_l2(0 to 3)) or or_reduce(low_pri_ex4_l2(0 to 3));
low_pri_ex5_act                  <=  or_reduce(low_pri_ex4_l2(0 to 3)) or or_reduce(low_pri_ex5_l2(0 to 3));
low_pri_ex6_act                  <=  or_reduce(low_pri_ex5_l2(0 to 3)) or or_reduce(low_pri_ex6_l2(0 to 3));
low_pri_val(0 TO 3) <=  low_pri_rf0_l2(0 to 3) or
                                   low_pri_rf1_l2(0 to 3) or  
                                   low_pri_ex1_l2(0 to 3) or  
                                   low_pri_ex2_l2(0 to 3) or  
                                   low_pri_ex3_l2(0 to 3) or  
                                   low_pri_ex4_l2(0 to 3) or  
                                   low_pri_ex5_l2(0 to 3) or  
                                   low_pri_ex6_l2(0 to 3) ;
xu_iu_need_hole_d        <=  xu_iu_need_hole;
xu_iu_xucr0_rel_d        <=  xu_iu_xucr0_rel;
an_ac_back_inv_d         <=  an_ac_back_inv;
an_ac_back_inv_target_d  <=  an_ac_back_inv_target;
gap_l2_rel_hole          <=  an_ac_reld_data_vld and not an_ac_reld_core_tag(1) and not an_ac_reld_ditc and not dcache_rel_tag_2nd_beat;
gap_l2_rel_hole_dly1_d   <=  gap_l2_rel_hole;
gap_l2_rel_hole_dly2_d   <=  gap_l2_rel_hole_dly1_l2;
gap_l2_tag_dly1_d        <=  an_ac_reld_core_tag(2 to 4);
gap_l2_tag_dly2_d        <=  gap_l2_tag_dly1_l2;
dcache_rel_tag_2nd_beat  <=  (gap_l2_tag_dly2_l2(2 to 4) = an_ac_reld_core_tag(2 to 4)) and gap_l2_rel_hole_dly2_l2;
dcache_rel_hole          <= (gap_l2_rel_hole           and not xu_iu_xucr0_rel_l2) or
                          (an_ac_reld_data_coming and     xu_iu_xucr0_rel_l2);
dcache_binv_hole         <=  an_ac_back_inv_l2 and an_ac_back_inv_target_l2;
need_hole                <=  dcache_binv_hole or dcache_rel_hole or xu_iu_need_hole_l2;
high_pri_mask_din  <=  spr_high_mask_l2 or      low_pri_en;
med_pri_mask_din   <=  spr_med_mask_l2  and not low_pri_en;
high_pri_mask_d    <=  gate(is2_vld_d and high_pri_mask_din, not (hole0 or hole1 or hole2 or hole3 or need_hole));
med_pri_mask_d     <=  gate(is2_vld_d and med_pri_mask_din,  not (hole0 or hole1 or hole2 or hole3 or need_hole));
iu_au_hi_pri_mask        <=  high_pri_mask_din;
iu_au_md_pri_mask        <=  med_pri_mask_din;
low_pri_max0_d    <=  spr_fiss_count0_max;
low_pri_max1_d    <=  spr_fiss_count1_max;
low_pri_max2_d    <=  spr_fiss_count2_max;
low_pri_max3_d    <=  spr_fiss_count3_max;
spr_high_mask_d   <=  spr_issue_high_mask;
spr_med_mask_d    <=  spr_issue_med_mask;
n_thread  <=  next_tid;
int_is2_vld                      <=  (not xu_iu_is2_flush_tid(0) and not uc_flush_tid_l2(0) and n_thread(0)) or
                                   (not xu_iu_is2_flush_tid(1) and not uc_flush_tid_l2(1) and n_thread(1)) or
                                   (not xu_iu_is2_flush_tid(2) and not uc_flush_tid_l2(2) and n_thread(2)) or 
                                   (not xu_iu_is2_flush_tid(3) and not uc_flush_tid_l2(3) and n_thread(3)) ;
iss_is2_vld                      <=  (not uc_flush_tid_l2(0) and n_thread(0)) or
                                   (not uc_flush_tid_l2(1) and n_thread(1)) or
                                   (not uc_flush_tid_l2(2) and n_thread(2)) or 
                                   (not uc_flush_tid_l2(3) and n_thread(3)) ;
iu_xu_is2_instr_int              <=  gate(fdep_fiss_t0_is2_instr, n_thread(0)) or 
                                   gate(fdep_fiss_t1_is2_instr, n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_instr, n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_instr, n_thread(3)) ;
iu_xu_is2_ta_vld                 <=  (fdep_fiss_t0_is2_ta_vld and not fdep_fiss_t0_is2_to_ucode and not uc_flush_tid_l2(0) and n_thread(0)) or
                                   (fdep_fiss_t1_is2_ta_vld and not fdep_fiss_t1_is2_to_ucode and not uc_flush_tid_l2(1) and n_thread(1)) or
                                   (fdep_fiss_t2_is2_ta_vld and not fdep_fiss_t2_is2_to_ucode and not uc_flush_tid_l2(2) and n_thread(2)) or
                                   (fdep_fiss_t3_is2_ta_vld and not fdep_fiss_t3_is2_to_ucode and not uc_flush_tid_l2(3) and n_thread(3)) ;
iu_xu_is2_ta                     <=  gate(fdep_fiss_t0_is2_ta,  n_thread(0)) or
                                   gate(fdep_fiss_t1_is2_ta,  n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_ta,  n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_ta,  n_thread(3)) ;
iu_xu_is2_s1_vld                 <=  (fdep_fiss_t0_is2_s1_vld and not uc_flush_tid_l2(0) and n_thread(0)) or
                                   (fdep_fiss_t1_is2_s1_vld and not uc_flush_tid_l2(1) and n_thread(1)) or
                                   (fdep_fiss_t2_is2_s1_vld and not uc_flush_tid_l2(2) and n_thread(2)) or
                                   (fdep_fiss_t3_is2_s1_vld and not uc_flush_tid_l2(3) and n_thread(3)) ;
iu_xu_is2_s1                     <=  gate(fdep_fiss_t0_is2_s1,  n_thread(0)) or
                                   gate(fdep_fiss_t1_is2_s1,  n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_s1,  n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_s1,  n_thread(3)) ;
iu_xu_is2_s2_vld                 <=  (fdep_fiss_t0_is2_s2_vld and not uc_flush_tid_l2(0) and n_thread(0)) or
                                   (fdep_fiss_t1_is2_s2_vld and not uc_flush_tid_l2(1) and n_thread(1)) or
                                   (fdep_fiss_t2_is2_s2_vld and not uc_flush_tid_l2(2) and n_thread(2)) or
                                   (fdep_fiss_t3_is2_s2_vld and not uc_flush_tid_l2(3) and n_thread(3)) ;
iu_xu_is2_s2                     <=  gate(fdep_fiss_t0_is2_s2,  n_thread(0)) or
                                   gate(fdep_fiss_t1_is2_s2,  n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_s2,  n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_s2,  n_thread(3)) ;
iu_xu_is2_s3_vld                 <=  (fdep_fiss_t0_is2_s3_vld and not uc_flush_tid_l2(0) and n_thread(0)) or
                                   (fdep_fiss_t1_is2_s3_vld and not uc_flush_tid_l2(1) and n_thread(1)) or
                                   (fdep_fiss_t2_is2_s3_vld and not uc_flush_tid_l2(2) and n_thread(2)) or
                                   (fdep_fiss_t3_is2_s3_vld and not uc_flush_tid_l2(3) and n_thread(3)) ;
iu_xu_is2_s3                     <=  gate(fdep_fiss_t0_is2_s3,  n_thread(0)) or
                                   gate(fdep_fiss_t1_is2_s3,  n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_s3,  n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_s3,  n_thread(3)) ;
iu_xu_is2_pred_update_int        <=  (fdep_fiss_t0_is2_pred_update and n_thread(0)) or
                                   (fdep_fiss_t1_is2_pred_update and n_thread(1)) or
                                   (fdep_fiss_t2_is2_pred_update and n_thread(2)) or
                                   (fdep_fiss_t3_is2_pred_update and n_thread(3)) ;
iu_xu_is2_pred_update            <=  iu_xu_is2_pred_update_int;
iu_xu_is2_pred_taken_cnt_int     <=  gate(fdep_fiss_t0_is2_pred_taken_cnt, n_thread(0)) or
                                   gate(fdep_fiss_t1_is2_pred_taken_cnt, n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_pred_taken_cnt, n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_pred_taken_cnt, n_thread(3)) ;
iu_xu_is2_pred_taken_cnt         <=  iu_xu_is2_pred_taken_cnt_int;
iu_xu_is2_gshare                 <=  gate(fdep_fiss_t0_is2_gshare, n_thread(0)) or
                                   gate(fdep_fiss_t1_is2_gshare, n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_gshare, n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_gshare, n_thread(3)) ;
iu_xu_is2_ifar                   <=  gate(fdep_fiss_t0_is2_ifar, n_thread(0)) or 
                                   gate(fdep_fiss_t1_is2_ifar, n_thread(1)) or 
                                   gate(fdep_fiss_t2_is2_ifar, n_thread(2)) or 
                                   gate(fdep_fiss_t3_is2_ifar, n_thread(3)) ;
iu_xu_is2_error_int              <=  gate(fdep_fiss_t0_is2_error, n_thread(0)) or
                                   gate(fdep_fiss_t1_is2_error, n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_error, n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_error, n_thread(3)) ;
iu_xu_is2_error                  <=  iu_xu_is2_error_int;
int_is2_to_ucode                 <=  (fdep_fiss_t0_is2_to_ucode and n_thread(0)) or
                                   (fdep_fiss_t1_is2_to_ucode and n_thread(1)) or
                                   (fdep_fiss_t2_is2_to_ucode and n_thread(2)) or
                                   (fdep_fiss_t3_is2_to_ucode and n_thread(3)) ;
iu_xu_is2_is_ucode               <=  (fdep_fiss_t0_is2_is_ucode and n_thread(0)) or
                                   (fdep_fiss_t1_is2_is_ucode and n_thread(1)) or
                                   (fdep_fiss_t2_is2_is_ucode and n_thread(2)) or
                                   (fdep_fiss_t3_is2_is_ucode and n_thread(3)) ;
iu_xu_is2_axu_ld_or_st_int       <=  (fdep_fiss_t0_is2_axu_ld_or_st and n_thread(0)) or
                                   (fdep_fiss_t1_is2_axu_ld_or_st and n_thread(1)) or
                                   (fdep_fiss_t2_is2_axu_ld_or_st and n_thread(2)) or
                                   (fdep_fiss_t3_is2_axu_ld_or_st and n_thread(3)) ;
iu_xu_is2_axu_store_int          <=  (fdep_fiss_t0_is2_axu_store and n_thread(0)) or 
                                   (fdep_fiss_t1_is2_axu_store and n_thread(1)) or 
                                   (fdep_fiss_t2_is2_axu_store and n_thread(2)) or 
                                   (fdep_fiss_t3_is2_axu_store and n_thread(3)) ;
iu_xu_is2_axu_ldst_indexed       <=  (fdep_fiss_t0_is2_axu_ldst_indexed and n_thread(0)) or 
                                   (fdep_fiss_t1_is2_axu_ldst_indexed and n_thread(1)) or 
                                   (fdep_fiss_t2_is2_axu_ldst_indexed and n_thread(2)) or 
                                   (fdep_fiss_t3_is2_axu_ldst_indexed and n_thread(3)) ;
iu_xu_is2_axu_ldst_tag_int       <=  gate(fdep_fiss_t0_is2_axu_ldst_tag, n_thread(0)) or
                                   gate(fdep_fiss_t1_is2_axu_ldst_tag, n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_axu_ldst_tag, n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_axu_ldst_tag, n_thread(3)) ;
iu_xu_is2_axu_ldst_size          <=  gate(fdep_fiss_t0_is2_axu_ldst_size, n_thread(0)) or
                                   gate(fdep_fiss_t1_is2_axu_ldst_size, n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_axu_ldst_size, n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_axu_ldst_size, n_thread(3)) ;
iu_xu_is2_axu_ldst_update        <=  (fdep_fiss_t0_is2_axu_ldst_update and n_thread(0)) or
                                   (fdep_fiss_t1_is2_axu_ldst_update and n_thread(1)) or
                                   (fdep_fiss_t2_is2_axu_ldst_update and n_thread(2)) or
                                   (fdep_fiss_t3_is2_axu_ldst_update and n_thread(3)) ;
iu_xu_is2_axu_ldst_extpid        <=  (fdep_fiss_t0_is2_axu_ldst_extpid and n_thread(0)) or
                                   (fdep_fiss_t1_is2_axu_ldst_extpid and n_thread(1)) or
                                   (fdep_fiss_t2_is2_axu_ldst_extpid and n_thread(2)) or
                                   (fdep_fiss_t3_is2_axu_ldst_extpid and n_thread(3)) ;
iu_xu_is2_axu_ldst_forcealign    <=  (fdep_fiss_t0_is2_axu_ldst_forcealign and n_thread(0)) or
                                   (fdep_fiss_t1_is2_axu_ldst_forcealign and n_thread(1)) or
                                   (fdep_fiss_t2_is2_axu_ldst_forcealign and n_thread(2)) or
                                   (fdep_fiss_t3_is2_axu_ldst_forcealign and n_thread(3)) ;
iu_xu_is2_axu_ldst_forceexcept   <=  (fdep_fiss_t0_is2_axu_ldst_forceexcept and n_thread(0)) or
                                   (fdep_fiss_t1_is2_axu_ldst_forceexcept and n_thread(1)) or
                                   (fdep_fiss_t2_is2_axu_ldst_forceexcept and n_thread(2)) or
                                   (fdep_fiss_t3_is2_axu_ldst_forceexcept and n_thread(3)) ;
iu_xu_is2_axu_mftgpr             <=  (fdep_fiss_t0_is2_axu_mftgpr and n_thread(0)) or
                                   (fdep_fiss_t1_is2_axu_mftgpr and n_thread(1)) or
                                   (fdep_fiss_t2_is2_axu_mftgpr and n_thread(2)) or
                                   (fdep_fiss_t3_is2_axu_mftgpr and n_thread(3)) ;
iu_xu_is2_axu_mffgpr             <=  (fdep_fiss_t0_is2_axu_mffgpr and n_thread(0)) or
                                   (fdep_fiss_t1_is2_axu_mffgpr and n_thread(1)) or
                                   (fdep_fiss_t2_is2_axu_mffgpr and n_thread(2)) or
                                   (fdep_fiss_t3_is2_axu_mffgpr and n_thread(3)) ;
iu_xu_is2_axu_movedp            <=  (fdep_fiss_t0_is2_axu_movedp and n_thread(0)) or
                                   (fdep_fiss_t1_is2_axu_movedp and n_thread(1)) or
                                   (fdep_fiss_t2_is2_axu_movedp and n_thread(2)) or
                                   (fdep_fiss_t3_is2_axu_movedp and n_thread(3)) ;
iu_xu_is2_axu_instr_type         <=  gate(fdep_fiss_t0_is2_axu_instr_type, n_thread(0)) or
                                   gate(fdep_fiss_t1_is2_axu_instr_type, n_thread(1)) or
                                   gate(fdep_fiss_t2_is2_axu_instr_type, n_thread(2)) or
                                   gate(fdep_fiss_t3_is2_axu_instr_type, n_thread(3)) ;
iu_xu_is2_match                  <=  (fdep_fiss_t0_is2_match and n_thread(0)) or
                                   (fdep_fiss_t1_is2_match and n_thread(1)) or
                                   (fdep_fiss_t2_is2_match and n_thread(2)) or
                                   (fdep_fiss_t3_is2_match and n_thread(3)) ;
fiss_uc_is2_2ucode               <=  (fdep_fiss_t0_is2_2ucode and n_thread(0)) or
                                   (fdep_fiss_t1_is2_2ucode and n_thread(1)) or
                                   (fdep_fiss_t2_is2_2ucode and n_thread(2)) or
                                   (fdep_fiss_t3_is2_2ucode and n_thread(3)) ;
fiss_uc_is2_2ucode_type          <=  (fdep_fiss_t0_is2_2ucode_type and n_thread(0)) or
                                   (fdep_fiss_t1_is2_2ucode_type and n_thread(1)) or
                                   (fdep_fiss_t2_is2_2ucode_type and n_thread(2)) or
                                   (fdep_fiss_t3_is2_2ucode_type and n_thread(3)) ;
uc_flush_tid_d(0) <=  n_thread(0) and fdep_fiss_t0_is2_to_ucode and not xu_iu_is2_flush_tid(0) and not uc_flush_tid_l2(0);
uc_flush_tid_d(1) <=  n_thread(1) and fdep_fiss_t1_is2_to_ucode and not xu_iu_is2_flush_tid(1) and not uc_flush_tid_l2(1);
uc_flush_tid_d(2) <=  n_thread(2) and fdep_fiss_t2_is2_to_ucode and not xu_iu_is2_flush_tid(2) and not uc_flush_tid_l2(2);
uc_flush_tid_d(3) <=  n_thread(3) and fdep_fiss_t3_is2_to_ucode and not xu_iu_is2_flush_tid(3) and not uc_flush_tid_l2(3);
iu_xu_is2_vld_int        <=  iss_is2_vld and not int_is2_to_ucode;
iu_xu_is2_tid_int        <=  n_thread;
iu_xu_is2_vld            <=  iu_xu_is2_vld_int;
iu_xu_is2_tid            <=  iu_xu_is2_tid_int;
fiss_uc_is2_ucode_vld_int    <=  iss_is2_vld and int_is2_to_ucode;
fiss_uc_is2_ucode_vld    <=  fiss_uc_is2_ucode_vld_int;
iu_xu_is2_axu_store      <=  iu_xu_is2_axu_store_int;
iu_xu_is2_axu_ld_or_st   <=  iu_xu_is2_axu_ld_or_st_int;
iu_xu_is2_instr          <=  iu_xu_is2_instr_int;
iu_xu_is2_axu_ldst_tag   <=  iu_xu_is2_axu_ldst_tag_int;
rf0_str_val_d            <=  iu_xu_is2_axu_store_int;
rf0_ldst_val_d           <=  iu_xu_is2_axu_ld_or_st_int and int_is2_vld and not int_is2_to_ucode;
rf0_ldst_tid_d           <=  gate("11", n_thread(3)) or
                           gate("10", n_thread(2)) or
                           gate("01", n_thread(1)) ;
rf0_ldst_tag_d           <=  iu_xu_is2_axu_ldst_tag_int;
rf0_ldst_act             <=  iss_is2_vld;
iu_fu_rf0_str_val        <=  rf0_str_val_l2;
iu_fu_rf0_ldst_val       <=  rf0_ldst_val_l2;
iu_fu_rf0_ldst_tid       <=  rf0_ldst_tid_l2;
iu_fu_rf0_ldst_tag       <=  rf0_ldst_tag_l2;
perf_event_d(0) <=  i_afi_is2_take_t(0) and n_thread(0);
perf_event_d(1) <=  i_afi_is2_take_t(1) and n_thread(1);
perf_event_d(2) <=  i_afi_is2_take_t(2) and n_thread(2);
perf_event_d(3) <=  i_afi_is2_take_t(3) and n_thread(3);
perf_event_d(4) <=  not i_afi_is2_take_t(0) and i_afd_is2_t0_instr_v;
perf_event_d(5) <=  not i_afi_is2_take_t(1) and i_afd_is2_t1_instr_v;
perf_event_d(6) <=  not i_afi_is2_take_t(2) and i_afd_is2_t2_instr_v;
perf_event_d(7) <=  not i_afi_is2_take_t(3) and i_afd_is2_t3_instr_v;
perf_event_d(8) <=  not next_tid(0) and is2_vld_l2(0);
perf_event_d(9) <=  not next_tid(1) and is2_vld_l2(1);
perf_event_d(10) <=  not next_tid(2) and is2_vld_l2(2);
perf_event_d(11) <=  not next_tid(3) and is2_vld_l2(3);
perf_event_d(12) <=  i_afi_is2_take_t(0);
perf_event_d(13) <=  i_afi_is2_take_t(1);
perf_event_d(14) <=  i_afi_is2_take_t(2);
perf_event_d(15) <=  i_afi_is2_take_t(3);
perf_event_d(16) <=  n_thread(0);
perf_event_d(17) <=  n_thread(1);
perf_event_d(18) <=  n_thread(2);
perf_event_d(19) <=  n_thread(3);
perf_event_d(20) <=  i_afi_is2_take_t(0) or n_thread(0);
perf_event_d(21) <=  i_afi_is2_take_t(1) or n_thread(1);
perf_event_d(22) <=  i_afi_is2_take_t(2) or n_thread(2);
perf_event_d(23) <=  i_afi_is2_take_t(3) or n_thread(3);
perf_event_d(24) <=  n_thread(0) and fdep_fiss_t0_is2_match;
perf_event_d(25) <=  n_thread(1) and fdep_fiss_t1_is2_match;
perf_event_d(26) <=  n_thread(2) and fdep_fiss_t2_is2_match;
perf_event_d(27) <=  n_thread(3) and fdep_fiss_t3_is2_match;
perf_event_d(28) <=  i_afi_is2_take_t(0) or (n_thread(0) and not fdep_fiss_t0_is2_to_ucode and not fdep_fiss_t0_is2_is_ucode);
perf_event_d(29) <=  i_afi_is2_take_t(1) or (n_thread(1) and not fdep_fiss_t1_is2_to_ucode and not fdep_fiss_t1_is2_is_ucode);
perf_event_d(30) <=  i_afi_is2_take_t(2) or (n_thread(2) and not fdep_fiss_t2_is2_to_ucode and not fdep_fiss_t2_is2_is_ucode);
perf_event_d(31) <=  i_afi_is2_take_t(3) or (n_thread(3) and not fdep_fiss_t3_is2_to_ucode and not fdep_fiss_t3_is2_is_ucode);
fiss_perf_event_t0(0 TO 7) <=  perf_event_l2(0)  &
                              perf_event_l2(4)  &
                              perf_event_l2(8)  &
                              perf_event_l2(12) &
                              perf_event_l2(16) &
                              perf_event_l2(20) &
                              perf_event_l2(24) &
                              perf_event_l2(28);
fiss_perf_event_t1(0 TO 7) <=  perf_event_l2(1)  &
                              perf_event_l2(5)  &
                              perf_event_l2(9)  &
                              perf_event_l2(13) &
                              perf_event_l2(17) &
                              perf_event_l2(21) &
                              perf_event_l2(25) &
                              perf_event_l2(29);
fiss_perf_event_t2(0 TO 7) <=  perf_event_l2(2)  &
                              perf_event_l2(6)  &
                              perf_event_l2(10) &
                              perf_event_l2(14) &
                              perf_event_l2(18) &
                              perf_event_l2(22) &
                              perf_event_l2(26) &
                              perf_event_l2(30);
fiss_perf_event_t3(0 TO 7) <=  perf_event_l2(3)  &
                              perf_event_l2(7)  &
                              perf_event_l2(11) &
                              perf_event_l2(15) &
                              perf_event_l2(19) &
                              perf_event_l2(23) &
                              perf_event_l2(27) &
                              perf_event_l2(31);
fiss_dbg_data(0 TO 3) <=  high_pri_mask_l2(0 to 3);
fiss_dbg_data(4 TO 7) <=  med_pri_mask_l2(0 to 3);
fiss_dbg_data(8) <=  hi_did3no0;
fiss_dbg_data(9) <=  hi_did3no1;
fiss_dbg_data(10) <=  hi_did3no2;
fiss_dbg_data(11) <=  hi_did2no0;
fiss_dbg_data(12) <=  hi_did2no1;
fiss_dbg_data(13) <=  hi_did1no0;
fiss_dbg_data(14) <=  md_did3no0;
fiss_dbg_data(15) <=  md_did3no1;
fiss_dbg_data(16) <=  md_did3no2;
fiss_dbg_data(17) <=  md_did2no0;
fiss_dbg_data(18) <=  md_did2no1;
fiss_dbg_data(19) <=  md_did1no0;
fiss_dbg_data(20 TO 25) <=  low_pri_counter0_l2(0 to 5);
fiss_dbg_data(26 TO 31) <=  low_pri_counter1_l2(0 to 5);
fiss_dbg_data(32 TO 37) <=  low_pri_counter2_l2(0 to 5);
fiss_dbg_data(38 TO 43) <=  low_pri_counter3_l2(0 to 5);
fiss_dbg_data_d(44) <=  iu_xu_is2_vld_int;
fiss_dbg_data_d(45) <=  fiss_uc_is2_ucode_vld_int;
fiss_dbg_data_d(46 TO 49) <=  iu_xu_is2_tid_int(0 to 3);
fiss_dbg_data_d(50 TO 81) <=  iu_xu_is2_instr_int(0 to 31);
fiss_dbg_data_d(82) <=  iu_xu_is2_pred_update_int;
fiss_dbg_data_d(83 TO 84) <=  iu_xu_is2_pred_taken_cnt_int(0 to 1);
fiss_dbg_data_d(85 TO 87) <=  iu_xu_is2_error_int(0 to 2);
fiss_dbg_data(44 TO 87) <=  fiss_dbg_data_l2(44 to 87);
siv(0 TO scan_right) <=  sov(1 to scan_right) & scan_in;
scan_out  <=  sov(0) and an_ac_scan_dis_dc_b;
END IUQ_FXU_ISSUE;

