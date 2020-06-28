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

entity xuq_lsu_debug is
generic(expand_type          :integer :=  2);
port(

     pc_xu_trace_bus_enable     :in  std_ulogic;
     lsu_debug_mux_ctrls        :in  std_ulogic_vector(0 to 15);
     xu_lsu_ex2_instr_trace_val :in  std_ulogic;

     trigger_data_in            :in  std_ulogic_vector(0 to 11);
     debug_data_in              :in  std_ulogic_vector(0 to 87);

     dc_fgen_dbg_data           :in  std_ulogic_vector(0 to 1);
     dc_cntrl_dbg_data          :in  std_ulogic_vector(0 to 66);
     dc_val_dbg_data            :in  std_ulogic_vector(0 to 293);
     dc_lru_dbg_data            :in  std_ulogic_vector(0 to 81);
     dc_dir_dbg_data            :in  std_ulogic_vector(0 to 35);
     dir_arr_dbg_data           :in  std_ulogic_vector(0 to 60);
     lmq_dbg_dcache_pe          :in  std_ulogic_vector(1 to 60);
     lmq_dbg_l2req              :in  std_ulogic_vector(0 to 212);
     lmq_dbg_rel                :in  std_ulogic_vector(0 to 140);
     lmq_dbg_binv               :in  std_ulogic_vector(0 to 44);
     lmq_dbg_pops               :in  std_ulogic_vector(0 to 5);
     lmq_dbg_grp0               :in  std_ulogic_vector(0 to 81);
     lmq_dbg_grp1               :in  std_ulogic_vector(0 to 81);
     lmq_dbg_grp2               :in  std_ulogic_vector(0 to 87);
     lmq_dbg_grp3               :in  std_ulogic_vector(0 to 87);
     lmq_dbg_grp4               :in  std_ulogic_vector(0 to 87);
     lmq_dbg_grp5               :in  std_ulogic_vector(0 to 87);
     lmq_dbg_grp6               :in  std_ulogic_vector(0 to 87);
     pe_recov_begin             :in  std_ulogic;
     derat_xu_debug_group0      :in  std_ulogic_vector(0 to 87);
     derat_xu_debug_group1      :in  std_ulogic_vector(0 to 87);

     trigger_data_out           :out std_ulogic_vector(0 to 11);
     debug_data_out             :out std_ulogic_vector(0 to 87);

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
end xuq_lsu_debug;
architecture xuq_lsu_debug of xuq_lsu_debug is

type dbgSize   is array (natural range <>) of std_ulogic_vector(0 to 21);

signal trace_bus_enable_q               :std_ulogic;
signal unit_trace_sel_q                 :std_ulogic_vector(0 to 15);

signal lsu_dbg_way_0                    :dbgSize(0 to 7);
signal lsu_dbg_way_1                    :dbgSize(0 to 7);
signal lsu_dbg_way_2                    :dbgSize(0 to 7);
signal lsu_dbg_way_3                    :dbgSize(0 to 7);
signal l2cmdq_dbg_data_0                :dbgSize(0 to 3);
signal l2cmdq_dbg_data_1                :dbgSize(0 to 3);
signal l2cmdq_dbg_data_2                :dbgSize(0 to 3);
signal l2cmdq_dbg_data_3                :dbgSize(0 to 3);
signal lsu_dbg_group0_0                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group0_1                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group0_2                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group0_3                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group0                   :std_ulogic_vector(0 to 87);
signal lsu_dbg_group1_b64               :std_ulogic;
signal lsu_dbg_group1_b67               :std_ulogic;
signal lsu_dbg_group1_0                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group1_1                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group1_2                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group1_3                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group1                   :std_ulogic_vector(0 to 87);
signal lsu_dbg_group2_0                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group2_1                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group2_2                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group2_3                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group2                   :std_ulogic_vector(0 to 87);
signal lsu_dbg_group3_0                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group3_1                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group3_2                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group3_3                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group3                   :std_ulogic_vector(0 to 87);
signal lsu_dbg_group4_0                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group4_1                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group4_2                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group4_3                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group4                   :std_ulogic_vector(0 to 87);
signal lsu_dbg_group5_0                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group5_1                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group5_2                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group5_3                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group5                   :std_ulogic_vector(0 to 87);
signal lsu_dbg_group6_0                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group6_1                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group6_2                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group6_3                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group6                   :std_ulogic_vector(0 to 87);
signal lsu_dbg_group7_0                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group7_1                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group7_2                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group7_3                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group7                   :std_ulogic_vector(0 to 87);
signal lsu_dbg_group8_0                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group8_1                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group8_2                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group8_3                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group8                   :std_ulogic_vector(0 to 87);
signal lsu_dbg_group9_0                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group9_1                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group9_2                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group9_3                 :std_ulogic_vector(0 to 21);
signal lsu_dbg_group9                   :std_ulogic_vector(0 to 87);
signal lsu_dbg_group10_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group10_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group10_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group10_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group10                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group11_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group11_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group11_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group11_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group11                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group12_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group12_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group12_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group12_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group12                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group13_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group13_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group13_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group13_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group13                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group14_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group14_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group14_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group14_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group14                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group15_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group15_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group15_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group15_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group15                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group16_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group16_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group16_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group16_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group16                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group17_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group17_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group17_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group17_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group17                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group18_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group18_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group18_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group18_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group18                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group19_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group19_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group19_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group19_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group19                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group20_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group20_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group20_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group20_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group20                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group21_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group21_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group21_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group21_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group21                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group22                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group23                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group24                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group25                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group26                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group27                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group28                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group29_0                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group29_1                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group29_2                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group29_3                :std_ulogic_vector(0 to 21);
signal lsu_dbg_group29                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group30                  :std_ulogic_vector(0 to 87);
signal lsu_dbg_group31                  :std_ulogic_vector(0 to 87);
signal lsu_trg_group0                   :std_ulogic_vector(0 to 11);
signal lsu_trg_group1                   :std_ulogic_vector(0 to 11);
signal lsu_trg_group2                   :std_ulogic_vector(0 to 11);
signal lsu_trg_group3                   :std_ulogic_vector(0 to 11);
signal lmq_dbg_rel_ctrl                 :std_ulogic_vector(0 to 5);
signal ex3_instr_trace_val_d            :std_ulogic;
signal ex3_instr_trace_val_q            :std_ulogic;
signal ex4_instr_trace_val_d            :std_ulogic;
signal ex4_instr_trace_val_q            :std_ulogic;
signal trace_unit_sel                   :std_ulogic_vector(0 to 15);

constant trace_bus_enable_offset        :integer := 0;
constant ex3_instr_trace_val_offset     :integer := trace_bus_enable_offset     + 1;
constant ex4_instr_trace_val_offset     :integer := ex3_instr_trace_val_offset  + 1;
constant unit_trace_sel_offset          :integer := ex4_instr_trace_val_offset  + 1;
constant scan_right                     :integer := unit_trace_sel_offset       + unit_trace_sel_q'length;

signal dbg_scan_out                     :std_ulogic;
signal siv                              :std_ulogic_vector(0 to scan_right-1);
signal sov                              :std_ulogic_vector(0 to scan_right-1);
signal tiup                             :std_ulogic;

begin

tiup                  <= '1';



ex3_instr_trace_val_d <= xu_lsu_ex2_instr_trace_val;
ex4_instr_trace_val_d <= ex3_instr_trace_val_q;

with ex3_instr_trace_val_q select
    trace_unit_sel <= unit_trace_sel_q when '0',
                               x"09E0" when others;





lsu_dbg_group0_0 <= dc_val_dbg_data(208 to 215) & dc_val_dbg_data(216 to 220) & dc_val_dbg_data(293) & dc_val_dbg_data(226 to 229) &
                    dc_cntrl_dbg_data(24)       & dc_cntrl_dbg_data(25)       & dc_cntrl_dbg_data(26) & dc_cntrl_dbg_data(27);

lsu_dbg_group0_1 <= dc_val_dbg_data(264 to 267) & dc_val_dbg_data(268 to 271) & dc_cntrl_dbg_data(13 to 21) & dc_cntrl_dbg_data(28) &
                    dc_cntrl_dbg_data(29)       & dc_val_dbg_data(263)        & dc_val_dbg_data(262)        & dc_val_dbg_data(276);

lsu_dbg_group0_2 <= dc_cntrl_dbg_data(22) & dc_cntrl_dbg_data(23) & lmq_dbg_grp2(27 to 34) & lmq_dbg_grp3(7) & lmq_dbg_grp2(46) & lmq_dbg_grp3(50) & dc_cntrl_dbg_data(30 to 38);

lsu_dbg_group0_3 <= dc_cntrl_dbg_data(39 to 60);

lsu_dbg_group0  <= lsu_dbg_group0_0 & lsu_dbg_group0_1 & lsu_dbg_group0_2 & lsu_dbg_group0_3;






lsu_dbg_group1_b64 <= lmq_dbg_grp2(46) and not ex4_instr_trace_val_q;
lsu_dbg_group1_b67 <= dc_cntrl_dbg_data(23) or ex4_instr_trace_val_q;
lsu_dbg_group1_0 <= dc_val_dbg_data(208 to 215) & dc_val_dbg_data(216 to 220) & dc_val_dbg_data(293) & dc_val_dbg_data(226 to 229) &
                    dc_cntrl_dbg_data(61 to 64);

lsu_dbg_group1_1 <= dc_val_dbg_data(274) & dc_fgen_dbg_data(0) & lmq_dbg_grp2(27 to 34) & lmq_dbg_grp3(7) & dc_cntrl_dbg_data(30 to 40);
                    
lsu_dbg_group1_2 <= dc_cntrl_dbg_data(41 to 60) & lsu_dbg_group1_b64 & lmq_dbg_grp3(50);

lsu_dbg_group1_3 <= dc_cntrl_dbg_data(22) & lsu_dbg_group1_b67     & dc_fgen_dbg_data(1)       & dc_dir_dbg_data(0)   &
                    dc_dir_dbg_data(1)    & dc_dir_dbg_data(2)     & dc_lru_dbg_data(80)       & dc_val_dbg_data(275) &
                    dc_lru_dbg_data(77 to 79) & dc_dir_dbg_data(4) & dc_cntrl_dbg_data(8 to 9) & dc_val_dbg_data(272) &
                    dc_lru_dbg_data(75 to 76) & dc_val_dbg_data(221 to 225);

lsu_dbg_group1  <= lsu_dbg_group1_0 & lsu_dbg_group1_1 & lsu_dbg_group1_2 & lsu_dbg_group1_3;





wayDbgGen : for w in 0 to 7 generate begin

       lsu_dbg_way_0(w) <= (others=>'0');
       lsu_dbg_way_1(w) <= (others=>'0');
       lsu_dbg_way_2(w) <= (others=>'0');
       lsu_dbg_way_3(w) <= (others=>'0');
end generate wayDbgGen;

lsu_dbg_group2_0 <= lsu_dbg_way_0(0);
lsu_dbg_group2_1 <= lsu_dbg_way_1(0);
lsu_dbg_group2_2 <= lsu_dbg_way_2(0);
lsu_dbg_group2_3 <= lsu_dbg_way_3(0);
lsu_dbg_group2   <= lsu_dbg_group2_0  & lsu_dbg_group2_1  & lsu_dbg_group2_2  & lsu_dbg_group2_3;





lsu_dbg_group3_0 <= lsu_dbg_way_0(1);
lsu_dbg_group3_1 <= lsu_dbg_way_1(1);
lsu_dbg_group3_2 <= lsu_dbg_way_2(1);
lsu_dbg_group3_3 <= lsu_dbg_way_3(1);
lsu_dbg_group3   <= lsu_dbg_group3_0  & lsu_dbg_group3_1  & lsu_dbg_group3_2  & lsu_dbg_group3_3;





lsu_dbg_group4_0 <= lsu_dbg_way_0(2);
lsu_dbg_group4_1 <= lsu_dbg_way_1(2);
lsu_dbg_group4_2 <= lsu_dbg_way_2(2);
lsu_dbg_group4_3 <= lsu_dbg_way_3(2);
lsu_dbg_group4   <= lsu_dbg_group4_0  & lsu_dbg_group4_1  & lsu_dbg_group4_2  & lsu_dbg_group4_3;





lsu_dbg_group5_0 <= lsu_dbg_way_0(3);
lsu_dbg_group5_1 <= lsu_dbg_way_1(3);
lsu_dbg_group5_2 <= lsu_dbg_way_2(3);
lsu_dbg_group5_3 <= lsu_dbg_way_3(3);
lsu_dbg_group5   <= lsu_dbg_group5_0  & lsu_dbg_group5_1  & lsu_dbg_group5_2  & lsu_dbg_group5_3;





lsu_dbg_group6_0 <= lsu_dbg_way_0(4);
lsu_dbg_group6_1 <= lsu_dbg_way_1(4);
lsu_dbg_group6_2 <= lsu_dbg_way_2(4);
lsu_dbg_group6_3 <= lsu_dbg_way_3(4);
lsu_dbg_group6   <= lsu_dbg_group6_0  & lsu_dbg_group6_1  & lsu_dbg_group6_2  & lsu_dbg_group6_3;





lsu_dbg_group7_0 <= lsu_dbg_way_0(5);
lsu_dbg_group7_1 <= lsu_dbg_way_1(5);
lsu_dbg_group7_2 <= lsu_dbg_way_2(5);
lsu_dbg_group7_3 <= lsu_dbg_way_3(5);
lsu_dbg_group7   <= lsu_dbg_group7_0  & lsu_dbg_group7_1  & lsu_dbg_group7_2  & lsu_dbg_group7_3;





lsu_dbg_group8_0 <= lsu_dbg_way_0(6);
lsu_dbg_group8_1 <= lsu_dbg_way_1(6);
lsu_dbg_group8_2 <= lsu_dbg_way_2(6);
lsu_dbg_group8_3 <= lsu_dbg_way_3(6);
lsu_dbg_group8   <= lsu_dbg_group8_0  & lsu_dbg_group8_1  & lsu_dbg_group8_2  & lsu_dbg_group8_3;





lsu_dbg_group9_0 <= lsu_dbg_way_0(7);
lsu_dbg_group9_1 <= lsu_dbg_way_1(7);
lsu_dbg_group9_2 <= lsu_dbg_way_2(7);
lsu_dbg_group9_3 <= lsu_dbg_way_3(7);
lsu_dbg_group9   <= lsu_dbg_group9_0  & lsu_dbg_group9_1  & lsu_dbg_group9_2  & lsu_dbg_group9_3;





lsu_dbg_group10_0 <= dc_dir_dbg_data(0) & dc_dir_dbg_data(1) & dc_dir_dbg_data(2) & dc_lru_dbg_data(80) &
                     dc_val_dbg_data(275) & dc_lru_dbg_data(77 to 79) & dc_dir_dbg_data(4) & dc_fgen_dbg_data(0) &
                     dc_val_dbg_data(274) & dc_cntrl_dbg_data(0) & dc_dir_dbg_data(3) & dc_cntrl_dbg_data(1 to 9);

lsu_dbg_group10_1 <= dc_val_dbg_data(272) & dc_val_dbg_data(273) & dc_cntrl_dbg_data(10) & dc_lru_dbg_data(75 to 76) &
                     dc_cntrl_dbg_data(11) & dc_lru_dbg_data(0 to 7) & dc_lru_dbg_data(44) & dc_lru_dbg_data(52 to 58);

lsu_dbg_group10_2 <= dc_lru_dbg_data(16 to 23) & dc_dir_dbg_data(5 to 18);

lsu_dbg_group10_3 <= dc_dir_dbg_data(19 to 35) & dc_val_dbg_data(21 to 25);

lsu_dbg_group10 <= lsu_dbg_group10_0 & lsu_dbg_group10_1 & lsu_dbg_group10_2 & lsu_dbg_group10_3;





lsu_dbg_group11_0 <= dc_dir_dbg_data(0) & dc_dir_dbg_data(1) & dc_dir_dbg_data(2) & dc_lru_dbg_data(80) &
                     dc_val_dbg_data(275) & dc_lru_dbg_data(77 to 79) & dc_dir_dbg_data(4) & dc_fgen_dbg_data(0) &
                     dc_val_dbg_data(274) & dc_cntrl_dbg_data(8 to 9) & dc_val_dbg_data(272) & dc_lru_dbg_data(75 to 76) &
                     dc_cntrl_dbg_data(11) & dc_lru_dbg_data(59) & dc_lru_dbg_data(8 to 11);

lsu_dbg_group11_1 <= dc_lru_dbg_data(12 to 15) & '0' & '0' & dc_lru_dbg_data(16 to 23) & dc_lru_dbg_data(24 to 31);

lsu_dbg_group11_2 <= dc_lru_dbg_data(0 to 7) & dc_dir_dbg_data(5 to 18);

lsu_dbg_group11_3 <= dc_dir_dbg_data(19 to 35) & dc_val_dbg_data(21 to 25);

lsu_dbg_group11 <= lsu_dbg_group11_0 & lsu_dbg_group11_1 & lsu_dbg_group11_2 & lsu_dbg_group11_3;





lsu_dbg_group12_0 <= dc_dir_dbg_data(0) & dc_lru_dbg_data(77 to 79) & dc_lru_dbg_data(75 to 76) & dc_lru_dbg_data(42 to 43) &
                     dc_val_dbg_data(221 to 225) & dc_lru_dbg_data(24 to 31) & dc_lru_dbg_data(44);

lsu_dbg_group12_1 <= dc_lru_dbg_data(32 to 39) & dc_lru_dbg_data(45 to 51) & dc_lru_dbg_data(52 to 58);

lsu_dbg_group12_2 <= dc_lru_dbg_data(0 to 7) & dc_lru_dbg_data(59) & dc_val_dbg_data(216 to 220) & dc_lru_dbg_data(60 to 66) &
                     dc_lru_dbg_data(67);

lsu_dbg_group12_3 <= dc_lru_dbg_data(68 to 74) & dc_val_dbg_data(208 to 215) & dc_lru_dbg_data(81) & dc_cntrl_dbg_data(11) &
                     dc_lru_dbg_data(40 to 41) & "000";

lsu_dbg_group12 <= lsu_dbg_group12_0 & lsu_dbg_group12_1 & lsu_dbg_group12_2 & lsu_dbg_group12_3;





lsu_dbg_group13_0 <= dc_val_dbg_data(277) & dc_val_dbg_data(278) & dc_val_dbg_data(279 to 280) & dc_val_dbg_data(281 to 282) &
                     dc_val_dbg_data(283) & dc_val_dbg_data(284 to 291) & dc_val_dbg_data(292) & dc_dir_dbg_data(0) &
                     dc_dir_dbg_data(1) & dc_dir_dbg_data(2) & dc_lru_dbg_data(77 to 79);

lsu_dbg_group13_1 <= dc_val_dbg_data(221 to 225) & pe_recov_begin & lmq_dbg_dcache_pe(1 to 6) & lmq_dbg_dcache_pe(58 to 60) &
                     lmq_dbg_dcache_pe(7 to 13);

lsu_dbg_group13_2 <= lmq_dbg_dcache_pe(14 to 35);

lsu_dbg_group13_3 <= lmq_dbg_dcache_pe(36 to 57);

lsu_dbg_group13 <= lsu_dbg_group13_0 & lsu_dbg_group13_1 & lsu_dbg_group13_2 & lsu_dbg_group13_3;






lsu_dbg_group14_0 <= lmq_dbg_l2req(0 to 5) & lmq_dbg_l2req(67 to 77) & lmq_dbg_l2req(82 to 84) & lmq_dbg_l2req(64 to 65);

lsu_dbg_group14_1 <= lmq_dbg_l2req(66) & lmq_dbg_l2req(78 to 81) & lmq_dbg_rel(0 to 12) & lmq_dbg_pops(0 to 3);

lsu_dbg_group14_2 <= lmq_dbg_pops(4 to 5) & lmq_dbg_l2req(6 to 25);

lsu_dbg_group14_3 <= lmq_dbg_l2req(26 to 47);

lsu_dbg_group14 <= lsu_dbg_group14_0 & lsu_dbg_group14_1 & lsu_dbg_group14_2 & lsu_dbg_group14_3;






dataDbgGen : for w in 0 to 3 generate begin
      l2cmdq_dbg_data_0(w) <= lmq_dbg_l2req(0) & lmq_dbg_l2req(67 to 72) & lmq_dbg_l2req(74) & lmq_dbg_l2req(76 to 77) & lmq_dbg_l2req(48+(4*w) to 51+(4*w)) & lmq_dbg_l2req(6 to 13);
      l2cmdq_dbg_data_1(w) <= lmq_dbg_l2req(14 to 35);
      l2cmdq_dbg_data_2(w) <= lmq_dbg_l2req(36 to 47) & lmq_dbg_l2req(85+(32*w) to 94+(32*w));
      l2cmdq_dbg_data_3(w) <= lmq_dbg_l2req(95+(32*w) to 116+(32*w));
end generate dataDbgGen;


lsu_dbg_group15_0 <= l2cmdq_dbg_data_0(0);
lsu_dbg_group15_1 <= l2cmdq_dbg_data_1(0);
lsu_dbg_group15_2 <= l2cmdq_dbg_data_2(0);
lsu_dbg_group15_3 <= l2cmdq_dbg_data_3(0);
lsu_dbg_group15   <= lsu_dbg_group15_0 & lsu_dbg_group15_1 & lsu_dbg_group15_2 & lsu_dbg_group15_3;






lsu_dbg_group16_0 <= l2cmdq_dbg_data_0(1);
lsu_dbg_group16_1 <= l2cmdq_dbg_data_1(1);
lsu_dbg_group16_2 <= l2cmdq_dbg_data_2(1);
lsu_dbg_group16_3 <= l2cmdq_dbg_data_3(1);
lsu_dbg_group16   <= lsu_dbg_group16_0 & lsu_dbg_group16_1 & lsu_dbg_group16_2 & lsu_dbg_group16_3;






lsu_dbg_group17_0 <= l2cmdq_dbg_data_0(2);
lsu_dbg_group17_1 <= l2cmdq_dbg_data_1(2);
lsu_dbg_group17_2 <= l2cmdq_dbg_data_2(2);
lsu_dbg_group17_3 <= l2cmdq_dbg_data_3(2);
lsu_dbg_group17   <= lsu_dbg_group17_0 & lsu_dbg_group17_1 & lsu_dbg_group17_2 & lsu_dbg_group17_3;






lsu_dbg_group18_0 <= l2cmdq_dbg_data_0(3);
lsu_dbg_group18_1 <= l2cmdq_dbg_data_1(3);
lsu_dbg_group18_2 <= l2cmdq_dbg_data_2(3);
lsu_dbg_group18_3 <= l2cmdq_dbg_data_3(3);
lsu_dbg_group18   <= lsu_dbg_group18_0 & lsu_dbg_group18_1 & lsu_dbg_group18_2 & lsu_dbg_group18_3;






lsu_dbg_group19_0 <= lmq_dbg_l2req(0) & lmq_dbg_l2req(2 to 5) & lmq_dbg_l2req(67 to 72) & lmq_dbg_l2req(74) & lmq_dbg_rel(0 to 3) & lmq_dbg_rel(5 to 10);
lsu_dbg_group19_1 <= lmq_dbg_rel(11 to 12) & lmq_dbg_rel(13 to 32);
lsu_dbg_group19_2 <= lmq_dbg_rel(33 to 54);
lsu_dbg_group19_3 <= lmq_dbg_rel(55 to 76);
lsu_dbg_group19   <= lsu_dbg_group19_0 & lsu_dbg_group19_1 & lsu_dbg_group19_2 & lsu_dbg_group19_3;






lsu_dbg_group20_0 <= lmq_dbg_l2req(0) & lmq_dbg_l2req(2 to 5) & lmq_dbg_l2req(67 to 72) & lmq_dbg_l2req(74) & lmq_dbg_rel(0 to 3) & lmq_dbg_rel(5 to 10);
lsu_dbg_group20_1 <= lmq_dbg_rel(11 to 12) & lmq_dbg_rel(77 to 96);
lsu_dbg_group20_2 <= lmq_dbg_rel(97 to 118);
lsu_dbg_group20_3 <= lmq_dbg_rel(119 to 140);
lsu_dbg_group20   <= lsu_dbg_group20_0 & lsu_dbg_group20_1 & lsu_dbg_group20_2 & lsu_dbg_group20_3;






lsu_dbg_group21_0 <= lmq_dbg_binv(1 to 22);
lsu_dbg_group21_1 <= lmq_dbg_binv(23 to 42) & lmq_dbg_binv(43 to 44);
lsu_dbg_group21_2 <= lmq_dbg_binv(0) & lmq_dbg_grp0(40 to 47) & dc_val_dbg_data(208 to 215) & dc_val_dbg_data(216 to 220);
lsu_dbg_group21_3 <= dc_val_dbg_data(293) & dc_cntrl_dbg_data(40 to 60);
lsu_dbg_group21   <= lsu_dbg_group21_0 & lsu_dbg_group21_1 & lsu_dbg_group21_2 & lsu_dbg_group21_3;



lmq_dbg_rel_ctrl <= dc_dir_dbg_data(3) & dc_dir_dbg_data(0 to 2) & dc_cntrl_dbg_data(0) & dc_dir_dbg_data(4);

lsu_dbg_group22 <= lmq_dbg_grp0(0 to 71) & lmq_dbg_rel_ctrl & lmq_dbg_grp0(72 to 81);



lsu_dbg_group23 <= lmq_dbg_grp1(0 to 71) & lmq_dbg_rel_ctrl & lmq_dbg_grp1(72 to 81);



lsu_dbg_group24 <= lmq_dbg_grp2;



lsu_dbg_group25 <= lmq_dbg_grp3;



lsu_dbg_group26 <= (others=>'0');



lsu_dbg_group27 <= lmq_dbg_grp5;



lsu_dbg_group28 <= lmq_dbg_grp6;








lsu_dbg_group29_0 <= dir_arr_dbg_data(0 to 16)  & dir_arr_dbg_data(55)       & dir_arr_dbg_data(48 to 51);
lsu_dbg_group29_1 <= dir_arr_dbg_data(52 to 54) & dir_arr_dbg_data(56 to 60) & dir_arr_dbg_data(17 to 30);
lsu_dbg_group29_2 <= dir_arr_dbg_data(31 to 47) & "00000";
lsu_dbg_group29_3 <= (others=>'0');
lsu_dbg_group29   <= lsu_dbg_group29_0 & lsu_dbg_group29_1 & lsu_dbg_group29_2 & lsu_dbg_group29_3;
lsu_dbg_group30 <= derat_xu_debug_group0;
lsu_dbg_group31 <= derat_xu_debug_group1;



lsu_trg_group0  <= dc_val_dbg_data(293)  & dc_cntrl_dbg_data(65 to 66) & dc_cntrl_dbg_data(22 to 23) & dc_fgen_dbg_data(1) &
                   dc_cntrl_dbg_data(12) & dc_cntrl_dbg_data(26)       & dc_val_dbg_data(226 to 229);



lsu_trg_group1  <= lmq_dbg_l2req(0) & lmq_dbg_l2req(64 to 65) & lmq_dbg_l2req(67 to 72) & lmq_dbg_l2req(74 to 76);

lsu_trg_group2  <= (others=>'0');
lsu_trg_group3  <= (others=>'0');



dbg : entity work.xuq_debug_mux32(xuq_debug_mux32)
port map(

     trace_bus_enable           => trace_bus_enable_q,
     trace_unit_sel             => trace_unit_sel,

     debug_data_in              => debug_data_in,
     trigger_data_in            => trigger_data_in,

     dbg_group0                 => lsu_dbg_group0,
     dbg_group1                 => lsu_dbg_group1,
     dbg_group2                 => lsu_dbg_group2,
     dbg_group3                 => lsu_dbg_group3,
     dbg_group4                 => lsu_dbg_group4,
     dbg_group5                 => lsu_dbg_group5,
     dbg_group6                 => lsu_dbg_group6,
     dbg_group7                 => lsu_dbg_group7,
     dbg_group8                 => lsu_dbg_group8,
     dbg_group9                 => lsu_dbg_group9,
     dbg_group10                => lsu_dbg_group10,
     dbg_group11                => lsu_dbg_group11,
     dbg_group12                => lsu_dbg_group12,
     dbg_group13                => lsu_dbg_group13,
     dbg_group14                => lsu_dbg_group14,
     dbg_group15                => lsu_dbg_group15,
     dbg_group16                => lsu_dbg_group16,
     dbg_group17                => lsu_dbg_group17,
     dbg_group18                => lsu_dbg_group18,
     dbg_group19                => lsu_dbg_group19,
     dbg_group20                => lsu_dbg_group20,
     dbg_group21                => lsu_dbg_group21,
     dbg_group22                => lsu_dbg_group22,
     dbg_group23                => lsu_dbg_group23,
     dbg_group24                => lsu_dbg_group24,
     dbg_group25                => lsu_dbg_group25,
     dbg_group26                => lsu_dbg_group26,
     dbg_group27                => lsu_dbg_group27,
     dbg_group28                => lsu_dbg_group28,
     dbg_group29                => lsu_dbg_group29,
     dbg_group30                => lsu_dbg_group30,
     dbg_group31                => lsu_dbg_group31,

     trg_group0                 => lsu_trg_group0,
     trg_group1                 => lsu_trg_group1,
     trg_group2                 => lsu_trg_group2,
     trg_group3                 => lsu_trg_group3,

     trigger_data_out           => trigger_data_out,
     debug_data_out             => debug_data_out,

     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_slp_sl_thold_0_b      => func_slp_sl_thold_0_b,
     func_slp_sl_force => func_slp_sl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc,
     mpw1_dc_b                  => mpw1_dc_b,
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => scan_in,
     scan_out                   => dbg_scan_out
);

trace_bus_enable_latch : tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => pc_xu_trace_bus_enable,
            dout    => trace_bus_enable_q);
ex3_instr_trace_val_latch : tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_instr_trace_val_offset),
            scout   => sov(ex3_instr_trace_val_offset),
            din     => ex3_instr_trace_val_d,
            dout    => ex3_instr_trace_val_q);
ex4_instr_trace_val_latch : tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_instr_trace_val_offset),
            scout   => sov(ex4_instr_trace_val_offset),
            din     => ex4_instr_trace_val_d,
            dout    => ex4_instr_trace_val_q);
unit_trace_sel_latch : tri_rlmreg_p
generic map (width => unit_trace_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(unit_trace_sel_offset to unit_trace_sel_offset + unit_trace_sel_q'length-1),
            scout   => sov(unit_trace_sel_offset to unit_trace_sel_offset + unit_trace_sel_q'length-1),
            din     => lsu_debug_mux_ctrls,
            dout    => unit_trace_sel_q);

siv(0 to scan_right-1) <= sov(1 to scan_right-1) & dbg_scan_out;
scan_out               <= sov(0);

end architecture xuq_lsu_debug;
