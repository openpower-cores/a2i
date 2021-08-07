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
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity mmq_tlb_req is
  generic(thdid_width       : integer := 4;
            state_width        : integer := 4;
            pid_width          : integer := 14;
            pid_width_erat      : integer := 8;
            lpid_width          : integer := 8;
            req_epn_width       : integer := 52;
            rs_data_width       : integer := 64;
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
xu_mm_ccr2_notlb_b   : in     std_ulogic;
mmucr2_act_override  : in     std_ulogic;
pid0           : in std_ulogic_vector(0 to pid_width-1);
pid1           : in std_ulogic_vector(0 to pid_width-1);
pid2           : in std_ulogic_vector(0 to pid_width-1);
pid3           : in std_ulogic_vector(0 to pid_width-1);
lpidr           : in std_ulogic_vector(0 to lpid_width-1);
iu_mm_ierat_req            : in std_ulogic;
iu_mm_ierat_epn            : in std_ulogic_vector(0 to 51);
iu_mm_ierat_thdid          : in std_ulogic_vector(0 to thdid_width-1);
iu_mm_ierat_state          : in std_ulogic_vector(0 to state_width-1);
iu_mm_ierat_tid            : in std_ulogic_vector(0 to pid_width-1);
iu_mm_ierat_flush          : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_derat_req            : in std_ulogic;
xu_mm_derat_epn            : in std_ulogic_vector(64-rs_data_width to 51);
xu_mm_derat_thdid          : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_derat_ttype          : in std_ulogic_vector(0 to 1);
xu_mm_derat_state          : in std_ulogic_vector(0 to state_width-1);
xu_mm_derat_tid            : in std_ulogic_vector(0 to pid_width-1);
xu_mm_derat_lpid           : in std_ulogic_vector(0 to lpid_width-1);
ierat_req0_pid    : out std_ulogic_vector(0 to pid_width-1);
ierat_req0_as     : out std_ulogic;
ierat_req0_gs     : out std_ulogic;
ierat_req0_epn    : out std_ulogic_vector(0 to req_epn_width-1);
ierat_req0_thdid    : out std_ulogic_vector(0 to thdid_width-1);
ierat_req0_valid    : out std_ulogic;
ierat_req0_nonspec    : out std_ulogic;
ierat_req1_pid    : out std_ulogic_vector(0 to pid_width-1);
ierat_req1_as     : out std_ulogic;
ierat_req1_gs     : out std_ulogic;
ierat_req1_epn    : out std_ulogic_vector(0 to req_epn_width-1);
ierat_req1_thdid    : out std_ulogic_vector(0 to thdid_width-1);
ierat_req1_valid    : out std_ulogic;
ierat_req1_nonspec    : out std_ulogic;
ierat_req2_pid    : out std_ulogic_vector(0 to pid_width-1);
ierat_req2_as     : out std_ulogic;
ierat_req2_gs     : out std_ulogic;
ierat_req2_epn    : out std_ulogic_vector(0 to req_epn_width-1);
ierat_req2_thdid    : out std_ulogic_vector(0 to thdid_width-1);
ierat_req2_valid    : out std_ulogic;
ierat_req2_nonspec    : out std_ulogic;
ierat_req3_pid    : out std_ulogic_vector(0 to pid_width-1);
ierat_req3_as     : out std_ulogic;
ierat_req3_gs     : out std_ulogic;
ierat_req3_epn    : out std_ulogic_vector(0 to req_epn_width-1);
ierat_req3_thdid    : out std_ulogic_vector(0 to thdid_width-1);
ierat_req3_valid    : out std_ulogic;
ierat_req3_nonspec    : out std_ulogic;
ierat_iu4_pid    : out  std_ulogic_vector(0 to pid_width-1);
ierat_iu4_gs     : out  std_ulogic;
ierat_iu4_as     : out  std_ulogic;
ierat_iu4_epn    : out  std_ulogic_vector(0 to req_epn_width-1);
ierat_iu4_thdid  : out  std_ulogic_vector(0 to thdid_width-1);
ierat_iu4_valid  : out  std_ulogic;
derat_req0_lpid   : out std_ulogic_vector(0 to lpid_width-1);
derat_req0_pid    : out std_ulogic_vector(0 to pid_width-1);
derat_req0_as     : out std_ulogic;
derat_req0_gs     : out std_ulogic;
derat_req0_epn    : out std_ulogic_vector(0 to req_epn_width-1);
derat_req0_thdid    : out std_ulogic_vector(0 to thdid_width-1);
derat_req0_valid    : out std_ulogic;
derat_req1_lpid   : out std_ulogic_vector(0 to lpid_width-1);
derat_req1_pid    : out std_ulogic_vector(0 to pid_width-1);
derat_req1_as     : out std_ulogic;
derat_req1_gs     : out std_ulogic;
derat_req1_epn    : out std_ulogic_vector(0 to req_epn_width-1);
derat_req1_thdid    : out std_ulogic_vector(0 to thdid_width-1);
derat_req1_valid    : out std_ulogic;
derat_req2_lpid   : out std_ulogic_vector(0 to lpid_width-1);
derat_req2_pid    : out std_ulogic_vector(0 to pid_width-1);
derat_req2_as     : out std_ulogic;
derat_req2_gs     : out std_ulogic;
derat_req2_epn    : out std_ulogic_vector(0 to req_epn_width-1);
derat_req2_thdid    : out std_ulogic_vector(0 to thdid_width-1);
derat_req2_valid    : out std_ulogic;
derat_req3_lpid   : out std_ulogic_vector(0 to lpid_width-1);
derat_req3_pid    : out std_ulogic_vector(0 to pid_width-1);
derat_req3_as     : out std_ulogic;
derat_req3_gs     : out std_ulogic;
derat_req3_epn    : out std_ulogic_vector(0 to req_epn_width-1);
derat_req3_thdid    : out std_ulogic_vector(0 to thdid_width-1);
derat_req3_valid    : out std_ulogic;
derat_ex5_lpid   : out  std_ulogic_vector(0 to lpid_width-1);
derat_ex5_pid    : out  std_ulogic_vector(0 to pid_width-1);
derat_ex5_gs     : out  std_ulogic;
derat_ex5_as     : out  std_ulogic;
derat_ex5_epn    : out  std_ulogic_vector(0 to req_epn_width-1);
derat_ex5_thdid  : out  std_ulogic_vector(0 to thdid_width-1);
derat_ex5_valid  : out  std_ulogic;
xu_ex3_flush               : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ex4_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ex5_flush            : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ierat_miss        : in std_ulogic_vector(0 to thdid_width-1);
xu_mm_ierat_flush       : in std_ulogic_vector(0 to thdid_width-1);
mm_xu_eratmiss_done : in std_ulogic_vector(0 to thdid_width-1);
mm_xu_tlb_miss      : in std_ulogic_vector(0 to thdid_width-1);
tlb_cmp_ierat_dup_val  : in std_ulogic_vector(0 to 6);
tlb_cmp_derat_dup_val  : in std_ulogic_vector(0 to 6);
tlb_seq_ierat_req          : out std_ulogic;
tlb_seq_derat_req          : out std_ulogic;
tlb_seq_ierat_done        : in std_ulogic;
tlb_seq_derat_done        : in std_ulogic;
ierat_req_taken       : in std_ulogic;
derat_req_taken       : in std_ulogic;
ierat_req_epn   : out std_ulogic_vector(0 to req_epn_width-1);
ierat_req_pid   : out std_ulogic_vector(0 to pid_width-1);
ierat_req_state : out std_ulogic_vector(0 to state_width-1);
ierat_req_thdid : out std_ulogic_vector(0 to thdid_width-1);
ierat_req_dup   : out std_ulogic_vector(0 to 1);
derat_req_epn   : out std_ulogic_vector(0 to req_epn_width-1);
derat_req_pid   : out std_ulogic_vector(0 to pid_width-1);
derat_req_lpid  : out std_ulogic_vector(0 to lpid_width-1);
derat_req_state : out std_ulogic_vector(0 to state_width-1);
derat_req_ttype : out std_ulogic_vector(0 to 1);
derat_req_thdid : out std_ulogic_vector(0 to thdid_width-1);
derat_req_dup   : out std_ulogic_vector(0 to 1);
tlb_req_quiesce     : out std_ulogic_vector(0 to thdid_width-1);
tlb_req_dbg_ierat_iu5_valid_q    : out  std_ulogic;
tlb_req_dbg_ierat_iu5_thdid      : out  std_ulogic_vector(0 to 1);
tlb_req_dbg_ierat_iu5_state_q    : out  std_ulogic_vector(0 to 3);
tlb_req_dbg_ierat_inptr_q        : out  std_ulogic_vector(0 to 1);
tlb_req_dbg_ierat_outptr_q       : out  std_ulogic_vector(0 to 1);
tlb_req_dbg_ierat_req_valid_q    : out  std_ulogic_vector(0 to 3);
tlb_req_dbg_ierat_req_nonspec_q  : out  std_ulogic_vector(0 to 3);
tlb_req_dbg_ierat_req_thdid      : out  std_ulogic_vector(0 to 7);
tlb_req_dbg_ierat_req_dup_q      : out  std_ulogic_vector(0 to 3);
tlb_req_dbg_derat_ex6_valid_q    : out  std_ulogic;
tlb_req_dbg_derat_ex6_thdid      : out  std_ulogic_vector(0 to 1);
tlb_req_dbg_derat_ex6_state_q    : out  std_ulogic_vector(0 to 3);
tlb_req_dbg_derat_inptr_q        : out  std_ulogic_vector(0 to 1);
tlb_req_dbg_derat_outptr_q       : out  std_ulogic_vector(0 to 1);
tlb_req_dbg_derat_req_valid_q    : out  std_ulogic_vector(0 to 3);
tlb_req_dbg_derat_req_thdid      : out  std_ulogic_vector(0 to 7);
tlb_req_dbg_derat_req_ttype_q    : out  std_ulogic_vector(0 to 7);
tlb_req_dbg_derat_req_dup_q      : out  std_ulogic_vector(0 to 3)

);
end mmq_tlb_req;
architecture mmq_tlb_req of mmq_tlb_req is
constant MMU_Mode_Value : std_ulogic := '0';
constant TlbSel_Tlb : std_ulogic_vector(0 to 1) := "00";
constant TlbSel_IErat : std_ulogic_vector(0 to 1) := "10";
constant TlbSel_DErat : std_ulogic_vector(0 to 1) := "11";
constant ierat_req0_valid_offset   : natural := 0;
constant ierat_req0_nonspec_offset : natural := ierat_req0_valid_offset + 1;
constant ierat_req0_thdid_offset   : natural := ierat_req0_nonspec_offset + 1;
constant ierat_req0_epn_offset     : natural := ierat_req0_thdid_offset + thdid_width;
constant ierat_req0_state_offset   : natural := ierat_req0_epn_offset + req_epn_width;
constant ierat_req0_pid_offset     : natural := ierat_req0_state_offset + state_width;
constant ierat_req0_dup_offset     : natural := ierat_req0_pid_offset + pid_width;
constant ierat_req1_valid_offset   : natural := ierat_req0_dup_offset + 2;
constant ierat_req1_nonspec_offset : natural := ierat_req1_valid_offset + 1;
constant ierat_req1_thdid_offset   : natural := ierat_req1_nonspec_offset + 1;
constant ierat_req1_epn_offset     : natural := ierat_req1_thdid_offset + thdid_width;
constant ierat_req1_state_offset   : natural := ierat_req1_epn_offset + req_epn_width;
constant ierat_req1_pid_offset     : natural := ierat_req1_state_offset + state_width;
constant ierat_req1_dup_offset     : natural := ierat_req1_pid_offset + pid_width;
constant ierat_req2_valid_offset   : natural := ierat_req1_dup_offset + 2;
constant ierat_req2_nonspec_offset : natural := ierat_req2_valid_offset + 1;
constant ierat_req2_thdid_offset   : natural := ierat_req2_nonspec_offset + 1;
constant ierat_req2_epn_offset     : natural := ierat_req2_thdid_offset + thdid_width;
constant ierat_req2_state_offset   : natural := ierat_req2_epn_offset + req_epn_width;
constant ierat_req2_pid_offset     : natural := ierat_req2_state_offset + state_width;
constant ierat_req2_dup_offset     : natural := ierat_req2_pid_offset + pid_width;
constant ierat_req3_valid_offset   : natural := ierat_req2_dup_offset + 2;
constant ierat_req3_nonspec_offset : natural := ierat_req3_valid_offset + 1;
constant ierat_req3_thdid_offset   : natural := ierat_req3_nonspec_offset + 1;
constant ierat_req3_epn_offset     : natural := ierat_req3_thdid_offset + thdid_width;
constant ierat_req3_state_offset   : natural := ierat_req3_epn_offset + req_epn_width;
constant ierat_req3_pid_offset     : natural := ierat_req3_state_offset + state_width;
constant ierat_req3_dup_offset     : natural := ierat_req3_pid_offset + pid_width;
constant ierat_inptr_offset     : natural := ierat_req3_dup_offset + 2;
constant ierat_outptr_offset    : natural := ierat_inptr_offset + 2;
constant tlb_seq_ierat_req_offset   : natural := ierat_outptr_offset + 2;
constant ierat_iu3_flush_offset     : natural := tlb_seq_ierat_req_offset + 1;
constant xu_mm_ierat_flush_offset   : natural := ierat_iu3_flush_offset + thdid_width;
constant xu_mm_ierat_miss_offset    : natural := xu_mm_ierat_flush_offset + thdid_width;
constant ierat_iu3_valid_offset  : natural := xu_mm_ierat_miss_offset + thdid_width;
constant ierat_iu3_thdid_offset  : natural := ierat_iu3_valid_offset + 1;
constant ierat_iu3_epn_offset    : natural := ierat_iu3_thdid_offset + thdid_width;
constant ierat_iu3_state_offset  : natural := ierat_iu3_epn_offset + req_epn_width;
constant ierat_iu3_pid_offset    : natural := ierat_iu3_state_offset + state_width;
constant ierat_iu4_valid_offset  : natural := ierat_iu3_pid_offset + pid_width;
constant ierat_iu4_thdid_offset  : natural := ierat_iu4_valid_offset + 1;
constant ierat_iu4_epn_offset    : natural := ierat_iu4_thdid_offset + thdid_width;
constant ierat_iu4_state_offset  : natural := ierat_iu4_epn_offset + req_epn_width;
constant ierat_iu4_pid_offset    : natural := ierat_iu4_state_offset + state_width;
constant ierat_iu5_valid_offset  : natural := ierat_iu4_pid_offset + pid_width;
constant ierat_iu5_thdid_offset  : natural := ierat_iu5_valid_offset + 1;
constant ierat_iu5_epn_offset    : natural := ierat_iu5_thdid_offset + thdid_width;
constant ierat_iu5_state_offset  : natural := ierat_iu5_epn_offset + req_epn_width;
constant ierat_iu5_pid_offset    : natural := ierat_iu5_state_offset + state_width;
constant derat_req0_valid_offset  : natural := ierat_iu5_pid_offset + pid_width;
constant derat_req0_thdid_offset  : natural := derat_req0_valid_offset + 1;
constant derat_req0_epn_offset    : natural := derat_req0_thdid_offset + thdid_width;
constant derat_req0_state_offset  : natural := derat_req0_epn_offset + req_epn_width;
constant derat_req0_ttype_offset  : natural := derat_req0_state_offset + state_width;
constant derat_req0_pid_offset    : natural := derat_req0_ttype_offset + 2;
constant derat_req0_lpid_offset   : natural := derat_req0_pid_offset + pid_width;
constant derat_req0_dup_offset    : natural := derat_req0_lpid_offset + lpid_width;
constant derat_req1_valid_offset  : natural := derat_req0_dup_offset + 2;
constant derat_req1_thdid_offset  : natural := derat_req1_valid_offset + 1;
constant derat_req1_epn_offset    : natural := derat_req1_thdid_offset + thdid_width;
constant derat_req1_state_offset  : natural := derat_req1_epn_offset + req_epn_width;
constant derat_req1_ttype_offset  : natural := derat_req1_state_offset + state_width;
constant derat_req1_pid_offset    : natural := derat_req1_ttype_offset + 2;
constant derat_req1_lpid_offset   : natural := derat_req1_pid_offset + pid_width;
constant derat_req1_dup_offset    : natural := derat_req1_lpid_offset + lpid_width;
constant derat_req2_valid_offset  : natural := derat_req1_dup_offset + 2;
constant derat_req2_thdid_offset  : natural := derat_req2_valid_offset + 1;
constant derat_req2_epn_offset    : natural := derat_req2_thdid_offset + thdid_width;
constant derat_req2_state_offset  : natural := derat_req2_epn_offset + req_epn_width;
constant derat_req2_ttype_offset  : natural := derat_req2_state_offset + state_width;
constant derat_req2_pid_offset    : natural := derat_req2_ttype_offset + 2;
constant derat_req2_lpid_offset   : natural := derat_req2_pid_offset + pid_width;
constant derat_req2_dup_offset    : natural := derat_req2_lpid_offset + lpid_width;
constant derat_req3_valid_offset  : natural := derat_req2_dup_offset + 2;
constant derat_req3_thdid_offset  : natural := derat_req3_valid_offset + 1;
constant derat_req3_epn_offset    : natural := derat_req3_thdid_offset + thdid_width;
constant derat_req3_state_offset  : natural := derat_req3_epn_offset + req_epn_width;
constant derat_req3_ttype_offset  : natural := derat_req3_state_offset + state_width;
constant derat_req3_pid_offset    : natural := derat_req3_ttype_offset + 2;
constant derat_req3_lpid_offset   : natural := derat_req3_pid_offset + pid_width;
constant derat_req3_dup_offset    : natural := derat_req3_lpid_offset + lpid_width;
constant derat_inptr_offset    : natural := derat_req3_dup_offset + 2;
constant derat_outptr_offset   : natural := derat_inptr_offset + 2;
constant tlb_seq_derat_req_offset   : natural := derat_outptr_offset + 2;
constant derat_ex4_valid_offset  : natural := tlb_seq_derat_req_offset + 1;
constant derat_ex4_thdid_offset  : natural := derat_ex4_valid_offset + 1;
constant derat_ex4_epn_offset    : natural := derat_ex4_thdid_offset + thdid_width;
constant derat_ex4_state_offset  : natural := derat_ex4_epn_offset + req_epn_width;
constant derat_ex4_ttype_offset  : natural := derat_ex4_state_offset + state_width;
constant derat_ex4_pid_offset    : natural := derat_ex4_ttype_offset + 2;
constant derat_ex4_lpid_offset   : natural := derat_ex4_pid_offset + pid_width;
constant derat_ex5_valid_offset  : natural := derat_ex4_lpid_offset + lpid_width;
constant derat_ex5_thdid_offset  : natural := derat_ex5_valid_offset + 1;
constant derat_ex5_epn_offset    : natural := derat_ex5_thdid_offset + thdid_width;
constant derat_ex5_state_offset  : natural := derat_ex5_epn_offset + req_epn_width;
constant derat_ex5_ttype_offset  : natural := derat_ex5_state_offset + state_width;
constant derat_ex5_pid_offset    : natural := derat_ex5_ttype_offset + 2;
constant derat_ex5_lpid_offset   : natural := derat_ex5_pid_offset + pid_width;
constant derat_ex6_valid_offset  : natural := derat_ex5_lpid_offset + lpid_width;
constant derat_ex6_thdid_offset  : natural := derat_ex6_valid_offset + 1;
constant derat_ex6_epn_offset    : natural := derat_ex6_thdid_offset + thdid_width;
constant derat_ex6_state_offset  : natural := derat_ex6_epn_offset + req_epn_width;
constant derat_ex6_ttype_offset  : natural := derat_ex6_state_offset + state_width;
constant derat_ex6_pid_offset    : natural := derat_ex6_ttype_offset + 2;
constant derat_ex6_lpid_offset   : natural := derat_ex6_pid_offset + pid_width;
constant spare_offset               : natural := derat_ex6_lpid_offset + lpid_width;
constant scan_right                 : natural := spare_offset + 32 -1;
signal ierat_req0_valid_d,   ierat_req0_valid_q          : std_ulogic;
signal ierat_req0_nonspec_d,   ierat_req0_nonspec_q      : std_ulogic;
signal ierat_req0_thdid_d,   ierat_req0_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal ierat_req0_epn_d,   ierat_req0_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal ierat_req0_state_d,   ierat_req0_state_q      : std_ulogic_vector(0 to state_width-1);
signal ierat_req0_pid_d,   ierat_req0_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal ierat_req0_dup_d,   ierat_req0_dup_q          : std_ulogic_vector(0 to 1);
signal ierat_req1_valid_d,   ierat_req1_valid_q          : std_ulogic;
signal ierat_req1_nonspec_d,   ierat_req1_nonspec_q      : std_ulogic;
signal ierat_req1_thdid_d,   ierat_req1_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal ierat_req1_epn_d,   ierat_req1_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal ierat_req1_state_d,   ierat_req1_state_q      : std_ulogic_vector(0 to state_width-1);
signal ierat_req1_pid_d,   ierat_req1_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal ierat_req1_dup_d,   ierat_req1_dup_q          : std_ulogic_vector(0 to 1);
signal ierat_req2_valid_d,   ierat_req2_valid_q          : std_ulogic;
signal ierat_req2_nonspec_d,   ierat_req2_nonspec_q      : std_ulogic;
signal ierat_req2_thdid_d,   ierat_req2_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal ierat_req2_epn_d,   ierat_req2_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal ierat_req2_state_d,   ierat_req2_state_q      : std_ulogic_vector(0 to state_width-1);
signal ierat_req2_pid_d,   ierat_req2_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal ierat_req2_dup_d,   ierat_req2_dup_q          : std_ulogic_vector(0 to 1);
signal ierat_req3_valid_d,   ierat_req3_valid_q          : std_ulogic;
signal ierat_req3_nonspec_d,   ierat_req3_nonspec_q      : std_ulogic;
signal ierat_req3_thdid_d,   ierat_req3_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal ierat_req3_epn_d,   ierat_req3_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal ierat_req3_state_d,   ierat_req3_state_q      : std_ulogic_vector(0 to state_width-1);
signal ierat_req3_pid_d,   ierat_req3_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal ierat_req3_dup_d,   ierat_req3_dup_q          : std_ulogic_vector(0 to 1);
signal ierat_iu3_valid_d,   ierat_iu3_valid_q      : std_ulogic;
signal ierat_iu3_thdid_d,   ierat_iu3_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal ierat_iu3_epn_d,   ierat_iu3_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal ierat_iu3_state_d,   ierat_iu3_state_q      : std_ulogic_vector(0 to state_width-1);
signal ierat_iu3_pid_d,   ierat_iu3_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal ierat_iu4_valid_d,   ierat_iu4_valid_q      : std_ulogic;
signal ierat_iu4_thdid_d,   ierat_iu4_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal ierat_iu4_epn_d,   ierat_iu4_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal ierat_iu4_state_d,   ierat_iu4_state_q      : std_ulogic_vector(0 to state_width-1);
signal ierat_iu4_pid_d,   ierat_iu4_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal ierat_iu5_valid_d,   ierat_iu5_valid_q      : std_ulogic;
signal ierat_iu5_thdid_d,   ierat_iu5_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal ierat_iu5_epn_d,   ierat_iu5_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal ierat_iu5_state_d,   ierat_iu5_state_q      : std_ulogic_vector(0 to state_width-1);
signal ierat_iu5_pid_d,   ierat_iu5_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal ierat_iu3_flush_d, ierat_iu3_flush_q    : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_ierat_flush_d, xu_mm_ierat_flush_q          : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_ierat_miss_d, xu_mm_ierat_miss_q          : std_ulogic_vector(0 to thdid_width-1);
signal ierat_inptr_d, ierat_inptr_q    : std_ulogic_vector(0 to 1);
signal ierat_outptr_d, ierat_outptr_q    : std_ulogic_vector(0 to 1);
signal tlb_seq_ierat_req_d, tlb_seq_ierat_req_q  : std_ulogic;
signal derat_req0_valid_d,   derat_req0_valid_q      : std_ulogic;
signal derat_req0_thdid_d,   derat_req0_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal derat_req0_epn_d,   derat_req0_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal derat_req0_state_d,   derat_req0_state_q      : std_ulogic_vector(0 to state_width-1);
signal derat_req0_ttype_d,   derat_req0_ttype_q      : std_ulogic_vector(0 to 1);
signal derat_req0_pid_d,   derat_req0_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal derat_req0_lpid_d,   derat_req0_lpid_q        : std_ulogic_vector(0 to lpid_width-1);
signal derat_req0_dup_d,   derat_req0_dup_q          : std_ulogic_vector(0 to 1);
signal derat_req1_valid_d,   derat_req1_valid_q      : std_ulogic;
signal derat_req1_thdid_d,   derat_req1_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal derat_req1_epn_d,   derat_req1_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal derat_req1_state_d,   derat_req1_state_q      : std_ulogic_vector(0 to state_width-1);
signal derat_req1_ttype_d,   derat_req1_ttype_q      : std_ulogic_vector(0 to 1);
signal derat_req1_pid_d,   derat_req1_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal derat_req1_lpid_d,   derat_req1_lpid_q        : std_ulogic_vector(0 to lpid_width-1);
signal derat_req1_dup_d,   derat_req1_dup_q          : std_ulogic_vector(0 to 1);
signal derat_req2_valid_d,   derat_req2_valid_q      : std_ulogic;
signal derat_req2_thdid_d,   derat_req2_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal derat_req2_epn_d,   derat_req2_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal derat_req2_state_d,   derat_req2_state_q      : std_ulogic_vector(0 to state_width-1);
signal derat_req2_ttype_d,   derat_req2_ttype_q      : std_ulogic_vector(0 to 1);
signal derat_req2_pid_d,   derat_req2_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal derat_req2_lpid_d,   derat_req2_lpid_q        : std_ulogic_vector(0 to lpid_width-1);
signal derat_req2_dup_d,   derat_req2_dup_q          : std_ulogic_vector(0 to 1);
signal derat_req3_valid_d,   derat_req3_valid_q      : std_ulogic;
signal derat_req3_thdid_d,   derat_req3_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal derat_req3_epn_d,   derat_req3_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal derat_req3_state_d,   derat_req3_state_q      : std_ulogic_vector(0 to state_width-1);
signal derat_req3_ttype_d,   derat_req3_ttype_q      : std_ulogic_vector(0 to 1);
signal derat_req3_pid_d,   derat_req3_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal derat_req3_lpid_d,   derat_req3_lpid_q        : std_ulogic_vector(0 to lpid_width-1);
signal derat_req3_dup_d,   derat_req3_dup_q          : std_ulogic_vector(0 to 1);
signal derat_ex4_valid_d,   derat_ex4_valid_q      : std_ulogic;
signal derat_ex4_thdid_d,   derat_ex4_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal derat_ex4_epn_d,   derat_ex4_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal derat_ex4_state_d,   derat_ex4_state_q      : std_ulogic_vector(0 to state_width-1);
signal derat_ex4_ttype_d,   derat_ex4_ttype_q      : std_ulogic_vector(0 to 1);
signal derat_ex4_pid_d,   derat_ex4_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal derat_ex4_lpid_d,   derat_ex4_lpid_q          : std_ulogic_vector(0 to lpid_width-1);
signal derat_ex5_valid_d,   derat_ex5_valid_q      : std_ulogic;
signal derat_ex5_thdid_d,   derat_ex5_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal derat_ex5_epn_d,   derat_ex5_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal derat_ex5_state_d,   derat_ex5_state_q      : std_ulogic_vector(0 to state_width-1);
signal derat_ex5_ttype_d,   derat_ex5_ttype_q      : std_ulogic_vector(0 to 1);
signal derat_ex5_pid_d,   derat_ex5_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal derat_ex5_lpid_d,   derat_ex5_lpid_q          : std_ulogic_vector(0 to lpid_width-1);
signal derat_ex6_valid_d,   derat_ex6_valid_q      : std_ulogic;
signal derat_ex6_thdid_d,   derat_ex6_thdid_q      : std_ulogic_vector(0 to thdid_width-1);
signal derat_ex6_epn_d,   derat_ex6_epn_q          : std_ulogic_vector(0 to req_epn_width-1);
signal derat_ex6_state_d,   derat_ex6_state_q      : std_ulogic_vector(0 to state_width-1);
signal derat_ex6_ttype_d,   derat_ex6_ttype_q      : std_ulogic_vector(0 to 1);
signal derat_ex6_pid_d,   derat_ex6_pid_q          : std_ulogic_vector(0 to pid_width-1);
signal derat_ex6_lpid_d,   derat_ex6_lpid_q          : std_ulogic_vector(0 to lpid_width-1);
signal derat_inptr_d, derat_inptr_q    : std_ulogic_vector(0 to 1);
signal derat_outptr_d, derat_outptr_q    : std_ulogic_vector(0 to 1);
signal tlb_seq_derat_req_d, tlb_seq_derat_req_q  : std_ulogic;
signal spare_q    : std_ulogic_vector(0 to 31);
signal ierat_req_pid_mux : std_ulogic_vector(0 to pid_width-1);
signal tlb_req_quiesce_b : std_ulogic_vector(0 to thdid_width-1);
signal unused_dc  :  std_ulogic_vector(0 to 12);
-- synopsys translate_off
-- synopsys translate_on
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
signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);
begin
tlb_req_quiesce_b(0 to thdid_width-1) <=
 ( (0 to thdid_width-1 => ierat_req0_valid_q)   and ierat_req0_thdid_q(0   to thdid_width-1) ) or
 ( (0 to thdid_width-1 => ierat_req1_valid_q)   and ierat_req1_thdid_q(0   to thdid_width-1) ) or
 ( (0 to thdid_width-1 => ierat_req2_valid_q)   and ierat_req2_thdid_q(0   to thdid_width-1) ) or
 ( (0 to thdid_width-1 => ierat_req3_valid_q)   and ierat_req3_thdid_q(0   to thdid_width-1) ) or
 ( (0 to thdid_width-1 => derat_req0_valid_q)   and derat_req0_thdid_q(0   to thdid_width-1) ) or
 ( (0 to thdid_width-1 => derat_req1_valid_q)   and derat_req1_thdid_q(0   to thdid_width-1) ) or
 ( (0 to thdid_width-1 => derat_req2_valid_q)   and derat_req2_thdid_q(0   to thdid_width-1) ) or
 ( (0 to thdid_width-1 => derat_req3_valid_q)   and derat_req3_thdid_q(0   to thdid_width-1) ) or
 ( (0 to thdid_width-1 => derat_ex4_valid_q)   and derat_ex4_thdid_q(0   to thdid_width-1) ) or 
 ( (0 to thdid_width-1 => derat_ex5_valid_q)   and derat_ex5_thdid_q(0   to thdid_width-1) ) or 
 ( (0 to thdid_width-1 => derat_ex6_valid_q)   and derat_ex6_thdid_q(0   to thdid_width-1) ) or 
 ( (0 to thdid_width-1 => ierat_iu3_valid_q)   and ierat_iu3_thdid_q(0   to thdid_width-1) ) or 
 ( (0 to thdid_width-1 => ierat_iu4_valid_q)   and ierat_iu4_thdid_q(0   to thdid_width-1) ) or 
 ( (0 to thdid_width-1 => ierat_iu5_valid_q) and ierat_iu5_thdid_q(0 to thdid_width-1) );
tlb_req_quiesce <= not tlb_req_quiesce_b;
xu_mm_ierat_flush_d <= xu_mm_ierat_flush;
xu_mm_ierat_miss_d  <= xu_mm_ierat_miss;
ierat_iu3_flush_d <=  iu_mm_ierat_flush;
ierat_iu3_valid_d <=  iu_mm_ierat_req;
ierat_iu4_valid_d <=  '1' when (ierat_iu3_valid_q='1' and or_reduce(ierat_iu3_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1')
                   else '0';
ierat_iu5_valid_d <=  '1' when (ierat_iu4_valid_q='1' and or_reduce(ierat_iu4_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1')
                   else '0';
ierat_iu3_thdid_d <= iu_mm_ierat_thdid;
ierat_iu3_state_d <= iu_mm_ierat_state;
ierat_iu3_pid_d <= iu_mm_ierat_tid;
gen64_iu3_epn: if rs_data_width = 64 generate
ierat_iu3_epn_d <= iu_mm_ierat_epn;
end generate gen64_iu3_epn;
gen32_iu3_epn: if rs_data_width < 64 generate
ierat_iu3_epn_d <= (0 to 64-rs_data_width-1 => '0') & iu_mm_ierat_epn(64-rs_data_width to 51);
end generate gen32_iu3_epn;
ierat_iu4_thdid_d   <= ierat_iu3_thdid_q;
ierat_iu4_epn_d   <= ierat_iu3_epn_q;
ierat_iu4_state_d   <= ierat_iu3_state_q;
ierat_iu4_pid_d   <= ierat_iu3_pid_q;
ierat_iu5_thdid_d   <= ierat_iu4_thdid_q;
ierat_iu5_epn_d   <= ierat_iu4_epn_q;
ierat_iu5_state_d   <= ierat_iu4_state_q;
ierat_iu5_pid_d   <= ierat_iu4_pid_q;
ierat_inptr_d <= "00" when ierat_req0_valid_q='1' and ierat_req0_nonspec_q='0' and or_reduce(ierat_req0_thdid_q and (ierat_iu3_flush_q or xu_mm_ierat_flush_q))='1'
              else "01" when ierat_req1_valid_q='1' and ierat_req1_nonspec_q='0' and or_reduce(ierat_req1_thdid_q and (ierat_iu3_flush_q or xu_mm_ierat_flush_q))='1'
              else "10" when ierat_req2_valid_q='1' and ierat_req2_nonspec_q='0' and or_reduce(ierat_req2_thdid_q and (ierat_iu3_flush_q or xu_mm_ierat_flush_q))='1'
              else "11" when ierat_req3_valid_q='1' and ierat_req3_nonspec_q='0' and or_reduce(ierat_req3_thdid_q and (ierat_iu3_flush_q or xu_mm_ierat_flush_q))='1'
              else "01" when ierat_inptr_q="00" and ierat_req1_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "10" when ierat_inptr_q="00" and ierat_req2_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "11" when ierat_inptr_q="00" and ierat_req3_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "10" when ierat_inptr_q="01" and ierat_req2_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "11" when ierat_inptr_q="01" and ierat_req3_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "00" when ierat_inptr_q="01" and ierat_req0_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "11" when ierat_inptr_q="10" and ierat_req3_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "00" when ierat_inptr_q="10" and ierat_req0_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "01" when ierat_inptr_q="10" and ierat_req1_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "00" when ierat_inptr_q="11" and ierat_req0_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "01" when ierat_inptr_q="11" and ierat_req1_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else "10" when ierat_inptr_q="11" and ierat_req2_valid_q='0' and ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
              else ierat_outptr_q when ierat_req_taken='1' 
              else ierat_inptr_q;
ierat_outptr_d <= "01" when ierat_outptr_q="00" and ierat_req0_valid_q='1' and ierat_req_taken='1'
              else "10" when ierat_outptr_q="01" and ierat_req1_valid_q='1' and ierat_req_taken='1'
              else "11" when ierat_outptr_q="10" and ierat_req2_valid_q='1' and ierat_req_taken='1'
              else "00" when ierat_outptr_q="11" and ierat_req3_valid_q='1' and ierat_req_taken='1'
              else "01" when ierat_outptr_q="00" and ierat_req0_valid_q='0' and ierat_req1_valid_q='1'
              else "10" when ierat_outptr_q="00" and ierat_req0_valid_q='0' and ierat_req1_valid_q='0' and ierat_req2_valid_q='1'
              else "11" when ierat_outptr_q="00" and ierat_req0_valid_q='0' and ierat_req1_valid_q='0' and ierat_req2_valid_q='0' and ierat_req3_valid_q='1'
              else "10" when ierat_outptr_q="01" and ierat_req1_valid_q='0' and ierat_req2_valid_q='1'
              else "11" when ierat_outptr_q="01" and ierat_req1_valid_q='0' and ierat_req2_valid_q='0' and ierat_req3_valid_q='1'
              else "00" when ierat_outptr_q="01" and ierat_req1_valid_q='0' and ierat_req2_valid_q='0' and ierat_req3_valid_q='0' and ierat_req0_valid_q='1'
              else "11" when ierat_outptr_q="10" and ierat_req2_valid_q='0' and ierat_req3_valid_q='1'
              else "00" when ierat_outptr_q="10" and ierat_req2_valid_q='0' and ierat_req3_valid_q='0' and ierat_req0_valid_q='1'
              else "01" when ierat_outptr_q="10" and ierat_req2_valid_q='0' and ierat_req3_valid_q='0' and ierat_req0_valid_q='0' and ierat_req1_valid_q='1'
              else "00" when ierat_outptr_q="11" and ierat_req3_valid_q='0' and ierat_req0_valid_q='1'
              else "01" when ierat_outptr_q="11" and ierat_req3_valid_q='0' and ierat_req0_valid_q='0' and ierat_req1_valid_q='1'
              else "10" when ierat_outptr_q="11" and ierat_req3_valid_q='0' and ierat_req0_valid_q='0' and ierat_req1_valid_q='0' and ierat_req2_valid_q='1'
              else ierat_outptr_q;
tlb_seq_ierat_req_d <= '1' when ((ierat_outptr_q="00" and ierat_req0_valid_q='1' and ierat_req0_nonspec_q='1' and or_reduce(ierat_req0_thdid_q and  not(xu_mm_ierat_flush_q))='1') or
              (ierat_outptr_q="01" and ierat_req1_valid_q='1' and ierat_req1_nonspec_q='1' and or_reduce(ierat_req1_thdid_q and  not(xu_mm_ierat_flush_q))='1') or
              (ierat_outptr_q="10" and ierat_req2_valid_q='1' and ierat_req2_nonspec_q='1' and or_reduce(ierat_req2_thdid_q and  not(xu_mm_ierat_flush_q))='1') or
              (ierat_outptr_q="11" and ierat_req3_valid_q='1' and ierat_req3_nonspec_q='1' and or_reduce(ierat_req3_thdid_q and  not(xu_mm_ierat_flush_q))='1'))
              else '0';
tlb_seq_ierat_req <= tlb_seq_ierat_req_q;
ierat_req0_valid_d   <= '1' when (ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
                                        and ierat_req0_valid_q='0'   and ierat_inptr_q="00")
                   else '0' when (ierat_req0_valid_q='1'   and ierat_req0_nonspec_q='0'   and or_reduce(ierat_req0_thdid_q   and xu_mm_ierat_flush_q)='1')
                   else '0' when (ierat_req0_valid_q='1'   and ierat_req0_nonspec_q='0'   and or_reduce(ierat_req0_thdid_q   and ierat_iu3_flush_q)='1')
                   else '0' when (ierat_req_taken='1' and ierat_req0_valid_q='1'   and ierat_req0_nonspec_q='1'   and ierat_outptr_q="00")
                   else '0' when (ierat_req0_nonspec_q='1'   and tlb_cmp_ierat_dup_val(0)='1'   and tlb_cmp_ierat_dup_val(4)='1') 
                   else ierat_req0_valid_q;
ierat_req0_nonspec_d   <= '1' when (ierat_req0_valid_q='1'   and ierat_req0_nonspec_q='0'   
                                        and or_reduce(ierat_req0_thdid_q   and xu_mm_ierat_miss_q and not(xu_mm_ierat_flush_q))='1') 
                   else '0' when (ierat_req0_valid_q='1'   and or_reduce(ierat_req0_thdid_q   and xu_mm_ierat_flush_q)='1')
                   else '0' when (ierat_req_taken='1' and ierat_req0_valid_q='1'   and ierat_req0_nonspec_q='1'   and ierat_outptr_q="00")
                   else '0' when (ierat_req0_nonspec_q='1'   and tlb_cmp_ierat_dup_val(0)='1'   and tlb_cmp_ierat_dup_val(4)='1') 
                   else ierat_req0_nonspec_q;
ierat_req0_thdid_d(0   to 3) <= ierat_iu5_thdid_q when (ierat_iu5_valid_q='1' and ierat_req0_valid_q='0'   and ierat_inptr_q="00")
                   else ierat_req0_thdid_q(0   to 3);
ierat_req0_epn_d   <= ierat_iu5_epn_q when (ierat_iu5_valid_q='1' and ierat_req0_valid_q='0'   and ierat_inptr_q="00")
                   else ierat_req0_epn_q;
ierat_req0_state_d   <= ierat_iu5_state_q when (ierat_iu5_valid_q='1' and ierat_req0_valid_q='0'   and ierat_inptr_q="00")
                   else ierat_req0_state_q;
ierat_req0_pid_d   <= ierat_iu5_pid_q when (ierat_iu5_valid_q='1' and ierat_req0_valid_q='0'   and ierat_inptr_q="00")
                   else ierat_req0_pid_q;
ierat_req0_dup_d(0)   <= '0';
ierat_req0_dup_d(1)   <= '0' when (ierat_req_taken='1' and ierat_req0_valid_q='1'   and ierat_outptr_q="00")
                   else tlb_cmp_ierat_dup_val(6) when (ierat_iu5_valid_q='1' and ierat_req0_valid_q='0'   and ierat_inptr_q="00") 
                   else tlb_cmp_ierat_dup_val(0)   when (ierat_req0_valid_q='1'   and ierat_req0_dup_q(1)='0'   and tlb_cmp_ierat_dup_val(4)='0' and tlb_cmp_ierat_dup_val(5)='1') 
                   else ierat_req0_dup_q(1);
ierat_req1_valid_d   <= '1' when (ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
                                        and ierat_req1_valid_q='0'   and ierat_inptr_q="01")
                   else '0' when (ierat_req1_valid_q='1'   and ierat_req1_nonspec_q='0'   and or_reduce(ierat_req1_thdid_q   and xu_mm_ierat_flush_q)='1')
                   else '0' when (ierat_req1_valid_q='1'   and ierat_req1_nonspec_q='0'   and or_reduce(ierat_req1_thdid_q   and ierat_iu3_flush_q)='1')
                   else '0' when (ierat_req_taken='1' and ierat_req1_valid_q='1'   and ierat_req1_nonspec_q='1'   and ierat_outptr_q="01")
                   else '0' when (ierat_req1_nonspec_q='1'   and tlb_cmp_ierat_dup_val(1)='1'   and tlb_cmp_ierat_dup_val(4)='1') 
                   else ierat_req1_valid_q;
ierat_req1_nonspec_d   <= '1' when (ierat_req1_valid_q='1'   and ierat_req1_nonspec_q='0'   
                                        and or_reduce(ierat_req1_thdid_q   and xu_mm_ierat_miss_q and not(xu_mm_ierat_flush_q))='1') 
                   else '0' when (ierat_req1_valid_q='1'   and or_reduce(ierat_req1_thdid_q   and xu_mm_ierat_flush_q)='1')
                   else '0' when (ierat_req_taken='1' and ierat_req1_valid_q='1'   and ierat_req1_nonspec_q='1'   and ierat_outptr_q="01")
                   else '0' when (ierat_req1_nonspec_q='1'   and tlb_cmp_ierat_dup_val(1)='1'   and tlb_cmp_ierat_dup_val(4)='1') 
                   else ierat_req1_nonspec_q;
ierat_req1_thdid_d(0   to 3) <= ierat_iu5_thdid_q when (ierat_iu5_valid_q='1' and ierat_req1_valid_q='0'   and ierat_inptr_q="01")
                   else ierat_req1_thdid_q(0   to 3);
ierat_req1_epn_d   <= ierat_iu5_epn_q when (ierat_iu5_valid_q='1' and ierat_req1_valid_q='0'   and ierat_inptr_q="01")
                   else ierat_req1_epn_q;
ierat_req1_state_d   <= ierat_iu5_state_q when (ierat_iu5_valid_q='1' and ierat_req1_valid_q='0'   and ierat_inptr_q="01")
                   else ierat_req1_state_q;
ierat_req1_pid_d   <= ierat_iu5_pid_q when (ierat_iu5_valid_q='1' and ierat_req1_valid_q='0'   and ierat_inptr_q="01")
                   else ierat_req1_pid_q;
ierat_req1_dup_d(0)   <= '0';
ierat_req1_dup_d(1)   <= '0' when (ierat_req_taken='1' and ierat_req1_valid_q='1'   and ierat_outptr_q="01")
                   else tlb_cmp_ierat_dup_val(6) when (ierat_iu5_valid_q='1' and ierat_req1_valid_q='0'   and ierat_inptr_q="01") 
                   else tlb_cmp_ierat_dup_val(1)   when (ierat_req1_valid_q='1'   and ierat_req1_dup_q(1)='0'   and tlb_cmp_ierat_dup_val(4)='0' and tlb_cmp_ierat_dup_val(5)='1') 
                   else ierat_req1_dup_q(1);
ierat_req2_valid_d   <= '1' when (ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
                                        and ierat_req2_valid_q='0'   and ierat_inptr_q="10")
                   else '0' when (ierat_req2_valid_q='1'   and ierat_req2_nonspec_q='0'   and or_reduce(ierat_req2_thdid_q   and xu_mm_ierat_flush_q)='1')
                   else '0' when (ierat_req2_valid_q='1'   and ierat_req2_nonspec_q='0'   and or_reduce(ierat_req2_thdid_q   and ierat_iu3_flush_q)='1')
                   else '0' when (ierat_req_taken='1' and ierat_req2_valid_q='1'   and ierat_req2_nonspec_q='1'   and ierat_outptr_q="10")
                   else '0' when (ierat_req2_nonspec_q='1'   and tlb_cmp_ierat_dup_val(2)='1'   and tlb_cmp_ierat_dup_val(4)='1') 
                   else ierat_req2_valid_q;
ierat_req2_nonspec_d   <= '1' when (ierat_req2_valid_q='1'   and ierat_req2_nonspec_q='0'   
                                        and or_reduce(ierat_req2_thdid_q   and xu_mm_ierat_miss_q and not(xu_mm_ierat_flush_q))='1') 
                   else '0' when (ierat_req2_valid_q='1'   and or_reduce(ierat_req2_thdid_q   and xu_mm_ierat_flush_q)='1')
                   else '0' when (ierat_req_taken='1' and ierat_req2_valid_q='1'   and ierat_req2_nonspec_q='1'   and ierat_outptr_q="10")
                   else '0' when (ierat_req2_nonspec_q='1'   and tlb_cmp_ierat_dup_val(2)='1'   and tlb_cmp_ierat_dup_val(4)='1') 
                   else ierat_req2_nonspec_q;
ierat_req2_thdid_d(0   to 3) <= ierat_iu5_thdid_q when (ierat_iu5_valid_q='1' and ierat_req2_valid_q='0'   and ierat_inptr_q="10")
                   else ierat_req2_thdid_q(0   to 3);
ierat_req2_epn_d   <= ierat_iu5_epn_q when (ierat_iu5_valid_q='1' and ierat_req2_valid_q='0'   and ierat_inptr_q="10")
                   else ierat_req2_epn_q;
ierat_req2_state_d   <= ierat_iu5_state_q when (ierat_iu5_valid_q='1' and ierat_req2_valid_q='0'   and ierat_inptr_q="10")
                   else ierat_req2_state_q;
ierat_req2_pid_d   <= ierat_iu5_pid_q when (ierat_iu5_valid_q='1' and ierat_req2_valid_q='0'   and ierat_inptr_q="10")
                   else ierat_req2_pid_q;
ierat_req2_dup_d(0)   <= '0';
ierat_req2_dup_d(1)   <= '0' when (ierat_req_taken='1' and ierat_req2_valid_q='1'   and ierat_outptr_q="10")
                   else tlb_cmp_ierat_dup_val(6) when (ierat_iu5_valid_q='1' and ierat_req2_valid_q='0'   and ierat_inptr_q="10") 
                   else tlb_cmp_ierat_dup_val(2)   when (ierat_req2_valid_q='1'   and ierat_req2_dup_q(1)='0'   and tlb_cmp_ierat_dup_val(4)='0' and tlb_cmp_ierat_dup_val(5)='1') 
                   else ierat_req2_dup_q(1);
ierat_req3_valid_d   <= '1' when (ierat_iu5_valid_q='1' and or_reduce(ierat_iu5_thdid_q and not(ierat_iu3_flush_q) and not(xu_mm_ierat_flush_q))='1'
                                        and ierat_req3_valid_q='0'   and ierat_inptr_q="11")
                   else '0' when (ierat_req3_valid_q='1'   and ierat_req3_nonspec_q='0'   and or_reduce(ierat_req3_thdid_q   and xu_mm_ierat_flush_q)='1')
                   else '0' when (ierat_req3_valid_q='1'   and ierat_req3_nonspec_q='0'   and or_reduce(ierat_req3_thdid_q   and ierat_iu3_flush_q)='1')
                   else '0' when (ierat_req_taken='1' and ierat_req3_valid_q='1'   and ierat_req3_nonspec_q='1'   and ierat_outptr_q="11")
                   else '0' when (ierat_req3_nonspec_q='1'   and tlb_cmp_ierat_dup_val(3)='1'   and tlb_cmp_ierat_dup_val(4)='1') 
                   else ierat_req3_valid_q;
ierat_req3_nonspec_d   <= '1' when (ierat_req3_valid_q='1'   and ierat_req3_nonspec_q='0'   
                                        and or_reduce(ierat_req3_thdid_q   and xu_mm_ierat_miss_q and not(xu_mm_ierat_flush_q))='1') 
                   else '0' when (ierat_req3_valid_q='1'   and or_reduce(ierat_req3_thdid_q   and xu_mm_ierat_flush_q)='1')
                   else '0' when (ierat_req_taken='1' and ierat_req3_valid_q='1'   and ierat_req3_nonspec_q='1'   and ierat_outptr_q="11")
                   else '0' when (ierat_req3_nonspec_q='1'   and tlb_cmp_ierat_dup_val(3)='1'   and tlb_cmp_ierat_dup_val(4)='1') 
                   else ierat_req3_nonspec_q;
ierat_req3_thdid_d(0   to 3) <= ierat_iu5_thdid_q when (ierat_iu5_valid_q='1' and ierat_req3_valid_q='0'   and ierat_inptr_q="11")
                   else ierat_req3_thdid_q(0   to 3);
ierat_req3_epn_d   <= ierat_iu5_epn_q when (ierat_iu5_valid_q='1' and ierat_req3_valid_q='0'   and ierat_inptr_q="11")
                   else ierat_req3_epn_q;
ierat_req3_state_d   <= ierat_iu5_state_q when (ierat_iu5_valid_q='1' and ierat_req3_valid_q='0'   and ierat_inptr_q="11")
                   else ierat_req3_state_q;
ierat_req3_pid_d   <= ierat_iu5_pid_q when (ierat_iu5_valid_q='1' and ierat_req3_valid_q='0'   and ierat_inptr_q="11")
                   else ierat_req3_pid_q;
ierat_req3_dup_d(0)   <= '0';
ierat_req3_dup_d(1)   <= '0' when (ierat_req_taken='1' and ierat_req3_valid_q='1'   and ierat_outptr_q="11")
                   else tlb_cmp_ierat_dup_val(6) when (ierat_iu5_valid_q='1' and ierat_req3_valid_q='0'   and ierat_inptr_q="11") 
                   else tlb_cmp_ierat_dup_val(3)   when (ierat_req3_valid_q='1'   and ierat_req3_dup_q(1)='0'   and tlb_cmp_ierat_dup_val(4)='0' and tlb_cmp_ierat_dup_val(5)='1') 
                   else ierat_req3_dup_q(1);
ierat_req_pid_mux <= pid1 when iu_mm_ierat_thdid(1)='1'
            else pid2 when iu_mm_ierat_thdid(2)='1'
            else pid3 when iu_mm_ierat_thdid(3)='1'
            else pid0;
derat_ex4_valid_d <=  '1' when (xu_mm_derat_req='1' and or_reduce(xu_mm_derat_thdid and not(xu_ex3_flush))='1')
                   else '0';
derat_ex5_valid_d <=  '1' when (derat_ex4_valid_q='1' and or_reduce(derat_ex4_thdid_q and not(xu_mm_ex4_flush))='1')
                   else '0';
derat_ex6_valid_d <=  '1' when (derat_ex5_valid_q='1' and or_reduce(derat_ex5_thdid_q and not(xu_mm_ex5_flush))='1')
                   else '0';
gen64_ex4_epn: if rs_data_width = 64 generate
derat_ex4_epn_d <= xu_mm_derat_epn;
end generate gen64_ex4_epn;
gen32_ex4_epn: if rs_data_width < 64 generate
derat_ex4_epn_d <= (0 to 64-rs_data_width-1 => '0') & xu_mm_derat_epn(64-rs_data_width to 51);
end generate gen32_ex4_epn;
derat_ex4_thdid_d <= xu_mm_derat_thdid;
derat_ex4_state_d <= xu_mm_derat_state;
derat_ex4_ttype_d <= xu_mm_derat_ttype;
derat_ex4_pid_d <= xu_mm_derat_tid;
derat_ex4_lpid_d <= xu_mm_derat_lpid;
derat_ex5_thdid_d   <= derat_ex4_thdid_q;
derat_ex5_epn_d   <= derat_ex4_epn_q;
derat_ex5_state_d   <= derat_ex4_state_q;
derat_ex5_ttype_d   <= derat_ex4_ttype_q;
derat_ex5_pid_d   <= derat_ex4_pid_q;
derat_ex6_thdid_d   <= derat_ex5_thdid_q;
derat_ex6_epn_d   <= derat_ex5_epn_q;
derat_ex6_state_d   <= derat_ex5_state_q;
derat_ex6_ttype_d   <= derat_ex5_ttype_q;
derat_ex6_pid_d   <= derat_ex5_pid_q;
derat_ex5_lpid_d <= derat_ex4_lpid_q when derat_ex4_valid_q='1' and derat_ex4_ttype_q(0)='1' 
               else lpidr;
derat_ex6_lpid_d <= derat_ex5_lpid_q when derat_ex5_valid_q='1' and derat_ex5_ttype_q(0)='1' 
               else lpidr;
derat_inptr_d <=    "01" when derat_inptr_q="00" and derat_req1_valid_q='0' and derat_ex6_valid_q='1'
              else "10" when derat_inptr_q="00" and derat_req2_valid_q='0' and derat_ex6_valid_q='1'
              else "11" when derat_inptr_q="00" and derat_req3_valid_q='0' and derat_ex6_valid_q='1'
              else "10" when derat_inptr_q="01" and derat_req2_valid_q='0' and derat_ex6_valid_q='1'
              else "11" when derat_inptr_q="01" and derat_req3_valid_q='0' and derat_ex6_valid_q='1'
              else "00" when derat_inptr_q="01" and derat_req0_valid_q='0' and derat_ex6_valid_q='1'
              else "11" when derat_inptr_q="10" and derat_req3_valid_q='0' and derat_ex6_valid_q='1'
              else "00" when derat_inptr_q="10" and derat_req0_valid_q='0' and derat_ex6_valid_q='1'
              else "01" when derat_inptr_q="10" and derat_req1_valid_q='0' and derat_ex6_valid_q='1'
              else "00" when derat_inptr_q="11" and derat_req0_valid_q='0' and derat_ex6_valid_q='1'
              else "01" when derat_inptr_q="11" and derat_req1_valid_q='0' and derat_ex6_valid_q='1'
              else "10" when derat_inptr_q="11" and derat_req2_valid_q='0' and derat_ex6_valid_q='1'
              else derat_outptr_q when derat_req_taken='1'  
              else derat_inptr_q;
derat_outptr_d <= "01" when derat_outptr_q="00" and derat_req0_valid_q='1' and derat_req_taken='1'
              else "10" when derat_outptr_q="01" and derat_req1_valid_q='1' and derat_req_taken='1'
              else "11" when derat_outptr_q="10" and derat_req2_valid_q='1' and derat_req_taken='1'
              else "00" when derat_outptr_q="11" and derat_req3_valid_q='1' and derat_req_taken='1'
              else "01" when derat_outptr_q="00" and derat_req0_valid_q='0' and derat_req1_valid_q='1'
              else "10" when derat_outptr_q="00" and derat_req0_valid_q='0' and derat_req1_valid_q='0' and derat_req2_valid_q='1'
              else "11" when derat_outptr_q="00" and derat_req0_valid_q='0' and derat_req1_valid_q='0' and derat_req2_valid_q='0' and derat_req3_valid_q='1'
              else "10" when derat_outptr_q="01" and derat_req1_valid_q='0' and derat_req2_valid_q='1'
              else "11" when derat_outptr_q="01" and derat_req1_valid_q='0' and derat_req2_valid_q='0' and derat_req3_valid_q='1'
              else "00" when derat_outptr_q="01" and derat_req1_valid_q='0' and derat_req2_valid_q='0' and derat_req3_valid_q='0' and derat_req0_valid_q='1'
              else "11" when derat_outptr_q="10" and derat_req2_valid_q='0' and derat_req3_valid_q='1'
              else "00" when derat_outptr_q="10" and derat_req2_valid_q='0' and derat_req3_valid_q='0' and derat_req0_valid_q='1'
              else "01" when derat_outptr_q="10" and derat_req2_valid_q='0' and derat_req3_valid_q='0' and derat_req0_valid_q='0' and derat_req1_valid_q='1'
              else "00" when derat_outptr_q="11" and derat_req3_valid_q='0' and derat_req0_valid_q='1'
              else "01" when derat_outptr_q="11" and derat_req3_valid_q='0' and derat_req0_valid_q='0' and derat_req1_valid_q='1'
              else "10" when derat_outptr_q="11" and derat_req3_valid_q='0' and derat_req0_valid_q='0' and derat_req1_valid_q='0' and derat_req2_valid_q='1'
              else derat_outptr_q;
tlb_seq_derat_req_d <= '1' when ((derat_outptr_q="00" and derat_req0_valid_q='1') or
              (derat_outptr_q="01" and derat_req1_valid_q='1') or
              (derat_outptr_q="10" and derat_req2_valid_q='1') or
              (derat_outptr_q="11" and derat_req3_valid_q='1'))
              else '0';
tlb_seq_derat_req <= tlb_seq_derat_req_q;
derat_req0_valid_d   <=  '1' when (derat_ex6_valid_q='1' and derat_req0_valid_q='0'   and derat_inptr_q="00")
                   else '0' when (derat_req_taken='1' and derat_req0_valid_q='1'   and derat_outptr_q="00")
                   else '0' when (tlb_cmp_derat_dup_val(0)='1'   and tlb_cmp_derat_dup_val(4)='1') 
                   else derat_req0_valid_q;
derat_req0_thdid_d(0   to 3) <= derat_ex6_thdid_q when (derat_ex6_valid_q='1' and derat_req0_valid_q='0'   and derat_inptr_q="00")
                   else derat_req0_thdid_q(0   to 3);
derat_req0_epn_d   <= derat_ex6_epn_q when (derat_ex6_valid_q='1' and derat_req0_valid_q='0'   and derat_inptr_q="00")
                   else derat_req0_epn_q;
derat_req0_state_d   <= derat_ex6_state_q when (derat_ex6_valid_q='1' and derat_req0_valid_q='0'   and derat_inptr_q="00")
                   else derat_req0_state_q;
derat_req0_ttype_d   <= derat_ex6_ttype_q when (derat_ex6_valid_q='1' and derat_req0_valid_q='0'   and derat_inptr_q="00")
                   else derat_req0_ttype_q;
derat_req0_pid_d   <= derat_ex6_pid_q when (derat_ex6_valid_q='1' and derat_req0_valid_q='0'   and derat_inptr_q="00")
                   else derat_req0_pid_q;
derat_req0_lpid_d   <= derat_ex6_lpid_q when (derat_ex6_valid_q='1' and derat_req0_valid_q='0'   and derat_inptr_q="00")
                   else derat_req0_lpid_q;
derat_req0_dup_d(0)   <= '0';
derat_req0_dup_d(1)   <= '0' when (derat_req_taken='1' and derat_req0_valid_q='1'   and derat_outptr_q="00")
                   else tlb_cmp_derat_dup_val(6) when (derat_ex6_valid_q='1' and derat_req0_valid_q='0'   and derat_inptr_q="00") 
                   else tlb_cmp_derat_dup_val(0)   when (derat_req0_valid_q='1'   and derat_req0_dup_q(1)='0'   and tlb_cmp_derat_dup_val(4)='0'  and tlb_cmp_derat_dup_val(5)='1') 
                   else derat_req0_dup_q(1);
derat_req1_valid_d   <=  '1' when (derat_ex6_valid_q='1' and derat_req1_valid_q='0'   and derat_inptr_q="01")
                   else '0' when (derat_req_taken='1' and derat_req1_valid_q='1'   and derat_outptr_q="01")
                   else '0' when (tlb_cmp_derat_dup_val(1)='1'   and tlb_cmp_derat_dup_val(4)='1') 
                   else derat_req1_valid_q;
derat_req1_thdid_d(0   to 3) <= derat_ex6_thdid_q when (derat_ex6_valid_q='1' and derat_req1_valid_q='0'   and derat_inptr_q="01")
                   else derat_req1_thdid_q(0   to 3);
derat_req1_epn_d   <= derat_ex6_epn_q when (derat_ex6_valid_q='1' and derat_req1_valid_q='0'   and derat_inptr_q="01")
                   else derat_req1_epn_q;
derat_req1_state_d   <= derat_ex6_state_q when (derat_ex6_valid_q='1' and derat_req1_valid_q='0'   and derat_inptr_q="01")
                   else derat_req1_state_q;
derat_req1_ttype_d   <= derat_ex6_ttype_q when (derat_ex6_valid_q='1' and derat_req1_valid_q='0'   and derat_inptr_q="01")
                   else derat_req1_ttype_q;
derat_req1_pid_d   <= derat_ex6_pid_q when (derat_ex6_valid_q='1' and derat_req1_valid_q='0'   and derat_inptr_q="01")
                   else derat_req1_pid_q;
derat_req1_lpid_d   <= derat_ex6_lpid_q when (derat_ex6_valid_q='1' and derat_req1_valid_q='0'   and derat_inptr_q="01")
                   else derat_req1_lpid_q;
derat_req1_dup_d(0)   <= '0';
derat_req1_dup_d(1)   <= '0' when (derat_req_taken='1' and derat_req1_valid_q='1'   and derat_outptr_q="01")
                   else tlb_cmp_derat_dup_val(6) when (derat_ex6_valid_q='1' and derat_req1_valid_q='0'   and derat_inptr_q="01") 
                   else tlb_cmp_derat_dup_val(1)   when (derat_req1_valid_q='1'   and derat_req1_dup_q(1)='0'   and tlb_cmp_derat_dup_val(4)='0'  and tlb_cmp_derat_dup_val(5)='1') 
                   else derat_req1_dup_q(1);
derat_req2_valid_d   <=  '1' when (derat_ex6_valid_q='1' and derat_req2_valid_q='0'   and derat_inptr_q="10")
                   else '0' when (derat_req_taken='1' and derat_req2_valid_q='1'   and derat_outptr_q="10")
                   else '0' when (tlb_cmp_derat_dup_val(2)='1'   and tlb_cmp_derat_dup_val(4)='1') 
                   else derat_req2_valid_q;
derat_req2_thdid_d(0   to 3) <= derat_ex6_thdid_q when (derat_ex6_valid_q='1' and derat_req2_valid_q='0'   and derat_inptr_q="10")
                   else derat_req2_thdid_q(0   to 3);
derat_req2_epn_d   <= derat_ex6_epn_q when (derat_ex6_valid_q='1' and derat_req2_valid_q='0'   and derat_inptr_q="10")
                   else derat_req2_epn_q;
derat_req2_state_d   <= derat_ex6_state_q when (derat_ex6_valid_q='1' and derat_req2_valid_q='0'   and derat_inptr_q="10")
                   else derat_req2_state_q;
derat_req2_ttype_d   <= derat_ex6_ttype_q when (derat_ex6_valid_q='1' and derat_req2_valid_q='0'   and derat_inptr_q="10")
                   else derat_req2_ttype_q;
derat_req2_pid_d   <= derat_ex6_pid_q when (derat_ex6_valid_q='1' and derat_req2_valid_q='0'   and derat_inptr_q="10")
                   else derat_req2_pid_q;
derat_req2_lpid_d   <= derat_ex6_lpid_q when (derat_ex6_valid_q='1' and derat_req2_valid_q='0'   and derat_inptr_q="10")
                   else derat_req2_lpid_q;
derat_req2_dup_d(0)   <= '0';
derat_req2_dup_d(1)   <= '0' when (derat_req_taken='1' and derat_req2_valid_q='1'   and derat_outptr_q="10")
                   else tlb_cmp_derat_dup_val(6) when (derat_ex6_valid_q='1' and derat_req2_valid_q='0'   and derat_inptr_q="10") 
                   else tlb_cmp_derat_dup_val(2)   when (derat_req2_valid_q='1'   and derat_req2_dup_q(1)='0'   and tlb_cmp_derat_dup_val(4)='0'  and tlb_cmp_derat_dup_val(5)='1') 
                   else derat_req2_dup_q(1);
derat_req3_valid_d   <=  '1' when (derat_ex6_valid_q='1' and derat_req3_valid_q='0'   and derat_inptr_q="11")
                   else '0' when (derat_req_taken='1' and derat_req3_valid_q='1'   and derat_outptr_q="11")
                   else '0' when (tlb_cmp_derat_dup_val(3)='1'   and tlb_cmp_derat_dup_val(4)='1') 
                   else derat_req3_valid_q;
derat_req3_thdid_d(0   to 3) <= derat_ex6_thdid_q when (derat_ex6_valid_q='1' and derat_req3_valid_q='0'   and derat_inptr_q="11")
                   else derat_req3_thdid_q(0   to 3);
derat_req3_epn_d   <= derat_ex6_epn_q when (derat_ex6_valid_q='1' and derat_req3_valid_q='0'   and derat_inptr_q="11")
                   else derat_req3_epn_q;
derat_req3_state_d   <= derat_ex6_state_q when (derat_ex6_valid_q='1' and derat_req3_valid_q='0'   and derat_inptr_q="11")
                   else derat_req3_state_q;
derat_req3_ttype_d   <= derat_ex6_ttype_q when (derat_ex6_valid_q='1' and derat_req3_valid_q='0'   and derat_inptr_q="11")
                   else derat_req3_ttype_q;
derat_req3_pid_d   <= derat_ex6_pid_q when (derat_ex6_valid_q='1' and derat_req3_valid_q='0'   and derat_inptr_q="11")
                   else derat_req3_pid_q;
derat_req3_lpid_d   <= derat_ex6_lpid_q when (derat_ex6_valid_q='1' and derat_req3_valid_q='0'   and derat_inptr_q="11")
                   else derat_req3_lpid_q;
derat_req3_dup_d(0)   <= '0';
derat_req3_dup_d(1)   <= '0' when (derat_req_taken='1' and derat_req3_valid_q='1'   and derat_outptr_q="11")
                   else tlb_cmp_derat_dup_val(6) when (derat_ex6_valid_q='1' and derat_req3_valid_q='0'   and derat_inptr_q="11") 
                   else tlb_cmp_derat_dup_val(3)   when (derat_req3_valid_q='1'   and derat_req3_dup_q(1)='0'   and tlb_cmp_derat_dup_val(4)='0'  and tlb_cmp_derat_dup_val(5)='1') 
                   else derat_req3_dup_q(1);
ierat_req_epn <= ierat_req1_epn_q when (ierat_outptr_q="01")
            else ierat_req2_epn_q when (ierat_outptr_q="10")
            else ierat_req3_epn_q when (ierat_outptr_q="11")
            else ierat_req0_epn_q;
ierat_req_pid <= ierat_req1_pid_q when (ierat_outptr_q="01")
            else ierat_req2_pid_q when (ierat_outptr_q="10")
            else ierat_req3_pid_q when (ierat_outptr_q="11")
            else ierat_req0_pid_q;
ierat_req_state <= ierat_req1_state_q when (ierat_outptr_q="01")
            else ierat_req2_state_q when (ierat_outptr_q="10")
            else ierat_req3_state_q when (ierat_outptr_q="11")
            else ierat_req0_state_q;
ierat_req_thdid <= ierat_req1_thdid_q(0 to thdid_width-1) when (ierat_outptr_q="01")
            else ierat_req2_thdid_q(0 to thdid_width-1) when (ierat_outptr_q="10")
            else ierat_req3_thdid_q(0 to thdid_width-1) when (ierat_outptr_q="11")
            else ierat_req0_thdid_q(0 to thdid_width-1);
ierat_req_dup <= ierat_req1_dup_q(0 to 1) when (ierat_outptr_q="01")
            else ierat_req2_dup_q(0 to 1) when (ierat_outptr_q="10")
            else ierat_req3_dup_q(0 to 1) when (ierat_outptr_q="11")
            else ierat_req0_dup_q(0 to 1);
derat_req_epn <= derat_req1_epn_q when (derat_outptr_q="01")
            else derat_req2_epn_q when (derat_outptr_q="10")
            else derat_req3_epn_q when (derat_outptr_q="11")
            else derat_req0_epn_q;
derat_req_pid <= derat_req1_pid_q when (derat_outptr_q="01")
            else derat_req2_pid_q when (derat_outptr_q="10")
            else derat_req3_pid_q when (derat_outptr_q="11")
            else derat_req0_pid_q;
derat_req_lpid <= derat_req1_lpid_q when (derat_outptr_q="01")
            else derat_req2_lpid_q when (derat_outptr_q="10")
            else derat_req3_lpid_q when (derat_outptr_q="11")
            else derat_req0_lpid_q;
derat_req_state <= derat_req1_state_q when (derat_outptr_q="01")
            else derat_req2_state_q when (derat_outptr_q="10")
            else derat_req3_state_q when (derat_outptr_q="11")
            else derat_req0_state_q;
derat_req_ttype <= derat_req1_ttype_q when (derat_outptr_q="01")
            else derat_req2_ttype_q when (derat_outptr_q="10")
            else derat_req3_ttype_q when (derat_outptr_q="11")
            else derat_req0_ttype_q;
derat_req_thdid <= derat_req1_thdid_q(0 to thdid_width-1) when (derat_outptr_q="01")
            else derat_req2_thdid_q(0 to thdid_width-1) when (derat_outptr_q="10")
            else derat_req3_thdid_q(0 to thdid_width-1) when (derat_outptr_q="11")
            else derat_req0_thdid_q(0 to thdid_width-1);
derat_req_dup <= derat_req1_dup_q(0 to 1) when (derat_outptr_q="01")
            else derat_req2_dup_q(0 to 1) when (derat_outptr_q="10")
            else derat_req3_dup_q(0 to 1) when (derat_outptr_q="11")
            else derat_req0_dup_q(0 to 1);
ierat_req0_pid      <= ierat_req0_pid_q;
ierat_req0_gs       <= ierat_req0_state_q(1);
ierat_req0_as       <= ierat_req0_state_q(2);
ierat_req0_epn      <= ierat_req0_epn_q;
ierat_req0_thdid    <= ierat_req0_thdid_q;
ierat_req0_valid    <= ierat_req0_valid_q;
ierat_req0_nonspec    <= ierat_req0_nonspec_q;
ierat_req1_pid      <= ierat_req1_pid_q;
ierat_req1_gs       <= ierat_req1_state_q(1);
ierat_req1_as       <= ierat_req1_state_q(2);
ierat_req1_epn      <= ierat_req1_epn_q;
ierat_req1_thdid    <= ierat_req1_thdid_q;
ierat_req1_valid    <= ierat_req1_valid_q;
ierat_req1_nonspec    <= ierat_req1_nonspec_q;
ierat_req2_pid      <= ierat_req2_pid_q;
ierat_req2_gs       <= ierat_req2_state_q(1);
ierat_req2_as       <= ierat_req2_state_q(2);
ierat_req2_epn      <= ierat_req2_epn_q;
ierat_req2_thdid    <= ierat_req2_thdid_q;
ierat_req2_valid    <= ierat_req2_valid_q;
ierat_req2_nonspec    <= ierat_req2_nonspec_q;
ierat_req3_pid      <= ierat_req3_pid_q;
ierat_req3_gs       <= ierat_req3_state_q(1);
ierat_req3_as       <= ierat_req3_state_q(2);
ierat_req3_epn      <= ierat_req3_epn_q;
ierat_req3_thdid    <= ierat_req3_thdid_q;
ierat_req3_valid    <= ierat_req3_valid_q;
ierat_req3_nonspec    <= ierat_req3_nonspec_q;
ierat_iu4_pid    <= ierat_iu4_pid_q;
ierat_iu4_gs     <= ierat_iu4_state_q(1);
ierat_iu4_as     <= ierat_iu4_state_q(2);
ierat_iu4_epn    <= ierat_iu4_epn_q;
ierat_iu4_thdid  <= ierat_iu4_thdid_q;
ierat_iu4_valid  <= ierat_iu4_valid_q;
derat_req0_lpid     <= derat_req0_lpid_q;
derat_req0_pid      <= derat_req0_pid_q;
derat_req0_gs       <= derat_req0_state_q(1);
derat_req0_as       <= derat_req0_state_q(2);
derat_req0_epn      <= derat_req0_epn_q;
derat_req0_thdid    <= derat_req0_thdid_q;
derat_req0_valid    <= derat_req0_valid_q;
derat_req1_lpid     <= derat_req1_lpid_q;
derat_req1_pid      <= derat_req1_pid_q;
derat_req1_gs       <= derat_req1_state_q(1);
derat_req1_as       <= derat_req1_state_q(2);
derat_req1_epn      <= derat_req1_epn_q;
derat_req1_thdid    <= derat_req1_thdid_q;
derat_req1_valid    <= derat_req1_valid_q;
derat_req2_lpid     <= derat_req2_lpid_q;
derat_req2_pid      <= derat_req2_pid_q;
derat_req2_gs       <= derat_req2_state_q(1);
derat_req2_as       <= derat_req2_state_q(2);
derat_req2_epn      <= derat_req2_epn_q;
derat_req2_thdid    <= derat_req2_thdid_q;
derat_req2_valid    <= derat_req2_valid_q;
derat_req3_lpid     <= derat_req3_lpid_q;
derat_req3_pid      <= derat_req3_pid_q;
derat_req3_gs       <= derat_req3_state_q(1);
derat_req3_as       <= derat_req3_state_q(2);
derat_req3_epn      <= derat_req3_epn_q;
derat_req3_thdid    <= derat_req3_thdid_q;
derat_req3_valid    <= derat_req3_valid_q;
derat_ex5_lpid   <= derat_ex5_lpid_q;
derat_ex5_pid    <= derat_ex5_pid_q;
derat_ex5_gs     <= derat_ex5_state_q(1);
derat_ex5_as     <= derat_ex5_state_q(2);
derat_ex5_epn    <= derat_ex5_epn_q;
derat_ex5_thdid  <= derat_ex5_thdid_q;
derat_ex5_valid  <= derat_ex5_valid_q;
tlb_req_dbg_ierat_iu5_valid_q       <= ierat_iu5_valid_q;
tlb_req_dbg_ierat_iu5_thdid(0)      <= ierat_iu5_thdid_q(2) or ierat_iu5_thdid_q(3);
tlb_req_dbg_ierat_iu5_thdid(1)      <= ierat_iu5_thdid_q(1) or ierat_iu5_thdid_q(3);
tlb_req_dbg_ierat_iu5_state_q       <= ierat_iu5_state_q;
tlb_req_dbg_ierat_inptr_q           <= ierat_inptr_q;
tlb_req_dbg_ierat_outptr_q          <= ierat_outptr_q;
tlb_req_dbg_ierat_req_valid_q       <= ierat_req0_valid_q & ierat_req1_valid_q & ierat_req2_valid_q & ierat_req3_valid_q;
tlb_req_dbg_ierat_req_nonspec_q     <= ierat_req0_nonspec_q & ierat_req1_nonspec_q & ierat_req2_nonspec_q & ierat_req3_nonspec_q;
tlb_req_dbg_ierat_req_thdid(0)      <= ierat_req0_thdid_q(2) or ierat_req0_thdid_q(3);
tlb_req_dbg_ierat_req_thdid(1)      <= ierat_req0_thdid_q(1) or ierat_req0_thdid_q(3);
tlb_req_dbg_ierat_req_thdid(2)      <= ierat_req1_thdid_q(2) or ierat_req1_thdid_q(3);
tlb_req_dbg_ierat_req_thdid(3)      <= ierat_req1_thdid_q(1) or ierat_req1_thdid_q(3);
tlb_req_dbg_ierat_req_thdid(4)      <= ierat_req2_thdid_q(2) or ierat_req2_thdid_q(3);
tlb_req_dbg_ierat_req_thdid(5)      <= ierat_req2_thdid_q(1) or ierat_req2_thdid_q(3);
tlb_req_dbg_ierat_req_thdid(6)      <= ierat_req3_thdid_q(2) or ierat_req3_thdid_q(3);
tlb_req_dbg_ierat_req_thdid(7)      <= ierat_req3_thdid_q(1) or ierat_req3_thdid_q(3);
tlb_req_dbg_ierat_req_dup_q         <= ierat_req0_dup_q(1) & ierat_req1_dup_q(1) & ierat_req2_dup_q(1) & ierat_req3_dup_q(1);
tlb_req_dbg_derat_ex6_valid_q       <= derat_ex6_valid_q;
tlb_req_dbg_derat_ex6_thdid(0)      <= derat_ex6_thdid_q(2) or derat_ex6_thdid_q(3);
tlb_req_dbg_derat_ex6_thdid(1)      <= derat_ex6_thdid_q(1) or derat_ex6_thdid_q(3);
tlb_req_dbg_derat_ex6_state_q       <= derat_ex6_state_q;
tlb_req_dbg_derat_inptr_q           <= derat_inptr_q;
tlb_req_dbg_derat_outptr_q          <= derat_outptr_q;
tlb_req_dbg_derat_req_valid_q       <= derat_req0_valid_q & derat_req1_valid_q & derat_req2_valid_q & derat_req3_valid_q;
tlb_req_dbg_derat_req_thdid(0)      <= derat_req0_thdid_q(2) or derat_req0_thdid_q(3);
tlb_req_dbg_derat_req_thdid(1)      <= derat_req0_thdid_q(1) or derat_req0_thdid_q(3);
tlb_req_dbg_derat_req_thdid(2)      <= derat_req1_thdid_q(2) or derat_req1_thdid_q(3);
tlb_req_dbg_derat_req_thdid(3)      <= derat_req1_thdid_q(1) or derat_req1_thdid_q(3);
tlb_req_dbg_derat_req_thdid(4)      <= derat_req2_thdid_q(2) or derat_req2_thdid_q(3);
tlb_req_dbg_derat_req_thdid(5)      <= derat_req2_thdid_q(1) or derat_req2_thdid_q(3);
tlb_req_dbg_derat_req_thdid(6)      <= derat_req3_thdid_q(2) or derat_req3_thdid_q(3);
tlb_req_dbg_derat_req_thdid(7)      <= derat_req3_thdid_q(1) or derat_req3_thdid_q(3);
tlb_req_dbg_derat_req_ttype_q(0 to 1)    <= derat_req0_ttype_q(0 to 1);
tlb_req_dbg_derat_req_ttype_q(2 to 3)    <= derat_req1_ttype_q(0 to 1);
tlb_req_dbg_derat_req_ttype_q(4 to 5)    <= derat_req2_ttype_q(0 to 1);
tlb_req_dbg_derat_req_ttype_q(6 to 7)    <= derat_req3_ttype_q(0 to 1);
tlb_req_dbg_derat_req_dup_q          <= derat_req0_dup_q(1) & derat_req1_dup_q(1) & derat_req2_dup_q(1) & derat_req3_dup_q(1);
unused_dc(0) <= or_reduce(LCB_DELAY_LCLKR_DC(1 TO 4));
unused_dc(1) <= or_reduce(LCB_MPW1_DC_B(1 TO 4));
unused_dc(2) <= PC_FUNC_SL_FORCE;
unused_dc(3) <= PC_FUNC_SL_THOLD_0_B;
unused_dc(4) <= TC_SCAN_DIS_DC_B;
unused_dc(5) <= TC_SCAN_DIAG_DC;
unused_dc(6) <= TC_LBIST_EN_DC;
unused_dc(7) <= or_reduce(IERAT_REQ_PID_MUX);
unused_dc(8) <= or_reduce(MM_XU_ERATMISS_DONE);
unused_dc(9) <= or_reduce(MM_XU_TLB_MISS);
unused_dc(10) <= TLB_SEQ_IERAT_DONE;
unused_dc(11) <= TLB_SEQ_DERAT_DONE;
unused_dc(12) <= mmucr2_act_override;
ierat_req0_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_req0_valid_offset),
            scout   => sov(ierat_req0_valid_offset),
            din     => ierat_req0_valid_d,
            dout    => ierat_req0_valid_q);
ierat_req0_nonspec_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_req0_nonspec_offset),
            scout   => sov(ierat_req0_nonspec_offset),
            din     => ierat_req0_nonspec_d,
            dout    => ierat_req0_nonspec_q);
ierat_req0_thdid_latch:   tri_rlmreg_p
  generic map (width => ierat_req0_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req0_thdid_offset   to ierat_req0_thdid_offset+ierat_req0_thdid_q'length-1),
            scout   => sov(ierat_req0_thdid_offset   to ierat_req0_thdid_offset+ierat_req0_thdid_q'length-1),
            din     => ierat_req0_thdid_d(0   to thdid_width-1),
            dout    => ierat_req0_thdid_q(0   to thdid_width-1)  );
ierat_req0_epn_latch:   tri_rlmreg_p
  generic map (width => ierat_req0_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req0_epn_offset   to ierat_req0_epn_offset+ierat_req0_epn_q'length-1),
            scout   => sov(ierat_req0_epn_offset   to ierat_req0_epn_offset+ierat_req0_epn_q'length-1),
            din     => ierat_req0_epn_d(0   to req_epn_width-1),
            dout    => ierat_req0_epn_q(0   to req_epn_width-1)  );
ierat_req0_state_latch:   tri_rlmreg_p
  generic map (width => ierat_req0_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req0_state_offset   to ierat_req0_state_offset+ierat_req0_state_q'length-1),
            scout   => sov(ierat_req0_state_offset   to ierat_req0_state_offset+ierat_req0_state_q'length-1),
            din     => ierat_req0_state_d(0   to state_width-1),
            dout    => ierat_req0_state_q(0   to state_width-1)  );
ierat_req0_pid_latch:   tri_rlmreg_p
  generic map (width => ierat_req0_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req0_pid_offset   to ierat_req0_pid_offset+ierat_req0_pid_q'length-1),
            scout   => sov(ierat_req0_pid_offset   to ierat_req0_pid_offset+ierat_req0_pid_q'length-1),
            din     => ierat_req0_pid_d(0   to pid_width-1),
            dout    => ierat_req0_pid_q(0   to pid_width-1)  );
ierat_req0_dup_latch:   tri_rlmreg_p
  generic map (width => ierat_req0_dup_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req0_dup_offset   to ierat_req0_dup_offset+ierat_req0_dup_q'length-1),
            scout   => sov(ierat_req0_dup_offset   to ierat_req0_dup_offset+ierat_req0_dup_q'length-1),
            din     => ierat_req0_dup_d,
            dout    => ierat_req0_dup_q    );
ierat_req1_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_req1_valid_offset),
            scout   => sov(ierat_req1_valid_offset),
            din     => ierat_req1_valid_d,
            dout    => ierat_req1_valid_q);
ierat_req1_nonspec_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_req1_nonspec_offset),
            scout   => sov(ierat_req1_nonspec_offset),
            din     => ierat_req1_nonspec_d,
            dout    => ierat_req1_nonspec_q);
ierat_req1_thdid_latch:   tri_rlmreg_p
  generic map (width => ierat_req1_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req1_thdid_offset   to ierat_req1_thdid_offset+ierat_req1_thdid_q'length-1),
            scout   => sov(ierat_req1_thdid_offset   to ierat_req1_thdid_offset+ierat_req1_thdid_q'length-1),
            din     => ierat_req1_thdid_d(0   to thdid_width-1),
            dout    => ierat_req1_thdid_q(0   to thdid_width-1)  );
ierat_req1_epn_latch:   tri_rlmreg_p
  generic map (width => ierat_req1_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req1_epn_offset   to ierat_req1_epn_offset+ierat_req1_epn_q'length-1),
            scout   => sov(ierat_req1_epn_offset   to ierat_req1_epn_offset+ierat_req1_epn_q'length-1),
            din     => ierat_req1_epn_d(0   to req_epn_width-1),
            dout    => ierat_req1_epn_q(0   to req_epn_width-1)  );
ierat_req1_state_latch:   tri_rlmreg_p
  generic map (width => ierat_req1_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req1_state_offset   to ierat_req1_state_offset+ierat_req1_state_q'length-1),
            scout   => sov(ierat_req1_state_offset   to ierat_req1_state_offset+ierat_req1_state_q'length-1),
            din     => ierat_req1_state_d(0   to state_width-1),
            dout    => ierat_req1_state_q(0   to state_width-1)  );
ierat_req1_pid_latch:   tri_rlmreg_p
  generic map (width => ierat_req1_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req1_pid_offset   to ierat_req1_pid_offset+ierat_req1_pid_q'length-1),
            scout   => sov(ierat_req1_pid_offset   to ierat_req1_pid_offset+ierat_req1_pid_q'length-1),
            din     => ierat_req1_pid_d(0   to pid_width-1),
            dout    => ierat_req1_pid_q(0   to pid_width-1)  );
ierat_req1_dup_latch:   tri_rlmreg_p
  generic map (width => ierat_req1_dup_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req1_dup_offset   to ierat_req1_dup_offset+ierat_req1_dup_q'length-1),
            scout   => sov(ierat_req1_dup_offset   to ierat_req1_dup_offset+ierat_req1_dup_q'length-1),
            din     => ierat_req1_dup_d,
            dout    => ierat_req1_dup_q    );
ierat_req2_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_req2_valid_offset),
            scout   => sov(ierat_req2_valid_offset),
            din     => ierat_req2_valid_d,
            dout    => ierat_req2_valid_q);
ierat_req2_nonspec_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_req2_nonspec_offset),
            scout   => sov(ierat_req2_nonspec_offset),
            din     => ierat_req2_nonspec_d,
            dout    => ierat_req2_nonspec_q);
ierat_req2_thdid_latch:   tri_rlmreg_p
  generic map (width => ierat_req2_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req2_thdid_offset   to ierat_req2_thdid_offset+ierat_req2_thdid_q'length-1),
            scout   => sov(ierat_req2_thdid_offset   to ierat_req2_thdid_offset+ierat_req2_thdid_q'length-1),
            din     => ierat_req2_thdid_d(0   to thdid_width-1),
            dout    => ierat_req2_thdid_q(0   to thdid_width-1)  );
ierat_req2_epn_latch:   tri_rlmreg_p
  generic map (width => ierat_req2_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req2_epn_offset   to ierat_req2_epn_offset+ierat_req2_epn_q'length-1),
            scout   => sov(ierat_req2_epn_offset   to ierat_req2_epn_offset+ierat_req2_epn_q'length-1),
            din     => ierat_req2_epn_d(0   to req_epn_width-1),
            dout    => ierat_req2_epn_q(0   to req_epn_width-1)  );
ierat_req2_state_latch:   tri_rlmreg_p
  generic map (width => ierat_req2_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req2_state_offset   to ierat_req2_state_offset+ierat_req2_state_q'length-1),
            scout   => sov(ierat_req2_state_offset   to ierat_req2_state_offset+ierat_req2_state_q'length-1),
            din     => ierat_req2_state_d(0   to state_width-1),
            dout    => ierat_req2_state_q(0   to state_width-1)  );
ierat_req2_pid_latch:   tri_rlmreg_p
  generic map (width => ierat_req2_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req2_pid_offset   to ierat_req2_pid_offset+ierat_req2_pid_q'length-1),
            scout   => sov(ierat_req2_pid_offset   to ierat_req2_pid_offset+ierat_req2_pid_q'length-1),
            din     => ierat_req2_pid_d(0   to pid_width-1),
            dout    => ierat_req2_pid_q(0   to pid_width-1)  );
ierat_req2_dup_latch:   tri_rlmreg_p
  generic map (width => ierat_req2_dup_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req2_dup_offset   to ierat_req2_dup_offset+ierat_req2_dup_q'length-1),
            scout   => sov(ierat_req2_dup_offset   to ierat_req2_dup_offset+ierat_req2_dup_q'length-1),
            din     => ierat_req2_dup_d,
            dout    => ierat_req2_dup_q    );
ierat_req3_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_req3_valid_offset),
            scout   => sov(ierat_req3_valid_offset),
            din     => ierat_req3_valid_d,
            dout    => ierat_req3_valid_q);
ierat_req3_nonspec_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_req3_nonspec_offset),
            scout   => sov(ierat_req3_nonspec_offset),
            din     => ierat_req3_nonspec_d,
            dout    => ierat_req3_nonspec_q);
ierat_req3_thdid_latch:   tri_rlmreg_p
  generic map (width => ierat_req3_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req3_thdid_offset   to ierat_req3_thdid_offset+ierat_req3_thdid_q'length-1),
            scout   => sov(ierat_req3_thdid_offset   to ierat_req3_thdid_offset+ierat_req3_thdid_q'length-1),
            din     => ierat_req3_thdid_d(0   to thdid_width-1),
            dout    => ierat_req3_thdid_q(0   to thdid_width-1)  );
ierat_req3_epn_latch:   tri_rlmreg_p
  generic map (width => ierat_req3_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req3_epn_offset   to ierat_req3_epn_offset+ierat_req3_epn_q'length-1),
            scout   => sov(ierat_req3_epn_offset   to ierat_req3_epn_offset+ierat_req3_epn_q'length-1),
            din     => ierat_req3_epn_d(0   to req_epn_width-1),
            dout    => ierat_req3_epn_q(0   to req_epn_width-1)  );
ierat_req3_state_latch:   tri_rlmreg_p
  generic map (width => ierat_req3_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req3_state_offset   to ierat_req3_state_offset+ierat_req3_state_q'length-1),
            scout   => sov(ierat_req3_state_offset   to ierat_req3_state_offset+ierat_req3_state_q'length-1),
            din     => ierat_req3_state_d(0   to state_width-1),
            dout    => ierat_req3_state_q(0   to state_width-1)  );
ierat_req3_pid_latch:   tri_rlmreg_p
  generic map (width => ierat_req3_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req3_pid_offset   to ierat_req3_pid_offset+ierat_req3_pid_q'length-1),
            scout   => sov(ierat_req3_pid_offset   to ierat_req3_pid_offset+ierat_req3_pid_q'length-1),
            din     => ierat_req3_pid_d(0   to pid_width-1),
            dout    => ierat_req3_pid_q(0   to pid_width-1)  );
ierat_req3_dup_latch:   tri_rlmreg_p
  generic map (width => ierat_req3_dup_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_req3_dup_offset   to ierat_req3_dup_offset+ierat_req3_dup_q'length-1),
            scout   => sov(ierat_req3_dup_offset   to ierat_req3_dup_offset+ierat_req3_dup_q'length-1),
            din     => ierat_req3_dup_d,
            dout    => ierat_req3_dup_q    );
ierat_inptr_latch: tri_rlmreg_p
  generic map (width => ierat_inptr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_inptr_offset to ierat_inptr_offset+ierat_inptr_q'length-1),
            scout   => sov(ierat_inptr_offset to ierat_inptr_offset+ierat_inptr_q'length-1),
            din     => ierat_inptr_d,
            dout    => ierat_inptr_q  );
ierat_outptr_latch: tri_rlmreg_p
  generic map (width => ierat_outptr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_outptr_offset to ierat_outptr_offset+ierat_outptr_q'length-1),
            scout   => sov(ierat_outptr_offset to ierat_outptr_offset+ierat_outptr_q'length-1),
            din     => ierat_outptr_d,
            dout    => ierat_outptr_q  );
ierat_iu3_flush_latch: tri_rlmreg_p
  generic map (width => ierat_iu3_flush_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu3_flush_offset to ierat_iu3_flush_offset+ierat_iu3_flush_q'length-1),
            scout   => sov(ierat_iu3_flush_offset to ierat_iu3_flush_offset+ierat_iu3_flush_q'length-1),
            din     => ierat_iu3_flush_d,
            dout    => ierat_iu3_flush_q  );
tlb_seq_ierat_req_latch: tri_rlmlatch_p
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
            scin    => siv(tlb_seq_ierat_req_offset),
            scout   => sov(tlb_seq_ierat_req_offset),
            din     => tlb_seq_ierat_req_d,
            dout    => tlb_seq_ierat_req_q);
xu_mm_ierat_flush_latch: tri_rlmreg_p
  generic map (width => xu_mm_ierat_flush_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(xu_mm_ierat_flush_offset to xu_mm_ierat_flush_offset+xu_mm_ierat_flush_q'length-1),
            scout   => sov(xu_mm_ierat_flush_offset to xu_mm_ierat_flush_offset+xu_mm_ierat_flush_q'length-1),
            din     => xu_mm_ierat_flush_d,
            dout    => xu_mm_ierat_flush_q  );
xu_mm_ierat_miss_latch: tri_rlmreg_p
  generic map (width => xu_mm_ierat_miss_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(xu_mm_ierat_miss_offset to xu_mm_ierat_miss_offset+xu_mm_ierat_miss_q'length-1),
            scout   => sov(xu_mm_ierat_miss_offset to xu_mm_ierat_miss_offset+xu_mm_ierat_miss_q'length-1),
            din     => xu_mm_ierat_miss_d,
            dout    => xu_mm_ierat_miss_q  );
ierat_iu3_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_iu3_valid_offset),
            scout   => sov(ierat_iu3_valid_offset),
            din     => ierat_iu3_valid_d,
            dout    => ierat_iu3_valid_q);
ierat_iu3_thdid_latch:   tri_rlmreg_p
  generic map (width => ierat_iu3_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu3_thdid_offset   to ierat_iu3_thdid_offset+ierat_iu3_thdid_q'length-1),
            scout   => sov(ierat_iu3_thdid_offset   to ierat_iu3_thdid_offset+ierat_iu3_thdid_q'length-1),
            din     => ierat_iu3_thdid_d(0   to thdid_width-1),
            dout    => ierat_iu3_thdid_q(0   to thdid_width-1)  );
ierat_iu3_epn_latch:   tri_rlmreg_p
  generic map (width => ierat_iu3_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu3_epn_offset   to ierat_iu3_epn_offset+ierat_iu3_epn_q'length-1),
            scout   => sov(ierat_iu3_epn_offset   to ierat_iu3_epn_offset+ierat_iu3_epn_q'length-1),
            din     => ierat_iu3_epn_d(0   to req_epn_width-1),
            dout    => ierat_iu3_epn_q(0   to req_epn_width-1)  );
ierat_iu3_state_latch:   tri_rlmreg_p
  generic map (width => ierat_iu3_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu3_state_offset   to ierat_iu3_state_offset+ierat_iu3_state_q'length-1),
            scout   => sov(ierat_iu3_state_offset   to ierat_iu3_state_offset+ierat_iu3_state_q'length-1),
            din     => ierat_iu3_state_d(0   to state_width-1),
            dout    => ierat_iu3_state_q(0   to state_width-1)  );
ierat_iu3_pid_latch:   tri_rlmreg_p
  generic map (width => ierat_iu3_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu3_pid_offset   to ierat_iu3_pid_offset+ierat_iu3_pid_q'length-1),
            scout   => sov(ierat_iu3_pid_offset   to ierat_iu3_pid_offset+ierat_iu3_pid_q'length-1),
            din     => ierat_iu3_pid_d(0   to pid_width-1),
            dout    => ierat_iu3_pid_q(0   to pid_width-1)  );
ierat_iu4_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_iu4_valid_offset),
            scout   => sov(ierat_iu4_valid_offset),
            din     => ierat_iu4_valid_d,
            dout    => ierat_iu4_valid_q);
ierat_iu4_thdid_latch:   tri_rlmreg_p
  generic map (width => ierat_iu4_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu4_thdid_offset   to ierat_iu4_thdid_offset+ierat_iu4_thdid_q'length-1),
            scout   => sov(ierat_iu4_thdid_offset   to ierat_iu4_thdid_offset+ierat_iu4_thdid_q'length-1),
            din     => ierat_iu4_thdid_d(0   to thdid_width-1),
            dout    => ierat_iu4_thdid_q(0   to thdid_width-1)  );
ierat_iu4_epn_latch:   tri_rlmreg_p
  generic map (width => ierat_iu4_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu4_epn_offset   to ierat_iu4_epn_offset+ierat_iu4_epn_q'length-1),
            scout   => sov(ierat_iu4_epn_offset   to ierat_iu4_epn_offset+ierat_iu4_epn_q'length-1),
            din     => ierat_iu4_epn_d(0   to req_epn_width-1),
            dout    => ierat_iu4_epn_q(0   to req_epn_width-1)  );
ierat_iu4_state_latch:   tri_rlmreg_p
  generic map (width => ierat_iu4_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu4_state_offset   to ierat_iu4_state_offset+ierat_iu4_state_q'length-1),
            scout   => sov(ierat_iu4_state_offset   to ierat_iu4_state_offset+ierat_iu4_state_q'length-1),
            din     => ierat_iu4_state_d(0   to state_width-1),
            dout    => ierat_iu4_state_q(0   to state_width-1)  );
ierat_iu4_pid_latch:   tri_rlmreg_p
  generic map (width => ierat_iu4_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu4_pid_offset   to ierat_iu4_pid_offset+ierat_iu4_pid_q'length-1),
            scout   => sov(ierat_iu4_pid_offset   to ierat_iu4_pid_offset+ierat_iu4_pid_q'length-1),
            din     => ierat_iu4_pid_d(0   to pid_width-1),
            dout    => ierat_iu4_pid_q(0   to pid_width-1)  );
ierat_iu5_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(ierat_iu5_valid_offset),
            scout   => sov(ierat_iu5_valid_offset),
            din     => ierat_iu5_valid_d,
            dout    => ierat_iu5_valid_q);
ierat_iu5_thdid_latch:   tri_rlmreg_p
  generic map (width => ierat_iu5_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu5_thdid_offset   to ierat_iu5_thdid_offset+ierat_iu5_thdid_q'length-1),
            scout   => sov(ierat_iu5_thdid_offset   to ierat_iu5_thdid_offset+ierat_iu5_thdid_q'length-1),
            din     => ierat_iu5_thdid_d(0   to thdid_width-1),
            dout    => ierat_iu5_thdid_q(0   to thdid_width-1)  );
ierat_iu5_epn_latch:   tri_rlmreg_p
  generic map (width => ierat_iu5_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu5_epn_offset   to ierat_iu5_epn_offset+ierat_iu5_epn_q'length-1),
            scout   => sov(ierat_iu5_epn_offset   to ierat_iu5_epn_offset+ierat_iu5_epn_q'length-1),
            din     => ierat_iu5_epn_d(0   to req_epn_width-1),
            dout    => ierat_iu5_epn_q(0   to req_epn_width-1)  );
ierat_iu5_state_latch:   tri_rlmreg_p
  generic map (width => ierat_iu5_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu5_state_offset   to ierat_iu5_state_offset+ierat_iu5_state_q'length-1),
            scout   => sov(ierat_iu5_state_offset   to ierat_iu5_state_offset+ierat_iu5_state_q'length-1),
            din     => ierat_iu5_state_d(0   to state_width-1),
            dout    => ierat_iu5_state_q(0   to state_width-1)  );
ierat_iu5_pid_latch:   tri_rlmreg_p
  generic map (width => ierat_iu5_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ierat_iu5_pid_offset   to ierat_iu5_pid_offset+ierat_iu5_pid_q'length-1),
            scout   => sov(ierat_iu5_pid_offset   to ierat_iu5_pid_offset+ierat_iu5_pid_q'length-1),
            din     => ierat_iu5_pid_d(0   to pid_width-1),
            dout    => ierat_iu5_pid_q(0   to pid_width-1)  );
derat_req0_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(derat_req0_valid_offset),
            scout   => sov(derat_req0_valid_offset),
            din     => derat_req0_valid_d,
            dout    => derat_req0_valid_q);
derat_req0_thdid_latch:   tri_rlmreg_p
  generic map (width => derat_req0_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req0_thdid_offset   to derat_req0_thdid_offset+derat_req0_thdid_q'length-1),
            scout   => sov(derat_req0_thdid_offset   to derat_req0_thdid_offset+derat_req0_thdid_q'length-1),
            din     => derat_req0_thdid_d(0   to thdid_width-1),
            dout    => derat_req0_thdid_q(0   to thdid_width-1)  );
derat_req0_epn_latch:   tri_rlmreg_p
  generic map (width => derat_req0_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req0_epn_offset   to derat_req0_epn_offset+derat_req0_epn_q'length-1),
            scout   => sov(derat_req0_epn_offset   to derat_req0_epn_offset+derat_req0_epn_q'length-1),
            din     => derat_req0_epn_d(0   to req_epn_width-1),
            dout    => derat_req0_epn_q(0   to req_epn_width-1)  );
derat_req0_state_latch:   tri_rlmreg_p
  generic map (width => derat_req0_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req0_state_offset   to derat_req0_state_offset+derat_req0_state_q'length-1),
            scout   => sov(derat_req0_state_offset   to derat_req0_state_offset+derat_req0_state_q'length-1),
            din     => derat_req0_state_d(0   to state_width-1),
            dout    => derat_req0_state_q(0   to state_width-1)  );
derat_req0_ttype_latch:   tri_rlmreg_p
  generic map (width => derat_req0_ttype_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req0_ttype_offset   to derat_req0_ttype_offset+derat_req0_ttype_q'length-1),
            scout   => sov(derat_req0_ttype_offset   to derat_req0_ttype_offset+derat_req0_ttype_q'length-1),
            din     => derat_req0_ttype_d,
            dout    => derat_req0_ttype_q    );
derat_req0_pid_latch:   tri_rlmreg_p
  generic map (width => derat_req0_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req0_pid_offset   to derat_req0_pid_offset+derat_req0_pid_q'length-1),
            scout   => sov(derat_req0_pid_offset   to derat_req0_pid_offset+derat_req0_pid_q'length-1),
            din     => derat_req0_pid_d(0   to pid_width-1),
            dout    => derat_req0_pid_q(0   to pid_width-1)  );
derat_req0_lpid_latch:   tri_rlmreg_p
  generic map (width => derat_req0_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req0_lpid_offset   to derat_req0_lpid_offset+derat_req0_lpid_q'length-1),
            scout   => sov(derat_req0_lpid_offset   to derat_req0_lpid_offset+derat_req0_lpid_q'length-1),
            din     => derat_req0_lpid_d(0   to lpid_width-1),
            dout    => derat_req0_lpid_q(0   to lpid_width-1)  );
derat_req0_dup_latch:   tri_rlmreg_p
  generic map (width => derat_req0_dup_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req0_dup_offset   to derat_req0_dup_offset+derat_req0_dup_q'length-1),
            scout   => sov(derat_req0_dup_offset   to derat_req0_dup_offset+derat_req0_dup_q'length-1),
            din     => derat_req0_dup_d,
            dout    => derat_req0_dup_q    );
derat_req1_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(derat_req1_valid_offset),
            scout   => sov(derat_req1_valid_offset),
            din     => derat_req1_valid_d,
            dout    => derat_req1_valid_q);
derat_req1_thdid_latch:   tri_rlmreg_p
  generic map (width => derat_req1_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req1_thdid_offset   to derat_req1_thdid_offset+derat_req1_thdid_q'length-1),
            scout   => sov(derat_req1_thdid_offset   to derat_req1_thdid_offset+derat_req1_thdid_q'length-1),
            din     => derat_req1_thdid_d(0   to thdid_width-1),
            dout    => derat_req1_thdid_q(0   to thdid_width-1)  );
derat_req1_epn_latch:   tri_rlmreg_p
  generic map (width => derat_req1_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req1_epn_offset   to derat_req1_epn_offset+derat_req1_epn_q'length-1),
            scout   => sov(derat_req1_epn_offset   to derat_req1_epn_offset+derat_req1_epn_q'length-1),
            din     => derat_req1_epn_d(0   to req_epn_width-1),
            dout    => derat_req1_epn_q(0   to req_epn_width-1)  );
derat_req1_state_latch:   tri_rlmreg_p
  generic map (width => derat_req1_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req1_state_offset   to derat_req1_state_offset+derat_req1_state_q'length-1),
            scout   => sov(derat_req1_state_offset   to derat_req1_state_offset+derat_req1_state_q'length-1),
            din     => derat_req1_state_d(0   to state_width-1),
            dout    => derat_req1_state_q(0   to state_width-1)  );
derat_req1_ttype_latch:   tri_rlmreg_p
  generic map (width => derat_req1_ttype_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req1_ttype_offset   to derat_req1_ttype_offset+derat_req1_ttype_q'length-1),
            scout   => sov(derat_req1_ttype_offset   to derat_req1_ttype_offset+derat_req1_ttype_q'length-1),
            din     => derat_req1_ttype_d,
            dout    => derat_req1_ttype_q    );
derat_req1_pid_latch:   tri_rlmreg_p
  generic map (width => derat_req1_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req1_pid_offset   to derat_req1_pid_offset+derat_req1_pid_q'length-1),
            scout   => sov(derat_req1_pid_offset   to derat_req1_pid_offset+derat_req1_pid_q'length-1),
            din     => derat_req1_pid_d(0   to pid_width-1),
            dout    => derat_req1_pid_q(0   to pid_width-1)  );
derat_req1_lpid_latch:   tri_rlmreg_p
  generic map (width => derat_req1_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req1_lpid_offset   to derat_req1_lpid_offset+derat_req1_lpid_q'length-1),
            scout   => sov(derat_req1_lpid_offset   to derat_req1_lpid_offset+derat_req1_lpid_q'length-1),
            din     => derat_req1_lpid_d(0   to lpid_width-1),
            dout    => derat_req1_lpid_q(0   to lpid_width-1)  );
derat_req1_dup_latch:   tri_rlmreg_p
  generic map (width => derat_req1_dup_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req1_dup_offset   to derat_req1_dup_offset+derat_req1_dup_q'length-1),
            scout   => sov(derat_req1_dup_offset   to derat_req1_dup_offset+derat_req1_dup_q'length-1),
            din     => derat_req1_dup_d,
            dout    => derat_req1_dup_q    );
derat_req2_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(derat_req2_valid_offset),
            scout   => sov(derat_req2_valid_offset),
            din     => derat_req2_valid_d,
            dout    => derat_req2_valid_q);
derat_req2_thdid_latch:   tri_rlmreg_p
  generic map (width => derat_req2_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req2_thdid_offset   to derat_req2_thdid_offset+derat_req2_thdid_q'length-1),
            scout   => sov(derat_req2_thdid_offset   to derat_req2_thdid_offset+derat_req2_thdid_q'length-1),
            din     => derat_req2_thdid_d(0   to thdid_width-1),
            dout    => derat_req2_thdid_q(0   to thdid_width-1)  );
derat_req2_epn_latch:   tri_rlmreg_p
  generic map (width => derat_req2_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req2_epn_offset   to derat_req2_epn_offset+derat_req2_epn_q'length-1),
            scout   => sov(derat_req2_epn_offset   to derat_req2_epn_offset+derat_req2_epn_q'length-1),
            din     => derat_req2_epn_d(0   to req_epn_width-1),
            dout    => derat_req2_epn_q(0   to req_epn_width-1)  );
derat_req2_state_latch:   tri_rlmreg_p
  generic map (width => derat_req2_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req2_state_offset   to derat_req2_state_offset+derat_req2_state_q'length-1),
            scout   => sov(derat_req2_state_offset   to derat_req2_state_offset+derat_req2_state_q'length-1),
            din     => derat_req2_state_d(0   to state_width-1),
            dout    => derat_req2_state_q(0   to state_width-1)  );
derat_req2_ttype_latch:   tri_rlmreg_p
  generic map (width => derat_req2_ttype_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req2_ttype_offset   to derat_req2_ttype_offset+derat_req2_ttype_q'length-1),
            scout   => sov(derat_req2_ttype_offset   to derat_req2_ttype_offset+derat_req2_ttype_q'length-1),
            din     => derat_req2_ttype_d,
            dout    => derat_req2_ttype_q    );
derat_req2_pid_latch:   tri_rlmreg_p
  generic map (width => derat_req2_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req2_pid_offset   to derat_req2_pid_offset+derat_req2_pid_q'length-1),
            scout   => sov(derat_req2_pid_offset   to derat_req2_pid_offset+derat_req2_pid_q'length-1),
            din     => derat_req2_pid_d(0   to pid_width-1),
            dout    => derat_req2_pid_q(0   to pid_width-1)  );
derat_req2_lpid_latch:   tri_rlmreg_p
  generic map (width => derat_req2_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req2_lpid_offset   to derat_req2_lpid_offset+derat_req2_lpid_q'length-1),
            scout   => sov(derat_req2_lpid_offset   to derat_req2_lpid_offset+derat_req2_lpid_q'length-1),
            din     => derat_req2_lpid_d(0   to lpid_width-1),
            dout    => derat_req2_lpid_q(0   to lpid_width-1)  );
derat_req2_dup_latch:   tri_rlmreg_p
  generic map (width => derat_req2_dup_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req2_dup_offset   to derat_req2_dup_offset+derat_req2_dup_q'length-1),
            scout   => sov(derat_req2_dup_offset   to derat_req2_dup_offset+derat_req2_dup_q'length-1),
            din     => derat_req2_dup_d,
            dout    => derat_req2_dup_q    );
derat_req3_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(derat_req3_valid_offset),
            scout   => sov(derat_req3_valid_offset),
            din     => derat_req3_valid_d,
            dout    => derat_req3_valid_q);
derat_req3_thdid_latch:   tri_rlmreg_p
  generic map (width => derat_req3_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req3_thdid_offset   to derat_req3_thdid_offset+derat_req3_thdid_q'length-1),
            scout   => sov(derat_req3_thdid_offset   to derat_req3_thdid_offset+derat_req3_thdid_q'length-1),
            din     => derat_req3_thdid_d(0   to thdid_width-1),
            dout    => derat_req3_thdid_q(0   to thdid_width-1)  );
derat_req3_epn_latch:   tri_rlmreg_p
  generic map (width => derat_req3_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req3_epn_offset   to derat_req3_epn_offset+derat_req3_epn_q'length-1),
            scout   => sov(derat_req3_epn_offset   to derat_req3_epn_offset+derat_req3_epn_q'length-1),
            din     => derat_req3_epn_d(0   to req_epn_width-1),
            dout    => derat_req3_epn_q(0   to req_epn_width-1)  );
derat_req3_state_latch:   tri_rlmreg_p
  generic map (width => derat_req3_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req3_state_offset   to derat_req3_state_offset+derat_req3_state_q'length-1),
            scout   => sov(derat_req3_state_offset   to derat_req3_state_offset+derat_req3_state_q'length-1),
            din     => derat_req3_state_d(0   to state_width-1),
            dout    => derat_req3_state_q(0   to state_width-1)  );
derat_req3_ttype_latch:   tri_rlmreg_p
  generic map (width => derat_req3_ttype_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req3_ttype_offset   to derat_req3_ttype_offset+derat_req3_ttype_q'length-1),
            scout   => sov(derat_req3_ttype_offset   to derat_req3_ttype_offset+derat_req3_ttype_q'length-1),
            din     => derat_req3_ttype_d,
            dout    => derat_req3_ttype_q    );
derat_req3_pid_latch:   tri_rlmreg_p
  generic map (width => derat_req3_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req3_pid_offset   to derat_req3_pid_offset+derat_req3_pid_q'length-1),
            scout   => sov(derat_req3_pid_offset   to derat_req3_pid_offset+derat_req3_pid_q'length-1),
            din     => derat_req3_pid_d(0   to pid_width-1),
            dout    => derat_req3_pid_q(0   to pid_width-1)  );
derat_req3_lpid_latch:   tri_rlmreg_p
  generic map (width => derat_req3_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req3_lpid_offset   to derat_req3_lpid_offset+derat_req3_lpid_q'length-1),
            scout   => sov(derat_req3_lpid_offset   to derat_req3_lpid_offset+derat_req3_lpid_q'length-1),
            din     => derat_req3_lpid_d(0   to lpid_width-1),
            dout    => derat_req3_lpid_q(0   to lpid_width-1)  );
derat_req3_dup_latch:   tri_rlmreg_p
  generic map (width => derat_req3_dup_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_req3_dup_offset   to derat_req3_dup_offset+derat_req3_dup_q'length-1),
            scout   => sov(derat_req3_dup_offset   to derat_req3_dup_offset+derat_req3_dup_q'length-1),
            din     => derat_req3_dup_d,
            dout    => derat_req3_dup_q    );
derat_inptr_latch: tri_rlmreg_p
  generic map (width => derat_inptr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_inptr_offset to derat_inptr_offset+derat_inptr_q'length-1),
            scout   => sov(derat_inptr_offset to derat_inptr_offset+derat_inptr_q'length-1),
            din     => derat_inptr_d,
            dout    => derat_inptr_q  );
derat_outptr_latch: tri_rlmreg_p
  generic map (width => derat_outptr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_outptr_offset to derat_outptr_offset+derat_outptr_q'length-1),
            scout   => sov(derat_outptr_offset to derat_outptr_offset+derat_outptr_q'length-1),
            din     => derat_outptr_d,
            dout    => derat_outptr_q  );
tlb_seq_derat_req_latch: tri_rlmlatch_p
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
            scin    => siv(tlb_seq_derat_req_offset),
            scout   => sov(tlb_seq_derat_req_offset),
            din     => tlb_seq_derat_req_d,
            dout    => tlb_seq_derat_req_q);
derat_ex4_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(derat_ex4_valid_offset),
            scout   => sov(derat_ex4_valid_offset),
            din     => derat_ex4_valid_d,
            dout    => derat_ex4_valid_q);
derat_ex4_thdid_latch:   tri_rlmreg_p
  generic map (width => derat_ex4_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex4_thdid_offset   to derat_ex4_thdid_offset+derat_ex4_thdid_q'length-1),
            scout   => sov(derat_ex4_thdid_offset   to derat_ex4_thdid_offset+derat_ex4_thdid_q'length-1),
            din     => derat_ex4_thdid_d(0   to thdid_width-1),
            dout    => derat_ex4_thdid_q(0   to thdid_width-1)  );
derat_ex4_epn_latch:   tri_rlmreg_p
  generic map (width => derat_ex4_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex4_epn_offset   to derat_ex4_epn_offset+derat_ex4_epn_q'length-1),
            scout   => sov(derat_ex4_epn_offset   to derat_ex4_epn_offset+derat_ex4_epn_q'length-1),
            din     => derat_ex4_epn_d(0   to req_epn_width-1),
            dout    => derat_ex4_epn_q(0   to req_epn_width-1)  );
derat_ex4_state_latch:   tri_rlmreg_p
  generic map (width => derat_ex4_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex4_state_offset   to derat_ex4_state_offset+derat_ex4_state_q'length-1),
            scout   => sov(derat_ex4_state_offset   to derat_ex4_state_offset+derat_ex4_state_q'length-1),
            din     => derat_ex4_state_d(0   to state_width-1),
            dout    => derat_ex4_state_q(0   to state_width-1)  );
derat_ex4_ttype_latch:   tri_rlmreg_p
  generic map (width => derat_ex4_ttype_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex4_ttype_offset   to derat_ex4_ttype_offset+derat_ex4_ttype_q'length-1),
            scout   => sov(derat_ex4_ttype_offset   to derat_ex4_ttype_offset+derat_ex4_ttype_q'length-1),
            din     => derat_ex4_ttype_d,
            dout    => derat_ex4_ttype_q    );
derat_ex4_pid_latch:   tri_rlmreg_p
  generic map (width => derat_ex4_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex4_pid_offset   to derat_ex4_pid_offset+derat_ex4_pid_q'length-1),
            scout   => sov(derat_ex4_pid_offset   to derat_ex4_pid_offset+derat_ex4_pid_q'length-1),
            din     => derat_ex4_pid_d(0   to pid_width-1),
            dout    => derat_ex4_pid_q(0   to pid_width-1)  );
derat_ex4_lpid_latch:   tri_rlmreg_p
  generic map (width => derat_ex4_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex4_lpid_offset   to derat_ex4_lpid_offset+derat_ex4_lpid_q'length-1),
            scout   => sov(derat_ex4_lpid_offset   to derat_ex4_lpid_offset+derat_ex4_lpid_q'length-1),
            din     => derat_ex4_lpid_d(0   to lpid_width-1),
            dout    => derat_ex4_lpid_q(0   to lpid_width-1)  );
derat_ex5_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(derat_ex5_valid_offset),
            scout   => sov(derat_ex5_valid_offset),
            din     => derat_ex5_valid_d,
            dout    => derat_ex5_valid_q);
derat_ex5_thdid_latch:   tri_rlmreg_p
  generic map (width => derat_ex5_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex5_thdid_offset   to derat_ex5_thdid_offset+derat_ex5_thdid_q'length-1),
            scout   => sov(derat_ex5_thdid_offset   to derat_ex5_thdid_offset+derat_ex5_thdid_q'length-1),
            din     => derat_ex5_thdid_d(0   to thdid_width-1),
            dout    => derat_ex5_thdid_q(0   to thdid_width-1)  );
derat_ex5_epn_latch:   tri_rlmreg_p
  generic map (width => derat_ex5_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex5_epn_offset   to derat_ex5_epn_offset+derat_ex5_epn_q'length-1),
            scout   => sov(derat_ex5_epn_offset   to derat_ex5_epn_offset+derat_ex5_epn_q'length-1),
            din     => derat_ex5_epn_d(0   to req_epn_width-1),
            dout    => derat_ex5_epn_q(0   to req_epn_width-1)  );
derat_ex5_state_latch:   tri_rlmreg_p
  generic map (width => derat_ex5_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex5_state_offset   to derat_ex5_state_offset+derat_ex5_state_q'length-1),
            scout   => sov(derat_ex5_state_offset   to derat_ex5_state_offset+derat_ex5_state_q'length-1),
            din     => derat_ex5_state_d(0   to state_width-1),
            dout    => derat_ex5_state_q(0   to state_width-1)  );
derat_ex5_ttype_latch:   tri_rlmreg_p
  generic map (width => derat_ex5_ttype_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex5_ttype_offset   to derat_ex5_ttype_offset+derat_ex5_ttype_q'length-1),
            scout   => sov(derat_ex5_ttype_offset   to derat_ex5_ttype_offset+derat_ex5_ttype_q'length-1),
            din     => derat_ex5_ttype_d,
            dout    => derat_ex5_ttype_q    );
derat_ex5_pid_latch:   tri_rlmreg_p
  generic map (width => derat_ex5_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex5_pid_offset   to derat_ex5_pid_offset+derat_ex5_pid_q'length-1),
            scout   => sov(derat_ex5_pid_offset   to derat_ex5_pid_offset+derat_ex5_pid_q'length-1),
            din     => derat_ex5_pid_d(0   to pid_width-1),
            dout    => derat_ex5_pid_q(0   to pid_width-1)  );
derat_ex5_lpid_latch:   tri_rlmreg_p
  generic map (width => derat_ex5_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex5_lpid_offset   to derat_ex5_lpid_offset+derat_ex5_lpid_q'length-1),
            scout   => sov(derat_ex5_lpid_offset   to derat_ex5_lpid_offset+derat_ex5_lpid_q'length-1),
            din     => derat_ex5_lpid_d(0   to lpid_width-1),
            dout    => derat_ex5_lpid_q(0   to lpid_width-1)  );
derat_ex6_valid_latch:   tri_rlmlatch_p
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
            scin    => siv(derat_ex6_valid_offset),
            scout   => sov(derat_ex6_valid_offset),
            din     => derat_ex6_valid_d,
            dout    => derat_ex6_valid_q);
derat_ex6_thdid_latch:   tri_rlmreg_p
  generic map (width => derat_ex6_thdid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex6_thdid_offset   to derat_ex6_thdid_offset+derat_ex6_thdid_q'length-1),
            scout   => sov(derat_ex6_thdid_offset   to derat_ex6_thdid_offset+derat_ex6_thdid_q'length-1),
            din     => derat_ex6_thdid_d(0   to thdid_width-1),
            dout    => derat_ex6_thdid_q(0   to thdid_width-1)  );
derat_ex6_epn_latch:   tri_rlmreg_p
  generic map (width => derat_ex6_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex6_epn_offset   to derat_ex6_epn_offset+derat_ex6_epn_q'length-1),
            scout   => sov(derat_ex6_epn_offset   to derat_ex6_epn_offset+derat_ex6_epn_q'length-1),
            din     => derat_ex6_epn_d(0   to req_epn_width-1),
            dout    => derat_ex6_epn_q(0   to req_epn_width-1)  );
derat_ex6_state_latch:   tri_rlmreg_p
  generic map (width => derat_ex6_state_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex6_state_offset   to derat_ex6_state_offset+derat_ex6_state_q'length-1),
            scout   => sov(derat_ex6_state_offset   to derat_ex6_state_offset+derat_ex6_state_q'length-1),
            din     => derat_ex6_state_d(0   to state_width-1),
            dout    => derat_ex6_state_q(0   to state_width-1)  );
derat_ex6_ttype_latch:   tri_rlmreg_p
  generic map (width => derat_ex6_ttype_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex6_ttype_offset   to derat_ex6_ttype_offset+derat_ex6_ttype_q'length-1),
            scout   => sov(derat_ex6_ttype_offset   to derat_ex6_ttype_offset+derat_ex6_ttype_q'length-1),
            din     => derat_ex6_ttype_d,
            dout    => derat_ex6_ttype_q    );
derat_ex6_pid_latch:   tri_rlmreg_p
  generic map (width => derat_ex6_pid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex6_pid_offset   to derat_ex6_pid_offset+derat_ex6_pid_q'length-1),
            scout   => sov(derat_ex6_pid_offset   to derat_ex6_pid_offset+derat_ex6_pid_q'length-1),
            din     => derat_ex6_pid_d(0   to pid_width-1),
            dout    => derat_ex6_pid_q(0   to pid_width-1)  );
derat_ex6_lpid_latch:   tri_rlmreg_p
  generic map (width => derat_ex6_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(derat_ex6_lpid_offset   to derat_ex6_lpid_offset+derat_ex6_lpid_q'length-1),
            scout   => sov(derat_ex6_lpid_offset   to derat_ex6_lpid_offset+derat_ex6_lpid_q'length-1),
            din     => derat_ex6_lpid_d(0   to lpid_width-1),
            dout    => derat_ex6_lpid_q(0   to lpid_width-1)  );
spare_latch: tri_rlmreg_p
  generic map (width => spare_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(spare_offset to spare_offset+spare_q'length-1),
            scout   => sov(spare_offset to spare_offset+spare_q'length-1),
            din     => spare_q,
            dout    => spare_q  );
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
siv(0 to scan_right) <= sov(1 to scan_right) & ac_func_scan_in;
ac_func_scan_out <= sov(0);
end mmq_tlb_req;

