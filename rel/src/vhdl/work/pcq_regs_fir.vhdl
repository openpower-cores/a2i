-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--
--  Description: Pervasive Core FIR + Error Reporting Function
--
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library ibm,clib;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;


entity pcq_regs_fir is
generic(expand_type             : integer  := 2);  -- 0=ibm (Umbra), 1=non-ibm, 2=ibm (MPG)

port(
    vdd                         : inout power_logic;
    gnd                         : inout power_logic;
    nclk                        : in    clk_logic;
    lcb_clkoff_dc_b             : in    std_ulogic;
    lcb_mpw1_dc_b               : in    std_ulogic;
    lcb_mpw2_dc_b               : in    std_ulogic;
    lcb_delay_lclkr_dc          : in    std_ulogic;
    lcb_act_dis_dc              : in    std_ulogic;
    lcb_sg_0                    : in    std_ulogic;
    lcb_func_slp_sl_thold_0     : in    std_ulogic;
    lcb_cfg_slp_sl_thold_0      : in    std_ulogic;
    cfgslp_d1clk                : in    std_ulogic;
    cfgslp_d2clk                : in    std_ulogic;
    cfgslp_lclk                 : in    clk_logic;
    cfg_slat_d2clk              : in    std_ulogic;
    cfg_slat_lclk               : in    clk_logic;
    bcfg_scan_in                : in    std_ulogic;
    bcfg_scan_out               : out   std_ulogic;
    func_scan_in                : in    std_ulogic;
    func_scan_out               : out   std_ulogic;
-- SCOM Satellite Interface
    sc_active                   : in    std_ulogic;
    sc_wr_q                     : in    std_ulogic;
    sc_addr_v                   : in    std_ulogic_vector(0 to 63);
    sc_wdata                    : in    std_ulogic_vector(0 to 63);
    sc_wparity                  : in    std_ulogic;
    sc_rdata                    : out   std_ulogic_vector(0 to 63);
-- FIR and Error Signals
    ac_an_special_attn           : out   std_ulogic_vector(0 to 3);
    ac_an_checkstop              : out   std_ulogic_vector(0 to 2);
    ac_an_local_checkstop        : out   std_ulogic_vector(0 to 2);
    ac_an_recov_err              : out   std_ulogic_vector(0 to 2);
    ac_an_trace_error            : out   std_ulogic;
    rg_rg_any_fir_xstop          : out   std_ulogic;
    an_ac_checkstop              : in    std_ulogic;
    an_ac_malf_alert             : in    std_ulogic;
    iu_pc_err_icache_parity      : in    std_ulogic;
    iu_pc_err_icachedir_parity   : in    std_ulogic;
    iu_pc_err_icachedir_multihit : in    std_ulogic;
    iu_pc_err_ucode_illegal      : in    std_ulogic_vector(0 to 3);
    xu_pc_err_dcache_parity      : in    std_ulogic;
    xu_pc_err_dcachedir_parity   : in    std_ulogic;
    xu_pc_err_dcachedir_multihit : in    std_ulogic;
    xu_pc_err_mcsr_summary       : in    std_ulogic_vector(0 to 3);
    xu_pc_err_ierat_parity       : in    std_ulogic;
    xu_pc_err_derat_parity       : in    std_ulogic;
    xu_pc_err_tlb_parity         : in    std_ulogic;
    xu_pc_err_tlb_lru_parity     : in    std_ulogic;
    xu_pc_err_ierat_multihit     : in    std_ulogic;
    xu_pc_err_derat_multihit     : in    std_ulogic;
    xu_pc_err_tlb_multihit       : in    std_ulogic;
    xu_pc_err_ext_mchk           : in    std_ulogic;
    xu_pc_err_ditc_overrun       : in    std_ulogic;
    xu_pc_err_local_snoop_reject : in    std_ulogic;
    xu_pc_err_sprg_ecc           : in    std_ulogic_vector(0 to 3);
    xu_pc_err_sprg_ue            : in    std_ulogic_vector(0 to 3);
    xu_pc_err_regfile_parity     : in    std_ulogic_vector(0 to 3);
    xu_pc_err_regfile_ue         : in    std_ulogic_vector(0 to 3);
    xu_pc_err_llbust_attempt     : in    std_ulogic_vector(0 to 3);
    xu_pc_err_llbust_failed      : in    std_ulogic_vector(0 to 3);
    xu_pc_err_l2intrf_ecc        : in    std_ulogic;
    xu_pc_err_l2intrf_ue         : in    std_ulogic;
    xu_pc_err_l2credit_overrun   : in    std_ulogic;
    xu_pc_err_wdt_reset          : in    std_ulogic_vector(0 to 3);
    xu_pc_err_attention_instr    : in    std_ulogic_vector(0 to 3);
    xu_pc_err_debug_event        : in    std_ulogic_vector(0 to 3);
    xu_pc_err_nia_miscmpr        : in    std_ulogic_vector(0 to 3);
    xu_pc_err_invld_reld         : in    std_ulogic;
    xu_pc_err_mchk_disabled      : in    std_ulogic;
    bx_pc_err_inbox_ecc          : in    std_ulogic;
    bx_pc_err_inbox_ue           : in    std_ulogic;
    bx_pc_err_outbox_ecc         : in    std_ulogic;
    bx_pc_err_outbox_ue          : in    std_ulogic;
    fu_pc_err_regfile_parity     : in    std_ulogic_vector(0 to 3);
    fu_pc_err_regfile_ue         : in    std_ulogic_vector(0 to 3);
    scom_reg_par_checks          : in    std_ulogic_vector(0 to 6);
    scom_sat_fsm_error           : in    std_ulogic;
    scom_ack_error               : in    std_ulogic;
    sc_parity_error_inject       : in    std_ulogic;
    rg_rg_xstop_report_ovride    : in    std_ulogic;
    rg_rg_ram_mode               : in    std_ulogic;
    rg_rg_ram_mode_xstop         : out   std_ulogic;
    rg_rg_xstop_err              : out   std_ulogic_vector(0 to 3);
    rg_rg_errinj_shutoff         : out   std_ulogic_vector(0 to 14);
    rg_rg_maxRecErrCntrValue     : in    std_ulogic;
    rg_rg_gateRecErrCntr         : out   std_ulogic;
   -- Performance Event Signals
    pc_xu_cache_par_err_event   : out   std_ulogic;
--  Trace/Trigger Signals
    dbg_fir0_err                : out   std_ulogic_vector(0 to 31);
    dbg_fir1_err                : out   std_ulogic_vector(0 to 30);
    dbg_fir2_err                : out   std_ulogic_vector(0 to 21);
    dbg_fir_misc                : out   std_ulogic_vector(0 to 35)
);

-- synopsys translate_off


-- synopsys translate_on
end pcq_regs_fir;

architecture pcq_regs_fir of pcq_regs_fir is
--=====================================================================
-- Signal Declarations
--=====================================================================
-- FIR0 Init Values
constant fir0_width            : positive := 32;
constant fir0_init             : std_ulogic_vector := x"00000000";
constant fir0mask_init         : std_ulogic_vector := x"FFFFFFFF"; 
constant fir0mask_par_init     : std_ulogic_vector := "0";  
constant fir0act0_init         : std_ulogic_vector := x"00000F00";
constant fir0act0_par_init     : std_ulogic_vector := "0";
constant fir0act1_init         : std_ulogic_vector := x"FFFFF0FF";
constant fir0act1_par_init     : std_ulogic_vector := "0";
-- FIR1 Init Values
constant fir1_width            : positive := 32;
constant fir1_init             : std_ulogic_vector := x"00000000";
constant fir1mask_init         : std_ulogic_vector := x"FFFFFFFF"; 
constant fir1mask_par_init     : std_ulogic_vector := "0";  
constant fir1act0_init         : std_ulogic_vector := x"3FFFFFFF";
constant fir1act0_par_init     : std_ulogic_vector := "0";
constant fir1act1_init         : std_ulogic_vector := x"C0000000";
constant fir1act1_par_init     : std_ulogic_vector := "0";
-- FIR2 Init Values
constant fir2_width            : positive := 22;
constant fir2_init             : std_ulogic_vector := x"00000" & "00";
constant fir2mask_init         : std_ulogic_vector := x"FFFE0" & "11"; 
constant fir2mask_par_init     : std_ulogic_vector := "1";  
constant fir2act0_init         : std_ulogic_vector := x"00020" & "00";
constant fir2act0_par_init     : std_ulogic_vector := "1";
constant fir2act1_init         : std_ulogic_vector := x"0FFC0" & "11";
constant fir2act1_par_init     : std_ulogic_vector := "0";
-- Common Init Values
constant scpar_err_rpt_width   : positive := 16;
constant scpar_rpt_reset_value : std_ulogic_vector := x"0000";
constant scack_err_rpt_width   : positive := 2;
constant scack_rpt_reset_value : std_ulogic_vector := "00";

-- Scan Ring Ordering:
constant FIR0_bcfg_size        : positive := 3*(fir0_width+1)+fir0_width;  
constant FIR1_bcfg_size        : positive := 3*(fir1_width+1)+fir1_width;
constant FIR2_bcfg_size        : positive := 3*(fir2_width+1)+fir2_width;
constant FIR0_func_size        : positive := 5;
constant FIR1_func_size        : positive := 5;
constant FIR2_func_size        : positive := 5;
constant attent_func_size      : positive := 4;
constant errout_func_size      : positive := 34;
-- start of bcfg scan chain ordering
constant bcfg_fir0_offset      : natural := 0;
constant bcfg_fir1_offset      : natural := bcfg_fir0_offset + FIR0_bcfg_size;
constant bcfg_fir2_offset      : natural := bcfg_fir1_offset + FIR1_bcfg_size;
constant bcfg_erpt1_hld_offset : natural := bcfg_fir2_offset + FIR2_bcfg_size;
constant bcfg_erpt1_msk_offset : natural := bcfg_erpt1_hld_offset + scpar_err_rpt_width;
constant bcfg_erpt2_hld_offset : natural := bcfg_erpt1_msk_offset + scpar_err_rpt_width;
constant bcfg_erpt2_msk_offset : natural := bcfg_erpt2_hld_offset + scack_err_rpt_width;
constant bcfg_right            : natural := bcfg_erpt2_msk_offset + scack_err_rpt_width - 1;
-- end of bcfg scan chain ordering
-- start of func scan chain ordering
constant func_fir0_offset      : natural := 0;
constant func_fir1_offset      : natural := func_fir0_offset + FIR0_func_size;
constant func_fir2_offset      : natural := func_fir1_offset + FIR1_func_size;
constant func_attent_offset    : natural := func_fir2_offset + FIR2_func_size;
constant func_errout_offset    : natural := func_attent_offset + attent_func_size;
constant func_f0err_offset     : natural := func_errout_offset + errout_func_size;
constant func_f1err_offset     : natural := func_f0err_offset + fir0_width;
constant func_f2err_offset     : natural := func_f1err_offset + fir1_width;
constant func_right            : natural := func_f2err_offset + fir2_width - 1;
-- end of func scan chain ordering

-----------------------------------------------------------------------
-- Basic/Misc signals
signal tidn, tiup                       : std_ulogic;
signal tidn_32                          : std_ulogic_vector(0 to 31);
-- Clocks
signal func_d1clk                       : std_ulogic;
signal func_d2clk                       : std_ulogic;
signal func_lclk                        : clk_logic;
signal func_thold_b                     : std_ulogic;
signal func_force                       : std_ulogic;
-- SCOM
signal scom_err_rpt_held                : std_ulogic_vector(0 to 63);
signal sc_reg_par_err_in                : std_ulogic_vector(0 to scpar_err_rpt_width-1);
signal sc_reg_par_err_out               : std_ulogic_vector(0 to scpar_err_rpt_width-1);
signal sc_reg_par_err_out_q             : std_ulogic_vector(0 to scpar_err_rpt_width-1);
signal sc_reg_par_err_hold              : std_ulogic_vector(0 to scpar_err_rpt_width-1);
signal scom_reg_parity_err              : std_ulogic;
signal fir_regs_parity_err              : std_ulogic;
signal sc_reg_ack_err_in                : std_ulogic_vector(0 to scack_err_rpt_width-1);
signal sc_reg_ack_err_out               : std_ulogic_vector(0 to scack_err_rpt_width-1);
signal sc_reg_ack_err_out_q             : std_ulogic_vector(0 to scack_err_rpt_width-1);
signal sc_reg_ack_err_hold              : std_ulogic_vector(0 to scack_err_rpt_width-1);
signal scom_reg_ack_err                 : std_ulogic;
-- FIR0
signal fir0_errors                      : std_ulogic_vector(0 to fir0_width-1);
signal fir0_errors_q                    : std_ulogic_vector(0 to fir0_width-1);
signal fir0_fir_out                     : std_ulogic_vector(0 to fir0_width-1);
signal fir0_act0_out                    : std_ulogic_vector(0 to fir0_width-1);
signal fir0_act1_out                    : std_ulogic_vector(0 to fir0_width-1);
signal fir0_mask_out                    : std_ulogic_vector(0 to fir0_width-1);
signal fir0_scrdata                     : std_ulogic_vector(0 to fir0_width-1);
signal fir0_xstop_err                   : std_ulogic;
signal fir0_recov_err                   : std_ulogic;
signal fir0_lxstop_mchk                 : std_ulogic;
signal fir0_trace_error                 : std_ulogic;
signal fir0_block_on_checkstop          : std_ulogic;
signal fir0_fir_parity_check            : std_ulogic_vector(0 to 2);
signal fir0_recoverable_errors          : std_ulogic_vector(0 to fir0_width-1);
signal fir0_recov_err_in                : std_ulogic_vector(0 to 1);
signal fir0_recov_err_q                 : std_ulogic_vector(0 to 1);
signal fir0_recov_err_pulse             : std_ulogic;
signal fir0_enabled_checkstops          : std_ulogic_vector(32 to 32 + fir0_width-1);
-- FIR1
signal fir1_errors                      : std_ulogic_vector(0 to fir1_width-1);
signal fir1_errors_q                    : std_ulogic_vector(0 to fir1_width-1);
signal fir1_fir_out                     : std_ulogic_vector(0 to fir1_width-1);
signal fir1_act0_out                    : std_ulogic_vector(0 to fir1_width-1);
signal fir1_act1_out                    : std_ulogic_vector(0 to fir1_width-1);
signal fir1_mask_out                    : std_ulogic_vector(0 to fir1_width-1);
signal fir1_scrdata                     : std_ulogic_vector(0 to fir1_width-1);
signal fir1_xstop_err                   : std_ulogic;
signal fir1_recov_err                   : std_ulogic;
signal fir1_lxstop_mchk                 : std_ulogic;
signal fir1_trace_error                 : std_ulogic;
signal fir1_block_on_checkstop          : std_ulogic;
signal fir1_fir_parity_check            : std_ulogic_vector(0 to 2);
signal fir1_recoverable_errors          : std_ulogic_vector(0 to fir1_width-1);
signal fir1_recov_err_in                : std_ulogic_vector(0 to 1);
signal fir1_recov_err_q                 : std_ulogic_vector(0 to 1);
signal fir1_recov_err_pulse             : std_ulogic;
signal fir1_enabled_checkstops          : std_ulogic_vector(32 to 32 + fir1_width-1);
-- FIR2
signal fir2_errors                      : std_ulogic_vector(0 to fir2_width-1);
signal fir2_errors_q                    : std_ulogic_vector(0 to fir2_width-1);
signal fir2_fir_out                     : std_ulogic_vector(0 to fir2_width-1);
signal fir2_act0_out                    : std_ulogic_vector(0 to fir2_width-1);
signal fir2_act1_out                    : std_ulogic_vector(0 to fir2_width-1);
signal fir2_mask_out                    : std_ulogic_vector(0 to fir2_width-1);
signal fir2_scrdata                     : std_ulogic_vector(0 to fir2_width-1);
signal fir2_xstop_err                   : std_ulogic;
signal fir2_recov_err                   : std_ulogic;
signal fir2_lxstop_mchk                 : std_ulogic;
signal fir2_trace_error                 : std_ulogic;
signal fir2_block_on_checkstop          : std_ulogic;
signal fir2_fir_parity_check            : std_ulogic_vector(0 to 2);
signal fir2_recoverable_errors          : std_ulogic_vector(0 to fir2_width-1);
signal fir2_recov_err_in                : std_ulogic_vector(0 to 1);
signal fir2_recov_err_q                 : std_ulogic_vector(0 to 1);
signal fir2_recov_err_pulse             : std_ulogic;
signal fir2_enabled_checkstops          : std_ulogic_vector(36 to 32 + fir2_width-1);
-- Error Inject Shutoff
signal injoff_icache_parity             : std_ulogic;
signal injoff_icachedir_parity          : std_ulogic;
signal injoff_dcache_parity             : std_ulogic;
signal injoff_dcachedir_parity          : std_ulogic;
signal injoff_xuregfile_parity          : std_ulogic;
signal injoff_furegfile_parity          : std_ulogic;
signal injoff_sprg_ecc                  : std_ulogic;
signal injoff_inbox_ecc                 : std_ulogic;
signal injoff_outbox_ecc                : std_ulogic;
signal injoff_llbust_attempt            : std_ulogic;
signal injoff_llbust_failed             : std_ulogic;
signal injoff_wdt_reset                 : std_ulogic;
signal injoff_scomreg_parity            : std_ulogic;
signal injoff_icachedir_multihit        : std_ulogic;
signal injoff_dcachedir_multihit        : std_ulogic;
signal error_inject_shutoff             : std_ulogic_vector(0 to 14);
-- MISC
signal xstop_err_int, xstop_err_q       : std_ulogic_vector(0 to 2);
signal xstop_out_d, xstop_out_q         : std_ulogic_vector(0 to 2);
signal lxstop_err_int, lxstop_err_q     : std_ulogic_vector(0 to 2);
signal xstop_err_per_thread             : std_ulogic_vector(0 to 3);
signal xstop_err_common                 : std_ulogic;
signal an_ac_checkstop_q                : std_ulogic;
signal maxRecErrCntrValue_errrpt        : std_ulogic;
signal block_xstop_in_ram_mode          : std_ulogic;
signal atten_instr_q                    : std_ulogic_vector(0 to 3);
signal bcfg_siv, bcfg_sov               : std_ulogic_vector(0 to bcfg_right);
signal func_siv, func_sov               : std_ulogic_vector(0 to func_right);
signal unused_signals                   : std_ulogic;

begin


  tiup <= '1';
  tidn <= '0';
  tidn_32 <= (others => '0');

  unused_signals <= or_reduce( fir0_scrdata  & fir1_scrdata & fir2_scrdata  &
                               fir1_recoverable_errors(0)   & sc_addr_v(9)  & 
                               sc_addr_v(29 to 63) & sc_wdata & an_ac_malf_alert  );
                                
                    
                               
--=====================================================================
-- FIR0 Instantiation
--=====================================================================
FIR0: entity work.pcq_local_fir2
  generic map( width => fir0_width,
               expand_type => expand_type,
               impl_lxstop_mchk => false,
               use_recov_reset => false,
               fir_init => fir0_init, 
               fir_mask_init => fir0mask_init,
               fir_mask_par_init => fir0mask_par_init,
               fir_action0_init =>  fir0act0_init,
               fir_action0_par_init => fir0act0_par_init,
               fir_action1_init => fir0act1_init,
               fir_action1_par_init => fir0act1_par_init
             )
   port map 
    --  Global lines for clocking and scan control
    ( nclk                    => nclk
    , vd                      => vdd
    , gd                      => gnd
    , lcb_clkoff_dc_b         => lcb_clkoff_dc_b
    , lcb_mpw1_dc_b           => lcb_mpw1_dc_b
    , lcb_mpw2_dc_b           => lcb_mpw2_dc_b
    , lcb_delay_lclkr_dc      => lcb_delay_lclkr_dc
    , lcb_act_dis_dc          => lcb_act_dis_dc
    , lcb_sg_0                => lcb_sg_0
    , lcb_func_slp_sl_thold_0 => lcb_func_slp_sl_thold_0  -- not power-managed
    , lcb_cfg_slp_sl_thold_0  => lcb_cfg_slp_sl_thold_0   -- not power-managed
    , mode_scan_siv           => bcfg_siv(bcfg_fir0_offset to bcfg_fir0_offset + FIR0_bcfg_size-1)
    , mode_scan_sov           => bcfg_sov(bcfg_fir0_offset to bcfg_fir0_offset + FIR0_bcfg_size-1)
    , func_scan_siv           => func_siv(func_fir0_offset to func_fir0_offset + FIR0_func_size-1)
    , func_scan_sov           => func_sov(func_fir0_offset to func_fir0_offset + FIR0_func_size-1)
    -- external interface
    , error_in                => fir0_errors_q            -- needs to be directly off a latch for timing
    , xstop_err               => fir0_xstop_err           -- checkstop   output to Global FIR
    , recov_err               => fir0_recov_err           -- recoverable output to Global FIR
    , lxstop_mchk             => fir0_lxstop_mchk         -- use ONLY if impl_lxstop_mchk = true
    , trace_error             => fir0_trace_error         -- connect to error_input of closest trdata macro
    , sys_xstop_in            => fir0_block_on_checkstop  -- freeze FIR on other checkstop errors
    , recov_reset             => tidn                     -- only needed if use_recov_reset = true
    , fir_out                 => fir0_fir_out             -- output of current FIR state if needed
    , act0_out                => fir0_act0_out            -- output of current FIR ACT0 if needed
    , act1_out                => fir0_act1_out            -- output of current FIR ACT1 if needed
    , mask_out                => fir0_mask_out            -- output of current FIR MASK if needed
    , sc_parity_error_inject  => sc_parity_error_inject   -- Force parity error
    -- scom register connections
    , sc_active               => sc_active
    , sc_wr_q                 => sc_wr_q
    , sc_addr_v               => sc_addr_v(0 to 8)     
    , sc_wdata                => sc_wdata(32 to 32+fir0_width-1)      
    , sc_wparity              => sc_wparity    
    , sc_rdata                => fir0_scrdata      
    , fir_parity_check        => fir0_fir_parity_check
    );

-----------------------------------------------------------------------
-- Error Input Facility
   fir0_errors <= 
       iu_pc_err_icache_parity              & iu_pc_err_icachedir_parity          & --  0:1
       xu_pc_err_dcache_parity              & xu_pc_err_dcachedir_parity          & --  2:3
       xu_pc_err_sprg_ecc(0 to 3)           & xu_pc_err_regfile_parity(0 to 3)    & --  4:11
       fu_pc_err_regfile_parity(0 to 3)     & bx_pc_err_inbox_ecc                 & -- 12:16
       bx_pc_err_outbox_ecc                 & scom_reg_parity_err                 & -- 17:18
       scom_reg_ack_err                     & xu_pc_err_wdt_reset(0 to 3)         & -- 19:23
       xu_pc_err_llbust_attempt(0 to 3)     & xu_pc_err_llbust_failed(0 to 3)     ; -- 24:31

-- Block FIR on checkstop (external input or from other FIRs)
   fir0_block_on_checkstop <= an_ac_checkstop_q or xstop_err_q(1) or xstop_err_q(2);


--=====================================================================
-- FIR1 Instantiation
--=====================================================================
FIR1: entity work.pcq_local_fir2
  generic map( width => fir1_width,
               expand_type => expand_type,
               impl_lxstop_mchk => false,
               use_recov_reset => false,
               fir_init => fir1_init, 
               fir_mask_init => fir1mask_init,
               fir_mask_par_init => fir1mask_par_init,
               fir_action0_init =>  fir1act0_init,
               fir_action0_par_init => fir1act0_par_init,
               fir_action1_init => fir1act1_init,
               fir_action1_par_init => fir1act1_par_init
             )
   port map 
    --  Global lines for clocking and scan control
    ( nclk                    => nclk
    , vd                      => vdd
    , gd                      => gnd
    , lcb_clkoff_dc_b         => lcb_clkoff_dc_b
    , lcb_mpw1_dc_b           => lcb_mpw1_dc_b
    , lcb_mpw2_dc_b           => lcb_mpw2_dc_b
    , lcb_delay_lclkr_dc      => lcb_delay_lclkr_dc
    , lcb_act_dis_dc          => lcb_act_dis_dc
    , lcb_sg_0                => lcb_sg_0
    , lcb_func_slp_sl_thold_0 => lcb_func_slp_sl_thold_0  -- not power-managed
    , lcb_cfg_slp_sl_thold_0  => lcb_cfg_slp_sl_thold_0   -- not power-managed
    , mode_scan_siv           => bcfg_siv(bcfg_fir1_offset to bcfg_fir1_offset + FIR1_bcfg_size-1)
    , mode_scan_sov           => bcfg_sov(bcfg_fir1_offset to bcfg_fir1_offset + FIR1_bcfg_size-1)
    , func_scan_siv           => func_siv(func_fir1_offset to func_fir1_offset + FIR1_func_size-1)
    , func_scan_sov           => func_sov(func_fir1_offset to func_fir1_offset + FIR1_func_size-1)
    -- external interface
    , error_in                => fir1_errors_q            -- needs to be directly off a latch for timing
    , xstop_err               => fir1_xstop_err           -- checkstop   output to Global FIR
    , recov_err               => fir1_recov_err           -- recoverable output to Global FIR
    , lxstop_mchk             => fir1_lxstop_mchk         -- use ONLY if impl_lxstop_mchk = true
    , trace_error             => fir1_trace_error         -- connect to error_input of closest trdata macro
    , sys_xstop_in            => fir1_block_on_checkstop  -- freeze FIR on other checkstop errors
    , recov_reset             => tidn                     -- only needed if use_recov_reset = true
    , fir_out                 => fir1_fir_out             -- output of current FIR state if needed
    , act0_out                => fir1_act0_out            -- output of current FIR ACT0 if needed
    , act1_out                => fir1_act1_out            -- output of current FIR ACT1 if needed
    , mask_out                => fir1_mask_out            -- output of current FIR MASK if needed
    , sc_parity_error_inject  => sc_parity_error_inject   -- Force parity error
    -- scom register connections
    , sc_active               => sc_active
    , sc_wr_q                 => sc_wr_q
    , sc_addr_v               => sc_addr_v(10 to 18)     
    , sc_wdata                => sc_wdata(32 to 32+fir1_width-1)      
    , sc_wparity              => sc_wparity    
    , sc_rdata                => fir1_scrdata      
    , fir_parity_check        => fir1_fir_parity_check
    );

-----------------------------------------------------------------------
-- Error Input Facility
   fir1_errors <=
       maxRecErrCntrValue_errrpt         & xu_pc_err_l2intrf_ecc               &  --  0:1
       xu_pc_err_l2intrf_ue              & xu_pc_err_l2credit_overrun          &  --  2:3
       xu_pc_err_sprg_ue(0 to 3)         & xu_pc_err_regfile_ue(0 to 3)        &  --  4:11
       fu_pc_err_regfile_ue(0 to 3)      & xu_pc_err_nia_miscmpr(0 to 3)       &  -- 12:19
       xu_pc_err_debug_event(0 to 3)     & iu_pc_err_ucode_illegal(0 to 3)     &  -- 20:27
       bx_pc_err_inbox_ue                & bx_pc_err_outbox_ue                 &  -- 28:29
       xu_pc_err_invld_reld              & fir_regs_parity_err                 ;  -- 30:31
       

-----------------------------------------------------------------------
-- Block FIR on checkstop (external input or from other FIRs)
   fir1_block_on_checkstop <= an_ac_checkstop_q or xstop_err_q(0) or xstop_err_q(2);


--=====================================================================
-- FIR2 Instantiation
--=====================================================================
FIR2: entity work.pcq_local_fir2
  generic map( width => fir2_width,
               expand_type => expand_type,
               impl_lxstop_mchk => false,
               use_recov_reset => false,
               fir_init => fir2_init, 
               fir_mask_init => fir2mask_init,
               fir_mask_par_init => fir2mask_par_init,
               fir_action0_init =>  fir2act0_init,
               fir_action0_par_init => fir2act0_par_init,
               fir_action1_init => fir2act1_init,
               fir_action1_par_init => fir2act1_par_init
             )
   port map 
    --  Global lines for clocking and scan control
    ( nclk                    => nclk
    , vd                      => vdd
    , gd                      => gnd
    , lcb_clkoff_dc_b         => lcb_clkoff_dc_b
    , lcb_mpw1_dc_b           => lcb_mpw1_dc_b
    , lcb_mpw2_dc_b           => lcb_mpw2_dc_b
    , lcb_delay_lclkr_dc      => lcb_delay_lclkr_dc
    , lcb_act_dis_dc          => lcb_act_dis_dc
    , lcb_sg_0                => lcb_sg_0
    , lcb_func_slp_sl_thold_0 => lcb_func_slp_sl_thold_0  -- not power-managed
    , lcb_cfg_slp_sl_thold_0  => lcb_cfg_slp_sl_thold_0   -- not power-managed
    , mode_scan_siv           => bcfg_siv(bcfg_fir2_offset to bcfg_fir2_offset + FIR2_bcfg_size-1)
    , mode_scan_sov           => bcfg_sov(bcfg_fir2_offset to bcfg_fir2_offset + FIR2_bcfg_size-1)
    , func_scan_siv           => func_siv(func_fir2_offset to func_fir2_offset + FIR2_func_size-1)
    , func_scan_sov           => func_sov(func_fir2_offset to func_fir2_offset + FIR2_func_size-1)
    -- external interface
    , error_in                => fir2_errors_q            -- needs to be directly off a latch for timing
    , xstop_err               => fir2_xstop_err           -- checkstop   output to Global FIR
    , recov_err               => fir2_recov_err           -- recoverable output to Global FIR
    , lxstop_mchk             => fir2_lxstop_mchk         -- use ONLY if impl_lxstop_mchk = true
    , trace_error             => fir2_trace_error         -- connect to error_input of closest trdata macro
    , sys_xstop_in            => fir2_block_on_checkstop  -- freeze FIR on other checkstop errors
    , recov_reset             => tidn                     -- only needed if use_recov_reset = true
    , fir_out                 => fir2_fir_out             -- output of current FIR state if needed
    , act0_out                => fir2_act0_out            -- output of current FIR ACT0 if needed
    , act1_out                => fir2_act1_out            -- output of current FIR ACT1 if needed
    , mask_out                => fir2_mask_out            -- output of current FIR MASK if needed
    , sc_parity_error_inject  => sc_parity_error_inject   -- Force parity error
    -- scom register connections
    , sc_active               => sc_active
    , sc_wr_q                 => sc_wr_q
    , sc_addr_v               => sc_addr_v(20 to 28)     
    , sc_wdata                => sc_wdata(32 to 32+fir2_width-1)      
    , sc_wparity              => sc_wparity    
    , sc_rdata                => fir2_scrdata      
    , fir_parity_check        => fir2_fir_parity_check
    );


-----------------------------------------------------------------------
-- Error Input Facility
   fir2_errors <=
       xu_pc_err_mcsr_summary(0 to 3)                                    &  --  0:3
       xu_pc_err_ierat_parity           & xu_pc_err_derat_parity         &  --  4:5
       xu_pc_err_tlb_parity             & xu_pc_err_tlb_lru_parity       &  --  6:7
       xu_pc_err_ierat_multihit         & xu_pc_err_derat_multihit       &  --  8:9
       xu_pc_err_tlb_multihit           & xu_pc_err_ext_mchk             &  -- 10:11
       xu_pc_err_local_snoop_reject     & xu_pc_err_ditc_overrun         &  -- 12:13
       xu_pc_err_mchk_disabled          & fir2_errors_q(15 to 19)        &  -- 14:19  spares (wrapback dout=>din)
       iu_pc_err_icachedir_multihit     & xu_pc_err_dcachedir_multihit   ;  -- 20:21


-----------------------------------------------------------------------
-- Block FIR on checkstop (external input or from other FIRs)
   fir2_block_on_checkstop <= an_ac_checkstop_q or xstop_err_q(0) or xstop_err_q(1);


--=====================================================================
-- SCOM Register Read
--=====================================================================
  scom_err_rpt_held <= sc_reg_par_err_hold(0 to scpar_err_rpt_width-1) &
                       sc_reg_ack_err_hold(0 to scack_err_rpt_width-1) &
                       (scpar_err_rpt_width+scack_err_rpt_width to 63 => '0');

  sc_rdata  <=  gate_and(sc_addr_v(0),  tidn_32 & fir0_fir_out)            or
                gate_and(sc_addr_v(3),  tidn_32 & fir0_act0_out)           or
                gate_and(sc_addr_v(4),  tidn_32 & fir0_act1_out)           or
                gate_and(sc_addr_v(6),  tidn_32 & fir0_mask_out)           or
                gate_and(sc_addr_v(10), tidn_32 & fir1_fir_out)            or
                gate_and(sc_addr_v(13), tidn_32 & fir1_act0_out)           or
                gate_and(sc_addr_v(14), tidn_32 & fir1_act1_out)           or
                gate_and(sc_addr_v(16), tidn_32 & fir1_mask_out)           or
                gate_and(sc_addr_v(20), tidn_32 & fir2_fir_out  & "0000000000") or
                gate_and(sc_addr_v(23), tidn_32 & fir2_act0_out & "0000000000") or
                gate_and(sc_addr_v(24), tidn_32 & fir2_act1_out & "0000000000") or
                gate_and(sc_addr_v(26), tidn_32 & fir2_mask_out & "0000000000") or
                gate_and(sc_addr_v(5),  scom_err_rpt_held)                 or
                gate_and(sc_addr_v(19), fir0_fir_out & fir1_fir_out)       ;


--=====================================================================
-- Error Related Signals
--=====================================================================
-- SCOM parity error reporting macro
   sc_reg_par_err_in    <= scom_reg_par_checks     & fir0_fir_parity_check &
                           fir1_fir_parity_check   & fir2_fir_parity_check ;

   scom_reg_parity_err  <= or_reduce(sc_reg_par_err_out(0 to 6));
   fir_regs_parity_err  <= or_reduce(sc_reg_par_err_out(7 to 15));

   scom_err : entity tri.tri_err_rpt
     generic map
      (  width        => scpar_err_rpt_width
       , mask_reset_value => scpar_rpt_reset_value
       , inline       => false
       , expand_type  => expand_type
      ) -- use to bundle error reporting checkers of the same exact type
     port map
      ( vd            => vdd
      , gd            => gnd
      , err_d1clk     => cfgslp_d1clk         -- CAUTION: if LCB uses powersavings,
      , err_d2clk     => cfgslp_d2clk         --          errors must always get reported
      , err_lclk      => cfgslp_lclk 
      , err_scan_in   => bcfg_siv(bcfg_erpt1_hld_offset to bcfg_erpt1_hld_offset + scpar_err_rpt_width-1)  
      , err_scan_out  => bcfg_sov(bcfg_erpt1_hld_offset to bcfg_erpt1_hld_offset + scpar_err_rpt_width-1)  
      , mode_dclk     => cfg_slat_d2clk
      , mode_lclk     => cfg_slat_lclk
      , mode_scan_in  => bcfg_siv(bcfg_erpt1_msk_offset to bcfg_erpt1_msk_offset + scpar_err_rpt_width-1)
      , mode_scan_out => bcfg_sov(bcfg_erpt1_msk_offset to bcfg_erpt1_msk_offset + scpar_err_rpt_width-1)
      , err_in        => sc_reg_par_err_in
      , err_out       => sc_reg_par_err_out
      , hold_out      => sc_reg_par_err_hold
     );

-----------------------------------------------------------------------
-- SCOM control error reporting macro
   sc_reg_ack_err_in     <= scom_ack_error & scom_sat_fsm_error;
   scom_reg_ack_err      <= or_reduce(sc_reg_ack_err_out);

   sc_ack_err : entity tri.tri_err_rpt
     generic map
      (  width        => scack_err_rpt_width
       , mask_reset_value => scack_rpt_reset_value
       , inline       => false
       , expand_type  => expand_type
      ) -- use to bundle error reporting checkers of the same exact type
     port map
      ( vd            => vdd
      , gd            => gnd
      , err_d1clk     => cfgslp_d1clk         -- CAUTION: if LCB uses powersavings,
      , err_d2clk     => cfgslp_d2clk         --          errors must always get reported
      , err_lclk      => cfgslp_lclk 
      , err_scan_in   => bcfg_siv(bcfg_erpt2_hld_offset to bcfg_erpt2_hld_offset + scack_err_rpt_width-1)  
      , err_scan_out  => bcfg_sov(bcfg_erpt2_hld_offset to bcfg_erpt2_hld_offset + scack_err_rpt_width-1)  
      , mode_dclk     => cfg_slat_d2clk
      , mode_lclk     => cfg_slat_lclk
      , mode_scan_in  => bcfg_siv(bcfg_erpt2_msk_offset to bcfg_erpt2_msk_offset + scack_err_rpt_width-1)
      , mode_scan_out => bcfg_sov(bcfg_erpt2_msk_offset to bcfg_erpt2_msk_offset + scack_err_rpt_width-1)
      , err_in        => sc_reg_ack_err_in
      , err_out       => sc_reg_ack_err_out
      , hold_out      => sc_reg_ack_err_hold
     );

-----------------------------------------------------------------------
-- Other error reporting macros

   misc_dir_err : entity tri.tri_direct_err_rpt
     generic map
      (  width          => 1
       , expand_type    => expand_type
      ) 
     port map
      ( vd    => vdd
      , gd    => gnd
      , err_in(0)       => rg_rg_maxRecErrCntrValue
      , err_out(0)      => maxRecErrCntrValue_errrpt
     );


-----------------------------------------------------------------------
-- Error related facilities used in other functions
    -- FIR0 Errors that increment the recoverable error counter
    -- Only use fir0_act1_out so that a local_checkstop will count as a recoverable error.
    fir0_recoverable_errors    <= fir0_errors_q and fir0_act1_out and not fir0_mask_out;
    fir0_recov_err_in(0)       <= or_reduce(fir0_recoverable_errors);
    fir0_recov_err_in(1)       <= fir0_recov_err_q(0);
    -- Only indicates 1 recoverable error pulse if error input active multiple cycles
    fir0_recov_err_pulse       <= fir0_recov_err_q(0) and not fir0_recov_err_q(1);


    -- FIR1 Errors that increment the recoverable error counter
    -- Only use fir1_act1_out so that a local_checkstop will count as a recoverable error.
    fir1_recoverable_errors    <= fir1_errors_q and fir1_act1_out and not fir1_mask_out;
    -- Leaving maxRecErrCntrValue (FIR1(0)) out of input that gates recoverable error counter.
    fir1_recov_err_in(0)       <= or_reduce(fir1_recoverable_errors(1 to fir1_width-1));
    fir1_recov_err_in(1)       <= fir1_recov_err_q(0);
    -- Only indicates 1 recoverable error pulse if error input active multiple cycles
    fir1_recov_err_pulse       <= fir1_recov_err_q(0) and not fir1_recov_err_q(1);


    -- FIR2 Errors that increment the recoverable error counter
    -- Only use fir2_act1_out so that a local_checkstop will count as a recoverable error.
    fir2_recoverable_errors    <= fir2_errors_q and fir2_act1_out and not fir2_mask_out;
    fir2_recov_err_in(0)       <= or_reduce(fir2_recoverable_errors);
    fir2_recov_err_in(1)       <= fir2_recov_err_q(0);
    -- Only indicates 1 recoverable error pulse if error input active multiple cycles
    fir2_recov_err_pulse       <= fir2_recov_err_q(0) and not fir2_recov_err_q(1);


    -- Enabled checkstop errors used to stop failing thread.
    fir0_enabled_checkstops    <= fir0_fir_out and fir0_act0_out and not fir0_act1_out and not fir0_mask_out;
    fir1_enabled_checkstops    <= fir1_fir_out and fir1_act0_out and not fir1_act1_out and not fir1_mask_out;
    fir2_enabled_checkstops    <= fir2_fir_out(4 to fir2_width-1)   and        -- F!R2(36 to 53)
                                  fir2_act0_out(4 to fir2_width-1)  and not
                                  fir2_act1_out(4 to fir2_width-1)  and not
                                  fir2_mask_out(4 to fir2_width-1)  ;
   
-----------------------------------------------------------------------
-- Determines how errors will force failing thread(s) to stop if configured as checkstop:
-- This is based on the error bit definition in each FIR (thread specific or per core).
--
-- T0           FIR0(36,40,44,52,56,60) FIR1(36,40,44,48,52,56) FIR2(32 and 36:51)
-- T1           FIR0(37,41,45,53,57,61) FIR1(37,41,45,49,53,57) FIR2(33 and 36:51)
-- T2           FIR0(38,42,46,54,58,62) FIR1(38,42,46,50,54,58) FIR2(34 and 36:51)
-- T3           FIR0(39,43,47,55,59,63) FIR1(39,43,47,51,55,59) FIR2(35 and 36:51)
-- Per core     FIR0(32:35,48:51)       FIR1(32:35,60:63)       FIR2(52:53)
--
   xstop_err_common <= or_reduce(fir0_enabled_checkstops(32 to 35) & fir0_enabled_checkstops(48 to 51)) or 
                       or_reduce(fir1_enabled_checkstops(32 to 35) & fir1_enabled_checkstops(60 to 63)) or 
                       or_reduce(fir2_enabled_checkstops(52 to 53));
     
   xstop_err_per_thread(0) <= fir0_enabled_checkstops(36) or fir0_enabled_checkstops(40) or
                              fir0_enabled_checkstops(44) or fir0_enabled_checkstops(52) or
                              fir0_enabled_checkstops(56) or fir0_enabled_checkstops(60) or
                              fir1_enabled_checkstops(36) or fir1_enabled_checkstops(40) or
                              fir1_enabled_checkstops(44) or fir1_enabled_checkstops(48) or
                              fir1_enabled_checkstops(52) or fir1_enabled_checkstops(56) or
                              (fir2_fir_out(0) and or_reduce(fir2_enabled_checkstops(36 to 51))) or
                              xstop_err_common;                             
     
   xstop_err_per_thread(1) <= fir0_enabled_checkstops(37) or fir0_enabled_checkstops(41) or
                              fir0_enabled_checkstops(45) or fir0_enabled_checkstops(53) or
                              fir0_enabled_checkstops(57) or fir0_enabled_checkstops(61) or
                              fir1_enabled_checkstops(37) or fir1_enabled_checkstops(41) or
                              fir1_enabled_checkstops(45) or fir1_enabled_checkstops(49) or
                              fir1_enabled_checkstops(53) or fir1_enabled_checkstops(57) or
                              (fir2_fir_out(1) and or_reduce(fir2_enabled_checkstops(36 to 51))) or
                              xstop_err_common;                             
     
   xstop_err_per_thread(2) <= fir0_enabled_checkstops(38) or fir0_enabled_checkstops(42) or
                              fir0_enabled_checkstops(46) or fir0_enabled_checkstops(54) or
                              fir0_enabled_checkstops(58) or fir0_enabled_checkstops(62) or
                              fir1_enabled_checkstops(38) or fir1_enabled_checkstops(42) or
                              fir1_enabled_checkstops(46) or fir1_enabled_checkstops(50) or
                              fir1_enabled_checkstops(54) or fir1_enabled_checkstops(58) or
                              (fir2_fir_out(2) and or_reduce(fir2_enabled_checkstops(36 to 51))) or
                              xstop_err_common;                             
     
   xstop_err_per_thread(3) <= fir0_enabled_checkstops(39) or fir0_enabled_checkstops(43) or
                              fir0_enabled_checkstops(47) or fir0_enabled_checkstops(55) or
                              fir0_enabled_checkstops(59) or fir0_enabled_checkstops(63) or
                              fir1_enabled_checkstops(39) or fir1_enabled_checkstops(43) or
                              fir1_enabled_checkstops(47) or fir1_enabled_checkstops(51) or
                              fir1_enabled_checkstops(55) or fir1_enabled_checkstops(59) or
                              (fir2_fir_out(3) and or_reduce(fir2_enabled_checkstops(36 to 51))) or
                              xstop_err_common;                             

-----------------------------------------------------------------------
-- Report xstop + lxstop errors to Chiplet FIR.  Can bypass in Ram mode if override signal active.
   xstop_err_int(0)  <= fir0_xstop_err;
   xstop_err_int(1)  <= fir1_xstop_err;
   xstop_err_int(2)  <= fir2_xstop_err;

   rg_rg_any_fir_xstop <= or_reduce(xstop_err_int(0 to 2));

   lxstop_err_int(0) <= fir0_lxstop_mchk;
   lxstop_err_int(1) <= fir1_lxstop_mchk;
   lxstop_err_int(2) <= fir2_lxstop_mchk;

   block_xstop_in_ram_mode <= rg_rg_xstop_report_ovride and rg_rg_ram_mode;
   xstop_out_d(0 to 2)     <= gate_and(not block_xstop_in_ram_mode, xstop_err_int(0 to 2));
   
-----------------------------------------------------------------------
-- Error injection shutoff control signals
   injoff_icache_parity      <= fir0_errors_q(0);
   injoff_icachedir_parity   <= fir0_errors_q(1);
   injoff_dcache_parity      <= fir0_errors_q(2);
   injoff_dcachedir_parity   <= fir0_errors_q(3);
   injoff_sprg_ecc           <= or_reduce(fir0_errors_q(4 to 7));
   injoff_xuregfile_parity   <= or_reduce(fir0_errors_q(8 to 11));
   injoff_furegfile_parity   <= or_reduce(fir0_errors_q(12 to 15));
   injoff_inbox_ecc          <= fir0_errors_q(16);
   injoff_outbox_ecc         <= fir0_errors_q(17);
   injoff_scomreg_parity     <= fir0_errors_q(18);
   injoff_wdt_reset          <= or_reduce(fir0_errors_q(20 to 23));
   injoff_llbust_attempt     <= or_reduce(fir0_errors_q(24 to 27));
   injoff_llbust_failed      <= or_reduce(fir0_errors_q(28 to 31));
   injoff_icachedir_multihit <= fir2_errors_q(20);
   injoff_dcachedir_multihit <= fir2_errors_q(21);


   error_inject_shutoff <= injoff_icache_parity      & injoff_icachedir_parity   &
                           injoff_dcache_parity      & injoff_dcachedir_parity   &
                           injoff_xuregfile_parity   & injoff_furegfile_parity   &
                           injoff_sprg_ecc           & injoff_inbox_ecc          &
                           injoff_outbox_ecc         & injoff_llbust_attempt     &
                           injoff_llbust_failed      & injoff_wdt_reset          &
                           injoff_scomreg_parity     & injoff_icachedir_multihit &
                           injoff_dcachedir_multihit ;
 

--=====================================================================
-- Output Assignments
--=====================================================================
   ac_an_special_attn    <=  atten_instr_q(0 to 3);

   ac_an_checkstop       <=  xstop_out_q(0 to 2);

   ac_an_local_checkstop <=  lxstop_err_q(0 to 2);

   ac_an_recov_err       <=  fir0_recov_err & fir1_recov_err & fir2_recov_err;

   ac_an_trace_error     <=  fir0_trace_error or fir1_trace_error or fir2_trace_error;

   rg_rg_xstop_err       <=  xstop_err_per_thread(0 to 3);

   rg_rg_ram_mode_xstop  <=  rg_rg_ram_mode and (fir0_xstop_err or fir1_xstop_err or fir2_xstop_err);

   rg_rg_errinj_shutoff  <=  error_inject_shutoff;

   rg_rg_gateRecErrCntr  <=  fir0_recov_err_pulse or fir1_recov_err_pulse or fir2_recov_err_pulse;

   -- Combined performance event for I-Cache and D-Cache parity errors
   pc_xu_cache_par_err_event <= or_reduce(fir0_errors_q(0 to 3));


--=====================================================================
-- Trace/Trigger Signals
--=====================================================================
   dbg_fir0_err  <= fir0_errors_q;

   dbg_fir1_err  <= fir1_errors_q(0 to 30);

   dbg_fir2_err  <= fir2_errors_q;

   dbg_fir_misc  <= atten_instr_q(0 to 3)           &  --  0:3
                    fir0_xstop_err                  &  --  4
                    fir1_xstop_err                  &  --  5
                    fir2_xstop_err                  &  --  6
                    fir0_recov_err                  &  --  7
                    fir1_recov_err                  &  --  8
                    fir2_recov_err                  &  --  9
                    sc_reg_par_err_out_q(0 to 15)   &  -- 10:25
                    sc_reg_ack_err_out_q(0 to 1)    &  -- 26:27
                    xstop_err_per_thread(0 to 3)    &  -- 28:31
                    block_xstop_in_ram_mode         &  -- 32
                    fir0_recov_err_pulse            &  -- 33
                    fir1_recov_err_pulse            &  -- 34
                    fir2_recov_err_pulse            ;  -- 35



--=====================================================================
-- Latches
--=====================================================================
   atten_instr : entity tri.tri_nlat_scan
     generic map( width => attent_func_size, init => "0000", expand_type => expand_type )
     port map
      ( d1clk    => func_d1clk
      , vd       => vdd
      , gd       => gnd
      , lclk     => func_lclk
      , d2clk    => func_d2clk
      , scan_in  => func_siv(func_attent_offset to func_attent_offset + attent_func_size-1)
      , scan_out => func_sov(func_attent_offset to func_attent_offset + attent_func_size-1)
      , din      => xu_pc_err_attention_instr
      , q        => atten_instr_q
      );

   error_out : entity tri.tri_nlat_scan
     generic map( width => errout_func_size, init => x"00000000" & "00", expand_type => expand_type )
     port map
      ( d1clk    => func_d1clk
      , vd       => vdd
      , gd       => gnd
      , lclk     => func_lclk
      , d2clk    => func_d2clk
      , scan_in  => func_siv(func_errout_offset to func_errout_offset + errout_func_size-1)
      , scan_out => func_sov(func_errout_offset to func_errout_offset + errout_func_size-1)
      , din(0 to 2)   => xstop_err_int
      , din(3 to 5)   => xstop_out_d
      , din(6 to 8)   => lxstop_err_int
      , din(9 to 10)  => fir0_recov_err_in
      , din(11 to 12) => fir1_recov_err_in
      , din(13 to 14) => fir2_recov_err_in
      , din(15)       => an_ac_checkstop
      , din(16 to 31) => sc_reg_par_err_out
      , din(32 to 33) => sc_reg_ack_err_out
      , q(0 to 2)     => xstop_err_q
      , q(3 to 5)     => xstop_out_q
      , q(6 to 8)     => lxstop_err_q
      , q(9 to 10)    => fir0_recov_err_q
      , q(11 to 12)   => fir1_recov_err_q
      , q(13 to 14)   => fir2_recov_err_q
      , q(15)         => an_ac_checkstop_q
      , q(16 to 31)   => sc_reg_par_err_out_q
      , q(32 to 33)   => sc_reg_ack_err_out_q
      );

   f0err_out : entity tri.tri_nlat_scan
     generic map( width => fir0_width, init => fir0_init, expand_type => expand_type )
     port map
      ( d1clk    => func_d1clk
      , vd       => vdd
      , gd       => gnd
      , lclk     => func_lclk
      , d2clk    => func_d2clk
      , scan_in  => func_siv(func_f0err_offset to func_f0err_offset + fir0_width-1)
      , scan_out => func_sov(func_f0err_offset to func_f0err_offset + fir0_width-1)
      , din      => fir0_errors
      , q        => fir0_errors_q
      );

   f1err_out : entity tri.tri_nlat_scan
     generic map( width => fir1_width, init => fir1_init, expand_type => expand_type )
     port map
      ( d1clk    => func_d1clk
      , vd       => vdd
      , gd       => gnd
      , lclk     => func_lclk
      , d2clk    => func_d2clk
      , scan_in  => func_siv(func_f1err_offset to func_f1err_offset + fir1_width-1)
      , scan_out => func_sov(func_f1err_offset to func_f1err_offset + fir1_width-1)
      , din      => fir1_errors
      , q        => fir1_errors_q
      );

   f2err_out : entity tri.tri_nlat_scan
     generic map( width => fir2_width, init => fir2_init, expand_type => expand_type )
     port map
      ( d1clk    => func_d1clk
      , vd       => vdd
      , gd       => gnd
      , lclk     => func_lclk
      , d2clk    => func_d2clk
      , scan_in  => func_siv(func_f2err_offset to func_f2err_offset + fir2_width-1)
      , scan_out => func_sov(func_f2err_offset to func_f2err_offset + fir2_width-1)
      , din      => fir2_errors
      , q        => fir2_errors_q
      );


--=====================================================================
-- LCBs
--=====================================================================
-- functional ring regs; NOT power managed
   func_lcbor: entity tri.tri_lcbor
      generic map (expand_type => expand_type )
      port map( clkoff_b => lcb_clkoff_dc_b,
                thold    => lcb_func_slp_sl_thold_0,
                sg       => lcb_sg_0,
                act_dis  => lcb_act_dis_dc,
                forcee => func_force,
                thold_b  => func_thold_b
              );

   func_lcb: entity tri.tri_lcbnd
      generic map (expand_type => expand_type )
      port map( act         => tiup,           -- not power saved
                vd          => vdd,
                gd          => gnd,
                delay_lclkr => lcb_delay_lclkr_dc,
                mpw1_b      => lcb_mpw1_dc_b,
                mpw2_b      => lcb_mpw2_dc_b,
                nclk        => nclk,
                forcee => func_force,
                sg          => lcb_sg_0,
                thold_b     => func_thold_b,
                d1clk       => func_d1clk,
                d2clk       => func_d2clk,
                lclk        => func_lclk
              );


--=====================================================================
-- Scan Connections
--=====================================================================
   bcfg_siv(0 to bcfg_right)  <=  bcfg_scan_in & bcfg_sov(0 to bcfg_right-1);
   bcfg_scan_out  <=  bcfg_sov(bcfg_right);

   func_siv(0 to func_right)  <=  func_scan_in & func_sov(0 to func_right-1);
   func_scan_out  <=  func_sov(func_right);


-----------------------------------------------------------------------
end pcq_regs_fir;
