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
--* TITLE: Instruction Unit
--*
--* NAME: iuq.vhdl
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

entity iuq is
  generic(expand_type           : integer := 2;
          a2mode                : integer := 1;
          lmq_entries           : integer := 8;
          fpr_addr_width        : integer := 5;
          regmode               : integer := 6;
          threads               : integer := 4;
          ucode_mode            : integer := 1;
          bcfg_epn_0to15        : integer := 0;
          bcfg_epn_16to31       : integer := 0;
          bcfg_epn_32to47       : integer := (2**16)-1;  
          bcfg_epn_48to51       : integer := (2**4)-1; 
          bcfg_rpn_22to31       : integer := (2**10)-1;
          bcfg_rpn_32to47       : integer := (2**16)-1;  
          bcfg_rpn_48to51       : integer := (2**4)-1; 
          uc_ifar               : integer := 21);
port(
     vcs                        : inout power_logic;
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in  clk_logic;

     tc_ac_ccflush_dc           : in  std_ulogic;
     an_ac_scan_dis_dc_b        : in  std_ulogic;
     an_ac_scan_diag_dc         : in  std_ulogic;

     pc_iu_gptr_sl_thold_4      : in  std_ulogic;
     pc_iu_time_sl_thold_4      : in  std_ulogic;
     pc_iu_repr_sl_thold_4      : in  std_ulogic;
     pc_iu_abst_sl_thold_4      : in  std_ulogic;
     pc_iu_abst_slp_sl_thold_4  : in  std_ulogic;
     pc_iu_bolt_sl_thold_4      : in  std_ulogic;
     pc_iu_regf_slp_sl_thold_4  : in  std_ulogic;
     pc_iu_func_sl_thold_4      : in  std_ulogic;
     pc_iu_func_slp_sl_thold_4  : in  std_ulogic;
     pc_iu_cfg_sl_thold_4       : in  std_ulogic;
     pc_iu_cfg_slp_sl_thold_4   : in  std_ulogic;
     pc_iu_func_nsl_thold_4     : in  std_ulogic;
     pc_iu_func_slp_nsl_thold_4 : in  std_ulogic;
     pc_iu_ary_nsl_thold_4      : in  std_ulogic;
     pc_iu_ary_slp_nsl_thold_4  : in  std_ulogic;
     pc_iu_sg_4                 : in  std_ulogic;
     pc_iu_fce_4                : in  std_ulogic;

     pc_iu_abist_dcomp_g6t_2r   : in  std_ulogic_vector(0 to 3);
     pc_iu_abist_di_0           : in  std_ulogic_vector(0 to 3);
     pc_iu_abist_di_g6t_2r      : in  std_ulogic_vector(0 to 3);
     pc_iu_abist_ena_dc         : in  std_ulogic;
     pc_iu_abist_g6t_bw         : in  std_ulogic_vector(0 to 1);
     pc_iu_abist_g6t_r_wb       : in  std_ulogic;
     pc_iu_abist_g8t1p_renb_0   : in  std_ulogic;
     pc_iu_abist_g8t_bw_0       : in  std_ulogic;
     pc_iu_abist_g8t_bw_1       : in  std_ulogic;
     pc_iu_abist_g8t_dcomp      : in  std_ulogic_vector(0 to 3);
     pc_iu_abist_g8t_wenb       : in  std_ulogic;
     pc_iu_abist_raddr_0        : in  std_ulogic_vector(0 to 9);
     pc_iu_abist_raw_dc_b       : in  std_ulogic;
     pc_iu_abist_waddr_0        : in  std_ulogic_vector(0 to 9);
     pc_iu_abist_wl256_comp_ena : in  std_ulogic;
     pc_iu_abist_wl64_comp_ena  : in  std_ulogic;
     pc_iu_abist_wl128_comp_ena : in  std_ulogic;
     an_ac_lbist_ary_wrt_thru_dc: in  std_ulogic;
     an_ac_lbist_en_dc          : in  std_ulogic;
     an_ac_atpg_en_dc           : in  std_ulogic;
     an_ac_grffence_en_dc       : in  std_ulogic;

     pc_iu_bo_enable_4          : in std_ulogic; 
     pc_iu_bo_reset             : in std_ulogic;
     pc_iu_bo_unload            : in std_ulogic;
     pc_iu_bo_repair            : in std_ulogic;
     pc_iu_bo_shdata            : in std_ulogic;
     pc_iu_bo_select            : in std_ulogic_vector(0 to 4);
     iu_pc_bo_fail              : out std_ulogic_vector(0 to 4);
     iu_pc_bo_diagout           : out std_ulogic_vector(0 to 4);


     iu_pc_err_icache_parity    : out std_ulogic;
     iu_pc_err_icachedir_parity : out std_ulogic;
     iu_pc_err_icachedir_multihit : out std_ulogic;

     iu_pc_err_ucode_illegal    : out std_ulogic_vector(0 to 3);

     pc_iu_inj_icache_parity    : in  std_ulogic;
     pc_iu_inj_icachedir_parity : in  std_ulogic;
     pc_iu_inj_icachedir_multihit : in  std_ulogic;

     pc_iu_trace_bus_enable     : in  std_ulogic;
     pc_iu_debug_mux1_ctrls     : in  std_ulogic_vector(0 to 15);
     pc_iu_debug_mux2_ctrls     : in  std_ulogic_vector(0 to 15);
     debug_data_in              : in  std_ulogic_vector(0 to 87);
     trace_triggers_in          : in  std_ulogic_vector(0 to 11);
     debug_data_out             : out std_ulogic_vector(0 to 87);
     trace_triggers_out         : out std_ulogic_vector(0 to 11);
     pc_iu_event_mux_ctrls      : in  std_ulogic_vector(0 to 47);
     pc_iu_event_count_mode     : in  std_ulogic_vector(0 to 2);
     pc_iu_event_bus_enable     : in  std_ulogic;
     iu_pc_event_data           : out std_ulogic_vector(0 to 7);

     pc_iu_init_reset           : in  std_ulogic;

     gptr_scan_in               : in  std_ulogic;
     time_scan_in               : in  std_ulogic;
     repr_scan_in               : in  std_ulogic;
     abst_scan_in               : in  std_ulogic_vector(0 to 2);
     func_scan_in               : in  std_ulogic_vector(0 to 13);
     ccfg_scan_in               : in  std_ulogic;
     bcfg_scan_in               : in  std_ulogic;
     dcfg_scan_in               : in  std_ulogic;
     regf_scan_in               : in  std_ulogic_vector(0 to 4);

     gptr_scan_out              : out std_ulogic;
     time_scan_out              : out std_ulogic;
     repr_scan_out              : out std_ulogic;
     abst_scan_out              : out std_ulogic_vector(0 to 2);
     func_scan_out              : out std_ulogic_vector(0 to 13);
     ccfg_scan_out              : out std_ulogic;
     bcfg_scan_out              : out std_ulogic;
     dcfg_scan_out              : out std_ulogic;
     regf_scan_out              : out std_ulogic_vector(0 to 4);

     slowspr_val_in             : in  std_ulogic;
     slowspr_rw_in              : in  std_ulogic;
     slowspr_etid_in            : in  std_ulogic_vector(0 to 1);
     slowspr_addr_in            : in  std_ulogic_vector(0 to 9);
     slowspr_data_in            : in  std_ulogic_vector(64-(2**regmode) to 63);
     slowspr_done_in            : in  std_ulogic;

     slowspr_val_out            : out std_ulogic;
     slowspr_rw_out             : out std_ulogic;
     slowspr_etid_out           : out std_ulogic_vector(0 to 1);
     slowspr_addr_out           : out std_ulogic_vector(0 to 9);
     slowspr_data_out           : out std_ulogic_vector(64-(2**regmode) to 63);
     slowspr_done_out           : out std_ulogic;

     xu_iu_run_thread           : in  std_ulogic_vector(0 to 3);
     xu_iu_l_flush              : in  std_ulogic_vector(0 to 3);
     xu_iu_u_flush              : in  std_ulogic_vector(0 to 3);
     xu_iu_iu0_flush_ifar0      : in  EFF_IFAR;
     xu_iu_iu0_flush_ifar1      : in  EFF_IFAR;
     xu_iu_iu0_flush_ifar2      : in  EFF_IFAR;
     xu_iu_iu0_flush_ifar3      : in  EFF_IFAR;
     xu_iu_flush_2ucode         : in  std_ulogic_vector(0 to 3);
     xu_iu_flush_2ucode_type    : in  std_ulogic_vector(0 to 3);
     xu_iu_membar_tid           : in  std_ulogic_vector(0 to 3);
     xu_iu_set_barr_tid         : in  std_ulogic_vector(0 to 3);
     xu_iu_larx_done_tid        : in  std_ulogic_vector(0 to 3);
     xu_iu_msr_cm               : in  std_ulogic_vector(0 to threads-1);
     xu_iu_ex6_icbi_val         : in  std_ulogic_vector(0 to threads-1);
     xu_iu_ex6_icbi_addr        : in  std_ulogic_vector(REAL_IFAR'left to 57);
     xu_iu_ici                  : in  std_ulogic;
     iu_xu_request              : out std_ulogic;
     iu_xu_thread               : out std_ulogic_vector(0 to 3);
     iu_xu_ra                   : out std_ulogic_vector(REAL_IFAR'left to 59);
     iu_xu_wimge                : out std_ulogic_vector(0 to 4);
     iu_xu_userdef              : out std_ulogic_vector(0 to 3);

     an_ac_reld_data_vld        : in  std_ulogic;
     an_ac_reld_data_vld_clone  : in  std_ulogic;
     an_ac_reld_ditc_clone      : in  std_ulogic;
     an_ac_reld_data_coming_clone: in  std_ulogic;
     an_ac_reld_core_tag        : in  std_ulogic_vector(0 to 4);
     an_ac_reld_core_tag_clone  : in  std_ulogic_vector(1 to 4);
     an_ac_reld_qw              : in  std_ulogic_vector(57 to 59);
     an_ac_reld_data            : in  std_ulogic_vector(0 to 127);
     an_ac_reld_ecc_err         : in  std_ulogic;
     an_ac_reld_ecc_err_ue      : in  std_ulogic;
     an_ac_back_inv             : in  std_ulogic;
     an_ac_back_inv_addr        : in  std_ulogic_vector(REAL_IFAR'left to 63);
     an_ac_back_inv_target_iiu_a: in  std_ulogic_vector(0 to 1);
     an_ac_back_inv_target_iiu_b: in  std_ulogic_vector(3 to 4);
     an_ac_sync_ack             : in  std_ulogic_vector(0 to 3);
     an_ac_stcx_complete        : in  std_ulogic_vector(0 to 3);
     an_ac_icbi_ack             : in  std_ulogic;
     an_ac_icbi_ack_thread      : in  std_ulogic_vector(0 to 1);

     iu_mm_ierat_req            : out std_ulogic;
     iu_mm_ierat_epn            : out std_ulogic_vector(0 to 51);
     iu_mm_ierat_thdid          : out std_ulogic_vector(0 to 3);
     iu_mm_ierat_state          : out std_ulogic_vector(0 to 3);
     iu_mm_ierat_tid            : out std_ulogic_vector(0 to 13);
     iu_mm_ierat_flush          : out std_ulogic_vector(0 to 3);
     mm_iu_ierat_rel_val        : in  std_ulogic_vector(0 to 4);
     mm_iu_ierat_rel_data       : in  std_ulogic_vector(0 to 131);
     mm_iu_ierat_snoop_coming   : in  std_ulogic;
     mm_iu_ierat_snoop_val      : in  std_ulogic;
     mm_iu_ierat_snoop_attr     : in  std_ulogic_vector(0 to 25);
     mm_iu_ierat_snoop_vpn      : in  std_ulogic_vector(EFF_IFAR'left to 51);
     iu_mm_ierat_snoop_ack      : out std_ulogic;
     mm_iu_ierat_pid0           : in std_ulogic_vector(0 to 13);
     mm_iu_ierat_pid1           : in std_ulogic_vector(0 to 13);
     mm_iu_ierat_pid2           : in std_ulogic_vector(0 to 13);
     mm_iu_ierat_pid3           : in std_ulogic_vector(0 to 13);
     mm_iu_ierat_mmucr0_0       : in std_ulogic_vector(0 to 19);
     mm_iu_ierat_mmucr0_1       : in std_ulogic_vector(0 to 19);
     mm_iu_ierat_mmucr0_2       : in std_ulogic_vector(0 to 19);
     mm_iu_ierat_mmucr0_3       : in std_ulogic_vector(0 to 19);
     iu_mm_ierat_mmucr0         : out std_ulogic_vector(0 to 17);
     iu_mm_ierat_mmucr0_we      : out std_ulogic_vector(0 to 3);
     mm_iu_ierat_mmucr1         : in std_ulogic_vector(0 to 8);
     iu_mm_ierat_mmucr1         : out std_ulogic_vector(0 to 3);
     iu_mm_ierat_mmucr1_we      : out std_ulogic;
     mm_iu_barrier_done         : in  std_ulogic_vector(0 to 3);
     iu_mm_lmq_empty            : out std_ulogic;

     xu_iu_ex1_rb               : in  std_ulogic_vector(64-(2**regmode) to 51);
     xu_wl_rf1_flush            : in  std_ulogic_vector(0 to 3);
     xu_wl_ex1_flush            : in  std_ulogic_vector(0 to 3);
     xu_wl_ex2_flush            : in  std_ulogic_vector(0 to 3);
     xu_wl_ex3_flush            : in  std_ulogic_vector(0 to 3);
     xu_wl_ex4_flush            : in  std_ulogic_vector(0 to 3);
     xu_wl_ex5_flush            : in  std_ulogic_vector(0 to 3);
     xu_wu_rf1_flush            : in  std_ulogic_vector(0 to 3);
     xu_wu_ex1_flush            : in  std_ulogic_vector(0 to 3);
     xu_wu_ex2_flush            : in  std_ulogic_vector(0 to 3);
     xu_wu_ex3_flush            : in  std_ulogic_vector(0 to 3);
     xu_wu_ex4_flush            : in  std_ulogic_vector(0 to 3);
     xu_wu_ex5_flush            : in  std_ulogic_vector(0 to 3);
     xu_iu_ex4_rs_data          : in  std_ulogic_vector(64-(2**regmode) to 63);
     xu_iu_hid_mmu_mode         : in  std_ulogic;
     xu_iu_msr_hv               : in  std_ulogic_vector(0 to threads-1);
     xu_iu_msr_is               : in  std_ulogic_vector(0 to threads-1);
     xu_iu_msr_pr               : in  std_ulogic_vector(0 to threads-1);
     xu_iu_spr_ccr2_ifratsc     : in  std_ulogic_vector(0 to 8);
     xu_iu_spr_ccr2_ifrat       : in  std_ulogic;
     xu_iu_xucr4_mmu_mchk       : in  std_ulogic;
     xu_iu_rf1_val              : in  std_ulogic_vector(0 to 3);
     xu_iu_rf1_is_eratre        : in  std_ulogic;
     xu_iu_rf1_is_eratsx        : in  std_ulogic;
     xu_iu_rf1_is_eratwe        : in  std_ulogic;
     xu_iu_rf1_is_eratilx       : in  std_ulogic;
     xu_iu_ex1_is_isync         : in  std_ulogic;
     xu_iu_ex1_is_csync         : in  std_ulogic;
     xu_iu_rf1_ws               : in  std_ulogic_vector(0 to 1);
     xu_iu_rf1_t                : in  std_ulogic_vector(0 to 2);
     xu_iu_ex1_ra_entry         : in  std_ulogic_vector(8 to 11);
     xu_iu_ex1_rs_is            : in  std_ulogic_vector(0 to 8);
     iu_xu_ex4_tlb_data         : out std_ulogic_vector(64-(2**regmode) to 63);
     iu_xu_ierat_ex3_par_err    : out std_ulogic_vector(0 to threads-1);
     iu_xu_ierat_ex4_par_err    : out std_ulogic_vector(0 to threads-1);
     iu_xu_ierat_ex2_flush_req  : out std_ulogic_vector(0 to threads-1);

     xu_iu_ex5_ifar             : in  EFF_IFAR;
     xu_iu_ex5_tid              : in  std_ulogic_vector(0 to 3);
     xu_iu_ex5_val              : in  std_ulogic;
     xu_iu_ex5_br_update        : in  std_ulogic;
     xu_iu_ex5_br_hist          : in  std_ulogic_vector(0 to 1);
     xu_iu_ex5_br_taken         : in  std_ulogic;
     xu_iu_ex5_bclr             : in  std_ulogic;
     xu_iu_ex5_getNIA           : in  std_ulogic;
     xu_iu_ex5_lk               : in  std_ulogic;
     xu_iu_ex5_bh               : in  std_ulogic_vector(0 to 1);
     xu_iu_ex5_gshare           : in  std_ulogic_vector(0 to 3);

     pc_iu_ram_instr            : in  std_ulogic_vector(0 to 31);
     pc_iu_ram_instr_ext        : in  std_ulogic_vector(0 to 3);
     pc_iu_ram_force_cmplt      : in  std_ulogic;
     pc_iu_ram_mode             : in  std_ulogic;
     pc_iu_ram_thread           : in  std_ulogic_vector(0 to 1);
     xu_iu_ram_issue            : in  std_ulogic_vector(0 to 3);

     xu_iu_ex6_pri              : in std_ulogic_vector(0 to 2);
     xu_iu_ex6_pri_val          : in std_ulogic_vector(0 to 3);
     xu_iu_raise_iss_pri        : in std_ulogic_vector(0 to 3);
     xu_iu_msr_gs               : in std_ulogic_vector(0 to 3);

     xu_iu_ucode_restart        : in std_ulogic_vector(0 to 3);
     xu_iu_spr_xer0             : in std_ulogic_vector(57 to 63);
     xu_iu_spr_xer1             : in std_ulogic_vector(57 to 63);
     xu_iu_spr_xer2             : in std_ulogic_vector(57 to 63);
     xu_iu_spr_xer3             : in std_ulogic_vector(57 to 63);
     xu_iu_uc_flush_ifar0       : in std_ulogic_vector(62-uc_ifar to 61);
     xu_iu_uc_flush_ifar1       : in std_ulogic_vector(62-uc_ifar to 61);
     xu_iu_uc_flush_ifar2       : in std_ulogic_vector(62-uc_ifar to 61);
     xu_iu_uc_flush_ifar3       : in std_ulogic_vector(62-uc_ifar to 61);

     xu_iu_slowspr_done         : in  std_ulogic_vector(0 to 3);

     xu_iu_ex4_loadmiss_tid         : in  std_ulogic_vector(0 to 3);
     xu_iu_ex4_loadmiss_qentry      : in  std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_ex4_loadmiss_target      : in  std_ulogic_vector(0 to 8);
     xu_iu_ex4_loadmiss_target_type : in  std_ulogic_vector(0 to 1);
     xu_iu_ex5_loadmiss_tid         : in  std_ulogic_vector(0 to 3);
     xu_iu_ex5_loadmiss_qentry      : in  std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_ex5_loadmiss_target      : in  std_ulogic_vector(0 to 8);
     xu_iu_ex5_loadmiss_target_type : in  std_ulogic_vector(0 to 1);

     xu_iu_complete_tid         : in  std_ulogic_vector(0 to 3);
     xu_iu_complete_qentry      : in  std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_complete_target_type : in  std_ulogic_vector(0 to 1);
     iu_xu_quiesce              : out std_ulogic_vector(0 to 3);
     xu_iu_single_instr_mode    : in  std_ulogic_vector(0 to 3);
     xu_iu_need_hole            : in  std_ulogic;
     xu_iu_xucr0_rel            : in  std_ulogic;
     xu_iu_spr_ccr2_en_dcr      : in  std_ulogic;

     xu_iu_ex5_ppc_cpl          : in std_ulogic_vector(0 to 3);
     xu_iu_multdiv_done         : in std_ulogic_vector(0 to 3);
     iu_xu_is2_ucode_vld        : out std_ulogic;
     iu_xu_is2_vld              : out std_ulogic;
     iu_xu_is2_tid              : out std_ulogic_vector(0 to 3);
     iu_xu_is2_instr            : out std_ulogic_vector(0 to 31);
     iu_xu_is2_ta_vld           : out std_ulogic;
     iu_xu_is2_ta               : out std_ulogic_vector(0 to 5);
     iu_xu_is2_s1_vld           : out std_ulogic;
     iu_xu_is2_s1               : out std_ulogic_vector(0 to 5);
     iu_xu_is2_s2_vld           : out std_ulogic;
     iu_xu_is2_s2               : out std_ulogic_vector(0 to 5);
     iu_xu_is2_s3_vld           : out std_ulogic;
     iu_xu_is2_s3               : out std_ulogic_vector(0 to 5);
     iu_xu_is2_pred_update      : out std_ulogic;
     iu_xu_is2_pred_taken_cnt   : out std_ulogic_vector(0 to 1);
     iu_xu_is2_gshare           : out std_ulogic_vector(0 to 3);
     iu_xu_is2_ifar             : out eff_ifar;
     iu_xu_is2_axu_ld_or_st     : out std_ulogic;                       
     iu_xu_is2_axu_store        : out std_ulogic;                       
     iu_xu_is2_axu_ldst_size    : out std_ulogic_vector(0 to 5);        
     iu_xu_is2_axu_ldst_tag     : out std_ulogic_vector(0 to 8);        
     iu_xu_is2_axu_ldst_indexed : out std_ulogic;
     iu_xu_is2_axu_ldst_update      : out std_ulogic;                       
     iu_xu_is2_axu_ldst_extpid      : out std_ulogic;                       
     iu_xu_is2_axu_ldst_forcealign  : out std_ulogic;                       
     iu_xu_is2_axu_ldst_forceexcept  : out std_ulogic;                       
     iu_xu_is2_axu_mftgpr        : out std_ulogic;                       
     iu_xu_is2_axu_mffgpr        : out std_ulogic;                       
     iu_xu_is2_axu_movedp        : out std_ulogic;                       
     iu_xu_is2_axu_instr_type        : out std_ulogic_vector(0 to 2);                       
     iu_xu_is2_error            : out std_ulogic_vector(0 to 2);
     iu_xu_is2_is_ucode         : out std_ulogic;
     iu_xu_is2_match            : out std_ulogic;

     iu_fu_is2_tid_decode       : out std_ulogic_vector(0 to 3);
     iu_fu_rf0_ucfmul           : out std_ulogic;
     iu_fu_rf0_instr            : out std_ulogic_vector(0 to 31);
     iu_fu_rf0_instr_v          : out std_ulogic;
     iu_fu_rf0_instr_match      : out std_ulogic;
     iu_fu_rf0_is_ucode         : out std_ulogic;
     iu_fu_rf0_fra              : out std_ulogic_vector(0 to 6);
     iu_fu_rf0_frb              : out std_ulogic_vector(0 to 6);
     iu_fu_rf0_frc              : out std_ulogic_vector(0 to 6);
     iu_fu_rf0_frt              : out std_ulogic_vector(0 to 6);
     iu_fu_rf0_fra_v            : out std_ulogic;
     iu_fu_rf0_frb_v            : out std_ulogic;
     iu_fu_rf0_frc_v            : out std_ulogic;
     iu_fu_rf0_tid              : out std_ulogic_vector(0 to 1);
     iu_fu_rf0_bypsel           : out std_ulogic_vector(0 to 5);
     iu_fu_rf0_ifar             : out EFF_IFAR;
     iu_fu_rf0_str_val          : out std_ulogic;
     iu_fu_rf0_ldst_val         : out std_ulogic;
     iu_fu_rf0_ldst_tid         : out std_ulogic_vector(0 to 1);
     iu_fu_rf0_ldst_tag         : out std_ulogic_vector(0 to 8);                       

     fu_iu_uc_special           : in  std_ulogic_vector(0 to 3);
     iu_fu_ex2_n_flush          : out std_ulogic_vector(0 to 3);

     rtim_sl_thold_7            : in  std_ulogic;
     func_sl_thold_7            : in  std_ulogic;
     func_nsl_thold_7           : in  std_ulogic;
     ary_nsl_thold_7            : in  std_ulogic;
     sg_7                       : in  std_ulogic;
     fce_7                      : in  std_ulogic;
     rtim_sl_thold_6            : out std_ulogic;
     func_sl_thold_6            : out std_ulogic;
     func_nsl_thold_6           : out std_ulogic;
     ary_nsl_thold_6            : out std_ulogic;
     sg_6                       : out std_ulogic;
     fce_6                      : out std_ulogic;
     an_ac_scom_dch             : in  std_ulogic;
     an_ac_scom_cch             : in  std_ulogic;
     an_ac_checkstop            : in  std_ulogic;
     an_ac_debug_stop           : in  std_ulogic;
     an_ac_pm_thread_stop       : in  std_ulogic_vector(0 to 3);
     an_ac_reset_1_complete     : in  std_ulogic;
     an_ac_reset_2_complete     : in  std_ulogic;
     an_ac_reset_3_complete     : in  std_ulogic;
     an_ac_reset_wd_complete    : in  std_ulogic;
     an_ac_abist_start_test     : in  std_ulogic;
     ac_rp_trace_to_perfcntr    : in  std_ulogic_vector(0 to 7);
     rp_pc_scom_dch_q           : out std_ulogic;
     rp_pc_scom_cch_q           : out std_ulogic;
     rp_pc_checkstop_q          : out std_ulogic;
     rp_pc_debug_stop_q         : out std_ulogic;
     rp_pc_pm_thread_stop_q     : out std_ulogic_vector(0 to 3);
     rp_pc_reset_1_complete_q   : out std_ulogic;
     rp_pc_reset_2_complete_q   : out std_ulogic;
     rp_pc_reset_3_complete_q   : out std_ulogic;
     rp_pc_reset_wd_complete_q  : out std_ulogic;
     rp_pc_abist_start_test_q   : out std_ulogic;
     rp_pc_trace_to_perfcntr_q  : out std_ulogic_vector(0 to 7);
     pc_rp_scom_dch             : in  std_ulogic;
     pc_rp_scom_cch             : in  std_ulogic;
     pc_rp_special_attn         : in  std_ulogic_vector(0 to 3);
     pc_rp_checkstop            : in  std_ulogic_vector(0 to 2);
     pc_rp_local_checkstop      : in  std_ulogic_vector(0 to 2);
     pc_rp_recov_err            : in  std_ulogic_vector(0 to 2);
     pc_rp_trace_error          : in  std_ulogic;
     pc_rp_event_bus_enable     : in  std_ulogic;
     pc_rp_event_bus            : in  std_ulogic_vector(0 to 7);
     pc_rp_fu_bypass_events     : in  std_ulogic_vector(0 to 7);
     pc_rp_iu_bypass_events     : in  std_ulogic_vector(0 to 7);
     pc_rp_mm_bypass_events     : in  std_ulogic_vector(0 to 7);
     pc_rp_lsu_bypass_events    : in  std_ulogic_vector(0 to 7);
     pc_rp_pm_thread_running    : in  std_ulogic_vector(0 to 3);
     pc_rp_power_managed        : in  std_ulogic;
     pc_rp_rvwinkle_mode        : in  std_ulogic;
     ac_an_scom_dch_q           : out std_ulogic;
     ac_an_scom_cch_q           : out std_ulogic;
     ac_an_special_attn_q       : out std_ulogic_vector(0 to 3);
     ac_an_checkstop_q          : out std_ulogic_vector(0 to 2);
     ac_an_local_checkstop_q    : out std_ulogic_vector(0 to 2);
     ac_an_recov_err_q          : out std_ulogic_vector(0 to 2);
     ac_an_trace_error_q        : out std_ulogic;
     rp_mm_event_bus_enable_q   : out std_ulogic;
     ac_an_event_bus_q          : out std_ulogic_vector(0 to 7);
     ac_an_fu_bypass_events_q   : out std_ulogic_vector(0 to 7);
     ac_an_iu_bypass_events_q   : out std_ulogic_vector(0 to 7);
     ac_an_mm_bypass_events_q   : out std_ulogic_vector(0 to 7);
     ac_an_lsu_bypass_events_q  : out std_ulogic_vector(0 to 7);
     ac_an_pm_thread_running_q  : out std_ulogic_vector(0 to 3);
     ac_an_power_managed_q      : out std_ulogic;
     ac_an_rvwinkle_mode_q      : out std_ulogic;

     pc_func_scan_in            : in  std_ulogic_vector(0 to 1);
     pc_func_scan_in_q          : out std_ulogic_vector(0 to 1);
     pc_func_scan_out           : in  std_ulogic;
     pc_func_scan_out_q         : out std_ulogic;
     pc_bcfg_scan_in            : in  std_ulogic; 
     pc_bcfg_scan_in_q          : out std_ulogic;
     pc_dcfg_scan_in            : in  std_ulogic; 
     pc_dcfg_scan_in_q          : out std_ulogic;
     pc_bcfg_scan_out           : in  std_ulogic;
     pc_bcfg_scan_out_q         : out std_ulogic;
     pc_ccfg_scan_out           : in  std_ulogic;
     pc_ccfg_scan_out_q         : out std_ulogic;
     pc_dcfg_scan_out           : in  std_ulogic;
     pc_dcfg_scan_out_q         : out std_ulogic;
     fu_abst_scan_in            : in  std_ulogic;
     fu_abst_scan_in_q          : out std_ulogic;
     fu_abst_scan_out           : in  std_ulogic;
     fu_abst_scan_out_q         : out std_ulogic;
     fu_ccfg_scan_out           : in  std_ulogic;
     fu_ccfg_scan_out_q         : out std_ulogic;
     fu_bcfg_scan_out           : in  std_ulogic;
     fu_bcfg_scan_out_q         : out std_ulogic;
     fu_dcfg_scan_out           : in  std_ulogic;
     fu_dcfg_scan_out_q         : out std_ulogic;
     fu_func_scan_in            : in  std_ulogic_vector(0 to 3);
     fu_func_scan_in_q          : out std_ulogic_vector(0 to 3);
     fu_func_scan_out           : in  std_ulogic_vector(0 to 3);
     fu_func_scan_out_q         : out std_ulogic_vector(0 to 3);
     bx_abst_scan_in            : in  std_ulogic;
     bx_abst_scan_in_q          : out std_ulogic;
     bx_abst_scan_out           : in  std_ulogic;
     bx_abst_scan_out_q         : out std_ulogic;
     bx_func_scan_in            : in  std_ulogic_vector(0 to 1);
     bx_func_scan_in_q          : out std_ulogic_vector(0 to 1);
     bx_func_scan_out           : in  std_ulogic_vector(0 to 1);
     bx_func_scan_out_q         : out std_ulogic_vector(0 to 1);
     spare_func_scan_in         : in  std_ulogic_vector(0 to 3);
     spare_func_scan_out_q      : out std_ulogic_vector(0 to 3);
     rp_abst_scan_in            : in  std_ulogic;
     rp_func_scan_in            : in  std_ulogic;
     rp_abst_scan_out           : out std_ulogic;
     rp_func_scan_out           : out std_ulogic;

     bg_an_ac_func_scan_sn      : in  std_ulogic_vector(60 to 69);
     bg_an_ac_abst_scan_sn      : in  std_ulogic_vector(10 to 11);
     bg_an_ac_func_scan_sn_q    : out std_ulogic_vector(60 to 69);
     bg_an_ac_abst_scan_sn_q    : out std_ulogic_vector(10 to 11);

     bg_ac_an_func_scan_ns      : in  std_ulogic_vector(60 to 69);
     bg_ac_an_abst_scan_ns      : in  std_ulogic_vector(10 to 11);
     bg_ac_an_func_scan_ns_q    : out std_ulogic_vector(60 to 69);
     bg_ac_an_abst_scan_ns_q    : out std_ulogic_vector(10 to 11);

     bg_pc_l1p_abist_di_0       : in  std_ulogic_vector(0 to 3);
     bg_pc_l1p_abist_g8t1p_renb_0  : in  std_ulogic;
     bg_pc_l1p_abist_g8t_bw_0   : in  std_ulogic;
     bg_pc_l1p_abist_g8t_bw_1   : in  std_ulogic;
     bg_pc_l1p_abist_g8t_dcomp  : in  std_ulogic_vector(0 to 3);
     bg_pc_l1p_abist_g8t_wenb   : in  std_ulogic;
     bg_pc_l1p_abist_raddr_0    : in  std_ulogic_vector(0 to 9);
     bg_pc_l1p_abist_waddr_0    : in  std_ulogic_vector(0 to 9);
     bg_pc_l1p_abist_wl128_comp_ena : in  std_ulogic;
     bg_pc_l1p_abist_wl32_comp_ena  : in  std_ulogic;
     bg_pc_l1p_abist_di_0_q     : out std_ulogic_vector(0 to 3);
     bg_pc_l1p_abist_g8t1p_renb_0_q  : out std_ulogic;
     bg_pc_l1p_abist_g8t_bw_0_q : out std_ulogic;
     bg_pc_l1p_abist_g8t_bw_1_q : out std_ulogic;
     bg_pc_l1p_abist_g8t_dcomp_q: out std_ulogic_vector(0 to 3);
     bg_pc_l1p_abist_g8t_wenb_q : out std_ulogic;
     bg_pc_l1p_abist_raddr_0_q  : out std_ulogic_vector(0 to 9);
     bg_pc_l1p_abist_waddr_0_q  : out std_ulogic_vector(0 to 9);
     bg_pc_l1p_abist_wl128_comp_ena_q : out std_ulogic;
     bg_pc_l1p_abist_wl32_comp_ena_q  : out std_ulogic;

     bg_pc_l1p_gptr_sl_thold_3  : in  std_ulogic;
     bg_pc_l1p_time_sl_thold_3  : in  std_ulogic;
     bg_pc_l1p_repr_sl_thold_3  : in  std_ulogic;
     bg_pc_l1p_abst_sl_thold_3  : in  std_ulogic;
     bg_pc_l1p_func_sl_thold_3  : in  std_ulogic_vector(0 to 1);
     bg_pc_l1p_func_slp_sl_thold_3 : in  std_ulogic;
     bg_pc_l1p_bolt_sl_thold_3  : in  std_ulogic;
     bg_pc_l1p_ary_nsl_thold_3  : in  std_ulogic;
     bg_pc_l1p_sg_3             : in  std_ulogic_vector(0 to 1);
     bg_pc_l1p_fce_3            : in  std_ulogic;
     bg_pc_l1p_bo_enable_3      : in  std_ulogic;
     bg_pc_l1p_gptr_sl_thold_2  : out std_ulogic;
     bg_pc_l1p_time_sl_thold_2  : out std_ulogic;
     bg_pc_l1p_repr_sl_thold_2  : out std_ulogic;
     bg_pc_l1p_abst_sl_thold_2  : out std_ulogic;
     bg_pc_l1p_func_sl_thold_2  : out std_ulogic_vector(0 to 1);
     bg_pc_l1p_func_slp_sl_thold_2 : out std_ulogic;
     bg_pc_l1p_bolt_sl_thold_2  : out std_ulogic;
     bg_pc_l1p_ary_nsl_thold_2  : out std_ulogic;
     bg_pc_l1p_sg_2             : out std_ulogic_vector(0 to 1);
     bg_pc_l1p_fce_2            : out std_ulogic;
     bg_pc_l1p_bo_enable_2      : out std_ulogic;


     bg_pc_bo_unload_iiu                : in  std_ulogic;
     bg_pc_bo_load_iiu                  : in  std_ulogic;
     bg_pc_bo_repair_iiu                : in  std_ulogic;
     bg_pc_bo_reset_iiu                 : in  std_ulogic;
     bg_pc_bo_shdata_iiu                : in  std_ulogic;
     bg_pc_bo_select_iiu                : in  std_ulogic_vector(0 to 10);
     bg_pc_l1p_ccflush_dc_iiu           : in  std_ulogic;
     bg_pc_l1p_abist_ena_dc_iiu         : in  std_ulogic;
     bg_pc_l1p_abist_raw_dc_b_iiu       : in  std_ulogic;

     bg_pc_bo_unload_oiu                : out std_ulogic;
     bg_pc_bo_load_oiu                  : out std_ulogic;
     bg_pc_bo_repair_oiu                : out std_ulogic;
     bg_pc_bo_reset_oiu                 : out std_ulogic;
     bg_pc_bo_shdata_oiu                : out std_ulogic;
     bg_pc_bo_select_oiu                : out std_ulogic_vector(0 to 10);
     bg_pc_l1p_ccflush_dc_oiu           : out std_ulogic;
     bg_pc_l1p_abist_ena_dc_oiu         : out std_ulogic;
     bg_pc_l1p_abist_raw_dc_b_oiu       : out std_ulogic;

     ac_an_abist_done_dc_iiu            : in  std_ulogic;
     ac_an_psro_ringsig_iiu             : in  std_ulogic;
     mm_pc_bo_fail_iiu                  : in  std_ulogic_vector(0 to 4);
     mm_pc_bo_diagout_iiu               : in  std_ulogic_vector(0 to 4);
     mm_pc_event_data_iiu               : in  std_ulogic_vector(0 to 7);

     ac_an_abist_done_dc_oiu            : out std_ulogic;
     ac_an_psro_ringsig_oiu             : out std_ulogic;
     mm_pc_bo_fail_oiu                  : out std_ulogic_vector(0 to 4);
     mm_pc_bo_diagout_oiu               : out std_ulogic_vector(0 to 4);
     mm_pc_event_data_oiu               : out std_ulogic_vector(0 to 7);

     bg_pc_bo_fail_iiu                  : in  std_ulogic_vector(0 to 10);
     bg_pc_bo_diagout_iiu               : in  std_ulogic_vector(0 to 10);

     bg_pc_bo_fail_oiu                  : out std_ulogic_vector(0 to 10);
     bg_pc_bo_diagout_oiu               : out std_ulogic_vector(0 to 10);

     an_ac_abist_mode_dc_iiu            : in  std_ulogic;
     an_ac_ccenable_dc_iiu              : in  std_ulogic;
     an_ac_ccflush_dc_iiu               : in  std_ulogic;
     an_ac_gsd_test_enable_dc_iiu       : in  std_ulogic;
     an_ac_gsd_test_acmode_dc_iiu       : in  std_ulogic;
     an_ac_lbist_ip_dc_iiu              : in  std_ulogic;
     an_ac_lbist_ac_mode_dc_iiu         : in  std_ulogic;
     an_ac_malf_alert_iiu               : in  std_ulogic;
     an_ac_psro_enable_dc_iiu           : in  std_ulogic_vector(0 to 2);
     an_ac_scan_type_dc_iiu             : in  std_ulogic_vector(0 to 8);
     an_ac_scom_sat_id_iiu              : in  std_ulogic_vector(0 to 3);

     pc_mm_abist_dcomp_g6t_2r_iiu       : in  std_ulogic_vector(0 to 3);
     pc_mm_abist_di_g6t_2r_iiu          : in  std_ulogic_vector(0 to 3);
     pc_mm_abist_di_0_iiu               : in  std_ulogic_vector(0 to 3);
     pc_mm_abist_ena_dc_iiu             : in  std_ulogic;
     pc_mm_abist_g6t_r_wb_iiu           : in  std_ulogic;
     pc_mm_abist_g8t_bw_0_iiu           : in  std_ulogic;
     pc_mm_abist_g8t_bw_1_iiu           : in  std_ulogic;
     pc_mm_abist_g8t_dcomp_iiu          : in  std_ulogic_vector(0 to 3);
     pc_mm_abist_g8t_wenb_iiu           : in  std_ulogic;
     pc_mm_abist_g8t1p_renb_0_iiu       : in  std_ulogic;
     pc_mm_abist_raddr_0_iiu            : in  std_ulogic_vector(0 to 9);
     pc_mm_abist_raw_dc_b_iiu           : in  std_ulogic;
     pc_mm_abist_waddr_0_iiu            : in  std_ulogic_vector(0 to 9);
     pc_mm_abist_wl128_comp_ena_iiu     : in  std_ulogic;
     pc_mm_bo_enable_4_iiu              : in  std_ulogic;
     pc_mm_bo_repair_iiu                : in  std_ulogic;
     pc_mm_bo_reset_iiu                 : in  std_ulogic;
     pc_mm_bo_select_iiu                : in  std_ulogic_vector(0 to 4);
     pc_mm_bo_shdata_iiu                : in  std_ulogic;
     pc_mm_bo_unload_iiu                : in  std_ulogic;
     pc_mm_ccflush_dc_iiu               : in  std_ulogic;
     pc_mm_debug_mux1_ctrls_iiu         : in  std_ulogic_vector(0 to 15);
     pc_mm_event_count_mode_iiu         : in  std_ulogic_vector(0 to 2);
     pc_mm_event_mux_ctrls_iiu          : in  std_ulogic_vector(0 to 39);
     pc_mm_trace_bus_enable_iiu         : in  std_ulogic;

     an_ac_abist_mode_dc_oiu            : out std_ulogic;
     an_ac_ccenable_dc_oiu              : out std_ulogic;
     an_ac_ccflush_dc_oiu               : out std_ulogic;
     an_ac_gsd_test_enable_dc_oiu       : out std_ulogic;
     an_ac_gsd_test_acmode_dc_oiu       : out std_ulogic;
     an_ac_lbist_ip_dc_oiu              : out std_ulogic;
     an_ac_lbist_ac_mode_dc_oiu         : out std_ulogic;
     an_ac_malf_alert_oiu               : out std_ulogic;
     an_ac_psro_enable_dc_oiu           : out std_ulogic_vector(0 to 2);
     an_ac_scan_type_dc_oiu             : out std_ulogic_vector(0 to 8);
     an_ac_scom_sat_id_oiu              : out std_ulogic_vector(0 to 3);

     pc_mm_abist_dcomp_g6t_2r_oiu       : out std_ulogic_vector(0 to 3);
     pc_mm_abist_di_g6t_2r_oiu          : out std_ulogic_vector(0 to 3);
     pc_mm_abist_di_0_oiu               : out std_ulogic_vector(0 to 3);
     pc_mm_abist_ena_dc_oiu             : out std_ulogic;
     pc_mm_abist_g6t_r_wb_oiu           : out std_ulogic;
     pc_mm_abist_g8t_bw_0_oiu           : out std_ulogic;
     pc_mm_abist_g8t_bw_1_oiu           : out std_ulogic;
     pc_mm_abist_g8t_dcomp_oiu          : out std_ulogic_vector(0 to 3);
     pc_mm_abist_g8t_wenb_oiu           : out std_ulogic;
     pc_mm_abist_g8t1p_renb_0_oiu       : out std_ulogic;
     pc_mm_abist_raddr_0_oiu            : out std_ulogic_vector(0 to 9);
     pc_mm_abist_raw_dc_b_oiu           : out std_ulogic;
     pc_mm_abist_waddr_0_oiu            : out std_ulogic_vector(0 to 9);
     pc_mm_abist_wl128_comp_ena_oiu     : out std_ulogic;
     pc_mm_abst_sl_thold_3_oiu          : out std_ulogic;
     pc_mm_abst_slp_sl_thold_3_oiu      : out std_ulogic;
     pc_mm_ary_nsl_thold_3_oiu          : out std_ulogic;
     pc_mm_ary_slp_nsl_thold_3_oiu      : out std_ulogic;
     pc_mm_bo_enable_3_oiu              : out std_ulogic;
     pc_mm_bo_repair_oiu                : out std_ulogic;
     pc_mm_bo_reset_oiu                 : out std_ulogic;
     pc_mm_bo_select_oiu                : out std_ulogic_vector(0 to 4);
     pc_mm_bo_shdata_oiu                : out std_ulogic;
     pc_mm_bo_unload_oiu                : out std_ulogic;
     pc_mm_bolt_sl_thold_3_oiu          : out std_ulogic;
     pc_mm_ccflush_dc_oiu               : out std_ulogic;
     pc_mm_cfg_sl_thold_3_oiu           : out std_ulogic;
     pc_mm_cfg_slp_sl_thold_3_oiu       : out std_ulogic;
     pc_mm_debug_mux1_ctrls_oiu         : out std_ulogic_vector(0 to 15);
     pc_mm_event_count_mode_oiu         : out std_ulogic_vector(0 to 2);
     pc_mm_event_mux_ctrls_oiu          : out std_ulogic_vector(0 to 39);
     pc_mm_fce_3_oiu                    : out std_ulogic;
     pc_mm_func_nsl_thold_3_oiu         : out std_ulogic;
     pc_mm_func_sl_thold_3_oiu          : out std_ulogic_vector(0 to 1);
     pc_mm_func_slp_nsl_thold_3_oiu     : out std_ulogic;
     pc_mm_func_slp_sl_thold_3_oiu      : out std_ulogic_vector(0 to 1);
     pc_mm_gptr_sl_thold_3_oiu          : out std_ulogic;
     pc_mm_repr_sl_thold_3_oiu          : out std_ulogic;
     pc_mm_sg_3_oiu                     : out std_ulogic_vector(0 to 1);
     pc_mm_time_sl_thold_3_oiu          : out std_ulogic;
     pc_mm_trace_bus_enable_oiu         : out std_ulogic;

     an_ac_back_inv_oiu                 : out std_ulogic;
     an_ac_back_inv_addr_oiu            : out std_ulogic_vector(REAL_IFAR'left to 63);
     an_ac_back_inv_target_bit1_oiu     : out std_ulogic;
     an_ac_back_inv_target_bit3_oiu     : out std_ulogic;
     an_ac_back_inv_target_bit4_oiu     : out std_ulogic;
     an_ac_atpg_en_dc_oiu               : out std_ulogic;
     an_ac_lbist_ary_wrt_thru_dc_oiu    : out std_ulogic;
     an_ac_lbist_en_dc_oiu              : out std_ulogic;
     an_ac_scan_diag_dc_oiu             : out std_ulogic;
     an_ac_scan_dis_dc_b_oiu            : out std_ulogic;
     an_ac_grffence_en_dc_oiu           : out std_ulogic

);
-- synopsys translate_off
-- synopsys translate_on
end iuq;
architecture iuq of iuq is
signal clkoff_b                 : std_ulogic_vector(0 to 3);
signal delay_lclkr              : std_ulogic_vector(5 to 14);
signal mpw1_b                   : std_ulogic_vector(5 to 14);
signal pc_iu_sg_2               : std_ulogic_vector(0 to 3);
signal pc_iu_func_sl_thold_2    : std_ulogic_vector(0 to 3);
-- BP
signal bp_ib_iu4_t0_val         : std_ulogic_vector(0 to 3);
signal bp_ib_iu4_t1_val         : std_ulogic_vector(0 to 3);
signal bp_ib_iu4_t2_val         : std_ulogic_vector(0 to 3);
signal bp_ib_iu4_t3_val         : std_ulogic_vector(0 to 3);
signal bp_ib_iu4_ifar_t0        : EFF_IFAR;
signal bp_ib_iu3_0_instr_t0     : std_ulogic_vector(0 to 31);
signal bp_ib_iu4_0_instr_t0     : std_ulogic_vector(32 to 43);
signal bp_ib_iu4_1_instr_t0     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_2_instr_t0     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_3_instr_t0     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_ifar_t1        : EFF_IFAR;
signal bp_ib_iu3_0_instr_t1     : std_ulogic_vector(0 to 31);
signal bp_ib_iu4_0_instr_t1     : std_ulogic_vector(32 to 43);
signal bp_ib_iu4_1_instr_t1     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_2_instr_t1     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_3_instr_t1     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_ifar_t2        : EFF_IFAR;
signal bp_ib_iu3_0_instr_t2     : std_ulogic_vector(0 to 31);
signal bp_ib_iu4_0_instr_t2     : std_ulogic_vector(32 to 43);
signal bp_ib_iu4_1_instr_t2     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_2_instr_t2     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_3_instr_t2     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_ifar_t3        : EFF_IFAR;
signal bp_ib_iu3_0_instr_t3     : std_ulogic_vector(0 to 31);
signal bp_ib_iu4_0_instr_t3     : std_ulogic_vector(32 to 43);
signal bp_ib_iu4_1_instr_t3     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_2_instr_t3     : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_3_instr_t3     : std_ulogic_vector(0 to 43);
-- UC
signal uc_ib_iu4_val            : std_ulogic_vector(0 to 3);
signal uc_ib_iu4_ifar_t0        : std_ulogic_vector(62-uc_ifar to 61);
signal uc_ib_iu4_instr_t0       : std_ulogic_vector(0 to 36);
signal uc_ib_iu4_ifar_t1        : std_ulogic_vector(62-uc_ifar to 61);
signal uc_ib_iu4_instr_t1       : std_ulogic_vector(0 to 36);
signal uc_ib_iu4_ifar_t2        : std_ulogic_vector(62-uc_ifar to 61);
signal uc_ib_iu4_instr_t2       : std_ulogic_vector(0 to 36);
signal uc_ib_iu4_ifar_t3        : std_ulogic_vector(62-uc_ifar to 61);
signal uc_ib_iu4_instr_t3       : std_ulogic_vector(0 to 36);
signal uc_flush_tid             : std_ulogic_vector(0 to 3);
-- RAM
signal rm_ib_iu4_val            : std_ulogic_vector(0 to 3);
signal rm_ib_iu4_force_ram_t0   : std_ulogic;
signal rm_ib_iu4_instr_t0       : std_ulogic_vector(0 to 35);
signal rm_ib_iu4_force_ram_t1   : std_ulogic;
signal rm_ib_iu4_instr_t1       : std_ulogic_vector(0 to 35);
signal rm_ib_iu4_force_ram_t2   : std_ulogic;
signal rm_ib_iu4_instr_t2       : std_ulogic_vector(0 to 35);
signal rm_ib_iu4_force_ram_t3   : std_ulogic;
signal rm_ib_iu4_instr_t3       : std_ulogic_vector(0 to 35);
-- IB
signal iu_au_ib1_instr_vld_t0   : std_ulogic;
signal iu_au_ib1_ifar_t0        : EFF_IFAR;
signal iu_au_ib1_data_t0        : std_ulogic_vector(0 to 49);
signal iu_au_ib1_instr_vld_t1   : std_ulogic;
signal iu_au_ib1_ifar_t1        : EFF_IFAR;
signal iu_au_ib1_data_t1        : std_ulogic_vector(0 to 49);
signal iu_au_ib1_instr_vld_t2   : std_ulogic;
signal iu_au_ib1_ifar_t2        : EFF_IFAR;
signal iu_au_ib1_data_t2        : std_ulogic_vector(0 to 49);
signal iu_au_ib1_instr_vld_t3   : std_ulogic;
signal iu_au_ib1_ifar_t3        : EFF_IFAR;
signal iu_au_ib1_data_t3        : std_ulogic_vector(0 to 49);
signal ib_ic_empty              : std_ulogic_vector(0 to 3);
signal ib_ic_below_water        : std_ulogic_vector(0 to 3);
signal ib_ic_iu5_redirect_tid   : std_ulogic_vector(0 to 3);
-- SPR
signal iu_au_config_iucr_t0     : std_ulogic_vector(0 to 7);
signal iu_au_config_iucr_t1     : std_ulogic_vector(0 to 7);
signal iu_au_config_iucr_t2     : std_ulogic_vector(0 to 7);
signal iu_au_config_iucr_t3     : std_ulogic_vector(0 to 7);
signal spr_fiss_pri_rand        : std_ulogic_vector(0 to 4);
signal spr_fiss_pri_rand_always : std_ulogic;
signal spr_fiss_pri_rand_flush  : std_ulogic;
signal spr_fdep_ll_hold_t0      : std_ulogic;
signal spr_fdep_ll_hold_t1      : std_ulogic;
signal spr_fdep_ll_hold_t2      : std_ulogic;
signal spr_fdep_ll_hold_t3      : std_ulogic;
signal spr_issue_high_mask      : std_ulogic_vector(0 to 3);
signal spr_issue_med_mask       : std_ulogic_vector(0 to 3);
signal spr_fiss_count0_max      : std_ulogic_vector(0 to 5);
signal spr_fiss_count1_max      : std_ulogic_vector(0 to 5);
signal spr_fiss_count2_max      : std_ulogic_vector(0 to 5);
signal spr_fiss_count3_max      : std_ulogic_vector(0 to 5);
signal spr_dec_mask_pt_in_t0          : std_ulogic_vector(0 to 31);
signal spr_dec_mask_pt_in_t1          : std_ulogic_vector(0 to 31);
signal spr_dec_mask_pt_in_t2          : std_ulogic_vector(0 to 31);
signal spr_dec_mask_pt_in_t3          : std_ulogic_vector(0 to 31);
signal spr_dec_mask_pt_out_t0          : std_ulogic_vector(0 to 31);
signal spr_dec_mask_pt_out_t1          : std_ulogic_vector(0 to 31);
signal spr_dec_mask_pt_out_t2          : std_ulogic_vector(0 to 31);
signal spr_dec_mask_pt_out_t3          : std_ulogic_vector(0 to 31);
signal spr_dec_match_t0         : std_ulogic_vector(0 to 31);
signal spr_dec_match_t1         : std_ulogic_vector(0 to 31);
signal spr_dec_match_t2         : std_ulogic_vector(0 to 31);
signal spr_dec_match_t3         : std_ulogic_vector(0 to 31);
signal ic_fdep_load_quiesce     : std_ulogic_vector(0 to 3);
signal ic_fdep_icbi_ack         : std_ulogic_vector(0 to 3);
-- FXU Issue
signal iu_xu_is2_vld_internal                   : std_ulogic;
signal iu_xu_is2_tid_internal                   : std_ulogic_vector(0 to 3);
signal iu_xu_is2_instr_internal                 : std_ulogic_vector(0 to 31);
signal iu_xu_is2_error_internal                 : std_ulogic_vector(0 to 2);
signal iu_xu_is2_pred_update_internal           : std_ulogic;
signal iu_xu_is2_pred_taken_cnt_internal        : std_ulogic_vector(0 to 1);
signal iu_xu_is2_ifar_internal                  : EFF_IFAR;
signal iu_xu_is2_axu_store_internal             : std_ulogic;
signal fiss_uc_is2_ucode_vld                    : std_ulogic;
signal fiss_uc_is2_tid                          : std_ulogic_vector(0 to 3);
signal fiss_uc_is2_instr                        : std_ulogic_vector(0 to 31);
signal fiss_uc_is2_2ucode                       : std_ulogic;
signal fiss_uc_is2_2ucode_type                  : std_ulogic;
signal iuq_mi_scan_out          : std_ulogic_vector(0 to 1);
signal iuq_bp_scan_out          : std_ulogic;
signal iuq_b0_scan_in           : std_ulogic;
signal iuq_b0_scan_out          : std_ulogic;
signal iuq_b1_scan_in           : std_ulogic;
signal iuq_b1_scan_out          : std_ulogic;
signal iuq_b2_scan_in           : std_ulogic;
signal iuq_b2_scan_out          : std_ulogic;
signal iuq_b3_scan_in           : std_ulogic;
signal iuq_b3_scan_out          : std_ulogic;
signal iuq_s0_scan_in           : std_ulogic;
signal iuq_s0_scan_out          : std_ulogic;
signal iuq_s1_scan_in           : std_ulogic;
signal iuq_s1_scan_out          : std_ulogic;
signal iuq_s2_scan_in           : std_ulogic;
signal iuq_s2_scan_out          : std_ulogic;
signal iuq_s3_scan_in           : std_ulogic;
signal iuq_s3_scan_out          : std_ulogic;
signal iuq_fi_scan_in           : std_ulogic;
signal iuq_fi_scan_out          : std_ulogic;
signal iuq_ai_scan_in           : std_ulogic;
signal iuq_ai_scan_out          : std_ulogic;
--perf
signal ib_perf_event_t0         : std_ulogic_vector(0 to 1);
signal ib_perf_event_t1         : std_ulogic_vector(0 to 1);
signal ib_perf_event_t2         : std_ulogic_vector(0 to 1);
signal ib_perf_event_t3         : std_ulogic_vector(0 to 1);
signal fdep_perf_event_pt_in_t0 : std_ulogic_vector(0 to 11);
signal fdep_perf_event_pt_in_t1 : std_ulogic_vector(0 to 11);
signal fdep_perf_event_pt_in_t2 : std_ulogic_vector(0 to 11);
signal fdep_perf_event_pt_in_t3 : std_ulogic_vector(0 to 11);
signal fdep_perf_event_pt_out_t0: std_ulogic_vector(0 to 11);
signal fdep_perf_event_pt_out_t1: std_ulogic_vector(0 to 11);
signal fdep_perf_event_pt_out_t2: std_ulogic_vector(0 to 11);
signal fdep_perf_event_pt_out_t3: std_ulogic_vector(0 to 11);
signal fiss_perf_event_t0       : std_ulogic_vector(0 to 7);
signal fiss_perf_event_t1       : std_ulogic_vector(0 to 7);
signal fiss_perf_event_t2       : std_ulogic_vector(0 to 7);
signal fiss_perf_event_t3       : std_ulogic_vector(0 to 7);
signal fdec_ibuf_stall_t0       : std_ulogic;
signal fdec_ibuf_stall_t1       : std_ulogic;
signal fdec_ibuf_stall_t2       : std_ulogic;
signal fdec_ibuf_stall_t3       : std_ulogic;
--debug groups (misc)
signal fiss_dbg_data            : std_ulogic_vector(0 to 87);
signal fdep_dbg_data_pt_in      : std_ulogic_vector(0 to 87);
signal fdep_dbg_data_pt_out     : std_ulogic_vector(0 to 87);
signal ib_dbg_data              : std_ulogic_vector(0 to 63);
signal fu_iss_dbg_data          : std_ulogic_vector(0 to 23);
signal axu_dbg_data_t0          : std_ulogic_vector(0 to 37);
signal axu_dbg_data_t1          : std_ulogic_vector(0 to 37);
signal axu_dbg_data_t2          : std_ulogic_vector(0 to 37);
signal axu_dbg_data_t3          : std_ulogic_vector(0 to 37);
-- IU pass thru signals
signal an_ac_scan_dis_dc_b_oif  : std_ulogic_vector(0 to 3);
signal an_ac_back_inv_oif       : std_ulogic;
signal an_ac_back_inv_target_oif: std_ulogic_vector(1 to 1);
signal an_ac_sync_ack_oif       : std_ulogic_vector(0 to 3);
signal mm_iu_barrier_done_oif   : std_ulogic_vector(0 to 3);
-- IU repower
signal iu_func_scan_in_q        : std_ulogic_vector(0 to 4);
signal iu_func_scan_out         : std_ulogic_vector(0 to 7);
signal unused                   : std_ulogic_vector(6 to 14);
-- synopsys translate_off
-- synopsys translate_on
begin
------------------------------------------
--tie off unused signals
------------------------------------------
unused(6 to 8)  <= pc_iu_abist_waddr_0(0 to 2);
unused(9 to 10) <= pc_iu_abist_raddr_0(0 to 1);
unused(11)      <= xu_iu_ex5_loadmiss_target(0);
unused(12 to 13)<= xu_iu_ex5_loadmiss_target(7 to 8);
unused(14)      <= xu_iu_ex5_loadmiss_target_type(1);
------------------------------------------
------------------------------------------
iuq_ifetch0 : entity work.iuq_ifetch
generic map(expand_type         => expand_type,
            a2mode              => a2mode,
            regmode             => regmode,
            threads             => threads,
            ucode_mode          => ucode_mode,
            bcfg_epn_0to15      => bcfg_epn_0to15,
            bcfg_epn_16to31     => bcfg_epn_16to31,
            bcfg_epn_32to47     => bcfg_epn_32to47,
            bcfg_epn_48to51     => bcfg_epn_48to51,
            bcfg_rpn_22to31     => bcfg_rpn_22to31,
            bcfg_rpn_32to47     => bcfg_rpn_32to47,
            bcfg_rpn_48to51     => bcfg_rpn_48to51,
            uc_ifar             => uc_ifar)
port map(
     vcs                        => vcs,
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     tc_ac_ccflush_dc           => tc_ac_ccflush_dc,
     an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b,
     an_ac_scan_diag_dc         => an_ac_scan_diag_dc,
     pc_iu_gptr_sl_thold_4      => pc_iu_gptr_sl_thold_4,
     pc_iu_time_sl_thold_4      => pc_iu_time_sl_thold_4,
     pc_iu_repr_sl_thold_4      => pc_iu_repr_sl_thold_4,
     pc_iu_abst_sl_thold_4      => pc_iu_abst_sl_thold_4,
     pc_iu_abst_slp_sl_thold_4  => pc_iu_abst_slp_sl_thold_4,
     pc_iu_bolt_sl_thold_4      => pc_iu_bolt_sl_thold_4,
     pc_iu_regf_slp_sl_thold_4  => pc_iu_regf_slp_sl_thold_4,
     pc_iu_func_sl_thold_4      => pc_iu_func_sl_thold_4,
     pc_iu_func_slp_sl_thold_4  => pc_iu_func_slp_sl_thold_4,
     pc_iu_cfg_sl_thold_4       => pc_iu_cfg_sl_thold_4,
     pc_iu_cfg_slp_sl_thold_4   => pc_iu_cfg_slp_sl_thold_4,
     pc_iu_func_nsl_thold_4     => pc_iu_func_nsl_thold_4,
     pc_iu_func_slp_nsl_thold_4 => pc_iu_func_slp_nsl_thold_4,
     pc_iu_ary_nsl_thold_4      => pc_iu_ary_nsl_thold_4,
     pc_iu_ary_slp_nsl_thold_4  => pc_iu_ary_slp_nsl_thold_4,
     pc_iu_sg_4                 => pc_iu_sg_4,
     pc_iu_fce_4                => pc_iu_fce_4,
     pc_iu_abist_dcomp_g6t_2r   => pc_iu_abist_dcomp_g6t_2r,
     pc_iu_abist_di_0           => pc_iu_abist_di_0,
     pc_iu_abist_di_g6t_2r      => pc_iu_abist_di_g6t_2r,
     pc_iu_abist_ena_dc         => pc_iu_abist_ena_dc,
     pc_iu_abist_g6t_bw         => pc_iu_abist_g6t_bw,
     pc_iu_abist_g6t_r_wb       => pc_iu_abist_g6t_r_wb,
     pc_iu_abist_g8t1p_renb_0   => pc_iu_abist_g8t1p_renb_0,
     pc_iu_abist_g8t_bw_0       => pc_iu_abist_g8t_bw_0,
     pc_iu_abist_g8t_bw_1       => pc_iu_abist_g8t_bw_1,
     pc_iu_abist_g8t_dcomp      => pc_iu_abist_g8t_dcomp,
     pc_iu_abist_g8t_wenb       => pc_iu_abist_g8t_wenb,
     pc_iu_abist_raddr_0        => pc_iu_abist_raddr_0(2 to 9),
     pc_iu_abist_raw_dc_b       => pc_iu_abist_raw_dc_b,
     pc_iu_abist_waddr_0        => pc_iu_abist_waddr_0(3 to 9),
     pc_iu_abist_wl256_comp_ena => pc_iu_abist_wl256_comp_ena,
     pc_iu_abist_wl64_comp_ena  => pc_iu_abist_wl64_comp_ena,
     pc_iu_abist_wl128_comp_ena => pc_iu_abist_wl128_comp_ena,
     an_ac_lbist_ary_wrt_thru_dc=> an_ac_lbist_ary_wrt_thru_dc,
     an_ac_lbist_en_dc          => an_ac_lbist_en_dc,
     an_ac_atpg_en_dc           => an_ac_atpg_en_dc,
     an_ac_grffence_en_dc       => an_ac_grffence_en_dc,
     pc_iu_bo_enable_4          => pc_iu_bo_enable_4,
     pc_iu_bo_reset             => pc_iu_bo_reset,
     pc_iu_bo_unload            => pc_iu_bo_unload,
     pc_iu_bo_repair            => pc_iu_bo_repair,
     pc_iu_bo_shdata            => pc_iu_bo_shdata,
     pc_iu_bo_select            => pc_iu_bo_select,
     iu_pc_bo_fail              => iu_pc_bo_fail,
     iu_pc_bo_diagout           => iu_pc_bo_diagout,
     iu_pc_err_icache_parity    => iu_pc_err_icache_parity,
     iu_pc_err_icachedir_parity => iu_pc_err_icachedir_parity,
     iu_pc_err_icachedir_multihit => iu_pc_err_icachedir_multihit,
     iu_pc_err_ucode_illegal    => iu_pc_err_ucode_illegal,
     pc_iu_inj_icache_parity    => pc_iu_inj_icache_parity,
     pc_iu_inj_icachedir_parity => pc_iu_inj_icachedir_parity,
     pc_iu_inj_icachedir_multihit => pc_iu_inj_icachedir_multihit,
     pc_iu_trace_bus_enable     => pc_iu_trace_bus_enable,
     pc_iu_debug_mux1_ctrls     => pc_iu_debug_mux1_ctrls,
     pc_iu_debug_mux2_ctrls     => pc_iu_debug_mux2_ctrls,
     debug_data_in              => debug_data_in,
     trace_triggers_in          => trace_triggers_in,
     debug_data_out             => debug_data_out,
     trace_triggers_out         => trace_triggers_out,
     pc_iu_event_mux_ctrls      => pc_iu_event_mux_ctrls,
     pc_iu_event_count_mode     => pc_iu_event_count_mode,
     pc_iu_event_bus_enable     => pc_iu_event_bus_enable,
     iu_pc_event_data           => iu_pc_event_data,
     pc_iu_init_reset           => pc_iu_init_reset,
     gptr_scan_in               => gptr_scan_in,
     time_scan_in               => time_scan_in,
     repr_scan_in               => repr_scan_in,
     abst_scan_in               => abst_scan_in,
     func_scan_in               => func_scan_in,
     ccfg_scan_in               => ccfg_scan_in,
     bcfg_scan_in               => bcfg_scan_in,
     dcfg_scan_in               => dcfg_scan_in,
     regf_scan_in               => regf_scan_in,
     gptr_scan_out              => gptr_scan_out,
     time_scan_out              => time_scan_out,
     repr_scan_out              => repr_scan_out,
     abst_scan_out              => abst_scan_out,
     func_scan_out              => func_scan_out,
     ccfg_scan_out              => ccfg_scan_out,
     bcfg_scan_out              => bcfg_scan_out,
     dcfg_scan_out              => dcfg_scan_out,
     regf_scan_out              => regf_scan_out,
     iuq_mi_scan_out            => iuq_mi_scan_out,
     iuq_bp_scan_out            => iuq_bp_scan_out,
     slowspr_val_in             => slowspr_val_in,
     slowspr_rw_in              => slowspr_rw_in,
     slowspr_etid_in            => slowspr_etid_in,
     slowspr_addr_in            => slowspr_addr_in,
     slowspr_data_in            => slowspr_data_in,
     slowspr_done_in            => slowspr_done_in,
     slowspr_val_out            => slowspr_val_out,
     slowspr_rw_out             => slowspr_rw_out,
     slowspr_etid_out           => slowspr_etid_out,
     slowspr_addr_out           => slowspr_addr_out,
     slowspr_data_out           => slowspr_data_out,
     slowspr_done_out           => slowspr_done_out,
     xu_iu_run_thread           => xu_iu_run_thread,
     xu_iu_flush                => xu_iu_l_flush,
     xu_iu_iu0_flush_ifar0      => xu_iu_iu0_flush_ifar0,
     xu_iu_iu0_flush_ifar1      => xu_iu_iu0_flush_ifar1,
     xu_iu_iu0_flush_ifar2      => xu_iu_iu0_flush_ifar2,
     xu_iu_iu0_flush_ifar3      => xu_iu_iu0_flush_ifar3,
     xu_iu_flush_2ucode         => xu_iu_flush_2ucode,
     xu_iu_flush_2ucode_type    => xu_iu_flush_2ucode_type,
     xu_iu_msr_cm               => xu_iu_msr_cm,
     xu_iu_ex6_icbi_val         => xu_iu_ex6_icbi_val,
     xu_iu_ex6_icbi_addr        => xu_iu_ex6_icbi_addr,
     xu_iu_ici                  => xu_iu_ici,
     iu_xu_request              => iu_xu_request,
     iu_xu_thread               => iu_xu_thread,
     iu_xu_ra                   => iu_xu_ra,
     iu_xu_wimge                => iu_xu_wimge,
     iu_xu_userdef              => iu_xu_userdef,
     an_ac_reld_data_vld        => an_ac_reld_data_vld,
     an_ac_reld_core_tag        => an_ac_reld_core_tag,
     an_ac_reld_qw              => an_ac_reld_qw,
     an_ac_reld_data            => an_ac_reld_data,
     an_ac_reld_ecc_err         => an_ac_reld_ecc_err,
     an_ac_reld_ecc_err_ue      => an_ac_reld_ecc_err_ue,
     an_ac_back_inv             => an_ac_back_inv,
     an_ac_back_inv_addr        => an_ac_back_inv_addr,
     an_ac_back_inv_target_iiu_a=> an_ac_back_inv_target_iiu_a,
     an_ac_back_inv_target_iiu_b=> an_ac_back_inv_target_iiu_b,
     an_ac_icbi_ack             => an_ac_icbi_ack,
     an_ac_icbi_ack_thread      => an_ac_icbi_ack_thread,
     iu_mm_ierat_req            => iu_mm_ierat_req,
     iu_mm_ierat_epn            => iu_mm_ierat_epn,
     iu_mm_ierat_thdid          => iu_mm_ierat_thdid,
     iu_mm_ierat_state          => iu_mm_ierat_state,
     iu_mm_ierat_tid            => iu_mm_ierat_tid,
     iu_mm_ierat_flush          => iu_mm_ierat_flush,
     mm_iu_ierat_rel_val        => mm_iu_ierat_rel_val,
     mm_iu_ierat_rel_data       => mm_iu_ierat_rel_data,
     mm_iu_ierat_snoop_coming   => mm_iu_ierat_snoop_coming,
     mm_iu_ierat_snoop_val      => mm_iu_ierat_snoop_val,
     mm_iu_ierat_snoop_attr     => mm_iu_ierat_snoop_attr,
     mm_iu_ierat_snoop_vpn      => mm_iu_ierat_snoop_vpn,
     iu_mm_ierat_snoop_ack      => iu_mm_ierat_snoop_ack,
     mm_iu_ierat_pid0           => mm_iu_ierat_pid0,
     mm_iu_ierat_pid1           => mm_iu_ierat_pid1,
     mm_iu_ierat_pid2           => mm_iu_ierat_pid2,
     mm_iu_ierat_pid3           => mm_iu_ierat_pid3,
     mm_iu_ierat_mmucr0_0       => mm_iu_ierat_mmucr0_0,
     mm_iu_ierat_mmucr0_1       => mm_iu_ierat_mmucr0_1,
     mm_iu_ierat_mmucr0_2       => mm_iu_ierat_mmucr0_2,
     mm_iu_ierat_mmucr0_3       => mm_iu_ierat_mmucr0_3,
     iu_mm_ierat_mmucr0         => iu_mm_ierat_mmucr0,
     iu_mm_ierat_mmucr0_we      => iu_mm_ierat_mmucr0_we,
     mm_iu_ierat_mmucr1         => mm_iu_ierat_mmucr1,
     iu_mm_ierat_mmucr1         => iu_mm_ierat_mmucr1,
     iu_mm_ierat_mmucr1_we      => iu_mm_ierat_mmucr1_we,
     iu_mm_lmq_empty            => iu_mm_lmq_empty,
     xu_iu_ex1_rb               => xu_iu_ex1_rb,
     xu_rf1_flush               => xu_wl_rf1_flush,
     xu_ex1_flush               => xu_wl_ex1_flush,
     xu_ex2_flush               => xu_wl_ex2_flush,
     xu_ex3_flush               => xu_wl_ex3_flush,
     xu_ex4_flush               => xu_wl_ex4_flush,
     xu_ex5_flush               => xu_wl_ex5_flush,
     xu_iu_ex4_rs_data          => xu_iu_ex4_rs_data,
     xu_iu_hid_mmu_mode         => xu_iu_hid_mmu_mode,
     xu_iu_msr_hv               => xu_iu_msr_hv,
     xu_iu_msr_is               => xu_iu_msr_is,
     xu_iu_msr_pr               => xu_iu_msr_pr,
     xu_iu_spr_ccr2_ifratsc     => xu_iu_spr_ccr2_ifratsc,
     xu_iu_spr_ccr2_ifrat       => xu_iu_spr_ccr2_ifrat,
     xu_iu_xucr4_mmu_mchk       => xu_iu_xucr4_mmu_mchk,
     xu_iu_rf1_val              => xu_iu_rf1_val,
     xu_iu_rf1_is_eratre        => xu_iu_rf1_is_eratre,
     xu_iu_rf1_is_eratsx        => xu_iu_rf1_is_eratsx,
     xu_iu_rf1_is_eratwe        => xu_iu_rf1_is_eratwe,
     xu_iu_rf1_is_eratilx       => xu_iu_rf1_is_eratilx,
     xu_iu_ex1_is_isync         => xu_iu_ex1_is_isync,
     xu_iu_ex1_is_csync         => xu_iu_ex1_is_csync,
     xu_iu_rf1_ws               => xu_iu_rf1_ws,
     xu_iu_rf1_t                => xu_iu_rf1_t,
     xu_iu_ex1_ra_entry         => xu_iu_ex1_ra_entry,
     xu_iu_ex1_rs_is            => xu_iu_ex1_rs_is,
     iu_xu_ex4_tlb_data         => iu_xu_ex4_tlb_data,
     iu_xu_ierat_ex3_par_err    => iu_xu_ierat_ex3_par_err,
     iu_xu_ierat_ex4_par_err    => iu_xu_ierat_ex4_par_err,
     iu_xu_ierat_ex2_flush_req  => iu_xu_ierat_ex2_flush_req,
     xu_iu_ex5_ifar             => xu_iu_ex5_ifar,
     xu_iu_ex5_tid              => xu_iu_ex5_tid,
     xu_iu_ex5_val              => xu_iu_ex5_val,
     xu_iu_ex5_br_update        => xu_iu_ex5_br_update,
     xu_iu_ex5_br_hist          => xu_iu_ex5_br_hist,
     xu_iu_ex5_br_taken         => xu_iu_ex5_br_taken,
     xu_iu_ex5_bclr             => xu_iu_ex5_bclr,
     xu_iu_ex5_getNIA           => xu_iu_ex5_getNIA,
     xu_iu_ex5_lk               => xu_iu_ex5_lk,
     xu_iu_ex5_bh               => xu_iu_ex5_bh,
     xu_iu_ex5_gshare           => xu_iu_ex5_gshare,
     pc_iu_ram_instr            => pc_iu_ram_instr,
     pc_iu_ram_instr_ext        => pc_iu_ram_instr_ext,
     pc_iu_ram_force_cmplt      => pc_iu_ram_force_cmplt,
     xu_iu_ram_issue            => xu_iu_ram_issue,
     xu_iu_ex6_pri              => xu_iu_ex6_pri,
     xu_iu_ex6_pri_val          => xu_iu_ex6_pri_val,
     xu_iu_raise_iss_pri        => xu_iu_raise_iss_pri,
     xu_iu_msr_gs               => xu_iu_msr_gs,
     xu_iu_ucode_restart        => xu_iu_ucode_restart,
     xu_iu_spr_xer0             => xu_iu_spr_xer0,
     xu_iu_spr_xer1             => xu_iu_spr_xer1,
     xu_iu_spr_xer2             => xu_iu_spr_xer2,
     xu_iu_spr_xer3             => xu_iu_spr_xer3,
     xu_iu_uc_flush_ifar0       => xu_iu_uc_flush_ifar0,
     xu_iu_uc_flush_ifar1       => xu_iu_uc_flush_ifar1,
     xu_iu_uc_flush_ifar2       => xu_iu_uc_flush_ifar2,
     xu_iu_uc_flush_ifar3       => xu_iu_uc_flush_ifar3,
     rtim_sl_thold_7            => rtim_sl_thold_7,
     func_sl_thold_7            => func_sl_thold_7,
     func_nsl_thold_7           => func_nsl_thold_7,
     ary_nsl_thold_7            => ary_nsl_thold_7,
     sg_7                       => sg_7,
     fce_7                      => fce_7,
     rtim_sl_thold_6            => rtim_sl_thold_6,
     func_sl_thold_6            => func_sl_thold_6,
     func_nsl_thold_6           => func_nsl_thold_6,
     ary_nsl_thold_6            => ary_nsl_thold_6,
     sg_6                       => sg_6,
     fce_6                      => fce_6,
     an_ac_scom_dch             => an_ac_scom_dch,
     an_ac_scom_cch             => an_ac_scom_cch,
     an_ac_checkstop            => an_ac_checkstop,
     an_ac_debug_stop           => an_ac_debug_stop,
     an_ac_pm_thread_stop       => an_ac_pm_thread_stop,
     an_ac_reset_1_complete     => an_ac_reset_1_complete,
     an_ac_reset_2_complete     => an_ac_reset_2_complete,
     an_ac_reset_3_complete     => an_ac_reset_3_complete,
     an_ac_reset_wd_complete    => an_ac_reset_wd_complete,
     an_ac_abist_start_test     => an_ac_abist_start_test,
     ac_rp_trace_to_perfcntr    => ac_rp_trace_to_perfcntr,
     rp_pc_scom_dch_q           => rp_pc_scom_dch_q,
     rp_pc_scom_cch_q           => rp_pc_scom_cch_q,
     rp_pc_checkstop_q          => rp_pc_checkstop_q,
     rp_pc_debug_stop_q         => rp_pc_debug_stop_q,
     rp_pc_pm_thread_stop_q     => rp_pc_pm_thread_stop_q,
     rp_pc_reset_1_complete_q   => rp_pc_reset_1_complete_q,
     rp_pc_reset_2_complete_q   => rp_pc_reset_2_complete_q,
     rp_pc_reset_3_complete_q   => rp_pc_reset_3_complete_q,
     rp_pc_reset_wd_complete_q  => rp_pc_reset_wd_complete_q,
     rp_pc_abist_start_test_q   => rp_pc_abist_start_test_q,
     rp_pc_trace_to_perfcntr_q  => rp_pc_trace_to_perfcntr_q,
     pc_rp_scom_dch             => pc_rp_scom_dch,
     pc_rp_scom_cch             => pc_rp_scom_cch,
     pc_rp_special_attn         => pc_rp_special_attn,
     pc_rp_checkstop            => pc_rp_checkstop,
     pc_rp_local_checkstop      => pc_rp_local_checkstop,
     pc_rp_recov_err            => pc_rp_recov_err,
     pc_rp_trace_error          => pc_rp_trace_error,
     pc_rp_event_bus_enable     => pc_rp_event_bus_enable,
     pc_rp_event_bus            => pc_rp_event_bus,
     pc_rp_fu_bypass_events     => pc_rp_fu_bypass_events,
     pc_rp_iu_bypass_events     => pc_rp_iu_bypass_events,
     pc_rp_mm_bypass_events     => pc_rp_mm_bypass_events,
     pc_rp_lsu_bypass_events    => pc_rp_lsu_bypass_events,
     pc_rp_pm_thread_running    => pc_rp_pm_thread_running,
     pc_rp_power_managed        => pc_rp_power_managed,
     pc_rp_rvwinkle_mode        => pc_rp_rvwinkle_mode,
     ac_an_scom_dch_q           => ac_an_scom_dch_q,
     ac_an_scom_cch_q           => ac_an_scom_cch_q,
     ac_an_special_attn_q       => ac_an_special_attn_q,
     ac_an_checkstop_q          => ac_an_checkstop_q,
     ac_an_local_checkstop_q    => ac_an_local_checkstop_q,
     ac_an_recov_err_q          => ac_an_recov_err_q,
     ac_an_trace_error_q        => ac_an_trace_error_q,
     rp_mm_event_bus_enable_q   => rp_mm_event_bus_enable_q,
     ac_an_event_bus_q          => ac_an_event_bus_q,
     ac_an_fu_bypass_events_q   => ac_an_fu_bypass_events_q,
     ac_an_iu_bypass_events_q   => ac_an_iu_bypass_events_q,
     ac_an_mm_bypass_events_q   => ac_an_mm_bypass_events_q,
     ac_an_lsu_bypass_events_q  => ac_an_lsu_bypass_events_q,
     ac_an_pm_thread_running_q  => ac_an_pm_thread_running_q,
     ac_an_power_managed_q      => ac_an_power_managed_q,
     ac_an_rvwinkle_mode_q      => ac_an_rvwinkle_mode_q,
     pc_func_scan_in            => pc_func_scan_in,
     pc_func_scan_in_q          => pc_func_scan_in_q,
     pc_func_scan_out           => pc_func_scan_out,
     pc_func_scan_out_q         => pc_func_scan_out_q,
     pc_bcfg_scan_in            => pc_bcfg_scan_in,
     pc_bcfg_scan_in_q          => pc_bcfg_scan_in_q,
     pc_dcfg_scan_in            => pc_dcfg_scan_in,
     pc_dcfg_scan_in_q          => pc_dcfg_scan_in_q,
     pc_bcfg_scan_out           => pc_bcfg_scan_out,
     pc_bcfg_scan_out_q         => pc_bcfg_scan_out_q,
     pc_ccfg_scan_out           => pc_ccfg_scan_out,
     pc_ccfg_scan_out_q         => pc_ccfg_scan_out_q,
     pc_dcfg_scan_out           => pc_dcfg_scan_out,
     pc_dcfg_scan_out_q         => pc_dcfg_scan_out_q,
     fu_abst_scan_in            => fu_abst_scan_in,
     fu_abst_scan_in_q          => fu_abst_scan_in_q,
     fu_abst_scan_out           => fu_abst_scan_out,
     fu_abst_scan_out_q         => fu_abst_scan_out_q,
     fu_ccfg_scan_out           => fu_ccfg_scan_out,
     fu_ccfg_scan_out_q         => fu_ccfg_scan_out_q,
     fu_bcfg_scan_out           => fu_bcfg_scan_out,
     fu_bcfg_scan_out_q         => fu_bcfg_scan_out_q,
     fu_dcfg_scan_out           => fu_dcfg_scan_out,
     fu_dcfg_scan_out_q         => fu_dcfg_scan_out_q,
     fu_func_scan_in            => fu_func_scan_in,
     fu_func_scan_in_q          => fu_func_scan_in_q,
     fu_func_scan_out           => fu_func_scan_out,
     fu_func_scan_out_q         => fu_func_scan_out_q,
     bx_abst_scan_in            => bx_abst_scan_in,
     bx_abst_scan_in_q          => bx_abst_scan_in_q,
     bx_abst_scan_out           => bx_abst_scan_out,
     bx_abst_scan_out_q         => bx_abst_scan_out_q,
     bx_func_scan_in            => bx_func_scan_in,
     bx_func_scan_in_q          => bx_func_scan_in_q,
     bx_func_scan_out           => bx_func_scan_out,
     bx_func_scan_out_q         => bx_func_scan_out_q,
     iu_func_scan_in_q          => iu_func_scan_in_q,
     iu_func_scan_out           => iu_func_scan_out,
     spare_func_scan_in         => spare_func_scan_in,
     spare_func_scan_out_q      => spare_func_scan_out_q,
     rp_abst_scan_in            => rp_abst_scan_in,
     rp_func_scan_in            => rp_func_scan_in,
     rp_abst_scan_out           => rp_abst_scan_out,
     rp_func_scan_out           => rp_func_scan_out,
     bg_an_ac_func_scan_sn      => bg_an_ac_func_scan_sn,
     bg_an_ac_abst_scan_sn      => bg_an_ac_abst_scan_sn,
     bg_an_ac_func_scan_sn_q    => bg_an_ac_func_scan_sn_q,
     bg_an_ac_abst_scan_sn_q    => bg_an_ac_abst_scan_sn_q,
     bg_ac_an_func_scan_ns      => bg_ac_an_func_scan_ns,
     bg_ac_an_abst_scan_ns      => bg_ac_an_abst_scan_ns,
     bg_ac_an_func_scan_ns_q    => bg_ac_an_func_scan_ns_q,
     bg_ac_an_abst_scan_ns_q    => bg_ac_an_abst_scan_ns_q,
     bg_pc_l1p_abist_di_0       => bg_pc_l1p_abist_di_0,
     bg_pc_l1p_abist_g8t1p_renb_0  => bg_pc_l1p_abist_g8t1p_renb_0,
     bg_pc_l1p_abist_g8t_bw_0   => bg_pc_l1p_abist_g8t_bw_0,
     bg_pc_l1p_abist_g8t_bw_1   => bg_pc_l1p_abist_g8t_bw_1,
     bg_pc_l1p_abist_g8t_dcomp  => bg_pc_l1p_abist_g8t_dcomp,
     bg_pc_l1p_abist_g8t_wenb   => bg_pc_l1p_abist_g8t_wenb,
     bg_pc_l1p_abist_raddr_0    => bg_pc_l1p_abist_raddr_0,
     bg_pc_l1p_abist_waddr_0    => bg_pc_l1p_abist_waddr_0,
     bg_pc_l1p_abist_wl128_comp_ena => bg_pc_l1p_abist_wl128_comp_ena,
     bg_pc_l1p_abist_wl32_comp_ena  => bg_pc_l1p_abist_wl32_comp_ena,
     bg_pc_l1p_abist_di_0_q     => bg_pc_l1p_abist_di_0_q,
     bg_pc_l1p_abist_g8t1p_renb_0_q  => bg_pc_l1p_abist_g8t1p_renb_0_q,
     bg_pc_l1p_abist_g8t_bw_0_q => bg_pc_l1p_abist_g8t_bw_0_q,
     bg_pc_l1p_abist_g8t_bw_1_q => bg_pc_l1p_abist_g8t_bw_1_q,
     bg_pc_l1p_abist_g8t_dcomp_q=> bg_pc_l1p_abist_g8t_dcomp_q,
     bg_pc_l1p_abist_g8t_wenb_q => bg_pc_l1p_abist_g8t_wenb_q,
     bg_pc_l1p_abist_raddr_0_q  => bg_pc_l1p_abist_raddr_0_q,
     bg_pc_l1p_abist_waddr_0_q  => bg_pc_l1p_abist_waddr_0_q,
     bg_pc_l1p_abist_wl128_comp_ena_q => bg_pc_l1p_abist_wl128_comp_ena_q,
     bg_pc_l1p_abist_wl32_comp_ena_q  => bg_pc_l1p_abist_wl32_comp_ena_q,
     bg_pc_l1p_gptr_sl_thold_3  => bg_pc_l1p_gptr_sl_thold_3,
     bg_pc_l1p_time_sl_thold_3  => bg_pc_l1p_time_sl_thold_3,
     bg_pc_l1p_repr_sl_thold_3  => bg_pc_l1p_repr_sl_thold_3,
     bg_pc_l1p_abst_sl_thold_3  => bg_pc_l1p_abst_sl_thold_3,
     bg_pc_l1p_func_sl_thold_3  => bg_pc_l1p_func_sl_thold_3,
     bg_pc_l1p_func_slp_sl_thold_3 => bg_pc_l1p_func_slp_sl_thold_3,
     bg_pc_l1p_bolt_sl_thold_3  => bg_pc_l1p_bolt_sl_thold_3,
     bg_pc_l1p_ary_nsl_thold_3  => bg_pc_l1p_ary_nsl_thold_3,
     bg_pc_l1p_sg_3             => bg_pc_l1p_sg_3,
     bg_pc_l1p_fce_3            => bg_pc_l1p_fce_3,
     bg_pc_l1p_bo_enable_3      => bg_pc_l1p_bo_enable_3,
     bg_pc_l1p_gptr_sl_thold_2  => bg_pc_l1p_gptr_sl_thold_2,
     bg_pc_l1p_time_sl_thold_2  => bg_pc_l1p_time_sl_thold_2,
     bg_pc_l1p_repr_sl_thold_2  => bg_pc_l1p_repr_sl_thold_2,
     bg_pc_l1p_abst_sl_thold_2  => bg_pc_l1p_abst_sl_thold_2,
     bg_pc_l1p_func_sl_thold_2  => bg_pc_l1p_func_sl_thold_2,
     bg_pc_l1p_func_slp_sl_thold_2 => bg_pc_l1p_func_slp_sl_thold_2,
     bg_pc_l1p_bolt_sl_thold_2  => bg_pc_l1p_bolt_sl_thold_2,
     bg_pc_l1p_ary_nsl_thold_2  => bg_pc_l1p_ary_nsl_thold_2,
     bg_pc_l1p_sg_2             => bg_pc_l1p_sg_2,
     bg_pc_l1p_fce_2            => bg_pc_l1p_fce_2,
     bg_pc_l1p_bo_enable_2      => bg_pc_l1p_bo_enable_2,
     bg_pc_bo_unload_iiu                => bg_pc_bo_unload_iiu,
     bg_pc_bo_load_iiu                  => bg_pc_bo_load_iiu,
     bg_pc_bo_repair_iiu                => bg_pc_bo_repair_iiu,
     bg_pc_bo_reset_iiu                 => bg_pc_bo_reset_iiu,
     bg_pc_bo_shdata_iiu                => bg_pc_bo_shdata_iiu,
     bg_pc_bo_select_iiu                => bg_pc_bo_select_iiu,
     bg_pc_l1p_ccflush_dc_iiu           => bg_pc_l1p_ccflush_dc_iiu,
     bg_pc_l1p_abist_ena_dc_iiu         => bg_pc_l1p_abist_ena_dc_iiu,
     bg_pc_l1p_abist_raw_dc_b_iiu       => bg_pc_l1p_abist_raw_dc_b_iiu,
     bg_pc_bo_unload_oiu                => bg_pc_bo_unload_oiu,
     bg_pc_bo_load_oiu                  => bg_pc_bo_load_oiu,
     bg_pc_bo_repair_oiu                => bg_pc_bo_repair_oiu,
     bg_pc_bo_reset_oiu                 => bg_pc_bo_reset_oiu,
     bg_pc_bo_shdata_oiu                => bg_pc_bo_shdata_oiu,
     bg_pc_bo_select_oiu                => bg_pc_bo_select_oiu,
     bg_pc_l1p_ccflush_dc_oiu           => bg_pc_l1p_ccflush_dc_oiu,
     bg_pc_l1p_abist_ena_dc_oiu         => bg_pc_l1p_abist_ena_dc_oiu,
     bg_pc_l1p_abist_raw_dc_b_oiu       => bg_pc_l1p_abist_raw_dc_b_oiu,
     ac_an_abist_done_dc_iiu            => ac_an_abist_done_dc_iiu,
     ac_an_psro_ringsig_iiu             => ac_an_psro_ringsig_iiu,
     mm_pc_bo_fail_iiu                  => mm_pc_bo_fail_iiu,
     mm_pc_bo_diagout_iiu               => mm_pc_bo_diagout_iiu,
     mm_pc_event_data_iiu               => mm_pc_event_data_iiu,
     ac_an_abist_done_dc_oiu            => ac_an_abist_done_dc_oiu,
     ac_an_psro_ringsig_oiu             => ac_an_psro_ringsig_oiu,
     mm_pc_bo_fail_oiu                  => mm_pc_bo_fail_oiu,
     mm_pc_bo_diagout_oiu               => mm_pc_bo_diagout_oiu,
     mm_pc_event_data_oiu               => mm_pc_event_data_oiu,
     bg_pc_bo_fail_iiu                  => bg_pc_bo_fail_iiu,
     bg_pc_bo_diagout_iiu               => bg_pc_bo_diagout_iiu,
     bg_pc_bo_fail_oiu                  => bg_pc_bo_fail_oiu,
     bg_pc_bo_diagout_oiu               => bg_pc_bo_diagout_oiu,
     an_ac_abist_mode_dc_iiu            => an_ac_abist_mode_dc_iiu,
     an_ac_ccenable_dc_iiu              => an_ac_ccenable_dc_iiu,
     an_ac_ccflush_dc_iiu               => an_ac_ccflush_dc_iiu,
     an_ac_gsd_test_enable_dc_iiu       => an_ac_gsd_test_enable_dc_iiu,
     an_ac_gsd_test_acmode_dc_iiu       => an_ac_gsd_test_acmode_dc_iiu,
     an_ac_lbist_ip_dc_iiu              => an_ac_lbist_ip_dc_iiu,
     an_ac_lbist_ac_mode_dc_iiu         => an_ac_lbist_ac_mode_dc_iiu,
     an_ac_malf_alert_iiu               => an_ac_malf_alert_iiu,
     an_ac_psro_enable_dc_iiu           => an_ac_psro_enable_dc_iiu,
     an_ac_scan_type_dc_iiu             => an_ac_scan_type_dc_iiu,
     an_ac_scom_sat_id_iiu              => an_ac_scom_sat_id_iiu,
     pc_mm_abist_dcomp_g6t_2r_iiu       => pc_mm_abist_dcomp_g6t_2r_iiu,
     pc_mm_abist_di_g6t_2r_iiu          => pc_mm_abist_di_g6t_2r_iiu,
     pc_mm_abist_di_0_iiu               => pc_mm_abist_di_0_iiu,
     pc_mm_abist_ena_dc_iiu             => pc_mm_abist_ena_dc_iiu,
     pc_mm_abist_g6t_r_wb_iiu           => pc_mm_abist_g6t_r_wb_iiu,
     pc_mm_abist_g8t_bw_0_iiu           => pc_mm_abist_g8t_bw_0_iiu,
     pc_mm_abist_g8t_bw_1_iiu           => pc_mm_abist_g8t_bw_1_iiu,
     pc_mm_abist_g8t_dcomp_iiu          => pc_mm_abist_g8t_dcomp_iiu,
     pc_mm_abist_g8t_wenb_iiu           => pc_mm_abist_g8t_wenb_iiu,
     pc_mm_abist_g8t1p_renb_0_iiu       => pc_mm_abist_g8t1p_renb_0_iiu,
     pc_mm_abist_raddr_0_iiu            => pc_mm_abist_raddr_0_iiu,
     pc_mm_abist_raw_dc_b_iiu           => pc_mm_abist_raw_dc_b_iiu,
     pc_mm_abist_waddr_0_iiu            => pc_mm_abist_waddr_0_iiu,
     pc_mm_abist_wl128_comp_ena_iiu     => pc_mm_abist_wl128_comp_ena_iiu,
     pc_mm_bo_enable_4_iiu              => pc_mm_bo_enable_4_iiu,
     pc_mm_bo_repair_iiu                => pc_mm_bo_repair_iiu,
     pc_mm_bo_reset_iiu                 => pc_mm_bo_reset_iiu,
     pc_mm_bo_select_iiu                => pc_mm_bo_select_iiu,
     pc_mm_bo_shdata_iiu                => pc_mm_bo_shdata_iiu,
     pc_mm_bo_unload_iiu                => pc_mm_bo_unload_iiu,
     pc_mm_ccflush_dc_iiu               => pc_mm_ccflush_dc_iiu,
     pc_mm_debug_mux1_ctrls_iiu         => pc_mm_debug_mux1_ctrls_iiu,
     pc_mm_event_count_mode_iiu         => pc_mm_event_count_mode_iiu,
     pc_mm_event_mux_ctrls_iiu          => pc_mm_event_mux_ctrls_iiu,
     pc_mm_trace_bus_enable_iiu         => pc_mm_trace_bus_enable_iiu,
     an_ac_abist_mode_dc_oiu            => an_ac_abist_mode_dc_oiu,
     an_ac_ccenable_dc_oiu              => an_ac_ccenable_dc_oiu,
     an_ac_ccflush_dc_oiu               => an_ac_ccflush_dc_oiu,
     an_ac_gsd_test_enable_dc_oiu       => an_ac_gsd_test_enable_dc_oiu,
     an_ac_gsd_test_acmode_dc_oiu       => an_ac_gsd_test_acmode_dc_oiu,
     an_ac_lbist_ip_dc_oiu              => an_ac_lbist_ip_dc_oiu,
     an_ac_lbist_ac_mode_dc_oiu         => an_ac_lbist_ac_mode_dc_oiu,
     an_ac_malf_alert_oiu               => an_ac_malf_alert_oiu,
     an_ac_psro_enable_dc_oiu           => an_ac_psro_enable_dc_oiu,
     an_ac_scan_type_dc_oiu             => an_ac_scan_type_dc_oiu,
     an_ac_scom_sat_id_oiu              => an_ac_scom_sat_id_oiu,
     pc_mm_abist_dcomp_g6t_2r_oiu       => pc_mm_abist_dcomp_g6t_2r_oiu,
     pc_mm_abist_di_g6t_2r_oiu          => pc_mm_abist_di_g6t_2r_oiu,
     pc_mm_abist_di_0_oiu               => pc_mm_abist_di_0_oiu,
     pc_mm_abist_ena_dc_oiu             => pc_mm_abist_ena_dc_oiu,
     pc_mm_abist_g6t_r_wb_oiu           => pc_mm_abist_g6t_r_wb_oiu,
     pc_mm_abist_g8t_bw_0_oiu           => pc_mm_abist_g8t_bw_0_oiu,
     pc_mm_abist_g8t_bw_1_oiu           => pc_mm_abist_g8t_bw_1_oiu,
     pc_mm_abist_g8t_dcomp_oiu          => pc_mm_abist_g8t_dcomp_oiu,
     pc_mm_abist_g8t_wenb_oiu           => pc_mm_abist_g8t_wenb_oiu,
     pc_mm_abist_g8t1p_renb_0_oiu       => pc_mm_abist_g8t1p_renb_0_oiu,
     pc_mm_abist_raddr_0_oiu            => pc_mm_abist_raddr_0_oiu,
     pc_mm_abist_raw_dc_b_oiu           => pc_mm_abist_raw_dc_b_oiu,
     pc_mm_abist_waddr_0_oiu            => pc_mm_abist_waddr_0_oiu,
     pc_mm_abist_wl128_comp_ena_oiu     => pc_mm_abist_wl128_comp_ena_oiu,
     pc_mm_abst_sl_thold_3_oiu          => pc_mm_abst_sl_thold_3_oiu,
     pc_mm_abst_slp_sl_thold_3_oiu      => pc_mm_abst_slp_sl_thold_3_oiu,
     pc_mm_ary_nsl_thold_3_oiu          => pc_mm_ary_nsl_thold_3_oiu,
     pc_mm_ary_slp_nsl_thold_3_oiu      => pc_mm_ary_slp_nsl_thold_3_oiu,
     pc_mm_bo_enable_3_oiu              => pc_mm_bo_enable_3_oiu,
     pc_mm_bo_repair_oiu                => pc_mm_bo_repair_oiu,
     pc_mm_bo_reset_oiu                 => pc_mm_bo_reset_oiu,
     pc_mm_bo_select_oiu                => pc_mm_bo_select_oiu,
     pc_mm_bo_shdata_oiu                => pc_mm_bo_shdata_oiu,
     pc_mm_bo_unload_oiu                => pc_mm_bo_unload_oiu,
     pc_mm_bolt_sl_thold_3_oiu          => pc_mm_bolt_sl_thold_3_oiu,
     pc_mm_ccflush_dc_oiu               => pc_mm_ccflush_dc_oiu,
     pc_mm_cfg_sl_thold_3_oiu           => pc_mm_cfg_sl_thold_3_oiu,
     pc_mm_cfg_slp_sl_thold_3_oiu       => pc_mm_cfg_slp_sl_thold_3_oiu,
     pc_mm_debug_mux1_ctrls_oiu         => pc_mm_debug_mux1_ctrls_oiu,
     pc_mm_event_count_mode_oiu         => pc_mm_event_count_mode_oiu,
     pc_mm_event_mux_ctrls_oiu          => pc_mm_event_mux_ctrls_oiu,
     pc_mm_fce_3_oiu                    => pc_mm_fce_3_oiu,
     pc_mm_func_nsl_thold_3_oiu         => pc_mm_func_nsl_thold_3_oiu,
     pc_mm_func_sl_thold_3_oiu          => pc_mm_func_sl_thold_3_oiu,
     pc_mm_func_slp_nsl_thold_3_oiu     => pc_mm_func_slp_nsl_thold_3_oiu,
     pc_mm_func_slp_sl_thold_3_oiu      => pc_mm_func_slp_sl_thold_3_oiu,
     pc_mm_gptr_sl_thold_3_oiu          => pc_mm_gptr_sl_thold_3_oiu,
     pc_mm_repr_sl_thold_3_oiu          => pc_mm_repr_sl_thold_3_oiu,
     pc_mm_sg_3_oiu                     => pc_mm_sg_3_oiu,
     pc_mm_time_sl_thold_3_oiu          => pc_mm_time_sl_thold_3_oiu,
     pc_mm_trace_bus_enable_oiu         => pc_mm_trace_bus_enable_oiu,
     an_ac_back_inv_oiu                 => an_ac_back_inv_oiu,
     an_ac_back_inv_addr_oiu            => an_ac_back_inv_addr_oiu,
     an_ac_back_inv_target_bit1_oiu     => an_ac_back_inv_target_bit1_oiu,
     an_ac_back_inv_target_bit3_oiu     => an_ac_back_inv_target_bit3_oiu,
     an_ac_back_inv_target_bit4_oiu     => an_ac_back_inv_target_bit4_oiu,
     an_ac_atpg_en_dc_oiu               => an_ac_atpg_en_dc_oiu,
     an_ac_lbist_ary_wrt_thru_dc_oiu    => an_ac_lbist_ary_wrt_thru_dc_oiu,
     an_ac_lbist_en_dc_oiu              => an_ac_lbist_en_dc_oiu,
     an_ac_scan_diag_dc_oiu             => an_ac_scan_diag_dc_oiu,
     an_ac_scan_dis_dc_b_oiu            => an_ac_scan_dis_dc_b_oiu,
     an_ac_grffence_en_dc_oiu           => an_ac_grffence_en_dc_oiu,
     an_ac_sync_ack             => an_ac_sync_ack,
     mm_iu_barrier_done         => mm_iu_barrier_done,
     an_ac_scan_dis_dc_b_oif    => an_ac_scan_dis_dc_b_oif,
     an_ac_back_inv_oif         => an_ac_back_inv_oif,
     an_ac_back_inv_target_oif  => an_ac_back_inv_target_oif,
     an_ac_sync_ack_oif         => an_ac_sync_ack_oif,
     mm_iu_barrier_done_oif     => mm_iu_barrier_done_oif,
     pc_iu_sg_2                 => pc_iu_sg_2,
     pc_iu_func_sl_thold_2      => pc_iu_func_sl_thold_2,
     clkoff_b                   => clkoff_b,
     delay_lclkr                => delay_lclkr,
     mpw1_b                     => mpw1_b,
     fiss_dbg_data              => fiss_dbg_data,
     fdep_dbg_data              => fdep_dbg_data_pt_out,
     ib_dbg_data                => ib_dbg_data,
     fu_iss_dbg_data            => fu_iss_dbg_data,
     axu_dbg_data_t0            => axu_dbg_data_t0,
     axu_dbg_data_t1            => axu_dbg_data_t1,
     axu_dbg_data_t2            => axu_dbg_data_t2,
     axu_dbg_data_t3            => axu_dbg_data_t3,
     ib_perf_event_t0           => ib_perf_event_t0,
     ib_perf_event_t1           => ib_perf_event_t1,
     ib_perf_event_t2           => ib_perf_event_t2,
     ib_perf_event_t3           => ib_perf_event_t3,
     fdep_perf_event_t0         => fdep_perf_event_pt_out_t0,
     fdep_perf_event_t1         => fdep_perf_event_pt_out_t1,
     fdep_perf_event_t2         => fdep_perf_event_pt_out_t2,
     fdep_perf_event_t3         => fdep_perf_event_pt_out_t3,
     fiss_perf_event_t0         => fiss_perf_event_t0,
     fiss_perf_event_t1         => fiss_perf_event_t1,
     fiss_perf_event_t2         => fiss_perf_event_t2,
     fiss_perf_event_t3         => fiss_perf_event_t3,
     ib_ic_empty                => ib_ic_empty,
     ib_ic_below_water          => ib_ic_below_water,
     ib_ic_iu5_redirect_tid     => ib_ic_iu5_redirect_tid,
     bp_ib_iu4_t0_val           => bp_ib_iu4_t0_val,
     bp_ib_iu4_t1_val           => bp_ib_iu4_t1_val,
     bp_ib_iu4_t2_val           => bp_ib_iu4_t2_val,
     bp_ib_iu4_t3_val           => bp_ib_iu4_t3_val,
     bp_ib_iu4_ifar_t0          => bp_ib_iu4_ifar_t0,
     bp_ib_iu3_0_instr_t0       => bp_ib_iu3_0_instr_t0,
     bp_ib_iu4_0_instr_t0       => bp_ib_iu4_0_instr_t0,
     bp_ib_iu4_1_instr_t0       => bp_ib_iu4_1_instr_t0,
     bp_ib_iu4_2_instr_t0       => bp_ib_iu4_2_instr_t0,
     bp_ib_iu4_3_instr_t0       => bp_ib_iu4_3_instr_t0,
     bp_ib_iu4_ifar_t1          => bp_ib_iu4_ifar_t1,
     bp_ib_iu3_0_instr_t1       => bp_ib_iu3_0_instr_t1,
     bp_ib_iu4_0_instr_t1       => bp_ib_iu4_0_instr_t1,
     bp_ib_iu4_1_instr_t1       => bp_ib_iu4_1_instr_t1,
     bp_ib_iu4_2_instr_t1       => bp_ib_iu4_2_instr_t1,
     bp_ib_iu4_3_instr_t1       => bp_ib_iu4_3_instr_t1,
     bp_ib_iu4_ifar_t2          => bp_ib_iu4_ifar_t2,
     bp_ib_iu3_0_instr_t2       => bp_ib_iu3_0_instr_t2,
     bp_ib_iu4_0_instr_t2       => bp_ib_iu4_0_instr_t2,
     bp_ib_iu4_1_instr_t2       => bp_ib_iu4_1_instr_t2,
     bp_ib_iu4_2_instr_t2       => bp_ib_iu4_2_instr_t2,
     bp_ib_iu4_3_instr_t2       => bp_ib_iu4_3_instr_t2,
     bp_ib_iu4_ifar_t3          => bp_ib_iu4_ifar_t3,
     bp_ib_iu3_0_instr_t3       => bp_ib_iu3_0_instr_t3,
     bp_ib_iu4_0_instr_t3       => bp_ib_iu4_0_instr_t3,
     bp_ib_iu4_1_instr_t3       => bp_ib_iu4_1_instr_t3,
     bp_ib_iu4_2_instr_t3       => bp_ib_iu4_2_instr_t3,
     bp_ib_iu4_3_instr_t3       => bp_ib_iu4_3_instr_t3,
     uc_ib_iu4_val              => uc_ib_iu4_val,
     uc_ib_iu4_ifar_t0          => uc_ib_iu4_ifar_t0,
     uc_ib_iu4_instr_t0         => uc_ib_iu4_instr_t0,
     uc_ib_iu4_ifar_t1          => uc_ib_iu4_ifar_t1,
     uc_ib_iu4_instr_t1         => uc_ib_iu4_instr_t1,
     uc_ib_iu4_ifar_t2          => uc_ib_iu4_ifar_t2,
     uc_ib_iu4_instr_t2         => uc_ib_iu4_instr_t2,
     uc_ib_iu4_ifar_t3          => uc_ib_iu4_ifar_t3,
     uc_ib_iu4_instr_t3         => uc_ib_iu4_instr_t3,
     rm_ib_iu4_val              => rm_ib_iu4_val,
     rm_ib_iu4_force_ram_t0     => rm_ib_iu4_force_ram_t0,
     rm_ib_iu4_instr_t0         => rm_ib_iu4_instr_t0,
     rm_ib_iu4_force_ram_t1     => rm_ib_iu4_force_ram_t1,
     rm_ib_iu4_instr_t1         => rm_ib_iu4_instr_t1,
     rm_ib_iu4_force_ram_t2     => rm_ib_iu4_force_ram_t2,
     rm_ib_iu4_instr_t2         => rm_ib_iu4_instr_t2,
     rm_ib_iu4_force_ram_t3     => rm_ib_iu4_force_ram_t3,
     rm_ib_iu4_instr_t3         => rm_ib_iu4_instr_t3,
     iu_au_config_iucr_t0       => iu_au_config_iucr_t0,
     iu_au_config_iucr_t1       => iu_au_config_iucr_t1,
     iu_au_config_iucr_t2       => iu_au_config_iucr_t2,
     iu_au_config_iucr_t3       => iu_au_config_iucr_t3,
     spr_issue_high_mask        => spr_issue_high_mask,
     spr_issue_med_mask         => spr_issue_med_mask,
     spr_fiss_count0_max        => spr_fiss_count0_max,
     spr_fiss_count1_max        => spr_fiss_count1_max,
     spr_fiss_count2_max        => spr_fiss_count2_max,
     spr_fiss_count3_max        => spr_fiss_count3_max,
     spr_fiss_pri_rand          => spr_fiss_pri_rand,
     spr_fiss_pri_rand_always   => spr_fiss_pri_rand_always,
     spr_fiss_pri_rand_flush    => spr_fiss_pri_rand_flush,
     spr_dec_mask_t0            => spr_dec_mask_pt_in_t0,
     spr_dec_mask_t1            => spr_dec_mask_pt_in_t1,
     spr_dec_mask_t2            => spr_dec_mask_pt_in_t2,
     spr_dec_mask_t3            => spr_dec_mask_pt_in_t3,
     spr_dec_match_t0           => spr_dec_match_t0,
     spr_dec_match_t1           => spr_dec_match_t1,
     spr_dec_match_t2           => spr_dec_match_t2,
     spr_dec_match_t3           => spr_dec_match_t3,
     spr_fdep_ll_hold_t0        => spr_fdep_ll_hold_t0,
     spr_fdep_ll_hold_t1        => spr_fdep_ll_hold_t1,
     spr_fdep_ll_hold_t2        => spr_fdep_ll_hold_t2,
     spr_fdep_ll_hold_t3        => spr_fdep_ll_hold_t3,
     ic_fdep_load_quiesce       => ic_fdep_load_quiesce,
     ic_fdep_icbi_ack           => ic_fdep_icbi_ack,
     fiss_uc_is2_ucode_vld      => fiss_uc_is2_ucode_vld,
     fiss_uc_is2_tid            => fiss_uc_is2_tid,
     fiss_uc_is2_instr          => fiss_uc_is2_instr,
     fiss_uc_is2_2ucode         => fiss_uc_is2_2ucode,
     fiss_uc_is2_2ucode_type    => fiss_uc_is2_2ucode_type,
     uc_flush_tid               => uc_flush_tid
);
iuq_ib_buff_wrap0 : entity work.iuq_ib_buff_wrap
generic map(expand_type         => expand_type,
            uc_ifar             => uc_ifar)
port map(
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     pc_iu_func_sl_thold_2      => pc_iu_func_sl_thold_2,    
     pc_iu_sg_2                 => pc_iu_sg_2,          
     clkoff_b                   => clkoff_b,            
     an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b_oif,
     tc_ac_ccflush_dc           => tc_ac_ccflush_dc,
     delay_lclkr                => delay_lclkr(5 to 8),
     mpw1_b                     => mpw1_b(5 to 8),
     iuq_b0_scan_in             => iuq_b0_scan_in,
     iuq_b0_scan_out            => iuq_b0_scan_out,
     iuq_b1_scan_in             => iuq_b1_scan_in,
     iuq_b1_scan_out            => iuq_b1_scan_out,
     iuq_b2_scan_in             => iuq_b2_scan_in,
     iuq_b2_scan_out            => iuq_b2_scan_out,
     iuq_b3_scan_in             => iuq_b3_scan_in,
     iuq_b3_scan_out            => iuq_b3_scan_out,

     spr_dec_mask_pt_in_t0      => spr_dec_mask_pt_in_t0,
     spr_dec_mask_pt_in_t1      => spr_dec_mask_pt_in_t1,
     spr_dec_mask_pt_in_t2      => spr_dec_mask_pt_in_t2,
     spr_dec_mask_pt_in_t3      => spr_dec_mask_pt_in_t3,
     spr_dec_mask_pt_out_t0     => spr_dec_mask_pt_out_t0,
     spr_dec_mask_pt_out_t1     => spr_dec_mask_pt_out_t1,
     spr_dec_mask_pt_out_t2     => spr_dec_mask_pt_out_t2,
     spr_dec_mask_pt_out_t3     => spr_dec_mask_pt_out_t3,
     fdep_dbg_data_pt_in        => fdep_dbg_data_pt_in,
     fdep_dbg_data_pt_out       => fdep_dbg_data_pt_out,
     fdep_perf_event_pt_in_t0   => fdep_perf_event_pt_in_t0,
     fdep_perf_event_pt_in_t1   => fdep_perf_event_pt_in_t1,
     fdep_perf_event_pt_in_t2   => fdep_perf_event_pt_in_t2,
     fdep_perf_event_pt_in_t3   => fdep_perf_event_pt_in_t3,
     fdep_perf_event_pt_out_t0  => fdep_perf_event_pt_out_t0,
     fdep_perf_event_pt_out_t1  => fdep_perf_event_pt_out_t1,
     fdep_perf_event_pt_out_t2  => fdep_perf_event_pt_out_t2,
     fdep_perf_event_pt_out_t3  => fdep_perf_event_pt_out_t3,

     pc_iu_trace_bus_enable     => pc_iu_trace_bus_enable,
     pc_iu_event_bus_enable     => pc_iu_event_bus_enable,
     ib_dbg_data                => ib_dbg_data,
     ib_perf_event_t0           => ib_perf_event_t0,
     ib_perf_event_t1           => ib_perf_event_t1,
     ib_perf_event_t2           => ib_perf_event_t2,
     ib_perf_event_t3           => ib_perf_event_t3,
     xu_iu_flush                => xu_iu_u_flush,
     uc_flush_tid               => uc_flush_tid,
     fdec_ibuf_stall_t0         => fdec_ibuf_stall_t0,
     fdec_ibuf_stall_t1         => fdec_ibuf_stall_t1,
     fdec_ibuf_stall_t2         => fdec_ibuf_stall_t2,
     fdec_ibuf_stall_t3         => fdec_ibuf_stall_t3,
     ib_ic_below_water          => ib_ic_below_water,
     ib_ic_empty                => ib_ic_empty,
     bp_ib_iu4_t0_val           => bp_ib_iu4_t0_val,
     bp_ib_iu4_t1_val           => bp_ib_iu4_t1_val,
     bp_ib_iu4_t2_val           => bp_ib_iu4_t2_val,
     bp_ib_iu4_t3_val           => bp_ib_iu4_t3_val,
     bp_ib_iu4_ifar_t0          => bp_ib_iu4_ifar_t0,
     bp_ib_iu3_0_instr_t0       => bp_ib_iu3_0_instr_t0,
     bp_ib_iu4_0_instr_t0       => bp_ib_iu4_0_instr_t0,
     bp_ib_iu4_1_instr_t0       => bp_ib_iu4_1_instr_t0,
     bp_ib_iu4_2_instr_t0       => bp_ib_iu4_2_instr_t0,
     bp_ib_iu4_3_instr_t0       => bp_ib_iu4_3_instr_t0,
     bp_ib_iu4_ifar_t1          => bp_ib_iu4_ifar_t1,
     bp_ib_iu3_0_instr_t1       => bp_ib_iu3_0_instr_t1,
     bp_ib_iu4_0_instr_t1       => bp_ib_iu4_0_instr_t1,
     bp_ib_iu4_1_instr_t1       => bp_ib_iu4_1_instr_t1,
     bp_ib_iu4_2_instr_t1       => bp_ib_iu4_2_instr_t1,
     bp_ib_iu4_3_instr_t1       => bp_ib_iu4_3_instr_t1,
     bp_ib_iu4_ifar_t2          => bp_ib_iu4_ifar_t2,
     bp_ib_iu3_0_instr_t2       => bp_ib_iu3_0_instr_t2,
     bp_ib_iu4_0_instr_t2       => bp_ib_iu4_0_instr_t2,
     bp_ib_iu4_1_instr_t2       => bp_ib_iu4_1_instr_t2,
     bp_ib_iu4_2_instr_t2       => bp_ib_iu4_2_instr_t2,
     bp_ib_iu4_3_instr_t2       => bp_ib_iu4_3_instr_t2,
     bp_ib_iu4_ifar_t3          => bp_ib_iu4_ifar_t3,
     bp_ib_iu3_0_instr_t3       => bp_ib_iu3_0_instr_t3,
     bp_ib_iu4_0_instr_t3       => bp_ib_iu4_0_instr_t3,
     bp_ib_iu4_1_instr_t3       => bp_ib_iu4_1_instr_t3,
     bp_ib_iu4_2_instr_t3       => bp_ib_iu4_2_instr_t3,
     bp_ib_iu4_3_instr_t3       => bp_ib_iu4_3_instr_t3,
     uc_ib_iu4_val              => uc_ib_iu4_val,
     uc_ib_iu4_ifar_t0          => uc_ib_iu4_ifar_t0,
     uc_ib_iu4_instr_t0         => uc_ib_iu4_instr_t0,
     uc_ib_iu4_ifar_t1          => uc_ib_iu4_ifar_t1,
     uc_ib_iu4_instr_t1         => uc_ib_iu4_instr_t1,
     uc_ib_iu4_ifar_t2          => uc_ib_iu4_ifar_t2,
     uc_ib_iu4_instr_t2         => uc_ib_iu4_instr_t2,
     uc_ib_iu4_ifar_t3          => uc_ib_iu4_ifar_t3,
     uc_ib_iu4_instr_t3         => uc_ib_iu4_instr_t3,
     rm_ib_iu4_val              => rm_ib_iu4_val,
     rm_ib_iu4_force_ram_t0     => rm_ib_iu4_force_ram_t0,
     rm_ib_iu4_instr_t0         => rm_ib_iu4_instr_t0,
     rm_ib_iu4_force_ram_t1     => rm_ib_iu4_force_ram_t1,
     rm_ib_iu4_instr_t1         => rm_ib_iu4_instr_t1,
     rm_ib_iu4_force_ram_t2     => rm_ib_iu4_force_ram_t2,
     rm_ib_iu4_instr_t2         => rm_ib_iu4_instr_t2,
     rm_ib_iu4_force_ram_t3     => rm_ib_iu4_force_ram_t3,
     rm_ib_iu4_instr_t3         => rm_ib_iu4_instr_t3,
     ib_ic_iu5_redirect_tid     => ib_ic_iu5_redirect_tid,
     iu_au_ib1_instr_vld_t0     => iu_au_ib1_instr_vld_t0,
     iu_au_ib1_instr_vld_t1     => iu_au_ib1_instr_vld_t1,
     iu_au_ib1_instr_vld_t2     => iu_au_ib1_instr_vld_t2,
     iu_au_ib1_instr_vld_t3     => iu_au_ib1_instr_vld_t3,
     iu_au_ib1_ifar_t0          => iu_au_ib1_ifar_t0,
     iu_au_ib1_ifar_t1          => iu_au_ib1_ifar_t1,
     iu_au_ib1_ifar_t2          => iu_au_ib1_ifar_t2,
     iu_au_ib1_ifar_t3          => iu_au_ib1_ifar_t3,
     iu_au_ib1_data_t0          => iu_au_ib1_data_t0,
     iu_au_ib1_data_t1          => iu_au_ib1_data_t1,
     iu_au_ib1_data_t2          => iu_au_ib1_data_t2,
     iu_au_ib1_data_t3          => iu_au_ib1_data_t3
);
iuq_slice_wrap0 : entity work.iuq_slice_wrap
generic map(expand_type           => expand_type,
            fpr_addr_width        => fpr_addr_width,
            regmode               => regmode,
            a2mode                => a2mode,
            lmq_entries           => lmq_entries)
port map(
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,
     pc_iu_func_sl_thold_2              => pc_iu_func_sl_thold_2,       
     pc_iu_sg_2                         => pc_iu_sg_2,                  
     clkoff_b                           => clkoff_b,                    
     an_ac_scan_dis_dc_b                => an_ac_scan_dis_dc_b_oif,
     tc_ac_ccflush_dc                   => tc_ac_ccflush_dc,
     delay_lclkr                        => delay_lclkr(9 to 14),
     mpw1_b                             => mpw1_b(9 to 14),
     iuq_s0_scan_in                     => iuq_s0_scan_in,
     iuq_s0_scan_out                    => iuq_s0_scan_out,
     iuq_s1_scan_in                     => iuq_s1_scan_in,
     iuq_s1_scan_out                    => iuq_s1_scan_out,
     iuq_s2_scan_in                     => iuq_s2_scan_in,
     iuq_s2_scan_out                    => iuq_s2_scan_out,
     iuq_s3_scan_in                     => iuq_s3_scan_in,
     iuq_s3_scan_out                    => iuq_s3_scan_out,
     pc_iu_ram_mode                     => pc_iu_ram_mode,
     pc_iu_ram_thread                   => pc_iu_ram_thread,
     pc_iu_trace_bus_enable             => pc_iu_trace_bus_enable,
     pc_iu_event_bus_enable             => pc_iu_event_bus_enable,
     fdep_dbg_data                      => fdep_dbg_data_pt_in,
     fdep_perf_event_t0                 => fdep_perf_event_pt_in_t0,
     fdep_perf_event_t1                 => fdep_perf_event_pt_in_t1,
     fdep_perf_event_t2                 => fdep_perf_event_pt_in_t2,
     fdep_perf_event_t3                 => fdep_perf_event_pt_in_t3,
     iu_au_config_iucr_t0               => iu_au_config_iucr_t0,
     iu_au_config_iucr_t1               => iu_au_config_iucr_t1,
     iu_au_config_iucr_t2               => iu_au_config_iucr_t2,
     iu_au_config_iucr_t3               => iu_au_config_iucr_t3,
     spr_dec_mask_t0                    => spr_dec_mask_pt_out_t0,
     spr_dec_mask_t1                    => spr_dec_mask_pt_out_t1,
     spr_dec_mask_t2                    => spr_dec_mask_pt_out_t2,
     spr_dec_mask_t3                    => spr_dec_mask_pt_out_t3,
     spr_dec_match_t0                   => spr_dec_match_t0,
     spr_dec_match_t1                   => spr_dec_match_t1,
     spr_dec_match_t2                   => spr_dec_match_t2,
     spr_dec_match_t3                   => spr_dec_match_t3,
     uc_flush_tid                       => uc_flush_tid,
     xu_iu_flush                        => xu_iu_u_flush,
     xu_rf1_flush                       => xu_wu_rf1_flush,
     xu_ex1_flush                       => xu_wu_ex1_flush,
     xu_ex2_flush                       => xu_wu_ex2_flush,
     xu_ex3_flush                       => xu_wu_ex3_flush,
     xu_ex4_flush                       => xu_wu_ex4_flush,
     xu_ex5_flush                       => xu_wu_ex5_flush,
     fdec_ibuf_stall_t0                 => fdec_ibuf_stall_t0,
     fdec_ibuf_stall_t1                 => fdec_ibuf_stall_t1,
     fdec_ibuf_stall_t2                 => fdec_ibuf_stall_t2,
     fdec_ibuf_stall_t3                 => fdec_ibuf_stall_t3,
     iu_au_ib1_instr_vld_t0             => iu_au_ib1_instr_vld_t0,
     iu_au_ib1_instr_vld_t1             => iu_au_ib1_instr_vld_t1,
     iu_au_ib1_instr_vld_t2             => iu_au_ib1_instr_vld_t2,
     iu_au_ib1_instr_vld_t3             => iu_au_ib1_instr_vld_t3,
     iu_au_ib1_ifar_t0                  => iu_au_ib1_ifar_t0,
     iu_au_ib1_ifar_t1                  => iu_au_ib1_ifar_t1,
     iu_au_ib1_ifar_t2                  => iu_au_ib1_ifar_t2,
     iu_au_ib1_ifar_t3                  => iu_au_ib1_ifar_t3,
     iu_au_ib1_data_t0                  => iu_au_ib1_data_t0,
     iu_au_ib1_data_t1                  => iu_au_ib1_data_t1,
     iu_au_ib1_data_t2                  => iu_au_ib1_data_t2,
     iu_au_ib1_data_t3                  => iu_au_ib1_data_t3,
     xu_iu_ucode_restart                => xu_iu_ucode_restart,
     xu_iu_slowspr_done                 => xu_iu_slowspr_done,
     xu_iu_multdiv_done                 => xu_iu_multdiv_done,
     xu_iu_ex4_loadmiss_tid             => xu_iu_ex4_loadmiss_tid,
     xu_iu_ex4_loadmiss_qentry          => xu_iu_ex4_loadmiss_qentry,
     xu_iu_ex4_loadmiss_target          => xu_iu_ex4_loadmiss_target,
     xu_iu_ex4_loadmiss_target_type     => xu_iu_ex4_loadmiss_target_type,
     xu_iu_ex5_loadmiss_tid             => xu_iu_ex5_loadmiss_tid,
     xu_iu_ex5_loadmiss_qentry          => xu_iu_ex5_loadmiss_qentry,
     xu_iu_ex5_loadmiss_target          => xu_iu_ex5_loadmiss_target(1 to 6),
     xu_iu_ex5_loadmiss_target_type     => xu_iu_ex5_loadmiss_target_type(0 to 0),
     xu_iu_complete_tid                 => xu_iu_complete_tid,
     xu_iu_complete_qentry              => xu_iu_complete_qentry,
     xu_iu_complete_target_type         => xu_iu_complete_target_type,
     ic_fdep_load_quiesce               => ic_fdep_load_quiesce,
     iu_xu_quiesce                      => iu_xu_quiesce,
     xu_iu_membar_tid                   => xu_iu_membar_tid,
     xu_iu_set_barr_tid                 => xu_iu_set_barr_tid,
     xu_iu_larx_done_tid                => xu_iu_larx_done_tid,
     an_ac_sync_ack                     => an_ac_sync_ack_oif,
     ic_fdep_icbi_ack                   => ic_fdep_icbi_ack,
     an_ac_stcx_complete                => an_ac_stcx_complete,
     mm_iu_barrier_done                 => mm_iu_barrier_done_oif,
     spr_fdep_ll_hold_t0                => spr_fdep_ll_hold_t0,
     spr_fdep_ll_hold_t1                => spr_fdep_ll_hold_t1,
     spr_fdep_ll_hold_t2                => spr_fdep_ll_hold_t2,
     spr_fdep_ll_hold_t3                => spr_fdep_ll_hold_t3,
     xu_iu_spr_ccr2_en_dcr              => xu_iu_spr_ccr2_en_dcr,
     xu_iu_single_instr_mode            => xu_iu_single_instr_mode,
     fu_iu_uc_special                   => fu_iu_uc_special,
     iu_fu_ex2_n_flush                  => iu_fu_ex2_n_flush,
     axu_dbg_data_t0                    => axu_dbg_data_t0,
     axu_dbg_data_t1                    => axu_dbg_data_t1,
     axu_dbg_data_t2                    => axu_dbg_data_t2,
     axu_dbg_data_t3                    => axu_dbg_data_t3,
     iuq_fi_scan_in                     => iuq_fi_scan_in,
     iuq_fi_scan_out                    => iuq_fi_scan_out,
     fiss_dbg_data                      => fiss_dbg_data,
     fiss_perf_event_t0                 => fiss_perf_event_t0,
     fiss_perf_event_t1                 => fiss_perf_event_t1,
     fiss_perf_event_t2                 => fiss_perf_event_t2,
     fiss_perf_event_t3                 => fiss_perf_event_t3,
     xu_iu_need_hole                    => xu_iu_need_hole,
     xu_iu_xucr0_rel                    => xu_iu_xucr0_rel,
     an_ac_reld_data_vld_clone          => an_ac_reld_data_vld_clone,
     an_ac_reld_core_tag_clone          => an_ac_reld_core_tag_clone(1 to 4),
     an_ac_reld_ditc_clone              => an_ac_reld_ditc_clone,
     an_ac_reld_data_coming_clone       => an_ac_reld_data_coming_clone,
     an_ac_back_inv                     => an_ac_back_inv_oif,
     an_ac_back_inv_target              => an_ac_back_inv_target_oif,
     fiss_uc_is2_ucode_vld              => fiss_uc_is2_ucode_vld,
     spr_issue_high_mask                => spr_issue_high_mask,
     spr_issue_med_mask                 => spr_issue_med_mask,
     spr_fiss_count0_max                => spr_fiss_count0_max,
     spr_fiss_count1_max                => spr_fiss_count1_max,
     spr_fiss_count2_max                => spr_fiss_count2_max,
     spr_fiss_count3_max                => spr_fiss_count3_max,
     spr_fiss_pri_rand                  => spr_fiss_pri_rand,
     spr_fiss_pri_rand_always           => spr_fiss_pri_rand_always,
     spr_fiss_pri_rand_flush            => spr_fiss_pri_rand_flush,
     xu_iu_ex5_ppc_cpl                  => xu_iu_ex5_ppc_cpl,
     iu_xu_is2_vld_internal             => iu_xu_is2_vld_internal,
     iu_xu_is2_tid_internal             => iu_xu_is2_tid_internal,
     iu_xu_is2_instr_internal           => iu_xu_is2_instr_internal,
     iu_xu_is2_ta_vld                   => iu_xu_is2_ta_vld,
     iu_xu_is2_ta                       => iu_xu_is2_ta,
     iu_xu_is2_s1_vld                   => iu_xu_is2_s1_vld,
     iu_xu_is2_s1                       => iu_xu_is2_s1,
     iu_xu_is2_s2_vld                   => iu_xu_is2_s2_vld,
     iu_xu_is2_s2                       => iu_xu_is2_s2,
     iu_xu_is2_s3_vld                   => iu_xu_is2_s3_vld,
     iu_xu_is2_s3                       => iu_xu_is2_s3,
     iu_xu_is2_pred_update_internal     => iu_xu_is2_pred_update_internal,
     iu_xu_is2_pred_taken_cnt_internal  => iu_xu_is2_pred_taken_cnt_internal,
     iu_xu_is2_gshare                   => iu_xu_is2_gshare,
     iu_xu_is2_ifar_internal            => iu_xu_is2_ifar_internal,
     iu_xu_is2_error_internal           => iu_xu_is2_error_internal,
     iu_xu_is2_is_ucode                 => iu_xu_is2_is_ucode,
     iu_xu_is2_axu_ld_or_st             => iu_xu_is2_axu_ld_or_st,
     iu_xu_is2_axu_store_internal       => iu_xu_is2_axu_store_internal,
     iu_xu_is2_axu_ldst_indexed         => iu_xu_is2_axu_ldst_indexed,
     iu_xu_is2_axu_ldst_tag             => iu_xu_is2_axu_ldst_tag,
     iu_xu_is2_axu_ldst_size            => iu_xu_is2_axu_ldst_size,
     iu_xu_is2_axu_ldst_update          => iu_xu_is2_axu_ldst_update,
     iu_xu_is2_axu_ldst_extpid          => iu_xu_is2_axu_ldst_extpid,
     iu_xu_is2_axu_ldst_forcealign      => iu_xu_is2_axu_ldst_forcealign,
     iu_xu_is2_axu_ldst_forceexcept     => iu_xu_is2_axu_ldst_forceexcept,
     iu_xu_is2_axu_mftgpr               => iu_xu_is2_axu_mftgpr,
     iu_xu_is2_axu_mffgpr               => iu_xu_is2_axu_mffgpr,
     iu_xu_is2_axu_movedp               => iu_xu_is2_axu_movedp,
     iu_xu_is2_axu_instr_type           => iu_xu_is2_axu_instr_type,
     iu_xu_is2_match                    => iu_xu_is2_match,
     fiss_uc_is2_2ucode                 => fiss_uc_is2_2ucode,
     fiss_uc_is2_2ucode_type            => fiss_uc_is2_2ucode_type,
     iu_fu_rf0_str_val                  => iu_fu_rf0_str_val,
     iu_fu_rf0_ldst_val                 => iu_fu_rf0_ldst_val,
     iu_fu_rf0_ldst_tid                 => iu_fu_rf0_ldst_tid,
     iu_fu_rf0_ldst_tag                 => iu_fu_rf0_ldst_tag,
     iuq_ai_scan_in                     => iuq_ai_scan_in,
     iuq_ai_scan_out                    => iuq_ai_scan_out,
     iu_fu_is2_tid_decode               => iu_fu_is2_tid_decode,
     iu_fu_rf0_instr_match              => iu_fu_rf0_instr_match,
     iu_fu_rf0_instr                    => iu_fu_rf0_instr,
     iu_fu_rf0_instr_v                  => iu_fu_rf0_instr_v,
     iu_fu_rf0_is_ucode                 => iu_fu_rf0_is_ucode,
     iu_fu_rf0_fra                      => iu_fu_rf0_fra,
     iu_fu_rf0_frb                      => iu_fu_rf0_frb,
     iu_fu_rf0_frc                      => iu_fu_rf0_frc,
     iu_fu_rf0_frt                      => iu_fu_rf0_frt,
     iu_fu_rf0_fra_v                    => iu_fu_rf0_fra_v,
     iu_fu_rf0_frb_v                    => iu_fu_rf0_frb_v,
     iu_fu_rf0_frc_v                    => iu_fu_rf0_frc_v,
     iu_fu_rf0_ucfmul                   => iu_fu_rf0_ucfmul,
     fu_iss_dbg_data                    => fu_iss_dbg_data,
     iu_fu_rf0_tid                      => iu_fu_rf0_tid,
     iu_fu_rf0_bypsel                   => iu_fu_rf0_bypsel,
     iu_fu_rf0_ifar                     => iu_fu_rf0_ifar
);
iu_xu_is2_vld                   <= iu_xu_is2_vld_internal;
iu_xu_is2_instr(0 to 31)        <= iu_xu_is2_instr_internal(0 to 31);
iu_xu_is2_tid(0 to 3)           <= iu_xu_is2_tid_internal(0 to 3);
iu_xu_is2_axu_store             <= iu_xu_is2_axu_store_internal;
iu_xu_is2_error(0 to 2)         <= iu_xu_is2_error_internal(0 to 2);
iu_xu_is2_ifar                  <= iu_xu_is2_ifar_internal;
iu_xu_is2_pred_update           <= iu_xu_is2_pred_update_internal;
iu_xu_is2_pred_taken_cnt(0 to 1)<= iu_xu_is2_pred_taken_cnt_internal(0 to 1);
fiss_uc_is2_instr(0 to 31)      <= iu_xu_is2_instr_internal(0 to 31);
fiss_uc_is2_tid(0 to 3)         <= iu_xu_is2_tid_internal(0 to 3);
iu_xu_is2_ucode_vld             <= fiss_uc_is2_ucode_vld;
---------------------------------------
-- scan chains
---------------------------------------
iuq_b0_scan_in          <= iuq_bp_scan_out;
iu_func_scan_out(0)     <= iuq_b0_scan_out;
iuq_b1_scan_in          <= iuq_mi_scan_out(0);
iu_func_scan_out(1)     <= iuq_b1_scan_out;
iuq_fi_scan_in          <= iu_func_scan_in_q(0);
iuq_ai_scan_in          <= iuq_fi_scan_out;
iuq_b2_scan_in          <= iuq_ai_scan_out;
iu_func_scan_out(2)     <= iuq_b2_scan_out;
iuq_b3_scan_in          <= iuq_mi_scan_out(1);
iu_func_scan_out(3)     <= iuq_b3_scan_out;
iuq_s0_scan_in          <= iu_func_scan_in_q(1);
iu_func_scan_out(4)     <= iuq_s0_scan_out;
iuq_s1_scan_in          <= iu_func_scan_in_q(2);
iu_func_scan_out(5)     <= iuq_s1_scan_out;
iuq_s2_scan_in          <= iu_func_scan_in_q(3);
iu_func_scan_out(6)     <= iuq_s2_scan_out;
iuq_s3_scan_in          <= iu_func_scan_in_q(4);
iu_func_scan_out(7)     <= iuq_s3_scan_out;
end iuq;
