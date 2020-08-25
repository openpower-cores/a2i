-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU SPR - per thread register slice
--
library ieee,ibm,support,work,tri; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_spr_tspr is
generic(
   hvmode                           :     integer := 1;
   a2mode                           :     integer := 1;
   expand_type                      :     integer := 2;
   regsize                          :     integer := 64;
   eff_ifar                         :     integer := 62);
port(
   nclk                             : in  clk_logic;
   
   -- CHIP IO
   an_ac_ext_interrupt              : in  std_ulogic;
   an_ac_crit_interrupt             : in  std_ulogic;
   an_ac_perf_interrupt             : in  std_ulogic;
   an_ac_hang_pulse                 : in  std_ulogic;
   ac_tc_machine_check              : out std_ulogic;
   an_ac_external_mchk              : in  std_ulogic;
   instr_trace_mode                 : in  std_ulogic;

   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic_vector(0 to 0);
   mpw1_dc_b                        : in  std_ulogic_vector(0 to 0);
   mpw2_dc_b                        : in  std_ulogic;
   ccfg_sl_force : in  std_ulogic;
   ccfg_sl_thold_0_b                : in  std_ulogic;
   dcfg_sl_force : in  std_ulogic;
   dcfg_sl_thold_0_b                : in  std_ulogic;
   func_sl_force : in  std_ulogic;
   func_sl_thold_0_b                : in  std_ulogic;
   func_slp_sl_force : in  std_ulogic;
   func_slp_sl_thold_0_b            : in  std_ulogic;
   func_nsl_force : in  std_ulogic;
   func_nsl_thold_0_b               : in  std_ulogic;
   sg_0                             : in  std_ulogic;
   scan_in                          : in  std_ulogic;
   scan_out                         : out std_ulogic;
   ccfg_scan_in                     : in  std_ulogic;
   ccfg_scan_out                    : out std_ulogic;
   dcfg_scan_in                     : in  std_ulogic;
   dcfg_scan_out                    : out std_ulogic;
   
   cspr_tspr_rf1_act                : in  std_ulogic;

   -- Read Interface
   cspr_tspr_ex1_instr              : in  std_ulogic_vector(0 to 31);
   cspr_tspr_ex2_tid                : in  std_ulogic;
   tspr_cspr_ex3_tspr_rt            : out std_ulogic_vector(64-regsize to 63);

   -- Write Interface
   dec_spr_ex4_val                  : in  std_ulogic;
   cspr_tspr_ex5_is_mtmsr           : in  std_ulogic;
   cspr_tspr_ex5_is_mtspr           : in  std_ulogic;
   cspr_tspr_ex5_is_wrtee           : in  std_ulogic;
   cspr_tspr_ex5_is_wrteei          : in  std_ulogic;
   cspr_tspr_ex5_instr              : in  std_ulogic_vector(11 to 20);
   ex5_spr_wd                       : in  std_ulogic_vector(64-regsize to 63);

   cspr_tspr_dec_dbg_dis            : in  std_ulogic;
   
   dec_spr_ex1_epid_instr           : in  std_ulogic;
   fxu_spr_ex1_rs2                  : in  std_ulogic_vector(42 to 55);
   spr_cpl_ex3_ct_be                : out std_ulogic;
   spr_cpl_ex3_ct_le                : out std_ulogic;
   
   -- Illegal SPR
   tspr_cspr_illeg_mtspr_b          : out std_ulogic;
   tspr_cspr_illeg_mfspr_b          : out std_ulogic;
   tspr_cspr_hypv_mtspr             : out std_ulogic;
   tspr_cspr_hypv_mfspr             : out std_ulogic;

   -- Interrupt Interface
   cpl_spr_ex5_act                  : in  std_ulogic;
   cpl_spr_ex5_int                  : in  std_ulogic;
   cpl_spr_ex5_gint                 : in  std_ulogic;
   cpl_spr_ex5_cint                 : in  std_ulogic;
   cpl_spr_ex5_mcint                : in  std_ulogic;
   cpl_spr_ex5_nia                  : in  std_ulogic_vector(62-eff_ifar to 61);
   cpl_spr_ex5_esr                  : in  std_ulogic_vector(0 to 16);
   cpl_spr_ex5_mcsr                 : in  std_ulogic_vector(0 to 14);
   cpl_spr_ex5_dbsr                 : in  std_ulogic_vector(0 to 18);
   cpl_spr_ex5_dear_save            : in  std_ulogic;
   cpl_spr_ex5_dear_update          : in  std_ulogic;
   cpl_spr_ex5_dear_update_saved    : in  std_ulogic;
   cpl_spr_ex5_dbsr_update          : in  std_ulogic;
   cpl_spr_ex5_esr_update           : in  std_ulogic;
   cpl_spr_ex5_srr0_dec             : in  std_ulogic;
   cpl_spr_ex5_force_gsrr           : in  std_ulogic;
   cpl_spr_ex5_dbsr_ide             : in  std_ulogic;
   spr_cpl_dbsr_ide                 : out std_ulogic;
   
   -- Async Interrupt Req Interface
   spr_cpl_external_mchk            : out std_ulogic;
   spr_cpl_ext_interrupt            : out std_ulogic;
   spr_cpl_dec_interrupt            : out std_ulogic;
   spr_cpl_udec_interrupt           : out std_ulogic;
   spr_cpl_perf_interrupt           : out std_ulogic;
   spr_cpl_fit_interrupt            : out std_ulogic;
   spr_cpl_crit_interrupt           : out std_ulogic;
   spr_cpl_wdog_interrupt           : out std_ulogic;
   
   cspr_tspr_crit_mask              : in  std_ulogic;
   cspr_tspr_wdog_mask              : in  std_ulogic;
   cspr_tspr_dec_mask               : in  std_ulogic;
   cspr_tspr_udec_mask              : in  std_ulogic;
   cspr_tspr_perf_mask              : in  std_ulogic;
   cspr_tspr_fit_mask               : in  std_ulogic;
   cspr_tspr_ext_mask               : in  std_ulogic;

   tspr_cspr_pm_wake_up             : out std_ulogic;
   tspr_cspr_async_int              : out std_ulogic_vector(0 to 2);

   -- DBELL Int
   cspr_tspr_dbell_pirtag           : in  std_ulogic_vector(50 to 63);
   tspr_cspr_gpir_match             : out std_ulogic;

   cspr_tspr_timebase_taps          : in  std_ulogic_vector(0 to 9);
   timer_update                     : in  std_ulogic;
   
   -- Debug
   spr_cpl_iac1_en                  : out std_ulogic;
   spr_cpl_iac2_en                  : out std_ulogic;
   spr_cpl_iac3_en                  : out std_ulogic;
   spr_cpl_iac4_en                  : out std_ulogic;
   tspr_cspr_freeze_timers          : out std_ulogic;

   -- Flush
   xu_ex4_flush                     : in  std_ulogic;
   xu_ex5_flush                     : in  std_ulogic;

   -- Run State
   xu_iu_single_instr_mode          : out std_ulogic;
   xu_iu_raise_iss_pri              : out std_ulogic;
    
   -- LiveLock
   cpl_spr_ex5_instr_cpl            : in  std_ulogic;
   cspr_tspr_llen                   : in  std_ulogic;
   cspr_tspr_llpri                  : in  std_ulogic;
   tspr_cspr_lldet                  : out std_ulogic;   
   tspr_cspr_llpulse                : out std_ulogic;
   xu_pc_err_llbust_attempt         : out std_ulogic;
   xu_pc_err_llbust_failed          : out std_ulogic;
   pc_xu_inj_llbust_attempt         : in  std_ulogic;
   pc_xu_inj_llbust_failed          : in  std_ulogic;

   -- Resets
   pc_xu_inj_wdt_reset              : in  std_ulogic;
   reset_wd_complete                : in  std_ulogic;
   reset_1_complete                 : in  std_ulogic;
   reset_2_complete                 : in  std_ulogic;
   reset_3_complete                 : in  std_ulogic;
   reset_1_request                  : out std_ulogic;
   reset_2_request                  : out std_ulogic;
   reset_3_request                  : out std_ulogic;
   reset_wd_request                 : out std_ulogic;
   xu_pc_err_wdt_reset              : out std_ulogic;
   
   -- XER
   spr_byp_ex4_is_mtxer             : out std_ulogic;
   spr_byp_ex4_is_mfxer             : out std_ulogic;   

   -- MSR Override
   cspr_tspr_ram_mode               : in  std_ulogic;
   cspr_tspr_msrovride_en           : in  std_ulogic;
   pc_xu_msrovride_pr               : in  std_ulogic;
   pc_xu_msrovride_gs               : in  std_ulogic;  
   pc_xu_msrovride_de               : in  std_ulogic;  

   -- SPRs
   cpl_spr_dbcr0_edm                : in  std_ulogic;
   lsu_xu_spr_epsc_egs              : in  std_ulogic;
   lsu_xu_spr_epsc_epr              : in  std_ulogic;
   tspr_msr_de                      : out std_ulogic;
   tspr_msr_cm                      : out std_ulogic;
   tspr_msr_pr                      : out std_ulogic;
   tspr_msr_is                      : out std_ulogic;
   tspr_msr_gs                      : out std_ulogic;
   tspr_msr_ee                      : out std_ulogic;
   tspr_msr_ce                      : out std_ulogic;
   tspr_msr_me                      : out std_ulogic;
   tspr_fp_precise                  : out std_ulogic;
   tspr_epcr_extgs                  : out std_ulogic;
   cspr_xucr0_clkg_ctl              : in  std_ulogic_vector(4 to 4);
	spr_dbcr0_idm                    : out std_ulogic;
	spr_dbcr0_icmp                   : out std_ulogic;
	spr_dbcr0_brt                    : out std_ulogic;
	spr_dbcr0_irpt                   : out std_ulogic;
	spr_dbcr0_trap                   : out std_ulogic;
	spr_dbcr0_dac1                   : out std_ulogic_vector(0 to 1);
	spr_dbcr0_dac2                   : out std_ulogic_vector(0 to 1);
	spr_dbcr0_ret                    : out std_ulogic;
	spr_dbcr0_dac3                   : out std_ulogic_vector(0 to 1);
	spr_dbcr0_dac4                   : out std_ulogic_vector(0 to 1);
	spr_dbcr1_iac12m                 : out std_ulogic;
	spr_dbcr1_iac34m                 : out std_ulogic;
	spr_epcr_dtlbgs                  : out std_ulogic;
	spr_epcr_itlbgs                  : out std_ulogic;
	spr_epcr_dsigs                   : out std_ulogic;
	spr_epcr_isigs                   : out std_ulogic;
	spr_epcr_duvd                    : out std_ulogic;
	spr_epcr_dgtmi                   : out std_ulogic;
	xu_mm_spr_epcr_dmiuh             : out std_ulogic;
	spr_msr_ucle                     : out std_ulogic;
	spr_msr_spv                      : out std_ulogic;
	spr_msr_fp                       : out std_ulogic;
	spr_msr_ds                       : out std_ulogic;
	spr_msrp_uclep                   : out std_ulogic;

   tspr_debug                       : out std_ulogic_vector(0 to 11);

   -- Power
   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_spr_tspr;
architecture xuq_spr_tspr of xuq_spr_tspr is

constant DEX2                          : natural := 0;
constant DEX3                          : natural := 0;
constant DEX4                          : natural := 0;
constant DEX5                          : natural := 0;
constant DEX6                          : natural := 0;
constant DWR                           : natural := 0;
constant DX                            : natural := 0;
-- Types
subtype s2                            is std_ulogic_vector(0 to 1);
subtype s3                            is std_ulogic_vector(0 to 2);
subtype s4                            is std_ulogic_vector(0 to 3);
subtype s5                            is std_ulogic_vector(0 to 4);
subtype DO                            is std_ulogic_vector(65-regsize to 64);
-- SPR Bit Constants
constant MSR_CM                        : natural := 50;
constant MSR_GS                        : natural := 51;
constant MSR_UCLE                      : natural := 52;
constant MSR_SPV                       : natural := 53;
constant MSR_CE                        : natural := 54;
constant MSR_EE                        : natural := 55;
constant MSR_PR                        : natural := 56;
constant MSR_FP                        : natural := 57;
constant MSR_ME                        : natural := 58;
constant MSR_FE0                       : natural := 59;
constant MSR_DE                        : natural := 60;
constant MSR_FE1                       : natural := 61;
constant MSR_IS                        : natural := 62;
constant MSR_DS                        : natural := 63;
constant MSRP_UCLEP                    : natural := 62;
constant MSRP_DEP                      : natural := 63;
-- SPR Registers
signal acop_d         , acop_q         : std_ulogic_vector(32 to 63);
signal ccr3_d         , ccr3_q         : std_ulogic_vector(62 to 63);
signal csrr0_d        , csrr0_q        : std_ulogic_vector(64-(eff_ifar) to 63);
signal csrr1_d        , csrr1_q        : std_ulogic_vector(50 to 63);
signal dbcr0_d        , dbcr0_q        : std_ulogic_vector(43 to 63);
signal dbcr1_d        , dbcr1_q        : std_ulogic_vector(46 to 63);
signal dbsr_d         , dbsr_q         : std_ulogic_vector(44 to 63);
signal dear_d         , dear_q         : std_ulogic_vector(64-(regsize) to 63);
signal dec_d          , dec_q          : std_ulogic_vector(32 to 63);
signal decar_d        , decar_q        : std_ulogic_vector(32 to 63);
signal epcr_d         , epcr_q         : std_ulogic_vector(54 to 63);
signal esr_d          , esr_q          : std_ulogic_vector(47 to 63);
signal gdear_d        , gdear_q        : std_ulogic_vector(64-(regsize) to 63);
signal gesr_d         , gesr_q         : std_ulogic_vector(47 to 63);
signal gpir_d         , gpir_q         : std_ulogic_vector(32 to 63);
signal gsrr0_d        , gsrr0_q        : std_ulogic_vector(64-(eff_ifar) to 63);
signal gsrr1_d        , gsrr1_q        : std_ulogic_vector(50 to 63);
signal hacop_d        , hacop_q        : std_ulogic_vector(32 to 63);
signal mcsr_d         , mcsr_q         : std_ulogic_vector(49 to 63);
signal mcsrr0_d       , mcsrr0_q       : std_ulogic_vector(64-(eff_ifar) to 63);
signal mcsrr1_d       , mcsrr1_q       : std_ulogic_vector(50 to 63);
signal msr_d          , msr_q          : std_ulogic_vector(50 to 63);
signal msrp_d         , msrp_q         : std_ulogic_vector(62 to 63);
signal srr0_d         , srr0_q         : std_ulogic_vector(64-(eff_ifar) to 63);
signal srr1_d         , srr1_q         : std_ulogic_vector(50 to 63);
signal tcr_d          , tcr_q          : std_ulogic_vector(52 to 63);
signal tsr_d          , tsr_q          : std_ulogic_vector(59 to 63);
signal udec_d         , udec_q         : std_ulogic_vector(32 to 63);
signal xucr1_d        , xucr1_q        : std_ulogic_vector(59 to 63);
-- FUNC Scanchain
constant acop_offset                   : natural := 0;
constant csrr0_offset                  : natural := acop_offset     + acop_q'length*a2mode;
constant csrr1_offset                  : natural := csrr0_offset    + csrr0_q'length*a2mode;
constant dbcr1_offset                  : natural := csrr1_offset    + csrr1_q'length*a2mode;
constant dbsr_offset                   : natural := dbcr1_offset    + dbcr1_q'length;
constant dear_offset                   : natural := dbsr_offset     + dbsr_q'length;
constant dec_offset                    : natural := dear_offset     + dear_q'length;
constant decar_offset                  : natural := dec_offset      + dec_q'length;
constant epcr_offset                   : natural := decar_offset    + decar_q'length*a2mode;
constant esr_offset                    : natural := epcr_offset     + epcr_q'length*hvmode;
constant gdear_offset                  : natural := esr_offset      + esr_q'length;
constant gesr_offset                   : natural := gdear_offset    + gdear_q'length*hvmode;
constant gpir_offset                   : natural := gesr_offset     + gesr_q'length*hvmode;
constant gsrr0_offset                  : natural := gpir_offset     + gpir_q'length*hvmode;
constant gsrr1_offset                  : natural := gsrr0_offset    + gsrr0_q'length*hvmode;
constant hacop_offset                  : natural := gsrr1_offset    + gsrr1_q'length*hvmode;
constant mcsr_offset                   : natural := hacop_offset    + hacop_q'length*hvmode;
constant mcsrr0_offset                 : natural := mcsr_offset     + mcsr_q'length*a2mode;
constant mcsrr1_offset                 : natural := mcsrr0_offset   + mcsrr0_q'length*a2mode;
constant msrp_offset                   : natural := mcsrr1_offset   + mcsrr1_q'length*a2mode;
constant srr0_offset                   : natural := msrp_offset     + msrp_q'length*hvmode;
constant srr1_offset                   : natural := srr0_offset     + srr0_q'length;
constant tcr_offset                    : natural := srr1_offset     + srr1_q'length;
constant tsr_offset                    : natural := tcr_offset      + tcr_q'length*a2mode;
constant udec_offset                   : natural := tsr_offset      + tsr_q'length*a2mode;
constant last_reg_offset               : natural := udec_offset     + udec_q'length*a2mode;
-- BCFG Scanchain
constant last_reg_offset_bcfg          : natural := 1;
-- CCFG Scanchain
constant ccr3_offset_ccfg              : natural := 0;
constant msr_offset_ccfg               : natural := ccr3_offset_ccfg + ccr3_q'length;
constant xucr1_offset_ccfg             : natural := msr_offset_ccfg + msr_q'length;
constant last_reg_offset_ccfg          : natural := xucr1_offset_ccfg + xucr1_q'length;
-- DCFG Scanchain
constant dbcr0_offset_dcfg             : natural := 0;
constant last_reg_offset_dcfg          : natural := dbcr0_offset_dcfg + dbcr0_q'length;
-- Latches
signal exx_act_q,             exx_act_d               : std_ulogic_vector(1 to 5);              -- input=>exx_act_d                  , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_mfspr_q,        ex1_is_mfspr            : std_ulogic;                             -- input=>ex1_is_mfspr               , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_mtspr_q,        ex1_is_mtspr            : std_ulogic;                             -- input=>ex1_is_mtspr               , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_mfmsr_q,        ex1_is_mfmsr            : std_ulogic;                             -- input=>ex1_is_mfmsr               , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_instr_q,           ex2_instr_d             : std_ulogic_vector(11 to 20);            -- input=>ex2_instr_d                , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_is_mtxer_q,        ex3_is_mtxer_d          : std_ulogic;                             -- input=>ex3_is_mtxer_d             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_is_mfxer_q,        ex3_is_mfxer_d          : std_ulogic;                             -- input=>ex3_is_mfxer_d             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_rfi_q,             ex2_rfi_d               : std_ulogic;                             -- input=>ex2_rfi_d                  , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_rfgi_q,            ex2_rfgi_d              : std_ulogic;                             -- input=>ex2_rfgi_d                 , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_rfci_q,            ex1_is_rfci             : std_ulogic;                             -- input=>ex1_is_rfci                , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_rfmci_q,           ex1_is_rfmci            : std_ulogic;                             -- input=>ex1_is_rfmci               , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_rfi_q                                      : std_ulogic;                             -- input=>ex2_rfi_q                  , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_rfgi_q                                     : std_ulogic;                             -- input=>ex2_rfgi_q                 , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_rfci_q                                     : std_ulogic;                             -- input=>ex2_rfci_q                 , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_rfmci_q                                    : std_ulogic;                             -- input=>ex2_rfmci_q                , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_is_mfxer_q                                 : std_ulogic;                             -- input=>ex3_is_mfxer_q             , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_is_mtxer_q                                 : std_ulogic;                             -- input=>ex3_is_mtxer_q             , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_rfi_q                                      : std_ulogic;                             -- input=>ex3_rfi_q                  , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_rfgi_q                                     : std_ulogic;                             -- input=>ex3_rfgi_q                 , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_rfci_q                                     : std_ulogic;                             -- input=>ex3_rfci_q                 , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_rfmci_q                                    : std_ulogic;                             -- input=>ex3_rfmci_q                , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_val_q,               ex4_val               : std_ulogic;                             -- input=>ex4_val                    , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_rfi_q                                      : std_ulogic;                             -- input=>ex4_rfi_q                  , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_rfgi_q                                     : std_ulogic;                             -- input=>ex4_rfgi_q                 , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_rfci_q                                     : std_ulogic;                             -- input=>ex4_rfci_q                 , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_rfmci_q                                    : std_ulogic;                             -- input=>ex4_rfmci_q                , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_val_q,               ex5_val               : std_ulogic;                             -- input=>ex5_val                    , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_rfi_q                                      : std_ulogic;                             -- input=>ex5_rfi_q                  , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_rfgi_q                                     : std_ulogic;                             -- input=>ex5_rfgi_q                 , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_rfci_q                                     : std_ulogic;                             -- input=>ex5_rfci_q                 , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_rfmci_q                                    : std_ulogic;                             -- input=>ex5_rfmci_q                , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_wrtee_q                                    : std_ulogic;                             -- input=>cspr_tspr_ex5_is_wrtee     , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_wrteei_q                                   : std_ulogic;                             -- input=>cspr_tspr_ex5_is_wrteei    , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_is_mtmsr_q                                 : std_ulogic;                             -- input=>cspr_tspr_ex5_is_mtmsr     , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_is_mtspr_q                                 : std_ulogic;                             -- input=>cspr_tspr_ex5_is_mtspr     , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_instr_q                                    : std_ulogic_vector(11 to 20);            -- input=>cspr_tspr_ex5_instr        , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_int_q                                      : std_ulogic;                             -- input=>cpl_spr_ex5_int            , act=>ex5_int_act    , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_gint_q                                     : std_ulogic;                             -- input=>cpl_spr_ex5_gint           , act=>ex5_int_act    , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_cint_q                                     : std_ulogic;                             -- input=>cpl_spr_ex5_cint           , act=>ex5_int_act    , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_mcint_q                                    : std_ulogic;                             -- input=>cpl_spr_ex5_mcint          , act=>ex5_int_act    , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_nia_q                                      : std_ulogic_vector(62-eff_ifar to 61);   -- input=>cpl_spr_ex5_nia            , act=>ex5_int_act    , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_esr_q                                      : std_ulogic_vector(0 to 16);             -- input=>cpl_spr_ex5_esr   , act=>cpl_spr_ex5_esr_update  , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_mcsr_q                                     : std_ulogic_vector(0 to 14);             -- input=>cpl_spr_ex5_mcsr           , act=>ex5_int_act    , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_dbsr_q                                     : std_ulogic_vector(0 to 18);             -- input=>cpl_spr_ex5_dbsr  , act=>cpl_spr_ex5_dbsr_update , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_dear_save_q                                : std_ulogic;                             -- input=>cpl_spr_ex5_dear_save      , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_dear_update_q                              : std_ulogic;                             -- input=>cpl_spr_ex5_dear_update    , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_dear_update_saved_q                        : std_ulogic;                           -- input=>cpl_spr_ex5_dear_update_saved, act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_dbsr_update_q                              : std_ulogic;                             -- input=>cpl_spr_ex5_dbsr_update    , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_esr_update_q                               : std_ulogic;                             -- input=>cpl_spr_ex5_esr_update     , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_srr0_dec_q                                 : std_ulogic;                             -- input=>cpl_spr_ex5_srr0_dec       , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_force_gsrr_q                               : std_ulogic;                             -- input=>cpl_spr_ex5_force_gsrr     , act=>ex5_int_act    , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_dbsr_ide_q                                 : std_ulogic;                             -- input=>cpl_spr_ex5_dbsr_ide       , act=>ex5_int_act    , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_spr_wd_q                                   : std_ulogic_vector(64-regsize to 63);    -- input=>ex5_spr_wd                 , act=>exx_act_data(5), scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal fit_tb_tap_q,          fit_tb_tap_d            : std_ulogic;                             -- input=>fit_tb_tap_d               , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal wdog_tb_tap_q,         wdog_tb_tap_d           : std_ulogic;                             -- input=>wdog_tb_tap_d              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal hang_pulse_q,          hang_pulse_d            : std_ulogic_vector(0 to 3);              -- input=>hang_pulse_d               , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal lltap_q,               lltap_d                 : std_ulogic;                             -- input=>lltap_d                    , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal llcnt_q,               llcnt_d                 : std_ulogic_vector(0 to 1);              -- input=>llcnt_d                    , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal msrovride_pr_q                                 : std_ulogic;                             -- input=>pc_xu_msrovride_pr         , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal msrovride_gs_q                                 : std_ulogic;                             -- input=>pc_xu_msrovride_gs         , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal msrovride_de_q                                 : std_ulogic;                             -- input=>pc_xu_msrovride_de         , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal an_ac_ext_interrupt_q                          : std_ulogic;                             -- input=>an_ac_ext_interrupt        , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal an_ac_crit_interrupt_q                         : std_ulogic;                             -- input=>an_ac_crit_interrupt       , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal an_ac_perf_interrupt_q                         : std_ulogic;                             -- input=>an_ac_perf_interrupt       , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal dear_tmp_q,            dear_tmp_d              : std_ulogic_vector(dear_q'range);        -- input=>dear_tmp_d                 , act=>ex6_dear_save_q, scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal mux_msr_gs_q,          mux_msr_gs_d            : std_ulogic_vector(0 to 3);              -- input=>mux_msr_gs_d               , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>0
signal mux_msr_pr_q,          mux_msr_pr_d            : std_ulogic_vector(0 to 0);              -- input=>mux_msr_pr_d               , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>0
signal ex3_tspr_rt_q,         ex3_tspr_rt_d           : std_ulogic_vector(64-regsize to 63);    -- input=>ex3_tspr_rt_d              , act=>exx_act_data(2), scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal err_llbust_attempt_q,  err_llbust_attempt_d    : std_ulogic;                             -- input=>err_llbust_attempt_d       , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal err_llbust_failed_q,   err_llbust_failed_d     : std_ulogic;                             -- input=>err_llbust_failed_d        , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal inj_llbust_attempt_q                           : std_ulogic;                             -- input=>pc_xu_inj_llbust_attempt   , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal inj_llbust_failed_q                            : std_ulogic;                             -- input=>pc_xu_inj_llbust_failed    , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_rs2_q                                      : std_ulogic_vector(42 to 55);            -- input=>fxu_spr_ex1_rs2            , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_ct_q,              ex3_ct_d                : std_ulogic_vector(0 to 1);              -- input=>ex3_ct_d                   , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal an_ac_external_mchk_q                          : std_ulogic;                             -- input=>an_ac_external_mchk        , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal mchk_int_q,            mchk_int                : std_ulogic;                             -- input=>mchk_int                   , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal mchk_interrupt_q,      mchk_interrupt          : std_ulogic;                             -- input=>mchk_interrupt             , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal crit_interrupt_q,      crit_interrupt          : std_ulogic;                             -- input=>crit_interrupt             , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal wdog_interrupt_q,      wdog_interrupt          : std_ulogic;                             -- input=>wdog_interrupt             , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal dec_interrupt_q,       dec_interrupt           : std_ulogic;                             -- input=>dec_interrupt              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal udec_interrupt_q,      udec_interrupt          : std_ulogic;                             -- input=>udec_interrupt             , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal perf_interrupt_q,      perf_interrupt          : std_ulogic;                             -- input=>perf_interrupt             , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal fit_interrupt_q,       fit_interrupt           : std_ulogic;                             -- input=>fit_interrupt              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal ext_interrupt_q,       ext_interrupt           : std_ulogic;                             -- input=>ext_interrupt              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal single_instr_mode_q,   single_instr_mode_d     : std_ulogic;                             -- input=>single_instr_mode_d        , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal single_instr_mode_2_q                          : std_ulogic;                             -- input=>single_instr_mode_q        , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal machine_check_q,       machine_check_d         : std_ulogic;                             -- input=>machine_check_d            , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal raise_iss_pri_q,       raise_iss_pri_d         : std_ulogic;                             -- input=>raise_iss_pri_d            , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal raise_iss_pri_2_q                              : std_ulogic;                             -- input=>raise_iss_pri_q            , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal epsc_egs_q                                     : std_ulogic;                             -- input=>lsu_xu_spr_epsc_egs        , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal epsc_epr_q                                     : std_ulogic;                             -- input=>lsu_xu_spr_epsc_epr        , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_epid_instr_q                               : std_ulogic;                             -- input=>dec_spr_ex1_epid_instr     , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal pc_xu_inj_wdt_reset_q                          : std_ulogic;                             -- input=>pc_xu_inj_wdt_reset        , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal err_wdt_reset_q,       err_wdt_reset_d         : std_ulogic;                             -- input=>err_wdt_reset_d            , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal ex3_tid_rpwr_q,        ex3_tid_rpwr_d          : std_ulogic_vector(0 to regsize/8-1);    -- input=>ex3_tid_rpwr_d             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ram_mode_q                                     : std_ulogic;                             -- input=>cspr_tspr_ram_mode         , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal timebase_taps_q                                : std_ulogic_vector(cspr_tspr_timebase_taps'range);-- input=>cspr_tspr_timebase_taps , act=>tiup     , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>0
signal dbsr_mrr_q,            dbsr_mrr_d              : std_ulogic_vector(0 to 1);              -- input=>dbsr_mrr_d                 , act=>dbsr_mrr_act   , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal tsr_wrs_q,             tsr_wrs_d               : std_ulogic_vector(0 to 1);              -- input=>tsr_wrs_d                  , act=>tsr_wrs_act    , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal iac1_en_q,             iac1_en_d               : std_ulogic;                             -- input=>iac1_en_d                  , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal iac2_en_q,             iac2_en_d               : std_ulogic;                             -- input=>iac2_en_d                  , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal iac3_en_q,             iac3_en_d               : std_ulogic;                             -- input=>iac3_en_d                  , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal iac4_en_q,             iac4_en_d               : std_ulogic;                             -- input=>iac4_en_d                  , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal spare_0_q,             spare_0_d               : std_ulogic_vector(0 to 13);             -- input=>spare_0_d,             act=>tiup,
-- Scanchain
constant exx_act_offset                            : integer := last_reg_offset;
constant ex3_is_mtxer_offset                       : integer := exx_act_offset                 + exx_act_q'length;
constant ex3_is_mfxer_offset                       : integer := ex3_is_mtxer_offset            + 1;
constant ex3_rfi_offset                            : integer := ex3_is_mfxer_offset            + 1;
constant ex3_rfgi_offset                           : integer := ex3_rfi_offset                 + 1;
constant ex3_rfci_offset                           : integer := ex3_rfgi_offset                + 1;
constant ex3_rfmci_offset                          : integer := ex3_rfci_offset                + 1;
constant ex5_val_offset                            : integer := ex3_rfmci_offset               + 1;
constant ex5_rfi_offset                            : integer := ex5_val_offset                 + 1;
constant ex5_rfgi_offset                           : integer := ex5_rfi_offset                 + 1;
constant ex5_rfci_offset                           : integer := ex5_rfgi_offset                + 1;
constant ex5_rfmci_offset                          : integer := ex5_rfci_offset                + 1;
constant ex6_val_offset                            : integer := ex5_rfmci_offset               + 1;
constant fit_tb_tap_offset                         : integer := ex6_val_offset                 + 1;
constant wdog_tb_tap_offset                        : integer := fit_tb_tap_offset              + 1;
constant hang_pulse_offset                         : integer := wdog_tb_tap_offset             + 1;
constant lltap_offset                              : integer := hang_pulse_offset              + hang_pulse_q'length;
constant llcnt_offset                              : integer := lltap_offset                   + 1;
constant msrovride_pr_offset                       : integer := llcnt_offset                   + llcnt_q'length;
constant msrovride_gs_offset                       : integer := msrovride_pr_offset            + 1;
constant msrovride_de_offset                       : integer := msrovride_gs_offset            + 1;
constant an_ac_ext_interrupt_offset                : integer := msrovride_de_offset            + 1;
constant an_ac_crit_interrupt_offset               : integer := an_ac_ext_interrupt_offset     + 1;
constant an_ac_perf_interrupt_offset               : integer := an_ac_crit_interrupt_offset    + 1;
constant dear_tmp_offset                           : integer := an_ac_perf_interrupt_offset    + 1;
constant mux_msr_gs_offset                         : integer := dear_tmp_offset                + dear_tmp_q'length;
constant mux_msr_pr_offset                         : integer := mux_msr_gs_offset              + mux_msr_gs_q'length;
constant ex3_tspr_rt_offset                        : integer := mux_msr_pr_offset              + mux_msr_pr_q'length;
constant err_llbust_attempt_offset                 : integer := ex3_tspr_rt_offset             + ex3_tspr_rt_q'length;
constant err_llbust_failed_offset                  : integer := err_llbust_attempt_offset      + 1;
constant inj_llbust_attempt_offset                 : integer := err_llbust_failed_offset       + 1;
constant inj_llbust_failed_offset                  : integer := inj_llbust_attempt_offset      + 1;
constant ex3_ct_offset                             : integer := inj_llbust_failed_offset       + 1;
constant an_ac_external_mchk_offset                : integer := ex3_ct_offset                  + ex3_ct_q'length;
constant mchk_int_offset                           : integer := an_ac_external_mchk_offset     + 1;
constant mchk_interrupt_offset                     : integer := mchk_int_offset                + 1;
constant crit_interrupt_offset                     : integer := mchk_interrupt_offset          + 1;
constant wdog_interrupt_offset                     : integer := crit_interrupt_offset          + 1;
constant dec_interrupt_offset                      : integer := wdog_interrupt_offset          + 1;
constant udec_interrupt_offset                     : integer := dec_interrupt_offset           + 1;
constant perf_interrupt_offset                     : integer := udec_interrupt_offset          + 1;
constant fit_interrupt_offset                      : integer := perf_interrupt_offset          + 1;
constant ext_interrupt_offset                      : integer := fit_interrupt_offset           + 1;
constant single_instr_mode_offset                  : integer := ext_interrupt_offset           + 1;
constant single_instr_mode_2_offset                : integer := single_instr_mode_offset       + 1;
constant machine_check_offset                      : integer := single_instr_mode_2_offset     + 1;
constant raise_iss_pri_offset                      : integer := machine_check_offset           + 1;
constant raise_iss_pri_2_offset                    : integer := raise_iss_pri_offset           + 1;
constant epsc_egs_offset                           : integer := raise_iss_pri_2_offset         + 1;
constant epsc_epr_offset                           : integer := epsc_egs_offset                + 1;
constant pc_xu_inj_wdt_reset_offset                : integer := epsc_epr_offset                + 1;
constant err_wdt_reset_offset                      : integer := pc_xu_inj_wdt_reset_offset     + 1;
constant ex3_tid_rpwr_offset                       : integer := err_wdt_reset_offset           + 1;
constant ram_mode_offset                           : integer := ex3_tid_rpwr_offset            + ex3_tid_rpwr_q'length;
constant timebase_taps_offset                      : integer := ram_mode_offset                + 1;
constant dbsr_mrr_offset                           : integer := timebase_taps_offset           + timebase_taps_q'length;
constant tsr_wrs_offset                            : integer := dbsr_mrr_offset                + dbsr_mrr_q'length;
constant iac1_en_offset                            : integer := tsr_wrs_offset                 + tsr_wrs_q'length;
constant iac2_en_offset                            : integer := iac1_en_offset                 + 1;
constant iac3_en_offset                            : integer := iac2_en_offset                 + 1;
constant iac4_en_offset                            : integer := iac3_en_offset                 + 1;
constant spare_0_offset                            : integer := iac4_en_offset                 + 1;
constant scan_right                                : integer := spare_0_offset                 + spare_0_q'length;
signal siv                             : std_ulogic_vector(0 to scan_right-1);
signal sov                             : std_ulogic_vector(0 to scan_right-1);
constant scan_right_ccfg               : integer := last_reg_offset_ccfg;
signal siv_ccfg                        : std_ulogic_vector(0 to scan_right_ccfg-1);
signal sov_ccfg                        : std_ulogic_vector(0 to scan_right_ccfg-1);
constant scan_right_dcfg               : integer := last_reg_offset_dcfg;
signal siv_dcfg                        : std_ulogic_vector(0 to scan_right_dcfg-1);
signal sov_dcfg                        : std_ulogic_vector(0 to scan_right_dcfg-1);
-- Signals
signal tiup                            : std_ulogic;
signal tidn                            : std_ulogic_vector(00 to 63);
signal spare_0_lclk                    : clk_logic;
signal spare_0_d1clk, spare_0_d2clk    : std_ulogic;
signal ex1_opcode_is_31                : boolean;
signal ex1_opcode_is_19                : boolean;
signal ex1_is_rfi,   ex1_is_rfgi       : std_ulogic;
signal ex2_is_mfmsr                    : std_ulogic;
signal ex2_is_mfspr                    : std_ulogic;
signal ex2_is_mtspr                    : std_ulogic;
signal ex2_instr                       : std_ulogic_vector(11 to 20);
signal ex6_val                         : std_ulogic;
signal ex6_is_mtmsr                    : std_ulogic;
signal ex6_is_mtspr                    : std_ulogic;
signal ex6_instr                       : std_ulogic_vector(11 to 20);
signal ex6_any_int, ex6_any_hint       : std_ulogic;
signal ex6_msr_di2                     : std_ulogic_vector(msr_q'range);
signal ex6_msr_mask                    : std_ulogic_vector(msr_q'range);
signal ex6_msr_mux                     : std_ulogic_vector(msr_q'range);
signal ex6_msr_in                      : std_ulogic_vector(msr_q'range);
signal ex6_csrr1_d,ex6_mcsrr1_d        : std_ulogic_vector(msr_q'range);
signal ex6_gsrr1_d,ex6_srr1_d          : std_ulogic_vector(msr_q'range);
signal ex6_rfgi_msr                    : std_ulogic_vector(msr_q'range);
signal ex6_nia_srr0                    : std_ulogic_vector(srr0_q'range);
signal ex6_nia_srr0_dec                : std_ulogic_vector(srr0_q'range);
signal ex6_dec_zero,ex6_dec_upper_zero : std_ulogic;
signal ex6_udec_zero,ex6_udec_upper_zero : std_ulogic;
signal ex6_set_tsr_udis                : std_ulogic;
signal ex6_set_tsr_dis                 : std_ulogic;
signal ex6_set_tsr_fis                 : std_ulogic;
signal ex6_set_tsr_wis                 : std_ulogic;
signal ex6_set_tsr_enw                 : std_ulogic;
signal ex6_set_tsr                     : std_ulogic_vector(tsr_q'range);
signal ex6_spr_wd                      : std_ulogic_vector(64-regsize to 63);
signal wdog_pulse                      : std_ulogic;
signal lltbtap, llpulse, llreset       : std_ulogic;
signal llstate                         : std_ulogic_vector(0 to 1);
signal set_dbsr_ide                    : std_ulogic;
signal set_dbsr                        : std_ulogic_vector(dbsr_q'range);
signal dec_running, udec_running       : std_ulogic;
signal dbcr0_freeze_timers             : std_ulogic;
signal dbsr_event                      : std_ulogic;
signal mux_msr_gs, mux_msr_pr          : std_ulogic;
signal mux_msr_de                      : std_ulogic;
signal hang_pulse                      : std_ulogic;
signal dear_di                         : std_ulogic_vector(dear_q'range);
signal ex2_srr0_re2, ex2_gsrr0_re2     : std_ulogic;
signal ex2_csrr0_re2, ex2_mcsrr0_re2   : std_ulogic;
signal ex2_icswx_gs, ex2_icswx_pr      : std_ulogic;
signal ex2_acop_ct,  ex2_cop_ct        : std_ulogic_vector(32 to 63);
signal iac_us_en,    iac_er_en         : std_ulogic_vector(1 to 4);
signal udec_en                         : std_ulogic;
signal ex2_ct                          : std_ulogic_vector(0 to 1);
signal ex6_rfi, ex6_rfgi               : std_ulogic;
signal ex6_rfci, ex6_rfmci             : std_ulogic;
signal ex6_wrteei, ex6_wrtee           : std_ulogic;
signal reset_complete                  : std_ulogic_vector(0 to 1);
signal wdog_reset_1                    : std_ulogic;
signal wdog_reset_2                    : std_ulogic;
signal wdog_reset_3                    : std_ulogic;
signal tb_tap_edge                     : std_ulogic_vector(cspr_tspr_timebase_taps'range);
signal exx_act, exx_act_data           : std_ulogic_vector(1 to 5);
signal ex5_int_act                     : std_ulogic;
signal ex1_is_wrteei                   : std_ulogic;
signal dbsr_mrr_act, tsr_wrs_act       : std_ulogic;
signal reset_complete_act              : std_ulogic;
signal ex6_gint_nia_sel                : std_ulogic;
signal fp_precise                      : std_ulogic;
signal dbsr_di                         : std_ulogic_vector(dbsr_q'range);

-- Data
signal spr_acop_ct                     : std_ulogic_vector(0 to 31);
signal spr_ccr3_en_eepri               : std_ulogic;
signal spr_ccr3_si                     : std_ulogic;
signal spr_dbcr0_rst                   : std_ulogic_vector(0 to 1);
signal spr_dbcr0_iac1                  : std_ulogic;
signal spr_dbcr0_iac2                  : std_ulogic;
signal spr_dbcr0_iac3                  : std_ulogic;
signal spr_dbcr0_iac4                  : std_ulogic;
signal spr_dbcr0_ft                    : std_ulogic;
signal spr_dbcr1_iac1us                : std_ulogic_vector(0 to 1);
signal spr_dbcr1_iac1er                : std_ulogic_vector(0 to 1);
signal spr_dbcr1_iac2us                : std_ulogic_vector(0 to 1);
signal spr_dbcr1_iac2er                : std_ulogic_vector(0 to 1);
signal spr_dbcr1_iac3us                : std_ulogic_vector(0 to 1);
signal spr_dbcr1_iac3er                : std_ulogic_vector(0 to 1);
signal spr_dbcr1_iac4us                : std_ulogic_vector(0 to 1);
signal spr_dbcr1_iac4er                : std_ulogic_vector(0 to 1);
signal spr_dbsr_ide                    : std_ulogic;
signal spr_epcr_extgs                  : std_ulogic;
signal spr_epcr_icm                    : std_ulogic;
signal spr_epcr_gicm                   : std_ulogic;
signal spr_hacop_ct                    : std_ulogic_vector(0 to 31);
signal spr_msr_cm                      : std_ulogic;
signal spr_msr_gs                      : std_ulogic;
signal spr_msr_ce                      : std_ulogic;
signal spr_msr_ee                      : std_ulogic;
signal spr_msr_pr                      : std_ulogic;
signal spr_msr_me                      : std_ulogic;
signal spr_msr_fe0                     : std_ulogic;
signal spr_msr_de                      : std_ulogic;
signal spr_msr_fe1                     : std_ulogic;
signal spr_msr_is                      : std_ulogic;
signal spr_tcr_wp                      : std_ulogic_vector(0 to 1);
signal spr_tcr_wrc                     : std_ulogic_vector(0 to 1);
signal spr_tcr_wie                     : std_ulogic;
signal spr_tcr_die                     : std_ulogic;
signal spr_tcr_fp                      : std_ulogic_vector(0 to 1);
signal spr_tcr_fie                     : std_ulogic;
signal spr_tcr_are                     : std_ulogic;
signal spr_tcr_udie                    : std_ulogic;
signal spr_tcr_ud                      : std_ulogic;
signal spr_tsr_enw                     : std_ulogic;
signal spr_tsr_wis                     : std_ulogic;
signal spr_tsr_dis                     : std_ulogic;
signal spr_tsr_fis                     : std_ulogic;
signal spr_tsr_udis                    : std_ulogic;
signal spr_xucr1_ll_tb_sel             : std_ulogic_vector(0 to 2);
signal spr_xucr1_ll_sel                : std_ulogic;
signal spr_xucr1_ll_en                 : std_ulogic;
signal ex6_acop_di                     : std_ulogic_vector(acop_q'range);
signal ex6_ccr3_di                     : std_ulogic_vector(ccr3_q'range);
signal ex6_csrr0_di                    : std_ulogic_vector(csrr0_q'range);
signal ex6_csrr1_di                    : std_ulogic_vector(csrr1_q'range);
signal ex6_dbcr0_di                    : std_ulogic_vector(dbcr0_q'range);
signal ex6_dbcr1_di                    : std_ulogic_vector(dbcr1_q'range);
signal ex6_dbsr_di                     : std_ulogic_vector(dbsr_q'range);
signal ex6_dear_di                     : std_ulogic_vector(dear_q'range);
signal ex6_dec_di                      : std_ulogic_vector(dec_q'range);
signal ex6_decar_di                    : std_ulogic_vector(decar_q'range);
signal ex6_epcr_di                     : std_ulogic_vector(epcr_q'range);
signal ex6_esr_di                      : std_ulogic_vector(esr_q'range);
signal ex6_gdear_di                    : std_ulogic_vector(gdear_q'range);
signal ex6_gesr_di                     : std_ulogic_vector(gesr_q'range);
signal ex6_gpir_di                     : std_ulogic_vector(gpir_q'range);
signal ex6_gsrr0_di                    : std_ulogic_vector(gsrr0_q'range);
signal ex6_gsrr1_di                    : std_ulogic_vector(gsrr1_q'range);
signal ex6_hacop_di                    : std_ulogic_vector(hacop_q'range);
signal ex6_mcsr_di                     : std_ulogic_vector(mcsr_q'range);
signal ex6_mcsrr0_di                   : std_ulogic_vector(mcsrr0_q'range);
signal ex6_mcsrr1_di                   : std_ulogic_vector(mcsrr1_q'range);
signal ex6_msr_di                      : std_ulogic_vector(msr_q'range);
signal ex6_msrp_di                     : std_ulogic_vector(msrp_q'range);
signal ex6_srr0_di                     : std_ulogic_vector(srr0_q'range);
signal ex6_srr1_di                     : std_ulogic_vector(srr1_q'range);
signal ex6_tcr_di                      : std_ulogic_vector(tcr_q'range);
signal ex6_tsr_di                      : std_ulogic_vector(tsr_q'range);
signal ex6_udec_di                     : std_ulogic_vector(udec_q'range);
signal ex6_xucr1_di                    : std_ulogic_vector(xucr1_q'range);
signal
	ex2_acop_rdec  , ex2_ccr3_rdec  , ex2_csrr0_rdec , ex2_csrr1_rdec 
 , ex2_ctr_rdec   , ex2_dbcr0_rdec , ex2_dbcr1_rdec , ex2_dbcr2_rdec 
 , ex2_dbcr3_rdec , ex2_dbsr_rdec  , ex2_dear_rdec  , ex2_dec_rdec   
 , ex2_decar_rdec , ex2_epcr_rdec  , ex2_esr_rdec   , ex2_gdear_rdec 
 , ex2_gesr_rdec  , ex2_gpir_rdec  , ex2_gsrr0_rdec , ex2_gsrr1_rdec 
 , ex2_hacop_rdec , ex2_iar_rdec   , ex2_lr_rdec    , ex2_mcsr_rdec  
 , ex2_mcsrr0_rdec, ex2_mcsrr1_rdec, ex2_msrp_rdec  , ex2_srr0_rdec  
 , ex2_srr1_rdec  , ex2_tcr_rdec   , ex2_tsr_rdec   , ex2_udec_rdec  
 , ex2_xer_rdec   , ex2_xucr1_rdec 
													: std_ulogic;
signal
	ex2_acop_re    , ex2_ccr3_re    , ex2_csrr0_re   , ex2_csrr1_re   
 , ex2_ctr_re     , ex2_dbcr0_re   , ex2_dbcr1_re   , ex2_dbcr2_re   
 , ex2_dbcr3_re   , ex2_dbsr_re    , ex2_dear_re    , ex2_dec_re     
 , ex2_decar_re   , ex2_epcr_re    , ex2_esr_re     , ex2_gdear_re   
 , ex2_gesr_re    , ex2_gpir_re    , ex2_gsrr0_re   , ex2_gsrr1_re   
 , ex2_hacop_re   , ex2_iar_re     , ex2_lr_re      , ex2_mcsr_re    
 , ex2_mcsrr0_re  , ex2_mcsrr1_re  , ex2_msrp_re    , ex2_srr0_re    
 , ex2_srr1_re    , ex2_tcr_re     , ex2_tsr_re     , ex2_udec_re    
 , ex2_xer_re     , ex2_xucr1_re   
													: std_ulogic;
signal ex2_pir_rdec                                  : std_ulogic;
signal
	ex2_acop_we    , ex2_ccr3_we    , ex2_csrr0_we   , ex2_csrr1_we   
 , ex2_ctr_we     , ex2_dbcr0_we   , ex2_dbcr1_we   , ex2_dbcr2_we   
 , ex2_dbcr3_we   , ex2_dbsr_we    , ex2_dbsrwr_we  , ex2_dear_we    
 , ex2_dec_we     , ex2_decar_we   , ex2_epcr_we    , ex2_esr_we     
 , ex2_gdear_we   , ex2_gesr_we    , ex2_gpir_we    , ex2_gsrr0_we   
 , ex2_gsrr1_we   , ex2_hacop_we   , ex2_iar_we     , ex2_lr_we      
 , ex2_mcsr_we    , ex2_mcsrr0_we  , ex2_mcsrr1_we  , ex2_msrp_we    
 , ex2_srr0_we    , ex2_srr1_we    , ex2_tcr_we     , ex2_tsr_we     
 , ex2_udec_we    , ex2_xer_we     , ex2_xucr1_we   
													: std_ulogic;
signal
	ex2_acop_wdec  , ex2_ccr3_wdec  , ex2_csrr0_wdec , ex2_csrr1_wdec 
 , ex2_ctr_wdec   , ex2_dbcr0_wdec , ex2_dbcr1_wdec , ex2_dbcr2_wdec 
 , ex2_dbcr3_wdec , ex2_dbsr_wdec  , ex2_dbsrwr_wdec, ex2_dear_wdec  
 , ex2_dec_wdec   , ex2_decar_wdec , ex2_epcr_wdec  , ex2_esr_wdec   
 , ex2_gdear_wdec , ex2_gesr_wdec  , ex2_gpir_wdec  , ex2_gsrr0_wdec 
 , ex2_gsrr1_wdec , ex2_hacop_wdec , ex2_iar_wdec   , ex2_lr_wdec    
 , ex2_mcsr_wdec  , ex2_mcsrr0_wdec, ex2_mcsrr1_wdec, ex2_msrp_wdec  
 , ex2_srr0_wdec  , ex2_srr1_wdec  , ex2_tcr_wdec   , ex2_tsr_wdec   
 , ex2_udec_wdec  , ex2_xer_wdec   , ex2_xucr1_wdec 
													: std_ulogic;
signal
	ex6_acop_wdec  , ex6_ccr3_wdec  , ex6_csrr0_wdec , ex6_csrr1_wdec 
 , ex6_dbcr0_wdec , ex6_dbcr1_wdec , ex6_dbsr_wdec  , ex6_dbsrwr_wdec
 , ex6_dear_wdec  , ex6_dec_wdec   , ex6_decar_wdec , ex6_epcr_wdec  
 , ex6_esr_wdec   , ex6_gdear_wdec , ex6_gesr_wdec  , ex6_gpir_wdec  
 , ex6_gsrr0_wdec , ex6_gsrr1_wdec , ex6_hacop_wdec , ex6_mcsr_wdec  
 , ex6_mcsrr0_wdec, ex6_mcsrr1_wdec, ex6_msr_wdec   , ex6_msrp_wdec  
 , ex6_srr0_wdec  , ex6_srr1_wdec  , ex6_tcr_wdec   , ex6_tsr_wdec   
 , ex6_udec_wdec  , ex6_xucr1_wdec 
													: std_ulogic;
signal
	ex6_acop_we    , ex6_ccr3_we    , ex6_csrr0_we   , ex6_csrr1_we   
 , ex6_dbcr0_we   , ex6_dbcr1_we   , ex6_dbsr_we    , ex6_dbsrwr_we  
 , ex6_dear_we    , ex6_dec_we     , ex6_decar_we   , ex6_epcr_we    
 , ex6_esr_we     , ex6_gdear_we   , ex6_gesr_we    , ex6_gpir_we    
 , ex6_gsrr0_we   , ex6_gsrr1_we   , ex6_hacop_we   , ex6_mcsr_we    
 , ex6_mcsrr0_we  , ex6_mcsrr1_we  , ex6_msr_we     , ex6_msrp_we    
 , ex6_srr0_we    , ex6_srr1_we    , ex6_tcr_we     , ex6_tsr_we     
 , ex6_udec_we    , ex6_xucr1_we   
													: std_ulogic;
signal
	acop_act       , ccr3_act       , csrr0_act      , csrr1_act      
 , dbcr0_act      , dbcr1_act      , dbsr_act       , dear_act       
 , dec_act        , decar_act      , epcr_act       , esr_act        
 , gdear_act      , gesr_act       , gpir_act       , gsrr0_act      
 , gsrr1_act      , hacop_act      , mcsr_act       , mcsrr0_act     
 , mcsrr1_act     , msr_act        , msrp_act       , srr0_act       
 , srr1_act       , tcr_act        , tsr_act        , udec_act       
 , xucr1_act      
													: std_ulogic;
signal
	acop_do        , ccr3_do        , csrr0_do       , csrr1_do       
 , dbcr0_do       , dbcr1_do       , dbsr_do        , dear_do        
 , dec_do         , decar_do       , epcr_do        , esr_do         
 , gdear_do       , gesr_do        , gpir_do        , gsrr0_do       
 , gsrr1_do       , hacop_do       , mcsr_do        , mcsrr0_do      
 , mcsrr1_do      , msr_do         , msrp_do        , srr0_do        
 , srr1_do        , tcr_do         , tsr_do         , udec_do        
 , xucr1_do       
													: std_ulogic_vector(0 to 64);

begin


tiup           <= '1';
tidn           <= (others=>'0');

exx_act_d         <= cspr_tspr_rf1_act & exx_act(1 to 4);

exx_act(1)        <= exx_act_q(1);
exx_act(2)        <= exx_act_q(2);
exx_act(3)        <= exx_act_q(3);
exx_act(4)        <= exx_act_q(4);
exx_act(5)        <= exx_act_q(5);

exx_act_data(1)   <= exx_act(1);
exx_act_data(2)   <= exx_act(2);
exx_act_data(3)   <= exx_act(3);
exx_act_data(4)   <= exx_act(4);
exx_act_data(5)   <= exx_act(5);

ex5_int_act    <= cpl_spr_ex5_act or cspr_xucr0_clkg_ctl(4);

-- Decode
ex1_opcode_is_31        <= cspr_tspr_ex1_instr(0 to 5) = "011111";
ex1_opcode_is_19        <= cspr_tspr_ex1_instr(0 to 5) = "010011";
ex1_is_mfspr            <= '1' when ex1_opcode_is_31 and cspr_tspr_ex1_instr(21 to 30) = "0101010011" else '0'; -- 31/339
ex1_is_mtspr            <= '1' when ex1_opcode_is_31 and cspr_tspr_ex1_instr(21 to 30) = "0111010011" else '0'; -- 31/467
ex1_is_mfmsr            <= '1' when ex1_opcode_is_31 and cspr_tspr_ex1_instr(21 to 30) = "0001010011" else '0'; -- 31/083
ex1_is_rfi              <= '1' when ex1_opcode_is_19 and cspr_tspr_ex1_instr(21 to 30) = "0000110010" else '0'; -- 19/050
ex1_is_rfgi             <= '1' when ex1_opcode_is_19 and cspr_tspr_ex1_instr(21 to 30) = "0001100110" else '0'; -- 19/102
ex1_is_rfci             <= '1' when ex1_opcode_is_19 and cspr_tspr_ex1_instr(21 to 30) = "0000110011" else '0'; -- 19/051
ex1_is_rfmci            <= '1' when ex1_opcode_is_19 and cspr_tspr_ex1_instr(21 to 30) = "0000100110" else '0'; -- 19/038
ex1_is_wrteei           <= '1' when ex1_opcode_is_31 and cspr_tspr_ex1_instr(21 to 30) = "0010100011" else '0'; -- 31/163

ex2_instr_d    <= gate(cspr_tspr_ex1_instr(11 to 20),(ex1_is_mfspr or ex1_is_mtspr or ex1_is_wrteei));

ex2_is_mfmsr   <= ex2_is_mfmsr_q;
ex2_is_mfspr   <= ex2_is_mfspr_q;
ex2_is_mtspr   <= ex2_is_mtspr_q;
ex2_instr      <= ex2_instr_q;
ex6_is_mtmsr   <= ex6_is_mtmsr_q;
ex6_is_mtspr   <= ex6_is_mtspr_q;
ex6_instr      <= ex6_instr_q;
ex6_spr_wd     <= ex6_spr_wd_q;

ex4_val        <= dec_spr_ex4_val and not xu_ex4_flush;
ex5_val        <= ex5_val_q       and not xu_ex5_flush;
ex6_val        <= ex6_val_q;
ex2_rfgi_d     <=(ex1_is_rfi and     mux_msr_gs_q(0)) or ex1_is_rfgi;
ex2_rfi_d      <= ex1_is_rfi and not mux_msr_gs_q(0);
ex6_any_int    <= ex6_int_q or ex6_cint_q or ex6_mcint_q or ex6_gint_q;
ex6_any_hint   <= ex6_int_q or ex6_cint_q or ex6_mcint_q;
ex6_rfi        <= ex6_val and ex6_rfi_q;
ex6_rfgi       <= ex6_val and ex6_rfgi_q;
ex6_rfci       <= ex6_val and ex6_rfci_q;
ex6_rfmci      <= ex6_val and ex6_rfmci_q;
ex6_wrteei     <= ex6_val and ex6_wrteei_q;
ex6_wrtee      <= ex6_val and ex6_wrtee_q;

ex3_tid_rpwr_d <= (others=>cspr_tspr_ex2_tid);

tb_tap_edge    <= cspr_tspr_timebase_taps and not timebase_taps_q;


-- SPR Input Control
-- ACOP
acop_act      <= ex6_acop_we;
acop_d        <= ex6_acop_di;

-- CCR3
ccr3_act       <= ex6_ccr3_we;
ccr3_d         <= ex6_ccr3_di;

-- CSRR0
csrr0_act      <= ex6_csrr0_we or ex6_cint_q;

with ex6_cint_q select
   csrr0_d     <= ex6_nia_srr0               when '1',
                  ex6_csrr0_di               when others;

-- CSRR1
csrr1_act      <= ex6_csrr1_we or ex6_cint_q;

csrr1_gen_64 : if regsize = 64 generate
   ex6_csrr1_d                   <= ex6_csrr1_di;
end generate;
csrr1_gen_32 : if regsize = 32 generate
   ex6_csrr1_d(MSR_CM)           <= '0';
   ex6_csrr1_d(MSR_GS to MSR_DS) <= ex6_csrr1_di(MSR_GS to MSR_DS);
end generate;

with ex6_cint_q select
   csrr1_d     <= msr_q                      when '1',     
                  ex6_csrr1_d                when others;

-- DBCR0
dbcr0_act      <= ex6_dbcr0_we;
dbcr0_d        <= ex6_dbcr0_di;

-- DBCR1
dbcr1_act      <= ex6_dbcr1_we;
dbcr1_d        <= ex6_dbcr1_di;

-- DBSR
reset_complete_act <= or_reduce(reset_complete);

dbsr_mrr_act   <= reset_complete_act or ex6_dbsr_we or ex6_dbsrwr_we;

dbsr_mrr_d     <= reset_complete                               when reset_complete_act ='1' else
                  ex6_spr_wd(34 to 35)                         when ex6_dbsrwr_we     ='1' else
                  (dbsr_mrr_q and not ex6_spr_wd(34 to 35));

dbsr_act       <= ex6_dbsr_we or ex6_dbsrwr_we or ex6_dbsr_update_q;

-- BRT and ICMP event can never set IDE.
set_dbsr_ide   <= ((ex6_dbsr_q(0) or or_reduce(ex6_dbsr_q(3 to 18))) and not msr_q(60)) or ex6_dbsr_ide_q;
set_dbsr       <= set_dbsr_ide & ex6_dbsr_q(0 to 18);

dbsr_d         <=  dbsr_di or gate(set_dbsr,ex6_dbsr_update_q);
dbsr_di        <= ex6_dbsr_di                   when ex6_dbsrwr_we     ='1' else
                  (dbsr_q and not ex6_dbsr_di)  when ex6_dbsr_we       ='1' else
                   dbsr_q;

-- DEAR
dear_act       <= ex6_dear_we  or (ex6_dear_update_q and not ex6_gint_q);

dear_tmp_d(32 to 63) <= ex6_dear_di(32 to 63);
dear_di(32 to 63)    <= ex6_dear_di(32 to 63);
xuq_cpl_dear_mask_gen0 : if (64-regsize) < 32 generate
   dear_di(dear_d'left to 31)    <= ex6_dear_di(dear_d'left to 31) and (dear_d'left to 31=>(spr_msr_cm or not ex6_dear_update_q));
   dear_tmp_d(dear_d'left to 31) <= ex6_dear_di(dear_d'left to 31) and (dear_d'left to 31=> spr_msr_cm);
end generate;

with ex6_dear_update_saved_q select
   dear_d      <= dear_tmp_q        when '1',
                  dear_di           when others;

-- GDEAR
gdear_act      <= ex6_gdear_we or (ex6_dear_update_q and     ex6_gint_q);

gdear_d        <= dear_d;

-- DEC
dec_running    <= timer_update and not (not spr_tcr_are and ex6_dec_zero) and not cspr_tspr_dec_dbg_dis and not dbcr0_freeze_timers;

dec_act        <= ex6_dec_we or dec_running;

dec_d          <= ex6_dec_di     when ex6_dec_we                        ='1' else
                  decar_q        when (ex6_set_tsr_dis and spr_tcr_are) ='1' else
                  std_ulogic_vector(unsigned(dec_q) - 1);

-- UDEC
udec_running   <= timer_update and not ex6_udec_zero and not cspr_tspr_dec_dbg_dis and not dbcr0_freeze_timers;

udec_act       <= ex6_udec_we or udec_running;

udec_d         <= ex6_udec_di     when ex6_udec_we                     ='1' else
                  std_ulogic_vector(unsigned(udec_q) - 1);
                  
-- DECAR
decar_act      <= ex6_decar_we;
decar_d        <= ex6_decar_di;

-- EPCR
epcr_act       <= ex6_epcr_we;
epcr_d         <= ex6_epcr_di;

-- ESR
esr_act        <= ex6_esr_we or (ex6_esr_update_q and ex6_int_q);

esr_d          <= ex6_esr_q   when ex6_esr_update_q         ='1' else
                  ex6_esr_di        when ex6_esr_we                     ='1' else
                  esr_q;

-- GESR
gesr_act       <= ex6_gesr_we or (ex6_esr_update_q and ex6_gint_q);

gesr_d         <= ex6_esr_q   when ex6_esr_update_q         ='1' else
                  ex6_gesr_di       when ex6_gesr_we                    ='1' else
                  gesr_q;

-- GPIR
gpir_act       <= ex6_gpir_we;
gpir_d         <= ex6_gpir_di;

-- HACOP
hacop_act      <= ex6_hacop_we;
hacop_d        <= ex6_hacop_di;

-- MCSR
mcsr_act       <= ex6_mcsr_we or ex6_mcint_q;

mcsr_d         <= ex6_mcsr_q  when ex6_mcint_q              ='1' else
                  ex6_mcsr_di       when ex6_mcsr_we                    ='1' else
                  mcsr_q;

-- MCSRR0
mcsrr0_act     <= ex6_mcsrr0_we or ex6_mcint_q;

with ex6_mcint_q select
   mcsrr0_d       <= ex6_nia_srr0            when '1',
                     ex6_mcsrr0_di           when others;

-- MCSRR1
mcsrr1_act     <= ex6_mcsrr1_we or ex6_mcint_q;

mcsrr1_gen_64 : if regsize = 64 generate
   ex6_mcsrr1_d                     <= ex6_mcsrr1_di;
end generate;
mcsrr1_gen_32 : if regsize = 32 generate
   ex6_mcsrr1_d(MSR_CM)             <= '0';
   ex6_mcsrr1_d(MSR_GS to MSR_DS)   <= ex6_mcsrr1_di(MSR_GS to MSR_DS);
end generate;

with ex6_mcint_q select
   mcsrr1_d       <= msr_q                   when '1',
                     ex6_mcsrr1_d            when others;

-- MSR
msr_act        <= cspr_xucr0_clkg_ctl(4) or 
                  ex6_any_int or ex6_msr_we or
                  ex6_wrteei_q or ex6_wrtee_q or
                  ex6_rfi_q or ex6_rfgi_q or ex6_rfci_q or ex6_rfmci_q;

-- CM GS UCLE SPV CE EE PR FP ME FE0 DE FE1 IS DS
-- 50 51 52   53  54 55 56 57 58 59  60 61  62 63
--       X                           X             MSRP

with (msrp_q(MSRP_UCLEP) and msr_q(MSR_GS)) select
   ex6_msr_di2(MSR_UCLE)            <= msr_q(MSR_UCLE)         when '1',
                                       ex6_msr_di(MSR_UCLE)    when others;

with (msrp_q(MSRP_DEP)   and msr_q(MSR_GS)) select
   ex6_msr_di2(MSR_DE)              <= msr_q(MSR_DE)           when '1',
                                       ex6_msr_di(MSR_DE)      when others;

ex6_msr_di2(MSR_CM)                 <= ex6_msr_di(MSR_CM);
ex6_msr_di2(MSR_GS)                 <= ex6_msr_di(MSR_GS) or msr_q(MSR_GS);
ex6_msr_di2(MSR_SPV to MSR_FE0)     <= ex6_msr_di(MSR_SPV to MSR_FE0);
ex6_msr_di2(MSR_FE1 to MSR_DS)      <= ex6_msr_di(MSR_FE1 to MSR_DS);


-- 0 leave unchanged
-- 1 clear
ex6_msr_mask(MSR_CM)             <= '0';                                                     -- CM
ex6_msr_mask(MSR_GS)             <= ex6_any_hint;                                            -- GS
ex6_msr_mask(MSR_UCLE)           <= ex6_any_hint or (ex6_gint_q and not msrp_q(MSRP_UCLEP)); -- UCLE
ex6_msr_mask(MSR_SPV)            <= ex6_any_int;                                             -- SPV
ex6_msr_mask(MSR_CE)             <= ex6_mcint_q or ex6_cint_q;                               -- CE
ex6_msr_mask(MSR_EE)             <= ex6_any_int;                                             -- EE
ex6_msr_mask(MSR_PR to MSR_FP)   <= (others=>ex6_any_int);                                   -- PR,FP
ex6_msr_mask(MSR_ME)             <= ex6_mcint_q;                                             -- ME
ex6_msr_mask(MSR_FE0)            <= ex6_any_int;                                             -- FE0
ex6_msr_mask(MSR_DE)             <= ex6_mcint_q or ex6_cint_q;                               -- DE
ex6_msr_mask(MSR_FE1 to MSR_DS)  <= (others=>ex6_any_int);                                   -- FE1,IS,DS
                     
with s5'(ex6_rfi & ex6_rfgi & ex6_rfci & ex6_rfmci & ex6_msr_we) select
   ex6_msr_mux    <= srr1_q                  when "10000",
                     ex6_rfgi_msr            when "01000",
                     csrr1_q                 when "00100",
                     mcsrr1_q                when "00010",
                     ex6_msr_di2             when "00001",                     
                     msr_q                   when others;

ex6_msr_in(51 to 54) <= ex6_msr_mux(51 to 54);
ex6_msr_in(56 to 63) <= ex6_msr_mux(56 to 63);

with s2'(ex6_any_hint & ex6_gint_q) select
   ex6_msr_in(MSR_CM)   <= spr_epcr_icm            when "10",     --  ICM
                           spr_epcr_gicm           when "01",     -- GICM
                           ex6_msr_mux(MSR_CM)     when others;   --   CM

with s2'(ex6_wrteei & ex6_wrtee) select
   ex6_msr_in(MSR_EE)   <= ex6_instr_q(16)         when "10",
                           ex6_spr_wd(48)          when "01",
                           ex6_msr_mux(MSR_EE)     when others;

msr_gen_64 : if regsize = 64 generate
   msr_d                <= ex6_msr_in and not ex6_msr_mask;
end generate;
msr_gen_32 : if regsize = 32 generate
   msr_d(MSR_CM)           <= '0';
   msr_d(MSR_GS to MSR_DS) <= ex6_msr_in(MSR_GS to MSR_DS) and not ex6_msr_mask(MSR_GS to MSR_DS);
end generate;

-- rfgi msr
ex6_rfgi_msr(MSR_CM)                <= gsrr1_q(MSR_CM);
ex6_rfgi_msr(MSR_SPV to MSR_FE0)    <= gsrr1_q(MSR_SPV to MSR_FE0);
ex6_rfgi_msr(MSR_FE1 to MSR_DS)     <= gsrr1_q(MSR_FE1 to MSR_DS);

with (msr_q(MSR_GS)) select
   ex6_rfgi_msr(MSR_GS)                <= msr_q(MSR_GS)        when '1',
                                          gsrr1_q(MSR_GS)      when others;

with (msrp_q(MSRP_UCLEP) and msr_q(MSR_GS)) select
   ex6_rfgi_msr(MSR_UCLE)              <= msr_q(MSR_UCLE)      when '1',
                                          gsrr1_q(MSR_UCLE)    when others;

with (msrp_q(MSRP_DEP)   and msr_q(MSR_GS)) select
   ex6_rfgi_msr(MSR_DE)                <= msr_q(MSR_DE)        when '1',
                                          gsrr1_q(MSR_DE)      when others;

-- MSRP
msrp_act       <= ex6_msrp_we;
msrp_d         <= ex6_msrp_di;

-- SRR0
srr0_act       <= ex6_srr0_we or (ex6_int_q and not ex6_force_gsrr_q);

-- Subtract one for enabled program interrupts
ex6_nia_srr0_dec <= (ex6_nia_q'left to 60=>'0') & ex6_srr0_dec_q;
ex6_nia_srr0      <= std_ulogic_vector(unsigned(ex6_nia_q) - unsigned(ex6_nia_srr0_dec));

with ex6_int_q select
   srr0_d      <= ex6_nia_srr0               when '1',
                  ex6_srr0_di                when others;

-- SRR1
srr1_act       <= ex6_srr1_we or (ex6_int_q and not ex6_force_gsrr_q);

srr1_gen_64 : if regsize = 64 generate
   ex6_srr1_d                    <= ex6_srr1_di;
end generate;
srr1_gen_32 : if regsize = 32 generate
   ex6_srr1_d(MSR_CM)            <= '0';
   ex6_srr1_d(MSR_GS to MSR_DS)  <= ex6_srr1_di(MSR_GS to MSR_DS);
end generate;

with ex6_int_q select
   srr1_d      <= msr_q                      when '1',     
                  ex6_srr1_d                 when others;


-- GSRR0
ex6_gint_nia_sel               <= ex6_gint_q or (ex6_int_q and ex6_force_gsrr_q);

gsrr0_act      <= ex6_gsrr0_we or ex6_gint_nia_sel;


with ex6_gint_nia_sel select
   gsrr0_d     <= ex6_nia_srr0               when '1',
                  ex6_gsrr0_di               when others;

-- GSRR1
gsrr1_act      <= ex6_gsrr1_we or ex6_gint_nia_sel;

gsrr1_gen_64 : if regsize = 64 generate
   ex6_gsrr1_d                   <= ex6_gsrr1_di;
end generate;
gsrr1_gen_32 : if regsize = 32 generate
   ex6_gsrr1_d(MSR_CM)           <= '0';
   ex6_gsrr1_d(MSR_GS to MSR_DS) <= ex6_gsrr1_di(MSR_GS to MSR_DS);
end generate;

with ex6_gint_nia_sel select
   gsrr1_d     <= msr_q                      when '1',     
                  ex6_gsrr1_d                when others;

-- TCR
tcr_act        <= ex6_tcr_we;
tcr_d          <= ex6_tcr_di;

-- TSR
tsr_wrs_act    <= (reset_wd_complete and reset_complete_act) or ex6_tsr_we;

tsr_wrs_d      <= reset_complete                when (reset_wd_complete and reset_complete_act) ='1' else
                 (tsr_wrs_q and not ex6_spr_wd(34 to 35));

tsr_act        <= cspr_xucr0_clkg_ctl(4) or ex6_tsr_we or or_reduce(ex6_set_tsr);

tsr_d          <= ex6_set_tsr or (tsr_q and not (ex6_tsr_di and (tsr_q'range=>ex6_tsr_we)));

-- XUCR1
xucr1_act         <= ex6_xucr1_we;
xucr1_d           <= ex6_xucr1_di;

-- LiveLock Buster!
with spr_xucr1_ll_tb_sel select
   lltbtap        <= tb_tap_edge(8)                when "000",
                     tb_tap_edge(5)                when "001",
                     tb_tap_edge(4)                when "010",
                     tb_tap_edge(3)                when "011",
                     tb_tap_edge(7)                when "100",
                     tb_tap_edge(2)                when "101",
                     tb_tap_edge(6)                when "110",
                     tb_tap_edge(1)                when others;

hang_pulse_d      <= an_ac_hang_pulse & hang_pulse_q(0 to 2);
hang_pulse        <= hang_pulse_q(2) and not hang_pulse_q(3);
 

with spr_xucr1_ll_sel select
   lltap_d        <= hang_pulse                    when '1',
                     lltbtap                       when others;

llpulse           <= not llcnt_q(0) and               -- Stop if counter == "10"
                     cspr_tspr_llen and               -- Don't pulse if stopped
                     spr_xucr1_ll_en and              -- Gate off if disabled
                     lltap_q;
                     
llreset           <= (cpl_spr_ex5_instr_cpl and not ((inj_llbust_attempt_q and not llcnt_q(0)) or inj_llbust_failed_q)) or not cspr_tspr_llen;

with s2'(llpulse & llreset) select
   llcnt_d     <= "00"                    when "01",
                  "00"                    when "11",
std_ulogic_vector(signed(llcnt_q) + 1)    when "10", 
                  llcnt_q                 when others;
                  
tspr_cspr_lldet   <= llcnt_q(0) and spr_xucr1_ll_en;
tspr_cspr_llpulse <= llpulse;

llstate(0)        <= llcnt_q(0);
llstate(1)        <= llcnt_q(1) or (llcnt_q(0) and not cspr_tspr_llpri);

-- Raise the priority for threads that are in livelock
-- Raise the priroity for threads with EE=0
raise_iss_pri_d            <= (not spr_msr_ee   and spr_ccr3_en_eepri) or 
                              (llcnt_q(0)       and spr_xucr1_ll_en);
xu_iu_raise_iss_pri        <= raise_iss_pri_2_q;

err_llbust_attempt_d <= llstate(0) and not llstate(1);
err_llbust_failed_d  <= llstate(0) and     cspr_tspr_llen and spr_xucr1_ll_en and lltap_q and cspr_tspr_llpri;

xu_spr_tspr_llbust_err_rpt : entity tri.tri_direct_err_rpt(tri_direct_err_rpt) 
generic map(width => 2, expand_type => expand_type)
port map (  vd => vdd, gd => gnd,
            err_in(0)   => err_llbust_attempt_q,
            err_in(1)   => err_llbust_failed_q,
            err_out(0)  => xu_pc_err_llbust_attempt,
            err_out(1)  => xu_pc_err_llbust_failed);

-- Decrementer Logic
ex6_dec_upper_zero   <= not or_reduce(dec_q(32 to 62));
ex6_set_tsr_dis      <=  dec_running and ex6_dec_upper_zero and     dec_q(63);
ex6_dec_zero         <=                  ex6_dec_upper_zero and not dec_q(63);

ex6_udec_upper_zero  <= not or_reduce(udec_q(32 to 62));
ex6_set_tsr_udis     <= udec_running and ex6_udec_upper_zero and     udec_q(63);
ex6_udec_zero        <=                  ex6_udec_upper_zero and not udec_q(63);

-- Fixed Interval Timer logic
with spr_tcr_fp select
   fit_tb_tap_d   <= tb_tap_edge(5)                when "00",
                     tb_tap_edge(4)                when "01",
                     tb_tap_edge(3)                when "10",
                     tb_tap_edge(2)                when others;                    

ex6_set_tsr_fis   <= fit_tb_tap_q;

-- Watchdog Timer Logic
with spr_tcr_wp select
   wdog_tb_tap_d  <= tb_tap_edge(3)                when "00",
                     tb_tap_edge(2)                when "01",
                     tb_tap_edge(9)                when "10",
                     tb_tap_edge(0)                when others;                    

wdog_pulse        <= wdog_tb_tap_q or pc_xu_inj_wdt_reset_q;

ex6_set_tsr_enw   <=           wdog_pulse and not spr_tsr_enw;
ex6_set_tsr_wis   <=           wdog_pulse and     spr_tsr_enw and not spr_tsr_wis;

ex6_set_tsr       <= ex6_set_tsr_enw &
                     ex6_set_tsr_wis &
                     ex6_set_tsr_dis &
                     ex6_set_tsr_fis &
                     ex6_set_tsr_udis;


-- Resets
reset_complete    <= "11" when reset_3_complete='1' else
                     "10" when reset_2_complete='1' else
                     "01" when reset_1_complete='1' else
                     "00";

wdog_reset_1      <= spr_tsr_enw and spr_tsr_wis and     (spr_tcr_wrc="01");
wdog_reset_2      <= spr_tsr_enw and spr_tsr_wis and     (spr_tcr_wrc="10");
wdog_reset_3      <= spr_tsr_enw and spr_tsr_wis and     (spr_tcr_wrc="11");
reset_wd_request  <= spr_tsr_enw and spr_tsr_wis and not (spr_tcr_wrc="00");

reset_1_request   <= wdog_reset_1 or (spr_dbcr0_rst="01");
reset_2_request   <= wdog_reset_2 or (spr_dbcr0_rst="10");
reset_3_request   <= wdog_reset_3 or (spr_dbcr0_rst="11");
err_wdt_reset_d   <= spr_tsr_enw and spr_tsr_wis and or_reduce(spr_tcr_wrc);

xu_spr_tspr_wdt_err_rpt : entity tri.tri_direct_err_rpt(tri_direct_err_rpt) 
generic map (width => 1, expand_type => expand_type)
port map (vd => vdd, gd => gnd,
          err_in(0)     => err_wdt_reset_q,
          err_out(0)    => xu_pc_err_wdt_reset);

-- DBCR0[FT] Freeze timers
dbcr0_freeze_timers     <= spr_dbcr0_ft and (spr_dbsr_ide or dbsr_event);
tspr_cspr_freeze_timers <= dbcr0_freeze_timers;


-- ICSWX
ex2_icswx_gs   <= epsc_egs_q when ex2_epid_instr_q='1' else spr_msr_gs;
ex2_icswx_pr   <= epsc_epr_q when ex2_epid_instr_q='1' else spr_msr_pr;
   
-- Only Check ACOP in problem state (PR=1)
ex2_acop_ct    <= gate_or(not ex2_icswx_pr,spr_acop_ct);

ex2_cop_ct     <= spr_hacop_ct and ex2_acop_ct;

-- Only Check ACOP/HACOP if not in Hypervisor
ex3_ct_d(0)    <= ex2_ct(0) or (not ex2_icswx_pr and not ex2_icswx_gs); -- Big Endian
ex3_ct_d(1)    <= ex2_ct(1) or (not ex2_icswx_pr and not ex2_icswx_gs); -- Little Endian
 
with ex2_rs2_q(42 to 47) select -- Big Endian
   ex2_ct(0)<= ex2_cop_ct(32)    when "100000",
               ex2_cop_ct(33)    when "100001",
               ex2_cop_ct(34)    when "100010",
               ex2_cop_ct(35)    when "100011",
               ex2_cop_ct(36)    when "100100",
               ex2_cop_ct(37)    when "100101",
               ex2_cop_ct(38)    when "100110",
               ex2_cop_ct(39)    when "100111",
               ex2_cop_ct(40)    when "101000",
               ex2_cop_ct(41)    when "101001",
               ex2_cop_ct(42)    when "101010",
               ex2_cop_ct(43)    when "101011",
               ex2_cop_ct(44)    when "101100",
               ex2_cop_ct(45)    when "101101",
               ex2_cop_ct(46)    when "101110",
               ex2_cop_ct(47)    when "101111",
               ex2_cop_ct(48)    when "110000",
               ex2_cop_ct(49)    when "110001",
               ex2_cop_ct(50)    when "110010",
               ex2_cop_ct(51)    when "110011",
               ex2_cop_ct(52)    when "110100",
               ex2_cop_ct(53)    when "110101",
               ex2_cop_ct(54)    when "110110",
               ex2_cop_ct(55)    when "110111",
               ex2_cop_ct(56)    when "111000",
               ex2_cop_ct(57)    when "111001",
               ex2_cop_ct(58)    when "111010",
               ex2_cop_ct(59)    when "111011",
               ex2_cop_ct(60)    when "111100",
               ex2_cop_ct(61)    when "111101",
               ex2_cop_ct(62)    when "111110",
               ex2_cop_ct(63)    when "111111",
               '0'               when others;

with ex2_rs2_q(50 to 55) select -- Little Endian
   ex2_ct(1)<= ex2_cop_ct(32)    when "100000",
               ex2_cop_ct(33)    when "100001",
               ex2_cop_ct(34)    when "100010",
               ex2_cop_ct(35)    when "100011",
               ex2_cop_ct(36)    when "100100",
               ex2_cop_ct(37)    when "100101",
               ex2_cop_ct(38)    when "100110",
               ex2_cop_ct(39)    when "100111",
               ex2_cop_ct(40)    when "101000",
               ex2_cop_ct(41)    when "101001",
               ex2_cop_ct(42)    when "101010",
               ex2_cop_ct(43)    when "101011",
               ex2_cop_ct(44)    when "101100",
               ex2_cop_ct(45)    when "101101",
               ex2_cop_ct(46)    when "101110",
               ex2_cop_ct(47)    when "101111",
               ex2_cop_ct(48)    when "110000",
               ex2_cop_ct(49)    when "110001",
               ex2_cop_ct(50)    when "110010",
               ex2_cop_ct(51)    when "110011",
               ex2_cop_ct(52)    when "110100",
               ex2_cop_ct(53)    when "110101",
               ex2_cop_ct(54)    when "110110",
               ex2_cop_ct(55)    when "110111",
               ex2_cop_ct(56)    when "111000",
               ex2_cop_ct(57)    when "111001",
               ex2_cop_ct(58)    when "111010",
               ex2_cop_ct(59)    when "111011",
               ex2_cop_ct(60)    when "111100",
               ex2_cop_ct(61)    when "111101",
               ex2_cop_ct(62)    when "111110",
               ex2_cop_ct(63)    when "111111",
               '0'               when others;

spr_cpl_ex3_ct_be          <= ex3_ct_q(0);
spr_cpl_ex3_ct_le          <= ex3_ct_q(1);

-- Debug Enables

iac_us_en(1)         <= (not spr_dbcr1_iac1us(0) and not spr_dbcr1_iac1us(1)) or
                        (    spr_dbcr1_iac1us(0) and    (spr_dbcr1_iac1us(1) xnor spr_msr_pr));

iac_us_en(2)         <= (not spr_dbcr1_iac2us(0) and not spr_dbcr1_iac2us(1)) or
                        (    spr_dbcr1_iac2us(0) and    (spr_dbcr1_iac2us(1) xnor spr_msr_pr));

iac_us_en(3)         <= (not spr_dbcr1_iac3us(0) and not spr_dbcr1_iac3us(1)) or
                        (    spr_dbcr1_iac3us(0) and    (spr_dbcr1_iac3us(1) xnor spr_msr_pr));

iac_us_en(4)         <= (not spr_dbcr1_iac4us(0) and not spr_dbcr1_iac4us(1)) or
                        (    spr_dbcr1_iac4us(0) and    (spr_dbcr1_iac4us(1) xnor spr_msr_pr));

iac_er_en(1)         <= (not spr_dbcr1_iac1er(0) and not spr_dbcr1_iac1er(1)) or
                        (    spr_dbcr1_iac1er(0) and    (spr_dbcr1_iac1er(1) xnor spr_msr_is));

iac_er_en(2)         <= (not spr_dbcr1_iac2er(0) and not spr_dbcr1_iac2er(1)) or
                        (    spr_dbcr1_iac2er(0) and    (spr_dbcr1_iac2er(1) xnor spr_msr_is));

iac_er_en(3)         <= (not spr_dbcr1_iac3er(0) and not spr_dbcr1_iac3er(1)) or
                        (    spr_dbcr1_iac3er(0) and    (spr_dbcr1_iac3er(1) xnor spr_msr_is));

iac_er_en(4)         <= (not spr_dbcr1_iac4er(0) and not spr_dbcr1_iac4er(1)) or
                        (    spr_dbcr1_iac4er(0) and    (spr_dbcr1_iac4er(1) xnor spr_msr_is));

iac1_en_d            <= spr_dbcr0_iac1 and iac_us_en(1) and iac_er_en(1);
iac2_en_d            <= spr_dbcr0_iac2 and iac_us_en(2) and iac_er_en(2);
iac3_en_d            <= spr_dbcr0_iac3 and iac_us_en(3) and iac_er_en(3);
iac4_en_d            <= spr_dbcr0_iac4 and iac_us_en(4) and iac_er_en(4);
spr_cpl_iac1_en      <= iac1_en_q;
spr_cpl_iac2_en      <= iac2_en_q;
spr_cpl_iac3_en      <= iac3_en_q;
spr_cpl_iac4_en      <= iac4_en_q;

-- Async Interrupts
spr_cpl_crit_interrupt    <= crit_interrupt_q;
spr_cpl_wdog_interrupt    <= wdog_interrupt_q;
spr_cpl_dec_interrupt     <= dec_interrupt_q;
spr_cpl_udec_interrupt    <= udec_interrupt_q;
spr_cpl_perf_interrupt    <= perf_interrupt_q;
spr_cpl_fit_interrupt     <= fit_interrupt_q;
spr_cpl_ext_interrupt     <= ext_interrupt_q;
spr_cpl_external_mchk     <= mchk_interrupt_q;

-- Ungated version for CPL
-- Gating for gs|me done at ex5_ivo_sel, which also gates mcsr write.
mchk_int          <= cspr_tspr_crit_mask and an_ac_external_mchk_q;  

mchk_interrupt    <= cspr_tspr_crit_mask and an_ac_external_mchk_q   and (spr_msr_gs or spr_msr_me);
crit_interrupt    <= cspr_tspr_crit_mask and an_ac_crit_interrupt_q  and (spr_msr_gs or spr_msr_ce);
wdog_interrupt    <= cspr_tspr_wdog_mask and spr_tsr_wis             and (spr_msr_gs or spr_msr_ce) and spr_tcr_wie;
dec_interrupt     <= cspr_tspr_dec_mask  and spr_tsr_dis             and (spr_msr_gs or spr_msr_ee) and spr_tcr_die;
udec_interrupt    <= cspr_tspr_udec_mask and spr_tsr_udis            and (spr_msr_gs or spr_msr_ee) and spr_tcr_udie;
perf_interrupt    <= cspr_tspr_perf_mask and an_ac_perf_interrupt_q  and (spr_msr_gs or spr_msr_ee);
fit_interrupt     <= cspr_tspr_fit_mask  and spr_tsr_fis             and (spr_msr_gs or spr_msr_ee) and spr_tcr_fie;
ext_interrupt     <= cspr_tspr_ext_mask  and an_ac_ext_interrupt_q   and ((    spr_epcr_extgs and  spr_msr_gs and spr_msr_ee) or
                                                                          (not spr_epcr_extgs and (spr_msr_gs or  spr_msr_ee)));
tspr_cspr_pm_wake_up    <= ex6_any_int or
                           mchk_interrupt_q or
                           crit_interrupt_q or
                           wdog_interrupt_q or             
                           dec_interrupt_q  or
                           udec_interrupt_q or
                           perf_interrupt_q or
                           fit_interrupt_q  or
                           ext_interrupt_q;
                           
tspr_cspr_async_int     <= an_ac_ext_interrupt_q & an_ac_crit_interrupt_q & an_ac_perf_interrupt_q;
                           
tspr_cspr_gpir_match <= '1' when cspr_tspr_dbell_pirtag = gpir_do(51 to 64) else '0';

-- MSR Override
with cspr_tspr_msrovride_en select
   mux_msr_pr    <= msrovride_pr_q     when '1',
                    spr_msr_pr         when others;
               
with cspr_tspr_msrovride_en select
   mux_msr_gs     <= msrovride_gs_q    when '1',
                     spr_msr_gs        when others;

with cspr_tspr_msrovride_en select
   mux_msr_de     <= msrovride_de_q    when '1',
                     spr_msr_de        when others;

                     
mux_msr_gs_d      <= (others=>mux_msr_gs);
mux_msr_pr_d      <= (others=>mux_msr_pr);

udec_en           <= ram_mode_q or spr_tcr_ud;
               
-- FP Precise Mode
tspr_fp_precise            <= fp_precise;
fp_precise                 <= (spr_msr_fe0 or spr_msr_fe1);

-- IO signal assignments
tspr_msr_de                <= mux_msr_de;
tspr_msr_cm                <= spr_msr_cm;
tspr_msr_is                <= spr_msr_is;
tspr_msr_gs                <= mux_msr_gs_q(3);
tspr_msr_pr                <= mux_msr_pr_q(0);
tspr_msr_ee                <= spr_msr_ee;
tspr_msr_ce                <= spr_msr_ce;
tspr_msr_me                <= spr_msr_me;
tspr_epcr_extgs            <= spr_epcr_extgs;
dbsr_event                 <= or_reduce(dbsr_q(45 to 63));
spr_cpl_dbsr_ide           <= spr_dbsr_ide and dbsr_event;
single_instr_mode_d        <= spr_ccr3_si or (fp_precise and msr_q(MSR_FP)) or instr_trace_mode;
xu_iu_single_instr_mode    <= single_instr_mode_2_q;
machine_check_d            <= or_reduce(mcsr_q);
ac_tc_machine_check        <= machine_check_q;

-- Debug
tspr_debug                 <= ex6_int_q               &
                              ex6_gint_q              &
                              ex6_cint_q              &
                              ex6_mcint_q             &
                              ex6_esr_update_q        &
                              ex6_dbsr_update_q       &
                              ex6_dear_update_q       &
                              ex6_dear_save_q         &
                              ex6_dear_update_saved_q &
                              an_ac_crit_interrupt_q  &
                              an_ac_perf_interrupt_q  &
                              an_ac_ext_interrupt_q;


spr_byp_ex4_is_mtxer       <= ex4_is_mtxer_q;
spr_byp_ex4_is_mfxer       <= ex4_is_mfxer_q;
ex3_is_mfxer_d             <= ex2_is_mfspr and ex2_xer_rdec;
ex3_is_mtxer_d             <= ex2_is_mtspr and ex2_xer_rdec;

ex2_srr0_re2      <= ex2_rfi_q;
ex2_gsrr0_re2     <= ex2_rfgi_q;
ex2_csrr0_re2     <= ex2_rfci_q;
ex2_mcsrr0_re2    <= ex2_rfmci_q;

readmux_00 : if a2mode = 0 and hvmode = 0 generate
ex3_tspr_rt_d <=
	(ccr3_do(DO'range)        and (DO'range => ex2_ccr3_re    )) or
	(dbcr0_do(DO'range)       and (DO'range => ex2_dbcr0_re   )) or
	(dbcr1_do(DO'range)       and (DO'range => ex2_dbcr1_re   )) or
	(dbsr_do(DO'range)        and (DO'range => ex2_dbsr_re    )) or
	(dear_do(DO'range)        and (DO'range => ex2_dear_re    )) or
	(dec_do(DO'range)         and (DO'range => ex2_dec_re     )) or
	(esr_do(DO'range)         and (DO'range => ex2_esr_re     )) or
	(msr_do(DO'range)         and (DO'range => ex2_is_mfmsr   )) or
	(srr0_do(DO'range)        and (DO'range => (ex2_srr0_re or ex2_srr0_re2))) or
	(srr1_do(DO'range)        and (DO'range => ex2_srr1_re    )) or
	(xucr1_do(DO'range)       and (DO'range => ex2_xucr1_re   ));
end generate;
readmux_01 : if a2mode = 0 and hvmode = 1 generate
ex3_tspr_rt_d <=
	(ccr3_do(DO'range)        and (DO'range => ex2_ccr3_re    )) or
	(dbcr0_do(DO'range)       and (DO'range => ex2_dbcr0_re   )) or
	(dbcr1_do(DO'range)       and (DO'range => ex2_dbcr1_re   )) or
	(dbsr_do(DO'range)        and (DO'range => ex2_dbsr_re    )) or
	(dear_do(DO'range)        and (DO'range => ex2_dear_re    )) or
	(dec_do(DO'range)         and (DO'range => ex2_dec_re     )) or
	(epcr_do(DO'range)        and (DO'range => ex2_epcr_re    )) or
	(esr_do(DO'range)         and (DO'range => ex2_esr_re     )) or
	(gdear_do(DO'range)       and (DO'range => ex2_gdear_re   )) or
	(gesr_do(DO'range)        and (DO'range => ex2_gesr_re    )) or
	(gpir_do(DO'range)        and (DO'range => ex2_gpir_re    )) or
	(gsrr0_do(DO'range)       and (DO'range => (ex2_gsrr0_re or ex2_gsrr0_re2))) or
	(gsrr1_do(DO'range)       and (DO'range => ex2_gsrr1_re   )) or
	(hacop_do(DO'range)       and (DO'range => ex2_hacop_re   )) or
	(msr_do(DO'range)         and (DO'range => ex2_is_mfmsr   )) or
	(msrp_do(DO'range)        and (DO'range => ex2_msrp_re    )) or
	(srr0_do(DO'range)        and (DO'range => (ex2_srr0_re or ex2_srr0_re2))) or
	(srr1_do(DO'range)        and (DO'range => ex2_srr1_re    )) or
	(xucr1_do(DO'range)       and (DO'range => ex2_xucr1_re   ));
end generate;
readmux_10 : if a2mode = 1 and hvmode = 0 generate
ex3_tspr_rt_d <=
	(acop_do(DO'range)        and (DO'range => ex2_acop_re    )) or
	(ccr3_do(DO'range)        and (DO'range => ex2_ccr3_re    )) or
	(csrr0_do(DO'range)       and (DO'range => (ex2_csrr0_re or ex2_csrr0_re2))) or
	(csrr1_do(DO'range)       and (DO'range => ex2_csrr1_re   )) or
	(dbcr0_do(DO'range)       and (DO'range => ex2_dbcr0_re   )) or
	(dbcr1_do(DO'range)       and (DO'range => ex2_dbcr1_re   )) or
	(dbsr_do(DO'range)        and (DO'range => ex2_dbsr_re    )) or
	(dear_do(DO'range)        and (DO'range => ex2_dear_re    )) or
	(dec_do(DO'range)         and (DO'range => ex2_dec_re     )) or
	(decar_do(DO'range)       and (DO'range => ex2_decar_re   )) or
	(esr_do(DO'range)         and (DO'range => ex2_esr_re     )) or
	(mcsr_do(DO'range)        and (DO'range => ex2_mcsr_re    )) or
	(mcsrr0_do(DO'range)      and (DO'range => (ex2_mcsrr0_re or ex2_mcsrr0_re2))) or
	(mcsrr1_do(DO'range)      and (DO'range => ex2_mcsrr1_re  )) or
	(msr_do(DO'range)         and (DO'range => ex2_is_mfmsr   )) or
	(srr0_do(DO'range)        and (DO'range => (ex2_srr0_re or ex2_srr0_re2))) or
	(srr1_do(DO'range)        and (DO'range => ex2_srr1_re    )) or
	(tcr_do(DO'range)         and (DO'range => ex2_tcr_re     )) or
	(tsr_do(DO'range)         and (DO'range => ex2_tsr_re     )) or
	(udec_do(DO'range)        and (DO'range => ex2_udec_re    )) or
	(xucr1_do(DO'range)       and (DO'range => ex2_xucr1_re   ));
end generate;
readmux_11 : if a2mode = 1 and hvmode = 1 generate
ex3_tspr_rt_d <=
	(acop_do(DO'range)        and (DO'range => ex2_acop_re    )) or
	(ccr3_do(DO'range)        and (DO'range => ex2_ccr3_re    )) or
	(csrr0_do(DO'range)       and (DO'range => (ex2_csrr0_re or ex2_csrr0_re2))) or
	(csrr1_do(DO'range)       and (DO'range => ex2_csrr1_re   )) or
	(dbcr0_do(DO'range)       and (DO'range => ex2_dbcr0_re   )) or
	(dbcr1_do(DO'range)       and (DO'range => ex2_dbcr1_re   )) or
	(dbsr_do(DO'range)        and (DO'range => ex2_dbsr_re    )) or
	(dear_do(DO'range)        and (DO'range => ex2_dear_re    )) or
	(dec_do(DO'range)         and (DO'range => ex2_dec_re     )) or
	(decar_do(DO'range)       and (DO'range => ex2_decar_re   )) or
	(epcr_do(DO'range)        and (DO'range => ex2_epcr_re    )) or
	(esr_do(DO'range)         and (DO'range => ex2_esr_re     )) or
	(gdear_do(DO'range)       and (DO'range => ex2_gdear_re   )) or
	(gesr_do(DO'range)        and (DO'range => ex2_gesr_re    )) or
	(gpir_do(DO'range)        and (DO'range => ex2_gpir_re    )) or
	(gsrr0_do(DO'range)       and (DO'range => (ex2_gsrr0_re or ex2_gsrr0_re2))) or
	(gsrr1_do(DO'range)       and (DO'range => ex2_gsrr1_re   )) or
	(hacop_do(DO'range)       and (DO'range => ex2_hacop_re   )) or
	(mcsr_do(DO'range)        and (DO'range => ex2_mcsr_re    )) or
	(mcsrr0_do(DO'range)      and (DO'range => (ex2_mcsrr0_re or ex2_mcsrr0_re2))) or
	(mcsrr1_do(DO'range)      and (DO'range => ex2_mcsrr1_re  )) or
	(msr_do(DO'range)         and (DO'range => ex2_is_mfmsr   )) or
	(msrp_do(DO'range)        and (DO'range => ex2_msrp_re    )) or
	(srr0_do(DO'range)        and (DO'range => (ex2_srr0_re or ex2_srr0_re2))) or
	(srr1_do(DO'range)        and (DO'range => ex2_srr1_re    )) or
	(tcr_do(DO'range)         and (DO'range => ex2_tcr_re     )) or
	(tsr_do(DO'range)         and (DO'range => ex2_tsr_re     )) or
	(udec_do(DO'range)        and (DO'range => ex2_udec_re    )) or
	(xucr1_do(DO'range)       and (DO'range => ex2_xucr1_re   ));
end generate;

tspr_cspr_ex3_tspr_rt   <= ex3_tspr_rt_q and fanout(ex3_tid_rpwr_q,regsize);

ex2_pir_rdec      <= (ex2_instr(11 to 20) = "1111001000");   --  286
ex2_acop_rdec     <= (ex2_instr(11 to 20) = "1111100000");   --   31
ex2_ccr3_rdec     <= (ex2_instr(11 to 20) = "1010111111");   -- 1013
ex2_csrr0_rdec    <= (ex2_instr(11 to 20) = "1101000001");   --   58
ex2_csrr1_rdec    <= (ex2_instr(11 to 20) = "1101100001");   --   59
ex2_ctr_rdec      <= (ex2_instr(11 to 20) = "0100100000");   --    9
ex2_dbcr0_rdec    <= (ex2_instr(11 to 20) = "1010001001");   --  308
ex2_dbcr1_rdec    <= (ex2_instr(11 to 20) = "1010101001");   --  309
ex2_dbcr2_rdec    <= (ex2_instr(11 to 20) = "1011001001");   --  310
ex2_dbcr3_rdec    <= (ex2_instr(11 to 20) = "1000011010");   --  848
ex2_dbsr_rdec     <= (ex2_instr(11 to 20) = "1000001001");   --  304
ex2_dear_rdec     <= (ex2_instr(11 to 20) = "1110100001");   --   61
ex2_dec_rdec      <= (ex2_instr(11 to 20) = "1011000000");   --   22
ex2_decar_rdec    <= (ex2_instr(11 to 20) = "1011000001");   --   54
ex2_epcr_rdec     <= (ex2_instr(11 to 20) = "1001101001");   --  307
ex2_esr_rdec      <= (ex2_instr(11 to 20) = "1111000001");   --   62
ex2_gdear_rdec    <= (ex2_instr(11 to 20) = "1110101011");   --  381
ex2_gesr_rdec     <= (ex2_instr(11 to 20) = "1111101011");   --  383
ex2_gpir_rdec     <= (ex2_instr(11 to 20) = "1111001011");   --  382
ex2_gsrr0_rdec    <= (ex2_instr(11 to 20) = "1101001011");   --  378
ex2_gsrr1_rdec    <= (ex2_instr(11 to 20) = "1101101011");   --  379
ex2_hacop_rdec    <= (ex2_instr(11 to 20) = "1111101010");   --  351
ex2_iar_rdec      <= (ex2_instr(11 to 20) = "1001011011");   --  882
ex2_lr_rdec       <= (ex2_instr(11 to 20) = "0100000000");   --    8
ex2_mcsr_rdec     <= (ex2_instr(11 to 20) = "1110010001");   --  572
ex2_mcsrr0_rdec   <= (ex2_instr(11 to 20) = "1101010001");   --  570
ex2_mcsrr1_rdec   <= (ex2_instr(11 to 20) = "1101110001");   --  571
ex2_msrp_rdec     <= (ex2_instr(11 to 20) = "1011101001");   --  311
ex2_srr0_rdec     <= (ex2_instr(11 to 20) = "1101000000");   --   26
ex2_srr1_rdec     <= (ex2_instr(11 to 20) = "1101100000");   --   27
ex2_tcr_rdec      <= (ex2_instr(11 to 20) = "1010001010");   --  340
ex2_tsr_rdec      <= (ex2_instr(11 to 20) = "1000001010");   --  336
ex2_udec_rdec     <= udec_en and
                     (ex2_instr(11 to 20) = "0011010001");   --  550
ex2_xer_rdec      <= (ex2_instr(11 to 20) = "0000100000");   --    1
ex2_xucr1_rdec    <= (ex2_instr(11 to 20) = "1001111010");   --  851
ex2_acop_re       <=  ex2_acop_rdec;
ex2_ccr3_re       <=  ex2_ccr3_rdec;
ex2_csrr0_re      <=  ex2_csrr0_rdec;
ex2_csrr1_re      <=  ex2_csrr1_rdec;
ex2_ctr_re        <=  ex2_ctr_rdec;
ex2_dbcr0_re      <=  ex2_dbcr0_rdec;
ex2_dbcr1_re      <=  ex2_dbcr1_rdec;
ex2_dbcr2_re      <=  ex2_dbcr2_rdec;
ex2_dbcr3_re      <=  ex2_dbcr3_rdec;
ex2_dbsr_re       <=  ex2_dbsr_rdec;
ex2_dear_re       <=  ex2_dear_rdec      and not mux_msr_gs_q(0);
ex2_dec_re        <=  ex2_dec_rdec;
ex2_decar_re      <=  ex2_decar_rdec;
ex2_epcr_re       <=  ex2_epcr_rdec;
ex2_esr_re        <=  ex2_esr_rdec       and not mux_msr_gs_q(0);
ex2_gdear_re      <= (ex2_gdear_rdec     or (ex2_dear_rdec and mux_msr_gs_q(0)));
ex2_gesr_re       <= (ex2_gesr_rdec      or (ex2_esr_rdec and mux_msr_gs_q(0)));
ex2_gpir_re       <= (ex2_gpir_rdec      or (ex2_pir_rdec and mux_msr_gs_q(0)));
ex2_gsrr0_re      <= (ex2_gsrr0_rdec     or (ex2_srr0_rdec and mux_msr_gs_q(0)));
ex2_gsrr1_re      <= (ex2_gsrr1_rdec     or (ex2_srr1_rdec and mux_msr_gs_q(0)));
ex2_hacop_re      <=  ex2_hacop_rdec;
ex2_iar_re        <=  ex2_iar_rdec;
ex2_lr_re         <=  ex2_lr_rdec;
ex2_mcsr_re       <=  ex2_mcsr_rdec;
ex2_mcsrr0_re     <=  ex2_mcsrr0_rdec;
ex2_mcsrr1_re     <=  ex2_mcsrr1_rdec;
ex2_msrp_re       <=  ex2_msrp_rdec;
ex2_srr0_re       <=  ex2_srr0_rdec      and not mux_msr_gs_q(0);
ex2_srr1_re       <=  ex2_srr1_rdec      and not mux_msr_gs_q(0);
ex2_tcr_re        <=  ex2_tcr_rdec;
ex2_tsr_re        <=  ex2_tsr_rdec;
ex2_udec_re       <=  ex2_udec_rdec;
ex2_xer_re        <=  ex2_xer_rdec;
ex2_xucr1_re      <=  ex2_xucr1_rdec;

ex2_acop_wdec     <= ex2_acop_rdec;
ex2_ccr3_wdec     <= ex2_ccr3_rdec;
ex2_csrr0_wdec    <= ex2_csrr0_rdec;
ex2_csrr1_wdec    <= ex2_csrr1_rdec;
ex2_ctr_wdec      <= ex2_ctr_rdec;
ex2_dbcr0_wdec    <= ex2_dbcr0_rdec;
ex2_dbcr1_wdec    <= ex2_dbcr1_rdec;
ex2_dbcr2_wdec    <= ex2_dbcr2_rdec;
ex2_dbcr3_wdec    <= ex2_dbcr3_rdec;
ex2_dbsr_wdec     <= ex2_dbsr_rdec;
ex2_dbsrwr_wdec   <= (ex2_instr(11 to 20) = "1001001001");   --  306
ex2_dear_wdec     <= ex2_dear_rdec;
ex2_dec_wdec      <= ex2_dec_rdec;
ex2_decar_wdec    <= ex2_decar_rdec;
ex2_epcr_wdec     <= ex2_epcr_rdec;
ex2_esr_wdec      <= ex2_esr_rdec;
ex2_gdear_wdec    <= ex2_gdear_rdec;
ex2_gesr_wdec     <= ex2_gesr_rdec;
ex2_gpir_wdec     <= (ex2_instr(11 to 20) = "1111001011");   --  382
ex2_gsrr0_wdec    <= ex2_gsrr0_rdec;
ex2_gsrr1_wdec    <= ex2_gsrr1_rdec;
ex2_hacop_wdec    <= (ex2_instr(11 to 20) = "1111101010");   --  351
ex2_iar_wdec      <= ex2_iar_rdec;
ex2_lr_wdec       <= ex2_lr_rdec;
ex2_mcsr_wdec     <= ex2_mcsr_rdec;
ex2_mcsrr0_wdec   <= ex2_mcsrr0_rdec;
ex2_mcsrr1_wdec   <= ex2_mcsrr1_rdec;
ex2_msrp_wdec     <= ex2_msrp_rdec;
ex2_srr0_wdec     <= ex2_srr0_rdec;
ex2_srr1_wdec     <= ex2_srr1_rdec;
ex2_tcr_wdec      <= ex2_tcr_rdec;
ex2_tsr_wdec      <= ex2_tsr_rdec;
ex2_udec_wdec     <= udec_en and
                     ex2_udec_rdec;
ex2_xer_wdec      <= ex2_xer_rdec;
ex2_xucr1_wdec    <= ex2_xucr1_rdec;
ex2_acop_we       <=  ex2_acop_wdec;
ex2_ccr3_we       <=  ex2_ccr3_wdec;
ex2_csrr0_we      <=  ex2_csrr0_wdec;
ex2_csrr1_we      <=  ex2_csrr1_wdec;
ex2_ctr_we        <=  ex2_ctr_wdec;
ex2_dbcr0_we      <=  ex2_dbcr0_wdec;
ex2_dbcr1_we      <=  ex2_dbcr1_wdec;
ex2_dbcr2_we      <=  ex2_dbcr2_wdec;
ex2_dbcr3_we      <=  ex2_dbcr3_wdec;
ex2_dbsr_we       <=  ex2_dbsr_wdec;
ex2_dbsrwr_we     <=  ex2_dbsrwr_wdec;
ex2_dear_we       <=  ex2_dear_wdec      and not mux_msr_gs_q(1);
ex2_dec_we        <=  ex2_dec_wdec;
ex2_decar_we      <=  ex2_decar_wdec;
ex2_epcr_we       <=  ex2_epcr_wdec;
ex2_esr_we        <=  ex2_esr_wdec       and not mux_msr_gs_q(1);
ex2_gdear_we      <= (ex2_gdear_wdec     or (ex2_dear_wdec and mux_msr_gs_q(1)));
ex2_gesr_we       <= (ex2_gesr_wdec      or (ex2_esr_wdec and mux_msr_gs_q(1)));
ex2_gpir_we       <=  ex2_gpir_wdec;
ex2_gsrr0_we      <= (ex2_gsrr0_wdec     or (ex2_srr0_wdec and mux_msr_gs_q(1)));
ex2_gsrr1_we      <= (ex2_gsrr1_wdec     or (ex2_srr1_wdec and mux_msr_gs_q(1)));
ex2_hacop_we      <=  ex2_hacop_wdec;
ex2_iar_we        <=  ex2_iar_wdec;
ex2_lr_we         <=  ex2_lr_wdec;
ex2_mcsr_we       <=  ex2_mcsr_wdec;
ex2_mcsrr0_we     <=  ex2_mcsrr0_wdec;
ex2_mcsrr1_we     <=  ex2_mcsrr1_wdec;
ex2_msrp_we       <=  ex2_msrp_wdec;
ex2_srr0_we       <=  ex2_srr0_wdec      and not mux_msr_gs_q(1);
ex2_srr1_we       <=  ex2_srr1_wdec      and not mux_msr_gs_q(1);
ex2_tcr_we        <=  ex2_tcr_wdec;
ex2_tsr_we        <=  ex2_tsr_wdec;
ex2_udec_we       <=  ex2_udec_wdec;
ex2_xer_we        <=  ex2_xer_wdec;
ex2_xucr1_we      <=  ex2_xucr1_wdec;

ex6_acop_wdec     <= (ex6_instr(11 to 20) = "1111100000");   --   31
ex6_ccr3_wdec     <= (ex6_instr(11 to 20) = "1010111111");   -- 1013
ex6_csrr0_wdec    <= (ex6_instr(11 to 20) = "1101000001");   --   58
ex6_csrr1_wdec    <= (ex6_instr(11 to 20) = "1101100001");   --   59
ex6_dbcr0_wdec    <= (ex6_instr(11 to 20) = "1010001001");   --  308
ex6_dbcr1_wdec    <= (ex6_instr(11 to 20) = "1010101001");   --  309
ex6_dbsr_wdec     <= (ex6_instr(11 to 20) = "1000001001");   --  304
ex6_dbsrwr_wdec   <= (ex6_instr(11 to 20) = "1001001001");   --  306
ex6_dear_wdec     <= (ex6_instr(11 to 20) = "1110100001");   --   61
ex6_dec_wdec      <= (ex6_instr(11 to 20) = "1011000000");   --   22
ex6_decar_wdec    <= (ex6_instr(11 to 20) = "1011000001");   --   54
ex6_epcr_wdec     <= (ex6_instr(11 to 20) = "1001101001");   --  307
ex6_esr_wdec      <= (ex6_instr(11 to 20) = "1111000001");   --   62
ex6_gdear_wdec    <= (ex6_instr(11 to 20) = "1110101011");   --  381
ex6_gesr_wdec     <= (ex6_instr(11 to 20) = "1111101011");   --  383
ex6_gpir_wdec     <= (ex6_instr(11 to 20) = "1111001011");   --  382
ex6_gsrr0_wdec    <= (ex6_instr(11 to 20) = "1101001011");   --  378
ex6_gsrr1_wdec    <= (ex6_instr(11 to 20) = "1101101011");   --  379
ex6_hacop_wdec    <= (ex6_instr(11 to 20) = "1111101010");   --  351
ex6_mcsr_wdec     <= (ex6_instr(11 to 20) = "1110010001");   --  572
ex6_mcsrr0_wdec   <= (ex6_instr(11 to 20) = "1101010001");   --  570
ex6_mcsrr1_wdec   <= (ex6_instr(11 to 20) = "1101110001");   --  571
ex6_msr_wdec      <=  ex6_is_mtmsr;
ex6_msrp_wdec     <= (ex6_instr(11 to 20) = "1011101001");   --  311
ex6_srr0_wdec     <= (ex6_instr(11 to 20) = "1101000000");   --   26
ex6_srr1_wdec     <= (ex6_instr(11 to 20) = "1101100000");   --   27
ex6_tcr_wdec      <= (ex6_instr(11 to 20) = "1010001010");   --  340
ex6_tsr_wdec      <= (ex6_instr(11 to 20) = "1000001010");   --  336
ex6_udec_wdec     <= udec_en and
                     (ex6_instr(11 to 20) = "0011010001");   --  550
ex6_xucr1_wdec    <= (ex6_instr(11 to 20) = "1001111010");   --  851
ex6_acop_we       <= ex6_val and ex6_is_mtspr and  ex6_acop_wdec;
ex6_ccr3_we       <= ex6_val and ex6_is_mtspr and  ex6_ccr3_wdec;
ex6_csrr0_we      <= ex6_val and ex6_is_mtspr and  ex6_csrr0_wdec;
ex6_csrr1_we      <= ex6_val and ex6_is_mtspr and  ex6_csrr1_wdec;
ex6_dbcr0_we      <= ex6_val and ex6_is_mtspr and  ex6_dbcr0_wdec;
ex6_dbcr1_we      <= ex6_val and ex6_is_mtspr and  ex6_dbcr1_wdec;
ex6_dbsr_we       <= ex6_val and ex6_is_mtspr and  ex6_dbsr_wdec;
ex6_dbsrwr_we     <= ex6_val and ex6_is_mtspr and  ex6_dbsrwr_wdec;
ex6_dear_we       <= ex6_val and ex6_is_mtspr and  ex6_dear_wdec      and not mux_msr_gs_q(2);
ex6_dec_we        <= ex6_val and ex6_is_mtspr and  ex6_dec_wdec;
ex6_decar_we      <= ex6_val and ex6_is_mtspr and  ex6_decar_wdec;
ex6_epcr_we       <= ex6_val and ex6_is_mtspr and  ex6_epcr_wdec;
ex6_esr_we        <= ex6_val and ex6_is_mtspr and  ex6_esr_wdec       and not mux_msr_gs_q(2);
ex6_gdear_we      <= ex6_val and ex6_is_mtspr and (ex6_gdear_wdec     or (ex6_dear_wdec and mux_msr_gs_q(2)));
ex6_gesr_we       <= ex6_val and ex6_is_mtspr and (ex6_gesr_wdec      or (ex6_esr_wdec and mux_msr_gs_q(2)));
ex6_gpir_we       <= ex6_val and ex6_is_mtspr and  ex6_gpir_wdec;
ex6_gsrr0_we      <= ex6_val and ex6_is_mtspr and (ex6_gsrr0_wdec     or (ex6_srr0_wdec and mux_msr_gs_q(2)));
ex6_gsrr1_we      <= ex6_val and ex6_is_mtspr and (ex6_gsrr1_wdec     or (ex6_srr1_wdec and mux_msr_gs_q(2)));
ex6_hacop_we      <= ex6_val and ex6_is_mtspr and  ex6_hacop_wdec;
ex6_mcsr_we       <= ex6_val and ex6_is_mtspr and  ex6_mcsr_wdec;
ex6_mcsrr0_we     <= ex6_val and ex6_is_mtspr and  ex6_mcsrr0_wdec;
ex6_mcsrr1_we     <= ex6_val and ex6_is_mtspr and  ex6_mcsrr1_wdec;
ex6_msr_we        <= ex6_val and                   ex6_msr_wdec;
ex6_msrp_we       <= ex6_val and ex6_is_mtspr and  ex6_msrp_wdec;
ex6_srr0_we       <= ex6_val and ex6_is_mtspr and  ex6_srr0_wdec      and not mux_msr_gs_q(2);
ex6_srr1_we       <= ex6_val and ex6_is_mtspr and  ex6_srr1_wdec      and not mux_msr_gs_q(2);
ex6_tcr_we        <= ex6_val and ex6_is_mtspr and  ex6_tcr_wdec;
ex6_tsr_we        <= ex6_val and ex6_is_mtspr and  ex6_tsr_wdec;
ex6_udec_we       <= ex6_val and ex6_is_mtspr and  ex6_udec_wdec;
ex6_xucr1_we      <= ex6_val and ex6_is_mtspr and  ex6_xucr1_wdec;

-- Illegal SPR checks
ill_spr_00 : if a2mode = 0 and hvmode = 0 generate
tspr_cspr_illeg_mtspr_b <= 
                              ex2_ccr3_wdec        or ex2_ctr_wdec         or ex2_dbcr0_wdec       
                           or ex2_dbcr1_wdec       or ex2_dbcr3_wdec       or ex2_dbsr_wdec        
                           or ex2_dear_wdec        or ex2_dec_wdec         or ex2_esr_wdec         
                           or ex2_iar_wdec         or ex2_lr_wdec          or ex2_srr0_wdec        
                           or ex2_srr1_wdec        or ex2_xer_wdec         or ex2_xucr1_wdec       ;

tspr_cspr_illeg_mfspr_b <= 
                              ex2_ccr3_rdec        or ex2_ctr_rdec         or ex2_dbcr0_rdec       
                           or ex2_dbcr1_rdec       or ex2_dbcr3_rdec       or ex2_dbsr_rdec        
                           or ex2_dear_rdec        or ex2_dec_rdec         or ex2_esr_rdec         
                           or ex2_iar_rdec         or ex2_lr_rdec          or ex2_srr0_rdec        
                           or ex2_srr1_rdec        or ex2_xer_rdec         or ex2_xucr1_rdec       ;

tspr_cspr_hypv_mtspr <= 
                              ex2_ccr3_we          or ex2_dbcr0_we         or ex2_dbcr1_we         
                           or ex2_dbcr3_we         or ex2_dbsr_we          or ex2_dec_we           
                           or ex2_iar_we           or ex2_xucr1_we         ;

tspr_cspr_hypv_mfspr <= 
                              ex2_ccr3_re          or ex2_dbcr0_re         or ex2_dbcr1_re         
                           or ex2_dbcr3_re         or ex2_dbsr_re          or ex2_dec_re           
                           or ex2_iar_re           or ex2_xucr1_re         ;

end generate;
ill_spr_01 : if a2mode = 0 and hvmode = 1 generate
tspr_cspr_illeg_mtspr_b <= 
                              ex2_ccr3_wdec        or ex2_ctr_wdec         or ex2_dbcr0_wdec       
                           or ex2_dbcr1_wdec       or ex2_dbcr3_wdec       or ex2_dbsr_wdec        
                           or ex2_dbsrwr_wdec      or ex2_dear_wdec        or ex2_dec_wdec         
                           or ex2_epcr_wdec        or ex2_esr_wdec         or ex2_gdear_wdec       
                           or ex2_gesr_wdec        or ex2_gpir_wdec        or ex2_gsrr0_wdec       
                           or ex2_gsrr1_wdec       or ex2_hacop_wdec       or ex2_iar_wdec         
                           or ex2_lr_wdec          or ex2_msrp_wdec        or ex2_srr0_wdec        
                           or ex2_srr1_wdec        or ex2_xer_wdec         or ex2_xucr1_wdec       ;

tspr_cspr_illeg_mfspr_b <= 
                              ex2_ccr3_rdec        or ex2_ctr_rdec         or ex2_dbcr0_rdec       
                           or ex2_dbcr1_rdec       or ex2_dbcr3_rdec       or ex2_dbsr_rdec        
                           or ex2_dear_rdec        or ex2_dec_rdec         or ex2_epcr_rdec        
                           or ex2_esr_rdec         or ex2_gdear_rdec       or ex2_gesr_rdec        
                           or ex2_gpir_rdec        or ex2_gsrr0_rdec       or ex2_gsrr1_rdec       
                           or ex2_hacop_rdec       or ex2_iar_rdec         or ex2_lr_rdec          
                           or ex2_msrp_rdec        or ex2_srr0_rdec        or ex2_srr1_rdec        
                           or ex2_xer_rdec         or ex2_xucr1_rdec       ;

tspr_cspr_hypv_mtspr <= 
                              ex2_ccr3_we          or ex2_dbcr0_we         or ex2_dbcr1_we         
                           or ex2_dbcr3_we         or ex2_dbsr_we          or ex2_dbsrwr_we        
                           or ex2_dec_we           or ex2_epcr_we          or ex2_gpir_we          
                           or ex2_hacop_we         or ex2_iar_we           or ex2_msrp_we          
                           or ex2_xucr1_we         ;

tspr_cspr_hypv_mfspr <= 
                              ex2_ccr3_re          or ex2_dbcr0_re         or ex2_dbcr1_re         
                           or ex2_dbcr3_re         or ex2_dbsr_re          or ex2_dec_re           
                           or ex2_epcr_re          or ex2_iar_re           or ex2_msrp_re          
                           or ex2_xucr1_re         ;

end generate;
ill_spr_10 : if a2mode = 1 and hvmode = 0 generate
tspr_cspr_illeg_mtspr_b <=
                              ex2_acop_wdec        or ex2_ccr3_wdec        or ex2_csrr0_wdec       
                           or ex2_csrr1_wdec       or ex2_ctr_wdec         or ex2_dbcr0_wdec       
                           or ex2_dbcr1_wdec       or ex2_dbcr2_wdec       or ex2_dbcr3_wdec       
                           or ex2_dbsr_wdec        or ex2_dear_wdec        or ex2_dec_wdec         
                           or ex2_decar_wdec       or ex2_esr_wdec         or ex2_iar_wdec         
                           or ex2_lr_wdec          or ex2_mcsr_wdec        or ex2_mcsrr0_wdec      
                           or ex2_mcsrr1_wdec      or ex2_srr0_wdec        or ex2_srr1_wdec        
                           or ex2_tcr_wdec         or ex2_tsr_wdec         or ex2_udec_wdec        
                           or ex2_xer_wdec         or ex2_xucr1_wdec       ;

tspr_cspr_illeg_mfspr_b <=
                              ex2_acop_rdec        or ex2_ccr3_rdec        or ex2_csrr0_rdec       
                           or ex2_csrr1_rdec       or ex2_ctr_rdec         or ex2_dbcr0_rdec       
                           or ex2_dbcr1_rdec       or ex2_dbcr2_rdec       or ex2_dbcr3_rdec       
                           or ex2_dbsr_rdec        or ex2_dear_rdec        or ex2_dec_rdec         
                           or ex2_decar_rdec       or ex2_esr_rdec         or ex2_iar_rdec         
                           or ex2_lr_rdec          or ex2_mcsr_rdec        or ex2_mcsrr0_rdec      
                           or ex2_mcsrr1_rdec      or ex2_srr0_rdec        or ex2_srr1_rdec        
                           or ex2_tcr_rdec         or ex2_tsr_rdec         or ex2_udec_rdec        
                           or ex2_xer_rdec         or ex2_xucr1_rdec       ;

tspr_cspr_hypv_mtspr <= 
                              ex2_ccr3_we          or ex2_csrr0_we         or ex2_csrr1_we         
                           or ex2_dbcr0_we         or ex2_dbcr1_we         or ex2_dbcr2_we         
                           or ex2_dbcr3_we         or ex2_dbsr_we          or ex2_dec_we           
                           or ex2_decar_we         or ex2_iar_we           or ex2_mcsr_we          
                           or ex2_mcsrr0_we        or ex2_mcsrr1_we        or ex2_tcr_we           
                           or ex2_tsr_we           or ex2_xucr1_we         ;
                                                                                                             
tspr_cspr_hypv_mfspr <=                                                                              
                              ex2_ccr3_re          or ex2_csrr0_re         or ex2_csrr1_re         
                           or ex2_dbcr0_re         or ex2_dbcr1_re         or ex2_dbcr2_re         
                           or ex2_dbcr3_re         or ex2_dbsr_re          or ex2_dec_re           
                           or ex2_decar_re         or ex2_iar_re           or ex2_mcsr_re          
                           or ex2_mcsrr0_re        or ex2_mcsrr1_re        or ex2_tcr_re           
                           or ex2_tsr_re           or ex2_xucr1_re         ;

end generate;
ill_spr_11 : if a2mode = 1 and hvmode = 1 generate
tspr_cspr_illeg_mtspr_b <=
                              ex2_acop_wdec        or ex2_ccr3_wdec        or ex2_csrr0_wdec       
                           or ex2_csrr1_wdec       or ex2_ctr_wdec         or ex2_dbcr0_wdec       
                           or ex2_dbcr1_wdec       or ex2_dbcr2_wdec       or ex2_dbcr3_wdec       
                           or ex2_dbsr_wdec        or ex2_dbsrwr_wdec      or ex2_dear_wdec        
                           or ex2_dec_wdec         or ex2_decar_wdec       or ex2_epcr_wdec        
                           or ex2_esr_wdec         or ex2_gdear_wdec       or ex2_gesr_wdec        
                           or ex2_gpir_wdec        or ex2_gsrr0_wdec       or ex2_gsrr1_wdec       
                           or ex2_hacop_wdec       or ex2_iar_wdec         or ex2_lr_wdec          
                           or ex2_mcsr_wdec        or ex2_mcsrr0_wdec      or ex2_mcsrr1_wdec      
                           or ex2_msrp_wdec        or ex2_srr0_wdec        or ex2_srr1_wdec        
                           or ex2_tcr_wdec         or ex2_tsr_wdec         or ex2_udec_wdec        
                           or ex2_xer_wdec         or ex2_xucr1_wdec       ;

tspr_cspr_illeg_mfspr_b <=
                              ex2_acop_rdec        or ex2_ccr3_rdec        or ex2_csrr0_rdec       
                           or ex2_csrr1_rdec       or ex2_ctr_rdec         or ex2_dbcr0_rdec       
                           or ex2_dbcr1_rdec       or ex2_dbcr2_rdec       or ex2_dbcr3_rdec       
                           or ex2_dbsr_rdec        or ex2_dear_rdec        or ex2_dec_rdec         
                           or ex2_decar_rdec       or ex2_epcr_rdec        or ex2_esr_rdec         
                           or ex2_gdear_rdec       or ex2_gesr_rdec        or ex2_gpir_rdec        
                           or ex2_gsrr0_rdec       or ex2_gsrr1_rdec       or ex2_hacop_rdec       
                           or ex2_iar_rdec         or ex2_lr_rdec          or ex2_mcsr_rdec        
                           or ex2_mcsrr0_rdec      or ex2_mcsrr1_rdec      or ex2_msrp_rdec        
                           or ex2_srr0_rdec        or ex2_srr1_rdec        or ex2_tcr_rdec         
                           or ex2_tsr_rdec         or ex2_udec_rdec        or ex2_xer_rdec         
                           or ex2_xucr1_rdec       ;

tspr_cspr_hypv_mtspr <= 
                              ex2_ccr3_we          or ex2_csrr0_we         or ex2_csrr1_we         
                           or ex2_dbcr0_we         or ex2_dbcr1_we         or ex2_dbcr2_we         
                           or ex2_dbcr3_we         or ex2_dbsr_we          or ex2_dbsrwr_we        
                           or ex2_dec_we           or ex2_decar_we         or ex2_epcr_we          
                           or ex2_gpir_we          or ex2_hacop_we         or ex2_iar_we           
                           or ex2_mcsr_we          or ex2_mcsrr0_we        or ex2_mcsrr1_we        
                           or ex2_msrp_we          or ex2_tcr_we           or ex2_tsr_we           
                           or ex2_xucr1_we         ;

tspr_cspr_hypv_mfspr <= 
                              ex2_ccr3_re          or ex2_csrr0_re         or ex2_csrr1_re         
                           or ex2_dbcr0_re         or ex2_dbcr1_re         or ex2_dbcr2_re         
                           or ex2_dbcr3_re         or ex2_dbsr_re          or ex2_dec_re           
                           or ex2_decar_re         or ex2_epcr_re          or ex2_iar_re           
                           or ex2_mcsr_re          or ex2_mcsrr0_re        or ex2_mcsrr1_re        
                           or ex2_msrp_re          or ex2_tcr_re           or ex2_tsr_re           
                           or ex2_xucr1_re         ;

end generate;

spr_acop_ct                <= acop_q(32 to 63);
spr_ccr3_en_eepri          <= ccr3_q(62);
spr_ccr3_si                <= ccr3_q(63);
spr_dbcr0_idm              <= dbcr0_q(43);
spr_dbcr0_rst              <= dbcr0_q(44 to 45);
spr_dbcr0_icmp             <= dbcr0_q(46);
spr_dbcr0_brt              <= dbcr0_q(47);
spr_dbcr0_irpt             <= dbcr0_q(48);
spr_dbcr0_trap             <= dbcr0_q(49);
spr_dbcr0_iac1             <= dbcr0_q(50);
spr_dbcr0_iac2             <= dbcr0_q(51);
spr_dbcr0_iac3             <= dbcr0_q(52);
spr_dbcr0_iac4             <= dbcr0_q(53);
spr_dbcr0_dac1             <= dbcr0_q(54 to 55);
spr_dbcr0_dac2             <= dbcr0_q(56 to 57);
spr_dbcr0_ret              <= dbcr0_q(58);
spr_dbcr0_dac3             <= dbcr0_q(59 to 60);
spr_dbcr0_dac4             <= dbcr0_q(61 to 62);
spr_dbcr0_ft               <= dbcr0_q(63);
spr_dbcr1_iac1us           <= dbcr1_q(46 to 47);
spr_dbcr1_iac1er           <= dbcr1_q(48 to 49);
spr_dbcr1_iac2us           <= dbcr1_q(50 to 51);
spr_dbcr1_iac2er           <= dbcr1_q(52 to 53);
spr_dbcr1_iac12m           <= dbcr1_q(54);
spr_dbcr1_iac3us           <= dbcr1_q(55 to 56);
spr_dbcr1_iac3er           <= dbcr1_q(57 to 58);
spr_dbcr1_iac4us           <= dbcr1_q(59 to 60);
spr_dbcr1_iac4er           <= dbcr1_q(61 to 62);
spr_dbcr1_iac34m           <= dbcr1_q(63);
spr_dbsr_ide               <= dbsr_q(44);
spr_epcr_extgs             <= epcr_q(54);
spr_epcr_dtlbgs            <= epcr_q(55);
spr_epcr_itlbgs            <= epcr_q(56);
spr_epcr_dsigs             <= epcr_q(57);
spr_epcr_isigs             <= epcr_q(58);
spr_epcr_duvd              <= epcr_q(59);
spr_epcr_icm               <= epcr_q(60);
spr_epcr_gicm              <= epcr_q(61);
spr_epcr_dgtmi             <= epcr_q(62);
xu_mm_spr_epcr_dmiuh       <= epcr_q(63);
spr_hacop_ct               <= hacop_q(32 to 63);
spr_msr_cm                 <= msr_q(50);
spr_msr_gs                 <= msr_q(51);
spr_msr_ucle               <= msr_q(52);
spr_msr_spv                <= msr_q(53);
spr_msr_ce                 <= msr_q(54);
spr_msr_ee                 <= msr_q(55);
spr_msr_pr                 <= msr_q(56);
spr_msr_fp                 <= msr_q(57);
spr_msr_me                 <= msr_q(58);
spr_msr_fe0                <= msr_q(59);
spr_msr_de                 <= msr_q(60);
spr_msr_fe1                <= msr_q(61);
spr_msr_is                 <= msr_q(62);
spr_msr_ds                 <= msr_q(63);
spr_msrp_uclep             <= msrp_q(62);
spr_tcr_wp                 <= tcr_q(52 to 53);
spr_tcr_wrc                <= tcr_q(54 to 55);
spr_tcr_wie                <= tcr_q(56);
spr_tcr_die                <= tcr_q(57);
spr_tcr_fp                 <= tcr_q(58 to 59);
spr_tcr_fie                <= tcr_q(60);
spr_tcr_are                <= tcr_q(61);
spr_tcr_udie               <= tcr_q(62);
spr_tcr_ud                 <= tcr_q(63);
spr_tsr_enw                <= tsr_q(59);
spr_tsr_wis                <= tsr_q(60);
spr_tsr_dis                <= tsr_q(61);
spr_tsr_fis                <= tsr_q(62);
spr_tsr_udis               <= tsr_q(63);
spr_xucr1_ll_tb_sel        <= xucr1_q(59 to 61);
spr_xucr1_ll_sel           <= xucr1_q(62);
spr_xucr1_ll_en            <= xucr1_q(63);

-- ACOP
ex6_acop_di    <= ex6_spr_wd(32 to 63)             ; --CT
acop_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						acop_q(32 to 63)                 ; --CT
-- CCR3
ex6_ccr3_di    <= ex6_spr_wd(62 to 62)             & --EN_EEPRI
						ex6_spr_wd(63 to 63)             ; --SI
ccr3_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 61)                   & --///
						ccr3_q(62 to 62)                 & --EN_EEPRI
						ccr3_q(63 to 63)                 ; --SI
-- CSRR0
ex6_csrr0_di   <= ex6_spr_wd(62-(eff_ifar) to 61)  ; --SRR0
csrr0_do       <= tidn(0 to 62-(eff_ifar))         &
						csrr0_q(64-(eff_ifar) to 63)     & --SRR0
						tidn(62 to 63)                   ; --///
-- CSRR1
ex6_csrr1_di   <= ex6_spr_wd(32 to 32)             & --CM
						ex6_spr_wd(35 to 35)             & --GS
						ex6_spr_wd(37 to 37)             & --UCLE
						ex6_spr_wd(38 to 38)             & --SPV
						ex6_spr_wd(46 to 46)             & --CE
						ex6_spr_wd(48 to 48)             & --EE
						ex6_spr_wd(49 to 49)             & --PR
						ex6_spr_wd(50 to 50)             & --FP
						ex6_spr_wd(51 to 51)             & --ME
						ex6_spr_wd(52 to 52)             & --FE0
						ex6_spr_wd(54 to 54)             & --DE
						ex6_spr_wd(55 to 55)             & --FE1
						ex6_spr_wd(58 to 58)             & --IS
						ex6_spr_wd(59 to 59)             ; --DS
csrr1_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						csrr1_q(50 to 50)                & --CM
						tidn(33 to 34)                   & --///
						csrr1_q(51 to 51)                & --GS
						tidn(36 to 36)                   & --///
						csrr1_q(52 to 52)                & --UCLE
						csrr1_q(53 to 53)                & --SPV
						tidn(39 to 45)                   & --///
						csrr1_q(54 to 54)                & --CE
						tidn(47 to 47)                   & --///
						csrr1_q(55 to 55)                & --EE
						csrr1_q(56 to 56)                & --PR
						csrr1_q(57 to 57)                & --FP
						csrr1_q(58 to 58)                & --ME
						csrr1_q(59 to 59)                & --FE0
						tidn(53 to 53)                   & --///
						csrr1_q(60 to 60)                & --DE
						csrr1_q(61 to 61)                & --FE1
						tidn(56 to 57)                   & --///
						csrr1_q(62 to 62)                & --IS
						csrr1_q(63 to 63)                & --DS
						tidn(60 to 63)                   ; --///
-- DBCR0
ex6_dbcr0_di   <= ex6_spr_wd(33 to 33)             & --IDM
						ex6_spr_wd(34 to 35)             & --RST
						ex6_spr_wd(36 to 36)             & --ICMP
						ex6_spr_wd(37 to 37)             & --BRT
						ex6_spr_wd(38 to 38)             & --IRPT
						ex6_spr_wd(39 to 39)             & --TRAP
						ex6_spr_wd(40 to 40)             & --IAC1
						ex6_spr_wd(41 to 41)             & --IAC2
						ex6_spr_wd(42 to 42)             & --IAC3
						ex6_spr_wd(43 to 43)             & --IAC4
						ex6_spr_wd(44 to 45)             & --DAC1
						ex6_spr_wd(46 to 47)             & --DAC2
						ex6_spr_wd(48 to 48)             & --RET
						ex6_spr_wd(59 to 60)             & --DAC3
						ex6_spr_wd(61 to 62)             & --DAC4
						ex6_spr_wd(63 to 63)             ; --FT
dbcr0_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						cpl_spr_dbcr0_edm                & --EDM
						dbcr0_q(43 to 43)                & --IDM
						dbcr0_q(44 to 45)                & --RST
						dbcr0_q(46 to 46)                & --ICMP
						dbcr0_q(47 to 47)                & --BRT
						dbcr0_q(48 to 48)                & --IRPT
						dbcr0_q(49 to 49)                & --TRAP
						dbcr0_q(50 to 50)                & --IAC1
						dbcr0_q(51 to 51)                & --IAC2
						dbcr0_q(52 to 52)                & --IAC3
						dbcr0_q(53 to 53)                & --IAC4
						dbcr0_q(54 to 55)                & --DAC1
						dbcr0_q(56 to 57)                & --DAC2
						dbcr0_q(58 to 58)                & --RET
						tidn(49 to 58)                   & --///
						dbcr0_q(59 to 60)                & --DAC3
						dbcr0_q(61 to 62)                & --DAC4
						dbcr0_q(63 to 63)                ; --FT
-- DBCR1
ex6_dbcr1_di   <= ex6_spr_wd(32 to 33)             & --IAC1US
						ex6_spr_wd(34 to 35)             & --IAC1ER
						ex6_spr_wd(36 to 37)             & --IAC2US
						ex6_spr_wd(38 to 39)             & --IAC2ER
						ex6_spr_wd(41 to 41)             & --IAC12M
						ex6_spr_wd(48 to 49)             & --IAC3US
						ex6_spr_wd(50 to 51)             & --IAC3ER
						ex6_spr_wd(52 to 53)             & --IAC4US
						ex6_spr_wd(54 to 55)             & --IAC4ER
						ex6_spr_wd(57 to 57)             ; --IAC34M
dbcr1_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						dbcr1_q(46 to 47)                & --IAC1US
						dbcr1_q(48 to 49)                & --IAC1ER
						dbcr1_q(50 to 51)                & --IAC2US
						dbcr1_q(52 to 53)                & --IAC2ER
						tidn(40 to 40)                   & --///
						dbcr1_q(54 to 54)                & --IAC12M
						tidn(42 to 47)                   & --///
						dbcr1_q(55 to 56)                & --IAC3US
						dbcr1_q(57 to 58)                & --IAC3ER
						dbcr1_q(59 to 60)                & --IAC4US
						dbcr1_q(61 to 62)                & --IAC4ER
						tidn(56 to 56)                   & --///
						dbcr1_q(63 to 63)                & --IAC34M
						tidn(58 to 63)                   ; --///
-- DBSR
ex6_dbsr_di    <= ex6_spr_wd(32 to 32)             & --IDE
						ex6_spr_wd(33 to 33)             & --UDE
						ex6_spr_wd(36 to 36)             & --ICMP
						ex6_spr_wd(37 to 37)             & --BRT
						ex6_spr_wd(38 to 38)             & --IRPT
						ex6_spr_wd(39 to 39)             & --TRAP
						ex6_spr_wd(40 to 40)             & --IAC1
						ex6_spr_wd(41 to 41)             & --IAC2
						ex6_spr_wd(42 to 42)             & --IAC3
						ex6_spr_wd(43 to 43)             & --IAC4
						ex6_spr_wd(44 to 44)             & --DAC1R
						ex6_spr_wd(45 to 45)             & --DAC1W
						ex6_spr_wd(46 to 46)             & --DAC2R
						ex6_spr_wd(47 to 47)             & --DAC2W
						ex6_spr_wd(48 to 48)             & --RET
						ex6_spr_wd(59 to 59)             & --DAC3R
						ex6_spr_wd(60 to 60)             & --DAC3W
						ex6_spr_wd(61 to 61)             & --DAC4R
						ex6_spr_wd(62 to 62)             & --DAC4W
						ex6_spr_wd(63 to 63)             ; --IVC
dbsr_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						dbsr_q(44 to 44)                 & --IDE
						dbsr_q(45 to 45)                 & --UDE
						dbsr_mrr_q(0 to 1)               & --MRR
						dbsr_q(46 to 46)                 & --ICMP
						dbsr_q(47 to 47)                 & --BRT
						dbsr_q(48 to 48)                 & --IRPT
						dbsr_q(49 to 49)                 & --TRAP
						dbsr_q(50 to 50)                 & --IAC1
						dbsr_q(51 to 51)                 & --IAC2
						dbsr_q(52 to 52)                 & --IAC3
						dbsr_q(53 to 53)                 & --IAC4
						dbsr_q(54 to 54)                 & --DAC1R
						dbsr_q(55 to 55)                 & --DAC1W
						dbsr_q(56 to 56)                 & --DAC2R
						dbsr_q(57 to 57)                 & --DAC2W
						dbsr_q(58 to 58)                 & --RET
						tidn(49 to 58)                   & --///
						dbsr_q(59 to 59)                 & --DAC3R
						dbsr_q(60 to 60)                 & --DAC3W
						dbsr_q(61 to 61)                 & --DAC4R
						dbsr_q(62 to 62)                 & --DAC4W
						dbsr_q(63 to 63)                 ; --IVC
-- DEAR
ex6_dear_di    <= ex6_spr_wd(64-(regsize) to 63)   ; --DEAR
dear_do        <= tidn(0 to 64-(regsize))          &
						dear_q(64-(regsize) to 63)       ; --DEAR
-- DEC
ex6_dec_di     <= ex6_spr_wd(32 to 63)             ; --DEC
dec_do         <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						dec_q(32 to 63)                  ; --DEC
-- DECAR
ex6_decar_di   <= ex6_spr_wd(32 to 63)             ; --DECAR
decar_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						decar_q(32 to 63)                ; --DECAR
-- EPCR
ex6_epcr_di    <= ex6_spr_wd(32 to 32)             & --EXTGS
						ex6_spr_wd(33 to 33)             & --DTLBGS
						ex6_spr_wd(34 to 34)             & --ITLBGS
						ex6_spr_wd(35 to 35)             & --DSIGS
						ex6_spr_wd(36 to 36)             & --ISIGS
						ex6_spr_wd(37 to 37)             & --DUVD
						ex6_spr_wd(38 to 38)             & --ICM
						ex6_spr_wd(39 to 39)             & --GICM
						ex6_spr_wd(40 to 40)             & --DGTMI
						ex6_spr_wd(41 to 41)             ; --DMIUH
epcr_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						epcr_q(54 to 54)                 & --EXTGS
						epcr_q(55 to 55)                 & --DTLBGS
						epcr_q(56 to 56)                 & --ITLBGS
						epcr_q(57 to 57)                 & --DSIGS
						epcr_q(58 to 58)                 & --ISIGS
						epcr_q(59 to 59)                 & --DUVD
						epcr_q(60 to 60)                 & --ICM
						epcr_q(61 to 61)                 & --GICM
						epcr_q(62 to 62)                 & --DGTMI
						epcr_q(63 to 63)                 & --DMIUH
						tidn(42 to 63)                   ; --///
-- ESR
ex6_esr_di     <= ex6_spr_wd(36 to 36)             & --PIL
						ex6_spr_wd(37 to 37)             & --PPR
						ex6_spr_wd(38 to 38)             & --PTR
						ex6_spr_wd(39 to 39)             & --FP
						ex6_spr_wd(40 to 40)             & --ST
						ex6_spr_wd(42 to 42)             & --DLK0
						ex6_spr_wd(43 to 43)             & --DLK1
						ex6_spr_wd(44 to 44)             & --AP
						ex6_spr_wd(45 to 45)             & --PUO
						ex6_spr_wd(46 to 46)             & --BO
						ex6_spr_wd(47 to 47)             & --PIE
						ex6_spr_wd(49 to 49)             & --UCT
						ex6_spr_wd(53 to 53)             & --DATA
						ex6_spr_wd(54 to 54)             & --TLBI
						ex6_spr_wd(55 to 55)             & --PT
						ex6_spr_wd(56 to 56)             & --SPV
						ex6_spr_wd(57 to 57)             ; --EPID
esr_do         <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 35)                   & --///
						esr_q(47 to 47)                  & --PIL
						esr_q(48 to 48)                  & --PPR
						esr_q(49 to 49)                  & --PTR
						esr_q(50 to 50)                  & --FP
						esr_q(51 to 51)                  & --ST
						tidn(41 to 41)                   & --///
						esr_q(52 to 52)                  & --DLK0
						esr_q(53 to 53)                  & --DLK1
						esr_q(54 to 54)                  & --AP
						esr_q(55 to 55)                  & --PUO
						esr_q(56 to 56)                  & --BO
						esr_q(57 to 57)                  & --PIE
						tidn(48 to 48)                   & --///
						esr_q(58 to 58)                  & --UCT
						tidn(50 to 52)                   & --///
						esr_q(59 to 59)                  & --DATA
						esr_q(60 to 60)                  & --TLBI
						esr_q(61 to 61)                  & --PT
						esr_q(62 to 62)                  & --SPV
						esr_q(63 to 63)                  & --EPID
						tidn(58 to 63)                   ; --///
-- GDEAR
ex6_gdear_di   <= ex6_spr_wd(64-(regsize) to 63)   ; --GDEAR
gdear_do       <= tidn(0 to 64-(regsize))          &
						gdear_q(64-(regsize) to 63)      ; --GDEAR
-- GESR
ex6_gesr_di    <= ex6_spr_wd(36 to 36)             & --PIL
						ex6_spr_wd(37 to 37)             & --PPR
						ex6_spr_wd(38 to 38)             & --PTR
						ex6_spr_wd(39 to 39)             & --FP
						ex6_spr_wd(40 to 40)             & --ST
						ex6_spr_wd(42 to 42)             & --DLK0
						ex6_spr_wd(43 to 43)             & --DLK1
						ex6_spr_wd(44 to 44)             & --AP
						ex6_spr_wd(45 to 45)             & --PUO
						ex6_spr_wd(46 to 46)             & --BO
						ex6_spr_wd(47 to 47)             & --PIE
						ex6_spr_wd(49 to 49)             & --UCT
						ex6_spr_wd(53 to 53)             & --DATA
						ex6_spr_wd(54 to 54)             & --TLBI
						ex6_spr_wd(55 to 55)             & --PT
						ex6_spr_wd(56 to 56)             & --SPV
						ex6_spr_wd(57 to 57)             ; --EPID
gesr_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 35)                   & --///
						gesr_q(47 to 47)                 & --PIL
						gesr_q(48 to 48)                 & --PPR
						gesr_q(49 to 49)                 & --PTR
						gesr_q(50 to 50)                 & --FP
						gesr_q(51 to 51)                 & --ST
						tidn(41 to 41)                   & --///
						gesr_q(52 to 52)                 & --DLK0
						gesr_q(53 to 53)                 & --DLK1
						gesr_q(54 to 54)                 & --AP
						gesr_q(55 to 55)                 & --PUO
						gesr_q(56 to 56)                 & --BO
						gesr_q(57 to 57)                 & --PIE
						tidn(48 to 48)                   & --///
						gesr_q(58 to 58)                 & --UCT
						tidn(50 to 52)                   & --///
						gesr_q(59 to 59)                 & --DATA
						gesr_q(60 to 60)                 & --TLBI
						gesr_q(61 to 61)                 & --PT
						gesr_q(62 to 62)                 & --SPV
						gesr_q(63 to 63)                 & --EPID
						tidn(58 to 63)                   ; --///
-- GPIR
ex6_gpir_di    <= ex6_spr_wd(32 to 49)             & --VPTAG
						ex6_spr_wd(50 to 63)             ; --DBTAG
gpir_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						gpir_q(32 to 49)                 & --VPTAG
						gpir_q(50 to 63)                 ; --DBTAG
-- GSRR0
ex6_gsrr0_di   <= ex6_spr_wd(62-(eff_ifar) to 61)  ; --GSRR0
gsrr0_do       <= tidn(0 to 62-(eff_ifar))         &
						gsrr0_q(64-(eff_ifar) to 63)     & --GSRR0
						tidn(62 to 63)                   ; --///
-- GSRR1
ex6_gsrr1_di   <= ex6_spr_wd(32 to 32)             & --CM
						ex6_spr_wd(35 to 35)             & --GS
						ex6_spr_wd(37 to 37)             & --UCLE
						ex6_spr_wd(38 to 38)             & --SPV
						ex6_spr_wd(46 to 46)             & --CE
						ex6_spr_wd(48 to 48)             & --EE
						ex6_spr_wd(49 to 49)             & --PR
						ex6_spr_wd(50 to 50)             & --FP
						ex6_spr_wd(51 to 51)             & --ME
						ex6_spr_wd(52 to 52)             & --FE0
						ex6_spr_wd(54 to 54)             & --DE
						ex6_spr_wd(55 to 55)             & --FE1
						ex6_spr_wd(58 to 58)             & --IS
						ex6_spr_wd(59 to 59)             ; --DS
gsrr1_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						gsrr1_q(50 to 50)                & --CM
						tidn(33 to 34)                   & --///
						gsrr1_q(51 to 51)                & --GS
						tidn(36 to 36)                   & --///
						gsrr1_q(52 to 52)                & --UCLE
						gsrr1_q(53 to 53)                & --SPV
						tidn(39 to 45)                   & --///
						gsrr1_q(54 to 54)                & --CE
						tidn(47 to 47)                   & --///
						gsrr1_q(55 to 55)                & --EE
						gsrr1_q(56 to 56)                & --PR
						gsrr1_q(57 to 57)                & --FP
						gsrr1_q(58 to 58)                & --ME
						gsrr1_q(59 to 59)                & --FE0
						tidn(53 to 53)                   & --///
						gsrr1_q(60 to 60)                & --DE
						gsrr1_q(61 to 61)                & --FE1
						tidn(56 to 57)                   & --///
						gsrr1_q(62 to 62)                & --IS
						gsrr1_q(63 to 63)                & --DS
						tidn(60 to 63)                   ; --///
-- HACOP
ex6_hacop_di   <= ex6_spr_wd(32 to 63)             ; --CT
hacop_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						hacop_q(32 to 63)                ; --CT
-- MCSR
ex6_mcsr_di    <= ex6_spr_wd(48 to 48)             & --DPOVR
						ex6_spr_wd(49 to 49)             & --DDMH
						ex6_spr_wd(50 to 50)             & --TLBIVAXSR
						ex6_spr_wd(51 to 51)             & --TLBLRUPE
						ex6_spr_wd(52 to 52)             & --IL2ECC
						ex6_spr_wd(53 to 53)             & --DL2ECC
						ex6_spr_wd(54 to 54)             & --DDPE
						ex6_spr_wd(55 to 55)             & --EXT
						ex6_spr_wd(56 to 56)             & --DCPE
						ex6_spr_wd(57 to 57)             & --IEMH
						ex6_spr_wd(58 to 58)             & --DEMH
						ex6_spr_wd(59 to 59)             & --TLBMH
						ex6_spr_wd(60 to 60)             & --IEPE
						ex6_spr_wd(61 to 61)             & --DEPE
						ex6_spr_wd(62 to 62)             ; --TLBPE
mcsr_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 47)                   & --///
						mcsr_q(49 to 49)                 & --DPOVR
						mcsr_q(50 to 50)                 & --DDMH
						mcsr_q(51 to 51)                 & --TLBIVAXSR
						mcsr_q(52 to 52)                 & --TLBLRUPE
						mcsr_q(53 to 53)                 & --IL2ECC
						mcsr_q(54 to 54)                 & --DL2ECC
						mcsr_q(55 to 55)                 & --DDPE
						mcsr_q(56 to 56)                 & --EXT
						mcsr_q(57 to 57)                 & --DCPE
						mcsr_q(58 to 58)                 & --IEMH
						mcsr_q(59 to 59)                 & --DEMH
						mcsr_q(60 to 60)                 & --TLBMH
						mcsr_q(61 to 61)                 & --IEPE
						mcsr_q(62 to 62)                 & --DEPE
						mcsr_q(63 to 63)                 & --TLBPE
						tidn(63 to 63)                   ; --///
-- MCSRR0
ex6_mcsrr0_di  <= ex6_spr_wd(62-(eff_ifar) to 61)  ; --SRR0
mcsrr0_do      <= tidn(0 to 62-(eff_ifar))         &
						mcsrr0_q(64-(eff_ifar) to 63)    & --SRR0
						tidn(62 to 63)                   ; --///
-- MCSRR1
ex6_mcsrr1_di  <= ex6_spr_wd(32 to 32)             & --CM
						ex6_spr_wd(35 to 35)             & --GS
						ex6_spr_wd(37 to 37)             & --UCLE
						ex6_spr_wd(38 to 38)             & --SPV
						ex6_spr_wd(46 to 46)             & --CE
						ex6_spr_wd(48 to 48)             & --EE
						ex6_spr_wd(49 to 49)             & --PR
						ex6_spr_wd(50 to 50)             & --FP
						ex6_spr_wd(51 to 51)             & --ME
						ex6_spr_wd(52 to 52)             & --FE0
						ex6_spr_wd(54 to 54)             & --DE
						ex6_spr_wd(55 to 55)             & --FE1
						ex6_spr_wd(58 to 58)             & --IS
						ex6_spr_wd(59 to 59)             ; --DS
mcsrr1_do      <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						mcsrr1_q(50 to 50)               & --CM
						tidn(33 to 34)                   & --///
						mcsrr1_q(51 to 51)               & --GS
						tidn(36 to 36)                   & --///
						mcsrr1_q(52 to 52)               & --UCLE
						mcsrr1_q(53 to 53)               & --SPV
						tidn(39 to 45)                   & --///
						mcsrr1_q(54 to 54)               & --CE
						tidn(47 to 47)                   & --///
						mcsrr1_q(55 to 55)               & --EE
						mcsrr1_q(56 to 56)               & --PR
						mcsrr1_q(57 to 57)               & --FP
						mcsrr1_q(58 to 58)               & --ME
						mcsrr1_q(59 to 59)               & --FE0
						tidn(53 to 53)                   & --///
						mcsrr1_q(60 to 60)               & --DE
						mcsrr1_q(61 to 61)               & --FE1
						tidn(56 to 57)                   & --///
						mcsrr1_q(62 to 62)               & --IS
						mcsrr1_q(63 to 63)               & --DS
						tidn(60 to 63)                   ; --///
-- MSR
ex6_msr_di     <= ex6_spr_wd(32 to 32)             & --CM
						ex6_spr_wd(35 to 35)             & --GS
						ex6_spr_wd(37 to 37)             & --UCLE
						ex6_spr_wd(38 to 38)             & --SPV
						ex6_spr_wd(46 to 46)             & --CE
						ex6_spr_wd(48 to 48)             & --EE
						ex6_spr_wd(49 to 49)             & --PR
						ex6_spr_wd(50 to 50)             & --FP
						ex6_spr_wd(51 to 51)             & --ME
						ex6_spr_wd(52 to 52)             & --FE0
						ex6_spr_wd(54 to 54)             & --DE
						ex6_spr_wd(55 to 55)             & --FE1
						ex6_spr_wd(58 to 58)             & --IS
						ex6_spr_wd(59 to 59)             ; --DS
msr_do         <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						msr_q(50 to 50)                  & --CM
						tidn(33 to 34)                   & --///
						msr_q(51 to 51)                  & --GS
						tidn(36 to 36)                   & --///
						msr_q(52 to 52)                  & --UCLE
						msr_q(53 to 53)                  & --SPV
						tidn(39 to 45)                   & --///
						msr_q(54 to 54)                  & --CE
						tidn(47 to 47)                   & --///
						msr_q(55 to 55)                  & --EE
						msr_q(56 to 56)                  & --PR
						msr_q(57 to 57)                  & --FP
						msr_q(58 to 58)                  & --ME
						msr_q(59 to 59)                  & --FE0
						tidn(53 to 53)                   & --///
						msr_q(60 to 60)                  & --DE
						msr_q(61 to 61)                  & --FE1
						tidn(56 to 57)                   & --///
						msr_q(62 to 62)                  & --IS
						msr_q(63 to 63)                  & --DS
						tidn(60 to 63)                   ; --///
-- MSRP
ex6_msrp_di    <= ex6_spr_wd(37 to 37)             & --UCLEP
						ex6_spr_wd(54 to 54)             ; --DEP
msrp_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 36)                   & --///
						msrp_q(62 to 62)                 & --UCLEP
						tidn(38 to 53)                   & --///
						msrp_q(63 to 63)                 & --DEP
						tidn(55 to 63)                   ; --///
-- SRR0
ex6_srr0_di    <= ex6_spr_wd(62-(eff_ifar) to 61)  ; --SRR0
srr0_do        <= tidn(0 to 62-(eff_ifar))         &
						srr0_q(64-(eff_ifar) to 63)      & --SRR0
						tidn(62 to 63)                   ; --///
-- SRR1
ex6_srr1_di    <= ex6_spr_wd(32 to 32)             & --CM
						ex6_spr_wd(35 to 35)             & --GS
						ex6_spr_wd(37 to 37)             & --UCLE
						ex6_spr_wd(38 to 38)             & --SPV
						ex6_spr_wd(46 to 46)             & --CE
						ex6_spr_wd(48 to 48)             & --EE
						ex6_spr_wd(49 to 49)             & --PR
						ex6_spr_wd(50 to 50)             & --FP
						ex6_spr_wd(51 to 51)             & --ME
						ex6_spr_wd(52 to 52)             & --FE0
						ex6_spr_wd(54 to 54)             & --DE
						ex6_spr_wd(55 to 55)             & --FE1
						ex6_spr_wd(58 to 58)             & --IS
						ex6_spr_wd(59 to 59)             ; --DS
srr1_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						srr1_q(50 to 50)                 & --CM
						tidn(33 to 34)                   & --///
						srr1_q(51 to 51)                 & --GS
						tidn(36 to 36)                   & --///
						srr1_q(52 to 52)                 & --UCLE
						srr1_q(53 to 53)                 & --SPV
						tidn(39 to 45)                   & --///
						srr1_q(54 to 54)                 & --CE
						tidn(47 to 47)                   & --///
						srr1_q(55 to 55)                 & --EE
						srr1_q(56 to 56)                 & --PR
						srr1_q(57 to 57)                 & --FP
						srr1_q(58 to 58)                 & --ME
						srr1_q(59 to 59)                 & --FE0
						tidn(53 to 53)                   & --///
						srr1_q(60 to 60)                 & --DE
						srr1_q(61 to 61)                 & --FE1
						tidn(56 to 57)                   & --///
						srr1_q(62 to 62)                 & --IS
						srr1_q(63 to 63)                 & --DS
						tidn(60 to 63)                   ; --///
-- TCR
ex6_tcr_di     <= ex6_spr_wd(32 to 33)             & --WP
						ex6_spr_wd(34 to 35)             & --WRC
						ex6_spr_wd(36 to 36)             & --WIE
						ex6_spr_wd(37 to 37)             & --DIE
						ex6_spr_wd(38 to 39)             & --FP
						ex6_spr_wd(40 to 40)             & --FIE
						ex6_spr_wd(41 to 41)             & --ARE
						ex6_spr_wd(42 to 42)             & --UDIE
						ex6_spr_wd(51 to 51)             ; --UD
tcr_do         <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tcr_q(52 to 53)                  & --WP
						tcr_q(54 to 55)                  & --WRC
						tcr_q(56 to 56)                  & --WIE
						tcr_q(57 to 57)                  & --DIE
						tcr_q(58 to 59)                  & --FP
						tcr_q(60 to 60)                  & --FIE
						tcr_q(61 to 61)                  & --ARE
						tcr_q(62 to 62)                  & --UDIE
						tidn(43 to 50)                   & --///
						tcr_q(63 to 63)                  & --UD
						tidn(52 to 63)                   ; --///
-- TSR
ex6_tsr_di     <= ex6_spr_wd(32 to 32)             & --ENW
						ex6_spr_wd(33 to 33)             & --WIS
						ex6_spr_wd(36 to 36)             & --DIS
						ex6_spr_wd(37 to 37)             & --FIS
						ex6_spr_wd(38 to 38)             ; --UDIS
tsr_do         <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tsr_q(59 to 59)                  & --ENW
						tsr_q(60 to 60)                  & --WIS
						tsr_wrs_q(0 to 1)                & --WRS
						tsr_q(61 to 61)                  & --DIS
						tsr_q(62 to 62)                  & --FIS
						tsr_q(63 to 63)                  & --UDIS
						tidn(39 to 63)                   ; --///
-- UDEC
ex6_udec_di    <= ex6_spr_wd(32 to 63)             ; --UDEC
udec_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						udec_q(32 to 63)                 ; --UDEC
-- XUCR1
ex6_xucr1_di   <= ex6_spr_wd(57 to 59)             & --LL_TB_SEL
						ex6_spr_wd(62 to 62)             & --LL_SEL
						ex6_spr_wd(63 to 63)             ; --LL_EN
xucr1_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 56)                   & --///
						xucr1_q(59 to 61)                & --LL_TB_SEL
						llstate(0 to 1)                  & --LL_STATE
						xucr1_q(62 to 62)                & --LL_SEL
						xucr1_q(63 to 63)                ; --LL_EN

-- Unused Signals
mark_unused(acop_do(0 to 64-regsize));
mark_unused(ccr3_do(0 to 64-regsize));
mark_unused(csrr0_do(0 to 64-regsize));
mark_unused(csrr1_do(0 to 64-regsize));
mark_unused(dbcr0_do(0 to 64-regsize));
mark_unused(dbcr1_do(0 to 64-regsize));
mark_unused(dbsr_do(0 to 64-regsize));
mark_unused(dear_do(0 to 64-regsize));
mark_unused(dec_do(0 to 64-regsize));
mark_unused(decar_do(0 to 64-regsize));
mark_unused(epcr_do(0 to 64-regsize));
mark_unused(esr_do(0 to 64-regsize));
mark_unused(gdear_do(0 to 64-regsize));
mark_unused(gesr_do(0 to 64-regsize));
mark_unused(gpir_do(0 to 64-regsize));
mark_unused(gsrr0_do(0 to 64-regsize));
mark_unused(gsrr1_do(0 to 64-regsize));
mark_unused(hacop_do(0 to 64-regsize));
mark_unused(mcsr_do(0 to 64-regsize));
mark_unused(mcsrr0_do(0 to 64-regsize));
mark_unused(mcsrr1_do(0 to 64-regsize));
mark_unused(msr_do(0 to 64-regsize));
mark_unused(msrp_do(0 to 64-regsize));
mark_unused(srr0_do(0 to 64-regsize));
mark_unused(srr1_do(0 to 64-regsize));
mark_unused(tcr_do(0 to 64-regsize));
mark_unused(tsr_do(0 to 64-regsize));
mark_unused(udec_do(0 to 64-regsize));
mark_unused(xucr1_do(0 to 64-regsize));
mark_unused(ex2_ctr_re);
mark_unused(ex2_lr_re);
mark_unused(ex2_xer_re);
mark_unused(ex2_acop_we);
mark_unused(ex2_ctr_we);
mark_unused(ex2_dear_we);
mark_unused(ex2_dec_we);
mark_unused(ex2_esr_we);
mark_unused(ex2_gdear_we);
mark_unused(ex2_gesr_we);
mark_unused(ex2_gsrr0_we);
mark_unused(ex2_gsrr1_we);
mark_unused(ex2_lr_we);
mark_unused(ex2_srr0_we);
mark_unused(ex2_srr1_we);
mark_unused(ex2_udec_we);
mark_unused(ex2_xer_we);
mark_unused(ex2_rs2_q(48 to 49));
mark_unused(cspr_tspr_ex1_instr(6 to 10));
mark_unused(cspr_tspr_ex1_instr(31));
mark_unused(ex6_gdear_di);
mark_unused(exx_act_data(1));
mark_unused(exx_act_data(3 to 4));
mark_unused(mchk_int_q);

-- SPR Latch Instances
acop_latch_gen : if a2mode = 1 generate
acop_latch : tri_ser_rlmreg_p
generic map(width   => acop_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => acop_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(acop_offset to acop_offset + acop_q'length-1),
            scout   => sov(acop_offset to acop_offset + acop_q'length-1),
            din     => acop_d,
            dout    => acop_q);
end generate;
acop_latch_tie : if a2mode = 0 generate
	acop_q          <= (others=>'0');
end generate;
ccr3_latch : tri_ser_rlmreg_p
generic map(width   => ccr3_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => ccr3_act,
            forcee => ccfg_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => ccfg_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv_ccfg(ccr3_offset_ccfg to ccr3_offset_ccfg + ccr3_q'length-1),
            scout   => sov_ccfg(ccr3_offset_ccfg to ccr3_offset_ccfg + ccr3_q'length-1),
            din     => ccr3_d,
            dout    => ccr3_q);
csrr0_latch_gen : if a2mode = 1 generate
csrr0_latch : tri_ser_rlmreg_p
generic map(width   => csrr0_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => csrr0_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(csrr0_offset to csrr0_offset + csrr0_q'length-1),
            scout   => sov(csrr0_offset to csrr0_offset + csrr0_q'length-1),
            din     => csrr0_d,
            dout    => csrr0_q);
end generate;
csrr0_latch_tie : if a2mode = 0 generate
	csrr0_q         <= (others=>'0');
end generate;
csrr1_latch_gen : if a2mode = 1 generate
csrr1_latch : tri_ser_rlmreg_p
generic map(width   => csrr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => csrr1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(csrr1_offset to csrr1_offset + csrr1_q'length-1),
            scout   => sov(csrr1_offset to csrr1_offset + csrr1_q'length-1),
            din     => csrr1_d,
            dout    => csrr1_q);
end generate;
csrr1_latch_tie : if a2mode = 0 generate
	csrr1_q         <= (others=>'0');
end generate;
dbcr0_latch : tri_ser_rlmreg_p
generic map(width   => dbcr0_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dbcr0_act,
            forcee => dcfg_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => dcfg_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv_dcfg(dbcr0_offset_dcfg to dbcr0_offset_dcfg + dbcr0_q'length-1),
            scout   => sov_dcfg(dbcr0_offset_dcfg to dbcr0_offset_dcfg + dbcr0_q'length-1),
            din     => dbcr0_d,
            dout    => dbcr0_q);
dbcr1_latch : tri_ser_rlmreg_p
generic map(width   => dbcr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dbcr1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr1_offset to dbcr1_offset + dbcr1_q'length-1),
            scout   => sov(dbcr1_offset to dbcr1_offset + dbcr1_q'length-1),
            din     => dbcr1_d,
            dout    => dbcr1_q);
dbsr_latch : tri_ser_rlmreg_p
generic map(width   => dbsr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dbsr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbsr_offset to dbsr_offset + dbsr_q'length-1),
            scout   => sov(dbsr_offset to dbsr_offset + dbsr_q'length-1),
            din     => dbsr_d,
            dout    => dbsr_q);
dear_latch : tri_ser_rlmreg_p
generic map(width   => dear_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dear_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dear_offset to dear_offset + dear_q'length-1),
            scout   => sov(dear_offset to dear_offset + dear_q'length-1),
            din     => dear_d,
            dout    => dear_q);
dec_latch : tri_ser_rlmreg_p
generic map(width   => dec_q'length, init => 2147483647, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dec_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dec_offset to dec_offset + dec_q'length-1),
            scout   => sov(dec_offset to dec_offset + dec_q'length-1),
            din     => dec_d,
            dout    => dec_q);
decar_latch_gen : if a2mode = 1 generate
decar_latch : tri_ser_rlmreg_p
generic map(width   => decar_q'length, init => 2147483647, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => decar_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(decar_offset to decar_offset + decar_q'length-1),
            scout   => sov(decar_offset to decar_offset + decar_q'length-1),
            din     => decar_d,
            dout    => decar_q);
end generate;
decar_latch_tie : if a2mode = 0 generate
	decar_q         <= (others=>'0');
end generate;
epcr_latch_gen : if hvmode = 1 generate
epcr_latch : tri_ser_rlmreg_p
generic map(width   => epcr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => epcr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epcr_offset to epcr_offset + epcr_q'length-1),
            scout   => sov(epcr_offset to epcr_offset + epcr_q'length-1),
            din     => epcr_d,
            dout    => epcr_q);
end generate;
epcr_latch_tie : if hvmode = 0 generate
	epcr_q          <= (others=>'0');
end generate;
esr_latch : tri_ser_rlmreg_p
generic map(width   => esr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => esr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(esr_offset to esr_offset + esr_q'length-1),
            scout   => sov(esr_offset to esr_offset + esr_q'length-1),
            din     => esr_d,
            dout    => esr_q);
gdear_latch_gen : if hvmode = 1 generate
gdear_latch : tri_ser_rlmreg_p
generic map(width   => gdear_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => gdear_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gdear_offset to gdear_offset + gdear_q'length-1),
            scout   => sov(gdear_offset to gdear_offset + gdear_q'length-1),
            din     => gdear_d,
            dout    => gdear_q);
end generate;
gdear_latch_tie : if hvmode = 0 generate
	gdear_q         <= (others=>'0');
end generate;
gesr_latch_gen : if hvmode = 1 generate
gesr_latch : tri_ser_rlmreg_p
generic map(width   => gesr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => gesr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gesr_offset to gesr_offset + gesr_q'length-1),
            scout   => sov(gesr_offset to gesr_offset + gesr_q'length-1),
            din     => gesr_d,
            dout    => gesr_q);
end generate;
gesr_latch_tie : if hvmode = 0 generate
	gesr_q          <= (others=>'0');
end generate;
gpir_latch_gen : if hvmode = 1 generate
gpir_latch : tri_ser_rlmreg_p
generic map(width   => gpir_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => gpir_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gpir_offset to gpir_offset + gpir_q'length-1),
            scout   => sov(gpir_offset to gpir_offset + gpir_q'length-1),
            din     => gpir_d,
            dout    => gpir_q);
end generate;
gpir_latch_tie : if hvmode = 0 generate
	gpir_q          <= (others=>'0');
end generate;
gsrr0_latch_gen : if hvmode = 1 generate
gsrr0_latch : tri_ser_rlmreg_p
generic map(width   => gsrr0_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => gsrr0_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gsrr0_offset to gsrr0_offset + gsrr0_q'length-1),
            scout   => sov(gsrr0_offset to gsrr0_offset + gsrr0_q'length-1),
            din     => gsrr0_d,
            dout    => gsrr0_q);
end generate;
gsrr0_latch_tie : if hvmode = 0 generate
	gsrr0_q         <= (others=>'0');
end generate;
gsrr1_latch_gen : if hvmode = 1 generate
gsrr1_latch : tri_ser_rlmreg_p
generic map(width   => gsrr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => gsrr1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gsrr1_offset to gsrr1_offset + gsrr1_q'length-1),
            scout   => sov(gsrr1_offset to gsrr1_offset + gsrr1_q'length-1),
            din     => gsrr1_d,
            dout    => gsrr1_q);
end generate;
gsrr1_latch_tie : if hvmode = 0 generate
	gsrr1_q         <= (others=>'0');
end generate;
hacop_latch_gen : if hvmode = 1 generate
hacop_latch : tri_ser_rlmreg_p
generic map(width   => hacop_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => hacop_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(hacop_offset to hacop_offset + hacop_q'length-1),
            scout   => sov(hacop_offset to hacop_offset + hacop_q'length-1),
            din     => hacop_d,
            dout    => hacop_q);
end generate;
hacop_latch_tie : if hvmode = 0 generate
	hacop_q         <= (others=>'0');
end generate;
mcsr_latch_gen : if a2mode = 1 generate
mcsr_latch : tri_ser_rlmreg_p
generic map(width   => mcsr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => mcsr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mcsr_offset to mcsr_offset + mcsr_q'length-1),
            scout   => sov(mcsr_offset to mcsr_offset + mcsr_q'length-1),
            din     => mcsr_d,
            dout    => mcsr_q);
end generate;
mcsr_latch_tie : if a2mode = 0 generate
	mcsr_q          <= (others=>'0');
end generate;
mcsrr0_latch_gen : if a2mode = 1 generate
mcsrr0_latch : tri_ser_rlmreg_p
generic map(width   => mcsrr0_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => mcsrr0_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mcsrr0_offset to mcsrr0_offset + mcsrr0_q'length-1),
            scout   => sov(mcsrr0_offset to mcsrr0_offset + mcsrr0_q'length-1),
            din     => mcsrr0_d,
            dout    => mcsrr0_q);
end generate;
mcsrr0_latch_tie : if a2mode = 0 generate
	mcsrr0_q        <= (others=>'0');
end generate;
mcsrr1_latch_gen : if a2mode = 1 generate
mcsrr1_latch : tri_ser_rlmreg_p
generic map(width   => mcsrr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => mcsrr1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mcsrr1_offset to mcsrr1_offset + mcsrr1_q'length-1),
            scout   => sov(mcsrr1_offset to mcsrr1_offset + mcsrr1_q'length-1),
            din     => mcsrr1_d,
            dout    => mcsrr1_q);
end generate;
mcsrr1_latch_tie : if a2mode = 0 generate
	mcsrr1_q        <= (others=>'0');
end generate;
msr_latch : tri_ser_rlmreg_p
generic map(width   => msr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => msr_act,
            forcee => ccfg_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => ccfg_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv_ccfg(msr_offset_ccfg to msr_offset_ccfg + msr_q'length-1),
            scout   => sov_ccfg(msr_offset_ccfg to msr_offset_ccfg + msr_q'length-1),
            din     => msr_d,
            dout    => msr_q);
msrp_latch_gen : if hvmode = 1 generate
msrp_latch : tri_ser_rlmreg_p
generic map(width   => msrp_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => msrp_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msrp_offset to msrp_offset + msrp_q'length-1),
            scout   => sov(msrp_offset to msrp_offset + msrp_q'length-1),
            din     => msrp_d,
            dout    => msrp_q);
end generate;
msrp_latch_tie : if hvmode = 0 generate
	msrp_q          <= (others=>'0');
end generate;
srr0_latch : tri_ser_rlmreg_p
generic map(width   => srr0_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => srr0_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(srr0_offset to srr0_offset + srr0_q'length-1),
            scout   => sov(srr0_offset to srr0_offset + srr0_q'length-1),
            din     => srr0_d,
            dout    => srr0_q);
srr1_latch : tri_ser_rlmreg_p
generic map(width   => srr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => srr1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(srr1_offset to srr1_offset + srr1_q'length-1),
            scout   => sov(srr1_offset to srr1_offset + srr1_q'length-1),
            din     => srr1_d,
            dout    => srr1_q);
tcr_latch_gen : if a2mode = 1 generate
tcr_latch : tri_ser_rlmreg_p
generic map(width   => tcr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => tcr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(tcr_offset to tcr_offset + tcr_q'length-1),
            scout   => sov(tcr_offset to tcr_offset + tcr_q'length-1),
            din     => tcr_d,
            dout    => tcr_q);
end generate;
tcr_latch_tie : if a2mode = 0 generate
	tcr_q           <= (others=>'0');
end generate;
tsr_latch_gen : if a2mode = 1 generate
tsr_latch : tri_ser_rlmreg_p
generic map(width   => tsr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => tsr_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(tsr_offset to tsr_offset + tsr_q'length-1),
            scout   => sov(tsr_offset to tsr_offset + tsr_q'length-1),
            din     => tsr_d,
            dout    => tsr_q);
end generate;
tsr_latch_tie : if a2mode = 0 generate
	tsr_q           <= (others=>'0');
end generate;
udec_latch_gen : if a2mode = 1 generate
udec_latch : tri_ser_rlmreg_p
generic map(width   => udec_q'length, init => 2147483647, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => udec_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(udec_offset to udec_offset + udec_q'length-1),
            scout   => sov(udec_offset to udec_offset + udec_q'length-1),
            din     => udec_d,
            dout    => udec_q);
end generate;
udec_latch_tie : if a2mode = 0 generate
	udec_q          <= (others=>'0');
end generate;
xucr1_latch : tri_ser_rlmreg_p
generic map(width   => xucr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => xucr1_act,
            forcee => ccfg_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => ccfg_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv_ccfg(xucr1_offset_ccfg to xucr1_offset_ccfg + xucr1_q'length-1),
            scout   => sov_ccfg(xucr1_offset_ccfg to xucr1_offset_ccfg + xucr1_q'length-1),
            din     => xucr1_d,
            dout    => xucr1_q);


-- Latch Instances
exx_act_latch : tri_rlmreg_p
  generic map (width => exx_act_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_act_offset to exx_act_offset + exx_act_q'length-1),
            scout   => sov(exx_act_offset to exx_act_offset + exx_act_q'length-1),
            din     => exx_act_d,
            dout    => exx_act_q);
ex2_is_mfspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_mfspr,
            dout(0) => ex2_is_mfspr_q);
ex2_is_mtspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_mtspr,
            dout(0) => ex2_is_mtspr_q);
ex2_is_mfmsr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_mfmsr,
            dout(0) => ex2_is_mfmsr_q);
ex2_instr_latch : tri_regk
  generic map (width => ex2_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_instr_d,
            dout    => ex2_instr_q);
ex3_is_mtxer_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_mtxer_offset),
            scout   => sov(ex3_is_mtxer_offset),
            din     => ex3_is_mtxer_d,
            dout    => ex3_is_mtxer_q);
ex3_is_mfxer_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_mfxer_offset),
            scout   => sov(ex3_is_mfxer_offset),
            din     => ex3_is_mfxer_d,
            dout    => ex3_is_mfxer_q);
ex2_rfi_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_rfi_d,
            dout(0) => ex2_rfi_q);
ex2_rfgi_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_rfgi_d,
            dout(0) => ex2_rfgi_q);
ex2_rfci_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_rfci,
            dout(0) => ex2_rfci_q);
ex2_rfmci_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_rfmci,
            dout(0) => ex2_rfmci_q);
ex3_rfi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_rfi_offset),
            scout   => sov(ex3_rfi_offset),
            din     => ex2_rfi_q                  ,
            dout    => ex3_rfi_q);
ex3_rfgi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_rfgi_offset),
            scout   => sov(ex3_rfgi_offset),
            din     => ex2_rfgi_q                 ,
            dout    => ex3_rfgi_q);
ex3_rfci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_rfci_offset),
            scout   => sov(ex3_rfci_offset),
            din     => ex2_rfci_q                 ,
            dout    => ex3_rfci_q);
ex3_rfmci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_rfmci_offset),
            scout   => sov(ex3_rfmci_offset),
            din     => ex2_rfmci_q                ,
            dout    => ex3_rfmci_q);
ex4_is_mfxer_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_is_mfxer_q             ,
            dout(0) => ex4_is_mfxer_q);
ex4_is_mtxer_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_is_mtxer_q             ,
            dout(0) => ex4_is_mtxer_q);
ex4_rfi_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_rfi_q                  ,
            dout(0) => ex4_rfi_q);
ex4_rfgi_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_rfgi_q                 ,
            dout(0) => ex4_rfgi_q);
ex4_rfci_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_rfci_q                 ,
            dout(0) => ex4_rfci_q);
ex4_rfmci_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_rfmci_q                ,
            dout(0) => ex4_rfmci_q);
ex5_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_val_offset),
            scout   => sov(ex5_val_offset),
            din     => ex4_val,
            dout    => ex5_val_q);
ex5_rfi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_rfi_offset),
            scout   => sov(ex5_rfi_offset),
            din     => ex4_rfi_q                  ,
            dout    => ex5_rfi_q);
ex5_rfgi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_rfgi_offset),
            scout   => sov(ex5_rfgi_offset),
            din     => ex4_rfgi_q                 ,
            dout    => ex5_rfgi_q);
ex5_rfci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_rfci_offset),
            scout   => sov(ex5_rfci_offset),
            din     => ex4_rfci_q                 ,
            dout    => ex5_rfci_q);
ex5_rfmci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_rfmci_offset),
            scout   => sov(ex5_rfmci_offset),
            din     => ex4_rfmci_q                ,
            dout    => ex5_rfmci_q);
ex6_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_val_offset),
            scout   => sov(ex6_val_offset),
            din     => ex5_val,
            dout    => ex6_val_q);
ex6_rfi_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_rfi_q                  ,
            dout(0) => ex6_rfi_q);
ex6_rfgi_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_rfgi_q                 ,
            dout(0) => ex6_rfgi_q);
ex6_rfci_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_rfci_q                 ,
            dout(0) => ex6_rfci_q);
ex6_rfmci_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_rfmci_q                ,
            dout(0) => ex6_rfmci_q);
ex6_wrtee_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cspr_tspr_ex5_is_wrtee     ,
            dout(0) => ex6_wrtee_q);
ex6_wrteei_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cspr_tspr_ex5_is_wrteei    ,
            dout(0) => ex6_wrteei_q);
ex6_is_mtmsr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cspr_tspr_ex5_is_mtmsr     ,
            dout(0) => ex6_is_mtmsr_q);
ex6_is_mtspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cspr_tspr_ex5_is_mtspr     ,
            dout(0) => ex6_is_mtspr_q);
ex6_instr_latch : tri_regk
  generic map (width => ex6_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => cspr_tspr_ex5_instr        ,
            dout    => ex6_instr_q);
ex6_int_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex5_int_act    ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_int            ,
            dout(0) => ex6_int_q);
ex6_gint_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex5_int_act    ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_gint           ,
            dout(0) => ex6_gint_q);
ex6_cint_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex5_int_act    ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_cint           ,
            dout(0) => ex6_cint_q);
ex6_mcint_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex5_int_act    ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_mcint          ,
            dout(0) => ex6_mcint_q);
ex6_nia_latch : tri_regk
  generic map (width => ex6_nia_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex5_int_act    ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => cpl_spr_ex5_nia            ,
            dout    => ex6_nia_q);
ex6_esr_latch : tri_regk
  generic map (width => ex6_esr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => cpl_spr_ex5_esr_update  ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => cpl_spr_ex5_esr   ,
            dout    => ex6_esr_q);
ex6_mcsr_latch : tri_regk
  generic map (width => ex6_mcsr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex5_int_act    ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => cpl_spr_ex5_mcsr           ,
            dout    => ex6_mcsr_q);
ex6_dbsr_latch : tri_regk
  generic map (width => ex6_dbsr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => cpl_spr_ex5_dbsr_update ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => cpl_spr_ex5_dbsr  ,
            dout    => ex6_dbsr_q);
ex6_dear_save_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_dear_save      ,
            dout(0) => ex6_dear_save_q);
ex6_dear_update_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_dear_update    ,
            dout(0) => ex6_dear_update_q);
ex6_dear_update_saved_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_dear_update_saved,
            dout(0) => ex6_dear_update_saved_q);
ex6_dbsr_update_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_dbsr_update    ,
            dout(0) => ex6_dbsr_update_q);
ex6_esr_update_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_esr_update     ,
            dout(0) => ex6_esr_update_q);
ex6_srr0_dec_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_srr0_dec   ,
            dout(0) => ex6_srr0_dec_q);
ex6_force_gsrr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex5_int_act    ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_force_gsrr     ,
            dout(0) => ex6_force_gsrr_q);
ex6_dbsr_ide_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex5_int_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => cpl_spr_ex5_dbsr_ide,
            dout(0) => ex6_dbsr_ide_q);
ex6_spr_wd_latch : tri_regk
  generic map (width => ex6_spr_wd_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(5),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex5_spr_wd                 ,
            dout    => ex6_spr_wd_q);
fit_tb_tap_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(fit_tb_tap_offset),
            scout   => sov(fit_tb_tap_offset),
            din     => fit_tb_tap_d,
            dout    => fit_tb_tap_q);
wdog_tb_tap_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(wdog_tb_tap_offset),
            scout   => sov(wdog_tb_tap_offset),
            din     => wdog_tb_tap_d,
            dout    => wdog_tb_tap_q);
hang_pulse_latch : tri_rlmreg_p
  generic map (width => hang_pulse_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(hang_pulse_offset to hang_pulse_offset + hang_pulse_q'length-1),
            scout   => sov(hang_pulse_offset to hang_pulse_offset + hang_pulse_q'length-1),
            din     => hang_pulse_d,
            dout    => hang_pulse_q);
lltap_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lltap_offset),
            scout   => sov(lltap_offset),
            din     => lltap_d,
            dout    => lltap_q);
llcnt_latch : tri_rlmreg_p
  generic map (width => llcnt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(llcnt_offset to llcnt_offset + llcnt_q'length-1),
            scout   => sov(llcnt_offset to llcnt_offset + llcnt_q'length-1),
            din     => llcnt_d,
            dout    => llcnt_q);
msrovride_pr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msrovride_pr_offset),
            scout   => sov(msrovride_pr_offset),
            din     => pc_xu_msrovride_pr         ,
            dout    => msrovride_pr_q);
msrovride_gs_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msrovride_gs_offset),
            scout   => sov(msrovride_gs_offset),
            din     => pc_xu_msrovride_gs         ,
            dout    => msrovride_gs_q);
msrovride_de_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msrovride_de_offset),
            scout   => sov(msrovride_de_offset),
            din     => pc_xu_msrovride_de,
            dout    => msrovride_de_q);
an_ac_ext_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(an_ac_ext_interrupt_offset),
            scout   => sov(an_ac_ext_interrupt_offset),
            din     => an_ac_ext_interrupt        ,
            dout    => an_ac_ext_interrupt_q);
an_ac_crit_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(an_ac_crit_interrupt_offset),
            scout   => sov(an_ac_crit_interrupt_offset),
            din     => an_ac_crit_interrupt       ,
            dout    => an_ac_crit_interrupt_q);
an_ac_perf_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(an_ac_perf_interrupt_offset),
            scout   => sov(an_ac_perf_interrupt_offset),
            din     => an_ac_perf_interrupt       ,
            dout    => an_ac_perf_interrupt_q);
dear_tmp_latch : tri_rlmreg_p
  generic map (width => dear_tmp_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex6_dear_save_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dear_tmp_offset to dear_tmp_offset + dear_tmp_q'length-1),
            scout   => sov(dear_tmp_offset to dear_tmp_offset + dear_tmp_q'length-1),
            din     => dear_tmp_d,
            dout    => dear_tmp_q);
mux_msr_gs_latch : tri_rlmreg_p
  generic map (width => mux_msr_gs_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mux_msr_gs_offset to mux_msr_gs_offset + mux_msr_gs_q'length-1),
            scout   => sov(mux_msr_gs_offset to mux_msr_gs_offset + mux_msr_gs_q'length-1),
            din     => mux_msr_gs_d,
            dout    => mux_msr_gs_q);
mux_msr_pr_latch : tri_rlmreg_p
  generic map (width => mux_msr_pr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mux_msr_pr_offset to mux_msr_pr_offset + mux_msr_pr_q'length-1),
            scout   => sov(mux_msr_pr_offset to mux_msr_pr_offset + mux_msr_pr_q'length-1),
            din     => mux_msr_pr_d,
            dout    => mux_msr_pr_q);
ex3_tspr_rt_latch : tri_rlmreg_p
  generic map (width => ex3_tspr_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tspr_rt_offset to ex3_tspr_rt_offset + ex3_tspr_rt_q'length-1),
            scout   => sov(ex3_tspr_rt_offset to ex3_tspr_rt_offset + ex3_tspr_rt_q'length-1),
            din     => ex3_tspr_rt_d,
            dout    => ex3_tspr_rt_q);
err_llbust_attempt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(err_llbust_attempt_offset),
            scout   => sov(err_llbust_attempt_offset),
            din     => err_llbust_attempt_d,
            dout    => err_llbust_attempt_q);
err_llbust_failed_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(err_llbust_failed_offset),
            scout   => sov(err_llbust_failed_offset),
            din     => err_llbust_failed_d,
            dout    => err_llbust_failed_q);
inj_llbust_attempt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(inj_llbust_attempt_offset),
            scout   => sov(inj_llbust_attempt_offset),
            din     => pc_xu_inj_llbust_attempt   ,
            dout    => inj_llbust_attempt_q);
inj_llbust_failed_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(inj_llbust_failed_offset),
            scout   => sov(inj_llbust_failed_offset),
            din     => pc_xu_inj_llbust_failed    ,
            dout    => inj_llbust_failed_q);
ex2_rs2_latch : tri_regk
  generic map (width => ex2_rs2_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => fxu_spr_ex1_rs2            ,
            dout    => ex2_rs2_q);
ex3_ct_latch : tri_rlmreg_p
  generic map (width => ex3_ct_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_ct_offset to ex3_ct_offset + ex3_ct_q'length-1),
            scout   => sov(ex3_ct_offset to ex3_ct_offset + ex3_ct_q'length-1),
            din     => ex3_ct_d,
            dout    => ex3_ct_q);
an_ac_external_mchk_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(an_ac_external_mchk_offset),
            scout   => sov(an_ac_external_mchk_offset),
            din     => an_ac_external_mchk        ,
            dout    => an_ac_external_mchk_q);
mchk_int_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mchk_int_offset),
            scout   => sov(mchk_int_offset),
            din     => mchk_int,
            dout    => mchk_int_q);
mchk_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mchk_interrupt_offset),
            scout   => sov(mchk_interrupt_offset),
            din     => mchk_interrupt,
            dout    => mchk_interrupt_q);
crit_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(crit_interrupt_offset),
            scout   => sov(crit_interrupt_offset),
            din     => crit_interrupt,
            dout    => crit_interrupt_q);
wdog_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(wdog_interrupt_offset),
            scout   => sov(wdog_interrupt_offset),
            din     => wdog_interrupt,
            dout    => wdog_interrupt_q);
dec_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dec_interrupt_offset),
            scout   => sov(dec_interrupt_offset),
            din     => dec_interrupt,
            dout    => dec_interrupt_q);
udec_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(udec_interrupt_offset),
            scout   => sov(udec_interrupt_offset),
            din     => udec_interrupt,
            dout    => udec_interrupt_q);
perf_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(perf_interrupt_offset),
            scout   => sov(perf_interrupt_offset),
            din     => perf_interrupt,
            dout    => perf_interrupt_q);
fit_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(fit_interrupt_offset),
            scout   => sov(fit_interrupt_offset),
            din     => fit_interrupt,
            dout    => fit_interrupt_q);
ext_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ext_interrupt_offset),
            scout   => sov(ext_interrupt_offset),
            din     => ext_interrupt,
            dout    => ext_interrupt_q);
single_instr_mode_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(single_instr_mode_offset),
            scout   => sov(single_instr_mode_offset),
            din     => single_instr_mode_d,
            dout    => single_instr_mode_q);
single_instr_mode_2_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(single_instr_mode_2_offset),
            scout   => sov(single_instr_mode_2_offset),
            din     => single_instr_mode_q        ,
            dout    => single_instr_mode_2_q);
machine_check_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(machine_check_offset),
            scout   => sov(machine_check_offset),
            din     => machine_check_d,
            dout    => machine_check_q);
raise_iss_pri_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(raise_iss_pri_offset),
            scout   => sov(raise_iss_pri_offset),
            din     => raise_iss_pri_d,
            dout    => raise_iss_pri_q);
raise_iss_pri_2_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(raise_iss_pri_2_offset),
            scout   => sov(raise_iss_pri_2_offset),
            din     => raise_iss_pri_q            ,
            dout    => raise_iss_pri_2_q);
epsc_egs_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_egs_offset),
            scout   => sov(epsc_egs_offset),
            din     => lsu_xu_spr_epsc_egs        ,
            dout    => epsc_egs_q);
epsc_epr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_epr_offset),
            scout   => sov(epsc_epr_offset),
            din     => lsu_xu_spr_epsc_epr        ,
            dout    => epsc_epr_q);
ex2_epid_instr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => dec_spr_ex1_epid_instr     ,
            dout(0) => ex2_epid_instr_q);
pc_xu_inj_wdt_reset_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_xu_inj_wdt_reset_offset),
            scout   => sov(pc_xu_inj_wdt_reset_offset),
            din     => pc_xu_inj_wdt_reset        ,
            dout    => pc_xu_inj_wdt_reset_q);
err_wdt_reset_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(err_wdt_reset_offset),
            scout   => sov(err_wdt_reset_offset),
            din     => err_wdt_reset_d,
            dout    => err_wdt_reset_q);
ex3_tid_rpwr_latch : tri_rlmreg_p
  generic map (width => ex3_tid_rpwr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tid_rpwr_offset to ex3_tid_rpwr_offset + ex3_tid_rpwr_q'length-1),
            scout   => sov(ex3_tid_rpwr_offset to ex3_tid_rpwr_offset + ex3_tid_rpwr_q'length-1),
            din     => ex3_tid_rpwr_d,
            dout    => ex3_tid_rpwr_q);
ram_mode_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ram_mode_offset),
            scout   => sov(ram_mode_offset),
            din     => cspr_tspr_ram_mode         ,
            dout    => ram_mode_q);
timebase_taps_latch : tri_rlmreg_p
  generic map (width => timebase_taps_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup     ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(timebase_taps_offset to timebase_taps_offset + timebase_taps_q'length-1),
            scout   => sov(timebase_taps_offset to timebase_taps_offset + timebase_taps_q'length-1),
            din     => cspr_tspr_timebase_taps ,
            dout    => timebase_taps_q);
dbsr_mrr_latch : tri_rlmreg_p
  generic map (width => dbsr_mrr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => dbsr_mrr_act   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbsr_mrr_offset to dbsr_mrr_offset + dbsr_mrr_q'length-1),
            scout   => sov(dbsr_mrr_offset to dbsr_mrr_offset + dbsr_mrr_q'length-1),
            din     => dbsr_mrr_d,
            dout    => dbsr_mrr_q);
tsr_wrs_latch : tri_rlmreg_p
  generic map (width => tsr_wrs_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tsr_wrs_act    ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(tsr_wrs_offset to tsr_wrs_offset + tsr_wrs_q'length-1),
            scout   => sov(tsr_wrs_offset to tsr_wrs_offset + tsr_wrs_q'length-1),
            din     => tsr_wrs_d,
            dout    => tsr_wrs_q);
iac1_en_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac1_en_offset),
            scout   => sov(iac1_en_offset),
            din     => iac1_en_d,
            dout    => iac1_en_q);
iac2_en_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac2_en_offset),
            scout   => sov(iac2_en_offset),
            din     => iac2_en_d,
            dout    => iac2_en_q);
iac3_en_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac3_en_offset),
            scout   => sov(iac3_en_offset),
            din     => iac3_en_d,
            dout    => iac3_en_q);
iac4_en_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac4_en_offset),
            scout   => sov(iac4_en_offset),
            din     => iac4_en_d,
            dout    => iac4_en_q);


spare_0_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tidn(0),
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b      => mpw1_dc_b(DX),
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_0_lclk,
            d1clk       => spare_0_d1clk,
            d2clk       => spare_0_d2clk);
spare_0_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_0_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_0_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_0_lclk,
            D1CLK   => spare_0_d1clk,
            D2CLK   => spare_0_d2clk,
            SCANIN  => siv(spare_0_offset to spare_0_offset + spare_0_q'length-1),
            SCANOUT => sov(spare_0_offset to spare_0_offset + spare_0_q'length-1),
            D       => spare_0_d,
            QB      => spare_0_q);
spare_0_d   <= not spare_0_q;
mark_unused(spare_0_q);


siv(0 to scan_right-1)  <= sov(1 to scan_right-1) & scan_in;
scan_out                <= sov(0);


ccfg_l : if sov_ccfg'length > 1 generate
siv_ccfg(0 to scan_right_ccfg-1) <= sov_ccfg(1 to scan_right_ccfg-1) & ccfg_scan_in;
ccfg_scan_out                    <= sov_ccfg(0);
end generate;
ccfg_s : if sov_ccfg'length <= 1 generate
ccfg_scan_out                    <= ccfg_scan_in;
sov_ccfg                         <= (others=>'0');
siv_ccfg                         <= (others=>'0');
end generate;

dcfg_l : if sov_dcfg'length > 1 generate
siv_dcfg(0 to scan_right_dcfg-1) <= sov_dcfg(1 to scan_right_dcfg-1) & dcfg_scan_in;
dcfg_scan_out                    <= sov_dcfg(0);
end generate;
dcfg_s : if sov_dcfg'length <= 1 generate
dcfg_scan_out                    <= dcfg_scan_in;
sov_dcfg                         <= (others=>'0');
siv_dcfg                         <= (others=>'0');
end generate;


end architecture xuq_spr_tspr;
