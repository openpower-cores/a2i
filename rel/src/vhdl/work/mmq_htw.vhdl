-- © IBM Corp. 2020
-- Licensed under the Apache License, Version 2.0 (the "License"), as modified by
-- the terms below; you may not use the files in this repository except in
-- compliance with the License as modified.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
--
-- Modified Terms:
--
--    1) For the purpose of the patent license granted to you in Section 3 of the
--    License, the "Work" hereby includes implementations of the work of authorship
--    in physical form.
--
--    2) Notwithstanding any terms to the contrary in the License, any licenses
--    necessary for implementation of the Work that are available from OpenPOWER
--    via the Power ISA End User License Agreement (EULA) are explicitly excluded
--    hereunder, and may be obtained from OpenPOWER under the terms and conditions
--    of the EULA.  
--
-- Unless required by applicable law or agreed to in writing, the reference design
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
-- for the specific language governing permissions and limitations under the License.
-- 
-- Additional rights, including the ability to physically implement a softcore that
-- is compliant with the required sections of the Power ISA Specification, are
-- available at no cost under the terms of the OpenPOWER Power ISA EULA, which can be
-- obtained (along with the Power ISA) here: https://openpowerfoundation.org. 

			

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

entity mmq_htw is
  generic(thdid_width       : integer := 4;
            pid_width          : integer := 14;
            lpid_width         : integer := 8;
            htw_seq_width      : integer := 2;
            pte_seq_width      : integer := 3;
            tlb_way_width     : natural := 168;
            tlb_word_width    : natural := 84;
            real_addr_width    : integer := 42;
            epn_width          : integer := 52;
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
ac_func_scan_in          :in     std_ulogic_vector(0 to 1);
ac_func_scan_out         :out    std_ulogic_vector(0 to 1);
pc_sg_2                : in     std_ulogic;
pc_func_sl_thold_2     : in     std_ulogic;
pc_func_slp_sl_thold_2 : in     std_ulogic;
xu_mm_ccr2_notlb_b   : in     std_ulogic;
mmucr2_act_override  : in     std_ulogic;
tlb_delayed_act    : in std_ulogic_vector(24 to 28);
tlb_ctl_tag2_flush            : in std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_tag3_flush            : in std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_tag4_flush            : in std_ulogic_vector(0 to thdid_width-1);
tlb_tag2        : in std_ulogic_vector(0 to tlb_tag_width-1);
tlb_tag5_except    : in std_ulogic_vector(0 to thdid_width-1);
tlb_htw_req_valid : in std_ulogic;
tlb_htw_req_tag   : in std_ulogic_vector(0 to tlb_tag_width-1);
tlb_htw_req_way   : in std_ulogic_vector(tlb_word_width to tlb_way_width-1);
htw_lsu_req_valid        : out     std_ulogic;
htw_lsu_thdid            : out     std_ulogic_vector(0 to thdid_width-1);
htw_dbg_lsu_thdid        : out     std_ulogic_vector(0 to 1);
htw_lsu_ttype            : out     std_ulogic_vector(0 to 1);
htw_lsu_wimge            : out     std_ulogic_vector(0 to 4);
htw_lsu_u                : out     std_ulogic_vector(0 to 3);
htw_lsu_addr             : out     std_ulogic_vector(64-real_addr_width to 63);
htw_lsu_req_taken        : in    std_ulogic;
htw_quiesce              : out     std_ulogic_vector(0 to thdid_width-1);
htw_req0_valid      : out     std_ulogic;
htw_req0_thdid      : out     std_ulogic_vector(0 to thdid_width-1);
htw_req0_type       : out     std_ulogic_vector(0 to 1);
htw_req1_valid      : out     std_ulogic;
htw_req1_thdid      : out     std_ulogic_vector(0 to thdid_width-1);
htw_req1_type       : out     std_ulogic_vector(0 to 1);
htw_req2_valid      : out     std_ulogic;
htw_req2_thdid      : out     std_ulogic_vector(0 to thdid_width-1);
htw_req2_type       : out     std_ulogic_vector(0 to 1);
htw_req3_valid      : out     std_ulogic;
htw_req3_thdid      : out     std_ulogic_vector(0 to thdid_width-1);
htw_req3_type       : out     std_ulogic_vector(0 to 1);
ptereload_req_valid : out std_ulogic;
ptereload_req_tag   : out std_ulogic_vector(0 to tlb_tag_width-1);
ptereload_req_pte   : out std_ulogic_vector(0 to pte_width-1);
ptereload_req_taken : in std_ulogic;
an_ac_reld_core_tag        : in    std_ulogic_vector(0 to 4);
an_ac_reld_data            : in    std_ulogic_vector(0 to 127);
an_ac_reld_data_vld        : in    std_ulogic;
an_ac_reld_ecc_err         : in    std_ulogic;
an_ac_reld_ecc_err_ue      : in    std_ulogic;
an_ac_reld_qw              : in    std_ulogic_vector(58 to 59);
an_ac_reld_ditc            : in    std_ulogic;
an_ac_reld_crit_qw         : in    std_ulogic;
htw_dbg_seq_idle                 : out  std_ulogic;
htw_dbg_pte0_seq_idle            : out  std_ulogic;
htw_dbg_pte1_seq_idle            : out  std_ulogic;
htw_dbg_seq_q                    : out std_ulogic_vector(0 to 1);
htw_dbg_inptr_q                  : out std_ulogic_vector(0 to 1);
htw_dbg_pte0_seq_q               : out std_ulogic_vector(0 to 2);
htw_dbg_pte1_seq_q               : out std_ulogic_vector(0 to 2);
htw_dbg_ptereload_ptr_q          : out std_ulogic;
htw_dbg_lsuptr_q                 : out std_ulogic_vector(0 to 1);
htw_dbg_req_valid_q              : out std_ulogic_vector(0 to 3);
htw_dbg_resv_valid_vec           : out std_ulogic_vector(0 to 3);
htw_dbg_tag4_clr_resv_q          : out std_ulogic_vector(0 to 3);
htw_dbg_tag4_clr_resv_terms      : out std_ulogic_vector(0 to 3);
htw_dbg_pte0_score_ptr_q         : out std_ulogic_vector(0 to 1);
htw_dbg_pte0_score_cl_offset_q   : out std_ulogic_vector(58 to 60);
htw_dbg_pte0_score_error_q       : out std_ulogic_vector(0 to 2);
htw_dbg_pte0_score_qwbeat_q      : out std_ulogic_vector(0 to 3);
htw_dbg_pte0_score_pending_q     : out std_ulogic;
htw_dbg_pte0_score_ibit_q        : out std_ulogic;
htw_dbg_pte0_score_dataval_q     : out std_ulogic;
htw_dbg_pte0_reld_for_me_tm1     : out std_ulogic;
htw_dbg_pte1_score_ptr_q         : out std_ulogic_vector(0 to 1);
htw_dbg_pte1_score_cl_offset_q   : out std_ulogic_vector(58 to 60);
htw_dbg_pte1_score_error_q       : out std_ulogic_vector(0 to 2);
htw_dbg_pte1_score_qwbeat_q      : out std_ulogic_vector(0 to 3);
htw_dbg_pte1_score_pending_q     : out std_ulogic;
htw_dbg_pte1_score_ibit_q        : out std_ulogic;
htw_dbg_pte1_score_dataval_q     : out std_ulogic;
htw_dbg_pte1_reld_for_me_tm1     : out std_ulogic

);
end mmq_htw;
ARCHITECTURE MMQ_HTW
          OF MMQ_HTW
          IS
constant MMU_Mode_Value : std_ulogic := '0';
constant TlbSel_Tlb : std_ulogic_vector(0 to 1) := "00";
constant TlbSel_IErat : std_ulogic_vector(0 to 1) := "10";
constant TlbSel_DErat : std_ulogic_vector(0 to 1) := "11";
constant Core_Tag0_Value : std_ulogic_vector(0 to 4) := "01100";
constant Core_Tag1_Value : std_ulogic_vector(0 to 4) := "01101";
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
constant HtwSeq_Idle  : std_ulogic_vector(0 to 1) := "00";
constant HtwSeq_Stg1  : std_ulogic_vector(0 to 1) := "01";
constant HtwSeq_Stg2  : std_ulogic_vector(0 to 1) := "11";
constant HtwSeq_Stg3  : std_ulogic_vector(0 to 1) := "10";
constant PteSeq_Idle  : std_ulogic_vector(0 to 2) := "000";
constant PteSeq_Stg1  : std_ulogic_vector(0 to 2) := "001";
constant PteSeq_Stg2  : std_ulogic_vector(0 to 2) := "011";
constant PteSeq_Stg3  : std_ulogic_vector(0 to 2) := "010";
constant PteSeq_Stg4  : std_ulogic_vector(0 to 2) := "110";
constant PteSeq_Stg5  : std_ulogic_vector(0 to 2) := "111";
constant PteSeq_Stg6  : std_ulogic_vector(0 to 2) := "101";
constant PteSeq_Stg7  : std_ulogic_vector(0 to 2) := "100";
constant tlb_htw_req0_valid_offset : natural := 0;
constant tlb_htw_req0_pending_offset   : natural := tlb_htw_req0_valid_offset + 1;
constant tlb_htw_req0_tag_offset   : natural := tlb_htw_req0_pending_offset + 1;
constant tlb_htw_req0_way_offset   : natural := tlb_htw_req0_tag_offset + tlb_tag_width;
constant tlb_htw_req1_valid_offset   : natural := tlb_htw_req0_way_offset     + tlb_word_width;
constant tlb_htw_req1_pending_offset   : natural := tlb_htw_req1_valid_offset   + 1;
constant tlb_htw_req1_tag_offset     : natural := tlb_htw_req1_pending_offset   + 1;
constant tlb_htw_req1_way_offset     : natural := tlb_htw_req1_tag_offset   + tlb_tag_width;
constant tlb_htw_req2_valid_offset   : natural := tlb_htw_req1_way_offset     + tlb_word_width;
constant tlb_htw_req2_pending_offset   : natural := tlb_htw_req2_valid_offset   + 1;
constant tlb_htw_req2_tag_offset     : natural := tlb_htw_req2_pending_offset   + 1;
constant tlb_htw_req2_way_offset     : natural := tlb_htw_req2_tag_offset   + tlb_tag_width;
constant tlb_htw_req3_valid_offset   : natural := tlb_htw_req2_way_offset     + tlb_word_width;
constant tlb_htw_req3_pending_offset   : natural := tlb_htw_req3_valid_offset   + 1;
constant tlb_htw_req3_tag_offset     : natural := tlb_htw_req3_pending_offset   + 1;
constant tlb_htw_req3_way_offset     : natural := tlb_htw_req3_tag_offset   + tlb_tag_width;
constant spare_a_offset               : natural := tlb_htw_req3_way_offset + tlb_word_width;
constant scan_right_0                : natural := spare_a_offset + 16 -1;
constant htw_seq_offset             : natural := 0;
constant htw_inptr_offset           : natural := htw_seq_offset + htw_seq_width;
constant htw_lsuptr_offset          : natural := htw_inptr_offset + 2;
constant htw_lsu_ttype_offset       : natural := htw_lsuptr_offset + 2;
constant htw_lsu_thdid_offset       : natural := htw_lsu_ttype_offset + 2;
constant htw_lsu_wimge_offset       : natural := htw_lsu_thdid_offset + thdid_width;
constant htw_lsu_u_offset           : natural := htw_lsu_wimge_offset + 5;
constant htw_lsu_addr_offset        : natural := htw_lsu_u_offset + 4;
constant pte0_seq_offset             : natural := htw_lsu_addr_offset + real_addr_width;
constant pte0_score_ptr_offset       : natural := pte0_seq_offset + pte_seq_width;
constant pte0_score_cl_offset_offset : natural := pte0_score_ptr_offset + 2;
constant pte0_score_error_offset     : natural := pte0_score_cl_offset_offset + 3;
constant pte0_score_qwbeat_offset    : natural := pte0_score_error_offset + 3;
constant pte0_score_ibit_offset      : natural := pte0_score_qwbeat_offset + 4;
constant pte0_score_pending_offset   : natural := pte0_score_ibit_offset + 1;
constant pte0_score_dataval_offset   : natural := pte0_score_pending_offset + 1;
constant pte1_seq_offset             : natural := pte0_score_dataval_offset + 1;
constant pte1_score_ptr_offset       : natural := pte1_seq_offset + pte_seq_width;
constant pte1_score_cl_offset_offset : natural := pte1_score_ptr_offset + 2;
constant pte1_score_error_offset     : natural := pte1_score_cl_offset_offset + 3;
constant pte1_score_qwbeat_offset    : natural := pte1_score_error_offset + 3;
constant pte1_score_ibit_offset      : natural := pte1_score_qwbeat_offset + 4;
constant pte1_score_pending_offset   : natural := pte1_score_ibit_offset + 1;
constant pte1_score_dataval_offset   : natural := pte1_score_pending_offset + 1;
constant pte_load_ptr_offset         : natural := pte1_score_dataval_offset + 1;
constant ptereload_ptr_offset        : natural := pte_load_ptr_offset + 1;
--  ptereload_ptr_offset + 1 phase
constant reld_core_tag_tm1_offset : natural := ptereload_ptr_offset + 1;
constant reld_qw_tm1_offset       : natural := reld_core_tag_tm1_offset + 5;
constant reld_crit_qw_tm1_offset  : natural := reld_qw_tm1_offset + 2;
constant reld_ditc_tm1_offset     : natural := reld_crit_qw_tm1_offset + 1;
constant reld_data_vld_tm1_offset : natural := reld_ditc_tm1_offset + 1;
--  reld_data_vld_tm1_offset + 1 phase
constant reld_core_tag_t_offset   : natural := reld_data_vld_tm1_offset + 1;
constant reld_qw_t_offset         : natural := reld_core_tag_t_offset   + 5;
constant reld_crit_qw_t_offset    : natural := reld_qw_t_offset   + 2;
constant reld_ditc_t_offset       : natural := reld_crit_qw_t_offset   + 1;
constant reld_data_vld_t_offset   : natural := reld_ditc_t_offset   + 1;
--  reld_data_vld_t_offset + 1 phase
constant reld_core_tag_tp1_offset : natural := reld_data_vld_t_offset + 1;
constant reld_qw_tp1_offset       : natural := reld_core_tag_tp1_offset + 5;
constant reld_crit_qw_tp1_offset  : natural := reld_qw_tp1_offset + 2;
constant reld_ditc_tp1_offset     : natural := reld_crit_qw_tp1_offset + 1;
constant reld_data_vld_tp1_offset : natural := reld_ditc_tp1_offset + 1;
--  reld_data_vld_tp1_offset + 1 phase
constant reld_core_tag_tp2_offset : natural := reld_data_vld_tp1_offset + 1;
constant reld_qw_tp2_offset       : natural := reld_core_tag_tp2_offset + 5;
constant reld_crit_qw_tp2_offset  : natural := reld_qw_tp2_offset + 2;
constant reld_ditc_tp2_offset     : natural := reld_crit_qw_tp2_offset + 1;
constant reld_data_vld_tp2_offset : natural := reld_ditc_tp2_offset + 1;
constant reld_ecc_err_tp2_offset     : natural := reld_data_vld_tp2_offset + 1;
constant reld_ecc_err_ue_tp2_offset  : natural := reld_ecc_err_tp2_offset + 1;
constant reld_data_tp1_offset     : natural := reld_ecc_err_ue_tp2_offset + 1;
constant reld_data_tp2_offset     : natural := reld_data_tp1_offset + 128;
constant pte0_reld_data_tp3_offset  : natural := reld_data_tp2_offset + 128;
constant pte1_reld_data_tp3_offset  : natural := pte0_reld_data_tp3_offset + 64;
constant htw_tag3_offset            : natural := pte1_reld_data_tp3_offset + 64;
constant htw_tag4_clr_resv_offset        : natural := htw_tag3_offset + tlb_tag_width;
constant htw_tag5_clr_resv_offset        : natural := htw_tag4_clr_resv_offset + thdid_width;
constant spare_b_offset               : natural := htw_tag5_clr_resv_offset + thdid_width;
constant scan_right_1               : natural := spare_b_offset + 16 -1;
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
constant tagpos_ltwe     : natural  := 106;
constant tagpos_lpte     : natural  := 107;
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
-- Latch signals
signal htw_seq_d, htw_seq_q            : std_ulogic_vector(0 to 1);
signal htw_inptr_d, htw_inptr_q      : std_ulogic_vector(0 to 1);
signal htw_lsuptr_d, htw_lsuptr_q    : std_ulogic_vector(0 to 1);
signal htw_lsu_ttype_d, htw_lsu_ttype_q             : std_ulogic_vector(0 to 1);
signal htw_lsu_thdid_d, htw_lsu_thdid_q             : std_ulogic_vector(0 to thdid_width-1);
signal htw_lsu_wimge_d, htw_lsu_wimge_q             : std_ulogic_vector(0 to 4);
signal htw_lsu_u_d, htw_lsu_u_q                     : std_ulogic_vector(0 to 3);
signal htw_lsu_addr_d, htw_lsu_addr_q               : std_ulogic_vector(64-real_addr_width to 63);
signal pte0_seq_d,   pte0_seq_q              : std_ulogic_vector(0 to 2);
signal pte0_score_ptr_d,   pte0_score_ptr_q              : std_ulogic_vector(0 to 1);
signal pte0_score_cl_offset_d,   pte0_score_cl_offset_q    : std_ulogic_vector(58 to 60);
signal pte0_score_error_d,   pte0_score_error_q          : std_ulogic_vector(0 to 2);
signal pte0_score_qwbeat_d,   pte0_score_qwbeat_q          : std_ulogic_vector(0 to 3);
signal pte0_score_pending_d,   pte0_score_pending_q              : std_ulogic;
signal pte0_score_ibit_d,   pte0_score_ibit_q                    : std_ulogic;
signal pte0_score_dataval_d,   pte0_score_dataval_q              : std_ulogic;
signal pte1_seq_d,   pte1_seq_q              : std_ulogic_vector(0 to 2);
signal pte1_score_ptr_d,   pte1_score_ptr_q              : std_ulogic_vector(0 to 1);
signal pte1_score_cl_offset_d,   pte1_score_cl_offset_q    : std_ulogic_vector(58 to 60);
signal pte1_score_error_d,   pte1_score_error_q          : std_ulogic_vector(0 to 2);
signal pte1_score_qwbeat_d,   pte1_score_qwbeat_q          : std_ulogic_vector(0 to 3);
signal pte1_score_pending_d,   pte1_score_pending_q              : std_ulogic;
signal pte1_score_ibit_d,   pte1_score_ibit_q                    : std_ulogic;
signal pte1_score_dataval_d,   pte1_score_dataval_q              : std_ulogic;
signal ptereload_ptr_d, ptereload_ptr_q            : std_ulogic;
signal pte_load_ptr_d, pte_load_ptr_q            : std_ulogic;
signal tlb_htw_req0_valid_d,   tlb_htw_req0_valid_q    : std_ulogic;
signal tlb_htw_req0_pending_d,   tlb_htw_req0_pending_q    : std_ulogic;
signal tlb_htw_req0_tag_d,   tlb_htw_req0_tag_q    : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_htw_req0_way_d,   tlb_htw_req0_way_q    : std_ulogic_vector(tlb_word_width to tlb_way_width-1);
signal tlb_htw_req0_tag_act    : std_ulogic;
signal tlb_htw_req1_valid_d,   tlb_htw_req1_valid_q    : std_ulogic;
signal tlb_htw_req1_pending_d,   tlb_htw_req1_pending_q    : std_ulogic;
signal tlb_htw_req1_tag_d,   tlb_htw_req1_tag_q    : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_htw_req1_way_d,   tlb_htw_req1_way_q    : std_ulogic_vector(tlb_word_width to tlb_way_width-1);
signal tlb_htw_req1_tag_act    : std_ulogic;
signal tlb_htw_req2_valid_d,   tlb_htw_req2_valid_q    : std_ulogic;
signal tlb_htw_req2_pending_d,   tlb_htw_req2_pending_q    : std_ulogic;
signal tlb_htw_req2_tag_d,   tlb_htw_req2_tag_q    : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_htw_req2_way_d,   tlb_htw_req2_way_q    : std_ulogic_vector(tlb_word_width to tlb_way_width-1);
signal tlb_htw_req2_tag_act    : std_ulogic;
signal tlb_htw_req3_valid_d,   tlb_htw_req3_valid_q    : std_ulogic;
signal tlb_htw_req3_pending_d,   tlb_htw_req3_pending_q    : std_ulogic;
signal tlb_htw_req3_tag_d,   tlb_htw_req3_tag_q    : std_ulogic_vector(0 to tlb_tag_width-1);
signal tlb_htw_req3_way_d,   tlb_htw_req3_way_q    : std_ulogic_vector(tlb_word_width to tlb_way_width-1);
signal tlb_htw_req3_tag_act    : std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
--  t minus 1 phase
signal reld_core_tag_tm1_d, reld_core_tag_tm1_q : std_ulogic_vector(0 to 4);
signal reld_qw_tm1_d, reld_qw_tm1_q             : std_ulogic_vector(0 to 1);
signal reld_crit_qw_tm1_d, reld_crit_qw_tm1_q   : std_ulogic;
signal reld_ditc_tm1_d, reld_ditc_tm1_q         : std_ulogic;
signal reld_data_vld_tm1_d, reld_data_vld_tm1_q : std_ulogic;
--  t   phase
signal reld_core_tag_t_d,   reld_core_tag_t_q   : std_ulogic_vector(0 to 4);
signal reld_qw_t_d,   reld_qw_t_q               : std_ulogic_vector(0 to 1);
signal reld_crit_qw_t_d,   reld_crit_qw_t_q     : std_ulogic;
signal reld_ditc_t_d,   reld_ditc_t_q           : std_ulogic;
signal reld_data_vld_t_d,   reld_data_vld_t_q   : std_ulogic;
--  t plus 1 phase
signal reld_core_tag_tp1_d, reld_core_tag_tp1_q : std_ulogic_vector(0 to 4);
signal reld_qw_tp1_d, reld_qw_tp1_q             : std_ulogic_vector(0 to 1);
signal reld_crit_qw_tp1_d, reld_crit_qw_tp1_q   : std_ulogic;
signal reld_ditc_tp1_d, reld_ditc_tp1_q         : std_ulogic;
signal reld_data_vld_tp1_d, reld_data_vld_tp1_q : std_ulogic;
signal reld_data_tp1_d, reld_data_tp1_q         : std_ulogic_vector(0 to 127);
--  t plus 2 phase
signal reld_core_tag_tp2_d, reld_core_tag_tp2_q : std_ulogic_vector(0 to 4);
signal reld_qw_tp2_d, reld_qw_tp2_q             : std_ulogic_vector(0 to 1);
signal reld_crit_qw_tp2_d, reld_crit_qw_tp2_q   : std_ulogic;
signal reld_ditc_tp2_d, reld_ditc_tp2_q         : std_ulogic;
signal reld_data_vld_tp2_d, reld_data_vld_tp2_q : std_ulogic;
signal reld_data_tp2_d, reld_data_tp2_q         : std_ulogic_vector(0 to 127);
signal reld_ecc_err_tp2_d, reld_ecc_err_tp2_q       : std_ulogic;
signal reld_ecc_err_ue_tp2_d, reld_ecc_err_ue_tp2_q : std_ulogic;
--  t plus 3 phase
signal pte0_reld_data_tp3_d, pte0_reld_data_tp3_q   : std_ulogic_vector(0 to 63);
signal pte1_reld_data_tp3_d, pte1_reld_data_tp3_q   : std_ulogic_vector(0 to 63);
signal htw_tag3_d, htw_tag3_q           : std_ulogic_vector(0 to tlb_tag_width-1);
signal htw_tag3_clr_resv_term2, htw_tag3_clr_resv_term4, htw_tag3_clr_resv_term5, htw_tag3_clr_resv_term6    :  std_ulogic_vector(0 to thdid_width-1);
signal htw_tag3_clr_resv_term7, htw_tag3_clr_resv_term8, htw_tag3_clr_resv_term9, htw_tag3_clr_resv_term11   :  std_ulogic_vector(0 to thdid_width-1);
signal htw_tag4_clr_resv_d, htw_tag4_clr_resv_q   :  std_ulogic_vector(0 to thdid_width-1);
signal htw_tag5_clr_resv_d, htw_tag5_clr_resv_q   :  std_ulogic_vector(0 to thdid_width-1);
signal spare_a_q, spare_b_q   : std_ulogic_vector(0 to 15);
-- logic signals
signal htw_seq_idle            : std_ulogic;
signal htw_seq_load_pteaddr    : std_ulogic;
signal htw_quiesce_b           : std_ulogic_vector(0 to thdid_width-1);
signal tlb_htw_req_valid_vec   : std_ulogic_vector(0 to thdid_width-1);
signal tlb_htw_req_valid_notpend_vec   : std_ulogic_vector(0 to thdid_width-1);
signal tlb_htw_pte_machines_full : std_ulogic;
signal htw_lsuptr_alt_d : std_ulogic_vector(0 to 1);
-- synopsys translate_off
-- synopsys translate_on
signal pte0_seq_idle              : std_ulogic;
signal pte0_reload_req_valid   : std_ulogic;
signal pte0_reload_req_taken    : std_ulogic;
signal pte0_reld_for_me_tm1   : std_ulogic;
signal pte0_reld_for_me_tp2   : std_ulogic;
signal pte0_reld_enable_lo_tp2   : std_ulogic;
signal pte0_reld_enable_hi_tp2   : std_ulogic;
signal pte0_seq_score_load   : std_ulogic;
signal pte0_seq_score_done   : std_ulogic;
signal pte0_seq_data_retry   : std_ulogic;
signal pte0_seq_clr_resv_ue    : std_ulogic;
signal pte1_seq_idle              : std_ulogic;
signal pte1_reload_req_valid   : std_ulogic;
signal pte1_reload_req_taken    : std_ulogic;
signal pte1_reld_for_me_tm1   : std_ulogic;
signal pte1_reld_for_me_tp2   : std_ulogic;
signal pte1_reld_enable_lo_tp2   : std_ulogic;
signal pte1_reld_enable_hi_tp2   : std_ulogic;
signal pte1_seq_score_load   : std_ulogic;
signal pte1_seq_score_done   : std_ulogic;
signal pte1_seq_data_retry   : std_ulogic;
signal pte1_seq_clr_resv_ue    : std_ulogic;
signal pte_ra_0    : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_0_spsize4K     : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_0_spsize64K    : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_1    : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_1_spsize4K     : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_1_spsize64K    : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_2    : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_2_spsize4K     : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_2_spsize64K    : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_3    : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_3_spsize4K     : std_ulogic_vector(64-real_addr_width to 63);
signal pte_ra_3_spsize64K    : std_ulogic_vector(64-real_addr_width to 63);
-- synopsys translate_off
-- synopsys translate_on
signal htw_resv0_tag3_lpid_match    : std_ulogic;
signal htw_resv0_tag3_pid_match     : std_ulogic;
signal htw_resv0_tag3_as_match      : std_ulogic;
signal htw_resv0_tag3_gs_match      : std_ulogic;
signal htw_resv0_tag3_epn_loc_match     : std_ulogic;
signal htw_resv0_tag3_epn_glob_match     : std_ulogic;
signal tlb_htw_req0_clr_resv_ue     : std_ulogic;
signal htw_resv1_tag3_lpid_match    : std_ulogic;
signal htw_resv1_tag3_pid_match     : std_ulogic;
signal htw_resv1_tag3_as_match      : std_ulogic;
signal htw_resv1_tag3_gs_match      : std_ulogic;
signal htw_resv1_tag3_epn_loc_match     : std_ulogic;
signal htw_resv1_tag3_epn_glob_match     : std_ulogic;
signal tlb_htw_req1_clr_resv_ue     : std_ulogic;
signal htw_resv2_tag3_lpid_match    : std_ulogic;
signal htw_resv2_tag3_pid_match     : std_ulogic;
signal htw_resv2_tag3_as_match      : std_ulogic;
signal htw_resv2_tag3_gs_match      : std_ulogic;
signal htw_resv2_tag3_epn_loc_match     : std_ulogic;
signal htw_resv2_tag3_epn_glob_match     : std_ulogic;
signal tlb_htw_req2_clr_resv_ue     : std_ulogic;
signal htw_resv3_tag3_lpid_match    : std_ulogic;
signal htw_resv3_tag3_pid_match     : std_ulogic;
signal htw_resv3_tag3_as_match      : std_ulogic;
signal htw_resv3_tag3_gs_match      : std_ulogic;
signal htw_resv3_tag3_epn_loc_match     : std_ulogic;
signal htw_resv3_tag3_epn_glob_match     : std_ulogic;
signal tlb_htw_req3_clr_resv_ue     : std_ulogic;
signal htw_resv_valid_vec : std_ulogic_vector(0 to thdid_width-1);
signal htw_tag4_clr_resv_terms : std_ulogic_vector(0 to 3);
signal htw_lsu_act : std_ulogic;
signal pte0_score_act  : std_ulogic;
signal pte1_score_act  : std_ulogic;
signal reld_act  : std_ulogic;
signal pte0_reld_act  : std_ulogic;
signal pte1_reld_act  : std_ulogic;
signal unused_dc  :  std_ulogic_vector(0 to 21);
-- synopsys translate_off
-- synopsys translate_on
-- Pervasive
signal pc_sg_1         : std_ulogic;
signal pc_sg_0         : std_ulogic;
signal pc_func_sl_thold_1        : std_ulogic;
signal pc_func_sl_thold_0        : std_ulogic;
signal pc_func_sl_thold_0_b      : std_ulogic;
signal pc_func_slp_sl_thold_1    : std_ulogic;
signal pc_func_slp_sl_thold_0    : std_ulogic;
signal pc_func_slp_sl_thold_0_b  : std_ulogic;
signal pc_func_sl_force     : std_ulogic;
signal pc_func_slp_sl_force : std_ulogic;
signal siv_0                      : std_ulogic_vector(0 to scan_right_0);
signal sov_0                      : std_ulogic_vector(0 to scan_right_0);
signal siv_1                      : std_ulogic_vector(0 to scan_right_1);
signal sov_1                      : std_ulogic_vector(0 to scan_right_1);
  BEGIN --@@ START OF EXECUTABLE CODE FOR MMQ_HTW

-----------------------------------------------------------------------
-- Logic
-----------------------------------------------------------------------
-- not quiesced
htw_quiesce_b(0 TO thdid_width-1) <= 
 ( (0 to thdid_width-1 => tlb_htw_req0_valid_q) and tlb_htw_req0_tag_q(tagpos_thdid to tagpos_thdid+thdid_width-1) ) or
 ( (0 to thdid_width-1 => tlb_htw_req1_valid_q) and tlb_htw_req1_tag_q(tagpos_thdid to tagpos_thdid+thdid_width-1) ) or
 ( (0 to thdid_width-1 => tlb_htw_req2_valid_q) and tlb_htw_req2_tag_q(tagpos_thdid to tagpos_thdid+thdid_width-1) ) or
 ( (0 to thdid_width-1 => tlb_htw_req3_valid_q) and tlb_htw_req3_tag_q(tagpos_thdid to tagpos_thdid+thdid_width-1) );
htw_quiesce  <=  not htw_quiesce_b;
tlb_htw_pte_machines_full  <=  '1' when (pte0_score_pending_q='1' and pte1_score_pending_q='1')
                         else '0';
tlb_htw_req_valid_vec  <=  (tlb_htw_req0_valid_q and (pte0_score_pending_q='0' or pte0_score_ptr_q/="00") and (pte1_score_pending_q='0' or pte1_score_ptr_q/="00")) & 
                          (tlb_htw_req1_valid_q and (pte0_score_pending_q='0' or pte0_score_ptr_q/="01") and (pte1_score_pending_q='0' or pte1_score_ptr_q/="01")) &
                          (tlb_htw_req2_valid_q and (pte0_score_pending_q='0' or pte0_score_ptr_q/="10") and (pte1_score_pending_q='0' or pte1_score_ptr_q/="10")) &
                          (tlb_htw_req3_valid_q and (pte0_score_pending_q='0' or pte0_score_ptr_q/="11") and (pte1_score_pending_q='0' or pte1_score_ptr_q/="11"));
-- HTW sequencer for servicing indirect tlb entry hits
Htw_Sequencer: PROCESS (htw_seq_q, tlb_htw_req_valid_vec, tlb_htw_pte_machines_full, htw_lsu_req_taken)
BEGIN
htw_seq_load_pteaddr  <=  '0';
htw_lsu_req_valid  <=  '0';
CASE htw_seq_q IS
        WHEN HtwSeq_Idle =>
          if tlb_htw_req_valid_vec/="0000" and tlb_htw_pte_machines_full='0' then 
                    htw_seq_d <=  HtwSeq_Stg1; 
          else
                    htw_seq_d <=  HtwSeq_Idle;
          end if;  
        WHEN HtwSeq_Stg1 =>
           htw_seq_load_pteaddr <= '1';  
           htw_seq_d <=  HtwSeq_Stg2;

        WHEN HtwSeq_Stg2 =>
          htw_lsu_req_valid <= '1';
          if htw_lsu_req_taken='1' then 
                    htw_seq_d <=  HtwSeq_Idle;
          else
                    htw_seq_d <=  HtwSeq_Stg2;
          end if;  

        WHEN OTHERS =>
          htw_seq_d <=  HtwSeq_Idle;  

    END CASE;
END PROCESS Htw_Sequencer;
htw_seq_idle  <=  '1' when htw_seq_q=HtwSeq_Idle else '0';
-- PTE sequencer for servicing pte data reloads
Pte0_Sequencer:   PROCESS (pte0_seq_q,   pte_load_ptr_q, ptereload_ptr_q, htw_lsu_req_taken, ptereload_req_taken,
                              pte0_score_pending_q,   pte0_score_dataval_q,   
                               pte0_score_error_q,   pte0_score_qwbeat_q,   pte0_score_ibit_q,   spare_b_q(0 to 2))
BEGIN
pte0_reload_req_valid    <=  '0';
pte0_reload_req_taken    <=  '0';
pte0_seq_score_load    <=  '0';
pte0_seq_score_done    <=  '0';
pte0_seq_data_retry    <=  '0';
pte0_reld_enable_lo_tp2    <=  '0';
pte0_reld_enable_hi_tp2    <=  '0';
pte0_seq_clr_resv_ue    <=  '0';
CASE pte0_seq_q   IS
        WHEN PteSeq_Idle =>
          if pte_load_ptr_q='0' and htw_lsu_req_taken='1' then 
                    pte0_seq_score_load   <= '1';
                    pte0_seq_d   <=  PteSeq_Stg1; 
          else
                    pte0_seq_d   <=  PteSeq_Idle;
          end if;  
        WHEN PteSeq_Stg1 =>
          if pte0_score_pending_q='1'   and pte0_score_dataval_q='1'   then 
                    pte0_seq_d   <=  PteSeq_Stg2; 
          else
                    pte0_seq_d   <=  PteSeq_Stg1;
          end if;  

        WHEN PteSeq_Stg2 =>
          if pte0_score_error_q(1)='1'   and spare_b_q(0)='1' and (pte0_score_qwbeat_q="1111"   or pte0_score_ibit_q='1')   then 
                    pte0_seq_d   <=  PteSeq_Stg4; 
          elsif pte0_score_error_q(0)='1'   and (pte0_score_error_q(2)='0'   or spare_b_q(1)='1') and 
                             (pte0_score_qwbeat_q="1111"   or pte0_score_ibit_q='1')   then 
                    pte0_seq_data_retry   <= '1';
                    pte0_seq_d   <=  PteSeq_Stg1; 
          elsif pte0_score_error_q(1)='1'   and (pte0_score_qwbeat_q="1111"   or pte0_score_ibit_q='1')   then 
                    pte0_seq_d   <=  PteSeq_Stg4; 
          elsif pte0_score_error_q(1)='0'   and (pte0_score_qwbeat_q="1111"   or pte0_score_ibit_q='1')   then 
                    pte0_seq_d   <=  PteSeq_Stg3;          
          else
                    pte0_seq_d   <=  PteSeq_Stg2;
          end if;  

        WHEN PteSeq_Stg3 =>
          pte0_reload_req_valid    <= '1';
          if ptereload_ptr_q='0' and ptereload_req_taken='1' then 
                    pte0_seq_score_done     <= '1';
                    pte0_reload_req_taken   <= '1';
                    pte0_seq_d   <=  PteSeq_Idle;
          else
                    pte0_seq_d   <=  PteSeq_Stg3;
          end if;  

        WHEN PteSeq_Stg4 =>
          pte0_seq_clr_resv_ue   <= not spare_b_q(2);  
                    pte0_seq_d   <=  PteSeq_Stg5;

        WHEN PteSeq_Stg5 =>
          pte0_reload_req_valid    <= '1';
          if ptereload_ptr_q='0' and ptereload_req_taken='1' then 
                    pte0_seq_score_done     <= '1';
                    pte0_reload_req_taken   <= '1';
                    pte0_seq_d   <=  PteSeq_Idle;
          else
                    pte0_seq_d   <=  PteSeq_Stg5;
          end if;  

        WHEN OTHERS =>
          pte0_seq_d   <=  PteSeq_Idle;  

    END CASE;
END PROCESS Pte0_Sequencer;
pte0_seq_idle    <=  '1' when pte0_seq_q=PteSeq_Idle   else '0';
-- PTE sequencer for servicing pte data reloads
Pte1_Sequencer:   PROCESS (pte1_seq_q,   pte_load_ptr_q, ptereload_ptr_q, htw_lsu_req_taken, ptereload_req_taken,
                              pte1_score_pending_q,   pte1_score_dataval_q,   
                               pte1_score_error_q,   pte1_score_qwbeat_q,   pte1_score_ibit_q,   spare_b_q(0 to 2))
BEGIN
pte1_reload_req_valid    <=  '0';
pte1_reload_req_taken    <=  '0';
pte1_seq_score_load    <=  '0';
pte1_seq_score_done    <=  '0';
pte1_seq_data_retry    <=  '0';
pte1_reld_enable_lo_tp2    <=  '0';
pte1_reld_enable_hi_tp2    <=  '0';
pte1_seq_clr_resv_ue    <=  '0';
CASE pte1_seq_q   IS
        WHEN PteSeq_Idle =>
          if pte_load_ptr_q='1' and htw_lsu_req_taken='1' then 
                    pte1_seq_score_load   <= '1';
                    pte1_seq_d   <=  PteSeq_Stg1; 
          else
                    pte1_seq_d   <=  PteSeq_Idle;
          end if;  
        WHEN PteSeq_Stg1 =>
          if pte1_score_pending_q='1'   and pte1_score_dataval_q='1'   then 
                    pte1_seq_d   <=  PteSeq_Stg2; 
          else
                    pte1_seq_d   <=  PteSeq_Stg1;
          end if;  

        WHEN PteSeq_Stg2 =>
          if pte1_score_error_q(1)='1'   and spare_b_q(0)='1' and (pte1_score_qwbeat_q="1111"   or pte1_score_ibit_q='1')   then 
                    pte1_seq_d   <=  PteSeq_Stg4; 
          elsif pte1_score_error_q(0)='1'   and (pte1_score_error_q(2)='0'   or spare_b_q(1)='1') and 
                             (pte1_score_qwbeat_q="1111"   or pte1_score_ibit_q='1')   then 
                    pte1_seq_data_retry   <= '1';
                    pte1_seq_d   <=  PteSeq_Stg1; 
          elsif pte1_score_error_q(1)='1'   and (pte1_score_qwbeat_q="1111"   or pte1_score_ibit_q='1')   then 
                    pte1_seq_d   <=  PteSeq_Stg4; 
          elsif pte1_score_error_q(1)='0'   and (pte1_score_qwbeat_q="1111"   or pte1_score_ibit_q='1')   then 
                    pte1_seq_d   <=  PteSeq_Stg3;          
          else
                    pte1_seq_d   <=  PteSeq_Stg2;
          end if;  

        WHEN PteSeq_Stg3 =>
          pte1_reload_req_valid    <= '1';
          if ptereload_ptr_q='1' and ptereload_req_taken='1' then 
                    pte1_seq_score_done     <= '1';
                    pte1_reload_req_taken   <= '1';
                    pte1_seq_d   <=  PteSeq_Idle;
          else
                    pte1_seq_d   <=  PteSeq_Stg3;
          end if;  

        WHEN PteSeq_Stg4 =>
          pte1_seq_clr_resv_ue   <= not spare_b_q(2);  
                    pte1_seq_d   <=  PteSeq_Stg5;

        WHEN PteSeq_Stg5 =>
          pte1_reload_req_valid    <= '1';
          if ptereload_ptr_q='1' and ptereload_req_taken='1' then 
                    pte1_seq_score_done     <= '1';
                    pte1_reload_req_taken   <= '1';
                    pte1_seq_d   <=  PteSeq_Idle;
          else
                    pte1_seq_d   <=  PteSeq_Stg5;
          end if;  

        WHEN OTHERS =>
          pte1_seq_d   <=  PteSeq_Idle;  

    END CASE;
END PROCESS Pte1_Sequencer;
pte1_seq_idle    <=  '1' when pte1_seq_q=PteSeq_Idle   else '0';
--  tlb_way  IND=0    IND=1
--   134      UX     SPSIZE0
--   135      SX     SPSIZE1
--   136      UW     SPSIZE2
--   137      SW     SPSIZE3
--   138      UR     PTRPN
--   139      SR     PA52
tlb_htw_req0_valid_d    <=   '1' when (tlb_htw_req_valid='1' and tlb_htw_req0_valid_q='0'   and htw_inptr_q="00")
                      else '0' when (pte0_reload_req_taken='1' and tlb_htw_req0_valid_q='1'   and pte0_score_ptr_q="00")
                      else '0' when (pte1_reload_req_taken='1' and tlb_htw_req0_valid_q='1'   and pte1_score_ptr_q="00")
                      else tlb_htw_req0_valid_q;
tlb_htw_req0_pending_d    <=   '1' when (htw_lsu_req_taken='1' and tlb_htw_req0_pending_q='0'   and htw_lsuptr_q="00")
                      else '0' when (pte0_reload_req_taken='1' and tlb_htw_req0_pending_q='1'   and pte0_score_ptr_q="00")
                      else '0' when (pte1_reload_req_taken='1' and tlb_htw_req0_pending_q='1'   and pte1_score_ptr_q="00")
                      else tlb_htw_req0_pending_q;
-- the  rpn  part of the tlb way
tlb_htw_req0_way_d    <=  tlb_htw_req_way when (tlb_htw_req_valid='1' and tlb_htw_req0_valid_q='0'   and htw_inptr_q="00")
                   else tlb_htw_req0_way_q;
tlb_htw_req0_tag_d(0 TO tagpos_wq-1) <=  tlb_htw_req_tag(0 to tagpos_wq-1) when (tlb_htw_req_valid='1' and tlb_htw_req0_valid_q='0'   and htw_inptr_q="00")
                   else tlb_htw_req0_tag_q(0   to tagpos_wq-1);
tlb_htw_req0_tag_d(tagpos_wq+2 TO tlb_tag_width-1) <=  tlb_htw_req_tag(tagpos_wq+2 to tlb_tag_width-1) when (tlb_htw_req_valid='1' and tlb_htw_req0_valid_q='0'   and htw_inptr_q="00")
                   else tlb_htw_req0_tag_q(tagpos_wq+2   to tlb_tag_width-1);
-- the WQ bits of the tag are re-purposed as reservation valid and duplicate bits
--  set reservation valid at tlb handoff, clear when ptereload taken..
--  or, clear reservation if tlbwe,ptereload,tlbi from another thread to avoid duplicates
--  or, clear reservation when L2 UE for this reload
tlb_htw_req0_tag_d(tagpos_wq) <=  '0' when ((htw_tag5_clr_resv_q(0)='1'   and tlb_tag5_except="0000") or tlb_htw_req0_clr_resv_ue='1')
                              else '1' when (tlb_htw_req_valid='1' and tlb_htw_req0_valid_q='0'   and htw_inptr_q="00")
                              else '0' when (pte0_reload_req_taken='1' and tlb_htw_req0_valid_q='1'   and pte0_score_ptr_q="00")
                              else '0' when (pte1_reload_req_taken='1' and tlb_htw_req0_valid_q='1'   and pte1_score_ptr_q="00")
                   else tlb_htw_req0_tag_q(tagpos_wq);
--  spare, wq+1 is duplicate indicator in tlb_cmp, but would not make it to tlb handoff
tlb_htw_req0_tag_d(tagpos_wq+1) <=  tlb_htw_req0_tag_q(tagpos_wq+1);
tlb_htw_req0_tag_act    <=  tlb_delayed_act(24+0)   or tlb_htw_req0_valid_q;
tlb_htw_req0_clr_resv_ue    <=  (pte0_seq_clr_resv_ue and Eq(pte0_score_ptr_q,"00")) or
                               (pte1_seq_clr_resv_ue and Eq(pte1_score_ptr_q,"00"));
htw_req0_valid    <=  tlb_htw_req0_valid_q;
htw_req0_thdid    <=  tlb_htw_req0_tag_q(tagpos_thdid   to tagpos_thdid+thdid_width-1);
htw_req0_type     <=  tlb_htw_req0_tag_q(tagpos_type_derat   to tagpos_type_ierat);
pte_ra_0_spsize4K    <=  tlb_htw_req0_way_q(waypos_rpn   to waypos_rpn+rpn_width-1) & 
                        tlb_htw_req0_way_q(waypos_usxwr+5)   & 
                        tlb_htw_req0_tag_q(tagpos_epn+epn_width-8   to tagpos_epn+epn_width-1) & "000";
pte_ra_0_spsize64K    <=  tlb_htw_req0_way_q(waypos_rpn   to waypos_rpn+rpn_width-4) & 
                         tlb_htw_req0_tag_q(tagpos_epn+epn_width-16   to tagpos_epn+epn_width-5) & "000";
-- select based on SPSIZE
pte_ra_0    <=  pte_ra_0_spsize64K   when tlb_htw_req0_way_q(waypos_usxwr   to waypos_usxwr+3)=TLB_PgSize_64KB
         else pte_ra_0_spsize4K;
tlb_htw_req1_valid_d    <=   '1' when (tlb_htw_req_valid='1' and tlb_htw_req1_valid_q='0'   and htw_inptr_q="01")
                      else '0' when (pte0_reload_req_taken='1' and tlb_htw_req1_valid_q='1'   and pte0_score_ptr_q="01")
                      else '0' when (pte1_reload_req_taken='1' and tlb_htw_req1_valid_q='1'   and pte1_score_ptr_q="01")
                      else tlb_htw_req1_valid_q;
tlb_htw_req1_pending_d    <=   '1' when (htw_lsu_req_taken='1' and tlb_htw_req1_pending_q='0'   and htw_lsuptr_q="01")
                      else '0' when (pte0_reload_req_taken='1' and tlb_htw_req1_pending_q='1'   and pte0_score_ptr_q="01")
                      else '0' when (pte1_reload_req_taken='1' and tlb_htw_req1_pending_q='1'   and pte1_score_ptr_q="01")
                      else tlb_htw_req1_pending_q;
-- the  rpn  part of the tlb way
tlb_htw_req1_way_d    <=  tlb_htw_req_way when (tlb_htw_req_valid='1' and tlb_htw_req1_valid_q='0'   and htw_inptr_q="01")
                   else tlb_htw_req1_way_q;
tlb_htw_req1_tag_d(0 TO tagpos_wq-1) <=  tlb_htw_req_tag(0 to tagpos_wq-1) when (tlb_htw_req_valid='1' and tlb_htw_req1_valid_q='0'   and htw_inptr_q="01")
                   else tlb_htw_req1_tag_q(0   to tagpos_wq-1);
tlb_htw_req1_tag_d(tagpos_wq+2 TO tlb_tag_width-1) <=  tlb_htw_req_tag(tagpos_wq+2 to tlb_tag_width-1) when (tlb_htw_req_valid='1' and tlb_htw_req1_valid_q='0'   and htw_inptr_q="01")
                   else tlb_htw_req1_tag_q(tagpos_wq+2   to tlb_tag_width-1);
-- the WQ bits of the tag are re-purposed as reservation valid and duplicate bits
--  set reservation valid at tlb handoff, clear when ptereload taken..
--  or, clear reservation if tlbwe,ptereload,tlbi from another thread to avoid duplicates
--  or, clear reservation when L2 UE for this reload
tlb_htw_req1_tag_d(tagpos_wq) <=  '0' when ((htw_tag5_clr_resv_q(1)='1'   and tlb_tag5_except="0000") or tlb_htw_req1_clr_resv_ue='1')
                              else '1' when (tlb_htw_req_valid='1' and tlb_htw_req1_valid_q='0'   and htw_inptr_q="01")
                              else '0' when (pte0_reload_req_taken='1' and tlb_htw_req1_valid_q='1'   and pte0_score_ptr_q="01")
                              else '0' when (pte1_reload_req_taken='1' and tlb_htw_req1_valid_q='1'   and pte1_score_ptr_q="01")
                   else tlb_htw_req1_tag_q(tagpos_wq);
--  spare, wq+1 is duplicate indicator in tlb_cmp, but would not make it to tlb handoff
tlb_htw_req1_tag_d(tagpos_wq+1) <=  tlb_htw_req1_tag_q(tagpos_wq+1);
tlb_htw_req1_tag_act    <=  tlb_delayed_act(24+1)   or tlb_htw_req1_valid_q;
tlb_htw_req1_clr_resv_ue    <=  (pte0_seq_clr_resv_ue and Eq(pte0_score_ptr_q,"01")) or
                               (pte1_seq_clr_resv_ue and Eq(pte1_score_ptr_q,"01"));
htw_req1_valid    <=  tlb_htw_req1_valid_q;
htw_req1_thdid    <=  tlb_htw_req1_tag_q(tagpos_thdid   to tagpos_thdid+thdid_width-1);
htw_req1_type     <=  tlb_htw_req1_tag_q(tagpos_type_derat   to tagpos_type_ierat);
pte_ra_1_spsize4K    <=  tlb_htw_req1_way_q(waypos_rpn   to waypos_rpn+rpn_width-1) & 
                        tlb_htw_req1_way_q(waypos_usxwr+5)   & 
                        tlb_htw_req1_tag_q(tagpos_epn+epn_width-8   to tagpos_epn+epn_width-1) & "000";
pte_ra_1_spsize64K    <=  tlb_htw_req1_way_q(waypos_rpn   to waypos_rpn+rpn_width-4) & 
                         tlb_htw_req1_tag_q(tagpos_epn+epn_width-16   to tagpos_epn+epn_width-5) & "000";
pte_ra_1    <=  pte_ra_1_spsize64K   when tlb_htw_req1_way_q(waypos_usxwr   to waypos_usxwr+3)=TLB_PgSize_64KB
         else pte_ra_1_spsize4K;
tlb_htw_req2_valid_d    <=   '1' when (tlb_htw_req_valid='1' and tlb_htw_req2_valid_q='0'   and htw_inptr_q="10")
                      else '0' when (pte0_reload_req_taken='1' and tlb_htw_req2_valid_q='1'   and pte0_score_ptr_q="10")
                      else '0' when (pte1_reload_req_taken='1' and tlb_htw_req2_valid_q='1'   and pte1_score_ptr_q="10")
                      else tlb_htw_req2_valid_q;
tlb_htw_req2_pending_d    <=   '1' when (htw_lsu_req_taken='1' and tlb_htw_req2_pending_q='0'   and htw_lsuptr_q="10")
                      else '0' when (pte0_reload_req_taken='1' and tlb_htw_req2_pending_q='1'   and pte0_score_ptr_q="10")
                      else '0' when (pte1_reload_req_taken='1' and tlb_htw_req2_pending_q='1'   and pte1_score_ptr_q="10")
                      else tlb_htw_req2_pending_q;
-- the  rpn  part of the tlb way
tlb_htw_req2_way_d    <=  tlb_htw_req_way when (tlb_htw_req_valid='1' and tlb_htw_req2_valid_q='0'   and htw_inptr_q="10")
                   else tlb_htw_req2_way_q;
tlb_htw_req2_tag_d(0 TO tagpos_wq-1) <=  tlb_htw_req_tag(0 to tagpos_wq-1) when (tlb_htw_req_valid='1' and tlb_htw_req2_valid_q='0'   and htw_inptr_q="10")
                   else tlb_htw_req2_tag_q(0   to tagpos_wq-1);
tlb_htw_req2_tag_d(tagpos_wq+2 TO tlb_tag_width-1) <=  tlb_htw_req_tag(tagpos_wq+2 to tlb_tag_width-1) when (tlb_htw_req_valid='1' and tlb_htw_req2_valid_q='0'   and htw_inptr_q="10")
                   else tlb_htw_req2_tag_q(tagpos_wq+2   to tlb_tag_width-1);
-- the WQ bits of the tag are re-purposed as reservation valid and duplicate bits
--  set reservation valid at tlb handoff, clear when ptereload taken..
--  or, clear reservation if tlbwe,ptereload,tlbi from another thread to avoid duplicates
--  or, clear reservation when L2 UE for this reload
tlb_htw_req2_tag_d(tagpos_wq) <=  '0' when ((htw_tag5_clr_resv_q(2)='1'   and tlb_tag5_except="0000") or tlb_htw_req2_clr_resv_ue='1')
                              else '1' when (tlb_htw_req_valid='1' and tlb_htw_req2_valid_q='0'   and htw_inptr_q="10")
                              else '0' when (pte0_reload_req_taken='1' and tlb_htw_req2_valid_q='1'   and pte0_score_ptr_q="10")
                              else '0' when (pte1_reload_req_taken='1' and tlb_htw_req2_valid_q='1'   and pte1_score_ptr_q="10")
                   else tlb_htw_req2_tag_q(tagpos_wq);
tlb_htw_req2_tag_d(tagpos_wq+1) <=  tlb_htw_req2_tag_q(tagpos_wq+1);
tlb_htw_req2_tag_act    <=  tlb_delayed_act(24+2)   or tlb_htw_req2_valid_q;
tlb_htw_req2_clr_resv_ue    <=  (pte0_seq_clr_resv_ue and Eq(pte0_score_ptr_q,"10")) or
                               (pte1_seq_clr_resv_ue and Eq(pte1_score_ptr_q,"10"));
htw_req2_valid    <=  tlb_htw_req2_valid_q;
htw_req2_thdid    <=  tlb_htw_req2_tag_q(tagpos_thdid   to tagpos_thdid+thdid_width-1);
htw_req2_type     <=  tlb_htw_req2_tag_q(tagpos_type_derat   to tagpos_type_ierat);
pte_ra_2_spsize4K    <=  tlb_htw_req2_way_q(waypos_rpn   to waypos_rpn+rpn_width-1) & 
                        tlb_htw_req2_way_q(waypos_usxwr+5)   & 
                        tlb_htw_req2_tag_q(tagpos_epn+epn_width-8   to tagpos_epn+epn_width-1) & "000";
pte_ra_2_spsize64K    <=  tlb_htw_req2_way_q(waypos_rpn   to waypos_rpn+rpn_width-4) & 
                         tlb_htw_req2_tag_q(tagpos_epn+epn_width-16   to tagpos_epn+epn_width-5) & "000";
-- select based on SPSIZE
pte_ra_2    <=  pte_ra_2_spsize64K   when tlb_htw_req2_way_q(waypos_usxwr   to waypos_usxwr+3)=TLB_PgSize_64KB
         else pte_ra_2_spsize4K;
tlb_htw_req3_valid_d    <=   '1' when (tlb_htw_req_valid='1' and tlb_htw_req3_valid_q='0'   and htw_inptr_q="11")
                      else '0' when (pte0_reload_req_taken='1' and tlb_htw_req3_valid_q='1'   and pte0_score_ptr_q="11")
                      else '0' when (pte1_reload_req_taken='1' and tlb_htw_req3_valid_q='1'   and pte1_score_ptr_q="11")
                      else tlb_htw_req3_valid_q;
tlb_htw_req3_pending_d    <=   '1' when (htw_lsu_req_taken='1' and tlb_htw_req3_pending_q='0'   and htw_lsuptr_q="11")
                      else '0' when (pte0_reload_req_taken='1' and tlb_htw_req3_pending_q='1'   and pte0_score_ptr_q="11")
                      else '0' when (pte1_reload_req_taken='1' and tlb_htw_req3_pending_q='1'   and pte1_score_ptr_q="11")
                      else tlb_htw_req3_pending_q;
-- the  rpn  part of the tlb way
tlb_htw_req3_way_d    <=  tlb_htw_req_way when (tlb_htw_req_valid='1' and tlb_htw_req3_valid_q='0'   and htw_inptr_q="11")
                   else tlb_htw_req3_way_q;
tlb_htw_req3_tag_d(0 TO tagpos_wq-1) <=  tlb_htw_req_tag(0 to tagpos_wq-1) when (tlb_htw_req_valid='1' and tlb_htw_req3_valid_q='0'   and htw_inptr_q="11")
                   else tlb_htw_req3_tag_q(0   to tagpos_wq-1);
tlb_htw_req3_tag_d(tagpos_wq+2 TO tlb_tag_width-1) <=  tlb_htw_req_tag(tagpos_wq+2 to tlb_tag_width-1) when (tlb_htw_req_valid='1' and tlb_htw_req3_valid_q='0'   and htw_inptr_q="11")
                   else tlb_htw_req3_tag_q(tagpos_wq+2   to tlb_tag_width-1);
-- the WQ bits of the tag are re-purposed as reservation valid and duplicate bits
--  set reservation valid at tlb handoff, clear when ptereload taken..
--  or, clear reservation if tlbwe,ptereload,tlbi from another thread to avoid duplicates
--  or, clear reservation when L2 UE for this reload
tlb_htw_req3_tag_d(tagpos_wq) <=  '0' when ((htw_tag5_clr_resv_q(3)='1'   and tlb_tag5_except="0000") or tlb_htw_req3_clr_resv_ue='1')
                              else '1' when (tlb_htw_req_valid='1' and tlb_htw_req3_valid_q='0'   and htw_inptr_q="11")
                              else '0' when (pte0_reload_req_taken='1' and tlb_htw_req3_valid_q='1'   and pte0_score_ptr_q="11")
                              else '0' when (pte1_reload_req_taken='1' and tlb_htw_req3_valid_q='1'   and pte1_score_ptr_q="11")
                   else tlb_htw_req3_tag_q(tagpos_wq);
--  spare, wq+1 is duplicate indicator in tlb_cmp, but would not make it to tlb handoff
tlb_htw_req3_tag_d(tagpos_wq+1) <=  tlb_htw_req3_tag_q(tagpos_wq+1);
tlb_htw_req3_tag_act    <=  tlb_delayed_act(24+3)   or tlb_htw_req3_valid_q;
tlb_htw_req3_clr_resv_ue    <=  (pte0_seq_clr_resv_ue and Eq(pte0_score_ptr_q,"11")) or
                               (pte1_seq_clr_resv_ue and Eq(pte1_score_ptr_q,"11"));
htw_req3_valid    <=  tlb_htw_req3_valid_q;
htw_req3_thdid    <=  tlb_htw_req3_tag_q(tagpos_thdid   to tagpos_thdid+thdid_width-1);
htw_req3_type     <=  tlb_htw_req3_tag_q(tagpos_type_derat   to tagpos_type_ierat);
pte_ra_3_spsize4K    <=  tlb_htw_req3_way_q(waypos_rpn   to waypos_rpn+rpn_width-1) & 
                        tlb_htw_req3_way_q(waypos_usxwr+5)   & 
                        tlb_htw_req3_tag_q(tagpos_epn+epn_width-8   to tagpos_epn+epn_width-1) & "000";
pte_ra_3_spsize64K    <=  tlb_htw_req3_way_q(waypos_rpn   to waypos_rpn+rpn_width-4) & 
                         tlb_htw_req3_tag_q(tagpos_epn+epn_width-16   to tagpos_epn+epn_width-5) & "000";
-- select based on SPSIZE
pte_ra_3    <=  pte_ra_3_spsize64K   when tlb_htw_req3_way_q(waypos_usxwr   to waypos_usxwr+3)=TLB_PgSize_64KB
         else pte_ra_3_spsize4K;
-- tag forwarding from tlb_ctl, for reservation clear compares
htw_tag3_d(0 TO tagpos_thdid-1) <=  tlb_tag2(0 to tagpos_thdid-1);
htw_tag3_d(tagpos_thdid+thdid_width TO tlb_tag_width-1) <=  tlb_tag2(tagpos_thdid+thdid_width to tlb_tag_width-1);
htw_tag3_d(tagpos_thdid TO tagpos_thdid+thdid_width-1) <=   tlb_tag2(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag2_flush);
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
--        (7) any proc executes tlbwe not causing exception and with (wq=00 always, or wq=01 and proc holds resv)
--              and mas regs ind,tgs,ts,tlpid,tid,sizemasked(epn,mas1.tsize) match resv.ind,gs,as,lpid,pid,sizemasked(epn,mas1.tsize)
--        (8) any page table reload not causing an exception (due to pt fault, tlb inelig, or lrat miss)
--              and PTE's tag ind=0,tgs,ts,tlpid,tid,sizemasked(epn,pte.size) match resv.ind=0,gs,as,lpid,pid,sizemasked(epn.pte.size)
--       A2-specific non-architected clear states
--        (9) any proc executes tlbwe not causing exception and with (wq=10 clear, or wq=11 always (same as 00))
--              and mas regs ind,tgs,ts,tlpid,tid,sizemasked(epn,mas1.tsize) match resv.ind,gs,as,lpid,pid,sizemasked(epn,mas1.tsize)
--               (basically same as 7,
--        (10) any proc executes tlbilx T=2 (gs) with mas5.sgs matching resv.gs
--        (11) any proc executes tlbilx T=4 to 7 (class) with T(1:2) matching resv.class
--  ttype <= tlbre & tlbwe & tlbsx & tlbsxr & tlbsrx;
--  IS0: Local bit
--  IS1/Class: 0=all, 1=tid, 2=gs, 3=vpn, 4=class0, 5=class1, 6=class2, 7=class3
--  mas0.wq: 00=ignore reserv write always, 01=write if reserved, 10=clear reserv, 11=same as 00
htw_tag3_clr_resv_term2(0) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="0011" and 
                                htw_resv0_tag3_lpid_match='1'   and htw_resv0_tag3_pid_match='1'   and htw_resv0_tag3_gs_match='1'   and 
                                htw_resv0_tag3_as_match='1'   and htw_resv0_tag3_epn_glob_match='1'    )
              else '0';
htw_tag3_clr_resv_term4(0) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1000" and 
                                 htw_resv0_tag3_lpid_match='1'   )
              else '0';
htw_tag3_clr_resv_term5(0) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1001" and 
                                htw_resv0_tag3_lpid_match='1'   and htw_resv0_tag3_pid_match='1'   )
              else '0';
htw_tag3_clr_resv_term6(0) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1011" and 
                                htw_resv0_tag3_lpid_match='1'   and htw_resv0_tag3_pid_match='1'   and htw_resv0_tag3_gs_match='1'   and 
                                htw_resv0_tag3_as_match='1'   and htw_resv0_tag3_epn_loc_match='1'    )
              else '0';
htw_tag3_clr_resv_term7(0) <=  '1' when  ( (((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="01") or 
                                   ((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="00")) and 
                                    htw_tag3_q(tagpos_type_tlbwe)='1' and 
                                     htw_resv0_tag3_gs_match='1'   and htw_resv0_tag3_as_match='1'   and 
                                      htw_resv0_tag3_lpid_match='1'   and htw_resv0_tag3_pid_match='1'   and 
                                       htw_resv0_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term8(0) <=  '1' when  ( htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                   htw_tag3_q(tagpos_type_ptereload)='1' and  htw_tag3_q(tagpos_wq to tagpos_wq+1)="10" and
                                     htw_resv0_tag3_gs_match='1'   and htw_resv0_tag3_as_match='1'   and 
                                      htw_resv0_tag3_lpid_match='1'   and htw_resv0_tag3_pid_match='1'   and 
                                       htw_resv0_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term9(0) <=  '1' when  ( (((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="10") or 
                                   ((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="11"))  and 
                                    htw_tag3_q(tagpos_type_tlbwe)='1' and 
                                     htw_resv0_tag3_gs_match='1'   and htw_resv0_tag3_as_match='1'   and 
                                      htw_resv0_tag3_lpid_match='1'   and htw_resv0_tag3_pid_match='1'   and 
                                       htw_resv0_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term11(0) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+1)="11" )
              else '0';
htw_tag4_clr_resv_d(0) <=  htw_tag3_clr_resv_term2(0)   or htw_tag3_clr_resv_term4(0)   or htw_tag3_clr_resv_term5(0)   or htw_tag3_clr_resv_term6(0)   or
                             htw_tag3_clr_resv_term7(0)   or htw_tag3_clr_resv_term8(0)   or htw_tag3_clr_resv_term9(0)   or 
                             htw_tag3_clr_resv_term11(0);
htw_tag3_clr_resv_term2(1) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="0011" and 
                                htw_resv1_tag3_lpid_match='1'   and htw_resv1_tag3_pid_match='1'   and htw_resv1_tag3_gs_match='1'   and 
                                htw_resv1_tag3_as_match='1'   and htw_resv1_tag3_epn_glob_match='1'    )
              else '0';
htw_tag3_clr_resv_term4(1) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1000" and 
                                 htw_resv1_tag3_lpid_match='1'   )
              else '0';
htw_tag3_clr_resv_term5(1) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1001" and 
                                htw_resv1_tag3_lpid_match='1'   and htw_resv1_tag3_pid_match='1'   )
              else '0';
htw_tag3_clr_resv_term6(1) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1011" and 
                                htw_resv1_tag3_lpid_match='1'   and htw_resv1_tag3_pid_match='1'   and htw_resv1_tag3_gs_match='1'   and 
                                htw_resv1_tag3_as_match='1'   and htw_resv1_tag3_epn_loc_match='1'    )
              else '0';
htw_tag3_clr_resv_term7(1) <=  '1' when  ( (((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="01") or 
                                   ((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="00")) and 
                                    htw_tag3_q(tagpos_type_tlbwe)='1' and 
                                     htw_resv1_tag3_gs_match='1'   and htw_resv1_tag3_as_match='1'   and 
                                      htw_resv1_tag3_lpid_match='1'   and htw_resv1_tag3_pid_match='1'   and 
                                       htw_resv1_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term8(1) <=  '1' when  ( htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                   htw_tag3_q(tagpos_type_ptereload)='1' and  htw_tag3_q(tagpos_wq to tagpos_wq+1)="10" and
                                     htw_resv1_tag3_gs_match='1'   and htw_resv1_tag3_as_match='1'   and 
                                      htw_resv1_tag3_lpid_match='1'   and htw_resv1_tag3_pid_match='1'   and 
                                       htw_resv1_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term9(1) <=  '1' when  ( (((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="10") or 
                                   ((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="11"))  and 
                                    htw_tag3_q(tagpos_type_tlbwe)='1' and 
                                     htw_resv1_tag3_gs_match='1'   and htw_resv1_tag3_as_match='1'   and 
                                      htw_resv1_tag3_lpid_match='1'   and htw_resv1_tag3_pid_match='1'   and 
                                       htw_resv1_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term11(1) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+1)="11" )
              else '0';
htw_tag4_clr_resv_d(1) <=  htw_tag3_clr_resv_term2(1)   or htw_tag3_clr_resv_term4(1)   or htw_tag3_clr_resv_term5(1)   or htw_tag3_clr_resv_term6(1)   or
                             htw_tag3_clr_resv_term7(1)   or htw_tag3_clr_resv_term8(1)   or htw_tag3_clr_resv_term9(1)   or 
                             htw_tag3_clr_resv_term11(1);
htw_tag3_clr_resv_term2(2) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="0011" and 
                                htw_resv2_tag3_lpid_match='1'   and htw_resv2_tag3_pid_match='1'   and htw_resv2_tag3_gs_match='1'   and 
                                htw_resv2_tag3_as_match='1'   and htw_resv2_tag3_epn_glob_match='1'    )
              else '0';
htw_tag3_clr_resv_term4(2) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1000" and 
                                 htw_resv2_tag3_lpid_match='1'   )
              else '0';
htw_tag3_clr_resv_term5(2) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1001" and 
                                htw_resv2_tag3_lpid_match='1'   and htw_resv2_tag3_pid_match='1'   )
              else '0';
htw_tag3_clr_resv_term6(2) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1011" and 
                                htw_resv2_tag3_lpid_match='1'   and htw_resv2_tag3_pid_match='1'   and htw_resv2_tag3_gs_match='1'   and 
                                htw_resv2_tag3_as_match='1'   and htw_resv2_tag3_epn_loc_match='1'    )
              else '0';
htw_tag3_clr_resv_term7(2) <=  '1' when  ( (((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="01") or 
                                   ((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="00")) and 
                                    htw_tag3_q(tagpos_type_tlbwe)='1' and 
                                     htw_resv2_tag3_gs_match='1'   and htw_resv2_tag3_as_match='1'   and 
                                      htw_resv2_tag3_lpid_match='1'   and htw_resv2_tag3_pid_match='1'   and 
                                       htw_resv2_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term8(2) <=  '1' when  ( htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                   htw_tag3_q(tagpos_type_ptereload)='1' and  htw_tag3_q(tagpos_wq to tagpos_wq+1)="10" and
                                     htw_resv2_tag3_gs_match='1'   and htw_resv2_tag3_as_match='1'   and 
                                      htw_resv2_tag3_lpid_match='1'   and htw_resv2_tag3_pid_match='1'   and 
                                       htw_resv2_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term9(2) <=  '1' when  ( (((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="10") or 
                                   ((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="11"))  and 
                                    htw_tag3_q(tagpos_type_tlbwe)='1' and 
                                     htw_resv2_tag3_gs_match='1'   and htw_resv2_tag3_as_match='1'   and 
                                      htw_resv2_tag3_lpid_match='1'   and htw_resv2_tag3_pid_match='1'   and 
                                       htw_resv2_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term11(2) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+1)="11" )
              else '0';
htw_tag4_clr_resv_d(2) <=  htw_tag3_clr_resv_term2(2)   or htw_tag3_clr_resv_term4(2)   or htw_tag3_clr_resv_term5(2)   or htw_tag3_clr_resv_term6(2)   or
                             htw_tag3_clr_resv_term7(2)   or htw_tag3_clr_resv_term8(2)   or htw_tag3_clr_resv_term9(2)   or 
                             htw_tag3_clr_resv_term11(2);
htw_tag3_clr_resv_term2(3) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="0011" and 
                                htw_resv3_tag3_lpid_match='1'   and htw_resv3_tag3_pid_match='1'   and htw_resv3_tag3_gs_match='1'   and 
                                htw_resv3_tag3_as_match='1'   and htw_resv3_tag3_epn_glob_match='1'    )
              else '0';
htw_tag3_clr_resv_term4(3) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1000" and 
                                 htw_resv3_tag3_lpid_match='1'   )
              else '0';
htw_tag3_clr_resv_term5(3) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1001" and 
                                htw_resv3_tag3_lpid_match='1'   and htw_resv3_tag3_pid_match='1'   )
              else '0';
htw_tag3_clr_resv_term6(3) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+3)="1011" and 
                                htw_resv3_tag3_lpid_match='1'   and htw_resv3_tag3_pid_match='1'   and htw_resv3_tag3_gs_match='1'   and 
                                htw_resv3_tag3_as_match='1'   and htw_resv3_tag3_epn_loc_match='1'    )
              else '0';
htw_tag3_clr_resv_term7(3) <=  '1' when  ( (((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="01") or 
                                   ((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="00")) and 
                                    htw_tag3_q(tagpos_type_tlbwe)='1' and 
                                     htw_resv3_tag3_gs_match='1'   and htw_resv3_tag3_as_match='1'   and 
                                      htw_resv3_tag3_lpid_match='1'   and htw_resv3_tag3_pid_match='1'   and 
                                       htw_resv3_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term8(3) <=  '1' when  ( htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                   htw_tag3_q(tagpos_type_ptereload)='1' and  htw_tag3_q(tagpos_wq to tagpos_wq+1)="10" and
                                     htw_resv3_tag3_gs_match='1'   and htw_resv3_tag3_as_match='1'   and 
                                      htw_resv3_tag3_lpid_match='1'   and htw_resv3_tag3_pid_match='1'   and 
                                       htw_resv3_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term9(3) <=  '1' when  ( (((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="10") or 
                                   ((htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag3_flush))/="0000" and htw_tag3_q(tagpos_wq to tagpos_wq+1)="11"))  and 
                                    htw_tag3_q(tagpos_type_tlbwe)='1' and 
                                     htw_resv3_tag3_gs_match='1'   and htw_resv3_tag3_as_match='1'   and 
                                      htw_resv3_tag3_lpid_match='1'   and htw_resv3_tag3_pid_match='1'   and 
                                       htw_resv3_tag3_epn_loc_match='1'   ) 
              else '0';
htw_tag3_clr_resv_term11(3) <=  '1' when (htw_tag3_q(tagpos_thdid to tagpos_thdid+thdid_width-1)/="0000" and
                                htw_tag3_q(tagpos_type_snoop)='1' and htw_tag3_q(tagpos_is to tagpos_is+1)="11" )
              else '0';
htw_tag4_clr_resv_d(3) <=  htw_tag3_clr_resv_term2(3)   or htw_tag3_clr_resv_term4(3)   or htw_tag3_clr_resv_term5(3)   or htw_tag3_clr_resv_term6(3)   or
                             htw_tag3_clr_resv_term7(3)   or htw_tag3_clr_resv_term8(3)   or htw_tag3_clr_resv_term9(3)   or 
                             htw_tag3_clr_resv_term11(3);
htw_tag5_clr_resv_d  <=  htw_tag4_clr_resv_q when 
           (tlb_htw_req_tag(tagpos_thdid to tagpos_thdid+thdid_width-1) and not(tlb_ctl_tag4_flush))/="0000"
                    else "0000";
htw_resv_valid_vec  <=  tlb_htw_req0_tag_q(tagpos_wq) & tlb_htw_req1_tag_q(tagpos_wq) & tlb_htw_req2_tag_q(tagpos_wq) & tlb_htw_req3_tag_q(tagpos_wq);
htw_resv0_tag3_lpid_match      <=  '1' when (htw_tag3_q(tagpos_lpid to tagpos_lpid+lpid_width-1)=tlb_htw_req0_tag_q(tagpos_lpid   to tagpos_lpid+lpid_width-1)) else '0';
htw_resv0_tag3_pid_match       <=  '1' when (htw_tag3_q(tagpos_pid to tagpos_pid+pid_width-1)=tlb_htw_req0_tag_q(tagpos_pid   to tagpos_pid+pid_width-1)) else '0';
htw_resv0_tag3_as_match        <=  '1' when (htw_tag3_q(tagpos_as)=tlb_htw_req0_tag_q(tagpos_as))   else '0';
htw_resv0_tag3_gs_match        <=  '1' when (htw_tag3_q(tagpos_gs)=tlb_htw_req0_tag_q(tagpos_gs))   else '0';
htw_resv0_tag3_epn_loc_match       <=  '1' when (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-1)=tlb_htw_req0_tag_q(tagpos_epn   to tagpos_epn+epn_width-1) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-5)=tlb_htw_req0_tag_q(tagpos_epn   to tagpos_epn+epn_width-5) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-9)=tlb_htw_req0_tag_q(tagpos_epn   to tagpos_epn+epn_width-9) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-13)=tlb_htw_req0_tag_q(tagpos_epn   to tagpos_epn+epn_width-13) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-19)=tlb_htw_req0_tag_q(tagpos_epn   to tagpos_epn+epn_width-19) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- global match ignores certain upper epn bits that are not tranferred over bus
-- fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
htw_resv0_tag3_epn_glob_match       <=  '1' when (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-1)=tlb_htw_req0_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-1) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-5)=tlb_htw_req0_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-5) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-9)=tlb_htw_req0_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-9) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-13)=tlb_htw_req0_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-13) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-19)=tlb_htw_req0_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-19) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
htw_resv1_tag3_lpid_match      <=  '1' when (htw_tag3_q(tagpos_lpid to tagpos_lpid+lpid_width-1)=tlb_htw_req1_tag_q(tagpos_lpid   to tagpos_lpid+lpid_width-1)) else '0';
htw_resv1_tag3_pid_match       <=  '1' when (htw_tag3_q(tagpos_pid to tagpos_pid+pid_width-1)=tlb_htw_req1_tag_q(tagpos_pid   to tagpos_pid+pid_width-1)) else '0';
htw_resv1_tag3_as_match        <=  '1' when (htw_tag3_q(tagpos_as)=tlb_htw_req1_tag_q(tagpos_as))   else '0';
htw_resv1_tag3_gs_match        <=  '1' when (htw_tag3_q(tagpos_gs)=tlb_htw_req1_tag_q(tagpos_gs))   else '0';
htw_resv1_tag3_epn_loc_match       <=  '1' when (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-1)=tlb_htw_req1_tag_q(tagpos_epn   to tagpos_epn+epn_width-1) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-5)=tlb_htw_req1_tag_q(tagpos_epn   to tagpos_epn+epn_width-5) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-9)=tlb_htw_req1_tag_q(tagpos_epn   to tagpos_epn+epn_width-9) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-13)=tlb_htw_req1_tag_q(tagpos_epn   to tagpos_epn+epn_width-13) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-19)=tlb_htw_req1_tag_q(tagpos_epn   to tagpos_epn+epn_width-19) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- global match ignores certain upper epn bits that are not tranferred over bus
-- fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
htw_resv1_tag3_epn_glob_match       <=  '1' when (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-1)=tlb_htw_req1_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-1) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-5)=tlb_htw_req1_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-5) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-9)=tlb_htw_req1_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-9) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-13)=tlb_htw_req1_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-13) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-19)=tlb_htw_req1_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-19) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
htw_resv2_tag3_lpid_match      <=  '1' when (htw_tag3_q(tagpos_lpid to tagpos_lpid+lpid_width-1)=tlb_htw_req2_tag_q(tagpos_lpid   to tagpos_lpid+lpid_width-1)) else '0';
htw_resv2_tag3_pid_match       <=  '1' when (htw_tag3_q(tagpos_pid to tagpos_pid+pid_width-1)=tlb_htw_req2_tag_q(tagpos_pid   to tagpos_pid+pid_width-1)) else '0';
htw_resv2_tag3_as_match        <=  '1' when (htw_tag3_q(tagpos_as)=tlb_htw_req2_tag_q(tagpos_as))   else '0';
htw_resv2_tag3_gs_match        <=  '1' when (htw_tag3_q(tagpos_gs)=tlb_htw_req2_tag_q(tagpos_gs))   else '0';
htw_resv2_tag3_epn_loc_match       <=  '1' when (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-1)=tlb_htw_req2_tag_q(tagpos_epn   to tagpos_epn+epn_width-1) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-5)=tlb_htw_req2_tag_q(tagpos_epn   to tagpos_epn+epn_width-5) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-9)=tlb_htw_req2_tag_q(tagpos_epn   to tagpos_epn+epn_width-9) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-13)=tlb_htw_req2_tag_q(tagpos_epn   to tagpos_epn+epn_width-13) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-19)=tlb_htw_req2_tag_q(tagpos_epn   to tagpos_epn+epn_width-19) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- global match ignores certain upper epn bits that are not tranferred over bus
-- fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
htw_resv2_tag3_epn_glob_match       <=  '1' when (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-1)=tlb_htw_req2_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-1) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-5)=tlb_htw_req2_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-5) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-9)=tlb_htw_req2_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-9) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-13)=tlb_htw_req2_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-13) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-19)=tlb_htw_req2_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-19) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
htw_resv3_tag3_lpid_match      <=  '1' when (htw_tag3_q(tagpos_lpid to tagpos_lpid+lpid_width-1)=tlb_htw_req3_tag_q(tagpos_lpid   to tagpos_lpid+lpid_width-1)) else '0';
htw_resv3_tag3_pid_match       <=  '1' when (htw_tag3_q(tagpos_pid to tagpos_pid+pid_width-1)=tlb_htw_req3_tag_q(tagpos_pid   to tagpos_pid+pid_width-1)) else '0';
htw_resv3_tag3_as_match        <=  '1' when (htw_tag3_q(tagpos_as)=tlb_htw_req3_tag_q(tagpos_as))   else '0';
htw_resv3_tag3_gs_match        <=  '1' when (htw_tag3_q(tagpos_gs)=tlb_htw_req3_tag_q(tagpos_gs))   else '0';
htw_resv3_tag3_epn_loc_match       <=  '1' when (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-1)=tlb_htw_req3_tag_q(tagpos_epn   to tagpos_epn+epn_width-1) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-5)=tlb_htw_req3_tag_q(tagpos_epn   to tagpos_epn+epn_width-5) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-9)=tlb_htw_req3_tag_q(tagpos_epn   to tagpos_epn+epn_width-9) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-13)=tlb_htw_req3_tag_q(tagpos_epn   to tagpos_epn+epn_width-13) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (htw_tag3_q(tagpos_epn to tagpos_epn+epn_width-19)=tlb_htw_req3_tag_q(tagpos_epn   to tagpos_epn+epn_width-19) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
-- global match ignores certain upper epn bits that are not tranferred over bus
-- fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
htw_resv3_tag3_epn_glob_match       <=  '1' when (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-1)=tlb_htw_req3_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-1) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_4KB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-5)=tlb_htw_req3_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-5) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_64KB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-9)=tlb_htw_req3_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-9) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1MB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-13)=tlb_htw_req3_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-13) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_16MB) or
                                            (htw_tag3_q(tagpos_epn+31 to tagpos_epn+epn_width-19)=tlb_htw_req3_tag_q(tagpos_epn+31   to tagpos_epn+epn_width-19) and htw_tag3_q(tagpos_size to tagpos_size+3)=TLB_PgSize_1GB)
                            else '0';
pte0_score_act    <=  (or_reduce(pte0_seq_q)   or or_reduce(htw_seq_q) or mmucr2_act_override) and xu_mm_ccr2_notlb_b;
pte0_score_ptr_d      <=  htw_lsuptr_q when pte0_seq_score_load='1'
                   else pte0_score_ptr_q;
pte0_score_cl_offset_d    <=  pte_ra_0(58 to 60) when pte0_seq_score_load='1'   and htw_lsuptr_q="00"
                       else pte_ra_1(58 to 60) when pte0_seq_score_load='1'   and htw_lsuptr_q="01"
                       else pte_ra_2(58 to 60) when pte0_seq_score_load='1'   and htw_lsuptr_q="10"
                       else pte_ra_3(58 to 60) when pte0_seq_score_load='1'   and htw_lsuptr_q="11"
                       else pte0_score_cl_offset_q;
pte0_score_ibit_d    <=  tlb_htw_req0_way_q(waypos_wimge+1) when pte0_seq_score_load='1'   and htw_lsuptr_q="00"
                       else tlb_htw_req1_way_q(waypos_wimge+1) when pte0_seq_score_load='1'   and htw_lsuptr_q="01"
                       else tlb_htw_req2_way_q(waypos_wimge+1) when pte0_seq_score_load='1'   and htw_lsuptr_q="10"
                       else tlb_htw_req3_way_q(waypos_wimge+1) when pte0_seq_score_load='1'   and htw_lsuptr_q="11"
                       else pte0_score_ibit_q;
pte0_score_pending_d      <=  '1' when pte0_seq_score_load='1'
                       else '0' when pte0_seq_score_done='1'
                       else pte0_score_pending_q;
-- 4 quadword data beats being returned; entire CL repeated if any beat has ecc error
--   ...beats need to be set regardless of ecc present..ecc and any qw happen simultaneously
pte0_score_qwbeat_d(0) <=  '0' when pte0_seq_score_load='1'   or pte0_seq_data_retry='1'   
                       else '1' when (pte0_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag0_Value   and reld_qw_tp2_q="00") 
                       else pte0_score_qwbeat_q(0);
pte0_score_qwbeat_d(1) <=  '0' when pte0_seq_score_load='1'   or pte0_seq_data_retry='1'   
                       else '1' when (pte0_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag0_Value   and reld_qw_tp2_q="01") 
                       else pte0_score_qwbeat_q(1);
pte0_score_qwbeat_d(2) <=  '0' when pte0_seq_score_load='1'   or pte0_seq_data_retry='1'   
                       else '1' when (pte0_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag0_Value   and reld_qw_tp2_q="10") 
                       else pte0_score_qwbeat_q(2);
pte0_score_qwbeat_d(3) <=  '0' when pte0_seq_score_load='1'   or pte0_seq_data_retry='1'   
                       else '1' when (pte0_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag0_Value   and reld_qw_tp2_q="11") 
                       else pte0_score_qwbeat_q(3);
-- ecc error detection: bit0=ECC, bit1=UE, bit2=retry
pte0_score_error_d(0) <=  '0' when pte0_seq_score_load='1'
                      else '1' when (pte0_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag0_Value   
                                    and reld_ecc_err_tp2_q='1') 
                      else pte0_score_error_q(0);
pte0_score_error_d(1) <=  '0' when pte0_seq_score_load='1'   
                      else '1' when (pte0_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag0_Value   
                                    and reld_ecc_err_ue_tp2_q='1') 
                      else pte0_score_error_q(1);
pte0_score_error_d(2) <=  '0' when pte0_seq_score_load='1'   
                      else '1' when pte0_seq_data_retry='1'   
                      else pte0_score_error_q(2);
pte0_score_dataval_d    <=  '0' when pte0_seq_score_load='1'   or pte0_seq_data_retry='1'
                     else '1' when (pte0_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_crit_qw_tp2_q='1' and reld_qw_tp2_q=pte0_score_cl_offset_q(58   to 59) 
                                    and reld_core_tag_tp2_q=Core_Tag0_Value)
                     else pte0_score_dataval_q;
pte1_score_act    <=  (or_reduce(pte1_seq_q)   or or_reduce(htw_seq_q) or mmucr2_act_override) and xu_mm_ccr2_notlb_b;
pte1_score_ptr_d      <=  htw_lsuptr_q when pte1_seq_score_load='1'
                   else pte1_score_ptr_q;
pte1_score_cl_offset_d    <=  pte_ra_0(58 to 60) when pte1_seq_score_load='1'   and htw_lsuptr_q="00"
                       else pte_ra_1(58 to 60) when pte1_seq_score_load='1'   and htw_lsuptr_q="01"
                       else pte_ra_2(58 to 60) when pte1_seq_score_load='1'   and htw_lsuptr_q="10"
                       else pte_ra_3(58 to 60) when pte1_seq_score_load='1'   and htw_lsuptr_q="11"
                       else pte1_score_cl_offset_q;
pte1_score_ibit_d    <=  tlb_htw_req0_way_q(waypos_wimge+1) when pte1_seq_score_load='1'   and htw_lsuptr_q="00"
                       else tlb_htw_req1_way_q(waypos_wimge+1) when pte1_seq_score_load='1'   and htw_lsuptr_q="01"
                       else tlb_htw_req2_way_q(waypos_wimge+1) when pte1_seq_score_load='1'   and htw_lsuptr_q="10"
                       else tlb_htw_req3_way_q(waypos_wimge+1) when pte1_seq_score_load='1'   and htw_lsuptr_q="11"
                       else pte1_score_ibit_q;
pte1_score_pending_d      <=  '1' when pte1_seq_score_load='1'
                       else '0' when pte1_seq_score_done='1'
                       else pte1_score_pending_q;
-- 4 quadword data beats being returned; entire CL repeated if any beat has ecc error
--   ...beats need to be set regardless of ecc present..ecc and any qw happen simultaneously
pte1_score_qwbeat_d(0) <=  '0' when pte1_seq_score_load='1'   or pte1_seq_data_retry='1'   
                       else '1' when (pte1_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag1_Value   and reld_qw_tp2_q="00") 
                       else pte1_score_qwbeat_q(0);
pte1_score_qwbeat_d(1) <=  '0' when pte1_seq_score_load='1'   or pte1_seq_data_retry='1'   
                       else '1' when (pte1_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag1_Value   and reld_qw_tp2_q="01") 
                       else pte1_score_qwbeat_q(1);
pte1_score_qwbeat_d(2) <=  '0' when pte1_seq_score_load='1'   or pte1_seq_data_retry='1'   
                       else '1' when (pte1_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag1_Value   and reld_qw_tp2_q="10") 
                       else pte1_score_qwbeat_q(2);
pte1_score_qwbeat_d(3) <=  '0' when pte1_seq_score_load='1'   or pte1_seq_data_retry='1'   
                       else '1' when (pte1_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag1_Value   and reld_qw_tp2_q="11") 
                       else pte1_score_qwbeat_q(3);
-- ecc error detection: bit0=ECC, bit1=UE, bit2=retry
pte1_score_error_d(0) <=  '0' when pte1_seq_score_load='1'
                      else '1' when (pte1_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag1_Value   
                                    and reld_ecc_err_tp2_q='1') 
                      else pte1_score_error_q(0);
pte1_score_error_d(1) <=  '0' when pte1_seq_score_load='1'   
                      else '1' when (pte1_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_core_tag_tp2_q=Core_Tag1_Value   
                                    and reld_ecc_err_ue_tp2_q='1') 
                      else pte1_score_error_q(1);
pte1_score_error_d(2) <=  '0' when pte1_seq_score_load='1'   
                      else '1' when pte1_seq_data_retry='1'   
                      else pte1_score_error_q(2);
pte1_score_dataval_d    <=  '0' when pte1_seq_score_load='1'   or pte1_seq_data_retry='1'
                     else '1' when (pte1_score_pending_q='1'   and reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' 
                                   and reld_crit_qw_tp2_q='1' and reld_qw_tp2_q=pte1_score_cl_offset_q(58   to 59) 
                                    and reld_core_tag_tp2_q=Core_Tag1_Value)
                     else pte1_score_dataval_q;
-- pointers:
--  htw_inptr:      tlb to htw incoming request queue pointer, 4 total
--  htw_lsuptr:     htw to lru outgoing request queue pointer, 4 total
--  pte_load_ptr:   pte machine pointer next to load, 2 total
--  ptereload_ptr:  pte to tlb data reload select, 2 total
htw_inptr_d  <=      "01" when htw_inptr_q="00" and tlb_htw_req0_valid_q='0' and tlb_htw_req1_valid_q='0' and tlb_htw_req_valid='1'
              else "10" when htw_inptr_q="00" and tlb_htw_req0_valid_q='0' and tlb_htw_req1_valid_q='1' and tlb_htw_req2_valid_q='0' and tlb_htw_req_valid='1'
              else "11" when htw_inptr_q="00" and tlb_htw_req0_valid_q='0' and tlb_htw_req1_valid_q='1' and tlb_htw_req2_valid_q='1' and tlb_htw_req3_valid_q='0' and tlb_htw_req_valid='1' 
              else "10" when htw_inptr_q="01" and tlb_htw_req1_valid_q='0' and tlb_htw_req2_valid_q='0' and tlb_htw_req_valid='1'
              else "11" when htw_inptr_q="01" and tlb_htw_req1_valid_q='0' and tlb_htw_req2_valid_q='1' and tlb_htw_req3_valid_q='0' and tlb_htw_req_valid='1'
              else "00" when htw_inptr_q="01" and tlb_htw_req1_valid_q='0' and tlb_htw_req2_valid_q='1' and tlb_htw_req3_valid_q='1' and tlb_htw_req0_valid_q='0' and tlb_htw_req_valid='1' 
              else "11" when htw_inptr_q="10" and tlb_htw_req2_valid_q='0' and tlb_htw_req3_valid_q='0' and tlb_htw_req_valid='1'
              else "00" when htw_inptr_q="10" and tlb_htw_req2_valid_q='0' and tlb_htw_req3_valid_q='1' and tlb_htw_req0_valid_q='0' and tlb_htw_req_valid='1'
              else "01" when htw_inptr_q="10" and tlb_htw_req2_valid_q='0' and tlb_htw_req3_valid_q='1' and tlb_htw_req0_valid_q='1' and tlb_htw_req1_valid_q='0' and tlb_htw_req_valid='1' 
              else "00" when htw_inptr_q="11" and tlb_htw_req3_valid_q='0' and tlb_htw_req0_valid_q='0' and tlb_htw_req_valid='1'
              else "01" when htw_inptr_q="11" and tlb_htw_req3_valid_q='0' and tlb_htw_req0_valid_q='1' and tlb_htw_req1_valid_q='0' and tlb_htw_req_valid='1'
              else "10" when htw_inptr_q="11" and tlb_htw_req3_valid_q='0' and tlb_htw_req0_valid_q='1' and tlb_htw_req1_valid_q='1' and tlb_htw_req2_valid_q='0' and tlb_htw_req_valid='1' 
              else pte0_score_ptr_q when ptereload_ptr_q='0' and ptereload_req_taken='1'
              else pte1_score_ptr_q when ptereload_ptr_q='1' and ptereload_req_taken='1'
              else htw_inptr_q;
htw_lsuptr_d  <=     "01" when htw_lsuptr_q="00" and tlb_htw_req_valid_vec(0)='0' and tlb_htw_req_valid_vec(1)='1'
              else "10" when htw_lsuptr_q="00" and tlb_htw_req_valid_vec(0)='0' and tlb_htw_req_valid_vec(1)='0' and tlb_htw_req_valid_vec(2)='1'
              else "11" when htw_lsuptr_q="00" and tlb_htw_req_valid_vec(0)='0' and tlb_htw_req_valid_vec(1)='0' and tlb_htw_req_valid_vec(2)='0' and tlb_htw_req_valid_vec(3)='1'
              else "10" when htw_lsuptr_q="01" and tlb_htw_req_valid_vec(1)='0' and tlb_htw_req_valid_vec(2)='1'
              else "11" when htw_lsuptr_q="01" and tlb_htw_req_valid_vec(1)='0' and tlb_htw_req_valid_vec(2)='0' and tlb_htw_req_valid_vec(3)='1'
              else "00" when htw_lsuptr_q="01" and tlb_htw_req_valid_vec(1)='0' and tlb_htw_req_valid_vec(2)='0' and tlb_htw_req_valid_vec(3)='0' and tlb_htw_req_valid_vec(0)='1'
              else "11" when htw_lsuptr_q="10" and tlb_htw_req_valid_vec(2)='0' and tlb_htw_req_valid_vec(3)='1'
              else "00" when htw_lsuptr_q="10" and tlb_htw_req_valid_vec(2)='0' and tlb_htw_req_valid_vec(3)='0' and tlb_htw_req_valid_vec(0)='1'
              else "01" when htw_lsuptr_q="10" and tlb_htw_req_valid_vec(2)='0' and tlb_htw_req_valid_vec(3)='0' and tlb_htw_req_valid_vec(0)='0' and tlb_htw_req_valid_vec(1)='1'
              else "00" when htw_lsuptr_q="11" and tlb_htw_req_valid_vec(3)='0' and tlb_htw_req_valid_vec(0)='1'
              else "01" when htw_lsuptr_q="11" and tlb_htw_req_valid_vec(3)='0' and tlb_htw_req_valid_vec(0)='0' and tlb_htw_req_valid_vec(1)='1'
              else "10" when htw_lsuptr_q="11" and tlb_htw_req_valid_vec(3)='0' and tlb_htw_req_valid_vec(0)='0' and tlb_htw_req_valid_vec(1)='0' and tlb_htw_req_valid_vec(2)='1'
              else htw_lsuptr_q;
tlb_htw_req_valid_notpend_vec  <=  (tlb_htw_req0_valid_q and not tlb_htw_req0_pending_q) & 
                                  (tlb_htw_req1_valid_q and not tlb_htw_req1_pending_q) &
                                  (tlb_htw_req2_valid_q and not tlb_htw_req2_pending_q) &
                                  (tlb_htw_req3_valid_q and not tlb_htw_req3_pending_q);
htw_lsuptr_alt_d  <=   "01" when htw_lsuptr_q="00" and tlb_htw_req_valid_notpend_vec(0)='1' and htw_lsu_req_taken='1'  
               else "10" when htw_lsuptr_q="01" and tlb_htw_req_valid_notpend_vec(1)='1' and htw_lsu_req_taken='1'
               else "11" when htw_lsuptr_q="10" and tlb_htw_req_valid_notpend_vec(2)='1' and htw_lsu_req_taken='1'
               else "00" when htw_lsuptr_q="11" and tlb_htw_req_valid_notpend_vec(3)='1' and htw_lsu_req_taken='1'
               else "01" when htw_lsuptr_q="00" and tlb_htw_req_valid_notpend_vec(0)='0' and tlb_htw_req_valid_notpend_vec(1)='1'
               else "10" when htw_lsuptr_q="00" and tlb_htw_req_valid_notpend_vec(0)='0' and tlb_htw_req_valid_notpend_vec(1)='0' and tlb_htw_req_valid_notpend_vec(2)='1'
               else "11" when htw_lsuptr_q="00" and tlb_htw_req_valid_notpend_vec(0)='0' and tlb_htw_req_valid_notpend_vec(1)='0' and tlb_htw_req_valid_notpend_vec(2)='0' and tlb_htw_req_valid_notpend_vec(3)='1'
               else "10" when htw_lsuptr_q="01" and tlb_htw_req_valid_notpend_vec(1)='0' and tlb_htw_req_valid_notpend_vec(2)='1'
               else "11" when htw_lsuptr_q="01" and tlb_htw_req_valid_notpend_vec(1)='0' and tlb_htw_req_valid_notpend_vec(2)='0' and tlb_htw_req_valid_notpend_vec(3)='1'
               else "00" when htw_lsuptr_q="01" and tlb_htw_req_valid_notpend_vec(1)='0' and tlb_htw_req_valid_notpend_vec(2)='0' and tlb_htw_req_valid_notpend_vec(3)='0' and tlb_htw_req_valid_notpend_vec(0)='1'
               else "11" when htw_lsuptr_q="10" and tlb_htw_req_valid_notpend_vec(2)='0' and tlb_htw_req_valid_notpend_vec(3)='1'
               else "00" when htw_lsuptr_q="10" and tlb_htw_req_valid_notpend_vec(2)='0' and tlb_htw_req_valid_notpend_vec(3)='0' and tlb_htw_req_valid_notpend_vec(0)='1'
               else "01" when htw_lsuptr_q="10" and tlb_htw_req_valid_notpend_vec(2)='0' and tlb_htw_req_valid_notpend_vec(3)='0' and tlb_htw_req_valid_notpend_vec(0)='0' and tlb_htw_req_valid_notpend_vec(1)='1'
               else "00" when htw_lsuptr_q="11" and tlb_htw_req_valid_notpend_vec(3)='0' and tlb_htw_req_valid_notpend_vec(0)='1'
               else "01" when htw_lsuptr_q="11" and tlb_htw_req_valid_notpend_vec(3)='0' and tlb_htw_req_valid_notpend_vec(0)='0' and tlb_htw_req_valid_notpend_vec(1)='1'
               else "10" when htw_lsuptr_q="11" and tlb_htw_req_valid_notpend_vec(3)='0' and tlb_htw_req_valid_notpend_vec(0)='0' and tlb_htw_req_valid_notpend_vec(1)='0' and tlb_htw_req_valid_notpend_vec(2)='1'
               else htw_lsuptr_q;
pte_load_ptr_d  <=   '1' when ptereload_ptr_q='1' and pte1_score_pending_q='1' and pte0_score_pending_d='1'  and ptereload_req_taken='1'
              else '0' when ptereload_ptr_q='0' and pte0_score_pending_q='1' and pte1_score_pending_d='1' and ptereload_req_taken='1'
              else '1' when pte_load_ptr_q='0' and pte0_seq_score_load='1' and pte1_score_pending_q='0'
              else '0' when pte_load_ptr_q='1' and pte1_seq_score_load='1' and pte0_score_pending_q='0'
              else pte_load_ptr_q;
ptereload_ptr_d  <=  '1' when ptereload_ptr_q='0' and ptereload_req_taken='1'
              else '1' when ptereload_ptr_q='0' and pte0_reload_req_valid='0' and pte1_reload_req_valid='1'
              else '0' when ptereload_ptr_q='1' and ptereload_req_taken='1'
              else '0' when ptereload_ptr_q='1' and pte0_reload_req_valid='1' and pte1_reload_req_valid='0'
              else ptereload_ptr_q;
-- 0=tlbivax_op, 1=tlbi_complete, 2=mmu read with core_tag=01100, 3=mmu read with core_tag=01101
htw_lsu_ttype_d  <=  "11" when (pte_load_ptr_q='1' and htw_seq_load_pteaddr='1')  
              else "10" when htw_seq_load_pteaddr='1' 
              else htw_lsu_ttype_q;
htw_lsu_thdid_d  <=  tlb_htw_req0_tag_q(tagpos_thdid to tagpos_thdid+thdid_width-1) when htw_lsuptr_q="00" and tlb_htw_req0_valid_q='1' and htw_seq_load_pteaddr='1'
              else tlb_htw_req1_tag_q(tagpos_thdid to tagpos_thdid+thdid_width-1) when htw_lsuptr_q="01" and tlb_htw_req1_valid_q='1' and htw_seq_load_pteaddr='1'
              else tlb_htw_req2_tag_q(tagpos_thdid to tagpos_thdid+thdid_width-1) when htw_lsuptr_q="10" and tlb_htw_req2_valid_q='1' and htw_seq_load_pteaddr='1'
              else tlb_htw_req3_tag_q(tagpos_thdid to tagpos_thdid+thdid_width-1) when htw_lsuptr_q="11" and tlb_htw_req3_valid_q='1' and htw_seq_load_pteaddr='1'
              else htw_lsu_thdid_q;
htw_lsu_wimge_d  <=  tlb_htw_req0_way_q(waypos_wimge to waypos_wimge+4) when htw_lsuptr_q="00" and tlb_htw_req0_valid_q='1' and htw_seq_load_pteaddr='1'
              else tlb_htw_req1_way_q(waypos_wimge to waypos_wimge+4) when htw_lsuptr_q="01" and tlb_htw_req1_valid_q='1' and htw_seq_load_pteaddr='1'
              else tlb_htw_req2_way_q(waypos_wimge to waypos_wimge+4) when htw_lsuptr_q="10" and tlb_htw_req2_valid_q='1' and htw_seq_load_pteaddr='1'
              else tlb_htw_req3_way_q(waypos_wimge to waypos_wimge+4) when htw_lsuptr_q="11" and tlb_htw_req3_valid_q='1' and htw_seq_load_pteaddr='1'
              else htw_lsu_wimge_q;
htw_lsu_u_d  <=  tlb_htw_req0_way_q(waypos_ubits to waypos_ubits+3) when htw_lsuptr_q="00" and tlb_htw_req0_valid_q='1' and htw_seq_load_pteaddr='1'
              else tlb_htw_req1_way_q(waypos_ubits to waypos_ubits+3) when htw_lsuptr_q="01" and tlb_htw_req1_valid_q='1' and htw_seq_load_pteaddr='1'
              else tlb_htw_req2_way_q(waypos_ubits to waypos_ubits+3) when htw_lsuptr_q="10" and tlb_htw_req2_valid_q='1' and htw_seq_load_pteaddr='1'
              else tlb_htw_req3_way_q(waypos_ubits to waypos_ubits+3) when htw_lsuptr_q="11" and tlb_htw_req3_valid_q='1' and htw_seq_load_pteaddr='1'
              else htw_lsu_u_q;
htw_lsu_addr_d  <=  pte_ra_0 when htw_lsuptr_q="00" and tlb_htw_req0_valid_q='1' and htw_seq_load_pteaddr='1'
              else pte_ra_1 when htw_lsuptr_q="01" and tlb_htw_req1_valid_q='1' and htw_seq_load_pteaddr='1'
              else pte_ra_2 when htw_lsuptr_q="10" and tlb_htw_req2_valid_q='1' and htw_seq_load_pteaddr='1'
              else pte_ra_3 when htw_lsuptr_q="11" and tlb_htw_req3_valid_q='1' and htw_seq_load_pteaddr='1'
              else htw_lsu_addr_q;
htw_lsu_act  <=  (or_reduce(htw_seq_q) or mmucr2_act_override) and xu_mm_ccr2_notlb_b;
htw_lsu_thdid     <=  htw_lsu_thdid_q;
htw_dbg_lsu_thdid(0) <=  htw_lsu_thdid_q(2) or htw_lsu_thdid_q(3);
htw_dbg_lsu_thdid(1) <=  htw_lsu_thdid_q(1) or htw_lsu_thdid_q(3);
htw_lsu_ttype     <=  htw_lsu_ttype_q;
htw_lsu_wimge     <=  htw_lsu_wimge_q;
htw_lsu_u         <=  htw_lsu_u_q;
htw_lsu_addr      <=  htw_lsu_addr_q;
-- L2 data reload stages
--  t minus 2 phase
reld_core_tag_tm1_d  <=   an_ac_reld_core_tag;
reld_qw_tm1_d        <=   an_ac_reld_qw;
reld_crit_qw_tm1_d   <=   an_ac_reld_crit_qw;
reld_ditc_tm1_d      <=   an_ac_reld_ditc;
reld_data_vld_tm1_d  <=   an_ac_reld_data_vld;
--  t minus 1 phase
reld_core_tag_t_d  <=  reld_core_tag_tm1_q;
reld_qw_t_d        <=  reld_qw_tm1_q;
reld_crit_qw_t_d   <=  reld_crit_qw_tm1_q;
reld_ditc_t_d      <=  reld_ditc_tm1_q;
reld_data_vld_t_d  <=  reld_data_vld_tm1_q;
pte0_reld_for_me_tm1    <=  '1' when (reld_data_vld_tm1_q='1' and reld_ditc_tm1_q='0' and reld_crit_qw_tm1_q='1' 
                                 and reld_qw_tm1_q=pte0_score_cl_offset_q(58   to 59) and reld_core_tag_tm1_q=Core_Tag0_Value)
                     else '0';
pte1_reld_for_me_tm1    <=  '1' when (reld_data_vld_tm1_q='1' and reld_ditc_tm1_q='0' and reld_crit_qw_tm1_q='1' 
                                 and reld_qw_tm1_q=pte1_score_cl_offset_q(58   to 59) and reld_core_tag_tm1_q=Core_Tag1_Value)
                     else '0';
--  t phase
reld_core_tag_tp1_d  <=  reld_core_tag_t_q;
reld_qw_tp1_d        <=  reld_qw_t_q;
reld_crit_qw_tp1_d   <=  reld_crit_qw_t_q;
reld_ditc_tp1_d      <=  reld_ditc_t_q;
reld_data_vld_tp1_d  <=  reld_data_vld_t_q;
reld_data_tp1_d      <=   an_ac_reld_data;
--  t plus 1 phase
reld_core_tag_tp2_d    <=  reld_core_tag_tp1_q;
reld_qw_tp2_d          <=  reld_qw_tp1_q;
reld_crit_qw_tp2_d     <=  reld_crit_qw_tp1_q;
reld_ditc_tp2_d        <=  reld_ditc_tp1_q;
reld_data_vld_tp2_d    <=  reld_data_vld_tp1_q;
reld_data_tp2_d        <=  reld_data_tp1_q;
reld_ecc_err_tp2_d     <=   an_ac_reld_ecc_err;
reld_ecc_err_ue_tp2_d  <=   an_ac_reld_ecc_err_ue;
--  t plus 2 phase
pte0_reld_for_me_tp2    <=  '1' when (reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' and reld_crit_qw_tp2_q='1' 
                                 and reld_qw_tp2_q=pte0_score_cl_offset_q(58   to 59) and reld_core_tag_tp2_q=Core_Tag0_Value)
                     else '0';
pte0_reld_data_tp3_d     <=  reld_data_tp2_q(0 to 63) when (pte0_reld_for_me_tp2='1'   and pte0_score_cl_offset_q(60)='0')
                      else reld_data_tp2_q(64 to 127) when (pte0_reld_for_me_tp2='1'   and pte0_score_cl_offset_q(60)='1')
                      else pte0_reld_data_tp3_q;
pte1_reld_for_me_tp2    <=  '1' when (reld_data_vld_tp2_q='1' and reld_ditc_tp2_q='0' and reld_crit_qw_tp2_q='1' 
                                 and reld_qw_tp2_q=pte1_score_cl_offset_q(58   to 59) and reld_core_tag_tp2_q=Core_Tag1_Value)
                     else '0';
pte1_reld_data_tp3_d     <=  reld_data_tp2_q(0 to 63) when (pte1_reld_for_me_tp2='1'   and pte1_score_cl_offset_q(60)='0')
                      else reld_data_tp2_q(64 to 127) when (pte1_reld_for_me_tp2='1'   and pte1_score_cl_offset_q(60)='1')
                      else pte1_reld_data_tp3_q;
reld_act  <=  (or_reduce(pte0_seq_q) or or_reduce(pte1_seq_q) or mmucr2_act_override) and xu_mm_ccr2_notlb_b;
pte0_reld_act  <=  (or_reduce(pte0_seq_q) or mmucr2_act_override) and xu_mm_ccr2_notlb_b;
pte1_reld_act  <=  (or_reduce(pte1_seq_q) or mmucr2_act_override) and xu_mm_ccr2_notlb_b;
-- ptereload requests to tlb_ctl
ptereload_req_valid  <=  '0' when (htw_tag4_clr_resv_q/="0000" or htw_tag5_clr_resv_q/="0000") 
                  else pte1_reload_req_valid when ptereload_ptr_q='1'
                  else pte0_reload_req_valid;
ptereload_req_tag    <=  tlb_htw_req1_tag_q when ((ptereload_ptr_q='0' and pte0_score_ptr_q="01") or 
                                                  (ptereload_ptr_q='1' and pte1_score_ptr_q="01"))
                  else tlb_htw_req2_tag_q when ((ptereload_ptr_q='0' and pte0_score_ptr_q="10") or 
                                                   (ptereload_ptr_q='1' and pte1_score_ptr_q="10"))
                  else tlb_htw_req3_tag_q when ((ptereload_ptr_q='0' and pte0_score_ptr_q="11") or 
                                                   (ptereload_ptr_q='1' and pte1_score_ptr_q="11"))
                  else tlb_htw_req0_tag_q;
ptereload_req_pte    <=  pte1_reld_data_tp3_q when ptereload_ptr_q='1'
                  else pte0_reld_data_tp3_q;
htw_tag4_clr_resv_terms  <=  (others => '0');
htw_dbg_seq_idle                  <=  htw_seq_idle;
htw_dbg_pte0_seq_idle             <=  pte0_seq_idle;
htw_dbg_pte1_seq_idle             <=  pte1_seq_idle;
htw_dbg_seq_q                     <=  htw_seq_q;
htw_dbg_inptr_q                   <=  htw_inptr_q;
htw_dbg_pte0_seq_q                <=  pte0_seq_q;
htw_dbg_pte1_seq_q                <=  pte1_seq_q;
htw_dbg_ptereload_ptr_q           <=  ptereload_ptr_q;
htw_dbg_lsuptr_q                  <=  htw_lsuptr_q;
htw_dbg_req_valid_q               <=  tlb_htw_req0_valid_q & tlb_htw_req1_valid_q & tlb_htw_req2_valid_q & tlb_htw_req3_valid_q;
htw_dbg_resv_valid_vec            <=  htw_resv_valid_vec;
htw_dbg_tag4_clr_resv_q           <=  htw_tag4_clr_resv_q;
htw_dbg_tag4_clr_resv_terms       <=  htw_tag4_clr_resv_terms;
htw_dbg_pte0_score_ptr_q          <=  pte0_score_ptr_q;
htw_dbg_pte0_score_cl_offset_q    <=  pte0_score_cl_offset_q;
htw_dbg_pte0_score_error_q        <=  pte0_score_error_q;
htw_dbg_pte0_score_qwbeat_q       <=  pte0_score_qwbeat_q;
htw_dbg_pte0_score_pending_q      <=  pte0_score_pending_q;
htw_dbg_pte0_score_ibit_q         <=  pte0_score_ibit_q;
htw_dbg_pte0_score_dataval_q      <=  pte0_score_dataval_q;
htw_dbg_pte0_reld_for_me_tm1      <=  pte0_reld_for_me_tm1;
htw_dbg_pte1_score_ptr_q          <=  pte1_score_ptr_q;
htw_dbg_pte1_score_cl_offset_q    <=  pte1_score_cl_offset_q;
htw_dbg_pte1_score_error_q        <=  pte1_score_error_q;
htw_dbg_pte1_score_qwbeat_q       <=  pte1_score_qwbeat_q;
htw_dbg_pte1_score_pending_q      <=  pte1_score_pending_q;
htw_dbg_pte1_score_ibit_q         <=  pte1_score_ibit_q;
htw_dbg_pte1_score_dataval_q      <=  pte1_score_dataval_q;
htw_dbg_pte1_reld_for_me_tm1      <=  pte1_reld_for_me_tm1;
-- unused spare signal assignments
unused_dc(0) <=  or_reduce(LCB_DELAY_LCLKR_DC(1 TO 4));
unused_dc(1) <=  or_reduce(LCB_MPW1_DC_B(1 TO 4));
unused_dc(2) <=  PC_FUNC_SL_FORCE;
unused_dc(3) <=  PC_FUNC_SL_THOLD_0_B;
unused_dc(4) <=  TC_SCAN_DIS_DC_B;
unused_dc(5) <=  TC_SCAN_DIAG_DC;
unused_dc(6) <=  TC_LBIST_EN_DC;
unused_dc(7) <=  or_reduce(TLB_HTW_REQ_TAG(104 TO 105));
unused_dc(8) <=  HTW_TAG3_Q(70);
unused_dc(9) <=  HTW_TAG3_Q(73);
unused_dc(10) <=  or_reduce(HTW_TAG3_Q(82 TO 85));
unused_dc(11) <=  HTW_TAG3_Q(87);
unused_dc(12) <=  or_reduce(HTW_TAG3_Q(98 TO 103));
unused_dc(13) <=  or_reduce(HTW_TAG3_Q(106 TO 109));
unused_dc(14) <=  PTE0_RELD_ENABLE_LO_TP2 or PTE0_RELD_ENABLE_HI_TP2;
unused_dc(15) <=  PTE1_RELD_ENABLE_LO_TP2 or PTE1_RELD_ENABLE_HI_TP2;
unused_dc(16 TO 19) <=  tlb_htw_req0_pending_q & tlb_htw_req1_pending_q & tlb_htw_req2_pending_q & tlb_htw_req3_pending_q;
unused_dc(20 TO 21) <=  htw_lsuptr_alt_d;
-----------------------------------------------------------------------
-- Latches
-----------------------------------------------------------------------
-- tlb request valid latches
tlb_htw_req0_valid_latch:   tri_rlmlatch_p
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
            scin    => siv_0(tlb_htw_req0_valid_offset),
            scout   => sov_0(tlb_htw_req0_valid_offset),
            din     => tlb_htw_req0_valid_d,
            dout    => tlb_htw_req0_valid_q);
-- tlb request pending latches.. this req is loaded into a pte machine
tlb_htw_req0_pending_latch:   tri_rlmlatch_p
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
            scin    => siv_0(tlb_htw_req0_pending_offset),
            scout   => sov_0(tlb_htw_req0_pending_offset),
            din     => tlb_htw_req0_pending_d,
            dout    => tlb_htw_req0_pending_q);
-- tlb request tag latches
tlb_htw_req0_tag_latch:   tri_rlmreg_p
  generic map (width => tlb_htw_req0_tag_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_htw_req0_tag_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_htw_req0_tag_offset   to tlb_htw_req0_tag_offset+tlb_htw_req0_tag_q'length-1),
            scout   => sov_0(tlb_htw_req0_tag_offset   to tlb_htw_req0_tag_offset+tlb_htw_req0_tag_q'length-1),
            din     => tlb_htw_req0_tag_d,
            dout    => tlb_htw_req0_tag_q    );
-- tlb request tag latches
tlb_htw_req0_way_latch:   tri_rlmreg_p
  generic map (width => tlb_htw_req0_way_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(24+0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_htw_req0_way_offset   to tlb_htw_req0_way_offset+tlb_htw_req0_way_q'length-1),
            scout   => sov_0(tlb_htw_req0_way_offset   to tlb_htw_req0_way_offset+tlb_htw_req0_way_q'length-1),
            din     => tlb_htw_req0_way_d,
            dout    => tlb_htw_req0_way_q    );
-- tlb request valid latches
tlb_htw_req1_valid_latch:   tri_rlmlatch_p
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
            scin    => siv_0(tlb_htw_req1_valid_offset),
            scout   => sov_0(tlb_htw_req1_valid_offset),
            din     => tlb_htw_req1_valid_d,
            dout    => tlb_htw_req1_valid_q);
-- tlb request pending latches.. this req is loaded into a pte machine
tlb_htw_req1_pending_latch:   tri_rlmlatch_p
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
            scin    => siv_0(tlb_htw_req1_pending_offset),
            scout   => sov_0(tlb_htw_req1_pending_offset),
            din     => tlb_htw_req1_pending_d,
            dout    => tlb_htw_req1_pending_q);
-- tlb request tag latches
tlb_htw_req1_tag_latch:   tri_rlmreg_p
  generic map (width => tlb_htw_req1_tag_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_htw_req1_tag_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_htw_req1_tag_offset   to tlb_htw_req1_tag_offset+tlb_htw_req1_tag_q'length-1),
            scout   => sov_0(tlb_htw_req1_tag_offset   to tlb_htw_req1_tag_offset+tlb_htw_req1_tag_q'length-1),
            din     => tlb_htw_req1_tag_d,
            dout    => tlb_htw_req1_tag_q    );
-- tlb request tag latches
tlb_htw_req1_way_latch:   tri_rlmreg_p
  generic map (width => tlb_htw_req1_way_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(24+1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_htw_req1_way_offset   to tlb_htw_req1_way_offset+tlb_htw_req1_way_q'length-1),
            scout   => sov_0(tlb_htw_req1_way_offset   to tlb_htw_req1_way_offset+tlb_htw_req1_way_q'length-1),
            din     => tlb_htw_req1_way_d,
            dout    => tlb_htw_req1_way_q    );
-- tlb request valid latches
tlb_htw_req2_valid_latch:   tri_rlmlatch_p
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
            scin    => siv_0(tlb_htw_req2_valid_offset),
            scout   => sov_0(tlb_htw_req2_valid_offset),
            din     => tlb_htw_req2_valid_d,
            dout    => tlb_htw_req2_valid_q);
-- tlb request pending latches.. this req is loaded into a pte machine
tlb_htw_req2_pending_latch:   tri_rlmlatch_p
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
            scin    => siv_0(tlb_htw_req2_pending_offset),
            scout   => sov_0(tlb_htw_req2_pending_offset),
            din     => tlb_htw_req2_pending_d,
            dout    => tlb_htw_req2_pending_q);
-- tlb request tag latches
tlb_htw_req2_tag_latch:   tri_rlmreg_p
  generic map (width => tlb_htw_req2_tag_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_htw_req2_tag_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_htw_req2_tag_offset   to tlb_htw_req2_tag_offset+tlb_htw_req2_tag_q'length-1),
            scout   => sov_0(tlb_htw_req2_tag_offset   to tlb_htw_req2_tag_offset+tlb_htw_req2_tag_q'length-1),
            din     => tlb_htw_req2_tag_d,
            dout    => tlb_htw_req2_tag_q    );
-- tlb request tag latches
tlb_htw_req2_way_latch:   tri_rlmreg_p
  generic map (width => tlb_htw_req2_way_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(24+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_htw_req2_way_offset   to tlb_htw_req2_way_offset+tlb_htw_req2_way_q'length-1),
            scout   => sov_0(tlb_htw_req2_way_offset   to tlb_htw_req2_way_offset+tlb_htw_req2_way_q'length-1),
            din     => tlb_htw_req2_way_d,
            dout    => tlb_htw_req2_way_q    );
-- tlb request valid latches
tlb_htw_req3_valid_latch:   tri_rlmlatch_p
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
            scin    => siv_0(tlb_htw_req3_valid_offset),
            scout   => sov_0(tlb_htw_req3_valid_offset),
            din     => tlb_htw_req3_valid_d,
            dout    => tlb_htw_req3_valid_q);
tlb_htw_req3_pending_latch:   tri_rlmlatch_p
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
            scin    => siv_0(tlb_htw_req3_pending_offset),
            scout   => sov_0(tlb_htw_req3_pending_offset),
            din     => tlb_htw_req3_pending_d,
            dout    => tlb_htw_req3_pending_q);
-- tlb request tag latches
tlb_htw_req3_tag_latch:   tri_rlmreg_p
  generic map (width => tlb_htw_req3_tag_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_htw_req3_tag_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_htw_req3_tag_offset   to tlb_htw_req3_tag_offset+tlb_htw_req3_tag_q'length-1),
            scout   => sov_0(tlb_htw_req3_tag_offset   to tlb_htw_req3_tag_offset+tlb_htw_req3_tag_q'length-1),
            din     => tlb_htw_req3_tag_d,
            dout    => tlb_htw_req3_tag_q    );
-- tlb request tag latches
tlb_htw_req3_way_latch:   tri_rlmreg_p
  generic map (width => tlb_htw_req3_way_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(24+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(tlb_htw_req3_way_offset   to tlb_htw_req3_way_offset+tlb_htw_req3_way_q'length-1),
            scout   => sov_0(tlb_htw_req3_way_offset   to tlb_htw_req3_way_offset+tlb_htw_req3_way_q'length-1),
            din     => tlb_htw_req3_way_d,
            dout    => tlb_htw_req3_way_q    );
spare_a_latch: tri_rlmreg_p
  generic map (width => spare_a_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_0(spare_a_offset to spare_a_offset+spare_a_q'length-1),
            scout   => sov_0(spare_a_offset to spare_a_offset+spare_a_q'length-1),
            din     => spare_a_q,
            dout    => spare_a_q  );
htw_seq_latch: tri_rlmreg_p
  generic map (width => htw_seq_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(htw_seq_offset to htw_seq_offset+htw_seq_q'length-1),
            scout   => sov_1(htw_seq_offset to htw_seq_offset+htw_seq_q'length-1),
            din     => htw_seq_d(0 to htw_seq_width-1),
            dout    => htw_seq_q(0 to htw_seq_width-1)  );
htw_inptr_latch: tri_rlmreg_p
  generic map (width => htw_inptr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(htw_inptr_offset to htw_inptr_offset+htw_inptr_q'length-1),
            scout   => sov_1(htw_inptr_offset to htw_inptr_offset+htw_inptr_q'length-1),
            din     => htw_inptr_d,
            dout    => htw_inptr_q  );
htw_lsuptr_latch: tri_rlmreg_p
  generic map (width => htw_lsuptr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(htw_lsuptr_offset to htw_lsuptr_offset+htw_lsuptr_q'length-1),
            scout   => sov_1(htw_lsuptr_offset to htw_lsuptr_offset+htw_lsuptr_q'length-1),
            din     => htw_lsuptr_d,
            dout    => htw_lsuptr_q  );
htw_lsu_ttype_latch: tri_rlmreg_p
  generic map (width => htw_lsu_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => htw_lsu_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(htw_lsu_ttype_offset to htw_lsu_ttype_offset+htw_lsu_ttype_q'length-1),
            scout   => sov_1(htw_lsu_ttype_offset to htw_lsu_ttype_offset+htw_lsu_ttype_q'length-1),
            din     => htw_lsu_ttype_d,
            dout    => htw_lsu_ttype_q  );
htw_lsu_thdid_latch: tri_rlmreg_p
  generic map (width => htw_lsu_thdid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => htw_lsu_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(htw_lsu_thdid_offset to htw_lsu_thdid_offset+htw_lsu_thdid_q'length-1),
            scout   => sov_1(htw_lsu_thdid_offset to htw_lsu_thdid_offset+htw_lsu_thdid_q'length-1),
            din     => htw_lsu_thdid_d,
            dout    => htw_lsu_thdid_q  );
htw_lsu_wimge_latch: tri_rlmreg_p
  generic map (width => htw_lsu_wimge_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => htw_lsu_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(htw_lsu_wimge_offset to htw_lsu_wimge_offset+htw_lsu_wimge_q'length-1),
            scout   => sov_1(htw_lsu_wimge_offset to htw_lsu_wimge_offset+htw_lsu_wimge_q'length-1),
            din     => htw_lsu_wimge_d,
            dout    => htw_lsu_wimge_q  );
htw_lsu_u_latch: tri_rlmreg_p
  generic map (width => htw_lsu_u_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => htw_lsu_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(htw_lsu_u_offset to htw_lsu_u_offset+htw_lsu_u_q'length-1),
            scout   => sov_1(htw_lsu_u_offset to htw_lsu_u_offset+htw_lsu_u_q'length-1),
            din     => htw_lsu_u_d,
            dout    => htw_lsu_u_q  );
htw_lsu_addr_latch: tri_rlmreg_p
  generic map (width => htw_lsu_addr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => htw_lsu_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(htw_lsu_addr_offset to htw_lsu_addr_offset+htw_lsu_addr_q'length-1),
            scout   => sov_1(htw_lsu_addr_offset to htw_lsu_addr_offset+htw_lsu_addr_q'length-1),
            din     => htw_lsu_addr_d,
            dout    => htw_lsu_addr_q  );
pte0_seq_latch:   tri_rlmreg_p
  generic map (width => pte0_seq_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(pte0_seq_offset   to pte0_seq_offset+pte0_seq_q'length-1),
            scout   => sov_1(pte0_seq_offset   to pte0_seq_offset+pte0_seq_q'length-1),
            din     => pte0_seq_d,
            dout    => pte0_seq_q    );
pte0_score_ptr_latch:   tri_rlmreg_p
  generic map (width => pte0_score_ptr_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte0_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte0_score_ptr_offset   to pte0_score_ptr_offset+pte0_score_ptr_q'length-1),
            scout   => sov_1(pte0_score_ptr_offset   to pte0_score_ptr_offset+pte0_score_ptr_q'length-1),
            din     => pte0_score_ptr_d,
            dout    => pte0_score_ptr_q    );
pte0_score_cl_offset_latch:   tri_rlmreg_p
  generic map (width => pte0_score_cl_offset_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte0_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte0_score_cl_offset_offset   to pte0_score_cl_offset_offset+pte0_score_cl_offset_q'length-1),
            scout   => sov_1(pte0_score_cl_offset_offset   to pte0_score_cl_offset_offset+pte0_score_cl_offset_q'length-1),
            din     => pte0_score_cl_offset_d,
            dout    => pte0_score_cl_offset_q    );
pte0_score_error_latch:   tri_rlmreg_p
  generic map (width => pte0_score_error_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte0_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte0_score_error_offset   to pte0_score_error_offset+pte0_score_error_q'length-1),
            scout   => sov_1(pte0_score_error_offset   to pte0_score_error_offset+pte0_score_error_q'length-1),
            din     => pte0_score_error_d,
            dout    => pte0_score_error_q    );
pte0_score_qwbeat_latch:   tri_rlmreg_p
  generic map (width => pte0_score_qwbeat_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte0_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte0_score_qwbeat_offset   to pte0_score_qwbeat_offset+pte0_score_qwbeat_q'length-1),
            scout   => sov_1(pte0_score_qwbeat_offset   to pte0_score_qwbeat_offset+pte0_score_qwbeat_q'length-1),
            din     => pte0_score_qwbeat_d,
            dout    => pte0_score_qwbeat_q    );
pte0_score_ibit_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte0_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte0_score_ibit_offset),
            scout   => sov_1(pte0_score_ibit_offset),
            din     => pte0_score_ibit_d,
            dout    => pte0_score_ibit_q);
pte0_score_pending_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte0_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte0_score_pending_offset),
            scout   => sov_1(pte0_score_pending_offset),
            din     => pte0_score_pending_d,
            dout    => pte0_score_pending_q);
pte0_score_dataval_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte0_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte0_score_dataval_offset),
            scout   => sov_1(pte0_score_dataval_offset),
            din     => pte0_score_dataval_d,
            dout    => pte0_score_dataval_q);
pte1_seq_latch:   tri_rlmreg_p
  generic map (width => pte1_seq_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(pte1_seq_offset   to pte1_seq_offset+pte1_seq_q'length-1),
            scout   => sov_1(pte1_seq_offset   to pte1_seq_offset+pte1_seq_q'length-1),
            din     => pte1_seq_d,
            dout    => pte1_seq_q    );
pte1_score_ptr_latch:   tri_rlmreg_p
  generic map (width => pte1_score_ptr_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte1_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte1_score_ptr_offset   to pte1_score_ptr_offset+pte1_score_ptr_q'length-1),
            scout   => sov_1(pte1_score_ptr_offset   to pte1_score_ptr_offset+pte1_score_ptr_q'length-1),
            din     => pte1_score_ptr_d,
            dout    => pte1_score_ptr_q    );
pte1_score_cl_offset_latch:   tri_rlmreg_p
  generic map (width => pte1_score_cl_offset_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte1_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte1_score_cl_offset_offset   to pte1_score_cl_offset_offset+pte1_score_cl_offset_q'length-1),
            scout   => sov_1(pte1_score_cl_offset_offset   to pte1_score_cl_offset_offset+pte1_score_cl_offset_q'length-1),
            din     => pte1_score_cl_offset_d,
            dout    => pte1_score_cl_offset_q    );
pte1_score_error_latch:   tri_rlmreg_p
  generic map (width => pte1_score_error_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte1_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte1_score_error_offset   to pte1_score_error_offset+pte1_score_error_q'length-1),
            scout   => sov_1(pte1_score_error_offset   to pte1_score_error_offset+pte1_score_error_q'length-1),
            din     => pte1_score_error_d,
            dout    => pte1_score_error_q    );
pte1_score_qwbeat_latch:   tri_rlmreg_p
  generic map (width => pte1_score_qwbeat_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte1_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte1_score_qwbeat_offset   to pte1_score_qwbeat_offset+pte1_score_qwbeat_q'length-1),
            scout   => sov_1(pte1_score_qwbeat_offset   to pte1_score_qwbeat_offset+pte1_score_qwbeat_q'length-1),
            din     => pte1_score_qwbeat_d,
            dout    => pte1_score_qwbeat_q    );
pte1_score_ibit_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte1_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte1_score_ibit_offset),
            scout   => sov_1(pte1_score_ibit_offset),
            din     => pte1_score_ibit_d,
            dout    => pte1_score_ibit_q);
pte1_score_pending_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte1_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte1_score_pending_offset),
            scout   => sov_1(pte1_score_pending_offset),
            din     => pte1_score_pending_d,
            dout    => pte1_score_pending_q);
pte1_score_dataval_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte1_score_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte1_score_dataval_offset),
            scout   => sov_1(pte1_score_dataval_offset),
            din     => pte1_score_dataval_d,
            dout    => pte1_score_dataval_q);
pte_load_ptr_latch: tri_rlmlatch_p
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
            scin    => siv_1(pte_load_ptr_offset),
            scout   => sov_1(pte_load_ptr_offset),
            din     => pte_load_ptr_d,
            dout    => pte_load_ptr_q);
ptereload_ptr_latch: tri_rlmlatch_p
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
            scin    => siv_1(ptereload_ptr_offset),
            scout   => sov_1(ptereload_ptr_offset),
            din     => ptereload_ptr_d,
            dout    => ptereload_ptr_q);
--  t minus 1 phase latches
reld_core_tag_tm1_latch: tri_rlmreg_p
  generic map (width => reld_core_tag_tm1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_core_tag_tm1_offset to reld_core_tag_tm1_offset+reld_core_tag_tm1_q'length-1),
            scout   => sov_1(reld_core_tag_tm1_offset to reld_core_tag_tm1_offset+reld_core_tag_tm1_q'length-1),
            din     => reld_core_tag_tm1_d,
            dout    => reld_core_tag_tm1_q  );
reld_qw_tm1_latch: tri_rlmreg_p
  generic map (width => reld_qw_tm1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_qw_tm1_offset to reld_qw_tm1_offset+reld_qw_tm1_q'length-1),
            scout   => sov_1(reld_qw_tm1_offset to reld_qw_tm1_offset+reld_qw_tm1_q'length-1),
            din     => reld_qw_tm1_d,
            dout    => reld_qw_tm1_q  );
reld_crit_qw_tm1_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_crit_qw_tm1_offset),
            scout   => sov_1(reld_crit_qw_tm1_offset),
            din     => reld_crit_qw_tm1_d,
            dout    => reld_crit_qw_tm1_q);
reld_ditc_tm1_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_ditc_tm1_offset),
            scout   => sov_1(reld_ditc_tm1_offset),
            din     => reld_ditc_tm1_d,
            dout    => reld_ditc_tm1_q);
reld_data_vld_tm1_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_data_vld_tm1_offset),
            scout   => sov_1(reld_data_vld_tm1_offset),
            din     => reld_data_vld_tm1_d,
            dout    => reld_data_vld_tm1_q);
--  t   phase latches
reld_core_tag_t_latch:   tri_rlmreg_p
  generic map (width => reld_core_tag_t_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_core_tag_t_offset   to reld_core_tag_t_offset+reld_core_tag_t_q'length-1),
            scout   => sov_1(reld_core_tag_t_offset   to reld_core_tag_t_offset+reld_core_tag_t_q'length-1),
            din     => reld_core_tag_t_d,
            dout    => reld_core_tag_t_q    );
reld_qw_t_latch:   tri_rlmreg_p
  generic map (width => reld_qw_t_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_qw_t_offset   to reld_qw_t_offset+reld_qw_t_q'length-1),
            scout   => sov_1(reld_qw_t_offset   to reld_qw_t_offset+reld_qw_t_q'length-1),
            din     => reld_qw_t_d,
            dout    => reld_qw_t_q    );
reld_crit_qw_t_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_crit_qw_t_offset),
            scout   => sov_1(reld_crit_qw_t_offset),
            din     => reld_crit_qw_t_d,
            dout    => reld_crit_qw_t_q);
reld_ditc_t_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_ditc_t_offset),
            scout   => sov_1(reld_ditc_t_offset),
            din     => reld_ditc_t_d,
            dout    => reld_ditc_t_q);
reld_data_vld_t_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_data_vld_t_offset),
            scout   => sov_1(reld_data_vld_t_offset),
            din     => reld_data_vld_t_d,
            dout    => reld_data_vld_t_q);
--  t plus 1 phase latches
reld_core_tag_tp1_latch: tri_rlmreg_p
  generic map (width => reld_core_tag_tp1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_core_tag_tp1_offset to reld_core_tag_tp1_offset+reld_core_tag_tp1_q'length-1),
            scout   => sov_1(reld_core_tag_tp1_offset to reld_core_tag_tp1_offset+reld_core_tag_tp1_q'length-1),
            din     => reld_core_tag_tp1_d,
            dout    => reld_core_tag_tp1_q  );
reld_qw_tp1_latch: tri_rlmreg_p
  generic map (width => reld_qw_tp1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_qw_tp1_offset to reld_qw_tp1_offset+reld_qw_tp1_q'length-1),
            scout   => sov_1(reld_qw_tp1_offset to reld_qw_tp1_offset+reld_qw_tp1_q'length-1),
            din     => reld_qw_tp1_d,
            dout    => reld_qw_tp1_q  );
reld_crit_qw_tp1_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_crit_qw_tp1_offset),
            scout   => sov_1(reld_crit_qw_tp1_offset),
            din     => reld_crit_qw_tp1_d,
            dout    => reld_crit_qw_tp1_q);
reld_ditc_tp1_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_ditc_tp1_offset),
            scout   => sov_1(reld_ditc_tp1_offset),
            din     => reld_ditc_tp1_d,
            dout    => reld_ditc_tp1_q);
reld_data_vld_tp1_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_data_vld_tp1_offset),
            scout   => sov_1(reld_data_vld_tp1_offset),
            din     => reld_data_vld_tp1_d,
            dout    => reld_data_vld_tp1_q);
reld_data_tp1_latch: tri_rlmreg_p
  generic map (width => reld_data_tp1_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_data_tp1_offset to reld_data_tp1_offset+reld_data_tp1_q'length-1),
            scout   => sov_1(reld_data_tp1_offset to reld_data_tp1_offset+reld_data_tp1_q'length-1),
            din     => reld_data_tp1_d,
            dout    => reld_data_tp1_q  );
--  t plus 2 phase latches
reld_core_tag_tp2_latch: tri_rlmreg_p
  generic map (width => reld_core_tag_tp2_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_core_tag_tp2_offset to reld_core_tag_tp2_offset+reld_core_tag_tp2_q'length-1),
            scout   => sov_1(reld_core_tag_tp2_offset to reld_core_tag_tp2_offset+reld_core_tag_tp2_q'length-1),
            din     => reld_core_tag_tp2_d,
            dout    => reld_core_tag_tp2_q  );
reld_qw_tp2_latch: tri_rlmreg_p
  generic map (width => reld_qw_tp2_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_qw_tp2_offset to reld_qw_tp2_offset+reld_qw_tp2_q'length-1),
            scout   => sov_1(reld_qw_tp2_offset to reld_qw_tp2_offset+reld_qw_tp2_q'length-1),
            din     => reld_qw_tp2_d,
            dout    => reld_qw_tp2_q  );
reld_crit_qw_tp2_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_crit_qw_tp2_offset),
            scout   => sov_1(reld_crit_qw_tp2_offset),
            din     => reld_crit_qw_tp2_d,
            dout    => reld_crit_qw_tp2_q);
reld_ditc_tp2_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_ditc_tp2_offset),
            scout   => sov_1(reld_ditc_tp2_offset),
            din     => reld_ditc_tp2_d,
            dout    => reld_ditc_tp2_q);
reld_data_vld_tp2_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_data_vld_tp2_offset),
            scout   => sov_1(reld_data_vld_tp2_offset),
            din     => reld_data_vld_tp2_d,
            dout    => reld_data_vld_tp2_q);
reld_data_tp2_latch: tri_rlmreg_p
  generic map (width => reld_data_tp2_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_data_tp2_offset to reld_data_tp2_offset+reld_data_tp2_q'length-1),
            scout   => sov_1(reld_data_tp2_offset to reld_data_tp2_offset+reld_data_tp2_q'length-1),
            din     => reld_data_tp2_d,
            dout    => reld_data_tp2_q  );
reld_ecc_err_tp2_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_ecc_err_tp2_offset),
            scout   => sov_1(reld_ecc_err_tp2_offset),
            din     => reld_ecc_err_tp2_d,
            dout    => reld_ecc_err_tp2_q);
reld_ecc_err_ue_tp2_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(reld_ecc_err_ue_tp2_offset),
            scout   => sov_1(reld_ecc_err_ue_tp2_offset),
            din     => reld_ecc_err_ue_tp2_d,
            dout    => reld_ecc_err_ue_tp2_q);
--  t plus 3 phase
pte0_reld_data_tp3_latch:   tri_rlmreg_p
  generic map (width => pte0_reld_data_tp3_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte0_reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte0_reld_data_tp3_offset   to pte0_reld_data_tp3_offset+pte0_reld_data_tp3_q'length-1),
            scout   => sov_1(pte0_reld_data_tp3_offset   to pte0_reld_data_tp3_offset+pte0_reld_data_tp3_q'length-1),
            din     => pte0_reld_data_tp3_d,
            dout    => pte0_reld_data_tp3_q    );
pte1_reld_data_tp3_latch:   tri_rlmreg_p
  generic map (width => pte1_reld_data_tp3_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => pte1_reld_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(pte1_reld_data_tp3_offset   to pte1_reld_data_tp3_offset+pte1_reld_data_tp3_q'length-1),
            scout   => sov_1(pte1_reld_data_tp3_offset   to pte1_reld_data_tp3_offset+pte1_reld_data_tp3_q'length-1),
            din     => pte1_reld_data_tp3_d,
            dout    => pte1_reld_data_tp3_q    );
htw_tag3_latch: tri_rlmreg_p
  generic map (width => htw_tag3_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(28),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(htw_tag3_offset to htw_tag3_offset+htw_tag3_q'length-1),
            scout   => sov_1(htw_tag3_offset to htw_tag3_offset+htw_tag3_q'length-1),
            din     => htw_tag3_d,
            dout    => htw_tag3_q  );
htw_tag4_clr_resv_latch: tri_rlmreg_p
  generic map (width => htw_tag4_clr_resv_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(28),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(htw_tag4_clr_resv_offset to htw_tag4_clr_resv_offset+htw_tag4_clr_resv_q'length-1),
            scout   => sov_1(htw_tag4_clr_resv_offset to htw_tag4_clr_resv_offset+htw_tag4_clr_resv_q'length-1),
            din     => htw_tag4_clr_resv_d,
            dout    => htw_tag4_clr_resv_q  );
htw_tag5_clr_resv_latch: tri_rlmreg_p
  generic map (width => htw_tag5_clr_resv_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(28),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(htw_tag5_clr_resv_offset to htw_tag5_clr_resv_offset+htw_tag5_clr_resv_q'length-1),
            scout   => sov_1(htw_tag5_clr_resv_offset to htw_tag5_clr_resv_offset+htw_tag5_clr_resv_q'length-1),
            din     => htw_tag5_clr_resv_d,
            dout    => htw_tag5_clr_resv_q  );
spare_b_latch: tri_rlmreg_p
  generic map (width => spare_b_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv_1(spare_b_offset to spare_b_offset+spare_b_q'length-1),
            scout   => sov_1(spare_b_offset to spare_b_offset+spare_b_q'length-1),
            din     => spare_b_q,
            dout    => spare_b_q  );
--------------------------------------------------
-- thold/sg latches
--------------------------------------------------
perv_2to1_reg: tri_plat
  generic map (width => 3, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ccflush_dc,
            din(0)      => pc_func_sl_thold_2,
            din(1)      => pc_func_slp_sl_thold_2,
            din(2)      => pc_sg_2,
            q(0)        => pc_func_sl_thold_1,
            q(1)        => pc_func_slp_sl_thold_1,
            q(2)        => pc_sg_1);
perv_1to0_reg: tri_plat
  generic map (width => 3, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ccflush_dc,
            din(0)      => pc_func_sl_thold_1,
            din(1)      => pc_func_slp_sl_thold_1,
            din(2)      => pc_sg_1,
            q(0)        => pc_func_sl_thold_0,
            q(1)        => pc_func_slp_sl_thold_0,
            q(2)        => pc_sg_0);
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
-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
siv_0(0 TO scan_right_0) <=  sov_0(1 to scan_right_0) & ac_func_scan_in(0);
ac_func_scan_out(0) <=  sov_0(0);
siv_1(0 TO scan_right_1) <=  sov_1(1 to scan_right_1) & ac_func_scan_in(1);
ac_func_scan_out(1) <=  sov_1(0);
END MMQ_HTW;
