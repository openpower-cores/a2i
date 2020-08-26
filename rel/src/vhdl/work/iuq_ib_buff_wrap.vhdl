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
--* TITLE: Instruction buffer wrapper
--*
--* NAME: iuq_ib_buff_wrap.vhdl
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

entity iuq_ib_buff_wrap is
  generic(expand_type           : integer := 2;
          uc_ifar               : integer := 21);
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in  clk_logic;
     pc_iu_func_sl_thold_2      : in  std_ulogic_vector(0 to 3);
     pc_iu_sg_2                 : in  std_ulogic_vector(0 to 3);
     clkoff_b                   : in  std_ulogic_vector(0 to 3);
     an_ac_scan_dis_dc_b        : in  std_ulogic_vector(0 to 3);
     tc_ac_ccflush_dc           : in  std_ulogic;
     delay_lclkr                : in  std_ulogic_vector(5 to 8);
     mpw1_b                     : in  std_ulogic_vector(5 to 8);
     iuq_b0_scan_in             : in  std_ulogic;
     iuq_b0_scan_out            : out std_ulogic;
     iuq_b1_scan_in             : in  std_ulogic;
     iuq_b1_scan_out            : out std_ulogic;
     iuq_b2_scan_in             : in  std_ulogic;
     iuq_b2_scan_out            : out std_ulogic;
     iuq_b3_scan_in             : in  std_ulogic;
     iuq_b3_scan_out            : out std_ulogic;

     spr_dec_mask_pt_in_t0      : in  std_ulogic_vector(0 to 31);
     spr_dec_mask_pt_in_t1      : in  std_ulogic_vector(0 to 31);
     spr_dec_mask_pt_in_t2      : in  std_ulogic_vector(0 to 31);
     spr_dec_mask_pt_in_t3      : in  std_ulogic_vector(0 to 31);
     spr_dec_mask_pt_out_t0     : out std_ulogic_vector(0 to 31);
     spr_dec_mask_pt_out_t1     : out std_ulogic_vector(0 to 31);
     spr_dec_mask_pt_out_t2     : out std_ulogic_vector(0 to 31);
     spr_dec_mask_pt_out_t3     : out std_ulogic_vector(0 to 31);
     fdep_dbg_data_pt_in        : in  std_ulogic_vector(0 to 87);
     fdep_dbg_data_pt_out       : out std_ulogic_vector(0 to 87);
     fdep_perf_event_pt_in_t0   : in  std_ulogic_vector(0 to 11);
     fdep_perf_event_pt_in_t1   : in  std_ulogic_vector(0 to 11);
     fdep_perf_event_pt_in_t2   : in  std_ulogic_vector(0 to 11);
     fdep_perf_event_pt_in_t3   : in  std_ulogic_vector(0 to 11);
     fdep_perf_event_pt_out_t0  : out std_ulogic_vector(0 to 11);
     fdep_perf_event_pt_out_t1  : out std_ulogic_vector(0 to 11);
     fdep_perf_event_pt_out_t2  : out std_ulogic_vector(0 to 11);
     fdep_perf_event_pt_out_t3  : out std_ulogic_vector(0 to 11);

     pc_iu_trace_bus_enable     : in  std_ulogic;
     pc_iu_event_bus_enable     : in  std_ulogic;
     ib_dbg_data                : out std_ulogic_vector(0 to 63);
     ib_perf_event_t0           : out std_ulogic_vector(0 to 1);
     ib_perf_event_t1           : out std_ulogic_vector(0 to 1);
     ib_perf_event_t2           : out std_ulogic_vector(0 to 1);
     ib_perf_event_t3           : out std_ulogic_vector(0 to 1);
     xu_iu_flush                : in  std_ulogic_vector(0 to 3);
     uc_flush_tid               : in  std_ulogic_vector(0 to 3);
     fdec_ibuf_stall_t0         : in  std_ulogic;
     fdec_ibuf_stall_t1         : in  std_ulogic;
     fdec_ibuf_stall_t2         : in  std_ulogic;
     fdec_ibuf_stall_t3         : in  std_ulogic;
     ib_ic_below_water          : out std_ulogic_vector(0 to 3);
     ib_ic_empty                : out std_ulogic_vector(0 to 3);
     bp_ib_iu4_t0_val           : in  std_ulogic_vector(0 to 3);
     bp_ib_iu4_t1_val           : in  std_ulogic_vector(0 to 3);
     bp_ib_iu4_t2_val           : in  std_ulogic_vector(0 to 3);
     bp_ib_iu4_t3_val           : in  std_ulogic_vector(0 to 3);
     bp_ib_iu4_ifar_t0          : in  EFF_IFAR;
     bp_ib_iu3_0_instr_t0       : in  std_ulogic_vector(0 to 31);
     bp_ib_iu4_0_instr_t0       : in  std_ulogic_vector(32 to 43);
     bp_ib_iu4_1_instr_t0       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_2_instr_t0       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_3_instr_t0       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_ifar_t1          : in  EFF_IFAR;
     bp_ib_iu3_0_instr_t1       : in  std_ulogic_vector(0 to 31);
     bp_ib_iu4_0_instr_t1       : in  std_ulogic_vector(32 to 43);
     bp_ib_iu4_1_instr_t1       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_2_instr_t1       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_3_instr_t1       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_ifar_t2          : in  EFF_IFAR;
     bp_ib_iu3_0_instr_t2       : in  std_ulogic_vector(0 to 31);
     bp_ib_iu4_0_instr_t2       : in  std_ulogic_vector(32 to 43);
     bp_ib_iu4_1_instr_t2       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_2_instr_t2       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_3_instr_t2       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_ifar_t3          : in  EFF_IFAR;
     bp_ib_iu3_0_instr_t3       : in  std_ulogic_vector(0 to 31);
     bp_ib_iu4_0_instr_t3       : in  std_ulogic_vector(32 to 43);
     bp_ib_iu4_1_instr_t3       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_2_instr_t3       : in  std_ulogic_vector(0 to 43);
     bp_ib_iu4_3_instr_t3       : in  std_ulogic_vector(0 to 43);
     uc_ib_iu4_val              : in  std_ulogic_vector(0 to 3);
     uc_ib_iu4_ifar_t0          : in  std_ulogic_vector(62-uc_ifar to 61);
     uc_ib_iu4_instr_t0         : in  std_ulogic_vector(0 to 36);
     uc_ib_iu4_ifar_t1          : in  std_ulogic_vector(62-uc_ifar to 61);
     uc_ib_iu4_instr_t1         : in  std_ulogic_vector(0 to 36);
     uc_ib_iu4_ifar_t2          : in  std_ulogic_vector(62-uc_ifar to 61);
     uc_ib_iu4_instr_t2         : in  std_ulogic_vector(0 to 36);
     uc_ib_iu4_ifar_t3          : in  std_ulogic_vector(62-uc_ifar to 61);
     uc_ib_iu4_instr_t3         : in  std_ulogic_vector(0 to 36);
     rm_ib_iu4_val              : in  std_ulogic_vector(0 to 3);
     rm_ib_iu4_force_ram_t0     : in  std_ulogic;
     rm_ib_iu4_instr_t0         : in  std_ulogic_vector(0 to 35);
     rm_ib_iu4_force_ram_t1     : in  std_ulogic;
     rm_ib_iu4_instr_t1         : in  std_ulogic_vector(0 to 35);
     rm_ib_iu4_force_ram_t2     : in  std_ulogic;
     rm_ib_iu4_instr_t2         : in  std_ulogic_vector(0 to 35);
     rm_ib_iu4_force_ram_t3     : in  std_ulogic;
     rm_ib_iu4_instr_t3         : in  std_ulogic_vector(0 to 35);
     ib_ic_iu5_redirect_tid     : out std_ulogic_vector(0 to 3);
     iu_au_ib1_instr_vld_t0     : out std_ulogic;
     iu_au_ib1_instr_vld_t1     : out std_ulogic;
     iu_au_ib1_instr_vld_t2     : out std_ulogic;
     iu_au_ib1_instr_vld_t3     : out std_ulogic;
     iu_au_ib1_ifar_t0          : out EFF_IFAR;
     iu_au_ib1_ifar_t1          : out EFF_IFAR;
     iu_au_ib1_ifar_t2          : out EFF_IFAR;
     iu_au_ib1_ifar_t3          : out EFF_IFAR;
     iu_au_ib1_data_t0          : out std_ulogic_vector(0 to 49);
     iu_au_ib1_data_t1          : out std_ulogic_vector(0 to 49);
     iu_au_ib1_data_t2          : out std_ulogic_vector(0 to 49);
     iu_au_ib1_data_t3          : out std_ulogic_vector(0 to 49)
);
end iuq_ib_buff_wrap;
architecture iuq_ib_buff_wrap of iuq_ib_buff_wrap is
begin
ibuff0   : entity work.iuq_ib_buff
generic map(
      uc_ifar                           => uc_ifar,
      expand_type                       => expand_type )
port map(
      vdd                               => vdd,
      gnd                               => gnd,
      nclk                              => nclk,
      pc_iu_func_sl_thold_2             => pc_iu_func_sl_thold_2(0),
      pc_iu_sg_2                        => pc_iu_sg_2(0),
      clkoff_b                          => clkoff_b(0),
      an_ac_scan_dis_dc_b               => an_ac_scan_dis_dc_b(0),
      tc_ac_ccflush_dc                  => tc_ac_ccflush_dc,
      delay_lclkr                       => delay_lclkr(5+0),
      mpw1_b                            => mpw1_b(5+0),
      scan_in                           => iuq_b0_scan_in,
      scan_out                          => iuq_b0_scan_out,
      spr_dec_mask_pt_in                => spr_dec_mask_pt_in_t0,
      spr_dec_mask_pt_out               => spr_dec_mask_pt_out_t0,
      fdep_dbg_data_pt_in               => fdep_dbg_data_pt_in(22*0   to 22*0+21),
      fdep_dbg_data_pt_out              => fdep_dbg_data_pt_out(22*0   to 22*0+21),
      fdep_perf_event_pt_in             => fdep_perf_event_pt_in_t0,
      fdep_perf_event_pt_out            => fdep_perf_event_pt_out_t0,
      pc_iu_trace_bus_enable            => pc_iu_trace_bus_enable,
      pc_iu_event_bus_enable            => pc_iu_event_bus_enable,
      ib_dbg_data                       => ib_dbg_data(16*0   to 16*0+15),
      ib_perf_event                     => ib_perf_event_t0,
      xu_iu_ib1_flush                   => xu_iu_flush(0),   
      uc_flush                          => uc_flush_tid(0),
      fdec_ibuf_stall                   => fdec_ibuf_stall_t0,
      ib_ic_below_water                 => ib_ic_below_water(0),
      ib_ic_empty                       => ib_ic_empty(0),
      bp_ib_iu4_ifar                    => bp_ib_iu4_ifar_t0,
      bp_ib_iu4_val                     => bp_ib_iu4_t0_val,
      bp_ib_iu3_0_instr                 => bp_ib_iu3_0_instr_t0,
      bp_ib_iu4_0_instr                 => bp_ib_iu4_0_instr_t0,
      bp_ib_iu4_1_instr                 => bp_ib_iu4_1_instr_t0,
      bp_ib_iu4_2_instr                 => bp_ib_iu4_2_instr_t0,
      bp_ib_iu4_3_instr                 => bp_ib_iu4_3_instr_t0,
      uc_ib_iu4_ifar                    => uc_ib_iu4_ifar_t0,
      uc_ib_iu4_val                     => uc_ib_iu4_val(0),
      uc_ib_iu4_instr                   => uc_ib_iu4_instr_t0,
      rm_ib_iu4_val                     => rm_ib_iu4_val(0),
      rm_ib_iu4_force_ram               => rm_ib_iu4_force_ram_t0,
      rm_ib_iu4_instr                   => rm_ib_iu4_instr_t0,
      ib_ic_iu5_redirect_tid            => ib_ic_iu5_redirect_tid(0),
      iu_au_ib1_valid                   => iu_au_ib1_instr_vld_t0,
      iu_au_ib1_ifar                    => iu_au_ib1_ifar_t0,
      iu_au_ib1_data                    => iu_au_ib1_data_t0
);
ibuff1   : entity work.iuq_ib_buff
generic map(
      uc_ifar                           => uc_ifar,
      expand_type                       => expand_type )
port map(
      vdd                               => vdd,
      gnd                               => gnd,
      nclk                              => nclk,
      pc_iu_func_sl_thold_2             => pc_iu_func_sl_thold_2(1),
      pc_iu_sg_2                        => pc_iu_sg_2(1),
      clkoff_b                          => clkoff_b(1),
      an_ac_scan_dis_dc_b               => an_ac_scan_dis_dc_b(1),
      tc_ac_ccflush_dc                  => tc_ac_ccflush_dc,
      delay_lclkr                       => delay_lclkr(5+1),
      mpw1_b                            => mpw1_b(5+1),
      scan_in                           => iuq_b1_scan_in,
      scan_out                          => iuq_b1_scan_out,
      spr_dec_mask_pt_in                => spr_dec_mask_pt_in_t1,
      spr_dec_mask_pt_out               => spr_dec_mask_pt_out_t1,
      fdep_dbg_data_pt_in               => fdep_dbg_data_pt_in(22*1   to 22*1+21),
      fdep_dbg_data_pt_out              => fdep_dbg_data_pt_out(22*1   to 22*1+21),
      fdep_perf_event_pt_in             => fdep_perf_event_pt_in_t1,
      fdep_perf_event_pt_out            => fdep_perf_event_pt_out_t1,
      pc_iu_trace_bus_enable            => pc_iu_trace_bus_enable,
      pc_iu_event_bus_enable            => pc_iu_event_bus_enable,
      ib_dbg_data                       => ib_dbg_data(16*1   to 16*1+15),
      ib_perf_event                     => ib_perf_event_t1,
      xu_iu_ib1_flush                   => xu_iu_flush(1),   
      uc_flush                          => uc_flush_tid(1),
      fdec_ibuf_stall                   => fdec_ibuf_stall_t1,
      ib_ic_below_water                 => ib_ic_below_water(1),
      ib_ic_empty                       => ib_ic_empty(1),
      bp_ib_iu4_ifar                    => bp_ib_iu4_ifar_t1,
      bp_ib_iu4_val                     => bp_ib_iu4_t1_val,
      bp_ib_iu3_0_instr                 => bp_ib_iu3_0_instr_t1,
      bp_ib_iu4_0_instr                 => bp_ib_iu4_0_instr_t1,
      bp_ib_iu4_1_instr                 => bp_ib_iu4_1_instr_t1,
      bp_ib_iu4_2_instr                 => bp_ib_iu4_2_instr_t1,
      bp_ib_iu4_3_instr                 => bp_ib_iu4_3_instr_t1,
      uc_ib_iu4_ifar                    => uc_ib_iu4_ifar_t1,
      uc_ib_iu4_val                     => uc_ib_iu4_val(1),
      uc_ib_iu4_instr                   => uc_ib_iu4_instr_t1,
      rm_ib_iu4_val                     => rm_ib_iu4_val(1),
      rm_ib_iu4_force_ram               => rm_ib_iu4_force_ram_t1,
      rm_ib_iu4_instr                   => rm_ib_iu4_instr_t1,
      ib_ic_iu5_redirect_tid            => ib_ic_iu5_redirect_tid(1),
      iu_au_ib1_valid                   => iu_au_ib1_instr_vld_t1,
      iu_au_ib1_ifar                    => iu_au_ib1_ifar_t1,
      iu_au_ib1_data                    => iu_au_ib1_data_t1
);
ibuff2   : entity work.iuq_ib_buff
generic map(
      uc_ifar                           => uc_ifar,
      expand_type                       => expand_type )
port map(
      vdd                               => vdd,
      gnd                               => gnd,
      nclk                              => nclk,
      pc_iu_func_sl_thold_2             => pc_iu_func_sl_thold_2(2),
      pc_iu_sg_2                        => pc_iu_sg_2(2),
      clkoff_b                          => clkoff_b(2),
      an_ac_scan_dis_dc_b               => an_ac_scan_dis_dc_b(2),
      tc_ac_ccflush_dc                  => tc_ac_ccflush_dc,
      delay_lclkr                       => delay_lclkr(5+2),
      mpw1_b                            => mpw1_b(5+2),
      scan_in                           => iuq_b2_scan_in,
      scan_out                          => iuq_b2_scan_out,
      spr_dec_mask_pt_in                => spr_dec_mask_pt_in_t2,
      spr_dec_mask_pt_out               => spr_dec_mask_pt_out_t2,
      fdep_dbg_data_pt_in               => fdep_dbg_data_pt_in(22*2   to 22*2+21),
      fdep_dbg_data_pt_out              => fdep_dbg_data_pt_out(22*2   to 22*2+21),
      fdep_perf_event_pt_in             => fdep_perf_event_pt_in_t2,
      fdep_perf_event_pt_out            => fdep_perf_event_pt_out_t2,
      pc_iu_trace_bus_enable            => pc_iu_trace_bus_enable,
      pc_iu_event_bus_enable            => pc_iu_event_bus_enable,
      ib_dbg_data                       => ib_dbg_data(16*2   to 16*2+15),
      ib_perf_event                     => ib_perf_event_t2,
      xu_iu_ib1_flush                   => xu_iu_flush(2),   
      uc_flush                          => uc_flush_tid(2),
      fdec_ibuf_stall                   => fdec_ibuf_stall_t2,
      ib_ic_below_water                 => ib_ic_below_water(2),
      ib_ic_empty                       => ib_ic_empty(2),
      bp_ib_iu4_ifar                    => bp_ib_iu4_ifar_t2,
      bp_ib_iu4_val                     => bp_ib_iu4_t2_val,
      bp_ib_iu3_0_instr                 => bp_ib_iu3_0_instr_t2,
      bp_ib_iu4_0_instr                 => bp_ib_iu4_0_instr_t2,
      bp_ib_iu4_1_instr                 => bp_ib_iu4_1_instr_t2,
      bp_ib_iu4_2_instr                 => bp_ib_iu4_2_instr_t2,
      bp_ib_iu4_3_instr                 => bp_ib_iu4_3_instr_t2,
      uc_ib_iu4_ifar                    => uc_ib_iu4_ifar_t2,
      uc_ib_iu4_val                     => uc_ib_iu4_val(2),
      uc_ib_iu4_instr                   => uc_ib_iu4_instr_t2,
      rm_ib_iu4_val                     => rm_ib_iu4_val(2),
      rm_ib_iu4_force_ram               => rm_ib_iu4_force_ram_t2,
      rm_ib_iu4_instr                   => rm_ib_iu4_instr_t2,
      ib_ic_iu5_redirect_tid            => ib_ic_iu5_redirect_tid(2),
      iu_au_ib1_valid                   => iu_au_ib1_instr_vld_t2,
      iu_au_ib1_ifar                    => iu_au_ib1_ifar_t2,
      iu_au_ib1_data                    => iu_au_ib1_data_t2
);
ibuff3   : entity work.iuq_ib_buff
generic map(
      uc_ifar                           => uc_ifar,
      expand_type                       => expand_type )
port map(
      vdd                               => vdd,
      gnd                               => gnd,
      nclk                              => nclk,
      pc_iu_func_sl_thold_2             => pc_iu_func_sl_thold_2(3),
      pc_iu_sg_2                        => pc_iu_sg_2(3),
      clkoff_b                          => clkoff_b(3),
      an_ac_scan_dis_dc_b               => an_ac_scan_dis_dc_b(3),
      tc_ac_ccflush_dc                  => tc_ac_ccflush_dc,
      delay_lclkr                       => delay_lclkr(5+3),
      mpw1_b                            => mpw1_b(5+3),
      scan_in                           => iuq_b3_scan_in,
      scan_out                          => iuq_b3_scan_out,
      spr_dec_mask_pt_in                => spr_dec_mask_pt_in_t3,
      spr_dec_mask_pt_out               => spr_dec_mask_pt_out_t3,
      fdep_dbg_data_pt_in               => fdep_dbg_data_pt_in(22*3   to 22*3+21),
      fdep_dbg_data_pt_out              => fdep_dbg_data_pt_out(22*3   to 22*3+21),
      fdep_perf_event_pt_in             => fdep_perf_event_pt_in_t3,
      fdep_perf_event_pt_out            => fdep_perf_event_pt_out_t3,
      pc_iu_trace_bus_enable            => pc_iu_trace_bus_enable,
      pc_iu_event_bus_enable            => pc_iu_event_bus_enable,
      ib_dbg_data                       => ib_dbg_data(16*3   to 16*3+15),
      ib_perf_event                     => ib_perf_event_t3,
      xu_iu_ib1_flush                   => xu_iu_flush(3),   
      uc_flush                          => uc_flush_tid(3),
      fdec_ibuf_stall                   => fdec_ibuf_stall_t3,
      ib_ic_below_water                 => ib_ic_below_water(3),
      ib_ic_empty                       => ib_ic_empty(3),
      bp_ib_iu4_ifar                    => bp_ib_iu4_ifar_t3,
      bp_ib_iu4_val                     => bp_ib_iu4_t3_val,
      bp_ib_iu3_0_instr                 => bp_ib_iu3_0_instr_t3,
      bp_ib_iu4_0_instr                 => bp_ib_iu4_0_instr_t3,
      bp_ib_iu4_1_instr                 => bp_ib_iu4_1_instr_t3,
      bp_ib_iu4_2_instr                 => bp_ib_iu4_2_instr_t3,
      bp_ib_iu4_3_instr                 => bp_ib_iu4_3_instr_t3,
      uc_ib_iu4_ifar                    => uc_ib_iu4_ifar_t3,
      uc_ib_iu4_val                     => uc_ib_iu4_val(3),
      uc_ib_iu4_instr                   => uc_ib_iu4_instr_t3,
      rm_ib_iu4_val                     => rm_ib_iu4_val(3),
      rm_ib_iu4_force_ram               => rm_ib_iu4_force_ram_t3,
      rm_ib_iu4_instr                   => rm_ib_iu4_instr_t3,
      ib_ic_iu5_redirect_tid            => ib_ic_iu5_redirect_tid(3),
      iu_au_ib1_valid                   => iu_au_ib1_instr_vld_t3,
      iu_au_ib1_ifar                    => iu_au_ib1_ifar_t3,
      iu_au_ib1_data                    => iu_au_ib1_data_t3
);
end iuq_ib_buff_wrap;
