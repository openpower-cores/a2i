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
library ibm;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity mmq_tlb_cmp is
  generic(thdid_width       : integer := 4;
            ttype_width        : integer := 4;
            state_width        : integer := 3;
            pid_width          : integer := 14;
            pid_width_erat     : integer := 8;
            lpid_width         : integer := 8;
            class_width        : integer := 2;
            extclass_width     : integer := 2;
            tlbsel_width       : integer := 2;
            epn_width          : integer := 52;
            vpn_width          : integer := 61;
            erat_cam_data_width       : integer := 75;
            erat_ary_data_width       : integer := 73;
            erat_rel_data_width       : integer := 132;
            ws_width           : integer := 2;
            rs_is_width        : integer := 9;
            ra_entry_width     : integer := 12;
            rs_data_width      : integer := 64;
            data_out_width     : integer := 64;
            error_width        : integer := 3;
            tlb_num_entry          : natural := 512; 
            tlb_num_entry_log2     : natural := 9; 
            tlb_ways               : natural := 4;
            tlb_addr_width         : natural := 7;
            tlb_way_width     : natural := 168;
            tlb_word_width    : natural := 84;
            tlb_seq_width      : integer := 6;
            inv_seq_width      : integer := 5;
            por_seq_width      : integer := 3;
            watermark_width    : integer := 4;
            eptr_width         : integer := 4;
            lru_width          : integer := 16;
            mmucr0_width       : integer := 20;
            mmucr1_width       : integer := 32;
            mmucr2_width       : integer := 32;
            mmucr3_width       : integer := 15;
            spr_ctl_width      : integer := 3;
            spr_etid_width     : integer := 2;
            spr_addr_width     : integer := 10;
            spr_data_width     : integer := 64;
            debug_trace_width  : integer := 88;
            debug_event_width  : integer := 16;
            real_addr_width    : integer := 42;
            rpn_width          : integer := 30;  
            pte_width          : integer := 64;  
            check_parity       : integer := 1;
            tlb_tag_width      : natural := 110;
      mmq_tlb_cmp_cswitch_0to7  : integer := 0; 
          expand_type           : integer := 2 );   
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;

tc_ccflush_dc             : in std_ulogic;
tc_scan_dis_dc_b          : in std_ulogic;
tc_scan_diag_dc           : in std_ulogic;
tc_lbist_en_dc            : in std_ulogic;
lcb_d_mode_dc              : in std_ulogic;
lcb_clkoff_dc_b            : in std_ulogic;
lcb_act_dis_dc             : in std_ulogic;
lcb_mpw1_dc_b              : in std_ulogic_vector(0 to 4);
lcb_mpw2_dc_b              : in std_ulogic;
lcb_delay_lclkr_dc         : in std_ulogic_vector(0 to 4);
ac_func_scan_in          :in     std_ulogic_vector(0 to 2);
ac_func_scan_out         :out    std_ulogic_vector(0 to 2);
pc_sg_2                : in     std_ulogic;
pc_func_sl_thold_2     : in     std_ulogic;
pc_func_slp_sl_thold_2 : in     std_ulogic;
pc_func_slp_nsl_thold_2  : in   std_ulogic;
pc_fce_2               : in     std_ulogic;
xu_mm_ccr2_notlb_b     : in     std_ulogic;
xu_mm_spr_epcr_dmiuh   : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_epcr_dgtmi       : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_msr_gs           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_msr_pr           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_xucr4_mmu_mchk_q : in std_ulogic;
lpidr           : in std_ulogic_vector(0 to lpid_width-1);
mmucr1          : in std_ulogic_vector(10 to 18);
mmucr3_0        : in std_ulogic_vector(64-mmucr3_width to 63);
mmucr3_1        : in std_ulogic_vector(64-mmucr3_width to 63);
mmucr3_2        : in std_ulogic_vector(64-mmucr3_width to 63);
mmucr3_3        : in std_ulogic_vector(64-mmucr3_width to 63);
mm_iu_ierat_rel_val        : out std_ulogic_vector(0 to 4);
mm_iu_ierat_rel_data       : out std_ulogic_vector(0 to erat_rel_data_width-1);
mm_xu_derat_rel_val        : out std_ulogic_vector(0 to 4);
mm_xu_derat_rel_data       : out std_ulogic_vector(0 to erat_rel_data_width-1);
tlb_cmp_ierat_dup_val  : out std_ulogic_vector(0 to 6);
tlb_cmp_derat_dup_val  : out std_ulogic_vector(0 to 6);
tlb_cmp_erat_dup_wait  : out std_ulogic_vector(0 to 1);
ierat_req0_pid    : in std_ulogic_vector(0 to pid_width-1);
ierat_req0_as     : in std_ulogic;
ierat_req0_gs     : in std_ulogic;
ierat_req0_epn    : in std_ulogic_vector(0 to epn_width-1);
ierat_req0_thdid    : in std_ulogic_vector(0 to thdid_width-1);
ierat_req0_valid    : in std_ulogic;
ierat_req0_nonspec    : in std_ulogic;
ierat_req1_pid    : in std_ulogic_vector(0 to pid_width-1);
ierat_req1_as     : in std_ulogic;
ierat_req1_gs     : in std_ulogic;
ierat_req1_epn    : in std_ulogic_vector(0 to epn_width-1);
ierat_req1_thdid    : in std_ulogic_vector(0 to thdid_width-1);
ierat_req1_valid    : in std_ulogic;
ierat_req1_nonspec    : in std_ulogic;
ierat_req2_pid    : in std_ulogic_vector(0 to pid_width-1);
ierat_req2_as     : in std_ulogic;
ierat_req2_gs     : in std_ulogic;
ierat_req2_epn    : in std_ulogic_vector(0 to epn_width-1);
ierat_req2_thdid    : in std_ulogic_vector(0 to thdid_width-1);
ierat_req2_valid    : in std_ulogic;
ierat_req2_nonspec    : in std_ulogic;
ierat_req3_pid    : in std_ulogic_vector(0 to pid_width-1);
ierat_req3_as     : in std_ulogic;
ierat_req3_gs     : in std_ulogic;
ierat_req3_epn    : in std_ulogic_vector(0 to epn_width-1);
ierat_req3_thdid    : in std_ulogic_vector(0 to thdid_width-1);
ierat_req3_valid    : in std_ulogic;
ierat_req3_nonspec    : in std_ulogic;
ierat_iu4_pid    : in  std_ulogic_vector(0 to pid_width-1);
ierat_iu4_gs     : in  std_ulogic;
ierat_iu4_as     : in  std_ulogic;
ierat_iu4_epn    : in  std_ulogic_vector(0 to epn_width-1);
ierat_iu4_thdid  : in  std_ulogic_vector(0 to thdid_width-1);
ierat_iu4_valid  : in  std_ulogic;
derat_req0_lpid   : in std_ulogic_vector(0 to lpid_width-1);
derat_req0_pid    : in std_ulogic_vector(0 to pid_width-1);
derat_req0_as     : in std_ulogic;
derat_req0_gs     : in std_ulogic;
derat_req0_epn    : in std_ulogic_vector(0 to epn_width-1);
derat_req0_thdid    : in std_ulogic_vector(0 to thdid_width-1);
derat_req0_valid    : in std_ulogic;
derat_req1_lpid   : in std_ulogic_vector(0 to lpid_width-1);
derat_req1_pid    : in std_ulogic_vector(0 to pid_width-1);
derat_req1_as     : in std_ulogic;
derat_req1_gs     : in std_ulogic;
derat_req1_epn    : in std_ulogic_vector(0 to epn_width-1);
derat_req1_thdid    : in std_ulogic_vector(0 to thdid_width-1);
derat_req1_valid    : in std_ulogic;
derat_req2_lpid   : in std_ulogic_vector(0 to lpid_width-1);
derat_req2_pid    : in std_ulogic_vector(0 to pid_width-1);
derat_req2_as     : in std_ulogic;
derat_req2_gs     : in std_ulogic;
derat_req2_epn    : in std_ulogic_vector(0 to epn_width-1);
derat_req2_thdid    : in std_ulogic_vector(0 to thdid_width-1);
derat_req2_valid    : in std_ulogic;
derat_req3_lpid   : in std_ulogic_vector(0 to lpid_width-1);
derat_req3_pid    : in std_ulogic_vector(0 to pid_width-1);
derat_req3_as     : in std_ulogic;
derat_req3_gs     : in std_ulogic;
derat_req3_epn    : in std_ulogic_vector(0 to epn_width-1);
derat_req3_thdid    : in std_ulogic_vector(0 to thdid_width-1);
derat_req3_valid    : in std_ulogic;
derat_ex5_lpid   : in  std_ulogic_vector(0 to lpid_width-1);
derat_ex5_pid    : in  std_ulogic_vector(0 to pid_width-1);
derat_ex5_gs     : in  std_ulogic;
derat_ex5_as     : in  std_ulogic;
derat_ex5_epn    : in  std_ulogic_vector(0 to epn_width-1);
derat_ex5_thdid  : in  std_ulogic_vector(0 to thdid_width-1);
derat_ex5_valid  : in  std_ulogic;
tlb_tag2        : in std_ulogic_vector(0 to tlb_tag_width-1);
tlb_addr2       : in std_ulogic_vector(0 to tlb_addr_width-1);
ex6_illeg_instr : in std_ulogic_vector(0 to 1);
ierat_req_taken       : in std_ulogic;
derat_req_taken       : in std_ulogic;
ptereload_req_taken   : in std_ulogic;
tlb_tag0_type         : in std_ulogic_vector(0 to 1);
lrat_tag3_lpn              : in std_ulogic_vector(64-real_addr_width to 51);
lrat_tag3_rpn              : in std_ulogic_vector(64-real_addr_width to 51);
lrat_tag3_hit_status       : in std_ulogic_vector(0 to 3);
lrat_tag3_hit_entry        : in std_ulogic_vector(0 to 2);
lrat_tag4_lpn              : in std_ulogic_vector(64-real_addr_width to 51);
lrat_tag4_rpn              : in std_ulogic_vector(64-real_addr_width to 51);
lrat_tag4_hit_status       : in std_ulogic_vector(0 to 3);
lrat_tag4_hit_entry        : in std_ulogic_vector(0 to 2);
lru_dataout             : in std_ulogic_vector(0 to 15);
tlb_dataout             : in std_ulogic_vector(0 to tlb_way_width*tlb_ways-1);
tlb_dataina              : out std_ulogic_vector(0 to tlb_way_width-1);
tlb_datainb              : out std_ulogic_vector(0 to tlb_way_width-1);
lru_wr_addr             : out std_ulogic_vector(0 to tlb_addr_width-1);
lru_write               : out std_ulogic_vector(0 to 15);
lru_datain              : out std_ulogic_vector(0 to 15);
lru_tag4_dataout   : out std_ulogic_vector(0 to 15);
tlb_tag4_esel      : out std_ulogic_vector(0 to 2);
tlb_tag4_wq        : out std_ulogic_vector(0 to 1);
tlb_tag4_is        : out std_ulogic_vector(0 to 1);
tlb_tag4_gs        : out std_ulogic;
tlb_tag4_pr        : out std_ulogic;
tlb_tag4_hes       : out std_ulogic;
tlb_tag4_atsel     : out std_ulogic;
tlb_tag4_pt        : out std_ulogic;
tlb_tag4_cmp_hit   : out std_ulogic;
tlb_tag4_way_ind   : out std_ulogic;
tlb_tag4_ptereload : out std_ulogic;
tlb_tag4_endflag   : out std_ulogic;
tlb_tag4_parerr    : out std_ulogic;
tlb_tag5_except    : out std_ulogic_vector(0 to thdid_width-1);
mmucfg_twc         : in std_ulogic;
mmucfg_lrat        : in std_ulogic;
tlb0cfg_pt         : in std_ulogic;
tlb0cfg_gtwe       : in std_ulogic;
tlb0cfg_ind        : in std_ulogic;
mas2_0_wimge           : in std_ulogic_vector(0 to 4);
mas3_0_rpnl            : in std_ulogic_vector(32 to 52);
mas3_0_ubits           : in std_ulogic_vector(0 to 3);
mas3_0_usxwr           : in std_ulogic_vector(0 to 5);
mas7_0_rpnu            : in std_ulogic_vector(22 to 31);
mas8_0_vf              : in std_ulogic;
mas2_1_wimge           : in std_ulogic_vector(0 to 4);
mas3_1_rpnl            : in std_ulogic_vector(32 to 52);
mas3_1_ubits           : in std_ulogic_vector(0 to 3);
mas3_1_usxwr           : in std_ulogic_vector(0 to 5);
mas7_1_rpnu            : in std_ulogic_vector(22 to 31);
mas8_1_vf              : in std_ulogic;
mas2_2_wimge           : in std_ulogic_vector(0 to 4);
mas3_2_rpnl            : in std_ulogic_vector(32 to 52);
mas3_2_ubits           : in std_ulogic_vector(0 to 3);
mas3_2_usxwr           : in std_ulogic_vector(0 to 5);
mas7_2_rpnu            : in std_ulogic_vector(22 to 31);
mas8_2_vf              : in std_ulogic;
mas2_3_wimge           : in std_ulogic_vector(0 to 4);
mas3_3_rpnl            : in std_ulogic_vector(32 to 52);
mas3_3_ubits           : in std_ulogic_vector(0 to 3);
mas3_3_usxwr           : in std_ulogic_vector(0 to 5);
mas7_3_rpnu            : in std_ulogic_vector(22 to 31);
mas8_3_vf              : in std_ulogic;
tlb_mas0_esel          : out std_ulogic_vector(0 to 2);
tlb_mas1_v             : out std_ulogic;
tlb_mas1_iprot         : out std_ulogic;
tlb_mas1_tid           : out std_ulogic_vector(0 to pid_width-1);
tlb_mas1_tid_error     : out std_ulogic_vector(0 to pid_width-1);
tlb_mas1_ind           : out std_ulogic;
tlb_mas1_ts            : out std_ulogic;
tlb_mas1_ts_error      : out std_ulogic;
tlb_mas1_tsize         : out std_ulogic_vector(0 to 3);
tlb_mas2_epn           : out std_ulogic_vector(0 to epn_width-1);
tlb_mas2_epn_error     : out std_ulogic_vector(0 to epn_width-1);
tlb_mas2_wimge         : out std_ulogic_vector(0 to 4);
tlb_mas3_rpnl          : out std_ulogic_vector(32 to 51);
tlb_mas3_ubits         : out std_ulogic_vector(0 to 3);
tlb_mas3_usxwr         : out std_ulogic_vector(0 to 5);
tlb_mas6_spid          : out std_ulogic_vector(0 to pid_width-1);
tlb_mas6_isize         : out std_ulogic_vector(0 to 3);
tlb_mas6_sind          : out std_ulogic;
tlb_mas6_sas           : out std_ulogic;
tlb_mas7_rpnu          : out std_ulogic_vector(22 to 31);
tlb_mas8_tgs           : out std_ulogic;
tlb_mas8_vf            : out std_ulogic;
tlb_mas8_tlpid         : out std_ulogic_vector(0 to 7);
tlb_mmucr1_een         : out std_ulogic_vector(0 to 8);
tlb_mmucr1_we          : out std_ulogic;
tlb_mmucr3_thdid       : out std_ulogic_vector(0 to thdid_width-1);
tlb_mmucr3_resvattr    : out std_ulogic;
tlb_mmucr3_wlc         : out std_ulogic_vector(0 to 1);
tlb_mmucr3_class       : out std_ulogic_vector(0 to class_width-1);
tlb_mmucr3_extclass    : out std_ulogic_vector(0 to extclass_width-1);
tlb_mmucr3_rc          : out std_ulogic_vector(0 to 1);
tlb_mmucr3_x           : out std_ulogic;
tlb_mas_tlbre          : out std_ulogic;
tlb_mas_tlbsx_hit      : out std_ulogic;
tlb_mas_tlbsx_miss     : out std_ulogic;
tlb_mas_dtlb_error     : out std_ulogic;
tlb_mas_itlb_error     : out std_ulogic;
tlb_mas_thdid          : out std_ulogic_vector(0 to thdid_width-1);
tlb_htw_req_valid : out std_ulogic;
tlb_htw_req_tag   : out std_ulogic_vector(0 to tlb_tag_width-1);
tlb_htw_req_way   : out std_ulogic_vector(tlb_word_width to tlb_way_width-1);
tlbwe_back_inv_valid     : out     std_ulogic;
tlbwe_back_inv_thdid     : out     std_ulogic_vector(0 to thdid_width-1);
tlbwe_back_inv_addr      : out     std_ulogic_vector(52-epn_width to 51);
tlbwe_back_inv_attr      : out     std_ulogic_vector(0 to 34);
ptereload_req_pte_lat      : in std_ulogic_vector(0 to pte_width-1);
tlb_ctl_tag2_flush            : in std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_tag3_flush            : in std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_tag4_flush            : in std_ulogic_vector(0 to thdid_width-1);
tlb_resv_match_vec            : in std_ulogic_vector(0 to thdid_width-1);
mm_xu_eratmiss_done     : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_miss          : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_inelig        : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_lrat_miss         : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_pt_fault          : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_hv_priv           : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_esr_pt           : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_esr_data         : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_esr_epid         : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_esr_st           : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_cr0_eq            : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_cr0_eq_valid      : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_multihit_err        : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_par_err             : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_lru_par_err             : out std_ulogic_vector(0 to thdid_width-1);
tlb_delayed_act  : in std_ulogic_vector(9 to 16);
tlb_cmp_perf_event_t0           : out std_ulogic_vector(0 to 9);
tlb_cmp_perf_event_t1           : out std_ulogic_vector(0 to 9);
tlb_cmp_perf_event_t2           : out std_ulogic_vector(0 to 9);
tlb_cmp_perf_event_t3           : out std_ulogic_vector(0 to 9);
tlb_cmp_perf_state              : out std_ulogic_vector(0 to 1);
tlb_cmp_perf_miss_direct       : out std_ulogic;
tlb_cmp_perf_hit_indirect      : out std_ulogic;
tlb_cmp_perf_hit_first_page    : out std_ulogic;
tlb_cmp_perf_ptereload_noexcep : out std_ulogic;
tlb_cmp_perf_lrat_request      : out std_ulogic;
tlb_cmp_perf_lrat_miss         : out std_ulogic;
tlb_cmp_perf_pt_fault          : out std_ulogic;
tlb_cmp_perf_pt_inelig         : out std_ulogic;
tlb_cmp_dbg_tag4                   : out  std_ulogic_vector(0 to tlb_tag_width-1);
tlb_cmp_dbg_tag4_wayhit            : out  std_ulogic_vector(0 to tlb_ways);
tlb_cmp_dbg_addr4                  : out  std_ulogic_vector(0 to tlb_addr_width-1);
tlb_cmp_dbg_tag4_way               : out  std_ulogic_vector(0 to tlb_way_width-1);
tlb_cmp_dbg_tag4_parerr            : out  std_ulogic_vector(0 to 4);
tlb_cmp_dbg_tag4_lru_dataout_q     : out std_ulogic_vector(0 to 11);
tlb_cmp_dbg_tag5_tlb_datain_q      : out  std_ulogic_vector(0 to tlb_way_width-1);
tlb_cmp_dbg_tag5_lru_datain_q      : out std_ulogic_vector(0 to 11);
tlb_cmp_dbg_tag5_lru_write         : out std_ulogic;
tlb_cmp_dbg_tag5_any_exception     : out std_ulogic;
tlb_cmp_dbg_tag5_except_type_q     : out std_ulogic_vector(0 to 3);
tlb_cmp_dbg_tag5_except_thdid_q    : out std_ulogic_vector(0 to 1);
tlb_cmp_dbg_tag5_erat_rel_val      : out  std_ulogic_vector(0 to 9);
tlb_cmp_dbg_tag5_erat_rel_data     : out  std_ulogic_vector(0 to 131);
tlb_cmp_dbg_erat_dup_q             : out  std_ulogic_vector(0 to 19);
tlb_cmp_dbg_addr_enable            : out  std_ulogic_vector(0 to 8);
tlb_cmp_dbg_pgsize_enable          : out  std_ulogic;
tlb_cmp_dbg_class_enable           : out  std_ulogic;
tlb_cmp_dbg_extclass_enable        : out  std_ulogic_vector(0 to 1);
tlb_cmp_dbg_state_enable           : out  std_ulogic_vector(0 to 1);
tlb_cmp_dbg_thdid_enable           : out  std_ulogic;
tlb_cmp_dbg_pid_enable             : out  std_ulogic;
tlb_cmp_dbg_lpid_enable            : out  std_ulogic;
tlb_cmp_dbg_ind_enable             : out  std_ulogic;
tlb_cmp_dbg_iprot_enable           : out  std_ulogic;
tlb_cmp_dbg_way0_entry_v                        : out  std_ulogic;
tlb_cmp_dbg_way0_addr_match                     : out  std_ulogic;
tlb_cmp_dbg_way0_pgsize_match                   : out  std_ulogic;
tlb_cmp_dbg_way0_class_match                    : out  std_ulogic;
tlb_cmp_dbg_way0_extclass_match                 : out  std_ulogic;
tlb_cmp_dbg_way0_state_match                    : out  std_ulogic;
tlb_cmp_dbg_way0_thdid_match                    : out  std_ulogic;
tlb_cmp_dbg_way0_pid_match                      : out  std_ulogic;
tlb_cmp_dbg_way0_lpid_match                     : out  std_ulogic;
tlb_cmp_dbg_way0_ind_match                      : out  std_ulogic;
tlb_cmp_dbg_way0_iprot_match                    : out  std_ulogic;
tlb_cmp_dbg_way1_entry_v                        : out  std_ulogic;
tlb_cmp_dbg_way1_addr_match                     : out  std_ulogic;
tlb_cmp_dbg_way1_pgsize_match                   : out  std_ulogic;
tlb_cmp_dbg_way1_class_match                    : out  std_ulogic;
tlb_cmp_dbg_way1_extclass_match                 : out  std_ulogic;
tlb_cmp_dbg_way1_state_match                    : out  std_ulogic;
tlb_cmp_dbg_way1_thdid_match                    : out  std_ulogic;
tlb_cmp_dbg_way1_pid_match                      : out  std_ulogic;
tlb_cmp_dbg_way1_lpid_match                     : out  std_ulogic;
tlb_cmp_dbg_way1_ind_match                      : out  std_ulogic;
tlb_cmp_dbg_way1_iprot_match                    : out  std_ulogic;
tlb_cmp_dbg_way2_entry_v                        : out  std_ulogic;
tlb_cmp_dbg_way2_addr_match                     : out  std_ulogic;
tlb_cmp_dbg_way2_pgsize_match                   : out  std_ulogic;
tlb_cmp_dbg_way2_class_match                    : out  std_ulogic;
tlb_cmp_dbg_way2_extclass_match                 : out  std_ulogic;
tlb_cmp_dbg_way2_state_match                    : out  std_ulogic;
tlb_cmp_dbg_way2_thdid_match                    : out  std_ulogic;
tlb_cmp_dbg_way2_pid_match                      : out  std_ulogic;
tlb_cmp_dbg_way2_lpid_match                     : out  std_ulogic;
tlb_cmp_dbg_way2_ind_match                      : out  std_ulogic;
tlb_cmp_dbg_way2_iprot_match                    : out  std_ulogic;
tlb_cmp_dbg_way3_entry_v                        : out  std_ulogic;
tlb_cmp_dbg_way3_addr_match                     : out  std_ulogic;
tlb_cmp_dbg_way3_pgsize_match                   : out  std_ulogic;
tlb_cmp_dbg_way3_class_match                    : out  std_ulogic;
tlb_cmp_dbg_way3_extclass_match                 : out  std_ulogic;
tlb_cmp_dbg_way3_state_match                    : out  std_ulogic;
tlb_cmp_dbg_way3_thdid_match                    : out  std_ulogic;
tlb_cmp_dbg_way3_pid_match                      : out  std_ulogic;
tlb_cmp_dbg_way3_lpid_match                     : out  std_ulogic;
tlb_cmp_dbg_way3_ind_match                      : out  std_ulogic;
tlb_cmp_dbg_way3_iprot_match                    : out  std_ulogic     
);
end mmq_tlb_cmp;
ARCHITECTURE MMQ_TLB_CMP
          OF MMQ_TLB_CMP
          IS
SIGNAL LRU_UPDATE_DATA_PT                : STD_ULOGIC_VECTOR(1 TO 175)  := 
(OTHERS=> 'U');
component mmq_tlb_matchline
  generic (  have_xbit : integer := 1;
             num_pgsizes : integer := 5;
             have_cmpmask : integer := 1;
             cmpmask_width : integer := 5);
port(
    vdd                              : inout power_logic;
    gnd                              : inout power_logic;
    addr_in                          : in std_ulogic_vector(0 to 51);
    addr_enable                      : in std_ulogic_vector(0 to 8);
    comp_pgsize                      : in std_ulogic_vector(0 to 3);
    pgsize_enable                    : in std_ulogic;
    entry_size                       : in std_ulogic_vector(0 to 3);
    entry_cmpmask                    : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_xbit                       : in std_ulogic;
    entry_xbitmask                   : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_epn                        : in std_ulogic_vector(0 to 51);
    comp_class                       : in std_ulogic_vector(0 to 1);
    entry_class                      : in std_ulogic_vector(0 to 1);
    class_enable                     : in std_ulogic;
    comp_extclass                    : in std_ulogic_vector(0 to 1);
    entry_extclass                   : in std_ulogic_vector(0 to 1);
    extclass_enable                  : in std_ulogic_vector(0 to 1);
    comp_state                       : in std_ulogic_vector(0 to 1);
    entry_gs                         : in std_ulogic;
    entry_ts                         : in std_ulogic;
    state_enable                     : in std_ulogic_vector(0 to 1);
    entry_thdid                      : in std_ulogic_vector(0 to 3);
    comp_thdid                       : in std_ulogic_vector(0 to 3);
    thdid_enable                     : in std_ulogic;
    entry_pid                        : in std_ulogic_vector(0 to 13);
    comp_pid                         : in std_ulogic_vector(0 to 13);
    pid_enable                       : in std_ulogic;
    entry_lpid                       : in std_ulogic_vector(0 to 7);
    comp_lpid                        : in std_ulogic_vector(0 to 7);
    lpid_enable                      : in std_ulogic;
    entry_ind                        : in std_ulogic;
    comp_ind                         : in std_ulogic;
    ind_enable                       : in std_ulogic;
    entry_iprot                      : in std_ulogic;
    comp_iprot                       : in std_ulogic;
    iprot_enable                     : in std_ulogic;
    entry_v                          : in std_ulogic;
    comp_invalidate                  : in std_ulogic;

    match                            : out std_ulogic;
    dbg_addr_match       : out  std_ulogic;
    dbg_pgsize_match     : out  std_ulogic;
    dbg_class_match      : out  std_ulogic;
    dbg_extclass_match   : out  std_ulogic;
    dbg_state_match      : out  std_ulogic;
    dbg_thdid_match      : out  std_ulogic;
    dbg_pid_match        : out  std_ulogic;
    dbg_lpid_match       : out  std_ulogic;
    dbg_ind_match        : out  std_ulogic;
    dbg_iprot_match      : out  std_ulogic
);
end component;
constant MMU_Mode_Value : std_ulogic := '0';
constant TlbSel_Tlb : std_ulogic_vector(0 to 1) := "00";
constant TlbSel_IErat : std_ulogic_vector(0 to 1) := "10";
constant TlbSel_DErat : std_ulogic_vector(0 to 1) := "11";
constant ERAT_PgSize_1GB   : std_ulogic_vector(0 to 2) := "110";
constant ERAT_PgSize_16MB  : std_ulogic_vector(0 to 2) := "111";
constant ERAT_PgSize_1MB   : std_ulogic_vector(0 to 2) := "101";
constant ERAT_PgSize_64KB  : std_ulogic_vector(0 to 2) := "011";
constant ERAT_PgSize_4KB   : std_ulogic_vector(0 to 2) := "001";
constant TLB_PgSize_1GB   : std_ulogic_vector(0 to 3) := "1010";
constant TLB_PgSize_16MB  : std_ulogic_vector(0 to 3) := "0111";
constant TLB_PgSize_1MB   : std_ulogic_vector(0 to 3) := "0101";
constant TLB_PgSize_64KB  : std_ulogic_vector(0 to 3) := "0011";
constant TLB_PgSize_4KB   : std_ulogic_vector(0 to 3) := "0001";
constant ERAT_PgSize_256MB : std_ulogic_vector(0 to 2) := "100";
constant TLB_PgSize_256MB : std_ulogic_vector(0 to 3) := "1001";
constant tlb_way0_offset              : natural := 0;
constant tlb_way1_offset              : natural := tlb_way0_offset + tlb_way_width;
constant tlb_way0_cmpmask_offset      : natural := tlb_way1_offset + tlb_way_width;
constant tlb_way1_cmpmask_offset      : natural := tlb_way0_cmpmask_offset + 5;
constant tlb_way0_xbitmask_offset     : natural := tlb_way1_cmpmask_offset + 5;
constant tlb_way1_xbitmask_offset     : natural := tlb_way0_xbitmask_offset + 5;
constant tlb_tag3_cmpmask_offset      : natural := tlb_way1_xbitmask_offset + 5;
constant tlb_tag3_clone1_offset       : natural := tlb_tag3_cmpmask_offset + 5;
constant tlb_tag4_way_offset          : natural := tlb_tag3_clone1_offset + tlb_tag_width;
constant tlb_tag4_way_rw_offset       : natural := tlb_tag4_way_offset + tlb_way_width;
constant tlb_dataina_offset           : natural := tlb_tag4_way_rw_offset + tlb_way_width;
constant tlb_erat_rel_offset          : natural := tlb_dataina_offset + tlb_way_width;
constant mmucr1_offset                : natural := tlb_erat_rel_offset + 132;
constant spare_a_offset               : natural := mmucr1_offset + 9;
constant scan_right_0                 : natural := spare_a_offset + 16 -1;
constant tlb_way2_offset                 : natural := 0;
constant tlb_way3_offset                 : natural := tlb_way2_offset + tlb_way_width;
constant tlb_way2_cmpmask_offset         : natural := tlb_way3_offset + tlb_way_width;
constant tlb_way3_cmpmask_offset         : natural := tlb_way2_cmpmask_offset + 5;
constant tlb_way2_xbitmask_offset        : natural := tlb_way3_cmpmask_offset + 5;
constant tlb_way3_xbitmask_offset        : natural := tlb_way2_xbitmask_offset + 5;
constant tlb_tag3_clone2_offset          : natural := tlb_way3_xbitmask_offset + 5;
constant tlb_tag3_cmpmask_clone_offset   : natural := tlb_tag3_clone2_offset + tlb_tag_width;
constant tlb_erat_rel_clone_offset       : natural := tlb_tag3_cmpmask_clone_offset + 5;
constant tlb_tag4_way_clone_offset       : natural := tlb_erat_rel_clone_offset + 132;
constant tlb_tag4_way_rw_clone_offset    : natural := tlb_tag4_way_clone_offset + tlb_way_width;
constant tlb_datainb_offset              : natural := tlb_tag4_way_rw_clone_offset + tlb_way_width;
constant mmucr1_clone_offset             : natural := tlb_datainb_offset + tlb_way_width;
constant spare_b_offset                  : natural := mmucr1_clone_offset + 9;
constant scan_right_1                    : natural := spare_b_offset + 16 -1;
constant tlb_tag3_offset                 : natural := 0;
constant tlb_addr3_offset                : natural := tlb_tag3_offset + tlb_tag_width;
constant lru_tag3_dataout_offset         : natural := tlb_addr3_offset + tlb_addr_width;
constant tlb_tag4_offset                 : natural := lru_tag3_dataout_offset + 16;
constant tlb_tag4_wayhit_offset          : natural := tlb_tag4_offset + tlb_tag_width;
constant tlb_addr4_offset                : natural := tlb_tag4_wayhit_offset + tlb_ways+1;
constant lru_tag4_dataout_offset         : natural := tlb_addr4_offset + tlb_addr_width;
constant tlbwe_tag4_back_inv_offset      : natural := lru_tag4_dataout_offset + 16;
constant tlbwe_tag4_back_inv_attr_offset : natural := tlbwe_tag4_back_inv_offset + thdid_width + 1;
constant tlb_erat_val_offset             : natural := tlbwe_tag4_back_inv_attr_offset + 2;
constant tlb_erat_dup_offset             : natural := tlb_erat_val_offset + 2*thdid_width+2;
constant lru_write_offset                : natural := tlb_erat_dup_offset + 2*thdid_width+12;
constant lru_wr_addr_offset              : natural := lru_write_offset + 16;
constant lru_datain_offset               : natural := lru_wr_addr_offset + tlb_addr_width;
constant eratmiss_done_offset            : natural := lru_datain_offset + 16;
constant tlb_miss_offset                 : natural := eratmiss_done_offset + thdid_width;
constant tlb_inelig_offset               : natural := tlb_miss_offset + thdid_width;
constant lrat_miss_offset                : natural := tlb_inelig_offset + thdid_width;
constant pt_fault_offset                 : natural := lrat_miss_offset + thdid_width;
constant hv_priv_offset                  : natural := pt_fault_offset + thdid_width;
constant tlb_tag5_except_offset          : natural := hv_priv_offset + thdid_width;
constant tlb_dsi_offset                  : natural := tlb_tag5_except_offset + thdid_width;
constant tlb_isi_offset                  : natural := tlb_dsi_offset + thdid_width;
constant esr_pt_offset                   : natural := tlb_isi_offset + thdid_width;
constant esr_data_offset                 : natural := esr_pt_offset + thdid_width;
constant esr_epid_offset                 : natural := esr_data_offset + thdid_width;
constant esr_st_offset                   : natural := esr_epid_offset + thdid_width;
constant cr0_eq_offset                   : natural := esr_st_offset + thdid_width;
constant cr0_eq_valid_offset             : natural := cr0_eq_offset + thdid_width;
constant tlb_multihit_err_offset         : natural := cr0_eq_valid_offset + thdid_width;
constant tag4_parerr_offset              : natural := tlb_multihit_err_offset + thdid_width;
constant tlb_par_err_offset              : natural := tag4_parerr_offset + 5;
constant lru_par_err_offset              : natural := tlb_par_err_offset + thdid_width;
constant cswitch_offset                  : natural := lru_par_err_offset + thdid_width;
constant spare_c_offset                  : natural := cswitch_offset + 8;
constant scan_right_2                    : natural := spare_c_offset + 16 - 1;
constant tagpos_epn      : natural  := 0;
constant tagpos_pid      : natural  := 52;
constant tagpos_is       : natural  := 66;
constant tagpos_class    : natural  := 68;
constant tagpos_state    : natural  := 70;
constant tagpos_thdid    : natural  := 74;
constant tagpos_size     : natural  := 78;
constant tagpos_type     : natural  := 82;
constant tagpos_lpid     : natural  := 90;
constant tagpos_ind      : natural  := 98;
constant tagpos_atsel    : natural  := 99;
constant tagpos_esel     : natural  := 100;
constant tagpos_hes      : natural  := 103;
constant tagpos_wq       : natural  := 104;
constant tagpos_lrat     : natural  := 106;
constant tagpos_pt       : natural  := 107;
constant tagpos_recform  : natural  := 108;
constant tagpos_endflag  : natural  := 109;
constant tagpos_type_derat     : natural  := tagpos_type;
constant tagpos_type_ierat     : natural  := tagpos_type+1;
constant tagpos_type_tlbsx     : natural  := tagpos_type+2;
constant tagpos_type_tlbsrx    : natural  := tagpos_type+3;
constant tagpos_type_snoop     : natural  := tagpos_type+4;
constant tagpos_type_tlbre     : natural  := tagpos_type+5;
constant tagpos_type_tlbwe     : natural  := tagpos_type+6;
constant tagpos_type_ptereload : natural  := tagpos_type+7;
constant tagpos_pr             : natural  := tagpos_state;
constant tagpos_gs             : natural  := tagpos_state+1;
constant tagpos_as             : natural  := tagpos_state+2;
constant tagpos_cm             : natural  := tagpos_state+3;
constant waypos_epn      : natural  := 0;
constant waypos_size     : natural  := 52;
constant waypos_thdid    : natural  := 56;
constant waypos_class    : natural  := 60;
constant waypos_extclass : natural  := 62;
constant waypos_lpid     : natural  := 66;
constant waypos_xbit     : natural  := 84;
constant waypos_rpn      : natural  := 88;
constant waypos_rc       : natural  := 118;
constant waypos_wlc      : natural  := 120;
constant waypos_resvattr : natural  := 122;
constant waypos_vf       : natural  := 123;
constant waypos_ind      : natural  := 124;
constant waypos_ubits    : natural  := 125;
constant waypos_wimge    : natural  := 129;
constant waypos_usxwr    : natural  := 134;
constant waypos_gs       : natural  := 140;
constant waypos_ts       : natural  := 141;
constant waypos_tid      : natural  := 144;
constant eratpos_epn      : natural  := 0;
constant eratpos_x        : natural  := 52;
constant eratpos_size     : natural  := 53;
constant eratpos_v        : natural  := 56;
constant eratpos_thdid    : natural  := 57;
constant eratpos_class    : natural  := 61;
constant eratpos_extclass : natural  := 63;
constant eratpos_wren     : natural  := 65;
constant eratpos_rpnrsvd  : natural  := 66;
constant eratpos_rpn      : natural  := 70;
constant eratpos_r        : natural  := 100;
constant eratpos_c        : natural  := 101;
constant eratpos_relsoon  : natural  := 102;
constant eratpos_wlc      : natural  := 103;
constant eratpos_resvattr : natural  := 105;
constant eratpos_vf       : natural  := 106;
constant eratpos_ubits    : natural  := 107;
constant eratpos_wimge    : natural  := 111;
constant eratpos_usxwr    : natural  := 116;
constant eratpos_gs       : natural  := 122;
constant eratpos_ts       : natural  := 123;
constant eratpos_tid      : natural  := 124;
constant ptepos_rpn      : natural  := 0;
constant ptepos_wimge    : natural  := 40;
constant ptepos_r        : natural  := 45;
constant ptepos_ubits    : natural  := 46;
constant ptepos_sw0      : natural  := 50;
constant ptepos_c        : natural  := 51;
constant ptepos_size     : natural  := 52;
constant ptepos_usxwr    : natural  := 56;
constant ptepos_sw1      : natural  := 62;
constant ptepos_valid    : natural  := 63;
constant pos_tlb_pei : natural := 10;
constant pos_lru_pei : natural := 11;
constant pos_ictid : natural := 12;
constant pos_ittid : natural := 13;
constant pos_dctid : natural := 14;
constant pos_dttid : natural := 15;
constant pos_dccd  : natural := 16;
constant pos_tlbwe_binv : natural := 17;
constant pos_tlbi_msb : natural := 18;
constant pos_tlbi_rej : natural := 19;
signal tlb_way0_d, tlb_way0_q    : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_way1_d, tlb_way1_q    : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_way2_d, tlb_way2_q    : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_way3_d, tlb_way3_q    : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_tag3_d, tlb_tag3_q  : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_tag3_clone1_d, tlb_tag3_clone1_q  : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_tag3_clone2_d, tlb_tag3_clone2_q  : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_addr3_d, tlb_addr3_q  : std_ulogic_vector(0 to tlb_addr_width-1);
signal lru_tag3_dataout_d, lru_tag3_dataout_q    : std_ulogic_vector(0 to 15);
signal tlb_tag3_cmpmask_d, tlb_tag3_cmpmask_q  : std_ulogic_vector(0 to 4);
signal tlb_tag3_cmpmask_clone_d, tlb_tag3_cmpmask_clone_q  : std_ulogic_vector(0 to 4);
signal tlb_way0_cmpmask_d, tlb_way0_cmpmask_q  : std_ulogic_vector(0 to 4);
signal tlb_way1_cmpmask_d, tlb_way1_cmpmask_q  : std_ulogic_vector(0 to 4);
signal tlb_way2_cmpmask_d, tlb_way2_cmpmask_q  : std_ulogic_vector(0 to 4);
signal tlb_way3_cmpmask_d, tlb_way3_cmpmask_q  : std_ulogic_vector(0 to 4);
signal tlb_way0_xbitmask_d, tlb_way0_xbitmask_q  : std_ulogic_vector(0 to 4);
signal tlb_way1_xbitmask_d, tlb_way1_xbitmask_q  : std_ulogic_vector(0 to 4);
signal tlb_way2_xbitmask_d, tlb_way2_xbitmask_q  : std_ulogic_vector(0 to 4);
signal tlb_way3_xbitmask_d, tlb_way3_xbitmask_q  : std_ulogic_vector(0 to 4);
signal tlb_tag4_d, tlb_tag4_q                    : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_tag4_wayhit_d, tlb_tag4_wayhit_q      : std_ulogic_vector(0 to tlb_ways);
signal tlb_addr4_d, tlb_addr4_q                  : std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_dataina_d, tlb_dataina_q          : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_datainb_d, tlb_datainb_q          : std_ulogic_vector(0 to tlb_way_width-1);
signal lru_tag4_dataout_d, lru_tag4_dataout_q    : std_ulogic_vector(0 to lru_width-1);
signal tlb_tag4_way_d, tlb_tag4_way_q            : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_tag4_way_clone_d, tlb_tag4_way_clone_q   : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_tag4_way_rw_d, tlb_tag4_way_rw_q      : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_tag4_way_rw_clone_d, tlb_tag4_way_rw_clone_q      : std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_tag4_way_rw_or      : std_ulogic_vector(0 to tlb_way_width-1);
signal tlbwe_tag4_back_inv_d, tlbwe_tag4_back_inv_q :  std_ulogic_vector(0 to thdid_width);
signal tlbwe_tag4_back_inv_attr_d, tlbwe_tag4_back_inv_attr_q :  std_ulogic_vector(18 to 19);
signal tlb_erat_val_d, tlb_erat_val_q     : std_ulogic_vector(0 to 2*thdid_width+1);
signal tlb_erat_rel_d, tlb_erat_rel_q     : std_ulogic_vector(0 to erat_rel_data_width-1);
signal tlb_erat_rel_clone_d, tlb_erat_rel_clone_q     : std_ulogic_vector(0 to erat_rel_data_width-1);
signal tlb_erat_dup_d, tlb_erat_dup_q     : std_ulogic_vector(0 to 2*thdid_width+11);
signal lru_write_d, lru_write_q           : std_ulogic_vector(0 to 15);
signal lru_wr_addr_d, lru_wr_addr_q       : std_ulogic_vector(0 to tlb_addr_width-1);
signal lru_datain_d, lru_datain_q         : std_ulogic_vector(0 to 15);
signal eratmiss_done_d, eratmiss_done_q  : std_ulogic_vector(0 to thdid_width-1);
signal tlb_miss_d, tlb_miss_q            : std_ulogic_vector(0 to thdid_width-1);
signal tlb_inelig_d, tlb_inelig_q        : std_ulogic_vector(0 to thdid_width-1);
signal lrat_miss_d, lrat_miss_q          : std_ulogic_vector(0 to thdid_width-1);
signal pt_fault_d, pt_fault_q            : std_ulogic_vector(0 to thdid_width-1);
signal hv_priv_d, hv_priv_q              : std_ulogic_vector(0 to thdid_width-1);
signal tlb_tag5_except_d, tlb_tag5_except_q            : std_ulogic_vector(0 to thdid_width-1);
signal tlb_dsi_d,  tlb_dsi_q             : std_ulogic_vector(0 to thdid_width-1);
signal tlb_isi_d,  tlb_isi_q             : std_ulogic_vector(0 to thdid_width-1);
signal esr_pt_d, esr_pt_q                : std_ulogic_vector(0 to thdid_width-1);
signal esr_data_d, esr_data_q            : std_ulogic_vector(0 to thdid_width-1);
signal esr_epid_d, esr_epid_q            : std_ulogic_vector(0 to thdid_width-1);
signal esr_st_d, esr_st_q                : std_ulogic_vector(0 to thdid_width-1);
signal tlb_multihit_err_d, tlb_multihit_err_q : std_ulogic_vector(0 to thdid_width-1);
signal tag4_parerr_d, tag4_parerr_q           : std_ulogic_vector(0 to 4);
signal tlb_par_err_d, tlb_par_err_q           : std_ulogic_vector(0 to thdid_width-1);
signal lru_par_err_d, lru_par_err_q           : std_ulogic_vector(0 to thdid_width-1);
signal cr0_eq_d, cr0_eq_q                : std_ulogic_vector(0 to thdid_width-1);
signal cr0_eq_valid_d, cr0_eq_valid_q    : std_ulogic_vector(0 to thdid_width-1);
signal mmucr1_q, mmucr1_clone_q          : std_ulogic_vector(10 to 18);
signal epcr_dmiuh_q    : std_ulogic_vector(0 to thdid_width-1);
signal msr_gs_q, msr_pr_q   : std_ulogic_vector(0 to thdid_width-1);
signal spare_a_q, spare_b_q, spare_c_q   : std_ulogic_vector(0 to 15);
signal spare_nsl_q, spare_nsl_clone_q : std_ulogic_vector(0 to 7);
signal cswitch_q : std_ulogic_vector(0 to 7);
signal pgsize_enable,class_enable,thdid_enable,pid_enable,lpid_enable,ind_enable,iprot_enable  : std_ulogic;
signal state_enable,extclass_enable : std_ulogic_vector(0 to 1);
signal addr_enable : std_ulogic_vector(0 to 8);
signal comp_iprot  : std_ulogic;
signal comp_extclass : std_ulogic_vector(0 to 1);
signal comp_ind  : std_ulogic;
signal pgsize_enable_clone,class_enable_clone,thdid_enable_clone,pid_enable_clone,lpid_enable_clone,ind_enable_clone,iprot_enable_clone  : std_ulogic;
signal state_enable_clone,extclass_enable_clone : std_ulogic_vector(0 to 1);
signal addr_enable_clone : std_ulogic_vector(0 to 8);
signal comp_iprot_clone  : std_ulogic;
signal comp_extclass_clone : std_ulogic_vector(0 to 1);
signal comp_ind_clone  : std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
signal tlbwe_tag3_back_inv_enab : std_ulogic;
signal tlb_tag4_way_or  :  std_ulogic_vector(0 to tlb_way_width-1);
signal tlb_tag4_way_act     : std_ulogic;
signal tlb_tag4_way_clone_act : std_ulogic;
signal tlb_tag4_way_rw_act     : std_ulogic;
signal tlb_tag4_way_rw_clone_act     : std_ulogic;
signal tlb_tag4_type_sig      : std_ulogic_vector(0 to 7);
signal tlb_tag4_esel_sig      : std_ulogic_vector(0 to 2);
signal tlb_tag4_hes_sig       : std_ulogic;
signal tlb_tag4_wq_sig        : std_ulogic_vector(0 to 1);
signal tlb_tag4_is_sig        : std_ulogic_vector(0 to 3);
signal lru_update_data        : std_ulogic_vector(0 to 2);
signal lru_update_data_enab, lru_update_clear_enab   : std_ulogic;
signal tlb_tag4_hes1_mas1_v     :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_tag4_hes0_mas1_v     :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_tag4_hes1_mas1_iprot :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_tag4_hes0_mas1_iprot :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_tag4_ptereload_v :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_tag4_ptereload_iprot :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_tag4_ptereload_sig :  std_ulogic;
signal tlb_tag4_erat_data_cap : std_ulogic;
signal tlb_wayhit   : std_ulogic_vector(0 to tlb_ways-1);
signal multihit     : std_ulogic;
signal erat_pgsize  : std_ulogic_vector(0 to 2);
signal tlb_tag4_size_not_supp  : std_ulogic;
signal tlb_tag4_hv_op  : std_ulogic;
signal tlb_tag4_epcr_dgtmi  : std_ulogic;
signal tlb_way0_addr_match         :  std_ulogic;
signal tlb_way0_pgsize_match       :  std_ulogic;
signal tlb_way0_class_match        :  std_ulogic;
signal tlb_way0_extclass_match     :  std_ulogic;
signal tlb_way0_state_match        :  std_ulogic;
signal tlb_way0_thdid_match        :  std_ulogic;
signal tlb_way0_pid_match          :  std_ulogic;
signal tlb_way0_lpid_match         :  std_ulogic;
signal tlb_way0_ind_match          :  std_ulogic;
signal tlb_way0_iprot_match        :  std_ulogic;
signal tlb_way1_addr_match         :  std_ulogic;
signal tlb_way1_pgsize_match       :  std_ulogic;
signal tlb_way1_class_match        :  std_ulogic;
signal tlb_way1_extclass_match     :  std_ulogic;
signal tlb_way1_state_match        :  std_ulogic;
signal tlb_way1_thdid_match        :  std_ulogic;
signal tlb_way1_pid_match          :  std_ulogic;
signal tlb_way1_lpid_match         :  std_ulogic;
signal tlb_way1_ind_match          :  std_ulogic;
signal tlb_way1_iprot_match        :  std_ulogic;
signal tlb_way2_addr_match         :  std_ulogic;
signal tlb_way2_pgsize_match       :  std_ulogic;
signal tlb_way2_class_match        :  std_ulogic;
signal tlb_way2_extclass_match     :  std_ulogic;
signal tlb_way2_state_match        :  std_ulogic;
signal tlb_way2_thdid_match        :  std_ulogic;
signal tlb_way2_pid_match          :  std_ulogic;
signal tlb_way2_lpid_match         :  std_ulogic;
signal tlb_way2_ind_match          :  std_ulogic;
signal tlb_way2_iprot_match        :  std_ulogic;
signal tlb_way3_addr_match         :  std_ulogic;
signal tlb_way3_pgsize_match       :  std_ulogic;
signal tlb_way3_class_match        :  std_ulogic;
signal tlb_way3_extclass_match     :  std_ulogic;
signal tlb_way3_state_match        :  std_ulogic;
signal tlb_way3_thdid_match        :  std_ulogic;
signal tlb_way3_pid_match          :  std_ulogic;
signal tlb_way3_lpid_match         :  std_ulogic;
signal tlb_way3_ind_match          :  std_ulogic;
signal tlb_way3_iprot_match        :  std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
signal ierat_req0_tag4_pid_match     : std_ulogic;
signal ierat_req0_tag4_as_match      : std_ulogic;
signal ierat_req0_tag4_gs_match      : std_ulogic;
signal ierat_req0_tag4_epn_match     : std_ulogic;
signal ierat_req0_tag4_thdid_match   : std_ulogic;
signal ierat_req1_tag4_pid_match     : std_ulogic;
signal ierat_req1_tag4_as_match      : std_ulogic;
signal ierat_req1_tag4_gs_match      : std_ulogic;
signal ierat_req1_tag4_epn_match     : std_ulogic;
signal ierat_req1_tag4_thdid_match   : std_ulogic;
signal ierat_req2_tag4_pid_match     : std_ulogic;
signal ierat_req2_tag4_as_match      : std_ulogic;
signal ierat_req2_tag4_gs_match      : std_ulogic;
signal ierat_req2_tag4_epn_match     : std_ulogic;
signal ierat_req2_tag4_thdid_match   : std_ulogic;
signal ierat_req3_tag4_pid_match     : std_ulogic;
signal ierat_req3_tag4_as_match      : std_ulogic;
signal ierat_req3_tag4_gs_match      : std_ulogic;
signal ierat_req3_tag4_epn_match     : std_ulogic;
signal ierat_req3_tag4_thdid_match   : std_ulogic;
signal ierat_iu4_tag4_lpid_match  : std_ulogic;
signal ierat_iu4_tag4_pid_match   : std_ulogic;
signal ierat_iu4_tag4_as_match    : std_ulogic;
signal ierat_iu4_tag4_gs_match    : std_ulogic;
signal ierat_iu4_tag4_epn_match   : std_ulogic;
signal ierat_iu4_tag4_thdid_match : std_ulogic;
signal derat_req0_tag4_lpid_match    : std_ulogic;
signal derat_req0_tag4_pid_match     : std_ulogic;
signal derat_req0_tag4_as_match      : std_ulogic;
signal derat_req0_tag4_gs_match      : std_ulogic;
signal derat_req0_tag4_epn_match     : std_ulogic;
signal derat_req0_tag4_thdid_match   : std_ulogic;
signal derat_req1_tag4_lpid_match    : std_ulogic;
signal derat_req1_tag4_pid_match     : std_ulogic;
signal derat_req1_tag4_as_match      : std_ulogic;
signal derat_req1_tag4_gs_match      : std_ulogic;
signal derat_req1_tag4_epn_match     : std_ulogic;
signal derat_req1_tag4_thdid_match   : std_ulogic;
signal derat_req2_tag4_lpid_match    : std_ulogic;
signal derat_req2_tag4_pid_match     : std_ulogic;
signal derat_req2_tag4_as_match      : std_ulogic;
signal derat_req2_tag4_gs_match      : std_ulogic;
signal derat_req2_tag4_epn_match     : std_ulogic;
signal derat_req2_tag4_thdid_match   : std_ulogic;
signal derat_req3_tag4_lpid_match    : std_ulogic;
signal derat_req3_tag4_pid_match     : std_ulogic;
signal derat_req3_tag4_as_match      : std_ulogic;
signal derat_req3_tag4_gs_match      : std_ulogic;
signal derat_req3_tag4_epn_match     : std_ulogic;
signal derat_req3_tag4_thdid_match   : std_ulogic;
signal derat_ex5_tag4_lpid_match  : std_ulogic;
signal derat_ex5_tag4_pid_match   : std_ulogic;
signal derat_ex5_tag4_as_match    : std_ulogic;
signal derat_ex5_tag4_gs_match    : std_ulogic;
signal derat_ex5_tag4_epn_match   : std_ulogic;
signal derat_ex5_tag4_thdid_match : std_ulogic;
signal ierat_tag4_dup_thdid  : std_ulogic_vector(0 to thdid_width-1);
signal derat_tag4_dup_thdid  : std_ulogic_vector(0 to thdid_width-1);
signal tlb_way0_lo_calc_par    : std_ulogic_vector(0 to 9);
signal tlb_way0_hi_calc_par    : std_ulogic_vector(0 to 9);
signal tlb_way0_parerr    : std_ulogic;
signal tlb_way1_lo_calc_par    : std_ulogic_vector(0 to 9);
signal tlb_way1_hi_calc_par    : std_ulogic_vector(0 to 9);
signal tlb_way1_parerr    : std_ulogic;
signal tlb_way2_lo_calc_par    : std_ulogic_vector(0 to 9);
signal tlb_way2_hi_calc_par    : std_ulogic_vector(0 to 9);
signal tlb_way2_parerr    : std_ulogic;
signal tlb_way3_lo_calc_par    : std_ulogic_vector(0 to 9);
signal tlb_way3_hi_calc_par    : std_ulogic_vector(0 to 9);
signal tlb_way3_parerr    : std_ulogic;
signal lru_calc_par     : std_ulogic_vector(0 to 1);
signal tlb_datain_lo_tlbwe_0_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_lo_tlbwe_0_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_hi_hv_tlbwe_0_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_hi_gs_tlbwe_0_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_hi_hv_tlbwe_0_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_hi_gs_tlbwe_0_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_lo_tlbwe_1_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_lo_tlbwe_1_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_hi_hv_tlbwe_1_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_hi_gs_tlbwe_1_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_hi_hv_tlbwe_1_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_hi_gs_tlbwe_1_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_lo_tlbwe_2_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_lo_tlbwe_2_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_hi_hv_tlbwe_2_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_hi_gs_tlbwe_2_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_hi_hv_tlbwe_2_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_hi_gs_tlbwe_2_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_lo_tlbwe_3_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_lo_tlbwe_3_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_hi_hv_tlbwe_3_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_hi_gs_tlbwe_3_nopar   : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_hi_hv_tlbwe_3_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_hi_gs_tlbwe_3_par     : std_ulogic_vector(0 to 9);
signal tlb_datain_lo_ptereload_nopar : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_lo_ptereload_par   : std_ulogic_vector(0 to 9);
signal tlb_datain_hi_hv_ptereload_nopar : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_hi_gs_ptereload_nopar : std_ulogic_vector(0 to tlb_word_width-10-1);
signal tlb_datain_hi_hv_ptereload_par   : std_ulogic_vector(0 to 9);
signal tlb_datain_hi_gs_ptereload_par   : std_ulogic_vector(0 to 9);
signal ptereload_req_derived_usxwr :  std_ulogic_vector(0 to 5);
signal lrat_tag3_lpn_sig              : std_ulogic_vector(22 to 51);
signal lrat_tag3_rpn_sig              : std_ulogic_vector(22 to 51);
signal lrat_tag4_lpn_sig              : std_ulogic_vector(22 to 51);
signal lrat_tag4_rpn_sig              : std_ulogic_vector(22 to 51);
-- synopsys translate_off
-- synopsys translate_on
signal lru_datain_alt_d         : std_ulogic_vector(4 to 9);
signal lru_update_data_alt      : std_ulogic_vector(0 to 2);
signal tlb_tag4_parerr_enab    : std_ulogic;
signal tlb_tag4_tlbre_parerr  : std_ulogic;
signal lru_update_data_snoophit_eco    : std_ulogic_vector(0 to 2);
signal lru_update_data_erathit_eco    : std_ulogic_vector(0 to 2);
-- synopsys translate_off
-- synopsys translate_on
signal unused_dc  :  std_ulogic_vector(0 to 38);
-- synopsys translate_off
-- synopsys translate_on
signal ECO107332_orred_tag4_thdid_flushed  : std_ulogic;
signal ECO107332_tlb_par_err_d  : std_ulogic_vector(0 to thdid_width-1);
signal ECO107332_lru_par_err_d  : std_ulogic_vector(0 to thdid_width-1);
signal pc_sg_1         : std_ulogic;
signal pc_sg_0         : std_ulogic;
signal pc_fce_1        : std_ulogic;
signal pc_fce_0        : std_ulogic;
signal pc_func_sl_thold_1        : std_ulogic;
signal pc_func_sl_thold_0        : std_ulogic;
signal pc_func_sl_thold_0_b      : std_ulogic;
signal pc_func_slp_sl_thold_1    : std_ulogic;
signal pc_func_slp_sl_thold_0    : std_ulogic;
signal pc_func_slp_sl_thold_0_b  : std_ulogic;
signal pc_func_sl_force     : std_ulogic;
signal pc_func_slp_sl_force : std_ulogic;
signal pc_func_slp_nsl_thold_1   : std_ulogic;
signal pc_func_slp_nsl_thold_0   : std_ulogic;
signal pc_func_slp_nsl_thold_0_b : std_ulogic_vector(0 to 1);
signal pc_func_slp_nsl_force     : std_ulogic_vector(0 to 1);
signal siv_0, sov_0                      : std_ulogic_vector(0 to scan_right_0);
signal siv_1, sov_1                      : std_ulogic_vector(0 to scan_right_1);
signal siv_2, sov_2                      : std_ulogic_vector(0 to scan_right_2);
signal tidn                     : std_ulogic;
signal tiup                     : std_ulogic;
  BEGIN 

tidn  <=  '0';
tiup  <=  '1';
tlb_addr3_d  <=  tlb_addr2;
tlb_way0_d  <=  tlb_dataout(0 to tlb_way_width-1);
tlb_way1_d  <=  tlb_dataout(tlb_way_width to 2*tlb_way_width-1);
tlb_way2_d  <=  tlb_dataout(2*tlb_way_width to 3*tlb_way_width-1);
tlb_way3_d  <=  tlb_dataout(3*tlb_way_width to 4*tlb_way_width-1);
tlb_tag3_d(0 TO tagpos_thdid-1) <=  tlb_tag2(0 to tagpos_thdid-1);
tlb_tag3_d(tagpos_thdid TO tagpos_thdid+thdid_width-1) <=   
            (others => '0') when ((tlb_tag4_wayhit_q(tlb_ways)='1' or tlb_tag4_q(tagpos_endflag)='1' or or_reduce(tag4_parerr_q(0 to 4))='1') and
                  tlb_tag4_q(tagpos_type_ptereload)='0' and
                    (tlb_tag4_q(tagpos_type_ierat)='1' or tlb_tag4_q(tagpos_type_derat)='1')) 
      else (others => '0') when ((tlb_tag4_wayhit_q(tlb_ways)='1' or tlb_tag4_q(tagpos_endflag)='1' or or_reduce(tag4_parerr_q(0 to 4))='1') and 
                    (tlb_tag4_q(tagpos_type_tlbsx)='1' or tlb_tag4_q(tagpos_type_tlbsrx)='1')) 
      else (others => '0') when (tlb_tag4_q(tagpos_endflag)='1' and tlb_tag4_q(tagpos_type_snoop)='1') 
      else (others => '0') when ((tlb_tag4_q(tagpos_type_tlbre)='1' or tlb_tag4_q(tagpos_type_tlbwe)='1' or tlb_tag4_q(tagpos_type_ptereload)='1' ) and 
               tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000") 
      else tlb_tag2(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag2_flush);
tlb_tag3_d(tagpos_thdid+thdid_width TO tlb_tag_width-1) <=  tlb_tag2(tagpos_thdid+thdid_width to tlb_tag_width-1);
tlb_tag3_clone1_d(0 TO tagpos_thdid-1) <=  tlb_tag2(0 to tagpos_thdid-1);
tlb_tag3_clone1_d(tagpos_thdid TO tagpos_thdid+thdid_width-1) <=   
            (others => '0') when ((tlb_tag4_wayhit_q(tlb_ways)='1' or tlb_tag4_q(tagpos_endflag)='1' or or_reduce(tag4_parerr_q(0 to 4))='1') and 
               tlb_tag4_q(tagpos_type_ptereload)='0' and
                    (tlb_tag4_q(tagpos_type_ierat)='1' or tlb_tag4_q(tagpos_type_derat)='1')) 
      else (others => '0') when ((tlb_tag4_wayhit_q(tlb_ways)='1' or tlb_tag4_q(tagpos_endflag)='1' or or_reduce(tag4_parerr_q(0 to 4))='1') and 
                    (tlb_tag4_q(tagpos_type_tlbsx)='1' or tlb_tag4_q(tagpos_type_tlbsrx)='1')) 
      else (others => '0') when (tlb_tag4_q(tagpos_endflag)='1' and tlb_tag4_q(tagpos_type_snoop)='1') 
      else (others => '0') when ((tlb_tag4_q(tagpos_type_tlbre)='1' or tlb_tag4_q(tagpos_type_tlbwe)='1' or tlb_tag4_q(tagpos_type_ptereload)='1' ) and 
               tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000") 
      else tlb_tag2(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag2_flush);
tlb_tag3_clone1_d(tagpos_thdid+thdid_width TO tlb_tag_width-1) <=  tlb_tag2(tagpos_thdid+thdid_width to tlb_tag_width-1);
tlb_tag3_clone2_d(0 TO tagpos_thdid-1) <=  tlb_tag2(0 to tagpos_thdid-1);
tlb_tag3_clone2_d(tagpos_thdid TO tagpos_thdid+thdid_width-1) <=   
            (others => '0') when ((tlb_tag4_wayhit_q(tlb_ways)='1' or tlb_tag4_q(tagpos_endflag)='1' or or_reduce(tag4_parerr_q(0 to 4))='1') and 
                 tlb_tag4_q(tagpos_type_ptereload)='0' and
                    (tlb_tag4_q(tagpos_type_ierat)='1' or tlb_tag4_q(tagpos_type_derat)='1')) 
      else (others => '0') when ((tlb_tag4_wayhit_q(tlb_ways)='1' or tlb_tag4_q(tagpos_endflag)='1' or or_reduce(tag4_parerr_q(0 to 4))='1') and 
                    (tlb_tag4_q(tagpos_type_tlbsx)='1' or tlb_tag4_q(tagpos_type_tlbsrx)='1')) 
      else (others => '0') when (tlb_tag4_q(tagpos_endflag)='1' and tlb_tag4_q(tagpos_type_snoop)='1') 
      else (others => '0') when ((tlb_tag4_q(tagpos_type_tlbre)='1' or tlb_tag4_q(tagpos_type_tlbwe)='1' or tlb_tag4_q(tagpos_type_ptereload)='1' ) and 
               tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000") 
      else tlb_tag2(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag2_flush);
tlb_tag3_clone2_d(tagpos_thdid+thdid_width TO tlb_tag_width-1) <=  tlb_tag2(tagpos_thdid+thdid_width to tlb_tag_width-1);
tlb_tag3_cmpmask_d(0) <=  Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1GB);
tlb_tag3_cmpmask_d(1) <=  Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1GB) or 
                         Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_256MB);
tlb_tag3_cmpmask_d(2) <=  Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1GB) or 
                         Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_256MB) or
                         Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_16MB);
tlb_tag3_cmpmask_d(3) <=  Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1GB) or 
                         Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_256MB) or
                         Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_16MB) or
                         Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1MB);
tlb_tag3_cmpmask_d(4) <=  Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1GB) or 
                         Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_256MB) or
                         Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_16MB) or
                         Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1MB) or
                         Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_64KB);
tlb_tag3_cmpmask_clone_d(0) <=  Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1GB);
tlb_tag3_cmpmask_clone_d(1) <=  Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1GB) or 
                               Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_256MB);
tlb_tag3_cmpmask_clone_d(2) <=  Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1GB) or 
                               Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_256MB) or
                               Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_16MB);
tlb_tag3_cmpmask_clone_d(3) <=  Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1GB) or 
                               Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_256MB) or
                               Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_16MB) or
                               Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1MB);
tlb_tag3_cmpmask_clone_d(4) <=  Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1GB) or 
                               Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_256MB) or
                               Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_16MB) or
                               Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_1MB) or
                               Eq(tlb_tag2(tagpos_size to tagpos_size+3), TLB_PgSize_64KB);
tlb_way0_cmpmask_d(0) <=  Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB);
tlb_way0_cmpmask_d(1) <=  Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB);
tlb_way0_cmpmask_d(2) <=  Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB);
tlb_way0_cmpmask_d(3) <=  Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB) or
                           Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB);
tlb_way0_cmpmask_d(4) <=  Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB) or
                           Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB) or
                           Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_64KB);
tlb_way0_xbitmask_d(0) <=  Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB);
tlb_way0_xbitmask_d(1) <=  Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB);
tlb_way0_xbitmask_d(2) <=  Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB);
tlb_way0_xbitmask_d(3) <=  Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB);
tlb_way0_xbitmask_d(4) <=  Eq(tlb_dataout(0*tlb_way_width+waypos_size   to 0*tlb_way_width+waypos_size+3),   TLB_PgSize_64KB);
tlb_way1_cmpmask_d(0) <=  Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB);
tlb_way1_cmpmask_d(1) <=  Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB);
tlb_way1_cmpmask_d(2) <=  Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB);
tlb_way1_cmpmask_d(3) <=  Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB) or
                           Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB);
tlb_way1_cmpmask_d(4) <=  Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB) or
                           Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB) or
                           Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_64KB);
tlb_way1_xbitmask_d(0) <=  Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB);
tlb_way1_xbitmask_d(1) <=  Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB);
tlb_way1_xbitmask_d(2) <=  Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB);
tlb_way1_xbitmask_d(3) <=  Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB);
tlb_way1_xbitmask_d(4) <=  Eq(tlb_dataout(1*tlb_way_width+waypos_size   to 1*tlb_way_width+waypos_size+3),   TLB_PgSize_64KB);
tlb_way2_cmpmask_d(0) <=  Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB);
tlb_way2_cmpmask_d(1) <=  Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB);
tlb_way2_cmpmask_d(2) <=  Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB);
tlb_way2_cmpmask_d(3) <=  Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB) or
                           Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB);
tlb_way2_cmpmask_d(4) <=  Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB) or
                           Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB) or
                           Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_64KB);
tlb_way2_xbitmask_d(0) <=  Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB);
tlb_way2_xbitmask_d(1) <=  Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB);
tlb_way2_xbitmask_d(2) <=  Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB);
tlb_way2_xbitmask_d(3) <=  Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB);
tlb_way2_xbitmask_d(4) <=  Eq(tlb_dataout(2*tlb_way_width+waypos_size   to 2*tlb_way_width+waypos_size+3),   TLB_PgSize_64KB);
tlb_way3_cmpmask_d(0) <=  Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB);
tlb_way3_cmpmask_d(1) <=  Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB);
tlb_way3_cmpmask_d(2) <=  Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB);
tlb_way3_cmpmask_d(3) <=  Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB) or
                           Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB);
tlb_way3_cmpmask_d(4) <=  Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB) or 
                           Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB) or
                           Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB) or
                           Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB) or
                           Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_64KB);
tlb_way3_xbitmask_d(0) <=  Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_1GB);
tlb_way3_xbitmask_d(1) <=  Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_256MB);
tlb_way3_xbitmask_d(2) <=  Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_16MB);
tlb_way3_xbitmask_d(3) <=  Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_1MB);
tlb_way3_xbitmask_d(4) <=  Eq(tlb_dataout(3*tlb_way_width+waypos_size   to 3*tlb_way_width+waypos_size+3),   TLB_PgSize_64KB);
tlb_way0_lo_calc_par(0) <=  xor_reduce(tlb_way0_q(0   to 7));
tlb_way0_lo_calc_par(1) <=  xor_reduce(tlb_way0_q(8   to 15));
tlb_way0_lo_calc_par(2) <=  xor_reduce(tlb_way0_q(16   to 23));
tlb_way0_lo_calc_par(3) <=  xor_reduce(tlb_way0_q(24   to 31));
tlb_way0_lo_calc_par(4) <=  xor_reduce(tlb_way0_q(32   to 39));
tlb_way0_lo_calc_par(5) <=  xor_reduce(tlb_way0_q(40   to 47));
tlb_way0_lo_calc_par(6) <=  xor_reduce(tlb_way0_q(48   to 51));
tlb_way0_lo_calc_par(7) <=  xor_reduce(tlb_way0_q(52   to 59));
tlb_way0_lo_calc_par(8) <=  xor_reduce(tlb_way0_q(60   to 65));
tlb_way0_lo_calc_par(9) <=  xor_reduce(tlb_way0_q(66   to 73));
tlb_way1_lo_calc_par(0) <=  xor_reduce(tlb_way1_q(0   to 7));
tlb_way1_lo_calc_par(1) <=  xor_reduce(tlb_way1_q(8   to 15));
tlb_way1_lo_calc_par(2) <=  xor_reduce(tlb_way1_q(16   to 23));
tlb_way1_lo_calc_par(3) <=  xor_reduce(tlb_way1_q(24   to 31));
tlb_way1_lo_calc_par(4) <=  xor_reduce(tlb_way1_q(32   to 39));
tlb_way1_lo_calc_par(5) <=  xor_reduce(tlb_way1_q(40   to 47));
tlb_way1_lo_calc_par(6) <=  xor_reduce(tlb_way1_q(48   to 51));
tlb_way1_lo_calc_par(7) <=  xor_reduce(tlb_way1_q(52   to 59));
tlb_way1_lo_calc_par(8) <=  xor_reduce(tlb_way1_q(60   to 65));
tlb_way1_lo_calc_par(9) <=  xor_reduce(tlb_way1_q(66   to 73));
tlb_way2_lo_calc_par(0) <=  xor_reduce(tlb_way2_q(0   to 7));
tlb_way2_lo_calc_par(1) <=  xor_reduce(tlb_way2_q(8   to 15));
tlb_way2_lo_calc_par(2) <=  xor_reduce(tlb_way2_q(16   to 23));
tlb_way2_lo_calc_par(3) <=  xor_reduce(tlb_way2_q(24   to 31));
tlb_way2_lo_calc_par(4) <=  xor_reduce(tlb_way2_q(32   to 39));
tlb_way2_lo_calc_par(5) <=  xor_reduce(tlb_way2_q(40   to 47));
tlb_way2_lo_calc_par(6) <=  xor_reduce(tlb_way2_q(48   to 51));
tlb_way2_lo_calc_par(7) <=  xor_reduce(tlb_way2_q(52   to 59));
tlb_way2_lo_calc_par(8) <=  xor_reduce(tlb_way2_q(60   to 65));
tlb_way2_lo_calc_par(9) <=  xor_reduce(tlb_way2_q(66   to 73));
tlb_way3_lo_calc_par(0) <=  xor_reduce(tlb_way3_q(0   to 7));
tlb_way3_lo_calc_par(1) <=  xor_reduce(tlb_way3_q(8   to 15));
tlb_way3_lo_calc_par(2) <=  xor_reduce(tlb_way3_q(16   to 23));
tlb_way3_lo_calc_par(3) <=  xor_reduce(tlb_way3_q(24   to 31));
tlb_way3_lo_calc_par(4) <=  xor_reduce(tlb_way3_q(32   to 39));
tlb_way3_lo_calc_par(5) <=  xor_reduce(tlb_way3_q(40   to 47));
tlb_way3_lo_calc_par(6) <=  xor_reduce(tlb_way3_q(48   to 51));
tlb_way3_lo_calc_par(7) <=  xor_reduce(tlb_way3_q(52   to 59));
tlb_way3_lo_calc_par(8) <=  xor_reduce(tlb_way3_q(60   to 65));
tlb_way3_lo_calc_par(9) <=  xor_reduce(tlb_way3_q(66   to 73));
tlb_way0_hi_calc_par(0) <=  xor_reduce(tlb_way0_q(tlb_word_width+0   to tlb_word_width+7));
tlb_way0_hi_calc_par(1) <=  xor_reduce(tlb_way0_q(tlb_word_width+8   to tlb_word_width+15));
tlb_way0_hi_calc_par(2) <=  xor_reduce(tlb_way0_q(tlb_word_width+16   to tlb_word_width+23));
tlb_way0_hi_calc_par(3) <=  xor_reduce(tlb_way0_q(tlb_word_width+24   to tlb_word_width+31));
tlb_way0_hi_calc_par(4) <=  xor_reduce(tlb_way0_q(tlb_word_width+32   to tlb_word_width+39));
tlb_way0_hi_calc_par(5) <=  xor_reduce(tlb_way0_q(tlb_word_width+40   to tlb_word_width+44));
tlb_way0_hi_calc_par(6) <=  xor_reduce(tlb_way0_q(tlb_word_width+45   to tlb_word_width+49));
tlb_way0_hi_calc_par(7) <=  xor_reduce(tlb_way0_q(tlb_word_width+50   to tlb_word_width+57));
tlb_way0_hi_calc_par(8) <=  xor_reduce(tlb_way0_q(tlb_word_width+58   to tlb_word_width+65));
tlb_way0_hi_calc_par(9) <=  xor_reduce(tlb_way0_q(tlb_word_width+66   to tlb_word_width+73));
tlb_way1_hi_calc_par(0) <=  xor_reduce(tlb_way1_q(tlb_word_width+0   to tlb_word_width+7));
tlb_way1_hi_calc_par(1) <=  xor_reduce(tlb_way1_q(tlb_word_width+8   to tlb_word_width+15));
tlb_way1_hi_calc_par(2) <=  xor_reduce(tlb_way1_q(tlb_word_width+16   to tlb_word_width+23));
tlb_way1_hi_calc_par(3) <=  xor_reduce(tlb_way1_q(tlb_word_width+24   to tlb_word_width+31));
tlb_way1_hi_calc_par(4) <=  xor_reduce(tlb_way1_q(tlb_word_width+32   to tlb_word_width+39));
tlb_way1_hi_calc_par(5) <=  xor_reduce(tlb_way1_q(tlb_word_width+40   to tlb_word_width+44));
tlb_way1_hi_calc_par(6) <=  xor_reduce(tlb_way1_q(tlb_word_width+45   to tlb_word_width+49));
tlb_way1_hi_calc_par(7) <=  xor_reduce(tlb_way1_q(tlb_word_width+50   to tlb_word_width+57));
tlb_way1_hi_calc_par(8) <=  xor_reduce(tlb_way1_q(tlb_word_width+58   to tlb_word_width+65));
tlb_way1_hi_calc_par(9) <=  xor_reduce(tlb_way1_q(tlb_word_width+66   to tlb_word_width+73));
tlb_way2_hi_calc_par(0) <=  xor_reduce(tlb_way2_q(tlb_word_width+0   to tlb_word_width+7));
tlb_way2_hi_calc_par(1) <=  xor_reduce(tlb_way2_q(tlb_word_width+8   to tlb_word_width+15));
tlb_way2_hi_calc_par(2) <=  xor_reduce(tlb_way2_q(tlb_word_width+16   to tlb_word_width+23));
tlb_way2_hi_calc_par(3) <=  xor_reduce(tlb_way2_q(tlb_word_width+24   to tlb_word_width+31));
tlb_way2_hi_calc_par(4) <=  xor_reduce(tlb_way2_q(tlb_word_width+32   to tlb_word_width+39));
tlb_way2_hi_calc_par(5) <=  xor_reduce(tlb_way2_q(tlb_word_width+40   to tlb_word_width+44));
tlb_way2_hi_calc_par(6) <=  xor_reduce(tlb_way2_q(tlb_word_width+45   to tlb_word_width+49));
tlb_way2_hi_calc_par(7) <=  xor_reduce(tlb_way2_q(tlb_word_width+50   to tlb_word_width+57));
tlb_way2_hi_calc_par(8) <=  xor_reduce(tlb_way2_q(tlb_word_width+58   to tlb_word_width+65));
tlb_way2_hi_calc_par(9) <=  xor_reduce(tlb_way2_q(tlb_word_width+66   to tlb_word_width+73));
tlb_way3_hi_calc_par(0) <=  xor_reduce(tlb_way3_q(tlb_word_width+0   to tlb_word_width+7));
tlb_way3_hi_calc_par(1) <=  xor_reduce(tlb_way3_q(tlb_word_width+8   to tlb_word_width+15));
tlb_way3_hi_calc_par(2) <=  xor_reduce(tlb_way3_q(tlb_word_width+16   to tlb_word_width+23));
tlb_way3_hi_calc_par(3) <=  xor_reduce(tlb_way3_q(tlb_word_width+24   to tlb_word_width+31));
tlb_way3_hi_calc_par(4) <=  xor_reduce(tlb_way3_q(tlb_word_width+32   to tlb_word_width+39));
tlb_way3_hi_calc_par(5) <=  xor_reduce(tlb_way3_q(tlb_word_width+40   to tlb_word_width+44));
tlb_way3_hi_calc_par(6) <=  xor_reduce(tlb_way3_q(tlb_word_width+45   to tlb_word_width+49));
tlb_way3_hi_calc_par(7) <=  xor_reduce(tlb_way3_q(tlb_word_width+50   to tlb_word_width+57));
tlb_way3_hi_calc_par(8) <=  xor_reduce(tlb_way3_q(tlb_word_width+58   to tlb_word_width+65));
tlb_way3_hi_calc_par(9) <=  xor_reduce(tlb_way3_q(tlb_word_width+66   to tlb_word_width+73));
tlb_way0_parerr     <=  or_reduce(tlb_way0_lo_calc_par(0   to 9) xor tlb_way0_q(74   to 83)) or
                      or_reduce(tlb_way0_hi_calc_par(0   to 9) xor tlb_way0_q(tlb_word_width+74   to tlb_word_width+83));
tlb_way1_parerr     <=  or_reduce(tlb_way1_lo_calc_par(0   to 9) xor tlb_way1_q(74   to 83)) or
                      or_reduce(tlb_way1_hi_calc_par(0   to 9) xor tlb_way1_q(tlb_word_width+74   to tlb_word_width+83));
tlb_way2_parerr     <=  or_reduce(tlb_way2_lo_calc_par(0   to 9) xor tlb_way2_q(74   to 83)) or
                      or_reduce(tlb_way2_hi_calc_par(0   to 9) xor tlb_way2_q(tlb_word_width+74   to tlb_word_width+83));
tlb_way3_parerr     <=  or_reduce(tlb_way3_lo_calc_par(0   to 9) xor tlb_way3_q(74   to 83)) or
                      or_reduce(tlb_way3_hi_calc_par(0   to 9) xor tlb_way3_q(tlb_word_width+74   to tlb_word_width+83));
tag4_parerr_d(0) <=  tlb_way0_parerr;
tag4_parerr_d(1) <=  tlb_way1_parerr;
tag4_parerr_d(2) <=  tlb_way2_parerr;
tag4_parerr_d(3) <=  tlb_way3_parerr;
lru_tag3_dataout_d  <=  lru_dataout;
tlb_tag4_d(0 TO tagpos_thdid-1) <=  tlb_tag3_q(0 to tagpos_thdid-1);
tlb_tag4_d(tagpos_thdid TO tagpos_thdid+thdid_width-1) <=  
    (others => '0') when ((tlb_tag4_wayhit_q(tlb_ways)='1' or tlb_tag4_q(tagpos_endflag)='1' or or_reduce(tag4_parerr_q(0 to 4))='1') and 
        tlb_tag4_q(tagpos_type_ptereload)='0' and 
        (tlb_tag4_q(tagpos_type_ierat)='1' or tlb_tag4_q(tagpos_type_derat)='1')) 
      else (others => '0') when ((tlb_tag4_wayhit_q(tlb_ways)='1' or tlb_tag4_q(tagpos_endflag)='1' or or_reduce(tag4_parerr_q(0 to 4))='1') and 
                    (tlb_tag4_q(tagpos_type_tlbsx)='1' or tlb_tag4_q(tagpos_type_tlbsrx)='1')) 
      else (others => '0') when (tlb_tag4_q(tagpos_endflag)='1' and tlb_tag4_q(tagpos_type_snoop)='1') 
      else (others => '0') when ((tlb_tag4_q(tagpos_type_tlbre)='1' or tlb_tag4_q(tagpos_type_tlbwe)='1' or tlb_tag4_q(tagpos_type_ptereload)='1') and 
               tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000") 
     else tlb_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush);
tlb_tag4_d(tagpos_thdid+thdid_width TO tlb_tag_width-1) <=  tlb_tag3_q(tagpos_thdid+thdid_width to tlb_tag_width-1);
tlb_addr4_d  <=  tlb_addr3_q;
tlb_tag4_way_d  <=  ( tlb_way0_q and (0 to tlb_way_width-1 => tlb_wayhit(0)) ) or
                  ( tlb_way1_q and (0 to tlb_way_width-1 => tlb_wayhit(1)) );
tlb_tag4_way_clone_d  <=  ( tlb_way2_q and (0 to tlb_way_width-1 => tlb_wayhit(2)) ) or
                        ( tlb_way3_q and (0 to tlb_way_width-1 => tlb_wayhit(3)) );
tlb_tag4_way_or  <=  tlb_tag4_way_q or tlb_tag4_way_clone_q;
tlb_tag4_way_rw_d  <=  ( tlb_way0_q and (0 to tlb_way_width-1 => (not tlb_tag3_clone1_q(tagpos_esel+1) and not tlb_tag3_clone1_q(tagpos_esel+2) and or_reduce(tlb_tag3_clone1_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and
                       (tlb_tag3_clone1_q(tagpos_type_tlbre) or (tlb_tag3_clone1_q(tagpos_type_tlbwe) and not tlb_tag3_clone1_q(tagpos_hes))) )) ) or
                   ( tlb_way1_q and (0 to tlb_way_width-1 => (not tlb_tag3_clone1_q(tagpos_esel+1) and      tlb_tag3_clone1_q(tagpos_esel+2) and or_reduce(tlb_tag3_clone1_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and
                       (tlb_tag3_clone1_q(tagpos_type_tlbre) or (tlb_tag3_clone1_q(tagpos_type_tlbwe) and not tlb_tag3_clone1_q(tagpos_hes))) )) ) or

                   ( tlb_way0_q and (0 to tlb_way_width-1 => (not lru_tag3_dataout_q(4) and not lru_tag3_dataout_q(5) and or_reduce(tlb_tag3_clone1_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and
                       (tlb_tag3_clone1_q(tagpos_type_ptereload) or (tlb_tag3_clone1_q(tagpos_type_tlbwe) and tlb_tag3_clone1_q(tagpos_hes))) )) ) or
                   ( tlb_way1_q and (0 to tlb_way_width-1 => (not lru_tag3_dataout_q(4) and      lru_tag3_dataout_q(5) and or_reduce(tlb_tag3_clone1_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and
                       (tlb_tag3_clone1_q(tagpos_type_ptereload) or (tlb_tag3_clone1_q(tagpos_type_tlbwe) and tlb_tag3_clone1_q(tagpos_hes))) )) );
tlb_tag4_way_rw_clone_d  <=  ( tlb_way2_q and (0 to tlb_way_width-1 => (     tlb_tag3_clone2_q(tagpos_esel+1) and not tlb_tag3_clone2_q(tagpos_esel+2) and or_reduce(tlb_tag3_clone2_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and
                       (tlb_tag3_clone2_q(tagpos_type_tlbre) or (tlb_tag3_clone2_q(tagpos_type_tlbwe) and not tlb_tag3_clone2_q(tagpos_hes))) )) ) or
                   ( tlb_way3_q and (0 to tlb_way_width-1 => (     tlb_tag3_clone2_q(tagpos_esel+1) and      tlb_tag3_clone2_q(tagpos_esel+2) and or_reduce(tlb_tag3_clone2_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and
                       (tlb_tag3_clone2_q(tagpos_type_tlbre) or (tlb_tag3_clone2_q(tagpos_type_tlbwe) and not tlb_tag3_clone2_q(tagpos_hes))) )) ) or

                   ( tlb_way2_q and (0 to tlb_way_width-1 => (     lru_tag3_dataout_q(4) and not lru_tag3_dataout_q(6) and or_reduce(tlb_tag3_clone2_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and
                       (tlb_tag3_clone2_q(tagpos_type_ptereload) or (tlb_tag3_clone2_q(tagpos_type_tlbwe) and tlb_tag3_clone2_q(tagpos_hes))) )) ) or
                   ( tlb_way3_q and (0 to tlb_way_width-1 => (     lru_tag3_dataout_q(4) and      lru_tag3_dataout_q(6) and or_reduce(tlb_tag3_clone2_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and
                       (tlb_tag3_clone2_q(tagpos_type_ptereload) or (tlb_tag3_clone2_q(tagpos_type_tlbwe) and tlb_tag3_clone2_q(tagpos_hes))) )) ) ;
tlb_tag4_way_rw_or  <=  tlb_tag4_way_rw_q or tlb_tag4_way_rw_clone_q;
tlb_tag4_wayhit_d(0 TO tlb_ways-1) <=  tlb_wayhit(0 to tlb_ways-1);
tlb_tag4_wayhit_d(tlb_ways) <=  '1' when (tlb_tag4_wayhit_q(tlb_ways)='0' and tlb_wayhit(0 to tlb_ways-1) /= "0000" and 
                                          tlb_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000") 
                           else '0';
tlb_tag4_way_act  <=  or_reduce(tlb_tag3_clone1_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and not(tlb_tag4_wayhit_q(tlb_ways)) and  not tlb_tag3_clone1_q(tagpos_type_ptereload) and
                       (tlb_tag3_clone1_q(tagpos_type_derat) or tlb_tag3_clone1_q(tagpos_type_ierat) or tlb_tag3_clone1_q(tagpos_type_tlbsx) or tlb_tag3_clone1_q(tagpos_type_tlbsrx));
tlb_tag4_way_clone_act  <=  or_reduce(tlb_tag3_clone2_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and not(tlb_tag4_wayhit_q(tlb_ways)) and  not tlb_tag3_clone2_q(tagpos_type_ptereload) and
                       (tlb_tag3_clone2_q(tagpos_type_derat) or tlb_tag3_clone2_q(tagpos_type_ierat) or tlb_tag3_clone2_q(tagpos_type_tlbsx) or tlb_tag3_clone2_q(tagpos_type_tlbsrx));
tlb_tag4_way_rw_act  <=  or_reduce(tlb_tag3_clone1_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and 
                          (tlb_tag3_clone1_q(tagpos_type_tlbre) or tlb_tag3_clone1_q(tagpos_type_tlbwe) or tlb_tag3_clone1_q(tagpos_type_ptereload));
tlb_tag4_way_rw_clone_act  <=  or_reduce(tlb_tag3_clone2_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and 
                          (tlb_tag3_clone2_q(tagpos_type_tlbre) or tlb_tag3_clone2_q(tagpos_type_tlbwe) or tlb_tag3_clone2_q(tagpos_type_ptereload));
lru_tag4_dataout_d  <=  lru_tag3_dataout_q;
addr_enable(0) <=  ( or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone1_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"1011") );
addr_enable(1) <=  ( or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone1_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_q(pos_tlbi_msb) and tlb_tag3_cmpmask_q(0) );
addr_enable(2) <=  ( or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone1_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_q(pos_tlbi_msb) and tlb_tag3_cmpmask_q(1) );
addr_enable(3) <=  ( or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone1_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_q(pos_tlbi_msb) and tlb_tag3_cmpmask_q(1) ) 
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"0011") and 
                             not mmucr1_q(pos_tlbi_msb) and tlb_tag3_cmpmask_q(0) );
addr_enable(4) <=  ( or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone1_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_q(pos_tlbi_msb) and tlb_tag3_cmpmask_q(2) ) 
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"0011") and 
                             not mmucr1_q(pos_tlbi_msb) and tlb_tag3_cmpmask_q(1) );
addr_enable(5) <=  ( or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                       not tlb_tag3_clone1_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_q(pos_tlbi_msb) and tlb_tag3_cmpmask_q(3) ) 
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"0011") and 
                             not mmucr1_q(pos_tlbi_msb) and tlb_tag3_cmpmask_q(2) );
addr_enable(6) <=  ( or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                       not tlb_tag3_clone1_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_q(pos_tlbi_msb) ) 
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is to tagpos_is+3),"0011") and 
                             not mmucr1_q(pos_tlbi_msb) and tlb_tag3_cmpmask_q(3) );
addr_enable(7) <=  ( or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone1_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3),"011") );
addr_enable(8) <=  ( or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone1_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3),"011") );
class_enable  <=  '1' when (tlb_tag3_clone1_q(tagpos_type_snoop)='1' and tlb_tag3_clone1_q(tagpos_is+1)='1')  
           else '0';
pgsize_enable  <=  tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3),"011");
extclass_enable  <=  "00";
thdid_enable  <=  or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and not tlb_tag3_clone1_q(tagpos_type_ptereload);
pid_enable  <=  '1' when (tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx) /= "0000" and 
                            tlb_tag3_clone1_q(tagpos_type_ptereload)='0') 
         else '1' when (tlb_tag3_clone1_q(tagpos_type_snoop)='1' and tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3)="001") 
          else '1' when (tlb_tag3_clone1_q(tagpos_type_snoop)='1' and tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3)="011") 
           else '0';
state_enable(0) <=  '1' when (tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx) /= "0000" and 
                            tlb_tag3_clone1_q(tagpos_type_ptereload)='0') 
               else '1' when (tlb_tag3_clone1_q(tagpos_type_snoop)='1' and tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3)="010" ) 
                else '1' when (tlb_tag3_clone1_q(tagpos_type_snoop)='1' and tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3)="011" ) 
                 else '0';
state_enable(1) <=  '1' when (tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx) /= "0000" and 
                            tlb_tag3_clone1_q(tagpos_type_ptereload)='0') 
                else '1' when (tlb_tag3_clone1_q(tagpos_type_snoop)='1' and tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3)="011" ) 
                 else '0';
lpid_enable  <=  '1' when (tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx) /= "0000" and 
                            tlb_tag3_clone1_q(tagpos_type_ptereload)='0') 
             else not(tlb_tag3_clone1_q(tagpos_hes)) when (tlb_tag3_clone1_q(tagpos_type_snoop)='1') 
             else '0';
ind_enable  <=  ( or_reduce(tlb_tag3_clone1_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                        not tlb_tag3_clone1_q(tagpos_type_ptereload) ) 
           or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3),"011") ) 
           or ( tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3),"001") and tlb_tag3_clone1_q(tagpos_ind) );
iprot_enable  <=  tlb_tag3_clone1_q(tagpos_type_snoop);
comp_extclass  <=  (others => '0');
comp_iprot  <=  '0';
comp_ind  <=  tlb_tag3_clone1_q(tagpos_ind) and not(tlb_tag3_clone1_q(tagpos_type_snoop) and Eq(tlb_tag3_clone1_q(tagpos_is+1 to tagpos_is+3),"001"));
addr_enable_clone(0) <=  ( or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone2_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"1011") );
addr_enable_clone(1) <=  ( or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone2_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_clone_q(pos_tlbi_msb) and tlb_tag3_cmpmask_clone_q(0) );
addr_enable_clone(2) <=  ( or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone2_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_clone_q(pos_tlbi_msb) and tlb_tag3_cmpmask_clone_q(1) );
addr_enable_clone(3) <=  ( or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone2_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_clone_q(pos_tlbi_msb) and tlb_tag3_cmpmask_clone_q(1) ) 
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"0011") and 
                             not mmucr1_clone_q(pos_tlbi_msb) and tlb_tag3_cmpmask_clone_q(0) );
addr_enable_clone(4) <=  ( or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone2_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_clone_q(pos_tlbi_msb) and tlb_tag3_cmpmask_clone_q(2) ) 
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"0011") and 
                             not mmucr1_clone_q(pos_tlbi_msb) and tlb_tag3_cmpmask_clone_q(1) );
addr_enable_clone(5) <=  ( or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                       not tlb_tag3_clone2_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_clone_q(pos_tlbi_msb) and tlb_tag3_cmpmask_clone_q(3) ) 
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"0011") and 
                             not mmucr1_clone_q(pos_tlbi_msb) and tlb_tag3_cmpmask_clone_q(2) );
addr_enable_clone(6) <=  ( or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                       not tlb_tag3_clone2_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"1011") ) 
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"0011") and 
                                 mmucr1_clone_q(pos_tlbi_msb) ) 
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is to tagpos_is+3),"0011") and 
                             not mmucr1_clone_q(pos_tlbi_msb) and tlb_tag3_cmpmask_clone_q(3) );
addr_enable_clone(7) <=  ( or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone2_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3),"011") );
addr_enable_clone(8) <=  ( or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                      not tlb_tag3_clone2_q(tagpos_type_ptereload) )  
               or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3),"011") );
class_enable_clone  <=  '1' when (tlb_tag3_clone2_q(tagpos_type_snoop)='1' and tlb_tag3_clone2_q(tagpos_is+1)='1')  
           else '0';
pgsize_enable_clone  <=  tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3),"011");
extclass_enable_clone  <=  "00";
thdid_enable_clone  <=  or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and not tlb_tag3_clone2_q(tagpos_type_ptereload);
pid_enable_clone  <=  '1' when (tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx) /= "0000" and 
                            tlb_tag3_clone2_q(tagpos_type_ptereload)='0') 
         else '1' when (tlb_tag3_clone2_q(tagpos_type_snoop)='1' and tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3)="001") 
          else '1' when (tlb_tag3_clone2_q(tagpos_type_snoop)='1' and tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3)="011") 
           else '0';
state_enable_clone(0) <=  '1' when (tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx) /= "0000" and 
                            tlb_tag3_clone2_q(tagpos_type_ptereload)='0') 
               else '1' when (tlb_tag3_clone2_q(tagpos_type_snoop)='1' and tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3)="010" ) 
                else '1' when (tlb_tag3_clone2_q(tagpos_type_snoop)='1' and tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3)="011" ) 
                 else '0';
state_enable_clone(1) <=  '1' when (tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx) /= "0000" and 
                            tlb_tag3_clone2_q(tagpos_type_ptereload)='0') 
                else '1' when (tlb_tag3_clone2_q(tagpos_type_snoop)='1' and tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3)="011" ) 
                 else '0';
lpid_enable_clone  <=  '1' when (tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx) /= "0000" and 
                            tlb_tag3_clone2_q(tagpos_type_ptereload)='0') 
             else not(tlb_tag3_clone2_q(tagpos_hes)) when (tlb_tag3_clone2_q(tagpos_type_snoop)='1') 
             else '0';
ind_enable_clone  <=  ( or_reduce(tlb_tag3_clone2_q(tagpos_type_derat to tagpos_type_tlbsrx)) and 
                        not tlb_tag3_clone2_q(tagpos_type_ptereload) ) 
           or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3),"011") ) 
           or ( tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3),"001") and tlb_tag3_clone2_q(tagpos_ind) );
iprot_enable_clone  <=  tlb_tag3_clone2_q(tagpos_type_snoop);
comp_extclass_clone  <=  (others => '0');
comp_iprot_clone  <=  '0';
comp_ind_clone  <=  tlb_tag3_clone2_q(tagpos_ind) and not(tlb_tag3_clone2_q(tagpos_type_snoop) and Eq(tlb_tag3_clone2_q(tagpos_is+1 to tagpos_is+3),"001"));
tlb_tag4_type_sig(0 TO 7) <=  tlb_tag4_q(tagpos_type to tagpos_type+7);
tlb_tag4_esel_sig(0 TO 2) <=  tlb_tag4_q(tagpos_esel to tagpos_esel+2);
tlb_tag4_hes_sig  <=  tlb_tag4_q(tagpos_hes);
tlb_tag4_wq_sig(0 TO 1) <=  tlb_tag4_q(tagpos_wq to tagpos_wq+1);
tlb_tag4_is_sig(0 TO 3) <=  tlb_tag4_q(tagpos_is to tagpos_is+3);
tlb_tag4_hv_op  <=  or_reduce( not msr_gs_q and not msr_pr_q and tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) );
multihit  <=  not(Eq(tlb_tag4_wayhit_q(0 to 3),"0000") or Eq(tlb_tag4_wayhit_q(0 to 3),"1000") or Eq(tlb_tag4_wayhit_q(0 to 3),"0100") 
                          or Eq(tlb_tag4_wayhit_q(0 to 3),"0010") or Eq(tlb_tag4_wayhit_q(0 to 3),"0001"))
             and or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1));
tlb_tag4_hes1_mas1_v(0 TO thdid_width-1) <=  
         ( (tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(1 to 3))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(0) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(2 to 3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(0 to 1) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(3))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(6))) ) 
      or ( (lru_tag4_dataout_q(0 to 2) & tlb_tag4_q(tagpos_is))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(6))) ) 

      or ( (tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(1 to 3))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(0) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(2 to 3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(0 to 1) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(3))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(6))) ) 
      or ( (lru_tag4_dataout_q(0 to 2) & tlb_tag4_q(tagpos_is))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(6))) ) 

      or ( (tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(1 to 3))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(0) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(2 to 3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(0 to 1) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(3))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(6))) ) 
      or ( (lru_tag4_dataout_q(0 to 2) & tlb_tag4_q(tagpos_is))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(6))) ) 

      or ( (tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(1 to 3))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(0) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(2 to 3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(0 to 1) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(3))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(6))) ) 
      or ( (lru_tag4_dataout_q(0 to 2) & tlb_tag4_q(tagpos_is))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(6))) );
tlb_tag4_hes0_mas1_v(0 TO thdid_width-1) <=  
         ( (tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(1 to 3))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(2 to 3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0 to 1) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0 to 2) & tlb_tag4_q(tagpos_is))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 

      or ( (tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(1 to 3))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(2 to 3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0 to 1) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0 to 2) & tlb_tag4_q(tagpos_is))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 

      or ( (tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(1 to 3))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(2 to 3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0 to 1) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0 to 2) & tlb_tag4_q(tagpos_is))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 

      or ( (tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(1 to 3))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(2 to 3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0 to 1) & tlb_tag4_q(tagpos_is) & lru_tag4_dataout_q(3)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(0 to 2) & tlb_tag4_q(tagpos_is))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) );
tlb_tag4_hes1_mas1_iprot(0 TO thdid_width-1) <=  
         ( (tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(9 to 11))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(8) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(10 to 11)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(8 to 9) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(11))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(6))) ) 
      or ( (lru_tag4_dataout_q(8 to 10) & tlb_tag4_q(tagpos_is+1))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(6))) ) 

      or ( (tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(9 to 11))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(8) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(10 to 11)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(8 to 9) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(11))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(6))) ) 
      or ( (lru_tag4_dataout_q(8 to 10) & tlb_tag4_q(tagpos_is+1))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(6))) ) 

      or ( (tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(9 to 11))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(8) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(10 to 11)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(8 to 9) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(11))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(6))) ) 
      or ( (lru_tag4_dataout_q(8 to 10) & tlb_tag4_q(tagpos_is+1))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(6))) ) 

      or ( (tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(9 to 11))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(8) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(10 to 11)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_hes) and not lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(5))) ) 
      or ( (lru_tag4_dataout_q(8 to 9) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(11))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and not lru_tag4_dataout_q(6))) ) 
      or ( (lru_tag4_dataout_q(8 to 10) & tlb_tag4_q(tagpos_is+1))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_hes) and     lru_tag4_dataout_q(4) and     lru_tag4_dataout_q(6))) );
tlb_tag4_hes0_mas1_iprot(0 TO thdid_width-1) <=  
         ( (tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(9 to 11))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(10 to 11)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8 to 9) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(11))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8 to 10) & tlb_tag4_q(tagpos_is+1))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+0) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 

      or ( (tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(9 to 11))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(10 to 11)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8 to 9) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(11))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8 to 10) & tlb_tag4_q(tagpos_is+1))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+1) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 

      or ( (tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(9 to 11))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(10 to 11)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8 to 9) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(11))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8 to 10) & tlb_tag4_q(tagpos_is+1))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+2) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 

      or ( (tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(9 to 11))                           and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(10 to 11)) and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and not tlb_tag4_q(tagpos_hes) and not tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8 to 9) & tlb_tag4_q(tagpos_is+1) & lru_tag4_dataout_q(11))  and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2))) ) 
      or ( (lru_tag4_dataout_q(8 to 10) & tlb_tag4_q(tagpos_is+1))                          and (0 to thdid_width-1 => (tlb_tag4_q(tagpos_thdid+3) and not tlb_tag4_q(tagpos_hes) and     tlb_tag4_q(tagpos_esel+1) and     tlb_tag4_q(tagpos_esel+2))) );
tlb_tag4_ptereload_v(0 TO thdid_width-1) <=  (ptereload_req_pte_lat(ptepos_valid) & lru_tag4_dataout_q(1 to 3)) 
                        when (lru_tag4_dataout_q(4 to 5)="00") 
               else (lru_tag4_dataout_q(0) & ptereload_req_pte_lat(ptepos_valid) & lru_tag4_dataout_q(2 to 3)) 
                        when (lru_tag4_dataout_q(4 to 5)="01") 
               else (lru_tag4_dataout_q(0 to 1) & ptereload_req_pte_lat(ptepos_valid) & lru_tag4_dataout_q(3)) 
                        when (lru_tag4_dataout_q(4)='1' and lru_tag4_dataout_q(6)='0') 
               else (lru_tag4_dataout_q(0 to 2) & ptereload_req_pte_lat(ptepos_valid)) 
                        when (lru_tag4_dataout_q(4)='1' and lru_tag4_dataout_q(6)='1') 
               else lru_tag4_dataout_q(0 to 3);
tlb_tag4_ptereload_iprot(0 TO thdid_width-1) <=  ('0' & lru_tag4_dataout_q(9 to 11)) 
                        when (lru_tag4_dataout_q(4 to 5)="00") 
               else (lru_tag4_dataout_q(8) & '0' & lru_tag4_dataout_q(10 to 11)) 
                        when (lru_tag4_dataout_q(4 to 5)="01") 
               else (lru_tag4_dataout_q(8 to 9) & '0' & lru_tag4_dataout_q(11)) 
                        when (lru_tag4_dataout_q(4)='1' and lru_tag4_dataout_q(6)='0') 
               else (lru_tag4_dataout_q(8 to 10) & '0') 
                        when (lru_tag4_dataout_q(4)='1' and lru_tag4_dataout_q(6)='1') 
               else lru_tag4_dataout_q(8 to 11);
lru_write_d  <=  (others => '1') when ( (tlb_tag4_q(tagpos_type_derat)='1' or tlb_tag4_q(tagpos_type_ierat)='1') 
                              and tlb_tag4_q(tagpos_type_ptereload)='0'
                              and tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" 
                              and ((tlb_tag4_wayhit_q(0 to 3) /= "0000" and multihit='0') or 
                                    (xu_mm_xucr4_mmu_mchk_q='0' and xu_mm_ccr2_notlb_b='1' and (multihit='1' or or_reduce(tag4_parerr_q(0 to 4))='1'))) )  
          else (others => '1') when ( tlb_tag4_q(tagpos_type_snoop)='1' 
                              and tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" 
                              and (tlb_tag4_wayhit_q(0 to 3) /= "0000" or tlb_tag4_q(tagpos_is+1 to tagpos_is+3)="000") )  
          else (others => '1') when ( tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_pr)='0' and ex6_illeg_instr(1)='0'    
                              and (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not tlb_ctl_tag4_flush)/="0000" 
                              and ((or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and tlb_resv_match_vec)='1' 
                                         and tlb_tag4_q(tagpos_wq to tagpos_wq+1)="01" and mmucfg_twc='1')  
                                           or tlb_tag4_q(tagpos_wq to tagpos_wq+1)="00" or tlb_tag4_q(tagpos_wq to tagpos_wq+1)="11")  
                              and ((tlb_tag4_q(tagpos_gs)='0' and tlb_tag4_q(tagpos_atsel)='0') or     
                                     (tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_hes)='1' and tlb_tag4_q(tagpos_is+1)='0' 
                                        and tlb0cfg_gtwe='1' and tlb_tag4_epcr_dgtmi='0' and lrat_tag4_hit_status="1100"  
                                        and (((lru_tag4_dataout_q(0)='0' or lru_tag4_dataout_q(8)='0') and lru_tag4_dataout_q(4 to 5)="00")  
                                           or ((lru_tag4_dataout_q(1)='0' or lru_tag4_dataout_q(9)='0') and lru_tag4_dataout_q(4 to 5)="01")  
                                           or ((lru_tag4_dataout_q(2)='0' or lru_tag4_dataout_q(10)='0') and lru_tag4_dataout_q(4)='1' and lru_tag4_dataout_q(6)='0')    
                                           or ((lru_tag4_dataout_q(3)='0' or lru_tag4_dataout_q(11)='0') and lru_tag4_dataout_q(4)='1' and lru_tag4_dataout_q(6)='1')))) ) 
          else (others => ptereload_req_pte_lat(ptepos_valid)) when ( tlb_tag4_q(tagpos_type_ptereload)='1' 
                              and (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000") 
                              and (tlb_tag4_q(tagpos_gs)='0' or (tlb_tag4_q(tagpos_gs)='1' and lrat_tag4_hit_status="1100"))  
                              and (tlb_tag4_q(tagpos_wq to tagpos_wq+1)="10")   
                              and (tlb_tag4_q(tagpos_pt)='1')   
                              and (((lru_tag4_dataout_q(0)='0' or lru_tag4_dataout_q(8)='0') and lru_tag4_dataout_q(4 to 5)="00")  
                                 or ((lru_tag4_dataout_q(1)='0' or lru_tag4_dataout_q(9)='0') and lru_tag4_dataout_q(4 to 5)="01")  
                                 or ((lru_tag4_dataout_q(2)='0' or lru_tag4_dataout_q(10)='0') and lru_tag4_dataout_q(4)='1' and lru_tag4_dataout_q(6)='0')    
                                 or ((lru_tag4_dataout_q(3)='0' or lru_tag4_dataout_q(11)='0') and lru_tag4_dataout_q(4)='1' and lru_tag4_dataout_q(6)='1')) ) 
          else (others => '0');
lru_wr_addr_d  <=  tlb_addr4_q;
lru_update_clear_enab  <=  '1' when ( xu_mm_xucr4_mmu_mchk_q='0' and xu_mm_ccr2_notlb_b='1' and   
                                     ((tlb_tag4_q(tagpos_type_derat)='1' or tlb_tag4_q(tagpos_type_ierat)='1') and tlb_tag4_q(tagpos_type_ptereload)='0') and  
                                       (multihit='1' or or_reduce(tag4_parerr_q(0 to 4))='1') )
                    else '0';
lru_update_data_enab  <=  '1' when ( ((tlb_tag4_q(tagpos_type_derat)='1' or tlb_tag4_q(tagpos_type_ierat)='1') and tlb_tag4_q(tagpos_type_ptereload)='0' and 
                                         multihit='0' and or_reduce(tag4_parerr_q(0 to 4))='0') 
                                 or (tlb_tag4_q(tagpos_type_tlbwe)='1' and (tlb_tag4_q(tagpos_atsel)='0' or tlb_tag4_q(tagpos_gs)='1')) 
                                 or (tlb_tag4_q(tagpos_type_ptereload)='1')  
                                 or (tlb_tag4_q(tagpos_type_snoop)='1') )    
                   else '0';
lru_datain_d(0 TO 3) <=  (others => '0') when lru_update_clear_enab='1'
                     else ( lru_tag4_dataout_q(0 to 3) and 
                           (lru_tag4_dataout_q(8 to 11) or not(tlb_tag4_wayhit_q(0 to 3))) )
                           when tlb_tag4_q(tagpos_type_snoop)='1'  
                     else tlb_tag4_hes1_mas1_v(0 to thdid_width-1)
                           when tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_hes)='1'  
                     else tlb_tag4_hes0_mas1_v(0 to thdid_width-1)
                           when tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_hes)='0' 
                     else tlb_tag4_ptereload_v(0 to thdid_width-1)
                           when tlb_tag4_q(tagpos_type_ptereload)='1'  
                     else lru_tag4_dataout_q(0 to 3);
lru_datain_d(4 TO 6) <=  (others => '0') when lru_update_clear_enab='1'
                    else lru_update_data when lru_update_data_enab='1'
                    else lru_tag4_dataout_q(4 to 6);
lru_datain_alt_d(4 TO 6) <=  lru_update_data_alt when ((tlb_tag4_q(tagpos_type_derat)='1' or tlb_tag4_q(tagpos_type_ierat)='1' or 
                                 tlb_tag4_q(tagpos_type_snoop)='1') and tlb_tag4_q(tagpos_type_ptereload)='0') 
                    else lru_update_data when (tlb_tag4_q(tagpos_type_tlbwe)='1' and (tlb_tag4_q(tagpos_atsel)='0' or tlb_tag4_q(tagpos_gs)='1')) 
                    else lru_update_data when (tlb_tag4_q(tagpos_type_ptereload)='1') 
                    else lru_tag4_dataout_q(4 to 6);
lru_update_data_alt     <=  (lru_tag4_dataout_q(4 to 6) and (4 to 6 => not tlb_tag4_wayhit_q(4))) or
                          (lru_update_data_snoophit_eco and (4 to 6 => tlb_tag4_wayhit_q(4) and tlb_tag4_q(tagpos_type_snoop))) or
                          (lru_update_data_erathit_eco  and (4 to 6 => tlb_tag4_wayhit_q(4) and not tlb_tag4_q(tagpos_type_ptereload) 
                                    and (tlb_tag4_q(tagpos_type_derat) or tlb_tag4_q(tagpos_type_ierat))));
lru_datain_alt_d(7) <=  xor_reduce(lru_datain_d(0 to 3) & lru_datain_alt_d(4 to 6));
lru_update_data_snoophit_eco(0 TO 2) <=  "000" when (tlb_tag4_wayhit_q(0) and not lru_tag4_dataout_q(6) and not lru_tag4_dataout_q(8))='1'
                                   else "001" when (tlb_tag4_wayhit_q(0) and     lru_tag4_dataout_q(6) and not lru_tag4_dataout_q(8))='1'
                                   else "010" when (tlb_tag4_wayhit_q(1) and not lru_tag4_dataout_q(6) and not lru_tag4_dataout_q(9))='1'
                                   else "011" when (tlb_tag4_wayhit_q(1) and     lru_tag4_dataout_q(6) and not lru_tag4_dataout_q(9))='1'
                                   else "100" when (tlb_tag4_wayhit_q(2) and not lru_tag4_dataout_q(5) and not lru_tag4_dataout_q(10))='1'
                                   else "110" when (tlb_tag4_wayhit_q(2) and     lru_tag4_dataout_q(5) and not lru_tag4_dataout_q(10))='1'
                                   else "101" when (tlb_tag4_wayhit_q(3) and not lru_tag4_dataout_q(5) and not lru_tag4_dataout_q(11))='1'
                                   else "111" when (tlb_tag4_wayhit_q(3) and     lru_tag4_dataout_q(5) and not lru_tag4_dataout_q(11))='1'
                                   else lru_tag4_dataout_q(4 to 6);
lru_datain_alt_d(8) <=  xor_reduce(lru_datain_d(0 to 3) & lru_update_data_snoophit_eco(0 to 2));
lru_update_data_erathit_eco(0 TO 2) <=  "01" & lru_tag4_dataout_q(6)      when (tlb_tag4_wayhit_q(0) and not lru_tag4_dataout_q(9))='1'
                                   else '1' & lru_tag4_dataout_q(5) & '0' when (tlb_tag4_wayhit_q(0) and not lru_tag4_dataout_q(10))='1'
                                   else '1' & lru_tag4_dataout_q(5) & '1' when (tlb_tag4_wayhit_q(0) and not lru_tag4_dataout_q(11))='1'
                                   else '1' & lru_tag4_dataout_q(5) & '0' when (tlb_tag4_wayhit_q(1) and not lru_tag4_dataout_q(10))='1'
                                   else '1' & lru_tag4_dataout_q(5) & '1' when (tlb_tag4_wayhit_q(1) and not lru_tag4_dataout_q(11))='1'
                                   else "00" & lru_tag4_dataout_q(6)      when (tlb_tag4_wayhit_q(1) and not lru_tag4_dataout_q(8))='1'
                                   else '1' & lru_tag4_dataout_q(5) & '1' when (tlb_tag4_wayhit_q(2) and not lru_tag4_dataout_q(11))='1'
                                   else "00" & lru_tag4_dataout_q(6)      when (tlb_tag4_wayhit_q(2) and not lru_tag4_dataout_q(8))='1'
                                   else "01" & lru_tag4_dataout_q(6)      when (tlb_tag4_wayhit_q(2) and not lru_tag4_dataout_q(9))='1'
                                   else "00" & lru_tag4_dataout_q(6)      when (tlb_tag4_wayhit_q(3) and not lru_tag4_dataout_q(8))='1'
                                   else "01" & lru_tag4_dataout_q(6)      when (tlb_tag4_wayhit_q(3) and not lru_tag4_dataout_q(9))='1'
                                   else '1' & lru_tag4_dataout_q(5) & '0' when (tlb_tag4_wayhit_q(3) and not lru_tag4_dataout_q(10))='1'
                                   else lru_tag4_dataout_q(4 to 6);
lru_datain_alt_d(9) <=  xor_reduce(lru_datain_d(0 to 3) & lru_update_data_erathit_eco(0 to 2));
lru_datain_d(8 TO 11) <=  (others => '0') when lru_update_clear_enab='1'
                     else tlb_tag4_hes1_mas1_iprot(0 to thdid_width-1)
                           when tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_hes)='1'  
                     else tlb_tag4_hes0_mas1_iprot(0 to thdid_width-1)
                           when tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_hes)='0' 
                     else tlb_tag4_ptereload_iprot(0 to thdid_width-1)
                           when tlb_tag4_q(tagpos_type_ptereload)='1'  
                     else lru_tag4_dataout_q(8 to 11);
lru_datain_d(12 TO 14) <=  (others => '0');
lru_datain_d(7) <=  xor_reduce(lru_datain_d(0 to 6));
lru_datain_d(15) <=  xor_reduce(lru_datain_d(8 to 14) & mmucr1_q(pos_lru_pei));
lru_calc_par(0) <=  xor_reduce(lru_tag3_dataout_q(0 to 6));
lru_calc_par(1) <=  xor_reduce(lru_tag3_dataout_q(8 to 14));
tag4_parerr_d(4) <=  or_reduce(lru_calc_par(0 to 1) xor (lru_tag3_dataout_q(7) & lru_tag3_dataout_q(15)));
tlb_tag4_parerr_enab  <=  or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and 
                         (or_reduce(tlb_tag4_q(tagpos_type_derat to tagpos_type_tlbsrx)) or tlb_tag4_q(tagpos_type_tlbre));
MQQ1:LRU_UPDATE_DATA_PT(1) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_WAYHIT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) & LRU_TAG4_DATAOUT_Q(10) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("011111110"));
MQQ2:LRU_UPDATE_DATA_PT(2) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(3) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(9) & LRU_TAG4_DATAOUT_Q(10) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("101111110"));
MQQ3:LRU_UPDATE_DATA_PT(3) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(10) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("111111010"));
MQQ4:LRU_UPDATE_DATA_PT(4) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(10) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("1111010"));
MQQ5:LRU_UPDATE_DATA_PT(5) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(10) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("0001111110"));
MQQ6:LRU_UPDATE_DATA_PT(6) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(10) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("1000111110"));
MQQ7:LRU_UPDATE_DATA_PT(7) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & TLB_TAG4_WAYHIT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(10) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("100111110"));
MQQ8:LRU_UPDATE_DATA_PT(8) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(10) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("000111110"));
MQQ9:LRU_UPDATE_DATA_PT(9) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(10) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("100111110"));
MQQ10:LRU_UPDATE_DATA_PT(10) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("0001111110"));
MQQ11:LRU_UPDATE_DATA_PT(11) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(6) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("111111100"));
MQQ12:LRU_UPDATE_DATA_PT(12) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(6) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("1111100"));
MQQ13:LRU_UPDATE_DATA_PT(13) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(6) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("1111010"));
MQQ14:LRU_UPDATE_DATA_PT(14) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("111010"));
MQQ15:LRU_UPDATE_DATA_PT(15) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("11110110"));
MQQ16:LRU_UPDATE_DATA_PT(16) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("110110"));
MQQ17:LRU_UPDATE_DATA_PT(17) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("11101110"));
MQQ18:LRU_UPDATE_DATA_PT(18) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("101110"));
MQQ19:LRU_UPDATE_DATA_PT(19) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(6) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("0000110"));
MQQ20:LRU_UPDATE_DATA_PT(20) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("100110"));
MQQ21:LRU_UPDATE_DATA_PT(21) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("1111111000"));
MQQ22:LRU_UPDATE_DATA_PT(22) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("11111000"));
MQQ23:LRU_UPDATE_DATA_PT(23) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("1111100"));
MQQ24:LRU_UPDATE_DATA_PT(24) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("11100"));
MQQ25:LRU_UPDATE_DATA_PT(25) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & TLB_TAG4_WAYHIT_Q(2) & 
    TLB_TAG4_WAYHIT_Q(3) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("100011110"));
MQQ26:LRU_UPDATE_DATA_PT(26) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("10101110"));
MQQ27:LRU_UPDATE_DATA_PT(27) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_WAYHIT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) & LRU_TAG4_DATAOUT_Q(10) & 
    LRU_TAG4_DATAOUT_Q(11) ) , STD_ULOGIC_VECTOR'("011111011"));
MQQ28:LRU_UPDATE_DATA_PT(28) <=
    Eq(( TLB_TAG4_HES_SIG & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(10) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("111111"));
MQQ29:LRU_UPDATE_DATA_PT(29) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(10) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("011111"));
MQQ30:LRU_UPDATE_DATA_PT(30) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(10) & LRU_TAG4_DATAOUT_Q(11)
     ) , STD_ULOGIC_VECTOR'("1001111111"));
MQQ31:LRU_UPDATE_DATA_PT(31) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_WAYHIT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(8) & LRU_TAG4_DATAOUT_Q(9) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("0111110"));
MQQ32:LRU_UPDATE_DATA_PT(32) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(2) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(9) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("1011110"));
MQQ33:LRU_UPDATE_DATA_PT(33) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("1111111000"));
MQQ34:LRU_UPDATE_DATA_PT(34) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("11111000"));
MQQ35:LRU_UPDATE_DATA_PT(35) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("11111100"));
MQQ36:LRU_UPDATE_DATA_PT(36) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("111100"));
MQQ37:LRU_UPDATE_DATA_PT(37) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("000111110"));
MQQ38:LRU_UPDATE_DATA_PT(38) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("100011110"));
MQQ39:LRU_UPDATE_DATA_PT(39) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("111100"));
MQQ40:LRU_UPDATE_DATA_PT(40) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("1100"));
MQQ41:LRU_UPDATE_DATA_PT(41) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("111010"));
MQQ42:LRU_UPDATE_DATA_PT(42) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("1010"));
MQQ43:LRU_UPDATE_DATA_PT(43) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & TLB_TAG4_WAYHIT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("1001110"));
MQQ44:LRU_UPDATE_DATA_PT(44) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("0001110"));
MQQ45:LRU_UPDATE_DATA_PT(45) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("1001110"));
MQQ46:LRU_UPDATE_DATA_PT(46) <=
    Eq(( TLB_TAG4_HES_SIG & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("111111"));
MQQ47:LRU_UPDATE_DATA_PT(47) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("011111"));
MQQ48:LRU_UPDATE_DATA_PT(48) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("1011111111"));
MQQ49:LRU_UPDATE_DATA_PT(49) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("111011"));
MQQ50:LRU_UPDATE_DATA_PT(50) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(6) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("11011"));
MQQ51:LRU_UPDATE_DATA_PT(51) <=
    Eq(( LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ52:LRU_UPDATE_DATA_PT(52) <=
    Eq(( LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ53:LRU_UPDATE_DATA_PT(53) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_TYPE_SIG(7) & 
    TLB_TAG4_WAYHIT_Q(3) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("000111"));
MQQ54:LRU_UPDATE_DATA_PT(54) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_TYPE_SIG(7) & 
    TLB_TAG4_WAYHIT_Q(2) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("001111"));
MQQ55:LRU_UPDATE_DATA_PT(55) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(10)
     ) , STD_ULOGIC_VECTOR'("100111"));
MQQ56:LRU_UPDATE_DATA_PT(56) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & TLB_TAG4_WAYHIT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("100111101"));
MQQ57:LRU_UPDATE_DATA_PT(57) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("1111101"));
MQQ58:LRU_UPDATE_DATA_PT(58) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(10) ) , STD_ULOGIC_VECTOR'("11101"));
MQQ59:LRU_UPDATE_DATA_PT(59) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("1111110"));
MQQ60:LRU_UPDATE_DATA_PT(60) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("11110"));
MQQ61:LRU_UPDATE_DATA_PT(61) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(8) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("0001111110"));
MQQ62:LRU_UPDATE_DATA_PT(62) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("000111110"));
MQQ63:LRU_UPDATE_DATA_PT(63) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("1111110"));
MQQ64:LRU_UPDATE_DATA_PT(64) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(8) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("1010111110"));
MQQ65:LRU_UPDATE_DATA_PT(65) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("101111110"));
MQQ66:LRU_UPDATE_DATA_PT(66) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("1111111100"));
MQQ67:LRU_UPDATE_DATA_PT(67) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("11111100"));
MQQ68:LRU_UPDATE_DATA_PT(68) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_TYPE_SIG(7) & 
    TLB_TAG4_WAYHIT_Q(0) & TLB_TAG4_WAYHIT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(6) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("0011110"));
MQQ69:LRU_UPDATE_DATA_PT(69) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & LRU_TAG4_DATAOUT_Q(6) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ70:LRU_UPDATE_DATA_PT(70) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(5) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("111111000"));
MQQ71:LRU_UPDATE_DATA_PT(71) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(5) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("1111000"));
MQQ72:LRU_UPDATE_DATA_PT(72) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(5) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("1111110"));
MQQ73:LRU_UPDATE_DATA_PT(73) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(5) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("11110"));
MQQ74:LRU_UPDATE_DATA_PT(74) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_IS_SIG(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(5) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("0111010"));
MQQ75:LRU_UPDATE_DATA_PT(75) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(5) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("0000110"));
MQQ76:LRU_UPDATE_DATA_PT(76) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("101110"));
MQQ77:LRU_UPDATE_DATA_PT(77) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("00011110"));
MQQ78:LRU_UPDATE_DATA_PT(78) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("10001110"));
MQQ79:LRU_UPDATE_DATA_PT(79) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("11100"));
MQQ80:LRU_UPDATE_DATA_PT(80) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("100"));
MQQ81:LRU_UPDATE_DATA_PT(81) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ82:LRU_UPDATE_DATA_PT(82) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_IS_SIG(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(5) & 
    LRU_TAG4_DATAOUT_Q(8) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("01110111"));
MQQ83:LRU_UPDATE_DATA_PT(83) <=
    Eq(( TLB_TAG4_HES_SIG & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(8) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("111111"));
MQQ84:LRU_UPDATE_DATA_PT(84) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(8) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("011111"));
MQQ85:LRU_UPDATE_DATA_PT(85) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("11011"));
MQQ86:LRU_UPDATE_DATA_PT(86) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("1111011"));
MQQ87:LRU_UPDATE_DATA_PT(87) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("11011"));
MQQ88:LRU_UPDATE_DATA_PT(88) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(8) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("00011111"));
MQQ89:LRU_UPDATE_DATA_PT(89) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(8) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("1011111"));
MQQ90:LRU_UPDATE_DATA_PT(90) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("101111"));
MQQ91:LRU_UPDATE_DATA_PT(91) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(9)
     ) , STD_ULOGIC_VECTOR'("10111101"));
MQQ92:LRU_UPDATE_DATA_PT(92) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(9) ) , STD_ULOGIC_VECTOR'("1011101"));
MQQ93:LRU_UPDATE_DATA_PT(93) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("1111111100"));
MQQ94:LRU_UPDATE_DATA_PT(94) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("11111100"));
MQQ95:LRU_UPDATE_DATA_PT(95) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(6) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("1110"));
MQQ96:LRU_UPDATE_DATA_PT(96) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & TLB_TAG4_WAYHIT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("00011110"));
MQQ97:LRU_UPDATE_DATA_PT(97) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("10101110"));
MQQ98:LRU_UPDATE_DATA_PT(98) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(5) & 
    LRU_TAG4_DATAOUT_Q(8) ) , STD_ULOGIC_VECTOR'("1111001"));
MQQ99:LRU_UPDATE_DATA_PT(99) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("111111"));
MQQ100:LRU_UPDATE_DATA_PT(100) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(5) & 
    LRU_TAG4_DATAOUT_Q(8) ) , STD_ULOGIC_VECTOR'("11111"));
MQQ101:LRU_UPDATE_DATA_PT(101) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_TYPE_SIG(7) & 
    TLB_TAG4_WAYHIT_Q(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("000111"));
MQQ102:LRU_UPDATE_DATA_PT(102) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("101111"));
MQQ103:LRU_UPDATE_DATA_PT(103) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(5) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ104:LRU_UPDATE_DATA_PT(104) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(4) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("101111"));
MQQ105:LRU_UPDATE_DATA_PT(105) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(8) ) , STD_ULOGIC_VECTOR'("1111101"));
MQQ106:LRU_UPDATE_DATA_PT(106) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(8)
     ) , STD_ULOGIC_VECTOR'("111101"));
MQQ107:LRU_UPDATE_DATA_PT(107) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(8) ) , STD_ULOGIC_VECTOR'("11101"));
MQQ108:LRU_UPDATE_DATA_PT(108) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(8) ) , STD_ULOGIC_VECTOR'("11101"));
MQQ109:LRU_UPDATE_DATA_PT(109) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(8) ) , STD_ULOGIC_VECTOR'("101"));
MQQ110:LRU_UPDATE_DATA_PT(110) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(4) & 
    LRU_TAG4_DATAOUT_Q(6) ) , STD_ULOGIC_VECTOR'("11001"));
MQQ111:LRU_UPDATE_DATA_PT(111) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_TYPE_SIG(7) & 
    TLB_TAG4_WAYHIT_Q(0) & TLB_TAG4_WAYHIT_Q(1) & 
    TLB_TAG4_WAYHIT_Q(2) & TLB_TAG4_WAYHIT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(6)
     ) , STD_ULOGIC_VECTOR'("00000011"));
MQQ112:LRU_UPDATE_DATA_PT(112) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(6)
     ) , STD_ULOGIC_VECTOR'("1011"));
MQQ113:LRU_UPDATE_DATA_PT(113) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(6) ) , STD_ULOGIC_VECTOR'("11011"));
MQQ114:LRU_UPDATE_DATA_PT(114) <=
    Eq(( LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(6) ) , STD_ULOGIC_VECTOR'("001"));
MQQ115:LRU_UPDATE_DATA_PT(115) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_IS_SIG(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(6)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ116:LRU_UPDATE_DATA_PT(116) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(2) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(6) ) , STD_ULOGIC_VECTOR'("10001"));
MQQ117:LRU_UPDATE_DATA_PT(117) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(6) ) , STD_ULOGIC_VECTOR'("10101"));
MQQ118:LRU_UPDATE_DATA_PT(118) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_TYPE_SIG(7) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(6)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ119:LRU_UPDATE_DATA_PT(119) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_IS_SIG(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(6)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ120:LRU_UPDATE_DATA_PT(120) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(2) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(6) ) , STD_ULOGIC_VECTOR'("10101"));
MQQ121:LRU_UPDATE_DATA_PT(121) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(6) ) , STD_ULOGIC_VECTOR'("10101"));
MQQ122:LRU_UPDATE_DATA_PT(122) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_TYPE_SIG(7) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(6)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ123:LRU_UPDATE_DATA_PT(123) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & TLB_TAG4_WAYHIT_Q(2) & 
    TLB_TAG4_WAYHIT_Q(3) & LRU_TAG4_DATAOUT_Q(6)
     ) , STD_ULOGIC_VECTOR'("100001"));
MQQ124:LRU_UPDATE_DATA_PT(124) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_IS_SIG(0) & 
    LRU_TAG4_DATAOUT_Q(6) ) , STD_ULOGIC_VECTOR'("10001"));
MQQ125:LRU_UPDATE_DATA_PT(125) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(5) ) , STD_ULOGIC_VECTOR'("0011101"));
MQQ126:LRU_UPDATE_DATA_PT(126) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_ESEL_SIG(1) & 
    TLB_TAG4_ESEL_SIG(2) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(5) ) , STD_ULOGIC_VECTOR'("0011101"));
MQQ127:LRU_UPDATE_DATA_PT(127) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(3) & LRU_TAG4_DATAOUT_Q(5)
     ) , STD_ULOGIC_VECTOR'("001101"));
MQQ128:LRU_UPDATE_DATA_PT(128) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_ESEL_SIG(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(5)
     ) , STD_ULOGIC_VECTOR'("011101"));
MQQ129:LRU_UPDATE_DATA_PT(129) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_HES_SIG & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(5)
     ) , STD_ULOGIC_VECTOR'("011101"));
MQQ130:LRU_UPDATE_DATA_PT(130) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(5)
     ) , STD_ULOGIC_VECTOR'("001101"));
MQQ131:LRU_UPDATE_DATA_PT(131) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(5) ) , STD_ULOGIC_VECTOR'("1000101"));
MQQ132:LRU_UPDATE_DATA_PT(132) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_TYPE_SIG(7) & 
    TLB_TAG4_WAYHIT_Q(0) & TLB_TAG4_WAYHIT_Q(1) & 
    TLB_TAG4_WAYHIT_Q(2) & TLB_TAG4_WAYHIT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(5)
     ) , STD_ULOGIC_VECTOR'("00000011"));
MQQ133:LRU_UPDATE_DATA_PT(133) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(5)
     ) , STD_ULOGIC_VECTOR'("1011"));
MQQ134:LRU_UPDATE_DATA_PT(134) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_ESEL_SIG(1) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(5) ) , STD_ULOGIC_VECTOR'("11011"));
MQQ135:LRU_UPDATE_DATA_PT(135) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(5) ) , STD_ULOGIC_VECTOR'("11011"));
MQQ136:LRU_UPDATE_DATA_PT(136) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & TLB_TAG4_WAYHIT_Q(2) & 
    TLB_TAG4_WAYHIT_Q(3) & LRU_TAG4_DATAOUT_Q(5)
     ) , STD_ULOGIC_VECTOR'("100001"));
MQQ137:LRU_UPDATE_DATA_PT(137) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(4)
     ) , STD_ULOGIC_VECTOR'("110101"));
MQQ138:LRU_UPDATE_DATA_PT(138) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_TYPE_SIG(7) & 
    TLB_TAG4_WAYHIT_Q(0) & TLB_TAG4_WAYHIT_Q(1) & 
    TLB_TAG4_WAYHIT_Q(2) & TLB_TAG4_WAYHIT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(4) ) , STD_ULOGIC_VECTOR'("000000111"));
MQQ139:LRU_UPDATE_DATA_PT(139) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(4)
     ) , STD_ULOGIC_VECTOR'("100111"));
MQQ140:LRU_UPDATE_DATA_PT(140) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(4)
     ) , STD_ULOGIC_VECTOR'("110111"));
MQQ141:LRU_UPDATE_DATA_PT(141) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & TLB_TAG4_WAYHIT_Q(2) & 
    TLB_TAG4_WAYHIT_Q(3) & LRU_TAG4_DATAOUT_Q(4)
     ) , STD_ULOGIC_VECTOR'("100001"));
MQQ142:LRU_UPDATE_DATA_PT(142) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) ) , STD_ULOGIC_VECTOR'("1111100"));
MQQ143:LRU_UPDATE_DATA_PT(143) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) ) , STD_ULOGIC_VECTOR'("11100"));
MQQ144:LRU_UPDATE_DATA_PT(144) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) ) , STD_ULOGIC_VECTOR'("1111010"));
MQQ145:LRU_UPDATE_DATA_PT(145) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) ) , STD_ULOGIC_VECTOR'("11010"));
MQQ146:LRU_UPDATE_DATA_PT(146) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) ) , STD_ULOGIC_VECTOR'("1110110"));
MQQ147:LRU_UPDATE_DATA_PT(147) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ148:LRU_UPDATE_DATA_PT(148) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & TLB_TAG4_WAYHIT_Q(2) & 
    TLB_TAG4_WAYHIT_Q(3) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) ) , STD_ULOGIC_VECTOR'("100011110"));
MQQ149:LRU_UPDATE_DATA_PT(149) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(3) ) , STD_ULOGIC_VECTOR'("0001110"));
MQQ150:LRU_UPDATE_DATA_PT(150) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3)
     ) , STD_ULOGIC_VECTOR'("10001110"));
MQQ151:LRU_UPDATE_DATA_PT(151) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) & LRU_TAG4_DATAOUT_Q(3)
     ) , STD_ULOGIC_VECTOR'("10011110"));
MQQ152:LRU_UPDATE_DATA_PT(152) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(3)
     ) , STD_ULOGIC_VECTOR'("10101110"));
MQQ153:LRU_UPDATE_DATA_PT(153) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(3) ) , STD_ULOGIC_VECTOR'("1000100"));
MQQ154:LRU_UPDATE_DATA_PT(154) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2)
     ) , STD_ULOGIC_VECTOR'("111100"));
MQQ155:LRU_UPDATE_DATA_PT(155) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2)
     ) , STD_ULOGIC_VECTOR'("1100"));
MQQ156:LRU_UPDATE_DATA_PT(156) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2)
     ) , STD_ULOGIC_VECTOR'("111010"));
MQQ157:LRU_UPDATE_DATA_PT(157) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2)
     ) , STD_ULOGIC_VECTOR'("1010"));
MQQ158:LRU_UPDATE_DATA_PT(158) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & TLB_TAG4_WAYHIT_Q(3) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) ) , STD_ULOGIC_VECTOR'("1001110"));
MQQ159:LRU_UPDATE_DATA_PT(159) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & TLB_TAG4_WAYHIT_Q(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) ) , STD_ULOGIC_VECTOR'("1001110"));
MQQ160:LRU_UPDATE_DATA_PT(160) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) ) , STD_ULOGIC_VECTOR'("1011110"));
MQQ161:LRU_UPDATE_DATA_PT(161) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2)
     ) , STD_ULOGIC_VECTOR'("000110"));
MQQ162:LRU_UPDATE_DATA_PT(162) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(1) & 
    LRU_TAG4_DATAOUT_Q(2) ) , STD_ULOGIC_VECTOR'("1000110"));
MQQ163:LRU_UPDATE_DATA_PT(163) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) ) , STD_ULOGIC_VECTOR'("1000100"));
MQQ164:LRU_UPDATE_DATA_PT(164) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(2) ) , STD_ULOGIC_VECTOR'("1001110"));
MQQ165:LRU_UPDATE_DATA_PT(165) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) & LRU_TAG4_DATAOUT_Q(2)
     ) , STD_ULOGIC_VECTOR'("10110111"));
MQQ166:LRU_UPDATE_DATA_PT(166) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) ) , STD_ULOGIC_VECTOR'("11100"));
MQQ167:LRU_UPDATE_DATA_PT(167) <=
    Eq(( TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) ) , STD_ULOGIC_VECTOR'("100"));
MQQ168:LRU_UPDATE_DATA_PT(168) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(3) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ169:LRU_UPDATE_DATA_PT(169) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(2) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ170:LRU_UPDATE_DATA_PT(170) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_WAYHIT_Q(0) & 
    TLB_TAG4_WAYHIT_Q(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ171:LRU_UPDATE_DATA_PT(171) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ172:LRU_UPDATE_DATA_PT(172) <=
    Eq(( TLB_TAG4_TYPE_SIG(4) & TLB_TAG4_TYPE_SIG(6) & 
    TLB_TAG4_TYPE_SIG(7) & LRU_TAG4_DATAOUT_Q(0) & 
    LRU_TAG4_DATAOUT_Q(1) ) , STD_ULOGIC_VECTOR'("00010"));
MQQ173:LRU_UPDATE_DATA_PT(173) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(1)
     ) , STD_ULOGIC_VECTOR'("100010"));
MQQ174:LRU_UPDATE_DATA_PT(174) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_IS_SIG(0) & 
    LRU_TAG4_DATAOUT_Q(0) & LRU_TAG4_DATAOUT_Q(1)
     ) , STD_ULOGIC_VECTOR'("101011"));
MQQ175:LRU_UPDATE_DATA_PT(175) <=
    Eq(( TLB_TAG4_TYPE_SIG(6) & TLB_TAG4_HES_SIG & 
    TLB_TAG4_ESEL_SIG(1) & TLB_TAG4_ESEL_SIG(2) & 
    TLB_TAG4_IS_SIG(0) & LRU_TAG4_DATAOUT_Q(0)
     ) , STD_ULOGIC_VECTOR'("100101"));
MQQ176:LRU_UPDATE_DATA(0) <= 
    (LRU_UPDATE_DATA_PT(1) OR LRU_UPDATE_DATA_PT(2)
     OR LRU_UPDATE_DATA_PT(3) OR LRU_UPDATE_DATA_PT(4)
     OR LRU_UPDATE_DATA_PT(5) OR LRU_UPDATE_DATA_PT(6)
     OR LRU_UPDATE_DATA_PT(7) OR LRU_UPDATE_DATA_PT(8)
     OR LRU_UPDATE_DATA_PT(9) OR LRU_UPDATE_DATA_PT(10)
     OR LRU_UPDATE_DATA_PT(15) OR LRU_UPDATE_DATA_PT(16)
     OR LRU_UPDATE_DATA_PT(17) OR LRU_UPDATE_DATA_PT(18)
     OR LRU_UPDATE_DATA_PT(25) OR LRU_UPDATE_DATA_PT(31)
     OR LRU_UPDATE_DATA_PT(32) OR LRU_UPDATE_DATA_PT(35)
     OR LRU_UPDATE_DATA_PT(36) OR LRU_UPDATE_DATA_PT(37)
     OR LRU_UPDATE_DATA_PT(38) OR LRU_UPDATE_DATA_PT(39)
     OR LRU_UPDATE_DATA_PT(40) OR LRU_UPDATE_DATA_PT(41)
     OR LRU_UPDATE_DATA_PT(42) OR LRU_UPDATE_DATA_PT(43)
     OR LRU_UPDATE_DATA_PT(44) OR LRU_UPDATE_DATA_PT(45)
     OR LRU_UPDATE_DATA_PT(56) OR LRU_UPDATE_DATA_PT(82)
     OR LRU_UPDATE_DATA_PT(83) OR LRU_UPDATE_DATA_PT(84)
     OR LRU_UPDATE_DATA_PT(85) OR LRU_UPDATE_DATA_PT(86)
     OR LRU_UPDATE_DATA_PT(87) OR LRU_UPDATE_DATA_PT(88)
     OR LRU_UPDATE_DATA_PT(89) OR LRU_UPDATE_DATA_PT(90)
     OR LRU_UPDATE_DATA_PT(91) OR LRU_UPDATE_DATA_PT(92)
     OR LRU_UPDATE_DATA_PT(98) OR LRU_UPDATE_DATA_PT(104)
     OR LRU_UPDATE_DATA_PT(105) OR LRU_UPDATE_DATA_PT(106)
     OR LRU_UPDATE_DATA_PT(138) OR LRU_UPDATE_DATA_PT(139)
     OR LRU_UPDATE_DATA_PT(140) OR LRU_UPDATE_DATA_PT(141)
     OR LRU_UPDATE_DATA_PT(142) OR LRU_UPDATE_DATA_PT(143)
     OR LRU_UPDATE_DATA_PT(144) OR LRU_UPDATE_DATA_PT(145)
     OR LRU_UPDATE_DATA_PT(146) OR LRU_UPDATE_DATA_PT(147)
     OR LRU_UPDATE_DATA_PT(148) OR LRU_UPDATE_DATA_PT(149)
     OR LRU_UPDATE_DATA_PT(150) OR LRU_UPDATE_DATA_PT(151)
     OR LRU_UPDATE_DATA_PT(152) OR LRU_UPDATE_DATA_PT(154)
     OR LRU_UPDATE_DATA_PT(155) OR LRU_UPDATE_DATA_PT(156)
     OR LRU_UPDATE_DATA_PT(157) OR LRU_UPDATE_DATA_PT(158)
     OR LRU_UPDATE_DATA_PT(159) OR LRU_UPDATE_DATA_PT(160)
     OR LRU_UPDATE_DATA_PT(161) OR LRU_UPDATE_DATA_PT(162)
     OR LRU_UPDATE_DATA_PT(164) OR LRU_UPDATE_DATA_PT(174)
    );
MQQ177:LRU_UPDATE_DATA(1) <= 
    (LRU_UPDATE_DATA_PT(5) OR LRU_UPDATE_DATA_PT(6)
     OR LRU_UPDATE_DATA_PT(21) OR LRU_UPDATE_DATA_PT(22)
     OR LRU_UPDATE_DATA_PT(27) OR LRU_UPDATE_DATA_PT(28)
     OR LRU_UPDATE_DATA_PT(29) OR LRU_UPDATE_DATA_PT(30)
     OR LRU_UPDATE_DATA_PT(33) OR LRU_UPDATE_DATA_PT(34)
     OR LRU_UPDATE_DATA_PT(37) OR LRU_UPDATE_DATA_PT(38)
     OR LRU_UPDATE_DATA_PT(59) OR LRU_UPDATE_DATA_PT(60)
     OR LRU_UPDATE_DATA_PT(61) OR LRU_UPDATE_DATA_PT(62)
     OR LRU_UPDATE_DATA_PT(63) OR LRU_UPDATE_DATA_PT(64)
     OR LRU_UPDATE_DATA_PT(65) OR LRU_UPDATE_DATA_PT(70)
     OR LRU_UPDATE_DATA_PT(71) OR LRU_UPDATE_DATA_PT(72)
     OR LRU_UPDATE_DATA_PT(73) OR LRU_UPDATE_DATA_PT(74)
     OR LRU_UPDATE_DATA_PT(75) OR LRU_UPDATE_DATA_PT(76)
     OR LRU_UPDATE_DATA_PT(77) OR LRU_UPDATE_DATA_PT(78)
     OR LRU_UPDATE_DATA_PT(79) OR LRU_UPDATE_DATA_PT(80)
     OR LRU_UPDATE_DATA_PT(81) OR LRU_UPDATE_DATA_PT(82)
     OR LRU_UPDATE_DATA_PT(99) OR LRU_UPDATE_DATA_PT(100)
     OR LRU_UPDATE_DATA_PT(101) OR LRU_UPDATE_DATA_PT(102)
     OR LRU_UPDATE_DATA_PT(103) OR LRU_UPDATE_DATA_PT(107)
     OR LRU_UPDATE_DATA_PT(108) OR LRU_UPDATE_DATA_PT(109)
     OR LRU_UPDATE_DATA_PT(125) OR LRU_UPDATE_DATA_PT(126)
     OR LRU_UPDATE_DATA_PT(127) OR LRU_UPDATE_DATA_PT(128)
     OR LRU_UPDATE_DATA_PT(129) OR LRU_UPDATE_DATA_PT(130)
     OR LRU_UPDATE_DATA_PT(131) OR LRU_UPDATE_DATA_PT(132)
     OR LRU_UPDATE_DATA_PT(133) OR LRU_UPDATE_DATA_PT(134)
     OR LRU_UPDATE_DATA_PT(135) OR LRU_UPDATE_DATA_PT(136)
     OR LRU_UPDATE_DATA_PT(137) OR LRU_UPDATE_DATA_PT(153)
     OR LRU_UPDATE_DATA_PT(163) OR LRU_UPDATE_DATA_PT(166)
     OR LRU_UPDATE_DATA_PT(167) OR LRU_UPDATE_DATA_PT(168)
     OR LRU_UPDATE_DATA_PT(169) OR LRU_UPDATE_DATA_PT(170)
     OR LRU_UPDATE_DATA_PT(171) OR LRU_UPDATE_DATA_PT(172)
     OR LRU_UPDATE_DATA_PT(173) OR LRU_UPDATE_DATA_PT(175)
    );
MQQ178:LRU_UPDATE_DATA(2) <= 
    (LRU_UPDATE_DATA_PT(1) OR LRU_UPDATE_DATA_PT(2)
     OR LRU_UPDATE_DATA_PT(3) OR LRU_UPDATE_DATA_PT(4)
     OR LRU_UPDATE_DATA_PT(5) OR LRU_UPDATE_DATA_PT(6)
     OR LRU_UPDATE_DATA_PT(7) OR LRU_UPDATE_DATA_PT(8)
     OR LRU_UPDATE_DATA_PT(9) OR LRU_UPDATE_DATA_PT(10)
     OR LRU_UPDATE_DATA_PT(11) OR LRU_UPDATE_DATA_PT(12)
     OR LRU_UPDATE_DATA_PT(13) OR LRU_UPDATE_DATA_PT(14)
     OR LRU_UPDATE_DATA_PT(15) OR LRU_UPDATE_DATA_PT(16)
     OR LRU_UPDATE_DATA_PT(17) OR LRU_UPDATE_DATA_PT(18)
     OR LRU_UPDATE_DATA_PT(19) OR LRU_UPDATE_DATA_PT(20)
     OR LRU_UPDATE_DATA_PT(23) OR LRU_UPDATE_DATA_PT(24)
     OR LRU_UPDATE_DATA_PT(25) OR LRU_UPDATE_DATA_PT(26)
     OR LRU_UPDATE_DATA_PT(46) OR LRU_UPDATE_DATA_PT(47)
     OR LRU_UPDATE_DATA_PT(48) OR LRU_UPDATE_DATA_PT(49)
     OR LRU_UPDATE_DATA_PT(50) OR LRU_UPDATE_DATA_PT(51)
     OR LRU_UPDATE_DATA_PT(52) OR LRU_UPDATE_DATA_PT(53)
     OR LRU_UPDATE_DATA_PT(54) OR LRU_UPDATE_DATA_PT(55)
     OR LRU_UPDATE_DATA_PT(56) OR LRU_UPDATE_DATA_PT(57)
     OR LRU_UPDATE_DATA_PT(58) OR LRU_UPDATE_DATA_PT(61)
     OR LRU_UPDATE_DATA_PT(64) OR LRU_UPDATE_DATA_PT(66)
     OR LRU_UPDATE_DATA_PT(67) OR LRU_UPDATE_DATA_PT(68)
     OR LRU_UPDATE_DATA_PT(69) OR LRU_UPDATE_DATA_PT(91)
     OR LRU_UPDATE_DATA_PT(93) OR LRU_UPDATE_DATA_PT(94)
     OR LRU_UPDATE_DATA_PT(95) OR LRU_UPDATE_DATA_PT(96)
     OR LRU_UPDATE_DATA_PT(97) OR LRU_UPDATE_DATA_PT(105)
     OR LRU_UPDATE_DATA_PT(110) OR LRU_UPDATE_DATA_PT(111)
     OR LRU_UPDATE_DATA_PT(112) OR LRU_UPDATE_DATA_PT(113)
     OR LRU_UPDATE_DATA_PT(114) OR LRU_UPDATE_DATA_PT(115)
     OR LRU_UPDATE_DATA_PT(116) OR LRU_UPDATE_DATA_PT(117)
     OR LRU_UPDATE_DATA_PT(118) OR LRU_UPDATE_DATA_PT(119)
     OR LRU_UPDATE_DATA_PT(120) OR LRU_UPDATE_DATA_PT(121)
     OR LRU_UPDATE_DATA_PT(122) OR LRU_UPDATE_DATA_PT(123)
     OR LRU_UPDATE_DATA_PT(124) OR LRU_UPDATE_DATA_PT(142)
     OR LRU_UPDATE_DATA_PT(143) OR LRU_UPDATE_DATA_PT(144)
     OR LRU_UPDATE_DATA_PT(145) OR LRU_UPDATE_DATA_PT(146)
     OR LRU_UPDATE_DATA_PT(147) OR LRU_UPDATE_DATA_PT(148)
     OR LRU_UPDATE_DATA_PT(149) OR LRU_UPDATE_DATA_PT(150)
     OR LRU_UPDATE_DATA_PT(151) OR LRU_UPDATE_DATA_PT(152)
     OR LRU_UPDATE_DATA_PT(165));

gen64_tlb_datain: if rs_data_width = 64 generate
tlb_datain_lo_tlbwe_0_nopar(0 TO tlb_word_width-10-1) <=  
                    (tlb_tag4_q(tagpos_epn to tagpos_epn+31) and (0 to 31 => tlb_tag4_q(tagpos_cm))) & tlb_tag4_q(tagpos_epn+32 to tagpos_epn+51) & tlb_tag4_q(tagpos_size to tagpos_size+3) & mmucr3_0(60   to 63) & 
                     mmucr3_0(54   to 55) & (mmucr3_0(52)   and tlb_tag4_q(tagpos_is+1)) & or_reduce(tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1)) &
                     "00" & tlb_tag4_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_datain_lo_tlbwe_1_nopar(0 TO tlb_word_width-10-1) <=  
                    (tlb_tag4_q(tagpos_epn to tagpos_epn+31) and (0 to 31 => tlb_tag4_q(tagpos_cm))) & tlb_tag4_q(tagpos_epn+32 to tagpos_epn+51) & tlb_tag4_q(tagpos_size to tagpos_size+3) & mmucr3_1(60   to 63) & 
                     mmucr3_1(54   to 55) & (mmucr3_1(52)   and tlb_tag4_q(tagpos_is+1)) & or_reduce(tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1)) &
                     "00" & tlb_tag4_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_datain_lo_tlbwe_2_nopar(0 TO tlb_word_width-10-1) <=  
                    (tlb_tag4_q(tagpos_epn to tagpos_epn+31) and (0 to 31 => tlb_tag4_q(tagpos_cm))) & tlb_tag4_q(tagpos_epn+32 to tagpos_epn+51) & tlb_tag4_q(tagpos_size to tagpos_size+3) & mmucr3_2(60   to 63) & 
                     mmucr3_2(54   to 55) & (mmucr3_2(52)   and tlb_tag4_q(tagpos_is+1)) & or_reduce(tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1)) &
                     "00" & tlb_tag4_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_datain_lo_tlbwe_3_nopar(0 TO tlb_word_width-10-1) <=  
                    (tlb_tag4_q(tagpos_epn to tagpos_epn+31) and (0 to 31 => tlb_tag4_q(tagpos_cm))) & tlb_tag4_q(tagpos_epn+32 to tagpos_epn+51) & tlb_tag4_q(tagpos_size to tagpos_size+3) & mmucr3_3(60   to 63) & 
                     mmucr3_3(54   to 55) & (mmucr3_3(52)   and tlb_tag4_q(tagpos_is+1)) & or_reduce(tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1)) &
                     "00" & tlb_tag4_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_datain_lo_ptereload_nopar(0 TO tlb_word_width-10-1) <=  
                     tlb_tag4_q(tagpos_epn to tagpos_epn+epn_width-1) & '0' & ptereload_req_pte_lat(ptepos_size to ptepos_size+2) & tlb_tag4_q(tagpos_atsel) & tlb_tag4_q(tagpos_esel to tagpos_esel+2) &
                     tlb_tag4_q(tagpos_class) & (tlb_tag4_q(tagpos_class) and tlb_tag4_q(tagpos_class+1)) & '0' & or_reduce(tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1)) &
                     "00" & tlb_tag4_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_dataina_d(0 TO tlb_word_width-1) <=  
                   tlb_datain_lo_tlbwe_0_nopar   & tlb_datain_lo_tlbwe_0_par   
                                        when (tlb_tag4_q(tagpos_thdid+0)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                   tlb_datain_lo_tlbwe_1_nopar   & tlb_datain_lo_tlbwe_1_par   
                                        when (tlb_tag4_q(tagpos_thdid+1)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                   tlb_datain_lo_tlbwe_2_nopar   & tlb_datain_lo_tlbwe_2_par   
                                        when (tlb_tag4_q(tagpos_thdid+2)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                   tlb_datain_lo_tlbwe_3_nopar   & tlb_datain_lo_tlbwe_3_par   
                                        when (tlb_tag4_q(tagpos_thdid+3)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                   tlb_datain_lo_ptereload_nopar & tlb_datain_lo_ptereload_par 
                                        when (tlb_tag4_ptereload_sig='1') else  
                   tlb_dataina_q(0 to tlb_word_width-1);
tlb_datainb_d(0 TO tlb_word_width-1) <=  
                   tlb_datain_lo_tlbwe_0_nopar   & tlb_datain_lo_tlbwe_0_par   
                                        when (tlb_tag4_q(tagpos_thdid+0)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                   tlb_datain_lo_tlbwe_1_nopar   & tlb_datain_lo_tlbwe_1_par   
                                        when (tlb_tag4_q(tagpos_thdid+1)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                   tlb_datain_lo_tlbwe_2_nopar   & tlb_datain_lo_tlbwe_2_par   
                                        when (tlb_tag4_q(tagpos_thdid+2)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                   tlb_datain_lo_tlbwe_3_nopar   & tlb_datain_lo_tlbwe_3_par   
                                        when (tlb_tag4_q(tagpos_thdid+3)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                   tlb_datain_lo_ptereload_nopar & tlb_datain_lo_ptereload_par 
                                        when (tlb_tag4_ptereload_sig='1') else  
                   tlb_datainb_q(0 to tlb_word_width-1);
end generate gen64_tlb_datain;
gen32_tlb_datain: if rs_data_width = 32 generate
tlb_datain_lo_tlbwe_0_nopar(0 TO tlb_word_width-10-1) <=  
                  (0 to 31 => '0') & tlb_tag4_q(tagpos_epn+32 to tagpos_epn+51) & tlb_tag4_q(tagpos_size to tagpos_size+3) & mmucr3_0(60   to 63) & 
                    mmucr3_0(54   to 55) & (mmucr3_0(52)   and tlb_tag4_q(tagpos_is+1)) & or_reduce(tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1)) & 
                    "00" & tlb_tag4_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_datain_lo_tlbwe_1_nopar(0 TO tlb_word_width-10-1) <=  
                  (0 to 31 => '0') & tlb_tag4_q(tagpos_epn+32 to tagpos_epn+51) & tlb_tag4_q(tagpos_size to tagpos_size+3) & mmucr3_1(60   to 63) & 
                    mmucr3_1(54   to 55) & (mmucr3_1(52)   and tlb_tag4_q(tagpos_is+1)) & or_reduce(tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1)) & 
                    "00" & tlb_tag4_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_datain_lo_tlbwe_2_nopar(0 TO tlb_word_width-10-1) <=  
                  (0 to 31 => '0') & tlb_tag4_q(tagpos_epn+32 to tagpos_epn+51) & tlb_tag4_q(tagpos_size to tagpos_size+3) & mmucr3_2(60   to 63) & 
                    mmucr3_2(54   to 55) & (mmucr3_2(52)   and tlb_tag4_q(tagpos_is+1)) & or_reduce(tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1)) & 
                    "00" & tlb_tag4_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_datain_lo_tlbwe_3_nopar(0 TO tlb_word_width-10-1) <=  
                  (0 to 31 => '0') & tlb_tag4_q(tagpos_epn+32 to tagpos_epn+51) & tlb_tag4_q(tagpos_size to tagpos_size+3) & mmucr3_3(60   to 63) & 
                    mmucr3_3(54   to 55) & (mmucr3_3(52)   and tlb_tag4_q(tagpos_is+1)) & or_reduce(tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1)) & 
                    "00" & tlb_tag4_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_datain_lo_ptereload_nopar(0 TO tlb_word_width-10-1) <=  
                  (0 to 31 => '0') & tlb_tag4_q(tagpos_epn+32 to tagpos_epn+epn_width+32-1) & '0' & ptereload_req_pte_lat(ptepos_size to ptepos_size+2) & "1111" & 
                     tlb_tag4_q(tagpos_class to tagpos_class+1) & '0' & or_reduce(tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1)) &
                     "00" & tlb_tag4_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_dataina_d(0 TO tlb_word_width-1) <=  
                     tlb_datain_lo_tlbwe_0_nopar   & tlb_datain_lo_tlbwe_0_par   
                                        when (tlb_tag4_q(tagpos_thdid+0)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                     tlb_datain_lo_tlbwe_1_nopar   & tlb_datain_lo_tlbwe_1_par   
                                        when (tlb_tag4_q(tagpos_thdid+1)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                     tlb_datain_lo_tlbwe_2_nopar   & tlb_datain_lo_tlbwe_2_par   
                                        when (tlb_tag4_q(tagpos_thdid+2)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                     tlb_datain_lo_tlbwe_3_nopar   & tlb_datain_lo_tlbwe_3_par   
                                        when (tlb_tag4_q(tagpos_thdid+3)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                     tlb_datain_lo_ptereload_nopar & tlb_datain_lo_ptereload_par 
                                        when (tlb_tag4_ptereload_sig='1') else  
                     tlb_dataina_q(0 to tlb_word_width-1);
tlb_datainb_d(0 TO tlb_word_width-1) <=  
                     tlb_datain_lo_tlbwe_0_nopar   & tlb_datain_lo_tlbwe_0_par   
                                        when (tlb_tag4_q(tagpos_thdid+0)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                     tlb_datain_lo_tlbwe_1_nopar   & tlb_datain_lo_tlbwe_1_par   
                                        when (tlb_tag4_q(tagpos_thdid+1)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                     tlb_datain_lo_tlbwe_2_nopar   & tlb_datain_lo_tlbwe_2_par   
                                        when (tlb_tag4_q(tagpos_thdid+2)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                     tlb_datain_lo_tlbwe_3_nopar   & tlb_datain_lo_tlbwe_3_par   
                                        when (tlb_tag4_q(tagpos_thdid+3)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1') else  
                     tlb_datain_lo_ptereload_nopar & tlb_datain_lo_ptereload_par 
                                        when (tlb_tag4_ptereload_sig='1') else  
                     tlb_datainb_q(0 to tlb_word_width-1);
end generate gen32_tlb_datain;
ptereload_req_derived_usxwr(0) <=  ptereload_req_pte_lat(ptepos_usxwr+0) and ptereload_req_pte_lat(ptepos_r);
ptereload_req_derived_usxwr(1) <=  ptereload_req_pte_lat(ptepos_usxwr+1) and ptereload_req_pte_lat(ptepos_r);
ptereload_req_derived_usxwr(2) <=  ptereload_req_pte_lat(ptepos_usxwr+2) and ptereload_req_pte_lat(ptepos_r) and ptereload_req_pte_lat(ptepos_c);
ptereload_req_derived_usxwr(3) <=  ptereload_req_pte_lat(ptepos_usxwr+3) and ptereload_req_pte_lat(ptepos_r) and ptereload_req_pte_lat(ptepos_c);
ptereload_req_derived_usxwr(4) <=  ptereload_req_pte_lat(ptepos_usxwr+4) and ptereload_req_pte_lat(ptepos_r);
ptereload_req_derived_usxwr(5) <=  ptereload_req_pte_lat(ptepos_usxwr+5) and ptereload_req_pte_lat(ptepos_r);
gen32_lrat_tag3_lpn: if real_addr_width < 42 generate
lrat_tag3_lpn_sig(22 TO 63-real_addr_width) <=  (others => '0');
lrat_tag3_lpn_sig(64-real_addr_width TO 51) <=  lrat_tag3_lpn(64-real_addr_width to 51);
end generate gen32_lrat_tag3_lpn;
gen64_lrat_tag3_lpn: if real_addr_width > 41 generate
lrat_tag3_lpn_sig(64-real_addr_width TO 51) <=  lrat_tag3_lpn(64-real_addr_width to 51);
end generate gen64_lrat_tag3_lpn;
gen32_lrat_tag3_rpn: if real_addr_width < 42 generate
lrat_tag3_rpn_sig(22 TO 63-real_addr_width) <=  (others => '0');
lrat_tag3_rpn_sig(64-real_addr_width TO 51) <=  lrat_tag3_rpn(64-real_addr_width to 51);
end generate gen32_lrat_tag3_rpn;
gen64_lrat_tag3_rpn: if real_addr_width > 41 generate
lrat_tag3_rpn_sig(64-real_addr_width TO 51) <=  lrat_tag3_rpn(64-real_addr_width to 51);
end generate gen64_lrat_tag3_rpn;
gen32_lrat_tag4_lpn: if real_addr_width < 42 generate
lrat_tag4_lpn_sig(22 TO 63-real_addr_width) <=  (others => '0');
lrat_tag4_lpn_sig(64-real_addr_width TO 51) <=  lrat_tag4_lpn(64-real_addr_width to 51);
end generate gen32_lrat_tag4_lpn;
gen64_lrat_tag4_lpn: if real_addr_width > 41 generate
lrat_tag4_lpn_sig(64-real_addr_width TO 51) <=  lrat_tag4_lpn(64-real_addr_width to 51);
end generate gen64_lrat_tag4_lpn;
gen32_lrat_tag4_rpn: if real_addr_width < 42 generate
lrat_tag4_rpn_sig(22 TO 63-real_addr_width) <=  (others => '0');
lrat_tag4_rpn_sig(64-real_addr_width TO 51) <=  lrat_tag4_rpn(64-real_addr_width to 51);
end generate gen32_lrat_tag4_rpn;
gen64_lrat_tag4_rpn: if real_addr_width > 41 generate
lrat_tag4_rpn_sig(64-real_addr_width TO 51) <=  lrat_tag4_rpn(64-real_addr_width to 51);
end generate gen64_lrat_tag4_rpn;
tlb_datain_hi_hv_tlbwe_0_nopar      <=  
                     mmucr3_0(49)   & "000" & mas7_0_rpnu   & mas3_0_rpnl(32   to 51) & mmucr3_0(50   to 51) & 
                     mmucr3_0(56   to 58) & mas8_0_vf   & (tlb_tag4_q(tagpos_ind) and tlb0cfg_ind) & mas3_0_ubits   & mas2_0_wimge   & 
                     mas3_0_usxwr(0   to 3) & 
                      (mas3_0_usxwr(4)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) & 
                     ((mas3_0_usxwr(5)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) or (mas3_0_rpnl(52)   and tlb_tag4_q(tagpos_ind) and tlb0cfg_ind)) & 
                     tlb_tag4_q(tagpos_pt) & tlb_tag4_q(tagpos_recform) & "00" & tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_datain_hi_hv_tlbwe_1_nopar      <=  
                     mmucr3_1(49)   & "000" & mas7_1_rpnu   & mas3_1_rpnl(32   to 51) & mmucr3_1(50   to 51) & 
                     mmucr3_1(56   to 58) & mas8_1_vf   & (tlb_tag4_q(tagpos_ind) and tlb0cfg_ind) & mas3_1_ubits   & mas2_1_wimge   & 
                     mas3_1_usxwr(0   to 3) & 
                      (mas3_1_usxwr(4)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) & 
                     ((mas3_1_usxwr(5)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) or (mas3_1_rpnl(52)   and tlb_tag4_q(tagpos_ind) and tlb0cfg_ind)) & 
                     tlb_tag4_q(tagpos_pt) & tlb_tag4_q(tagpos_recform) & "00" & tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_datain_hi_hv_tlbwe_2_nopar      <=  
                     mmucr3_2(49)   & "000" & mas7_2_rpnu   & mas3_2_rpnl(32   to 51) & mmucr3_2(50   to 51) & 
                     mmucr3_2(56   to 58) & mas8_2_vf   & (tlb_tag4_q(tagpos_ind) and tlb0cfg_ind) & mas3_2_ubits   & mas2_2_wimge   & 
                     mas3_2_usxwr(0   to 3) & 
                      (mas3_2_usxwr(4)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) & 
                     ((mas3_2_usxwr(5)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) or (mas3_2_rpnl(52)   and tlb_tag4_q(tagpos_ind) and tlb0cfg_ind)) & 
                     tlb_tag4_q(tagpos_pt) & tlb_tag4_q(tagpos_recform) & "00" & tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_datain_hi_hv_tlbwe_3_nopar      <=  
                     mmucr3_3(49)   & "000" & mas7_3_rpnu   & mas3_3_rpnl(32   to 51) & mmucr3_3(50   to 51) & 
                     mmucr3_3(56   to 58) & mas8_3_vf   & (tlb_tag4_q(tagpos_ind) and tlb0cfg_ind) & mas3_3_ubits   & mas2_3_wimge   & 
                     mas3_3_usxwr(0   to 3) & 
                      (mas3_3_usxwr(4)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) & 
                     ((mas3_3_usxwr(5)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) or (mas3_3_rpnl(52)   and tlb_tag4_q(tagpos_ind) and tlb0cfg_ind)) & 
                     tlb_tag4_q(tagpos_pt) & tlb_tag4_q(tagpos_recform) & "00" & tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_datain_hi_gs_tlbwe_0_nopar      <=  
                     mmucr3_0(49)   & "000" & lrat_tag4_rpn_sig(22 to 51) & mmucr3_0(50   to 51) & 
                     mmucr3_0(56   to 58) & mas8_0_vf   & (tlb_tag4_q(tagpos_ind) and tlb0cfg_ind) & mas3_0_ubits   & mas2_0_wimge   & 
                     mas3_0_usxwr(0   to 3) & 
                      (mas3_0_usxwr(4)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) & 
                     ((mas3_0_usxwr(5)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) or (mas3_0_rpnl(52)   and tlb_tag4_q(tagpos_ind) and tlb0cfg_ind)) & 
                     tlb_tag4_q(tagpos_pt) & tlb_tag4_q(tagpos_recform) & "00" & tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_datain_hi_gs_tlbwe_1_nopar      <=  
                     mmucr3_1(49)   & "000" & lrat_tag4_rpn_sig(22 to 51) & mmucr3_1(50   to 51) & 
                     mmucr3_1(56   to 58) & mas8_1_vf   & (tlb_tag4_q(tagpos_ind) and tlb0cfg_ind) & mas3_1_ubits   & mas2_1_wimge   & 
                     mas3_1_usxwr(0   to 3) & 
                      (mas3_1_usxwr(4)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) & 
                     ((mas3_1_usxwr(5)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) or (mas3_1_rpnl(52)   and tlb_tag4_q(tagpos_ind) and tlb0cfg_ind)) & 
                     tlb_tag4_q(tagpos_pt) & tlb_tag4_q(tagpos_recform) & "00" & tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_datain_hi_gs_tlbwe_2_nopar      <=  
                     mmucr3_2(49)   & "000" & lrat_tag4_rpn_sig(22 to 51) & mmucr3_2(50   to 51) & 
                     mmucr3_2(56   to 58) & mas8_2_vf   & (tlb_tag4_q(tagpos_ind) and tlb0cfg_ind) & mas3_2_ubits   & mas2_2_wimge   & 
                     mas3_2_usxwr(0   to 3) & 
                      (mas3_2_usxwr(4)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) & 
                     ((mas3_2_usxwr(5)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) or (mas3_2_rpnl(52)   and tlb_tag4_q(tagpos_ind) and tlb0cfg_ind)) & 
                     tlb_tag4_q(tagpos_pt) & tlb_tag4_q(tagpos_recform) & "00" & tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_datain_hi_gs_tlbwe_3_nopar      <=  
                     mmucr3_3(49)   & "000" & lrat_tag4_rpn_sig(22 to 51) & mmucr3_3(50   to 51) & 
                     mmucr3_3(56   to 58) & mas8_3_vf   & (tlb_tag4_q(tagpos_ind) and tlb0cfg_ind) & mas3_3_ubits   & mas2_3_wimge   & 
                     mas3_3_usxwr(0   to 3) & 
                      (mas3_3_usxwr(4)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) & 
                     ((mas3_3_usxwr(5)   and (not tlb_tag4_q(tagpos_ind) or not tlb0cfg_ind)) or (mas3_3_rpnl(52)   and tlb_tag4_q(tagpos_ind) and tlb0cfg_ind)) & 
                     tlb_tag4_q(tagpos_pt) & tlb_tag4_q(tagpos_recform) & "00" & tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_datain_hi_hv_ptereload_nopar    <=  
                     '0' & "000" & ptereload_req_pte_lat(ptepos_rpn+10 to ptepos_rpn+39) & ptereload_req_pte_lat(ptepos_r) & ptereload_req_pte_lat(ptepos_c) &
                     "00" & '0' & '0' & '0' & ptereload_req_pte_lat(ptepos_ubits to ptepos_ubits+3) & ptereload_req_pte_lat(ptepos_wimge to ptepos_wimge+4) & 
                      ptereload_req_derived_usxwr(0 to 5) & 
                      tlb_tag4_q(tagpos_gs) & tlb_tag4_q(tagpos_as) & "00" & tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_datain_hi_gs_ptereload_nopar    <=  
                     '0' & "000" & lrat_tag4_rpn_sig(22 to 51) & ptereload_req_pte_lat(ptepos_r) & ptereload_req_pte_lat(ptepos_c) &
                     "00" & '0' & '0' & '0' & ptereload_req_pte_lat(ptepos_ubits to ptepos_ubits+3) & ptereload_req_pte_lat(ptepos_wimge to ptepos_wimge+4) & 
                     ptereload_req_derived_usxwr(0 to 5) & 
                     tlb_tag4_q(tagpos_gs) & tlb_tag4_q(tagpos_as) & "00" & tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_dataina_d(tlb_word_width TO 2*tlb_word_width-1) <=  
                     tlb_datain_hi_hv_tlbwe_0_nopar   & tlb_datain_hi_hv_tlbwe_0_par   
                        when (tlb_tag4_q(tagpos_thdid+0)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and (tlb_tag4_q(tagpos_gs)='0' or tlb_tag4_q(tagpos_is)='0')) else  
                     tlb_datain_hi_hv_tlbwe_1_nopar   & tlb_datain_hi_hv_tlbwe_1_par   
                        when (tlb_tag4_q(tagpos_thdid+1)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and (tlb_tag4_q(tagpos_gs)='0' or tlb_tag4_q(tagpos_is)='0')) else  
                     tlb_datain_hi_hv_tlbwe_2_nopar   & tlb_datain_hi_hv_tlbwe_2_par   
                        when (tlb_tag4_q(tagpos_thdid+2)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and (tlb_tag4_q(tagpos_gs)='0' or tlb_tag4_q(tagpos_is)='0')) else  
                     tlb_datain_hi_hv_tlbwe_3_nopar   & tlb_datain_hi_hv_tlbwe_3_par   
                        when (tlb_tag4_q(tagpos_thdid+3)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and (tlb_tag4_q(tagpos_gs)='0' or tlb_tag4_q(tagpos_is)='0')) else  
                     tlb_datain_hi_gs_tlbwe_0_nopar   &  tlb_datain_hi_gs_tlbwe_0_par
                        when (tlb_tag4_q(tagpos_thdid+0)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_is)='1') else  
                     tlb_datain_hi_gs_tlbwe_1_nopar   &  tlb_datain_hi_gs_tlbwe_1_par
                        when (tlb_tag4_q(tagpos_thdid+1)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_is)='1') else  
                     tlb_datain_hi_gs_tlbwe_2_nopar   &  tlb_datain_hi_gs_tlbwe_2_par
                        when (tlb_tag4_q(tagpos_thdid+2)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_is)='1') else  
                     tlb_datain_hi_gs_tlbwe_3_nopar   &  tlb_datain_hi_gs_tlbwe_3_par
                        when (tlb_tag4_q(tagpos_thdid+3)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_is)='1') else  
                     tlb_datain_hi_hv_ptereload_nopar &  tlb_datain_hi_hv_ptereload_par
                        when (tlb_tag4_ptereload_sig='1' and tlb_tag4_q(tagpos_gs)='0') else  
                     tlb_datain_hi_gs_ptereload_nopar &  tlb_datain_hi_gs_ptereload_par
                        when (tlb_tag4_ptereload_sig='1' and tlb_tag4_q(tagpos_gs)='1') else  
                     tlb_dataina_q(tlb_word_width to 2*tlb_word_width-1);
tlb_datainb_d(tlb_word_width TO 2*tlb_word_width-1) <=  
                     tlb_datain_hi_hv_tlbwe_0_nopar   & tlb_datain_hi_hv_tlbwe_0_par   
                        when (tlb_tag4_q(tagpos_thdid+0)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and (tlb_tag4_q(tagpos_gs)='0' or tlb_tag4_q(tagpos_is)='0')) else  
                     tlb_datain_hi_hv_tlbwe_1_nopar   & tlb_datain_hi_hv_tlbwe_1_par   
                        when (tlb_tag4_q(tagpos_thdid+1)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and (tlb_tag4_q(tagpos_gs)='0' or tlb_tag4_q(tagpos_is)='0')) else  
                     tlb_datain_hi_hv_tlbwe_2_nopar   & tlb_datain_hi_hv_tlbwe_2_par   
                        when (tlb_tag4_q(tagpos_thdid+2)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and (tlb_tag4_q(tagpos_gs)='0' or tlb_tag4_q(tagpos_is)='0')) else  
                     tlb_datain_hi_hv_tlbwe_3_nopar   & tlb_datain_hi_hv_tlbwe_3_par   
                        when (tlb_tag4_q(tagpos_thdid+3)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and (tlb_tag4_q(tagpos_gs)='0' or tlb_tag4_q(tagpos_is)='0')) else  
                     tlb_datain_hi_gs_tlbwe_0_nopar   &  tlb_datain_hi_gs_tlbwe_0_par
                        when (tlb_tag4_q(tagpos_thdid+0)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_is)='1') else  
                     tlb_datain_hi_gs_tlbwe_1_nopar   &  tlb_datain_hi_gs_tlbwe_1_par
                        when (tlb_tag4_q(tagpos_thdid+1)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_is)='1') else  
                     tlb_datain_hi_gs_tlbwe_2_nopar   &  tlb_datain_hi_gs_tlbwe_2_par
                        when (tlb_tag4_q(tagpos_thdid+2)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_is)='1') else  
                     tlb_datain_hi_gs_tlbwe_3_nopar   &  tlb_datain_hi_gs_tlbwe_3_par
                        when (tlb_tag4_q(tagpos_thdid+3)='1'   and tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_is)='1') else  
                     tlb_datain_hi_hv_ptereload_nopar &  tlb_datain_hi_hv_ptereload_par
                        when (tlb_tag4_ptereload_sig='1' and tlb_tag4_q(tagpos_gs)='0') else  
                     tlb_datain_hi_gs_ptereload_nopar &  tlb_datain_hi_gs_ptereload_par
                        when (tlb_tag4_ptereload_sig='1' and tlb_tag4_q(tagpos_gs)='1') else  
                     tlb_datainb_q(tlb_word_width to 2*tlb_word_width-1);
tlb_datain_lo_tlbwe_0_par(0) <=  xor_reduce(tlb_datain_lo_tlbwe_0_nopar(0   to 7));
tlb_datain_lo_tlbwe_0_par(1) <=  xor_reduce(tlb_datain_lo_tlbwe_0_nopar(8   to 15));
tlb_datain_lo_tlbwe_0_par(2) <=  xor_reduce(tlb_datain_lo_tlbwe_0_nopar(16   to 23));
tlb_datain_lo_tlbwe_0_par(3) <=  xor_reduce(tlb_datain_lo_tlbwe_0_nopar(24   to 31));
tlb_datain_lo_tlbwe_0_par(4) <=  xor_reduce(tlb_datain_lo_tlbwe_0_nopar(32   to 39));
tlb_datain_lo_tlbwe_0_par(5) <=  xor_reduce(tlb_datain_lo_tlbwe_0_nopar(40   to 47));
tlb_datain_lo_tlbwe_0_par(7) <=  xor_reduce(tlb_datain_lo_tlbwe_0_nopar(52   to 59));
tlb_datain_lo_tlbwe_0_par(8) <=  xor_reduce(tlb_datain_lo_tlbwe_0_nopar(60   to 65));
tlb_datain_lo_tlbwe_0_par(9) <=  xor_reduce(tlb_datain_lo_tlbwe_0_nopar(66   to 73));
tlb_datain_lo_tlbwe_1_par(0) <=  xor_reduce(tlb_datain_lo_tlbwe_1_nopar(0   to 7));
tlb_datain_lo_tlbwe_1_par(1) <=  xor_reduce(tlb_datain_lo_tlbwe_1_nopar(8   to 15));
tlb_datain_lo_tlbwe_1_par(2) <=  xor_reduce(tlb_datain_lo_tlbwe_1_nopar(16   to 23));
tlb_datain_lo_tlbwe_1_par(3) <=  xor_reduce(tlb_datain_lo_tlbwe_1_nopar(24   to 31));
tlb_datain_lo_tlbwe_1_par(4) <=  xor_reduce(tlb_datain_lo_tlbwe_1_nopar(32   to 39));
tlb_datain_lo_tlbwe_1_par(5) <=  xor_reduce(tlb_datain_lo_tlbwe_1_nopar(40   to 47));
tlb_datain_lo_tlbwe_1_par(7) <=  xor_reduce(tlb_datain_lo_tlbwe_1_nopar(52   to 59));
tlb_datain_lo_tlbwe_1_par(8) <=  xor_reduce(tlb_datain_lo_tlbwe_1_nopar(60   to 65));
tlb_datain_lo_tlbwe_1_par(9) <=  xor_reduce(tlb_datain_lo_tlbwe_1_nopar(66   to 73));
tlb_datain_lo_tlbwe_2_par(0) <=  xor_reduce(tlb_datain_lo_tlbwe_2_nopar(0   to 7));
tlb_datain_lo_tlbwe_2_par(1) <=  xor_reduce(tlb_datain_lo_tlbwe_2_nopar(8   to 15));
tlb_datain_lo_tlbwe_2_par(2) <=  xor_reduce(tlb_datain_lo_tlbwe_2_nopar(16   to 23));
tlb_datain_lo_tlbwe_2_par(3) <=  xor_reduce(tlb_datain_lo_tlbwe_2_nopar(24   to 31));
tlb_datain_lo_tlbwe_2_par(4) <=  xor_reduce(tlb_datain_lo_tlbwe_2_nopar(32   to 39));
tlb_datain_lo_tlbwe_2_par(5) <=  xor_reduce(tlb_datain_lo_tlbwe_2_nopar(40   to 47));
tlb_datain_lo_tlbwe_2_par(7) <=  xor_reduce(tlb_datain_lo_tlbwe_2_nopar(52   to 59));
tlb_datain_lo_tlbwe_2_par(8) <=  xor_reduce(tlb_datain_lo_tlbwe_2_nopar(60   to 65));
tlb_datain_lo_tlbwe_2_par(9) <=  xor_reduce(tlb_datain_lo_tlbwe_2_nopar(66   to 73));
tlb_datain_lo_tlbwe_3_par(0) <=  xor_reduce(tlb_datain_lo_tlbwe_3_nopar(0   to 7));
tlb_datain_lo_tlbwe_3_par(1) <=  xor_reduce(tlb_datain_lo_tlbwe_3_nopar(8   to 15));
tlb_datain_lo_tlbwe_3_par(2) <=  xor_reduce(tlb_datain_lo_tlbwe_3_nopar(16   to 23));
tlb_datain_lo_tlbwe_3_par(3) <=  xor_reduce(tlb_datain_lo_tlbwe_3_nopar(24   to 31));
tlb_datain_lo_tlbwe_3_par(4) <=  xor_reduce(tlb_datain_lo_tlbwe_3_nopar(32   to 39));
tlb_datain_lo_tlbwe_3_par(5) <=  xor_reduce(tlb_datain_lo_tlbwe_3_nopar(40   to 47));
tlb_datain_lo_tlbwe_3_par(7) <=  xor_reduce(tlb_datain_lo_tlbwe_3_nopar(52   to 59));
tlb_datain_lo_tlbwe_3_par(8) <=  xor_reduce(tlb_datain_lo_tlbwe_3_nopar(60   to 65));
tlb_datain_lo_tlbwe_3_par(9) <=  xor_reduce(tlb_datain_lo_tlbwe_3_nopar(66   to 73));
tlb_datain_lo_tlbwe_0_par(6) <=  xor_reduce(tlb_datain_lo_tlbwe_0_nopar(48   to 51) & mmucr1_q(pos_tlb_pei));
tlb_datain_lo_tlbwe_1_par(6) <=  xor_reduce(tlb_datain_lo_tlbwe_1_nopar(48   to 51) & mmucr1_q(pos_tlb_pei));
tlb_datain_lo_tlbwe_2_par(6) <=  xor_reduce(tlb_datain_lo_tlbwe_2_nopar(48   to 51) & mmucr1_clone_q(pos_tlb_pei));
tlb_datain_lo_tlbwe_3_par(6) <=  xor_reduce(tlb_datain_lo_tlbwe_3_nopar(48   to 51) & mmucr1_clone_q(pos_tlb_pei));
tlb_datain_lo_ptereload_par(0) <=  xor_reduce(tlb_datain_lo_ptereload_nopar(0 to 7));
tlb_datain_lo_ptereload_par(1) <=  xor_reduce(tlb_datain_lo_ptereload_nopar(8 to 15));
tlb_datain_lo_ptereload_par(2) <=  xor_reduce(tlb_datain_lo_ptereload_nopar(16 to 23));
tlb_datain_lo_ptereload_par(3) <=  xor_reduce(tlb_datain_lo_ptereload_nopar(24 to 31));
tlb_datain_lo_ptereload_par(4) <=  xor_reduce(tlb_datain_lo_ptereload_nopar(32 to 39));
tlb_datain_lo_ptereload_par(5) <=  xor_reduce(tlb_datain_lo_ptereload_nopar(40 to 47));
tlb_datain_lo_ptereload_par(6) <=  xor_reduce(tlb_datain_lo_ptereload_nopar(48 to 51));
tlb_datain_lo_ptereload_par(7) <=  xor_reduce(tlb_datain_lo_ptereload_nopar(52 to 59));
tlb_datain_lo_ptereload_par(8) <=  xor_reduce(tlb_datain_lo_ptereload_nopar(60 to 65));
tlb_datain_lo_ptereload_par(9) <=  xor_reduce(tlb_datain_lo_ptereload_nopar(66 to 73));
tlb_datain_hi_hv_tlbwe_0_par(0) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_0_nopar(0   to 7));
tlb_datain_hi_hv_tlbwe_0_par(1) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_0_nopar(8   to 15));
tlb_datain_hi_hv_tlbwe_0_par(2) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_0_nopar(16   to 23));
tlb_datain_hi_hv_tlbwe_0_par(3) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_0_nopar(24   to 31));
tlb_datain_hi_hv_tlbwe_0_par(4) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_0_nopar(32   to 39));
tlb_datain_hi_hv_tlbwe_0_par(5) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_0_nopar(40   to 44));
tlb_datain_hi_hv_tlbwe_0_par(6) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_0_nopar(45   to 49));
tlb_datain_hi_hv_tlbwe_0_par(7) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_0_nopar(50   to 57));
tlb_datain_hi_hv_tlbwe_0_par(8) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_0_nopar(58   to 65));
tlb_datain_hi_hv_tlbwe_0_par(9) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_0_nopar(66   to 73));
tlb_datain_hi_hv_tlbwe_1_par(0) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_1_nopar(0   to 7));
tlb_datain_hi_hv_tlbwe_1_par(1) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_1_nopar(8   to 15));
tlb_datain_hi_hv_tlbwe_1_par(2) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_1_nopar(16   to 23));
tlb_datain_hi_hv_tlbwe_1_par(3) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_1_nopar(24   to 31));
tlb_datain_hi_hv_tlbwe_1_par(4) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_1_nopar(32   to 39));
tlb_datain_hi_hv_tlbwe_1_par(5) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_1_nopar(40   to 44));
tlb_datain_hi_hv_tlbwe_1_par(6) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_1_nopar(45   to 49));
tlb_datain_hi_hv_tlbwe_1_par(7) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_1_nopar(50   to 57));
tlb_datain_hi_hv_tlbwe_1_par(8) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_1_nopar(58   to 65));
tlb_datain_hi_hv_tlbwe_1_par(9) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_1_nopar(66   to 73));
tlb_datain_hi_hv_tlbwe_2_par(0) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_2_nopar(0   to 7));
tlb_datain_hi_hv_tlbwe_2_par(1) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_2_nopar(8   to 15));
tlb_datain_hi_hv_tlbwe_2_par(2) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_2_nopar(16   to 23));
tlb_datain_hi_hv_tlbwe_2_par(3) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_2_nopar(24   to 31));
tlb_datain_hi_hv_tlbwe_2_par(4) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_2_nopar(32   to 39));
tlb_datain_hi_hv_tlbwe_2_par(5) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_2_nopar(40   to 44));
tlb_datain_hi_hv_tlbwe_2_par(6) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_2_nopar(45   to 49));
tlb_datain_hi_hv_tlbwe_2_par(7) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_2_nopar(50   to 57));
tlb_datain_hi_hv_tlbwe_2_par(8) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_2_nopar(58   to 65));
tlb_datain_hi_hv_tlbwe_2_par(9) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_2_nopar(66   to 73));
tlb_datain_hi_hv_tlbwe_3_par(0) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_3_nopar(0   to 7));
tlb_datain_hi_hv_tlbwe_3_par(1) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_3_nopar(8   to 15));
tlb_datain_hi_hv_tlbwe_3_par(2) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_3_nopar(16   to 23));
tlb_datain_hi_hv_tlbwe_3_par(3) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_3_nopar(24   to 31));
tlb_datain_hi_hv_tlbwe_3_par(4) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_3_nopar(32   to 39));
tlb_datain_hi_hv_tlbwe_3_par(5) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_3_nopar(40   to 44));
tlb_datain_hi_hv_tlbwe_3_par(6) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_3_nopar(45   to 49));
tlb_datain_hi_hv_tlbwe_3_par(7) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_3_nopar(50   to 57));
tlb_datain_hi_hv_tlbwe_3_par(8) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_3_nopar(58   to 65));
tlb_datain_hi_hv_tlbwe_3_par(9) <=  xor_reduce(tlb_datain_hi_hv_tlbwe_3_nopar(66   to 73));
tlb_datain_hi_gs_tlbwe_0_par(0) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_0_nopar(0   to 7));
tlb_datain_hi_gs_tlbwe_0_par(1) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_0_nopar(8   to 15));
tlb_datain_hi_gs_tlbwe_0_par(2) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_0_nopar(16   to 23));
tlb_datain_hi_gs_tlbwe_0_par(3) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_0_nopar(24   to 31));
tlb_datain_hi_gs_tlbwe_0_par(4) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_0_nopar(32   to 39));
tlb_datain_hi_gs_tlbwe_0_par(5) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_0_nopar(40   to 44));
tlb_datain_hi_gs_tlbwe_0_par(6) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_0_nopar(45   to 49));
tlb_datain_hi_gs_tlbwe_0_par(7) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_0_nopar(50   to 57));
tlb_datain_hi_gs_tlbwe_0_par(8) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_0_nopar(58   to 65));
tlb_datain_hi_gs_tlbwe_0_par(9) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_0_nopar(66   to 73));
tlb_datain_hi_gs_tlbwe_1_par(0) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_1_nopar(0   to 7));
tlb_datain_hi_gs_tlbwe_1_par(1) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_1_nopar(8   to 15));
tlb_datain_hi_gs_tlbwe_1_par(2) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_1_nopar(16   to 23));
tlb_datain_hi_gs_tlbwe_1_par(3) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_1_nopar(24   to 31));
tlb_datain_hi_gs_tlbwe_1_par(4) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_1_nopar(32   to 39));
tlb_datain_hi_gs_tlbwe_1_par(5) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_1_nopar(40   to 44));
tlb_datain_hi_gs_tlbwe_1_par(6) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_1_nopar(45   to 49));
tlb_datain_hi_gs_tlbwe_1_par(7) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_1_nopar(50   to 57));
tlb_datain_hi_gs_tlbwe_1_par(8) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_1_nopar(58   to 65));
tlb_datain_hi_gs_tlbwe_1_par(9) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_1_nopar(66   to 73));
tlb_datain_hi_gs_tlbwe_2_par(0) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_2_nopar(0   to 7));
tlb_datain_hi_gs_tlbwe_2_par(1) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_2_nopar(8   to 15));
tlb_datain_hi_gs_tlbwe_2_par(2) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_2_nopar(16   to 23));
tlb_datain_hi_gs_tlbwe_2_par(3) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_2_nopar(24   to 31));
tlb_datain_hi_gs_tlbwe_2_par(4) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_2_nopar(32   to 39));
tlb_datain_hi_gs_tlbwe_2_par(5) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_2_nopar(40   to 44));
tlb_datain_hi_gs_tlbwe_2_par(6) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_2_nopar(45   to 49));
tlb_datain_hi_gs_tlbwe_2_par(7) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_2_nopar(50   to 57));
tlb_datain_hi_gs_tlbwe_2_par(8) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_2_nopar(58   to 65));
tlb_datain_hi_gs_tlbwe_2_par(9) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_2_nopar(66   to 73));
tlb_datain_hi_gs_tlbwe_3_par(0) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_3_nopar(0   to 7));
tlb_datain_hi_gs_tlbwe_3_par(1) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_3_nopar(8   to 15));
tlb_datain_hi_gs_tlbwe_3_par(2) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_3_nopar(16   to 23));
tlb_datain_hi_gs_tlbwe_3_par(3) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_3_nopar(24   to 31));
tlb_datain_hi_gs_tlbwe_3_par(4) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_3_nopar(32   to 39));
tlb_datain_hi_gs_tlbwe_3_par(5) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_3_nopar(40   to 44));
tlb_datain_hi_gs_tlbwe_3_par(6) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_3_nopar(45   to 49));
tlb_datain_hi_gs_tlbwe_3_par(7) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_3_nopar(50   to 57));
tlb_datain_hi_gs_tlbwe_3_par(8) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_3_nopar(58   to 65));
tlb_datain_hi_gs_tlbwe_3_par(9) <=  xor_reduce(tlb_datain_hi_gs_tlbwe_3_nopar(66   to 73));
tlb_datain_hi_hv_ptereload_par(0) <=  xor_reduce(tlb_datain_hi_hv_ptereload_nopar(0 to 7));
tlb_datain_hi_hv_ptereload_par(1) <=  xor_reduce(tlb_datain_hi_hv_ptereload_nopar(8 to 15));
tlb_datain_hi_hv_ptereload_par(2) <=  xor_reduce(tlb_datain_hi_hv_ptereload_nopar(16 to 23));
tlb_datain_hi_hv_ptereload_par(3) <=  xor_reduce(tlb_datain_hi_hv_ptereload_nopar(24 to 31));
tlb_datain_hi_hv_ptereload_par(4) <=  xor_reduce(tlb_datain_hi_hv_ptereload_nopar(32 to 39));
tlb_datain_hi_hv_ptereload_par(5) <=  xor_reduce(tlb_datain_hi_hv_ptereload_nopar(40 to 44));
tlb_datain_hi_hv_ptereload_par(6) <=  xor_reduce(tlb_datain_hi_hv_ptereload_nopar(45 to 49));
tlb_datain_hi_hv_ptereload_par(7) <=  xor_reduce(tlb_datain_hi_hv_ptereload_nopar(50 to 57));
tlb_datain_hi_hv_ptereload_par(8) <=  xor_reduce(tlb_datain_hi_hv_ptereload_nopar(58 to 65));
tlb_datain_hi_hv_ptereload_par(9) <=  xor_reduce(tlb_datain_hi_hv_ptereload_nopar(66 to 73));
tlb_datain_hi_gs_ptereload_par(0) <=  xor_reduce(tlb_datain_hi_gs_ptereload_nopar(0 to 7));
tlb_datain_hi_gs_ptereload_par(1) <=  xor_reduce(tlb_datain_hi_gs_ptereload_nopar(8 to 15));
tlb_datain_hi_gs_ptereload_par(2) <=  xor_reduce(tlb_datain_hi_gs_ptereload_nopar(16 to 23));
tlb_datain_hi_gs_ptereload_par(3) <=  xor_reduce(tlb_datain_hi_gs_ptereload_nopar(24 to 31));
tlb_datain_hi_gs_ptereload_par(4) <=  xor_reduce(tlb_datain_hi_gs_ptereload_nopar(32 to 39));
tlb_datain_hi_gs_ptereload_par(5) <=  xor_reduce(tlb_datain_hi_gs_ptereload_nopar(40 to 44));
tlb_datain_hi_gs_ptereload_par(6) <=  xor_reduce(tlb_datain_hi_gs_ptereload_nopar(45 to 49));
tlb_datain_hi_gs_ptereload_par(7) <=  xor_reduce(tlb_datain_hi_gs_ptereload_nopar(50 to 57));
tlb_datain_hi_gs_ptereload_par(8) <=  xor_reduce(tlb_datain_hi_gs_ptereload_nopar(58 to 65));
tlb_datain_hi_gs_ptereload_par(9) <=  xor_reduce(tlb_datain_hi_gs_ptereload_nopar(66 to 73));
tlb_dataina          <=  tlb_dataina_q;
tlb_datainb          <=  tlb_datainb_q;
tlb_cmp_dbg_tag5_tlb_datain_q  <=  tlb_dataina_q;
tlb_erat_rel_d(eratpos_epn TO epn_width-1) <=  tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_epn to epn_width-1);
tlb_erat_rel_d(eratpos_x) <=  tlb_tag4_way_or(waypos_xbit) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_x);
tlb_erat_rel_d(eratpos_size TO eratpos_size+2) <=   erat_pgsize(0 to 2) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_size to eratpos_size+2);
tlb_erat_rel_d(eratpos_v) <=  '1' 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_v);
tlb_erat_rel_clone_d(eratpos_epn TO epn_width-1) <=  tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_epn to epn_width-1);
tlb_erat_rel_clone_d(eratpos_x) <=  tlb_tag4_way_or(waypos_xbit) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_x);
tlb_erat_rel_clone_d(eratpos_size TO eratpos_size+2) <=   erat_pgsize(0 to 2) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_size to eratpos_size+2);
tlb_erat_rel_clone_d(eratpos_v) <=  '1' 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_v);
tlb_erat_rel_d(eratpos_thdid TO eratpos_thdid+thdid_width-1) <=  
       tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) 
        when ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_q(pos_ittid)='0' and tlb_tag4_q(tagpos_ind)='0') or
               (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_q(pos_dttid)='0' and tlb_tag4_q(tagpos_ind)='0'))
         else tlb_tag4_way_or(waypos_tid+2 to waypos_tid+5)                  
         when ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_q(pos_ittid)='1' and tlb_tag4_q(tagpos_ind)='0') or
                (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_q(pos_dttid)='1' and tlb_tag4_q(tagpos_ind)='0'))
          else (tlb_tag4_q(tagpos_atsel) & tlb_tag4_q(tagpos_esel to tagpos_esel+2))    
          when ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_q(pos_ittid)='0' and tlb_tag4_q(tagpos_ind)='0') or
                 (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_q(pos_dttid)='0' and tlb_tag4_q(tagpos_ind)='0'))
           else tlb_tag4_q(tagpos_pid+2 to tagpos_pid+5)                  
           when ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_q(pos_ittid)='1' and tlb_tag4_q(tagpos_ind)='0') or
                  (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_q(pos_dttid)='1' and tlb_tag4_q(tagpos_ind)='0'))
             else tlb_erat_rel_q(eratpos_thdid to eratpos_thdid+thdid_width-1);
tlb_erat_rel_clone_d(eratpos_thdid TO eratpos_thdid+thdid_width-1) <=  
       tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) 
        when ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_clone_q(pos_ittid)='0' and tlb_tag4_q(tagpos_ind)='0') or
               (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_clone_q(pos_dttid)='0' and tlb_tag4_q(tagpos_ind)='0'))
         else tlb_tag4_way_or(waypos_tid+2 to waypos_tid+5)                  
         when ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_clone_q(pos_ittid)='1' and tlb_tag4_q(tagpos_ind)='0') or
                (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_clone_q(pos_dttid)='1' and tlb_tag4_q(tagpos_ind)='0'))
          else (tlb_tag4_q(tagpos_atsel) & tlb_tag4_q(tagpos_esel to tagpos_esel+2))    
          when ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_clone_q(pos_ittid)='0' and tlb_tag4_q(tagpos_ind)='0') or
                 (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_clone_q(pos_dttid)='0' and tlb_tag4_q(tagpos_ind)='0'))
           else tlb_tag4_q(tagpos_pid+2 to tagpos_pid+5)                  
           when ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_clone_q(pos_ittid)='1' and tlb_tag4_q(tagpos_ind)='0') or
                  (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_clone_q(pos_dttid)='1' and tlb_tag4_q(tagpos_ind)='0'))
             else tlb_erat_rel_clone_q(eratpos_thdid to eratpos_thdid+thdid_width-1);
tlb_erat_rel_d(eratpos_class TO eratpos_class+class_width-1) <=  
       tlb_tag4_way_or(waypos_class to waypos_class+class_width-1) 
        when tlb_tag4_erat_data_cap='1' and
               ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_q(pos_ictid)='0' and tlb_tag4_q(tagpos_ind)='0') or
                (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_q(pos_dctid)='0'  and mmucr1_q(pos_dccd)='1' and tlb_tag4_q(tagpos_ind)='0'))
         else tlb_tag4_way_or(waypos_tid+0 to waypos_tid+1)                  
         when tlb_tag4_erat_data_cap='1' and
               ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_q(pos_ictid)='1' and tlb_tag4_q(tagpos_ind)='0') or
                (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_q(pos_dctid)='1' and tlb_tag4_q(tagpos_ind)='0'))
          else ( tlb_tag4_q(tagpos_class) & ((tlb_tag4_q(tagpos_class) and tlb_tag4_q(tagpos_class+1)) or (not(tlb_tag4_q(tagpos_class)) and tlb_tag4_way_or(waypos_class+1))) )
          when (tlb_tag4_erat_data_cap='1' and
                 tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_q(pos_dctid)='0'  and mmucr1_q(pos_dccd)='0' and tlb_tag4_q(tagpos_ind)='0')
           else (tlb_tag4_q(tagpos_class) & (tlb_tag4_q(tagpos_class) and tlb_tag4_q(tagpos_class+1)))                  
           when tlb_tag4_erat_data_cap='1' and
                 ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_q(pos_ictid)='0' and tlb_tag4_q(tagpos_ind)='0') or
                  (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_q(pos_dctid)='0' and tlb_tag4_q(tagpos_ind)='0'))
             else tlb_tag4_q(tagpos_pid+0 to tagpos_pid+1)                  
             when tlb_tag4_erat_data_cap='1' and
                   ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_q(pos_ictid)='1' and tlb_tag4_q(tagpos_ind)='0') or
                    (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_q(pos_dctid)='1' and tlb_tag4_q(tagpos_ind)='0'))
               else tlb_erat_rel_q(eratpos_class to eratpos_class+class_width-1);
tlb_erat_rel_clone_d(eratpos_class TO eratpos_class+class_width-1) <=  
       tlb_tag4_way_or(waypos_class to waypos_class+class_width-1) 
        when tlb_tag4_erat_data_cap='1' and
               ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_clone_q(pos_ictid)='0' and tlb_tag4_q(tagpos_ind)='0') or
                (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_clone_q(pos_dctid)='0'  and mmucr1_clone_q(pos_dccd)='1' and tlb_tag4_q(tagpos_ind)='0'))
         else tlb_tag4_way_or(waypos_tid+0 to waypos_tid+1)                  
         when tlb_tag4_erat_data_cap='1' and
               ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_clone_q(pos_ictid)='1' and tlb_tag4_q(tagpos_ind)='0') or
                (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_clone_q(pos_dctid)='1' and tlb_tag4_q(tagpos_ind)='0'))
          else ( tlb_tag4_q(tagpos_class) & ((tlb_tag4_q(tagpos_class) and tlb_tag4_q(tagpos_class+1)) or (not(tlb_tag4_q(tagpos_class)) and tlb_tag4_way_or(waypos_class+1))) )
          when (tlb_tag4_erat_data_cap='1' and
                 tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and mmucr1_clone_q(pos_dctid)='0'  and mmucr1_clone_q(pos_dccd)='0' and tlb_tag4_q(tagpos_ind)='0')
           else (tlb_tag4_q(tagpos_class) & (tlb_tag4_q(tagpos_class) and tlb_tag4_q(tagpos_class+1)))                  
           when tlb_tag4_erat_data_cap='1' and
                 ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_clone_q(pos_ictid)='0' and tlb_tag4_q(tagpos_ind)='0') or
                  (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_clone_q(pos_dctid)='0' and tlb_tag4_q(tagpos_ind)='0'))
             else tlb_tag4_q(tagpos_pid+0 to tagpos_pid+1)                  
             when tlb_tag4_erat_data_cap='1' and
                   ((tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_clone_q(pos_ictid)='1' and tlb_tag4_q(tagpos_ind)='0') or
                    (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1' and mmucr1_clone_q(pos_dctid)='1' and tlb_tag4_q(tagpos_ind)='0'))
               else tlb_erat_rel_clone_q(eratpos_class to eratpos_class+class_width-1);
tlb_erat_rel_d(eratpos_extclass TO eratpos_extclass+1) <=  tlb_tag4_way_or(waypos_extclass to waypos_extclass+1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_extclass to eratpos_extclass+1);
tlb_erat_rel_d(eratpos_wren) <=  '1' when (tlb_tag4_erat_data_cap='1' and 
                                             (tlb_tag4_q(tagpos_type_ierat)='1' or tlb_tag4_q(tagpos_type_derat)='1') and 
                                              tlb_tag4_q(tagpos_type_ptereload)='0' and tlb_tag4_wayhit_q(tlb_ways)='1' and 
                                               tlb_tag4_q(tagpos_wq+1)='0' and tlb_tag4_q(tagpos_ind)='0' and multihit='0'   
                                                 and or_reduce(tag4_parerr_q(0 to 4))='0') 
                            else '0' when tlb_tag4_erat_data_cap='1' 
                            else tlb_erat_rel_q(eratpos_wren);
tlb_erat_rel_d(eratpos_rpnrsvd TO eratpos_rpnrsvd+3) <=  (others => '0');
tlb_erat_rel_d(eratpos_rpn TO eratpos_rpn+rpn_width-1) <=  tlb_tag4_way_or(waypos_rpn to waypos_rpn+rpn_width-1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_rpn to eratpos_rpn+rpn_width-1);
tlb_erat_rel_d(eratpos_r TO eratpos_c) <=  tlb_tag4_way_or(waypos_rc to waypos_rc+1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_r to eratpos_c);
tlb_erat_rel_d(eratpos_relsoon) <=  ierat_req_taken or ptereload_req_taken or tlb_tag0_type(1);
tlb_erat_rel_d(eratpos_wlc TO eratpos_wlc+1) <=  tlb_tag4_way_or(waypos_wlc to waypos_wlc+1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_wlc to eratpos_wlc+1);
tlb_erat_rel_d(eratpos_resvattr) <=  tlb_tag4_way_or(waypos_resvattr) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_resvattr);
tlb_erat_rel_d(eratpos_vf) <=  tlb_tag4_way_or(waypos_vf) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_vf);
tlb_erat_rel_d(eratpos_ubits TO eratpos_ubits+3) <=  tlb_tag4_way_or(waypos_ubits to waypos_ubits+3) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_ubits to eratpos_ubits+3);
tlb_erat_rel_d(eratpos_wimge TO eratpos_wimge+4) <=  tlb_tag4_way_or(waypos_wimge to waypos_wimge+4) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_wimge to eratpos_wimge+4);
tlb_erat_rel_d(eratpos_usxwr TO eratpos_usxwr+5) <=  tlb_tag4_way_or(waypos_usxwr to waypos_usxwr+5) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_usxwr to eratpos_usxwr+5);
tlb_erat_rel_d(eratpos_gs) <=  tlb_tag4_way_or(waypos_gs) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_gs);
tlb_erat_rel_d(eratpos_ts) <=  tlb_tag4_way_or(waypos_ts) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_ts);
tlb_erat_rel_d(eratpos_tid TO eratpos_tid+pid_width_erat-1) <=  tlb_tag4_way_or(waypos_tid+6 to waypos_tid+14-1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_q(eratpos_tid to eratpos_tid+pid_width_erat-1);
tlb_erat_rel_clone_d(eratpos_extclass TO eratpos_extclass+1) <=  tlb_tag4_way_or(waypos_extclass to waypos_extclass+1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_extclass to eratpos_extclass+1);
tlb_erat_rel_clone_d(eratpos_wren) <=  '1' when (tlb_tag4_erat_data_cap='1' and 
                                             (tlb_tag4_q(tagpos_type_ierat)='1' or tlb_tag4_q(tagpos_type_derat)='1') and 
                                              tlb_tag4_q(tagpos_type_ptereload)='0' and tlb_tag4_wayhit_q(tlb_ways)='1' and 
                                               tlb_tag4_q(tagpos_wq+1)='0' and tlb_tag4_q(tagpos_ind)='0' and multihit='0') 
                            else '0' when tlb_tag4_erat_data_cap='1' 
                            else tlb_erat_rel_clone_q(eratpos_wren);
tlb_erat_rel_clone_d(eratpos_rpnrsvd TO eratpos_rpnrsvd+3) <=  (others => '0');
tlb_erat_rel_clone_d(eratpos_rpn TO eratpos_rpn+rpn_width-1) <=  tlb_tag4_way_or(waypos_rpn to waypos_rpn+rpn_width-1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_rpn to eratpos_rpn+rpn_width-1);
tlb_erat_rel_clone_d(eratpos_r TO eratpos_c) <=  tlb_tag4_way_or(waypos_rc to waypos_rc+1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_r to eratpos_c);
tlb_erat_rel_clone_d(eratpos_relsoon) <=  derat_req_taken or ptereload_req_taken or tlb_tag0_type(0);
tlb_erat_rel_clone_d(eratpos_wlc TO eratpos_wlc+1) <=  tlb_tag4_way_or(waypos_wlc to waypos_wlc+1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_wlc to eratpos_wlc+1);
tlb_erat_rel_clone_d(eratpos_resvattr) <=  tlb_tag4_way_or(waypos_resvattr) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_resvattr);
tlb_erat_rel_clone_d(eratpos_vf) <=  tlb_tag4_way_or(waypos_vf) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_vf);
tlb_erat_rel_clone_d(eratpos_ubits TO eratpos_ubits+3) <=  tlb_tag4_way_or(waypos_ubits to waypos_ubits+3) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_ubits to eratpos_ubits+3);
tlb_erat_rel_clone_d(eratpos_wimge TO eratpos_wimge+4) <=  tlb_tag4_way_or(waypos_wimge to waypos_wimge+4) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_wimge to eratpos_wimge+4);
tlb_erat_rel_clone_d(eratpos_usxwr TO eratpos_usxwr+5) <=  tlb_tag4_way_or(waypos_usxwr to waypos_usxwr+5) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_usxwr to eratpos_usxwr+5);
tlb_erat_rel_clone_d(eratpos_gs) <=  tlb_tag4_way_or(waypos_gs) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_gs);
tlb_erat_rel_clone_d(eratpos_ts) <=  tlb_tag4_way_or(waypos_ts) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_ts);
tlb_erat_rel_clone_d(eratpos_tid TO eratpos_tid+pid_width_erat-1) <=  tlb_tag4_way_or(waypos_tid+6 to waypos_tid+14-1) 
                  when tlb_tag4_erat_data_cap='1' else tlb_erat_rel_clone_q(eratpos_tid to eratpos_tid+pid_width_erat-1);
tlb_tag4_erat_data_cap  <=  '1' when ((tlb_tag4_q(tagpos_type_ierat)='1' or tlb_tag4_q(tagpos_type_derat)='1') and 
                               tlb_tag4_q(tagpos_type_ptereload)='0' and tlb_tag4_q(tagpos_ind)='0'  and 
                               (tlb_tag4_wayhit_q(tlb_ways)='1' or or_reduce(tag4_parerr_q(0 to 4))='1') and
                                (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not tlb_ctl_tag4_flush)/="0000" ) 
                     else '1' when ((tlb_tag4_q(tagpos_type_ierat)='1' or tlb_tag4_q(tagpos_type_derat)='1') and 
                               tlb_tag4_q(tagpos_type_ptereload)='1' and tlb_tag4_q(tagpos_ind)='0' and
                               tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" )  
                     else '0';
erat_pgsize(0 TO 2) <=  ERAT_PgSize_1GB  when tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB
                 else  ERAT_PgSize_16MB when tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB
                 else  ERAT_PgSize_1MB  when tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB
                 else  ERAT_PgSize_64KB when tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB
                 else  ERAT_PgSize_4KB;
tlb_erat_val_d(0 TO 3) <=  (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) or ierat_tag4_dup_thdid(0 to thdid_width-1)) 
                         when (tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and 
                                 tlb_tag4_q(tagpos_ind)='0' and tlb_tag4_wayhit_q(tlb_ways)='1' and
                                     or_reduce(tag4_parerr_q(0 to 4))='0' and  
                                  (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not tlb_ctl_tag4_flush)/="0000")  
                   else tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                         when (tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and 
                                 ((tlb_tag4_q(tagpos_endflag)='1' and tlb_tag4_wayhit_q(tlb_ways)='0') or or_reduce(tag4_parerr_q(0 to 4))='1') and
                                  (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not tlb_ctl_tag4_flush)/="0000")  
                   else tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                         when (tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1')  
                   else (others => '0');
tlb_erat_val_d(4) <=  tlb_tag4_q(tagpos_type_ierat)
                         when (tlb_tag4_q(tagpos_type_ptereload)='0' and tlb_tag4_q(tagpos_ind)='0' and 
                                 tlb_tag4_wayhit_q(tlb_ways)='1' and multihit='0' and
                                  (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not tlb_ctl_tag4_flush)/="0000") 
                   else tlb_tag4_q(tagpos_type_ierat) 
                         when (tlb_tag4_q(tagpos_type_ptereload)='1' and tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000")  
                   else '0';
tlb_erat_val_d(5 TO 8) <=  (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) or derat_tag4_dup_thdid(0 to thdid_width-1)) 
                         when (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and 
                                 tlb_tag4_q(tagpos_ind)='0' and tlb_tag4_wayhit_q(tlb_ways)='1' and
                                     or_reduce(tag4_parerr_q(0 to 4))='0' and  
                                  (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not tlb_ctl_tag4_flush)/="0000")  
                   else tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                         when (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and 
                                 ((tlb_tag4_q(tagpos_endflag)='1' and tlb_tag4_wayhit_q(tlb_ways)='0') or or_reduce(tag4_parerr_q(0 to 4))='1') and
                                  (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not tlb_ctl_tag4_flush)/="0000")  
                   else tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                         when (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='1')  
                   else (others => '0');
tlb_erat_val_d(9) <=  tlb_tag4_q(tagpos_type_derat) 
                         when (tlb_tag4_q(tagpos_type_ptereload)='0' and tlb_tag4_q(tagpos_ind)='0' and 
                                 tlb_tag4_wayhit_q(tlb_ways)='1' and multihit='0' and
                                  (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not tlb_ctl_tag4_flush)/="0000")
                   else tlb_tag4_q(tagpos_type_derat) 
                         when (tlb_tag4_q(tagpos_type_ptereload)='1' and tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000")  
                   else '0';
ierat_req0_tag4_thdid_match     <=  '1' when or_reduce(tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) and ierat_req0_thdid)='1'   else '0';
ierat_req0_tag4_pid_match       <=  '1' when (tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1)=ierat_req0_pid   or or_reduce(tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1))='0') 
                              else '0';
ierat_req0_tag4_as_match        <=  '1' when (tlb_tag4_way_or(waypos_ts)=ierat_req0_as)   else '0';
ierat_req0_tag4_gs_match        <=  '1' when (tlb_tag4_way_or(waypos_gs)=ierat_req0_gs)   else '0';
ierat_req0_tag4_epn_match       <=  '1' when (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1)=ierat_req0_epn(52-epn_width   to 51) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-5)=ierat_req0_epn(52-epn_width   to 47) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-9)=ierat_req0_epn(52-epn_width   to 43) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-13)=ierat_req0_epn(52-epn_width   to 39) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-19)=ierat_req0_epn(52-epn_width   to 33) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB)
                             else '0';
tlb_erat_dup_d(0) <=  '1' when (ierat_req0_tag4_pid_match='1'   and 
                                    ierat_req0_tag4_as_match='1'   and ierat_req0_tag4_gs_match='1'   and 
                                    ierat_req0_tag4_epn_match='1'   and ierat_req0_tag4_thdid_match='1'   and
                                    ierat_req0_valid='1'   and (ierat_req0_nonspec='1'   or (tlb_erat_dup_d(4)='0' and tlb_erat_dup_d(5)='1'))) else '0';
ierat_req1_tag4_thdid_match     <=  '1' when or_reduce(tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) and ierat_req1_thdid)='1'   else '0';
ierat_req1_tag4_pid_match       <=  '1' when (tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1)=ierat_req1_pid   or or_reduce(tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1))='0') 
                              else '0';
ierat_req1_tag4_as_match        <=  '1' when (tlb_tag4_way_or(waypos_ts)=ierat_req1_as)   else '0';
ierat_req1_tag4_gs_match        <=  '1' when (tlb_tag4_way_or(waypos_gs)=ierat_req1_gs)   else '0';
ierat_req1_tag4_epn_match       <=  '1' when (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1)=ierat_req1_epn(52-epn_width   to 51) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-5)=ierat_req1_epn(52-epn_width   to 47) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-9)=ierat_req1_epn(52-epn_width   to 43) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-13)=ierat_req1_epn(52-epn_width   to 39) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-19)=ierat_req1_epn(52-epn_width   to 33) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB)
                             else '0';
tlb_erat_dup_d(1) <=  '1' when (ierat_req1_tag4_pid_match='1'   and 
                                    ierat_req1_tag4_as_match='1'   and ierat_req1_tag4_gs_match='1'   and 
                                    ierat_req1_tag4_epn_match='1'   and ierat_req1_tag4_thdid_match='1'   and
                                    ierat_req1_valid='1'   and (ierat_req1_nonspec='1'   or (tlb_erat_dup_d(4)='0' and tlb_erat_dup_d(5)='1'))) else '0';
ierat_req2_tag4_thdid_match     <=  '1' when or_reduce(tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) and ierat_req2_thdid)='1'   else '0';
ierat_req2_tag4_pid_match       <=  '1' when (tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1)=ierat_req2_pid   or or_reduce(tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1))='0') 
                              else '0';
ierat_req2_tag4_as_match        <=  '1' when (tlb_tag4_way_or(waypos_ts)=ierat_req2_as)   else '0';
ierat_req2_tag4_gs_match        <=  '1' when (tlb_tag4_way_or(waypos_gs)=ierat_req2_gs)   else '0';
ierat_req2_tag4_epn_match       <=  '1' when (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1)=ierat_req2_epn(52-epn_width   to 51) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-5)=ierat_req2_epn(52-epn_width   to 47) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-9)=ierat_req2_epn(52-epn_width   to 43) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-13)=ierat_req2_epn(52-epn_width   to 39) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-19)=ierat_req2_epn(52-epn_width   to 33) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB)
                             else '0';
tlb_erat_dup_d(2) <=  '1' when (ierat_req2_tag4_pid_match='1'   and 
                                    ierat_req2_tag4_as_match='1'   and ierat_req2_tag4_gs_match='1'   and 
                                    ierat_req2_tag4_epn_match='1'   and ierat_req2_tag4_thdid_match='1'   and
                                    ierat_req2_valid='1'   and (ierat_req2_nonspec='1'   or (tlb_erat_dup_d(4)='0' and tlb_erat_dup_d(5)='1'))) else '0';
ierat_req3_tag4_thdid_match     <=  '1' when or_reduce(tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) and ierat_req3_thdid)='1'   else '0';
ierat_req3_tag4_pid_match       <=  '1' when (tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1)=ierat_req3_pid   or or_reduce(tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1))='0') 
                              else '0';
ierat_req3_tag4_as_match        <=  '1' when (tlb_tag4_way_or(waypos_ts)=ierat_req3_as)   else '0';
ierat_req3_tag4_gs_match        <=  '1' when (tlb_tag4_way_or(waypos_gs)=ierat_req3_gs)   else '0';
ierat_req3_tag4_epn_match       <=  '1' when (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1)=ierat_req3_epn(52-epn_width   to 51) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-5)=ierat_req3_epn(52-epn_width   to 47) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-9)=ierat_req3_epn(52-epn_width   to 43) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-13)=ierat_req3_epn(52-epn_width   to 39) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-19)=ierat_req3_epn(52-epn_width   to 33) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB)
                             else '0';
tlb_erat_dup_d(3) <=  '1' when (ierat_req3_tag4_pid_match='1'   and 
                                    ierat_req3_tag4_as_match='1'   and ierat_req3_tag4_gs_match='1'   and 
                                    ierat_req3_tag4_epn_match='1'   and ierat_req3_tag4_thdid_match='1'   and
                                    ierat_req3_valid='1'   and (ierat_req3_nonspec='1'   or (tlb_erat_dup_d(4)='0' and tlb_erat_dup_d(5)='1'))) else '0';
ierat_iu4_tag4_thdid_match   <=  '1' when or_reduce(tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) and ierat_iu4_thdid)='1' else '0';
ierat_iu4_tag4_lpid_match    <=  '1' when (tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1)=lpidr or or_reduce(tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1))='0') else '0';
ierat_iu4_tag4_pid_match     <=  '1' when (tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1)=ierat_iu4_pid or or_reduce(tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1))='0') else '0';
ierat_iu4_tag4_as_match      <=  '1' when (tlb_tag4_way_or(waypos_ts)=ierat_iu4_as) else '0';
ierat_iu4_tag4_gs_match      <=  '1' when (tlb_tag4_way_or(waypos_gs)=ierat_iu4_gs) else '0';
ierat_iu4_tag4_epn_match     <=  '1' when (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1)=ierat_iu4_epn(52-epn_width to 51) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-5)=ierat_iu4_epn(52-epn_width to 47) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-9)=ierat_iu4_epn(52-epn_width to 43) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-13)=ierat_iu4_epn(52-epn_width to 39) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-19)=ierat_iu4_epn(52-epn_width to 33) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB)
                             else '0';
derat_req0_tag4_thdid_match     <=  '1' when or_reduce(tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) and derat_req0_thdid)='1'   else '0';
derat_req0_tag4_lpid_match      <=  '1' when (tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1)=derat_req0_lpid   or or_reduce(tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1))='0') 
                             else '0';
derat_req0_tag4_pid_match       <=  '1' when (tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1)=derat_req0_pid   or or_reduce(tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1))='0') 
                             else '0';
derat_req0_tag4_as_match        <=  '1' when (tlb_tag4_way_or(waypos_ts)=derat_req0_as)   else '0';
derat_req0_tag4_gs_match        <=  '1' when (tlb_tag4_way_or(waypos_gs)=derat_req0_gs)   else '0';
derat_req0_tag4_epn_match       <=  '1' when (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1)=derat_req0_epn(52-epn_width   to 51) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-5)=derat_req0_epn(52-epn_width   to 47) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-9)=derat_req0_epn(52-epn_width   to 43) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-13)=derat_req0_epn(52-epn_width   to 39) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-19)=derat_req0_epn(52-epn_width   to 33) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB)
                             else '0';
tlb_erat_dup_d(10) <=  '1' when (derat_req0_tag4_lpid_match='1'   and derat_req0_tag4_pid_match='1'   and 
                                    derat_req0_tag4_as_match='1'   and derat_req0_tag4_gs_match='1'   and 
                                    derat_req0_tag4_epn_match='1'   and derat_req0_tag4_thdid_match='1'   and
                                    derat_req0_valid='1')   else '0';
derat_req1_tag4_thdid_match     <=  '1' when or_reduce(tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) and derat_req1_thdid)='1'   else '0';
derat_req1_tag4_lpid_match      <=  '1' when (tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1)=derat_req1_lpid   or or_reduce(tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1))='0') 
                             else '0';
derat_req1_tag4_pid_match       <=  '1' when (tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1)=derat_req1_pid   or or_reduce(tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1))='0') 
                             else '0';
derat_req1_tag4_as_match        <=  '1' when (tlb_tag4_way_or(waypos_ts)=derat_req1_as)   else '0';
derat_req1_tag4_gs_match        <=  '1' when (tlb_tag4_way_or(waypos_gs)=derat_req1_gs)   else '0';
derat_req1_tag4_epn_match       <=  '1' when (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1)=derat_req1_epn(52-epn_width   to 51) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-5)=derat_req1_epn(52-epn_width   to 47) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-9)=derat_req1_epn(52-epn_width   to 43) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-13)=derat_req1_epn(52-epn_width   to 39) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-19)=derat_req1_epn(52-epn_width   to 33) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB)
                             else '0';
tlb_erat_dup_d(11) <=  '1' when (derat_req1_tag4_lpid_match='1'   and derat_req1_tag4_pid_match='1'   and 
                                    derat_req1_tag4_as_match='1'   and derat_req1_tag4_gs_match='1'   and 
                                    derat_req1_tag4_epn_match='1'   and derat_req1_tag4_thdid_match='1'   and
                                    derat_req1_valid='1')   else '0';
derat_req2_tag4_thdid_match     <=  '1' when or_reduce(tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) and derat_req2_thdid)='1'   else '0';
derat_req2_tag4_lpid_match      <=  '1' when (tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1)=derat_req2_lpid   or or_reduce(tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1))='0') 
                             else '0';
derat_req2_tag4_pid_match       <=  '1' when (tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1)=derat_req2_pid   or or_reduce(tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1))='0') 
                             else '0';
derat_req2_tag4_as_match        <=  '1' when (tlb_tag4_way_or(waypos_ts)=derat_req2_as)   else '0';
derat_req2_tag4_gs_match        <=  '1' when (tlb_tag4_way_or(waypos_gs)=derat_req2_gs)   else '0';
derat_req2_tag4_epn_match       <=  '1' when (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1)=derat_req2_epn(52-epn_width   to 51) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-5)=derat_req2_epn(52-epn_width   to 47) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-9)=derat_req2_epn(52-epn_width   to 43) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-13)=derat_req2_epn(52-epn_width   to 39) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-19)=derat_req2_epn(52-epn_width   to 33) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB)
                             else '0';
tlb_erat_dup_d(12) <=  '1' when (derat_req2_tag4_lpid_match='1'   and derat_req2_tag4_pid_match='1'   and 
                                    derat_req2_tag4_as_match='1'   and derat_req2_tag4_gs_match='1'   and 
                                    derat_req2_tag4_epn_match='1'   and derat_req2_tag4_thdid_match='1'   and
                                    derat_req2_valid='1')   else '0';
derat_req3_tag4_thdid_match     <=  '1' when or_reduce(tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) and derat_req3_thdid)='1'   else '0';
derat_req3_tag4_lpid_match      <=  '1' when (tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1)=derat_req3_lpid   or or_reduce(tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1))='0') 
                             else '0';
derat_req3_tag4_pid_match       <=  '1' when (tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1)=derat_req3_pid   or or_reduce(tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1))='0') 
                             else '0';
derat_req3_tag4_as_match        <=  '1' when (tlb_tag4_way_or(waypos_ts)=derat_req3_as)   else '0';
derat_req3_tag4_gs_match        <=  '1' when (tlb_tag4_way_or(waypos_gs)=derat_req3_gs)   else '0';
derat_req3_tag4_epn_match       <=  '1' when (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1)=derat_req3_epn(52-epn_width   to 51) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-5)=derat_req3_epn(52-epn_width   to 47) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-9)=derat_req3_epn(52-epn_width   to 43) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-13)=derat_req3_epn(52-epn_width   to 39) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-19)=derat_req3_epn(52-epn_width   to 33) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB)
                             else '0';
tlb_erat_dup_d(13) <=  '1' when (derat_req3_tag4_lpid_match='1'   and derat_req3_tag4_pid_match='1'   and 
                                    derat_req3_tag4_as_match='1'   and derat_req3_tag4_gs_match='1'   and 
                                    derat_req3_tag4_epn_match='1'   and derat_req3_tag4_thdid_match='1'   and
                                    derat_req3_valid='1')   else '0';
derat_ex5_tag4_thdid_match   <=  '1' when or_reduce(tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1) and derat_ex5_thdid)='1' else '0';
derat_ex5_tag4_lpid_match    <=  '1' when (tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1)=derat_ex5_lpid or or_reduce(tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1))='0') else '0';
derat_ex5_tag4_pid_match     <=  '1' when (tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1)=derat_ex5_pid or or_reduce(tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1))='0') else '0';
derat_ex5_tag4_as_match      <=  '1' when (tlb_tag4_way_or(waypos_ts)=derat_ex5_as) else '0';
derat_ex5_tag4_gs_match      <=  '1' when (tlb_tag4_way_or(waypos_gs)=derat_ex5_gs) else '0';
derat_ex5_tag4_epn_match     <=  '1' when (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-1)=derat_ex5_epn(52-epn_width to 51) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-5)=derat_ex5_epn(52-epn_width to 47) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-9)=derat_ex5_epn(52-epn_width to 43) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-13)=derat_ex5_epn(52-epn_width to 39) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag4_way_or(waypos_epn to waypos_epn+epn_width-19)=derat_ex5_epn(52-epn_width to 33) and tlb_tag4_way_or(waypos_size to waypos_size+3)=TLB_PgSize_1GB)
                             else '0';
tlb_erat_dup_d(4) <=  tlb_tag4_q(tagpos_type_ierat)
                         when (tlb_tag4_q(tagpos_type_ptereload)='0' and tlb_tag4_way_or(waypos_ind)='0' and 
                                 tlb_tag4_wayhit_q(tlb_ways)='1' and multihit='0' and 
                                    tlb_tag4_q(tagpos_wq+1)='0' and or_reduce(tag4_parerr_q(0 to 4))='0') 
                   else '0';
tlb_erat_dup_d(5) <=  '1' when (tlb_erat_dup_d(4)='1' or tlb_erat_dup_q(4)='1')    
                 else '1' when tlb_erat_dup_q(7 to 9)/="000"  
                 else '0';
tlb_erat_dup_d(6) <=  tlb_tag4_q(tagpos_type_ierat) when 
                                   (ierat_iu4_tag4_lpid_match='1' and ierat_iu4_tag4_pid_match='1' and 
                                    ierat_iu4_tag4_as_match='1' and ierat_iu4_tag4_gs_match='1' and 
                                    ierat_iu4_tag4_epn_match='1' and ierat_iu4_tag4_thdid_match='1' and
                                    ierat_iu4_valid='1' and tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000") else '0';
tlb_erat_dup_d(7 TO 9) <=  "001" when (tlb_erat_dup_q(4)='1' and tlb_erat_dup_q(7 to 9)="000")
                       else "010" when tlb_erat_dup_q(7 to 9)="001" 
                       else "011" when tlb_erat_dup_q(7 to 9)="010" 
                       else "100" when tlb_erat_dup_q(7 to 9)="011"
                       else "101" when tlb_erat_dup_q(7 to 9)="100"
                       else "110" when tlb_erat_dup_q(7 to 9)="101"
                       else "111" when tlb_erat_dup_q(7 to 9)="110"
                       else "000" when tlb_erat_dup_q(7 to 9)="111"  
                       else tlb_erat_dup_q(7 to 9);
tlb_erat_dup_d(14) <=  tlb_tag4_q(tagpos_type_derat) 
                         when (tlb_tag4_q(tagpos_type_ptereload)='0' and tlb_tag4_way_or(waypos_ind)='0' and 
                                 tlb_tag4_wayhit_q(tlb_ways)='1' and multihit='0' and 
                                    tlb_tag4_q(tagpos_wq+1)='0' and or_reduce(tag4_parerr_q(0 to 4))='0') 
                   else '0';
tlb_erat_dup_d(15) <=  '1' when (tlb_erat_dup_d(14)='1' or tlb_erat_dup_q(14)='1')    
                 else '1' when tlb_erat_dup_q(17 to 19)/="000"  
                 else '0';
tlb_erat_dup_d(16) <=  tlb_tag4_q(tagpos_type_derat) when 
                                   (derat_ex5_tag4_lpid_match='1' and derat_ex5_tag4_pid_match='1' and 
                                    derat_ex5_tag4_as_match='1' and derat_ex5_tag4_gs_match='1' and 
                                    derat_ex5_tag4_epn_match='1' and derat_ex5_tag4_thdid_match='1' and
                                    derat_ex5_valid='1' and tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000") else '0';
tlb_erat_dup_d(17 TO 19) <=  "001" when (tlb_erat_dup_q(14)='1' and tlb_erat_dup_q(17 to 19)="000")
                       else "010" when tlb_erat_dup_q(17 to 19)="001" 
                       else "011" when tlb_erat_dup_q(17 to 19)="010" 
                       else "100" when tlb_erat_dup_q(17 to 19)="011"
                       else "101" when tlb_erat_dup_q(17 to 19)="100"
                       else "110" when tlb_erat_dup_q(17 to 19)="101"
                       else "111" when tlb_erat_dup_q(17 to 19)="110"
                       else "000" when tlb_erat_dup_q(17 to 19)="111"  
                       else tlb_erat_dup_q(17 to 19);
ierat_tag4_dup_thdid      <=   ((0 to 3 => tlb_erat_dup_d(0)) and ierat_req0_thdid(0 to 3) and (0 to 3 => ierat_req0_nonspec) and (0 to 3 => not tlb_tag4_q(tagpos_wq+1))) or  
                              ((0 to 3 => tlb_erat_dup_d(1)) and ierat_req1_thdid(0 to 3) and (0 to 3 => ierat_req1_nonspec) and (0 to 3 => not tlb_tag4_q(tagpos_wq+1))) or
                              ((0 to 3 => tlb_erat_dup_d(2)) and ierat_req2_thdid(0 to 3) and (0 to 3 => ierat_req2_nonspec) and (0 to 3 => not tlb_tag4_q(tagpos_wq+1))) or
                              ((0 to 3 => tlb_erat_dup_d(3)) and ierat_req3_thdid(0 to 3) and (0 to 3 => ierat_req3_nonspec) and (0 to 3 => not tlb_tag4_q(tagpos_wq+1)));
derat_tag4_dup_thdid      <=   ((0 to 3 => tlb_erat_dup_d(10)) and derat_req0_thdid(0 to 3) and (0 to 3 => not tlb_tag4_q(tagpos_wq+1))) or 
                              ((0 to 3 => tlb_erat_dup_d(11)) and derat_req1_thdid(0 to 3) and (0 to 3 => not tlb_tag4_q(tagpos_wq+1))) or
                              ((0 to 3 => tlb_erat_dup_d(12)) and derat_req2_thdid(0 to 3) and (0 to 3 => not tlb_tag4_q(tagpos_wq+1))) or
                              ((0 to 3 => tlb_erat_dup_d(13)) and derat_req3_thdid(0 to 3) and (0 to 3 => not tlb_tag4_q(tagpos_wq+1)));
tlb_tag4_epcr_dgtmi  <=  or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and xu_mm_epcr_dgtmi);
tlb_tag4_size_not_supp  <=  '0' when (tlb_tag4_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB or tlb_tag4_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB or
                              tlb_tag4_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB or  tlb_tag4_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB or 
                              tlb_tag4_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB or 
                              (tlb_tag4_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB and tlb_tag4_q(tagpos_ind)='1')) else '1';
eratmiss_done_d  <=  tlb_erat_val_q(0 to 3) or tlb_erat_val_q(5 to 8);
tlb_miss_d  <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                  when ((tlb_tag4_q(tagpos_type_ierat)='1' or tlb_tag4_q(tagpos_type_derat)='1') and tlb_tag4_q(tagpos_type_ptereload)='0' and 
                          tlb_tag4_q(tagpos_endflag)='1' and tlb_tag4_wayhit_q(0 to 3) = "0000"     
                            and or_reduce(tag4_parerr_q(0 to 4))='0')  
         else (others => '0');
tlb_inelig_d  <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                  when (tlb_tag4_q(tagpos_type_ptereload)='1' and tlb_tag4_q(tagpos_is)='1' and lru_tag4_dataout_q(0 to 3)="1111" and lru_tag4_dataout_q(8 to 11)="1111")  
                    or (tlb_tag4_q(tagpos_type_ptereload)='1' and tlb_tag4_q(tagpos_is)='1' and tlb_tag4_size_not_supp='1')  
                    or (tlb_tag4_q(tagpos_type_ptereload)='1' and tlb_tag4_q(tagpos_is)='1' and tlb_tag4_q(tagpos_pt)='0')  
         else (others => '0');
lrat_miss_d   <=  (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag4_flush)) 
                  when ( ((or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and tlb_resv_match_vec)='1' 
                                         and tlb_tag4_q(tagpos_wq to tagpos_wq+1)="01" and mmucfg_twc='1')  
                                           or tlb_tag4_q(tagpos_wq to tagpos_wq+1)="00" or tlb_tag4_q(tagpos_wq to tagpos_wq+1)="11") and  
                              tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_pr)='0' and 
                               tlb_tag4_epcr_dgtmi='0' and mmucfg_lrat='1' and
                                tlb_tag4_q(tagpos_is)='1' and lrat_tag4_hit_status(0 to 3)/="1100" ) 
        else tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                  when (tlb_tag4_q(tagpos_type_ptereload)='1' and tlb_tag4_q(tagpos_gs)='1' and mmucfg_lrat='1' and 
                          tlb_tag4_q(tagpos_is)='1' and lrat_tag4_hit_status(0 to 3)/="1100" and   
                            tlb_tag4_q(tagpos_wq to tagpos_wq+1)="10" and   
                             tlb_tag4_q(tagpos_pt)='1')       
        else (others => '0');
pt_fault_d    <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                  when ( tlb_tag4_q(tagpos_type_ptereload)='1' and tlb_tag4_q(tagpos_is)='0' and  
                             tlb_tag4_q(tagpos_wq to tagpos_wq+1)="10" and  
                               tlb_tag4_q(tagpos_pt)='1' )    
         else (others => '0');
hv_priv_d   <=  (tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag4_flush))  
    when ( tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_pr)='0' and tlb0cfg_gtwe='0' ) or 
          ( tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_pr)='0' and mmucfg_lrat='0' ) or 

          ( tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_pr)='0' and tlb_tag4_q(tagpos_hes)='1' 
             and (tlb_tag4_q(tagpos_wq to tagpos_wq+1)="00" or tlb_tag4_q(tagpos_wq to tagpos_wq+1)="11" or
                     (tlb_tag4_q(tagpos_wq to tagpos_wq+1)="01" and (or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and tlb_resv_match_vec)='1'))) and
             ((lru_tag4_dataout_q(0)='1' and lru_tag4_dataout_q(4 to 5)="00" and lru_tag4_dataout_q(8)='1') or 
              (lru_tag4_dataout_q(1)='1' and lru_tag4_dataout_q(4 to 5)="01" and lru_tag4_dataout_q(9)='1') or
              (lru_tag4_dataout_q(2)='1' and lru_tag4_dataout_q(4)='1' and lru_tag4_dataout_q(6)='0' and lru_tag4_dataout_q(10)='1') or
              (lru_tag4_dataout_q(3)='1' and lru_tag4_dataout_q(4)='1' and lru_tag4_dataout_q(6)='1' and lru_tag4_dataout_q(11)='1')) ) or  
          ( tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_pr)='0' and tlb_tag4_q(tagpos_hes)='1' 
             and  (tlb_tag4_q(tagpos_wq to tagpos_wq+1)="00" or tlb_tag4_q(tagpos_wq to tagpos_wq+1)="11" or 
                     (tlb_tag4_q(tagpos_wq to tagpos_wq+1)="01" and (or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and tlb_resv_match_vec)='1'))) and 
               tlb_tag4_q(tagpos_is+1)='1' ) or 

          ( tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_pr)='0' and tlb_tag4_q(tagpos_hes)='0' and tlb_tag4_q(tagpos_wq to tagpos_wq+1)/="10")  

    else (others => '0');
esr_pt_d     <=  (pt_fault_d or lrat_miss_d) and (0 to 3 => tlb_tag4_q(tagpos_type_ptereload));
esr_data_d   <=  (tlb_miss_d or pt_fault_d or tlb_inelig_d or lrat_miss_d) and (0 to 3 => tlb_tag4_q(tagpos_type_derat));
esr_st_d     <=  (tlb_miss_d or pt_fault_d or tlb_inelig_d or lrat_miss_d) and (0 to 3 => tlb_tag4_q(tagpos_type_derat)) and (0 to 3 => tlb_tag4_q(tagpos_class+1));
esr_epid_d   <=  (tlb_miss_d or pt_fault_d or tlb_inelig_d or lrat_miss_d) and (0 to 3 => tlb_tag4_q(tagpos_type_derat)) and (0 to 3 => tlb_tag4_q(tagpos_class));
cr0_eq_d         <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
          when ( (tlb_tag4_q(tagpos_type_tlbsrx)='1' or (tlb_tag4_q(tagpos_type_tlbsx)='1' and tlb_tag4_q(tagpos_recform)='1')) and
                    tlb_tag4_wayhit_q(tlb_ways)='1' and multihit='0' and or_reduce(tag4_parerr_q(0 to 4))='0' )  
        else (others => '0');
cr0_eq_valid_d   <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
          when ( (tlb_tag4_q(tagpos_type_tlbsrx)='1' or (tlb_tag4_q(tagpos_type_tlbsx)='1' and tlb_tag4_q(tagpos_recform)='1')) and 
                    (tlb_tag4_q(tagpos_endflag)='1' or (tlb_tag4_wayhit_q(tlb_ways)='1' and multihit='0')) and or_reduce(tag4_parerr_q(0 to 4))='0' )
        else (others => '0');
tlb_multihit_err_d  <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
               when ( ((tlb_tag4_q(tagpos_type_derat to tagpos_type_ierat)/="00" and tlb_tag4_q(tagpos_type_ptereload)='0') or 
                           (tlb_tag4_q(tagpos_type_tlbsx to tagpos_type_tlbsrx)/="00"))  and
                         multihit='1' and (tlb_tag4_q(tagpos_endflag)='1' or tlb_tag4_wayhit_q(tlb_ways)='1')) 
         else (others => '0');
parerr_gen0: if check_parity = 0 generate
tlb_par_err_d       <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                          and (0 to 3 => tag4_parerr_q(0) and not(tag4_parerr_q(0)) and or_reduce(tlb_tag4_q(tagpos_type_derat to tagpos_type_tlbre)));
lru_par_err_d       <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                          and (0 to 3 => tag4_parerr_q(2) and not(tag4_parerr_q(2)) and or_reduce(tlb_tag4_q(tagpos_type_derat to tagpos_type_tlbre)));
tlb_tag4_tlbre_parerr  <=  '0';
ECO107332_tlb_par_err_d  <=  tlb_par_err_d;
ECO107332_lru_par_err_d  <=  lru_par_err_d;
end generate parerr_gen0;
parerr_gen1: if check_parity = 1 generate
tlb_par_err_d       <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                          and ( 0 to 3 => (or_reduce(tag4_parerr_q(0 to 3)) and or_reduce(tlb_tag4_q(tagpos_type_derat to tagpos_type_tlbsrx))) or
                                            (tag4_parerr_q(0) and tlb_tag4_q(tagpos_type_tlbre) and not tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2)) or 
                                            (tag4_parerr_q(1) and tlb_tag4_q(tagpos_type_tlbre) and not tlb_tag4_q(tagpos_esel+1) and      tlb_tag4_q(tagpos_esel+2)) or 
                                            (tag4_parerr_q(2) and tlb_tag4_q(tagpos_type_tlbre) and      tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2)) or 
                                            (tag4_parerr_q(3) and tlb_tag4_q(tagpos_type_tlbre) and      tlb_tag4_q(tagpos_esel+1) and      tlb_tag4_q(tagpos_esel+2)) );
lru_par_err_d       <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                          and (0 to 3 => tag4_parerr_q(4) and (or_reduce(tlb_tag4_q(tagpos_type_derat to tagpos_type_tlbsrx)) or tlb_tag4_q(tagpos_type_tlbre)));
ECO107332_tlb_par_err_d  <=  tlb_par_err_d and not(tlb_ctl_tag4_flush);
ECO107332_lru_par_err_d  <=  lru_par_err_d and not(tlb_ctl_tag4_flush);
tlb_tag4_tlbre_parerr  <=   (tag4_parerr_q(0) and tlb_tag4_q(tagpos_type_tlbre) and not tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2)) or 
                           (tag4_parerr_q(1) and tlb_tag4_q(tagpos_type_tlbre) and not tlb_tag4_q(tagpos_esel+1) and      tlb_tag4_q(tagpos_esel+2)) or 
                           (tag4_parerr_q(2) and tlb_tag4_q(tagpos_type_tlbre) and      tlb_tag4_q(tagpos_esel+1) and not tlb_tag4_q(tagpos_esel+2)) or 
                           (tag4_parerr_q(3) and tlb_tag4_q(tagpos_type_tlbre) and      tlb_tag4_q(tagpos_esel+1) and      tlb_tag4_q(tagpos_esel+2)) or
                           (tag4_parerr_q(4) and tlb_tag4_q(tagpos_type_tlbre));
end generate parerr_gen1;
tlb_tag5_except_d  <=  (hv_priv_d or lrat_miss_d or tlb_inelig_d or pt_fault_d or 
                        tlb_multihit_err_d or tlb_par_err_d or lru_par_err_d);
tlb_isi_d  <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
               when (tlb_tag4_q(tagpos_type_ierat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0' and 
                       tlb_tag4_wayhit_q(0 to 3) = "0000" and tlb_tag4_q(tagpos_endflag)='1') 
         else (others => '0');
tlb_dsi_d  <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                when (tlb_tag4_q(tagpos_type_derat)='1' and tlb_tag4_q(tagpos_type_ptereload)='0'  and 
                        tlb_tag4_wayhit_q(0 to 3) = "0000" and tlb_tag4_q(tagpos_endflag)='1') 
         else (others => '0');
matchline_comb0   : mmq_tlb_matchline
 generic map (have_xbit => 1, num_pgsizes => 5, have_cmpmask => 1, cmpmask_width => 5)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => tlb_tag3_clone1_q(tagpos_epn to tagpos_epn+epn_width-1), 
    addr_enable                      => addr_enable,
    comp_pgsize                      => tlb_tag3_clone1_q(tagpos_size to tagpos_size+3), 
    pgsize_enable                    => pgsize_enable, 
    entry_size                       => tlb_way0_q(waypos_size   to waypos_size+3), 
    entry_cmpmask                    => tlb_way0_cmpmask_q,   
    entry_xbit                       => tlb_way0_q(waypos_xbit),   
    entry_xbitmask                   => tlb_way0_xbitmask_q,   
    entry_epn                        => tlb_way0_q(waypos_epn   to waypos_epn+epn_width-1), 
    comp_class                       => tlb_tag3_clone1_q(tagpos_class to tagpos_class+1), 
    entry_class                      => tlb_way0_q(waypos_class   to waypos_class+1), 
    class_enable                     => class_enable, 
    comp_extclass                    => comp_extclass, 
    entry_extclass                   => tlb_way0_q(waypos_extclass   to waypos_extclass+1), 
    extclass_enable                  => extclass_enable, 
    comp_state                       => tlb_tag3_clone1_q(tagpos_state+1 to tagpos_state+2), 
    entry_gs                         => tlb_way0_q(waypos_gs),   
    entry_ts                         => tlb_way0_q(waypos_ts),   
    state_enable                     => state_enable, 
    entry_thdid                      => tlb_way0_q(waypos_thdid   to waypos_thdid+thdid_width-1), 
    comp_thdid                       => tlb_tag3_clone1_q(tagpos_thdid to tagpos_thdid+thdid_width-1), 
    thdid_enable                     => thdid_enable, 
    entry_pid                        => tlb_way0_q(waypos_tid   to waypos_tid+pid_width-1), 
    comp_pid                         => tlb_tag3_clone1_q(tagpos_pid to tagpos_pid+pid_width-1), 
    pid_enable                       => pid_enable, 
    entry_lpid                       => tlb_way0_q(waypos_lpid   to waypos_lpid+lpid_width-1),
    comp_lpid                        => tlb_tag3_clone1_q(tagpos_lpid to tagpos_lpid+lpid_width-1),
    lpid_enable                      => lpid_enable,
    entry_ind                        => tlb_way0_q(waypos_ind),
    comp_ind                         => comp_ind,  
    ind_enable                       => ind_enable,
    entry_iprot                      => lru_tag3_dataout_q(8),     
    comp_iprot                       => comp_iprot,  
    iprot_enable                     => iprot_enable,
    entry_v                          => lru_tag3_dataout_q(0),   
    comp_invalidate                  => tlb_tag3_clone1_q(tagpos_type_snoop), 

    match                            => tlb_wayhit(0),    
    dbg_addr_match                   => tlb_way0_addr_match,
    dbg_pgsize_match                 => tlb_way0_pgsize_match,
    dbg_class_match                  => tlb_way0_class_match,
    dbg_extclass_match               => tlb_way0_extclass_match,
    dbg_state_match                  => tlb_way0_state_match,
    dbg_thdid_match                  => tlb_way0_thdid_match,
    dbg_pid_match                    => tlb_way0_pid_match,
    dbg_lpid_match                   => tlb_way0_lpid_match,
    dbg_ind_match                    => tlb_way0_ind_match,
    dbg_iprot_match                  => tlb_way0_iprot_match
  );
matchline_comb1   : mmq_tlb_matchline
 generic map (have_xbit => 1, num_pgsizes => 5, have_cmpmask => 1, cmpmask_width => 5)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => tlb_tag3_clone1_q(tagpos_epn to tagpos_epn+epn_width-1), 
    addr_enable                      => addr_enable,
    comp_pgsize                      => tlb_tag3_clone1_q(tagpos_size to tagpos_size+3), 
    pgsize_enable                    => pgsize_enable, 
    entry_size                       => tlb_way1_q(waypos_size   to waypos_size+3), 
    entry_cmpmask                    => tlb_way1_cmpmask_q,   
    entry_xbit                       => tlb_way1_q(waypos_xbit),   
    entry_xbitmask                   => tlb_way1_xbitmask_q,   
    entry_epn                        => tlb_way1_q(waypos_epn   to waypos_epn+epn_width-1), 
    comp_class                       => tlb_tag3_clone1_q(tagpos_class to tagpos_class+1), 
    entry_class                      => tlb_way1_q(waypos_class   to waypos_class+1), 
    class_enable                     => class_enable, 
    comp_extclass                    => comp_extclass, 
    entry_extclass                   => tlb_way1_q(waypos_extclass   to waypos_extclass+1), 
    extclass_enable                  => extclass_enable, 
    comp_state                       => tlb_tag3_clone1_q(tagpos_state+1 to tagpos_state+2), 
    entry_gs                         => tlb_way1_q(waypos_gs),   
    entry_ts                         => tlb_way1_q(waypos_ts),   
    state_enable                     => state_enable, 
    entry_thdid                      => tlb_way1_q(waypos_thdid   to waypos_thdid+thdid_width-1), 
    comp_thdid                       => tlb_tag3_clone1_q(tagpos_thdid to tagpos_thdid+thdid_width-1), 
    thdid_enable                     => thdid_enable, 
    entry_pid                        => tlb_way1_q(waypos_tid   to waypos_tid+pid_width-1), 
    comp_pid                         => tlb_tag3_clone1_q(tagpos_pid to tagpos_pid+pid_width-1), 
    pid_enable                       => pid_enable, 
    entry_lpid                       => tlb_way1_q(waypos_lpid   to waypos_lpid+lpid_width-1),
    comp_lpid                        => tlb_tag3_clone1_q(tagpos_lpid to tagpos_lpid+lpid_width-1),
    lpid_enable                      => lpid_enable,
    entry_ind                        => tlb_way1_q(waypos_ind),
    comp_ind                         => comp_ind,  
    ind_enable                       => ind_enable,
    entry_iprot                      => lru_tag3_dataout_q(9),     
    comp_iprot                       => comp_iprot,  
    iprot_enable                     => iprot_enable,
    entry_v                          => lru_tag3_dataout_q(1),   
    comp_invalidate                  => tlb_tag3_clone1_q(tagpos_type_snoop), 

    match                            => tlb_wayhit(1),    
    dbg_addr_match                   => tlb_way1_addr_match,
    dbg_pgsize_match                 => tlb_way1_pgsize_match,
    dbg_class_match                  => tlb_way1_class_match,
    dbg_extclass_match               => tlb_way1_extclass_match,
    dbg_state_match                  => tlb_way1_state_match,
    dbg_thdid_match                  => tlb_way1_thdid_match,
    dbg_pid_match                    => tlb_way1_pid_match,
    dbg_lpid_match                   => tlb_way1_lpid_match,
    dbg_ind_match                    => tlb_way1_ind_match,
    dbg_iprot_match                  => tlb_way1_iprot_match
  );
matchline_comb2   : mmq_tlb_matchline
 generic map (have_xbit => 1, num_pgsizes => 5, have_cmpmask => 1, cmpmask_width => 5)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => tlb_tag3_clone2_q(tagpos_epn to tagpos_epn+epn_width-1), 
    addr_enable                      => addr_enable_clone,
    comp_pgsize                      => tlb_tag3_clone2_q(tagpos_size to tagpos_size+3), 
    pgsize_enable                    => pgsize_enable_clone, 
    entry_size                       => tlb_way2_q(waypos_size   to waypos_size+3), 
    entry_cmpmask                    => tlb_way2_cmpmask_q,   
    entry_xbit                       => tlb_way2_q(waypos_xbit),   
    entry_xbitmask                   => tlb_way2_xbitmask_q,   
    entry_epn                        => tlb_way2_q(waypos_epn   to waypos_epn+epn_width-1), 
    comp_class                       => tlb_tag3_clone2_q(tagpos_class to tagpos_class+1), 
    entry_class                      => tlb_way2_q(waypos_class   to waypos_class+1), 
    class_enable                     => class_enable_clone, 
    comp_extclass                    => comp_extclass_clone, 
    entry_extclass                   => tlb_way2_q(waypos_extclass   to waypos_extclass+1), 
    extclass_enable                  => extclass_enable_clone, 
    comp_state                       => tlb_tag3_clone2_q(tagpos_state+1 to tagpos_state+2), 
    entry_gs                         => tlb_way2_q(waypos_gs),   
    entry_ts                         => tlb_way2_q(waypos_ts),   
    state_enable                     => state_enable_clone, 
    entry_thdid                      => tlb_way2_q(waypos_thdid   to waypos_thdid+thdid_width-1), 
    comp_thdid                       => tlb_tag3_clone2_q(tagpos_thdid to tagpos_thdid+thdid_width-1), 
    thdid_enable                     => thdid_enable_clone, 
    entry_pid                        => tlb_way2_q(waypos_tid   to waypos_tid+pid_width-1), 
    comp_pid                         => tlb_tag3_clone2_q(tagpos_pid to tagpos_pid+pid_width-1), 
    pid_enable                       => pid_enable_clone, 
    entry_lpid                       => tlb_way2_q(waypos_lpid   to waypos_lpid+lpid_width-1),
    comp_lpid                        => tlb_tag3_clone2_q(tagpos_lpid to tagpos_lpid+lpid_width-1),
    lpid_enable                      => lpid_enable_clone,
    entry_ind                        => tlb_way2_q(waypos_ind),
    comp_ind                         => comp_ind_clone,  
    ind_enable                       => ind_enable_clone,
    entry_iprot                      => lru_tag3_dataout_q(10),    
    comp_iprot                       => comp_iprot_clone,  
    iprot_enable                     => iprot_enable_clone,
    entry_v                          => lru_tag3_dataout_q(2),   
    comp_invalidate                  => tlb_tag3_clone2_q(tagpos_type_snoop), 

    match                            => tlb_wayhit(2),    

    dbg_addr_match                   => tlb_way2_addr_match,
    dbg_pgsize_match                 => tlb_way2_pgsize_match,
    dbg_class_match                  => tlb_way2_class_match,
    dbg_extclass_match               => tlb_way2_extclass_match,
    dbg_state_match                  => tlb_way2_state_match,
    dbg_thdid_match                  => tlb_way2_thdid_match,
    dbg_pid_match                    => tlb_way2_pid_match,
    dbg_lpid_match                   => tlb_way2_lpid_match,
    dbg_ind_match                    => tlb_way2_ind_match,
    dbg_iprot_match                  => tlb_way2_iprot_match
   );
matchline_comb3   : mmq_tlb_matchline
 generic map (have_xbit => 1, num_pgsizes => 5, have_cmpmask => 1, cmpmask_width => 5)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => tlb_tag3_clone2_q(tagpos_epn to tagpos_epn+epn_width-1), 
    addr_enable                      => addr_enable_clone,
    comp_pgsize                      => tlb_tag3_clone2_q(tagpos_size to tagpos_size+3), 
    pgsize_enable                    => pgsize_enable_clone, 
    entry_size                       => tlb_way3_q(waypos_size   to waypos_size+3), 
    entry_cmpmask                    => tlb_way3_cmpmask_q,   
    entry_xbit                       => tlb_way3_q(waypos_xbit),   
    entry_xbitmask                   => tlb_way3_xbitmask_q,   
    entry_epn                        => tlb_way3_q(waypos_epn   to waypos_epn+epn_width-1), 
    comp_class                       => tlb_tag3_clone2_q(tagpos_class to tagpos_class+1), 
    entry_class                      => tlb_way3_q(waypos_class   to waypos_class+1), 
    class_enable                     => class_enable_clone, 
    comp_extclass                    => comp_extclass_clone, 
    entry_extclass                   => tlb_way3_q(waypos_extclass   to waypos_extclass+1), 
    extclass_enable                  => extclass_enable_clone, 
    comp_state                       => tlb_tag3_clone2_q(tagpos_state+1 to tagpos_state+2), 
    entry_gs                         => tlb_way3_q(waypos_gs),   
    entry_ts                         => tlb_way3_q(waypos_ts),   
    state_enable                     => state_enable_clone, 
    entry_thdid                      => tlb_way3_q(waypos_thdid   to waypos_thdid+thdid_width-1), 
    comp_thdid                       => tlb_tag3_clone2_q(tagpos_thdid to tagpos_thdid+thdid_width-1), 
    thdid_enable                     => thdid_enable_clone, 
    entry_pid                        => tlb_way3_q(waypos_tid   to waypos_tid+pid_width-1), 
    comp_pid                         => tlb_tag3_clone2_q(tagpos_pid to tagpos_pid+pid_width-1), 
    pid_enable                       => pid_enable_clone, 
    entry_lpid                       => tlb_way3_q(waypos_lpid   to waypos_lpid+lpid_width-1),
    comp_lpid                        => tlb_tag3_clone2_q(tagpos_lpid to tagpos_lpid+lpid_width-1),
    lpid_enable                      => lpid_enable_clone,
    entry_ind                        => tlb_way3_q(waypos_ind),
    comp_ind                         => comp_ind_clone,  
    ind_enable                       => ind_enable_clone,
    entry_iprot                      => lru_tag3_dataout_q(11),    
    comp_iprot                       => comp_iprot_clone,  
    iprot_enable                     => iprot_enable_clone,
    entry_v                          => lru_tag3_dataout_q(3),   
    comp_invalidate                  => tlb_tag3_clone2_q(tagpos_type_snoop), 

    match                            => tlb_wayhit(3),    

    dbg_addr_match                   => tlb_way3_addr_match,
    dbg_pgsize_match                 => tlb_way3_pgsize_match,
    dbg_class_match                  => tlb_way3_class_match,
    dbg_extclass_match               => tlb_way3_extclass_match,
    dbg_state_match                  => tlb_way3_state_match,
    dbg_thdid_match                  => tlb_way3_thdid_match,
    dbg_pid_match                    => tlb_way3_pid_match,
    dbg_lpid_match                   => tlb_way3_lpid_match,
    dbg_ind_match                    => tlb_way3_ind_match,
    dbg_iprot_match                  => tlb_way3_iprot_match
   );
tlb_cmp_ierat_dup_val(0 TO 6) <=  tlb_erat_dup_q(0 to 6);
tlb_cmp_derat_dup_val(0 TO 6) <=  tlb_erat_dup_q(10 to 16);
tlb_cmp_erat_dup_wait   <=  tlb_erat_dup_q(5) & tlb_erat_dup_q(15);
mm_iu_ierat_rel_val              <=  tlb_erat_val_q(0 to 4);
mm_iu_ierat_rel_data             <=  tlb_erat_rel_q;
mm_xu_derat_rel_val              <=  tlb_erat_val_q(5 to 9);
mm_xu_derat_rel_data             <=  tlb_erat_rel_clone_q;
mm_xu_eratmiss_done  <=  eratmiss_done_q;
mm_xu_tlb_miss       <=  tlb_miss_q;
mm_xu_tlb_inelig     <=  tlb_inelig_q;
mm_xu_lrat_miss      <=  lrat_miss_q;
mm_xu_pt_fault       <=  pt_fault_q;
mm_xu_hv_priv        <=  hv_priv_q;
mm_xu_esr_pt     <=  esr_pt_q;
mm_xu_esr_data   <=  esr_data_q;
mm_xu_esr_epid   <=  esr_epid_q;
mm_xu_esr_st     <=  esr_st_q;
mm_xu_cr0_eq         <=  cr0_eq_q;
mm_xu_cr0_eq_valid   <=  cr0_eq_valid_q;
mm_xu_tlb_multihit_err      <=  tlb_multihit_err_q;
mm_xu_tlb_par_err           <=  tlb_par_err_q;
mm_xu_lru_par_err           <=  lru_par_err_q;
tlb_tag5_except  <=  tlb_tag5_except_q;
tlb_tag4_esel     <=  tlb_tag4_q(tagpos_esel to tagpos_esel+2);
tlb_tag4_wq       <=  tlb_tag4_q(tagpos_wq to tagpos_wq+1);
tlb_tag4_is       <=  tlb_tag4_q(tagpos_is to tagpos_is+1);
tlb_tag4_hes      <=  tlb_tag4_q(tagpos_hes);
tlb_tag4_gs       <=  tlb_tag4_q(tagpos_gs);
tlb_tag4_pr       <=  tlb_tag4_q(tagpos_pr);
tlb_tag4_atsel    <=  tlb_tag4_q(tagpos_atsel);
tlb_tag4_pt       <=  tlb_tag4_q(tagpos_pt);
tlb_tag4_endflag  <=  tlb_tag4_q(tagpos_endflag) and or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1));
lru_tag4_dataout  <=  lru_tag4_dataout_q(0 to 15);
tlb_tag4_cmp_hit  <=  tlb_tag4_wayhit_q(tlb_ways);
tlb_tag4_way_ind  <=  tlb_tag4_way_or(waypos_ind);
tlb_tag4_ptereload_sig  <=  tlb_tag4_q(tagpos_type_ptereload) and or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1));
tlb_tag4_ptereload  <=  tlb_tag4_ptereload_sig;
tlb_tag4_parerr  <=  or_reduce(tag4_parerr_q(0 to 4)) and tlb_tag4_parerr_enab;
tlb_mas0_esel(0) <=  '0';
tlb_mas0_esel(1 TO 2) <=  "01" when tlb_tag4_wayhit_q(0 to tlb_ways)="01001"
                          else "10" when tlb_tag4_wayhit_q(0 to tlb_ways)="00101"
                          else "11" when tlb_tag4_wayhit_q(0 to tlb_ways)="00011"
                          else "00";
tlb_mas1_v              <=  lru_tag4_dataout_q(0) when 
                                 (tlb_tag4_q(tagpos_type_tlbre)='1' and tlb_tag4_q(tagpos_esel+1 to tagpos_esel+2)="00")
                          else lru_tag4_dataout_q(1) when 
                                 (tlb_tag4_q(tagpos_type_tlbre)='1' and tlb_tag4_q(tagpos_esel+1 to tagpos_esel+2)="01")
                          else lru_tag4_dataout_q(2) when
                                 (tlb_tag4_q(tagpos_type_tlbre)='1' and tlb_tag4_q(tagpos_esel+1 to tagpos_esel+2)="10")
                          else lru_tag4_dataout_q(3) when 
                                 (tlb_tag4_q(tagpos_type_tlbre)='1' and tlb_tag4_q(tagpos_esel+1 to tagpos_esel+2)="11")
                          else tlb_tag4_wayhit_q(tlb_ways) when tlb_tag4_q(tagpos_type_tlbsx)='1'
                          else '0';
tlb_mas1_iprot          <=  lru_tag4_dataout_q(8) when 
                                 (tlb_tag4_q(tagpos_type_tlbsx)='1' and tlb_tag4_wayhit_q(0 to tlb_ways)="10001") or
                                 (tlb_tag4_q(tagpos_type_tlbre)='1' and tlb_tag4_q(tagpos_esel+1 to tagpos_esel+2)="00")
                          else lru_tag4_dataout_q(9) when 
                                 (tlb_tag4_q(tagpos_type_tlbsx)='1' and tlb_tag4_wayhit_q(0 to tlb_ways)="01001") or
                                 (tlb_tag4_q(tagpos_type_tlbre)='1' and tlb_tag4_q(tagpos_esel+1 to tagpos_esel+2)="01")
                          else lru_tag4_dataout_q(10) when
                                 (tlb_tag4_q(tagpos_type_tlbsx)='1' and tlb_tag4_wayhit_q(0 to tlb_ways)="00101") or
                                 (tlb_tag4_q(tagpos_type_tlbre)='1' and tlb_tag4_q(tagpos_esel+1 to tagpos_esel+2)="10")
                          else lru_tag4_dataout_q(11) when 
                                 (tlb_tag4_q(tagpos_type_tlbsx)='1' and tlb_tag4_wayhit_q(0 to tlb_ways)="00011") or
                                 (tlb_tag4_q(tagpos_type_tlbre)='1' and tlb_tag4_q(tagpos_esel+1 to tagpos_esel+2)="11")
                          else '0';
tlb_mas1_tid            <=  tlb_tag4_way_rw_or(waypos_tid to waypos_tid+13) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_tid to waypos_tid+13);
tlb_mas1_tid_error      <=  tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_mas1_ind            <=  tlb_tag4_way_rw_or(waypos_ind) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_ind);
tlb_mas1_ts             <=  tlb_tag4_way_rw_or(waypos_ts) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_ts);
tlb_mas1_ts_error       <=  tlb_tag4_q(tagpos_state+2);
tlb_mas1_tsize          <=  tlb_tag4_way_rw_or(waypos_size to waypos_size+3) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_size to waypos_size+3);
tlb_mas2_epn(0 TO 31) <=  ( tlb_tag4_way_rw_or(waypos_epn to waypos_epn+31) and (0 to 31 => tlb_tag4_q(tagpos_cm)))
                          when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_epn to waypos_epn+31);
tlb_mas2_epn(32 TO epn_width-1) <=  tlb_tag4_way_rw_or(waypos_epn+32 to waypos_epn+51) 
                          when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_epn+32 to waypos_epn+51);
tlb_mas2_epn_error      <=  tlb_tag4_q(tagpos_epn to tagpos_epn+epn_width-1);
tlb_mas2_wimge          <=  tlb_tag4_way_rw_or(waypos_wimge to waypos_wimge+4) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_wimge to waypos_wimge+4);
tlb_mas3_rpnl           <=  tlb_tag4_way_rw_or(waypos_rpn+10 to waypos_rpn+rpn_width-1) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_rpn+10 to waypos_rpn+rpn_width-1);
tlb_mas3_ubits          <=  tlb_tag4_way_rw_or(waypos_ubits to waypos_ubits+3) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_ubits to waypos_ubits+3);
tlb_mas3_usxwr          <=  tlb_tag4_way_rw_or(waypos_usxwr to waypos_usxwr+5) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_usxwr to waypos_usxwr+5);
tlb_mas6_spid           <=  tlb_tag4_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_mas6_isize          <=  tlb_tag4_q(tagpos_size to tagpos_size+3);
tlb_mas6_sind           <=  tlb_tag4_q(tagpos_ind);
tlb_mas6_sas            <=  tlb_tag4_q(tagpos_state+2);
tlb_mas7_rpnu           <=  tlb_tag4_way_rw_or(waypos_rpn to waypos_rpn+9) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_rpn to waypos_rpn+9);
tlb_mas8_tgs            <=  tlb_tag4_way_rw_or(waypos_gs) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_gs);
tlb_mas8_vf             <=  tlb_tag4_way_rw_or(waypos_vf) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_vf);
tlb_mas8_tlpid          <=  tlb_tag4_way_rw_or(waypos_lpid to waypos_lpid+lpid_width-1) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1);
tlb_mmucr3_thdid        <=  tlb_tag4_way_rw_or(waypos_thdid to waypos_thdid+thdid_width-1) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_thdid to waypos_thdid+thdid_width-1);
tlb_mmucr3_resvattr     <=  tlb_tag4_way_rw_or(waypos_resvattr) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_resvattr);
tlb_mmucr3_wlc          <=  tlb_tag4_way_rw_or(waypos_wlc to waypos_wlc+1) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_wlc to waypos_wlc+1);
tlb_mmucr3_class        <=  tlb_tag4_way_rw_or(waypos_class to waypos_class+1) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_class to waypos_class+1);
tlb_mmucr3_extclass     <=  tlb_tag4_way_rw_or(waypos_extclass to waypos_extclass+1) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_extclass to waypos_extclass+1);
tlb_mmucr3_rc           <=  tlb_tag4_way_rw_or(waypos_rc to waypos_rc+1) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_rc to waypos_rc+1);
tlb_mmucr3_x            <=  tlb_tag4_way_rw_or(waypos_xbit) when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                  (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                          else tlb_tag4_way_or(waypos_xbit);
tlb_mmucr1_een          <=  tlb_addr4_q & (tag4_parerr_q(2) or tag4_parerr_q(3)) & (tag4_parerr_q(1) or tag4_parerr_q(3));
tlb_mmucr1_we           <=  ( ( (or_reduce(tag4_parerr_q(0 to 4)) and or_reduce(tlb_tag4_q(tagpos_type_derat to tagpos_type_tlbsrx)) and not tlb_tag4_q(tagpos_type_ptereload)) or tlb_tag4_tlbre_parerr )
                                  and ECO107332_orred_tag4_thdid_flushed )
                            or ( multihit and tlb_tag4_wayhit_q(tlb_ways) and or_reduce(tlb_tag4_q(tagpos_type_derat to tagpos_type_tlbsrx)) and not tlb_tag4_q(tagpos_type_ptereload)  );
ECO107332_orred_tag4_thdid_flushed  <=  or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag4_flush));
tlb_mas_dtlb_error      <=  tlb_tag4_q(tagpos_type_derat) and tlb_tag4_q(tagpos_endflag) and not tlb_tag4_wayhit_q(tlb_ways) and (not(or_reduce(tag4_parerr_q(0 to 4))) or cswitch_q(6)) and
                                 or_reduce( (msr_gs_q or msr_pr_q or not epcr_dmiuh_q) and tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) );
tlb_mas_itlb_error      <=  tlb_tag4_q(tagpos_type_ierat) and tlb_tag4_q(tagpos_endflag) and not tlb_tag4_wayhit_q(tlb_ways) and (not(or_reduce(tag4_parerr_q(0 to 4))) or cswitch_q(6)) and  
                                 or_reduce( (msr_gs_q or msr_pr_q or not epcr_dmiuh_q) and tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) );
tlb_mas_tlbsx_hit       <=  tlb_tag4_q(tagpos_type_tlbsx) and tlb_tag4_wayhit_q(tlb_ways) and not multihit and tlb_tag4_hv_op and (not(or_reduce(tag4_parerr_q(0 to 4))) or cswitch_q(5));
tlb_mas_tlbsx_miss      <=  tlb_tag4_q(tagpos_type_tlbsx) and tlb_tag4_q(tagpos_endflag)  and not tlb_tag4_wayhit_q(tlb_ways) and tlb_tag4_hv_op and (not(or_reduce(tag4_parerr_q(0 to 4))) or cswitch_q(6));
tlb_mas_tlbre           <=  tlb_tag4_q(tagpos_type_tlbre) and not tlb_tag4_q(tagpos_atsel) and tlb_tag4_hv_op and not ex6_illeg_instr(0) and (not(tlb_tag4_tlbre_parerr) or cswitch_q(7));
tlb_mas_thdid           <=  tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag4_flush);
tlbwe_tag3_back_inv_enab  <=  
            ( lru_tag3_dataout_q(0) and (lru_tag3_dataout_q(8)  or not cswitch_q(0)) and (not(tlb_tag3_q(tagpos_is)) or not(cswitch_q(3))) and not tlb_tag3_q(tagpos_hes) and not tlb_tag3_q(tagpos_esel+1) and not tlb_tag3_q(tagpos_esel+2) ) or
            ( lru_tag3_dataout_q(1) and (lru_tag3_dataout_q(9)  or not cswitch_q(0)) and (not(tlb_tag3_q(tagpos_is)) or not(cswitch_q(3))) and not tlb_tag3_q(tagpos_hes) and not tlb_tag3_q(tagpos_esel+1) and      tlb_tag3_q(tagpos_esel+2) ) or
            ( lru_tag3_dataout_q(2) and (lru_tag3_dataout_q(10) or not cswitch_q(0)) and (not(tlb_tag3_q(tagpos_is)) or not(cswitch_q(3))) and not tlb_tag3_q(tagpos_hes) and      tlb_tag3_q(tagpos_esel+1) and not tlb_tag3_q(tagpos_esel+2) ) or
            ( lru_tag3_dataout_q(3) and (lru_tag3_dataout_q(11) or not cswitch_q(0)) and (not(tlb_tag3_q(tagpos_is)) or not(cswitch_q(3))) and not tlb_tag3_q(tagpos_hes) and      tlb_tag3_q(tagpos_esel+1) and      tlb_tag3_q(tagpos_esel+2) ) or
            ( lru_tag3_dataout_q(0) and (lru_tag3_dataout_q(8)  or not cswitch_q(0)) and (not(tlb_tag3_q(tagpos_is)) or not(cswitch_q(3))) and tlb_tag3_q(tagpos_hes) and cswitch_q(1) and not lru_tag3_dataout_q(4) and not lru_tag3_dataout_q(5) ) or
            ( lru_tag3_dataout_q(1) and (lru_tag3_dataout_q(9)  or not cswitch_q(0)) and (not(tlb_tag3_q(tagpos_is)) or not(cswitch_q(3))) and tlb_tag3_q(tagpos_hes) and cswitch_q(1) and not lru_tag3_dataout_q(4) and      lru_tag3_dataout_q(5) ) or
            ( lru_tag3_dataout_q(2) and (lru_tag3_dataout_q(10) or not cswitch_q(0)) and (not(tlb_tag3_q(tagpos_is)) or not(cswitch_q(3))) and tlb_tag3_q(tagpos_hes) and cswitch_q(1) and      lru_tag3_dataout_q(4) and not lru_tag3_dataout_q(6) ) or
            ( lru_tag3_dataout_q(3) and (lru_tag3_dataout_q(11) or not cswitch_q(0)) and (not(tlb_tag3_q(tagpos_is)) or not(cswitch_q(3))) and tlb_tag3_q(tagpos_hes) and cswitch_q(1) and      lru_tag3_dataout_q(4) and      lru_tag3_dataout_q(6) );
tlbwe_tag4_back_inv_d(0 TO thdid_width-1) <=  tlb_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush);
tlbwe_tag4_back_inv_d(thdid_width) <=  ( tlbwe_tag3_back_inv_enab and tlb_tag3_q(tagpos_type_tlbwe) and not(Eq(tlb_tag3_q(tagpos_wq to tagpos_wq+1),"10")) and mmucr1_q(pos_tlbwe_binv) and
                   ((not(tlb_tag3_q(tagpos_gs)) and not(tlb_tag3_q(tagpos_atsel))) or 
                       (tlb_tag3_q(tagpos_gs) and tlb_tag3_q(tagpos_hes) and lrat_tag3_hit_status(1) and not lrat_tag3_hit_status(2))) and  
                    or_reduce(tlb_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush)) );
tlbwe_tag4_back_inv_attr_d(18) <= 
            ( lru_tag3_dataout_q(0) and (lru_tag3_dataout_q(8)  or not cswitch_q(2)) and not tlb_tag3_q(tagpos_hes) and not tlb_tag3_q(tagpos_esel+1) and not tlb_tag3_q(tagpos_esel+2) ) or
            ( lru_tag3_dataout_q(1) and (lru_tag3_dataout_q(9)  or not cswitch_q(2)) and not tlb_tag3_q(tagpos_hes) and not tlb_tag3_q(tagpos_esel+1) and     tlb_tag3_q(tagpos_esel+2) ) or
            ( lru_tag3_dataout_q(2) and (lru_tag3_dataout_q(10) or not cswitch_q(2)) and not tlb_tag3_q(tagpos_hes) and      tlb_tag3_q(tagpos_esel+1) and not tlb_tag3_q(tagpos_esel+2) ) or
            ( lru_tag3_dataout_q(3) and (lru_tag3_dataout_q(11) or not cswitch_q(2)) and not tlb_tag3_q(tagpos_hes) and      tlb_tag3_q(tagpos_esel+1) and     tlb_tag3_q(tagpos_esel+2) ) or
            ( lru_tag3_dataout_q(0) and (lru_tag3_dataout_q(8)  or not cswitch_q(2)) and      tlb_tag3_q(tagpos_hes) and not lru_tag3_dataout_q(4) and not lru_tag3_dataout_q(5) ) or
            ( lru_tag3_dataout_q(1) and (lru_tag3_dataout_q(9)  or not cswitch_q(2)) and      tlb_tag3_q(tagpos_hes) and not lru_tag3_dataout_q(4) and     lru_tag3_dataout_q(5) ) or
            ( lru_tag3_dataout_q(2) and (lru_tag3_dataout_q(10) or not cswitch_q(2)) and      tlb_tag3_q(tagpos_hes) and      lru_tag3_dataout_q(4) and not lru_tag3_dataout_q(6) ) or
            ( lru_tag3_dataout_q(3) and (lru_tag3_dataout_q(11) or not cswitch_q(2)) and      tlb_tag3_q(tagpos_hes) and      lru_tag3_dataout_q(4) and     lru_tag3_dataout_q(6) );
tlbwe_tag4_back_inv_attr_d(19) <=  '0';
tlbwe_back_inv_valid      <=  tlbwe_tag4_back_inv_q(thdid_width) and (not(tlb_tag4_way_rw_or(waypos_ind)) or cswitch_q(4));
tlbwe_back_inv_thdid      <=  tlbwe_tag4_back_inv_q(0 to thdid_width-1);
tlbwe_back_inv_addr       <=  tlb_tag4_way_rw_or(waypos_epn to waypos_epn+51);
tlbwe_back_inv_attr       <=  '1' & "011" & 
                                    tlb_tag4_way_rw_or(waypos_gs) & tlb_tag4_way_rw_or(waypos_ts) &
                                    tlb_tag4_way_rw_or(waypos_tid+6 to waypos_tid+13) & 
                                    tlb_tag4_way_rw_or(waypos_size to waypos_size+3) & 
                                    tlbwe_tag4_back_inv_attr_q(18 to 19) &
                                    tlb_tag4_way_rw_or(waypos_tid to waypos_tid+5) & 
                                    tlb_tag4_way_rw_or(waypos_lpid to waypos_lpid+lpid_width-1) & 
                                    tlb_tag4_way_rw_or(waypos_ind);
lru_write    <=  lru_write_q and (0 to lru_width-1 => not or_reduce(tlb_tag5_except_q));
lru_wr_addr  <=  lru_wr_addr_q;
lru_datain   <=  lru_datain_q;
tlb_htw_req_valid  <=  '1' when (tlb_tag4_q(tagpos_type_derat to tagpos_type_ierat)/="00" and tlb_tag4_q(tagpos_type_ptereload)='0' and
                                     tlb_tag4_q(tagpos_ind)='1' and tlb_tag4_wayhit_q(tlb_ways)='1' and multihit='0') 
                      else '0';
tlb_htw_req_way    <=  tlb_tag4_way_or(tlb_word_width to tlb_way_width-1);
tlb_htw_req_tag(0 TO epn_width-1) <=  tlb_tag4_q(0 to epn_width-1);
tlb_htw_req_tag(tagpos_pid TO tagpos_pid+pid_width-1) <=  tlb_tag4_way_or(waypos_tid to waypos_tid+pid_width-1);
tlb_htw_req_tag(tagpos_is TO tagpos_class+1) <=  tlb_tag4_q(tagpos_is to tagpos_class+1);
tlb_htw_req_tag(tagpos_pr) <=  tlb_tag4_q(tagpos_pr);
tlb_htw_req_tag(tagpos_gs) <=  tlb_tag4_way_or(waypos_gs);
tlb_htw_req_tag(tagpos_as) <=  tlb_tag4_way_or(waypos_ts);
tlb_htw_req_tag(tagpos_cm) <=  tlb_tag4_q(tagpos_cm);
tlb_htw_req_tag(tagpos_thdid TO tagpos_lpid-1) <=  tlb_tag4_q(tagpos_thdid to tagpos_lpid-1);
tlb_htw_req_tag(tagpos_lpid TO tagpos_lpid+lpid_width-1) <=  tlb_tag4_way_or(waypos_lpid to waypos_lpid+lpid_width-1);
tlb_htw_req_tag(tagpos_ind) <=  tlb_tag4_q(tagpos_ind);
tlb_htw_req_tag(tagpos_atsel) <=  tlb_tag4_way_or(waypos_thdid);
tlb_htw_req_tag(tagpos_esel TO tagpos_esel+2) <=  tlb_tag4_way_or(waypos_thdid+1 to waypos_thdid+3);
tlb_htw_req_tag(tagpos_hes TO tlb_tag_width-1) <=  tlb_tag4_q(tagpos_hes to tlb_tag_width-1);
tlb_cmp_perf_event_t0(0) <=  tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and tlb_tag4_wayhit_q(tlb_ways) and not multihit;
tlb_cmp_perf_event_t0(1) <=  tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                    (tlb_tag3_q(tagpos_ind) or tlb_tag4_q(tagpos_endflag));
tlb_cmp_perf_event_t0(2) <=  tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                     tlb_tag4_q(tagpos_endflag);
tlb_cmp_perf_event_t0(3) <=  tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_type_ierat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t0(4) <=  tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_type_ierat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     not tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t0(5) <=  tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and tlb_tag4_wayhit_q(tlb_ways) and not multihit;
tlb_cmp_perf_event_t0(6) <=  tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                    (tlb_tag3_q(tagpos_ind) or tlb_tag4_q(tagpos_endflag));
tlb_cmp_perf_event_t0(7) <=  tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                     tlb_tag4_q(tagpos_endflag);
tlb_cmp_perf_event_t0(8) <=  tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_type_derat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t0(9) <=  tlb_tag4_q(tagpos_thdid+0) and tlb_tag4_q(tagpos_type_derat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     not tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t1(0) <=  tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and tlb_tag4_wayhit_q(tlb_ways) and not multihit;
tlb_cmp_perf_event_t1(1) <=  tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                    (tlb_tag3_q(tagpos_ind) or tlb_tag4_q(tagpos_endflag));
tlb_cmp_perf_event_t1(2) <=  tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                     tlb_tag4_q(tagpos_endflag);
tlb_cmp_perf_event_t1(3) <=  tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_type_ierat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t1(4) <=  tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_type_ierat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     not tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t1(5) <=  tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and tlb_tag4_wayhit_q(tlb_ways) and not multihit;
tlb_cmp_perf_event_t1(6) <=  tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                    (tlb_tag3_q(tagpos_ind) or tlb_tag4_q(tagpos_endflag));
tlb_cmp_perf_event_t1(7) <=  tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                     tlb_tag4_q(tagpos_endflag);
tlb_cmp_perf_event_t1(8) <=  tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_type_derat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t1(9) <=  tlb_tag4_q(tagpos_thdid+1) and tlb_tag4_q(tagpos_type_derat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     not tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t2(0) <=  tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and tlb_tag4_wayhit_q(tlb_ways) and not multihit;
tlb_cmp_perf_event_t2(1) <=  tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                    (tlb_tag3_q(tagpos_ind) or tlb_tag4_q(tagpos_endflag));
tlb_cmp_perf_event_t2(2) <=  tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                     tlb_tag4_q(tagpos_endflag);
tlb_cmp_perf_event_t2(3) <=  tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_type_ierat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t2(4) <=  tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_type_ierat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     not tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t2(5) <=  tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and tlb_tag4_wayhit_q(tlb_ways) and not multihit;
tlb_cmp_perf_event_t2(6) <=  tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                    (tlb_tag3_q(tagpos_ind) or tlb_tag4_q(tagpos_endflag));
tlb_cmp_perf_event_t2(7) <=  tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                     tlb_tag4_q(tagpos_endflag);
tlb_cmp_perf_event_t2(8) <=  tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_type_derat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t2(9) <=  tlb_tag4_q(tagpos_thdid+2) and tlb_tag4_q(tagpos_type_derat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     not tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t3(0) <=  tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and tlb_tag4_wayhit_q(tlb_ways) and not multihit;
tlb_cmp_perf_event_t3(1) <=  tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                    (tlb_tag3_q(tagpos_ind) or tlb_tag4_q(tagpos_endflag));
tlb_cmp_perf_event_t3(2) <=  tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_type_ierat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                     tlb_tag4_q(tagpos_endflag);
tlb_cmp_perf_event_t3(3) <=  tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_type_ierat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t3(4) <=  tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_type_ierat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     not tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t3(5) <=  tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and tlb_tag4_wayhit_q(tlb_ways) and not multihit;
tlb_cmp_perf_event_t3(6) <=  tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    not tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                    (tlb_tag3_q(tagpos_ind) or tlb_tag4_q(tagpos_endflag));
tlb_cmp_perf_event_t3(7) <=  tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_type_derat) and not tlb_tag4_q(tagpos_type_ptereload) and 
                                    tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                     tlb_tag4_q(tagpos_endflag);
tlb_cmp_perf_event_t3(8) <=  tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_type_derat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     tlb_tag4_q(tagpos_is);
tlb_cmp_perf_event_t3(9) <=  tlb_tag4_q(tagpos_thdid+3) and tlb_tag4_q(tagpos_type_derat) and tlb_tag4_q(tagpos_type_ptereload) and 
                                     not tlb_tag4_q(tagpos_is);
tlb_cmp_perf_state       <=  tlb_tag4_q(tagpos_gs) & tlb_tag4_q(tagpos_pr);
tlb_cmp_perf_miss_direct         <=   or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and or_reduce(tlb_tag4_q(tagpos_type_derat to tagpos_type_ierat)) and 
                                    not tlb_tag4_q(tagpos_type_ptereload) and not tlb_tag4_q(tagpos_ind) and not tlb_tag4_wayhit_q(tlb_ways) and 
                                    (tlb_tag3_q(tagpos_ind) or tlb_tag4_q(tagpos_endflag));
tlb_cmp_perf_hit_indirect        <=   or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and or_reduce(tlb_tag4_q(tagpos_type_derat to tagpos_type_ierat)) and 
                                    not tlb_tag4_q(tagpos_type_ptereload) and tlb_tag4_q(tagpos_ind) and tlb_tag4_wayhit_q(tlb_ways) and not multihit;
tlb_cmp_perf_hit_first_page      <=   or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) and or_reduce(tlb_tag4_q(tagpos_type_derat to tagpos_type_ierat)) and 
                                    not tlb_tag4_q(tagpos_type_ptereload) and not tlb_tag4_q(tagpos_ind) and tlb_tag4_wayhit_q(tlb_ways) and not multihit and
                                     Eq(tlb_tag4_q(tagpos_esel to tagpos_esel+2),"001");
tlb_cmp_perf_pt_fault            <=   or_reduce(pt_fault_q);
tlb_cmp_perf_pt_inelig           <=   or_reduce(tlb_inelig_q);
tlb_cmp_perf_lrat_miss           <=   or_reduce(lrat_miss_q);
tlb_cmp_perf_ptereload_noexcep   <=  or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) 
                  when ( tlb_tag4_q(tagpos_type_ptereload)='1' and tlb_tag4_q(tagpos_is)='1' and  
                             tlb_tag4_q(tagpos_wq to tagpos_wq+1)="10" and  
                               tlb_tag4_q(tagpos_pt)='1'  and     
                                or_reduce(pt_fault_d or tlb_inelig_d or lrat_miss_d)='0' )  
         else '0';
tlb_cmp_perf_lrat_request   <=  or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag4_flush)) 
                  when ( ((or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and tlb_resv_match_vec)='1' 
                                         and tlb_tag4_q(tagpos_wq to tagpos_wq+1)="01" and mmucfg_twc='1')  
                                           or tlb_tag4_q(tagpos_wq to tagpos_wq+1)="00" or tlb_tag4_q(tagpos_wq to tagpos_wq+1)="11") and  
                              tlb_tag4_q(tagpos_type_tlbwe)='1' and tlb_tag4_q(tagpos_gs)='1' and tlb_tag4_q(tagpos_pr)='0' and 
                               tlb_tag4_epcr_dgtmi='0' and mmucfg_lrat='1' and
                                tlb_tag4_q(tagpos_is)='1' ) 
        else or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1)) 
                  when (tlb_tag4_q(tagpos_type_ptereload)='1' and tlb_tag4_q(tagpos_gs)='1' and mmucfg_lrat='1' and 
                          tlb_tag4_q(tagpos_is)='1'  and   
                            tlb_tag4_q(tagpos_wq to tagpos_wq+1)="10" and   
                             tlb_tag4_q(tagpos_pt)='1')       
        else '0';
tlb_cmp_dbg_tag4                    <=  tlb_tag4_q;
tlb_cmp_dbg_tag4_wayhit             <=  tlb_tag4_wayhit_q;
tlb_cmp_dbg_addr4                   <=  tlb_addr4_q;
tlb_cmp_dbg_tag4_way                <=  tlb_tag4_way_rw_or when ( or_reduce(tlb_tag4_q(tagpos_thdid to tagpos_thdid+thdid_width-1))='1' and 
                                             (tlb_tag4_q(tagpos_type_tlbre) or tlb_tag4_q(tagpos_type_tlbwe) or tlb_tag4_q(tagpos_type_ptereload))='1' )
                                      else tlb_tag4_way_or;
tlb_cmp_dbg_tag4_parerr             <=  tag4_parerr_q;
tlb_cmp_dbg_tag4_lru_dataout_q      <=  lru_tag4_dataout_q(0 to lru_width-5);
tlb_cmp_dbg_tag5_lru_datain_q       <=  lru_datain_q(0 to lru_width-5);
tlb_cmp_dbg_tag5_lru_write          <=  lru_write_q(0);
tlb_cmp_dbg_tag5_any_exception      <=  or_reduce(tlb_miss_q) or or_reduce(hv_priv_q) or or_reduce(lrat_miss_q) or or_reduce(pt_fault_q) or or_reduce(tlb_inelig_q);
tlb_cmp_dbg_tag5_except_type_q      <=  or_reduce(hv_priv_q) & or_reduce(lrat_miss_q) & or_reduce(pt_fault_q) & or_reduce(tlb_inelig_q);
tlb_cmp_dbg_tag5_except_thdid_q(0) <=  hv_priv_q(2) or hv_priv_q(3) or lrat_miss_q(2) or lrat_miss_q(3) or
                                               pt_fault_q(2) or pt_fault_q(3) or tlb_inelig_q(2) or tlb_inelig_q(3) or
                                               tlb_miss_q(2) or tlb_miss_q(3);
tlb_cmp_dbg_tag5_except_thdid_q(1) <=  hv_priv_q(1) or hv_priv_q(3) or lrat_miss_q(1) or lrat_miss_q(3) or
                                               pt_fault_q(1) or pt_fault_q(3) or tlb_inelig_q(1) or tlb_inelig_q(3) or
                                               tlb_miss_q(1) or tlb_miss_q(3);
tlb_cmp_dbg_tag5_erat_rel_val       <=  tlb_erat_val_q;
tlb_cmp_dbg_tag5_erat_rel_data      <=  tlb_erat_rel_q;
tlb_cmp_dbg_erat_dup_q              <=  tlb_erat_dup_q;
tlb_cmp_dbg_addr_enable             <=  addr_enable;
tlb_cmp_dbg_pgsize_enable           <=  pgsize_enable;
tlb_cmp_dbg_class_enable            <=  class_enable;
tlb_cmp_dbg_extclass_enable         <=  extclass_enable;
tlb_cmp_dbg_state_enable            <=  state_enable;
tlb_cmp_dbg_thdid_enable            <=  thdid_enable;
tlb_cmp_dbg_pid_enable              <=  pid_enable;
tlb_cmp_dbg_lpid_enable             <=  lpid_enable;
tlb_cmp_dbg_ind_enable              <=  ind_enable;
tlb_cmp_dbg_iprot_enable            <=  iprot_enable;
tlb_cmp_dbg_way0_entry_v                         <=  lru_tag3_dataout_q(0);
tlb_cmp_dbg_way0_addr_match                      <=  tlb_way0_addr_match;
tlb_cmp_dbg_way0_pgsize_match                    <=  tlb_way0_pgsize_match;
tlb_cmp_dbg_way0_class_match                     <=  tlb_way0_class_match;
tlb_cmp_dbg_way0_extclass_match                  <=  tlb_way0_extclass_match;
tlb_cmp_dbg_way0_state_match                     <=  tlb_way0_state_match;
tlb_cmp_dbg_way0_thdid_match                     <=  tlb_way0_thdid_match;
tlb_cmp_dbg_way0_pid_match                       <=  tlb_way0_pid_match;
tlb_cmp_dbg_way0_lpid_match                      <=  tlb_way0_lpid_match;
tlb_cmp_dbg_way0_ind_match                       <=  tlb_way0_ind_match;
tlb_cmp_dbg_way0_iprot_match                     <=  tlb_way0_iprot_match;
tlb_cmp_dbg_way1_entry_v                         <=  lru_tag3_dataout_q(1);
tlb_cmp_dbg_way1_addr_match                      <=  tlb_way1_addr_match;
tlb_cmp_dbg_way1_pgsize_match                    <=  tlb_way1_pgsize_match;
tlb_cmp_dbg_way1_class_match                     <=  tlb_way1_class_match;
tlb_cmp_dbg_way1_extclass_match                  <=  tlb_way1_extclass_match;
tlb_cmp_dbg_way1_state_match                     <=  tlb_way1_state_match;
tlb_cmp_dbg_way1_thdid_match                     <=  tlb_way1_thdid_match;
tlb_cmp_dbg_way1_pid_match                       <=  tlb_way1_pid_match;
tlb_cmp_dbg_way1_lpid_match                      <=  tlb_way1_lpid_match;
tlb_cmp_dbg_way1_ind_match                       <=  tlb_way1_ind_match;
tlb_cmp_dbg_way1_iprot_match                     <=  tlb_way1_iprot_match;
tlb_cmp_dbg_way2_entry_v                         <=  lru_tag3_dataout_q(2);
tlb_cmp_dbg_way2_addr_match                      <=  tlb_way2_addr_match;
tlb_cmp_dbg_way2_pgsize_match                    <=  tlb_way2_pgsize_match;
tlb_cmp_dbg_way2_class_match                     <=  tlb_way2_class_match;
tlb_cmp_dbg_way2_extclass_match                  <=  tlb_way2_extclass_match;
tlb_cmp_dbg_way2_state_match                     <=  tlb_way2_state_match;
tlb_cmp_dbg_way2_thdid_match                     <=  tlb_way2_thdid_match;
tlb_cmp_dbg_way2_pid_match                       <=  tlb_way2_pid_match;
tlb_cmp_dbg_way2_lpid_match                      <=  tlb_way2_lpid_match;
tlb_cmp_dbg_way2_ind_match                       <=  tlb_way2_ind_match;
tlb_cmp_dbg_way2_iprot_match                     <=  tlb_way2_iprot_match;
tlb_cmp_dbg_way3_entry_v                         <=  lru_tag3_dataout_q(3);
tlb_cmp_dbg_way3_addr_match                      <=  tlb_way3_addr_match;
tlb_cmp_dbg_way3_pgsize_match                    <=  tlb_way3_pgsize_match;
tlb_cmp_dbg_way3_class_match                     <=  tlb_way3_class_match;
tlb_cmp_dbg_way3_extclass_match                  <=  tlb_way3_extclass_match;
tlb_cmp_dbg_way3_state_match                     <=  tlb_way3_state_match;
tlb_cmp_dbg_way3_thdid_match                     <=  tlb_way3_thdid_match;
tlb_cmp_dbg_way3_pid_match                       <=  tlb_way3_pid_match;
tlb_cmp_dbg_way3_lpid_match                      <=  tlb_way3_lpid_match;
tlb_cmp_dbg_way3_ind_match                       <=  tlb_way3_ind_match;
tlb_cmp_dbg_way3_iprot_match                     <=  tlb_way3_iprot_match;
unused_dc(0) <=  or_reduce(LCB_DELAY_LCLKR_DC(1 TO 4));
unused_dc(1) <=  or_reduce(LCB_MPW1_DC_B(1 TO 4));
unused_dc(2) <=  PC_FUNC_SL_FORCE;
unused_dc(3) <=  PC_FUNC_SL_THOLD_0_B;
unused_dc(4) <=  TC_SCAN_DIS_DC_B;
unused_dc(5) <=  TC_SCAN_DIAG_DC;
unused_dc(6) <=  TC_LBIST_EN_DC;
unused_dc(7) <=  TLB_TAG3_CLONE1_Q(70);
unused_dc(8) <=  TLB_TAG3_CLONE1_Q(73);
unused_dc(9) <=  or_reduce(TLB_TAG3_CLONE1_Q(99 TO 100));
unused_dc(10) <=  or_reduce(TLB_TAG3_CLONE1_Q(104 TO 109));
unused_dc(11) <=  TLB_TAG3_CLONE2_Q(70);
unused_dc(12) <=  TLB_TAG3_CLONE2_Q(73);
unused_dc(13) <=  or_reduce(TLB_TAG3_CLONE2_Q(99 TO 100));
unused_dc(14) <=  or_reduce(TLB_TAG3_CLONE2_Q(104 TO 109));
unused_dc(15) <=  '0';
unused_dc(16) <=  TLB_TAG3_CMPMASK_Q(4);
unused_dc(17) <=  TLB_TAG3_CMPMASK_CLONE_Q(4);
unused_dc(18) <=  or_reduce(MMUCR1_CLONE_Q(11) & MMUCR1_CLONE_Q(17));
unused_dc(19) <=  or_reduce(TLB_TAG4_TYPE_SIG(0 TO 3) & TLB_TAG4_TYPE_SIG(5));
unused_dc(20) <=  TLB_TAG4_ESEL_SIG(0);
unused_dc(21) <=  or_reduce(TLB_TAG4_WQ_SIG);
unused_dc(22) <=  or_reduce(TLB_TAG4_IS_SIG(1 TO 3));
unused_dc(23) <=  or_reduce(PTERELOAD_REQ_PTE_LAT(0 TO 9));
unused_dc(24) <=  or_reduce(PTERELOAD_REQ_PTE_LAT(50) & PTERELOAD_REQ_PTE_LAT(55) & PTERELOAD_REQ_PTE_LAT(62));
unused_dc(25) <=  or_reduce(MMUCR3_0(53) & MMUCR3_0(59));
unused_dc(26) <=  or_reduce(MMUCR3_1(53) & MMUCR3_1(59));
unused_dc(27) <=  or_reduce(MMUCR3_2(53) & MMUCR3_2(59));
unused_dc(28) <=  or_reduce(MMUCR3_3(53) & MMUCR3_3(59));
unused_dc(29) <=  TLB0CFG_PT;
unused_dc(30) <=  or_reduce(TLB_DSI_Q);
unused_dc(31) <=  or_reduce(TLB_ISI_Q);
unused_dc(32) <=  or_reduce(LRAT_TAG3_LPN_SIG);
unused_dc(33) <=  or_reduce(LRAT_TAG3_RPN_SIG);
unused_dc(34) <=  or_reduce(LRAT_TAG4_LPN_SIG);
unused_dc(35) <=  LRAT_TAG3_HIT_STATUS(0);
unused_dc(36) <=  LRAT_TAG3_HIT_STATUS(3);
unused_dc(37) <=  or_reduce(LRAT_TAG3_HIT_ENTRY);
unused_dc(38) <=  or_reduce(LRAT_TAG4_HIT_ENTRY);
tlb_way0_latch: tri_rlmreg_p
  generic map (width => tlb_way0_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(12),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_way0_offset to tlb_way0_offset+tlb_way0_q'length-1),
            scout   => sov_0(tlb_way0_offset to tlb_way0_offset+tlb_way0_q'length-1),
            din     => tlb_way0_d(0 to tlb_way_width-1),
            dout    => tlb_way0_q(0 to tlb_way_width-1)  );
tlb_way1_latch: tri_rlmreg_p
  generic map (width => tlb_way1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(12),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_way1_offset to tlb_way1_offset+tlb_way1_q'length-1),
            scout   => sov_0(tlb_way1_offset to tlb_way1_offset+tlb_way1_q'length-1),
            din     => tlb_way1_d(0 to tlb_way_width-1),
            dout    => tlb_way1_q(0 to tlb_way_width-1)  );
tlb_way2_latch: tri_rlmreg_p
  generic map (width => tlb_way2_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(13),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(tlb_way2_offset to tlb_way2_offset+tlb_way2_q'length-1),
            scout   => sov_1(tlb_way2_offset to tlb_way2_offset+tlb_way2_q'length-1),
            din     => tlb_way2_d(0 to tlb_way_width-1),
            dout    => tlb_way2_q(0 to tlb_way_width-1)  );
tlb_way3_latch: tri_rlmreg_p
  generic map (width => tlb_way3_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(13),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(tlb_way3_offset to tlb_way3_offset+tlb_way3_q'length-1),
            scout   => sov_1(tlb_way3_offset to tlb_way3_offset+tlb_way3_q'length-1),
            din     => tlb_way3_d(0 to tlb_way_width-1),
            dout    => tlb_way3_q(0 to tlb_way_width-1)  );
tlb_tag3_latch: tri_rlmreg_p
  generic map (width => tlb_tag3_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(9),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_tag3_offset to tlb_tag3_offset+tlb_tag3_q'length-1),
            scout   => sov_2(tlb_tag3_offset to tlb_tag3_offset+tlb_tag3_q'length-1),
            din     => tlb_tag3_d(0 to tlb_tag_width-1),
            dout    => tlb_tag3_q(0 to tlb_tag_width-1)  );
tlb_tag3_clone1_latch: tri_rlmreg_p
  generic map (width => tlb_tag3_clone1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(12),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_tag3_clone1_offset to tlb_tag3_clone1_offset+tlb_tag3_clone1_q'length-1),
            scout   => sov_0(tlb_tag3_clone1_offset to tlb_tag3_clone1_offset+tlb_tag3_clone1_q'length-1),
            din     => tlb_tag3_clone1_d(0 to tlb_tag_width-1),
            dout    => tlb_tag3_clone1_q(0 to tlb_tag_width-1)  );
tlb_tag3_clone2_latch: tri_rlmreg_p
  generic map (width => tlb_tag3_clone2_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(13),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(tlb_tag3_clone2_offset to tlb_tag3_clone2_offset+tlb_tag3_clone2_q'length-1),
            scout   => sov_1(tlb_tag3_clone2_offset to tlb_tag3_clone2_offset+tlb_tag3_clone2_q'length-1),
            din     => tlb_tag3_clone2_d(0 to tlb_tag_width-1),
            dout    => tlb_tag3_clone2_q(0 to tlb_tag_width-1)  );
tlb_addr3_latch: tri_rlmreg_p
  generic map (width => tlb_addr3_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(9),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_addr3_offset to tlb_addr3_offset+tlb_addr3_q'length-1),
            scout   => sov_2(tlb_addr3_offset to tlb_addr3_offset+tlb_addr3_q'length-1),
            din     => tlb_addr3_d(0 to tlb_addr_width-1),
            dout    => tlb_addr3_q(0 to tlb_addr_width-1)  );
lru_tag3_dataout_latch: tri_rlmreg_p
 generic map (width => lru_tag3_dataout_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(9),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_2(lru_tag3_dataout_offset to lru_tag3_dataout_offset+lru_tag3_dataout_q'length-1),
           scout   => sov_2(lru_tag3_dataout_offset to lru_tag3_dataout_offset+lru_tag3_dataout_q'length-1),
           din     => lru_tag3_dataout_d(0 to 15),
           dout    => lru_tag3_dataout_q(0 to 15)  );
tlb_tag3_cmpmask_latch: tri_rlmreg_p
 generic map (width => tlb_tag3_cmpmask_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(12),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_0(tlb_tag3_cmpmask_offset to tlb_tag3_cmpmask_offset+tlb_tag3_cmpmask_q'length-1),
           scout   => sov_0(tlb_tag3_cmpmask_offset to tlb_tag3_cmpmask_offset+tlb_tag3_cmpmask_q'length-1),
           din     => tlb_tag3_cmpmask_d,
           dout    => tlb_tag3_cmpmask_q  );
tlb_tag3_cmpmask_clone_latch: tri_rlmreg_p
 generic map (width => tlb_tag3_cmpmask_clone_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(13),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_1(tlb_tag3_cmpmask_clone_offset to tlb_tag3_cmpmask_clone_offset+tlb_tag3_cmpmask_clone_q'length-1),
           scout   => sov_1(tlb_tag3_cmpmask_clone_offset to tlb_tag3_cmpmask_clone_offset+tlb_tag3_cmpmask_clone_q'length-1),
           din     => tlb_tag3_cmpmask_clone_d,
           dout    => tlb_tag3_cmpmask_clone_q  );
tlb_way0_cmpmask_latch: tri_rlmreg_p
 generic map (width => tlb_way0_cmpmask_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(12),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_0(tlb_way0_cmpmask_offset to tlb_way0_cmpmask_offset+tlb_way0_cmpmask_q'length-1),
           scout   => sov_0(tlb_way0_cmpmask_offset to tlb_way0_cmpmask_offset+tlb_way0_cmpmask_q'length-1),
           din     => tlb_way0_cmpmask_d,
           dout    => tlb_way0_cmpmask_q  );
tlb_way1_cmpmask_latch: tri_rlmreg_p
 generic map (width => tlb_way1_cmpmask_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(12),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_0(tlb_way1_cmpmask_offset to tlb_way1_cmpmask_offset+tlb_way1_cmpmask_q'length-1),
           scout   => sov_0(tlb_way1_cmpmask_offset to tlb_way1_cmpmask_offset+tlb_way1_cmpmask_q'length-1),
           din     => tlb_way1_cmpmask_d,
           dout    => tlb_way1_cmpmask_q  );
tlb_way2_cmpmask_latch: tri_rlmreg_p
 generic map (width => tlb_way2_cmpmask_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(13),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_1(tlb_way2_cmpmask_offset to tlb_way2_cmpmask_offset+tlb_way2_cmpmask_q'length-1),
           scout   => sov_1(tlb_way2_cmpmask_offset to tlb_way2_cmpmask_offset+tlb_way2_cmpmask_q'length-1),
           din     => tlb_way2_cmpmask_d,
           dout    => tlb_way2_cmpmask_q  );
tlb_way3_cmpmask_latch: tri_rlmreg_p
 generic map (width => tlb_way3_cmpmask_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(13),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_1(tlb_way3_cmpmask_offset to tlb_way3_cmpmask_offset+tlb_way3_cmpmask_q'length-1),
           scout   => sov_1(tlb_way3_cmpmask_offset to tlb_way3_cmpmask_offset+tlb_way3_cmpmask_q'length-1),
           din     => tlb_way3_cmpmask_d,
           dout    => tlb_way3_cmpmask_q  );
tlb_way0_xbitmask_latch: tri_rlmreg_p
 generic map (width => tlb_way0_xbitmask_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(12),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_0(tlb_way0_xbitmask_offset to tlb_way0_xbitmask_offset+tlb_way0_xbitmask_q'length-1),
           scout   => sov_0(tlb_way0_xbitmask_offset to tlb_way0_xbitmask_offset+tlb_way0_xbitmask_q'length-1),
           din     => tlb_way0_xbitmask_d,
           dout    => tlb_way0_xbitmask_q  );
tlb_way1_xbitmask_latch: tri_rlmreg_p
 generic map (width => tlb_way1_xbitmask_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(12),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_0(tlb_way1_xbitmask_offset to tlb_way1_xbitmask_offset+tlb_way1_xbitmask_q'length-1),
           scout   => sov_0(tlb_way1_xbitmask_offset to tlb_way1_xbitmask_offset+tlb_way1_xbitmask_q'length-1),
           din     => tlb_way1_xbitmask_d,
           dout    => tlb_way1_xbitmask_q  );
tlb_way2_xbitmask_latch: tri_rlmreg_p
 generic map (width => tlb_way2_xbitmask_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(13),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_1(tlb_way2_xbitmask_offset to tlb_way2_xbitmask_offset+tlb_way2_xbitmask_q'length-1),
           scout   => sov_1(tlb_way2_xbitmask_offset to tlb_way2_xbitmask_offset+tlb_way2_xbitmask_q'length-1),
           din     => tlb_way2_xbitmask_d,
           dout    => tlb_way2_xbitmask_q  );
tlb_way3_xbitmask_latch: tri_rlmreg_p
 generic map (width => tlb_way3_xbitmask_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
 port map (vd      => vdd,
             gd      => gnd, 
           nclk    => nclk,
           act     => tlb_delayed_act(13),
           thold_b => pc_func_slp_sl_thold_0_b,
           sg      => pc_sg_0,
           forcee => pc_func_slp_sl_force,
           delay_lclkr => lcb_delay_lclkr_dc(0),
           mpw1_b      => lcb_mpw1_dc_b(0),
           mpw2_b      => lcb_mpw2_dc_b,
           d_mode      => lcb_d_mode_dc,
           scin    => siv_1(tlb_way3_xbitmask_offset to tlb_way3_xbitmask_offset+tlb_way3_xbitmask_q'length-1),
           scout   => sov_1(tlb_way3_xbitmask_offset to tlb_way3_xbitmask_offset+tlb_way3_xbitmask_q'length-1),
           din     => tlb_way3_xbitmask_d,
           dout    => tlb_way3_xbitmask_q  );
tlb_tag4_latch: tri_rlmreg_p
  generic map (width => tlb_tag4_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(10),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_tag4_offset to tlb_tag4_offset+tlb_tag4_q'length-1),
            scout   => sov_2(tlb_tag4_offset to tlb_tag4_offset+tlb_tag4_q'length-1),
            din     => tlb_tag4_d(0 to tlb_tag_width-1),
            dout    => tlb_tag4_q(0 to tlb_tag_width-1)  );
tlb_tag4_wayhit_latch: tri_rlmreg_p
  generic map (width => tlb_tag4_wayhit_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(10),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_tag4_wayhit_offset to tlb_tag4_wayhit_offset+tlb_tag4_wayhit_q'length-1),
            scout   => sov_2(tlb_tag4_wayhit_offset to tlb_tag4_wayhit_offset+tlb_tag4_wayhit_q'length-1),
            din     => tlb_tag4_wayhit_d(0 to tlb_ways),
            dout    => tlb_tag4_wayhit_q(0 to tlb_ways)  );
tlb_addr4_latch: tri_rlmreg_p
  generic map (width => tlb_addr4_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(10),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_addr4_offset to tlb_addr4_offset+tlb_addr4_q'length-1),
            scout   => sov_2(tlb_addr4_offset to tlb_addr4_offset+tlb_addr4_q'length-1),
            din     => tlb_addr4_d(0 to tlb_addr_width-1),
            dout    => tlb_addr4_q(0 to tlb_addr_width-1)  );
tlb_dataina_latch: tri_rlmreg_p
  generic map (width => tlb_dataina_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(14),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_dataina_offset to tlb_dataina_offset+tlb_dataina_q'length-1),
            scout   => sov_0(tlb_dataina_offset to tlb_dataina_offset+tlb_dataina_q'length-1),
            din     => tlb_dataina_d(0 to tlb_way_width-1),
            dout    => tlb_dataina_q(0 to tlb_way_width-1)  );
tlb_datainb_latch: tri_rlmreg_p
  generic map (width => tlb_datainb_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(15),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(tlb_datainb_offset to tlb_datainb_offset+tlb_datainb_q'length-1),
            scout   => sov_1(tlb_datainb_offset to tlb_datainb_offset+tlb_datainb_q'length-1),
            din     => tlb_datainb_d(0 to tlb_way_width-1),
            dout    => tlb_datainb_q(0 to tlb_way_width-1)  );
lru_tag4_dataout_latch: tri_rlmreg_p
  generic map (width => lru_tag4_dataout_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(10),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(lru_tag4_dataout_offset to lru_tag4_dataout_offset+lru_tag4_dataout_q'length-1),
            scout   => sov_2(lru_tag4_dataout_offset to lru_tag4_dataout_offset+lru_tag4_dataout_q'length-1),
            din     => lru_tag4_dataout_d(0 to 15),
            dout    => lru_tag4_dataout_q(0 to 15)  );
tlb_tag4_way_latch: tri_rlmreg_p
  generic map (width => tlb_tag4_way_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_tag4_way_act,   
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_tag4_way_offset to tlb_tag4_way_offset+tlb_tag4_way_q'length-1),
            scout   => sov_0(tlb_tag4_way_offset to tlb_tag4_way_offset+tlb_tag4_way_q'length-1),
            din     => tlb_tag4_way_d(0 to tlb_way_width-1),
            dout    => tlb_tag4_way_q(0 to tlb_way_width-1)  );
tlb_tag4_way_clone_latch: tri_rlmreg_p
  generic map (width => tlb_tag4_way_clone_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_tag4_way_clone_act,   
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(tlb_tag4_way_clone_offset to tlb_tag4_way_clone_offset+tlb_tag4_way_clone_q'length-1),
            scout   => sov_1(tlb_tag4_way_clone_offset to tlb_tag4_way_clone_offset+tlb_tag4_way_clone_q'length-1),
            din     => tlb_tag4_way_clone_d(0 to tlb_way_width-1),
            dout    => tlb_tag4_way_clone_q(0 to tlb_way_width-1)  );
tlb_tag4_way_rw_latch: tri_rlmreg_p
  generic map (width => tlb_tag4_way_rw_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_tag4_way_rw_act,  
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_tag4_way_rw_offset to tlb_tag4_way_rw_offset+tlb_tag4_way_rw_q'length-1),
            scout   => sov_0(tlb_tag4_way_rw_offset to tlb_tag4_way_rw_offset+tlb_tag4_way_rw_q'length-1),
            din     => tlb_tag4_way_rw_d(0 to tlb_way_width-1),
            dout    => tlb_tag4_way_rw_q(0 to tlb_way_width-1)  );
tlb_tag4_way_rw_clone_latch: tri_rlmreg_p
  generic map (width => tlb_tag4_way_rw_clone_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_tag4_way_rw_clone_act,  
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(tlb_tag4_way_rw_clone_offset to tlb_tag4_way_rw_clone_offset+tlb_tag4_way_rw_clone_q'length-1),
            scout   => sov_1(tlb_tag4_way_rw_clone_offset to tlb_tag4_way_rw_clone_offset+tlb_tag4_way_rw_clone_q'length-1),
            din     => tlb_tag4_way_rw_clone_d(0 to tlb_way_width-1),
            dout    => tlb_tag4_way_rw_clone_q(0 to tlb_way_width-1)  );
tlbwe_tag4_back_inv_latch: tri_rlmreg_p
  generic map (width => tlbwe_tag4_back_inv_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(10),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlbwe_tag4_back_inv_offset to tlbwe_tag4_back_inv_offset+tlbwe_tag4_back_inv_q'length-1),
            scout   => sov_2(tlbwe_tag4_back_inv_offset to tlbwe_tag4_back_inv_offset+tlbwe_tag4_back_inv_q'length-1),
            din     => tlbwe_tag4_back_inv_d,
            dout    => tlbwe_tag4_back_inv_q );
tlbwe_tag4_back_inv_attr_latch: tri_rlmreg_p
  generic map (width => tlbwe_tag4_back_inv_attr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(10),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlbwe_tag4_back_inv_attr_offset to tlbwe_tag4_back_inv_attr_offset+tlbwe_tag4_back_inv_attr_q'length-1),
            scout   => sov_2(tlbwe_tag4_back_inv_attr_offset to tlbwe_tag4_back_inv_attr_offset+tlbwe_tag4_back_inv_attr_q'length-1),
            din     => tlbwe_tag4_back_inv_attr_d,
            dout    => tlbwe_tag4_back_inv_attr_q );
tlb_erat_val_latch: tri_rlmreg_p
  generic map (width => tlb_erat_val_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(14),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_erat_val_offset to tlb_erat_val_offset+tlb_erat_val_q'length-1),
            scout   => sov_2(tlb_erat_val_offset to tlb_erat_val_offset+tlb_erat_val_q'length-1),
            din     => tlb_erat_val_d(0 to 2*thdid_width+1),
            dout    => tlb_erat_val_q(0 to 2*thdid_width+1)  );
tlb_erat_rel_latch: tri_rlmreg_p
  generic map (width => tlb_erat_rel_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(14),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_erat_rel_offset to tlb_erat_rel_offset+tlb_erat_rel_q'length-1),
            scout   => sov_0(tlb_erat_rel_offset to tlb_erat_rel_offset+tlb_erat_rel_q'length-1),
            din     => tlb_erat_rel_d(0 to erat_rel_data_width-1),
            dout    => tlb_erat_rel_q(0 to erat_rel_data_width-1)  );
tlb_erat_rel_clone_latch: tri_rlmreg_p
  generic map (width => tlb_erat_rel_clone_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(15),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(tlb_erat_rel_clone_offset to tlb_erat_rel_clone_offset+tlb_erat_rel_clone_q'length-1),
            scout   => sov_1(tlb_erat_rel_clone_offset to tlb_erat_rel_clone_offset+tlb_erat_rel_clone_q'length-1),
            din     => tlb_erat_rel_clone_d(0 to erat_rel_data_width-1),
            dout    => tlb_erat_rel_clone_q(0 to erat_rel_data_width-1)  );
tlb_erat_dup_latch: tri_rlmreg_p
  generic map (width => tlb_erat_dup_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => xu_mm_ccr2_notlb_b,  
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_erat_dup_offset to tlb_erat_dup_offset+tlb_erat_dup_q'length-1),
            scout   => sov_2(tlb_erat_dup_offset to tlb_erat_dup_offset+tlb_erat_dup_q'length-1),
            din     => tlb_erat_dup_d,
            dout    => tlb_erat_dup_q  );
lru_write_latch: tri_rlmreg_p
  generic map (width => lru_write_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(11),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(lru_write_offset to lru_write_offset+lru_write_q'length-1),
            scout   => sov_2(lru_write_offset to lru_write_offset+lru_write_q'length-1),
            din     => lru_write_d(0 to 15),
            dout    => lru_write_q(0 to 15)  );
lru_wr_addr_latch: tri_rlmreg_p
  generic map (width => lru_wr_addr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(11),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(lru_wr_addr_offset to lru_wr_addr_offset+lru_wr_addr_q'length-1),
            scout   => sov_2(lru_wr_addr_offset to lru_wr_addr_offset+lru_wr_addr_q'length-1),
            din     => lru_wr_addr_d(0 to tlb_addr_width-1),
            dout    => lru_wr_addr_q(0 to tlb_addr_width-1)  );
lru_datain_latch: tri_rlmreg_p
  generic map (width => lru_datain_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(11),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(lru_datain_offset to lru_datain_offset+lru_datain_q'length-1),
            scout   => sov_2(lru_datain_offset to lru_datain_offset+lru_datain_q'length-1),
            din     => lru_datain_d(0 to 15),
            dout    => lru_datain_q(0 to 15)  );
eratmiss_done_latch: tri_rlmreg_p
  generic map (width => eratmiss_done_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(eratmiss_done_offset to eratmiss_done_offset+eratmiss_done_q'length-1),
            scout   => sov_2(eratmiss_done_offset to eratmiss_done_offset+eratmiss_done_q'length-1),
            din     => eratmiss_done_d(0 to thdid_width-1),
            dout    => eratmiss_done_q(0 to thdid_width-1));
tlb_miss_latch: tri_rlmreg_p
  generic map (width => tlb_miss_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_miss_offset to tlb_miss_offset+tlb_miss_q'length-1),
            scout   => sov_2(tlb_miss_offset to tlb_miss_offset+tlb_miss_q'length-1),
            din     => tlb_miss_d(0 to thdid_width-1),
            dout    => tlb_miss_q(0 to thdid_width-1));
tlb_inelig_latch: tri_rlmreg_p
  generic map (width => tlb_inelig_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_inelig_offset to tlb_inelig_offset+tlb_inelig_q'length-1),
            scout   => sov_2(tlb_inelig_offset to tlb_inelig_offset+tlb_inelig_q'length-1),
            din     => tlb_inelig_d(0 to thdid_width-1),
            dout    => tlb_inelig_q(0 to thdid_width-1));
lrat_miss_latch: tri_rlmreg_p
  generic map (width => lrat_miss_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(lrat_miss_offset to lrat_miss_offset+lrat_miss_q'length-1),
            scout   => sov_2(lrat_miss_offset to lrat_miss_offset+lrat_miss_q'length-1),
            din     => lrat_miss_d(0 to thdid_width-1),
            dout    => lrat_miss_q(0 to thdid_width-1));
pt_fault_latch: tri_rlmreg_p
  generic map (width => pt_fault_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(pt_fault_offset to pt_fault_offset+pt_fault_q'length-1),
            scout   => sov_2(pt_fault_offset to pt_fault_offset+pt_fault_q'length-1),
            din     => pt_fault_d(0 to thdid_width-1),
            dout    => pt_fault_q(0 to thdid_width-1));
hv_priv_latch: tri_rlmreg_p
  generic map (width => hv_priv_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(hv_priv_offset to hv_priv_offset+hv_priv_q'length-1),
            scout   => sov_2(hv_priv_offset to hv_priv_offset+hv_priv_q'length-1),
            din     => hv_priv_d(0 to thdid_width-1),
            dout    => hv_priv_q(0 to thdid_width-1));
tlb_tag5_except_latch: tri_rlmreg_p
  generic map (width => tlb_tag5_except_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(11),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_tag5_except_offset to tlb_tag5_except_offset+tlb_tag5_except_q'length-1),
            scout   => sov_2(tlb_tag5_except_offset to tlb_tag5_except_offset+tlb_tag5_except_q'length-1),
            din     => tlb_tag5_except_d(0 to thdid_width-1),
            dout    => tlb_tag5_except_q(0 to thdid_width-1));
tlb_dsi_latch: tri_rlmreg_p
  generic map (width => tlb_dsi_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_dsi_offset to tlb_dsi_offset+tlb_dsi_q'length-1),
            scout   => sov_2(tlb_dsi_offset to tlb_dsi_offset+tlb_dsi_q'length-1),
            din     => tlb_dsi_d(0 to thdid_width-1),
            dout    => tlb_dsi_q(0 to thdid_width-1));
tlb_isi_latch: tri_rlmreg_p
  generic map (width => tlb_isi_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_isi_offset to tlb_isi_offset+tlb_isi_q'length-1),
            scout   => sov_2(tlb_isi_offset to tlb_isi_offset+tlb_isi_q'length-1),
            din     => tlb_isi_d(0 to thdid_width-1),
            dout    => tlb_isi_q(0 to thdid_width-1));
esr_pt_latch: tri_rlmreg_p
  generic map (width => esr_pt_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(esr_pt_offset to esr_pt_offset+esr_pt_q'length-1),
            scout   => sov_2(esr_pt_offset to esr_pt_offset+esr_pt_q'length-1),
            din     => esr_pt_d(0 to thdid_width-1),
            dout    => esr_pt_q(0 to thdid_width-1));
esr_data_latch: tri_rlmreg_p
  generic map (width => esr_data_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(esr_data_offset to esr_data_offset+esr_data_q'length-1),
            scout   => sov_2(esr_data_offset to esr_data_offset+esr_data_q'length-1),
            din     => esr_data_d(0 to thdid_width-1),
            dout    => esr_data_q(0 to thdid_width-1));
esr_st_latch: tri_rlmreg_p
  generic map (width => esr_st_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(esr_st_offset to esr_st_offset+esr_st_q'length-1),
            scout   => sov_2(esr_st_offset to esr_st_offset+esr_st_q'length-1),
            din     => esr_st_d(0 to thdid_width-1),
            dout    => esr_st_q(0 to thdid_width-1));
esr_epid_latch: tri_rlmreg_p
  generic map (width => esr_epid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(esr_epid_offset to esr_epid_offset+esr_epid_q'length-1),
            scout   => sov_2(esr_epid_offset to esr_epid_offset+esr_epid_q'length-1),
            din     => esr_epid_d(0 to thdid_width-1),
            dout    => esr_epid_q(0 to thdid_width-1));
cr0_eq_latch: tri_rlmreg_p
  generic map (width => cr0_eq_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(cr0_eq_offset to cr0_eq_offset+cr0_eq_q'length-1),
            scout   => sov_2(cr0_eq_offset to cr0_eq_offset+cr0_eq_q'length-1),
            din     => cr0_eq_d(0 to thdid_width-1),
            dout    => cr0_eq_q(0 to thdid_width-1));
cr0_eq_valid_latch: tri_rlmreg_p
  generic map (width => cr0_eq_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(cr0_eq_valid_offset to cr0_eq_valid_offset+cr0_eq_valid_q'length-1),
            scout   => sov_2(cr0_eq_valid_offset to cr0_eq_valid_offset+cr0_eq_valid_q'length-1),
            din     => cr0_eq_valid_d(0 to thdid_width-1),
            dout    => cr0_eq_valid_q(0 to thdid_width-1));
tlb_multihit_err_latch: tri_rlmreg_p
  generic map (width => tlb_multihit_err_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_multihit_err_offset to tlb_multihit_err_offset+tlb_multihit_err_q'length-1),
            scout   => sov_2(tlb_multihit_err_offset to tlb_multihit_err_offset+tlb_multihit_err_q'length-1),
            din     => tlb_multihit_err_d(0 to thdid_width-1),
            dout    => tlb_multihit_err_q(0 to thdid_width-1));
tag4_parerr_latch: tri_rlmreg_p
  generic map (width => tag4_parerr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(10),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tag4_parerr_offset to tag4_parerr_offset+tag4_parerr_q'length-1),
            scout   => sov_2(tag4_parerr_offset to tag4_parerr_offset+tag4_parerr_q'length-1),
            din     => tag4_parerr_d,
            dout    => tag4_parerr_q );
tlb_par_err_latch: tri_rlmreg_p
  generic map (width => tlb_par_err_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(tlb_par_err_offset to tlb_par_err_offset+tlb_par_err_q'length-1),
            scout   => sov_2(tlb_par_err_offset to tlb_par_err_offset+tlb_par_err_q'length-1),
            din     => ECO107332_tlb_par_err_d(0 to thdid_width-1),
            dout    => tlb_par_err_q(0 to thdid_width-1));
lru_par_err_latch: tri_rlmreg_p
  generic map (width => lru_par_err_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(lru_par_err_offset to lru_par_err_offset+lru_par_err_q'length-1),
            scout   => sov_2(lru_par_err_offset to lru_par_err_offset+lru_par_err_q'length-1),
            din     => ECO107332_lru_par_err_d(0 to thdid_width-1),
            dout    => lru_par_err_q(0 to thdid_width-1));
mmucr1_latch: tri_rlmreg_p
  generic map (width => mmucr1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_mm_ccr2_notlb_b,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(mmucr1_offset to mmucr1_offset+mmucr1_q'length-1),
            scout   => sov_0(mmucr1_offset to mmucr1_offset+mmucr1_q'length-1),
            din     => mmucr1,
            dout    => mmucr1_q );
mmucr1_clone_latch: tri_rlmreg_p
  generic map (width => mmucr1_clone_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_mm_ccr2_notlb_b,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mmucr1_clone_offset to mmucr1_clone_offset+mmucr1_clone_q'length-1),
            scout   => sov_1(mmucr1_clone_offset to mmucr1_clone_offset+mmucr1_clone_q'length-1),
            din     => mmucr1,
            dout    => mmucr1_clone_q );
spare_a_latch: tri_rlmreg_p
  generic map (width => spare_a_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(14),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spare_a_offset to spare_a_offset+spare_a_q'length-1),
            scout   => sov_0(spare_a_offset to spare_a_offset+spare_a_q'length-1),
            din     => spare_a_q,
            dout    => spare_a_q );
spare_b_latch: tri_rlmreg_p
  generic map (width => spare_b_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(15),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spare_b_offset to spare_b_offset+spare_b_q'length-1),
            scout   => sov_1(spare_b_offset to spare_b_offset+spare_b_q'length-1),
            din     => spare_b_q,
            dout    => spare_b_q );
cswitch_latch: tri_rlmreg_p
  generic map (width => cswitch_q'length, init => mmq_tlb_cmp_cswitch_0to7, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(cswitch_offset to cswitch_offset+cswitch_q'length-1),
            scout   => sov_2(cswitch_offset to cswitch_offset+cswitch_q'length-1),
            din     => cswitch_q,
            dout    => cswitch_q );
spare_c_latch: tri_rlmreg_p
  generic map (width => spare_c_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act(16),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_2(spare_c_offset to spare_c_offset+spare_c_q'length-1),
            scout   => sov_2(spare_c_offset to spare_c_offset+spare_c_q'length-1),
            din     => spare_c_q,
            dout    => spare_c_q );
spare_nsl_latch : tri_regk
  generic map (width => spare_nsl_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => xu_mm_ccr2_notlb_b,
            forcee => pc_func_slp_nsl_force(0),
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b(0),
            din     => spare_nsl_q,
            dout    => spare_nsl_q);
spare_nsl_clone_latch : tri_regk
  generic map (width => spare_nsl_clone_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => xu_mm_ccr2_notlb_b,
            forcee => pc_func_slp_nsl_force(1),
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b(1),
            din     => spare_nsl_clone_q,
            dout    => spare_nsl_clone_q);
epcr_dmiuh_latch : tri_regk
  generic map (width => epcr_dmiuh_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => xu_mm_ccr2_notlb_b,
            forcee => pc_func_slp_nsl_force(0),
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b(0),
            din     => xu_mm_spr_epcr_dmiuh,
            dout    => epcr_dmiuh_q);
msr_gs_latch : tri_regk
  generic map (width => msr_gs_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => xu_mm_ccr2_notlb_b,
            forcee => pc_func_slp_nsl_force(0),
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b(0),
            din     => xu_mm_msr_gs,
            dout    => msr_gs_q);
msr_pr_latch : tri_regk
  generic map (width => msr_pr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => xu_mm_ccr2_notlb_b,
            forcee => pc_func_slp_nsl_force(0),
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b(0),
            din     => xu_mm_msr_pr,
            dout    => msr_pr_q);
perv_2to1_reg: tri_plat
  generic map (width => 5, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ccflush_dc,
            din(0)      => pc_func_sl_thold_2,
            din(1)      => pc_func_slp_sl_thold_2,
            din(2)      => pc_func_slp_nsl_thold_2,
            din(3)      => pc_sg_2,
            din(4)      => pc_fce_2,
            q(0)        => pc_func_sl_thold_1,
            q(1)        => pc_func_slp_sl_thold_1,
            q(2)        => pc_func_slp_nsl_thold_1,
            q(3)        => pc_sg_1,
            q(4)        => pc_fce_1);
perv_1to0_reg: tri_plat
  generic map (width => 5, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ccflush_dc,
            din(0)      => pc_func_sl_thold_1,
            din(1)      => pc_func_slp_sl_thold_1,
            din(2)      => pc_func_slp_nsl_thold_1,
            din(3)      => pc_sg_1,
            din(4)      => pc_fce_1,
            q(0)        => pc_func_sl_thold_0,
            q(1)        => pc_func_slp_sl_thold_0,
            q(2)        => pc_func_slp_nsl_thold_0,
            q(3)        => pc_sg_0,
            q(4)        => pc_fce_0);
perv_lcbor_func_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_sl_thold_0,
            sg          => pc_sg_0,
            act_dis     => lcb_act_dis_dc,
            forcee => pc_func_sl_force,
            thold_b     => pc_func_sl_thold_0_b);
perv_lcbor_func_slp_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_slp_sl_thold_0,
            sg          => pc_sg_0,
            act_dis     => lcb_act_dis_dc,
            forcee => pc_func_slp_sl_force,
            thold_b     => pc_func_slp_sl_thold_0_b);
perv_nsl_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_slp_nsl_thold_0,
            sg          => pc_fce_0,
            act_dis     => tidn,
            forcee => pc_func_slp_nsl_force(0),
            thold_b     => pc_func_slp_nsl_thold_0_b(0));
perv_nsl_lcbor_clone: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_slp_nsl_thold_0,
            sg          => pc_fce_0,
            act_dis     => tidn,
            forcee => pc_func_slp_nsl_force(1),
            thold_b     => pc_func_slp_nsl_thold_0_b(1));
siv_0(0 TO scan_right_0) <=  sov_0(1 to scan_right_0) & ac_func_scan_in(0);
ac_func_scan_out(0) <=  sov_0(0);
siv_1(0 TO scan_right_1) <=  sov_1(1 to scan_right_1) & ac_func_scan_in(1);
ac_func_scan_out(1) <=  sov_1(0);
siv_2(0 TO scan_right_2) <=  sov_2(1 to scan_right_2) & ac_func_scan_in(2);
ac_func_scan_out(2) <=  sov_2(0);
END MMQ_TLB_CMP;

