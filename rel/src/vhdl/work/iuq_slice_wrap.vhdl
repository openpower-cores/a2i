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
--*
--* TITLE: Instruction slice wrapper
--*
--* NAME: iuq_slice_wrap.vhdl
--*
--*********************************************************************

library ieee;
use ieee.std_logic_1164.all;
library support;
use support.power_logic_pkg.all;
library work;
use work.iuq_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity iuq_slice_wrap is
  generic(expand_type           : integer := 2; 
          fpr_addr_width        : integer := 5;
          regmode               : integer := 6;
          a2mode                : integer := 1;
          lmq_entries           : integer := 8);
port(
     vdd                                : inout power_logic;
     gnd                                : inout power_logic;
     nclk                               : in  clk_logic;
     pc_iu_func_sl_thold_2              : in  std_ulogic_vector(0 to 3);
     pc_iu_sg_2                         : in  std_ulogic_vector(0 to 3);
     clkoff_b                           : in  std_ulogic_vector(0 to 3);
     an_ac_scan_dis_dc_b                : in  std_ulogic_vector(0 to 3);
     tc_ac_ccflush_dc                   : in  std_ulogic;
     delay_lclkr                        : in  std_ulogic_vector(9 to 14);
     mpw1_b                             : in  std_ulogic_vector(9 to 14);

     iuq_s0_scan_in                     : in  std_ulogic;
     iuq_s0_scan_out                    : out std_ulogic;
     iuq_s1_scan_in                     : in  std_ulogic;
     iuq_s1_scan_out                    : out std_ulogic;
     iuq_s2_scan_in                     : in  std_ulogic;
     iuq_s2_scan_out                    : out std_ulogic;
     iuq_s3_scan_in                     : in  std_ulogic;
     iuq_s3_scan_out                    : out std_ulogic;
     pc_iu_ram_mode                     : in  std_ulogic;
     pc_iu_ram_thread                   : in  std_ulogic_vector(0 to 1);
     pc_iu_trace_bus_enable             : in  std_ulogic;
     pc_iu_event_bus_enable             : in  std_ulogic;
     fdep_dbg_data                      : out std_ulogic_vector(0 to 87);
     fdep_perf_event_t0                 : out std_ulogic_vector(0 to 11);
     fdep_perf_event_t1                 : out std_ulogic_vector(0 to 11);
     fdep_perf_event_t2                 : out std_ulogic_vector(0 to 11);
     fdep_perf_event_t3                 : out std_ulogic_vector(0 to 11);
     iu_au_config_iucr_t0               : in  std_ulogic_vector(0 to 7);
     iu_au_config_iucr_t1               : in  std_ulogic_vector(0 to 7);
     iu_au_config_iucr_t2               : in  std_ulogic_vector(0 to 7);
     iu_au_config_iucr_t3               : in  std_ulogic_vector(0 to 7);
     spr_dec_mask_t0                    : in  std_ulogic_vector(0 to 31);
     spr_dec_mask_t1                    : in  std_ulogic_vector(0 to 31);
     spr_dec_mask_t2                    : in  std_ulogic_vector(0 to 31);
     spr_dec_mask_t3                    : in  std_ulogic_vector(0 to 31);
     spr_dec_match_t0                   : in  std_ulogic_vector(0 to 31);
     spr_dec_match_t1                   : in  std_ulogic_vector(0 to 31);
     spr_dec_match_t2                   : in  std_ulogic_vector(0 to 31);
     spr_dec_match_t3                   : in  std_ulogic_vector(0 to 31);
     uc_flush_tid                       : in  std_ulogic_vector(0 to 3);
     xu_iu_flush                        : in  std_ulogic_vector(0 to 3);
     xu_rf1_flush                       : in  std_ulogic_vector(0 to 3);
     xu_ex1_flush                       : in  std_ulogic_vector(0 to 3);
     xu_ex2_flush                       : in  std_ulogic_vector(0 to 3);
     xu_ex3_flush                       : in  std_ulogic_vector(0 to 3);
     xu_ex4_flush                       : in  std_ulogic_vector(0 to 3);
     xu_ex5_flush                       : in  std_ulogic_vector(0 to 3);
     fdec_ibuf_stall_t0                 : out std_ulogic;
     fdec_ibuf_stall_t1                 : out std_ulogic;
     fdec_ibuf_stall_t2                 : out std_ulogic;
     fdec_ibuf_stall_t3                 : out std_ulogic;
     iu_au_ib1_instr_vld_t0             : in  std_ulogic;
     iu_au_ib1_instr_vld_t1             : in  std_ulogic;
     iu_au_ib1_instr_vld_t2             : in  std_ulogic;
     iu_au_ib1_instr_vld_t3             : in  std_ulogic;
     iu_au_ib1_ifar_t0                  : in  EFF_IFAR;
     iu_au_ib1_ifar_t1                  : in  EFF_IFAR;
     iu_au_ib1_ifar_t2                  : in  EFF_IFAR;
     iu_au_ib1_ifar_t3                  : in  EFF_IFAR;
     iu_au_ib1_data_t0                  : in  std_ulogic_vector(0 to 49);
     iu_au_ib1_data_t1                  : in  std_ulogic_vector(0 to 49);
     iu_au_ib1_data_t2                  : in  std_ulogic_vector(0 to 49);
     iu_au_ib1_data_t3                  : in  std_ulogic_vector(0 to 49);
     xu_iu_ucode_restart                : in  std_ulogic_vector(0 to 3);
     xu_iu_slowspr_done                 : in  std_ulogic_vector(0 to 3);
     xu_iu_multdiv_done                 : in  std_ulogic_vector(0 to 3);
     xu_iu_ex4_loadmiss_tid             : in  std_ulogic_vector(0 to 3);
     xu_iu_ex4_loadmiss_qentry          : in  std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_ex4_loadmiss_target          : in  std_ulogic_vector(0 to 8);
     xu_iu_ex4_loadmiss_target_type     : in  std_ulogic_vector(0 to 1);
     xu_iu_ex5_loadmiss_tid             : in  std_ulogic_vector(0 to 3);
     xu_iu_ex5_loadmiss_qentry          : in  std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_ex5_loadmiss_target          : in  std_ulogic_vector(1 to 6);
     xu_iu_ex5_loadmiss_target_type     : in  std_ulogic_vector(0 to 0);
     xu_iu_complete_tid                 : in  std_ulogic_vector(0 to 3);
     xu_iu_complete_qentry              : in  std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_complete_target_type         : in  std_ulogic_vector(0 to 1);
     ic_fdep_load_quiesce               : in  std_ulogic_vector(0 to 3);
     iu_xu_quiesce                      : out std_ulogic_vector(0 to 3);
     xu_iu_membar_tid                   : in  std_ulogic_vector(0 to 3);
     xu_iu_set_barr_tid                 : in  std_ulogic_vector(0 to 3);
     xu_iu_larx_done_tid                : in  std_ulogic_vector(0 to 3);
     an_ac_sync_ack                     : in  std_ulogic_vector(0 to 3);
     ic_fdep_icbi_ack                   : in  std_ulogic_vector(0 to 3);
     an_ac_stcx_complete                : in  std_ulogic_vector(0 to 3);
     mm_iu_barrier_done                 : in  std_ulogic_vector(0 to 3);
     spr_fdep_ll_hold_t0                : in  std_ulogic;
     spr_fdep_ll_hold_t1                : in  std_ulogic;
     spr_fdep_ll_hold_t2                : in  std_ulogic;
     spr_fdep_ll_hold_t3                : in  std_ulogic;
     xu_iu_spr_ccr2_en_dcr              : in  std_ulogic;
     xu_iu_single_instr_mode            : in  std_ulogic_vector(0 to 3);
     fu_iu_uc_special                   : in  std_ulogic_vector(0 to 3);
     iu_fu_ex2_n_flush                  : out std_ulogic_vector(0 to 3);
     axu_dbg_data_t0                    : out std_ulogic_vector(0 to 37);
     axu_dbg_data_t1                    : out std_ulogic_vector(0 to 37);
     axu_dbg_data_t2                    : out std_ulogic_vector(0 to 37);
     axu_dbg_data_t3                    : out std_ulogic_vector(0 to 37);

     iuq_fi_scan_in                     : in std_ulogic;
     iuq_fi_scan_out                    : out std_ulogic;
     fiss_dbg_data                      : out std_ulogic_vector(0 to 87);
     fiss_perf_event_t0                 : out std_ulogic_vector(0 to 7);
     fiss_perf_event_t1                 : out std_ulogic_vector(0 to 7);
     fiss_perf_event_t2                 : out std_ulogic_vector(0 to 7);
     fiss_perf_event_t3                 : out std_ulogic_vector(0 to 7);
     xu_iu_need_hole                    : in  std_ulogic;
     xu_iu_xucr0_rel                    : in  std_ulogic;
     an_ac_reld_data_vld_clone          : in  std_ulogic;
     an_ac_reld_core_tag_clone          : in  std_ulogic_vector(1 to 4);
     an_ac_reld_ditc_clone              : in  std_ulogic;
     an_ac_reld_data_coming_clone       : in  std_ulogic;
     an_ac_back_inv                     : in  std_ulogic;
     an_ac_back_inv_target              : in  std_ulogic_vector(1 to 1);
     fiss_uc_is2_ucode_vld              : out std_ulogic;
     spr_issue_high_mask                : in std_ulogic_vector(0 to 3);
     spr_issue_med_mask                 : in std_ulogic_vector(0 to 3);
     spr_fiss_count0_max                : in std_ulogic_vector(0 to 5);
     spr_fiss_count1_max                : in std_ulogic_vector(0 to 5);
     spr_fiss_count2_max                : in std_ulogic_vector(0 to 5);
     spr_fiss_count3_max                : in std_ulogic_vector(0 to 5);
     spr_fiss_pri_rand                  : in std_ulogic_vector(0 to 4);
     spr_fiss_pri_rand_always           : in std_ulogic;
     spr_fiss_pri_rand_flush            : in std_ulogic;
     xu_iu_ex5_ppc_cpl                  : in std_ulogic_vector(0 to 3);
     iu_xu_is2_vld_internal             : out std_ulogic;
     iu_xu_is2_tid_internal             : out std_ulogic_vector(0 to 3);
     iu_xu_is2_instr_internal           : out std_ulogic_vector(0 to 31);
     iu_xu_is2_ta_vld                   : out std_ulogic;
     iu_xu_is2_ta                       : out std_ulogic_vector(0 to 5);
     iu_xu_is2_s1_vld                   : out std_ulogic;
     iu_xu_is2_s1                       : out std_ulogic_vector(0 to 5);
     iu_xu_is2_s2_vld                   : out std_ulogic;
     iu_xu_is2_s2                       : out std_ulogic_vector(0 to 5);
     iu_xu_is2_s3_vld                   : out std_ulogic;
     iu_xu_is2_s3                       : out std_ulogic_vector(0 to 5);
     iu_xu_is2_pred_update_internal     : out std_ulogic;
     iu_xu_is2_pred_taken_cnt_internal  : out std_ulogic_vector(0 to 1);
     iu_xu_is2_gshare                   : out std_ulogic_vector(0 to 3);
     iu_xu_is2_ifar_internal            : out eff_ifar;
     iu_xu_is2_error_internal           : out std_ulogic_vector(0 to 2);    
     iu_xu_is2_is_ucode                 : out std_ulogic;
     iu_xu_is2_axu_ld_or_st             : out std_ulogic;                       
     iu_xu_is2_axu_store_internal       : out std_ulogic;                       
     iu_xu_is2_axu_ldst_indexed         : out std_ulogic;        
     iu_xu_is2_axu_ldst_tag             : out std_ulogic_vector(0 to 8);        
     iu_xu_is2_axu_ldst_size            : out std_ulogic_vector(0 to 5);        
     iu_xu_is2_axu_ldst_update          : out std_ulogic;                       
     iu_xu_is2_axu_ldst_extpid          : out std_ulogic;                       
     iu_xu_is2_axu_ldst_forcealign      : out std_ulogic;                       
     iu_xu_is2_axu_ldst_forceexcept     : out std_ulogic;                       
     iu_xu_is2_axu_mftgpr               : out std_ulogic;                       
     iu_xu_is2_axu_mffgpr               : out std_ulogic;                       
     iu_xu_is2_axu_movedp               : out std_ulogic;                       
     iu_xu_is2_axu_instr_type           : out std_ulogic_vector(0 to 2);               
     iu_xu_is2_match                    : out std_ulogic;
     fiss_uc_is2_2ucode                 : out std_ulogic;
     fiss_uc_is2_2ucode_type            : out std_ulogic;
     iu_fu_rf0_str_val                  : out std_ulogic;
     iu_fu_rf0_ldst_val                 : out std_ulogic;
     iu_fu_rf0_ldst_tid                 : out std_ulogic_vector(0 to 1);
     iu_fu_rf0_ldst_tag                 : out std_ulogic_vector(0 to 8);                       

     iuq_ai_scan_in                     : in  std_ulogic;           
     iuq_ai_scan_out                    : out std_ulogic;              
     iu_fu_is2_tid_decode               : out std_ulogic_vector(0 to 3);
     iu_fu_rf0_instr_match              : out std_ulogic;
     iu_fu_rf0_instr                    : out std_ulogic_vector(0 to 31);      
     iu_fu_rf0_instr_v                  : out std_ulogic;
     iu_fu_rf0_is_ucode                 : out std_ulogic;
     iu_fu_rf0_fra                      : out std_ulogic_vector(0 to 6);        
     iu_fu_rf0_frb                      : out std_ulogic_vector(0 to 6);                  
     iu_fu_rf0_frc                      : out std_ulogic_vector(0 to 6);                  
     iu_fu_rf0_frt                      : out std_ulogic_vector(0 to 6);                                   
     iu_fu_rf0_fra_v                    : out std_ulogic;                
     iu_fu_rf0_frb_v                    : out std_ulogic;                 
     iu_fu_rf0_frc_v                    : out std_ulogic;   
     iu_fu_rf0_ucfmul                   : out std_ulogic;     
     fu_iss_dbg_data                    : out std_ulogic_vector(0 to 23); 
     iu_fu_rf0_tid                      : out std_ulogic_vector(0 to 1);      
     iu_fu_rf0_bypsel                   : out std_ulogic_vector(0 to 5);                    
     iu_fu_rf0_ifar                     : out EFF_IFAR        

);
end iuq_slice_wrap;
architecture iuq_slice_wrap of iuq_slice_wrap is
-- FXU Issue
signal fiss_fdep_is2_take0                      : std_ulogic;
signal fdep_fiss_t0_is2_instr                   : std_ulogic_vector(0 to 31);
signal fdep_fiss_t0_is2_ta_vld                  : std_ulogic;
signal fdep_fiss_t0_is2_ta                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t0_is2_s1_vld                  : std_ulogic;
signal fdep_fiss_t0_is2_s1                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t0_is2_s2_vld                  : std_ulogic;
signal fdep_fiss_t0_is2_s2                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t0_is2_s3_vld                  : std_ulogic;
signal fdep_fiss_t0_is2_s3                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t0_is2_pred_update             : std_ulogic;
signal fdep_fiss_t0_is2_pred_taken_cnt          : std_ulogic_vector(0 to 1);
signal fdep_fiss_t0_is2_gshare                  : std_ulogic_vector(0 to 3);
signal fdep_fiss_t0_is2_ifar                    : eff_ifar;
signal fdep_fiss_t0_is2_error                   : std_ulogic_vector(0 to 2);
signal fdep_fiss_t0_is2_axu_ld_or_st            : std_ulogic;
signal fdep_fiss_t0_is2_axu_store               : std_ulogic;
signal fdep_fiss_t0_is2_axu_ldst_size           : std_ulogic_vector(0 to 5);
signal fdep_fiss_t0_is2_axu_ldst_tag            : std_ulogic_vector(0 to 8);
signal fdep_fiss_t0_is2_axu_ldst_indexed        : std_ulogic;
signal fdep_fiss_t0_is2_axu_ldst_update         : std_ulogic;
signal fdep_fiss_t0_is2_axu_ldst_extpid         : std_ulogic;
signal fdep_fiss_t0_is2_axu_ldst_forcealign     : std_ulogic;
signal fdep_fiss_t0_is2_axu_ldst_forceexcept    : std_ulogic;
signal fdep_fiss_t0_is2_axu_mftgpr              : std_ulogic;
signal fdep_fiss_t0_is2_axu_mffgpr              : std_ulogic;
signal fdep_fiss_t0_is2_axu_movedp              : std_ulogic;
signal fdep_fiss_t0_is2_axu_instr_type          : std_ulogic_vector(0 to 2);
signal fdep_fiss_t0_is2_match                   : std_ulogic;
signal fdep_fiss_t0_is2_2ucode                  : std_ulogic;
signal fdep_fiss_t0_is2_2ucode_type             : std_ulogic;
signal fdep_fiss_t0_is2early_vld                : std_ulogic;
signal fdep_fiss_t0_is1_xu_dep_hit_b            : std_ulogic;
signal fdep_fiss_t0_is2_hole_delay              : std_ulogic_vector(0 to 2);
signal fdep_fiss_t0_is2_to_ucode                : std_ulogic;
signal fdep_fiss_t0_is2_is_ucode                : std_ulogic;
signal fiss_fdep_is2_take1                      : std_ulogic;
signal fdep_fiss_t1_is2_instr                   : std_ulogic_vector(0 to 31);
signal fdep_fiss_t1_is2_ta_vld                  : std_ulogic;
signal fdep_fiss_t1_is2_ta                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t1_is2_s1_vld                  : std_ulogic;
signal fdep_fiss_t1_is2_s1                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t1_is2_s2_vld                  : std_ulogic;
signal fdep_fiss_t1_is2_s2                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t1_is2_s3_vld                  : std_ulogic;
signal fdep_fiss_t1_is2_s3                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t1_is2_pred_update             : std_ulogic;
signal fdep_fiss_t1_is2_pred_taken_cnt          : std_ulogic_vector(0 to 1);
signal fdep_fiss_t1_is2_gshare                  : std_ulogic_vector(0 to 3);
signal fdep_fiss_t1_is2_ifar                    : eff_ifar;
signal fdep_fiss_t1_is2_error                   : std_ulogic_vector(0 to 2);
signal fdep_fiss_t1_is2_axu_ld_or_st            : std_ulogic;
signal fdep_fiss_t1_is2_axu_store               : std_ulogic;
signal fdep_fiss_t1_is2_axu_ldst_size           : std_ulogic_vector(0 to 5);
signal fdep_fiss_t1_is2_axu_ldst_tag            : std_ulogic_vector(0 to 8);
signal fdep_fiss_t1_is2_axu_ldst_indexed        : std_ulogic;
signal fdep_fiss_t1_is2_axu_ldst_update         : std_ulogic;
signal fdep_fiss_t1_is2_axu_ldst_extpid         : std_ulogic;
signal fdep_fiss_t1_is2_axu_ldst_forcealign     : std_ulogic;
signal fdep_fiss_t1_is2_axu_ldst_forceexcept    : std_ulogic;
signal fdep_fiss_t1_is2_axu_mftgpr              : std_ulogic;
signal fdep_fiss_t1_is2_axu_mffgpr              : std_ulogic;
signal fdep_fiss_t1_is2_axu_movedp              : std_ulogic;
signal fdep_fiss_t1_is2_axu_instr_type          : std_ulogic_vector(0 to 2);
signal fdep_fiss_t1_is2_match                   : std_ulogic;
signal fdep_fiss_t1_is2_2ucode                  : std_ulogic;
signal fdep_fiss_t1_is2_2ucode_type             : std_ulogic;
signal fdep_fiss_t1_is2early_vld                : std_ulogic;
signal fdep_fiss_t1_is1_xu_dep_hit_b            : std_ulogic;
signal fdep_fiss_t1_is2_hole_delay              : std_ulogic_vector(0 to 2);
signal fdep_fiss_t1_is2_to_ucode                : std_ulogic;
signal fdep_fiss_t1_is2_is_ucode                : std_ulogic;
signal fiss_fdep_is2_take2                      : std_ulogic;
signal fdep_fiss_t2_is2_instr                   : std_ulogic_vector(0 to 31);
signal fdep_fiss_t2_is2_ta_vld                  : std_ulogic;
signal fdep_fiss_t2_is2_ta                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t2_is2_s1_vld                  : std_ulogic;
signal fdep_fiss_t2_is2_s1                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t2_is2_s2_vld                  : std_ulogic;
signal fdep_fiss_t2_is2_s2                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t2_is2_s3_vld                  : std_ulogic;
signal fdep_fiss_t2_is2_s3                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t2_is2_pred_update             : std_ulogic;
signal fdep_fiss_t2_is2_pred_taken_cnt          : std_ulogic_vector(0 to 1);
signal fdep_fiss_t2_is2_gshare                  : std_ulogic_vector(0 to 3);
signal fdep_fiss_t2_is2_ifar                    : eff_ifar;
signal fdep_fiss_t2_is2_error                   : std_ulogic_vector(0 to 2);
signal fdep_fiss_t2_is2_axu_ld_or_st            : std_ulogic;
signal fdep_fiss_t2_is2_axu_store               : std_ulogic;
signal fdep_fiss_t2_is2_axu_ldst_size           : std_ulogic_vector(0 to 5);
signal fdep_fiss_t2_is2_axu_ldst_tag            : std_ulogic_vector(0 to 8);
signal fdep_fiss_t2_is2_axu_ldst_indexed        : std_ulogic;
signal fdep_fiss_t2_is2_axu_ldst_update         : std_ulogic;
signal fdep_fiss_t2_is2_axu_ldst_extpid         : std_ulogic;
signal fdep_fiss_t2_is2_axu_ldst_forcealign     : std_ulogic;
signal fdep_fiss_t2_is2_axu_ldst_forceexcept    : std_ulogic;
signal fdep_fiss_t2_is2_axu_mftgpr              : std_ulogic;
signal fdep_fiss_t2_is2_axu_mffgpr              : std_ulogic;
signal fdep_fiss_t2_is2_axu_movedp              : std_ulogic;
signal fdep_fiss_t2_is2_axu_instr_type          : std_ulogic_vector(0 to 2);
signal fdep_fiss_t2_is2_match                   : std_ulogic;
signal fdep_fiss_t2_is2_2ucode                  : std_ulogic;
signal fdep_fiss_t2_is2_2ucode_type             : std_ulogic;
signal fdep_fiss_t2_is2early_vld                : std_ulogic;
signal fdep_fiss_t2_is1_xu_dep_hit_b            : std_ulogic;
signal fdep_fiss_t2_is2_hole_delay              : std_ulogic_vector(0 to 2);
signal fdep_fiss_t2_is2_to_ucode                : std_ulogic;
signal fdep_fiss_t2_is2_is_ucode                : std_ulogic;
signal fiss_fdep_is2_take3                      : std_ulogic;
signal fdep_fiss_t3_is2_instr                   : std_ulogic_vector(0 to 31);
signal fdep_fiss_t3_is2_ta_vld                  : std_ulogic;
signal fdep_fiss_t3_is2_ta                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t3_is2_s1_vld                  : std_ulogic;
signal fdep_fiss_t3_is2_s1                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t3_is2_s2_vld                  : std_ulogic;
signal fdep_fiss_t3_is2_s2                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t3_is2_s3_vld                  : std_ulogic;
signal fdep_fiss_t3_is2_s3                      : std_ulogic_vector(0 to 5);
signal fdep_fiss_t3_is2_pred_update             : std_ulogic;
signal fdep_fiss_t3_is2_pred_taken_cnt          : std_ulogic_vector(0 to 1);
signal fdep_fiss_t3_is2_gshare                  : std_ulogic_vector(0 to 3);
signal fdep_fiss_t3_is2_ifar                    : eff_ifar;
signal fdep_fiss_t3_is2_error                   : std_ulogic_vector(0 to 2);
signal fdep_fiss_t3_is2_axu_ld_or_st            : std_ulogic;
signal fdep_fiss_t3_is2_axu_store               : std_ulogic;
signal fdep_fiss_t3_is2_axu_ldst_size           : std_ulogic_vector(0 to 5);
signal fdep_fiss_t3_is2_axu_ldst_tag            : std_ulogic_vector(0 to 8);
signal fdep_fiss_t3_is2_axu_ldst_indexed        : std_ulogic;
signal fdep_fiss_t3_is2_axu_ldst_update         : std_ulogic;
signal fdep_fiss_t3_is2_axu_ldst_extpid         : std_ulogic;
signal fdep_fiss_t3_is2_axu_ldst_forcealign     : std_ulogic;
signal fdep_fiss_t3_is2_axu_ldst_forceexcept    : std_ulogic;
signal fdep_fiss_t3_is2_axu_mftgpr              : std_ulogic;
signal fdep_fiss_t3_is2_axu_mffgpr              : std_ulogic;
signal fdep_fiss_t3_is2_axu_movedp              : std_ulogic;
signal fdep_fiss_t3_is2_axu_instr_type          : std_ulogic_vector(0 to 2);
signal fdep_fiss_t3_is2_match                   : std_ulogic;
signal fdep_fiss_t3_is2_2ucode                  : std_ulogic;
signal fdep_fiss_t3_is2_2ucode_type             : std_ulogic;
signal fdep_fiss_t3_is2early_vld                : std_ulogic;
signal fdep_fiss_t3_is1_xu_dep_hit_b            : std_ulogic;
signal fdep_fiss_t3_is2_hole_delay              : std_ulogic_vector(0 to 2);
signal fdep_fiss_t3_is2_to_ucode                : std_ulogic;
signal fdep_fiss_t3_is2_is_ucode                : std_ulogic;
-- AXU Issue
signal i_afi_is2_take_t                         : std_ulogic_vector(0 to 3);
signal i_axu_is1_dep_hit_t0_b                   : std_ulogic;
signal i_axu_is2_instr_match_t0                 : std_ulogic;
signal i_afd_is2_t0_instr_v                     : std_ulogic;
signal i_axu_is1_early_v_t0                     : std_ulogic;
signal i_afd_is2_fra_t0                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frb_t0                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frc_t0                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frt_t0                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_fra_v_t0                       : std_ulogic;
signal i_afd_is2_frb_v_t0                       : std_ulogic;
signal i_afd_is2_frc_v_t0                       : std_ulogic;
signal ifdp_is2_est_bubble3_t0                  : std_ulogic;
signal i_afd_is2_is_ucode_t0                    : std_ulogic;
signal i_afd_ignore_flush_is2_t0                : std_ulogic;
signal i_afd_in_ucode_mode_or1d_b_t0            : std_ulogic;
signal i_axu_is1_dep_hit_t1_b                   : std_ulogic;
signal i_axu_is2_instr_match_t1                 : std_ulogic;
signal i_afd_is2_t1_instr_v                     : std_ulogic;
signal i_axu_is1_early_v_t1                     : std_ulogic;
signal i_afd_is2_fra_t1                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frb_t1                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frc_t1                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frt_t1                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_fra_v_t1                       : std_ulogic;
signal i_afd_is2_frb_v_t1                       : std_ulogic;
signal i_afd_is2_frc_v_t1                       : std_ulogic;
signal ifdp_is2_est_bubble3_t1                  : std_ulogic;
signal i_afd_is2_is_ucode_t1                    : std_ulogic;
signal i_afd_ignore_flush_is2_t1                : std_ulogic;
signal i_afd_in_ucode_mode_or1d_b_t1            : std_ulogic;
signal i_axu_is1_dep_hit_t2_b                   : std_ulogic;
signal i_axu_is2_instr_match_t2                 : std_ulogic;
signal i_afd_is2_t2_instr_v                     : std_ulogic;
signal i_axu_is1_early_v_t2                     : std_ulogic;
signal i_afd_is2_fra_t2                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frb_t2                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frc_t2                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frt_t2                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_fra_v_t2                       : std_ulogic;
signal i_afd_is2_frb_v_t2                       : std_ulogic;
signal i_afd_is2_frc_v_t2                       : std_ulogic;
signal ifdp_is2_est_bubble3_t2                  : std_ulogic;
signal i_afd_is2_is_ucode_t2                    : std_ulogic;
signal i_afd_ignore_flush_is2_t2                : std_ulogic;
signal i_afd_in_ucode_mode_or1d_b_t2            : std_ulogic;
signal i_axu_is1_dep_hit_t3_b                   : std_ulogic;
signal i_axu_is2_instr_match_t3                 : std_ulogic;
signal i_afd_is2_t3_instr_v                     : std_ulogic;
signal i_axu_is1_early_v_t3                     : std_ulogic;
signal i_afd_is2_fra_t3                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frb_t3                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frc_t3                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_frt_t3                         : std_ulogic_vector(0 to 6);
signal i_afd_is2_fra_v_t3                       : std_ulogic;
signal i_afd_is2_frb_v_t3                       : std_ulogic;
signal i_afd_is2_frc_v_t3                       : std_ulogic;
signal ifdp_is2_est_bubble3_t3                  : std_ulogic;
signal i_afd_is2_is_ucode_t3                    : std_ulogic;
signal i_afd_ignore_flush_is2_t3                : std_ulogic;
signal i_afd_in_ucode_mode_or1d_b_t3            : std_ulogic;
signal i_afd_is2_bypsel_t0                      : std_ulogic_vector(0 to 5);
signal i_afd_is2_bypsel_t1                      : std_ulogic_vector(0 to 5);
signal i_afd_is2_bypsel_t2                      : std_ulogic_vector(0 to 5);
signal i_afd_is2_bypsel_t3                      : std_ulogic_vector(0 to 5);
signal iu_au_hi_pri_mask                        : std_ulogic_vector(0 to 3);
signal iu_au_md_pri_mask                        : std_ulogic_vector(0 to 3);
signal slice_id0                                : std_ulogic_vector(0 to 1);
signal slice_id1                                : std_ulogic_vector(0 to 1);
signal slice_id2                                : std_ulogic_vector(0 to 1);
signal slice_id3                                : std_ulogic_vector(0 to 1);
signal iu_au_config_iucr_pt_t0                  : std_ulogic_vector(2 to 4);
signal iu_au_config_iucr_pt_t1                  : std_ulogic_vector(2 to 4);
signal iu_au_config_iucr_pt_t2                  : std_ulogic_vector(2 to 4);
signal iu_au_config_iucr_pt_t3                  : std_ulogic_vector(2 to 4);
begin
iuq_slice0   : entity work.iuq_slice
generic map(expand_type         => expand_type,
            regmode             => regmode,
            a2mode              => a2mode,
            lmq_entries         => lmq_entries)
port map(
     slice_id                           => slice_id0,
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,
     pc_iu_func_sl_thold_2              => pc_iu_func_sl_thold_2(0),    
     pc_iu_sg_2                         => pc_iu_sg_2(0),               
     clkoff_b                           => clkoff_b(0),                 
     an_ac_scan_dis_dc_b                => an_ac_scan_dis_dc_b(0),
     tc_ac_ccflush_dc                   => tc_ac_ccflush_dc,
     delay_lclkr                        => delay_lclkr(10+0),
     mpw1_b                             => mpw1_b(10+0),
     scan_in                            => iuq_s0_scan_in,    
     scan_out                           => iuq_s0_scan_out,   
     pc_iu_ram_mode                     => pc_iu_ram_mode,
     pc_iu_ram_thread                   => pc_iu_ram_thread,
     pc_iu_trace_bus_enable             => pc_iu_trace_bus_enable,
     pc_iu_event_bus_enable             => pc_iu_event_bus_enable,
     fdep_dbg_data                      => fdep_dbg_data(22*0   to 22*0+21),
     fdep_perf_event                    => fdep_perf_event_t0,
     iu_au_config_iucr                  => iu_au_config_iucr_t0,
     iu_au_config_iucr_pt               => iu_au_config_iucr_pt_t0,
     spr_dec_mask                       => spr_dec_mask_t0,
     spr_dec_match                      => spr_dec_match_t0,
     uc_flush                           => uc_flush_tid(0),
     xu_iu_flush                        => xu_iu_flush(0),   
     xu_iu_rf1_flush                    => xu_rf1_flush(0),
     xu_iu_ex1_flush                    => xu_ex1_flush(0),
     xu_iu_ex2_flush                    => xu_ex2_flush(0),
     xu_iu_ex3_flush                    => xu_ex3_flush(0),
     xu_iu_ex4_flush                    => xu_ex4_flush(0),
     xu_iu_ex5_flush                    => xu_ex5_flush(0),
     fdec_ibuf_stall                    => fdec_ibuf_stall_t0,
     iu_au_ib1_instr_vld                => iu_au_ib1_instr_vld_t0,
     iu_au_ib1_ifar                     => iu_au_ib1_ifar_t0,
     iu_au_ib1_data                     => iu_au_ib1_data_t0,
     xu_iu_ucode_restart                => xu_iu_ucode_restart(0),
     xu_iu_slowspr_done                 => xu_iu_slowspr_done(0),
     xu_iu_multdiv_done                 => xu_iu_multdiv_done(0),
     xu_iu_ex4_loadmiss_vld             => xu_iu_ex4_loadmiss_tid(0),
     xu_iu_ex4_loadmiss_qentry          => xu_iu_ex4_loadmiss_qentry,
     xu_iu_ex4_loadmiss_target          => xu_iu_ex4_loadmiss_target,
     xu_iu_ex4_loadmiss_target_type     => xu_iu_ex4_loadmiss_target_type,
     xu_iu_ex5_loadmiss_vld             => xu_iu_ex5_loadmiss_tid(0),
     xu_iu_ex5_loadmiss_qentry          => xu_iu_ex5_loadmiss_qentry,
     xu_iu_ex5_loadmiss_target          => xu_iu_ex5_loadmiss_target(1 to 6),
     xu_iu_ex5_loadmiss_target_type     => xu_iu_ex5_loadmiss_target_type(0 to 0),
     xu_iu_complete_vld                 => xu_iu_complete_tid(0),
     xu_iu_complete_qentry              => xu_iu_complete_qentry,
     xu_iu_complete_target_type         => xu_iu_complete_target_type,
     ic_fdep_load_quiesce               => ic_fdep_load_quiesce(0),
     iu_xu_quiesce                      => iu_xu_quiesce(0),
     xu_iu_membar_tid                   => xu_iu_membar_tid(0),
     xu_iu_set_barr_tid                 => xu_iu_set_barr_tid(0),
     xu_iu_larx_done_tid                => xu_iu_larx_done_tid(0),
     an_ac_sync_ack                     => an_ac_sync_ack(0),
     ic_fdep_icbi_ack                   => ic_fdep_icbi_ack(0),
     an_ac_stcx_complete                => an_ac_stcx_complete(0),
     mm_iu_barrier_done                 => mm_iu_barrier_done(0),
     spr_fdep_ll_hold                   => spr_fdep_ll_hold_t0,
     xu_iu_spr_ccr2_en_dcr              => xu_iu_spr_ccr2_en_dcr,
     xu_iu_single_instr_mode            => xu_iu_single_instr_mode(0),
     fiss_fdep_is2_take                 => fiss_fdep_is2_take0,
     fdep_fiss_is2_instr                => fdep_fiss_t0_is2_instr,
     fdep_fiss_is2_ta_vld               => fdep_fiss_t0_is2_ta_vld,
     fdep_fiss_is2_ta                   => fdep_fiss_t0_is2_ta,
     fdep_fiss_is2_s1_vld               => fdep_fiss_t0_is2_s1_vld,
     fdep_fiss_is2_s1                   => fdep_fiss_t0_is2_s1,
     fdep_fiss_is2_s2_vld               => fdep_fiss_t0_is2_s2_vld,
     fdep_fiss_is2_s2                   => fdep_fiss_t0_is2_s2,
     fdep_fiss_is2_s3_vld               => fdep_fiss_t0_is2_s3_vld,
     fdep_fiss_is2_s3                   => fdep_fiss_t0_is2_s3,
     fdep_fiss_is2_pred_update          => fdep_fiss_t0_is2_pred_update,
     fdep_fiss_is2_pred_taken_cnt       => fdep_fiss_t0_is2_pred_taken_cnt,
     fdep_fiss_is2_gshare               => fdep_fiss_t0_is2_gshare,
     fdep_fiss_is2_ifar                 => fdep_fiss_t0_is2_ifar,
     fdep_fiss_is2_error                => fdep_fiss_t0_is2_error,
     fdep_fiss_is2_axu_ld_or_st         => fdep_fiss_t0_is2_axu_ld_or_st,
     fdep_fiss_is2_axu_store            => fdep_fiss_t0_is2_axu_store,
     fdep_fiss_is2_axu_ldst_size        => fdep_fiss_t0_is2_axu_ldst_size,
     fdep_fiss_is2_axu_ldst_tag         => fdep_fiss_t0_is2_axu_ldst_tag,
     fdep_fiss_is2_axu_ldst_indexed     => fdep_fiss_t0_is2_axu_ldst_indexed,
     fdep_fiss_is2_axu_ldst_update      => fdep_fiss_t0_is2_axu_ldst_update,
     fdep_fiss_is2_axu_ldst_extpid      => fdep_fiss_t0_is2_axu_ldst_extpid,
     fdep_fiss_is2_axu_ldst_forcealign  => fdep_fiss_t0_is2_axu_ldst_forcealign,
     fdep_fiss_is2_axu_ldst_forceexcept => fdep_fiss_t0_is2_axu_ldst_forceexcept,
     fdep_fiss_is2_axu_mftgpr           => fdep_fiss_t0_is2_axu_mftgpr,
     fdep_fiss_is2_axu_mffgpr           => fdep_fiss_t0_is2_axu_mffgpr,
     fdep_fiss_is2_axu_movedp           => fdep_fiss_t0_is2_axu_movedp,
     fdep_fiss_is2_axu_instr_type       => fdep_fiss_t0_is2_axu_instr_type,
     fdep_fiss_is2_match                => fdep_fiss_t0_is2_match,
     fdep_fiss_is2_2ucode               => fdep_fiss_t0_is2_2ucode,
     fdep_fiss_is2_2ucode_type          => fdep_fiss_t0_is2_2ucode_type,
     fdep_fiss_is2early_vld             => fdep_fiss_t0_is2early_vld,
     fdep_fiss_is1_xu_dep_hit_b         => fdep_fiss_t0_is1_xu_dep_hit_b,
     fdep_fiss_is2_hole_delay           => fdep_fiss_t0_is2_hole_delay,
     fdep_fiss_is2_to_ucode             => fdep_fiss_t0_is2_to_ucode,      
     fdep_fiss_is2_is_ucode             => fdep_fiss_t0_is2_is_ucode,      
     fu_iu_uc_special                   => fu_iu_uc_special(0),
     iu_fu_ex2_n_flush                  => iu_fu_ex2_n_flush(0),
     i_afi_is2_take                     => i_afi_is2_take_t(0),
     i_axu_is1_dep_hit_b                => i_axu_is1_dep_hit_t0_b,
     i_axu_is2_instr_v                  => i_afd_is2_t0_instr_v,
     i_axu_is1_early_v                  => i_axu_is1_early_v_t0,
     i_axu_is2_instr_match              => i_axu_is2_instr_match_t0,
     i_axu_is2_fra                      => i_afd_is2_fra_t0,
     i_axu_is2_frb                      => i_afd_is2_frb_t0,
     i_axu_is2_frc                      => i_afd_is2_frc_t0,
     i_axu_is2_frt                      => i_afd_is2_frt_t0,
     i_axu_is2_fra_v                    => i_afd_is2_fra_v_t0,
     i_axu_is2_frb_v                    => i_afd_is2_frb_v_t0,
     i_axu_is2_frc_v                    => i_afd_is2_frc_v_t0,
     i_afd_is2_is_ucode                 => i_afd_is2_is_ucode_t0,
     i_afd_ignore_flush_is2             => i_afd_ignore_flush_is2_t0,
     i_afd_in_ucode_mode_or1d_b         => i_afd_in_ucode_mode_or1d_b_t0,
     ifdp_is2_est_bubble3               => ifdp_is2_est_bubble3_t0,
     ifdp_is2_bypsel                    => i_afd_is2_bypsel_t0,
     axu_dbg_data                       => axu_dbg_data_t0    	 
);
iuq_slice1   : entity work.iuq_slice
generic map(expand_type         => expand_type,
            regmode             => regmode,
            a2mode              => a2mode,
            lmq_entries         => lmq_entries)
port map(
     slice_id                           => slice_id1,
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,
     pc_iu_func_sl_thold_2              => pc_iu_func_sl_thold_2(1),    
     pc_iu_sg_2                         => pc_iu_sg_2(1),               
     clkoff_b                           => clkoff_b(1),                 
     an_ac_scan_dis_dc_b                => an_ac_scan_dis_dc_b(1),
     tc_ac_ccflush_dc                   => tc_ac_ccflush_dc,
     delay_lclkr                        => delay_lclkr(10+1),
     mpw1_b                             => mpw1_b(10+1),
     scan_in                            => iuq_s1_scan_in,    
     scan_out                           => iuq_s1_scan_out,   
     pc_iu_ram_mode                     => pc_iu_ram_mode,
     pc_iu_ram_thread                   => pc_iu_ram_thread,
     pc_iu_trace_bus_enable             => pc_iu_trace_bus_enable,
     pc_iu_event_bus_enable             => pc_iu_event_bus_enable,
     fdep_dbg_data                      => fdep_dbg_data(22*1   to 22*1+21),
     fdep_perf_event                    => fdep_perf_event_t1,
     iu_au_config_iucr                  => iu_au_config_iucr_t1,
     iu_au_config_iucr_pt               => iu_au_config_iucr_pt_t1,
     spr_dec_mask                       => spr_dec_mask_t1,
     spr_dec_match                      => spr_dec_match_t1,
     uc_flush                           => uc_flush_tid(1),
     xu_iu_flush                        => xu_iu_flush(1),   
     xu_iu_rf1_flush                    => xu_rf1_flush(1),
     xu_iu_ex1_flush                    => xu_ex1_flush(1),
     xu_iu_ex2_flush                    => xu_ex2_flush(1),
     xu_iu_ex3_flush                    => xu_ex3_flush(1),
     xu_iu_ex4_flush                    => xu_ex4_flush(1),
     xu_iu_ex5_flush                    => xu_ex5_flush(1),
     fdec_ibuf_stall                    => fdec_ibuf_stall_t1,
     iu_au_ib1_instr_vld                => iu_au_ib1_instr_vld_t1,
     iu_au_ib1_ifar                     => iu_au_ib1_ifar_t1,
     iu_au_ib1_data                     => iu_au_ib1_data_t1,
     xu_iu_ucode_restart                => xu_iu_ucode_restart(1),
     xu_iu_slowspr_done                 => xu_iu_slowspr_done(1),
     xu_iu_multdiv_done                 => xu_iu_multdiv_done(1),
     xu_iu_ex4_loadmiss_vld             => xu_iu_ex4_loadmiss_tid(1),
     xu_iu_ex4_loadmiss_qentry          => xu_iu_ex4_loadmiss_qentry,
     xu_iu_ex4_loadmiss_target          => xu_iu_ex4_loadmiss_target,
     xu_iu_ex4_loadmiss_target_type     => xu_iu_ex4_loadmiss_target_type,
     xu_iu_ex5_loadmiss_vld             => xu_iu_ex5_loadmiss_tid(1),
     xu_iu_ex5_loadmiss_qentry          => xu_iu_ex5_loadmiss_qentry,
     xu_iu_ex5_loadmiss_target          => xu_iu_ex5_loadmiss_target(1 to 6),
     xu_iu_ex5_loadmiss_target_type     => xu_iu_ex5_loadmiss_target_type(0 to 0),
     xu_iu_complete_vld                 => xu_iu_complete_tid(1),
     xu_iu_complete_qentry              => xu_iu_complete_qentry,
     xu_iu_complete_target_type         => xu_iu_complete_target_type,
     ic_fdep_load_quiesce               => ic_fdep_load_quiesce(1),
     iu_xu_quiesce                      => iu_xu_quiesce(1),
     xu_iu_membar_tid                   => xu_iu_membar_tid(1),
     xu_iu_set_barr_tid                 => xu_iu_set_barr_tid(1),
     xu_iu_larx_done_tid                => xu_iu_larx_done_tid(1),
     an_ac_sync_ack                     => an_ac_sync_ack(1),
     ic_fdep_icbi_ack                   => ic_fdep_icbi_ack(1),
     an_ac_stcx_complete                => an_ac_stcx_complete(1),
     mm_iu_barrier_done                 => mm_iu_barrier_done(1),
     spr_fdep_ll_hold                   => spr_fdep_ll_hold_t1,
     xu_iu_spr_ccr2_en_dcr              => xu_iu_spr_ccr2_en_dcr,
     xu_iu_single_instr_mode            => xu_iu_single_instr_mode(1),
     fiss_fdep_is2_take                 => fiss_fdep_is2_take1,
     fdep_fiss_is2_instr                => fdep_fiss_t1_is2_instr,
     fdep_fiss_is2_ta_vld               => fdep_fiss_t1_is2_ta_vld,
     fdep_fiss_is2_ta                   => fdep_fiss_t1_is2_ta,
     fdep_fiss_is2_s1_vld               => fdep_fiss_t1_is2_s1_vld,
     fdep_fiss_is2_s1                   => fdep_fiss_t1_is2_s1,
     fdep_fiss_is2_s2_vld               => fdep_fiss_t1_is2_s2_vld,
     fdep_fiss_is2_s2                   => fdep_fiss_t1_is2_s2,
     fdep_fiss_is2_s3_vld               => fdep_fiss_t1_is2_s3_vld,
     fdep_fiss_is2_s3                   => fdep_fiss_t1_is2_s3,
     fdep_fiss_is2_pred_update          => fdep_fiss_t1_is2_pred_update,
     fdep_fiss_is2_pred_taken_cnt       => fdep_fiss_t1_is2_pred_taken_cnt,
     fdep_fiss_is2_gshare               => fdep_fiss_t1_is2_gshare,
     fdep_fiss_is2_ifar                 => fdep_fiss_t1_is2_ifar,
     fdep_fiss_is2_error                => fdep_fiss_t1_is2_error,
     fdep_fiss_is2_axu_ld_or_st         => fdep_fiss_t1_is2_axu_ld_or_st,
     fdep_fiss_is2_axu_store            => fdep_fiss_t1_is2_axu_store,
     fdep_fiss_is2_axu_ldst_size        => fdep_fiss_t1_is2_axu_ldst_size,
     fdep_fiss_is2_axu_ldst_tag         => fdep_fiss_t1_is2_axu_ldst_tag,
     fdep_fiss_is2_axu_ldst_indexed     => fdep_fiss_t1_is2_axu_ldst_indexed,
     fdep_fiss_is2_axu_ldst_update      => fdep_fiss_t1_is2_axu_ldst_update,
     fdep_fiss_is2_axu_ldst_extpid      => fdep_fiss_t1_is2_axu_ldst_extpid,
     fdep_fiss_is2_axu_ldst_forcealign  => fdep_fiss_t1_is2_axu_ldst_forcealign,
     fdep_fiss_is2_axu_ldst_forceexcept => fdep_fiss_t1_is2_axu_ldst_forceexcept,
     fdep_fiss_is2_axu_mftgpr           => fdep_fiss_t1_is2_axu_mftgpr,
     fdep_fiss_is2_axu_mffgpr           => fdep_fiss_t1_is2_axu_mffgpr,
     fdep_fiss_is2_axu_movedp           => fdep_fiss_t1_is2_axu_movedp,
     fdep_fiss_is2_axu_instr_type       => fdep_fiss_t1_is2_axu_instr_type,
     fdep_fiss_is2_match                => fdep_fiss_t1_is2_match,
     fdep_fiss_is2_2ucode               => fdep_fiss_t1_is2_2ucode,
     fdep_fiss_is2_2ucode_type          => fdep_fiss_t1_is2_2ucode_type,
     fdep_fiss_is2early_vld             => fdep_fiss_t1_is2early_vld,
     fdep_fiss_is1_xu_dep_hit_b         => fdep_fiss_t1_is1_xu_dep_hit_b,
     fdep_fiss_is2_hole_delay           => fdep_fiss_t1_is2_hole_delay,
     fdep_fiss_is2_to_ucode             => fdep_fiss_t1_is2_to_ucode,      
     fdep_fiss_is2_is_ucode             => fdep_fiss_t1_is2_is_ucode,      
     fu_iu_uc_special                   => fu_iu_uc_special(1),
     iu_fu_ex2_n_flush                  => iu_fu_ex2_n_flush(1),
     i_afi_is2_take                     => i_afi_is2_take_t(1),
     i_axu_is1_dep_hit_b                => i_axu_is1_dep_hit_t1_b,
     i_axu_is2_instr_v                  => i_afd_is2_t1_instr_v,
     i_axu_is1_early_v                  => i_axu_is1_early_v_t1,
     i_axu_is2_instr_match              => i_axu_is2_instr_match_t1,
     i_axu_is2_fra                      => i_afd_is2_fra_t1,
     i_axu_is2_frb                      => i_afd_is2_frb_t1,
     i_axu_is2_frc                      => i_afd_is2_frc_t1,
     i_axu_is2_frt                      => i_afd_is2_frt_t1,
     i_axu_is2_fra_v                    => i_afd_is2_fra_v_t1,
     i_axu_is2_frb_v                    => i_afd_is2_frb_v_t1,
     i_axu_is2_frc_v                    => i_afd_is2_frc_v_t1,
     i_afd_is2_is_ucode                 => i_afd_is2_is_ucode_t1,
     i_afd_ignore_flush_is2             => i_afd_ignore_flush_is2_t1,
     i_afd_in_ucode_mode_or1d_b         => i_afd_in_ucode_mode_or1d_b_t1,
     ifdp_is2_est_bubble3               => ifdp_is2_est_bubble3_t1,
     ifdp_is2_bypsel                    => i_afd_is2_bypsel_t1,
     axu_dbg_data                       => axu_dbg_data_t1    	 
);
iuq_slice2   : entity work.iuq_slice
generic map(expand_type         => expand_type,
            regmode             => regmode,
            a2mode              => a2mode,
            lmq_entries         => lmq_entries)
port map(
     slice_id                           => slice_id2,
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,
     pc_iu_func_sl_thold_2              => pc_iu_func_sl_thold_2(2),    
     pc_iu_sg_2                         => pc_iu_sg_2(2),               
     clkoff_b                           => clkoff_b(2),                 
     an_ac_scan_dis_dc_b                => an_ac_scan_dis_dc_b(2),
     tc_ac_ccflush_dc                   => tc_ac_ccflush_dc,
     delay_lclkr                        => delay_lclkr(10+2),
     mpw1_b                             => mpw1_b(10+2),
     scan_in                            => iuq_s2_scan_in,    
     scan_out                           => iuq_s2_scan_out,   
     pc_iu_ram_mode                     => pc_iu_ram_mode,
     pc_iu_ram_thread                   => pc_iu_ram_thread,
     pc_iu_trace_bus_enable             => pc_iu_trace_bus_enable,
     pc_iu_event_bus_enable             => pc_iu_event_bus_enable,
     fdep_dbg_data                      => fdep_dbg_data(22*2   to 22*2+21),
     fdep_perf_event                    => fdep_perf_event_t2,
     iu_au_config_iucr                  => iu_au_config_iucr_t2,
     iu_au_config_iucr_pt               => iu_au_config_iucr_pt_t2,
     spr_dec_mask                       => spr_dec_mask_t2,
     spr_dec_match                      => spr_dec_match_t2,
     uc_flush                           => uc_flush_tid(2),
     xu_iu_flush                        => xu_iu_flush(2),   
     xu_iu_rf1_flush                    => xu_rf1_flush(2),
     xu_iu_ex1_flush                    => xu_ex1_flush(2),
     xu_iu_ex2_flush                    => xu_ex2_flush(2),
     xu_iu_ex3_flush                    => xu_ex3_flush(2),
     xu_iu_ex4_flush                    => xu_ex4_flush(2),
     xu_iu_ex5_flush                    => xu_ex5_flush(2),
     fdec_ibuf_stall                    => fdec_ibuf_stall_t2,
     iu_au_ib1_instr_vld                => iu_au_ib1_instr_vld_t2,
     iu_au_ib1_ifar                     => iu_au_ib1_ifar_t2,
     iu_au_ib1_data                     => iu_au_ib1_data_t2,
     xu_iu_ucode_restart                => xu_iu_ucode_restart(2),
     xu_iu_slowspr_done                 => xu_iu_slowspr_done(2),
     xu_iu_multdiv_done                 => xu_iu_multdiv_done(2),
     xu_iu_ex4_loadmiss_vld             => xu_iu_ex4_loadmiss_tid(2),
     xu_iu_ex4_loadmiss_qentry          => xu_iu_ex4_loadmiss_qentry,
     xu_iu_ex4_loadmiss_target          => xu_iu_ex4_loadmiss_target,
     xu_iu_ex4_loadmiss_target_type     => xu_iu_ex4_loadmiss_target_type,
     xu_iu_ex5_loadmiss_vld             => xu_iu_ex5_loadmiss_tid(2),
     xu_iu_ex5_loadmiss_qentry          => xu_iu_ex5_loadmiss_qentry,
     xu_iu_ex5_loadmiss_target          => xu_iu_ex5_loadmiss_target(1 to 6),
     xu_iu_ex5_loadmiss_target_type     => xu_iu_ex5_loadmiss_target_type(0 to 0),
     xu_iu_complete_vld                 => xu_iu_complete_tid(2),
     xu_iu_complete_qentry              => xu_iu_complete_qentry,
     xu_iu_complete_target_type         => xu_iu_complete_target_type,
     ic_fdep_load_quiesce               => ic_fdep_load_quiesce(2),
     iu_xu_quiesce                      => iu_xu_quiesce(2),
     xu_iu_membar_tid                   => xu_iu_membar_tid(2),
     xu_iu_set_barr_tid                 => xu_iu_set_barr_tid(2),
     xu_iu_larx_done_tid                => xu_iu_larx_done_tid(2),
     an_ac_sync_ack                     => an_ac_sync_ack(2),
     ic_fdep_icbi_ack                   => ic_fdep_icbi_ack(2),
     an_ac_stcx_complete                => an_ac_stcx_complete(2),
     mm_iu_barrier_done                 => mm_iu_barrier_done(2),
     spr_fdep_ll_hold                   => spr_fdep_ll_hold_t2,
     xu_iu_spr_ccr2_en_dcr              => xu_iu_spr_ccr2_en_dcr,
     xu_iu_single_instr_mode            => xu_iu_single_instr_mode(2),
     fiss_fdep_is2_take                 => fiss_fdep_is2_take2,
     fdep_fiss_is2_instr                => fdep_fiss_t2_is2_instr,
     fdep_fiss_is2_ta_vld               => fdep_fiss_t2_is2_ta_vld,
     fdep_fiss_is2_ta                   => fdep_fiss_t2_is2_ta,
     fdep_fiss_is2_s1_vld               => fdep_fiss_t2_is2_s1_vld,
     fdep_fiss_is2_s1                   => fdep_fiss_t2_is2_s1,
     fdep_fiss_is2_s2_vld               => fdep_fiss_t2_is2_s2_vld,
     fdep_fiss_is2_s2                   => fdep_fiss_t2_is2_s2,
     fdep_fiss_is2_s3_vld               => fdep_fiss_t2_is2_s3_vld,
     fdep_fiss_is2_s3                   => fdep_fiss_t2_is2_s3,
     fdep_fiss_is2_pred_update          => fdep_fiss_t2_is2_pred_update,
     fdep_fiss_is2_pred_taken_cnt       => fdep_fiss_t2_is2_pred_taken_cnt,
     fdep_fiss_is2_gshare               => fdep_fiss_t2_is2_gshare,
     fdep_fiss_is2_ifar                 => fdep_fiss_t2_is2_ifar,
     fdep_fiss_is2_error                => fdep_fiss_t2_is2_error,
     fdep_fiss_is2_axu_ld_or_st         => fdep_fiss_t2_is2_axu_ld_or_st,
     fdep_fiss_is2_axu_store            => fdep_fiss_t2_is2_axu_store,
     fdep_fiss_is2_axu_ldst_size        => fdep_fiss_t2_is2_axu_ldst_size,
     fdep_fiss_is2_axu_ldst_tag         => fdep_fiss_t2_is2_axu_ldst_tag,
     fdep_fiss_is2_axu_ldst_indexed     => fdep_fiss_t2_is2_axu_ldst_indexed,
     fdep_fiss_is2_axu_ldst_update      => fdep_fiss_t2_is2_axu_ldst_update,
     fdep_fiss_is2_axu_ldst_extpid      => fdep_fiss_t2_is2_axu_ldst_extpid,
     fdep_fiss_is2_axu_ldst_forcealign  => fdep_fiss_t2_is2_axu_ldst_forcealign,
     fdep_fiss_is2_axu_ldst_forceexcept => fdep_fiss_t2_is2_axu_ldst_forceexcept,
     fdep_fiss_is2_axu_mftgpr           => fdep_fiss_t2_is2_axu_mftgpr,
     fdep_fiss_is2_axu_mffgpr           => fdep_fiss_t2_is2_axu_mffgpr,
     fdep_fiss_is2_axu_movedp           => fdep_fiss_t2_is2_axu_movedp,
     fdep_fiss_is2_axu_instr_type       => fdep_fiss_t2_is2_axu_instr_type,
     fdep_fiss_is2_match                => fdep_fiss_t2_is2_match,
     fdep_fiss_is2_2ucode               => fdep_fiss_t2_is2_2ucode,
     fdep_fiss_is2_2ucode_type          => fdep_fiss_t2_is2_2ucode_type,
     fdep_fiss_is2early_vld             => fdep_fiss_t2_is2early_vld,
     fdep_fiss_is1_xu_dep_hit_b         => fdep_fiss_t2_is1_xu_dep_hit_b,
     fdep_fiss_is2_hole_delay           => fdep_fiss_t2_is2_hole_delay,
     fdep_fiss_is2_to_ucode             => fdep_fiss_t2_is2_to_ucode,      
     fdep_fiss_is2_is_ucode             => fdep_fiss_t2_is2_is_ucode,      
     fu_iu_uc_special                   => fu_iu_uc_special(2),
     iu_fu_ex2_n_flush                  => iu_fu_ex2_n_flush(2),
     i_afi_is2_take                     => i_afi_is2_take_t(2),
     i_axu_is1_dep_hit_b                => i_axu_is1_dep_hit_t2_b,
     i_axu_is2_instr_v                  => i_afd_is2_t2_instr_v,
     i_axu_is1_early_v                  => i_axu_is1_early_v_t2,
     i_axu_is2_instr_match              => i_axu_is2_instr_match_t2,
     i_axu_is2_fra                      => i_afd_is2_fra_t2,
     i_axu_is2_frb                      => i_afd_is2_frb_t2,
     i_axu_is2_frc                      => i_afd_is2_frc_t2,
     i_axu_is2_frt                      => i_afd_is2_frt_t2,
     i_axu_is2_fra_v                    => i_afd_is2_fra_v_t2,
     i_axu_is2_frb_v                    => i_afd_is2_frb_v_t2,
     i_axu_is2_frc_v                    => i_afd_is2_frc_v_t2,
     i_afd_is2_is_ucode                 => i_afd_is2_is_ucode_t2,
     i_afd_ignore_flush_is2             => i_afd_ignore_flush_is2_t2,
     i_afd_in_ucode_mode_or1d_b         => i_afd_in_ucode_mode_or1d_b_t2,
     ifdp_is2_est_bubble3               => ifdp_is2_est_bubble3_t2,
     ifdp_is2_bypsel                    => i_afd_is2_bypsel_t2,
     axu_dbg_data                       => axu_dbg_data_t2    	 
);
iuq_slice3   : entity work.iuq_slice
generic map(expand_type         => expand_type,
            regmode             => regmode,
            a2mode              => a2mode,
            lmq_entries         => lmq_entries)
port map(
     slice_id                           => slice_id3,
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,
     pc_iu_func_sl_thold_2              => pc_iu_func_sl_thold_2(3),    
     pc_iu_sg_2                         => pc_iu_sg_2(3),               
     clkoff_b                           => clkoff_b(3),                 
     an_ac_scan_dis_dc_b                => an_ac_scan_dis_dc_b(3),
     tc_ac_ccflush_dc                   => tc_ac_ccflush_dc,
     delay_lclkr                        => delay_lclkr(10+3),
     mpw1_b                             => mpw1_b(10+3),
     scan_in                            => iuq_s3_scan_in,    
     scan_out                           => iuq_s3_scan_out,   
     pc_iu_ram_mode                     => pc_iu_ram_mode,
     pc_iu_ram_thread                   => pc_iu_ram_thread,
     pc_iu_trace_bus_enable             => pc_iu_trace_bus_enable,
     pc_iu_event_bus_enable             => pc_iu_event_bus_enable,
     fdep_dbg_data                      => fdep_dbg_data(22*3   to 22*3+21),
     fdep_perf_event                    => fdep_perf_event_t3,
     iu_au_config_iucr                  => iu_au_config_iucr_t3,
     iu_au_config_iucr_pt               => iu_au_config_iucr_pt_t3,
     spr_dec_mask                       => spr_dec_mask_t3,
     spr_dec_match                      => spr_dec_match_t3,
     uc_flush                           => uc_flush_tid(3),
     xu_iu_flush                        => xu_iu_flush(3),   
     xu_iu_rf1_flush                    => xu_rf1_flush(3),
     xu_iu_ex1_flush                    => xu_ex1_flush(3),
     xu_iu_ex2_flush                    => xu_ex2_flush(3),
     xu_iu_ex3_flush                    => xu_ex3_flush(3),
     xu_iu_ex4_flush                    => xu_ex4_flush(3),
     xu_iu_ex5_flush                    => xu_ex5_flush(3),
     fdec_ibuf_stall                    => fdec_ibuf_stall_t3,
     iu_au_ib1_instr_vld                => iu_au_ib1_instr_vld_t3,
     iu_au_ib1_ifar                     => iu_au_ib1_ifar_t3,
     iu_au_ib1_data                     => iu_au_ib1_data_t3,
     xu_iu_ucode_restart                => xu_iu_ucode_restart(3),
     xu_iu_slowspr_done                 => xu_iu_slowspr_done(3),
     xu_iu_multdiv_done                 => xu_iu_multdiv_done(3),
     xu_iu_ex4_loadmiss_vld             => xu_iu_ex4_loadmiss_tid(3),
     xu_iu_ex4_loadmiss_qentry          => xu_iu_ex4_loadmiss_qentry,
     xu_iu_ex4_loadmiss_target          => xu_iu_ex4_loadmiss_target,
     xu_iu_ex4_loadmiss_target_type     => xu_iu_ex4_loadmiss_target_type,
     xu_iu_ex5_loadmiss_vld             => xu_iu_ex5_loadmiss_tid(3),
     xu_iu_ex5_loadmiss_qentry          => xu_iu_ex5_loadmiss_qentry,
     xu_iu_ex5_loadmiss_target          => xu_iu_ex5_loadmiss_target(1 to 6),
     xu_iu_ex5_loadmiss_target_type     => xu_iu_ex5_loadmiss_target_type(0 to 0),
     xu_iu_complete_vld                 => xu_iu_complete_tid(3),
     xu_iu_complete_qentry              => xu_iu_complete_qentry,
     xu_iu_complete_target_type         => xu_iu_complete_target_type,
     ic_fdep_load_quiesce               => ic_fdep_load_quiesce(3),
     iu_xu_quiesce                      => iu_xu_quiesce(3),
     xu_iu_membar_tid                   => xu_iu_membar_tid(3),
     xu_iu_set_barr_tid                 => xu_iu_set_barr_tid(3),
     xu_iu_larx_done_tid                => xu_iu_larx_done_tid(3),
     an_ac_sync_ack                     => an_ac_sync_ack(3),
     ic_fdep_icbi_ack                   => ic_fdep_icbi_ack(3),
     an_ac_stcx_complete                => an_ac_stcx_complete(3),
     mm_iu_barrier_done                 => mm_iu_barrier_done(3),
     spr_fdep_ll_hold                   => spr_fdep_ll_hold_t3,
     xu_iu_spr_ccr2_en_dcr              => xu_iu_spr_ccr2_en_dcr,
     xu_iu_single_instr_mode            => xu_iu_single_instr_mode(3),
     fiss_fdep_is2_take                 => fiss_fdep_is2_take3,
     fdep_fiss_is2_instr                => fdep_fiss_t3_is2_instr,
     fdep_fiss_is2_ta_vld               => fdep_fiss_t3_is2_ta_vld,
     fdep_fiss_is2_ta                   => fdep_fiss_t3_is2_ta,
     fdep_fiss_is2_s1_vld               => fdep_fiss_t3_is2_s1_vld,
     fdep_fiss_is2_s1                   => fdep_fiss_t3_is2_s1,
     fdep_fiss_is2_s2_vld               => fdep_fiss_t3_is2_s2_vld,
     fdep_fiss_is2_s2                   => fdep_fiss_t3_is2_s2,
     fdep_fiss_is2_s3_vld               => fdep_fiss_t3_is2_s3_vld,
     fdep_fiss_is2_s3                   => fdep_fiss_t3_is2_s3,
     fdep_fiss_is2_pred_update          => fdep_fiss_t3_is2_pred_update,
     fdep_fiss_is2_pred_taken_cnt       => fdep_fiss_t3_is2_pred_taken_cnt,
     fdep_fiss_is2_gshare               => fdep_fiss_t3_is2_gshare,
     fdep_fiss_is2_ifar                 => fdep_fiss_t3_is2_ifar,
     fdep_fiss_is2_error                => fdep_fiss_t3_is2_error,
     fdep_fiss_is2_axu_ld_or_st         => fdep_fiss_t3_is2_axu_ld_or_st,
     fdep_fiss_is2_axu_store            => fdep_fiss_t3_is2_axu_store,
     fdep_fiss_is2_axu_ldst_size        => fdep_fiss_t3_is2_axu_ldst_size,
     fdep_fiss_is2_axu_ldst_tag         => fdep_fiss_t3_is2_axu_ldst_tag,
     fdep_fiss_is2_axu_ldst_indexed     => fdep_fiss_t3_is2_axu_ldst_indexed,
     fdep_fiss_is2_axu_ldst_update      => fdep_fiss_t3_is2_axu_ldst_update,
     fdep_fiss_is2_axu_ldst_extpid      => fdep_fiss_t3_is2_axu_ldst_extpid,
     fdep_fiss_is2_axu_ldst_forcealign  => fdep_fiss_t3_is2_axu_ldst_forcealign,
     fdep_fiss_is2_axu_ldst_forceexcept => fdep_fiss_t3_is2_axu_ldst_forceexcept,
     fdep_fiss_is2_axu_mftgpr           => fdep_fiss_t3_is2_axu_mftgpr,
     fdep_fiss_is2_axu_mffgpr           => fdep_fiss_t3_is2_axu_mffgpr,
     fdep_fiss_is2_axu_movedp           => fdep_fiss_t3_is2_axu_movedp,
     fdep_fiss_is2_axu_instr_type       => fdep_fiss_t3_is2_axu_instr_type,
     fdep_fiss_is2_match                => fdep_fiss_t3_is2_match,
     fdep_fiss_is2_2ucode               => fdep_fiss_t3_is2_2ucode,
     fdep_fiss_is2_2ucode_type          => fdep_fiss_t3_is2_2ucode_type,
     fdep_fiss_is2early_vld             => fdep_fiss_t3_is2early_vld,
     fdep_fiss_is1_xu_dep_hit_b         => fdep_fiss_t3_is1_xu_dep_hit_b,
     fdep_fiss_is2_hole_delay           => fdep_fiss_t3_is2_hole_delay,
     fdep_fiss_is2_to_ucode             => fdep_fiss_t3_is2_to_ucode,      
     fdep_fiss_is2_is_ucode             => fdep_fiss_t3_is2_is_ucode,      
     fu_iu_uc_special                   => fu_iu_uc_special(3),
     iu_fu_ex2_n_flush                  => iu_fu_ex2_n_flush(3),
     i_afi_is2_take                     => i_afi_is2_take_t(3),
     i_axu_is1_dep_hit_b                => i_axu_is1_dep_hit_t3_b,
     i_axu_is2_instr_v                  => i_afd_is2_t3_instr_v,
     i_axu_is1_early_v                  => i_axu_is1_early_v_t3,
     i_axu_is2_instr_match              => i_axu_is2_instr_match_t3,
     i_axu_is2_fra                      => i_afd_is2_fra_t3,
     i_axu_is2_frb                      => i_afd_is2_frb_t3,
     i_axu_is2_frc                      => i_afd_is2_frc_t3,
     i_axu_is2_frt                      => i_afd_is2_frt_t3,
     i_axu_is2_fra_v                    => i_afd_is2_fra_v_t3,
     i_axu_is2_frb_v                    => i_afd_is2_frb_v_t3,
     i_axu_is2_frc_v                    => i_afd_is2_frc_v_t3,
     i_afd_is2_is_ucode                 => i_afd_is2_is_ucode_t3,
     i_afd_ignore_flush_is2             => i_afd_ignore_flush_is2_t3,
     i_afd_in_ucode_mode_or1d_b         => i_afd_in_ucode_mode_or1d_b_t3,
     ifdp_is2_est_bubble3               => ifdp_is2_est_bubble3_t3,
     ifdp_is2_bypsel                    => i_afd_is2_bypsel_t3,
     axu_dbg_data                       => axu_dbg_data_t3    	 
);
slice_id0(0 to 1)       <= "00";
slice_id1(0 to 1)       <= "01";
slice_id2(0 to 1)       <= "10";
slice_id3(0 to 1)       <= "11";
iuq_fxu_issue0 : entity work.iuq_fxu_issue
generic map(expand_type           => expand_type)
port map(
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,
     pc_iu_func_sl_thold_2              => pc_iu_func_sl_thold_2(1),    
     pc_iu_sg_2                         => pc_iu_sg_2(1),               
     clkoff_b                           => clkoff_b(1),                 
     an_ac_scan_dis_dc_b                => an_ac_scan_dis_dc_b(1),
     tc_ac_ccflush_dc                   => tc_ac_ccflush_dc,
     delay_lclkr                        => delay_lclkr(9),
     mpw1_b                             => mpw1_b(9),
     scan_in                            => iuq_fi_scan_in, 
     scan_out                           => iuq_fi_scan_out, 
     fiss_dbg_data                      => fiss_dbg_data,
     pc_iu_trace_bus_enable             => pc_iu_trace_bus_enable,
     pc_iu_event_bus_enable             => pc_iu_event_bus_enable,
     fiss_perf_event_t0                 => fiss_perf_event_t0,
     fiss_perf_event_t1                 => fiss_perf_event_t1,
     fiss_perf_event_t2                 => fiss_perf_event_t2,
     fiss_perf_event_t3                 => fiss_perf_event_t3,
     xu_iu_need_hole                    => xu_iu_need_hole,
     xu_iu_xucr0_rel                    => xu_iu_xucr0_rel,
     an_ac_reld_data_vld                => an_ac_reld_data_vld_clone,
     an_ac_reld_core_tag                => an_ac_reld_core_tag_clone(1 to 4),
     an_ac_reld_ditc                    => an_ac_reld_ditc_clone,
     an_ac_reld_data_coming             => an_ac_reld_data_coming_clone,
     an_ac_back_inv                     => an_ac_back_inv,
     an_ac_back_inv_target              => an_ac_back_inv_target(1),
     fiss_uc_is2_ucode_vld              => fiss_uc_is2_ucode_vld,
     fdep_fiss_t0_is2_instr             => fdep_fiss_t0_is2_instr,
     fdep_fiss_t0_is2_ta_vld            => fdep_fiss_t0_is2_ta_vld,
     fdep_fiss_t0_is2_ta                => fdep_fiss_t0_is2_ta,
     fdep_fiss_t0_is2_s1_vld            => fdep_fiss_t0_is2_s1_vld,
     fdep_fiss_t0_is2_s1                => fdep_fiss_t0_is2_s1,
     fdep_fiss_t0_is2_s2_vld            => fdep_fiss_t0_is2_s2_vld,
     fdep_fiss_t0_is2_s2                => fdep_fiss_t0_is2_s2,
     fdep_fiss_t0_is2_s3_vld            => fdep_fiss_t0_is2_s3_vld,
     fdep_fiss_t0_is2_s3                => fdep_fiss_t0_is2_s3,
     fdep_fiss_t0_is2_pred_update       => fdep_fiss_t0_is2_pred_update,
     fdep_fiss_t0_is2_pred_taken_cnt    => fdep_fiss_t0_is2_pred_taken_cnt,
     fdep_fiss_t0_is2_gshare            => fdep_fiss_t0_is2_gshare,
     fdep_fiss_t0_is2_ifar              => fdep_fiss_t0_is2_ifar,
     fdep_fiss_t0_is2_error             => fdep_fiss_t0_is2_error,
     fdep_fiss_t0_is2_axu_ld_or_st      => fdep_fiss_t0_is2_axu_ld_or_st,
     fdep_fiss_t0_is2_axu_store         => fdep_fiss_t0_is2_axu_store,
     fdep_fiss_t0_is2_axu_ldst_size     => fdep_fiss_t0_is2_axu_ldst_size,
     fdep_fiss_t0_is2_axu_ldst_tag      => fdep_fiss_t0_is2_axu_ldst_tag,
     fdep_fiss_t0_is2_axu_ldst_indexed=>   fdep_fiss_t0_is2_axu_ldst_indexed,
     fdep_fiss_t0_is2_axu_ldst_update        => fdep_fiss_t0_is2_axu_ldst_update,
     fdep_fiss_t0_is2_axu_ldst_extpid        => fdep_fiss_t0_is2_axu_ldst_extpid,
     fdep_fiss_t0_is2_axu_ldst_forcealign    => fdep_fiss_t0_is2_axu_ldst_forcealign,
     fdep_fiss_t0_is2_axu_ldst_forceexcept   => fdep_fiss_t0_is2_axu_ldst_forceexcept,
     fdep_fiss_t0_is2_axu_mftgpr        => fdep_fiss_t0_is2_axu_mftgpr,
     fdep_fiss_t0_is2_axu_mffgpr        => fdep_fiss_t0_is2_axu_mffgpr,
     fdep_fiss_t0_is2_axu_movedp        => fdep_fiss_t0_is2_axu_movedp,
     fdep_fiss_t0_is2_axu_instr_type    => fdep_fiss_t0_is2_axu_instr_type,
     fdep_fiss_t0_is2_match             => fdep_fiss_t0_is2_match,
     fdep_fiss_t0_is2_2ucode            => fdep_fiss_t0_is2_2ucode,
     fdep_fiss_t0_is2_2ucode_type       => fdep_fiss_t0_is2_2ucode_type,
     fdep_fiss_t0_is2_hole_delay        => fdep_fiss_t0_is2_hole_delay,
     fdep_fiss_t0_is2_to_ucode          => fdep_fiss_t0_is2_to_ucode,
     fdep_fiss_t0_is2_is_ucode          => fdep_fiss_t0_is2_is_ucode,
     fdep_fiss_t0_is2early_vld          => fdep_fiss_t0_is2early_vld,
     fdep_fiss_t0_is1_xu_dep_hit_b      => fdep_fiss_t0_is1_xu_dep_hit_b,
     fdep_fiss_t1_is2_instr             => fdep_fiss_t1_is2_instr,
     fdep_fiss_t1_is2_ta_vld            => fdep_fiss_t1_is2_ta_vld,
     fdep_fiss_t1_is2_ta                => fdep_fiss_t1_is2_ta,
     fdep_fiss_t1_is2_s1_vld            => fdep_fiss_t1_is2_s1_vld,
     fdep_fiss_t1_is2_s1                => fdep_fiss_t1_is2_s1,
     fdep_fiss_t1_is2_s2_vld            => fdep_fiss_t1_is2_s2_vld,
     fdep_fiss_t1_is2_s2                => fdep_fiss_t1_is2_s2,
     fdep_fiss_t1_is2_s3_vld            => fdep_fiss_t1_is2_s3_vld,
     fdep_fiss_t1_is2_s3                => fdep_fiss_t1_is2_s3,
     fdep_fiss_t1_is2_pred_update       => fdep_fiss_t1_is2_pred_update,
     fdep_fiss_t1_is2_pred_taken_cnt    => fdep_fiss_t1_is2_pred_taken_cnt,
     fdep_fiss_t1_is2_gshare            => fdep_fiss_t1_is2_gshare,
     fdep_fiss_t1_is2_ifar              => fdep_fiss_t1_is2_ifar,
     fdep_fiss_t1_is2_error             => fdep_fiss_t1_is2_error,
     fdep_fiss_t1_is2_axu_ld_or_st      => fdep_fiss_t1_is2_axu_ld_or_st,
     fdep_fiss_t1_is2_axu_store         => fdep_fiss_t1_is2_axu_store,
     fdep_fiss_t1_is2_axu_ldst_size     => fdep_fiss_t1_is2_axu_ldst_size,
     fdep_fiss_t1_is2_axu_ldst_tag      => fdep_fiss_t1_is2_axu_ldst_tag,
     fdep_fiss_t1_is2_axu_ldst_indexed=>   fdep_fiss_t1_is2_axu_ldst_indexed,
     fdep_fiss_t1_is2_axu_ldst_update        => fdep_fiss_t1_is2_axu_ldst_update,
     fdep_fiss_t1_is2_axu_ldst_extpid        => fdep_fiss_t1_is2_axu_ldst_extpid,
     fdep_fiss_t1_is2_axu_ldst_forcealign    => fdep_fiss_t1_is2_axu_ldst_forcealign,
     fdep_fiss_t1_is2_axu_ldst_forceexcept   => fdep_fiss_t1_is2_axu_ldst_forceexcept,
     fdep_fiss_t1_is2_axu_mftgpr        => fdep_fiss_t1_is2_axu_mftgpr,
     fdep_fiss_t1_is2_axu_mffgpr        => fdep_fiss_t1_is2_axu_mffgpr,
     fdep_fiss_t1_is2_axu_movedp        => fdep_fiss_t1_is2_axu_movedp,
     fdep_fiss_t1_is2_axu_instr_type    => fdep_fiss_t1_is2_axu_instr_type,
     fdep_fiss_t1_is2_match             => fdep_fiss_t1_is2_match,
     fdep_fiss_t1_is2_2ucode            => fdep_fiss_t1_is2_2ucode,
     fdep_fiss_t1_is2_2ucode_type       => fdep_fiss_t1_is2_2ucode_type,
     fdep_fiss_t1_is2_hole_delay        => fdep_fiss_t1_is2_hole_delay,
     fdep_fiss_t1_is2_to_ucode          => fdep_fiss_t1_is2_to_ucode,
     fdep_fiss_t1_is2_is_ucode          => fdep_fiss_t1_is2_is_ucode,
     fdep_fiss_t1_is2early_vld          => fdep_fiss_t1_is2early_vld,
     fdep_fiss_t1_is1_xu_dep_hit_b      => fdep_fiss_t1_is1_xu_dep_hit_b,
     fdep_fiss_t2_is2_instr             => fdep_fiss_t2_is2_instr,
     fdep_fiss_t2_is2_ta_vld            => fdep_fiss_t2_is2_ta_vld,
     fdep_fiss_t2_is2_ta                => fdep_fiss_t2_is2_ta,
     fdep_fiss_t2_is2_s1_vld            => fdep_fiss_t2_is2_s1_vld,
     fdep_fiss_t2_is2_s1                => fdep_fiss_t2_is2_s1,
     fdep_fiss_t2_is2_s2_vld            => fdep_fiss_t2_is2_s2_vld,
     fdep_fiss_t2_is2_s2                => fdep_fiss_t2_is2_s2,
     fdep_fiss_t2_is2_s3_vld            => fdep_fiss_t2_is2_s3_vld,
     fdep_fiss_t2_is2_s3                => fdep_fiss_t2_is2_s3,
     fdep_fiss_t2_is2_pred_update       => fdep_fiss_t2_is2_pred_update,
     fdep_fiss_t2_is2_pred_taken_cnt    => fdep_fiss_t2_is2_pred_taken_cnt,
     fdep_fiss_t2_is2_gshare            => fdep_fiss_t2_is2_gshare,
     fdep_fiss_t2_is2_ifar              => fdep_fiss_t2_is2_ifar,
     fdep_fiss_t2_is2_error             => fdep_fiss_t2_is2_error,
     fdep_fiss_t2_is2_axu_ld_or_st      => fdep_fiss_t2_is2_axu_ld_or_st,
     fdep_fiss_t2_is2_axu_store         => fdep_fiss_t2_is2_axu_store,
     fdep_fiss_t2_is2_axu_ldst_size     => fdep_fiss_t2_is2_axu_ldst_size,
     fdep_fiss_t2_is2_axu_ldst_tag      => fdep_fiss_t2_is2_axu_ldst_tag,
     fdep_fiss_t2_is2_axu_ldst_indexed=>   fdep_fiss_t2_is2_axu_ldst_indexed,
     fdep_fiss_t2_is2_axu_ldst_update        => fdep_fiss_t2_is2_axu_ldst_update,
     fdep_fiss_t2_is2_axu_ldst_extpid        => fdep_fiss_t2_is2_axu_ldst_extpid,
     fdep_fiss_t2_is2_axu_ldst_forcealign    => fdep_fiss_t2_is2_axu_ldst_forcealign,
     fdep_fiss_t2_is2_axu_ldst_forceexcept   => fdep_fiss_t2_is2_axu_ldst_forceexcept,
     fdep_fiss_t2_is2_axu_mftgpr        => fdep_fiss_t2_is2_axu_mftgpr,
     fdep_fiss_t2_is2_axu_mffgpr        => fdep_fiss_t2_is2_axu_mffgpr,
     fdep_fiss_t2_is2_axu_movedp        => fdep_fiss_t2_is2_axu_movedp,
     fdep_fiss_t2_is2_axu_instr_type    => fdep_fiss_t2_is2_axu_instr_type,
     fdep_fiss_t2_is2_match             => fdep_fiss_t2_is2_match,
     fdep_fiss_t2_is2_2ucode            => fdep_fiss_t2_is2_2ucode,
     fdep_fiss_t2_is2_2ucode_type       => fdep_fiss_t2_is2_2ucode_type,
     fdep_fiss_t2_is2_hole_delay        => fdep_fiss_t2_is2_hole_delay,
     fdep_fiss_t2_is2_to_ucode          => fdep_fiss_t2_is2_to_ucode,
     fdep_fiss_t2_is2_is_ucode          => fdep_fiss_t2_is2_is_ucode,
     fdep_fiss_t2_is2early_vld          => fdep_fiss_t2_is2early_vld,
     fdep_fiss_t2_is1_xu_dep_hit_b      => fdep_fiss_t2_is1_xu_dep_hit_b,
     fdep_fiss_t3_is2_instr             => fdep_fiss_t3_is2_instr,
     fdep_fiss_t3_is2_ta_vld            => fdep_fiss_t3_is2_ta_vld,
     fdep_fiss_t3_is2_ta                => fdep_fiss_t3_is2_ta,
     fdep_fiss_t3_is2_s1_vld            => fdep_fiss_t3_is2_s1_vld,
     fdep_fiss_t3_is2_s1                => fdep_fiss_t3_is2_s1,
     fdep_fiss_t3_is2_s2_vld            => fdep_fiss_t3_is2_s2_vld,
     fdep_fiss_t3_is2_s2                => fdep_fiss_t3_is2_s2,
     fdep_fiss_t3_is2_s3_vld            => fdep_fiss_t3_is2_s3_vld,
     fdep_fiss_t3_is2_s3                => fdep_fiss_t3_is2_s3,
     fdep_fiss_t3_is2_pred_update       => fdep_fiss_t3_is2_pred_update,
     fdep_fiss_t3_is2_pred_taken_cnt    => fdep_fiss_t3_is2_pred_taken_cnt,
     fdep_fiss_t3_is2_gshare            => fdep_fiss_t3_is2_gshare,
     fdep_fiss_t3_is2_ifar              => fdep_fiss_t3_is2_ifar,
     fdep_fiss_t3_is2_error             => fdep_fiss_t3_is2_error,
     fdep_fiss_t3_is2_axu_ld_or_st      => fdep_fiss_t3_is2_axu_ld_or_st,
     fdep_fiss_t3_is2_axu_store         => fdep_fiss_t3_is2_axu_store,
     fdep_fiss_t3_is2_axu_ldst_size     => fdep_fiss_t3_is2_axu_ldst_size,
     fdep_fiss_t3_is2_axu_ldst_tag      => fdep_fiss_t3_is2_axu_ldst_tag,
     fdep_fiss_t3_is2_axu_ldst_indexed=>   fdep_fiss_t3_is2_axu_ldst_indexed,
     fdep_fiss_t3_is2_axu_ldst_update        => fdep_fiss_t3_is2_axu_ldst_update,
     fdep_fiss_t3_is2_axu_ldst_extpid        => fdep_fiss_t3_is2_axu_ldst_extpid,
     fdep_fiss_t3_is2_axu_ldst_forcealign    => fdep_fiss_t3_is2_axu_ldst_forcealign,
     fdep_fiss_t3_is2_axu_ldst_forceexcept   => fdep_fiss_t3_is2_axu_ldst_forceexcept,
     fdep_fiss_t3_is2_axu_mftgpr        => fdep_fiss_t3_is2_axu_mftgpr,
     fdep_fiss_t3_is2_axu_mffgpr        => fdep_fiss_t3_is2_axu_mffgpr,
     fdep_fiss_t3_is2_axu_movedp        => fdep_fiss_t3_is2_axu_movedp,
     fdep_fiss_t3_is2_axu_instr_type    => fdep_fiss_t3_is2_axu_instr_type,
     fdep_fiss_t3_is2_match             => fdep_fiss_t3_is2_match,
     fdep_fiss_t3_is2_2ucode            => fdep_fiss_t3_is2_2ucode,
     fdep_fiss_t3_is2_2ucode_type       => fdep_fiss_t3_is2_2ucode_type,
     fdep_fiss_t3_is2_hole_delay        => fdep_fiss_t3_is2_hole_delay,
     fdep_fiss_t3_is2_to_ucode          => fdep_fiss_t3_is2_to_ucode,
     fdep_fiss_t3_is2_is_ucode          => fdep_fiss_t3_is2_is_ucode,
     fdep_fiss_t3_is2early_vld          => fdep_fiss_t3_is2early_vld,
     fdep_fiss_t3_is1_xu_dep_hit_b      => fdep_fiss_t3_is1_xu_dep_hit_b,
     fiss_fdep_is2_take0                => fiss_fdep_is2_take0,
     fiss_fdep_is2_take1                => fiss_fdep_is2_take1,
     fiss_fdep_is2_take2                => fiss_fdep_is2_take2,
     fiss_fdep_is2_take3                => fiss_fdep_is2_take3,
     spr_issue_high_mask                => spr_issue_high_mask,
     spr_issue_med_mask                 => spr_issue_med_mask,
     spr_fiss_count0_max                => spr_fiss_count0_max,
     spr_fiss_count1_max                => spr_fiss_count1_max,
     spr_fiss_count2_max                => spr_fiss_count2_max,
     spr_fiss_count3_max                => spr_fiss_count3_max,
     spr_fiss_pri_rand                  => spr_fiss_pri_rand,
     spr_fiss_pri_rand_always           => spr_fiss_pri_rand_always,
     spr_fiss_pri_rand_flush            => spr_fiss_pri_rand_flush,
     iu_au_hi_pri_mask                  => iu_au_hi_pri_mask,
     iu_au_md_pri_mask                  => iu_au_md_pri_mask,
     i_afi_is2_take_t                   => i_afi_is2_take_t,
     i_afd_is2_t0_instr_v               => i_afd_is2_t0_instr_v,
     i_afd_is2_t1_instr_v               => i_afd_is2_t1_instr_v,
     i_afd_is2_t2_instr_v               => i_afd_is2_t2_instr_v,
     i_afd_is2_t3_instr_v               => i_afd_is2_t3_instr_v,
     i_axu_is1_dep_hit_t0_b             => i_axu_is1_dep_hit_t0_b,
     i_axu_is1_dep_hit_t1_b             => i_axu_is1_dep_hit_t1_b,
     i_axu_is1_dep_hit_t2_b             => i_axu_is1_dep_hit_t2_b,
     i_axu_is1_dep_hit_t3_b             => i_axu_is1_dep_hit_t3_b,
     xu_iu_is2_flush_tid                => xu_iu_flush, 
     xu_iu_rf0_flush_tid                => xu_iu_flush,
     xu_iu_rf1_flush_tid                => xu_rf1_flush,
     xu_iu_ex1_flush_tid                => xu_ex1_flush,
     xu_iu_ex2_flush_tid                => xu_ex2_flush,
     xu_iu_ex3_flush_tid                => xu_ex3_flush,
     xu_iu_ex4_flush_tid                => xu_ex4_flush,
     xu_iu_ex5_flush_tid                => xu_ex5_flush,
     xu_iu_ex5_ppc_cpl                  => xu_iu_ex5_ppc_cpl,
     iu_xu_is2_vld                      => iu_xu_is2_vld_internal,
     iu_xu_is2_tid                      => iu_xu_is2_tid_internal,
     iu_xu_is2_instr                    => iu_xu_is2_instr_internal,
     iu_xu_is2_ta_vld                   => iu_xu_is2_ta_vld,
     iu_xu_is2_ta                       => iu_xu_is2_ta,
     iu_xu_is2_s1_vld                   => iu_xu_is2_s1_vld,
     iu_xu_is2_s1                       => iu_xu_is2_s1,
     iu_xu_is2_s2_vld                   => iu_xu_is2_s2_vld,
     iu_xu_is2_s2                       => iu_xu_is2_s2,
     iu_xu_is2_s3_vld                   => iu_xu_is2_s3_vld,
     iu_xu_is2_s3                       => iu_xu_is2_s3,
     iu_xu_is2_pred_update              => iu_xu_is2_pred_update_internal,
     iu_xu_is2_pred_taken_cnt           => iu_xu_is2_pred_taken_cnt_internal,
     iu_xu_is2_gshare                   => iu_xu_is2_gshare,
     iu_xu_is2_ifar                     => iu_xu_is2_ifar_internal,
     iu_xu_is2_error                    => iu_xu_is2_error_internal,
     iu_xu_is2_is_ucode                 => iu_xu_is2_is_ucode,  
     iu_xu_is2_match                    => iu_xu_is2_match,
     fiss_uc_is2_2ucode                 => fiss_uc_is2_2ucode,
     fiss_uc_is2_2ucode_type            => fiss_uc_is2_2ucode_type,
     iu_xu_is2_axu_ldst_update          => iu_xu_is2_axu_ldst_update,       
     iu_xu_is2_axu_ldst_extpid          => iu_xu_is2_axu_ldst_extpid,       
     iu_xu_is2_axu_ldst_forcealign      => iu_xu_is2_axu_ldst_forcealign,       
     iu_xu_is2_axu_ldst_forceexcept     => iu_xu_is2_axu_ldst_forceexcept,       
     iu_xu_is2_axu_mftgpr               => iu_xu_is2_axu_mftgpr,       
     iu_xu_is2_axu_mffgpr               => iu_xu_is2_axu_mffgpr,       
     iu_xu_is2_axu_movedp               => iu_xu_is2_axu_movedp,       
     iu_xu_is2_axu_instr_type           => iu_xu_is2_axu_instr_type,       
     iu_xu_is2_axu_ld_or_st             => iu_xu_is2_axu_ld_or_st,         
     iu_xu_is2_axu_store                => iu_xu_is2_axu_store_internal,            
     iu_xu_is2_axu_ldst_size            => iu_xu_is2_axu_ldst_size,       
     iu_xu_is2_axu_ldst_tag             => iu_xu_is2_axu_ldst_tag,         
     iu_xu_is2_axu_ldst_indexed         => iu_xu_is2_axu_ldst_indexed,
     iu_fu_rf0_str_val                  => iu_fu_rf0_str_val,
     iu_fu_rf0_ldst_val                 => iu_fu_rf0_ldst_val,
     iu_fu_rf0_ldst_tid                 => iu_fu_rf0_ldst_tid,
     iu_fu_rf0_ldst_tag                 => iu_fu_rf0_ldst_tag
);
iuq_axu_fu_iss0 : entity work.iuq_axu_fu_iss
generic map(expand_type                 => expand_type,
            fpr_addr_width              => fpr_addr_width)
port map(
    vdd                                 => vdd,
    gnd                                 => gnd,
    nclk                                => nclk,
    i_iss_si                           	=> iuq_ai_scan_in, 
    i_iss_so                           	=> iuq_ai_scan_out, 
    an_ac_scan_dis_dc_b                 => an_ac_scan_dis_dc_b(2),
    pc_iu_func_sl_thold_2               => pc_iu_func_sl_thold_2(2),    
    pc_iu_sg_2                          => pc_iu_sg_2(2),               
    clkoff_b                            => clkoff_b(2),                 
    tc_ac_ccflush_dc                    => tc_ac_ccflush_dc,
    delay_lclkr                         => delay_lclkr(14),
    mpw1_b                              => mpw1_b(14),
    iu_au_is1_flush                     => xu_iu_flush,
    xu_iu_is2_flush                     => xu_iu_flush,
    uc_flush                            => uc_flush_tid,
    i_afd_config_iucr_t0                => iu_au_config_iucr_pt_t0(2 to 4),
    i_afd_config_iucr_t1                => iu_au_config_iucr_pt_t1(2 to 4),
    i_afd_config_iucr_t2                => iu_au_config_iucr_pt_t2(2 to 4),
    i_afd_config_iucr_t3                => iu_au_config_iucr_pt_t3(2 to 4),
    i_afd_in_ucode_mode_or1d_b_t0       => i_afd_in_ucode_mode_or1d_b_t0,
    i_afd_in_ucode_mode_or1d_b_t1       => i_afd_in_ucode_mode_or1d_b_t1,
    i_afd_in_ucode_mode_or1d_b_t2       => i_afd_in_ucode_mode_or1d_b_t2,
    i_afd_in_ucode_mode_or1d_b_t3       => i_afd_in_ucode_mode_or1d_b_t3,
    i_axu_is2_instr_match_t0            => i_axu_is2_instr_match_t0,
    i_axu_is2_instr_match_t1            => i_axu_is2_instr_match_t1,
    i_axu_is2_instr_match_t2            => i_axu_is2_instr_match_t2,
    i_axu_is2_instr_match_t3            => i_axu_is2_instr_match_t3,
    i_afd_is2_is_ucode_t0               => i_afd_is2_is_ucode_t0,
    i_afd_is2_is_ucode_t1               => i_afd_is2_is_ucode_t1,
    i_afd_is2_is_ucode_t2               => i_afd_is2_is_ucode_t2,
    i_afd_is2_is_ucode_t3               => i_afd_is2_is_ucode_t3,
    i_afd_ignore_flush_is2_t0           => i_afd_ignore_flush_is2_t0,
    i_afd_ignore_flush_is2_t1           => i_afd_ignore_flush_is2_t1,
    i_afd_ignore_flush_is2_t2           => i_afd_ignore_flush_is2_t2,
    i_afd_ignore_flush_is2_t3           => i_afd_ignore_flush_is2_t3,
    i_afd_is2_t0_instr_v                => i_afd_is2_t0_instr_v,
    i_afd_is2_t1_instr_v                => i_afd_is2_t1_instr_v,
    i_afd_is2_t2_instr_v                => i_afd_is2_t2_instr_v,
    i_afd_is2_t3_instr_v                => i_afd_is2_t3_instr_v,
    i_axu_is1_early_v_t0                => i_axu_is1_early_v_t0,
    i_axu_is1_early_v_t1                => i_axu_is1_early_v_t1,
    i_axu_is1_early_v_t2                => i_axu_is1_early_v_t2,
    i_axu_is1_early_v_t3                => i_axu_is1_early_v_t3,
    i_afd_is2_t0_instr                  => fdep_fiss_t0_is2_instr,
    i_afd_is2_t1_instr                  => fdep_fiss_t1_is2_instr,
    i_afd_is2_t2_instr                  => fdep_fiss_t2_is2_instr,
    i_afd_is2_t3_instr                  => fdep_fiss_t3_is2_instr,
    i_afd_is2_fra_t0                    => i_afd_is2_fra_t0,
    i_afd_is2_fra_t1                    => i_afd_is2_fra_t1,
    i_afd_is2_fra_t2                    => i_afd_is2_fra_t2,
    i_afd_is2_fra_t3                    => i_afd_is2_fra_t3,
    i_afd_is2_frb_t0                    => i_afd_is2_frb_t0,
    i_afd_is2_frb_t1                    => i_afd_is2_frb_t1,
    i_afd_is2_frb_t2                    => i_afd_is2_frb_t2,
    i_afd_is2_frb_t3                    => i_afd_is2_frb_t3,
    i_afd_is2_frc_t0                    => i_afd_is2_frc_t0,
    i_afd_is2_frc_t1                    => i_afd_is2_frc_t1,
    i_afd_is2_frc_t2                    => i_afd_is2_frc_t2,
    i_afd_is2_frc_t3                    => i_afd_is2_frc_t3,
    i_afd_is2_frt_t0                    => i_afd_is2_frt_t0,
    i_afd_is2_frt_t1                    => i_afd_is2_frt_t1,
    i_afd_is2_frt_t2                    => i_afd_is2_frt_t2,
    i_afd_is2_frt_t3                    => i_afd_is2_frt_t3,
    i_afd_is2_fra_v_t0                  => i_afd_is2_fra_v_t0,
    i_afd_is2_fra_v_t1                  => i_afd_is2_fra_v_t1,
    i_afd_is2_fra_v_t2                  => i_afd_is2_fra_v_t2,
    i_afd_is2_fra_v_t3                  => i_afd_is2_fra_v_t3,
    i_afd_is2_frb_v_t0                  => i_afd_is2_frb_v_t0,
    i_afd_is2_frb_v_t1                  => i_afd_is2_frb_v_t1,
    i_afd_is2_frb_v_t2                  => i_afd_is2_frb_v_t2,
    i_afd_is2_frb_v_t3                  => i_afd_is2_frb_v_t3,
    i_afd_is2_frc_v_t0                  => i_afd_is2_frc_v_t0,
    i_afd_is2_frc_v_t1                  => i_afd_is2_frc_v_t1,
    i_afd_is2_frc_v_t2                  => i_afd_is2_frc_v_t2,
    i_afd_is2_frc_v_t3                  => i_afd_is2_frc_v_t3,
    i_afd_is2_bypsel_t0                 => i_afd_is2_bypsel_t0, 
    i_afd_is2_bypsel_t1                 => i_afd_is2_bypsel_t1, 
    i_afd_is2_bypsel_t2                 => i_afd_is2_bypsel_t2, 
    i_afd_is2_bypsel_t3                 => i_afd_is2_bypsel_t3, 
    i_afd_is2_ifar_t0                   => fdep_fiss_t0_is2_ifar,
    i_afd_is2_ifar_t1                   => fdep_fiss_t1_is2_ifar,
    i_afd_is2_ifar_t2                   => fdep_fiss_t2_is2_ifar,
    i_afd_is2_ifar_t3                   => fdep_fiss_t3_is2_ifar,
    ifdp_is2_est_bubble3_t0             => ifdp_is2_est_bubble3_t0,
    ifdp_is2_est_bubble3_t1             => ifdp_is2_est_bubble3_t1,
    ifdp_is2_est_bubble3_t2             => ifdp_is2_est_bubble3_t2,
    ifdp_is2_est_bubble3_t3             => ifdp_is2_est_bubble3_t3,
    iu_au_hi_pri_mask                   => iu_au_hi_pri_mask,
    iu_au_md_pri_mask                   => iu_au_md_pri_mask,
    spr_fiss_pri_rand                   => spr_fiss_pri_rand,
    spr_fiss_pri_rand_always            => spr_fiss_pri_rand_always,
    spr_fiss_pri_rand_flush             => spr_fiss_pri_rand_flush,	 
    iu_is2_take_t                       => i_afi_is2_take_t,
    i_axu_is1_dep_hit_t0_b              => i_axu_is1_dep_hit_t0_b,
    i_axu_is1_dep_hit_t1_b              => i_axu_is1_dep_hit_t1_b,
    i_axu_is1_dep_hit_t2_b              => i_axu_is1_dep_hit_t2_b,
    i_axu_is1_dep_hit_t3_b              => i_axu_is1_dep_hit_t3_b,
    iu_fu_is2_tid_decode                => iu_fu_is2_tid_decode,
    iu_fu_rf0_ucfmul                    => iu_fu_rf0_ucfmul,
    iu_fu_rf0_instr_match               => iu_fu_rf0_instr_match,
    iu_fu_rf0_is_ucode                  => iu_fu_rf0_is_ucode,
    iu_fu_rf0_instr                     => iu_fu_rf0_instr,
    iu_fu_rf0_instr_v                   => iu_fu_rf0_instr_v,
    iu_fu_rf0_fra                       => iu_fu_rf0_fra,
    iu_fu_rf0_frb                       => iu_fu_rf0_frb,
    iu_fu_rf0_frc                       => iu_fu_rf0_frc,
    iu_fu_rf0_frt                       => iu_fu_rf0_frt,
    iu_fu_rf0_fra_v                     => iu_fu_rf0_fra_v,
    iu_fu_rf0_frb_v                     => iu_fu_rf0_frb_v,
    iu_fu_rf0_frc_v                     => iu_fu_rf0_frc_v,
    iu_fu_rf0_tid                       => iu_fu_rf0_tid,
    iu_fu_rf0_bypsel                    => iu_fu_rf0_bypsel,
    iu_fu_rf0_ifar                      => iu_fu_rf0_ifar,
    fu_iss_debug                        => fu_iss_dbg_data	 
);
end iuq_slice_wrap;
