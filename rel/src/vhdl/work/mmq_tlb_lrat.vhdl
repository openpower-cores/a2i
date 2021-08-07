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

			

--********************************************************************
--* TITLE: MMU Logical to Real Translate Logic
--* NAME: mmq_tlb_lrat.vhdl
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

entity mmq_tlb_lrat is
  generic(thdid_width       : integer := 4;
            ttype_width        : integer := 5;
            lpid_width         : integer := 8;
            spr_data_width     : integer := 64;
            real_addr_width    : integer := 42;
            rpn_width          : integer := 30;  
            epn_width          : integer := 52;
            lrat_num_entry      : natural := 8; 
            lrat_num_entry_log2 : natural := 3;
            lrat_maxsize_log2  : integer := 40;  
            lrat_minsize_log2  : integer := 20;  
          expand_type          : integer := 2 );   
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
xu_mm_ccr2_notlb_b  : in     std_ulogic;
tlb_delayed_act       : in std_ulogic_vector(20 to 23);
mmucr2_act_override   : in     std_ulogic;
tlb_ctl_ex3_valid    : in std_ulogic_vector(0 to thdid_width-1);
tlb_ctl_ex3_ttype    : in std_ulogic_vector(0 to ttype_width-1);
xu_ex3_flush         : in std_ulogic_vector(0 to thdid_width-1);
xu_ex4_flush         : in std_ulogic_vector(0 to thdid_width-1);
xu_ex5_flush         : in std_ulogic_vector(0 to thdid_width-1);
tlb_tag0_epn         : in std_ulogic_vector(64-real_addr_width to 51);
tlb_tag0_thdid       : in std_ulogic_vector(0 to thdid_width-1);
tlb_tag0_type        : in std_ulogic_vector(0 to 7);
tlb_tag0_lpid        : in std_ulogic_vector(0 to lpid_width-1);
tlb_tag0_size        : in std_ulogic_vector(0 to 3);
tlb_tag0_atsel       : in std_ulogic;
tlb_tag0_addr_cap    : in std_ulogic;
ex6_illeg_instr      : in std_ulogic_vector(0 to 1);
pte_tag0_lpn         : in std_ulogic_vector(64-real_addr_width to 51);
pte_tag0_lpid        : in std_ulogic_vector(0 to lpid_width-1);
mas0_0_atsel           : in std_ulogic;
mas0_0_esel            : in std_ulogic_vector(0 to lrat_num_entry_log2-1);
mas0_0_hes             : in std_ulogic;
mas0_0_wq              : in std_ulogic_vector(0 to 1);
mas1_0_v               : in std_ulogic;
mas1_0_tsize           : in std_ulogic_vector(0 to 3);
mas2_0_epn             : in std_ulogic_vector(64-real_addr_width to 51);
mas7_0_rpnu            : in std_ulogic_vector(22 to 31);
mas3_0_rpnl            : in std_ulogic_vector(32 to 51);
mas8_0_tlpid           : in std_ulogic_vector(0 to lpid_width-1);
mmucr3_0_x             : in std_ulogic;
mas0_1_atsel           : in std_ulogic;
mas0_1_esel            : in std_ulogic_vector(0 to lrat_num_entry_log2-1);
mas0_1_hes             : in std_ulogic;
mas0_1_wq              : in std_ulogic_vector(0 to 1);
mas1_1_v               : in std_ulogic;
mas1_1_tsize           : in std_ulogic_vector(0 to 3);
mas2_1_epn             : in std_ulogic_vector(64-real_addr_width to 51);
mas7_1_rpnu            : in std_ulogic_vector(22 to 31);
mas3_1_rpnl            : in std_ulogic_vector(32 to 51);
mas8_1_tlpid           : in std_ulogic_vector(0 to lpid_width-1);
mmucr3_1_x             : in std_ulogic;
mas0_2_atsel           : in std_ulogic;
mas0_2_esel            : in std_ulogic_vector(0 to lrat_num_entry_log2-1);
mas0_2_hes             : in std_ulogic;
mas0_2_wq              : in std_ulogic_vector(0 to 1);
mas1_2_v               : in std_ulogic;
mas1_2_tsize           : in std_ulogic_vector(0 to 3);
mas2_2_epn             : in std_ulogic_vector(64-real_addr_width to 51);
mas7_2_rpnu            : in std_ulogic_vector(22 to 31);
mas3_2_rpnl            : in std_ulogic_vector(32 to 51);
mas8_2_tlpid           : in std_ulogic_vector(0 to lpid_width-1);
mmucr3_2_x             : in std_ulogic;
mas0_3_atsel           : in std_ulogic;
mas0_3_esel            : in std_ulogic_vector(0 to lrat_num_entry_log2-1);
mas0_3_hes             : in std_ulogic;
mas0_3_wq              : in std_ulogic_vector(0 to 1);
mas1_3_v               : in std_ulogic;
mas1_3_tsize           : in std_ulogic_vector(0 to 3);
mas2_3_epn             : in std_ulogic_vector(64-real_addr_width to 51);
mas7_3_rpnu            : in std_ulogic_vector(22 to 31);
mas3_3_rpnl            : in std_ulogic_vector(32 to 51);
mas8_3_tlpid           : in std_ulogic_vector(0 to lpid_width-1);
mmucr3_3_x             : in std_ulogic;
lrat_mmucr3_x          : out std_ulogic;
lrat_mas0_esel         : out std_ulogic_vector(0 to 2);
lrat_mas1_v            : out std_ulogic;
lrat_mas1_tsize        : out std_ulogic_vector(0 to 3);
lrat_mas2_epn          : out std_ulogic_vector(0 to 51);
lrat_mas3_rpnl         : out std_ulogic_vector(32 to 51);
lrat_mas7_rpnu         : out std_ulogic_vector(22 to 31);
lrat_mas8_tlpid        : out std_ulogic_vector(0 to lpid_width-1);
lrat_mas_tlbre         : out std_ulogic;
lrat_mas_tlbsx_hit     : out std_ulogic;
lrat_mas_tlbsx_miss    : out std_ulogic;
lrat_mas_thdid         : out std_ulogic_vector(0 to thdid_width-1);
lrat_tag3_lpn              : out std_ulogic_vector(64-real_addr_width to 51);
lrat_tag3_rpn              : out std_ulogic_vector(64-real_addr_width to 51);
lrat_tag3_hit_status       : out std_ulogic_vector(0 to 3);
lrat_tag3_hit_entry        : out std_ulogic_vector(0 to lrat_num_entry_log2-1);
lrat_tag4_lpn              : out std_ulogic_vector(64-real_addr_width to 51);
lrat_tag4_rpn              : out std_ulogic_vector(64-real_addr_width to 51);
lrat_tag4_hit_status       : out std_ulogic_vector(0 to 3);
lrat_tag4_hit_entry        : out std_ulogic_vector(0 to lrat_num_entry_log2-1);
lrat_dbg_tag1_addr_enable    : out  std_ulogic;
lrat_dbg_tag2_matchline_q    : out  std_ulogic_vector(0 to 7);
lrat_dbg_entry0_addr_match   : out  std_ulogic;
lrat_dbg_entry0_lpid_match   : out  std_ulogic;
lrat_dbg_entry0_entry_v      : out  std_ulogic;
lrat_dbg_entry0_entry_x      : out  std_ulogic;
lrat_dbg_entry0_size         : out  std_ulogic_vector(0 to 3);
lrat_dbg_entry1_addr_match   : out  std_ulogic;
lrat_dbg_entry1_lpid_match   : out  std_ulogic;
lrat_dbg_entry1_entry_v      : out  std_ulogic;
lrat_dbg_entry1_entry_x      : out  std_ulogic;
lrat_dbg_entry1_size         : out  std_ulogic_vector(0 to 3);
lrat_dbg_entry2_addr_match   : out  std_ulogic;
lrat_dbg_entry2_lpid_match   : out  std_ulogic;
lrat_dbg_entry2_entry_v      : out  std_ulogic;
lrat_dbg_entry2_entry_x      : out  std_ulogic;
lrat_dbg_entry2_size         : out  std_ulogic_vector(0 to 3);
lrat_dbg_entry3_addr_match   : out  std_ulogic;
lrat_dbg_entry3_lpid_match   : out  std_ulogic;
lrat_dbg_entry3_entry_v      : out  std_ulogic;
lrat_dbg_entry3_entry_x      : out  std_ulogic;
lrat_dbg_entry3_size         : out  std_ulogic_vector(0 to 3);
lrat_dbg_entry4_addr_match   : out  std_ulogic;
lrat_dbg_entry4_lpid_match   : out  std_ulogic;
lrat_dbg_entry4_entry_v      : out  std_ulogic;
lrat_dbg_entry4_entry_x      : out  std_ulogic;
lrat_dbg_entry4_size         : out  std_ulogic_vector(0 to 3);
lrat_dbg_entry5_addr_match   : out  std_ulogic;
lrat_dbg_entry5_lpid_match   : out  std_ulogic;
lrat_dbg_entry5_entry_v      : out  std_ulogic;
lrat_dbg_entry5_entry_x      : out  std_ulogic;
lrat_dbg_entry5_size         : out  std_ulogic_vector(0 to 3);
lrat_dbg_entry6_addr_match   : out  std_ulogic;
lrat_dbg_entry6_lpid_match   : out  std_ulogic;
lrat_dbg_entry6_entry_v      : out  std_ulogic;
lrat_dbg_entry6_entry_x      : out  std_ulogic;
lrat_dbg_entry6_size         : out  std_ulogic_vector(0 to 3);
lrat_dbg_entry7_addr_match   : out  std_ulogic;
lrat_dbg_entry7_lpid_match   : out  std_ulogic;
lrat_dbg_entry7_entry_v      : out  std_ulogic;
lrat_dbg_entry7_entry_x      : out  std_ulogic;
lrat_dbg_entry7_size         : out  std_ulogic_vector(0 to 3)
);
end mmq_tlb_lrat;
ARCHITECTURE MMQ_TLB_LRAT
          OF MMQ_TLB_LRAT
          IS
component mmq_tlb_lrat_matchline
  generic (real_addr_width     : integer := 42;
             lpid_width           : integer := 8;
             lrat_maxsize_log2    : integer := 40;  
             lrat_minsize_log2    : integer := 20;  
             have_xbit            : integer := 1;
             num_pgsizes          : integer := 8;
             have_cmpmask         : integer := 1;
             cmpmask_width        : integer := 7);
port(
    vdd                              : inout power_logic;
    gnd                              : inout power_logic;
    addr_in                          : in std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
    addr_enable                      : in std_ulogic;
    entry_size                       : in std_ulogic_vector(0 to 3);
    entry_cmpmask                    : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_xbit                       : in std_ulogic;
    entry_xbitmask                   : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_lpn                        : in std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
    entry_lpid                       : in std_ulogic_vector(0 to lpid_width-1);
    comp_lpid                        : in std_ulogic_vector(0 to lpid_width-1);
    lpid_enable                      : in std_ulogic;
    entry_v                          : in std_ulogic;

    match                            : out std_ulogic;
    dbg_addr_match       : out  std_ulogic;
    dbg_lpid_match       : out  std_ulogic
);
end component;
constant MMU_Mode_Value : std_ulogic := '0';
constant TLB_PgSize_1GB   : std_ulogic_vector(0 to 3) := "1010";
constant TLB_PgSize_256MB : std_ulogic_vector(0 to 3) := "1001";
constant TLB_PgSize_16MB  : std_ulogic_vector(0 to 3) := "0111";
constant TLB_PgSize_1MB   : std_ulogic_vector(0 to 3) := "0101";
constant TLB_PgSize_64KB  : std_ulogic_vector(0 to 3) := "0011";
constant TLB_PgSize_4KB   : std_ulogic_vector(0 to 3) := "0001";
constant LRAT_PgSize_1TB   : std_ulogic_vector(0 to 3) := "1111";
constant LRAT_PgSize_256GB : std_ulogic_vector(0 to 3) := "1110";
constant LRAT_PgSize_16GB  : std_ulogic_vector(0 to 3) := "1100";
constant LRAT_PgSize_4GB   : std_ulogic_vector(0 to 3) := "1011";
constant LRAT_PgSize_1GB   : std_ulogic_vector(0 to 3) := "1010";
constant LRAT_PgSize_256MB : std_ulogic_vector(0 to 3) := "1001";
constant LRAT_PgSize_16MB  : std_ulogic_vector(0 to 3) := "0111";
constant LRAT_PgSize_1MB   : std_ulogic_vector(0 to 3) := "0101";
constant LRAT_PgSize_1TB_log2   : integer := 40;
constant LRAT_PgSize_256GB_log2 : integer := 38;
constant LRAT_PgSize_16GB_log2  : integer := 34;
constant LRAT_PgSize_4GB_log2   : integer := 32;
constant LRAT_PgSize_1GB_log2   : integer := 30;
constant LRAT_PgSize_256MB_log2 : integer := 28;
constant LRAT_PgSize_16MB_log2  : integer := 24;
constant LRAT_PgSize_1MB_log2   : integer := 20;
-- derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
constant tagpos_type           : natural  := 0;
constant tagpos_type_derat     : natural  := tagpos_type;
constant tagpos_type_ierat     : natural  := tagpos_type+1;
constant tagpos_type_tlbsx     : natural  := tagpos_type+2;
constant tagpos_type_tlbsrx    : natural  := tagpos_type+3;
constant tagpos_type_snoop     : natural  := tagpos_type+4;
constant tagpos_type_tlbre     : natural  := tagpos_type+5;
constant tagpos_type_tlbwe     : natural  := tagpos_type+6;
constant tagpos_type_ptereload : natural  := tagpos_type+7;
-- scan path constants
constant ex4_valid_offset : natural  := 0;
constant ex4_ttype_offset : natural  := ex4_valid_offset + thdid_width;
constant ex5_valid_offset : natural  := ex4_ttype_offset + ttype_width;
constant ex5_ttype_offset : natural  := ex5_valid_offset + thdid_width;
constant ex5_esel_offset  : natural  := ex5_ttype_offset + ttype_width;
constant ex5_atsel_offset : natural  := ex5_esel_offset + 3;
constant ex5_wq_offset    : natural  := ex5_atsel_offset + 1;
constant ex5_hes_offset   : natural  := ex5_wq_offset + 2;
constant ex6_valid_offset : natural  := ex5_hes_offset + 1;
constant ex6_ttype_offset : natural  := ex6_valid_offset + thdid_width;
constant ex6_esel_offset  : natural  := ex6_ttype_offset + ttype_width;
constant ex6_atsel_offset : natural  := ex6_esel_offset + 3;
constant ex6_wq_offset    : natural  := ex6_atsel_offset + 1;
constant ex6_hes_offset   : natural  := ex6_wq_offset + 2;
constant lrat_tag1_lpn_offset         : natural := ex6_hes_offset + 1;
constant lrat_tag2_lpn_offset         : natural := lrat_tag1_lpn_offset + rpn_width;
constant lrat_tag3_lpn_offset         : natural := lrat_tag2_lpn_offset + rpn_width;
constant lrat_tag3_rpn_offset         : natural := lrat_tag3_lpn_offset + rpn_width;
constant lrat_tag4_lpn_offset         : natural := lrat_tag3_rpn_offset + rpn_width;
constant lrat_tag4_rpn_offset         : natural := lrat_tag4_lpn_offset + rpn_width;
constant lrat_tag1_lpid_offset        : natural := lrat_tag4_rpn_offset + rpn_width;
constant lrat_tag1_size_offset        : natural := lrat_tag1_lpid_offset + lpid_width;
constant lrat_tag2_size_offset        : natural := lrat_tag1_size_offset + 4;
constant lrat_tag2_entry_size_offset  : natural := lrat_tag2_size_offset + 4;
constant lrat_tag2_matchline_offset   : natural := lrat_tag2_entry_size_offset + 4;
constant lrat_tag3_hit_status_offset  : natural := lrat_tag2_matchline_offset + lrat_num_entry;
constant lrat_tag3_hit_entry_offset   : natural := lrat_tag3_hit_status_offset + 4;
constant lrat_tag4_hit_status_offset  : natural := lrat_tag3_hit_entry_offset + lrat_num_entry_log2;
constant lrat_tag4_hit_entry_offset   : natural := lrat_tag4_hit_status_offset + 4;
constant tlb_addr_cap_offset          : natural := lrat_tag4_hit_entry_offset + lrat_num_entry_log2;
constant lrat_entry0_lpn_offset   : natural := tlb_addr_cap_offset + 2;
constant lrat_entry0_rpn_offset   : natural := lrat_entry0_lpn_offset + real_addr_width - lrat_minsize_log2;
constant lrat_entry0_lpid_offset  : natural := lrat_entry0_rpn_offset + real_addr_width - lrat_minsize_log2;
constant lrat_entry0_size_offset  : natural := lrat_entry0_lpid_offset + lpid_width;
constant lrat_entry0_cmpmask_offset  : natural := lrat_entry0_size_offset + 4;
constant lrat_entry0_xbitmask_offset : natural := lrat_entry0_cmpmask_offset + 7;
constant lrat_entry0_xbit_offset  : natural := lrat_entry0_xbitmask_offset + 7;
constant lrat_entry0_valid_offset : natural := lrat_entry0_xbit_offset + 1;
constant lrat_entry1_lpn_offset     : natural := lrat_entry0_valid_offset     + 1;
constant lrat_entry1_rpn_offset     : natural := lrat_entry1_lpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry1_lpid_offset    : natural := lrat_entry1_rpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry1_size_offset    : natural := lrat_entry1_lpid_offset   + lpid_width;
constant lrat_entry1_cmpmask_offset    : natural := lrat_entry1_size_offset   + 4;
constant lrat_entry1_xbitmask_offset   : natural := lrat_entry1_cmpmask_offset   + 7;
constant lrat_entry1_xbit_offset    : natural := lrat_entry1_xbitmask_offset   + 7;
constant lrat_entry1_valid_offset   : natural := lrat_entry1_xbit_offset   + 1;
constant lrat_entry2_lpn_offset     : natural := lrat_entry1_valid_offset     + 1;
constant lrat_entry2_rpn_offset     : natural := lrat_entry2_lpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry2_lpid_offset    : natural := lrat_entry2_rpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry2_size_offset    : natural := lrat_entry2_lpid_offset   + lpid_width;
constant lrat_entry2_cmpmask_offset    : natural := lrat_entry2_size_offset   + 4;
constant lrat_entry2_xbitmask_offset   : natural := lrat_entry2_cmpmask_offset   + 7;
constant lrat_entry2_xbit_offset    : natural := lrat_entry2_xbitmask_offset   + 7;
constant lrat_entry2_valid_offset   : natural := lrat_entry2_xbit_offset   + 1;
constant lrat_entry3_lpn_offset     : natural := lrat_entry2_valid_offset     + 1;
constant lrat_entry3_rpn_offset     : natural := lrat_entry3_lpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry3_lpid_offset    : natural := lrat_entry3_rpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry3_size_offset    : natural := lrat_entry3_lpid_offset   + lpid_width;
constant lrat_entry3_cmpmask_offset    : natural := lrat_entry3_size_offset   + 4;
constant lrat_entry3_xbitmask_offset   : natural := lrat_entry3_cmpmask_offset   + 7;
constant lrat_entry3_xbit_offset    : natural := lrat_entry3_xbitmask_offset   + 7;
constant lrat_entry3_valid_offset   : natural := lrat_entry3_xbit_offset   + 1;
constant lrat_entry4_lpn_offset     : natural := lrat_entry3_valid_offset     + 1;
constant lrat_entry4_rpn_offset     : natural := lrat_entry4_lpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry4_lpid_offset    : natural := lrat_entry4_rpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry4_size_offset    : natural := lrat_entry4_lpid_offset   + lpid_width;
constant lrat_entry4_cmpmask_offset    : natural := lrat_entry4_size_offset   + 4;
constant lrat_entry4_xbitmask_offset   : natural := lrat_entry4_cmpmask_offset   + 7;
constant lrat_entry4_xbit_offset    : natural := lrat_entry4_xbitmask_offset   + 7;
constant lrat_entry4_valid_offset   : natural := lrat_entry4_xbit_offset   + 1;
constant lrat_entry5_lpn_offset     : natural := lrat_entry4_valid_offset     + 1;
constant lrat_entry5_rpn_offset     : natural := lrat_entry5_lpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry5_lpid_offset    : natural := lrat_entry5_rpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry5_size_offset    : natural := lrat_entry5_lpid_offset   + lpid_width;
constant lrat_entry5_cmpmask_offset    : natural := lrat_entry5_size_offset   + 4;
constant lrat_entry5_xbitmask_offset   : natural := lrat_entry5_cmpmask_offset   + 7;
constant lrat_entry5_xbit_offset    : natural := lrat_entry5_xbitmask_offset   + 7;
constant lrat_entry5_valid_offset   : natural := lrat_entry5_xbit_offset   + 1;
constant lrat_entry6_lpn_offset     : natural := lrat_entry5_valid_offset     + 1;
constant lrat_entry6_rpn_offset     : natural := lrat_entry6_lpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry6_lpid_offset    : natural := lrat_entry6_rpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry6_size_offset    : natural := lrat_entry6_lpid_offset   + lpid_width;
constant lrat_entry6_cmpmask_offset    : natural := lrat_entry6_size_offset   + 4;
constant lrat_entry6_xbitmask_offset   : natural := lrat_entry6_cmpmask_offset   + 7;
constant lrat_entry6_xbit_offset    : natural := lrat_entry6_xbitmask_offset   + 7;
constant lrat_entry6_valid_offset   : natural := lrat_entry6_xbit_offset   + 1;
constant lrat_entry7_lpn_offset     : natural := lrat_entry6_valid_offset     + 1;
constant lrat_entry7_rpn_offset     : natural := lrat_entry7_lpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry7_lpid_offset    : natural := lrat_entry7_rpn_offset   + real_addr_width - lrat_minsize_log2;
constant lrat_entry7_size_offset    : natural := lrat_entry7_lpid_offset   + lpid_width;
constant lrat_entry7_cmpmask_offset    : natural := lrat_entry7_size_offset   + 4;
constant lrat_entry7_xbitmask_offset   : natural := lrat_entry7_cmpmask_offset   + 7;
constant lrat_entry7_xbit_offset    : natural := lrat_entry7_xbitmask_offset   + 7;
constant lrat_entry7_valid_offset   : natural := lrat_entry7_xbit_offset   + 1;
constant lrat_datain_lpn_offset     : natural := lrat_entry7_valid_offset + 1;
constant lrat_datain_rpn_offset     : natural := lrat_datain_lpn_offset + real_addr_width - lrat_minsize_log2;
constant lrat_datain_lpid_offset    : natural := lrat_datain_rpn_offset + real_addr_width - lrat_minsize_log2;
constant lrat_datain_size_offset    : natural := lrat_datain_lpid_offset + lpid_width;
constant lrat_datain_xbit_offset    : natural := lrat_datain_size_offset + 4;
constant lrat_datain_valid_offset   : natural := lrat_datain_xbit_offset + 1;
constant lrat_mas1_v_offset          :  natural := lrat_datain_valid_offset + 1;
constant lrat_mas1_tsize_offset      :  natural := lrat_mas1_v_offset + 1;
constant lrat_mas2_epn_offset        :  natural := lrat_mas1_tsize_offset + 4;
constant lrat_mas3_rpnl_offset       :  natural := lrat_mas2_epn_offset + rpn_width;
constant lrat_mas7_rpnu_offset       :  natural := lrat_mas3_rpnl_offset + 20;
constant lrat_mas8_tlpid_offset      :  natural := lrat_mas7_rpnu_offset + 10;
constant lrat_mas_tlbre_offset       :  natural := lrat_mas8_tlpid_offset  + lpid_width;
constant lrat_mas_tlbsx_hit_offset   :  natural := lrat_mas_tlbre_offset + 1;
constant lrat_mas_tlbsx_miss_offset  :  natural := lrat_mas_tlbsx_hit_offset + 1;
constant lrat_mas_thdid_offset       :  natural := lrat_mas_tlbsx_miss_offset + 1;
constant lrat_mmucr3_x_offset        :  natural := lrat_mas_thdid_offset + thdid_width;
constant lrat_entry_act_offset       : natural := lrat_mmucr3_x_offset + 1;
constant lrat_mas_act_offset         : natural := lrat_entry_act_offset + 8;
constant lrat_datain_act_offset      : natural := lrat_mas_act_offset +3;
constant spare_offset                 : natural := lrat_datain_act_offset +2;
constant scan_right                 : natural := spare_offset + 64 -1;
constant const_lrat_maxsize_log2 : natural := real_addr_width-2;
-- Latch signals
signal ex4_valid_d, ex4_valid_q : std_ulogic_vector(0 to thdid_width-1);
signal ex4_ttype_d, ex4_ttype_q : std_ulogic_vector(0 to ttype_width-1);
signal ex5_valid_d, ex5_valid_q : std_ulogic_vector(0 to thdid_width-1);
signal ex5_ttype_d, ex5_ttype_q : std_ulogic_vector(0 to ttype_width-1);
signal ex5_esel_d, ex5_esel_q   : std_ulogic_vector(0 to 2);
signal ex5_atsel_d, ex5_atsel_q : std_ulogic;
signal ex5_hes_d, ex5_hes_q     : std_ulogic;
signal ex5_wq_d, ex5_wq_q       : std_ulogic_vector(0 to 1);
signal ex6_valid_d, ex6_valid_q : std_ulogic_vector(0 to thdid_width-1);
signal ex6_ttype_d, ex6_ttype_q : std_ulogic_vector(0 to ttype_width-1);
signal ex6_esel_d, ex6_esel_q   : std_ulogic_vector(0 to 2);
signal ex6_atsel_d, ex6_atsel_q : std_ulogic;
signal ex6_hes_d, ex6_hes_q     : std_ulogic;
signal ex6_wq_d, ex6_wq_q       : std_ulogic_vector(0 to 1);
signal lrat_tag1_lpn_d, lrat_tag1_lpn_q    : std_ulogic_vector(64-real_addr_width to 51);
signal lrat_tag2_lpn_d, lrat_tag2_lpn_q    : std_ulogic_vector(64-real_addr_width to 51);
signal lrat_tag3_lpn_d, lrat_tag3_lpn_q    : std_ulogic_vector(64-real_addr_width to 51);
signal lrat_tag3_rpn_d, lrat_tag3_rpn_q    : std_ulogic_vector(64-real_addr_width to 51);
signal lrat_tag4_lpn_d, lrat_tag4_lpn_q    : std_ulogic_vector(64-real_addr_width to 51);
signal lrat_tag4_rpn_d, lrat_tag4_rpn_q    : std_ulogic_vector(64-real_addr_width to 51);
signal lrat_tag1_lpid_d, lrat_tag1_lpid_q  : std_ulogic_vector(0 to lpid_width-1);
signal lrat_tag2_matchline_d, lrat_tag2_matchline_q    : std_ulogic_vector(0 to lrat_num_entry-1);
signal lrat_tag1_size_d, lrat_tag1_size_q   : std_ulogic_vector(0 to 3);
signal lrat_tag2_size_d, lrat_tag2_size_q   : std_ulogic_vector(0 to 3);
signal lrat_tag2_entry_size_d, lrat_tag2_entry_size_q    : std_ulogic_vector(0 to 3);
signal lrat_tag3_hit_status_d, lrat_tag3_hit_status_q    : std_ulogic_vector(0 to 3);
signal lrat_tag3_hit_entry_d, lrat_tag3_hit_entry_q    : std_ulogic_vector(0 to lrat_num_entry_log2-1);
signal lrat_tag4_hit_status_d, lrat_tag4_hit_status_q    : std_ulogic_vector(0 to 3);
signal lrat_tag4_hit_entry_d, lrat_tag4_hit_entry_q    : std_ulogic_vector(0 to lrat_num_entry_log2-1);
signal tlb_addr_cap_d, tlb_addr_cap_q  : std_ulogic_vector(1 to 2);
signal lrat_entry0_lpn_d,   lrat_entry0_lpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry0_rpn_d,   lrat_entry0_rpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry0_lpid_d,   lrat_entry0_lpid_q    : std_ulogic_vector(0 to lpid_width-1);
signal lrat_entry0_size_d,   lrat_entry0_size_q    : std_ulogic_vector(0 to 3);
signal lrat_entry0_cmpmask_d,   lrat_entry0_cmpmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry0_xbitmask_d,   lrat_entry0_xbitmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry0_xbit_d,   lrat_entry0_xbit_q    : std_ulogic;
signal lrat_entry0_valid_d,   lrat_entry0_valid_q    : std_ulogic;
signal lrat_entry1_lpn_d,   lrat_entry1_lpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry1_rpn_d,   lrat_entry1_rpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry1_lpid_d,   lrat_entry1_lpid_q    : std_ulogic_vector(0 to lpid_width-1);
signal lrat_entry1_size_d,   lrat_entry1_size_q    : std_ulogic_vector(0 to 3);
signal lrat_entry1_cmpmask_d,   lrat_entry1_cmpmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry1_xbitmask_d,   lrat_entry1_xbitmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry1_xbit_d,   lrat_entry1_xbit_q    : std_ulogic;
signal lrat_entry1_valid_d,   lrat_entry1_valid_q    : std_ulogic;
signal lrat_entry2_lpn_d,   lrat_entry2_lpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry2_rpn_d,   lrat_entry2_rpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry2_lpid_d,   lrat_entry2_lpid_q    : std_ulogic_vector(0 to lpid_width-1);
signal lrat_entry2_size_d,   lrat_entry2_size_q    : std_ulogic_vector(0 to 3);
signal lrat_entry2_cmpmask_d,   lrat_entry2_cmpmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry2_xbitmask_d,   lrat_entry2_xbitmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry2_xbit_d,   lrat_entry2_xbit_q    : std_ulogic;
signal lrat_entry2_valid_d,   lrat_entry2_valid_q    : std_ulogic;
signal lrat_entry3_lpn_d,   lrat_entry3_lpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry3_rpn_d,   lrat_entry3_rpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry3_lpid_d,   lrat_entry3_lpid_q    : std_ulogic_vector(0 to lpid_width-1);
signal lrat_entry3_size_d,   lrat_entry3_size_q    : std_ulogic_vector(0 to 3);
signal lrat_entry3_cmpmask_d,   lrat_entry3_cmpmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry3_xbitmask_d,   lrat_entry3_xbitmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry3_xbit_d,   lrat_entry3_xbit_q    : std_ulogic;
signal lrat_entry3_valid_d,   lrat_entry3_valid_q    : std_ulogic;
signal lrat_entry4_lpn_d,   lrat_entry4_lpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry4_rpn_d,   lrat_entry4_rpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry4_lpid_d,   lrat_entry4_lpid_q    : std_ulogic_vector(0 to lpid_width-1);
signal lrat_entry4_size_d,   lrat_entry4_size_q    : std_ulogic_vector(0 to 3);
signal lrat_entry4_cmpmask_d,   lrat_entry4_cmpmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry4_xbitmask_d,   lrat_entry4_xbitmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry4_xbit_d,   lrat_entry4_xbit_q    : std_ulogic;
signal lrat_entry4_valid_d,   lrat_entry4_valid_q    : std_ulogic;
signal lrat_entry5_lpn_d,   lrat_entry5_lpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry5_rpn_d,   lrat_entry5_rpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry5_lpid_d,   lrat_entry5_lpid_q    : std_ulogic_vector(0 to lpid_width-1);
signal lrat_entry5_size_d,   lrat_entry5_size_q    : std_ulogic_vector(0 to 3);
signal lrat_entry5_cmpmask_d,   lrat_entry5_cmpmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry5_xbitmask_d,   lrat_entry5_xbitmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry5_xbit_d,   lrat_entry5_xbit_q    : std_ulogic;
signal lrat_entry5_valid_d,   lrat_entry5_valid_q    : std_ulogic;
signal lrat_entry6_lpn_d,   lrat_entry6_lpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry6_rpn_d,   lrat_entry6_rpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry6_lpid_d,   lrat_entry6_lpid_q    : std_ulogic_vector(0 to lpid_width-1);
signal lrat_entry6_size_d,   lrat_entry6_size_q    : std_ulogic_vector(0 to 3);
signal lrat_entry6_cmpmask_d,   lrat_entry6_cmpmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry6_xbitmask_d,   lrat_entry6_xbitmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry6_xbit_d,   lrat_entry6_xbit_q    : std_ulogic;
signal lrat_entry6_valid_d,   lrat_entry6_valid_q    : std_ulogic;
signal lrat_entry7_lpn_d,   lrat_entry7_lpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry7_rpn_d,   lrat_entry7_rpn_q    : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_entry7_lpid_d,   lrat_entry7_lpid_q    : std_ulogic_vector(0 to lpid_width-1);
signal lrat_entry7_size_d,   lrat_entry7_size_q    : std_ulogic_vector(0 to 3);
signal lrat_entry7_cmpmask_d,   lrat_entry7_cmpmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry7_xbitmask_d,   lrat_entry7_xbitmask_q    : std_ulogic_vector(0 to 6);
signal lrat_entry7_xbit_d,   lrat_entry7_xbit_q    : std_ulogic;
signal lrat_entry7_valid_d,   lrat_entry7_valid_q    : std_ulogic;
signal lrat_datain_lpn_d, lrat_datain_lpn_q      : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_datain_rpn_d, lrat_datain_rpn_q      : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
signal lrat_datain_lpid_d, lrat_datain_lpid_q    : std_ulogic_vector(0 to lpid_width-1);
signal lrat_datain_size_d, lrat_datain_size_q    : std_ulogic_vector(0 to 3);
signal lrat_datain_xbit_d, lrat_datain_xbit_q    : std_ulogic;
signal lrat_datain_valid_d, lrat_datain_valid_q  : std_ulogic;
signal lrat_mas1_v_d, lrat_mas1_v_q              :  std_ulogic;
signal lrat_mas1_tsize_d, lrat_mas1_tsize_q      :  std_ulogic_vector(0 to 3);
signal lrat_mas2_epn_d,lrat_mas2_epn_q           :  std_ulogic_vector(64-real_addr_width to 51);
signal lrat_mas3_rpnl_d,lrat_mas3_rpnl_q         :  std_ulogic_vector(32 to 51);
signal lrat_mas7_rpnu_d, lrat_mas7_rpnu_q        :  std_ulogic_vector(22 to 31);
signal lrat_mas8_tlpid_d, lrat_mas8_tlpid_q      :  std_ulogic_vector(0 to lpid_width-1);
signal lrat_mas_tlbre_d, lrat_mas_tlbre_q        :  std_ulogic;
signal lrat_mas_tlbsx_hit_d, lrat_mas_tlbsx_hit_q        :  std_ulogic;
signal lrat_mas_tlbsx_miss_d, lrat_mas_tlbsx_miss_q      :  std_ulogic;
signal lrat_mas_thdid_d, lrat_mas_thdid_q        :  std_ulogic_vector(0 to thdid_width-1);
signal lrat_mmucr3_x_d, lrat_mmucr3_x_q          :  std_ulogic;
signal lrat_entry_act_d, lrat_entry_act_q  : std_ulogic_vector(0 to 7);
signal lrat_mas_act_d, lrat_mas_act_q  : std_ulogic_vector(0 to 2);
signal lrat_datain_act_d, lrat_datain_act_q  : std_ulogic_vector(0 to 1);
signal spare_q  : std_ulogic_vector(0 to 63);
-- Logic signals
signal multihit         : std_ulogic;
signal addr_enable      : std_ulogic;
signal lpid_enable      : std_ulogic;
signal lrat_supp_pgsize : std_ulogic;
signal lrat_tag2_size_gt_entry_size : std_ulogic;
signal lrat_tag1_matchline : std_ulogic_vector(0 to lrat_num_entry-1);
signal lrat_entry0_addr_match         :  std_ulogic;
signal lrat_entry0_lpid_match         :  std_ulogic;
signal lrat_entry1_addr_match         :  std_ulogic;
signal lrat_entry1_lpid_match         :  std_ulogic;
signal lrat_entry2_addr_match         :  std_ulogic;
signal lrat_entry2_lpid_match         :  std_ulogic;
signal lrat_entry3_addr_match         :  std_ulogic;
signal lrat_entry3_lpid_match         :  std_ulogic;
signal lrat_entry4_addr_match         :  std_ulogic;
signal lrat_entry4_lpid_match         :  std_ulogic;
signal lrat_entry5_addr_match         :  std_ulogic;
signal lrat_entry5_lpid_match         :  std_ulogic;
signal lrat_entry6_addr_match         :  std_ulogic;
signal lrat_entry6_lpid_match         :  std_ulogic;
signal lrat_entry7_addr_match         :  std_ulogic;
signal lrat_entry7_lpid_match         :  std_ulogic;
signal unused_dc  :  std_ulogic_vector(0 to 13);
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
signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);
signal tiup                     : std_ulogic;
  BEGIN --@@ START OF EXECUTABLE CODE FOR MMQ_TLB_LRAT

tiup  <=  '1';
-- tag0 phase signals, tlbwe/re ex2, tlbsx/srx ex3
tlb_addr_cap_d(1) <=  tlb_tag0_addr_cap and ((tlb_tag0_type(tagpos_type_tlbsx) and tlb_tag0_atsel) or 
                                    tlb_tag0_type(tagpos_type_ptereload) or tlb_tag0_type(tagpos_type_tlbwe));
lrat_tag1_size_d  <=  tlb_tag0_size when tlb_tag0_addr_cap='1' 
                else lrat_tag1_size_q;
gen32_lrat_tag1_lpn: if real_addr_width < 33 generate
lrat_tag1_lpn_d  <=  tlb_tag0_epn(64-real_addr_width to 51) when (tlb_tag0_addr_cap='1' and tlb_tag0_type(tagpos_type_tlbsx)='1')
              else pte_tag0_lpn(64-real_addr_width to 51) when (tlb_tag0_addr_cap='1' and tlb_tag0_type(tagpos_type_ptereload)='1')
              else mas3_3_rpnl when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(3)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else mas3_2_rpnl when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(2)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else mas3_1_rpnl when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(1)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else mas3_0_rpnl when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(0)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else lrat_tag1_lpn_q;
end generate gen32_lrat_tag1_lpn;
gen64_lrat_tag1_lpn: if real_addr_width > 32 generate
lrat_tag1_lpn_d  <=  tlb_tag0_epn(64-real_addr_width to 51) when (tlb_tag0_addr_cap='1' and tlb_tag0_type(tagpos_type_tlbsx)='1')
              else pte_tag0_lpn(64-real_addr_width to 51) when (tlb_tag0_addr_cap='1' and tlb_tag0_type(tagpos_type_ptereload)='1')
              else mas7_3_rpnu(64-real_addr_width to 31) & mas3_3_rpnl when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(3)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else mas7_2_rpnu(64-real_addr_width to 31) & mas3_2_rpnl when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(2)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else mas7_1_rpnu(64-real_addr_width to 31) & mas3_1_rpnl when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(1)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else mas7_0_rpnu(64-real_addr_width to 31) & mas3_0_rpnl when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(0)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else lrat_tag1_lpn_q;
end generate gen64_lrat_tag1_lpn;
lrat_tag1_lpid_d  <=  tlb_tag0_lpid when (tlb_tag0_addr_cap='1' and tlb_tag0_type(tagpos_type_tlbsx)='1')
              else pte_tag0_lpid when (tlb_tag0_addr_cap='1' and tlb_tag0_type(tagpos_type_ptereload)='1')
              else mas8_3_tlpid when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(3)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else mas8_2_tlpid when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(2)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else mas8_1_tlpid when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(1)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else mas8_0_tlpid when (tlb_tag0_addr_cap='1' and tlb_tag0_thdid(0)='1' and tlb_tag0_type(tagpos_type_tlbwe)='1')
              else lrat_tag1_lpid_q;
-- tag1 phase signals, tlbwe/re ex3, tlbsx/srx ex4
ex4_valid_d  <=  tlb_ctl_ex3_valid and not(xu_ex3_flush);
ex4_ttype_d  <=  tlb_ctl_ex3_ttype;
addr_enable  <=  tlb_addr_cap_q(1);
lpid_enable  <=  tlb_addr_cap_q(1);
tlb_addr_cap_d(2) <=  tlb_addr_cap_q(1);
lrat_tag2_lpn_d  <=  lrat_tag1_lpn_q;
lrat_tag2_matchline_d  <=  lrat_tag1_matchline;
lrat_tag2_size_d  <=  lrat_tag1_size_q;
lrat_tag2_entry_size_d  <=                      
                 (lrat_entry0_size_q   and (0 to 3 => lrat_tag1_matchline(0)))   or
                 (lrat_entry1_size_q   and (0 to 3 => lrat_tag1_matchline(1)))   or
                 (lrat_entry2_size_q   and (0 to 3 => lrat_tag1_matchline(2)))   or
                 (lrat_entry3_size_q   and (0 to 3 => lrat_tag1_matchline(3)))   or
                 (lrat_entry4_size_q   and (0 to 3 => lrat_tag1_matchline(4)))   or
                 (lrat_entry5_size_q   and (0 to 3 => lrat_tag1_matchline(5)))   or
                 (lrat_entry6_size_q   and (0 to 3 => lrat_tag1_matchline(6)))   or
                 (lrat_entry7_size_q and (0 to 3 => lrat_tag1_matchline(7)));
-- tag2 phase signals, tlbwe/re ex4, tlbsx/srx ex5
ex5_valid_d  <=  ex4_valid_q and not(xu_ex4_flush);
ex5_ttype_d  <=  ex4_ttype_q;
ex5_esel_d  <=  mas0_1_esel when ex4_valid_q(1)='1' 
         else mas0_2_esel when ex4_valid_q(2)='1'
          else mas0_3_esel when ex4_valid_q(3)='1'
           else mas0_0_esel;
ex5_atsel_d  <=  mas0_1_atsel when ex4_valid_q(1)='1' 
           else mas0_2_atsel when ex4_valid_q(2)='1'
            else mas0_3_atsel when ex4_valid_q(3)='1'
             else mas0_0_atsel;
ex5_hes_d  <=  mas0_1_hes when ex4_valid_q(1)='1' 
           else mas0_2_hes when ex4_valid_q(2)='1'
            else mas0_3_hes when ex4_valid_q(3)='1'
             else mas0_0_hes;
ex5_wq_d  <=  mas0_1_wq when ex4_valid_q(1)='1' 
           else mas0_2_wq when ex4_valid_q(2)='1'
            else mas0_3_wq when ex4_valid_q(3)='1'
             else mas0_0_wq;
lrat_tag3_lpn_d  <=  lrat_tag2_lpn_q;
-- hit_status: val,hit,multihit,inval_pgsize
lrat_tag3_hit_status_d(0) <=  tlb_addr_cap_q(2);
lrat_tag3_hit_status_d(1) <=  tlb_addr_cap_q(2) and or_reduce(lrat_tag2_matchline_q(0 to lrat_num_entry-1));
lrat_tag3_hit_status_d(2) <=  tlb_addr_cap_q(2) and multihit;
lrat_tag3_hit_status_d(3) <=  tlb_addr_cap_q(2) and (not(lrat_supp_pgsize) or lrat_tag2_size_gt_entry_size);
multihit  <=  '0' when (lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00000000" or
                        lrat_tag2_matchline_q(0 to lrat_num_entry-1)="10000000" or                    
                        lrat_tag2_matchline_q(0 to lrat_num_entry-1)="01000000" or                    
                        lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00100000" or                    
                        lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00010000" or                    
                        lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00001000" or                    
                        lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00000100" or                    
                        lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00000010" or                    
                        lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00000001")
        else '1';
lrat_tag3_hit_entry_d  <=     "001" when lrat_tag2_matchline_q(0 to lrat_num_entry-1)="01000000"                     
                       else "010" when lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00100000"                     
                       else "011" when lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00010000"                     
                       else "100" when lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00001000"                     
                       else "101" when lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00000100"                     
                       else "110" when lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00000010"                     
                       else "111" when lrat_tag2_matchline_q(0 to lrat_num_entry-1)="00000001"
                       else "000";
--     constant TLB_PgSize_1GB   : std_ulogic_vector(0 to 3) :=  1010 ;
--     constant TLB_PgSize_256MB : std_ulogic_vector(0 to 3) :=  1001 ;
--     constant TLB_PgSize_16MB  : std_ulogic_vector(0 to 3) :=  0111 ;
--     constant TLB_PgSize_1MB   : std_ulogic_vector(0 to 3) :=  0101 ;
--     constant TLB_PgSize_64KB  : std_ulogic_vector(0 to 3) :=  0011 ;
--     constant TLB_PgSize_4KB   : std_ulogic_vector(0 to 3) :=  0001 ;
-- ISA 2.06 pgsize match criteria for tlbwe:
--   MAS1.IND=0 and MAS1.TSIZE </= LRAT_entry.LSIZE, or
--   MAS1.IND=1 and (3 + (MAS1.TSIZE - MAS3.SPSIZE)) </= (10 + LRAT_entry.LSIZE)
--    the second term above can never happen for A2, 3+9-3 or 3+5-1 is never > 10+5
--      ..in other words, the biggest page table for A2 is 256M/64K=4K entries x 8 bytes = 32K,
--      .. 32K is always less than the minimum supported LRAT size of 1MB.
-- pgsize match criteria for ptereload:
--   PTE.PS </= LRAT_entry.LSIZE
lrat_tag2_size_gt_entry_size  <=  (Eq(lrat_tag2_size_q,TLB_PgSize_16MB) and Eq(lrat_tag2_entry_size_q,LRAT_PgSize_1MB)) or
                           (Eq(lrat_tag2_size_q,TLB_PgSize_1GB)   and Eq(lrat_tag2_entry_size_q,LRAT_PgSize_1MB)) or
                           (Eq(lrat_tag2_size_q,TLB_PgSize_1GB)   and Eq(lrat_tag2_entry_size_q,LRAT_PgSize_16MB)) or
                           (Eq(lrat_tag2_size_q,TLB_PgSize_1GB)   and Eq(lrat_tag2_entry_size_q,LRAT_PgSize_256MB));
lrat_supp_pgsize  <=  '1' when (lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or
                                 lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                 lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB or
                                 lrat_tag2_entry_size_q=LRAT_PgSize_256GB or lrat_tag2_entry_size_q=LRAT_PgSize_1TB)
                 else '0';
--constant LRAT_PgSize_1TB_log2   : integer := 40;
--constant LRAT_PgSize_256GB_log2 : integer := 38;
--constant LRAT_PgSize_16GB_log2  : integer := 34;
--constant LRAT_PgSize_4GB_log2   : integer := 32;
--constant LRAT_PgSize_1GB_log2   : integer := 30;
--constant LRAT_PgSize_256MB_log2 : integer := 28;
--constant LRAT_PgSize_16MB_log2  : integer := 24;
--constant LRAT_PgSize_1MB_log2   : integer := 20;
-- offset forwarding muxes based on page size
-- rpn(44:51)
lrat_tag3_rpn_d(64-LRAT_PgSize_1MB_log2 TO 51) <=  lrat_tag2_lpn_q(64-LRAT_PgSize_1MB_log2 to 51);
-- rpn(40:43)
lrat_tag3_rpn_d(64-LRAT_PgSize_16MB_log2 TO 64-LRAT_PgSize_1MB_log2-1) <=  
                   lrat_entry0_rpn_q(64-LRAT_PgSize_16MB_log2 to 64-LRAT_PgSize_1MB_log2-1) 
                             when (lrat_tag2_entry_size_q=LRAT_PgSize_1MB and lrat_tag2_matchline_q(0)='1')
             else lrat_entry1_rpn_q(64-LRAT_PgSize_16MB_log2   to 64-LRAT_PgSize_1MB_log2-1) 
                             when (lrat_tag2_entry_size_q=LRAT_PgSize_1MB and lrat_tag2_matchline_q(1)='1')
             else lrat_entry2_rpn_q(64-LRAT_PgSize_16MB_log2   to 64-LRAT_PgSize_1MB_log2-1) 
                             when (lrat_tag2_entry_size_q=LRAT_PgSize_1MB and lrat_tag2_matchline_q(2)='1')
             else lrat_entry3_rpn_q(64-LRAT_PgSize_16MB_log2   to 64-LRAT_PgSize_1MB_log2-1) 
                             when (lrat_tag2_entry_size_q=LRAT_PgSize_1MB and lrat_tag2_matchline_q(3)='1')
             else lrat_entry4_rpn_q(64-LRAT_PgSize_16MB_log2   to 64-LRAT_PgSize_1MB_log2-1) 
                             when (lrat_tag2_entry_size_q=LRAT_PgSize_1MB and lrat_tag2_matchline_q(4)='1')
             else lrat_entry5_rpn_q(64-LRAT_PgSize_16MB_log2   to 64-LRAT_PgSize_1MB_log2-1) 
                             when (lrat_tag2_entry_size_q=LRAT_PgSize_1MB and lrat_tag2_matchline_q(5)='1')
             else lrat_entry6_rpn_q(64-LRAT_PgSize_16MB_log2   to 64-LRAT_PgSize_1MB_log2-1) 
                             when (lrat_tag2_entry_size_q=LRAT_PgSize_1MB and lrat_tag2_matchline_q(6)='1')
             else lrat_entry7_rpn_q(64-LRAT_PgSize_16MB_log2   to 64-LRAT_PgSize_1MB_log2-1) 
                             when (lrat_tag2_entry_size_q=LRAT_PgSize_1MB and lrat_tag2_matchline_q(7)='1')
             else lrat_tag2_lpn_q(64-LRAT_PgSize_16MB_log2 to 64-LRAT_PgSize_1MB_log2-1);
-- rpn(36:39)
lrat_tag3_rpn_d(64-LRAT_PgSize_256MB_log2 TO 64-LRAT_PgSize_16MB_log2-1) <=  
                   lrat_entry0_rpn_q(64-LRAT_PgSize_256MB_log2 to 64-LRAT_PgSize_16MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB) and lrat_tag2_matchline_q(0)='1')
             else lrat_entry1_rpn_q(64-LRAT_PgSize_256MB_log2   to 64-LRAT_PgSize_16MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB) and lrat_tag2_matchline_q(1)='1')
             else lrat_entry2_rpn_q(64-LRAT_PgSize_256MB_log2   to 64-LRAT_PgSize_16MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB) and lrat_tag2_matchline_q(2)='1')
             else lrat_entry3_rpn_q(64-LRAT_PgSize_256MB_log2   to 64-LRAT_PgSize_16MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB) and lrat_tag2_matchline_q(3)='1')
             else lrat_entry4_rpn_q(64-LRAT_PgSize_256MB_log2   to 64-LRAT_PgSize_16MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB) and lrat_tag2_matchline_q(4)='1')
             else lrat_entry5_rpn_q(64-LRAT_PgSize_256MB_log2   to 64-LRAT_PgSize_16MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB) and lrat_tag2_matchline_q(5)='1')
             else lrat_entry6_rpn_q(64-LRAT_PgSize_256MB_log2   to 64-LRAT_PgSize_16MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB) and lrat_tag2_matchline_q(6)='1')
             else lrat_entry7_rpn_q(64-LRAT_PgSize_256MB_log2   to 64-LRAT_PgSize_16MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB) and lrat_tag2_matchline_q(7)='1')
             else lrat_tag2_lpn_q(64-LRAT_PgSize_256MB_log2 to 64-LRAT_PgSize_16MB_log2-1);
-- rpn(34:35)
lrat_tag3_rpn_d(64-LRAT_PgSize_1GB_log2 TO 64-LRAT_PgSize_256MB_log2-1) <=  
                   lrat_entry0_rpn_q(64-LRAT_PgSize_1GB_log2 to 64-LRAT_PgSize_256MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB) and lrat_tag2_matchline_q(0)='1')
             else lrat_entry1_rpn_q(64-LRAT_PgSize_1GB_log2   to 64-LRAT_PgSize_256MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB) and lrat_tag2_matchline_q(1)='1')
             else lrat_entry2_rpn_q(64-LRAT_PgSize_1GB_log2   to 64-LRAT_PgSize_256MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB) and lrat_tag2_matchline_q(2)='1')
             else lrat_entry3_rpn_q(64-LRAT_PgSize_1GB_log2   to 64-LRAT_PgSize_256MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB) and lrat_tag2_matchline_q(3)='1')
             else lrat_entry4_rpn_q(64-LRAT_PgSize_1GB_log2   to 64-LRAT_PgSize_256MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB) and lrat_tag2_matchline_q(4)='1')
             else lrat_entry5_rpn_q(64-LRAT_PgSize_1GB_log2   to 64-LRAT_PgSize_256MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB) and lrat_tag2_matchline_q(5)='1')
             else lrat_entry6_rpn_q(64-LRAT_PgSize_1GB_log2   to 64-LRAT_PgSize_256MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB) and lrat_tag2_matchline_q(6)='1')
             else lrat_entry7_rpn_q(64-LRAT_PgSize_1GB_log2   to 64-LRAT_PgSize_256MB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB) and lrat_tag2_matchline_q(7)='1')
             else lrat_tag2_lpn_q(64-LRAT_PgSize_1GB_log2 to 64-LRAT_PgSize_256MB_log2-1);
-- rpn(32:33)
lrat_tag3_rpn_d(64-LRAT_PgSize_4GB_log2 TO 64-LRAT_PgSize_1GB_log2-1) <=  
                   lrat_entry0_rpn_q(64-LRAT_PgSize_4GB_log2 to 64-LRAT_PgSize_1GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB) and lrat_tag2_matchline_q(0)='1')
             else lrat_entry1_rpn_q(64-LRAT_PgSize_4GB_log2   to 64-LRAT_PgSize_1GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB) and lrat_tag2_matchline_q(1)='1')
             else lrat_entry2_rpn_q(64-LRAT_PgSize_4GB_log2   to 64-LRAT_PgSize_1GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB) and lrat_tag2_matchline_q(2)='1')
             else lrat_entry3_rpn_q(64-LRAT_PgSize_4GB_log2   to 64-LRAT_PgSize_1GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB) and lrat_tag2_matchline_q(3)='1')
             else lrat_entry4_rpn_q(64-LRAT_PgSize_4GB_log2   to 64-LRAT_PgSize_1GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB) and lrat_tag2_matchline_q(4)='1')
             else lrat_entry5_rpn_q(64-LRAT_PgSize_4GB_log2   to 64-LRAT_PgSize_1GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB) and lrat_tag2_matchline_q(5)='1')
             else lrat_entry6_rpn_q(64-LRAT_PgSize_4GB_log2   to 64-LRAT_PgSize_1GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB) and lrat_tag2_matchline_q(6)='1')
             else lrat_entry7_rpn_q(64-LRAT_PgSize_4GB_log2   to 64-LRAT_PgSize_1GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB) and lrat_tag2_matchline_q(7)='1')
             else lrat_tag2_lpn_q(64-LRAT_PgSize_4GB_log2 to 64-LRAT_PgSize_1GB_log2-1);
gen64_lrat_tag3_rpn_34: if real_addr_width > 33 generate
-- rpn(30:31)
lrat_tag3_rpn_d(64-LRAT_PgSize_16GB_log2 TO 64-LRAT_PgSize_4GB_log2-1) <=  
                   lrat_entry0_rpn_q(64-LRAT_PgSize_16GB_log2 to 64-LRAT_PgSize_4GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB) and lrat_tag2_matchline_q(0)='1')
             else lrat_entry1_rpn_q(64-LRAT_PgSize_16GB_log2   to 64-LRAT_PgSize_4GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB) and lrat_tag2_matchline_q(1)='1')
             else lrat_entry2_rpn_q(64-LRAT_PgSize_16GB_log2   to 64-LRAT_PgSize_4GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB) and lrat_tag2_matchline_q(2)='1')
             else lrat_entry3_rpn_q(64-LRAT_PgSize_16GB_log2   to 64-LRAT_PgSize_4GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB) and lrat_tag2_matchline_q(3)='1')
             else lrat_entry4_rpn_q(64-LRAT_PgSize_16GB_log2   to 64-LRAT_PgSize_4GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB) and lrat_tag2_matchline_q(4)='1')
             else lrat_entry5_rpn_q(64-LRAT_PgSize_16GB_log2   to 64-LRAT_PgSize_4GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB) and lrat_tag2_matchline_q(5)='1')
             else lrat_entry6_rpn_q(64-LRAT_PgSize_16GB_log2   to 64-LRAT_PgSize_4GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB) and lrat_tag2_matchline_q(6)='1')
             else lrat_entry7_rpn_q(64-LRAT_PgSize_16GB_log2   to 64-LRAT_PgSize_4GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB) and lrat_tag2_matchline_q(7)='1')
             else lrat_tag2_lpn_q(64-LRAT_PgSize_16GB_log2 to 64-LRAT_PgSize_4GB_log2-1);
end generate gen64_lrat_tag3_rpn_34;
gen64_lrat_tag3_rpn_38: if real_addr_width > 37 generate
-- rpn(26:29)
lrat_tag3_rpn_d(64-LRAT_PgSize_256GB_log2 TO 64-LRAT_PgSize_16GB_log2-1) <=  
                   lrat_entry0_rpn_q(64-LRAT_PgSize_256GB_log2 to 64-LRAT_PgSize_16GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB) and lrat_tag2_matchline_q(0)='1')
             else lrat_entry1_rpn_q(64-LRAT_PgSize_256GB_log2   to 64-LRAT_PgSize_16GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB) and lrat_tag2_matchline_q(1)='1')
             else lrat_entry2_rpn_q(64-LRAT_PgSize_256GB_log2   to 64-LRAT_PgSize_16GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB) and lrat_tag2_matchline_q(2)='1')
             else lrat_entry3_rpn_q(64-LRAT_PgSize_256GB_log2   to 64-LRAT_PgSize_16GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB) and lrat_tag2_matchline_q(3)='1')
             else lrat_entry4_rpn_q(64-LRAT_PgSize_256GB_log2   to 64-LRAT_PgSize_16GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB) and lrat_tag2_matchline_q(4)='1')
             else lrat_entry5_rpn_q(64-LRAT_PgSize_256GB_log2   to 64-LRAT_PgSize_16GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB) and lrat_tag2_matchline_q(5)='1')
             else lrat_entry6_rpn_q(64-LRAT_PgSize_256GB_log2   to 64-LRAT_PgSize_16GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB) and lrat_tag2_matchline_q(6)='1')
             else lrat_entry7_rpn_q(64-LRAT_PgSize_256GB_log2   to 64-LRAT_PgSize_16GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB) and lrat_tag2_matchline_q(7)='1')
             else lrat_tag2_lpn_q(64-LRAT_PgSize_256GB_log2 to 64-LRAT_PgSize_16GB_log2-1);
end generate gen64_lrat_tag3_rpn_38;
gen64_lrat_tag3_rpn_40: if real_addr_width > 39 generate
-- rpn(24:25)
lrat_tag3_rpn_d(64-LRAT_PgSize_1TB_log2 TO 64-LRAT_PgSize_256GB_log2-1) <=  
                   lrat_entry0_rpn_q(64-LRAT_PgSize_1TB_log2 to 64-LRAT_PgSize_256GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256GB) and lrat_tag2_matchline_q(0)='1')
             else lrat_entry1_rpn_q(64-LRAT_PgSize_1TB_log2   to 64-LRAT_PgSize_256GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256GB) and lrat_tag2_matchline_q(1)='1')
             else lrat_entry2_rpn_q(64-LRAT_PgSize_1TB_log2   to 64-LRAT_PgSize_256GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256GB) and lrat_tag2_matchline_q(2)='1')
             else lrat_entry3_rpn_q(64-LRAT_PgSize_1TB_log2   to 64-LRAT_PgSize_256GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256GB) and lrat_tag2_matchline_q(3)='1')
             else lrat_entry4_rpn_q(64-LRAT_PgSize_1TB_log2   to 64-LRAT_PgSize_256GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256GB) and lrat_tag2_matchline_q(4)='1')
             else lrat_entry5_rpn_q(64-LRAT_PgSize_1TB_log2   to 64-LRAT_PgSize_256GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256GB) and lrat_tag2_matchline_q(5)='1')
             else lrat_entry6_rpn_q(64-LRAT_PgSize_1TB_log2   to 64-LRAT_PgSize_256GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256GB) and lrat_tag2_matchline_q(6)='1')
             else lrat_entry7_rpn_q(64-LRAT_PgSize_1TB_log2   to 64-LRAT_PgSize_256GB_log2-1) 
                             when ((lrat_tag2_entry_size_q=LRAT_PgSize_1MB or lrat_tag2_entry_size_q=LRAT_PgSize_16MB or 
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256MB or lrat_tag2_entry_size_q=LRAT_PgSize_1GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_4GB or lrat_tag2_entry_size_q=LRAT_PgSize_16GB or
                                      lrat_tag2_entry_size_q=LRAT_PgSize_256GB) and lrat_tag2_matchline_q(7)='1')
             else lrat_tag2_lpn_q(64-LRAT_PgSize_1TB_log2 to 64-LRAT_PgSize_256GB_log2-1);
end generate gen64_lrat_tag3_rpn_40;
gen64_lrat_tag3_rpn_42: if real_addr_width > 41 generate
-- rpn(22:23)
lrat_tag3_rpn_d(64-real_addr_width TO 64-lrat_maxsize_log2-1) <=  
                   lrat_entry0_rpn_q(64-real_addr_width to 64-lrat_maxsize_log2-1) when lrat_tag2_matchline_q(0)='1'
             else lrat_entry1_rpn_q(64-real_addr_width   to 64-lrat_maxsize_log2-1) when lrat_tag2_matchline_q(1)='1'
             else lrat_entry2_rpn_q(64-real_addr_width   to 64-lrat_maxsize_log2-1) when lrat_tag2_matchline_q(2)='1'
             else lrat_entry3_rpn_q(64-real_addr_width   to 64-lrat_maxsize_log2-1) when lrat_tag2_matchline_q(3)='1'
             else lrat_entry4_rpn_q(64-real_addr_width   to 64-lrat_maxsize_log2-1) when lrat_tag2_matchline_q(4)='1'
             else lrat_entry5_rpn_q(64-real_addr_width   to 64-lrat_maxsize_log2-1) when lrat_tag2_matchline_q(5)='1'
             else lrat_entry6_rpn_q(64-real_addr_width   to 64-lrat_maxsize_log2-1) when lrat_tag2_matchline_q(6)='1'
             else lrat_entry7_rpn_q(64-real_addr_width   to 64-lrat_maxsize_log2-1) when lrat_tag2_matchline_q(7)='1'
             else lrat_tag2_lpn_q(64-real_addr_width to 64-lrat_maxsize_log2-1);
end generate gen64_lrat_tag3_rpn_42;
--constant LRAT_PgSize_1TB_log2   : integer := 40;
--constant LRAT_PgSize_256GB_log2 : integer := 38;
--constant LRAT_PgSize_16GB_log2  : integer := 34;
--constant LRAT_PgSize_4GB_log2   : integer := 32;
--constant LRAT_PgSize_1GB_log2   : integer := 30;
--constant LRAT_PgSize_256MB_log2 : integer := 28;
--constant LRAT_PgSize_16MB_log2  : integer := 24;
--constant LRAT_PgSize_1MB_log2   : integer := 20;
-- tag3 phase signals, tlbwe/re ex4, tlbsx/srx ex5
ex6_valid_d  <=  ex5_valid_q and not(xu_ex5_flush);
ex6_ttype_d  <=  ex5_ttype_q;
ex6_esel_d   <=  ex5_esel_q;
ex6_atsel_d  <=  ex5_atsel_q;
ex6_hes_d    <=  ex5_hes_q;
ex6_wq_d     <=  ex5_wq_q;
lrat_tag4_lpn_d               <=  lrat_tag3_lpn_q;
lrat_tag4_rpn_d               <=  lrat_tag3_rpn_q;
lrat_tag4_hit_status_d        <=  lrat_tag3_hit_status_q;
lrat_tag4_hit_entry_d         <=  lrat_tag3_hit_entry_q;
lrat_datain_lpn_d  <=  mas2_0_epn(64-real_addr_width to 63-lrat_minsize_log2) when (ex5_valid_q(0)='1')
                else mas2_1_epn(64-real_addr_width   to 63-lrat_minsize_log2) when (ex5_valid_q(1)='1')
                else mas2_2_epn(64-real_addr_width   to 63-lrat_minsize_log2) when (ex5_valid_q(2)='1')
                else mas2_3_epn(64-real_addr_width   to 63-lrat_minsize_log2) when (ex5_valid_q(3)='1')
                else lrat_datain_lpn_q;
gen64_lrat_datain_rpn: if real_addr_width > 32 generate
lrat_datain_rpn_d(64-real_addr_width TO 31) <=  mas7_0_rpnu(64-real_addr_width to 31) when (ex5_valid_q(0)='1')
                else mas7_1_rpnu(64-real_addr_width   to 31) when (ex5_valid_q(1)='1')
                else mas7_2_rpnu(64-real_addr_width   to 31) when (ex5_valid_q(2)='1')
                else mas7_3_rpnu(64-real_addr_width   to 31) when (ex5_valid_q(3)='1')
                else lrat_datain_rpn_q(64-real_addr_width to 31);
end generate gen64_lrat_datain_rpn;
lrat_datain_rpn_d(32 TO 63-lrat_minsize_log2) <=  mas3_0_rpnl(32 to 63-lrat_minsize_log2) when (ex5_valid_q(0)='1')
                else mas3_1_rpnl(32   to 63-lrat_minsize_log2) when (ex5_valid_q(1)='1')
                else mas3_2_rpnl(32   to 63-lrat_minsize_log2) when (ex5_valid_q(2)='1')
                else mas3_3_rpnl(32   to 63-lrat_minsize_log2) when (ex5_valid_q(3)='1')
                else lrat_datain_rpn_q(32 to 63-lrat_minsize_log2);
lrat_datain_lpid_d  <=  mas8_0_tlpid when (ex5_valid_q(0)='1')
                else mas8_1_tlpid   when (ex5_valid_q(1)='1')
                else mas8_2_tlpid   when (ex5_valid_q(2)='1')
                else mas8_3_tlpid   when (ex5_valid_q(3)='1')
                else lrat_datain_lpid_q;
lrat_datain_size_d  <=  mas1_0_tsize when (ex5_valid_q(0)='1')
                else mas1_1_tsize   when (ex5_valid_q(1)='1')
                else mas1_2_tsize   when (ex5_valid_q(2)='1')
                else mas1_3_tsize   when (ex5_valid_q(3)='1')
                else lrat_datain_size_q;
lrat_datain_valid_d  <=  mas1_0_v when (ex5_valid_q(0)='1')
                else mas1_1_v   when (ex5_valid_q(1)='1')
                else mas1_2_v   when (ex5_valid_q(2)='1')
                else mas1_3_v   when (ex5_valid_q(3)='1')
                else lrat_datain_valid_q;
lrat_datain_xbit_d  <=  mmucr3_0_x when (ex5_valid_q(0)='1')
                else mmucr3_1_x   when (ex5_valid_q(1)='1')
                else mmucr3_2_x   when (ex5_valid_q(2)='1')
                else mmucr3_3_x   when (ex5_valid_q(3)='1')
                else lrat_datain_xbit_q;
lrat_mmucr3_x_d  <=  lrat_entry0_xbit_q when (ex5_valid_q/="0000" and ex5_esel_q="000")
            else lrat_entry1_xbit_q   when (ex5_valid_q/="0000" and ex5_esel_q="001")
            else lrat_entry2_xbit_q   when (ex5_valid_q/="0000" and ex5_esel_q="010")
            else lrat_entry3_xbit_q   when (ex5_valid_q/="0000" and ex5_esel_q="011")
            else lrat_entry4_xbit_q   when (ex5_valid_q/="0000" and ex5_esel_q="100")
            else lrat_entry5_xbit_q   when (ex5_valid_q/="0000" and ex5_esel_q="101")
            else lrat_entry6_xbit_q   when (ex5_valid_q/="0000" and ex5_esel_q="110")
            else lrat_entry7_xbit_q   when (ex5_valid_q/="0000" and ex5_esel_q="111")
            else lrat_mmucr3_x_q;
lrat_mas1_v_d  <=  lrat_entry0_valid_q when (ex5_valid_q/="0000" and ex5_esel_q="000")
            else lrat_entry1_valid_q   when (ex5_valid_q/="0000" and ex5_esel_q="001")
            else lrat_entry2_valid_q   when (ex5_valid_q/="0000" and ex5_esel_q="010")
            else lrat_entry3_valid_q   when (ex5_valid_q/="0000" and ex5_esel_q="011")
            else lrat_entry4_valid_q   when (ex5_valid_q/="0000" and ex5_esel_q="100")
            else lrat_entry5_valid_q   when (ex5_valid_q/="0000" and ex5_esel_q="101")
            else lrat_entry6_valid_q   when (ex5_valid_q/="0000" and ex5_esel_q="110")
            else lrat_entry7_valid_q   when (ex5_valid_q/="0000" and ex5_esel_q="111")
            else lrat_mas1_v_q;
lrat_mas1_tsize_d  <=  lrat_entry0_size_q when (ex5_valid_q/="0000" and ex5_esel_q="000")
                else lrat_entry1_size_q   when (ex5_valid_q/="0000" and ex5_esel_q="001")
                else lrat_entry2_size_q   when (ex5_valid_q/="0000" and ex5_esel_q="010")
                else lrat_entry3_size_q   when (ex5_valid_q/="0000" and ex5_esel_q="011")
                else lrat_entry4_size_q   when (ex5_valid_q/="0000" and ex5_esel_q="100")
                else lrat_entry5_size_q   when (ex5_valid_q/="0000" and ex5_esel_q="101")
                else lrat_entry6_size_q   when (ex5_valid_q/="0000" and ex5_esel_q="110")
                else lrat_entry7_size_q   when (ex5_valid_q/="0000" and ex5_esel_q="111")
                else lrat_mas1_tsize_q;
lrat_mas2_epn_d(64-real_addr_width TO 64-lrat_minsize_log2-1) <=  
          lrat_entry0_lpn_q(64-real_addr_width to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="000")
    else lrat_entry1_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="001")
    else lrat_entry2_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="010")
    else lrat_entry3_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="011")
    else lrat_entry4_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="100")
    else lrat_entry5_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="101")
    else lrat_entry6_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="110")
    else lrat_entry7_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="111")
    else lrat_mas2_epn_q(64-real_addr_width to 64-lrat_minsize_log2-1);
lrat_mas2_epn_d(64-lrat_minsize_log2 TO 51) <=  
         (others => '0') when (ex5_valid_q/="0000" and ex5_esel_q="000")
   else (others => '0')  when (ex5_valid_q/="0000" and ex5_esel_q="001")
   else (others => '0')  when (ex5_valid_q/="0000" and ex5_esel_q="010")
   else (others => '0')  when (ex5_valid_q/="0000" and ex5_esel_q="011")
   else (others => '0')  when (ex5_valid_q/="0000" and ex5_esel_q="100")
   else (others => '0')  when (ex5_valid_q/="0000" and ex5_esel_q="101")
   else (others => '0')  when (ex5_valid_q/="0000" and ex5_esel_q="110")
   else (others => '0')  when (ex5_valid_q/="0000" and ex5_esel_q="111")
   else lrat_mas2_epn_q(64-lrat_minsize_log2 to 51);
lrat_mas3_rpnl_d(32 TO 64-lrat_minsize_log2-1) <=  
              lrat_entry0_rpn_q(32 to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="000")
        else lrat_entry1_rpn_q(32   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="001")
        else lrat_entry2_rpn_q(32   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="010")
        else lrat_entry3_rpn_q(32   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="011")
        else lrat_entry4_rpn_q(32   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="100")
        else lrat_entry5_rpn_q(32   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="101")
        else lrat_entry6_rpn_q(32   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="110")
        else lrat_entry7_rpn_q(32   to 64-lrat_minsize_log2-1) when (ex5_valid_q/="0000" and ex5_esel_q="111")
         else lrat_mas3_rpnl_q(32 to 64-lrat_minsize_log2-1);
lrat_mas3_rpnl_d(64-lrat_minsize_log2 TO 51) <=  
          (others => '0') when (ex5_valid_q/="0000" and ex5_esel_q="000")
    else (others => '0') when (ex5_valid_q/="0000" and ex5_esel_q="001")
    else (others => '0') when (ex5_valid_q/="0000" and ex5_esel_q="010")
    else (others => '0') when (ex5_valid_q/="0000" and ex5_esel_q="011")
    else (others => '0') when (ex5_valid_q/="0000" and ex5_esel_q="100")
    else (others => '0') when (ex5_valid_q/="0000" and ex5_esel_q="101")
    else (others => '0') when (ex5_valid_q/="0000" and ex5_esel_q="110")
    else (others => '0') when (ex5_valid_q/="0000" and ex5_esel_q="111")
    else lrat_mas3_rpnl_q(64-lrat_minsize_log2 to 51);
lrat_mas7_rpnu_d(64-real_addr_width TO 31) <=  
          lrat_entry0_rpn_q(64-real_addr_width to 31) when (ex5_valid_q/="0000" and ex5_esel_q="000")
    else lrat_entry1_rpn_q(64-real_addr_width   to 31) when (ex5_valid_q/="0000" and ex5_esel_q="001")
    else lrat_entry2_rpn_q(64-real_addr_width   to 31) when (ex5_valid_q/="0000" and ex5_esel_q="010")
    else lrat_entry3_rpn_q(64-real_addr_width   to 31) when (ex5_valid_q/="0000" and ex5_esel_q="011")
    else lrat_entry4_rpn_q(64-real_addr_width   to 31) when (ex5_valid_q/="0000" and ex5_esel_q="100")
    else lrat_entry5_rpn_q(64-real_addr_width   to 31) when (ex5_valid_q/="0000" and ex5_esel_q="101")
    else lrat_entry6_rpn_q(64-real_addr_width   to 31) when (ex5_valid_q/="0000" and ex5_esel_q="110")
    else lrat_entry7_rpn_q(64-real_addr_width   to 31) when (ex5_valid_q/="0000" and ex5_esel_q="111")
    else lrat_mas7_rpnu_q(64-real_addr_width to 31);
lrat_mas8_tlpid_d  <=  lrat_entry0_lpid_q when (ex5_valid_q/="0000" and ex5_esel_q="000")
                else lrat_entry1_lpid_q   when (ex5_valid_q/="0000" and ex5_esel_q="001")
                else lrat_entry2_lpid_q   when (ex5_valid_q/="0000" and ex5_esel_q="010")
                else lrat_entry3_lpid_q   when (ex5_valid_q/="0000" and ex5_esel_q="011")
                else lrat_entry4_lpid_q   when (ex5_valid_q/="0000" and ex5_esel_q="100")
                else lrat_entry5_lpid_q   when (ex5_valid_q/="0000" and ex5_esel_q="101")
                else lrat_entry6_lpid_q   when (ex5_valid_q/="0000" and ex5_esel_q="110")
                else lrat_entry7_lpid_q   when (ex5_valid_q/="0000" and ex5_esel_q="111")
                else lrat_mas8_tlpid_q;
-- ttype -> tlbre,tlbwe,tlbsx,tlbsxr,tlbsrx
lrat_mas_tlbre_d  <=  '1' when ((ex5_valid_q and not(xu_ex5_flush))/="0000" 
                                     and ex5_ttype_q(0)='1' and ex5_atsel_q='1') 
               else '0';
lrat_mas_tlbsx_hit_d  <=  '1' when (ex6_valid_q/="0000" and ex6_ttype_q(2 to 4)/="000" and ex6_ttype_q(0)='1' 
                                     and ex6_atsel_q='1' and lrat_tag3_hit_status_q(1)='1') 
                  else '0';
lrat_mas_tlbsx_miss_d  <=  '1' when (ex6_valid_q/="0000" and ex6_ttype_q(2 to 4)/="000" and ex6_ttype_q(0)='1'
                                     and ex6_atsel_q='1' and lrat_tag3_hit_status_q(1)='0') 
                  else '0';
lrat_mas_thdid_d(0 TO thdid_width-1) <=  (ex5_valid_q  and (0 to thdid_width-1 => ex5_ttype_q(0))) 
                                       or (ex6_valid_q  and (0 to thdid_width-1 => or_reduce(ex6_ttype_q(2 to 4))));
-- power clock gating
lrat_mas_act_d(0) <=  ((or_reduce(ex4_valid_q) and or_reduce(ex4_ttype_q)) or mmucr2_act_override) and xu_mm_ccr2_notlb_b;
lrat_mas_act_d(1) <=  ((or_reduce(ex4_valid_q) and or_reduce(ex4_ttype_q)) or mmucr2_act_override) and xu_mm_ccr2_notlb_b;
lrat_mas_act_d(2) <=  (((or_reduce(ex4_valid_q) and or_reduce(ex4_ttype_q)) or mmucr2_act_override) and xu_mm_ccr2_notlb_b) or 
                      (((or_reduce(ex5_valid_q) and or_reduce(ex5_ttype_q)) or mmucr2_act_override) and xu_mm_ccr2_notlb_b) or 
                      (((or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q)) or mmucr2_act_override) and xu_mm_ccr2_notlb_b);
lrat_datain_act_d(0) <=  ((or_reduce(ex4_valid_q) and or_reduce(ex4_ttype_q)) or mmucr2_act_override) and xu_mm_ccr2_notlb_b;
lrat_datain_act_d(1) <=  ((or_reduce(ex4_valid_q) and or_reduce(ex4_ttype_q)) or mmucr2_act_override) and xu_mm_ccr2_notlb_b;
-- tag4 phase signals, tlbwe/re ex6
lrat_entry0_lpn_d    <=  lrat_datain_lpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_lpn_q;
lrat_entry0_rpn_d    <=  lrat_datain_rpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_rpn_q;
lrat_entry0_lpid_d    <=  lrat_datain_lpid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_lpid_q;
lrat_entry0_size_d    <=  lrat_datain_size_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_size_q;
lrat_entry0_xbit_d    <=  lrat_datain_xbit_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_xbit_q;
lrat_entry0_valid_d    <=  lrat_datain_valid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_valid_q;
--  size           entry_cmpmask: 0123456
--    1TB                         1111111
--  256GB                         0111111
--   16GB                         0011111
--    4GB                         0001111
--    1GB                         0000111
--  256MB                         0000011
--   16MB                         0000001
--    1MB                         0000000
lrat_entry0_cmpmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_cmpmask_q(0);
lrat_entry0_cmpmask_d(1) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_cmpmask_q(1);
lrat_entry0_cmpmask_d(2) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_cmpmask_q(2);
lrat_entry0_cmpmask_d(3) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_cmpmask_q(3);
lrat_entry0_cmpmask_d(4) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_cmpmask_q(4);
lrat_entry0_cmpmask_d(5) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                   and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_cmpmask_q(5);
lrat_entry0_cmpmask_d(6) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                    and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_cmpmask_q(6);
--  size          entry_xbitmask: 0123456
--    1TB                         1000000
--  256GB                         0100000
--   16GB                         0010000
--    4GB                         0001000
--    1GB                         0000100
--  256MB                         0000010
--   16MB                         0000001
--    1MB                         0000000
lrat_entry0_xbitmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_xbitmask_q(0);
lrat_entry0_xbitmask_d(1) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_xbitmask_q(1);
lrat_entry0_xbitmask_d(2) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_xbitmask_q(2);
lrat_entry0_xbitmask_d(3) <=  Eq(lrat_datain_size_q, LRAT_PgSize_4GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_xbitmask_q(3);
lrat_entry0_xbitmask_d(4) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_xbitmask_q(4);
lrat_entry0_xbitmask_d(5) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_xbitmask_q(5);
lrat_entry0_xbitmask_d(6) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="000"   and ex6_illeg_instr(1)='0') 
              else lrat_entry0_xbitmask_q(6);
lrat_entry1_lpn_d    <=  lrat_datain_lpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_lpn_q;
lrat_entry1_rpn_d    <=  lrat_datain_rpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_rpn_q;
lrat_entry1_lpid_d    <=  lrat_datain_lpid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_lpid_q;
lrat_entry1_size_d    <=  lrat_datain_size_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_size_q;
lrat_entry1_xbit_d    <=  lrat_datain_xbit_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_xbit_q;
lrat_entry1_valid_d    <=  lrat_datain_valid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_valid_q;
--  size           entry_cmpmask: 0123456
--    1TB                         1111111
--  256GB                         0111111
--   16GB                         0011111
--    4GB                         0001111
--    1GB                         0000111
--  256MB                         0000011
--   16MB                         0000001
--    1MB                         0000000
lrat_entry1_cmpmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_cmpmask_q(0);
lrat_entry1_cmpmask_d(1) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_cmpmask_q(1);
lrat_entry1_cmpmask_d(2) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_cmpmask_q(2);
lrat_entry1_cmpmask_d(3) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_cmpmask_q(3);
lrat_entry1_cmpmask_d(4) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_cmpmask_q(4);
lrat_entry1_cmpmask_d(5) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                   and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_cmpmask_q(5);
lrat_entry1_cmpmask_d(6) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                    and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_cmpmask_q(6);
--  size          entry_xbitmask: 0123456
--    1TB                         1000000
--  256GB                         0100000
--   16GB                         0010000
--    4GB                         0001000
--    1GB                         0000100
--  256MB                         0000010
--   16MB                         0000001
--    1MB                         0000000
lrat_entry1_xbitmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_xbitmask_q(0);
lrat_entry1_xbitmask_d(1) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_xbitmask_q(1);
lrat_entry1_xbitmask_d(2) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_xbitmask_q(2);
lrat_entry1_xbitmask_d(3) <=  Eq(lrat_datain_size_q, LRAT_PgSize_4GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_xbitmask_q(3);
lrat_entry1_xbitmask_d(4) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_xbitmask_q(4);
lrat_entry1_xbitmask_d(5) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_xbitmask_q(5);
lrat_entry1_xbitmask_d(6) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="001"   and ex6_illeg_instr(1)='0') 
              else lrat_entry1_xbitmask_q(6);
lrat_entry2_lpn_d    <=  lrat_datain_lpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_lpn_q;
lrat_entry2_rpn_d    <=  lrat_datain_rpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_rpn_q;
lrat_entry2_lpid_d    <=  lrat_datain_lpid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_lpid_q;
lrat_entry2_size_d    <=  lrat_datain_size_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_size_q;
lrat_entry2_xbit_d    <=  lrat_datain_xbit_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_xbit_q;
lrat_entry2_valid_d    <=  lrat_datain_valid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_valid_q;
--  size           entry_cmpmask: 0123456
--    1TB                         1111111
--  256GB                         0111111
--   16GB                         0011111
--    4GB                         0001111
--    1GB                         0000111
--  256MB                         0000011
--   16MB                         0000001
--    1MB                         0000000
lrat_entry2_cmpmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_cmpmask_q(0);
lrat_entry2_cmpmask_d(1) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_cmpmask_q(1);
lrat_entry2_cmpmask_d(2) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_cmpmask_q(2);
lrat_entry2_cmpmask_d(3) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_cmpmask_q(3);
lrat_entry2_cmpmask_d(4) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_cmpmask_q(4);
lrat_entry2_cmpmask_d(5) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                   and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_cmpmask_q(5);
lrat_entry2_cmpmask_d(6) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                    and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_cmpmask_q(6);
--  size          entry_xbitmask: 0123456
--    1TB                         1000000
--  256GB                         0100000
--   16GB                         0010000
--    4GB                         0001000
--    1GB                         0000100
--  256MB                         0000010
--   16MB                         0000001
--    1MB                         0000000
lrat_entry2_xbitmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_xbitmask_q(0);
lrat_entry2_xbitmask_d(1) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_xbitmask_q(1);
lrat_entry2_xbitmask_d(2) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_xbitmask_q(2);
lrat_entry2_xbitmask_d(3) <=  Eq(lrat_datain_size_q, LRAT_PgSize_4GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_xbitmask_q(3);
lrat_entry2_xbitmask_d(4) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_xbitmask_q(4);
lrat_entry2_xbitmask_d(5) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_xbitmask_q(5);
lrat_entry2_xbitmask_d(6) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="010"   and ex6_illeg_instr(1)='0') 
              else lrat_entry2_xbitmask_q(6);
lrat_entry3_lpn_d    <=  lrat_datain_lpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_lpn_q;
lrat_entry3_rpn_d    <=  lrat_datain_rpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_rpn_q;
lrat_entry3_lpid_d    <=  lrat_datain_lpid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_lpid_q;
lrat_entry3_size_d    <=  lrat_datain_size_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_size_q;
lrat_entry3_xbit_d    <=  lrat_datain_xbit_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_xbit_q;
lrat_entry3_valid_d    <=  lrat_datain_valid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_valid_q;
--  size           entry_cmpmask: 0123456
--    1TB                         1111111
--  256GB                         0111111
--   16GB                         0011111
--    4GB                         0001111
--    1GB                         0000111
--  256MB                         0000011
--   16MB                         0000001
--    1MB                         0000000
lrat_entry3_cmpmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_cmpmask_q(0);
lrat_entry3_cmpmask_d(1) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_cmpmask_q(1);
lrat_entry3_cmpmask_d(2) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_cmpmask_q(2);
lrat_entry3_cmpmask_d(3) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_cmpmask_q(3);
lrat_entry3_cmpmask_d(4) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_cmpmask_q(4);
lrat_entry3_cmpmask_d(5) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                   and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_cmpmask_q(5);
lrat_entry3_cmpmask_d(6) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                    and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_cmpmask_q(6);
--  size          entry_xbitmask: 0123456
--    1TB                         1000000
--  256GB                         0100000
--   16GB                         0010000
--    4GB                         0001000
--    1GB                         0000100
--  256MB                         0000010
--   16MB                         0000001
--    1MB                         0000000
lrat_entry3_xbitmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_xbitmask_q(0);
lrat_entry3_xbitmask_d(1) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_xbitmask_q(1);
lrat_entry3_xbitmask_d(2) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_xbitmask_q(2);
lrat_entry3_xbitmask_d(3) <=  Eq(lrat_datain_size_q, LRAT_PgSize_4GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_xbitmask_q(3);
lrat_entry3_xbitmask_d(4) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_xbitmask_q(4);
lrat_entry3_xbitmask_d(5) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_xbitmask_q(5);
lrat_entry3_xbitmask_d(6) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="011"   and ex6_illeg_instr(1)='0') 
              else lrat_entry3_xbitmask_q(6);
lrat_entry4_lpn_d    <=  lrat_datain_lpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_lpn_q;
lrat_entry4_rpn_d    <=  lrat_datain_rpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_rpn_q;
lrat_entry4_lpid_d    <=  lrat_datain_lpid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_lpid_q;
lrat_entry4_size_d    <=  lrat_datain_size_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_size_q;
lrat_entry4_xbit_d    <=  lrat_datain_xbit_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_xbit_q;
lrat_entry4_valid_d    <=  lrat_datain_valid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_valid_q;
--  size           entry_cmpmask: 0123456
--    1TB                         1111111
--  256GB                         0111111
--   16GB                         0011111
--    4GB                         0001111
--    1GB                         0000111
--  256MB                         0000011
--   16MB                         0000001
--    1MB                         0000000
lrat_entry4_cmpmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_cmpmask_q(0);
lrat_entry4_cmpmask_d(1) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_cmpmask_q(1);
lrat_entry4_cmpmask_d(2) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_cmpmask_q(2);
lrat_entry4_cmpmask_d(3) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_cmpmask_q(3);
lrat_entry4_cmpmask_d(4) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_cmpmask_q(4);
lrat_entry4_cmpmask_d(5) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                   and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_cmpmask_q(5);
lrat_entry4_cmpmask_d(6) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                    and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_cmpmask_q(6);
--  size          entry_xbitmask: 0123456
--    1TB                         1000000
--  256GB                         0100000
--   16GB                         0010000
--    4GB                         0001000
--    1GB                         0000100
--  256MB                         0000010
--   16MB                         0000001
--    1MB                         0000000
lrat_entry4_xbitmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_xbitmask_q(0);
lrat_entry4_xbitmask_d(1) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_xbitmask_q(1);
lrat_entry4_xbitmask_d(2) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_xbitmask_q(2);
lrat_entry4_xbitmask_d(3) <=  Eq(lrat_datain_size_q, LRAT_PgSize_4GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_xbitmask_q(3);
lrat_entry4_xbitmask_d(4) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_xbitmask_q(4);
lrat_entry4_xbitmask_d(5) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_xbitmask_q(5);
lrat_entry4_xbitmask_d(6) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="100"   and ex6_illeg_instr(1)='0') 
              else lrat_entry4_xbitmask_q(6);
lrat_entry5_lpn_d    <=  lrat_datain_lpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_lpn_q;
lrat_entry5_rpn_d    <=  lrat_datain_rpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_rpn_q;
lrat_entry5_lpid_d    <=  lrat_datain_lpid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_lpid_q;
lrat_entry5_size_d    <=  lrat_datain_size_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_size_q;
lrat_entry5_xbit_d    <=  lrat_datain_xbit_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_xbit_q;
lrat_entry5_valid_d    <=  lrat_datain_valid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_valid_q;
--  size           entry_cmpmask: 0123456
--    1TB                         1111111
--  256GB                         0111111
--   16GB                         0011111
--    4GB                         0001111
--    1GB                         0000111
--  256MB                         0000011
--   16MB                         0000001
--    1MB                         0000000
lrat_entry5_cmpmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_cmpmask_q(0);
lrat_entry5_cmpmask_d(1) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_cmpmask_q(1);
lrat_entry5_cmpmask_d(2) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_cmpmask_q(2);
lrat_entry5_cmpmask_d(3) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_cmpmask_q(3);
lrat_entry5_cmpmask_d(4) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_cmpmask_q(4);
lrat_entry5_cmpmask_d(5) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                   and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_cmpmask_q(5);
lrat_entry5_cmpmask_d(6) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                    and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_cmpmask_q(6);
--  size          entry_xbitmask: 0123456
--    1TB                         1000000
--  256GB                         0100000
--   16GB                         0010000
--    4GB                         0001000
--    1GB                         0000100
--  256MB                         0000010
--   16MB                         0000001
--    1MB                         0000000
lrat_entry5_xbitmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_xbitmask_q(0);
lrat_entry5_xbitmask_d(1) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_xbitmask_q(1);
lrat_entry5_xbitmask_d(2) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_xbitmask_q(2);
lrat_entry5_xbitmask_d(3) <=  Eq(lrat_datain_size_q, LRAT_PgSize_4GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_xbitmask_q(3);
lrat_entry5_xbitmask_d(4) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_xbitmask_q(4);
lrat_entry5_xbitmask_d(5) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_xbitmask_q(5);
lrat_entry5_xbitmask_d(6) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="101"   and ex6_illeg_instr(1)='0') 
              else lrat_entry5_xbitmask_q(6);
lrat_entry6_lpn_d    <=  lrat_datain_lpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_lpn_q;
lrat_entry6_rpn_d    <=  lrat_datain_rpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_rpn_q;
lrat_entry6_lpid_d    <=  lrat_datain_lpid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_lpid_q;
lrat_entry6_size_d    <=  lrat_datain_size_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_size_q;
lrat_entry6_xbit_d    <=  lrat_datain_xbit_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_xbit_q;
lrat_entry6_valid_d    <=  lrat_datain_valid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_valid_q;
--  size           entry_cmpmask: 0123456
--    1TB                         1111111
--  256GB                         0111111
--   16GB                         0011111
--    4GB                         0001111
--    1GB                         0000111
--  256MB                         0000011
--   16MB                         0000001
--    1MB                         0000000
lrat_entry6_cmpmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_cmpmask_q(0);
lrat_entry6_cmpmask_d(1) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_cmpmask_q(1);
lrat_entry6_cmpmask_d(2) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_cmpmask_q(2);
lrat_entry6_cmpmask_d(3) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_cmpmask_q(3);
lrat_entry6_cmpmask_d(4) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_cmpmask_q(4);
lrat_entry6_cmpmask_d(5) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                   and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_cmpmask_q(5);
lrat_entry6_cmpmask_d(6) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                    and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_cmpmask_q(6);
--  size          entry_xbitmask: 0123456
--    1TB                         1000000
--  256GB                         0100000
--   16GB                         0010000
--    4GB                         0001000
--    1GB                         0000100
--  256MB                         0000010
--   16MB                         0000001
--    1MB                         0000000
lrat_entry6_xbitmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_xbitmask_q(0);
lrat_entry6_xbitmask_d(1) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_xbitmask_q(1);
lrat_entry6_xbitmask_d(2) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_xbitmask_q(2);
lrat_entry6_xbitmask_d(3) <=  Eq(lrat_datain_size_q, LRAT_PgSize_4GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_xbitmask_q(3);
lrat_entry6_xbitmask_d(4) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_xbitmask_q(4);
lrat_entry6_xbitmask_d(5) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_xbitmask_q(5);
lrat_entry6_xbitmask_d(6) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="110"   and ex6_illeg_instr(1)='0') 
              else lrat_entry6_xbitmask_q(6);
lrat_entry7_lpn_d    <=  lrat_datain_lpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_lpn_q;
lrat_entry7_rpn_d    <=  lrat_datain_rpn_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_rpn_q;
lrat_entry7_lpid_d    <=  lrat_datain_lpid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_lpid_q;
lrat_entry7_size_d    <=  lrat_datain_size_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_size_q;
lrat_entry7_xbit_d    <=  lrat_datain_xbit_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_xbit_q;
lrat_entry7_valid_d    <=  lrat_datain_valid_q when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                          and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_valid_q;
--  size           entry_cmpmask: 0123456
--    1TB                         1111111
--  256GB                         0111111
--   16GB                         0011111
--    4GB                         0001111
--    1GB                         0000111
--  256MB                         0000011
--   16MB                         0000001
--    1MB                         0000000
lrat_entry7_cmpmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_cmpmask_q(0);
lrat_entry7_cmpmask_d(1) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_cmpmask_q(1);
lrat_entry7_cmpmask_d(2) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_cmpmask_q(2);
lrat_entry7_cmpmask_d(3) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_cmpmask_q(3);
lrat_entry7_cmpmask_d(4) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                  and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_cmpmask_q(4);
lrat_entry7_cmpmask_d(5) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                   and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_cmpmask_q(5);
lrat_entry7_cmpmask_d(6) <=  (Eq(lrat_datain_size_q, LRAT_PgSize_1TB) or 
                                Eq(lrat_datain_size_q, LRAT_PgSize_256GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_4GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_1GB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_256MB) or
                                Eq(lrat_datain_size_q, LRAT_PgSize_16MB)) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                                    and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_cmpmask_q(6);
--  size          entry_xbitmask: 0123456
--    1TB                         1000000
--  256GB                         0100000
--   16GB                         0010000
--    4GB                         0001000
--    1GB                         0000100
--  256MB                         0000010
--   16MB                         0000001
--    1MB                         0000000
lrat_entry7_xbitmask_d(0) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1TB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_xbitmask_q(0);
lrat_entry7_xbitmask_d(1) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_xbitmask_q(1);
lrat_entry7_xbitmask_d(2) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_xbitmask_q(2);
lrat_entry7_xbitmask_d(3) <=  Eq(lrat_datain_size_q, LRAT_PgSize_4GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_xbitmask_q(3);
lrat_entry7_xbitmask_d(4) <=  Eq(lrat_datain_size_q, LRAT_PgSize_1GB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_xbitmask_q(4);
lrat_entry7_xbitmask_d(5) <=  Eq(lrat_datain_size_q, LRAT_PgSize_256MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_xbitmask_q(5);
lrat_entry7_xbitmask_d(6) <=  Eq(lrat_datain_size_q, LRAT_PgSize_16MB) 
                         when (ex6_valid_q/="0000" and ex6_ttype_q(1)='1' 
                         and ex6_atsel_q='1' and ex6_hes_q='0' and (ex6_wq_q="00" or ex6_wq_q="11") and ex6_esel_q="111"   and ex6_illeg_instr(1)='0') 
              else lrat_entry7_xbitmask_q(6);
-- power clock gating for entries
lrat_entry_act_d(0 TO 7) <=  (0 to 7 => ((or_reduce(ex5_valid_q) and ex5_atsel_q) or mmucr2_act_override) and xu_mm_ccr2_notlb_b);
-- these are tag1 phase matchline components
matchline_comb0   : mmq_tlb_lrat_matchline
 generic map (real_addr_width   => real_addr_width,
                 lpid_width         => 8,
                 lrat_maxsize_log2  => const_lrat_maxsize_log2,  
                 lrat_minsize_log2  => 20,                       
                 have_xbit   => 1,
                 num_pgsizes => 8,
                 have_cmpmask => 1, 
                 cmpmask_width => 7)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => lrat_tag1_lpn_q(64-real_addr_width to 64-lrat_minsize_log2-1), 
    addr_enable                      => addr_enable,
    entry_size                       => lrat_entry0_size_q(0   to 3), 
    entry_cmpmask                    => lrat_entry0_cmpmask_q(0   to 6), 
    entry_xbit                       => lrat_entry0_xbit_q,   
    entry_xbitmask                   => lrat_entry0_xbitmask_q(0   to 6), 
    entry_lpn                        => lrat_entry0_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1), 
    entry_lpid                       => lrat_entry0_lpid_q(0   to lpid_width-1),
    comp_lpid                        => lrat_tag1_lpid_q(0 to lpid_width-1),
    lpid_enable                      => lpid_enable,
    entry_v                          => lrat_entry0_valid_q,   

    match                            => lrat_tag1_matchline(0),    

    dbg_addr_match                   => lrat_entry0_addr_match,
    dbg_lpid_match                   => lrat_entry0_lpid_match

  );
matchline_comb1   : mmq_tlb_lrat_matchline
 generic map (real_addr_width   => real_addr_width,
                 lpid_width         => 8,
                 lrat_maxsize_log2  => const_lrat_maxsize_log2,  
                 lrat_minsize_log2  => 20,                       
                 have_xbit   => 1,
                 num_pgsizes => 8,
                 have_cmpmask => 1, 
                 cmpmask_width => 7)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => lrat_tag1_lpn_q(64-real_addr_width to 64-lrat_minsize_log2-1), 
    addr_enable                      => addr_enable,
    entry_size                       => lrat_entry1_size_q(0   to 3), 
    entry_cmpmask                    => lrat_entry1_cmpmask_q(0   to 6), 
    entry_xbit                       => lrat_entry1_xbit_q,   
    entry_xbitmask                   => lrat_entry1_xbitmask_q(0   to 6), 
    entry_lpn                        => lrat_entry1_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1), 
    entry_lpid                       => lrat_entry1_lpid_q(0   to lpid_width-1),
    comp_lpid                        => lrat_tag1_lpid_q(0 to lpid_width-1),
    lpid_enable                      => lpid_enable,
    entry_v                          => lrat_entry1_valid_q,   

    match                            => lrat_tag1_matchline(1),    

    dbg_addr_match                   => lrat_entry1_addr_match,
    dbg_lpid_match                   => lrat_entry1_lpid_match

  );
matchline_comb2   : mmq_tlb_lrat_matchline
 generic map (real_addr_width   => real_addr_width,
                 lpid_width         => 8,
                 lrat_maxsize_log2  => const_lrat_maxsize_log2,  
                 lrat_minsize_log2  => 20,                       
                 have_xbit   => 1,
                 num_pgsizes => 8,
                 have_cmpmask => 1, 
                 cmpmask_width => 7)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => lrat_tag1_lpn_q(64-real_addr_width to 64-lrat_minsize_log2-1), 
    addr_enable                      => addr_enable,
    entry_size                       => lrat_entry2_size_q(0   to 3), 
    entry_cmpmask                    => lrat_entry2_cmpmask_q(0   to 6), 
    entry_xbit                       => lrat_entry2_xbit_q,   
    entry_xbitmask                   => lrat_entry2_xbitmask_q(0   to 6), 
    entry_lpn                        => lrat_entry2_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1), 
    entry_lpid                       => lrat_entry2_lpid_q(0   to lpid_width-1),
    comp_lpid                        => lrat_tag1_lpid_q(0 to lpid_width-1),
    lpid_enable                      => lpid_enable,
    entry_v                          => lrat_entry2_valid_q,   

    match                            => lrat_tag1_matchline(2),    

    dbg_addr_match                   => lrat_entry2_addr_match,
    dbg_lpid_match                   => lrat_entry2_lpid_match

  );
matchline_comb3   : mmq_tlb_lrat_matchline
 generic map (real_addr_width   => real_addr_width,
                 lpid_width         => 8,
                 lrat_maxsize_log2  => const_lrat_maxsize_log2,  
                 lrat_minsize_log2  => 20,                       
                 have_xbit   => 1,
                 num_pgsizes => 8,
                 have_cmpmask => 1, 
                 cmpmask_width => 7)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => lrat_tag1_lpn_q(64-real_addr_width to 64-lrat_minsize_log2-1), 
    addr_enable                      => addr_enable,
    entry_size                       => lrat_entry3_size_q(0   to 3), 
    entry_cmpmask                    => lrat_entry3_cmpmask_q(0   to 6), 
    entry_xbit                       => lrat_entry3_xbit_q,   
    entry_xbitmask                   => lrat_entry3_xbitmask_q(0   to 6), 
    entry_lpn                        => lrat_entry3_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1), 
    entry_lpid                       => lrat_entry3_lpid_q(0   to lpid_width-1),
    comp_lpid                        => lrat_tag1_lpid_q(0 to lpid_width-1),
    lpid_enable                      => lpid_enable,
    entry_v                          => lrat_entry3_valid_q,   

    match                            => lrat_tag1_matchline(3),    

    dbg_addr_match                   => lrat_entry3_addr_match,
    dbg_lpid_match                   => lrat_entry3_lpid_match

  );
matchline_comb4   : mmq_tlb_lrat_matchline
 generic map (real_addr_width   => real_addr_width,
                 lpid_width         => 8,
                 lrat_maxsize_log2  => const_lrat_maxsize_log2,  
                 lrat_minsize_log2  => 20,                       
                 have_xbit   => 1,
                 num_pgsizes => 8,
                 have_cmpmask => 1, 
                 cmpmask_width => 7)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => lrat_tag1_lpn_q(64-real_addr_width to 64-lrat_minsize_log2-1), 
    addr_enable                      => addr_enable,
    entry_size                       => lrat_entry4_size_q(0   to 3), 
    entry_cmpmask                    => lrat_entry4_cmpmask_q(0   to 6), 
    entry_xbit                       => lrat_entry4_xbit_q,   
    entry_xbitmask                   => lrat_entry4_xbitmask_q(0   to 6), 
    entry_lpn                        => lrat_entry4_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1), 
    entry_lpid                       => lrat_entry4_lpid_q(0   to lpid_width-1),
    comp_lpid                        => lrat_tag1_lpid_q(0 to lpid_width-1),
    lpid_enable                      => lpid_enable,
    entry_v                          => lrat_entry4_valid_q,   

    match                            => lrat_tag1_matchline(4),    

    dbg_addr_match                   => lrat_entry4_addr_match,
    dbg_lpid_match                   => lrat_entry4_lpid_match

  );
matchline_comb5   : mmq_tlb_lrat_matchline
 generic map (real_addr_width   => real_addr_width,
                 lpid_width         => 8,
                 lrat_maxsize_log2  => const_lrat_maxsize_log2,  
                 lrat_minsize_log2  => 20,                       
                 have_xbit   => 1,
                 num_pgsizes => 8,
                 have_cmpmask => 1, 
                 cmpmask_width => 7)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => lrat_tag1_lpn_q(64-real_addr_width to 64-lrat_minsize_log2-1), 
    addr_enable                      => addr_enable,
    entry_size                       => lrat_entry5_size_q(0   to 3), 
    entry_cmpmask                    => lrat_entry5_cmpmask_q(0   to 6), 
    entry_xbit                       => lrat_entry5_xbit_q,   
    entry_xbitmask                   => lrat_entry5_xbitmask_q(0   to 6), 
    entry_lpn                        => lrat_entry5_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1), 
    entry_lpid                       => lrat_entry5_lpid_q(0   to lpid_width-1),
    comp_lpid                        => lrat_tag1_lpid_q(0 to lpid_width-1),
    lpid_enable                      => lpid_enable,
    entry_v                          => lrat_entry5_valid_q,   

    match                            => lrat_tag1_matchline(5),    

    dbg_addr_match                   => lrat_entry5_addr_match,
    dbg_lpid_match                   => lrat_entry5_lpid_match

  );
matchline_comb6   : mmq_tlb_lrat_matchline
 generic map (real_addr_width   => real_addr_width,
                 lpid_width         => 8,
                 lrat_maxsize_log2  => const_lrat_maxsize_log2,  
                 lrat_minsize_log2  => 20,                       
                 have_xbit   => 1,
                 num_pgsizes => 8,
                 have_cmpmask => 1, 
                 cmpmask_width => 7)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => lrat_tag1_lpn_q(64-real_addr_width to 64-lrat_minsize_log2-1), 
    addr_enable                      => addr_enable,
    entry_size                       => lrat_entry6_size_q(0   to 3), 
    entry_cmpmask                    => lrat_entry6_cmpmask_q(0   to 6), 
    entry_xbit                       => lrat_entry6_xbit_q,   
    entry_xbitmask                   => lrat_entry6_xbitmask_q(0   to 6), 
    entry_lpn                        => lrat_entry6_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1), 
    entry_lpid                       => lrat_entry6_lpid_q(0   to lpid_width-1),
    comp_lpid                        => lrat_tag1_lpid_q(0 to lpid_width-1),
    lpid_enable                      => lpid_enable,
    entry_v                          => lrat_entry6_valid_q,   

    match                            => lrat_tag1_matchline(6),    

    dbg_addr_match                   => lrat_entry6_addr_match,
    dbg_lpid_match                   => lrat_entry6_lpid_match

  );
matchline_comb7   : mmq_tlb_lrat_matchline
 generic map (real_addr_width   => real_addr_width,
                 lpid_width         => 8,
                 lrat_maxsize_log2  => const_lrat_maxsize_log2,  
                 lrat_minsize_log2  => 20,                       
                 have_xbit   => 1,
                 num_pgsizes => 8,
                 have_cmpmask => 1, 
                 cmpmask_width => 7)
  port map (
    vdd                              => vdd,
    gnd                              => gnd, 
    addr_in                          => lrat_tag1_lpn_q(64-real_addr_width to 64-lrat_minsize_log2-1), 
    addr_enable                      => addr_enable,
    entry_size                       => lrat_entry7_size_q(0   to 3), 
    entry_cmpmask                    => lrat_entry7_cmpmask_q(0   to 6), 
    entry_xbit                       => lrat_entry7_xbit_q,   
    entry_xbitmask                   => lrat_entry7_xbitmask_q(0   to 6), 
    entry_lpn                        => lrat_entry7_lpn_q(64-real_addr_width   to 64-lrat_minsize_log2-1), 
    entry_lpid                       => lrat_entry7_lpid_q(0   to lpid_width-1),
    comp_lpid                        => lrat_tag1_lpid_q(0 to lpid_width-1),
    lpid_enable                      => lpid_enable,
    entry_v                          => lrat_entry7_valid_q,   

    match                            => lrat_tag1_matchline(7),    

    dbg_addr_match                   => lrat_entry7_addr_match,
    dbg_lpid_match                   => lrat_entry7_lpid_match

  );
-----------------------------------------------------------------------
-- output assignments
-----------------------------------------------------------------------
lrat_tag3_lpn               <=  lrat_tag3_lpn_q(64-real_addr_width to 51);
lrat_tag3_rpn               <=  lrat_tag3_rpn_q(64-real_addr_width to 51);
lrat_tag3_hit_status        <=  lrat_tag3_hit_status_q;
lrat_tag3_hit_entry         <=  lrat_tag3_hit_entry_q;
lrat_tag4_lpn               <=  lrat_tag4_lpn_q(64-real_addr_width to 51);
lrat_tag4_rpn               <=  lrat_tag4_rpn_q(64-real_addr_width to 51);
lrat_tag4_hit_status        <=  lrat_tag4_hit_status_q;
lrat_tag4_hit_entry         <=  lrat_tag4_hit_entry_q;
lrat_mas0_esel   <=  lrat_tag4_hit_entry_q;
lrat_mas1_v      <=  lrat_mas1_v_q;
lrat_mas1_tsize  <=  lrat_mas1_tsize_q;
gen64_lrat_mas2_epn: if real_addr_width > 32 generate
lrat_mas2_epn(0 TO 63-real_addr_width) <=  (others => '0');
lrat_mas2_epn(64-real_addr_width TO 31) <=  lrat_mas2_epn_q(64-real_addr_width to 31);
lrat_mas2_epn(32 TO 51) <=  lrat_mas2_epn_q(32 to 51);
end generate gen64_lrat_mas2_epn;
gen32_lrat_mas2_epn: if real_addr_width < 33 generate
lrat_mas2_epn(0 TO 63-real_addr_width) <=  (others => '0');
lrat_mas2_epn(64-real_addr_width TO 51) <=  lrat_mas2_epn_q(64-real_addr_width to 51);
end generate gen32_lrat_mas2_epn;
lrat_mas3_rpnl   <=  lrat_mas3_rpnl_q;
lrat_mas7_rpnu   <=  lrat_mas7_rpnu_q;
lrat_mas8_tlpid  <=  lrat_mas8_tlpid_q;
lrat_mas_tlbre   <=  lrat_mas_tlbre_q;
lrat_mas_tlbsx_hit    <=  lrat_mas_tlbsx_hit_q;
lrat_mas_tlbsx_miss   <=  lrat_mas_tlbsx_miss_q;
lrat_mas_thdid   <=  lrat_mas_thdid_q;
lrat_mmucr3_x    <=  lrat_mmucr3_x_q;
lrat_dbg_tag1_addr_enable     <=  addr_enable;
lrat_dbg_tag2_matchline_q     <=  lrat_tag2_matchline_q;
lrat_dbg_entry0_addr_match    <=  lrat_entry0_addr_match;
lrat_dbg_entry0_lpid_match    <=  lrat_entry0_lpid_match;
lrat_dbg_entry0_entry_v       <=  lrat_entry0_valid_q;
lrat_dbg_entry0_entry_x       <=  lrat_entry0_xbit_q;
lrat_dbg_entry0_size          <=  lrat_entry0_size_q;
lrat_dbg_entry1_addr_match    <=  lrat_entry1_addr_match;
lrat_dbg_entry1_lpid_match    <=  lrat_entry1_lpid_match;
lrat_dbg_entry1_entry_v       <=  lrat_entry1_valid_q;
lrat_dbg_entry1_entry_x       <=  lrat_entry1_xbit_q;
lrat_dbg_entry1_size          <=  lrat_entry1_size_q;
lrat_dbg_entry2_addr_match    <=  lrat_entry2_addr_match;
lrat_dbg_entry2_lpid_match    <=  lrat_entry2_lpid_match;
lrat_dbg_entry2_entry_v       <=  lrat_entry2_valid_q;
lrat_dbg_entry2_entry_x       <=  lrat_entry2_xbit_q;
lrat_dbg_entry2_size          <=  lrat_entry2_size_q;
lrat_dbg_entry3_addr_match    <=  lrat_entry3_addr_match;
lrat_dbg_entry3_lpid_match    <=  lrat_entry3_lpid_match;
lrat_dbg_entry3_entry_v       <=  lrat_entry3_valid_q;
lrat_dbg_entry3_entry_x       <=  lrat_entry3_xbit_q;
lrat_dbg_entry3_size          <=  lrat_entry3_size_q;
lrat_dbg_entry4_addr_match    <=  lrat_entry4_addr_match;
lrat_dbg_entry4_lpid_match    <=  lrat_entry4_lpid_match;
lrat_dbg_entry4_entry_v       <=  lrat_entry4_valid_q;
lrat_dbg_entry4_entry_x       <=  lrat_entry4_xbit_q;
lrat_dbg_entry4_size          <=  lrat_entry4_size_q;
lrat_dbg_entry5_addr_match    <=  lrat_entry5_addr_match;
lrat_dbg_entry5_lpid_match    <=  lrat_entry5_lpid_match;
lrat_dbg_entry5_entry_v       <=  lrat_entry5_valid_q;
lrat_dbg_entry5_entry_x       <=  lrat_entry5_xbit_q;
lrat_dbg_entry5_size          <=  lrat_entry5_size_q;
lrat_dbg_entry6_addr_match    <=  lrat_entry6_addr_match;
lrat_dbg_entry6_lpid_match    <=  lrat_entry6_lpid_match;
lrat_dbg_entry6_entry_v       <=  lrat_entry6_valid_q;
lrat_dbg_entry6_entry_x       <=  lrat_entry6_xbit_q;
lrat_dbg_entry6_size          <=  lrat_entry6_size_q;
lrat_dbg_entry7_addr_match    <=  lrat_entry7_addr_match;
lrat_dbg_entry7_lpid_match    <=  lrat_entry7_lpid_match;
lrat_dbg_entry7_entry_v       <=  lrat_entry7_valid_q;
lrat_dbg_entry7_entry_x       <=  lrat_entry7_xbit_q;
lrat_dbg_entry7_size          <=  lrat_entry7_size_q;
-- unused spare signal assignments
unused_dc(0) <=  or_reduce(LCB_DELAY_LCLKR_DC(1 TO 4));
unused_dc(1) <=  or_reduce(LCB_MPW1_DC_B(1 TO 4));
unused_dc(2) <=  PC_FUNC_SL_FORCE;
unused_dc(3) <=  PC_FUNC_SL_THOLD_0_B;
unused_dc(4) <=  TC_SCAN_DIS_DC_B;
unused_dc(5) <=  TC_SCAN_DIAG_DC;
unused_dc(6) <=  TC_LBIST_EN_DC;
unused_dc(7) <=  or_reduce(TLB_TAG0_TYPE(0 TO 1) & TLB_TAG0_TYPE(3 TO 5));
unused_dc(8) <=  EX6_TTYPE_Q(0);
unused_dc(9) <=  or_reduce(MAS2_0_EPN(44 TO 51));
unused_dc(10) <=  or_reduce(MAS2_1_EPN(44 TO 51));
unused_dc(11) <=  or_reduce(MAS2_2_EPN(44 TO 51));
unused_dc(12) <=  or_reduce(MAS2_3_EPN(44 TO 51));
unused_dc(13) <=  ex6_illeg_instr(0);
-----------------------------------------------------------------------
-- Latches
-----------------------------------------------------------------------
-- ex4   phase:  valid latches
ex4_valid_latch:   tri_rlmreg_p
  generic map (width => ex4_valid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_valid_offset   to ex4_valid_offset+ex4_valid_q'length-1),
            scout   => sov(ex4_valid_offset   to ex4_valid_offset+ex4_valid_q'length-1),
            din     => ex4_valid_d,
            dout    => ex4_valid_q    );
-- ex4   phase:  ttype latches
ex4_ttype_latch:   tri_rlmreg_p
  generic map (width => ex4_ttype_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_ttype_offset   to ex4_ttype_offset+ex4_ttype_q'length-1),
            scout   => sov(ex4_ttype_offset   to ex4_ttype_offset+ex4_ttype_q'length-1),
            din     => ex4_ttype_d,
            dout    => ex4_ttype_q    );
-- ex5   phase:  valid latches
ex5_valid_latch:   tri_rlmreg_p
  generic map (width => ex5_valid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_valid_offset   to ex5_valid_offset+ex5_valid_q'length-1),
            scout   => sov(ex5_valid_offset   to ex5_valid_offset+ex5_valid_q'length-1),
            din     => ex5_valid_d,
            dout    => ex5_valid_q    );
-- ex5   phase:  ttype latches
ex5_ttype_latch:   tri_rlmreg_p
  generic map (width => ex5_ttype_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_ttype_offset   to ex5_ttype_offset+ex5_ttype_q'length-1),
            scout   => sov(ex5_ttype_offset   to ex5_ttype_offset+ex5_ttype_q'length-1),
            din     => ex5_ttype_d,
            dout    => ex5_ttype_q    );
-- ex6   phase:  valid latches
ex6_valid_latch:   tri_rlmreg_p
  generic map (width => ex6_valid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_valid_offset   to ex6_valid_offset+ex6_valid_q'length-1),
            scout   => sov(ex6_valid_offset   to ex6_valid_offset+ex6_valid_q'length-1),
            din     => ex6_valid_d,
            dout    => ex6_valid_q    );
-- ex6   phase:  ttype latches
ex6_ttype_latch:   tri_rlmreg_p
  generic map (width => ex6_ttype_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_ttype_offset   to ex6_ttype_offset+ex6_ttype_q'length-1),
            scout   => sov(ex6_ttype_offset   to ex6_ttype_offset+ex6_ttype_q'length-1),
            din     => ex6_ttype_d,
            dout    => ex6_ttype_q    );
-- ex5   phase:  esel latches
ex5_esel_latch:   tri_rlmreg_p
  generic map (width => ex5_esel_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_esel_offset   to ex5_esel_offset+ex5_esel_q'length-1),
            scout   => sov(ex5_esel_offset   to ex5_esel_offset+ex5_esel_q'length-1),
            din     => ex5_esel_d,
            dout    => ex5_esel_q    );
-- ex5   phase:  atsel latches
ex5_atsel_latch:   tri_rlmlatch_p
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
            scin    => siv(ex5_atsel_offset),
            scout   => sov(ex5_atsel_offset),
            din     => ex5_atsel_d,
            dout    => ex5_atsel_q);
-- ex5   phase:  hes latches
ex5_hes_latch:   tri_rlmlatch_p
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
            scin    => siv(ex5_hes_offset),
            scout   => sov(ex5_hes_offset),
            din     => ex5_hes_d,
            dout    => ex5_hes_q);
-- ex5   phase:  wq latches
ex5_wq_latch:   tri_rlmreg_p
  generic map (width => ex5_wq_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_wq_offset   to ex5_wq_offset+ex5_wq_q'length-1),
            scout   => sov(ex5_wq_offset   to ex5_wq_offset+ex5_wq_q'length-1),
            din     => ex5_wq_d,
            dout    => ex5_wq_q    );
-- ex6   phase:  esel latches
ex6_esel_latch:   tri_rlmreg_p
  generic map (width => ex6_esel_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_esel_offset   to ex6_esel_offset+ex6_esel_q'length-1),
            scout   => sov(ex6_esel_offset   to ex6_esel_offset+ex6_esel_q'length-1),
            din     => ex6_esel_d,
            dout    => ex6_esel_q    );
-- ex6   phase:  atsel latches
ex6_atsel_latch:   tri_rlmlatch_p
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
            scin    => siv(ex6_atsel_offset),
            scout   => sov(ex6_atsel_offset),
            din     => ex6_atsel_d,
            dout    => ex6_atsel_q);
-- ex6   phase:  hes latches
ex6_hes_latch:   tri_rlmlatch_p
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
            scin    => siv(ex6_hes_offset),
            scout   => sov(ex6_hes_offset),
            din     => ex6_hes_d,
            dout    => ex6_hes_q);
-- ex6   phase:  wq latches
ex6_wq_latch:   tri_rlmreg_p
  generic map (width => ex6_wq_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_wq_offset   to ex6_wq_offset+ex6_wq_q'length-1),
            scout   => sov(ex6_wq_offset   to ex6_wq_offset+ex6_wq_q'length-1),
            din     => ex6_wq_d,
            dout    => ex6_wq_q    );
-- tag1   phase:  logical page number latches
lrat_tag1_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_tag1_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20+0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag1_lpn_offset   to lrat_tag1_lpn_offset+lrat_tag1_lpn_q'length-1),
            scout   => sov(lrat_tag1_lpn_offset   to lrat_tag1_lpn_offset+lrat_tag1_lpn_q'length-1),
            din     => lrat_tag1_lpn_d(64-real_addr_width   to 51),
            dout    => lrat_tag1_lpn_q(64-real_addr_width   to 51)  );
-- tag2   phase:  logical page number latches
lrat_tag2_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_tag2_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20+1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag2_lpn_offset   to lrat_tag2_lpn_offset+lrat_tag2_lpn_q'length-1),
            scout   => sov(lrat_tag2_lpn_offset   to lrat_tag2_lpn_offset+lrat_tag2_lpn_q'length-1),
            din     => lrat_tag2_lpn_d(64-real_addr_width   to 51),
            dout    => lrat_tag2_lpn_q(64-real_addr_width   to 51)  );
-- tag3   phase:  logical page number latches
lrat_tag3_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_tag3_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag3_lpn_offset   to lrat_tag3_lpn_offset+lrat_tag3_lpn_q'length-1),
            scout   => sov(lrat_tag3_lpn_offset   to lrat_tag3_lpn_offset+lrat_tag3_lpn_q'length-1),
            din     => lrat_tag3_lpn_d(64-real_addr_width   to 51),
            dout    => lrat_tag3_lpn_q(64-real_addr_width   to 51)  );
-- tag4   phase:  logical page number latches
lrat_tag4_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_tag4_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag4_lpn_offset   to lrat_tag4_lpn_offset+lrat_tag4_lpn_q'length-1),
            scout   => sov(lrat_tag4_lpn_offset   to lrat_tag4_lpn_offset+lrat_tag4_lpn_q'length-1),
            din     => lrat_tag4_lpn_d(64-real_addr_width   to 51),
            dout    => lrat_tag4_lpn_q(64-real_addr_width   to 51)  );
-- tag3   phase:  real page number latches
lrat_tag3_rpn_latch:   tri_rlmreg_p
  generic map (width => lrat_tag3_rpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag3_rpn_offset   to lrat_tag3_rpn_offset+lrat_tag3_rpn_q'length-1),
            scout   => sov(lrat_tag3_rpn_offset   to lrat_tag3_rpn_offset+lrat_tag3_rpn_q'length-1),
            din     => lrat_tag3_rpn_d(64-real_addr_width   to 51),
            dout    => lrat_tag3_rpn_q(64-real_addr_width   to 51)  );
-- tag4   phase:  real page number latches
lrat_tag4_rpn_latch:   tri_rlmreg_p
  generic map (width => lrat_tag4_rpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag4_rpn_offset   to lrat_tag4_rpn_offset+lrat_tag4_rpn_q'length-1),
            scout   => sov(lrat_tag4_rpn_offset   to lrat_tag4_rpn_offset+lrat_tag4_rpn_q'length-1),
            din     => lrat_tag4_rpn_d(64-real_addr_width   to 51),
            dout    => lrat_tag4_rpn_q(64-real_addr_width   to 51)  );
-- tag3   phase:  hit status latches
lrat_tag3_hit_status_latch:   tri_rlmreg_p
  generic map (width => lrat_tag3_hit_status_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag3_hit_status_offset   to lrat_tag3_hit_status_offset+lrat_tag3_hit_status_q'length-1),
            scout   => sov(lrat_tag3_hit_status_offset   to lrat_tag3_hit_status_offset+lrat_tag3_hit_status_q'length-1),
            din     => lrat_tag3_hit_status_d,
            dout    => lrat_tag3_hit_status_q    );
-- tag3   phase:  hit entry latches
lrat_tag3_hit_entry_latch:   tri_rlmreg_p
  generic map (width => lrat_tag3_hit_entry_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20+2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag3_hit_entry_offset   to lrat_tag3_hit_entry_offset+lrat_tag3_hit_entry_q'length-1),
            scout   => sov(lrat_tag3_hit_entry_offset   to lrat_tag3_hit_entry_offset+lrat_tag3_hit_entry_q'length-1),
            din     => lrat_tag3_hit_entry_d,
            dout    => lrat_tag3_hit_entry_q    );
-- tag4   phase:  hit status latches
lrat_tag4_hit_status_latch:   tri_rlmreg_p
  generic map (width => lrat_tag4_hit_status_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag4_hit_status_offset   to lrat_tag4_hit_status_offset+lrat_tag4_hit_status_q'length-1),
            scout   => sov(lrat_tag4_hit_status_offset   to lrat_tag4_hit_status_offset+lrat_tag4_hit_status_q'length-1),
            din     => lrat_tag4_hit_status_d,
            dout    => lrat_tag4_hit_status_q    );
-- tag4   phase:  hit entry latches
lrat_tag4_hit_entry_latch:   tri_rlmreg_p
  generic map (width => lrat_tag4_hit_entry_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20+3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag4_hit_entry_offset   to lrat_tag4_hit_entry_offset+lrat_tag4_hit_entry_q'length-1),
            scout   => sov(lrat_tag4_hit_entry_offset   to lrat_tag4_hit_entry_offset+lrat_tag4_hit_entry_q'length-1),
            din     => lrat_tag4_hit_entry_d,
            dout    => lrat_tag4_hit_entry_q    );
lrat_tag1_lpid_latch: tri_rlmreg_p
  generic map (width => lrat_tag1_lpid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag1_lpid_offset to lrat_tag1_lpid_offset+lrat_tag1_lpid_q'length-1),
            scout   => sov(lrat_tag1_lpid_offset to lrat_tag1_lpid_offset+lrat_tag1_lpid_q'length-1),
            din     => lrat_tag1_lpid_d,
            dout    => lrat_tag1_lpid_q  );
lrat_tag1_size_latch: tri_rlmreg_p
  generic map (width => lrat_tag1_size_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag1_size_offset to lrat_tag1_size_offset+lrat_tag1_size_q'length-1),
            scout   => sov(lrat_tag1_size_offset to lrat_tag1_size_offset+lrat_tag1_size_q'length-1),
            din     => lrat_tag1_size_d,
            dout    => lrat_tag1_size_q  );
lrat_tag2_size_latch: tri_rlmreg_p
  generic map (width => lrat_tag2_size_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(21),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag2_size_offset to lrat_tag2_size_offset+lrat_tag2_size_q'length-1),
            scout   => sov(lrat_tag2_size_offset to lrat_tag2_size_offset+lrat_tag2_size_q'length-1),
            din     => lrat_tag2_size_d,
            dout    => lrat_tag2_size_q  );
lrat_tag2_entry_size_latch: tri_rlmreg_p
  generic map (width => lrat_tag2_entry_size_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(21),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag2_entry_size_offset to lrat_tag2_entry_size_offset+lrat_tag2_entry_size_q'length-1),
            scout   => sov(lrat_tag2_entry_size_offset to lrat_tag2_entry_size_offset+lrat_tag2_entry_size_q'length-1),
            din     => lrat_tag2_entry_size_d,
            dout    => lrat_tag2_entry_size_q  );
lrat_tag2_matchline_latch: tri_rlmreg_p
  generic map (width => lrat_tag2_matchline_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(21),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_tag2_matchline_offset to lrat_tag2_matchline_offset+lrat_tag2_matchline_q'length-1),
            scout   => sov(lrat_tag2_matchline_offset to lrat_tag2_matchline_offset+lrat_tag2_matchline_q'length-1),
            din     => lrat_tag2_matchline_d,
            dout    => lrat_tag2_matchline_q  );
tlb_addr_cap_latch: tri_rlmreg_p
  generic map (width => tlb_addr_cap_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tlb_delayed_act(20),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(tlb_addr_cap_offset to tlb_addr_cap_offset+tlb_addr_cap_q'length-1),
            scout   => sov(tlb_addr_cap_offset to tlb_addr_cap_offset+tlb_addr_cap_q'length-1),
            din     => tlb_addr_cap_d,
            dout    => tlb_addr_cap_q  );
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
lrat_entry_act_latch: tri_rlmreg_p
  generic map (width => lrat_entry_act_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lrat_entry_act_offset to lrat_entry_act_offset+lrat_entry_act_q'length-1),
            scout   => sov(lrat_entry_act_offset to lrat_entry_act_offset+lrat_entry_act_q'length-1),
            din     => lrat_entry_act_d,
            dout    => lrat_entry_act_q  );
lrat_mas_act_latch: tri_rlmreg_p
  generic map (width => lrat_mas_act_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lrat_mas_act_offset to lrat_mas_act_offset+lrat_mas_act_q'length-1),
            scout   => sov(lrat_mas_act_offset to lrat_mas_act_offset+lrat_mas_act_q'length-1),
            din     => lrat_mas_act_d,
            dout    => lrat_mas_act_q  );
lrat_datain_act_latch: tri_rlmreg_p
  generic map (width => lrat_datain_act_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lrat_datain_act_offset to lrat_datain_act_offset+lrat_datain_act_q'length-1),
            scout   => sov(lrat_datain_act_offset to lrat_datain_act_offset+lrat_datain_act_q'length-1),
            din     => lrat_datain_act_d,
            dout    => lrat_datain_act_q  );
-- LRAT entry latches
lrat_entry0_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry0_valid_offset),
            scout   => sov(lrat_entry0_valid_offset),
            din     => lrat_entry0_valid_d,
            dout    => lrat_entry0_valid_q);
lrat_entry0_xbit_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry0_xbit_offset),
            scout   => sov(lrat_entry0_xbit_offset),
            din     => lrat_entry0_xbit_d,
            dout    => lrat_entry0_xbit_q);
lrat_entry0_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry0_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry0_lpn_offset   to lrat_entry0_lpn_offset+lrat_entry0_lpn_q'length-1),
            scout   => sov(lrat_entry0_lpn_offset   to lrat_entry0_lpn_offset+lrat_entry0_lpn_q'length-1),
            din     => lrat_entry0_lpn_d,
            dout    => lrat_entry0_lpn_q    );
lrat_entry0_rpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry0_rpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry0_rpn_offset   to lrat_entry0_rpn_offset+lrat_entry0_rpn_q'length-1),
            scout   => sov(lrat_entry0_rpn_offset   to lrat_entry0_rpn_offset+lrat_entry0_rpn_q'length-1),
            din     => lrat_entry0_rpn_d,
            dout    => lrat_entry0_rpn_q    );
lrat_entry0_lpid_latch:   tri_rlmreg_p
  generic map (width => lrat_entry0_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry0_lpid_offset   to lrat_entry0_lpid_offset+lrat_entry0_lpid_q'length-1),
            scout   => sov(lrat_entry0_lpid_offset   to lrat_entry0_lpid_offset+lrat_entry0_lpid_q'length-1),
            din     => lrat_entry0_lpid_d,
            dout    => lrat_entry0_lpid_q    );
lrat_entry0_size_latch:   tri_rlmreg_p
  generic map (width => lrat_entry0_size_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry0_size_offset   to lrat_entry0_size_offset+lrat_entry0_size_q'length-1),
            scout   => sov(lrat_entry0_size_offset   to lrat_entry0_size_offset+lrat_entry0_size_q'length-1),
            din     => lrat_entry0_size_d,
            dout    => lrat_entry0_size_q    );
lrat_entry0_cmpmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry0_cmpmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry0_cmpmask_offset   to lrat_entry0_cmpmask_offset+lrat_entry0_cmpmask_q'length-1),
            scout   => sov(lrat_entry0_cmpmask_offset   to lrat_entry0_cmpmask_offset+lrat_entry0_cmpmask_q'length-1),
            din     => lrat_entry0_cmpmask_d,
            dout    => lrat_entry0_cmpmask_q    );
lrat_entry0_xbitmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry0_xbitmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry0_xbitmask_offset   to lrat_entry0_xbitmask_offset+lrat_entry0_xbitmask_q'length-1),
            scout   => sov(lrat_entry0_xbitmask_offset   to lrat_entry0_xbitmask_offset+lrat_entry0_xbitmask_q'length-1),
            din     => lrat_entry0_xbitmask_d,
            dout    => lrat_entry0_xbitmask_q    );
lrat_entry1_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry1_valid_offset),
            scout   => sov(lrat_entry1_valid_offset),
            din     => lrat_entry1_valid_d,
            dout    => lrat_entry1_valid_q);
lrat_entry1_xbit_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry1_xbit_offset),
            scout   => sov(lrat_entry1_xbit_offset),
            din     => lrat_entry1_xbit_d,
            dout    => lrat_entry1_xbit_q);
lrat_entry1_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry1_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry1_lpn_offset   to lrat_entry1_lpn_offset+lrat_entry1_lpn_q'length-1),
            scout   => sov(lrat_entry1_lpn_offset   to lrat_entry1_lpn_offset+lrat_entry1_lpn_q'length-1),
            din     => lrat_entry1_lpn_d,
            dout    => lrat_entry1_lpn_q    );
lrat_entry1_rpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry1_rpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry1_rpn_offset   to lrat_entry1_rpn_offset+lrat_entry1_rpn_q'length-1),
            scout   => sov(lrat_entry1_rpn_offset   to lrat_entry1_rpn_offset+lrat_entry1_rpn_q'length-1),
            din     => lrat_entry1_rpn_d,
            dout    => lrat_entry1_rpn_q    );
lrat_entry1_lpid_latch:   tri_rlmreg_p
  generic map (width => lrat_entry1_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry1_lpid_offset   to lrat_entry1_lpid_offset+lrat_entry1_lpid_q'length-1),
            scout   => sov(lrat_entry1_lpid_offset   to lrat_entry1_lpid_offset+lrat_entry1_lpid_q'length-1),
            din     => lrat_entry1_lpid_d,
            dout    => lrat_entry1_lpid_q    );
lrat_entry1_size_latch:   tri_rlmreg_p
  generic map (width => lrat_entry1_size_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry1_size_offset   to lrat_entry1_size_offset+lrat_entry1_size_q'length-1),
            scout   => sov(lrat_entry1_size_offset   to lrat_entry1_size_offset+lrat_entry1_size_q'length-1),
            din     => lrat_entry1_size_d,
            dout    => lrat_entry1_size_q    );
lrat_entry1_cmpmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry1_cmpmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry1_cmpmask_offset   to lrat_entry1_cmpmask_offset+lrat_entry1_cmpmask_q'length-1),
            scout   => sov(lrat_entry1_cmpmask_offset   to lrat_entry1_cmpmask_offset+lrat_entry1_cmpmask_q'length-1),
            din     => lrat_entry1_cmpmask_d,
            dout    => lrat_entry1_cmpmask_q    );
lrat_entry1_xbitmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry1_xbitmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry1_xbitmask_offset   to lrat_entry1_xbitmask_offset+lrat_entry1_xbitmask_q'length-1),
            scout   => sov(lrat_entry1_xbitmask_offset   to lrat_entry1_xbitmask_offset+lrat_entry1_xbitmask_q'length-1),
            din     => lrat_entry1_xbitmask_d,
            dout    => lrat_entry1_xbitmask_q    );
lrat_entry2_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry2_valid_offset),
            scout   => sov(lrat_entry2_valid_offset),
            din     => lrat_entry2_valid_d,
            dout    => lrat_entry2_valid_q);
lrat_entry2_xbit_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry2_xbit_offset),
            scout   => sov(lrat_entry2_xbit_offset),
            din     => lrat_entry2_xbit_d,
            dout    => lrat_entry2_xbit_q);
lrat_entry2_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry2_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry2_lpn_offset   to lrat_entry2_lpn_offset+lrat_entry2_lpn_q'length-1),
            scout   => sov(lrat_entry2_lpn_offset   to lrat_entry2_lpn_offset+lrat_entry2_lpn_q'length-1),
            din     => lrat_entry2_lpn_d,
            dout    => lrat_entry2_lpn_q    );
lrat_entry2_rpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry2_rpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry2_rpn_offset   to lrat_entry2_rpn_offset+lrat_entry2_rpn_q'length-1),
            scout   => sov(lrat_entry2_rpn_offset   to lrat_entry2_rpn_offset+lrat_entry2_rpn_q'length-1),
            din     => lrat_entry2_rpn_d,
            dout    => lrat_entry2_rpn_q    );
lrat_entry2_lpid_latch:   tri_rlmreg_p
  generic map (width => lrat_entry2_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry2_lpid_offset   to lrat_entry2_lpid_offset+lrat_entry2_lpid_q'length-1),
            scout   => sov(lrat_entry2_lpid_offset   to lrat_entry2_lpid_offset+lrat_entry2_lpid_q'length-1),
            din     => lrat_entry2_lpid_d,
            dout    => lrat_entry2_lpid_q    );
lrat_entry2_size_latch:   tri_rlmreg_p
  generic map (width => lrat_entry2_size_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry2_size_offset   to lrat_entry2_size_offset+lrat_entry2_size_q'length-1),
            scout   => sov(lrat_entry2_size_offset   to lrat_entry2_size_offset+lrat_entry2_size_q'length-1),
            din     => lrat_entry2_size_d,
            dout    => lrat_entry2_size_q    );
lrat_entry2_cmpmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry2_cmpmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry2_cmpmask_offset   to lrat_entry2_cmpmask_offset+lrat_entry2_cmpmask_q'length-1),
            scout   => sov(lrat_entry2_cmpmask_offset   to lrat_entry2_cmpmask_offset+lrat_entry2_cmpmask_q'length-1),
            din     => lrat_entry2_cmpmask_d,
            dout    => lrat_entry2_cmpmask_q    );
lrat_entry2_xbitmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry2_xbitmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry2_xbitmask_offset   to lrat_entry2_xbitmask_offset+lrat_entry2_xbitmask_q'length-1),
            scout   => sov(lrat_entry2_xbitmask_offset   to lrat_entry2_xbitmask_offset+lrat_entry2_xbitmask_q'length-1),
            din     => lrat_entry2_xbitmask_d,
            dout    => lrat_entry2_xbitmask_q    );
lrat_entry3_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry3_valid_offset),
            scout   => sov(lrat_entry3_valid_offset),
            din     => lrat_entry3_valid_d,
            dout    => lrat_entry3_valid_q);
lrat_entry3_xbit_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry3_xbit_offset),
            scout   => sov(lrat_entry3_xbit_offset),
            din     => lrat_entry3_xbit_d,
            dout    => lrat_entry3_xbit_q);
lrat_entry3_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry3_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry3_lpn_offset   to lrat_entry3_lpn_offset+lrat_entry3_lpn_q'length-1),
            scout   => sov(lrat_entry3_lpn_offset   to lrat_entry3_lpn_offset+lrat_entry3_lpn_q'length-1),
            din     => lrat_entry3_lpn_d,
            dout    => lrat_entry3_lpn_q    );
lrat_entry3_rpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry3_rpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry3_rpn_offset   to lrat_entry3_rpn_offset+lrat_entry3_rpn_q'length-1),
            scout   => sov(lrat_entry3_rpn_offset   to lrat_entry3_rpn_offset+lrat_entry3_rpn_q'length-1),
            din     => lrat_entry3_rpn_d,
            dout    => lrat_entry3_rpn_q    );
lrat_entry3_lpid_latch:   tri_rlmreg_p
  generic map (width => lrat_entry3_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry3_lpid_offset   to lrat_entry3_lpid_offset+lrat_entry3_lpid_q'length-1),
            scout   => sov(lrat_entry3_lpid_offset   to lrat_entry3_lpid_offset+lrat_entry3_lpid_q'length-1),
            din     => lrat_entry3_lpid_d,
            dout    => lrat_entry3_lpid_q    );
lrat_entry3_size_latch:   tri_rlmreg_p
  generic map (width => lrat_entry3_size_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry3_size_offset   to lrat_entry3_size_offset+lrat_entry3_size_q'length-1),
            scout   => sov(lrat_entry3_size_offset   to lrat_entry3_size_offset+lrat_entry3_size_q'length-1),
            din     => lrat_entry3_size_d,
            dout    => lrat_entry3_size_q    );
lrat_entry3_cmpmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry3_cmpmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry3_cmpmask_offset   to lrat_entry3_cmpmask_offset+lrat_entry3_cmpmask_q'length-1),
            scout   => sov(lrat_entry3_cmpmask_offset   to lrat_entry3_cmpmask_offset+lrat_entry3_cmpmask_q'length-1),
            din     => lrat_entry3_cmpmask_d,
            dout    => lrat_entry3_cmpmask_q    );
lrat_entry3_xbitmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry3_xbitmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry3_xbitmask_offset   to lrat_entry3_xbitmask_offset+lrat_entry3_xbitmask_q'length-1),
            scout   => sov(lrat_entry3_xbitmask_offset   to lrat_entry3_xbitmask_offset+lrat_entry3_xbitmask_q'length-1),
            din     => lrat_entry3_xbitmask_d,
            dout    => lrat_entry3_xbitmask_q    );
lrat_entry4_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry4_valid_offset),
            scout   => sov(lrat_entry4_valid_offset),
            din     => lrat_entry4_valid_d,
            dout    => lrat_entry4_valid_q);
lrat_entry4_xbit_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry4_xbit_offset),
            scout   => sov(lrat_entry4_xbit_offset),
            din     => lrat_entry4_xbit_d,
            dout    => lrat_entry4_xbit_q);
lrat_entry4_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry4_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry4_lpn_offset   to lrat_entry4_lpn_offset+lrat_entry4_lpn_q'length-1),
            scout   => sov(lrat_entry4_lpn_offset   to lrat_entry4_lpn_offset+lrat_entry4_lpn_q'length-1),
            din     => lrat_entry4_lpn_d,
            dout    => lrat_entry4_lpn_q    );
lrat_entry4_rpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry4_rpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry4_rpn_offset   to lrat_entry4_rpn_offset+lrat_entry4_rpn_q'length-1),
            scout   => sov(lrat_entry4_rpn_offset   to lrat_entry4_rpn_offset+lrat_entry4_rpn_q'length-1),
            din     => lrat_entry4_rpn_d,
            dout    => lrat_entry4_rpn_q    );
lrat_entry4_lpid_latch:   tri_rlmreg_p
  generic map (width => lrat_entry4_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry4_lpid_offset   to lrat_entry4_lpid_offset+lrat_entry4_lpid_q'length-1),
            scout   => sov(lrat_entry4_lpid_offset   to lrat_entry4_lpid_offset+lrat_entry4_lpid_q'length-1),
            din     => lrat_entry4_lpid_d,
            dout    => lrat_entry4_lpid_q    );
lrat_entry4_size_latch:   tri_rlmreg_p
  generic map (width => lrat_entry4_size_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry4_size_offset   to lrat_entry4_size_offset+lrat_entry4_size_q'length-1),
            scout   => sov(lrat_entry4_size_offset   to lrat_entry4_size_offset+lrat_entry4_size_q'length-1),
            din     => lrat_entry4_size_d,
            dout    => lrat_entry4_size_q    );
lrat_entry4_cmpmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry4_cmpmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry4_cmpmask_offset   to lrat_entry4_cmpmask_offset+lrat_entry4_cmpmask_q'length-1),
            scout   => sov(lrat_entry4_cmpmask_offset   to lrat_entry4_cmpmask_offset+lrat_entry4_cmpmask_q'length-1),
            din     => lrat_entry4_cmpmask_d,
            dout    => lrat_entry4_cmpmask_q    );
lrat_entry4_xbitmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry4_xbitmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry4_xbitmask_offset   to lrat_entry4_xbitmask_offset+lrat_entry4_xbitmask_q'length-1),
            scout   => sov(lrat_entry4_xbitmask_offset   to lrat_entry4_xbitmask_offset+lrat_entry4_xbitmask_q'length-1),
            din     => lrat_entry4_xbitmask_d,
            dout    => lrat_entry4_xbitmask_q    );
lrat_entry5_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(5),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry5_valid_offset),
            scout   => sov(lrat_entry5_valid_offset),
            din     => lrat_entry5_valid_d,
            dout    => lrat_entry5_valid_q);
lrat_entry5_xbit_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(5),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry5_xbit_offset),
            scout   => sov(lrat_entry5_xbit_offset),
            din     => lrat_entry5_xbit_d,
            dout    => lrat_entry5_xbit_q);
lrat_entry5_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry5_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(5),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry5_lpn_offset   to lrat_entry5_lpn_offset+lrat_entry5_lpn_q'length-1),
            scout   => sov(lrat_entry5_lpn_offset   to lrat_entry5_lpn_offset+lrat_entry5_lpn_q'length-1),
            din     => lrat_entry5_lpn_d,
            dout    => lrat_entry5_lpn_q    );
lrat_entry5_rpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry5_rpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(5),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry5_rpn_offset   to lrat_entry5_rpn_offset+lrat_entry5_rpn_q'length-1),
            scout   => sov(lrat_entry5_rpn_offset   to lrat_entry5_rpn_offset+lrat_entry5_rpn_q'length-1),
            din     => lrat_entry5_rpn_d,
            dout    => lrat_entry5_rpn_q    );
lrat_entry5_lpid_latch:   tri_rlmreg_p
  generic map (width => lrat_entry5_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(5),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry5_lpid_offset   to lrat_entry5_lpid_offset+lrat_entry5_lpid_q'length-1),
            scout   => sov(lrat_entry5_lpid_offset   to lrat_entry5_lpid_offset+lrat_entry5_lpid_q'length-1),
            din     => lrat_entry5_lpid_d,
            dout    => lrat_entry5_lpid_q    );
lrat_entry5_size_latch:   tri_rlmreg_p
  generic map (width => lrat_entry5_size_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(5),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry5_size_offset   to lrat_entry5_size_offset+lrat_entry5_size_q'length-1),
            scout   => sov(lrat_entry5_size_offset   to lrat_entry5_size_offset+lrat_entry5_size_q'length-1),
            din     => lrat_entry5_size_d,
            dout    => lrat_entry5_size_q    );
lrat_entry5_cmpmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry5_cmpmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(5),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry5_cmpmask_offset   to lrat_entry5_cmpmask_offset+lrat_entry5_cmpmask_q'length-1),
            scout   => sov(lrat_entry5_cmpmask_offset   to lrat_entry5_cmpmask_offset+lrat_entry5_cmpmask_q'length-1),
            din     => lrat_entry5_cmpmask_d,
            dout    => lrat_entry5_cmpmask_q    );
lrat_entry5_xbitmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry5_xbitmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(5),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry5_xbitmask_offset   to lrat_entry5_xbitmask_offset+lrat_entry5_xbitmask_q'length-1),
            scout   => sov(lrat_entry5_xbitmask_offset   to lrat_entry5_xbitmask_offset+lrat_entry5_xbitmask_q'length-1),
            din     => lrat_entry5_xbitmask_d,
            dout    => lrat_entry5_xbitmask_q    );
lrat_entry6_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(6),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry6_valid_offset),
            scout   => sov(lrat_entry6_valid_offset),
            din     => lrat_entry6_valid_d,
            dout    => lrat_entry6_valid_q);
lrat_entry6_xbit_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(6),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry6_xbit_offset),
            scout   => sov(lrat_entry6_xbit_offset),
            din     => lrat_entry6_xbit_d,
            dout    => lrat_entry6_xbit_q);
lrat_entry6_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry6_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(6),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry6_lpn_offset   to lrat_entry6_lpn_offset+lrat_entry6_lpn_q'length-1),
            scout   => sov(lrat_entry6_lpn_offset   to lrat_entry6_lpn_offset+lrat_entry6_lpn_q'length-1),
            din     => lrat_entry6_lpn_d,
            dout    => lrat_entry6_lpn_q    );
lrat_entry6_rpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry6_rpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(6),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry6_rpn_offset   to lrat_entry6_rpn_offset+lrat_entry6_rpn_q'length-1),
            scout   => sov(lrat_entry6_rpn_offset   to lrat_entry6_rpn_offset+lrat_entry6_rpn_q'length-1),
            din     => lrat_entry6_rpn_d,
            dout    => lrat_entry6_rpn_q    );
lrat_entry6_lpid_latch:   tri_rlmreg_p
  generic map (width => lrat_entry6_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(6),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry6_lpid_offset   to lrat_entry6_lpid_offset+lrat_entry6_lpid_q'length-1),
            scout   => sov(lrat_entry6_lpid_offset   to lrat_entry6_lpid_offset+lrat_entry6_lpid_q'length-1),
            din     => lrat_entry6_lpid_d,
            dout    => lrat_entry6_lpid_q    );
lrat_entry6_size_latch:   tri_rlmreg_p
  generic map (width => lrat_entry6_size_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(6),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry6_size_offset   to lrat_entry6_size_offset+lrat_entry6_size_q'length-1),
            scout   => sov(lrat_entry6_size_offset   to lrat_entry6_size_offset+lrat_entry6_size_q'length-1),
            din     => lrat_entry6_size_d,
            dout    => lrat_entry6_size_q    );
lrat_entry6_cmpmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry6_cmpmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(6),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry6_cmpmask_offset   to lrat_entry6_cmpmask_offset+lrat_entry6_cmpmask_q'length-1),
            scout   => sov(lrat_entry6_cmpmask_offset   to lrat_entry6_cmpmask_offset+lrat_entry6_cmpmask_q'length-1),
            din     => lrat_entry6_cmpmask_d,
            dout    => lrat_entry6_cmpmask_q    );
lrat_entry6_xbitmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry6_xbitmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(6),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry6_xbitmask_offset   to lrat_entry6_xbitmask_offset+lrat_entry6_xbitmask_q'length-1),
            scout   => sov(lrat_entry6_xbitmask_offset   to lrat_entry6_xbitmask_offset+lrat_entry6_xbitmask_q'length-1),
            din     => lrat_entry6_xbitmask_d,
            dout    => lrat_entry6_xbitmask_q    );
lrat_entry7_valid_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(7),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry7_valid_offset),
            scout   => sov(lrat_entry7_valid_offset),
            din     => lrat_entry7_valid_d,
            dout    => lrat_entry7_valid_q);
lrat_entry7_xbit_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(7),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry7_xbit_offset),
            scout   => sov(lrat_entry7_xbit_offset),
            din     => lrat_entry7_xbit_d,
            dout    => lrat_entry7_xbit_q);
lrat_entry7_lpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry7_lpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(7),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry7_lpn_offset   to lrat_entry7_lpn_offset+lrat_entry7_lpn_q'length-1),
            scout   => sov(lrat_entry7_lpn_offset   to lrat_entry7_lpn_offset+lrat_entry7_lpn_q'length-1),
            din     => lrat_entry7_lpn_d,
            dout    => lrat_entry7_lpn_q    );
lrat_entry7_rpn_latch:   tri_rlmreg_p
  generic map (width => lrat_entry7_rpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(7),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry7_rpn_offset   to lrat_entry7_rpn_offset+lrat_entry7_rpn_q'length-1),
            scout   => sov(lrat_entry7_rpn_offset   to lrat_entry7_rpn_offset+lrat_entry7_rpn_q'length-1),
            din     => lrat_entry7_rpn_d,
            dout    => lrat_entry7_rpn_q    );
lrat_entry7_lpid_latch:   tri_rlmreg_p
  generic map (width => lrat_entry7_lpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(7),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry7_lpid_offset   to lrat_entry7_lpid_offset+lrat_entry7_lpid_q'length-1),
            scout   => sov(lrat_entry7_lpid_offset   to lrat_entry7_lpid_offset+lrat_entry7_lpid_q'length-1),
            din     => lrat_entry7_lpid_d,
            dout    => lrat_entry7_lpid_q    );
lrat_entry7_size_latch:   tri_rlmreg_p
  generic map (width => lrat_entry7_size_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(7),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry7_size_offset   to lrat_entry7_size_offset+lrat_entry7_size_q'length-1),
            scout   => sov(lrat_entry7_size_offset   to lrat_entry7_size_offset+lrat_entry7_size_q'length-1),
            din     => lrat_entry7_size_d,
            dout    => lrat_entry7_size_q    );
lrat_entry7_cmpmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry7_cmpmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(7),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry7_cmpmask_offset   to lrat_entry7_cmpmask_offset+lrat_entry7_cmpmask_q'length-1),
            scout   => sov(lrat_entry7_cmpmask_offset   to lrat_entry7_cmpmask_offset+lrat_entry7_cmpmask_q'length-1),
            din     => lrat_entry7_cmpmask_d,
            dout    => lrat_entry7_cmpmask_q    );
lrat_entry7_xbitmask_latch:   tri_rlmreg_p
  generic map (width => lrat_entry7_xbitmask_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_entry_act_q(7),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_entry7_xbitmask_offset   to lrat_entry7_xbitmask_offset+lrat_entry7_xbitmask_q'length-1),
            scout   => sov(lrat_entry7_xbitmask_offset   to lrat_entry7_xbitmask_offset+lrat_entry7_xbitmask_q'length-1),
            din     => lrat_entry7_xbitmask_d,
            dout    => lrat_entry7_xbitmask_q    );
lrat_datain_lpn_latch: tri_rlmreg_p
  generic map (width => lrat_datain_lpn_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_datain_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_datain_lpn_offset to lrat_datain_lpn_offset+lrat_datain_lpn_q'length-1),
            scout   => sov(lrat_datain_lpn_offset to lrat_datain_lpn_offset+lrat_datain_lpn_q'length-1),
            din     => lrat_datain_lpn_d,
            dout    => lrat_datain_lpn_q  );
lrat_datain_rpn_latch: tri_rlmreg_p
  generic map (width => lrat_datain_rpn_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_datain_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_datain_rpn_offset to lrat_datain_rpn_offset+lrat_datain_rpn_q'length-1),
            scout   => sov(lrat_datain_rpn_offset to lrat_datain_rpn_offset+lrat_datain_rpn_q'length-1),
            din     => lrat_datain_rpn_d,
            dout    => lrat_datain_rpn_q  );
lrat_datain_lpid_latch: tri_rlmreg_p
  generic map (width => lrat_datain_lpid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_datain_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_datain_lpid_offset to lrat_datain_lpid_offset+lrat_datain_lpid_q'length-1),
            scout   => sov(lrat_datain_lpid_offset to lrat_datain_lpid_offset+lrat_datain_lpid_q'length-1),
            din     => lrat_datain_lpid_d,
            dout    => lrat_datain_lpid_q  );
lrat_datain_size_latch: tri_rlmreg_p
  generic map (width => lrat_datain_size_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_datain_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_datain_size_offset to lrat_datain_size_offset+lrat_datain_size_q'length-1),
            scout   => sov(lrat_datain_size_offset to lrat_datain_size_offset+lrat_datain_size_q'length-1),
            din     => lrat_datain_size_d,
            dout    => lrat_datain_size_q  );
lrat_datain_valid_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_datain_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_datain_valid_offset),
            scout   => sov(lrat_datain_valid_offset),
            din     => lrat_datain_valid_d,
            dout    => lrat_datain_valid_q);
lrat_datain_xbit_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_datain_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_datain_xbit_offset),
            scout   => sov(lrat_datain_xbit_offset),
            din     => lrat_datain_xbit_d,
            dout    => lrat_datain_xbit_q);
lrat_mas1_v_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mas1_v_offset),
            scout   => sov(lrat_mas1_v_offset),
            din     => lrat_mas1_v_d,
            dout    => lrat_mas1_v_q);
lrat_mmucr3_x_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mmucr3_x_offset),
            scout   => sov(lrat_mmucr3_x_offset),
            din     => lrat_mmucr3_x_d,
            dout    => lrat_mmucr3_x_q);
lrat_mas1_tsize_latch: tri_rlmreg_p
  generic map (width => lrat_mas1_tsize_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mas1_tsize_offset to lrat_mas1_tsize_offset+lrat_mas1_tsize_q'length-1),
            scout   => sov(lrat_mas1_tsize_offset to lrat_mas1_tsize_offset+lrat_mas1_tsize_q'length-1),
            din     => lrat_mas1_tsize_d,
            dout    => lrat_mas1_tsize_q  );
lrat_mas2_epn_latch: tri_rlmreg_p
  generic map (width => lrat_mas2_epn_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mas2_epn_offset to lrat_mas2_epn_offset+lrat_mas2_epn_q'length-1),
            scout   => sov(lrat_mas2_epn_offset to lrat_mas2_epn_offset+lrat_mas2_epn_q'length-1),
            din     => lrat_mas2_epn_d,
            dout    => lrat_mas2_epn_q  );
lrat_mas3_rpnl_latch: tri_rlmreg_p
  generic map (width => lrat_mas3_rpnl_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mas3_rpnl_offset to lrat_mas3_rpnl_offset+lrat_mas3_rpnl_q'length-1),
            scout   => sov(lrat_mas3_rpnl_offset to lrat_mas3_rpnl_offset+lrat_mas3_rpnl_q'length-1),
            din     => lrat_mas3_rpnl_d,
            dout    => lrat_mas3_rpnl_q  );
lrat_mas7_rpnu_latch: tri_rlmreg_p
  generic map (width => lrat_mas7_rpnu_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mas7_rpnu_offset to lrat_mas7_rpnu_offset+lrat_mas7_rpnu_q'length-1),
            scout   => sov(lrat_mas7_rpnu_offset to lrat_mas7_rpnu_offset+lrat_mas7_rpnu_q'length-1),
            din     => lrat_mas7_rpnu_d,
            dout    => lrat_mas7_rpnu_q  );
lrat_mas8_tlpid_latch: tri_rlmreg_p
  generic map (width => lrat_mas8_tlpid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mas8_tlpid_offset to lrat_mas8_tlpid_offset+lrat_mas8_tlpid_q'length-1),
            scout   => sov(lrat_mas8_tlpid_offset to lrat_mas8_tlpid_offset+lrat_mas8_tlpid_q'length-1),
            din     => lrat_mas8_tlpid_d,
            dout    => lrat_mas8_tlpid_q  );
lrat_mas_thdid_latch: tri_rlmreg_p
  generic map (width => lrat_mas_thdid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mas_thdid_offset to lrat_mas_thdid_offset+lrat_mas_thdid_q'length-1),
            scout   => sov(lrat_mas_thdid_offset to lrat_mas_thdid_offset+lrat_mas_thdid_q'length-1),
            din     => lrat_mas_thdid_d,
            dout    => lrat_mas_thdid_q  );
lrat_mas_tlbre_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mas_tlbre_offset),
            scout   => sov(lrat_mas_tlbre_offset),
            din     => lrat_mas_tlbre_d,
            dout    => lrat_mas_tlbre_q  );
lrat_mas_tlbsx_hit_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mas_tlbsx_hit_offset),
            scout   => sov(lrat_mas_tlbsx_hit_offset),
            din     => lrat_mas_tlbsx_hit_d,
            dout    => lrat_mas_tlbsx_hit_q  );
lrat_mas_tlbsx_miss_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => lrat_mas_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(lrat_mas_tlbsx_miss_offset),
            scout   => sov(lrat_mas_tlbsx_miss_offset),
            din     => lrat_mas_tlbsx_miss_d,
            dout    => lrat_mas_tlbsx_miss_q  );
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
siv(0 TO scan_right) <=  sov(1 to scan_right) & ac_func_scan_in;
ac_func_scan_out  <=  sov(0);
END MMQ_TLB_LRAT;
