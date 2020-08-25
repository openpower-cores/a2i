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
library ieee,ibm,support,work,tri,clib;
use ieee.std_logic_1164.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;

entity xuq_lsu_debug is
generic(expand_type          :integer :=  2);
port(

     -- PC Debug Control
     pc_xu_trace_bus_enable     :in  std_ulogic;
     lsu_debug_mux_ctrls        :in  std_ulogic_vector(0 to 15);
     xu_lsu_ex2_instr_trace_val :in  std_ulogic;

     -- Pass Thru Debug Trace Bus
     trigger_data_in            :in  std_ulogic_vector(0 to 11);
     debug_data_in              :in  std_ulogic_vector(0 to 87);

     -- Debug Data
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



-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Instruction Trace Mode
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Trace Mode selects debug bus 1
-- bit67 of debug bus 1 becomes ex4_instr_trace_val_q
ex3_instr_trace_val_d <= xu_lsu_ex2_instr_trace_val;
ex4_instr_trace_val_d <= ex3_instr_trace_val_q;

with ex3_instr_trace_val_q select
    trace_unit_sel <= unit_trace_sel_q when '0',
                               x"09E0" when others;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 0 -> General Instruction
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex4_way_hit_q		8
-- ex4_congr_cl_q               5
-- binv4_ex4_xuop_upd_q         1
-- ex4_dir_access_op            4
-- ex1_ldst_falign_q            1
-- ex2_ldst_fexcpt_q            1
-- ex5_cache_inh_q              1
-- ex3_data_swap_int            1

-- rel_lost_watch_upd_q         4
-- stm_watchlost_state_q	4
-- ex5_axu_ta_gpr_q             9
-- ex5_xu_wren_q		1
-- ex5_axu_wren_q               1
-- ex4_dir_err_val_q            1
-- ex4_dir_multihit_val_q       1
-- ex7_ld_par_err               1

-- ex2_is_mem_bar_op            1
-- ex3_l2_op_q                  1
-- ld_rel_val_l2		8
-- st_entry0_val_l2             1
-- load_cmd_count_l2(0)         1
-- store_cmd_count_l2(0)	1
-- ex4_p_addr                   9

-- ex4_p_addr                   22
-- Total                        88

lsu_dbg_group0_0 <= dc_val_dbg_data(208 to 215) & dc_val_dbg_data(216 to 220) & dc_val_dbg_data(293) & dc_val_dbg_data(226 to 229) &
                    dc_cntrl_dbg_data(24)       & dc_cntrl_dbg_data(25)       & dc_cntrl_dbg_data(26) & dc_cntrl_dbg_data(27);

lsu_dbg_group0_1 <= dc_val_dbg_data(264 to 267) & dc_val_dbg_data(268 to 271) & dc_cntrl_dbg_data(13 to 21) & dc_cntrl_dbg_data(28) &
                    dc_cntrl_dbg_data(29)       & dc_val_dbg_data(263)        & dc_val_dbg_data(262)        & dc_val_dbg_data(276);

lsu_dbg_group0_2 <= dc_cntrl_dbg_data(22) & dc_cntrl_dbg_data(23) & lmq_dbg_grp2(27 to 34) & lmq_dbg_grp3(7) & lmq_dbg_grp2(46) & lmq_dbg_grp3(50) & dc_cntrl_dbg_data(30 to 38);

lsu_dbg_group0_3 <= dc_cntrl_dbg_data(39 to 60);

lsu_dbg_group0  <= lsu_dbg_group0_0 & lsu_dbg_group0_1 & lsu_dbg_group0_2 & lsu_dbg_group0_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 1 -> General Instruction with Reload
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex4_way_hit_q		8
-- ex4_congr_cl_q		5       <-- ex4_p_addr_q(53:57)
-- binv4_ex4_xuop_upd_q		1
-- ex4_dir_access_op		4
-- ex4_p_addr(58:61)            4

-- ldq_rel_back_invalidated	1
-- ldq_rel_ci                   1
-- ld_rel_val_l2		8
-- st_entry0_val_l2		1
-- ex4_p_addr(22:32)            11

-- ex4_p_addr(33:52)            20
-- load_cmd_count_l2(0)		1
-- store_cmd_count_l2(0)	1

-- ex2_is_mem_bar_op		1
-- ex3_l2_op_q                  1
-- ex4_n_flush_rq_q		1
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_tag                  3
-- ldq_rel_set_val		1
-- ldq_rel_ta_gpr(7:8)		2
-- ldq_rel_lock_en		1
-- ldq_rel_classid		2
-- rel_congr_cl_q		5

-- Total                        88

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

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 2 -> WayA Bypass
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex4_wayA_byp_ctrl_fxpipe	1
-- ex4_wayA_byp_ctrl_relpipe	1
-- ex4_wayA_val                 6
-- ex4_congr_cl_q		5
-- ex4_p_addr                   9

-- ex4_p_addr                   22

-- ex4_way_hit_q(0)		1
-- binv4_ex4_xuop_upd_q		1
-- ex4_dir_access_op		4
-- binv_wayA_upd2_q		1
-- flush_wayA_data_q		6
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_set_val		1
-- rel_way_dwen(0)		1
-- rel_wayA_byp_ctrl_fxpipe	1
-- rel_wayA_byp_ctrl_relpipe	1

-- ldq_rel_back_invalidated	1
-- ldq_rel_tag                  3
-- rel_wayA_val                 6
-- rel_congr_cl_q		5
-- reload_wayA_upd2_q		1
-- reload_wayA_data_q		6
-- Total                        88

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

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 3 -> WayB Bypass
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex4_wayB_byp_ctrl_fxpipe	1
-- ex4_wayB_byp_ctrl_relpipe	1
-- ex4_wayB_val                 6
-- ex4_congr_cl_q		5
-- ex4_p_addr                   9

-- ex4_p_addr                   22

-- ex4_way_hit_q(1)		1
-- binv4_ex4_xuop_upd_q		1
-- ex4_dir_access_op		4
-- binv_wayB_upd2_q		1
-- flush_wayB_data_q		6
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_set_val		1
-- rel_way_dwen(1)		1
-- rel_wayB_byp_ctrl_fxpipe	1
-- rel_wayB_byp_ctrl_relpipe	1

-- ldq_rel_back_invalidated	1
-- ldq_rel_tag                  3
-- rel_wayB_val                 6
-- rel_congr_cl_q		5
-- reload_wayB_upd2_q		1
-- reload_wayB_data_q		6
-- Total                        88

lsu_dbg_group3_0 <= lsu_dbg_way_0(1);
lsu_dbg_group3_1 <= lsu_dbg_way_1(1);
lsu_dbg_group3_2 <= lsu_dbg_way_2(1);
lsu_dbg_group3_3 <= lsu_dbg_way_3(1);
lsu_dbg_group3   <= lsu_dbg_group3_0  & lsu_dbg_group3_1  & lsu_dbg_group3_2  & lsu_dbg_group3_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 4 -> WayC Bypass
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex4_wayC_byp_ctrl_fxpipe	1
-- ex4_wayC_byp_ctrl_relpipe	1
-- ex4_wayC_val                 6
-- ex4_congr_cl_q		5
-- ex4_p_addr                   9

-- ex4_p_addr                   22

-- ex4_way_hit_q(2)		1
-- binv4_ex4_xuop_upd_q		1
-- ex4_dir_access_op		4
-- binv_wayC_upd2_q		1
-- flush_wayC_data_q		6
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_set_val		1
-- rel_way_dwen(2)		1
-- rel_wayC_byp_ctrl_fxpipe	1
-- rel_wayC_byp_ctrl_relpipe	1

-- ldq_rel_back_invalidated	1
-- ldq_rel_tag                  3
-- rel_wayC_val                 6
-- rel_congr_cl_q		5
-- reload_wayC_upd2_q		1
-- reload_wayC_data_q		6
-- Total                        88

lsu_dbg_group4_0 <= lsu_dbg_way_0(2);
lsu_dbg_group4_1 <= lsu_dbg_way_1(2);
lsu_dbg_group4_2 <= lsu_dbg_way_2(2);
lsu_dbg_group4_3 <= lsu_dbg_way_3(2);
lsu_dbg_group4   <= lsu_dbg_group4_0  & lsu_dbg_group4_1  & lsu_dbg_group4_2  & lsu_dbg_group4_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 5 -> WayD Bypass
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex4_wayD_byp_ctrl_fxpipe	1
-- ex4_wayD_byp_ctrl_relpipe	1
-- ex4_wayD_val                 6
-- ex4_congr_cl_q		5
-- ex4_p_addr                   9

-- ex4_p_addr                   22

-- ex4_way_hit_q(3)		1
-- binv4_ex4_xuop_upd_q		1
-- ex4_dir_access_op		4
-- binv_wayD_upd2_q		1
-- flush_wayD_data_q		6
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_set_val		1
-- rel_way_dwen(3)		1
-- rel_wayD_byp_ctrl_fxpipe	1
-- rel_wayD_byp_ctrl_relpipe	1

-- ldq_rel_back_invalidated	1
-- ldq_rel_tag                  3
-- rel_wayD_val                 6
-- rel_congr_cl_q		5
-- reload_wayD_upd2_q		1
-- reload_wayD_data_q		6
-- Total                        88

lsu_dbg_group5_0 <= lsu_dbg_way_0(3);
lsu_dbg_group5_1 <= lsu_dbg_way_1(3);
lsu_dbg_group5_2 <= lsu_dbg_way_2(3);
lsu_dbg_group5_3 <= lsu_dbg_way_3(3);
lsu_dbg_group5   <= lsu_dbg_group5_0  & lsu_dbg_group5_1  & lsu_dbg_group5_2  & lsu_dbg_group5_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 6 -> WayE Bypass
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex4_wayE_byp_ctrl_fxpipe	1
-- ex4_wayE_byp_ctrl_relpipe	1
-- ex4_wayE_val                 6
-- ex4_congr_cl_q		5
-- ex4_p_addr                   9

-- ex4_p_addr                   22

-- ex4_way_hit_q(4)		1
-- binv4_ex4_xuop_upd_q		1
-- ex4_dir_access_op		4
-- binv_wayE_upd2_q		1
-- flush_wayE_data_q		6
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_set_val		1
-- rel_way_dwen(4)		1
-- rel_wayE_byp_ctrl_fxpipe	1
-- rel_wayE_byp_ctrl_relpipe	1

-- ldq_rel_back_invalidated	1
-- ldq_rel_tag                  3
-- rel_wayE_val                 6
-- rel_congr_cl_q		5
-- reload_wayE_upd2_q		1
-- reload_wayE_data_q		6
-- Total                        88

lsu_dbg_group6_0 <= lsu_dbg_way_0(4);
lsu_dbg_group6_1 <= lsu_dbg_way_1(4);
lsu_dbg_group6_2 <= lsu_dbg_way_2(4);
lsu_dbg_group6_3 <= lsu_dbg_way_3(4);
lsu_dbg_group6   <= lsu_dbg_group6_0  & lsu_dbg_group6_1  & lsu_dbg_group6_2  & lsu_dbg_group6_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 7 -> WayF Bypass
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex4_wayF_byp_ctrl_fxpipe	1
-- ex4_wayF_byp_ctrl_relpipe	1
-- ex4_wayF_val                 6
-- ex4_congr_cl_q		5
-- ex4_p_addr                   9

-- ex4_p_addr                   22

-- ex4_way_hit_q(5)		1
-- binv4_ex4_xuop_upd_q		1
-- ex4_dir_access_op		4
-- binv_wayF_upd2_q		1
-- flush_wayF_data_q		6
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_set_val		1
-- rel_way_dwen(5)		1
-- rel_wayF_byp_ctrl_fxpipe	1
-- rel_wayF_byp_ctrl_relpipe	1

-- ldq_rel_back_invalidated	1
-- ldq_rel_tag                  3
-- rel_wayF_val                 6
-- rel_congr_cl_q		5
-- reload_wayF_upd2_q		1
-- reload_wayF_data_q		6
-- Total                        88

lsu_dbg_group7_0 <= lsu_dbg_way_0(5);
lsu_dbg_group7_1 <= lsu_dbg_way_1(5);
lsu_dbg_group7_2 <= lsu_dbg_way_2(5);
lsu_dbg_group7_3 <= lsu_dbg_way_3(5);
lsu_dbg_group7   <= lsu_dbg_group7_0  & lsu_dbg_group7_1  & lsu_dbg_group7_2  & lsu_dbg_group7_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 8 -> WayG Bypass
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex4_wayG_byp_ctrl_fxpipe	1
-- ex4_wayG_byp_ctrl_relpipe	1
-- ex4_wayG_val                 6
-- ex4_congr_cl_q		5
-- ex4_p_addr                   9

-- ex4_p_addr                   22

-- ex4_way_hit_q(6)		1
-- binv4_ex4_xuop_upd_q		1
-- ex4_dir_access_op		4
-- binv_wayG_upd2_q		1
-- flush_wayG_data_q		6
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_set_val		1
-- rel_way_dwen(6)		1
-- rel_wayG_byp_ctrl_fxpipe	1
-- rel_wayG_byp_ctrl_relpipe	1

-- ldq_rel_back_invalidated	1
-- ldq_rel_tag                  3
-- rel_wayG_val                 6
-- rel_congr_cl_q		5
-- reload_wayG_upd2_q		1
-- reload_wayG_data_q		6
-- Total                        88

lsu_dbg_group8_0 <= lsu_dbg_way_0(6);
lsu_dbg_group8_1 <= lsu_dbg_way_1(6);
lsu_dbg_group8_2 <= lsu_dbg_way_2(6);
lsu_dbg_group8_3 <= lsu_dbg_way_3(6);
lsu_dbg_group8   <= lsu_dbg_group8_0  & lsu_dbg_group8_1  & lsu_dbg_group8_2  & lsu_dbg_group8_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 9 -> WayH Bypass
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex4_wayH_byp_ctrl_fxpipe	1
-- ex4_wayH_byp_ctrl_relpipe	1
-- ex4_wayH_val                 6
-- ex4_congr_cl_q		5
-- ex4_p_addr                   9

-- ex4_p_addr                   22

-- ex4_way_hit_q(7)		1
-- binv4_ex4_xuop_upd_q		1
-- ex4_dir_access_op		4
-- binv_wayH_upd2_q		1
-- flush_wayH_data_q		6
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_set_val		1
-- rel_way_dwen(7)		1
-- rel_wayH_byp_ctrl_fxpipe	1
-- rel_wayH_byp_ctrl_relpipe	1

-- ldq_rel_back_invalidated	1
-- ldq_rel_tag                  3
-- rel_wayH_val                 6
-- rel_congr_cl_q		5
-- reload_wayH_upd2_q		1
-- reload_wayH_data_q		6
-- Total                        88

lsu_dbg_group9_0 <= lsu_dbg_way_0(7);
lsu_dbg_group9_1 <= lsu_dbg_way_1(7);
lsu_dbg_group9_2 <= lsu_dbg_way_2(7);
lsu_dbg_group9_3 <= lsu_dbg_way_3(7);
lsu_dbg_group9   <= lsu_dbg_group9_0  & lsu_dbg_group9_1  & lsu_dbg_group9_2  & lsu_dbg_group9_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 10 -> General Reload
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_tag                  3
-- ldq_rel_set_val		1
-- ldq_rel_ci                   1
-- ldq_rel_back_invalidated	1
-- ldq_rel_upd_gpr		1
-- rel_data_val                 1
-- ldq_rel_ta_gpr(0:8)		9

-- ldq_rel_lock_en		1
-- ldq_rel_watch_en		1
-- ldq_rel_axu_val		1
-- ldq_rel_classid		2
-- spr_xucr0_dcdis_q		1
-- rel24_way_dwen_stg_q		8
-- rel_val_wen_q		1
-- rel_lru_val_q		7

-- rel_m_q_way_q		8
-- ldq_rel_addr                 14

-- ldq_rel_addr                 22
-- Total                        88

lsu_dbg_group10_0 <= dc_dir_dbg_data(0) & dc_dir_dbg_data(1) & dc_dir_dbg_data(2) & dc_lru_dbg_data(80) &
                     dc_val_dbg_data(275) & dc_lru_dbg_data(77 to 79) & dc_dir_dbg_data(4) & dc_fgen_dbg_data(0) &
                     dc_val_dbg_data(274) & dc_cntrl_dbg_data(0) & dc_dir_dbg_data(3) & dc_cntrl_dbg_data(1 to 9);

lsu_dbg_group10_1 <= dc_val_dbg_data(272) & dc_val_dbg_data(273) & dc_cntrl_dbg_data(10) & dc_lru_dbg_data(75 to 76) &
                     dc_cntrl_dbg_data(11) & dc_lru_dbg_data(0 to 7) & dc_lru_dbg_data(44) & dc_lru_dbg_data(52 to 58);

lsu_dbg_group10_2 <= dc_lru_dbg_data(16 to 23) & dc_dir_dbg_data(5 to 18);

lsu_dbg_group10_3 <= dc_dir_dbg_data(19 to 35) & dc_val_dbg_data(21 to 25);

lsu_dbg_group10 <= lsu_dbg_group10_0 & lsu_dbg_group10_1 & lsu_dbg_group10_2 & lsu_dbg_group10_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 11 -> General Reload Queue
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_retry_val		1
-- ldq_recirc_rel_val		1
-- ldq_rel_tag                  3
-- ldq_rel_set_val		1
-- ldq_rel_ci                   1
-- ldq_rel_back_invalidated	1
-- ldq_rel_ta_gpr(7:8)		2
-- ldq_rel_lock_en		1
-- ldq_rel_classid		2
-- spr_xucr0_dcdis_q		1
-- xucr0_clo_q                  1
-- reld_q_val(0:3)		4

-- reld_q_val(4:7)		4
-- rel_m_q_upd                  1       <-- Whats up with that
-- reld_q_early_byp		1       <-- Whats up with that
-- rel_m_q_way_q		8
-- rel2_wlock_q                 8

-- rel_way_dwen                 8
-- ldq_rel_addr                 14

-- ldq_rel_addr                 22
-- Total                        88

lsu_dbg_group11_0 <= dc_dir_dbg_data(0) & dc_dir_dbg_data(1) & dc_dir_dbg_data(2) & dc_lru_dbg_data(80) &
                     dc_val_dbg_data(275) & dc_lru_dbg_data(77 to 79) & dc_dir_dbg_data(4) & dc_fgen_dbg_data(0) &
                     dc_val_dbg_data(274) & dc_cntrl_dbg_data(8 to 9) & dc_val_dbg_data(272) & dc_lru_dbg_data(75 to 76) &
                     dc_cntrl_dbg_data(11) & dc_lru_dbg_data(59) & dc_lru_dbg_data(8 to 11);

lsu_dbg_group11_1 <= dc_lru_dbg_data(12 to 15) & '0' & '0' & dc_lru_dbg_data(16 to 23) & dc_lru_dbg_data(24 to 31);

lsu_dbg_group11_2 <= dc_lru_dbg_data(0 to 7) & dc_dir_dbg_data(5 to 18);

lsu_dbg_group11_3 <= dc_dir_dbg_data(19 to 35) & dc_val_dbg_data(21 to 25);

lsu_dbg_group11 <= lsu_dbg_group11_0 & lsu_dbg_group11_1 & lsu_dbg_group11_2 & lsu_dbg_group11_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 12 -> General LRU
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ldq_rel1_val                 1
-- ldq_rel_tag                  3
-- ldq_rel_classid		2
-- rel_fxubyp_val		1
-- rel_relbyp_val		1
-- rel_congr_cl_q		5
-- rel2_wlock_q                 8
-- rel_val_wen_q		1

-- way_not_empty		8
-- rel_op_lru                   7
-- rel_lru_val_q		7

-- rel_way_dwen                 8
-- xucr0_clo_q                  1
-- ex4_congr_cl_q		5
-- xu_op_lru                    7
-- ex6_c_acc_val_q		1

-- ex6_lru_upd_q		7
-- ex4_way_hit_q		8
-- ex4_c_acc_q                  1
-- spr_xucr0_dcdis_q		1
-- ex4_fxubyp_val		1
-- ex4_relbyp_val		1
-- Total                        85

lsu_dbg_group12_0 <= dc_dir_dbg_data(0) & dc_lru_dbg_data(77 to 79) & dc_lru_dbg_data(75 to 76) & dc_lru_dbg_data(42 to 43) &
                     dc_val_dbg_data(221 to 225) & dc_lru_dbg_data(24 to 31) & dc_lru_dbg_data(44);

lsu_dbg_group12_1 <= dc_lru_dbg_data(32 to 39) & dc_lru_dbg_data(45 to 51) & dc_lru_dbg_data(52 to 58);

lsu_dbg_group12_2 <= dc_lru_dbg_data(0 to 7) & dc_lru_dbg_data(59) & dc_val_dbg_data(216 to 220) & dc_lru_dbg_data(60 to 66) &
                     dc_lru_dbg_data(67);

lsu_dbg_group12_3 <= dc_lru_dbg_data(68 to 74) & dc_val_dbg_data(208 to 215) & dc_lru_dbg_data(81) & dc_cntrl_dbg_data(11) &
                     dc_lru_dbg_data(40 to 41) & "000";

lsu_dbg_group12 <= lsu_dbg_group12_0 & lsu_dbg_group12_1 & lsu_dbg_group12_2 & lsu_dbg_group12_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 13 -> Data Cache Parity Error Recovery
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ex9_ld_par_err_q		1
-- rel_in_progress		1
-- dcpar_err_ind_sel		2
-- dcpar_err_cntr_q		2
-- dcpar_err_push_queue		1
-- dcpar_err_way_q		8
-- dcpar_err_stg2_q		1
-- ldq_rel1_val                 1
-- ldq_rel_mid_val		1
-- ldq_rel3_val                 1
-- ldq_rel_tag                  3

-- rel_congr_cl_q		5
-- pe_recov_begin               1
-- l2req_resend_l2              1
-- l2req_recycle_l2 &           1
-- ex6_ld_recov_val_l2 &        1
-- ex6_ld_recov_extra_l2(0) &   1
-- ex7_ld_recov_val_l2 &        1
-- ex7_ld_recov_extra_l2(0) &   1
-- stq_hit_ex6_recov_l2         1
-- pe_recov_state_l2            1
-- blk_ld_for_pe_recov_l2       1
-- ex7_ld_recov_l2(1 to 6)      6
-- ex7_ld_recov_l2(18)          1

-- ex7_ld_recov_l2(19 to 21)    3
-- ex7_ld_recov_l2(53 to 71)    18

-- ex7_ld_recov_l2(72 to 93)    22
-- Total                        88

lsu_dbg_group13_0 <= dc_val_dbg_data(277) & dc_val_dbg_data(278) & dc_val_dbg_data(279 to 280) & dc_val_dbg_data(281 to 282) &
                     dc_val_dbg_data(283) & dc_val_dbg_data(284 to 291) & dc_val_dbg_data(292) & dc_dir_dbg_data(0) &
                     dc_dir_dbg_data(1) & dc_dir_dbg_data(2) & dc_lru_dbg_data(77 to 79);

lsu_dbg_group13_1 <= dc_val_dbg_data(221 to 225) & pe_recov_begin & lmq_dbg_dcache_pe(1 to 6) & lmq_dbg_dcache_pe(58 to 60) &
                     lmq_dbg_dcache_pe(7 to 13);

lsu_dbg_group13_2 <= lmq_dbg_dcache_pe(14 to 35);

lsu_dbg_group13_3 <= lmq_dbg_dcache_pe(36 to 57);

lsu_dbg_group13 <= lsu_dbg_group13_0 & lsu_dbg_group13_1 & lsu_dbg_group13_2 & lsu_dbg_group13_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 14 -> L2 Request General
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- l2req_l2                     1
-- l2req_ld_core_tag_l2         5
-- l2req_ttype_l2               6
-- l2req_wimg_l2                4
-- l2req_endian_l2              1
-- l2req_ld_xfr_len_l2          3
-- l2req_thread_l2(0:1)         2

-- l2req_thread_l2(2)           1
-- l2req_user_l2                4
-- anaclat_data_coming          1
-- anaclat_data_val             1
-- an_ac_reld_crit_qw           1
-- anaclat_ditc                 1
-- anaclat_l1_dump              1
-- anaclat_tag                  4
-- anaclat_qw                   2
-- anaclat_ecc_err              1
-- anaclat_ecc_err_ue           1
-- anaclat_ld_pop               1
-- anaclat_st_gather            1
-- anaclat_st_pop               1
-- anaclat_st_pop_thrd(0)       1

-- anaclat_st_pop_thrd(1:2)     2
-- l2req_ra_l2(22:41)           19

-- l2req_ra_l2(42:63)           22
-- Total                        88

lsu_dbg_group14_0 <= lmq_dbg_l2req(0 to 5) & lmq_dbg_l2req(67 to 77) & lmq_dbg_l2req(82 to 84) & lmq_dbg_l2req(64 to 65);

lsu_dbg_group14_1 <= lmq_dbg_l2req(66) & lmq_dbg_l2req(78 to 81) & lmq_dbg_rel(0 to 12) & lmq_dbg_pops(0 to 3);

lsu_dbg_group14_2 <= lmq_dbg_pops(4 to 5) & lmq_dbg_l2req(6 to 25);

lsu_dbg_group14_3 <= lmq_dbg_l2req(26 to 47);

lsu_dbg_group14 <= lsu_dbg_group14_0 & lsu_dbg_group14_1 & lsu_dbg_group14_2 & lsu_dbg_group14_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 15 -> L2 Request Store Data0
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- l2req_l2                     1
-- l2req_ttype_l2               6
-- l2req_wimg_l2(1)             1
-- l2req_wimg_l2(3)             1
-- l2req_endian_l2              1
-- l2req_st_byte_enbl_l2(0:3)   4
-- l2req_ra_l2(22:29)           8

-- l2req_ra_l2(30:51)           22

-- l2req_ra_l2(52:63)           12
-- ex6_st_data_l2(0:9)          10

-- ex6_st_data_l2(10:31)        22
-- Total                        88

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

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 16 -> L2 Request Store Data1
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- l2req_l2                     1
-- l2req_ttype_l2               6
-- l2req_wimg_l2(1)             1
-- l2req_wimg_l2(3)             1
-- l2req_endian_l2              1
-- l2req_st_byte_enbl_l2(4:7)   4
-- l2req_ra_l2(22:29)           8

-- l2req_ra_l2(30:51)           22

-- l2req_ra_l2(52:63)           12
-- ex6_st_data_l2(32:41)        10

-- ex6_st_data_l2(42:63)        22
-- Total                        88

lsu_dbg_group16_0 <= l2cmdq_dbg_data_0(1);
lsu_dbg_group16_1 <= l2cmdq_dbg_data_1(1);
lsu_dbg_group16_2 <= l2cmdq_dbg_data_2(1);
lsu_dbg_group16_3 <= l2cmdq_dbg_data_3(1);
lsu_dbg_group16   <= lsu_dbg_group16_0 & lsu_dbg_group16_1 & lsu_dbg_group16_2 & lsu_dbg_group16_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 17 -> L2 Request Store Data2
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- l2req_l2                     1
-- l2req_ttype_l2               6
-- l2req_wimg_l2(1)             1
-- l2req_wimg_l2(3)             1
-- l2req_endian_l2              1
-- l2req_st_byte_enbl_l2(8:11)  4
-- l2req_ra_l2(22:29)           8

-- l2req_ra_l2(30:51)           22

-- l2req_ra_l2(52:63)           12
-- ex6_st_data_l2(64:73)        10

-- ex6_st_data_l2(74:95)        22
-- Total                        88

lsu_dbg_group17_0 <= l2cmdq_dbg_data_0(2);
lsu_dbg_group17_1 <= l2cmdq_dbg_data_1(2);
lsu_dbg_group17_2 <= l2cmdq_dbg_data_2(2);
lsu_dbg_group17_3 <= l2cmdq_dbg_data_3(2);
lsu_dbg_group17   <= lsu_dbg_group17_0 & lsu_dbg_group17_1 & lsu_dbg_group17_2 & lsu_dbg_group17_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 18 -> L2 Request Store Data3
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- l2req_l2                     1
-- l2req_ttype_l2               6
-- l2req_wimg_l2(1)             1
-- l2req_wimg_l2(3)             1
-- l2req_endian_l2              1
-- l2req_st_byte_enbl_l2(12:15) 4
-- l2req_ra_l2(22:29)           8

-- l2req_ra_l2(30:51)           22

-- l2req_ra_l2(52:63)           12
-- ex6_st_data_l2(96:105)       10

-- ex6_st_data_l2(106:127)      22
-- Total                        88

lsu_dbg_group18_0 <= l2cmdq_dbg_data_0(3);
lsu_dbg_group18_1 <= l2cmdq_dbg_data_1(3);
lsu_dbg_group18_2 <= l2cmdq_dbg_data_2(3);
lsu_dbg_group18_3 <= l2cmdq_dbg_data_3(3);
lsu_dbg_group18   <= lsu_dbg_group18_0 & lsu_dbg_group18_1 & lsu_dbg_group18_2 & lsu_dbg_group18_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 19 -> L2 Reload Interface0
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- l2req_l2                     1
-- l2req_ld_core_tag_l2(1:4)    4
-- l2req_ttype_l2               6
-- l2req_wimg_l2(1)             1
-- anaclat_data_coming          1
-- anaclat_data_val             1
-- an_ac_reld_crit_qw           1
-- anaclat_ditc                 1
-- anaclat_tag                  4
-- anaclat_qw                   2

-- anaclat_ecc_err              1
-- anaclat_ecc_err_ue           1
-- anaclat_data(0:19)           20

-- anaclat_data(20:41)          22

-- anaclat_data(42:63)          22
-- Total                        88

lsu_dbg_group19_0 <= lmq_dbg_l2req(0) & lmq_dbg_l2req(2 to 5) & lmq_dbg_l2req(67 to 72) & lmq_dbg_l2req(74) & lmq_dbg_rel(0 to 3) & lmq_dbg_rel(5 to 10);
lsu_dbg_group19_1 <= lmq_dbg_rel(11 to 12) & lmq_dbg_rel(13 to 32);
lsu_dbg_group19_2 <= lmq_dbg_rel(33 to 54);
lsu_dbg_group19_3 <= lmq_dbg_rel(55 to 76);
lsu_dbg_group19   <= lsu_dbg_group19_0 & lsu_dbg_group19_1 & lsu_dbg_group19_2 & lsu_dbg_group19_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 20 -> L2 Reload Interface1
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- l2req_l2                     1
-- l2req_ld_core_tag_l2(1:4)    4
-- l2req_ttype_l2               6
-- l2req_wimg_l2(1)             1
-- anaclat_data_coming          1
-- anaclat_data_val             1
-- an_ac_reld_crit_qw           1
-- anaclat_ditc                 1
-- anaclat_tag                  4
-- anaclat_qw                   2

-- anaclat_ecc_err              1
-- anaclat_ecc_err_ue           1
-- anaclat_data(0:19)           20

-- anaclat_data(20:41)          22

-- anaclat_data(42:63)          22
-- Total                        88

lsu_dbg_group20_0 <= lmq_dbg_l2req(0) & lmq_dbg_l2req(2 to 5) & lmq_dbg_l2req(67 to 72) & lmq_dbg_l2req(74) & lmq_dbg_rel(0 to 3) & lmq_dbg_rel(5 to 10);
lsu_dbg_group20_1 <= lmq_dbg_rel(11 to 12) & lmq_dbg_rel(77 to 96);
lsu_dbg_group20_2 <= lmq_dbg_rel(97 to 118);
lsu_dbg_group20_3 <= lmq_dbg_rel(119 to 140);
lsu_dbg_group20   <= lsu_dbg_group20_0 & lsu_dbg_group20_1 & lsu_dbg_group20_2 & lsu_dbg_group20_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 21 -> Back Invalidate Interface
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- anaclat_back_inv_addr(22:43) 22

-- anaclat_back_inv_addr(44:63) 20
-- anaclat_back_inv_target_1    1
-- anaclat_back_inv_target_4    1

-- anaclat_back_inv             1
-- lmq_back_invalidated_l2      8
-- ex4_way_hit_q		8
-- ex4_congr_cl_q               5

-- binv4_ex4_xuop_upd_q         1
-- ex4_p_addr                   21
-- Total                        88

lsu_dbg_group21_0 <= lmq_dbg_binv(1 to 22);
lsu_dbg_group21_1 <= lmq_dbg_binv(23 to 42) & lmq_dbg_binv(43 to 44);
lsu_dbg_group21_2 <= lmq_dbg_binv(0) & lmq_dbg_grp0(40 to 47) & dc_val_dbg_data(208 to 215) & dc_val_dbg_data(216 to 220);
lsu_dbg_group21_3 <= dc_val_dbg_data(293) & dc_cntrl_dbg_data(40 to 60);
lsu_dbg_group21   <= lsu_dbg_group21_0 & lsu_dbg_group21_1 & lsu_dbg_group21_2 & lsu_dbg_group21_3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 22 -> LoadmissQ Debug Group0
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--lmq_dbg_grp0 <= l_m_rel_hit_beat0_l2 &                              --(0:7)
--                l_m_rel_hit_beat1_l2 &                              --(8:15)
--                l_m_rel_hit_beat2_l2 &                              --(16:23)
--                l_m_rel_hit_beat3_l2 &                              --(24:31)
--                l_m_rel_val_c_i_dly &                               --(32:39)
--                lmq_back_invalidated_l2(0 to lmq_entries-1) &       --(40:47)
--                complete_qentry(0 to lmq_entries-1) &               --(48:55)
--                ldq_retry_l2(0 to lmq_entries-1) &                  --(56:63)
--                retry_started_l2(0 to lmq_entries-1) &              --(64:71)
--                gpr_ecc_err_l2(0 to lmq_entries-1) &                --(78:85)
--                "00";                                               --(86:87)

lmq_dbg_rel_ctrl <= dc_dir_dbg_data(3) & dc_dir_dbg_data(0 to 2) & dc_cntrl_dbg_data(0) & dc_dir_dbg_data(4);

lsu_dbg_group22 <= lmq_dbg_grp0(0 to 71) & lmq_dbg_rel_ctrl & lmq_dbg_grp0(72 to 81);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 23 -> LoadmissQ Debug Group1
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--lmq_dbg_grp1 <= l_m_rel_hit_beat0_l2 &                              --(0:7)
--                l_m_rel_hit_beat1_l2 &                              --(8:15)
--                l_m_rel_hit_beat2_l2 &                              --(16:23)
--                l_m_rel_hit_beat3_l2 &                              --(24:31)
--                l_m_rel_val_c_i_dly &                               --(32:39)
--                gpr_ecc_err_l2(0 to lmq_entries-1) &                --(40:47)
--                data_ecc_err_l2(0 to lmq_entries-1) &               --(48:55)
--                data_ecc_ue_l2(0 to lmq_entries-1) &                --(56:63)
--                gpr_updated_prev_l2(0 to lmq_entries-1) &           --(64:71)
--                anaclat_data_val &                                  --(78)
--                anaclat_reld_crit_qw &                              --(79)
--                anaclat_tag(1 to 4) &                               --(80:83)
--                anaclat_qw(58 to 59) &                              --(84:85)
--                anaclat_ecc_err &                                   --(86)
--                anaclat_ecc_err_ue;                                 --(87)


lsu_dbg_group23 <= lmq_dbg_grp1(0 to 71) & lmq_dbg_rel_ctrl & lmq_dbg_grp1(72 to 81);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 24 -> LoadmissQ Debug Group2
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--lmq_dbg_grp2 <= I1_G1_flush &                                       --(0)
--                ld_queue_full &                                     --(1)
--                ex4_drop_ld_req &                                   --(2)
--                ex5_flush_l2 &                                      --(3)
--                ex5_stg_flush &                                     --(4)
--                cmd_type_ld(0 to 5) &                               --(5:10)
--                ex4_loadmiss_qentry(0 to lmq_entries-1) &           --(11:18)
--                ld_entry_val_l2(0 to lmq_entries-1) &               --(19:26)
--                ld_rel_val_l2(0 to lmq_entries-1) &                 --(27:34)
--                ex4_lmq_cpy_l2(0 to lmq_entries-1) &                --(35:42)
--                send_if_req_l2 &                                    --(43)
--                send_ld_req_l2 &                                    --(44)
--                send_mm_req_l2 &                                    --(45)
--                load_cmd_count_l2 &                                 --(46:49)
--                load_sent &                                         --(50)
--                load_flushed &                                      --(51)
--                selected_entry_flushed &                            --(52)
--                ex6_load_sent_l2 &                                  --(53)
--                ex6_flush_l2 &                                      --(54)
--                cmd_seq_l2 &                                        --(55:59)
--                l_q_rd_en &                                         --(60:67)
--                rd_seq_num_skip &                                   --(68)
--                lq_rd_en_is_ex5 &                                   --(69)
--                lq_rd_en_is_ex6 &                                   --(70)
--                l_m_q_hit_st_l2(0 to lmq_entries-1) &               --(71:78)
--                lmq_drop_rel_l2(0 to lmq_entries-1) &               --(79:86)
--                '0';                                                --(87)

lsu_dbg_group24 <= lmq_dbg_grp2;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 25 -> LoadmissQ Debug Group3
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--lmq_dbg_grp3 <= sync_flush &                                       --(0)
--                flush_if_store &                                   --(1)
--                I1_G1_flush &                                      --(2)
--                l_m_fnd_stg &                                      --(3)
--                ex5_flush_l2 &                                     --(4)
--                ex5_stg_flush &                                    --(5)
--                ex4_st_val_l2 &                                    --(6)
--                st_entry0_val_l2 &                                 --(7)
--                s_m_queue0(0 to 5) &                               --(8:13)
--                s_m_queue0(58 to (58+real_data_add-6-1)) &         --(14:49)
--                store_cmd_count_l2 &                               --(50:55)
--                ex5_sel_st_req &                                   --(56)
--                store_sent &                                       --(57)
--                ex6_store_sent_l2 &                                --(58)
--                ex6_flush_l2 &                                     --(59)
--                l2req_l2 &                                         --(60)
--             	  l2req_thread_l2 &                                  --(61:63)
--                l2req_ttype_l2 &                                   --(64:69)
--                ob_req_val_l2 &                                    --(70)
--                ob_ditc_val_l2 &                                   --(71)
--                "0000000000000000";                                --(72:87)

lsu_dbg_group25 <= lmq_dbg_grp3;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 26 -> LoadmissQ Debug Group4
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


lsu_dbg_group26 <= (others=>'0');

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 27 -> LoadmissQ Debug Group5
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--lmq_dbg_grp5 <= mm_req_val_l2 &                                    --(0)
--                mmu_q_val_l2 &                                     --(1)
--                mmu_q_entry_l2 &                                   --(2:69)
--                send_if_req_l2 &                                   --(70)
--                send_ld_req_l2 &                                   --(71)
--                send_mm_req_l2 &                                   --(72)
--                mmu_sent &                                         --(73)
--                l2req_l2 &                                         --(74)
--                l2req_thread_l2 &                                  --(75:77)
--                l2req_ttype_l2 &                                   --(78:83)
--                "0000";

lsu_dbg_group27 <= lmq_dbg_grp5;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 28 -> LoadmissQ Debug Group6
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--lmq_dbg_grp6 <= ex3_stg_flush &                                    --(0)
--                I1_G1_flush &                                      --(1)
--                sync_flush &                                       --(2)
--                flush_if_store &                                   --(3)
--                ld_queue_full &                                    --(4)
--                ex4_drop_ld_req &                                  --(5)
--                l_m_fnd_stg &                                      --(6)
--                ex4_stg_flush &                                    --(7)
--                my_ex4_flush_l2 &                                  --(8)
--                ex5_stg_flush &                                    --(9)
--                ex2_lm_dep_hit_buf &                               --(10)
--                ex3_load_instr &                                   --(11)
--                ex3_thrd_id(0 to 3) &                              --(12:15)
--                cmd_type_st(0 to 5) &                              --(16:21)
--                cmd_type_ld(0 to 5) &                              --(22:27)
--                ex4_lmq_cpy_l2(0 to lmq_entries-1) &               --(28:35)
--                lmq_collision_t0_l2(0 to lmq_entries-1) &          --(36:43)
--                lmq_collision_t1_l2(0 to lmq_entries-1) &          --(44:51)
--                lmq_collision_t2_l2(0 to lmq_entries-1) &          --(52:59)
--                lmq_collision_t3_l2(0 to lmq_entries-1) &          --(60:67)
--                ldq_barr_active_l2(0 to 3) &                       --(68:71)
--                ldq_barr_done_l2(0 to 3) &                         --(72:75)
--                sync_done_tid_l2(0 to 3) &                         --(76:79)
--                "00000000";

lsu_dbg_group28 <= lmq_dbg_grp6;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus 29 -> Directory Access
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- dir_wr_enable_int            4
-- dir_wr_way_int               8
-- dir_arr_wr_addr_int          5
-- recirc_rel_val_q             1
-- dir_arr_wr_data_int(31:34)   4

-- ex1_dir_acc_val              1
-- ex1_l2_inv_val               1
-- binv1_ex1_stg_act            1
-- lwr_p_addr_q(53:57)          5
-- dir_arr_wr_data_int(0:13)    14

-- dir_arr_wr_data_int(14:30)   17
-- 0                            5

-- 0                            22

--dir_arr_dbg_data   <= dir_wr_enable_int & dir_wr_way_int & dir_arr_wr_addr_int & dir_arr_wr_data_int &            --(0:51)
--                      ex1_dir_acc_val   & ex1_l2_inv_val & binv1_ex1_stg_act   & recirc_rel_val_q    &            --(52:55)
--                      lwr_p_addr_q(53:57);                                                                        --(56:60)


lsu_dbg_group29_0 <= dir_arr_dbg_data(0 to 16)  & dir_arr_dbg_data(55)       & dir_arr_dbg_data(48 to 51);
lsu_dbg_group29_1 <= dir_arr_dbg_data(52 to 54) & dir_arr_dbg_data(56 to 60) & dir_arr_dbg_data(17 to 30);
lsu_dbg_group29_2 <= dir_arr_dbg_data(31 to 47) & "00000";
lsu_dbg_group29_3 <= (others=>'0');
lsu_dbg_group29   <= lsu_dbg_group29_0 & lsu_dbg_group29_1 & lsu_dbg_group29_2 & lsu_dbg_group29_3;
lsu_dbg_group30 <= derat_xu_debug_group0;
lsu_dbg_group31 <= derat_xu_debug_group1;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Trigger Bus 0 -> Instruction Pipe
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- binv4_ex4_xuop_upd_q         1
-- ex4_enc_thdid                2
-- ex2_is_mem_bar_op		1
-- ex3_l2_op_q                  1
-- ex4_n_flush_rq_q		1
-- ex4_miss                     1
-- ex5_cache_inh_q              1
-- ex4_dir_access_op            4

lsu_trg_group0  <= dc_val_dbg_data(293)  & dc_cntrl_dbg_data(65 to 66) & dc_cntrl_dbg_data(22 to 23) & dc_fgen_dbg_data(1) &
                   dc_cntrl_dbg_data(12) & dc_cntrl_dbg_data(26)       & dc_val_dbg_data(226 to 229);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Trigger Bus 1 -> L2 Request
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- l2req_l2                     1
-- l2req_thread_l2(0:1)         2
-- l2req_ttype_l2               6
-- l2req_wimg_l2(1:3)           3

lsu_trg_group1  <= lmq_dbg_l2req(0) & lmq_dbg_l2req(64 to 65) & lmq_dbg_l2req(67 to 72) & lmq_dbg_l2req(74 to 76);

lsu_trg_group2  <= (others=>'0');
lsu_trg_group3  <= (others=>'0');

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Pass Thru/Swap Muxing
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

dbg : entity work.xuq_debug_mux32(xuq_debug_mux32)
port map(

     -- PC Debug Control
     trace_bus_enable           => trace_bus_enable_q,
     trace_unit_sel             => trace_unit_sel,

     -- Pass Thru Debug Trace Bus
     debug_data_in              => debug_data_in,
     trigger_data_in            => trigger_data_in,

     -- Debug Data In
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

     -- Trigger Data In
     trg_group0                 => lsu_trg_group0,
     trg_group1                 => lsu_trg_group1,
     trg_group2                 => lsu_trg_group2,
     trg_group3                 => lsu_trg_group3,

     -- Outputs
     trigger_data_out           => trigger_data_out,
     debug_data_out             => debug_data_out,

     -- Power
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

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Registers
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
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
