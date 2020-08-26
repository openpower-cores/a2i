-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU Bypass Unit
--
library ieee,ibm,support,tri;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;
use work.xuq_pkg.all;

entity xuq_byp is
generic (
   threads                             : integer := 4;
   expand_type                         : integer := 2;
   regsize                             : integer := 64;
   eff_ifar                            : integer := 62);
port (
   -- Clocks
   nclk                                : in  clk_logic;

   -- Power
   vdd                                 : inout power_logic;
   gnd                                 : inout power_logic;

   -- Pervasive
   d_mode_dc                           : in std_ulogic;
   delay_lclkr_dc                      : in std_ulogic;
   mpw1_dc_b                           : in std_ulogic;
   mpw2_dc_b                           : in std_ulogic;
   func_sl_force : in std_ulogic;
   func_sl_thold_0_b                   : in std_ulogic;
   func_nsl_force : in std_ulogic;
   func_nsl_thold_0_b                  : in std_ulogic;
   func_slp_sl_force : in std_ulogic;
   func_slp_sl_thold_0_b               : in std_ulogic;
   sg_0                                : in std_ulogic;
   scan_in                             : in std_ulogic_vector(0 to 1);
   scan_out                            : out std_ulogic_vector(0 to 1);

   pc_xu_trace_bus_enable              : in  std_ulogic;
   dec_byp_ex3_instr_trace_val         : in  std_ulogic;
   dec_byp_ex3_instr_trace_gate        : in  std_ulogic;

   -- Flushes
   xu_ex3_flush                        : in  std_ulogic_vector(0 to threads-1);
   xu_ex4_flush                        : in  std_ulogic_vector(0 to threads-1);
   xu_ex5_flush                        : in  std_ulogic_vector(0 to threads-1);

   dec_rf1_tid                         : in std_ulogic_vector(0 to threads-1);
   dec_ex1_tid                         : in std_ulogic_vector(0 to threads-1);
   dec_ex2_tid                         : in std_ulogic_vector(0 to threads-1);
   dec_ex3_tid                         : in std_ulogic_vector(0 to threads-1);
   dec_ex5_tid                         : in std_ulogic_vector(0 to threads-1);

   -- Decode Inputs
   dec_alu_rf1_sel                     : in  std_ulogic_vector(2 to 2);
   dec_byp_rf1_rs0_sel                 : in std_ulogic_vector(1 to 9);
   dec_byp_rf1_rs1_sel                 : in std_ulogic_vector(1 to 10);
   dec_byp_rf1_rs2_sel                 : in std_ulogic_vector(1 to 9);
   dec_byp_rf1_instr                   : in std_ulogic_vector(6 to 25);
   dec_byp_rf1_cr_so_update            : in std_ulogic_vector(0 to 1);
   dec_byp_ex3_val                     : in std_ulogic_vector(0 to threads-1);
   dec_byp_rf1_cr_we                   : in std_ulogic;
   dec_byp_rf1_is_mcrf                 : in std_ulogic;
   dec_byp_rf1_use_crfld0              : in std_ulogic;
   dec_byp_rf1_alu_cmp                 : in std_ulogic;
   dec_byp_rf1_is_mtcrf                : in std_ulogic;
   dec_byp_rf1_is_mtocrf               : in std_ulogic;
   dec_byp_rf1_is_isel                 : in std_ulogic;
   dec_byp_rf1_byp_val                 : in std_ulogic_vector(1 to 3);
   dec_byp_ex4_is_eratsxr              : in std_ulogic;
   dec_byp_rf1_ca_used                 : in std_ulogic;
   dec_byp_rf1_ov_used                 : in std_ulogic;
   dec_byp_ex4_dp_instr                : in std_ulogic;
   dec_byp_ex4_mtdp_val                : in std_ulogic;
   dec_byp_ex4_mfdp_val                : in std_ulogic;
   dec_byp_rf0_act                     : in std_ulogic;
   fxa_fxb_rf0_is_mfocrf               : in std_ulogic;

   dec_byp_ex1_spr_sel                 : in  std_ulogic;
   lsu_xu_ex5_wren                     : in  std_ulogic;
   dec_byp_ex4_is_mfcr                 : in  std_ulogic;
   spr_byp_ex4_is_mfxer                : in  std_ulogic_vector(0 to 3);
   dec_byp_ex3_tlb_sel                 : in  std_ulogic_vector(0 to 1);
   alu_ex2_div_done                    : in  std_ulogic;

   -- Slow SPR Bus
   slowspr_val_in                      : in  std_ulogic;
   slowspr_rw_in                       : in  std_ulogic;
   slowspr_etid_in                     : in  std_ulogic_vector(0 to 1);
   slowspr_addr_in                     : in  std_ulogic_vector(0 to 9);
   slowspr_done_in                     : in  std_ulogic;

   -- DCR Bus
   dec_byp_ex4_dcr_ack                 : in  std_ulogic;
   an_ac_dcr_act                       : in  std_ulogic;
   an_ac_dcr_read                      : in  std_ulogic;
   an_ac_dcr_etid                      : in  std_ulogic_vector(0 to 1);
   an_ac_dcr_data                      : in  std_ulogic_vector(64-regsize to 63);
   an_ac_dcr_done                      : in  std_ulogic;

   xu_iu_slowspr_done                  : out std_ulogic_vector(0 to 3);
   mux_cpl_slowspr_done                : out std_ulogic_vector(0 to 3);
   mux_cpl_slowspr_flush               : out std_ulogic_vector(0 to 3);

   -- Source Data
   dec_byp_rf1_imm                     : in std_ulogic_vector(64-regsize to 63);
   fxa_fxb_rf1_do0                     : in std_ulogic_vector(64-regsize to 63);
   fxa_fxb_rf1_do1                     : in std_ulogic_vector(64-regsize to 63);
   fxa_fxb_rf1_do2                     : in std_ulogic_vector(64-regsize to 63);

   -- Result Busses
   alu_byp_ex1_log_rt                  : in  std_ulogic_vector(64-regsize to 63);     -- ALU Logicals
   alu_byp_ex2_rt                      : in  std_ulogic_vector(64-regsize to 63);     -- ALU
   alu_byp_ex3_div_rt                  : in  std_ulogic_vector(64-regsize to 63);     -- Divide
   cpl_byp_ex3_spr_rt                  : in  std_ulogic_vector(64-regsize to 63);     -- CPL SPR
   spr_byp_ex3_spr_rt                  : in  std_ulogic_vector(64-regsize to 63);     -- SPR
   fspr_byp_ex3_spr_rt                 : in  std_ulogic_vector(64-regsize to 63);     -- FXU SPR
   lsu_xu_ex4_tlb_data                 : in  std_ulogic_vector(64-regsize to 63);     -- D-ERAT
   iu_xu_ex4_tlb_data                  : in  std_ulogic_vector(64-regsize to 63);     -- I-ERAT
   alu_byp_ex5_mul_rt                  : in  std_ulogic_vector(64-regsize to 63);     -- Multiply
   lsu_xu_rot_ex6_data_b               : in  std_ulogic_vector(64-regsize to 63);     -- Load/Store Hit
   lsu_xu_rot_rel_data                 : in  std_ulogic_vector(64-regsize to 63);     -- Load/Store Miss
   slowspr_data_in                     : in  std_ulogic_vector(64-regsize to 63);     -- Slow SPR

   -- Target Data
   byp_dec_rf1_xer_ca                  : out std_ulogic;
   byp_alu_ex1_rs0                     : out std_ulogic_vector(64-regsize to 63);
   byp_alu_ex1_rs1                     : out std_ulogic_vector(64-regsize to 63);
   byp_alu_ex1_mulsrc_0                : out std_ulogic_vector(64-regsize to 63);
   byp_alu_ex1_mulsrc_1                : out std_ulogic_vector(64-regsize to 63);
   byp_alu_ex1_divsrc_0                : out std_ulogic_vector(64-regsize to 63);
   byp_alu_ex1_divsrc_1                : out std_ulogic_vector(64-regsize to 63);
   xu_lsu_ex1_add_src0                 : out std_ulogic_vector(64-regsize to 63);
   xu_lsu_ex1_add_src1                 : out std_ulogic_vector(64-regsize to 63);

   -- Other Outputs
   xu_ex1_rs_is                        : out std_ulogic_vector(0 to 8);
   xu_ex1_ra_entry                     : out std_ulogic_vector(7 to 11);
   xu_ex1_rb                           : out std_ulogic_vector(64-regsize to 51);
   xu_ex4_rs_data                      : out std_ulogic_vector(64-regsize to 63);     -- TLB Write Data
   xu_mm_derat_epn                     : out std_ulogic_vector(62-eff_ifar to 51);    -- DERAT EPN
   xu_pc_ram_data                      : out std_ulogic_vector(64-regsize to 63);     -- RAM Result Capture
   mux_spr_ex6_rt                      : out std_ulogic_vector(64-regsize to 63);     -- SPR Write Data
   byp_xer_si                          : out std_ulogic_vector(0 to 7*threads-1);

   -- FU CR Update
   fu_xu_ex4_cr_val                    : in std_ulogic_vector(0 to threads-1);
   fu_xu_ex4_cr_noflush                : in std_ulogic_vector(0 to threads-1);
   fu_xu_ex4_cr0                       : in std_ulogic_vector(0 to 3);
   fu_xu_ex4_cr0_bf                    : in std_ulogic_vector(0 to 2);
   fu_xu_ex4_cr1                       : in std_ulogic_vector(0 to 3);
   fu_xu_ex4_cr1_bf                    : in std_ulogic_vector(0 to 2);
   fu_xu_ex4_cr2                       : in std_ulogic_vector(0 to 3);
   fu_xu_ex4_cr2_bf                    : in std_ulogic_vector(0 to 2);
   fu_xu_ex4_cr3                       : in std_ulogic_vector(0 to 3);
   fu_xu_ex4_cr3_bf                    : in std_ulogic_vector(0 to 2);

   -- MMU CR Update
   mm_xu_cr0_eq_valid                  : in  std_ulogic_vector(0 to threads-1);
   mm_xu_cr0_eq                        : in  std_ulogic_vector(0 to threads-1);

   -- L2 CR Update
   an_ac_stcx_complete                 : in  std_ulogic_vector(0 to threads-1);
   an_ac_stcx_pass                     : in  std_ulogic_vector(0 to threads-1);

   -- icswx CR Update
   an_ac_back_inv                      : in std_ulogic;
   an_ac_back_inv_addr                 : in std_ulogic_vector(58 to 63);
   an_ac_back_inv_target_bit3          : in std_ulogic;

   -- MT/MFDCR
   lsu_xu_ex4_mtdp_cr_status           : in std_ulogic;
   lsu_xu_ex4_mfdp_cr_status           : in std_ulogic;

   -- ldawx/wchkall
   dec_byp_ex4_is_wchkall              : in std_ulogic;
   lsu_xu_ex4_cr_upd                   : in std_ulogic;
   lsu_xu_ex5_cr_rslt                  : in std_ulogic;

   -- CR/XER Signals
   alu_byp_ex2_cr_recform              : in std_ulogic_vector(0 to 3);
   alu_byp_ex5_cr_mul                  : in std_ulogic_vector(0 to 4);
   alu_byp_ex3_cr_div                  : in std_ulogic_vector(0 to 4);
   alu_byp_ex2_xer                     : in std_ulogic_vector(0 to 3);
   alu_byp_ex5_xer_mul                 : in std_ulogic_vector(0 to 3);
   alu_byp_ex3_xer_div                 : in std_ulogic_vector(0 to 3);
   alu_ex4_mul_done                    : in std_ulogic;
   spr_byp_ex4_is_mtxer                : in std_ulogic_vector(0 to threads-1);
   byp_cpl_ex1_cr_bit                  : out std_ulogic;

   -- ALU isel controls
   byp_alu_rf1_isel_fcn                : out std_ulogic_vector(0 to 3);

   -- SPR Inputs
   spr_msr_cm                          : in  std_ulogic_vector(0 to threads-1);
   dec_byp_ex5_instr                   : in std_ulogic_vector(12 to 19);

   byp_perf_tx_events                  : out std_ulogic_vector(0 to 3*threads-1);

   -- GPR Bypass
   mux_cpl_ex4_rt                      : out std_ulogic_vector(64-regsize to 63);
   byp_spr_ex6_rt                      : out std_ulogic_vector(64-regsize to 63);
   xu_lsu_ex1_store_data               : out std_ulogic_vector(64-regsize to 63);
   fxu_spr_ex1_rs2                     : out std_ulogic_vector(42 to 55);
   fxu_spr_ex1_rs1                     : out std_ulogic_vector(54 to 63);
   fxu_spr_ex1_rs0                     : out std_ulogic_vector(52 to 63);   
   fxb_fxa_ex7_wd0                     : out std_ulogic_vector(64-regsize to 63);
   
   byp_grp0_debug                      : out std_ulogic_vector( 0 to 87);
   byp_grp1_debug                      : out std_ulogic_vector( 0 to 87);
   byp_grp2_debug                      : out std_ulogic_vector( 0 to 87);
   byp_grp3_debug                      : out std_ulogic_vector(15 to 87);
   byp_grp4_debug                      : out std_ulogic_vector(14 to 87);
   byp_grp5_debug                      : out std_ulogic_vector(15 to 87);
   byp_grp6_debug                      : out std_ulogic_vector(0 to 87);
   byp_grp7_debug                      : out std_ulogic_vector(0 to 87);
   byp_grp8_debug                      : out std_ulogic_vector(22 to 87)
   );
   
--  synopsys translate_off
--  synopsys translate_on

end xuq_byp;
architecture xuq_byp of xuq_byp is

constant tidn                                   : std_ulogic := '0';

signal siv, sov                                 : std_ulogic_vector(0 to 1);
signal byp_ex5_cr_rt                            : std_ulogic_vector(32 to 63);
signal byp_ex5_xer_rt                           : std_ulogic_vector(54 to 63);
signal ex1_mfocrf_rt                            : std_ulogic_vector(64-regsize to 63);
signal byp_ex5_mtcrxer                          : std_ulogic_vector(32 to 63);
signal byp_ex5_tlb_rt                           : std_ulogic_vector(51 to 51);
signal byp_xer_so                               : std_ulogic_vector(0 to threads-1);
signal xer_cr_ex1_xer_ov_in_pipe                : std_ulogic;
signal xer_cr_ex2_xer_ov_in_pipe                : std_ulogic;
signal xer_cr_ex3_xer_ov_in_pipe                : std_ulogic;
signal xer_cr_ex5_xer_ov_in_pipe                : std_ulogic;
signal trace_bus_enable                         : std_ulogic;

begin

---------------------------------------------------------------------
-- GPR
---------------------------------------------------------------------
xu_byp_gpr : entity work.xuq_byp_gpr(xuq_byp_gpr)
generic map(
   threads                             => threads,
   expand_type                         => expand_type,
   regsize                             => regsize,
   eff_ifar                            => eff_ifar)
port map(
   nclk                                => nclk,
   vdd                                 => vdd,
   gnd                                 => gnd,
   d_mode_dc                           => d_mode_dc,
   delay_lclkr_dc                      => delay_lclkr_dc,
   mpw1_dc_b                           => mpw1_dc_b,
   mpw2_dc_b                           => mpw2_dc_b,
   func_sl_force => func_sl_force,
   func_sl_thold_0_b                   => func_sl_thold_0_b,
   func_slp_sl_force => func_slp_sl_force,
   func_slp_sl_thold_0_b               => func_slp_sl_thold_0_b,
   func_nsl_force => func_nsl_force,
   func_nsl_thold_0_b                  => func_nsl_thold_0_b,
   sg_0                                => sg_0,
   scan_in                             => scan_in(0),
   scan_out                            => scan_out(0),
   pc_xu_trace_bus_enable              => pc_xu_trace_bus_enable,
   dec_byp_ex3_instr_trace_val         => dec_byp_ex3_instr_trace_val,
   dec_byp_ex3_instr_trace_gate        => dec_byp_ex3_instr_trace_gate,
   trace_bus_enable                    => trace_bus_enable,
   dec_rf1_tid                         => dec_rf1_tid,
   dec_ex2_tid                         => dec_ex2_tid,
   dec_byp_rf0_act                     => dec_byp_rf0_act,
   dec_alu_rf1_sel                     => dec_alu_rf1_sel,
   dec_byp_rf1_rs0_sel                 => dec_byp_rf1_rs0_sel,
   dec_byp_rf1_rs1_sel                 => dec_byp_rf1_rs1_sel,
   dec_byp_rf1_rs2_sel                 => dec_byp_rf1_rs2_sel,
   fxa_fxb_rf0_is_mfocrf               => fxa_fxb_rf0_is_mfocrf,
   dec_byp_ex1_spr_sel                 => dec_byp_ex1_spr_sel,
   alu_ex2_div_done                    => alu_ex2_div_done,
   dec_byp_ex3_tlb_sel                 => dec_byp_ex3_tlb_sel,
   alu_ex4_mul_done                    => alu_ex4_mul_done,
   dec_byp_ex4_is_mfcr                 => dec_byp_ex4_is_mfcr,
   spr_byp_ex4_is_mfxer                => spr_byp_ex4_is_mfxer,
   lsu_xu_ex5_wren                     => lsu_xu_ex5_wren,
   slowspr_val_in                      => slowspr_val_in,
   slowspr_rw_in                       => slowspr_rw_in,
   slowspr_etid_in                     => slowspr_etid_in,
   slowspr_addr_in                     => slowspr_addr_in,
   slowspr_done_in                     => slowspr_done_in,
   dec_byp_ex4_dcr_ack                 => dec_byp_ex4_dcr_ack,
   an_ac_dcr_act                       => an_ac_dcr_act,
   an_ac_dcr_read                      => an_ac_dcr_read,
   an_ac_dcr_etid                      => an_ac_dcr_etid,
   an_ac_dcr_data                      => an_ac_dcr_data,
   an_ac_dcr_done                      => an_ac_dcr_done,
   xu_iu_slowspr_done                  => xu_iu_slowspr_done,
   mux_cpl_slowspr_done                => mux_cpl_slowspr_done,
   mux_cpl_slowspr_flush               => mux_cpl_slowspr_flush,
   dec_byp_rf1_imm                     => dec_byp_rf1_imm,
   fxa_fxb_rf1_do0                     => fxa_fxb_rf1_do0,
   fxa_fxb_rf1_do1                     => fxa_fxb_rf1_do1,
   fxa_fxb_rf1_do2                     => fxa_fxb_rf1_do2,
   alu_byp_ex1_log_rt                  => alu_byp_ex1_log_rt,                  -- ALU Logicals
   alu_byp_ex2_rt                      => alu_byp_ex2_rt,                      -- ALU
   alu_byp_ex3_div_rt                  => alu_byp_ex3_div_rt,                  -- Divide
   cpl_byp_ex3_spr_rt                  => cpl_byp_ex3_spr_rt,                  -- CPL SPR
   spr_byp_ex3_spr_rt                  => spr_byp_ex3_spr_rt,                  -- SPR
   fspr_byp_ex3_spr_rt                 => fspr_byp_ex3_spr_rt,                 -- FXU SPR
   lsu_xu_ex4_tlb_data                 => lsu_xu_ex4_tlb_data,                 -- D-ERAT
   iu_xu_ex4_tlb_data                  => iu_xu_ex4_tlb_data,                  -- I-ERAT
   alu_byp_ex5_mul_rt                  => alu_byp_ex5_mul_rt,                  -- Multiply
   lsu_xu_rot_ex6_data_b               => lsu_xu_rot_ex6_data_b,               -- Load/Store Hit
   lsu_xu_rot_rel_data                 => lsu_xu_rot_rel_data,                 -- Load/Store Miss
   slowspr_data_in                     => slowspr_data_in,                     -- Slow SPR
   byp_ex5_cr_rt                       => byp_ex5_cr_rt,
   byp_ex5_xer_rt                      => byp_ex5_xer_rt,
   ex1_mfocrf_rt                       => ex1_mfocrf_rt,
   byp_alu_ex1_rs0                     => byp_alu_ex1_rs0,
   byp_alu_ex1_rs1                     => byp_alu_ex1_rs1,
   byp_alu_ex1_mulsrc_0                => byp_alu_ex1_mulsrc_0,
   byp_alu_ex1_mulsrc_1                => byp_alu_ex1_mulsrc_1,
   byp_alu_ex1_divsrc_0                => byp_alu_ex1_divsrc_0,
   byp_alu_ex1_divsrc_1                => byp_alu_ex1_divsrc_1,
   xu_lsu_ex1_add_src0                 => xu_lsu_ex1_add_src0,
   xu_lsu_ex1_add_src1                 => xu_lsu_ex1_add_src1,
   xu_ex1_rs_is                        => xu_ex1_rs_is,
   xu_ex1_ra_entry                     => xu_ex1_ra_entry,
   xu_ex1_rb                           => xu_ex1_rb,
   xu_ex4_rs_data                      => xu_ex4_rs_data,                      -- TLB Write Data
   xu_mm_derat_epn                     => xu_mm_derat_epn,                     -- DERAT EPN
   xu_pc_ram_data                      => xu_pc_ram_data,                      -- RAM Result Capture
   mux_spr_ex6_rt                      => mux_spr_ex6_rt,                      -- SPR Write Data
   spr_msr_cm                          => spr_msr_cm,
   mux_cpl_ex4_rt                      => mux_cpl_ex4_rt,
   byp_spr_ex6_rt                      => byp_spr_ex6_rt,
   xu_lsu_ex1_store_data               => xu_lsu_ex1_store_data,
   fxu_spr_ex1_rs2                     => fxu_spr_ex1_rs2,
   fxu_spr_ex1_rs1                     => fxu_spr_ex1_rs1,
   fxu_spr_ex1_rs0                     => fxu_spr_ex1_rs0,
   fxb_fxa_ex7_wd0                     => fxb_fxa_ex7_wd0,
   byp_ex5_mtcrxer                     => byp_ex5_mtcrxer,
   byp_ex5_tlb_rt                      => byp_ex5_tlb_rt,
   byp_grp0_debug                      => byp_grp0_debug,
   byp_grp1_debug                      => byp_grp1_debug,
   byp_grp2_debug                      => byp_grp2_debug,
   byp_grp3_debug                      => byp_grp3_debug,
   byp_grp4_debug                      => byp_grp4_debug,
   byp_grp5_debug                      => byp_grp5_debug
   );


---------------------------------------------------------------------
-- CR
---------------------------------------------------------------------
xu_byp_cr : entity work.xuq_byp_cr(xuq_byp_cr)
generic map(
   threads                         => threads,
   expand_type                     => expand_type,
   regsize                         => regsize)
port map(
   nclk                            => nclk,
   vdd                             => vdd,
   gnd                             => gnd,
   d_mode_dc                       => d_mode_dc,
   delay_lclkr_dc                  => delay_lclkr_dc,
   mpw1_dc_b                       => mpw1_dc_b,
   mpw2_dc_b                       => mpw2_dc_b,
   func_sl_force => func_sl_force,
   func_sl_thold_0_b               => func_sl_thold_0_b,
   func_nsl_force => func_nsl_force,
   func_nsl_thold_0_b              => func_nsl_thold_0_b,
   func_slp_sl_force => func_slp_sl_force,
   func_slp_sl_thold_0_b           => func_slp_sl_thold_0_b,
   sg_0                            => sg_0,
   scan_in                         => siv(0),
   scan_out                        => sov(0),
   trace_bus_enable                => trace_bus_enable,
   dec_byp_ex3_val                 => dec_byp_ex3_val,
   xu_ex3_flush                    => xu_ex3_flush,
   xu_ex4_flush                    => xu_ex4_flush,
   xu_ex5_flush                    => xu_ex5_flush,
   rf1_tid                         => dec_rf1_tid,
   ex1_tid                         => dec_ex1_tid,
   ex2_tid                         => dec_ex2_tid,
   ex3_tid                         => dec_ex3_tid,
   ex5_tid                         => dec_ex5_tid,
   rf1_instr                       => dec_byp_rf1_instr,
   dec_byp_rf1_cr_so_update        => dec_byp_rf1_cr_so_update,
   dec_byp_rf1_cr_we               => dec_byp_rf1_cr_we,
   dec_byp_rf1_is_mcrf             => dec_byp_rf1_is_mcrf,
   dec_byp_rf1_use_crfld0          => dec_byp_rf1_use_crfld0,
   dec_byp_rf1_alu_cmp             => dec_byp_rf1_alu_cmp,
   dec_byp_rf1_is_mtcrf            => dec_byp_rf1_is_mtcrf,
   dec_byp_rf1_is_mtocrf           => dec_byp_rf1_is_mtocrf,
   fxa_fxb_rf0_is_mfocrf           => fxa_fxb_rf0_is_mfocrf,
   dec_byp_rf1_is_isel             => dec_byp_rf1_is_isel,
   dec_byp_rf1_byp_val             => dec_byp_rf1_byp_val,
   dec_byp_rf0_act                 => dec_byp_rf0_act,
   dec_byp_ex4_is_eratsxr          => dec_byp_ex4_is_eratsxr,
   dec_byp_ex4_dp_instr            => dec_byp_ex4_dp_instr,
   dec_byp_ex4_mtdp_val            => dec_byp_ex4_mtdp_val,
   dec_byp_ex4_mfdp_val            => dec_byp_ex4_mfdp_val,
   lsu_xu_ex4_mtdp_cr_status       => lsu_xu_ex4_mtdp_cr_status,
   lsu_xu_ex4_mfdp_cr_status       => lsu_xu_ex4_mfdp_cr_status,
   dec_byp_ex4_is_wchkall          => dec_byp_ex4_is_wchkall,
   lsu_xu_ex4_cr_upd               => lsu_xu_ex4_cr_upd,
   lsu_xu_ex5_cr_rslt              => lsu_xu_ex5_cr_rslt,
   byp_cpl_ex1_cr_bit              => byp_cpl_ex1_cr_bit,
   byp_alu_rf1_isel_fcn            => byp_alu_rf1_isel_fcn,
   alu_byp_ex2_cr_recform          => alu_byp_ex2_cr_recform,
   alu_byp_ex5_cr_mul              => alu_byp_ex5_cr_mul,
   alu_byp_ex3_cr_div              => alu_byp_ex3_cr_div,
   alu_ex2_div_done                => alu_ex2_div_done,
   fu_xu_ex4_cr_val                => fu_xu_ex4_cr_val,
   fu_xu_ex4_cr_noflush            => fu_xu_ex4_cr_noflush,
   fu_xu_ex4_cr0                   => fu_xu_ex4_cr0,
   fu_xu_ex4_cr0_bf                => fu_xu_ex4_cr0_bf,
   fu_xu_ex4_cr1                   => fu_xu_ex4_cr1,
   fu_xu_ex4_cr1_bf                => fu_xu_ex4_cr1_bf,
   fu_xu_ex4_cr2                   => fu_xu_ex4_cr2,
   fu_xu_ex4_cr2_bf                => fu_xu_ex4_cr2_bf,
   fu_xu_ex4_cr3                   => fu_xu_ex4_cr3,
   fu_xu_ex4_cr3_bf                => fu_xu_ex4_cr3_bf,
   mm_xu_cr0_eq_valid              => mm_xu_cr0_eq_valid,
   mm_xu_cr0_eq                    => mm_xu_cr0_eq,
   an_ac_stcx_complete             => an_ac_stcx_complete,
   an_ac_stcx_pass                 => an_ac_stcx_pass,
   an_ac_back_inv                  => an_ac_back_inv,
   an_ac_back_inv_addr             => an_ac_back_inv_addr,
   an_ac_back_inv_target_bit3      => an_ac_back_inv_target_bit3,
   byp_ex5_mtcrxer                 => byp_ex5_mtcrxer,
   byp_ex5_tlb_rt                  => byp_ex5_tlb_rt,
   ex5_cr_rt                       => byp_ex5_cr_rt,
   ex1_mfocrf_rt                   => ex1_mfocrf_rt,
   dec_cr_ex5_instr                => dec_byp_ex5_instr,
   byp_perf_tx_events              => byp_perf_tx_events,
   byp_xer_so                      => byp_xer_so,
   xer_cr_ex1_xer_ov_in_pipe       => xer_cr_ex1_xer_ov_in_pipe,
   xer_cr_ex2_xer_ov_in_pipe       => xer_cr_ex2_xer_ov_in_pipe,
   xer_cr_ex3_xer_ov_in_pipe       => xer_cr_ex3_xer_ov_in_pipe,
   xer_cr_ex5_xer_ov_in_pipe       => xer_cr_ex5_xer_ov_in_pipe,
   cr_grp0_debug                   => byp_grp6_debug,
   cr_grp1_debug                   => byp_grp7_debug
   );

---------------------------------------------------------------------
-- XER
---------------------------------------------------------------------
xu_byp_xer : entity work.xuq_byp_xer(xuq_byp_xer)
generic map(
   threads                         => threads,
   expand_type                     => expand_type,
   regsize                         => regsize)
port map(
   nclk                            => nclk,
   vdd                             => vdd,
   gnd                             => gnd,
   d_mode_dc                       => d_mode_dc,
   delay_lclkr_dc                  => delay_lclkr_dc,
   mpw1_dc_b                       => mpw1_dc_b,
   mpw2_dc_b                       => mpw2_dc_b,
   func_sl_force => func_sl_force,
   func_sl_thold_0_b               => func_sl_thold_0_b,
   func_slp_sl_force => func_slp_sl_force,
   func_slp_sl_thold_0_b           => func_slp_sl_thold_0_b,
   sg_0                            => sg_0,
   scan_in                         => siv(1),
   scan_out                        => sov(1),
   trace_bus_enable                => trace_bus_enable,
   dec_byp_rf1_ca_used             => dec_byp_rf1_ca_used,
   dec_byp_rf1_ov_used             => dec_byp_rf1_ov_used,
   rf1_tid                         => dec_rf1_tid,
   ex5_tid                         => dec_ex5_tid,
   dec_byp_ex3_val                 => dec_byp_ex3_val,
   dec_byp_rf1_byp_val             => dec_byp_rf1_byp_val(2 to 3),
   xu_ex3_flush                    => xu_ex3_flush,
   xu_ex4_flush                    => xu_ex4_flush,
   xu_ex5_flush                    => xu_ex5_flush,
   byp_ex5_xer_rt                  => byp_ex5_xer_rt,
   alu_ex4_mul_done                => alu_ex4_mul_done,
   alu_ex2_div_done                => alu_ex2_div_done,
   alu_byp_ex2_xer                 => alu_byp_ex2_xer,
   alu_byp_ex5_xer_mul             => alu_byp_ex5_xer_mul,
   alu_byp_ex3_xer_div             => alu_byp_ex3_xer_div,
   spr_byp_ex4_is_mtxer            => spr_byp_ex4_is_mtxer,
   byp_ex5_mtcrxer                 => byp_ex5_mtcrxer,
   byp_xer_si                      => byp_xer_si,
   byp_xer_so                      => byp_xer_so,
   xer_cr_ex1_xer_ov_in_pipe       => xer_cr_ex1_xer_ov_in_pipe,
   xer_cr_ex2_xer_ov_in_pipe       => xer_cr_ex2_xer_ov_in_pipe,
   xer_cr_ex3_xer_ov_in_pipe       => xer_cr_ex3_xer_ov_in_pipe,
   xer_cr_ex5_xer_ov_in_pipe       => xer_cr_ex5_xer_ov_in_pipe,
   byp_dec_rf1_xer_ca              => byp_dec_rf1_xer_ca,
   xer_debug                       => byp_grp8_debug);


siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in(1);
scan_out(1) <= sov(0);

end architecture xuq_byp;
