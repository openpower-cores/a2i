-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU SPR - per core registers & array
--
library ieee,ibm,support,work,tri; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;
 
entity xuq_spr_cspr is
generic(
   hvmode                           :     integer := 1;
   a2mode                           :     integer := 1;
   expand_type                      :     integer := 2;
   threads                          :     integer := 4;
   regsize                          :     integer := 64;
   eff_ifar                         :     integer := 62;
   spr_xucr0_init_mod               :     integer := 0);
port(
   nclk                             : in  clk_logic;
   
   -- CHIP IO
   an_ac_reservation_vld            : in  std_ulogic_vector(0 to threads-1);
   an_ac_tb_update_enable           : in  std_ulogic;
   an_ac_tb_update_pulse            : in  std_ulogic;
   an_ac_sleep_en                   : in  std_ulogic_vector(0 to threads-1);
   an_ac_coreid                     : in  std_ulogic_vector(54 to 61);
   spr_pvr_version_dc               : in  std_ulogic_vector(8 to 15);
   spr_pvr_revision_dc              : in  std_ulogic_vector(12 to 15);
   pc_xu_instr_trace_mode           : in  std_ulogic;
   pc_xu_instr_trace_tid            : in  std_ulogic_vector(0 to 1);
   instr_trace_mode                 : out std_ulogic_vector(0 to threads-1);

   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic_vector(0 to 0);
   mpw1_dc_b                        : in  std_ulogic_vector(0 to 0);
   mpw2_dc_b                        : in  std_ulogic;

   bcfg_sl_force : in  std_ulogic;
   bcfg_sl_thold_0_b                : in  std_ulogic;
   bcfg_slp_sl_force : in  std_ulogic;
   bcfg_slp_sl_thold_0_b            : in  std_ulogic;
   ccfg_sl_force : in  std_ulogic;
   ccfg_sl_thold_0_b                : in  std_ulogic;
   func_sl_force : in  std_ulogic;
   func_sl_thold_0_b                : in  std_ulogic;
   func_slp_sl_force : in  std_ulogic;
   func_slp_sl_thold_0_b            : in  std_ulogic;
   func_nsl_force : in  std_ulogic;
   func_nsl_thold_0_b               : in  std_ulogic;
   func_slp_nsl_force : in  std_ulogic;
   func_slp_nsl_thold_0_b           : in  std_ulogic;
   sg_0                             : in  std_ulogic;
   scan_in                          : in  std_ulogic_vector(0 to 1);
   scan_out                         : out std_ulogic_vector(0 to 1);
   bcfg_scan_in                     : in  std_ulogic;
   bcfg_scan_out                    : out std_ulogic;
   ccfg_scan_in                     : in  std_ulogic;
   ccfg_scan_out                    : out std_ulogic;

   cspr_tspr_rf1_act                : out std_ulogic;

   -- Decode
   dec_spr_rf0_tid                  : in  std_ulogic_vector(0 to threads-1);
   dec_spr_rf0_instr                : in  std_ulogic_vector(0 to 31);
   dec_spr_rf1_val                  : in  std_ulogic_vector(0 to 3);
   dec_spr_ex4_val                  : in  std_ulogic_vector(0 to threads-1);

   -- Read Data
   tspr_cspr_ex3_tspr_rt            : in  std_ulogic_vector(0 to regsize*threads-1);
   spr_byp_ex3_spr_rt               : out std_ulogic_vector(64-regsize to 63);
   
   -- Write Data
   fxu_spr_ex1_rs0                  : in  std_ulogic_vector(52 to 63);
   fxu_spr_ex1_rs1                  : in  std_ulogic_vector(54 to 63);
   mux_spr_ex2_rt                   : in  std_ulogic_vector(64-regsize to 63);
   ex5_spr_wd                       : out std_ulogic_vector(64-regsize to 64+8-(64/regsize));
   
   -- SPRT Interface
   cspr_tspr_ex2_tid                : out std_ulogic_vector(0 to threads-1);             
   cspr_tspr_ex1_instr              : out std_ulogic_vector(0 to 31);             
   cspr_tspr_ex5_is_mtmsr           : out std_ulogic;
   cspr_tspr_ex5_is_mtspr           : out std_ulogic;
   cspr_tspr_ex5_is_wrtee           : out std_ulogic;
   cspr_tspr_ex5_is_wrteei          : out std_ulogic;
   cspr_tspr_ex5_instr              : out std_ulogic_vector(11 to 20);
   cspr_tspr_dec_dbg_dis            : out std_ulogic_vector(0 to threads-1);

   -- Illegal SPR
   tspr_cspr_illeg_mtspr_b          : in  std_ulogic_vector(0 to threads-1);
   tspr_cspr_illeg_mfspr_b          : in  std_ulogic_vector(0 to threads-1);
   tspr_cspr_hypv_mtspr             : in  std_ulogic_vector(0 to threads-1);
   tspr_cspr_hypv_mfspr             : in  std_ulogic_vector(0 to threads-1);
   
   -- Array SPRs
   cspr_aspr_ex5_we                 : out std_ulogic;
   cspr_aspr_ex5_waddr              : out std_ulogic_vector(0 to 5);
   cspr_aspr_rf1_re                 : out std_ulogic;
   cspr_aspr_rf1_raddr              : out std_ulogic_vector(0 to 5);
   aspr_cspr_ex1_rdata              : in  std_ulogic_vector(64-regsize to 72-(64/regsize));

   -- Slow SPR Bus
   xu_lsu_slowspr_val               : out std_ulogic;
   xu_lsu_slowspr_rw                : out std_ulogic;
   xu_lsu_slowspr_etid              : out std_ulogic_vector(0 to 1);
   xu_lsu_slowspr_addr              : out std_ulogic_vector(11 to 20);
   xu_lsu_slowspr_data              : out std_ulogic_vector(64-regsize to 63);

   -- DCR Bus
   ac_an_dcr_act                    : out std_ulogic;
   ac_an_dcr_val                    : out std_ulogic;
   ac_an_dcr_read                   : out std_ulogic;
   ac_an_dcr_user                   : out std_ulogic;
   ac_an_dcr_etid                   : out std_ulogic_vector(0 to 1);
   ac_an_dcr_addr                   : out std_ulogic_vector(11 to 20);
   ac_an_dcr_data                   : out std_ulogic_vector(64-regsize to 63);

   -- Flush
   xu_ex4_flush                     : in  std_ulogic_vector(0 to threads-1);
   xu_ex5_flush                     : in  std_ulogic_vector(0 to threads-1);
   
   -- Trap
   spr_cpl_ex3_spr_hypv             : out std_ulogic;
   spr_cpl_ex3_spr_illeg            : out std_ulogic;
   spr_cpl_ex3_spr_priv             : out std_ulogic;
     
   cspr_tspr_timebase_taps          : out std_ulogic_vector(0 to 9);
   timer_update                     : out std_ulogic;

   -- Run State
   cpl_spr_stop                     : in  std_ulogic_vector(0 to threads-1);
   xu_iu_run_thread                 : out std_ulogic_vector(0 to threads-1);
   spr_cpl_ex2_run_ctl_flush        : out std_ulogic_vector(0 to threads-1);
   xu_pc_spr_ccr0_we                : out std_ulogic_vector(0 to threads-1);

   -- Quiesce
   iu_xu_quiesce                    : in std_ulogic_vector(0 to threads-1);
   lsu_xu_quiesce                   : in std_ulogic_vector(0 to threads-1);
   mm_xu_quiesce                    : in std_ulogic_vector(0 to threads-1);
   bx_xu_quiesce                    : in std_ulogic_vector(0 to threads-1);
   cpl_spr_quiesce                  : in std_ulogic_vector(0 to threads-1);
   xu_pc_running                    : out std_ulogic_vector(0 to threads-1);
   spr_cpl_quiesce                  : out std_ulogic_vector(0 to threads-1);

   -- PCCR0
   pc_xu_extirpts_dis_on_stop       : in std_ulogic;
   pc_xu_timebase_dis_on_stop       : in std_ulogic;
   pc_xu_decrem_dis_on_stop         : in std_ulogic;

   -- MSR Override
   pc_xu_ram_mode                   : in  std_ulogic;
   pc_xu_ram_thread                 : in  std_ulogic_vector(0 to 1);
   pc_xu_msrovride_enab             : in  std_ulogic;
   cspr_tspr_msrovride_en           : out std_ulogic_vector(0 to threads-1);
   cspr_tspr_ram_mode               : out std_ulogic_vector(0 to threads-1);

   -- LiveLock
   cspr_tspr_llen                   : out std_ulogic_vector(0 to threads-1);
   cspr_tspr_llpri                  : out std_ulogic_vector(0 to threads-1);
   tspr_cspr_lldet                  : in  std_ulogic_vector(0 to threads-1);
   tspr_cspr_llpulse                : in  std_ulogic_vector(0 to threads-1);        

   -- Reset
   pc_xu_reset_wd_complete          : in  std_ulogic;
   pc_xu_reset_3_complete           : in  std_ulogic;
   pc_xu_reset_2_complete           : in  std_ulogic;
   pc_xu_reset_1_complete           : in  std_ulogic;
   reset_wd_complete                : out std_ulogic;
   reset_3_complete                 : out std_ulogic;
   reset_2_complete                 : out std_ulogic;
   reset_1_complete                 : out std_ulogic;

   -- Async Interrupt Masking
   cspr_tspr_crit_mask              : out std_ulogic_vector(0 to threads-1);
   cspr_tspr_ext_mask               : out std_ulogic_vector(0 to threads-1);
   cspr_tspr_dec_mask               : out std_ulogic_vector(0 to threads-1);
   cspr_tspr_fit_mask               : out std_ulogic_vector(0 to threads-1);
   cspr_tspr_wdog_mask              : out std_ulogic_vector(0 to threads-1);
   cspr_tspr_udec_mask              : out std_ulogic_vector(0 to threads-1);
   cspr_tspr_perf_mask              : out std_ulogic_vector(0 to threads-1);

   tspr_cspr_pm_wake_up             : in  std_ulogic_vector(0 to threads-1);

   -- More Async Interrupts
   spr_cpl_dbell_interrupt          : out std_ulogic_vector(0 to threads-1);
   spr_cpl_cdbell_interrupt         : out std_ulogic_vector(0 to threads-1);
   spr_cpl_gdbell_interrupt         : out std_ulogic_vector(0 to threads-1);
   spr_cpl_gcdbell_interrupt        : out std_ulogic_vector(0 to threads-1);
   spr_cpl_gmcdbell_interrupt       : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_dbell_taken          : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_cdbell_taken         : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gdbell_taken         : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gcdbell_taken        : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gmcdbell_taken       : in  std_ulogic_vector(0 to threads-1);

   -- DBELL Int
   lsu_xu_dbell_val                 : in  std_ulogic;
   lsu_xu_dbell_type                : in  std_ulogic_vector(0 to 4);
   lsu_xu_dbell_brdcast             : in  std_ulogic;
   lsu_xu_dbell_lpid_match          : in  std_ulogic;
   lsu_xu_dbell_pirtag              : in  std_ulogic_vector(50 to 63);
   cspr_tspr_dbell_pirtag           : out std_ulogic_vector(50 to 63);
   tspr_cspr_gpir_match             : in  std_ulogic_vector(0 to threads-1);

   -- Parity
   xu_pc_err_sprg_ecc               : out std_ulogic_vector(0 to threads-1);
   spr_cpl_ex3_sprg_ce              : out std_ulogic;
   spr_cpl_ex3_sprg_ue              : out std_ulogic;
   pc_xu_inj_sprg_ecc               : in  std_ulogic_vector(0 to threads-1);
   
   -- Debug
   tspr_cspr_freeze_timers          : in  std_ulogic_vector(0 to threads-1);
   tspr_cspr_async_int              : in  std_ulogic_vector(0 to 3*threads-1);


   -- Perf
   spr_perf_tx_events               : out std_ulogic_vector(0 to 8*threads-1);
   
   xu_lsu_mtspr_trace_en            : out std_ulogic_vector(0 to threads-1);

   lsu_xu_spr_xucr0_cslc_xuop       : in  std_ulogic;
   lsu_xu_spr_xucr0_cslc_binv       : in  std_ulogic;
   lsu_xu_spr_xucr0_clo             : in  std_ulogic;
   lsu_xu_spr_xucr0_cul             : in  std_ulogic;
   tspr_msr_ee                      : in  std_ulogic_vector(0 to threads-1);
   tspr_msr_ce                      : in  std_ulogic_vector(0 to threads-1);
   tspr_msr_me                      : in  std_ulogic_vector(0 to threads-1);
   tspr_msr_gs                      : in  std_ulogic_vector(0 to threads-1);
   tspr_msr_pr                      : in  std_ulogic_vector(0 to threads-1);
   cspr_xucr0_clkg_ctl              : out std_ulogic_vector(0 to 4);
   xu_lsu_spr_xucr0_clfc            : out std_ulogic;
   spr_bit_act                      : out std_ulogic;
	xu_pc_spr_ccr0_pme               : out std_ulogic_vector(0 to 1);
	spr_ccr2_en_dcr                  : out std_ulogic;
	spr_ccr2_en_pc                   : out std_ulogic;
	xu_iu_spr_ccr2_ifratsc           : out std_ulogic_vector(0 to 8);
	xu_iu_spr_ccr2_ifrat             : out std_ulogic;
	xu_lsu_spr_ccr2_dfratsc          : out std_ulogic_vector(0 to 8);
	xu_lsu_spr_ccr2_dfrat            : out std_ulogic;
	spr_ccr2_ucode_dis               : out std_ulogic;
	spr_ccr2_ap                      : out std_ulogic_vector(0 to 3);
	spr_ccr2_en_attn                 : out std_ulogic;
	spr_ccr2_en_ditc                 : out std_ulogic;
	spr_ccr2_en_icswx                : out std_ulogic;
	spr_ccr2_notlb                   : out std_ulogic;
	xu_lsu_spr_xucr0_mbar_ack        : out std_ulogic;
	xu_lsu_spr_xucr0_tlbsync         : out std_ulogic;
	spr_dec_spr_xucr0_ssdly          : out std_ulogic_vector(0 to 4);
	spr_xucr0_cls                    : out std_ulogic;
	xu_lsu_spr_xucr0_aflsta          : out std_ulogic;
	spr_xucr0_mddp                   : out std_ulogic;
	xu_lsu_spr_xucr0_cred            : out std_ulogic;
	xu_lsu_spr_xucr0_rel             : out std_ulogic;
	spr_xucr0_mdcp                   : out std_ulogic;
	xu_lsu_spr_xucr0_flsta           : out std_ulogic;
	xu_lsu_spr_xucr0_l2siw           : out std_ulogic;
	xu_lsu_spr_xucr0_flh2l2          : out std_ulogic;
	xu_lsu_spr_xucr0_dcdis           : out std_ulogic;
	xu_lsu_spr_xucr0_wlk             : out std_ulogic;

   cspr_debug0                      : out std_ulogic_vector(0 to 39);
   cspr_debug1                      : out std_ulogic_vector(0 to 87);

   -- Power
   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_spr_cspr;
architecture xuq_spr_cspr of xuq_spr_cspr is

-- Constants
constant DRF1                          : natural := 0;
constant DEX1                          : natural := 0;
constant DEX2                          : natural := 0;
constant DEX3                          : natural := 0;
constant DEX4                          : natural := 0;
constant DEX5                          : natural := 0;
constant DEX6                          : natural := 0;
constant DWR                           : natural := 0;
constant DX                            : natural := 0;
constant a2hvmode                      : natural := ((a2mode+hvmode) mod 1);
-- Types
subtype TID                           is std_ulogic_vector(0 to threads-1);
subtype DO                            is std_ulogic_vector(65-regsize to 64);
-- SPR Registers
signal ccr0_d         , ccr0_q         : std_ulogic_vector(58 to 63);
signal ccr1_d         , ccr1_q         : std_ulogic_vector(40 to 63);
signal ccr2_d         , ccr2_q         : std_ulogic_vector(32 to 63);
signal tbl_d          , tbl_q          : std_ulogic_vector(32 to 63);
signal tbu_d          , tbu_q          : std_ulogic_vector(32 to 63);
signal tens_d         , tens_q         : std_ulogic_vector(60 to 63);
signal xucr0_d        , xucr0_q        : std_ulogic_vector(33 to 63);
-- FUNC Scanchain
constant ccr1_offset                   : natural := 0;
constant tbl_offset                    : natural := ccr1_offset     + ccr1_q'length;
constant tbu_offset                    : natural := tbl_offset      + tbl_q'length;
constant last_reg_offset               : natural := tbu_offset      + tbu_q'length;
-- BCFG Scanchain
constant ccr0_offset_bcfg              : natural := 0;
constant tens_offset_bcfg              : natural := ccr0_offset_bcfg + ccr0_q'length;
constant last_reg_offset_bcfg          : natural := tens_offset_bcfg + tens_q'length;
-- CCFG Scanchain
constant ccr2_offset_ccfg              : natural := 0;
constant xucr0_offset_ccfg             : natural := ccr2_offset_ccfg + ccr2_q'length;
constant last_reg_offset_ccfg          : natural := xucr0_offset_ccfg + xucr0_q'length;
-- DCFG Scanchain
constant last_reg_offset_dcfg          : natural := 1;
-- Latches
signal exx_act_q,                 exx_act_d                   : std_ulogic_vector(0 to 5);                -- input=>exx_act_d                  , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal rf1_instr_q                                            : std_ulogic_vector(0 to 31);               -- input=>dec_spr_rf0_instr          , act=>rf0_act        , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal rf1_aspr_act_q,            rf1_aspr_act_d              : std_ulogic;                               -- input=>rf1_aspr_act_d             , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal rf1_aspr_tid_q,            rf1_aspr_tid_d              : std_ulogic_vector(0 to 1);                -- input=>rf1_aspr_tid_d             , act=>rf0_act        , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal rf1_msr_gs_q,              rf1_msr_gs_d                : std_ulogic;                               -- input=>rf1_msr_gs_d               , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal ex1_tid_q,                 rf1_tid                     : std_ulogic_vector(0 to 1);                -- input=>rf1_tid                    , act=>exx_act(0)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex1_is_mfspr_q,            rf1_is_mfspr                : std_ulogic;                               -- input=>rf1_is_mfspr               , act=>exx_act(0)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex1_is_mtspr_q,            rf1_is_mtspr                : std_ulogic;                               -- input=>rf1_is_mtspr               , act=>exx_act(0)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex1_instr_q                                            : std_ulogic_vector(0 to 31);               -- input=>rf1_instr_q                , act=>exx_act(0)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex1_aspr_re_q,             rf1_aspr_re                 : std_ulogic_vector(2-regsize/32 to 1);     -- input=>rf1_aspr_re                , act=>exx_act(0)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex1_aspr_ce_addr_q,        rf1_aspr_addr               : std_ulogic_vector(0 to 3);                -- input=>rf1_aspr_addr              , act=>exx_act(0)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_tid_q                                              : std_ulogic_vector(0 to 1);                -- input=>ex1_tid_q                  , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_mfmsr_q,            ex1_is_mfmsr                : std_ulogic;                               -- input=>ex1_is_mfmsr               , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_mfspr_q                                         : std_ulogic;                               -- input=>ex1_is_mfspr_q             , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_mftb_q,             ex1_is_mftb                 : std_ulogic;                               -- input=>ex1_is_mftb                , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_mtmsr_q,            ex1_is_mtmsr                : std_ulogic;                               -- input=>ex1_is_mtmsr               , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_mtspr_q                                         : std_ulogic;                               -- input=>ex1_is_mtspr_q             , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_wait_q,             ex1_is_wait                 : std_ulogic;                               -- input=>ex1_is_wait                , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_wait_wc_q                                          : std_ulogic_vector(9 to 10);               -- input=>ex1_instr_q(9 to 10)       , act=>exx_act_data(1), scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_msgclr_q,           ex1_is_msgclr               : std_ulogic;                               -- input=>ex1_is_msgclr              , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_instr_q,               ex2_instr_d                 : std_ulogic_vector(11 to 20);              -- input=>ex2_instr_d                , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_rs0_q                                              : std_ulogic_vector(52 to 63);              -- input=>fxu_spr_ex1_rs0            , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_msr_gs_q,              ex2_msr_gs_d                : std_ulogic_vector(0 to 0);                -- input=>ex2_msr_gs_d               , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_tenc_we_q,             ex1_tenc_we                 : std_ulogic;                               -- input=>ex1_tenc_we                , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_ccr0_we_q,             ex1_ccr0_we                 : std_ulogic;                               -- input=>ex1_ccr0_we                , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_aspr_rdata_q,          ex2_aspr_rdata_d            : std_ulogic_vector(aspr_cspr_ex1_rdata'range);-- input=>ex2_aspr_rdata_d        , act=>exx_act_data(1), scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_dcrn_q                                             : std_ulogic_vector(54 to 63);              -- input=>fxu_spr_ex1_rs1            , act=>exx_act_data(1), scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_dcr_val_q,             ex1_dcr_val                 : std_ulogic;                               -- input=>ex1_dcr_val                , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_aspr_ce_addr_q                                     : std_ulogic_vector(0 to 3);                -- input=>ex1_aspr_ce_addr_q         , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_aspr_re_q                                          : std_ulogic_vector(2-regsize/32 to 1);     -- input=>ex1_aspr_re_q              , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_dcr_read_q,            ex1_dcr_read                : std_ulogic;                               -- input=>ex1_dcr_read               , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_dcr_user_q,            ex1_dcr_user                : std_ulogic;                               -- input=>ex1_dcr_user               , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_wrtee_q,            ex1_is_wrtee                : std_ulogic;                               -- input=>ex1_is_wrtee               , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_is_wrteei_q,           ex1_is_wrteei               : std_ulogic;                               -- input=>ex1_is_wrteei              , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_tid_q                                              : std_ulogic_vector(0 to 1);                -- input=>ex2_tid_q                  , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_is_mtmsr_q                                         : std_ulogic;                               -- input=>ex2_is_mtmsr_q             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_is_mtspr_q                                         : std_ulogic;                               -- input=>ex2_is_mtspr_q             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_wait_wc_q                                          : std_ulogic_vector(9 to 10);               -- input=>ex2_wait_wc_q              , act=>exx_act_data(2), scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_is_msgclr_q                                        : std_ulogic;                               -- input=>ex2_is_msgclr_q            , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_instr_q,               ex3_instr_d                 : std_ulogic_vector(11 to 20);              -- input=>ex3_instr_d                , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_cspr_rt_q,             ex2_cspr_rt                 : std_ulogic_vector(64-regsize to 63);      -- input=>ex2_cspr_rt                , act=>exx_act_data(2), scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_hypv_spr_q,            ex3_hypv_spr_d              : std_ulogic;                               -- input=>ex3_hypv_spr_d             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_illeg_spr_q,           ex3_illeg_spr_d             : std_ulogic;                               -- input=>ex3_illeg_spr_d            , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_priv_spr_q,            ex3_priv_spr_d              : std_ulogic;                               -- input=>ex3_priv_spr_d             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_sspr_val_q,            ex2_sspr_val                : std_ulogic;                               -- input=>ex2_sspr_val               , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_rt_q                                               : std_ulogic_vector(64-regsize to 63);      -- input=>mux_spr_ex2_rt             , act=>exx_act_data(2), scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_is_mfspr_q                                         : std_ulogic;                               -- input=>ex2_is_mfspr_q             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_wait_q,                ex2_wait                    : std_ulogic;                               -- input=>ex2_wait                   , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_corr_rdata_q,          ex2_corr_rdata              : std_ulogic_vector(64-regsize to 63);      -- input=>ex2_corr_rdata             , act=>exx_act_data(2), scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_sprg_ce_q,             ex2_sprg_ce                 : std_ulogic;                               -- input=>ex2_sprg_ce                , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_sprg_ue_q,             ex2_sprg_ue                 : std_ulogic;                               -- input=>ex2_sprg_ue                , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_aspr_ce_addr_q                                     : std_ulogic_vector(0 to 3);                -- input=>ex2_aspr_ce_addr_q         , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_dcr_read_q                                         : std_ulogic;                               -- input=>ex2_dcr_read_q             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_aspr_re_q                                          : std_ulogic_vector(2-regsize/32 to 1);     -- input=>ex2_aspr_re_q              , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_dcr_val_q                                          : std_ulogic;                               -- input=>ex2_dcr_val_q              , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_dcr_user_q                                         : std_ulogic;                               -- input=>ex2_dcr_user_q             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_is_wrtee_q                                         : std_ulogic;                               -- input=>ex2_is_wrtee_q             , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_is_wrteei_q                                        : std_ulogic;                               -- input=>ex2_is_wrteei_q            , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_msr_gs_q,              ex3_msr_gs_d                : std_ulogic;                               -- input=>ex3_msr_gs_d               , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_tid_q                                              : std_ulogic_vector(0 to 1);                -- input=>ex3_tid_q                  , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_is_mtmsr_q                                         : std_ulogic;                               -- input=>ex3_is_mtmsr_q             , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_is_mtspr_q                                         : std_ulogic;                               -- input=>ex3_is_mtspr_q             , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_wait_wc_q                                          : std_ulogic_vector(9 to 10);               -- input=>ex3_wait_wc_q              , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_is_msgclr_q                                        : std_ulogic;                               -- input=>ex3_is_msgclr_q            , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_instr_q                                            : std_ulogic_vector(11 to 20);              -- input=>ex3_instr_q                , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_sspr_val_q                                         : std_ulogic;                               -- input=>ex3_sspr_val_q             , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_rt_q                                               : std_ulogic_vector(64-regsize to 63);      -- input=>ex3_rt_q                   , act=>exx_act_data(3), scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_is_mfspr_q                                         : std_ulogic;                               -- input=>ex3_is_mfspr_q             , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_dcr_read_q                                         : std_ulogic;                               -- input=>ex3_dcr_read_q             , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_wait_q                                             : std_ulogic;                               -- input=>ex3_wait_q                 , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_corr_rdata_q                                       : std_ulogic_vector(64-regsize to 63);      -- input=>ex3_corr_rdata_q           , act=>exx_act_data(3), scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_sprg_ce_q,             ex4_sprg_ce_d               : std_ulogic_vector(0 to regsize/8);        -- input=>ex4_sprg_ce_d              , act=>exx_act_data(3), scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_aspr_ce_addr_q                                     : std_ulogic_vector(0 to 3);                -- input=>ex3_aspr_ce_addr_q         , act=>ex3_sprg_ce    , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_dcr_val_q                                          : std_ulogic;                               -- input=>ex3_dcr_val_q              , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_dcr_user_q                                         : std_ulogic;                               -- input=>ex3_dcr_user_q             , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_is_wrtee_q                                         : std_ulogic;                               -- input=>ex3_is_wrtee_q             , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_is_wrteei_q                                        : std_ulogic;                               -- input=>ex3_is_wrteei_q            , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_aspr_we_q,             ex3_aspr_we                 : std_ulogic;                               -- input=>ex3_aspr_we                , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_aspr_addr_q,           ex3_aspr_addr               : std_ulogic_vector(0 to 3);                -- input=>ex3_aspr_addr              , act=>exx_act(3)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_val_q,                 ex5_val_d                   : std_ulogic_vector(0 to threads-1);        -- input=>ex5_val_d                  , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal ex5_tid_q                                              : std_ulogic_vector(0 to 1);                -- input=>ex4_tid_q                  , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_is_mtmsr_q                                         : std_ulogic;                               -- input=>ex4_is_mtmsr_q             , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_is_mtspr_q                                         : std_ulogic;                               -- input=>ex4_is_mtspr_q             , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_wait_wc_q                                          : std_ulogic_vector(9 to 10);               -- input=>ex4_wait_wc_q              , act=>exx_act_data(4), scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_is_msgclr_q                                        : std_ulogic;                               -- input=>ex4_is_msgclr_q            , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_instr_q                                            : std_ulogic_vector(11 to 20);              -- input=>ex4_instr_q                , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_sspr_val_q                                         : std_ulogic;                               -- input=>ex4_sspr_val_q             , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_aspr_we_q,             ex5_aspr_we_d               : std_ulogic_vector(0 to threads-1);        -- input=>ex5_aspr_we_d              , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_rt_q,                  ex5_rt_d                    : std_ulogic_vector(64-regsize to 64+8-(64/regsize));-- input=>ex5_rt_d          , act=>exx_act_data(4), scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_rt_q_b : std_ulogic_vector(64-regsize to 64+8-(64/regsize));
signal ex5_wait_q                                             : std_ulogic;                               -- input=>ex4_wait_q                 , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_sprg_ce_q                                          : std_ulogic;                               -- input=>ex4_sprg_ce_q(0)           , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_dcr_val_q,             ex4_dcr_val                 : std_ulogic;                               -- input=>ex4_dcr_val                , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_dcr_read_q                                         : std_ulogic;                               -- input=>ex4_dcr_read_q             , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_dcr_user_q                                         : std_ulogic;                               -- input=>ex4_dcr_user_q             , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_aspr_addr_q,           ex5_aspr_addr_d             : std_ulogic_vector(0 to 3);                -- input=>ex5_aspr_addr_d            , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_is_wrtee_q                                         : std_ulogic;                               -- input=>ex4_is_wrtee_q             , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_is_wrteei_q                                        : std_ulogic;                               -- input=>ex4_is_wrteei_q            , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_valid_q,               ex5_valid                   : std_ulogic_vector(0 to threads-1);        -- input=>ex5_valid                  , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_val_q,                 ex5_val                     : std_ulogic;                               -- input=>ex5_val                    , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal ex6_tid_q                                              : std_ulogic_vector(0 to 1);                -- input=>ex5_tid_q                  , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_dbell_taken_q                                      : std_ulogic_vector(0 to threads-1);        -- input=>cpl_spr_ex5_dbell_taken    , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_cdbell_taken_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>cpl_spr_ex5_cdbell_taken   , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_gdbell_taken_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>cpl_spr_ex5_gdbell_taken   , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_gcdbell_taken_q                                    : std_ulogic_vector(0 to threads-1);        -- input=>cpl_spr_ex5_gcdbell_taken  , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_gmcdbell_taken_q                                   : std_ulogic_vector(0 to threads-1);        -- input=>cpl_spr_ex5_gmcdbell_taken , act=>tiup           , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_rt_q                                               : std_ulogic_vector(64-regsize to 63);      -- input=>ex5_rt_q(64-regsize to 63) , act=>exx_act_data(5), scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_instr_q                                            : std_ulogic_vector(11 to 20);              -- input=>ex5_instr_q                , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_is_mtspr_q                                         : std_ulogic;                               -- input=>ex5_is_mtspr_q             , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_wait_wc_q                                          : std_ulogic_vector(9 to 10);               -- input=>ex5_wait_wc_q              , act=>exx_act_data(5), scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_is_msgclr_q                                        : std_ulogic;                               -- input=>ex5_is_msgclr_q            , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_sspr_val_q                                         : std_ulogic;                               -- input=>ex5_sspr_val_q             , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_set_xucr0_cslc_q,      ex6_set_xucr0_cslc_d        : std_ulogic;                               -- input=>ex6_set_xucr0_cslc_d       , act=>tiup           , scan=>N, sleep=>Y, ring=>func, needs_sreset=>0
signal ex6_set_xucr0_cul_q,       ex6_set_xucr0_cul_d         : std_ulogic;                               -- input=>ex6_set_xucr0_cul_d        , act=>tiup           , scan=>N, sleep=>Y, ring=>func, needs_sreset=>0
signal ex6_set_xucr0_clo_q,       ex6_set_xucr0_clo_d         : std_ulogic;                               -- input=>ex6_set_xucr0_clo_d        , act=>tiup           , scan=>N, sleep=>Y, ring=>func, needs_sreset=>0
signal ex6_wait_q                                             : std_ulogic;                               -- input=>ex5_wait_q                 , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_sprg_ce_q,             ex5_sprg_ce                 : std_ulogic_vector(0 to threads-1);        -- input=>ex5_sprg_ce                , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_dcr_val_q,             ex5_dcr_val                 : std_ulogic;                               -- input=>ex5_dcr_val                , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_dcr_read_q                                         : std_ulogic;                               -- input=>ex5_dcr_read_q             , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex6_dcr_user_q                                         : std_ulogic;                               -- input=>ex5_dcr_user_q             , act=>exx_act(5)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_any_mfspr_q,           ex2_any_mfspr_d             : std_ulogic;                               -- input=>ex2_any_mfspr_d            , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex2_any_mtspr_q,           ex2_any_mtspr_d             : std_ulogic;                               -- input=>ex2_any_mtspr_d            , act=>exx_act(1)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_any_mfspr_q                                        : std_ulogic;                               -- input=>ex2_any_mfspr_q            , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_any_mtspr_q                                        : std_ulogic;                               -- input=>ex2_any_mtspr_q            , act=>exx_act(2)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_any_mfspr_q                                        : std_ulogic;                               -- input=>ex3_any_mfspr_q            , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_any_mtspr_q                                        : std_ulogic;                               -- input=>ex3_any_mtspr_q            , act=>exx_act(3)     , scan=>N, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_any_mfspr_q                                        : std_ulogic;                               -- input=>ex4_any_mfspr_q            , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex5_any_mtspr_q                                        : std_ulogic;                               -- input=>ex4_any_mtspr_q            , act=>exx_act(4)     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal running_q,                 running_d                   : std_ulogic_vector(0 to threads-1);        -- input=>running_d                  , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal llpri_q,                   llpri_d                     : std_ulogic_vector(0 to threads-1);        -- input=>llpri_d                    , act=>llpri_inc      , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1, init=>8
signal dec_dbg_dis_q,             dec_dbg_dis_d               : std_ulogic_vector(0 to threads-1);        -- input=>dec_dbg_dis_d              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal tb_dbg_dis_q,              tb_dbg_dis_d                : std_ulogic;                               -- input=>tb_dbg_dis_d               , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal tb_act_q,                  tb_act_d                    : std_ulogic;                               -- input=>tb_act_d                   , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal ext_dbg_dis_q,             ext_dbg_dis_d               : std_ulogic_vector(0 to threads-1);        -- input=>ext_dbg_dis_d              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal ram_mode_q                                             : std_ulogic;                               -- input=>pc_xu_ram_mode             , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal ram_thread_q                                           : std_ulogic_vector(0 to 1);                -- input=>pc_xu_ram_thread           , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal msrovride_enab_q                                       : std_ulogic;                               -- input=>pc_xu_msrovride_enab       , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal waitimpl_val_q,            waitimpl_val_d              : std_ulogic_vector(0 to threads-1);        -- input=>waitimpl_val_d             , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal waitrsv_val_q,             waitrsv_val_d               : std_ulogic_vector(0 to threads-1);        -- input=>waitrsv_val_d              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal an_ac_reservation_vld_q                                : std_ulogic_vector(0 to threads-1);        -- input=>an_ac_reservation_vld      , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal an_ac_sleep_en_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>an_ac_sleep_en             , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal an_ac_coreid_q                                         : std_ulogic_vector(54 to 61);              -- input=>an_ac_coreid               , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal tb_update_enable_q                                     : std_ulogic;                               -- input=>an_ac_tb_update_enable     , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal tb_update_pulse_q                                      : std_ulogic;                               -- input=>an_ac_tb_update_pulse      , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal tb_update_pulse_1_q                                    : std_ulogic;                               -- input=>tb_update_pulse_q          , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal pc_xu_reset_wd_complete_q                              : std_ulogic;                               -- input=>pc_xu_reset_wd_complete    , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal pc_xu_reset_3_complete_q                               : std_ulogic;                               -- input=>pc_xu_reset_3_complete     , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal pc_xu_reset_2_complete_q                               : std_ulogic;                               -- input=>pc_xu_reset_2_complete     , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal pc_xu_reset_1_complete_q                               : std_ulogic;                               -- input=>pc_xu_reset_1_complete     , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal lsu_xu_dbell_val_q                                     : std_ulogic;                               -- input=>lsu_xu_dbell_val           , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal lsu_xu_dbell_type_q                                    : std_ulogic_vector(0 to 4);                -- input=>lsu_xu_dbell_type          , act=>dbell_act      , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal lsu_xu_dbell_brdcast_q                                 : std_ulogic;                               -- input=>lsu_xu_dbell_brdcast       , act=>dbell_act      , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal lsu_xu_dbell_lpid_match_q                              : std_ulogic;                               -- input=>lsu_xu_dbell_lpid_match    , act=>dbell_act      , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal lsu_xu_dbell_pirtag_q                                  : std_ulogic_vector(50 to 63);              -- input=>lsu_xu_dbell_pirtag        , act=>dbell_act      , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal dbell_present_q,           dbell_present_d             : std_ulogic_vector(0 to threads-1);        -- input=>dbell_present_d            , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal cdbell_present_q,          cdbell_present_d            : std_ulogic_vector(0 to threads-1);        -- input=>cdbell_present_d           , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal gdbell_present_q,          gdbell_present_d            : std_ulogic_vector(0 to threads-1);        -- input=>gdbell_present_d           , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal gcdbell_present_q,         gcdbell_present_d           : std_ulogic_vector(0 to threads-1);        -- input=>gcdbell_present_d          , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal gmcdbell_present_q,        gmcdbell_present_d          : std_ulogic_vector(0 to threads-1);        -- input=>gmcdbell_present_d         , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal xucr0_clfc_q,              xucr0_clfc_d                : std_ulogic;                               -- input=>xucr0_clfc_d               , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal iu_run_thread_q,           iu_run_thread_d             : std_ulogic_vector(0 to threads-1);        -- input=>iu_run_thread_d            , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal perf_event_q,              perf_event_d                : std_ulogic_vector(0 to 3*threads-1);      -- input=>perf_event_d               , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal inj_sprg_ecc_q                                         : std_ulogic_vector(0 to threads-1);        -- input=>pc_xu_inj_sprg_ecc         , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal dbell_interrupt_q,         dbell_interrupt             : std_ulogic_vector(0 to threads-1);        -- input=>dbell_interrupt            , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal cdbell_interrupt_q,        cdbell_interrupt            : std_ulogic_vector(0 to threads-1);        -- input=>cdbell_interrupt           , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal gdbell_interrupt_q,        gdbell_interrupt            : std_ulogic_vector(0 to threads-1);        -- input=>gdbell_interrupt           , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal gcdbell_interrupt_q,       gcdbell_interrupt           : std_ulogic_vector(0 to threads-1);        -- input=>gcdbell_interrupt          , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal gmcdbell_interrupt_q,      gmcdbell_interrupt          : std_ulogic_vector(0 to threads-1);        -- input=>gmcdbell_interrupt         , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal iu_quiesce_q                                           : std_ulogic_vector(0 to threads-1);        -- input=>iu_xu_quiesce              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal lsu_quiesce_q                                          : std_ulogic_vector(0 to threads-1);        -- input=>lsu_xu_quiesce             , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal mm_quiesce_q                                           : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_quiesce              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal bx_quiesce_q                                           : std_ulogic_vector(0 to threads-1);        -- input=>bx_xu_quiesce              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal quiesce_q,                 quiesce_d                   : std_ulogic_vector(0 to threads-1);        -- input=>quiesce_d                  , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal cpl_quiesce_q,             cpl_quiesce_d               : std_ulogic_vector(0 to threads-1);        -- input=>cpl_quiesce_d              , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal quiesced_4cpl_q,           quiesced_4cpl_d             : std_ulogic_vector(0 to threads-1);        -- input=>quiesced_4cpl_d            , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal quiesced_q,                quiesced_d                  : std_ulogic_vector(0 to threads-1);        -- input=>quiesced_d                 , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal instr_trace_mode_q                                     : std_ulogic;                               -- input=>pc_xu_instr_trace_mode     , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal instr_trace_tid_q                                      : std_ulogic_vector(0 to 1);                -- input=>pc_xu_instr_trace_tid      , act=>tiup           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal timer_update_q                                         : std_ulogic;                               -- input=>timer_update_int           , act=>tiup           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
signal spare_0_q,                 spare_0_d                   : std_ulogic_vector(0 to 15);               -- input=>spare_0_d,             act=>tiup,
-- Scanchains
constant exx_act_offset                            : integer := last_reg_offset;
constant rf1_instr_offset                          : integer := exx_act_offset                 + exx_act_q'length;
constant rf1_aspr_act_offset                       : integer := rf1_instr_offset               + rf1_instr_q'length;
constant rf1_aspr_tid_offset                       : integer := rf1_aspr_act_offset            + 1;
constant rf1_msr_gs_offset                         : integer := rf1_aspr_tid_offset            + rf1_aspr_tid_q'length;
constant ex1_tid_offset                            : integer := rf1_msr_gs_offset              + 1;
constant ex1_is_mfspr_offset                       : integer := ex1_tid_offset                 + ex1_tid_q'length;
constant ex1_is_mtspr_offset                       : integer := ex1_is_mfspr_offset            + 1;
constant ex1_instr_offset                          : integer := ex1_is_mtspr_offset            + 1;
constant ex1_aspr_re_offset                        : integer := ex1_instr_offset               + ex1_instr_q'length;
constant ex1_aspr_ce_addr_offset                   : integer := ex1_aspr_re_offset             + ex1_aspr_re_q'length;
constant ex2_aspr_rdata_offset                     : integer := ex1_aspr_ce_addr_offset        + ex1_aspr_ce_addr_q'length;
constant ex3_tid_offset                            : integer := ex2_aspr_rdata_offset          + ex2_aspr_rdata_q'length;
constant ex3_is_mtmsr_offset                       : integer := ex3_tid_offset                 + ex3_tid_q'length;
constant ex3_is_mtspr_offset                       : integer := ex3_is_mtmsr_offset            + 1;
constant ex3_wait_wc_offset                        : integer := ex3_is_mtspr_offset            + 1;
constant ex3_is_msgclr_offset                      : integer := ex3_wait_wc_offset             + ex3_wait_wc_q'length;
constant ex3_instr_offset                          : integer := ex3_is_msgclr_offset           + 1;
constant ex3_cspr_rt_offset                        : integer := ex3_instr_offset               + ex3_instr_q'length;
constant ex3_hypv_spr_offset                       : integer := ex3_cspr_rt_offset             + ex3_cspr_rt_q'length;
constant ex3_illeg_spr_offset                      : integer := ex3_hypv_spr_offset            + 1;
constant ex3_priv_spr_offset                       : integer := ex3_illeg_spr_offset           + 1;
constant ex3_sspr_val_offset                       : integer := ex3_priv_spr_offset            + 1;
constant ex3_rt_offset                             : integer := ex3_sspr_val_offset            + 1;
constant ex3_is_mfspr_offset                       : integer := ex3_rt_offset                  + ex3_rt_q'length;
constant ex3_wait_offset                           : integer := ex3_is_mfspr_offset            + 1;
constant ex3_corr_rdata_offset                     : integer := ex3_wait_offset                + 1;
constant ex3_sprg_ce_offset                        : integer := ex3_corr_rdata_offset          + ex3_corr_rdata_q'length;
constant ex3_sprg_ue_offset                        : integer := ex3_sprg_ce_offset             + 1;
constant ex3_aspr_ce_addr_offset                   : integer := ex3_sprg_ue_offset             + 1;
constant ex3_dcr_read_offset                       : integer := ex3_aspr_ce_addr_offset        + ex3_aspr_ce_addr_q'length;
constant ex3_aspr_re_offset                        : integer := ex3_dcr_read_offset            + 1;
constant ex3_dcr_val_offset                        : integer := ex3_aspr_re_offset             + ex3_aspr_re_q'length;
constant ex3_dcr_user_offset                       : integer := ex3_dcr_val_offset             + 1;
constant ex3_is_wrtee_offset                       : integer := ex3_dcr_user_offset            + 1;
constant ex3_is_wrteei_offset                      : integer := ex3_is_wrtee_offset            + 1;
constant ex3_msr_gs_offset                         : integer := ex3_is_wrteei_offset           + 1;
constant ex4_aspr_we_offset                        : integer := ex3_msr_gs_offset              + 1;
constant ex4_aspr_addr_offset                      : integer := ex4_aspr_we_offset             + 1;
constant ex5_val_offset                            : integer := ex4_aspr_addr_offset           + ex4_aspr_addr_q'length;
constant ex5_tid_offset                            : integer := ex5_val_offset                 + ex5_val_q'length;
constant ex5_is_mtmsr_offset                       : integer := ex5_tid_offset                 + ex5_tid_q'length;
constant ex5_is_mtspr_offset                       : integer := ex5_is_mtmsr_offset            + 1;
constant ex5_wait_wc_offset                        : integer := ex5_is_mtspr_offset            + 1;
constant ex5_is_msgclr_offset                      : integer := ex5_wait_wc_offset             + ex5_wait_wc_q'length;
constant ex5_instr_offset                          : integer := ex5_is_msgclr_offset           + 1;
constant ex5_sspr_val_offset                       : integer := ex5_instr_offset               + ex5_instr_q'length;
constant ex5_aspr_we_offset                        : integer := ex5_sspr_val_offset            + 1;
constant ex5_rt_offset                             : integer := ex5_aspr_we_offset             + ex5_aspr_we_q'length;
constant ex5_wait_offset                           : integer := ex5_rt_offset                  + ex5_rt_q'length;
constant ex5_sprg_ce_offset                        : integer := ex5_wait_offset                + 1;
constant ex5_dcr_val_offset                        : integer := ex5_sprg_ce_offset             + 1;
constant ex5_dcr_read_offset                       : integer := ex5_dcr_val_offset             + 1;
constant ex5_dcr_user_offset                       : integer := ex5_dcr_read_offset            + 1;
constant ex5_aspr_addr_offset                      : integer := ex5_dcr_user_offset            + 1;
constant ex5_is_wrtee_offset                       : integer := ex5_aspr_addr_offset           + ex5_aspr_addr_q'length;
constant ex5_is_wrteei_offset                      : integer := ex5_is_wrtee_offset            + 1;
constant ex3_any_mfspr_offset                      : integer := ex5_is_wrteei_offset           + 1;
constant ex3_any_mtspr_offset                      : integer := ex3_any_mfspr_offset           + 1;
constant ex5_any_mfspr_offset                      : integer := ex3_any_mtspr_offset           + 1;
constant ex5_any_mtspr_offset                      : integer := ex5_any_mfspr_offset           + 1;
constant ex6_valid_offset                          : integer := ex5_any_mtspr_offset           + 1;
constant ex6_val_offset                            : integer := ex6_valid_offset               + ex6_valid_q'length;
constant running_offset                            : integer := ex6_val_offset                 + 1;
constant llpri_offset                              : integer := running_offset                 + running_q'length;
constant dec_dbg_dis_offset                        : integer := llpri_offset                   + llpri_q'length;
constant tb_dbg_dis_offset                         : integer := dec_dbg_dis_offset             + dec_dbg_dis_q'length;
constant tb_act_offset                             : integer := tb_dbg_dis_offset              + 1;
constant ext_dbg_dis_offset                        : integer := tb_act_offset                  + 1;
constant ram_mode_offset                           : integer := ext_dbg_dis_offset             + ext_dbg_dis_q'length;
constant ram_thread_offset                         : integer := ram_mode_offset                + 1;
constant msrovride_enab_offset                     : integer := ram_thread_offset              + ram_thread_q'length;
constant waitimpl_val_offset                       : integer := msrovride_enab_offset          + 1;
constant waitrsv_val_offset                        : integer := waitimpl_val_offset            + waitimpl_val_q'length;
constant an_ac_reservation_vld_offset              : integer := waitrsv_val_offset             + waitrsv_val_q'length;
constant an_ac_sleep_en_offset                     : integer := an_ac_reservation_vld_offset   + an_ac_reservation_vld_q'length;
constant an_ac_coreid_offset                       : integer := an_ac_sleep_en_offset          + an_ac_sleep_en_q'length;
constant tb_update_enable_offset                   : integer := an_ac_coreid_offset            + an_ac_coreid_q'length;
constant tb_update_pulse_offset                    : integer := tb_update_enable_offset        + 1;
constant tb_update_pulse_1_offset                  : integer := tb_update_pulse_offset         + 1;
constant pc_xu_reset_wd_complete_offset            : integer := tb_update_pulse_1_offset       + 1;
constant pc_xu_reset_3_complete_offset             : integer := pc_xu_reset_wd_complete_offset + 1;
constant pc_xu_reset_2_complete_offset             : integer := pc_xu_reset_3_complete_offset  + 1;
constant pc_xu_reset_1_complete_offset             : integer := pc_xu_reset_2_complete_offset  + 1;
constant lsu_xu_dbell_val_offset                   : integer := pc_xu_reset_1_complete_offset  + 1;
constant lsu_xu_dbell_type_offset                  : integer := lsu_xu_dbell_val_offset        + 1;
constant lsu_xu_dbell_brdcast_offset               : integer := lsu_xu_dbell_type_offset       + lsu_xu_dbell_type_q'length;
constant lsu_xu_dbell_lpid_match_offset            : integer := lsu_xu_dbell_brdcast_offset    + 1;
constant lsu_xu_dbell_pirtag_offset                : integer := lsu_xu_dbell_lpid_match_offset + 1;
constant dbell_present_offset                      : integer := lsu_xu_dbell_pirtag_offset     + lsu_xu_dbell_pirtag_q'length;
constant cdbell_present_offset                     : integer := dbell_present_offset           + dbell_present_q'length;
constant gdbell_present_offset                     : integer := cdbell_present_offset          + cdbell_present_q'length;
constant gcdbell_present_offset                    : integer := gdbell_present_offset          + gdbell_present_q'length;
constant gmcdbell_present_offset                   : integer := gcdbell_present_offset         + gcdbell_present_q'length;
constant xucr0_clfc_offset                         : integer := gmcdbell_present_offset        + gmcdbell_present_q'length;
constant iu_run_thread_offset                      : integer := xucr0_clfc_offset              + 1;
constant perf_event_offset                         : integer := iu_run_thread_offset           + iu_run_thread_q'length;
constant inj_sprg_ecc_offset                       : integer := perf_event_offset              + perf_event_q'length;
constant dbell_interrupt_offset                    : integer := inj_sprg_ecc_offset            + inj_sprg_ecc_q'length;
constant cdbell_interrupt_offset                   : integer := dbell_interrupt_offset         + dbell_interrupt_q'length;
constant gdbell_interrupt_offset                   : integer := cdbell_interrupt_offset        + cdbell_interrupt_q'length;
constant gcdbell_interrupt_offset                  : integer := gdbell_interrupt_offset        + gdbell_interrupt_q'length;
constant gmcdbell_interrupt_offset                 : integer := gcdbell_interrupt_offset       + gcdbell_interrupt_q'length;
constant iu_quiesce_offset                         : integer := gmcdbell_interrupt_offset      + gmcdbell_interrupt_q'length;
constant lsu_quiesce_offset                        : integer := iu_quiesce_offset              + iu_quiesce_q'length;
constant mm_quiesce_offset                         : integer := lsu_quiesce_offset             + lsu_quiesce_q'length;
constant bx_quiesce_offset                         : integer := mm_quiesce_offset              + mm_quiesce_q'length;
constant quiesce_offset                            : integer := bx_quiesce_offset              + bx_quiesce_q'length;
constant cpl_quiesce_offset                        : integer := quiesce_offset                 + quiesce_q'length;
constant quiesced_4cpl_offset                      : integer := cpl_quiesce_offset             + cpl_quiesce_q'length;
constant quiesced_offset                           : integer := quiesced_4cpl_offset           + quiesced_4cpl_q'length;
constant instr_trace_mode_offset                   : integer := quiesced_offset                + quiesced_q'length;
constant instr_trace_tid_offset                    : integer := instr_trace_mode_offset        + 1;
constant timer_update_offset                       : integer := instr_trace_tid_offset         + instr_trace_tid_q'length;
constant spare_0_offset                            : integer := timer_update_offset            + 1;
constant quiesced_ctr_offset                       : integer := spare_0_offset                 + spare_0_q'length;
constant quiesced_4cpl_ctr_offset                  : integer := quiesced_ctr_offset            + 1;
constant scan_right                                : integer := quiesced_4cpl_ctr_offset       + 1;
signal siv                                         : std_ulogic_vector(0 to scan_right-1);
signal sov                                         : std_ulogic_vector(0 to scan_right-1);
constant scan_right_bcfg                           : integer := last_reg_offset_bcfg;
signal siv_bcfg                                    : std_ulogic_vector(0 to scan_right_bcfg-1);
signal sov_bcfg                                    : std_ulogic_vector(0 to scan_right_bcfg-1);
constant scan_right_ccfg                           : integer := last_reg_offset_ccfg;
signal siv_ccfg                                    : std_ulogic_vector(0 to scan_right_ccfg-1);
signal sov_ccfg                                    : std_ulogic_vector(0 to scan_right_ccfg-1);
-- Signals
signal tiup                                        : std_ulogic;
signal tidn                                        : std_ulogic_vector(00 to 61);
signal spare_0_lclk                                : clk_logic;
signal spare_0_d1clk, spare_0_d2clk                : std_ulogic;
signal tb                                          : std_ulogic_vector(00 to 63);
signal rf1_opcode_is_31, ex1_opcode_is_31          : boolean;
signal rf1_instr                                   : std_ulogic_vector(11 to 20);
signal ex1_tid                                     : std_ulogic_vector(0 to threads-1);
signal ex1_is_mtdcr, ex1_is_mtdcrux, ex1_is_mtdcrx : std_ulogic;
signal ex1_is_mfdcr, ex1_is_mfdcrux, ex1_is_mfdcrx : std_ulogic;
signal ex1_is_mfcr,  ex1_is_mtcrf                  : std_ulogic;
signal ex1_dcr_instr                               : std_ulogic;
signal ex2_tid                                     : std_ulogic_vector(0 to threads-1);
signal ex2_illeg_mfspr                             : std_ulogic;
signal ex2_illeg_mtspr                             : std_ulogic;
signal ex2_illeg_mftb                              : std_ulogic;
signal ex2_hypv_mfspr                              : std_ulogic;
signal ex2_hypv_mtspr                              : std_ulogic;
signal ex2_instr                                   : std_ulogic_vector(11 to 20);
signal ex2_slowspr_range_priv                      : std_ulogic;
signal ex2_slowspr_range_hypv                      : std_ulogic;
signal ex2_slowspr_range                           : std_ulogic;
signal ex2_wait_flush                              : std_ulogic_vector(0 to threads-1);
signal ex2_ccr0_flush                              : std_ulogic_vector(0 to threads-1);
signal ex2_tenc_flush                              : std_ulogic_vector(0 to threads-1);
signal ex3_tspr_rt                                 : std_ulogic_vector(64-regsize to 63);
signal ex4_rt, ex4_rt_inj                          : std_ulogic_vector(64-regsize to 63);
signal ex4_tid                                     : std_ulogic_vector(0 to threads-1);
signal ex5_tid                                     : std_ulogic_vector(0 to threads-1);
signal ex3_instr                                   : std_ulogic_vector(11 to 20);
signal llunmasked,llmasked                         : std_ulogic;
signal llpulse,llpres,llpri_inc                    : std_ulogic;
signal llmask                                      : std_ulogic_vector(0 to threads-1);
signal ram_tid                                     : std_ulogic_vector(0 to threads-1);
signal pm_wake_up                                  : std_ulogic_vector(0 to threads-1);
signal ccr0_di, ccr0_wen                           : std_ulogic_vector(ccr0_q'range);
signal dbell_pir_match                             : std_ulogic;
signal dbell_pir_thread                            : std_ulogic_vector(0 to threads-1);
signal spr_ccr0_we_rev, spr_tens_ten_rev           : std_ulogic_vector(0 to threads-1);
signal set_dbell,          clr_dbell               : std_ulogic_vector(0 to threads-1);
signal set_cdbell,         clr_cdbell              : std_ulogic_vector(0 to threads-1);
signal set_gdbell,         clr_gdbell              : std_ulogic_vector(0 to threads-1);
signal set_gcdbell,        clr_gcdbell             : std_ulogic_vector(0 to threads-1);
signal set_gmcdbell,       clr_gmcdbell            : std_ulogic_vector(0 to threads-1);
signal tb_update_pulse                             : std_ulogic;
signal spr_tensr                                   : std_ulogic_vector(0 to threads-1);
signal ex6_instr                                   : std_ulogic_vector(11 to 20);
signal ex6_is_mtspr                                : std_ulogic;
signal ex6_val                                     : std_ulogic;
signal ex6_tid                                     : std_ulogic_vector(0 to threads-1);
signal tb_q                                        : std_ulogic_vector(0 to 63);
signal crit_mask, base_mask, dec_mask, fit_mask    : std_ulogic_vector(0 to threads-1);
signal ex6_wait                                    : std_ulogic_vector(0 to threads-1);
signal ex6_any_valid                               : std_ulogic;
signal ex5_flush                                   : std_ulogic;
signal xucr0_di                                    : std_ulogic_vector(xucr0_q'range);
signal ex4_eccgen_data                             : std_ulogic_vector(64-regsize to 72-(64/regsize));
signal ex4_eccgen_syn                              : std_ulogic_vector(64 to 72-(64/regsize));
signal ex2_eccchk_syn,     ex2_eccchk_syn_b        : std_ulogic_vector(64 to 72-(64/regsize));
signal ram_mode                                    : std_ulogic_vector(0 to threads-1);
signal ex4_is_mfsspr_b                             : std_ulogic;
signal encorr                                      : std_ulogic;
signal ex3_sprg_ce                                 : std_ulogic;
signal ex3_aspr_rt                                 : std_ulogic_vector(64-regsize to 63);
signal ex6_spr_wd                                  : std_ulogic_vector(64-regsize to 63);
signal quiesce_ctr_zero_b, cpl_quiesce_ctr_zero_b  : std_ulogic_vector(0 to threads-1);
signal quiesce_b_q,      cpl_quiesce_b_q           : std_ulogic_vector(0 to threads-1);
signal running                                     : std_ulogic_vector(0 to threads-1);
signal timer_update_int                            : std_ulogic;
signal exx_act                                     : std_ulogic_vector(0 to 5);
signal exx_act_data                                : std_ulogic_vector(1 to 5);
signal rf0_act                                     : std_ulogic;
signal ex4_inj_ecc                                 : std_ulogic;
signal version                                     : std_ulogic_vector(32 to 47);
signal revision                                    : std_ulogic_vector(48 to 63);
signal revision_minor                              : std_ulogic_vector(0 to 3);
signal instr_trace_tid                             : std_ulogic_vector(0 to threads-1);
signal ex3_sprg_ue                                 : std_ulogic;
signal dbell_act                                   : std_ulogic;

-- Data
signal spr_ccr0_we                     : std_ulogic_vector(0 to 3);
signal spr_ccr2_en_dcr_int             : std_ulogic;
signal spr_ccr2_en_trace               : std_ulogic;
signal spr_tens_ten                    : std_ulogic_vector(0 to 3);
signal spr_xucr0_clkg_ctl              : std_ulogic_vector(0 to 4);
signal spr_xucr0_trace_um              : std_ulogic_vector(0 to 3);
signal spr_xucr0_tcs                   : std_ulogic;
signal ex6_ccr0_di                     : std_ulogic_vector(ccr0_q'range);
signal ex6_ccr1_di                     : std_ulogic_vector(ccr1_q'range);
signal ex6_ccr2_di                     : std_ulogic_vector(ccr2_q'range);
signal ex6_tbl_di                      : std_ulogic_vector(tbl_q'range);
signal ex6_tbu_di                      : std_ulogic_vector(tbu_q'range);
signal ex6_tens_di                     : std_ulogic_vector(tens_q'range);
signal ex6_xucr0_di                    : std_ulogic_vector(xucr0_q'range);
signal
	rf1_gsprg0_re  , rf1_gsprg1_re  , rf1_gsprg2_re  , rf1_gsprg3_re  
 , rf1_sprg0_re   , rf1_sprg1_re   , rf1_sprg2_re   , rf1_sprg3_re   
 , rf1_sprg4_re   , rf1_sprg5_re   , rf1_sprg6_re   , rf1_sprg7_re   
 , rf1_sprg8_re   , rf1_vrsave_re  
													: std_ulogic;
signal
	rf1_gsprg0_rdec, rf1_gsprg1_rdec, rf1_gsprg2_rdec, rf1_gsprg3_rdec
 , rf1_sprg0_rdec , rf1_sprg1_rdec , rf1_sprg2_rdec , rf1_sprg3_rdec 
 , rf1_sprg4_rdec , rf1_sprg5_rdec , rf1_sprg6_rdec , rf1_sprg7_rdec 
 , rf1_sprg8_rdec , rf1_vrsave_rdec
													: std_ulogic;
signal
	ex2_ccr0_re    , ex2_ccr1_re    , ex2_ccr2_re    , ex2_dac1_re    
 , ex2_dac2_re    , ex2_dac3_re    , ex2_dac4_re    , ex2_givpr_re   
 , ex2_iac1_re    , ex2_iac2_re    , ex2_iac3_re    , ex2_iac4_re    
 , ex2_ivpr_re    , ex2_pir_re     , ex2_pvr_re     , ex2_tb_re      
 , ex2_tbu_re     , ex2_tenc_re    , ex2_tens_re    , ex2_tensr_re   
 , ex2_tir_re     , ex2_xucr0_re   , ex2_xucr3_re   , ex2_xucr4_re   
													: std_ulogic;
signal
	ex2_dvc1_re    , ex2_dvc2_re    , ex2_eplc_re    , ex2_epsc_re    
 , ex2_eptcfg_re  , ex2_immr_re    , ex2_imr_re     , ex2_iucr0_re   
 , ex2_iucr1_re   , ex2_iucr2_re   , ex2_iudbg0_re  , ex2_iudbg1_re  
 , ex2_iudbg2_re  , ex2_iulfsr_re  , ex2_iullcr_re  , ex2_lper_re    
 , ex2_lperu_re   , ex2_lpidr_re   , ex2_lratcfg_re , ex2_lratps_re  
 , ex2_mas0_re    , ex2_mas0_mas1_re, ex2_mas1_re    , ex2_mas2_re    
 , ex2_mas2u_re   , ex2_mas3_re    , ex2_mas4_re    , ex2_mas5_re    
 , ex2_mas5_mas6_re, ex2_mas6_re    , ex2_mas7_re    , ex2_mas7_mas3_re
 , ex2_mas8_re    , ex2_mas8_mas1_re, ex2_mmucfg_re  , ex2_mmucr0_re  
 , ex2_mmucr1_re  , ex2_mmucr2_re  , ex2_mmucr3_re  , ex2_mmucsr0_re 
 , ex2_pid_re     , ex2_ppr32_re   , ex2_tlb0cfg_re , ex2_tlb0ps_re  
 , ex2_xucr2_re   , ex2_xudbg0_re  , ex2_xudbg1_re  , ex2_xudbg2_re  
													: std_ulogic;
signal ex2_sprg8_re, ex2_sprg8_we                  : std_ulogic;
signal
	ex2_ccr0_we    , ex2_ccr1_we    , ex2_ccr2_we    , ex2_dac1_we    
 , ex2_dac2_we    , ex2_dac3_we    , ex2_dac4_we    , ex2_givpr_we   
 , ex2_iac1_we    , ex2_iac2_we    , ex2_iac3_we    , ex2_iac4_we    
 , ex2_ivpr_we    , ex2_tbl_we     , ex2_tbu_we     , ex2_tenc_we    
 , ex2_tens_we    , ex2_trace_we   , ex2_xucr0_we   , ex2_xucr3_we   
 , ex2_xucr4_we   
													: std_ulogic;
signal
	ex2_dvc1_we    , ex2_dvc2_we    , ex2_eplc_we    , ex2_epsc_we    
 , ex2_immr_we    , ex2_imr_we     , ex2_iucr0_we   , ex2_iucr1_we   
 , ex2_iucr2_we   , ex2_iudbg0_we  , ex2_iulfsr_we  , ex2_iullcr_we  
 , ex2_lper_we    , ex2_lperu_we   , ex2_lpidr_we   , ex2_mas0_we    
 , ex2_mas0_mas1_we, ex2_mas1_we    , ex2_mas2_we    , ex2_mas2u_we   
 , ex2_mas3_we    , ex2_mas4_we    , ex2_mas5_we    , ex2_mas5_mas6_we
 , ex2_mas6_we    , ex2_mas7_we    , ex2_mas7_mas3_we, ex2_mas8_we    
 , ex2_mas8_mas1_we, ex2_mmucr0_we  , ex2_mmucr1_we  , ex2_mmucr2_we  
 , ex2_mmucr3_we  , ex2_mmucsr0_we , ex2_pid_we     , ex2_ppr32_we   
 , ex2_xucr2_we   , ex2_xudbg0_we  
													: std_ulogic;
signal
	ex2_ccr0_rdec  , ex2_ccr1_rdec  , ex2_ccr2_rdec  , ex2_dac1_rdec  
 , ex2_dac2_rdec  , ex2_dac3_rdec  , ex2_dac4_rdec  , ex2_givpr_rdec 
 , ex2_iac1_rdec  , ex2_iac2_rdec  , ex2_iac3_rdec  , ex2_iac4_rdec  
 , ex2_ivpr_rdec  , ex2_pir_rdec   , ex2_pvr_rdec   , ex2_tb_rdec    
 , ex2_tbu_rdec   , ex2_tenc_rdec  , ex2_tens_rdec  , ex2_tensr_rdec 
 , ex2_tir_rdec   , ex2_xucr0_rdec , ex2_xucr3_rdec , ex2_xucr4_rdec 
													: std_ulogic;
signal
	ex2_dvc1_rdec  , ex2_dvc2_rdec  , ex2_eplc_rdec  , ex2_epsc_rdec  
 , ex2_eptcfg_rdec, ex2_immr_rdec  , ex2_imr_rdec   , ex2_iucr0_rdec 
 , ex2_iucr1_rdec , ex2_iucr2_rdec , ex2_iudbg0_rdec, ex2_iudbg1_rdec
 , ex2_iudbg2_rdec, ex2_iulfsr_rdec, ex2_iullcr_rdec, ex2_lper_rdec  
 , ex2_lperu_rdec , ex2_lpidr_rdec , ex2_lratcfg_rdec, ex2_lratps_rdec
 , ex2_mas0_rdec  , ex2_mas0_mas1_rdec, ex2_mas1_rdec  , ex2_mas2_rdec  
 , ex2_mas2u_rdec , ex2_mas3_rdec  , ex2_mas4_rdec  , ex2_mas5_rdec  
 , ex2_mas5_mas6_rdec, ex2_mas6_rdec  , ex2_mas7_rdec  , ex2_mas7_mas3_rdec
 , ex2_mas8_rdec  , ex2_mas8_mas1_rdec, ex2_mmucfg_rdec, ex2_mmucr0_rdec
 , ex2_mmucr1_rdec, ex2_mmucr2_rdec, ex2_mmucr3_rdec, ex2_mmucsr0_rdec
 , ex2_pid_rdec   , ex2_ppr32_rdec , ex2_tlb0cfg_rdec, ex2_tlb0ps_rdec
 , ex2_xucr2_rdec , ex2_xudbg0_rdec, ex2_xudbg1_rdec, ex2_xudbg2_rdec
													: std_ulogic;
signal
	ex2_gsprg0_rdec, ex2_gsprg1_rdec, ex2_gsprg2_rdec, ex2_gsprg3_rdec
 , ex2_sprg0_rdec , ex2_sprg1_rdec , ex2_sprg2_rdec , ex2_sprg3_rdec 
 , ex2_sprg4_rdec , ex2_sprg5_rdec , ex2_sprg6_rdec , ex2_sprg7_rdec 
 , ex2_sprg8_rdec , ex2_vrsave_rdec
													: std_ulogic;
signal
	ex2_ccr0_wdec  , ex2_ccr1_wdec  , ex2_ccr2_wdec  , ex2_dac1_wdec  
 , ex2_dac2_wdec  , ex2_dac3_wdec  , ex2_dac4_wdec  , ex2_givpr_wdec 
 , ex2_iac1_wdec  , ex2_iac2_wdec  , ex2_iac3_wdec  , ex2_iac4_wdec  
 , ex2_ivpr_wdec  , ex2_tbl_wdec   , ex2_tbu_wdec   , ex2_tenc_wdec  
 , ex2_tens_wdec  , ex2_trace_wdec , ex2_xucr0_wdec , ex2_xucr3_wdec 
 , ex2_xucr4_wdec 
													: std_ulogic;
signal
	ex2_gsprg0_wdec, ex2_gsprg1_wdec, ex2_gsprg2_wdec, ex2_gsprg3_wdec
 , ex2_sprg0_wdec , ex2_sprg1_wdec , ex2_sprg2_wdec , ex2_sprg3_wdec 
 , ex2_sprg4_wdec , ex2_sprg5_wdec , ex2_sprg6_wdec , ex2_sprg7_wdec 
 , ex2_sprg8_wdec , ex2_vrsave_wdec
													: std_ulogic;
signal
	ex2_dvc1_wdec  , ex2_dvc2_wdec  , ex2_eplc_wdec  , ex2_epsc_wdec  
 , ex2_immr_wdec  , ex2_imr_wdec   , ex2_iucr0_wdec , ex2_iucr1_wdec 
 , ex2_iucr2_wdec , ex2_iudbg0_wdec, ex2_iulfsr_wdec, ex2_iullcr_wdec
 , ex2_lper_wdec  , ex2_lperu_wdec , ex2_lpidr_wdec , ex2_mas0_wdec  
 , ex2_mas0_mas1_wdec, ex2_mas1_wdec  , ex2_mas2_wdec  , ex2_mas2u_wdec 
 , ex2_mas3_wdec  , ex2_mas4_wdec  , ex2_mas5_wdec  , ex2_mas5_mas6_wdec
 , ex2_mas6_wdec  , ex2_mas7_wdec  , ex2_mas7_mas3_wdec, ex2_mas8_wdec  
 , ex2_mas8_mas1_wdec, ex2_mmucr0_wdec, ex2_mmucr1_wdec, ex2_mmucr2_wdec
 , ex2_mmucr3_wdec, ex2_mmucsr0_wdec, ex2_pid_wdec   , ex2_ppr32_wdec 
 , ex2_xucr2_wdec , ex2_xudbg0_wdec
													: std_ulogic;
signal
	ex3_gsprg0_wdec, ex3_gsprg1_wdec, ex3_gsprg2_wdec, ex3_gsprg3_wdec
 , ex3_sprg0_wdec , ex3_sprg1_wdec , ex3_sprg2_wdec , ex3_sprg3_wdec 
 , ex3_sprg4_wdec , ex3_sprg5_wdec , ex3_sprg6_wdec , ex3_sprg7_wdec 
 , ex3_sprg8_wdec , ex3_vrsave_wdec
													: std_ulogic;
signal
	ex3_gsprg0_we  , ex3_gsprg1_we  , ex3_gsprg2_we  , ex3_gsprg3_we  
 , ex3_sprg0_we   , ex3_sprg1_we   , ex3_sprg2_we   , ex3_sprg3_we   
 , ex3_sprg4_we   , ex3_sprg5_we   , ex3_sprg6_we   , ex3_sprg7_we   
 , ex3_sprg8_we   , ex3_vrsave_we  
													: std_ulogic;
signal
	ex6_ccr0_wdec  , ex6_ccr1_wdec  , ex6_ccr2_wdec  , ex6_tbl_wdec   
 , ex6_tbu_wdec   , ex6_tenc_wdec  , ex6_tens_wdec  , ex6_xucr0_wdec 
													: std_ulogic;
signal
	ex6_ccr0_we    , ex6_ccr1_we    , ex6_ccr2_we    , ex6_tbl_we     
 , ex6_tbu_we     , ex6_tenc_we    , ex6_tens_we    , ex6_xucr0_we   
													: std_ulogic;
signal
	ccr0_act       , ccr1_act       , ccr2_act       , pir_act        
 , pvr_act        , tb_act         , tbl_act        , tbu_act        
 , tenc_act       , tens_act       , tensr_act      , tir_act        
 , xucr0_act      
													: std_ulogic;
signal
	ccr0_do        , ccr1_do        , ccr2_do        , pir_do         
 , pvr_do         , tb_do          , tbl_do         , tbu_do         
 , tenc_do        , tens_do        , tensr_do       , tir_do         
 , xucr0_do       
													: std_ulogic_vector(0 to 64);

begin


tiup           <= '1';
tidn           <= (others=>'0');

cspr_xucr0_clkg_ctl  <= spr_xucr0_clkg_ctl;

rf1_aspr_act_d    <= rf0_act;

rf0_act           <= or_reduce(dec_spr_rf0_tid) or spr_xucr0_clkg_ctl(4);
exx_act_d         <= rf0_act & exx_act(0 to 4);

exx_act(0)        <= (exx_act_q(0) and or_reduce(dec_spr_rf1_val)) or spr_xucr0_clkg_ctl(4);
exx_act(1)        <= exx_act_q(1);
exx_act(2)        <= exx_act_q(2);
exx_act(3)        <= exx_act_q(3);
exx_act(4)        <= exx_act_q(4);
exx_act(5)        <= exx_act_q(5);

-- Needs to be on for loads and stores, for the DEAR...
exx_act_data(1)   <= exx_act(1);
exx_act_data(2)   <= exx_act(2);
exx_act_data(3)   <= exx_act(3);
exx_act_data(4)   <= exx_act(4);
exx_act_data(5)   <= exx_act(5);

cspr_tspr_rf1_act <= exx_act(0);

dbell_act         <= lsu_xu_dbell_val or spr_xucr0_clkg_ctl(4);

spr_bit_act       <= '1';

-- Decode
rf1_opcode_is_31        <= rf1_instr_q(0 to 5) = "011111";
ex1_opcode_is_31        <= ex1_instr_q(0 to 5) = "011111";
rf1_is_mfspr            <= '1' when rf1_opcode_is_31 and rf1_instr_q(21 to 30) = "0101010011" else '0'; -- 31/339
rf1_is_mtspr            <= '1' when rf1_opcode_is_31 and rf1_instr_q(21 to 30) = "0111010011" else '0'; -- 31/467
ex1_is_mfmsr            <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0001010011" else '0'; -- 31/083
ex1_is_mtmsr            <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0010010010" else '0'; -- 31/146
ex1_is_mftb             <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0101110011" else '0'; -- 31/371
ex1_is_wait             <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0000111110" else '0'; -- 31/062
ex1_is_msgclr           <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0011101110" else '0'; -- 31/238
ex1_is_wrtee            <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0010000011" else '0'; -- 31/131
ex1_is_wrteei           <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0010100011" else '0'; -- 31/163
ex1_is_mtdcr            <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0111000011" else '0'; -- 31/451
ex1_is_mtdcrux          <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0110100011" else '0'; -- 31/419
ex1_is_mtdcrx           <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0110000011" else '0'; -- 31/387
ex1_is_mfdcr            <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0101000011" else '0'; -- 31/323
ex1_is_mfdcrux          <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0100100011" else '0'; -- 31/291
ex1_is_mfdcrx           <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0100000011" else '0'; -- 31/259
ex1_is_mfcr             <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0000010011" else '0'; -- 31/19
ex1_is_mtcrf            <= '1' when ex1_opcode_is_31 and ex1_instr_q(21 to 30) = "0010010000" else '0'; -- 31/144

ex1_dcr_instr           <= ex1_is_mtdcrux or ex1_is_mtdcrx or ex1_is_mtdcr or ex1_dcr_read;
ex1_dcr_read            <= ex1_is_mfdcrux or ex1_is_mfdcrx or ex1_is_mfdcr;
ex1_dcr_user            <= ex1_is_mtdcrux or ex1_is_mfdcrux;
ex1_dcr_val             <= ex1_dcr_instr and spr_ccr2_en_dcr_int;

ex2_any_mfspr_d         <= ex1_is_mfspr_q or ex1_is_mfmsr or ex1_is_mftb or ex1_is_mfcr;
ex2_any_mtspr_d         <= ex1_is_mtspr_q or ex1_is_mtmsr or                ex1_is_mtcrf or ex1_is_wrtee or ex1_is_wrteei;

-- Run State
xu_pc_spr_ccr0_we    <= spr_ccr0_we_rev and quiesced_q;
spr_ccr0_we_rev      <= reverse(spr_ccr0_we);
spr_tens_ten_rev     <= reverse(spr_tens_ten);

quiesce_b_q          <= not (quiesce_q and not running_q);
quiesce_d            <= iu_quiesce_q   and
                        lsu_quiesce_q  and
                        mm_quiesce_q   and
                        bx_quiesce_q;

cpl_quiesce_b_q      <= not cpl_quiesce_q;
cpl_quiesce_d        <= cpl_spr_quiesce and not running_q;
                    
-- CPL needs a seperate copy that doesn't include its own signals
quiesced_d           <=     quiesce_q and not     quiesce_ctr_zero_b and
                        cpl_quiesce_q and not cpl_quiesce_ctr_zero_b;

xu_pc_running        <= running;

quiesced_4cpl_d      <= lsu_quiesce_q;
spr_cpl_quiesce      <= quiesced_4cpl_q;

running              <= running_q or not quiesced_q;
running_d            <= (cpl_spr_stop nor spr_ccr0_we_rev) and spr_tens_ten_rev;
iu_run_thread_d      <= running_q and llmask;
xu_iu_run_thread     <= iu_run_thread_q;

spr_tensr            <= spr_tens_ten or reverse(running);

ex6_any_valid        <= or_reduce(ex6_valid_q);
ex1_tenc_we          <= (ex1_instr_q(11 to 20) = "1011101101");   --  439
ex1_ccr0_we          <= (ex1_instr_q(11 to 20) = "1000011111");   -- 1008

-- Wakeup Condition Masking
pm_wake_up_gen : for t in 0 to threads-1 generate

-- Reset the mask when running
-- Set the mask on a valid wait instruction
-- Otherwise hold

-- WAIT[WC](0) = Resume on Imp. Specific
-- WAIT[WC](1) = Resume on no reservation
waitimpl_val_d(t)          <= '0'                     when pm_wake_up(t)      ='1' else
                              ex6_wait_wc_q(9)        when ex6_wait(t)        ='1' else
                              waitimpl_val_q(t);

waitrsv_val_d(t)           <= '0'                     when pm_wake_up(t)      ='1' else
                              ex6_wait_wc_q(10)       when ex6_wait(t)        ='1' else
                              waitrsv_val_q(t);

-- Block interrupts (mask=0) if:
-- Stopped via (HW Debug and pc_xu_extirpts_dis_on_stop)=1
-- Stopped via TEN=0
-- Stopped via CCR0=1, unless overriden by CCR1=1 (and wait, if applicable)
crit_mask(t)   <= not(ext_dbg_dis_q(t) or not spr_tens_ten_rev(t) or (spr_ccr0_we_rev(t) and not ccr1_q(60-6*t)));
base_mask(t)   <= not(ext_dbg_dis_q(t) or not spr_tens_ten_rev(t) or (spr_ccr0_we_rev(t) and not ccr1_q(61-6*t)));
dec_mask(t)    <= not(ext_dbg_dis_q(t) or not spr_tens_ten_rev(t) or (spr_ccr0_we_rev(t) and not ccr1_q(62-6*t)));
fit_mask(t)    <= not(ext_dbg_dis_q(t) or not spr_tens_ten_rev(t) or (spr_ccr0_we_rev(t) and not ccr1_q(63-6*t)));

cspr_tspr_crit_mask(t)  <= crit_mask(t);
cspr_tspr_ext_mask(t)   <= base_mask(t);
cspr_tspr_dec_mask(t)   <= dec_mask(t); 
cspr_tspr_fit_mask(t)   <= fit_mask(t);
cspr_tspr_wdog_mask(t)  <= crit_mask(t);
cspr_tspr_udec_mask(t)  <= dec_mask(t);
cspr_tspr_perf_mask(t)  <= base_mask(t);

-- Generate Conditional Wait flush
ex2_wait_flush(t)      <= ex2_tid(t) and ex2_is_wait_q and 
                         ((ex2_wait_wc_q = "00") or                                                         -- Unconditional Wait
                          (ex2_wait_wc_q = "01" and an_ac_reservation_vld_q(t) and not ccr1_q(58-6*t)) or   -- Reservation Exists
                          (ex2_wait_wc_q = "10" and an_ac_sleep_en_q(t)        and not ccr1_q(59-6*t)));    -- Impl. Specific Exists (Sleep enabled)

ex2_ccr0_flush(t)      <= ex2_is_mtspr_q and ex2_ccr0_we_q and ex2_rs0_q(55-t) and ex2_rs0_q(63-t);

ex2_tenc_flush(t)      <= ex2_is_mtspr_q and ex2_tenc_we_q and                     ex2_rs0_q(63-t);


end generate;

ex2_wait       <= or_reduce(ex2_wait_flush);

with s3'(ex2_is_wait_q & ex2_ccr0_we_q & ex2_tenc_we_q) select
   spr_cpl_ex2_run_ctl_flush     <= ex2_wait_flush    when "100",
                                    ex2_ccr0_flush    when "010",
                                    ex2_tenc_flush    when "001",
                                    (others=>'0')     when others;

pm_wake_up     <= (not an_ac_reservation_vld_q and waitrsv_val_q )   or
                  (       not an_ac_sleep_en_q and waitimpl_val_q)   or
                  tspr_cspr_pm_wake_up                         or
                  dbell_interrupt_q                            or
                  cdbell_interrupt_q                           or
                  gdbell_interrupt_q                           or
                  gcdbell_interrupt_q                          or
                  gmcdbell_interrupt_q;
                  
ex6_wait       <= gate(ex6_tid,(ex6_any_valid and ex6_wait_q));


-- Debug Timer Disable
tb_dbg_dis_d         <= and_reduce(cpl_spr_stop) and pc_xu_timebase_dis_on_stop;
dec_dbg_dis_d        <= gate(cpl_spr_stop,pc_xu_decrem_dis_on_stop);
ext_dbg_dis_d        <= gate(cpl_spr_stop,pc_xu_extirpts_dis_on_stop);

-- LiveLock Priority
cspr_tspr_llen    <= running_q;
cspr_tspr_llpri   <= llpri_q;
llpres            <= or_reduce(                tspr_cspr_lldet);
llunmasked        <= or_reduce(    llpri_q and tspr_cspr_lldet);
llmasked          <= or_reduce(not llpri_q and tspr_cspr_lldet);
llpulse           <= or_reduce(    llpri_q and tspr_cspr_llpulse);

-- Increment the hang priority if:
--    There is a       hang present, but the priority is masking it.
--    There is another hang present, and there is a hang pulse.
llpri_inc   <= (llpres and not llunmasked) or 
               (llpulse and llmasked and llunmasked);

llpri_d     <= llpri_q(threads-1) & llpri_q(0 to threads-2);

llmask      <= (llpri_q and tspr_cspr_lldet) or not (0 to threads-1=>llpres);



with s2'(instr_trace_tid_q) select
   instr_trace_tid   <= "1000" when "00",
                        "0100" when "01",
                        "0010" when "10",
                        "0001" when others;

instr_trace_mode  <= gate(instr_trace_tid,instr_trace_mode_q);

with s4'(dec_spr_rf0_tid) select
   rf1_aspr_tid_d <= "00" when "1000",
                     "01" when "0100",
                     "10" when "0010",
                     "11" when others;

with dec_spr_rf1_val select
   rf1_tid     <= "00" when "1000",
                  "01" when "0100",
                  "10" when "0010",
                  "11" when others;
with ex1_tid_q select
   ex1_tid     <= "1000" when "00",
                  "0100" when "01",
                  "0010" when "10",
                  "0001" when others;
with ex2_tid_q select
   ex2_tid     <= "1000" when "00",
                  "0100" when "01",
                  "0010" when "10",
                  "0001" when others;

with ex4_tid_q select
   ex4_tid     <= "1000" when "00",
                  "0100" when "01",
                  "0010" when "10",
                  "0001" when others;

with ex5_tid_q select
   ex5_tid     <= "1000" when "00",
                  "0100" when "01",
                  "0010" when "10",
                  "0001" when others;
                  
with ex6_tid_q select
   ex6_tid     <= "1000" when "00",
                  "0100" when "01",
                  "0010" when "10",
                  "0001" when others;
with ram_thread_q select
   ram_tid     <= "1000" when "00",
                  "0100" when "01",
                  "0010" when "10",
                  "0001" when others;

rf1_instr      <= rf1_instr_q(11 to 20);
ex2_instr_d    <= gate(ex1_instr_q(11 to 20),(ex1_is_mfspr_q or ex1_is_mtspr_q or ex1_is_wrteei or ex1_is_wait or ex1_is_mftb));
ex2_instr      <= ex2_instr_q(11 to 20);
ex3_instr_d    <= ex2_instr_q or gate(ex2_dcrn_q,ex2_dcr_val_q);

rf1_msr_gs_d   <=          or_reduce(tspr_msr_gs and dec_spr_rf0_tid);
ex2_msr_gs_d   <= (others=>or_reduce(tspr_msr_gs and ex1_tid));
ex3_msr_gs_d   <=          or_reduce(tspr_msr_gs and ex2_tid);

ex5_val_d      <=           dec_spr_ex4_val and not xu_ex4_flush;
ex5_valid      <=           ex5_val_q       and not xu_ex5_flush;     
ex5_val        <= or_reduce(ex5_valid);
ex5_spr_wd     <= ex5_rt_q;
ex5_rt_q_b     <= ex5_rt_q;
ex3_instr      <= ex3_instr_q;

ex6_val        <= ex6_val_q;
ex6_spr_wd     <= ex6_rt_q;
ex6_instr      <= ex6_instr_q;
ex6_is_mtspr   <= ex6_is_mtspr_q;

ram_mode                <= gate(ram_tid,ram_mode_q);
cspr_tspr_ram_mode      <= ram_mode;

cspr_tspr_msrovride_en  <= gate(ram_mode,msrovride_enab_q);

-- Perf Events
perf_count : for t in 0 to threads-1 generate
   perf_event_d(0+3*t)     <= running(t);
   perf_event_d(1+3*t)     <= ex5_valid(t) and ex5_any_mfspr_q;
   perf_event_d(2+3*t)     <= ex5_valid(t) and ex5_any_mtspr_q;

   spr_perf_tx_events(0+8*t)  <= perf_event_q(0+3*t);
   spr_perf_tx_events(1+8*t)  <= tb_act_q;
   spr_perf_tx_events(2+8*t)  <= perf_event_q(1+3*t);
   spr_perf_tx_events(3+8*t)  <= perf_event_q(2+3*t);
   spr_perf_tx_events(4+8*t)  <= waitrsv_val_q(t);
   spr_perf_tx_events(5+8*t)  <= tspr_cspr_async_int(0+3*t);
   spr_perf_tx_events(6+8*t)  <= tspr_cspr_async_int(1+3*t);
   spr_perf_tx_events(7+8*t)  <= tspr_cspr_async_int(2+3*t);
end generate;

-- SPR Input Control
-- CCR0
ccr0_act          <= spr_xucr0_clkg_ctl(4) or ex6_ccr0_we or or_reduce(pm_wake_up) or ex6_wait_q;

ccr0_wen          <= (0 to 1=>ex6_ccr0_we) & gate(ex6_spr_wd(56-threads to 55),ex6_ccr0_we);

ccr0_di           <= (ex6_ccr0_di and     ccr0_wen) or
                     (     ccr0_q and not ccr0_wen);
                     
ccr0_d(62-threads to 63-threads) <= ccr0_di(62-threads to 63-threads);
ccr0_d(64-threads to 63)         <= (ccr0_di(64-threads to 63) or reverse(ex6_wait)) and not reverse(pm_wake_up);

-- CCR1
ccr1_act          <= ex6_ccr1_we;
ccr1_d            <= ex6_ccr1_di;

-- CCR2
ccr2_act          <= ex6_ccr2_we;
ccr2_d            <= ex6_ccr2_di;

-- PIR
pir_act           <= tiup;

-- PVR
pvr_act           <= tiup;

version           <= x"00" & spr_pvr_version_dc(8 to 15);
revision          <= x"0"  & spr_pvr_revision_dc(12 to 15) & x"0" & revision_minor;
revision_minor    <= x"0";

-- TB
tb_update_pulse   <= (tb_update_pulse_q xor tb_update_pulse_1_q);  -- Any Edge

timer_update_int  <= tb_update_enable_q and (tb_update_pulse or not spr_xucr0_tcs);       -- Update on external signal selected by XUCR0[TCS]
timer_update      <= timer_update_q;

tb_act_d          <= not tb_dbg_dis_q and                                                 -- Not Stopped via HW DBG (if enabled)
                     not or_reduce(tspr_cspr_freeze_timers) and                           -- Timers not frozen due to debug event
                         timer_update_int;                                                
                         
tb_act            <= tb_act_q;
tb_q              <= tbu_q & tbl_q;
tb                <= std_ulogic_vector(unsigned(tb_q)+1);

-- TBL
tbl_act           <= tb_act or ex6_tbl_we;
with (ex6_tbl_we) select
   tbl_d             <= ex6_tbl_di     when '1',
                        tb(32 to 63)   when others;

-- TBU
tbu_act           <= tb_act or ex6_tbu_we;
with (ex6_tbu_we) select
   tbu_d             <= ex6_tbu_di     when '1',
                        tb(0 to 31)    when others;

-- TENC
tenc_act          <= tiup;                     

-- TENS
tens_act          <= ex6_tenc_we or ex6_tens_we;
tens_d            <= (tens_q and not ex6_tens_di) when ex6_tenc_we='1' else
                     (tens_q or      ex6_tens_di);
-- TENSR
tensr_act         <= tiup;

-- TIR
tir_act           <= tiup;

-- XUCR0
ex5_flush            <= or_reduce(xu_ex5_flush and ex5_tid);

ex6_set_xucr0_cslc_d <=(lsu_xu_spr_xucr0_cslc_xuop and not ex5_flush) or
                        lsu_xu_spr_xucr0_cslc_binv;
                        
ex6_set_xucr0_cul_d  <=(lsu_xu_spr_xucr0_cul       and not ex5_flush);
                       
ex6_set_xucr0_clo_d  <= lsu_xu_spr_xucr0_clo;

xucr0_act            <= spr_xucr0_clkg_ctl(4) or ex6_xucr0_we or 
                        ex6_set_xucr0_cslc_q or ex6_set_xucr0_cul_q or ex6_set_xucr0_clo_q;

xucr0_d              <= xucr0_di(xucr0_q'left to 60) &
                       (xucr0_di(61) or ex6_set_xucr0_cslc_q) &
                       (xucr0_di(62) or ex6_set_xucr0_cul_q) &
                       (xucr0_di(63) or ex6_set_xucr0_clo_q);

with (ex6_xucr0_we) select
   xucr0_di             <= ex6_xucr0_di   when '1',
                           xucr0_q        when others;     

-- IO signal assignments

                                            --        FIT   LL    WDOG
cspr_tspr_timebase_taps(8) <= tbl_q(32+23); --  9           x
cspr_tspr_timebase_taps(7) <= tbl_q(32+11); -- 21           x
cspr_tspr_timebase_taps(6) <= tbl_q(32+ 7); -- 25           x
cspr_tspr_timebase_taps(5) <= tbl_q(32+21); -- 11     x     x
cspr_tspr_timebase_taps(4) <= tbl_q(32+17); -- 15     x     x
cspr_tspr_timebase_taps(3) <= tbl_q(32+13); -- 19     x     x     x
cspr_tspr_timebase_taps(2) <= tbl_q(32+ 9); -- 23     x     x     x
cspr_tspr_timebase_taps(1) <= tbl_q(32+ 5); -- 27           x
cspr_tspr_timebase_taps(0) <= tbl_q(32+ 1); -- 31                 x

cspr_tspr_timebase_taps(9) <= tbl_q(32+ 7); -- 29                 x   -- Replaced 1 for wdog


cspr_tspr_ex2_tid          <= ex2_tid;
cspr_tspr_ex1_instr        <= ex1_instr_q;
cspr_tspr_ex5_is_mtmsr     <= ex5_is_mtmsr_q;
cspr_tspr_ex5_is_mtspr     <= ex5_is_mtspr_q;
cspr_tspr_ex5_instr        <= ex5_instr_q;
cspr_tspr_dec_dbg_dis      <= dec_dbg_dis_q;

reset_wd_complete             <= pc_xu_reset_wd_complete_q;
reset_3_complete              <= pc_xu_reset_3_complete_q;
reset_2_complete              <= pc_xu_reset_2_complete_q;
reset_1_complete              <= pc_xu_reset_1_complete_q;

cspr_tspr_ex5_is_wrtee     <= ex5_is_wrtee_q;
cspr_tspr_ex5_is_wrteei    <= ex5_is_wrteei_q;

cspr_aspr_ex5_we           <= or_reduce(ex5_aspr_we_q and not xu_ex5_flush);
cspr_aspr_ex5_waddr        <= ex5_aspr_addr_q & ex5_tid_q;
cspr_aspr_rf1_re           <= rf1_aspr_re(1) and rf1_aspr_act_q;
cspr_aspr_rf1_raddr        <= rf1_aspr_addr & rf1_aspr_tid_q;

xu_lsu_slowspr_val         <= ex6_val_q and ex6_sspr_val_q;
xu_lsu_slowspr_rw          <= not ex6_is_mtspr_q;
xu_lsu_slowspr_etid        <= ex6_tid_q;
xu_lsu_slowspr_addr        <= ex6_instr_q(16 to 20) & ex6_instr_q(11 to 15);
xu_lsu_slowspr_data        <= ex6_spr_wd;

ex4_dcr_val                <= exx_act(4) and ex4_dcr_val_q;
ex5_dcr_val                <= ex5_val    and ex5_dcr_val_q;

ac_an_dcr_act              <= ex5_dcr_val_q;
ac_an_dcr_val              <= ex6_dcr_val_q;
ac_an_dcr_read             <= ex6_dcr_read_q;
ac_an_dcr_user             <= ex6_dcr_user_q;
ac_an_dcr_etid             <= ex6_tid_q;
ac_an_dcr_addr             <= ex6_instr_q(11 to 20);
ac_an_dcr_data             <= ex6_spr_wd;

spr_cpl_ex3_spr_hypv       <= ex3_hypv_spr_q;
spr_cpl_ex3_spr_illeg      <= ex3_illeg_spr_q;
spr_cpl_ex3_spr_priv       <= ex3_priv_spr_q;

xu_lsu_mtspr_trace_en      <= gate((spr_xucr0_trace_um or not tspr_msr_pr),spr_ccr2_en_trace);

dbell_pir_match            <= (lsu_xu_dbell_pirtag_q(50 to 61) = pir_do(51 to 62));

with lsu_xu_dbell_pirtag_q(62 to 63) select
   dbell_pir_thread        <= "1000" when "00",
                              "0100" when "01",
                              "0010" when "10",
                              "0001" when "11",
                              "0000" when others;

cspr_tspr_dbell_pirtag     <= lsu_xu_dbell_pirtag_q;

dbell : for t in 0 to threads-1 generate

set_dbell(t)    <= lsu_xu_dbell_val_q and lsu_xu_dbell_type_q = "00000" and lsu_xu_dbell_lpid_match_q and (lsu_xu_dbell_brdcast_q or (dbell_pir_match and dbell_pir_thread(t)));
set_cdbell(t)   <= lsu_xu_dbell_val_q and lsu_xu_dbell_type_q = "00001" and lsu_xu_dbell_lpid_match_q and (lsu_xu_dbell_brdcast_q or (dbell_pir_match and dbell_pir_thread(t)));
set_gdbell(t)   <= lsu_xu_dbell_val_q and lsu_xu_dbell_type_q = "00010" and lsu_xu_dbell_lpid_match_q and (lsu_xu_dbell_brdcast_q or tspr_cspr_gpir_match(t));
set_gcdbell(t)  <= lsu_xu_dbell_val_q and lsu_xu_dbell_type_q = "00011" and lsu_xu_dbell_lpid_match_q and (lsu_xu_dbell_brdcast_q or tspr_cspr_gpir_match(t));
set_gmcdbell(t) <= lsu_xu_dbell_val_q and lsu_xu_dbell_type_q = "00100" and lsu_xu_dbell_lpid_match_q and (lsu_xu_dbell_brdcast_q or tspr_cspr_gpir_match(t));

clr_dbell(t)    <= ex6_valid_q(t) and ex6_is_msgclr_q and (ex6_spr_wd(32 to 36) = "00000");
clr_cdbell(t)   <= ex6_valid_q(t) and ex6_is_msgclr_q and (ex6_spr_wd(32 to 36) = "00001");
clr_gdbell(t)   <= ex6_valid_q(t) and ex6_is_msgclr_q and (ex6_spr_wd(32 to 36) = "00010");
clr_gcdbell(t)  <= ex6_valid_q(t) and ex6_is_msgclr_q and (ex6_spr_wd(32 to 36) = "00011");
clr_gmcdbell(t) <= ex6_valid_q(t) and ex6_is_msgclr_q and (ex6_spr_wd(32 to 36) = "00100");

end generate;

dbell_present_d               <= set_dbell         or (dbell_present_q     and not (clr_dbell      or ex6_dbell_taken_q   ));
cdbell_present_d              <= set_cdbell        or (cdbell_present_q    and not (clr_cdbell     or ex6_cdbell_taken_q  ));
gdbell_present_d              <= set_gdbell        or (gdbell_present_q    and not (clr_gdbell     or ex6_gdbell_taken_q  ));
gcdbell_present_d             <= set_gcdbell       or (gcdbell_present_q   and not (clr_gcdbell    or ex6_gcdbell_taken_q ));
gmcdbell_present_d            <= set_gmcdbell      or (gmcdbell_present_q  and not (clr_gmcdbell   or ex6_gmcdbell_taken_q));

dbell_interrupt               <= dbell_present_q      and base_mask and (tspr_msr_ee or tspr_msr_gs);  
cdbell_interrupt              <= cdbell_present_q     and crit_mask and (tspr_msr_ce or tspr_msr_gs);  
gdbell_interrupt              <= gdbell_present_q     and base_mask and tspr_msr_ee and tspr_msr_gs;  
gcdbell_interrupt             <= gcdbell_present_q    and crit_mask and tspr_msr_ce and tspr_msr_gs; 
gmcdbell_interrupt            <= gmcdbell_present_q   and crit_mask and tspr_msr_me and tspr_msr_gs;

spr_cpl_dbell_interrupt       <= dbell_interrupt_q;
spr_cpl_cdbell_interrupt      <= cdbell_interrupt_q;
spr_cpl_gdbell_interrupt      <= gdbell_interrupt_q;
spr_cpl_gcdbell_interrupt     <= gcdbell_interrupt_q;
spr_cpl_gmcdbell_interrupt    <= gmcdbell_interrupt_q;

-- Debug
cspr_debug0                   <= ex6_valid_q                &
                                 ex1_instr_q                &  -- 36
                                 ex3_hypv_spr_q             &
                                 ex3_illeg_spr_q            &
                                 ex3_priv_spr_q             &           
                                 timer_update_q             ;  -- 4

cspr_debug1                   <= lsu_xu_dbell_val_q         &
                                 lsu_xu_dbell_type_q        &
                                 lsu_xu_dbell_lpid_match_q  &
                                 lsu_xu_dbell_brdcast_q     &
                                 lsu_xu_dbell_pirtag_q      &  -- 25
                                 spr_ccr0_we_rev            &
                                 quiesced_q                 &
                                 iu_quiesce_q               &
                                 lsu_quiesce_q              &
                                 mm_quiesce_q               &
                                 bx_quiesce_q               &
                                 cpl_quiesce_q              &
                                 running                    &
                                 iu_run_thread_q            &
                                 pm_wake_up                 &
                                 an_ac_reservation_vld_q    &
                                 an_ac_sleep_en_q           &
                                 waitimpl_val_q             &
                                 waitrsv_val_q              &
                                 llpri_q                    &
                                 tspr_cspr_lldet & "00";       -- 64

-- Array ECC Check
spr_cpl_ex3_sprg_ce        <= ex3_sprg_ce;
spr_cpl_ex3_sprg_ue        <= ex3_sprg_ue;

ex2_aspr_rdata_d(64-regsize)                    <= aspr_cspr_ex1_rdata(64-regsize);
ex2_aspr_rdata_d(65-regsize to 72-(64/regsize)) <= aspr_cspr_ex1_rdata(65-regsize to 72-(64/regsize));

ex2_eccchk_syn_b           <= not ex2_eccchk_syn;

xuq_spr_rd_eccgen : entity work.xuq_eccgen(xuq_eccgen)
generic map(regsize => regsize)
port map(din         => ex2_aspr_rdata_q,
         Syn         => ex2_eccchk_syn);

xuq_spr_eccchk : entity work.xuq_eccchk(xuq_eccchk)
generic map(regsize  => regsize)
port map(din         => ex2_aspr_rdata_q(64-regsize to 63),
         EnCorr      => encorr,
         NSyn        => ex2_eccchk_syn_b,
         Corrd       => ex2_corr_rdata,
         SBE         => ex2_sprg_ce,
         UE          => ex2_sprg_ue);

encorr   <= '1';         
         
ex5_sprg_ce    <= gate(ex5_valid,ex5_sprg_ce_q);

xu_spr_cspr_ce_err_rpt : entity tri.tri_direct_err_rpt(tri_direct_err_rpt) 
generic map(width => threads, expand_type => expand_type)
port map (  vd => vdd, gd => gnd,
            err_in   => ex6_sprg_ce_q,
            err_out  => xu_pc_err_sprg_ecc);

ex3_aspr_rt(32 to 63)         <= gate(ex3_corr_rdata_q(32 to 63),        ex3_aspr_re_q(1));
aspr_rt : if regsize > 32 generate
ex3_aspr_rt(64-regsize to 31) <= gate(ex3_corr_rdata_q(64-regsize to 31),ex3_aspr_re_q(0));
end generate;

ex3_tspr_rt                <= or_reduce_t(tspr_cspr_ex3_tspr_rt,threads);

spr_byp_ex3_spr_rt         <= (ex3_cspr_rt_q and not (64-regsize to 63=>ex3_sspr_val_q)) or ex3_tspr_rt or ex3_aspr_rt;

-- Fast SPR Read
ex2_ccr0_rdec     <= (ex2_instr(11 to 20) = "1000011111");   -- 1008
ex2_ccr1_rdec     <= (ex2_instr(11 to 20) = "1000111111");   -- 1009
ex2_ccr2_rdec     <= (ex2_instr(11 to 20) = "1001011111");   -- 1010
ex2_dac1_rdec     <= (ex2_instr(11 to 20) = "1110001001");   --  316
ex2_dac2_rdec     <= (ex2_instr(11 to 20) = "1110101001");   --  317
ex2_dac3_rdec     <= (ex2_instr(11 to 20) = "1000111010");   --  849
ex2_dac4_rdec     <= (ex2_instr(11 to 20) = "1001011010");   --  850
ex2_givpr_rdec    <= (ex2_instr(11 to 20) = "1111101101");   --  447
ex2_iac1_rdec     <= (ex2_instr(11 to 20) = "1100001001");   --  312
ex2_iac2_rdec     <= (ex2_instr(11 to 20) = "1100101001");   --  313
ex2_iac3_rdec     <= (ex2_instr(11 to 20) = "1101001001");   --  314
ex2_iac4_rdec     <= (ex2_instr(11 to 20) = "1101101001");   --  315
ex2_ivpr_rdec     <= (ex2_instr(11 to 20) = "1111100001");   --   63
ex2_pir_rdec      <= (ex2_instr(11 to 20) = "1111001000");   --  286
ex2_pvr_rdec      <= (ex2_instr(11 to 20) = "1111101000");   --  287
ex2_tb_rdec       <= (ex2_instr(11 to 20) = "0110001000");   --  268
ex2_tbu_rdec      <= ((ex2_instr(11 to 20) = "0110101000"));  --  269
ex2_tenc_rdec     <= (ex2_instr(11 to 20) = "1011101101");   --  439
ex2_tens_rdec     <= (ex2_instr(11 to 20) = "1011001101");   --  438
ex2_tensr_rdec    <= (ex2_instr(11 to 20) = "1010101101");   --  437
ex2_tir_rdec      <= (ex2_instr(11 to 20) = "1111001101");   --  446
ex2_xucr0_rdec    <= (ex2_instr(11 to 20) = "1011011111");   -- 1014
ex2_xucr3_rdec    <= (ex2_instr(11 to 20) = "1010011010");   --  852
ex2_xucr4_rdec    <= (ex2_instr(11 to 20) = "1010111010");   --  853
ex2_ccr0_re       <=  ex2_ccr0_rdec;
ex2_ccr1_re       <=  ex2_ccr1_rdec;
ex2_ccr2_re       <=  ex2_ccr2_rdec;
ex2_dac1_re       <=  ex2_dac1_rdec;
ex2_dac2_re       <=  ex2_dac2_rdec;
ex2_dac3_re       <=  ex2_dac3_rdec;
ex2_dac4_re       <=  ex2_dac4_rdec;
ex2_givpr_re      <=  ex2_givpr_rdec;
ex2_iac1_re       <=  ex2_iac1_rdec;
ex2_iac2_re       <=  ex2_iac2_rdec;
ex2_iac3_re       <=  ex2_iac3_rdec;
ex2_iac4_re       <=  ex2_iac4_rdec;
ex2_ivpr_re       <=  ex2_ivpr_rdec;
ex2_pir_re        <=  ex2_pir_rdec       and not ex2_msr_gs_q(0);
ex2_pvr_re        <=  ex2_pvr_rdec;
ex2_tb_re         <=  ex2_tb_rdec;
ex2_tbu_re        <=  ex2_tbu_rdec;
ex2_tenc_re       <=  ex2_tenc_rdec;
ex2_tens_re       <=  ex2_tens_rdec;
ex2_tensr_re      <=  ex2_tensr_rdec;
ex2_tir_re        <=  ex2_tir_rdec;
ex2_xucr0_re      <=  ex2_xucr0_rdec;
ex2_xucr3_re      <=  ex2_xucr3_rdec;
ex2_xucr4_re      <=  ex2_xucr4_rdec;

readmux_00 : if a2mode = 0 and hvmode = 0 generate
ex2_cspr_rt <=
	(ccr0_do(DO'range)        and (DO'range => ex2_ccr0_re    )) or
	(ccr1_do(DO'range)        and (DO'range => ex2_ccr1_re    )) or
	(ccr2_do(DO'range)        and (DO'range => ex2_ccr2_re    )) or
	(pir_do(DO'range)         and (DO'range => ex2_pir_re     )) or
	(pvr_do(DO'range)         and (DO'range => ex2_pvr_re     )) or
	(tb_do(DO'range)          and (DO'range => ex2_tb_re      )) or
	(tbu_do(DO'range)         and (DO'range => ex2_tbu_re     )) or
	(tenc_do(DO'range)        and (DO'range => ex2_tenc_re    )) or
	(tens_do(DO'range)        and (DO'range => ex2_tens_re    )) or
	(tensr_do(DO'range)       and (DO'range => ex2_tensr_re   )) or
	(tir_do(DO'range)         and (DO'range => ex2_tir_re     )) or
	(xucr0_do(DO'range)       and (DO'range => ex2_xucr0_re   ));
end generate;
readmux_01 : if a2mode = 0 and hvmode = 1 generate
ex2_cspr_rt <=
	(ccr0_do(DO'range)        and (DO'range => ex2_ccr0_re    )) or
	(ccr1_do(DO'range)        and (DO'range => ex2_ccr1_re    )) or
	(ccr2_do(DO'range)        and (DO'range => ex2_ccr2_re    )) or
	(pir_do(DO'range)         and (DO'range => ex2_pir_re     )) or
	(pvr_do(DO'range)         and (DO'range => ex2_pvr_re     )) or
	(tb_do(DO'range)          and (DO'range => ex2_tb_re      )) or
	(tbu_do(DO'range)         and (DO'range => ex2_tbu_re     )) or
	(tenc_do(DO'range)        and (DO'range => ex2_tenc_re    )) or
	(tens_do(DO'range)        and (DO'range => ex2_tens_re    )) or
	(tensr_do(DO'range)       and (DO'range => ex2_tensr_re   )) or
	(tir_do(DO'range)         and (DO'range => ex2_tir_re     )) or
	(xucr0_do(DO'range)       and (DO'range => ex2_xucr0_re   ));
end generate;
readmux_10 : if a2mode = 1 and hvmode = 0 generate
ex2_cspr_rt <=
	(ccr0_do(DO'range)        and (DO'range => ex2_ccr0_re    )) or
	(ccr1_do(DO'range)        and (DO'range => ex2_ccr1_re    )) or
	(ccr2_do(DO'range)        and (DO'range => ex2_ccr2_re    )) or
	(pir_do(DO'range)         and (DO'range => ex2_pir_re     )) or
	(pvr_do(DO'range)         and (DO'range => ex2_pvr_re     )) or
	(tb_do(DO'range)          and (DO'range => ex2_tb_re      )) or
	(tbu_do(DO'range)         and (DO'range => ex2_tbu_re     )) or
	(tenc_do(DO'range)        and (DO'range => ex2_tenc_re    )) or
	(tens_do(DO'range)        and (DO'range => ex2_tens_re    )) or
	(tensr_do(DO'range)       and (DO'range => ex2_tensr_re   )) or
	(tir_do(DO'range)         and (DO'range => ex2_tir_re     )) or
	(xucr0_do(DO'range)       and (DO'range => ex2_xucr0_re   ));
end generate;
readmux_11 : if a2mode = 1 and hvmode = 1 generate
ex2_cspr_rt <=
	(ccr0_do(DO'range)        and (DO'range => ex2_ccr0_re    )) or
	(ccr1_do(DO'range)        and (DO'range => ex2_ccr1_re    )) or
	(ccr2_do(DO'range)        and (DO'range => ex2_ccr2_re    )) or
	(pir_do(DO'range)         and (DO'range => ex2_pir_re     )) or
	(pvr_do(DO'range)         and (DO'range => ex2_pvr_re     )) or
	(tb_do(DO'range)          and (DO'range => ex2_tb_re      )) or
	(tbu_do(DO'range)         and (DO'range => ex2_tbu_re     )) or
	(tenc_do(DO'range)        and (DO'range => ex2_tenc_re    )) or
	(tens_do(DO'range)        and (DO'range => ex2_tens_re    )) or
	(tensr_do(DO'range)       and (DO'range => ex2_tensr_re   )) or
	(tir_do(DO'range)         and (DO'range => ex2_tir_re     )) or
	(xucr0_do(DO'range)       and (DO'range => ex2_xucr0_re   ));
end generate;

-- Fast SPR Write
ex6_ccr0_wdec     <= (ex6_instr(11 to 20) = "1000011111");   -- 1008
ex6_ccr1_wdec     <= (ex6_instr(11 to 20) = "1000111111");   -- 1009
ex6_ccr2_wdec     <= (ex6_instr(11 to 20) = "1001011111");   -- 1010
ex6_tbl_wdec      <= (ex6_instr(11 to 20) = "1110001000");   --  284
ex6_tbu_wdec      <= ((ex6_instr(11 to 20) = "1110101000"));  --  285
ex6_tenc_wdec     <= (ex6_instr(11 to 20) = "1011101101");   --  439
ex6_tens_wdec     <= (ex6_instr(11 to 20) = "1011001101");   --  438
ex6_xucr0_wdec    <= (ex6_instr(11 to 20) = "1011011111");   -- 1014
ex6_ccr0_we       <= ex6_val and ex6_is_mtspr and  ex6_ccr0_wdec;
ex6_ccr1_we       <= ex6_val and ex6_is_mtspr and  ex6_ccr1_wdec;
ex6_ccr2_we       <= ex6_val and ex6_is_mtspr and  ex6_ccr2_wdec;
ex6_tbl_we        <= ex6_val and ex6_is_mtspr and  ex6_tbl_wdec;
ex6_tbu_we        <= ex6_val and ex6_is_mtspr and  ex6_tbu_wdec;
ex6_tenc_we       <= ex6_val and ex6_is_mtspr and  ex6_tenc_wdec;
ex6_tens_we       <= ex6_val and ex6_is_mtspr and  ex6_tens_wdec;
ex6_xucr0_we      <= ex6_val and ex6_is_mtspr and  ex6_xucr0_wdec;

-- Array Read
rf1_gsprg0_rdec   <= (rf1_instr(11 to 20) = "1000001011");   --  368
rf1_gsprg1_rdec   <= (rf1_instr(11 to 20) = "1000101011");   --  369
rf1_gsprg2_rdec   <= (rf1_instr(11 to 20) = "1001001011");   --  370
rf1_gsprg3_rdec   <= (rf1_instr(11 to 20) = "1001101011");   --  371
rf1_sprg0_rdec    <= (rf1_instr(11 to 20) = "1000001000");   --  272
rf1_sprg1_rdec    <= (rf1_instr(11 to 20) = "1000101000");   --  273
rf1_sprg2_rdec    <= (rf1_instr(11 to 20) = "1001001000");   --  274
rf1_sprg3_rdec    <= ((rf1_instr(11 to 20) = "1001101000") or --  275
                     (rf1_instr(11 to 20) = "0001101000"));  --  259
rf1_sprg4_rdec    <= ((rf1_instr(11 to 20) = "1010001000") or --  276
                     (rf1_instr(11 to 20) = "0010001000"));  --  260
rf1_sprg5_rdec    <= ((rf1_instr(11 to 20) = "1010101000") or --  277
                     (rf1_instr(11 to 20) = "0010101000"));  --  261
rf1_sprg6_rdec    <= ((rf1_instr(11 to 20) = "1011001000") or --  278
                     (rf1_instr(11 to 20) = "0011001000"));  --  262
rf1_sprg7_rdec    <= ((rf1_instr(11 to 20) = "1011101000") or --  279
                     (rf1_instr(11 to 20) = "0011101000"));  --  263
rf1_sprg8_rdec    <= (rf1_instr(11 to 20) = "1110010010");   --  604
rf1_vrsave_rdec   <= (rf1_instr(11 to 20) = "0000001000");   --  256
rf1_gsprg0_re     <= (rf1_gsprg0_rdec    or (rf1_sprg0_rdec and rf1_msr_gs_q));
rf1_gsprg1_re     <= (rf1_gsprg1_rdec    or (rf1_sprg1_rdec and rf1_msr_gs_q));
rf1_gsprg2_re     <= (rf1_gsprg2_rdec    or (rf1_sprg2_rdec and rf1_msr_gs_q));
rf1_gsprg3_re     <= (rf1_gsprg3_rdec    or (rf1_sprg3_rdec and rf1_msr_gs_q));
rf1_sprg0_re      <=  rf1_sprg0_rdec     and not rf1_msr_gs_q;
rf1_sprg1_re      <=  rf1_sprg1_rdec     and not rf1_msr_gs_q;
rf1_sprg2_re      <=  rf1_sprg2_rdec     and not rf1_msr_gs_q;
rf1_sprg3_re      <=  rf1_sprg3_rdec     and not rf1_msr_gs_q;
rf1_sprg4_re      <=  rf1_sprg4_rdec;
rf1_sprg5_re      <=  rf1_sprg5_rdec;
rf1_sprg6_re      <=  rf1_sprg6_rdec;
rf1_sprg7_re      <=  rf1_sprg7_rdec;
rf1_sprg8_re      <=  rf1_sprg8_rdec;
rf1_vrsave_re     <=  rf1_vrsave_rdec;

rf1_aspr_re(1) <= rf1_is_mfspr and (
                              rf1_gsprg0_re        or rf1_gsprg1_re        or rf1_gsprg2_re        
                           or rf1_gsprg3_re        or rf1_sprg0_re         or rf1_sprg1_re         
                           or rf1_sprg2_re         or rf1_sprg3_re         or rf1_sprg4_re         
                           or rf1_sprg5_re         or rf1_sprg6_re         or rf1_sprg7_re         
                           or rf1_sprg8_re         or rf1_vrsave_re        );

rf1_aspr_re0_gen : if regsize > 32 generate
rf1_aspr_re(0) <= rf1_aspr_re(1) and not ( 
                              rf1_vrsave_re        );
end generate;

rf1_aspr_addr	<=
	("0000" and (0 to 3=> rf1_gsprg0_re           )) or
	("0001" and (0 to 3=> rf1_gsprg1_re           )) or
	("0010" and (0 to 3=> rf1_gsprg2_re           )) or
	("0011" and (0 to 3=> rf1_gsprg3_re           )) or
	("0100" and (0 to 3=> rf1_sprg0_re            )) or
	("0101" and (0 to 3=> rf1_sprg1_re            )) or
	("0110" and (0 to 3=> rf1_sprg2_re            )) or
	("0111" and (0 to 3=> rf1_sprg3_re            )) or
	("1000" and (0 to 3=> rf1_sprg4_re            )) or
	("1001" and (0 to 3=> rf1_sprg5_re            )) or
	("1010" and (0 to 3=> rf1_sprg6_re            )) or
	("1011" and (0 to 3=> rf1_sprg7_re            )) or
	("1100" and (0 to 3=> rf1_sprg8_re            )) or
	("1101" and (0 to 3=> rf1_vrsave_re           ));

-- Array Writes

-- Generate ECC
ex3_sprg_ue    <= ex3_sprg_ue_q and ex3_aspr_re_q(0);
ex3_sprg_ce    <= ex3_sprg_ce_q and ex3_aspr_re_q(0);
ex4_sprg_ce_d  <= (others=>ex3_sprg_ce);

ex4_inj_ecc <= or_reduce(inj_sprg_ecc_q and ex4_tid) and ex4_aspr_we_q and not ex4_sprg_ce_q(0);

ex4_rt      <= (ex4_corr_rdata_q and     fanout(ex4_sprg_ce_q(0 to regsize/8-1),regsize)) or
               (ex4_rt_q         and not fanout(ex4_sprg_ce_q(0 to regsize/8-1),regsize));

ex4_rt_inj(63)                <= ex4_rt(63) xor ex4_inj_ecc;
ex4_rt_inj(64-regsize to 62)  <= ex4_rt(64-regsize to 62);

ex4_eccgen_data   <= ex4_rt & tidn(0 to 8-(64/regsize));

xuq_spr_wr_eccgen : entity work.xuq_eccgen(xuq_eccgen)
generic map(regsize => regsize)
port map(din   => ex4_eccgen_data,
         Syn   => ex4_eccgen_syn);

ex4_is_mfsspr_b   <= not (ex4_sspr_val_q and ex4_is_mfspr_q);

ex5_rt_d       <= gate(ex4_rt_inj,ex4_is_mfsspr_b) & ex4_eccgen_syn;

ex5_aspr_we_d  <= dec_spr_ex4_val and not xu_ex4_flush and (0 to threads-1=>(ex4_aspr_we_q or ex4_sprg_ce_q(0)));

ex3_aspr_we    <= ex3_is_mtspr_q and (
                              ex3_gsprg0_we        or ex3_gsprg1_we        or ex3_gsprg2_we        
                           or ex3_gsprg3_we        or ex3_sprg0_we         or ex3_sprg1_we         
                           or ex3_sprg2_we         or ex3_sprg3_we         or ex3_sprg4_we         
                           or ex3_sprg5_we         or ex3_sprg6_we         or ex3_sprg7_we         
                           or ex3_sprg8_we         or ex3_vrsave_we        );

ex3_gsprg0_wdec   <= (ex3_instr(11 to 20) = "1000001011");   --  368
ex3_gsprg1_wdec   <= (ex3_instr(11 to 20) = "1000101011");   --  369
ex3_gsprg2_wdec   <= (ex3_instr(11 to 20) = "1001001011");   --  370
ex3_gsprg3_wdec   <= (ex3_instr(11 to 20) = "1001101011");   --  371
ex3_sprg0_wdec    <= (ex3_instr(11 to 20) = "1000001000");   --  272
ex3_sprg1_wdec    <= (ex3_instr(11 to 20) = "1000101000");   --  273
ex3_sprg2_wdec    <= (ex3_instr(11 to 20) = "1001001000");   --  274
ex3_sprg3_wdec    <= ((ex3_instr(11 to 20) = "1001101000"));  --  275
ex3_sprg4_wdec    <= ((ex3_instr(11 to 20) = "1010001000"));  --  276
ex3_sprg5_wdec    <= ((ex3_instr(11 to 20) = "1010101000"));  --  277
ex3_sprg6_wdec    <= ((ex3_instr(11 to 20) = "1011001000"));  --  278
ex3_sprg7_wdec    <= ((ex3_instr(11 to 20) = "1011101000"));  --  279
ex3_sprg8_wdec    <= (ex3_instr(11 to 20) = "1110010010");   --  604
ex3_vrsave_wdec   <= (ex3_instr(11 to 20) = "0000001000");   --  256
ex3_gsprg0_we     <= (ex3_gsprg0_wdec    or (ex3_sprg0_wdec and ex3_msr_gs_q));
ex3_gsprg1_we     <= (ex3_gsprg1_wdec    or (ex3_sprg1_wdec and ex3_msr_gs_q));
ex3_gsprg2_we     <= (ex3_gsprg2_wdec    or (ex3_sprg2_wdec and ex3_msr_gs_q));
ex3_gsprg3_we     <= (ex3_gsprg3_wdec    or (ex3_sprg3_wdec and ex3_msr_gs_q));
ex3_sprg0_we      <=  ex3_sprg0_wdec     and not ex3_msr_gs_q;
ex3_sprg1_we      <=  ex3_sprg1_wdec     and not ex3_msr_gs_q;
ex3_sprg2_we      <=  ex3_sprg2_wdec     and not ex3_msr_gs_q;
ex3_sprg3_we      <=  ex3_sprg3_wdec     and not ex3_msr_gs_q;
ex3_sprg4_we      <=  ex3_sprg4_wdec;
ex3_sprg5_we      <=  ex3_sprg5_wdec;
ex3_sprg6_we      <=  ex3_sprg6_wdec;
ex3_sprg7_we      <=  ex3_sprg7_wdec;
ex3_sprg8_we      <=  ex3_sprg8_wdec;
ex3_vrsave_we     <=  ex3_vrsave_wdec;
ex3_aspr_addr	<=
	("0000" and (0 to 3=> ex3_gsprg0_we           )) or
	("0001" and (0 to 3=> ex3_gsprg1_we           )) or
	("0010" and (0 to 3=> ex3_gsprg2_we           )) or
	("0011" and (0 to 3=> ex3_gsprg3_we           )) or
	("0100" and (0 to 3=> ex3_sprg0_we            )) or
	("0101" and (0 to 3=> ex3_sprg1_we            )) or
	("0110" and (0 to 3=> ex3_sprg2_we            )) or
	("0111" and (0 to 3=> ex3_sprg3_we            )) or
	("1000" and (0 to 3=> ex3_sprg4_we            )) or
	("1001" and (0 to 3=> ex3_sprg5_we            )) or
	("1010" and (0 to 3=> ex3_sprg6_we            )) or
	("1011" and (0 to 3=> ex3_sprg7_we            )) or
	("1100" and (0 to 3=> ex3_sprg8_we            )) or
	("1101" and (0 to 3=> ex3_vrsave_we           ));

with ex4_sprg_ce_q(regsize/8) select
   ex5_aspr_addr_d      <= ex4_aspr_ce_addr_q   when '1',
                           ex4_aspr_addr_q      when others;
                           
-- Slow SPR
ex2_dvc1_rdec     <= (ex2_instr(11 to 20) = "1111001001");   --  318
ex2_dvc2_rdec     <= (ex2_instr(11 to 20) = "1111101001");   --  319
ex2_eplc_rdec     <= (ex2_instr(11 to 20) = "1001111101");   --  947
ex2_epsc_rdec     <= (ex2_instr(11 to 20) = "1010011101");   --  948
ex2_eptcfg_rdec   <= (ex2_instr(11 to 20) = "1111001010");   --  350
ex2_immr_rdec     <= (ex2_instr(11 to 20) = "1000111011");   --  881
ex2_imr_rdec      <= (ex2_instr(11 to 20) = "1000011011");   --  880
ex2_iucr0_rdec    <= (ex2_instr(11 to 20) = "1001111111");   -- 1011
ex2_iucr1_rdec    <= (ex2_instr(11 to 20) = "1001111011");   --  883
ex2_iucr2_rdec    <= (ex2_instr(11 to 20) = "1010011011");   --  884
ex2_iudbg0_rdec   <= (ex2_instr(11 to 20) = "1100011011");   --  888
ex2_iudbg1_rdec   <= (ex2_instr(11 to 20) = "1100111011");   --  889
ex2_iudbg2_rdec   <= (ex2_instr(11 to 20) = "1101011011");   --  890
ex2_iulfsr_rdec   <= (ex2_instr(11 to 20) = "1101111011");   --  891
ex2_iullcr_rdec   <= (ex2_instr(11 to 20) = "1110011011");   --  892
ex2_lper_rdec     <= (ex2_instr(11 to 20) = "1100000001");   --   56
ex2_lperu_rdec    <= (ex2_instr(11 to 20) = "1100100001");   --   57
ex2_lpidr_rdec    <= (ex2_instr(11 to 20) = "1001001010");   --  338
ex2_lratcfg_rdec  <= (ex2_instr(11 to 20) = "1011001010");   --  342
ex2_lratps_rdec   <= (ex2_instr(11 to 20) = "1011101010");   --  343
ex2_mas0_rdec     <= (ex2_instr(11 to 20) = "1000010011");   --  624
ex2_mas0_mas1_rdec<= (ex2_instr(11 to 20) = "1010101011");   --  373
ex2_mas1_rdec     <= (ex2_instr(11 to 20) = "1000110011");   --  625
ex2_mas2_rdec     <= (ex2_instr(11 to 20) = "1001010011");   --  626
ex2_mas2u_rdec    <= (ex2_instr(11 to 20) = "1011110011");   --  631
ex2_mas3_rdec     <= (ex2_instr(11 to 20) = "1001110011");   --  627
ex2_mas4_rdec     <= (ex2_instr(11 to 20) = "1010010011");   --  628
ex2_mas5_rdec     <= (ex2_instr(11 to 20) = "1001101010");   --  339
ex2_mas5_mas6_rdec<= (ex2_instr(11 to 20) = "1110001010");   --  348
ex2_mas6_rdec     <= (ex2_instr(11 to 20) = "1011010011");   --  630
ex2_mas7_rdec     <= (ex2_instr(11 to 20) = "1000011101");   --  944
ex2_mas7_mas3_rdec<= (ex2_instr(11 to 20) = "1010001011");   --  372
ex2_mas8_rdec     <= (ex2_instr(11 to 20) = "1010101010");   --  341
ex2_mas8_mas1_rdec<= (ex2_instr(11 to 20) = "1110101010");   --  349
ex2_mmucfg_rdec   <= (ex2_instr(11 to 20) = "1011111111");   -- 1015
ex2_mmucr0_rdec   <= (ex2_instr(11 to 20) = "1110011111");   -- 1020
ex2_mmucr1_rdec   <= (ex2_instr(11 to 20) = "1110111111");   -- 1021
ex2_mmucr2_rdec   <= (ex2_instr(11 to 20) = "1111011111");   -- 1022
ex2_mmucr3_rdec   <= (ex2_instr(11 to 20) = "1111111111");   -- 1023
ex2_mmucsr0_rdec  <= (ex2_instr(11 to 20) = "1010011111");   -- 1012
ex2_pid_rdec      <= (ex2_instr(11 to 20) = "1000000001");   --   48
ex2_ppr32_rdec    <= (ex2_instr(11 to 20) = "0001011100");   --  898
ex2_tlb0cfg_rdec  <= (ex2_instr(11 to 20) = "1000010101");   --  688
ex2_tlb0ps_rdec   <= (ex2_instr(11 to 20) = "1100001010");   --  344
ex2_xucr2_rdec    <= (ex2_instr(11 to 20) = "1100011111");   -- 1016
ex2_xudbg0_rdec   <= (ex2_instr(11 to 20) = "1010111011");   --  885
ex2_xudbg1_rdec   <= (ex2_instr(11 to 20) = "1011011011");   --  886
ex2_xudbg2_rdec   <= (ex2_instr(11 to 20) = "1011111011");   --  887
ex2_dvc1_re       <=  ex2_dvc1_rdec;
ex2_dvc2_re       <=  ex2_dvc2_rdec;
ex2_eplc_re       <=  ex2_eplc_rdec;
ex2_epsc_re       <=  ex2_epsc_rdec;
ex2_eptcfg_re     <=  ex2_eptcfg_rdec;
ex2_immr_re       <=  ex2_immr_rdec;
ex2_imr_re        <=  ex2_imr_rdec;
ex2_iucr0_re      <=  ex2_iucr0_rdec;
ex2_iucr1_re      <=  ex2_iucr1_rdec;
ex2_iucr2_re      <=  ex2_iucr2_rdec;
ex2_iudbg0_re     <=  ex2_iudbg0_rdec;
ex2_iudbg1_re     <=  ex2_iudbg1_rdec;
ex2_iudbg2_re     <=  ex2_iudbg2_rdec;
ex2_iulfsr_re     <=  ex2_iulfsr_rdec;
ex2_iullcr_re     <=  ex2_iullcr_rdec;
ex2_lper_re       <=  ex2_lper_rdec;
ex2_lperu_re      <=  ex2_lperu_rdec;
ex2_lpidr_re      <=  ex2_lpidr_rdec;
ex2_lratcfg_re    <=  ex2_lratcfg_rdec;
ex2_lratps_re     <=  ex2_lratps_rdec;
ex2_mas0_re       <=  ex2_mas0_rdec;
ex2_mas0_mas1_re  <=  ex2_mas0_mas1_rdec;
ex2_mas1_re       <=  ex2_mas1_rdec;
ex2_mas2_re       <=  ex2_mas2_rdec;
ex2_mas2u_re      <=  ex2_mas2u_rdec;
ex2_mas3_re       <=  ex2_mas3_rdec;
ex2_mas4_re       <=  ex2_mas4_rdec;
ex2_mas5_re       <=  ex2_mas5_rdec;
ex2_mas5_mas6_re  <=  ex2_mas5_mas6_rdec;
ex2_mas6_re       <=  ex2_mas6_rdec;
ex2_mas7_re       <=  ex2_mas7_rdec;
ex2_mas7_mas3_re  <=  ex2_mas7_mas3_rdec;
ex2_mas8_re       <=  ex2_mas8_rdec;
ex2_mas8_mas1_re  <=  ex2_mas8_mas1_rdec;
ex2_mmucfg_re     <=  ex2_mmucfg_rdec;
ex2_mmucr0_re     <=  ex2_mmucr0_rdec;
ex2_mmucr1_re     <=  ex2_mmucr1_rdec;
ex2_mmucr2_re     <=  ex2_mmucr2_rdec;
ex2_mmucr3_re     <=  ex2_mmucr3_rdec;
ex2_mmucsr0_re    <=  ex2_mmucsr0_rdec;
ex2_pid_re        <=  ex2_pid_rdec;
ex2_ppr32_re      <=  ex2_ppr32_rdec;
ex2_tlb0cfg_re    <=  ex2_tlb0cfg_rdec;
ex2_tlb0ps_re     <=  ex2_tlb0ps_rdec;
ex2_xucr2_re      <=  ex2_xucr2_rdec;
ex2_xudbg0_re     <=  ex2_xudbg0_rdec;
ex2_xudbg1_re     <=  ex2_xudbg1_rdec;
ex2_xudbg2_re     <=  ex2_xudbg2_rdec;
ex2_dvc1_wdec     <= ex2_dvc1_rdec;
ex2_dvc2_wdec     <= ex2_dvc2_rdec;
ex2_eplc_wdec     <= ex2_eplc_rdec;
ex2_epsc_wdec     <= ex2_epsc_rdec;
ex2_immr_wdec     <= ex2_immr_rdec;
ex2_imr_wdec      <= ex2_imr_rdec;
ex2_iucr0_wdec    <= ex2_iucr0_rdec;
ex2_iucr1_wdec    <= ex2_iucr1_rdec;
ex2_iucr2_wdec    <= ex2_iucr2_rdec;
ex2_iudbg0_wdec   <= ex2_iudbg0_rdec;
ex2_iulfsr_wdec   <= ex2_iulfsr_rdec;
ex2_iullcr_wdec   <= ex2_iullcr_rdec;
ex2_lper_wdec     <= ex2_lper_rdec;
ex2_lperu_wdec    <= ex2_lperu_rdec;
ex2_lpidr_wdec    <= ex2_lpidr_rdec;
ex2_mas0_wdec     <= ex2_mas0_rdec;
ex2_mas0_mas1_wdec<= ex2_mas0_mas1_rdec;
ex2_mas1_wdec     <= ex2_mas1_rdec;
ex2_mas2_wdec     <= ex2_mas2_rdec;
ex2_mas2u_wdec    <= ex2_mas2u_rdec;
ex2_mas3_wdec     <= ex2_mas3_rdec;
ex2_mas4_wdec     <= ex2_mas4_rdec;
ex2_mas5_wdec     <= ex2_mas5_rdec;
ex2_mas5_mas6_wdec<= ex2_mas5_mas6_rdec;
ex2_mas6_wdec     <= ex2_mas6_rdec;
ex2_mas7_wdec     <= ex2_mas7_rdec;
ex2_mas7_mas3_wdec<= ex2_mas7_mas3_rdec;
ex2_mas8_wdec     <= ex2_mas8_rdec;
ex2_mas8_mas1_wdec<= ex2_mas8_mas1_rdec;
ex2_mmucr0_wdec   <= ex2_mmucr0_rdec;
ex2_mmucr1_wdec   <= ex2_mmucr1_rdec;
ex2_mmucr2_wdec   <= ex2_mmucr2_rdec;
ex2_mmucr3_wdec   <= ex2_mmucr3_rdec;
ex2_mmucsr0_wdec  <= ex2_mmucsr0_rdec;
ex2_pid_wdec      <= ex2_pid_rdec;
ex2_ppr32_wdec    <= ex2_ppr32_rdec;
ex2_xucr2_wdec    <= ex2_xucr2_rdec;
ex2_xudbg0_wdec   <= ex2_xudbg0_rdec;
ex2_dvc1_we       <=  ex2_dvc1_wdec;
ex2_dvc2_we       <=  ex2_dvc2_wdec;
ex2_eplc_we       <=  ex2_eplc_wdec;
ex2_epsc_we       <=  ex2_epsc_wdec;
ex2_immr_we       <=  ex2_immr_wdec;
ex2_imr_we        <=  ex2_imr_wdec;
ex2_iucr0_we      <=  ex2_iucr0_wdec;
ex2_iucr1_we      <=  ex2_iucr1_wdec;
ex2_iucr2_we      <=  ex2_iucr2_wdec;
ex2_iudbg0_we     <=  ex2_iudbg0_wdec;
ex2_iulfsr_we     <=  ex2_iulfsr_wdec;
ex2_iullcr_we     <=  ex2_iullcr_wdec;
ex2_lper_we       <=  ex2_lper_wdec;
ex2_lperu_we      <=  ex2_lperu_wdec;
ex2_lpidr_we      <=  ex2_lpidr_wdec;
ex2_mas0_we       <=  ex2_mas0_wdec;
ex2_mas0_mas1_we  <=  ex2_mas0_mas1_wdec;
ex2_mas1_we       <=  ex2_mas1_wdec;
ex2_mas2_we       <=  ex2_mas2_wdec;
ex2_mas2u_we      <=  ex2_mas2u_wdec;
ex2_mas3_we       <=  ex2_mas3_wdec;
ex2_mas4_we       <=  ex2_mas4_wdec;
ex2_mas5_we       <=  ex2_mas5_wdec;
ex2_mas5_mas6_we  <=  ex2_mas5_mas6_wdec;
ex2_mas6_we       <=  ex2_mas6_wdec;
ex2_mas7_we       <=  ex2_mas7_wdec;
ex2_mas7_mas3_we  <=  ex2_mas7_mas3_wdec;
ex2_mas8_we       <=  ex2_mas8_wdec;
ex2_mas8_mas1_we  <=  ex2_mas8_mas1_wdec;
ex2_mmucr0_we     <=  ex2_mmucr0_wdec;
ex2_mmucr1_we     <=  ex2_mmucr1_wdec;
ex2_mmucr2_we     <=  ex2_mmucr2_wdec;
ex2_mmucr3_we     <=  ex2_mmucr3_wdec;
ex2_mmucsr0_we    <=  ex2_mmucsr0_wdec;
ex2_pid_we        <=  ex2_pid_wdec;
ex2_ppr32_we      <=  ex2_ppr32_wdec;
ex2_xucr2_we      <=  ex2_xucr2_wdec;
ex2_xudbg0_we     <=  ex2_xudbg0_wdec;
ex2_slowspr_range_hypv  <= ex2_instr(11) and ex2_instr(16 to 20) = "11110";   -- 976-991
ex2_slowspr_range_priv  <= ex2_instr(11) and ex2_instr(16 to 20) = "11100";   -- 912-927
ex2_slowspr_range       <= ex2_slowspr_range_priv or ex2_slowspr_range_hypv;

-- mftb encode is only legal for tbr=268,269                        --  "0110-01000"
ex2_illeg_mftb          <= ex2_is_mftb_q and not (ex2_instr(11 to 14) = "0110" and
                                                  ex2_instr(16 to 20) =      "01000");
 
ex2_sspr_val   <=(ex2_is_mtspr_q and (ex2_slowspr_range or
                              ex2_dvc1_we          or ex2_dvc2_we          or ex2_eplc_we          
                           or ex2_epsc_we          or ex2_immr_we          or ex2_imr_we           
                           or ex2_iucr0_we         or ex2_iucr1_we         or ex2_iucr2_we         
                           or ex2_iudbg0_we        or ex2_iulfsr_we        or ex2_iullcr_we        
                           or ex2_lper_we          or ex2_lperu_we         or ex2_lpidr_we         
                           or ex2_mas0_we          or ex2_mas0_mas1_we     or ex2_mas1_we          
                           or ex2_mas2_we          or ex2_mas2u_we         or ex2_mas3_we          
                           or ex2_mas4_we          or ex2_mas5_we          or ex2_mas5_mas6_we     
                           or ex2_mas6_we          or ex2_mas7_we          or ex2_mas7_mas3_we     
                           or ex2_mas8_we          or ex2_mas8_mas1_we     or ex2_mmucr0_we        
                           or ex2_mmucr1_we        or ex2_mmucr2_we        or ex2_mmucr3_we        
                           or ex2_mmucsr0_we       or ex2_pid_we           or ex2_ppr32_we         
                           or ex2_xucr2_we         or ex2_xudbg0_we        )) or
                 (ex2_is_mfspr_q and (ex2_slowspr_range or
                              ex2_dvc1_re          or ex2_dvc2_re          or ex2_eplc_re          
                           or ex2_epsc_re          or ex2_eptcfg_re        or ex2_immr_re          
                           or ex2_imr_re           or ex2_iucr0_re         or ex2_iucr1_re         
                           or ex2_iucr2_re         or ex2_iudbg0_re        or ex2_iudbg1_re        
                           or ex2_iudbg2_re        or ex2_iulfsr_re        or ex2_iullcr_re        
                           or ex2_lper_re          or ex2_lperu_re         or ex2_lpidr_re         
                           or ex2_lratcfg_re       or ex2_lratps_re        or ex2_mas0_re          
                           or ex2_mas0_mas1_re     or ex2_mas1_re          or ex2_mas2_re          
                           or ex2_mas2u_re         or ex2_mas3_re          or ex2_mas4_re          
                           or ex2_mas5_re          or ex2_mas5_mas6_re     or ex2_mas6_re          
                           or ex2_mas7_re          or ex2_mas7_mas3_re     or ex2_mas8_re          
                           or ex2_mas8_mas1_re     or ex2_mmucfg_re        or ex2_mmucr0_re        
                           or ex2_mmucr1_re        or ex2_mmucr2_re        or ex2_mmucr3_re        
                           or ex2_mmucsr0_re       or ex2_pid_re           or ex2_ppr32_re         
                           or ex2_tlb0cfg_re       or ex2_tlb0ps_re        or ex2_xucr2_re         
                           or ex2_xudbg0_re        or ex2_xudbg1_re        or ex2_xudbg2_re        ));

-- Illegal SPR checks
ex2_gsprg0_rdec   <= (ex2_instr(11 to 20) = "1000001011");   --  368
ex2_gsprg1_rdec   <= (ex2_instr(11 to 20) = "1000101011");   --  369
ex2_gsprg2_rdec   <= (ex2_instr(11 to 20) = "1001001011");   --  370
ex2_gsprg3_rdec   <= (ex2_instr(11 to 20) = "1001101011");   --  371
ex2_sprg0_rdec    <= (ex2_instr(11 to 20) = "1000001000");   --  272
ex2_sprg1_rdec    <= (ex2_instr(11 to 20) = "1000101000");   --  273
ex2_sprg2_rdec    <= (ex2_instr(11 to 20) = "1001001000");   --  274
ex2_sprg3_rdec    <= ((ex2_instr(11 to 20) = "1001101000") or --  275
                     (ex2_instr(11 to 20) = "0001101000"));  --  259
ex2_sprg4_rdec    <= ((ex2_instr(11 to 20) = "1010001000") or --  276
                     (ex2_instr(11 to 20) = "0010001000"));  --  260
ex2_sprg5_rdec    <= ((ex2_instr(11 to 20) = "1010101000") or --  277
                     (ex2_instr(11 to 20) = "0010101000"));  --  261
ex2_sprg6_rdec    <= ((ex2_instr(11 to 20) = "1011001000") or --  278
                     (ex2_instr(11 to 20) = "0011001000"));  --  262
ex2_sprg7_rdec    <= ((ex2_instr(11 to 20) = "1011101000") or --  279
                     (ex2_instr(11 to 20) = "0011101000"));  --  263
ex2_sprg8_rdec    <= (ex2_instr(11 to 20) = "1110010010");   --  604
ex2_vrsave_rdec   <= (ex2_instr(11 to 20) = "0000001000");   --  256
ex2_gsprg0_wdec   <= (ex2_instr(11 to 20) = "1000001011");   --  368
ex2_gsprg1_wdec   <= (ex2_instr(11 to 20) = "1000101011");   --  369
ex2_gsprg2_wdec   <= (ex2_instr(11 to 20) = "1001001011");   --  370
ex2_gsprg3_wdec   <= (ex2_instr(11 to 20) = "1001101011");   --  371
ex2_sprg0_wdec    <= (ex2_instr(11 to 20) = "1000001000");   --  272
ex2_sprg1_wdec    <= (ex2_instr(11 to 20) = "1000101000");   --  273
ex2_sprg2_wdec    <= (ex2_instr(11 to 20) = "1001001000");   --  274
ex2_sprg3_wdec    <= ((ex2_instr(11 to 20) = "1001101000"));  --  275
ex2_sprg4_wdec    <= ((ex2_instr(11 to 20) = "1010001000"));  --  276
ex2_sprg5_wdec    <= ((ex2_instr(11 to 20) = "1010101000"));  --  277
ex2_sprg6_wdec    <= ((ex2_instr(11 to 20) = "1011001000"));  --  278
ex2_sprg7_wdec    <= ((ex2_instr(11 to 20) = "1011101000"));  --  279
ex2_sprg8_wdec    <= (ex2_instr(11 to 20) = "1110010010");   --  604
ex2_vrsave_wdec   <= (ex2_instr(11 to 20) = "0000001000");   --  256
ex2_sprg8_re      <=  ex2_sprg8_rdec;
ex2_sprg8_we      <=  ex2_sprg8_wdec;
ex2_ccr0_wdec     <= ex2_ccr0_rdec;
ex2_ccr1_wdec     <= ex2_ccr1_rdec;
ex2_ccr2_wdec     <= ex2_ccr2_rdec;
ex2_dac1_wdec     <= ex2_dac1_rdec;
ex2_dac2_wdec     <= ex2_dac2_rdec;
ex2_dac3_wdec     <= ex2_dac3_rdec;
ex2_dac4_wdec     <= ex2_dac4_rdec;
ex2_givpr_wdec    <= (ex2_instr(11 to 20) = "1111101101");   --  447
ex2_iac1_wdec     <= ex2_iac1_rdec;
ex2_iac2_wdec     <= ex2_iac2_rdec;
ex2_iac3_wdec     <= ex2_iac3_rdec;
ex2_iac4_wdec     <= ex2_iac4_rdec;
ex2_ivpr_wdec     <= ex2_ivpr_rdec;
ex2_tbl_wdec      <= (ex2_instr(11 to 20) = "1110001000");   --  284
ex2_tbu_wdec      <= ((ex2_instr(11 to 20) = "1110101000"));  --  285
ex2_tenc_wdec     <= ex2_tenc_rdec;
ex2_tens_wdec     <= ex2_tens_rdec;
ex2_trace_wdec    <= (ex2_instr(11 to 20) = "0111011111");   -- 1006
ex2_xucr0_wdec    <= ex2_xucr0_rdec;
ex2_xucr3_wdec    <= ex2_xucr3_rdec;
ex2_xucr4_wdec    <= ex2_xucr4_rdec;
ex2_ccr0_we       <=  ex2_ccr0_wdec;
ex2_ccr1_we       <=  ex2_ccr1_wdec;
ex2_ccr2_we       <=  ex2_ccr2_wdec;
ex2_dac1_we       <=  ex2_dac1_wdec;
ex2_dac2_we       <=  ex2_dac2_wdec;
ex2_dac3_we       <=  ex2_dac3_wdec;
ex2_dac4_we       <=  ex2_dac4_wdec;
ex2_givpr_we      <=  ex2_givpr_wdec;
ex2_iac1_we       <=  ex2_iac1_wdec;
ex2_iac2_we       <=  ex2_iac2_wdec;
ex2_iac3_we       <=  ex2_iac3_wdec;
ex2_iac4_we       <=  ex2_iac4_wdec;
ex2_ivpr_we       <=  ex2_ivpr_wdec;
ex2_tbl_we        <=  ex2_tbl_wdec;
ex2_tbu_we        <=  ex2_tbu_wdec;
ex2_tenc_we       <=  ex2_tenc_wdec;
ex2_tens_we       <=  ex2_tens_wdec;
ex2_trace_we      <=  ex2_trace_wdec;
ex2_xucr0_we      <=  ex2_xucr0_wdec;
ex2_xucr3_we      <=  ex2_xucr3_wdec;
ex2_xucr4_we      <=  ex2_xucr4_wdec;


ill_spr_00 : if a2mode = 0 and hvmode = 0 generate
ex2_illeg_mfspr <= ex2_is_mfspr_q and not (
                              ex2_ccr0_rdec        or ex2_ccr1_rdec        or ex2_ccr2_rdec        
                           or ex2_dac3_rdec        or ex2_dac4_rdec        or ex2_iac1_rdec        
                           or ex2_iac2_rdec        or ex2_ivpr_rdec        or ex2_pir_rdec         
                           or ex2_pvr_rdec         or ex2_tb_rdec          or ex2_tbu_rdec         
                           or ex2_tenc_rdec        or ex2_tens_rdec        or ex2_tensr_rdec       
                           or ex2_tir_rdec         or ex2_xucr0_rdec       or ex2_xucr3_rdec       
                           or ex2_xucr4_rdec       or
                              ex2_sprg0_rdec       or ex2_sprg1_rdec       or ex2_sprg2_rdec       
                           or ex2_sprg3_rdec       or ex2_sprg4_rdec       or ex2_sprg5_rdec       
                           or ex2_sprg6_rdec       or ex2_sprg7_rdec       or ex2_sprg8_rdec       
                           or ex2_vrsave_rdec      or
                              ex2_iucr0_rdec       or ex2_iucr1_rdec       or ex2_iucr2_rdec       
                           or ex2_iudbg0_rdec      or ex2_iudbg1_rdec      or ex2_iudbg2_rdec      
                           or ex2_iulfsr_rdec      or ex2_iullcr_rdec      or ex2_lpidr_rdec       
                           or ex2_pid_rdec         or ex2_ppr32_rdec       or ex2_xucr2_rdec       
                           or ex2_xudbg0_rdec      or ex2_xudbg1_rdec      or ex2_xudbg2_rdec      or
                              ex2_slowspr_range or
                           or_reduce(tspr_cspr_illeg_mfspr_b and ex2_tid));

ex2_illeg_mtspr <= ex2_is_mtspr_q and not (
                              ex2_ccr0_wdec        or ex2_ccr1_wdec        or ex2_ccr2_wdec        
                           or ex2_dac3_wdec        or ex2_dac4_wdec        or ex2_iac1_wdec        
                           or ex2_iac2_wdec        or ex2_ivpr_wdec        or ex2_tbl_wdec         
                           or ex2_tbu_wdec         or ex2_tenc_wdec        or ex2_tens_wdec        
                           or ex2_trace_wdec       or ex2_xucr0_wdec       or ex2_xucr3_wdec       
                           or ex2_xucr4_wdec       or
                              ex2_sprg0_wdec       or ex2_sprg1_wdec       or ex2_sprg2_wdec       
                           or ex2_sprg3_wdec       or ex2_sprg4_wdec       or ex2_sprg5_wdec       
                           or ex2_sprg6_wdec       or ex2_sprg7_wdec       or ex2_sprg8_wdec       
                           or ex2_vrsave_wdec      or
                              ex2_iucr0_wdec       or ex2_iucr1_wdec       or ex2_iucr2_wdec       
                           or ex2_iudbg0_wdec      or ex2_iulfsr_wdec      or ex2_iullcr_wdec      
                           or ex2_lpidr_wdec       or ex2_pid_wdec         or ex2_ppr32_wdec       
                           or ex2_xucr2_wdec       or ex2_xudbg0_wdec      or
                              ex2_slowspr_range or
                           or_reduce(tspr_cspr_illeg_mtspr_b and ex2_tid));

ex2_hypv_mfspr <= ex2_is_mfspr_q and (
                              ex2_ccr0_re          or ex2_ccr1_re          or ex2_ccr2_re          
                           or ex2_dac3_re          or ex2_dac4_re          or ex2_iac1_re          
                           or ex2_iac2_re          or ex2_ivpr_re          or ex2_tenc_re          
                           or ex2_tens_re          or ex2_tensr_re         or ex2_tir_re           
                           or ex2_xucr0_re         or ex2_xucr3_re         or ex2_xucr4_re         or
                              ex2_sprg8_re         or
                              ex2_iucr0_re         or ex2_iucr1_re         or ex2_iucr2_re         
                           or ex2_iudbg0_re        or ex2_iudbg1_re        or ex2_iudbg2_re        
                           or ex2_iulfsr_re        or ex2_iullcr_re        or ex2_lpidr_re         
                           or ex2_xucr2_re         or ex2_xudbg0_re        or ex2_xudbg1_re        
                           or ex2_xudbg2_re        or
                              ex2_slowspr_range_hypv or
                           or_reduce(tspr_cspr_hypv_mfspr and ex2_tid));

ex2_hypv_mtspr <= ex2_is_mtspr_q and (
                              ex2_ccr0_we          or ex2_ccr1_we          or ex2_ccr2_we          
                           or ex2_dac3_we          or ex2_dac4_we          or ex2_iac1_we          
                           or ex2_iac2_we          or ex2_ivpr_we          or ex2_tbl_we           
                           or ex2_tbu_we           or ex2_tenc_we          or ex2_tens_we          
                           or ex2_xucr0_we         or ex2_xucr3_we         or ex2_xucr4_we         or
                              ex2_sprg8_we         or
                              ex2_iucr0_we         or ex2_iucr1_we         or ex2_iucr2_we         
                           or ex2_iudbg0_we        or ex2_iulfsr_we        or ex2_iullcr_we        
                           or ex2_lpidr_we         or ex2_xucr2_we         or ex2_xudbg0_we        or
                              ex2_slowspr_range_hypv or
                           or_reduce(tspr_cspr_hypv_mtspr and ex2_tid));

end generate;
ill_spr_01 : if a2mode = 0 and hvmode = 1 generate
ex2_illeg_mfspr <= ex2_is_mfspr_q and not (
                              ex2_ccr0_rdec        or ex2_ccr1_rdec        or ex2_ccr2_rdec        
                           or ex2_dac3_rdec        or ex2_dac4_rdec        or ex2_givpr_rdec       
                           or ex2_iac1_rdec        or ex2_iac2_rdec        or ex2_ivpr_rdec        
                           or ex2_pir_rdec         or ex2_pvr_rdec         or ex2_tb_rdec          
                           or ex2_tbu_rdec         or ex2_tenc_rdec        or ex2_tens_rdec        
                           or ex2_tensr_rdec       or ex2_tir_rdec         or ex2_xucr0_rdec       
                           or ex2_xucr3_rdec       or ex2_xucr4_rdec       or
                              ex2_gsprg0_rdec      or ex2_gsprg1_rdec      or ex2_gsprg2_rdec      
                           or ex2_gsprg3_rdec      or ex2_sprg0_rdec       or ex2_sprg1_rdec       
                           or ex2_sprg2_rdec       or ex2_sprg3_rdec       or ex2_sprg4_rdec       
                           or ex2_sprg5_rdec       or ex2_sprg6_rdec       or ex2_sprg7_rdec       
                           or ex2_sprg8_rdec       or ex2_vrsave_rdec      or
                              ex2_eplc_rdec        or ex2_epsc_rdec        or ex2_eptcfg_rdec      
                           or ex2_iucr0_rdec       or ex2_iucr1_rdec       or ex2_iucr2_rdec       
                           or ex2_iudbg0_rdec      or ex2_iudbg1_rdec      or ex2_iudbg2_rdec      
                           or ex2_iulfsr_rdec      or ex2_iullcr_rdec      or ex2_lper_rdec        
                           or ex2_lperu_rdec       or ex2_lpidr_rdec       or ex2_lratcfg_rdec     
                           or ex2_lratps_rdec      or ex2_mas0_rdec        or ex2_mas0_mas1_rdec   
                           or ex2_mas1_rdec        or ex2_mas2_rdec        or ex2_mas2u_rdec       
                           or ex2_mas3_rdec        or ex2_mas4_rdec        or ex2_mas5_rdec        
                           or ex2_mas5_mas6_rdec   or ex2_mas6_rdec        or ex2_mas7_rdec        
                           or ex2_mas7_mas3_rdec   or ex2_mas8_rdec        or ex2_mas8_mas1_rdec   
                           or ex2_mmucfg_rdec      or ex2_mmucr3_rdec      or ex2_mmucsr0_rdec     
                           or ex2_pid_rdec         or ex2_ppr32_rdec       or ex2_tlb0cfg_rdec     
                           or ex2_tlb0ps_rdec      or ex2_xucr2_rdec       or ex2_xudbg0_rdec      
                           or ex2_xudbg1_rdec      or ex2_xudbg2_rdec      or
                              ex2_slowspr_range or
                           or_reduce(tspr_cspr_illeg_mfspr_b and ex2_tid));

ex2_illeg_mtspr <= ex2_is_mtspr_q and not (
                              ex2_ccr0_wdec        or ex2_ccr1_wdec        or ex2_ccr2_wdec        
                           or ex2_dac3_wdec        or ex2_dac4_wdec        or ex2_givpr_wdec       
                           or ex2_iac1_wdec        or ex2_iac2_wdec        or ex2_ivpr_wdec        
                           or ex2_tbl_wdec         or ex2_tbu_wdec         or ex2_tenc_wdec        
                           or ex2_tens_wdec        or ex2_trace_wdec       or ex2_xucr0_wdec       
                           or ex2_xucr3_wdec       or ex2_xucr4_wdec       or
                              ex2_gsprg0_wdec      or ex2_gsprg1_wdec      or ex2_gsprg2_wdec      
                           or ex2_gsprg3_wdec      or ex2_sprg0_wdec       or ex2_sprg1_wdec       
                           or ex2_sprg2_wdec       or ex2_sprg3_wdec       or ex2_sprg4_wdec       
                           or ex2_sprg5_wdec       or ex2_sprg6_wdec       or ex2_sprg7_wdec       
                           or ex2_sprg8_wdec       or ex2_vrsave_wdec      or
                              ex2_eplc_wdec        or ex2_epsc_wdec        or ex2_iucr0_wdec       
                           or ex2_iucr1_wdec       or ex2_iucr2_wdec       or ex2_iudbg0_wdec      
                           or ex2_iulfsr_wdec      or ex2_iullcr_wdec      or ex2_lper_wdec        
                           or ex2_lperu_wdec       or ex2_lpidr_wdec       or ex2_mas0_wdec        
                           or ex2_mas0_mas1_wdec   or ex2_mas1_wdec        or ex2_mas2_wdec        
                           or ex2_mas2u_wdec       or ex2_mas3_wdec        or ex2_mas4_wdec        
                           or ex2_mas5_wdec        or ex2_mas5_mas6_wdec   or ex2_mas6_wdec        
                           or ex2_mas7_wdec        or ex2_mas7_mas3_wdec   or ex2_mas8_wdec        
                           or ex2_mas8_mas1_wdec   or ex2_mmucr3_wdec      or ex2_mmucsr0_wdec     
                           or ex2_pid_wdec         or ex2_ppr32_wdec       or ex2_xucr2_wdec       
                           or ex2_xudbg0_wdec      or
                              ex2_slowspr_range or
                           or_reduce(tspr_cspr_illeg_mtspr_b and ex2_tid));

ex2_hypv_mfspr <= ex2_is_mfspr_q and (
                              ex2_ccr0_re          or ex2_ccr1_re          or ex2_ccr2_re          
                           or ex2_dac3_re          or ex2_dac4_re          or ex2_iac1_re          
                           or ex2_iac2_re          or ex2_ivpr_re          or ex2_tenc_re          
                           or ex2_tens_re          or ex2_tensr_re         or ex2_tir_re           
                           or ex2_xucr0_re         or ex2_xucr3_re         or ex2_xucr4_re         or
                              ex2_sprg8_re         or
                              ex2_eptcfg_re        or ex2_iucr0_re         or ex2_iucr1_re         
                           or ex2_iucr2_re         or ex2_iudbg0_re        or ex2_iudbg1_re        
                           or ex2_iudbg2_re        or ex2_iulfsr_re        or ex2_iullcr_re        
                           or ex2_lper_re          or ex2_lperu_re         or ex2_lpidr_re         
                           or ex2_lratcfg_re       or ex2_lratps_re        or ex2_mas5_re          
                           or ex2_mas5_mas6_re     or ex2_mas8_re          or ex2_mas8_mas1_re     
                           or ex2_mmucfg_re        or ex2_mmucsr0_re       or ex2_tlb0cfg_re       
                           or ex2_tlb0ps_re        or ex2_xucr2_re         or ex2_xudbg0_re        
                           or ex2_xudbg1_re        or ex2_xudbg2_re        or
                              ex2_slowspr_range_hypv or
                           or_reduce(tspr_cspr_hypv_mfspr and ex2_tid));

ex2_hypv_mtspr <= ex2_is_mtspr_q and (
                              ex2_ccr0_we          or ex2_ccr1_we          or ex2_ccr2_we          
                           or ex2_dac3_we          or ex2_dac4_we          or ex2_givpr_we         
                           or ex2_iac1_we          or ex2_iac2_we          or ex2_ivpr_we          
                           or ex2_tbl_we           or ex2_tbu_we           or ex2_tenc_we          
                           or ex2_tens_we          or ex2_xucr0_we         or ex2_xucr3_we         
                           or ex2_xucr4_we         or
                              ex2_sprg8_we         or
                              ex2_iucr0_we         or ex2_iucr1_we         or ex2_iucr2_we         
                           or ex2_iudbg0_we        or ex2_iulfsr_we        or ex2_iullcr_we        
                           or ex2_lper_we          or ex2_lperu_we         or ex2_lpidr_we         
                           or ex2_mas5_we          or ex2_mas5_mas6_we     or ex2_mas8_we          
                           or ex2_mas8_mas1_we     or ex2_mmucsr0_we       or ex2_xucr2_we         
                           or ex2_xudbg0_we        or
                              ex2_slowspr_range_hypv or
                           or_reduce(tspr_cspr_hypv_mtspr and ex2_tid));
                           
end generate;
ill_spr_10 : if a2mode = 1 and hvmode = 0 generate
ex2_illeg_mfspr <= ex2_is_mfspr_q and not (
                              ex2_ccr0_rdec        or ex2_ccr1_rdec        or ex2_ccr2_rdec        
                           or ex2_dac1_rdec        or ex2_dac2_rdec        or ex2_dac3_rdec        
                           or ex2_dac4_rdec        or ex2_iac1_rdec        or ex2_iac2_rdec        
                           or ex2_iac3_rdec        or ex2_iac4_rdec        or ex2_ivpr_rdec        
                           or ex2_pir_rdec         or ex2_pvr_rdec         or ex2_tb_rdec          
                           or ex2_tbu_rdec         or ex2_tenc_rdec        or ex2_tens_rdec        
                           or ex2_tensr_rdec       or ex2_tir_rdec         or ex2_xucr0_rdec       
                           or ex2_xucr3_rdec       or ex2_xucr4_rdec       or
                              ex2_sprg0_rdec       or ex2_sprg1_rdec       or ex2_sprg2_rdec       
                           or ex2_sprg3_rdec       or ex2_sprg4_rdec       or ex2_sprg5_rdec       
                           or ex2_sprg6_rdec       or ex2_sprg7_rdec       or ex2_sprg8_rdec       
                           or ex2_vrsave_rdec      or
                              ex2_dvc1_rdec        or ex2_dvc2_rdec        or ex2_immr_rdec        
                           or ex2_imr_rdec         or ex2_iucr0_rdec       or ex2_iucr1_rdec       
                           or ex2_iucr2_rdec       or ex2_iudbg0_rdec      or ex2_iudbg1_rdec      
                           or ex2_iudbg2_rdec      or ex2_iulfsr_rdec      or ex2_iullcr_rdec      
                           or ex2_lpidr_rdec       or ex2_mmucr0_rdec      or ex2_mmucr1_rdec      
                           or ex2_mmucr2_rdec      or ex2_pid_rdec         or ex2_ppr32_rdec       
                           or ex2_xucr2_rdec       or ex2_xudbg0_rdec      or ex2_xudbg1_rdec      
                           or ex2_xudbg2_rdec      or
                              ex2_slowspr_range or
                           or_reduce(tspr_cspr_illeg_mfspr_b and ex2_tid));

ex2_illeg_mtspr <= ex2_is_mtspr_q and not (
                              ex2_ccr0_wdec        or ex2_ccr1_wdec        or ex2_ccr2_wdec        
                           or ex2_dac1_wdec        or ex2_dac2_wdec        or ex2_dac3_wdec        
                           or ex2_dac4_wdec        or ex2_iac1_wdec        or ex2_iac2_wdec        
                           or ex2_iac3_wdec        or ex2_iac4_wdec        or ex2_ivpr_wdec        
                           or ex2_tbl_wdec         or ex2_tbu_wdec         or ex2_tenc_wdec        
                           or ex2_tens_wdec        or ex2_trace_wdec       or ex2_xucr0_wdec       
                           or ex2_xucr3_wdec       or ex2_xucr4_wdec       or
                              ex2_sprg0_wdec       or ex2_sprg1_wdec       or ex2_sprg2_wdec       
                           or ex2_sprg3_wdec       or ex2_sprg4_wdec       or ex2_sprg5_wdec       
                           or ex2_sprg6_wdec       or ex2_sprg7_wdec       or ex2_sprg8_wdec       
                           or ex2_vrsave_wdec      or
                              ex2_dvc1_wdec        or ex2_dvc2_wdec        or ex2_immr_wdec        
                           or ex2_imr_wdec         or ex2_iucr0_wdec       or ex2_iucr1_wdec       
                           or ex2_iucr2_wdec       or ex2_iudbg0_wdec      or ex2_iulfsr_wdec      
                           or ex2_iullcr_wdec      or ex2_lpidr_wdec       or ex2_mmucr0_wdec      
                           or ex2_mmucr1_wdec      or ex2_mmucr2_wdec      or ex2_pid_wdec         
                           or ex2_ppr32_wdec       or ex2_xucr2_wdec       or ex2_xudbg0_wdec      or
                              ex2_slowspr_range or
                           or_reduce(tspr_cspr_illeg_mtspr_b and ex2_tid));

ex2_hypv_mfspr <= ex2_is_mfspr_q and (
                              ex2_ccr0_re          or ex2_ccr1_re          or ex2_ccr2_re          
                           or ex2_dac1_re          or ex2_dac2_re          or ex2_dac3_re          
                           or ex2_dac4_re          or ex2_iac1_re          or ex2_iac2_re          
                           or ex2_iac3_re          or ex2_iac4_re          or ex2_ivpr_re          
                           or ex2_tenc_re          or ex2_tens_re          or ex2_tensr_re         
                           or ex2_tir_re           or ex2_xucr0_re         or ex2_xucr3_re         
                           or ex2_xucr4_re         or
                              ex2_sprg8_re         or
                              ex2_dvc1_re          or ex2_dvc2_re          or ex2_immr_re          
                           or ex2_imr_re           or ex2_iucr0_re         or ex2_iucr1_re         
                           or ex2_iucr2_re         or ex2_iudbg0_re        or ex2_iudbg1_re        
                           or ex2_iudbg2_re        or ex2_iulfsr_re        or ex2_iullcr_re        
                           or ex2_lpidr_re         or ex2_mmucr0_re        or ex2_mmucr1_re        
                           or ex2_mmucr2_re        or ex2_xucr2_re         or ex2_xudbg0_re        
                           or ex2_xudbg1_re        or ex2_xudbg2_re        or
                              ex2_slowspr_range_hypv or                                                          
                           or_reduce(tspr_cspr_hypv_mfspr and ex2_tid));                               
                                                                                                            
ex2_hypv_mtspr <= ex2_is_mtspr_q and (                               
                              ex2_ccr0_we          or ex2_ccr1_we          or ex2_ccr2_we          
                           or ex2_dac1_we          or ex2_dac2_we          or ex2_dac3_we          
                           or ex2_dac4_we          or ex2_iac1_we          or ex2_iac2_we          
                           or ex2_iac3_we          or ex2_iac4_we          or ex2_ivpr_we          
                           or ex2_tbl_we           or ex2_tbu_we           or ex2_tenc_we          
                           or ex2_tens_we          or ex2_xucr0_we         or ex2_xucr3_we         
                           or ex2_xucr4_we         or
                              ex2_sprg8_we         or
                              ex2_dvc1_we          or ex2_dvc2_we          or ex2_immr_we          
                           or ex2_imr_we           or ex2_iucr0_we         or ex2_iucr1_we         
                           or ex2_iucr2_we         or ex2_iudbg0_we        or ex2_iulfsr_we        
                           or ex2_iullcr_we        or ex2_lpidr_we         or ex2_mmucr0_we        
                           or ex2_mmucr1_we        or ex2_mmucr2_we        or ex2_xucr2_we         
                           or ex2_xudbg0_we        or
                              ex2_slowspr_range_hypv or
                           or_reduce(tspr_cspr_hypv_mtspr and ex2_tid));

end generate;
ill_spr_11 : if a2mode = 1 and hvmode = 1 generate
ex2_illeg_mfspr <= ex2_is_mfspr_q and not (
                              ex2_ccr0_rdec        or ex2_ccr1_rdec        or ex2_ccr2_rdec        
                           or ex2_dac1_rdec        or ex2_dac2_rdec        or ex2_dac3_rdec        
                           or ex2_dac4_rdec        or ex2_givpr_rdec       or ex2_iac1_rdec        
                           or ex2_iac2_rdec        or ex2_iac3_rdec        or ex2_iac4_rdec        
                           or ex2_ivpr_rdec        or ex2_pir_rdec         or ex2_pvr_rdec         
                           or ex2_tb_rdec          or ex2_tbu_rdec         or ex2_tenc_rdec        
                           or ex2_tens_rdec        or ex2_tensr_rdec       or ex2_tir_rdec         
                           or ex2_xucr0_rdec       or ex2_xucr3_rdec       or ex2_xucr4_rdec       or
                              ex2_gsprg0_rdec      or ex2_gsprg1_rdec      or ex2_gsprg2_rdec      
                           or ex2_gsprg3_rdec      or ex2_sprg0_rdec       or ex2_sprg1_rdec       
                           or ex2_sprg2_rdec       or ex2_sprg3_rdec       or ex2_sprg4_rdec       
                           or ex2_sprg5_rdec       or ex2_sprg6_rdec       or ex2_sprg7_rdec       
                           or ex2_sprg8_rdec       or ex2_vrsave_rdec      or
                              ex2_dvc1_rdec        or ex2_dvc2_rdec        or ex2_eplc_rdec        
                           or ex2_epsc_rdec        or ex2_eptcfg_rdec      or ex2_immr_rdec        
                           or ex2_imr_rdec         or ex2_iucr0_rdec       or ex2_iucr1_rdec       
                           or ex2_iucr2_rdec       or ex2_iudbg0_rdec      or ex2_iudbg1_rdec      
                           or ex2_iudbg2_rdec      or ex2_iulfsr_rdec      or ex2_iullcr_rdec      
                           or ex2_lper_rdec        or ex2_lperu_rdec       or ex2_lpidr_rdec       
                           or ex2_lratcfg_rdec     or ex2_lratps_rdec      or ex2_mas0_rdec        
                           or ex2_mas0_mas1_rdec   or ex2_mas1_rdec        or ex2_mas2_rdec        
                           or ex2_mas2u_rdec       or ex2_mas3_rdec        or ex2_mas4_rdec        
                           or ex2_mas5_rdec        or ex2_mas5_mas6_rdec   or ex2_mas6_rdec        
                           or ex2_mas7_rdec        or ex2_mas7_mas3_rdec   or ex2_mas8_rdec        
                           or ex2_mas8_mas1_rdec   or ex2_mmucfg_rdec      or ex2_mmucr0_rdec      
                           or ex2_mmucr1_rdec      or ex2_mmucr2_rdec      or ex2_mmucr3_rdec      
                           or ex2_mmucsr0_rdec     or ex2_pid_rdec         or ex2_ppr32_rdec       
                           or ex2_tlb0cfg_rdec     or ex2_tlb0ps_rdec      or ex2_xucr2_rdec       
                           or ex2_xudbg0_rdec      or ex2_xudbg1_rdec      or ex2_xudbg2_rdec      or
                              ex2_slowspr_range or
                           or_reduce(tspr_cspr_illeg_mfspr_b and ex2_tid));

ex2_illeg_mtspr <= ex2_is_mtspr_q and not (
                              ex2_ccr0_wdec        or ex2_ccr1_wdec        or ex2_ccr2_wdec        
                           or ex2_dac1_wdec        or ex2_dac2_wdec        or ex2_dac3_wdec        
                           or ex2_dac4_wdec        or ex2_givpr_wdec       or ex2_iac1_wdec        
                           or ex2_iac2_wdec        or ex2_iac3_wdec        or ex2_iac4_wdec        
                           or ex2_ivpr_wdec        or ex2_tbl_wdec         or ex2_tbu_wdec         
                           or ex2_tenc_wdec        or ex2_tens_wdec        or ex2_trace_wdec       
                           or ex2_xucr0_wdec       or ex2_xucr3_wdec       or ex2_xucr4_wdec       or
                              ex2_gsprg0_wdec      or ex2_gsprg1_wdec      or ex2_gsprg2_wdec      
                           or ex2_gsprg3_wdec      or ex2_sprg0_wdec       or ex2_sprg1_wdec       
                           or ex2_sprg2_wdec       or ex2_sprg3_wdec       or ex2_sprg4_wdec       
                           or ex2_sprg5_wdec       or ex2_sprg6_wdec       or ex2_sprg7_wdec       
                           or ex2_sprg8_wdec       or ex2_vrsave_wdec      or
                              ex2_dvc1_wdec        or ex2_dvc2_wdec        or ex2_eplc_wdec        
                           or ex2_epsc_wdec        or ex2_immr_wdec        or ex2_imr_wdec         
                           or ex2_iucr0_wdec       or ex2_iucr1_wdec       or ex2_iucr2_wdec       
                           or ex2_iudbg0_wdec      or ex2_iulfsr_wdec      or ex2_iullcr_wdec      
                           or ex2_lper_wdec        or ex2_lperu_wdec       or ex2_lpidr_wdec       
                           or ex2_mas0_wdec        or ex2_mas0_mas1_wdec   or ex2_mas1_wdec        
                           or ex2_mas2_wdec        or ex2_mas2u_wdec       or ex2_mas3_wdec        
                           or ex2_mas4_wdec        or ex2_mas5_wdec        or ex2_mas5_mas6_wdec   
                           or ex2_mas6_wdec        or ex2_mas7_wdec        or ex2_mas7_mas3_wdec   
                           or ex2_mas8_wdec        or ex2_mas8_mas1_wdec   or ex2_mmucr0_wdec      
                           or ex2_mmucr1_wdec      or ex2_mmucr2_wdec      or ex2_mmucr3_wdec      
                           or ex2_mmucsr0_wdec     or ex2_pid_wdec         or ex2_ppr32_wdec       
                           or ex2_xucr2_wdec       or ex2_xudbg0_wdec      or
                              ex2_slowspr_range or
                           or_reduce(tspr_cspr_illeg_mtspr_b and ex2_tid));

ex2_hypv_mfspr <= ex2_is_mfspr_q and (
                              ex2_ccr0_re          or ex2_ccr1_re          or ex2_ccr2_re          
                           or ex2_dac1_re          or ex2_dac2_re          or ex2_dac3_re          
                           or ex2_dac4_re          or ex2_iac1_re          or ex2_iac2_re          
                           or ex2_iac3_re          or ex2_iac4_re          or ex2_ivpr_re          
                           or ex2_tenc_re          or ex2_tens_re          or ex2_tensr_re         
                           or ex2_tir_re           or ex2_xucr0_re         or ex2_xucr3_re         
                           or ex2_xucr4_re         or
                              ex2_sprg8_re         or
                              ex2_dvc1_re          or ex2_dvc2_re          or ex2_eptcfg_re        
                           or ex2_immr_re          or ex2_imr_re           or ex2_iucr0_re         
                           or ex2_iucr1_re         or ex2_iucr2_re         or ex2_iudbg0_re        
                           or ex2_iudbg1_re        or ex2_iudbg2_re        or ex2_iulfsr_re        
                           or ex2_iullcr_re        or ex2_lper_re          or ex2_lperu_re         
                           or ex2_lpidr_re         or ex2_lratcfg_re       or ex2_lratps_re        
                           or ex2_mas5_re          or ex2_mas5_mas6_re     or ex2_mas8_re          
                           or ex2_mas8_mas1_re     or ex2_mmucfg_re        or ex2_mmucr0_re        
                           or ex2_mmucr1_re        or ex2_mmucr2_re        or ex2_mmucsr0_re       
                           or ex2_tlb0cfg_re       or ex2_tlb0ps_re        or ex2_xucr2_re         
                           or ex2_xudbg0_re        or ex2_xudbg1_re        or ex2_xudbg2_re        or
                              ex2_slowspr_range_hypv or
                           or_reduce(tspr_cspr_hypv_mfspr and ex2_tid));

ex2_hypv_mtspr <= ex2_is_mtspr_q and (
                              ex2_ccr0_we          or ex2_ccr1_we          or ex2_ccr2_we          
                           or ex2_dac1_we          or ex2_dac2_we          or ex2_dac3_we          
                           or ex2_dac4_we          or ex2_givpr_we         or ex2_iac1_we          
                           or ex2_iac2_we          or ex2_iac3_we          or ex2_iac4_we          
                           or ex2_ivpr_we          or ex2_tbl_we           or ex2_tbu_we           
                           or ex2_tenc_we          or ex2_tens_we          or ex2_xucr0_we         
                           or ex2_xucr3_we         or ex2_xucr4_we         or
                              ex2_sprg8_we         or
                              ex2_dvc1_we          or ex2_dvc2_we          or ex2_immr_we          
                           or ex2_imr_we           or ex2_iucr0_we         or ex2_iucr1_we         
                           or ex2_iucr2_we         or ex2_iudbg0_we        or ex2_iulfsr_we        
                           or ex2_iullcr_we        or ex2_lper_we          or ex2_lperu_we         
                           or ex2_lpidr_we         or ex2_mas5_we          or ex2_mas5_mas6_we     
                           or ex2_mas8_we          or ex2_mas8_mas1_we     or ex2_mmucr0_we        
                           or ex2_mmucr1_we        or ex2_mmucr2_we        or ex2_mmucsr0_we       
                           or ex2_xucr2_we         or ex2_xudbg0_we        or
                              ex2_slowspr_range_hypv or
                           or_reduce(tspr_cspr_hypv_mtspr and ex2_tid));

end generate;

ex3_hypv_spr_d    <= ex2_hypv_mfspr or ex2_hypv_mtspr;

ex3_illeg_spr_d   <= ex2_illeg_mfspr or ex2_illeg_mtspr or ex2_illeg_mftb;

ex3_priv_spr_d    <= (ex2_instr_q(11) and (ex2_is_mtspr_q or ex2_is_mfspr_q)) or
                                           ex2_is_mtmsr_q or ex2_is_mfmsr_q;

xu_pc_spr_ccr0_pme         <= ccr0_q(58 to 59);
spr_ccr0_we                <= ccr0_q(60 to 63);
spr_ccr2_en_dcr      <= spr_ccr2_en_dcr_int;
spr_ccr2_en_dcr_int        <= ccr2_q(32);
spr_ccr2_en_trace          <= ccr2_q(33);
spr_ccr2_en_pc             <= ccr2_q(34);
xu_iu_spr_ccr2_ifratsc     <= ccr2_q(35 to 43);
xu_iu_spr_ccr2_ifrat       <= ccr2_q(44);
xu_lsu_spr_ccr2_dfratsc    <= ccr2_q(45 to 53);
xu_lsu_spr_ccr2_dfrat      <= ccr2_q(54);
spr_ccr2_ucode_dis         <= ccr2_q(55);
spr_ccr2_ap                <= ccr2_q(56 to 59);
spr_ccr2_en_attn           <= ccr2_q(60);
spr_ccr2_en_ditc           <= ccr2_q(61);
spr_ccr2_en_icswx          <= ccr2_q(62);
spr_ccr2_notlb             <= ccr2_q(63);
spr_tens_ten               <= tens_q(60 to 63);
spr_xucr0_clkg_ctl         <= xucr0_q(33 to 37);
spr_xucr0_trace_um         <= xucr0_q(38 to 41);
xu_lsu_spr_xucr0_mbar_ack  <= xucr0_q(42);
xu_lsu_spr_xucr0_tlbsync   <= xucr0_q(43);
spr_dec_spr_xucr0_ssdly    <= xucr0_q(44 to 48);
spr_xucr0_cls              <= xucr0_q(49);
xu_lsu_spr_xucr0_aflsta    <= xucr0_q(50);
spr_xucr0_mddp             <= xucr0_q(51);
xu_lsu_spr_xucr0_cred      <= xucr0_q(52);
xu_lsu_spr_xucr0_rel       <= xucr0_q(53);
spr_xucr0_mdcp             <= xucr0_q(54);
spr_xucr0_tcs              <= xucr0_q(55);
xu_lsu_spr_xucr0_flsta     <= xucr0_q(56);
xu_lsu_spr_xucr0_l2siw     <= xucr0_q(57);
xu_lsu_spr_xucr0_flh2l2    <= xucr0_q(58);
xu_lsu_spr_xucr0_dcdis     <= xucr0_q(59);
xu_lsu_spr_xucr0_wlk       <= xucr0_q(60);
xucr0_clfc_d               <= ex6_xucr0_we and ex6_spr_wd(63);
xu_lsu_spr_xucr0_clfc      <= xucr0_clfc_q;

-- CCR0
ex6_ccr0_di    <= ex6_spr_wd(32 to 33)             & --PME
						ex6_spr_wd(60 to 63)             ; --WE
ccr0_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						ccr0_q(58 to 59)                 & --PME
						tidn(34 to 51)                   & --///
						"0000"                           & --WEM
						tidn(56 to 59)                   & --///
						ccr0_q(60 to 63)                 ; --WE
-- CCR1
ex6_ccr1_di    <= ex6_spr_wd(34 to 39)             & --WC3
						ex6_spr_wd(42 to 47)             & --WC2
						ex6_spr_wd(50 to 55)             & --WC1
						ex6_spr_wd(58 to 63)             ; --WC0
ccr1_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 33)                   & --///
						ccr1_q(40 to 45)                 & --WC3
						tidn(40 to 41)                   & --///
						ccr1_q(46 to 51)                 & --WC2
						tidn(48 to 49)                   & --///
						ccr1_q(52 to 57)                 & --WC1
						tidn(56 to 57)                   & --///
						ccr1_q(58 to 63)                 ; --WC0
-- CCR2
ex6_ccr2_di    <= ex6_spr_wd(32 to 32)             & --EN_DCR
						ex6_spr_wd(33 to 33)             & --EN_TRACE
						ex6_spr_wd(34 to 34)             & --EN_PC
						ex6_spr_wd(35 to 43)             & --IFRATSC
						ex6_spr_wd(44 to 44)             & --IFRAT
						ex6_spr_wd(45 to 53)             & --DFRATSC
						ex6_spr_wd(54 to 54)             & --DFRAT
						ex6_spr_wd(55 to 55)             & --UCODE_DIS
						ex6_spr_wd(56 to 59)             & --AP
						ex6_spr_wd(60 to 60)             & --EN_ATTN
						ex6_spr_wd(61 to 61)             & --EN_DITC
						ex6_spr_wd(62 to 62)             & --EN_ICSWX
						ex6_spr_wd(63 to 63)             ; --NOTLB
ccr2_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						ccr2_q(32 to 32)                 & --EN_DCR
						ccr2_q(33 to 33)                 & --EN_TRACE
						ccr2_q(34 to 34)                 & --EN_PC
						ccr2_q(35 to 43)                 & --IFRATSC
						ccr2_q(44 to 44)                 & --IFRAT
						ccr2_q(45 to 53)                 & --DFRATSC
						ccr2_q(54 to 54)                 & --DFRAT
						ccr2_q(55 to 55)                 & --UCODE_DIS
						ccr2_q(56 to 59)                 & --AP
						ccr2_q(60 to 60)                 & --EN_ATTN
						ccr2_q(61 to 61)                 & --EN_DITC
						ccr2_q(62 to 62)                 & --EN_ICSWX
						ccr2_q(63 to 63)                 ; --NOTLB
-- PIR
pir_do         <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 53)                   & --///
						an_ac_coreid_q(54 to 61)         & --CID
						ex2_tid_q(0 to 1)                ; --TID
-- PVR
pvr_do         <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						version(32 to 47)                & --VERSION
						revision(48 to 63)               ; --REVISION
-- TB
tb_do          <= tidn(0 to 0)                     &
						tbu_q(32 to 63)                  & --TBU
						tbl_q(32 to 63)                  ; --TBL
-- TBL
ex6_tbl_di     <= ex6_spr_wd(32 to 63)             ; --TBL
tbl_do         <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tbl_q(32 to 63)                  ; --TBL
-- TBU
ex6_tbu_di     <= ex6_spr_wd(32 to 63)             ; --TBU
tbu_do         <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tbu_q(32 to 63)                  ; --TBU
-- TENC
tenc_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 59)                   & --///
						tens_q(60 to 63)                 ; --TEN
-- TENS
ex6_tens_di    <= ex6_spr_wd(60 to 63)             ; --TEN
tens_do        <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 59)                   & --///
						tens_q(60 to 63)                 ; --TEN
-- TENSR
tensr_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 59)                   & --///
						spr_tensr(0 to 3)                ; --TENSR
-- TIR
tir_do         <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 61)                   & --///
						ex2_tid_q(0 to 1)                ; --TID
-- XUCR0
ex6_xucr0_di   <= ex6_spr_wd(32 to 36)             & --CLKG_CTL
						ex6_spr_wd(37 to 40)             & --TRACE_UM
						ex6_spr_wd(41 to 41)             & --MBAR_ACK
						ex6_spr_wd(42 to 42)             & --TLBSYNC
						xucr0_q(44 to 48)                & --SSDLY
						xucr0_q(49 to 49)                & --CLS
						ex6_spr_wd(49 to 49)             & --AFLSTA
						ex6_spr_wd(50 to 50)             & --MDDP
						ex6_spr_wd(51 to 51)             & --CRED
						xucr0_q(53 to 53)                & --REL
						ex6_spr_wd(53 to 53)             & --MDCP
						ex6_spr_wd(54 to 54)             & --TCS
						ex6_spr_wd(55 to 55)             & --FLSTA
						xucr0_q(57 to 57)                & --L2SIW
						xucr0_q(58 to 58)                & --FLH2L2
						ex6_spr_wd(58 to 58)             & --DCDIS
						ex6_spr_wd(59 to 59)             & --WLK
						ex6_spr_wd(60 to 60)             & --CSLC
						ex6_spr_wd(61 to 61)             & --CUL
						ex6_spr_wd(62 to 62)             ; --CLO
xucr0_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						xucr0_q(33 to 37)                & --CLKG_CTL
						xucr0_q(38 to 41)                & --TRACE_UM
						xucr0_q(42 to 42)                & --MBAR_ACK
						xucr0_q(43 to 43)                & --TLBSYNC
						xucr0_q(44 to 48)                & --SSDLY
						xucr0_q(49 to 49)                & --CLS
						xucr0_q(50 to 50)                & --AFLSTA
						xucr0_q(51 to 51)                & --MDDP
						xucr0_q(52 to 52)                & --CRED
						xucr0_q(53 to 53)                & --REL
						xucr0_q(54 to 54)                & --MDCP
						xucr0_q(55 to 55)                & --TCS
						xucr0_q(56 to 56)                & --FLSTA
						xucr0_q(57 to 57)                & --L2SIW
						xucr0_q(58 to 58)                & --FLH2L2
						xucr0_q(59 to 59)                & --DCDIS
						xucr0_q(60 to 60)                & --WLK
						xucr0_q(61 to 61)                & --CSLC
						xucr0_q(62 to 62)                & --CUL
						xucr0_q(63 to 63)                & --CLO
						'0'                              ; --CLFC

-- Unused Signals
mark_unused(ccr0_do(0 to 64-regsize));
mark_unused(ccr1_do(0 to 64-regsize));
mark_unused(ccr2_do(0 to 64-regsize));
mark_unused(pir_do(0 to 64-regsize));
mark_unused(pvr_do(0 to 64-regsize));
mark_unused(tb_do(0 to 64-regsize));
mark_unused(tbl_do(0 to 64-regsize));
mark_unused(tbu_do(0 to 64-regsize));
mark_unused(tenc_do(0 to 64-regsize));
mark_unused(tens_do(0 to 64-regsize));
mark_unused(tensr_do(0 to 64-regsize));
mark_unused(tir_do(0 to 64-regsize));
mark_unused(xucr0_do(0 to 64-regsize));
mark_unused(ex2_rs0_q(56 to 59));
mark_unused(tbl_do(1 to 64));
mark_unused(ex2_trace_we);
mark_unused(ex2_givpr_re);
mark_unused(pir_act);
mark_unused(pvr_act);
mark_unused(tenc_act);
mark_unused(tensr_act);
mark_unused(tir_act);
mark_unused(exx_act_data(1));

ccr0_latch : tri_ser_rlmreg_p
generic map(width   => ccr0_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => ccr0_act,
            forcee => bcfg_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => bcfg_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv_bcfg(ccr0_offset_bcfg to ccr0_offset_bcfg + ccr0_q'length-1),
            scout   => sov_bcfg(ccr0_offset_bcfg to ccr0_offset_bcfg + ccr0_q'length-1),
            din     => ccr0_d,
            dout    => ccr0_q);
ccr1_latch : tri_ser_rlmreg_p
generic map(width   => ccr1_q'length, init => 3994575, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => ccr1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ccr1_offset to ccr1_offset + ccr1_q'length-1),
            scout   => sov(ccr1_offset to ccr1_offset + ccr1_q'length-1),
            din     => ccr1_d,
            dout    => ccr1_q);
ccr2_latch : tri_ser_rlmreg_p
generic map(width   => ccr2_q'length, init => 1, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => ccr2_act,
            forcee => ccfg_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => ccfg_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv_ccfg(ccr2_offset_ccfg to ccr2_offset_ccfg + ccr2_q'length-1),
            scout   => sov_ccfg(ccr2_offset_ccfg to ccr2_offset_ccfg + ccr2_q'length-1),
            din     => ccr2_d,
            dout    => ccr2_q);
tbl_latch : tri_ser_rlmreg_p
generic map(width   => tbl_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => tbl_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(tbl_offset to tbl_offset + tbl_q'length-1),
            scout   => sov(tbl_offset to tbl_offset + tbl_q'length-1),
            din     => tbl_d,
            dout    => tbl_q);
tbu_latch : tri_ser_rlmreg_p
generic map(width   => tbu_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => tbu_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(tbu_offset to tbu_offset + tbu_q'length-1),
            scout   => sov(tbu_offset to tbu_offset + tbu_q'length-1),
            din     => tbu_d,
            dout    => tbu_q);
tens_latch : tri_ser_rlmreg_p
generic map(width   => tens_q'length, init => 1, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => tens_act,
            forcee => bcfg_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => bcfg_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv_bcfg(tens_offset_bcfg to tens_offset_bcfg + tens_q'length-1),
            scout   => sov_bcfg(tens_offset_bcfg to tens_offset_bcfg + tens_q'length-1),
            din     => tens_d,
            dout    => tens_q);
xucr0_latch : tri_ser_rlmreg_p
generic map(width   => xucr0_q'length, init => (230496 + spr_xucr0_init_mod), expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => xucr0_act,
            forcee => ccfg_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DWR),
            mpw1_b  => mpw1_dc_b(DWR), mpw2_b => mpw2_dc_b,
            thold_b => ccfg_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv_ccfg(xucr0_offset_ccfg to xucr0_offset_ccfg + xucr0_q'length-1),
            scout   => sov_ccfg(xucr0_offset_ccfg to xucr0_offset_ccfg + xucr0_q'length-1),
            din     => xucr0_d,
            dout    => xucr0_q);


-- Latch Instances
exx_act_latch : tri_rlmreg_p
  generic map (width => exx_act_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
rf1_instr_latch : tri_rlmreg_p
  generic map (width => rf1_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf0_act        ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DRF1),
            mpw1_b  => mpw1_dc_b(DRF1), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rf1_instr_offset to rf1_instr_offset + rf1_instr_q'length-1),
            scout   => sov(rf1_instr_offset to rf1_instr_offset + rf1_instr_q'length-1),
            din     => dec_spr_rf0_instr          ,
            dout    => rf1_instr_q);
rf1_aspr_act_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DRF1),
            mpw1_b  => mpw1_dc_b(DRF1), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rf1_aspr_act_offset),
            scout   => sov(rf1_aspr_act_offset),
            din     => rf1_aspr_act_d,
            dout    => rf1_aspr_act_q);
rf1_aspr_tid_latch : tri_rlmreg_p
  generic map (width => rf1_aspr_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf0_act        ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DRF1),
            mpw1_b  => mpw1_dc_b(DRF1), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rf1_aspr_tid_offset to rf1_aspr_tid_offset + rf1_aspr_tid_q'length-1),
            scout   => sov(rf1_aspr_tid_offset to rf1_aspr_tid_offset + rf1_aspr_tid_q'length-1),
            din     => rf1_aspr_tid_d,
            dout    => rf1_aspr_tid_q);
rf1_msr_gs_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DRF1),
            mpw1_b  => mpw1_dc_b(DRF1), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rf1_msr_gs_offset),
            scout   => sov(rf1_msr_gs_offset),
            din     => rf1_msr_gs_d,
            dout    => rf1_msr_gs_q);
ex1_tid_latch : tri_rlmreg_p
  generic map (width => ex1_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX1),
            mpw1_b  => mpw1_dc_b(DEX1), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_tid_offset to ex1_tid_offset + ex1_tid_q'length-1),
            scout   => sov(ex1_tid_offset to ex1_tid_offset + ex1_tid_q'length-1),
            din     => rf1_tid,
            dout    => ex1_tid_q);
ex1_is_mfspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX1),
            mpw1_b  => mpw1_dc_b(DEX1), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_mfspr_offset),
            scout   => sov(ex1_is_mfspr_offset),
            din     => rf1_is_mfspr,
            dout    => ex1_is_mfspr_q);
ex1_is_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX1),
            mpw1_b  => mpw1_dc_b(DEX1), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_mtspr_offset),
            scout   => sov(ex1_is_mtspr_offset),
            din     => rf1_is_mtspr,
            dout    => ex1_is_mtspr_q);
ex1_instr_latch : tri_rlmreg_p
  generic map (width => ex1_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX1),
            mpw1_b  => mpw1_dc_b(DEX1), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_instr_offset to ex1_instr_offset + ex1_instr_q'length-1),
            scout   => sov(ex1_instr_offset to ex1_instr_offset + ex1_instr_q'length-1),
            din     => rf1_instr_q                ,
            dout    => ex1_instr_q);
ex1_aspr_re_latch : tri_rlmreg_p
  generic map (width => ex1_aspr_re_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX1),
            mpw1_b  => mpw1_dc_b(DEX1), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_aspr_re_offset to ex1_aspr_re_offset + ex1_aspr_re_q'length-1),
            scout   => sov(ex1_aspr_re_offset to ex1_aspr_re_offset + ex1_aspr_re_q'length-1),
            din     => rf1_aspr_re,
            dout    => ex1_aspr_re_q);
ex1_aspr_ce_addr_latch : tri_rlmreg_p
  generic map (width => ex1_aspr_ce_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX1),
            mpw1_b  => mpw1_dc_b(DEX1), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_aspr_ce_addr_offset to ex1_aspr_ce_addr_offset + ex1_aspr_ce_addr_q'length-1),
            scout   => sov(ex1_aspr_ce_addr_offset to ex1_aspr_ce_addr_offset + ex1_aspr_ce_addr_q'length-1),
            din     => rf1_aspr_addr,
            dout    => ex1_aspr_ce_addr_q);
ex2_tid_latch : tri_regk
  generic map (width => ex2_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_tid_q                  ,
            dout    => ex2_tid_q);
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
ex2_is_mfspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_mfspr_q             ,
            dout(0) => ex2_is_mfspr_q);
ex2_is_mftb_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_mftb,
            dout(0) => ex2_is_mftb_q);
ex2_is_mtmsr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_mtmsr,
            dout(0) => ex2_is_mtmsr_q);
ex2_is_mtspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_mtspr_q             ,
            dout(0) => ex2_is_mtspr_q);
ex2_is_wait_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_wait,
            dout(0) => ex2_is_wait_q);
ex2_wait_wc_latch : tri_regk
  generic map (width => ex2_wait_wc_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(1),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_instr_q(9 to 10)       ,
            dout    => ex2_wait_wc_q);
ex2_is_msgclr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_msgclr,
            dout(0) => ex2_is_msgclr_q);
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
ex2_rs0_latch : tri_regk
  generic map (width => ex2_rs0_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => fxu_spr_ex1_rs0            ,
            dout    => ex2_rs0_q);
ex2_msr_gs_latch : tri_regk
  generic map (width => ex2_msr_gs_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_msr_gs_d,
            dout    => ex2_msr_gs_q);
ex2_tenc_we_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_tenc_we,
            dout(0) => ex2_tenc_we_q);
ex2_ccr0_we_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_ccr0_we,
            dout(0) => ex2_ccr0_we_q);
ex2_aspr_rdata_latch : tri_rlmreg_p
  generic map (width => ex2_aspr_rdata_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(1),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_aspr_rdata_offset to ex2_aspr_rdata_offset + ex2_aspr_rdata_q'length-1),
            scout   => sov(ex2_aspr_rdata_offset to ex2_aspr_rdata_offset + ex2_aspr_rdata_q'length-1),
            din     => ex2_aspr_rdata_d,
            dout    => ex2_aspr_rdata_q);
ex2_dcrn_latch : tri_regk
  generic map (width => ex2_dcrn_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(1),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => fxu_spr_ex1_rs1            ,
            dout    => ex2_dcrn_q);
ex2_dcr_val_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_dcr_val,
            dout(0) => ex2_dcr_val_q);
ex2_aspr_ce_addr_latch : tri_regk
  generic map (width => ex2_aspr_ce_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_aspr_ce_addr_q         ,
            dout    => ex2_aspr_ce_addr_q);
ex2_aspr_re_latch : tri_regk
  generic map (width => ex2_aspr_re_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_aspr_re_q              ,
            dout    => ex2_aspr_re_q);
ex2_dcr_read_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_dcr_read,
            dout(0) => ex2_dcr_read_q);
ex2_dcr_user_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_dcr_user,
            dout(0) => ex2_dcr_user_q);
ex2_is_wrtee_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_wrtee,
            dout(0) => ex2_is_wrtee_q);
ex2_is_wrteei_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_wrteei,
            dout(0) => ex2_is_wrteei_q);
ex3_tid_latch : tri_rlmreg_p
  generic map (width => ex3_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tid_offset to ex3_tid_offset + ex3_tid_q'length-1),
            scout   => sov(ex3_tid_offset to ex3_tid_offset + ex3_tid_q'length-1),
            din     => ex2_tid_q                  ,
            dout    => ex3_tid_q);
ex3_is_mtmsr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_mtmsr_offset),
            scout   => sov(ex3_is_mtmsr_offset),
            din     => ex2_is_mtmsr_q             ,
            dout    => ex3_is_mtmsr_q);
ex3_is_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_mtspr_offset),
            scout   => sov(ex3_is_mtspr_offset),
            din     => ex2_is_mtspr_q             ,
            dout    => ex3_is_mtspr_q);
ex3_wait_wc_latch : tri_rlmreg_p
  generic map (width => ex3_wait_wc_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_wait_wc_offset to ex3_wait_wc_offset + ex3_wait_wc_q'length-1),
            scout   => sov(ex3_wait_wc_offset to ex3_wait_wc_offset + ex3_wait_wc_q'length-1),
            din     => ex2_wait_wc_q              ,
            dout    => ex3_wait_wc_q);
ex3_is_msgclr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_msgclr_offset),
            scout   => sov(ex3_is_msgclr_offset),
            din     => ex2_is_msgclr_q            ,
            dout    => ex3_is_msgclr_q);
ex3_instr_latch : tri_rlmreg_p
  generic map (width => ex3_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_instr_offset to ex3_instr_offset + ex3_instr_q'length-1),
            scout   => sov(ex3_instr_offset to ex3_instr_offset + ex3_instr_q'length-1),
            din     => ex3_instr_d,
            dout    => ex3_instr_q);
ex3_cspr_rt_latch : tri_rlmreg_p
  generic map (width => ex3_cspr_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_cspr_rt_offset to ex3_cspr_rt_offset + ex3_cspr_rt_q'length-1),
            scout   => sov(ex3_cspr_rt_offset to ex3_cspr_rt_offset + ex3_cspr_rt_q'length-1),
            din     => ex2_cspr_rt,
            dout    => ex3_cspr_rt_q);
ex3_hypv_spr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_hypv_spr_offset),
            scout   => sov(ex3_hypv_spr_offset),
            din     => ex3_hypv_spr_d,
            dout    => ex3_hypv_spr_q);
ex3_illeg_spr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_illeg_spr_offset),
            scout   => sov(ex3_illeg_spr_offset),
            din     => ex3_illeg_spr_d,
            dout    => ex3_illeg_spr_q);
ex3_priv_spr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_priv_spr_offset),
            scout   => sov(ex3_priv_spr_offset),
            din     => ex3_priv_spr_d,
            dout    => ex3_priv_spr_q);
ex3_sspr_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_sspr_val_offset),
            scout   => sov(ex3_sspr_val_offset),
            din     => ex2_sspr_val,
            dout    => ex3_sspr_val_q);
ex3_rt_latch : tri_rlmreg_p
  generic map (width => ex3_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_rt_offset to ex3_rt_offset + ex3_rt_q'length-1),
            scout   => sov(ex3_rt_offset to ex3_rt_offset + ex3_rt_q'length-1),
            din     => mux_spr_ex2_rt             ,
            dout    => ex3_rt_q);
ex3_is_mfspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_mfspr_offset),
            scout   => sov(ex3_is_mfspr_offset),
            din     => ex2_is_mfspr_q             ,
            dout    => ex3_is_mfspr_q);
ex3_wait_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_wait_offset),
            scout   => sov(ex3_wait_offset),
            din     => ex2_wait,
            dout    => ex3_wait_q);
ex3_corr_rdata_latch : tri_rlmreg_p
  generic map (width => ex3_corr_rdata_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_corr_rdata_offset to ex3_corr_rdata_offset + ex3_corr_rdata_q'length-1),
            scout   => sov(ex3_corr_rdata_offset to ex3_corr_rdata_offset + ex3_corr_rdata_q'length-1),
            din     => ex2_corr_rdata,
            dout    => ex3_corr_rdata_q);
ex3_sprg_ce_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_sprg_ce_offset),
            scout   => sov(ex3_sprg_ce_offset),
            din     => ex2_sprg_ce,
            dout    => ex3_sprg_ce_q);
ex3_sprg_ue_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_sprg_ue_offset),
            scout   => sov(ex3_sprg_ue_offset),
            din     => ex2_sprg_ue,
            dout    => ex3_sprg_ue_q);
ex3_aspr_ce_addr_latch : tri_rlmreg_p
  generic map (width => ex3_aspr_ce_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_aspr_ce_addr_offset to ex3_aspr_ce_addr_offset + ex3_aspr_ce_addr_q'length-1),
            scout   => sov(ex3_aspr_ce_addr_offset to ex3_aspr_ce_addr_offset + ex3_aspr_ce_addr_q'length-1),
            din     => ex2_aspr_ce_addr_q         ,
            dout    => ex3_aspr_ce_addr_q);
ex3_dcr_read_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcr_read_offset),
            scout   => sov(ex3_dcr_read_offset),
            din     => ex2_dcr_read_q             ,
            dout    => ex3_dcr_read_q);
ex3_aspr_re_latch : tri_rlmreg_p
  generic map (width => ex3_aspr_re_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_aspr_re_offset to ex3_aspr_re_offset + ex3_aspr_re_q'length-1),
            scout   => sov(ex3_aspr_re_offset to ex3_aspr_re_offset + ex3_aspr_re_q'length-1),
            din     => ex2_aspr_re_q              ,
            dout    => ex3_aspr_re_q);
ex3_dcr_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcr_val_offset),
            scout   => sov(ex3_dcr_val_offset),
            din     => ex2_dcr_val_q              ,
            dout    => ex3_dcr_val_q);
ex3_dcr_user_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcr_user_offset),
            scout   => sov(ex3_dcr_user_offset),
            din     => ex2_dcr_user_q             ,
            dout    => ex3_dcr_user_q);
ex3_is_wrtee_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_wrtee_offset),
            scout   => sov(ex3_is_wrtee_offset),
            din     => ex2_is_wrtee_q             ,
            dout    => ex3_is_wrtee_q);
ex3_is_wrteei_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_wrteei_offset),
            scout   => sov(ex3_is_wrteei_offset),
            din     => ex2_is_wrteei_q            ,
            dout    => ex3_is_wrteei_q);
ex3_msr_gs_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_msr_gs_offset),
            scout   => sov(ex3_msr_gs_offset),
            din     => ex3_msr_gs_d,
            dout    => ex3_msr_gs_q);
ex4_tid_latch : tri_regk
  generic map (width => ex4_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_tid_q                  ,
            dout    => ex4_tid_q);
ex4_is_mtmsr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_is_mtmsr_q             ,
            dout(0) => ex4_is_mtmsr_q);
ex4_is_mtspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_is_mtspr_q             ,
            dout(0) => ex4_is_mtspr_q);
ex4_wait_wc_latch : tri_regk
  generic map (width => ex4_wait_wc_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_wait_wc_q              ,
            dout    => ex4_wait_wc_q);
ex4_is_msgclr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_is_msgclr_q            ,
            dout(0) => ex4_is_msgclr_q);
ex4_instr_latch : tri_regk
  generic map (width => ex4_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_instr_q                ,
            dout    => ex4_instr_q);
ex4_sspr_val_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_sspr_val_q             ,
            dout(0) => ex4_sspr_val_q);
ex4_rt_latch : tri_regk
  generic map (width => ex4_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(3),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_rt_q                   ,
            dout    => ex4_rt_q);
ex4_is_mfspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_is_mfspr_q             ,
            dout(0) => ex4_is_mfspr_q);
ex4_dcr_read_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_dcr_read_q             ,
            dout(0) => ex4_dcr_read_q);
ex4_wait_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_wait_q                 ,
            dout(0) => ex4_wait_q);
ex4_corr_rdata_latch : tri_regk
  generic map (width => ex4_corr_rdata_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(3),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_corr_rdata_q           ,
            dout    => ex4_corr_rdata_q);
ex4_sprg_ce_latch : tri_regk
  generic map (width => ex4_sprg_ce_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(3),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_sprg_ce_d,
            dout    => ex4_sprg_ce_q);
ex4_aspr_ce_addr_latch : tri_regk
  generic map (width => ex4_aspr_ce_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex3_sprg_ce    ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_aspr_ce_addr_q         ,
            dout    => ex4_aspr_ce_addr_q);
ex4_dcr_val_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_dcr_val_q              ,
            dout(0) => ex4_dcr_val_q);
ex4_dcr_user_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_dcr_user_q             ,
            dout(0) => ex4_dcr_user_q);
ex4_is_wrtee_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_is_wrtee_q             ,
            dout(0) => ex4_is_wrtee_q);
ex4_is_wrteei_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_is_wrteei_q            ,
            dout(0) => ex4_is_wrteei_q);
ex4_aspr_we_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_aspr_we_offset),
            scout   => sov(ex4_aspr_we_offset),
            din     => ex3_aspr_we,
            dout    => ex4_aspr_we_q);
ex4_aspr_addr_latch : tri_rlmreg_p
  generic map (width => ex4_aspr_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_aspr_addr_offset to ex4_aspr_addr_offset + ex4_aspr_addr_q'length-1),
            scout   => sov(ex4_aspr_addr_offset to ex4_aspr_addr_offset + ex4_aspr_addr_q'length-1),
            din     => ex3_aspr_addr,
            dout    => ex4_aspr_addr_q);
ex5_val_latch : tri_rlmreg_p
  generic map (width => ex5_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_val_offset to ex5_val_offset + ex5_val_q'length-1),
            scout   => sov(ex5_val_offset to ex5_val_offset + ex5_val_q'length-1),
            din     => ex5_val_d,
            dout    => ex5_val_q);
ex5_tid_latch : tri_rlmreg_p
  generic map (width => ex5_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_tid_offset to ex5_tid_offset + ex5_tid_q'length-1),
            scout   => sov(ex5_tid_offset to ex5_tid_offset + ex5_tid_q'length-1),
            din     => ex4_tid_q                  ,
            dout    => ex5_tid_q);
ex5_is_mtmsr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_mtmsr_offset),
            scout   => sov(ex5_is_mtmsr_offset),
            din     => ex4_is_mtmsr_q             ,
            dout    => ex5_is_mtmsr_q);
ex5_is_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_mtspr_offset),
            scout   => sov(ex5_is_mtspr_offset),
            din     => ex4_is_mtspr_q             ,
            dout    => ex5_is_mtspr_q);
ex5_wait_wc_latch : tri_rlmreg_p
  generic map (width => ex5_wait_wc_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_wait_wc_offset to ex5_wait_wc_offset + ex5_wait_wc_q'length-1),
            scout   => sov(ex5_wait_wc_offset to ex5_wait_wc_offset + ex5_wait_wc_q'length-1),
            din     => ex4_wait_wc_q              ,
            dout    => ex5_wait_wc_q);
ex5_is_msgclr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_msgclr_offset),
            scout   => sov(ex5_is_msgclr_offset),
            din     => ex4_is_msgclr_q            ,
            dout    => ex5_is_msgclr_q);
ex5_instr_latch : tri_rlmreg_p
  generic map (width => ex5_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_instr_offset to ex5_instr_offset + ex5_instr_q'length-1),
            scout   => sov(ex5_instr_offset to ex5_instr_offset + ex5_instr_q'length-1),
            din     => ex4_instr_q                ,
            dout    => ex5_instr_q);
ex5_sspr_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_sspr_val_offset),
            scout   => sov(ex5_sspr_val_offset),
            din     => ex4_sspr_val_q             ,
            dout    => ex5_sspr_val_q);
ex5_aspr_we_latch : tri_rlmreg_p
  generic map (width => ex5_aspr_we_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_aspr_we_offset to ex5_aspr_we_offset + ex5_aspr_we_q'length-1),
            scout   => sov(ex5_aspr_we_offset to ex5_aspr_we_offset + ex5_aspr_we_q'length-1),
            din     => ex5_aspr_we_d,
            dout    => ex5_aspr_we_q);
ex5_rt_latch : tri_rlmreg_p
  generic map (width => ex5_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_rt_offset to ex5_rt_offset + ex5_rt_q'length-1),
            scout   => sov(ex5_rt_offset to ex5_rt_offset + ex5_rt_q'length-1),
            din     => ex5_rt_d,
            dout    => ex5_rt_q);
ex5_wait_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_wait_offset),
            scout   => sov(ex5_wait_offset),
            din     => ex4_wait_q                 ,
            dout    => ex5_wait_q);
ex5_sprg_ce_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_sprg_ce_offset),
            scout   => sov(ex5_sprg_ce_offset),
            din     => ex4_sprg_ce_q(0)           ,
            dout    => ex5_sprg_ce_q);
ex5_dcr_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dcr_val_offset),
            scout   => sov(ex5_dcr_val_offset),
            din     => ex4_dcr_val,
            dout    => ex5_dcr_val_q);
ex5_dcr_read_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dcr_read_offset),
            scout   => sov(ex5_dcr_read_offset),
            din     => ex4_dcr_read_q             ,
            dout    => ex5_dcr_read_q);
ex5_dcr_user_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dcr_user_offset),
            scout   => sov(ex5_dcr_user_offset),
            din     => ex4_dcr_user_q             ,
            dout    => ex5_dcr_user_q);
ex5_aspr_addr_latch : tri_rlmreg_p
  generic map (width => ex5_aspr_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_aspr_addr_offset to ex5_aspr_addr_offset + ex5_aspr_addr_q'length-1),
            scout   => sov(ex5_aspr_addr_offset to ex5_aspr_addr_offset + ex5_aspr_addr_q'length-1),
            din     => ex5_aspr_addr_d,
            dout    => ex5_aspr_addr_q);
ex5_is_wrtee_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_wrtee_offset),
            scout   => sov(ex5_is_wrtee_offset),
            din     => ex4_is_wrtee_q             ,
            dout    => ex5_is_wrtee_q);
ex5_is_wrteei_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_wrteei_offset),
            scout   => sov(ex5_is_wrteei_offset),
            din     => ex4_is_wrteei_q            ,
            dout    => ex5_is_wrteei_q);
ex6_valid_latch : tri_rlmreg_p
  generic map (width => ex6_valid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_valid_offset to ex6_valid_offset + ex6_valid_q'length-1),
            scout   => sov(ex6_valid_offset to ex6_valid_offset + ex6_valid_q'length-1),
            din     => ex5_valid,
            dout    => ex6_valid_q);
ex6_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
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
ex6_tid_latch : tri_regk
  generic map (width => ex6_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex5_tid_q                  ,
            dout    => ex6_tid_q);
ex6_dbell_taken_latch : tri_regk
  generic map (width => ex6_dbell_taken_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => cpl_spr_ex5_dbell_taken    ,
            dout    => ex6_dbell_taken_q);
ex6_cdbell_taken_latch : tri_regk
  generic map (width => ex6_cdbell_taken_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => cpl_spr_ex5_cdbell_taken   ,
            dout    => ex6_cdbell_taken_q);
ex6_gdbell_taken_latch : tri_regk
  generic map (width => ex6_gdbell_taken_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => cpl_spr_ex5_gdbell_taken   ,
            dout    => ex6_gdbell_taken_q);
ex6_gcdbell_taken_latch : tri_regk
  generic map (width => ex6_gcdbell_taken_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => cpl_spr_ex5_gcdbell_taken  ,
            dout    => ex6_gcdbell_taken_q);
ex6_gmcdbell_taken_latch : tri_regk
  generic map (width => ex6_gmcdbell_taken_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => cpl_spr_ex5_gmcdbell_taken ,
            dout    => ex6_gmcdbell_taken_q);
ex6_rt_latch : tri_regk
  generic map (width => ex6_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(5),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex5_rt_q_b(64-regsize to 63) ,
            dout    => ex6_rt_q);
ex6_instr_latch : tri_regk
  generic map (width => ex6_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex5_instr_q                ,
            dout    => ex6_instr_q);
ex6_is_mtspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_is_mtspr_q             ,
            dout(0) => ex6_is_mtspr_q);
ex6_wait_wc_latch : tri_regk
  generic map (width => ex6_wait_wc_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act_data(5),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex5_wait_wc_q              ,
            dout    => ex6_wait_wc_q);
ex6_is_msgclr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_is_msgclr_q            ,
            dout(0) => ex6_is_msgclr_q);
ex6_sspr_val_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_sspr_val_q             ,
            dout(0) => ex6_sspr_val_q);
ex6_set_xucr0_cslc_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_nsl_thold_0_b,
            din(0)  => ex6_set_xucr0_cslc_d,
            dout(0) => ex6_set_xucr0_cslc_q);
ex6_set_xucr0_cul_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_nsl_thold_0_b,
            din(0)  => ex6_set_xucr0_cul_d,
            dout(0) => ex6_set_xucr0_cul_q);
ex6_set_xucr0_clo_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_nsl_thold_0_b,
            din(0)  => ex6_set_xucr0_clo_d,
            dout(0) => ex6_set_xucr0_clo_q);
ex6_wait_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_wait_q                 ,
            dout(0) => ex6_wait_q);
ex6_sprg_ce_latch : tri_regk
  generic map (width => ex6_sprg_ce_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex5_sprg_ce,
            dout    => ex6_sprg_ce_q);
ex6_dcr_val_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_dcr_val,
            dout(0) => ex6_dcr_val_q);
ex6_dcr_read_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_dcr_read_q             ,
            dout(0) => ex6_dcr_read_q);
ex6_dcr_user_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX6),
            mpw1_b  => mpw1_dc_b(DEX6), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_dcr_user_q             ,
            dout(0) => ex6_dcr_user_q);
ex2_any_mfspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_any_mfspr_d,
            dout(0) => ex2_any_mfspr_q);
ex2_any_mtspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX2),
            mpw1_b  => mpw1_dc_b(DEX2), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_any_mtspr_d,
            dout(0) => ex2_any_mtspr_q);
ex3_any_mfspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_any_mfspr_offset),
            scout   => sov(ex3_any_mfspr_offset),
            din     => ex2_any_mfspr_q            ,
            dout    => ex3_any_mfspr_q);
ex3_any_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX3),
            mpw1_b  => mpw1_dc_b(DEX3), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_any_mtspr_offset),
            scout   => sov(ex3_any_mtspr_offset),
            din     => ex2_any_mtspr_q            ,
            dout    => ex3_any_mtspr_q);
ex4_any_mfspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_any_mfspr_q            ,
            dout(0) => ex4_any_mfspr_q);
ex4_any_mtspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)     ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX4),
            mpw1_b  => mpw1_dc_b(DEX4), mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_any_mtspr_q            ,
            dout(0) => ex4_any_mtspr_q);
ex5_any_mfspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_any_mfspr_offset),
            scout   => sov(ex5_any_mfspr_offset),
            din     => ex4_any_mfspr_q            ,
            dout    => ex5_any_mfspr_q);
ex5_any_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DEX5),
            mpw1_b  => mpw1_dc_b(DEX5), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_any_mtspr_offset),
            scout   => sov(ex5_any_mtspr_offset),
            din     => ex4_any_mtspr_q            ,
            dout    => ex5_any_mtspr_q);
running_latch : tri_rlmreg_p
  generic map (width => running_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(running_offset to running_offset + running_q'length-1),
            scout   => sov(running_offset to running_offset + running_q'length-1),
            din     => running_d,
            dout    => running_q);
llpri_latch : tri_rlmreg_p
  generic map (width => llpri_q'length, init => 8, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => llpri_inc      ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(llpri_offset to llpri_offset + llpri_q'length-1),
            scout   => sov(llpri_offset to llpri_offset + llpri_q'length-1),
            din     => llpri_d,
            dout    => llpri_q);
dec_dbg_dis_latch : tri_rlmreg_p
  generic map (width => dec_dbg_dis_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dec_dbg_dis_offset to dec_dbg_dis_offset + dec_dbg_dis_q'length-1),
            scout   => sov(dec_dbg_dis_offset to dec_dbg_dis_offset + dec_dbg_dis_q'length-1),
            din     => dec_dbg_dis_d,
            dout    => dec_dbg_dis_q);
tb_dbg_dis_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(tb_dbg_dis_offset),
            scout   => sov(tb_dbg_dis_offset),
            din     => tb_dbg_dis_d,
            dout    => tb_dbg_dis_q);
tb_act_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(tb_act_offset),
            scout   => sov(tb_act_offset),
            din     => tb_act_d,
            dout    => tb_act_q);
ext_dbg_dis_latch : tri_rlmreg_p
  generic map (width => ext_dbg_dis_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ext_dbg_dis_offset to ext_dbg_dis_offset + ext_dbg_dis_q'length-1),
            scout   => sov(ext_dbg_dis_offset to ext_dbg_dis_offset + ext_dbg_dis_q'length-1),
            din     => ext_dbg_dis_d,
            dout    => ext_dbg_dis_q);
ram_mode_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ram_mode_offset),
            scout   => sov(ram_mode_offset),
            din     => pc_xu_ram_mode             ,
            dout    => ram_mode_q);
ram_thread_latch : tri_rlmreg_p
  generic map (width => ram_thread_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ram_thread_offset to ram_thread_offset + ram_thread_q'length-1),
            scout   => sov(ram_thread_offset to ram_thread_offset + ram_thread_q'length-1),
            din     => pc_xu_ram_thread           ,
            dout    => ram_thread_q);
msrovride_enab_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msrovride_enab_offset),
            scout   => sov(msrovride_enab_offset),
            din     => pc_xu_msrovride_enab       ,
            dout    => msrovride_enab_q);
waitimpl_val_latch : tri_rlmreg_p
  generic map (width => waitimpl_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(waitimpl_val_offset to waitimpl_val_offset + waitimpl_val_q'length-1),
            scout   => sov(waitimpl_val_offset to waitimpl_val_offset + waitimpl_val_q'length-1),
            din     => waitimpl_val_d,
            dout    => waitimpl_val_q);
waitrsv_val_latch : tri_rlmreg_p
  generic map (width => waitrsv_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(waitrsv_val_offset to waitrsv_val_offset + waitrsv_val_q'length-1),
            scout   => sov(waitrsv_val_offset to waitrsv_val_offset + waitrsv_val_q'length-1),
            din     => waitrsv_val_d,
            dout    => waitrsv_val_q);
an_ac_reservation_vld_latch : tri_rlmreg_p
  generic map (width => an_ac_reservation_vld_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(an_ac_reservation_vld_offset to an_ac_reservation_vld_offset + an_ac_reservation_vld_q'length-1),
            scout   => sov(an_ac_reservation_vld_offset to an_ac_reservation_vld_offset + an_ac_reservation_vld_q'length-1),
            din     => an_ac_reservation_vld      ,
            dout    => an_ac_reservation_vld_q);
an_ac_sleep_en_latch : tri_rlmreg_p
  generic map (width => an_ac_sleep_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(an_ac_sleep_en_offset to an_ac_sleep_en_offset + an_ac_sleep_en_q'length-1),
            scout   => sov(an_ac_sleep_en_offset to an_ac_sleep_en_offset + an_ac_sleep_en_q'length-1),
            din     => an_ac_sleep_en             ,
            dout    => an_ac_sleep_en_q);
an_ac_coreid_latch : tri_rlmreg_p
  generic map (width => an_ac_coreid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(an_ac_coreid_offset to an_ac_coreid_offset + an_ac_coreid_q'length-1),
            scout   => sov(an_ac_coreid_offset to an_ac_coreid_offset + an_ac_coreid_q'length-1),
            din     => an_ac_coreid               ,
            dout    => an_ac_coreid_q);
tb_update_enable_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(tb_update_enable_offset),
            scout   => sov(tb_update_enable_offset),
            din     => an_ac_tb_update_enable     ,
            dout    => tb_update_enable_q);
tb_update_pulse_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(tb_update_pulse_offset),
            scout   => sov(tb_update_pulse_offset),
            din     => an_ac_tb_update_pulse      ,
            dout    => tb_update_pulse_q);
tb_update_pulse_1_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(tb_update_pulse_1_offset),
            scout   => sov(tb_update_pulse_1_offset),
            din     => tb_update_pulse_q          ,
            dout    => tb_update_pulse_1_q);
pc_xu_reset_wd_complete_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_xu_reset_wd_complete_offset),
            scout   => sov(pc_xu_reset_wd_complete_offset),
            din     => pc_xu_reset_wd_complete    ,
            dout    => pc_xu_reset_wd_complete_q);
pc_xu_reset_3_complete_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_xu_reset_3_complete_offset),
            scout   => sov(pc_xu_reset_3_complete_offset),
            din     => pc_xu_reset_3_complete     ,
            dout    => pc_xu_reset_3_complete_q);
pc_xu_reset_2_complete_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_xu_reset_2_complete_offset),
            scout   => sov(pc_xu_reset_2_complete_offset),
            din     => pc_xu_reset_2_complete     ,
            dout    => pc_xu_reset_2_complete_q);
pc_xu_reset_1_complete_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_xu_reset_1_complete_offset),
            scout   => sov(pc_xu_reset_1_complete_offset),
            din     => pc_xu_reset_1_complete     ,
            dout    => pc_xu_reset_1_complete_q);
lsu_xu_dbell_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_xu_dbell_val_offset),
            scout   => sov(lsu_xu_dbell_val_offset),
            din     => lsu_xu_dbell_val           ,
            dout    => lsu_xu_dbell_val_q);
lsu_xu_dbell_type_latch : tri_rlmreg_p
  generic map (width => lsu_xu_dbell_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => dbell_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_xu_dbell_type_offset to lsu_xu_dbell_type_offset + lsu_xu_dbell_type_q'length-1),
            scout   => sov(lsu_xu_dbell_type_offset to lsu_xu_dbell_type_offset + lsu_xu_dbell_type_q'length-1),
            din     => lsu_xu_dbell_type          ,
            dout    => lsu_xu_dbell_type_q);
lsu_xu_dbell_brdcast_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => dbell_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_xu_dbell_brdcast_offset),
            scout   => sov(lsu_xu_dbell_brdcast_offset),
            din     => lsu_xu_dbell_brdcast       ,
            dout    => lsu_xu_dbell_brdcast_q);
lsu_xu_dbell_lpid_match_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => dbell_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_xu_dbell_lpid_match_offset),
            scout   => sov(lsu_xu_dbell_lpid_match_offset),
            din     => lsu_xu_dbell_lpid_match    ,
            dout    => lsu_xu_dbell_lpid_match_q);
lsu_xu_dbell_pirtag_latch : tri_rlmreg_p
  generic map (width => lsu_xu_dbell_pirtag_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => dbell_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_xu_dbell_pirtag_offset to lsu_xu_dbell_pirtag_offset + lsu_xu_dbell_pirtag_q'length-1),
            scout   => sov(lsu_xu_dbell_pirtag_offset to lsu_xu_dbell_pirtag_offset + lsu_xu_dbell_pirtag_q'length-1),
            din     => lsu_xu_dbell_pirtag        ,
            dout    => lsu_xu_dbell_pirtag_q);
dbell_present_latch : tri_rlmreg_p
  generic map (width => dbell_present_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbell_present_offset to dbell_present_offset + dbell_present_q'length-1),
            scout   => sov(dbell_present_offset to dbell_present_offset + dbell_present_q'length-1),
            din     => dbell_present_d,
            dout    => dbell_present_q);
cdbell_present_latch : tri_rlmreg_p
  generic map (width => cdbell_present_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(cdbell_present_offset to cdbell_present_offset + cdbell_present_q'length-1),
            scout   => sov(cdbell_present_offset to cdbell_present_offset + cdbell_present_q'length-1),
            din     => cdbell_present_d,
            dout    => cdbell_present_q);
gdbell_present_latch : tri_rlmreg_p
  generic map (width => gdbell_present_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gdbell_present_offset to gdbell_present_offset + gdbell_present_q'length-1),
            scout   => sov(gdbell_present_offset to gdbell_present_offset + gdbell_present_q'length-1),
            din     => gdbell_present_d,
            dout    => gdbell_present_q);
gcdbell_present_latch : tri_rlmreg_p
  generic map (width => gcdbell_present_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gcdbell_present_offset to gcdbell_present_offset + gcdbell_present_q'length-1),
            scout   => sov(gcdbell_present_offset to gcdbell_present_offset + gcdbell_present_q'length-1),
            din     => gcdbell_present_d,
            dout    => gcdbell_present_q);
gmcdbell_present_latch : tri_rlmreg_p
  generic map (width => gmcdbell_present_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gmcdbell_present_offset to gmcdbell_present_offset + gmcdbell_present_q'length-1),
            scout   => sov(gmcdbell_present_offset to gmcdbell_present_offset + gmcdbell_present_q'length-1),
            din     => gmcdbell_present_d,
            dout    => gmcdbell_present_q);
xucr0_clfc_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xucr0_clfc_offset),
            scout   => sov(xucr0_clfc_offset),
            din     => xucr0_clfc_d,
            dout    => xucr0_clfc_q);
iu_run_thread_latch : tri_rlmreg_p
  generic map (width => iu_run_thread_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iu_run_thread_offset to iu_run_thread_offset + iu_run_thread_q'length-1),
            scout   => sov(iu_run_thread_offset to iu_run_thread_offset + iu_run_thread_q'length-1),
            din     => iu_run_thread_d,
            dout    => iu_run_thread_q);
perf_event_latch : tri_rlmreg_p
  generic map (width => perf_event_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(perf_event_offset to perf_event_offset + perf_event_q'length-1),
            scout   => sov(perf_event_offset to perf_event_offset + perf_event_q'length-1),
            din     => perf_event_d,
            dout    => perf_event_q);
inj_sprg_ecc_latch : tri_rlmreg_p
  generic map (width => inj_sprg_ecc_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(inj_sprg_ecc_offset to inj_sprg_ecc_offset + inj_sprg_ecc_q'length-1),
            scout   => sov(inj_sprg_ecc_offset to inj_sprg_ecc_offset + inj_sprg_ecc_q'length-1),
            din     => pc_xu_inj_sprg_ecc         ,
            dout    => inj_sprg_ecc_q);
dbell_interrupt_latch : tri_rlmreg_p
  generic map (width => dbell_interrupt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbell_interrupt_offset to dbell_interrupt_offset + dbell_interrupt_q'length-1),
            scout   => sov(dbell_interrupt_offset to dbell_interrupt_offset + dbell_interrupt_q'length-1),
            din     => dbell_interrupt,
            dout    => dbell_interrupt_q);
cdbell_interrupt_latch : tri_rlmreg_p
  generic map (width => cdbell_interrupt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(cdbell_interrupt_offset to cdbell_interrupt_offset + cdbell_interrupt_q'length-1),
            scout   => sov(cdbell_interrupt_offset to cdbell_interrupt_offset + cdbell_interrupt_q'length-1),
            din     => cdbell_interrupt,
            dout    => cdbell_interrupt_q);
gdbell_interrupt_latch : tri_rlmreg_p
  generic map (width => gdbell_interrupt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gdbell_interrupt_offset to gdbell_interrupt_offset + gdbell_interrupt_q'length-1),
            scout   => sov(gdbell_interrupt_offset to gdbell_interrupt_offset + gdbell_interrupt_q'length-1),
            din     => gdbell_interrupt,
            dout    => gdbell_interrupt_q);
gcdbell_interrupt_latch : tri_rlmreg_p
  generic map (width => gcdbell_interrupt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gcdbell_interrupt_offset to gcdbell_interrupt_offset + gcdbell_interrupt_q'length-1),
            scout   => sov(gcdbell_interrupt_offset to gcdbell_interrupt_offset + gcdbell_interrupt_q'length-1),
            din     => gcdbell_interrupt,
            dout    => gcdbell_interrupt_q);
gmcdbell_interrupt_latch : tri_rlmreg_p
  generic map (width => gmcdbell_interrupt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(gmcdbell_interrupt_offset to gmcdbell_interrupt_offset + gmcdbell_interrupt_q'length-1),
            scout   => sov(gmcdbell_interrupt_offset to gmcdbell_interrupt_offset + gmcdbell_interrupt_q'length-1),
            din     => gmcdbell_interrupt,
            dout    => gmcdbell_interrupt_q);
iu_quiesce_latch : tri_rlmreg_p
  generic map (width => iu_quiesce_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iu_quiesce_offset to iu_quiesce_offset + iu_quiesce_q'length-1),
            scout   => sov(iu_quiesce_offset to iu_quiesce_offset + iu_quiesce_q'length-1),
            din     => iu_xu_quiesce              ,
            dout    => iu_quiesce_q);
lsu_quiesce_latch : tri_rlmreg_p
  generic map (width => lsu_quiesce_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_quiesce_offset to lsu_quiesce_offset + lsu_quiesce_q'length-1),
            scout   => sov(lsu_quiesce_offset to lsu_quiesce_offset + lsu_quiesce_q'length-1),
            din     => lsu_xu_quiesce             ,
            dout    => lsu_quiesce_q);
mm_quiesce_latch : tri_rlmreg_p
  generic map (width => mm_quiesce_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mm_quiesce_offset to mm_quiesce_offset + mm_quiesce_q'length-1),
            scout   => sov(mm_quiesce_offset to mm_quiesce_offset + mm_quiesce_q'length-1),
            din     => mm_xu_quiesce              ,
            dout    => mm_quiesce_q);
bx_quiesce_latch : tri_rlmreg_p
  generic map (width => bx_quiesce_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(bx_quiesce_offset to bx_quiesce_offset + bx_quiesce_q'length-1),
            scout   => sov(bx_quiesce_offset to bx_quiesce_offset + bx_quiesce_q'length-1),
            din     => bx_xu_quiesce              ,
            dout    => bx_quiesce_q);
quiesce_latch : tri_rlmreg_p
  generic map (width => quiesce_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(quiesce_offset to quiesce_offset + quiesce_q'length-1),
            scout   => sov(quiesce_offset to quiesce_offset + quiesce_q'length-1),
            din     => quiesce_d,
            dout    => quiesce_q);
cpl_quiesce_latch : tri_rlmreg_p
  generic map (width => cpl_quiesce_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(cpl_quiesce_offset to cpl_quiesce_offset + cpl_quiesce_q'length-1),
            scout   => sov(cpl_quiesce_offset to cpl_quiesce_offset + cpl_quiesce_q'length-1),
            din     => cpl_quiesce_d,
            dout    => cpl_quiesce_q);
quiesced_4cpl_latch : tri_rlmreg_p
  generic map (width => quiesced_4cpl_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(quiesced_4cpl_offset to quiesced_4cpl_offset + quiesced_4cpl_q'length-1),
            scout   => sov(quiesced_4cpl_offset to quiesced_4cpl_offset + quiesced_4cpl_q'length-1),
            din     => quiesced_4cpl_d,
            dout    => quiesced_4cpl_q);
quiesced_latch : tri_rlmreg_p
  generic map (width => quiesced_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(quiesced_offset to quiesced_offset + quiesced_q'length-1),
            scout   => sov(quiesced_offset to quiesced_offset + quiesced_q'length-1),
            din     => quiesced_d,
            dout    => quiesced_q);
instr_trace_mode_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(instr_trace_mode_offset),
            scout   => sov(instr_trace_mode_offset),
            din     => pc_xu_instr_trace_mode     ,
            dout    => instr_trace_mode_q);
instr_trace_tid_latch : tri_rlmreg_p
  generic map (width => instr_trace_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(instr_trace_tid_offset to instr_trace_tid_offset + instr_trace_tid_q'length-1),
            scout   => sov(instr_trace_tid_offset to instr_trace_tid_offset + instr_trace_tid_q'length-1),
            din     => pc_xu_instr_trace_tid      ,
            dout    => instr_trace_tid_q);
timer_update_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(timer_update_offset),
            scout   => sov(timer_update_offset),
            din     => timer_update_int,
            dout    => timer_update_q);

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


quiesced_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 0)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(quiesced_ctr_offset),
            scout   => sov(quiesced_ctr_offset),
            delay   => "1111",
            din     => quiesce_b_q,
            dout    => quiesce_ctr_zero_b);
quiesced_4cpl_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 0)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc(DX),
            mpw1_b  => mpw1_dc_b(DX), mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(quiesced_4cpl_ctr_offset),
            scout   => sov(quiesced_4cpl_ctr_offset),
            delay   => "1111",
            din     => cpl_quiesce_b_q,
            dout    => cpl_quiesce_ctr_zero_b);


siv(   0 to 399)                 <= sov(   1 to 399)       & scan_in(0);
scan_out(0)                      <= sov(   0);

siv(400 to siv'right)            <= sov(401 to siv'right)  & scan_in(1);
scan_out(1)                      <= sov(400);


bcfg_l : if sov_bcfg'length > 1 generate
siv_bcfg(0 to scan_right_bcfg-1) <= sov_bcfg(1 to scan_right_bcfg-1) & bcfg_scan_in;
bcfg_scan_out                    <= sov_bcfg(0);
end generate;
bcfg_s : if sov_bcfg'length <= 1 generate
bcfg_scan_out                    <= bcfg_scan_in;
sov_bcfg                         <= (others=>'0');
siv_bcfg                         <= (others=>'0');
end generate;

ccfg_l : if sov_ccfg'length > 1 generate
siv_ccfg(0 to scan_right_ccfg-1) <= sov_ccfg(1 to scan_right_ccfg-1) & ccfg_scan_in;
ccfg_scan_out                    <= sov_ccfg(0);
end generate;
ccfg_s : if sov_ccfg'length <= 1 generate
ccfg_scan_out                    <= ccfg_scan_in;
sov_ccfg                         <= (others=>'0');
siv_ccfg                         <= (others=>'0');
end generate;


end architecture xuq_spr_cspr;
