-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU Performance Event Muxing
--
library ieee,ibm,support,work,tri,clib;
use ieee.std_logic_1164.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;

entity xuq_perf is
generic(
   expand_type                      :     integer :=  2);
port(
   -- Clocks
   nclk                             : in  clk_logic;

   -- Pervasive
   func_sl_thold_2                  : in  std_ulogic;
   sg_2                             : in  std_ulogic;
   clkoff_dc_b                      : in  std_ulogic;
   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic;
   mpw1_dc_b                        : in  std_ulogic;
   mpw2_dc_b                        : in  std_ulogic;
   pc_xu_ccflush_dc                 : in  std_ulogic;
   scan_in                          : in  std_ulogic;
   scan_out                         : out std_ulogic;

   -- Event Inputs
   cpl_perf_tx_events               : in  std_ulogic_vector(0 to 75);
   spr_perf_tx_events               : in  std_ulogic_vector(0 to 31);
   byp_perf_tx_events               : in  std_ulogic_vector(0 to 11);
   fxa_perf_muldiv_in_use           : in  std_ulogic;

   -- PC Control Interface
   pc_xu_event_bus_enable           : in  std_ulogic;
   pc_xu_event_count_mode           : in  std_ulogic_vector(0 to 2);
   pc_xu_event_mux_ctrls            : in  std_ulogic_vector(0 to 47);

   -- Perf Event Output
   xu_pc_event_data                 : out std_ulogic_vector(0 to 7);

   -- SPR Bits
   spr_msr_gs                       : in  std_ulogic_vector(0 to 3);
   spr_msr_pr                       : in  std_ulogic_vector(0 to 3);

   -- Power
   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_perf;
architecture xuq_perf of xuq_perf is

-- Latches
signal event_en_q,            event_en_d              : std_ulogic_vector(0 to 3);
signal event_data_q,          event_data_d            : std_ulogic_vector(xu_pc_event_data'range);
signal event_mux_ctrls_q,     event_mux_ctrls_d       : std_ulogic_vector(0 to 47);
signal cpl_perf_tx_events_q                           : std_ulogic_vector(0 to 75);                -- input=>cpl_perf_tx_events
signal spr_perf_tx_events_q                           : std_ulogic_vector(0 to 31);                -- input=>spr_perf_tx_events
signal byp_perf_tx_events_q                           : std_ulogic_vector(0 to 11);                -- input=>byp_perf_tx_events
signal muldiv_in_use_q                                : std_ulogic;                                -- input=>fxa_perf_muldiv_in_use
signal processor_busy_q,      processor_busy_d        : std_ulogic;
signal br_commit_q,           br_commit_d             : std_ulogic;                                -- act=>pc_event_bus_enable_q
signal br_mispred_q,          br_mispred_d            : std_ulogic;                                -- act=>pc_event_bus_enable_q
signal br_ta_mispred_q,       br_ta_mispred_d         : std_ulogic;                                -- act=>pc_event_bus_enable_q
signal pc_event_count_mode_q                          : std_ulogic_vector(0 to 2);                 -- input=>pc_xu_event_count_mode
signal pc_event_bus_enable_q                          : std_ulogic;
-- Scanchains
constant event_en_offset                              : integer := 0;
constant event_data_offset                            : integer := event_en_offset                + event_en_q'length;
constant event_mux_ctrls_offset                       : integer := event_data_offset              + event_data_q'length;
constant cpl_perf_tx_events_offset                    : integer := event_mux_ctrls_offset         + event_mux_ctrls_q'length;
constant spr_perf_tx_events_offset                    : integer := cpl_perf_tx_events_offset      + cpl_perf_tx_events_q'length;
constant byp_perf_tx_events_offset                    : integer := spr_perf_tx_events_offset      + spr_perf_tx_events_q'length;
constant muldiv_in_use_offset                         : integer := byp_perf_tx_events_offset      + byp_perf_tx_events_q'length;
constant processor_busy_offset                        : integer := muldiv_in_use_offset           + 1;
constant br_commit_offset                             : integer := processor_busy_offset          + 1;
constant br_mispred_offset                            : integer := br_commit_offset               + 1;
constant br_ta_mispred_offset                         : integer := br_mispred_offset              + 1;
constant pc_event_count_mode_offset                   : integer := br_ta_mispred_offset           + 1;
constant pc_event_bus_enable_offset                   : integer := pc_event_count_mode_offset     + pc_event_count_mode_q'length;
constant scan_right                                   : integer := pc_event_bus_enable_offset     + 1;
signal siv                                            : std_ulogic_vector(0 to scan_right-1);
signal sov                                            : std_ulogic_vector(0 to scan_right-1);

-- Signals
signal tiup                                           : std_ulogic;
signal func_sl_thold_1                                : std_ulogic;
signal sg_1                                           : std_ulogic;
signal func_sl_thold_0                                : std_ulogic;
signal sg_0                                           : std_ulogic;
signal func_sl_force                                  : std_ulogic;
signal func_sl_thold_0_b                              : std_ulogic;
signal t0_events,             t0_events_in            : std_ulogic_vector(0 to 31);
signal t1_events,             t1_events_in            : std_ulogic_vector(0 to 31);
signal t2_events,             t2_events_in            : std_ulogic_vector(0 to 31);
signal t3_events,             t3_events_in            : std_ulogic_vector(0 to 31);

begin

tiup <= '1';

-- Processor Busy / Br Commit / Br Mispred / Br TA Mispred
------------------------------------------ SPR
-- Thread Running
-- TB Tick
-- SPR read
-- SPR write
-- Cycles Stalled on waitrsv
-- External Int Asserted
-- Critical Ext Int Asserted
-- Perf Mon Int Asserted
------------------------------------------ CPL
-- PPE Commit
-- Integer Commit
-- uCode Commit
-- Any Flush
-- Branch Commit
-- Branch Mispredict Commit
-- Branch Taken Commit
-- Branch TA Mispredict Commit
-- Mult/Div collision
-- External Interrupt Pending
-- Critical External Interrupt Pending
-- Performance Mon Interrupt Pending
-- Opcode Match
-- Concurrent Run Instructions
-- External, Critical, Perf Interrupts Taken (any thread)
-- External Interrupt Taken
-- Critical External Interrupt Taken
-- Performance Mon Interrupt Taken
-- Processor Doorbell or Critical Doorbell Taken
------------------------------------------ BYP
-- STCX Fail
-- icswx failed
-- icswx finished
------------------------------------------ DEC
-- Mult/Div Busy

processor_busy_d     <= spr_perf_tx_events_q(00) or spr_perf_tx_events_q(08) or spr_perf_tx_events_q(16) or spr_perf_tx_events_q(24);

br_commit_d          <= cpl_perf_tx_events_q(04) or cpl_perf_tx_events_q(04+19) or cpl_perf_tx_events_q(04+38) or cpl_perf_tx_events_q(04+57);
br_mispred_d         <= cpl_perf_tx_events_q(05) or cpl_perf_tx_events_q(05+19) or cpl_perf_tx_events_q(05+38) or cpl_perf_tx_events_q(05+57);
br_ta_mispred_d      <= cpl_perf_tx_events_q(07) or cpl_perf_tx_events_q(07+19) or cpl_perf_tx_events_q(07+38) or cpl_perf_tx_events_q(07+57);

t0_events_in   <= processor_busy_q & spr_perf_tx_events_q(00 to 07) & cpl_perf_tx_events_q(00 to 18) & byp_perf_tx_events_q(00 to 02) & muldiv_in_use_q;
t1_events_in   <= br_commit_q      & spr_perf_tx_events_q(08 to 15) & cpl_perf_tx_events_q(19 to 37) & byp_perf_tx_events_q(03 to 05) & muldiv_in_use_q;
t2_events_in   <= br_mispred_q     & spr_perf_tx_events_q(16 to 23) & cpl_perf_tx_events_q(38 to 56) & byp_perf_tx_events_q(06 to 08) & muldiv_in_use_q;
t3_events_in   <= br_ta_mispred_q  & spr_perf_tx_events_q(24 to 31) & cpl_perf_tx_events_q(57 to 75) & byp_perf_tx_events_q(09 to 11) & muldiv_in_use_q;

t0_events      <= t0_events_in and (0 to 31=>event_en_q(0));
t1_events      <= t1_events_in and (0 to 31=>event_en_q(1));
t2_events      <= t2_events_in and (0 to 31=>event_en_q(2));
t3_events      <= t3_events_in and (0 to 31=>event_en_q(3));

xu_pc_event_data  <= event_data_q;

event_mux_ctrls_d <= pc_xu_event_mux_ctrls;

event_en_d     <= (    spr_msr_pr and                    (0 to 3=>pc_event_count_mode_q(0))) or -- User
                  (not spr_msr_pr and     spr_msr_gs and (0 to 3=>pc_event_count_mode_q(1))) or -- Guest Supervisor
                  (not spr_msr_pr and not spr_msr_gs and (0 to 3=>pc_event_count_mode_q(2)));   -- Hypervisor

xuq_perf_mux1 : entity clib.c_event_mux(c_event_mux)
generic map(events_in => 128)
port map(
   vd             => vdd,
   gd             => gnd,
   t0_events      => t0_events,
   t1_events      => t1_events,
   t2_events      => t2_events,
   t3_events      => t3_events,
   select_bits    => event_mux_ctrls_q,
   event_bits     => event_data_d
);

-- Latch Instances
event_en_latch : tri_rlmreg_p
  generic map (width => event_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(event_en_offset to event_en_offset + event_en_q'length-1),
            scout   => sov(event_en_offset to event_en_offset + event_en_q'length-1),
            din     => event_en_d,
            dout    => event_en_q);
event_data_latch : tri_rlmreg_p
  generic map (width => event_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(event_data_offset to event_data_offset + event_data_q'length-1),
            scout   => sov(event_data_offset to event_data_offset + event_data_q'length-1),
            din     => event_data_d,
            dout    => event_data_q);
event_mux_ctrls_latch : tri_rlmreg_p
  generic map (width => event_mux_ctrls_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(event_mux_ctrls_offset to event_mux_ctrls_offset + event_mux_ctrls_q'length-1),
            scout   => sov(event_mux_ctrls_offset to event_mux_ctrls_offset + event_mux_ctrls_q'length-1),
            din     => event_mux_ctrls_d,
            dout    => event_mux_ctrls_q);
cpl_perf_tx_events_latch : tri_rlmreg_p
  generic map (width => cpl_perf_tx_events_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(cpl_perf_tx_events_offset to cpl_perf_tx_events_offset + cpl_perf_tx_events_q'length-1),
            scout   => sov(cpl_perf_tx_events_offset to cpl_perf_tx_events_offset + cpl_perf_tx_events_q'length-1),
            din     => cpl_perf_tx_events,
            dout    => cpl_perf_tx_events_q);
spr_perf_tx_events_latch : tri_rlmreg_p
  generic map (width => spr_perf_tx_events_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(spr_perf_tx_events_offset to spr_perf_tx_events_offset + spr_perf_tx_events_q'length-1),
            scout   => sov(spr_perf_tx_events_offset to spr_perf_tx_events_offset + spr_perf_tx_events_q'length-1),
            din     => spr_perf_tx_events,
            dout    => spr_perf_tx_events_q);
byp_perf_tx_events_latch : tri_rlmreg_p
  generic map (width => byp_perf_tx_events_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(byp_perf_tx_events_offset to byp_perf_tx_events_offset + byp_perf_tx_events_q'length-1),
            scout   => sov(byp_perf_tx_events_offset to byp_perf_tx_events_offset + byp_perf_tx_events_q'length-1),
            din     => byp_perf_tx_events,
            dout    => byp_perf_tx_events_q);
muldiv_in_use_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(muldiv_in_use_offset),
            scout   => sov(muldiv_in_use_offset),
            din     => fxa_perf_muldiv_in_use,
            dout    => muldiv_in_use_q);
processor_busy_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(processor_busy_offset),
            scout   => sov(processor_busy_offset),
            din     => processor_busy_d,
            dout    => processor_busy_q);
br_commit_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(br_commit_offset),
            scout   => sov(br_commit_offset),
            din     => br_commit_d,
            dout    => br_commit_q);
br_mispred_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(br_mispred_offset),
            scout   => sov(br_mispred_offset),
            din     => br_mispred_d,
            dout    => br_mispred_q);
br_ta_mispred_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(br_ta_mispred_offset),
            scout   => sov(br_ta_mispred_offset),
            din     => br_ta_mispred_d,
            dout    => br_ta_mispred_q);
pc_event_count_mode_latch : tri_rlmreg_p
  generic map (width => pc_event_count_mode_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_event_count_mode_offset to pc_event_count_mode_offset + pc_event_count_mode_q'length-1),
            scout   => sov(pc_event_count_mode_offset to pc_event_count_mode_offset + pc_event_count_mode_q'length-1),
            din     => pc_xu_event_count_mode,
            dout    => pc_event_count_mode_q);
pc_event_bus_enable_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_event_bus_enable_offset),
            scout   => sov(pc_event_bus_enable_offset),
            din     => pc_xu_event_bus_enable,
            dout    => pc_event_bus_enable_q);

-------------------------------------------------
-- Pervasive
-------------------------------------------------
perv_2to1_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => func_sl_thold_2,
            din(1)      => sg_2,
            q(0)        => func_sl_thold_1,
            q(1)        => sg_1);

perv_1to0_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => func_sl_thold_1,
            din(1)      => sg_1,
            q(0)        => func_sl_thold_0,
            q(1)        => sg_0);

perv_lcbor_func_sl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_sl_thold_0,
            sg          => sg_0,
            act_dis     => '0',
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b);


siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in;
scan_out <= sov(0);

end architecture xuq_perf;
