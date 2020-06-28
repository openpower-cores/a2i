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

entity xuq_lsu_perf is
generic( expand_type            :integer :=  2);
port(

     lsu_perf_events            :in  std_ulogic_vector(0 to 46);

     pc_xu_event_bus_enable     :in  std_ulogic;
     pc_xu_event_count_mode     :in  std_ulogic_vector(0 to 2);
     pc_xu_lsu_event_mux_ctrls  :in  std_ulogic_vector(0 to 47);
     pc_xu_cache_par_err_event  :in  std_ulogic;

     spr_msr_gs                 :in  std_ulogic_vector(0 to 3);
     spr_msr_pr                 :in  std_ulogic_vector(0 to 3);

     xu_pc_lsu_event_data       :out std_ulogic_vector(0 to 7);

     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     nclk                       :in  clk_logic;
     sg_0                       :in  std_ulogic;
     func_slp_sl_thold_0_b      :in  std_ulogic;
     func_slp_sl_force          :in  std_ulogic;
     d_mode_dc                  :in  std_ulogic;
     delay_lclkr_dc             :in  std_ulogic;
     mpw1_dc_b                  :in  std_ulogic;
     mpw2_dc_b                  :in  std_ulogic;
     scan_in                    :in  std_ulogic;
     scan_out                   :out std_ulogic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_lsu_perf;
architecture xuq_lsu_perf of xuq_lsu_perf is


signal t0_events                                      : std_ulogic_vector(0 to 31);
signal t1_events                                      : std_ulogic_vector(0 to 31);
signal t2_events                                      : std_ulogic_vector(0 to 31);
signal t3_events                                      : std_ulogic_vector(0 to 31);
signal t0_lsu_events                                  : std_ulogic_vector(0 to 31);
signal t1_lsu_events                                  : std_ulogic_vector(0 to 31);
signal t2_lsu_events                                  : std_ulogic_vector(0 to 31);
signal t3_lsu_events                                  : std_ulogic_vector(0 to 31);
signal t0_lsu_events_tmp                              : std_ulogic_vector(0 to 23);
signal t1_lsu_events_tmp                              : std_ulogic_vector(0 to 23);
signal t2_lsu_events_tmp                              : std_ulogic_vector(0 to 23);
signal t3_lsu_events_tmp                              : std_ulogic_vector(0 to 23);
signal event_en_q,            event_en_d              : std_ulogic_vector(0 to 3);
signal event_data_q,          event_data_d            : std_ulogic_vector(xu_pc_lsu_event_data'range);
signal event_mux_ctrls_q,     event_mux_ctrls_d       : std_ulogic_vector(0 to 47);
signal lsu_perf_events_q                              : std_ulogic_vector(0 to 46);
signal pc_event_count_mode_q                          : std_ulogic_vector(0 to 2);
signal pc_cache_par_err_event_q                       : std_ulogic;
signal pc_event_bus_enable_q                          : std_ulogic;

constant event_en_offset                              : integer := 0;
constant event_data_offset                            : integer := event_en_offset                + event_en_q'length;
constant event_mux_ctrls_offset                       : integer := event_data_offset              + event_data_q'length;
constant lsu_perf_events_offset                       : integer := event_mux_ctrls_offset         + event_mux_ctrls_q'length;
constant pc_event_count_mode_offset                   : integer := lsu_perf_events_offset         + lsu_perf_events_q'length;
constant pc_cache_par_err_event_offset                : integer := pc_event_count_mode_offset     + pc_event_count_mode_q'length;
constant pc_event_bus_enable_offset                   : integer := pc_cache_par_err_event_offset  + 1;
constant scan_right                                   : integer := pc_event_bus_enable_offset + 1;

signal siv                                            : std_ulogic_vector(0 to scan_right-1);
signal sov                                            : std_ulogic_vector(0 to scan_right-1);
signal tiup                                           : std_ulogic;

begin

tiup <= '1';


event_en_d     <= (    spr_msr_pr and                    (0 to 3=>pc_event_count_mode_q(0))) or 
                  (not spr_msr_pr and     spr_msr_gs and (0 to 3=>pc_event_count_mode_q(1))) or 
                  (not spr_msr_pr and not spr_msr_gs and (0 to 3=>pc_event_count_mode_q(2)));   

event_mux_ctrls_d <= pc_xu_lsu_event_mux_ctrls;



t0_lsu_events_tmp  <= (lsu_perf_events_q(4 to 20) & lsu_perf_events_q(35 to 41)) and (0 to 23=>lsu_perf_events_q(0));
t1_lsu_events_tmp  <= (lsu_perf_events_q(4 to 20) & lsu_perf_events_q(35 to 41)) and (0 to 23=>lsu_perf_events_q(1));
t2_lsu_events_tmp  <= (lsu_perf_events_q(4 to 20) & lsu_perf_events_q(35 to 41)) and (0 to 23=>lsu_perf_events_q(2));
t3_lsu_events_tmp  <= (lsu_perf_events_q(4 to 20) & lsu_perf_events_q(35 to 41)) and (0 to 23=>lsu_perf_events_q(3));

t0_lsu_events <= t0_lsu_events_tmp           & lsu_perf_events_q(42)    & lsu_perf_events_q(21) & lsu_perf_events_q(25) & lsu_perf_events_q(29) &
                 lsu_perf_events_q(33 to 34) & pc_cache_par_err_event_q & lsu_perf_events_q(46);
t1_lsu_events <= t1_lsu_events_tmp           & lsu_perf_events_q(43)    & lsu_perf_events_q(22) & lsu_perf_events_q(26) & lsu_perf_events_q(30) &
                 lsu_perf_events_q(33 to 34) & pc_cache_par_err_event_q & lsu_perf_events_q(46);
t2_lsu_events <= t2_lsu_events_tmp           & lsu_perf_events_q(44)    & lsu_perf_events_q(23) & lsu_perf_events_q(27) & lsu_perf_events_q(31) &
                 lsu_perf_events_q(33 to 34) & pc_cache_par_err_event_q & lsu_perf_events_q(46);
t3_lsu_events <= t3_lsu_events_tmp           & lsu_perf_events_q(45)    & lsu_perf_events_q(24) & lsu_perf_events_q(28) & lsu_perf_events_q(32) &
                 lsu_perf_events_q(33 to 34) & pc_cache_par_err_event_q & lsu_perf_events_q(46);

t0_events(0 to 31)  <= t0_lsu_events and (0 to 31=>event_en_q(0));
t1_events(0 to 31)  <= t1_lsu_events and (0 to 31=>event_en_q(1));
t2_events(0 to 31)  <= t2_lsu_events and (0 to 31=>event_en_q(2));
t3_events(0 to 31)  <= t3_lsu_events and (0 to 31=>event_en_q(3));


xuq_lsu_perf_mux1 : entity clib.c_event_mux(c_event_mux)
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

xu_pc_lsu_event_data  <= event_data_q;

event_en_latch : tri_rlmreg_p
generic map (width => event_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (nclk    => nclk,
          vd      => vdd,
            gd      => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(event_en_offset to event_en_offset + event_en_q'length-1),
            scout   => sov(event_en_offset to event_en_offset + event_en_q'length-1),
            din     => event_en_d,
            dout    => event_en_q);

event_data_latch : tri_rlmreg_p
generic map (width => event_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (nclk    => nclk,
            vd      => vdd,
            gd      => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(event_data_offset to event_data_offset + event_data_q'length-1),
            scout   => sov(event_data_offset to event_data_offset + event_data_q'length-1),
            din     => event_data_d,
            dout    => event_data_q);

event_mux_ctrls_latch : tri_rlmreg_p
generic map (width => event_mux_ctrls_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (nclk    => nclk,
            vd      => vdd,
            gd      => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(event_mux_ctrls_offset to event_mux_ctrls_offset + event_mux_ctrls_q'length-1),
            scout   => sov(event_mux_ctrls_offset to event_mux_ctrls_offset + event_mux_ctrls_q'length-1),
            din     => event_mux_ctrls_d,
            dout    => event_mux_ctrls_q);

lsu_perf_events_latch : tri_rlmreg_p
generic map (width => lsu_perf_events_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (nclk      => nclk,
            vd      => vdd,
            gd      => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_perf_events_offset to lsu_perf_events_offset + lsu_perf_events_q'length-1),
            scout   => sov(lsu_perf_events_offset to lsu_perf_events_offset + lsu_perf_events_q'length-1),
            din     => lsu_perf_events,
            dout    => lsu_perf_events_q);

pc_event_count_mode_latch : tri_rlmreg_p
generic map (width => pc_event_count_mode_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (nclk      => nclk,
            vd      => vdd,
            gd      => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_event_count_mode_offset to pc_event_count_mode_offset + pc_event_count_mode_q'length-1),
            scout   => sov(pc_event_count_mode_offset to pc_event_count_mode_offset + pc_event_count_mode_q'length-1),
            din     => pc_xu_event_count_mode,
            dout    => pc_event_count_mode_q);

pc_cache_par_err_event_latch : tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (nclk      => nclk,
            vd      => vdd,
            gd      => gnd,
            act     => pc_event_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_cache_par_err_event_offset),
            scout   => sov(pc_cache_par_err_event_offset),
            din     => pc_xu_cache_par_err_event,
            dout    => pc_cache_par_err_event_q);

pc_event_bus_enable_latch : tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (nclk      => nclk,
            vd      => vdd,
            gd      => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_event_bus_enable_offset),
            scout   => sov(pc_event_bus_enable_offset),
            din     => pc_xu_event_bus_enable,
            dout    => pc_event_bus_enable_q);

siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in;
scan_out <= sov(0);

end architecture xuq_lsu_perf;
