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

entity mmq is
  generic(thdid_width       : integer := 4;
            ttype_width        : integer := 4;
            state_width        : integer := 4;
            pid_width          : integer := 14;
            pid_width_erat     : integer := 8;
            lpid_width         : integer := 8;
            class_width        : integer := 2;
            extclass_width     : integer := 2;
            tlbsel_width       : integer := 2;
            epn_width          : integer := 52;
            req_epn_width      : integer := 52;
            vpn_width          : integer := 61;
            erat_cam_data_width       : integer := 75;
            erat_ary_data_width       : integer := 73;
            erat_rel_data_width       : integer := 132;
            ws_width           : integer := 2;
            rs_is_width        : integer := 9;
            ra_entry_width     : integer := 12;
            rs_data_width      : integer := 64;
            data_out_width     : integer := 64;
            error_width        : integer := 3;
            tlb_num_entry          : natural := 512; 
            tlb_num_entry_log2     : natural := 9; 
            tlb_ways               : natural := 4;
            tlb_addr_width         : natural := 7;
            tlb_way_width     : natural := 168;
            tlb_word_width    : natural := 84;
            tlb_seq_width      : integer := 6;
            inv_seq_width      : integer := 6;
            por_seq_width      : integer := 3;
            watermark_width    : integer := 4;
            eptr_width         : integer := 4;
            lru_width          : integer := 16;
            mmucr0_width       : integer := 20;
            mmucr1_width       : integer := 32;
            mmucr2_width       : integer := 32;
            mmucr3_width       : integer := 15;
            spr_ctl_width      : integer := 3;
            spr_etid_width     : integer := 2;
            spr_addr_width     : integer := 10;
            spr_data_width     : integer := 64;
            debug_trace_width  : integer := 88;
            debug_event_width  : integer := 16;
            real_addr_width    : integer := 42;
            rpn_width          : integer := 30;  
            pte_width          : integer := 64;  
            lrat_num_entry_log2 : integer := 3;
            tlb_tag_width      : natural := 110;
         mmq_spr_cswitch_0to3  : integer := 0; 
     mmq_tlb_cmp_cswitch_0to7  : integer := 0; 
          expand_tlb_type      : integer := 2;     
          expand_type          : integer := 2 );   
port(
     vcs                        : inout power_logic;
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;

tc_ac_ccflush_dc             : in std_ulogic;
tc_ac_scan_dis_dc_b          : in std_ulogic;
tc_ac_scan_diag_dc           : in std_ulogic;
tc_ac_lbist_en_dc            : in std_ulogic;
pc_mm_gptr_sl_thold_3       : in   std_ulogic;
pc_mm_time_sl_thold_3       : in   std_ulogic;
pc_mm_repr_sl_thold_3       : in   std_ulogic;
pc_mm_abst_sl_thold_3       : in   std_ulogic;
pc_mm_abst_slp_sl_thold_3   : in   std_ulogic;
pc_mm_func_sl_thold_3       : in   std_ulogic_vector(0 to 1);
pc_mm_func_slp_sl_thold_3   : in   std_ulogic_vector(0 to 1);
pc_mm_cfg_sl_thold_3        : in   std_ulogic;
pc_mm_cfg_slp_sl_thold_3    : in   std_ulogic;
pc_mm_func_nsl_thold_3      : in   std_ulogic;
pc_mm_func_slp_nsl_thold_3  : in   std_ulogic;
pc_mm_ary_nsl_thold_3       : in   std_ulogic;
pc_mm_ary_slp_nsl_thold_3   : in   std_ulogic;
pc_mm_sg_3                  : in   std_ulogic_vector(0 to 1);
pc_mm_fce_3                 : in   std_ulogic;
debug_bus_out               : out   std_ulogic_vector(0 to 87);
debug_bus_out_int           : out   std_ulogic_vector(0 to 7);
trace_triggers_out          : out   std_ulogic_vector(0 to 11);
debug_bus_in                : in    std_ulogic_vector(0 to 87);
trace_triggers_in           : in    std_ulogic_vector(0 to 11);
pc_mm_debug_mux1_ctrls      : in   std_ulogic_vector(0 to 15);
pc_mm_trace_bus_enable      : in   std_ulogic;
pc_mm_event_mux_ctrls       : in   std_ulogic_vector(0 to 39);
pc_mm_event_count_mode      : in   std_ulogic_vector(0 to 2);
rp_mm_event_bus_enable_q    : in   std_ulogic;
mm_pc_event_data            : out   std_ulogic_vector(0 to 7);
pc_mm_abist_dcomp_g6t_2r    : in   std_ulogic_vector(0 to 3);
pc_mm_abist_di_0            : in   std_ulogic_vector(0 to 3);
pc_mm_abist_di_g6t_2r       : in   std_ulogic_vector(0 to 3);
pc_mm_abist_ena_dc          : in   std_ulogic;
pc_mm_abist_g6t_r_wb        : in   std_ulogic;
pc_mm_abist_g8t1p_renb_0    : in   std_ulogic;
pc_mm_abist_g8t_bw_0        : in   std_ulogic;
pc_mm_abist_g8t_bw_1        : in   std_ulogic;
pc_mm_abist_g8t_dcomp       : in   std_ulogic_vector(0 to 3);
pc_mm_abist_g8t_wenb        : in   std_ulogic;
pc_mm_abist_raddr_0         : in   std_ulogic_vector(0 to 9);
pc_mm_abist_raw_dc_b        : in   std_ulogic;
pc_mm_abist_waddr_0         : in   std_ulogic_vector(0 to 9);
pc_mm_abist_wl128_comp_ena  : in   std_ulogic;
pc_mm_bolt_sl_thold_3          : in    std_ulogic;
pc_mm_bo_enable_3              : in    std_ulogic;
pc_mm_bo_reset                 : in    std_ulogic;
pc_mm_bo_unload                : in    std_ulogic;
pc_mm_bo_repair                : in    std_ulogic;
pc_mm_bo_shdata                : in    std_ulogic;
pc_mm_bo_select                : in    std_ulogic_vector(0 to 4);
mm_pc_bo_fail                  : out   std_ulogic_vector(0 to 4);
mm_pc_bo_diagout               : out   std_ulogic_vector(0 to 4);
iu_mm_ierat_req            : in std_ulogic;
iu_mm_ierat_epn            : in std_ulogic_vector(0 to 51);
iu_mm_ierat_thdid          : in std_ulogic_vector(0 to thdid_width-1);
iu_mm_ierat_state          : in std_ulogic_vector(0 to state_width-1);
iu_mm_ierat_tid            : in std_ulogic_vector(0 to pid_width-1);
iu_mm_ierat_flush          : in std_ulogic_vector(0 to thdid_width-1);
mm_iu_ierat_rel_val        : out std_ulogic_vector(0 to 4);
mm_iu_ierat_rel_data       : out std_ulogic_vector(0 to erat_rel_data_width-1);
mm_iu_ierat_snoop_coming   : out std_ulogic;
mm_iu_ierat_snoop_val      : out std_ulogic;
mm_iu_ierat_snoop_attr     : out std_ulogic_vector(0 to 25);
mm_iu_ierat_snoop_vpn      : out std_ulogic_vector(52-epn_width to 51);
iu_mm_ierat_snoop_ack      : in std_ulogic;
mm_iu_ierat_pid0           : out std_ulogic_vector(0 to pid_width-1);
mm_iu_ierat_pid1           : out std_ulogic_vector(0 to pid_width-1);
mm_iu_ierat_pid2           : out std_ulogic_vector(0 to pid_width-1);
mm_iu_ierat_pid3           : out std_ulogic_vector(0 to pid_width-1);
mm_iu_ierat_mmucr0_0         : out std_ulogic_vector(0 to 19);
mm_iu_ierat_mmucr0_1         : out std_ulogic_vector(0 to 19);
mm_iu_ierat_mmucr0_2         : out std_ulogic_vector(0 to 19);
mm_iu_ierat_mmucr0_3         : out std_ulogic_vector(0 to 19);
iu_mm_ierat_mmucr0          : in std_ulogic_vector(0 to 17);
iu_mm_ierat_mmucr0_we       : in std_ulogic_vector(0 to 3);
mm_iu_ierat_mmucr1          : out std_ulogic_vector(0 to 8);
iu_mm_ierat_mmucr1          : in std_ulogic_vector(0 to 3);
iu_mm_ierat_mmucr1_we       : in std_ulogic;
xu_mm_derat_req            : in std_ulogic;
xu_mm_derat_epn            : in std_ulogic_vector(64-rs_data_width to 51);
xu_mm_derat_thdid          : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_derat_ttype          : in std_ulogic_vector(0 to 1);
xu_mm_derat_state          : in std_ulogic_vector(0 to state_width-1);
xu_mm_derat_lpid           : in std_ulogic_vector(0 to lpid_width-1);
xu_mm_derat_tid            : in std_ulogic_vector(0 to pid_width-1);
mm_xu_derat_rel_val        : out std_ulogic_vector(0 to 4);
mm_xu_derat_rel_data       : out std_ulogic_vector(0 to erat_rel_data_width-1);
mm_xu_derat_snoop_coming   : out std_ulogic;
mm_xu_derat_snoop_val      : out std_ulogic;
mm_xu_derat_snoop_attr     : out std_ulogic_vector(0 to 25);
mm_xu_derat_snoop_vpn      : out std_ulogic_vector(52-epn_width to 51);
xu_mm_derat_snoop_ack      : in std_ulogic;
mm_xu_derat_pid0           : out std_ulogic_vector(0 to pid_width-1);
mm_xu_derat_pid1           : out std_ulogic_vector(0 to pid_width-1);
mm_xu_derat_pid2           : out std_ulogic_vector(0 to pid_width-1);
mm_xu_derat_pid3           : out std_ulogic_vector(0 to pid_width-1);
mm_xu_derat_mmucr0_0         : out std_ulogic_vector(0 to 19);
mm_xu_derat_mmucr0_1         : out std_ulogic_vector(0 to 19);
mm_xu_derat_mmucr0_2         : out std_ulogic_vector(0 to 19);
mm_xu_derat_mmucr0_3         : out std_ulogic_vector(0 to 19);
xu_mm_derat_mmucr0          : in std_ulogic_vector(0 to 17);
xu_mm_derat_mmucr0_we       : in std_ulogic_vector(0 to 3);
mm_xu_derat_mmucr1          : out std_ulogic_vector(0 to 9);
xu_mm_derat_mmucr1          : in std_ulogic_vector(0 to 4);
xu_mm_derat_mmucr1_we       : in std_ulogic;
xu_mm_rf1_val           : in std_ulogic_vector(0 to 3);
xu_mm_rf1_is_tlbre      : in std_ulogic;
xu_mm_rf1_is_tlbwe      : in std_ulogic;
xu_mm_rf1_is_tlbsx      : in std_ulogic;
xu_mm_rf1_is_tlbsxr     : in std_ulogic;
xu_mm_rf1_is_tlbsrx     : in std_ulogic;
xu_mm_rf1_is_tlbivax    : in std_ulogic;
xu_mm_rf1_is_tlbilx     : in std_ulogic;
xu_mm_rf1_is_erativax   : in std_ulogic;
xu_mm_rf1_is_eratilx    : in std_ulogic;
xu_mm_ex1_is_isync      : in std_ulogic;
xu_mm_ex1_is_csync      : in std_ulogic;
xu_mm_rf1_t             : in std_ulogic_vector(0 to 2);
xu_mm_ex1_rs_is         : in std_ulogic_vector(0 to 8);
xu_mm_ex2_eff_addr      : in std_ulogic_vector(64-rs_data_width to 63);
xu_mm_msr_gs           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_msr_pr           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_msr_is           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_msr_ds           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_msr_cm           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_spr_epcr_dmiuh   : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_spr_epcr_dgtmi   : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_hid_mmu_mode      : in std_ulogic;
xu_mm_xucr4_mmu_mchk    : in std_ulogic;
xu_mm_lmq_stq_empty     : in std_ulogic;
iu_mm_lmq_empty         : in std_ulogic;
xu_rf1_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex1_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex2_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex3_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex4_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex5_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ex4_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ex5_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ierat_miss        : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ierat_flush       : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ex5_perf_dtlb     : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ex5_perf_itlb     : in std_ulogic_vector(0 to thdid_width-1);
mm_iu_barrier_done     : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_eratmiss_done    : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_cr0_eq           : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_cr0_eq_valid     : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_miss         : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_lrat_miss        : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_inelig       : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_pt_fault         : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_hv_priv          : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_illeg_instr      : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_esr_pt           : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_esr_data         : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_esr_epid         : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_esr_st           : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_quiesce        : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_multihit_err        : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_par_err             : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_lru_par_err             : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_local_snoop_reject       : out std_ulogic_vector(0 to thdid_width-1);
xu_mm_hold_ack          : in std_ulogic_vector(0 to thdid_width-1);
mm_xu_hold_req          : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_hold_done         : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_ex3_flush_req     : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_lsu_req              : out     std_ulogic_vector(0 to 3);
mm_xu_lsu_ttype            : out     std_ulogic_vector(0 to 1);
mm_xu_lsu_wimge            : out     std_ulogic_vector(0 to 4);
mm_xu_lsu_u                : out     std_ulogic_vector(0 to 3);
mm_xu_lsu_addr             : out     std_ulogic_vector(64-real_addr_width to 63);
mm_xu_lsu_lpid             : out  std_ulogic_vector(0 to 7);
mm_xu_lsu_lpidr            : out  std_ulogic_vector(0 to 7);
mm_xu_lsu_gs               : out  std_ulogic;
mm_xu_lsu_ind              : out  std_ulogic;
mm_xu_lsu_lbit             : out  std_ulogic;
xu_mm_lsu_token            :in    std_ulogic;
slowspr_val_in             : in std_ulogic;
slowspr_rw_in              : in std_ulogic;
slowspr_etid_in            : in std_ulogic_vector(0 to 1);
slowspr_addr_in            : in std_ulogic_vector(0 to 9);
slowspr_data_in            : in std_ulogic_vector(64-spr_data_width to 63);
slowspr_done_in            : in std_ulogic;
slowspr_val_out            : out std_ulogic;
slowspr_rw_out             : out std_ulogic;
slowspr_etid_out           : out std_ulogic_vector(0 to 1);
slowspr_addr_out           : out std_ulogic_vector(0 to 9);
slowspr_data_out           : out std_ulogic_vector(64-spr_data_width to 63);
slowspr_done_out           : out std_ulogic;
gptr_scan_in          :in     std_ulogic;
time_scan_in          :in     std_ulogic;
repr_scan_in          :in     std_ulogic;
an_ac_abst_scan_in	   : in std_ulogic_vector(0 to 9);
an_ac_func_scan_in	   : in std_ulogic_vector(0 to 63);
an_ac_bcfg_scan_in	   : in std_ulogic_vector(0 to 4);
an_ac_dcfg_scan_in	   : in std_ulogic_vector(0 to 2);
ac_an_gptr_scan_out   :out    std_ulogic;
ac_an_time_scan_out   :out    std_ulogic;
ac_an_repr_scan_out   :out    std_ulogic;
bcfg_scan_out         :out    std_ulogic;
ccfg_scan_out         :out    std_ulogic;
dcfg_scan_out         :out    std_ulogic;
an_ac_back_inv             : in std_ulogic;
an_ac_back_inv_target      : in std_ulogic_vector(0 to 4);
an_ac_back_inv_addr        : in std_ulogic_vector(64-real_addr_width to 63);
an_ac_back_inv_local       : in std_ulogic;
an_ac_back_inv_lbit        : in std_ulogic;
an_ac_back_inv_gs          : in std_ulogic;
an_ac_back_inv_ind         : in std_ulogic;
an_ac_back_inv_lpar_id     : in std_ulogic_vector(0 to lpid_width-1);
ac_an_back_inv_reject      : out std_ulogic;
ac_an_lpar_id              : out std_ulogic_vector(0 to lpid_width-1);
an_ac_reld_core_tag         : in std_ulogic_vector(0 to 4);
an_ac_reld_data 	         : in std_ulogic_vector(0 to 127);
an_ac_reld_data_vld         : in std_ulogic;
an_ac_reld_ecc_err	         : in std_ulogic;
an_ac_reld_ecc_err_ue       : in std_ulogic;
an_ac_reld_qw	         : in std_ulogic_vector(57 to 59);
an_ac_reld_ditc 	         : in std_ulogic;
an_ac_reld_crit_qw	         : in std_ulogic;
an_ac_reld_data_coming      : in std_ulogic;
an_ac_reld_l1_dump	         : in std_ulogic;
an_ac_grffence_en_dc        : in std_ulogic;
an_ac_stcx_complete         : in std_ulogic_vector(0 to 3);
an_ac_abist_mode_dc         : in std_ulogic;
an_ac_abist_start_test      : in std_ulogic;
an_ac_atpg_en_dc	         : in std_ulogic;
an_ac_lbist_ary_wrt_thru_dc : in std_ulogic;
an_ac_ccflush_dc	         : in std_ulogic;
an_ac_reset_1_complete      : in std_ulogic;
an_ac_reset_2_complete      : in std_ulogic;
an_ac_reset_3_complete      : in std_ulogic;
an_ac_reset_wd_complete     : in std_ulogic;
an_ac_debug_stop	   : in std_ulogic;
an_ac_lbist_en_dc	   : in std_ulogic;
an_ac_pm_thread_stop  : in std_ulogic_vector(0 to 3);
an_ac_regf_scan_in	   : in std_ulogic_vector(0 to 11);
an_ac_scan_diag_dc	   : in std_ulogic;
an_ac_scan_dis_dc_b   : in std_ulogic;
an_ac_scom_cch  	   : in std_ulogic;
an_ac_scom_dch  	   : in std_ulogic;
an_ac_checkstop 	   : in std_ulogic;
--   _omm  suffix means output from mmu
an_ac_back_inv_omm	         : out std_ulogic;
an_ac_back_inv_addr_omm     : out std_ulogic_vector(64-real_addr_width to 63);
an_ac_back_inv_target_omm_iua   : out std_ulogic_vector(0 to 1);
an_ac_back_inv_target_omm_iub   : out std_ulogic_vector(3 to 4);
an_ac_reld_core_tag_omm         : out std_ulogic_vector(0 to 4);
an_ac_reld_data_omm 	     : out std_ulogic_vector(0 to 127);
an_ac_reld_data_vld_omm         : out std_ulogic;
an_ac_reld_ecc_err_omm	     : out std_ulogic;
an_ac_reld_ecc_err_ue_omm       : out std_ulogic;
an_ac_reld_qw_omm	             : out std_ulogic_vector(57 to 59);
an_ac_reld_ditc_omm 	     : out std_ulogic;
an_ac_reld_crit_qw_omm	     : out std_ulogic;
an_ac_reld_data_coming_omm      : out std_ulogic;
an_ac_reld_l1_dump_omm	     : out std_ulogic;
an_ac_grffence_en_dc_omm        : out std_ulogic;
an_ac_stcx_complete_omm         : out std_ulogic_vector(0 to 3);
an_ac_abist_mode_dc_omm         : out std_ulogic;
an_ac_abist_start_test_omm      : out std_ulogic;
an_ac_abst_scan_in_omm_iu	     : out std_ulogic_vector(0 to 4);
an_ac_abst_scan_in_omm_xu	     : out std_ulogic_vector(7 to 9);
an_ac_atpg_en_dc_omm	         : out std_ulogic;
an_ac_bcfg_scan_in_omm_bit1	         : out std_ulogic;
an_ac_bcfg_scan_in_omm_bit3	         : out std_ulogic;
an_ac_bcfg_scan_in_omm_bit4	         : out std_ulogic;
an_ac_lbist_ary_wrt_thru_dc_omm : out std_ulogic;
an_ac_ccflush_dc_omm	     : out std_ulogic;
an_ac_reset_1_complete_omm      : out std_ulogic;
an_ac_reset_2_complete_omm      : out std_ulogic;
an_ac_reset_3_complete_omm      : out std_ulogic;
an_ac_reset_wd_complete_omm     : out std_ulogic;
an_ac_dcfg_scan_in_omm	     : out std_ulogic_vector(1 to 2);
an_ac_debug_stop_omm	   : out std_ulogic;
an_ac_func_scan_in_omm_iua	   : out std_ulogic_vector(0 to 21);
an_ac_func_scan_in_omm_iub	   : out std_ulogic_vector(60 to 63);
an_ac_func_scan_in_omm_xu	   : out std_ulogic_vector(31 to 58);
an_ac_lbist_en_dc_omm	   : out std_ulogic;
an_ac_pm_thread_stop_omm      : out std_ulogic_vector(0 to 3);
an_ac_regf_scan_in_omm	   : out std_ulogic_vector(0 to 11);
an_ac_scan_diag_dc_omm	   : out std_ulogic;
an_ac_scan_dis_dc_b_omm       : out std_ulogic;
an_ac_scom_cch_omm  	   : out std_ulogic;
an_ac_scom_dch_omm  	   : out std_ulogic;
an_ac_checkstop_omm 	   : out std_ulogic;
--   _imm  prefix means input to mmu
ac_an_abst_scan_out_imm_iu    : in std_ulogic_vector(0 to 4);
ac_an_abst_scan_out_imm_xu    : in std_ulogic_vector(7 to 9);
ac_an_bcfg_scan_out_imm	   : in std_ulogic_vector(0 to 4);
ac_an_dcfg_scan_out_imm	   : in std_ulogic_vector(0 to 2);
ac_an_func_scan_out_imm_iua   : in std_ulogic_vector(0 to 21);
ac_an_func_scan_out_imm_iub   : in std_ulogic_vector(60 to 63);
ac_an_func_scan_out_imm_xu	   : in std_ulogic_vector(31 to 58);
ac_an_reld_ditc_pop_imm	   : in std_ulogic_vector(0 to 3);
ac_an_power_managed_imm	   : in std_ulogic;
ac_an_rvwinkle_mode_imm	   : in std_ulogic;
ac_an_fu_bypass_events_imm        : in std_ulogic_vector(0 to 7);
ac_an_iu_bypass_events_imm        : in std_ulogic_vector(0 to 7);
ac_an_mm_bypass_events_imm        : in std_ulogic_vector(0 to 7);
ac_an_lsu_bypass_events_imm       : in std_ulogic_vector(0 to 7);
ac_an_event_bus_imm 	           : in std_ulogic_vector(0 to 7);
ac_an_pm_thread_running_imm       : in std_ulogic_vector(0 to 3);
ac_an_recov_err_imm 	           : in std_ulogic_vector(0 to 2);
ac_an_regf_scan_out_imm	   : in std_ulogic_vector(0 to 11);
ac_an_scom_cch_imm  	           : in std_ulogic;
ac_an_scom_dch_imm  	           : in std_ulogic;
ac_an_special_attn_imm	           : in std_ulogic_vector(0 to 3);
ac_an_checkstop_imm 	           : in std_ulogic_vector(0 to 2);
ac_an_local_checkstop_imm	           : in std_ulogic_vector(0 to 2);
ac_an_trace_error_imm	           : in std_ulogic;
ac_an_abst_scan_out	   : out std_ulogic_vector(0 to 9);
ac_an_bcfg_scan_out	   : out std_ulogic_vector(0 to 4);
ac_an_dcfg_scan_out	   : out std_ulogic_vector(0 to 2);
ac_an_func_scan_out	   : out std_ulogic_vector(0 to 63);
ac_an_reld_ditc_pop	   : out std_ulogic_vector(0 to 3);
ac_an_power_managed	   : out std_ulogic;
ac_an_rvwinkle_mode	   : out std_ulogic;
ac_an_fu_bypass_events        : out std_ulogic_vector(0 to 7);
ac_an_iu_bypass_events        : out std_ulogic_vector(0 to 7);
ac_an_mm_bypass_events        : out std_ulogic_vector(0 to 7);
ac_an_lsu_bypass_events       : out std_ulogic_vector(0 to 7);
ac_an_event_bus 	           : out std_ulogic_vector(0 to 7);
ac_an_pm_thread_running       : out std_ulogic_vector(0 to 3);
ac_an_recov_err 	           : out std_ulogic_vector(0 to 2);
ac_an_regf_scan_out	   : out std_ulogic_vector(0 to 11);
ac_an_scom_cch  	           : out std_ulogic;
ac_an_scom_dch  	           : out std_ulogic;
ac_an_special_attn	           : out std_ulogic_vector(0 to 3);
ac_an_checkstop 	           : out std_ulogic_vector(0 to 2);
ac_an_local_checkstop	   : out std_ulogic_vector(0 to 2);
ac_an_trace_error	           : out std_ulogic;
an_ac_dcr_act	   : in std_ulogic;
an_ac_dcr_val	   : in std_ulogic;
an_ac_dcr_read  	   : in std_ulogic;
an_ac_dcr_etid  	   : in std_ulogic_vector(0 to 1);
an_ac_dcr_data  	   : in std_ulogic_vector(64-spr_data_width to 63);
an_ac_dcr_done  	   : in std_ulogic;
an_ac_crit_interrupt  : in std_ulogic_vector(0 to thdid_width-1);
an_ac_ext_interrupt   : in std_ulogic_vector(0 to thdid_width-1);
an_ac_flh2l2_gate	   : in std_ulogic;
an_ac_icbi_ack  	   : in std_ulogic;
an_ac_icbi_ack_thread : in std_ulogic_vector(0 to 1);
an_ac_req_ld_pop	   : in std_ulogic;
an_ac_req_spare_ctrl_a1    : in std_ulogic_vector(0 to 3);
an_ac_req_st_gather	: in std_ulogic;
an_ac_req_st_pop	   : in std_ulogic;
an_ac_req_st_pop_thrd : in std_ulogic_vector(0 to 2);
an_ac_reservation_vld : in std_ulogic_vector(0 to thdid_width-1);
an_ac_sleep_en  	   : in std_ulogic_vector(0 to thdid_width-1);
an_ac_stcx_pass 	   : in std_ulogic_vector(0 to 3);
an_ac_sync_ack  	   : in std_ulogic_vector(0 to 3);
an_ac_ary_nsl_thold_7 : in std_ulogic;
an_ac_ccenable_dc	   : in std_ulogic;
an_ac_coreid	   : in std_ulogic_vector(0 to 7);
an_ac_external_mchk   : in std_ulogic_vector(0 to 3);
an_ac_fce_7	   : in std_ulogic;
an_ac_func_nsl_thold_7  : in std_ulogic;
an_ac_func_sl_thold_7   : in std_ulogic;
an_ac_gsd_test_enable_dc   : in std_ulogic;
an_ac_gsd_test_acmode_dc   : in std_ulogic;
an_ac_gptr_scan_in	   : in std_ulogic;
an_ac_hang_pulse	   : in std_ulogic_vector(0 to thdid_width-1);
an_ac_lbist_ac_mode_dc     : in std_ulogic;
an_ac_lbist_ip_dc	        : in std_ulogic;
an_ac_malf_alert	        : in std_ulogic;
an_ac_perf_interrupt	   : in std_ulogic_vector(0 to thdid_width-1);
an_ac_psro_enable_dc	   : in std_ulogic_vector(0 to 2);
an_ac_repr_scan_in	   : in std_ulogic;
an_ac_rtim_sl_thold_7	   : in std_ulogic;
an_ac_scan_type_dc	   : in std_ulogic_vector(0 to 8);
an_ac_scom_sat_id	   : in std_ulogic_vector(0 to 3);
an_ac_sg_7		   : in std_ulogic;
an_ac_tb_update_enable     : in std_ulogic;
an_ac_tb_update_pulse	: in std_ulogic;
an_ac_time_scan_in	   : in std_ulogic;
an_ac_crit_interrupt_omm      : out std_ulogic_vector(0 to thdid_width-1);
an_ac_ext_interrupt_omm       : out std_ulogic_vector(0 to thdid_width-1);
an_ac_flh2l2_gate_omm	   : out std_ulogic;
an_ac_icbi_ack_omm  	   : out std_ulogic;
an_ac_icbi_ack_thread_omm     : out std_ulogic_vector(0 to 1);
an_ac_req_ld_pop_omm	   : out std_ulogic;
an_ac_req_spare_ctrl_a1_omm   : out std_ulogic_vector(0 to 3);
an_ac_req_st_gather_omm	   : out std_ulogic;
an_ac_req_st_pop_omm	   : out std_ulogic;
an_ac_req_st_pop_thrd_omm     : out std_ulogic_vector(0 to 2);
an_ac_reservation_vld_omm     : out std_ulogic_vector(0 to thdid_width-1);
an_ac_sleep_en_omm  	   : out std_ulogic_vector(0 to thdid_width-1);
an_ac_stcx_pass_omm 	   : out std_ulogic_vector(0 to 3);
an_ac_sync_ack_omm  	   : out std_ulogic_vector(0 to 3);
an_ac_ary_nsl_thold_7_omm     : out std_ulogic;
an_ac_ccenable_dc_omm	   : out std_ulogic;
an_ac_coreid_omm	           : out std_ulogic_vector(0 to 7);
an_ac_external_mchk_omm       : out std_ulogic_vector(0 to 3);
an_ac_fce_7_omm	           : out std_ulogic;
an_ac_func_nsl_thold_7_omm    : out std_ulogic;
an_ac_func_sl_thold_7_omm     : out std_ulogic;
an_ac_gsd_test_enable_dc_omm   : out std_ulogic;
an_ac_gsd_test_acmode_dc_omm   : out std_ulogic;
an_ac_gptr_scan_in_omm	   : out std_ulogic;
an_ac_hang_pulse_omm	   : out std_ulogic_vector(0 to thdid_width-1);
an_ac_lbist_ac_mode_dc_omm     : out std_ulogic;
an_ac_lbist_ip_dc_omm	        : out std_ulogic;
an_ac_malf_alert_omm	        : out std_ulogic;
an_ac_perf_interrupt_omm	   : out std_ulogic_vector(0 to thdid_width-1);
an_ac_psro_enable_dc_omm	   : out std_ulogic_vector(0 to 2);
an_ac_repr_scan_in_omm	   : out std_ulogic;
an_ac_rtim_sl_thold_7_omm	   : out std_ulogic;
an_ac_scan_type_dc_omm	   : out std_ulogic_vector(0 to 8);
an_ac_scom_sat_id_omm	   : out std_ulogic_vector(0 to 3);
an_ac_sg_7_omm		   : out std_ulogic;
an_ac_tb_update_enable_omm     : out std_ulogic;
an_ac_tb_update_pulse_omm	: out std_ulogic;
an_ac_time_scan_in_omm	   : out std_ulogic;
ac_an_box_empty_imm 	      : in  std_ulogic_vector(0 to 3);
ac_an_machine_check_imm      : in  std_ulogic_vector(0 to thdid_width-1);
ac_an_req_imm		  : in  std_ulogic;
ac_an_req_endian_imm	  : in  std_ulogic;
ac_an_req_ld_core_tag_imm    : in  std_ulogic_vector(0 to 4);
ac_an_req_ld_xfr_len_imm     : in  std_ulogic_vector(0 to 2);
ac_an_req_pwr_token_imm      : in  std_ulogic;
ac_an_req_ra_imm	          : in  std_ulogic_vector(64-real_addr_width to 63);
ac_an_req_spare_ctrl_a0_imm  : in  std_ulogic_vector(0 to 3);
ac_an_req_thread_imm	  : in  std_ulogic_vector(0 to 2);
ac_an_req_ttype_imm 	  : in  std_ulogic_vector(0 to 5);
ac_an_req_user_defined_imm   : in  std_ulogic_vector(0 to 3);
ac_an_req_wimg_g_imm	      : in  std_ulogic;
ac_an_req_wimg_i_imm	      : in  std_ulogic;
ac_an_req_wimg_m_imm	      : in  std_ulogic;
ac_an_req_wimg_w_imm	      : in  std_ulogic;
ac_an_st_byte_enbl_imm	    : in  std_ulogic_vector(0 to 31);
ac_an_st_data_imm		    : in std_ulogic_vector(0 to 255);
ac_an_st_data_pwr_token_imm    : in  std_ulogic;
ac_an_abist_done_dc_imm	    : in std_ulogic;
ac_an_debug_trigger_imm	    : in std_ulogic_vector(0 to thdid_width-1);
ac_an_psro_ringsig_imm	   : in  std_ulogic;
ac_an_reset_1_request_imm	   : in  std_ulogic;
ac_an_reset_2_request_imm	   : in  std_ulogic;
ac_an_reset_3_request_imm	   : in  std_ulogic;
ac_an_reset_wd_request_imm        : in  std_ulogic;
ac_an_box_empty 	      : out std_ulogic_vector(0 to 3);
ac_an_machine_check      : out std_ulogic_vector(0 to thdid_width-1);
ac_an_req		      : out std_ulogic;
ac_an_req_endian	      : out std_ulogic;
ac_an_req_ld_core_tag    : out std_ulogic_vector(0 to 4);
ac_an_req_ld_xfr_len     : out std_ulogic_vector(0 to 2);
ac_an_req_pwr_token      : out std_ulogic;
ac_an_req_ra	      : out std_ulogic_vector(64-real_addr_width to 63);
ac_an_req_spare_ctrl_a0  : out std_ulogic_vector(0 to 3);
ac_an_req_thread	      : out std_ulogic_vector(0 to 2);
ac_an_req_ttype 	      : out std_ulogic_vector(0 to 5);
ac_an_req_user_defined   : out std_ulogic_vector(0 to 3);
ac_an_req_wimg_g	      : out std_ulogic;
ac_an_req_wimg_i	      : out std_ulogic;
ac_an_req_wimg_m	      : out std_ulogic;
ac_an_req_wimg_w	      : out std_ulogic;
ac_an_st_byte_enbl	        : out std_ulogic_vector(0 to 31);
ac_an_st_data		: out std_ulogic_vector(0 to 255);
ac_an_st_data_pwr_token    : out std_ulogic;
ac_an_abist_done_dc	: out std_ulogic;
ac_an_debug_trigger	: out std_ulogic_vector(0 to thdid_width-1);
ac_an_psro_ringsig	        : out std_ulogic;
ac_an_reset_1_request	   : out std_ulogic;
ac_an_reset_2_request	   : out std_ulogic;
ac_an_reset_3_request	   : out std_ulogic;
ac_an_reset_wd_request        : out std_ulogic;
ac_an_dcr_act		   : out std_ulogic;
ac_an_dcr_val		   : out std_ulogic;
ac_an_dcr_read  	   : out std_ulogic;
ac_an_dcr_user  	   : out std_ulogic;
ac_an_dcr_etid  	   : out std_ulogic_vector(0 to 1);
ac_an_dcr_addr  	   : out std_ulogic_vector(11 to 20);
ac_an_dcr_data	   : out std_ulogic_vector(64-spr_data_width to 63);
-- Pass thru wires specifically for Bluegene, PC -> IU -> MMU -> L1P/TPB
bg_ac_an_func_scan_ns_imm        : in  std_ulogic_vector(60 to 69);
bg_ac_an_abst_scan_ns_imm        : in  std_ulogic_vector(10 to 11);
bg_ac_an_func_scan_ns            : out std_ulogic_vector(60 to 69);
bg_ac_an_abst_scan_ns            : out std_ulogic_vector(10 to 11);
bg_pc_l1p_abist_di_0_imm           : in  std_ulogic_vector(0 to 3);
bg_pc_l1p_abist_g8t1p_renb_0_imm   : in  std_ulogic;
bg_pc_l1p_abist_g8t_bw_0_imm       : in  std_ulogic;
bg_pc_l1p_abist_g8t_bw_1_imm       : in  std_ulogic;
bg_pc_l1p_abist_g8t_dcomp_imm      : in  std_ulogic_vector(0 to 3);
bg_pc_l1p_abist_g8t_wenb_imm       : in  std_ulogic;
bg_pc_l1p_abist_raddr_0_imm        : in  std_ulogic_vector(0 to 9);
bg_pc_l1p_abist_waddr_0_imm        : in  std_ulogic_vector(0 to 9);
bg_pc_l1p_abist_wl128_comp_ena_imm : in  std_ulogic;
bg_pc_l1p_abist_wl32_comp_ena_imm  : in  std_ulogic;
bg_pc_l1p_abist_di_0               : out std_ulogic_vector(0 to 3);
bg_pc_l1p_abist_g8t1p_renb_0       : out std_ulogic;
bg_pc_l1p_abist_g8t_bw_0           : out std_ulogic;
bg_pc_l1p_abist_g8t_bw_1           : out std_ulogic;
bg_pc_l1p_abist_g8t_dcomp          : out std_ulogic_vector(0 to 3);
bg_pc_l1p_abist_g8t_wenb           : out std_ulogic;
bg_pc_l1p_abist_raddr_0            : out std_ulogic_vector(0 to 9);
bg_pc_l1p_abist_waddr_0            : out std_ulogic_vector(0 to 9);
bg_pc_l1p_abist_wl128_comp_ena     : out std_ulogic;
bg_pc_l1p_abist_wl32_comp_ena      : out std_ulogic;
bg_pc_l1p_gptr_sl_thold_2_imm      : in  std_ulogic;
bg_pc_l1p_time_sl_thold_2_imm      : in  std_ulogic;
bg_pc_l1p_repr_sl_thold_2_imm      : in  std_ulogic;
bg_pc_l1p_abst_sl_thold_2_imm      : in  std_ulogic;
bg_pc_l1p_func_sl_thold_2_imm      : in  std_ulogic_vector(0 to 1);
bg_pc_l1p_func_slp_sl_thold_2_imm  : in  std_ulogic;
bg_pc_l1p_bolt_sl_thold_2_imm      : in  std_ulogic;
bg_pc_l1p_ary_nsl_thold_2_imm      : in  std_ulogic;
bg_pc_l1p_sg_2_imm                 : in  std_ulogic_vector(0 to 1);
bg_pc_l1p_fce_2_imm                : in  std_ulogic;
bg_pc_l1p_bo_enable_2_imm          : in  std_ulogic;
bg_pc_l1p_gptr_sl_thold_2          : out std_ulogic;
bg_pc_l1p_time_sl_thold_2          : out std_ulogic;
bg_pc_l1p_repr_sl_thold_2          : out std_ulogic;
bg_pc_l1p_abst_sl_thold_2          : out std_ulogic;
bg_pc_l1p_func_sl_thold_2          : out std_ulogic_vector(0 to 1);
bg_pc_l1p_func_slp_sl_thold_2      : out std_ulogic;
bg_pc_l1p_bolt_sl_thold_2          : out std_ulogic;
bg_pc_l1p_ary_nsl_thold_2          : out std_ulogic;
bg_pc_l1p_sg_2                     : out std_ulogic_vector(0 to 1);
bg_pc_l1p_fce_2                    : out std_ulogic;
bg_pc_l1p_bo_enable_2              : out std_ulogic;
bg_pc_bo_unload_imm                : in  std_ulogic;
bg_pc_bo_load_imm                  : in  std_ulogic;
bg_pc_bo_repair_imm                : in  std_ulogic;
bg_pc_bo_reset_imm                 : in  std_ulogic;
bg_pc_bo_shdata_imm                : in  std_ulogic;
bg_pc_bo_select_imm                : in  std_ulogic_vector(0 to 10);
bg_pc_l1p_ccflush_dc_imm           : in  std_ulogic;
bg_pc_l1p_abist_ena_dc_imm         : in  std_ulogic;
bg_pc_l1p_abist_raw_dc_b_imm       : in  std_ulogic;
bg_pc_bo_unload                    : out std_ulogic;
bg_pc_bo_load                      : out std_ulogic;
bg_pc_bo_repair                    : out std_ulogic;
bg_pc_bo_reset                     : out std_ulogic;
bg_pc_bo_shdata                    : out std_ulogic;
bg_pc_bo_select                    : out std_ulogic_vector(0 to 10);
bg_pc_l1p_ccflush_dc               : out std_ulogic;
bg_pc_l1p_abist_ena_dc             : out std_ulogic;
bg_pc_l1p_abist_raw_dc_b           : out std_ulogic;
-- Pass thru wires specifically for Bluegene, L1P/TPB -> MMU -> IU -> PC
bg_an_ac_func_scan_sn              : in  std_ulogic_vector(60 to 69);
bg_an_ac_abst_scan_sn              : in  std_ulogic_vector(10 to 11);
bg_an_ac_func_scan_sn_omm          : out std_ulogic_vector(60 to 69);
bg_an_ac_abst_scan_sn_omm          : out std_ulogic_vector(10 to 11);
bg_pc_bo_fail                      : in  std_ulogic_vector(0 to 10);
bg_pc_bo_diagout                   : in  std_ulogic_vector(0 to 10);
bg_pc_bo_fail_omm                  : out std_ulogic_vector(0 to 10);
bg_pc_bo_diagout_omm               : out std_ulogic_vector(0 to 10)
);
end mmq;
architecture mmq of mmq is
constant MMU_Mode_Value : std_ulogic := '0';
constant TlbSel_Tlb : std_ulogic_vector(0 to 1) := "00";
constant TlbSel_IErat : std_ulogic_vector(0 to 1) := "10";
constant TlbSel_DErat : std_ulogic_vector(0 to 1) := "11";
-- func scan bit 0 is mmq_inval (701), mmq_spr(0) non-mas (439)  ~1140
-- func scan bit 1 is mmq_spr(1) mas regs (1017)  ~1017
-- func scan bit 2 is tlb_req  ~1196
-- func scan bit 3 is tlb_ctl ~1101
-- func scan bit 4 is tlb_cmp(0) ~1134
-- func scan bit 5 is tlb_cmp(1) ~1134
-- func scan bit 6 is tlb_lrat ~1059
-- func scan bit 7 is tlb_htw(0)  ~802
-- func scan bit 8 is tlb_htw(1)  ~663
-- func scan bit 9 is tlb_cmp(2), perf (60), debug daisy chain (134) ~636
constant mmq_inval_offset     :  natural := 0;
constant mmq_spr_offset_0     :  natural := mmq_inval_offset + 1;
constant scan_right_0         :  natural := mmq_spr_offset_0;
constant tlb_cmp2_offset      :  natural := 0;
constant mmq_perf_offset      :  natural := tlb_cmp2_offset + 1;
constant mmq_dbg_offset       :  natural := mmq_perf_offset + 1;
constant scan_right_1         :  natural := mmq_dbg_offset;
constant mmq_spr_bcfg_offset   : natural := 0;
constant boot_scan_right       : natural := mmq_spr_bcfg_offset + 1 - 1;
-- local spr signals
signal pid0_sig        : std_ulogic_vector(0 to pid_width-1);
signal pid1_sig        : std_ulogic_vector(0 to pid_width-1);
signal pid2_sig        : std_ulogic_vector(0 to pid_width-1);
signal pid3_sig        : std_ulogic_vector(0 to pid_width-1);
signal mmucr0_0_sig    : std_ulogic_vector(0 to mmucr0_width-1);
signal mmucr0_1_sig    : std_ulogic_vector(0 to mmucr0_width-1);
signal mmucr0_2_sig    : std_ulogic_vector(0 to mmucr0_width-1);
signal mmucr0_3_sig    : std_ulogic_vector(0 to mmucr0_width-1);
signal mmucr1_sig      : std_ulogic_vector(0 to mmucr1_width-1);
signal mmucr2_sig      : std_ulogic_vector(0 to mmucr2_width-1);
signal mmucr3_0_sig    : std_ulogic_vector(64-mmucr3_width to 63);
signal mmucr3_1_sig    : std_ulogic_vector(64-mmucr3_width to 63);
signal mmucr3_2_sig    : std_ulogic_vector(64-mmucr3_width to 63);
signal mmucr3_3_sig    : std_ulogic_vector(64-mmucr3_width to 63);
signal lpidr_sig       : std_ulogic_vector(0 to lpid_width-1);
signal ac_an_lpar_id_sig           : std_ulogic_vector(0 to lpid_width-1);
signal mm_iu_ierat_rel_val_sig        : std_ulogic_vector(0 to 4);
signal mm_iu_ierat_rel_data_sig       : std_ulogic_vector(0 to erat_rel_data_width-1);
signal mm_xu_derat_rel_val_sig        : std_ulogic_vector(0 to 4);
signal mm_xu_derat_rel_data_sig       : std_ulogic_vector(0 to erat_rel_data_width-1);
signal mm_xu_hold_req_sig : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_hold_done_sig : std_ulogic_vector(0 to thdid_width-1);
signal tlb_cmp_ierat_dup_val_sig        : std_ulogic_vector(0 to 6);
signal tlb_cmp_derat_dup_val_sig        : std_ulogic_vector(0 to 6);
signal tlb_cmp_erat_dup_wait_sig        : std_ulogic_vector(0 to 1);
signal tlb_ctl_ex2_flush_req_sig    : std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_ex2_illeg_instr_sig  : std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_barrier_done_sig     : std_ulogic_vector(0 to thdid_width-1);
signal mm_iu_barrier_done_sig   : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_ex3_flush_req_sig  : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_quiesce_sig        : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_eratmiss_done_sig   : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_tlb_miss_sig        : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_lrat_miss_sig        : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_pt_fault_sig         : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_hv_priv_sig          : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_illeg_instr_sig      : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_tlb_inelig_sig       : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_esr_pt_sig           : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_esr_data_sig         : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_esr_epid_sig         : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_esr_st_sig           : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_cr0_eq_sig           : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_cr0_eq_valid_sig     : std_ulogic_vector(0 to thdid_width-1);
signal mm_xu_local_snoop_reject_sig         : std_ulogic_vector(0 to thdid_width-1);
signal tlb_req_quiesce_sig   : std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_quiesce_sig : std_ulogic_vector(0 to thdid_width-1);
signal htw_quiesce_sig     : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_ccr2_notlb_b : std_ulogic_vector(1 to 12);
signal xu_mm_epcr_dgtmi_sig  : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_xucr4_mmu_mchk_q  : std_ulogic;
-- Internal signals
signal lru_write               : std_ulogic_vector(0 to lru_width-1);
signal lru_wr_addr             : std_ulogic_vector(0 to tlb_addr_width-1);
signal lru_rd_addr             : std_ulogic_vector(0 to tlb_addr_width-1);
signal lru_datain              : std_ulogic_vector(0 to lru_width-1);
signal lru_dataout             : std_ulogic_vector(0 to lru_width-1);
signal tlb_tag2_sig            : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_addr2_sig           : std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_write               : std_ulogic_vector(0 to tlb_ways-1);
signal tlb_addr                : std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_dataina              : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_datainb              : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_dataout             : std_ulogic_vector(0 to tlb_way_width*tlb_ways-1);
signal lru_tag4_dataout   : std_ulogic_vector(0 to 15);
signal tlb_tag4_esel      : std_ulogic_vector(0 to 2);
signal tlb_tag4_wq        : std_ulogic_vector(0 to 1);
signal tlb_tag4_is        : std_ulogic_vector(0 to 1);
signal tlb_tag4_gs        : std_ulogic;
signal tlb_tag4_pr        : std_ulogic;
signal tlb_tag4_hes       : std_ulogic;
signal tlb_tag4_atsel     : std_ulogic;
signal tlb_tag4_pt        : std_ulogic;
signal tlb_tag4_cmp_hit   : std_ulogic;
signal tlb_tag4_way_ind   : std_ulogic;
signal tlb_tag4_ptereload   : std_ulogic;
signal tlb_tag4_endflag   : std_ulogic;
signal tlb_tag4_parerr        : std_ulogic;
signal tlb_tag5_except   : std_ulogic_vector(0 to thdid_width-1);
signal ptereload_req_pte_lat   : std_ulogic_vector(0 to pte_width-1);
signal ex6_illeg_instr       : std_ulogic_vector(0 to 1);
signal tlb_ctl_tag2_flush_sig        : std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_tag3_flush_sig        : std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_tag4_flush_sig        : std_ulogic_vector(0 to thdid_width-1);
signal tlb_resv_match_vec_sig        : std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_ex3_valid_sig : std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_ex3_ttype_sig : std_ulogic_vector(0 to 4);
signal ierat_req_taken        : std_ulogic;
signal derat_req_taken        : std_ulogic;
signal tlb_seq_ierat_req    : std_ulogic;
signal tlb_seq_derat_req    : std_ulogic;
signal tlb_seq_ierat_done   : std_ulogic;
signal tlb_seq_derat_done   : std_ulogic;
signal tlb_seq_idle    : std_ulogic;
signal ierat_req_epn           : std_ulogic_vector(0 to req_epn_width-1);
signal ierat_req_pid           : std_ulogic_vector(0 to pid_width-1);
signal ierat_req_state         : std_ulogic_vector(0 to state_width-1);
signal ierat_req_thdid         : std_ulogic_vector(0 to thdid_width-1);
signal ierat_req_dup           : std_ulogic_vector(0 to 1);
signal derat_req_epn           : std_ulogic_vector(0 to req_epn_width-1);
signal derat_req_pid           : std_ulogic_vector(0 to pid_width-1);
signal derat_req_lpid          : std_ulogic_vector(0 to lpid_width-1);
signal derat_req_state         : std_ulogic_vector(0 to state_width-1);
signal derat_req_ttype         : std_ulogic_vector(0 to 1);
signal derat_req_thdid         : std_ulogic_vector(0 to thdid_width-1);
signal derat_req_dup           : std_ulogic_vector(0 to 1);
signal ptereload_req_valid :  std_ulogic;
signal ptereload_req_tag   :  std_ulogic_vector(0 to tlb_tag_width-1);
signal ptereload_req_pte   :  std_ulogic_vector(0 to pte_width-1);
signal ptereload_req_taken :  std_ulogic;
signal tlb_htw_req_valid : std_ulogic;
signal tlb_htw_req_tag   : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_htw_req_way   : std_ulogic_vector(tlb_word_width to tlb_way_width-1);
signal htw_lsu_req_valid        : std_ulogic;
signal htw_lsu_thdid        : std_ulogic_vector(0 to thdid_width-1);
signal htw_dbg_lsu_thdid        : std_ulogic_vector(0 to 1);
-- 0=tlbivax_op, 1=tlbi_complete, 2=mmu read with core_tag=01100, 3=mmu read with core_tag=01101
signal htw_lsu_ttype            : std_ulogic_vector(0 to 1);
signal htw_lsu_wimge            : std_ulogic_vector(0 to 4);
signal htw_lsu_u                : std_ulogic_vector(0 to 3);
signal htw_lsu_addr             : std_ulogic_vector(64-real_addr_width to 63);
signal htw_lsu_req_taken        : std_ulogic;
signal htw_req0_valid           : std_ulogic;
signal htw_req0_thdid           : std_ulogic_vector(0 to thdid_width-1);
signal htw_req0_type            : std_ulogic_vector(0 to 1);
signal htw_req1_valid           : std_ulogic;
signal htw_req1_thdid           : std_ulogic_vector(0 to thdid_width-1);
signal htw_req1_type            : std_ulogic_vector(0 to 1);
signal htw_req2_valid           : std_ulogic;
signal htw_req2_thdid           : std_ulogic_vector(0 to thdid_width-1);
signal htw_req2_type            : std_ulogic_vector(0 to 1);
signal htw_req3_valid           : std_ulogic;
signal htw_req3_thdid           : std_ulogic_vector(0 to thdid_width-1);
signal htw_req3_type            : std_ulogic_vector(0 to 1);
signal mm_xu_lsu_req_sig              :      std_ulogic_vector(0 to 3);
signal mm_xu_lsu_ttype_sig            :      std_ulogic_vector(0 to 1);
signal mm_xu_lsu_wimge_sig            :      std_ulogic_vector(0 to 4);
signal mm_xu_lsu_u_sig                :      std_ulogic_vector(0 to 3);
signal mm_xu_lsu_addr_sig             :      std_ulogic_vector(64-real_addr_width to 63);
signal mm_xu_lsu_lpid_sig             :   std_ulogic_vector(0 to 7);
signal mm_xu_lsu_gs_sig               :   std_ulogic;
signal mm_xu_lsu_ind_sig              :   std_ulogic;
signal mm_xu_lsu_lbit_sig             :   std_ulogic;
signal xu_mm_ex2_eff_addr_sig   :  std_ulogic_vector(64-rs_data_width to 63);
signal repr_scan_int :  std_ulogic_vector(0 to 5);
signal time_scan_int :  std_ulogic_vector(0 to 5);
signal abst_scan_int :  std_ulogic_vector(0 to 6);
signal tlbwe_back_inv_valid_sig   : std_ulogic;
signal tlbwe_back_inv_thdid_sig   : std_ulogic_vector(0 to thdid_width-1);
signal tlbwe_back_inv_addr_sig    : std_ulogic_vector(52-epn_width to 51);
signal tlbwe_back_inv_attr_sig    : std_ulogic_vector(0 to 34);
signal tlbwe_back_inv_pending_sig   : std_ulogic;
signal tlb_tag5_write    : std_ulogic;
--  these are needed regardless of tlb existence
signal tlb_snoop_coming   : std_ulogic;
signal tlb_snoop_val      : std_ulogic;
signal tlb_snoop_attr     : std_ulogic_vector(0 to 34);
signal tlb_snoop_vpn      : std_ulogic_vector(52-epn_width to 51);
signal tlb_snoop_ack      : std_ulogic;
signal mas0_0_atsel            : std_ulogic;
signal mas0_0_esel             : std_ulogic_vector(0 to 2);
signal mas0_0_hes              : std_ulogic;
signal mas0_0_wq               : std_ulogic_vector(0 to 1);
signal mas1_0_v                : std_ulogic;
signal mas1_0_iprot            : std_ulogic;
signal mas1_0_tid              : std_ulogic_vector(0 to 13);
signal mas1_0_ind              : std_ulogic;
signal mas1_0_ts               : std_ulogic;
signal mas1_0_tsize            : std_ulogic_vector(0 to 3);
signal mas2_0_epn              : std_ulogic_vector(0 to 51);
signal mas2_0_wimge            : std_ulogic_vector(0 to 4);
signal mas3_0_rpnl             : std_ulogic_vector(32 to 52);
signal mas3_0_ubits            : std_ulogic_vector(0 to 3);
signal mas3_0_usxwr            : std_ulogic_vector(0 to 5);
signal mas5_0_sgs              : std_ulogic;
signal mas5_0_slpid            : std_ulogic_vector(0 to 7);
signal mas6_0_spid             : std_ulogic_vector(0 to 13);
signal mas6_0_isize            : std_ulogic_vector(0 to 3);
signal mas6_0_sind             : std_ulogic;
signal mas6_0_sas              : std_ulogic;
signal mas7_0_rpnu             : std_ulogic_vector(22 to 31);
signal mas8_0_tgs              : std_ulogic;
signal mas8_0_vf               : std_ulogic;
signal mas8_0_tlpid            : std_ulogic_vector(0 to 7);
signal mas0_1_atsel            : std_ulogic;
signal mas0_1_esel             : std_ulogic_vector(0 to 2);
signal mas0_1_hes              : std_ulogic;
signal mas0_1_wq               : std_ulogic_vector(0 to 1);
signal mas1_1_v                : std_ulogic;
signal mas1_1_iprot            : std_ulogic;
signal mas1_1_tid              : std_ulogic_vector(0 to 13);
signal mas1_1_ind              : std_ulogic;
signal mas1_1_ts               : std_ulogic;
signal mas1_1_tsize            : std_ulogic_vector(0 to 3);
signal mas2_1_epn              : std_ulogic_vector(0 to 51);
signal mas2_1_wimge            : std_ulogic_vector(0 to 4);
signal mas3_1_rpnl             : std_ulogic_vector(32 to 52);
signal mas3_1_ubits            : std_ulogic_vector(0 to 3);
signal mas3_1_usxwr            : std_ulogic_vector(0 to 5);
signal mas5_1_sgs              : std_ulogic;
signal mas5_1_slpid            : std_ulogic_vector(0 to 7);
signal mas6_1_spid             : std_ulogic_vector(0 to 13);
signal mas6_1_isize            : std_ulogic_vector(0 to 3);
signal mas6_1_sind             : std_ulogic;
signal mas6_1_sas              : std_ulogic;
signal mas7_1_rpnu             : std_ulogic_vector(22 to 31);
signal mas8_1_tgs              : std_ulogic;
signal mas8_1_vf               : std_ulogic;
signal mas8_1_tlpid            : std_ulogic_vector(0 to 7);
signal mas0_2_atsel            : std_ulogic;
signal mas0_2_esel             : std_ulogic_vector(0 to 2);
signal mas0_2_hes              : std_ulogic;
signal mas0_2_wq               : std_ulogic_vector(0 to 1);
signal mas1_2_v                : std_ulogic;
signal mas1_2_iprot            : std_ulogic;
signal mas1_2_tid              : std_ulogic_vector(0 to 13);
signal mas1_2_ind              : std_ulogic;
signal mas1_2_ts               : std_ulogic;
signal mas1_2_tsize            : std_ulogic_vector(0 to 3);
signal mas2_2_epn              : std_ulogic_vector(0 to 51);
signal mas2_2_wimge            : std_ulogic_vector(0 to 4);
signal mas3_2_rpnl             : std_ulogic_vector(32 to 52);
signal mas3_2_ubits            : std_ulogic_vector(0 to 3);
signal mas3_2_usxwr            : std_ulogic_vector(0 to 5);
signal mas5_2_sgs              : std_ulogic;
signal mas5_2_slpid            : std_ulogic_vector(0 to 7);
signal mas6_2_spid             : std_ulogic_vector(0 to 13);
signal mas6_2_isize            : std_ulogic_vector(0 to 3);
signal mas6_2_sind             : std_ulogic;
signal mas6_2_sas              : std_ulogic;
signal mas7_2_rpnu             : std_ulogic_vector(22 to 31);
signal mas8_2_tgs              : std_ulogic;
signal mas8_2_vf               : std_ulogic;
signal mas8_2_tlpid            : std_ulogic_vector(0 to 7);
signal mas0_3_atsel            : std_ulogic;
signal mas0_3_esel             : std_ulogic_vector(0 to 2);
signal mas0_3_hes              : std_ulogic;
signal mas0_3_wq               : std_ulogic_vector(0 to 1);
signal mas1_3_v                : std_ulogic;
signal mas1_3_iprot            : std_ulogic;
signal mas1_3_tid              : std_ulogic_vector(0 to 13);
signal mas1_3_ind              : std_ulogic;
signal mas1_3_ts               : std_ulogic;
signal mas1_3_tsize            : std_ulogic_vector(0 to 3);
signal mas2_3_epn              : std_ulogic_vector(0 to 51);
signal mas2_3_wimge            : std_ulogic_vector(0 to 4);
signal mas3_3_rpnl             : std_ulogic_vector(32 to 52);
signal mas3_3_ubits            : std_ulogic_vector(0 to 3);
signal mas3_3_usxwr            : std_ulogic_vector(0 to 5);
signal mas5_3_sgs              : std_ulogic;
signal mas5_3_slpid            : std_ulogic_vector(0 to 7);
signal mas6_3_spid             : std_ulogic_vector(0 to 13);
signal mas6_3_isize            : std_ulogic_vector(0 to 3);
signal mas6_3_sind             : std_ulogic;
signal mas6_3_sas              : std_ulogic;
signal mas7_3_rpnu             : std_ulogic_vector(22 to 31);
signal mas8_3_tgs              : std_ulogic;
signal mas8_3_vf               : std_ulogic;
signal mas8_3_tlpid            : std_ulogic_vector(0 to 7);
signal mmucfg_lrat            : std_ulogic;
signal mmucfg_twc             : std_ulogic;
signal mmucsr0_tlb0fi         : std_ulogic;
signal mmq_inval_tlb0fi_done  : std_ulogic;
signal tlb0cfg_pt             : std_ulogic;
signal tlb0cfg_ind            : std_ulogic;
signal tlb0cfg_gtwe           : std_ulogic;
signal tlb_mas0_esel          : std_ulogic_vector(0 to 2);
signal tlb_mas1_v             : std_ulogic;
signal tlb_mas1_iprot         : std_ulogic;
signal tlb_mas1_tid           : std_ulogic_vector(0 to pid_width-1);
signal tlb_mas1_tid_error     : std_ulogic_vector(0 to pid_width-1);
signal tlb_mas1_ind           : std_ulogic;
signal tlb_mas1_ts            : std_ulogic;
signal tlb_mas1_ts_error      : std_ulogic;
signal tlb_mas1_tsize         : std_ulogic_vector(0 to 3);
signal tlb_mas2_epn           : std_ulogic_vector(0 to 51);
signal tlb_mas2_epn_error     : std_ulogic_vector(0 to 51);
signal tlb_mas2_wimge         : std_ulogic_vector(0 to 4);
signal tlb_mas3_rpnl          : std_ulogic_vector(32 to 51);
signal tlb_mas3_ubits         : std_ulogic_vector(0 to 3);
signal tlb_mas3_usxwr         : std_ulogic_vector(0 to 5);
signal tlb_mas6_spid          : std_ulogic_vector(0 to pid_width-1);
signal tlb_mas6_isize         : std_ulogic_vector(0 to 3);
signal tlb_mas6_sind          : std_ulogic;
signal tlb_mas6_sas           : std_ulogic;
signal tlb_mas7_rpnu          : std_ulogic_vector(22 to 31);
signal tlb_mas8_tgs           : std_ulogic;
signal tlb_mas8_vf            : std_ulogic;
signal tlb_mas8_tlpid         : std_ulogic_vector(0 to 7);
signal tlb_mmucr1_een         : std_ulogic_vector(0 to 8);
signal tlb_mmucr1_we          : std_ulogic;
signal tlb_mmucr3_thdid       : std_ulogic_vector(0 to thdid_width-1);
signal tlb_mmucr3_resvattr    : std_ulogic;
signal tlb_mmucr3_wlc         : std_ulogic_vector(0 to 1);
signal tlb_mmucr3_class       : std_ulogic_vector(0 to class_width-1);
signal tlb_mmucr3_extclass    : std_ulogic_vector(0 to extclass_width-1);
signal tlb_mmucr3_rc          : std_ulogic_vector(0 to 1);
signal tlb_mmucr3_x           : std_ulogic;
signal tlb_mas_tlbre          : std_ulogic;
signal tlb_mas_tlbsx_hit      : std_ulogic;
signal tlb_mas_tlbsx_miss     : std_ulogic;
signal tlb_mas_dtlb_error     : std_ulogic;
signal tlb_mas_itlb_error     : std_ulogic;
signal tlb_mas_thdid          : std_ulogic_vector(0 to 3);
signal lrat_mas0_esel         : std_ulogic_vector(0 to 2);
signal lrat_mas1_v            : std_ulogic;
signal lrat_mas1_tsize        : std_ulogic_vector(0 to 3);
signal lrat_mas2_epn          : std_ulogic_vector(0 to 51);
signal lrat_mas3_rpnl         : std_ulogic_vector(32 to 51);
signal lrat_mas7_rpnu         : std_ulogic_vector(22 to 31);
signal lrat_mas8_tlpid        : std_ulogic_vector(0 to lpid_width-1);
signal lrat_mmucr3_x          : std_ulogic;
signal lrat_mas_tlbre         : std_ulogic;
signal lrat_mas_tlbsx_hit     : std_ulogic;
signal lrat_mas_tlbsx_miss    : std_ulogic;
signal lrat_mas_thdid         : std_ulogic_vector(0 to 3);
signal lrat_tag3_lpn              : std_ulogic_vector(64-real_addr_width to 51);
signal lrat_tag3_rpn              : std_ulogic_vector(64-real_addr_width to 51);
signal lrat_tag3_hit_status       : std_ulogic_vector(0 to 3);
signal lrat_tag3_hit_entry        : std_ulogic_vector(0 to lrat_num_entry_log2-1);
signal lrat_tag4_lpn              : std_ulogic_vector(64-real_addr_width to 51);
signal lrat_tag4_rpn              : std_ulogic_vector(64-real_addr_width to 51);
signal lrat_tag4_hit_status       : std_ulogic_vector(0 to 3);
signal lrat_tag4_hit_entry        : std_ulogic_vector(0 to lrat_num_entry_log2-1);
signal tlb_tag0_epn         : std_ulogic_vector(52-epn_width to 51);
signal tlb_tag0_thdid       : std_ulogic_vector(0 to thdid_width-1);
signal tlb_tag0_type        : std_ulogic_vector(0 to 7);
signal tlb_tag0_lpid        : std_ulogic_vector(0 to lpid_width-1);
signal tlb_tag0_atsel       : std_ulogic;
signal tlb_tag0_size        : std_ulogic_vector(0 to 3);
signal tlb_tag0_addr_cap    : std_ulogic;
signal pte_tag0_lpn      : std_ulogic_vector(64-real_addr_width to 51);
signal pte_tag0_lpid     : std_ulogic_vector(0 to lpid_width-1);
signal tlb_lper_lpn         : std_ulogic_vector(64-real_addr_width to 51);
signal tlb_lper_lps         : std_ulogic_vector(60 to 63);
signal tlb_lper_we          : std_ulogic_vector(0 to thdid_width-1);
signal ierat_req0_pid_sig    :  std_ulogic_vector(0 to pid_width-1);
signal ierat_req0_as_sig     :  std_ulogic;
signal ierat_req0_gs_sig     :  std_ulogic;
signal ierat_req0_epn_sig    :  std_ulogic_vector(0 to epn_width-1);
signal ierat_req0_thdid_sig    :  std_ulogic_vector(0 to thdid_width-1);
signal ierat_req0_valid_sig    :  std_ulogic;
signal ierat_req0_nonspec_sig    :  std_ulogic;
signal ierat_req1_pid_sig    :  std_ulogic_vector(0 to pid_width-1);
signal ierat_req1_as_sig     :  std_ulogic;
signal ierat_req1_gs_sig     :  std_ulogic;
signal ierat_req1_epn_sig    :  std_ulogic_vector(0 to epn_width-1);
signal ierat_req1_thdid_sig    :  std_ulogic_vector(0 to thdid_width-1);
signal ierat_req1_valid_sig    :  std_ulogic;
signal ierat_req1_nonspec_sig    :  std_ulogic;
signal ierat_req2_pid_sig    :  std_ulogic_vector(0 to pid_width-1);
signal ierat_req2_as_sig     :  std_ulogic;
signal ierat_req2_gs_sig     :  std_ulogic;
signal ierat_req2_epn_sig    :  std_ulogic_vector(0 to epn_width-1);
signal ierat_req2_thdid_sig    :  std_ulogic_vector(0 to thdid_width-1);
signal ierat_req2_valid_sig    :  std_ulogic;
signal ierat_req2_nonspec_sig    :  std_ulogic;
signal ierat_req3_pid_sig    :  std_ulogic_vector(0 to pid_width-1);
signal ierat_req3_as_sig     :  std_ulogic;
signal ierat_req3_gs_sig     :  std_ulogic;
signal ierat_req3_epn_sig    :  std_ulogic_vector(0 to epn_width-1);
signal ierat_req3_thdid_sig    :  std_ulogic_vector(0 to thdid_width-1);
signal ierat_req3_valid_sig    :  std_ulogic;
signal ierat_req3_nonspec_sig    :  std_ulogic;
signal ierat_iu4_pid_sig    :   std_ulogic_vector(0 to pid_width-1);
signal ierat_iu4_gs_sig     :   std_ulogic;
signal ierat_iu4_as_sig     :   std_ulogic;
signal ierat_iu4_epn_sig    :   std_ulogic_vector(0 to epn_width-1);
signal ierat_iu4_thdid_sig  :   std_ulogic_vector(0 to thdid_width-1);
signal ierat_iu4_valid_sig  :   std_ulogic;
signal derat_req0_lpid_sig   :  std_ulogic_vector(0 to lpid_width-1);
signal derat_req0_pid_sig    :  std_ulogic_vector(0 to pid_width-1);
signal derat_req0_as_sig    :  std_ulogic;
signal derat_req0_gs_sig    :  std_ulogic;
signal derat_req0_epn_sig    :  std_ulogic_vector(0 to epn_width-1);
signal derat_req0_thdid_sig    :  std_ulogic_vector(0 to thdid_width-1);
signal derat_req0_valid_sig    :  std_ulogic;
signal derat_req1_lpid_sig   :  std_ulogic_vector(0 to lpid_width-1);
signal derat_req1_pid_sig    :  std_ulogic_vector(0 to pid_width-1);
signal derat_req1_as_sig    :  std_ulogic;
signal derat_req1_gs_sig    :  std_ulogic;
signal derat_req1_epn_sig    :  std_ulogic_vector(0 to epn_width-1);
signal derat_req1_thdid_sig    :  std_ulogic_vector(0 to thdid_width-1);
signal derat_req1_valid_sig    :  std_ulogic;
signal derat_req2_lpid_sig   :  std_ulogic_vector(0 to lpid_width-1);
signal derat_req2_pid_sig    :  std_ulogic_vector(0 to pid_width-1);
signal derat_req2_as_sig    :  std_ulogic;
signal derat_req2_gs_sig    :  std_ulogic;
signal derat_req2_epn_sig    :  std_ulogic_vector(0 to epn_width-1);
signal derat_req2_thdid_sig    :  std_ulogic_vector(0 to thdid_width-1);
signal derat_req2_valid_sig    :  std_ulogic;
signal derat_req3_lpid_sig   :  std_ulogic_vector(0 to lpid_width-1);
signal derat_req3_pid_sig    :  std_ulogic_vector(0 to pid_width-1);
signal derat_req3_as_sig    :  std_ulogic;
signal derat_req3_gs_sig    :  std_ulogic;
signal derat_req3_epn_sig    :  std_ulogic_vector(0 to epn_width-1);
signal derat_req3_thdid_sig    :  std_ulogic_vector(0 to thdid_width-1);
signal derat_req3_valid_sig    :  std_ulogic;
signal derat_ex5_lpid_sig   :   std_ulogic_vector(0 to lpid_width-1);
signal derat_ex5_pid_sig    :   std_ulogic_vector(0 to pid_width-1);
signal derat_ex5_gs_sig     :   std_ulogic;
signal derat_ex5_as_sig     :   std_ulogic;
signal derat_ex5_epn_sig    :   std_ulogic_vector(0 to epn_width-1);
signal derat_ex5_thdid_sig  :   std_ulogic_vector(0 to thdid_width-1);
signal derat_ex5_valid_sig  :   std_ulogic;
signal tlb_cmp_perf_event_t0  :   std_ulogic_vector(0 to 9);
signal tlb_cmp_perf_event_t1  :   std_ulogic_vector(0 to 9);
signal tlb_cmp_perf_event_t2  :   std_ulogic_vector(0 to 9);
signal tlb_cmp_perf_event_t3  :   std_ulogic_vector(0 to 9);
signal tlb_cmp_perf_state     :   std_ulogic_vector(0 to 1);
signal tlb_cmp_perf_miss_direct       : std_ulogic;
signal tlb_cmp_perf_hit_indirect      : std_ulogic;
signal tlb_cmp_perf_hit_first_page    : std_ulogic;
signal tlb_cmp_perf_ptereload_noexcep : std_ulogic;
signal tlb_cmp_perf_lrat_request      : std_ulogic;
signal tlb_cmp_perf_lrat_miss         : std_ulogic;
signal tlb_cmp_perf_pt_fault          : std_ulogic;
signal tlb_cmp_perf_pt_inelig         : std_ulogic;
signal tlb_ctl_perf_tlbwec_resv     : std_ulogic;
signal tlb_ctl_perf_tlbwec_noresv   : std_ulogic;
signal inval_perf_tlbilx             : std_ulogic;
signal inval_perf_tlbivax            : std_ulogic;
signal inval_perf_tlbivax_snoop      : std_ulogic;
signal inval_perf_tlb_flush          : std_ulogic;
----------- debug signals
signal spr_dbg_match_64b           : std_ulogic;
signal spr_dbg_match_any_mmu       : std_ulogic;
signal spr_dbg_match_any_mas       : std_ulogic;
signal spr_dbg_match_pid           : std_ulogic;
signal spr_dbg_match_lpidr         : std_ulogic;
signal spr_dbg_match_mmucr0        : std_ulogic;
signal spr_dbg_match_mmucr1        : std_ulogic;
signal spr_dbg_match_mmucr2        : std_ulogic;
signal spr_dbg_match_mmucr3        : std_ulogic;
signal spr_dbg_match_mmucsr0       : std_ulogic;
signal spr_dbg_match_mmucfg        : std_ulogic;
signal spr_dbg_match_tlb0cfg       : std_ulogic;
signal spr_dbg_match_tlb0ps        : std_ulogic;
signal spr_dbg_match_lratcfg       : std_ulogic;
signal spr_dbg_match_lratps        : std_ulogic;
signal spr_dbg_match_eptcfg        : std_ulogic;
signal spr_dbg_match_lper          : std_ulogic;
signal spr_dbg_match_lperu         : std_ulogic;
signal spr_dbg_match_mas0          : std_ulogic;
signal spr_dbg_match_mas1          : std_ulogic;
signal spr_dbg_match_mas2          : std_ulogic;
signal spr_dbg_match_mas2u         : std_ulogic;
signal spr_dbg_match_mas3          : std_ulogic;
signal spr_dbg_match_mas4          : std_ulogic;
signal spr_dbg_match_mas5          : std_ulogic;
signal spr_dbg_match_mas6          : std_ulogic;
signal spr_dbg_match_mas7          : std_ulogic;
signal spr_dbg_match_mas8          : std_ulogic;
signal spr_dbg_match_mas01_64b     : std_ulogic;
signal spr_dbg_match_mas56_64b     : std_ulogic;
signal spr_dbg_match_mas73_64b     : std_ulogic;
signal spr_dbg_match_mas81_64b     : std_ulogic;
signal spr_dbg_slowspr_val_int         : std_ulogic;
signal spr_dbg_slowspr_rw_int          : std_ulogic;
signal spr_dbg_slowspr_etid_int        : std_ulogic_vector(0 to 1);
signal spr_dbg_slowspr_addr_int        : std_ulogic_vector(0 to 9);
signal spr_dbg_slowspr_val_out         : std_ulogic;
signal spr_dbg_slowspr_done_out        : std_ulogic;
signal spr_dbg_slowspr_data_out        : std_ulogic_vector(64-spr_data_width to 63);
signal inval_dbg_seq_q                  : std_ulogic_vector(0 to 4);
signal inval_dbg_seq_idle               : std_ulogic;
signal inval_dbg_seq_snoop_inprogress   : std_ulogic;
signal inval_dbg_seq_snoop_done         : std_ulogic;
signal inval_dbg_seq_local_done         : std_ulogic;
signal inval_dbg_seq_tlb0fi_done        : std_ulogic;
signal inval_dbg_seq_tlbwe_snoop_done   : std_ulogic;
signal inval_dbg_ex6_valid              : std_ulogic;
signal inval_dbg_ex6_thdid              : std_ulogic_vector(0 to 1);
signal inval_dbg_ex6_ttype              : std_ulogic_vector(0 to 2);
signal inval_dbg_snoop_forme            : std_ulogic;
signal inval_dbg_snoop_local_reject     : std_ulogic;
signal inval_dbg_an_ac_back_inv_q       : std_ulogic_vector(2 to 8);
signal inval_dbg_an_ac_back_inv_lpar_id_q   : std_ulogic_vector(0 to 7);
signal inval_dbg_an_ac_back_inv_addr_q      : std_ulogic_vector(22 to 63);
signal inval_dbg_snoop_valid_q          : std_ulogic_vector(0 to 2);
signal inval_dbg_snoop_ack_q            : std_ulogic_vector(0 to 2);
signal inval_dbg_snoop_attr_q           : std_ulogic_vector(0 to 34);
signal inval_dbg_snoop_attr_tlb_spec_q  : std_ulogic_vector(18 to 19);
signal inval_dbg_snoop_vpn_q            : std_ulogic_vector(17 to 51);
signal inval_dbg_lsu_tokens_q           : std_ulogic_vector(0 to 1);
signal tlb_req_dbg_ierat_iu5_valid_q    :  std_ulogic;
signal tlb_req_dbg_ierat_iu5_thdid      :  std_ulogic_vector(0 to 1);
signal tlb_req_dbg_ierat_iu5_state_q    :  std_ulogic_vector(0 to 3);
signal tlb_req_dbg_ierat_inptr_q        :  std_ulogic_vector(0 to 1);
signal tlb_req_dbg_ierat_outptr_q       :  std_ulogic_vector(0 to 1);
signal tlb_req_dbg_ierat_req_valid_q    :  std_ulogic_vector(0 to 3);
signal tlb_req_dbg_ierat_req_nonspec_q  :  std_ulogic_vector(0 to 3);
signal tlb_req_dbg_ierat_req_thdid      :  std_ulogic_vector(0 to 7);
signal tlb_req_dbg_ierat_req_dup_q      :  std_ulogic_vector(0 to 3);
signal tlb_req_dbg_derat_ex6_valid_q    :  std_ulogic;
signal tlb_req_dbg_derat_ex6_thdid      :  std_ulogic_vector(0 to 1);
signal tlb_req_dbg_derat_ex6_state_q    :  std_ulogic_vector(0 to 3);
signal tlb_req_dbg_derat_inptr_q        :  std_ulogic_vector(0 to 1);
signal tlb_req_dbg_derat_outptr_q       :  std_ulogic_vector(0 to 1);
signal tlb_req_dbg_derat_req_valid_q    :  std_ulogic_vector(0 to 3);
signal tlb_req_dbg_derat_req_thdid      :  std_ulogic_vector(0 to 7);
signal tlb_req_dbg_derat_req_ttype_q    :  std_ulogic_vector(0 to 7);
signal tlb_req_dbg_derat_req_dup_q      :  std_ulogic_vector(0 to 3);
signal tlb_ctl_dbg_seq_q                :  std_ulogic_vector(0 to 5);
signal tlb_ctl_dbg_seq_idle             :  std_ulogic;
signal tlb_ctl_dbg_seq_any_done_sig     :  std_ulogic;
signal tlb_ctl_dbg_seq_abort            :  std_ulogic;
signal tlb_ctl_dbg_any_tlb_req_sig      :  std_ulogic;
signal tlb_ctl_dbg_any_req_taken_sig    :  std_ulogic;
signal tlb_ctl_dbg_tag0_valid          :  std_ulogic;
signal tlb_ctl_dbg_tag0_thdid          :  std_ulogic_vector(0 to 1);
signal tlb_ctl_dbg_tag0_type           :  std_ulogic_vector(0 to 2);
signal tlb_ctl_dbg_tag0_wq             :  std_ulogic_vector(0 to 1);
signal tlb_ctl_dbg_tag0_gs             :  std_ulogic;
signal tlb_ctl_dbg_tag0_pr             :  std_ulogic;
signal tlb_ctl_dbg_tag0_atsel          :  std_ulogic;
signal tlb_ctl_dbg_tag5_tlb_write_q     : std_ulogic_vector(0 to 3);
signal tlb_ctl_dbg_resv_valid          :  std_ulogic_vector(0 to 3);
signal tlb_ctl_dbg_set_resv            :  std_ulogic_vector(0 to 3);
signal tlb_ctl_dbg_resv_match_vec_q    :  std_ulogic_vector(0 to 3);
signal tlb_ctl_dbg_any_tag_flush_sig   :  std_ulogic;
signal tlb_ctl_dbg_resv0_tag0_lpid_match         : std_ulogic;
signal tlb_ctl_dbg_resv0_tag0_pid_match          : std_ulogic;
signal tlb_ctl_dbg_resv0_tag0_as_snoop_match     : std_ulogic;
signal tlb_ctl_dbg_resv0_tag0_gs_snoop_match     : std_ulogic;
signal tlb_ctl_dbg_resv0_tag0_as_tlbwe_match     : std_ulogic;
signal tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match     : std_ulogic;
signal tlb_ctl_dbg_resv0_tag0_ind_match          : std_ulogic;
signal tlb_ctl_dbg_resv0_tag0_epn_loc_match      : std_ulogic;
signal tlb_ctl_dbg_resv0_tag0_epn_glob_match     : std_ulogic;
signal tlb_ctl_dbg_resv0_tag0_class_match        : std_ulogic;
signal tlb_ctl_dbg_resv1_tag0_lpid_match         : std_ulogic;
signal tlb_ctl_dbg_resv1_tag0_pid_match          : std_ulogic;
signal tlb_ctl_dbg_resv1_tag0_as_snoop_match     : std_ulogic;
signal tlb_ctl_dbg_resv1_tag0_gs_snoop_match     : std_ulogic;
signal tlb_ctl_dbg_resv1_tag0_as_tlbwe_match     : std_ulogic;
signal tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match     : std_ulogic;
signal tlb_ctl_dbg_resv1_tag0_ind_match          : std_ulogic;
signal tlb_ctl_dbg_resv1_tag0_epn_loc_match      : std_ulogic;
signal tlb_ctl_dbg_resv1_tag0_epn_glob_match     : std_ulogic;
signal tlb_ctl_dbg_resv1_tag0_class_match        : std_ulogic;
signal tlb_ctl_dbg_resv2_tag0_lpid_match         : std_ulogic;
signal tlb_ctl_dbg_resv2_tag0_pid_match          : std_ulogic;
signal tlb_ctl_dbg_resv2_tag0_as_snoop_match     : std_ulogic;
signal tlb_ctl_dbg_resv2_tag0_gs_snoop_match     : std_ulogic;
signal tlb_ctl_dbg_resv2_tag0_as_tlbwe_match     : std_ulogic;
signal tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match     : std_ulogic;
signal tlb_ctl_dbg_resv2_tag0_ind_match          : std_ulogic;
signal tlb_ctl_dbg_resv2_tag0_epn_loc_match      : std_ulogic;
signal tlb_ctl_dbg_resv2_tag0_epn_glob_match     : std_ulogic;
signal tlb_ctl_dbg_resv2_tag0_class_match        : std_ulogic;
signal tlb_ctl_dbg_resv3_tag0_lpid_match         : std_ulogic;
signal tlb_ctl_dbg_resv3_tag0_pid_match          : std_ulogic;
signal tlb_ctl_dbg_resv3_tag0_as_snoop_match     : std_ulogic;
signal tlb_ctl_dbg_resv3_tag0_gs_snoop_match     : std_ulogic;
signal tlb_ctl_dbg_resv3_tag0_as_tlbwe_match     : std_ulogic;
signal tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match     : std_ulogic;
signal tlb_ctl_dbg_resv3_tag0_ind_match          : std_ulogic;
signal tlb_ctl_dbg_resv3_tag0_epn_loc_match      : std_ulogic;
signal tlb_ctl_dbg_resv3_tag0_epn_glob_match     : std_ulogic;
signal tlb_ctl_dbg_resv3_tag0_class_match        : std_ulogic;
signal tlb_ctl_dbg_clr_resv_q                    : std_ulogic_vector(0 to 3);
signal tlb_ctl_dbg_clr_resv_terms                : std_ulogic_vector(0 to 3);
signal tlb_cmp_dbg_tag4                   :  std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_cmp_dbg_tag4_wayhit            :  std_ulogic_vector(0 to tlb_ways);
signal tlb_cmp_dbg_addr4                  :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_cmp_dbg_tag4_way               :  std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_cmp_dbg_tag4_parerr            :  std_ulogic_vector(0 to 4);
signal tlb_cmp_dbg_tag4_lru_dataout_q     : std_ulogic_vector(0 to lru_width-5);
signal tlb_cmp_dbg_tag5_tlb_datain_q      :  std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_cmp_dbg_tag5_lru_datain_q      : std_ulogic_vector(0 to lru_width-5);
signal tlb_cmp_dbg_tag5_lru_write         : std_ulogic;
signal tlb_cmp_dbg_tag5_any_exception     : std_ulogic;
signal tlb_cmp_dbg_tag5_except_type_q     : std_ulogic_vector(0 to 3);
signal tlb_cmp_dbg_tag5_except_thdid_q    : std_ulogic_vector(0 to 1);
signal tlb_cmp_dbg_tag5_erat_rel_val      :  std_ulogic_vector(0 to 9);
signal tlb_cmp_dbg_tag5_erat_rel_data     :  std_ulogic_vector(0 to 131);
signal tlb_cmp_dbg_erat_dup_q             :  std_ulogic_vector(0 to 19);
signal tlb_cmp_dbg_addr_enable            :  std_ulogic_vector(0 to 8);
signal tlb_cmp_dbg_pgsize_enable          :  std_ulogic;
signal tlb_cmp_dbg_class_enable           :  std_ulogic;
signal tlb_cmp_dbg_extclass_enable        :  std_ulogic_vector(0 to 1);
signal tlb_cmp_dbg_state_enable           :  std_ulogic_vector(0 to 1);
signal tlb_cmp_dbg_thdid_enable           :  std_ulogic;
signal tlb_cmp_dbg_pid_enable             :  std_ulogic;
signal tlb_cmp_dbg_lpid_enable            :  std_ulogic;
signal tlb_cmp_dbg_ind_enable             :  std_ulogic;
signal tlb_cmp_dbg_iprot_enable           :  std_ulogic;
signal tlb_cmp_dbg_way0_entry_v                        :  std_ulogic;
signal tlb_cmp_dbg_way0_addr_match                     :  std_ulogic;
signal tlb_cmp_dbg_way0_pgsize_match                   :  std_ulogic;
signal tlb_cmp_dbg_way0_class_match                    :  std_ulogic;
signal tlb_cmp_dbg_way0_extclass_match                 :  std_ulogic;
signal tlb_cmp_dbg_way0_state_match                    :  std_ulogic;
signal tlb_cmp_dbg_way0_thdid_match                    :  std_ulogic;
signal tlb_cmp_dbg_way0_pid_match                      :  std_ulogic;
signal tlb_cmp_dbg_way0_lpid_match                     :  std_ulogic;
signal tlb_cmp_dbg_way0_ind_match                      :  std_ulogic;
signal tlb_cmp_dbg_way0_iprot_match                    :  std_ulogic;
signal tlb_cmp_dbg_way1_entry_v                        :  std_ulogic;
signal tlb_cmp_dbg_way1_addr_match                     :  std_ulogic;
signal tlb_cmp_dbg_way1_pgsize_match                   :  std_ulogic;
signal tlb_cmp_dbg_way1_class_match                    :  std_ulogic;
signal tlb_cmp_dbg_way1_extclass_match                 :  std_ulogic;
signal tlb_cmp_dbg_way1_state_match                    :  std_ulogic;
signal tlb_cmp_dbg_way1_thdid_match                    :  std_ulogic;
signal tlb_cmp_dbg_way1_pid_match                      :  std_ulogic;
signal tlb_cmp_dbg_way1_lpid_match                     :  std_ulogic;
signal tlb_cmp_dbg_way1_ind_match                      :  std_ulogic;
signal tlb_cmp_dbg_way1_iprot_match                    :  std_ulogic;
signal tlb_cmp_dbg_way2_entry_v                        :  std_ulogic;
signal tlb_cmp_dbg_way2_addr_match                     :  std_ulogic;
signal tlb_cmp_dbg_way2_pgsize_match                   :  std_ulogic;
signal tlb_cmp_dbg_way2_class_match                    :  std_ulogic;
signal tlb_cmp_dbg_way2_extclass_match                 :  std_ulogic;
signal tlb_cmp_dbg_way2_state_match                    :  std_ulogic;
signal tlb_cmp_dbg_way2_thdid_match                    :  std_ulogic;
signal tlb_cmp_dbg_way2_pid_match                      :  std_ulogic;
signal tlb_cmp_dbg_way2_lpid_match                     :  std_ulogic;
signal tlb_cmp_dbg_way2_ind_match                      :  std_ulogic;
signal tlb_cmp_dbg_way2_iprot_match                    :  std_ulogic;
signal tlb_cmp_dbg_way3_entry_v                        :  std_ulogic;
signal tlb_cmp_dbg_way3_addr_match                     :  std_ulogic;
signal tlb_cmp_dbg_way3_pgsize_match                   :  std_ulogic;
signal tlb_cmp_dbg_way3_class_match                    :  std_ulogic;
signal tlb_cmp_dbg_way3_extclass_match                 :  std_ulogic;
signal tlb_cmp_dbg_way3_state_match                    :  std_ulogic;
signal tlb_cmp_dbg_way3_thdid_match                    :  std_ulogic;
signal tlb_cmp_dbg_way3_pid_match                      :  std_ulogic;
signal tlb_cmp_dbg_way3_lpid_match                     :  std_ulogic;
signal tlb_cmp_dbg_way3_ind_match                      :  std_ulogic;
signal tlb_cmp_dbg_way3_iprot_match                    :  std_ulogic;
signal lrat_dbg_tag1_addr_enable    :  std_ulogic;
signal lrat_dbg_tag2_matchline_q    :  std_ulogic_vector(0 to 7);
signal lrat_dbg_entry0_addr_match   :  std_ulogic;
signal lrat_dbg_entry0_lpid_match   :  std_ulogic;
signal lrat_dbg_entry0_entry_v      :  std_ulogic;
signal lrat_dbg_entry0_entry_x      :  std_ulogic;
signal lrat_dbg_entry0_size         :  std_ulogic_vector(0 to 3);
signal lrat_dbg_entry1_addr_match   :  std_ulogic;
signal lrat_dbg_entry1_lpid_match   :  std_ulogic;
signal lrat_dbg_entry1_entry_v      :  std_ulogic;
signal lrat_dbg_entry1_entry_x      :  std_ulogic;
signal lrat_dbg_entry1_size         :  std_ulogic_vector(0 to 3);
signal lrat_dbg_entry2_addr_match   :  std_ulogic;
signal lrat_dbg_entry2_lpid_match   :  std_ulogic;
signal lrat_dbg_entry2_entry_v      :  std_ulogic;
signal lrat_dbg_entry2_entry_x      :  std_ulogic;
signal lrat_dbg_entry2_size         :  std_ulogic_vector(0 to 3);
signal lrat_dbg_entry3_addr_match   :  std_ulogic;
signal lrat_dbg_entry3_lpid_match   :  std_ulogic;
signal lrat_dbg_entry3_entry_v      :  std_ulogic;
signal lrat_dbg_entry3_entry_x      :  std_ulogic;
signal lrat_dbg_entry3_size         :  std_ulogic_vector(0 to 3);
signal lrat_dbg_entry4_addr_match   :  std_ulogic;
signal lrat_dbg_entry4_lpid_match   :  std_ulogic;
signal lrat_dbg_entry4_entry_v      :  std_ulogic;
signal lrat_dbg_entry4_entry_x      :  std_ulogic;
signal lrat_dbg_entry4_size         :  std_ulogic_vector(0 to 3);
signal lrat_dbg_entry5_addr_match   :  std_ulogic;
signal lrat_dbg_entry5_lpid_match   :  std_ulogic;
signal lrat_dbg_entry5_entry_v      :  std_ulogic;
signal lrat_dbg_entry5_entry_x      :  std_ulogic;
signal lrat_dbg_entry5_size         :  std_ulogic_vector(0 to 3);
signal lrat_dbg_entry6_addr_match   :  std_ulogic;
signal lrat_dbg_entry6_lpid_match   :  std_ulogic;
signal lrat_dbg_entry6_entry_v      :  std_ulogic;
signal lrat_dbg_entry6_entry_x      :  std_ulogic;
signal lrat_dbg_entry6_size         :  std_ulogic_vector(0 to 3);
signal lrat_dbg_entry7_addr_match   :  std_ulogic;
signal lrat_dbg_entry7_lpid_match   :  std_ulogic;
signal lrat_dbg_entry7_entry_v      :  std_ulogic;
signal lrat_dbg_entry7_entry_x      :  std_ulogic;
signal lrat_dbg_entry7_size         :  std_ulogic_vector(0 to 3);
signal htw_dbg_seq_idle                 :  std_ulogic;
signal htw_dbg_pte0_seq_idle            :  std_ulogic;
signal htw_dbg_pte1_seq_idle            :  std_ulogic;
signal htw_dbg_seq_q                    : std_ulogic_vector(0 to 1);
signal htw_dbg_inptr_q                  : std_ulogic_vector(0 to 1);
signal htw_dbg_pte0_seq_q               : std_ulogic_vector(0 to 2);
signal htw_dbg_pte1_seq_q               : std_ulogic_vector(0 to 2);
signal htw_dbg_ptereload_ptr_q          : std_ulogic;
signal htw_dbg_lsuptr_q                 : std_ulogic_vector(0 to 1);
signal htw_dbg_req_valid_q              : std_ulogic_vector(0 to 3);
signal htw_dbg_resv_valid_vec           : std_ulogic_vector(0 to 3);
signal htw_dbg_tag4_clr_resv_q          : std_ulogic_vector(0 to 3);
signal htw_dbg_tag4_clr_resv_terms      : std_ulogic_vector(0 to 3);
signal htw_dbg_pte0_score_ptr_q         : std_ulogic_vector(0 to 1);
signal htw_dbg_pte0_score_cl_offset_q   : std_ulogic_vector(58 to 60);
signal htw_dbg_pte0_score_error_q       : std_ulogic_vector(0 to 2);
signal htw_dbg_pte0_score_qwbeat_q      : std_ulogic_vector(0 to 3);
signal htw_dbg_pte0_score_pending_q     : std_ulogic;
signal htw_dbg_pte0_score_ibit_q        : std_ulogic;
signal htw_dbg_pte0_score_dataval_q     : std_ulogic;
signal htw_dbg_pte0_reld_for_me_tm1     : std_ulogic;
signal htw_dbg_pte1_score_ptr_q         : std_ulogic_vector(0 to 1);
signal htw_dbg_pte1_score_cl_offset_q   : std_ulogic_vector(58 to 60);
signal htw_dbg_pte1_score_error_q       : std_ulogic_vector(0 to 2);
signal htw_dbg_pte1_score_qwbeat_q      : std_ulogic_vector(0 to 3);
signal htw_dbg_pte1_score_pending_q     : std_ulogic;
signal htw_dbg_pte1_score_ibit_q        : std_ulogic;
signal htw_dbg_pte1_score_dataval_q     : std_ulogic;
signal htw_dbg_pte1_reld_for_me_tm1     : std_ulogic;
-- power clock gating sigs
signal tlb_delayed_act  : std_ulogic_vector(9 to 32);
signal unused_dc  :  std_ulogic_vector(0 to 70);
-- synopsys translate_off
-- synopsys translate_on
-- Pervasive
signal lcb_clkoff_dc_b     : std_ulogic;
signal lcb_act_dis_dc      : std_ulogic;
signal lcb_d_mode_dc       : std_ulogic;
signal lcb_delay_lclkr_dc  :  std_ulogic_vector(0 to 4);
signal lcb_mpw1_dc_b       :  std_ulogic_vector(0 to 4);
signal lcb_mpw2_dc_b       : std_ulogic;
signal g6t_gptr_lcb_clkoff_dc_b     : std_ulogic;
signal g6t_gptr_lcb_act_dis_dc      : std_ulogic;
signal g6t_gptr_lcb_d_mode_dc       : std_ulogic;
signal g6t_gptr_lcb_delay_lclkr_dc  :  std_ulogic_vector(0 to 4);
signal g6t_gptr_lcb_mpw1_dc_b       :  std_ulogic_vector(0 to 4);
signal g6t_gptr_lcb_mpw2_dc_b       : std_ulogic;
signal g8t_gptr_lcb_clkoff_dc_b     : std_ulogic;
signal g8t_gptr_lcb_act_dis_dc      : std_ulogic;
signal g8t_gptr_lcb_d_mode_dc       : std_ulogic;
signal g8t_gptr_lcb_delay_lclkr_dc  :  std_ulogic_vector(0 to 4);
signal g8t_gptr_lcb_mpw1_dc_b       :  std_ulogic_vector(0 to 4);
signal g8t_gptr_lcb_mpw2_dc_b       : std_ulogic;
signal pc_func_sl_thold_2      : std_ulogic_vector(0 to 1);
signal pc_func_slp_sl_thold_2  : std_ulogic_vector(0 to 1);
signal pc_func_slp_nsl_thold_2 : std_ulogic;
signal pc_fce_2                : std_ulogic;
signal pc_cfg_sl_thold_2       : std_ulogic;
signal pc_cfg_slp_sl_thold_2   : std_ulogic;
signal pc_sg_2         : std_ulogic_vector(0 to 1);
signal pc_sg_1         : std_ulogic_vector(0 to 1);
signal pc_sg_0         : std_ulogic_vector(0 to 1);
signal pc_func_sl_thold_0        : std_ulogic_vector(0 to 1);
signal pc_func_sl_thold_0_b      : std_ulogic_vector(0 to 1);
signal pc_func_slp_sl_thold_0    : std_ulogic_vector(0 to 1);
signal pc_func_slp_sl_thold_0_b  : std_ulogic_vector(0 to 1);
signal pc_abst_sl_thold_0        : std_ulogic;
signal pc_abst_slp_sl_thold_0    : std_ulogic;
signal pc_repr_sl_thold_0        : std_ulogic;
signal pc_time_sl_thold_0        : std_ulogic;
signal pc_ary_nsl_thold_0        : std_ulogic;
signal pc_ary_slp_nsl_thold_0    : std_ulogic;
signal pc_mm_bolt_sl_thold_0     : std_ulogic;
signal pc_mm_bo_enable_2         : std_ulogic;
signal pc_mm_abist_g8t_wenb_q        :    std_ulogic;
signal pc_mm_abist_g8t1p_renb_0_q    :    std_ulogic;
signal pc_mm_abist_di_0_q            :    std_ulogic_vector(0 to 3);
signal pc_mm_abist_g8t_bw_1_q        :    std_ulogic;
signal pc_mm_abist_g8t_bw_0_q        :    std_ulogic;
signal pc_mm_abist_waddr_0_q         :    std_ulogic_vector(0 to 9);
signal pc_mm_abist_raddr_0_q         :    std_ulogic_vector(0 to 9);
signal pc_mm_abist_wl128_comp_ena_q  :    std_ulogic;
signal pc_mm_abist_g8t_dcomp_q       :    std_ulogic_vector(0 to 3);
signal pc_mm_abist_dcomp_g6t_2r_q    :    std_ulogic_vector(0 to 3);
signal pc_mm_abist_di_g6t_2r_q       :    std_ulogic_vector(0 to 3);
signal pc_mm_abist_g6t_r_wb_q        :    std_ulogic;
signal time_scan_in_int      : std_ulogic;
signal time_scan_out_int     : std_ulogic;
signal func_scan_in_int      : std_ulogic_vector(0 to 9);
signal func_scan_out_int     : std_ulogic_vector(0 to 9);
signal repr_scan_in_int      : std_ulogic;
signal repr_scan_out_int     : std_ulogic;
signal abst_scan_in_int      : std_ulogic_vector(0 to 1);
signal abst_scan_out_int     : std_ulogic_vector(0 to 1);
signal bcfg_scan_in_int      : std_ulogic;
signal bcfg_scan_out_int     : std_ulogic;
signal ccfg_scan_in_int      : std_ulogic;
signal ccfg_scan_out_int     : std_ulogic;
signal dcfg_scan_in_int      : std_ulogic;
signal dcfg_scan_out_int     : std_ulogic;
signal siv_0                      : std_ulogic_vector(0 to scan_right_0);
signal sov_0                      : std_ulogic_vector(0 to scan_right_0);
signal siv_1                      : std_ulogic_vector(0 to scan_right_1);
signal sov_1                      : std_ulogic_vector(0 to scan_right_1);
signal bsiv                     : std_ulogic_vector(0 to boot_scan_right);
signal bsov                     : std_ulogic_vector(0 to boot_scan_right);
signal tidn                     : std_ulogic;
signal ac_an_psro_ringsig_b         : std_ulogic;
begin
-----------------------------------------------------------------------
-- common stuff for tlb and erat-only modes
-----------------------------------------------------------------------
tidn <= '0';
ac_an_lpar_id <= ac_an_lpar_id_sig;
mm_xu_lsu_lpidr <= lpidr_sig;
-----------------------------------------------------------------------
-- Invalidate Component Instantiation
-----------------------------------------------------------------------
mmq_inval: entity work.mmq_inval(mmq_inval)
  generic map ( rs_data_width => rs_data_width,
                   epn_width => epn_width, 
                   real_addr_width => real_addr_width,
                   lpid_width => lpid_width,
                   expand_type => expand_type )
  port map(
     vdd               => vdd,
     gnd               => gnd,
     nclk              => nclk,
     tc_ccflush_dc             => tc_ac_ccflush_dc,
     tc_scan_dis_dc_b          => tc_ac_scan_dis_dc_b,
     tc_scan_diag_dc           => tc_ac_scan_diag_dc,
     tc_lbist_en_dc            => tc_ac_lbist_en_dc,

     lcb_d_mode_dc              => lcb_d_mode_dc,
     lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
     lcb_act_dis_dc             => lcb_act_dis_dc,
     lcb_mpw1_dc_b              => lcb_mpw1_dc_b,
     lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
     lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc,

     ac_func_scan_in            => siv_0(mmq_inval_offset),
     ac_func_scan_out           => sov_0(mmq_inval_offset),

     pc_sg_2                  => pc_sg_2(0),
     pc_func_sl_thold_2       => pc_func_sl_thold_2(0),
     pc_func_slp_sl_thold_2   => pc_func_slp_sl_thold_2(0),
     pc_func_slp_nsl_thold_2  => pc_func_slp_nsl_thold_2,
     pc_fce_2                 => pc_fce_2,
     mmucr2_act_override        => mmucr2_sig(7),   
     xu_mm_ccr2_notlb           => xu_mm_hid_mmu_mode,
     xu_mm_ccr2_notlb_b         => xu_mm_ccr2_notlb_b,

     mm_iu_ierat_snoop_coming   => mm_iu_ierat_snoop_coming,
     mm_iu_ierat_snoop_val      => mm_iu_ierat_snoop_val,
     mm_iu_ierat_snoop_attr     => mm_iu_ierat_snoop_attr,
     mm_iu_ierat_snoop_vpn      => mm_iu_ierat_snoop_vpn,
     iu_mm_ierat_snoop_ack      => iu_mm_ierat_snoop_ack,

     mm_xu_derat_snoop_coming   => mm_xu_derat_snoop_coming,
     mm_xu_derat_snoop_val      => mm_xu_derat_snoop_val,
     mm_xu_derat_snoop_attr     => mm_xu_derat_snoop_attr,
     mm_xu_derat_snoop_vpn      => mm_xu_derat_snoop_vpn,
     xu_mm_derat_snoop_ack      => xu_mm_derat_snoop_ack,

     tlb_snoop_coming           => tlb_snoop_coming,
     tlb_snoop_val              => tlb_snoop_val,
     tlb_snoop_attr             => tlb_snoop_attr,
     tlb_snoop_vpn              => tlb_snoop_vpn,
     tlb_snoop_ack              => tlb_snoop_ack,

     tlb_ctl_barrier_done         => tlb_ctl_barrier_done_sig,
     tlb_ctl_ex2_flush_req        => tlb_ctl_ex2_flush_req_sig,
     tlb_ctl_ex2_illeg_instr      => tlb_ctl_ex2_illeg_instr_sig,
     tlb_ctl_quiesce              => tlb_ctl_quiesce_sig,    
     tlb_req_quiesce              => tlb_req_quiesce_sig,    

     mm_iu_barrier_done           => mm_iu_barrier_done_sig,
     mm_xu_ex3_flush_req          => mm_xu_ex3_flush_req_sig,
     mm_xu_illeg_instr            => mm_xu_illeg_instr_sig,
     mm_xu_local_snoop_reject     => mm_xu_local_snoop_reject_sig,     

     an_ac_back_inv             => an_ac_back_inv,
     an_ac_back_inv_target      => an_ac_back_inv_target(2),
     an_ac_back_inv_local       => an_ac_back_inv_local,
     an_ac_back_inv_lbit        => an_ac_back_inv_lbit,
     an_ac_back_inv_gs          => an_ac_back_inv_gs,  
     an_ac_back_inv_ind         => an_ac_back_inv_ind,  
     an_ac_back_inv_addr        => an_ac_back_inv_addr,
     an_ac_back_inv_lpar_id     => an_ac_back_inv_lpar_id,
     ac_an_back_inv_reject      => ac_an_back_inv_reject,
     ac_an_power_managed        => ac_an_power_managed_imm,  
     mmucr0_0                 => mmucr0_0_sig(2 to 19),
     mmucr0_1                 => mmucr0_1_sig(2 to 19),
     mmucr0_2                 => mmucr0_2_sig(2 to 19),
     mmucr0_3                 => mmucr0_3_sig(2 to 19),
     mmucr1                   => mmucr1_sig(12 to 19), 
     mmucr1_csinv             => mmucr1_sig(4 to 5), 
     lpidr                    => lpidr_sig,

     mas5_0_sgs          => mas5_0_sgs,       
     mas5_0_slpid        => mas5_0_slpid,       
     mas6_0_spid         => mas6_0_spid,       
     mas6_0_isize        => mas6_0_isize,       
     mas6_0_sind         => mas6_0_sind,       
     mas6_0_sas          => mas6_0_sas,     
     mas5_1_sgs          => mas5_1_sgs,       
     mas5_1_slpid        => mas5_1_slpid,       
     mas6_1_spid         => mas6_1_spid,       
     mas6_1_isize        => mas6_1_isize,       
     mas6_1_sind         => mas6_1_sind,       
     mas6_1_sas          => mas6_1_sas,     
     mas5_2_sgs          => mas5_2_sgs,       
     mas5_2_slpid        => mas5_2_slpid,       
     mas6_2_spid         => mas6_2_spid,       
     mas6_2_isize        => mas6_2_isize,       
     mas6_2_sind         => mas6_2_sind,       
     mas6_2_sas          => mas6_2_sas,     
     mas5_3_sgs          => mas5_3_sgs,       
     mas5_3_slpid        => mas5_3_slpid,       
     mas6_3_spid         => mas6_3_spid,       
     mas6_3_isize        => mas6_3_isize,       
     mas6_3_sind         => mas6_3_sind,       
     mas6_3_sas          => mas6_3_sas,     
     mmucsr0_tlb0fi           => mmucsr0_tlb0fi,  
     mmq_inval_tlb0fi_done    => mmq_inval_tlb0fi_done,  


     xu_mm_rf1_val              => xu_mm_rf1_val,
     xu_mm_rf1_is_tlbivax       => xu_mm_rf1_is_tlbivax,
     xu_mm_rf1_is_tlbilx        => xu_mm_rf1_is_tlbilx,
     xu_mm_rf1_is_erativax      => xu_mm_rf1_is_erativax,
     xu_mm_rf1_is_eratilx       => xu_mm_rf1_is_eratilx,
     xu_mm_ex1_rs_is            => xu_mm_ex1_rs_is,
     xu_mm_ex1_is_isync         => xu_mm_ex1_is_isync,
     xu_mm_ex1_is_csync         => xu_mm_ex1_is_csync,
     xu_mm_ex2_eff_addr         => xu_mm_ex2_eff_addr_sig,
     xu_mm_rf1_t                => xu_mm_rf1_t,
     xu_mm_msr_gs               => xu_mm_msr_gs,
     xu_mm_msr_pr               => xu_mm_msr_pr,
     xu_mm_spr_epcr_dgtmi       => xu_mm_spr_epcr_dgtmi,
     xu_mm_epcr_dgtmi           => xu_mm_epcr_dgtmi_sig,
     xu_rf1_flush               => xu_rf1_flush,
     xu_ex1_flush               => xu_ex1_flush,
     xu_ex2_flush               => xu_ex2_flush,
     xu_ex3_flush               => xu_ex3_flush,
     xu_ex4_flush               => xu_ex4_flush,
     xu_ex5_flush               => xu_ex5_flush,
     xu_mm_lmq_stq_empty        => xu_mm_lmq_stq_empty,
     iu_mm_lmq_empty            => iu_mm_lmq_empty,
     mm_xu_hold_req             => mm_xu_hold_req_sig,
     xu_mm_hold_ack             => xu_mm_hold_ack,
     mm_xu_hold_done            => mm_xu_hold_done_sig,
     mm_xu_quiesce              => mm_xu_quiesce_sig,   
     inval_perf_tlbilx          => inval_perf_tlbilx,
     inval_perf_tlbivax         => inval_perf_tlbivax,
     inval_perf_tlbivax_snoop   => inval_perf_tlbivax_snoop,
     inval_perf_tlb_flush       => inval_perf_tlb_flush,

     htw_lsu_req_valid        => htw_lsu_req_valid,  
     htw_lsu_thdid            => htw_lsu_thdid,  
     htw_lsu_ttype            => htw_lsu_ttype,      
     htw_lsu_wimge            => htw_lsu_wimge,      
     htw_lsu_u                => htw_lsu_u,          
     htw_lsu_addr             => htw_lsu_addr,       
     htw_lsu_req_taken        => htw_lsu_req_taken,  
     htw_quiesce              => htw_quiesce_sig,    

     tlbwe_back_inv_valid     => tlbwe_back_inv_valid_sig,  
     tlbwe_back_inv_thdid     => tlbwe_back_inv_thdid_sig,  
     tlbwe_back_inv_addr      => tlbwe_back_inv_addr_sig,  
     tlbwe_back_inv_attr      => tlbwe_back_inv_attr_sig,  
     tlbwe_back_inv_pending   => tlbwe_back_inv_pending_sig,  
     tlb_tag5_write           => tlb_tag5_write,          

     mm_xu_lsu_req              => mm_xu_lsu_req_sig,    
     mm_xu_lsu_ttype            => mm_xu_lsu_ttype_sig, 
     mm_xu_lsu_wimge            => mm_xu_lsu_wimge_sig,
     mm_xu_lsu_u                => mm_xu_lsu_u_sig,    
     mm_xu_lsu_addr             => mm_xu_lsu_addr_sig,
     mm_xu_lsu_lpid             => mm_xu_lsu_lpid_sig,  
     mm_xu_lsu_gs               => mm_xu_lsu_gs_sig,    
     mm_xu_lsu_ind              => mm_xu_lsu_ind_sig,   
     mm_xu_lsu_lbit             => mm_xu_lsu_lbit_sig,  
     xu_mm_lsu_token            => xu_mm_lsu_token,              

     inval_dbg_seq_q                  => inval_dbg_seq_q,  
     inval_dbg_seq_idle               => inval_dbg_seq_idle,  
     inval_dbg_seq_snoop_inprogress   => inval_dbg_seq_snoop_inprogress,  
     inval_dbg_seq_snoop_done         => inval_dbg_seq_snoop_done,  
     inval_dbg_seq_local_done         => inval_dbg_seq_local_done,  
     inval_dbg_seq_tlb0fi_done        => inval_dbg_seq_tlb0fi_done,  
     inval_dbg_seq_tlbwe_snoop_done   => inval_dbg_seq_tlbwe_snoop_done,  
     inval_dbg_ex6_valid              => inval_dbg_ex6_valid,  
     inval_dbg_ex6_thdid              => inval_dbg_ex6_thdid,  
     inval_dbg_ex6_ttype              => inval_dbg_ex6_ttype,  
     inval_dbg_snoop_forme            => inval_dbg_snoop_forme,  
     inval_dbg_snoop_local_reject     => inval_dbg_snoop_local_reject,  
     inval_dbg_an_ac_back_inv_q       => inval_dbg_an_ac_back_inv_q,  
     inval_dbg_an_ac_back_inv_lpar_id_q   => inval_dbg_an_ac_back_inv_lpar_id_q,  
     inval_dbg_an_ac_back_inv_addr_q      => inval_dbg_an_ac_back_inv_addr_q,  
     inval_dbg_snoop_valid_q          => inval_dbg_snoop_valid_q,  
     inval_dbg_snoop_ack_q            => inval_dbg_snoop_ack_q,  
     inval_dbg_snoop_attr_q           => inval_dbg_snoop_attr_q,  
     inval_dbg_snoop_attr_tlb_spec_q  => inval_dbg_snoop_attr_tlb_spec_q,  
     inval_dbg_snoop_vpn_q            => inval_dbg_snoop_vpn_q,  
     inval_dbg_lsu_tokens_q           => inval_dbg_lsu_tokens_q  
);
-- End of mmq_inval component instantiation
-----------------------------------------------------------------------
-- Special Purpose Register Component Instantiation
-----------------------------------------------------------------------
mmq_spr: entity work.mmq_spr(mmq_spr)
  generic map ( spr_data_width => spr_data_width,
                   expand_tlb_type => expand_tlb_type,  
                   lpid_width => lpid_width,
                   real_addr_width => real_addr_width,
                   mmq_spr_cswitch_0to3 => mmq_spr_cswitch_0to3,
                   expand_type => expand_type )
  port map(
     vdd               => vdd,
     gnd               => gnd,
     nclk              => nclk,
     tc_ccflush_dc             => tc_ac_ccflush_dc,
     tc_scan_dis_dc_b          => tc_ac_scan_dis_dc_b,
     tc_scan_diag_dc           => tc_ac_scan_diag_dc,
     tc_lbist_en_dc            => tc_ac_lbist_en_dc,

     lcb_d_mode_dc              => lcb_d_mode_dc,
     lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
     lcb_act_dis_dc             => lcb_act_dis_dc,
     lcb_mpw1_dc_b              => lcb_mpw1_dc_b,
     lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
     lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc,

     ac_func_scan_in(0)            => siv_0(mmq_spr_offset_0),  
     ac_func_scan_in(1)            => func_scan_in_int(1),  
     ac_func_scan_out(0)           => sov_0(mmq_spr_offset_0),  
     ac_func_scan_out(1)           => func_scan_out_int(1),  
     ac_bcfg_scan_in            => bsiv(mmq_spr_bcfg_offset),
     ac_bcfg_scan_out           => bsov(mmq_spr_bcfg_offset),


pc_sg_2                  => pc_sg_2(0),
     pc_func_sl_thold_2       => pc_func_sl_thold_2(0),
     pc_func_slp_sl_thold_2   => pc_func_slp_sl_thold_2(0),
     pc_func_slp_nsl_thold_2  => pc_func_slp_nsl_thold_2,
     pc_cfg_sl_thold_2        => pc_cfg_sl_thold_2,  
     pc_cfg_slp_sl_thold_2    => pc_cfg_slp_sl_thold_2,  
     pc_fce_2                 => pc_fce_2,
     xu_mm_ccr2_notlb_b         => xu_mm_ccr2_notlb_b(1),
     mmucr2_act_override        => mmucr2_sig(5 to 6),   

     tlb_delayed_act         => tlb_delayed_act(29 to 32),    

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

     mm_xu_derat_pid0           => mm_xu_derat_pid0,     
     mm_xu_derat_pid1           => mm_xu_derat_pid1,           
     mm_xu_derat_pid2           => mm_xu_derat_pid2,           
     mm_xu_derat_pid3           => mm_xu_derat_pid3,           
     mm_xu_derat_mmucr0_0       => mm_xu_derat_mmucr0_0,
     mm_xu_derat_mmucr0_1       => mm_xu_derat_mmucr0_1,       
     mm_xu_derat_mmucr0_2       => mm_xu_derat_mmucr0_2,      
     mm_xu_derat_mmucr0_3       => mm_xu_derat_mmucr0_3,      
     xu_mm_derat_mmucr0         => xu_mm_derat_mmucr0,        
     xu_mm_derat_mmucr0_we      => xu_mm_derat_mmucr0_we,     
     mm_xu_derat_mmucr1         => mm_xu_derat_mmucr1,          
     xu_mm_derat_mmucr1         => xu_mm_derat_mmucr1, 
     xu_mm_derat_mmucr1_we      => xu_mm_derat_mmucr1_we,      

     pid0                       => pid0_sig,     
     pid1                       => pid1_sig,           
     pid2                       => pid2_sig,           
     pid3                       => pid3_sig,           
     mmucr0_0                   => mmucr0_0_sig,
     mmucr0_1                   => mmucr0_1_sig,       
     mmucr0_2                   => mmucr0_2_sig,      
     mmucr0_3                   => mmucr0_3_sig,      
     mmucr1                     => mmucr1_sig,          
     mmucr2                     => mmucr2_sig,          
     mmucr3_0                   => mmucr3_0_sig,          
     mmucr3_1                   => mmucr3_1_sig,          
     mmucr3_2                   => mmucr3_2_sig,          
     mmucr3_3                   => mmucr3_3_sig,          
     mmucfg_lrat                => mmucfg_lrat,  
     mmucfg_twc                 => mmucfg_twc,  
     tlb0cfg_pt                 => tlb0cfg_pt,
     tlb0cfg_ind                => tlb0cfg_ind,
     tlb0cfg_gtwe               => tlb0cfg_gtwe,
     mas0_0_atsel            => mas0_0_atsel,    
     mas0_0_esel             => mas0_0_esel,    
     mas0_0_hes              => mas0_0_hes,    
     mas0_0_wq               => mas0_0_wq,    
     mas1_0_v                => mas1_0_v,    
     mas1_0_iprot            => mas1_0_iprot,    
     mas1_0_tid              => mas1_0_tid,    
     mas1_0_ind              => mas1_0_ind,    
     mas1_0_ts               => mas1_0_ts,    
     mas1_0_tsize            => mas1_0_tsize,    
     mas2_0_epn              => mas2_0_epn,    
     mas2_0_wimge            => mas2_0_wimge,    
     mas3_0_rpnl             => mas3_0_rpnl,    
     mas3_0_ubits            => mas3_0_ubits,    
     mas3_0_usxwr            => mas3_0_usxwr,    
     mas5_0_sgs              => mas5_0_sgs,    
     mas5_0_slpid            => mas5_0_slpid,    
     mas6_0_spid             => mas6_0_spid,    
     mas6_0_isize            => mas6_0_isize,    
     mas6_0_sind             => mas6_0_sind,    
     mas6_0_sas              => mas6_0_sas,    
     mas7_0_rpnu             => mas7_0_rpnu,    
     mas8_0_tgs              => mas8_0_tgs,    
     mas8_0_vf               => mas8_0_vf,    
     mas8_0_tlpid            => mas8_0_tlpid,    
     mas0_1_atsel            => mas0_1_atsel,    
     mas0_1_esel             => mas0_1_esel,    
     mas0_1_hes              => mas0_1_hes,    
     mas0_1_wq               => mas0_1_wq,    
     mas1_1_v                => mas1_1_v,    
     mas1_1_iprot            => mas1_1_iprot,    
     mas1_1_tid              => mas1_1_tid,    
     mas1_1_ind              => mas1_1_ind,    
     mas1_1_ts               => mas1_1_ts,    
     mas1_1_tsize            => mas1_1_tsize,    
     mas2_1_epn              => mas2_1_epn,    
     mas2_1_wimge            => mas2_1_wimge,    
     mas3_1_rpnl             => mas3_1_rpnl,    
     mas3_1_ubits            => mas3_1_ubits,    
     mas3_1_usxwr            => mas3_1_usxwr,    
     mas5_1_sgs              => mas5_1_sgs,    
     mas5_1_slpid            => mas5_1_slpid,    
     mas6_1_spid             => mas6_1_spid,    
     mas6_1_isize            => mas6_1_isize,    
     mas6_1_sind             => mas6_1_sind,    
     mas6_1_sas              => mas6_1_sas,    
     mas7_1_rpnu             => mas7_1_rpnu,    
     mas8_1_tgs              => mas8_1_tgs,    
     mas8_1_vf               => mas8_1_vf,    
     mas8_1_tlpid            => mas8_1_tlpid,    
     mas0_2_atsel            => mas0_2_atsel,    
     mas0_2_esel             => mas0_2_esel,    
     mas0_2_hes              => mas0_2_hes,    
     mas0_2_wq               => mas0_2_wq,    
     mas1_2_v                => mas1_2_v,    
     mas1_2_iprot            => mas1_2_iprot,    
     mas1_2_tid              => mas1_2_tid,    
     mas1_2_ind              => mas1_2_ind,    
     mas1_2_ts               => mas1_2_ts,    
     mas1_2_tsize            => mas1_2_tsize,    
     mas2_2_epn              => mas2_2_epn,    
     mas2_2_wimge            => mas2_2_wimge,    
     mas3_2_rpnl             => mas3_2_rpnl,    
     mas3_2_ubits            => mas3_2_ubits,    
     mas3_2_usxwr            => mas3_2_usxwr,    
     mas5_2_sgs              => mas5_2_sgs,    
     mas5_2_slpid            => mas5_2_slpid,    
     mas6_2_spid             => mas6_2_spid,    
     mas6_2_isize            => mas6_2_isize,    
     mas6_2_sind             => mas6_2_sind,    
     mas6_2_sas              => mas6_2_sas,    
     mas7_2_rpnu             => mas7_2_rpnu,    
     mas8_2_tgs              => mas8_2_tgs,    
     mas8_2_vf               => mas8_2_vf,    
     mas8_2_tlpid            => mas8_2_tlpid,    
     mas0_3_atsel            => mas0_3_atsel,    
     mas0_3_esel             => mas0_3_esel,    
     mas0_3_hes              => mas0_3_hes,    
     mas0_3_wq               => mas0_3_wq,    
     mas1_3_v                => mas1_3_v,    
     mas1_3_iprot            => mas1_3_iprot,    
     mas1_3_tid              => mas1_3_tid,    
     mas1_3_ind              => mas1_3_ind,    
     mas1_3_ts               => mas1_3_ts,    
     mas1_3_tsize            => mas1_3_tsize,    
     mas2_3_epn              => mas2_3_epn,    
     mas2_3_wimge            => mas2_3_wimge,    
     mas3_3_rpnl             => mas3_3_rpnl,    
     mas3_3_ubits            => mas3_3_ubits,    
     mas3_3_usxwr            => mas3_3_usxwr,    
     mas5_3_sgs              => mas5_3_sgs,    
     mas5_3_slpid            => mas5_3_slpid,    
     mas6_3_spid             => mas6_3_spid,    
     mas6_3_isize            => mas6_3_isize,    
     mas6_3_sind             => mas6_3_sind,    
     mas6_3_sas              => mas6_3_sas,    
     mas7_3_rpnu             => mas7_3_rpnu,    
     mas8_3_tgs              => mas8_3_tgs,    
     mas8_3_vf               => mas8_3_vf,    
     mas8_3_tlpid            => mas8_3_tlpid,    
     tlb_mas0_esel          => tlb_mas0_esel,  
     tlb_mas1_v             => tlb_mas1_v,  
     tlb_mas1_iprot         => tlb_mas1_iprot,  
     tlb_mas1_tid           => tlb_mas1_tid,  
     tlb_mas1_tid_error     => tlb_mas1_tid_error,  
     tlb_mas1_ind           => tlb_mas1_ind,  
     tlb_mas1_ts            => tlb_mas1_ts,  
     tlb_mas1_ts_error      => tlb_mas1_ts_error,  
     tlb_mas1_tsize         => tlb_mas1_tsize,  
     tlb_mas2_epn           => tlb_mas2_epn,  
     tlb_mas2_epn_error     => tlb_mas2_epn_error,  
     tlb_mas2_wimge         => tlb_mas2_wimge,  
     tlb_mas3_rpnl          => tlb_mas3_rpnl,  
     tlb_mas3_ubits         => tlb_mas3_ubits,  
     tlb_mas3_usxwr         => tlb_mas3_usxwr,  
     tlb_mas6_spid          => tlb_mas6_spid,  
     tlb_mas6_isize         => tlb_mas6_isize,  
     tlb_mas6_sind          => tlb_mas6_sind,  
     tlb_mas6_sas           => tlb_mas6_sas,  
     tlb_mas7_rpnu          => tlb_mas7_rpnu,  
     tlb_mas8_tgs           => tlb_mas8_tgs,  
     tlb_mas8_vf            => tlb_mas8_vf,  
     tlb_mas8_tlpid         => tlb_mas8_tlpid,  

     tlb_mmucr1_een         => tlb_mmucr1_een, 
     tlb_mmucr1_we          => tlb_mmucr1_we, 
     tlb_mmucr3_thdid       => tlb_mmucr3_thdid, 
     tlb_mmucr3_resvattr    => tlb_mmucr3_resvattr, 
     tlb_mmucr3_wlc         => tlb_mmucr3_wlc, 
     tlb_mmucr3_class       => tlb_mmucr3_class, 
     tlb_mmucr3_extclass    => tlb_mmucr3_extclass, 
     tlb_mmucr3_rc          => tlb_mmucr3_rc, 
     tlb_mmucr3_x           => tlb_mmucr3_x, 
     tlb_mas_tlbre          => tlb_mas_tlbre,  
     tlb_mas_tlbsx_hit      => tlb_mas_tlbsx_hit,  
     tlb_mas_tlbsx_miss     => tlb_mas_tlbsx_miss,  
     tlb_mas_dtlb_error     => tlb_mas_dtlb_error,  
     tlb_mas_itlb_error     => tlb_mas_itlb_error,  
     tlb_mas_thdid          => tlb_mas_thdid,  

     mmucsr0_tlb0fi           => mmucsr0_tlb0fi,  
     mmq_inval_tlb0fi_done    => mmq_inval_tlb0fi_done,  

     lrat_mmucr3_x          => lrat_mmucr3_x,  
     lrat_mas0_esel         => lrat_mas0_esel,  
     lrat_mas1_v            => lrat_mas1_v,  
     lrat_mas1_tsize        => lrat_mas1_tsize,  
     lrat_mas2_epn          => lrat_mas2_epn,  
     lrat_mas3_rpnl         => lrat_mas3_rpnl,  
     lrat_mas7_rpnu         => lrat_mas7_rpnu,  
     lrat_mas8_tlpid        => lrat_mas8_tlpid,  
     lrat_mas_tlbre         => lrat_mas_tlbre,  
     lrat_mas_tlbsx_hit     => lrat_mas_tlbsx_hit,  
     lrat_mas_tlbsx_miss    => lrat_mas_tlbsx_miss,  
     lrat_mas_thdid         => lrat_mas_thdid,  
     lrat_tag4_hit_entry    => lrat_tag4_hit_entry,

     tlb_lper_lpn           => tlb_lper_lpn, 
     tlb_lper_lps           => tlb_lper_lps, 
     tlb_lper_we            => tlb_lper_we, 

     lpidr                      => lpidr_sig,
     ac_an_lpar_id              => ac_an_lpar_id_sig,

     spr_dbg_match_64b           => spr_dbg_match_64b,   
     spr_dbg_match_any_mmu       => spr_dbg_match_any_mmu,   
     spr_dbg_match_any_mas       => spr_dbg_match_any_mas,   
     spr_dbg_match_pid           => spr_dbg_match_pid,   
     spr_dbg_match_lpidr         => spr_dbg_match_lpidr,   
     spr_dbg_match_mmucr0        => spr_dbg_match_mmucr0,   
     spr_dbg_match_mmucr1        => spr_dbg_match_mmucr1,   
     spr_dbg_match_mmucr2        => spr_dbg_match_mmucr2,   
     spr_dbg_match_mmucr3        => spr_dbg_match_mmucr3,   

     spr_dbg_match_mmucsr0       => spr_dbg_match_mmucsr0,   
     spr_dbg_match_mmucfg        => spr_dbg_match_mmucfg,   
     spr_dbg_match_tlb0cfg       => spr_dbg_match_tlb0cfg,   
     spr_dbg_match_tlb0ps        => spr_dbg_match_tlb0ps,   
     spr_dbg_match_lratcfg       => spr_dbg_match_lratcfg,   
     spr_dbg_match_lratps        => spr_dbg_match_lratps,   
     spr_dbg_match_eptcfg        => spr_dbg_match_eptcfg,   
     spr_dbg_match_lper          => spr_dbg_match_lper,   
     spr_dbg_match_lperu         => spr_dbg_match_lperu,   

     spr_dbg_match_mas0          => spr_dbg_match_mas0,   
     spr_dbg_match_mas1          => spr_dbg_match_mas1,   
     spr_dbg_match_mas2          => spr_dbg_match_mas2,   
     spr_dbg_match_mas2u         => spr_dbg_match_mas2u,   
     spr_dbg_match_mas3          => spr_dbg_match_mas3,   
     spr_dbg_match_mas4          => spr_dbg_match_mas4,   
     spr_dbg_match_mas5          => spr_dbg_match_mas5,   
     spr_dbg_match_mas6          => spr_dbg_match_mas6,   
     spr_dbg_match_mas7          => spr_dbg_match_mas7,   
     spr_dbg_match_mas8          => spr_dbg_match_mas8,   
     spr_dbg_match_mas01_64b     => spr_dbg_match_mas01_64b,   
     spr_dbg_match_mas56_64b     => spr_dbg_match_mas56_64b,   
     spr_dbg_match_mas73_64b     => spr_dbg_match_mas73_64b,   
     spr_dbg_match_mas81_64b     => spr_dbg_match_mas81_64b,   

     spr_dbg_slowspr_val_int         => spr_dbg_slowspr_val_int,   
     spr_dbg_slowspr_rw_int          => spr_dbg_slowspr_rw_int,   
     spr_dbg_slowspr_etid_int        => spr_dbg_slowspr_etid_int,   
     spr_dbg_slowspr_addr_int        => spr_dbg_slowspr_addr_int,   
     spr_dbg_slowspr_val_out         => spr_dbg_slowspr_val_out,   
     spr_dbg_slowspr_done_out        => spr_dbg_slowspr_done_out,   
     spr_dbg_slowspr_data_out        => spr_dbg_slowspr_data_out,   

     xu_mm_slowspr_val          => slowspr_val_in,
     xu_mm_slowspr_rw           => slowspr_rw_in,           
     xu_mm_slowspr_etid         => slowspr_etid_in,         
     xu_mm_slowspr_addr         => slowspr_addr_in,        
     xu_mm_slowspr_data         => slowspr_data_in,        
     xu_mm_slowspr_done         => slowspr_done_in,       

     mm_iu_slowspr_val          => slowspr_val_out,
     mm_iu_slowspr_rw           => slowspr_rw_out,
     mm_iu_slowspr_etid         => slowspr_etid_out,
     mm_iu_slowspr_addr         => slowspr_addr_out,
     mm_iu_slowspr_data         => slowspr_data_out,
     mm_iu_slowspr_done         => slowspr_done_out

);
-- End of mmq_spr component instantiation
-----------------------------------------------------------------------
-- Debug Trace component instantiation
-----------------------------------------------------------------------
mmq_dbg: entity work.mmq_dbg(mmq_dbg)
  generic map ( tlb_tag_width => tlb_tag_width,
                     expand_type => expand_type )
  port map(
     vdd               => vdd,
     gnd               => gnd,
     nclk              => nclk,
     pc_func_slp_sl_thold_2  => pc_func_slp_sl_thold_2(0),
     pc_func_slp_nsl_thold_2 => pc_func_slp_nsl_thold_2,
     pc_sg_2                 => pc_sg_2(0),
     pc_fce_2                => pc_fce_2,
     tc_ac_ccflush_dc        => tc_ac_ccflush_dc,
     lcb_clkoff_dc_b         => lcb_clkoff_dc_b,
     lcb_act_dis_dc          => lcb_act_dis_dc,
     lcb_d_mode_dc           => lcb_d_mode_dc,
     lcb_delay_lclkr_dc      => lcb_delay_lclkr_dc(0),
     lcb_mpw1_dc_b           => lcb_mpw1_dc_b(0),
     lcb_mpw2_dc_b           => lcb_mpw2_dc_b,
     scan_in            => siv_1(mmq_dbg_offset),
     scan_out           => sov_1(mmq_dbg_offset),

     mmucr2             => mmucr2_sig(8 to 11),
     pc_mm_trace_bus_enable     => pc_mm_trace_bus_enable,
     pc_mm_debug_mux1_ctrls     => pc_mm_debug_mux1_ctrls,

     debug_bus_in               => debug_bus_in,
     trace_triggers_in          => trace_triggers_in,

     debug_bus_out              => debug_bus_out,
     debug_bus_out_int          => debug_bus_out_int,
     trace_triggers_out         => trace_triggers_out,        

     spr_dbg_match_64b           => spr_dbg_match_64b,  
     spr_dbg_match_any_mmu       => spr_dbg_match_any_mmu,  
     spr_dbg_match_any_mas       => spr_dbg_match_any_mas,  
     spr_dbg_match_pid           => spr_dbg_match_pid,  
     spr_dbg_match_lpidr         => spr_dbg_match_lpidr,  
     spr_dbg_match_mmucr0        => spr_dbg_match_mmucr0,  
     spr_dbg_match_mmucr1        => spr_dbg_match_mmucr1,  
     spr_dbg_match_mmucr2        => spr_dbg_match_mmucr2,  
     spr_dbg_match_mmucr3        => spr_dbg_match_mmucr3,  

     spr_dbg_match_mmucsr0       => spr_dbg_match_mmucsr0,  
     spr_dbg_match_mmucfg        => spr_dbg_match_mmucfg,  
     spr_dbg_match_tlb0cfg       => spr_dbg_match_tlb0cfg,  
     spr_dbg_match_tlb0ps        => spr_dbg_match_tlb0ps,  
     spr_dbg_match_lratcfg       => spr_dbg_match_lratcfg,  
     spr_dbg_match_lratps        => spr_dbg_match_lratps,  
     spr_dbg_match_eptcfg        => spr_dbg_match_eptcfg,  
     spr_dbg_match_lper          => spr_dbg_match_lper,  
     spr_dbg_match_lperu         => spr_dbg_match_lperu,  

     spr_dbg_match_mas0          => spr_dbg_match_mas0,  
     spr_dbg_match_mas1          => spr_dbg_match_mas1,  
     spr_dbg_match_mas2          => spr_dbg_match_mas2,  
     spr_dbg_match_mas2u         => spr_dbg_match_mas2u,  
     spr_dbg_match_mas3          => spr_dbg_match_mas3,  
     spr_dbg_match_mas4          => spr_dbg_match_mas4,  
     spr_dbg_match_mas5          => spr_dbg_match_mas5,  
     spr_dbg_match_mas6          => spr_dbg_match_mas6,  
     spr_dbg_match_mas7          => spr_dbg_match_mas7,  
     spr_dbg_match_mas8          => spr_dbg_match_mas8,  
     spr_dbg_match_mas01_64b     => spr_dbg_match_mas01_64b,  
     spr_dbg_match_mas56_64b     => spr_dbg_match_mas56_64b,  
     spr_dbg_match_mas73_64b     => spr_dbg_match_mas73_64b,  
     spr_dbg_match_mas81_64b     => spr_dbg_match_mas81_64b,  

     spr_dbg_slowspr_val_int         => spr_dbg_slowspr_val_int,  
     spr_dbg_slowspr_rw_int          => spr_dbg_slowspr_rw_int,  
     spr_dbg_slowspr_etid_int        => spr_dbg_slowspr_etid_int,  
     spr_dbg_slowspr_addr_int        => spr_dbg_slowspr_addr_int,  
     spr_dbg_slowspr_val_out         => spr_dbg_slowspr_val_out,  
     spr_dbg_slowspr_done_out        => spr_dbg_slowspr_done_out,  
     spr_dbg_slowspr_data_out        => spr_dbg_slowspr_data_out,  
     inval_dbg_seq_q                  => inval_dbg_seq_q,  
     inval_dbg_seq_idle               => inval_dbg_seq_idle,  
     inval_dbg_seq_snoop_inprogress   => inval_dbg_seq_snoop_inprogress,  
     inval_dbg_seq_snoop_done         => inval_dbg_seq_snoop_done,  
     inval_dbg_seq_local_done         => inval_dbg_seq_local_done,  
     inval_dbg_seq_tlb0fi_done        => inval_dbg_seq_tlb0fi_done,  
     inval_dbg_seq_tlbwe_snoop_done   => inval_dbg_seq_tlbwe_snoop_done,  
     inval_dbg_ex6_valid              => inval_dbg_ex6_valid,  
     inval_dbg_ex6_thdid              => inval_dbg_ex6_thdid,  
     inval_dbg_ex6_ttype              => inval_dbg_ex6_ttype,  
     inval_dbg_snoop_forme            => inval_dbg_snoop_forme,  
     inval_dbg_snoop_local_reject     => inval_dbg_snoop_local_reject,  
     inval_dbg_an_ac_back_inv_q       => inval_dbg_an_ac_back_inv_q,  
     inval_dbg_an_ac_back_inv_lpar_id_q   => inval_dbg_an_ac_back_inv_lpar_id_q,  
     inval_dbg_an_ac_back_inv_addr_q      => inval_dbg_an_ac_back_inv_addr_q,  
     inval_dbg_snoop_valid_q          => inval_dbg_snoop_valid_q,  
     inval_dbg_snoop_ack_q            => inval_dbg_snoop_ack_q,  
     inval_dbg_snoop_attr_q           => inval_dbg_snoop_attr_q,  
     inval_dbg_snoop_attr_tlb_spec_q  => inval_dbg_snoop_attr_tlb_spec_q,  
     inval_dbg_snoop_vpn_q            => inval_dbg_snoop_vpn_q,  
     inval_dbg_lsu_tokens_q           => inval_dbg_lsu_tokens_q,  
     tlb_req_dbg_ierat_iu5_valid_q    => tlb_req_dbg_ierat_iu5_valid_q,  
     tlb_req_dbg_ierat_iu5_thdid      => tlb_req_dbg_ierat_iu5_thdid,  
     tlb_req_dbg_ierat_iu5_state_q    => tlb_req_dbg_ierat_iu5_state_q,  
     tlb_req_dbg_ierat_inptr_q        => tlb_req_dbg_ierat_inptr_q,  
     tlb_req_dbg_ierat_outptr_q       => tlb_req_dbg_ierat_outptr_q,  
     tlb_req_dbg_ierat_req_valid_q    => tlb_req_dbg_ierat_req_valid_q,  
     tlb_req_dbg_ierat_req_nonspec_q  => tlb_req_dbg_ierat_req_nonspec_q,  
     tlb_req_dbg_ierat_req_thdid      => tlb_req_dbg_ierat_req_thdid,  
     tlb_req_dbg_ierat_req_dup_q      => tlb_req_dbg_ierat_req_dup_q,  
     tlb_req_dbg_derat_ex6_valid_q    => tlb_req_dbg_derat_ex6_valid_q,  
     tlb_req_dbg_derat_ex6_thdid      => tlb_req_dbg_derat_ex6_thdid,  
     tlb_req_dbg_derat_ex6_state_q    => tlb_req_dbg_derat_ex6_state_q,  
     tlb_req_dbg_derat_inptr_q        => tlb_req_dbg_derat_inptr_q,  
     tlb_req_dbg_derat_outptr_q       => tlb_req_dbg_derat_outptr_q,  
     tlb_req_dbg_derat_req_valid_q    => tlb_req_dbg_derat_req_valid_q,  
     tlb_req_dbg_derat_req_thdid      => tlb_req_dbg_derat_req_thdid,  
     tlb_req_dbg_derat_req_ttype_q    => tlb_req_dbg_derat_req_ttype_q,  
     tlb_req_dbg_derat_req_dup_q      => tlb_req_dbg_derat_req_dup_q,  

     tlb_ctl_dbg_seq_q                => tlb_ctl_dbg_seq_q,  
     tlb_ctl_dbg_seq_idle             => tlb_ctl_dbg_seq_idle,  
     tlb_ctl_dbg_seq_any_done_sig     => tlb_ctl_dbg_seq_any_done_sig,  
     tlb_ctl_dbg_seq_abort            => tlb_ctl_dbg_seq_abort,  
     tlb_ctl_dbg_any_tlb_req_sig      => tlb_ctl_dbg_any_tlb_req_sig,  
     tlb_ctl_dbg_any_req_taken_sig    => tlb_ctl_dbg_any_req_taken_sig,  
     tlb_ctl_dbg_tag0_valid          => tlb_ctl_dbg_tag0_valid,  
     tlb_ctl_dbg_tag0_thdid          => tlb_ctl_dbg_tag0_thdid,  
     tlb_ctl_dbg_tag0_type           => tlb_ctl_dbg_tag0_type,  
     tlb_ctl_dbg_tag0_wq             => tlb_ctl_dbg_tag0_wq,  
     tlb_ctl_dbg_tag0_gs             => tlb_ctl_dbg_tag0_gs,  
     tlb_ctl_dbg_tag0_pr             => tlb_ctl_dbg_tag0_pr,  
     tlb_ctl_dbg_tag0_atsel          => tlb_ctl_dbg_tag0_atsel,  
     tlb_ctl_dbg_tag5_tlb_write_q    => tlb_ctl_dbg_tag5_tlb_write_q,  
     tlb_ctl_dbg_resv_valid          => tlb_ctl_dbg_resv_valid,  
     tlb_ctl_dbg_set_resv            => tlb_ctl_dbg_set_resv,  
     tlb_ctl_dbg_resv_match_vec_q    => tlb_ctl_dbg_resv_match_vec_q,  
     tlb_ctl_dbg_any_tag_flush_sig   => tlb_ctl_dbg_any_tag_flush_sig,  
     tlb_ctl_dbg_resv0_tag0_lpid_match         => tlb_ctl_dbg_resv0_tag0_lpid_match,  
     tlb_ctl_dbg_resv0_tag0_pid_match          => tlb_ctl_dbg_resv0_tag0_pid_match,  
     tlb_ctl_dbg_resv0_tag0_as_snoop_match     => tlb_ctl_dbg_resv0_tag0_as_snoop_match,  
     tlb_ctl_dbg_resv0_tag0_gs_snoop_match     => tlb_ctl_dbg_resv0_tag0_gs_snoop_match,  
     tlb_ctl_dbg_resv0_tag0_as_tlbwe_match     => tlb_ctl_dbg_resv0_tag0_as_tlbwe_match,  
     tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match     => tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match,  
     tlb_ctl_dbg_resv0_tag0_ind_match          => tlb_ctl_dbg_resv0_tag0_ind_match,  
     tlb_ctl_dbg_resv0_tag0_epn_loc_match      => tlb_ctl_dbg_resv0_tag0_epn_loc_match,  
     tlb_ctl_dbg_resv0_tag0_epn_glob_match     => tlb_ctl_dbg_resv0_tag0_epn_glob_match,  
     tlb_ctl_dbg_resv0_tag0_class_match        => tlb_ctl_dbg_resv0_tag0_class_match,  
     tlb_ctl_dbg_resv1_tag0_lpid_match         => tlb_ctl_dbg_resv1_tag0_lpid_match,  
     tlb_ctl_dbg_resv1_tag0_pid_match          => tlb_ctl_dbg_resv1_tag0_pid_match,  
     tlb_ctl_dbg_resv1_tag0_as_snoop_match     => tlb_ctl_dbg_resv1_tag0_as_snoop_match,  
     tlb_ctl_dbg_resv1_tag0_gs_snoop_match     => tlb_ctl_dbg_resv1_tag0_gs_snoop_match,  
     tlb_ctl_dbg_resv1_tag0_as_tlbwe_match     => tlb_ctl_dbg_resv1_tag0_as_tlbwe_match,  
     tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match     => tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match,  
     tlb_ctl_dbg_resv1_tag0_ind_match          => tlb_ctl_dbg_resv1_tag0_ind_match,  
     tlb_ctl_dbg_resv1_tag0_epn_loc_match      => tlb_ctl_dbg_resv1_tag0_epn_loc_match,  
     tlb_ctl_dbg_resv1_tag0_epn_glob_match     => tlb_ctl_dbg_resv1_tag0_epn_glob_match,  
     tlb_ctl_dbg_resv1_tag0_class_match        => tlb_ctl_dbg_resv1_tag0_class_match ,  
     tlb_ctl_dbg_resv2_tag0_lpid_match         => tlb_ctl_dbg_resv2_tag0_lpid_match,  
     tlb_ctl_dbg_resv2_tag0_pid_match          => tlb_ctl_dbg_resv2_tag0_pid_match,  
     tlb_ctl_dbg_resv2_tag0_as_snoop_match     => tlb_ctl_dbg_resv2_tag0_as_snoop_match,  
     tlb_ctl_dbg_resv2_tag0_gs_snoop_match     => tlb_ctl_dbg_resv2_tag0_gs_snoop_match,  
     tlb_ctl_dbg_resv2_tag0_as_tlbwe_match     => tlb_ctl_dbg_resv2_tag0_as_tlbwe_match,  
     tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match     => tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match,  
     tlb_ctl_dbg_resv2_tag0_ind_match          => tlb_ctl_dbg_resv2_tag0_ind_match,  
     tlb_ctl_dbg_resv2_tag0_epn_loc_match      => tlb_ctl_dbg_resv2_tag0_epn_loc_match,  
     tlb_ctl_dbg_resv2_tag0_epn_glob_match     => tlb_ctl_dbg_resv2_tag0_epn_glob_match,  
     tlb_ctl_dbg_resv2_tag0_class_match        => tlb_ctl_dbg_resv2_tag0_class_match,  
     tlb_ctl_dbg_resv3_tag0_lpid_match         => tlb_ctl_dbg_resv3_tag0_lpid_match,  
     tlb_ctl_dbg_resv3_tag0_pid_match          => tlb_ctl_dbg_resv3_tag0_pid_match,  
     tlb_ctl_dbg_resv3_tag0_as_snoop_match     => tlb_ctl_dbg_resv3_tag0_as_snoop_match,  
     tlb_ctl_dbg_resv3_tag0_gs_snoop_match     => tlb_ctl_dbg_resv3_tag0_gs_snoop_match,  
     tlb_ctl_dbg_resv3_tag0_as_tlbwe_match     => tlb_ctl_dbg_resv3_tag0_as_tlbwe_match,  
     tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match     => tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match,  
     tlb_ctl_dbg_resv3_tag0_ind_match          => tlb_ctl_dbg_resv3_tag0_ind_match,  
     tlb_ctl_dbg_resv3_tag0_epn_loc_match      => tlb_ctl_dbg_resv3_tag0_epn_loc_match,  
     tlb_ctl_dbg_resv3_tag0_epn_glob_match     => tlb_ctl_dbg_resv3_tag0_epn_glob_match,  
     tlb_ctl_dbg_resv3_tag0_class_match        => tlb_ctl_dbg_resv3_tag0_class_match,  
     tlb_ctl_dbg_clr_resv_q                    => tlb_ctl_dbg_clr_resv_q,  
     tlb_ctl_dbg_clr_resv_terms                => tlb_ctl_dbg_clr_resv_terms,  
     tlb_cmp_dbg_tag4                   => tlb_cmp_dbg_tag4,  
     tlb_cmp_dbg_tag4_wayhit            => tlb_cmp_dbg_tag4_wayhit,  
     tlb_cmp_dbg_addr4                  => tlb_cmp_dbg_addr4,  
     tlb_cmp_dbg_tag4_way               => tlb_cmp_dbg_tag4_way,  
     tlb_cmp_dbg_tag4_parerr            => tlb_cmp_dbg_tag4_parerr,  
     tlb_cmp_dbg_tag4_lru_dataout_q     => tlb_cmp_dbg_tag4_lru_dataout_q,  
     tlb_cmp_dbg_tag5_tlb_datain_q      => tlb_cmp_dbg_tag5_tlb_datain_q, 
     tlb_cmp_dbg_tag5_lru_datain_q      => tlb_cmp_dbg_tag5_lru_datain_q,  
     tlb_cmp_dbg_tag5_lru_write         => tlb_cmp_dbg_tag5_lru_write,  
     tlb_cmp_dbg_tag5_any_exception     => tlb_cmp_dbg_tag5_any_exception,  
     tlb_cmp_dbg_tag5_except_type_q     => tlb_cmp_dbg_tag5_except_type_q,  
     tlb_cmp_dbg_tag5_except_thdid_q    => tlb_cmp_dbg_tag5_except_thdid_q,  
     tlb_cmp_dbg_tag5_erat_rel_val      => tlb_cmp_dbg_tag5_erat_rel_val,  
     tlb_cmp_dbg_tag5_erat_rel_data     => tlb_cmp_dbg_tag5_erat_rel_data,  
     tlb_cmp_dbg_erat_dup_q             => tlb_cmp_dbg_erat_dup_q,  
     tlb_cmp_dbg_addr_enable            => tlb_cmp_dbg_addr_enable,  
     tlb_cmp_dbg_pgsize_enable          => tlb_cmp_dbg_pgsize_enable,  
     tlb_cmp_dbg_class_enable           => tlb_cmp_dbg_class_enable,  
     tlb_cmp_dbg_extclass_enable        => tlb_cmp_dbg_extclass_enable,  
     tlb_cmp_dbg_state_enable           => tlb_cmp_dbg_state_enable,  
     tlb_cmp_dbg_thdid_enable           => tlb_cmp_dbg_thdid_enable,  
     tlb_cmp_dbg_pid_enable             => tlb_cmp_dbg_pid_enable,  
     tlb_cmp_dbg_lpid_enable            => tlb_cmp_dbg_lpid_enable,  
     tlb_cmp_dbg_ind_enable             => tlb_cmp_dbg_ind_enable,  
     tlb_cmp_dbg_iprot_enable           => tlb_cmp_dbg_iprot_enable,  
     tlb_cmp_dbg_way0_entry_v                        => tlb_cmp_dbg_way0_entry_v,  
     tlb_cmp_dbg_way0_addr_match                     => tlb_cmp_dbg_way0_addr_match,  
     tlb_cmp_dbg_way0_pgsize_match                   => tlb_cmp_dbg_way0_pgsize_match,  
     tlb_cmp_dbg_way0_class_match                    => tlb_cmp_dbg_way0_class_match,  
     tlb_cmp_dbg_way0_extclass_match                 => tlb_cmp_dbg_way0_extclass_match,  
     tlb_cmp_dbg_way0_state_match                    => tlb_cmp_dbg_way0_state_match,  
     tlb_cmp_dbg_way0_thdid_match                    => tlb_cmp_dbg_way0_thdid_match,  
     tlb_cmp_dbg_way0_pid_match                      => tlb_cmp_dbg_way0_pid_match,  
     tlb_cmp_dbg_way0_lpid_match                     => tlb_cmp_dbg_way0_lpid_match,  
     tlb_cmp_dbg_way0_ind_match                      => tlb_cmp_dbg_way0_ind_match,  
     tlb_cmp_dbg_way0_iprot_match                    => tlb_cmp_dbg_way0_iprot_match,  
     tlb_cmp_dbg_way1_entry_v                        => tlb_cmp_dbg_way1_entry_v,  
     tlb_cmp_dbg_way1_addr_match                     => tlb_cmp_dbg_way1_addr_match,  
     tlb_cmp_dbg_way1_pgsize_match                   => tlb_cmp_dbg_way1_pgsize_match,  
     tlb_cmp_dbg_way1_class_match                    => tlb_cmp_dbg_way1_class_match,  
     tlb_cmp_dbg_way1_extclass_match                 => tlb_cmp_dbg_way1_extclass_match,  
     tlb_cmp_dbg_way1_state_match                    => tlb_cmp_dbg_way1_state_match,  
     tlb_cmp_dbg_way1_thdid_match                    => tlb_cmp_dbg_way1_thdid_match,  
     tlb_cmp_dbg_way1_pid_match                      => tlb_cmp_dbg_way1_pid_match,  
     tlb_cmp_dbg_way1_lpid_match                     => tlb_cmp_dbg_way1_lpid_match,  
     tlb_cmp_dbg_way1_ind_match                      => tlb_cmp_dbg_way1_ind_match,  
     tlb_cmp_dbg_way1_iprot_match                    => tlb_cmp_dbg_way1_iprot_match,  
     tlb_cmp_dbg_way2_entry_v                        => tlb_cmp_dbg_way2_entry_v,  
     tlb_cmp_dbg_way2_addr_match                     => tlb_cmp_dbg_way2_addr_match,  
     tlb_cmp_dbg_way2_pgsize_match                   => tlb_cmp_dbg_way2_pgsize_match,  
     tlb_cmp_dbg_way2_class_match                    => tlb_cmp_dbg_way2_class_match,  
     tlb_cmp_dbg_way2_extclass_match                 => tlb_cmp_dbg_way2_extclass_match,  
     tlb_cmp_dbg_way2_state_match                    => tlb_cmp_dbg_way2_state_match,  
     tlb_cmp_dbg_way2_thdid_match                    => tlb_cmp_dbg_way2_thdid_match,  
     tlb_cmp_dbg_way2_pid_match                      => tlb_cmp_dbg_way2_pid_match,  
     tlb_cmp_dbg_way2_lpid_match                     => tlb_cmp_dbg_way2_lpid_match,  
     tlb_cmp_dbg_way2_ind_match                      => tlb_cmp_dbg_way2_ind_match,  
     tlb_cmp_dbg_way2_iprot_match                    => tlb_cmp_dbg_way2_iprot_match,  
     tlb_cmp_dbg_way3_entry_v                        => tlb_cmp_dbg_way3_entry_v,  
     tlb_cmp_dbg_way3_addr_match                     => tlb_cmp_dbg_way3_addr_match,  
     tlb_cmp_dbg_way3_pgsize_match                   => tlb_cmp_dbg_way3_pgsize_match,  
     tlb_cmp_dbg_way3_class_match                    => tlb_cmp_dbg_way3_class_match,  
     tlb_cmp_dbg_way3_extclass_match                 => tlb_cmp_dbg_way3_extclass_match,  
     tlb_cmp_dbg_way3_state_match                    => tlb_cmp_dbg_way3_state_match,  
     tlb_cmp_dbg_way3_thdid_match                    => tlb_cmp_dbg_way3_thdid_match,  
     tlb_cmp_dbg_way3_pid_match                      => tlb_cmp_dbg_way3_pid_match,  
     tlb_cmp_dbg_way3_lpid_match                     => tlb_cmp_dbg_way3_lpid_match,  
     tlb_cmp_dbg_way3_ind_match                      => tlb_cmp_dbg_way3_ind_match,  
     tlb_cmp_dbg_way3_iprot_match                    => tlb_cmp_dbg_way3_iprot_match,  

     lrat_dbg_tag1_addr_enable    => lrat_dbg_tag1_addr_enable,  
     lrat_dbg_tag2_matchline_q    => lrat_dbg_tag2_matchline_q,  
     lrat_dbg_entry0_addr_match   => lrat_dbg_entry0_addr_match,  
     lrat_dbg_entry0_lpid_match   => lrat_dbg_entry0_lpid_match,  
     lrat_dbg_entry0_entry_v      => lrat_dbg_entry0_entry_v,  
     lrat_dbg_entry0_entry_x      => lrat_dbg_entry0_entry_x,  
     lrat_dbg_entry0_size         => lrat_dbg_entry0_size,  
     lrat_dbg_entry1_addr_match   => lrat_dbg_entry1_addr_match,  
     lrat_dbg_entry1_lpid_match   => lrat_dbg_entry1_lpid_match,  
     lrat_dbg_entry1_entry_v      => lrat_dbg_entry1_entry_v,  
     lrat_dbg_entry1_entry_x      => lrat_dbg_entry1_entry_x,  
     lrat_dbg_entry1_size         => lrat_dbg_entry1_size,  
     lrat_dbg_entry2_addr_match   => lrat_dbg_entry2_addr_match,  
     lrat_dbg_entry2_lpid_match   => lrat_dbg_entry2_lpid_match,  
     lrat_dbg_entry2_entry_v      => lrat_dbg_entry2_entry_v,  
     lrat_dbg_entry2_entry_x      => lrat_dbg_entry2_entry_x,  
     lrat_dbg_entry2_size         => lrat_dbg_entry2_size,  
     lrat_dbg_entry3_addr_match   => lrat_dbg_entry3_addr_match,  
     lrat_dbg_entry3_lpid_match   => lrat_dbg_entry3_lpid_match,  
     lrat_dbg_entry3_entry_v      => lrat_dbg_entry3_entry_v,  
     lrat_dbg_entry3_entry_x      => lrat_dbg_entry3_entry_x,  
     lrat_dbg_entry3_size         => lrat_dbg_entry3_size,  
     lrat_dbg_entry4_addr_match   => lrat_dbg_entry4_addr_match,  
     lrat_dbg_entry4_lpid_match   => lrat_dbg_entry4_lpid_match,  
     lrat_dbg_entry4_entry_v      => lrat_dbg_entry4_entry_v,  
     lrat_dbg_entry4_entry_x      => lrat_dbg_entry4_entry_x,  
     lrat_dbg_entry4_size         => lrat_dbg_entry4_size,  
     lrat_dbg_entry5_addr_match   => lrat_dbg_entry5_addr_match,  
     lrat_dbg_entry5_lpid_match   => lrat_dbg_entry5_lpid_match,  
     lrat_dbg_entry5_entry_v      => lrat_dbg_entry5_entry_v,  
     lrat_dbg_entry5_entry_x      => lrat_dbg_entry5_entry_x,  
     lrat_dbg_entry5_size         => lrat_dbg_entry5_size,  
     lrat_dbg_entry6_addr_match   => lrat_dbg_entry6_addr_match,  
     lrat_dbg_entry6_lpid_match   => lrat_dbg_entry6_lpid_match,  
     lrat_dbg_entry6_entry_v      => lrat_dbg_entry6_entry_v,  
     lrat_dbg_entry6_entry_x      => lrat_dbg_entry6_entry_x,  
     lrat_dbg_entry6_size         => lrat_dbg_entry6_size,  
     lrat_dbg_entry7_addr_match   => lrat_dbg_entry7_addr_match,  
     lrat_dbg_entry7_lpid_match   => lrat_dbg_entry7_lpid_match,  
     lrat_dbg_entry7_entry_v      => lrat_dbg_entry7_entry_v,  
     lrat_dbg_entry7_entry_x      => lrat_dbg_entry7_entry_x,  
     lrat_dbg_entry7_size         => lrat_dbg_entry7_size,  
     htw_dbg_seq_idle                 => htw_dbg_seq_idle,  
     htw_dbg_pte0_seq_idle            => htw_dbg_pte0_seq_idle,  
     htw_dbg_pte1_seq_idle            => htw_dbg_pte1_seq_idle,  
     htw_dbg_seq_q                    => htw_dbg_seq_q,  
     htw_dbg_inptr_q                  => htw_dbg_inptr_q,  
     htw_dbg_pte0_seq_q               => htw_dbg_pte0_seq_q,  
     htw_dbg_pte1_seq_q               => htw_dbg_pte1_seq_q,  
     htw_dbg_ptereload_ptr_q          => htw_dbg_ptereload_ptr_q,  
     htw_dbg_lsuptr_q                 => htw_dbg_lsuptr_q,  
     htw_dbg_req_valid_q              => htw_dbg_req_valid_q,  
     htw_dbg_resv_valid_vec           => htw_dbg_resv_valid_vec,  
     htw_dbg_tag4_clr_resv_q          => htw_dbg_tag4_clr_resv_q,  
     htw_dbg_tag4_clr_resv_terms      => htw_dbg_tag4_clr_resv_terms,  
     htw_dbg_pte0_score_ptr_q         => htw_dbg_pte0_score_ptr_q,  
     htw_dbg_pte0_score_cl_offset_q   => htw_dbg_pte0_score_cl_offset_q,  
     htw_dbg_pte0_score_error_q       => htw_dbg_pte0_score_error_q,  
     htw_dbg_pte0_score_qwbeat_q      => htw_dbg_pte0_score_qwbeat_q,  
     htw_dbg_pte0_score_pending_q     => htw_dbg_pte0_score_pending_q,  
     htw_dbg_pte0_score_ibit_q        => htw_dbg_pte0_score_ibit_q,  
     htw_dbg_pte0_score_dataval_q     => htw_dbg_pte0_score_dataval_q,  
     htw_dbg_pte0_reld_for_me_tm1     => htw_dbg_pte0_reld_for_me_tm1,  
     htw_dbg_pte1_score_ptr_q         => htw_dbg_pte1_score_ptr_q,  
     htw_dbg_pte1_score_cl_offset_q   => htw_dbg_pte1_score_cl_offset_q,  
     htw_dbg_pte1_score_error_q       => htw_dbg_pte1_score_error_q,  
     htw_dbg_pte1_score_qwbeat_q      => htw_dbg_pte1_score_qwbeat_q,  
     htw_dbg_pte1_score_pending_q     => htw_dbg_pte1_score_pending_q,  
     htw_dbg_pte1_score_ibit_q        => htw_dbg_pte1_score_ibit_q,  
     htw_dbg_pte1_score_dataval_q     => htw_dbg_pte1_score_dataval_q,  
     htw_dbg_pte1_reld_for_me_tm1     => htw_dbg_pte1_reld_for_me_tm1,  

     mm_xu_lsu_req              => mm_xu_lsu_req_sig,  
     mm_xu_lsu_ttype            => mm_xu_lsu_ttype_sig,  
     mm_xu_lsu_wimge            => mm_xu_lsu_wimge_sig,  
     mm_xu_lsu_u                => mm_xu_lsu_u_sig,  
     mm_xu_lsu_addr             => mm_xu_lsu_addr_sig,  
     mm_xu_lsu_lpid             => mm_xu_lsu_lpid_sig,  
     mm_xu_lsu_gs               => mm_xu_lsu_gs_sig,  
     mm_xu_lsu_ind              => mm_xu_lsu_ind_sig,  
     mm_xu_lsu_lbit             => mm_xu_lsu_lbit_sig,  
     xu_mm_lsu_token            => xu_mm_lsu_token,  
     tlb_mas_tlbre            => tlb_mas_tlbre,  
     tlb_mas_tlbsx_hit        => tlb_mas_tlbsx_hit,  
     tlb_mas_tlbsx_miss       => tlb_mas_tlbsx_miss,  
     tlb_mas_dtlb_error       => tlb_mas_dtlb_error,  
     tlb_mas_itlb_error       => tlb_mas_itlb_error,  
     tlb_mas_thdid            => tlb_mas_thdid,  
     lrat_mas_tlbre           => lrat_mas_tlbre,  
     lrat_mas_tlbsx_hit       => lrat_mas_tlbsx_hit,  
     lrat_mas_tlbsx_miss      => lrat_mas_tlbsx_miss,  
     lrat_mas_thdid           => lrat_mas_thdid,  
     lrat_tag3_hit_status     => lrat_tag3_hit_status,  
     lrat_tag3_hit_entry      => lrat_tag3_hit_entry,  

     tlb_seq_ierat_req               => tlb_seq_ierat_req,  
     tlb_seq_derat_req               => tlb_seq_derat_req,  
     mm_xu_hold_req                  => mm_xu_hold_req_sig,  
     xu_mm_hold_ack                  => xu_mm_hold_ack,  
     mm_xu_hold_done                 => mm_xu_hold_done_sig,  
     mmucsr0_tlb0fi                  => mmucsr0_tlb0fi,  
     tlbwe_back_inv_valid            => tlbwe_back_inv_valid_sig,  
     tlbwe_back_inv_attr             => tlbwe_back_inv_attr_sig(18 to 19),  
     xu_mm_lmq_stq_empty             => xu_mm_lmq_stq_empty,  
     iu_mm_lmq_empty                 => iu_mm_lmq_empty,  
     mm_xu_eratmiss_done             => mm_xu_eratmiss_done_sig,  
     mm_iu_barrier_done              => mm_iu_barrier_done_sig,  
     mm_xu_ex3_flush_req             => mm_xu_ex3_flush_req_sig,  
     mm_xu_illeg_instr               => mm_xu_illeg_instr_sig,  
     lrat_tag4_hit_status            => lrat_tag4_hit_status,  
     lrat_tag4_hit_entry             => lrat_tag4_hit_entry,  
     mm_xu_cr0_eq                    => mm_xu_cr0_eq_sig,  
     mm_xu_cr0_eq_valid              => mm_xu_cr0_eq_valid_sig,  
     tlb_htw_req_valid               => tlb_htw_req_valid,  
     htw_lsu_req_valid               => htw_lsu_req_valid,  
     htw_dbg_lsu_thdid               => htw_dbg_lsu_thdid,  
     htw_lsu_ttype                   => htw_lsu_ttype,  
     htw_lsu_addr                    => htw_lsu_addr,  
     ptereload_req_taken             => ptereload_req_taken,  
     ptereload_req_pte               => ptereload_req_pte   
);
-- End of mmq_dbg component instantiation
-----------------------------------------------------------------------
-- Performance Event component instantiation
-----------------------------------------------------------------------
mmq_perf: entity work.mmq_perf(mmq_perf)
  generic map ( expand_type => expand_type )
  port map(
     vdd               => vdd,
     gnd               => gnd,
     nclk              => nclk,
     pc_func_sl_thold_2      => pc_func_sl_thold_2(0),
     pc_func_slp_nsl_thold_2 => pc_func_slp_nsl_thold_2,
     pc_sg_2                 => pc_sg_2(0),
     pc_fce_2                => pc_fce_2,
     tc_ac_ccflush_dc        => tc_ac_ccflush_dc,
     lcb_clkoff_dc_b         => lcb_clkoff_dc_b,
     lcb_act_dis_dc          => lcb_act_dis_dc,
     lcb_d_mode_dc           => lcb_d_mode_dc,
     lcb_delay_lclkr_dc      => lcb_delay_lclkr_dc(0),
     lcb_mpw1_dc_b           => lcb_mpw1_dc_b(0),
     lcb_mpw2_dc_b           => lcb_mpw2_dc_b,
     scan_in            => siv_1(mmq_perf_offset),
     scan_out           => sov_1(mmq_perf_offset),

     xu_mm_msr_gs       => xu_mm_msr_gs,  
     xu_mm_msr_pr       => xu_mm_msr_pr,  
     xu_mm_ccr2_notlb_b => xu_mm_ccr2_notlb_b(2),


-- count event inputs
xu_mm_ex5_perf_dtlb     =>  xu_mm_ex5_perf_dtlb, 
     xu_mm_ex5_perf_itlb     =>  xu_mm_ex5_perf_itlb, 

     tlb_cmp_perf_event_t0    =>  tlb_cmp_perf_event_t0,       
     tlb_cmp_perf_event_t1    =>  tlb_cmp_perf_event_t1,           
     tlb_cmp_perf_event_t2    =>  tlb_cmp_perf_event_t2,           
     tlb_cmp_perf_event_t3    =>  tlb_cmp_perf_event_t3,
     tlb_cmp_perf_state       =>  tlb_cmp_perf_state,        

     derat_req0_thdid                => derat_req0_thdid_sig,    
     derat_req0_valid                => derat_req0_valid_sig,    
     derat_req1_thdid                => derat_req1_thdid_sig,    
     derat_req1_valid                => derat_req1_valid_sig,    
     derat_req2_thdid                => derat_req2_thdid_sig,    
     derat_req2_valid                => derat_req2_valid_sig,    
     derat_req3_thdid                => derat_req3_thdid_sig,    
     derat_req3_valid                => derat_req3_valid_sig,    
     ierat_req0_thdid                => ierat_req0_thdid_sig,    
     ierat_req0_valid                => ierat_req0_valid_sig,    
     ierat_req0_nonspec              => ierat_req0_nonspec_sig,    
     ierat_req1_thdid                => ierat_req1_thdid_sig,    
     ierat_req1_valid                => ierat_req1_valid_sig,    
     ierat_req1_nonspec              => ierat_req1_nonspec_sig,    
     ierat_req2_thdid                => ierat_req2_thdid_sig,    
     ierat_req2_valid                => ierat_req2_valid_sig,    
     ierat_req2_nonspec              => ierat_req2_nonspec_sig,    
     ierat_req3_thdid                => ierat_req3_thdid_sig,    
     ierat_req3_valid                => ierat_req3_valid_sig,    
     ierat_req3_nonspec              => ierat_req3_nonspec_sig,    
     ierat_req_taken                 => ierat_req_taken,
     derat_req_taken                 => derat_req_taken,

     tlb_tag0_thdid              => tlb_tag0_thdid,  
     tlb_tag0_type               => tlb_tag0_type(0 to 1),  
     tlb_seq_idle                => tlb_seq_idle,  

     inval_perf_tlbilx          => inval_perf_tlbilx,
     inval_perf_tlbivax         => inval_perf_tlbivax,
     inval_perf_tlbivax_snoop   => inval_perf_tlbivax_snoop,
     inval_perf_tlb_flush       => inval_perf_tlb_flush,

     htw_req0_valid           => htw_req0_valid,    
     htw_req0_thdid           => htw_req0_thdid,    
     htw_req0_type            => htw_req0_type,    
     htw_req1_valid           => htw_req1_valid,    
     htw_req1_thdid           => htw_req1_thdid,    
     htw_req1_type            => htw_req1_type,    
     htw_req2_valid           => htw_req2_valid,    
     htw_req2_thdid           => htw_req2_thdid,    
     htw_req2_type            => htw_req2_type,    
     htw_req3_valid           => htw_req3_valid,    
     htw_req3_thdid           => htw_req3_thdid,    
     htw_req3_type            => htw_req3_type,    

     tlb_cmp_perf_miss_direct       => tlb_cmp_perf_miss_direct, 
     tlb_cmp_perf_hit_indirect      => tlb_cmp_perf_hit_indirect,  
     tlb_cmp_perf_hit_first_page    => tlb_cmp_perf_hit_first_page, 
     tlb_cmp_perf_ptereload_noexcep => tlb_cmp_perf_ptereload_noexcep,  
     tlb_cmp_perf_lrat_request      => tlb_cmp_perf_lrat_request,   
     tlb_cmp_perf_lrat_miss         => tlb_cmp_perf_lrat_miss,  
     tlb_cmp_perf_pt_fault          => tlb_cmp_perf_pt_fault,  
     tlb_cmp_perf_pt_inelig         => tlb_cmp_perf_pt_inelig,  
     tlb_ctl_perf_tlbwec_resv       => tlb_ctl_perf_tlbwec_resv,  
     tlb_ctl_perf_tlbwec_noresv     => tlb_ctl_perf_tlbwec_noresv,  


-- control inputs
pc_mm_event_mux_ctrls       => pc_mm_event_mux_ctrls(0 to 39),
     pc_mm_event_count_mode      => pc_mm_event_count_mode(0 to 2),
     rp_mm_event_bus_enable_q    => rp_mm_event_bus_enable_q,
     mm_pc_event_data            => mm_pc_event_data(0 to 7)
);
-- End of mmq_perf component instantiation
-----------------------------------------------------------------------
-- Pervasive and LCB Control Component Instantiation
-----------------------------------------------------------------------
mmq_perv : entity work.mmq_perv(mmq_perv)
generic map (expand_type        => expand_type)
port map (
          vdd                   => vdd,
          gnd                   => gnd,
          nclk                  => nclk,
          pc_mm_sg_3                => pc_mm_sg_3,
          pc_mm_func_sl_thold_3     => pc_mm_func_sl_thold_3,
          pc_mm_func_slp_sl_thold_3 => pc_mm_func_slp_sl_thold_3,
          pc_mm_gptr_sl_thold_3     => pc_mm_gptr_sl_thold_3,
          pc_mm_fce_3               => pc_mm_fce_3,
          pc_mm_time_sl_thold_3       => pc_mm_time_sl_thold_3, 
          pc_mm_repr_sl_thold_3       => pc_mm_repr_sl_thold_3, 
          pc_mm_abst_sl_thold_3       => pc_mm_abst_sl_thold_3, 
          pc_mm_abst_slp_sl_thold_3   => pc_mm_abst_slp_sl_thold_3, 
          pc_mm_cfg_sl_thold_3        => pc_mm_cfg_sl_thold_3, 
          pc_mm_cfg_slp_sl_thold_3    => pc_mm_cfg_slp_sl_thold_3, 
          pc_mm_func_nsl_thold_3      => pc_mm_func_nsl_thold_3, 
          pc_mm_func_slp_nsl_thold_3  => pc_mm_func_slp_nsl_thold_3, 
          pc_mm_ary_nsl_thold_3       => pc_mm_ary_nsl_thold_3, 
          pc_mm_ary_slp_nsl_thold_3   => pc_mm_ary_slp_nsl_thold_3, 
          tc_ac_ccflush_dc          => tc_ac_ccflush_dc,
          tc_scan_diag_dc           => tc_ac_scan_diag_dc,
          tc_ac_scan_dis_dc_b       => tc_ac_scan_dis_dc_b,

          pc_sg_0                => pc_sg_0,
          pc_sg_1                => pc_sg_1,
          pc_sg_2                => pc_sg_2,
          pc_func_sl_thold_2     => pc_func_sl_thold_2,
          pc_func_slp_sl_thold_2 => pc_func_slp_sl_thold_2,
          pc_func_slp_nsl_thold_2 => pc_func_slp_nsl_thold_2,
          pc_cfg_sl_thold_2      => pc_cfg_sl_thold_2,  
          pc_cfg_slp_sl_thold_2  => pc_cfg_slp_sl_thold_2,  
          pc_fce_2               => pc_fce_2,
          pc_time_sl_thold_0      => pc_time_sl_thold_0,  
          pc_repr_sl_thold_0      => pc_repr_sl_thold_0,  
          pc_abst_sl_thold_0      => pc_abst_sl_thold_0,  
          pc_abst_slp_sl_thold_0  => pc_abst_slp_sl_thold_0,  
          pc_ary_nsl_thold_0      => pc_ary_nsl_thold_0,  
          pc_ary_slp_nsl_thold_0  => pc_ary_slp_nsl_thold_0,  
          pc_func_sl_thold_0        => pc_func_sl_thold_0,  
          pc_func_sl_thold_0_b      => pc_func_sl_thold_0_b,  
          pc_func_slp_sl_thold_0    => pc_func_slp_sl_thold_0,  
          pc_func_slp_sl_thold_0_b  => pc_func_slp_sl_thold_0_b,  
          lcb_clkoff_dc_b       => lcb_clkoff_dc_b,
          lcb_act_dis_dc        => lcb_act_dis_dc,
          lcb_d_mode_dc         => lcb_d_mode_dc,
          lcb_delay_lclkr_dc    => lcb_delay_lclkr_dc,
          lcb_mpw1_dc_b         => lcb_mpw1_dc_b,
          lcb_mpw2_dc_b         => lcb_mpw2_dc_b,
          g8t_gptr_lcb_clkoff_dc_b       => g8t_gptr_lcb_clkoff_dc_b,
          g8t_gptr_lcb_act_dis_dc        => g8t_gptr_lcb_act_dis_dc,
          g8t_gptr_lcb_d_mode_dc         => g8t_gptr_lcb_d_mode_dc,
          g8t_gptr_lcb_delay_lclkr_dc    => g8t_gptr_lcb_delay_lclkr_dc,
          g8t_gptr_lcb_mpw1_dc_b         => g8t_gptr_lcb_mpw1_dc_b,
          g8t_gptr_lcb_mpw2_dc_b         => g8t_gptr_lcb_mpw2_dc_b,
          g6t_gptr_lcb_clkoff_dc_b       => g6t_gptr_lcb_clkoff_dc_b,
          g6t_gptr_lcb_act_dis_dc        => g6t_gptr_lcb_act_dis_dc,
          g6t_gptr_lcb_d_mode_dc         => g6t_gptr_lcb_d_mode_dc,
          g6t_gptr_lcb_delay_lclkr_dc    => g6t_gptr_lcb_delay_lclkr_dc,
          g6t_gptr_lcb_mpw1_dc_b         => g6t_gptr_lcb_mpw1_dc_b,
          g6t_gptr_lcb_mpw2_dc_b         => g6t_gptr_lcb_mpw2_dc_b,

          pc_mm_abist_dcomp_g6t_2r    => pc_mm_abist_dcomp_g6t_2r,   
          pc_mm_abist_di_0            => pc_mm_abist_di_0,           
          pc_mm_abist_di_g6t_2r       => pc_mm_abist_di_g6t_2r,      
          pc_mm_abist_ena_dc          => pc_mm_abist_ena_dc,         
          pc_mm_abist_g6t_r_wb        => pc_mm_abist_g6t_r_wb,       
          pc_mm_abist_g8t1p_renb_0    => pc_mm_abist_g8t1p_renb_0,   
          pc_mm_abist_g8t_bw_0        => pc_mm_abist_g8t_bw_0,       
          pc_mm_abist_g8t_bw_1        => pc_mm_abist_g8t_bw_1,       
          pc_mm_abist_g8t_dcomp       => pc_mm_abist_g8t_dcomp,      
          pc_mm_abist_g8t_wenb        => pc_mm_abist_g8t_wenb,       
          pc_mm_abist_raddr_0         => pc_mm_abist_raddr_0,        
          pc_mm_abist_waddr_0         => pc_mm_abist_waddr_0,        
          pc_mm_abist_wl128_comp_ena  => pc_mm_abist_wl128_comp_ena, 

          pc_mm_abist_g8t_wenb_q        => pc_mm_abist_g8t_wenb_q,       
          pc_mm_abist_g8t1p_renb_0_q    => pc_mm_abist_g8t1p_renb_0_q,   
          pc_mm_abist_di_0_q            => pc_mm_abist_di_0_q,           
          pc_mm_abist_g8t_bw_1_q        => pc_mm_abist_g8t_bw_1_q,       
          pc_mm_abist_g8t_bw_0_q        => pc_mm_abist_g8t_bw_0_q,       
          pc_mm_abist_waddr_0_q         => pc_mm_abist_waddr_0_q,        
          pc_mm_abist_raddr_0_q         => pc_mm_abist_raddr_0_q,        
          pc_mm_abist_wl128_comp_ena_q  => pc_mm_abist_wl128_comp_ena_q, 
          pc_mm_abist_g8t_dcomp_q       => pc_mm_abist_g8t_dcomp_q,      
          pc_mm_abist_dcomp_g6t_2r_q    => pc_mm_abist_dcomp_g6t_2r_q,   
          pc_mm_abist_di_g6t_2r_q       => pc_mm_abist_di_g6t_2r_q,      
          pc_mm_abist_g6t_r_wb_q        => pc_mm_abist_g6t_r_wb_q,       

          pc_mm_bolt_sl_thold_3         => pc_mm_bolt_sl_thold_3,   
          pc_mm_bo_enable_3             => pc_mm_bo_enable_3,       
          pc_mm_bolt_sl_thold_0         => pc_mm_bolt_sl_thold_0,   
          pc_mm_bo_enable_2             => pc_mm_bo_enable_2,       

          gptr_scan_in          => gptr_scan_in,
          gptr_scan_out         => ac_an_gptr_scan_out,

          time_scan_in          => time_scan_in,   
          time_scan_in_int      => time_scan_in_int,  
          time_scan_out_int     => time_scan_out_int,   
          time_scan_out         => ac_an_time_scan_out,  

          func_scan_in(0 to 8)    => an_ac_func_scan_in(22 to 30),   
          func_scan_in(9)          => an_ac_func_scan_in(59),   
          func_scan_in_int         => func_scan_in_int,  
          func_scan_out_int        => func_scan_out_int,   
          func_scan_out(0 to 8)   => ac_an_func_scan_out(22 to 30),  
          func_scan_out(9)         => ac_an_func_scan_out(59),        

          repr_scan_in          => repr_scan_in,   
          repr_scan_in_int      => repr_scan_in_int,  
          repr_scan_out_int     => repr_scan_out_int,   
          repr_scan_out         => ac_an_repr_scan_out,  

          abst_scan_in          => an_ac_abst_scan_in(5 to 6),   
          abst_scan_in_int      => abst_scan_in_int,  
          abst_scan_out_int     => abst_scan_out_int,   
          abst_scan_out         => ac_an_abst_scan_out(5 to 6),  

          bcfg_scan_in          => an_ac_bcfg_scan_in(2),   
          bcfg_scan_in_int      => bcfg_scan_in_int,  
          bcfg_scan_out_int     => bcfg_scan_out_int,   
          bcfg_scan_out         => bcfg_scan_out,  

          ccfg_scan_in          => an_ac_bcfg_scan_in(0),   
          ccfg_scan_in_int      => ccfg_scan_in_int,  
          ccfg_scan_out_int     => ccfg_scan_out_int,   
          ccfg_scan_out         => ccfg_scan_out,  

          dcfg_scan_in          => an_ac_dcfg_scan_in(0),   
          dcfg_scan_in_int      => dcfg_scan_in_int,  
          dcfg_scan_out_int     => dcfg_scan_out_int,   
          dcfg_scan_out         => dcfg_scan_out     
  );
-----------------------------------------------------------------------
-- output assignments
-----------------------------------------------------------------------
-- tie off undriven ports when tlb components are not present
--  keep this here for schmucks that like to control TLB existence with generics
eratonly_tieoffs_gen: if expand_tlb_type = 0 generate
mm_iu_ierat_rel_val_sig        <= (others => '0');
mm_iu_ierat_rel_data_sig       <= (others => '0');
mm_xu_derat_rel_val_sig        <= (others => '0');
mm_xu_derat_rel_data_sig       <= (others => '0');
tlb_cmp_ierat_dup_val_sig      <= (others => '0');
tlb_cmp_derat_dup_val_sig      <= (others => '0');
tlb_cmp_erat_dup_wait_sig      <= (others => '0');
tlb_ctl_barrier_done_sig   <= (others => '0');
tlb_ctl_ex2_flush_req_sig  <= (others => '0');
tlb_ctl_ex2_illeg_instr_sig  <= (others => '0');
tlb_req_quiesce_sig          <= (others => '1');
tlb_ctl_quiesce_sig          <= (others => '1');
htw_quiesce_sig              <= (others => '1');
-- missing perf count signals
tlb_cmp_perf_event_t0      <= (others => '0');
tlb_cmp_perf_event_t1      <= (others => '0');
tlb_cmp_perf_event_t2      <= (others => '0');
tlb_cmp_perf_event_t3      <= (others => '0');
tlb_cmp_perf_state         <= (others => '0');
derat_req0_thdid_sig       <= (others => '0');
derat_req0_valid_sig       <= '0';
derat_req1_thdid_sig       <= (others => '0');
derat_req1_valid_sig       <= '0';
derat_req2_thdid_sig       <= (others => '0');
derat_req2_valid_sig       <= '0';
derat_req3_thdid_sig       <= (others => '0');
derat_req3_valid_sig       <= '0';
ierat_req0_thdid_sig       <= (others => '0');
ierat_req0_valid_sig       <= '0';
ierat_req0_nonspec_sig     <= '0';
ierat_req1_thdid_sig       <= (others => '0');
ierat_req1_valid_sig       <= '0';
ierat_req1_nonspec_sig     <= '0';
ierat_req2_thdid_sig       <= (others => '0');
ierat_req2_valid_sig       <= '0';
ierat_req2_nonspec_sig     <= '0';
ierat_req3_thdid_sig       <= (others => '0');
ierat_req3_valid_sig       <= '0';
ierat_req3_nonspec_sig     <= '0';
tlb_tag0_thdid             <= (others => '0');
tlb_tag0_type              <= (others => '0');
tlb_seq_idle               <= '0';
htw_req0_valid           <= '0';
htw_req0_thdid           <= (others => '0');
htw_req0_type            <= (others => '0');
htw_req1_valid           <= '0';
htw_req1_thdid           <= (others => '0');
htw_req1_type            <= (others => '0');
htw_req2_valid           <= '0';
htw_req2_thdid           <= (others => '0');
htw_req2_type            <= (others => '0');
htw_req3_valid           <= '0';
htw_req3_thdid           <= (others => '0');
htw_req3_type            <= (others => '0');
tlb_cmp_perf_miss_direct       <= '0';
tlb_cmp_perf_hit_indirect      <= '0';
tlb_cmp_perf_hit_first_page    <= '0';
tlb_cmp_perf_ptereload_noexcep <= '0';
tlb_cmp_perf_lrat_request      <= '0';
tlb_cmp_perf_lrat_miss         <= '0';
tlb_cmp_perf_pt_fault          <= '0';
tlb_cmp_perf_pt_inelig         <= '0';
tlb_ctl_perf_tlbwec_resv       <= '0';
tlb_ctl_perf_tlbwec_noresv     <= '0';
-- missing debug signals
tlb_cmp_dbg_tag4                <= (others => '0');
tlb_cmp_dbg_tag4_wayhit         <= (others => '0');
tlb_cmp_dbg_addr4               <= (others => '0');
tlb_cmp_dbg_tag4_way            <= (others => '0');
mm_xu_eratmiss_done_sig <= (others => '0');
mm_xu_tlb_miss_sig      <= (others => '0');
mm_xu_lrat_miss_sig     <= (others => '0');
mm_xu_tlb_inelig_sig    <= (others => '0');
mm_xu_pt_fault_sig      <= (others => '0');
mm_xu_hv_priv_sig       <= (others => '0');
mm_xu_cr0_eq_sig        <= (others => '0');
mm_xu_cr0_eq_valid_sig  <= (others => '0');
mm_xu_esr_pt_sig        <= (others => '0');
mm_xu_esr_data_sig      <= (others => '0');
mm_xu_esr_epid_sig      <= (others => '0');
mm_xu_esr_st_sig        <= (others => '0');
mm_xu_tlb_multihit_err    <= (others => '0');
mm_xu_tlb_par_err         <= (others => '0');
mm_xu_lru_par_err         <= (others => '0');
tlb_snoop_ack <= '0';
end generate eratonly_tieoffs_gen;
mm_iu_ierat_rel_val        <= mm_iu_ierat_rel_val_sig;
mm_iu_ierat_rel_data       <= mm_iu_ierat_rel_data_sig;
mm_xu_derat_rel_val        <= mm_xu_derat_rel_val_sig;
mm_xu_derat_rel_data       <= mm_xu_derat_rel_data_sig;
mm_xu_hold_req                  <= mm_xu_hold_req_sig;
mm_xu_hold_done                 <= mm_xu_hold_done_sig;
mm_iu_barrier_done        <= mm_iu_barrier_done_sig;
mm_xu_eratmiss_done        <= mm_xu_eratmiss_done_sig;
mm_xu_tlb_miss             <= mm_xu_tlb_miss_sig;
mm_xu_lrat_miss             <= mm_xu_lrat_miss_sig;
mm_xu_tlb_inelig    <= mm_xu_tlb_inelig_sig;
mm_xu_pt_fault      <= mm_xu_pt_fault_sig;
mm_xu_hv_priv       <= mm_xu_hv_priv_sig;
mm_xu_illeg_instr   <= mm_xu_illeg_instr_sig;
mm_xu_esr_pt        <= mm_xu_esr_pt_sig;
mm_xu_esr_data      <= mm_xu_esr_data_sig;
mm_xu_esr_epid      <= mm_xu_esr_epid_sig;
mm_xu_esr_st        <= mm_xu_esr_st_sig;
mm_xu_cr0_eq        <= mm_xu_cr0_eq_sig;
mm_xu_cr0_eq_valid  <= mm_xu_cr0_eq_valid_sig;
mm_xu_quiesce       <= mm_xu_quiesce_sig;
mm_xu_local_snoop_reject     <=  mm_xu_local_snoop_reject_sig;
mm_xu_ex3_flush_req           <= mm_xu_ex3_flush_req_sig;
mm_xu_lsu_req              <= mm_xu_lsu_req_sig;
mm_xu_lsu_ttype            <= mm_xu_lsu_ttype_sig;
mm_xu_lsu_wimge            <= mm_xu_lsu_wimge_sig;
mm_xu_lsu_u                <= mm_xu_lsu_u_sig;
mm_xu_lsu_addr             <= mm_xu_lsu_addr_sig;
mm_xu_lsu_lpid             <= mm_xu_lsu_lpid_sig;
mm_xu_lsu_gs               <= mm_xu_lsu_gs_sig;
mm_xu_lsu_ind              <= mm_xu_lsu_ind_sig;
mm_xu_lsu_lbit             <= mm_xu_lsu_lbit_sig;
-------------------- glorp1: end of common stuff for both erat-only and tlb -------------
tlb_gen_logic: if expand_tlb_type > 0 generate
-----------------------------------------------------------------------
-- Start of TLB logic
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- TLB Request Queue Component Instantiation
-----------------------------------------------------------------------
mmq_tlb_req: entity work.mmq_tlb_req(mmq_tlb_req)
  generic map ( pid_width => pid_width,
                   pid_width_erat => pid_width_erat,
                   lpid_width => lpid_width,
                   req_epn_width => req_epn_width,
                   rs_data_width => rs_data_width,
                   expand_type => expand_type )
  port map(
     vdd               => vdd,
     gnd               => gnd,
     nclk              => nclk,
     tc_ccflush_dc             => tc_ac_ccflush_dc,
     tc_scan_dis_dc_b          => tc_ac_scan_dis_dc_b,
     tc_scan_diag_dc           => tc_ac_scan_diag_dc,
     tc_lbist_en_dc            => tc_ac_lbist_en_dc,

     lcb_d_mode_dc              => lcb_d_mode_dc,
     lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
     lcb_act_dis_dc             => lcb_act_dis_dc,
     lcb_mpw1_dc_b              => lcb_mpw1_dc_b,
     lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
     lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc,

     ac_func_scan_in            => func_scan_in_int(2),
     ac_func_scan_out           => func_scan_out_int(2),

     pc_sg_2                  => pc_sg_2(1),
     pc_func_sl_thold_2       => pc_func_sl_thold_2(1),
     pc_func_slp_sl_thold_2   => pc_func_slp_sl_thold_2(1),
     pid0                       => pid0_sig,
     pid1                       => pid1_sig,
     pid2                       => pid2_sig,
     pid3                       => pid3_sig,
     lpidr                      => lpidr_sig, 
     xu_mm_ccr2_notlb_b         => xu_mm_ccr2_notlb_b(3),
     mmucr2_act_override        => mmucr2_sig(0),
     iu_mm_ierat_req            => iu_mm_ierat_req, 
     iu_mm_ierat_epn            => iu_mm_ierat_epn, 
     iu_mm_ierat_thdid          => iu_mm_ierat_thdid, 
     iu_mm_ierat_state          => iu_mm_ierat_state, 
     iu_mm_ierat_tid            => iu_mm_ierat_tid, 
     iu_mm_ierat_flush          => iu_mm_ierat_flush, 

     xu_mm_derat_req            => xu_mm_derat_req, 
     xu_mm_derat_epn            => xu_mm_derat_epn, 
     xu_mm_derat_thdid          => xu_mm_derat_thdid, 
     xu_mm_derat_ttype          => xu_mm_derat_ttype, 
     xu_mm_derat_state          => xu_mm_derat_state, 
     xu_mm_derat_tid            => xu_mm_derat_tid,
     xu_mm_derat_lpid           => xu_mm_derat_lpid,

     ierat_req0_pid       => ierat_req0_pid_sig,    
     ierat_req0_as        => ierat_req0_as_sig,    
     ierat_req0_gs        => ierat_req0_gs_sig,    
     ierat_req0_epn       => ierat_req0_epn_sig,    
     ierat_req0_thdid       => ierat_req0_thdid_sig,    
     ierat_req0_valid       => ierat_req0_valid_sig,    
     ierat_req0_nonspec       => ierat_req0_nonspec_sig,    
     ierat_req1_pid       => ierat_req1_pid_sig,    
     ierat_req1_as        => ierat_req1_as_sig,    
     ierat_req1_gs        => ierat_req1_gs_sig,    
     ierat_req1_epn       => ierat_req1_epn_sig,    
     ierat_req1_thdid       => ierat_req1_thdid_sig,    
     ierat_req1_valid       => ierat_req1_valid_sig,    
     ierat_req1_nonspec       => ierat_req1_nonspec_sig,    
     ierat_req2_pid       => ierat_req2_pid_sig,    
     ierat_req2_as        => ierat_req2_as_sig,    
     ierat_req2_gs        => ierat_req2_gs_sig,    
     ierat_req2_epn       => ierat_req2_epn_sig,    
     ierat_req2_thdid       => ierat_req2_thdid_sig,    
     ierat_req2_valid       => ierat_req2_valid_sig,    
     ierat_req2_nonspec       => ierat_req2_nonspec_sig,    
     ierat_req3_pid       => ierat_req3_pid_sig,    
     ierat_req3_as        => ierat_req3_as_sig,    
     ierat_req3_gs        => ierat_req3_gs_sig,    
     ierat_req3_epn       => ierat_req3_epn_sig,    
     ierat_req3_thdid       => ierat_req3_thdid_sig,    
     ierat_req3_valid       => ierat_req3_valid_sig,    
     ierat_req3_nonspec       => ierat_req3_nonspec_sig,    
     ierat_iu4_pid       => ierat_iu4_pid_sig,  
     ierat_iu4_gs        => ierat_iu4_gs_sig,  
     ierat_iu4_as        => ierat_iu4_as_sig,  
     ierat_iu4_epn       => ierat_iu4_epn_sig,  
     ierat_iu4_thdid     => ierat_iu4_thdid_sig,  
     ierat_iu4_valid     => ierat_iu4_valid_sig,  

     derat_req0_lpid      => derat_req0_lpid_sig,    
     derat_req0_pid       => derat_req0_pid_sig,    
     derat_req0_as        => derat_req0_as_sig,    
     derat_req0_gs        => derat_req0_gs_sig,    
     derat_req0_epn       => derat_req0_epn_sig,    
     derat_req0_thdid       => derat_req0_thdid_sig,    
     derat_req0_valid       => derat_req0_valid_sig,    
     derat_req1_lpid      => derat_req1_lpid_sig,    
     derat_req1_pid       => derat_req1_pid_sig,    
     derat_req1_as        => derat_req1_as_sig,    
     derat_req1_gs        => derat_req1_gs_sig,    
     derat_req1_epn       => derat_req1_epn_sig,    
     derat_req1_thdid       => derat_req1_thdid_sig,    
     derat_req1_valid       => derat_req1_valid_sig,    
     derat_req2_lpid      => derat_req2_lpid_sig,    
     derat_req2_pid       => derat_req2_pid_sig,    
     derat_req2_as        => derat_req2_as_sig,    
     derat_req2_gs        => derat_req2_gs_sig,    
     derat_req2_epn       => derat_req2_epn_sig,    
     derat_req2_thdid       => derat_req2_thdid_sig,    
     derat_req2_valid       => derat_req2_valid_sig,    
     derat_req3_lpid      => derat_req3_lpid_sig,    
     derat_req3_pid       => derat_req3_pid_sig,    
     derat_req3_as        => derat_req3_as_sig,    
     derat_req3_gs        => derat_req3_gs_sig,    
     derat_req3_epn       => derat_req3_epn_sig,    
     derat_req3_thdid       => derat_req3_thdid_sig,    
     derat_req3_valid       => derat_req3_valid_sig,    
     derat_ex5_lpid      => derat_ex5_lpid_sig,  
     derat_ex5_pid       => derat_ex5_pid_sig,  
     derat_ex5_gs        => derat_ex5_gs_sig,  
     derat_ex5_as        => derat_ex5_as_sig,  
     derat_ex5_epn       => derat_ex5_epn_sig,  
     derat_ex5_thdid     => derat_ex5_thdid_sig,  
     derat_ex5_valid     => derat_ex5_valid_sig,  

     xu_ex3_flush               => xu_ex3_flush,
     xu_mm_ex4_flush            => xu_mm_ex4_flush,
     xu_mm_ex5_flush            => xu_mm_ex5_flush,
     xu_mm_ierat_flush          => xu_mm_ierat_flush,
     xu_mm_ierat_miss           => xu_mm_ierat_miss,

     mm_xu_eratmiss_done        => mm_xu_eratmiss_done_sig,
     mm_xu_tlb_miss             => mm_xu_tlb_miss_sig,

     tlb_cmp_ierat_dup_val  => tlb_cmp_ierat_dup_val_sig, 
     tlb_cmp_derat_dup_val  => tlb_cmp_derat_dup_val_sig, 

     tlb_seq_ierat_req          => tlb_seq_ierat_req,
     tlb_seq_derat_req          => tlb_seq_derat_req, 
     tlb_seq_ierat_done         => tlb_seq_ierat_done,
     tlb_seq_derat_done         => tlb_seq_derat_done,
     ierat_req_taken            => ierat_req_taken,
     derat_req_taken            => derat_req_taken,
     ierat_req_epn              => ierat_req_epn,
     ierat_req_pid              => ierat_req_pid, 
     ierat_req_state            => ierat_req_state, 
     ierat_req_thdid            => ierat_req_thdid, 
     ierat_req_dup              => ierat_req_dup, 
     derat_req_epn              => derat_req_epn, 
     derat_req_pid              => derat_req_pid, 
     derat_req_lpid             => derat_req_lpid, 
     derat_req_state            => derat_req_state, 
     derat_req_ttype            => derat_req_ttype, 
     derat_req_thdid            => derat_req_thdid, 
     derat_req_dup              => derat_req_dup, 

     tlb_req_quiesce            => tlb_req_quiesce_sig,

     tlb_req_dbg_ierat_iu5_valid_q    => tlb_req_dbg_ierat_iu5_valid_q,  
     tlb_req_dbg_ierat_iu5_thdid      => tlb_req_dbg_ierat_iu5_thdid,  
     tlb_req_dbg_ierat_iu5_state_q    => tlb_req_dbg_ierat_iu5_state_q,  
     tlb_req_dbg_ierat_inptr_q        => tlb_req_dbg_ierat_inptr_q,  
     tlb_req_dbg_ierat_outptr_q       => tlb_req_dbg_ierat_outptr_q,  
     tlb_req_dbg_ierat_req_valid_q    => tlb_req_dbg_ierat_req_valid_q,  
     tlb_req_dbg_ierat_req_nonspec_q  => tlb_req_dbg_ierat_req_nonspec_q,  
     tlb_req_dbg_ierat_req_thdid      => tlb_req_dbg_ierat_req_thdid,  
     tlb_req_dbg_ierat_req_dup_q      => tlb_req_dbg_ierat_req_dup_q,  
     tlb_req_dbg_derat_ex6_valid_q    => tlb_req_dbg_derat_ex6_valid_q,  
     tlb_req_dbg_derat_ex6_thdid      => tlb_req_dbg_derat_ex6_thdid,  
     tlb_req_dbg_derat_ex6_state_q    => tlb_req_dbg_derat_ex6_state_q,  
     tlb_req_dbg_derat_inptr_q        => tlb_req_dbg_derat_inptr_q,  
     tlb_req_dbg_derat_outptr_q       => tlb_req_dbg_derat_outptr_q,  
     tlb_req_dbg_derat_req_valid_q    => tlb_req_dbg_derat_req_valid_q,  
     tlb_req_dbg_derat_req_thdid      => tlb_req_dbg_derat_req_thdid,  
     tlb_req_dbg_derat_req_ttype_q    => tlb_req_dbg_derat_req_ttype_q,  
     tlb_req_dbg_derat_req_dup_q      => tlb_req_dbg_derat_req_dup_q  
);
-- End of mmq_tlb_req component instantiation
-----------------------------------------------------------------------
-- TLB Control Logic Component Instantiation
-----------------------------------------------------------------------
mmq_tlb_ctl: entity work.mmq_tlb_ctl(mmq_tlb_ctl)
  generic map (     epn_width => epn_width,
                       pid_width => pid_width,
                 real_addr_width => real_addr_width,
                   rs_data_width => rs_data_width,
                  data_out_width => data_out_width,
                   tlb_tag_width => tlb_tag_width,
                     expand_type => expand_type )
  port map(
     vdd               => vdd,
     gnd               => gnd,
     nclk              => nclk,
     tc_ccflush_dc             => tc_ac_ccflush_dc,
     tc_scan_dis_dc_b          => tc_ac_scan_dis_dc_b,
     tc_scan_diag_dc           => tc_ac_scan_diag_dc,
     tc_lbist_en_dc            => tc_ac_lbist_en_dc,

     lcb_d_mode_dc              => lcb_d_mode_dc,
     lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
     lcb_act_dis_dc             => lcb_act_dis_dc,
     lcb_mpw1_dc_b              => lcb_mpw1_dc_b,
     lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
     lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc,

     ac_func_scan_in            => func_scan_in_int(3),
     ac_func_scan_out           => func_scan_out_int(3),

     pc_sg_2                  => pc_sg_2(1),
     pc_func_sl_thold_2       => pc_func_sl_thold_2(1),
     pc_func_slp_sl_thold_2   => pc_func_slp_sl_thold_2(1),
     pc_func_slp_nsl_thold_2  => pc_func_slp_nsl_thold_2,
     pc_fce_2                 => pc_fce_2,
     xu_mm_rf1_val              => xu_mm_rf1_val,   
     xu_mm_rf1_is_tlbre         => xu_mm_rf1_is_tlbre,
     xu_mm_rf1_is_tlbwe         => xu_mm_rf1_is_tlbwe,
     xu_mm_rf1_is_tlbsx         => xu_mm_rf1_is_tlbsx,
     xu_mm_rf1_is_tlbsxr        => xu_mm_rf1_is_tlbsxr,
     xu_mm_rf1_is_tlbsrx        => xu_mm_rf1_is_tlbsrx,  
     xu_mm_ex2_epn              => xu_mm_ex2_eff_addr_sig(64-rs_data_width to 51),  

     xu_mm_msr_gs               => xu_mm_msr_gs,
     xu_mm_msr_pr               => xu_mm_msr_pr,
     xu_mm_msr_is               => xu_mm_msr_is,
     xu_mm_msr_ds               => xu_mm_msr_ds,
     xu_mm_msr_cm               => xu_mm_msr_cm,

     xu_mm_ccr2_notlb_b         => xu_mm_ccr2_notlb_b(4),
     xu_mm_epcr_dgtmi           => xu_mm_epcr_dgtmi_sig,
     xu_mm_xucr4_mmu_mchk       => xu_mm_xucr4_mmu_mchk,   
     xu_mm_xucr4_mmu_mchk_q     => xu_mm_xucr4_mmu_mchk_q,
     xu_rf1_flush               => xu_rf1_flush,
     xu_ex1_flush               => xu_ex1_flush,
     xu_ex2_flush               => xu_ex2_flush,
     xu_ex3_flush               => xu_ex3_flush,
     xu_ex4_flush               => xu_ex4_flush,
     xu_ex5_flush               => xu_ex5_flush,

     tlb_ctl_ex3_valid          => tlb_ctl_ex3_valid_sig,  
     tlb_ctl_ex3_ttype          => tlb_ctl_ex3_ttype_sig,  

     tlb_ctl_tag2_flush               => tlb_ctl_tag2_flush_sig,
     tlb_ctl_tag3_flush               => tlb_ctl_tag3_flush_sig,
     tlb_ctl_tag4_flush               => tlb_ctl_tag4_flush_sig,
     tlb_resv_match_vec               => tlb_resv_match_vec_sig,
     tlb_ctl_barrier_done       => tlb_ctl_barrier_done_sig,
     tlb_ctl_ex2_flush_req      => tlb_ctl_ex2_flush_req_sig,
     tlb_ctl_ex2_illeg_instr    => tlb_ctl_ex2_illeg_instr_sig,
     tlb_ctl_quiesce            => tlb_ctl_quiesce_sig,
     ex6_illeg_instr            => ex6_illeg_instr,

     mm_xu_eratmiss_done        => mm_xu_eratmiss_done_sig,
     mm_xu_tlb_miss             => mm_xu_tlb_miss_sig,
     mm_xu_tlb_inelig           => mm_xu_tlb_inelig_sig,

     tlbwe_back_inv_pending     => tlbwe_back_inv_pending_sig,  
     pid0                       => pid0_sig,
     pid1                       => pid1_sig,
     pid2                       => pid2_sig,
     pid3                       => pid3_sig,
     mmucr1_tlbi_msb            => mmucr1_sig(18),  
     mmucr1_tlbwe_binv          => mmucr1_sig(17),  
     mmucr2                     => mmucr2_sig, 
     mmucr3_0                   => mmucr3_0_sig, 
     mmucr3_1                   => mmucr3_1_sig, 
     mmucr3_2                   => mmucr3_2_sig, 
     mmucr3_3                   => mmucr3_3_sig, 
     lpidr                      => lpidr_sig, 
     mmucfg_lrat                => mmucfg_lrat,  
     mmucfg_twc                 => mmucfg_twc,  
     mmucsr0_tlb0fi             => mmucsr0_tlb0fi,  
     tlb0cfg_pt                 => tlb0cfg_pt,
     tlb0cfg_ind                => tlb0cfg_ind,
     tlb0cfg_gtwe               => tlb0cfg_gtwe,

     mas0_0_atsel            => mas0_0_atsel,    
     mas0_0_esel             => mas0_0_esel,    
     mas0_0_hes              => mas0_0_hes,    
     mas0_0_wq               => mas0_0_wq,    
     mas1_0_v                => mas1_0_v,    
     mas1_0_iprot            => mas1_0_iprot,    
     mas1_0_tid              => mas1_0_tid,    
     mas1_0_ind              => mas1_0_ind,    
     mas1_0_ts               => mas1_0_ts,    
     mas1_0_tsize            => mas1_0_tsize,    
     mas2_0_epn              => mas2_0_epn,    
     mas2_0_wimge            => mas2_0_wimge,    
     mas3_0_usxwr            => mas3_0_usxwr(0   to 3),  
     mas5_0_sgs              => mas5_0_sgs,    
     mas5_0_slpid            => mas5_0_slpid,    
     mas6_0_spid             => mas6_0_spid,    
     mas6_0_sind             => mas6_0_sind,    
     mas6_0_sas              => mas6_0_sas,    
     mas8_0_tgs              => mas8_0_tgs,    
     mas8_0_tlpid            => mas8_0_tlpid,    
     mas0_1_atsel            => mas0_1_atsel,    
     mas0_1_esel             => mas0_1_esel,    
     mas0_1_hes              => mas0_1_hes,    
     mas0_1_wq               => mas0_1_wq,    
     mas1_1_v                => mas1_1_v,    
     mas1_1_iprot            => mas1_1_iprot,    
     mas1_1_tid              => mas1_1_tid,    
     mas1_1_ind              => mas1_1_ind,    
     mas1_1_ts               => mas1_1_ts,    
     mas1_1_tsize            => mas1_1_tsize,    
     mas2_1_epn              => mas2_1_epn,    
     mas2_1_wimge            => mas2_1_wimge,    
     mas3_1_usxwr            => mas3_1_usxwr(0   to 3),  
     mas5_1_sgs              => mas5_1_sgs,    
     mas5_1_slpid            => mas5_1_slpid,    
     mas6_1_spid             => mas6_1_spid,    
     mas6_1_sind             => mas6_1_sind,    
     mas6_1_sas              => mas6_1_sas,    
     mas8_1_tgs              => mas8_1_tgs,    
     mas8_1_tlpid            => mas8_1_tlpid,    
     mas0_2_atsel            => mas0_2_atsel,    
     mas0_2_esel             => mas0_2_esel,    
     mas0_2_hes              => mas0_2_hes,    
     mas0_2_wq               => mas0_2_wq,    
     mas1_2_v                => mas1_2_v,    
     mas1_2_iprot            => mas1_2_iprot,    
     mas1_2_tid              => mas1_2_tid,    
     mas1_2_ind              => mas1_2_ind,    
     mas1_2_ts               => mas1_2_ts,    
     mas1_2_tsize            => mas1_2_tsize,    
     mas2_2_epn              => mas2_2_epn,    
     mas2_2_wimge            => mas2_2_wimge,    
     mas3_2_usxwr            => mas3_2_usxwr(0   to 3),  
     mas5_2_sgs              => mas5_2_sgs,    
     mas5_2_slpid            => mas5_2_slpid,    
     mas6_2_spid             => mas6_2_spid,    
     mas6_2_sind             => mas6_2_sind,    
     mas6_2_sas              => mas6_2_sas,    
     mas8_2_tgs              => mas8_2_tgs,    
     mas8_2_tlpid            => mas8_2_tlpid,    
     mas0_3_atsel            => mas0_3_atsel,    
     mas0_3_esel             => mas0_3_esel,    
     mas0_3_hes              => mas0_3_hes,    
     mas0_3_wq               => mas0_3_wq,    
     mas1_3_v                => mas1_3_v,    
     mas1_3_iprot            => mas1_3_iprot,    
     mas1_3_tid              => mas1_3_tid,    
     mas1_3_ind              => mas1_3_ind,    
     mas1_3_ts               => mas1_3_ts,    
     mas1_3_tsize            => mas1_3_tsize,    
     mas2_3_epn              => mas2_3_epn,    
     mas2_3_wimge            => mas2_3_wimge,    
     mas3_3_usxwr            => mas3_3_usxwr(0   to 3),  
     mas5_3_sgs              => mas5_3_sgs,    
     mas5_3_slpid            => mas5_3_slpid,    
     mas6_3_spid             => mas6_3_spid,    
     mas6_3_sind             => mas6_3_sind,    
     mas6_3_sas              => mas6_3_sas,    
     mas8_3_tgs              => mas8_3_tgs,    
     mas8_3_tlpid            => mas8_3_tlpid,    

     tlb_seq_ierat_req          => tlb_seq_ierat_req,
     tlb_seq_derat_req          => tlb_seq_derat_req, 
     tlb_seq_ierat_done         => tlb_seq_ierat_done,
     tlb_seq_derat_done         => tlb_seq_derat_done,
     tlb_seq_idle               => tlb_seq_idle,
     ierat_req_taken            => ierat_req_taken,
     derat_req_taken            => derat_req_taken,
     ierat_req_epn              => ierat_req_epn,
     ierat_req_pid              => ierat_req_pid, 
     ierat_req_state            => ierat_req_state, 
     ierat_req_thdid            => ierat_req_thdid, 
     ierat_req_dup              => ierat_req_dup, 
     derat_req_epn              => derat_req_epn, 
     derat_req_pid              => derat_req_pid, 
     derat_req_lpid             => derat_req_lpid, 
     derat_req_state            => derat_req_state, 
     derat_req_ttype            => derat_req_ttype, 
     derat_req_thdid            => derat_req_thdid,
     derat_req_dup              => derat_req_dup,
     ptereload_req_valid        => ptereload_req_valid,
     ptereload_req_tag          => ptereload_req_tag,
     ptereload_req_pte          => ptereload_req_pte,
     ptereload_req_taken        => ptereload_req_taken,

     tlb_snoop_coming           => tlb_snoop_coming,
     tlb_snoop_val              => tlb_snoop_val,
     tlb_snoop_attr             => tlb_snoop_attr,
     tlb_snoop_vpn              => tlb_snoop_vpn,
     tlb_snoop_ack              => tlb_snoop_ack,

     lru_rd_addr                 => lru_rd_addr,
     lru_tag4_dataout            => lru_tag4_dataout,
     tlb_tag4_esel               => tlb_tag4_esel,
     tlb_tag4_wq                 => tlb_tag4_wq,
     tlb_tag4_is                 => tlb_tag4_is,
     tlb_tag4_gs                 => tlb_tag4_gs,
     tlb_tag4_pr                 => tlb_tag4_pr,
     tlb_tag4_hes                => tlb_tag4_hes,
     tlb_tag4_atsel              => tlb_tag4_atsel,
     tlb_tag4_pt                 => tlb_tag4_pt,
     tlb_tag4_cmp_hit            => tlb_tag4_cmp_hit,
     tlb_tag4_way_ind            => tlb_tag4_way_ind,
     tlb_tag4_ptereload          => tlb_tag4_ptereload,
     tlb_tag4_endflag            => tlb_tag4_endflag,
     tlb_tag4_parerr             => tlb_tag4_parerr,
     tlb_tag5_except             => tlb_tag5_except,
     tlb_cmp_erat_dup_wait       => tlb_cmp_erat_dup_wait_sig, 

     tlb_tag0_epn         => tlb_tag0_epn,  
     tlb_tag0_thdid       => tlb_tag0_thdid,  
     tlb_tag0_type        => tlb_tag0_type,  
     tlb_tag0_lpid        => tlb_tag0_lpid,  
     tlb_tag0_atsel       => tlb_tag0_atsel,  
     tlb_tag0_size        => tlb_tag0_size,  
     tlb_tag0_addr_cap    => tlb_tag0_addr_cap,  

     tlb_tag2                   => tlb_tag2_sig,
     tlb_addr2                  => tlb_addr2_sig,

     tlb_ctl_perf_tlbwec_resv       => tlb_ctl_perf_tlbwec_resv,  
     tlb_ctl_perf_tlbwec_noresv     => tlb_ctl_perf_tlbwec_noresv,  

     lrat_tag4_hit_status       => lrat_tag4_hit_status,  

     tlb_lper_lpn           => tlb_lper_lpn, 
     tlb_lper_lps           => tlb_lper_lps, 
     tlb_lper_we            => tlb_lper_we, 

     ptereload_req_pte_lat  => ptereload_req_pte_lat,
     pte_tag0_lpn         => pte_tag0_lpn(64-real_addr_width to 51),  
     pte_tag0_lpid        => pte_tag0_lpid,  

     tlb_write               => tlb_write,
     tlb_addr                => tlb_addr,
     tlb_tag5_write          => tlb_tag5_write,          
     tlb_delayed_act         => tlb_delayed_act,    

     tlb_ctl_dbg_seq_q                => tlb_ctl_dbg_seq_q,  
     tlb_ctl_dbg_seq_idle             => tlb_ctl_dbg_seq_idle,  
     tlb_ctl_dbg_seq_any_done_sig     => tlb_ctl_dbg_seq_any_done_sig,  
     tlb_ctl_dbg_seq_abort            => tlb_ctl_dbg_seq_abort,  
     tlb_ctl_dbg_any_tlb_req_sig      => tlb_ctl_dbg_any_tlb_req_sig,  
     tlb_ctl_dbg_any_req_taken_sig    => tlb_ctl_dbg_any_req_taken_sig,  
     tlb_ctl_dbg_tag0_valid          => tlb_ctl_dbg_tag0_valid,  
     tlb_ctl_dbg_tag0_thdid          => tlb_ctl_dbg_tag0_thdid,  
     tlb_ctl_dbg_tag0_type           => tlb_ctl_dbg_tag0_type,  
     tlb_ctl_dbg_tag0_wq             => tlb_ctl_dbg_tag0_wq,  
     tlb_ctl_dbg_tag0_gs             => tlb_ctl_dbg_tag0_gs,  
     tlb_ctl_dbg_tag0_pr             => tlb_ctl_dbg_tag0_pr,  
     tlb_ctl_dbg_tag0_atsel          => tlb_ctl_dbg_tag0_atsel,  
     tlb_ctl_dbg_tag5_tlb_write_q    => tlb_ctl_dbg_tag5_tlb_write_q,  
     tlb_ctl_dbg_resv_valid          => tlb_ctl_dbg_resv_valid,  
     tlb_ctl_dbg_set_resv            => tlb_ctl_dbg_set_resv,  
     tlb_ctl_dbg_resv_match_vec_q    => tlb_ctl_dbg_resv_match_vec_q,  
     tlb_ctl_dbg_any_tag_flush_sig   => tlb_ctl_dbg_any_tag_flush_sig,  
     tlb_ctl_dbg_resv0_tag0_lpid_match         => tlb_ctl_dbg_resv0_tag0_lpid_match,  
     tlb_ctl_dbg_resv0_tag0_pid_match          => tlb_ctl_dbg_resv0_tag0_pid_match,  
     tlb_ctl_dbg_resv0_tag0_as_snoop_match     => tlb_ctl_dbg_resv0_tag0_as_snoop_match,  
     tlb_ctl_dbg_resv0_tag0_gs_snoop_match     => tlb_ctl_dbg_resv0_tag0_gs_snoop_match,  
     tlb_ctl_dbg_resv0_tag0_as_tlbwe_match     => tlb_ctl_dbg_resv0_tag0_as_tlbwe_match,  
     tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match     => tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match,  
     tlb_ctl_dbg_resv0_tag0_ind_match          => tlb_ctl_dbg_resv0_tag0_ind_match,  
     tlb_ctl_dbg_resv0_tag0_epn_loc_match      => tlb_ctl_dbg_resv0_tag0_epn_loc_match,  
     tlb_ctl_dbg_resv0_tag0_epn_glob_match     => tlb_ctl_dbg_resv0_tag0_epn_glob_match,  
     tlb_ctl_dbg_resv0_tag0_class_match        => tlb_ctl_dbg_resv0_tag0_class_match,  
     tlb_ctl_dbg_resv1_tag0_lpid_match         => tlb_ctl_dbg_resv1_tag0_lpid_match,  
     tlb_ctl_dbg_resv1_tag0_pid_match          => tlb_ctl_dbg_resv1_tag0_pid_match,  
     tlb_ctl_dbg_resv1_tag0_as_snoop_match     => tlb_ctl_dbg_resv1_tag0_as_snoop_match,  
     tlb_ctl_dbg_resv1_tag0_gs_snoop_match     => tlb_ctl_dbg_resv1_tag0_gs_snoop_match,  
     tlb_ctl_dbg_resv1_tag0_as_tlbwe_match     => tlb_ctl_dbg_resv1_tag0_as_tlbwe_match,  
     tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match     => tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match,  
     tlb_ctl_dbg_resv1_tag0_ind_match          => tlb_ctl_dbg_resv1_tag0_ind_match,  
     tlb_ctl_dbg_resv1_tag0_epn_loc_match      => tlb_ctl_dbg_resv1_tag0_epn_loc_match,  
     tlb_ctl_dbg_resv1_tag0_epn_glob_match     => tlb_ctl_dbg_resv1_tag0_epn_glob_match,  
     tlb_ctl_dbg_resv1_tag0_class_match        => tlb_ctl_dbg_resv1_tag0_class_match ,  
     tlb_ctl_dbg_resv2_tag0_lpid_match         => tlb_ctl_dbg_resv2_tag0_lpid_match,  
     tlb_ctl_dbg_resv2_tag0_pid_match          => tlb_ctl_dbg_resv2_tag0_pid_match,  
     tlb_ctl_dbg_resv2_tag0_as_snoop_match     => tlb_ctl_dbg_resv2_tag0_as_snoop_match,  
     tlb_ctl_dbg_resv2_tag0_gs_snoop_match     => tlb_ctl_dbg_resv2_tag0_gs_snoop_match,  
     tlb_ctl_dbg_resv2_tag0_as_tlbwe_match     => tlb_ctl_dbg_resv2_tag0_as_tlbwe_match,  
     tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match     => tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match,  
     tlb_ctl_dbg_resv2_tag0_ind_match          => tlb_ctl_dbg_resv2_tag0_ind_match,  
     tlb_ctl_dbg_resv2_tag0_epn_loc_match      => tlb_ctl_dbg_resv2_tag0_epn_loc_match,  
     tlb_ctl_dbg_resv2_tag0_epn_glob_match     => tlb_ctl_dbg_resv2_tag0_epn_glob_match,  
     tlb_ctl_dbg_resv2_tag0_class_match        => tlb_ctl_dbg_resv2_tag0_class_match,  
     tlb_ctl_dbg_resv3_tag0_lpid_match         => tlb_ctl_dbg_resv3_tag0_lpid_match,  
     tlb_ctl_dbg_resv3_tag0_pid_match          => tlb_ctl_dbg_resv3_tag0_pid_match,  
     tlb_ctl_dbg_resv3_tag0_as_snoop_match     => tlb_ctl_dbg_resv3_tag0_as_snoop_match,  
     tlb_ctl_dbg_resv3_tag0_gs_snoop_match     => tlb_ctl_dbg_resv3_tag0_gs_snoop_match,  
     tlb_ctl_dbg_resv3_tag0_as_tlbwe_match     => tlb_ctl_dbg_resv3_tag0_as_tlbwe_match,  
     tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match     => tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match,  
     tlb_ctl_dbg_resv3_tag0_ind_match          => tlb_ctl_dbg_resv3_tag0_ind_match,  
     tlb_ctl_dbg_resv3_tag0_epn_loc_match      => tlb_ctl_dbg_resv3_tag0_epn_loc_match,  
     tlb_ctl_dbg_resv3_tag0_epn_glob_match     => tlb_ctl_dbg_resv3_tag0_epn_glob_match,  
     tlb_ctl_dbg_resv3_tag0_class_match        => tlb_ctl_dbg_resv3_tag0_class_match,  
     tlb_ctl_dbg_clr_resv_q                    => tlb_ctl_dbg_clr_resv_q,  
     tlb_ctl_dbg_clr_resv_terms                => tlb_ctl_dbg_clr_resv_terms  
);
-- End of mmq_tlb_ctl component instantiation
-----------------------------------------------------------------------
-- TLB Compare Logic Component Instantiation
-----------------------------------------------------------------------
mmq_tlb_cmp: entity work.mmq_tlb_cmp(mmq_tlb_cmp)
  generic map (     epn_width => epn_width,
                       pid_width => pid_width,
                  pid_width_erat => pid_width_erat,
                   tlb_tag_width => tlb_tag_width,
       mmq_tlb_cmp_cswitch_0to7  => mmq_tlb_cmp_cswitch_0to7,
                      expand_type => expand_type )
  port map(
     vdd               => vdd,
     gnd               => gnd,
     nclk              => nclk,
     tc_ccflush_dc             => tc_ac_ccflush_dc,
     tc_scan_dis_dc_b          => tc_ac_scan_dis_dc_b,
     tc_scan_diag_dc           => tc_ac_scan_diag_dc,
     tc_lbist_en_dc            => tc_ac_lbist_en_dc,

     lcb_d_mode_dc              => lcb_d_mode_dc,
     lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
     lcb_act_dis_dc             => lcb_act_dis_dc,
     lcb_mpw1_dc_b              => lcb_mpw1_dc_b,
     lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
     lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc,

     ac_func_scan_in(0)            => func_scan_in_int(4),
     ac_func_scan_in(1)            => func_scan_in_int(5),
     ac_func_scan_in(2)            => siv_1(tlb_cmp2_offset),
     ac_func_scan_out(0)           => func_scan_out_int(4),
     ac_func_scan_out(1)           => func_scan_out_int(5),
     ac_func_scan_out(2)           => sov_1(tlb_cmp2_offset),

     pc_sg_2                  => pc_sg_2(1),
     pc_func_sl_thold_2       => pc_func_sl_thold_2(1),
     pc_func_slp_sl_thold_2   => pc_func_slp_sl_thold_2(1),
     pc_func_slp_nsl_thold_2  => pc_func_slp_nsl_thold_2,
     pc_fce_2                 => pc_fce_2,
     xu_mm_ccr2_notlb_b       => xu_mm_ccr2_notlb_b(5),
     xu_mm_spr_epcr_dmiuh     => xu_mm_spr_epcr_dmiuh,
     xu_mm_epcr_dgtmi         => xu_mm_epcr_dgtmi_sig,
     xu_mm_msr_gs             => xu_mm_msr_gs,
     xu_mm_msr_pr             => xu_mm_msr_pr,
     xu_mm_xucr4_mmu_mchk_q   => xu_mm_xucr4_mmu_mchk_q,
     lpidr                    => lpidr_sig,
     mmucr1                   => mmucr1_sig(10 to 18), 
     mmucr3_0                 => mmucr3_0_sig,          
     mmucr3_1                 => mmucr3_1_sig,          
     mmucr3_2                 => mmucr3_2_sig,          
     mmucr3_3                 => mmucr3_3_sig,          
     mm_iu_ierat_rel_val        => mm_iu_ierat_rel_val_sig,
     mm_iu_ierat_rel_data       => mm_iu_ierat_rel_data_sig,

     mm_xu_derat_rel_val        => mm_xu_derat_rel_val_sig,
     mm_xu_derat_rel_data       => mm_xu_derat_rel_data_sig,
     tlb_cmp_ierat_dup_val  => tlb_cmp_ierat_dup_val_sig,  
     tlb_cmp_derat_dup_val  => tlb_cmp_derat_dup_val_sig,  
     tlb_cmp_erat_dup_wait => tlb_cmp_erat_dup_wait_sig, 
     ierat_req0_pid       => ierat_req0_pid_sig,    
     ierat_req0_as        => ierat_req0_as_sig,    
     ierat_req0_gs        => ierat_req0_gs_sig,    
     ierat_req0_epn       => ierat_req0_epn_sig,    
     ierat_req0_thdid       => ierat_req0_thdid_sig,    
     ierat_req0_valid       => ierat_req0_valid_sig,    
     ierat_req0_nonspec       => ierat_req0_nonspec_sig,    
     ierat_req1_pid       => ierat_req1_pid_sig,    
     ierat_req1_as        => ierat_req1_as_sig,    
     ierat_req1_gs        => ierat_req1_gs_sig,    
     ierat_req1_epn       => ierat_req1_epn_sig,    
     ierat_req1_thdid       => ierat_req1_thdid_sig,    
     ierat_req1_valid       => ierat_req1_valid_sig,    
     ierat_req1_nonspec       => ierat_req1_nonspec_sig,    
     ierat_req2_pid       => ierat_req2_pid_sig,    
     ierat_req2_as        => ierat_req2_as_sig,    
     ierat_req2_gs        => ierat_req2_gs_sig,    
     ierat_req2_epn       => ierat_req2_epn_sig,    
     ierat_req2_thdid       => ierat_req2_thdid_sig,    
     ierat_req2_valid       => ierat_req2_valid_sig,    
     ierat_req2_nonspec       => ierat_req2_nonspec_sig,    
     ierat_req3_pid       => ierat_req3_pid_sig,    
     ierat_req3_as        => ierat_req3_as_sig,    
     ierat_req3_gs        => ierat_req3_gs_sig,    
     ierat_req3_epn       => ierat_req3_epn_sig,    
     ierat_req3_thdid       => ierat_req3_thdid_sig,    
     ierat_req3_valid       => ierat_req3_valid_sig,    
     ierat_req3_nonspec       => ierat_req3_nonspec_sig,    
     ierat_iu4_pid       => ierat_iu4_pid_sig,  
     ierat_iu4_gs        => ierat_iu4_gs_sig,  
     ierat_iu4_as        => ierat_iu4_as_sig,  
     ierat_iu4_epn       => ierat_iu4_epn_sig,  
     ierat_iu4_thdid     => ierat_iu4_thdid_sig,  
     ierat_iu4_valid     => ierat_iu4_valid_sig,  

     derat_req0_lpid      => derat_req0_lpid_sig,    
     derat_req0_pid       => derat_req0_pid_sig,    
     derat_req0_as        => derat_req0_as_sig,    
     derat_req0_gs        => derat_req0_gs_sig,    
     derat_req0_epn       => derat_req0_epn_sig,    
     derat_req0_thdid       => derat_req0_thdid_sig,    
     derat_req0_valid       => derat_req0_valid_sig,    
     derat_req1_lpid      => derat_req1_lpid_sig,    
     derat_req1_pid       => derat_req1_pid_sig,    
     derat_req1_as        => derat_req1_as_sig,    
     derat_req1_gs        => derat_req1_gs_sig,    
     derat_req1_epn       => derat_req1_epn_sig,    
     derat_req1_thdid       => derat_req1_thdid_sig,    
     derat_req1_valid       => derat_req1_valid_sig,    
     derat_req2_lpid      => derat_req2_lpid_sig,    
     derat_req2_pid       => derat_req2_pid_sig,    
     derat_req2_as        => derat_req2_as_sig,    
     derat_req2_gs        => derat_req2_gs_sig,    
     derat_req2_epn       => derat_req2_epn_sig,    
     derat_req2_thdid       => derat_req2_thdid_sig,    
     derat_req2_valid       => derat_req2_valid_sig,    
     derat_req3_lpid      => derat_req3_lpid_sig,    
     derat_req3_pid       => derat_req3_pid_sig,    
     derat_req3_as        => derat_req3_as_sig,    
     derat_req3_gs        => derat_req3_gs_sig,    
     derat_req3_epn       => derat_req3_epn_sig,    
     derat_req3_thdid       => derat_req3_thdid_sig,    
     derat_req3_valid       => derat_req3_valid_sig,    
     derat_ex5_lpid      => derat_ex5_lpid_sig,  
     derat_ex5_pid       => derat_ex5_pid_sig,  
     derat_ex5_gs        => derat_ex5_gs_sig,  
     derat_ex5_as        => derat_ex5_as_sig,  
     derat_ex5_epn       => derat_ex5_epn_sig,  
     derat_ex5_thdid     => derat_ex5_thdid_sig,  
     derat_ex5_valid     => derat_ex5_valid_sig,  

     tlb_tag2                   => tlb_tag2_sig,
     tlb_addr2                  => tlb_addr2_sig,
     ex6_illeg_instr            => ex6_illeg_instr,

     ierat_req_taken            => ierat_req_taken,
     derat_req_taken            => derat_req_taken,
     ptereload_req_taken        => ptereload_req_taken,
     tlb_tag0_type              => tlb_tag0_type(0 to 1),     

     lru_dataout             => lru_dataout(0 to 15),
     tlb_dataout             => tlb_dataout,
     tlb_dataina                => tlb_dataina,
     tlb_datainb                => tlb_datainb,
     lru_write                  => lru_write(0 to 15),
     lru_wr_addr                => lru_wr_addr,
     lru_datain                 => lru_datain(0 to 15),
     lru_tag4_dataout            => lru_tag4_dataout,
     tlb_tag4_esel               => tlb_tag4_esel,
     tlb_tag4_wq                 => tlb_tag4_wq,
     tlb_tag4_is                 => tlb_tag4_is,
     tlb_tag4_gs                 => tlb_tag4_gs,
     tlb_tag4_pr                 => tlb_tag4_pr,
     tlb_tag4_hes                => tlb_tag4_hes,
     tlb_tag4_atsel              => tlb_tag4_atsel,
     tlb_tag4_pt                 => tlb_tag4_pt,
     tlb_tag4_cmp_hit            => tlb_tag4_cmp_hit,
     tlb_tag4_way_ind            => tlb_tag4_way_ind,
     tlb_tag4_ptereload          => tlb_tag4_ptereload,
     tlb_tag4_endflag            => tlb_tag4_endflag,
     tlb_tag4_parerr             => tlb_tag4_parerr,
     tlb_tag5_except             => tlb_tag5_except,

     mmucfg_twc                 => mmucfg_twc,  
     mmucfg_lrat                => mmucfg_lrat,  
     tlb0cfg_pt                 => tlb0cfg_pt,
     tlb0cfg_gtwe               => tlb0cfg_gtwe,
     tlb0cfg_ind                => tlb0cfg_ind,

     mas2_0_wimge            =>  mas2_0_wimge,      
     mas3_0_rpnl             =>  mas3_0_rpnl,      
     mas3_0_ubits            =>  mas3_0_ubits,      
     mas3_0_usxwr            =>  mas3_0_usxwr,      
     mas7_0_rpnu             =>  mas7_0_rpnu,      
     mas8_0_vf               =>  mas8_0_vf,      
     mas2_1_wimge            =>  mas2_1_wimge,      
     mas3_1_rpnl             =>  mas3_1_rpnl,      
     mas3_1_ubits            =>  mas3_1_ubits,      
     mas3_1_usxwr            =>  mas3_1_usxwr,      
     mas7_1_rpnu             =>  mas7_1_rpnu,      
     mas8_1_vf               =>  mas8_1_vf,      
     mas2_2_wimge            =>  mas2_2_wimge,      
     mas3_2_rpnl             =>  mas3_2_rpnl,      
     mas3_2_ubits            =>  mas3_2_ubits,      
     mas3_2_usxwr            =>  mas3_2_usxwr,      
     mas7_2_rpnu             =>  mas7_2_rpnu,      
     mas8_2_vf               =>  mas8_2_vf,      
     mas2_3_wimge            =>  mas2_3_wimge,      
     mas3_3_rpnl             =>  mas3_3_rpnl,      
     mas3_3_ubits            =>  mas3_3_ubits,      
     mas3_3_usxwr            =>  mas3_3_usxwr,      
     mas7_3_rpnu             =>  mas7_3_rpnu,      
     mas8_3_vf               =>  mas8_3_vf,      

     tlb_mas0_esel          => tlb_mas0_esel,  
     tlb_mas1_v             => tlb_mas1_v,  
     tlb_mas1_iprot         => tlb_mas1_iprot,  
     tlb_mas1_tid           => tlb_mas1_tid,  
     tlb_mas1_tid_error     => tlb_mas1_tid_error,  
     tlb_mas1_ind           => tlb_mas1_ind,  
     tlb_mas1_ts            => tlb_mas1_ts,  
     tlb_mas1_ts_error      => tlb_mas1_ts_error,  
     tlb_mas1_tsize         => tlb_mas1_tsize,  
     tlb_mas2_epn           => tlb_mas2_epn,  
     tlb_mas2_epn_error     => tlb_mas2_epn_error,  
     tlb_mas2_wimge         => tlb_mas2_wimge,  
     tlb_mas3_rpnl          => tlb_mas3_rpnl,  
     tlb_mas3_ubits         => tlb_mas3_ubits,  
     tlb_mas3_usxwr         => tlb_mas3_usxwr,  
     tlb_mas6_spid          => tlb_mas6_spid,  
     tlb_mas6_isize         => tlb_mas6_isize,  
     tlb_mas6_sind          => tlb_mas6_sind,  
     tlb_mas6_sas           => tlb_mas6_sas,  
     tlb_mas7_rpnu          => tlb_mas7_rpnu,  
     tlb_mas8_tgs           => tlb_mas8_tgs,  
     tlb_mas8_vf            => tlb_mas8_vf,  
     tlb_mas8_tlpid         => tlb_mas8_tlpid,  

     tlb_mmucr1_een         => tlb_mmucr1_een, 
     tlb_mmucr1_we          => tlb_mmucr1_we, 
     tlb_mmucr3_thdid       => tlb_mmucr3_thdid, 
     tlb_mmucr3_resvattr    => tlb_mmucr3_resvattr, 
     tlb_mmucr3_wlc         => tlb_mmucr3_wlc, 
     tlb_mmucr3_class       => tlb_mmucr3_class, 
     tlb_mmucr3_extclass    => tlb_mmucr3_extclass, 
     tlb_mmucr3_rc          => tlb_mmucr3_rc, 
     tlb_mmucr3_x           => tlb_mmucr3_x, 
     tlb_mas_tlbre          => tlb_mas_tlbre,  
     tlb_mas_tlbsx_hit      => tlb_mas_tlbsx_hit,  
     tlb_mas_tlbsx_miss     => tlb_mas_tlbsx_miss,  
     tlb_mas_dtlb_error     => tlb_mas_dtlb_error,  
     tlb_mas_itlb_error     => tlb_mas_itlb_error,  
     tlb_mas_thdid          => tlb_mas_thdid,  
     lrat_tag3_lpn              => lrat_tag3_lpn,  
     lrat_tag3_rpn              => lrat_tag3_rpn,  
     lrat_tag3_hit_status       => lrat_tag3_hit_status,  
     lrat_tag3_hit_entry        => lrat_tag3_hit_entry,  
     lrat_tag4_lpn              => lrat_tag4_lpn,  
     lrat_tag4_rpn              => lrat_tag4_rpn,  
     lrat_tag4_hit_status       => lrat_tag4_hit_status,  
     lrat_tag4_hit_entry        => lrat_tag4_hit_entry,  

     tlb_htw_req_valid        => tlb_htw_req_valid,  
     tlb_htw_req_tag          => tlb_htw_req_tag,    
     tlb_htw_req_way          => tlb_htw_req_way,    

     tlbwe_back_inv_valid     => tlbwe_back_inv_valid_sig,  
     tlbwe_back_inv_thdid     => tlbwe_back_inv_thdid_sig,  
     tlbwe_back_inv_addr      => tlbwe_back_inv_addr_sig,  
     tlbwe_back_inv_attr      => tlbwe_back_inv_attr_sig,  

     ptereload_req_pte_lat        => ptereload_req_pte_lat,

     tlb_ctl_tag2_flush               => tlb_ctl_tag2_flush_sig,
     tlb_ctl_tag3_flush               => tlb_ctl_tag3_flush_sig,
     tlb_ctl_tag4_flush               => tlb_ctl_tag4_flush_sig,
     tlb_resv_match_vec               => tlb_resv_match_vec_sig,

     mm_xu_eratmiss_done        => mm_xu_eratmiss_done_sig,
     mm_xu_tlb_miss             => mm_xu_tlb_miss_sig,
     mm_xu_tlb_inelig           => mm_xu_tlb_inelig_sig,

     mm_xu_lrat_miss            => mm_xu_lrat_miss_sig,
     mm_xu_pt_fault             => mm_xu_pt_fault_sig,
     mm_xu_hv_priv              => mm_xu_hv_priv_sig,

     mm_xu_esr_pt               => mm_xu_esr_pt_sig,
     mm_xu_esr_data             => mm_xu_esr_data_sig,
     mm_xu_esr_epid             => mm_xu_esr_epid_sig,
     mm_xu_esr_st               => mm_xu_esr_st_sig,

     mm_xu_cr0_eq               => mm_xu_cr0_eq_sig,
     mm_xu_cr0_eq_valid         => mm_xu_cr0_eq_valid_sig,

     mm_xu_tlb_multihit_err     => mm_xu_tlb_multihit_err,
     mm_xu_tlb_par_err          => mm_xu_tlb_par_err,
     mm_xu_lru_par_err          => mm_xu_lru_par_err,

     tlb_delayed_act         => tlb_delayed_act(9 to 16),    

     tlb_cmp_perf_event_t0    =>  tlb_cmp_perf_event_t0,       
     tlb_cmp_perf_event_t1    =>  tlb_cmp_perf_event_t1,           
     tlb_cmp_perf_event_t2    =>  tlb_cmp_perf_event_t2,           
     tlb_cmp_perf_event_t3    =>  tlb_cmp_perf_event_t3,           
     tlb_cmp_perf_state       =>  tlb_cmp_perf_state,           

     tlb_cmp_perf_miss_direct       => tlb_cmp_perf_miss_direct, 
     tlb_cmp_perf_hit_indirect      => tlb_cmp_perf_hit_indirect,  
     tlb_cmp_perf_hit_first_page    => tlb_cmp_perf_hit_first_page, 
     tlb_cmp_perf_ptereload_noexcep => tlb_cmp_perf_ptereload_noexcep,  
     tlb_cmp_perf_lrat_request      => tlb_cmp_perf_lrat_request,   
     tlb_cmp_perf_lrat_miss         => tlb_cmp_perf_lrat_miss,  
     tlb_cmp_perf_pt_fault          => tlb_cmp_perf_pt_fault,  
     tlb_cmp_perf_pt_inelig         => tlb_cmp_perf_pt_inelig,  

     tlb_cmp_dbg_tag4                   => tlb_cmp_dbg_tag4,  
     tlb_cmp_dbg_tag4_wayhit            => tlb_cmp_dbg_tag4_wayhit,  
     tlb_cmp_dbg_addr4                  => tlb_cmp_dbg_addr4,  
     tlb_cmp_dbg_tag4_way               => tlb_cmp_dbg_tag4_way,  
     tlb_cmp_dbg_tag4_parerr            => tlb_cmp_dbg_tag4_parerr,  
     tlb_cmp_dbg_tag4_lru_dataout_q     => tlb_cmp_dbg_tag4_lru_dataout_q,  
     tlb_cmp_dbg_tag5_tlb_datain_q      => tlb_cmp_dbg_tag5_tlb_datain_q,  
     tlb_cmp_dbg_tag5_lru_datain_q      => tlb_cmp_dbg_tag5_lru_datain_q,  
     tlb_cmp_dbg_tag5_lru_write         => tlb_cmp_dbg_tag5_lru_write,  
     tlb_cmp_dbg_tag5_any_exception     => tlb_cmp_dbg_tag5_any_exception,  
     tlb_cmp_dbg_tag5_except_type_q     => tlb_cmp_dbg_tag5_except_type_q,  
     tlb_cmp_dbg_tag5_except_thdid_q    => tlb_cmp_dbg_tag5_except_thdid_q,  
     tlb_cmp_dbg_tag5_erat_rel_val      => tlb_cmp_dbg_tag5_erat_rel_val,  
     tlb_cmp_dbg_tag5_erat_rel_data     => tlb_cmp_dbg_tag5_erat_rel_data,  
     tlb_cmp_dbg_erat_dup_q             => tlb_cmp_dbg_erat_dup_q,  
     tlb_cmp_dbg_addr_enable            => tlb_cmp_dbg_addr_enable,  
     tlb_cmp_dbg_pgsize_enable          => tlb_cmp_dbg_pgsize_enable,  
     tlb_cmp_dbg_class_enable           => tlb_cmp_dbg_class_enable,  
     tlb_cmp_dbg_extclass_enable        => tlb_cmp_dbg_extclass_enable,  
     tlb_cmp_dbg_state_enable           => tlb_cmp_dbg_state_enable,  
     tlb_cmp_dbg_thdid_enable           => tlb_cmp_dbg_thdid_enable,  
     tlb_cmp_dbg_pid_enable             => tlb_cmp_dbg_pid_enable,  
     tlb_cmp_dbg_lpid_enable            => tlb_cmp_dbg_lpid_enable,  
     tlb_cmp_dbg_ind_enable             => tlb_cmp_dbg_ind_enable,  
     tlb_cmp_dbg_iprot_enable           => tlb_cmp_dbg_iprot_enable,  
     tlb_cmp_dbg_way0_entry_v                        => tlb_cmp_dbg_way0_entry_v,  
     tlb_cmp_dbg_way0_addr_match                     => tlb_cmp_dbg_way0_addr_match,  
     tlb_cmp_dbg_way0_pgsize_match                   => tlb_cmp_dbg_way0_pgsize_match,  
     tlb_cmp_dbg_way0_class_match                    => tlb_cmp_dbg_way0_class_match,  
     tlb_cmp_dbg_way0_extclass_match                 => tlb_cmp_dbg_way0_extclass_match,  
     tlb_cmp_dbg_way0_state_match                    => tlb_cmp_dbg_way0_state_match,  
     tlb_cmp_dbg_way0_thdid_match                    => tlb_cmp_dbg_way0_thdid_match,  
     tlb_cmp_dbg_way0_pid_match                      => tlb_cmp_dbg_way0_pid_match,  
     tlb_cmp_dbg_way0_lpid_match                     => tlb_cmp_dbg_way0_lpid_match,  
     tlb_cmp_dbg_way0_ind_match                      => tlb_cmp_dbg_way0_ind_match,  
     tlb_cmp_dbg_way0_iprot_match                    => tlb_cmp_dbg_way0_iprot_match,  
     tlb_cmp_dbg_way1_entry_v                        => tlb_cmp_dbg_way1_entry_v,  
     tlb_cmp_dbg_way1_addr_match                     => tlb_cmp_dbg_way1_addr_match,  
     tlb_cmp_dbg_way1_pgsize_match                   => tlb_cmp_dbg_way1_pgsize_match,  
     tlb_cmp_dbg_way1_class_match                    => tlb_cmp_dbg_way1_class_match,  
     tlb_cmp_dbg_way1_extclass_match                 => tlb_cmp_dbg_way1_extclass_match,  
     tlb_cmp_dbg_way1_state_match                    => tlb_cmp_dbg_way1_state_match,  
     tlb_cmp_dbg_way1_thdid_match                    => tlb_cmp_dbg_way1_thdid_match,  
     tlb_cmp_dbg_way1_pid_match                      => tlb_cmp_dbg_way1_pid_match,  
     tlb_cmp_dbg_way1_lpid_match                     => tlb_cmp_dbg_way1_lpid_match,  
     tlb_cmp_dbg_way1_ind_match                      => tlb_cmp_dbg_way1_ind_match,  
     tlb_cmp_dbg_way1_iprot_match                    => tlb_cmp_dbg_way1_iprot_match,  
     tlb_cmp_dbg_way2_entry_v                        => tlb_cmp_dbg_way2_entry_v,  
     tlb_cmp_dbg_way2_addr_match                     => tlb_cmp_dbg_way2_addr_match,  
     tlb_cmp_dbg_way2_pgsize_match                   => tlb_cmp_dbg_way2_pgsize_match,  
     tlb_cmp_dbg_way2_class_match                    => tlb_cmp_dbg_way2_class_match,  
     tlb_cmp_dbg_way2_extclass_match                 => tlb_cmp_dbg_way2_extclass_match,  
     tlb_cmp_dbg_way2_state_match                    => tlb_cmp_dbg_way2_state_match,  
     tlb_cmp_dbg_way2_thdid_match                    => tlb_cmp_dbg_way2_thdid_match,  
     tlb_cmp_dbg_way2_pid_match                      => tlb_cmp_dbg_way2_pid_match,  
     tlb_cmp_dbg_way2_lpid_match                     => tlb_cmp_dbg_way2_lpid_match,  
     tlb_cmp_dbg_way2_ind_match                      => tlb_cmp_dbg_way2_ind_match,  
     tlb_cmp_dbg_way2_iprot_match                    => tlb_cmp_dbg_way2_iprot_match,  
     tlb_cmp_dbg_way3_entry_v                        => tlb_cmp_dbg_way3_entry_v,  
     tlb_cmp_dbg_way3_addr_match                     => tlb_cmp_dbg_way3_addr_match,  
     tlb_cmp_dbg_way3_pgsize_match                   => tlb_cmp_dbg_way3_pgsize_match,  
     tlb_cmp_dbg_way3_class_match                    => tlb_cmp_dbg_way3_class_match,  
     tlb_cmp_dbg_way3_extclass_match                 => tlb_cmp_dbg_way3_extclass_match,  
     tlb_cmp_dbg_way3_state_match                    => tlb_cmp_dbg_way3_state_match,  
     tlb_cmp_dbg_way3_thdid_match                    => tlb_cmp_dbg_way3_thdid_match,  
     tlb_cmp_dbg_way3_pid_match                      => tlb_cmp_dbg_way3_pid_match,  
     tlb_cmp_dbg_way3_lpid_match                     => tlb_cmp_dbg_way3_lpid_match,  
     tlb_cmp_dbg_way3_ind_match                      => tlb_cmp_dbg_way3_ind_match,  
     tlb_cmp_dbg_way3_iprot_match                    => tlb_cmp_dbg_way3_iprot_match  

);
-- End of mmq_tlb_cmp component instantiation
-- End of mmq_tlb_cmp component instantiation
mmq_tlb_lrat: entity work.mmq_tlb_lrat(mmq_tlb_lrat)
  generic map ( epn_width => epn_width,
                   spr_data_width => spr_data_width, 
                   real_addr_width => real_addr_width,
                   rpn_width => rpn_width,
                   lpid_width => lpid_width,
                   expand_type => expand_type )
  port map(
     vdd               => vdd,
     gnd               => gnd,
     nclk              => nclk,
     tc_ccflush_dc             => tc_ac_ccflush_dc,
     tc_scan_dis_dc_b          => tc_ac_scan_dis_dc_b,
     tc_scan_diag_dc           => tc_ac_scan_diag_dc,
     tc_lbist_en_dc            => tc_ac_lbist_en_dc,

     lcb_d_mode_dc              => lcb_d_mode_dc,
     lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
     lcb_act_dis_dc             => lcb_act_dis_dc,
     lcb_mpw1_dc_b              => lcb_mpw1_dc_b,
     lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
     lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc,

     ac_func_scan_in            => func_scan_in_int(6),
     ac_func_scan_out           => func_scan_out_int(6),

     pc_sg_2                  => pc_sg_2(1),
     pc_func_sl_thold_2       => pc_func_sl_thold_2(1),
     pc_func_slp_sl_thold_2   => pc_func_slp_sl_thold_2(1),

     xu_mm_ccr2_notlb_b           => xu_mm_ccr2_notlb_b(6),
     tlb_delayed_act         => tlb_delayed_act(20 to 23),    
     mmucr2_act_override     => mmucr2_sig(3),

     tlb_ctl_ex3_valid    => tlb_ctl_ex3_valid_sig,  
     tlb_ctl_ex3_ttype    => tlb_ctl_ex3_ttype_sig,  
     xu_ex3_flush         => xu_ex3_flush,  
     xu_ex4_flush         => xu_ex4_flush,  
     xu_ex5_flush         => xu_ex5_flush,  
     tlb_tag0_epn         => tlb_tag0_epn(64-real_addr_width to 51),  
     tlb_tag0_thdid       => tlb_tag0_thdid,  
     tlb_tag0_type        => tlb_tag0_type,  
     tlb_tag0_lpid        => tlb_tag0_lpid,  
     tlb_tag0_atsel       => tlb_tag0_atsel,  
     tlb_tag0_size        => tlb_tag0_size,  
     tlb_tag0_addr_cap    => tlb_tag0_addr_cap,  
     ex6_illeg_instr      => ex6_illeg_instr,  

     pte_tag0_lpn         => pte_tag0_lpn(64-real_addr_width to 51),  
     pte_tag0_lpid        => pte_tag0_lpid,  
     mas0_0_atsel           => mas0_0_atsel,    
     mas0_0_esel            => mas0_0_esel,    
     mas0_0_hes             => mas0_0_hes,    
     mas0_0_wq              => mas0_0_wq,    
     mas1_0_v               => mas1_0_v,    
     mas1_0_tsize           => mas1_0_tsize,    
     mas2_0_epn             => mas2_0_epn(64-real_addr_width   to 51),  
     mas7_0_rpnu            => mas7_0_rpnu,    
     mas3_0_rpnl            => mas3_0_rpnl(32   to 51),  
     mas8_0_tlpid           => mas8_0_tlpid,    
     mmucr3_0_x             => mmucr3_0_sig(49),    
     mas0_1_atsel           => mas0_1_atsel,    
     mas0_1_esel            => mas0_1_esel,    
     mas0_1_hes             => mas0_1_hes,    
     mas0_1_wq              => mas0_1_wq,    
     mas1_1_v               => mas1_1_v,    
     mas1_1_tsize           => mas1_1_tsize,    
     mas2_1_epn             => mas2_1_epn(64-real_addr_width   to 51),  
     mas7_1_rpnu            => mas7_1_rpnu,    
     mas3_1_rpnl            => mas3_1_rpnl(32   to 51),  
     mas8_1_tlpid           => mas8_1_tlpid,    
     mmucr3_1_x             => mmucr3_1_sig(49),    
     mas0_2_atsel           => mas0_2_atsel,    
     mas0_2_esel            => mas0_2_esel,    
     mas0_2_hes             => mas0_2_hes,    
     mas0_2_wq              => mas0_2_wq,    
     mas1_2_v               => mas1_2_v,    
     mas1_2_tsize           => mas1_2_tsize,    
     mas2_2_epn             => mas2_2_epn(64-real_addr_width   to 51),  
     mas7_2_rpnu            => mas7_2_rpnu,    
     mas3_2_rpnl            => mas3_2_rpnl(32   to 51),  
     mas8_2_tlpid           => mas8_2_tlpid,    
     mmucr3_2_x             => mmucr3_2_sig(49),    
     mas0_3_atsel           => mas0_3_atsel,    
     mas0_3_esel            => mas0_3_esel,    
     mas0_3_hes             => mas0_3_hes,    
     mas0_3_wq              => mas0_3_wq,    
     mas1_3_v               => mas1_3_v,    
     mas1_3_tsize           => mas1_3_tsize,    
     mas2_3_epn             => mas2_3_epn(64-real_addr_width   to 51),  
     mas7_3_rpnu            => mas7_3_rpnu,    
     mas3_3_rpnl            => mas3_3_rpnl(32   to 51),  
     mas8_3_tlpid           => mas8_3_tlpid,    
     mmucr3_3_x             => mmucr3_3_sig(49),    

     lrat_mmucr3_x          => lrat_mmucr3_x,  
     lrat_mas0_esel         => lrat_mas0_esel,  
     lrat_mas1_v            => lrat_mas1_v,  
     lrat_mas1_tsize        => lrat_mas1_tsize,  
     lrat_mas2_epn          => lrat_mas2_epn,  
     lrat_mas3_rpnl         => lrat_mas3_rpnl,  
     lrat_mas7_rpnu         => lrat_mas7_rpnu,  
     lrat_mas8_tlpid        => lrat_mas8_tlpid,  
     lrat_mas_tlbre         => lrat_mas_tlbre,  
     lrat_mas_tlbsx_hit     => lrat_mas_tlbsx_hit,  
     lrat_mas_tlbsx_miss    => lrat_mas_tlbsx_miss,  
     lrat_mas_thdid         => lrat_mas_thdid,  

     lrat_tag3_lpn              => lrat_tag3_lpn,  
     lrat_tag3_rpn              => lrat_tag3_rpn,  
     lrat_tag3_hit_status       => lrat_tag3_hit_status,  
     lrat_tag3_hit_entry        => lrat_tag3_hit_entry,  
     lrat_tag4_lpn              => lrat_tag4_lpn,  
     lrat_tag4_rpn              => lrat_tag4_rpn,  
     lrat_tag4_hit_status       => lrat_tag4_hit_status,  
     lrat_tag4_hit_entry        => lrat_tag4_hit_entry,  

     lrat_dbg_tag1_addr_enable    => lrat_dbg_tag1_addr_enable,  
     lrat_dbg_tag2_matchline_q    => lrat_dbg_tag2_matchline_q,  
     lrat_dbg_entry0_addr_match   => lrat_dbg_entry0_addr_match,  
     lrat_dbg_entry0_lpid_match   => lrat_dbg_entry0_lpid_match,  
     lrat_dbg_entry0_entry_v      => lrat_dbg_entry0_entry_v,  
     lrat_dbg_entry0_entry_x      => lrat_dbg_entry0_entry_x,  
     lrat_dbg_entry0_size         => lrat_dbg_entry0_size,  
     lrat_dbg_entry1_addr_match   => lrat_dbg_entry1_addr_match,  
     lrat_dbg_entry1_lpid_match   => lrat_dbg_entry1_lpid_match,  
     lrat_dbg_entry1_entry_v      => lrat_dbg_entry1_entry_v,  
     lrat_dbg_entry1_entry_x      => lrat_dbg_entry1_entry_x,  
     lrat_dbg_entry1_size         => lrat_dbg_entry1_size,  
     lrat_dbg_entry2_addr_match   => lrat_dbg_entry2_addr_match,  
     lrat_dbg_entry2_lpid_match   => lrat_dbg_entry2_lpid_match,  
     lrat_dbg_entry2_entry_v      => lrat_dbg_entry2_entry_v,  
     lrat_dbg_entry2_entry_x      => lrat_dbg_entry2_entry_x,  
     lrat_dbg_entry2_size         => lrat_dbg_entry2_size,  
     lrat_dbg_entry3_addr_match   => lrat_dbg_entry3_addr_match,  
     lrat_dbg_entry3_lpid_match   => lrat_dbg_entry3_lpid_match,  
     lrat_dbg_entry3_entry_v      => lrat_dbg_entry3_entry_v,  
     lrat_dbg_entry3_entry_x      => lrat_dbg_entry3_entry_x,  
     lrat_dbg_entry3_size         => lrat_dbg_entry3_size,  
     lrat_dbg_entry4_addr_match   => lrat_dbg_entry4_addr_match,  
     lrat_dbg_entry4_lpid_match   => lrat_dbg_entry4_lpid_match,  
     lrat_dbg_entry4_entry_v      => lrat_dbg_entry4_entry_v,  
     lrat_dbg_entry4_entry_x      => lrat_dbg_entry4_entry_x,  
     lrat_dbg_entry4_size         => lrat_dbg_entry4_size,  
     lrat_dbg_entry5_addr_match   => lrat_dbg_entry5_addr_match,  
     lrat_dbg_entry5_lpid_match   => lrat_dbg_entry5_lpid_match,  
     lrat_dbg_entry5_entry_v      => lrat_dbg_entry5_entry_v,  
     lrat_dbg_entry5_entry_x      => lrat_dbg_entry5_entry_x,  
     lrat_dbg_entry5_size         => lrat_dbg_entry5_size,  
     lrat_dbg_entry6_addr_match   => lrat_dbg_entry6_addr_match,  
     lrat_dbg_entry6_lpid_match   => lrat_dbg_entry6_lpid_match,  
     lrat_dbg_entry6_entry_v      => lrat_dbg_entry6_entry_v,  
     lrat_dbg_entry6_entry_x      => lrat_dbg_entry6_entry_x,  
     lrat_dbg_entry6_size         => lrat_dbg_entry6_size,  
     lrat_dbg_entry7_addr_match   => lrat_dbg_entry7_addr_match,  
     lrat_dbg_entry7_lpid_match   => lrat_dbg_entry7_lpid_match,  
     lrat_dbg_entry7_entry_v      => lrat_dbg_entry7_entry_v,  
     lrat_dbg_entry7_entry_x      => lrat_dbg_entry7_entry_x,  
     lrat_dbg_entry7_size         => lrat_dbg_entry7_size  
);
-- End of mmq_tlb_lrat component instantiation
mmq_htw: entity work.mmq_htw(mmq_htw)
  generic map ( thdid_width => thdid_width,
                   pid_width => pid_width,
                   lpid_width => lpid_width,
                   epn_width => epn_width,
                   real_addr_width => real_addr_width,
                   rpn_width => rpn_width,
                   tlb_way_width  => tlb_way_width,
                   tlb_word_width => tlb_word_width,
                   tlb_tag_width => tlb_tag_width,
                   pte_width => pte_width,
                   expand_type => expand_type )
  port map(
     vdd               => vdd,
     gnd               => gnd,
     nclk              => nclk,
     tc_ccflush_dc             => tc_ac_ccflush_dc,
     tc_scan_dis_dc_b          => tc_ac_scan_dis_dc_b,
     tc_scan_diag_dc           => tc_ac_scan_diag_dc,
     tc_lbist_en_dc            => tc_ac_lbist_en_dc,

     lcb_d_mode_dc              => lcb_d_mode_dc,
     lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
     lcb_act_dis_dc             => lcb_act_dis_dc,
     lcb_mpw1_dc_b              => lcb_mpw1_dc_b,
     lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
     lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc,

     ac_func_scan_in(0 to 1)    => func_scan_in_int(7 to 8),
     ac_func_scan_out(0 to 1)   => func_scan_out_int(7 to 8),

     pc_sg_2                  => pc_sg_2(1),
     pc_func_sl_thold_2       => pc_func_sl_thold_2(1),
     pc_func_slp_sl_thold_2   => pc_func_slp_sl_thold_2(1),

     xu_mm_ccr2_notlb_b           => xu_mm_ccr2_notlb_b(7),

     tlb_delayed_act         => tlb_delayed_act(24 to 28),    
     mmucr2_act_override     => mmucr2_sig(4),

     tlb_ctl_tag2_flush               => tlb_ctl_tag2_flush_sig,
     tlb_ctl_tag3_flush               => tlb_ctl_tag3_flush_sig,
     tlb_ctl_tag4_flush               => tlb_ctl_tag4_flush_sig,

     tlb_tag2                   => tlb_tag2_sig,
     tlb_tag5_except            => tlb_tag5_except,

     tlb_htw_req_valid        => tlb_htw_req_valid,  
     tlb_htw_req_tag          => tlb_htw_req_tag,    
     tlb_htw_req_way          => tlb_htw_req_way,    
     htw_lsu_req_valid        => htw_lsu_req_valid,  
     htw_lsu_thdid            => htw_lsu_thdid,  
     htw_dbg_lsu_thdid        => htw_dbg_lsu_thdid,  
     htw_lsu_ttype            => htw_lsu_ttype,      
     htw_lsu_wimge            => htw_lsu_wimge,      
     htw_lsu_u                => htw_lsu_u,          
     htw_lsu_addr             => htw_lsu_addr,       
     htw_lsu_req_taken        => htw_lsu_req_taken,  
     htw_quiesce              => htw_quiesce_sig,    

     htw_req0_valid           => htw_req0_valid,    
     htw_req0_thdid           => htw_req0_thdid,    
     htw_req0_type            => htw_req0_type,    
     htw_req1_valid           => htw_req1_valid,    
     htw_req1_thdid           => htw_req1_thdid,    
     htw_req1_type            => htw_req1_type,    
     htw_req2_valid           => htw_req2_valid,    
     htw_req2_thdid           => htw_req2_thdid,    
     htw_req2_type            => htw_req2_type,    
     htw_req3_valid           => htw_req3_valid,    
     htw_req3_thdid           => htw_req3_thdid,    
     htw_req3_type            => htw_req3_type,    
     ptereload_req_valid  =>  ptereload_req_valid,  
     ptereload_req_tag    =>  ptereload_req_tag,    
     ptereload_req_pte    =>  ptereload_req_pte,    
     ptereload_req_taken  =>  ptereload_req_taken,  
     an_ac_reld_core_tag     => an_ac_reld_core_tag,    
     an_ac_reld_data         => an_ac_reld_data,        
     an_ac_reld_data_vld     => an_ac_reld_data_vld,    
     an_ac_reld_ecc_err      => an_ac_reld_ecc_err,     
     an_ac_reld_ecc_err_ue   => an_ac_reld_ecc_err_ue,  
     an_ac_reld_qw           => an_ac_reld_qw(58 to 59),          
     an_ac_reld_ditc         => an_ac_reld_ditc,        
     an_ac_reld_crit_qw      => an_ac_reld_crit_qw,      

     htw_dbg_seq_idle                 => htw_dbg_seq_idle,  
     htw_dbg_pte0_seq_idle            => htw_dbg_pte0_seq_idle,  
     htw_dbg_pte1_seq_idle            => htw_dbg_pte1_seq_idle,  
     htw_dbg_seq_q                    => htw_dbg_seq_q,  
     htw_dbg_inptr_q                  => htw_dbg_inptr_q,  
     htw_dbg_pte0_seq_q               => htw_dbg_pte0_seq_q,  
     htw_dbg_pte1_seq_q               => htw_dbg_pte1_seq_q,  
     htw_dbg_ptereload_ptr_q          => htw_dbg_ptereload_ptr_q,  
     htw_dbg_lsuptr_q                 => htw_dbg_lsuptr_q,  
     htw_dbg_req_valid_q              => htw_dbg_req_valid_q,  
     htw_dbg_resv_valid_vec           => htw_dbg_resv_valid_vec,  
     htw_dbg_tag4_clr_resv_q          => htw_dbg_tag4_clr_resv_q,  
     htw_dbg_tag4_clr_resv_terms      => htw_dbg_tag4_clr_resv_terms,  
     htw_dbg_pte0_score_ptr_q         => htw_dbg_pte0_score_ptr_q,  
     htw_dbg_pte0_score_cl_offset_q   => htw_dbg_pte0_score_cl_offset_q,  
     htw_dbg_pte0_score_error_q       => htw_dbg_pte0_score_error_q,  
     htw_dbg_pte0_score_qwbeat_q      => htw_dbg_pte0_score_qwbeat_q,  
     htw_dbg_pte0_score_pending_q     => htw_dbg_pte0_score_pending_q,  
     htw_dbg_pte0_score_ibit_q        => htw_dbg_pte0_score_ibit_q,  
     htw_dbg_pte0_score_dataval_q     => htw_dbg_pte0_score_dataval_q,  
     htw_dbg_pte0_reld_for_me_tm1     => htw_dbg_pte0_reld_for_me_tm1,  
     htw_dbg_pte1_score_ptr_q         => htw_dbg_pte1_score_ptr_q,  
     htw_dbg_pte1_score_cl_offset_q   => htw_dbg_pte1_score_cl_offset_q,  
     htw_dbg_pte1_score_error_q       => htw_dbg_pte1_score_error_q,  
     htw_dbg_pte1_score_qwbeat_q      => htw_dbg_pte1_score_qwbeat_q,  
     htw_dbg_pte1_score_pending_q     => htw_dbg_pte1_score_pending_q,  
     htw_dbg_pte1_score_ibit_q        => htw_dbg_pte1_score_ibit_q,  
     htw_dbg_pte1_score_dataval_q     => htw_dbg_pte1_score_dataval_q,  
     htw_dbg_pte1_reld_for_me_tm1     => htw_dbg_pte1_reld_for_me_tm1  

 );
-- End of mmq_htw component instantiation
end generate tlb_gen_logic;
tlb_gen_noarrays: if expand_tlb_type = 1 generate
tlb_dataout(0 to tlb_way_width-1) <= tlb_dataina;
tlb_dataout(tlb_way_width to 2*tlb_way_width-1) <= tlb_dataina;
tlb_dataout(2*tlb_way_width to 3*tlb_way_width-1) <= tlb_dataina;
tlb_dataout(3*tlb_way_width to 4*tlb_way_width-1) <= tlb_dataina;
lru_dataout <= lru_datain;
time_scan_int(1 to 5) <= (others => '0');
repr_scan_int(1 to 5) <= (others => '0');
abst_scan_int(1 to 6) <= (others => '0');
end generate tlb_gen_noarrays;
tlb_gen_instance: if expand_tlb_type = 2 generate
-----------------------------------------------------------------------
-- TLB Instantiation
-----------------------------------------------------------------------
tlb_array0: entity tri.tri_128x168_1w_0(tri_128x168_1w_0)
  generic map ( expand_type => expand_type )
  port map(
    gnd               => gnd,
    vdd               => vdd,
    vcs               => vcs,
    nclk              => nclk,
    act               => tlb_delayed_act(17),
    ccflush_dc        => tc_ac_ccflush_dc,
    scan_dis_dc_b     => tc_ac_scan_dis_dc_b,
    scan_diag_dc      => tc_ac_scan_diag_dc,
    repr_scan_in      => repr_scan_int(0),  
    time_scan_in      => time_scan_int(0),  
    abst_scan_in      => abst_scan_int(0),  
    repr_scan_out     => repr_scan_int(1),  
    time_scan_out     => time_scan_int(1),  
    abst_scan_out     => abst_scan_int(1),  
    lcb_d_mode_dc              => g6t_gptr_lcb_d_mode_dc,
    lcb_clkoff_dc_b            => g6t_gptr_lcb_clkoff_dc_b,
    lcb_act_dis_dc             => g6t_gptr_lcb_act_dis_dc,
    lcb_mpw1_dc_b              => g6t_gptr_lcb_mpw1_dc_b,
    lcb_mpw2_dc_b              => g6t_gptr_lcb_mpw2_dc_b,
    lcb_delay_lclkr_dc         => g6t_gptr_lcb_delay_lclkr_dc,

    tri_lcb_mpw1_dc_b              => lcb_mpw1_dc_b(0),
    tri_lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
    tri_lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc(0),
    tri_lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
    tri_lcb_act_dis_dc             => lcb_act_dis_dc,

    lcb_sg_1          => pc_sg_1(0),
    lcb_time_sg_0     => pc_sg_0(0),
    lcb_repr_sg_0     => pc_sg_0(0),
    lcb_abst_sl_thold_0   => pc_abst_sl_thold_0, 
    lcb_repr_sl_thold_0   => pc_repr_sl_thold_0, 
    lcb_time_sl_thold_0   => pc_time_sl_thold_0, 
    lcb_ary_nsl_thold_0   => pc_ary_slp_nsl_thold_0, 
    tc_lbist_ary_wrt_thru_dc  => an_ac_lbist_ary_wrt_thru_dc,    
    abist_en_1                => pc_mm_abist_ena_dc,
    din_abist                 => pc_mm_abist_di_g6t_2r_q,
    abist_cmp_en              => pc_mm_abist_wl128_comp_ena_q,
    abist_raw_b_dc            => pc_mm_abist_raw_dc_b,
    data_cmp_abist            => pc_mm_abist_dcomp_g6t_2r_q,
    addr_abist                => pc_mm_abist_raddr_0_q(3 to 9),  
    r_wb_abist                => pc_mm_abist_g6t_r_wb_q,
    lcb_bolt_sl_thold_0         => pc_mm_bolt_sl_thold_0,   
    pc_bo_enable_2              => pc_mm_bo_enable_2,   
    pc_bo_reset                 => pc_mm_bo_reset,   
    pc_bo_unload                => pc_mm_bo_unload,   
    pc_bo_repair                => pc_mm_bo_repair,   
    pc_bo_shdata                => pc_mm_bo_shdata,   
    pc_bo_select                => pc_mm_bo_select(0),   
    bo_pc_failout               => mm_pc_bo_fail(0),   
    bo_pc_diagloop              => mm_pc_bo_diagout(0),   

    write_enable      => tlb_write(0),
    addr              => tlb_addr,
    data_in           => tlb_dataina,
    data_out          => tlb_dataout(0 to tlb_way_width-1)
);
tlb_array1: entity tri.tri_128x168_1w_0(tri_128x168_1w_0)
  generic map ( expand_type => expand_type )
  port map(
    gnd               => gnd,
    vdd               => vdd,
    vcs               => vcs,
    nclk              => nclk,
    act               => tlb_delayed_act(17),

    ccflush_dc        => tc_ac_ccflush_dc,
    scan_dis_dc_b     => tc_ac_scan_dis_dc_b,
    scan_diag_dc      => tc_ac_scan_diag_dc,
    repr_scan_in    => repr_scan_int(1),  
    time_scan_in    => time_scan_int(1),  
    abst_scan_in    => abst_scan_int(1),  
    repr_scan_out   => repr_scan_int(2),  
    time_scan_out   => time_scan_int(2),  
    abst_scan_out   => abst_scan_int(2),  
    lcb_d_mode_dc              => g6t_gptr_lcb_d_mode_dc,
    lcb_clkoff_dc_b            => g6t_gptr_lcb_clkoff_dc_b,
    lcb_act_dis_dc             => g6t_gptr_lcb_act_dis_dc,
    lcb_mpw1_dc_b              => g6t_gptr_lcb_mpw1_dc_b,
    lcb_mpw2_dc_b              => g6t_gptr_lcb_mpw2_dc_b,
    lcb_delay_lclkr_dc         => g6t_gptr_lcb_delay_lclkr_dc,

    tri_lcb_mpw1_dc_b              => lcb_mpw1_dc_b(0),
    tri_lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
    tri_lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc(0),
    tri_lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
    tri_lcb_act_dis_dc             => lcb_act_dis_dc,

    lcb_sg_1          => pc_sg_1(0),
    lcb_time_sg_0     => pc_sg_0(0),
    lcb_repr_sg_0     => pc_sg_0(0),
    lcb_abst_sl_thold_0   => pc_abst_sl_thold_0, 
    lcb_repr_sl_thold_0   => pc_repr_sl_thold_0, 
    lcb_time_sl_thold_0   => pc_time_sl_thold_0, 
    lcb_ary_nsl_thold_0   => pc_ary_slp_nsl_thold_0, 
    tc_lbist_ary_wrt_thru_dc  => an_ac_lbist_ary_wrt_thru_dc,    
    abist_en_1                => pc_mm_abist_ena_dc,
    din_abist                 => pc_mm_abist_di_g6t_2r_q,
    abist_cmp_en              => pc_mm_abist_wl128_comp_ena_q,
    abist_raw_b_dc            => pc_mm_abist_raw_dc_b,
    data_cmp_abist            => pc_mm_abist_dcomp_g6t_2r_q,
    addr_abist                => pc_mm_abist_raddr_0_q(3 to 9),  
    r_wb_abist                => pc_mm_abist_g6t_r_wb_q,
    lcb_bolt_sl_thold_0         => pc_mm_bolt_sl_thold_0,   
    pc_bo_enable_2              => pc_mm_bo_enable_2,   
    pc_bo_reset                 => pc_mm_bo_reset,   
    pc_bo_unload                => pc_mm_bo_unload,   
    pc_bo_repair                => pc_mm_bo_repair,   
    pc_bo_shdata                => pc_mm_bo_shdata,   
    pc_bo_select                => pc_mm_bo_select(1),   
    bo_pc_failout               => mm_pc_bo_fail(1),   
    bo_pc_diagloop              => mm_pc_bo_diagout(1),   

    write_enable      => tlb_write(1),
    addr              => tlb_addr,
    data_in           => tlb_dataina,
    data_out          => tlb_dataout(tlb_way_width to 2*tlb_way_width-1)
);
tlb_array2: entity tri.tri_128x168_1w_0(tri_128x168_1w_0)
  generic map ( expand_type => expand_type )
  port map(
    gnd               => gnd,
    vdd               => vdd,
    vcs               => vcs,
    nclk              => nclk,
    act               => tlb_delayed_act(18),
    ccflush_dc        => tc_ac_ccflush_dc,
    scan_dis_dc_b     => tc_ac_scan_dis_dc_b,
    scan_diag_dc      => tc_ac_scan_diag_dc,
    repr_scan_in    => repr_scan_int(2),  
    time_scan_in    => time_scan_int(2),  
    abst_scan_in    => abst_scan_int(3),  
    repr_scan_out   => repr_scan_int(3),  
    time_scan_out   => time_scan_int(3),  
    abst_scan_out   => abst_scan_int(4),  
    lcb_d_mode_dc              => g6t_gptr_lcb_d_mode_dc,
    lcb_clkoff_dc_b            => g6t_gptr_lcb_clkoff_dc_b,
    lcb_act_dis_dc             => g6t_gptr_lcb_act_dis_dc,
    lcb_mpw1_dc_b              => g6t_gptr_lcb_mpw1_dc_b,
    lcb_mpw2_dc_b              => g6t_gptr_lcb_mpw2_dc_b,
    lcb_delay_lclkr_dc         => g6t_gptr_lcb_delay_lclkr_dc,

    tri_lcb_mpw1_dc_b              => lcb_mpw1_dc_b(0),
    tri_lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
    tri_lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc(0),
    tri_lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
    tri_lcb_act_dis_dc             => lcb_act_dis_dc,

    lcb_sg_1          => pc_sg_1(1),
    lcb_time_sg_0     => pc_sg_0(1),
    lcb_repr_sg_0     => pc_sg_0(1),
    lcb_abst_sl_thold_0   => pc_abst_sl_thold_0, 
    lcb_repr_sl_thold_0   => pc_repr_sl_thold_0, 
    lcb_time_sl_thold_0   => pc_time_sl_thold_0, 
    lcb_ary_nsl_thold_0   => pc_ary_slp_nsl_thold_0, 
    tc_lbist_ary_wrt_thru_dc  => an_ac_lbist_ary_wrt_thru_dc,    
    abist_en_1                => pc_mm_abist_ena_dc,
    din_abist                 => pc_mm_abist_di_g6t_2r_q,
    abist_cmp_en              => pc_mm_abist_wl128_comp_ena_q,
    abist_raw_b_dc            => pc_mm_abist_raw_dc_b,
    data_cmp_abist            => pc_mm_abist_dcomp_g6t_2r_q,
    addr_abist                => pc_mm_abist_raddr_0_q(3 to 9),  
    r_wb_abist                => pc_mm_abist_g6t_r_wb_q,
    lcb_bolt_sl_thold_0         => pc_mm_bolt_sl_thold_0,   
    pc_bo_enable_2              => pc_mm_bo_enable_2,   
    pc_bo_reset                 => pc_mm_bo_reset,   
    pc_bo_unload                => pc_mm_bo_unload,   
    pc_bo_repair                => pc_mm_bo_repair,   
    pc_bo_shdata                => pc_mm_bo_shdata,   
    pc_bo_select                => pc_mm_bo_select(2),   
    bo_pc_failout               => mm_pc_bo_fail(2),   
    bo_pc_diagloop              => mm_pc_bo_diagout(2),   

    write_enable      => tlb_write(2),
    addr              => tlb_addr,
    data_in           => tlb_datainb,
    data_out          => tlb_dataout(2*tlb_way_width to 3*tlb_way_width-1)
);
tlb_array3: entity tri.tri_128x168_1w_0(tri_128x168_1w_0)
  generic map ( expand_type => expand_type )
  port map(
    gnd               => gnd,
    vdd               => vdd,
    vcs               => vcs,
    nclk              => nclk,
    act               => tlb_delayed_act(18),

    ccflush_dc        => tc_ac_ccflush_dc,
    scan_dis_dc_b     => tc_ac_scan_dis_dc_b,
    scan_diag_dc      => tc_ac_scan_diag_dc,
    repr_scan_in    => repr_scan_int(3),  
    time_scan_in    => time_scan_int(3),  
    abst_scan_in    => abst_scan_int(4),  
    repr_scan_out   => repr_scan_int(4),  
    time_scan_out   => time_scan_int(4),  
    abst_scan_out   => abst_scan_int(5),  
    lcb_d_mode_dc              => g6t_gptr_lcb_d_mode_dc,
    lcb_clkoff_dc_b            => g6t_gptr_lcb_clkoff_dc_b,
    lcb_act_dis_dc             => g6t_gptr_lcb_act_dis_dc,
    lcb_mpw1_dc_b              => g6t_gptr_lcb_mpw1_dc_b,
    lcb_mpw2_dc_b              => g6t_gptr_lcb_mpw2_dc_b,
    lcb_delay_lclkr_dc         => g6t_gptr_lcb_delay_lclkr_dc,

    tri_lcb_mpw1_dc_b              => lcb_mpw1_dc_b(0),
    tri_lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
    tri_lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc(0),
    tri_lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
    tri_lcb_act_dis_dc             => lcb_act_dis_dc,

    lcb_sg_1          => pc_sg_1(1),
    lcb_time_sg_0     => pc_sg_0(1),
    lcb_repr_sg_0     => pc_sg_0(1),
    lcb_abst_sl_thold_0   => pc_abst_sl_thold_0, 
    lcb_repr_sl_thold_0   => pc_repr_sl_thold_0, 
    lcb_time_sl_thold_0   => pc_time_sl_thold_0, 
    lcb_ary_nsl_thold_0   => pc_ary_slp_nsl_thold_0, 
    tc_lbist_ary_wrt_thru_dc  => an_ac_lbist_ary_wrt_thru_dc,    
    abist_en_1                => pc_mm_abist_ena_dc,
    din_abist                 => pc_mm_abist_di_g6t_2r_q,
    abist_cmp_en              => pc_mm_abist_wl128_comp_ena_q,
    abist_raw_b_dc            => pc_mm_abist_raw_dc_b,
    data_cmp_abist            => pc_mm_abist_dcomp_g6t_2r_q,
    addr_abist                => pc_mm_abist_raddr_0_q(3 to 9),  
    r_wb_abist                => pc_mm_abist_g6t_r_wb_q,
    lcb_bolt_sl_thold_0         => pc_mm_bolt_sl_thold_0,   
    pc_bo_enable_2              => pc_mm_bo_enable_2,   
    pc_bo_reset                 => pc_mm_bo_reset,   
    pc_bo_unload                => pc_mm_bo_unload,   
    pc_bo_repair                => pc_mm_bo_repair,   
    pc_bo_shdata                => pc_mm_bo_shdata,   
    pc_bo_select                => pc_mm_bo_select(3),   
    bo_pc_failout               => mm_pc_bo_fail(3),   
    bo_pc_diagloop              => mm_pc_bo_diagout(3),   

    write_enable      => tlb_write(3),
    addr              => tlb_addr,
    data_in           => tlb_datainb,
    data_out          => tlb_dataout(3*tlb_way_width to 4*tlb_way_width-1)
);
-----------------------------------------------------------------------
-- LRU Instantiation
-----------------------------------------------------------------------
lru_array0: entity tri.tri_128x16_1r1w_1(tri_128x16_1r1w_1)
  generic map ( expand_type => expand_type )
  port map(
    gnd               => gnd,
    vdd               => vdd,
    vcs               => vcs,
    nclk              => nclk,
    rd_act               => tlb_delayed_act(19),
    wr_act               => tlb_delayed_act(19),

    lcb_d_mode_dc        => g8t_gptr_lcb_d_mode_dc,           
    lcb_clkoff_dc_b      => g8t_gptr_lcb_clkoff_dc_b,      
    lcb_mpw1_dc_b        => g8t_gptr_lcb_mpw1_dc_b,         
    lcb_mpw2_dc_b        => g8t_gptr_lcb_mpw2_dc_b,                  
    lcb_delay_lclkr_dc   => g8t_gptr_lcb_delay_lclkr_dc,      
    tri_lcb_mpw1_dc_b              => lcb_mpw1_dc_b(0),
    tri_lcb_mpw2_dc_b              => lcb_mpw2_dc_b,
    tri_lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc(0),
    tri_lcb_clkoff_dc_b            => lcb_clkoff_dc_b,
    tri_lcb_act_dis_dc             => lcb_act_dis_dc,

    ccflush_dc        => tc_ac_ccflush_dc,
    scan_dis_dc_b         => tc_ac_scan_dis_dc_b,     
    scan_diag_dc          => tc_ac_scan_diag_dc,     
    func_scan_in          => tidn,     
    func_scan_out         => open,      

    lcb_sg_0           => pc_sg_0(1),                      
    lcb_sl_thold_0_b   => pc_func_slp_sl_thold_0_b(1),     

    lcb_time_sl_thold_0        => pc_time_sl_thold_0,  
    lcb_abst_sl_thold_0        => pc_abst_sl_thold_0,  
    lcb_repr_sl_thold_0        => pc_repr_sl_thold_0, 
    lcb_ary_nsl_thold_0   => pc_ary_slp_nsl_thold_0, 

    time_scan_in         => time_scan_int(4),  
    time_scan_out        => time_scan_int(5),  
    repr_scan_in    => repr_scan_int(4),  
    repr_scan_out   => repr_scan_int(5),  
    abst_scan_in    => abst_scan_int(5),  
    abst_scan_out   => abst_scan_int(6),  

    abist_di                       => pc_mm_abist_di_0_q,   
    abist_bw_odd                   => pc_mm_abist_g8t_bw_1_q,   
    abist_bw_even                  => pc_mm_abist_g8t_bw_0_q,   
    abist_wr_adr                   => pc_mm_abist_waddr_0_q(3 TO 9),   
    wr_abst_act                    => pc_mm_abist_g8t_wenb_q,   
    abist_rd0_adr                  => pc_mm_abist_raddr_0_q(3 TO 9),   
    rd0_abst_act                   => pc_mm_abist_g8t1p_renb_0_q,   
    tc_lbist_ary_wrt_thru_dc       => an_ac_lbist_ary_wrt_thru_dc,   
    abist_ena_1                    => pc_mm_abist_ena_dc,   
    abist_g8t_rd0_comp_ena         => pc_mm_abist_wl128_comp_ena_q,   
    abist_raw_dc_b                 => pc_mm_abist_raw_dc_b,   
    obs0_abist_cmp                 => pc_mm_abist_g8t_dcomp_q,   

    lcb_bolt_sl_thold_0         => pc_mm_bolt_sl_thold_0,   
    pc_bo_enable_2              => pc_mm_bo_enable_2,   
    pc_bo_reset                 => pc_mm_bo_reset,   
    pc_bo_unload                => pc_mm_bo_unload,   
    pc_bo_repair                => pc_mm_bo_repair,   
    pc_bo_shdata                => pc_mm_bo_shdata,   
    pc_bo_select                => pc_mm_bo_select(4),   
    bo_pc_failout               => mm_pc_bo_fail(4),   
    bo_pc_diagloop              => mm_pc_bo_diagout(4),   

    bw                    => lru_write(0 to lru_width-1),     
    wr_adr                => lru_wr_addr,     
    rd_adr                => lru_rd_addr,     
    di                	  => lru_datain(0 to lru_width-1),     
    do                    => lru_dataout(0 to lru_width-1)    
);
end generate tlb_gen_instance;
xu_mm_ex2_eff_addr_sig <= xu_mm_ex2_eff_addr;
-----------------------------------------------------------------------
-- end of TLB logic
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
siv_0(0 to scan_right_0) <= sov_0(1 to scan_right_0) & func_scan_in_int(0);
func_scan_out_int(0) <= sov_0(0);
siv_1(0 to scan_right_1) <= sov_1(1 to scan_right_1) & func_scan_in_int(9);
func_scan_out_int(9) <= sov_1(0);
time_scan_int(0) <= time_scan_in_int;
repr_scan_int(0) <= repr_scan_in_int;
abst_scan_int(0) <= abst_scan_in_int(0);
abst_scan_int(3) <= abst_scan_in_int(1);
abst_scan_out_int(0) <= abst_scan_int(2);
abst_scan_out_int(1) <= abst_scan_int(6);
time_scan_out_int <= time_scan_int(5);
repr_scan_out_int <= repr_scan_int(5);
bcfg_scan_out_int <= bcfg_scan_in_int;
dcfg_scan_out_int <= dcfg_scan_in_int;
bsiv(0) <= ccfg_scan_in_int;
ccfg_scan_out_int <= bsov(boot_scan_right);
unused_dc(0) <= PC_ABST_SLP_SL_THOLD_0;
unused_dc(1) <= pc_ary_nsl_thold_0;
unused_dc(2 to 3) <= PC_FUNC_SL_THOLD_0(0 TO 1);
unused_dc(4 to 5) <= PC_FUNC_SL_THOLD_0_B(0 TO 1);
unused_dc(6 to 7) <= PC_FUNC_SLP_SL_THOLD_0(0 TO 1);
unused_dc(8) <= G8T_GPTR_LCB_ACT_DIS_DC;
unused_dc(9 to 11) <= PC_MM_ABIST_RADDR_0_Q(0 TO 2);
unused_dc(12 to 14) <= PC_MM_ABIST_WADDR_0_Q(0 TO 2);
unused_dc(15) <= PC_FUNC_SLP_SL_THOLD_0_B(0);
unused_dc(16 to 17) <= MMUCR0_0_SIG(0 TO 1);
unused_dc(18 to 19) <= MMUCR0_1_SIG(0 TO 1);
unused_dc(20 to 21) <= MMUCR0_2_SIG(0 TO 1);
unused_dc(22 to 23) <= MMUCR0_3_SIG(0 TO 1);
unused_dc(24 to 27) <= MMUCR1_SIG(0 TO 3);
unused_dc(28 to 31) <= MMUCR1_SIG(6 TO 9);
unused_dc(32 to 43) <= MMUCR1_SIG(20 TO 31);
unused_dc(44 to 65) <= TLB_TAG0_EPN(0 TO 21);
unused_dc(66 to 70) <= XU_MM_CCR2_NOTLB_B(8 TO 12);
-----------------------------------------------------------------------
-- Pass thru wire mapping from node to other units
-----------------------------------------------------------------------
an_ac_back_inv_omm	         <= an_ac_back_inv;
an_ac_back_inv_addr_omm     <= an_ac_back_inv_addr;
an_ac_back_inv_target_omm_iua   <= an_ac_back_inv_target(0 to 1);
an_ac_back_inv_target_omm_iub   <= an_ac_back_inv_target(3 to 4);
an_ac_reld_core_tag_omm         <= an_ac_reld_core_tag;
an_ac_reld_data_omm 	     <= an_ac_reld_data;
an_ac_reld_data_vld_omm         <= an_ac_reld_data_vld;
an_ac_reld_ecc_err_omm	     <= an_ac_reld_ecc_err;
an_ac_reld_ecc_err_ue_omm       <= an_ac_reld_ecc_err_ue;
an_ac_reld_qw_omm	             <= an_ac_reld_qw;
an_ac_reld_ditc_omm 	     <= an_ac_reld_ditc;
an_ac_reld_crit_qw_omm	     <= an_ac_reld_crit_qw;
an_ac_reld_data_coming_omm      <= an_ac_reld_data_coming;
an_ac_reld_l1_dump_omm	     <= an_ac_reld_l1_dump;
an_ac_grffence_en_dc_omm        <= an_ac_grffence_en_dc;
an_ac_stcx_complete_omm         <= an_ac_stcx_complete;
an_ac_abist_mode_dc_omm         <= an_ac_abist_mode_dc;
an_ac_abist_start_test_omm      <= an_ac_abist_start_test;
an_ac_abst_scan_in_omm_iu	     <= an_ac_abst_scan_in(0 to 4);
an_ac_abst_scan_in_omm_xu	     <= an_ac_abst_scan_in(7 to 9);
an_ac_atpg_en_dc_omm	         <= an_ac_atpg_en_dc;
an_ac_bcfg_scan_in_omm_bit1	         <= an_ac_bcfg_scan_in(1);
an_ac_bcfg_scan_in_omm_bit3	         <= an_ac_bcfg_scan_in(3);
an_ac_bcfg_scan_in_omm_bit4	         <= an_ac_bcfg_scan_in(4);
an_ac_lbist_ary_wrt_thru_dc_omm <= an_ac_lbist_ary_wrt_thru_dc;
an_ac_ccflush_dc_omm	     <= an_ac_ccflush_dc;
an_ac_reset_1_complete_omm      <= an_ac_reset_1_complete;
an_ac_reset_2_complete_omm      <= an_ac_reset_2_complete;
an_ac_reset_3_complete_omm      <= an_ac_reset_3_complete;
an_ac_reset_wd_complete_omm     <= an_ac_reset_wd_complete;
an_ac_dcfg_scan_in_omm	     <= an_ac_dcfg_scan_in(1 to 2);
an_ac_debug_stop_omm	     <= an_ac_debug_stop;
an_ac_func_scan_in_omm_iua	     <= an_ac_func_scan_in(0 to 21);
an_ac_func_scan_in_omm_iub	     <= an_ac_func_scan_in(60 to 63);
an_ac_func_scan_in_omm_xu	     <= an_ac_func_scan_in(31 to 58);
an_ac_lbist_en_dc_omm	   <= an_ac_lbist_en_dc;
an_ac_pm_thread_stop_omm      <= an_ac_pm_thread_stop;
an_ac_regf_scan_in_omm	   <= an_ac_regf_scan_in;
an_ac_scan_diag_dc_omm	   <= an_ac_scan_diag_dc;
an_ac_scan_dis_dc_b_omm       <= an_ac_scan_dis_dc_b;
an_ac_scom_cch_omm  	   <= an_ac_scom_cch;
an_ac_scom_dch_omm  	   <= an_ac_scom_dch;
an_ac_checkstop_omm 	   <= an_ac_checkstop;
an_ac_crit_interrupt_omm      <= an_ac_crit_interrupt;
an_ac_ext_interrupt_omm       <= an_ac_ext_interrupt;
an_ac_flh2l2_gate_omm	   <= an_ac_flh2l2_gate;
an_ac_icbi_ack_omm  	   <= an_ac_icbi_ack;
an_ac_icbi_ack_thread_omm     <= an_ac_icbi_ack_thread;
an_ac_req_ld_pop_omm	   <= an_ac_req_ld_pop;
an_ac_req_spare_ctrl_a1_omm   <= an_ac_req_spare_ctrl_a1;
an_ac_req_st_gather_omm	   <= an_ac_req_st_gather;
an_ac_req_st_pop_omm	   <= an_ac_req_st_pop;
an_ac_req_st_pop_thrd_omm     <= an_ac_req_st_pop_thrd;
an_ac_reservation_vld_omm     <= an_ac_reservation_vld;
an_ac_sleep_en_omm  	   <= an_ac_sleep_en;
an_ac_stcx_pass_omm 	   <= an_ac_stcx_pass;
an_ac_sync_ack_omm  	   <= an_ac_sync_ack;
an_ac_ary_nsl_thold_7_omm     <= an_ac_ary_nsl_thold_7;
an_ac_ccenable_dc_omm	   <= an_ac_ccenable_dc;
an_ac_coreid_omm	           <= an_ac_coreid;
an_ac_external_mchk_omm       <= an_ac_external_mchk;
an_ac_fce_7_omm	           <= an_ac_fce_7;
an_ac_func_nsl_thold_7_omm    <= an_ac_func_nsl_thold_7;
an_ac_func_sl_thold_7_omm     <= an_ac_func_sl_thold_7;
an_ac_gsd_test_enable_dc_omm  <= an_ac_gsd_test_enable_dc;
an_ac_gsd_test_acmode_dc_omm  <= an_ac_gsd_test_acmode_dc;
an_ac_gptr_scan_in_omm	   <= an_ac_gptr_scan_in;
an_ac_hang_pulse_omm	   <= an_ac_hang_pulse;
an_ac_lbist_ac_mode_dc_omm    <= an_ac_lbist_ac_mode_dc;
an_ac_lbist_ip_dc_omm	   <= an_ac_lbist_ip_dc;
an_ac_malf_alert_omm	   <= an_ac_malf_alert;
an_ac_perf_interrupt_omm	   <= an_ac_perf_interrupt;
an_ac_psro_enable_dc_omm	   <= an_ac_psro_enable_dc;
an_ac_repr_scan_in_omm	   <= an_ac_repr_scan_in;
an_ac_rtim_sl_thold_7_omm	   <= an_ac_rtim_sl_thold_7;
an_ac_scan_type_dc_omm	   <= an_ac_scan_type_dc;
an_ac_scom_sat_id_omm	   <= an_ac_scom_sat_id;
an_ac_sg_7_omm		   <= an_ac_sg_7;
an_ac_tb_update_enable_omm    <= an_ac_tb_update_enable;
an_ac_tb_update_pulse_omm	   <= an_ac_tb_update_pulse;
an_ac_time_scan_in_omm	   <= an_ac_time_scan_in;
ac_an_reld_ditc_pop <= ac_an_reld_ditc_pop_imm;
ac_an_power_managed <= ac_an_power_managed_imm;
ac_an_rvwinkle_mode <= ac_an_rvwinkle_mode_imm;
ac_an_fu_bypass_events <= ac_an_fu_bypass_events_imm;
ac_an_iu_bypass_events <= ac_an_iu_bypass_events_imm;
ac_an_mm_bypass_events <= ac_an_mm_bypass_events_imm;
ac_an_lsu_bypass_events <= ac_an_lsu_bypass_events_imm;
ac_an_event_bus <= ac_an_event_bus_imm;
ac_an_abst_scan_out(0 to 4) <= ac_an_abst_scan_out_imm_iu(0 to 4);
ac_an_abst_scan_out(7 to 9) <= ac_an_abst_scan_out_imm_xu(7 to 9);
ac_an_bcfg_scan_out <= ac_an_bcfg_scan_out_imm;
ac_an_dcfg_scan_out <= ac_an_dcfg_scan_out_imm;
ac_an_func_scan_out(0 to 21)  <= ac_an_func_scan_out_imm_iua(0 to 21);
ac_an_func_scan_out(31 to 58) <= ac_an_func_scan_out_imm_xu(31 to 58);
ac_an_func_scan_out(60 to 63) <= ac_an_func_scan_out_imm_iub(60 to 63);
ac_an_regf_scan_out <= ac_an_regf_scan_out_imm;
ac_an_pm_thread_running <= ac_an_pm_thread_running_imm;
ac_an_recov_err    <= ac_an_recov_err_imm;
ac_an_scom_cch     <= ac_an_scom_cch_imm;
ac_an_scom_dch     <= ac_an_scom_dch_imm;
ac_an_special_attn <= ac_an_special_attn_imm;
ac_an_checkstop       <= ac_an_checkstop_imm;
ac_an_local_checkstop <= ac_an_local_checkstop_imm;
ac_an_trace_error     <= ac_an_trace_error_imm;
ac_an_box_empty 	      <= ac_an_box_empty_imm;
ac_an_machine_check      <= ac_an_machine_check_imm;
ac_an_req		      <= ac_an_req_imm;
ac_an_req_endian	      <= ac_an_req_endian_imm;
ac_an_req_ld_core_tag    <= ac_an_req_ld_core_tag_imm;
ac_an_req_ld_xfr_len     <= ac_an_req_ld_xfr_len_imm;
ac_an_req_pwr_token      <= ac_an_req_pwr_token_imm;
ac_an_req_ra	      <= ac_an_req_ra_imm;
ac_an_req_spare_ctrl_a0  <= ac_an_req_spare_ctrl_a0_imm;
ac_an_req_thread	      <= ac_an_req_thread_imm;
ac_an_req_ttype 	      <= ac_an_req_ttype_imm;
ac_an_req_user_defined   <= ac_an_req_user_defined_imm;
ac_an_req_wimg_g	      <= ac_an_req_wimg_g_imm;
ac_an_req_wimg_i	      <= ac_an_req_wimg_i_imm;
ac_an_req_wimg_m	      <= ac_an_req_wimg_m_imm;
ac_an_req_wimg_w	      <= ac_an_req_wimg_w_imm;
ac_an_st_byte_enbl	        <= ac_an_st_byte_enbl_imm;
ac_an_st_data		<= ac_an_st_data_imm;
ac_an_st_data_pwr_token    <= ac_an_st_data_pwr_token_imm;
ac_an_abist_done_dc	<= ac_an_abist_done_dc_imm;
ac_an_debug_trigger	<= ac_an_debug_trigger_imm;
psro_ringsig_inv1:  ac_an_psro_ringsig_b   <= not(ac_an_psro_ringsig_imm);
psro_ringsig_inv2:  ac_an_psro_ringsig	   <= not(ac_an_psro_ringsig_b);
ac_an_reset_1_request	   <= ac_an_reset_1_request_imm;
ac_an_reset_2_request	   <= ac_an_reset_2_request_imm;
ac_an_reset_3_request	   <= ac_an_reset_3_request_imm;
ac_an_reset_wd_request        <= ac_an_reset_wd_request_imm;
ac_an_dcr_act		   <= '0';
ac_an_dcr_val		   <= '0';
ac_an_dcr_read  	   <= '0';
ac_an_dcr_user  	   <= '0';
ac_an_dcr_etid  	   <= (others => '0');
ac_an_dcr_addr  	   <= (others => '0');
ac_an_dcr_data	   <= (others => '0');
-- Pass thru wires specifically for Bluegene, PC <--> IU <--> MMU <--> L1P/TPB
bg_ac_an_func_scan_ns      <= bg_ac_an_func_scan_ns_imm;
bg_ac_an_abst_scan_ns      <= bg_ac_an_abst_scan_ns_imm;
bg_pc_l1p_abist_di_0               <= bg_pc_l1p_abist_di_0_imm;
bg_pc_l1p_abist_g8t1p_renb_0       <= bg_pc_l1p_abist_g8t1p_renb_0_imm;
bg_pc_l1p_abist_g8t_bw_0           <= bg_pc_l1p_abist_g8t_bw_0_imm;
bg_pc_l1p_abist_g8t_bw_1           <= bg_pc_l1p_abist_g8t_bw_1_imm;
bg_pc_l1p_abist_g8t_dcomp          <= bg_pc_l1p_abist_g8t_dcomp_imm;
bg_pc_l1p_abist_g8t_wenb           <= bg_pc_l1p_abist_g8t_wenb_imm;
bg_pc_l1p_abist_raddr_0            <= bg_pc_l1p_abist_raddr_0_imm;
bg_pc_l1p_abist_waddr_0            <= bg_pc_l1p_abist_waddr_0_imm;
bg_pc_l1p_abist_wl128_comp_ena     <= bg_pc_l1p_abist_wl128_comp_ena_imm;
bg_pc_l1p_abist_wl32_comp_ena      <= bg_pc_l1p_abist_wl32_comp_ena_imm;
bg_pc_l1p_gptr_sl_thold_2          <= bg_pc_l1p_gptr_sl_thold_2_imm;
bg_pc_l1p_time_sl_thold_2          <= bg_pc_l1p_time_sl_thold_2_imm;
bg_pc_l1p_repr_sl_thold_2          <= bg_pc_l1p_repr_sl_thold_2_imm;
bg_pc_l1p_abst_sl_thold_2          <= bg_pc_l1p_abst_sl_thold_2_imm;
bg_pc_l1p_func_sl_thold_2          <= bg_pc_l1p_func_sl_thold_2_imm;
bg_pc_l1p_func_slp_sl_thold_2      <= bg_pc_l1p_func_slp_sl_thold_2_imm;
bg_pc_l1p_bolt_sl_thold_2          <= bg_pc_l1p_bolt_sl_thold_2_imm;
bg_pc_l1p_ary_nsl_thold_2          <= bg_pc_l1p_ary_nsl_thold_2_imm;
bg_pc_l1p_sg_2                     <= bg_pc_l1p_sg_2_imm;
bg_pc_l1p_fce_2                    <= bg_pc_l1p_fce_2_imm;
bg_pc_l1p_bo_enable_2              <= bg_pc_l1p_bo_enable_2_imm;
bg_pc_bo_unload                    <= bg_pc_bo_unload_imm;
bg_pc_bo_load                      <= bg_pc_bo_load_imm;
bg_pc_bo_repair                    <= bg_pc_bo_repair_imm;
bg_pc_bo_reset                     <= bg_pc_bo_reset_imm;
bg_pc_bo_shdata                    <= bg_pc_bo_shdata_imm;
bg_pc_bo_select                    <= bg_pc_bo_select_imm;
bg_pc_l1p_ccflush_dc               <= bg_pc_l1p_ccflush_dc_imm;
bg_pc_l1p_abist_ena_dc             <= bg_pc_l1p_abist_ena_dc_imm;
bg_pc_l1p_abist_raw_dc_b           <= bg_pc_l1p_abist_raw_dc_b_imm;
-- Pass thru wires specifically for Bluegene, L1P/TPB -> MMU -> IU -> PC
bg_an_ac_func_scan_sn_omm          <= bg_an_ac_func_scan_sn;
bg_an_ac_abst_scan_sn_omm          <= bg_an_ac_abst_scan_sn;
bg_pc_bo_fail_omm                  <= bg_pc_bo_fail;
bg_pc_bo_diagout_omm               <= bg_pc_bo_diagout;
end mmq;
