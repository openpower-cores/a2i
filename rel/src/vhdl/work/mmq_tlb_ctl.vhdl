-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

			

--********************************************************************
--* TITLE: Memory Management Unit TLB Central Control Logic
--* NAME: mmq_tlb_ctl.vhdl
--*********************************************************************

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

entity mmq_tlb_ctl is
  generic(thdid_width       : integer := 4;
            ttype_width        : integer := 5;
            state_width        : integer := 4;
            pid_width          : integer := 14;
            lpid_width         : integer := 8;
            class_width        : integer := 2;
            extclass_width     : integer := 2;
            tlbsel_width       : integer := 2;
            epn_width          : integer := 52;
            req_epn_width      : integer := 52;
            vpn_width          : integer := 61;
            erat_cam_data_width       : integer := 75;
            erat_ary_data_width       : integer := 73;
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
            tlb_way_width      : natural := 168;
            tlb_word_width     : natural := 84;
            tlb_seq_width      : integer := 6;
            inv_seq_width      : integer := 5;
            watermark_width    : integer := 4;
            eptr_width         : integer := 4;
            lru_width          : integer := 26;
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
            tlb_tag_width      : natural := 110;
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
ac_func_scan_in          :in     std_ulogic;
ac_func_scan_out         :out    std_ulogic;
pc_sg_2                : in     std_ulogic;
pc_func_sl_thold_2     : in     std_ulogic;
pc_func_slp_sl_thold_2 : in     std_ulogic;
pc_func_slp_nsl_thold_2  : in   std_ulogic;
pc_fce_2               : in     std_ulogic;
xu_mm_rf1_val           : in std_ulogic_vector(0 to 3);
xu_mm_rf1_is_tlbre      : in std_ulogic;
xu_mm_rf1_is_tlbwe      : in std_ulogic;
xu_mm_rf1_is_tlbsx      : in std_ulogic;
xu_mm_rf1_is_tlbsxr     : in std_ulogic;
xu_mm_rf1_is_tlbsrx     : in std_ulogic;
xu_mm_ex2_epn           : in std_ulogic_vector(64-rs_data_width to 51);
xu_mm_msr_gs           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_msr_pr           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_msr_is           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_msr_ds           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_msr_cm           : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ccr2_notlb_b      : in std_ulogic;
xu_mm_epcr_dgtmi        : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_xucr4_mmu_mchk    : in std_ulogic;
xu_mm_xucr4_mmu_mchk_q  : out std_ulogic;
xu_rf1_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex1_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex2_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex3_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex4_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_ex5_flush            : in std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_ex3_valid       : out std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_ex3_ttype       : out std_ulogic_vector(0 to ttype_width-1);
tlb_ctl_tag2_flush            : out std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_tag3_flush            : out std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_tag4_flush            : out std_ulogic_vector(0 to thdid_width-1);
tlb_resv_match_vec            : out std_ulogic_vector(0 to thdid_width-1);
mm_xu_eratmiss_done : in std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_miss      : in std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_inelig    : in std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_barrier_done    : out std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_ex2_flush_req   : out std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_quiesce           : out std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_ex2_illeg_instr      : out std_ulogic_vector(0 to thdid_width-1);
ex6_illeg_instr              : out std_ulogic_vector(0 to 1);
tlbwe_back_inv_pending     : in std_ulogic;
pid0            : in std_ulogic_vector(0 to pid_width-1);
pid1            : in std_ulogic_vector(0 to pid_width-1);
pid2            : in std_ulogic_vector(0 to pid_width-1);
pid3            : in std_ulogic_vector(0 to pid_width-1);
mmucr1_tlbi_msb   : in std_ulogic;
mmucr1_tlbwe_binv : in std_ulogic;
mmucr2          : in std_ulogic_vector(0 to mmucr2_width-1);
mmucr3_0        : in std_ulogic_vector(64-mmucr3_width to 63);
mmucr3_1        : in std_ulogic_vector(64-mmucr3_width to 63);
mmucr3_2        : in std_ulogic_vector(64-mmucr3_width to 63);
mmucr3_3        : in std_ulogic_vector(64-mmucr3_width to 63);
lpidr           : in std_ulogic_vector(0 to lpid_width-1);
mmucfg_lrat       : in std_ulogic;
mmucfg_twc        : in std_ulogic;
tlb0cfg_pt        : in std_ulogic;
tlb0cfg_ind       : in std_ulogic;
tlb0cfg_gtwe      : in std_ulogic;
mmucsr0_tlb0fi     : in std_ulogic;
mas0_0_atsel           : in std_ulogic;
mas0_0_esel            : in std_ulogic_vector(0 to 2);
mas0_0_hes             : in std_ulogic;
mas0_0_wq              : in std_ulogic_vector(0 to 1);
mas1_0_v               : in std_ulogic;
mas1_0_iprot           : in std_ulogic;
mas1_0_tid             : in std_ulogic_vector(0 to 13);
mas1_0_ind             : in std_ulogic;
mas1_0_ts              : in std_ulogic;
mas1_0_tsize           : in std_ulogic_vector(0 to 3);
mas2_0_epn             : in std_ulogic_vector(0 to 51);
mas2_0_wimge           : in std_ulogic_vector(0 to 4);
mas3_0_usxwr           : in std_ulogic_vector(0 to 3);
mas5_0_sgs             : in std_ulogic;
mas5_0_slpid           : in std_ulogic_vector(0 to 7);
mas6_0_spid            : in std_ulogic_vector(0 to 13);
mas6_0_sind            : in std_ulogic;
mas6_0_sas             : in std_ulogic;
mas8_0_tgs             : in std_ulogic;
mas8_0_tlpid           : in std_ulogic_vector(0 to 7);
mas0_1_atsel           : in std_ulogic;
mas0_1_esel            : in std_ulogic_vector(0 to 2);
mas0_1_hes             : in std_ulogic;
mas0_1_wq              : in std_ulogic_vector(0 to 1);
mas1_1_v               : in std_ulogic;
mas1_1_iprot           : in std_ulogic;
mas1_1_tid             : in std_ulogic_vector(0 to 13);
mas1_1_ind             : in std_ulogic;
mas1_1_ts              : in std_ulogic;
mas1_1_tsize           : in std_ulogic_vector(0 to 3);
mas2_1_epn             : in std_ulogic_vector(0 to 51);
mas2_1_wimge           : in std_ulogic_vector(0 to 4);
mas3_1_usxwr           : in std_ulogic_vector(0 to 3);
mas5_1_sgs             : in std_ulogic;
mas5_1_slpid           : in std_ulogic_vector(0 to 7);
mas6_1_spid            : in std_ulogic_vector(0 to 13);
mas6_1_sind            : in std_ulogic;
mas6_1_sas             : in std_ulogic;
mas8_1_tgs             : in std_ulogic;
mas8_1_tlpid           : in std_ulogic_vector(0 to 7);
mas0_2_atsel           : in std_ulogic;
mas0_2_esel            : in std_ulogic_vector(0 to 2);
mas0_2_hes             : in std_ulogic;
mas0_2_wq              : in std_ulogic_vector(0 to 1);
mas1_2_v               : in std_ulogic;
mas1_2_iprot           : in std_ulogic;
mas1_2_tid             : in std_ulogic_vector(0 to 13);
mas1_2_ind             : in std_ulogic;
mas1_2_ts              : in std_ulogic;
mas1_2_tsize           : in std_ulogic_vector(0 to 3);
mas2_2_epn             : in std_ulogic_vector(0 to 51);
mas2_2_wimge           : in std_ulogic_vector(0 to 4);
mas3_2_usxwr           : in std_ulogic_vector(0 to 3);
mas5_2_sgs             : in std_ulogic;
mas5_2_slpid           : in std_ulogic_vector(0 to 7);
mas6_2_spid            : in std_ulogic_vector(0 to 13);
mas6_2_sind            : in std_ulogic;
mas6_2_sas             : in std_ulogic;
mas8_2_tgs             : in std_ulogic;
mas8_2_tlpid           : in std_ulogic_vector(0 to 7);
mas0_3_atsel           : in std_ulogic;
mas0_3_esel            : in std_ulogic_vector(0 to 2);
mas0_3_hes             : in std_ulogic;
mas0_3_wq              : in std_ulogic_vector(0 to 1);
mas1_3_v               : in std_ulogic;
mas1_3_iprot           : in std_ulogic;
mas1_3_tid             : in std_ulogic_vector(0 to 13);
mas1_3_ind             : in std_ulogic;
mas1_3_ts              : in std_ulogic;
mas1_3_tsize           : in std_ulogic_vector(0 to 3);
mas2_3_epn             : in std_ulogic_vector(0 to 51);
mas2_3_wimge           : in std_ulogic_vector(0 to 4);
mas3_3_usxwr           : in std_ulogic_vector(0 to 3);
mas5_3_sgs             : in std_ulogic;
mas5_3_slpid           : in std_ulogic_vector(0 to 7);
mas6_3_spid            : in std_ulogic_vector(0 to 13);
mas6_3_sind            : in std_ulogic;
mas6_3_sas             : in std_ulogic;
mas8_3_tgs             : in std_ulogic;
mas8_3_tlpid           : in std_ulogic_vector(0 to 7);
tlb_seq_ierat_req          : in std_ulogic;
tlb_seq_derat_req          : in std_ulogic;
tlb_seq_ierat_done        : out std_ulogic;
tlb_seq_derat_done        : out std_ulogic;
tlb_seq_idle              : out std_ulogic;
ierat_req_taken       : out std_ulogic;
derat_req_taken       : out std_ulogic;
ierat_req_epn   : in std_ulogic_vector(0 to req_epn_width-1);
ierat_req_pid   : in std_ulogic_vector(0 to pid_width-1);
ierat_req_state : in std_ulogic_vector(0 to state_width-1);
ierat_req_thdid : in std_ulogic_vector(0 to thdid_width-1);
ierat_req_dup   : in std_ulogic_vector(0 to 1);
derat_req_epn   : in std_ulogic_vector(0 to req_epn_width-1);
derat_req_pid   : in std_ulogic_vector(0 to pid_width-1);
derat_req_lpid  : in std_ulogic_vector(0 to lpid_width-1);
derat_req_state : in std_ulogic_vector(0 to state_width-1);
derat_req_ttype : in std_ulogic_vector(0 to 1);
derat_req_thdid : in std_ulogic_vector(0 to thdid_width-1);
derat_req_dup   : in std_ulogic_vector(0 to 1);
ptereload_req_valid : in std_ulogic;
ptereload_req_tag   : in std_ulogic_vector(0 to tlb_tag_width-1);
ptereload_req_pte   : in std_ulogic_vector(0 to pte_width-1);
ptereload_req_taken : out std_ulogic;
tlb_snoop_coming           : in std_ulogic;
tlb_snoop_val              : in std_ulogic;
tlb_snoop_attr             : in std_ulogic_vector(0 to 34);
tlb_snoop_vpn              : in std_ulogic_vector(52-epn_width to 51);
tlb_snoop_ack              : out std_ulogic;
lru_rd_addr             : out std_ulogic_vector(0 to tlb_addr_width-1);
lru_tag4_dataout   : in std_ulogic_vector(0 to 15);
tlb_tag4_esel      : in std_ulogic_vector(0 to 2);
tlb_tag4_wq        : in std_ulogic_vector(0 to 1);
tlb_tag4_is        : in std_ulogic_vector(0 to 1);
tlb_tag4_gs        : in std_ulogic;
tlb_tag4_pr        : in std_ulogic;
tlb_tag4_hes       : in std_ulogic;
tlb_tag4_atsel     : in std_ulogic;
tlb_tag4_pt        : in std_ulogic;
tlb_tag4_cmp_hit   : in std_ulogic;
tlb_tag4_way_ind   : in std_ulogic;
tlb_tag4_ptereload : in std_ulogic;
tlb_tag4_endflag   : in std_ulogic;
tlb_tag4_parerr    : in std_ulogic;
tlb_tag5_except    : in std_ulogic_vector(0 to thdid_width-1);
tlb_cmp_erat_dup_wait : in std_ulogic_vector(0 to 1);
tlb_tag0_epn         : out std_ulogic_vector(52-epn_width to 51);
tlb_tag0_thdid       : out std_ulogic_vector(0 to thdid_width-1);
tlb_tag0_type        : out std_ulogic_vector(0 to 7);
tlb_tag0_lpid        : out std_ulogic_vector(0 to lpid_width-1);
tlb_tag0_atsel       : out std_ulogic;
tlb_tag0_size        : out std_ulogic_vector(0 to 3);
tlb_tag0_addr_cap    : out std_ulogic;
tlb_tag2                : out std_ulogic_vector(0 to tlb_tag_width-1);
tlb_addr2               : out std_ulogic_vector(0 to tlb_addr_width-1);
tlb_ctl_perf_tlbwec_resv     : out std_ulogic;
tlb_ctl_perf_tlbwec_noresv   : out std_ulogic;
lrat_tag4_hit_status       : in std_ulogic_vector(0 to 3);
tlb_lper_lpn         : out std_ulogic_vector(64-real_addr_width to 51);
tlb_lper_lps         : out std_ulogic_vector(60 to 63);
tlb_lper_we          : out std_ulogic_vector(0 to thdid_width-1);
ptereload_req_pte_lat      : out std_ulogic_vector(0 to pte_width-1);
pte_tag0_lpn     : out std_ulogic_vector(64-real_addr_width to 51);
pte_tag0_lpid    : out std_ulogic_vector(0 to lpid_width-1);
tlb_write               : out std_ulogic_vector(0 to tlb_ways-1);
tlb_addr                : out std_ulogic_vector(0 to tlb_addr_width-1);
tlb_tag5_write               : out std_ulogic;
tlb_delayed_act  : out std_ulogic_vector(9 to 32);
tlb_ctl_dbg_seq_q                : out  std_ulogic_vector(0 to 5);
tlb_ctl_dbg_seq_idle             : out  std_ulogic;
tlb_ctl_dbg_seq_any_done_sig     : out  std_ulogic;
tlb_ctl_dbg_seq_abort            : out  std_ulogic;
tlb_ctl_dbg_any_tlb_req_sig      : out  std_ulogic;
tlb_ctl_dbg_any_req_taken_sig    : out  std_ulogic;
tlb_ctl_dbg_tag5_tlb_write_q     : out std_ulogic_vector(0 to 3);
tlb_ctl_dbg_tag0_valid          : out  std_ulogic;
tlb_ctl_dbg_tag0_thdid          : out  std_ulogic_vector(0 to 1);
tlb_ctl_dbg_tag0_type           : out  std_ulogic_vector(0 to 2);
tlb_ctl_dbg_tag0_wq             : out  std_ulogic_vector(0 to 1);
tlb_ctl_dbg_tag0_gs             : out  std_ulogic;
tlb_ctl_dbg_tag0_pr             : out  std_ulogic;
tlb_ctl_dbg_tag0_atsel          : out  std_ulogic;
tlb_ctl_dbg_resv_valid          : out  std_ulogic_vector(0 to 3);
tlb_ctl_dbg_set_resv            : out  std_ulogic_vector(0 to 3);
tlb_ctl_dbg_resv_match_vec_q    : out  std_ulogic_vector(0 to 3);
tlb_ctl_dbg_any_tag_flush_sig   : out  std_ulogic;
tlb_ctl_dbg_resv0_tag0_lpid_match         : out std_ulogic;
tlb_ctl_dbg_resv0_tag0_pid_match          : out std_ulogic;
tlb_ctl_dbg_resv0_tag0_as_snoop_match     : out std_ulogic;
tlb_ctl_dbg_resv0_tag0_gs_snoop_match     : out std_ulogic;
tlb_ctl_dbg_resv0_tag0_as_tlbwe_match     : out std_ulogic;
tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match     : out std_ulogic;
tlb_ctl_dbg_resv0_tag0_ind_match          : out std_ulogic;
tlb_ctl_dbg_resv0_tag0_epn_loc_match      : out std_ulogic;
tlb_ctl_dbg_resv0_tag0_epn_glob_match     : out std_ulogic;
tlb_ctl_dbg_resv0_tag0_class_match        : out std_ulogic;
tlb_ctl_dbg_resv1_tag0_lpid_match         : out std_ulogic;
tlb_ctl_dbg_resv1_tag0_pid_match          : out std_ulogic;
tlb_ctl_dbg_resv1_tag0_as_snoop_match     : out std_ulogic;
tlb_ctl_dbg_resv1_tag0_gs_snoop_match     : out std_ulogic;
tlb_ctl_dbg_resv1_tag0_as_tlbwe_match     : out std_ulogic;
tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match     : out std_ulogic;
tlb_ctl_dbg_resv1_tag0_ind_match          : out std_ulogic;
tlb_ctl_dbg_resv1_tag0_epn_loc_match      : out std_ulogic;
tlb_ctl_dbg_resv1_tag0_epn_glob_match     : out std_ulogic;
tlb_ctl_dbg_resv1_tag0_class_match        : out std_ulogic;
tlb_ctl_dbg_resv2_tag0_lpid_match         : out std_ulogic;
tlb_ctl_dbg_resv2_tag0_pid_match          : out std_ulogic;
tlb_ctl_dbg_resv2_tag0_as_snoop_match     : out std_ulogic;
tlb_ctl_dbg_resv2_tag0_gs_snoop_match     : out std_ulogic;
tlb_ctl_dbg_resv2_tag0_as_tlbwe_match     : out std_ulogic;
tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match     : out std_ulogic;
tlb_ctl_dbg_resv2_tag0_ind_match          : out std_ulogic;
tlb_ctl_dbg_resv2_tag0_epn_loc_match      : out std_ulogic;
tlb_ctl_dbg_resv2_tag0_epn_glob_match     : out std_ulogic;
tlb_ctl_dbg_resv2_tag0_class_match        : out std_ulogic;
tlb_ctl_dbg_resv3_tag0_lpid_match         : out std_ulogic;
tlb_ctl_dbg_resv3_tag0_pid_match          : out std_ulogic;
tlb_ctl_dbg_resv3_tag0_as_snoop_match     : out std_ulogic;
tlb_ctl_dbg_resv3_tag0_gs_snoop_match     : out std_ulogic;
tlb_ctl_dbg_resv3_tag0_as_tlbwe_match     : out std_ulogic;
tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match     : out std_ulogic;
tlb_ctl_dbg_resv3_tag0_ind_match          : out std_ulogic;
tlb_ctl_dbg_resv3_tag0_epn_loc_match      : out std_ulogic;
tlb_ctl_dbg_resv3_tag0_epn_glob_match     : out std_ulogic;
tlb_ctl_dbg_resv3_tag0_class_match        : out std_ulogic;
tlb_ctl_dbg_clr_resv_q                    : out std_ulogic_vector(0 to 3);
tlb_ctl_dbg_clr_resv_terms                : out std_ulogic_vector(0 to 3)   
);
end mmq_tlb_ctl;
ARCHITECTURE MMQ_TLB_CTL
          OF MMQ_TLB_CTL
          IS
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
-- reserved for indirect entries
constant ERAT_PgSize_256MB : std_ulogic_vector(0 to 2) := "100";
constant TLB_PgSize_256MB : std_ulogic_vector(0 to 3) := "1001";
-- LRAT page sizes
constant LRAT_PgSize_1TB   : std_ulogic_vector(0 to 3) := "1111";
constant LRAT_PgSize_256GB : std_ulogic_vector(0 to 3) := "1110";
constant LRAT_PgSize_16GB  : std_ulogic_vector(0 to 3) := "1100";
constant LRAT_PgSize_4GB   : std_ulogic_vector(0 to 3) := "1011";
constant LRAT_PgSize_1GB   : std_ulogic_vector(0 to 3) := "1010";
constant LRAT_PgSize_256MB : std_ulogic_vector(0 to 3) := "1001";
constant LRAT_PgSize_16MB  : std_ulogic_vector(0 to 3) := "0111";
constant LRAT_PgSize_1MB   : std_ulogic_vector(0 to 3) := "0101";
constant TlbSeq_Idle  : std_ulogic_vector(0 to 5) := "000000";
constant TlbSeq_Stg1  : std_ulogic_vector(0 to 5) := "000001";
constant TlbSeq_Stg2  : std_ulogic_vector(0 to 5) := "000011";
constant TlbSeq_Stg3  : std_ulogic_vector(0 to 5) := "000010";
constant TlbSeq_Stg4  : std_ulogic_vector(0 to 5) := "000110";
constant TlbSeq_Stg5  : std_ulogic_vector(0 to 5) := "000100";
constant TlbSeq_Stg6  : std_ulogic_vector(0 to 5) := "000101";
constant TlbSeq_Stg7  : std_ulogic_vector(0 to 5) := "000111";
constant TlbSeq_Stg8  : std_ulogic_vector(0 to 5) := "001000";
constant TlbSeq_Stg9  : std_ulogic_vector(0 to 5) := "001001";
constant TlbSeq_Stg10 : std_ulogic_vector(0 to 5) := "001011";
constant TlbSeq_Stg11 : std_ulogic_vector(0 to 5) := "001010";
constant TlbSeq_Stg12 : std_ulogic_vector(0 to 5) := "001110";
constant TlbSeq_Stg13 : std_ulogic_vector(0 to 5) := "001100";
constant TlbSeq_Stg14 : std_ulogic_vector(0 to 5) := "001101";
constant TlbSeq_Stg15 : std_ulogic_vector(0 to 5) := "001111";
constant TlbSeq_Stg16 : std_ulogic_vector(0 to 5) := "010000";
constant TlbSeq_Stg17 : std_ulogic_vector(0 to 5) := "010001";
constant TlbSeq_Stg18 : std_ulogic_vector(0 to 5) := "010011";
constant TlbSeq_Stg19 : std_ulogic_vector(0 to 5) := "010010";
constant TlbSeq_Stg20 : std_ulogic_vector(0 to 5) := "010110";
constant TlbSeq_Stg21 : std_ulogic_vector(0 to 5) := "010100";
constant TlbSeq_Stg22 : std_ulogic_vector(0 to 5) := "010101";
constant TlbSeq_Stg23 : std_ulogic_vector(0 to 5) := "010111";
constant TlbSeq_Stg24 : std_ulogic_vector(0 to 5) := "011000";
constant TlbSeq_Stg25 : std_ulogic_vector(0 to 5) := "011001";
constant TlbSeq_Stg26 : std_ulogic_vector(0 to 5) := "011011";
constant TlbSeq_Stg27 : std_ulogic_vector(0 to 5) := "011010";
constant TlbSeq_Stg28 : std_ulogic_vector(0 to 5) := "011110";
constant TlbSeq_Stg29 : std_ulogic_vector(0 to 5) := "011100";
constant TlbSeq_Stg30 : std_ulogic_vector(0 to 5) := "011101";
constant TlbSeq_Stg31 : std_ulogic_vector(0 to 5) := "011111";
constant TlbSeq_Stg32 : std_ulogic_vector(0 to 5) := "100000";
--tlb_tag0_d <= ( 0:51   epn &
--                52:65  pid &
--                66:67  IS &
--                68:69  Class &
--                70:73  state (pr,gs,as,cm) &
--                74:77  thdid &
--                78:81  size &
--                82:83  derat_miss/ierat_miss &
--                84:85  tlbsx/tlbsrx &
--                86:87  inval_snoop/tlbre &
--                88:89  tlbwe/ptereload &
--                90:97  lpid &
--                98  indirect
--                99  atsel &
--                100:102  esel &
--                103:105  hes/wq(0:1) &
--                106:107  lrat/pt &
--                108  record form
--                109  endflag
constant tagpos_epn      : natural  := 0;
constant tagpos_pid      : natural  := 52;
constant tagpos_is       : natural  := 66;
constant tagpos_class    : natural  := 68;
constant tagpos_state    : natural  := 70;
constant tagpos_thdid    : natural  := 74;
constant tagpos_size     : natural  := 78;
constant tagpos_type    : natural  := 82;
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
-- derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
constant tagpos_type_derat     : natural  := tagpos_type;
constant tagpos_type_ierat     : natural  := tagpos_type+1;
constant tagpos_type_tlbsx     : natural  := tagpos_type+2;
constant tagpos_type_tlbsrx    : natural  := tagpos_type+3;
constant tagpos_type_snoop     : natural  := tagpos_type+4;
constant tagpos_type_tlbre     : natural  := tagpos_type+5;
constant tagpos_type_tlbwe     : natural  := tagpos_type+6;
constant tagpos_type_ptereload : natural  := tagpos_type+7;
-- state: 0:pr 1:gs 2:as 3:cm
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
constant xu_ex1_flush_offset        : natural := 0;
constant ex1_valid_offset           : natural := xu_ex1_flush_offset + thdid_width;
constant ex1_ttype_offset           : natural := ex1_valid_offset + thdid_width;
constant ex1_state_offset           : natural := ex1_ttype_offset + ttype_width;
constant ex1_pid_offset             : natural := ex1_state_offset + state_width+1;
constant ex2_valid_offset           : natural := ex1_pid_offset + pid_width;
constant ex2_flush_offset           : natural := ex2_valid_offset + thdid_width;
constant ex2_flush_req_offset       : natural := ex2_flush_offset + thdid_width;
constant ex2_ttype_offset           : natural := ex2_flush_req_offset + thdid_width;
constant ex2_state_offset           : natural := ex2_ttype_offset + ttype_width;
constant ex2_pid_offset             : natural := ex2_state_offset + state_width+1;
constant ex3_valid_offset           : natural := ex2_pid_offset + pid_width;
constant ex3_flush_offset           : natural := ex3_valid_offset + thdid_width;
constant ex3_ttype_offset           : natural := ex3_flush_offset + thdid_width;
constant ex3_state_offset           : natural := ex3_ttype_offset + ttype_width;
constant ex3_pid_offset             : natural := ex3_state_offset + state_width+1;
constant ex4_valid_offset           : natural := ex3_pid_offset + pid_width;
constant ex4_flush_offset           : natural := ex4_valid_offset + thdid_width;
constant ex4_ttype_offset           : natural := ex4_flush_offset + thdid_width;
constant ex4_state_offset           : natural := ex4_ttype_offset + ttype_width;
constant ex4_pid_offset             : natural := ex4_state_offset + state_width+1;
constant ex5_valid_offset           : natural := ex4_pid_offset + pid_width;
constant ex5_flush_offset           : natural := ex5_valid_offset + thdid_width;
constant ex5_ttype_offset           : natural := ex5_flush_offset + thdid_width;
constant ex5_state_offset           : natural := ex5_ttype_offset + ttype_width;
constant ex5_pid_offset             : natural := ex5_state_offset + state_width+1;
constant ex6_valid_offset           : natural := ex5_pid_offset + pid_width;
constant ex6_flush_offset           : natural := ex6_valid_offset + thdid_width;
constant ex6_ttype_offset           : natural := ex6_flush_offset + thdid_width;
constant ex6_state_offset           : natural := ex6_ttype_offset + ttype_width;
constant ex6_pid_offset             : natural := ex6_state_offset + state_width+1;
constant tlb_addr_offset     : natural := ex6_pid_offset + pid_width;
constant tlb_addr2_offset    : natural := tlb_addr_offset + tlb_addr_width;
constant tlb_write_offset    : natural := tlb_addr2_offset + tlb_addr_width;
constant tlb_tag0_offset     : natural := tlb_write_offset + tlb_ways;
constant tlb_tag1_offset     : natural := tlb_tag0_offset + tlb_tag_width;
constant tlb_tag2_offset     : natural := tlb_tag1_offset + tlb_tag_width;
constant tlb_seq_offset             : natural := tlb_tag2_offset + tlb_tag_width;
constant derat_taken_offset         : natural := tlb_seq_offset + tlb_seq_width;
constant xucr4_mmu_mchk_offset      : natural := derat_taken_offset + 1;
constant ex6_illeg_instr_offset     : natural := xucr4_mmu_mchk_offset + 1;
constant snoop_val_offset        : natural := ex6_illeg_instr_offset + 2;
constant snoop_attr_offset       : natural := snoop_val_offset + 2;
constant snoop_vpn_offset        : natural := snoop_attr_offset + 35;
constant tlb_clr_resv_offset          : natural := snoop_vpn_offset + epn_width;
constant tlb_resv_match_vec_offset    : natural := tlb_clr_resv_offset + thdid_width;
constant tlb_resv0_valid_offset    : natural := tlb_resv_match_vec_offset + thdid_width;
constant tlb_resv0_epn_offset      : natural := tlb_resv0_valid_offset + 1;
constant tlb_resv0_pid_offset      : natural := tlb_resv0_epn_offset + epn_width;
constant tlb_resv0_lpid_offset     : natural := tlb_resv0_pid_offset + pid_width;
constant tlb_resv0_as_offset       : natural := tlb_resv0_lpid_offset + lpid_width;
constant tlb_resv0_gs_offset       : natural := tlb_resv0_as_offset + 1;
constant tlb_resv0_ind_offset      : natural := tlb_resv0_gs_offset + 1;
constant tlb_resv0_class_offset    : natural := tlb_resv0_ind_offset + 1;
constant tlb_resv1_valid_offset      : natural := tlb_resv0_class_offset     + class_width;
constant tlb_resv1_epn_offset        : natural := tlb_resv1_valid_offset   + 1;
constant tlb_resv1_pid_offset        : natural := tlb_resv1_epn_offset   + epn_width;
constant tlb_resv1_lpid_offset       : natural := tlb_resv1_pid_offset   + pid_width;
constant tlb_resv1_as_offset         : natural := tlb_resv1_lpid_offset   + lpid_width;
constant tlb_resv1_gs_offset         : natural := tlb_resv1_as_offset   + 1;
constant tlb_resv1_ind_offset        : natural := tlb_resv1_gs_offset   + 1;
constant tlb_resv1_class_offset      : natural := tlb_resv1_ind_offset   + 1;
constant tlb_resv2_valid_offset      : natural := tlb_resv1_class_offset     + class_width;
constant tlb_resv2_epn_offset        : natural := tlb_resv2_valid_offset   + 1;
constant tlb_resv2_pid_offset        : natural := tlb_resv2_epn_offset   + epn_width;
constant tlb_resv2_lpid_offset       : natural := tlb_resv2_pid_offset   + pid_width;
constant tlb_resv2_as_offset         : natural := tlb_resv2_lpid_offset   + lpid_width;
constant tlb_resv2_gs_offset         : natural := tlb_resv2_as_offset   + 1;
constant tlb_resv2_ind_offset        : natural := tlb_resv2_gs_offset   + 1;
constant tlb_resv2_class_offset      : natural := tlb_resv2_ind_offset   + 1;
constant tlb_resv3_valid_offset      : natural := tlb_resv2_class_offset     + class_width;
constant tlb_resv3_epn_offset        : natural := tlb_resv3_valid_offset   + 1;
constant tlb_resv3_pid_offset        : natural := tlb_resv3_epn_offset   + epn_width;
constant tlb_resv3_lpid_offset       : natural := tlb_resv3_pid_offset   + pid_width;
constant tlb_resv3_as_offset         : natural := tlb_resv3_lpid_offset   + lpid_width;
constant tlb_resv3_gs_offset         : natural := tlb_resv3_as_offset   + 1;
constant tlb_resv3_ind_offset        : natural := tlb_resv3_gs_offset   + 1;
constant tlb_resv3_class_offset      : natural := tlb_resv3_ind_offset   + 1;
constant ptereload_req_pte_offset   : natural := tlb_resv3_class_offset + class_width;
constant tlb_delayed_act_offset     : natural := ptereload_req_pte_offset + pte_width;
constant tlb_ctl_spare_offset       : natural := tlb_delayed_act_offset + 33;
constant scan_right                 : natural := tlb_ctl_spare_offset + 32 -1;
-- Latch signals
signal xu_ex1_flush_d, xu_ex1_flush_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex1_valid_d, ex1_valid_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex1_ttype_d, ex1_ttype_q            : std_ulogic_vector(0 to ttype_width-1);
signal ex1_state_d, ex1_state_q            : std_ulogic_vector(0 to state_width);
signal ex1_pid_d, ex1_pid_q                : std_ulogic_vector(0 to pid_width-1);
signal ex2_valid_d, ex2_valid_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex2_flush_d, ex2_flush_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex2_flush_req_d, ex2_flush_req_q    : std_ulogic_vector(0 to thdid_width-1);
signal ex2_ttype_d, ex2_ttype_q            : std_ulogic_vector(0 to ttype_width-1);
signal ex2_state_d, ex2_state_q            : std_ulogic_vector(0 to state_width);
signal ex2_pid_d, ex2_pid_q                : std_ulogic_vector(0 to pid_width-1);
signal ex3_valid_d, ex3_valid_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex3_flush_d, ex3_flush_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex3_ttype_d, ex3_ttype_q            : std_ulogic_vector(0 to ttype_width-1);
signal ex3_state_d, ex3_state_q            : std_ulogic_vector(0 to state_width);
signal ex3_pid_d, ex3_pid_q                : std_ulogic_vector(0 to pid_width-1);
signal ex4_valid_d, ex4_valid_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex4_flush_d, ex4_flush_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex4_ttype_d, ex4_ttype_q            : std_ulogic_vector(0 to ttype_width-1);
signal ex4_state_d, ex4_state_q            : std_ulogic_vector(0 to state_width);
signal ex4_pid_d, ex4_pid_q                : std_ulogic_vector(0 to pid_width-1);
signal ex5_valid_d,    ex5_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex5_flush_d,    ex5_flush_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex5_ttype_d,    ex5_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex5_state_d,    ex5_state_q           : std_ulogic_vector(0 to state_width);
signal ex5_pid_d,      ex5_pid_q             : std_ulogic_vector(0 to pid_width-1);
signal ex6_valid_d,    ex6_valid_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex6_flush_d,    ex6_flush_q           : std_ulogic_vector(0 to thdid_width-1);
signal ex6_ttype_d,    ex6_ttype_q           : std_ulogic_vector(0 to ttype_width-1);
signal ex6_state_d,    ex6_state_q           : std_ulogic_vector(0 to state_width);
signal ex6_pid_d,      ex6_pid_q             : std_ulogic_vector(0 to pid_width-1);
signal tlb_tag0_d, tlb_tag0_q  : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_tag1_d, tlb_tag1_q  : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_tag2_d, tlb_tag2_q  : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_addr_d, tlb_addr_q    : std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_addr2_d, tlb_addr2_q    : std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_write_d, tlb_write_q    : std_ulogic_vector(0 to tlb_ways-1);
signal tlb_seq_d, tlb_seq_q    : std_ulogic_vector(0 to 5);
signal derat_taken_d, derat_taken_q   : std_ulogic;
signal ex6_illeg_instr_d, ex6_illeg_instr_q   : std_ulogic_vector(0 to 1);
signal snoop_val_d, snoop_val_q      : std_ulogic_vector(0 to 1);
signal snoop_attr_d, snoop_attr_q        : std_ulogic_vector(0 to 34);
signal snoop_vpn_d,snoop_vpn_q           : std_ulogic_vector(52-epn_width to 51);
signal tlb_resv0_valid_d,   tlb_resv0_valid_q    : std_ulogic;
signal tlb_resv0_epn_d,   tlb_resv0_epn_q        : std_ulogic_vector(52-epn_width to 51);
signal tlb_resv0_pid_d,   tlb_resv0_pid_q        : std_ulogic_vector(0 to pid_width-1);
signal tlb_resv0_lpid_d,   tlb_resv0_lpid_q      : std_ulogic_vector(0 to lpid_width-1);
signal tlb_resv0_as_d,   tlb_resv0_as_q          : std_ulogic;
signal tlb_resv0_gs_d,   tlb_resv0_gs_q          : std_ulogic;
signal tlb_resv0_ind_d,   tlb_resv0_ind_q          : std_ulogic;
signal tlb_resv0_class_d,   tlb_resv0_class_q        : std_ulogic_vector(0 to class_width-1);
signal tlb_resv1_valid_d,   tlb_resv1_valid_q    : std_ulogic;
signal tlb_resv1_epn_d,   tlb_resv1_epn_q        : std_ulogic_vector(52-epn_width to 51);
signal tlb_resv1_pid_d,   tlb_resv1_pid_q        : std_ulogic_vector(0 to pid_width-1);
signal tlb_resv1_lpid_d,   tlb_resv1_lpid_q      : std_ulogic_vector(0 to lpid_width-1);
signal tlb_resv1_as_d,   tlb_resv1_as_q          : std_ulogic;
signal tlb_resv1_gs_d,   tlb_resv1_gs_q          : std_ulogic;
signal tlb_resv1_ind_d,   tlb_resv1_ind_q          : std_ulogic;
signal tlb_resv1_class_d,   tlb_resv1_class_q        : std_ulogic_vector(0 to class_width-1);
signal tlb_resv2_valid_d,   tlb_resv2_valid_q    : std_ulogic;
signal tlb_resv2_epn_d,   tlb_resv2_epn_q        : std_ulogic_vector(52-epn_width to 51);
signal tlb_resv2_pid_d,   tlb_resv2_pid_q        : std_ulogic_vector(0 to pid_width-1);
signal tlb_resv2_lpid_d,   tlb_resv2_lpid_q      : std_ulogic_vector(0 to lpid_width-1);
signal tlb_resv2_as_d,   tlb_resv2_as_q          : std_ulogic;
signal tlb_resv2_gs_d,   tlb_resv2_gs_q          : std_ulogic;
signal tlb_resv2_ind_d,   tlb_resv2_ind_q          : std_ulogic;
signal tlb_resv2_class_d,   tlb_resv2_class_q        : std_ulogic_vector(0 to class_width-1);
signal tlb_resv3_valid_d,   tlb_resv3_valid_q    : std_ulogic;
signal tlb_resv3_epn_d,   tlb_resv3_epn_q        : std_ulogic_vector(52-epn_width to 51);
signal tlb_resv3_pid_d,   tlb_resv3_pid_q        : std_ulogic_vector(0 to pid_width-1);
signal tlb_resv3_lpid_d,   tlb_resv3_lpid_q      : std_ulogic_vector(0 to lpid_width-1);
signal tlb_resv3_as_d,   tlb_resv3_as_q          : std_ulogic;
signal tlb_resv3_gs_d,   tlb_resv3_gs_q          : std_ulogic;
signal tlb_resv3_ind_d,   tlb_resv3_ind_q          : std_ulogic;
signal tlb_resv3_class_d,   tlb_resv3_class_q        : std_ulogic_vector(0 to class_width-1);
signal ptereload_req_pte_d, ptereload_req_pte_q : std_ulogic_vector(0 to pte_width-1);
signal tlb_clr_resv_d, tlb_clr_resv_q   :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_resv_match_vec_d, tlb_resv_match_vec_q   :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_delayed_act_d, tlb_delayed_act_q       : std_ulogic_vector(0 to 32);
signal tlb_ctl_spare_q       : std_ulogic_vector(0 to 31);
-- logic signals
signal tlb_seq_next : std_ulogic_vector(0 to 5);
signal tlb_resv0_tag0_lpid_match    : std_ulogic;
signal tlb_resv0_tag0_pid_match     : std_ulogic;
signal tlb_resv0_tag0_as_snoop_match      : std_ulogic;
signal tlb_resv0_tag0_gs_snoop_match      : std_ulogic;
signal tlb_resv0_tag0_as_tlbwe_match      : std_ulogic;
signal tlb_resv0_tag0_gs_tlbwe_match      : std_ulogic;
signal tlb_resv0_tag0_ind_match     : std_ulogic;
signal tlb_resv0_tag0_epn_loc_match     : std_ulogic;
signal tlb_resv0_tag0_epn_glob_match     : std_ulogic;
signal tlb_resv0_tag0_class_match   : std_ulogic;
signal tlb_resv1_tag0_lpid_match    : std_ulogic;
signal tlb_resv1_tag0_pid_match     : std_ulogic;
signal tlb_resv1_tag0_as_snoop_match      : std_ulogic;
signal tlb_resv1_tag0_gs_snoop_match      : std_ulogic;
signal tlb_resv1_tag0_as_tlbwe_match      : std_ulogic;
signal tlb_resv1_tag0_gs_tlbwe_match      : std_ulogic;
signal tlb_resv1_tag0_ind_match     : std_ulogic;
signal tlb_resv1_tag0_epn_loc_match     : std_ulogic;
signal tlb_resv1_tag0_epn_glob_match     : std_ulogic;
signal tlb_resv1_tag0_class_match   : std_ulogic;
signal tlb_resv2_tag0_lpid_match    : std_ulogic;
signal tlb_resv2_tag0_pid_match     : std_ulogic;
signal tlb_resv2_tag0_as_snoop_match      : std_ulogic;
signal tlb_resv2_tag0_gs_snoop_match      : std_ulogic;
signal tlb_resv2_tag0_as_tlbwe_match      : std_ulogic;
signal tlb_resv2_tag0_gs_tlbwe_match      : std_ulogic;
signal tlb_resv2_tag0_ind_match     : std_ulogic;
signal tlb_resv2_tag0_epn_loc_match     : std_ulogic;
signal tlb_resv2_tag0_epn_glob_match     : std_ulogic;
signal tlb_resv2_tag0_class_match   : std_ulogic;
signal tlb_resv3_tag0_lpid_match    : std_ulogic;
signal tlb_resv3_tag0_pid_match     : std_ulogic;
signal tlb_resv3_tag0_as_snoop_match      : std_ulogic;
signal tlb_resv3_tag0_gs_snoop_match      : std_ulogic;
signal tlb_resv3_tag0_as_tlbwe_match      : std_ulogic;
signal tlb_resv3_tag0_gs_tlbwe_match      : std_ulogic;
signal tlb_resv3_tag0_ind_match     : std_ulogic;
signal tlb_resv3_tag0_epn_loc_match     : std_ulogic;
signal tlb_resv3_tag0_epn_glob_match     : std_ulogic;
signal tlb_resv3_tag0_class_match   : std_ulogic;
signal tlb_resv0_tag1_lpid_match    : std_ulogic;
signal tlb_resv0_tag1_pid_match     : std_ulogic;
signal tlb_resv0_tag1_as_snoop_match      : std_ulogic;
signal tlb_resv0_tag1_gs_snoop_match      : std_ulogic;
signal tlb_resv0_tag1_as_tlbwe_match      : std_ulogic;
signal tlb_resv0_tag1_gs_tlbwe_match      : std_ulogic;
signal tlb_resv0_tag1_ind_match     : std_ulogic;
signal tlb_resv0_tag1_epn_loc_match     : std_ulogic;
signal tlb_resv0_tag1_epn_glob_match     : std_ulogic;
signal tlb_resv0_tag1_class_match   : std_ulogic;
signal tlb_resv1_tag1_lpid_match    : std_ulogic;
signal tlb_resv1_tag1_pid_match     : std_ulogic;
signal tlb_resv1_tag1_as_snoop_match      : std_ulogic;
signal tlb_resv1_tag1_gs_snoop_match      : std_ulogic;
signal tlb_resv1_tag1_as_tlbwe_match      : std_ulogic;
signal tlb_resv1_tag1_gs_tlbwe_match      : std_ulogic;
signal tlb_resv1_tag1_ind_match     : std_ulogic;
signal tlb_resv1_tag1_epn_loc_match     : std_ulogic;
signal tlb_resv1_tag1_epn_glob_match     : std_ulogic;
signal tlb_resv1_tag1_class_match   : std_ulogic;
signal tlb_resv2_tag1_lpid_match    : std_ulogic;
signal tlb_resv2_tag1_pid_match     : std_ulogic;
signal tlb_resv2_tag1_as_snoop_match      : std_ulogic;
signal tlb_resv2_tag1_gs_snoop_match      : std_ulogic;
signal tlb_resv2_tag1_as_tlbwe_match      : std_ulogic;
signal tlb_resv2_tag1_gs_tlbwe_match      : std_ulogic;
signal tlb_resv2_tag1_ind_match     : std_ulogic;
signal tlb_resv2_tag1_epn_loc_match     : std_ulogic;
signal tlb_resv2_tag1_epn_glob_match     : std_ulogic;
signal tlb_resv2_tag1_class_match   : std_ulogic;
signal tlb_resv3_tag1_lpid_match    : std_ulogic;
signal tlb_resv3_tag1_pid_match     : std_ulogic;
signal tlb_resv3_tag1_as_snoop_match      : std_ulogic;
signal tlb_resv3_tag1_gs_snoop_match      : std_ulogic;
signal tlb_resv3_tag1_as_tlbwe_match      : std_ulogic;
signal tlb_resv3_tag1_gs_tlbwe_match      : std_ulogic;
signal tlb_resv3_tag1_ind_match     : std_ulogic;
signal tlb_resv3_tag1_epn_loc_match     : std_ulogic;
signal tlb_resv3_tag1_epn_glob_match     : std_ulogic;
signal tlb_resv3_tag1_class_match   : std_ulogic;
signal tlb_resv_valid_vec : std_ulogic_vector(0 to thdid_width-1);
signal tlb_seq_set_resv      : std_ulogic;
signal tlb_seq_snoop_resv    : std_ulogic;
signal tlb_seq_snoop_resv_q    : std_ulogic_vector(0 to thdid_width-1);
signal tlb_hashed_addr1      :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_hashed_addr2      :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_hashed_addr3      :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_hashed_addr4      :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_hashed_addr5      :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_hashed_tid0_addr1      :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_hashed_tid0_addr2      :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_hashed_tid0_addr3      :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_hashed_tid0_addr4      :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_hashed_tid0_addr5      :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_tag0_hashed_addr       :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_tag0_hashed_tid0_addr  :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_tag0_tid_notzero       :  std_ulogic;
signal size_4K_hashed_addr   :  std_ulogic_vector(0 to tlb_addr_width-1);
signal size_64K_hashed_addr  :  std_ulogic_vector(0 to tlb_addr_width-1);
signal size_1M_hashed_addr   :  std_ulogic_vector(0 to tlb_addr_width-1);
signal size_16M_hashed_addr  :  std_ulogic_vector(0 to tlb_addr_width-1);
signal size_1G_hashed_addr   :  std_ulogic_vector(0 to tlb_addr_width-1);
signal size_4K_hashed_tid0_addr   :  std_ulogic_vector(0 to tlb_addr_width-1);
signal size_64K_hashed_tid0_addr  :  std_ulogic_vector(0 to tlb_addr_width-1);
signal size_1M_hashed_tid0_addr   :  std_ulogic_vector(0 to tlb_addr_width-1);
signal size_16M_hashed_tid0_addr  :  std_ulogic_vector(0 to tlb_addr_width-1);
signal size_1G_hashed_tid0_addr   :  std_ulogic_vector(0 to tlb_addr_width-1);
-- reserved for HTW
signal size_256M_hashed_addr  :  std_ulogic_vector(0 to tlb_addr_width-1);
signal size_256M_hashed_tid0_addr  :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_seq_pgsize          :  std_ulogic_vector(0 to 3);
signal tlb_seq_addr            :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_seq_esel            :  std_ulogic_vector(0 to 2);
signal tlb_seq_is              :  std_ulogic_vector(0 to 1);
signal tlb_addr_p1             :  std_ulogic_vector(0 to tlb_addr_width-1);
signal tlb_addr_maxcntm1        : std_ulogic;
signal tlb_seq_addr_incr        : std_ulogic;
signal tlb_seq_addr_clr         : std_ulogic;
signal tlb_seq_tag0_addr_cap      :  std_ulogic;
signal tlb_seq_addr_update   :  std_ulogic;
signal tlb_seq_lrat_enable   :  std_ulogic;
signal tlb_seq_idle_sig          :  std_ulogic;
signal tlb_seq_ind           :  std_ulogic;
signal tlb_seq_ierat_done_sig     : std_ulogic;
signal tlb_seq_derat_done_sig     : std_ulogic;
signal tlb_seq_snoop_done_sig     : std_ulogic;
signal tlb_seq_search_done_sig    : std_ulogic;
signal tlb_seq_searchresv_done_sig   : std_ulogic;
signal tlb_seq_read_done_sig         : std_ulogic;
signal tlb_seq_write_done_sig        : std_ulogic;
signal tlb_seq_ptereload_done_sig    : std_ulogic;
signal tlb_seq_any_done_sig     : std_ulogic;
signal tlb_seq_endflag            : std_ulogic;
signal tlb_search_req             : std_ulogic;
signal tlb_searchresv_req         : std_ulogic;
signal tlb_read_req               : std_ulogic;
signal tlb_write_req              : std_ulogic;
signal tlb_set_resv0                 :  std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
signal tlb_set_resv1                 :  std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
signal tlb_set_resv2                 :  std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
signal tlb_set_resv3                 :  std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
signal any_tlb_req_sig            : std_ulogic;
signal any_req_taken_sig          : std_ulogic;
signal ierat_req_taken_sig        : std_ulogic;
signal derat_req_taken_sig        : std_ulogic;
signal snoop_req_taken_sig        : std_ulogic;
signal search_req_taken_sig       : std_ulogic;
signal searchresv_req_taken_sig   : std_ulogic;
signal read_req_taken_sig         : std_ulogic;
signal write_req_taken_sig        : std_ulogic;
signal ptereload_req_taken_sig    : std_ulogic;
signal ex3_valid_32b  : std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
signal ex1_mas0_atsel :  std_ulogic;
signal ex1_mas0_esel :  std_ulogic_vector(0 to 2);
signal ex1_mas0_hes :  std_ulogic;
signal ex1_mas0_wq :  std_ulogic_vector(0 to 1);
signal ex1_mas1_v :  std_ulogic;
signal ex1_mas1_iprot :  std_ulogic;
signal ex1_mas1_ind :  std_ulogic;
signal ex1_mas1_tid :  std_ulogic_vector(0 to pid_width-1);
signal ex1_mas1_ts :  std_ulogic;
signal ex1_mas1_tsize :  std_ulogic_vector(0 to 3);
signal ex1_mas2_epn :  std_ulogic_vector(52-epn_width to 51);
signal ex1_mas8_tgs :  std_ulogic;
signal ex1_mas8_tlpid :  std_ulogic_vector(0 to lpid_width-1);
signal ex1_mmucr3_class :  std_ulogic_vector(0 to class_width-1);
signal ex2_mas0_atsel :  std_ulogic;
signal ex2_mas0_esel :  std_ulogic_vector(0 to 2);
signal ex2_mas0_hes :  std_ulogic;
signal ex2_mas0_wq :  std_ulogic_vector(0 to 1);
signal ex2_mas1_ind :  std_ulogic;
signal ex2_mas1_tid :  std_ulogic_vector(0 to pid_width-1);
signal ex2_mas5_slpid :  std_ulogic_vector(0 to lpid_width-1);
signal ex2_mas5_1_state :  std_ulogic_vector(0 to state_width-1);
signal ex2_mas5_6_state :  std_ulogic_vector(0 to state_width-1);
signal ex2_mas6_sind :  std_ulogic;
signal ex2_mas6_spid :  std_ulogic_vector(0 to pid_width-1);
signal ex2_hv_state    : std_ulogic;
signal ex6_hv_state    : std_ulogic;
signal ex6_priv_state  : std_ulogic;
signal ex6_dgtmi_state  : std_ulogic;
signal tlb_ctl_tag1_flush_sig :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_tag2_flush_sig :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_tag3_flush_sig :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_tag4_flush_sig :  std_ulogic_vector(0 to thdid_width-1);
signal tlb_ctl_any_tag_flush_sig :  std_ulogic;
signal tlb_seq_abort :  std_ulogic;
signal tlb_tag4_hit_or_parerr :  std_ulogic;
signal tlb_ctl_quiesce_b   : std_ulogic_vector(0 to thdid_width-1);
signal ex2_flush_req_local :  std_ulogic_vector(0 to thdid_width-1);
signal tlbwe_back_inv_holdoff :  std_ulogic;
signal pgsize1_valid : std_ulogic;
signal pgsize2_valid : std_ulogic;
signal pgsize3_valid : std_ulogic;
signal pgsize4_valid : std_ulogic;
signal pgsize5_valid : std_ulogic;
signal pgsize1_tid0_valid : std_ulogic;
signal pgsize2_tid0_valid : std_ulogic;
signal pgsize3_tid0_valid : std_ulogic;
signal pgsize4_tid0_valid : std_ulogic;
signal pgsize5_tid0_valid : std_ulogic;
signal pgsize_qty :  std_ulogic_vector(0 to 2);
signal pgsize_tid0_qty :  std_ulogic_vector(0 to 2);
signal tlb_tag1_pgsize_eq_16mb  :  std_ulogic;
signal tlb_tag1_pgsize_gte_1mb   :  std_ulogic;
signal tlb_tag1_pgsize_gte_64kb  :  std_ulogic;
-- mas settings errors
signal mas1_tsize_direct           : std_ulogic_vector(0 to thdid_width-1);
signal mas1_tsize_indirect         : std_ulogic_vector(0 to thdid_width-1);
signal mas1_tsize_lrat             : std_ulogic_vector(0 to thdid_width-1);
signal mas3_spsize_indirect        : std_ulogic_vector(0 to thdid_width-1);
signal ex2_tlbre_mas1_tsize_not_supp         : std_ulogic_vector(0 to thdid_width-1);
signal ex5_tlbre_mas1_tsize_not_supp         : std_ulogic_vector(0 to thdid_width-1);
signal ex5_tlbwe_mas1_tsize_not_supp         : std_ulogic_vector(0 to thdid_width-1);
signal ex6_tlbwe_mas1_tsize_not_supp         : std_ulogic_vector(0 to thdid_width-1);
signal ex5_tlbwe_mas0_lrat_bad_selects       : std_ulogic_vector(0 to thdid_width-1);
signal ex6_tlbwe_mas0_lrat_bad_selects       : std_ulogic_vector(0 to thdid_width-1);
signal ex5_tlbwe_mas2_ind_bad_wimge          : std_ulogic_vector(0 to thdid_width-1);
signal ex6_tlbwe_mas2_ind_bad_wimge          : std_ulogic_vector(0 to thdid_width-1);
signal ex5_tlbwe_mas3_ind_bad_spsize        : std_ulogic_vector(0 to thdid_width-1);
signal ex6_tlbwe_mas3_ind_bad_spsize        : std_ulogic_vector(0 to thdid_width-1);
-- synopsys translate_off
-- synopsys translate_on
-- power clock gating signals
signal tlb_early_act  : std_ulogic;
signal tlb_tag0_act    : std_ulogic;
signal tlb_snoop_act   : std_ulogic;
signal unused_dc  :  std_ulogic_vector(0 to 35);
-- synopsys translate_off
-- synopsys translate_on
-- Pervasive
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
signal pc_func_slp_nsl_thold_0_b : std_ulogic;
signal pc_func_slp_nsl_force     : std_ulogic;
signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);
signal tidn                     : std_ulogic;
signal tiup                     : std_ulogic;
  BEGIN --@@ START OF EXECUTABLE CODE FOR MMQ_TLB_CTL

-----------------------------------------------------------------------
-- Logic
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Glorp1 - common stuff for erat-only and tlb
-----------------------------------------------------------------------
tidn  <=  '0';
tiup  <=  '1';
-- not quiesced
tlb_ctl_quiesce_b(0 TO thdid_width-1) <= 
 ( (0 to thdid_width-1 => or_reduce(tlb_seq_q)) and tlb_tag0_q(tagpos_thdid to tagpos_thdid+thdid_width-1) );
tlb_ctl_quiesce  <=  not tlb_ctl_quiesce_b;
xu_ex1_flush_d  <=  xu_rf1_flush;
ex1_valid_d  <=  xu_mm_rf1_val and not(xu_rf1_flush);
ex1_ttype_d  <=  xu_mm_rf1_is_tlbre & xu_mm_rf1_is_tlbwe & xu_mm_rf1_is_tlbsx & xu_mm_rf1_is_tlbsxr & xu_mm_rf1_is_tlbsrx;
ex1_state_d(0) <=  or_reduce(xu_mm_msr_pr and xu_mm_rf1_val);
ex1_state_d(1) <=  or_reduce(xu_mm_msr_gs and xu_mm_rf1_val);
ex1_state_d(2) <=  or_reduce(xu_mm_msr_ds and xu_mm_rf1_val);
ex1_state_d(3) <=  or_reduce(xu_mm_msr_cm and xu_mm_rf1_val);
ex1_state_d(4) <=  or_reduce(xu_mm_msr_is and xu_mm_rf1_val);
ex1_pid_d  <=  (pid0 and (0 to pid_width-1 => xu_mm_rf1_val(0)))
          or (pid1 and (0 to pid_width-1 => xu_mm_rf1_val(1)))
          or (pid2 and (0 to pid_width-1 => xu_mm_rf1_val(2)))
          or (pid3 and (0 to pid_width-1 => xu_mm_rf1_val(3)));
ex1_mas0_atsel  <=  (mas0_0_atsel and ex1_valid_q(0)) 
               or (mas0_1_atsel and ex1_valid_q(1)) 
               or (mas0_2_atsel and ex1_valid_q(2))
               or (mas0_3_atsel and ex1_valid_q(3));
ex1_mas0_esel  <=  (mas0_0_esel and (0 to 2 => ex1_valid_q(0))) 
              or (mas0_1_esel and (0 to 2 => ex1_valid_q(1))) 
              or (mas0_2_esel and (0 to 2 => ex1_valid_q(2)))
              or (mas0_3_esel and (0 to 2 => ex1_valid_q(3)));
ex1_mas0_hes  <=   (mas0_0_hes and ex1_valid_q(0)) 
              or (mas0_1_hes and ex1_valid_q(1)) 
              or (mas0_2_hes and ex1_valid_q(2))
              or (mas0_3_hes and ex1_valid_q(3));
ex1_mas0_wq  <=  (mas0_0_wq and (0 to 1 => ex1_valid_q(0))) 
            or (mas0_1_wq and (0 to 1 => ex1_valid_q(1))) 
            or (mas0_2_wq and (0 to 1 => ex1_valid_q(2)))
            or (mas0_3_wq and (0 to 1 => ex1_valid_q(3)));
ex1_mas1_tid  <=  (mas1_0_tid and (0 to pid_width-1 => ex1_valid_q(0))) 
             or (mas1_1_tid and (0 to pid_width-1 => ex1_valid_q(1))) 
             or (mas1_2_tid and (0 to pid_width-1 => ex1_valid_q(2)))
             or (mas1_3_tid and (0 to pid_width-1 => ex1_valid_q(3)));
ex1_mas1_ts  <=     (mas1_0_ts and ex1_valid_q(0)) 
               or (mas1_1_ts and ex1_valid_q(1)) 
               or (mas1_2_ts and ex1_valid_q(2))
               or (mas1_3_ts and ex1_valid_q(3));
ex1_mas1_tsize  <=  (mas1_0_tsize and (0 to 3 => ex1_valid_q(0))) 
               or (mas1_1_tsize and (0 to 3 => ex1_valid_q(1))) 
               or (mas1_2_tsize and (0 to 3 => ex1_valid_q(2)))
               or (mas1_3_tsize and (0 to 3 => ex1_valid_q(3)));
ex1_mas1_ind  <=  (mas1_0_ind and ex1_valid_q(0))
             or (mas1_1_ind and ex1_valid_q(1)) 
             or (mas1_2_ind and ex1_valid_q(2))
             or (mas1_3_ind and ex1_valid_q(3));
ex1_mas1_v  <=  (mas1_0_v and ex1_valid_q(0))
           or (mas1_1_v and ex1_valid_q(1)) 
           or (mas1_2_v and ex1_valid_q(2))
           or (mas1_3_v and ex1_valid_q(3));
ex1_mas1_iprot  <=  (mas1_0_iprot and ex1_valid_q(0))
               or (mas1_1_iprot and ex1_valid_q(1)) 
               or (mas1_2_iprot and ex1_valid_q(2))
               or (mas1_3_iprot and ex1_valid_q(3));
ex1_mas2_epn  <=  (mas2_0_epn(52-epn_width to 51) and (52-epn_width to 51 => ex1_valid_q(0)))
             or (mas2_1_epn(52-epn_width to 51) and (52-epn_width to 51 => ex1_valid_q(1)))
             or (mas2_2_epn(52-epn_width to 51) and (52-epn_width to 51 => ex1_valid_q(2)))
             or (mas2_3_epn(52-epn_width to 51) and (52-epn_width to 51 => ex1_valid_q(3)));
ex1_mas8_tgs  <=    (mas8_0_tgs and ex1_valid_q(0)) 
               or (mas8_1_tgs and ex1_valid_q(1)) 
               or (mas8_2_tgs and ex1_valid_q(2))
               or (mas8_3_tgs and ex1_valid_q(3));
ex1_mas8_tlpid  <=  (mas8_0_tlpid and (0 to lpid_width-1 => ex1_valid_q(0)))
               or (mas8_1_tlpid and (0 to lpid_width-1 => ex1_valid_q(1))) 
               or (mas8_2_tlpid and (0 to lpid_width-1 => ex1_valid_q(2)))
               or (mas8_3_tlpid and (0 to lpid_width-1 => ex1_valid_q(3)));
-- state: 0:pr 1:gs 2:as 3:cm
ex1_mmucr3_class  <=  (mmucr3_0(54 to 55) and (54 to 55 => ex1_valid_q(0)))
                 or (mmucr3_1(54 to 55) and (54 to 55 => ex1_valid_q(1))) 
                 or (mmucr3_2(54 to 55) and (54 to 55 => ex1_valid_q(2)))
                 or (mmucr3_3(54 to 55) and (54 to 55 => ex1_valid_q(3)));
ex2_mas0_atsel  <=  (mas0_0_atsel and ex2_valid_q(0)) 
              or (mas0_1_atsel and ex2_valid_q(1)) 
              or (mas0_2_atsel and ex2_valid_q(2))
              or (mas0_3_atsel and ex2_valid_q(3));
ex2_mas0_esel  <=  (mas0_0_esel and (0 to 2 => ex2_valid_q(0))) 
              or (mas0_1_esel and (0 to 2 => ex2_valid_q(1))) 
              or (mas0_2_esel and (0 to 2 => ex2_valid_q(2)))
              or (mas0_3_esel and (0 to 2 => ex2_valid_q(3)));
ex2_mas0_hes  <=   (mas0_0_hes and ex2_valid_q(0)) 
              or (mas0_1_hes and ex2_valid_q(1)) 
              or (mas0_2_hes and ex2_valid_q(2))
              or (mas0_3_hes and ex2_valid_q(3));
ex2_mas0_wq  <=  (mas0_0_wq and (0 to 1 => ex2_valid_q(0))) 
            or (mas0_1_wq and (0 to 1 => ex2_valid_q(1))) 
            or (mas0_2_wq and (0 to 1 => ex2_valid_q(2)))
            or (mas0_3_wq and (0 to 1 => ex2_valid_q(3)));
ex2_mas1_ind  <=  (mas1_0_ind and ex2_valid_q(0)) 
             or (mas1_1_ind and ex2_valid_q(1)) 
             or (mas1_2_ind and ex2_valid_q(2))
             or (mas1_3_ind and ex2_valid_q(3));
ex2_mas1_tid  <=  (mas1_0_tid and (0 to pid_width-1 => ex2_valid_q(0))) 
             or (mas1_1_tid and (0 to pid_width-1 => ex2_valid_q(1))) 
             or (mas1_2_tid and (0 to pid_width-1 => ex2_valid_q(2)))
             or (mas1_3_tid and (0 to pid_width-1 => ex2_valid_q(3)));
ex2_mas5_1_state  <=  ((ex2_state_q(0) & mas5_0_sgs & mas1_0_ts & ex2_state_q(3)) and (0 to 3 => ex2_valid_q(0))) 
                 or ((ex2_state_q(0) & mas5_1_sgs & mas1_1_ts & ex2_state_q(3)) and (0 to 3 => ex2_valid_q(1))) 
                 or ((ex2_state_q(0) & mas5_2_sgs & mas1_2_ts & ex2_state_q(3)) and (0 to 3 => ex2_valid_q(2)))
                 or ((ex2_state_q(0) & mas5_3_sgs & mas1_3_ts & ex2_state_q(3)) and (0 to 3 => ex2_valid_q(3)));
ex2_mas5_6_state  <=  ((ex2_state_q(0) & mas5_0_sgs & mas6_0_sas & ex2_state_q(3)) and (0 to 3 => ex2_valid_q(0)))
                 or ((ex2_state_q(0) & mas5_1_sgs & mas6_1_sas & ex2_state_q(3)) and (0 to 3 => ex2_valid_q(1))) 
                 or ((ex2_state_q(0) & mas5_2_sgs & mas6_2_sas & ex2_state_q(3)) and (0 to 3 => ex2_valid_q(2)))
                 or ((ex2_state_q(0) & mas5_3_sgs & mas6_3_sas & ex2_state_q(3)) and (0 to 3 => ex2_valid_q(3)));
ex2_mas5_slpid  <=  (mas5_0_slpid and (0 to lpid_width-1 => ex2_valid_q(0)))
               or (mas5_1_slpid and (0 to lpid_width-1 => ex2_valid_q(1))) 
               or (mas5_2_slpid and (0 to lpid_width-1 => ex2_valid_q(2)))
               or (mas5_3_slpid and (0 to lpid_width-1 => ex2_valid_q(3)));
ex2_mas6_spid  <=   (mas6_0_spid and (0 to pid_width-1 => ex2_valid_q(0)))
               or (mas6_1_spid and (0 to pid_width-1 => ex2_valid_q(1))) 
               or (mas6_2_spid and (0 to pid_width-1 => ex2_valid_q(2)))
               or (mas6_3_spid and (0 to pid_width-1 => ex2_valid_q(3)));
ex2_mas6_sind  <=    (mas6_0_sind and ex2_valid_q(0))
                or (mas6_1_sind and ex2_valid_q(1)) 
                or (mas6_2_sind and ex2_valid_q(2))
                or (mas6_3_sind and ex2_valid_q(3));
ex2_valid_d  <=  ex1_valid_q and not(xu_ex1_flush);
ex2_flush_d  <=  (ex1_valid_q and xu_ex1_flush) when ex1_ttype_q/="00000" else "0000";
ex2_flush_req_d  <=  (ex1_valid_q and not(xu_ex1_flush)) when (ex1_ttype_q(0 to 1)/="00" 
                          and read_req_taken_sig='0' and write_req_taken_sig='0')  
             else "0000";
ex2_ttype_d  <=  ex1_ttype_q;
ex2_state_d  <=  ex1_state_q;
ex2_pid_d  <=  ex1_pid_q;
ex2_flush_req_local  <=  ex2_valid_q when (ex2_ttype_q(2 to 4)/="000" and search_req_taken_sig='0' and searchresv_req_taken_sig='0')
                else "0000";
-- state: 0:pr 1:gs 2:as 3:cm
ex2_hv_state    <=  not ex2_state_q(0) and not ex2_state_q(1);
ex6_hv_state    <=  not ex6_state_q(0) and not ex6_state_q(1);
ex6_priv_state  <=  not ex6_state_q(0);
ex6_dgtmi_state  <=  or_reduce(ex6_valid_q and xu_mm_epcr_dgtmi);
ex3_valid_d  <=  ex2_valid_q and not(xu_ex2_flush) and not(ex2_flush_req_q) and not(ex2_flush_req_local);
ex3_flush_d  <=  ((ex2_valid_q and xu_ex2_flush) or ex2_flush_q or ex2_flush_req_q or ex2_flush_req_local) when ex2_ttype_q/="00000" else "0000";
ex3_ttype_d  <=  ex2_ttype_q;
ex3_state_d  <=  ex2_state_q;
ex3_pid_d  <=  ex2_pid_q;
tlb_ctl_ex3_valid        <=  ex3_valid_q;
tlb_ctl_ex3_ttype        <=  ex3_ttype_q;
ex4_valid_d  <=  ex3_valid_q and not(xu_ex3_flush);
ex4_flush_d  <=  ((ex3_valid_q and xu_ex3_flush) or ex3_flush_q) when ex3_ttype_q/="00000" else "0000";
ex4_ttype_d  <=  ex3_ttype_q;
-- state: 0:pr 1:gs 2:as 3:cm
ex4_state_d  <=  ex3_state_q;
ex4_pid_d  <=   ex3_pid_q;
ex5_valid_d  <=  ex4_valid_q and not(xu_ex4_flush);
ex5_flush_d  <=  ((ex4_valid_q and xu_ex4_flush) or ex4_flush_q) when ex4_ttype_q/="00000" else "0000";
ex5_ttype_d  <=  ex4_ttype_q;
ex5_state_d  <=  ex4_state_q;
ex5_pid_d  <=  ex4_pid_q;
-- ex6 phase are holding latches for non-flushed tlbre,we,sx until tlb_seq is done
ex6_valid_d  <=  (others => '0') when (tlb_seq_read_done_sig='1' or tlb_seq_write_done_sig='1' or
                                          tlb_seq_search_done_sig='1' or tlb_seq_searchresv_done_sig='1') 
          else (ex5_valid_q and not(xu_ex5_flush)) when (ex6_valid_q="0000" and ex5_ttype_q/="00000")
          else ex6_valid_q;
ex6_flush_d  <=  ((ex5_valid_q and xu_ex5_flush) or ex5_flush_q) when ex5_ttype_q/="00000" else "0000";
ex6_ttype_d  <=  ex5_ttype_q when ex6_valid_q="0000"
          else ex6_ttype_q;
ex6_state_d  <=  ex5_state_q when ex6_valid_q="0000"
          else ex6_state_q;
ex6_pid_d  <=  ex5_pid_q when ex6_valid_q="0000"
          else ex6_pid_q;
tlb_ctl_barrier_done  <=  ex6_valid_q when (tlb_seq_search_done_sig='1' or tlb_seq_searchresv_done_sig='1' or 
                                            tlb_seq_read_done_sig='1' or tlb_seq_write_done_sig='1' )   
             else (others => '0');
-- TLB Reservations
-- ttype <= tlbre & tlbwe & tlbsx & tlbsxr & tlbsrx;
-- mas0.wq: 00=ignore reserv, 01=write if reserved, 10=clear reserv, 11=not used
--  reservation set:
--        (1) proc completion of tlbsrx. when no reservation exists
--        (2) proc holding resv executes another tlbsrx. thus establishing new resv
tlb_set_resv0    <=  '1' when (ex6_valid_q(0)='1'    and ex6_ttype_q(4)='1' and tlb_seq_set_resv='1')
              else '0';
tlb_set_resv1    <=  '1' when (ex6_valid_q(1)='1'    and ex6_ttype_q(4)='1' and tlb_seq_set_resv='1')
              else '0';
tlb_set_resv2    <=  '1' when (ex6_valid_q(2)='1'    and ex6_ttype_q(4)='1' and tlb_seq_set_resv='1')
              else '0';
tlb_set_resv3    <=  '1' when (ex6_valid_q(3)='1'    and ex6_ttype_q(4)='1' and tlb_seq_set_resv='1')
              else '0';
--  reservation clear:
--        (1) proc holding resv executes another tlbsrx. overwriting the old resv
--        (2) any tlbivax snoop with gs,as,lpid,pid,sizemasked(epn,mas6.isize) matching resv.gs,as,lpid,pid,sizemasked(epn,mas6.isize)
--             (note ind bit is not part of tlbivax criteria!!)
--        (3) any proc sets mmucsr0.TLB0_FI=1 with lpidr matching resv.lpid
--        (4) any proc executes tlbilx T=0 (all) with mas5.slpid matching resv.lpid
--        (5) any proc executes tlbilx T=1 (pid) with mas5.slpid and mas6.spid matching resv.lpid,pid
--        (6) any proc executes tlbilx T=3 (vpn) with mas gs,as,slpid,spid,sizemasked(epn,mas6.isize) matching
--              resv.gs,as,lpid,pid,sizemasked(epn,mas6.isize)
--              (note ind bit is not part of tlbilx criteria!!)
--        (7a) any proc executes tlbwe not causing exception and with (wq=00 always, or wq=01 and proc holds resv)
--              and mas regs ind,tgs,ts,tlpid,tid,sizemasked(epn,mas1.tsize) match resv.ind,gs,as,lpid,pid,sizemasked(epn,mas1.tsize)
--        (7b) this proc executes tlbwe not causing exception and with (wq=10 clear my resv regardless of va)
--        (8) any page table reload not causing an exception (due to pt fault, tlb inelig, or lrat miss)
--              and PTE's tag ind=0,tgs,ts,tlpid,tid,sizemasked(epn,pte.size) match resv.ind=0,gs,as,lpid,pid,sizemasked(epn.pte.size)
--       A2-specific non-architected clear states
--        (9) any proc executes tlbwe not causing exception and with (wq=10 clear, or wq=11 always (same as 00))
--              and mas regs ind,tgs,ts,tlpid,tid,sizemasked(epn,mas1.tsize) match resv.ind,gs,as,lpid,pid,sizemasked(epn,mas1.tsize)
--               (basically same as 7)
--        (10) any proc executes tlbilx T=2 (gs) with mas5.sgs matching resv.gs
--        (11) any proc executes tlbilx T=4 to 7 (class) with T(1:2) matching resv.class
--  ttype <= tlbre & tlbwe & tlbsx & tlbsxr & tlbsrx;
--  IS0: Local bit
--  IS1/Class: 0=all, 1=tid, 2=gs, 3=vpn, 4=class0, 5=class1, 6=class2, 7=class3
--  mas0.wq: 00=ignore reserv write always, 01=write if reserved, 10=clear reserv, 11=same as 00
tlb_clr_resv_d(0) <=  
                    (tlb_seq_snoop_resv_q(0)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"0011") and tlb_resv0_tag1_lpid_match   and 
                                tlb_resv0_tag1_pid_match   and tlb_resv0_tag1_gs_snoop_match   and 
                                tlb_resv0_tag1_as_snoop_match   and tlb_resv0_tag1_epn_glob_match)   
                or (tlb_seq_snoop_resv_q(0)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1000") and tlb_resv0_tag1_lpid_match)
                or (tlb_seq_snoop_resv_q(0)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1001") and 
                                tlb_resv0_tag1_lpid_match   and tlb_resv0_tag1_pid_match)
                or (tlb_seq_snoop_resv_q(0)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1011") and tlb_resv0_tag1_lpid_match   and 
                                tlb_resv0_tag1_pid_match   and tlb_resv0_tag1_gs_snoop_match   and 
                                tlb_resv0_tag1_as_snoop_match   and tlb_resv0_tag1_epn_loc_match)
                or  ( ((or_reduce(ex6_valid_q and tlb_resv_valid_vec) and Eq(tlb_tag4_wq,"01")) or 
                                   (or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"00")))   and ex6_ttype_q(1) and 
                                     tlb_resv0_tag1_gs_tlbwe_match   and tlb_resv0_tag1_as_tlbwe_match   and 
                                      tlb_resv0_tag1_lpid_match   and tlb_resv0_tag1_pid_match   and 
                                       tlb_resv0_tag1_epn_loc_match   and tlb_resv0_tag1_ind_match   ) 
                or  ( ex6_valid_q(0)   and Eq(tlb_tag4_wq,"10")  and ex6_ttype_q(1) ) 
                or  ( tlb_tag4_ptereload and 
                                     tlb_resv0_tag1_gs_snoop_match   and tlb_resv0_tag1_as_snoop_match   and 
                                      tlb_resv0_tag1_lpid_match   and tlb_resv0_tag1_pid_match   and 
                                       tlb_resv0_tag1_epn_loc_match   and tlb_resv0_tag1_ind_match   ) 
                or  ( ((or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"10")) or 
                                   (or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"11")))   and ex6_ttype_q(1) and 
                                     tlb_resv0_tag1_gs_tlbwe_match   and tlb_resv0_tag1_as_tlbwe_match   and 
                                      tlb_resv0_tag1_lpid_match   and tlb_resv0_tag1_pid_match   and 
                                       tlb_resv0_tag1_epn_loc_match   and tlb_resv0_tag1_ind_match   ) 
                or (tlb_seq_snoop_resv_q(0)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+1),"11") and 
                                tlb_resv0_tag1_class_match);
tlb_clr_resv_d(1) <=  
                    (tlb_seq_snoop_resv_q(1)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"0011") and tlb_resv1_tag1_lpid_match   and 
                                tlb_resv1_tag1_pid_match   and tlb_resv1_tag1_gs_snoop_match   and 
                                tlb_resv1_tag1_as_snoop_match   and tlb_resv1_tag1_epn_glob_match)   
                or (tlb_seq_snoop_resv_q(1)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1000") and tlb_resv1_tag1_lpid_match)
                or (tlb_seq_snoop_resv_q(1)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1001") and 
                                tlb_resv1_tag1_lpid_match   and tlb_resv1_tag1_pid_match)
                or (tlb_seq_snoop_resv_q(1)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1011") and tlb_resv1_tag1_lpid_match   and 
                                tlb_resv1_tag1_pid_match   and tlb_resv1_tag1_gs_snoop_match   and 
                                tlb_resv1_tag1_as_snoop_match   and tlb_resv1_tag1_epn_loc_match)
                or  ( ((or_reduce(ex6_valid_q and tlb_resv_valid_vec) and Eq(tlb_tag4_wq,"01")) or 
                                   (or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"00")))   and ex6_ttype_q(1) and 
                                     tlb_resv1_tag1_gs_tlbwe_match   and tlb_resv1_tag1_as_tlbwe_match   and 
                                      tlb_resv1_tag1_lpid_match   and tlb_resv1_tag1_pid_match   and 
                                       tlb_resv1_tag1_epn_loc_match   and tlb_resv1_tag1_ind_match   ) 
                or  ( ex6_valid_q(1)   and Eq(tlb_tag4_wq,"10")  and ex6_ttype_q(1) ) 
                or  ( tlb_tag4_ptereload and 
                                     tlb_resv1_tag1_gs_snoop_match   and tlb_resv1_tag1_as_snoop_match   and 
                                      tlb_resv1_tag1_lpid_match   and tlb_resv1_tag1_pid_match   and 
                                       tlb_resv1_tag1_epn_loc_match   and tlb_resv1_tag1_ind_match   ) 
                or  ( ((or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"10")) or 
                                   (or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"11")))   and ex6_ttype_q(1) and 
                                     tlb_resv1_tag1_gs_tlbwe_match   and tlb_resv1_tag1_as_tlbwe_match   and 
                                      tlb_resv1_tag1_lpid_match   and tlb_resv1_tag1_pid_match   and 
                                       tlb_resv1_tag1_epn_loc_match   and tlb_resv1_tag1_ind_match   ) 
                or (tlb_seq_snoop_resv_q(1)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+1),"11") and 
                                tlb_resv1_tag1_class_match);
tlb_clr_resv_d(2) <=  
                    (tlb_seq_snoop_resv_q(2)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"0011") and tlb_resv2_tag1_lpid_match   and 
                                tlb_resv2_tag1_pid_match   and tlb_resv2_tag1_gs_snoop_match   and 
                                tlb_resv2_tag1_as_snoop_match   and tlb_resv2_tag1_epn_glob_match)   
                or (tlb_seq_snoop_resv_q(2)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1000") and tlb_resv2_tag1_lpid_match)
                or (tlb_seq_snoop_resv_q(2)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1001") and 
                                tlb_resv2_tag1_lpid_match   and tlb_resv2_tag1_pid_match)
                or (tlb_seq_snoop_resv_q(2)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1011") and tlb_resv2_tag1_lpid_match   and 
                                tlb_resv2_tag1_pid_match   and tlb_resv2_tag1_gs_snoop_match   and 
                                tlb_resv2_tag1_as_snoop_match   and tlb_resv2_tag1_epn_loc_match)
                or  ( ((or_reduce(ex6_valid_q and tlb_resv_valid_vec) and Eq(tlb_tag4_wq,"01")) or 
                                   (or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"00")))   and ex6_ttype_q(1) and 
                                     tlb_resv2_tag1_gs_tlbwe_match   and tlb_resv2_tag1_as_tlbwe_match   and 
                                      tlb_resv2_tag1_lpid_match   and tlb_resv2_tag1_pid_match   and 
                                       tlb_resv2_tag1_epn_loc_match   and tlb_resv2_tag1_ind_match   ) 
                or  ( ex6_valid_q(2)   and Eq(tlb_tag4_wq,"10")  and ex6_ttype_q(1) ) 
                or  ( tlb_tag4_ptereload and 
                                     tlb_resv2_tag1_gs_snoop_match   and tlb_resv2_tag1_as_snoop_match   and 
                                      tlb_resv2_tag1_lpid_match   and tlb_resv2_tag1_pid_match   and 
                                       tlb_resv2_tag1_epn_loc_match   and tlb_resv2_tag1_ind_match   ) 
                or  ( ((or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"10")) or 
                                   (or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"11")))   and ex6_ttype_q(1) and 
                                     tlb_resv2_tag1_gs_tlbwe_match   and tlb_resv2_tag1_as_tlbwe_match   and 
                                      tlb_resv2_tag1_lpid_match   and tlb_resv2_tag1_pid_match   and 
                                       tlb_resv2_tag1_epn_loc_match   and tlb_resv2_tag1_ind_match   ) 
                or (tlb_seq_snoop_resv_q(2)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+1),"11") and 
                                tlb_resv2_tag1_class_match);
tlb_clr_resv_d(3) <=  
                    (tlb_seq_snoop_resv_q(3)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"0011") and tlb_resv3_tag1_lpid_match   and 
                                tlb_resv3_tag1_pid_match   and tlb_resv3_tag1_gs_snoop_match   and 
                                tlb_resv3_tag1_as_snoop_match   and tlb_resv3_tag1_epn_glob_match)   
                or (tlb_seq_snoop_resv_q(3)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1000") and tlb_resv3_tag1_lpid_match)
                or (tlb_seq_snoop_resv_q(3)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1001") and 
                                tlb_resv3_tag1_lpid_match   and tlb_resv3_tag1_pid_match)
                or (tlb_seq_snoop_resv_q(3)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1011") and tlb_resv3_tag1_lpid_match   and 
                                tlb_resv3_tag1_pid_match   and tlb_resv3_tag1_gs_snoop_match   and 
                                tlb_resv3_tag1_as_snoop_match   and tlb_resv3_tag1_epn_loc_match)
                or  ( ((or_reduce(ex6_valid_q and tlb_resv_valid_vec) and Eq(tlb_tag4_wq,"01")) or 
                                   (or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"00")))   and ex6_ttype_q(1) and 
                                     tlb_resv3_tag1_gs_tlbwe_match   and tlb_resv3_tag1_as_tlbwe_match   and 
                                      tlb_resv3_tag1_lpid_match   and tlb_resv3_tag1_pid_match   and 
                                       tlb_resv3_tag1_epn_loc_match   and tlb_resv3_tag1_ind_match   ) 
                or  ( ex6_valid_q(3)   and Eq(tlb_tag4_wq,"10")  and ex6_ttype_q(1) ) 
                or  ( tlb_tag4_ptereload and 
                                     tlb_resv3_tag1_gs_snoop_match   and tlb_resv3_tag1_as_snoop_match   and 
                                      tlb_resv3_tag1_lpid_match   and tlb_resv3_tag1_pid_match   and 
                                       tlb_resv3_tag1_epn_loc_match   and tlb_resv3_tag1_ind_match   ) 
                or  ( ((or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"10")) or 
                                   (or_reduce(ex6_valid_q) and Eq(tlb_tag4_wq,"11")))   and ex6_ttype_q(1) and 
                                     tlb_resv3_tag1_gs_tlbwe_match   and tlb_resv3_tag1_as_tlbwe_match   and 
                                      tlb_resv3_tag1_lpid_match   and tlb_resv3_tag1_pid_match   and 
                                       tlb_resv3_tag1_epn_loc_match   and tlb_resv3_tag1_ind_match   ) 
                or (tlb_seq_snoop_resv_q(3)   and Eq(tlb_tag1_q(tagpos_is to tagpos_is+1),"11") and 
                                tlb_resv3_tag1_class_match);
tlb_resv_valid_vec  <=  tlb_resv0_valid_q & tlb_resv1_valid_q & tlb_resv2_valid_q & tlb_resv3_valid_q;
tlb_resv_match_vec  <=  tlb_resv_match_vec_q;
tlb_resv0_valid_d    <=  '0' when tlb_clr_resv_q(0)='1'   and tlb_tag5_except(0)='0'    
             else ex6_valid_q(0)   when tlb_set_resv0='1'    
             else tlb_resv0_valid_q;
tlb_resv0_epn_d    <=  tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1) when (tlb_set_resv0='1')
             else tlb_resv0_epn_q;
tlb_resv0_pid_d    <=  mas1_0_tid   when (tlb_set_resv0='1')
             else tlb_resv0_pid_q;
tlb_resv0_lpid_d    <=  mas5_0_slpid   when (tlb_set_resv0='1')
             else tlb_resv0_lpid_q;
tlb_resv0_as_d    <=  mas1_0_ts   when (tlb_set_resv0='1')
             else tlb_resv0_as_q;
tlb_resv0_gs_d    <=  mas5_0_sgs   when (tlb_set_resv0='1')
             else tlb_resv0_gs_q;
tlb_resv0_ind_d    <=  mas1_0_ind   when (tlb_set_resv0='1')
             else tlb_resv0_ind_q;
tlb_resv0_class_d    <=  mmucr3_0(54   to 55) when (tlb_set_resv0='1')
             else tlb_resv0_class_q;
-- uniquify snoop/tlbwe as/gs match sigs because tagpos_as/gs are msr state for tlbwe, not mas values
tlb_resv0_tag0_lpid_match      <=  '1' when (tlb_tag0_q(tagpos_lpid to tagpos_lpid+lpid_width-1)=tlb_resv0_lpid_q)   else '0';
tlb_resv0_tag0_pid_match       <=  '1' when (tlb_tag0_q(tagpos_pid to tagpos_pid+pid_width-1)=tlb_resv0_pid_q)   else '0';
tlb_resv0_tag0_gs_snoop_match        <=  '1' when (tlb_tag0_q(tagpos_gs)=tlb_resv0_gs_q)   else '0';
tlb_resv0_tag0_as_snoop_match        <=  '1' when (tlb_tag0_q(tagpos_as)=tlb_resv0_as_q)   else '0';
--  unused tagpos_pt, tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
tlb_resv0_tag0_gs_tlbwe_match        <=  '1' when (tlb_tag0_q(tagpos_pt)=tlb_resv0_gs_q)   else '0';
tlb_resv0_tag0_as_tlbwe_match        <=  '1' when (tlb_tag0_q(tagpos_recform)=tlb_resv0_as_q)   else '0';
tlb_resv0_tag0_ind_match       <=  '1' when (tlb_tag0_q(tagpos_ind)=tlb_resv0_ind_q)   else '0';
tlb_resv0_tag0_class_match     <=  '1' when (tlb_tag0_q(tagpos_class to tagpos_class+1)=tlb_resv0_class_q)   else '0';
-- local match includes upper epn bits
tlb_resv0_tag0_epn_loc_match       <=  '1' when (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1)=tlb_resv0_epn_q(52-epn_width   to 51) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-5)=tlb_resv0_epn_q(52-epn_width   to 47) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-9)=tlb_resv0_epn_q(52-epn_width   to 43) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-13)=tlb_resv0_epn_q(52-epn_width   to 39) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-17)=tlb_resv0_epn_q(52-epn_width   to 35) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-19)=tlb_resv0_epn_q(52-epn_width   to 33) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- global match ignores certain upper epn bits that are not tranferred over bus
-- fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
tlb_resv0_tag0_epn_glob_match       <=  '1' when (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-1)=tlb_resv0_epn_q(52-epn_width+31   to 51) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-5)=tlb_resv0_epn_q(52-epn_width+31   to 47) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-9)=tlb_resv0_epn_q(52-epn_width+31   to 43) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-13)=tlb_resv0_epn_q(52-epn_width+31   to 39) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-17)=tlb_resv0_epn_q(52-epn_width+31   to 35) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-19)=tlb_resv0_epn_q(52-epn_width+31   to 33) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- NOTE: ind is part of reservation tlbwe/ptereload match criteria, but not invalidate criteria
tlb_resv_match_vec_d(0) <=  (tlb_resv0_valid_q   and tlb_tag0_q(tagpos_type_snoop)='1' 
                            and tlb_resv0_tag0_epn_loc_match   and tlb_resv0_tag0_lpid_match   and tlb_resv0_tag0_pid_match
                            and tlb_resv0_tag0_as_snoop_match   and tlb_resv0_tag0_gs_snoop_match)   or                         
                          (tlb_resv0_valid_q   and tlb_tag0_q(tagpos_type_tlbwe)='1' 
                            and tlb_resv0_tag0_epn_loc_match   and tlb_resv0_tag0_lpid_match   and tlb_resv0_tag0_pid_match
                            and tlb_resv0_tag0_as_tlbwe_match   and tlb_resv0_tag0_gs_tlbwe_match   and tlb_resv0_tag0_ind_match)   or  
                          (tlb_resv0_valid_q   and tlb_tag0_q(tagpos_type_ptereload)='1' 
                            and tlb_resv0_tag0_epn_loc_match   and tlb_resv0_tag0_lpid_match   and tlb_resv0_tag0_pid_match
                            and tlb_resv0_tag0_as_snoop_match   and tlb_resv0_tag0_gs_snoop_match   and tlb_resv0_tag0_ind_match);
tlb_resv1_valid_d    <=  '0' when tlb_clr_resv_q(1)='1'   and tlb_tag5_except(1)='0'    
             else ex6_valid_q(1)   when tlb_set_resv1='1'    
             else tlb_resv1_valid_q;
tlb_resv1_epn_d    <=  tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1) when (tlb_set_resv1='1')
             else tlb_resv1_epn_q;
tlb_resv1_pid_d    <=  mas1_1_tid   when (tlb_set_resv1='1')
             else tlb_resv1_pid_q;
tlb_resv1_lpid_d    <=  mas5_1_slpid   when (tlb_set_resv1='1')
             else tlb_resv1_lpid_q;
tlb_resv1_as_d    <=  mas1_1_ts   when (tlb_set_resv1='1')
             else tlb_resv1_as_q;
tlb_resv1_gs_d    <=  mas5_1_sgs   when (tlb_set_resv1='1')
             else tlb_resv1_gs_q;
tlb_resv1_ind_d    <=  mas1_1_ind   when (tlb_set_resv1='1')
             else tlb_resv1_ind_q;
tlb_resv1_class_d    <=  mmucr3_1(54   to 55) when (tlb_set_resv1='1')
             else tlb_resv1_class_q;
-- uniquify snoop/tlbwe as/gs match sigs because tagpos_as/gs are msr state for tlbwe, not mas values
tlb_resv1_tag0_lpid_match      <=  '1' when (tlb_tag0_q(tagpos_lpid to tagpos_lpid+lpid_width-1)=tlb_resv1_lpid_q)   else '0';
tlb_resv1_tag0_pid_match       <=  '1' when (tlb_tag0_q(tagpos_pid to tagpos_pid+pid_width-1)=tlb_resv1_pid_q)   else '0';
tlb_resv1_tag0_gs_snoop_match        <=  '1' when (tlb_tag0_q(tagpos_gs)=tlb_resv1_gs_q)   else '0';
tlb_resv1_tag0_as_snoop_match        <=  '1' when (tlb_tag0_q(tagpos_as)=tlb_resv1_as_q)   else '0';
--  unused tagpos_pt, tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
tlb_resv1_tag0_gs_tlbwe_match        <=  '1' when (tlb_tag0_q(tagpos_pt)=tlb_resv1_gs_q)   else '0';
tlb_resv1_tag0_as_tlbwe_match        <=  '1' when (tlb_tag0_q(tagpos_recform)=tlb_resv1_as_q)   else '0';
tlb_resv1_tag0_ind_match       <=  '1' when (tlb_tag0_q(tagpos_ind)=tlb_resv1_ind_q)   else '0';
tlb_resv1_tag0_class_match     <=  '1' when (tlb_tag0_q(tagpos_class to tagpos_class+1)=tlb_resv1_class_q)   else '0';
-- local match includes upper epn bits
tlb_resv1_tag0_epn_loc_match       <=  '1' when (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1)=tlb_resv1_epn_q(52-epn_width   to 51) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-5)=tlb_resv1_epn_q(52-epn_width   to 47) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-9)=tlb_resv1_epn_q(52-epn_width   to 43) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-13)=tlb_resv1_epn_q(52-epn_width   to 39) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-17)=tlb_resv1_epn_q(52-epn_width   to 35) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-19)=tlb_resv1_epn_q(52-epn_width   to 33) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- global match ignores certain upper epn bits that are not tranferred over bus
-- fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
tlb_resv1_tag0_epn_glob_match       <=  '1' when (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-1)=tlb_resv1_epn_q(52-epn_width+31   to 51) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-5)=tlb_resv1_epn_q(52-epn_width+31   to 47) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-9)=tlb_resv1_epn_q(52-epn_width+31   to 43) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-13)=tlb_resv1_epn_q(52-epn_width+31   to 39) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-17)=tlb_resv1_epn_q(52-epn_width+31   to 35) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-19)=tlb_resv1_epn_q(52-epn_width+31   to 33) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- NOTE: ind is part of reservation tlbwe/ptereload match criteria, but not invalidate criteria
tlb_resv_match_vec_d(1) <=  (tlb_resv1_valid_q   and tlb_tag0_q(tagpos_type_snoop)='1' 
                            and tlb_resv1_tag0_epn_loc_match   and tlb_resv1_tag0_lpid_match   and tlb_resv1_tag0_pid_match
                            and tlb_resv1_tag0_as_snoop_match   and tlb_resv1_tag0_gs_snoop_match)   or                         
                          (tlb_resv1_valid_q   and tlb_tag0_q(tagpos_type_tlbwe)='1' 
                            and tlb_resv1_tag0_epn_loc_match   and tlb_resv1_tag0_lpid_match   and tlb_resv1_tag0_pid_match
                            and tlb_resv1_tag0_as_tlbwe_match   and tlb_resv1_tag0_gs_tlbwe_match   and tlb_resv1_tag0_ind_match)   or  
                          (tlb_resv1_valid_q   and tlb_tag0_q(tagpos_type_ptereload)='1' 
                            and tlb_resv1_tag0_epn_loc_match   and tlb_resv1_tag0_lpid_match   and tlb_resv1_tag0_pid_match
                            and tlb_resv1_tag0_as_snoop_match   and tlb_resv1_tag0_gs_snoop_match   and tlb_resv1_tag0_ind_match);
tlb_resv2_valid_d    <=  '0' when tlb_clr_resv_q(2)='1'   and tlb_tag5_except(2)='0'    
             else ex6_valid_q(2)   when tlb_set_resv2='1'    
             else tlb_resv2_valid_q;
tlb_resv2_epn_d    <=  tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1) when (tlb_set_resv2='1')
             else tlb_resv2_epn_q;
tlb_resv2_pid_d    <=  mas1_2_tid   when (tlb_set_resv2='1')
             else tlb_resv2_pid_q;
tlb_resv2_lpid_d    <=  mas5_2_slpid   when (tlb_set_resv2='1')
             else tlb_resv2_lpid_q;
tlb_resv2_as_d    <=  mas1_2_ts   when (tlb_set_resv2='1')
             else tlb_resv2_as_q;
tlb_resv2_gs_d    <=  mas5_2_sgs   when (tlb_set_resv2='1')
             else tlb_resv2_gs_q;
tlb_resv2_ind_d    <=  mas1_2_ind   when (tlb_set_resv2='1')
             else tlb_resv2_ind_q;
tlb_resv2_class_d    <=  mmucr3_2(54   to 55) when (tlb_set_resv2='1')
             else tlb_resv2_class_q;
-- uniquify snoop/tlbwe as/gs match sigs because tagpos_as/gs are msr state for tlbwe, not mas values
tlb_resv2_tag0_lpid_match      <=  '1' when (tlb_tag0_q(tagpos_lpid to tagpos_lpid+lpid_width-1)=tlb_resv2_lpid_q)   else '0';
tlb_resv2_tag0_pid_match       <=  '1' when (tlb_tag0_q(tagpos_pid to tagpos_pid+pid_width-1)=tlb_resv2_pid_q)   else '0';
tlb_resv2_tag0_gs_snoop_match        <=  '1' when (tlb_tag0_q(tagpos_gs)=tlb_resv2_gs_q)   else '0';
tlb_resv2_tag0_as_snoop_match        <=  '1' when (tlb_tag0_q(tagpos_as)=tlb_resv2_as_q)   else '0';
--  unused tagpos_pt, tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
tlb_resv2_tag0_gs_tlbwe_match        <=  '1' when (tlb_tag0_q(tagpos_pt)=tlb_resv2_gs_q)   else '0';
tlb_resv2_tag0_as_tlbwe_match        <=  '1' when (tlb_tag0_q(tagpos_recform)=tlb_resv2_as_q)   else '0';
tlb_resv2_tag0_ind_match       <=  '1' when (tlb_tag0_q(tagpos_ind)=tlb_resv2_ind_q)   else '0';
tlb_resv2_tag0_class_match     <=  '1' when (tlb_tag0_q(tagpos_class to tagpos_class+1)=tlb_resv2_class_q)   else '0';
-- local match includes upper epn bits
tlb_resv2_tag0_epn_loc_match       <=  '1' when (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1)=tlb_resv2_epn_q(52-epn_width   to 51) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-5)=tlb_resv2_epn_q(52-epn_width   to 47) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-9)=tlb_resv2_epn_q(52-epn_width   to 43) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-13)=tlb_resv2_epn_q(52-epn_width   to 39) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-17)=tlb_resv2_epn_q(52-epn_width   to 35) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-19)=tlb_resv2_epn_q(52-epn_width   to 33) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- global match ignores certain upper epn bits that are not tranferred over bus
-- fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
tlb_resv2_tag0_epn_glob_match       <=  '1' when (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-1)=tlb_resv2_epn_q(52-epn_width+31   to 51) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-5)=tlb_resv2_epn_q(52-epn_width+31   to 47) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-9)=tlb_resv2_epn_q(52-epn_width+31   to 43) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-13)=tlb_resv2_epn_q(52-epn_width+31   to 39) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-17)=tlb_resv2_epn_q(52-epn_width+31   to 35) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-19)=tlb_resv2_epn_q(52-epn_width+31   to 33) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- NOTE: ind is part of reservation tlbwe/ptereload match criteria, but not invalidate criteria
tlb_resv_match_vec_d(2) <=  (tlb_resv2_valid_q   and tlb_tag0_q(tagpos_type_snoop)='1' 
                            and tlb_resv2_tag0_epn_loc_match   and tlb_resv2_tag0_lpid_match   and tlb_resv2_tag0_pid_match
                            and tlb_resv2_tag0_as_snoop_match   and tlb_resv2_tag0_gs_snoop_match)   or                         
                          (tlb_resv2_valid_q   and tlb_tag0_q(tagpos_type_tlbwe)='1' 
                            and tlb_resv2_tag0_epn_loc_match   and tlb_resv2_tag0_lpid_match   and tlb_resv2_tag0_pid_match
                            and tlb_resv2_tag0_as_tlbwe_match   and tlb_resv2_tag0_gs_tlbwe_match   and tlb_resv2_tag0_ind_match)   or  
                          (tlb_resv2_valid_q   and tlb_tag0_q(tagpos_type_ptereload)='1' 
                            and tlb_resv2_tag0_epn_loc_match   and tlb_resv2_tag0_lpid_match   and tlb_resv2_tag0_pid_match
                            and tlb_resv2_tag0_as_snoop_match   and tlb_resv2_tag0_gs_snoop_match   and tlb_resv2_tag0_ind_match);
tlb_resv3_valid_d    <=  '0' when tlb_clr_resv_q(3)='1'   and tlb_tag5_except(3)='0'    
             else ex6_valid_q(3)   when tlb_set_resv3='1'    
             else tlb_resv3_valid_q;
tlb_resv3_epn_d    <=  tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1) when (tlb_set_resv3='1')
             else tlb_resv3_epn_q;
tlb_resv3_pid_d    <=  mas1_3_tid   when (tlb_set_resv3='1')
             else tlb_resv3_pid_q;
tlb_resv3_lpid_d    <=  mas5_3_slpid   when (tlb_set_resv3='1')
             else tlb_resv3_lpid_q;
tlb_resv3_as_d    <=  mas1_3_ts   when (tlb_set_resv3='1')
             else tlb_resv3_as_q;
tlb_resv3_gs_d    <=  mas5_3_sgs   when (tlb_set_resv3='1')
             else tlb_resv3_gs_q;
tlb_resv3_ind_d    <=  mas1_3_ind   when (tlb_set_resv3='1')
             else tlb_resv3_ind_q;
tlb_resv3_class_d    <=  mmucr3_3(54   to 55) when (tlb_set_resv3='1')
             else tlb_resv3_class_q;
tlb_resv3_tag0_lpid_match      <=  '1' when (tlb_tag0_q(tagpos_lpid to tagpos_lpid+lpid_width-1)=tlb_resv3_lpid_q)   else '0';
tlb_resv3_tag0_pid_match       <=  '1' when (tlb_tag0_q(tagpos_pid to tagpos_pid+pid_width-1)=tlb_resv3_pid_q)   else '0';
tlb_resv3_tag0_gs_snoop_match        <=  '1' when (tlb_tag0_q(tagpos_gs)=tlb_resv3_gs_q)   else '0';
tlb_resv3_tag0_as_snoop_match        <=  '1' when (tlb_tag0_q(tagpos_as)=tlb_resv3_as_q)   else '0';
--  unused tagpos_pt, tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
tlb_resv3_tag0_gs_tlbwe_match        <=  '1' when (tlb_tag0_q(tagpos_pt)=tlb_resv3_gs_q)   else '0';
tlb_resv3_tag0_as_tlbwe_match        <=  '1' when (tlb_tag0_q(tagpos_recform)=tlb_resv3_as_q)   else '0';
tlb_resv3_tag0_ind_match       <=  '1' when (tlb_tag0_q(tagpos_ind)=tlb_resv3_ind_q)   else '0';
tlb_resv3_tag0_class_match     <=  '1' when (tlb_tag0_q(tagpos_class to tagpos_class+1)=tlb_resv3_class_q)   else '0';
-- local match includes upper epn bits
tlb_resv3_tag0_epn_loc_match       <=  '1' when (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1)=tlb_resv3_epn_q(52-epn_width   to 51) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-5)=tlb_resv3_epn_q(52-epn_width   to 47) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-9)=tlb_resv3_epn_q(52-epn_width   to 43) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-13)=tlb_resv3_epn_q(52-epn_width   to 39) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-17)=tlb_resv3_epn_q(52-epn_width   to 35) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB) or
                                            (tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-19)=tlb_resv3_epn_q(52-epn_width   to 33) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- global match ignores certain upper epn bits that are not tranferred over bus
-- fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
tlb_resv3_tag0_epn_glob_match       <=  '1' when (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-1)=tlb_resv3_epn_q(52-epn_width+31   to 51) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-5)=tlb_resv3_epn_q(52-epn_width+31   to 47) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-9)=tlb_resv3_epn_q(52-epn_width+31   to 43) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-13)=tlb_resv3_epn_q(52-epn_width+31   to 39) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-17)=tlb_resv3_epn_q(52-epn_width+31   to 35) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB) or
                                            (tlb_tag0_q(tagpos_epn+31 to tagpos_epn+epn_width-19)=tlb_resv3_epn_q(52-epn_width+31   to 33) and tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- NOTE: ind is part of reservation tlbwe/ptereload match criteria, but not invalidate criteria
tlb_resv_match_vec_d(3) <=  (tlb_resv3_valid_q   and tlb_tag0_q(tagpos_type_snoop)='1' 
                            and tlb_resv3_tag0_epn_loc_match   and tlb_resv3_tag0_lpid_match   and tlb_resv3_tag0_pid_match
                            and tlb_resv3_tag0_as_snoop_match   and tlb_resv3_tag0_gs_snoop_match)   or                         
                          (tlb_resv3_valid_q   and tlb_tag0_q(tagpos_type_tlbwe)='1' 
                            and tlb_resv3_tag0_epn_loc_match   and tlb_resv3_tag0_lpid_match   and tlb_resv3_tag0_pid_match
                            and tlb_resv3_tag0_as_tlbwe_match   and tlb_resv3_tag0_gs_tlbwe_match   and tlb_resv3_tag0_ind_match)   or  
                          (tlb_resv3_valid_q   and tlb_tag0_q(tagpos_type_ptereload)='1' 
                            and tlb_resv3_tag0_epn_loc_match   and tlb_resv3_tag0_lpid_match   and tlb_resv3_tag0_pid_match
                            and tlb_resv3_tag0_as_snoop_match   and tlb_resv3_tag0_gs_snoop_match   and tlb_resv3_tag0_ind_match);
tlbaddrwidth7_gen: if tlb_addr_width = 7 generate
--  TLB Address Hash xor terms per size
--   4K        64K       1M     16M   256M    1G
-------------------------------------------------
-- 6 51 44 37  47    37  43 36  39     35     33
-- 5 50 43 36  46    36  42 35  38     34     32
-- 4 49 42 35  45    35  41 34  37     33     31
-- 3 48 41 34  44    34  40 33  36 32  32     30
-- 2 47 40 33  43 40 33  39 32  35 31  31     29
-- 1 46 39 32  42 39 32  38 31  34 30  30 28  28
-- 0 45 38 31  41 38 31  37 30  33 29  29 27  27
size_1G_hashed_addr(6) <=  tlb_tag0_q(33) xor tlb_tag0_q(tagpos_pid+pid_width-1);
size_1G_hashed_addr(5) <=  tlb_tag0_q(32) xor tlb_tag0_q(tagpos_pid+pid_width-2);
size_1G_hashed_addr(4) <=  tlb_tag0_q(31) xor tlb_tag0_q(tagpos_pid+pid_width-3);
size_1G_hashed_addr(3) <=  tlb_tag0_q(30) xor tlb_tag0_q(tagpos_pid+pid_width-4);
size_1G_hashed_addr(2) <=  tlb_tag0_q(29) xor tlb_tag0_q(tagpos_pid+pid_width-5);
size_1G_hashed_addr(1) <=  tlb_tag0_q(28) xor tlb_tag0_q(tagpos_pid+pid_width-6);
size_1G_hashed_addr(0) <=  tlb_tag0_q(27) xor tlb_tag0_q(tagpos_pid+pid_width-7);
size_1G_hashed_tid0_addr(6) <=  tlb_tag0_q(33);
size_1G_hashed_tid0_addr(5) <=  tlb_tag0_q(32);
size_1G_hashed_tid0_addr(4) <=  tlb_tag0_q(31);
size_1G_hashed_tid0_addr(3) <=  tlb_tag0_q(30);
size_1G_hashed_tid0_addr(2) <=  tlb_tag0_q(29);
size_1G_hashed_tid0_addr(1) <=  tlb_tag0_q(28);
size_1G_hashed_tid0_addr(0) <=  tlb_tag0_q(27);
size_256M_hashed_addr(6) <=  tlb_tag0_q(35)                     xor tlb_tag0_q(tagpos_pid+pid_width-1);
size_256M_hashed_addr(5) <=  tlb_tag0_q(34)                     xor tlb_tag0_q(tagpos_pid+pid_width-2);
size_256M_hashed_addr(4) <=  tlb_tag0_q(33)                     xor tlb_tag0_q(tagpos_pid+pid_width-3);
size_256M_hashed_addr(3) <=  tlb_tag0_q(32)                     xor tlb_tag0_q(tagpos_pid+pid_width-4);
size_256M_hashed_addr(2) <=  tlb_tag0_q(31)                     xor tlb_tag0_q(tagpos_pid+pid_width-5);
size_256M_hashed_addr(1) <=  tlb_tag0_q(30) xor tlb_tag0_q(28) xor tlb_tag0_q(tagpos_pid+pid_width-6);
size_256M_hashed_addr(0) <=  tlb_tag0_q(29) xor tlb_tag0_q(27) xor tlb_tag0_q(tagpos_pid+pid_width-7);
size_256M_hashed_tid0_addr(6) <=  tlb_tag0_q(35);
size_256M_hashed_tid0_addr(5) <=  tlb_tag0_q(34);
size_256M_hashed_tid0_addr(4) <=  tlb_tag0_q(33);
size_256M_hashed_tid0_addr(3) <=  tlb_tag0_q(32);
size_256M_hashed_tid0_addr(2) <=  tlb_tag0_q(31);
size_256M_hashed_tid0_addr(1) <=  tlb_tag0_q(30) xor tlb_tag0_q(28);
size_256M_hashed_tid0_addr(0) <=  tlb_tag0_q(29) xor tlb_tag0_q(27);
size_16M_hashed_addr(6) <=  tlb_tag0_q(39)                     xor tlb_tag0_q(tagpos_pid+pid_width-1);
size_16M_hashed_addr(5) <=  tlb_tag0_q(38)                     xor tlb_tag0_q(tagpos_pid+pid_width-2);
size_16M_hashed_addr(4) <=  tlb_tag0_q(37)                     xor tlb_tag0_q(tagpos_pid+pid_width-3);
size_16M_hashed_addr(3) <=  tlb_tag0_q(36) xor tlb_tag0_q(32) xor tlb_tag0_q(tagpos_pid+pid_width-4);
size_16M_hashed_addr(2) <=  tlb_tag0_q(35) xor tlb_tag0_q(31) xor tlb_tag0_q(tagpos_pid+pid_width-5);
size_16M_hashed_addr(1) <=  tlb_tag0_q(34) xor tlb_tag0_q(30) xor tlb_tag0_q(tagpos_pid+pid_width-6);
size_16M_hashed_addr(0) <=  tlb_tag0_q(33) xor tlb_tag0_q(29) xor tlb_tag0_q(tagpos_pid+pid_width-7);
size_16M_hashed_tid0_addr(6) <=  tlb_tag0_q(39);
size_16M_hashed_tid0_addr(5) <=  tlb_tag0_q(38);
size_16M_hashed_tid0_addr(4) <=  tlb_tag0_q(37);
size_16M_hashed_tid0_addr(3) <=  tlb_tag0_q(36) xor tlb_tag0_q(32);
size_16M_hashed_tid0_addr(2) <=  tlb_tag0_q(35) xor tlb_tag0_q(31);
size_16M_hashed_tid0_addr(1) <=  tlb_tag0_q(34) xor tlb_tag0_q(30);
size_16M_hashed_tid0_addr(0) <=  tlb_tag0_q(33) xor tlb_tag0_q(29);
size_1M_hashed_addr(6) <=  tlb_tag0_q(43) xor tlb_tag0_q(36) xor tlb_tag0_q(tagpos_pid+pid_width-1);
size_1M_hashed_addr(5) <=  tlb_tag0_q(42) xor tlb_tag0_q(35) xor tlb_tag0_q(tagpos_pid+pid_width-2);
size_1M_hashed_addr(4) <=  tlb_tag0_q(41) xor tlb_tag0_q(34) xor tlb_tag0_q(tagpos_pid+pid_width-3);
size_1M_hashed_addr(3) <=  tlb_tag0_q(40) xor tlb_tag0_q(33) xor tlb_tag0_q(tagpos_pid+pid_width-4);
size_1M_hashed_addr(2) <=  tlb_tag0_q(39) xor tlb_tag0_q(32) xor tlb_tag0_q(tagpos_pid+pid_width-5);
size_1M_hashed_addr(1) <=  tlb_tag0_q(38) xor tlb_tag0_q(31) xor tlb_tag0_q(tagpos_pid+pid_width-6);
size_1M_hashed_addr(0) <=  tlb_tag0_q(37) xor tlb_tag0_q(30) xor tlb_tag0_q(tagpos_pid+pid_width-7);
size_1M_hashed_tid0_addr(6) <=  tlb_tag0_q(43) xor tlb_tag0_q(36);
size_1M_hashed_tid0_addr(5) <=  tlb_tag0_q(42) xor tlb_tag0_q(35);
size_1M_hashed_tid0_addr(4) <=  tlb_tag0_q(41) xor tlb_tag0_q(34);
size_1M_hashed_tid0_addr(3) <=  tlb_tag0_q(40) xor tlb_tag0_q(33);
size_1M_hashed_tid0_addr(2) <=  tlb_tag0_q(39) xor tlb_tag0_q(32);
size_1M_hashed_tid0_addr(1) <=  tlb_tag0_q(38) xor tlb_tag0_q(31);
size_1M_hashed_tid0_addr(0) <=  tlb_tag0_q(37) xor tlb_tag0_q(30);
size_64K_hashed_addr(6) <=  tlb_tag0_q(47)                     xor tlb_tag0_q(37) xor tlb_tag0_q(tagpos_pid+pid_width-1);
size_64K_hashed_addr(5) <=  tlb_tag0_q(46)                     xor tlb_tag0_q(36) xor tlb_tag0_q(tagpos_pid+pid_width-2);
size_64K_hashed_addr(4) <=  tlb_tag0_q(45)                     xor tlb_tag0_q(35) xor tlb_tag0_q(tagpos_pid+pid_width-3);
size_64K_hashed_addr(3) <=  tlb_tag0_q(44)                     xor tlb_tag0_q(34) xor tlb_tag0_q(tagpos_pid+pid_width-4);
size_64K_hashed_addr(2) <=  tlb_tag0_q(43) xor tlb_tag0_q(40) xor tlb_tag0_q(33) xor tlb_tag0_q(tagpos_pid+pid_width-5);
size_64K_hashed_addr(1) <=  tlb_tag0_q(42) xor tlb_tag0_q(39) xor tlb_tag0_q(32) xor tlb_tag0_q(tagpos_pid+pid_width-6);
size_64K_hashed_addr(0) <=  tlb_tag0_q(41) xor tlb_tag0_q(38) xor tlb_tag0_q(31) xor tlb_tag0_q(tagpos_pid+pid_width-7);
size_64K_hashed_tid0_addr(6) <=  tlb_tag0_q(47)                     xor tlb_tag0_q(37);
size_64K_hashed_tid0_addr(5) <=  tlb_tag0_q(46)                     xor tlb_tag0_q(36);
size_64K_hashed_tid0_addr(4) <=  tlb_tag0_q(45)                     xor tlb_tag0_q(35);
size_64K_hashed_tid0_addr(3) <=  tlb_tag0_q(44)                     xor tlb_tag0_q(34);
size_64K_hashed_tid0_addr(2) <=  tlb_tag0_q(43) xor tlb_tag0_q(40) xor tlb_tag0_q(33);
size_64K_hashed_tid0_addr(1) <=  tlb_tag0_q(42) xor tlb_tag0_q(39) xor tlb_tag0_q(32);
size_64K_hashed_tid0_addr(0) <=  tlb_tag0_q(41) xor tlb_tag0_q(38) xor tlb_tag0_q(31);
size_4K_hashed_addr(6) <=  tlb_tag0_q(51) xor tlb_tag0_q(44) xor tlb_tag0_q(37) xor tlb_tag0_q(tagpos_pid+pid_width-1);
size_4K_hashed_addr(5) <=  tlb_tag0_q(50) xor tlb_tag0_q(43) xor tlb_tag0_q(36) xor tlb_tag0_q(tagpos_pid+pid_width-2);
size_4K_hashed_addr(4) <=  tlb_tag0_q(49) xor tlb_tag0_q(42) xor tlb_tag0_q(35) xor tlb_tag0_q(tagpos_pid+pid_width-3);
size_4K_hashed_addr(3) <=  tlb_tag0_q(48) xor tlb_tag0_q(41) xor tlb_tag0_q(34) xor tlb_tag0_q(tagpos_pid+pid_width-4);
size_4K_hashed_addr(2) <=  tlb_tag0_q(47) xor tlb_tag0_q(40) xor tlb_tag0_q(33) xor tlb_tag0_q(tagpos_pid+pid_width-5);
size_4K_hashed_addr(1) <=  tlb_tag0_q(46) xor tlb_tag0_q(39) xor tlb_tag0_q(32) xor tlb_tag0_q(tagpos_pid+pid_width-6);
size_4K_hashed_addr(0) <=  tlb_tag0_q(45) xor tlb_tag0_q(38) xor tlb_tag0_q(31) xor tlb_tag0_q(tagpos_pid+pid_width-7);
size_4K_hashed_tid0_addr(6) <=  tlb_tag0_q(51) xor tlb_tag0_q(44) xor tlb_tag0_q(37);
size_4K_hashed_tid0_addr(5) <=  tlb_tag0_q(50) xor tlb_tag0_q(43) xor tlb_tag0_q(36);
size_4K_hashed_tid0_addr(4) <=  tlb_tag0_q(49) xor tlb_tag0_q(42) xor tlb_tag0_q(35);
size_4K_hashed_tid0_addr(3) <=  tlb_tag0_q(48) xor tlb_tag0_q(41) xor tlb_tag0_q(34);
size_4K_hashed_tid0_addr(2) <=  tlb_tag0_q(47) xor tlb_tag0_q(40) xor tlb_tag0_q(33);
size_4K_hashed_tid0_addr(1) <=  tlb_tag0_q(46) xor tlb_tag0_q(39) xor tlb_tag0_q(32);
size_4K_hashed_tid0_addr(0) <=  tlb_tag0_q(45) xor tlb_tag0_q(38) xor tlb_tag0_q(31);
end generate tlbaddrwidth7_gen;
--constant TLB_PgSize_1GB   :=  1010 ;
--constant TLB_PgSize_256MB :=  1001 ;
--constant TLB_PgSize_16MB  :=  0111 ;
--constant TLB_PgSize_1MB   :=  0101 ;
--constant TLB_PgSize_64KB  :=  0011 ;
--constant TLB_PgSize_4KB   :=  0001 ;
tlb_tag0_tid_notzero  <=  or_reduce(tlb_tag0_q(tagpos_pid to tagpos_pid+pid_width-1));
-- these are used for direct and indirect page sizes
tlb_tag0_hashed_addr  <=  size_1G_hashed_addr when tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB
               else size_256M_hashed_addr when tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB
               else size_16M_hashed_addr when tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB
               else size_1M_hashed_addr  when tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB
               else size_64K_hashed_addr when tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB
               else size_4K_hashed_addr;
tlb_tag0_hashed_tid0_addr  <=  size_1G_hashed_tid0_addr when tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB
                   else size_256M_hashed_tid0_addr when tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_256MB
                   else size_16M_hashed_tid0_addr when tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB
                   else size_1M_hashed_tid0_addr  when tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB
                   else size_64K_hashed_tid0_addr when tlb_tag0_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB
                   else size_4K_hashed_tid0_addr;
-- these are used for direct page sizes only
tlb_hashed_addr1  <=  size_1G_hashed_addr when mmucr2(28 to 31)=TLB_PgSize_1GB
               else size_16M_hashed_addr when mmucr2(28 to 31)=TLB_PgSize_16MB
               else size_1M_hashed_addr  when mmucr2(28 to 31)=TLB_PgSize_1MB
               else size_64K_hashed_addr when mmucr2(28 to 31)=TLB_PgSize_64KB
               else size_4K_hashed_addr;
tlb_hashed_tid0_addr1  <=  size_1G_hashed_tid0_addr when mmucr2(28 to 31)=TLB_PgSize_1GB
                   else size_16M_hashed_tid0_addr when mmucr2(28 to 31)=TLB_PgSize_16MB
                   else size_1M_hashed_tid0_addr  when mmucr2(28 to 31)=TLB_PgSize_1MB
                   else size_64K_hashed_tid0_addr when mmucr2(28 to 31)=TLB_PgSize_64KB
                   else size_4K_hashed_tid0_addr;
tlb_hashed_addr2  <=  size_1G_hashed_addr when mmucr2(24 to 27)=TLB_PgSize_1GB
               else size_16M_hashed_addr when mmucr2(24 to 27)=TLB_PgSize_16MB
               else size_1M_hashed_addr  when mmucr2(24 to 27)=TLB_PgSize_1MB
               else size_64K_hashed_addr when mmucr2(24 to 27)=TLB_PgSize_64KB
               else size_4K_hashed_addr;
tlb_hashed_tid0_addr2  <=  size_1G_hashed_tid0_addr when mmucr2(24 to 27)=TLB_PgSize_1GB
                   else size_16M_hashed_tid0_addr when mmucr2(24 to 27)=TLB_PgSize_16MB
                   else size_1M_hashed_tid0_addr  when mmucr2(24 to 27)=TLB_PgSize_1MB
                   else size_64K_hashed_tid0_addr when mmucr2(24 to 27)=TLB_PgSize_64KB
                   else size_4K_hashed_tid0_addr;
tlb_hashed_addr3  <=  size_1G_hashed_addr when mmucr2(20 to 23)=TLB_PgSize_1GB
               else size_16M_hashed_addr when mmucr2(20 to 23)=TLB_PgSize_16MB
               else size_1M_hashed_addr  when mmucr2(20 to 23)=TLB_PgSize_1MB
               else size_64K_hashed_addr when mmucr2(20 to 23)=TLB_PgSize_64KB
               else size_4K_hashed_addr;
tlb_hashed_tid0_addr3  <=  size_1G_hashed_tid0_addr when mmucr2(20 to 23)=TLB_PgSize_1GB
                   else size_16M_hashed_tid0_addr when mmucr2(20 to 23)=TLB_PgSize_16MB
                   else size_1M_hashed_tid0_addr  when mmucr2(20 to 23)=TLB_PgSize_1MB
                   else size_64K_hashed_tid0_addr when mmucr2(20 to 23)=TLB_PgSize_64KB
                   else size_4K_hashed_tid0_addr;
tlb_hashed_addr4  <=  size_1G_hashed_addr when mmucr2(16 to 19)=TLB_PgSize_1GB
               else size_16M_hashed_addr when mmucr2(16 to 19)=TLB_PgSize_16MB
               else size_1M_hashed_addr  when mmucr2(16 to 19)=TLB_PgSize_1MB
               else size_64K_hashed_addr when mmucr2(16 to 19)=TLB_PgSize_64KB
               else size_4K_hashed_addr;
tlb_hashed_tid0_addr4  <=  size_1G_hashed_tid0_addr when mmucr2(16 to 19)=TLB_PgSize_1GB
                   else size_16M_hashed_tid0_addr when mmucr2(16 to 19)=TLB_PgSize_16MB
                   else size_1M_hashed_tid0_addr  when mmucr2(16 to 19)=TLB_PgSize_1MB
                   else size_64K_hashed_tid0_addr when mmucr2(16 to 19)=TLB_PgSize_64KB
                   else size_4K_hashed_tid0_addr;
tlb_hashed_addr5  <=  size_1G_hashed_addr when mmucr2(12 to 15)=TLB_PgSize_1GB
               else size_16M_hashed_addr when mmucr2(12 to 15)=TLB_PgSize_16MB
               else size_1M_hashed_addr  when mmucr2(12 to 15)=TLB_PgSize_1MB
               else size_64K_hashed_addr when mmucr2(12 to 15)=TLB_PgSize_64KB
               else size_4K_hashed_addr;
tlb_hashed_tid0_addr5  <=  size_1G_hashed_tid0_addr when mmucr2(12 to 15)=TLB_PgSize_1GB
                   else size_16M_hashed_tid0_addr when mmucr2(12 to 15)=TLB_PgSize_16MB
                   else size_1M_hashed_tid0_addr  when mmucr2(12 to 15)=TLB_PgSize_1MB
                   else size_64K_hashed_tid0_addr when mmucr2(12 to 15)=TLB_PgSize_64KB
                   else size_4K_hashed_tid0_addr;
pgsize1_valid  <=  '1' when mmucr2(28 to 31) /= "0000" else '0';
pgsize2_valid  <=  '1' when mmucr2(24 to 27) /= "0000" else '0';
pgsize3_valid  <=  '1' when mmucr2(20 to 23) /= "0000" else '0';
pgsize4_valid  <=  '1' when mmucr2(16 to 19) /= "0000" else '0';
pgsize5_valid  <=  '1' when mmucr2(12 to 15) /= "0000" else '0';
pgsize1_tid0_valid  <=  '1' when mmucr2(28 to 31) /= "0000" else '0';
pgsize2_tid0_valid  <=  '1' when mmucr2(24 to 27) /= "0000" else '0';
pgsize3_tid0_valid  <=  '1' when mmucr2(20 to 23) /= "0000" else '0';
pgsize4_tid0_valid  <=  '1' when mmucr2(16 to 19) /= "0000" else '0';
pgsize5_tid0_valid  <=  '1' when mmucr2(12 to 15) /= "0000" else '0';
pgsize_qty  <=  "101" when (pgsize5_valid='1' and pgsize4_valid='1' and pgsize3_valid='1' and pgsize2_valid='1' and pgsize1_valid='1')
         else "100" when (pgsize4_valid='1' and pgsize3_valid='1' and pgsize2_valid='1' and pgsize1_valid='1') 
         else "011" when (pgsize3_valid='1' and pgsize2_valid='1' and pgsize1_valid='1') 
         else "010" when (pgsize2_valid='1' and pgsize1_valid='1') 
         else "001" when (pgsize1_valid='1') 
         else "000";
pgsize_tid0_qty  <=  "101" when (pgsize5_tid0_valid='1' and pgsize4_tid0_valid='1' and pgsize3_tid0_valid='1' and pgsize2_tid0_valid='1' and pgsize1_tid0_valid='1')
              else "100" when (pgsize4_tid0_valid='1' and pgsize3_tid0_valid='1' and pgsize2_tid0_valid='1' and pgsize1_tid0_valid='1') 
              else "011" when (pgsize3_tid0_valid='1' and pgsize2_tid0_valid='1' and pgsize1_tid0_valid='1') 
              else "010" when (pgsize2_tid0_valid='1' and pgsize1_tid0_valid='1') 
              else "001" when (pgsize1_tid0_valid='1') 
              else "000";
derat_taken_d  <=  '1' when derat_req_taken_sig='1' 
            else '0' when ierat_req_taken_sig <= '1'
            else derat_taken_q;
-- ttype: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
tlb_read_req  <=  '1' when (ex1_valid_q(0 to 3) /= "0000" and ex1_ttype_q(0)='1') else '0';
tlb_write_req  <=  '1' when (ex1_valid_q(0 to 3) /= "0000" and ex1_ttype_q(1)='1') else '0';
tlb_search_req  <=  '1' when (ex2_valid_q(0 to 3) /= "0000" and ex2_ttype_q(2 to 3)/="00") else '0';
tlb_searchresv_req  <=  '1' when (ex2_valid_q(0 to 3) /= "0000" and ex2_ttype_q(4)='1') else '0';
tlb_seq_idle_sig  <=  '1' when tlb_seq_q=TlbSeq_Idle else '0';
tlbwe_back_inv_holdoff  <=   tlbwe_back_inv_pending and mmucr1_tlbwe_binv;
tlb_seq_any_done_sig  <=  tlb_seq_ierat_done_sig or tlb_seq_derat_done_sig or tlb_seq_snoop_done_sig or 
                         tlb_seq_search_done_sig or tlb_seq_searchresv_done_sig or tlb_seq_read_done_sig or 
                         tlb_seq_write_done_sig or tlb_seq_ptereload_done_sig;
any_tlb_req_sig  <=  snoop_val_q(0) or ptereload_req_valid or tlb_seq_ierat_req or tlb_seq_derat_req or
                   tlb_search_req or tlb_searchresv_req or tlb_write_req or tlb_read_req;
any_req_taken_sig  <=  ierat_req_taken_sig or derat_req_taken_sig or snoop_req_taken_sig or 
       search_req_taken_sig or searchresv_req_taken_sig or read_req_taken_sig or 
       write_req_taken_sig or ptereload_req_taken_sig;
tlb_tag4_hit_or_parerr  <=   tlb_tag4_cmp_hit or tlb_tag4_parerr;
-- abort control sequencer back to state_idle
--   tlbsx, tlbsrx, tlbre, tlbwe are flushable ops, so short-cycle sequencer
tlb_seq_abort  <=   or_reduce( tlb_tag0_q(tagpos_thdid to tagpos_thdid+thdid_width-1) 
                     and (tlb_ctl_tag1_flush_sig or tlb_ctl_tag2_flush_sig or tlb_ctl_tag3_flush_sig or tlb_ctl_tag4_flush_sig) );
tlb_seq_d  <=  tlb_seq_next and (0 to 5 => not(tlb_seq_abort));
-- TLB access sequencer for multiple page size compares for reloads
Tlb_Sequencer: PROCESS (tlb_seq_q, tlb_tag0_q(tagpos_is+1 to tagpos_is+3), tlb_tag0_q(tagpos_size to tagpos_size+3), tlb_tag0_q(tagpos_type to tagpos_type+7), 
                          tlb_tag0_q(tagpos_type to tagpos_type+7), tlb_tag1_q(tagpos_endflag), tlb_tag0_tid_notzero, 
                          tlb_tag4_hit_or_parerr, tlb_tag4_way_ind, tlb_addr_maxcntm1, tlb_cmp_erat_dup_wait,
                          tlb_seq_ierat_req, tlb_seq_derat_req, tlb_search_req, tlb_searchresv_req, 
                          snoop_val_q(0), tlb_read_req, tlb_write_req, ptereload_req_valid, mmucr2(12 to 31), derat_taken_q,
                          tlb_hashed_addr1, tlb_hashed_addr2, tlb_hashed_addr3, tlb_hashed_addr4, tlb_hashed_addr5, 
                          tlb_hashed_tid0_addr1, tlb_hashed_tid0_addr2, tlb_hashed_tid0_addr3, tlb_hashed_tid0_addr4, tlb_hashed_tid0_addr5, 
                          pgsize2_valid, pgsize3_valid, pgsize4_valid, pgsize5_valid,
                          pgsize2_tid0_valid, pgsize3_tid0_valid, pgsize4_tid0_valid, pgsize5_tid0_valid,
                          size_1M_hashed_addr,size_1M_hashed_tid0_addr,size_256M_hashed_addr,size_256M_hashed_tid0_addr,
                          tlb_tag0_hashed_addr, tlb_tag0_hashed_tid0_addr, tlb0cfg_ind, tlbwe_back_inv_holdoff)
BEGIN
tlb_seq_addr  <=  (others => '0');
tlb_seq_pgsize  <=  mmucr2(28 to 31);
tlb_seq_ind  <=  '0';
tlb_seq_esel  <=  (others => '0');
tlb_seq_is  <=  (others => '0');
tlb_seq_tag0_addr_cap  <=  '0';
tlb_seq_addr_update  <=  '0';
tlb_seq_addr_clr  <=  '0';
tlb_seq_addr_incr  <=  '0';
tlb_seq_lrat_enable  <=  '0';
tlb_seq_endflag  <=  '0';
tlb_seq_ierat_done_sig  <=  '0';
tlb_seq_derat_done_sig  <=  '0';
tlb_seq_snoop_done_sig  <=  '0';
tlb_seq_search_done_sig  <=  '0';
tlb_seq_searchresv_done_sig  <=  '0';
tlb_seq_read_done_sig  <=  '0';
tlb_seq_write_done_sig  <=  '0';
tlb_seq_ptereload_done_sig  <=  '0';
ierat_req_taken_sig  <=  '0';
derat_req_taken_sig  <=  '0';
search_req_taken_sig  <=  '0';
searchresv_req_taken_sig  <=  '0';
snoop_req_taken_sig  <=  '0';
read_req_taken_sig  <=  '0';
write_req_taken_sig  <=  '0';
ptereload_req_taken_sig  <=  '0';
tlb_seq_set_resv  <=  '0';
tlb_seq_snoop_resv  <=  '0';
CASE tlb_seq_q IS
        WHEN TlbSeq_Idle =>
          if snoop_val_q(0)='1' then 
                    tlb_seq_next <=  TlbSeq_Stg24; snoop_req_taken_sig <= '1'; 
          elsif ptereload_req_valid='1' then 
                    tlb_seq_next <=  TlbSeq_Stg19; ptereload_req_taken_sig <= '1'; 
          elsif tlb_seq_ierat_req='1' and tlb_cmp_erat_dup_wait(0)='0' and (derat_taken_q='1' or tlb_seq_derat_req='0') then
                    tlb_seq_next <=  TlbSeq_Stg1; ierat_req_taken_sig <= '1'; 
          elsif tlb_seq_derat_req='1' and tlb_cmp_erat_dup_wait(1)='0' then
                    tlb_seq_next <=  TlbSeq_Stg1; derat_req_taken_sig <= '1';
          elsif tlb_search_req='1' then 
                    tlb_seq_next <=  TlbSeq_Stg1; search_req_taken_sig <= '1'; 
          elsif tlb_searchresv_req='1' then 
                    tlb_seq_next <=  TlbSeq_Stg1; searchresv_req_taken_sig <= '1'; 
          elsif (tlb_write_req='1' and tlbwe_back_inv_holdoff='0') then   
                    tlb_seq_next <=  TlbSeq_Stg19; write_req_taken_sig <= '1'; 
          elsif tlb_read_req='1' then 
                    tlb_seq_next <=  TlbSeq_Stg19; read_req_taken_sig <= '1'; 
          else
                    tlb_seq_next <=  TlbSeq_Idle;
          end if;  
        WHEN TlbSeq_Stg1 =>
          tlb_seq_tag0_addr_cap <= '1';  
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= tlb_hashed_addr1;  
          tlb_seq_pgsize <= mmucr2(28 to 31); 
          tlb_seq_is <= "00";  
          tlb_seq_esel <= "001";  
          if pgsize2_valid='1' then
           tlb_seq_next <=  TlbSeq_Stg2;
          else 
           tlb_seq_next <=  TlbSeq_Stg6;
          end if;

        WHEN TlbSeq_Stg2 =>
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= tlb_hashed_addr2;  
          tlb_seq_pgsize <= mmucr2(24 to 27);
          tlb_seq_is <= "00";  
          tlb_seq_esel <= "010";  
          if pgsize3_valid='1' then
           tlb_seq_next <=  TlbSeq_Stg3;
          else 
           tlb_seq_next <=  TlbSeq_Stg6;
          end if;

        WHEN TlbSeq_Stg3 =>
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= tlb_hashed_addr3;  
          tlb_seq_pgsize <= mmucr2(20 to 23);
          tlb_seq_is <= "00";  
          tlb_seq_esel <= "011";  
          if pgsize4_valid='1' then
           tlb_seq_next <=  TlbSeq_Stg4;
          else 
           tlb_seq_next <=  TlbSeq_Stg6;
          end if;

        WHEN TlbSeq_Stg4 =>
          tlb_seq_addr_update <= '1';
          tlb_seq_addr <= tlb_hashed_addr4;  
          tlb_seq_pgsize <= mmucr2(16 to 19);
          tlb_seq_is <= "00";  
          tlb_seq_esel <= "100";  
          if pgsize5_valid='1' then
           tlb_seq_next <=  TlbSeq_Stg5;
          else 
           tlb_seq_next <=  TlbSeq_Stg6;
          end if;

        WHEN TlbSeq_Stg5 =>
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= tlb_hashed_addr5;  
          tlb_seq_pgsize <= mmucr2(12 to 15);
          tlb_seq_is <= "00";  
          tlb_seq_esel <= "101";  
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
            tlb_seq_next <=  TlbSeq_Stg31;
          else
            tlb_seq_next <=  TlbSeq_Stg6;
          end if;
        WHEN TlbSeq_Stg6 =>
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= tlb_hashed_tid0_addr1;  
          tlb_seq_pgsize <= mmucr2(28 to 31);
          tlb_seq_is <= "01";  
          tlb_seq_esel <= "001";  
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          elsif pgsize2_tid0_valid='1' then
           tlb_seq_next <=  TlbSeq_Stg7;
          elsif tlb0cfg_ind='1' then   
           tlb_seq_next <=  TlbSeq_Stg11; 
          else
           tlb_seq_endflag <= '1';
           tlb_seq_next <=  TlbSeq_Stg15; 
          end if;

        WHEN TlbSeq_Stg7 =>
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= tlb_hashed_tid0_addr2;  
          tlb_seq_pgsize <= mmucr2(24 to 27);
          tlb_seq_is <= "01";  
          tlb_seq_esel <= "010";  
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          elsif pgsize3_tid0_valid='1' then
           tlb_seq_next <=  TlbSeq_Stg8;
          elsif tlb0cfg_ind='1' then   
           tlb_seq_next <=  TlbSeq_Stg11; 
          else
           tlb_seq_endflag <= '1';
           tlb_seq_next <=  TlbSeq_Stg15; 
          end if;

        WHEN TlbSeq_Stg8 =>
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= tlb_hashed_tid0_addr3;  
          tlb_seq_pgsize <= mmucr2(20 to 23);
          tlb_seq_is <= "01";  
          tlb_seq_esel <= "011";  
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          elsif pgsize4_tid0_valid='1' then
           tlb_seq_next <=  TlbSeq_Stg9;
          elsif tlb0cfg_ind='1' then   
           tlb_seq_next <=  TlbSeq_Stg11; 
          else
           tlb_seq_endflag <= '1';
           tlb_seq_next <=  TlbSeq_Stg15; 
          end if;


        WHEN TlbSeq_Stg9 =>
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= tlb_hashed_tid0_addr4;  
          tlb_seq_pgsize <= mmucr2(16 to 19);
          tlb_seq_is <= "01";  
          tlb_seq_esel <= "100";  
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          elsif pgsize5_tid0_valid='1' then
           tlb_seq_next <=  TlbSeq_Stg10;
          elsif tlb0cfg_ind='1' then   
           tlb_seq_next <=  TlbSeq_Stg11; 
          else
           tlb_seq_endflag <= '1';
           tlb_seq_next <=  TlbSeq_Stg15; 
          end if;


        WHEN TlbSeq_Stg10 =>
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= tlb_hashed_tid0_addr5;  
          tlb_seq_pgsize <= mmucr2(12 to 15);
          tlb_seq_is <= "01";  
          tlb_seq_esel <= "101";  
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          elsif tlb0cfg_ind='1' then   
           tlb_seq_next <=  TlbSeq_Stg11; 
          else
           tlb_seq_endflag <= '1';
           tlb_seq_next <=  TlbSeq_Stg15; 
          end if;

        WHEN TlbSeq_Stg11 =>
          tlb_seq_ind <= '1';
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= size_1M_hashed_addr;  
          tlb_seq_pgsize <= TLB_PgSize_1MB;
          tlb_seq_is <= "10";  
          tlb_seq_esel <= "001";  
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          else 
           tlb_seq_next <=  TlbSeq_Stg12;
          end if;

        WHEN TlbSeq_Stg12 =>
          tlb_seq_ind <= '1';
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= size_256M_hashed_addr;  
          tlb_seq_pgsize <= TLB_PgSize_256MB;
          tlb_seq_is <= "10";  
          tlb_seq_esel <= "010";  
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          else 
           tlb_seq_next <=  TlbSeq_Stg13;
          end if;

        WHEN TlbSeq_Stg13 =>
          tlb_seq_ind <= '1';
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= size_1M_hashed_tid0_addr;  
          tlb_seq_pgsize <= TLB_PgSize_1MB;
          tlb_seq_is <= "11";  
          tlb_seq_esel <= "001";  
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          else 
           tlb_seq_next <=  TlbSeq_Stg14;
          end if;

        WHEN TlbSeq_Stg14 =>
          tlb_seq_ind <= '1';
          tlb_seq_addr_update <= '1';  
          tlb_seq_addr <= size_256M_hashed_tid0_addr;  
          tlb_seq_pgsize <= TLB_PgSize_256MB;
          tlb_seq_is <= "11";  
          tlb_seq_esel <= "010";  
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          else 
           tlb_seq_endflag <= '1';  
           tlb_seq_next <=  TlbSeq_Stg15;
          end if;

        WHEN TlbSeq_Stg15 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='1' and 
                   or_reduce(tlb_tag0_q(tagpos_type_derat to tagpos_type_ierat))='1' and tlb_tag0_q(tagpos_type_ptereload)='0' then  
              tlb_seq_next <=  TlbSeq_Stg29;  
          else 
           tlb_seq_next <=  TlbSeq_Stg16;
          end if;

        WHEN TlbSeq_Stg16 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='1' then 
              tlb_seq_next <=  TlbSeq_Stg29;  
          else 
           tlb_seq_next <=  TlbSeq_Stg17;
          end if;

        WHEN TlbSeq_Stg17 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='1' then 
              tlb_seq_next <=  TlbSeq_Stg29;  
          else 
           tlb_seq_next <=  TlbSeq_Stg18;
          end if;

        WHEN TlbSeq_Stg18 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          if tlb_tag4_hit_or_parerr='1' and or_reduce(tlb_tag0_q(tagpos_type_tlbsx to tagpos_type_tlbsrx))='1' then  
            tlb_seq_next <=  TlbSeq_Stg30;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='0' then  
              tlb_seq_next <=  TlbSeq_Stg31;
          elsif tlb_tag4_hit_or_parerr='1' and tlb_tag4_way_ind='1' then 
              tlb_seq_next <=  TlbSeq_Stg29;  
          else 
           tlb_seq_next <=  TlbSeq_Stg30; 
          end if;

        WHEN TlbSeq_Stg19 =>
          tlb_seq_pgsize <= tlb_tag0_q(tagpos_size to tagpos_size+3);
          tlb_seq_tag0_addr_cap <= '1';
          tlb_seq_addr_update <= '1';  
          if tlb_tag0_tid_notzero='1' then
            tlb_seq_addr <= tlb_tag0_hashed_addr;  
          else 
            tlb_seq_addr <= tlb_tag0_hashed_tid0_addr;
          end if;
          tlb_seq_next <=  TlbSeq_Stg20;

        WHEN TlbSeq_Stg20 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
           tlb_seq_next <=  TlbSeq_Stg21;

        WHEN TlbSeq_Stg21 =>
          tlb_seq_lrat_enable <= tlb_tag0_q(tagpos_type_tlbwe) or tlb_tag0_q(tagpos_type_ptereload); 
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          tlb_seq_next <=  TlbSeq_Stg22;

        WHEN TlbSeq_Stg22 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          tlb_seq_next <=  TlbSeq_Stg23;

        WHEN TlbSeq_Stg23 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          tlb_seq_read_done_sig <= tlb_tag0_q(tagpos_type_tlbre); 
          tlb_seq_write_done_sig <= tlb_tag0_q(tagpos_type_tlbwe); 
          tlb_seq_ptereload_done_sig  <= tlb_tag0_q(tagpos_type_ptereload);
          if tlb_tag0_q(tagpos_type_tlbre)='1' or tlb_tag0_q(tagpos_type_tlbwe)='1' then 
             tlb_seq_next <=  TlbSeq_Idle;  
          else 
             tlb_seq_next <=  TlbSeq_Stg31; 
          end if;


        WHEN TlbSeq_Stg24 =>
          tlb_seq_pgsize <= tlb_tag0_q(tagpos_size to tagpos_size+3);
          tlb_seq_tag0_addr_cap <= '1'; 
          tlb_seq_snoop_resv <= '1';
          if (tlb_tag0_q(tagpos_is+1 to tagpos_is+3)="011") then  
            tlb_seq_addr_update <= '1';  
            tlb_seq_addr_clr <= '0'; 
            tlb_seq_endflag <= '1';
          else 
            tlb_seq_addr_update <= '0';  
            tlb_seq_addr_clr <= '1'; 
            tlb_seq_endflag <= '0'; 
          end if;
          if tlb_tag0_tid_notzero='1' then
            tlb_seq_addr <= tlb_tag0_hashed_addr;  
          else 
            tlb_seq_addr <= tlb_tag0_hashed_tid0_addr;
          end if;
          tlb_seq_next <=  TlbSeq_Stg25;

        WHEN TlbSeq_Stg25 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          if (tlb_tag0_q(tagpos_is+1 to tagpos_is+3)="011") then  
            tlb_seq_addr_incr <= '0';
            tlb_seq_endflag <= '0';
          else 
            tlb_seq_addr_incr <= '1'; 
            tlb_seq_endflag <= tlb_addr_maxcntm1;
          end if;             
          if tlb_tag0_q(tagpos_is+1 to tagpos_is+3)/="011" and tlb_tag1_q(tagpos_endflag)='0' then
            tlb_seq_next <=  TlbSeq_Stg25;  
          else 
            tlb_seq_next <=  TlbSeq_Stg26;  
          end if;

        WHEN TlbSeq_Stg26 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          tlb_seq_next <=  TlbSeq_Stg27;

        WHEN TlbSeq_Stg27 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          tlb_seq_next <=  TlbSeq_Stg28;

        WHEN TlbSeq_Stg28 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          tlb_seq_next <=  TlbSeq_Stg31; 
        WHEN TlbSeq_Stg29 =>
          tlb_seq_derat_done_sig      <= tlb_tag0_q(tagpos_type_derat) and not tlb_tag0_q(tagpos_type_ptereload);
          tlb_seq_ierat_done_sig      <= tlb_tag0_q(tagpos_type_ierat) and not tlb_tag0_q(tagpos_type_ptereload);
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          tlb_seq_next <=  TlbSeq_Idle; 

        WHEN TlbSeq_Stg30 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          tlb_seq_derat_done_sig      <= tlb_tag0_q(tagpos_type_derat) and not tlb_tag0_q(tagpos_type_ptereload);
          tlb_seq_ierat_done_sig      <= tlb_tag0_q(tagpos_type_ierat) and not tlb_tag0_q(tagpos_type_ptereload);
          tlb_seq_search_done_sig     <= tlb_tag0_q(tagpos_type_tlbsx); 
          tlb_seq_searchresv_done_sig <= tlb_tag0_q(tagpos_type_tlbsrx); 
          tlb_seq_snoop_done_sig      <= tlb_tag0_q(tagpos_type_snoop);          
          tlb_seq_set_resv            <= tlb_tag0_q(tagpos_type_tlbsrx);   

          tlb_seq_next <=  TlbSeq_Idle;


        WHEN TlbSeq_Stg31 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          tlb_seq_derat_done_sig      <= tlb_tag0_q(tagpos_type_derat) and not tlb_tag0_q(tagpos_type_ptereload);
          tlb_seq_ierat_done_sig      <= tlb_tag0_q(tagpos_type_ierat) and not tlb_tag0_q(tagpos_type_ptereload);
          tlb_seq_search_done_sig     <= tlb_tag0_q(tagpos_type_tlbsx); 
          tlb_seq_searchresv_done_sig <= tlb_tag0_q(tagpos_type_tlbsrx); 
          tlb_seq_snoop_done_sig      <= tlb_tag0_q(tagpos_type_snoop);          
          tlb_seq_set_resv            <= tlb_tag0_q(tagpos_type_tlbsrx);   

          if (tlb_tag0_q(tagpos_type_ierat)='1' or tlb_tag0_q(tagpos_type_derat)='1' 
                 or tlb_tag0_q(tagpos_type_ptereload)='1') then
            tlb_seq_next <=  TlbSeq_Stg32; 
          else 
            tlb_seq_next <=  TlbSeq_Idle; 
          end if;

        WHEN TlbSeq_Stg32 =>
          tlb_seq_addr <= (others => '0');  
          tlb_seq_pgsize <= (others => '0');
          tlb_seq_next <=  TlbSeq_Idle;

        WHEN OTHERS =>
          tlb_seq_next <=  TlbSeq_Idle;  

    END CASE;
END PROCESS Tlb_Sequencer;
ierat_req_taken     <=  ierat_req_taken_sig;
derat_req_taken     <=  derat_req_taken_sig;
tlb_seq_ierat_done  <=  tlb_seq_ierat_done_sig;
tlb_seq_derat_done  <=  tlb_seq_derat_done_sig;
ptereload_req_taken  <=  ptereload_req_taken_sig;
tlb_seq_idle  <=  tlb_seq_idle_sig;
-- snoop_val: 0 -> valid, 1 -> ack
snoop_val_d(0) <=  tlb_snoop_val when snoop_val_q(0)='0'
           else '0' when snoop_req_taken_sig='1'
           else snoop_val_q(0);
snoop_val_d(1) <=  tlb_seq_snoop_done_sig;
tlb_snoop_ack  <=  snoop_val_q(1);
-- snoop_attr:
--          0 -> Local
--        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
--        4:5 -> GS/TS
--       6:13 -> TID(6:13)
--      14:17 -> Size
--      18    -> reserved for tlb, extclass_enable(0) for erats
--      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
--      20:25 -> TID(0:5)
--      26:33 -> LPID
--      34    -> IND
snoop_attr_d  <=  tlb_snoop_attr when snoop_val_q(0)='0'
           else snoop_attr_q;
snoop_vpn_d(52-epn_width TO 51) <=  tlb_snoop_vpn when snoop_val_q(0)='0'
           else snoop_vpn_q(52-epn_width to 51);
ptereload_req_pte_d  <=  ptereload_req_pte when ptereload_req_taken_sig='1'
           else ptereload_req_pte_q;
ptereload_req_pte_lat  <=  ptereload_req_pte_q;
--tlb_tag0_d <= ( 0:51   epn &
--                52:65  pid &
--                66:67  IS &
--                68:69  Class &
--                70:73  state (pr,gs,as,cm) &
--                74:77  thdid &
--                78:81  size &
--                82:83  derat_miss/ierat_miss &
--                84:85  tlbsx/tlbsrx &
--                86:87  inval_snoop/tlbre &
--                88:89  tlbwe/ptereload &
--                90:97  lpid &
--                98  indirect
--                99  atsel &
--                100:102  esel &
--                103:105  hes/wq(0:1) &
--                106:107  lrat/pt &
--                108  record form
--                109  endflag
--  tagpos_epn      : natural  := 0;
--  tagpos_pid      : natural  := 52; -- 14 bits
--  tagpos_is       : natural  := 66;
--  tagpos_class    : natural  := 68;
--  tagpos_state    : natural  := 70; -- state: 0:pr 1:gs 2:as 3:cm
--  tagpos_thdid    : natural  := 74;
--  tagpos_size     : natural  := 78;
--  tagpos_type    : natural  := 82; -- derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
--  tagpos_lpid     : natural  := 90;
--  tagpos_ind      : natural  := 98;
--  tagpos_atsel    : natural  := 99;
--  tagpos_esel     : natural  := 100;
--  tagpos_hes      : natural  := 103;
--  tagpos_wq       : natural  := 104;
--  tagpos_lrat     : natural  := 106;
--  tagpos_pt       : natural  := 107;
--  tagpos_recform  : natural  := 108;
--  tagpos_endflag  : natural  := 109;
-- snoop_attr:
--          0 -> Local
--        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
--        4:5 -> GS/TS
--       6:13 -> TID(6:13)
--      14:17 -> Size
--      18    -> reserved for tlb, extclass_enable(0) for erats
--      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
--      20:25 -> TID(0:5)
--      26:33 -> LPID
--      34    -> IND
-- TAG PHASE (q)  DESCRPTION                      OPERATION / EXn
-- -1    prehash arb                tlbwe ex1  tlbre ex1  tlbsx ex2   tlbsrx ex2
--  0    hash calc                  tlbwe ex2  tlbre ex2  tlbsx ex3   tlbsrx ex3
--  1    tlb/lru cc addr            tlbwe ex3  tlbre ex3  tlbsx ex4   tlbsrx ex4
--  2    tlb/lru data out           tlbwe ex4  tlbre ex4  tlbsx ex5   tlbsrx ex5
--  3    comp & select              tlbwe ex5  tlbre ex5  tlbsx ex6   tlbsrx ex6
--  4    tlb/lru/mas update         tlbwe ex6  tlbre ex6  tlbsx ex7   tlbsrx ex7
--  5    erat reload
tlb_ctl_tag1_flush_sig      <=  ex3_flush_q when (tlb_tag0_q(tagpos_type_tlbre)='1' or tlb_tag0_q(tagpos_type_tlbwe)='1')
                         else ex4_flush_q when (tlb_tag0_q(tagpos_type_tlbsx)='1' or tlb_tag0_q(tagpos_type_tlbsrx)='1')
                         else (others => '0');
tlb_ctl_tag2_flush_sig      <=  ex4_flush_q when (tlb_tag0_q(tagpos_type_tlbre)='1' or tlb_tag0_q(tagpos_type_tlbwe)='1')
                         else ex5_flush_q when (tlb_tag0_q(tagpos_type_tlbsx)='1' or tlb_tag0_q(tagpos_type_tlbsrx)='1')
                         else (others => '0');
tlb_ctl_tag3_flush_sig      <=  ex5_flush_q when (tlb_tag0_q(tagpos_type_tlbre)='1' or tlb_tag0_q(tagpos_type_tlbwe)='1')
                         else ex6_flush_q when (tlb_tag0_q(tagpos_type_tlbsx)='1' or tlb_tag0_q(tagpos_type_tlbsrx)='1')
                         else (others => '0');
tlb_ctl_tag4_flush_sig      <=  ex6_flush_q when (tlb_tag0_q(tagpos_type_tlbre)='1' or tlb_tag0_q(tagpos_type_tlbwe)='1')
                         else (others => '0');
tlb_ctl_any_tag_flush_sig  <=  or_reduce(tlb_ctl_tag1_flush_sig or tlb_ctl_tag2_flush_sig or tlb_ctl_tag3_flush_sig or tlb_ctl_tag4_flush_sig);
tlb_ctl_tag2_flush  <=  tlb_ctl_tag2_flush_sig or tlb_ctl_tag3_flush_sig or tlb_ctl_tag4_flush_sig;
tlb_ctl_tag3_flush  <=  tlb_ctl_tag3_flush_sig or tlb_ctl_tag4_flush_sig;
tlb_ctl_tag4_flush  <=  tlb_ctl_tag4_flush_sig;
--                        0     1     2     3      4     5     6     7
--     tag type bits --> derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
--  tag -1 phase, tlbwe/re ex1, tlbsx/srx ex2
tlb_tag0_d(tagpos_type_derat) <=  (derat_req_taken_sig)
                         or (ptereload_req_tag(tagpos_type_derat) and ptereload_req_taken_sig) 
                         or (tlb_tag0_q(tagpos_type_derat) and not tlb_seq_any_done_sig and not tlb_seq_abort);
tlb_tag0_d(tagpos_type_ierat) <=  (ierat_req_taken_sig)
                         or (ptereload_req_tag(tagpos_type_ierat) and ptereload_req_taken_sig) 
                         or (tlb_tag0_q(tagpos_type_ierat) and not tlb_seq_any_done_sig and not tlb_seq_abort);
tlb_tag0_d(tagpos_type_tlbsx) <=  (search_req_taken_sig)
                         or (tlb_tag0_q(tagpos_type_tlbsx) and not tlb_seq_any_done_sig and not tlb_seq_abort);
tlb_tag0_d(tagpos_type_tlbsrx) <=  (searchresv_req_taken_sig)
                         or (tlb_tag0_q(tagpos_type_tlbsrx) and not tlb_seq_any_done_sig and not tlb_seq_abort);
tlb_tag0_d(tagpos_type_snoop) <=  (snoop_req_taken_sig)
                         or (tlb_tag0_q(tagpos_type_snoop) and not tlb_seq_any_done_sig and not tlb_seq_abort);
tlb_tag0_d(tagpos_type_tlbre) <=  (read_req_taken_sig)
                         or (tlb_tag0_q(tagpos_type_tlbre) and not tlb_seq_any_done_sig and not tlb_seq_abort);
tlb_tag0_d(tagpos_type_tlbwe) <=  (write_req_taken_sig)
                         or (tlb_tag0_q(tagpos_type_tlbwe) and not tlb_seq_any_done_sig and not tlb_seq_abort);
tlb_tag0_d(tagpos_type_ptereload) <=  (ptereload_req_taken_sig)
                         or (tlb_tag0_q(tagpos_type_ptereload) and not tlb_seq_any_done_sig and not tlb_seq_abort);
-- state: 0:pr 1:gs 2:as 3:cm
gen64_tag_epn: if rs_data_width = 64 generate
tlb_tag0_d(tagpos_epn TO tagpos_epn+epn_width-1) <=  
            ( ptereload_req_tag(tagpos_epn to tagpos_epn+epn_width-1) and (tagpos_epn to tagpos_epn+epn_width-1 => ptereload_req_taken_sig) )
         or ( ((ex1_mas2_epn(0 to 31) and (0 to 31 => ex1_state_q(3))) & ex1_mas2_epn(32 to epn_width-1))  and (tagpos_epn to tagpos_epn+epn_width-1 => write_req_taken_sig) )
         or ( ((ex1_mas2_epn(0 to 31) and (0 to 31 => ex1_state_q(3))) & ex1_mas2_epn(32 to epn_width-1))  and (tagpos_epn to tagpos_epn+epn_width-1 => read_req_taken_sig) )
         or ( snoop_vpn_q    and (tagpos_epn to tagpos_epn+epn_width-1 => snoop_req_taken_sig) )
         or ( xu_mm_ex2_epn   and (tagpos_epn to tagpos_epn+epn_width-1 => searchresv_req_taken_sig) )
         or ( xu_mm_ex2_epn   and (tagpos_epn to tagpos_epn+epn_width-1 => search_req_taken_sig) )
         or ( ierat_req_epn  and (tagpos_epn to tagpos_epn+epn_width-1 => ierat_req_taken_sig) )
         or ( derat_req_epn  and (tagpos_epn to tagpos_epn+epn_width-1 => derat_req_taken_sig) )
         or ( tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1) and (tagpos_epn to tagpos_epn+epn_width-1 => not any_req_taken_sig) );
end generate gen64_tag_epn;
gen32_tag_epn: if rs_data_width = 32 generate
tlb_tag0_d(tagpos_epn TO tagpos_epn+epn_width-1) <=  
            ( ptereload_req_tag(tagpos_epn to tagpos_epn+epn_width-1) and (0 to epn_width-1 => ptereload_req_taken_sig) )
         or ( ex1_mas2_epn(52-epn_width to 51)   and (0 to epn_width-1 => write_req_taken_sig) )
         or ( ex1_mas2_epn(52-epn_width to 51)   and (0 to epn_width-1 => read_req_taken_sig) )
         or ( snoop_vpn_q(52-epn_width to 51)    and (0 to epn_width-1 => snoop_req_taken_sig) )
         or ( xu_mm_ex2_epn(52-epn_width to 51)   and (0 to epn_width-1 => searchresv_req_taken_sig) )
         or ( xu_mm_ex2_epn(52-epn_width to 51)   and (0 to epn_width-1 => search_req_taken_sig) )
         or ( ierat_req_epn(52-epn_width to 51)  and (0 to epn_width-1 => ierat_req_taken_sig) )
         or ( derat_req_epn(52-epn_width to 51)  and (0 to epn_width-1 => derat_req_taken_sig) )
         or ( tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1) and (0 to epn_width-1 => not any_req_taken_sig) );
end generate gen32_tag_epn;
-- snoop_attr:
--          0 -> Local
--        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
--        4:5 -> GS/TS
--       6:13 -> TID(6:13)
--      14:17 -> Size
--      18    -> reserved for tlb, extclass_enable(0) for erats
--      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
--      20:25 -> TID(0:5)
--      26:33 -> LPID
--      34    -> IND
tlb_tag0_d(tagpos_pid TO tagpos_pid+pid_width-1) <=  
             ( ptereload_req_tag(tagpos_pid to tagpos_pid+pid_width-1) and (0 to pid_width-1 => ptereload_req_taken_sig) )
         or ( ex1_mas1_tid   and (0 to pid_width-1 => write_req_taken_sig) )
         or ( ex1_mas1_tid   and (0 to pid_width-1 => read_req_taken_sig) )
         or ( snoop_attr_q(20 to 25) & snoop_attr_q(6 to 13) and (0 to pid_width-1 => snoop_req_taken_sig) )
         or ( ex2_mas1_tid         and (0 to pid_width-1 => searchresv_req_taken_sig) )
         or ( ex2_mas6_spid         and (0 to pid_width-1 => search_req_taken_sig) )
         or ( ierat_req_pid          and (0 to pid_width-1 => ierat_req_taken_sig) )
         or ( derat_req_pid          and (0 to pid_width-1 => derat_req_taken_sig) )
         or ( tlb_tag0_q(tagpos_pid to tagpos_pid+pid_width-1)  and (0 to pid_width-1 => not any_req_taken_sig) );
-- snoop_attr: 0 -> Local
-- snoop_attr: 1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=vpn, 4=class0, 5=class1, 6=class2, 7=class3
--  unused tagpos_is def is mas1_v, mas1_iprot for tlbwe, and is (pte.valid & 0) for ptereloads
tlb_tag0_d(tagpos_is TO tagpos_is+1) <=  
         ((ptereload_req_pte(ptepos_valid) & ptereload_req_tag(tagpos_is+1)) and (0 to 1 => ptereload_req_taken_sig)) 
     or ((ex1_mas1_v & ex1_mas1_iprot) and (0 to 1 => write_req_taken_sig)) 
     or (snoop_attr_q(0 to 1) and (0 to 1 => snoop_req_taken_sig))   
     or (tlb_tag0_q(tagpos_is to tagpos_is+1) and (0 to 1 => not any_req_taken_sig));
tlb_tag0_d(tagpos_class TO tagpos_class+1) <=  
          (ptereload_req_tag(tagpos_class to tagpos_class+1) and (0 to 1 => ptereload_req_taken_sig))
       or (ex1_mmucr3_class and (0 to 1 => write_req_taken_sig))
       or (snoop_attr_q(2 to 3) and (0 to 1 => snoop_req_taken_sig))   
       or (derat_req_ttype and (0 to 1 => derat_req_taken_sig))  
       or (tlb_tag0_q(tagpos_class to tagpos_class+1) and (0 to 1 => not any_req_taken_sig));
-- state: 0:pr 1:gs 2:as 3:cm
tlb_tag0_d(tagpos_state TO tagpos_state+state_width-1) <=  
         (ptereload_req_tag(tagpos_state to tagpos_state+state_width-1) and (0 to state_width-1 => ptereload_req_taken_sig))
         or (ex1_state_q(0 to 3) and (0 to state_width-1 => write_req_taken_sig))  
         or (ex1_state_q(0 to 3) and (0 to state_width-1 => read_req_taken_sig))
         or (('0' & snoop_attr_q(4 to 5) & '0') and (0 to state_width-1 => snoop_req_taken_sig))
         or (ex2_mas5_1_state and (0 to state_width-1 => searchresv_req_taken_sig))   
         or (ex2_mas5_6_state and (0 to state_width-1 => search_req_taken_sig))       
         or (ierat_req_state and (0 to state_width-1 => ierat_req_taken_sig))
         or (derat_req_state and (0 to state_width-1 => derat_req_taken_sig))
         or (tlb_tag0_q(tagpos_state to tagpos_state+state_width-1) and (0 to state_width-1 => not any_req_taken_sig));
tlb_tag0_d(tagpos_thdid TO tagpos_thdid+thdid_width-1) <=  
         (ptereload_req_tag(tagpos_thdid to tagpos_thdid+thdid_width-1) and (0 to thdid_width-1 => ptereload_req_taken_sig))
         or (ex1_valid_q     and (0 to thdid_width-1 => write_req_taken_sig))
         or (ex1_valid_q     and (0 to thdid_width-1 => read_req_taken_sig))
         or ("1111"          and (0 to thdid_width-1 => snoop_req_taken_sig))
         or (ex2_valid_q     and (0 to thdid_width-1 => searchresv_req_taken_sig))
         or (ex2_valid_q     and (0 to thdid_width-1 => search_req_taken_sig))
         or (ierat_req_thdid and (0 to thdid_width-1 => ierat_req_taken_sig))
         or (derat_req_thdid and (0 to thdid_width-1 => derat_req_taken_sig))
         or ( tlb_tag0_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag1_flush_sig)
                   and not(tlb_ctl_tag2_flush_sig) and not(tlb_ctl_tag3_flush_sig) and not(tlb_ctl_tag4_flush_sig)
                   and (0 to thdid_width-1 => (not tlb_seq_any_done_sig and not any_req_taken_sig and not tlb_seq_abort)) );
tlb_tag0_d(tagpos_size TO tagpos_size+3) <=  
         (('0' & ptereload_req_pte(ptepos_size to ptepos_size+2)) and (0 to 3 => ptereload_req_taken_sig))  
         or (ex1_mas1_tsize   and (0 to 3 => write_req_taken_sig))
         or (ex1_mas1_tsize   and (0 to 3 => read_req_taken_sig))
         or (snoop_attr_q(14 to 17)  and (0 to 3 => snoop_req_taken_sig))
         or (mmucr2(28 to 31) and (0 to 3 => searchresv_req_taken_sig))
         or (mmucr2(28 to 31) and (0 to 3 => search_req_taken_sig))
         or (mmucr2(28 to 31) and (0 to 3 => ierat_req_taken_sig))
         or (mmucr2(28 to 31) and (0 to 3 => derat_req_taken_sig))
         or (tlb_tag0_q(tagpos_size to tagpos_size+3) and (0 to 3 => not any_req_taken_sig));
tlb_tag0_d(tagpos_lpid TO tagpos_lpid+lpid_width-1) <=  
         (ptereload_req_tag(tagpos_lpid to tagpos_lpid+lpid_width-1) and (0 to lpid_width-1 => ptereload_req_taken_sig))
         or (ex1_mas8_tlpid  and (0 to lpid_width-1 => write_req_taken_sig))
         or (ex1_mas8_tlpid  and (0 to lpid_width-1 => read_req_taken_sig))
         or (snoop_attr_q(26 to 33) and (0 to lpid_width-1 => snoop_req_taken_sig))
         or (ex2_mas5_slpid   and (0 to lpid_width-1 => searchresv_req_taken_sig))
         or (ex2_mas5_slpid   and (0 to lpid_width-1 => search_req_taken_sig))
         or (lpidr            and (0 to lpid_width-1 => ierat_req_taken_sig))
         or (derat_req_lpid   and (0 to lpid_width-1 => derat_req_taken_sig))
         or (tlb_tag0_q(tagpos_lpid to tagpos_lpid+lpid_width-1) and (0 to lpid_width-1 => not any_req_taken_sig));
tlb_tag0_d(tagpos_ind) <=  
             (ex1_mas1_ind  and write_req_taken_sig)
         or (ex1_mas1_ind  and read_req_taken_sig)
         or (snoop_attr_q(34) and snoop_req_taken_sig)
         or (ex2_mas1_ind  and searchresv_req_taken_sig)
         or (ex2_mas6_sind and search_req_taken_sig)
         or (tlb_tag0_q(tagpos_ind) and not any_req_taken_sig);
tlb_tag0_d(tagpos_atsel) <=  
         (ptereload_req_tag(tagpos_atsel) and ptereload_req_taken_sig)
         or (ex1_mas0_atsel  and write_req_taken_sig)
         or (ex1_mas0_atsel  and read_req_taken_sig)
         or (ex2_mas0_atsel  and searchresv_req_taken_sig)
         or (ex2_mas0_atsel  and search_req_taken_sig)
         or (tlb_tag0_q(tagpos_atsel) and not any_req_taken_sig);
tlb_tag0_d(tagpos_esel TO tagpos_esel+2) <=  
         (ptereload_req_tag(tagpos_esel to tagpos_esel+2) and (0 to 2 => ptereload_req_taken_sig))
         or (ex1_mas0_esel   and (0 to 2 => write_req_taken_sig))
         or (ex1_mas0_esel   and (0 to 2 => read_req_taken_sig))
         or (ex2_mas0_esel and (0 to 2 => searchresv_req_taken_sig))
         or (ex2_mas0_esel and (0 to 2 => search_req_taken_sig))
         or (tlb_tag0_q(tagpos_esel to tagpos_esel+2) and (0 to 2 => not any_req_taken_sig));
tlb_tag0_d(tagpos_hes) <=  
         (ptereload_req_tag(tagpos_hes) and ptereload_req_taken_sig)
         or (ex1_mas0_hes  and write_req_taken_sig)
         or (ex1_mas0_hes  and read_req_taken_sig)
         or (snoop_attr_q(19) and snoop_req_taken_sig)  
         or (ex2_mas0_hes  and searchresv_req_taken_sig)
         or (ex2_mas0_hes  and search_req_taken_sig)
         or (ierat_req_taken_sig)
         or (derat_req_taken_sig)
         or (tlb_tag0_q(tagpos_hes) and not any_req_taken_sig);
tlb_tag0_d(tagpos_wq TO tagpos_wq+1) <=  
         (ptereload_req_tag(tagpos_wq to tagpos_wq+1) and (0 to 1 => ptereload_req_taken_sig)) 
         or (ex1_mas0_wq   and (0 to 1 => write_req_taken_sig))
         or (ex1_mas0_wq   and (0 to 1 => read_req_taken_sig))
         or (ex2_mas0_wq and (0 to 1 => searchresv_req_taken_sig))
         or (ex2_mas0_wq and (0 to 1 => search_req_taken_sig))
         or (ierat_req_dup and (0 to 1 => ierat_req_taken_sig))  
         or (derat_req_dup and (0 to 1 => derat_req_taken_sig))  
         or (tlb_tag0_q(tagpos_wq to tagpos_wq+1) and (0 to 1 => not any_req_taken_sig));
tlb_tag0_d(tagpos_lrat) <=  
         (ptereload_req_tag(tagpos_lrat) and ptereload_req_taken_sig)
         or (mmucfg_lrat  and write_req_taken_sig)
         or (mmucfg_lrat  and read_req_taken_sig)
         or (mmucfg_lrat  and searchresv_req_taken_sig)
         or (mmucfg_lrat  and search_req_taken_sig)
         or (mmucfg_lrat  and ierat_req_taken_sig)
         or (mmucfg_lrat  and derat_req_taken_sig)
         or (tlb_tag0_q(tagpos_lrat) and not any_req_taken_sig);
--  unused tagpos_pt def is mas8_tgs for tlbwe
tlb_tag0_d(tagpos_pt) <=  
         (ptereload_req_tag(tagpos_pt) and ptereload_req_taken_sig)
         or (ex1_mas8_tgs  and write_req_taken_sig)
         or (tlb0cfg_pt  and read_req_taken_sig)
         or (tlb0cfg_pt  and searchresv_req_taken_sig)
         or (tlb0cfg_pt  and search_req_taken_sig)
         or (tlb0cfg_pt  and ierat_req_taken_sig)
         or (tlb0cfg_pt  and derat_req_taken_sig)
         or (tlb_tag0_q(tagpos_pt) and not any_req_taken_sig);
--  unused tagpos_recform def is mas1_ts for tlbwe
tlb_tag0_d(tagpos_recform) <=  
             (ex1_mas1_ts  and write_req_taken_sig)
         or (searchresv_req_taken_sig)   
         or (ex2_ttype_q(3)  and search_req_taken_sig)  
         or (tlb_tag0_q(tagpos_recform) and not any_req_taken_sig);
tlb_tag0_d(tagpos_endflag) <=  '0';
--  tagpos_epn      : natural  := 0;
--  tagpos_pid      : natural  := 52; -- 14 bits
--  tagpos_is       : natural  := 66;
--  tagpos_class    : natural  := 68;
--  tagpos_state    : natural  := 70; -- state: 0:pr 1:gs 2:as 3:cm
--  tagpos_thdid    : natural  := 74;
--  tagpos_size     : natural  := 78;
--  tagpos_type    : natural  := 82; -- derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
--  tagpos_lpid     : natural  := 90;
--  tagpos_ind      : natural  := 98;
--  tagpos_atsel    : natural  := 99;
--  tagpos_esel     : natural  := 100;
--  tagpos_hes      : natural  := 103;
--  tagpos_wq       : natural  := 104;
--  tagpos_lrat     : natural  := 106;
--  tagpos_pt       : natural  := 107;
--  tagpos_recform  : natural  := 108;
--  tagpos_endflag  : natural  := 109;
--ac/q7/vhdl/a2_simwrap_32.vhdl:  constant real_addr_width     : integer := 32;
--ac/q7/vhdl/a2_simwrap.vhdl:     constant real_addr_width     : integer := 42;
--ac/q7/vhdl/a2_simwrap_32.vhdl:  constant epn_width           : integer := 20;
--ac/q7/vhdl/a2_simwrap.vhdl:     constant epn_width           : integer := 52;
-- tag0 phase, tlbwe/re ex2, tlbsx/srx ex3
tlb_tag0_epn(52-epn_width TO 51) <=  tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1);
tlb_tag0_thdid       <=  tlb_tag0_q(tagpos_thdid to tagpos_thdid+thdid_width-1);
tlb_tag0_type        <=  tlb_tag0_q(tagpos_type to tagpos_type+7);
tlb_tag0_lpid        <=  tlb_tag0_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_tag0_atsel       <=  tlb_tag0_q(tagpos_atsel);
tlb_tag0_size        <=  tlb_tag0_q(tagpos_size to tagpos_size+3);
tlb_tag0_addr_cap    <=  tlb_seq_tag0_addr_cap;
tlb_tag1_d(tagpos_epn TO tagpos_epn+epn_width-1) <=  tlb_tag0_q(tagpos_epn to tagpos_epn+epn_width-1);
tlb_tag1_d(tagpos_pid TO tagpos_pid+pid_width-1) <=  tlb_tag0_q(tagpos_pid to tagpos_pid+pid_width-1);
-- maybe needed for timing here and for ptereload_req_pte(ptepos_size) stuff
--  unused tagpos_is def is (pte.valid & 0) for ptereloads
-- unused isel for derat,ierat,tlbsx,tlbsrx becomes page size attempted number msb (9 thru 13, or 17 thru 21)
tlb_tag1_d(tagpos_is TO tagpos_is+1) <=  ((0 to 1 => or_reduce(tlb_tag0_q(tagpos_type_derat to tagpos_type_tlbsrx)) and not tlb_tag0_q(tagpos_type_ptereload)) and tlb_seq_is) or
                                          ((0 to 1 => or_reduce(tlb_tag0_q(tagpos_type_snoop to tagpos_type_ptereload))) and tlb_tag0_q(tagpos_is to tagpos_is+1));
tlb_tag1_d(tagpos_class TO tagpos_class+1) <=  tlb_tag0_q(tagpos_class to tagpos_class+1);
tlb_tag1_d(tagpos_state TO tagpos_state+state_width-1) <=  tlb_tag0_q(tagpos_state to tagpos_state+state_width-1);
tlb_tag1_d(tagpos_thdid TO tagpos_thdid+thdid_width-1) <=  
               (others => '0') when
                                ( tlb_tag4_hit_or_parerr='1' and tlb_tag0_q(tagpos_type_ptereload)='0' and 
                                    (tlb_tag0_q(tagpos_type_ierat)='1' or tlb_tag0_q(tagpos_type_derat)='1' or 
                                            tlb_tag0_q(tagpos_type_tlbsx)='1' or tlb_tag0_q(tagpos_type_tlbsrx)='1') ) or 
                                (tlb_tag4_endflag='1' and tlb_tag0_q(tagpos_type_snoop)='1') or 
                                 tlb_seq_any_done_sig ='1' or tlb_seq_abort='1'
         else tlb_tag0_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag1_flush_sig) and
                   not(tlb_ctl_tag2_flush_sig) and not(tlb_ctl_tag3_flush_sig) and not(tlb_ctl_tag4_flush_sig);
tlb_tag1_d(tagpos_ind) <=  (or_reduce(tlb_tag0_q(tagpos_type_derat to tagpos_type_ierat)) and tlb_seq_ind) or
                           (not or_reduce(tlb_tag0_q(tagpos_type_derat to tagpos_type_ierat)) and tlb_tag0_q(tagpos_ind));
-- unused esel for derat,ierat,tlbsx,tlbsrx becomes page size attempted number (1 thru 5)
tlb_tag1_d(tagpos_esel TO tagpos_esel+2) <=  ((0 to 2 => or_reduce(tlb_tag0_q(tagpos_type_derat to tagpos_type_tlbsrx)) and not tlb_tag0_q(tagpos_type_ptereload)) and tlb_seq_esel) or
                                              ((0 to 2 =>  tlb_tag0_q(tagpos_type_ptereload) or not or_reduce(tlb_tag0_q(tagpos_type_derat to tagpos_type_tlbsrx))) and tlb_tag0_q(tagpos_esel to tagpos_esel+2));
tlb_tag1_d(tagpos_lpid TO tagpos_lpid+lpid_width-1) <=  tlb_tag0_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_tag1_d(tagpos_atsel) <=  tlb_tag0_q(tagpos_atsel);
tlb_tag1_d(tagpos_hes) <=  tlb_tag0_q(tagpos_hes);
tlb_tag1_d(tagpos_wq TO tagpos_wq+1) <=  tlb_tag0_q(tagpos_wq to tagpos_wq+1);
tlb_tag1_d(tagpos_lrat) <=  tlb_tag0_q(tagpos_lrat);
tlb_tag1_d(tagpos_pt) <=  tlb_tag0_q(tagpos_pt);
tlb_tag1_d(tagpos_recform) <=  tlb_tag0_q(tagpos_recform);
--       pgsize bits
tlb_tag1_d(tagpos_size TO tagpos_size+3) <=  ((0 to 3 => or_reduce(tlb_tag0_q(tagpos_type_derat to tagpos_type_tlbsrx)) and not tlb_tag0_q(tagpos_type_ptereload)) and tlb_seq_pgsize) or
                                              ((0 to 3 => tlb_tag0_q(tagpos_type_ptereload) or not or_reduce(tlb_tag0_q(tagpos_type_derat to tagpos_type_tlbsrx))) and tlb_tag0_q(tagpos_size to tagpos_size+3));
--       tag type bits: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
tlb_tag1_d(tagpos_type TO tagpos_type+7) <=  
               "00000000" when (tlb_seq_ierat_done_sig='1' or tlb_seq_derat_done_sig='1' or tlb_seq_snoop_done_sig='1' or tlb_seq_search_done_sig='1'
                    or tlb_seq_searchresv_done_sig ='1' or tlb_seq_read_done_sig ='1' or tlb_seq_write_done_sig ='1' or tlb_seq_ptereload_done_sig ='1' 
                    or tlb_seq_abort='1')
         else tlb_tag0_q(tagpos_type to tagpos_type+7);
--       endflag
tlb_tag1_d(tagpos_endflag) <=  tlb_seq_endflag;
tlb_addr_d  <=  (others => '0') when tlb_seq_addr_clr='1'
           else tlb_addr_p1 when tlb_seq_addr_incr='1'
           else tlb_seq_addr when tlb_seq_addr_update='1'  
           else tlb_addr_q;
tlb_addr_p1  <=  "0000000" when tlb_addr_q="1111111"
        else tlb_addr_q+1;
tlb_addr_maxcntm1  <=  '1' when tlb_addr_q="1111110" else '0';
-- tag1 phase, tlbwe/re ex3, tlbsx/srx ex4
tlb_tag1_pgsize_eq_16mb  <=  Eq(tlb_tag1_q(tagpos_size to tagpos_size+3),TLB_PgSize_16MB);
tlb_tag1_pgsize_gte_1mb   <=  Eq(tlb_tag1_q(tagpos_size to tagpos_size+3),TLB_PgSize_1MB) or 
                             Eq(tlb_tag1_q(tagpos_size to tagpos_size+3),TLB_PgSize_16MB);
tlb_tag1_pgsize_gte_64kb  <=  Eq(tlb_tag1_q(tagpos_size to tagpos_size+3),TLB_PgSize_1MB) or 
                             Eq(tlb_tag1_q(tagpos_size to tagpos_size+3),TLB_PgSize_16MB) or
                             Eq(tlb_tag1_q(tagpos_size to tagpos_size+3),TLB_PgSize_64KB);
tlb_tag2_d(tagpos_epn TO tagpos_epn+39) <=  tlb_tag1_q(tagpos_epn to tagpos_epn+39);
tlb_tag2_d(tagpos_epn+40 TO tagpos_epn+43) <=  tlb_tag1_q(tagpos_epn+40 to tagpos_epn+43) and (40 to 43 => (not tlb_tag1_pgsize_eq_16mb or not tlb_tag1_q(tagpos_type_ptereload)));
tlb_tag2_d(tagpos_epn+44 TO tagpos_epn+47) <=  tlb_tag1_q(tagpos_epn+44 to tagpos_epn+47) and (44 to 47 => (not tlb_tag1_pgsize_gte_1mb or not tlb_tag1_q(tagpos_type_ptereload)));
tlb_tag2_d(tagpos_epn+48 TO tagpos_epn+51) <=  tlb_tag1_q(tagpos_epn+48 to tagpos_epn+51) and (48 to 51 => (not tlb_tag1_pgsize_gte_64kb or not tlb_tag1_q(tagpos_type_ptereload)));
tlb_tag2_d(tagpos_pid TO tagpos_pid+pid_width-1) <=  tlb_tag1_q(tagpos_pid to tagpos_pid+pid_width-1);
tlb_tag2_d(tagpos_is TO tagpos_is+1) <=  tlb_tag1_q(tagpos_is to tagpos_is+1);
tlb_tag2_d(tagpos_class TO tagpos_class+1) <=  tlb_tag1_q(tagpos_class to tagpos_class+1);
tlb_tag2_d(tagpos_state TO tagpos_state+state_width-1) <=  tlb_tag1_q(tagpos_state to tagpos_state+state_width-1);
tlb_tag2_d(tagpos_thdid TO tagpos_thdid+thdid_width-1) <=  (others => '0') when
                                ( tlb_tag4_hit_or_parerr='1' and tlb_tag2_q(tagpos_type_ptereload)='0' and
                                   (tlb_tag2_q(tagpos_type_ierat)='1' or tlb_tag2_q(tagpos_type_derat)='1' or 
                                            tlb_tag2_q(tagpos_type_tlbsx)='1' or tlb_tag2_q(tagpos_type_tlbsrx)='1') ) or 
                                (tlb_tag4_endflag='1' and tlb_tag0_q(tagpos_type_snoop)='1') or 
                                 tlb_seq_any_done_sig ='1' or tlb_seq_abort='1'
               else tlb_tag1_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and
                   not(tlb_ctl_tag2_flush_sig) and not(tlb_ctl_tag3_flush_sig) and not(tlb_ctl_tag4_flush_sig);
tlb_tag2_d(tagpos_size TO tagpos_size+3) <=  tlb_tag1_q(tagpos_size to tagpos_size+3);
tlb_tag2_d(tagpos_type TO tagpos_type+7) <=  
               "00000000" when (tlb_seq_ierat_done_sig='1' or tlb_seq_derat_done_sig='1' or tlb_seq_snoop_done_sig='1' or tlb_seq_search_done_sig='1'
                    or tlb_seq_searchresv_done_sig ='1' or tlb_seq_read_done_sig ='1' or tlb_seq_write_done_sig ='1' or tlb_seq_ptereload_done_sig ='1'
                    or tlb_seq_abort='1')
         else tlb_tag1_q(tagpos_type to tagpos_type+7);
tlb_tag2_d(tagpos_lpid TO tagpos_lpid+lpid_width-1) <=  tlb_tag1_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
tlb_tag2_d(tagpos_ind) <=  tlb_tag1_q(tagpos_ind);
tlb_tag2_d(tagpos_atsel) <=  tlb_tag1_q(tagpos_atsel);
tlb_tag2_d(tagpos_esel TO tagpos_esel+2) <=  tlb_tag1_q(tagpos_esel to tagpos_esel+2);
tlb_tag2_d(tagpos_hes) <=  tlb_tag1_q(tagpos_hes);
tlb_tag2_d(tagpos_wq TO tagpos_wq+1) <=  tlb_tag1_q(tagpos_wq to tagpos_wq+1);
tlb_tag2_d(tagpos_lrat) <=  tlb_tag1_q(tagpos_lrat);
tlb_tag2_d(tagpos_pt) <=  tlb_tag1_q(tagpos_pt);
tlb_tag2_d(tagpos_recform) <=  tlb_tag1_q(tagpos_recform);
tlb_tag2_d(tagpos_endflag) <=  tlb_tag1_q(tagpos_endflag);
lru_rd_addr      <=  tlb_addr_q;
tlb_addr         <=  tlb_addr_q;
tlb_addr2_d      <=  tlb_addr_q;
-- tag2 phase, tlbwe/re ex4, tlbsx/srx ex5
tlb_tag2    <=  tlb_tag2_q;
tlb_addr2   <=  tlb_addr2_q;
-- tag4, tlbwe/re ex6
tlb_write_d      <=  "1000" when ( ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_state_q(0)='0' and ex6_illeg_instr_q(1)='0' 
                            and  ( (ex6_state_q(1)='0' and tlb_tag4_atsel='0') or 
                                     (ex6_state_q(1)='1' and lrat_tag4_hit_status(0 to 3)="1100" and 
                                       (lru_tag4_dataout(0)='0' or lru_tag4_dataout(8)='0') and     
                                         tlb_tag4_is(1)='0' and tlb0cfg_gtwe='1' and ex6_dgtmi_state='0'))  
                            and ((or_reduce(ex6_valid_q and tlb_resv_match_vec_q)='1' and tlb_tag4_wq="01" and mmucfg_twc='1') or tlb_tag4_wq="00" or tlb_tag4_wq="11")
                            and tlb_tag4_hes='1' and lru_tag4_dataout(4 to 5)="00" ) 
              else "0100" when ( ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_state_q(0)='0' and ex6_illeg_instr_q(1)='0'  
                            and  ((ex6_state_q(1)='0' and tlb_tag4_atsel='0') or 
                                    (ex6_state_q(1)='1' and lrat_tag4_hit_status(0 to 3)="1100" and  
                                      (lru_tag4_dataout(1)='0' or lru_tag4_dataout(9)='0') and       
                                         tlb_tag4_is(1)='0' and tlb0cfg_gtwe='1' and ex6_dgtmi_state='0'))  
                            and ((or_reduce(ex6_valid_q and tlb_resv_match_vec_q)='1' and tlb_tag4_wq="01" and mmucfg_twc='1') or tlb_tag4_wq="00" or tlb_tag4_wq="11")
                            and tlb_tag4_hes='1' and lru_tag4_dataout(4 to 5)="01" ) 
              else "0010" when ( ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_state_q(0)='0' and ex6_illeg_instr_q(1)='0'  
                            and  ((ex6_state_q(1)='0' and tlb_tag4_atsel='0') or 
                                    (ex6_state_q(1)='1' and lrat_tag4_hit_status(0 to 3)="1100" and 
                                      (lru_tag4_dataout(2)='0' or lru_tag4_dataout(10)='0') and     
                                         tlb_tag4_is(1)='0' and tlb0cfg_gtwe='1' and ex6_dgtmi_state='0'))  
                            and ((or_reduce(ex6_valid_q and tlb_resv_match_vec_q)='1' and tlb_tag4_wq="01" and mmucfg_twc='1') or tlb_tag4_wq="00" or tlb_tag4_wq="11")
                            and tlb_tag4_hes='1' and lru_tag4_dataout(4)='1' and lru_tag4_dataout(6)='0' )  
              else "0001" when ( ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_state_q(0)='0' and ex6_illeg_instr_q(1)='0'  
                            and  ((ex6_state_q(1)='0' and tlb_tag4_atsel='0') or 
                                    (ex6_state_q(1)='1' and lrat_tag4_hit_status(0 to 3)="1100" and 
                                      (lru_tag4_dataout(3)='0' or lru_tag4_dataout(11)='0') and     
                                         tlb_tag4_is(1)='0' and tlb0cfg_gtwe='1' and ex6_dgtmi_state='0'))  
                            and ((or_reduce(ex6_valid_q and tlb_resv_match_vec_q)='1' and tlb_tag4_wq="01" and mmucfg_twc='1') or tlb_tag4_wq="00" or tlb_tag4_wq="11")
                            and tlb_tag4_hes='1' and lru_tag4_dataout(4)='1' and lru_tag4_dataout(6)='1' )  
              else "1000" when ( ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_state_q(0)='0' and ex6_illeg_instr_q(1)='0'  
                            and ex6_state_q(1)='0' and tlb_tag4_atsel='0'  
                            and ((or_reduce(ex6_valid_q and tlb_resv_match_vec_q)='1' and tlb_tag4_wq="01" and mmucfg_twc='1') or tlb_tag4_wq="00" or tlb_tag4_wq="11")
                            and tlb_tag4_hes='0' and tlb_tag4_esel(1 to 2)="00" )   
              else "0100" when ( ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_state_q(0)='0' and ex6_illeg_instr_q(1)='0'  
                            and  ex6_state_q(1)='0' and tlb_tag4_atsel='0' 
                            and ((or_reduce(ex6_valid_q and tlb_resv_match_vec_q)='1' and tlb_tag4_wq="01" and mmucfg_twc='1') or tlb_tag4_wq="00" or tlb_tag4_wq="11")
                            and tlb_tag4_hes='0' and tlb_tag4_esel(1 to 2)="01")   
              else "0010" when ( ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_state_q(0)='0' and ex6_illeg_instr_q(1)='0'  
                            and  ex6_state_q(1)='0' and tlb_tag4_atsel='0' 
                            and ((or_reduce(ex6_valid_q and tlb_resv_match_vec_q)='1' and tlb_tag4_wq="01" and mmucfg_twc='1') or tlb_tag4_wq="00" or tlb_tag4_wq="11")
                            and tlb_tag4_hes='0' and tlb_tag4_esel(1 to 2)="10")   
              else "0001" when ( ex6_valid_q/="0000" and ex6_ttype_q(1)='1' and ex6_state_q(0)='0' and ex6_illeg_instr_q(1)='0'  
                            and  ex6_state_q(1)='0' and tlb_tag4_atsel='0' 
                            and ((or_reduce(ex6_valid_q and tlb_resv_match_vec_q)='1' and tlb_tag4_wq="01" and mmucfg_twc='1') or tlb_tag4_wq="00" or tlb_tag4_wq="11")
                            and tlb_tag4_hes='0' and tlb_tag4_esel(1 to 2)="11")   
              else "1000" when ( tlb_tag4_ptereload='1'  
                            and  (tlb_tag4_gs='0' or (tlb_tag4_gs='1' and lrat_tag4_hit_status(0 to 3)="1100"))  
                            and lru_tag4_dataout(4 to 5)="00" 
                            and (lru_tag4_dataout(0)='0' or lru_tag4_dataout(8)='0')  
                            and tlb_tag4_wq="10" and tlb_tag4_is(0)='1' and tlb_tag4_pt='1') 
              else "0100" when ( tlb_tag4_ptereload='1'       
                            and  (tlb_tag4_gs='0' or (tlb_tag4_gs='1' and lrat_tag4_hit_status(0 to 3)="1100"))  
                            and lru_tag4_dataout(4 to 5)="01" 
                            and (lru_tag4_dataout(1)='0' or lru_tag4_dataout(9)='0')  
                            and tlb_tag4_wq="10" and tlb_tag4_is(0)='1' and tlb_tag4_pt='1') 
              else "0010" when ( tlb_tag4_ptereload='1'       
                            and  (tlb_tag4_gs='0' or (tlb_tag4_gs='1' and lrat_tag4_hit_status(0 to 3)="1100"))  
                            and lru_tag4_dataout(4)='1' and lru_tag4_dataout(6)='0'  
                            and (lru_tag4_dataout(2)='0' or lru_tag4_dataout(10)='0')  
                            and tlb_tag4_wq="10" and tlb_tag4_is(0)='1' and tlb_tag4_pt='1') 
              else "0001" when ( tlb_tag4_ptereload='1'        
                            and  (tlb_tag4_gs='0' or (tlb_tag4_gs='1' and lrat_tag4_hit_status(0 to 3)="1100"))  
                            and lru_tag4_dataout(4)='1' and lru_tag4_dataout(6)='1'  
                            and (lru_tag4_dataout(3)='0' or lru_tag4_dataout(11)='0')  
                            and tlb_tag4_wq="10" and tlb_tag4_is(0)='1' and tlb_tag4_pt='1') 
              else "0000";
-- tag5 (ex7) phase signals
tlb_write         <=  tlb_write_q and (0 to tlb_ways-1 => not or_reduce(tlb_tag5_except));
tlb_tag5_write    <=  or_reduce(tlb_write_q) and not or_reduce(tlb_tag5_except);
----------- this is what the erat expects on reload bus
--  0:51  - EPN
--  52  - X
--  53:55  - SIZE
--  56  - V
--  57:60  - ThdID
--  61:62  - Class
--  63  - ExtClass
--  64  - TID_NZ
--  65  - reserved
--  0:33 66:99 - RPN
--  34:35 100:101 - R,C
--  36:40 102:106 - ResvAttr
--  41:44 107:110 - U0-U3
--  45:49 111:115 - WIMGE
--  50:52 116:118 - UX,UW,UR
--  53:55 119:121 - SX,SW,SR
--  56 122 - HS
--  57 123 - TS
--  58:65 124:131 - TID
-----------
-- tlb_low_data
--  0:51  - EPN
--  52:55  - SIZE (4b)
--  56:59  - ThdID
--  60:61  - Class
--  62  - ExtClass
--  63  - TID_NZ
--  64:65  - reserved (2b)
--  66:73  - 8b for LPID
--  74:83  - parity 10bits
-- tlb_high_data
--  84       -  0      - X-bit
--  85:87    -  1:3    - reserved (3b)
--  88:117   -  4:33   - RPN (30b)
--  118:119  -  34:35  - R,C
--  120:121  -  36:37  - WLC (2b)
--  122      -  38     - ResvAttr
--  123      -  39     - VF
--  124      -  40     - IND
--  125:128  -  41:44  - U0-U3
--  129:133  -  45:49  - WIMGE
--  134:136  -  50:52  - UX,UW,UR
--  137:139  -  53:55  - SX,SW,SR
--  140      -  56  - GS
--  141      -  57  - TS
--  142:143  -  58:59  - reserved (2b)
--  144:149  -  60:65  - 6b TID msbs
--  150:157  -  66:73  - 8b TID lsbs
--  158:167  -  74:83  - parity 10bits
-- lru data format
--   0:3  - valid(0:3)
--   4:6  - LRU
--   7  - parity
--   8:11  - iprot(0:3)
--   12:14  - reserved
--   15  - parity
-- wr_ws0_data (LO)
--  0:51  - EPN
--  52:53  - Class
--  54  - V
--  55  - unused
--  56  - X
--  57:59  - SIZE
--  60:63  - ThdID
-- wr_ws1_data (HI)
--  0:6  - unused
--  7:11  - ResvAttr
--  12:15  - U0-U3
--  16:17  - R,C
--  18:51  - RPN
--  52:56  - WIMGE
--  57  - unused
--  58:59  - UX,SX
--  60:61  - UW,SW
--  62:63  - UR,SR
ex3_valid_32b  <=  or_reduce(ex3_valid_q and not(xu_mm_msr_cm));
tlb_ctl_ex2_flush_req  <=  (ex2_valid_q and not(xu_ex2_flush)) 
                             when (ex2_ttype_q(2 to 4)/="000" 
                                   and search_req_taken_sig='0' and searchresv_req_taken_sig='0')  
              else (ex2_valid_q and not(xu_ex2_flush)) when (ex2_flush_req_q/="0000")  
              else "0000";
-- illegal instruction terms
--  state: 0:pr 1:gs 2:as 3:cm
mas1_tsize_direct(0) <=   ( Eq(mas1_0_tsize,TLB_PgSize_4KB)   or Eq(mas1_0_tsize,TLB_PgSize_64KB)   or
                                           Eq(mas1_0_tsize,TLB_PgSize_1MB)   or  Eq(mas1_0_tsize,TLB_PgSize_16MB)   or 
                                           Eq(mas1_0_tsize,TLB_PgSize_1GB)   );
mas1_tsize_indirect(0) <=   ( Eq(mas1_0_tsize,TLB_PgSize_1MB)   or  Eq(mas1_0_tsize,TLB_PgSize_256MB)   );
mas1_tsize_lrat(0) <=   ( Eq(mas1_0_tsize,LRAT_PgSize_1MB)   or  Eq(mas1_0_tsize,LRAT_PgSize_16MB)   or 
                                           Eq(mas1_0_tsize,LRAT_PgSize_256MB)   or Eq(mas1_0_tsize,LRAT_PgSize_1GB)   or
                                           Eq(mas1_0_tsize,LRAT_PgSize_4GB)   or Eq(mas1_0_tsize,LRAT_PgSize_16GB)   or
                                           Eq(mas1_0_tsize,LRAT_PgSize_256GB)   or Eq(mas1_0_tsize,LRAT_PgSize_1TB)   );
ex2_tlbre_mas1_tsize_not_supp(0) <=  '1' when ( mas1_tsize_direct(0)='0'   and (mas1_0_ind='0'   or tlb0cfg_ind='0') and (mas0_0_atsel='0'   or ex2_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(0)='0'   and mas1_0_ind='1'   and tlb0cfg_ind='1' and (mas0_0_atsel='0'   or ex2_state_q(1)='1') )
                       else '0';
ex5_tlbre_mas1_tsize_not_supp(0) <=  '1' when ( mas1_tsize_direct(0)='0'   and (mas1_0_ind='0'   or tlb0cfg_ind='0') and (mas0_0_atsel='0'   or ex5_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(0)='0'   and mas1_0_ind='1'   and tlb0cfg_ind='1' and (mas0_0_atsel='0'   or ex5_state_q(1)='1') )
                       else '0';
ex5_tlbwe_mas1_tsize_not_supp(0) <=  '1' when ( mas1_tsize_direct(0)='0'   and (mas1_0_ind='0'   or tlb0cfg_ind='0') and mas0_0_wq/="10"   and (mas0_0_atsel='0'   or ex5_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(0)='0'   and mas1_0_ind='1'   and tlb0cfg_ind='1' and mas0_0_wq/="10"   and (mas0_0_atsel='0'   or ex5_state_q(1)='1') )  or
                                       ( mas1_tsize_lrat(0)='0'   and mas0_0_atsel='1'   and (mas0_0_wq="00"   or mas0_0_wq="11")   and  ex5_state_q(1)='0' )   
                       else '0';
ex6_tlbwe_mas1_tsize_not_supp(0) <=  '1' when ( mas1_tsize_direct(0)='0'   and (mas1_0_ind='0'   or tlb0cfg_ind='0') and mas0_0_wq/="10"   and (mas0_0_atsel='0'   or ex6_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(0)='0'   and mas1_0_ind='1'   and tlb0cfg_ind='1' and mas0_0_wq/="10"   and (mas0_0_atsel='0'   or ex6_state_q(1)='1') )  or
                                       ( mas1_tsize_lrat(0)='0'   and mas0_0_atsel='1'   and (mas0_0_wq="00"   or mas0_0_wq="11")   and  ex6_state_q(1)='0' )   
                       else '0';
ex5_tlbwe_mas0_lrat_bad_selects(0) <=  '1' when ( (mas0_0_hes='1'   or mas0_0_wq="01"   or mas0_0_wq="10")   and mas0_0_atsel='1'   and  ex5_state_q(1)='0' )   
                       else '0';
ex6_tlbwe_mas0_lrat_bad_selects(0) <=  '1' when ( (mas0_0_hes='1'   or mas0_0_wq="01"   or mas0_0_wq="10")   and mas0_0_atsel='1'   and  ex6_state_q(1)='0' )   
                       else '0';
ex5_tlbwe_mas2_ind_bad_wimge(0) <=  '1' when ( mas1_0_ind='1'   and tlb0cfg_ind='1' and mas0_0_wq/="10"   and  
                                           (mas2_0_wimge(1)='1'   or mas2_0_wimge(2)='0'   or mas2_0_wimge(3)='1'   or mas2_0_wimge(4)='1')   and 
                                           (mas0_0_atsel='0'   or ex5_state_q(1)='1') )   
                       else '0';
ex6_tlbwe_mas2_ind_bad_wimge(0) <=  '1' when ( mas1_0_ind='1'   and tlb0cfg_ind='1' and mas0_0_wq/="10"   and 
                                           (mas2_0_wimge(1)='1'   or mas2_0_wimge(2)='0'   or mas2_0_wimge(3)='1'   or mas2_0_wimge(4)='1')   and 
                                           (mas0_0_atsel='0'   or ex6_state_q(1)='1') )   
                       else '0';
-- Added for illegal indirect page size and sub-page size combinations
mas3_spsize_indirect(0) <=  '1' when ((mas1_0_tsize=TLB_PgSize_1MB   and mas3_0_usxwr(0   to 3)=TLB_PgSize_4KB) or 
                                          (mas1_0_tsize=TLB_PgSize_256MB   and mas3_0_usxwr(0   to 3)=TLB_PgSize_64KB))
                       else '0';
ex5_tlbwe_mas3_ind_bad_spsize(0) <=  '1' when ( mas1_0_ind='1'   and tlb0cfg_ind='1' and mas0_0_wq/="10"   and mas3_spsize_indirect(0)='0'   and (mas0_0_atsel='0'   or ex5_state_q(1)='1') )   
                       else '0';
ex6_tlbwe_mas3_ind_bad_spsize(0) <=  '1' when ( mas1_0_ind='1'   and tlb0cfg_ind='1' and mas0_0_wq/="10"   and mas3_spsize_indirect(0)='0'   and (mas0_0_atsel='0'   or ex6_state_q(1)='1') )   
                       else '0';
mas1_tsize_direct(1) <=   ( Eq(mas1_1_tsize,TLB_PgSize_4KB)   or Eq(mas1_1_tsize,TLB_PgSize_64KB)   or
                                           Eq(mas1_1_tsize,TLB_PgSize_1MB)   or  Eq(mas1_1_tsize,TLB_PgSize_16MB)   or 
                                           Eq(mas1_1_tsize,TLB_PgSize_1GB)   );
mas1_tsize_indirect(1) <=   ( Eq(mas1_1_tsize,TLB_PgSize_1MB)   or  Eq(mas1_1_tsize,TLB_PgSize_256MB)   );
mas1_tsize_lrat(1) <=   ( Eq(mas1_1_tsize,LRAT_PgSize_1MB)   or  Eq(mas1_1_tsize,LRAT_PgSize_16MB)   or 
                                           Eq(mas1_1_tsize,LRAT_PgSize_256MB)   or Eq(mas1_1_tsize,LRAT_PgSize_1GB)   or
                                           Eq(mas1_1_tsize,LRAT_PgSize_4GB)   or Eq(mas1_1_tsize,LRAT_PgSize_16GB)   or
                                           Eq(mas1_1_tsize,LRAT_PgSize_256GB)   or Eq(mas1_1_tsize,LRAT_PgSize_1TB)   );
ex2_tlbre_mas1_tsize_not_supp(1) <=  '1' when ( mas1_tsize_direct(1)='0'   and (mas1_1_ind='0'   or tlb0cfg_ind='0') and (mas0_1_atsel='0'   or ex2_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(1)='0'   and mas1_1_ind='1'   and tlb0cfg_ind='1' and (mas0_1_atsel='0'   or ex2_state_q(1)='1') )
                       else '0';
ex5_tlbre_mas1_tsize_not_supp(1) <=  '1' when ( mas1_tsize_direct(1)='0'   and (mas1_1_ind='0'   or tlb0cfg_ind='0') and (mas0_1_atsel='0'   or ex5_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(1)='0'   and mas1_1_ind='1'   and tlb0cfg_ind='1' and (mas0_1_atsel='0'   or ex5_state_q(1)='1') )
                       else '0';
ex5_tlbwe_mas1_tsize_not_supp(1) <=  '1' when ( mas1_tsize_direct(1)='0'   and (mas1_1_ind='0'   or tlb0cfg_ind='0') and mas0_1_wq/="10"   and (mas0_1_atsel='0'   or ex5_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(1)='0'   and mas1_1_ind='1'   and tlb0cfg_ind='1' and mas0_1_wq/="10"   and (mas0_1_atsel='0'   or ex5_state_q(1)='1') )  or
                                       ( mas1_tsize_lrat(1)='0'   and mas0_1_atsel='1'   and (mas0_1_wq="00"   or mas0_1_wq="11")   and  ex5_state_q(1)='0' )   
                       else '0';
ex6_tlbwe_mas1_tsize_not_supp(1) <=  '1' when ( mas1_tsize_direct(1)='0'   and (mas1_1_ind='0'   or tlb0cfg_ind='0') and mas0_1_wq/="10"   and (mas0_1_atsel='0'   or ex6_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(1)='0'   and mas1_1_ind='1'   and tlb0cfg_ind='1' and mas0_1_wq/="10"   and (mas0_1_atsel='0'   or ex6_state_q(1)='1') )  or
                                       ( mas1_tsize_lrat(1)='0'   and mas0_1_atsel='1'   and (mas0_1_wq="00"   or mas0_1_wq="11")   and  ex6_state_q(1)='0' )   
                       else '0';
ex5_tlbwe_mas0_lrat_bad_selects(1) <=  '1' when ( (mas0_1_hes='1'   or mas0_1_wq="01"   or mas0_1_wq="10")   and mas0_1_atsel='1'   and  ex5_state_q(1)='0' )   
                       else '0';
ex6_tlbwe_mas0_lrat_bad_selects(1) <=  '1' when ( (mas0_1_hes='1'   or mas0_1_wq="01"   or mas0_1_wq="10")   and mas0_1_atsel='1'   and  ex6_state_q(1)='0' )   
                       else '0';
ex5_tlbwe_mas2_ind_bad_wimge(1) <=  '1' when ( mas1_1_ind='1'   and tlb0cfg_ind='1' and mas0_1_wq/="10"   and  
                                           (mas2_1_wimge(1)='1'   or mas2_1_wimge(2)='0'   or mas2_1_wimge(3)='1'   or mas2_1_wimge(4)='1')   and 
                                           (mas0_1_atsel='0'   or ex5_state_q(1)='1') )   
                       else '0';
ex6_tlbwe_mas2_ind_bad_wimge(1) <=  '1' when ( mas1_1_ind='1'   and tlb0cfg_ind='1' and mas0_1_wq/="10"   and 
                                           (mas2_1_wimge(1)='1'   or mas2_1_wimge(2)='0'   or mas2_1_wimge(3)='1'   or mas2_1_wimge(4)='1')   and 
                                           (mas0_1_atsel='0'   or ex6_state_q(1)='1') )   
                       else '0';
-- Added for illegal indirect page size and sub-page size combinations
mas3_spsize_indirect(1) <=  '1' when ((mas1_1_tsize=TLB_PgSize_1MB   and mas3_1_usxwr(0   to 3)=TLB_PgSize_4KB) or 
                                          (mas1_1_tsize=TLB_PgSize_256MB   and mas3_1_usxwr(0   to 3)=TLB_PgSize_64KB))
                       else '0';
ex5_tlbwe_mas3_ind_bad_spsize(1) <=  '1' when ( mas1_1_ind='1'   and tlb0cfg_ind='1' and mas0_1_wq/="10"   and mas3_spsize_indirect(1)='0'   and (mas0_1_atsel='0'   or ex5_state_q(1)='1') )   
                       else '0';
ex6_tlbwe_mas3_ind_bad_spsize(1) <=  '1' when ( mas1_1_ind='1'   and tlb0cfg_ind='1' and mas0_1_wq/="10"   and mas3_spsize_indirect(1)='0'   and (mas0_1_atsel='0'   or ex6_state_q(1)='1') )   
                       else '0';
mas1_tsize_direct(2) <=   ( Eq(mas1_2_tsize,TLB_PgSize_4KB)   or Eq(mas1_2_tsize,TLB_PgSize_64KB)   or
                                           Eq(mas1_2_tsize,TLB_PgSize_1MB)   or  Eq(mas1_2_tsize,TLB_PgSize_16MB)   or 
                                           Eq(mas1_2_tsize,TLB_PgSize_1GB)   );
mas1_tsize_indirect(2) <=   ( Eq(mas1_2_tsize,TLB_PgSize_1MB)   or  Eq(mas1_2_tsize,TLB_PgSize_256MB)   );
mas1_tsize_lrat(2) <=   ( Eq(mas1_2_tsize,LRAT_PgSize_1MB)   or  Eq(mas1_2_tsize,LRAT_PgSize_16MB)   or 
                                           Eq(mas1_2_tsize,LRAT_PgSize_256MB)   or Eq(mas1_2_tsize,LRAT_PgSize_1GB)   or
                                           Eq(mas1_2_tsize,LRAT_PgSize_4GB)   or Eq(mas1_2_tsize,LRAT_PgSize_16GB)   or
                                           Eq(mas1_2_tsize,LRAT_PgSize_256GB)   or Eq(mas1_2_tsize,LRAT_PgSize_1TB)   );
ex2_tlbre_mas1_tsize_not_supp(2) <=  '1' when ( mas1_tsize_direct(2)='0'   and (mas1_2_ind='0'   or tlb0cfg_ind='0') and (mas0_2_atsel='0'   or ex2_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(2)='0'   and mas1_2_ind='1'   and tlb0cfg_ind='1' and (mas0_2_atsel='0'   or ex2_state_q(1)='1') )
                       else '0';
ex5_tlbre_mas1_tsize_not_supp(2) <=  '1' when ( mas1_tsize_direct(2)='0'   and (mas1_2_ind='0'   or tlb0cfg_ind='0') and (mas0_2_atsel='0'   or ex5_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(2)='0'   and mas1_2_ind='1'   and tlb0cfg_ind='1' and (mas0_2_atsel='0'   or ex5_state_q(1)='1') )
                       else '0';
ex5_tlbwe_mas1_tsize_not_supp(2) <=  '1' when ( mas1_tsize_direct(2)='0'   and (mas1_2_ind='0'   or tlb0cfg_ind='0') and mas0_2_wq/="10"   and (mas0_2_atsel='0'   or ex5_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(2)='0'   and mas1_2_ind='1'   and tlb0cfg_ind='1' and mas0_2_wq/="10"   and (mas0_2_atsel='0'   or ex5_state_q(1)='1') )  or
                                       ( mas1_tsize_lrat(2)='0'   and mas0_2_atsel='1'   and (mas0_2_wq="00"   or mas0_2_wq="11")   and  ex5_state_q(1)='0' )   
                       else '0';
ex6_tlbwe_mas1_tsize_not_supp(2) <=  '1' when ( mas1_tsize_direct(2)='0'   and (mas1_2_ind='0'   or tlb0cfg_ind='0') and mas0_2_wq/="10"   and (mas0_2_atsel='0'   or ex6_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(2)='0'   and mas1_2_ind='1'   and tlb0cfg_ind='1' and mas0_2_wq/="10"   and (mas0_2_atsel='0'   or ex6_state_q(1)='1') )  or
                                       ( mas1_tsize_lrat(2)='0'   and mas0_2_atsel='1'   and (mas0_2_wq="00"   or mas0_2_wq="11")   and  ex6_state_q(1)='0' )   
                       else '0';
ex5_tlbwe_mas0_lrat_bad_selects(2) <=  '1' when ( (mas0_2_hes='1'   or mas0_2_wq="01"   or mas0_2_wq="10")   and mas0_2_atsel='1'   and  ex5_state_q(1)='0' )   
                       else '0';
ex6_tlbwe_mas0_lrat_bad_selects(2) <=  '1' when ( (mas0_2_hes='1'   or mas0_2_wq="01"   or mas0_2_wq="10")   and mas0_2_atsel='1'   and  ex6_state_q(1)='0' )   
                       else '0';
ex5_tlbwe_mas2_ind_bad_wimge(2) <=  '1' when ( mas1_2_ind='1'   and tlb0cfg_ind='1' and mas0_2_wq/="10"   and  
                                           (mas2_2_wimge(1)='1'   or mas2_2_wimge(2)='0'   or mas2_2_wimge(3)='1'   or mas2_2_wimge(4)='1')   and 
                                           (mas0_2_atsel='0'   or ex5_state_q(1)='1') )   
                       else '0';
ex6_tlbwe_mas2_ind_bad_wimge(2) <=  '1' when ( mas1_2_ind='1'   and tlb0cfg_ind='1' and mas0_2_wq/="10"   and 
                                           (mas2_2_wimge(1)='1'   or mas2_2_wimge(2)='0'   or mas2_2_wimge(3)='1'   or mas2_2_wimge(4)='1')   and 
                                           (mas0_2_atsel='0'   or ex6_state_q(1)='1') )   
                       else '0';
-- Added for illegal indirect page size and sub-page size combinations
mas3_spsize_indirect(2) <=  '1' when ((mas1_2_tsize=TLB_PgSize_1MB   and mas3_2_usxwr(0   to 3)=TLB_PgSize_4KB) or 
                                          (mas1_2_tsize=TLB_PgSize_256MB   and mas3_2_usxwr(0   to 3)=TLB_PgSize_64KB))
                       else '0';
ex5_tlbwe_mas3_ind_bad_spsize(2) <=  '1' when ( mas1_2_ind='1'   and tlb0cfg_ind='1' and mas0_2_wq/="10"   and mas3_spsize_indirect(2)='0'   and (mas0_2_atsel='0'   or ex5_state_q(1)='1') )   
                       else '0';
ex6_tlbwe_mas3_ind_bad_spsize(2) <=  '1' when ( mas1_2_ind='1'   and tlb0cfg_ind='1' and mas0_2_wq/="10"   and mas3_spsize_indirect(2)='0'   and (mas0_2_atsel='0'   or ex6_state_q(1)='1') )   
                       else '0';
mas1_tsize_direct(3) <=   ( Eq(mas1_3_tsize,TLB_PgSize_4KB)   or Eq(mas1_3_tsize,TLB_PgSize_64KB)   or
                                           Eq(mas1_3_tsize,TLB_PgSize_1MB)   or  Eq(mas1_3_tsize,TLB_PgSize_16MB)   or 
                                           Eq(mas1_3_tsize,TLB_PgSize_1GB)   );
mas1_tsize_indirect(3) <=   ( Eq(mas1_3_tsize,TLB_PgSize_1MB)   or  Eq(mas1_3_tsize,TLB_PgSize_256MB)   );
mas1_tsize_lrat(3) <=   ( Eq(mas1_3_tsize,LRAT_PgSize_1MB)   or  Eq(mas1_3_tsize,LRAT_PgSize_16MB)   or 
                                           Eq(mas1_3_tsize,LRAT_PgSize_256MB)   or Eq(mas1_3_tsize,LRAT_PgSize_1GB)   or
                                           Eq(mas1_3_tsize,LRAT_PgSize_4GB)   or Eq(mas1_3_tsize,LRAT_PgSize_16GB)   or
                                           Eq(mas1_3_tsize,LRAT_PgSize_256GB)   or Eq(mas1_3_tsize,LRAT_PgSize_1TB)   );
ex2_tlbre_mas1_tsize_not_supp(3) <=  '1' when ( mas1_tsize_direct(3)='0'   and (mas1_3_ind='0'   or tlb0cfg_ind='0') and (mas0_3_atsel='0'   or ex2_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(3)='0'   and mas1_3_ind='1'   and tlb0cfg_ind='1' and (mas0_3_atsel='0'   or ex2_state_q(1)='1') )
                       else '0';
ex5_tlbre_mas1_tsize_not_supp(3) <=  '1' when ( mas1_tsize_direct(3)='0'   and (mas1_3_ind='0'   or tlb0cfg_ind='0') and (mas0_3_atsel='0'   or ex5_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(3)='0'   and mas1_3_ind='1'   and tlb0cfg_ind='1' and (mas0_3_atsel='0'   or ex5_state_q(1)='1') )
                       else '0';
ex5_tlbwe_mas1_tsize_not_supp(3) <=  '1' when ( mas1_tsize_direct(3)='0'   and (mas1_3_ind='0'   or tlb0cfg_ind='0') and mas0_3_wq/="10"   and (mas0_3_atsel='0'   or ex5_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(3)='0'   and mas1_3_ind='1'   and tlb0cfg_ind='1' and mas0_3_wq/="10"   and (mas0_3_atsel='0'   or ex5_state_q(1)='1') )  or
                                       ( mas1_tsize_lrat(3)='0'   and mas0_3_atsel='1'   and (mas0_3_wq="00"   or mas0_3_wq="11")   and  ex5_state_q(1)='0' )   
                       else '0';
ex6_tlbwe_mas1_tsize_not_supp(3) <=  '1' when ( mas1_tsize_direct(3)='0'   and (mas1_3_ind='0'   or tlb0cfg_ind='0') and mas0_3_wq/="10"   and (mas0_3_atsel='0'   or ex6_state_q(1)='1') ) or 
                                       ( mas1_tsize_indirect(3)='0'   and mas1_3_ind='1'   and tlb0cfg_ind='1' and mas0_3_wq/="10"   and (mas0_3_atsel='0'   or ex6_state_q(1)='1') )  or
                                       ( mas1_tsize_lrat(3)='0'   and mas0_3_atsel='1'   and (mas0_3_wq="00"   or mas0_3_wq="11")   and  ex6_state_q(1)='0' )   
                       else '0';
ex5_tlbwe_mas0_lrat_bad_selects(3) <=  '1' when ( (mas0_3_hes='1'   or mas0_3_wq="01"   or mas0_3_wq="10")   and mas0_3_atsel='1'   and  ex5_state_q(1)='0' )   
                       else '0';
ex6_tlbwe_mas0_lrat_bad_selects(3) <=  '1' when ( (mas0_3_hes='1'   or mas0_3_wq="01"   or mas0_3_wq="10")   and mas0_3_atsel='1'   and  ex6_state_q(1)='0' )   
                       else '0';
ex5_tlbwe_mas2_ind_bad_wimge(3) <=  '1' when ( mas1_3_ind='1'   and tlb0cfg_ind='1' and mas0_3_wq/="10"   and  
                                           (mas2_3_wimge(1)='1'   or mas2_3_wimge(2)='0'   or mas2_3_wimge(3)='1'   or mas2_3_wimge(4)='1')   and 
                                           (mas0_3_atsel='0'   or ex5_state_q(1)='1') )   
                       else '0';
ex6_tlbwe_mas2_ind_bad_wimge(3) <=  '1' when ( mas1_3_ind='1'   and tlb0cfg_ind='1' and mas0_3_wq/="10"   and 
                                           (mas2_3_wimge(1)='1'   or mas2_3_wimge(2)='0'   or mas2_3_wimge(3)='1'   or mas2_3_wimge(4)='1')   and 
                                           (mas0_3_atsel='0'   or ex6_state_q(1)='1') )   
                       else '0';
-- Added for illegal indirect page size and sub-page size combinations
mas3_spsize_indirect(3) <=  '1' when ((mas1_3_tsize=TLB_PgSize_1MB   and mas3_3_usxwr(0   to 3)=TLB_PgSize_4KB) or 
                                          (mas1_3_tsize=TLB_PgSize_256MB   and mas3_3_usxwr(0   to 3)=TLB_PgSize_64KB))
                       else '0';
ex5_tlbwe_mas3_ind_bad_spsize(3) <=  '1' when ( mas1_3_ind='1'   and tlb0cfg_ind='1' and mas0_3_wq/="10"   and mas3_spsize_indirect(3)='0'   and (mas0_3_atsel='0'   or ex5_state_q(1)='1') )   
                       else '0';
ex6_tlbwe_mas3_ind_bad_spsize(3) <=  '1' when ( mas1_3_ind='1'   and tlb0cfg_ind='1' and mas0_3_wq/="10"   and mas3_spsize_indirect(3)='0'   and (mas0_3_atsel='0'   or ex6_state_q(1)='1') )   
                       else '0';
tlb_ctl_ex2_illeg_instr  <=  ( ex2_tlbre_mas1_tsize_not_supp and ex2_valid_q and not(xu_ex2_flush) and 
                                   (0 to 3 => (ex2_ttype_q(0) and ex2_hv_state and not ex2_mas0_atsel)) )   
                         or ( (ex6_tlbwe_mas1_tsize_not_supp or ex6_tlbwe_mas0_lrat_bad_selects or ex6_tlbwe_mas2_ind_bad_wimge or ex6_tlbwe_mas3_ind_bad_spsize) and ex6_valid_q and 
                                   (0 to 3 => (ex6_ttype_q(1) and (ex6_hv_state or (ex6_priv_state and not ex6_dgtmi_state)))) );
ex6_illeg_instr_d(0) <=   ex5_ttype_q(0) and or_reduce(ex5_tlbre_mas1_tsize_not_supp and ex5_valid_q);
ex6_illeg_instr_d(1) <=   ex5_ttype_q(1) and or_reduce((ex5_tlbwe_mas1_tsize_not_supp or ex5_tlbwe_mas0_lrat_bad_selects or ex5_tlbwe_mas2_ind_bad_wimge or ex5_tlbwe_mas3_ind_bad_spsize) and ex5_valid_q);
ex6_illeg_instr  <=  ex6_illeg_instr_q;
-- state: 0:pr 1:gs 2:as 3:cm
-- Event     |          Exceptions
--           | PT fault   | TLB Inelig | LRAT miss
----------------------------------------------------------
-- tlbwe     |  -         | hv_priv=1  | lrat_miss=1
--           |            | tlbi=1     | esr_pt=0
--           |            | esr_pt=0   |
----------------------------------------------------------
-- ptereload | DSI        | DSI        | lrat_miss=1
--  (data)   | pt_fault=1 | tlbi=1     | esr_pt=1
--           | PT=1       | esr_pt=0 ? | esr_data=1
--           |            |            | esr_epid=class(0)
--           |            |            | esr_st=class(1)
----------------------------------------------------------
-- ptereload | ISI        | ISI        | lrat_miss=1
--  (inst)   | pt_fault=1 | tlbi=1     | esr_pt=1
--           | PT=1       | esr_pt=0 ? | esr_data=0
----------------------------------------------------------
tlb_lper_lpn          <=  ptereload_req_pte_q(ptepos_rpn+10 to ptepos_rpn+39);
tlb_lper_lps          <=  ptereload_req_pte_q(ptepos_size to ptepos_size+3);
-- lrat hit_status: 0:val,1:hit,2:multihit,3:inval_pgsize
--  unused tagpos_is def is mas1_v, mas1_iprot for tlbwe, and is (pte.valid & 0) for ptereloads
tlb_lper_we           <=  tlb_tag0_q(tagpos_thdid to tagpos_thdid+thdid_width-1)  
                          when (tlb_tag4_ptereload='1' and tlb_tag4_gs='1' and
                                  mmucfg_lrat='1' and tlb_tag4_pt='1' and tlb_tag4_wq="10" and   
                                  tlb_tag4_is(0)='1' and lrat_tag4_hit_status(0 to 3)/="1100")  
                  else (others => '0');
pte_tag0_lpn      <=  ptereload_req_pte_q(ptepos_rpn+10 to ptepos_rpn+39);
pte_tag0_lpid     <=  tlb_tag0_q(tagpos_lpid to tagpos_lpid+lpid_width-1);
-- perf count events
tlb_ctl_perf_tlbwec_resv      <=  or_reduce(ex6_valid_q and tlb_resv_match_vec_q) and ex6_ttype_q(1) and Eq(tlb_tag4_wq,"01");
tlb_ctl_perf_tlbwec_noresv    <=  or_reduce(ex6_valid_q and not tlb_resv_match_vec_q) and ex6_ttype_q(1) and Eq(tlb_tag4_wq,"01");
-- power clock gating for latches
tlb_early_act  <=  xu_mm_ccr2_notlb_b and (any_tlb_req_sig or not(tlb_seq_idle_sig) or tlb_ctl_any_tag_flush_sig or tlb_seq_abort);
tlb_delayed_act_d(0 TO 1) <=  "11" when tlb_early_act='1'
                        else "10" when tlb_delayed_act_q(0 to 1)="11"
                        else "01" when tlb_delayed_act_q(0 to 1)="10"
                        else "00";
tlb_delayed_act_d(2 TO 8) <=  (2 to 8   => tlb_early_act or tlb_delayed_act_q(0) or tlb_delayed_act_q(1) or mmucr2(1));
tlb_delayed_act_d(9 TO 16) <=  (9 to 16  => tlb_early_act or tlb_delayed_act_q(0) or tlb_delayed_act_q(1) or mmucr2(2));
tlb_delayed_act_d(17 TO 19) <=  (17 to 19 => tlb_early_act or tlb_delayed_act_q(0) or tlb_delayed_act_q(1) or mmucr2(2));
tlb_delayed_act_d(20 TO 23) <=  (20 to 23 => tlb_early_act or tlb_delayed_act_q(0) or tlb_delayed_act_q(1) or mmucr2(3));
tlb_delayed_act_d(24 TO 28) <=  (24 to 28 => tlb_early_act or tlb_delayed_act_q(0) or tlb_delayed_act_q(1) or mmucr2(4));
tlb_delayed_act_d(29 TO 32) <=  (29 to 32 => tlb_early_act or tlb_delayed_act_q(0) or tlb_delayed_act_q(1) or mmucr2(6));
tlb_delayed_act(9 TO 32) <=  tlb_delayed_act_q(9 to 32);
tlb_tag0_act  <=  tlb_early_act or mmucr2(1);
tlb_snoop_act  <=  (tlb_snoop_coming or mmucr2(1)) and xu_mm_ccr2_notlb_b;
tlb_ctl_dbg_seq_q                 <=  tlb_seq_q;
tlb_ctl_dbg_seq_idle              <=  tlb_seq_idle_sig;
tlb_ctl_dbg_seq_any_done_sig      <=  tlb_seq_any_done_sig;
tlb_ctl_dbg_seq_abort             <=  tlb_seq_abort;
tlb_ctl_dbg_any_tlb_req_sig       <=  any_tlb_req_sig;
tlb_ctl_dbg_any_req_taken_sig     <=  any_req_taken_sig;
tlb_ctl_dbg_tag0_valid           <=  or_reduce(tlb_tag0_q(tagpos_thdid to tagpos_thdid+thdid_width-1));
tlb_ctl_dbg_tag0_thdid(0) <=  tlb_tag0_q(tagpos_thdid+2) or tlb_tag0_q(tagpos_thdid+3);
tlb_ctl_dbg_tag0_thdid(1) <=  tlb_tag0_q(tagpos_thdid+1) or tlb_tag0_q(tagpos_thdid+3);
tlb_ctl_dbg_tag0_type(0) <=  tlb_tag0_q(tagpos_type+4) or tlb_tag0_q(tagpos_type+5) or tlb_tag0_q(tagpos_type+6) or tlb_tag0_q(tagpos_type+7);
tlb_ctl_dbg_tag0_type(1) <=  tlb_tag0_q(tagpos_type+2) or tlb_tag0_q(tagpos_type+3) or tlb_tag0_q(tagpos_type+6) or tlb_tag0_q(tagpos_type+7);
tlb_ctl_dbg_tag0_type(2) <=  tlb_tag0_q(tagpos_type+1) or tlb_tag0_q(tagpos_type+3) or tlb_tag0_q(tagpos_type+5) or tlb_tag0_q(tagpos_type+7);
tlb_ctl_dbg_tag0_wq              <=  tlb_tag0_q(tagpos_wq to tagpos_wq+1);
tlb_ctl_dbg_tag0_gs              <=  tlb_tag0_q(tagpos_gs);
tlb_ctl_dbg_tag0_pr              <=  tlb_tag0_q(tagpos_pr);
tlb_ctl_dbg_tag0_atsel           <=  tlb_tag0_q(tagpos_atsel);
tlb_ctl_dbg_tag5_tlb_write_q     <=  tlb_write_q;
tlb_ctl_dbg_resv_valid           <=  tlb_resv_valid_vec;
tlb_ctl_dbg_set_resv             <=  tlb_set_resv0 & tlb_set_resv1 & tlb_set_resv2 & tlb_set_resv3;
tlb_ctl_dbg_resv_match_vec_q     <=  tlb_resv_match_vec_q;
tlb_ctl_dbg_any_tag_flush_sig    <=  tlb_ctl_any_tag_flush_sig;
tlb_ctl_dbg_resv0_tag0_lpid_match          <=  tlb_resv0_tag0_lpid_match;
tlb_ctl_dbg_resv0_tag0_pid_match           <=  tlb_resv0_tag0_pid_match;
tlb_ctl_dbg_resv0_tag0_as_snoop_match      <=  tlb_resv0_tag0_as_snoop_match;
tlb_ctl_dbg_resv0_tag0_gs_snoop_match      <=  tlb_resv0_tag0_gs_snoop_match;
tlb_ctl_dbg_resv0_tag0_as_tlbwe_match      <=  tlb_resv0_tag0_as_tlbwe_match;
tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match      <=  tlb_resv0_tag0_gs_tlbwe_match;
tlb_ctl_dbg_resv0_tag0_ind_match           <=  tlb_resv0_tag0_ind_match;
tlb_ctl_dbg_resv0_tag0_epn_loc_match       <=  tlb_resv0_tag0_epn_loc_match;
tlb_ctl_dbg_resv0_tag0_epn_glob_match      <=  tlb_resv0_tag0_epn_glob_match;
tlb_ctl_dbg_resv0_tag0_class_match         <=  tlb_resv0_tag0_class_match;
tlb_ctl_dbg_resv1_tag0_lpid_match          <=  tlb_resv1_tag0_lpid_match;
tlb_ctl_dbg_resv1_tag0_pid_match           <=  tlb_resv1_tag0_pid_match;
tlb_ctl_dbg_resv1_tag0_as_snoop_match      <=  tlb_resv1_tag0_as_snoop_match;
tlb_ctl_dbg_resv1_tag0_gs_snoop_match      <=  tlb_resv1_tag0_gs_snoop_match;
tlb_ctl_dbg_resv1_tag0_as_tlbwe_match      <=  tlb_resv1_tag0_as_tlbwe_match;
tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match      <=  tlb_resv1_tag0_gs_tlbwe_match;
tlb_ctl_dbg_resv1_tag0_ind_match           <=  tlb_resv1_tag0_ind_match;
tlb_ctl_dbg_resv1_tag0_epn_loc_match       <=  tlb_resv1_tag0_epn_loc_match;
tlb_ctl_dbg_resv1_tag0_epn_glob_match      <=  tlb_resv1_tag0_epn_glob_match;
tlb_ctl_dbg_resv1_tag0_class_match         <=  tlb_resv1_tag0_class_match ;
tlb_ctl_dbg_resv2_tag0_lpid_match          <=  tlb_resv2_tag0_lpid_match;
tlb_ctl_dbg_resv2_tag0_pid_match           <=  tlb_resv2_tag0_pid_match;
tlb_ctl_dbg_resv2_tag0_as_snoop_match      <=  tlb_resv2_tag0_as_snoop_match;
tlb_ctl_dbg_resv2_tag0_gs_snoop_match      <=  tlb_resv2_tag0_gs_snoop_match;
tlb_ctl_dbg_resv2_tag0_as_tlbwe_match      <=  tlb_resv2_tag0_as_tlbwe_match;
tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match      <=  tlb_resv2_tag0_gs_tlbwe_match;
tlb_ctl_dbg_resv2_tag0_ind_match           <=  tlb_resv2_tag0_ind_match;
tlb_ctl_dbg_resv2_tag0_epn_loc_match       <=  tlb_resv2_tag0_epn_loc_match;
tlb_ctl_dbg_resv2_tag0_epn_glob_match      <=  tlb_resv2_tag0_epn_glob_match;
tlb_ctl_dbg_resv2_tag0_class_match         <=  tlb_resv2_tag0_class_match;
tlb_ctl_dbg_resv3_tag0_lpid_match          <=  tlb_resv3_tag0_lpid_match;
tlb_ctl_dbg_resv3_tag0_pid_match           <=  tlb_resv3_tag0_pid_match;
tlb_ctl_dbg_resv3_tag0_as_snoop_match      <=  tlb_resv3_tag0_as_snoop_match;
tlb_ctl_dbg_resv3_tag0_gs_snoop_match      <=  tlb_resv3_tag0_gs_snoop_match;
tlb_ctl_dbg_resv3_tag0_as_tlbwe_match      <=  tlb_resv3_tag0_as_tlbwe_match;
tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match      <=  tlb_resv3_tag0_gs_tlbwe_match;
tlb_ctl_dbg_resv3_tag0_ind_match           <=  tlb_resv3_tag0_ind_match;
tlb_ctl_dbg_resv3_tag0_epn_loc_match       <=  tlb_resv3_tag0_epn_loc_match;
tlb_ctl_dbg_resv3_tag0_epn_glob_match      <=  tlb_resv3_tag0_epn_glob_match;
tlb_ctl_dbg_resv3_tag0_class_match         <=  tlb_resv3_tag0_class_match;
tlb_ctl_dbg_clr_resv_q                     <=  tlb_clr_resv_q;
tlb_ctl_dbg_clr_resv_terms                 <=  (others => '0');
-- unused spare signal assignments
unused_dc(0) <=  or_reduce(LCB_DELAY_LCLKR_DC(1 TO 4));
unused_dc(1) <=  or_reduce(LCB_MPW1_DC_B(1 TO 4));
unused_dc(2) <=  PC_FUNC_SL_FORCE;
unused_dc(3) <=  PC_FUNC_SL_THOLD_0_B;
unused_dc(4) <=  TC_SCAN_DIS_DC_B;
unused_dc(5) <=  TC_SCAN_DIAG_DC;
unused_dc(6) <=  TC_LBIST_EN_DC;
unused_dc(7) <=  TLB_TAG0_Q(109);
unused_dc(8) <=  or_reduce(MMUCR3_0(49 TO 53));
unused_dc(9) <=  or_reduce(MMUCR3_0(56 TO 63));
unused_dc(10) <=  or_reduce(MMUCR3_1(49 TO 53));
unused_dc(11) <=  or_reduce(MMUCR3_1(56 TO 63));
unused_dc(12) <=  or_reduce(MMUCR3_2(49 TO 53));
unused_dc(13) <=  or_reduce(MMUCR3_2(56 TO 63));
unused_dc(14) <=  or_reduce(MMUCR3_3(49 TO 53));
unused_dc(15) <=  or_reduce(MMUCR3_3(56 TO 63));
unused_dc(16) <=  or_reduce(PGSIZE_QTY);
unused_dc(17) <=  or_reduce(PGSIZE_TID0_QTY);
unused_dc(18) <=  PTERELOAD_REQ_TAG(66);
unused_dc(19) <=  or_reduce(PTERELOAD_REQ_TAG(78 TO 81));
unused_dc(20) <=  or_reduce(PTERELOAD_REQ_TAG(84 TO 89));
unused_dc(21) <=  PTERELOAD_REQ_TAG(98);
unused_dc(22) <=  or_reduce(PTERELOAD_REQ_TAG(108 TO 109));
unused_dc(23) <=  LRU_TAG4_DATAOUT(7);
unused_dc(24) <=  or_reduce(LRU_TAG4_DATAOUT(12 TO 15));
unused_dc(25) <=  TLB_TAG4_ESEL(0);
unused_dc(26) <=  EX3_VALID_32B;
unused_dc(27) <=  MAS2_0_WIMGE(0) or MAS2_1_WIMGE(0) or MAS2_2_WIMGE(0) or MAS2_3_WIMGE(0);
unused_dc(28) <=  or_reduce(XU_EX1_FLUSH_Q);
unused_dc(29) <=  or_reduce(MM_XU_ERATMISS_DONE);
unused_dc(30) <=  or_reduce(MM_XU_TLB_MISS);
unused_dc(31) <=  or_reduce(MM_XU_TLB_INELIG);
unused_dc(32) <=  MMUCR1_TLBI_MSB;
unused_dc(33) <=  MMUCSR0_TLB0FI;
unused_dc(34) <=  tlb_tag4_pr;
unused_dc(35) <=  or_reduce(MMUCR2(0) & MMUCR2(5) & MMUCR2(7) & MMUCR2(8 to 11));
-----------------------------------------------------------------------
-- Latches
-----------------------------------------------------------------------
xu_ex1_flush_latch: tri_rlmreg_p
  generic map (width => xu_ex1_flush_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(xu_ex1_flush_offset to xu_ex1_flush_offset+xu_ex1_flush_q'length-1),
            scout   => sov(xu_ex1_flush_offset to xu_ex1_flush_offset+xu_ex1_flush_q'length-1),
            din     => xu_ex1_flush_d(0 to thdid_width-1),
            dout    => xu_ex1_flush_q(0 to thdid_width-1)  );
ex1_valid_latch: tri_rlmreg_p
  generic map (width => ex1_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex1_valid_offset to ex1_valid_offset+ex1_valid_q'length-1),
            scout   => sov(ex1_valid_offset to ex1_valid_offset+ex1_valid_q'length-1),
            din     => ex1_valid_d(0 to thdid_width-1),
            dout    => ex1_valid_q(0 to thdid_width-1)  );
ex1_ttype_latch: tri_rlmreg_p
  generic map (width => ex1_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex1_ttype_offset to ex1_ttype_offset+ex1_ttype_q'length-1),
            scout   => sov(ex1_ttype_offset to ex1_ttype_offset+ex1_ttype_q'length-1),
            din     => ex1_ttype_d(0 to ttype_width-1),
            dout    => ex1_ttype_q(0 to ttype_width-1)  );
ex1_state_latch: tri_rlmreg_p
  generic map (width => ex1_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex1_state_offset to ex1_state_offset+ex1_state_q'length-1),
            scout   => sov(ex1_state_offset to ex1_state_offset+ex1_state_q'length-1),
            din     => ex1_state_d(0 to state_width),
            dout    => ex1_state_q(0 to state_width)  );
ex1_pid_latch: tri_rlmreg_p
  generic map (width => ex1_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex1_pid_offset to ex1_pid_offset+ex1_pid_q'length-1),
            scout   => sov(ex1_pid_offset to ex1_pid_offset+ex1_pid_q'length-1),
            din     => ex1_pid_d(0 to pid_width-1),
            dout    => ex1_pid_q(0 to pid_width-1)  );
-------------------------------------------------------------------------------
ex2_valid_latch: tri_rlmreg_p
  generic map (width => ex2_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_valid_offset to ex2_valid_offset+ex2_valid_q'length-1),
            scout   => sov(ex2_valid_offset to ex2_valid_offset+ex2_valid_q'length-1),
            din     => ex2_valid_d(0 to thdid_width-1),
            dout    => ex2_valid_q(0 to thdid_width-1)  );
ex2_flush_latch: tri_rlmreg_p
  generic map (width => ex2_flush_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_flush_offset to ex2_flush_offset+ex2_flush_q'length-1),
            scout   => sov(ex2_flush_offset to ex2_flush_offset+ex2_flush_q'length-1),
            din     => ex2_flush_d(0 to thdid_width-1),
            dout    => ex2_flush_q(0 to thdid_width-1)  );
ex2_flush_req_latch: tri_rlmreg_p
  generic map (width => ex2_flush_req_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_flush_req_offset to ex2_flush_req_offset+ex2_flush_req_q'length-1),
            scout   => sov(ex2_flush_req_offset to ex2_flush_req_offset+ex2_flush_req_q'length-1),
            din     => ex2_flush_req_d(0 to thdid_width-1),
            dout    => ex2_flush_req_q(0 to thdid_width-1)  );
ex2_ttype_latch: tri_rlmreg_p
  generic map (width => ex2_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_ttype_offset to ex2_ttype_offset+ex2_ttype_q'length-1),
            scout   => sov(ex2_ttype_offset to ex2_ttype_offset+ex2_ttype_q'length-1),
            din     => ex2_ttype_d(0 to ttype_width-1),
            dout    => ex2_ttype_q(0 to ttype_width-1)  );
ex2_state_latch: tri_rlmreg_p
  generic map (width => ex2_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_state_offset to ex2_state_offset+ex2_state_q'length-1),
            scout   => sov(ex2_state_offset to ex2_state_offset+ex2_state_q'length-1),
            din     => ex2_state_d(0 to state_width),
            dout    => ex2_state_q(0 to state_width)  );
ex2_pid_latch: tri_rlmreg_p
  generic map (width => ex2_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_pid_offset to ex2_pid_offset+ex2_pid_q'length-1),
            scout   => sov(ex2_pid_offset to ex2_pid_offset+ex2_pid_q'length-1),
            din     => ex2_pid_d(0 to pid_width-1),
            dout    => ex2_pid_q(0 to pid_width-1)  );
-------------------------------------------------------------------------------
ex3_valid_latch: tri_rlmreg_p
  generic map (width => ex3_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_valid_offset to ex3_valid_offset+ex3_valid_q'length-1),
            scout   => sov(ex3_valid_offset to ex3_valid_offset+ex3_valid_q'length-1),
            din     => ex3_valid_d(0 to thdid_width-1),
            dout    => ex3_valid_q(0 to thdid_width-1)  );
ex3_flush_latch: tri_rlmreg_p
  generic map (width => ex3_flush_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_flush_offset to ex3_flush_offset+ex3_flush_q'length-1),
            scout   => sov(ex3_flush_offset to ex3_flush_offset+ex3_flush_q'length-1),
            din     => ex3_flush_d(0 to thdid_width-1),
            dout    => ex3_flush_q(0 to thdid_width-1)  );
ex3_ttype_latch: tri_rlmreg_p
  generic map (width => ex3_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_ttype_offset to ex3_ttype_offset+ex3_ttype_q'length-1),
            scout   => sov(ex3_ttype_offset to ex3_ttype_offset+ex3_ttype_q'length-1),
            din     => ex3_ttype_d(0 to ttype_width-1),
            dout    => ex3_ttype_q(0 to ttype_width-1)  );
ex3_state_latch: tri_rlmreg_p
  generic map (width => ex3_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_state_offset to ex3_state_offset+ex3_state_q'length-1),
            scout   => sov(ex3_state_offset to ex3_state_offset+ex3_state_q'length-1),
            din     => ex3_state_d(0 to state_width),
            dout    => ex3_state_q(0 to state_width)  );
ex3_pid_latch: tri_rlmreg_p
  generic map (width => ex3_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_pid_offset to ex3_pid_offset+ex3_pid_q'length-1),
            scout   => sov(ex3_pid_offset to ex3_pid_offset+ex3_pid_q'length-1),
            din     => ex3_pid_d(0 to pid_width-1),
            dout    => ex3_pid_q(0 to pid_width-1)  );
-------------------------------------------------------------------------------
ex4_valid_latch: tri_rlmreg_p
  generic map (width => ex4_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_valid_offset to ex4_valid_offset+ex4_valid_q'length-1),
            scout   => sov(ex4_valid_offset to ex4_valid_offset+ex4_valid_q'length-1),
            din     => ex4_valid_d(0 to thdid_width-1),
            dout    => ex4_valid_q(0 to thdid_width-1)  );
ex4_flush_latch: tri_rlmreg_p
  generic map (width => ex4_flush_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_flush_offset to ex4_flush_offset+ex4_flush_q'length-1),
            scout   => sov(ex4_flush_offset to ex4_flush_offset+ex4_flush_q'length-1),
            din     => ex4_flush_d(0 to thdid_width-1),
            dout    => ex4_flush_q(0 to thdid_width-1)  );
ex4_ttype_latch: tri_rlmreg_p
  generic map (width => ex4_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_ttype_offset to ex4_ttype_offset+ex4_ttype_q'length-1),
            scout   => sov(ex4_ttype_offset to ex4_ttype_offset+ex4_ttype_q'length-1),
            din     => ex4_ttype_d(0 to ttype_width-1),
            dout    => ex4_ttype_q(0 to ttype_width-1)  );
ex4_state_latch: tri_rlmreg_p
  generic map (width => ex4_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_state_offset to ex4_state_offset+ex4_state_q'length-1),
            scout   => sov(ex4_state_offset to ex4_state_offset+ex4_state_q'length-1),
            din     => ex4_state_d(0 to state_width),
            dout    => ex4_state_q(0 to state_width)  );
ex4_pid_latch: tri_rlmreg_p
  generic map (width => ex4_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_pid_offset to ex4_pid_offset+ex4_pid_q'length-1),
            scout   => sov(ex4_pid_offset to ex4_pid_offset+ex4_pid_q'length-1),
            din     => ex4_pid_d(0 to pid_width-1),
            dout    => ex4_pid_q(0 to pid_width-1)  );
-------------------------------------------------------------------------------
ex5_valid_latch: tri_rlmreg_p
  generic map (width => ex5_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_valid_offset to ex5_valid_offset+ex5_valid_q'length-1),
            scout   => sov(ex5_valid_offset to ex5_valid_offset+ex5_valid_q'length-1),
            din     => ex5_valid_d(0 to thdid_width-1),
            dout    => ex5_valid_q(0 to thdid_width-1)  );
ex5_flush_latch: tri_rlmreg_p
  generic map (width => ex5_flush_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_flush_offset to ex5_flush_offset+ex5_flush_q'length-1),
            scout   => sov(ex5_flush_offset to ex5_flush_offset+ex5_flush_q'length-1),
            din     => ex5_flush_d(0 to thdid_width-1),
            dout    => ex5_flush_q(0 to thdid_width-1)  );
ex5_ttype_latch: tri_rlmreg_p
  generic map (width => ex5_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_ttype_offset to ex5_ttype_offset+ex5_ttype_q'length-1),
            scout   => sov(ex5_ttype_offset to ex5_ttype_offset+ex5_ttype_q'length-1),
            din     => ex5_ttype_d(0 to ttype_width-1),
            dout    => ex5_ttype_q(0 to ttype_width-1)  );
ex5_state_latch: tri_rlmreg_p
  generic map (width => ex5_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_state_offset to ex5_state_offset+ex5_state_q'length-1),
            scout   => sov(ex5_state_offset to ex5_state_offset+ex5_state_q'length-1),
            din     => ex5_state_d(0 to state_width),
            dout    => ex5_state_q(0 to state_width)  );
ex5_pid_latch: tri_rlmreg_p
  generic map (width => ex5_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_pid_offset to ex5_pid_offset+ex5_pid_q'length-1),
            scout   => sov(ex5_pid_offset to ex5_pid_offset+ex5_pid_q'length-1),
            din     => ex5_pid_d(0 to pid_width-1),
            dout    => ex5_pid_q(0 to pid_width-1)  );
--------------------------------------------------
ex6_valid_latch: tri_rlmreg_p
  generic map (width => ex6_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_valid_offset to ex6_valid_offset+ex6_valid_q'length-1),
            scout   => sov(ex6_valid_offset to ex6_valid_offset+ex6_valid_q'length-1),
            din     => ex6_valid_d(0 to thdid_width-1),
            dout    => ex6_valid_q(0 to thdid_width-1)  );
ex6_flush_latch: tri_rlmreg_p
  generic map (width => ex6_flush_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_flush_offset to ex6_flush_offset+ex6_flush_q'length-1),
            scout   => sov(ex6_flush_offset to ex6_flush_offset+ex6_flush_q'length-1),
            din     => ex6_flush_d(0 to thdid_width-1),
            dout    => ex6_flush_q(0 to thdid_width-1)  );
ex6_ttype_latch: tri_rlmreg_p
  generic map (width => ex6_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_ttype_offset to ex6_ttype_offset+ex6_ttype_q'length-1),
            scout   => sov(ex6_ttype_offset to ex6_ttype_offset+ex6_ttype_q'length-1),
            din     => ex6_ttype_d(0 to ttype_width-1),
            dout    => ex6_ttype_q(0 to ttype_width-1)  );
ex6_state_latch: tri_rlmreg_p
  generic map (width => ex6_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_state_offset to ex6_state_offset+ex6_state_q'length-1),
            scout   => sov(ex6_state_offset to ex6_state_offset+ex6_state_q'length-1),
            din     => ex6_state_d(0 to state_width),
            dout    => ex6_state_q(0 to state_width)  );
ex6_pid_latch: tri_rlmreg_p
  generic map (width => ex6_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_pid_offset to ex6_pid_offset+ex6_pid_q'length-1),
            scout   => sov(ex6_pid_offset to ex6_pid_offset+ex6_pid_q'length-1),
            din     => ex6_pid_d(0 to pid_width-1),
            dout    => ex6_pid_q(0 to pid_width-1)  );
--------------------------------------------------
-- ws=1 holding latches for tlbwe's
tlb_tag0_latch: tri_rlmreg_p
  generic map (width => tlb_tag0_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_tag0_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_tag0_offset to tlb_tag0_offset+tlb_tag0_q'length-1),
            scout   => sov(tlb_tag0_offset to tlb_tag0_offset+tlb_tag0_q'length-1),
            din     => tlb_tag0_d(0 to tlb_tag_width-1),
            dout    => tlb_tag0_q(0 to tlb_tag_width-1)  );
tlb_tag1_latch: tri_rlmreg_p
  generic map (width => tlb_tag1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_tag1_offset to tlb_tag1_offset+tlb_tag1_q'length-1),
            scout   => sov(tlb_tag1_offset to tlb_tag1_offset+tlb_tag1_q'length-1),
            din     => tlb_tag1_d(0 to tlb_tag_width-1),
            dout    => tlb_tag1_q(0 to tlb_tag_width-1)  );
tlb_tag2_latch: tri_rlmreg_p
  generic map (width => tlb_tag2_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_tag2_offset to tlb_tag2_offset+tlb_tag2_q'length-1),
            scout   => sov(tlb_tag2_offset to tlb_tag2_offset+tlb_tag2_q'length-1),
            din     => tlb_tag2_d(0 to tlb_tag_width-1),
            dout    => tlb_tag2_q(0 to tlb_tag_width-1)  );
-- hashed address input to tlb, tag1 phase
tlb_addr_latch: tri_rlmreg_p
  generic map (width => tlb_addr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_addr_offset to tlb_addr_offset+tlb_addr_q'length-1),
            scout   => sov(tlb_addr_offset to tlb_addr_offset+tlb_addr_q'length-1),
            din     => tlb_addr_d(0 to tlb_addr_width-1),
            dout    => tlb_addr_q(0 to tlb_addr_width-1)  );
-- hashed address input to tlb, tag2 phase
tlb_addr2_latch: tri_rlmreg_p
  generic map (width => tlb_addr2_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_addr2_offset to tlb_addr2_offset+tlb_addr2_q'length-1),
            scout   => sov(tlb_addr2_offset to tlb_addr2_offset+tlb_addr2_q'length-1),
            din     => tlb_addr2_d(0 to tlb_addr_width-1),
            dout    => tlb_addr2_q(0 to tlb_addr_width-1)  );
tlb_write_latch: tri_rlmreg_p
  generic map (width => tlb_write_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_write_offset to tlb_write_offset+tlb_write_q'length-1),
            scout   => sov(tlb_write_offset to tlb_write_offset+tlb_write_q'length-1),
            din     => tlb_write_d(0 to tlb_ways-1),
            dout    => tlb_write_q(0 to tlb_ways-1)  );
ex6_illeg_instr_latch: tri_rlmreg_p
  generic map (width => ex6_illeg_instr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(ex6_illeg_instr_offset to ex6_illeg_instr_offset+ex6_illeg_instr_q'length-1),
            scout   => sov(ex6_illeg_instr_offset to ex6_illeg_instr_offset+ex6_illeg_instr_q'length-1),
            din     => ex6_illeg_instr_d,
            dout    => ex6_illeg_instr_q  );
-- sequencer latches
tlb_seq_latch: tri_rlmreg_p
  generic map (width => tlb_seq_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(tlb_seq_offset to tlb_seq_offset+tlb_seq_q'length-1),
            scout   => sov(tlb_seq_offset to tlb_seq_offset+tlb_seq_q'length-1),
            din     => tlb_seq_d(0 to tlb_seq_width-1),
            dout    => tlb_seq_q(0 to tlb_seq_width-1)  );
derat_taken_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_taken_offset),
            scout   => sov(derat_taken_offset),
            din     => derat_taken_d,
            dout    => derat_taken_q);
xucr4_mmu_mchk_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(xucr4_mmu_mchk_offset),
            scout   => sov(xucr4_mmu_mchk_offset),
            din     => xu_mm_xucr4_mmu_mchk,
            dout    => xu_mm_xucr4_mmu_mchk_q);
-- data out latches
snoop_val_latch: tri_rlmreg_p
  generic map (width => snoop_val_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_snoop_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(snoop_val_offset to snoop_val_offset+snoop_val_q'length-1),
            scout   => sov(snoop_val_offset to snoop_val_offset+snoop_val_q'length-1),
            din     => snoop_val_d,
            dout    => snoop_val_q  );
snoop_attr_latch: tri_rlmreg_p
  generic map (width => snoop_attr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_snoop_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(snoop_attr_offset to snoop_attr_offset+snoop_attr_q'length-1),
            scout   => sov(snoop_attr_offset to snoop_attr_offset+snoop_attr_q'length-1),
            din     => snoop_attr_d,
            dout    => snoop_attr_q  );
snoop_vpn_latch: tri_rlmreg_p
  generic map (width => snoop_vpn_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_snoop_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(snoop_vpn_offset to snoop_vpn_offset+snoop_vpn_q'length-1),
            scout   => sov(snoop_vpn_offset to snoop_vpn_offset+snoop_vpn_q'length-1),
            din     => snoop_vpn_d,
            dout    => snoop_vpn_q  );
tlb_clr_resv_latch: tri_rlmreg_p
  generic map (width => tlb_clr_resv_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_clr_resv_offset to tlb_clr_resv_offset+tlb_clr_resv_q'length-1),
            scout   => sov(tlb_clr_resv_offset to tlb_clr_resv_offset+tlb_clr_resv_q'length-1),
            din     => tlb_clr_resv_d,
            dout    => tlb_clr_resv_q  );
tlb_resv_match_vec_latch: tri_rlmreg_p
  generic map (width => tlb_resv_match_vec_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv_match_vec_offset to tlb_resv_match_vec_offset+tlb_resv_match_vec_q'length-1),
            scout   => sov(tlb_resv_match_vec_offset to tlb_resv_match_vec_offset+tlb_resv_match_vec_q'length-1),
            din     => tlb_resv_match_vec_d,
            dout    => tlb_resv_match_vec_q  );
tlb_resv0_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv0_valid_offset),
            scout   => sov(tlb_resv0_valid_offset),
            din     => tlb_resv0_valid_d,
            dout    => tlb_resv0_valid_q);
tlb_resv0_epn_latch:   tri_rlmreg_p
  generic map (width => tlb_resv0_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv0_epn_offset   to tlb_resv0_epn_offset+tlb_resv0_epn_q'length-1),
            scout   => sov(tlb_resv0_epn_offset   to tlb_resv0_epn_offset+tlb_resv0_epn_q'length-1),
            din     => tlb_resv0_epn_d,
            dout    => tlb_resv0_epn_q);
tlb_resv0_pid_latch:   tri_rlmreg_p
  generic map (width => tlb_resv0_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv0_pid_offset   to tlb_resv0_pid_offset+tlb_resv0_pid_q'length-1),
            scout   => sov(tlb_resv0_pid_offset   to tlb_resv0_pid_offset+tlb_resv0_pid_q'length-1),
            din     => tlb_resv0_pid_d(0   to pid_width-1),
            dout    => tlb_resv0_pid_q(0   to pid_width-1));
tlb_resv0_lpid_latch:   tri_rlmreg_p
  generic map (width => tlb_resv0_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv0_lpid_offset   to tlb_resv0_lpid_offset+tlb_resv0_lpid_q'length-1),
            scout   => sov(tlb_resv0_lpid_offset   to tlb_resv0_lpid_offset+tlb_resv0_lpid_q'length-1),
            din     => tlb_resv0_lpid_d(0   to lpid_width-1),
            dout    => tlb_resv0_lpid_q(0   to lpid_width-1));
tlb_resv0_as_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv0_as_offset),
            scout   => sov(tlb_resv0_as_offset),
            din     => tlb_resv0_as_d,
            dout    => tlb_resv0_as_q);
tlb_resv0_gs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv0_gs_offset),
            scout   => sov(tlb_resv0_gs_offset),
            din     => tlb_resv0_gs_d,
            dout    => tlb_resv0_gs_q);
tlb_resv0_ind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv0_ind_offset),
            scout   => sov(tlb_resv0_ind_offset),
            din     => tlb_resv0_ind_d,
            dout    => tlb_resv0_ind_q);
tlb_resv0_class_latch:   tri_rlmreg_p
  generic map (width => tlb_resv0_class_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv0_class_offset   to tlb_resv0_class_offset+tlb_resv0_class_q'length-1),
            scout   => sov(tlb_resv0_class_offset   to tlb_resv0_class_offset+tlb_resv0_class_q'length-1),
            din     => tlb_resv0_class_d(0   to class_width-1),
            dout    => tlb_resv0_class_q(0   to class_width-1));
tlb_resv1_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv1_valid_offset),
            scout   => sov(tlb_resv1_valid_offset),
            din     => tlb_resv1_valid_d,
            dout    => tlb_resv1_valid_q);
tlb_resv1_epn_latch:   tri_rlmreg_p
  generic map (width => tlb_resv1_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv1_epn_offset   to tlb_resv1_epn_offset+tlb_resv1_epn_q'length-1),
            scout   => sov(tlb_resv1_epn_offset   to tlb_resv1_epn_offset+tlb_resv1_epn_q'length-1),
            din     => tlb_resv1_epn_d,
            dout    => tlb_resv1_epn_q);
tlb_resv1_pid_latch:   tri_rlmreg_p
  generic map (width => tlb_resv1_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv1_pid_offset   to tlb_resv1_pid_offset+tlb_resv1_pid_q'length-1),
            scout   => sov(tlb_resv1_pid_offset   to tlb_resv1_pid_offset+tlb_resv1_pid_q'length-1),
            din     => tlb_resv1_pid_d(0   to pid_width-1),
            dout    => tlb_resv1_pid_q(0   to pid_width-1));
tlb_resv1_lpid_latch:   tri_rlmreg_p
  generic map (width => tlb_resv1_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv1_lpid_offset   to tlb_resv1_lpid_offset+tlb_resv1_lpid_q'length-1),
            scout   => sov(tlb_resv1_lpid_offset   to tlb_resv1_lpid_offset+tlb_resv1_lpid_q'length-1),
            din     => tlb_resv1_lpid_d(0   to lpid_width-1),
            dout    => tlb_resv1_lpid_q(0   to lpid_width-1));
tlb_resv1_as_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv1_as_offset),
            scout   => sov(tlb_resv1_as_offset),
            din     => tlb_resv1_as_d,
            dout    => tlb_resv1_as_q);
tlb_resv1_gs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv1_gs_offset),
            scout   => sov(tlb_resv1_gs_offset),
            din     => tlb_resv1_gs_d,
            dout    => tlb_resv1_gs_q);
tlb_resv1_ind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv1_ind_offset),
            scout   => sov(tlb_resv1_ind_offset),
            din     => tlb_resv1_ind_d,
            dout    => tlb_resv1_ind_q);
tlb_resv1_class_latch:   tri_rlmreg_p
  generic map (width => tlb_resv1_class_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv1_class_offset   to tlb_resv1_class_offset+tlb_resv1_class_q'length-1),
            scout   => sov(tlb_resv1_class_offset   to tlb_resv1_class_offset+tlb_resv1_class_q'length-1),
            din     => tlb_resv1_class_d(0   to class_width-1),
            dout    => tlb_resv1_class_q(0   to class_width-1));
tlb_resv2_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv2_valid_offset),
            scout   => sov(tlb_resv2_valid_offset),
            din     => tlb_resv2_valid_d,
            dout    => tlb_resv2_valid_q);
tlb_resv2_epn_latch:   tri_rlmreg_p
  generic map (width => tlb_resv2_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv2_epn_offset   to tlb_resv2_epn_offset+tlb_resv2_epn_q'length-1),
            scout   => sov(tlb_resv2_epn_offset   to tlb_resv2_epn_offset+tlb_resv2_epn_q'length-1),
            din     => tlb_resv2_epn_d,
            dout    => tlb_resv2_epn_q);
tlb_resv2_pid_latch:   tri_rlmreg_p
  generic map (width => tlb_resv2_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv2_pid_offset   to tlb_resv2_pid_offset+tlb_resv2_pid_q'length-1),
            scout   => sov(tlb_resv2_pid_offset   to tlb_resv2_pid_offset+tlb_resv2_pid_q'length-1),
            din     => tlb_resv2_pid_d(0   to pid_width-1),
            dout    => tlb_resv2_pid_q(0   to pid_width-1));
tlb_resv2_lpid_latch:   tri_rlmreg_p
  generic map (width => tlb_resv2_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv2_lpid_offset   to tlb_resv2_lpid_offset+tlb_resv2_lpid_q'length-1),
            scout   => sov(tlb_resv2_lpid_offset   to tlb_resv2_lpid_offset+tlb_resv2_lpid_q'length-1),
            din     => tlb_resv2_lpid_d(0   to lpid_width-1),
            dout    => tlb_resv2_lpid_q(0   to lpid_width-1));
tlb_resv2_as_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv2_as_offset),
            scout   => sov(tlb_resv2_as_offset),
            din     => tlb_resv2_as_d,
            dout    => tlb_resv2_as_q);
tlb_resv2_gs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv2_gs_offset),
            scout   => sov(tlb_resv2_gs_offset),
            din     => tlb_resv2_gs_d,
            dout    => tlb_resv2_gs_q);
tlb_resv2_ind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv2_ind_offset),
            scout   => sov(tlb_resv2_ind_offset),
            din     => tlb_resv2_ind_d,
            dout    => tlb_resv2_ind_q);
tlb_resv2_class_latch:   tri_rlmreg_p
  generic map (width => tlb_resv2_class_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv2_class_offset   to tlb_resv2_class_offset+tlb_resv2_class_q'length-1),
            scout   => sov(tlb_resv2_class_offset   to tlb_resv2_class_offset+tlb_resv2_class_q'length-1),
            din     => tlb_resv2_class_d(0   to class_width-1),
            dout    => tlb_resv2_class_q(0   to class_width-1));
tlb_resv3_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv3_valid_offset),
            scout   => sov(tlb_resv3_valid_offset),
            din     => tlb_resv3_valid_d,
            dout    => tlb_resv3_valid_q);
tlb_resv3_epn_latch:   tri_rlmreg_p
  generic map (width => tlb_resv3_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv3_epn_offset   to tlb_resv3_epn_offset+tlb_resv3_epn_q'length-1),
            scout   => sov(tlb_resv3_epn_offset   to tlb_resv3_epn_offset+tlb_resv3_epn_q'length-1),
            din     => tlb_resv3_epn_d,
            dout    => tlb_resv3_epn_q);
tlb_resv3_pid_latch:   tri_rlmreg_p
  generic map (width => tlb_resv3_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv3_pid_offset   to tlb_resv3_pid_offset+tlb_resv3_pid_q'length-1),
            scout   => sov(tlb_resv3_pid_offset   to tlb_resv3_pid_offset+tlb_resv3_pid_q'length-1),
            din     => tlb_resv3_pid_d(0   to pid_width-1),
            dout    => tlb_resv3_pid_q(0   to pid_width-1));
tlb_resv3_lpid_latch:   tri_rlmreg_p
  generic map (width => tlb_resv3_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv3_lpid_offset   to tlb_resv3_lpid_offset+tlb_resv3_lpid_q'length-1),
            scout   => sov(tlb_resv3_lpid_offset   to tlb_resv3_lpid_offset+tlb_resv3_lpid_q'length-1),
            din     => tlb_resv3_lpid_d(0   to lpid_width-1),
            dout    => tlb_resv3_lpid_q(0   to lpid_width-1));
tlb_resv3_as_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv3_as_offset),
            scout   => sov(tlb_resv3_as_offset),
            din     => tlb_resv3_as_d,
            dout    => tlb_resv3_as_q);
tlb_resv3_gs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv3_gs_offset),
            scout   => sov(tlb_resv3_gs_offset),
            din     => tlb_resv3_gs_d,
            dout    => tlb_resv3_gs_q);
tlb_resv3_ind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv3_ind_offset),
            scout   => sov(tlb_resv3_ind_offset),
            din     => tlb_resv3_ind_d,
            dout    => tlb_resv3_ind_q);
tlb_resv3_class_latch:   tri_rlmreg_p
  generic map (width => tlb_resv3_class_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tlb_delayed_act_q(5+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_resv3_class_offset   to tlb_resv3_class_offset+tlb_resv3_class_q'length-1),
            scout   => sov(tlb_resv3_class_offset   to tlb_resv3_class_offset+tlb_resv3_class_q'length-1),
            din     => tlb_resv3_class_d(0   to class_width-1),
            dout    => tlb_resv3_class_q(0   to class_width-1));
ptereload_req_pte_latch: tri_rlmreg_p
  generic map (width => ptereload_req_pte_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => ptereload_req_valid,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(ptereload_req_pte_offset to ptereload_req_pte_offset+ptereload_req_pte_q'length-1),
            scout   => sov(ptereload_req_pte_offset to ptereload_req_pte_offset+ptereload_req_pte_q'length-1),
            din     => ptereload_req_pte_d,
            dout    => ptereload_req_pte_q  );
-- power clock gating latches
tlb_delayed_act_latch: tri_rlmreg_p
  generic map (width => tlb_delayed_act_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(tlb_delayed_act_offset to tlb_delayed_act_offset+tlb_delayed_act_q'length-1),
            scout   => sov(tlb_delayed_act_offset to tlb_delayed_act_offset+tlb_delayed_act_q'length-1),
            din     => tlb_delayed_act_d,
            dout    => tlb_delayed_act_q  );
-- spare latches
tlb_ctl_spare_latch: tri_rlmreg_p
  generic map (width => tlb_ctl_spare_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(tlb_ctl_spare_offset to tlb_ctl_spare_offset+tlb_ctl_spare_q'length-1),
            scout   => sov(tlb_ctl_spare_offset to tlb_ctl_spare_offset+tlb_ctl_spare_q'length-1),
            din     => tlb_ctl_spare_q,
            dout    => tlb_ctl_spare_q  );
-- non-scannable timing latches
tlb_resv0_tag1_match_latch   : tri_regk
  generic map (width => 11, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => xu_mm_ccr2_notlb_b,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din(0)  => tlb_resv0_tag0_lpid_match,
            din(1)  => tlb_resv0_tag0_pid_match,
            din(2)  => tlb_resv0_tag0_as_snoop_match,
            din(3)  => tlb_resv0_tag0_gs_snoop_match,
            din(4)  => tlb_resv0_tag0_as_tlbwe_match,
            din(5)  => tlb_resv0_tag0_gs_tlbwe_match,
            din(6)  => tlb_resv0_tag0_ind_match,
            din(7)  => tlb_resv0_tag0_epn_loc_match,
            din(8)  => tlb_resv0_tag0_epn_glob_match,
            din(9)  => tlb_resv0_tag0_class_match,
            din(10) => tlb_seq_snoop_resv,
            dout(0) => tlb_resv0_tag1_lpid_match,
            dout(1) => tlb_resv0_tag1_pid_match,
            dout(2) => tlb_resv0_tag1_as_snoop_match,
            dout(3) => tlb_resv0_tag1_gs_snoop_match,
            dout(4) => tlb_resv0_tag1_as_tlbwe_match,
            dout(5) => tlb_resv0_tag1_gs_tlbwe_match,
            dout(6) => tlb_resv0_tag1_ind_match,
            dout(7) => tlb_resv0_tag1_epn_loc_match,
            dout(8) => tlb_resv0_tag1_epn_glob_match,
            dout(9) => tlb_resv0_tag1_class_match,
            dout(10) => tlb_seq_snoop_resv_q(0));
tlb_resv1_tag1_match_latch   : tri_regk
  generic map (width => 11, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => xu_mm_ccr2_notlb_b,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din(0)  => tlb_resv1_tag0_lpid_match,
            din(1)  => tlb_resv1_tag0_pid_match,
            din(2)  => tlb_resv1_tag0_as_snoop_match,
            din(3)  => tlb_resv1_tag0_gs_snoop_match,
            din(4)  => tlb_resv1_tag0_as_tlbwe_match,
            din(5)  => tlb_resv1_tag0_gs_tlbwe_match,
            din(6)  => tlb_resv1_tag0_ind_match,
            din(7)  => tlb_resv1_tag0_epn_loc_match,
            din(8)  => tlb_resv1_tag0_epn_glob_match,
            din(9)  => tlb_resv1_tag0_class_match,
            din(10) => tlb_seq_snoop_resv,
            dout(0) => tlb_resv1_tag1_lpid_match,
            dout(1) => tlb_resv1_tag1_pid_match,
            dout(2) => tlb_resv1_tag1_as_snoop_match,
            dout(3) => tlb_resv1_tag1_gs_snoop_match,
            dout(4) => tlb_resv1_tag1_as_tlbwe_match,
            dout(5) => tlb_resv1_tag1_gs_tlbwe_match,
            dout(6) => tlb_resv1_tag1_ind_match,
            dout(7) => tlb_resv1_tag1_epn_loc_match,
            dout(8) => tlb_resv1_tag1_epn_glob_match,
            dout(9) => tlb_resv1_tag1_class_match,
            dout(10) => tlb_seq_snoop_resv_q(1));
tlb_resv2_tag1_match_latch   : tri_regk
  generic map (width => 11, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => xu_mm_ccr2_notlb_b,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din(0)  => tlb_resv2_tag0_lpid_match,
            din(1)  => tlb_resv2_tag0_pid_match,
            din(2)  => tlb_resv2_tag0_as_snoop_match,
            din(3)  => tlb_resv2_tag0_gs_snoop_match,
            din(4)  => tlb_resv2_tag0_as_tlbwe_match,
            din(5)  => tlb_resv2_tag0_gs_tlbwe_match,
            din(6)  => tlb_resv2_tag0_ind_match,
            din(7)  => tlb_resv2_tag0_epn_loc_match,
            din(8)  => tlb_resv2_tag0_epn_glob_match,
            din(9)  => tlb_resv2_tag0_class_match,
            din(10) => tlb_seq_snoop_resv,
            dout(0) => tlb_resv2_tag1_lpid_match,
            dout(1) => tlb_resv2_tag1_pid_match,
            dout(2) => tlb_resv2_tag1_as_snoop_match,
            dout(3) => tlb_resv2_tag1_gs_snoop_match,
            dout(4) => tlb_resv2_tag1_as_tlbwe_match,
            dout(5) => tlb_resv2_tag1_gs_tlbwe_match,
            dout(6) => tlb_resv2_tag1_ind_match,
            dout(7) => tlb_resv2_tag1_epn_loc_match,
            dout(8) => tlb_resv2_tag1_epn_glob_match,
            dout(9) => tlb_resv2_tag1_class_match,
            dout(10) => tlb_seq_snoop_resv_q(2));
tlb_resv3_tag1_match_latch   : tri_regk
  generic map (width => 11, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => xu_mm_ccr2_notlb_b,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din(0)  => tlb_resv3_tag0_lpid_match,
            din(1)  => tlb_resv3_tag0_pid_match,
            din(2)  => tlb_resv3_tag0_as_snoop_match,
            din(3)  => tlb_resv3_tag0_gs_snoop_match,
            din(4)  => tlb_resv3_tag0_as_tlbwe_match,
            din(5)  => tlb_resv3_tag0_gs_tlbwe_match,
            din(6)  => tlb_resv3_tag0_ind_match,
            din(7)  => tlb_resv3_tag0_epn_loc_match,
            din(8)  => tlb_resv3_tag0_epn_glob_match,
            din(9)  => tlb_resv3_tag0_class_match,
            din(10) => tlb_seq_snoop_resv,
            dout(0) => tlb_resv3_tag1_lpid_match,
            dout(1) => tlb_resv3_tag1_pid_match,
            dout(2) => tlb_resv3_tag1_as_snoop_match,
            dout(3) => tlb_resv3_tag1_gs_snoop_match,
            dout(4) => tlb_resv3_tag1_as_tlbwe_match,
            dout(5) => tlb_resv3_tag1_gs_tlbwe_match,
            dout(6) => tlb_resv3_tag1_ind_match,
            dout(7) => tlb_resv3_tag1_epn_loc_match,
            dout(8) => tlb_resv3_tag1_epn_glob_match,
            dout(9) => tlb_resv3_tag1_class_match,
            dout(10) => tlb_seq_snoop_resv_q(3));
--------------------------------------------------
-- thold/sg latches
--------------------------------------------------
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
            forcee => pc_func_slp_nsl_force,
            thold_b     => pc_func_slp_nsl_thold_0_b);
-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
siv(0 TO scan_right) <=  sov(1 to scan_right) & ac_func_scan_in;
ac_func_scan_out  <=  sov(0);
END MMQ_TLB_CTL;
