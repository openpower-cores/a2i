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
--* TITLE: Instruction Cache
--*
--* NAME: iuq_ic.vhdl
--*
--*********************************************************************

library ieee;
use ieee.std_logic_1164.all;
library support;
use support.power_logic_pkg.all;
library clib;
library tri;
use tri.tri_latches_pkg.all;
library work;
use work.iuq_pkg.all;

entity iuq_ic is
  generic(regmode               : integer := 6;
          bcfg_epn_0to15        : integer := 0;
          bcfg_epn_16to31       : integer := 0;
          bcfg_epn_32to47       : integer := (2**16)-1;  
          bcfg_epn_48to51       : integer := (2**4)-1; 
          bcfg_rpn_22to31       : integer := (2**10)-1;
          bcfg_rpn_32to47       : integer := (2**16)-1;  
          bcfg_rpn_48to51       : integer := (2**4)-1; 
          expand_type           : integer := 2 );
port(
     vcs                        : inout power_logic;
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;

     tc_ac_ccflush_dc           : in std_ulogic;
     an_ac_scan_dis_dc_b        : in std_ulogic;
     an_ac_scan_diag_dc         : in std_ulogic;

     pc_iu_func_sl_thold_2      : in std_ulogic;
     pc_iu_func_slp_sl_thold_2  : in std_ulogic;
     pc_iu_time_sl_thold_2      : in std_ulogic;
     pc_iu_abst_sl_thold_2      : in std_ulogic;
     pc_iu_abst_slp_sl_thold_2  : in std_ulogic;
     pc_iu_repr_sl_thold_2      : in std_ulogic;
     pc_iu_cfg_slp_sl_thold_2   : in std_ulogic;
     pc_iu_regf_slp_sl_thold_2  : in std_ulogic;
     pc_iu_ary_nsl_thold_2      : in std_ulogic;
     pc_iu_ary_slp_nsl_thold_2  : in std_ulogic;
     pc_iu_func_slp_nsl_thold_2 : in std_ulogic;
     pc_iu_bolt_sl_thold_2      : in std_ulogic;
     pc_iu_sg_2                 : in std_ulogic;
     pc_iu_fce_2                : in std_ulogic;
     clkoff_b                   : in std_ulogic;
     delay_lclkr                : in std_ulogic_vector(0 to 1);
     mpw1_b                     : in std_ulogic_vector(0 to 1);
     g8t_clkoff_b               : in std_ulogic;
     g8t_d_mode                 : in std_ulogic;
     g8t_delay_lclkr            : in std_ulogic_vector(0 to 4);
     g8t_mpw1_b                 : in std_ulogic_vector(0 to 4);
     g8t_mpw2_b                 : in std_ulogic;
     g6t_clkoff_b               : in std_ulogic;
     g6t_d_mode                 : in std_ulogic;
     g6t_delay_lclkr            : in std_ulogic_vector(0 to 3);
     g6t_mpw1_b                 : in std_ulogic_vector(0 to 4);
     g6t_mpw2_b                 : in std_ulogic;
     cam_clkoff_b               : in std_ulogic;
     cam_d_mode                 : in std_ulogic;
     cam_delay_lclkr            : in std_ulogic_vector(0 to 4);
     cam_mpw1_b                 : in std_ulogic_vector(0 to 4);
     cam_mpw2_b                 : in std_ulogic;

     func_scan_in               : in std_ulogic_vector(0 to 4);
     func_scan_out              : out std_ulogic_vector(0 to 4);
     ac_ccfg_scan_in            : in std_ulogic;
     ac_ccfg_scan_out           : out std_ulogic;
     time_scan_in               : in std_ulogic;
     time_scan_out              : out std_ulogic;
     repr_scan_in               : in std_ulogic;
     repr_scan_out              : out std_ulogic;
     abst_scan_in               : in std_ulogic_vector(0 to 2);
     abst_scan_out              : out std_ulogic_vector(0 to 2);
     regf_scan_in               : in std_ulogic_vector(0 to 4);
     regf_scan_out              : out std_ulogic_vector(0 to 4);

     uc_dbg_data                : in  std_ulogic_vector(0 to 87);

     pc_iu_trace_bus_enable     : in  std_ulogic;
     pc_iu_debug_mux_ctrls      : in  std_ulogic_vector(0 to 15);

     debug_data_in              : in  std_ulogic_vector(0 to 87);
     trace_triggers_in          : in  std_ulogic_vector(0 to 11);

     debug_data_out             : out std_ulogic_vector(0 to 87);
     trace_triggers_out         : out std_ulogic_vector(0 to 11);

     pc_iu_event_bus_enable     : in  std_ulogic;

     ic_perf_event_t0           : out std_ulogic_vector(0 to 6);
     ic_perf_event_t1           : out std_ulogic_vector(0 to 6);
     ic_perf_event_t2           : out std_ulogic_vector(0 to 6);
     ic_perf_event_t3           : out std_ulogic_vector(0 to 6);
     ic_perf_event              : out std_ulogic_vector(0 to 1);

     iu_pc_err_icache_parity    : out std_ulogic;
     iu_pc_err_icachedir_parity : out std_ulogic;
     iu_pc_err_icachedir_multihit : out std_ulogic;

     pc_iu_inj_icache_parity    : in  std_ulogic;
     pc_iu_inj_icachedir_parity : in  std_ulogic;
     pc_iu_inj_icachedir_multihit : in  std_ulogic;

     pc_iu_abist_g8t_wenb       : in std_ulogic;
     pc_iu_abist_g8t1p_renb_0   : in std_ulogic;
     pc_iu_abist_di_0           : in std_ulogic_vector(0 to 3);
     pc_iu_abist_g8t_bw_1       : in std_ulogic;
     pc_iu_abist_g8t_bw_0       : in std_ulogic;
     pc_iu_abist_waddr_0        : in std_ulogic_vector(4 to 9);
     pc_iu_abist_raddr_0        : in std_ulogic_vector(2 to 9);
     pc_iu_abist_ena_dc         : in std_ulogic;
     pc_iu_abist_wl64_comp_ena  : in std_ulogic;
     pc_iu_abist_raw_dc_b       : in std_ulogic;
     pc_iu_abist_g8t_dcomp      : in std_ulogic_vector(0 to 3);
     pc_iu_abist_g6t_bw         : in std_ulogic_vector(0 to 1);
     pc_iu_abist_di_g6t_2r      : in std_ulogic_vector(0 to 3);
     pc_iu_abist_wl256_comp_ena : in std_ulogic;
     pc_iu_abist_dcomp_g6t_2r   : in std_ulogic_vector(0 to 3);
     pc_iu_abist_g6t_r_wb       : in std_ulogic;
     an_ac_lbist_ary_wrt_thru_dc: in std_ulogic;
     an_ac_lbist_en_dc          : in std_ulogic;
     an_ac_atpg_en_dc           : in std_ulogic;
     an_ac_grffence_en_dc       : in std_ulogic;

     pc_iu_bo_enable_3          : in std_ulogic; 
     pc_iu_bo_reset             : in std_ulogic;
     pc_iu_bo_unload            : in std_ulogic;
     pc_iu_bo_repair            : in std_ulogic;
     pc_iu_bo_shdata            : in std_ulogic;
     pc_iu_bo_select            : in std_ulogic_vector(0 to 3);
     iu_pc_bo_fail              : out std_ulogic_vector(0 to 3);
     iu_pc_bo_diagout           : out std_ulogic_vector(0 to 3);

     pc_iu_init_reset           : in std_ulogic;

     xu_iu_rf1_val              : in std_ulogic_vector(0 to 3);
     xu_iu_rf1_is_eratre        : in std_ulogic;
     xu_iu_rf1_is_eratwe        : in std_ulogic;
     xu_iu_rf1_is_eratsx        : in std_ulogic;
     xu_iu_rf1_is_eratilx       : in std_ulogic;
     xu_iu_ex1_is_isync         : in std_ulogic;
     xu_iu_ex1_is_csync         : in std_ulogic;
     xu_iu_rf1_ws               : in std_ulogic_vector(0 to 1);
     xu_iu_rf1_t                : in std_ulogic_vector(0 to 2);
     xu_iu_ex1_rs_is            : in std_ulogic_vector(0 to 8);
     xu_iu_ex1_ra_entry         : in std_ulogic_vector(0 to 3);

     xu_iu_ex1_rb               : in std_ulogic_vector(64-(2**regmode) to 51);
     xu_rf1_flush               : in std_ulogic_vector(0 to 3);
     xu_ex1_flush               : in std_ulogic_vector(0 to 3);
     xu_ex2_flush               : in std_ulogic_vector(0 to 3);
     xu_ex3_flush               : in std_ulogic_vector(0 to 3);
     xu_ex4_flush               : in std_ulogic_vector(0 to 3);
     xu_ex5_flush               : in std_ulogic_vector(0 to 3);
     xu_iu_ex4_rs_data          : in std_ulogic_vector(64-(2**regmode) to 63);
     xu_iu_msr_hv               : in std_ulogic_vector(0 to 3);
     xu_iu_msr_pr               : in std_ulogic_vector(0 to 3);
     xu_iu_msr_is               : in std_ulogic_vector(0 to 3);
     xu_iu_hid_mmu_mode         : in std_ulogic;
     xu_iu_spr_ccr2_ifratsc     : in std_ulogic_vector(0 to 8);
     xu_iu_spr_ccr2_ifrat       : in std_ulogic;
     xu_iu_xucr4_mmu_mchk       : in std_ulogic;
     iu_xu_ex4_data             : out std_ulogic_vector(64-(2**regmode) to 63);
     iu_xu_ierat_ex3_par_err    : out std_ulogic_vector(0 to 3);
     iu_xu_ierat_ex4_par_err    : out std_ulogic_vector(0 to 3);
     iu_xu_ierat_ex2_flush_req  : out std_ulogic_vector(0 to 3);

     iu_mm_ierat_req            : out std_ulogic;
     iu_mm_ierat_epn            : out std_ulogic_vector(0 to 51);
     iu_mm_ierat_thdid          : out std_ulogic_vector(0 to 3);
     iu_mm_ierat_state          : out std_ulogic_vector(0 to 3);
     iu_mm_ierat_tid            : out std_ulogic_vector(0 to 13);
     iu_mm_ierat_flush          : out std_ulogic_vector(0 to 3);

     mm_iu_ierat_rel_val        : in std_ulogic_vector(0 to 4);
     mm_iu_ierat_rel_data       : in std_ulogic_vector(0 to 131);

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

     mm_iu_ierat_snoop_coming   : in std_ulogic;
     mm_iu_ierat_snoop_val      : in std_ulogic;
     mm_iu_ierat_snoop_attr     : in std_ulogic_vector(0 to 25);
     mm_iu_ierat_snoop_vpn      : in std_ulogic_vector(EFF_IFAR'left to 51);
     iu_mm_ierat_snoop_ack      : out std_ulogic;

     iu_mm_lmq_empty            : out std_ulogic;

     ac_an_power_managed        : in std_ulogic;

     xu_iu_run_thread           : in std_ulogic_vector(0 to 3);

     xu_iu_flush                : in std_ulogic_vector(0 to 3);
     xu_iu_iu0_flush_ifar0      : in EFF_IFAR;
     xu_iu_iu0_flush_ifar1      : in EFF_IFAR;
     xu_iu_iu0_flush_ifar2      : in EFF_IFAR;
     xu_iu_iu0_flush_ifar3      : in EFF_IFAR;
     xu_iu_flush_2ucode         : in std_ulogic_vector(0 to 3);
     xu_iu_flush_2ucode_type    : in std_ulogic_vector(0 to 3);

     xu_iu_msr_cm               : in std_ulogic_vector(0 to 3);

     xu_iu_ex6_icbi_val         : in  std_ulogic_vector(0 to 3);
     xu_iu_ex6_icbi_addr        : in  std_ulogic_vector(REAL_IFAR'left to 57);

     xu_iu_ici                  : in  std_ulogic;

     spr_ic_cls                 : in std_ulogic;                
     spr_ic_clockgate_dis       : in std_ulogic_vector(0 to 1);
     spr_ic_icbi_ack_en         : in std_ulogic;
     spr_ic_bp_config           : in std_ulogic_vector(0 to 3); 

     spr_ic_idir_read           : in std_ulogic;
     spr_ic_idir_way            : in std_ulogic_vector(0 to 1);
     spr_ic_idir_row            : in std_ulogic_vector(52 to 57);
     spr_ic_pri_rand            : in std_ulogic_vector(0 to 4);
     spr_ic_pri_rand_always     : in std_ulogic;
     spr_ic_pri_rand_flush      : in std_ulogic;

     ic_spr_idir_done           : out std_ulogic;
     ic_spr_idir_lru            : out std_ulogic_vector(0 to 2);
     ic_spr_idir_parity         : out std_ulogic_vector(0 to 3);
     ic_spr_idir_endian         : out std_ulogic;
     ic_spr_idir_valid          : out std_ulogic;
     ic_spr_idir_tag            : out std_ulogic_vector(0 to 29);

     iu_xu_request              : out std_ulogic;
     iu_xu_thread               : out std_ulogic_vector(0 to 3);
     iu_xu_ra                   : out std_ulogic_vector(REAL_IFAR'left to 59);
     iu_xu_wimge                : out std_ulogic_vector(0 to 4);
     iu_xu_userdef              : out std_ulogic_vector(0 to 3);

     an_ac_reld_data_vld        : in std_ulogic;
     an_ac_reld_core_tag        : in std_ulogic_vector(0 to 4);
     an_ac_reld_qw              : in std_ulogic_vector(57 to 59);
     an_ac_reld_data            : in std_ulogic_vector(0 to 127);
     an_ac_reld_ecc_err         : in std_ulogic;
     an_ac_reld_ecc_err_ue      : in std_ulogic;

     an_ac_back_inv             : in std_ulogic;
     an_ac_back_inv_addr        : in std_ulogic_vector(REAL_IFAR'left to 57);
     an_ac_back_inv_target      : in std_ulogic;        

     an_ac_icbi_ack             : in std_ulogic;
     an_ac_icbi_ack_thread      : in std_ulogic_vector(0 to 1);

     bp_ib_iu4_ifar             : in EFF_IFAR;

     bp_ic_iu5_hold_tid         : in std_ulogic_vector(0 to 3);
     bp_ic_iu5_redirect_tid     : in std_ulogic_vector(0 to 3);
     bp_ic_iu5_redirect_ifar    : in EFF_IFAR;

     ic_bp_iu1_val              : out std_ulogic;
     ic_bp_iu1_tid              : out std_ulogic_vector(0 to 3);
     ic_bp_iu1_ifar             : out std_ulogic_vector(52 to 59);

     ic_bp_iu3_val              : out std_ulogic_vector(0 to 3);
     ic_bp_iu3_tid              : out std_ulogic_vector(0 to 3);
     ic_bp_iu3_ifar             : out EFF_IFAR;
     ic_bp_iu3_2ucode           : out std_ulogic;
     ic_bp_iu3_2ucode_type      : out std_ulogic;
     ic_bp_iu3_error            : out std_ulogic_vector(0 to 2);
     ic_bp_iu3_flush            : out std_ulogic;

     ic_bp_iu3_0_instr          : out std_ulogic_vector(0 to 35);
     ic_bp_iu3_1_instr          : out std_ulogic_vector(0 to 35);
     ic_bp_iu3_2_instr          : out std_ulogic_vector(0 to 35);
     ic_bp_iu3_3_instr          : out std_ulogic_vector(0 to 35);

     ib_ic_empty                : in std_ulogic_vector(0 to 3);
     ib_ic_below_water          : in std_ulogic_vector(0 to 3);
     ib_ic_iu5_redirect_tid     : in std_ulogic_vector(0 to 3);

     ic_fdep_load_quiesce       : out std_ulogic_vector(0 to 3);
     ic_fdep_icbi_ack           : out std_ulogic_vector(0 to 3);

     uc_flush_tid               : in std_ulogic_vector(0 to 3);
     uc_ic_hold_thread          : in std_ulogic_vector(0 to 3)

);
-- synopsys translate_off
-- synopsys translate_on
end iuq_ic;
architecture iuq_ic of iuq_ic is
constant epn_width              : integer := 52-EFF_IFAR'left;
constant rpn_width              : integer := 52-REAL_IFAR'left;
constant rs_data_width          : integer := 2**regmode;
constant data_out_width         : integer := 2**regmode;
constant trigger_data_out_offset: natural := 0;
constant trace_data_out_offset  : natural := trigger_data_out_offset        + 12;
constant event_bus_enable_offset: natural := trace_data_out_offset          + 88;
constant trace_bus_enable_offset: natural := event_bus_enable_offset        + 1;
constant debug_mux_ctrls_offset : natural := trace_bus_enable_offset        + 1;
constant scan_right             : natural := debug_mux_ctrls_offset         + 16-1;
signal iu_ierat_iu0_val         : std_ulogic;
signal iu_ierat_iu0_thdid       : std_ulogic_vector(0 to 3);
signal iu_ierat_iu0_ifar        : std_ulogic_vector(0 to 51);
signal iu_ierat_iu0_flush       : std_ulogic_vector(0 to 3);
signal iu_ierat_iu1_flush       : std_ulogic_vector(0 to 3);
signal iu_ierat_iu1_back_inv    : std_ulogic;
signal iu_ierat_ium1_back_inv   : std_ulogic;
signal ierat_iu_iu2_rpn         : std_ulogic_vector(22 to 51);
signal ierat_iu_iu2_wimge       : std_ulogic_vector(0 to 4);
signal ierat_iu_iu2_u           : std_ulogic_vector(0 to 3);
signal ierat_iu_iu2_error       : std_ulogic_vector(0 to 2);
signal ierat_iu_iu2_miss        : std_ulogic;
signal ierat_iu_iu2_multihit    : std_ulogic;
signal ierat_iu_iu2_isi         : std_ulogic;
signal ierat_iu_hold_req        : std_ulogic_vector(0 to 3);
signal ierat_iu_iu2_flush_req   : std_ulogic_vector(0 to 3);
signal ics_icd_dir_rd_act       : std_ulogic;
signal ics_icd_data_rd_act      : std_ulogic;
signal ics_icd_iu0_valid        : std_ulogic;
signal ics_icd_iu0_tid          : std_ulogic_vector(0 to 3);
signal ics_icd_iu0_ifar         : EFF_IFAR;
signal ics_icd_iu0_inval        : std_ulogic;
signal ics_icd_iu0_2ucode       : std_ulogic;
signal ics_icd_iu0_2ucode_type  : std_ulogic;
signal ics_icd_iu0_spr_idir_read: std_ulogic;
signal icd_ics_iu1_valid        : std_ulogic;
signal icd_ics_iu1_tid          : std_ulogic_vector(0 to 3);
signal icd_ics_iu1_ifar         : EFF_IFAR;
signal icd_ics_iu1_2ucode       : std_ulogic;
signal icd_ics_iu1_2ucode_type  : std_ulogic;
signal ics_icd_all_flush_prev   : std_ulogic_vector(0 to 3);
signal ics_icd_iu1_flush_tid    : std_ulogic_vector(0 to 3);
signal ics_icd_iu2_flush_tid    : std_ulogic_vector(0 to 3);
signal icd_ics_iu2_miss_flush_prev : std_ulogic_vector(0 to 3);
signal icd_ics_iu2_ifar_eff     : EFF_IFAR;
signal icd_ics_iu2_2ucode       : std_ulogic;
signal icd_ics_iu2_2ucode_type  : std_ulogic;
signal icd_ics_iu3_parity_flush : std_ulogic_vector(0 to 3);
signal icd_ics_iu3_ifar         : EFF_IFAR;
signal icd_ics_iu3_2ucode       : std_ulogic;
signal icd_ics_iu3_2ucode_type  : std_ulogic;
signal icm_ics_iu0_preload_val  : std_ulogic;
signal icm_ics_iu0_preload_tid  : std_ulogic_vector(0 to 3);
signal icm_ics_iu0_preload_ifar : std_ulogic_vector(52 to 59);
signal icm_ics_hold_thread      : std_ulogic_vector(0 to 3);
signal icm_ics_hold_thread_dbg  : std_ulogic_vector(0 to 3);
signal icm_ics_hold_iu0         : std_ulogic;
signal icm_ics_ecc_block_iu0    : std_ulogic_vector(0 to 3);
signal icm_ics_load_tid         : std_ulogic_vector(0 to 3);
signal icm_ics_iu1_ecc_flush    : std_ulogic;
signal icm_ics_iu2_miss_match_prev : std_ulogic;
signal ics_icm_iu2_flush_tid    : std_ulogic_vector(0 to 3);
signal ics_icm_iu3_flush_tid    : std_ulogic_vector(0 to 3);
signal ics_icm_iu0_ifar0        : std_ulogic_vector(46 to 52);
signal ics_icm_iu0_ifar1        : std_ulogic_vector(46 to 52);
signal ics_icm_iu0_ifar2        : std_ulogic_vector(46 to 52);
signal ics_icm_iu0_ifar3        : std_ulogic_vector(46 to 52);
signal ics_icm_iu0_inval        : std_ulogic;
signal ics_icm_iu0_inval_addr   : std_ulogic_vector(52 to 57);
signal icm_icd_lru_addr         : std_ulogic_vector(52 to 57);
signal icm_icd_dir_inval        : std_ulogic;
signal icm_icd_dir_val          : std_ulogic;
signal icm_icd_data_write       : std_ulogic;
signal icm_icd_reload_addr      : std_ulogic_vector(52 to 59);
signal icm_icd_reload_data      : std_ulogic_vector(0 to 161);
signal icm_icd_reload_way       : std_ulogic_vector(0 to 3);
signal icm_icd_load_tid         : std_ulogic_vector(0 to 3);
signal icm_icd_load_addr        : EFF_IFAR;
signal icm_icd_load_2ucode      : std_ulogic;
signal icm_icd_load_2ucode_type : std_ulogic;
signal icm_icd_dir_write        : std_ulogic;
signal icm_icd_dir_write_addr   : std_ulogic_vector(REAL_IFAR'left to 57);
signal icm_icd_dir_write_endian : std_ulogic;
signal icm_icd_dir_write_way    : std_ulogic_vector(0 to 3);
signal icm_icd_lru_write        : std_ulogic;
signal icm_icd_lru_write_addr   : std_ulogic_vector(52 to 57);
signal icm_icd_lru_write_way    : std_ulogic_vector(0 to 3);
signal icm_icd_ecc_inval        : std_ulogic;
signal icm_icd_ecc_addr         : std_ulogic_vector(52 to 57);
signal icm_icd_ecc_way          : std_ulogic_vector(0 to 3);
signal icm_icd_iu3_ecc_fp_cancel: std_ulogic;
signal icm_icd_iu3_ecc_err      : std_ulogic;
signal icm_icd_any_reld_r2      : std_ulogic;
signal icm_icd_any_checkecc     : std_ulogic;
signal icd_icm_miss             : std_ulogic;
signal icd_icm_tid              : std_ulogic_vector(0 to 3);
signal icd_icm_addr_real        : REAL_IFAR;
signal icd_icm_addr_eff         : std_ulogic_vector(EFF_IFAR'left to 51);
signal icd_icm_wimge            : std_ulogic_vector(0 to 4);
signal icd_icm_userdef          : std_ulogic_vector(0 to 3);
signal icd_icm_2ucode           : std_ulogic;
signal icd_icm_2ucode_type      : std_ulogic;
signal icd_icm_iu3_erat_err     : std_ulogic;
signal icd_icm_iu2_inval        : std_ulogic;
signal icd_icm_ici              : std_ulogic;
signal icd_icm_any_iu2_valid    : std_ulogic;
signal icd_icm_row_lru          : std_ulogic_vector(0 to 2);
signal icd_icm_row_val          : std_ulogic_vector(0 to 3);
signal int_ic_bp_iu3_val        : std_ulogic_vector(0 to 3);
signal int_ic_bp_iu3_0_instr    : std_ulogic_vector(0 to 35);
signal int_ic_bp_iu3_1_instr    : std_ulogic_vector(0 to 35);
signal int_ic_bp_iu3_2_instr    : std_ulogic_vector(0 to 35);
signal int_ic_bp_iu3_3_instr    : std_ulogic_vector(0 to 35);
signal trigger_data_out_d       : std_ulogic_vector(0 to 11);
signal trigger_data_out_q       : std_ulogic_vector(0 to 11);
signal trace_data_out_d         : std_ulogic_vector(0 to 87);
signal trace_data_out_q         : std_ulogic_vector(0 to 87);
signal sel_dbg_data             : std_ulogic_vector(0 to 87);
signal dir_dbg_data0            : std_ulogic_vector(0 to 87);
signal dir_dbg_data1            : std_ulogic_vector(0 to 87);
signal dir_dbg_data2            : std_ulogic_vector(0 to 43);
signal dir_dbg_trigger0         : std_ulogic_vector(0 to 7);
signal dir_dbg_trigger1         : std_ulogic_vector(0 to 11);
signal miss_dbg_data0           : std_ulogic_vector(0 to 87);
signal miss_dbg_data1           : std_ulogic_vector(0 to 87);
signal miss_dbg_data2           : std_ulogic_vector(0 to 43);
signal miss_dbg_trigger         : std_ulogic_vector(0 to 11);
signal iu3_dbg_data             : std_ulogic_vector(0 to 87);
signal ierat_iu_debug_group0    : std_ulogic_vector(0 to 87);
signal ierat_iu_debug_group1    : std_ulogic_vector(0 to 87);
signal ierat_iu_debug_group2    : std_ulogic_vector(0 to 87);
signal ierat_iu_debug_group3    : std_ulogic_vector(0 to 87);
signal dbg_group0         : std_ulogic_vector(0 to 87);
signal dbg_group1         : std_ulogic_vector(0 to 87);
signal dbg_group2         : std_ulogic_vector(0 to 87);
signal dbg_group3         : std_ulogic_vector(0 to 87);
signal dbg_group4         : std_ulogic_vector(0 to 87);
signal dbg_group5         : std_ulogic_vector(0 to 87);
signal dbg_group6         : std_ulogic_vector(0 to 87);
signal dbg_group7         : std_ulogic_vector(0 to 87);
signal dbg_group8         : std_ulogic_vector(0 to 87);
signal dbg_group9         : std_ulogic_vector(0 to 87);
signal dbg_group10        : std_ulogic_vector(0 to 87);
signal dbg_group11        : std_ulogic_vector(0 to 87);
signal dbg_group12        : std_ulogic_vector(0 to 87);
signal dbg_group13        : std_ulogic_vector(0 to 87);
signal dbg_group14        : std_ulogic_vector(0 to 87);
signal dbg_group15        : std_ulogic_vector(0 to 87);
signal trg_group0         : std_ulogic_vector(0 to 11);
signal trg_group1         : std_ulogic_vector(0 to 11);
signal trg_group2         : std_ulogic_vector(0 to 11);
signal trg_group3         : std_ulogic_vector(0 to 11);
signal pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0    : std_ulogic;
signal pc_iu_func_sl_thold_0_b  : std_ulogic;
signal pc_iu_func_slp_sl_thold_1: std_ulogic;
signal pc_iu_func_slp_sl_thold_0: std_ulogic;
signal pc_iu_func_slp_sl_thold_0_b : std_ulogic;
signal pc_iu_time_sl_thold_1    : std_ulogic;
signal pc_iu_time_sl_thold_0    : std_ulogic;
signal pc_iu_abst_sl_thold_1    : std_ulogic;
signal pc_iu_abst_sl_thold_0    : std_ulogic;
signal pc_iu_abst_sl_thold_0_b  : std_ulogic;
signal pc_iu_abst_slp_sl_thold_1: std_ulogic;
signal pc_iu_abst_slp_sl_thold_0: std_ulogic;
signal pc_iu_repr_sl_thold_1    : std_ulogic;
signal pc_iu_repr_sl_thold_0    : std_ulogic;
signal pc_iu_ary_nsl_thold_1    : std_ulogic;
signal pc_iu_ary_nsl_thold_0    : std_ulogic;
signal pc_iu_ary_slp_nsl_thold_1: std_ulogic;
signal pc_iu_ary_slp_nsl_thold_0: std_ulogic;
signal pc_iu_regf_slp_sl_thold_1: std_ulogic;
signal pc_iu_regf_slp_sl_thold_0: std_ulogic;
signal regf_slat_slp_sl_thold_0_b: std_ulogic;
signal pc_iu_bolt_sl_thold_1    : std_ulogic;
signal pc_iu_bolt_sl_thold_0    : std_ulogic;
signal pc_iu_sg_1               : std_ulogic;
signal pc_iu_sg_0               : std_ulogic;
signal forcee                    : std_ulogic;
signal funcslp_force            : std_ulogic;
signal abst_force               : std_ulogic;
signal pc_iu_bo_enable_2        : std_ulogic;
signal ierat_func_scan_in       : std_ulogic_vector(0 to 1);
signal sel_func_scan_in         : std_ulogic;
signal dir_func_scan_in         : std_ulogic_vector(0 to 1);
signal miss_func_scan_in        : std_ulogic;
signal ierat_func_scan_out      : std_ulogic_vector(0 to 1);
signal sel_func_scan_out        : std_ulogic;
signal dir_func_scan_out        : std_ulogic_vector(0 to 1);
signal miss_func_scan_out       : std_ulogic;
signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);
signal tsiv                     : std_ulogic_vector(0 to 1);
signal tsov                     : std_ulogic_vector(0 to 1);
signal func_scan_in_cam         : std_ulogic;
signal func_scan_out_cam        : std_ulogic;
signal regf_scan_out_cam        : std_ulogic_vector(0 to 4);
signal ac_ccfg_scan_out_int     : std_ulogic;
signal event_bus_enable_d               : std_ulogic;
signal event_bus_enable_q               : std_ulogic;
signal trace_bus_enable_d               : std_ulogic;
signal trace_bus_enable_q               : std_ulogic;
signal debug_mux_ctrls_d                : std_ulogic_vector(0 to 15);
signal debug_mux_ctrls_q                : std_ulogic_vector(0 to 15);
signal tiup                             : std_ulogic;
signal act_dis                          : std_ulogic;
signal d_mode                           : std_ulogic;
signal mpw2_b                           : std_ulogic;
signal g6t_act_dis                      : std_ulogic;
signal cam_act_dis                      : std_ulogic;
begin
tiup <= '1';
act_dis <= '0';
d_mode  <= '0';
mpw2_b  <= '1';
g6t_act_dis <= '0';
cam_act_dis <= '0';
iuq_ic_ierat0 : entity work.iuq_ic_ierat
generic map(thdid_width         => 4,
            epn_width           => epn_width,
            rpn_width           => rpn_width,
            bcfg_epn_0to15      => bcfg_epn_0to15,
            bcfg_epn_16to31     => bcfg_epn_16to31,
            bcfg_epn_32to47     => bcfg_epn_32to47,
            bcfg_epn_48to51     => bcfg_epn_48to51,
            bcfg_rpn_22to31     => bcfg_rpn_22to31,
            bcfg_rpn_32to47     => bcfg_rpn_32to47,
            bcfg_rpn_48to51     => bcfg_rpn_48to51,
            rs_data_width       => rs_data_width,
            data_out_width      => data_out_width,
            expand_type         => expand_type)
port map(
     gnd                        => gnd,
     vdd                        => vdd,
     vcs                        => vcs,
     nclk                       => nclk,
     pc_iu_init_reset           => pc_iu_init_reset,
     tc_ccflush_dc              => tc_ac_ccflush_dc,
     tc_scan_dis_dc_b           => an_ac_scan_dis_dc_b,
     tc_scan_diag_dc            => an_ac_scan_diag_dc,
     tc_lbist_en_dc             => an_ac_lbist_en_dc,
     an_ac_atpg_en_dc           => an_ac_atpg_en_dc,
     an_ac_grffence_en_dc       => an_ac_grffence_en_dc,

     lcb_d_mode_dc              => d_mode,
     lcb_clkoff_dc_b            => clkoff_b,
     lcb_act_dis_dc             => act_dis,
     lcb_mpw1_dc_b              => mpw1_b,
     lcb_mpw2_dc_b              => mpw2_b,
     lcb_delay_lclkr_dc         => delay_lclkr,
     pc_iu_func_sl_thold_2      => pc_iu_func_sl_thold_2,
     pc_iu_func_slp_sl_thold_2  => pc_iu_func_slp_sl_thold_2,
     pc_iu_func_slp_nsl_thold_2 => pc_iu_func_slp_nsl_thold_2,
     pc_iu_cfg_slp_sl_thold_2   => pc_iu_cfg_slp_sl_thold_2,
     pc_iu_regf_slp_sl_thold_2  => pc_iu_regf_slp_sl_thold_2,
     pc_iu_time_sl_thold_2      => pc_iu_time_sl_thold_2,
     pc_iu_sg_2                 => pc_iu_sg_2,
     pc_iu_fce_2                => pc_iu_fce_2,

     cam_clkoff_b               => cam_clkoff_b,
     cam_act_dis                => cam_act_dis,
     cam_d_mode                 => cam_d_mode,
     cam_delay_lclkr            => cam_delay_lclkr,
     cam_mpw1_b                 => cam_mpw1_b,
     cam_mpw2_b                 => cam_mpw2_b,
     ac_func_scan_in            => ierat_func_scan_in,
     ac_func_scan_out           => ierat_func_scan_out,
     ac_ccfg_scan_in            => ac_ccfg_scan_in,
     ac_ccfg_scan_out           => ac_ccfg_scan_out_int,
     func_scan_in_cam           => func_scan_in_cam,
     func_scan_out_cam          => func_scan_out_cam,
     time_scan_in               => tsiv(0),
     time_scan_out              => tsov(0),
     regf_scan_in               => regf_scan_in,
     regf_scan_out              => regf_scan_out_cam,
     iu_ierat_iu0_val           => iu_ierat_iu0_val,
     iu_ierat_iu0_thdid         => iu_ierat_iu0_thdid,
     iu_ierat_iu0_ifar          => iu_ierat_iu0_ifar,
     iu_ierat_iu0_flush         => iu_ierat_iu0_flush,
     iu_ierat_iu1_flush         => iu_ierat_iu1_flush,
     iu_ierat_iu1_back_inv      => iu_ierat_iu1_back_inv,
     iu_ierat_ium1_back_inv     => iu_ierat_ium1_back_inv,
     spr_ic_clockgate_dis       => spr_ic_clockgate_dis(1),
     ierat_iu_iu2_rpn           => ierat_iu_iu2_rpn,
     ierat_iu_iu2_wimge         => ierat_iu_iu2_wimge,
     ierat_iu_iu2_u             => ierat_iu_iu2_u,
     ierat_iu_iu2_error         => ierat_iu_iu2_error,
     ierat_iu_iu2_miss          => ierat_iu_iu2_miss,
     ierat_iu_iu2_multihit      => ierat_iu_iu2_multihit,
     ierat_iu_iu2_isi           => ierat_iu_iu2_isi,
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
     xu_iu_ex1_ra_entry         => xu_iu_ex1_ra_entry,
     xu_iu_ex1_rb               => xu_iu_ex1_rb,
     xu_iu_flush                => xu_iu_flush,
     xu_rf1_flush               => xu_rf1_flush,
     xu_ex1_flush               => xu_ex1_flush,
     xu_ex2_flush               => xu_ex2_flush,
     xu_ex3_flush               => xu_ex3_flush,
     xu_ex4_flush               => xu_ex4_flush,
     xu_ex5_flush               => xu_ex5_flush,
     xu_iu_ex4_rs_data          => xu_iu_ex4_rs_data,
     xu_iu_msr_hv               => xu_iu_msr_hv,
     xu_iu_msr_pr               => xu_iu_msr_pr,
     xu_iu_msr_is               => xu_iu_msr_is,
     xu_iu_msr_cm               => xu_iu_msr_cm,
     xu_iu_hid_mmu_mode         => xu_iu_hid_mmu_mode,
     xu_iu_spr_ccr2_ifrat       => xu_iu_spr_ccr2_ifrat,
     xu_iu_spr_ccr2_ifratsc     => xu_iu_spr_ccr2_ifratsc,
     xu_iu_xucr4_mmu_mchk       => xu_iu_xucr4_mmu_mchk,
     ierat_iu_hold_req          => ierat_iu_hold_req,
     ierat_iu_iu2_flush_req     => ierat_iu_iu2_flush_req,
     iu_xu_ex4_data             => iu_xu_ex4_data,
     iu_xu_ierat_ex3_par_err    => iu_xu_ierat_ex3_par_err,
     iu_xu_ierat_ex4_par_err    => iu_xu_ierat_ex4_par_err,
     iu_xu_ierat_ex2_flush_req  => iu_xu_ierat_ex2_flush_req,
     iu_mm_ierat_req            => iu_mm_ierat_req,
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
     pc_iu_trace_bus_enable     => pc_iu_trace_bus_enable,
     ierat_iu_debug_group0      => ierat_iu_debug_group0,
     ierat_iu_debug_group1      => ierat_iu_debug_group1,
     ierat_iu_debug_group2      => ierat_iu_debug_group2,
     ierat_iu_debug_group3      => ierat_iu_debug_group3
);
iuq_ic_select0 : entity work.iuq_ic_select
generic map(expand_type     => expand_type)
port map(
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     pc_iu_func_sl_thold_0_b    => pc_iu_func_sl_thold_0_b,
     pc_iu_func_slp_sl_thold_0_b => pc_iu_func_slp_sl_thold_0_b,
     pc_iu_sg_0                 => pc_iu_sg_0,
     forcee => forcee,
     funcslp_force => funcslp_force,
     d_mode                     => d_mode,
     delay_lclkr                => delay_lclkr(0),
     mpw1_b                     => mpw1_b(0),
     mpw2_b                     => mpw2_b,
     an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b,
     func_scan_in               => sel_func_scan_in,
     func_scan_out              => sel_func_scan_out,
     ac_an_power_managed        => ac_an_power_managed,
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
     an_ac_back_inv             => an_ac_back_inv,
     an_ac_back_inv_addr        => an_ac_back_inv_addr,
     an_ac_back_inv_target      => an_ac_back_inv_target,
     an_ac_icbi_ack             => an_ac_icbi_ack,
     an_ac_icbi_ack_thread      => an_ac_icbi_ack_thread,
     spr_ic_clockgate_dis       => spr_ic_clockgate_dis(0),
     spr_ic_icbi_ack_en         => spr_ic_icbi_ack_en,
     spr_ic_idir_read           => spr_ic_idir_read,
     spr_ic_idir_row            => spr_ic_idir_row,
     spr_ic_pri_rand            => spr_ic_pri_rand,
     spr_ic_pri_rand_always     => spr_ic_pri_rand_always,
     spr_ic_pri_rand_flush      => spr_ic_pri_rand_flush,
     ic_perf_event_t0           => ic_perf_event_t0(2   to 3),
     ic_perf_event_t1           => ic_perf_event_t1(2   to 3),
     ic_perf_event_t2           => ic_perf_event_t2(2   to 3),
     ic_perf_event_t3           => ic_perf_event_t3(2   to 3),
     iu_ierat_iu0_val           => iu_ierat_iu0_val,
     iu_ierat_iu0_thdid         => iu_ierat_iu0_thdid,
     iu_ierat_iu0_ifar          => iu_ierat_iu0_ifar,
     iu_ierat_iu0_flush         => iu_ierat_iu0_flush,
     iu_ierat_iu1_flush         => iu_ierat_iu1_flush,
     iu_ierat_ium1_back_inv     => iu_ierat_ium1_back_inv,
     ierat_iu_hold_req          => ierat_iu_hold_req,
     ierat_iu_iu2_flush_req     => ierat_iu_iu2_flush_req,
     ierat_iu_iu2_miss          => ierat_iu_iu2_miss,
     icm_ics_iu0_preload_val    => icm_ics_iu0_preload_val,
     icm_ics_iu0_preload_tid    => icm_ics_iu0_preload_tid,
     icm_ics_iu0_preload_ifar   => icm_ics_iu0_preload_ifar,
     icm_ics_hold_thread        => icm_ics_hold_thread,
     icm_ics_hold_thread_dbg    => icm_ics_hold_thread_dbg,
     icm_ics_hold_iu0           => icm_ics_hold_iu0,
     icm_ics_ecc_block_iu0      => icm_ics_ecc_block_iu0,
     icm_ics_load_tid           => icm_ics_load_tid,
     icm_ics_iu1_ecc_flush      => icm_ics_iu1_ecc_flush,
     icm_ics_iu2_miss_match_prev=> icm_ics_iu2_miss_match_prev,
     ics_icm_iu2_flush_tid      => ics_icm_iu2_flush_tid,
     ics_icm_iu3_flush_tid      => ics_icm_iu3_flush_tid,
     ics_icm_iu0_ifar0          => ics_icm_iu0_ifar0,
     ics_icm_iu0_ifar1          => ics_icm_iu0_ifar1,
     ics_icm_iu0_ifar2          => ics_icm_iu0_ifar2,
     ics_icm_iu0_ifar3          => ics_icm_iu0_ifar3,
     ics_icm_iu0_inval          => ics_icm_iu0_inval,
     ics_icm_iu0_inval_addr     => ics_icm_iu0_inval_addr,
     ics_icd_dir_rd_act         => ics_icd_dir_rd_act,
     ics_icd_data_rd_act        => ics_icd_data_rd_act,
     ics_icd_iu0_valid          => ics_icd_iu0_valid,
     ics_icd_iu0_tid            => ics_icd_iu0_tid,
     ics_icd_iu0_ifar           => ics_icd_iu0_ifar,
     ics_icd_iu0_inval          => ics_icd_iu0_inval,
     ics_icd_iu0_2ucode         => ics_icd_iu0_2ucode,
     ics_icd_iu0_2ucode_type    => ics_icd_iu0_2ucode_type,
     ics_icd_iu0_spr_idir_read  => ics_icd_iu0_spr_idir_read,
     icd_ics_iu1_valid          => icd_ics_iu1_valid,
     icd_ics_iu1_tid            => icd_ics_iu1_tid,
     icd_ics_iu1_ifar           => icd_ics_iu1_ifar,
     icd_ics_iu1_2ucode         => icd_ics_iu1_2ucode,
     icd_ics_iu1_2ucode_type    => icd_ics_iu1_2ucode_type,
     ics_icd_all_flush_prev     => ics_icd_all_flush_prev,
     ics_icd_iu1_flush_tid      => ics_icd_iu1_flush_tid,
     ics_icd_iu2_flush_tid      => ics_icd_iu2_flush_tid,
     icd_ics_iu2_miss_flush_prev=> icd_ics_iu2_miss_flush_prev,
     icd_ics_iu2_ifar_eff       => icd_ics_iu2_ifar_eff,
     icd_ics_iu2_2ucode         => icd_ics_iu2_2ucode,
     icd_ics_iu2_2ucode_type    => icd_ics_iu2_2ucode_type,
     icd_ics_iu3_parity_flush   => icd_ics_iu3_parity_flush,
     icd_ics_iu3_ifar           => icd_ics_iu3_ifar,
     icd_ics_iu3_2ucode         => icd_ics_iu3_2ucode,
     icd_ics_iu3_2ucode_type    => icd_ics_iu3_2ucode_type,
     ic_bp_iu1_val              => ic_bp_iu1_val,
     ic_bp_iu1_tid              => ic_bp_iu1_tid,
     ic_bp_iu1_ifar             => ic_bp_iu1_ifar,
     bp_ib_iu4_ifar             => bp_ib_iu4_ifar,
     bp_ic_iu5_hold_tid         => bp_ic_iu5_hold_tid,
     bp_ic_iu5_redirect_tid     => bp_ic_iu5_redirect_tid,
     bp_ic_iu5_redirect_ifar    => bp_ic_iu5_redirect_ifar,
     ib_ic_empty                => ib_ic_empty,
     ib_ic_below_water          => ib_ic_below_water,
     ib_ic_iu5_redirect_tid     => ib_ic_iu5_redirect_tid,
     ic_fdep_icbi_ack           => ic_fdep_icbi_ack,
     uc_flush_tid               => uc_flush_tid,
     uc_ic_hold_thread          => uc_ic_hold_thread,
     event_bus_enable           => event_bus_enable_q,
     sel_dbg_data               => sel_dbg_data
);
iuq_ic_dir0 : entity work.iuq_ic_dir
generic map(expand_type     => expand_type)
port map(
     vcs                        => vcs,
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     pc_iu_func_sl_thold_0_b    => pc_iu_func_sl_thold_0_b,
     pc_iu_func_slp_sl_thold_0_b => pc_iu_func_slp_sl_thold_0_b,
     pc_iu_time_sl_thold_0      => pc_iu_time_sl_thold_0,
     pc_iu_repr_sl_thold_0      => pc_iu_repr_sl_thold_0,
     pc_iu_abst_sl_thold_0      => pc_iu_abst_sl_thold_0,
     pc_iu_abst_sl_thold_0_b    => pc_iu_abst_sl_thold_0_b,
     pc_iu_abst_slp_sl_thold_0  => pc_iu_abst_slp_sl_thold_0,
     pc_iu_ary_nsl_thold_0      => pc_iu_ary_nsl_thold_0,
     pc_iu_ary_slp_nsl_thold_0  => pc_iu_ary_slp_nsl_thold_0,
     pc_iu_bolt_sl_thold_0      => pc_iu_bolt_sl_thold_0,
     pc_iu_sg_0                 => pc_iu_sg_0,
     pc_iu_sg_1                 => pc_iu_sg_1,
     forcee => forcee,
     funcslp_force => funcslp_force,
     abst_force => abst_force,
     d_mode                     => d_mode,
     delay_lclkr                => delay_lclkr(0),
     mpw1_b                     => mpw1_b(0),
     mpw2_b                     => mpw2_b,
     clkoff_b                   => clkoff_b,
     act_dis                    => act_dis,
     g8t_clkoff_b               => g8t_clkoff_b,
     g8t_d_mode                 => g8t_d_mode,
     g8t_delay_lclkr            => g8t_delay_lclkr,
     g8t_mpw1_b                 => g8t_mpw1_b,
     g8t_mpw2_b                 => g8t_mpw2_b,
     g6t_clkoff_b               => g6t_clkoff_b,
     g6t_act_dis                => g6t_act_dis,
     g6t_d_mode                 => g6t_d_mode,
     g6t_delay_lclkr            => g6t_delay_lclkr,
     g6t_mpw1_b                 => g6t_mpw1_b,
     g6t_mpw2_b                 => g6t_mpw2_b,
     tc_ac_ccflush_dc           => tc_ac_ccflush_dc,
     an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b,
     an_ac_scan_diag_dc         => an_ac_scan_diag_dc,
     func_scan_in               => dir_func_scan_in,
     time_scan_in               => tsiv(1),
     repr_scan_in               => repr_scan_in,
     abst_scan_in               => abst_scan_in,
     func_scan_out              => dir_func_scan_out,
     time_scan_out              => tsov(1),
     repr_scan_out              => repr_scan_out,
     abst_scan_out              => abst_scan_out,
     spr_ic_cls                 => spr_ic_cls,
     spr_ic_clockgate_dis       => spr_ic_clockgate_dis(0),
     spr_ic_idir_way            => spr_ic_idir_way,
     ic_spr_idir_done           => ic_spr_idir_done,
     ic_spr_idir_lru            => ic_spr_idir_lru,
     ic_spr_idir_parity         => ic_spr_idir_parity,
     ic_spr_idir_endian         => ic_spr_idir_endian,
     ic_spr_idir_valid          => ic_spr_idir_valid,
     ic_spr_idir_tag            => ic_spr_idir_tag,
     ic_perf_event_t0           => ic_perf_event_t0(4   to 6),
     ic_perf_event_t1           => ic_perf_event_t1(4   to 6),
     ic_perf_event_t2           => ic_perf_event_t2(4   to 6),
     ic_perf_event_t3           => ic_perf_event_t3(4   to 6),
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
     pc_iu_abist_waddr_0        => pc_iu_abist_waddr_0,
     pc_iu_abist_raddr_0        => pc_iu_abist_raddr_0,
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
     pc_iu_bo_enable_2          => pc_iu_bo_enable_2,
     pc_iu_bo_reset             => pc_iu_bo_reset,
     pc_iu_bo_unload            => pc_iu_bo_unload,
     pc_iu_bo_repair            => pc_iu_bo_repair,
     pc_iu_bo_shdata            => pc_iu_bo_shdata,
     pc_iu_bo_select            => pc_iu_bo_select,
     iu_pc_bo_fail              => iu_pc_bo_fail,
     iu_pc_bo_diagout           => iu_pc_bo_diagout,
     xu_iu_ici                  => xu_iu_ici,
     iu_mm_ierat_epn            => iu_mm_ierat_epn,
     iu_ierat_iu1_back_inv      => iu_ierat_iu1_back_inv,
     ierat_iu_iu2_rpn           => ierat_iu_iu2_rpn,
     ierat_iu_iu2_wimge         => ierat_iu_iu2_wimge,
     ierat_iu_iu2_u             => ierat_iu_iu2_u,
     ierat_iu_iu2_error         => ierat_iu_iu2_error,
     ierat_iu_iu2_miss          => ierat_iu_iu2_miss,
     ierat_iu_iu2_multihit      => ierat_iu_iu2_multihit,
     ierat_iu_iu2_isi           => ierat_iu_iu2_isi,
     ics_icd_dir_rd_act         => ics_icd_dir_rd_act,
     ics_icd_data_rd_act        => ics_icd_data_rd_act,
     ics_icd_iu0_valid          => ics_icd_iu0_valid,
     ics_icd_iu0_tid            => ics_icd_iu0_tid,
     ics_icd_iu0_ifar           => ics_icd_iu0_ifar,
     ics_icd_iu0_inval          => ics_icd_iu0_inval,
     ics_icd_iu0_2ucode         => ics_icd_iu0_2ucode,
     ics_icd_iu0_2ucode_type    => ics_icd_iu0_2ucode_type,
     ics_icd_iu0_spr_idir_read  => ics_icd_iu0_spr_idir_read,
     icd_ics_iu1_valid          => icd_ics_iu1_valid,
     icd_ics_iu1_tid            => icd_ics_iu1_tid,
     icd_ics_iu1_ifar           => icd_ics_iu1_ifar,
     icd_ics_iu1_2ucode         => icd_ics_iu1_2ucode,
     icd_ics_iu1_2ucode_type    => icd_ics_iu1_2ucode_type,
     ics_icd_all_flush_prev     => ics_icd_all_flush_prev,
     ics_icd_iu1_flush_tid      => ics_icd_iu1_flush_tid,
     ics_icd_iu2_flush_tid      => ics_icd_iu2_flush_tid,
     icd_ics_iu2_miss_flush_prev=> icd_ics_iu2_miss_flush_prev,
     icd_ics_iu2_ifar_eff       => icd_ics_iu2_ifar_eff,
     icd_ics_iu2_2ucode         => icd_ics_iu2_2ucode,
     icd_ics_iu2_2ucode_type    => icd_ics_iu2_2ucode_type,
     icd_ics_iu3_parity_flush   => icd_ics_iu3_parity_flush,
     icd_ics_iu3_ifar           => icd_ics_iu3_ifar,
     icd_ics_iu3_2ucode         => icd_ics_iu3_2ucode,
     icd_ics_iu3_2ucode_type    => icd_ics_iu3_2ucode_type,
     icm_icd_lru_addr           => icm_icd_lru_addr,
     icm_icd_dir_inval          => icm_icd_dir_inval,
     icm_icd_dir_val            => icm_icd_dir_val,
     icm_icd_data_write         => icm_icd_data_write,
     icm_icd_reload_addr        => icm_icd_reload_addr,
     icm_icd_reload_data        => icm_icd_reload_data,
     icm_icd_reload_way         => icm_icd_reload_way,
     icm_icd_load_tid           => icm_icd_load_tid,
     icm_icd_load_addr          => icm_icd_load_addr,
     icm_icd_load_2ucode        => icm_icd_load_2ucode,
     icm_icd_load_2ucode_type   => icm_icd_load_2ucode_type,
     icm_icd_dir_write          => icm_icd_dir_write,
     icm_icd_dir_write_addr     => icm_icd_dir_write_addr,
     icm_icd_dir_write_endian   => icm_icd_dir_write_endian,
     icm_icd_dir_write_way      => icm_icd_dir_write_way,
     icm_icd_lru_write          => icm_icd_lru_write,
     icm_icd_lru_write_addr     => icm_icd_lru_write_addr,
     icm_icd_lru_write_way      => icm_icd_lru_write_way,
     icm_icd_ecc_inval          => icm_icd_ecc_inval,
     icm_icd_ecc_addr           => icm_icd_ecc_addr,
     icm_icd_ecc_way            => icm_icd_ecc_way,
     icm_icd_iu3_ecc_fp_cancel  => icm_icd_iu3_ecc_fp_cancel,
     icm_icd_iu3_ecc_err        => icm_icd_iu3_ecc_err,
     icm_icd_any_reld_r2        => icm_icd_any_reld_r2,
     icm_icd_any_checkecc       => icm_icd_any_checkecc,
     icd_icm_miss               => icd_icm_miss,
     icd_icm_tid                => icd_icm_tid,
     icd_icm_addr_real          => icd_icm_addr_real,
     icd_icm_addr_eff           => icd_icm_addr_eff,
     icd_icm_wimge              => icd_icm_wimge,
     icd_icm_userdef            => icd_icm_userdef,
     icd_icm_2ucode             => icd_icm_2ucode,
     icd_icm_2ucode_type        => icd_icm_2ucode_type,
     icd_icm_iu3_erat_err       => icd_icm_iu3_erat_err,
     icd_icm_iu2_inval          => icd_icm_iu2_inval,
     icd_icm_ici                => icd_icm_ici,
     icd_icm_any_iu2_valid      => icd_icm_any_iu2_valid,
     icd_icm_row_lru            => icd_icm_row_lru,
     icd_icm_row_val            => icd_icm_row_val,
     ic_bp_iu3_val              => int_ic_bp_iu3_val,
     ic_bp_iu3_tid              => ic_bp_iu3_tid,
     ic_bp_iu3_ifar             => ic_bp_iu3_ifar,
     ic_bp_iu3_2ucode           => ic_bp_iu3_2ucode,
     ic_bp_iu3_2ucode_type      => ic_bp_iu3_2ucode_type,
     ic_bp_iu3_error            => ic_bp_iu3_error,
     ic_bp_iu3_flush            => ic_bp_iu3_flush,
     ic_bp_iu3_0_instr          => int_ic_bp_iu3_0_instr,
     ic_bp_iu3_1_instr          => int_ic_bp_iu3_1_instr,
     ic_bp_iu3_2_instr          => int_ic_bp_iu3_2_instr,
     ic_bp_iu3_3_instr          => int_ic_bp_iu3_3_instr,
     event_bus_enable           => event_bus_enable_q,
     trace_bus_enable           => trace_bus_enable_q,
     dir_dbg_data0              => dir_dbg_data0,
     dir_dbg_data1              => dir_dbg_data1,
     dir_dbg_data2              => dir_dbg_data2,
     dir_dbg_trigger0           => dir_dbg_trigger0,
     dir_dbg_trigger1           => dir_dbg_trigger1
);
ic_bp_iu3_val     <= int_ic_bp_iu3_val;
ic_bp_iu3_0_instr <= int_ic_bp_iu3_0_instr;
ic_bp_iu3_1_instr <= int_ic_bp_iu3_1_instr;
ic_bp_iu3_2_instr <= int_ic_bp_iu3_2_instr;
ic_bp_iu3_3_instr <= int_ic_bp_iu3_3_instr;
iuq_ic_miss0 : entity work.iuq_ic_miss
generic map(expand_type           => expand_type)
port map(
      vdd                       => vdd,
      gnd                       => gnd,
      nclk                      => nclk,
      pc_iu_func_sl_thold_0_b   => pc_iu_func_sl_thold_0_b,
      pc_iu_sg_0                => pc_iu_sg_0,
      forcee => forcee,
      d_mode                    => d_mode,
      delay_lclkr               => delay_lclkr(0),
      mpw1_b                    => mpw1_b(0),
      mpw2_b                    => mpw2_b,
      scan_in                   => miss_func_scan_in,
      scan_out                  => miss_func_scan_out,
      xu_iu_flush               => xu_iu_flush,
      bp_ic_iu5_redirect_tid    => bp_ic_iu5_redirect_tid,
      ics_icm_iu0_ifar0         => ics_icm_iu0_ifar0,
      ics_icm_iu0_ifar1         => ics_icm_iu0_ifar1,
      ics_icm_iu0_ifar2         => ics_icm_iu0_ifar2,
      ics_icm_iu0_ifar3         => ics_icm_iu0_ifar3,
      ics_icm_iu0_inval         => ics_icm_iu0_inval,
      ics_icm_iu0_inval_addr    => ics_icm_iu0_inval_addr,
      ics_icm_iu2_flush_tid     => ics_icm_iu2_flush_tid,
      ics_icm_iu3_flush_tid     => ics_icm_iu3_flush_tid,
      icm_ics_hold_thread       => icm_ics_hold_thread,
      icm_ics_hold_thread_dbg   => icm_ics_hold_thread_dbg,
      icm_ics_hold_iu0          => icm_ics_hold_iu0,
      icm_ics_ecc_block_iu0     => icm_ics_ecc_block_iu0,
      icm_ics_load_tid          => icm_ics_load_tid,
      icm_ics_iu1_ecc_flush     => icm_ics_iu1_ecc_flush,
      icm_ics_iu2_miss_match_prev => icm_ics_iu2_miss_match_prev,
      icm_ics_iu0_preload_val   => icm_ics_iu0_preload_val,
      icm_ics_iu0_preload_tid   => icm_ics_iu0_preload_tid,
      icm_ics_iu0_preload_ifar  => icm_ics_iu0_preload_ifar,
      icm_icd_lru_addr          => icm_icd_lru_addr,
      icm_icd_dir_inval         => icm_icd_dir_inval,
      icm_icd_dir_val           => icm_icd_dir_val,
      icm_icd_data_write        => icm_icd_data_write,
      icm_icd_reload_addr       => icm_icd_reload_addr,
      icm_icd_reload_data       => icm_icd_reload_data,
      icm_icd_reload_way        => icm_icd_reload_way,
      icm_icd_load_tid          => icm_icd_load_tid,
      icm_icd_load_addr         => icm_icd_load_addr,
      icm_icd_load_2ucode       => icm_icd_load_2ucode,
      icm_icd_load_2ucode_type  => icm_icd_load_2ucode_type,
      icm_icd_dir_write         => icm_icd_dir_write,
      icm_icd_dir_write_addr    => icm_icd_dir_write_addr,
      icm_icd_dir_write_endian  => icm_icd_dir_write_endian,
      icm_icd_dir_write_way     => icm_icd_dir_write_way,
      icm_icd_lru_write         => icm_icd_lru_write,
      icm_icd_lru_write_addr    => icm_icd_lru_write_addr,
      icm_icd_lru_write_way     => icm_icd_lru_write_way,
      icm_icd_ecc_inval         => icm_icd_ecc_inval,
      icm_icd_ecc_addr          => icm_icd_ecc_addr,
      icm_icd_ecc_way           => icm_icd_ecc_way,
      icm_icd_iu3_ecc_fp_cancel => icm_icd_iu3_ecc_fp_cancel,
      icm_icd_iu3_ecc_err       => icm_icd_iu3_ecc_err,
      icm_icd_any_reld_r2       => icm_icd_any_reld_r2,
      icm_icd_any_checkecc      => icm_icd_any_checkecc,
      icd_icm_miss              => icd_icm_miss,
      icd_icm_tid               => icd_icm_tid,
      icd_icm_addr_real         => icd_icm_addr_real,
      icd_icm_addr_eff          => icd_icm_addr_eff,
      icd_icm_wimge             => icd_icm_wimge,
      icd_icm_userdef           => icd_icm_userdef,
      icd_icm_2ucode            => icd_icm_2ucode,
      icd_icm_2ucode_type       => icd_icm_2ucode_type,
      icd_icm_iu3_erat_err      => icd_icm_iu3_erat_err,
      icd_icm_iu2_inval         => icd_icm_iu2_inval,
      icd_icm_ici               => icd_icm_ici,
      icd_icm_any_iu2_valid     => icd_icm_any_iu2_valid,
      icd_icm_row_lru           => icd_icm_row_lru,
      icd_icm_row_val           => icd_icm_row_val,
      ic_fdep_load_quiesce      => ic_fdep_load_quiesce,
      iu_mm_lmq_empty           => iu_mm_lmq_empty,
      ic_perf_event_t0          => ic_perf_event_t0(0   to 1),
      ic_perf_event_t1          => ic_perf_event_t1(0   to 1),
      ic_perf_event_t2          => ic_perf_event_t2(0   to 1),
      ic_perf_event_t3          => ic_perf_event_t3(0   to 1),
      an_ac_reld_data_vld       => an_ac_reld_data_vld,
      an_ac_reld_core_tag       => an_ac_reld_core_tag,
      an_ac_reld_qw             => an_ac_reld_qw,
      an_ac_reld_data           => an_ac_reld_data,
      an_ac_reld_ecc_err        => an_ac_reld_ecc_err,
      an_ac_reld_ecc_err_ue     => an_ac_reld_ecc_err_ue,
      spr_ic_bp_config          => spr_ic_bp_config,
      spr_ic_cls                => spr_ic_cls,
      spr_ic_clockgate_dis      => spr_ic_clockgate_dis(0),
      iu_xu_request             => iu_xu_request,
      iu_xu_thread              => iu_xu_thread,
      iu_xu_ra                  => iu_xu_ra,
      iu_xu_wimge               => iu_xu_wimge,
      iu_xu_userdef             => iu_xu_userdef,
      event_bus_enable          => event_bus_enable_q,
      trace_bus_enable          => trace_bus_enable_q,
      miss_dbg_data0            => miss_dbg_data0,
      miss_dbg_data1            => miss_dbg_data1,
      miss_dbg_data2            => miss_dbg_data2,
      miss_dbg_trigger          => miss_dbg_trigger
);
-------------------------------------------------
-- Debug
-------------------------------------------------
iu3_dbg_data(0 to 21)           <= int_ic_bp_iu3_val(0) & int_ic_bp_iu3_0_instr(0 to 5) & int_ic_bp_iu3_0_instr(21 to 31) & int_ic_bp_iu3_0_instr(32 to 35);
iu3_dbg_data(22 to 43)          <= int_ic_bp_iu3_val(1) & int_ic_bp_iu3_1_instr(0 to 5) & int_ic_bp_iu3_1_instr(21 to 31) & int_ic_bp_iu3_1_instr(32 to 35);
iu3_dbg_data(44 to 65)          <= int_ic_bp_iu3_val(2) & int_ic_bp_iu3_2_instr(0 to 5) & int_ic_bp_iu3_2_instr(21 to 31) & int_ic_bp_iu3_2_instr(32 to 35);
iu3_dbg_data(66 to 87)          <= int_ic_bp_iu3_val(3) & int_ic_bp_iu3_3_instr(0 to 5) & int_ic_bp_iu3_3_instr(21 to 31) & int_ic_bp_iu3_3_instr(32 to 35);
dbg_group0     <= sel_dbg_data;
dbg_group1     <= dir_dbg_data0;
dbg_group2     <= dir_dbg_data1;
dbg_group3     <= dir_dbg_data2 & miss_dbg_data2;
dbg_group4     <= miss_dbg_data0;
dbg_group5     <= miss_dbg_data1;
dbg_group6     <= iu3_dbg_data;
dbg_group7     <= uc_dbg_data;
dbg_group8     <= ierat_iu_debug_group0;
dbg_group9     <= ierat_iu_debug_group1;
dbg_group10    <= ierat_iu_debug_group2;
dbg_group11    <= ierat_iu_debug_group3;
dbg_group12    <= (others => '0');
dbg_group13    <= (others => '0');
dbg_group14    <= (others => '0');
dbg_group15    <= (others => '0');
trg_group0     <= sel_dbg_data(65 to 66) &      
                  dir_dbg_trigger0 &
                  miss_dbg_trigger(10) & miss_dbg_trigger(7);
trg_group1     <= dir_dbg_trigger1;
trg_group2     <= miss_dbg_trigger;
trg_group3     <= (others => '0');
dbg_mux0: entity clib.c_debug_mux16
  port map(
     vd              => vdd,
     gd              => gnd,

     select_bits     => debug_mux_ctrls_q,
     trace_data_in   => debug_data_in,
     trigger_data_in => trace_triggers_in,

     dbg_group0      => dbg_group0,
     dbg_group1      => dbg_group1,
     dbg_group2      => dbg_group2,
     dbg_group3      => dbg_group3,
     dbg_group4      => dbg_group4,
     dbg_group5      => dbg_group5,
     dbg_group6      => dbg_group6,
     dbg_group7      => dbg_group7,
     dbg_group8      => dbg_group8,
     dbg_group9      => dbg_group9,
     dbg_group10     => dbg_group10,
     dbg_group11     => dbg_group11,
     dbg_group12     => dbg_group12,
     dbg_group13     => dbg_group13,
     dbg_group14     => dbg_group14,
     dbg_group15     => dbg_group15,

     trg_group0      => trg_group0,
     trg_group1      => trg_group1,
     trg_group2      => trg_group2,
     trg_group3      => trg_group3,

     trace_data_out  => trace_data_out_d,
     trigger_data_out=> trigger_data_out_d
);
trace_triggers_out      <= trigger_data_out_q;
debug_data_out          <= trace_data_out_q;
-----------------------------------------------------------------------
-- Debug & Performance Latches
-----------------------------------------------------------------------
event_bus_enable_d <= pc_iu_event_bus_enable;
trace_bus_enable_d <= pc_iu_trace_bus_enable;
debug_mux_ctrls_d  <= pc_iu_debug_mux_ctrls;
event_bus_enable_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr(0),
            mpw1_b      => mpw1_b(0),
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(event_bus_enable_offset),
            scout   => sov(event_bus_enable_offset),
            din     => event_bus_enable_d,
            dout    => event_bus_enable_q);
trace_enable_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr(0),
            mpw1_b      => mpw1_b(0),
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => trace_bus_enable_d,
            dout    => trace_bus_enable_q);
debug_mux_ctrls_reg: tri_rlmreg_p
  generic map (width => debug_mux_ctrls_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr(0),
            mpw1_b      => mpw1_b(0),
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux_ctrls_q'length-1),
            scout   => sov(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux_ctrls_q'length-1),
            din     => debug_mux_ctrls_d,
            dout    => debug_mux_ctrls_q);
dbg_trigger_data_reg: tri_rlmreg_p
  generic map (width => trigger_data_out_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr(0),
            mpw1_b      => mpw1_b(0),
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            scout   => sov(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            din     => trigger_data_out_d,
            dout    => trigger_data_out_q);
dbg_trace_data_reg: tri_rlmreg_p
  generic map (width => trace_data_out_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr(0),
            mpw1_b      => mpw1_b(0),
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(trace_data_out_offset to trace_data_out_offset + trace_data_out_q'length-1),
            scout   => sov(trace_data_out_offset to trace_data_out_offset + trace_data_out_q'length-1),
            din     => trace_data_out_d,
            dout    => trace_data_out_q);
-------------------------------------------------
-- pervasive
-------------------------------------------------
perv_3to2_reg: tri_plat
  generic map (width => 1, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_bo_enable_3,
            q(0)        => pc_iu_bo_enable_2);
perv_2to1_reg: tri_plat
  generic map (width => 11, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_2,
            din(1)      => pc_iu_func_slp_sl_thold_2,
            din(2)      => pc_iu_time_sl_thold_2,
            din(3)      => pc_iu_repr_sl_thold_2,
            din(4)      => pc_iu_abst_sl_thold_2,
            din(5)      => pc_iu_abst_slp_sl_thold_2,
            din(6)      => pc_iu_ary_nsl_thold_2,
            din(7)      => pc_iu_ary_slp_nsl_thold_2,
            din(8)      => pc_iu_regf_slp_sl_thold_2,
            din(9)      => pc_iu_bolt_sl_thold_2,
            din(10)     => pc_iu_sg_2,
            q(0)        => pc_iu_func_sl_thold_1,
            q(1)        => pc_iu_func_slp_sl_thold_1,
            q(2)        => pc_iu_time_sl_thold_1,
            q(3)        => pc_iu_repr_sl_thold_1,
            q(4)        => pc_iu_abst_sl_thold_1,
            q(5)        => pc_iu_abst_slp_sl_thold_1,
            q(6)        => pc_iu_ary_nsl_thold_1,
            q(7)        => pc_iu_ary_slp_nsl_thold_1,
            q(8)        => pc_iu_regf_slp_sl_thold_1,
            q(9)        => pc_iu_bolt_sl_thold_1,
            q(10)       => pc_iu_sg_1);
perv_1to0_reg: tri_plat
  generic map (width => 11, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_1,
            din(1)      => pc_iu_func_slp_sl_thold_1,
            din(2)      => pc_iu_time_sl_thold_1,
            din(3)      => pc_iu_repr_sl_thold_1,
            din(4)      => pc_iu_abst_sl_thold_1,
            din(5)      => pc_iu_abst_slp_sl_thold_1,
            din(6)      => pc_iu_ary_nsl_thold_1,
            din(7)      => pc_iu_ary_slp_nsl_thold_1,
            din(8)      => pc_iu_regf_slp_sl_thold_1,
            din(9)      => pc_iu_bolt_sl_thold_1,
            din(10)     => pc_iu_sg_1,
            q(0)        => pc_iu_func_sl_thold_0,
            q(1)        => pc_iu_func_slp_sl_thold_0,
            q(2)        => pc_iu_time_sl_thold_0,
            q(3)        => pc_iu_repr_sl_thold_0,
            q(4)        => pc_iu_abst_sl_thold_0,
            q(5)        => pc_iu_abst_slp_sl_thold_0,
            q(6)        => pc_iu_ary_nsl_thold_0,
            q(7)        => pc_iu_ary_slp_nsl_thold_0,
            q(8)        => pc_iu_regf_slp_sl_thold_0,
            q(9)        => pc_iu_bolt_sl_thold_0,
            q(10)       => pc_iu_sg_0);
perv_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_func_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee => forcee,
            thold_b     => pc_iu_func_sl_thold_0_b);
func_slp_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_func_slp_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee => funcslp_force,
            thold_b     => pc_iu_func_slp_sl_thold_0_b);
abst_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_abst_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee => abst_force,
            thold_b     => pc_iu_abst_sl_thold_0_b);
-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
ierat_func_scan_in(0)   <= func_scan_in(0);
func_scan_out(0)        <= ierat_func_scan_out(0) and an_ac_scan_dis_dc_b;
siv(0 to scan_right)    <= sov(1 to scan_right) & func_scan_in(1);
func_scan_in_cam        <= sov(0);
sel_func_scan_in        <= func_scan_out_cam;
func_scan_out(1)        <= sel_func_scan_out and an_ac_scan_dis_dc_b;
dir_func_scan_in(1)     <= func_scan_in(2);
func_scan_out(2)        <= dir_func_scan_out(1) and an_ac_scan_dis_dc_b;
miss_func_scan_in       <= func_scan_in(3);
ierat_func_scan_in(1)   <= miss_func_scan_out;
func_scan_out(3)        <= ierat_func_scan_out(1) and an_ac_scan_dis_dc_b;
dir_func_scan_in(0)     <= func_scan_in(4);
func_scan_out(4)        <= dir_func_scan_out(0) and an_ac_scan_dis_dc_b;
ac_ccfg_scan_out <= ac_ccfg_scan_out_int and an_ac_scan_dis_dc_b;
tsiv <= time_scan_in & tsov(0);
time_scan_out <= tsov(1) and an_ac_scan_dis_dc_b;
regf_slat_slp_sl_thold_0_b <= not pc_iu_regf_slp_sl_thold_0;
regf_scan_latch: entity tri.tri_regs
  generic map (width => 5, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            forcee => pc_iu_sg_0,
            thold_b     => regf_slat_slp_sl_thold_0_b,
            delay_lclkr => delay_lclkr(0),
            scin        => regf_scan_out_cam,
            scout       => regf_scan_out,
            dout        => open );
end iuq_ic;
