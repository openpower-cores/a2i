-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

			

--********************************************************************
--*
--* TITLE: Instruction Fetch RLM
--*
--* NAME: iuq_ifetch.vhdl
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

entity iuq_ifetch is
  generic(expand_type           : integer := 2;
          a2mode                : integer := 1;
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
     pc_iu_abist_raddr_0        : in  std_ulogic_vector(2 to 9);
     pc_iu_abist_raw_dc_b       : in  std_ulogic;
     pc_iu_abist_waddr_0        : in  std_ulogic_vector(3 to 9);
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


     iuq_mi_scan_out            : out std_ulogic_vector(0 to 1);
     iuq_bp_scan_out            : out std_ulogic;       

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
     xu_iu_flush                : in  std_ulogic_vector(0 to 3);
     xu_iu_iu0_flush_ifar0      : in  EFF_IFAR;
     xu_iu_iu0_flush_ifar1      : in  EFF_IFAR;
     xu_iu_iu0_flush_ifar2      : in  EFF_IFAR;
     xu_iu_iu0_flush_ifar3      : in  EFF_IFAR;
     xu_iu_flush_2ucode         : in  std_ulogic_vector(0 to 3);
     xu_iu_flush_2ucode_type    : in  std_ulogic_vector(0 to 3);
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
     an_ac_reld_core_tag        : in  std_ulogic_vector(0 to 4);
     an_ac_reld_qw              : in  std_ulogic_vector(57 to 59);
     an_ac_reld_data            : in  std_ulogic_vector(0 to 127);
     an_ac_reld_ecc_err         : in  std_ulogic;
     an_ac_reld_ecc_err_ue      : in  std_ulogic;
     an_ac_back_inv             : in  std_ulogic;
     an_ac_back_inv_addr        : in  std_ulogic_vector(REAL_IFAR'left to 63);  
     an_ac_back_inv_target_iiu_a: in  std_ulogic_vector(0 to 1);        
     an_ac_back_inv_target_iiu_b: in  std_ulogic_vector(3 to 4);
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
     iu_mm_lmq_empty            : out std_ulogic;

     xu_iu_ex1_rb               : in  std_ulogic_vector(64-(2**regmode) to 51);
     xu_rf1_flush               : in  std_ulogic_vector(0 to 3);
     xu_ex1_flush               : in  std_ulogic_vector(0 to 3);
     xu_ex2_flush               : in  std_ulogic_vector(0 to 3);
     xu_ex3_flush               : in  std_ulogic_vector(0 to 3);
     xu_ex4_flush               : in  std_ulogic_vector(0 to 3);
     xu_ex5_flush               : in  std_ulogic_vector(0 to 3);
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
     iu_func_scan_in_q          : out std_ulogic_vector(0 to 4);
     iu_func_scan_out           : in  std_ulogic_vector(0 to 7);
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
     an_ac_grffence_en_dc_oiu           : out std_ulogic;

     an_ac_sync_ack             : in  std_ulogic_vector(0 to 3);
     mm_iu_barrier_done         : in  std_ulogic_vector(0 to 3);

     an_ac_scan_dis_dc_b_oif    : out std_ulogic_vector(0 to 3);
     an_ac_back_inv_oif         : out std_ulogic;
     an_ac_back_inv_target_oif  : out std_ulogic_vector(1 to 1);
     an_ac_sync_ack_oif         : out std_ulogic_vector(0 to 3);
     mm_iu_barrier_done_oif     : out std_ulogic_vector(0 to 3);

     pc_iu_sg_2                 : out std_ulogic_vector(0 to 3);
     pc_iu_func_sl_thold_2      : out std_ulogic_vector(0 to 3);

     clkoff_b                   : out std_ulogic_vector(0 to 3);
     delay_lclkr                : out std_ulogic_vector(5 to 14);
     mpw1_b                     : out std_ulogic_vector(5 to 14);

     fiss_dbg_data              : in std_ulogic_vector(0 to 87);
     fdep_dbg_data              : in std_ulogic_vector(0 to 87);
     ib_dbg_data                : in std_ulogic_vector(0 to 63);
     fu_iss_dbg_data            : in std_ulogic_vector(0 to 23);
     axu_dbg_data_t0            : in std_ulogic_vector(0 to 37);
     axu_dbg_data_t1            : in std_ulogic_vector(0 to 37);
     axu_dbg_data_t2            : in std_ulogic_vector(0 to 37);
     axu_dbg_data_t3            : in std_ulogic_vector(0 to 37);

     ib_perf_event_t0           : in std_ulogic_vector(0 to 1);
     ib_perf_event_t1           : in std_ulogic_vector(0 to 1);
     ib_perf_event_t2           : in std_ulogic_vector(0 to 1);
     ib_perf_event_t3           : in std_ulogic_vector(0 to 1);
     fdep_perf_event_t0         : in std_ulogic_vector(0 to 11);
     fdep_perf_event_t1         : in std_ulogic_vector(0 to 11);
     fdep_perf_event_t2         : in std_ulogic_vector(0 to 11);
     fdep_perf_event_t3         : in std_ulogic_vector(0 to 11);
     fiss_perf_event_t0         : in std_ulogic_vector(0 to 7);
     fiss_perf_event_t1         : in std_ulogic_vector(0 to 7);
     fiss_perf_event_t2         : in std_ulogic_vector(0 to 7);
     fiss_perf_event_t3         : in std_ulogic_vector(0 to 7);

     ib_ic_empty                : in  std_ulogic_vector(0 to 3);
     ib_ic_below_water          : in  std_ulogic_vector(0 to 3);
     ib_ic_iu5_redirect_tid     : in  std_ulogic_vector(0 to 3);

     bp_ib_iu4_t0_val           : out std_ulogic_vector(0 to 3);
     bp_ib_iu4_t1_val           : out std_ulogic_vector(0 to 3);
     bp_ib_iu4_t2_val           : out std_ulogic_vector(0 to 3);
     bp_ib_iu4_t3_val           : out std_ulogic_vector(0 to 3);
     bp_ib_iu4_ifar_t0          : out EFF_IFAR;
     bp_ib_iu3_0_instr_t0       : out std_ulogic_vector(0 to 31);
     bp_ib_iu4_0_instr_t0       : out std_ulogic_vector(32 to 43);
     bp_ib_iu4_1_instr_t0       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_2_instr_t0       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_3_instr_t0       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_ifar_t1          : out EFF_IFAR;
     bp_ib_iu3_0_instr_t1       : out std_ulogic_vector(0 to 31);
     bp_ib_iu4_0_instr_t1       : out std_ulogic_vector(32 to 43);
     bp_ib_iu4_1_instr_t1       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_2_instr_t1       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_3_instr_t1       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_ifar_t2          : out EFF_IFAR;
     bp_ib_iu3_0_instr_t2       : out std_ulogic_vector(0 to 31);
     bp_ib_iu4_0_instr_t2       : out std_ulogic_vector(32 to 43);
     bp_ib_iu4_1_instr_t2       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_2_instr_t2       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_3_instr_t2       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_ifar_t3          : out EFF_IFAR;
     bp_ib_iu3_0_instr_t3       : out std_ulogic_vector(0 to 31);
     bp_ib_iu4_0_instr_t3       : out std_ulogic_vector(32 to 43);
     bp_ib_iu4_1_instr_t3       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_2_instr_t3       : out std_ulogic_vector(0 to 43);
     bp_ib_iu4_3_instr_t3       : out std_ulogic_vector(0 to 43);

     uc_ib_iu4_val              : out std_ulogic_vector(0 to 3);
     uc_ib_iu4_ifar_t0          : out std_ulogic_vector(62-uc_ifar to 61);
     uc_ib_iu4_instr_t0         : out std_ulogic_vector(0 to 36);
     uc_ib_iu4_ifar_t1          : out std_ulogic_vector(62-uc_ifar to 61);
     uc_ib_iu4_instr_t1         : out std_ulogic_vector(0 to 36);
     uc_ib_iu4_ifar_t2          : out std_ulogic_vector(62-uc_ifar to 61);
     uc_ib_iu4_instr_t2         : out std_ulogic_vector(0 to 36);
     uc_ib_iu4_ifar_t3          : out std_ulogic_vector(62-uc_ifar to 61);
     uc_ib_iu4_instr_t3         : out std_ulogic_vector(0 to 36);

     rm_ib_iu4_val              : out std_ulogic_vector(0 to 3);
     rm_ib_iu4_force_ram_t0     : out std_ulogic;
     rm_ib_iu4_instr_t0         : out std_ulogic_vector(0 to 35);
     rm_ib_iu4_force_ram_t1     : out std_ulogic;
     rm_ib_iu4_instr_t1         : out std_ulogic_vector(0 to 35);
     rm_ib_iu4_force_ram_t2     : out std_ulogic;
     rm_ib_iu4_instr_t2         : out std_ulogic_vector(0 to 35);
     rm_ib_iu4_force_ram_t3     : out std_ulogic;
     rm_ib_iu4_instr_t3         : out std_ulogic_vector(0 to 35);

     iu_au_config_iucr_t0       : out std_ulogic_vector(0 to 7);
     iu_au_config_iucr_t1       : out std_ulogic_vector(0 to 7);
     iu_au_config_iucr_t2       : out std_ulogic_vector(0 to 7);
     iu_au_config_iucr_t3       : out std_ulogic_vector(0 to 7);

     spr_issue_high_mask        : out std_ulogic_vector(0 to 3);
     spr_issue_med_mask         : out std_ulogic_vector(0 to 3);
     spr_fiss_count0_max        : out std_ulogic_vector(0 to 5);
     spr_fiss_count1_max        : out std_ulogic_vector(0 to 5);
     spr_fiss_count2_max        : out std_ulogic_vector(0 to 5);
     spr_fiss_count3_max        : out std_ulogic_vector(0 to 5);
     spr_fiss_pri_rand          : out std_ulogic_vector(0 to 4);
     spr_fiss_pri_rand_always   : out std_ulogic;
     spr_fiss_pri_rand_flush    : out std_ulogic;
     spr_dec_mask_t0            : out std_ulogic_vector(0 to 31);
     spr_dec_mask_t1            : out std_ulogic_vector(0 to 31);
     spr_dec_mask_t2            : out std_ulogic_vector(0 to 31);
     spr_dec_mask_t3            : out std_ulogic_vector(0 to 31);
     spr_dec_match_t0           : out std_ulogic_vector(0 to 31);
     spr_dec_match_t1           : out std_ulogic_vector(0 to 31);
     spr_dec_match_t2           : out std_ulogic_vector(0 to 31);
     spr_dec_match_t3           : out std_ulogic_vector(0 to 31);
     spr_fdep_ll_hold_t0        : out std_ulogic;
     spr_fdep_ll_hold_t1        : out std_ulogic;
     spr_fdep_ll_hold_t2        : out std_ulogic;
     spr_fdep_ll_hold_t3        : out std_ulogic;

     ic_fdep_load_quiesce       : out std_ulogic_vector(0 to 3);
     ic_fdep_icbi_ack           : out std_ulogic_vector(0 to 3);

     fiss_uc_is2_ucode_vld      : in std_ulogic;
     fiss_uc_is2_tid            : in std_ulogic_vector(0 to 3);
     fiss_uc_is2_instr          : in std_ulogic_vector(0 to 31);
     fiss_uc_is2_2ucode         : in std_ulogic;
     fiss_uc_is2_2ucode_type    : in std_ulogic;

     uc_flush_tid               : out std_ulogic_vector(0 to 3)

);
-- synopsys translate_off
-- synopsys translate_on
end iuq_ifetch;
architecture iuq_ifetch of iuq_ifetch is
signal int_clkoff_b             : std_ulogic_vector(0 to 2);
signal int_delay_lclkr          : std_ulogic_vector(1 to 14);
signal int_mpw1_b               : std_ulogic_vector(1 to 14);
signal g8t_clkoff_b             : std_ulogic;
signal g8t_d_mode               : std_ulogic;
signal g8t_delay_lclkr          : std_ulogic_vector(0 to 4);
signal g8t_mpw1_b               : std_ulogic_vector(0 to 4);
signal g8t_mpw2_b               : std_ulogic;
signal g6t_clkoff_b             : std_ulogic;
signal g6t_d_mode               : std_ulogic;
signal g6t_delay_lclkr          : std_ulogic_vector(0 to 3);
signal g6t_mpw1_b               : std_ulogic_vector(0 to 4);
signal g6t_mpw2_b               : std_ulogic;
signal cam_clkoff_b             : std_ulogic;
signal cam_d_mode               : std_ulogic;
signal cam_delay_lclkr          : std_ulogic_vector(0 to 4);
signal cam_mpw1_b               : std_ulogic_vector(0 to 4);
signal cam_mpw2_b               : std_ulogic;
signal int_pc_iu_sg_2           : std_ulogic_vector(0 to 3);
signal pc_iu_fce_2              : std_ulogic;
signal int_pc_iu_func_sl_thold_2 : std_ulogic_vector(0 to 3);
signal pc_iu_func_slp_sl_thold_2: std_ulogic;
signal pc_iu_regf_slp_sl_thold_2: std_ulogic;
signal pc_iu_time_sl_thold_2    : std_ulogic;
signal pc_iu_repr_sl_thold_2    : std_ulogic;
signal pc_iu_abst_sl_thold_2    : std_ulogic;
signal pc_iu_abst_slp_sl_thold_2: std_ulogic;
signal pc_iu_cfg_slp_sl_thold_2 : std_ulogic;
signal pc_iu_ary_nsl_thold_2    : std_ulogic;
signal pc_iu_ary_slp_nsl_thold_2: std_ulogic;
signal pc_iu_func_slp_nsl_thold_2   : std_ulogic;
signal pc_iu_bolt_sl_thold_2    : std_ulogic;
signal ac_an_power_managed_q_int : std_ulogic;
signal pc_iu_bo_enable_3        : std_ulogic;
signal pc_iu_gptr_sl_thold_3      : std_ulogic;
signal pc_iu_time_sl_thold_3      : std_ulogic;
signal pc_iu_repr_sl_thold_3      : std_ulogic;
signal pc_iu_abst_sl_thold_3      : std_ulogic;
signal pc_iu_abst_slp_sl_thold_3  : std_ulogic;
signal pc_iu_bolt_sl_thold_3      : std_ulogic;
signal pc_iu_regf_slp_sl_thold_3  : std_ulogic;
signal pc_iu_func_sl_thold_3      : std_ulogic_vector(0 to 3);
signal pc_iu_func_slp_sl_thold_3  : std_ulogic;
signal pc_iu_cfg_sl_thold_3       : std_ulogic;
signal pc_iu_cfg_slp_sl_thold_3   : std_ulogic;
signal pc_iu_func_slp_nsl_thold_3 : std_ulogic;
signal pc_iu_ary_nsl_thold_3      : std_ulogic;
signal pc_iu_ary_slp_nsl_thold_3  : std_ulogic;
signal pc_iu_sg_3                 : std_ulogic_vector(0 to 3);
signal pc_iu_fce_3                : std_ulogic;
signal pc_mm_gptr_sl_thold_3      : std_ulogic;
signal pc_mm_time_sl_thold_3      : std_ulogic;
signal pc_mm_repr_sl_thold_3      : std_ulogic;
signal pc_mm_abst_sl_thold_3      : std_ulogic;
signal pc_mm_abst_slp_sl_thold_3  : std_ulogic;
signal pc_mm_bolt_sl_thold_3      : std_ulogic;
signal pc_mm_func_sl_thold_3      : std_ulogic_vector(0 to 1);
signal pc_mm_func_slp_sl_thold_3  : std_ulogic_vector(0 to 1);
signal pc_mm_cfg_sl_thold_3       : std_ulogic;
signal pc_mm_cfg_slp_sl_thold_3   : std_ulogic;
signal pc_mm_func_nsl_thold_3     : std_ulogic;
signal pc_mm_func_slp_nsl_thold_3 : std_ulogic;
signal pc_mm_ary_nsl_thold_3      : std_ulogic;
signal pc_mm_ary_slp_nsl_thold_3  : std_ulogic;
signal pc_mm_sg_3                 : std_ulogic_vector(0 to 1);
signal pc_mm_fce_3                : std_ulogic;
-- IC_BP
signal ic_bp_iu1_val            : std_ulogic;
signal ic_bp_iu1_tid            : std_ulogic_vector(0 to 3);
signal ic_bp_iu1_ifar           : std_ulogic_vector(52 to 59);
signal ic_bp_iu3_val            : std_ulogic_vector(0 to 3);
signal ic_bp_iu3_tid            : std_ulogic_vector(0 to 3);
signal ic_bp_iu3_ifar           : EFF_IFAR;
signal ic_bp_iu3_2ucode         : std_ulogic;
signal ic_bp_iu3_2ucode_type    : std_ulogic;
signal ic_bp_iu3_error          : std_ulogic_vector(0 to 2);
signal ic_bp_iu3_0_instr        : std_ulogic_vector(0 to 35);
signal ic_bp_iu3_1_instr        : std_ulogic_vector(0 to 35);
signal ic_bp_iu3_2_instr        : std_ulogic_vector(0 to 35);
signal ic_bp_iu3_3_instr        : std_ulogic_vector(0 to 35);
signal ic_bp_iu3_flush          : std_ulogic;
-- BP
signal iu3_0_bh_rd_data         : std_ulogic_vector(0 to 1);
signal iu3_1_bh_rd_data         : std_ulogic_vector(0 to 1);
signal iu3_2_bh_rd_data         : std_ulogic_vector(0 to 1);
signal iu3_3_bh_rd_data         : std_ulogic_vector(0 to 1);
signal iu1_bh_rd_addr           : std_ulogic_vector(0 to 7);
signal iu1_bh_rd_act            : std_ulogic;
signal ex6_bh_wr_data           : std_ulogic_vector(0 to 1);
signal ex6_bh_wr_addr           : std_ulogic_vector(0 to 7);
signal ex6_bh_wr_act            : std_ulogic_vector(0 to 3);
signal int_bp_ib_iu4_ifar       : EFF_IFAR;
signal bp_ic_iu5_hold_tid       : std_ulogic_vector(0 to 3);
signal bp_ic_iu5_redirect_tid   : std_ulogic_vector(0 to 3);
signal bp_ic_iu5_redirect_ifar  : EFF_IFAR;
-- UC
signal int_uc_flush_tid         : std_ulogic_vector(0 to 3);
signal uc_ic_hold_thread        : std_ulogic_vector(0 to 3);
-- SPR
signal spr_ic_icbi_ack_en       : std_ulogic;
signal spr_ic_cls               : std_ulogic;
signal spr_ic_clockgate_dis     : std_ulogic_vector(0 to 1);
signal spr_ic_bp_config         : std_ulogic_vector(0 to 3);
signal spr_ic_idir_read         : std_ulogic;
signal spr_ic_idir_way          : std_ulogic_vector(0 to 1);
signal spr_ic_idir_row          : std_ulogic_vector(52 to 57);
signal ic_spr_idir_done         : std_ulogic;
signal ic_spr_idir_lru          : std_ulogic_vector(0 to 2);
signal ic_spr_idir_parity       : std_ulogic_vector(0 to 3);
signal ic_spr_idir_endian       : std_ulogic;
signal ic_spr_idir_valid        : std_ulogic;
signal ic_spr_idir_tag          : std_ulogic_vector(0 to 29);
signal spr_bp_config            : std_ulogic_vector(0 to 3);
signal spr_bp_gshare_mask       : std_ulogic_vector(0 to 3);
signal spr_ic_pri_rand          : std_ulogic_vector(0 to 4);
signal spr_ic_pri_rand_always   : std_ulogic;
signal spr_ic_pri_rand_flush    : std_ulogic;
signal iuq_mi_scan_in           : std_ulogic_vector(0 to 1);
signal iuq_mi_gptr_scan_in      : std_ulogic;
signal iuq_mi_gptr_scan_out     : std_ulogic;
signal iuq_mi_repr_scan_in      : std_ulogic;
signal iuq_mi_repr_scan_out     : std_ulogic;
signal iuq_mi_time_scan_in      : std_ulogic;
signal iuq_mi_time_scan_out     : std_ulogic;
signal iuq_mi_ccfg_scan_in      : std_ulogic;
signal iuq_mi_ccfg_scan_out     : std_ulogic;
signal iuq_mi_bcfg_scan_in      : std_ulogic;
signal iuq_mi_bcfg_scan_out     : std_ulogic;
signal iuq_mi_dcfg_scan_in      : std_ulogic;
signal iuq_mi_dcfg_scan_out     : std_ulogic;
signal iuq_mi_abst_scan_in      : std_ulogic;
signal iuq_ic_ccfg_scan_in      : std_ulogic;
signal iuq_ic_ccfg_scan_out     : std_ulogic;
signal rp_gptr_scan_in          : std_ulogic;
signal rp_gptr_scan_out         : std_ulogic;
signal iuq_ic_scan_in           : std_ulogic_vector(0 to 4);
signal iuq_ic_scan_out          : std_ulogic_vector(0 to 4);
signal iuq_ic_repr_scan_in      : std_ulogic;
signal iuq_ic_repr_scan_out     : std_ulogic;
signal iuq_ic_time_scan_in      : std_ulogic;
signal iuq_ic_time_scan_out     : std_ulogic;
signal iuq_ic_abst_scan_out     : std_ulogic_vector(2 to 2);
signal iuq_bp_scan_in           : std_ulogic_vector(0 to 1);
signal int_iuq_bp_scan_out      : std_ulogic_vector(0 to 1);
signal iuq_uc_scan_in           : std_ulogic;
signal iuq_uc_scan_out          : std_ulogic;
--repower
signal iu_func_scan_in          : std_ulogic_vector(0 to 8);
signal int_iu_func_scan_in_q    : std_ulogic_vector(0 to 8);
signal int_iu_func_scan_out     : std_ulogic_vector(0 to 9);
signal iu_func_scan_out_q       : std_ulogic_vector(0 to 9);
signal bcfg_scan_in_q           : std_ulogic;
signal spare_func_scan_in_q     : std_ulogic_vector(0 to 3);
--perf
signal ic_perf_event_t0         : std_ulogic_vector(0 to 6);
signal ic_perf_event_t1         : std_ulogic_vector(0 to 6);
signal ic_perf_event_t2         : std_ulogic_vector(0 to 6);
signal ic_perf_event_t3         : std_ulogic_vector(0 to 6);
signal ic_perf_event            : std_ulogic_vector(0 to 1);
--debug groups (misc)
signal bp_dbg_data0             : std_ulogic_vector(0 to 87);
signal bp_dbg_data1             : std_ulogic_vector(0 to 87);
--debug groups (ic)
signal uc_dbg_data              : std_ulogic_vector(0 to 87);
signal dbg_debug_data_out       : std_ulogic_vector(0 to 87);
signal dbg_trace_triggers_out   : std_ulogic_vector(0 to 11);
-- fanout
signal bp_ib_iu3_0_instr        : std_ulogic_vector(0 to 31);
signal bp_ib_iu4_0_instr        : std_ulogic_vector(32 to 43);
signal bp_ib_iu4_1_instr        : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_2_instr        : std_ulogic_vector(0 to 43);
signal bp_ib_iu4_3_instr        : std_ulogic_vector(0 to 43);
signal uc_ib_iu4_ifar           : std_ulogic_vector(62-uc_ifar to 61);
signal uc_ib_iu4_instr          : std_ulogic_vector(0 to 36);
signal rm_ib_iu4_force_ram      : std_ulogic;
signal rm_ib_iu4_instr          : std_ulogic_vector(0 to 35);
signal spr_dec_mask             : std_ulogic_vector(0 to 31);
signal spr_dec_match            : std_ulogic_vector(0 to 31);
signal spr_fdep_ll_hold         : std_ulogic;
-- Special Buffering for PSRO Sensor
signal ac_an_psro_ringsig_i1_b  : std_ulogic;
signal ac_an_psro_ringsig_i2    : std_ulogic;
signal ac_an_psro_ringsig_i3_b  : std_ulogic;
signal ac_an_psro_ringsig_i4    : std_ulogic;
signal ac_an_psro_ringsig_i5_b  : std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
begin
------------------------------------------
pc_iu_sg_2(0 to 2) <= int_pc_iu_sg_2(1 to 3);
pc_iu_sg_2(3)      <= int_pc_iu_sg_2(3);
pc_iu_func_sl_thold_2(0 to 2) <= int_pc_iu_func_sl_thold_2(1 to 3);
pc_iu_func_sl_thold_2(3)      <= int_pc_iu_func_sl_thold_2(3);
clkoff_b(0)     <= int_clkoff_b(1);
clkoff_b(1)     <= int_clkoff_b(1);
clkoff_b(2)     <= int_clkoff_b(2);
clkoff_b(3)     <= int_clkoff_b(2);
delay_lclkr(5 to 14)     <= int_delay_lclkr(5 to 14);
mpw1_b(5 to 14)          <= int_mpw1_b(5 to 14);
uc_flush_tid            <= int_uc_flush_tid;
iuq_bp_scan_out         <= int_iuq_bp_scan_out(0);
ac_an_power_managed_q   <= ac_an_power_managed_q_int;
-- fanout
bp_ib_iu4_ifar_t0          <= int_bp_ib_iu4_ifar;
bp_ib_iu3_0_instr_t0       <= bp_ib_iu3_0_instr;
bp_ib_iu4_0_instr_t0       <= bp_ib_iu4_0_instr;
bp_ib_iu4_1_instr_t0       <= bp_ib_iu4_1_instr;
bp_ib_iu4_2_instr_t0       <= bp_ib_iu4_2_instr;
bp_ib_iu4_3_instr_t0       <= bp_ib_iu4_3_instr;
uc_ib_iu4_ifar_t0          <= uc_ib_iu4_ifar;
uc_ib_iu4_instr_t0         <= uc_ib_iu4_instr;
rm_ib_iu4_force_ram_t0     <= rm_ib_iu4_force_ram;
rm_ib_iu4_instr_t0         <= rm_ib_iu4_instr;
spr_dec_mask_t0            <= spr_dec_mask;
spr_dec_match_t0           <= spr_dec_match;
spr_fdep_ll_hold_t0        <= spr_fdep_ll_hold;
bp_ib_iu4_ifar_t1          <= int_bp_ib_iu4_ifar;
bp_ib_iu3_0_instr_t1       <= bp_ib_iu3_0_instr;
bp_ib_iu4_0_instr_t1       <= bp_ib_iu4_0_instr;
bp_ib_iu4_1_instr_t1       <= bp_ib_iu4_1_instr;
bp_ib_iu4_2_instr_t1       <= bp_ib_iu4_2_instr;
bp_ib_iu4_3_instr_t1       <= bp_ib_iu4_3_instr;
uc_ib_iu4_ifar_t1          <= uc_ib_iu4_ifar;
uc_ib_iu4_instr_t1         <= uc_ib_iu4_instr;
rm_ib_iu4_force_ram_t1     <= rm_ib_iu4_force_ram;
rm_ib_iu4_instr_t1         <= rm_ib_iu4_instr;
spr_dec_mask_t1            <= spr_dec_mask;
spr_dec_match_t1           <= spr_dec_match;
spr_fdep_ll_hold_t1        <= spr_fdep_ll_hold;
bp_ib_iu4_ifar_t2          <= int_bp_ib_iu4_ifar;
bp_ib_iu3_0_instr_t2       <= bp_ib_iu3_0_instr;
bp_ib_iu4_0_instr_t2       <= bp_ib_iu4_0_instr;
bp_ib_iu4_1_instr_t2       <= bp_ib_iu4_1_instr;
bp_ib_iu4_2_instr_t2       <= bp_ib_iu4_2_instr;
bp_ib_iu4_3_instr_t2       <= bp_ib_iu4_3_instr;
uc_ib_iu4_ifar_t2          <= uc_ib_iu4_ifar;
uc_ib_iu4_instr_t2         <= uc_ib_iu4_instr;
rm_ib_iu4_force_ram_t2     <= rm_ib_iu4_force_ram;
rm_ib_iu4_instr_t2         <= rm_ib_iu4_instr;
spr_dec_mask_t2            <= spr_dec_mask;
spr_dec_match_t2           <= spr_dec_match;
spr_fdep_ll_hold_t2        <= spr_fdep_ll_hold;
bp_ib_iu4_ifar_t3          <= int_bp_ib_iu4_ifar;
bp_ib_iu3_0_instr_t3       <= bp_ib_iu3_0_instr;
bp_ib_iu4_0_instr_t3       <= bp_ib_iu4_0_instr;
bp_ib_iu4_1_instr_t3       <= bp_ib_iu4_1_instr;
bp_ib_iu4_2_instr_t3       <= bp_ib_iu4_2_instr;
bp_ib_iu4_3_instr_t3       <= bp_ib_iu4_3_instr;
uc_ib_iu4_ifar_t3          <= uc_ib_iu4_ifar;
uc_ib_iu4_instr_t3         <= uc_ib_iu4_instr;
rm_ib_iu4_force_ram_t3     <= rm_ib_iu4_force_ram;
rm_ib_iu4_instr_t3         <= rm_ib_iu4_instr;
spr_dec_mask_t3            <= spr_dec_mask;
spr_dec_match_t3           <= spr_dec_match;
spr_fdep_ll_hold_t3        <= spr_fdep_ll_hold;
iuq_misc0 : entity work.iuq_misc
generic map(regmode     => regmode,
            a2mode      => a2mode,
            expand_type => expand_type)
port map (
          vdd                           => vdd,
          gnd                           => gnd,
          vcs                           => vcs,
          nclk                          => nclk,
          pc_iu_sg_3                    => pc_iu_sg_3,
          pc_iu_func_sl_thold_3         => pc_iu_func_sl_thold_3,
          pc_iu_func_slp_sl_thold_3     => pc_iu_func_slp_sl_thold_3,
          pc_iu_gptr_sl_thold_3         => pc_iu_gptr_sl_thold_3,
          pc_iu_time_sl_thold_3         => pc_iu_time_sl_thold_3,
          pc_iu_repr_sl_thold_3         => pc_iu_repr_sl_thold_3,
          pc_iu_abst_sl_thold_3         => pc_iu_abst_sl_thold_3,
          pc_iu_abst_slp_sl_thold_3     => pc_iu_abst_slp_sl_thold_3,
          pc_iu_cfg_sl_thold_3          => pc_iu_cfg_sl_thold_3,
          pc_iu_cfg_slp_sl_thold_3      => pc_iu_cfg_slp_sl_thold_3,
          pc_iu_regf_slp_sl_thold_3     => pc_iu_regf_slp_sl_thold_3,
          pc_iu_ary_nsl_thold_3         => pc_iu_ary_nsl_thold_3,
          pc_iu_ary_slp_nsl_thold_3     => pc_iu_ary_slp_nsl_thold_3,
          pc_iu_func_slp_nsl_thold_3    => pc_iu_func_slp_nsl_thold_3,
          pc_iu_bolt_sl_thold_3         => pc_iu_bolt_sl_thold_3,
          pc_iu_fce_3                   => pc_iu_fce_3,
          tc_ac_ccflush_dc              => tc_ac_ccflush_dc,
          scan_diag_dc                  => an_ac_scan_diag_dc,
          pc_iu_sg_2                    => int_pc_iu_sg_2,
          pc_iu_func_sl_thold_2         => int_pc_iu_func_sl_thold_2,
          pc_iu_func_slp_sl_thold_2     => pc_iu_func_slp_sl_thold_2,
          pc_iu_time_sl_thold_2         => pc_iu_time_sl_thold_2,
          pc_iu_repr_sl_thold_2         => pc_iu_repr_sl_thold_2,
          pc_iu_abst_sl_thold_2         => pc_iu_abst_sl_thold_2,
          pc_iu_abst_slp_sl_thold_2     => pc_iu_abst_slp_sl_thold_2,
          pc_iu_cfg_slp_sl_thold_2      => pc_iu_cfg_slp_sl_thold_2,
          pc_iu_regf_slp_sl_thold_2     => pc_iu_regf_slp_sl_thold_2,
          pc_iu_ary_nsl_thold_2         => pc_iu_ary_nsl_thold_2,
          pc_iu_ary_slp_nsl_thold_2     => pc_iu_ary_slp_nsl_thold_2,
          pc_iu_func_slp_nsl_thold_2    => pc_iu_func_slp_nsl_thold_2,
          pc_iu_bolt_sl_thold_2         => pc_iu_bolt_sl_thold_2,
          pc_iu_fce_2                   => pc_iu_fce_2,
          clkoff_b                      => int_clkoff_b,

delay_lclkr                   => int_delay_lclkr,
          mpw1_b                        => int_mpw1_b,

g8t_clkoff_b                  => g8t_clkoff_b,
          g8t_d_mode                    => g8t_d_mode,
          g8t_delay_lclkr               => g8t_delay_lclkr,
          g8t_mpw1_b                    => g8t_mpw1_b,
          g8t_mpw2_b                    => g8t_mpw2_b,
          g6t_clkoff_b                  => g6t_clkoff_b,

g6t_d_mode                    => g6t_d_mode,
          g6t_delay_lclkr               => g6t_delay_lclkr,
          g6t_mpw1_b                    => g6t_mpw1_b,
          g6t_mpw2_b                    => g6t_mpw2_b,
          cam_clkoff_b                  => cam_clkoff_b,

cam_d_mode                    => cam_d_mode,
          cam_delay_lclkr               => cam_delay_lclkr,
          cam_mpw1_b                    => cam_mpw1_b,
          cam_mpw2_b                    => cam_mpw2_b,
          an_ac_scan_dis_dc_b           => an_ac_scan_dis_dc_b,
          func_scan_in                  => iuq_mi_scan_in,
          gptr_scan_in                  => iuq_mi_gptr_scan_in,
          time_scan_in                  => iuq_mi_time_scan_in,
          abst_scan_in                  => iuq_mi_abst_scan_in,
          repr_scan_in                  => iuq_mi_repr_scan_in,
          ccfg_scan_in                  => iuq_mi_ccfg_scan_in,
          bcfg_scan_in                  => iuq_mi_bcfg_scan_in,
          dcfg_scan_in                  => iuq_mi_dcfg_scan_in,
          func_scan_out                 => iuq_mi_scan_out,
          gptr_scan_out                 => iuq_mi_gptr_scan_out,
          time_scan_out                 => iuq_mi_time_scan_out,
          abst_scan_out                 => abst_scan_out(2),
          repr_scan_out                 => iuq_mi_repr_scan_out,
          ccfg_scan_out                 => iuq_mi_ccfg_scan_out,
          bcfg_scan_out                 => iuq_mi_bcfg_scan_out,
          dcfg_scan_out                 => iuq_mi_dcfg_scan_out,
          pc_iu_abist_di_0              => pc_iu_abist_di_0,
          pc_iu_abist_g8t_bw_1          => pc_iu_abist_g8t_bw_1,
          pc_iu_abist_g8t_bw_0          => pc_iu_abist_g8t_bw_0,
          pc_iu_abist_waddr_0           => pc_iu_abist_waddr_0(3 to 9),
          pc_iu_abist_g8t_wenb          => pc_iu_abist_g8t_wenb,
          pc_iu_abist_raddr_0           => pc_iu_abist_raddr_0(3 to 9),
          pc_iu_abist_g8t1p_renb_0      => pc_iu_abist_g8t1p_renb_0,
          an_ac_lbist_ary_wrt_thru_dc   => an_ac_lbist_ary_wrt_thru_dc,
          pc_iu_abist_ena_dc            => pc_iu_abist_ena_dc,
          pc_iu_abist_wl128_comp_ena    => pc_iu_abist_wl128_comp_ena,
          pc_iu_abist_raw_dc_b          => pc_iu_abist_raw_dc_b,
          pc_iu_abist_g8t_dcomp         => pc_iu_abist_g8t_dcomp,
          pc_iu_bo_enable_3             => pc_iu_bo_enable_3,
          pc_iu_bo_reset                => pc_iu_bo_reset,
          pc_iu_bo_unload               => pc_iu_bo_unload,
          pc_iu_bo_repair               => pc_iu_bo_repair,
          pc_iu_bo_shdata               => pc_iu_bo_shdata,
          pc_iu_bo_select               => pc_iu_bo_select(4),
          iu_pc_bo_fail                 => iu_pc_bo_fail(4),
          iu_pc_bo_diagout              => iu_pc_bo_diagout(4),
          r_act                         => iu1_bh_rd_act,
          w_act                         => ex6_bh_wr_act,
          r_addr                        => iu1_bh_rd_addr,
          w_addr                        => ex6_bh_wr_addr,
          data_in                       => ex6_bh_wr_data,
          data_out0                     => iu3_0_bh_rd_data,
          data_out1                     => iu3_1_bh_rd_data,
          data_out2                     => iu3_2_bh_rd_data,
          data_out3                     => iu3_3_bh_rd_data,
          pc_iu_ram_instr               => pc_iu_ram_instr,
          pc_iu_ram_instr_ext           => pc_iu_ram_instr_ext,
          pc_iu_ram_force_cmplt         => pc_iu_ram_force_cmplt,
          xu_iu_ram_issue               => xu_iu_ram_issue,
          rm_ib_iu4_val                 => rm_ib_iu4_val,
          rm_ib_iu4_force_ram           => rm_ib_iu4_force_ram,
          rm_ib_iu4_instr               => rm_ib_iu4_instr,
          slowspr_val_in                => slowspr_val_in,
          slowspr_rw_in                 => slowspr_rw_in,
          slowspr_etid_in               => slowspr_etid_in,
          slowspr_addr_in               => slowspr_addr_in,
          slowspr_data_in               => slowspr_data_in,
          slowspr_done_in               => slowspr_done_in,
          slowspr_val_out               => slowspr_val_out,
          slowspr_rw_out                => slowspr_rw_out,
          slowspr_etid_out              => slowspr_etid_out,
          slowspr_addr_out              => slowspr_addr_out,
          slowspr_data_out              => slowspr_data_out,
          slowspr_done_out              => slowspr_done_out,
          spr_ic_idir_read              => spr_ic_idir_read,
          spr_ic_idir_way               => spr_ic_idir_way,
          spr_ic_idir_row               => spr_ic_idir_row,
          ic_spr_idir_done              => ic_spr_idir_done,
          ic_spr_idir_lru               => ic_spr_idir_lru,
          ic_spr_idir_parity            => ic_spr_idir_parity,
          ic_spr_idir_endian            => ic_spr_idir_endian,
          ic_spr_idir_valid             => ic_spr_idir_valid,
          ic_spr_idir_tag               => ic_spr_idir_tag,
          spr_ic_cls                    => spr_ic_cls,
          spr_ic_clockgate_dis          => spr_ic_clockgate_dis,
          spr_ic_icbi_ack_en            => spr_ic_icbi_ack_en,
          spr_ic_bp_config              => spr_ic_bp_config,
          spr_bp_config                 => spr_bp_config,
          spr_bp_gshare_mask            => spr_bp_gshare_mask,
          spr_issue_high_mask           => spr_issue_high_mask,
          spr_issue_med_mask            => spr_issue_med_mask,
          spr_fiss_count0_max           => spr_fiss_count0_max,
          spr_fiss_count1_max           => spr_fiss_count1_max,
          spr_fiss_count2_max           => spr_fiss_count2_max,
          spr_fiss_count3_max           => spr_fiss_count3_max,
          spr_ic_pri_rand               => spr_ic_pri_rand,
          spr_ic_pri_rand_always        => spr_ic_pri_rand_always,
          spr_ic_pri_rand_flush         => spr_ic_pri_rand_flush,
          spr_fiss_pri_rand             => spr_fiss_pri_rand,
          spr_fiss_pri_rand_always      => spr_fiss_pri_rand_always,
          spr_fiss_pri_rand_flush       => spr_fiss_pri_rand_flush,
          spr_dec_mask                  => spr_dec_mask,
          spr_dec_match                 => spr_dec_match,
          spr_fdep_ll_hold              => spr_fdep_ll_hold,
          xu_iu_run_thread              => xu_iu_run_thread,
          iu_au_config_iucr_t0          => iu_au_config_iucr_t0,
          iu_au_config_iucr_t1          => iu_au_config_iucr_t1,
          iu_au_config_iucr_t2          => iu_au_config_iucr_t2,
          iu_au_config_iucr_t3          => iu_au_config_iucr_t3,
          xu_iu_ex6_pri                 => xu_iu_ex6_pri,
          xu_iu_ex6_pri_val             => xu_iu_ex6_pri_val,
          xu_iu_raise_iss_pri           => xu_iu_raise_iss_pri,
          xu_iu_msr_gs                  => xu_iu_msr_gs,
          xu_iu_msr_pr                  => xu_iu_msr_pr,
          pc_iu_trace_bus_enable        => pc_iu_trace_bus_enable,
          pc_iu_debug_mux_ctrls         => pc_iu_debug_mux1_ctrls,
          debug_data_in                 => debug_data_in,
          trace_triggers_in             => trace_triggers_in,
          debug_data_out                => dbg_debug_data_out,
          trace_triggers_out            => dbg_trace_triggers_out,
          fiss_dbg_data                 => fiss_dbg_data,
          fdep_dbg_data                 => fdep_dbg_data,
          ib_dbg_data                   => ib_dbg_data,
          bp_dbg_data0                  => bp_dbg_data0,
          bp_dbg_data1                  => bp_dbg_data1,
          fu_iss_dbg_data               => fu_iss_dbg_data,
          axu_dbg_data_t0               => axu_dbg_data_t0,
          axu_dbg_data_t1               => axu_dbg_data_t1,
          axu_dbg_data_t2               => axu_dbg_data_t2,
          axu_dbg_data_t3               => axu_dbg_data_t3,
          ic_perf_event_t0              => ic_perf_event_t0,
          ic_perf_event_t1              => ic_perf_event_t1,
          ic_perf_event_t2              => ic_perf_event_t2,
          ic_perf_event_t3              => ic_perf_event_t3,
          ic_perf_event                 => ic_perf_event,
          ib_perf_event_t0              => ib_perf_event_t0,
          ib_perf_event_t1              => ib_perf_event_t1,
          ib_perf_event_t2              => ib_perf_event_t2,
          ib_perf_event_t3              => ib_perf_event_t3,
          fdep_perf_event_t0            => fdep_perf_event_t0,
          fdep_perf_event_t1            => fdep_perf_event_t1,
          fdep_perf_event_t2            => fdep_perf_event_t2,
          fdep_perf_event_t3            => fdep_perf_event_t3,
          fiss_perf_event_t0            => fiss_perf_event_t0,
          fiss_perf_event_t1            => fiss_perf_event_t1,
          fiss_perf_event_t2            => fiss_perf_event_t2,
          fiss_perf_event_t3            => fiss_perf_event_t3,
          pc_iu_event_mux_ctrls        => pc_iu_event_mux_ctrls,
          pc_iu_event_count_mode        => pc_iu_event_count_mode,
          pc_iu_event_bus_enable        => pc_iu_event_bus_enable,
          iu_pc_event_data              => iu_pc_event_data

);
iuq_ic0 : entity work.iuq_ic
generic map(regmode               => regmode,
            bcfg_epn_0to15        => bcfg_epn_0to15,
            bcfg_epn_16to31       => bcfg_epn_16to31,
            bcfg_epn_32to47       => bcfg_epn_32to47,
            bcfg_epn_48to51       => bcfg_epn_48to51,
            bcfg_rpn_22to31       => bcfg_rpn_22to31,
            bcfg_rpn_32to47       => bcfg_rpn_32to47,
            bcfg_rpn_48to51       => bcfg_rpn_48to51,
            expand_type           => expand_type)
port map(
     vcs                        => vcs,
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     tc_ac_ccflush_dc           => tc_ac_ccflush_dc,
     an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b,
     an_ac_scan_diag_dc         => an_ac_scan_diag_dc,
     pc_iu_func_sl_thold_2      => int_pc_iu_func_sl_thold_2(0),
     pc_iu_func_slp_sl_thold_2  => pc_iu_func_slp_sl_thold_2,
     pc_iu_time_sl_thold_2      => pc_iu_time_sl_thold_2,
     pc_iu_repr_sl_thold_2      => pc_iu_repr_sl_thold_2,
     pc_iu_abst_sl_thold_2      => pc_iu_abst_sl_thold_2,
     pc_iu_abst_slp_sl_thold_2  => pc_iu_abst_slp_sl_thold_2,
     pc_iu_cfg_slp_sl_thold_2   => pc_iu_cfg_slp_sl_thold_2,
     pc_iu_regf_slp_sl_thold_2  => pc_iu_regf_slp_sl_thold_2,
     pc_iu_ary_nsl_thold_2      => pc_iu_ary_nsl_thold_2,
     pc_iu_ary_slp_nsl_thold_2  => pc_iu_ary_slp_nsl_thold_2,
     pc_iu_func_slp_nsl_thold_2 => pc_iu_func_slp_nsl_thold_2,
     pc_iu_bolt_sl_thold_2      => pc_iu_bolt_sl_thold_2,
     pc_iu_sg_2                 => int_pc_iu_sg_2(0),
     pc_iu_fce_2                => pc_iu_fce_2,
     clkoff_b                   => int_clkoff_b(0),
     delay_lclkr(0)             => int_delay_lclkr(1),
     delay_lclkr(1)             => int_delay_lclkr(4),
     mpw1_b(0)                  => int_mpw1_b(1),
     mpw1_b(1)                  => int_mpw1_b(4),
     g8t_clkoff_b               => g8t_clkoff_b,
     g8t_d_mode                 => g8t_d_mode,
     g8t_delay_lclkr            => g8t_delay_lclkr,
     g8t_mpw1_b                 => g8t_mpw1_b,
     g8t_mpw2_b                 => g8t_mpw2_b,
     g6t_clkoff_b               => g6t_clkoff_b,
     g6t_d_mode                 => g6t_d_mode,
     g6t_delay_lclkr            => g6t_delay_lclkr,
     g6t_mpw1_b                 => g6t_mpw1_b,
     g6t_mpw2_b                 => g6t_mpw2_b,
     cam_clkoff_b               => cam_clkoff_b,
     cam_d_mode                 => cam_d_mode,
     cam_delay_lclkr            => cam_delay_lclkr,
     cam_mpw1_b                 => cam_mpw1_b,
     cam_mpw2_b                 => cam_mpw2_b,
     func_scan_in               => iuq_ic_scan_in, 
     func_scan_out              => iuq_ic_scan_out, 
     ac_ccfg_scan_in            => iuq_ic_ccfg_scan_in,
     ac_ccfg_scan_out           => iuq_ic_ccfg_scan_out,
     time_scan_in               => iuq_ic_time_scan_in,
     time_scan_out              => iuq_ic_time_scan_out,
     repr_scan_in               => iuq_ic_repr_scan_in,
     repr_scan_out              => iuq_ic_repr_scan_out,
     abst_scan_in               => abst_scan_in(0 to 2),
     abst_scan_out(0 to 1)      => abst_scan_out(0 to 1),
     abst_scan_out(2)           => iuq_ic_abst_scan_out(2),
     regf_scan_in               => regf_scan_in,
     regf_scan_out              => regf_scan_out,
     uc_dbg_data                => uc_dbg_data,
     pc_iu_trace_bus_enable     => pc_iu_trace_bus_enable,
     pc_iu_debug_mux_ctrls      => pc_iu_debug_mux2_ctrls,
     debug_data_in              => dbg_debug_data_out,
     trace_triggers_in          => dbg_trace_triggers_out,
     debug_data_out             => debug_data_out,
     trace_triggers_out         => trace_triggers_out,
     pc_iu_event_bus_enable     => pc_iu_event_bus_enable,
     ic_perf_event_t0           => ic_perf_event_t0,
     ic_perf_event_t1           => ic_perf_event_t1,
     ic_perf_event_t2           => ic_perf_event_t2,
     ic_perf_event_t3           => ic_perf_event_t3,
     ic_perf_event              => ic_perf_event,
     iu_pc_err_icache_parity    => iu_pc_err_icache_parity,
     iu_pc_err_icachedir_parity => iu_pc_err_icachedir_parity,
     iu_pc_err_icachedir_multihit => iu_pc_err_icachedir_multihit,
     pc_iu_inj_icache_parity    => pc_iu_inj_icache_parity,
     pc_iu_inj_icachedir_parity => pc_iu_inj_icachedir_parity,
     pc_iu_inj_icachedir_multihit => pc_iu_inj_icachedir_multihit,
     pc_iu_abist_g8t_wenb       => pc_iu_abist_g8t_wenb,
     pc_iu_abist_g8t1p_renb_0   => pc_iu_abist_g8t1p_renb_0,
     pc_iu_abist_di_0           => pc_iu_abist_di_0,
     pc_iu_abist_g8t_bw_1       => pc_iu_abist_g8t_bw_1,
     pc_iu_abist_g8t_bw_0       => pc_iu_abist_g8t_bw_0,
     pc_iu_abist_waddr_0        => pc_iu_abist_waddr_0(4 to 9),
     pc_iu_abist_raddr_0        => pc_iu_abist_raddr_0(2 to 9),
     pc_iu_abist_ena_dc         => pc_iu_abist_ena_dc,
     pc_iu_abist_wl64_comp_ena  => pc_iu_abist_wl64_comp_ena,
     pc_iu_abist_raw_dc_b       => pc_iu_abist_raw_dc_b,
     pc_iu_abist_g8t_dcomp      => pc_iu_abist_g8t_dcomp,
     pc_iu_abist_g6t_bw         => pc_iu_abist_g6t_bw,
     pc_iu_abist_di_g6t_2r      => pc_iu_abist_di_g6t_2r,
     pc_iu_abist_wl256_comp_ena => pc_iu_abist_wl256_comp_ena,
     pc_iu_abist_dcomp_g6t_2r   => pc_iu_abist_dcomp_g6t_2r,
     pc_iu_abist_g6t_r_wb       => pc_iu_abist_g6t_r_wb,
     an_ac_lbist_ary_wrt_thru_dc=> an_ac_lbist_ary_wrt_thru_dc,
     an_ac_lbist_en_dc          => an_ac_lbist_en_dc,
     an_ac_atpg_en_dc           => an_ac_atpg_en_dc,
     an_ac_grffence_en_dc       => an_ac_grffence_en_dc,
     pc_iu_bo_enable_3          => pc_iu_bo_enable_3,
     pc_iu_bo_reset             => pc_iu_bo_reset,
     pc_iu_bo_unload            => pc_iu_bo_unload,
     pc_iu_bo_repair            => pc_iu_bo_repair,
     pc_iu_bo_shdata            => pc_iu_bo_shdata,
     pc_iu_bo_select            => pc_iu_bo_select(0 to 3),
     iu_pc_bo_fail              => iu_pc_bo_fail(0 to 3),
     iu_pc_bo_diagout           => iu_pc_bo_diagout(0 to 3),
     pc_iu_init_reset           => pc_iu_init_reset,
     xu_iu_rf1_val              => xu_iu_rf1_val,
     xu_iu_rf1_is_eratre        => xu_iu_rf1_is_eratre,
     xu_iu_rf1_is_eratwe        => xu_iu_rf1_is_eratwe,
     xu_iu_rf1_is_eratsx        => xu_iu_rf1_is_eratsx,
     xu_iu_rf1_is_eratilx       => xu_iu_rf1_is_eratilx,
     xu_iu_ex1_is_isync         => xu_iu_ex1_is_isync,
     xu_iu_ex1_is_csync         => xu_iu_ex1_is_csync,
     xu_iu_rf1_ws               => xu_iu_rf1_ws,
     xu_iu_rf1_t                => xu_iu_rf1_t,
     xu_iu_ex1_rs_is            => xu_iu_ex1_rs_is,
     xu_iu_ex1_ra_entry         => xu_iu_ex1_ra_entry(8 to 11),
     xu_iu_ex1_rb               => xu_iu_ex1_rb,
     xu_rf1_flush               => xu_rf1_flush,
     xu_ex1_flush               => xu_ex1_flush,
     xu_ex2_flush               => xu_ex2_flush,
     xu_ex3_flush               => xu_ex3_flush,
     xu_ex4_flush               => xu_ex4_flush,
     xu_ex5_flush               => xu_ex5_flush,
     xu_iu_ex4_rs_data          => xu_iu_ex4_rs_data,
     xu_iu_msr_hv               => xu_iu_msr_hv,
     xu_iu_msr_is               => xu_iu_msr_is,
     xu_iu_msr_pr               => xu_iu_msr_pr,
     xu_iu_hid_mmu_mode         => xu_iu_hid_mmu_mode,
     xu_iu_spr_ccr2_ifratsc     => xu_iu_spr_ccr2_ifratsc,
     xu_iu_spr_ccr2_ifrat       => xu_iu_spr_ccr2_ifrat,
     xu_iu_xucr4_mmu_mchk       => xu_iu_xucr4_mmu_mchk,
     iu_xu_ex4_data             => iu_xu_ex4_tlb_data,
     iu_xu_ierat_ex3_par_err    => iu_xu_ierat_ex3_par_err,
     iu_xu_ierat_ex4_par_err    => iu_xu_ierat_ex4_par_err,
     iu_xu_ierat_ex2_flush_req  => iu_xu_ierat_ex2_flush_req,
     iu_mm_ierat_req            => iu_mm_ierat_req,
     iu_mm_ierat_epn            => iu_mm_ierat_epn,
     iu_mm_ierat_thdid          => iu_mm_ierat_thdid,
     iu_mm_ierat_state          => iu_mm_ierat_state,
     iu_mm_ierat_tid            => iu_mm_ierat_tid,
     iu_mm_ierat_flush          => iu_mm_ierat_flush,
     mm_iu_ierat_rel_val        => mm_iu_ierat_rel_val,
     mm_iu_ierat_rel_data       => mm_iu_ierat_rel_data,
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
     mm_iu_ierat_snoop_coming   => mm_iu_ierat_snoop_coming,
     mm_iu_ierat_snoop_val      => mm_iu_ierat_snoop_val,
     mm_iu_ierat_snoop_attr     => mm_iu_ierat_snoop_attr,
     mm_iu_ierat_snoop_vpn      => mm_iu_ierat_snoop_vpn,
     iu_mm_ierat_snoop_ack      => iu_mm_ierat_snoop_ack,
     iu_mm_lmq_empty            => iu_mm_lmq_empty,
     ac_an_power_managed        => ac_an_power_managed_q_int,
     xu_iu_run_thread           => xu_iu_run_thread,
     xu_iu_flush                => xu_iu_flush,
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
     spr_ic_cls                 => spr_ic_cls,
     spr_ic_clockgate_dis       => spr_ic_clockgate_dis,
     spr_ic_icbi_ack_en         => spr_ic_icbi_ack_en,
     spr_ic_bp_config           => spr_ic_bp_config,
     spr_ic_idir_read           => spr_ic_idir_read,
     spr_ic_idir_way            => spr_ic_idir_way,
     spr_ic_idir_row            => spr_ic_idir_row,
     spr_ic_pri_rand            => spr_ic_pri_rand,
     spr_ic_pri_rand_always     => spr_ic_pri_rand_always,
     spr_ic_pri_rand_flush      => spr_ic_pri_rand_flush,
     ic_spr_idir_done           => ic_spr_idir_done,
     ic_spr_idir_lru            => ic_spr_idir_lru,
     ic_spr_idir_parity         => ic_spr_idir_parity,
     ic_spr_idir_endian         => ic_spr_idir_endian,
     ic_spr_idir_valid          => ic_spr_idir_valid,
     ic_spr_idir_tag            => ic_spr_idir_tag,
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
     an_ac_back_inv_addr        => an_ac_back_inv_addr(REAL_IFAR'left to 57),
     an_ac_back_inv_target      => an_ac_back_inv_target_iiu_a(0),
     an_ac_icbi_ack             => an_ac_icbi_ack,
     an_ac_icbi_ack_thread      => an_ac_icbi_ack_thread,
     bp_ib_iu4_ifar             => int_bp_ib_iu4_ifar,
     bp_ic_iu5_hold_tid         => bp_ic_iu5_hold_tid,
     bp_ic_iu5_redirect_tid     => bp_ic_iu5_redirect_tid,
     bp_ic_iu5_redirect_ifar    => bp_ic_iu5_redirect_ifar,
     ic_bp_iu1_val              => ic_bp_iu1_val,
     ic_bp_iu1_tid              => ic_bp_iu1_tid,
     ic_bp_iu1_ifar             => ic_bp_iu1_ifar,
     ic_bp_iu3_val              => ic_bp_iu3_val,
     ic_bp_iu3_tid              => ic_bp_iu3_tid,
     ic_bp_iu3_ifar             => ic_bp_iu3_ifar,
     ic_bp_iu3_2ucode           => ic_bp_iu3_2ucode,
     ic_bp_iu3_2ucode_type      => ic_bp_iu3_2ucode_type,
     ic_bp_iu3_error            => ic_bp_iu3_error,
     ic_bp_iu3_flush            => ic_bp_iu3_flush,
     ic_bp_iu3_0_instr          => ic_bp_iu3_0_instr,
     ic_bp_iu3_1_instr          => ic_bp_iu3_1_instr,
     ic_bp_iu3_2_instr          => ic_bp_iu3_2_instr,
     ic_bp_iu3_3_instr          => ic_bp_iu3_3_instr,
     ib_ic_empty                => ib_ic_empty,
     ib_ic_below_water          => ib_ic_below_water,
     ib_ic_iu5_redirect_tid     => ib_ic_iu5_redirect_tid,
     ic_fdep_load_quiesce       => ic_fdep_load_quiesce,
     ic_fdep_icbi_ack           => ic_fdep_icbi_ack,
     uc_flush_tid               => int_uc_flush_tid,
     uc_ic_hold_thread          => uc_ic_hold_thread
);
iuq_bp0 : entity work.iuq_bp
generic map(expand_type => expand_type)
port map(
     bp_dbg_data0               => bp_dbg_data0,
     bp_dbg_data1               => bp_dbg_data1,
     iu3_0_bh_rd_data           => iu3_0_bh_rd_data,
     iu3_1_bh_rd_data           => iu3_1_bh_rd_data,
     iu3_2_bh_rd_data           => iu3_2_bh_rd_data,
     iu3_3_bh_rd_data           => iu3_3_bh_rd_data,
     iu1_bh_rd_addr             => iu1_bh_rd_addr,
     iu1_bh_rd_act              => iu1_bh_rd_act,
     ex6_bh_wr_data             => ex6_bh_wr_data,
     ex6_bh_wr_addr             => ex6_bh_wr_addr,
     ex6_bh_wr_act              => ex6_bh_wr_act,
     ic_bp_iu1_val              => ic_bp_iu1_val,
     ic_bp_iu1_tid              => ic_bp_iu1_tid,
     ic_bp_iu1_ifar             => ic_bp_iu1_ifar,
     ic_bp_iu3_val              => ic_bp_iu3_val,
     ic_bp_iu3_tid              => ic_bp_iu3_tid,
     ic_bp_iu3_ifar             => ic_bp_iu3_ifar,
     ic_bp_iu3_error            => ic_bp_iu3_error,
     ic_bp_iu3_2ucode           => ic_bp_iu3_2ucode,
     ic_bp_iu3_2ucode_type      => ic_bp_iu3_2ucode_type,
     ic_bp_iu3_flush            => ic_bp_iu3_flush,
     ic_bp_iu3_0_instr          => ic_bp_iu3_0_instr,
     ic_bp_iu3_1_instr          => ic_bp_iu3_1_instr,
     ic_bp_iu3_2_instr          => ic_bp_iu3_2_instr,
     ic_bp_iu3_3_instr          => ic_bp_iu3_3_instr,
     bp_ib_iu4_t0_val           => bp_ib_iu4_t0_val,
     bp_ib_iu4_t1_val           => bp_ib_iu4_t1_val,
     bp_ib_iu4_t2_val           => bp_ib_iu4_t2_val,
     bp_ib_iu4_t3_val           => bp_ib_iu4_t3_val,
     bp_ib_iu4_ifar             => int_bp_ib_iu4_ifar,
     bp_ib_iu3_0_instr          => bp_ib_iu3_0_instr,
     bp_ib_iu4_0_instr          => bp_ib_iu4_0_instr,
     bp_ib_iu4_1_instr          => bp_ib_iu4_1_instr,
     bp_ib_iu4_2_instr          => bp_ib_iu4_2_instr,
     bp_ib_iu4_3_instr          => bp_ib_iu4_3_instr,
     bp_ic_iu5_hold_tid         => bp_ic_iu5_hold_tid,
     bp_ic_iu5_redirect_tid     => bp_ic_iu5_redirect_tid,
     bp_ic_iu5_redirect_ifar    => bp_ic_iu5_redirect_ifar,
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
     xu_iu_iu3_flush_tid        => xu_iu_flush,
     xu_iu_iu4_flush_tid        => xu_iu_flush,
     xu_iu_iu5_flush_tid        => xu_iu_flush,
     xu_iu_ex5_flush_tid        => xu_ex5_flush,
     ib_ic_iu5_redirect_tid     => ib_ic_iu5_redirect_tid,
     uc_flush_tid               => int_uc_flush_tid,
     spr_bp_config              => spr_bp_config,
     spr_bp_gshare_mask         => spr_bp_gshare_mask,
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b,
     pc_iu_sg_2                 => int_pc_iu_sg_2(0),
     pc_iu_func_sl_thold_2      => int_pc_iu_func_sl_thold_2(0),
     clkoff_b                   => int_clkoff_b(0),

tc_ac_ccflush_dc           => tc_ac_ccflush_dc,

delay_lclkr                => int_delay_lclkr(2),
     mpw1_b                     => int_mpw1_b(2),

scan_in                    => iuq_bp_scan_in(0 to 1), 
     scan_out                   => int_iuq_bp_scan_out(0 to 1) 
);
u0: if ucode_mode = 0 generate
begin
  iuq_uc_scan_out <= iuq_uc_scan_in;
int_uc_flush_tid <= (others => '0');
uc_ib_iu4_val <= (others => '0');
uc_ib_iu4_ifar <= (others => '0');
uc_ib_iu4_instr <= (others => '0');
uc_ic_hold_thread <= (others => '0');
iu_pc_err_ucode_illegal <= (others => '0');
end generate u0;
u1: if ucode_mode = 1 generate
begin
iuq_uc0 : entity work.iuq_uc
generic map(uc_ifar               => uc_ifar,
            regmode               => regmode,
            expand_type           => expand_type)
port map(
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     pc_iu_func_sl_thold_2      => int_pc_iu_func_sl_thold_2(0),
     pc_iu_sg_2                 => int_pc_iu_sg_2(0),
     an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b,
     tc_ac_ccflush_dc           => tc_ac_ccflush_dc,
     clkoff_b                   => int_clkoff_b(0),
     delay_lclkr                => int_delay_lclkr(3),
     mpw1_b                     => int_mpw1_b(3),
     scan_in                    => iuq_uc_scan_in,
     scan_out                   => iuq_uc_scan_out,
     spr_ic_clockgate_dis       => spr_ic_clockgate_dis(0),
     iu_pc_err_ucode_illegal    => iu_pc_err_ucode_illegal,
     xu_iu_spr_xer0             => xu_iu_spr_xer0,
     xu_iu_spr_xer1             => xu_iu_spr_xer1,
     xu_iu_spr_xer2             => xu_iu_spr_xer2,
     xu_iu_spr_xer3             => xu_iu_spr_xer3,
     xu_iu_flush            	=> xu_iu_flush,
     xu_iu_ucode_restart        => xu_iu_ucode_restart,
     xu_iu_uc_flush_ifar0       => xu_iu_uc_flush_ifar0,
     xu_iu_uc_flush_ifar1       => xu_iu_uc_flush_ifar1,
     xu_iu_uc_flush_ifar2       => xu_iu_uc_flush_ifar2,
     xu_iu_uc_flush_ifar3       => xu_iu_uc_flush_ifar3,
     uc_flush_tid               => int_uc_flush_tid,
     fiss_uc_is2_ucode_vld      => fiss_uc_is2_ucode_vld,
     fiss_uc_is2_tid            => fiss_uc_is2_tid,
     fiss_uc_is2_instr          => fiss_uc_is2_instr,
     fiss_uc_is2_2ucode         => fiss_uc_is2_2ucode,
     fiss_uc_is2_2ucode_type    => fiss_uc_is2_2ucode_type,
     ib_uc_buff0_avail          => ib_ic_below_water(0),    
     ib_uc_buff1_avail          => ib_ic_below_water(1),    
     ib_uc_buff2_avail          => ib_ic_below_water(2),    
     ib_uc_buff3_avail          => ib_ic_below_water(3),    
     uc_ib_iu4_valid_tid        => uc_ib_iu4_val,
     uc_ib_iu4_ifar             => uc_ib_iu4_ifar(62-uc_ifar to 61),
     uc_ib_iu4_instr            => uc_ib_iu4_instr(0 to 31),
     uc_ib_iu4_is_ucode         => uc_ib_iu4_instr(36),
     uc_ib_iu4_ext              => uc_ib_iu4_instr(32 to 35),
     uc_ic_hold_thread          => uc_ic_hold_thread,
     pc_iu_trace_bus_enable     => pc_iu_trace_bus_enable,
     uc_dbg_data                => uc_dbg_data
);
end generate u1;
iuq_rp0 : entity work.iuq_rp
generic map(expand_type => expand_type)
port map(
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     scan_diag_dc               => an_ac_scan_diag_dc,
     scan_dis_dc_b              => an_ac_scan_dis_dc_b,
     an_ac_ccflush_dc           => tc_ac_ccflush_dc,
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
     ac_an_power_managed_q      => ac_an_power_managed_q_int,
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
     iu_func_scan_in            => iu_func_scan_in,
     iu_func_scan_in_q          => int_iu_func_scan_in_q,
     iu_func_scan_out           => int_iu_func_scan_out,
     iu_func_scan_out_q         => iu_func_scan_out_q,
     iu_bcfg_scan_in            => bcfg_scan_in,
     iu_bcfg_scan_in_q          => bcfg_scan_in_q,
     spare_func_scan_in         => spare_func_scan_in,
     spare_func_scan_in_q       => spare_func_scan_in_q,
     spare_func_scan_out        => spare_func_scan_in_q,        
     spare_func_scan_out_q      => spare_func_scan_out_q,
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
     pc_mm_bo_enable_4          => pc_mm_bo_enable_4_iiu,
     pc_iu_bo_enable_4          => pc_iu_bo_enable_4,
     pc_mm_bo_enable_3          => pc_mm_bo_enable_3_oiu,
     pc_iu_bo_enable_3          => pc_iu_bo_enable_3,
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
     pc_iu_gptr_sl_thold_3      => pc_iu_gptr_sl_thold_3,     
     pc_iu_time_sl_thold_3      => pc_iu_time_sl_thold_3,     
     pc_iu_repr_sl_thold_3      => pc_iu_repr_sl_thold_3,     
     pc_iu_abst_sl_thold_3      => pc_iu_abst_sl_thold_3,     
     pc_iu_abst_slp_sl_thold_3  => pc_iu_abst_slp_sl_thold_3, 
     pc_iu_bolt_sl_thold_3      => pc_iu_bolt_sl_thold_3,     
     pc_iu_regf_slp_sl_thold_3  => pc_iu_regf_slp_sl_thold_3, 
     pc_iu_func_sl_thold_3      => pc_iu_func_sl_thold_3,                 
     pc_iu_func_slp_sl_thold_3  => pc_iu_func_slp_sl_thold_3, 
     pc_iu_cfg_sl_thold_3       => pc_iu_cfg_sl_thold_3,      
     pc_iu_cfg_slp_sl_thold_3   => pc_iu_cfg_slp_sl_thold_3,  
     pc_iu_func_slp_nsl_thold_3 => pc_iu_func_slp_nsl_thold_3,
     pc_iu_ary_nsl_thold_3      => pc_iu_ary_nsl_thold_3,     
     pc_iu_ary_slp_nsl_thold_3  => pc_iu_ary_slp_nsl_thold_3, 
     pc_iu_sg_3                 => pc_iu_sg_3,                             
     pc_iu_fce_3                => pc_iu_fce_3,               
     pc_mm_gptr_sl_thold_3      => pc_mm_gptr_sl_thold_3,     
     pc_mm_time_sl_thold_3      => pc_mm_time_sl_thold_3,     
     pc_mm_repr_sl_thold_3      => pc_mm_repr_sl_thold_3,     
     pc_mm_abst_sl_thold_3      => pc_mm_abst_sl_thold_3,     
     pc_mm_abst_slp_sl_thold_3  => pc_mm_abst_slp_sl_thold_3,
     pc_mm_bolt_sl_thold_3      => pc_mm_bolt_sl_thold_3,
     pc_mm_func_sl_thold_3      => pc_mm_func_sl_thold_3,                  
     pc_mm_func_slp_sl_thold_3  => pc_mm_func_slp_sl_thold_3,              
     pc_mm_cfg_sl_thold_3       => pc_mm_cfg_sl_thold_3,      
     pc_mm_cfg_slp_sl_thold_3   => pc_mm_cfg_slp_sl_thold_3,  
     pc_mm_func_nsl_thold_3     => pc_mm_func_nsl_thold_3,    
     pc_mm_func_slp_nsl_thold_3 => pc_mm_func_slp_nsl_thold_3,
     pc_mm_ary_nsl_thold_3      => pc_mm_ary_nsl_thold_3,     
     pc_mm_ary_slp_nsl_thold_3  => pc_mm_ary_slp_nsl_thold_3, 
     pc_mm_sg_3                 => pc_mm_sg_3,                             
     pc_mm_fce_3                => pc_mm_fce_3,               
     sg_2                       => int_pc_iu_sg_2(0),
     func_sl_thold_2            => int_pc_iu_func_sl_thold_2(0),
     func_slp_sl_thold_2        => pc_iu_func_slp_sl_thold_2,
     abst_sl_thold_2            => pc_iu_abst_sl_thold_2,
     abst_scan_in               => rp_abst_scan_in,
     func_scan_in               => rp_func_scan_in,
     gptr_scan_in               => rp_gptr_scan_in,
     abst_scan_out              => rp_abst_scan_out,
     func_scan_out              => rp_func_scan_out,
     gptr_scan_out              => rp_gptr_scan_out
);
-- Pass thru signals
bg_pc_bo_unload_oiu                <= bg_pc_bo_unload_iiu;
bg_pc_bo_load_oiu                  <= bg_pc_bo_load_iiu;
bg_pc_bo_repair_oiu                <= bg_pc_bo_repair_iiu;
bg_pc_bo_reset_oiu                 <= bg_pc_bo_reset_iiu;
bg_pc_bo_shdata_oiu                <= bg_pc_bo_shdata_iiu;
bg_pc_bo_select_oiu                <= bg_pc_bo_select_iiu;
bg_pc_l1p_ccflush_dc_oiu           <= bg_pc_l1p_ccflush_dc_iiu;
bg_pc_l1p_abist_ena_dc_oiu         <= bg_pc_l1p_abist_ena_dc_iiu;
bg_pc_l1p_abist_raw_dc_b_oiu       <= bg_pc_l1p_abist_raw_dc_b_iiu;
ac_an_abist_done_dc_oiu            <= ac_an_abist_done_dc_iiu;
u_psro_rsig_i1: ac_an_psro_ringsig_i1_b <= not ac_an_psro_ringsig_iiu;
u_psro_rsig_i2: ac_an_psro_ringsig_i2   <= not ac_an_psro_ringsig_i1_b;
u_psro_rsig_i3: ac_an_psro_ringsig_i3_b <= not ac_an_psro_ringsig_i2;
u_psro_rsig_i4: ac_an_psro_ringsig_i4   <= not ac_an_psro_ringsig_i3_b;
u_psro_rsig_i5: ac_an_psro_ringsig_i5_b <= not ac_an_psro_ringsig_i4;
u_psro_rsig_i6: ac_an_psro_ringsig_oiu  <= not ac_an_psro_ringsig_i5_b;
mm_pc_bo_fail_oiu                  <= mm_pc_bo_fail_iiu;
mm_pc_bo_diagout_oiu               <= mm_pc_bo_diagout_iiu;
mm_pc_event_data_oiu               <= mm_pc_event_data_iiu;
bg_pc_bo_fail_oiu                  <= bg_pc_bo_fail_iiu;
bg_pc_bo_diagout_oiu               <= bg_pc_bo_diagout_iiu;
an_ac_abist_mode_dc_oiu    <= an_ac_abist_mode_dc_iiu;
an_ac_ccenable_dc_oiu      <= an_ac_ccenable_dc_iiu;
an_ac_ccflush_dc_oiu       <= an_ac_ccflush_dc_iiu;
an_ac_gsd_test_enable_dc_oiu       <= an_ac_gsd_test_enable_dc_iiu;
an_ac_gsd_test_acmode_dc_oiu       <= an_ac_gsd_test_acmode_dc_iiu;
an_ac_lbist_ip_dc_oiu      <= an_ac_lbist_ip_dc_iiu;
an_ac_lbist_ac_mode_dc_oiu <= an_ac_lbist_ac_mode_dc_iiu;
an_ac_malf_alert_oiu       <= an_ac_malf_alert_iiu;
an_ac_psro_enable_dc_oiu   <= an_ac_psro_enable_dc_iiu;
an_ac_scan_type_dc_oiu     <= an_ac_scan_type_dc_iiu;
an_ac_scom_sat_id_oiu      <= an_ac_scom_sat_id_iiu;
pc_mm_abist_dcomp_g6t_2r_oiu       <= pc_mm_abist_dcomp_g6t_2r_iiu;
pc_mm_abist_di_g6t_2r_oiu          <= pc_mm_abist_di_g6t_2r_iiu;
pc_mm_abist_di_0_oiu               <= pc_mm_abist_di_0_iiu;
pc_mm_abist_ena_dc_oiu             <= pc_mm_abist_ena_dc_iiu;
pc_mm_abist_g6t_r_wb_oiu           <= pc_mm_abist_g6t_r_wb_iiu;
pc_mm_abist_g8t_bw_0_oiu           <= pc_mm_abist_g8t_bw_0_iiu;
pc_mm_abist_g8t_bw_1_oiu           <= pc_mm_abist_g8t_bw_1_iiu;
pc_mm_abist_g8t_dcomp_oiu          <= pc_mm_abist_g8t_dcomp_iiu;
pc_mm_abist_g8t_wenb_oiu           <= pc_mm_abist_g8t_wenb_iiu;
pc_mm_abist_g8t1p_renb_0_oiu       <= pc_mm_abist_g8t1p_renb_0_iiu;
pc_mm_abist_raddr_0_oiu            <= pc_mm_abist_raddr_0_iiu;
pc_mm_abist_raw_dc_b_oiu           <= pc_mm_abist_raw_dc_b_iiu;
pc_mm_abist_waddr_0_oiu            <= pc_mm_abist_waddr_0_iiu;
pc_mm_abist_wl128_comp_ena_oiu     <= pc_mm_abist_wl128_comp_ena_iiu;
pc_mm_bo_repair_oiu                <= pc_mm_bo_repair_iiu;
pc_mm_bo_reset_oiu                 <= pc_mm_bo_reset_iiu;
pc_mm_bo_select_oiu                <= pc_mm_bo_select_iiu;
pc_mm_bo_shdata_oiu                <= pc_mm_bo_shdata_iiu;
pc_mm_bo_unload_oiu                <= pc_mm_bo_unload_iiu;
pc_mm_ccflush_dc_oiu               <= pc_mm_ccflush_dc_iiu;
pc_mm_debug_mux1_ctrls_oiu         <= pc_mm_debug_mux1_ctrls_iiu;
pc_mm_event_count_mode_oiu         <= pc_mm_event_count_mode_iiu;
pc_mm_event_mux_ctrls_oiu          <= pc_mm_event_mux_ctrls_iiu;
pc_mm_trace_bus_enable_oiu         <= pc_mm_trace_bus_enable_iiu;
pc_mm_gptr_sl_thold_3_oiu          <= pc_mm_gptr_sl_thold_3;
pc_mm_time_sl_thold_3_oiu          <= pc_mm_time_sl_thold_3;
pc_mm_repr_sl_thold_3_oiu          <= pc_mm_repr_sl_thold_3;
pc_mm_abst_sl_thold_3_oiu          <= pc_mm_abst_sl_thold_3;
pc_mm_abst_slp_sl_thold_3_oiu      <= pc_mm_abst_slp_sl_thold_3;
pc_mm_bolt_sl_thold_3_oiu          <= pc_mm_bolt_sl_thold_3;
pc_mm_func_sl_thold_3_oiu          <= pc_mm_func_sl_thold_3;
pc_mm_func_slp_sl_thold_3_oiu      <= pc_mm_func_slp_sl_thold_3;
pc_mm_cfg_sl_thold_3_oiu           <= pc_mm_cfg_sl_thold_3;
pc_mm_cfg_slp_sl_thold_3_oiu       <= pc_mm_cfg_slp_sl_thold_3;
pc_mm_func_nsl_thold_3_oiu         <= pc_mm_func_nsl_thold_3;
pc_mm_func_slp_nsl_thold_3_oiu     <= pc_mm_func_slp_nsl_thold_3;
pc_mm_ary_nsl_thold_3_oiu          <= pc_mm_ary_nsl_thold_3;
pc_mm_ary_slp_nsl_thold_3_oiu      <= pc_mm_ary_slp_nsl_thold_3;
pc_mm_sg_3_oiu                     <= pc_mm_sg_3;
pc_mm_fce_3_oiu                    <= pc_mm_fce_3;
an_ac_back_inv_oiu         <= an_ac_back_inv;
an_ac_back_inv_addr_oiu    <= an_ac_back_inv_addr;
an_ac_back_inv_target_bit1_oiu  <= an_ac_back_inv_target_iiu_a(1);
an_ac_back_inv_target_bit3_oiu  <= an_ac_back_inv_target_iiu_b(3);
an_ac_back_inv_target_bit4_oiu  <= an_ac_back_inv_target_iiu_b(4);
an_ac_atpg_en_dc_oiu       <= an_ac_atpg_en_dc;
an_ac_lbist_ary_wrt_thru_dc_oiu <= an_ac_lbist_ary_wrt_thru_dc;
an_ac_lbist_en_dc_oiu      <= an_ac_lbist_en_dc;
an_ac_scan_diag_dc_oiu     <= an_ac_scan_diag_dc;
an_ac_scan_dis_dc_b_oiu    <= an_ac_scan_dis_dc_b;
an_ac_grffence_en_dc_oiu   <= an_ac_grffence_en_dc;
an_ac_scan_dis_dc_b_oif(0)      <= an_ac_scan_dis_dc_b;
an_ac_scan_dis_dc_b_oif(1)      <= an_ac_scan_dis_dc_b;
an_ac_scan_dis_dc_b_oif(2)      <= an_ac_scan_dis_dc_b;
an_ac_scan_dis_dc_b_oif(3)      <= an_ac_scan_dis_dc_b;
an_ac_back_inv_oif              <= an_ac_back_inv;
an_ac_back_inv_target_oif(1)    <= an_ac_back_inv_target_iiu_a(1);
an_ac_sync_ack_oif              <= an_ac_sync_ack;
mm_iu_barrier_done_oif          <= mm_iu_barrier_done;
---------------------------------------
-- scan chains
---------------------------------------
--1130
iuq_ic_scan_in(0)       <= func_scan_in(0);
func_scan_out(0)        <= iuq_ic_scan_out(0);
--1046
iuq_ic_scan_in(1)       <= func_scan_in(1);
func_scan_out(1)        <= iuq_ic_scan_out(1);
--1240
iuq_ic_scan_in(2)       <= func_scan_in(2);
func_scan_out(2)        <= iuq_ic_scan_out(2);
iu_func_scan_in(0)      <= func_scan_in(3);
iuq_bp_scan_in(1)       <= int_iu_func_scan_in_q(0);
int_iu_func_scan_out(0) <= int_iuq_bp_scan_out(1);
int_iu_func_scan_out(1 to 8) <= iu_func_scan_out;
func_scan_out(3 to 11)  <= iu_func_scan_out_q(0 to 8);
--1167
iu_func_scan_in(1)      <= func_scan_in(4);
iuq_bp_scan_in(0)       <= int_iu_func_scan_in_q(1);
iu_func_scan_in(2)      <= func_scan_in(5);
iuq_mi_scan_in(0)       <= int_iu_func_scan_in_q(2);
iu_func_scan_in(3)      <= func_scan_in(6);
iu_func_scan_in_q(0)    <= int_iu_func_scan_in_q(3);
iu_func_scan_in(4)       <= func_scan_in(7);
iuq_mi_scan_in(1)       <= int_iu_func_scan_in_q(4);
iu_func_scan_in(5 to 8) <= func_scan_in(8 to 11);
iu_func_scan_in_q(1 to 4) <= int_iu_func_scan_in_q(5 to 8);
iuq_ic_scan_in(3)       <= func_scan_in(12);
func_scan_out(12)       <= iuq_ic_scan_out(3);
-- 1035
iuq_ic_scan_in(4)       <= func_scan_in(13);
iuq_uc_scan_in          <= iuq_ic_scan_out(4);
int_iu_func_scan_out(9) <= iuq_uc_scan_out;
func_scan_out(13)       <= iu_func_scan_out_q(9);
iuq_ic_time_scan_in     <= time_scan_in;
iuq_mi_time_scan_in     <= iuq_ic_time_scan_out;
time_scan_out           <= iuq_mi_time_scan_out;
iuq_ic_repr_scan_in     <= repr_scan_in;
iuq_mi_repr_scan_in     <= iuq_ic_repr_scan_out;
repr_scan_out           <= iuq_mi_repr_scan_out;
iuq_mi_abst_scan_in     <= iuq_ic_abst_scan_out(2);
rp_gptr_scan_in         <= gptr_scan_in;
iuq_mi_gptr_scan_in     <= rp_gptr_scan_out;
gptr_scan_out           <= iuq_mi_gptr_scan_out;
iuq_mi_ccfg_scan_in     <= ccfg_scan_in;
iuq_ic_ccfg_scan_in     <= iuq_mi_ccfg_scan_out;
ccfg_scan_out           <= iuq_ic_ccfg_scan_out;
iuq_mi_bcfg_scan_in     <= bcfg_scan_in_q;
bcfg_scan_out           <= iuq_mi_bcfg_scan_out;
iuq_mi_dcfg_scan_in     <= dcfg_scan_in;
dcfg_scan_out           <= iuq_mi_dcfg_scan_out;
end iuq_ifetch;


