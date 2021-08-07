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
--* TITLE: Memory Management Unit Invalidate Control Logic
--* NAME: mmq_inval.vhdl
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

entity mmq_inval is
  generic(thdid_width       : integer := 4;
            ttype_width        : integer := 6;
            state_width        : integer := 2;
            pid_width          : integer := 14;
            lpid_width         : integer := 8;
            t_width            : integer := 3;
            rs_is_width        : integer := 9;
            rs_data_width      : integer := 64;
            epn_width          : integer := 52;
            real_addr_width    : integer := 42;
            rpn_width          : integer := 30;  
            inv_seq_width      : integer := 6;
            tlb_ways          : natural := 4;
            tlb_addr_width    : natural := 7;
            tlb_way_width     : natural := 168;
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

     ac_func_scan_in          : in     std_ulogic;
     ac_func_scan_out         : out    std_ulogic;

     pc_sg_2                : in     std_ulogic;
     pc_func_sl_thold_2     : in     std_ulogic;
     pc_func_slp_sl_thold_2 : in     std_ulogic;
     pc_func_slp_nsl_thold_2  : in std_ulogic;
     pc_fce_2               : in     std_ulogic;
     mmucr2_act_override     : in     std_ulogic;
     xu_mm_ccr2_notlb        : in std_ulogic;
     xu_mm_ccr2_notlb_b      : out std_ulogic_vector(1 to 12);  

     mm_iu_ierat_snoop_coming   : out std_ulogic;  
     mm_iu_ierat_snoop_val      : out std_ulogic;
     mm_iu_ierat_snoop_attr     : out std_ulogic_vector(0 to 25);  
     mm_iu_ierat_snoop_vpn      : out std_ulogic_vector(52-epn_width to 51);
     iu_mm_ierat_snoop_ack      : in std_ulogic;

     mm_xu_derat_snoop_coming   : out std_ulogic;  
     mm_xu_derat_snoop_val      : out std_ulogic;
     mm_xu_derat_snoop_attr     : out std_ulogic_vector(0 to 25);  
     mm_xu_derat_snoop_vpn      : out std_ulogic_vector(52-epn_width to 51);
     xu_mm_derat_snoop_ack      : in std_ulogic;
     tlb_snoop_coming           : out std_ulogic;  
     tlb_snoop_val              : out std_ulogic;
     tlb_snoop_attr             : out std_ulogic_vector(0 to 34);  
     tlb_snoop_vpn              : out std_ulogic_vector(52-epn_width to 51);
     tlb_snoop_ack              : in std_ulogic;
     an_ac_back_inv             : in std_ulogic;
     an_ac_back_inv_target      : in std_ulogic;
     an_ac_back_inv_local       : in std_ulogic;
     an_ac_back_inv_lbit        : in std_ulogic;
     an_ac_back_inv_gs          : in std_ulogic;
     an_ac_back_inv_ind         : in std_ulogic;
     an_ac_back_inv_addr        : in std_ulogic_vector(64-real_addr_width to 63);
     an_ac_back_inv_lpar_id     : in std_ulogic_vector(0 to lpid_width-1);
     ac_an_power_managed        : in   std_ulogic; 
     ac_an_back_inv_reject      : out std_ulogic;
     mmucr0_0     : in std_ulogic_vector(2 to 19);
     mmucr0_1     : in std_ulogic_vector(2 to 19);
     mmucr0_2     : in std_ulogic_vector(2 to 19);
     mmucr0_3     : in std_ulogic_vector(2 to 19);
     mmucr1       : in std_ulogic_vector(12 to 19);  
     mmucr1_csinv : in std_ulogic_vector(0 to 1);    
     lpidr        : in std_ulogic_vector(0 to lpid_width-1);

     mas5_0_sgs             : in std_ulogic;  
     mas5_0_slpid           : in std_ulogic_vector(0 to 7);  
     mas6_0_spid            : in std_ulogic_vector(0 to 13);  
     mas6_0_isize           : in std_ulogic_vector(0 to 3);  
     mas6_0_sind            : in std_ulogic;  
     mas6_0_sas             : in std_ulogic;  
     mas5_1_sgs             : in std_ulogic;  
     mas5_1_slpid           : in std_ulogic_vector(0 to 7);  
     mas6_1_spid            : in std_ulogic_vector(0 to 13);  
     mas6_1_isize           : in std_ulogic_vector(0 to 3);  
     mas6_1_sind            : in std_ulogic;  
     mas6_1_sas             : in std_ulogic;  
     mas5_2_sgs             : in std_ulogic;  
     mas5_2_slpid           : in std_ulogic_vector(0 to 7);  
     mas6_2_spid            : in std_ulogic_vector(0 to 13);  
     mas6_2_isize           : in std_ulogic_vector(0 to 3);  
     mas6_2_sind            : in std_ulogic;  
     mas6_2_sas             : in std_ulogic;  
     mas5_3_sgs             : in std_ulogic;  
     mas5_3_slpid           : in std_ulogic_vector(0 to 7);  
     mas6_3_spid            : in std_ulogic_vector(0 to 13);  
     mas6_3_isize           : in std_ulogic_vector(0 to 3);  
     mas6_3_sind            : in std_ulogic;  
     mas6_3_sas             : in std_ulogic;  
     mmucsr0_tlb0fi         : in std_ulogic;
     mmq_inval_tlb0fi_done  : out std_ulogic;


     xu_mm_rf1_val           : in std_ulogic_vector(0 to thdid_width-1);
     xu_mm_rf1_is_tlbivax    : in std_ulogic;
     xu_mm_rf1_is_tlbilx     : in std_ulogic;
     xu_mm_rf1_is_erativax   : in std_ulogic;
     xu_mm_rf1_is_eratilx    : in std_ulogic;
     xu_mm_ex1_rs_is         : in std_ulogic_vector(0 to rs_is_width-1);
     xu_mm_ex1_is_isync      : in std_ulogic;
     xu_mm_ex1_is_csync      : in std_ulogic;
     xu_mm_ex2_eff_addr      : in std_ulogic_vector(64-rs_data_width to 63);
     xu_mm_rf1_t             : in std_ulogic_vector(0 to t_width-1);
     xu_mm_msr_gs            : in std_ulogic_vector(0 to thdid_width-1);
     xu_mm_msr_pr            : in std_ulogic_vector(0 to thdid_width-1);
     xu_mm_spr_epcr_dgtmi    : in std_ulogic_vector(0 to thdid_width-1);
     xu_mm_epcr_dgtmi        : out std_ulogic_vector(0 to thdid_width-1);
     xu_rf1_flush            : in std_ulogic_vector(0 to thdid_width-1);
     xu_ex1_flush            : in std_ulogic_vector(0 to thdid_width-1);
     xu_ex2_flush            : in std_ulogic_vector(0 to thdid_width-1);
     xu_ex3_flush            : in std_ulogic_vector(0 to thdid_width-1);
     xu_ex4_flush            : in std_ulogic_vector(0 to thdid_width-1);
     xu_ex5_flush            : in std_ulogic_vector(0 to thdid_width-1);
     xu_mm_lmq_stq_empty     : in std_ulogic;
     xu_mm_hold_ack          : in std_ulogic_vector(0 to thdid_width-1);
     iu_mm_lmq_empty         : in std_ulogic; 
     tlb_ctl_barrier_done    : in std_ulogic_vector(0 to thdid_width-1);
     tlb_ctl_ex2_flush_req   : in std_ulogic_vector(0 to thdid_width-1); 
     tlb_ctl_ex2_illeg_instr : in std_ulogic_vector(0 to thdid_width-1); 
     tlb_ctl_quiesce         : in std_ulogic_vector(0 to thdid_width-1);
     tlb_req_quiesce         : in std_ulogic_vector(0 to thdid_width-1);

     mm_iu_barrier_done      : out std_ulogic_vector(0 to thdid_width-1);
     mm_xu_ex3_flush_req     : out std_ulogic_vector(0 to thdid_width-1);
     mm_xu_hold_req          : out std_ulogic_vector(0 to thdid_width-1);
     mm_xu_hold_done         : out std_ulogic_vector(0 to thdid_width-1);
     mm_xu_illeg_instr       : out std_ulogic_vector(0 to thdid_width-1);
     mm_xu_local_snoop_reject       : out std_ulogic_vector(0 to thdid_width-1);  
     mm_xu_quiesce           : out std_ulogic_vector(0 to thdid_width-1);

     inval_perf_tlbilx             : out std_ulogic;
     inval_perf_tlbivax            : out std_ulogic;
     inval_perf_tlbivax_snoop      : out std_ulogic;
     inval_perf_tlb_flush          : out std_ulogic;

     htw_lsu_req_valid        : in     std_ulogic;    
     htw_lsu_thdid            : in     std_ulogic_vector(0 to thdid_width-1);    
     htw_lsu_ttype            : in     std_ulogic_vector(0 to 1); 
     htw_lsu_wimge            : in     std_ulogic_vector(0 to 4);
     htw_lsu_u                : in     std_ulogic_vector(0 to 3);    
     htw_lsu_addr             : in     std_ulogic_vector(64-real_addr_width to 63);
     htw_lsu_req_taken        : out    std_ulogic;             
     htw_quiesce              : in     std_ulogic_vector(0 to thdid_width-1);
     tlbwe_back_inv_valid     : in     std_ulogic;                                
     tlbwe_back_inv_thdid     : in     std_ulogic_vector(0 to thdid_width-1);  
     tlbwe_back_inv_addr      : in     std_ulogic_vector(52-epn_width to 51);  
     tlbwe_back_inv_attr      : in     std_ulogic_vector(0 to 34);             
     tlb_tag5_write           : in     std_ulogic;             
     tlbwe_back_inv_pending   : out    std_ulogic;            

     mm_xu_lsu_req              : out     std_ulogic_vector(0 to thdid_width-1);    
     mm_xu_lsu_ttype            : out     std_ulogic_vector(0 to 1); 
     mm_xu_lsu_wimge            : out     std_ulogic_vector(0 to 4);
     mm_xu_lsu_u                : out     std_ulogic_vector(0 to 3);    
     mm_xu_lsu_addr             : out     std_ulogic_vector(64-real_addr_width to 63);
     mm_xu_lsu_lpid             : out  std_ulogic_vector(0 to 7); 
     mm_xu_lsu_gs               : out  std_ulogic;  
     mm_xu_lsu_ind              : out  std_ulogic;  
     mm_xu_lsu_lbit             : out  std_ulogic;  
     xu_mm_lsu_token            : in    std_ulogic;             

     inval_dbg_seq_q                  : out std_ulogic_vector(0 to 4);
     inval_dbg_seq_idle               : out std_ulogic;
     inval_dbg_seq_snoop_inprogress   : out std_ulogic;
     inval_dbg_seq_snoop_done         : out std_ulogic;
     inval_dbg_seq_local_done         : out std_ulogic;
     inval_dbg_seq_tlb0fi_done        : out std_ulogic;
     inval_dbg_seq_tlbwe_snoop_done   : out std_ulogic;
     inval_dbg_ex6_valid              : out std_ulogic;
     inval_dbg_ex6_thdid              : out std_ulogic_vector(0 to 1);  
     inval_dbg_ex6_ttype              : out std_ulogic_vector(0 to 2);  
     inval_dbg_snoop_forme            : out std_ulogic;
     inval_dbg_snoop_local_reject     : out std_ulogic;
     inval_dbg_an_ac_back_inv_q       : out std_ulogic_vector(2 to 8);    
     inval_dbg_an_ac_back_inv_lpar_id_q   : out std_ulogic_vector(0 to 7);
     inval_dbg_an_ac_back_inv_addr_q      : out std_ulogic_vector(22 to 63);
     inval_dbg_snoop_valid_q          : out std_ulogic_vector(0 to 2);
     inval_dbg_snoop_ack_q            : out std_ulogic_vector(0 to 2);
     inval_dbg_snoop_attr_q           : out std_ulogic_vector(0 to 34);
     inval_dbg_snoop_attr_tlb_spec_q  : out std_ulogic_vector(18 to 19);
     inval_dbg_snoop_vpn_q            : out std_ulogic_vector(17 to 51);
     inval_dbg_lsu_tokens_q           : out std_ulogic_vector(0 to 1)
);
end mmq_inval;
architecture mmq_inval of mmq_inval is
constant MMU_Mode_Value : std_ulogic := '0';
constant ERAT_Mode_Value : std_ulogic := '1';
constant TlbSel_Tlb : std_ulogic_vector(0 to 1) := "00";
constant TlbSel_IErat : std_ulogic_vector(0 to 1) := "10";
constant TlbSel_DErat : std_ulogic_vector(0 to 1) := "11";
constant TLB_PgSize_1GB   : std_ulogic_vector(0 to 3) := "1010";
constant TLB_PgSize_16MB  : std_ulogic_vector(0 to 3) := "0111";
constant TLB_PgSize_1MB   : std_ulogic_vector(0 to 3) := "0101";
constant TLB_PgSize_64KB  : std_ulogic_vector(0 to 3) := "0011";
constant TLB_PgSize_4KB   : std_ulogic_vector(0 to 3) := "0001";
constant TLB_PgSize_256MB : std_ulogic_vector(0 to 3) := "1001";
constant InvSeq_Idle  : std_ulogic_vector(0 to 5) := "000000";
constant InvSeq_Stg1  : std_ulogic_vector(0 to 5) := "000001";
constant InvSeq_Stg2  : std_ulogic_vector(0 to 5) := "000011";
constant InvSeq_Stg3  : std_ulogic_vector(0 to 5) := "000010";
constant InvSeq_Stg4  : std_ulogic_vector(0 to 5) := "000110";
constant InvSeq_Stg5  : std_ulogic_vector(0 to 5) := "000100";
constant InvSeq_Stg6  : std_ulogic_vector(0 to 5) := "000101";
constant InvSeq_Stg7  : std_ulogic_vector(0 to 5) := "000111";
constant InvSeq_Stg8  : std_ulogic_vector(0 to 5) := "001000";
constant InvSeq_Stg9  : std_ulogic_vector(0 to 5) := "001001";
constant InvSeq_Stg10 : std_ulogic_vector(0 to 5) := "001011";
constant InvSeq_Stg11 : std_ulogic_vector(0 to 5) := "001010";
constant InvSeq_Stg12 : std_ulogic_vector(0 to 5) := "001110";
constant InvSeq_Stg13 : std_ulogic_vector(0 to 5) := "001100";
constant InvSeq_Stg14 : std_ulogic_vector(0 to 5) := "001101";
constant InvSeq_Stg15 : std_ulogic_vector(0 to 5) := "001111";
constant InvSeq_Stg16 : std_ulogic_vector(0 to 5) := "010000";
constant InvSeq_Stg17 : std_ulogic_vector(0 to 5) := "010001";
constant InvSeq_Stg18 : std_ulogic_vector(0 to 5) := "010011";
constant InvSeq_Stg19 : std_ulogic_vector(0 to 5) := "010010";
constant InvSeq_Stg20 : std_ulogic_vector(0 to 5) := "010110";
constant InvSeq_Stg21 : std_ulogic_vector(0 to 5) := "010100";
constant InvSeq_Stg22 : std_ulogic_vector(0 to 5) := "010101";
constant InvSeq_Stg23 : std_ulogic_vector(0 to 5) := "010111";
constant InvSeq_Stg24 : std_ulogic_vector(0 to 5) := "011000";
constant InvSeq_Stg25 : std_ulogic_vector(0 to 5) := "011001";
constant InvSeq_Stg26 : std_ulogic_vector(0 to 5) := "011011";
constant InvSeq_Stg27 : std_ulogic_vector(0 to 5) := "011010";
constant InvSeq_Stg28 : std_ulogic_vector(0 to 5) := "011110";
constant InvSeq_Stg29 : std_ulogic_vector(0 to 5) := "011100";
constant InvSeq_Stg30 : std_ulogic_vector(0 to 5) := "011101";
constant InvSeq_Stg31 : std_ulogic_vector(0 to 5) := "011111";
constant InvSeq_Stg32 : std_ulogic_vector(0 to 5) := "100000";
-- mmucr1 bits:  12:13-ICTID/ITTID,14:15-DCTID/DTTID,16:17-resv, TLBI_MSB/TLBI_REJ
constant pos_ictid : natural := 12;
constant pos_ittid : natural := 13;
constant pos_dctid : natural := 14;
constant pos_dttid : natural := 15;
constant pos_tlbi_msb : natural := 18;
constant pos_tlbi_rej : natural := 19;
constant ex1_valid_offset           : natural := 0;
constant ex1_ttype_offset           : natural := ex1_valid_offset + thdid_width;
constant ex1_state_offset           : natural := ex1_ttype_offset + ttype_width-2;
constant ex1_t_offset               : natural := ex1_state_offset + state_width;
constant ex2_valid_offset           : natural := ex1_t_offset + t_width;
constant ex2_ttype_offset           : natural := ex2_valid_offset + thdid_width;
constant ex2_rs_is_offset           : natural := ex2_ttype_offset + ttype_width;
constant ex2_state_offset           : natural := ex2_rs_is_offset + rs_is_width;
constant ex2_t_offset               : natural := ex2_state_offset + state_width;
constant ex3_valid_offset           : natural := ex2_t_offset + t_width;
constant ex3_ttype_offset           : natural := ex3_valid_offset + thdid_width;
constant ex3_rs_is_offset           : natural := ex3_ttype_offset + ttype_width;
constant ex3_state_offset           : natural := ex3_rs_is_offset + rs_is_width;
constant ex3_t_offset               : natural := ex3_state_offset + state_width;
constant ex3_flush_req_offset       : natural := ex3_t_offset + t_width;
constant ex3_ea_offset              : natural := ex3_flush_req_offset + thdid_width;
constant ex4_valid_offset           : natural := ex3_ea_offset + epn_width+12;
constant ex4_ttype_offset           : natural := ex4_valid_offset + thdid_width;
constant ex4_rs_is_offset           : natural := ex4_ttype_offset + ttype_width;
constant ex4_state_offset           : natural := ex4_rs_is_offset + rs_is_width;
constant ex4_t_offset               : natural := ex4_state_offset + state_width;
constant ex5_valid_offset           : natural := ex4_t_offset + t_width;
constant ex5_ttype_offset           : natural := ex5_valid_offset + thdid_width;
constant ex5_rs_is_offset           : natural := ex5_ttype_offset + ttype_width;
constant ex5_state_offset           : natural := ex5_rs_is_offset + rs_is_width;
constant ex5_t_offset               : natural := ex5_state_offset + state_width;
constant ex6_valid_offset           : natural := ex5_t_offset + t_width;
constant ex6_ttype_offset           : natural := ex6_valid_offset + thdid_width;
constant ex6_isel_offset            : natural := ex6_ttype_offset + ttype_width;
constant ex6_size_offset            : natural := ex6_isel_offset + 3;
constant ex6_gs_offset              : natural := ex6_size_offset + 4;
constant ex6_ts_offset              : natural := ex6_gs_offset + 1;
constant ex6_ind_offset             : natural := ex6_ts_offset + 1;
constant ex6_pid_offset             : natural := ex6_ind_offset + 1;
constant ex6_lpid_offset            : natural := ex6_pid_offset + pid_width;
constant inv_seq_offset             : natural := ex6_lpid_offset + lpid_width;
constant hold_req_offset            : natural := inv_seq_offset + inv_seq_width;
constant hold_ack_offset            : natural := hold_req_offset + thdid_width;
constant hold_done_offset           : natural := hold_ack_offset + thdid_width;
constant local_barrier_offset       : natural := hold_done_offset + thdid_width;
constant global_barrier_offset      : natural := local_barrier_offset + thdid_width;
constant barrier_done_offset        : natural := global_barrier_offset + thdid_width;
constant illeg_instr_offset         : natural := barrier_done_offset + thdid_width;
constant local_reject_offset        : natural := illeg_instr_offset + thdid_width;
constant snoop_valid_offset         : natural := local_reject_offset + thdid_width;
constant snoop_attr_offset          : natural := snoop_valid_offset + 3;
constant snoop_vpn_offset           : natural := snoop_attr_offset + 35;
constant snoop_attr_clone_offset    : natural := snoop_vpn_offset + epn_width;
constant snoop_attr_tlb_spec_offset : natural := snoop_attr_clone_offset + 26;
constant snoop_vpn_clone_offset     : natural := snoop_attr_tlb_spec_offset + 2;
constant snoop_ack_offset           : natural := snoop_vpn_clone_offset + epn_width;
constant snoop_coming_offset        : natural := snoop_ack_offset + 3;
constant mm_xu_quiesce_offset       : natural := snoop_coming_offset + 5;
constant inv_seq_inprogress_offset  : natural := mm_xu_quiesce_offset + thdid_width;
constant xu_mm_ccr2_notlb_offset    : natural := inv_seq_inprogress_offset + 6;
constant spare_offset      : natural := xu_mm_ccr2_notlb_offset + 13;
constant an_ac_back_inv_offset      : natural := spare_offset + 16;
constant an_ac_back_inv_addr_offset : natural := an_ac_back_inv_offset + 9;
constant an_ac_back_inv_lpar_id_offset : natural := an_ac_back_inv_addr_offset + real_addr_width;
constant lsu_tokens_offset    :  natural := an_ac_back_inv_lpar_id_offset + lpid_width;
constant lsu_req_offset       :  natural := lsu_tokens_offset + 2;
constant lsu_ttype_offset     :  natural := lsu_req_offset + thdid_width;
constant lsu_ubits_offset     :  natural := lsu_ttype_offset + 2;
constant lsu_wimge_offset     :  natural := lsu_ubits_offset+ 4;
constant lsu_addr_offset      :  natural := lsu_wimge_offset + 5;
constant lsu_lpid_offset      : natural := lsu_addr_offset + real_addr_width;
constant lsu_ind_offset       : natural := lsu_lpid_offset + lpid_width;
constant lsu_gs_offset        : natural := lsu_ind_offset + 1;
constant lsu_lbit_offset      : natural := lsu_gs_offset + 1;
constant power_managed_offset      : natural := lsu_lbit_offset + 1;
constant tlbwe_back_inv_offset         : natural := power_managed_offset + 4;
constant tlbwe_back_inv_addr_offset    : natural := tlbwe_back_inv_offset + thdid_width + 2;
constant tlbwe_back_inv_attr_offset    : natural := tlbwe_back_inv_addr_offset + epn_width;
constant scan_right                  : natural := tlbwe_back_inv_attr_offset + 35 - 1;
signal ex1_valid_d, ex1_valid_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex1_ttype_d, ex1_ttype_q            : std_ulogic_vector(0 to ttype_width-3);
signal ex1_state_d, ex1_state_q            : std_ulogic_vector(0 to state_width-1);
signal ex1_t_d, ex1_t_q                    : std_ulogic_vector(0 to t_width-1);
signal ex2_valid_d, ex2_valid_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex2_ttype_d, ex2_ttype_q            : std_ulogic_vector(0 to ttype_width-1);
signal ex2_rs_is_d, ex2_rs_is_q            : std_ulogic_vector(0 to rs_is_width-1);
signal ex2_state_d, ex2_state_q            : std_ulogic_vector(0 to state_width-1);
signal ex2_t_d, ex2_t_q                    : std_ulogic_vector(0 to t_width-1);
signal ex3_ea_d, ex3_ea_q                  : std_ulogic_vector(64-rs_data_width to 63);
signal ex3_valid_d, ex3_valid_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex3_ttype_d, ex3_ttype_q            : std_ulogic_vector(0 to ttype_width-1);
signal ex3_rs_is_d, ex3_rs_is_q            : std_ulogic_vector(0 to rs_is_width-1);
signal ex3_state_d, ex3_state_q            : std_ulogic_vector(0 to state_width-1);
signal ex3_t_d, ex3_t_q                    : std_ulogic_vector(0 to t_width-1);
signal ex3_flush_req_d, ex3_flush_req_q    : std_ulogic_vector(0 to thdid_width-1);
signal ex4_valid_d, ex4_valid_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex4_ttype_d, ex4_ttype_q            : std_ulogic_vector(0 to ttype_width-1);
signal ex4_rs_is_d, ex4_rs_is_q            : std_ulogic_vector(0 to rs_is_width-1);
signal ex4_state_d, ex4_state_q            : std_ulogic_vector(0 to state_width-1);
signal ex4_t_d, ex4_t_q                    : std_ulogic_vector(0 to t_width-1);
signal ex5_valid_d, ex5_valid_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex5_ttype_d, ex5_ttype_q            : std_ulogic_vector(0 to ttype_width-1);
signal ex5_rs_is_d, ex5_rs_is_q            : std_ulogic_vector(0 to rs_is_width-1);
signal ex5_state_d, ex5_state_q            : std_ulogic_vector(0 to state_width-1);
signal ex5_t_d, ex5_t_q                    : std_ulogic_vector(0 to t_width-1);
signal ex6_valid_d, ex6_valid_q            : std_ulogic_vector(0 to thdid_width-1);
signal ex6_ttype_d, ex6_ttype_q            : std_ulogic_vector(0 to ttype_width-1);
signal ex6_isel_d, ex6_isel_q              : std_ulogic_vector(0 to 2);
signal ex6_size_d, ex6_size_q              : std_ulogic_vector(0 to 3);
signal ex6_gs_d, ex6_gs_q                  : std_ulogic;
signal ex6_ts_d, ex6_ts_q                  : std_ulogic;
signal ex6_ind_d, ex6_ind_q                : std_ulogic;
signal ex6_pid_d, ex6_pid_q                : std_ulogic_vector(0 to pid_width-1);
signal ex6_lpid_d, ex6_lpid_q              : std_ulogic_vector(0 to lpid_width-1);
signal inv_seq_d, inv_seq_q            : std_ulogic_vector(0 to 5);
signal hold_req_d, hold_req_q          : std_ulogic_vector(0 to thdid_width-1);
signal hold_ack_d, hold_ack_q          : std_ulogic_vector(0 to thdid_width-1);
signal hold_done_d, hold_done_q          : std_ulogic_vector(0 to thdid_width-1);
signal local_barrier_d, local_barrier_q  : std_ulogic_vector(0 to thdid_width-1);
signal global_barrier_d, global_barrier_q  : std_ulogic_vector(0 to thdid_width-1);
signal barrier_done_d, barrier_done_q    : std_ulogic_vector(0 to thdid_width-1);
signal illeg_instr_d, illeg_instr_q    : std_ulogic_vector(0 to thdid_width-1);
signal local_reject_d, local_reject_q    : std_ulogic_vector(0 to thdid_width-1);
signal inv_seq_inprogress_d, inv_seq_inprogress_q : std_ulogic_vector(0 to 5);
signal snoop_valid_d, snoop_valid_q      : std_ulogic_vector(0 to 2);
signal snoop_attr_d, snoop_attr_q        : std_ulogic_vector(0 to 34);
signal snoop_vpn_d,snoop_vpn_q           : std_ulogic_vector(52-epn_width to 51);
signal snoop_attr_clone_d, snoop_attr_clone_q        : std_ulogic_vector(0 to 25);
signal snoop_attr_tlb_spec_d, snoop_attr_tlb_spec_q        : std_ulogic_vector(18 to 19);
signal snoop_vpn_clone_d,snoop_vpn_clone_q           : std_ulogic_vector(52-epn_width to 51);
signal snoop_ack_d,snoop_ack_q           : std_ulogic_vector(0 to 2);
signal snoop_coming_d, snoop_coming_q    : std_ulogic_vector(0 to 4);
signal an_ac_back_inv_d, an_ac_back_inv_q             : std_ulogic_vector(0 to 8);
signal an_ac_back_inv_addr_d, an_ac_back_inv_addr_q        : std_ulogic_vector(64-real_addr_width to 63);
signal an_ac_back_inv_lpar_id_d, an_ac_back_inv_lpar_id_q    : std_ulogic_vector(0 to lpid_width-1);
signal lsu_tokens_d, lsu_tokens_q  : std_ulogic_vector(0 to 1);
signal lsu_req_d, lsu_req_q        : std_ulogic_vector(0 to thdid_width-1);
signal lsu_ttype_d, lsu_ttype_q    : std_ulogic_vector(0 to 1);
signal lsu_ubits_d, lsu_ubits_q    : std_ulogic_vector(0 to 3);
signal lsu_wimge_d, lsu_wimge_q    : std_ulogic_vector(0 to 4);
signal lsu_addr_d, lsu_addr_q      : std_ulogic_vector(64-real_addr_width to 63);
signal lsu_lpid_d, lsu_lpid_q      : std_ulogic_vector(0 to lpid_width-1);
signal lsu_ind_d, lsu_ind_q        : std_ulogic;
signal lsu_gs_d, lsu_gs_q          : std_ulogic;
signal lsu_lbit_d, lsu_lbit_q      : std_ulogic;
signal xu_mm_ccr2_notlb_d, xu_mm_ccr2_notlb_q      : std_ulogic_vector(0 to 12);
signal xu_mm_epcr_dgtmi_q     : std_ulogic_vector(0 to thdid_width-1);
signal lpidr_q     : std_ulogic_vector(0 to lpid_width-1);
signal mmucr1_q     : std_ulogic_vector(12 to 19);
signal mmucr1_csinv_q     : std_ulogic_vector(0 to 1);
signal spare_q     : std_ulogic_vector(0 to 15);
signal power_managed_d, power_managed_q    : std_ulogic_vector(0 to 3);
signal mm_xu_quiesce_d, mm_xu_quiesce_q    : std_ulogic_vector(0 to thdid_width-1);
signal inval_quiesce_b                     : std_ulogic_vector(0 to thdid_width-1);
signal inv_seq_local_done      : std_ulogic;
signal inv_seq_snoop_done      : std_ulogic;
signal inv_seq_hold_req        : std_ulogic_vector(0 to thdid_width-1);
signal inv_seq_hold_done       : std_ulogic_vector(0 to thdid_width-1);
signal inv_seq_tlbi_load    : std_ulogic;
signal inv_seq_tlbi_complete   : std_ulogic;
signal inv_seq_tlb_snoop_val   : std_ulogic;
signal inv_seq_htw_load        : std_ulogic;
signal inv_seq_ierat_snoop_val : std_ulogic;
signal inv_seq_derat_snoop_val : std_ulogic;
signal inv_seq_snoop_inprogress : std_ulogic;
signal inv_seq_snoop_inprogress_q : std_ulogic_vector(0 to 1);
signal inv_seq_local_inprogress : std_ulogic;
signal inv_seq_local_barrier_set    : std_ulogic;
signal inv_seq_global_barrier_set    : std_ulogic;
signal inv_seq_local_barrier_done    : std_ulogic;
signal inv_seq_global_barrier_done    : std_ulogic;
signal inv_seq_idle    : std_ulogic;
signal inval_snoop_forme       : std_ulogic;
signal inval_snoop_local_reject : std_ulogic;
signal ex6_size_large      : std_ulogic;
signal inv_seq_tlb0fi_inprogress : std_ulogic;
signal inv_seq_tlb0fi_inprogress_q : std_ulogic_vector(0 to 1);
signal inv_seq_tlb0fi_done : std_ulogic;
signal ex3_ea_hold  : std_ulogic;
signal htw_lsu_req_taken_sig         :    std_ulogic;
signal inv_seq_tlbwe_inprogress      : std_ulogic;
signal inv_seq_tlbwe_inprogress_q     : std_ulogic_vector(0 to 1);
signal inv_seq_tlbwe_snoop_done      : std_ulogic;
signal tlbwe_back_inv_tid_nz         : std_ulogic;
signal tlbwe_back_inv_d, tlbwe_back_inv_q              : std_ulogic_vector(0 to thdid_width+1);
signal tlbwe_back_inv_addr_d, tlbwe_back_inv_addr_q    : std_ulogic_vector(52-epn_width to 51);
signal tlbwe_back_inv_attr_d, tlbwe_back_inv_attr_q    : std_ulogic_vector(0 to 34);
signal back_inv_tid_nz   : std_ulogic;
signal ex6_tid_nz   : std_ulogic;
signal ex2_rs_pgsize_not_supp : std_ulogic;
signal mas6_isize_not_supp         : std_ulogic_vector(0 to thdid_width-1);
signal ex2_hv_state    : std_ulogic;
signal ex2_priv_state  : std_ulogic;
signal ex2_dgtmi_state  : std_ulogic;
signal ex5_hv_state    : std_ulogic;
signal ex5_priv_state  : std_ulogic;
signal ex5_dgtmi_state  : std_ulogic;
signal unused_dc  :  std_ulogic_vector(0 to 12);
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
signal pc_func_slp_nsl_thold_1   : std_ulogic;
signal pc_func_slp_nsl_thold_0   : std_ulogic;
signal pc_func_slp_nsl_thold_0_b : std_ulogic;
signal pc_func_sl_force     : std_ulogic;
signal pc_func_slp_sl_force : std_ulogic;
signal pc_func_slp_nsl_force : std_ulogic;
signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);
signal tidn                     : std_ulogic;
signal tiup                     : std_ulogic;
begin
tidn <= '0';
tiup <= '1';
xu_mm_ccr2_notlb_d <= (others => xu_mm_ccr2_notlb);
power_managed_d(0) <= ac_an_power_managed;
power_managed_d(1) <= power_managed_q(1);
power_managed_d(2) <= power_managed_q(2);
power_managed_d(3) <= power_managed_q(3);
mm_xu_quiesce <= mm_xu_quiesce_q;
mm_xu_quiesce_d <= tlb_req_quiesce and tlb_ctl_quiesce and
                 htw_quiesce and
                 not inval_quiesce_b;
-- not quiesced
inval_quiesce_b <=  ( (0 to thdid_width-1 => or_reduce(inv_seq_q)) and ex6_valid_q(0 to thdid_width-1) );
ex1_valid_d <= xu_mm_rf1_val and not(xu_rf1_flush);
ex1_ttype_d(0 to ttype_width-3) <= xu_mm_rf1_is_tlbilx & xu_mm_rf1_is_tlbivax & xu_mm_rf1_is_eratilx & xu_mm_rf1_is_erativax;
ex1_state_d(0) <= or_reduce(xu_mm_msr_gs and xu_mm_rf1_val);
ex1_state_d(1) <= or_reduce(xu_mm_msr_pr and xu_mm_rf1_val);
ex1_t_d <= xu_mm_rf1_t;
ex2_valid_d <= ex1_valid_q and not(xu_ex1_flush);
ex2_ttype_d(0 to ttype_width-3) <= ex1_ttype_q(0 to ttype_width-3);
ex2_ttype_d(ttype_width-2 to ttype_width-1) <= xu_mm_ex1_is_csync & xu_mm_ex1_is_isync;
ex2_rs_is_d <= xu_mm_ex1_rs_is;
-- RS(55)    -> Local  rs_is(0)
-- RS(56:57) -> IS     rs_is(1 to 2)
-- RS(58:59) -> Class  rs_is(3 to 4)
-- RS(60:63) -> Size   rs_is(5 to 8)
ex2_state_d <= ex1_state_q;
ex2_t_d <= ex1_t_q;
-- ex2 effective addr capture latch.. hold addr until inv_seq done with it
ex3_ea_hold <= (or_reduce(ex3_valid_q) and or_reduce(ex3_ttype_q(0 to 3)))  
            or (or_reduce(ex4_valid_q) and or_reduce(ex4_ttype_q(0 to 3)))  
            or (or_reduce(ex5_valid_q) and or_reduce(ex5_ttype_q(0 to 3)))  
            or (or_reduce(ex6_valid_q) and or_reduce(ex6_ttype_q(0 to 3)));
ex3_ea_d <= (ex3_ea_q and (64-rs_data_width to 63 => ex3_ea_hold))  
         or (xu_mm_ex2_eff_addr and (64-rs_data_width to 63 => not ex3_ea_hold));
ex2_hv_state   <= not ex2_state_q(0) and not ex2_state_q(1);
ex2_priv_state <= not ex2_state_q(1);
ex2_dgtmi_state <= or_reduce(ex2_valid_q and xu_mm_epcr_dgtmi_q);
ex3_valid_d <= ex2_valid_q and not(xu_ex2_flush);
--ex3_ttype_d <= ex2_ttype_q;
ex3_ttype_d(0 to ttype_width-3) <= ex2_ttype_q(0 to ttype_width-3);
ex3_ttype_d(ttype_width-2) <= (ex2_ttype_q(ttype_width-2) and not mmucr1_csinv_q(0));
ex3_ttype_d(ttype_width-1) <= (ex2_ttype_q(ttype_width-1) and not mmucr1_csinv_q(1));
ex3_rs_is_d <= ex2_rs_is_q;
ex3_state_d <= ex2_state_q;
ex3_t_d <= ex2_t_q;
ex3_flush_req_d <= (ex2_valid_q and not(xu_ex2_flush)) 
               when ( ex2_ttype_q(0 to 3)/="0000" and 
                        ( inv_seq_idle='0' or 
                          (ex3_valid_q/="0000" and ex3_ttype_q(0 to 3)/="0000") or 
                          (ex4_valid_q/="0000" and ex4_ttype_q(0 to 3)/="0000") or 
                          (ex5_valid_q/="0000" and ex5_ttype_q(0 to 3)/="0000") or 
                          (ex6_valid_q/="0000" and ex6_ttype_q(0 to 3)/="0000") ) ) 
              else tlb_ctl_ex2_flush_req;
ex4_valid_d <= ex3_valid_q and not(xu_ex3_flush);
ex4_ttype_d <= ex3_ttype_q;
ex4_rs_is_d <= ex3_rs_is_q;
ex4_state_d <= ex3_state_q;
ex4_t_d <= ex3_t_q;
ex5_valid_d <= ex4_valid_q and not(xu_ex4_flush);
ex5_ttype_d <= ex4_ttype_q;
ex5_rs_is_d <= ex4_rs_is_q;
ex5_state_d <= ex4_state_q;
ex5_t_d <= ex4_t_q;
ex5_hv_state   <= not ex5_state_q(0) and not ex5_state_q(1);
ex5_priv_state <= not ex5_state_q(1);
ex5_dgtmi_state <= or_reduce(ex5_valid_q and xu_mm_epcr_dgtmi_q);
-- these are ex6 capture latches.. hold op until inv_seq done with it
ex6_valid_d <= "0000" when inv_seq_local_done='1'
         else (ex5_valid_q and not(xu_ex5_flush)) when  ( ex6_valid_q="0000" and
                ((ex5_ttype_q(0)='1' and ex5_priv_state='1' and ex5_dgtmi_state='0') or   
                  (ex5_ttype_q(0)='1' and ex5_hv_state='1' and ex5_dgtmi_state='1') or    
                   (or_reduce(ex5_ttype_q(1 to 3))='1' and ex5_hv_state='1')) )             
         else ex6_valid_q;
--ttype <= tlbilx & tlbivax & eratilx & erativax & csync & isync;
ex6_ttype_d <= ex5_ttype_q when (ex5_valid_q /= "0000" and ex5_ttype_q(0 to 3)/="0000" and ex6_valid_q="0000") 
         else ex6_ttype_q;
--                            ttype ->    0        1         2          3
--                sources for ttype -> tlbilx   tlbivax   eratilx   erativax
-- RS(55)    -> Local  rs_is(0)           1        0         1          0
-- RS(56:57) -> IS     rs_is(1 to 2)    f(T)      11        f(T)    RS(56:57)
-- RS(58:59) -> Class  rs_is(3 to 4)    g(T)      00        g(T)    RS(58:59)
-- RS(60:63) -> Size   rs_is(5 to 8)    mas6     mas6       n/a     RS(60:63)
--              TS (state(1))           mas6     mas6      mmucr0    mmucr0
--              TID                     mas6     mas6      mmucr0    mmucr0
--              GS (state(0))           mas5     mas5      mmucr0    mmucr0
--              LPID                    mas5     mas5      lpidr     lpidr
--              IND                     mas6     mas6        0         0
ex6_isel_d <= '1' & ex5_rs_is_q(3 to 4)  when (ex5_valid_q /= "0000" and ex5_ttype_q(3)='1' and ex5_rs_is_q(1 to 2)="10" and ex6_valid_q="0000")
         else '0' & ex5_rs_is_q(1 to 2)  when (ex5_valid_q /= "0000" and ex5_ttype_q(3)='1' and ex5_rs_is_q(1 to 2)/="10" and ex6_valid_q="0000")
         else ex5_t_q(0 to 2) when (ex5_valid_q /= "0000" and ex5_ttype_q(2)='1' and ex6_valid_q="0000")
         else "011"            when (ex5_valid_q /= "0000" and ex5_ttype_q(1)='1' and ex6_valid_q="0000")
         else ex5_t_q(0 to 2) when (ex5_valid_q /= "0000" and ex5_ttype_q(0)='1' and ex6_valid_q="0000")
         else ex6_isel_q;
-- T field from tlbilx/eratilx is  0=all, 1=pid, 2=resvd/GS, 3=address, 4-7=class
-- ex1_rs_is(0 to 9) from erativax instr.
--   RS(55)    -> ex1_rs_is(0)   -> snoop_attr(0)     -> Local
--   RS(56:57) -> ex1_rs_is(1:2) -> snoop_attr(0:1)   -> IS
--   RS(58:59) -> ex1_rs_is(3:4) -> snoop_attr(2:3)   -> Class
--   n/a       ->  n/a           -> snoop_attr(4:5)   -> State
--   n/a       ->  n/a           -> snoop_attr(6:13)  -> TID(6:13)
--   RS(60:63) -> ex1_rs_is(5:8) -> snoop_attr(14:17) -> Size
--   n/a       ->  n/a           -> snoop_attr(20:25) -> TID(0:5)
-- erat snoop_attr:
--          0 -> Local
--        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
--        4:5 -> GS/TS
--       6:13 -> TID(6:13)
--      14:17 -> Size
--      18    -> TID_NZ
--      19    -> mmucsr0.tlb0fi
--      20:25 -> TID(0:5)
ex6_size_d <= ex5_rs_is_q(5 to 8) when (ex5_valid_q /= "0000" and ex5_ttype_q(3)='1' and ex6_valid_q="0000")
         else "0000" when (ex5_valid_q /= "0000" and ex5_ttype_q(2)='1' and ex6_valid_q="0000")
         else mas6_0_isize   when (ex5_valid_q(0)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_1_isize   when (ex5_valid_q(1)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_2_isize   when (ex5_valid_q(2)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_3_isize   when (ex5_valid_q(3)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else ex6_size_q;
ex6_size_large <= '1' when (ex6_size_q=TLB_PgSize_64KB or ex6_size_q=TLB_PgSize_1MB or 
                ex6_size_q=TLB_PgSize_16MB or ex6_size_q=TLB_PgSize_256MB or ex6_size_q=TLB_PgSize_1GB)
             else '0';
-- mmucr0: 0:1-ExtClass, 2:3-TGS/TS, 4:5-TLBSel, 6:19-TID,
ex6_gs_d <= mmucr0_0(2) when (ex5_valid_q(0)='1' and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else mmucr0_1(2)   when (ex5_valid_q(1)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else mmucr0_2(2)   when (ex5_valid_q(2)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else mmucr0_3(2)   when (ex5_valid_q(3)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else mas5_0_sgs   when (ex5_valid_q(0)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas5_1_sgs   when (ex5_valid_q(1)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas5_2_sgs   when (ex5_valid_q(2)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas5_3_sgs   when (ex5_valid_q(3)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else ex6_gs_q;
ex6_ts_d <= mmucr0_0(3) when (ex5_valid_q(0)='1' and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else mmucr0_1(3)   when (ex5_valid_q(1)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else mmucr0_2(3)   when (ex5_valid_q(2)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else mmucr0_3(3)   when (ex5_valid_q(3)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else mas6_0_sas   when (ex5_valid_q(0)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_1_sas   when (ex5_valid_q(1)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_2_sas   when (ex5_valid_q(2)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_3_sas   when (ex5_valid_q(3)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else ex6_ts_q;
ex6_ind_d <= '0' when (ex5_valid_q(0)='1' and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else '0' when (ex5_valid_q(1)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else '0' when (ex5_valid_q(2)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else '0' when (ex5_valid_q(3)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")
         else mas6_0_sind   when (ex5_valid_q(0)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_1_sind   when (ex5_valid_q(1)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_2_sind   when (ex5_valid_q(2)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_3_sind   when (ex5_valid_q(3)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else ex6_ind_q;
ex6_pid_d <=  mmucr0_0(6 to 19) when (ex5_valid_q(0)='1' and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")  
         else mmucr0_1(6   to 19) when (ex5_valid_q(1)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")  
         else mmucr0_2(6   to 19) when (ex5_valid_q(2)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")  
         else mmucr0_3(6   to 19) when (ex5_valid_q(3)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")  
         else mas6_0_spid   when (ex5_valid_q(0)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_1_spid   when (ex5_valid_q(1)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_2_spid   when (ex5_valid_q(2)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas6_3_spid   when (ex5_valid_q(3)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else ex6_pid_q;
ex6_lpid_d <=  lpidr_q when (ex5_valid_q(0)='1' and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")  
         else lpidr_q when (ex5_valid_q(1)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")  
         else lpidr_q when (ex5_valid_q(2)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")  
         else lpidr_q when (ex5_valid_q(3)='1'   and ex5_ttype_q(2 to 3)/="00" and ex6_valid_q="0000")  
         else mas5_0_slpid   when (ex5_valid_q(0)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas5_1_slpid   when (ex5_valid_q(1)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas5_2_slpid   when (ex5_valid_q(2)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else mas5_3_slpid   when (ex5_valid_q(3)='1'   and ex5_ttype_q(0 to 1)/="00" and ex6_valid_q="0000")
         else ex6_lpid_q;
-- an_ac_back_inv_q: 0=valid b-1, 1=target b-1, 2=valid b, 3=target b, 4=L, 5=GS, 6=IND, 7=local, 8=reject
-- iu barrier op shadow status
local_barrier_d <= (local_barrier_q and not(ex6_valid_q)) when inv_seq_local_barrier_done='1'
                else (ex6_valid_q or local_barrier_q) when inv_seq_local_barrier_set='1'
                else local_barrier_q;
global_barrier_d <= (others => '0') when ((inv_seq_global_barrier_done='1' and an_ac_back_inv_q(7)='1') or inval_snoop_local_reject='1') 
                else (ex6_valid_q or global_barrier_q) when inv_seq_global_barrier_set='1'
                else global_barrier_q;
barrier_done_d <= (local_barrier_q and ex6_valid_q) when inv_seq_local_barrier_done='1'
                 else global_barrier_q when ((inv_seq_global_barrier_done='1' and an_ac_back_inv_q(7)='1') or inval_snoop_local_reject='1') 
                 else tlb_ctl_barrier_done;
-- Illegal instr logic
ex2_rs_pgsize_not_supp <= '0' when (ex2_rs_is_q(5 to 8)=TLB_PgSize_4KB or ex2_rs_is_q(5 to 8)=TLB_PgSize_64KB or
                                      ex2_rs_is_q(5 to 8)=TLB_PgSize_1MB or  ex2_rs_is_q(5 to 8)=TLB_PgSize_16MB or
                                      ex2_rs_is_q(5 to 8)=TLB_PgSize_1GB ) else '1';
mas6_isize_not_supp(0)   <= '0' when ((mas6_0_isize=TLB_PgSize_4KB   or mas6_0_isize=TLB_PgSize_64KB   or
                                          mas6_0_isize=TLB_PgSize_1MB   or  mas6_0_isize=TLB_PgSize_16MB   or 
                                          mas6_0_isize=TLB_PgSize_1GB)   and mas6_0_sind='0')
                                    or ((mas6_0_isize=TLB_PgSize_1MB   or mas6_0_isize=TLB_PgSize_256MB)   and mas6_0_sind='1')   
                       else '1';
mas6_isize_not_supp(1)   <= '0' when ((mas6_1_isize=TLB_PgSize_4KB   or mas6_1_isize=TLB_PgSize_64KB   or
                                          mas6_1_isize=TLB_PgSize_1MB   or  mas6_1_isize=TLB_PgSize_16MB   or 
                                          mas6_1_isize=TLB_PgSize_1GB)   and mas6_1_sind='0')
                                    or ((mas6_1_isize=TLB_PgSize_1MB   or mas6_1_isize=TLB_PgSize_256MB)   and mas6_1_sind='1')   
                       else '1';
mas6_isize_not_supp(2)   <= '0' when ((mas6_2_isize=TLB_PgSize_4KB   or mas6_2_isize=TLB_PgSize_64KB   or
                                          mas6_2_isize=TLB_PgSize_1MB   or  mas6_2_isize=TLB_PgSize_16MB   or 
                                          mas6_2_isize=TLB_PgSize_1GB)   and mas6_2_sind='0')
                                    or ((mas6_2_isize=TLB_PgSize_1MB   or mas6_2_isize=TLB_PgSize_256MB)   and mas6_2_sind='1')   
                       else '1';
mas6_isize_not_supp(3)   <= '0' when ((mas6_3_isize=TLB_PgSize_4KB   or mas6_3_isize=TLB_PgSize_64KB   or
                                          mas6_3_isize=TLB_PgSize_1MB   or  mas6_3_isize=TLB_PgSize_16MB   or 
                                          mas6_3_isize=TLB_PgSize_1GB)   and mas6_3_sind='0')
                                    or ((mas6_3_isize=TLB_PgSize_1MB   or mas6_3_isize=TLB_PgSize_256MB)   and mas6_3_sind='1')   
                       else '1';
-- T field from tlbilx/eratilx is  0=all, 1=pid, 2=resvd/GS, 3=address, 4-7=class
illeg_instr_d <= ( ex2_valid_q and mas6_isize_not_supp and (0 to 3 => (ex2_ttype_q(1) and ex2_hv_state)) )  
              or ( ex2_valid_q and mas6_isize_not_supp and (0 to 3 => (ex2_ttype_q(0) and Eq(ex2_t_q,"011") and 
                                                            (ex2_hv_state or (ex2_priv_state and not ex2_dgtmi_state)))) )  
              or ( ex2_valid_q and (0 to 3 => (ex2_ttype_q(3) and ex2_hv_state and ex2_rs_pgsize_not_supp)) )  
              or ( ex2_valid_q and (0 to 3 => (ex2_ttype_q(2) and ex2_hv_state and ex2_t_q(0) and mmucr1_q(pos_ictid) and mmucr1_q(pos_dctid))) )  
              or ( tlb_ctl_ex2_illeg_instr );
-- invalidate sequencer
--Inv_Sequencer: PROCESS (inv_seq_q, por_seq_q, an_ac_back_inv, an_ac_back_inv_target,
--                           ex6_valid_q, ex6_ttype_q)
Inv_Sequencer: PROCESS (inv_seq_q, inval_snoop_forme, xu_mm_lmq_stq_empty, iu_mm_lmq_empty, hold_ack_q, lsu_tokens_q, xu_mm_ccr2_notlb_q(0),
                           snoop_ack_q, ex6_valid_q, ex6_ttype_q(0 to 3), ex6_ind_q, ex6_isel_q, 
                           mmucsr0_tlb0fi, 
                           tlbwe_back_inv_q(thdid_width+1),  
                           an_ac_back_inv_q(6), an_ac_back_inv_addr_q(54 to 55), htw_lsu_req_valid, lsu_req_q,
                           power_managed_q(0), power_managed_q(2), power_managed_q(3))
BEGIN
inv_seq_idle <= '0';
inv_seq_snoop_inprogress <= '0';
inv_seq_local_inprogress <= '0';
inv_seq_local_barrier_set <= '0';
inv_seq_global_barrier_set <= '0';
inv_seq_local_barrier_done <= '0';
inv_seq_global_barrier_done <= '0';
inv_seq_snoop_done <= '0';
inv_seq_local_done <= '0';
inv_seq_tlbi_load <= '0';
inv_seq_tlbi_complete <= '0';
inv_seq_htw_load <= '0';
htw_lsu_req_taken_sig <= '0';
inv_seq_hold_req(0 to 3) <= (others => '0');
inv_seq_hold_done(0 to 3) <= (others => '0');
inv_seq_tlb_snoop_val <= '0';
inv_seq_ierat_snoop_val  <= '0';
inv_seq_derat_snoop_val  <= '0';
inv_seq_tlb0fi_inprogress <= '0';
inv_seq_tlb0fi_done <= '0';
inv_seq_tlbwe_snoop_done <= '0';
inv_seq_tlbwe_inprogress <= '0';
CASE inv_seq_q IS
        WHEN InvSeq_Idle =>

          inv_seq_idle <= '1';
          if inval_snoop_forme='1' then
                    inv_seq_snoop_inprogress <= '1';
                    inv_seq_hold_req(0 to 3) <= "1111"; 
                    inv_seq_d <=  InvSeq_Stg8;
          elsif htw_lsu_req_valid='1' then
                    inv_seq_d <=  InvSeq_Stg31;
          elsif ex6_valid_q/="0000" and (ex6_ttype_q(1)='1' or ex6_ttype_q(3)='1') then
                    inv_seq_local_inprogress <= '1';
                    inv_seq_global_barrier_set <= '1';
                    inv_seq_d <=  InvSeq_Stg1;
          elsif ex6_valid_q/="0000" and  (ex6_ttype_q(0)='1' or ex6_ttype_q(2)='1') then
                    inv_seq_hold_req(0 to 3) <= "1111"; 
                    inv_seq_local_inprogress <= '1';
                    inv_seq_local_barrier_set <= '1';
                    inv_seq_d <=  InvSeq_Stg2;
          elsif mmucsr0_tlb0fi='1' then
                    inv_seq_hold_req(0 to 3) <= "1111"; 
                    inv_seq_tlb0fi_inprogress <= '1';
                    inv_seq_d <=  InvSeq_Stg16; 
          elsif tlbwe_back_inv_q(thdid_width+1)='1' then
                    inv_seq_hold_req(0 to 3) <= "1111"; 
                    inv_seq_tlbwe_inprogress <= '1';
                    inv_seq_d <=  InvSeq_Stg24; 
          else
                    inv_seq_d <=  InvSeq_Idle;
          end if;  
        WHEN InvSeq_Stg1 =>
         inv_seq_local_inprogress <= '1';
         if lsu_tokens_q/="00" then  
            inv_seq_tlbi_load <= '1';
            inv_seq_local_done <= '1'; 
            inv_seq_d <=  InvSeq_Idle;
         else
           inv_seq_d <=  InvSeq_Stg1; 
         end if;
        WHEN InvSeq_Stg2 =>
          inv_seq_local_inprogress <= '1';
          if hold_ack_q="1111" then
              inv_seq_d <=  InvSeq_Stg3;
          elsif htw_lsu_req_valid='1' then
                    inv_seq_d <=  InvSeq_Stg23;
          else 
              inv_seq_d <=  InvSeq_Stg2;
          end if;

        WHEN InvSeq_Stg3 =>
          inv_seq_local_inprogress <= '1';
          if iu_mm_lmq_empty='1' and xu_mm_lmq_stq_empty='1' and xu_mm_ccr2_notlb_q(0)=MMU_Mode_Value and ex6_ttype_q(0)='1' then
            inv_seq_d <=  InvSeq_Stg4;  
          elsif iu_mm_lmq_empty='1' and xu_mm_lmq_stq_empty='1' then
            inv_seq_d <=  InvSeq_Stg6;  
          else 
            inv_seq_d <=  InvSeq_Stg3; 
          end if;

        WHEN InvSeq_Stg4 =>
          inv_seq_local_inprogress <= '1';
          inv_seq_tlb_snoop_val <= '1';
          inv_seq_d <=  InvSeq_Stg5; 

        WHEN InvSeq_Stg5 =>
          inv_seq_local_inprogress <= '1';
          if snoop_ack_q(2)='1' then
              inv_seq_d <=  InvSeq_Stg6;
          else 
              inv_seq_d <=  InvSeq_Stg5;
          end if;

        WHEN InvSeq_Stg6 =>
         inv_seq_local_inprogress <= '1';
         inv_seq_ierat_snoop_val      <= not(ex6_ind_q and Eq(ex6_isel_q,"011"));
         inv_seq_derat_snoop_val      <= not(ex6_ind_q and Eq(ex6_isel_q,"011"));
         inv_seq_d <=  InvSeq_Stg7;

        WHEN InvSeq_Stg7 =>
          inv_seq_local_inprogress <= '1';
         if (snoop_ack_q(0 to 1)="11" or (ex6_ind_q and Eq(ex6_isel_q,"011"))='1') then  
            inv_seq_local_done <= '1';
            inv_seq_local_barrier_done <= '1'; 
            inv_seq_hold_done(0 to 3) <= "1111";
            inv_seq_d <=  InvSeq_Idle;  
         else
           inv_seq_d <=  InvSeq_Stg7;
         end if;

        WHEN InvSeq_Stg8 =>
          inv_seq_snoop_inprogress <= '1';
          if (hold_ack_q="1111" or (power_managed_q(0)='1' and power_managed_q(2)='1')) then
              inv_seq_d <=  InvSeq_Stg9;
          elsif htw_lsu_req_valid='1' then
                    inv_seq_d <=  InvSeq_Stg28;
          else 
              inv_seq_d <=  InvSeq_Stg8;
          end if;

        WHEN InvSeq_Stg9 =>
          inv_seq_snoop_inprogress <= '1';
          inv_seq_d <=  InvSeq_Stg10;

        WHEN InvSeq_Stg10 =>
          inv_seq_snoop_inprogress <= '1';
          if (power_managed_q(0)='1' and power_managed_q(3)='1') then
            inv_seq_d <=  InvSeq_Stg14;  
          elsif ( (iu_mm_lmq_empty='1' or power_managed_q(0)='1') and   
                    (xu_mm_lmq_stq_empty='1' or (power_managed_q(0)='1' and power_managed_q(2)='1')) and  
                      xu_mm_ccr2_notlb_q(0)=MMU_Mode_Value ) then
            inv_seq_d <=  InvSeq_Stg11;  
          elsif ( (iu_mm_lmq_empty='1' or power_managed_q(0)='1') and   
                    (xu_mm_lmq_stq_empty='1' or (power_managed_q(0)='1' and power_managed_q(2)='1')) ) then  
            inv_seq_d <=  InvSeq_Stg13;  
          else 
            inv_seq_d <=  InvSeq_Stg10; 
          end if;

        WHEN InvSeq_Stg11 =>
          inv_seq_snoop_inprogress <= '1';
          inv_seq_tlb_snoop_val <= '1';
          inv_seq_d <=  InvSeq_Stg12; 

        WHEN InvSeq_Stg12 =>
          inv_seq_snoop_inprogress <= '1';
          if snoop_ack_q(2)='1' or (power_managed_q(0)='1' and power_managed_q(2)='1') then
              inv_seq_d <=  InvSeq_Stg13;
          else 
              inv_seq_d <=  InvSeq_Stg12;
          end if;

        WHEN InvSeq_Stg13 =>
         inv_seq_snoop_inprogress <= '1';
         inv_seq_ierat_snoop_val      <= not(an_ac_back_inv_q(6) and Eq(an_ac_back_inv_addr_q(54 to 55),"11"));  
         inv_seq_derat_snoop_val      <= not(an_ac_back_inv_q(6) and Eq(an_ac_back_inv_addr_q(54 to 55),"11"));
         inv_seq_d <=  InvSeq_Stg14;

        WHEN InvSeq_Stg14 =>
         inv_seq_snoop_inprogress <= '1';
         if (power_managed_q(0)='1' and power_managed_q(2)='1') then
            inv_seq_tlbi_complete <= '1'; 
            inv_seq_d <=  InvSeq_Stg15;  
         elsif lsu_tokens_q/="00"  and (snoop_ack_q(0 to 1)="11" or (an_ac_back_inv_q(6) and Eq(an_ac_back_inv_addr_q(54 to 55),"11"))='1') then
            inv_seq_tlbi_complete <= '1'; 
            inv_seq_d <=  InvSeq_Stg15;  
         else
           inv_seq_d <=  InvSeq_Stg14;
         end if;

        WHEN InvSeq_Stg15 =>
         if (lsu_req_q="0000" and lsu_tokens_q/="00") or (power_managed_q(0)='1' and power_managed_q(2)='1') then
           inv_seq_snoop_inprogress <= '0';
           inv_seq_snoop_done <= '1';
           inv_seq_hold_done(0 to 3) <= "1111";
           inv_seq_global_barrier_done <= '1';
           inv_seq_d <=  InvSeq_Idle;  
         else
           inv_seq_snoop_inprogress <= '1';
           inv_seq_d <=  InvSeq_Stg15;
         end if;


        WHEN InvSeq_Stg16 =>
          inv_seq_tlb0fi_inprogress <= '1';
          if hold_ack_q="1111" then
              inv_seq_d <=  InvSeq_Stg17;
          elsif htw_lsu_req_valid='1' then
                    inv_seq_d <=  InvSeq_Stg22;
          else 
              inv_seq_d <=  InvSeq_Stg16;
          end if;

        WHEN InvSeq_Stg17 =>
          inv_seq_tlb0fi_inprogress <= '1';
          if iu_mm_lmq_empty='1' and xu_mm_lmq_stq_empty='1' and xu_mm_ccr2_notlb_q(0)=MMU_Mode_Value then
            inv_seq_d <=  InvSeq_Stg18;  
          elsif iu_mm_lmq_empty='1' and xu_mm_lmq_stq_empty='1' then  
            inv_seq_d <=  InvSeq_Stg20;  
          else 
            inv_seq_d <=  InvSeq_Stg17; 
          end if;

        WHEN InvSeq_Stg18 =>
          inv_seq_tlb0fi_inprogress <= '1';
          inv_seq_tlb_snoop_val <= '1';
          inv_seq_d <=  InvSeq_Stg19; 

        WHEN InvSeq_Stg19 =>
          inv_seq_tlb0fi_inprogress <= '1';
          if snoop_ack_q(2)='1' then
              inv_seq_d <=  InvSeq_Stg20;
          else 
              inv_seq_d <=  InvSeq_Stg19;
          end if;

        WHEN InvSeq_Stg20 =>
         inv_seq_tlb0fi_inprogress <= '1';
         inv_seq_ierat_snoop_val   <= '1'; 
         inv_seq_derat_snoop_val   <= '1';
         inv_seq_d <=  InvSeq_Stg21;

        WHEN InvSeq_Stg21 =>
         if (snoop_ack_q(0 to 1)="11") then  
            inv_seq_tlb0fi_inprogress <= '0';
            inv_seq_tlb0fi_done <= '1';
            inv_seq_hold_done(0 to 3) <= "1111";
            inv_seq_d <=  InvSeq_Idle;  
         else
           inv_seq_tlb0fi_inprogress <= '1';
           inv_seq_d <=  InvSeq_Stg21;
         end if;
        WHEN InvSeq_Stg22 =>
          inv_seq_tlb0fi_inprogress <= '1';
         if lsu_tokens_q/="00" then  
            inv_seq_htw_load <= '1';
            htw_lsu_req_taken_sig <= '1'; 
            inv_seq_d <=  InvSeq_Stg16;  
         else
           inv_seq_d <=  InvSeq_Stg22; 
         end if;

        WHEN InvSeq_Stg23 =>
          inv_seq_local_inprogress <= '1';
         if lsu_tokens_q/="00" then  
            inv_seq_htw_load <= '1';
            htw_lsu_req_taken_sig <= '1'; 
            inv_seq_d <=  InvSeq_Stg2;  
         else
           inv_seq_d <=  InvSeq_Stg23; 
         end if;

        WHEN InvSeq_Stg24 =>
          inv_seq_tlbwe_inprogress <= '1';
          if hold_ack_q="1111" then
              inv_seq_d <=  InvSeq_Stg25;
          elsif htw_lsu_req_valid='1' then
                    inv_seq_d <=  InvSeq_Stg29;
          else 
              inv_seq_d <=  InvSeq_Stg24;
          end if;

        WHEN InvSeq_Stg25 =>
          inv_seq_tlbwe_inprogress <= '1';
          if iu_mm_lmq_empty='1' and xu_mm_lmq_stq_empty='1' then
            inv_seq_d <=  InvSeq_Stg26;  
          else 
            inv_seq_d <=  InvSeq_Stg25; 
          end if;

        WHEN InvSeq_Stg26 =>
         inv_seq_tlbwe_inprogress <= '1';
         inv_seq_ierat_snoop_val   <= '1'; 
         inv_seq_derat_snoop_val   <= '1';
         inv_seq_d <=  InvSeq_Stg27;

        WHEN InvSeq_Stg27 =>
         if (snoop_ack_q(0 to 1)="11") then  
            inv_seq_tlbwe_inprogress <= '0';
            inv_seq_tlbwe_snoop_done <= '1';
            inv_seq_hold_done(0 to 3) <= "1111";
            inv_seq_d <=  InvSeq_Idle;  
         else
           inv_seq_tlbwe_inprogress <= '1';
           inv_seq_d <=  InvSeq_Stg27;
         end if;
        WHEN InvSeq_Stg29 =>
          inv_seq_tlbwe_inprogress <= '1';
         if lsu_tokens_q/="00" then  
            inv_seq_htw_load <= '1';
            htw_lsu_req_taken_sig <= '1'; 
            inv_seq_d <=  InvSeq_Stg24;  
         else
           inv_seq_d <=  InvSeq_Stg29; 
         end if;

        WHEN InvSeq_Stg28 =>
          inv_seq_snoop_inprogress <= '1';
         if lsu_tokens_q/="00" then  
            inv_seq_htw_load <= '1';
            htw_lsu_req_taken_sig <= '1'; 
            inv_seq_d <=  InvSeq_Stg8;  
         else
           inv_seq_d <=  InvSeq_Stg28; 
         end if;
        WHEN InvSeq_Stg31 =>
         if lsu_tokens_q/="00" then  
            inv_seq_htw_load <= '1';
            htw_lsu_req_taken_sig <= '1'; 
            inv_seq_d <=  InvSeq_Idle;
         else
           inv_seq_d <=  InvSeq_Stg31; 
         end if;
        WHEN OTHERS =>
          inv_seq_d <=  InvSeq_Idle;  
    END CASE;
END PROCESS Inv_Sequencer;
hold_req_d    <= inv_seq_hold_req;
hold_done_d   <= inv_seq_hold_done;
inv_seq_inprogress_d(0) <= inv_seq_snoop_inprogress;
inv_seq_inprogress_d(1) <= inv_seq_snoop_inprogress;
inv_seq_inprogress_d(2) <= inv_seq_tlb0fi_inprogress;
inv_seq_inprogress_d(3) <= inv_seq_tlb0fi_inprogress;
inv_seq_inprogress_d(4) <= inv_seq_tlbwe_inprogress;
inv_seq_inprogress_d(5) <= inv_seq_tlbwe_inprogress;
inv_seq_snoop_inprogress_q(0)  <= inv_seq_inprogress_q(0);
inv_seq_snoop_inprogress_q(1)  <= inv_seq_inprogress_q(1);
inv_seq_tlb0fi_inprogress_q(0) <= inv_seq_inprogress_q(2);
inv_seq_tlb0fi_inprogress_q(1) <= inv_seq_inprogress_q(3);
inv_seq_tlbwe_inprogress_q(0)  <= inv_seq_inprogress_q(4);
inv_seq_tlbwe_inprogress_q(1)  <= inv_seq_inprogress_q(5);
hold_ack_d(0)   <= '0' when (inv_seq_snoop_done='1' or inv_seq_local_done='1' or inv_seq_tlb0fi_done='1' or inv_seq_tlbwe_snoop_done='1') 
               else xu_mm_hold_ack(0)   when hold_ack_q(0)='0'
               else hold_ack_q(0);
hold_ack_d(1)   <= '0' when (inv_seq_snoop_done='1' or inv_seq_local_done='1' or inv_seq_tlb0fi_done='1' or inv_seq_tlbwe_snoop_done='1') 
               else xu_mm_hold_ack(1)   when hold_ack_q(1)='0'
               else hold_ack_q(1);
hold_ack_d(2)   <= '0' when (inv_seq_snoop_done='1' or inv_seq_local_done='1' or inv_seq_tlb0fi_done='1' or inv_seq_tlbwe_snoop_done='1') 
               else xu_mm_hold_ack(2)   when hold_ack_q(2)='0'
               else hold_ack_q(2);
hold_ack_d(3)   <= '0' when (inv_seq_snoop_done='1' or inv_seq_local_done='1' or inv_seq_tlb0fi_done='1' or inv_seq_tlbwe_snoop_done='1') 
               else xu_mm_hold_ack(3)   when hold_ack_q(3)='0'
               else hold_ack_q(3);
mm_xu_hold_req          <= hold_req_q;
mm_xu_hold_done         <= hold_done_q;
mm_xu_ex3_flush_req     <= ex3_flush_req_q;
mm_iu_barrier_done      <= barrier_done_q;
mm_xu_illeg_instr       <= illeg_instr_q;
mm_xu_local_snoop_reject   <= local_reject_q;
mmq_inval_tlb0fi_done   <= inv_seq_tlb0fi_done;
inval_snoop_forme <= ( an_ac_back_inv_q(2) and an_ac_back_inv_q(3) and not(power_managed_q(0) and power_managed_q(1)) and Eq(xu_mm_ccr2_notlb_q(0),MMU_Mode_Value) and not mmucr1_q(pos_tlbi_rej) )
                  or ( an_ac_back_inv_q(2) and an_ac_back_inv_q(3) and not(power_managed_q(0) and power_managed_q(1)) and Eq(an_ac_back_inv_lpar_id_q,lpidr_q) );
inval_snoop_local_reject <= ( an_ac_back_inv_q(2) and an_ac_back_inv_q(3) and not(power_managed_q(0) and power_managed_q(1)) and an_ac_back_inv_q(7)
                                and not Eq(an_ac_back_inv_lpar_id_q,lpidr_q) and (Eq(xu_mm_ccr2_notlb_q(0),ERAT_Mode_Value) or mmucr1_q(pos_tlbi_rej)) );
local_reject_d <= (global_barrier_q and (0 to thdid_width-1 => inval_snoop_local_reject));
-- an_ac_back_inv_q: 0=valid b-1, 1=target b-1, 2=valid b, 3=target b, 4=L, 5=GS, 6=IND, 7=local, 8=reject
an_ac_back_inv_d(0) <= an_ac_back_inv;
an_ac_back_inv_d(1) <= an_ac_back_inv_target;
an_ac_back_inv_d(2) <= an_ac_back_inv_q(0) when inval_snoop_forme='0' 
                else '0' when inv_seq_snoop_done='1'
                else an_ac_back_inv_q(2);
an_ac_back_inv_d(3) <= an_ac_back_inv_q(1) when inval_snoop_forme='0'
                else '0' when inv_seq_snoop_done='1'
                else an_ac_back_inv_q(3);
an_ac_back_inv_d(4) <= an_ac_back_inv_lbit when inval_snoop_forme='0'
                    else an_ac_back_inv_q(4);
an_ac_back_inv_d(5) <= an_ac_back_inv_gs when inval_snoop_forme='0'
                    else an_ac_back_inv_q(5);
an_ac_back_inv_d(6) <= an_ac_back_inv_ind when inval_snoop_forme='0'
                    else an_ac_back_inv_q(6);
an_ac_back_inv_d(7) <= an_ac_back_inv_local when inval_snoop_forme='0'
                    else an_ac_back_inv_q(7);
-- bit 8 is reject back to L2 (b phase) mmu targetted, but lpar id doesn't match
an_ac_back_inv_d(8) <= ( an_ac_back_inv_q(2) and an_ac_back_inv_q(3) and not Eq(an_ac_back_inv_lpar_id_q,lpidr_q)
                                and (Eq(xu_mm_ccr2_notlb_q(0),ERAT_Mode_Value) or mmucr1_q(pos_tlbi_rej)) )
                      or ( an_ac_back_inv_q(2) and an_ac_back_inv_q(3) and power_managed_q(0) and power_managed_q(1) );
an_ac_back_inv_addr_d <= an_ac_back_inv_addr when inval_snoop_forme='0' 
                    else an_ac_back_inv_addr_q;
an_ac_back_inv_lpar_id_d <= an_ac_back_inv_lpar_id when inval_snoop_forme='0'
                    else an_ac_back_inv_lpar_id_q;
ac_an_back_inv_reject  <= an_ac_back_inv_q(8);
-- tlbwe back-invalidate to erats request from tlb_cmp
tlbwe_back_inv_d(0 to thdid_width-1) <= tlbwe_back_inv_thdid when tlbwe_back_inv_q(thdid_width)='0'  
                else (others => '0') when (tlbwe_back_inv_q(thdid_width)='1' and tlbwe_back_inv_q(thdid_width+1)='0' and tlb_tag5_write='0')
                else (others => '0') when inv_seq_tlbwe_snoop_done='1'
                else tlbwe_back_inv_q(0 to thdid_width-1);
tlbwe_back_inv_d(thdid_width) <= tlbwe_back_inv_valid when tlbwe_back_inv_q(thdid_width)='0'   
                else '0' when (tlbwe_back_inv_q(thdid_width)='1' and tlbwe_back_inv_q(thdid_width+1)='0' and tlb_tag5_write='0')
                else '0' when inv_seq_tlbwe_snoop_done='1'
                else tlbwe_back_inv_q(thdid_width);
tlbwe_back_inv_d(thdid_width+1) <= (tlbwe_back_inv_q(thdid_width) and tlb_tag5_write) when tlbwe_back_inv_q(thdid_width+1)='0' 
                else '0' when inv_seq_tlbwe_snoop_done='1'
                else tlbwe_back_inv_q(thdid_width+1);
tlbwe_back_inv_addr_d <= tlbwe_back_inv_addr when tlbwe_back_inv_q(thdid_width)='0'  
                else tlbwe_back_inv_addr_q;
tlbwe_back_inv_attr_d <= tlbwe_back_inv_attr when tlbwe_back_inv_q(thdid_width)='0'  
                else tlbwe_back_inv_attr_q;
tlbwe_back_inv_pending <= or_reduce(tlbwe_back_inv_q(thdid_width to thdid_width+1));
-----------------------------------------------------------------------
-- Load/Store unit request interface
-----------------------------------------------------------------------
htw_lsu_req_taken <= htw_lsu_req_taken_sig;
lsu_tokens_d <= "01" when (xu_mm_lsu_token='1' and lsu_tokens_q="00")
                 else "10" when (xu_mm_lsu_token='1' and lsu_tokens_q="01")
                 else "11" when (xu_mm_lsu_token='1' and lsu_tokens_q="10")
                 else "10" when (lsu_req_q/="0000" and lsu_tokens_q="11")
                 else "01" when (lsu_req_q/="0000" and lsu_tokens_q="10")
                 else "00" when (lsu_req_q/="0000" and lsu_tokens_q="01")
                 else lsu_tokens_q;
lsu_req_d <= "0000" when lsu_tokens_q="00"
            else "1000" when inv_seq_tlbi_complete='1'
            else htw_lsu_thdid when inv_seq_htw_load='1'
            else  ex6_valid_q when inv_seq_tlbi_load='1'
            else (others => '0');
lsu_ttype_d <= "01" when inv_seq_tlbi_complete='1'
             else htw_lsu_ttype when inv_seq_htw_load='1'
             else (others => '0');
lsu_wimge_d <= htw_lsu_wimge when inv_seq_htw_load='1'
             else (others => '0');
lsu_ubits_d <= htw_lsu_u when inv_seq_htw_load='1'
             else (others => '0');
--                                            A2 to L2 interface req_ra epn bits for tlbivax op
--  page size  mmucr1.tlbi_msb    27:30     31:33     34:35     36:39     40:43     44:47     48:51   TLB  w  value
--      4K           0         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(44:47) EA(48:51)     31
--     64K           0         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(44:47)  0b0011       31
--      1M           0         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(27:30)  0b0101       27
--     16M           0         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(23:26) EA(27:30)  0b0111       23
--    256M           0         EA(27:30) EA(31:33) EA(34:35) EA(19:22) EA(23:26) EA(27:30)  0b1001       19
--      1G           0         EA(27:30) EA(31:33) EA(17:18) EA(19:22) EA(23:26) EA(27:30)  0b1010       17
--      4K           1         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(44:47) EA(48:51)     27
--     64K           1         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(44:47)  0b0011       27
--      1M           1         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(23:26)  0b0101       23
--     16M           1         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(19:22) EA(23:26)  0b0111       19
--    256M           1         EA(27:30) EA(31:33) EA(34:35) EA(15:18) EA(19:22) EA(23:26)  0b1001       15
--      1G           1         EA(27:30) EA(31:33) EA(13:14) EA(15:18) EA(19:22) EA(23:26)  0b1010       13
--  A2 to L2 interface req_ra for tlbivax op:
--    22:26 TID(1:5)
--    27:51 EPN
--       52 TS
--       53 TID(0)
--    54:55 attributes
--    56:63 TID(6:13)
lsu_addr_d(64-real_addr_width to 64-real_addr_width+4) <= 
              htw_lsu_addr(64-real_addr_width to 64-real_addr_width+4) when inv_seq_htw_load='1' 
              else ex6_pid_q(pid_width-13 to pid_width-9) when inv_seq_tlbi_load='1'
              else lsu_addr_q(64-real_addr_width to 64-real_addr_width+4);
lsu_addr_d(64-real_addr_width+5 to 33) <= 
              htw_lsu_addr(64-real_addr_width+5 to 33) when inv_seq_htw_load='1' 
              else ex3_ea_q(64-real_addr_width+5 to 33) when inv_seq_tlbi_load='1'
              else lsu_addr_q(64-real_addr_width+5 to 33);
lsu_addr_d(34 to 35) <= 
              htw_lsu_addr(34 to 35) when inv_seq_htw_load='1' 
              else ex3_ea_q(13 to 14) when (inv_seq_tlbi_load='1' and mmucr1(pos_tlbi_msb)='1' and ex6_size_q=TLB_PgSize_1GB)
              else ex3_ea_q(17 to 18) when (inv_seq_tlbi_load='1' and mmucr1(pos_tlbi_msb)='0' and ex6_size_q=TLB_PgSize_1GB)
              else ex3_ea_q(34 to 35) when inv_seq_tlbi_load='1'
              else lsu_addr_q(34 to 35);
lsu_addr_d(36 to 39) <= 
              htw_lsu_addr(36 to 39) when inv_seq_htw_load='1' 
              else ex3_ea_q(15 to 18) when (inv_seq_tlbi_load='1' and mmucr1(pos_tlbi_msb)='1' and 
                                                 (ex6_size_q=TLB_PgSize_1GB or ex6_size_q=TLB_PgSize_256MB))
              else ex3_ea_q(19 to 22) when (inv_seq_tlbi_load='1' and mmucr1(pos_tlbi_msb)='0' and 
                                                 (ex6_size_q=TLB_PgSize_1GB or ex6_size_q=TLB_PgSize_256MB))
              else ex3_ea_q(36 to 39) when inv_seq_tlbi_load='1'
              else lsu_addr_q(36 to 39);
lsu_addr_d(40 to 41) <= 
              htw_lsu_addr(40 to 41) when inv_seq_htw_load='1' 
              else ex3_ea_q(19 to 20) when (inv_seq_tlbi_load='1' and mmucr1(pos_tlbi_msb)='1' and 
                                   (ex6_size_q=TLB_PgSize_1GB or ex6_size_q=TLB_PgSize_256MB or ex6_size_q=TLB_PgSize_16MB))
              else ex3_ea_q(23 to 24) when (inv_seq_tlbi_load='1' and mmucr1(pos_tlbi_msb)='0' and 
                                   (ex6_size_q=TLB_PgSize_1GB or ex6_size_q=TLB_PgSize_256MB or ex6_size_q=TLB_PgSize_16MB))
              else ex3_ea_q(40 to 41) when inv_seq_tlbi_load='1'
              else lsu_addr_q(40 to 41);
lsu_addr_d(42 to 43) <= 
              htw_lsu_addr(42 to 43) when inv_seq_htw_load='1' 
              else ex6_isel_q(1 to 2) when (ex6_isel_q(0)='1' and inv_seq_tlbi_load='1') 
              else ex3_ea_q(21 to 22) when (ex6_isel_q(0)='0' and inv_seq_tlbi_load='1' and mmucr1(pos_tlbi_msb)='1' and 
                                   (ex6_size_q=TLB_PgSize_1GB or ex6_size_q=TLB_PgSize_256MB or ex6_size_q=TLB_PgSize_16MB))
              else ex3_ea_q(25 to 26) when (ex6_isel_q(0)='0' and inv_seq_tlbi_load='1' and mmucr1(pos_tlbi_msb)='0' and 
                                   (ex6_size_q=TLB_PgSize_1GB or ex6_size_q=TLB_PgSize_256MB or ex6_size_q=TLB_PgSize_16MB))
              else ex3_ea_q(42 to 43) when (ex6_isel_q(0)='0' and inv_seq_tlbi_load='1')
              else lsu_addr_q(42 to 43);
lsu_addr_d(44 to 47) <= 
              htw_lsu_addr(44 to 47) when inv_seq_htw_load='1' 
              else ex3_ea_q(23 to 26) when (inv_seq_tlbi_load='1' and mmucr1(pos_tlbi_msb)='1' and 
                     (ex6_size_q=TLB_PgSize_1GB or ex6_size_q=TLB_PgSize_256MB or ex6_size_q=TLB_PgSize_16MB or ex6_size_q=TLB_PgSize_1MB))
              else ex3_ea_q(27 to 30) when (inv_seq_tlbi_load='1' and mmucr1(pos_tlbi_msb)='0' and 
                     (ex6_size_q=TLB_PgSize_1GB or ex6_size_q=TLB_PgSize_256MB or ex6_size_q=TLB_PgSize_16MB or ex6_size_q=TLB_PgSize_1MB))
              else ex3_ea_q(44 to 47) when inv_seq_tlbi_load='1'
              else lsu_addr_q(44 to 47);
lsu_addr_d(48 to 51) <= htw_lsu_addr(48 to 51) when inv_seq_htw_load='1' 
              else ex6_size_q(0 to 3) when inv_seq_tlbi_load='1' and ex6_size_large='1'
              else ex3_ea_q(48 to 51) when inv_seq_tlbi_load='1' and ex6_size_large='0'
              else lsu_addr_q(48 to 51);
lsu_addr_d(52) <= htw_lsu_addr(52) when inv_seq_htw_load='1' 
              else ex6_ts_q when inv_seq_tlbi_load='1'
              else lsu_addr_q(52);
lsu_addr_d(53) <= htw_lsu_addr(53) when inv_seq_htw_load='1' 
              else ex6_pid_q(0) when inv_seq_tlbi_load='1'
              else lsu_addr_q(53);
lsu_addr_d(54 to 55) <= htw_lsu_addr(54 to 55) when inv_seq_htw_load='1' 
              else ex6_isel_q(1 to 2) when (ex6_isel_q(0)='0' and inv_seq_tlbi_load='1')
              else "10" when (ex6_isel_q(0)='1' and inv_seq_tlbi_load='1')
              else lsu_addr_q(54 to 55);
lsu_addr_d(56 to 63) <= htw_lsu_addr(56 to 63) when inv_seq_htw_load='1' 
              else ex6_pid_q(pid_width-8 to pid_width-1) when inv_seq_tlbi_load='1'
              else lsu_addr_q(56 to 63);
lsu_lpid_d <= ex6_lpid_q when inv_seq_tlbi_load='1'
              else lsu_lpid_q;
lsu_ind_d <= ex6_ind_q when inv_seq_tlbi_load='1'
              else lsu_ind_q;
lsu_gs_d <= ex6_gs_q when inv_seq_tlbi_load='1'
              else lsu_gs_q;
lsu_lbit_d <= '1' when (inv_seq_tlbi_load='1' and ex6_size_large='1')
              else '0' when (inv_seq_tlbi_load='1' and ex6_size_large='0')
               else lsu_lbit_q;
mm_xu_lsu_req              <= lsu_req_q;
mm_xu_lsu_ttype            <= lsu_ttype_q;
mm_xu_lsu_wimge            <= lsu_wimge_q;
mm_xu_lsu_u                <= lsu_ubits_q;
mm_xu_lsu_addr             <= lsu_addr_q;
mm_xu_lsu_lpid             <= lsu_lpid_q;
mm_xu_lsu_ind              <= lsu_ind_q;
mm_xu_lsu_gs               <= lsu_gs_q;
mm_xu_lsu_lbit             <= lsu_lbit_q;
-----------------------------------------------------------------------
-- Snoop interfaces to erats and tlb
-----------------------------------------------------------------------
snoop_valid_d(0) <= inv_seq_ierat_snoop_val;
snoop_valid_d(1) <= inv_seq_derat_snoop_val;
snoop_valid_d(2) <= inv_seq_tlb_snoop_val;
snoop_coming_d(0) <=  
                         inv_seq_tlb0fi_inprogress or 
                         inv_seq_tlbwe_inprogress or
                         inv_seq_local_inprogress or inv_seq_snoop_inprogress;
snoop_coming_d(1) <= snoop_coming_d(0);
snoop_coming_d(2) <= snoop_coming_d(0);
snoop_coming_d(3) <= snoop_coming_d(0) or mmucr2_act_override;
snoop_coming_d(4) <= snoop_coming_d(0) or mmucr2_act_override;
gen64_snoop_attr: if real_addr_width > 32 generate
ex6_tid_nz <= or_reduce(ex6_pid_q(0 to pid_width-1));
back_inv_tid_nz <= or_reduce(an_ac_back_inv_addr_q(53) & an_ac_back_inv_addr_q(22 to 26) & an_ac_back_inv_addr_q(56 to 63));
tlbwe_back_inv_tid_nz <= or_reduce(tlbwe_back_inv_attr_q(20 to 25) & tlbwe_back_inv_attr_q(6 to 13));
snoop_attr_d(0)  <= not inv_seq_snoop_inprogress_q(0);
snoop_attr_d(1 to 3)     <= '1' & an_ac_back_inv_addr_q(42 to 43) 
                                        when inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_addr_q(54 to 55)="10"
                             else '0' & an_ac_back_inv_addr_q(54 to 55) 
                                        when inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_addr_q(54 to 55)/="10"
                             else "011" when inv_seq_tlbwe_inprogress_q(0)='1'
                             else (ex6_isel_q(0 to 2) and not(0 to 2 => inv_seq_tlb0fi_inprogress_q(0)));
snoop_attr_d(4 to 13)  <= an_ac_back_inv_q(5) & an_ac_back_inv_addr_q(52) & an_ac_back_inv_addr_q(56 to 63)
                                        when inv_seq_snoop_inprogress_q(0)='1'                            
                             else tlbwe_back_inv_attr_q(4 to 13) when inv_seq_tlbwe_inprogress_q(0)='1'
                             else ex6_gs_q & ex6_ts_q & ex6_pid_q(pid_width-8 to pid_width-1);
snoop_attr_d(14 to 17)  <= "0001" when inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='0'  
                             else an_ac_back_inv_addr_q(48 to 51) when inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='1'
                             else tlbwe_back_inv_attr_q(14 to 17) when inv_seq_tlbwe_inprogress_q(0)='1'
                             else ex6_size_q(0 to 3);
snoop_attr_d(18)  <= not inv_seq_tlbwe_inprogress_q(0) or not tlbwe_back_inv_attr_q(18);
snoop_attr_d(19)  <= back_inv_tid_nz when inv_seq_snoop_inprogress_q(0)='1'
                             else tlbwe_back_inv_tid_nz when inv_seq_tlbwe_inprogress_q(0)='1'
                             else ex6_tid_nz;
snoop_attr_tlb_spec_d(18)  <= '0';
snoop_attr_tlb_spec_d(19)  <= inv_seq_tlb0fi_inprogress_q(0);
snoop_attr_d(20 to 25)  <= an_ac_back_inv_addr_q(53) & an_ac_back_inv_addr_q(22 to 26) when inv_seq_snoop_inprogress_q(0)='1'
                                   else tlbwe_back_inv_attr_q(20 to 25) when inv_seq_tlbwe_inprogress_q(0)='1'
                                   else ex6_pid_q(pid_width-14 to pid_width-9);
snoop_attr_d(26 to 33)  <= an_ac_back_inv_lpar_id_q when inv_seq_snoop_inprogress_q(0)='1'
                                   else tlbwe_back_inv_attr_q(26 to 33) when inv_seq_tlbwe_inprogress_q(0)='1'
                                   else lpidr_q when inv_seq_tlb0fi_inprogress_q(0)='1'
                                   else ex6_lpid_q;
snoop_attr_d(34)        <= an_ac_back_inv_q(6) when inv_seq_snoop_inprogress_q(0)='1'
                                   else tlbwe_back_inv_attr_q(34) when inv_seq_tlbwe_inprogress_q(0)='1'
                                   else ex6_ind_q;
snoop_attr_clone_d(0)  <= not inv_seq_snoop_inprogress_q(1);
snoop_attr_clone_d(1 to 3)     <= '1' & an_ac_back_inv_addr_q(42 to 43) 
                                        when inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_addr_q(54 to 55)="10"
                             else '0' & an_ac_back_inv_addr_q(54 to 55) 
                                        when inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_addr_q(54 to 55)/="10"
                             else "011" when inv_seq_tlbwe_inprogress_q(1)='1'
                             else (ex6_isel_q(0 to 2) and not(0 to 2 => inv_seq_tlb0fi_inprogress_q(1)));
snoop_attr_clone_d(4 to 13)  <= an_ac_back_inv_q(5) & an_ac_back_inv_addr_q(52) & an_ac_back_inv_addr_q(56 to 63)
                                        when inv_seq_snoop_inprogress_q(1)='1'                            
                             else tlbwe_back_inv_attr_q(4 to 13) when inv_seq_tlbwe_inprogress_q(1)='1'
                             else ex6_gs_q & ex6_ts_q & ex6_pid_q(pid_width-8 to pid_width-1);
snoop_attr_clone_d(14 to 17)  <= "0001" when inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='0'  
                             else an_ac_back_inv_addr_q(48 to 51) when inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='1'
                             else tlbwe_back_inv_attr_q(14 to 17) when inv_seq_tlbwe_inprogress_q(1)='1'
                             else ex6_size_q(0 to 3);
snoop_attr_clone_d(18)  <= not inv_seq_tlbwe_inprogress_q(1) or not tlbwe_back_inv_attr_q(18);
snoop_attr_clone_d(19)  <= back_inv_tid_nz when inv_seq_snoop_inprogress_q(1)='1'
                             else tlbwe_back_inv_tid_nz when inv_seq_tlbwe_inprogress_q(1)='1'
                             else ex6_tid_nz;
snoop_attr_clone_d(20 to 25)  <= an_ac_back_inv_addr_q(53) & an_ac_back_inv_addr_q(22 to 26) when inv_seq_snoop_inprogress_q(1)='1'
                                   else tlbwe_back_inv_attr_q(20 to 25) when inv_seq_tlbwe_inprogress_q(1)='1'
                                   else ex6_pid_q(pid_width-14 to pid_width-9);
end generate gen64_snoop_attr;
gen32_snoop_attr: if real_addr_width < 33 generate
ex6_tid_nz <= or_reduce(ex6_pid_q(0 to pid_width-1));
back_inv_tid_nz <= or_reduce(an_ac_back_inv_addr_q(56 to 63));
tlbwe_back_inv_tid_nz <= or_reduce(tlbwe_back_inv_attr_q(20 to 25) & tlbwe_back_inv_attr_q(6 to 13));
snoop_attr_d(0)  <= not inv_seq_snoop_inprogress_q(0);
snoop_attr_d(1 to 3)     <= '1' & an_ac_back_inv_addr_q(42 to 43) 
                                        when inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_addr_q(54 to 55)="10"
                             else '0' & an_ac_back_inv_addr_q(54 to 55) 
                                        when inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_addr_q(54 to 55)/="10"
                             else "011" when inv_seq_tlbwe_inprogress_q(0)='1'
                             else ex6_isel_q(0 to 2);
snoop_attr_d(4 to 13)  <= an_ac_back_inv_q(5) & an_ac_back_inv_addr_q(52) & an_ac_back_inv_addr_q(56 to 63)
                                        when inv_seq_snoop_inprogress_q(0)='1'                             
                             else tlbwe_back_inv_attr_q(4 to 13) when inv_seq_tlbwe_inprogress_q(0)='1'
                             else ex6_gs_q & ex6_ts_q & ex6_pid_q(pid_width-8 to pid_width-1);
snoop_attr_d(14 to 17)  <= "0001" when inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='0'  
                             else an_ac_back_inv_addr_q(48 to 51) when inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='1'
                             else tlbwe_back_inv_attr_q(14 to 17) when inv_seq_tlbwe_inprogress_q(0)='1'
                             else ex6_size_q(0 to 3);
snoop_attr_d(18)  <= not inv_seq_tlbwe_inprogress_q(0) or not tlbwe_back_inv_attr_q(18);
snoop_attr_d(19)  <= back_inv_tid_nz when inv_seq_snoop_inprogress_q(0)='1'
                             else tlbwe_back_inv_tid_nz when inv_seq_tlbwe_inprogress_q(0)='1'
                             else ex6_tid_nz;
snoop_attr_tlb_spec_d(18)  <= '0';
snoop_attr_tlb_spec_d(19)  <= inv_seq_tlb0fi_inprogress_q(0);
snoop_attr_d(20 to 25)  <= (others => '0') when inv_seq_snoop_inprogress_q(0)='1'
                             else tlbwe_back_inv_attr_q(20 to 25) when inv_seq_tlbwe_inprogress_q(0)='1'
                             else ex6_pid_q(pid_width-14 to pid_width-9);
snoop_attr_d(26 to 33)  <= an_ac_back_inv_lpar_id_q when inv_seq_snoop_inprogress_q(0)='1'
                                  else tlbwe_back_inv_attr_q(26 to 33) when inv_seq_tlbwe_inprogress_q(0)='1'
                                  else lpidr_q when inv_seq_tlb0fi_inprogress_q(0)='1'
                                  else ex6_lpid_q;
snoop_attr_d(34)        <= an_ac_back_inv_q(6) when inv_seq_snoop_inprogress_q(0)='1'
                             else tlbwe_back_inv_attr_q(34) when inv_seq_tlbwe_inprogress_q(0)='1'
                             else ex6_ind_q;
snoop_attr_clone_d(0)  <= not inv_seq_snoop_inprogress_q(1);
snoop_attr_clone_d(1 to 3)     <= '1' & an_ac_back_inv_addr_q(42 to 43) 
                                        when inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_addr_q(54 to 55)="10"
                             else '0' & an_ac_back_inv_addr_q(54 to 55) 
                                        when inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_addr_q(54 to 55)/="10"
                             else "011" when inv_seq_tlbwe_inprogress_q(1)='1'
                             else ex6_isel_q(0 to 2);
snoop_attr_clone_d(4 to 13)  <= an_ac_back_inv_q(5) & an_ac_back_inv_addr_q(52) & an_ac_back_inv_addr_q(56 to 63)
                                        when inv_seq_snoop_inprogress_q(1)='1'                             
                             else tlbwe_back_inv_attr_q(4 to 13) when inv_seq_tlbwe_inprogress_q(1)='1'
                             else ex6_gs_q & ex6_ts_q & ex6_pid_q(pid_width-8 to pid_width-1);
snoop_attr_clone_d(14 to 17)  <= "0001" when inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='0'  
                             else an_ac_back_inv_addr_q(48 to 51) when inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='1'
                             else tlbwe_back_inv_attr_q(14 to 17) when inv_seq_tlbwe_inprogress_q(1)='1'
                             else ex6_size_q(0 to 3);
snoop_attr_clone_d(18)  <= not inv_seq_tlbwe_inprogress_q(1) or not tlbwe_back_inv_attr_q(18);
snoop_attr_clone_d(19)  <= back_inv_tid_nz when inv_seq_snoop_inprogress_q(1)='1'
                             else tlbwe_back_inv_tid_nz when inv_seq_tlbwe_inprogress_q(1)='1'
                             else ex6_tid_nz;
snoop_attr_clone_d(20 to 25)  <= (others => '0') when inv_seq_snoop_inprogress_q(1)='1'
                             else tlbwe_back_inv_attr_q(20 to 25) when inv_seq_tlbwe_inprogress_q(1)='1'
                             else ex6_pid_q(pid_width-14 to pid_width-9);
end generate gen32_snoop_attr;
--                                            A2 to L2 interface req_ra epn bits for tlbivax op
--  page size  mmucr1.tlbi_msb    27:30     31:33     34:35     36:39     40:43     44:47     48:51   TLB  w  value
--      4K           0         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(44:47) EA(48:51)     31
--     64K           0         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(44:47)  0b0011       31
--      1M           0         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(27:30)  0b0101       27
--     16M           0         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(23:26) EA(27:30)  0b0111       23
--    256M           0         EA(27:30) EA(31:33) EA(34:35) EA(19:22) EA(23:26) EA(27:30)  0b1001       19
--      1G           0         EA(27:30) EA(31:33) EA(17:18) EA(19:22) EA(23:26) EA(27:30)  0b1010       17
--      4K           1         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(44:47) EA(48:51)     27
--     64K           1         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(44:47)  0b0011       27
--      1M           1         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(40:43) EA(23:26)  0b0101       23
--     16M           1         EA(27:30) EA(31:33) EA(34:35) EA(36:39) EA(19:22) EA(23:26)  0b0111       19
--    256M           1         EA(27:30) EA(31:33) EA(34:35) EA(15:18) EA(19:22) EA(23:26)  0b1001       15
--      1G           1         EA(27:30) EA(31:33) EA(13:14) EA(15:18) EA(19:22) EA(23:26)  0b1010       13
--  A2 to L2 interface req_ra for tlbivax op:
--    22:26 TID(1:5)
--    27:51 EPN
--       52 TS
--       53 TID(0)
--    54:55 attributes
--    56:63 TID(6:13)
gen_rs_gte_epn_snoop_vpn: if  (rs_data_width > epn_width-1) and (epn_width > real_addr_width) generate
snoop_vpn_d(52-epn_width to 12)   <= (others => '0') when inv_seq_snoop_inprogress_q(0)='1'
                                           else tlbwe_back_inv_addr_q(0 to 12) when inv_seq_tlbwe_inprogress_q(0)='1'
                                           else ex3_ea_q(52-epn_width to 12);
snoop_vpn_d(13 to 14)   <= an_ac_back_inv_addr_q(34 to 35) when (inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='1'  and an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB)  
                                  else (others => '0') when inv_seq_snoop_inprogress_q(0)='1'
                                  else tlbwe_back_inv_addr_q(13 to 14) when inv_seq_tlbwe_inprogress_q(0)='1'
                                  else ex3_ea_q(13 to 14);
snoop_vpn_d(15 to 16)   <= an_ac_back_inv_addr_q(36 to 37) when (inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='1'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                             an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB))  
                                  else (others => '0') when inv_seq_snoop_inprogress_q(0)='1'
                                  else tlbwe_back_inv_addr_q(15 to 16) when inv_seq_tlbwe_inprogress_q(0)='1'
                                  else ex3_ea_q(15 to 16);
snoop_vpn_d(17 to 18)   <= an_ac_back_inv_addr_q(38 to 39) when (inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='1'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                             an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB))  
                                  else an_ac_back_inv_addr_q(34 to 35) when (inv_seq_snoop_inprogress_q(0)='1'and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='0'  and an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB )  
                                  else (others => '0') when inv_seq_snoop_inprogress_q(0)='1'
                                  else tlbwe_back_inv_addr_q(17 to 18) when inv_seq_tlbwe_inprogress_q(0)='1'
                                  else ex3_ea_q(17 to 18);
snoop_vpn_d(19 to 22)   <= an_ac_back_inv_addr_q(40 to 43) when (inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='1'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB or an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_16MB))  
                                  else an_ac_back_inv_addr_q(36 to 39) when (inv_seq_snoop_inprogress_q(0)='1'and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='0'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB))  
                                  else (others => '0') when inv_seq_snoop_inprogress_q(0)='1'
                                  else tlbwe_back_inv_addr_q(19 to 22) when inv_seq_tlbwe_inprogress_q(0)='1'
                                  else ex3_ea_q(19 to 22);
snoop_vpn_d(23 to 26)   <= an_ac_back_inv_addr_q(44 to 47) when (inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='1'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB or an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_16MB or
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1MB))  
                                  else an_ac_back_inv_addr_q(40 to 43) when (inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='0'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB or an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_16MB))  
                                  else (others => '0') when inv_seq_snoop_inprogress_q(0)='1'
                                  else tlbwe_back_inv_addr_q(23 to 26) when inv_seq_tlbwe_inprogress_q(0)='1'
                                  else ex3_ea_q(23 to 26);
snoop_vpn_d(27 to 30)   <= an_ac_back_inv_addr_q(44 to 47) when (inv_seq_snoop_inprogress_q(0)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='0'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB or an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_16MB or
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1MB))  
                                  else an_ac_back_inv_addr_q(27 to 30) when inv_seq_snoop_inprogress_q(0)='1'
                                  else tlbwe_back_inv_addr_q(27 to 30) when inv_seq_tlbwe_inprogress_q(0)='1'
                                  else ex3_ea_q(27 to 30);
snoop_vpn_d(31)  <= an_ac_back_inv_addr_q(31) when inv_seq_snoop_inprogress_q(0)='1'
                                 else tlbwe_back_inv_addr_q(31) when inv_seq_tlbwe_inprogress_q(0)='1'
                                 else ex3_ea_q(31);
snoop_vpn_clone_d(52-epn_width to 12)   <= (others => '0') when inv_seq_snoop_inprogress_q(1)='1'
                                           else tlbwe_back_inv_addr_q(0 to 12) when inv_seq_tlbwe_inprogress_q(1)='1'
                                           else ex3_ea_q(52-epn_width to 12);
snoop_vpn_clone_d(13 to 14)   <= an_ac_back_inv_addr_q(34 to 35) when (inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='1'  and an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB)  
                                  else (others => '0') when inv_seq_snoop_inprogress_q(1)='1'
                                  else tlbwe_back_inv_addr_q(13 to 14) when inv_seq_tlbwe_inprogress_q(1)='1'
                                  else ex3_ea_q(13 to 14);
snoop_vpn_clone_d(15 to 16)   <= an_ac_back_inv_addr_q(36 to 37) when (inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='1'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                             an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB))  
                                  else (others => '0') when inv_seq_snoop_inprogress_q(1)='1'
                                  else tlbwe_back_inv_addr_q(15 to 16) when inv_seq_tlbwe_inprogress_q(1)='1'
                                  else ex3_ea_q(15 to 16);
snoop_vpn_clone_d(17 to 18)   <= an_ac_back_inv_addr_q(38 to 39) when (inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='1'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                             an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB))  
                                  else an_ac_back_inv_addr_q(34 to 35) when (inv_seq_snoop_inprogress_q(1)='1'and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='0'  and an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB )  
                                  else (others => '0') when inv_seq_snoop_inprogress_q(1)='1'
                                  else tlbwe_back_inv_addr_q(17 to 18) when inv_seq_tlbwe_inprogress_q(1)='1'
                                  else ex3_ea_q(17 to 18);
snoop_vpn_clone_d(19 to 22)   <= an_ac_back_inv_addr_q(40 to 43) when (inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='1'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB or an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_16MB))  
                                  else an_ac_back_inv_addr_q(36 to 39) when (inv_seq_snoop_inprogress_q(1)='1'and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='0'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB))  
                                  else (others => '0') when inv_seq_snoop_inprogress_q(1)='1'
                                  else tlbwe_back_inv_addr_q(19 to 22) when inv_seq_tlbwe_inprogress_q(1)='1'
                                  else ex3_ea_q(19 to 22);
snoop_vpn_clone_d(23 to 26)   <= an_ac_back_inv_addr_q(44 to 47) when (inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='1'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB or an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_16MB or
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1MB))  
                                  else an_ac_back_inv_addr_q(40 to 43) when (inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='0'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB or an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_16MB))  
                                  else (others => '0') when inv_seq_snoop_inprogress_q(1)='1'
                                  else tlbwe_back_inv_addr_q(23 to 26) when inv_seq_tlbwe_inprogress_q(1)='1'
                                  else ex3_ea_q(23 to 26);
snoop_vpn_clone_d(27 to 30)   <= an_ac_back_inv_addr_q(44 to 47) when (inv_seq_snoop_inprogress_q(1)='1' and an_ac_back_inv_q(4)='1' and 
                                        mmucr1_q(pos_tlbi_msb)='0'  and (an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1GB or 
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_256MB or an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_16MB or
                                          an_ac_back_inv_addr_q(48 to 51)=TLB_PgSize_1MB))  
                                  else an_ac_back_inv_addr_q(27 to 30) when inv_seq_snoop_inprogress_q(1)='1'
                                  else tlbwe_back_inv_addr_q(27 to 30) when inv_seq_tlbwe_inprogress_q(1)='1'
                                  else ex3_ea_q(27 to 30);
snoop_vpn_clone_d(31)  <= an_ac_back_inv_addr_q(31) when inv_seq_snoop_inprogress_q(1)='1'
                                 else tlbwe_back_inv_addr_q(31) when inv_seq_tlbwe_inprogress_q(1)='1'
                                 else ex3_ea_q(31);
end generate gen_rs_gte_epn_snoop_vpn;
gen_rs_gte_ra_snoop_vpn: if (rs_data_width > real_addr_width-1) generate
snoop_vpn_d(32 to 51)  <= an_ac_back_inv_addr_q(32 to 51) when inv_seq_snoop_inprogress_q(0)='1'
                                  else tlbwe_back_inv_addr_q(32 to 51) when inv_seq_tlbwe_inprogress_q(0)='1'
                                  else ex3_ea_q(32 to 51);
snoop_vpn_clone_d(32 to 51)  <= an_ac_back_inv_addr_q(32 to 51) when inv_seq_snoop_inprogress_q(1)='1'
                                  else tlbwe_back_inv_addr_q(32 to 51) when inv_seq_tlbwe_inprogress_q(1)='1'
                                  else ex3_ea_q(32 to 51);
end generate gen_rs_gte_ra_snoop_vpn;
gen_ra_gt_rs_snoop_vpn: if rs_data_width < real_addr_width generate
snoop_vpn_d(64-real_addr_width to 51)  <= an_ac_back_inv_addr_q(64-real_addr_width to 51) when inv_seq_snoop_inprogress_q(0)='1'
                                           else tlbwe_back_inv_addr_q(64-real_addr_width to 51) when inv_seq_tlbwe_inprogress_q(0)='1'
                                           else (64-real_addr_width to 63-rs_data_width => '0') & ex3_ea_q(64-rs_data_width to 51);
snoop_vpn_clone_d(64-real_addr_width to 51)  <= an_ac_back_inv_addr_q(64-real_addr_width to 51) when inv_seq_snoop_inprogress_q(1)='1'
                                           else tlbwe_back_inv_addr_q(64-real_addr_width to 51) when inv_seq_tlbwe_inprogress_q(1)='1'
                                           else (64-real_addr_width to 63-rs_data_width => '0') & ex3_ea_q(64-rs_data_width to 51);
end generate gen_ra_gt_rs_snoop_vpn;
gen_epn_gt_rs_snoop_vpn: if (epn_width > real_addr_width) and (rs_data_width < epn_width) generate
snoop_vpn_d(52-epn_width to 63-real_addr_width)   <= (others => '0');
snoop_vpn_clone_d(52-epn_width to 63-real_addr_width)   <= (others => '0');
end generate gen_epn_gt_rs_snoop_vpn;
snoop_ack_d(0) <= iu_mm_ierat_snoop_ack when snoop_ack_q(0)='0'
            else '0' when (inv_seq_snoop_done='1' or inv_seq_local_done='1' or inv_seq_tlb0fi_done='1' or inv_seq_tlbwe_snoop_done='1')
            else snoop_ack_q(0);
snoop_ack_d(1) <= xu_mm_derat_snoop_ack when snoop_ack_q(1)='0'
            else '0' when (inv_seq_snoop_done='1' or inv_seq_local_done='1' or inv_seq_tlb0fi_done='1' or inv_seq_tlbwe_snoop_done='1')
            else snoop_ack_q(1);
snoop_ack_d(2) <= tlb_snoop_ack when snoop_ack_q(2)='0'
            else '0' when (inv_seq_snoop_done='1' or inv_seq_local_done='1' or inv_seq_tlb0fi_done='1' or inv_seq_tlbwe_snoop_done='1')
            else snoop_ack_q(2);
mm_iu_ierat_snoop_coming  <= snoop_coming_q(0);
mm_iu_ierat_snoop_val  <= snoop_valid_q(0);
mm_iu_ierat_snoop_attr <= snoop_attr_q(0 to 25);
mm_iu_ierat_snoop_vpn  <= snoop_vpn_q;
mm_xu_derat_snoop_coming  <= snoop_coming_q(1);
mm_xu_derat_snoop_val  <= snoop_valid_q(1);
mm_xu_derat_snoop_attr <= snoop_attr_clone_q(0 to 25);
mm_xu_derat_snoop_vpn  <= snoop_vpn_clone_q;
tlb_snoop_coming  <= snoop_coming_q(2);
tlb_snoop_val  <= snoop_valid_q(2);
tlb_snoop_attr(0 to 17) <= snoop_attr_q(0 to 17);
tlb_snoop_attr(18 to 19) <= snoop_attr_tlb_spec_q(18 to 19);
tlb_snoop_attr(20 to 34) <= snoop_attr_q(20 to 34);
tlb_snoop_vpn  <= snoop_vpn_q;
xu_mm_ccr2_notlb_b <= not xu_mm_ccr2_notlb_q(1 to 12);
xu_mm_epcr_dgtmi   <= xu_mm_epcr_dgtmi_q;
inval_perf_tlbilx             <= inv_seq_local_done and not inv_seq_tlbi_load;
inval_perf_tlbivax            <= inv_seq_local_done and      inv_seq_tlbi_load;
inval_perf_tlbivax_snoop      <= inv_seq_snoop_done;
inval_perf_tlb_flush          <= or_reduce(ex3_flush_req_q);
inval_dbg_seq_q                  <= inv_seq_q(1 to 5);
inval_dbg_seq_idle               <= inv_seq_idle;
inval_dbg_seq_snoop_inprogress   <= inv_seq_snoop_inprogress;
inval_dbg_seq_snoop_done         <= inv_seq_snoop_done;
inval_dbg_seq_local_done         <= inv_seq_local_done;
inval_dbg_seq_tlb0fi_done        <= inv_seq_tlb0fi_done;
inval_dbg_seq_tlbwe_snoop_done   <= inv_seq_tlbwe_snoop_done;
inval_dbg_ex6_valid              <= or_reduce(ex6_valid_q);
inval_dbg_ex6_thdid(0)           <= (ex6_valid_q(2) or ex6_valid_q(3));
inval_dbg_ex6_thdid(1)           <= (ex6_valid_q(1) or ex6_valid_q(3));
inval_dbg_ex6_ttype(0)          <= ex6_ttype_q(4) or ex6_ttype_q(5);
inval_dbg_ex6_ttype(1)          <= ex6_ttype_q(2) or ex6_ttype_q(3);
inval_dbg_ex6_ttype(2)          <= ex6_ttype_q(1) or ex6_ttype_q(3) or ex6_ttype_q(5);
inval_dbg_snoop_forme            <= inval_snoop_forme;
inval_dbg_snoop_local_reject     <= inval_snoop_local_reject;
inval_dbg_an_ac_back_inv_q       <= an_ac_back_inv_q(2 to 8);
inval_dbg_an_ac_back_inv_lpar_id_q   <= an_ac_back_inv_lpar_id_q;
inval_dbg_an_ac_back_inv_addr_q      <= an_ac_back_inv_addr_q;
inval_dbg_snoop_valid_q          <= snoop_valid_q;
inval_dbg_snoop_ack_q            <= snoop_ack_q;
inval_dbg_snoop_attr_q           <= snoop_attr_q;
inval_dbg_snoop_attr_tlb_spec_q  <= snoop_attr_tlb_spec_q;
inval_dbg_snoop_vpn_q            <= snoop_vpn_q(17 to 51);
inval_dbg_lsu_tokens_q           <= lsu_tokens_q;
-- unused spare signal assignments
unused_dc(0) <= or_reduce(LCB_DELAY_LCLKR_DC(1 TO 4));
unused_dc(1) <= or_reduce(LCB_MPW1_DC_B(1 TO 4));
unused_dc(2) <= PC_FUNC_SL_FORCE;
unused_dc(3) <= PC_FUNC_SL_THOLD_0_B;
unused_dc(4) <= TC_SCAN_DIS_DC_B;
unused_dc(5) <= TC_SCAN_DIAG_DC;
unused_dc(6) <= TC_LBIST_EN_DC;
unused_dc(7) <= or_reduce(MMUCR0_0(4 TO 5));
unused_dc(8) <= or_reduce(MMUCR0_1(4 TO 5));
unused_dc(9) <= or_reduce(MMUCR0_2(4 TO 5));
unused_dc(10) <= or_reduce(MMUCR0_3(4 TO 5));
unused_dc(11) <= mmucr1_q(13) and or_reduce(mmucr1_q(15 to 17));
unused_dc(12) <= EX5_RS_IS_Q(0);
--------------------------------------------------
-- latches
--------------------------------------------------
ex1_valid_latch: tri_rlmreg_p
  generic map (width => ex1_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex1_valid_offset to ex1_valid_offset+ex1_valid_q'length-1),
            scout   => sov(ex1_valid_offset to ex1_valid_offset+ex1_valid_q'length-1),
            din     => ex1_valid_d(0 to thdid_width-1),
            dout    => ex1_valid_q(0 to thdid_width-1)  );
ex1_ttype_latch: tri_rlmreg_p
  generic map (width => ex1_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex1_ttype_offset to ex1_ttype_offset+ex1_ttype_q'length-1),
            scout   => sov(ex1_ttype_offset to ex1_ttype_offset+ex1_ttype_q'length-1),
            din     => ex1_ttype_d,
            dout    => ex1_ttype_q  );
ex1_state_latch: tri_rlmreg_p
  generic map (width => ex1_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex1_state_offset to ex1_state_offset+ex1_state_q'length-1),
            scout   => sov(ex1_state_offset to ex1_state_offset+ex1_state_q'length-1),
            din     => ex1_state_d(0 to state_width-1),
            dout    => ex1_state_q(0 to state_width-1)  );
ex1_t_latch: tri_rlmreg_p
  generic map (width => ex1_t_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex1_t_offset to ex1_t_offset+ex1_t_q'length-1),
            scout   => sov(ex1_t_offset to ex1_t_offset+ex1_t_q'length-1),
            din     => ex1_t_d(0 to t_width-1),
            dout    => ex1_t_q(0 to t_width-1)  );
-------------------------------------------------------------------------------
ex2_valid_latch: tri_rlmreg_p
  generic map (width => ex2_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_valid_offset to ex2_valid_offset+ex2_valid_q'length-1),
            scout   => sov(ex2_valid_offset to ex2_valid_offset+ex2_valid_q'length-1),
            din     => ex2_valid_d(0 to thdid_width-1),
            dout    => ex2_valid_q(0 to thdid_width-1)  );
ex2_ttype_latch: tri_rlmreg_p
  generic map (width => ex2_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_ttype_offset to ex2_ttype_offset+ex2_ttype_q'length-1),
            scout   => sov(ex2_ttype_offset to ex2_ttype_offset+ex2_ttype_q'length-1),
            din     => ex2_ttype_d(0 to ttype_width-1),
            dout    => ex2_ttype_q(0 to ttype_width-1)  );
ex2_rs_is_latch: tri_rlmreg_p
  generic map (width => ex2_rs_is_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_rs_is_offset to ex2_rs_is_offset+ex2_rs_is_q'length-1),
            scout   => sov(ex2_rs_is_offset to ex2_rs_is_offset+ex2_rs_is_q'length-1),
            din     => ex2_rs_is_d(0 to rs_is_width-1),
            dout    => ex2_rs_is_q(0 to rs_is_width-1)  );
ex2_state_latch: tri_rlmreg_p
  generic map (width => ex2_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_state_offset to ex2_state_offset+ex2_state_q'length-1),
            scout   => sov(ex2_state_offset to ex2_state_offset+ex2_state_q'length-1),
            din     => ex2_state_d(0 to state_width-1),
            dout    => ex2_state_q(0 to state_width-1)  );
ex2_t_latch: tri_rlmreg_p
  generic map (width => ex2_t_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex2_t_offset to ex2_t_offset+ex2_t_q'length-1),
            scout   => sov(ex2_t_offset to ex2_t_offset+ex2_t_q'length-1),
            din     => ex2_t_d(0 to t_width-1),
            dout    => ex2_t_q(0 to t_width-1)  );
-------------------------------------------------------------------------------
ex3_valid_latch: tri_rlmreg_p
  generic map (width => ex3_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_valid_offset to ex3_valid_offset+ex3_valid_q'length-1),
            scout   => sov(ex3_valid_offset to ex3_valid_offset+ex3_valid_q'length-1),
            din     => ex3_valid_d(0 to thdid_width-1),
            dout    => ex3_valid_q(0 to thdid_width-1)  );
ex3_ttype_latch: tri_rlmreg_p
  generic map (width => ex3_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_ttype_offset to ex3_ttype_offset+ex3_ttype_q'length-1),
            scout   => sov(ex3_ttype_offset to ex3_ttype_offset+ex3_ttype_q'length-1),
            din     => ex3_ttype_d(0 to ttype_width-1),
            dout    => ex3_ttype_q(0 to ttype_width-1)  );
ex3_rs_is_latch: tri_rlmreg_p
  generic map (width => ex3_rs_is_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_rs_is_offset to ex3_rs_is_offset+ex3_rs_is_q'length-1),
            scout   => sov(ex3_rs_is_offset to ex3_rs_is_offset+ex3_rs_is_q'length-1),
            din     => ex3_rs_is_d(0 to rs_is_width-1),
            dout    => ex3_rs_is_q(0 to rs_is_width-1)  );
ex3_state_latch: tri_rlmreg_p
  generic map (width => ex3_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_state_offset to ex3_state_offset+ex3_state_q'length-1),
            scout   => sov(ex3_state_offset to ex3_state_offset+ex3_state_q'length-1),
            din     => ex3_state_d(0 to state_width-1),
            dout    => ex3_state_q(0 to state_width-1)  );
ex3_t_latch: tri_rlmreg_p
  generic map (width => ex3_t_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_t_offset to ex3_t_offset+ex3_t_q'length-1),
            scout   => sov(ex3_t_offset to ex3_t_offset+ex3_t_q'length-1),
            din     => ex3_t_d(0 to t_width-1),
            dout    => ex3_t_q(0 to t_width-1)  );
ex3_flush_req_latch: tri_rlmreg_p
  generic map (width => ex3_flush_req_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_flush_req_offset to ex3_flush_req_offset+ex3_flush_req_q'length-1),
            scout   => sov(ex3_flush_req_offset to ex3_flush_req_offset+ex3_flush_req_q'length-1),
            din     => ex3_flush_req_d(0 to thdid_width-1),
            dout    => ex3_flush_req_q(0 to thdid_width-1)  );
ex3_ea_latch: tri_rlmreg_p
  generic map (width => ex3_ea_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex3_ea_offset to ex3_ea_offset+ex3_ea_q'length-1),
            scout   => sov(ex3_ea_offset to ex3_ea_offset+ex3_ea_q'length-1),
            din     => ex3_ea_d(64-rs_data_width to 63),
            dout    => ex3_ea_q(64-rs_data_width to 63)  );
-------------------------------------------------------------------------------
ex4_valid_latch: tri_rlmreg_p
  generic map (width => ex4_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_valid_offset to ex4_valid_offset+ex4_valid_q'length-1),
            scout   => sov(ex4_valid_offset to ex4_valid_offset+ex4_valid_q'length-1),
            din     => ex4_valid_d(0 to thdid_width-1),
            dout    => ex4_valid_q(0 to thdid_width-1)  );
ex4_ttype_latch: tri_rlmreg_p
  generic map (width => ex4_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_ttype_offset to ex4_ttype_offset+ex4_ttype_q'length-1),
            scout   => sov(ex4_ttype_offset to ex4_ttype_offset+ex4_ttype_q'length-1),
            din     => ex4_ttype_d(0 to ttype_width-1),
            dout    => ex4_ttype_q(0 to ttype_width-1)  );
ex4_rs_is_latch: tri_rlmreg_p
  generic map (width => ex4_rs_is_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_rs_is_offset to ex4_rs_is_offset+ex4_rs_is_q'length-1),
            scout   => sov(ex4_rs_is_offset to ex4_rs_is_offset+ex4_rs_is_q'length-1),
            din     => ex4_rs_is_d(0 to rs_is_width-1),
            dout    => ex4_rs_is_q(0 to rs_is_width-1)  );
ex4_state_latch: tri_rlmreg_p
  generic map (width => ex4_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_state_offset to ex4_state_offset+ex4_state_q'length-1),
            scout   => sov(ex4_state_offset to ex4_state_offset+ex4_state_q'length-1),
            din     => ex4_state_d(0 to state_width-1),
            dout    => ex4_state_q(0 to state_width-1)  );
ex4_t_latch: tri_rlmreg_p
  generic map (width => ex4_t_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex4_t_offset to ex4_t_offset+ex4_t_q'length-1),
            scout   => sov(ex4_t_offset to ex4_t_offset+ex4_t_q'length-1),
            din     => ex4_t_d(0 to t_width-1),
            dout    => ex4_t_q(0 to t_width-1)  );
--------------------------------------------------
ex5_valid_latch: tri_rlmreg_p
  generic map (width => ex5_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_valid_offset to ex5_valid_offset+ex5_valid_q'length-1),
            scout   => sov(ex5_valid_offset to ex5_valid_offset+ex5_valid_q'length-1),
            din     => ex5_valid_d(0 to thdid_width-1),
            dout    => ex5_valid_q(0 to thdid_width-1)  );
ex5_ttype_latch: tri_rlmreg_p
  generic map (width => ex5_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_ttype_offset to ex5_ttype_offset+ex5_ttype_q'length-1),
            scout   => sov(ex5_ttype_offset to ex5_ttype_offset+ex5_ttype_q'length-1),
            din     => ex5_ttype_d(0 to ttype_width-1),
            dout    => ex5_ttype_q(0 to ttype_width-1)  );
ex5_rs_is_latch: tri_rlmreg_p
  generic map (width => ex5_rs_is_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_rs_is_offset to ex5_rs_is_offset+ex5_rs_is_q'length-1),
            scout   => sov(ex5_rs_is_offset to ex5_rs_is_offset+ex5_rs_is_q'length-1),
            din     => ex5_rs_is_d(0 to rs_is_width-1),
            dout    => ex5_rs_is_q(0 to rs_is_width-1)  );
ex5_state_latch: tri_rlmreg_p
  generic map (width => ex5_state_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_state_offset to ex5_state_offset+ex5_state_q'length-1),
            scout   => sov(ex5_state_offset to ex5_state_offset+ex5_state_q'length-1),
            din     => ex5_state_d(0 to state_width-1),
            dout    => ex5_state_q(0 to state_width-1)  );
ex5_t_latch: tri_rlmreg_p
  generic map (width => ex5_t_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex5_t_offset to ex5_t_offset+ex5_t_q'length-1),
            scout   => sov(ex5_t_offset to ex5_t_offset+ex5_t_q'length-1),
            din     => ex5_t_d(0 to t_width-1),
            dout    => ex5_t_q(0 to t_width-1)  );
--------------------------------------------------
ex6_valid_latch: tri_rlmreg_p
  generic map (width => ex6_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_valid_offset to ex6_valid_offset+ex6_valid_q'length-1),
            scout   => sov(ex6_valid_offset to ex6_valid_offset+ex6_valid_q'length-1),
            din     => ex6_valid_d(0 to thdid_width-1),
            dout    => ex6_valid_q(0 to thdid_width-1)  );
ex6_ttype_latch: tri_rlmreg_p
  generic map (width => ex6_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_ttype_offset to ex6_ttype_offset+ex6_ttype_q'length-1),
            scout   => sov(ex6_ttype_offset to ex6_ttype_offset+ex6_ttype_q'length-1),
            din     => ex6_ttype_d(0 to ttype_width-1),
            dout    => ex6_ttype_q(0 to ttype_width-1)  );
ex6_isel_latch: tri_rlmreg_p
  generic map (width => ex6_isel_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_isel_offset to ex6_isel_offset+ex6_isel_q'length-1),
            scout   => sov(ex6_isel_offset to ex6_isel_offset+ex6_isel_q'length-1),
            din     => ex6_isel_d(0 to ex6_isel_d'length-1),
            dout    => ex6_isel_q(0 to ex6_isel_q'length-1)  );
ex6_size_latch: tri_rlmreg_p
  generic map (width => ex6_size_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_size_offset to ex6_size_offset+ex6_size_q'length-1),
            scout   => sov(ex6_size_offset to ex6_size_offset+ex6_size_q'length-1),
            din     => ex6_size_d(0 to ex6_size_d'length-1),
            dout    => ex6_size_q(0 to ex6_size_q'length-1)  );
ex6_gs_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_gs_offset),
            scout   => sov(ex6_gs_offset),
            din     => ex6_gs_d,
            dout    => ex6_gs_q);
ex6_ts_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_ts_offset),
            scout   => sov(ex6_ts_offset),
            din     => ex6_ts_d,
            dout    => ex6_ts_q);
ex6_ind_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_ind_offset),
            scout   => sov(ex6_ind_offset),
            din     => ex6_ind_d,
            dout    => ex6_ind_q);
ex6_pid_latch: tri_rlmreg_p
  generic map (width => ex6_pid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_pid_offset to ex6_pid_offset+ex6_pid_q'length-1),
            scout   => sov(ex6_pid_offset to ex6_pid_offset+ex6_pid_q'length-1),
            din     => ex6_pid_d(0 to pid_width-1),
            dout    => ex6_pid_q(0 to pid_width-1)  );
ex6_lpid_latch: tri_rlmreg_p
  generic map (width => ex6_lpid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(ex6_lpid_offset to ex6_lpid_offset+ex6_lpid_q'length-1),
            scout   => sov(ex6_lpid_offset to ex6_lpid_offset+ex6_lpid_q'length-1),
            din     => ex6_lpid_d(0 to lpid_width-1),
            dout    => ex6_lpid_q(0 to lpid_width-1)  );
--------------------------------------------------
inv_seq_latch: tri_rlmreg_p
  generic map (width => inv_seq_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(inv_seq_offset to inv_seq_offset+inv_seq_q'length-1),
            scout   => sov(inv_seq_offset to inv_seq_offset+inv_seq_q'length-1),
            din     => inv_seq_d(0 to inv_seq_width-1),
            dout    => inv_seq_q(0 to inv_seq_width-1)  );
hold_req_latch: tri_rlmreg_p
  generic map (width => hold_req_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(hold_req_offset to hold_req_offset+hold_req_q'length-1),
            scout   => sov(hold_req_offset to hold_req_offset+hold_req_q'length-1),
            din     => hold_req_d(0 to thdid_width-1),
            dout    => hold_req_q(0 to thdid_width-1)  );
hold_ack_latch: tri_rlmreg_p
  generic map (width => hold_ack_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(hold_ack_offset to hold_ack_offset+hold_ack_q'length-1),
            scout   => sov(hold_ack_offset to hold_ack_offset+hold_ack_q'length-1),
            din     => hold_ack_d(0 to thdid_width-1),
            dout    => hold_ack_q(0 to thdid_width-1)  );
hold_done_latch: tri_rlmreg_p
  generic map (width => hold_done_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(hold_done_offset to hold_done_offset+hold_done_q'length-1),
            scout   => sov(hold_done_offset to hold_done_offset+hold_done_q'length-1),
            din     => hold_done_d(0 to thdid_width-1),
            dout    => hold_done_q(0 to thdid_width-1)  );
local_barrier_latch: tri_rlmreg_p
  generic map (width => local_barrier_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(local_barrier_offset to local_barrier_offset+local_barrier_q'length-1),
            scout   => sov(local_barrier_offset to local_barrier_offset+local_barrier_q'length-1),
            din     => local_barrier_d(0 to thdid_width-1),
            dout    => local_barrier_q(0 to thdid_width-1)  );
global_barrier_latch: tri_rlmreg_p
  generic map (width => global_barrier_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(global_barrier_offset to global_barrier_offset+global_barrier_q'length-1),
            scout   => sov(global_barrier_offset to global_barrier_offset+global_barrier_q'length-1),
            din     => global_barrier_d(0 to thdid_width-1),
            dout    => global_barrier_q(0 to thdid_width-1)  );
barrier_done_latch: tri_rlmreg_p
  generic map (width => barrier_done_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(barrier_done_offset to barrier_done_offset+barrier_done_q'length-1),
            scout   => sov(barrier_done_offset to barrier_done_offset+barrier_done_q'length-1),
            din     => barrier_done_d(0 to thdid_width-1),
            dout    => barrier_done_q(0 to thdid_width-1));
illeg_instr_latch: tri_rlmreg_p
  generic map (width => illeg_instr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(illeg_instr_offset to illeg_instr_offset+illeg_instr_q'length-1),
            scout   => sov(illeg_instr_offset to illeg_instr_offset+illeg_instr_q'length-1),
            din     => illeg_instr_d(0 to thdid_width-1),
            dout    => illeg_instr_q(0 to thdid_width-1));
local_reject_latch: tri_rlmreg_p
  generic map (width => local_reject_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(local_reject_offset to local_reject_offset+local_reject_q'length-1),
            scout   => sov(local_reject_offset to local_reject_offset+local_reject_q'length-1),
            din     => local_reject_d(0 to thdid_width-1),
            dout    => local_reject_q(0 to thdid_width-1));
-- snoop output and ack latches 0:ierat, 1:derat, 2:tlb
snoop_coming_latch: tri_rlmreg_p
  generic map (width => snoop_coming_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(snoop_coming_offset to snoop_coming_offset+snoop_coming_q'length-1),
            scout   => sov(snoop_coming_offset to snoop_coming_offset+snoop_coming_q'length-1),
            din     => snoop_coming_d,
            dout    => snoop_coming_q  );
snoop_valid_latch: tri_rlmreg_p
  generic map (width => snoop_valid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(snoop_valid_offset to snoop_valid_offset+snoop_valid_q'length-1),
            scout   => sov(snoop_valid_offset to snoop_valid_offset+snoop_valid_q'length-1),
            din     => snoop_valid_d,
            dout    => snoop_valid_q  );
snoop_attr_latch: tri_rlmreg_p
  generic map (width => snoop_attr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => snoop_coming_q(3),
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
            act     => snoop_coming_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(snoop_vpn_offset to snoop_vpn_offset+snoop_vpn_q'length-1),
            scout   => sov(snoop_vpn_offset to snoop_vpn_offset+snoop_vpn_q'length-1),
            din     => snoop_vpn_d(52-epn_width to 51),
            dout    => snoop_vpn_q(52-epn_width to 51)  );
snoop_attr_clone_latch: tri_rlmreg_p
  generic map (width => snoop_attr_clone_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => snoop_coming_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(snoop_attr_clone_offset to snoop_attr_clone_offset+snoop_attr_clone_q'length-1),
            scout   => sov(snoop_attr_clone_offset to snoop_attr_clone_offset+snoop_attr_clone_q'length-1),
            din     => snoop_attr_clone_d,
            dout    => snoop_attr_clone_q  );
snoop_attr_tlb_spec_latch: tri_rlmreg_p
  generic map (width => snoop_attr_tlb_spec_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => snoop_coming_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(snoop_attr_tlb_spec_offset to snoop_attr_tlb_spec_offset+snoop_attr_tlb_spec_q'length-1),
            scout   => sov(snoop_attr_tlb_spec_offset to snoop_attr_tlb_spec_offset+snoop_attr_tlb_spec_q'length-1),
            din     => snoop_attr_tlb_spec_d,
            dout    => snoop_attr_tlb_spec_q  );
snoop_vpn_clone_latch: tri_rlmreg_p
  generic map (width => snoop_vpn_clone_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => snoop_coming_q(4),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(snoop_vpn_clone_offset to snoop_vpn_clone_offset+snoop_vpn_clone_q'length-1),
            scout   => sov(snoop_vpn_clone_offset to snoop_vpn_clone_offset+snoop_vpn_clone_q'length-1),
            din     => snoop_vpn_clone_d(52-epn_width to 51),
            dout    => snoop_vpn_clone_q(52-epn_width to 51)  );
snoop_ack_latch: tri_rlmreg_p
  generic map (width => snoop_ack_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(snoop_ack_offset to snoop_ack_offset+snoop_ack_q'length-1),
            scout   => sov(snoop_ack_offset to snoop_ack_offset+snoop_ack_q'length-1),
            din     => snoop_ack_d,
            dout    => snoop_ack_q  );
mm_xu_quiesce_latch: tri_rlmreg_p
  generic map (width => mm_xu_quiesce_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(mm_xu_quiesce_offset to mm_xu_quiesce_offset+mm_xu_quiesce_q'length-1),
            scout   => sov(mm_xu_quiesce_offset to mm_xu_quiesce_offset+mm_xu_quiesce_q'length-1),
            din     => mm_xu_quiesce_d(0 to thdid_width-1),
            dout    => mm_xu_quiesce_q(0 to thdid_width-1)  );
-- snoop invalidate input latches
an_ac_back_inv_latch: tri_rlmreg_p
  generic map (width => an_ac_back_inv_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(an_ac_back_inv_offset to an_ac_back_inv_offset+an_ac_back_inv_q'length-1),
            scout   => sov(an_ac_back_inv_offset to an_ac_back_inv_offset+an_ac_back_inv_q'length-1),
            din     => an_ac_back_inv_d,
            dout    => an_ac_back_inv_q  );
an_ac_back_inv_addr_latch: tri_rlmreg_p
  generic map (width => an_ac_back_inv_addr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(an_ac_back_inv_addr_offset to an_ac_back_inv_addr_offset+an_ac_back_inv_addr_q'length-1),
            scout   => sov(an_ac_back_inv_addr_offset to an_ac_back_inv_addr_offset+an_ac_back_inv_addr_q'length-1),
            din     => an_ac_back_inv_addr_d(64-real_addr_width to 63),
            dout    => an_ac_back_inv_addr_q(64-real_addr_width to 63)  );
an_ac_back_inv_lpar_id_latch: tri_rlmreg_p
  generic map (width => an_ac_back_inv_lpar_id_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(an_ac_back_inv_lpar_id_offset to an_ac_back_inv_lpar_id_offset+an_ac_back_inv_lpar_id_q'length-1),
            scout   => sov(an_ac_back_inv_lpar_id_offset to an_ac_back_inv_lpar_id_offset+an_ac_back_inv_lpar_id_q'length-1),
            din     => an_ac_back_inv_lpar_id_d(0 to lpid_width-1),
            dout    => an_ac_back_inv_lpar_id_q(0 to lpid_width-1)  );
-- Load/Store unit request interface latches
lsu_tokens_latch: tri_rlmreg_p
  generic map (width => lsu_tokens_q'length, init => 1, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lsu_tokens_offset to lsu_tokens_offset+lsu_tokens_q'length-1),
            scout   => sov(lsu_tokens_offset to lsu_tokens_offset+lsu_tokens_q'length-1),
            din     => lsu_tokens_d(0 to 1),
            dout    => lsu_tokens_q(0 to 1)  );
lsu_req_latch: tri_rlmreg_p
  generic map (width => lsu_req_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lsu_req_offset to lsu_req_offset+lsu_req_q'length-1),
            scout   => sov(lsu_req_offset to lsu_req_offset+lsu_req_q'length-1),
            din     => lsu_req_d(0 to thdid_width-1),
            dout    => lsu_req_q(0 to thdid_width-1)  );
lsu_ttype_latch: tri_rlmreg_p
  generic map (width => lsu_ttype_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lsu_ttype_offset to lsu_ttype_offset+lsu_ttype_q'length-1),
            scout   => sov(lsu_ttype_offset to lsu_ttype_offset+lsu_ttype_q'length-1),
            din     => lsu_ttype_d(0 to 1),
            dout    => lsu_ttype_q(0 to 1)  );
lsu_ubits_latch: tri_rlmreg_p
  generic map (width => lsu_ubits_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lsu_ubits_offset to lsu_ubits_offset+lsu_ubits_q'length-1),
            scout   => sov(lsu_ubits_offset to lsu_ubits_offset+lsu_ubits_q'length-1),
            din     => lsu_ubits_d(0 to 3),
            dout    => lsu_ubits_q(0 to 3)  );
lsu_wimge_latch: tri_rlmreg_p
  generic map (width => lsu_wimge_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lsu_wimge_offset to lsu_wimge_offset+lsu_wimge_q'length-1),
            scout   => sov(lsu_wimge_offset to lsu_wimge_offset+lsu_wimge_q'length-1),
            din     => lsu_wimge_d(0 to 4),
            dout    => lsu_wimge_q(0 to 4)  );
lsu_addr_latch: tri_rlmreg_p
  generic map (width => lsu_addr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lsu_addr_offset to lsu_addr_offset+lsu_addr_q'length-1),
            scout   => sov(lsu_addr_offset to lsu_addr_offset+lsu_addr_q'length-1),
            din     => lsu_addr_d(64-real_addr_width to 63),
            dout    => lsu_addr_q(64-real_addr_width to 63)  );
lsu_lpid_latch: tri_rlmreg_p
  generic map (width => lsu_lpid_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lsu_lpid_offset to lsu_lpid_offset+lsu_lpid_q'length-1),
            scout   => sov(lsu_lpid_offset to lsu_lpid_offset+lsu_lpid_q'length-1),
            din     => lsu_lpid_d(0 to lpid_width-1),
            dout    => lsu_lpid_q(0 to lpid_width-1)  );
lsu_ind_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lsu_ind_offset),
            scout   => sov(lsu_ind_offset),
            din     => lsu_ind_d,
            dout    => lsu_ind_q);
lsu_gs_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lsu_gs_offset),
            scout   => sov(lsu_gs_offset),
            din     => lsu_gs_d,
            dout    => lsu_gs_q);
lsu_lbit_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(lsu_lbit_offset),
            scout   => sov(lsu_lbit_offset),
            din     => lsu_lbit_d,
            dout    => lsu_lbit_q);
-- core night-night sleep mode
power_managed_latch: tri_rlmreg_p
  generic map (width => power_managed_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(power_managed_offset to power_managed_offset+power_managed_q'length-1),
            scout   => sov(power_managed_offset to power_managed_offset+power_managed_q'length-1),
            din     => power_managed_d,
            dout    => power_managed_q  );
tlbwe_back_inv_latch: tri_rlmreg_p
  generic map (width => tlbwe_back_inv_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(tlbwe_back_inv_offset to tlbwe_back_inv_offset+tlbwe_back_inv_q'length-1),
            scout   => sov(tlbwe_back_inv_offset to tlbwe_back_inv_offset+tlbwe_back_inv_q'length-1),
            din     => tlbwe_back_inv_d(0 to thdid_width+1),
            dout    => tlbwe_back_inv_q(0 to thdid_width+1)  );
tlbwe_back_inv_addr_latch: tri_rlmreg_p
  generic map (width => tlbwe_back_inv_addr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(tlbwe_back_inv_addr_offset to tlbwe_back_inv_addr_offset+tlbwe_back_inv_addr_q'length-1),
            scout   => sov(tlbwe_back_inv_addr_offset to tlbwe_back_inv_addr_offset+tlbwe_back_inv_addr_q'length-1),
            din     => tlbwe_back_inv_addr_d(0 to epn_width-1),
            dout    => tlbwe_back_inv_addr_q(0 to epn_width-1)  );
tlbwe_back_inv_attr_latch: tri_rlmreg_p
  generic map (width => tlbwe_back_inv_attr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(tlbwe_back_inv_attr_offset to tlbwe_back_inv_attr_offset+tlbwe_back_inv_attr_q'length-1),
            scout   => sov(tlbwe_back_inv_attr_offset to tlbwe_back_inv_attr_offset+tlbwe_back_inv_attr_q'length-1),
            din     => tlbwe_back_inv_attr_d,
            dout    => tlbwe_back_inv_attr_q  );
inv_seq_inprogress_latch: tri_rlmreg_p
  generic map (width => inv_seq_inprogress_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(inv_seq_inprogress_offset to inv_seq_inprogress_offset+inv_seq_inprogress_q'length-1),
            scout   => sov(inv_seq_inprogress_offset to inv_seq_inprogress_offset+inv_seq_inprogress_q'length-1),
            din     => inv_seq_inprogress_d,
            dout    => inv_seq_inprogress_q);
xu_mm_ccr2_notlb_latch: tri_rlmreg_p
  generic map (width => xu_mm_ccr2_notlb_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(xu_mm_ccr2_notlb_offset to xu_mm_ccr2_notlb_offset+xu_mm_ccr2_notlb_q'length-1),
            scout   => sov(xu_mm_ccr2_notlb_offset to xu_mm_ccr2_notlb_offset+xu_mm_ccr2_notlb_q'length-1),
            din     => xu_mm_ccr2_notlb_d,
            dout    => xu_mm_ccr2_notlb_q);
spare_latch: tri_rlmreg_p
  generic map (width => spare_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(spare_offset to spare_offset+spare_q'length-1),
            scout   => sov(spare_offset to spare_offset+spare_q'length-1),
            din     => spare_q,
            dout    => spare_q);
-- non-scannable config latches
epcr_dgtmi_latch : tri_regk
  generic map (width => xu_mm_epcr_dgtmi_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => xu_mm_spr_epcr_dgtmi,
            dout    => xu_mm_epcr_dgtmi_q);
lpidr_latch : tri_regk
  generic map (width => lpidr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => lpidr,
            dout    => lpidr_q);
mmucr1_latch : tri_regk
  generic map (width => mmucr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => mmucr1,
            dout    => mmucr1_q);
mmucr1_csinv_latch : tri_regk
  generic map (width => mmucr1_csinv_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => mmucr1_csinv,
            dout    => mmucr1_csinv_q);
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
siv(0 to scan_right) <= sov(1 to scan_right) & ac_func_scan_in;
ac_func_scan_out <= sov(0);
end mmq_inval;
-- PowerISA v2.06   Sec. 6.11.4.4  TLB Lookaside Information (i.e. shadow/erats)
--  If TLBnCFG HES =0, lookaside info is kept coherent with the TLB and is
--  invisible to software. Any write to the TLB that displaces or updates an entry
--  will be reflected in the lookaside info, invalidating the lookaside info
--  corresponding to the previous TLB entry.  Any type of invalidation of an
--  entry in TLB will also invalidate the corresponding lookaside info.
--  If TLBnCFG HES =1, lookaside info is not required to be kept coherent with TLB.
--  Only the following conditions will keep coherency.  MMUCRS0.tlb0_fi will
--  invalidate ALL lookaside info. tlbilx and tlbivax invalidate lookaside info
--  corresponding to TLB values that they are specified to invalidate as well as
--  those TLB entry values that would have been invalidated except for their
--  IPROT=1 value.
--  Programming Note: If TLBnCFG HES =1 for a TLB array and it is important that lookaside info
--  corresponding to a TLB entry be invalidated, software should use tlbilx or tlbivax
--  to invalidate the VA.
--  Architecture Note: For TLB's with TLBnCFG HES =1, the tlbilx and tlbivax instructions
--  are defined to invalidate lookaside info (but not TLB entries) with IPROT=1 because
--  tlbwe is not guaranteed to invalidate lookaside info corresponding to the previous
--  value of the TLB entry (i.e. for TLBnCFG HES =1). There needs to be a mechanism to
--  invalidate such lookaside information.
