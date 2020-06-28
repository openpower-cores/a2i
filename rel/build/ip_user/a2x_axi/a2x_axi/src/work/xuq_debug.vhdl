-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee,ibm,support,work,tri,clib;
use ieee.std_logic_1164.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;

entity xuq_debug is
generic(
   expand_type                      :     integer := 2);
port(
   nclk                             : in  clk_logic;

   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic;
   mpw1_dc_b                        : in  std_ulogic;
   mpw2_dc_b                        : in  std_ulogic;
   sg_0                             : in  std_ulogic;
   func_slp_sl_thold_0_b            : in  std_ulogic;
   func_slp_sl_force : in  std_ulogic;
   scan_in                          : in  std_ulogic;
   scan_out                         : out std_ulogic;
   
   dec_byp_ex3_instr_trace_val      : in  std_ulogic;

   pc_xu_trace_bus_enable           : in  std_ulogic;
   debug_mux_ctrls                  : in  std_ulogic_vector(0 to 15);
   trigger_data_in                  : in  std_ulogic_vector(0 to 11);
   debug_data_in                    : in  std_ulogic_vector(0 to 87);
   trigger_data_out                 : out std_ulogic_vector(0 to 11);
   debug_data_out                   : out std_ulogic_vector(0 to 87);

   dbg_group0                       : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group1                       : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group2                       : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group3                       : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group4                       : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group5                       : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group6                       : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group7                       : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group8                       : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group9                       : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group10                      : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group11                      : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group12                      : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group13                      : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group14                      : in std_ulogic_vector(0 to 87) := (others=>'0');
   dbg_group15                      : in std_ulogic_vector(0 to 87) := (others=>'0');

   trg_group0                       : in std_ulogic_vector(0 to 11) := (others=>'0');
   trg_group1                       : in std_ulogic_vector(0 to 11) := (others=>'0');
   trg_group2                       : in std_ulogic_vector(0 to 11) := (others=>'0');
   trg_group3                       : in std_ulogic_vector(0 to 11) := (others=>'0');

   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_debug;
architecture xuq_debug of xuq_debug is

signal tiup                                           : std_ulogic;
signal trace_bus_enable_q                             : std_ulogic;                       
signal debug_mux_ctrls_q                              : std_ulogic_vector(0 to 15);       
signal debug_mux_ctrls_int_q, debug_mux_ctrls_int     : std_ulogic_vector(0 to 15);       
signal trigger_data_out_q,    trigger_data_out_d      : std_ulogic_vector(0 to 11);       
signal debug_data_out_q,      debug_data_out_d        : std_ulogic_vector(0 to 87);       
signal ex4_instr_trace_val_q                          : std_ulogic;                     
constant trace_bus_enable_offset                      : integer := 0;
constant debug_mux_ctrls_offset                       : integer := trace_bus_enable_offset        + 1;
constant debug_mux_ctrls_int_offset                   : integer := debug_mux_ctrls_offset         + debug_mux_ctrls_q'length;
constant trigger_data_out_offset                      : integer := debug_mux_ctrls_int_offset     + debug_mux_ctrls_int_q'length;
constant debug_data_out_offset                        : integer := trigger_data_out_offset        + trigger_data_out_q'length;
constant ex4_instr_trace_val_offset                   : integer := debug_data_out_offset          + debug_data_out_q'length;
constant scan_right                                   : integer := ex4_instr_trace_val_offset     + 1;
signal siv                                            : std_ulogic_vector(0 to scan_right-1);
signal sov                                            : std_ulogic_vector(0 to scan_right-1);

begin

tiup                   <= '1';
trigger_data_out       <= trigger_data_out_q;
debug_data_out         <= debug_data_out_q;

with ex4_instr_trace_val_q select
   debug_mux_ctrls_int     <= x"11E0"              when '1',
                              debug_mux_ctrls_q    when others;

xu_debug_mux : entity clib.c_debug_mux16(c_debug_mux16)
port map(
   vd                   => vdd,
   gd                   => gnd,
   select_bits          => debug_mux_ctrls_int_q,
   trace_data_in        => debug_data_in,
   trigger_data_in      => trigger_data_in,
   dbg_group0           => dbg_group0,
   dbg_group1           => dbg_group1,
   dbg_group2           => dbg_group2,
   dbg_group3           => dbg_group3,
   dbg_group4           => dbg_group4,
   dbg_group5           => dbg_group5,
   dbg_group6           => dbg_group6,
   dbg_group7           => dbg_group7,
   dbg_group8           => dbg_group8,
   dbg_group9           => dbg_group9,
   dbg_group10          => dbg_group10,
   dbg_group11          => dbg_group11,
   dbg_group12          => dbg_group12,
   dbg_group13          => dbg_group13,
   dbg_group14          => dbg_group14,
   dbg_group15          => dbg_group15,
   trg_group0           => trg_group0,
   trg_group1           => trg_group1,
   trg_group2           => trg_group2,
   trg_group3           => trg_group3,
   trigger_data_out     => trigger_data_out_d,
   trace_data_out       => debug_data_out_d);

trace_bus_enable_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => pc_xu_trace_bus_enable,
            dout    => trace_bus_enable_q);
debug_mux_ctrls_latch : tri_rlmreg_p
  generic map (width => debug_mux_ctrls_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux_ctrls_q'length-1),
            scout   => sov(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux_ctrls_q'length-1),
            din     => debug_mux_ctrls,
            dout    => debug_mux_ctrls_q);
debug_mux_ctrls_int_latch : tri_rlmreg_p
  generic map (width => debug_mux_ctrls_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(debug_mux_ctrls_int_offset to debug_mux_ctrls_int_offset + debug_mux_ctrls_int_q'length-1),
            scout   => sov(debug_mux_ctrls_int_offset to debug_mux_ctrls_int_offset + debug_mux_ctrls_int_q'length-1),
            din     => debug_mux_ctrls_int,
            dout    => debug_mux_ctrls_int_q);
trigger_data_out_latch : tri_rlmreg_p
  generic map (width => trigger_data_out_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            scout   => sov(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            din     => trigger_data_out_d,
            dout    => trigger_data_out_q);
debug_data_out_latch : tri_rlmreg_p
  generic map (width => debug_data_out_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(debug_data_out_offset to debug_data_out_offset + debug_data_out_q'length-1),
            scout   => sov(debug_data_out_offset to debug_data_out_offset + debug_data_out_q'length-1),
            din     => debug_data_out_d,
            dout    => debug_data_out_q);
ex4_instr_trace_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_instr_trace_val_offset),
            scout   => sov(ex4_instr_trace_val_offset),
            din     => dec_byp_ex3_instr_trace_val,
            dout    => ex4_instr_trace_val_q);

siv(0 to scan_right-1)              <= sov(1 to scan_right-1) & scan_in;
scan_out                            <= sov(0);


end architecture xuq_debug;
