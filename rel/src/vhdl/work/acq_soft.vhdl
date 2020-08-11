-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee; use ieee.std_logic_1164.all;
library ibm; 
library work; use work.all;
  use ibm.std_ulogic_support.all;
  use ibm.std_ulogic_function_support.all;
library support;
  use support.power_logic_pkg.all;
  use work.iuq_pkg.all;
library tri;
  use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;
  
ENTITY acq_soft IS
   GENERIC(xu_eff_ifar : integer := 62;
   expand_type         : integer := 2;
   regmode             : integer := 6;
   hvmode              : integer := 1;
   a2mode              : integer := 1;
   bcfg_epn_0to15      : integer := 0;
   bcfg_epn_16to31     : integer := 0;
   bcfg_epn_32to47     : integer := (2**16)-1;
   bcfg_epn_48to51     : integer := (2**4)-1;
   bcfg_rpn_22to31     : integer := (2**10)-1;
   bcfg_rpn_32to47     : integer := (2**16)-1;
   bcfg_rpn_48to51     : integer := (2**4)-1;
   fpr_addr_width      : integer := 5;
   lmq_entries         : integer := 8;
   threads             : integer := 4;
   ucode_mode          : integer := 1;
   uc_ifar             : integer := 21;
   data_out_width      : integer := 64;
   debug_event_width   : integer := 16;
   debug_trace_width   : integer := 88;
   epn_width           : integer := 52;
   eptr_width          : integer := 4;
   erat_ary_data_width : integer := 73;
   erat_cam_data_width : integer := 75;
   erat_rel_data_width : integer := 132;
   error_width         : integer := 3;
   expand_tlb_type     : integer := 2;
   extclass_width      : integer := 2;
   inv_seq_width       : integer := 6;
   lpid_width          : integer := 8;
   lru_width           : integer := 16;         
   mmucr0_width        : integer := 20;
   mmucr1_width        : integer := 32;
   mmucr2_width        : integer := 32;
   mmucr3_width        : integer := 15;
   pid_width           : integer := 14;
   pid_width_erat      : integer := 8;
   por_seq_width       : integer := 3;
   ra_entry_width      : integer := 12;
   real_addr_width     : integer := 42;
   req_epn_width       : integer := 52;
   rpn_width           : integer := 30;
   rs_data_width       : integer := 64;
   rs_is_width         : integer := 9;
   spr_addr_width      : integer := 10;
   spr_ctl_width       : integer := 3;
   spr_data_width      : integer := 64;
   spr_etid_width      : integer := 2;
   spr_xucr0_init_mod  : integer := 0;
   state_width         : integer := 4;
   thdid_width         : integer := 4;
   tlb_addr_width      : natural := 7;
   tlb_num_entry       : natural := 512;
   tlb_num_entry_log2  : natural := 9;
   tlb_seq_width       : integer := 6;
   tlb_tag_width       : natural := 110;
   tlb_way_width       : natural := 168;
   tlb_ways            : natural := 4;
   tlb_word_width      : natural := 84;
   tlbsel_width        : integer := 2;
   ttype_width         : integer := 4;
   vpn_width           : integer := 61;
   watermark_width     : integer := 4;
   ws_width            : integer := 2;
   dc_size             : natural := 14;       
   include_boxes       : integer := 1;
   l_endian_m          : integer := 1;
   load_credits        : integer := 4;
   xu_real_data_add    : integer := 42;
   st_data_32b_mode    : integer := 1;
   ac_st_data_32b_mode : integer := 0;
   store_credits       : integer := 20
   );
   PORT (
      an_ac_back_inv             : in    std_ulogic;
      an_ac_back_inv_addr        : in    std_ulogic_vector(64-xu_real_data_add to 63);
      an_ac_back_inv_lbit        : in    std_ulogic;
      an_ac_back_inv_gs          : in std_ulogic;
      an_ac_back_inv_ind         : in std_ulogic;
      an_ac_back_inv_local         : in std_ulogic;
      an_ac_back_inv_lpar_id     : in    std_ulogic_vector(0 to lpid_width-1);
      an_ac_back_inv_target      : in    std_ulogic_vector(0 to 4);
      an_ac_dcr_act              : in    std_ulogic;
      an_ac_dcr_val              : in    std_ulogic;
      an_ac_dcr_read             : in    std_ulogic;
      an_ac_dcr_etid             : in    std_ulogic_vector(0 to 1);
      an_ac_dcr_data             : in    std_ulogic_vector(64-(2**regmode) to 63);
      an_ac_dcr_done             : in    std_ulogic;
      an_ac_crit_interrupt       : in    std_ulogic_vector(0 to threads-1);
      an_ac_ext_interrupt        : in    std_ulogic_vector(0 to threads-1);
      an_ac_camfence_en_dc       : in    std_ulogic;                     
      an_ac_flh2l2_gate          : in    std_ulogic;                     
      an_ac_icbi_ack             : in    std_ulogic;
      an_ac_icbi_ack_thread      : in    std_ulogic_vector(0 to 1);
      an_ac_reld_core_tag        : in    std_ulogic_vector(0 to 4);
      an_ac_reld_data            : in    std_ulogic_vector(0 to 127);
      an_ac_reld_data_vld        : in    std_ulogic;
      an_ac_reld_ecc_err         : in    std_ulogic;
      an_ac_reld_ecc_err_ue      : in    std_ulogic;
      an_ac_reld_qw              : in    std_ulogic_vector(57 to 59);
      an_ac_reld_data_coming     : in    std_ulogic;
      an_ac_reld_ditc            : in    std_ulogic;
      an_ac_reld_crit_qw         : in    std_ulogic;
      an_ac_reld_l1_dump         : in    std_ulogic;
      an_ac_req_ld_pop           : in    std_ulogic;
      an_ac_req_spare_ctrl_a1    : in    std_ulogic_vector(0 to 3);
      an_ac_req_st_gather        : in    std_ulogic;
      an_ac_req_st_pop           : in    std_ulogic;
      an_ac_req_st_pop_thrd      : in    std_ulogic_vector(0 to 2);
      an_ac_reservation_vld      : in    std_ulogic_vector(0 to threads-1);
      an_ac_sleep_en             : in    std_ulogic_vector(0 to threads-1);
      an_ac_stcx_complete        : in    std_ulogic_vector(0 to 3);
      an_ac_stcx_pass            : in    std_ulogic_vector(0 to 3);
      an_ac_sync_ack             : in    std_ulogic_vector(0 to 3);
      a2_nclk                    : in    clk_logic;
      an_ac_abist_mode_dc        : in    std_ulogic;
      an_ac_abist_start_test     : in    std_ulogic;
      an_ac_abst_scan_in         : in    std_ulogic_vector(0 to 9);
      an_ac_ary_nsl_thold_7      : in    std_ulogic;
      an_ac_atpg_en_dc           : in    std_ulogic;
      an_ac_bcfg_scan_in         : in    std_ulogic_vector(0 to 4);
      an_ac_lbist_ary_wrt_thru_dc : in    std_ulogic;
      an_ac_ccenable_dc          : in    std_ulogic;
      an_ac_ccflush_dc           : in    std_ulogic;
      an_ac_coreid               : in    std_ulogic_vector(0 to 7);
      an_ac_reset_1_complete     : in    std_ulogic;
      an_ac_reset_2_complete     : in    std_ulogic;
      an_ac_reset_3_complete     : in    std_ulogic;
      an_ac_reset_wd_complete    : in    std_ulogic;
      an_ac_dcfg_scan_in         : in    std_ulogic_vector(0 to 2);
      an_ac_debug_stop           : in    std_ulogic;
      an_ac_external_mchk        : in    std_ulogic_vector(0 to 3);
      an_ac_fce_7                : in    std_ulogic;
      an_ac_func_nsl_thold_7     : in    std_ulogic;
      an_ac_func_scan_in         : in    std_ulogic_vector(0 to 63);
      an_ac_func_sl_thold_7      : in    std_ulogic;
      an_ac_gsd_test_enable_dc   : in    std_ulogic;
      an_ac_gsd_test_acmode_dc   : in    std_ulogic;
      an_ac_gptr_scan_in         : in    std_ulogic;
      an_ac_hang_pulse           : in    std_ulogic_vector(0 to threads-1);
      an_ac_lbist_en_dc          : in    std_ulogic;
      an_ac_lbist_ac_mode_dc     : in    std_ulogic;
      an_ac_lbist_ip_dc          : in    std_ulogic;  
      an_ac_malf_alert           : in    std_ulogic;
      an_ac_perf_interrupt       : in    std_ulogic_vector(0 to threads-1);
      an_ac_pm_thread_stop       : in    std_ulogic_vector(0 to 3);
      an_ac_psro_enable_dc       : in    std_ulogic_vector(0 to 2);
      an_ac_regf_scan_in         : in    std_ulogic_vector(0 to 11);
      an_ac_repr_scan_in         : in    std_ulogic;
      an_ac_rtim_sl_thold_7      : in    std_ulogic;
      an_ac_scan_diag_dc         : in    std_ulogic;
      an_ac_scan_dis_dc_b        : in    std_ulogic;
      an_ac_scan_type_dc         : in    std_ulogic_vector(0 to 8);
      an_ac_scom_cch             : in    std_ulogic;
      an_ac_scom_dch             : in    std_ulogic;
      an_ac_scom_sat_id          : in    std_ulogic_vector(0 to 3);
      an_ac_sg_7                 : in    std_ulogic;
      an_ac_checkstop            : in    std_ulogic;
      an_ac_tb_update_enable     : in    std_ulogic;
      an_ac_tb_update_pulse      : in    std_ulogic;
      an_ac_time_scan_in         : in    std_ulogic;
      ac_an_back_inv_reject      : out   std_ulogic;
      ac_an_box_empty            : out   std_ulogic_vector(0 to 3);
      ac_an_reld_ditc_pop        : out   std_ulogic_vector(0 to 3);      
      ac_an_lpar_id              : out   std_ulogic_vector(0 to lpid_width-1);
      ac_an_machine_check        : out   std_ulogic_vector(0 to threads-1);
      ac_an_power_managed        : out   std_ulogic;
      ac_an_req                  : out   std_ulogic;
      ac_an_req_endian           : out   std_ulogic;
      ac_an_req_ld_core_tag      : out   std_ulogic_vector(0 to 4);
      ac_an_req_ld_xfr_len       : out   std_ulogic_vector(0 to 2);
      ac_an_req_pwr_token        : out   std_ulogic;
      ac_an_req_ra               : out   std_ulogic_vector(64-xu_real_data_add to 63);
      ac_an_req_spare_ctrl_a0    : out   std_ulogic_vector(0 to 3);
      ac_an_req_thread           : out   std_ulogic_vector(0 to 2);
      ac_an_req_ttype            : out   std_ulogic_vector(0 to 5);
      ac_an_req_user_defined     : out   std_ulogic_vector(0 to 3);
      ac_an_req_wimg_g           : out   std_ulogic;
      ac_an_req_wimg_i           : out   std_ulogic;
      ac_an_req_wimg_m           : out   std_ulogic;
      ac_an_req_wimg_w           : out   std_ulogic;
      ac_an_rvwinkle_mode        : out   std_ulogic;
      ac_an_st_byte_enbl         : out   std_ulogic_vector(0 to 15+(st_data_32b_mode*16));
      ac_an_st_data              : out   std_ulogic_vector(0 to 127+(st_data_32b_mode*128)); 
      ac_an_st_data_pwr_token    : out   std_ulogic;
      ac_an_fu_bypass_events     : out   std_ulogic_vector(0 to 7);
      ac_an_iu_bypass_events     : out   std_ulogic_vector(0 to 7);
      ac_an_mm_bypass_events     : out   std_ulogic_vector(0 to 7);
      ac_an_lsu_bypass_events    : out   std_ulogic_vector(0 to 7);
      ac_an_debug_bus            : out   std_ulogic_vector(0 to 87);
      ac_an_event_bus            : out   std_ulogic_vector(0 to 7);
      ac_an_trace_triggers       : out   std_ulogic_vector(0 to 11);
      ac_an_abist_done_dc        : out   std_ulogic;
      ac_an_abst_scan_out        : out   std_ulogic_vector(0 to 9);
      ac_an_bcfg_scan_out        : out   std_ulogic_vector(0 to 4);
      ac_an_dcfg_scan_out        : out   std_ulogic_vector(0 to 2);
      ac_an_debug_trigger        : out   std_ulogic_vector(0 to threads-1);
      ac_an_func_scan_out        : out   std_ulogic_vector(0 to 63);
      ac_an_gptr_scan_out        : out   std_ulogic;
      ac_an_pm_thread_running    : out   std_ulogic_vector(0 to 3);
      ac_an_psro_ringsig         : out   std_ulogic;
      ac_an_recov_err            : out   std_ulogic_vector(0 to 2);
      ac_an_regf_scan_out        : out   std_ulogic_vector(0 to 11);
      ac_an_repr_scan_out        : out   std_ulogic;
      ac_an_reset_1_request      : out   std_ulogic;
      ac_an_reset_2_request      : out   std_ulogic;
      ac_an_reset_3_request      : out   std_ulogic;
      ac_an_reset_wd_request     : out   std_ulogic;
      ac_an_scom_cch             : out   std_ulogic;
      ac_an_scom_dch             : out   std_ulogic;
      ac_an_time_scan_out        : out   std_ulogic;
      ac_an_special_attn         : out   std_ulogic_vector(0 to 3);
      ac_an_checkstop            : out   std_ulogic_vector(0 to 2);
      ac_an_local_checkstop      : out   std_ulogic_vector(0 to 2);
      ac_an_trace_error          : out   std_ulogic;
      ac_an_dcr_act	         : out   std_ulogic;
      ac_an_dcr_val	         : out   std_ulogic;
      ac_an_dcr_read	         : out   std_ulogic;
      ac_an_dcr_user	         : out   std_ulogic;
      ac_an_dcr_etid	         : out   std_ulogic_vector(0 to 1);
      ac_an_dcr_addr	         : out   std_ulogic_vector(11 to 20);
      ac_an_dcr_data	         : out   std_ulogic_vector(64-(2**regmode) to 63);
      gnd                        : inout power_logic;
      vcs                        : inout power_logic;
      vdd                        : inout power_logic
   );
   -- synopsys translate_off
   -- synopsys translate_on
END acq_soft;

ARCHITECTURE acq_soft OF acq_soft IS


signal a2_nclk_copy                  : clk_logic;
signal bx_pc_err_inbox_ue            : std_ulogic;
signal bx_pc_err_outbox_ue           : std_ulogic;
signal fu_iu_uc_special              : std_ulogic_vector(0 to 3);
signal fu_pc_err_regfile_parity      : std_ulogic_vector(0 to 3);
signal fu_pc_err_regfile_ue          : std_ulogic_vector(0 to 3);
signal fu_pc_event_data              : std_ulogic_vector(0 to 7);
signal fu_pc_ram_data                : std_ulogic_vector(0 to 63);
signal fu_pc_ram_done                : std_ulogic;
signal fu_xu_ex2_async_block         : std_ulogic_vector(0 to 3);
signal fu_xu_ex1_ifar                : std_ulogic_vector(62-xu_eff_ifar to 61);
signal fu_xu_ex2_ifar_val            : std_ulogic_vector(0 to 3);
signal fu_xu_ex2_ifar_issued         : std_ulogic_vector(0 to 3); 
signal fu_xu_ex2_store_data          : std_ulogic_vector(0 to 63);
signal fu_xu_ex2_store_data_val      : std_ulogic;
signal fu_xu_ex3_ap_int_req          : std_ulogic_vector(0 to 3);
signal fu_xu_ex3_flush2ucode         : std_ulogic_vector(0 to 3);
signal fu_xu_ex2_instr_match         : std_ulogic_vector(0 to 3);
signal fu_xu_ex2_instr_type          : std_ulogic_vector(0 to 11);
signal fu_xu_ex2_is_ucode            : std_ulogic_vector(0 to 3);
signal fu_xu_ex3_n_flush             : std_ulogic_vector(0 to 3);
signal fu_xu_ex3_np1_flush           : std_ulogic_vector(0 to 3);
signal fu_xu_ex3_regfile_err_det     : std_ulogic_vector(0 to 3);
signal fu_xu_ex3_trap                : std_ulogic_vector(0 to 3);
signal fu_xu_ex4_cr                  : std_ulogic_vector(0 to 3);
signal fu_xu_ex4_cr_bf               : std_ulogic_vector(0 to 2);
signal fu_xu_ex4_cr_noflush          : std_ulogic_vector(0 to 3);
signal fu_xu_ex4_cr_val              : std_ulogic_vector(0 to 3);
signal fu_xu_regfile_seq_end         : std_ulogic;
signal fu_xu_rf1_act                 : std_ulogic_vector(0 to 3);
signal fu_bx_slowspr_addr            : std_ulogic_vector(0 to 9);
signal fu_bx_slowspr_data            : std_ulogic_vector(64-(2**regmode) to 63);
signal fu_bx_slowspr_done            : std_ulogic;
signal fu_bx_slowspr_etid            : std_ulogic_vector(0 to 1);
signal fu_bx_slowspr_rw              : std_ulogic;
signal fu_bx_slowspr_val             : std_ulogic;
signal bx_xu_slowspr_addr            : std_ulogic_vector(0 to 9);
signal bx_xu_slowspr_data            : std_ulogic_vector(64-(2**regmode) to 63);
signal bx_xu_slowspr_done            : std_ulogic;
signal bx_xu_slowspr_etid            : std_ulogic_vector(0 to 1);
signal bx_xu_slowspr_rw              : std_ulogic;
signal bx_xu_slowspr_val             : std_ulogic;
signal bx_xu_quiesce                 : std_ulogic_vector(0 to 3);
signal iu_fu_ex2_n_flush             : std_ulogic_vector(0 to 3);
signal iu_fu_is2_tid_decode          : std_ulogic_vector(0 to 3);
signal iu_fu_rf0_bypsel              : std_ulogic_vector(0 to 5);
signal iu_fu_rf0_fra                 : std_ulogic_vector(0 to 6);
signal iu_fu_rf0_fra_v               : std_ulogic;
signal iu_fu_rf0_frb                 : std_ulogic_vector(0 to 6);
signal iu_fu_rf0_frb_v               : std_ulogic;
signal iu_fu_rf0_frc                 : std_ulogic_vector(0 to 6);
signal iu_fu_rf0_frc_v               : std_ulogic;
signal iu_fu_rf0_frt                 : std_ulogic_vector(0 to 6);
signal iu_fu_rf0_ifar                : eff_ifar;
signal iu_fu_rf0_instr               : std_ulogic_vector(0 to 31);
signal iu_fu_rf0_instr_match         : std_ulogic;
signal iu_fu_rf0_instr_v             : std_ulogic;
signal iu_fu_rf0_is_ucode            : std_ulogic;
signal iu_fu_rf0_ucfmul              : std_ulogic;
signal iu_fu_rf0_ldst_val            : std_ulogic;
signal iu_fu_rf0_ldst_tid            : std_ulogic_vector(0 to 1);
signal iu_fu_rf0_ldst_tag            : std_ulogic_vector(0 to 8);
signal iu_fu_rf0_str_val             : std_ulogic;
signal iu_fu_rf0_tid                 : std_ulogic_vector(0 to 1);
signal iu_mm_ierat_epn               : std_ulogic_vector(0 to 51);
signal iu_mm_ierat_flush             : std_ulogic_vector(0 to 3);
signal iu_mm_ierat_mmucr0            : std_ulogic_vector(0 to 17);
signal iu_mm_ierat_mmucr0_we         : std_ulogic_vector(0 to 3);
signal iu_mm_ierat_mmucr1            : std_ulogic_vector(0 to 3);
signal iu_mm_ierat_mmucr1_we         : std_ulogic;
signal iu_mm_ierat_req               : std_ulogic;
signal iu_mm_ierat_snoop_ack         : std_ulogic;
signal iu_mm_ierat_thdid             : std_ulogic_vector(0 to 3);
signal iu_mm_ierat_tid               : std_ulogic_vector(0 to 13);
signal iu_mm_ierat_state             : std_ulogic_vector(0 to 3);
signal iu_mm_lmq_empty               : std_ulogic;
signal iu_pc_err_icache_parity       : std_ulogic;
signal iu_pc_err_icachedir_multihit  : std_ulogic;
signal iu_pc_err_icachedir_parity    : std_ulogic;
signal iu_pc_err_ucode_illegal       : std_ulogic_vector(0 to 3);
signal iu_pc_event_data              : std_ulogic_vector(0 to 7);
signal iu_pc_slowspr_addr            : std_ulogic_vector(0 to 9);
signal iu_pc_slowspr_data            : std_ulogic_vector(64-(2**regmode) to 63);
signal iu_pc_slowspr_done            : std_ulogic;
signal iu_pc_slowspr_etid            : std_ulogic_vector(0 to 1);
signal iu_pc_slowspr_rw              : std_ulogic;
signal iu_pc_slowspr_val             : std_ulogic;
signal iu_xu_ex4_tlb_data            : std_ulogic_vector(64-(2**regmode) to 63);
signal iu_xu_ierat_ex2_flush_req     : std_ulogic_vector(0 to threads-1);
signal iu_xu_ierat_ex3_par_err       : std_ulogic_vector(0 to threads-1);
signal iu_xu_ierat_ex4_par_err       : std_ulogic_vector(0 to threads-1);
signal iu_xu_is2_axu_instr_type      : std_ulogic_vector(0 to 2);
signal iu_xu_is2_axu_ld_or_st        : std_ulogic;
signal iu_xu_is2_axu_ldst_extpid     : std_ulogic;
signal iu_xu_is2_axu_ldst_forcealign : std_ulogic;
signal iu_xu_is2_axu_ldst_forceexcept : std_ulogic;
signal iu_xu_is2_axu_ldst_indexed    : std_ulogic;
signal iu_xu_is2_axu_ldst_size       : std_ulogic_vector(0 to 5);
signal iu_xu_is2_axu_ldst_tag        : std_ulogic_vector(0 to 8);
signal iu_xu_is2_axu_ldst_update     : std_ulogic;
signal iu_xu_is2_axu_mffgpr          : std_ulogic;
signal iu_xu_is2_axu_mftgpr          : std_ulogic;
signal iu_xu_is2_axu_movedp          : std_ulogic;
signal iu_xu_is2_axu_store           : std_ulogic;
signal iu_xu_is2_error               : std_ulogic_vector(0 to 2);
signal iu_xu_is2_gshare              : std_ulogic_vector(0 to 3);
signal iu_xu_is2_ifar                : eff_ifar;
signal iu_xu_is2_instr               : std_ulogic_vector(0 to 31);
signal iu_xu_is2_is_ucode            : std_ulogic;
signal iu_xu_is2_match               : std_ulogic;
signal iu_xu_is2_pred_taken_cnt      : std_ulogic_vector(0 to 1);
signal iu_xu_is2_pred_update         : std_ulogic;
signal iu_xu_is2_s1                  : std_ulogic_vector(0 to 5);
signal iu_xu_is2_s1_vld              : std_ulogic;
signal iu_xu_is2_s2                  : std_ulogic_vector(0 to 5);
signal iu_xu_is2_s2_vld              : std_ulogic;
signal iu_xu_is2_s3                  : std_ulogic_vector(0 to 5);
signal iu_xu_is2_s3_vld              : std_ulogic;
signal iu_xu_is2_ta                  : std_ulogic_vector(0 to 5);
signal iu_xu_is2_ta_vld              : std_ulogic;
signal iu_xu_is2_tid                 : std_ulogic_vector(0 to 3);
signal iu_xu_is2_ucode_vld           : std_ulogic;
signal iu_xu_is2_vld                 : std_ulogic;
signal iu_xu_quiesce                 : std_ulogic_vector(0 to threads-1);
signal iu_xu_ra                      : std_ulogic_vector(real_ifar'left to 59);
signal iu_xu_request                 : std_ulogic;
signal iu_xu_thread                  : std_ulogic_vector(0 to 3);
signal iu_xu_userdef                 : std_ulogic_vector(0 to 3);
signal iu_xu_wimge                   : std_ulogic_vector(0 to 4);
signal mm_iu_ierat_mmucr0_0          : std_ulogic_vector(0 to 19);
signal mm_iu_ierat_mmucr0_1          : std_ulogic_vector(0 to 19);
signal mm_iu_ierat_mmucr0_2          : std_ulogic_vector(0 to 19);
signal mm_iu_ierat_mmucr0_3          : std_ulogic_vector(0 to 19);
signal mm_iu_ierat_mmucr1            : std_ulogic_vector(0 to 8);
signal mm_iu_ierat_pid0              : std_ulogic_vector(0 to 13);
signal mm_iu_ierat_pid1              : std_ulogic_vector(0 to 13);
signal mm_iu_ierat_pid2              : std_ulogic_vector(0 to 13);
signal mm_iu_ierat_pid3              : std_ulogic_vector(0 to 13);
signal mm_iu_ierat_rel_data          : std_ulogic_vector(0 to 131);
signal mm_iu_ierat_rel_val           : std_ulogic_vector(0 to 4);
signal mm_iu_ierat_snoop_attr        : std_ulogic_vector(0 to 25);
signal mm_iu_ierat_snoop_coming      : std_ulogic;
signal mm_iu_ierat_snoop_val         : std_ulogic;
signal mm_iu_ierat_snoop_vpn         : std_ulogic_vector(52-epn_width to 51);
signal mm_iu_slowspr_addr            : std_ulogic_vector(0 to 9);
signal mm_iu_slowspr_data            : std_ulogic_vector(64-spr_data_width to 63);
signal mm_iu_slowspr_done            : std_ulogic;
signal mm_iu_slowspr_etid            : std_ulogic_vector(0 to 1);
signal mm_iu_slowspr_rw              : std_ulogic;
signal mm_iu_slowspr_val             : std_ulogic;
signal xu_pc_err_mcsr_summary        : std_ulogic_vector(0 to threads-1);
signal xu_pc_err_ierat_parity        : std_ulogic;
signal xu_pc_err_derat_parity        : std_ulogic;
signal xu_pc_err_tlb_parity          : std_ulogic;
signal xu_pc_err_tlb_lru_parity      : std_ulogic;
signal xu_pc_err_ierat_multihit      : std_ulogic;
signal xu_pc_err_derat_multihit      : std_ulogic;
signal xu_pc_err_tlb_multihit        : std_ulogic;
signal xu_pc_err_ext_mchk            : std_ulogic;
signal xu_pc_err_local_snoop_reject  : std_ulogic;
signal mm_xu_derat_mmucr0_0          : std_ulogic_vector(0 to 19);
signal mm_xu_derat_mmucr0_1          : std_ulogic_vector(0 to 19);
signal mm_xu_derat_mmucr0_2          : std_ulogic_vector(0 to 19);
signal mm_xu_derat_mmucr0_3          : std_ulogic_vector(0 to 19);
signal mm_xu_derat_mmucr1            : std_ulogic_vector(0 to 9);
signal mm_xu_derat_pid0              : std_ulogic_vector(0 to 13);
signal mm_xu_derat_pid1              : std_ulogic_vector(0 to 13);
signal mm_xu_derat_pid2              : std_ulogic_vector(0 to 13);
signal mm_xu_derat_pid3              : std_ulogic_vector(0 to 13);
signal mm_xu_derat_rel_data          : std_ulogic_vector(0 to 131);
signal mm_xu_derat_rel_val           : std_ulogic_vector(0 to 4);
signal mm_xu_derat_snoop_attr        : std_ulogic_vector(0 to 25);
signal mm_xu_derat_snoop_coming      : std_ulogic;
signal mm_xu_derat_snoop_val         : std_ulogic;
signal mm_xu_derat_snoop_vpn         : std_ulogic_vector(52-epn_width to 51);
signal mm_iu_barrier_done            : std_ulogic_vector(0 to 3);
signal mm_xu_eratmiss_done           : std_ulogic_vector(0 to 3);
signal mm_xu_esr_pt                  : std_ulogic_vector(0 to 3);
signal mm_xu_esr_data                : std_ulogic_vector(0 to 3);
signal mm_xu_esr_epid                : std_ulogic_vector(0 to 3);
signal mm_xu_esr_st                  : std_ulogic_vector(0 to 3);
signal mm_xu_ex3_flush_req           : std_ulogic_vector(0 to 3);
signal xu_mm_rf1_is_tlbsxr           : std_ulogic;
signal mm_xu_hold_done               : std_ulogic_vector(0 to 3);
signal mm_xu_hold_req                : std_ulogic_vector(0 to 3);
signal mm_xu_hv_priv                 : std_ulogic_vector(0 to threads-1);
signal mm_xu_illeg_instr             : std_ulogic_vector(0 to threads-1);
signal mm_xu_lru_par_err             : std_ulogic_vector(0 to 3);
signal mm_xu_lrat_miss               : std_ulogic_vector(0 to 3);
signal mm_xu_local_snoop_reject      : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_lsu_addr                : std_ulogic_vector(64-real_addr_width to 63);
signal mm_xu_lsu_lpid                : std_ulogic_vector(0 to 7);
signal mm_xu_lsu_lpidr               : std_ulogic_vector(0 to 7);
signal mm_xu_lsu_gs                  : std_ulogic;
signal mm_xu_lsu_ind                 : std_ulogic;
signal mm_xu_lsu_lbit                : std_ulogic;
signal mm_xu_lsu_req                 : std_ulogic_vector(0 to 3);
signal mm_xu_lsu_ttype               : std_ulogic_vector(0 to 1);
signal mm_xu_lsu_u                   : std_ulogic_vector(0 to 3);
signal mm_xu_lsu_wimge               : std_ulogic_vector(0 to 4);
signal mm_xu_pt_fault                : std_ulogic_vector(0 to 3);
signal mm_xu_quiesce                 : std_ulogic_vector(0 to threads-1);
signal mm_xu_tlb_inelig              : std_ulogic_vector(0 to 3);
signal mm_xu_tlb_miss                : std_ulogic_vector(0 to 3);
signal mm_xu_tlb_multihit_err        : std_ulogic_vector(0 to 3);
signal mm_xu_tlb_par_err             : std_ulogic_vector(0 to 3);
signal mm_xu_cr0_eq                  : std_ulogic_vector(0 to 3);
signal mm_xu_cr0_eq_valid            : std_ulogic_vector(0 to 3);
signal pc_bx_inj_inbox_ecc           : std_ulogic;
signal pc_bx_inj_outbox_ecc          : std_ulogic;
signal pc_fu_abst_sl_thold_3         : std_ulogic;
signal pc_fu_abst_slp_sl_thold_3     : std_ulogic;
signal pc_fu_ary_nsl_thold_3         : std_ulogic;
signal pc_fu_ary_slp_nsl_thold_3     : std_ulogic;
signal pc_fu_cfg_sl_thold_3          : std_ulogic;
signal pc_fu_cfg_slp_sl_thold_3      : std_ulogic;
signal pc_bx_debug_mux1_ctrls        : std_ulogic_vector(0 to 15);
signal pc_fu_debug_mux1_ctrls        : std_ulogic_vector(0 to 15);
signal pc_fu_fce_3                   : std_ulogic;
signal pc_fu_func_nsl_thold_3        : std_ulogic;
signal pc_fu_func_sl_thold_3         : std_ulogic_vector(0 to 1);
signal pc_fu_func_slp_nsl_thold_3    : std_ulogic;
signal pc_fu_func_slp_sl_thold_3     : std_ulogic_vector(0 to 1);
signal pc_fu_gptr_sl_thold_3         : std_ulogic;
signal pc_fu_ram_mode                : std_ulogic;
signal pc_fu_ram_thread              : std_ulogic_vector(0 to 1);
signal pc_fu_repr_sl_thold_3         : std_ulogic;
signal pc_fu_sg_3                    : std_ulogic_vector(0 to 1);
signal pc_fu_slowspr_addr            : std_ulogic_vector(0 to 9);
signal pc_fu_slowspr_data            : std_ulogic_vector(64-(2**regmode) to 63);
signal pc_fu_slowspr_done            : std_ulogic;
signal pc_fu_slowspr_etid            : std_ulogic_vector(0 to 1);
signal pc_fu_slowspr_rw              : std_ulogic;
signal pc_fu_slowspr_val             : std_ulogic;
signal pc_bx_trace_bus_enable        : std_ulogic;
signal pc_fu_time_sl_thold_3         : std_ulogic;
signal pc_fu_trace_bus_enable        : std_ulogic;
signal pc_iu_gptr_sl_thold_4         : std_ulogic;
signal pc_iu_time_sl_thold_4         : std_ulogic;
signal pc_iu_repr_sl_thold_4         : std_ulogic;
signal pc_iu_abst_sl_thold_4         : std_ulogic;
signal pc_iu_abst_slp_sl_thold_4     : std_ulogic;
signal pc_iu_bolt_sl_thold_4         : std_ulogic;
signal pc_iu_regf_slp_sl_thold_4     : std_ulogic;
signal pc_iu_func_sl_thold_4         : std_ulogic;
signal pc_iu_func_slp_sl_thold_4     : std_ulogic;
signal pc_iu_cfg_sl_thold_4          : std_ulogic;
signal pc_iu_cfg_slp_sl_thold_4      : std_ulogic;
signal pc_iu_func_nsl_thold_4        : std_ulogic;
signal pc_iu_func_slp_nsl_thold_4    : std_ulogic;
signal pc_iu_ary_nsl_thold_4         : std_ulogic;
signal pc_iu_ary_slp_nsl_thold_4     : std_ulogic;
signal pc_iu_sg_4                    : std_ulogic;
signal pc_iu_fce_4                   : std_ulogic;
signal pc_iu_debug_mux1_ctrls        : std_ulogic_vector(0 to 15);
signal pc_iu_debug_mux2_ctrls        : std_ulogic_vector(0 to 15);
signal pc_iu_init_reset              : std_ulogic;
signal pc_iu_inj_icache_parity       : std_ulogic;
signal pc_iu_inj_icachedir_parity    : std_ulogic;
signal pc_iu_inj_icachedir_multihit  : std_ulogic;
signal pc_iu_ram_force_cmplt         : std_ulogic;
signal pc_iu_ram_instr               : std_ulogic_vector(0 to 31);
signal pc_iu_ram_instr_ext           : std_ulogic_vector(0 to 3);
signal pc_iu_ram_mode                : std_ulogic;
signal pc_iu_ram_thread              : std_ulogic_vector(0 to 1);
signal pc_iu_trace_bus_enable        : std_ulogic;
signal pc_xu_abst_sl_thold_3         : std_ulogic;
signal pc_xu_abst_slp_sl_thold_3     : std_ulogic;
signal pc_xu_regf_sl_thold_3         : std_ulogic;
signal pc_xu_regf_slp_sl_thold_3     : std_ulogic;
signal pc_xu_ary_nsl_thold_3         : std_ulogic;
signal pc_xu_ary_slp_nsl_thold_3     : std_ulogic;
signal pc_xu_cache_par_err_event     : std_ulogic;
signal pc_xu_cfg_sl_thold_3          : std_ulogic;
signal pc_xu_cfg_slp_sl_thold_3      : std_ulogic;
signal pc_xu_dbg_action              : std_ulogic_vector(0 to 11);
signal pc_xu_decrem_dis_on_stop      : std_ulogic;
signal spr_pvr_version_dc            : std_ulogic_vector(8 to 15);
signal spr_pvr_revision_dc           : std_ulogic_vector(12 to 15);
signal xu_pc_spr_ccr0_we             : std_ulogic_vector(0 to 3);
signal xu_pc_spr_ccr0_pme            : std_ulogic_vector(0 to 1);
signal pc_xu_debug_mux1_ctrls        : std_ulogic_vector(0 to 15);
signal pc_xu_debug_mux2_ctrls        : std_ulogic_vector(0 to 15);
signal pc_xu_debug_mux3_ctrls        : std_ulogic_vector(0 to 15);
signal pc_xu_debug_mux4_ctrls        : std_ulogic_vector(0 to 15);
signal pc_xu_extirpts_dis_on_stop    : std_ulogic;
signal pc_xu_fce_3                   : std_ulogic_vector(0 to 1);
signal pc_xu_force_ude               : std_ulogic_vector(0 to 3);
signal pc_xu_func_nsl_thold_3        : std_ulogic;
signal pc_xu_func_sl_thold_3         : std_ulogic_vector(0 to 4);
signal pc_xu_func_slp_nsl_thold_3    : std_ulogic;
signal pc_xu_func_slp_sl_thold_3     : std_ulogic_vector(0 to 4);
signal pc_xu_gptr_sl_thold_3         : std_ulogic;
signal pc_xu_init_reset              : std_ulogic;
signal pc_xu_inj_dcache_parity       : std_ulogic;
signal pc_xu_inj_dcachedir_parity    : std_ulogic;
signal pc_xu_inj_llbust_attempt      : std_ulogic_vector(0 to 3);
signal pc_xu_inj_llbust_failed       : std_ulogic_vector(0 to 3);
signal pc_xu_inj_sprg_ecc            : std_ulogic_vector(0 to 3);
signal pc_xu_inj_regfile_parity      : std_ulogic_vector(0 to 3);
signal pc_xu_inj_wdt_reset           : std_ulogic_vector(0 to 3);
signal pc_xu_inj_dcachedir_multihit  : std_ulogic;
signal pc_xu_msrovride_enab          : std_ulogic;
signal pc_xu_msrovride_pr            : std_ulogic;
signal pc_xu_msrovride_gs            : std_ulogic;
signal pc_xu_ram_mode                : std_ulogic;
signal pc_xu_ram_thread              : std_ulogic_vector(0 to 1);
signal pc_xu_ram_execute             : std_ulogic;
signal pc_xu_repr_sl_thold_3         : std_ulogic;
signal pc_xu_reset_1_complete        : std_ulogic;
signal pc_xu_reset_2_complete        : std_ulogic;
signal pc_xu_reset_3_complete        : std_ulogic;
signal pc_xu_reset_wd_complete       : std_ulogic;
signal pc_xu_sg_3                    : std_ulogic_vector(0 to 4);
signal pc_xu_step                    : std_ulogic_vector(0 to 3);
signal pc_xu_stop                    : std_ulogic_vector(0 to 3);
signal pc_xu_timebase_dis_on_stop    : std_ulogic;
signal pc_xu_time_sl_thold_3         : std_ulogic;
signal pc_xu_trace_bus_enable        : std_ulogic;
signal xu_n_is2_flush                : std_ulogic_vector(0 to threads-1);
signal xu_n_rf0_flush                : std_ulogic_vector(0 to threads-1);
signal xu_n_rf1_flush                : std_ulogic_vector(0 to threads-1);
signal xu_n_ex1_flush                : std_ulogic_vector(0 to threads-1);
signal xu_n_ex2_flush                : std_ulogic_vector(0 to threads-1);
signal xu_n_ex3_flush                : std_ulogic_vector(0 to threads-1);
signal xu_n_ex4_flush                : std_ulogic_vector(0 to threads-1);
signal xu_n_ex5_flush                : std_ulogic_vector(0 to threads-1);
signal xu_s_rf1_flush                : std_ulogic_vector(0 to threads-1);
signal xu_s_ex1_flush                : std_ulogic_vector(0 to threads-1);
signal xu_s_ex2_flush                : std_ulogic_vector(0 to threads-1);
signal xu_s_ex3_flush                : std_ulogic_vector(0 to threads-1);
signal xu_s_ex4_flush                : std_ulogic_vector(0 to threads-1);
signal xu_s_ex5_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wu_rf1_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wu_ex1_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wu_ex2_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wu_ex3_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wu_ex4_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wu_ex5_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wl_rf1_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wl_ex1_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wl_ex2_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wl_ex3_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wl_ex4_flush                : std_ulogic_vector(0 to threads-1);
signal xu_wl_ex5_flush                : std_ulogic_vector(0 to threads-1);
signal xu_fu_ccr2_ap                 : std_ulogic_vector(0 to threads-1);
signal xu_fu_ex3_eff_addr            : std_ulogic_vector(59 to 63);
signal xu_fu_ex6_load_data           : std_ulogic_vector(0 to 255);
signal xu_fu_ex5_load_le             : std_ulogic;
signal xu_fu_ex5_load_tag            : std_ulogic_vector(0 to 8);
signal xu_fu_ex5_load_val            : std_ulogic_vector(0 to threads-1);
signal xu_fu_ex5_reload_val          : std_ulogic;
signal xu_fu_msr_fp                  : std_ulogic_vector(0 to 3);
signal xu_fu_msr_pr                  : std_ulogic_vector(0 to 3);
signal xu_fu_msr_gs                  : std_ulogic_vector(0 to 3);
signal xu_fu_msr_spv                 : std_ulogic_vector(0 to threads-1);
signal xu_fu_regfile_seq_beg         : std_ulogic;
signal xu_iu_complete_qentry         : std_ulogic_vector(0 to lmq_entries-1);
signal xu_iu_complete_target_type    : std_ulogic_vector(0 to 1);
signal xu_iu_complete_tid            : std_ulogic_vector(0 to 3);
signal xu_iu_ex1_ra_entry            : std_ulogic_vector(8 to 11);
signal xu_iu_ex1_rb                  : std_ulogic_vector(64-(2**regmode) to 51);
signal xu_iu_ex1_rs_is               : std_ulogic_vector(0 to 8);
signal xu_iu_ex5_bclr                : std_ulogic;
signal xu_iu_ex5_bh                  : std_ulogic_vector(0 to 1);
signal xu_iu_ex5_br_hist             : std_ulogic_vector(0 to 1);
signal xu_iu_ex5_br_taken            : std_ulogic;
signal xu_iu_ex5_br_update           : std_ulogic;
signal xu_iu_ex5_getNIA              : std_ulogic;
signal xu_iu_ex5_gshare              : std_ulogic_vector(0 to 3);
signal xu_iu_ex5_ifar                : std_ulogic_vector(62-xu_eff_ifar to 61);
signal xu_iu_ex5_lk                  : std_ulogic;
signal xu_iu_ex5_ppc_cpl             : std_ulogic_vector(0 to 3);
signal xu_iu_ex4_loadmiss_qentry     : std_ulogic_vector(0 to lmq_entries-1);
signal xu_iu_ex4_loadmiss_target     : std_ulogic_vector(0 to 8);
signal xu_iu_ex4_loadmiss_target_type: std_ulogic_vector(0 to 1);
signal xu_iu_ex4_loadmiss_tid        : std_ulogic_vector(0 to 3);
signal xu_iu_ex4_rs_data             : std_ulogic_vector(64-(2**regmode) to 63);
signal xu_iu_ex5_tid                 : std_ulogic_vector(0 to threads-1);
signal xu_iu_ex5_val                 : std_ulogic;
signal xu_iu_ex5_loadmiss_qentry     : std_ulogic_vector(0 to lmq_entries-1);
signal xu_iu_ex5_loadmiss_target     : std_ulogic_vector(0 to 8);
signal xu_iu_ex5_loadmiss_target_type: std_ulogic_vector(0 to 1);
signal xu_iu_ex5_loadmiss_tid        : std_ulogic_vector(0 to 3);
signal xu_iu_ex6_icbi_val            : std_ulogic_vector(0 to threads-1);
signal xu_iu_ex6_icbi_addr           : std_ulogic_vector(64-xu_real_data_add to 57);
signal xu_iu_ex6_pri                 : std_ulogic_vector(0 to 2);
signal xu_iu_ex6_pri_val             : std_ulogic_vector(0 to 3);
signal xu_iu_flush_2ucode            : std_ulogic_vector(0 to 3);
signal xu_iu_flush_2ucode_type       : std_ulogic_vector(0 to 3);
signal xu_iu_hid_mmu_mode            : std_ulogic;
signal xu_iu_xucr0_rel               : std_ulogic;
signal xu_iu_ici                     : std_ulogic;
signal xu_iu_iu0_flush_ifar0         : std_ulogic_vector(62-xu_eff_ifar to 61);
signal xu_iu_iu0_flush_ifar1         : std_ulogic_vector(62-xu_eff_ifar to 61);
signal xu_iu_iu0_flush_ifar2         : std_ulogic_vector(62-xu_eff_ifar to 61);
signal xu_iu_iu0_flush_ifar3         : std_ulogic_vector(62-xu_eff_ifar to 61);
signal xu_iu_larx_done_tid           : std_ulogic_vector(0 to 3);
signal xu_iu_membar_tid              : std_ulogic_vector(0 to 3);
signal xu_iu_msr_cm                  : std_ulogic_vector(0 to threads-1);
signal xu_iu_msr_gs                  : std_ulogic_vector(0 to 3);
signal xu_iu_msr_hv                  : std_ulogic_vector(0 to threads-1);
signal xu_iu_msr_is                  : std_ulogic_vector(0 to threads-1);
signal xu_iu_msr_pr                  : std_ulogic_vector(0 to threads-1);
signal xu_iu_multdiv_done            : std_ulogic_vector(0 to threads-1);
signal xu_iu_need_hole               : std_ulogic;
signal xu_iu_raise_iss_pri           : std_ulogic_vector(0 to 3);
signal xu_iu_ram_issue               : std_ulogic_vector(0 to threads-1);
signal xu_iu_ex1_is_csync            : std_ulogic;
signal xu_iu_ex1_is_isync            : std_ulogic;
signal xu_iu_rf1_is_eratilx          : std_ulogic;
signal xu_iu_rf1_is_eratre           : std_ulogic;
signal xu_iu_rf1_is_eratsx           : std_ulogic;
signal xu_iu_rf1_is_eratwe           : std_ulogic;
signal xu_iu_rf1_val                 : std_ulogic_vector(0 to 3);
signal xu_iu_rf1_ws                  : std_ulogic_vector(0 to 1);
signal xu_iu_rf1_t                   : std_ulogic_vector(0 to 2);
signal xu_iu_run_thread              : std_ulogic_vector(0 to 3);
signal xu_iu_set_barr_tid            : std_ulogic_vector(0 to 3);
signal xu_iu_single_instr_mode       : std_ulogic_vector(0 to threads-1);
signal xu_iu_slowspr_done            : std_ulogic_vector(0 to 3);
signal xu_iu_spr_ccr2_en_dcr         : std_ulogic;
signal xu_iu_spr_ccr2_ifratsc        : std_ulogic_vector(0 to 8);
signal xu_iu_spr_ccr2_ifrat          : std_ulogic;
signal xu_bx_ccr2_en_ditc            : std_ulogic;
signal xu_iu_spr_xer0                : std_ulogic_vector(57 to 63);
signal xu_iu_spr_xer1                : std_ulogic_vector(57 to 63);
signal xu_iu_spr_xer2                : std_ulogic_vector(57 to 63);
signal xu_iu_spr_xer3                : std_ulogic_vector(57 to 63);
signal xu_iu_uc_flush_ifar0          : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_uc_flush_ifar1          : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_uc_flush_ifar2          : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_uc_flush_ifar3          : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_ucode_restart           : std_ulogic_vector(0 to 3);
signal xu_mm_derat_epn               : std_ulogic_vector(64-rs_data_width to 51);
signal xu_mm_derat_lpid              : std_ulogic_vector(0 to lpid_width-1);
signal xu_mm_derat_mmucr0            : std_ulogic_vector(0 to 17);
signal xu_mm_derat_mmucr0_we         : std_ulogic_vector(0 to 3);
signal xu_mm_derat_mmucr1            : std_ulogic_vector(0 to 4);
signal xu_mm_derat_mmucr1_we         : std_ulogic;
signal xu_mm_derat_req               : std_ulogic;
signal xu_mm_derat_snoop_ack         : std_ulogic;
signal xu_mm_derat_thdid             : std_ulogic_vector(0 to 3);
signal xu_mm_derat_tid               : std_ulogic_vector(0 to pid_width-1);
signal xu_mm_derat_ttype             : std_ulogic_vector(0 to 1);
signal xu_mm_derat_state             : std_ulogic_vector(0 to 3);
signal xu_mm_ex2_eff_addr            : std_ulogic_vector(64-rs_data_width to 63);
signal xu_mm_ex1_rs_is               : std_ulogic_vector(0 to 8);
signal xu_mm_ex4_flush               : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_ex5_flush               : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_ex5_perf_dtlb           : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_ex5_perf_itlb           : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_hid_mmu_mode            : std_ulogic;
signal xu_mm_hold_ack                : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_ierat_flush             : std_ulogic_vector(0 to threads-1);
signal xu_mm_ierat_miss              : std_ulogic_vector(0 to threads-1);
signal xu_mm_lmq_stq_empty           : std_ulogic;
signal xu_mm_lsu_token               : std_ulogic;
signal xu_mm_msr_cm                  : std_ulogic_vector(0 to threads-1);
signal xu_mm_msr_ds                  : std_ulogic_vector(0 to threads-1);
signal xu_mm_msr_gs                  : std_ulogic_vector(0 to threads-1);
signal xu_mm_msr_is                  : std_ulogic_vector(0 to threads-1);
signal xu_mm_msr_pr                  : std_ulogic_vector(0 to threads-1);
signal xu_mm_ex1_is_csync            : std_ulogic;
signal xu_mm_ex1_is_isync            : std_ulogic;
signal xu_mm_rf1_is_eratilx          : std_ulogic;
signal xu_mm_rf1_is_erativax         : std_ulogic;
signal xu_mm_rf1_is_tlbilx           : std_ulogic;
signal xu_mm_rf1_is_tlbivax          : std_ulogic;
signal xu_mm_rf1_is_tlbre            : std_ulogic;
signal xu_mm_rf1_is_tlbsx            : std_ulogic;
signal xu_mm_rf1_is_tlbsrx           : std_ulogic;
signal xu_mm_rf1_is_tlbwe            : std_ulogic;
signal xu_mm_rf1_val                 : std_ulogic_vector(0 to 3);
signal xu_mm_rf1_t                   : std_ulogic_vector(0 to 2);
signal xu_mm_slowspr_addr            : std_ulogic_vector(0 to 9);
signal xu_mm_slowspr_data            : std_ulogic_vector(64-(2**regmode) to 63);
signal xu_mm_slowspr_done            : std_ulogic;
signal xu_mm_slowspr_etid            : std_ulogic_vector(0 to 1);
signal xu_mm_slowspr_rw              : std_ulogic;
signal xu_mm_slowspr_val             : std_ulogic;
signal xu_mm_spr_epcr_dgtmi          : std_ulogic_vector(0 to threads-1);
signal xu_mm_spr_epcr_dmiuh          : std_ulogic_vector(0 to thdid_width-1);
signal xu_pc_err_attention_instr     : std_ulogic_vector(0 to 3);
signal xu_pc_err_dcache_parity       : std_ulogic;
signal xu_pc_err_dcachedir_parity    : std_ulogic;
signal xu_pc_err_dcachedir_multihit  : std_ulogic;
signal xu_pc_err_debug_event         : std_ulogic_vector(0 to 3);
signal xu_pc_err_ditc_overrun        : std_ulogic;
signal bx_pc_err_inbox_ecc           : std_ulogic;
signal xu_pc_err_invld_reld          : std_ulogic;
signal bx_pc_err_outbox_ecc          : std_ulogic;
signal xu_pc_err_l2intrf_ecc         : std_ulogic;
signal xu_pc_err_l2intrf_ue          : std_ulogic;
signal xu_pc_err_l2credit_overrun    : std_ulogic;
signal xu_pc_err_llbust_attempt      : std_ulogic_vector(0 to 3);
signal xu_pc_err_llbust_failed       : std_ulogic_vector(0 to 3);
signal xu_pc_err_nia_miscmpr         : std_ulogic_vector(0 to 3);
signal xu_pc_err_regfile_parity      : std_ulogic_vector(0 to 3);
signal xu_pc_err_regfile_ue          : std_ulogic_vector(0 to 3);
signal xu_pc_err_sprg_ecc            : std_ulogic_vector(0 to 3);
signal xu_pc_err_sprg_ue             : std_ulogic_vector(0 to 3);
signal xu_pc_err_wdt_reset           : std_ulogic_vector(0 to 3);
signal xu_pc_event_data              : std_ulogic_vector(0 to 7);
signal xu_pc_lsu_event_data          : std_ulogic_vector(0 to 7);
signal xu_pc_ram_data                : std_ulogic_vector(64-(2**regmode) to 63);
signal xu_pc_ram_done                : std_ulogic;
signal xu_pc_ram_interrupt           : std_ulogic;
signal xu_pc_running                 : std_ulogic_vector(0 to 3);
signal xu_pc_step_done               : std_ulogic_vector(0 to threads-1);
signal xu_pc_stop_dbg_event          : std_ulogic_vector(0 to 3);
signal pc_fu_ccflush_dc               : std_ulogic;
signal pc_iu_ccflush_dc               : std_ulogic;
signal pc_xu_ccflush_dc               : std_ulogic;
signal pc_bx_ccflush_dc               : std_ulogic;
signal pc_fu_event_count_mode         : std_ulogic_vector(0 to 2);
signal pc_iu_event_count_mode         : std_ulogic_vector(0 to 2);
signal pc_xu_event_count_mode         : std_ulogic_vector(0 to 2);
signal pc_fu_inj_regfile_parity       : std_ulogic_vector(0 to 3);
signal pc_fu_instr_trace_mode         : std_ulogic;
signal pc_fu_instr_trace_tid          : std_ulogic_vector(0 to 1);
signal pc_xu_instr_trace_mode         : std_ulogic;
signal pc_xu_instr_trace_tid          : std_ulogic_vector(0 to 1);
signal pc_xu_ram_flush_thread         : std_ulogic;
signal pc_bx_abist_di_0               : std_ulogic_vector(0 to 3);
signal pc_bx_abist_ena_dc             : std_ulogic;
signal pc_bx_abist_g8t1p_renb_0       : std_ulogic;
signal pc_bx_abist_g8t_bw_0           : std_ulogic;
signal pc_bx_abist_g8t_bw_1           : std_ulogic;
signal pc_bx_abist_g8t_dcomp          : std_ulogic_vector(0 to 3);
signal pc_bx_abist_g8t_wenb           : std_ulogic;
signal pc_bx_abist_raddr_0            : std_ulogic_vector(0 to 9);
signal pc_bx_abist_raw_dc_b           : std_ulogic;
signal pc_bx_abist_waddr_0            : std_ulogic_vector(0 to 9);
signal pc_bx_abist_wl64_comp_ena      : std_ulogic;
signal pc_fu_abist_di_0               : std_ulogic_vector(0 to 3);
signal pc_fu_abist_di_1               : std_ulogic_vector(0 to 3);
signal pc_fu_abist_ena_dc             : std_ulogic;
signal pc_fu_abist_grf_renb_0         : std_ulogic;
signal pc_fu_abist_grf_renb_1         : std_ulogic;
signal pc_fu_abist_grf_wenb_0         : std_ulogic;      
signal pc_fu_abist_grf_wenb_1         : std_ulogic;      
signal pc_fu_abist_raddr_0            : std_ulogic_vector(0 to 9);
signal pc_fu_abist_raddr_1            : std_ulogic_vector(0 to 9);
signal pc_fu_abist_raw_dc_b           : std_ulogic;
signal pc_fu_abist_waddr_0            : std_ulogic_vector(0 to 9);
signal pc_fu_abist_waddr_1            : std_ulogic_vector(0 to 9);
signal pc_fu_abist_wl144_comp_ena     : std_ulogic;
signal pc_iu_abist_dcomp_g6t_2r       : std_ulogic_vector(0 to 3);
signal pc_iu_abist_di_0               : std_ulogic_vector(0 to 3);
signal pc_iu_abist_di_g6t_2r          : std_ulogic_vector(0 to 3);
signal pc_iu_abist_ena_dc             : std_ulogic;
signal pc_iu_abist_g6t_bw             : std_ulogic_vector(0 to 1);
signal pc_iu_abist_g6t_r_wb           : std_ulogic;
signal pc_iu_abist_g8t1p_renb_0       : std_ulogic;
signal pc_iu_abist_g8t_bw_0           : std_ulogic;
signal pc_iu_abist_g8t_bw_1           : std_ulogic;
signal pc_iu_abist_g8t_dcomp          : std_ulogic_vector(0 to 3);
signal pc_iu_abist_g8t_wenb           : std_ulogic;
signal pc_iu_abist_raddr_0            : std_ulogic_vector(0 to 9);
signal pc_iu_abist_raw_dc_b           : std_ulogic;
signal pc_iu_abist_waddr_0            : std_ulogic_vector(0 to 9);
signal pc_iu_abist_wl128_comp_ena     : std_ulogic;
signal pc_iu_abist_wl256_comp_ena     : std_ulogic;
signal pc_iu_abist_wl64_comp_ena      : std_ulogic;
signal pc_xu_abist_dcomp_g6t_2r       : std_ulogic_vector(0 to 3);
signal pc_xu_abist_di_0               : std_ulogic_vector(0 to 3);
signal pc_xu_abist_di_1               : std_ulogic_vector(0 to 3);
signal pc_xu_abist_di_g6t_2r          : std_ulogic_vector(0 to 3);
signal pc_xu_abist_ena_dc             : std_ulogic;
signal pc_xu_abist_g6t_bw             : std_ulogic_vector(0 to 1);
signal pc_xu_abist_g6t_r_wb           : std_ulogic;
signal pc_xu_abist_g8t1p_renb_0       : std_ulogic;
signal pc_xu_abist_g8t_bw_0           : std_ulogic;
signal pc_xu_abist_g8t_bw_1           : std_ulogic;
signal pc_xu_abist_g8t_dcomp          : std_ulogic_vector(0 to 3);
signal pc_xu_abist_g8t_wenb           : std_ulogic;
signal pc_xu_abist_grf_renb_0         : std_ulogic;
signal pc_xu_abist_grf_renb_1         : std_ulogic;
signal pc_xu_abist_grf_wenb_0         : std_ulogic;      
signal pc_xu_abist_grf_wenb_1         : std_ulogic;
signal pc_xu_abist_raddr_0            : std_ulogic_vector(0 to 9);
signal pc_xu_abist_raddr_1            : std_ulogic_vector(0 to 9);
signal pc_xu_abist_raw_dc_b           : std_ulogic;
signal pc_xu_abist_waddr_0            : std_ulogic_vector(0 to 9);
signal pc_xu_abist_waddr_1            : std_ulogic_vector(0 to 9);
signal pc_xu_abist_wl144_comp_ena     : std_ulogic;
signal pc_xu_abist_wl32_comp_ena      : std_ulogic;
signal pc_xu_abist_wl512_comp_ena     : std_ulogic;
signal xu_bx_ex1_mtdp_val             : std_ulogic;                      
signal xu_bx_ex1_mfdp_val             : std_ulogic;                      
signal xu_bx_ex1_ipc_thrd             : std_ulogic_vector(0 to 1);       
signal xu_bx_ex2_ipc_ba               : std_ulogic_vector(0 to 4);       
signal xu_bx_ex2_ipc_sz               : std_ulogic_vector(0 to 1);       
signal xu_bx_ex4_256st_data           : std_ulogic_vector(128 to 255); 
signal bx_xu_ex4_mtdp_cr_status       : std_ulogic;                     
signal bx_xu_ex4_mfdp_cr_status       : std_ulogic;                     
signal bx_xu_ex5_dp_data              : std_ulogic_vector(0 to 127);
signal bx_lsu_ob_pwr_tok              : std_ulogic;
signal bx_lsu_ob_req_val              : std_ulogic;
signal bx_lsu_ob_ditc_val             : std_ulogic;
signal bx_lsu_ob_thrd                 : std_ulogic_vector(0 to 1);
signal bx_lsu_ob_qw                   : std_ulogic_vector(58 to 59);
signal bx_lsu_ob_dest                 : std_ulogic_vector(0 to 14);
signal bx_lsu_ob_data                 : std_ulogic_vector(0 to 127);
signal bx_lsu_ob_addr                 : std_ulogic_vector(64-xu_real_data_add to 57);
signal lsu_bx_cmd_avail               : std_ulogic;
signal lsu_bx_cmd_sent                : std_ulogic;
signal lsu_bx_cmd_stall               : std_ulogic;
signal lsu_reld_data_vld              : std_ulogic;                      
signal bx_ib_empty_int                : std_ulogic_vector(0 to 3);
signal ac_an_reld_ditc_pop_int        : std_ulogic_vector(0 to 3);
signal lsu_reld_core_tag             : std_ulogic_vector(3 to 4);       
signal lsu_reld_ditc                 : std_ulogic;                      
signal lsu_reld_ecc_err              : std_ulogic;                      
signal lsu_reld_qw                   : std_ulogic_vector(58 to 59);     
signal lsu_reld_data                 : std_ulogic_vector(0 to 127);     
signal lsu_req_st_pop                : std_ulogic;                  
signal lsu_req_st_pop_thrd           : std_ulogic_vector(0 to 2);   
signal pc_bx_func_sl_thold_3         : std_ulogic;
signal pc_bx_func_slp_sl_thold_3     : std_ulogic;
signal pc_bx_gptr_sl_thold_3         : std_ulogic;
signal pc_bx_time_sl_thold_3         : std_ulogic;
signal pc_bx_repr_sl_thold_3         : std_ulogic;
signal pc_bx_abst_sl_thold_3         : std_ulogic;
signal pc_bx_ary_nsl_thold_3         : std_ulogic;
signal pc_bx_ary_slp_nsl_thold_3     : std_ulogic;
signal pc_bx_sg_3                    : std_ulogic;
signal rp_pc_rtim_sl_thold_6         : std_ulogic;         
signal rp_pc_func_sl_thold_6         : std_ulogic;         
signal rp_pc_func_nsl_thold_6        : std_ulogic;        
signal rp_pc_ary_nsl_thold_6         : std_ulogic;         
signal rp_pc_sg_6                    : std_ulogic;                    
signal rp_pc_fce_6                   : std_ulogic;                   
signal debug_start_tiedowns          : std_ulogic_vector(0 to 87);
signal trigger_start_tiedowns        : std_ulogic_vector(0 to 11);
signal bx_fu_debug_data              : std_ulogic_vector(0 to 87);
signal bx_fu_trigger_data            : std_ulogic_vector(0 to 11);
signal fu_pc_debug_data              : std_ulogic_vector(0 to 87);
signal fu_pc_trigger_data            : std_ulogic_vector(0 to 11);
signal pc_iu_debug_data              : std_ulogic_vector(0 to 87);
signal pc_iu_trigger_data            : std_ulogic_vector(0 to 11);
signal iu_xu_debug_data              : std_ulogic_vector(0 to 87);
signal iu_xu_trigger_data            : std_ulogic_vector(0 to 11);
signal xu_mm_debug_data              : std_ulogic_vector(0 to 87);
signal xu_mm_trigger_data            : std_ulogic_vector(0 to 11);
signal iu_pc_gptr_scan_out           : std_ulogic;  
signal pc_fu_gptr_scan_out           : std_ulogic;  
signal fu_bx_gptr_scan_out           : std_ulogic;  
signal bx_xu_gptr_scan_out           : std_ulogic;  
signal xu_mm_gptr_scan_out           : std_ulogic;  
signal iu_fu_time_scan_out           : std_ulogic;  
signal fu_bx_time_scan_out           : std_ulogic;  
signal bx_xu_time_scan_out           : std_ulogic;  
signal xu_mm_time_scan_out           : std_ulogic;  
signal iu_fu_repr_scan_out           : std_ulogic;  
signal fu_bx_repr_scan_out           : std_ulogic;  
signal bx_xu_repr_scan_out           : std_ulogic;
signal xu_mm_repr_scan_out           : std_ulogic;
signal mm_iu_ccfg_scan_out           : std_ulogic;
signal iu_pc_ccfg_scan_out           : std_ulogic;
signal xu_fu_ccfg_scan_out           : std_ulogic;
signal iu_fu_bcfg_scan_out           : std_ulogic;
signal mm_rp_bcfg_scan_out           : std_ulogic;
signal rp_pc_bcfg_scan_out_q         : std_ulogic;
signal mm_rp_dcfg_scan_out           : std_ulogic;
signal rp_pc_dcfg_scan_out_q         : std_ulogic;
signal iu_fu_dcfg_scan_out           : std_ulogic;
signal pc_rp_abst_scan_out           : std_ulogic;
signal rp_pc_func_scan_in_q          : std_ulogic_vector(0 to 1);
signal pc_rp_func_scan_out           : std_ulogic_vector(0 to 1);
signal rp_fu_abst_scan_in_q          : std_ulogic;
signal fu_rp_abst_scan_out           : std_ulogic;
signal fu_rp_ccfg_scan_out           : std_ulogic;
signal fu_rp_bcfg_scan_out           : std_ulogic;
signal fu_rp_dcfg_scan_out           : std_ulogic;
signal rp_fu_func_scan_in_q          : std_ulogic_vector(0 to 3);
signal fu_rp_func_scan_out           : std_ulogic_vector(0 to 3);
signal rp_bx_abst_scan_in_q          : std_ulogic;
signal bx_rp_abst_scan_out           : std_ulogic;
signal rp_bx_func_scan_in_q          : std_ulogic_vector(0 to 1);
signal rp_fu_bx_abst_scan_in         : std_ulogic;
signal bx_fu_rp_abst_scan_out        : std_ulogic;
signal rp_fu_bx_func_scan_in         : std_ulogic_vector(0 to 1);
signal bx_fu_rp_func_scan_out        : std_ulogic_vector(0 to 1);
signal bx_rp_func_scan_out           : std_ulogic_vector(0 to 1);
signal pc_rp_bcfg_scan_out           : std_ulogic;
signal pc_rp_ccfg_scan_out           : std_ulogic;
signal pc_rp_dcfg_scan_out           : std_ulogic;
signal iu_pc_abst_scan_out           : std_ulogic;
signal rp_pc_scom_dch_q              : std_ulogic;
signal rp_pc_scom_cch_q              : std_ulogic;
signal rp_pc_checkstop_q             : std_ulogic;
signal rp_pc_debug_stop_q            : std_ulogic;
signal rp_pc_pm_thread_stop_q        : std_ulogic_vector(0 to 3); 
signal rp_pc_reset_1_complete_q      : std_ulogic;
signal rp_pc_reset_2_complete_q      : std_ulogic;
signal rp_pc_reset_3_complete_q      : std_ulogic;
signal rp_pc_reset_wd_complete_q     : std_ulogic;
signal rp_pc_abist_start_test_q      : std_ulogic;
signal pc_rp_scom_dch                : std_ulogic;
signal pc_rp_scom_cch                : std_ulogic;
signal pc_rp_special_attn            : std_ulogic_vector(0 to 3);
signal pc_rp_checkstop               : std_ulogic_vector(0 to 2);
signal pc_rp_trace_error             : std_ulogic;
signal pc_rp_local_checkstop         : std_ulogic_vector(0 to 2);
signal pc_rp_recov_err               : std_ulogic_vector(0 to 2);
signal pc_rp_event_bus               : std_ulogic_vector(0 to 7);
signal pc_rp_fu_bypass_events        : std_ulogic_vector(0 to 7);
signal pc_rp_iu_bypass_events        : std_ulogic_vector(0 to 7);
signal pc_rp_mm_bypass_events        : std_ulogic_vector(0 to 7);
signal pc_rp_lsu_bypass_events       : std_ulogic_vector(0 to 7);
signal pc_rp_pm_thread_running       : std_ulogic_vector(0 to 3);
signal pc_rp_power_managed           : std_ulogic;
signal pc_rp_rvwinkle_mode           : std_ulogic;
signal pc_fu_event_mux_ctrls         : std_ulogic_vector(0 to 31);
signal pc_iu_event_mux_ctrls         : std_ulogic_vector(0 to 47); 
signal pc_xu_event_mux_ctrls         : std_ulogic_vector(0 to 47);
signal pc_xu_lsu_event_mux_ctrls     : std_ulogic_vector(0 to 47);
signal pc_fu_event_bus_enable        : std_ulogic;
signal pc_iu_event_bus_enable        : std_ulogic;
signal pc_xu_event_bus_enable        : std_ulogic;
signal pc_rp_event_bus_enable        : std_ulogic;
signal rp_mm_event_bus_enable_q      : std_ulogic;
signal ac_an_debug_bus_int           : std_ulogic_vector(0 to 87);
signal ac_rp_trace_to_perfcntr       : std_ulogic_vector(0 to 7);
signal rp_pc_trace_to_perfcntr_q     : std_ulogic_vector(0 to 7);
signal ac_an_power_managed_int       : std_ulogic;  
signal xu_iu_reld_core_tag           : std_ulogic_vector(0 to 4);
signal xu_iu_reld_core_tag_clone     : std_ulogic_vector(1 to 4);
signal xu_iu_reld_data               : std_ulogic_vector(0 to 127);
signal xu_iu_reld_data_coming_clone  : std_ulogic;
signal xu_iu_reld_data_vld           : std_ulogic;
signal xu_iu_reld_data_vld_clone     : std_ulogic;
signal xu_iu_reld_ecc_err            : std_ulogic;
signal xu_iu_reld_ditc_clone         : std_ulogic;
signal xu_iu_reld_ecc_err_ue         : std_ulogic;
signal xu_iu_reld_qw                 : std_ulogic_vector(57 to 59);
signal xu_iu_stcx_complete           : std_ulogic_vector(0 to 3);
signal xu_st_byte_enbl               : std_ulogic_vector(0 to 15+(st_data_32b_mode*16));
signal xu_st_data                    : std_ulogic_vector(0 to 127+(st_data_32b_mode*128));
signal an_ac_bo_enable               : std_ulogic;
signal an_ac_bo_go                   : std_ulogic;
signal an_ac_bo_cntlclk              : std_ulogic;
signal an_ac_bo_ccflush              : std_ulogic;
signal an_ac_bo_reset                : std_ulogic;
signal an_ac_bo_data                 : std_ulogic;
signal an_ac_bo_shcntl               : std_ulogic;
signal an_ac_bo_shdata               : std_ulogic;
signal an_ac_bo_exe                  : std_ulogic;
signal an_ac_bo_sysrepair            : std_ulogic;
signal an_ac_bo_donein               : std_ulogic;
signal an_ac_bo_sdin                 : std_ulogic;
signal an_ac_bo_waitin               : std_ulogic;
signal an_ac_bo_failin               : std_ulogic;
signal an_ac_bo_fcshdata             : std_ulogic;
signal an_ac_bo_fcreset              : std_ulogic;
signal ac_an_bo_doneout              : std_ulogic;
signal ac_an_bo_sdout                : std_ulogic;
signal ac_an_bo_diagloopout          : std_ulogic;
signal ac_an_bo_waitout              : std_ulogic;
signal ac_an_bo_failout              : std_ulogic;
signal pc_bx_bolt_sl_thold_3         : std_ulogic;
signal pc_fu_bolt_sl_thold_3         : std_ulogic;
signal pc_xu_bolt_sl_thold_3         : std_ulogic;
signal pc_bx_bo_enable_3             : std_ulogic;
signal pc_bx_bo_unload               : std_ulogic;
signal pc_bx_bo_repair               : std_ulogic;
signal pc_bx_bo_reset                : std_ulogic;
signal pc_bx_bo_shdata               : std_ulogic;
signal pc_bx_bo_select               : std_ulogic_vector(0 to 3);
signal bx_pc_bo_fail                 : std_ulogic_vector(0 to 3);
signal bx_pc_bo_diagout              : std_ulogic_vector(0 to 3);
signal pc_fu_bo_enable_3             : std_ulogic;
signal pc_fu_bo_unload               : std_ulogic;
signal pc_fu_bo_load                 : std_ulogic;
signal pc_fu_bo_reset                : std_ulogic;
signal pc_fu_bo_shdata               : std_ulogic;
signal pc_fu_bo_select               : std_ulogic_vector(0 to 1);
signal fu_pc_bo_fail                 : std_ulogic_vector(0 to 1);
signal fu_pc_bo_diagout              : std_ulogic_vector(0 to 1);
signal pc_iu_bo_enable_4             : std_ulogic;
signal pc_iu_bo_unload               : std_ulogic;
signal pc_iu_bo_repair               : std_ulogic;
signal pc_iu_bo_reset                : std_ulogic;
signal pc_iu_bo_shdata               : std_ulogic;
signal pc_iu_bo_select               : std_ulogic_vector(0 to 4);
signal iu_pc_bo_fail                 : std_ulogic_vector(0 to 4);
signal iu_pc_bo_diagout              : std_ulogic_vector(0 to 4);
signal pc_xu_bo_enable_3             : std_ulogic;
signal pc_xu_bo_unload               : std_ulogic;
signal pc_xu_bo_load                 : std_ulogic;
signal pc_xu_bo_repair               : std_ulogic;
signal pc_xu_bo_reset                : std_ulogic;
signal pc_xu_bo_shdata               : std_ulogic;
signal pc_xu_bo_select               : std_ulogic_vector(0 to 8);
signal xu_pc_bo_fail                 : std_ulogic_vector(0 to 8);
signal xu_pc_bo_diagout              : std_ulogic_vector(0 to 8);

signal an_ac_abist_mode_dc_oiu         : std_ulogic;
signal an_ac_ccflush_dc_oiu            : std_ulogic;
signal an_ac_gsd_test_enable_dc_oiu    : std_ulogic;
signal an_ac_gsd_test_acmode_dc_oiu    : std_ulogic;
signal an_ac_lbist_ip_dc_oiu           : std_ulogic;
signal an_ac_lbist_ac_mode_dc_oiu      : std_ulogic;
signal an_ac_malf_alert_oiu            : std_ulogic;
signal an_ac_psro_enable_dc_oiu        : std_ulogic_vector(0 to 2);
signal an_ac_scan_type_dc_oiu          : std_ulogic_vector(0 to 8);
signal an_ac_scom_sat_id_oiu           : std_ulogic_vector(0 to 3);
signal an_ac_back_inv_oiu	       : std_ulogic;
signal an_ac_back_inv_addr_oiu         : std_ulogic_vector(64-xu_real_data_add to 63);
signal an_ac_back_inv_target_bit1_oiu  : std_ulogic;
signal an_ac_back_inv_target_bit3_oiu  : std_ulogic;
signal an_ac_back_inv_target_bit4_oiu  : std_ulogic;
signal an_ac_atpg_en_dc_oiu	       : std_ulogic;
signal an_ac_lbist_ary_wrt_thru_dc_oiu : std_ulogic;
signal an_ac_lbist_en_dc_oiu	       : std_ulogic;
signal an_ac_scan_diag_dc_oiu	       : std_ulogic;
signal an_ac_scan_dis_dc_b_oiu         : std_ulogic;
signal an_ac_back_inv_omm	       : std_ulogic;
signal an_ac_back_inv_addr_omm         : std_ulogic_vector(64-real_addr_width to 63);
signal an_ac_back_inv_target_omm_iua   : std_ulogic_vector(0 to 1);
signal an_ac_back_inv_target_omm_iub   : std_ulogic_vector(3 to 4);
signal an_ac_reld_core_tag_omm         : std_ulogic_vector(0 to 4);
signal an_ac_reld_data_omm 	       : std_ulogic_vector(0 to 127);
signal an_ac_reld_data_vld_omm         : std_ulogic;
signal an_ac_reld_ecc_err_omm	       : std_ulogic;
signal an_ac_reld_ecc_err_ue_omm       : std_ulogic;
signal an_ac_reld_qw_omm	       : std_ulogic_vector(57 to 59);
signal an_ac_reld_ditc_omm 	       : std_ulogic;
signal an_ac_reld_crit_qw_omm	       : std_ulogic;
signal an_ac_reld_data_coming_omm      : std_ulogic;
signal an_ac_reld_l1_dump_omm	       : std_ulogic;
signal an_ac_camfence_en_dc_omm        : std_ulogic;
signal an_ac_stcx_complete_omm         : std_ulogic_vector(0 to 3);
signal an_ac_abist_mode_dc_omm         : std_ulogic;
signal an_ac_abist_start_test_omm      : std_ulogic;
signal an_ac_abst_scan_in_omm_iu       : std_ulogic_vector(0 to 4);
signal an_ac_abst_scan_in_omm_xu       : std_ulogic_vector(7 to 9);
signal an_ac_atpg_en_dc_omm	       : std_ulogic;
signal an_ac_bcfg_scan_in_omm_bit1     : std_ulogic;
signal an_ac_bcfg_scan_in_omm_bit3     : std_ulogic;
signal an_ac_bcfg_scan_in_omm_bit4     : std_ulogic;
signal an_ac_lbist_ary_wrt_thru_dc_omm : std_ulogic;
signal an_ac_ccflush_dc_omm	       : std_ulogic;
signal an_ac_reset_1_complete_omm      : std_ulogic;
signal an_ac_reset_2_complete_omm      : std_ulogic;
signal an_ac_reset_3_complete_omm      : std_ulogic;
signal an_ac_reset_wd_complete_omm     : std_ulogic;
signal an_ac_dcfg_scan_in_omm	       : std_ulogic_vector(1 to 2);
signal an_ac_debug_stop_omm	       : std_ulogic;
signal an_ac_func_scan_in_omm_iua      : std_ulogic_vector(0 to 21);
signal an_ac_func_scan_in_omm_iub      : std_ulogic_vector(60 to 63);
signal an_ac_func_scan_in_omm_xu       : std_ulogic_vector(31 to 58);
signal an_ac_lbist_en_dc_omm	       : std_ulogic;
signal an_ac_pm_thread_stop_omm        : std_ulogic_vector(0 to 3);
signal an_ac_regf_scan_in_omm	       : std_ulogic_vector(0 to 11);
signal an_ac_scan_diag_dc_omm	       : std_ulogic;
signal an_ac_scan_dis_dc_b_omm         : std_ulogic;
signal an_ac_scom_cch_omm  	       : std_ulogic;
signal an_ac_scom_dch_omm              : std_ulogic;
signal an_ac_checkstop_omm 	       : std_ulogic;
signal ac_an_abst_scan_out_imm_iu     : std_ulogic_vector(0 to 4);
signal ac_an_abst_scan_out_imm_xu     : std_ulogic_vector(7 to 9);
signal ac_an_bcfg_scan_out_imm	      : std_ulogic_vector(0 to 4);
signal ac_an_dcfg_scan_out_imm	      : std_ulogic_vector(0 to 2);
signal ac_an_func_scan_out_imm_iua    : std_ulogic_vector(0 to 21);
signal ac_an_func_scan_out_imm_iub    : std_ulogic_vector(60 to 63);
signal ac_an_func_scan_out_imm_xu     : std_ulogic_vector(31 to 58);
signal ac_an_reld_ditc_pop_imm	      : std_ulogic_vector(0 to 3);
signal ac_an_power_managed_imm	      : std_ulogic;
signal ac_an_rvwinkle_mode_imm	      : std_ulogic;
signal ac_an_fu_bypass_events_imm     : std_ulogic_vector(0 to 7);
signal ac_an_iu_bypass_events_imm     : std_ulogic_vector(0 to 7);
signal ac_an_mm_bypass_events_imm     : std_ulogic_vector(0 to 7);
signal ac_an_lsu_bypass_events_imm    : std_ulogic_vector(0 to 7);
signal ac_an_event_bus_imm 	      : std_ulogic_vector(0 to 7);
signal ac_an_pm_thread_running_imm    : std_ulogic_vector(0 to 3);
signal ac_an_recov_err_imm 	      : std_ulogic_vector(0 to 2);
signal ac_an_regf_scan_out_imm	      : std_ulogic_vector(0 to 11);
signal ac_an_scom_cch_imm  	      : std_ulogic;
signal ac_an_scom_dch_imm  	      : std_ulogic;
signal ac_an_special_attn_imm	      : std_ulogic_vector(0 to 3);
signal ac_an_checkstop_imm 	      : std_ulogic_vector(0 to 2);
signal ac_an_local_checkstop_imm      : std_ulogic_vector(0 to 2);
signal ac_an_trace_error_imm	      : std_ulogic;

signal bx_pc_err_inbox_ue_ofu		: std_ulogic;
signal bx_pc_err_outbox_ue_ofu  	: std_ulogic;
signal bx_pc_err_inbox_ecc_ofu  	: std_ulogic;
signal bx_pc_err_outbox_ecc_ofu 	: std_ulogic;
signal pc_bx_bolt_sl_thold_3_ofu	: std_ulogic;
signal pc_bx_bo_enable_3_ofu		: std_ulogic;
signal pc_bx_bo_unload_ofu		: std_ulogic;
signal pc_bx_bo_repair_ofu		: std_ulogic;
signal pc_bx_bo_reset_ofu		: std_ulogic;
signal pc_bx_bo_shdata_ofu		: std_ulogic;
signal pc_bx_bo_select_ofu		: std_ulogic_vector(0 to 3);
signal bx_pc_bo_fail_ofu		: std_ulogic_vector(0 to 3);
signal bx_pc_bo_diagout_ofu		: std_ulogic_vector(0 to 3);
signal pc_bx_abist_di_0_ofu		: std_ulogic_vector(0 to 3);
signal pc_bx_abist_ena_dc_ofu		: std_ulogic;
signal pc_bx_abist_g8t1p_renb_0_ofu	: std_ulogic;
signal pc_bx_abist_g8t_bw_0_ofu 	: std_ulogic; 
signal pc_bx_abist_g8t_bw_1_ofu 	: std_ulogic; 
signal pc_bx_abist_g8t_dcomp_ofu	: std_ulogic_vector(0 to 3); 
signal pc_bx_abist_g8t_wenb_ofu 	: std_ulogic; 
signal pc_bx_abist_raddr_0_ofu  	: std_ulogic_vector(4 to 9); 
signal pc_bx_abist_raw_dc_b_ofu 	: std_ulogic; 
signal pc_bx_abist_waddr_0_ofu  	: std_ulogic_vector(4 to 9); 
signal pc_bx_abist_wl64_comp_ena_ofu	: std_ulogic;
signal pc_bx_trace_bus_enable_ofu	: std_ulogic;
signal pc_bx_debug_mux1_ctrls_ofu	: std_ulogic_vector(0 to 15);
signal pc_bx_inj_inbox_ecc_ofu  	: std_ulogic; 
signal pc_bx_inj_outbox_ecc_ofu 	: std_ulogic; 
signal pc_bx_ccflush_dc_ofu		: std_ulogic;
signal pc_bx_sg_3_ofu			: std_ulogic;
signal pc_bx_func_sl_thold_3_ofu	: std_ulogic; 
signal pc_bx_func_slp_sl_thold_3_ofu	: std_ulogic;
signal pc_bx_gptr_sl_thold_3_ofu	: std_ulogic; 
signal pc_bx_time_sl_thold_3_ofu	: std_ulogic; 
signal pc_bx_repr_sl_thold_3_ofu	: std_ulogic; 
signal pc_bx_abst_sl_thold_3_ofu	: std_ulogic; 
signal pc_bx_ary_nsl_thold_3_ofu	: std_ulogic; 
signal pc_bx_ary_slp_nsl_thold_3_ofu	: std_ulogic;  

signal xu_pc_err_mcsr_summary_ofu	      : std_ulogic_vector(0 to 3);
signal xu_pc_err_ierat_parity_ofu	      : std_ulogic;
signal xu_pc_err_derat_parity_ofu	      : std_ulogic;
signal xu_pc_err_tlb_parity_ofu 	      : std_ulogic;
signal xu_pc_err_tlb_lru_parity_ofu	      : std_ulogic;
signal xu_pc_err_ierat_multihit_ofu	      : std_ulogic;
signal xu_pc_err_derat_multihit_ofu	      : std_ulogic;
signal xu_pc_err_tlb_multihit_ofu	      : std_ulogic;
signal xu_pc_err_ext_mchk_ofu		      : std_ulogic;
signal xu_pc_err_ditc_overrun_ofu	      : std_ulogic;
signal xu_pc_err_local_snoop_reject_ofu       : std_ulogic;
signal xu_pc_err_attention_instr_ofu	      : std_ulogic_vector(0 to 3);
signal xu_pc_err_dcache_parity_ofu	      : std_ulogic;
signal xu_pc_err_dcachedir_parity_ofu	      : std_ulogic;
signal xu_pc_err_dcachedir_multihit_ofu       : std_ulogic;
signal xu_pc_err_debug_event_ofu	      : std_ulogic_vector(0 to 3);
signal xu_pc_err_invld_reld_ofu 	      : std_ulogic;
signal xu_pc_err_l2intrf_ecc_ofu	      : std_ulogic;
signal xu_pc_err_l2intrf_ue_ofu 	      : std_ulogic;
signal xu_pc_err_l2credit_overrun_ofu	      : std_ulogic;
signal xu_pc_err_llbust_attempt_ofu	      : std_ulogic_vector(0 to 3);
signal xu_pc_err_llbust_failed_ofu	      : std_ulogic_vector(0 to 3);
signal xu_pc_err_nia_miscmpr_ofu	      : std_ulogic_vector(0 to 3);
signal xu_pc_err_regfile_parity_ofu	      : std_ulogic_vector(0 to 3);
signal xu_pc_err_regfile_ue_ofu 	      : std_ulogic_vector(0 to 3);
signal xu_pc_err_sprg_ecc_ofu		      : std_ulogic_vector(0 to 3);
signal xu_pc_err_sprg_ue_ofu		      : std_ulogic_vector(0 to 3);
signal xu_pc_err_wdt_reset_ofu  	      : std_ulogic_vector(0 to 3);
signal xu_pc_event_data_ofu		      : std_ulogic_vector(0 to 7);
signal xu_pc_ram_data_ofu		      : std_ulogic_vector(64-(2**regmode) to 63);
signal xu_pc_ram_done_ofu		      : std_ulogic;
signal xu_pc_ram_interrupt_ofu  	      : std_ulogic;
signal xu_pc_running_ofu		      : std_ulogic_vector(0 to 3);
signal xu_pc_spr_ccr0_pme_ofu		      : std_ulogic_vector(0 to 1);
signal xu_pc_spr_ccr0_we_ofu		      : std_ulogic_vector(0 to 3);
signal xu_pc_step_done_ofu		      : std_ulogic_vector(0 to 3);
signal xu_pc_stop_dbg_event_ofu 	      : std_ulogic_vector(0 to 3);
signal pc_xu_bolt_sl_thold_3_ofu	      : std_ulogic;
signal pc_xu_bo_enable_3_ofu		      : std_ulogic;
signal pc_xu_bo_unload_ofu		      : std_ulogic;
signal pc_xu_bo_load_ofu		      : std_ulogic;
signal pc_xu_bo_repair_ofu		      : std_ulogic;
signal pc_xu_bo_reset_ofu		      : std_ulogic;
signal pc_xu_bo_shdata_ofu		      : std_ulogic;
signal pc_xu_bo_select_ofu		      : std_ulogic_vector(0 to 8);
signal xu_pc_bo_fail_ofu		      : std_ulogic_vector(0 to 8);
signal xu_pc_bo_diagout_ofu		      : std_ulogic_vector(0 to 8);
signal pc_xu_abist_dcomp_g6t_2r_ofu	      : std_ulogic_vector(0 to 3);
signal pc_xu_abist_di_0_ofu		      : std_ulogic_vector(0 to 3);
signal pc_xu_abist_di_1_ofu		      : std_ulogic_vector(0 to 3);
signal pc_xu_abist_di_g6t_2r_ofu	      : std_ulogic_vector(0 to 3);
signal pc_xu_abist_ena_dc_ofu		      : std_ulogic;
signal pc_xu_abist_g6t_bw_ofu		      : std_ulogic_vector(0 to 1);
signal pc_xu_abist_g6t_r_wb_ofu 	      : std_ulogic;
signal pc_xu_abist_g8t1p_renb_0_ofu	      : std_ulogic;
signal pc_xu_abist_g8t_bw_0_ofu 	      : std_ulogic;
signal pc_xu_abist_g8t_bw_1_ofu 	      : std_ulogic;
signal pc_xu_abist_g8t_dcomp_ofu	      : std_ulogic_vector(0 to 3);
signal pc_xu_abist_g8t_wenb_ofu 	      : std_ulogic;
signal pc_xu_abist_grf_renb_0_ofu	      : std_ulogic;
signal pc_xu_abist_grf_renb_1_ofu	      : std_ulogic;
signal pc_xu_abist_grf_wenb_0_ofu	      : std_ulogic;
signal pc_xu_abist_grf_wenb_1_ofu	      : std_ulogic;
signal pc_xu_abist_raddr_0_ofu  	      : std_ulogic_vector(0 to 9);
signal pc_xu_abist_raddr_1_ofu  	      : std_ulogic_vector(0 to 9);
signal pc_xu_abist_raw_dc_b_ofu 	      : std_ulogic;
signal pc_xu_abist_waddr_0_ofu  	      : std_ulogic_vector(0 to 9);
signal pc_xu_abist_waddr_1_ofu  	      : std_ulogic_vector(0 to 9);
signal pc_xu_abist_wl144_comp_ena_ofu	      : std_ulogic;
signal pc_xu_abist_wl32_comp_ena_ofu	      : std_ulogic;
signal pc_xu_abist_wl512_comp_ena_ofu	      : std_ulogic;
signal pc_xu_event_mux_ctrls_ofu	      : std_ulogic_vector(0 to 47);
signal pc_xu_lsu_event_mux_ctrls_ofu	      : std_ulogic_vector(0 to 47);
signal pc_xu_event_bus_enable_ofu	      : std_ulogic;
signal pc_xu_abst_sl_thold_3_ofu	      : std_ulogic;
signal pc_xu_abst_slp_sl_thold_3_ofu	      : std_ulogic;
signal pc_xu_regf_sl_thold_3_ofu	      : std_ulogic;
signal pc_xu_regf_slp_sl_thold_3_ofu	      : std_ulogic;
signal pc_xu_ary_nsl_thold_3_ofu	      : std_ulogic;
signal pc_xu_ary_slp_nsl_thold_3_ofu	      : std_ulogic;
signal pc_xu_cache_par_err_event_ofu	      : std_ulogic;
signal pc_xu_ccflush_dc_ofu		      : std_ulogic;
signal pc_xu_cfg_sl_thold_3_ofu 	      : std_ulogic;
signal pc_xu_cfg_slp_sl_thold_3_ofu	      : std_ulogic;
signal pc_xu_dbg_action_ofu		      : std_ulogic_vector(0 to 11);
signal pc_xu_debug_mux1_ctrls_ofu	      : std_ulogic_vector(0 to 15);
signal pc_xu_debug_mux2_ctrls_ofu	      : std_ulogic_vector(0 to 15);
signal pc_xu_debug_mux3_ctrls_ofu	      : std_ulogic_vector(0 to 15);
signal pc_xu_debug_mux4_ctrls_ofu	      : std_ulogic_vector(0 to 15);
signal pc_xu_decrem_dis_on_stop_ofu	      : std_ulogic;
signal pc_xu_event_count_mode_ofu	      : std_ulogic_vector(0 to 2);
signal pc_xu_extirpts_dis_on_stop_ofu	      : std_ulogic;
signal pc_xu_fce_3_ofu  		      : std_ulogic_vector(0 to 1);
signal pc_xu_force_ude_ofu		      : std_ulogic_vector(0 to 3);
signal pc_xu_func_nsl_thold_3_ofu	      : std_ulogic;
signal pc_xu_func_sl_thold_3_ofu	      : std_ulogic_vector(0 to 4);
signal pc_xu_func_slp_nsl_thold_3_ofu	      : std_ulogic;
signal pc_xu_func_slp_sl_thold_3_ofu	      : std_ulogic_vector(0 to 4);
signal pc_xu_gptr_sl_thold_3_ofu	      : std_ulogic;
signal pc_xu_init_reset_ofu		      : std_ulogic;
signal pc_xu_inj_dcache_parity_ofu	      : std_ulogic;
signal pc_xu_inj_dcachedir_parity_ofu	      : std_ulogic;
signal pc_xu_inj_llbust_attempt_ofu	      : std_ulogic_vector(0 to 3);
signal pc_xu_inj_llbust_failed_ofu	      : std_ulogic_vector(0 to 3);
signal pc_xu_inj_sprg_ecc_ofu		      : std_ulogic_vector(0 to 3);
signal pc_xu_inj_regfile_parity_ofu	      : std_ulogic_vector(0 to 3);
signal pc_xu_inj_wdt_reset_ofu  	      : std_ulogic_vector(0 to 3);
signal pc_xu_inj_dcachedir_multihit_ofu       : std_ulogic;
signal pc_xu_instr_trace_mode_ofu	      : std_ulogic;
signal pc_xu_instr_trace_tid_ofu	      : std_ulogic_vector(0 to 1);
signal pc_xu_msrovride_enab_ofu 	      : std_ulogic;
signal pc_xu_msrovride_gs_ofu		      : std_ulogic;
signal pc_xu_msrovride_pr_ofu		      : std_ulogic;
signal pc_xu_ram_execute_ofu		      : std_ulogic;
signal pc_xu_ram_flush_thread_ofu	      : std_ulogic;
signal pc_xu_ram_mode_ofu		      : std_ulogic;
signal pc_xu_ram_thread_ofu		      : std_ulogic_vector(0 to 1);
signal pc_xu_repr_sl_thold_3_ofu	      : std_ulogic;
signal pc_xu_reset_1_cmplt_ofu  	      : std_ulogic;
signal pc_xu_reset_2_cmplt_ofu  	      : std_ulogic;
signal pc_xu_reset_3_cmplt_ofu  	      : std_ulogic;
signal pc_xu_reset_wd_cmplt_ofu 	      : std_ulogic;
signal pc_xu_sg_3_ofu			      : std_ulogic_vector(0 to 4);
signal pc_xu_step_ofu			      : std_ulogic_vector(0 to 3);
signal pc_xu_stop_ofu			      : std_ulogic_vector(0 to 3);
signal pc_xu_time_sl_thold_3_ofu	      : std_ulogic;
signal pc_xu_timebase_dis_on_stop_ofu	      : std_ulogic;
signal pc_xu_trace_bus_enable_ofu             : std_ulogic;

signal an_ac_crit_interrupt_omm        : std_ulogic_vector(0 to thdid_width-1);
signal an_ac_ext_interrupt_omm         : std_ulogic_vector(0 to thdid_width-1);
signal an_ac_flh2l2_gate_omm	       : std_ulogic;
signal an_ac_icbi_ack_omm  	       : std_ulogic;
signal an_ac_icbi_ack_thread_omm       : std_ulogic_vector(0 to 1);
signal an_ac_req_ld_pop_omm	       : std_ulogic;
signal an_ac_req_spare_ctrl_a1_omm     : std_ulogic_vector(0 to 3);
signal an_ac_req_st_gather_omm	       : std_ulogic;
signal an_ac_req_st_pop_omm	       : std_ulogic;
signal an_ac_req_st_pop_thrd_omm       : std_ulogic_vector(0 to 2);
signal an_ac_reservation_vld_omm       : std_ulogic_vector(0 to thdid_width-1);
signal an_ac_sleep_en_omm  	       : std_ulogic_vector(0 to thdid_width-1);
signal an_ac_stcx_pass_omm 	       : std_ulogic_vector(0 to 3);
signal an_ac_sync_ack_omm  	       : std_ulogic_vector(0 to 3);
signal an_ac_ary_nsl_thold_7_omm       : std_ulogic;
signal an_ac_coreid_omm	               : std_ulogic_vector(0 to 7);
signal an_ac_external_mchk_omm         : std_ulogic_vector(0 to 3);
signal an_ac_fce_7_omm	               : std_ulogic;
signal an_ac_func_nsl_thold_7_omm      : std_ulogic;
signal an_ac_func_sl_thold_7_omm       : std_ulogic;
signal an_ac_gsd_test_enable_dc_omm    : std_ulogic;
signal an_ac_gsd_test_acmode_dc_omm    : std_ulogic;
signal an_ac_gptr_scan_in_omm	       : std_ulogic;
signal an_ac_hang_pulse_omm	       : std_ulogic_vector(0 to thdid_width-1);
signal an_ac_lbist_ac_mode_dc_omm      : std_ulogic;
signal an_ac_lbist_ip_dc_omm	       : std_ulogic;
signal an_ac_malf_alert_omm	       : std_ulogic;
signal an_ac_perf_interrupt_omm        : std_ulogic_vector(0 to thdid_width-1);
signal an_ac_psro_enable_dc_omm        : std_ulogic_vector(0 to 2);
signal an_ac_repr_scan_in_omm	       : std_ulogic;
signal an_ac_rtim_sl_thold_7_omm       : std_ulogic;
signal an_ac_scan_type_dc_omm	       : std_ulogic_vector(0 to 8);
signal an_ac_scom_sat_id_omm	       : std_ulogic_vector(0 to 3);
signal an_ac_sg_7_omm		       : std_ulogic;
signal an_ac_tb_update_enable_omm      : std_ulogic;
signal an_ac_tb_update_pulse_omm       : std_ulogic;
signal an_ac_time_scan_in_omm	       : std_ulogic;

signal ac_an_box_empty_imm 	       : std_ulogic_vector(0 to 3);
signal ac_an_machine_check_imm         : std_ulogic_vector(0 to thdid_width-1);
signal ac_an_req_imm		       : std_ulogic;
signal ac_an_req_endian_imm	       : std_ulogic;
signal ac_an_req_ld_core_tag_imm       : std_ulogic_vector(0 to 4);
signal ac_an_req_ld_xfr_len_imm        : std_ulogic_vector(0 to 2);
signal ac_an_req_pwr_token_imm         : std_ulogic;
signal ac_an_req_ra_imm	               : std_ulogic_vector(64-real_addr_width to 63);
signal ac_an_req_spare_ctrl_a0_imm     : std_ulogic_vector(0 to 3);
signal ac_an_req_thread_imm	       : std_ulogic_vector(0 to 2);
signal ac_an_req_ttype_imm 	       : std_ulogic_vector(0 to 5);
signal ac_an_req_user_defined_imm      : std_ulogic_vector(0 to 3);
signal ac_an_req_wimg_g_imm	       : std_ulogic;
signal ac_an_req_wimg_i_imm	       : std_ulogic;
signal ac_an_req_wimg_m_imm	       : std_ulogic;
signal ac_an_req_wimg_w_imm	       : std_ulogic;
signal ac_an_st_byte_enbl_imm	       : std_ulogic_vector(0 to 31); 
signal ac_an_st_byte_enbl_omm	       : std_ulogic_vector(16 to 31);
signal ac_an_st_data_imm	       : std_ulogic_vector(0 to 255);
signal ac_an_st_data_omm	       : std_ulogic_vector(128 to 255);
signal ac_an_st_data_pwr_token_imm     : std_ulogic;
signal ac_an_debug_trigger_imm	       : std_ulogic_vector(0 to thdid_width-1);
signal ac_an_reset_1_request_imm       : std_ulogic;
signal ac_an_reset_2_request_imm       : std_ulogic;
signal ac_an_reset_3_request_imm       : std_ulogic;
signal ac_an_reset_wd_request_imm      : std_ulogic;
signal an_ac_scan_diag_dc_opc          : std_ulogic;
signal an_ac_scan_dis_dc_b_opc         : std_ulogic;
signal an_ac_scan_dis_dc_b_ofu         : std_ulogic;
signal an_ac_scan_diag_dc_ofu          : std_ulogic;

signal ac_an_abist_done_dc_iiu  	  : std_ulogic;
signal ac_an_psro_ringsig_iiu		  : std_ulogic;
signal an_ac_ccenable_dc_iiu              : std_ulogic;
signal mm_pc_bo_fail_iiu		  : std_ulogic_vector(0 to 4);
signal mm_pc_bo_diagout_iiu		  : std_ulogic_vector(0 to 4);
signal mm_pc_event_data_iiu		  : std_ulogic_vector(0 to 7);
      
signal ac_an_abist_done_dc_oiu  	  : std_ulogic;
signal ac_an_psro_ringsig_oiu		  : std_ulogic;
signal an_ac_ccenable_dc_oiu              : std_ulogic;
signal mm_pc_bo_fail_oiu		  : std_ulogic_vector(0 to 4);
signal mm_pc_bo_diagout_oiu		  : std_ulogic_vector(0 to 4);
signal mm_pc_event_data_oiu		  : std_ulogic_vector(0 to 7);

signal pc_mm_abist_dcomp_g6t_2r_iiu	  : std_ulogic_vector(0 to 3);
signal pc_mm_abist_di_g6t_2r_iiu	  : std_ulogic_vector(0 to 3);
signal pc_mm_abist_di_0_iiu		  : std_ulogic_vector(0 to 3);
signal pc_mm_abist_ena_dc_iiu		  : std_ulogic;
signal pc_mm_abist_g6t_r_wb_iiu 	  : std_ulogic;
signal pc_mm_abist_g8t_bw_0_iiu 	  : std_ulogic;
signal pc_mm_abist_g8t_bw_1_iiu 	  : std_ulogic;
signal pc_mm_abist_g8t_dcomp_iiu	  : std_ulogic_vector(0 to 3);
signal pc_mm_abist_g8t_wenb_iiu 	  : std_ulogic;
signal pc_mm_abist_g8t1p_renb_0_iiu	  : std_ulogic;
signal pc_mm_abist_raddr_0_iiu  	  : std_ulogic_vector(0 to 9);
signal pc_mm_abist_raw_dc_b_iiu 	  : std_ulogic;
signal pc_mm_abist_waddr_0_iiu  	  : std_ulogic_vector(0 to 9);
signal pc_mm_abist_wl128_comp_ena_iiu	  : std_ulogic;
signal pc_mm_bo_enable_4_iiu		  : std_ulogic;
signal pc_mm_bo_repair_iiu		  : std_ulogic;
signal pc_mm_bo_reset_iiu		  : std_ulogic;
signal pc_mm_bo_select_iiu		  : std_ulogic_vector(0 to 4);
signal pc_mm_bo_shdata_iiu		  : std_ulogic;
signal pc_mm_bo_unload_iiu		  : std_ulogic;
signal pc_mm_ccflush_dc_iiu		  : std_ulogic;
signal pc_mm_debug_mux1_ctrls_iiu	  : std_ulogic_vector(0 to 15);
signal pc_mm_event_count_mode_iiu	  : std_ulogic_vector(0 to 2);
signal pc_mm_event_mux_ctrls_iiu	  : std_ulogic_vector(0 to 39);
signal pc_mm_trace_bus_enable_iiu	  : std_ulogic;
signal pc_mm_abist_dcomp_g6t_2r_oiu	  : std_ulogic_vector(0 to 3);
signal pc_mm_abist_di_g6t_2r_oiu	  : std_ulogic_vector(0 to 3);
signal pc_mm_abist_di_0_oiu		  : std_ulogic_vector(0 to 3);
signal pc_mm_abist_ena_dc_oiu		  : std_ulogic;
signal pc_mm_abist_g6t_r_wb_oiu 	  : std_ulogic;
signal pc_mm_abist_g8t_bw_0_oiu 	  : std_ulogic;
signal pc_mm_abist_g8t_bw_1_oiu 	  : std_ulogic;
signal pc_mm_abist_g8t_dcomp_oiu	  : std_ulogic_vector(0 to 3);
signal pc_mm_abist_g8t_wenb_oiu 	  : std_ulogic;
signal pc_mm_abist_g8t1p_renb_0_oiu	  : std_ulogic;
signal pc_mm_abist_raddr_0_oiu  	  : std_ulogic_vector(0 to 9);
signal pc_mm_abist_raw_dc_b_oiu 	  : std_ulogic;
signal pc_mm_abist_waddr_0_oiu  	  : std_ulogic_vector(0 to 9);
signal pc_mm_abist_wl128_comp_ena_oiu	  : std_ulogic;
signal pc_mm_abst_sl_thold_3_oiu	  : std_ulogic;
signal pc_mm_abst_slp_sl_thold_3_oiu	  : std_ulogic;
signal pc_mm_ary_nsl_thold_3_oiu	  : std_ulogic;
signal pc_mm_ary_slp_nsl_thold_3_oiu	  : std_ulogic;
signal pc_mm_bo_enable_3_oiu		  : std_ulogic;
signal pc_mm_bo_repair_oiu		  : std_ulogic;
signal pc_mm_bo_reset_oiu		  : std_ulogic;
signal pc_mm_bo_select_oiu		  : std_ulogic_vector(0 to 4);
signal pc_mm_bo_shdata_oiu		  : std_ulogic;
signal pc_mm_bo_unload_oiu		  : std_ulogic;
signal pc_mm_bolt_sl_thold_3_oiu	  : std_ulogic;
signal pc_mm_ccflush_dc_oiu		  : std_ulogic;
signal pc_mm_cfg_sl_thold_3_oiu 	  : std_ulogic;
signal pc_mm_cfg_slp_sl_thold_3_oiu	  : std_ulogic;
signal pc_mm_debug_mux1_ctrls_oiu	  : std_ulogic_vector(0 to 15);
signal pc_mm_event_count_mode_oiu	  : std_ulogic_vector(0 to 2);
signal pc_mm_event_mux_ctrls_oiu	  : std_ulogic_vector(0 to 39);
signal pc_mm_fce_3_oiu  		  : std_ulogic;
signal pc_mm_func_nsl_thold_3_oiu	  : std_ulogic;
signal pc_mm_func_sl_thold_3_oiu	  : std_ulogic_vector(0 to 1);
signal pc_mm_func_slp_nsl_thold_3_oiu	  : std_ulogic;
signal pc_mm_func_slp_sl_thold_3_oiu	  : std_ulogic_vector(0 to 1);
signal pc_mm_gptr_sl_thold_3_oiu	  : std_ulogic;
signal pc_mm_repr_sl_thold_3_oiu	  : std_ulogic;
signal pc_mm_sg_3_oiu			  : std_ulogic_vector(0 to 1);
signal pc_mm_time_sl_thold_3_oiu	  : std_ulogic;
signal pc_mm_trace_bus_enable_oiu	  : std_ulogic;
signal xu_ex2_flush_ofu 		  : std_ulogic_vector(0 to 3);
signal xu_ex3_flush_ofu 		  : std_ulogic_vector(0 to 3);
signal xu_ex4_flush_ofu 		  : std_ulogic_vector(0 to 3);
signal xu_ex5_flush_ofu 		  : std_ulogic_vector(0 to 3);
signal an_ac_lbist_ary_wrt_thru_dc_ofu    : std_ulogic;
signal xu_pc_lsu_event_data_ofu           : std_ulogic_vector(0 to 7);
signal xu_pc_err_mchk_disabled            : std_ulogic;
signal xu_pc_err_mchk_disabled_ofu        : std_ulogic;
signal xu_iu_l_flush                      : std_ulogic_vector(0 to 3);
signal xu_iu_u_flush                      : std_ulogic_vector(0 to 3);
signal debug_bus_out_int                  : std_ulogic_vector(0 to 7);
signal an_ac_grffence_en_dc_oiu           : std_ulogic;
signal xu_fu_lbist_ary_wrt_thru_dc        : std_ulogic;
signal pc_xu_msrovride_de                 : std_ulogic;

signal bg_an_ac_func_scan_sn	           : std_ulogic_vector(60 to 69);
signal bg_an_ac_abst_scan_sn	           : std_ulogic_vector(10 to 11);
signal bg_an_ac_func_scan_sn_q             : std_ulogic_vector(60 to 69);
signal bg_an_ac_abst_scan_sn_q             : std_ulogic_vector(10 to 11);

signal bg_ac_an_func_scan_ns	           : std_ulogic_vector(60 to 69);
signal bg_ac_an_abst_scan_ns	           : std_ulogic_vector(10 to 11);
signal bg_ac_an_func_scan_ns_q             : std_ulogic_vector(60 to 69);
signal bg_ac_an_abst_scan_ns_q             : std_ulogic_vector(10 to 11);

signal bg_pc_l1p_abist_di_0                : std_ulogic_vector(0 to 3);
signal bg_pc_l1p_abist_g8t1p_renb_0        : std_ulogic;
signal bg_pc_l1p_abist_g8t_bw_0            : std_ulogic;
signal bg_pc_l1p_abist_g8t_bw_1            : std_ulogic;
signal bg_pc_l1p_abist_g8t_dcomp           : std_ulogic_vector(0 to 3);
signal bg_pc_l1p_abist_g8t_wenb            : std_ulogic;
signal bg_pc_l1p_abist_raddr_0             : std_ulogic_vector(0 to 9);
signal bg_pc_l1p_abist_waddr_0             : std_ulogic_vector(0 to 9);
signal bg_pc_l1p_abist_wl128_comp_ena      : std_ulogic;
signal bg_pc_l1p_abist_wl32_comp_ena       : std_ulogic;
signal bg_pc_l1p_abist_di_0_q              : std_ulogic_vector(0 to 3);
signal bg_pc_l1p_abist_g8t1p_renb_0_q      : std_ulogic;
signal bg_pc_l1p_abist_g8t_bw_0_q          : std_ulogic;
signal bg_pc_l1p_abist_g8t_bw_1_q          : std_ulogic;
signal bg_pc_l1p_abist_g8t_dcomp_q         : std_ulogic_vector(0 to 3);
signal bg_pc_l1p_abist_g8t_wenb_q          : std_ulogic;
signal bg_pc_l1p_abist_raddr_0_q           : std_ulogic_vector(0 to 9);
signal bg_pc_l1p_abist_waddr_0_q           : std_ulogic_vector(0 to 9);
signal bg_pc_l1p_abist_wl128_comp_ena_q    : std_ulogic;
signal bg_pc_l1p_abist_wl32_comp_ena_q     : std_ulogic;

signal bg_pc_l1p_gptr_sl_thold_3           : std_ulogic;
signal bg_pc_l1p_time_sl_thold_3           : std_ulogic;
signal bg_pc_l1p_repr_sl_thold_3           : std_ulogic;
signal bg_pc_l1p_abst_sl_thold_3           : std_ulogic;
signal bg_pc_l1p_func_sl_thold_3           : std_ulogic_vector(0 to 1);
signal bg_pc_l1p_func_slp_sl_thold_3       : std_ulogic;
signal bg_pc_l1p_bolt_sl_thold_3           : std_ulogic;
signal bg_pc_l1p_ary_nsl_thold_3           : std_ulogic;
signal bg_pc_l1p_sg_3  	                   : std_ulogic_vector(0 to 1);
signal bg_pc_l1p_fce_3 	                   : std_ulogic;
signal bg_pc_l1p_bo_enable_3	           : std_ulogic;
signal bg_pc_l1p_gptr_sl_thold_2           : std_ulogic;
signal bg_pc_l1p_time_sl_thold_2           : std_ulogic;
signal bg_pc_l1p_repr_sl_thold_2           : std_ulogic;
signal bg_pc_l1p_abst_sl_thold_2           : std_ulogic;
signal bg_pc_l1p_func_sl_thold_2           : std_ulogic_vector(0 to 1);
signal bg_pc_l1p_func_slp_sl_thold_2       : std_ulogic;
signal bg_pc_l1p_bolt_sl_thold_2           : std_ulogic;
signal bg_pc_l1p_ary_nsl_thold_2           : std_ulogic;
signal bg_pc_l1p_sg_2  	                   : std_ulogic_vector(0 to 1);
signal bg_pc_l1p_fce_2 	                   : std_ulogic;
signal bg_pc_l1p_bo_enable_2	           : std_ulogic;

signal bg_pc_bo_unload_iiu		   : std_ulogic;
signal bg_pc_bo_load_iiu		   : std_ulogic;
signal bg_pc_bo_repair_iiu		   : std_ulogic;
signal bg_pc_bo_reset_iiu		   : std_ulogic;
signal bg_pc_bo_shdata_iiu		   : std_ulogic;
signal bg_pc_bo_select_iiu		   : std_ulogic_vector(0 to 10);
signal bg_pc_l1p_ccflush_dc_iiu	           : std_ulogic;
signal bg_pc_l1p_abist_ena_dc_iiu	   : std_ulogic;
signal bg_pc_l1p_abist_raw_dc_b_iiu	   : std_ulogic;

signal bg_pc_bo_unload_oiu		   : std_ulogic;
signal bg_pc_bo_load_oiu		   : std_ulogic;
signal bg_pc_bo_repair_oiu		   : std_ulogic;
signal bg_pc_bo_reset_oiu		   : std_ulogic;
signal bg_pc_bo_shdata_oiu		   : std_ulogic;
signal bg_pc_bo_select_oiu		   : std_ulogic_vector(0 to 10);
signal bg_pc_l1p_ccflush_dc_oiu	           : std_ulogic;
signal bg_pc_l1p_abist_ena_dc_oiu	   : std_ulogic;
signal bg_pc_l1p_abist_raw_dc_b_oiu	   : std_ulogic;

signal bg_pc_bo_fail_oiu                   : std_ulogic_vector(0 to 10);
signal bg_pc_bo_diagout_oiu                : std_ulogic_vector(0 to 10);

signal bg_pc_l1p_gptr_sl_thold_2_imm      : std_ulogic;
signal bg_pc_l1p_time_sl_thold_2_imm      : std_ulogic;
signal bg_pc_l1p_repr_sl_thold_2_imm      : std_ulogic;
signal bg_pc_l1p_abst_sl_thold_2_imm      : std_ulogic;
signal bg_pc_l1p_func_sl_thold_2_imm      : std_ulogic_vector(0 to 1);
signal bg_pc_l1p_func_slp_sl_thold_2_imm  : std_ulogic;
signal bg_pc_l1p_bolt_sl_thold_2_imm      : std_ulogic;
signal bg_pc_l1p_ary_nsl_thold_2_imm      : std_ulogic;
signal bg_pc_l1p_sg_2_imm                 : std_ulogic_vector(0 to 1);
signal bg_pc_l1p_fce_2_imm                : std_ulogic;
signal bg_pc_l1p_bo_enable_2_imm          : std_ulogic;
signal bg_pc_bo_unload                    : std_ulogic;
signal bg_pc_bo_load                      : std_ulogic;
signal bg_pc_bo_repair                    : std_ulogic;
signal bg_pc_bo_reset                     : std_ulogic;
signal bg_pc_bo_shdata                    : std_ulogic;
signal bg_pc_bo_select                    : std_ulogic_vector(0 to 10);
signal bg_pc_l1p_ccflush_dc               : std_ulogic;
signal bg_pc_l1p_abist_ena_dc             : std_ulogic;
signal bg_pc_l1p_abist_raw_dc_b           : std_ulogic;
signal bg_an_ac_func_scan_sn_omm          : std_ulogic_vector(60 to 69);
signal bg_an_ac_abst_scan_sn_omm          : std_ulogic_vector(10 to 11);
signal bg_pc_bo_fail                      : std_ulogic_vector(0 to 10);
signal bg_pc_bo_diagout                   : std_ulogic_vector(0 to 10);
signal bg_pc_bo_fail_omm                  : std_ulogic_vector(0 to 10);
signal bg_pc_bo_diagout_omm               : std_ulogic_vector(0 to 10);

signal xu_fu_lbist_en_dc                  : std_ulogic;
signal xu_iu_xucr4_mmu_mchk  	          : std_ulogic;
signal xu_mm_xucr4_mmu_mchk     	  : std_ulogic;

-- synopsys translate_off









-- synopsys translate_on


BEGIN


debug_start_tiedowns            <=  (0 to 87 => '0');
trigger_start_tiedowns          <=  (0 to 11 => '0');

ac_rp_trace_to_perfcntr         <=  debug_bus_out_int;            
ac_an_debug_bus                 <=  ac_an_debug_bus_int;

ac_an_power_managed_imm <= ac_an_power_managed_int; 

a2_nclk_copy             <= a2_nclk;


an_ac_bo_enable        <= '0';
an_ac_bo_go            <= '0';
an_ac_bo_cntlclk       <= '0';
an_ac_bo_ccflush       <= '1';
an_ac_bo_reset         <= '0';
an_ac_bo_data          <= '0';
an_ac_bo_shcntl        <= '0';
an_ac_bo_shdata        <= '0';
an_ac_bo_exe           <= '0';
an_ac_bo_sysrepair     <= '0';
an_ac_bo_donein        <= '0';
an_ac_bo_sdin          <= '0';
an_ac_bo_waitin        <= '0';
an_ac_bo_failin        <= '0';
an_ac_bo_fcshdata      <= '0';
an_ac_bo_fcreset       <= '0';

     bg_an_ac_func_scan_sn           <= "0000000000";  
     bg_an_ac_abst_scan_sn           <= "00";          
     bg_pc_l1p_gptr_sl_thold_3       <= '0';
     bg_pc_l1p_time_sl_thold_3       <= '0';
     bg_pc_l1p_repr_sl_thold_3       <= '0';
     bg_pc_l1p_abst_sl_thold_3       <= '0';
     bg_pc_l1p_func_sl_thold_3       <= "00";           
     bg_pc_l1p_func_slp_sl_thold_3   <= '0';
     bg_pc_l1p_bolt_sl_thold_3       <= '0';
     bg_pc_l1p_ary_nsl_thold_3       <= '0';
     bg_pc_l1p_sg_3                  <= "00";           
     bg_pc_l1p_fce_3                 <= '0';
     bg_pc_l1p_bo_enable_3           <= '0';
     bg_pc_bo_unload_iiu             <= '0';
     bg_pc_bo_load_iiu               <= '0';
     bg_pc_bo_repair_iiu             <= '0';
     bg_pc_bo_reset_iiu              <= '0';
     bg_pc_bo_shdata_iiu             <= '0';
     bg_pc_bo_select_iiu             <= "00000000000";   
     bg_pc_l1p_ccflush_dc_iiu        <= '0';
     bg_pc_l1p_abist_ena_dc_iiu      <= '0';
     bg_pc_l1p_abist_raw_dc_b_iiu    <= '0';
     bg_pc_bo_fail                   <= "00000000000";   
     bg_pc_bo_diagout                <= "00000000000";   


spr_pvr_version_dc  <= "01001000";
spr_pvr_revision_dc <= "0010";


a_fuq: entity work.fuq
   generic map(expand_type => expand_type, eff_ifar => xu_eff_ifar, regmode => regmode)
   port map (
      an_ac_abist_mode_dc        => an_ac_abist_mode_dc_oiu,
      an_ac_lbist_ary_wrt_thru_dc => xu_fu_lbist_ary_wrt_thru_dc,
      an_ac_lbist_en_dc          => xu_fu_lbist_en_dc,                
      pc_fu_ccflush_dc           => pc_fu_ccflush_dc,
      an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b_opc,
      an_ac_scan_diag_dc         => an_ac_scan_diag_dc_opc,
      abst_scan_in               => rp_fu_abst_scan_in_q,
      bcfg_scan_in               => iu_fu_bcfg_scan_out,
      ccfg_scan_in               => xu_fu_ccfg_scan_out,
      dcfg_scan_in               => iu_fu_dcfg_scan_out,
      func_scan_in               => rp_fu_func_scan_in_q(0 to 3),
      gptr_scan_in               => pc_fu_gptr_scan_out,
      repr_scan_in               => iu_fu_repr_scan_out,
      time_scan_in               => iu_fu_time_scan_out,
      bx_fu_rp_abst_scan_out     => bx_fu_rp_abst_scan_out,
      bx_rp_abst_scan_out        => bx_rp_abst_scan_out,
      rp_bx_abst_scan_in         => rp_bx_abst_scan_in_q,
      rp_fu_bx_abst_scan_in      => rp_fu_bx_abst_scan_in,
      rp_bx_func_scan_in         => rp_bx_func_scan_in_q,
      rp_fu_bx_func_scan_in      => rp_fu_bx_func_scan_in,
      bx_fu_rp_func_scan_out     => bx_fu_rp_func_scan_out,
      bx_rp_func_scan_out        => bx_rp_func_scan_out,
      debug_data_in              => bx_fu_debug_data, 
      trace_triggers_in          => bx_fu_trigger_data,  
      iu_fu_ex2_n_flush          => iu_fu_ex2_n_flush,
      iu_fu_is2_tid_decode       => iu_fu_is2_tid_decode,
      iu_fu_rf0_bypsel           => iu_fu_rf0_bypsel,
      iu_fu_rf0_fra              => iu_fu_rf0_fra,
      iu_fu_rf0_fra_v            => iu_fu_rf0_fra_v,
      iu_fu_rf0_frb              => iu_fu_rf0_frb,
      iu_fu_rf0_frb_v            => iu_fu_rf0_frb_v,
      iu_fu_rf0_frc              => iu_fu_rf0_frc,
      iu_fu_rf0_frc_v            => iu_fu_rf0_frc_v,
      iu_fu_rf0_frt              => iu_fu_rf0_frt,
      iu_fu_rf0_ifar             => iu_fu_rf0_ifar,
      iu_fu_rf0_instr            => iu_fu_rf0_instr,
      iu_fu_rf0_instr_match      => iu_fu_rf0_instr_match,
      iu_fu_rf0_instr_v          => iu_fu_rf0_instr_v,
      iu_fu_rf0_is_ucode         => iu_fu_rf0_is_ucode,
      iu_fu_rf0_ucfmul           => iu_fu_rf0_ucfmul,
      iu_fu_rf0_ldst_val         => iu_fu_rf0_ldst_val,
      iu_fu_rf0_ldst_tid         => iu_fu_rf0_ldst_tid,
      iu_fu_rf0_ldst_tag         => iu_fu_rf0_ldst_tag,
      iu_fu_rf0_str_val          => iu_fu_rf0_str_val,
      iu_fu_rf0_tid              => iu_fu_rf0_tid,
      nclk                       => a2_nclk,
      pc_fu_abist_di_0           => pc_fu_abist_di_0(0 to 3),
      pc_fu_abist_di_1           => pc_fu_abist_di_1(0 to 3),
      pc_fu_abist_ena_dc         => pc_fu_abist_ena_dc,        
      pc_fu_abist_grf_renb_0     => pc_fu_abist_grf_renb_0,    
      pc_fu_abist_grf_renb_1     => pc_fu_abist_grf_renb_1,    
      pc_fu_abist_grf_wenb_0     => pc_fu_abist_grf_wenb_0,          
      pc_fu_abist_grf_wenb_1     => pc_fu_abist_grf_wenb_1,          
      pc_fu_abist_raddr_0        => pc_fu_abist_raddr_0(0 to 9),
      pc_fu_abist_raddr_1        => pc_fu_abist_raddr_1(0 to 9),
      pc_fu_abist_raw_dc_b       => pc_fu_abist_raw_dc_b,      
      pc_fu_abist_waddr_0        => pc_fu_abist_waddr_0(0 to 9),
      pc_fu_abist_waddr_1        => pc_fu_abist_waddr_1(0 to 9),
      pc_fu_abist_wl144_comp_ena => pc_fu_abist_wl144_comp_ena,
      pc_fu_abst_sl_thold_3      => pc_fu_abst_sl_thold_3,
      pc_fu_abst_slp_sl_thold_3  => pc_fu_abst_slp_sl_thold_3,
      pc_fu_ary_nsl_thold_3      => pc_fu_ary_nsl_thold_3,
      pc_fu_ary_slp_nsl_thold_3  => pc_fu_ary_slp_nsl_thold_3,
      pc_fu_bolt_sl_thold_3	 => pc_fu_bolt_sl_thold_3,
      pc_fu_bo_enable_3  	 => pc_fu_bo_enable_3,
      pc_fu_bo_unload		 => pc_fu_bo_unload,
      pc_fu_bo_load		 => pc_fu_bo_load,    
      pc_fu_bo_reset		 => pc_fu_bo_reset,   
      pc_fu_bo_shdata		 => pc_fu_bo_shdata,   
      pc_fu_bo_select		 => pc_fu_bo_select,
      pc_fu_cfg_sl_thold_3       => pc_fu_cfg_sl_thold_3,
      pc_fu_cfg_slp_sl_thold_3   => pc_fu_cfg_slp_sl_thold_3,
      pc_fu_debug_mux_ctrls      => pc_fu_debug_mux1_ctrls,
      pc_fu_event_mux_ctrls      => pc_fu_event_mux_ctrls, 
      pc_fu_event_count_mode     => pc_fu_event_count_mode,
      pc_fu_fce_3                => pc_fu_fce_3,
      pc_fu_func_nsl_thold_3     => pc_fu_func_nsl_thold_3,
      pc_fu_func_sl_thold_3      => pc_fu_func_sl_thold_3,
      pc_fu_func_slp_nsl_thold_3 => pc_fu_func_slp_nsl_thold_3,
      pc_fu_func_slp_sl_thold_3  => pc_fu_func_slp_sl_thold_3,
      pc_fu_gptr_sl_thold_3      => pc_fu_gptr_sl_thold_3,
      pc_fu_inj_regfile_parity   => pc_fu_inj_regfile_parity,
      pc_fu_instr_trace_mode     => pc_fu_instr_trace_mode,
      pc_fu_instr_trace_tid      => pc_fu_instr_trace_tid,
      pc_fu_ram_mode             => pc_fu_ram_mode,
      pc_fu_ram_thread           => pc_fu_ram_thread,
      pc_fu_repr_sl_thold_3      => pc_fu_repr_sl_thold_3,
      pc_fu_sg_3                 => pc_fu_sg_3,
      slowspr_addr_in            => pc_fu_slowspr_addr,
      slowspr_data_in            => pc_fu_slowspr_data,
      slowspr_done_in            => pc_fu_slowspr_done,
      slowspr_etid_in            => pc_fu_slowspr_etid,
      slowspr_rw_in              => pc_fu_slowspr_rw,
      slowspr_val_in             => pc_fu_slowspr_val,
      pc_fu_time_sl_thold_3      => pc_fu_time_sl_thold_3,
      pc_fu_trace_bus_enable     => pc_fu_trace_bus_enable,
      pc_fu_event_bus_enable     => pc_fu_event_bus_enable, 
      xu_ex1_flush               => xu_n_ex1_flush,
      xu_ex2_flush               => xu_n_ex2_flush,
      xu_ex3_flush               => xu_n_ex3_flush,
      xu_ex4_flush               => xu_n_ex4_flush,
      xu_ex5_flush               => xu_n_ex5_flush,
      xu_fu_ex3_eff_addr         => xu_fu_ex3_eff_addr,
      xu_fu_ex6_load_data        => xu_fu_ex6_load_data(192 to 255),
      xu_fu_ex5_load_le          => xu_fu_ex5_load_le,
      xu_fu_ex5_load_tag         => xu_fu_ex5_load_tag,
      xu_fu_ex5_load_val         => xu_fu_ex5_load_val,
      xu_fu_ex5_reload_val       => xu_fu_ex5_reload_val,
      xu_fu_msr_fp               => xu_fu_msr_fp,
      xu_fu_msr_pr               => xu_fu_msr_pr,
      xu_fu_msr_gs               => xu_fu_msr_gs,
      xu_fu_regfile_seq_beg      => xu_fu_regfile_seq_beg,
      xu_is2_flush               => xu_n_is2_flush,
      xu_rf0_flush               => xu_n_rf0_flush,
      xu_rf1_flush               => xu_n_rf1_flush,
      abst_scan_out              => fu_rp_abst_scan_out,
      bcfg_scan_out              => fu_rp_bcfg_scan_out,
      ccfg_scan_out              => fu_rp_ccfg_scan_out,
      dcfg_scan_out              => fu_rp_dcfg_scan_out,
      func_scan_out              => fu_rp_func_scan_out(0 to 3),
      gptr_scan_out              => fu_bx_gptr_scan_out,
      repr_scan_out              => fu_bx_repr_scan_out,
      time_scan_out              => fu_bx_time_scan_out,
      debug_data_out             => fu_pc_debug_data,   
      trace_triggers_out         => fu_pc_trigger_data,  
      fu_iu_uc_special           => fu_iu_uc_special,
      fu_pc_bo_fail              => fu_pc_bo_fail,
      fu_pc_bo_diagout           => fu_pc_bo_diagout,
      fu_pc_err_regfile_parity   => fu_pc_err_regfile_parity,
      fu_pc_err_regfile_ue       => fu_pc_err_regfile_ue,
      fu_pc_event_data           => fu_pc_event_data,
      fu_pc_ram_data             => fu_pc_ram_data,
      fu_pc_ram_done             => fu_pc_ram_done,
      fu_xu_ex1_ifar             => fu_xu_ex1_ifar,
      fu_xu_ex2_async_block      => fu_xu_ex2_async_block,
      fu_xu_ex2_ifar_val         => fu_xu_ex2_ifar_val,
      fu_xu_ex2_ifar_issued      => fu_xu_ex2_ifar_issued,
      fu_xu_ex2_store_data       => fu_xu_ex2_store_data,
      fu_xu_ex2_store_data_val   => fu_xu_ex2_store_data_val,
      fu_xu_ex3_flush2ucode      => fu_xu_ex3_flush2ucode,
      fu_xu_ex2_instr_match      => fu_xu_ex2_instr_match,
      fu_xu_ex2_instr_type       => fu_xu_ex2_instr_type,
      fu_xu_ex2_is_ucode         => fu_xu_ex2_is_ucode,
      fu_xu_ex3_ap_int_req       => fu_xu_ex3_ap_int_req,
      fu_xu_ex3_n_flush          => fu_xu_ex3_n_flush,
      fu_xu_ex3_np1_flush        => fu_xu_ex3_np1_flush,
      fu_xu_ex3_regfile_err_det  => fu_xu_ex3_regfile_err_det,
      fu_xu_ex3_trap             => fu_xu_ex3_trap,
      fu_xu_ex4_cr               => fu_xu_ex4_cr,
      fu_xu_ex4_cr_bf            => fu_xu_ex4_cr_bf,
      fu_xu_ex4_cr_noflush       => fu_xu_ex4_cr_noflush,
      fu_xu_ex4_cr_val           => fu_xu_ex4_cr_val,
      fu_xu_regfile_seq_end      => fu_xu_regfile_seq_end,
      fu_xu_rf1_act              => fu_xu_rf1_act,
      slowspr_addr_out           => fu_bx_slowspr_addr,
      slowspr_data_out           => fu_bx_slowspr_data,
      slowspr_done_out           => fu_bx_slowspr_done,
      slowspr_etid_out           => fu_bx_slowspr_etid,
      slowspr_rw_out             => fu_bx_slowspr_rw,
      slowspr_val_out            => fu_bx_slowspr_val,
      
      bx_pc_err_inbox_ue_ifu	         => bx_pc_err_inbox_ue,
      bx_pc_err_outbox_ue_ifu	         => bx_pc_err_outbox_ue,
      bx_pc_err_inbox_ecc_ifu	         => bx_pc_err_inbox_ecc,
      bx_pc_err_outbox_ecc_ifu	         => bx_pc_err_outbox_ecc,    
      pc_bx_bolt_sl_thold_3_ifu	         => pc_bx_bolt_sl_thold_3,      
      pc_bx_bo_enable_3_ifu		 => pc_bx_bo_enable_3,       
      pc_bx_bo_unload_ifu	 	 => pc_bx_bo_unload,	       
      pc_bx_bo_repair_ifu	 	 => pc_bx_bo_repair,
      pc_bx_bo_reset_ifu	  	 => pc_bx_bo_reset,
      pc_bx_bo_shdata_ifu	 	 => pc_bx_bo_shdata,
      pc_bx_bo_select_ifu	 	 => pc_bx_bo_select,
      bx_pc_bo_fail_ifu	        	 => bx_pc_bo_fail,	       
      bx_pc_bo_diagout_ifu		 => bx_pc_bo_diagout,
      pc_bx_abist_di_0_ifu		 => pc_bx_abist_di_0,
      pc_bx_abist_ena_dc_ifu	         => pc_bx_abist_ena_dc,
      pc_bx_abist_g8t1p_renb_0_ifu	 => pc_bx_abist_g8t1p_renb_0,
      pc_bx_abist_g8t_bw_0_ifu	         => pc_bx_abist_g8t_bw_0,      
      pc_bx_abist_g8t_bw_1_ifu	         => pc_bx_abist_g8t_bw_1,       
      pc_bx_abist_g8t_dcomp_ifu	         => pc_bx_abist_g8t_dcomp,      
      pc_bx_abist_g8t_wenb_ifu	         => pc_bx_abist_g8t_wenb,
      pc_bx_abist_raddr_0_ifu	         => pc_bx_abist_raddr_0(4 to 9),
      pc_bx_abist_raw_dc_b_ifu	         => pc_bx_abist_raw_dc_b,
      pc_bx_abist_waddr_0_ifu	         => pc_bx_abist_waddr_0(4 to 9),       
      pc_bx_abist_wl64_comp_ena_ifu	 => pc_bx_abist_wl64_comp_ena,
      pc_bx_trace_bus_enable_ifu	 => pc_bx_trace_bus_enable,     
      pc_bx_debug_mux1_ctrls_ifu	 => pc_bx_debug_mux1_ctrls,
      pc_bx_inj_inbox_ecc_ifu	         => pc_bx_inj_inbox_ecc,
      pc_bx_inj_outbox_ecc_ifu	         => pc_bx_inj_outbox_ecc,       
      pc_bx_ccflush_dc_ifu		 => pc_bx_ccflush_dc,       
      pc_bx_sg_3_ifu			 => pc_bx_sg_3,       
      pc_bx_func_sl_thold_3_ifu	         => pc_bx_func_sl_thold_3,
      pc_bx_func_slp_sl_thold_3_ifu	 => pc_bx_func_slp_sl_thold_3,
      pc_bx_gptr_sl_thold_3_ifu	         => pc_bx_gptr_sl_thold_3, 
      pc_bx_time_sl_thold_3_ifu	         => pc_bx_time_sl_thold_3, 
      pc_bx_repr_sl_thold_3_ifu	         => pc_bx_repr_sl_thold_3, 
      pc_bx_abst_sl_thold_3_ifu	         => pc_bx_abst_sl_thold_3, 
      pc_bx_ary_nsl_thold_3_ifu	         => pc_bx_ary_nsl_thold_3, 
      pc_bx_ary_slp_nsl_thold_3_ifu	 => pc_bx_ary_slp_nsl_thold_3,

     xu_pc_err_mcsr_summary_ifu             => xu_pc_err_mcsr_summary,
     xu_pc_err_ierat_parity_ifu             => xu_pc_err_ierat_parity,      
     xu_pc_err_derat_parity_ifu             => xu_pc_err_derat_parity,      
     xu_pc_err_tlb_parity_ifu               => xu_pc_err_tlb_parity,	    
     xu_pc_err_tlb_lru_parity_ifu           => xu_pc_err_tlb_lru_parity,    
     xu_pc_err_ierat_multihit_ifu           => xu_pc_err_ierat_multihit,    
     xu_pc_err_derat_multihit_ifu           => xu_pc_err_derat_multihit,    
     xu_pc_err_tlb_multihit_ifu             => xu_pc_err_tlb_multihit,      
     xu_pc_err_ext_mchk_ifu                 => xu_pc_err_ext_mchk,	    
     xu_pc_err_ditc_overrun_ifu             => xu_pc_err_ditc_overrun,      
     xu_pc_err_local_snoop_reject_ifu       => xu_pc_err_local_snoop_reject,
     xu_pc_err_attention_instr_ifu          => xu_pc_err_attention_instr,   
     xu_pc_err_dcache_parity_ifu            => xu_pc_err_dcache_parity,     
     xu_pc_err_dcachedir_parity_ifu         => xu_pc_err_dcachedir_parity,  
     xu_pc_err_dcachedir_multihit_ifu       => xu_pc_err_dcachedir_multihit,
     xu_pc_err_debug_event_ifu              => xu_pc_err_debug_event,	    
     xu_pc_err_invld_reld_ifu               => xu_pc_err_invld_reld,	    
     xu_pc_err_l2intrf_ecc_ifu              => xu_pc_err_l2intrf_ecc,	    
     xu_pc_err_l2intrf_ue_ifu               => xu_pc_err_l2intrf_ue,	    
     xu_pc_err_l2credit_overrun_ifu         => xu_pc_err_l2credit_overrun,  
     xu_pc_err_llbust_attempt_ifu           => xu_pc_err_llbust_attempt,    
     xu_pc_err_llbust_failed_ifu            => xu_pc_err_llbust_failed,     
     xu_pc_err_nia_miscmpr_ifu              => xu_pc_err_nia_miscmpr,	    
     xu_pc_err_regfile_parity_ifu           => xu_pc_err_regfile_parity,    
     xu_pc_err_regfile_ue_ifu               => xu_pc_err_regfile_ue,	    
     xu_pc_err_sprg_ecc_ifu                 => xu_pc_err_sprg_ecc,	    
     xu_pc_err_sprg_ue_ifu                  => xu_pc_err_sprg_ue,	    
     xu_pc_err_wdt_reset_ifu                => xu_pc_err_wdt_reset,	    
     xu_pc_event_data_ifu                   => xu_pc_event_data,	    
     xu_pc_ram_data_ifu                     => xu_pc_ram_data,	    
     xu_pc_ram_done_ifu                     => xu_pc_ram_done,  	    
     xu_pc_ram_interrupt_ifu                => xu_pc_ram_interrupt,	    
     xu_pc_running_ifu                      => xu_pc_running,		    
     xu_pc_spr_ccr0_pme_ifu                 => xu_pc_spr_ccr0_pme,	    
     xu_pc_spr_ccr0_we_ifu                  => xu_pc_spr_ccr0_we,	    
     xu_pc_step_done_ifu                    => xu_pc_step_done, 	    
     xu_pc_stop_dbg_event_ifu               => xu_pc_stop_dbg_event,	    
     pc_xu_bolt_sl_thold_3_ifu              => pc_xu_bolt_sl_thold_3,	    
     pc_xu_bo_enable_3_ifu                  => pc_xu_bo_enable_3,	    
     pc_xu_bo_unload_ifu                    => pc_xu_bo_unload, 	    
     pc_xu_bo_load_ifu                      => pc_xu_bo_load,		    
     pc_xu_bo_repair_ifu                    => pc_xu_bo_repair, 	    
     pc_xu_bo_reset_ifu                     => pc_xu_bo_reset,  	    
     pc_xu_bo_shdata_ifu                    => pc_xu_bo_shdata, 	    
     pc_xu_bo_select_ifu                    => pc_xu_bo_select, 	    
     xu_pc_bo_fail_ifu                      => xu_pc_bo_fail,		    
     xu_pc_bo_diagout_ifu                   => xu_pc_bo_diagout,	    
     pc_xu_abist_dcomp_g6t_2r_ifu           => pc_xu_abist_dcomp_g6t_2r,    
     pc_xu_abist_di_0_ifu                   => pc_xu_abist_di_0,	    
     pc_xu_abist_di_1_ifu                   => pc_xu_abist_di_1,	    
     pc_xu_abist_di_g6t_2r_ifu              => pc_xu_abist_di_g6t_2r,	    
     pc_xu_abist_ena_dc_ifu                 => pc_xu_abist_ena_dc,	    
     pc_xu_abist_g6t_bw_ifu                 => pc_xu_abist_g6t_bw,	    
     pc_xu_abist_g6t_r_wb_ifu               => pc_xu_abist_g6t_r_wb,	    
     pc_xu_abist_g8t1p_renb_0_ifu           => pc_xu_abist_g8t1p_renb_0,    
     pc_xu_abist_g8t_bw_0_ifu               => pc_xu_abist_g8t_bw_0,	    
     pc_xu_abist_g8t_bw_1_ifu               => pc_xu_abist_g8t_bw_1,	    
     pc_xu_abist_g8t_dcomp_ifu              => pc_xu_abist_g8t_dcomp,	    
     pc_xu_abist_g8t_wenb_ifu               => pc_xu_abist_g8t_wenb,	    
     pc_xu_abist_grf_renb_0_ifu             => pc_xu_abist_grf_renb_0,      
     pc_xu_abist_grf_renb_1_ifu             => pc_xu_abist_grf_renb_1,      
     pc_xu_abist_grf_wenb_0_ifu             => pc_xu_abist_grf_wenb_0,      
     pc_xu_abist_grf_wenb_1_ifu             => pc_xu_abist_grf_wenb_1,      
     pc_xu_abist_raddr_0_ifu                => pc_xu_abist_raddr_0,	    
     pc_xu_abist_raddr_1_ifu                => pc_xu_abist_raddr_1,	    
     pc_xu_abist_raw_dc_b_ifu               => pc_xu_abist_raw_dc_b,	    
     pc_xu_abist_waddr_0_ifu                => pc_xu_abist_waddr_0,	    
     pc_xu_abist_waddr_1_ifu                => pc_xu_abist_waddr_1,	    
     pc_xu_abist_wl144_comp_ena_ifu         => pc_xu_abist_wl144_comp_ena,    
     pc_xu_abist_wl32_comp_ena_ifu          => pc_xu_abist_wl32_comp_ena,     
     pc_xu_abist_wl512_comp_ena_ifu         => pc_xu_abist_wl512_comp_ena,    
     pc_xu_event_mux_ctrls_ifu              => pc_xu_event_mux_ctrls,	      
     pc_xu_lsu_event_mux_ctrls_ifu          => pc_xu_lsu_event_mux_ctrls,     
     pc_xu_event_bus_enable_ifu             => pc_xu_event_bus_enable,        
     pc_xu_abst_sl_thold_3_ifu              => pc_xu_abst_sl_thold_3,	      
     pc_xu_abst_slp_sl_thold_3_ifu          => pc_xu_abst_slp_sl_thold_3,     
     pc_xu_regf_sl_thold_3_ifu              => pc_xu_regf_sl_thold_3,	      
     pc_xu_regf_slp_sl_thold_3_ifu          => pc_xu_regf_slp_sl_thold_3,     
     pc_xu_ary_nsl_thold_3_ifu              => pc_xu_ary_nsl_thold_3,	      
     pc_xu_ary_slp_nsl_thold_3_ifu          => pc_xu_ary_slp_nsl_thold_3,     
     pc_xu_cache_par_err_event_ifu          => pc_xu_cache_par_err_event,     
     pc_xu_ccflush_dc_ifu                   => pc_xu_ccflush_dc,	      
     pc_xu_cfg_sl_thold_3_ifu               => pc_xu_cfg_sl_thold_3,	      
     pc_xu_cfg_slp_sl_thold_3_ifu           => pc_xu_cfg_slp_sl_thold_3,      
     pc_xu_dbg_action_ifu                   => pc_xu_dbg_action,	      
     pc_xu_debug_mux1_ctrls_ifu             => pc_xu_debug_mux1_ctrls,        
     pc_xu_debug_mux2_ctrls_ifu             => pc_xu_debug_mux2_ctrls,        
     pc_xu_debug_mux3_ctrls_ifu             => pc_xu_debug_mux3_ctrls,        
     pc_xu_debug_mux4_ctrls_ifu             => pc_xu_debug_mux4_ctrls,        
     pc_xu_decrem_dis_on_stop_ifu           => pc_xu_decrem_dis_on_stop,      
     pc_xu_event_count_mode_ifu             => pc_xu_event_count_mode,        
     pc_xu_extirpts_dis_on_stop_ifu         => pc_xu_extirpts_dis_on_stop,    
     pc_xu_fce_3_ifu                        => pc_xu_fce_3,		      
     pc_xu_force_ude_ifu                    => pc_xu_force_ude, 	      
     pc_xu_func_nsl_thold_3_ifu             => pc_xu_func_nsl_thold_3,        
     pc_xu_func_sl_thold_3_ifu              => pc_xu_func_sl_thold_3,	      
     pc_xu_func_slp_nsl_thold_3_ifu         => pc_xu_func_slp_nsl_thold_3,    
     pc_xu_func_slp_sl_thold_3_ifu          => pc_xu_func_slp_sl_thold_3,     
     pc_xu_gptr_sl_thold_3_ifu              => pc_xu_gptr_sl_thold_3,	      
     pc_xu_init_reset_ifu                   => pc_xu_init_reset,	      
     pc_xu_inj_dcache_parity_ifu            => pc_xu_inj_dcache_parity,       
     pc_xu_inj_dcachedir_parity_ifu         => pc_xu_inj_dcachedir_parity,    
     pc_xu_inj_llbust_attempt_ifu           => pc_xu_inj_llbust_attempt,      
     pc_xu_inj_llbust_failed_ifu            => pc_xu_inj_llbust_failed,       
     pc_xu_inj_sprg_ecc_ifu                 => pc_xu_inj_sprg_ecc,	      
     pc_xu_inj_regfile_parity_ifu           => pc_xu_inj_regfile_parity,      
     pc_xu_inj_wdt_reset_ifu                => pc_xu_inj_wdt_reset,	      
     pc_xu_inj_dcachedir_multihit_ifu       => pc_xu_inj_dcachedir_multihit,  
     pc_xu_instr_trace_mode_ifu             => pc_xu_instr_trace_mode,        
     pc_xu_instr_trace_tid_ifu              => pc_xu_instr_trace_tid,	      
     pc_xu_msrovride_enab_ifu               => pc_xu_msrovride_enab,	      
     pc_xu_msrovride_gs_ifu                 => pc_xu_msrovride_gs,	      
     pc_xu_msrovride_pr_ifu                 => pc_xu_msrovride_pr,	      
     pc_xu_ram_execute_ifu                  => pc_xu_ram_execute,	      
     pc_xu_ram_flush_thread_ifu             => pc_xu_ram_flush_thread,        
     pc_xu_ram_mode_ifu                     => pc_xu_ram_mode,  	      
     pc_xu_ram_thread_ifu                   => pc_xu_ram_thread,	      
     pc_xu_repr_sl_thold_3_ifu              => pc_xu_repr_sl_thold_3,	      
     pc_xu_reset_1_cmplt_ifu                => pc_xu_reset_1_complete,	      
     pc_xu_reset_2_cmplt_ifu                => pc_xu_reset_2_complete,	      
     pc_xu_reset_3_cmplt_ifu                => pc_xu_reset_3_complete,	      
     pc_xu_reset_wd_cmplt_ifu               => pc_xu_reset_wd_complete,	      
     pc_xu_sg_3_ifu                         => pc_xu_sg_3,		      
     pc_xu_step_ifu                         => pc_xu_step,		      
     pc_xu_stop_ifu                         => pc_xu_stop,		      
     pc_xu_time_sl_thold_3_ifu              => pc_xu_time_sl_thold_3,	      
     pc_xu_timebase_dis_on_stop_ifu         => pc_xu_timebase_dis_on_stop,    
     pc_xu_trace_bus_enable_ifu             => pc_xu_trace_bus_enable,        

     bx_pc_err_inbox_ue_ofu	      => bx_pc_err_inbox_ue_ofu     ,
     bx_pc_err_outbox_ue_ofu	      => bx_pc_err_outbox_ue_ofu,
     bx_pc_err_inbox_ecc_ofu	      => bx_pc_err_inbox_ecc_ofu,
     bx_pc_err_outbox_ecc_ofu	      => bx_pc_err_outbox_ecc_ofu,
     pc_bx_bolt_sl_thold_3_ofu        => pc_bx_bolt_sl_thold_3_ofu,
     pc_bx_bo_enable_3_ofu	      => pc_bx_bo_enable_3_ofu  ,
     pc_bx_bo_unload_ofu	      => pc_bx_bo_unload_ofu	    ,  
     pc_bx_bo_repair_ofu	      => pc_bx_bo_repair_ofu	     , 
     pc_bx_bo_reset_ofu 	      => pc_bx_bo_reset_ofu    ,
     pc_bx_bo_shdata_ofu	      => pc_bx_bo_shdata_ofu	    ,  
     pc_bx_bo_select_ofu	      => pc_bx_bo_select_ofu	     , 
     bx_pc_bo_fail_ofu  	      => bx_pc_bo_fail_ofu   ,
     bx_pc_bo_diagout_ofu	      => bx_pc_bo_diagout_ofu ,  
     pc_bx_abist_di_0_ofu	      => pc_bx_abist_di_0_ofu  , 
     pc_bx_abist_ena_dc_ofu	      => pc_bx_abist_ena_dc_ofu     ,
     pc_bx_abist_g8t1p_renb_0_ofu     => pc_bx_abist_g8t1p_renb_0_ofu,
     pc_bx_abist_g8t_bw_0_ofu	      => pc_bx_abist_g8t_bw_0_ofu,
     pc_bx_abist_g8t_bw_1_ofu	      => pc_bx_abist_g8t_bw_1_ofu,
     pc_bx_abist_g8t_dcomp_ofu        => pc_bx_abist_g8t_dcomp_ofu,
     pc_bx_abist_g8t_wenb_ofu	      => pc_bx_abist_g8t_wenb_ofu,
     pc_bx_abist_raddr_0_ofu	      => pc_bx_abist_raddr_0_ofu,
     pc_bx_abist_raw_dc_b_ofu	      => pc_bx_abist_raw_dc_b_ofu,
     pc_bx_abist_waddr_0_ofu	      => pc_bx_abist_waddr_0_ofu,
     pc_bx_abist_wl64_comp_ena_ofu    => pc_bx_abist_wl64_comp_ena_ofu,
     pc_bx_trace_bus_enable_ofu       => pc_bx_trace_bus_enable_ofu,
     pc_bx_debug_mux1_ctrls_ofu       => pc_bx_debug_mux1_ctrls_ofu,
     pc_bx_inj_inbox_ecc_ofu	      => pc_bx_inj_inbox_ecc_ofu,
     pc_bx_inj_outbox_ecc_ofu	      => pc_bx_inj_outbox_ecc_ofu,
     pc_bx_ccflush_dc_ofu	      => pc_bx_ccflush_dc_ofu	,
     pc_bx_sg_3_ofu		      => pc_bx_sg_3_ofu      ,
     pc_bx_func_sl_thold_3_ofu        => pc_bx_func_sl_thold_3_ofu,
     pc_bx_func_slp_sl_thold_3_ofu    => pc_bx_func_slp_sl_thold_3_ofu,
     pc_bx_gptr_sl_thold_3_ofu        => pc_bx_gptr_sl_thold_3_ofu,
     pc_bx_time_sl_thold_3_ofu        => pc_bx_time_sl_thold_3_ofu,
     pc_bx_repr_sl_thold_3_ofu        => pc_bx_repr_sl_thold_3_ofu,
     pc_bx_abst_sl_thold_3_ofu        => pc_bx_abst_sl_thold_3_ofu,
     pc_bx_ary_nsl_thold_3_ofu        => pc_bx_ary_nsl_thold_3_ofu,
     pc_bx_ary_slp_nsl_thold_3_ofu    => pc_bx_ary_slp_nsl_thold_3_ofu,

     xu_pc_err_mcsr_summary_ofu           => xu_pc_err_mcsr_summary_ofu	     ,
     xu_pc_err_ierat_parity_ofu           => xu_pc_err_ierat_parity_ofu	     ,
     xu_pc_err_derat_parity_ofu           => xu_pc_err_derat_parity_ofu	     ,
     xu_pc_err_tlb_parity_ofu             => xu_pc_err_tlb_parity_ofu	     ,
     xu_pc_err_tlb_lru_parity_ofu         => xu_pc_err_tlb_lru_parity_ofu    ,  
     xu_pc_err_ierat_multihit_ofu         => xu_pc_err_ierat_multihit_ofu    ,  
     xu_pc_err_derat_multihit_ofu         => xu_pc_err_derat_multihit_ofu    ,  
     xu_pc_err_tlb_multihit_ofu           => xu_pc_err_tlb_multihit_ofu	     ,
     xu_pc_err_ext_mchk_ofu               => xu_pc_err_ext_mchk_ofu	     ,
     xu_pc_err_ditc_overrun_ofu           => xu_pc_err_ditc_overrun_ofu	     ,
     xu_pc_err_local_snoop_reject_ofu     => xu_pc_err_local_snoop_reject_ofu , 
     xu_pc_err_attention_instr_ofu        => xu_pc_err_attention_instr_ofu     ,
     xu_pc_err_dcache_parity_ofu          => xu_pc_err_dcache_parity_ofu       ,
     xu_pc_err_dcachedir_parity_ofu       => xu_pc_err_dcachedir_parity_ofu    ,
     xu_pc_err_dcachedir_multihit_ofu     => xu_pc_err_dcachedir_multihit_ofu  ,
     xu_pc_err_debug_event_ofu            => xu_pc_err_debug_event_ofu	     ,
     xu_pc_err_invld_reld_ofu             => xu_pc_err_invld_reld_ofu	     ,
     xu_pc_err_l2intrf_ecc_ofu            => xu_pc_err_l2intrf_ecc_ofu	     ,
     xu_pc_err_l2intrf_ue_ofu             => xu_pc_err_l2intrf_ue_ofu	     ,
     xu_pc_err_l2credit_overrun_ofu       => xu_pc_err_l2credit_overrun_ofu  ,  
     xu_pc_err_llbust_attempt_ofu         => xu_pc_err_llbust_attempt_ofu    ,  
     xu_pc_err_llbust_failed_ofu          => xu_pc_err_llbust_failed_ofu     ,  
     xu_pc_err_nia_miscmpr_ofu            => xu_pc_err_nia_miscmpr_ofu	     ,
     xu_pc_err_regfile_parity_ofu         => xu_pc_err_regfile_parity_ofu    ,  
     xu_pc_err_regfile_ue_ofu             => xu_pc_err_regfile_ue_ofu	     ,
     xu_pc_err_sprg_ecc_ofu               => xu_pc_err_sprg_ecc_ofu	     ,
     xu_pc_err_sprg_ue_ofu                => xu_pc_err_sprg_ue_ofu	     ,
     xu_pc_err_wdt_reset_ofu              => xu_pc_err_wdt_reset_ofu	     ,
     xu_pc_event_data_ofu                 => xu_pc_event_data_ofu 	     ,
     xu_pc_ram_data_ofu                   => xu_pc_ram_data_ofu		     ,
     xu_pc_ram_done_ofu                   => xu_pc_ram_done_ofu		     ,
     xu_pc_ram_interrupt_ofu              => xu_pc_ram_interrupt_ofu	     ,
     xu_pc_running_ofu                    => xu_pc_running_ofu		     ,
     xu_pc_spr_ccr0_pme_ofu               => xu_pc_spr_ccr0_pme_ofu	     ,
     xu_pc_spr_ccr0_we_ofu                => xu_pc_spr_ccr0_we_ofu	     ,
     xu_pc_step_done_ofu                  => xu_pc_step_done_ofu  	     ,
     xu_pc_stop_dbg_event_ofu             => xu_pc_stop_dbg_event_ofu	     ,
     pc_xu_bolt_sl_thold_3_ofu            => pc_xu_bolt_sl_thold_3_ofu	     ,
     pc_xu_bo_enable_3_ofu                => pc_xu_bo_enable_3_ofu	     ,
     pc_xu_bo_unload_ofu                  => pc_xu_bo_unload_ofu  	     ,
     pc_xu_bo_load_ofu                    => pc_xu_bo_load_ofu		     ,
     pc_xu_bo_repair_ofu                  => pc_xu_bo_repair_ofu  	     ,
     pc_xu_bo_reset_ofu                   => pc_xu_bo_reset_ofu		     ,
     pc_xu_bo_shdata_ofu                  => pc_xu_bo_shdata_ofu  	     ,
     pc_xu_bo_select_ofu                  => pc_xu_bo_select_ofu  	     ,
     xu_pc_bo_fail_ofu                    => xu_pc_bo_fail_ofu		     ,
     xu_pc_bo_diagout_ofu                 => xu_pc_bo_diagout_ofu 	     ,
     pc_xu_abist_dcomp_g6t_2r_ofu         => pc_xu_abist_dcomp_g6t_2r_ofu    ,  
     pc_xu_abist_di_0_ofu                 => pc_xu_abist_di_0_ofu 	     ,
     pc_xu_abist_di_1_ofu                 => pc_xu_abist_di_1_ofu 	     ,
     pc_xu_abist_di_g6t_2r_ofu            => pc_xu_abist_di_g6t_2r_ofu	     ,
     pc_xu_abist_ena_dc_ofu               => pc_xu_abist_ena_dc_ofu	     ,
     pc_xu_abist_g6t_bw_ofu               => pc_xu_abist_g6t_bw_ofu	     ,
     pc_xu_abist_g6t_r_wb_ofu             => pc_xu_abist_g6t_r_wb_ofu	     ,
     pc_xu_abist_g8t1p_renb_0_ofu         => pc_xu_abist_g8t1p_renb_0_ofu    ,  
     pc_xu_abist_g8t_bw_0_ofu             => pc_xu_abist_g8t_bw_0_ofu	     ,
     pc_xu_abist_g8t_bw_1_ofu             => pc_xu_abist_g8t_bw_1_ofu	     ,
     pc_xu_abist_g8t_dcomp_ofu            => pc_xu_abist_g8t_dcomp_ofu	     ,
     pc_xu_abist_g8t_wenb_ofu             => pc_xu_abist_g8t_wenb_ofu	     ,
     pc_xu_abist_grf_renb_0_ofu           => pc_xu_abist_grf_renb_0_ofu	    ,
     pc_xu_abist_grf_renb_1_ofu           => pc_xu_abist_grf_renb_1_ofu	    , 
     pc_xu_abist_grf_wenb_0_ofu           => pc_xu_abist_grf_wenb_0_ofu	    , 
     pc_xu_abist_grf_wenb_1_ofu           => pc_xu_abist_grf_wenb_1_ofu	    , 
     pc_xu_abist_raddr_0_ofu              => pc_xu_abist_raddr_0_ofu	    , 
     pc_xu_abist_raddr_1_ofu              => pc_xu_abist_raddr_1_ofu	    , 
     pc_xu_abist_raw_dc_b_ofu             => pc_xu_abist_raw_dc_b_ofu	    , 
     pc_xu_abist_waddr_0_ofu              => pc_xu_abist_waddr_0_ofu	    , 
     pc_xu_abist_waddr_1_ofu              => pc_xu_abist_waddr_1_ofu	    , 
     pc_xu_abist_wl144_comp_ena_ofu       => pc_xu_abist_wl144_comp_ena_ofu ,    
     pc_xu_abist_wl32_comp_ena_ofu        => pc_xu_abist_wl32_comp_ena_ofu  ,    
     pc_xu_abist_wl512_comp_ena_ofu       => pc_xu_abist_wl512_comp_ena_ofu ,    
     pc_xu_event_mux_ctrls_ofu            => pc_xu_event_mux_ctrls_ofu	    ,  
     pc_xu_lsu_event_mux_ctrls_ofu        => pc_xu_lsu_event_mux_ctrls_ofu  ,    
     pc_xu_event_bus_enable_ofu           => pc_xu_event_bus_enable_ofu	    ,  
     pc_xu_abst_sl_thold_3_ofu            => pc_xu_abst_sl_thold_3_ofu	    ,  
     pc_xu_abst_slp_sl_thold_3_ofu        => pc_xu_abst_slp_sl_thold_3_ofu  ,    
     pc_xu_regf_sl_thold_3_ofu            => pc_xu_regf_sl_thold_3_ofu	    ,  
     pc_xu_regf_slp_sl_thold_3_ofu        => pc_xu_regf_slp_sl_thold_3_ofu  ,    
     pc_xu_ary_nsl_thold_3_ofu            => pc_xu_ary_nsl_thold_3_ofu	    ,  
     pc_xu_ary_slp_nsl_thold_3_ofu        => pc_xu_ary_slp_nsl_thold_3_ofu  ,    
     pc_xu_cache_par_err_event_ofu        => pc_xu_cache_par_err_event_ofu  ,    
     pc_xu_ccflush_dc_ofu                 => pc_xu_ccflush_dc_ofu 	    ,  
     pc_xu_cfg_sl_thold_3_ofu             => pc_xu_cfg_sl_thold_3_ofu	    ,  
     pc_xu_cfg_slp_sl_thold_3_ofu         => pc_xu_cfg_slp_sl_thold_3_ofu   ,    
     pc_xu_dbg_action_ofu                 => pc_xu_dbg_action_ofu 	    ,  
     pc_xu_debug_mux1_ctrls_ofu           => pc_xu_debug_mux1_ctrls_ofu	    ,  
     pc_xu_debug_mux2_ctrls_ofu           => pc_xu_debug_mux2_ctrls_ofu	    ,  
     pc_xu_debug_mux3_ctrls_ofu           => pc_xu_debug_mux3_ctrls_ofu	    ,  
     pc_xu_debug_mux4_ctrls_ofu           => pc_xu_debug_mux4_ctrls_ofu	    ,  
     pc_xu_decrem_dis_on_stop_ofu         => pc_xu_decrem_dis_on_stop_ofu   ,    
     pc_xu_event_count_mode_ofu           => pc_xu_event_count_mode_ofu	    ,  
     pc_xu_extirpts_dis_on_stop_ofu       => pc_xu_extirpts_dis_on_stop_ofu ,    
     pc_xu_fce_3_ofu                      => pc_xu_fce_3_ofu		    ,  
     pc_xu_force_ude_ofu                  => pc_xu_force_ude_ofu  	    ,  
     pc_xu_func_nsl_thold_3_ofu           => pc_xu_func_nsl_thold_3_ofu	    ,  
     pc_xu_func_sl_thold_3_ofu            => pc_xu_func_sl_thold_3_ofu	    ,  
     pc_xu_func_slp_nsl_thold_3_ofu       => pc_xu_func_slp_nsl_thold_3_ofu ,    
     pc_xu_func_slp_sl_thold_3_ofu        => pc_xu_func_slp_sl_thold_3_ofu  ,    
     pc_xu_gptr_sl_thold_3_ofu            => pc_xu_gptr_sl_thold_3_ofu	    ,  
     pc_xu_init_reset_ofu                 => pc_xu_init_reset_ofu 	    ,  
     pc_xu_inj_dcache_parity_ofu          => pc_xu_inj_dcache_parity_ofu    ,    
     pc_xu_inj_dcachedir_parity_ofu       => pc_xu_inj_dcachedir_parity_ofu ,    
     pc_xu_inj_llbust_attempt_ofu         => pc_xu_inj_llbust_attempt_ofu   ,    
     pc_xu_inj_llbust_failed_ofu          => pc_xu_inj_llbust_failed_ofu    ,    
     pc_xu_inj_sprg_ecc_ofu               => pc_xu_inj_sprg_ecc_ofu	    ,  
     pc_xu_inj_regfile_parity_ofu         => pc_xu_inj_regfile_parity_ofu   ,    
     pc_xu_inj_wdt_reset_ofu              => pc_xu_inj_wdt_reset_ofu	    ,  
     pc_xu_inj_dcachedir_multihit_ofu     => pc_xu_inj_dcachedir_multihit_ofu,   
     pc_xu_instr_trace_mode_ofu           => pc_xu_instr_trace_mode_ofu	     , 
     pc_xu_instr_trace_tid_ofu            => pc_xu_instr_trace_tid_ofu	     , 
     pc_xu_msrovride_enab_ofu             => pc_xu_msrovride_enab_ofu	     , 
     pc_xu_msrovride_gs_ofu               => pc_xu_msrovride_gs_ofu	     , 
     pc_xu_msrovride_pr_ofu               => pc_xu_msrovride_pr_ofu	     , 
     pc_xu_ram_execute_ofu                => pc_xu_ram_execute_ofu	     , 
     pc_xu_ram_flush_thread_ofu           => pc_xu_ram_flush_thread_ofu	     , 
     pc_xu_ram_mode_ofu                   => pc_xu_ram_mode_ofu		     , 
     pc_xu_ram_thread_ofu                 => pc_xu_ram_thread_ofu 	     , 
     pc_xu_repr_sl_thold_3_ofu            => pc_xu_repr_sl_thold_3_ofu	     , 
     pc_xu_reset_1_cmplt_ofu              => pc_xu_reset_1_cmplt_ofu	     , 
     pc_xu_reset_2_cmplt_ofu              => pc_xu_reset_2_cmplt_ofu	     , 
     pc_xu_reset_3_cmplt_ofu              => pc_xu_reset_3_cmplt_ofu	     , 
     pc_xu_reset_wd_cmplt_ofu             => pc_xu_reset_wd_cmplt_ofu	     , 
     pc_xu_sg_3_ofu                       => pc_xu_sg_3_ofu		     , 
     pc_xu_step_ofu                       => pc_xu_step_ofu		     , 
     pc_xu_stop_ofu                       => pc_xu_stop_ofu		     , 
     pc_xu_time_sl_thold_3_ofu            => pc_xu_time_sl_thold_3_ofu	     , 
     pc_xu_timebase_dis_on_stop_ofu       => pc_xu_timebase_dis_on_stop_ofu  ,   
     pc_xu_trace_bus_enable_ofu           => pc_xu_trace_bus_enable_ofu	     , 
     an_ac_scan_dis_dc_b_ofu              => an_ac_scan_dis_dc_b_ofu,
     an_ac_scan_diag_dc_ofu               => an_ac_scan_diag_dc_ofu,

     xu_ex2_flush_ofu                     => xu_ex2_flush_ofu,		  
     xu_ex3_flush_ofu                     => xu_ex3_flush_ofu,		  
     xu_ex4_flush_ofu                     => xu_ex4_flush_ofu,		  
     xu_ex5_flush_ofu                     => xu_ex5_flush_ofu,		  
     an_ac_lbist_ary_wrt_thru_dc_ofu      => an_ac_lbist_ary_wrt_thru_dc_ofu,
     
     xu_pc_err_mchk_disabled_ifu          => xu_pc_err_mchk_disabled,
     xu_pc_lsu_event_data_ifu             => xu_pc_lsu_event_data,
     xu_pc_err_mchk_disabled_ofu          => xu_pc_err_mchk_disabled_ofu,
     xu_pc_lsu_event_data_ofu             => xu_pc_lsu_event_data_ofu,
     
      gnd                        => gnd,
      vdd                        => vdd
   ); 

a_iuq: entity work.iuq
   generic map(expand_type => expand_type,
      bcfg_epn_0to15  => bcfg_epn_0to15,
      bcfg_epn_16to31 => bcfg_epn_16to31,
      bcfg_epn_32to47 => bcfg_epn_32to47,
      bcfg_epn_48to51 => bcfg_epn_48to51,
      bcfg_rpn_22to31 => bcfg_rpn_22to31,
      bcfg_rpn_32to47 => bcfg_rpn_32to47,
      bcfg_rpn_48to51 => bcfg_rpn_48to51,
      fpr_addr_width  => fpr_addr_width,
      lmq_entries     => lmq_entries,
      regmode         => regmode,
      threads         => threads,
      ucode_mode      => ucode_mode)
   port map (
      abst_scan_in                  => an_ac_abst_scan_in_omm_iu(0 to 2),
      bcfg_scan_in                  => an_ac_bcfg_scan_in_omm_bit3,
      ccfg_scan_in                  => mm_iu_ccfg_scan_out,
      dcfg_scan_in                  => an_ac_dcfg_scan_in_omm(1),
      func_scan_in		    => an_ac_func_scan_in_omm_iua(6 to 19),
      gptr_scan_in                  => an_ac_gptr_scan_in_omm,
      repr_scan_in                  => an_ac_repr_scan_in_omm,
      time_scan_in                  => an_ac_time_scan_in_omm,
      regf_scan_in                  => an_ac_regf_scan_in_omm(0 to 4),
      debug_data_in                 => pc_iu_debug_data, 
      trace_triggers_in             => pc_iu_trigger_data,  
      an_ac_back_inv                => an_ac_back_inv_omm,
      an_ac_back_inv_addr           => an_ac_back_inv_addr_omm(real_ifar'left to 63),
      an_ac_back_inv_target_iiu_a   => an_ac_back_inv_target_omm_iua,
      an_ac_back_inv_target_iiu_b   => an_ac_back_inv_target_omm_iub,
      an_ac_grffence_en_dc          => an_ac_camfence_en_dc_omm,
      an_ac_icbi_ack                => an_ac_icbi_ack_omm,
      an_ac_icbi_ack_thread         => an_ac_icbi_ack_thread_omm,
      an_ac_lbist_ary_wrt_thru_dc   => an_ac_lbist_ary_wrt_thru_dc_omm,
      an_ac_reld_core_tag           => xu_iu_reld_core_tag,
      an_ac_reld_data               => xu_iu_reld_data,
      an_ac_reld_data_vld           => xu_iu_reld_data_vld,
      an_ac_reld_data_coming_clone  => xu_iu_reld_data_coming_clone,
      an_ac_reld_ditc_clone         => xu_iu_reld_ditc_clone,
      an_ac_reld_ecc_err            => xu_iu_reld_ecc_err,
      an_ac_reld_ecc_err_ue         => xu_iu_reld_ecc_err_ue,
      an_ac_reld_qw                 => xu_iu_reld_qw,
      an_ac_reld_data_vld_clone     => xu_iu_reld_data_vld_clone,
      an_ac_reld_core_tag_clone     => xu_iu_reld_core_tag_clone,
      an_ac_scan_diag_dc            => an_ac_scan_diag_dc_omm,
      an_ac_stcx_complete           => xu_iu_stcx_complete,
      an_ac_sync_ack                => an_ac_sync_ack_omm,
      fu_iu_uc_special              => fu_iu_uc_special,
      mm_iu_ierat_mmucr0_0          => mm_iu_ierat_mmucr0_0,
      mm_iu_ierat_mmucr0_1          => mm_iu_ierat_mmucr0_1,
      mm_iu_ierat_mmucr0_2          => mm_iu_ierat_mmucr0_2,
      mm_iu_ierat_mmucr0_3          => mm_iu_ierat_mmucr0_3,
      mm_iu_ierat_mmucr1            => mm_iu_ierat_mmucr1,
      mm_iu_ierat_pid0              => mm_iu_ierat_pid0,
      mm_iu_ierat_pid1              => mm_iu_ierat_pid1,
      mm_iu_ierat_pid2              => mm_iu_ierat_pid2,
      mm_iu_ierat_pid3              => mm_iu_ierat_pid3,
      mm_iu_ierat_rel_data          => mm_iu_ierat_rel_data,
      mm_iu_ierat_rel_val           => mm_iu_ierat_rel_val,
      mm_iu_ierat_snoop_attr        => mm_iu_ierat_snoop_attr,
      mm_iu_ierat_snoop_coming      => mm_iu_ierat_snoop_coming,
      mm_iu_ierat_snoop_val         => mm_iu_ierat_snoop_val,
      mm_iu_ierat_snoop_vpn         => mm_iu_ierat_snoop_vpn,
      slowspr_addr_in               => mm_iu_slowspr_addr,
      slowspr_data_in               => mm_iu_slowspr_data,
      slowspr_done_in               => mm_iu_slowspr_done,
      slowspr_etid_in               => mm_iu_slowspr_etid,
      slowspr_rw_in                 => mm_iu_slowspr_rw,
      slowspr_val_in                => mm_iu_slowspr_val,
      nclk                          => a2_nclk,
      pc_iu_abist_dcomp_g6t_2r      => pc_iu_abist_dcomp_g6t_2r(0 to 3),
      pc_iu_abist_di_0              => pc_iu_abist_di_0(0 to 3),
      pc_iu_abist_di_g6t_2r         => pc_iu_abist_di_g6t_2r(0 to 3),
      pc_iu_abist_ena_dc            => pc_iu_abist_ena_dc,        
      pc_iu_abist_g6t_bw            => pc_iu_abist_g6t_bw(0 to 1),
      pc_iu_abist_g6t_r_wb          => pc_iu_abist_g6t_r_wb,      
      pc_iu_abist_g8t1p_renb_0      => pc_iu_abist_g8t1p_renb_0, 
      pc_iu_abist_g8t_bw_0          => pc_iu_abist_g8t_bw_0,      
      pc_iu_abist_g8t_bw_1          => pc_iu_abist_g8t_bw_1,      
      pc_iu_abist_g8t_dcomp         => pc_iu_abist_g8t_dcomp(0 to 3),
      pc_iu_abist_g8t_wenb          => pc_iu_abist_g8t_wenb,      
      pc_iu_abist_raddr_0           => pc_iu_abist_raddr_0(0 to 9),
      pc_iu_abist_raw_dc_b          => pc_iu_abist_raw_dc_b,      
      pc_iu_abist_waddr_0           => pc_iu_abist_waddr_0(0 to 9),
      pc_iu_abist_wl128_comp_ena    => pc_iu_abist_wl128_comp_ena,
      pc_iu_abist_wl256_comp_ena    => pc_iu_abist_wl256_comp_ena,
      pc_iu_abist_wl64_comp_ena     => pc_iu_abist_wl64_comp_ena, 
      pc_iu_bo_enable_4		    => pc_iu_bo_enable_4,
      pc_iu_bo_reset		    => pc_iu_bo_reset,
      pc_iu_bo_unload		    => pc_iu_bo_unload,
      pc_iu_bo_repair		    => pc_iu_bo_repair,
      pc_iu_bo_shdata		    => pc_iu_bo_shdata,
      pc_iu_bo_select		    => pc_iu_bo_select,
      pc_iu_debug_mux1_ctrls        => pc_iu_debug_mux1_ctrls,
      pc_iu_debug_mux2_ctrls        => pc_iu_debug_mux2_ctrls,
      pc_iu_event_bus_enable        => pc_iu_event_bus_enable,
      pc_iu_event_count_mode        => pc_iu_event_count_mode,
      pc_iu_event_mux_ctrls         => pc_iu_event_mux_ctrls,
      pc_iu_gptr_sl_thold_4         => pc_iu_gptr_sl_thold_4,
      pc_iu_time_sl_thold_4         => pc_iu_time_sl_thold_4,
      pc_iu_repr_sl_thold_4         => pc_iu_repr_sl_thold_4,
      pc_iu_abst_sl_thold_4         => pc_iu_abst_sl_thold_4,
      pc_iu_abst_slp_sl_thold_4     => pc_iu_abst_slp_sl_thold_4,
      pc_iu_bolt_sl_thold_4 	 => pc_iu_bolt_sl_thold_4,
      pc_iu_regf_slp_sl_thold_4     => pc_iu_regf_slp_sl_thold_4,
      pc_iu_func_sl_thold_4         => pc_iu_func_sl_thold_4,
      pc_iu_func_slp_sl_thold_4     => pc_iu_func_slp_sl_thold_4,
      pc_iu_cfg_sl_thold_4          => pc_iu_cfg_sl_thold_4,
      pc_iu_cfg_slp_sl_thold_4      => pc_iu_cfg_slp_sl_thold_4,
      pc_iu_func_nsl_thold_4        => pc_iu_func_nsl_thold_4,
      pc_iu_func_slp_nsl_thold_4    => pc_iu_func_slp_nsl_thold_4,
      pc_iu_ary_nsl_thold_4         => pc_iu_ary_nsl_thold_4,
      pc_iu_ary_slp_nsl_thold_4     => pc_iu_ary_slp_nsl_thold_4,
      pc_iu_sg_4                    => pc_iu_sg_4,
      pc_iu_fce_4                   => pc_iu_fce_4,
      pc_iu_init_reset              => pc_iu_init_reset,
      pc_iu_inj_icache_parity       => pc_iu_inj_icache_parity,
      pc_iu_inj_icachedir_multihit  => pc_iu_inj_icachedir_multihit,
      pc_iu_inj_icachedir_parity    => pc_iu_inj_icachedir_parity,
      pc_iu_ram_force_cmplt         => pc_iu_ram_force_cmplt,
      pc_iu_ram_instr               => pc_iu_ram_instr,
      pc_iu_ram_instr_ext           => pc_iu_ram_instr_ext,
      pc_iu_ram_mode                => pc_iu_ram_mode,
      pc_iu_ram_thread              => pc_iu_ram_thread,
      pc_iu_trace_bus_enable        => pc_iu_trace_bus_enable,
      tc_ac_ccflush_dc              => pc_iu_ccflush_dc,
      an_ac_lbist_en_dc             => an_ac_lbist_en_dc_omm,
      an_ac_atpg_en_dc              => an_ac_atpg_en_dc_omm,
      an_ac_scan_dis_dc_b           => an_ac_scan_dis_dc_b_omm,
      xu_iu_complete_qentry         => xu_iu_complete_qentry,
      xu_iu_complete_target_type    => xu_iu_complete_target_type,
      xu_iu_complete_tid            => xu_iu_complete_tid,
      xu_iu_ex1_ra_entry            => xu_iu_ex1_ra_entry,
      xu_iu_ex1_rb                  => xu_iu_ex1_rb,
      xu_iu_ex1_rs_is               => xu_iu_ex1_rs_is,
      xu_iu_ex5_bclr                => xu_iu_ex5_bclr,
      xu_iu_ex5_bh                  => xu_iu_ex5_bh,
      xu_iu_ex5_br_hist             => xu_iu_ex5_br_hist,
      xu_iu_ex5_br_taken            => xu_iu_ex5_br_taken,
      xu_iu_ex5_br_update           => xu_iu_ex5_br_update,
      xu_iu_ex5_getNIA              => xu_iu_ex5_getNIA,
      xu_iu_ex5_gshare              => xu_iu_ex5_gshare,
      xu_iu_ex5_ifar                => xu_iu_ex5_ifar,
      xu_iu_ex5_lk                  => xu_iu_ex5_lk,
      xu_iu_ex5_ppc_cpl             => xu_iu_ex5_ppc_cpl,
      xu_iu_ex4_loadmiss_qentry     => xu_iu_ex4_loadmiss_qentry,
      xu_iu_ex4_loadmiss_target     => xu_iu_ex4_loadmiss_target,
      xu_iu_ex4_loadmiss_target_type=> xu_iu_ex4_loadmiss_target_type,
      xu_iu_ex4_loadmiss_tid        => xu_iu_ex4_loadmiss_tid,
      xu_iu_ex4_rs_data             => xu_iu_ex4_rs_data,
      xu_iu_ex5_tid                 => xu_iu_ex5_tid,
      xu_iu_ex5_val                 => xu_iu_ex5_val,
      xu_iu_ex5_loadmiss_qentry     => xu_iu_ex5_loadmiss_qentry,
      xu_iu_ex5_loadmiss_target     => xu_iu_ex5_loadmiss_target,
      xu_iu_ex5_loadmiss_target_type=> xu_iu_ex5_loadmiss_target_type,
      xu_iu_ex5_loadmiss_tid        => xu_iu_ex5_loadmiss_tid,
      xu_iu_ex6_icbi_val            => xu_iu_ex6_icbi_val,
      xu_iu_ex6_icbi_addr           => xu_iu_ex6_icbi_addr,
      xu_iu_ex6_pri                 => xu_iu_ex6_pri,
      xu_iu_ex6_pri_val             => xu_iu_ex6_pri_val,
      xu_iu_flush_2ucode            => xu_iu_flush_2ucode,
      xu_iu_flush_2ucode_type       => xu_iu_flush_2ucode_type,
      xu_iu_hid_mmu_mode            => xu_iu_hid_mmu_mode,
      xu_iu_xucr0_rel               => xu_iu_xucr0_rel,
      xu_iu_ici                     => xu_iu_ici,
      xu_iu_iu0_flush_ifar0         => xu_iu_iu0_flush_ifar0,
      xu_iu_iu0_flush_ifar1         => xu_iu_iu0_flush_ifar1,
      xu_iu_iu0_flush_ifar2         => xu_iu_iu0_flush_ifar2,
      xu_iu_iu0_flush_ifar3         => xu_iu_iu0_flush_ifar3,
      xu_iu_larx_done_tid           => xu_iu_larx_done_tid,
      xu_iu_membar_tid              => xu_iu_membar_tid,
      xu_iu_msr_cm                  => xu_iu_msr_cm,
      xu_iu_msr_gs                  => xu_iu_msr_gs,
      xu_iu_msr_hv                  => xu_iu_msr_hv,
      xu_iu_msr_is                  => xu_iu_msr_is,
      xu_iu_msr_pr                  => xu_iu_msr_pr,
      xu_iu_multdiv_done            => xu_iu_multdiv_done,
      xu_iu_need_hole               => xu_iu_need_hole,
      xu_iu_raise_iss_pri           => xu_iu_raise_iss_pri,
      xu_iu_ram_issue               => xu_iu_ram_issue,
      xu_iu_ex1_is_csync            => xu_iu_ex1_is_csync,
      xu_iu_ex1_is_isync            => xu_iu_ex1_is_isync,
      xu_iu_rf1_is_eratilx          => xu_iu_rf1_is_eratilx,
      xu_iu_rf1_is_eratre           => xu_iu_rf1_is_eratre,
      xu_iu_rf1_is_eratsx           => xu_iu_rf1_is_eratsx,
      xu_iu_rf1_is_eratwe           => xu_iu_rf1_is_eratwe,
      xu_iu_rf1_val                 => xu_iu_rf1_val,
      xu_iu_rf1_ws                  => xu_iu_rf1_ws,
      xu_iu_rf1_t                   => xu_iu_rf1_t,
      xu_iu_run_thread              => xu_iu_run_thread,
      xu_iu_set_barr_tid            => xu_iu_set_barr_tid,
      xu_iu_single_instr_mode       => xu_iu_single_instr_mode,
      xu_iu_slowspr_done            => xu_iu_slowspr_done,
      xu_iu_spr_ccr2_en_dcr         => xu_iu_spr_ccr2_en_dcr,
      xu_iu_spr_ccr2_ifratsc        => xu_iu_spr_ccr2_ifratsc,
      xu_iu_spr_ccr2_ifrat          => xu_iu_spr_ccr2_ifrat,
      xu_iu_spr_xer0                => xu_iu_spr_xer0,
      xu_iu_spr_xer1                => xu_iu_spr_xer1,
      xu_iu_spr_xer2                => xu_iu_spr_xer2,
      xu_iu_spr_xer3                => xu_iu_spr_xer3,
      xu_iu_uc_flush_ifar0          => xu_iu_uc_flush_ifar0,
      xu_iu_uc_flush_ifar1          => xu_iu_uc_flush_ifar1,
      xu_iu_uc_flush_ifar2          => xu_iu_uc_flush_ifar2,
      xu_iu_uc_flush_ifar3          => xu_iu_uc_flush_ifar3,
      xu_iu_ucode_restart           => xu_iu_ucode_restart,
      abst_scan_out(0 to 1)         => ac_an_abst_scan_out_imm_iu(0 to 1),
      abst_scan_out(2)              => iu_pc_abst_scan_out,
      bcfg_scan_out                 => iu_fu_bcfg_scan_out,
      ccfg_scan_out                 => iu_pc_ccfg_scan_out,
      dcfg_scan_out                 => iu_fu_dcfg_scan_out,
      func_scan_out		    => ac_an_func_scan_out_imm_iua(6 to 19),
      gptr_scan_out                 => iu_pc_gptr_scan_out,
      repr_scan_out                 => iu_fu_repr_scan_out,
      time_scan_out                 => iu_fu_time_scan_out,
      regf_scan_out                 => ac_an_regf_scan_out_imm(0 to 4),
      debug_data_out                => iu_xu_debug_data,   
      trace_triggers_out            => iu_xu_trigger_data,  
      iu_fu_ex2_n_flush             => iu_fu_ex2_n_flush,
      iu_fu_is2_tid_decode          => iu_fu_is2_tid_decode,
      iu_fu_rf0_bypsel              => iu_fu_rf0_bypsel,
      iu_fu_rf0_fra                 => iu_fu_rf0_fra,
      iu_fu_rf0_fra_v               => iu_fu_rf0_fra_v,
      iu_fu_rf0_frb                 => iu_fu_rf0_frb,
      iu_fu_rf0_frb_v               => iu_fu_rf0_frb_v,
      iu_fu_rf0_frc                 => iu_fu_rf0_frc,
      iu_fu_rf0_frc_v               => iu_fu_rf0_frc_v,
      iu_fu_rf0_frt                 => iu_fu_rf0_frt,
      iu_fu_rf0_ifar                => iu_fu_rf0_ifar,
      iu_fu_rf0_instr               => iu_fu_rf0_instr,
      iu_fu_rf0_instr_match         => iu_fu_rf0_instr_match,
      iu_fu_rf0_instr_v             => iu_fu_rf0_instr_v,
      iu_fu_rf0_is_ucode            => iu_fu_rf0_is_ucode,
      iu_fu_rf0_ucfmul              => iu_fu_rf0_ucfmul,
      iu_fu_rf0_ldst_val            => iu_fu_rf0_ldst_val,
      iu_fu_rf0_ldst_tid            => iu_fu_rf0_ldst_tid,
      iu_fu_rf0_ldst_tag            => iu_fu_rf0_ldst_tag,
      iu_fu_rf0_str_val             => iu_fu_rf0_str_val,
      iu_fu_rf0_tid                 => iu_fu_rf0_tid,
      iu_mm_ierat_epn               => iu_mm_ierat_epn,
      iu_mm_ierat_flush             => iu_mm_ierat_flush,
      iu_mm_ierat_mmucr0            => iu_mm_ierat_mmucr0,
      iu_mm_ierat_mmucr0_we         => iu_mm_ierat_mmucr0_we,
      iu_mm_ierat_mmucr1            => iu_mm_ierat_mmucr1,
      iu_mm_ierat_mmucr1_we         => iu_mm_ierat_mmucr1_we,
      iu_mm_ierat_req               => iu_mm_ierat_req,
      iu_mm_ierat_snoop_ack         => iu_mm_ierat_snoop_ack,
      iu_mm_ierat_thdid             => iu_mm_ierat_thdid,
      iu_mm_ierat_tid               => iu_mm_ierat_tid,
      iu_mm_ierat_state             => iu_mm_ierat_state,
      iu_mm_lmq_empty               => iu_mm_lmq_empty,
      mm_iu_barrier_done            => mm_iu_barrier_done,
      iu_pc_bo_fail                 => iu_pc_bo_fail,
      iu_pc_bo_diagout              => iu_pc_bo_diagout,
      iu_pc_err_icache_parity       => iu_pc_err_icache_parity,
      iu_pc_err_icachedir_multihit  => iu_pc_err_icachedir_multihit,
      iu_pc_err_icachedir_parity    => iu_pc_err_icachedir_parity,
      iu_pc_err_ucode_illegal       => iu_pc_err_ucode_illegal,
      iu_pc_event_data              => iu_pc_event_data,
      slowspr_addr_out              => iu_pc_slowspr_addr,
      slowspr_data_out              => iu_pc_slowspr_data,
      slowspr_done_out              => iu_pc_slowspr_done,
      slowspr_etid_out              => iu_pc_slowspr_etid,
      slowspr_rw_out                => iu_pc_slowspr_rw,
      slowspr_val_out               => iu_pc_slowspr_val,
      iu_xu_ex4_tlb_data            => iu_xu_ex4_tlb_data,
      iu_xu_ierat_ex2_flush_req     => iu_xu_ierat_ex2_flush_req,
      iu_xu_ierat_ex3_par_err       => iu_xu_ierat_ex3_par_err,
      iu_xu_ierat_ex4_par_err       => iu_xu_ierat_ex4_par_err,
      iu_xu_is2_axu_instr_type      => iu_xu_is2_axu_instr_type,
      iu_xu_is2_axu_ld_or_st        => iu_xu_is2_axu_ld_or_st,
      iu_xu_is2_axu_ldst_extpid     => iu_xu_is2_axu_ldst_extpid,
      iu_xu_is2_axu_ldst_forcealign => iu_xu_is2_axu_ldst_forcealign,
      iu_xu_is2_axu_ldst_forceexcept => iu_xu_is2_axu_ldst_forceexcept,
      iu_xu_is2_axu_ldst_indexed    => iu_xu_is2_axu_ldst_indexed,
      iu_xu_is2_axu_ldst_size       => iu_xu_is2_axu_ldst_size,
      iu_xu_is2_axu_ldst_tag        => iu_xu_is2_axu_ldst_tag,
      iu_xu_is2_axu_ldst_update     => iu_xu_is2_axu_ldst_update,
      iu_xu_is2_axu_mffgpr          => iu_xu_is2_axu_mffgpr,
      iu_xu_is2_axu_mftgpr          => iu_xu_is2_axu_mftgpr,
      iu_xu_is2_axu_movedp          => iu_xu_is2_axu_movedp,
      iu_xu_is2_axu_store           => iu_xu_is2_axu_store,
      iu_xu_is2_error               => iu_xu_is2_error,
      iu_xu_is2_gshare              => iu_xu_is2_gshare,
      iu_xu_is2_ifar                => iu_xu_is2_ifar,
      iu_xu_is2_instr               => iu_xu_is2_instr,
      iu_xu_is2_is_ucode            => iu_xu_is2_is_ucode,
      iu_xu_is2_match               => iu_xu_is2_match,
      iu_xu_is2_pred_taken_cnt      => iu_xu_is2_pred_taken_cnt,
      iu_xu_is2_pred_update         => iu_xu_is2_pred_update,
      iu_xu_is2_s1                  => iu_xu_is2_s1,
      iu_xu_is2_s1_vld              => iu_xu_is2_s1_vld,
      iu_xu_is2_s2                  => iu_xu_is2_s2,
      iu_xu_is2_s2_vld              => iu_xu_is2_s2_vld,
      iu_xu_is2_s3                  => iu_xu_is2_s3,
      iu_xu_is2_s3_vld              => iu_xu_is2_s3_vld,
      iu_xu_is2_ta                  => iu_xu_is2_ta,
      iu_xu_is2_ta_vld              => iu_xu_is2_ta_vld,
      iu_xu_is2_tid                 => iu_xu_is2_tid,
      iu_xu_is2_ucode_vld           => iu_xu_is2_ucode_vld,
      iu_xu_is2_vld                 => iu_xu_is2_vld,
      iu_xu_quiesce                 => iu_xu_quiesce,
      iu_xu_ra                      => iu_xu_ra,
      iu_xu_request                 => iu_xu_request,
      iu_xu_thread                  => iu_xu_thread,
      iu_xu_userdef                 => iu_xu_userdef,
      iu_xu_wimge                   => iu_xu_wimge,

      rtim_sl_thold_7               => an_ac_rtim_sl_thold_7_omm,         
      func_sl_thold_7               => an_ac_func_sl_thold_7_omm,         
      func_nsl_thold_7              => an_ac_func_nsl_thold_7_omm,        
      ary_nsl_thold_7               => an_ac_ary_nsl_thold_7_omm,         
      sg_7                          => an_ac_sg_7_omm,                    
      fce_7                         => an_ac_fce_7_omm,                   
      rtim_sl_thold_6               => rp_pc_rtim_sl_thold_6,           
      func_sl_thold_6               => rp_pc_func_sl_thold_6,           
      func_nsl_thold_6              => rp_pc_func_nsl_thold_6,         
      ary_nsl_thold_6               => rp_pc_ary_nsl_thold_6,           
      sg_6                          => rp_pc_sg_6,                                 
      fce_6                         => rp_pc_fce_6,                               
      an_ac_scom_dch                => an_ac_scom_dch_omm, 
      an_ac_scom_cch                => an_ac_scom_cch_omm, 
      an_ac_checkstop               => an_ac_checkstop_omm,        
      an_ac_debug_stop              => an_ac_debug_stop_omm,       
      an_ac_pm_thread_stop          => an_ac_pm_thread_stop_omm,   
      an_ac_reset_1_complete        => an_ac_reset_1_complete_omm, 
      an_ac_reset_2_complete        => an_ac_reset_2_complete_omm,
      an_ac_reset_3_complete        => an_ac_reset_3_complete_omm,
      an_ac_reset_wd_complete       => an_ac_reset_wd_complete_omm,
      an_ac_abist_start_test        => an_ac_abist_start_test_omm,  
      ac_rp_trace_to_perfcntr       => ac_rp_trace_to_perfcntr,
      rp_pc_scom_dch_q              => rp_pc_scom_dch_q,
      rp_pc_scom_cch_q              => rp_pc_scom_cch_q,
      rp_pc_checkstop_q             => rp_pc_checkstop_q,
      rp_pc_debug_stop_q            => rp_pc_debug_stop_q,
      rp_pc_pm_thread_stop_q        => rp_pc_pm_thread_stop_q,    
      rp_pc_reset_1_complete_q      => rp_pc_reset_1_complete_q,
      rp_pc_reset_2_complete_q      => rp_pc_reset_2_complete_q,
      rp_pc_reset_3_complete_q      => rp_pc_reset_3_complete_q,
      rp_pc_reset_wd_complete_q     => rp_pc_reset_wd_complete_q,
      rp_pc_abist_start_test_q      => rp_pc_abist_start_test_q,
      rp_pc_trace_to_perfcntr_q     => rp_pc_trace_to_perfcntr_q,
      pc_rp_scom_dch                => pc_rp_scom_dch,
      pc_rp_scom_cch                => pc_rp_scom_cch,
      pc_rp_special_attn            => pc_rp_special_attn,
      pc_rp_checkstop               => pc_rp_checkstop,
      pc_rp_local_checkstop         => pc_rp_local_checkstop,
      pc_rp_recov_err               => pc_rp_recov_err,
      pc_rp_trace_error             => pc_rp_trace_error,
      pc_rp_event_bus_enable        => pc_rp_event_bus_enable,
      pc_rp_event_bus               => pc_rp_event_bus,
      pc_rp_fu_bypass_events        => pc_rp_fu_bypass_events,
      pc_rp_iu_bypass_events        => pc_rp_iu_bypass_events,
      pc_rp_mm_bypass_events        => pc_rp_mm_bypass_events,
      pc_rp_lsu_bypass_events       => pc_rp_lsu_bypass_events,
      pc_rp_pm_thread_running       => pc_rp_pm_thread_running,
      pc_rp_power_managed           => pc_rp_power_managed,
      pc_rp_rvwinkle_mode           => pc_rp_rvwinkle_mode,
      ac_an_scom_dch_q              => ac_an_scom_dch_imm,         
      ac_an_scom_cch_q              => ac_an_scom_cch_imm,
      ac_an_special_attn_q          => ac_an_special_attn_imm,     
      ac_an_checkstop_q             => ac_an_checkstop_imm,        
      ac_an_local_checkstop_q       => ac_an_local_checkstop_imm,  
      ac_an_recov_err_q             => ac_an_recov_err_imm,       
      ac_an_trace_error_q           => ac_an_trace_error_imm,
      rp_mm_event_bus_enable_q      => rp_mm_event_bus_enable_q,
      ac_an_event_bus_q             => ac_an_event_bus_imm,        
      ac_an_fu_bypass_events_q      => ac_an_fu_bypass_events_imm, 
      ac_an_iu_bypass_events_q      => ac_an_iu_bypass_events_imm, 
      ac_an_mm_bypass_events_q      => ac_an_mm_bypass_events_imm, 
      ac_an_lsu_bypass_events_q     => ac_an_lsu_bypass_events_imm, 
      ac_an_pm_thread_running_q     => ac_an_pm_thread_running_imm,
      ac_an_power_managed_q         => ac_an_power_managed_int,    
      ac_an_rvwinkle_mode_q         => ac_an_rvwinkle_mode_imm,

      pc_func_scan_in               => an_ac_func_scan_in_omm_iua(0 to 1),    
      pc_func_scan_in_q             => rp_pc_func_scan_in_q(0 to 1),
      pc_func_scan_out              => pc_rp_func_scan_out(1),   
      pc_func_scan_out_q            => ac_an_func_scan_out_imm_iua(1),
      pc_bcfg_scan_in               => mm_rp_bcfg_scan_out,    
      pc_bcfg_scan_in_q             => rp_pc_bcfg_scan_out_q,
      pc_dcfg_scan_in               => mm_rp_dcfg_scan_out,    
      pc_dcfg_scan_in_q             => rp_pc_dcfg_scan_out_q,
      pc_bcfg_scan_out              => pc_rp_bcfg_scan_out,
      pc_bcfg_scan_out_q            => ac_an_bcfg_scan_out_imm(2),
      pc_ccfg_scan_out              => pc_rp_ccfg_scan_out,
      pc_ccfg_scan_out_q            => ac_an_bcfg_scan_out_imm(0),
      pc_dcfg_scan_out              => pc_rp_dcfg_scan_out,
      pc_dcfg_scan_out_q            => ac_an_dcfg_scan_out_imm(0),
      fu_abst_scan_in               => an_ac_abst_scan_in_omm_iu(3),    
      fu_abst_scan_in_q             => rp_fu_abst_scan_in_q,  
      fu_abst_scan_out              => fu_rp_abst_scan_out,
      fu_abst_scan_out_q            => ac_an_abst_scan_out_imm_iu(3),
      fu_bcfg_scan_out              => fu_rp_bcfg_scan_out,
      fu_bcfg_scan_out_q            => ac_an_bcfg_scan_out_imm(3),
      fu_ccfg_scan_out              => fu_rp_ccfg_scan_out,
      fu_ccfg_scan_out_q            => ac_an_bcfg_scan_out_imm(1),
      fu_dcfg_scan_out              => fu_rp_dcfg_scan_out,
      fu_dcfg_scan_out_q            => ac_an_dcfg_scan_out_imm(1),
      fu_func_scan_in               => an_ac_func_scan_in_omm_iua(2 to 5),     
      fu_func_scan_in_q             => rp_fu_func_scan_in_q(0 to 3),  
      fu_func_scan_out              => fu_rp_func_scan_out(0 to 3),    
      fu_func_scan_out_q            => ac_an_func_scan_out_imm_iua(2 to 5), 
      bx_abst_scan_in               => an_ac_abst_scan_in_omm_iu(4),    
      bx_abst_scan_in_q             => rp_bx_abst_scan_in_q,  
      bx_abst_scan_out              => bx_rp_abst_scan_out,   
      bx_abst_scan_out_q            => ac_an_abst_scan_out_imm_iu(4), 
      bx_func_scan_in               => an_ac_func_scan_in_omm_iua(20 to 21),    
      bx_func_scan_in_q             => rp_bx_func_scan_in_q(0 to 1),  
      bx_func_scan_out              => bx_rp_func_scan_out(0 to 1),   
      bx_func_scan_out_q            => ac_an_func_scan_out_imm_iua(20 to 21),
      spare_func_scan_in            => an_ac_func_scan_in_omm_iub(60 to 63),
      spare_func_scan_out_q         => ac_an_func_scan_out_imm_iub(60 to 63),
      rp_abst_scan_in           => pc_rp_abst_scan_out,     
      rp_func_scan_in           => pc_rp_func_scan_out(0),  
      rp_abst_scan_out          => ac_an_abst_scan_out_imm_iu(2),  
      rp_func_scan_out          => ac_an_func_scan_out_imm_iua(0),  
      
      an_ac_abist_mode_dc_iiu         => an_ac_abist_mode_dc_omm,
      an_ac_ccflush_dc_iiu            => an_ac_ccflush_dc_omm,
      an_ac_gsd_test_enable_dc_iiu    => an_ac_gsd_test_enable_dc_omm,
      an_ac_gsd_test_acmode_dc_iiu    => an_ac_gsd_test_acmode_dc_omm,
      an_ac_lbist_ip_dc_iiu           => an_ac_lbist_ip_dc_omm,	 
      an_ac_lbist_ac_mode_dc_iiu      => an_ac_lbist_ac_mode_dc_omm, 
      an_ac_malf_alert_iiu            => an_ac_malf_alert_omm,	 
      an_ac_psro_enable_dc_iiu        => an_ac_psro_enable_dc_omm,	 
      an_ac_scan_type_dc_iiu          => an_ac_scan_type_dc_omm, 
      an_ac_scom_sat_id_iiu           => an_ac_scom_sat_id_omm,	 

      an_ac_abist_mode_dc_oiu         => an_ac_abist_mode_dc_oiu,
      an_ac_ccflush_dc_oiu            => an_ac_ccflush_dc_oiu,
      an_ac_gsd_test_enable_dc_oiu    => an_ac_gsd_test_enable_dc_oiu,
      an_ac_gsd_test_acmode_dc_oiu    => an_ac_gsd_test_acmode_dc_oiu,
      an_ac_lbist_ip_dc_oiu           => an_ac_lbist_ip_dc_oiu,	  
      an_ac_lbist_ac_mode_dc_oiu      => an_ac_lbist_ac_mode_dc_oiu,
      an_ac_malf_alert_oiu            => an_ac_malf_alert_oiu,	  
      an_ac_psro_enable_dc_oiu        => an_ac_psro_enable_dc_oiu,    
      an_ac_scan_type_dc_oiu          => an_ac_scan_type_dc_oiu,	  
      an_ac_scom_sat_id_oiu           => an_ac_scom_sat_id_oiu,	  

      an_ac_back_inv_oiu              => an_ac_back_inv_oiu,
      an_ac_back_inv_addr_oiu         => an_ac_back_inv_addr_oiu,
      an_ac_back_inv_target_bit1_oiu  => an_ac_back_inv_target_bit1_oiu,
      an_ac_back_inv_target_bit3_oiu  => an_ac_back_inv_target_bit3_oiu,
      an_ac_back_inv_target_bit4_oiu  => an_ac_back_inv_target_bit4_oiu,
      an_ac_atpg_en_dc_oiu            => an_ac_atpg_en_dc_oiu,
      an_ac_lbist_ary_wrt_thru_dc_oiu => an_ac_lbist_ary_wrt_thru_dc_oiu,
      an_ac_lbist_en_dc_oiu           => an_ac_lbist_en_dc_oiu,
      an_ac_scan_diag_dc_oiu          => an_ac_scan_diag_dc_oiu,
      an_ac_scan_dis_dc_b_oiu         => an_ac_scan_dis_dc_b_oiu,


      
      ac_an_abist_done_dc_iiu         => ac_an_abist_done_dc_iiu,
      ac_an_psro_ringsig_iiu          => ac_an_psro_ringsig_iiu, 
      an_ac_ccenable_dc_iiu           => an_ac_ccenable_dc_iiu,
      mm_pc_bo_fail_iiu               => mm_pc_bo_fail_iiu,      
      mm_pc_bo_diagout_iiu            => mm_pc_bo_diagout_iiu,   
      mm_pc_event_data_iiu            => mm_pc_event_data_iiu,   
      
      ac_an_abist_done_dc_oiu         => ac_an_abist_done_dc_oiu,
      ac_an_psro_ringsig_oiu          => ac_an_psro_ringsig_oiu, 
      an_ac_ccenable_dc_oiu           => an_ac_ccenable_dc_oiu,
      mm_pc_bo_fail_oiu               => mm_pc_bo_fail_oiu,	
      mm_pc_bo_diagout_oiu            => mm_pc_bo_diagout_oiu,	
      mm_pc_event_data_oiu            => mm_pc_event_data_oiu,	

      pc_mm_abist_dcomp_g6t_2r_iiu     => pc_mm_abist_dcomp_g6t_2r_iiu,  
      pc_mm_abist_di_g6t_2r_iiu        => pc_mm_abist_di_g6t_2r_iiu,     
      pc_mm_abist_di_0_iiu             => pc_mm_abist_di_0_iiu,	      
      pc_mm_abist_ena_dc_iiu           => pc_mm_abist_ena_dc_iiu,        
      pc_mm_abist_g6t_r_wb_iiu         => pc_mm_abist_g6t_r_wb_iiu,      
      pc_mm_abist_g8t_bw_0_iiu         => pc_mm_abist_g8t_bw_0_iiu,      
      pc_mm_abist_g8t_bw_1_iiu         => pc_mm_abist_g8t_bw_1_iiu,      
      pc_mm_abist_g8t_dcomp_iiu        => pc_mm_abist_g8t_dcomp_iiu,     
      pc_mm_abist_g8t_wenb_iiu         => pc_mm_abist_g8t_wenb_iiu,      
      pc_mm_abist_g8t1p_renb_0_iiu     => pc_mm_abist_g8t1p_renb_0_iiu,  
      pc_mm_abist_raddr_0_iiu          => pc_mm_abist_raddr_0_iiu,       
      pc_mm_abist_raw_dc_b_iiu         => pc_mm_abist_raw_dc_b_iiu,      
      pc_mm_abist_waddr_0_iiu          => pc_mm_abist_waddr_0_iiu,       
      pc_mm_abist_wl128_comp_ena_iiu   => pc_mm_abist_wl128_comp_ena_iiu,
      pc_mm_bo_enable_4_iiu            => pc_mm_bo_enable_4_iiu,	      
      pc_mm_bo_repair_iiu              => pc_mm_bo_repair_iiu,	      
      pc_mm_bo_reset_iiu               => pc_mm_bo_reset_iiu,	      
      pc_mm_bo_select_iiu              => pc_mm_bo_select_iiu,	      
      pc_mm_bo_shdata_iiu              => pc_mm_bo_shdata_iiu,	      
      pc_mm_bo_unload_iiu              => pc_mm_bo_unload_iiu,	      
      pc_mm_ccflush_dc_iiu             => pc_mm_ccflush_dc_iiu,	      
      pc_mm_debug_mux1_ctrls_iiu       => pc_mm_debug_mux1_ctrls_iiu,    
      pc_mm_event_count_mode_iiu       => pc_mm_event_count_mode_iiu,    
      pc_mm_event_mux_ctrls_iiu        => pc_mm_event_mux_ctrls_iiu,     
      pc_mm_trace_bus_enable_iiu       => pc_mm_trace_bus_enable_iiu,    
      pc_mm_abist_dcomp_g6t_2r_oiu     => pc_mm_abist_dcomp_g6t_2r_oiu,  
      pc_mm_abist_di_g6t_2r_oiu        => pc_mm_abist_di_g6t_2r_oiu,     
      pc_mm_abist_di_0_oiu             => pc_mm_abist_di_0_oiu,	      
      pc_mm_abist_ena_dc_oiu           => pc_mm_abist_ena_dc_oiu,        
      pc_mm_abist_g6t_r_wb_oiu         => pc_mm_abist_g6t_r_wb_oiu,      
      pc_mm_abist_g8t_bw_0_oiu         => pc_mm_abist_g8t_bw_0_oiu,      
      pc_mm_abist_g8t_bw_1_oiu         => pc_mm_abist_g8t_bw_1_oiu,      
      pc_mm_abist_g8t_dcomp_oiu        => pc_mm_abist_g8t_dcomp_oiu,     
      pc_mm_abist_g8t_wenb_oiu         => pc_mm_abist_g8t_wenb_oiu,      
      pc_mm_abist_g8t1p_renb_0_oiu     => pc_mm_abist_g8t1p_renb_0_oiu,  
      pc_mm_abist_raddr_0_oiu          => pc_mm_abist_raddr_0_oiu,       
      pc_mm_abist_raw_dc_b_oiu         => pc_mm_abist_raw_dc_b_oiu,      
      pc_mm_abist_waddr_0_oiu          => pc_mm_abist_waddr_0_oiu,       
      pc_mm_abist_wl128_comp_ena_oiu   => pc_mm_abist_wl128_comp_ena_oiu,
      pc_mm_abst_sl_thold_3_oiu        => pc_mm_abst_sl_thold_3_oiu,     
      pc_mm_abst_slp_sl_thold_3_oiu    => pc_mm_abst_slp_sl_thold_3_oiu, 
      pc_mm_ary_nsl_thold_3_oiu        => pc_mm_ary_nsl_thold_3_oiu,     
      pc_mm_ary_slp_nsl_thold_3_oiu    => pc_mm_ary_slp_nsl_thold_3_oiu, 
      pc_mm_bo_enable_3_oiu            => pc_mm_bo_enable_3_oiu,	      
      pc_mm_bo_repair_oiu              => pc_mm_bo_repair_oiu,	      
      pc_mm_bo_reset_oiu               => pc_mm_bo_reset_oiu,	      
      pc_mm_bo_select_oiu              => pc_mm_bo_select_oiu,	      
      pc_mm_bo_shdata_oiu              => pc_mm_bo_shdata_oiu,	      
      pc_mm_bo_unload_oiu              => pc_mm_bo_unload_oiu,	      
      pc_mm_bolt_sl_thold_3_oiu        => pc_mm_bolt_sl_thold_3_oiu,     
      pc_mm_ccflush_dc_oiu             => pc_mm_ccflush_dc_oiu,	      
      pc_mm_cfg_sl_thold_3_oiu         => pc_mm_cfg_sl_thold_3_oiu,      
      pc_mm_cfg_slp_sl_thold_3_oiu     => pc_mm_cfg_slp_sl_thold_3_oiu,  
      pc_mm_debug_mux1_ctrls_oiu       => pc_mm_debug_mux1_ctrls_oiu,    
      pc_mm_event_count_mode_oiu       => pc_mm_event_count_mode_oiu,    
      pc_mm_event_mux_ctrls_oiu        => pc_mm_event_mux_ctrls_oiu,     
      pc_mm_fce_3_oiu                  => pc_mm_fce_3_oiu, 	      
      pc_mm_func_nsl_thold_3_oiu       => pc_mm_func_nsl_thold_3_oiu,    
      pc_mm_func_sl_thold_3_oiu        => pc_mm_func_sl_thold_3_oiu,     
      pc_mm_func_slp_nsl_thold_3_oiu   => pc_mm_func_slp_nsl_thold_3_oiu,
      pc_mm_func_slp_sl_thold_3_oiu    => pc_mm_func_slp_sl_thold_3_oiu, 
      pc_mm_gptr_sl_thold_3_oiu        => pc_mm_gptr_sl_thold_3_oiu,     
      pc_mm_repr_sl_thold_3_oiu        => pc_mm_repr_sl_thold_3_oiu,     
      pc_mm_sg_3_oiu                   => pc_mm_sg_3_oiu,  	      
      pc_mm_time_sl_thold_3_oiu        => pc_mm_time_sl_thold_3_oiu,    
      pc_mm_trace_bus_enable_oiu       => pc_mm_trace_bus_enable_oiu,    

      xu_wu_rf1_flush               => xu_wu_rf1_flush,    
      xu_wu_ex1_flush               => xu_wu_ex1_flush,    
      xu_wu_ex2_flush               => xu_wu_ex2_flush,    
      xu_wu_ex3_flush               => xu_wu_ex3_flush,    
      xu_wu_ex4_flush               => xu_wu_ex4_flush,    
      xu_wu_ex5_flush               => xu_wu_ex5_flush,    
      xu_wl_rf1_flush               => xu_wl_rf1_flush,    
      xu_wl_ex1_flush               => xu_wl_ex1_flush,    
      xu_wl_ex2_flush               => xu_wl_ex2_flush,    
      xu_wl_ex3_flush               => xu_wl_ex3_flush,    
      xu_wl_ex4_flush               => xu_wl_ex4_flush,    
      xu_wl_ex5_flush               => xu_wl_ex5_flush,    
      xu_iu_l_flush                 => xu_iu_l_flush,
      xu_iu_u_flush                 => xu_iu_u_flush,
      
      an_ac_grffence_en_dc_oiu      => an_ac_grffence_en_dc_oiu,
      
     bg_an_ac_func_scan_sn            => bg_an_ac_func_scan_sn_omm,	     
     bg_an_ac_abst_scan_sn            => bg_an_ac_abst_scan_sn_omm,	     
     bg_an_ac_func_scan_sn_q          => bg_an_ac_func_scan_sn_q,	     
     bg_an_ac_abst_scan_sn_q          => bg_an_ac_abst_scan_sn_q,	     
 
     bg_ac_an_func_scan_ns            => "0000000000",                      
     bg_ac_an_abst_scan_ns            => "00",                          
     bg_ac_an_func_scan_ns_q          => bg_ac_an_func_scan_ns_q,	     
     bg_ac_an_abst_scan_ns_q          => bg_ac_an_abst_scan_ns_q,	     

     bg_pc_l1p_abist_di_0             => "0000",                        
     bg_pc_l1p_abist_g8t1p_renb_0     => '0',	     	                
     bg_pc_l1p_abist_g8t_bw_0         => '0',	     	                
     bg_pc_l1p_abist_g8t_bw_1         => '0',	     	                
     bg_pc_l1p_abist_g8t_dcomp        => "0000",     	                
     bg_pc_l1p_abist_g8t_wenb         => '0',	     	                
     bg_pc_l1p_abist_raddr_0          => "0000000000",	                
     bg_pc_l1p_abist_waddr_0          => "0000000000",	                
     bg_pc_l1p_abist_wl128_comp_ena   => '0',	     	                
     bg_pc_l1p_abist_wl32_comp_ena    => '0',	     	                
     bg_pc_l1p_abist_di_0_q           => bg_pc_l1p_abist_di_0_q,	     
     bg_pc_l1p_abist_g8t1p_renb_0_q   => bg_pc_l1p_abist_g8t1p_renb_0_q,  
     bg_pc_l1p_abist_g8t_bw_0_q       => bg_pc_l1p_abist_g8t_bw_0_q,      
     bg_pc_l1p_abist_g8t_bw_1_q       => bg_pc_l1p_abist_g8t_bw_1_q,      
     bg_pc_l1p_abist_g8t_dcomp_q      => bg_pc_l1p_abist_g8t_dcomp_q,     
     bg_pc_l1p_abist_g8t_wenb_q       => bg_pc_l1p_abist_g8t_wenb_q,      
     bg_pc_l1p_abist_raddr_0_q        => bg_pc_l1p_abist_raddr_0_q,       
     bg_pc_l1p_abist_waddr_0_q        => bg_pc_l1p_abist_waddr_0_q,       
     bg_pc_l1p_abist_wl128_comp_ena_q => bg_pc_l1p_abist_wl128_comp_ena_q,
     bg_pc_l1p_abist_wl32_comp_ena_q  => bg_pc_l1p_abist_wl32_comp_ena_q, 

     bg_pc_l1p_gptr_sl_thold_3        => bg_pc_l1p_gptr_sl_thold_3,       
     bg_pc_l1p_time_sl_thold_3        => bg_pc_l1p_time_sl_thold_3,       
     bg_pc_l1p_repr_sl_thold_3        => bg_pc_l1p_repr_sl_thold_3,       
     bg_pc_l1p_abst_sl_thold_3        => bg_pc_l1p_abst_sl_thold_3,       
     bg_pc_l1p_func_sl_thold_3        => bg_pc_l1p_func_sl_thold_3,       
     bg_pc_l1p_func_slp_sl_thold_3    => bg_pc_l1p_func_slp_sl_thold_3,   
     bg_pc_l1p_bolt_sl_thold_3        => bg_pc_l1p_bolt_sl_thold_3,       
     bg_pc_l1p_ary_nsl_thold_3        => bg_pc_l1p_ary_nsl_thold_3,       
     bg_pc_l1p_sg_3                   => bg_pc_l1p_sg_3,		     
     bg_pc_l1p_fce_3                  => bg_pc_l1p_fce_3,		     
     bg_pc_l1p_bo_enable_3            => bg_pc_l1p_bo_enable_3,	     
     bg_pc_l1p_gptr_sl_thold_2        => bg_pc_l1p_gptr_sl_thold_2_imm,      
     bg_pc_l1p_time_sl_thold_2        => bg_pc_l1p_time_sl_thold_2_imm,       
     bg_pc_l1p_repr_sl_thold_2        => bg_pc_l1p_repr_sl_thold_2_imm,       
     bg_pc_l1p_abst_sl_thold_2        => bg_pc_l1p_abst_sl_thold_2_imm,       
     bg_pc_l1p_func_sl_thold_2        => bg_pc_l1p_func_sl_thold_2_imm,       
     bg_pc_l1p_func_slp_sl_thold_2    => bg_pc_l1p_func_slp_sl_thold_2_imm,   
     bg_pc_l1p_bolt_sl_thold_2        => bg_pc_l1p_bolt_sl_thold_2_imm,       
     bg_pc_l1p_ary_nsl_thold_2        => bg_pc_l1p_ary_nsl_thold_2_imm,       
     bg_pc_l1p_sg_2                   => bg_pc_l1p_sg_2_imm,		     
     bg_pc_l1p_fce_2                  => bg_pc_l1p_fce_2_imm,		     
     bg_pc_l1p_bo_enable_2            => bg_pc_l1p_bo_enable_2_imm,	     

     bg_pc_bo_unload_iiu            => bg_pc_bo_unload_iiu,	     
     bg_pc_bo_load_iiu              => bg_pc_bo_load_iiu,  	     
     bg_pc_bo_repair_iiu            => bg_pc_bo_repair_iiu,	     
     bg_pc_bo_reset_iiu             => bg_pc_bo_reset_iiu, 	     
     bg_pc_bo_shdata_iiu            => bg_pc_bo_shdata_iiu,	     
     bg_pc_bo_select_iiu            => bg_pc_bo_select_iiu,	     
     bg_pc_l1p_ccflush_dc_iiu       => bg_pc_l1p_ccflush_dc_iiu,	     
     bg_pc_l1p_abist_ena_dc_iiu     => bg_pc_l1p_abist_ena_dc_iiu,      
     bg_pc_l1p_abist_raw_dc_b_iiu   => bg_pc_l1p_abist_raw_dc_b_iiu,    

     bg_pc_bo_unload_oiu            => bg_pc_bo_unload_oiu,	     
     bg_pc_bo_load_oiu              => bg_pc_bo_load_oiu,  	     
     bg_pc_bo_repair_oiu            => bg_pc_bo_repair_oiu,	     
     bg_pc_bo_reset_oiu             => bg_pc_bo_reset_oiu, 	     
     bg_pc_bo_shdata_oiu            => bg_pc_bo_shdata_oiu,	     
     bg_pc_bo_select_oiu            => bg_pc_bo_select_oiu,	     
     bg_pc_l1p_ccflush_dc_oiu       => bg_pc_l1p_ccflush_dc_oiu,	 
     bg_pc_l1p_abist_ena_dc_oiu     => bg_pc_l1p_abist_ena_dc_oiu,      
     bg_pc_l1p_abist_raw_dc_b_oiu   => bg_pc_l1p_abist_raw_dc_b_oiu, 
     
     bg_pc_bo_fail_iiu              => bg_pc_bo_fail_omm,    
     bg_pc_bo_diagout_iiu           => bg_pc_bo_diagout_omm, 
     bg_pc_bo_fail_oiu              => bg_pc_bo_fail_oiu,    
     bg_pc_bo_diagout_oiu           => bg_pc_bo_diagout_oiu, 

     xu_iu_xucr4_mmu_mchk           => xu_iu_xucr4_mmu_mchk,      
     
      gnd                           => gnd,
      vcs                           => vcs,
      vdd                           => vdd
   ); 

a_xuq: entity work.xuq
   generic map(a2mode    => a2mode,
      bcfg_epn_0to15     => bcfg_epn_0to15,
      bcfg_epn_16to31    => bcfg_epn_16to31,
      bcfg_epn_32to47    => bcfg_epn_32to47,
      bcfg_epn_48to51    => bcfg_epn_48to51,
      bcfg_rpn_22to31    => bcfg_rpn_22to31,
      bcfg_rpn_32to47    => bcfg_rpn_32to47,
      bcfg_rpn_48to51    => bcfg_rpn_48to51,
      eff_ifar           => xu_eff_ifar,
      expand_type        => expand_type,
      l_endian_m         => l_endian_m,
      lmq_entries        => lmq_entries,
      real_data_add      => xu_real_data_add,
      regmode            => regmode,
      hvmode             => hvmode,
      st_data_32b_mode   => st_data_32b_mode,
      threads            => threads,
      load_credits       => load_credits,
      store_credits      => store_credits,
      spr_xucr0_init_mod => spr_xucr0_init_mod,
      dc_size            => dc_size )
   port map (
      abst_scan_in                  => an_ac_abst_scan_in_omm_xu(7 to 9),
      bcfg_scan_in                  => an_ac_bcfg_scan_in_omm_bit4,
      ccfg_scan_in                  => an_ac_bcfg_scan_in_omm_bit1,
      dcfg_scan_in                  => an_ac_dcfg_scan_in_omm(2),
      func_scan_in                  => an_ac_func_scan_in_omm_xu(31 to 58),
      gptr_scan_in                  => bx_xu_gptr_scan_out,
      repr_scan_in                  => bx_xu_repr_scan_out,
      time_scan_in                  => bx_xu_time_scan_out,
      an_ac_atpg_en_dc              => an_ac_atpg_en_dc_oiu,
      an_ac_back_inv                => an_ac_back_inv_oiu,
      an_ac_back_inv_addr           => an_ac_back_inv_addr_oiu(64-xu_real_data_add to 63),
      an_ac_back_inv_target_bit1    => an_ac_back_inv_target_bit1_oiu,
      an_ac_back_inv_target_bit3    => an_ac_back_inv_target_bit3_oiu,
      an_ac_back_inv_target_bit4    => an_ac_back_inv_target_bit4_oiu,
      an_ac_crit_interrupt          => an_ac_crit_interrupt_omm,
      an_ac_ext_interrupt           => an_ac_ext_interrupt_omm,
      an_ac_flh2l2_gate             => an_ac_flh2l2_gate_omm,
      an_ac_grffence_en_dc          => an_ac_grffence_en_dc_oiu,
      an_ac_lbist_en_dc             => an_ac_lbist_en_dc_oiu,
      an_ac_lbist_ary_wrt_thru_dc   => an_ac_lbist_ary_wrt_thru_dc_oiu,
      an_ac_perf_interrupt          => an_ac_perf_interrupt_omm,
      an_ac_reld_core_tag           => an_ac_reld_core_tag_omm(0 to 4),
      an_ac_reld_data               => an_ac_reld_data_omm,
      an_ac_reld_data_vld           => an_ac_reld_data_vld_omm,
      an_ac_reld_ecc_err            => an_ac_reld_ecc_err_omm,
      an_ac_reld_ecc_err_ue         => an_ac_reld_ecc_err_ue_omm,
      an_ac_reld_qw                 => an_ac_reld_qw_omm,
      an_ac_reld_data_coming        => an_ac_reld_data_coming_omm,
      an_ac_reld_ditc               => an_ac_reld_ditc_omm,
      an_ac_reld_crit_qw            => an_ac_reld_crit_qw_omm,
      an_ac_req_ld_pop              => an_ac_req_ld_pop_omm,
      an_ac_req_spare_ctrl_a1       => an_ac_req_spare_ctrl_a1_omm,
      an_ac_req_st_gather           => an_ac_req_st_gather_omm,
      an_ac_req_st_pop              => an_ac_req_st_pop_omm,
      an_ac_reservation_vld         => an_ac_reservation_vld_omm,
      an_ac_sleep_en                => an_ac_sleep_en_omm,
      an_ac_stcx_complete           => an_ac_stcx_complete_omm,
      an_ac_stcx_pass               => an_ac_stcx_pass_omm,
      xu_iu_stcx_complete           => xu_iu_stcx_complete,
      lsu_reld_data_vld          => lsu_reld_data_vld,
      lsu_reld_core_tag          => lsu_reld_core_tag,
      lsu_reld_qw                => lsu_reld_qw  ,
      lsu_reld_ditc              => lsu_reld_ditc,
      lsu_reld_ecc_err           => lsu_reld_ecc_err,
      lsu_reld_data              => lsu_reld_data,
      lsu_req_st_pop             => lsu_req_st_pop,
      lsu_req_st_pop_thrd        => lsu_req_st_pop_thrd,
      fu_xu_ex1_ifar0               => fu_xu_ex1_ifar,
      fu_xu_ex1_ifar1               => fu_xu_ex1_ifar,
      fu_xu_ex1_ifar2               => fu_xu_ex1_ifar,
      fu_xu_ex1_ifar3               => fu_xu_ex1_ifar,
      fu_xu_ex2_async_block         => fu_xu_ex2_async_block,
      fu_xu_ex2_ifar_val            => fu_xu_ex2_ifar_val,
      fu_xu_ex2_ifar_issued         => fu_xu_ex2_ifar_issued,
      fu_xu_ex2_store_data(0 to 63)    => fu_xu_ex2_store_data,
      fu_xu_ex2_store_data(64 to 127)  => fu_xu_ex2_store_data,
      fu_xu_ex2_store_data(128 to 191) => fu_xu_ex2_store_data,
      fu_xu_ex2_store_data(192 to 255) => fu_xu_ex2_store_data,
      fu_xu_ex2_store_data_val      => fu_xu_ex2_store_data_val,
      fu_xu_ex3_flush2ucode         => fu_xu_ex3_flush2ucode,
      fu_xu_ex2_instr_match         => fu_xu_ex2_instr_match,
      fu_xu_ex2_instr_type          => fu_xu_ex2_instr_type,
      fu_xu_ex2_is_ucode            => fu_xu_ex2_is_ucode,
      fu_xu_ex3_ap_int_req          => fu_xu_ex3_ap_int_req,
      fu_xu_ex3_n_flush             => fu_xu_ex3_n_flush,
      fu_xu_ex3_np1_flush           => fu_xu_ex3_np1_flush,
      fu_xu_ex3_regfile_err_det     => fu_xu_ex3_regfile_err_det, 
      fu_xu_ex3_trap                => fu_xu_ex3_trap,
      fu_xu_ex4_cr0                 => fu_xu_ex4_cr,
      fu_xu_ex4_cr0_bf              => fu_xu_ex4_cr_bf,
      fu_xu_ex4_cr1                 => fu_xu_ex4_cr,
      fu_xu_ex4_cr1_bf              => fu_xu_ex4_cr_bf,
      fu_xu_ex4_cr2                 => fu_xu_ex4_cr,
      fu_xu_ex4_cr2_bf              => fu_xu_ex4_cr_bf,
      fu_xu_ex4_cr3                 => fu_xu_ex4_cr,
      fu_xu_ex4_cr3_bf              => fu_xu_ex4_cr_bf,
      fu_xu_ex4_cr_noflush          => fu_xu_ex4_cr_noflush,
      fu_xu_ex4_cr_val              => fu_xu_ex4_cr_val,
      fu_xu_regfile_seq_end         => fu_xu_regfile_seq_end,
      fu_xu_rf1_act                 => fu_xu_rf1_act,
      regf_scan_in                  => an_ac_regf_scan_in_omm(5 to 11),
      slowspr_addr_in               => bx_xu_slowspr_addr,
      slowspr_data_in               => bx_xu_slowspr_data,
      slowspr_done_in               => bx_xu_slowspr_done,
      slowspr_etid_in               => bx_xu_slowspr_etid,
      slowspr_rw_in                 => bx_xu_slowspr_rw,
      slowspr_val_in                => bx_xu_slowspr_val,
      spr_pvr_version_dc            => spr_pvr_version_dc,
      spr_pvr_revision_dc           => spr_pvr_revision_dc,
      debug_data_in                 => iu_xu_debug_data, 
      trigger_data_in               => iu_xu_trigger_data,  
      iu_xu_ex4_tlb_data            => iu_xu_ex4_tlb_data,
      iu_xu_ierat_ex2_flush_req     => iu_xu_ierat_ex2_flush_req,
      iu_xu_ierat_ex3_par_err       => iu_xu_ierat_ex3_par_err,
      iu_xu_ierat_ex4_par_err       => iu_xu_ierat_ex4_par_err,
      iu_xu_is2_axu_instr_type      => iu_xu_is2_axu_instr_type,
      iu_xu_is2_axu_ld_or_st        => iu_xu_is2_axu_ld_or_st,
      iu_xu_is2_axu_ldst_extpid     => iu_xu_is2_axu_ldst_extpid,
      iu_xu_is2_axu_ldst_forcealign => iu_xu_is2_axu_ldst_forcealign,
      iu_xu_is2_axu_ldst_forceexcept => iu_xu_is2_axu_ldst_forceexcept,
      iu_xu_is2_axu_ldst_indexed    => iu_xu_is2_axu_ldst_indexed,
      iu_xu_is2_axu_ldst_size       => iu_xu_is2_axu_ldst_size,
      iu_xu_is2_axu_ldst_tag        => iu_xu_is2_axu_ldst_tag,
      iu_xu_is2_axu_ldst_update     => iu_xu_is2_axu_ldst_update,
      iu_xu_is2_axu_mffgpr          => iu_xu_is2_axu_mffgpr,
      iu_xu_is2_axu_mftgpr          => iu_xu_is2_axu_mftgpr,
      iu_xu_is2_axu_store           => iu_xu_is2_axu_store,
      iu_xu_is2_axu_movedp          => iu_xu_is2_axu_movedp,
      iu_xu_is2_error               => iu_xu_is2_error,
      iu_xu_is2_gshare              => iu_xu_is2_gshare,
      iu_xu_is2_ifar                => iu_xu_is2_ifar,
      iu_xu_is2_instr               => iu_xu_is2_instr,
      iu_xu_is2_is_ucode            => iu_xu_is2_is_ucode,
      iu_xu_is2_match               => iu_xu_is2_match,
      iu_xu_is2_pred_taken_cnt      => iu_xu_is2_pred_taken_cnt,
      iu_xu_is2_pred_update         => iu_xu_is2_pred_update,
      iu_xu_is2_s1                  => iu_xu_is2_s1,
      iu_xu_is2_s1_vld              => iu_xu_is2_s1_vld,
      iu_xu_is2_s2                  => iu_xu_is2_s2,
      iu_xu_is2_s2_vld              => iu_xu_is2_s2_vld,
      iu_xu_is2_s3                  => iu_xu_is2_s3,
      iu_xu_is2_s3_vld              => iu_xu_is2_s3_vld,
      iu_xu_is2_ta                  => iu_xu_is2_ta,
      iu_xu_is2_ta_vld              => iu_xu_is2_ta_vld,
      iu_xu_is2_tid                 => iu_xu_is2_tid,
      iu_xu_is2_ucode_vld           => iu_xu_is2_ucode_vld,
      iu_xu_is2_vld                 => iu_xu_is2_vld,
      iu_xu_quiesce                 => iu_xu_quiesce,
      iu_xu_ra                      => iu_xu_ra,
      iu_xu_request                 => iu_xu_request,
      iu_xu_thread                  => iu_xu_thread,
      iu_xu_userdef                 => iu_xu_userdef,
      iu_xu_wimge                   => iu_xu_wimge,
      mm_xu_derat_mmucr0_0          => mm_xu_derat_mmucr0_0,
      mm_xu_derat_mmucr0_1          => mm_xu_derat_mmucr0_1,
      mm_xu_derat_mmucr0_2          => mm_xu_derat_mmucr0_2,
      mm_xu_derat_mmucr0_3          => mm_xu_derat_mmucr0_3,
      mm_xu_derat_mmucr1            => mm_xu_derat_mmucr1,
      mm_xu_derat_pid0              => mm_xu_derat_pid0,
      mm_xu_derat_pid1              => mm_xu_derat_pid1,
      mm_xu_derat_pid2              => mm_xu_derat_pid2,
      mm_xu_derat_pid3              => mm_xu_derat_pid3,
      mm_xu_derat_rel_data          => mm_xu_derat_rel_data,
      mm_xu_derat_rel_val           => mm_xu_derat_rel_val,
      mm_xu_derat_snoop_attr        => mm_xu_derat_snoop_attr,
      mm_xu_derat_snoop_val         => mm_xu_derat_snoop_val,
      mm_xu_derat_snoop_coming      => mm_xu_derat_snoop_coming,
      mm_xu_derat_snoop_vpn         => mm_xu_derat_snoop_vpn,
      mm_xu_eratmiss_done           => mm_xu_eratmiss_done,
      mm_xu_esr_pt                  => mm_xu_esr_pt,
      mm_xu_esr_data                => mm_xu_esr_data,
      mm_xu_esr_epid                => mm_xu_esr_epid,
      mm_xu_esr_st                  => mm_xu_esr_st,
      mm_xu_ex3_flush_req           => mm_xu_ex3_flush_req,
      xu_mm_rf1_is_tlbsxr           => xu_mm_rf1_is_tlbsxr,
      mm_xu_hold_done               => mm_xu_hold_done,
      mm_xu_hold_req                => mm_xu_hold_req,
      mm_xu_hv_priv                 => mm_xu_hv_priv,
      mm_xu_illeg_instr             => mm_xu_illeg_instr,
      mm_xu_local_snoop_reject      => mm_xu_local_snoop_reject, 
      mm_xu_lrat_miss               => mm_xu_lrat_miss,
      mm_xu_lsu_addr                => mm_xu_lsu_addr,
      mm_xu_lsu_lpid                => mm_xu_lsu_lpid,
      mm_xu_lsu_lpidr               => mm_xu_lsu_lpidr,
      mm_xu_lsu_gs                  => mm_xu_lsu_gs,
      mm_xu_lsu_ind                 => mm_xu_lsu_ind,
      mm_xu_lsu_lbit                => mm_xu_lsu_lbit,
      mm_xu_lsu_req                 => mm_xu_lsu_req,
      mm_xu_lsu_ttype               => mm_xu_lsu_ttype,
      mm_xu_lsu_u                   => mm_xu_lsu_u,
      mm_xu_lsu_wimge               => mm_xu_lsu_wimge,
      mm_xu_pt_fault                => mm_xu_pt_fault,
      mm_xu_quiesce                 => mm_xu_quiesce,
      mm_xu_tlb_inelig              => mm_xu_tlb_inelig,
      mm_xu_tlb_miss                => mm_xu_tlb_miss,
      mm_xu_tlb_multihit_err        => mm_xu_tlb_multihit_err,
      mm_xu_tlb_par_err             => mm_xu_tlb_par_err,
      mm_xu_lru_par_err             => mm_xu_lru_par_err,
      mm_xu_cr0_eq_valid            => mm_xu_cr0_eq_valid,
      mm_xu_cr0_eq                  => mm_xu_cr0_eq,
      nclk                          => a2_nclk,
      pc_xu_abst_sl_thold_3         => pc_xu_abst_sl_thold_3_ofu,
      pc_xu_abst_slp_sl_thold_3     => pc_xu_abst_slp_sl_thold_3_ofu,
      pc_xu_regf_sl_thold_3         => pc_xu_regf_sl_thold_3_ofu,
      pc_xu_regf_slp_sl_thold_3     => pc_xu_regf_slp_sl_thold_3_ofu,
      pc_xu_ary_nsl_thold_3         => pc_xu_ary_nsl_thold_3_ofu,
      pc_xu_ary_slp_nsl_thold_3     => pc_xu_ary_slp_nsl_thold_3_ofu,
      pc_xu_bolt_sl_thold_3	    => pc_xu_bolt_sl_thold_3_ofu,
      pc_xu_bo_enable_3  	    => pc_xu_bo_enable_3_ofu,
      pc_xu_bo_load                 => pc_xu_bo_load_ofu,
      pc_xu_bo_unload		    => pc_xu_bo_unload_ofu,
      pc_xu_bo_repair		    => pc_xu_bo_repair_ofu,
      pc_xu_bo_reset		    => pc_xu_bo_reset_ofu,
      pc_xu_bo_shdata		    => pc_xu_bo_shdata_ofu,
      pc_xu_bo_select		    => pc_xu_bo_select_ofu,
      pc_xu_cache_par_err_event     => pc_xu_cache_par_err_event_ofu,
      pc_xu_ccflush_dc              => pc_xu_ccflush_dc_ofu,
      pc_xu_cfg_sl_thold_3          => pc_xu_cfg_sl_thold_3_ofu,
      pc_xu_cfg_slp_sl_thold_3      => pc_xu_cfg_slp_sl_thold_3_ofu,
      pc_xu_dbg_action              => pc_xu_dbg_action_ofu,
      pc_xu_debug_mux1_ctrls        => pc_xu_debug_mux1_ctrls_ofu,
      pc_xu_debug_mux2_ctrls        => pc_xu_debug_mux2_ctrls_ofu,
      pc_xu_debug_mux3_ctrls        => pc_xu_debug_mux3_ctrls_ofu,
      pc_xu_debug_mux4_ctrls        => pc_xu_debug_mux4_ctrls_ofu,
      pc_xu_decrem_dis_on_stop      => pc_xu_decrem_dis_on_stop_ofu,
      xu_pc_spr_ccr0_we             => xu_pc_spr_ccr0_we,
      xu_pc_spr_ccr0_pme            => xu_pc_spr_ccr0_pme,
      pc_xu_event_bus_enable        => pc_xu_event_bus_enable_ofu,
      pc_xu_event_count_mode        => pc_xu_event_count_mode_ofu,
      pc_xu_event_mux_ctrls         => pc_xu_event_mux_ctrls_ofu,
      pc_xu_extirpts_dis_on_stop    => pc_xu_extirpts_dis_on_stop_ofu,
      pc_xu_fce_3                   => pc_xu_fce_3_ofu,
      pc_xu_force_ude               => pc_xu_force_ude_ofu,
      pc_xu_func_nsl_thold_3        => pc_xu_func_nsl_thold_3_ofu,
      pc_xu_func_sl_thold_3         => pc_xu_func_sl_thold_3_ofu,
      pc_xu_func_slp_nsl_thold_3    => pc_xu_func_slp_nsl_thold_3_ofu,
      pc_xu_func_slp_sl_thold_3     => pc_xu_func_slp_sl_thold_3_ofu,
      pc_xu_gptr_sl_thold_3         => pc_xu_gptr_sl_thold_3_ofu,
      pc_xu_init_reset              => pc_xu_init_reset_ofu,
      pc_xu_inj_dcachedir_multihit  => pc_xu_inj_dcachedir_multihit_ofu,
      pc_xu_instr_trace_mode        => pc_xu_instr_trace_mode_ofu,
      pc_xu_instr_trace_tid         => pc_xu_instr_trace_tid_ofu,
      pc_xu_lsu_event_mux_ctrls     => pc_xu_lsu_event_mux_ctrls_ofu,
      pc_xu_msrovride_de            => pc_xu_msrovride_de,
      pc_xu_msrovride_enab          => pc_xu_msrovride_enab_ofu,
      pc_xu_msrovride_pr            => pc_xu_msrovride_pr_ofu,
      pc_xu_msrovride_gs            => pc_xu_msrovride_gs_ofu,
      pc_xu_ram_execute             => pc_xu_ram_execute_ofu,
      pc_xu_ram_flush_thread        => pc_xu_ram_flush_thread_ofu,
      pc_xu_ram_mode                => pc_xu_ram_mode_ofu,
      pc_xu_ram_thread              => pc_xu_ram_thread_ofu,
      pc_xu_repr_sl_thold_3         => pc_xu_repr_sl_thold_3_ofu,
      pc_xu_reset_1_complete        => pc_xu_reset_1_cmplt_ofu,
      pc_xu_reset_2_complete        => pc_xu_reset_2_cmplt_ofu,
      pc_xu_reset_3_complete        => pc_xu_reset_3_cmplt_ofu,
      pc_xu_reset_wd_complete       => pc_xu_reset_wd_cmplt_ofu,
      pc_xu_sg_3                    => pc_xu_sg_3_ofu,
      pc_xu_step                    => pc_xu_step_ofu,
      pc_xu_stop                    => pc_xu_stop_ofu,
      pc_xu_timebase_dis_on_stop    => pc_xu_timebase_dis_on_stop_ofu,
      pc_xu_time_sl_thold_3         => pc_xu_time_sl_thold_3_ofu,
      pc_xu_trace_bus_enable        => pc_xu_trace_bus_enable_ofu,
      pc_xu_inj_dcache_parity       => pc_xu_inj_dcache_parity_ofu,
      pc_xu_inj_dcachedir_parity    => pc_xu_inj_dcachedir_parity_ofu,
      pc_xu_inj_llbust_attempt      => pc_xu_inj_llbust_attempt_ofu,
      pc_xu_inj_llbust_failed       => pc_xu_inj_llbust_failed_ofu,
      pc_xu_inj_sprg_ecc            => pc_xu_inj_sprg_ecc_ofu,
      pc_xu_inj_regfile_parity      => pc_xu_inj_regfile_parity_ofu,
      pc_xu_inj_wdt_reset           => pc_xu_inj_wdt_reset_ofu,
      pc_xu_abist_dcomp_g6t_2r      => pc_xu_abist_dcomp_g6t_2r_ofu(0 to 3),
      pc_xu_abist_di_0              => pc_xu_abist_di_0_ofu(0 to 3),
      pc_xu_abist_di_1              => pc_xu_abist_di_1_ofu(0 to 3),
      pc_xu_abist_di_g6t_2r         => pc_xu_abist_di_g6t_2r_ofu(0 to 3),
      pc_xu_abist_ena_dc            => pc_xu_abist_ena_dc_ofu,        
      pc_xu_abist_g6t_bw            => pc_xu_abist_g6t_bw_ofu(0 to 1),
      pc_xu_abist_g6t_r_wb          => pc_xu_abist_g6t_r_wb_ofu,      
      pc_xu_abist_g8t1p_renb_0      => pc_xu_abist_g8t1p_renb_0_ofu,  
      pc_xu_abist_g8t_bw_0          => pc_xu_abist_g8t_bw_0_ofu,      
      pc_xu_abist_g8t_bw_1          => pc_xu_abist_g8t_bw_1_ofu,      
      pc_xu_abist_g8t_dcomp         => pc_xu_abist_g8t_dcomp_ofu(0 to 3),
      pc_xu_abist_g8t_wenb          => pc_xu_abist_g8t_wenb_ofu,      
      pc_xu_abist_grf_renb_0        => pc_xu_abist_grf_renb_0_ofu,    
      pc_xu_abist_grf_renb_1        => pc_xu_abist_grf_renb_1_ofu,    
      pc_xu_abist_grf_wenb_0        => pc_xu_abist_grf_wenb_0_ofu,          
      pc_xu_abist_grf_wenb_1        => pc_xu_abist_grf_wenb_1_ofu,    
      pc_xu_abist_raddr_0           => pc_xu_abist_raddr_0_ofu(0 to 9),
      pc_xu_abist_raddr_1           => pc_xu_abist_raddr_1_ofu(0 to 9),
      pc_xu_abist_raw_dc_b          => pc_xu_abist_raw_dc_b_ofu,      
      pc_xu_abist_waddr_0           => pc_xu_abist_waddr_0_ofu(0 to 9),
      pc_xu_abist_waddr_1           => pc_xu_abist_waddr_1_ofu(0 to 9),
      pc_xu_abist_wl144_comp_ena    => pc_xu_abist_wl144_comp_ena_ofu,
      pc_xu_abist_wl32_comp_ena     => pc_xu_abist_wl32_comp_ena_ofu, 
      pc_xu_abist_wl512_comp_ena    => pc_xu_abist_wl512_comp_ena_ofu,
      an_ac_coreid                  => an_ac_coreid_omm,
      an_ac_external_mchk           => an_ac_external_mchk_omm,
      an_ac_hang_pulse              => an_ac_hang_pulse_omm,
      an_ac_scan_diag_dc            => an_ac_scan_diag_dc_oiu,
      an_ac_scan_dis_dc_b           => an_ac_scan_dis_dc_b_oiu,
      an_ac_tb_update_enable        => an_ac_tb_update_enable_omm,
      an_ac_tb_update_pulse         => an_ac_tb_update_pulse_omm,
      an_ac_reld_l1_dump            => an_ac_reld_l1_dump_omm,
      ac_tc_machine_check           => ac_an_machine_check_imm,
      ac_an_req                     => ac_an_req_imm,
      ac_an_req_endian              => ac_an_req_endian_imm,
      ac_an_req_ld_core_tag         => ac_an_req_ld_core_tag_imm,
      ac_an_req_ld_xfr_len          => ac_an_req_ld_xfr_len_imm,
      ac_an_req_pwr_token           => ac_an_req_pwr_token_imm,
      ac_an_req_ra                  => ac_an_req_ra_imm,
      ac_an_req_spare_ctrl_a0       => ac_an_req_spare_ctrl_a0_imm,
      ac_an_req_thread              => ac_an_req_thread_imm,
      ac_an_req_ttype               => ac_an_req_ttype_imm,
      ac_an_req_user_defined        => ac_an_req_user_defined_imm,
      ac_an_req_wimg_g              => ac_an_req_wimg_g_imm,
      ac_an_req_wimg_i              => ac_an_req_wimg_i_imm,
      ac_an_req_wimg_m              => ac_an_req_wimg_m_imm,
      ac_an_req_wimg_w              => ac_an_req_wimg_w_imm,
      ac_an_st_byte_enbl            => xu_st_byte_enbl,  
      ac_an_st_data                 => xu_st_data,
      ac_an_st_data_pwr_token       => ac_an_st_data_pwr_token_imm,
      an_ac_req_st_pop_thrd         => an_ac_req_st_pop_thrd_omm,
      ac_tc_debug_trigger           => ac_an_debug_trigger_imm,
      ac_tc_reset_1_request         => ac_an_reset_1_request_imm,
      ac_tc_reset_2_request         => ac_an_reset_2_request_imm,
      ac_tc_reset_3_request         => ac_an_reset_3_request_imm,
      ac_tc_reset_wd_request        => ac_an_reset_wd_request_imm,
      abst_scan_out                 => ac_an_abst_scan_out_imm_xu(7 to 9),
      bcfg_scan_out                 => ac_an_bcfg_scan_out_imm(4),
      ccfg_scan_out                 => xu_fu_ccfg_scan_out,
      dcfg_scan_out                 => ac_an_dcfg_scan_out_imm(2),
      func_scan_out                 => ac_an_func_scan_out_imm_xu(31 to 58),
      gptr_scan_out                 => xu_mm_gptr_scan_out,
      repr_scan_out                 => xu_mm_repr_scan_out,
      time_scan_out                 => xu_mm_time_scan_out,
      regf_scan_out                 => ac_an_regf_scan_out_imm(5 to 11),
      xu_n_is2_flush                => xu_n_is2_flush,
      xu_n_rf0_flush                => xu_n_rf0_flush,
      xu_n_rf1_flush                => xu_n_rf1_flush,
      xu_n_ex1_flush                => xu_n_ex1_flush,
      xu_n_ex2_flush                => xu_n_ex2_flush,
      xu_n_ex3_flush                => xu_n_ex3_flush,
      xu_n_ex4_flush                => xu_n_ex4_flush,
      xu_n_ex5_flush                => xu_n_ex5_flush,
      xu_s_rf1_flush                => xu_s_rf1_flush,
      xu_s_ex1_flush                => xu_s_ex1_flush,
      xu_s_ex2_flush                => xu_s_ex2_flush,
      xu_s_ex3_flush                => xu_s_ex3_flush,
      xu_s_ex4_flush                => xu_s_ex4_flush,
      xu_s_ex5_flush                => xu_s_ex5_flush,
      xu_wu_rf1_flush               => xu_wu_rf1_flush,    
      xu_wu_ex1_flush               => xu_wu_ex1_flush,    
      xu_wu_ex2_flush               => xu_wu_ex2_flush,    
      xu_wu_ex3_flush               => xu_wu_ex3_flush,    
      xu_wu_ex4_flush               => xu_wu_ex4_flush,    
      xu_wu_ex5_flush               => xu_wu_ex5_flush,    
      xu_wl_rf1_flush               => xu_wl_rf1_flush,    
      xu_wl_ex1_flush               => xu_wl_ex1_flush,    
      xu_wl_ex2_flush               => xu_wl_ex2_flush,    
      xu_wl_ex3_flush               => xu_wl_ex3_flush,    
      xu_wl_ex4_flush               => xu_wl_ex4_flush,    
      xu_wl_ex5_flush               => xu_wl_ex5_flush,    
      xu_fu_ccr2_ap                 => xu_fu_ccr2_ap,
      xu_fu_ex3_eff_addr            => xu_fu_ex3_eff_addr,
      xu_fu_ex6_load_data           => xu_fu_ex6_load_data,
      xu_fu_ex5_load_le             => xu_fu_ex5_load_le,
      xu_fu_ex5_load_tag            => xu_fu_ex5_load_tag,
      xu_fu_ex5_load_val            => xu_fu_ex5_load_val,
      xu_fu_ex5_reload_val          => xu_fu_ex5_reload_val,
      xu_fu_msr_fp                  => xu_fu_msr_fp,
      xu_fu_msr_pr                  => xu_fu_msr_pr,
      xu_fu_msr_gs                  => xu_fu_msr_gs,
      xu_fu_msr_spv                 => xu_fu_msr_spv,
      xu_fu_regfile_seq_beg	    => xu_fu_regfile_seq_beg,
      xu_iu_complete_qentry         => xu_iu_complete_qentry,
      xu_iu_complete_target_type    => xu_iu_complete_target_type,
      xu_iu_complete_tid            => xu_iu_complete_tid,
      xu_iu_ex1_ra_entry            => xu_iu_ex1_ra_entry,
      xu_iu_ex1_rb                  => xu_iu_ex1_rb,
      xu_iu_ex1_rs_is               => xu_iu_ex1_rs_is,
      xu_iu_ex5_bclr                => xu_iu_ex5_bclr,
      xu_iu_ex5_bh                  => xu_iu_ex5_bh,
      xu_iu_ex5_br_hist             => xu_iu_ex5_br_hist,
      xu_iu_ex5_br_taken            => xu_iu_ex5_br_taken,
      xu_iu_ex5_br_update           => xu_iu_ex5_br_update,
      xu_iu_ex5_getNIA              => xu_iu_ex5_getNIA,
      xu_iu_ex5_gshare              => xu_iu_ex5_gshare,
      xu_iu_ex5_ifar                => xu_iu_ex5_ifar,
      xu_iu_ex5_lk                  => xu_iu_ex5_lk,
      xu_iu_ex5_ppc_cpl             => xu_iu_ex5_ppc_cpl,
      xu_iu_ex4_loadmiss_qentry     => xu_iu_ex4_loadmiss_qentry,
      xu_iu_ex4_loadmiss_target     => xu_iu_ex4_loadmiss_target,
      xu_iu_ex4_loadmiss_target_type=> xu_iu_ex4_loadmiss_target_type,
      xu_iu_ex4_loadmiss_tid        => xu_iu_ex4_loadmiss_tid,
      xu_iu_ex4_rs_data             => xu_iu_ex4_rs_data,
      xu_iu_ex5_tid                 => xu_iu_ex5_tid,
      xu_iu_ex5_val                 => xu_iu_ex5_val,
      xu_iu_ex5_loadmiss_qentry     => xu_iu_ex5_loadmiss_qentry,
      xu_iu_ex5_loadmiss_target     => xu_iu_ex5_loadmiss_target,
      xu_iu_ex5_loadmiss_target_type=> xu_iu_ex5_loadmiss_target_type,
      xu_iu_ex5_loadmiss_tid        => xu_iu_ex5_loadmiss_tid,
      xu_iu_ex6_icbi_val            => xu_iu_ex6_icbi_val,
      xu_iu_ex6_icbi_addr           => xu_iu_ex6_icbi_addr,
      xu_iu_ex6_pri                 => xu_iu_ex6_pri,
      xu_iu_ex6_pri_val             => xu_iu_ex6_pri_val,
      xu_iu_flush_2ucode            => xu_iu_flush_2ucode,
      xu_iu_flush_2ucode_type       => xu_iu_flush_2ucode_type,
      xu_iu_hid_mmu_mode            => xu_iu_hid_mmu_mode,
      xu_iu_xucr0_rel               => xu_iu_xucr0_rel,
      xu_iu_ici                     => xu_iu_ici,
      xu_iu_iu0_flush_ifar0         => xu_iu_iu0_flush_ifar0,
      xu_iu_iu0_flush_ifar1         => xu_iu_iu0_flush_ifar1,
      xu_iu_iu0_flush_ifar2         => xu_iu_iu0_flush_ifar2,
      xu_iu_iu0_flush_ifar3         => xu_iu_iu0_flush_ifar3,
      xu_iu_larx_done_tid           => xu_iu_larx_done_tid,
      xu_iu_set_barr_tid            => xu_iu_set_barr_tid,
      xu_iu_membar_tid              => xu_iu_membar_tid,
      xu_iu_msr_cm                  => xu_iu_msr_cm,
      xu_iu_msr_hv                  => xu_iu_msr_hv,
      xu_iu_msr_is                  => xu_iu_msr_is,
      xu_iu_msr_pr                  => xu_iu_msr_pr,
      xu_iu_multdiv_done            => xu_iu_multdiv_done,
      xu_iu_need_hole               => xu_iu_need_hole,
      xu_iu_raise_iss_pri           => xu_iu_raise_iss_pri,
      xu_iu_ram_issue               => xu_iu_ram_issue,
      xu_iu_ex1_is_csync            => xu_iu_ex1_is_csync,
      xu_iu_ex1_is_isync            => xu_iu_ex1_is_isync,
      xu_iu_rf1_is_eratilx          => xu_iu_rf1_is_eratilx,
      xu_iu_rf1_is_eratre           => xu_iu_rf1_is_eratre,
      xu_iu_rf1_is_eratsx           => xu_iu_rf1_is_eratsx,
      xu_iu_rf1_is_eratwe           => xu_iu_rf1_is_eratwe,
      xu_iu_rf1_val                 => xu_iu_rf1_val,
      xu_iu_rf1_ws                  => xu_iu_rf1_ws,
      xu_iu_rf1_t                   => xu_iu_rf1_t,
      xu_iu_run_thread              => xu_iu_run_thread,
      xu_iu_single_instr_mode       => xu_iu_single_instr_mode,
      xu_iu_slowspr_done            => xu_iu_slowspr_done,
      xu_iu_spr_ccr2_en_dcr         => xu_iu_spr_ccr2_en_dcr,
      xu_iu_spr_ccr2_ifratsc        => xu_iu_spr_ccr2_ifratsc,
      xu_iu_spr_ccr2_ifrat          => xu_iu_spr_ccr2_ifrat,
      xu_bx_ccr2_en_ditc            => xu_bx_ccr2_en_ditc,
      xu_iu_spr_xer0                => xu_iu_spr_xer0,
      xu_iu_spr_xer1                => xu_iu_spr_xer1,
      xu_iu_spr_xer2                => xu_iu_spr_xer2,
      xu_iu_spr_xer3                => xu_iu_spr_xer3,
      xu_iu_uc_flush_ifar0          => xu_iu_uc_flush_ifar0,
      xu_iu_uc_flush_ifar1          => xu_iu_uc_flush_ifar1,
      xu_iu_uc_flush_ifar2          => xu_iu_uc_flush_ifar2,
      xu_iu_uc_flush_ifar3          => xu_iu_uc_flush_ifar3,
      xu_iu_ucode_restart           => xu_iu_ucode_restart,
      xu_mm_derat_epn               => xu_mm_derat_epn,
      xu_mm_derat_lpid              => xu_mm_derat_lpid,
      xu_mm_derat_mmucr0            => xu_mm_derat_mmucr0,
      xu_mm_derat_mmucr0_we         => xu_mm_derat_mmucr0_we,
      xu_mm_derat_mmucr1            => xu_mm_derat_mmucr1,
      xu_mm_derat_mmucr1_we         => xu_mm_derat_mmucr1_we,
      xu_mm_derat_req               => xu_mm_derat_req,
      xu_mm_derat_snoop_ack         => xu_mm_derat_snoop_ack,
      xu_mm_derat_state             => xu_mm_derat_state,
      xu_mm_derat_thdid             => xu_mm_derat_thdid,
      xu_mm_derat_tid               => xu_mm_derat_tid,
      xu_mm_derat_ttype             => xu_mm_derat_ttype,
      xu_mm_ex2_eff_addr            => xu_mm_ex2_eff_addr,
      xu_mm_ex1_rs_is               => xu_mm_ex1_rs_is,
      xu_mm_ex4_flush               => xu_mm_ex4_flush,
      xu_mm_ex5_flush               => xu_mm_ex5_flush,
      xu_mm_ex5_perf_dtlb           => xu_mm_ex5_perf_dtlb,
      xu_mm_ex5_perf_itlb           => xu_mm_ex5_perf_itlb,
      xu_mm_hid_mmu_mode            => xu_mm_hid_mmu_mode,
      xu_mm_hold_ack                => xu_mm_hold_ack,
      xu_mm_ierat_flush             => xu_mm_ierat_flush,
      xu_mm_ierat_miss              => xu_mm_ierat_miss,
      xu_mm_lmq_stq_empty           => xu_mm_lmq_stq_empty,
      xu_mm_lsu_token               => xu_mm_lsu_token,
      xu_mm_msr_cm                  => xu_mm_msr_cm,
      xu_mm_msr_ds                  => xu_mm_msr_ds,
      xu_mm_msr_gs                  => xu_mm_msr_gs,
      xu_iu_msr_gs                  => xu_iu_msr_gs,
      xu_mm_msr_is                  => xu_mm_msr_is,
      xu_mm_msr_pr                  => xu_mm_msr_pr,
      xu_mm_ex1_is_csync            => xu_mm_ex1_is_csync,
      xu_mm_ex1_is_isync            => xu_mm_ex1_is_isync,
      xu_mm_rf1_is_eratilx          => xu_mm_rf1_is_eratilx,
      xu_mm_rf1_is_erativax         => xu_mm_rf1_is_erativax,
      xu_mm_rf1_is_tlbilx           => xu_mm_rf1_is_tlbilx,
      xu_mm_rf1_is_tlbivax          => xu_mm_rf1_is_tlbivax,
      xu_mm_rf1_is_tlbre            => xu_mm_rf1_is_tlbre,
      xu_mm_rf1_is_tlbsx            => xu_mm_rf1_is_tlbsx,
      xu_mm_rf1_is_tlbsrx           => xu_mm_rf1_is_tlbsrx,
      xu_mm_rf1_is_tlbwe            => xu_mm_rf1_is_tlbwe,
      xu_mm_rf1_val                 => xu_mm_rf1_val,
      xu_mm_rf1_t                   => xu_mm_rf1_t,
      xu_mm_spr_epcr_dgtmi          => xu_mm_spr_epcr_dgtmi,
      xu_mm_spr_epcr_dmiuh          => xu_mm_spr_epcr_dmiuh,
      slowspr_addr_out              => xu_mm_slowspr_addr,
      slowspr_data_out              => xu_mm_slowspr_data,
      slowspr_done_out              => xu_mm_slowspr_done,
      slowspr_etid_out              => xu_mm_slowspr_etid,
      slowspr_rw_out                => xu_mm_slowspr_rw,
      slowspr_val_out               => xu_mm_slowspr_val,
      debug_data_out                => xu_mm_debug_data,
      trigger_data_out              => xu_mm_trigger_data,
      xu_pc_bo_fail                 => xu_pc_bo_fail,
      xu_pc_bo_diagout              => xu_pc_bo_diagout,
      xu_pc_err_attention_instr     => xu_pc_err_attention_instr,
      xu_pc_err_dcache_parity       => xu_pc_err_dcache_parity,
      xu_pc_err_dcachedir_multihit  => xu_pc_err_dcachedir_multihit,
      xu_pc_err_dcachedir_parity    => xu_pc_err_dcachedir_parity,
      xu_pc_err_debug_event         => xu_pc_err_debug_event,
      xu_pc_err_mcsr_summary        => xu_pc_err_mcsr_summary,      
      xu_pc_err_ierat_parity        => xu_pc_err_ierat_parity,      
      xu_pc_err_derat_parity        => xu_pc_err_derat_parity,      
      xu_pc_err_ditc_overrun        => xu_pc_err_ditc_overrun,
      xu_pc_err_tlb_parity          => xu_pc_err_tlb_parity,        
      xu_pc_err_tlb_lru_parity      => xu_pc_err_tlb_lru_parity,    
      xu_pc_err_ierat_multihit      => xu_pc_err_ierat_multihit,    
      xu_pc_err_derat_multihit      => xu_pc_err_derat_multihit,    
      xu_pc_err_tlb_multihit        => xu_pc_err_tlb_multihit,      
      xu_pc_err_ext_mchk            => xu_pc_err_ext_mchk,          
      xu_pc_err_local_snoop_reject  => xu_pc_err_local_snoop_reject,
      xu_pc_err_l2intrf_ecc         => xu_pc_err_l2intrf_ecc,
      xu_pc_err_l2intrf_ue          => xu_pc_err_l2intrf_ue,
      xu_pc_err_llbust_attempt      => xu_pc_err_llbust_attempt,
      xu_pc_err_llbust_failed       => xu_pc_err_llbust_failed,
      xu_pc_err_nia_miscmpr         => xu_pc_err_nia_miscmpr,
      xu_pc_err_regfile_parity      => xu_pc_err_regfile_parity,
      xu_pc_err_regfile_ue          => xu_pc_err_regfile_ue,
      xu_pc_err_sprg_ecc            => xu_pc_err_sprg_ecc,
      xu_pc_err_sprg_ue             => xu_pc_err_sprg_ue,
      xu_pc_err_wdt_reset           => xu_pc_err_wdt_reset,
      xu_pc_err_invld_reld          => xu_pc_err_invld_reld,
      xu_pc_err_l2credit_overrun    => xu_pc_err_l2credit_overrun,
      xu_pc_lsu_event_data          => xu_pc_lsu_event_data,
      xu_pc_event_data              => xu_pc_event_data,
      xu_pc_ram_data                => xu_pc_ram_data,
      xu_pc_ram_done                => xu_pc_ram_done,
      xu_pc_ram_interrupt           => xu_pc_ram_interrupt,
      xu_pc_running                 => xu_pc_running,
      xu_pc_step_done               => xu_pc_step_done,
      xu_pc_stop_dbg_event          => xu_pc_stop_dbg_event,
     xu_bx_ex1_mtdp_val            => xu_bx_ex1_mtdp_val       ,
     xu_bx_ex1_mfdp_val            => xu_bx_ex1_mfdp_val       ,
     xu_bx_ex1_ipc_thrd            => xu_bx_ex1_ipc_thrd        ,
     xu_bx_ex2_ipc_ba              => xu_bx_ex2_ipc_ba          ,
     xu_bx_ex2_ipc_sz              => xu_bx_ex2_ipc_sz          ,
     xu_bx_ex4_256st_data          => xu_bx_ex4_256st_data(128 to 255) ,
     xu_iu_reld_core_tag          => xu_iu_reld_core_tag,
     xu_iu_reld_core_tag_clone    => xu_iu_reld_core_tag_clone,
     xu_iu_reld_data              => xu_iu_reld_data,
     xu_iu_reld_data_coming_clone => xu_iu_reld_data_coming_clone,
     xu_iu_reld_data_vld          => xu_iu_reld_data_vld,
     xu_iu_reld_data_vld_clone    => xu_iu_reld_data_vld_clone,
     xu_iu_reld_ditc_clone        => xu_iu_reld_ditc_clone,
     xu_iu_reld_ecc_err           => xu_iu_reld_ecc_err, 
     xu_iu_reld_ecc_err_ue        => xu_iu_reld_ecc_err_ue,
     xu_iu_reld_qw                => xu_iu_reld_qw,

     bx_xu_ex4_mtdp_cr_status     => bx_xu_ex4_mtdp_cr_status ,
     bx_xu_ex4_mfdp_cr_status     => bx_xu_ex4_mfdp_cr_status ,
     bx_xu_ex5_dp_data            => bx_xu_ex5_dp_data        ,
     bx_xu_quiesce                => bx_xu_quiesce,

     bx_lsu_ob_pwr_tok       => bx_lsu_ob_pwr_tok ,
     bx_lsu_ob_req_val       => bx_lsu_ob_req_val ,
     bx_lsu_ob_ditc_val      => bx_lsu_ob_ditc_val,
     bx_lsu_ob_thrd          => bx_lsu_ob_thrd    ,
     bx_lsu_ob_qw            => bx_lsu_ob_qw      ,
     bx_lsu_ob_dest          => bx_lsu_ob_dest    ,
     bx_lsu_ob_data          => bx_lsu_ob_data    ,
     bx_lsu_ob_addr          => bx_lsu_ob_addr    ,
     lsu_bx_cmd_avail           => lsu_bx_cmd_avail     ,
     lsu_bx_cmd_sent            => lsu_bx_cmd_sent      ,
     lsu_bx_cmd_stall           => lsu_bx_cmd_stall     ,



     ac_an_reld_ditc_pop_int            => ac_an_reld_ditc_pop_int,
     ac_an_reld_ditc_pop_q              => ac_an_reld_ditc_pop_imm,
     bx_ib_empty_int                    => bx_ib_empty_int,
     bx_ib_empty_q                      => ac_an_box_empty_imm,
     xu_iu_l_flush                      => xu_iu_l_flush,
     xu_iu_u_flush                      => xu_iu_u_flush,
     xu_pc_err_mchk_disabled            => xu_pc_err_mchk_disabled,
     xu_fu_lbist_ary_wrt_thru_dc        => xu_fu_lbist_ary_wrt_thru_dc,
     xu_fu_lbist_en_dc                  => xu_fu_lbist_en_dc,
     xu_iu_xucr4_mmu_mchk  	        => xu_iu_xucr4_mmu_mchk,
     xu_mm_xucr4_mmu_mchk     	        => xu_mm_xucr4_mmu_mchk,
     
      gnd                           => gnd,
      vcs                           => vcs,
      vdd                           => vdd
   ); 

   ac_an_st_byte_enbl_imm           <= xu_st_byte_enbl;
   ac_an_st_data_imm                <= xu_st_data;






a_mmq: entity work.mmq
   generic map(data_out_width => data_out_width,
     debug_event_width   => debug_event_width,
     debug_trace_width   => debug_trace_width,
     epn_width           => epn_width,
     eptr_width          => eptr_width,
     erat_ary_data_width => erat_ary_data_width,
     erat_cam_data_width => erat_cam_data_width,
     erat_rel_data_width => erat_rel_data_width,
     error_width         => error_width,
     expand_tlb_type     => expand_tlb_type,
     expand_type         => expand_type,
     extclass_width      => extclass_width,
     inv_seq_width       => inv_seq_width,
     lpid_width          => lpid_width,
     lru_width           => lru_width,
     mmucr0_width        => mmucr0_width,
     mmucr1_width        => mmucr1_width,
     mmucr2_width        => mmucr2_width,
     mmucr3_width        => mmucr3_width,
     pid_width           => pid_width,
     por_seq_width       => por_seq_width,
     ra_entry_width      => ra_entry_width,
     real_addr_width     => real_addr_width,
     req_epn_width       => req_epn_width,
     rpn_width           => rpn_width,
     rs_data_width       => rs_data_width,
     rs_is_width         => rs_is_width,
     spr_addr_width      => spr_addr_width,
     spr_ctl_width       => spr_ctl_width,
     spr_data_width      => spr_data_width,
     spr_etid_width      => spr_etid_width,
     state_width         => state_width,
     thdid_width         => thdid_width,
     tlb_addr_width      => tlb_addr_width,
     tlb_num_entry       => tlb_num_entry,
     tlb_num_entry_log2  => tlb_num_entry_log2,
     tlb_seq_width       => tlb_seq_width,
     tlb_tag_width       => tlb_tag_width,
     tlb_way_width       => tlb_way_width,
     tlb_ways            => tlb_ways,
     tlb_word_width      => tlb_word_width,
     tlbsel_width        => tlbsel_width,
     ttype_width         => ttype_width,
     vpn_width           => vpn_width,
     watermark_width     => watermark_width,
     ws_width            => ws_width)
   port map (
      an_ac_abst_scan_in          => an_ac_abst_scan_in(0 to 9),
      an_ac_bcfg_scan_in          => an_ac_bcfg_scan_in(0 to 4),
      an_ac_dcfg_scan_in          => an_ac_dcfg_scan_in(0 to 2),
      an_ac_func_scan_in          => an_ac_func_scan_in(0 to 63),
      gptr_scan_in	          => xu_mm_gptr_scan_out,
      repr_scan_in	          => xu_mm_repr_scan_out,
      time_scan_in	          => xu_mm_time_scan_out,
      an_ac_back_inv              => an_ac_back_inv,
      an_ac_back_inv_addr         => an_ac_back_inv_addr,
      an_ac_back_inv_lbit         => an_ac_back_inv_lbit,
      an_ac_back_inv_gs           => an_ac_back_inv_gs,
      an_ac_back_inv_ind          => an_ac_back_inv_ind,
      an_ac_back_inv_local        => an_ac_back_inv_local,
      an_ac_back_inv_lpar_id      => an_ac_back_inv_lpar_id,
      an_ac_back_inv_target       => an_ac_back_inv_target,
      an_ac_lbist_ary_wrt_thru_dc => an_ac_lbist_ary_wrt_thru_dc,
      an_ac_reld_core_tag         => an_ac_reld_core_tag,
      an_ac_reld_data             => an_ac_reld_data,
      an_ac_reld_data_vld         => an_ac_reld_data_vld,
      an_ac_reld_ecc_err          => an_ac_reld_ecc_err,
      an_ac_reld_ecc_err_ue       => an_ac_reld_ecc_err_ue,
      an_ac_reld_qw               => an_ac_reld_qw(57 to 59),
      an_ac_reld_ditc             => an_ac_reld_ditc,
      an_ac_reld_crit_qw          => an_ac_reld_crit_qw,
      iu_mm_ierat_epn             => iu_mm_ierat_epn,
      iu_mm_ierat_flush           => iu_mm_ierat_flush,
      iu_mm_ierat_mmucr0          => iu_mm_ierat_mmucr0,
      iu_mm_ierat_mmucr0_we       => iu_mm_ierat_mmucr0_we,
      iu_mm_ierat_mmucr1          => iu_mm_ierat_mmucr1,
      iu_mm_ierat_mmucr1_we       => iu_mm_ierat_mmucr1_we,
      iu_mm_ierat_req             => iu_mm_ierat_req,
      iu_mm_ierat_snoop_ack       => iu_mm_ierat_snoop_ack,
      iu_mm_ierat_thdid           => iu_mm_ierat_thdid,
      iu_mm_ierat_tid             => iu_mm_ierat_tid,
      iu_mm_ierat_state           => iu_mm_ierat_state,
      iu_mm_lmq_empty             => iu_mm_lmq_empty,
      nclk                        => a2_nclk,
      pc_mm_abist_dcomp_g6t_2r    => pc_mm_abist_dcomp_g6t_2r_oiu,
      pc_mm_abist_di_0            => pc_mm_abist_di_0_oiu,
      pc_mm_abist_di_g6t_2r       => pc_mm_abist_di_g6t_2r_oiu,
      pc_mm_abist_ena_dc          => pc_mm_abist_ena_dc_oiu,
      pc_mm_abist_g6t_r_wb        => pc_mm_abist_g6t_r_wb_oiu,
      pc_mm_abist_g8t1p_renb_0    => pc_mm_abist_g8t1p_renb_0_oiu,
      pc_mm_abist_g8t_bw_0        => pc_mm_abist_g8t_bw_0_oiu,
      pc_mm_abist_g8t_bw_1        => pc_mm_abist_g8t_bw_1_oiu,
      pc_mm_abist_g8t_dcomp       => pc_mm_abist_g8t_dcomp_oiu,
      pc_mm_abist_g8t_wenb        => pc_mm_abist_g8t_wenb_oiu,
      pc_mm_abist_raddr_0         => pc_mm_abist_raddr_0_oiu,
      pc_mm_abist_raw_dc_b        => pc_mm_abist_raw_dc_b_oiu,
      pc_mm_abist_waddr_0         => pc_mm_abist_waddr_0_oiu,
      pc_mm_abist_wl128_comp_ena  => pc_mm_abist_wl128_comp_ena_oiu,
      pc_mm_abst_sl_thold_3       => pc_mm_abst_sl_thold_3_oiu,
      pc_mm_abst_slp_sl_thold_3   => pc_mm_abst_slp_sl_thold_3_oiu,
      pc_mm_ary_nsl_thold_3       => pc_mm_ary_nsl_thold_3_oiu,
      pc_mm_ary_slp_nsl_thold_3   => pc_mm_ary_slp_nsl_thold_3_oiu,
      pc_mm_bolt_sl_thold_3	  => pc_mm_bolt_sl_thold_3_oiu,
      pc_mm_bo_enable_3	          => pc_mm_bo_enable_3_oiu,
      pc_mm_bo_reset  	          => pc_mm_bo_reset_oiu,
      pc_mm_bo_unload 	          => pc_mm_bo_unload_oiu,
      pc_mm_bo_repair 	          => pc_mm_bo_repair_oiu,
      pc_mm_bo_shdata 	          => pc_mm_bo_shdata_oiu,
      pc_mm_bo_select 	          => pc_mm_bo_select_oiu,
      pc_mm_cfg_sl_thold_3        => pc_mm_cfg_sl_thold_3_oiu,
      pc_mm_cfg_slp_sl_thold_3    => pc_mm_cfg_slp_sl_thold_3_oiu,
      pc_mm_debug_mux1_ctrls      => pc_mm_debug_mux1_ctrls_oiu,
      pc_mm_event_count_mode      => pc_mm_event_count_mode_oiu,
      pc_mm_event_mux_ctrls       => pc_mm_event_mux_ctrls_oiu,
      pc_mm_fce_3                 => pc_mm_fce_3_oiu,
      pc_mm_func_nsl_thold_3      => pc_mm_func_nsl_thold_3_oiu,
      pc_mm_func_sl_thold_3       => pc_mm_func_sl_thold_3_oiu,        
      pc_mm_func_slp_nsl_thold_3  => pc_mm_func_slp_nsl_thold_3_oiu,
      pc_mm_func_slp_sl_thold_3   => pc_mm_func_slp_sl_thold_3_oiu,    
      pc_mm_gptr_sl_thold_3       => pc_mm_gptr_sl_thold_3_oiu,
      pc_mm_repr_sl_thold_3       => pc_mm_repr_sl_thold_3_oiu,
      pc_mm_sg_3                  => pc_mm_sg_3_oiu,                   
      pc_mm_time_sl_thold_3       => pc_mm_time_sl_thold_3_oiu,
      pc_mm_trace_bus_enable      => pc_mm_trace_bus_enable_oiu,
      rp_mm_event_bus_enable_q    => rp_mm_event_bus_enable_q,
      tc_ac_ccflush_dc            => pc_mm_ccflush_dc_oiu,
      tc_ac_lbist_en_dc           => an_ac_lbist_en_dc,
      tc_ac_scan_diag_dc         => an_ac_scan_diag_dc,
      tc_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b,
      debug_bus_in               => xu_mm_debug_data,   
      trace_triggers_in          => xu_mm_trigger_data,
      xu_ex1_flush               => xu_s_ex1_flush,
      xu_ex2_flush               => xu_s_ex2_flush,
      xu_ex3_flush               => xu_s_ex3_flush,
      xu_ex4_flush               => xu_s_ex4_flush,
      xu_ex5_flush               => xu_s_ex5_flush,
      mm_xu_cr0_eq               => mm_xu_cr0_eq,
      mm_xu_cr0_eq_valid         => mm_xu_cr0_eq_valid,
      xu_mm_derat_epn            => xu_mm_derat_epn,
      xu_mm_derat_lpid           => xu_mm_derat_lpid,
      xu_mm_derat_mmucr0         => xu_mm_derat_mmucr0,
      xu_mm_derat_mmucr0_we      => xu_mm_derat_mmucr0_we,
      xu_mm_derat_mmucr1         => xu_mm_derat_mmucr1,
      xu_mm_derat_mmucr1_we      => xu_mm_derat_mmucr1_we,
      xu_mm_derat_req            => xu_mm_derat_req,
      xu_mm_derat_snoop_ack      => xu_mm_derat_snoop_ack,
      xu_mm_derat_state          => xu_mm_derat_state,
      xu_mm_derat_thdid          => xu_mm_derat_thdid,
      xu_mm_derat_tid            => xu_mm_derat_tid,
      xu_mm_derat_ttype          => xu_mm_derat_ttype,
      xu_mm_ex2_eff_addr         => xu_mm_ex2_eff_addr,
      xu_mm_ex1_rs_is            => xu_mm_ex1_rs_is,
      xu_mm_ex4_flush            => xu_mm_ex4_flush,
      xu_mm_ex5_flush            => xu_mm_ex5_flush,
      xu_mm_ex5_perf_dtlb        => xu_mm_ex5_perf_dtlb,
      xu_mm_ex5_perf_itlb        => xu_mm_ex5_perf_itlb,
      xu_mm_hid_mmu_mode         => xu_mm_hid_mmu_mode,
      xu_mm_hold_ack             => xu_mm_hold_ack,
      xu_mm_ierat_flush          => xu_mm_ierat_flush,
      xu_mm_ierat_miss           => xu_mm_ierat_miss,
      xu_mm_lmq_stq_empty        => xu_mm_lmq_stq_empty,
      xu_mm_lsu_token            => xu_mm_lsu_token,
      xu_mm_msr_cm               => xu_mm_msr_cm,
      xu_mm_msr_ds               => xu_mm_msr_ds,
      xu_mm_msr_gs               => xu_mm_msr_gs,
      xu_mm_msr_is               => xu_mm_msr_is,
      xu_mm_msr_pr               => xu_mm_msr_pr,
      xu_mm_ex1_is_csync         => xu_mm_ex1_is_csync,
      xu_mm_ex1_is_isync         => xu_mm_ex1_is_isync,
      xu_mm_rf1_is_eratilx       => xu_mm_rf1_is_eratilx,
      xu_mm_rf1_is_erativax      => xu_mm_rf1_is_erativax,
      xu_mm_rf1_is_tlbilx        => xu_mm_rf1_is_tlbilx,
      xu_mm_rf1_is_tlbivax       => xu_mm_rf1_is_tlbivax,
      xu_mm_rf1_is_tlbre         => xu_mm_rf1_is_tlbre,
      xu_mm_rf1_is_tlbsx         => xu_mm_rf1_is_tlbsx,
      xu_mm_rf1_is_tlbsxr        => xu_mm_rf1_is_tlbsxr,
      xu_mm_rf1_is_tlbsrx        => xu_mm_rf1_is_tlbsrx,
      xu_mm_rf1_is_tlbwe         => xu_mm_rf1_is_tlbwe,
      xu_mm_rf1_val              => xu_mm_rf1_val,
      xu_mm_rf1_t                => xu_mm_rf1_t,
      xu_mm_spr_epcr_dgtmi       => xu_mm_spr_epcr_dgtmi,
      xu_mm_spr_epcr_dmiuh       => xu_mm_spr_epcr_dmiuh,
      slowspr_addr_in            => xu_mm_slowspr_addr,
      slowspr_data_in            => xu_mm_slowspr_data,
      slowspr_done_in            => xu_mm_slowspr_done,
      slowspr_etid_in            => xu_mm_slowspr_etid,
      slowspr_rw_in              => xu_mm_slowspr_rw,
      slowspr_val_in             => xu_mm_slowspr_val,
      xu_rf1_flush               => xu_s_rf1_flush,
      bcfg_scan_out              => mm_rp_bcfg_scan_out,
      ccfg_scan_out              => mm_iu_ccfg_scan_out,
      dcfg_scan_out              => mm_rp_dcfg_scan_out,
      ac_an_gptr_scan_out        => ac_an_gptr_scan_out,
      ac_an_repr_scan_out        => ac_an_repr_scan_out,
      ac_an_time_scan_out        => ac_an_time_scan_out,
      ac_an_back_inv_reject      => ac_an_back_inv_reject,
      ac_an_lpar_id              => ac_an_lpar_id,
      mm_iu_barrier_done         => mm_iu_barrier_done,
      mm_iu_ierat_mmucr0_0       => mm_iu_ierat_mmucr0_0,
      mm_iu_ierat_mmucr0_1       => mm_iu_ierat_mmucr0_1,
      mm_iu_ierat_mmucr0_2       => mm_iu_ierat_mmucr0_2,
      mm_iu_ierat_mmucr0_3       => mm_iu_ierat_mmucr0_3,
      mm_iu_ierat_mmucr1         => mm_iu_ierat_mmucr1,
      mm_iu_ierat_pid0           => mm_iu_ierat_pid0,
      mm_iu_ierat_pid1           => mm_iu_ierat_pid1,
      mm_iu_ierat_pid2           => mm_iu_ierat_pid2,
      mm_iu_ierat_pid3           => mm_iu_ierat_pid3,
      mm_iu_ierat_rel_data       => mm_iu_ierat_rel_data,
      mm_iu_ierat_rel_val        => mm_iu_ierat_rel_val,
      mm_iu_ierat_snoop_attr     => mm_iu_ierat_snoop_attr,
      mm_iu_ierat_snoop_coming   => mm_iu_ierat_snoop_coming,
      mm_iu_ierat_snoop_val      => mm_iu_ierat_snoop_val,
      mm_iu_ierat_snoop_vpn      => mm_iu_ierat_snoop_vpn,
      slowspr_addr_out           => mm_iu_slowspr_addr,
      slowspr_data_out           => mm_iu_slowspr_data,
      slowspr_done_out           => mm_iu_slowspr_done,
      slowspr_etid_out           => mm_iu_slowspr_etid,
      slowspr_rw_out             => mm_iu_slowspr_rw,
      slowspr_val_out            => mm_iu_slowspr_val,
      debug_bus_out              => ac_an_debug_bus_int,    
      trace_triggers_out         => ac_an_trace_triggers, 
      mm_pc_bo_diagout           => mm_pc_bo_diagout_iiu,
      mm_pc_bo_fail              => mm_pc_bo_fail_iiu,
      mm_pc_event_data           => mm_pc_event_data_iiu,
      mm_xu_derat_mmucr0_0       => mm_xu_derat_mmucr0_0,
      mm_xu_derat_mmucr0_1       => mm_xu_derat_mmucr0_1,
      mm_xu_derat_mmucr0_2       => mm_xu_derat_mmucr0_2,
      mm_xu_derat_mmucr0_3       => mm_xu_derat_mmucr0_3,
      mm_xu_derat_mmucr1         => mm_xu_derat_mmucr1,
      mm_xu_derat_pid0           => mm_xu_derat_pid0,
      mm_xu_derat_pid1           => mm_xu_derat_pid1,
      mm_xu_derat_pid2           => mm_xu_derat_pid2,
      mm_xu_derat_pid3           => mm_xu_derat_pid3,
      mm_xu_derat_rel_data       => mm_xu_derat_rel_data,
      mm_xu_derat_rel_val        => mm_xu_derat_rel_val,
      mm_xu_derat_snoop_attr     => mm_xu_derat_snoop_attr,
      mm_xu_derat_snoop_coming   => mm_xu_derat_snoop_coming,
      mm_xu_derat_snoop_val      => mm_xu_derat_snoop_val,
      mm_xu_derat_snoop_vpn      => mm_xu_derat_snoop_vpn,
      mm_xu_eratmiss_done        => mm_xu_eratmiss_done,
      mm_xu_esr_pt               => mm_xu_esr_pt,
      mm_xu_esr_data             => mm_xu_esr_data,
      mm_xu_esr_epid             => mm_xu_esr_epid,
      mm_xu_esr_st               => mm_xu_esr_st,
      mm_xu_ex3_flush_req        => mm_xu_ex3_flush_req,
      mm_xu_hold_done            => mm_xu_hold_done,
      mm_xu_hold_req             => mm_xu_hold_req,
      mm_xu_hv_priv              => mm_xu_hv_priv,
      mm_xu_illeg_instr          => mm_xu_illeg_instr,
      mm_xu_local_snoop_reject   => mm_xu_local_snoop_reject,
      mm_xu_lrat_miss            => mm_xu_lrat_miss,
      mm_xu_lsu_addr             => mm_xu_lsu_addr,
      mm_xu_lsu_lpid             => mm_xu_lsu_lpid,
      mm_xu_lsu_lpidr            => mm_xu_lsu_lpidr,
      mm_xu_lsu_gs               => mm_xu_lsu_gs,
      mm_xu_lsu_ind              => mm_xu_lsu_ind,
      mm_xu_lsu_lbit             => mm_xu_lsu_lbit,
      mm_xu_lsu_req              => mm_xu_lsu_req,
      mm_xu_lsu_ttype            => mm_xu_lsu_ttype,
      mm_xu_lsu_u                => mm_xu_lsu_u,
      mm_xu_lsu_wimge            => mm_xu_lsu_wimge,
      mm_xu_pt_fault             => mm_xu_pt_fault,
      mm_xu_quiesce              => mm_xu_quiesce,
      mm_xu_tlb_inelig           => mm_xu_tlb_inelig,
      mm_xu_tlb_miss             => mm_xu_tlb_miss,
      mm_xu_tlb_multihit_err     => mm_xu_tlb_multihit_err,
      mm_xu_tlb_par_err          => mm_xu_tlb_par_err,
      mm_xu_lru_par_err          => mm_xu_lru_par_err,

      an_ac_reld_data_coming      => an_ac_reld_data_coming,
      an_ac_reld_l1_dump	  => an_ac_reld_l1_dump,    
      an_ac_grffence_en_dc        => an_ac_camfence_en_dc, 
      an_ac_stcx_complete         => an_ac_stcx_complete, 
      an_ac_abist_mode_dc         => an_ac_abist_mode_dc, 
      an_ac_abist_start_test      => an_ac_abist_start_test, 
      an_ac_atpg_en_dc	          => an_ac_atpg_en_dc, 
      an_ac_ccflush_dc	          => an_ac_ccflush_dc, 
      an_ac_reset_1_complete      => an_ac_reset_1_complete,     
      an_ac_reset_2_complete      => an_ac_reset_2_complete,     
      an_ac_reset_3_complete      => an_ac_reset_3_complete,     
      an_ac_reset_wd_complete     => an_ac_reset_wd_complete,
      an_ac_debug_stop	          => an_ac_debug_stop, 
      an_ac_lbist_en_dc	          => an_ac_lbist_en_dc,   
      an_ac_pm_thread_stop        => an_ac_pm_thread_stop,  
      an_ac_regf_scan_in	  => an_ac_regf_scan_in,      
      an_ac_scan_diag_dc	  => an_ac_scan_diag_dc,      
      an_ac_scan_dis_dc_b         => an_ac_scan_dis_dc_b,  
      an_ac_scom_cch  	          => an_ac_scom_cch, 
      an_ac_scom_dch  	          => an_ac_scom_dch, 
      an_ac_checkstop 	          => an_ac_checkstop, 
      an_ac_back_inv_omm	        => an_ac_back_inv_omm,
      an_ac_back_inv_addr_omm           => an_ac_back_inv_addr_omm,   
      an_ac_back_inv_target_omm_iua     => an_ac_back_inv_target_omm_iua,
      an_ac_back_inv_target_omm_iub     => an_ac_back_inv_target_omm_iub,
      an_ac_reld_core_tag_omm           => an_ac_reld_core_tag_omm, 
      an_ac_reld_data_omm 	        => an_ac_reld_data_omm, 
      an_ac_reld_data_vld_omm           => an_ac_reld_data_vld_omm,    
      an_ac_reld_ecc_err_omm	        => an_ac_reld_ecc_err_omm,	       
      an_ac_reld_ecc_err_ue_omm         => an_ac_reld_ecc_err_ue_omm,
      an_ac_reld_qw_omm	                => an_ac_reld_qw_omm, 
      an_ac_reld_ditc_omm 	        => an_ac_reld_ditc_omm, 
      an_ac_reld_crit_qw_omm	        => an_ac_reld_crit_qw_omm,	       
      an_ac_reld_data_coming_omm        => an_ac_reld_data_coming_omm,
      an_ac_reld_l1_dump_omm	        => an_ac_reld_l1_dump_omm,     
      an_ac_grffence_en_dc_omm          => an_ac_camfence_en_dc_omm, 
      an_ac_stcx_complete_omm           => an_ac_stcx_complete_omm, 
      an_ac_abist_mode_dc_omm           => an_ac_abist_mode_dc_omm, 
      an_ac_abist_start_test_omm        => an_ac_abist_start_test_omm, 
      an_ac_abst_scan_in_omm_iu	        => an_ac_abst_scan_in_omm_iu,
      an_ac_abst_scan_in_omm_xu	        => an_ac_abst_scan_in_omm_xu,
      an_ac_atpg_en_dc_omm	        => an_ac_atpg_en_dc_omm,   
      an_ac_bcfg_scan_in_omm_bit1	=> an_ac_bcfg_scan_in_omm_bit1,
      an_ac_bcfg_scan_in_omm_bit3	=> an_ac_bcfg_scan_in_omm_bit3,
      an_ac_bcfg_scan_in_omm_bit4	=> an_ac_bcfg_scan_in_omm_bit4,
      an_ac_lbist_ary_wrt_thru_dc_omm   => an_ac_lbist_ary_wrt_thru_dc_omm,
      an_ac_ccflush_dc_omm	        => an_ac_ccflush_dc_omm, 
      an_ac_reset_1_complete_omm        => an_ac_reset_1_complete_omm,    
      an_ac_reset_2_complete_omm        => an_ac_reset_2_complete_omm,    
      an_ac_reset_3_complete_omm        => an_ac_reset_3_complete_omm,    
      an_ac_reset_wd_complete_omm       => an_ac_reset_wd_complete_omm,    
      an_ac_dcfg_scan_in_omm	        => an_ac_dcfg_scan_in_omm,	       
      an_ac_debug_stop_omm	        => an_ac_debug_stop_omm,     
      an_ac_func_scan_in_omm_iua	=> an_ac_func_scan_in_omm_iua,
      an_ac_func_scan_in_omm_iub	=> an_ac_func_scan_in_omm_iub,
      an_ac_func_scan_in_omm_xu	        => an_ac_func_scan_in_omm_xu,
      an_ac_lbist_en_dc_omm	        => an_ac_lbist_en_dc_omm,       
      an_ac_pm_thread_stop_omm          => an_ac_pm_thread_stop_omm,  
      an_ac_regf_scan_in_omm	        => an_ac_regf_scan_in_omm,       
      an_ac_scan_diag_dc_omm	        => an_ac_scan_diag_dc_omm,       
      an_ac_scan_dis_dc_b_omm           => an_ac_scan_dis_dc_b_omm,  
      an_ac_scom_cch_omm  	        => an_ac_scom_cch_omm, 
      an_ac_scom_dch_omm  	        => an_ac_scom_dch_omm, 
      an_ac_checkstop_omm 	        => an_ac_checkstop_omm, 
      ac_an_abst_scan_out_imm_iu      => ac_an_abst_scan_out_imm_iu,
      ac_an_abst_scan_out_imm_xu      => ac_an_abst_scan_out_imm_xu,
      ac_an_bcfg_scan_out_imm	      => ac_an_bcfg_scan_out_imm,    
      ac_an_dcfg_scan_out_imm	      => ac_an_dcfg_scan_out_imm,    
      ac_an_func_scan_out_imm_iua     => ac_an_func_scan_out_imm_iua, 
      ac_an_func_scan_out_imm_iub     => ac_an_func_scan_out_imm_iub, 
      ac_an_func_scan_out_imm_xu      => ac_an_func_scan_out_imm_xu, 
      ac_an_reld_ditc_pop_imm	      => ac_an_reld_ditc_pop_imm,	    
      ac_an_power_managed_imm	      => ac_an_power_managed_imm,	    
      ac_an_rvwinkle_mode_imm	      => ac_an_rvwinkle_mode_imm,	    
      ac_an_fu_bypass_events_imm      => ac_an_fu_bypass_events_imm,
      ac_an_iu_bypass_events_imm      => ac_an_iu_bypass_events_imm,
      ac_an_mm_bypass_events_imm      => ac_an_mm_bypass_events_imm, 
      ac_an_lsu_bypass_events_imm     => ac_an_lsu_bypass_events_imm, 
      ac_an_event_bus_imm 	      => ac_an_event_bus_imm, 
      ac_an_pm_thread_running_imm     => ac_an_pm_thread_running_imm,
      ac_an_recov_err_imm 	      => ac_an_recov_err_imm, 
      ac_an_regf_scan_out_imm	      => ac_an_regf_scan_out_imm,	    
      ac_an_scom_cch_imm  	      => ac_an_scom_cch_imm,  
      ac_an_scom_dch_imm  	      => ac_an_scom_dch_imm,  
      ac_an_special_attn_imm	      => ac_an_special_attn_imm,	    
      ac_an_checkstop_imm 	      => ac_an_checkstop_imm,   
      ac_an_local_checkstop_imm	      => ac_an_local_checkstop_imm,
      ac_an_trace_error_imm	      => ac_an_trace_error_imm,	    
      ac_an_abst_scan_out	      => ac_an_abst_scan_out,
      ac_an_bcfg_scan_out	      => ac_an_bcfg_scan_out, 
      ac_an_dcfg_scan_out	      => ac_an_dcfg_scan_out, 
      ac_an_func_scan_out	      => ac_an_func_scan_out, 
      ac_an_reld_ditc_pop	      => ac_an_reld_ditc_pop, 
      ac_an_power_managed	      => ac_an_power_managed, 
      ac_an_rvwinkle_mode	      => ac_an_rvwinkle_mode, 
      ac_an_fu_bypass_events          => ac_an_fu_bypass_events,  
      ac_an_iu_bypass_events          => ac_an_iu_bypass_events,  
      ac_an_mm_bypass_events          => ac_an_mm_bypass_events,  
      ac_an_lsu_bypass_events         => ac_an_lsu_bypass_events,
      ac_an_event_bus 	              => ac_an_event_bus, 
      ac_an_pm_thread_running         => ac_an_pm_thread_running, 
      ac_an_recov_err 	              => ac_an_recov_err, 
      ac_an_regf_scan_out	      => ac_an_regf_scan_out, 
      ac_an_scom_cch  	              => ac_an_scom_cch, 
      ac_an_scom_dch  	              => ac_an_scom_dch, 
      ac_an_special_attn	      => ac_an_special_attn, 
      ac_an_checkstop 	              => ac_an_checkstop, 
      ac_an_local_checkstop	      => ac_an_local_checkstop,  
      ac_an_trace_error	              => ac_an_trace_error, 
      an_ac_dcr_act	              => an_ac_dcr_act,
      an_ac_dcr_val	              => an_ac_dcr_val,
      an_ac_dcr_read  	              => an_ac_dcr_read,
      an_ac_dcr_etid                  => an_ac_dcr_etid,
      an_ac_dcr_data  	              => an_ac_dcr_data, 
      an_ac_dcr_done  	              => an_ac_dcr_done, 
      an_ac_crit_interrupt            => an_ac_crit_interrupt,	 
      an_ac_ext_interrupt             => an_ac_ext_interrupt, 
      an_ac_flh2l2_gate	              => an_ac_flh2l2_gate, 
      an_ac_icbi_ack  	              => an_ac_icbi_ack, 
      an_ac_icbi_ack_thread           => an_ac_icbi_ack_thread,   
      an_ac_req_ld_pop	              => an_ac_req_ld_pop, 
      an_ac_req_spare_ctrl_a1         => an_ac_req_spare_ctrl_a1,
      an_ac_req_st_gather             => an_ac_req_st_gather,
      an_ac_req_st_pop	              => an_ac_req_st_pop,
      an_ac_req_st_pop_thrd           => an_ac_req_st_pop_thrd,   
      an_ac_reservation_vld           => an_ac_reservation_vld,   
      an_ac_sleep_en  	              => an_ac_sleep_en,
      an_ac_stcx_pass 	              => an_ac_stcx_pass,
      an_ac_sync_ack  	              => an_ac_sync_ack,
      an_ac_ary_nsl_thold_7           => an_ac_ary_nsl_thold_7,   
      an_ac_ccenable_dc	              => an_ac_ccenable_dc,
      an_ac_coreid	              => an_ac_coreid, 
      an_ac_external_mchk             => an_ac_external_mchk,
      an_ac_fce_7	              => an_ac_fce_7,
      an_ac_func_nsl_thold_7          => an_ac_func_nsl_thold_7,
      an_ac_func_sl_thold_7           => an_ac_func_sl_thold_7,
      an_ac_gsd_test_enable_dc        => an_ac_gsd_test_enable_dc,
      an_ac_gsd_test_acmode_dc        => an_ac_gsd_test_acmode_dc,
      an_ac_gptr_scan_in	      => an_ac_gptr_scan_in,
      an_ac_hang_pulse	              => an_ac_hang_pulse,
      an_ac_lbist_ac_mode_dc          => an_ac_lbist_ac_mode_dc,  
      an_ac_lbist_ip_dc	              => an_ac_lbist_ip_dc,
      an_ac_malf_alert	              => an_ac_malf_alert,
      an_ac_perf_interrupt	      => an_ac_perf_interrupt, 
      an_ac_psro_enable_dc	      => an_ac_psro_enable_dc, 
      an_ac_repr_scan_in	      => an_ac_repr_scan_in,
      an_ac_rtim_sl_thold_7	      => an_ac_rtim_sl_thold_7,   
      an_ac_scan_type_dc	      => an_ac_scan_type_dc,
      an_ac_scom_sat_id	              => an_ac_scom_sat_id,
      an_ac_sg_7		      => an_ac_sg_7,
      an_ac_tb_update_enable          => an_ac_tb_update_enable,  
      an_ac_tb_update_pulse	      => an_ac_tb_update_pulse,  
      an_ac_time_scan_in	      => an_ac_time_scan_in, 
      an_ac_crit_interrupt_omm      => an_ac_crit_interrupt_omm,    
      an_ac_ext_interrupt_omm       => an_ac_ext_interrupt_omm,     
      an_ac_flh2l2_gate_omm	    => an_ac_flh2l2_gate_omm,	   
      an_ac_icbi_ack_omm  	    => an_ac_icbi_ack_omm,	   
      an_ac_icbi_ack_thread_omm     => an_ac_icbi_ack_thread_omm,   
      an_ac_req_ld_pop_omm	    => an_ac_req_ld_pop_omm,	   
      an_ac_req_spare_ctrl_a1_omm   => an_ac_req_spare_ctrl_a1_omm, 
      an_ac_req_st_gather_omm	    => an_ac_req_st_gather_omm,     
      an_ac_req_st_pop_omm	    => an_ac_req_st_pop_omm,	   
      an_ac_req_st_pop_thrd_omm     => an_ac_req_st_pop_thrd_omm,   
      an_ac_reservation_vld_omm     => an_ac_reservation_vld_omm,   
      an_ac_sleep_en_omm  	    => an_ac_sleep_en_omm,	   
      an_ac_stcx_pass_omm 	    => an_ac_stcx_pass_omm,	   
      an_ac_sync_ack_omm  	    => an_ac_sync_ack_omm,	   
      an_ac_ary_nsl_thold_7_omm     => an_ac_ary_nsl_thold_7_omm,   
      an_ac_ccenable_dc_omm	    => an_ac_ccenable_dc_iiu,	   
      an_ac_coreid_omm	            => an_ac_coreid_omm, 	   
      an_ac_external_mchk_omm       => an_ac_external_mchk_omm,     
      an_ac_fce_7_omm	            => an_ac_fce_7_omm,  	   
      an_ac_func_nsl_thold_7_omm    => an_ac_func_nsl_thold_7_omm,
      an_ac_func_sl_thold_7_omm     => an_ac_func_sl_thold_7_omm,   
      an_ac_gsd_test_enable_dc_omm  => an_ac_gsd_test_enable_dc_omm,
      an_ac_gsd_test_acmode_dc_omm  => an_ac_gsd_test_acmode_dc_omm,
      an_ac_gptr_scan_in_omm	    => an_ac_gptr_scan_in_omm,	   
      an_ac_hang_pulse_omm	    => an_ac_hang_pulse_omm,	   
      an_ac_lbist_ac_mode_dc_omm    => an_ac_lbist_ac_mode_dc_omm,  
      an_ac_lbist_ip_dc_omm	    => an_ac_lbist_ip_dc_omm,	   
      an_ac_malf_alert_omm	    => an_ac_malf_alert_omm,	   
      an_ac_perf_interrupt_omm      => an_ac_perf_interrupt_omm,    
      an_ac_psro_enable_dc_omm      => an_ac_psro_enable_dc_omm,    
      an_ac_repr_scan_in_omm	    => an_ac_repr_scan_in_omm,	   
      an_ac_rtim_sl_thold_7_omm     => an_ac_rtim_sl_thold_7_omm,   
      an_ac_scan_type_dc_omm	    => an_ac_scan_type_dc_omm,	   
      an_ac_scom_sat_id_omm	    => an_ac_scom_sat_id_omm,	   
      an_ac_sg_7_omm		    => an_ac_sg_7_omm,		   
      an_ac_tb_update_enable_omm    => an_ac_tb_update_enable_omm,  
      an_ac_tb_update_pulse_omm     => an_ac_tb_update_pulse_omm,   
      an_ac_time_scan_in_omm	    => an_ac_time_scan_in_omm,	   

      ac_an_box_empty_imm 	   => ac_an_box_empty_imm,
      ac_an_machine_check_imm      => ac_an_machine_check_imm, 
      ac_an_req_imm		   => ac_an_req_imm, 
      ac_an_req_endian_imm	   => ac_an_req_endian_imm, 
      ac_an_req_ld_core_tag_imm    => ac_an_req_ld_core_tag_imm,  
      ac_an_req_ld_xfr_len_imm     => ac_an_req_ld_xfr_len_imm,  
      ac_an_req_pwr_token_imm      => ac_an_req_pwr_token_imm, 
      ac_an_req_ra_imm	           => ac_an_req_ra_imm, 
      ac_an_req_spare_ctrl_a0_imm  => ac_an_req_spare_ctrl_a0_imm,
      ac_an_req_thread_imm	   => ac_an_req_thread_imm, 
      ac_an_req_ttype_imm 	   => ac_an_req_ttype_imm, 
      ac_an_req_user_defined_imm   => ac_an_req_user_defined_imm, 
      ac_an_req_wimg_g_imm	   => ac_an_req_wimg_g_imm, 
      ac_an_req_wimg_i_imm	   => ac_an_req_wimg_i_imm, 
      ac_an_req_wimg_m_imm	   => ac_an_req_wimg_m_imm, 
      ac_an_req_wimg_w_imm	   => ac_an_req_wimg_w_imm, 
      ac_an_st_byte_enbl_imm	   => ac_an_st_byte_enbl_imm, 
      ac_an_st_data_imm	           => ac_an_st_data_imm, 
      ac_an_st_data_pwr_token_imm  => ac_an_st_data_pwr_token_imm,
      ac_an_abist_done_dc_imm	   => ac_an_abist_done_dc_oiu, 
      ac_an_debug_trigger_imm	   => ac_an_debug_trigger_imm, 
      ac_an_psro_ringsig_imm	   => ac_an_psro_ringsig_oiu,
      ac_an_reset_1_request_imm    => ac_an_reset_1_request_imm,  
      ac_an_reset_2_request_imm    => ac_an_reset_2_request_imm,  
      ac_an_reset_3_request_imm    => ac_an_reset_3_request_imm,  
      ac_an_reset_wd_request_imm   => ac_an_reset_wd_request_imm, 

      ac_an_box_empty 	         => ac_an_box_empty,
      ac_an_machine_check        => ac_an_machine_check, 
      ac_an_req		         => ac_an_req, 
      ac_an_req_endian	         => ac_an_req_endian, 
      ac_an_req_ld_core_tag      => ac_an_req_ld_core_tag,   
      ac_an_req_ld_xfr_len       => ac_an_req_ld_xfr_len, 
      ac_an_req_pwr_token        => ac_an_req_pwr_token, 
      ac_an_req_ra	         => ac_an_req_ra, 
      ac_an_req_spare_ctrl_a0    => ac_an_req_spare_ctrl_a0,
      ac_an_req_thread	         => ac_an_req_thread,
      ac_an_req_ttype    	 => ac_an_req_ttype,
      ac_an_req_user_defined     => ac_an_req_user_defined,  
      ac_an_req_wimg_g	         => ac_an_req_wimg_g,
      ac_an_req_wimg_i	         => ac_an_req_wimg_i,
      ac_an_req_wimg_m	         => ac_an_req_wimg_m,
      ac_an_req_wimg_w	         => ac_an_req_wimg_w,
      ac_an_st_byte_enbl  => ac_an_st_byte_enbl,
      ac_an_st_data => ac_an_st_data,      
      ac_an_st_data_pwr_token    => ac_an_st_data_pwr_token, 
      ac_an_abist_done_dc	 => ac_an_abist_done_dc,
      ac_an_debug_trigger	 => ac_an_debug_trigger,
      ac_an_psro_ringsig	 => ac_an_psro_ringsig,
      ac_an_reset_1_request	 => ac_an_reset_1_request,  
      ac_an_reset_2_request	 => ac_an_reset_2_request,  
      ac_an_reset_3_request	 => ac_an_reset_3_request,  
      ac_an_reset_wd_request     => ac_an_reset_wd_request,  
      ac_an_dcr_act		 => ac_an_dcr_act,
      ac_an_dcr_val		 => ac_an_dcr_val,
      ac_an_dcr_read  	         => ac_an_dcr_read,
      ac_an_dcr_user      	 => ac_an_dcr_user,
      ac_an_dcr_etid  	         => ac_an_dcr_etid,
      ac_an_dcr_addr  	         => ac_an_dcr_addr,
      ac_an_dcr_data	         => ac_an_dcr_data,
      
      debug_bus_out_int          => debug_bus_out_int,

 bg_ac_an_func_scan_ns_imm          => bg_ac_an_func_scan_ns_q,	     
 bg_ac_an_abst_scan_ns_imm          => bg_ac_an_abst_scan_ns_q,	     
 bg_ac_an_func_scan_ns              => bg_ac_an_func_scan_ns,	     
 bg_ac_an_abst_scan_ns              => bg_ac_an_abst_scan_ns,	     
 bg_pc_l1p_abist_di_0_imm           => bg_pc_l1p_abist_di_0_q,	     
 bg_pc_l1p_abist_g8t1p_renb_0_imm   => bg_pc_l1p_abist_g8t1p_renb_0_q,  
 bg_pc_l1p_abist_g8t_bw_0_imm       => bg_pc_l1p_abist_g8t_bw_0_q,      
 bg_pc_l1p_abist_g8t_bw_1_imm       => bg_pc_l1p_abist_g8t_bw_1_q,      
 bg_pc_l1p_abist_g8t_dcomp_imm      => bg_pc_l1p_abist_g8t_dcomp_q,     
 bg_pc_l1p_abist_g8t_wenb_imm       => bg_pc_l1p_abist_g8t_wenb_q,      
 bg_pc_l1p_abist_raddr_0_imm        => bg_pc_l1p_abist_raddr_0_q,       
 bg_pc_l1p_abist_waddr_0_imm        => bg_pc_l1p_abist_waddr_0_q,       
 bg_pc_l1p_abist_wl128_comp_ena_imm => bg_pc_l1p_abist_wl128_comp_ena_q,
 bg_pc_l1p_abist_wl32_comp_ena_imm  => bg_pc_l1p_abist_wl32_comp_ena_q, 
 bg_pc_l1p_abist_di_0               => bg_pc_l1p_abist_di_0, 	     
 bg_pc_l1p_abist_g8t1p_renb_0       => bg_pc_l1p_abist_g8t1p_renb_0,      
 bg_pc_l1p_abist_g8t_bw_0           => bg_pc_l1p_abist_g8t_bw_0,	     
 bg_pc_l1p_abist_g8t_bw_1           => bg_pc_l1p_abist_g8t_bw_1,	     
 bg_pc_l1p_abist_g8t_dcomp          => bg_pc_l1p_abist_g8t_dcomp,	     
 bg_pc_l1p_abist_g8t_wenb           => bg_pc_l1p_abist_g8t_wenb,	     
 bg_pc_l1p_abist_raddr_0            => bg_pc_l1p_abist_raddr_0,	     
 bg_pc_l1p_abist_waddr_0            => bg_pc_l1p_abist_waddr_0,	     
 bg_pc_l1p_abist_wl128_comp_ena     => bg_pc_l1p_abist_wl128_comp_ena,   
 bg_pc_l1p_abist_wl32_comp_ena      => bg_pc_l1p_abist_wl32_comp_ena,     
 bg_pc_l1p_gptr_sl_thold_2_imm      => bg_pc_l1p_gptr_sl_thold_2_imm,     
 bg_pc_l1p_time_sl_thold_2_imm      => bg_pc_l1p_time_sl_thold_2_imm,     
 bg_pc_l1p_repr_sl_thold_2_imm      => bg_pc_l1p_repr_sl_thold_2_imm,     
 bg_pc_l1p_abst_sl_thold_2_imm      => bg_pc_l1p_abst_sl_thold_2_imm,     
 bg_pc_l1p_func_sl_thold_2_imm      => bg_pc_l1p_func_sl_thold_2_imm,     
 bg_pc_l1p_func_slp_sl_thold_2_imm  => bg_pc_l1p_func_slp_sl_thold_2_imm, 
 bg_pc_l1p_bolt_sl_thold_2_imm      => bg_pc_l1p_bolt_sl_thold_2_imm,    
 bg_pc_l1p_ary_nsl_thold_2_imm      => bg_pc_l1p_ary_nsl_thold_2_imm,     
 bg_pc_l1p_sg_2_imm                 => bg_pc_l1p_sg_2_imm,		     
 bg_pc_l1p_fce_2_imm                => bg_pc_l1p_fce_2_imm,  	     
 bg_pc_l1p_bo_enable_2_imm          => bg_pc_l1p_bo_enable_2_imm,	     
 bg_pc_l1p_gptr_sl_thold_2          => bg_pc_l1p_gptr_sl_thold_2,	     
 bg_pc_l1p_time_sl_thold_2          => bg_pc_l1p_time_sl_thold_2,	     
 bg_pc_l1p_repr_sl_thold_2          => bg_pc_l1p_repr_sl_thold_2,	     
 bg_pc_l1p_abst_sl_thold_2          => bg_pc_l1p_abst_sl_thold_2,	     
 bg_pc_l1p_func_sl_thold_2          => bg_pc_l1p_func_sl_thold_2,	     
 bg_pc_l1p_func_slp_sl_thold_2      => bg_pc_l1p_func_slp_sl_thold_2,     
 bg_pc_l1p_bolt_sl_thold_2          => bg_pc_l1p_bolt_sl_thold_2,	     
 bg_pc_l1p_ary_nsl_thold_2          => bg_pc_l1p_ary_nsl_thold_2,	     
 bg_pc_l1p_sg_2                     => bg_pc_l1p_sg_2,		     
 bg_pc_l1p_fce_2                    => bg_pc_l1p_fce_2,		     
 bg_pc_l1p_bo_enable_2              => bg_pc_l1p_bo_enable_2,	     
 bg_pc_bo_unload_imm                => bg_pc_bo_unload_oiu,  	     
 bg_pc_bo_load_imm                  => bg_pc_bo_load_oiu,		     
 bg_pc_bo_repair_imm                => bg_pc_bo_repair_oiu,  	     
 bg_pc_bo_reset_imm                 => bg_pc_bo_reset_oiu,		     
 bg_pc_bo_shdata_imm                => bg_pc_bo_shdata_oiu,  	     
 bg_pc_bo_select_imm                => bg_pc_bo_select_oiu,  	     
 bg_pc_l1p_ccflush_dc_imm           => bg_pc_l1p_ccflush_dc_oiu,	     
 bg_pc_l1p_abist_ena_dc_imm         => bg_pc_l1p_abist_ena_dc_oiu,	     
 bg_pc_l1p_abist_raw_dc_b_imm       => bg_pc_l1p_abist_raw_dc_b_oiu,      
 bg_pc_bo_unload                    => bg_pc_bo_unload,		     
 bg_pc_bo_load                      => bg_pc_bo_load,		     
 bg_pc_bo_repair                    => bg_pc_bo_repair,		     
 bg_pc_bo_reset                     => bg_pc_bo_reset,		     
 bg_pc_bo_shdata                    => bg_pc_bo_shdata,		     
 bg_pc_bo_select                    => bg_pc_bo_select,		     
 bg_pc_l1p_ccflush_dc               => bg_pc_l1p_ccflush_dc, 	     
 bg_pc_l1p_abist_ena_dc             => bg_pc_l1p_abist_ena_dc,	     
 bg_pc_l1p_abist_raw_dc_b           => bg_pc_l1p_abist_raw_dc_b,	     
 bg_an_ac_func_scan_sn              => bg_an_ac_func_scan_sn,    
 bg_an_ac_abst_scan_sn              => bg_an_ac_abst_scan_sn,    
 bg_an_ac_func_scan_sn_omm          => bg_an_ac_func_scan_sn_omm,
 bg_an_ac_abst_scan_sn_omm          => bg_an_ac_abst_scan_sn_omm,
 bg_pc_bo_fail                      => bg_pc_bo_fail,	    
 bg_pc_bo_diagout                   => bg_pc_bo_diagout,	    
 bg_pc_bo_fail_omm                  => bg_pc_bo_fail_omm,	    
 bg_pc_bo_diagout_omm               => bg_pc_bo_diagout_omm,     
 xu_mm_xucr4_mmu_mchk               => xu_mm_xucr4_mmu_mchk,      

      gnd                        => gnd,
      vcs                        => vcs,
      vdd                        => vdd
   ); 

a_pcq: entity work.pcq
   generic map(expand_type => expand_type, regmode => regmode)
   port map (
      abst_scan_in                 => iu_pc_abst_scan_out,
      bcfg_scan_in                 => rp_pc_bcfg_scan_out_q,
      ccfg_scan_in                 => iu_pc_ccfg_scan_out,
      dcfg_scan_in                 => rp_pc_dcfg_scan_out_q,
      func_scan_in                 => rp_pc_func_scan_in_q(0 to 1),
      gptr_scan_in                 => iu_pc_gptr_scan_out,
      bx_pc_err_inbox_ue           => bx_pc_err_inbox_ue_ofu,
      bx_pc_err_outbox_ue          => bx_pc_err_outbox_ue_ofu,
      fu_pc_event_data             => fu_pc_event_data,
      fu_pc_ram_data               => fu_pc_ram_data,
      fu_pc_ram_done               => fu_pc_ram_done,
      iu_pc_err_icache_parity      => iu_pc_err_icache_parity,
      iu_pc_err_icachedir_multihit => iu_pc_err_icachedir_multihit,
      iu_pc_err_icachedir_parity   => iu_pc_err_icachedir_parity,
      fu_pc_err_regfile_parity     => fu_pc_err_regfile_parity,
      fu_pc_err_regfile_ue         => fu_pc_err_regfile_ue,
      iu_pc_err_ucode_illegal      => iu_pc_err_ucode_illegal,
      iu_pc_event_data             => iu_pc_event_data,
      slowspr_addr_in              => iu_pc_slowspr_addr,
      slowspr_data_in              => iu_pc_slowspr_data,
      slowspr_done_in              => iu_pc_slowspr_done,
      slowspr_etid_in              => iu_pc_slowspr_etid,
      slowspr_rw_in                => iu_pc_slowspr_rw,
      slowspr_val_in               => iu_pc_slowspr_val,
      xu_pc_err_mcsr_summary       => xu_pc_err_mcsr_summary_ofu,      
      xu_pc_err_ierat_parity       => xu_pc_err_ierat_parity_ofu,      
      xu_pc_err_derat_parity       => xu_pc_err_derat_parity_ofu,      
      xu_pc_err_tlb_parity         => xu_pc_err_tlb_parity_ofu,        
      xu_pc_err_tlb_lru_parity     => xu_pc_err_tlb_lru_parity_ofu,    
      xu_pc_err_ierat_multihit     => xu_pc_err_ierat_multihit_ofu,    
      xu_pc_err_derat_multihit     => xu_pc_err_derat_multihit_ofu,    
      xu_pc_err_tlb_multihit       => xu_pc_err_tlb_multihit_ofu,      
      xu_pc_err_ext_mchk           => xu_pc_err_ext_mchk_ofu,          
      xu_pc_err_ditc_overrun       => xu_pc_err_ditc_overrun_ofu,
      xu_pc_err_local_snoop_reject => xu_pc_err_local_snoop_reject_ofu,
      mm_pc_event_data             => mm_pc_event_data_oiu,
      nclk                         => a2_nclk,
      an_ac_rtim_sl_thold_6        => rp_pc_rtim_sl_thold_6,           
      an_ac_func_sl_thold_6        => rp_pc_func_sl_thold_6,           
      an_ac_func_nsl_thold_6       => rp_pc_func_nsl_thold_6,         
      an_ac_ary_nsl_thold_6        => rp_pc_ary_nsl_thold_6,           
      an_ac_sg_6                   => rp_pc_sg_6,                                 
      an_ac_fce_6                  => rp_pc_fce_6,                               
      an_ac_abist_start_test       => rp_pc_abist_start_test_q,
      an_ac_ccenable_dc            => an_ac_ccenable_dc_oiu,
      an_ac_ccflush_dc             => an_ac_ccflush_dc_oiu,
      an_ac_debug_stop             => rp_pc_debug_stop_q,
      an_ac_gsd_test_enable_dc     => an_ac_gsd_test_enable_dc_oiu,
      an_ac_gsd_test_acmode_dc     => an_ac_gsd_test_acmode_dc_oiu,
      an_ac_lbist_en_dc            => an_ac_lbist_en_dc_oiu,
      an_ac_lbist_ip_dc            => an_ac_lbist_ip_dc_oiu,    
      an_ac_lbist_ac_mode_dc       => an_ac_lbist_ac_mode_dc_oiu,  
      an_ac_abist_mode_dc          => an_ac_abist_mode_dc_oiu, 
      an_ac_malf_alert             => an_ac_malf_alert_oiu,        
      an_ac_pm_thread_stop         => rp_pc_pm_thread_stop_q,
      an_ac_psro_enable_dc         => an_ac_psro_enable_dc_oiu,
      an_ac_reset_1_complete       => rp_pc_reset_1_complete_q,
      an_ac_reset_2_complete       => rp_pc_reset_2_complete_q,
      an_ac_reset_3_complete       => rp_pc_reset_3_complete_q,
      an_ac_reset_wd_complete      => rp_pc_reset_wd_complete_q,
      an_ac_scan_diag_dc           => an_ac_scan_diag_dc_oiu,
      an_ac_scan_dis_dc_b          => an_ac_scan_dis_dc_b_oiu,
      an_ac_scan_type_dc           => an_ac_scan_type_dc_oiu,
      an_ac_scom_cch               => rp_pc_scom_cch_q,
      an_ac_scom_dch               => rp_pc_scom_dch_q,
      an_ac_scom_sat_id            => an_ac_scom_sat_id_oiu,
      an_ac_checkstop              => rp_pc_checkstop_q,
      debug_bus_in                 => fu_pc_debug_data,
      trace_triggers_in            => fu_pc_trigger_data,
      xu_pc_err_attention_instr    => xu_pc_err_attention_instr_ofu,
      xu_pc_err_dcache_parity      => xu_pc_err_dcache_parity_ofu,
      xu_pc_err_dcachedir_parity   => xu_pc_err_dcachedir_parity_ofu,
      xu_pc_err_dcachedir_multihit => xu_pc_err_dcachedir_multihit_ofu,
      xu_pc_err_debug_event        => xu_pc_err_debug_event_ofu,
      bx_pc_err_inbox_ecc          => bx_pc_err_inbox_ecc_ofu,
      xu_pc_err_invld_reld         => xu_pc_err_invld_reld_ofu,
      xu_pc_err_l2intrf_ecc        => xu_pc_err_l2intrf_ecc_ofu,
      xu_pc_err_l2intrf_ue         => xu_pc_err_l2intrf_ue_ofu,
      xu_pc_err_l2credit_overrun   => xu_pc_err_l2credit_overrun_ofu,
      xu_pc_err_llbust_attempt     => xu_pc_err_llbust_attempt_ofu,
      xu_pc_err_llbust_failed      => xu_pc_err_llbust_failed_ofu,
      xu_pc_err_nia_miscmpr        => xu_pc_err_nia_miscmpr_ofu,
      bx_pc_err_outbox_ecc         => bx_pc_err_outbox_ecc_ofu,
      xu_pc_err_regfile_parity     => xu_pc_err_regfile_parity_ofu,
      xu_pc_err_regfile_ue         => xu_pc_err_regfile_ue_ofu,
      xu_pc_err_sprg_ecc           => xu_pc_err_sprg_ecc_ofu,
      xu_pc_err_sprg_ue            => xu_pc_err_sprg_ue_ofu,
      xu_pc_err_wdt_reset          => xu_pc_err_wdt_reset_ofu,
      xu_pc_event_data             => xu_pc_event_data_ofu,
      lsu_pc_event_data            => xu_pc_lsu_event_data_ofu,
      ac_pc_trace_to_perfcntr      => rp_pc_trace_to_perfcntr_q,       
      xu_pc_ram_data               => xu_pc_ram_data_ofu,
      xu_pc_ram_done               => xu_pc_ram_done_ofu,
      xu_pc_ram_interrupt          => xu_pc_ram_interrupt_ofu,
      xu_pc_running                => xu_pc_running_ofu,
      xu_pc_spr_ccr0_pme           => xu_pc_spr_ccr0_pme_ofu,
      xu_pc_spr_ccr0_we            => xu_pc_spr_ccr0_we_ofu,
      xu_pc_step_done              => xu_pc_step_done_ofu,
      xu_pc_stop_dbg_event         => xu_pc_stop_dbg_event_ofu,
      an_ac_bo_enable            => an_ac_bo_enable,     
      an_ac_bo_go                => an_ac_bo_go,         
      an_ac_bo_cntlclk           => an_ac_bo_cntlclk,    
      an_ac_bo_ccflush           => an_ac_bo_ccflush,    
      an_ac_bo_reset             => an_ac_bo_reset,      
      an_ac_bo_data              => an_ac_bo_data,       
      an_ac_bo_shcntl            => an_ac_bo_shcntl,     
      an_ac_bo_shdata            => an_ac_bo_shdata,     
      an_ac_bo_exe               => an_ac_bo_exe,        
      an_ac_bo_sysrepair         => an_ac_bo_sysrepair,  
      an_ac_bo_donein            => an_ac_bo_donein,     
      an_ac_bo_sdin              => an_ac_bo_sdin,       
      an_ac_bo_waitin            => an_ac_bo_waitin,     
      an_ac_bo_failin            => an_ac_bo_failin,     
      an_ac_bo_fcshdata          => an_ac_bo_fcshdata,   
      an_ac_bo_fcreset           => an_ac_bo_fcreset,   
      ac_an_bo_doneout           => ac_an_bo_doneout,    
      ac_an_bo_sdout             => ac_an_bo_sdout,      
      ac_an_bo_diagloopout       => ac_an_bo_diagloopout,
      ac_an_bo_waitout           => ac_an_bo_waitout,    
      ac_an_bo_failout           => ac_an_bo_failout,    
      pc_bx_bolt_sl_thold_3      => pc_bx_bolt_sl_thold_3,
      pc_fu_bolt_sl_thold_3      => pc_fu_bolt_sl_thold_3,
      pc_xu_bolt_sl_thold_3      => pc_xu_bolt_sl_thold_3,
      pc_bx_bo_enable_3          => pc_bx_bo_enable_3,
      pc_bx_bo_unload            => pc_bx_bo_unload,  
      pc_bx_bo_repair            => pc_bx_bo_repair,  
      pc_bx_bo_reset             => pc_bx_bo_reset,   
      pc_bx_bo_shdata            => pc_bx_bo_shdata,  
      pc_bx_bo_select            => pc_bx_bo_select,  
      bx_pc_bo_fail              => bx_pc_bo_fail_ofu,
      bx_pc_bo_diagout           => bx_pc_bo_diagout_ofu, 
      pc_fu_bo_enable_3          => pc_fu_bo_enable_3,
      pc_fu_bo_unload            => pc_fu_bo_unload,  
      pc_fu_bo_load              => pc_fu_bo_load,    
      pc_fu_bo_reset             => pc_fu_bo_reset,   
      pc_fu_bo_shdata            => pc_fu_bo_shdata,  
      pc_fu_bo_select            => pc_fu_bo_select,  
      fu_pc_bo_fail              => fu_pc_bo_fail,    
      fu_pc_bo_diagout           => fu_pc_bo_diagout, 
      pc_iu_bo_enable_4          => pc_iu_bo_enable_4,
      pc_iu_bo_unload            => pc_iu_bo_unload,  
      pc_iu_bo_repair            => pc_iu_bo_repair,  
      pc_iu_bo_reset             => pc_iu_bo_reset,   
      pc_iu_bo_shdata            => pc_iu_bo_shdata,  
      pc_iu_bo_select            => pc_iu_bo_select,  
      iu_pc_bo_fail              => iu_pc_bo_fail,    
      iu_pc_bo_diagout           => iu_pc_bo_diagout, 
      pc_mm_bo_enable_4          => pc_mm_bo_enable_4_iiu, 
      pc_mm_bo_unload            => pc_mm_bo_unload_iiu,   
      pc_mm_bo_repair            => pc_mm_bo_repair_iiu,   
      pc_mm_bo_reset             => pc_mm_bo_reset_iiu,    
      pc_mm_bo_shdata            => pc_mm_bo_shdata_iiu,   
      pc_mm_bo_select            => pc_mm_bo_select_iiu,   
      mm_pc_bo_fail              => mm_pc_bo_fail_oiu,     
      mm_pc_bo_diagout           => mm_pc_bo_diagout_oiu,  
      pc_xu_bo_enable_3          => pc_xu_bo_enable_3, 
      pc_xu_bo_unload            => pc_xu_bo_unload,   
      pc_xu_bo_load              => pc_xu_bo_load,     
      pc_xu_bo_repair            => pc_xu_bo_repair,   
      pc_xu_bo_reset             => pc_xu_bo_reset,    
      pc_xu_bo_shdata            => pc_xu_bo_shdata,   
      pc_xu_bo_select            => pc_xu_bo_select,   
      xu_pc_bo_fail              => xu_pc_bo_fail_ofu,     
      xu_pc_bo_diagout           => xu_pc_bo_diagout_ofu,  
      ac_an_power_managed        => pc_rp_power_managed,
      ac_an_rvwinkle_mode        => pc_rp_rvwinkle_mode,
      ac_an_fu_bypass_events     => pc_rp_fu_bypass_events,
      ac_an_iu_bypass_events     => pc_rp_iu_bypass_events,
      ac_an_mm_bypass_events     => pc_rp_mm_bypass_events,
      ac_an_lsu_bypass_events    => pc_rp_lsu_bypass_events,
      ac_an_event_bus            => pc_rp_event_bus,
      ac_an_abist_done_dc        => ac_an_abist_done_dc_iiu,
      ac_an_local_checkstop      => pc_rp_local_checkstop,
      ac_an_pm_thread_running    => pc_rp_pm_thread_running,
      ac_an_psro_ringsig         => ac_an_psro_ringsig_iiu,
      ac_an_recov_err            => pc_rp_recov_err,
      ac_an_scom_cch             => pc_rp_scom_cch,
      ac_an_scom_dch             => pc_rp_scom_dch,
      ac_an_special_attn         => pc_rp_special_attn,
      ac_an_checkstop            => pc_rp_checkstop,
      ac_an_trace_error          => pc_rp_trace_error,
      debug_bus_out              => pc_iu_debug_data,
      trace_triggers_out         => pc_iu_trigger_data,
      abst_scan_out              => pc_rp_abst_scan_out,
      bcfg_scan_out              => pc_rp_bcfg_scan_out,
      ccfg_scan_out              => pc_rp_ccfg_scan_out,
      dcfg_scan_out              => pc_rp_dcfg_scan_out,
      func_scan_out              => pc_rp_func_scan_out(0 to 1),
      gptr_scan_out              => pc_fu_gptr_scan_out,
      pc_bx_abist_di_0           => pc_bx_abist_di_0(0 to 3),
      pc_bx_abist_ena_dc         => pc_bx_abist_ena_dc,       
      pc_bx_abist_g8t1p_renb_0   => pc_bx_abist_g8t1p_renb_0, 
      pc_bx_abist_g8t_bw_0       => pc_bx_abist_g8t_bw_0,     
      pc_bx_abist_g8t_bw_1       => pc_bx_abist_g8t_bw_1,     
      pc_bx_abist_g8t_dcomp      => pc_bx_abist_g8t_dcomp(0 to 3),
      pc_bx_abist_g8t_wenb       => pc_bx_abist_g8t_wenb,     
      pc_bx_abist_raddr_0        => pc_bx_abist_raddr_0(0 to 9),
      pc_bx_abist_raw_dc_b       => pc_bx_abist_raw_dc_b,     
      pc_bx_abist_waddr_0        => pc_bx_abist_waddr_0(0 to 9),
      pc_bx_abist_wl64_g8t_comp_ena  => pc_bx_abist_wl64_comp_ena,
      pc_fu_abist_di_0           => pc_fu_abist_di_0(0 to 3),
      pc_fu_abist_di_1           => pc_fu_abist_di_1(0 to 3),
      pc_fu_abist_ena_dc         => pc_fu_abist_ena_dc,        
      pc_fu_abist_grf_renb_0     => pc_fu_abist_grf_renb_0,    
      pc_fu_abist_grf_renb_1     => pc_fu_abist_grf_renb_1,    
      pc_fu_abist_grf_wenb_0     => pc_fu_abist_grf_wenb_0,          
      pc_fu_abist_grf_wenb_1     => pc_fu_abist_grf_wenb_1,          
      pc_fu_abist_raddr_0        => pc_fu_abist_raddr_0(0 to 9),
      pc_fu_abist_raddr_1        => pc_fu_abist_raddr_1(0 to 9),
      pc_fu_abist_raw_dc_b       => pc_fu_abist_raw_dc_b,      
      pc_fu_abist_waddr_0        => pc_fu_abist_waddr_0(0 to 9),
      pc_fu_abist_waddr_1        => pc_fu_abist_waddr_1(0 to 9),
      pc_fu_abist_wl144_comp_ena => pc_fu_abist_wl144_comp_ena,
      pc_iu_abist_dcomp_g6t_2r   => pc_iu_abist_dcomp_g6t_2r(0 to 3),
      pc_iu_abist_di_0           => pc_iu_abist_di_0(0 to 3),
      pc_iu_abist_di_g6t_2r      => pc_iu_abist_di_g6t_2r(0 to 3),
      pc_iu_abist_ena_dc         => pc_iu_abist_ena_dc,        
      pc_iu_abist_g6t_bw         => pc_iu_abist_g6t_bw(0 to 1),
      pc_iu_abist_g6t_r_wb       => pc_iu_abist_g6t_r_wb,      
      pc_iu_abist_g8t1p_renb_0   => pc_iu_abist_g8t1p_renb_0, 
      pc_iu_abist_g8t_bw_0       => pc_iu_abist_g8t_bw_0,      
      pc_iu_abist_g8t_bw_1       => pc_iu_abist_g8t_bw_1,      
      pc_iu_abist_g8t_dcomp      => pc_iu_abist_g8t_dcomp(0 to 3),
      pc_iu_abist_g8t_wenb       => pc_iu_abist_g8t_wenb,      
      pc_iu_abist_raddr_0        => pc_iu_abist_raddr_0(0 to 9),
      pc_iu_abist_raw_dc_b       => pc_iu_abist_raw_dc_b,      
      pc_iu_abist_waddr_0        => pc_iu_abist_waddr_0(0 to 9),
      pc_iu_abist_wl128_g8t_comp_ena => pc_iu_abist_wl128_comp_ena,
      pc_iu_abist_wl256_comp_ena => pc_iu_abist_wl256_comp_ena,
      pc_iu_abist_wl64_g8t_comp_ena  => pc_iu_abist_wl64_comp_ena, 
      pc_mm_abist_dcomp_g6t_2r   => pc_mm_abist_dcomp_g6t_2r_iiu(0 to 3),
      pc_mm_abist_di_0           => pc_mm_abist_di_0_iiu(0 to 3),
      pc_mm_abist_di_g6t_2r      => pc_mm_abist_di_g6t_2r_iiu(0 to 3),
      pc_mm_abist_ena_dc         => pc_mm_abist_ena_dc_iiu,        
      pc_mm_abist_g6t_r_wb       => pc_mm_abist_g6t_r_wb_iiu,      
      pc_mm_abist_g8t1p_renb_0   => pc_mm_abist_g8t1p_renb_0_iiu,  
      pc_mm_abist_g8t_bw_0       => pc_mm_abist_g8t_bw_0_iiu,      
      pc_mm_abist_g8t_bw_1       => pc_mm_abist_g8t_bw_1_iiu,      
      pc_mm_abist_g8t_dcomp      => pc_mm_abist_g8t_dcomp_iiu(0 to 3),
      pc_mm_abist_g8t_wenb       => pc_mm_abist_g8t_wenb_iiu,      
      pc_mm_abist_raddr_0        => pc_mm_abist_raddr_0_iiu(0 to 9),
      pc_mm_abist_raw_dc_b       => pc_mm_abist_raw_dc_b_iiu,      
      pc_mm_abist_waddr_0        => pc_mm_abist_waddr_0_iiu(0 to 9),
      pc_mm_abist_wl128_g8t_comp_ena => pc_mm_abist_wl128_comp_ena_iiu,
      pc_xu_abist_dcomp_g6t_2r   => pc_xu_abist_dcomp_g6t_2r(0 to 3),
      pc_xu_abist_di_0           => pc_xu_abist_di_0(0 to 3),
      pc_xu_abist_di_1           => pc_xu_abist_di_1(0 to 3),
      pc_xu_abist_di_g6t_2r      => pc_xu_abist_di_g6t_2r(0 to 3),
      pc_xu_abist_ena_dc         => pc_xu_abist_ena_dc,        
      pc_xu_abist_g6t_bw         => pc_xu_abist_g6t_bw(0 to 1),
      pc_xu_abist_g6t_r_wb       => pc_xu_abist_g6t_r_wb,      
      pc_xu_abist_g8t1p_renb_0   => pc_xu_abist_g8t1p_renb_0,  
      pc_xu_abist_g8t_bw_0       => pc_xu_abist_g8t_bw_0,      
      pc_xu_abist_g8t_bw_1       => pc_xu_abist_g8t_bw_1,      
      pc_xu_abist_g8t_dcomp      => pc_xu_abist_g8t_dcomp(0 to 3),
      pc_xu_abist_g8t_wenb       => pc_xu_abist_g8t_wenb,      
      pc_xu_abist_grf_renb_0     => pc_xu_abist_grf_renb_0,    
      pc_xu_abist_grf_renb_1     => pc_xu_abist_grf_renb_1,    
      pc_xu_abist_grf_wenb_0     => pc_xu_abist_grf_wenb_0,          
      pc_xu_abist_grf_wenb_1     => pc_xu_abist_grf_wenb_1,    
      pc_xu_abist_raddr_0        => pc_xu_abist_raddr_0(0 to 9),
      pc_xu_abist_raddr_1        => pc_xu_abist_raddr_1(0 to 9),
      pc_xu_abist_raw_dc_b       => pc_xu_abist_raw_dc_b,      
      pc_xu_abist_waddr_0        => pc_xu_abist_waddr_0(0 to 9),
      pc_xu_abist_waddr_1        => pc_xu_abist_waddr_1(0 to 9),
      pc_xu_abist_wl144_comp_ena => pc_xu_abist_wl144_comp_ena,
      pc_xu_abist_wl32_g8t_comp_ena  => pc_xu_abist_wl32_comp_ena, 
      pc_xu_abist_wl512_comp_ena => pc_xu_abist_wl512_comp_ena,
      pc_bx_trace_bus_enable     => pc_bx_trace_bus_enable,
      pc_bx_debug_mux1_ctrls     => pc_bx_debug_mux1_ctrls,
      pc_bx_inj_inbox_ecc        => pc_bx_inj_inbox_ecc,
      pc_bx_inj_outbox_ecc       => pc_bx_inj_outbox_ecc,
      pc_fu_abst_sl_thold_3      => pc_fu_abst_sl_thold_3,
      pc_fu_abst_slp_sl_thold_3  => pc_fu_abst_slp_sl_thold_3,
      pc_fu_ary_nsl_thold_3      => pc_fu_ary_nsl_thold_3,
      pc_fu_ary_slp_nsl_thold_3  => pc_fu_ary_slp_nsl_thold_3,
      pc_fu_ccflush_dc           => pc_fu_ccflush_dc,
      pc_fu_cfg_sl_thold_3       => pc_fu_cfg_sl_thold_3,
      pc_fu_cfg_slp_sl_thold_3   => pc_fu_cfg_slp_sl_thold_3,
      pc_fu_debug_mux1_ctrls     => pc_fu_debug_mux1_ctrls,
      pc_fu_event_count_mode     => pc_fu_event_count_mode,
      pc_fu_event_mux_ctrls      => pc_fu_event_mux_ctrls,
      pc_iu_event_mux_ctrls      => pc_iu_event_mux_ctrls,
      pc_mm_event_mux_ctrls      => pc_mm_event_mux_ctrls_iiu,
      pc_xu_event_mux_ctrls      => pc_xu_event_mux_ctrls,
      pc_xu_lsu_event_mux_ctrls  => pc_xu_lsu_event_mux_ctrls,
      pc_fu_event_bus_enable     => pc_fu_event_bus_enable,
      pc_iu_event_bus_enable     => pc_iu_event_bus_enable,
      pc_rp_event_bus_enable     => pc_rp_event_bus_enable,
      pc_xu_event_bus_enable     => pc_xu_event_bus_enable,
      pc_fu_fce_3                => pc_fu_fce_3,
      pc_fu_func_nsl_thold_3     => pc_fu_func_nsl_thold_3,
      pc_fu_func_sl_thold_3      => pc_fu_func_sl_thold_3,
      pc_fu_func_slp_nsl_thold_3 => pc_fu_func_slp_nsl_thold_3,
      pc_fu_func_slp_sl_thold_3  => pc_fu_func_slp_sl_thold_3,
      pc_fu_gptr_sl_thold_3      => pc_fu_gptr_sl_thold_3,
      pc_fu_inj_regfile_parity   => pc_fu_inj_regfile_parity,
      pc_fu_instr_trace_mode     => pc_fu_instr_trace_mode,
      pc_fu_instr_trace_tid      => pc_fu_instr_trace_tid,
      pc_fu_ram_mode             => pc_fu_ram_mode,
      pc_fu_ram_thread           => pc_fu_ram_thread,
      pc_fu_repr_sl_thold_3      => pc_fu_repr_sl_thold_3,
      pc_fu_sg_3                 => pc_fu_sg_3,
      slowspr_addr_out           => pc_fu_slowspr_addr,
      slowspr_data_out           => pc_fu_slowspr_data,
      slowspr_done_out           => pc_fu_slowspr_done,
      slowspr_etid_out           => pc_fu_slowspr_etid,
      slowspr_rw_out             => pc_fu_slowspr_rw,
      slowspr_val_out            => pc_fu_slowspr_val,
      pc_fu_time_sl_thold_3      => pc_fu_time_sl_thold_3,
      pc_fu_trace_bus_enable     => pc_fu_trace_bus_enable,
      pc_iu_ccflush_dc           => pc_iu_ccflush_dc,
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
      pc_iu_debug_mux1_ctrls     => pc_iu_debug_mux1_ctrls,
      pc_iu_debug_mux2_ctrls     => pc_iu_debug_mux2_ctrls,
      pc_iu_event_count_mode     => pc_iu_event_count_mode,
      pc_iu_init_reset           => pc_iu_init_reset,
      pc_iu_inj_icache_parity    => pc_iu_inj_icache_parity,
      pc_iu_inj_icachedir_parity => pc_iu_inj_icachedir_parity,
      pc_iu_inj_icachedir_multihit => pc_iu_inj_icachedir_multihit,
      pc_iu_ram_force_cmplt      => pc_iu_ram_force_cmplt,
      pc_iu_ram_instr            => pc_iu_ram_instr,
      pc_iu_ram_instr_ext        => pc_iu_ram_instr_ext,
      pc_iu_ram_mode             => pc_iu_ram_mode,
      pc_iu_ram_thread           => pc_iu_ram_thread,
      pc_iu_trace_bus_enable     => pc_iu_trace_bus_enable,
      pc_mm_ccflush_dc           => pc_mm_ccflush_dc_iiu,
      pc_mm_debug_mux1_ctrls     => pc_mm_debug_mux1_ctrls_iiu,
      pc_mm_event_count_mode     => pc_mm_event_count_mode_iiu,
      pc_mm_trace_bus_enable     => pc_mm_trace_bus_enable_iiu,
      pc_xu_abst_sl_thold_3      => pc_xu_abst_sl_thold_3,
      pc_xu_abst_slp_sl_thold_3  => pc_xu_abst_slp_sl_thold_3,
      pc_xu_regf_sl_thold_3      => pc_xu_regf_sl_thold_3,
      pc_xu_regf_slp_sl_thold_3  => pc_xu_regf_slp_sl_thold_3,
      pc_xu_ary_nsl_thold_3      => pc_xu_ary_nsl_thold_3,
      pc_xu_ary_slp_nsl_thold_3  => pc_xu_ary_slp_nsl_thold_3,
      pc_xu_cache_par_err_event  => pc_xu_cache_par_err_event,
      pc_xu_ccflush_dc           => pc_xu_ccflush_dc,
      pc_xu_cfg_sl_thold_3       => pc_xu_cfg_sl_thold_3,
      pc_xu_cfg_slp_sl_thold_3   => pc_xu_cfg_slp_sl_thold_3,
      pc_xu_dbg_action           => pc_xu_dbg_action,
      pc_xu_debug_mux1_ctrls     => pc_xu_debug_mux1_ctrls,
      pc_xu_debug_mux2_ctrls     => pc_xu_debug_mux2_ctrls,
      pc_xu_debug_mux3_ctrls     => pc_xu_debug_mux3_ctrls,
      pc_xu_debug_mux4_ctrls     => pc_xu_debug_mux4_ctrls,
      pc_xu_decrem_dis_on_stop   => pc_xu_decrem_dis_on_stop,
      pc_xu_event_count_mode     => pc_xu_event_count_mode,
      pc_xu_extirpts_dis_on_stop => pc_xu_extirpts_dis_on_stop,
      pc_xu_fce_3                => pc_xu_fce_3,
      pc_xu_force_ude            => pc_xu_force_ude,
      pc_xu_func_nsl_thold_3     => pc_xu_func_nsl_thold_3,
      pc_xu_func_sl_thold_3      => pc_xu_func_sl_thold_3,
      pc_xu_func_slp_nsl_thold_3 => pc_xu_func_slp_nsl_thold_3,
      pc_xu_func_slp_sl_thold_3  => pc_xu_func_slp_sl_thold_3,
      pc_xu_gptr_sl_thold_3      => pc_xu_gptr_sl_thold_3,
      pc_xu_init_reset           => pc_xu_init_reset,
      pc_xu_inj_dcache_parity    => pc_xu_inj_dcache_parity,
      pc_xu_inj_dcachedir_parity => pc_xu_inj_dcachedir_parity,
      pc_xu_inj_llbust_attempt   => pc_xu_inj_llbust_attempt,
      pc_xu_inj_llbust_failed    => pc_xu_inj_llbust_failed,
      pc_xu_inj_sprg_ecc         => pc_xu_inj_sprg_ecc,
      pc_xu_inj_regfile_parity   => pc_xu_inj_regfile_parity,
      pc_xu_inj_wdt_reset        => pc_xu_inj_wdt_reset,
      pc_xu_inj_dcachedir_multihit => pc_xu_inj_dcachedir_multihit,
      pc_xu_instr_trace_mode     => pc_xu_instr_trace_mode,
      pc_xu_instr_trace_tid      => pc_xu_instr_trace_tid,
      pc_xu_msrovride_de         => pc_xu_msrovride_de,
      pc_xu_msrovride_enab       => pc_xu_msrovride_enab,
      pc_xu_msrovride_gs         => pc_xu_msrovride_gs,
      pc_xu_msrovride_pr         => pc_xu_msrovride_pr,
      pc_xu_ram_execute          => pc_xu_ram_execute,
      pc_xu_ram_flush_thread     => pc_xu_ram_flush_thread,
      pc_xu_ram_mode             => pc_xu_ram_mode,
      pc_xu_ram_thread           => pc_xu_ram_thread,
      pc_xu_repr_sl_thold_3      => pc_xu_repr_sl_thold_3,
      pc_xu_reset_1_cmplt        => pc_xu_reset_1_complete, 
      pc_xu_reset_2_cmplt        => pc_xu_reset_2_complete, 
      pc_xu_reset_3_cmplt        => pc_xu_reset_3_complete, 
      pc_xu_reset_wd_cmplt       => pc_xu_reset_wd_complete, 
      pc_xu_sg_3                 => pc_xu_sg_3,
      pc_xu_step                 => pc_xu_step,
      pc_xu_stop                 => pc_xu_stop,
      pc_xu_time_sl_thold_3      => pc_xu_time_sl_thold_3,
      pc_xu_timebase_dis_on_stop => pc_xu_timebase_dis_on_stop,
      pc_xu_trace_bus_enable     => pc_xu_trace_bus_enable,
      pc_bx_ccflush_dc           => pc_bx_ccflush_dc,
      pc_bx_sg_3                 => pc_bx_sg_3,
      pc_bx_func_sl_thold_3      => pc_bx_func_sl_thold_3,
      pc_bx_func_slp_sl_thold_3  => pc_bx_func_slp_sl_thold_3,
      pc_bx_gptr_sl_thold_3      => pc_bx_gptr_sl_thold_3,
      pc_bx_time_sl_thold_3      => pc_bx_time_sl_thold_3,
      pc_bx_repr_sl_thold_3      => pc_bx_repr_sl_thold_3,
      pc_bx_abst_sl_thold_3      => pc_bx_abst_sl_thold_3,
      pc_bx_ary_nsl_thold_3      => pc_bx_ary_nsl_thold_3,
      pc_bx_ary_slp_nsl_thold_3  => pc_bx_ary_slp_nsl_thold_3, 
      
      an_ac_scan_diag_dc_opc     => an_ac_scan_diag_dc_opc,
      an_ac_scan_dis_dc_b_opc    => an_ac_scan_dis_dc_b_opc,

      xu_pc_err_mchk_disabled    => xu_pc_err_mchk_disabled_ofu,
      
      gnd                        => gnd,
      vdd                        => vdd
   ); 


bx: if include_boxes=1 generate begin 
   a_bxq: entity work.bxq
   generic map(expand_type    => expand_type,
               real_data_add  => xu_real_data_add,
               regmode        => regmode)
   PORT map(
     xu_bx_ccr2_en_ditc            => xu_bx_ccr2_en_ditc,
     xu_ex2_flush                  => xu_ex2_flush_ofu,
     xu_ex3_flush                  => xu_ex3_flush_ofu,
     xu_ex4_flush                  => xu_ex4_flush_ofu,
     xu_ex5_flush                  => xu_ex5_flush_ofu,
     xu_bx_ex1_mtdp_val            => xu_bx_ex1_mtdp_val,
     xu_bx_ex1_mfdp_val            => xu_bx_ex1_mfdp_val,
     xu_bx_ex1_ipc_thrd            => xu_bx_ex1_ipc_thrd,
     xu_bx_ex2_ipc_ba              => xu_bx_ex2_ipc_ba,
     xu_bx_ex2_ipc_sz              => xu_bx_ex2_ipc_sz,
     xu_bx_ex4_256st_data          => xu_bx_ex4_256st_data(128 to 255) ,
                           
     bx_xu_ex4_mtdp_cr_status     => bx_xu_ex4_mtdp_cr_status ,
     bx_xu_ex4_mfdp_cr_status     => bx_xu_ex4_mfdp_cr_status ,
     bx_xu_ex5_dp_data            => bx_xu_ex5_dp_data        ,

     bx_lsu_ob_pwr_tok       => bx_lsu_ob_pwr_tok,
     bx_lsu_ob_req_val       => bx_lsu_ob_req_val,
     bx_lsu_ob_ditc_val      => bx_lsu_ob_ditc_val,
     bx_lsu_ob_thrd          => bx_lsu_ob_thrd,
     bx_lsu_ob_qw            => bx_lsu_ob_qw,
     bx_lsu_ob_dest          => bx_lsu_ob_dest,
     bx_lsu_ob_data          => bx_lsu_ob_data,
     bx_lsu_ob_addr          => bx_lsu_ob_addr,
                                
     ac_an_reld_ditc_pop     => ac_an_reld_ditc_pop_int,

     bx_ib_empty             => bx_ib_empty_int, 
     bx_xu_quiesce           => bx_xu_quiesce,

    lsu_bx_cmd_avail           => lsu_bx_cmd_avail,
    lsu_bx_cmd_sent            => lsu_bx_cmd_sent,
    lsu_bx_cmd_stall           => lsu_bx_cmd_stall,

    lsu_reld_data_vld        => lsu_reld_data_vld,                 
    lsu_reld_core_tag        => lsu_reld_core_tag(3 to 4),
    lsu_reld_qw              => lsu_reld_qw,
    lsu_reld_ditc            => lsu_reld_ditc,
    lsu_reld_ecc_err         => lsu_reld_ecc_err,
    lsu_reld_data            => lsu_reld_data,
     
    an_ac_lbist_ary_wrt_thru_dc => an_ac_lbist_ary_wrt_thru_dc_ofu,
                                
    lsu_req_st_pop           => lsu_req_st_pop      ,
    lsu_req_st_pop_thrd      => lsu_req_st_pop_thrd ,

    slowspr_addr_in            => fu_bx_slowspr_addr,
    slowspr_data_in            => fu_bx_slowspr_data,
    slowspr_done_in            => fu_bx_slowspr_done,
    slowspr_etid_in            => fu_bx_slowspr_etid,
    slowspr_rw_in              => fu_bx_slowspr_rw,
    slowspr_val_in             => fu_bx_slowspr_val,
    slowspr_addr_out           => bx_xu_slowspr_addr,
    slowspr_data_out           => bx_xu_slowspr_data,
    slowspr_done_out           => bx_xu_slowspr_done,
    slowspr_etid_out           => bx_xu_slowspr_etid,
    slowspr_rw_out             => bx_xu_slowspr_rw,
    slowspr_val_out            => bx_xu_slowspr_val,

     bx_pc_bo_fail             => bx_pc_bo_fail,
     bx_pc_bo_diagout          => bx_pc_bo_diagout,
     bx_pc_err_inbox_ecc       => bx_pc_err_inbox_ecc,
     bx_pc_err_outbox_ecc      => bx_pc_err_outbox_ecc,
     bx_pc_err_inbox_ue        => bx_pc_err_inbox_ue,
     bx_pc_err_outbox_ue       => bx_pc_err_outbox_ue,
     pc_bx_inj_inbox_ecc       => pc_bx_inj_inbox_ecc_ofu,
     pc_bx_inj_outbox_ecc      => pc_bx_inj_outbox_ecc_ofu,

     pc_bx_trace_bus_enable    => pc_bx_trace_bus_enable_ofu,
     pc_bx_debug_mux1_ctrls    => pc_bx_debug_mux1_ctrls_ofu,
     trigger_data_in           => trigger_start_tiedowns,
     debug_data_in             => debug_start_tiedowns,
     debug_data_out            => bx_fu_debug_data,
     trigger_data_out          => bx_fu_trigger_data,

     vdd                     => vdd,
     gnd                     => gnd,
     vcs                     => vcs,
     nclk                    => a2_nclk,

     pc_bx_abist_di_0          	=> pc_bx_abist_di_0_ofu,        
     pc_bx_abist_ena_dc        	=> pc_bx_abist_ena_dc_ofu,      
     pc_bx_abist_g8t1p_renb_0  	=> pc_bx_abist_g8t1p_renb_0_ofu,
     pc_bx_abist_g8t_bw_0      	=> pc_bx_abist_g8t_bw_0_ofu,    
     pc_bx_abist_g8t_bw_1      	=> pc_bx_abist_g8t_bw_1_ofu,    
     pc_bx_abist_g8t_dcomp     	=> pc_bx_abist_g8t_dcomp_ofu,   
     pc_bx_abist_g8t_wenb      	=> pc_bx_abist_g8t_wenb_ofu,    
     pc_bx_abist_raddr_0       	=> pc_bx_abist_raddr_0_ofu(4 to 9),
     pc_bx_abist_raw_dc_b      	=> pc_bx_abist_raw_dc_b_ofu,    
     pc_bx_abist_waddr_0       	=> pc_bx_abist_waddr_0_ofu(4 to 9),
     pc_bx_abist_wl64_comp_ena  => pc_bx_abist_wl64_comp_ena_ofu,
     pc_bx_bolt_sl_thold_3      => pc_bx_bolt_sl_thold_3_ofu,
     pc_bx_bo_enable_3          => pc_bx_bo_enable_3_ofu,     
     pc_bx_bo_unload	        => pc_bx_bo_unload_ofu,    
     pc_bx_bo_repair	        => pc_bx_bo_repair_ofu,	    
     pc_bx_bo_reset	        => pc_bx_bo_reset_ofu,
     pc_bx_bo_shdata	        => pc_bx_bo_shdata_ofu,    
     pc_bx_bo_select	        => pc_bx_bo_select_ofu,
     pc_bx_ccflush_dc           => pc_bx_ccflush_dc_ofu,
     pc_bx_sg_3                 => pc_bx_sg_3_ofu,
     pc_bx_func_sl_thold_3      => pc_bx_func_sl_thold_3_ofu,
     pc_bx_func_slp_sl_thold_3  => pc_bx_func_slp_sl_thold_3_ofu,
     pc_bx_gptr_sl_thold_3      => pc_bx_gptr_sl_thold_3_ofu,
     pc_bx_abst_sl_thold_3      => pc_bx_abst_sl_thold_3_ofu,
     pc_bx_time_sl_thold_3      => pc_bx_time_sl_thold_3_ofu,
     pc_bx_ary_nsl_thold_3      => pc_bx_ary_nsl_thold_3_ofu,
     pc_bx_ary_slp_nsl_thold_3  => pc_bx_ary_slp_nsl_thold_3_ofu,
     pc_bx_repr_sl_thold_3      => pc_bx_repr_sl_thold_3_ofu,
     an_ac_scan_diag_dc         => an_ac_scan_diag_dc_ofu,
     an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b_ofu,
     time_scan_in               => fu_bx_time_scan_out,
     repr_scan_in               => fu_bx_repr_scan_out,
     abst_scan_in               => rp_fu_bx_abst_scan_in,
     time_scan_out              => bx_xu_time_scan_out,
     repr_scan_out              => bx_xu_repr_scan_out,
     abst_scan_out              => bx_fu_rp_abst_scan_out,
     gptr_scan_in               => fu_bx_gptr_scan_out,
     gptr_scan_out              => bx_xu_gptr_scan_out,
     func_scan_in               => rp_fu_bx_func_scan_in,
     func_scan_out              => bx_fu_rp_func_scan_out
   );  
end generate;


nobx: if include_boxes=0 generate begin
   bx_xu_ex5_dp_data <= (others=>'0');
   bx_xu_ex4_mtdp_cr_status <= '0';
   bx_xu_ex4_mfdp_cr_status <= '0';
   bx_lsu_ob_pwr_tok <= '0';
   bx_lsu_ob_req_val <= '0';
   bx_lsu_ob_ditc_val <= '0';
   bx_lsu_ob_thrd <= (others=>'0');
   bx_lsu_ob_qw   <= (others=>'0');
   bx_lsu_ob_dest <= (others=>'0');
   bx_lsu_ob_data <= (others=>'0');
   bx_lsu_ob_addr <= (others=>'0');
   ac_an_reld_ditc_pop_int <= (others=>'0');
   bx_ib_empty_int <= (others=>'1');
   bx_xu_quiesce <= (others=>'1');
   bx_xu_slowspr_addr            <= fu_bx_slowspr_addr;
   bx_xu_slowspr_data            <= fu_bx_slowspr_data;
   bx_xu_slowspr_done            <= fu_bx_slowspr_done;
   bx_xu_slowspr_etid            <= fu_bx_slowspr_etid;
   bx_xu_slowspr_rw              <= fu_bx_slowspr_rw;
   bx_xu_slowspr_val             <= fu_bx_slowspr_val;
   bx_pc_err_inbox_ecc  <= '0';
   bx_pc_err_outbox_ecc <= '0';
   bx_pc_err_inbox_ue   <= '0';
   bx_pc_err_outbox_ue  <= '0';
   bx_fu_debug_data <= debug_start_tiedowns;
   bx_fu_trigger_data <= trigger_start_tiedowns;
   bx_xu_time_scan_out <= fu_bx_time_scan_out;
   bx_xu_repr_scan_out <= fu_bx_repr_scan_out;
   bx_rp_abst_scan_out <= rp_bx_abst_scan_in_q;
   fu_bx_gptr_scan_out <= fu_bx_gptr_scan_out;
   bx_rp_func_scan_out <= rp_bx_func_scan_in_q;
end generate;


END acq_soft;
