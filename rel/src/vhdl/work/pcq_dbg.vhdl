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
library ibm,clib;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity pcq_dbg is
generic(expand_type             : integer := 2          
);         
port(
    vdd                         : inout power_logic;
    gnd                         : inout power_logic;
    nclk                        : in    clk_logic;
    scan_dis_dc_b               : in    std_ulogic;
    lcb_clkoff_dc_b             : in    std_ulogic;
    lcb_mpw1_dc_b               : in    std_ulogic;
    lcb_mpw2_dc_b               : in    std_ulogic;
    lcb_delay_lclkr_dc          : in    std_ulogic;
    lcb_act_dis_dc              : in    std_ulogic;
    pc_pc_func_slp_sl_thold_0   : in    std_ulogic;
    pc_pc_sg_0                  : in    std_ulogic;
    func_scan_in                : in    std_ulogic;
    func_scan_out               : out   std_ulogic;
    debug_bus_out               : out   std_ulogic_vector(0 to 87);
    trace_triggers_out          : out   std_ulogic_vector(0 to 11);
    debug_bus_in                : in    std_ulogic_vector(0 to 87);
    trace_triggers_in           : in    std_ulogic_vector(0 to 11);
    rg_db_trace_bus_enable      : in    std_ulogic;
    rg_db_debug_mux_ctrls       : in    std_ulogic_vector(0 to 15);
    ck_db_dbg_clks_ctrls        : in    std_ulogic_vector(0 to 13);
    rg_db_dbg_scom_rdata        : in    std_ulogic_vector(0 to 63);
    rg_db_dbg_scom_wdata        : in    std_ulogic_vector(0 to 63);
    rg_db_dbg_scom_decaddr      : in    std_ulogic_vector(0 to 63);
    rg_db_dbg_scom_misc         : in    std_ulogic_vector(0 to 8);
    rg_db_dbg_ram_thrctl        : in    std_ulogic_vector(0 to 20);
    rg_db_dbg_fir0_err          : in    std_ulogic_vector(0 to 31);
    rg_db_dbg_fir1_err          : in    std_ulogic_vector(0 to 30);
    rg_db_dbg_fir2_err          : in    std_ulogic_vector(0 to 21);
    rg_db_dbg_fir_misc          : in    std_ulogic_vector(0 to 35);
    ct_db_dbg_ctrls             : in    std_ulogic_vector(0 to 36);
    rg_db_dbg_spr               : in    std_ulogic_vector(0 to 46);
    ac_an_event_bus             : out   std_ulogic_vector(0 to 7);
    ac_an_fu_bypass_events      : out   std_ulogic_vector(0 to 7);
    ac_an_iu_bypass_events      : out   std_ulogic_vector(0 to 7);
    ac_an_mm_bypass_events      : out   std_ulogic_vector(0 to 7);
    ac_an_lsu_bypass_events     : out   std_ulogic_vector(0 to 7);
    rg_db_event_bus_enable      : in    std_ulogic;
    rg_db_event_mux_ctrls       : in    std_ulogic_vector(0 to 23);
    fu_pc_event_data            : in    std_ulogic_vector(0 to 7);
    iu_pc_event_data            : in    std_ulogic_vector(0 to 7);
    mm_pc_event_data            : in    std_ulogic_vector(0 to 7);
    xu_pc_event_data            : in    std_ulogic_vector(0 to 7);
    lsu_pc_event_data           : in    std_ulogic_vector(0 to 7);
    ac_pc_trace_to_perfcntr     : in    std_ulogic_vector(0 to 7)
);
-- synopsys translate_off


-- synopsys translate_on
end pcq_dbg;

architecture pcq_dbg of pcq_dbg is
constant fuevents_size          : positive := 8;
constant iuevents_size          : positive := 8;
constant mmevents_size          : positive := 8;
constant xuevents_size          : positive := 8;
constant lsuevents_size         : positive := 8;
constant trcevents_size         : positive := 8;
constant eventbus_size          : positive := 8;
constant scrdata_size           : positive := 64;
constant scwdata_size           : positive := 64;
constant scmisc_size            : positive := 3;
constant ramthrctl_size         : positive := 4;
constant traceout_size          : positive := 88;
constant triggout_size          : positive := 12;

constant fuevents_offset        : natural := 0;
constant fubypass_offset        : natural := fuevents_offset + fuevents_size;
constant iuevents_offset        : natural := fubypass_offset + fuevents_size;
constant iubypass_offset        : natural := iuevents_offset + iuevents_size;
constant mmevents_offset        : natural := iubypass_offset + iuevents_size;
constant mmbypass_offset        : natural := mmevents_offset + mmevents_size;
constant xuevents_offset        : natural := mmbypass_offset + mmevents_size;
constant lsuevents_offset       : natural := xuevents_offset + xuevents_size;
constant lsubypass_offset       : natural := lsuevents_offset + lsuevents_size;
constant trcevents_offset       : natural := lsubypass_offset + lsuevents_size;
constant eventbus_offset        : natural := trcevents_offset + trcevents_size;
constant scrdata_offset         : natural := eventbus_offset + eventbus_size;
constant scwdata_offset         : natural := scrdata_offset + scrdata_size;
constant scmisc_offset          : natural := scwdata_offset + scwdata_size;
constant ramthrctl_offset       : natural := scmisc_offset + scmisc_size;
constant traceout_offset        : natural := ramthrctl_offset + ramthrctl_size;
constant triggout_offset        : natural := traceout_offset + traceout_size;
constant func_right             : natural := triggout_offset + triggout_size - 1;

signal func_siv, func_sov               : std_ulogic_vector(0 to func_right);
signal pc_pc_func_slp_sl_thold_0_b      : std_ulogic;
signal force_func                       : std_ulogic;
signal debug_group_0                    : std_ulogic_vector(0 to traceout_size-1);
signal debug_group_1                    : std_ulogic_vector(0 to traceout_size-1);
signal debug_group_2                    : std_ulogic_vector(0 to traceout_size-1);
signal debug_group_3                    : std_ulogic_vector(0 to traceout_size-1);
signal debug_group_4                    : std_ulogic_vector(0 to traceout_size-1);
signal debug_group_5                    : std_ulogic_vector(0 to traceout_size-1);
signal debug_group_6                    : std_ulogic_vector(0 to traceout_size-1);
signal debug_group_7                    : std_ulogic_vector(0 to traceout_size-1);
signal trigg_group_0                    : std_ulogic_vector(0 to triggout_size-1);
signal trigg_group_1                    : std_ulogic_vector(0 to triggout_size-1);
signal trigg_group_2                    : std_ulogic_vector(0 to triggout_size-1);
signal trigg_group_3                    : std_ulogic_vector(0 to triggout_size-1);
signal fir_icache_parity_q              : std_ulogic;
signal fir_icachedir_parity_q           : std_ulogic;
signal fir_dcache_parity_q              : std_ulogic;
signal fir_dcachedir_parity_q           : std_ulogic;
signal fir_sprg_ecc_q                   : std_ulogic_vector(0 to 3);
signal fir_xu_regf_parity_q             : std_ulogic_vector(0 to 3);
signal fir_fu_regf_parity_q             : std_ulogic_vector(0 to 3);
signal fir_mcsr_summary_q               : std_ulogic_vector(0 to 3);
signal fir_ierat_parity_q               : std_ulogic;
signal fir_derat_parity_q               : std_ulogic;
signal fir_tlb_parity_q                 : std_ulogic;
signal fir_tlb_lru_parity_q             : std_ulogic;
signal fir_ierat_multihit_q             : std_ulogic;
signal fir_derat_multihit_q             : std_ulogic;
signal fir_tlb_multihit_q               : std_ulogic;
signal fir_external_mchk_q              : std_ulogic;
signal fir_ditc_overrun_q               : std_ulogic;
signal fir_local_snoop_rej_q            : std_ulogic;
signal fir_inbox_ecc_q                  : std_ulogic;
signal fir_outbox_ecc_q                 : std_ulogic;
signal fir_scom_reg_parity_q            : std_ulogic;
signal fir_scom_ack_err_q               : std_ulogic;
signal fir_icachedir_multi_q            : std_ulogic;
signal fir_dcachedir_multi_q            : std_ulogic;
signal fir_wdt_reset_q                  : std_ulogic_vector(0 to 3);
signal fir_llbust_attempt_q             : std_ulogic_vector(0 to 3);
signal fir_llbust_failed_q              : std_ulogic_vector(0 to 3);
signal fir_max_recov_cntr_q             : std_ulogic;
signal fir_l2intrf_ecc_q                : std_ulogic;
signal fir_l2intrf_ue_q                 : std_ulogic;
signal fir_l2credit_overrun_q           : std_ulogic;
signal fir_sprg_ue_q                    : std_ulogic;
signal fir_xu_regf_ue_q                 : std_ulogic;
signal fir_fu_regf_ue_q                 : std_ulogic;
signal fir_nia_miscmpr_q                : std_ulogic;
signal fir_debug_event_q                : std_ulogic_vector(0 to 3);
signal fir_inbox_ue_q                   : std_ulogic;
signal fir_outbox_ue_q                  : std_ulogic;
signal fir_invld_reld_q                 : std_ulogic;
signal fir_ucode_illegal_q              : std_ulogic;
signal fir_attention_instr_q            : std_ulogic_vector(0 to 3);
signal fir_xstop_err_q                  : std_ulogic_vector(0 to 2);
signal fir_recov_err_q                  : std_ulogic_vector(0 to 2);
signal fir_scom_err_report_q            : std_ulogic_vector(0 to 17);
signal fir_xstop_per_thread_d           : std_ulogic_vector(0 to 3);
signal fir_xstop_per_thread_q           : std_ulogic_vector(0 to 3);
signal fir_block_ram_mode_q             : std_ulogic;
signal fir0_recov_err_pulse_q           : std_ulogic;
signal fir1_recov_err_pulse_q           : std_ulogic;
signal fir2_recov_err_pulse_q           : std_ulogic;
signal scom_rdata_d, scom_rdata_q       : std_ulogic_vector(0 to 63);
signal scom_wdata_d, scom_wdata_q       : std_ulogic_vector(0 to 63);
signal scom_decaddr_q                   : std_ulogic_vector(0 to 63);
signal scom_misc_sc_act_d               : std_ulogic;
signal scom_misc_sc_act_q               : std_ulogic;
signal scom_misc_sc_req_q               : std_ulogic;
signal scom_misc_sc_wr_q                : std_ulogic;
signal scom_misc_sc_nvld_q              : std_ulogic_vector(0 to 2);
signal scom_misc_scaddr_fir_d           : std_ulogic;
signal scom_misc_scaddr_fir_q           : std_ulogic;
signal scom_misc_sc_par_inj_q           : std_ulogic;
signal scom_misc_sc_wparity_d           : std_ulogic;
signal scom_misc_sc_wparity_q           : std_ulogic;
signal ram_execute_q                    : std_ulogic;
signal ram_interrupt_q                  : std_ulogic;
signal ram_error_q                      : std_ulogic;
signal ram_done_q                       : std_ulogic;
signal ram_thread_q                     : std_ulogic_vector(0 to 1);
signal ram_mode_q                       : std_ulogic;
signal ram_xu_done_in_q                 : std_ulogic;
signal ram_fu_done_in_q                 : std_ulogic;
signal thrctl_stop_out_q                : std_ulogic_vector(0 to 3);
signal thrctl_step_out_q                : std_ulogic_vector(0 to 3);
signal thrctl_run_in_q                  : std_ulogic_vector(0 to 3);
signal ctrls_init_active_q              : std_ulogic;
signal ctrls_resetsm_q                  : std_ulogic_vector(0 to 4);
signal ctrls_initerat_q                 : std_ulogic;
signal ctrls_reset_cmplt_q              : std_ulogic_vector(0 to 3);
signal ctrls_pm_stop_q                  : std_ulogic_vector(0 to 3);
signal ctrls_pm_state_q                 : std_ulogic_vector(0 to 3);
signal ctrls_pm_rvwinkled_q             : std_ulogic;
signal ctrls_ccr0_pme_q                 : std_ulogic_vector(0 to 1);
signal ctrls_ccr0_we_q                  : std_ulogic_vector(0 to 3);
signal ctrls_pmclkctrl_dly_q            : std_ulogic_vector(0 to 7);
signal ctrls_dis_pwr_sav_q              : std_ulogic;
signal ctrls_ccflush_dis_q              : std_ulogic;
signal ctrls_raise_tholds_q             : std_ulogic;  
signal clks_ccenable_dc                 : std_ulogic;
signal clks_fast_xstop                  : std_ulogic;
signal clks_scan_type_dc                : std_ulogic_vector(0 to 7);
signal clks_gsd_tst_en_dc               : std_ulogic;
signal clks_gsd_tst_ac_dc               : std_ulogic;
signal clks_lbist_en_dc                 : std_ulogic;
signal clks_lbist_ip_dc                 : std_ulogic;
signal spr_slowspr_val_l2               : std_ulogic;
signal spr_slowspr_rw_l2                : std_ulogic;
signal spr_slowspr_etid_l2              : std_ulogic_vector(0 to 1);
signal spr_slowspr_addr_l2              : std_ulogic_vector(0 to 9);
signal spr_slowspr_data_l2              : std_ulogic_vector(0 to 31);
signal spr_pc_done_l2                   : std_ulogic;

signal fu_events_d, fu_events_q         : std_ulogic_vector(0 to fuevents_size-1);
signal fu_bypass_q                      : std_ulogic_vector(0 to fuevents_size-1);
signal iu_events_d, iu_events_q         : std_ulogic_vector(0 to iuevents_size-1);
signal iu_bypass_q                      : std_ulogic_vector(0 to iuevents_size-1);
signal mm_events_d, mm_events_q         : std_ulogic_vector(0 to mmevents_size-1);
signal mm_bypass_q                      : std_ulogic_vector(0 to mmevents_size-1);
signal xu_events_d, xu_events_q         : std_ulogic_vector(0 to xuevents_size-1);
signal lsu_events_d, lsu_events_q       : std_ulogic_vector(0 to lsuevents_size-1);
signal lsu_bypass_q                     : std_ulogic_vector(0 to lsuevents_size-1);
signal trc_events_d, trc_events_q       : std_ulogic_vector(0 to trcevents_size-1);
signal event_bus_d, event_bus_q         : std_ulogic_vector(0 to eventbus_size-1);
signal trace_data_out_d                 : std_ulogic_vector(0 to traceout_size-1);
signal trace_data_out_q                 : std_ulogic_vector(0 to traceout_size-1);
signal trigg_data_out_d                 : std_ulogic_vector(0 to triggout_size-1);
signal trigg_data_out_q                 : std_ulogic_vector(0 to triggout_size-1);
signal unused_signals                   : std_ulogic;


begin

  unused_signals  <= or_reduce(rg_db_dbg_fir2_err(14 to 19) );


  fu_events_d  <= fu_pc_event_data;
  iu_events_d  <= iu_pc_event_data;
  mm_events_d  <= mm_pc_event_data;
  xu_events_d  <= xu_pc_event_data;
  lsu_events_d <= lsu_pc_event_data;
  trc_events_d <= ac_pc_trace_to_perfcntr;


event_mux: entity work.pcq_dbg_event
  generic map( expand_type => expand_type )         
  port map
   ( vd                 => vdd
   , gd                 => gnd
   , event_mux_ctrls    => rg_db_event_mux_ctrls
   , fu_event_data      => fu_events_q
   , iu_event_data      => iu_events_q
   , mm_event_data      => mm_events_q
   , xu_event_data      => xu_events_q
   , lsu_event_data     => lsu_events_q
   , trace_bus_data     => trc_events_q
   , event_bus          => event_bus_d
  );


  fir_icache_parity_q       <=  rg_db_dbg_fir0_err(0);
  fir_icachedir_parity_q    <=  rg_db_dbg_fir0_err(1);      
  fir_dcache_parity_q       <=  rg_db_dbg_fir0_err(2);
  fir_dcachedir_parity_q    <=  rg_db_dbg_fir0_err(3);
  fir_sprg_ecc_q            <=  rg_db_dbg_fir0_err(4 to 7);
  fir_xu_regf_parity_q      <=  rg_db_dbg_fir0_err(8 to 11);
  fir_fu_regf_parity_q      <=  rg_db_dbg_fir0_err(12 to 15);
  fir_inbox_ecc_q           <=  rg_db_dbg_fir0_err(16);
  fir_outbox_ecc_q          <=  rg_db_dbg_fir0_err(17);
  fir_scom_reg_parity_q     <=  rg_db_dbg_fir0_err(18);
  fir_scom_ack_err_q        <=  rg_db_dbg_fir0_err(19);
  fir_wdt_reset_q           <=  rg_db_dbg_fir0_err(20 to 23);
  fir_llbust_attempt_q      <=  rg_db_dbg_fir0_err(24 to 27);
  fir_llbust_failed_q       <=  rg_db_dbg_fir0_err(28 to 31);
  fir_max_recov_cntr_q      <=  rg_db_dbg_fir1_err(0);
  fir_l2intrf_ecc_q         <=  rg_db_dbg_fir1_err(1);
  fir_l2intrf_ue_q          <=  rg_db_dbg_fir1_err(2);
  fir_l2credit_overrun_q    <=  rg_db_dbg_fir1_err(3);
  fir_sprg_ue_q             <=  or_reduce(rg_db_dbg_fir1_err(4 to 7));
  fir_xu_regf_ue_q          <=  or_reduce(rg_db_dbg_fir1_err(8 to 11)); 
  fir_fu_regf_ue_q          <=  or_reduce(rg_db_dbg_fir1_err(12 to 15));
  fir_nia_miscmpr_q         <=  or_reduce(rg_db_dbg_fir1_err(16 to 19));
  fir_debug_event_q         <=  rg_db_dbg_fir1_err(20 to 23);
  fir_ucode_illegal_q       <=  or_reduce(rg_db_dbg_fir1_err(24 to 27)); 
  fir_inbox_ue_q            <=  rg_db_dbg_fir1_err(28); 
  fir_outbox_ue_q           <=  rg_db_dbg_fir1_err(29); 
  fir_invld_reld_q          <=  rg_db_dbg_fir1_err(30); 
  fir_mcsr_summary_q        <=  rg_db_dbg_fir2_err(0 to 3);
  fir_ierat_parity_q        <=  rg_db_dbg_fir2_err(4);
  fir_derat_parity_q        <=  rg_db_dbg_fir2_err(5);
  fir_tlb_parity_q          <=  rg_db_dbg_fir2_err(6);
  fir_tlb_lru_parity_q      <=  rg_db_dbg_fir2_err(7);
  fir_ierat_multihit_q      <=  rg_db_dbg_fir2_err(8);
  fir_derat_multihit_q      <=  rg_db_dbg_fir2_err(9);
  fir_tlb_multihit_q        <=  rg_db_dbg_fir2_err(10);
  fir_external_mchk_q       <=  rg_db_dbg_fir2_err(11);
  fir_local_snoop_rej_q     <=  rg_db_dbg_fir2_err(12);
  fir_ditc_overrun_q        <=  rg_db_dbg_fir2_err(13);
  fir_icachedir_multi_q     <=  rg_db_dbg_fir2_err(20);
  fir_dcachedir_multi_q     <=  rg_db_dbg_fir2_err(21);
  fir_attention_instr_q     <=  rg_db_dbg_fir_misc(0 to 3);
  fir_xstop_err_q           <=  rg_db_dbg_fir_misc(4 to 6);
  fir_recov_err_q           <=  rg_db_dbg_fir_misc(7 to 9);
  fir_scom_err_report_q     <=  rg_db_dbg_fir_misc(10 to 27);
  fir_xstop_per_thread_d    <=  rg_db_dbg_fir_misc(28 to 31);
  fir_block_ram_mode_q      <=  rg_db_dbg_fir_misc(32);
  fir0_recov_err_pulse_q    <=  rg_db_dbg_fir_misc(33);
  fir1_recov_err_pulse_q    <=  rg_db_dbg_fir_misc(34);
  fir2_recov_err_pulse_q    <=  rg_db_dbg_fir_misc(35);
  scom_rdata_d              <= rg_db_dbg_scom_rdata(0 to 63);
  scom_wdata_d              <= rg_db_dbg_scom_wdata(0 to 63);
  scom_decaddr_q            <= rg_db_dbg_scom_decaddr(0 to 63);
  scom_misc_sc_act_d        <= rg_db_dbg_scom_misc(0);
  scom_misc_sc_req_q        <= rg_db_dbg_scom_misc(1);
  scom_misc_sc_wr_q         <= rg_db_dbg_scom_misc(2);
  scom_misc_sc_nvld_q       <= rg_db_dbg_scom_misc(3 to 5);
  scom_misc_scaddr_fir_d    <= rg_db_dbg_scom_misc(6);
  scom_misc_sc_par_inj_q    <= rg_db_dbg_scom_misc(7);
  scom_misc_sc_wparity_d    <= rg_db_dbg_scom_misc(8);
  ram_execute_q             <= rg_db_dbg_ram_thrctl(0);
  ram_interrupt_q           <= rg_db_dbg_ram_thrctl(1);
  ram_error_q               <= rg_db_dbg_ram_thrctl(2);
  ram_done_q                <= rg_db_dbg_ram_thrctl(3);
  ram_thread_q              <= rg_db_dbg_ram_thrctl(4 to 5);
  ram_mode_q                <= rg_db_dbg_ram_thrctl(6);
  ram_xu_done_in_q          <= rg_db_dbg_ram_thrctl(7);
  ram_fu_done_in_q          <= rg_db_dbg_ram_thrctl(8);
  thrctl_stop_out_q         <= rg_db_dbg_ram_thrctl(9 to 12);
  thrctl_step_out_q         <= rg_db_dbg_ram_thrctl(13 to 16);
  thrctl_run_in_q           <= rg_db_dbg_ram_thrctl(17 to 20);
  ctrls_init_active_q       <= ct_db_dbg_ctrls(0);
  ctrls_resetsm_q           <= ct_db_dbg_ctrls(1 to 5);
  ctrls_initerat_q          <= ct_db_dbg_ctrls(6);
  ctrls_reset_cmplt_q       <= ct_db_dbg_ctrls(7 to 10);
  ctrls_pm_stop_q           <= ct_db_dbg_ctrls(11 to 14);
  ctrls_pm_state_q          <= ct_db_dbg_ctrls(15 to 18);
  ctrls_pm_rvwinkled_q      <= ct_db_dbg_ctrls(19);
  ctrls_ccr0_pme_q          <= ct_db_dbg_ctrls(20 to 21);
  ctrls_ccr0_we_q           <= ct_db_dbg_ctrls(22 to 25);
  ctrls_pmclkctrl_dly_q     <= ct_db_dbg_ctrls(26 to 33);
  ctrls_dis_pwr_sav_q       <= ct_db_dbg_ctrls(34);
  ctrls_ccflush_dis_q       <= ct_db_dbg_ctrls(35);
  ctrls_raise_tholds_q      <= ct_db_dbg_ctrls(36);
  clks_ccenable_dc          <= ck_db_dbg_clks_ctrls(0);
  clks_gsd_tst_en_dc        <= ck_db_dbg_clks_ctrls(1);
  clks_gsd_tst_ac_dc        <= ck_db_dbg_clks_ctrls(2);
  clks_lbist_en_dc          <= ck_db_dbg_clks_ctrls(3);
  clks_lbist_ip_dc          <= ck_db_dbg_clks_ctrls(4);
  clks_scan_type_dc         <= ck_db_dbg_clks_ctrls(5 to 12);
  clks_fast_xstop           <= ck_db_dbg_clks_ctrls(13);
  spr_slowspr_val_l2        <= rg_db_dbg_spr(0);
  spr_slowspr_rw_l2         <= rg_db_dbg_spr(1);
  spr_slowspr_etid_l2       <= rg_db_dbg_spr(2 to 3);
  spr_slowspr_addr_l2       <= rg_db_dbg_spr(4 to 13);
  spr_slowspr_data_l2       <= rg_db_dbg_spr(14 to 45);
  spr_pc_done_l2            <= rg_db_dbg_spr(46);


  debug_group_0   <= fir_icache_parity_q    & fir_icachedir_parity_q & fir_dcache_parity_q &
                     fir_dcachedir_parity_q & fir_sprg_ecc_q(0 to 3) & fir_nia_miscmpr_q   & 
                     fir_l2intrf_ue_q & fir_sprg_ue_q  & fir_invld_reld_q & fir_xu_regf_ue_q &
                     fir_fu_regf_ue_q & fir_inbox_ue_q & fir_outbox_ue_q  & fir_l2credit_overrun_q &
                     fir_ucode_illegal_q  & scom_wdata_q(0 to 63) & "000000";

  debug_group_1   <= scom_misc_sc_act_q & scom_misc_sc_req_q & scom_misc_sc_wr_q &
                     scom_misc_sc_nvld_q(0 to 2) & scom_misc_scaddr_fir_q & scom_misc_sc_wparity_q &
                     scom_misc_sc_par_inj_q & fir_block_ram_mode_q & ram_mode_q & ram_thread_q(0 to 1) &
                     ram_execute_q & ram_interrupt_q & ram_error_q & ram_done_q & ram_xu_done_in_q &
                     ram_fu_done_in_q & scom_rdata_q(0 to 63) & "00000";

  debug_group_2   <= fir_fu_regf_parity_q(0 to 3) & fir_xu_regf_parity_q(0 to 3) & ctrls_init_active_q &
                     ctrls_resetsm_q(0 to 4) & ctrls_initerat_q &  ctrls_reset_cmplt_q(0 to 3) &
                     scom_decaddr_q(0 to 63) & "00000";

  debug_group_3   <= fir_mcsr_summary_q(0 to 3) & fir_ierat_parity_q & fir_derat_parity_q &
                     fir_tlb_parity_q & fir_tlb_lru_parity_q & fir_scom_err_report_q(0 to 17) &
                     thrctl_run_in_q(0 to 3) & thrctl_stop_out_q(0 to 3) &
                     thrctl_step_out_q(0 to 3) & fir_attention_instr_q(0 to 3) &
                     fir_scom_reg_parity_q & fir_scom_ack_err_q & fir_recov_err_q(0 to 2) &
                     fir_xstop_err_q(0 to 2) & fir_xstop_per_thread_q(0 to 3) & x"00000000" & "00";

  debug_group_4   <= fir_ierat_multihit_q  & fir_derat_multihit_q  & fir_tlb_multihit_q  &
                     fir_external_mchk_q   & fir_local_snoop_rej_q & fir_ditc_overrun_q  &
                     ctrls_pm_stop_q(0 to 3) & ctrls_pm_state_q(0 to 3) & ctrls_ccr0_pme_q(0 to 1) &
                     ctrls_ccr0_we_q(0 to 3) & ctrls_pm_rvwinkled_q & clks_ccenable_dc &
                     clks_scan_type_dc(0 to 7) & clks_gsd_tst_en_dc & clks_gsd_tst_ac_dc &
                     clks_lbist_en_dc & clks_lbist_ip_dc & clks_fast_xstop &
                     ctrls_pmclkctrl_dly_q(0 to 7) & ctrls_ccflush_dis_q & ctrls_dis_pwr_sav_q &
                     ctrls_raise_tholds_q & x"0000000000" & "00";

  debug_group_5   <= fir_icachedir_multi_q & fir_dcachedir_multi_q & fir_inbox_ecc_q &
                     fir_outbox_ecc_q & fir_l2intrf_ecc_q & fir0_recov_err_pulse_q &
                     fir1_recov_err_pulse_q & fir2_recov_err_pulse_q & fir_max_recov_cntr_q &
                     x"0000000000000000000" & "000";

  debug_group_6   <= fir_llbust_attempt_q(0 to 3) & fir_llbust_failed_q(0 to 3) &
                     x"00000000000000000000"; 

  debug_group_7   <= fir_wdt_reset_q(0 to 3) & fir_debug_event_q(0 to 3) &
                     spr_slowspr_val_l2 & spr_slowspr_rw_l2 & spr_pc_done_l2 &
                     spr_slowspr_etid_l2(0 to 1) & spr_slowspr_addr_l2(0 to 9) &
                     spr_slowspr_data_l2(0 to 31) & x"00000000" & "0";
  

  trigg_group_0   <= scom_misc_sc_act_q & scom_misc_sc_req_q & scom_misc_sc_wr_q &
                     scom_misc_sc_nvld_q(0 to 2) & scom_misc_scaddr_fir_q &
                     thrctl_stop_out_q(0 to 3) & ctrls_initerat_q;
 
  trigg_group_1   <= ram_mode_q & ram_execute_q & ram_interrupt_q & ram_error_q &
                     ram_done_q & ctrls_pm_stop_q(0 to 3) & ctrls_ccr0_pme_q(0 to 1) &
                     ctrls_ccflush_dis_q;

  trigg_group_2   <= fir_xstop_err_q(0 to 2) & fir_recov_err_q(0 to 2) & 
                     fir_mcsr_summary_q(0 to 3) & fir_external_mchk_q &
                     fir_l2intrf_ecc_q;

  trigg_group_3   <= fir_wdt_reset_q(0 to 3) & fir_llbust_attempt_q(0 to 3) &
                     thrctl_run_in_q(0 to 3);




debug_mux: entity clib.c_debug_mux8
  port map
    ( vd                 => vdd
     ,gd                 => gnd

     ,select_bits        => rg_db_debug_mux_ctrls
     ,trace_data_in      => debug_bus_in
     ,trigger_data_in    => trace_triggers_in

     ,dbg_group0         => debug_group_0
     ,dbg_group1         => debug_group_1
     ,dbg_group2         => debug_group_2
     ,dbg_group3         => debug_group_3
     ,dbg_group4         => debug_group_4
     ,dbg_group5         => debug_group_5
     ,dbg_group6         => debug_group_6
     ,dbg_group7         => debug_group_7

     ,trg_group0         => trigg_group_0
     ,trg_group1         => trigg_group_1
     ,trg_group2         => trigg_group_2
     ,trg_group3         => trigg_group_3

     ,trace_data_out     => trace_data_out_d
     ,trigger_data_out   => trigg_data_out_d
  );


  ac_an_event_bus         <= event_bus_q;
  ac_an_fu_bypass_events  <= fu_bypass_q;
  ac_an_iu_bypass_events  <= iu_bypass_q;
  ac_an_mm_bypass_events  <= mm_bypass_q;
  ac_an_lsu_bypass_events <= lsu_bypass_q;


  debug_bus_out  <= trace_data_out_q;

  trace_triggers_out  <= trigg_data_out_q;


fuevents: tri_rlmreg_p
  generic map (width => fuevents_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(fuevents_offset to fuevents_offset + fuevents_size-1),
            scout   => func_sov(fuevents_offset to fuevents_offset + fuevents_size-1),
            din     => fu_events_d,
            dout    => fu_events_q );

fubypass: tri_rlmreg_p
  generic map (width => fuevents_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(fubypass_offset to fubypass_offset + fuevents_size-1),
            scout   => func_sov(fubypass_offset to fubypass_offset + fuevents_size-1),
            din     => fu_events_q,
            dout    => fu_bypass_q );

iuevents: tri_rlmreg_p
  generic map (width => iuevents_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(iuevents_offset to iuevents_offset + iuevents_size-1),
            scout   => func_sov(iuevents_offset to iuevents_offset + iuevents_size-1),
            din     => iu_events_d,
            dout    => iu_events_q );

iubypass: tri_rlmreg_p
  generic map (width => iuevents_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(iubypass_offset to iubypass_offset + iuevents_size-1),
            scout   => func_sov(iubypass_offset to iubypass_offset + iuevents_size-1),
            din     => iu_events_q,
            dout    => iu_bypass_q );

mmevents: tri_rlmreg_p
  generic map (width => mmevents_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(mmevents_offset to mmevents_offset + mmevents_size-1),
            scout   => func_sov(mmevents_offset to mmevents_offset + mmevents_size-1),
            din     => mm_events_d,
            dout    => mm_events_q );

mmbypass: tri_rlmreg_p
  generic map (width => mmevents_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(mmbypass_offset to mmbypass_offset + mmevents_size-1),
            scout   => func_sov(mmbypass_offset to mmbypass_offset + mmevents_size-1),
            din     => mm_events_q,
            dout    => mm_bypass_q );

xuevents: tri_rlmreg_p
  generic map (width => xuevents_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(xuevents_offset to xuevents_offset + xuevents_size-1),
            scout   => func_sov(xuevents_offset to xuevents_offset + xuevents_size-1),
            din     => xu_events_d,
            dout    => xu_events_q );

lsuevents: tri_rlmreg_p
  generic map (width => lsuevents_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(lsuevents_offset to lsuevents_offset + lsuevents_size-1),
            scout   => func_sov(lsuevents_offset to lsuevents_offset + lsuevents_size-1),
            din     => lsu_events_d,
            dout    => lsu_events_q );

lsubypass: tri_rlmreg_p
  generic map (width => lsuevents_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(lsubypass_offset to lsubypass_offset + lsuevents_size-1),
            scout   => func_sov(lsubypass_offset to lsubypass_offset + lsuevents_size-1),
            din     => lsu_events_q,
            dout    => lsu_bypass_q );

trcevents: tri_rlmreg_p
  generic map (width => trcevents_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(trcevents_offset to trcevents_offset + trcevents_size-1),
            scout   => func_sov(trcevents_offset to trcevents_offset + trcevents_size-1),
            din     => trc_events_d,
            dout    => trc_events_q );

eventbus: tri_rlmreg_p
  generic map (width => eventbus_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_event_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(eventbus_offset to eventbus_offset + eventbus_size-1),
            scout   => func_sov(eventbus_offset to eventbus_offset + eventbus_size-1),
            din     => event_bus_d,
            dout    => event_bus_q );

scrdata: tri_rlmreg_p
  generic map (width => scrdata_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_trace_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(scrdata_offset to scrdata_offset + scrdata_size-1),
            scout   => func_sov(scrdata_offset to scrdata_offset + scrdata_size-1),
            din     => scom_rdata_d,
            dout    => scom_rdata_q );

scwdata: tri_rlmreg_p
  generic map (width => scwdata_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_trace_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(scwdata_offset to scwdata_offset + scwdata_size-1),
            scout   => func_sov(scwdata_offset to scwdata_offset + scwdata_size-1),
            din     => scom_wdata_d,
            dout    => scom_wdata_q );

scmisc: tri_rlmreg_p
  generic map (width => scmisc_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_trace_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(scmisc_offset to scmisc_offset + scmisc_size-1),
            scout   => func_sov(scmisc_offset to scmisc_offset + scmisc_size-1),
            din(0)  => scom_misc_sc_act_d,
            din(1)  => scom_misc_scaddr_fir_d,
            din(2)  => scom_misc_sc_wparity_d,
            dout(0) => scom_misc_sc_act_q,
            dout(1) => scom_misc_scaddr_fir_q,
            dout(2) => scom_misc_sc_wparity_q );

ramthrctl: tri_rlmreg_p
  generic map (width => ramthrctl_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_trace_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(ramthrctl_offset to ramthrctl_offset + ramthrctl_size-1),
            scout   => func_sov(ramthrctl_offset to ramthrctl_offset + ramthrctl_size-1),
            din(0 to 3)  => fir_xstop_per_thread_d,
            dout(0 to 3) => fir_xstop_per_thread_q );


traceout: tri_rlmreg_p
  generic map (width => traceout_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_trace_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(traceout_offset to traceout_offset + traceout_size-1),
            scout   => func_sov(traceout_offset to traceout_offset + traceout_size-1),
            din     => trace_data_out_d,
            dout    => trace_data_out_q );

triggout: tri_rlmreg_p
  generic map (width => triggout_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rg_db_trace_bus_enable,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(triggout_offset to triggout_offset + triggout_size-1),
            scout   => func_sov(triggout_offset to triggout_offset + triggout_size-1),
            din     => trigg_data_out_d,
            dout    => trigg_data_out_q );


lcbor_func0: tri_lcbor
generic map (expand_type => expand_type )
port map (
    clkoff_b => lcb_clkoff_dc_b,
    thold    => pc_pc_func_slp_sl_thold_0,
    sg       => pc_pc_sg_0,
    act_dis  => lcb_act_dis_dc,
    forcee => force_func,
    thold_b  => pc_pc_func_slp_sl_thold_0_b );


func_siv(0 TO func_right) <=  func_scan_in & func_sov(0 to func_right-1);
func_scan_out  <=  func_sov(func_right) and scan_dis_dc_b;


end pcq_dbg;

