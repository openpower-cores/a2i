-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  LSU Debug Event Muxing
--
library ieee,ibm,support,work,tri,clib,work;
use ieee.std_logic_1164.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_debug_mux32 is
generic(expand_type          :integer :=  2);
port(

     -- PC Debug Control
     trace_bus_enable           :in  std_ulogic;
     trace_unit_sel             :in  std_ulogic_vector(0 to 15);

     -- Pass Thru Debug Trace Bus
     debug_data_in              :in  std_ulogic_vector(0 to 87);
     trigger_data_in            :in  std_ulogic_vector(0 to 11);

     -- Debug Data In
     dbg_group0                 :in  std_ulogic_vector(0 to 87);
     dbg_group1                 :in  std_ulogic_vector(0 to 87);
     dbg_group2                 :in  std_ulogic_vector(0 to 87);
     dbg_group3                 :in  std_ulogic_vector(0 to 87);
     dbg_group4                 :in  std_ulogic_vector(0 to 87);
     dbg_group5                 :in  std_ulogic_vector(0 to 87);
     dbg_group6                 :in  std_ulogic_vector(0 to 87);
     dbg_group7                 :in  std_ulogic_vector(0 to 87);
     dbg_group8                 :in  std_ulogic_vector(0 to 87);
     dbg_group9                 :in  std_ulogic_vector(0 to 87);
     dbg_group10                :in  std_ulogic_vector(0 to 87);
     dbg_group11                :in  std_ulogic_vector(0 to 87);
     dbg_group12                :in  std_ulogic_vector(0 to 87);
     dbg_group13                :in  std_ulogic_vector(0 to 87);
     dbg_group14                :in  std_ulogic_vector(0 to 87);
     dbg_group15                :in  std_ulogic_vector(0 to 87);
     dbg_group16                :in  std_ulogic_vector(0 to 87);
     dbg_group17                :in  std_ulogic_vector(0 to 87);
     dbg_group18                :in  std_ulogic_vector(0 to 87);
     dbg_group19                :in  std_ulogic_vector(0 to 87);
     dbg_group20                :in  std_ulogic_vector(0 to 87);
     dbg_group21                :in  std_ulogic_vector(0 to 87);
     dbg_group22                :in  std_ulogic_vector(0 to 87);
     dbg_group23                :in  std_ulogic_vector(0 to 87);
     dbg_group24                :in  std_ulogic_vector(0 to 87);
     dbg_group25                :in  std_ulogic_vector(0 to 87);
     dbg_group26                :in  std_ulogic_vector(0 to 87);
     dbg_group27                :in  std_ulogic_vector(0 to 87);
     dbg_group28                :in  std_ulogic_vector(0 to 87);
     dbg_group29                :in  std_ulogic_vector(0 to 87);
     dbg_group30                :in  std_ulogic_vector(0 to 87);
     dbg_group31                :in  std_ulogic_vector(0 to 87);

     -- Trigger Data In
     trg_group0                 :in  std_ulogic_vector(0 to 11);
     trg_group1                 :in  std_ulogic_vector(0 to 11);
     trg_group2                 :in  std_ulogic_vector(0 to 11);
     trg_group3                 :in  std_ulogic_vector(0 to 11);

     -- Outputs
     trigger_data_out           :out std_ulogic_vector(0 to 11);
     debug_data_out             :out std_ulogic_vector(0 to 87);

     -- Power
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
end xuq_debug_mux32;
architecture xuq_debug_mux32 of xuq_debug_mux32 is

type ARY_32                             is array (0 to 31) of std_ulogic_vector(0 to 3);

signal dbg_group_int_data               :std_ulogic_vector(0 to 87);
signal dbg_group_rotate0                :std_ulogic_vector(0 to 87);
signal dbg_group_rotate1                :std_ulogic_vector(0 to 87);
signal dbg_group_rotate2                :std_ulogic_vector(0 to 87);
signal dbg_group_rotate3                :std_ulogic_vector(0 to 87);
signal dbg_group_rotate                 :std_ulogic_vector(0 to 87);
signal dbg_group_pthru_data0            :std_ulogic_vector(0 to 21);
signal dbg_group_pthru_data1            :std_ulogic_vector(0 to 21);
signal dbg_group_pthru_data2            :std_ulogic_vector(0 to 21);
signal dbg_group_pthru_data3            :std_ulogic_vector(0 to 21);
signal dbg_group_pthru_data             :std_ulogic_vector(0 to 87);
signal debug_data_out_d                 :std_ulogic_vector(0 to 87);
signal debug_data_out_q                 :std_ulogic_vector(0 to 87);
signal dbg_group_int_trig               :std_ulogic_vector(0 to 11);
signal dbg_group_rot_trig0              :std_ulogic_vector(0 to 11);
signal dbg_group_rot_trig1              :std_ulogic_vector(0 to 11);
signal dbg_group_rot_trig               :std_ulogic_vector(0 to 11);
signal dbg_group_pthru_trig0            :std_ulogic_vector(0 to 5);
signal dbg_group_pthru_trig1            :std_ulogic_vector(0 to 5);
signal dbg_group_pthru_trig             :std_ulogic_vector(0 to 11);
signal trigger_data_out_d               :std_ulogic_vector(0 to 11);
signal trigger_data_out_q               :std_ulogic_vector(0 to 11);
signal trace_unit_sel10                 :std_ulogic_vector(0 to 31);
signal trace_unit_selC840               :std_ulogic_vector(0 to 31);
signal trace_unit_sel3210               :std_ulogic_vector(0 to 31);
signal dbg_data_unit_sel_d              :ARY_32;
signal dbg_data_unit_sel_q              :ARY_32;
signal dbg_trace_unit_sel_d             :std_ulogic_vector(32 to 46);
signal dbg_trace_unit_sel_q             :std_ulogic_vector(32 to 46);
signal dbg_rot_grp_sel                  :std_ulogic_vector(0 to 3);
signal dbg_data_pthru_sel               :std_ulogic_vector(0 to 3);
signal dbg_trig_grp_sel                 :std_ulogic_vector(0 to 3);
signal dbg_rot_trig_sel                 :std_ulogic;
signal dbg_trig_pthru_sel               :std_ulogic_vector(0 to 1);

constant dbg_data_unit_sel_offset       :natural := 0;
constant dbg_trace_unit_sel_offset      :natural := dbg_data_unit_sel_offset + dbg_data_unit_sel_q(0)'length*32;
constant trigger_data_out_offset        :natural := dbg_trace_unit_sel_offset + 15;
constant debug_data_out_offset          :natural := trigger_data_out_offset + 12;
constant scan_right                     :natural := debug_data_out_offset + 88 - 1;
signal siv                              :std_ulogic_vector(0 to scan_right);
signal sov                              :std_ulogic_vector(0 to scan_right);

begin

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- MUX Control Generation
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- Generate 1-hot Debug Data Group Select
with trace_unit_sel(0) select
    trace_unit_sel10 <= x"80000000" when '0',
                        x"00008000" when others;

with trace_unit_sel(1 to 2) select
    trace_unit_selC840 <=        trace_unit_sel10(0 to 31) when "00",
                          x"0" & trace_unit_sel10(0 to 27) when "01",
                         x"00" & trace_unit_sel10(0 to 23) when "10",
                        x"000" & trace_unit_sel10(0 to 19) when others;

with trace_unit_sel(3 to 4) select
    trace_unit_sel3210 <=       trace_unit_selC840(0 to 31) when "00",
                          '0' & trace_unit_selC840(0 to 30) when "01",
                         "00" & trace_unit_selC840(0 to 29) when "10",
                        "000" & trace_unit_selC840(0 to 28) when others;

-- Generate 1-hot Debug Data Group Rotate
with trace_unit_sel(5 to 6) select
    dbg_trace_unit_sel_d(32 to 35) <= "1000" when "00",
                                      "0100" when "01",
                                      "0010" when "10",
                                      "0001" when others;

-- Debug Data Pass Through
dbg_trace_unit_sel_d(36 to 39) <= trace_unit_sel(7 to 10);

-- Generate 1-hot Trigger Group Select
with trace_unit_sel(11 to 12) select
    dbg_trace_unit_sel_d(40 to 43) <= "1000" when "00",
                                      "0100" when "01",
                                      "0010" when "10",
                                      "0001" when others;

-- Generate 1-hot Trigger Group Rotate
dbg_trace_unit_sel_d(44) <= trace_unit_sel(13);

-- Trigger Pass Through
dbg_trace_unit_sel_d(45 to 46) <= trace_unit_sel(14 to 15);

dbg_rot_grp_sel    <= dbg_trace_unit_sel_q(32 to 35);
dbg_data_pthru_sel <= dbg_trace_unit_sel_q(36 to 39);
dbg_trig_grp_sel   <= dbg_trace_unit_sel_q(40 to 43);
dbg_rot_trig_sel   <= dbg_trace_unit_sel_q(44);
dbg_trig_pthru_sel <= dbg_trace_unit_sel_q(45 to 46);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Muxing
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- Select Internal Debug Group
dbg_group_int_data <=  (dbg_group0     and fanout(dbg_data_unit_sel_q(00),88)) or
                       (dbg_group1     and fanout(dbg_data_unit_sel_q(01),88)) or
                       (dbg_group2     and fanout(dbg_data_unit_sel_q(02),88)) or
                       (dbg_group3     and fanout(dbg_data_unit_sel_q(03),88)) or
                       (dbg_group4     and fanout(dbg_data_unit_sel_q(04),88)) or
                       (dbg_group5     and fanout(dbg_data_unit_sel_q(05),88)) or
                       (dbg_group6     and fanout(dbg_data_unit_sel_q(06),88)) or
                       (dbg_group7     and fanout(dbg_data_unit_sel_q(07),88)) or
                       (dbg_group8     and fanout(dbg_data_unit_sel_q(08),88)) or
                       (dbg_group9     and fanout(dbg_data_unit_sel_q(09),88)) or
                       (dbg_group10    and fanout(dbg_data_unit_sel_q(10),88)) or
                       (dbg_group11    and fanout(dbg_data_unit_sel_q(11),88)) or
                       (dbg_group12    and fanout(dbg_data_unit_sel_q(12),88)) or
                       (dbg_group13    and fanout(dbg_data_unit_sel_q(13),88)) or
                       (dbg_group14    and fanout(dbg_data_unit_sel_q(14),88)) or
                       (dbg_group15    and fanout(dbg_data_unit_sel_q(15),88)) or
                       (dbg_group16    and fanout(dbg_data_unit_sel_q(16),88)) or
                       (dbg_group17    and fanout(dbg_data_unit_sel_q(17),88)) or
                       (dbg_group18    and fanout(dbg_data_unit_sel_q(18),88)) or
                       (dbg_group19    and fanout(dbg_data_unit_sel_q(19),88)) or
                       (dbg_group20    and fanout(dbg_data_unit_sel_q(20),88)) or
                       (dbg_group21    and fanout(dbg_data_unit_sel_q(21),88)) or
                       (dbg_group22    and fanout(dbg_data_unit_sel_q(22),88)) or
                       (dbg_group23    and fanout(dbg_data_unit_sel_q(23),88)) or
                       (dbg_group24    and fanout(dbg_data_unit_sel_q(24),88)) or
                       (dbg_group25    and fanout(dbg_data_unit_sel_q(25),88)) or
                       (dbg_group26    and fanout(dbg_data_unit_sel_q(26),88)) or
                       (dbg_group27    and fanout(dbg_data_unit_sel_q(27),88)) or
                       (dbg_group28    and fanout(dbg_data_unit_sel_q(28),88)) or
                       (dbg_group29    and fanout(dbg_data_unit_sel_q(29),88)) or
                       (dbg_group30    and fanout(dbg_data_unit_sel_q(30),88)) or
                       (dbg_group31    and fanout(dbg_data_unit_sel_q(31),88));

-- Rotate Internal Debug Group
dbg_group_rotate0 <= dbg_group_int_data(0 to 87);
dbg_group_rotate1 <= dbg_group_int_data(66 to 87) & dbg_group_int_data(0 to 65);
dbg_group_rotate2 <= dbg_group_int_data(44 to 87) & dbg_group_int_data(0 to 43);
dbg_group_rotate3 <= dbg_group_int_data(22 to 87) & dbg_group_int_data(0 to 21);
dbg_group_rotate  <= gate(dbg_group_rotate0, dbg_rot_grp_sel(0)) or gate(dbg_group_rotate1, dbg_rot_grp_sel(1)) or
                     gate(dbg_group_rotate2, dbg_rot_grp_sel(2)) or gate(dbg_group_rotate3, dbg_rot_grp_sel(3));

-- Pass Thru Debug Select
dbg_group_pthru_data0 <= gate(dbg_group_rotate(0 to 21),  dbg_data_pthru_sel(0)) or gate(debug_data_in(0 to 21),  not dbg_data_pthru_sel(0));
dbg_group_pthru_data1 <= gate(dbg_group_rotate(22 to 43), dbg_data_pthru_sel(1)) or gate(debug_data_in(22 to 43), not dbg_data_pthru_sel(1));
dbg_group_pthru_data2 <= gate(dbg_group_rotate(44 to 65), dbg_data_pthru_sel(2)) or gate(debug_data_in(44 to 65), not dbg_data_pthru_sel(2));
dbg_group_pthru_data3 <= gate(dbg_group_rotate(66 to 87), dbg_data_pthru_sel(3)) or gate(debug_data_in(66 to 87), not dbg_data_pthru_sel(3));
dbg_group_pthru_data  <= dbg_group_pthru_data0 & dbg_group_pthru_data1 & dbg_group_pthru_data2 & dbg_group_pthru_data3;

debug_data_out_d <= dbg_group_pthru_data;

-- Select Internal Trigger Group
dbg_group_int_trig <= gate(trg_group0, dbg_trig_grp_sel(0)) or gate(trg_group1, dbg_trig_grp_sel(1)) or gate(trg_group2, dbg_trig_grp_sel(2)) or gate(trg_group3, dbg_trig_grp_sel(3));

-- Rotate Internal Trigger Group
dbg_group_rot_trig0 <= dbg_group_int_trig(0 to 11);
dbg_group_rot_trig1 <= dbg_group_int_trig(6 to 11) & dbg_group_int_trig(0 to 5);
dbg_group_rot_trig  <= gate(dbg_group_rot_trig0, not dbg_rot_trig_sel) or gate(dbg_group_rot_trig1, dbg_rot_trig_sel);

-- Pass Thru Trigger Select
dbg_group_pthru_trig0 <= gate(dbg_group_rot_trig(0 to 5),  dbg_trig_pthru_sel(0)) or gate(trigger_data_in(0 to 5),  not dbg_trig_pthru_sel(0));
dbg_group_pthru_trig1 <= gate(dbg_group_rot_trig(6 to 11), dbg_trig_pthru_sel(1)) or gate(trigger_data_in(6 to 11), not dbg_trig_pthru_sel(1));
dbg_group_pthru_trig  <= dbg_group_pthru_trig0 & dbg_group_pthru_trig1;

trigger_data_out_d <= dbg_group_pthru_trig;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Outputs
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
debug_data_out   <= debug_data_out_q;
trigger_data_out <= trigger_data_out_q;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Latches
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
dbg_data_unit_sel_gen : for g in 0 to 31 generate
   dbg_data_unit_sel_latch : tri_rlmreg_p
   generic map (width => dbg_data_unit_sel_q(g)'length, init => 0, expand_type => expand_type, needs_sreset => 0)
   port map (vd      => vdd,
               gd      => gnd,
               nclk    => nclk,
               act     => trace_bus_enable,
               forcee => func_slp_sl_force,
               d_mode  => d_mode_dc,
               delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b,
               mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(dbg_data_unit_sel_offset+dbg_data_unit_sel_q(g)'length*g to dbg_data_unit_sel_offset + dbg_data_unit_sel_q(g)'length*(g+1)-1),
               scout   => sov(dbg_data_unit_sel_offset+dbg_data_unit_sel_q(g)'length*g to dbg_data_unit_sel_offset + dbg_data_unit_sel_q(g)'length*(g+1)-1),
               din     => dbg_data_unit_sel_d(g),
               dout    => dbg_data_unit_sel_q(g));
               
               dbg_data_unit_sel_d(g)     <= (others=>trace_unit_sel3210(g));
             
end generate;
dbg_trace_unit_sel_latch : tri_rlmreg_p
generic map (width => dbg_trace_unit_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbg_trace_unit_sel_offset to dbg_trace_unit_sel_offset + dbg_trace_unit_sel_q'length-1),
            scout   => sov(dbg_trace_unit_sel_offset to dbg_trace_unit_sel_offset + dbg_trace_unit_sel_q'length-1),
            din     => dbg_trace_unit_sel_d,
            dout    => dbg_trace_unit_sel_q);
trigger_data_out_latch : tri_rlmreg_p
generic map (width => trigger_data_out_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            scout   => sov(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            din     => trigger_data_out_d,
            dout    => trigger_data_out_q);
debug_data_out_latch : tri_rlmreg_p
generic map (width => debug_data_out_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(debug_data_out_offset to debug_data_out_offset + debug_data_out_q'length-1),
            scout   => sov(debug_data_out_offset to debug_data_out_offset + debug_data_out_q'length-1),
            din     => debug_data_out_d,
            dout    => debug_data_out_q);

siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out             <= sov(0);

end architecture xuq_debug_mux32;
