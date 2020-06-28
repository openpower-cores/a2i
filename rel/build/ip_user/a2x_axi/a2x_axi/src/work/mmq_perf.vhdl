-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.




library ieee;
use ieee.std_logic_1164.all;

library ibm,clib;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;

library support;
use support.power_logic_pkg.all;

library tri;
use tri.tri_latches_pkg.all;


entity mmq_perf is
generic(thdid_width       : integer := 4;
          expand_type        : integer := 2 );
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;
 
     pc_func_sl_thold_2         : in std_ulogic;
     pc_func_slp_nsl_thold_2    : in std_ulogic;
     pc_sg_2                    : in std_ulogic;
     pc_fce_2                   : in std_ulogic;
     tc_ac_ccflush_dc           : in std_ulogic;
     
     lcb_clkoff_dc_b            : in std_ulogic;
     lcb_act_dis_dc             : in std_ulogic;
     lcb_d_mode_dc              : in std_ulogic;
     lcb_delay_lclkr_dc         : in std_ulogic;
     lcb_mpw1_dc_b              : in std_ulogic;
     lcb_mpw2_dc_b              : in std_ulogic;
     
     scan_in                    : in std_ulogic;
     scan_out                   : out std_ulogic;

     xu_mm_msr_gs           : in std_ulogic_vector(0 to thdid_width-1);
     xu_mm_msr_pr           : in std_ulogic_vector(0 to thdid_width-1);
     xu_mm_ccr2_notlb_b     : in std_ulogic;

     xu_mm_ex5_perf_dtlb     : in std_ulogic_vector(0 to thdid_width-1); 
     xu_mm_ex5_perf_itlb     : in std_ulogic_vector(0 to thdid_width-1); 

     tlb_cmp_perf_event_t0           : in std_ulogic_vector(0 to 9);
     tlb_cmp_perf_event_t1           : in std_ulogic_vector(0 to 9);
     tlb_cmp_perf_event_t2           : in std_ulogic_vector(0 to 9);
     tlb_cmp_perf_event_t3           : in std_ulogic_vector(0 to 9);
     tlb_cmp_perf_state              : in std_ulogic_vector(0 to 1);  
     
     tlb_cmp_perf_miss_direct       : in std_ulogic;
     tlb_cmp_perf_hit_indirect      : in std_ulogic; 
     tlb_cmp_perf_hit_first_page    : in std_ulogic;
     tlb_cmp_perf_ptereload_noexcep : in std_ulogic; 
     tlb_cmp_perf_lrat_request      : in std_ulogic;  
     tlb_cmp_perf_lrat_miss         : in std_ulogic; 
     tlb_cmp_perf_pt_fault          : in std_ulogic; 
     tlb_cmp_perf_pt_inelig         : in std_ulogic;  
     tlb_ctl_perf_tlbwec_resv       : in std_ulogic;  
     tlb_ctl_perf_tlbwec_noresv     : in std_ulogic;

     derat_req0_thdid              : in std_ulogic_vector(0 to thdid_width-1);
     derat_req0_valid              : in std_ulogic;
     derat_req1_thdid              : in std_ulogic_vector(0 to thdid_width-1);
     derat_req1_valid              : in std_ulogic;
     derat_req2_thdid              : in std_ulogic_vector(0 to thdid_width-1);
     derat_req2_valid              : in std_ulogic;
     derat_req3_thdid              : in std_ulogic_vector(0 to thdid_width-1);
     derat_req3_valid              : in std_ulogic;

     ierat_req0_thdid              : in std_ulogic_vector(0 to thdid_width-1);
     ierat_req0_valid              : in std_ulogic;
     ierat_req0_nonspec            : in std_ulogic;
     ierat_req1_thdid              : in std_ulogic_vector(0 to thdid_width-1);
     ierat_req1_valid              : in std_ulogic;
     ierat_req1_nonspec            : in std_ulogic;
     ierat_req2_thdid              : in std_ulogic_vector(0 to thdid_width-1);
     ierat_req2_valid              : in std_ulogic;
     ierat_req2_nonspec            : in std_ulogic;
     ierat_req3_thdid              : in std_ulogic_vector(0 to thdid_width-1);
     ierat_req3_valid              : in std_ulogic;
     ierat_req3_nonspec            : in std_ulogic;

     ierat_req_taken               : in std_ulogic;
     derat_req_taken               : in std_ulogic;
     tlb_tag0_thdid                : in std_ulogic_vector(0 to thdid_width-1);
     tlb_tag0_type                 : in std_ulogic_vector(0 to 1);  
     tlb_seq_idle                  : in std_ulogic;

     inval_perf_tlbilx             : in std_ulogic;
     inval_perf_tlbivax            : in std_ulogic;
     inval_perf_tlbivax_snoop      : in std_ulogic;
     inval_perf_tlb_flush          : in std_ulogic;

     htw_req0_valid                : in std_ulogic;
     htw_req0_thdid                : in std_ulogic_vector(0 to thdid_width-1);
     htw_req0_type                 : in std_ulogic_vector(0 to 1);
     htw_req1_valid                : in std_ulogic;
     htw_req1_thdid                : in std_ulogic_vector(0 to thdid_width-1);
     htw_req1_type                 : in std_ulogic_vector(0 to 1);
     htw_req2_valid                : in std_ulogic;
     htw_req2_thdid                : in std_ulogic_vector(0 to thdid_width-1);
     htw_req2_type                 : in std_ulogic_vector(0 to 1);
     htw_req3_valid                : in std_ulogic;
     htw_req3_thdid                : in std_ulogic_vector(0 to thdid_width-1);
     htw_req3_type                 : in std_ulogic_vector(0 to 1);


     pc_mm_event_mux_ctrls     : in std_ulogic_vector(0 to 39);
     pc_mm_event_count_mode    : in std_ulogic_vector(0 to 2);  
     rp_mm_event_bus_enable_q  : in std_ulogic; 

     mm_pc_event_data           : out std_ulogic_vector(0 to 7)

);
  -- synopsys translate_off


  -- synopsys translate_on
end mmq_perf;


architecture mmq_perf of mmq_perf is
constant rp_mm_event_bus_enable_offset : natural := 0;
constant pc_mm_event_mux_ctrls_offset  : natural := rp_mm_event_bus_enable_offset + 1;
constant pc_mm_event_count_mode_offset : natural := pc_mm_event_mux_ctrls_offset + 40;
constant xu_mm_msr_gs_offset           : natural := pc_mm_event_count_mode_offset + 3;
constant xu_mm_msr_pr_offset           : natural := xu_mm_msr_gs_offset + thdid_width;
constant event_data_offset             : natural := xu_mm_msr_pr_offset + thdid_width;
constant scan_right                    : natural := event_data_offset + 8 -1;

signal event_data_d             : std_ulogic_vector(0 to 7);
signal event_data_q             : std_ulogic_vector(0 to 7);
signal rp_mm_event_bus_enable_int_q : std_ulogic;
signal pc_mm_event_mux_ctrls_q      : std_ulogic_vector(0 to 39);
signal pc_mm_event_count_mode_q     : std_ulogic_vector(0 to 2);  

signal mm_perf_event_t0_d, mm_perf_event_t0_q                : std_ulogic_vector(0 to 15);
signal mm_perf_event_t1_d, mm_perf_event_t1_q                : std_ulogic_vector(0 to 15);
signal mm_perf_event_t2_d, mm_perf_event_t2_q                : std_ulogic_vector(0 to 15);
signal mm_perf_event_t3_d, mm_perf_event_t3_q                : std_ulogic_vector(0 to 15);

signal xu_mm_msr_gs_q           : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_msr_pr_q           : std_ulogic_vector(0 to thdid_width-1);
signal event_en                 : std_ulogic_vector(0 to thdid_width);

signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);

signal tidn                     : std_ulogic;
signal tiup                     : std_ulogic;

signal pc_func_sl_thold_1    : std_ulogic;
signal pc_func_sl_thold_0    : std_ulogic;
signal pc_func_sl_thold_0_b  : std_ulogic;
signal pc_func_slp_nsl_thold_1    : std_ulogic;
signal pc_func_slp_nsl_thold_0    : std_ulogic;
signal pc_func_slp_nsl_thold_0_b  : std_ulogic;
signal pc_func_slp_nsl_force      : std_ulogic;
signal pc_sg_1               : std_ulogic;
signal pc_sg_0               : std_ulogic;
signal pc_fce_1               : std_ulogic;
signal pc_fce_0               : std_ulogic;
signal forcee                    : std_ulogic;

begin


tidn <= '0';
tiup <= '1';

event_en(0 to 3)        <= (    xu_mm_msr_pr_q(0 to 3)                                and (0 to 3 => pc_mm_event_count_mode_q(0))) or 
                           (not xu_mm_msr_pr_q(0 to 3) and     xu_mm_msr_gs_q(0 to 3) and (0 to 3 => pc_mm_event_count_mode_q(1))) or 
                           (not xu_mm_msr_pr_q(0 to 3) and not xu_mm_msr_gs_q(0 to 3) and (0 to 3 => pc_mm_event_count_mode_q(2)));   

event_en(4)        <= (tlb_cmp_perf_state(1)  and pc_mm_event_count_mode_q(0)) or 
                  (not tlb_cmp_perf_state(1) and  tlb_cmp_perf_state(0) and pc_mm_event_count_mode_q(1)) or 
                   (not tlb_cmp_perf_state(1) and not tlb_cmp_perf_state(0) and pc_mm_event_count_mode_q(2));   





mm_perf_event_t0_d(0 to 9) <= tlb_cmp_perf_event_t0(0 to 9) and (0 to 9 => event_en(0));

mm_perf_event_t0_d(10) <= (((ierat_req0_valid and ierat_req0_nonspec and ierat_req0_thdid(0)) or
                           (ierat_req1_valid and ierat_req1_nonspec and ierat_req1_thdid(0)) or
                           (ierat_req2_valid and ierat_req2_nonspec and ierat_req2_thdid(0)) or
                           (ierat_req3_valid and ierat_req3_nonspec and ierat_req3_thdid(0)) or
                           (not tlb_seq_idle and tlb_tag0_type(1) and tlb_tag0_thdid(0)) or  
                           (htw_req0_valid and htw_req0_type(1) and htw_req0_thdid(0)) or
                           (htw_req1_valid and htw_req1_type(1) and htw_req1_thdid(0)) or
                           (htw_req2_valid and htw_req2_type(1) and htw_req2_thdid(0)) or
                           (htw_req3_valid and htw_req3_type(1) and htw_req3_thdid(0))) 
                                 and xu_mm_ccr2_notlb_b)
                         or (xu_mm_ex5_perf_itlb(0) and not xu_mm_ccr2_notlb_b);

mm_perf_event_t0_d(11) <= (((derat_req0_valid and derat_req0_thdid(0)) or
                           (derat_req1_valid and derat_req1_thdid(0)) or
                           (derat_req2_valid and derat_req2_thdid(0)) or
                           (derat_req3_valid and derat_req3_thdid(0)) or
                           (not tlb_seq_idle and tlb_tag0_type(0) and tlb_tag0_thdid(0)) or  
                           (htw_req0_valid and htw_req0_type(0) and htw_req0_thdid(0)) or
                           (htw_req1_valid and htw_req1_type(0) and htw_req1_thdid(0)) or
                           (htw_req2_valid and htw_req2_type(0) and htw_req2_thdid(0)) or
                           (htw_req3_valid and htw_req3_type(0) and htw_req3_thdid(0))) 
                                 and xu_mm_ccr2_notlb_b)
                         or (xu_mm_ex5_perf_dtlb(0) and not xu_mm_ccr2_notlb_b);

mm_perf_event_t0_d(12) <= ierat_req_taken;

mm_perf_event_t0_d(13) <= derat_req_taken;

mm_perf_event_t0_d(14) <= tlb_cmp_perf_miss_direct and event_en(4);

mm_perf_event_t0_d(15) <= tlb_cmp_perf_hit_first_page and event_en(4);



mm_perf_event_t1_d(0 to 9) <= tlb_cmp_perf_event_t1(0 to 9) and (0 to 9 => event_en(1));

mm_perf_event_t1_d(10) <= (((ierat_req0_valid and ierat_req0_nonspec and ierat_req0_thdid(1)) or
                           (ierat_req1_valid and ierat_req1_nonspec and ierat_req1_thdid(1)) or
                           (ierat_req2_valid and ierat_req2_nonspec and ierat_req2_thdid(1)) or
                           (ierat_req3_valid and ierat_req3_nonspec and ierat_req3_thdid(1)) or
                           (not tlb_seq_idle and tlb_tag0_type(1) and tlb_tag0_thdid(1)) or  
                           (htw_req0_valid and htw_req0_type(1) and htw_req0_thdid(1)) or
                           (htw_req1_valid and htw_req1_type(1) and htw_req1_thdid(1)) or
                           (htw_req2_valid and htw_req2_type(1) and htw_req2_thdid(1)) or
                           (htw_req3_valid and htw_req3_type(1) and htw_req3_thdid(1))) 
                                 and xu_mm_ccr2_notlb_b)
                         or (xu_mm_ex5_perf_itlb(1) and not xu_mm_ccr2_notlb_b);

mm_perf_event_t1_d(11) <= (((derat_req0_valid and derat_req0_thdid(1)) or
                           (derat_req1_valid and derat_req1_thdid(1)) or
                           (derat_req2_valid and derat_req2_thdid(1)) or
                           (derat_req3_valid and derat_req3_thdid(1)) or
                           (not tlb_seq_idle and tlb_tag0_type(0) and tlb_tag0_thdid(1)) or  
                           (htw_req0_valid and htw_req0_type(0) and htw_req0_thdid(1)) or
                           (htw_req1_valid and htw_req1_type(0) and htw_req1_thdid(1)) or
                           (htw_req2_valid and htw_req2_type(0) and htw_req2_thdid(1)) or
                           (htw_req3_valid and htw_req3_type(0) and htw_req3_thdid(1))) 
                                 and xu_mm_ccr2_notlb_b)
                         or (xu_mm_ex5_perf_dtlb(1) and not xu_mm_ccr2_notlb_b);

mm_perf_event_t1_d(12) <= tlb_cmp_perf_hit_indirect and event_en(4);

mm_perf_event_t1_d(13) <= tlb_cmp_perf_ptereload_noexcep and event_en(4);

mm_perf_event_t1_d(14) <= tlb_cmp_perf_lrat_request and event_en(4);

mm_perf_event_t1_d(15) <= tlb_cmp_perf_lrat_miss and event_en(4);


mm_perf_event_t2_d(0 to 9) <= tlb_cmp_perf_event_t2(0 to 9) and (0 to 9 => event_en(2));

mm_perf_event_t2_d(10) <= (((ierat_req0_valid and ierat_req0_nonspec and ierat_req0_thdid(2)) or
                           (ierat_req1_valid and ierat_req1_nonspec and ierat_req1_thdid(2)) or
                           (ierat_req2_valid and ierat_req2_nonspec and ierat_req2_thdid(2)) or
                           (ierat_req3_valid and ierat_req3_nonspec and ierat_req3_thdid(2)) or
                           (not tlb_seq_idle and tlb_tag0_type(1) and tlb_tag0_thdid(2)) or  
                           (htw_req0_valid and htw_req0_type(1) and htw_req0_thdid(2)) or
                           (htw_req1_valid and htw_req1_type(1) and htw_req1_thdid(2)) or
                           (htw_req2_valid and htw_req2_type(1) and htw_req2_thdid(2)) or
                           (htw_req3_valid and htw_req3_type(1) and htw_req3_thdid(2))) 
                                 and xu_mm_ccr2_notlb_b)
                         or (xu_mm_ex5_perf_itlb(2) and not xu_mm_ccr2_notlb_b);

mm_perf_event_t2_d(11) <= (((derat_req0_valid and derat_req0_thdid(2)) or
                           (derat_req1_valid and derat_req1_thdid(2)) or
                           (derat_req2_valid and derat_req2_thdid(2)) or
                           (derat_req3_valid and derat_req3_thdid(2)) or
                           (not tlb_seq_idle and tlb_tag0_type(0) and tlb_tag0_thdid(2)) or  
                           (htw_req0_valid and htw_req0_type(0) and htw_req0_thdid(2)) or
                           (htw_req1_valid and htw_req1_type(0) and htw_req1_thdid(2)) or
                           (htw_req2_valid and htw_req2_type(0) and htw_req2_thdid(2)) or
                           (htw_req3_valid and htw_req3_type(0) and htw_req3_thdid(2))) 
                                 and xu_mm_ccr2_notlb_b)
                         or (xu_mm_ex5_perf_dtlb(2) and not xu_mm_ccr2_notlb_b);

mm_perf_event_t2_d(12) <= tlb_cmp_perf_pt_fault and event_en(4);

mm_perf_event_t2_d(13) <= tlb_cmp_perf_pt_inelig and event_en(4);

mm_perf_event_t2_d(14) <= tlb_ctl_perf_tlbwec_noresv and event_en(4);

mm_perf_event_t2_d(15) <= tlb_ctl_perf_tlbwec_resv and event_en(4);


mm_perf_event_t3_d(0 to 9) <= tlb_cmp_perf_event_t3(0 to 9) and (0 to 9 => event_en(3));

mm_perf_event_t3_d(10) <= (((ierat_req0_valid and ierat_req0_nonspec and ierat_req0_thdid(3)) or
                           (ierat_req1_valid and ierat_req1_nonspec and ierat_req1_thdid(3)) or
                           (ierat_req2_valid and ierat_req2_nonspec and ierat_req2_thdid(3)) or
                           (ierat_req3_valid and ierat_req3_nonspec and ierat_req3_thdid(3)) or
                           (not tlb_seq_idle and tlb_tag0_type(1) and tlb_tag0_thdid(3)) or  
                           (htw_req0_valid and htw_req0_type(1) and htw_req0_thdid(3)) or
                           (htw_req1_valid and htw_req1_type(1) and htw_req1_thdid(3)) or
                           (htw_req2_valid and htw_req2_type(1) and htw_req2_thdid(3)) or
                           (htw_req3_valid and htw_req3_type(1) and htw_req3_thdid(3))) 
                                 and xu_mm_ccr2_notlb_b)
                         or (xu_mm_ex5_perf_itlb(3) and not xu_mm_ccr2_notlb_b);

mm_perf_event_t3_d(11) <= (((derat_req0_valid and derat_req0_thdid(3)) or
                           (derat_req1_valid and derat_req1_thdid(3)) or
                           (derat_req2_valid and derat_req2_thdid(3)) or
                           (derat_req3_valid and derat_req3_thdid(3)) or
                           (not tlb_seq_idle and tlb_tag0_type(0) and tlb_tag0_thdid(3)) or  
                           (htw_req0_valid and htw_req0_type(0) and htw_req0_thdid(3)) or
                           (htw_req1_valid and htw_req1_type(0) and htw_req1_thdid(3)) or
                           (htw_req2_valid and htw_req2_type(0) and htw_req2_thdid(3)) or
                           (htw_req3_valid and htw_req3_type(0) and htw_req3_thdid(3))) 
                                 and xu_mm_ccr2_notlb_b)
                         or (xu_mm_ex5_perf_dtlb(3) and not xu_mm_ccr2_notlb_b);

mm_perf_event_t3_d(12) <= inval_perf_tlbilx;

mm_perf_event_t3_d(13) <= inval_perf_tlbivax;

mm_perf_event_t3_d(14) <= inval_perf_tlbivax_snoop;

mm_perf_event_t3_d(15) <= inval_perf_tlb_flush;


event_mux1: entity clib.c_event_mux
  generic map ( events_in => 64, 
                   events_out => 8 )
  port map(
           vd => vdd, 
           gd => gnd,

           t0_events            => mm_perf_event_t0_q(0 to 15),
           t1_events            => mm_perf_event_t1_q(0 to 15),
           t2_events            => mm_perf_event_t2_q(0 to 15),
           t3_events            => mm_perf_event_t3_q(0 to 15),

           select_bits          => pc_mm_event_mux_ctrls_q(0 to 39),
           event_bits           => event_data_d(0 to 7)
);


mm_pc_event_data                <= event_data_q(0 to 7);



rp_mm_event_bus_enable_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => forcee,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(rp_mm_event_bus_enable_offset),
            scout   => sov(rp_mm_event_bus_enable_offset),
            din     => rp_mm_event_bus_enable_q,  
            dout    => rp_mm_event_bus_enable_int_q);   
            
pc_mm_event_mux_ctrls_latch: tri_rlmreg_p
  generic map (width => pc_mm_event_mux_ctrls_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => forcee,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(pc_mm_event_mux_ctrls_offset to pc_mm_event_mux_ctrls_offset + pc_mm_event_mux_ctrls_q'length-1),
            scout   => sov(pc_mm_event_mux_ctrls_offset to pc_mm_event_mux_ctrls_offset + pc_mm_event_mux_ctrls_q'length-1),
            din     => pc_mm_event_mux_ctrls,
            dout    => pc_mm_event_mux_ctrls_q );

pc_mm_event_count_mode_latch: tri_rlmreg_p
  generic map (width => pc_mm_event_count_mode_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => forcee,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(pc_mm_event_count_mode_offset to pc_mm_event_count_mode_offset + pc_mm_event_count_mode_q'length-1),
            scout   => sov(pc_mm_event_count_mode_offset to pc_mm_event_count_mode_offset + pc_mm_event_count_mode_q'length-1),
            din     => pc_mm_event_count_mode,
            dout    => pc_mm_event_count_mode_q );

xu_mm_msr_gs_latch: tri_rlmreg_p
  generic map (width => xu_mm_msr_gs_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rp_mm_event_bus_enable_int_q,
            thold_b => pc_func_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => forcee,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(xu_mm_msr_gs_offset to xu_mm_msr_gs_offset + xu_mm_msr_gs_q'length-1),
            scout   => sov(xu_mm_msr_gs_offset to xu_mm_msr_gs_offset + xu_mm_msr_gs_q'length-1),
            din     => xu_mm_msr_gs,
            dout    => xu_mm_msr_gs_q );

xu_mm_msr_pr_latch: tri_rlmreg_p
  generic map (width => xu_mm_msr_pr_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rp_mm_event_bus_enable_int_q,
            thold_b => pc_func_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => forcee,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(xu_mm_msr_pr_offset to xu_mm_msr_pr_offset + xu_mm_msr_pr_q'length-1),
            scout   => sov(xu_mm_msr_pr_offset to xu_mm_msr_pr_offset + xu_mm_msr_pr_q'length-1),
            din     => xu_mm_msr_pr,
            dout    => xu_mm_msr_pr_q );

            
event_data_latch: tri_rlmreg_p
  generic map (width => event_data_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rp_mm_event_bus_enable_int_q,
            thold_b => pc_func_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => forcee,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(event_data_offset to event_data_offset + event_data_q'length-1),
            scout   => sov(event_data_offset to event_data_offset + event_data_q'length-1),
            din     => event_data_d,
            dout    => event_data_q );

mm_perf_event_t0_latch : tri_regk
  generic map (width => mm_perf_event_t0_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rp_mm_event_bus_enable_int_q,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => mm_perf_event_t0_d,
            dout    => mm_perf_event_t0_q );

mm_perf_event_t1_latch : tri_regk
  generic map (width => mm_perf_event_t1_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rp_mm_event_bus_enable_int_q,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => mm_perf_event_t1_d,
            dout    => mm_perf_event_t1_q );

mm_perf_event_t2_latch : tri_regk
  generic map (width => mm_perf_event_t2_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rp_mm_event_bus_enable_int_q,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => mm_perf_event_t2_d,
            dout    => mm_perf_event_t2_q );

mm_perf_event_t3_latch : tri_regk
  generic map (width => mm_perf_event_t3_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rp_mm_event_bus_enable_int_q,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => mm_perf_event_t3_d,
            dout    => mm_perf_event_t3_q );



perv_2to1_reg: tri_plat
  generic map (width => 4, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_func_sl_thold_2,
            din(1)      => pc_func_slp_nsl_thold_2,
            din(2)      => pc_sg_2,
            din(3)      => pc_fce_2,
            q(0)        => pc_func_sl_thold_1,
            q(1)        => pc_func_slp_nsl_thold_1,
            q(2)        => pc_sg_1,
            q(3)        => pc_fce_1);

perv_1to0_reg: tri_plat
  generic map (width => 4, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_func_sl_thold_1,
            din(1)      => pc_func_slp_nsl_thold_1,
            din(2)      => pc_sg_1,
            din(3)      => pc_fce_1,
            q(0)        => pc_func_sl_thold_0,
            q(1)        => pc_func_slp_nsl_thold_0,
            q(2)        => pc_sg_0,
            q(3)        => pc_fce_0);

perv_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_sl_thold_0,
            sg          => pc_sg_0,
            act_dis     => lcb_act_dis_dc,
            forcee => forcee,
            thold_b     => pc_func_sl_thold_0_b);

perv_nsl_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_slp_nsl_thold_0,
            sg          => pc_fce_0,
            act_dis     => tidn,
            forcee => pc_func_slp_nsl_force,
            thold_b     => pc_func_slp_nsl_thold_0_b);

siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);


end mmq_perf;

