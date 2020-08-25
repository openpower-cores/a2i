-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


--********************************************************************
--*
--* TITLE: debug event mux
--*
--* NAME: mmq_dbg.vhdl
--*
--*********************************************************************

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

entity mmq_dbg is
generic(thdid_width       : integer := 4;
          tlb_ways          : natural := 4;
          tlb_addr_width    : natural := 7;
          tlb_way_width     : natural := 168;
          tlb_word_width    : natural := 84;
          tlb_tag_width     : natural := 110;
          lru_width         : natural := 16;
          expand_type             : integer := 2 );
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;
     
     pc_func_slp_sl_thold_2     : in std_ulogic;
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

     mmucr2      : in  std_ulogic_vector(8 to 11);

     pc_mm_trace_bus_enable     : in  std_ulogic;
     pc_mm_debug_mux1_ctrls     : in  std_ulogic_vector(0 to 15);

     debug_bus_in              : in  std_ulogic_vector(0 to 87);
     trace_triggers_in          : in  std_ulogic_vector(0 to 11);

     debug_bus_out              : out std_ulogic_vector(0 to 87);
     debug_bus_out_int          : out std_ulogic_vector(0 to 7);  -- internal replicate to iu_fetch
     trace_triggers_out         : out std_ulogic_vector(0 to 11);

     ----------- spr debug signals
     spr_dbg_match_64b           : in std_ulogic;  -- these match sigs are spr_int phase
     spr_dbg_match_any_mmu       : in std_ulogic;
     spr_dbg_match_any_mas       : in std_ulogic;
     spr_dbg_match_pid           : in std_ulogic;
     spr_dbg_match_lpidr         : in std_ulogic;
     spr_dbg_match_mmucr0        : in std_ulogic;
     spr_dbg_match_mmucr1        : in std_ulogic;
     spr_dbg_match_mmucr2        : in std_ulogic;
     spr_dbg_match_mmucr3        : in std_ulogic;

     spr_dbg_match_mmucsr0       : in std_ulogic;  
     spr_dbg_match_mmucfg        : in std_ulogic;  
     spr_dbg_match_tlb0cfg       : in std_ulogic;  
     spr_dbg_match_tlb0ps        : in std_ulogic;  
     spr_dbg_match_lratcfg       : in std_ulogic;  
     spr_dbg_match_lratps        : in std_ulogic;  
     spr_dbg_match_eptcfg        : in std_ulogic;  
     spr_dbg_match_lper          : in std_ulogic;  
     spr_dbg_match_lperu         : in std_ulogic;  

     spr_dbg_match_mas0          : in std_ulogic;  
     spr_dbg_match_mas1          : in std_ulogic;  
     spr_dbg_match_mas2          : in std_ulogic; 
     spr_dbg_match_mas2u         : in std_ulogic; 
     spr_dbg_match_mas3          : in std_ulogic;  
     spr_dbg_match_mas4          : in std_ulogic;  
     spr_dbg_match_mas5          : in std_ulogic;  
     spr_dbg_match_mas6          : in std_ulogic;  
     spr_dbg_match_mas7          : in std_ulogic;  
     spr_dbg_match_mas8          : in std_ulogic;  
     spr_dbg_match_mas01_64b     : in std_ulogic;  
     spr_dbg_match_mas56_64b     : in std_ulogic;  
     spr_dbg_match_mas73_64b     : in std_ulogic;  
     spr_dbg_match_mas81_64b     : in std_ulogic;  

     spr_dbg_slowspr_val_int         : in std_ulogic;  -- spr_int phase
     spr_dbg_slowspr_rw_int          : in std_ulogic;
     spr_dbg_slowspr_etid_int        : in std_ulogic_vector(0 to 1);
     spr_dbg_slowspr_addr_int        : in std_ulogic_vector(0 to 9);
     spr_dbg_slowspr_val_out         : in std_ulogic; -- spr_out phase
     spr_dbg_slowspr_done_out        : in std_ulogic;
     spr_dbg_slowspr_data_out        : in std_ulogic_vector(0 to 63);

       
     ----------- mmq_inval debug signals
     inval_dbg_seq_q                  : in std_ulogic_vector(0 to 4);
     inval_dbg_seq_idle               : in std_ulogic;
     inval_dbg_seq_snoop_inprogress   : in std_ulogic;
     inval_dbg_seq_snoop_done         : in std_ulogic;
     inval_dbg_seq_local_done         : in std_ulogic;
     inval_dbg_seq_tlb0fi_done        : in std_ulogic;
     inval_dbg_seq_tlbwe_snoop_done   : in std_ulogic;
     inval_dbg_ex6_valid              : in std_ulogic;
     inval_dbg_ex6_thdid              : in std_ulogic_vector(0 to 1);  -- encoded
     inval_dbg_ex6_ttype              : in std_ulogic_vector(0 to 2);  -- encoded
     inval_dbg_snoop_forme            : in std_ulogic;
     inval_dbg_snoop_local_reject     : in std_ulogic;
     inval_dbg_an_ac_back_inv_q       : in std_ulogic_vector(2 to 8);    -- 2=valid b, 3=target b, 4=L, 5=GS, 6=IND, 7=local, 8=reject
     inval_dbg_an_ac_back_inv_lpar_id_q   : in std_ulogic_vector(0 to 7);
     inval_dbg_an_ac_back_inv_addr_q      : in std_ulogic_vector(22 to 63);
     inval_dbg_snoop_valid_q          : in std_ulogic_vector(0 to 2);
     inval_dbg_snoop_ack_q            : in std_ulogic_vector(0 to 2);
     inval_dbg_snoop_attr_q           : in std_ulogic_vector(0 to 34);
     inval_dbg_snoop_attr_tlb_spec_q  : in std_ulogic_vector(18 to 19);
     inval_dbg_snoop_vpn_q            : in std_ulogic_vector(17 to 51);
     inval_dbg_lsu_tokens_q           : in std_ulogic_vector(0 to 1);
     
     ----------- tlb_req debug signals
     tlb_req_dbg_ierat_iu5_valid_q    : in  std_ulogic;
     tlb_req_dbg_ierat_iu5_thdid      : in  std_ulogic_vector(0 to 1);
     tlb_req_dbg_ierat_iu5_state_q    : in  std_ulogic_vector(0 to 3);
     tlb_req_dbg_ierat_inptr_q        : in  std_ulogic_vector(0 to 1);             
     tlb_req_dbg_ierat_outptr_q       : in  std_ulogic_vector(0 to 1);
     tlb_req_dbg_ierat_req_valid_q    : in  std_ulogic_vector(0 to 3);
     tlb_req_dbg_ierat_req_nonspec_q  : in  std_ulogic_vector(0 to 3);
     tlb_req_dbg_ierat_req_thdid      : in  std_ulogic_vector(0 to 7); -- encoded
     tlb_req_dbg_ierat_req_dup_q      : in  std_ulogic_vector(0 to 3);
     tlb_req_dbg_derat_ex6_valid_q    : in  std_ulogic;
     tlb_req_dbg_derat_ex6_thdid      : in  std_ulogic_vector(0 to 1); -- encoded
     tlb_req_dbg_derat_ex6_state_q    : in  std_ulogic_vector(0 to 3);
     tlb_req_dbg_derat_inptr_q        : in  std_ulogic_vector(0 to 1);
     tlb_req_dbg_derat_outptr_q       : in  std_ulogic_vector(0 to 1);
     tlb_req_dbg_derat_req_valid_q    : in  std_ulogic_vector(0 to 3);
     tlb_req_dbg_derat_req_thdid      : in  std_ulogic_vector(0 to 7); -- encoded
     tlb_req_dbg_derat_req_ttype_q    : in  std_ulogic_vector(0 to 7);
     tlb_req_dbg_derat_req_dup_q      : in  std_ulogic_vector(0 to 3);

    ----------- tlb_ctl debug signals
     tlb_ctl_dbg_seq_q                : in  std_ulogic_vector(0 to 5);  -- tlb_seq_q
     tlb_ctl_dbg_seq_idle             : in  std_ulogic;
     tlb_ctl_dbg_seq_any_done_sig     : in  std_ulogic;
     tlb_ctl_dbg_seq_abort            : in  std_ulogic;
     tlb_ctl_dbg_any_tlb_req_sig      : in  std_ulogic;
     tlb_ctl_dbg_any_req_taken_sig    : in  std_ulogic;
     tlb_ctl_dbg_tag0_valid          : in  std_ulogic;
     tlb_ctl_dbg_tag0_thdid          : in  std_ulogic_vector(0 to 1); -- encoded
     tlb_ctl_dbg_tag0_type           : in  std_ulogic_vector(0 to 2); -- encoded
     tlb_ctl_dbg_tag0_wq             : in  std_ulogic_vector(0 to 1); -- encoded
     tlb_ctl_dbg_tag0_gs             : in  std_ulogic;  
     tlb_ctl_dbg_tag0_pr             : in  std_ulogic;  
     tlb_ctl_dbg_tag0_atsel          : in  std_ulogic;  
     tlb_ctl_dbg_tag5_tlb_write_q    : in  std_ulogic_vector(0 to 3);
     tlb_ctl_dbg_resv_valid          : in  std_ulogic_vector(0 to 3);
     tlb_ctl_dbg_set_resv            : in  std_ulogic_vector(0 to 3);
     tlb_ctl_dbg_resv_match_vec_q    : in  std_ulogic_vector(0 to 3);
     tlb_ctl_dbg_any_tag_flush_sig   : in  std_ulogic;
     tlb_ctl_dbg_resv0_tag0_lpid_match         : in std_ulogic;
     tlb_ctl_dbg_resv0_tag0_pid_match          : in std_ulogic;
     tlb_ctl_dbg_resv0_tag0_as_snoop_match     : in std_ulogic;
     tlb_ctl_dbg_resv0_tag0_gs_snoop_match     : in std_ulogic;
     tlb_ctl_dbg_resv0_tag0_as_tlbwe_match     : in std_ulogic;
     tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match     : in std_ulogic;
     tlb_ctl_dbg_resv0_tag0_ind_match          : in std_ulogic;
     tlb_ctl_dbg_resv0_tag0_epn_loc_match      : in std_ulogic;
     tlb_ctl_dbg_resv0_tag0_epn_glob_match     : in std_ulogic;
     tlb_ctl_dbg_resv0_tag0_class_match        : in std_ulogic;
     tlb_ctl_dbg_resv1_tag0_lpid_match         : in std_ulogic;
     tlb_ctl_dbg_resv1_tag0_pid_match          : in std_ulogic;
     tlb_ctl_dbg_resv1_tag0_as_snoop_match     : in std_ulogic;
     tlb_ctl_dbg_resv1_tag0_gs_snoop_match     : in std_ulogic;
     tlb_ctl_dbg_resv1_tag0_as_tlbwe_match     : in std_ulogic;
     tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match     : in std_ulogic;
     tlb_ctl_dbg_resv1_tag0_ind_match          : in std_ulogic;
     tlb_ctl_dbg_resv1_tag0_epn_loc_match      : in std_ulogic;
     tlb_ctl_dbg_resv1_tag0_epn_glob_match     : in std_ulogic;
     tlb_ctl_dbg_resv1_tag0_class_match        : in std_ulogic;
     tlb_ctl_dbg_resv2_tag0_lpid_match         : in std_ulogic;
     tlb_ctl_dbg_resv2_tag0_pid_match          : in std_ulogic;
     tlb_ctl_dbg_resv2_tag0_as_snoop_match     : in std_ulogic;
     tlb_ctl_dbg_resv2_tag0_gs_snoop_match     : in std_ulogic;
     tlb_ctl_dbg_resv2_tag0_as_tlbwe_match     : in std_ulogic;
     tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match     : in std_ulogic;
     tlb_ctl_dbg_resv2_tag0_ind_match          : in std_ulogic;
     tlb_ctl_dbg_resv2_tag0_epn_loc_match      : in std_ulogic;
     tlb_ctl_dbg_resv2_tag0_epn_glob_match     : in std_ulogic;
     tlb_ctl_dbg_resv2_tag0_class_match        : in std_ulogic;
     tlb_ctl_dbg_resv3_tag0_lpid_match         : in std_ulogic;
     tlb_ctl_dbg_resv3_tag0_pid_match          : in std_ulogic;
     tlb_ctl_dbg_resv3_tag0_as_snoop_match     : in std_ulogic;
     tlb_ctl_dbg_resv3_tag0_gs_snoop_match     : in std_ulogic;
     tlb_ctl_dbg_resv3_tag0_as_tlbwe_match     : in std_ulogic;
     tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match     : in std_ulogic;
     tlb_ctl_dbg_resv3_tag0_ind_match          : in std_ulogic;
     tlb_ctl_dbg_resv3_tag0_epn_loc_match      : in std_ulogic;
     tlb_ctl_dbg_resv3_tag0_epn_glob_match     : in std_ulogic;
     tlb_ctl_dbg_resv3_tag0_class_match        : in std_ulogic;
     tlb_ctl_dbg_clr_resv_q                    : in std_ulogic_vector(0 to 3);  -- tag5
     tlb_ctl_dbg_clr_resv_terms                : in std_ulogic_vector(0 to 3);  -- tag5, threadwise condensed into to  tlbivax, tlbilx, tlbwe, ptereload
     
     ----------- tlb_cmp debug signals
     tlb_cmp_dbg_tag4                   : in  std_ulogic_vector(0 to tlb_tag_width-1);
     tlb_cmp_dbg_tag4_wayhit            : in  std_ulogic_vector(0 to tlb_ways);
     tlb_cmp_dbg_addr4                  : in  std_ulogic_vector(0 to tlb_addr_width-1);
     tlb_cmp_dbg_tag4_way               : in  std_ulogic_vector(0 to tlb_way_width-1);
     tlb_cmp_dbg_tag4_parerr            : in  std_ulogic_vector(0 to 4);
     tlb_cmp_dbg_tag4_lru_dataout_q     : in std_ulogic_vector(0 to lru_width-5);
     tlb_cmp_dbg_tag5_tlb_datain_q      : in  std_ulogic_vector(0 to tlb_way_width-1);
     tlb_cmp_dbg_tag5_lru_datain_q      : in std_ulogic_vector(0 to lru_width-5);
     tlb_cmp_dbg_tag5_lru_write         : in std_ulogic;
     tlb_cmp_dbg_tag5_any_exception     : in std_ulogic;
     tlb_cmp_dbg_tag5_except_type_q     : in std_ulogic_vector(0 to 3);
     tlb_cmp_dbg_tag5_except_thdid_q    : in std_ulogic_vector(0 to 1);
     tlb_cmp_dbg_tag5_erat_rel_val      : in  std_ulogic_vector(0 to 9);
     tlb_cmp_dbg_tag5_erat_rel_data     : in  std_ulogic_vector(0 to 131);
     tlb_cmp_dbg_erat_dup_q             : in  std_ulogic_vector(0 to 19);
     

     tlb_cmp_dbg_addr_enable            : in  std_ulogic_vector(0 to 8);
     tlb_cmp_dbg_pgsize_enable          : in  std_ulogic;
     tlb_cmp_dbg_class_enable           : in  std_ulogic;
     tlb_cmp_dbg_extclass_enable        : in  std_ulogic_vector(0 to 1);
     tlb_cmp_dbg_state_enable           : in  std_ulogic_vector(0 to 1);
     tlb_cmp_dbg_thdid_enable           : in  std_ulogic;
     tlb_cmp_dbg_pid_enable             : in  std_ulogic;
     tlb_cmp_dbg_lpid_enable            : in  std_ulogic;
     tlb_cmp_dbg_ind_enable             : in  std_ulogic;
     tlb_cmp_dbg_iprot_enable           : in  std_ulogic;
     tlb_cmp_dbg_way0_entry_v                        : in  std_ulogic;    -- these are tag3 versions
     tlb_cmp_dbg_way0_addr_match                     : in  std_ulogic;
     tlb_cmp_dbg_way0_pgsize_match                   : in  std_ulogic;
     tlb_cmp_dbg_way0_class_match                    : in  std_ulogic;
     tlb_cmp_dbg_way0_extclass_match                 : in  std_ulogic;
     tlb_cmp_dbg_way0_state_match                    : in  std_ulogic;
     tlb_cmp_dbg_way0_thdid_match                    : in  std_ulogic;
     tlb_cmp_dbg_way0_pid_match                      : in  std_ulogic;
     tlb_cmp_dbg_way0_lpid_match                     : in  std_ulogic;
     tlb_cmp_dbg_way0_ind_match                      : in  std_ulogic;
     tlb_cmp_dbg_way0_iprot_match                    : in  std_ulogic;
     tlb_cmp_dbg_way1_entry_v                        : in  std_ulogic;
     tlb_cmp_dbg_way1_addr_match                     : in  std_ulogic;
     tlb_cmp_dbg_way1_pgsize_match                   : in  std_ulogic;
     tlb_cmp_dbg_way1_class_match                    : in  std_ulogic;
     tlb_cmp_dbg_way1_extclass_match                 : in  std_ulogic;
     tlb_cmp_dbg_way1_state_match                    : in  std_ulogic;
     tlb_cmp_dbg_way1_thdid_match                    : in  std_ulogic;
     tlb_cmp_dbg_way1_pid_match                      : in  std_ulogic;
     tlb_cmp_dbg_way1_lpid_match                     : in  std_ulogic;
     tlb_cmp_dbg_way1_ind_match                      : in  std_ulogic;
     tlb_cmp_dbg_way1_iprot_match                    : in  std_ulogic;
     tlb_cmp_dbg_way2_entry_v                        : in  std_ulogic;
     tlb_cmp_dbg_way2_addr_match                     : in  std_ulogic;
     tlb_cmp_dbg_way2_pgsize_match                   : in  std_ulogic;
     tlb_cmp_dbg_way2_class_match                    : in  std_ulogic;
     tlb_cmp_dbg_way2_extclass_match                 : in  std_ulogic;
     tlb_cmp_dbg_way2_state_match                    : in  std_ulogic;
     tlb_cmp_dbg_way2_thdid_match                    : in  std_ulogic;
     tlb_cmp_dbg_way2_pid_match                      : in  std_ulogic;
     tlb_cmp_dbg_way2_lpid_match                     : in  std_ulogic;
     tlb_cmp_dbg_way2_ind_match                      : in  std_ulogic;
     tlb_cmp_dbg_way2_iprot_match                    : in  std_ulogic;
     tlb_cmp_dbg_way3_entry_v                        : in  std_ulogic;
     tlb_cmp_dbg_way3_addr_match                     : in  std_ulogic;
     tlb_cmp_dbg_way3_pgsize_match                   : in  std_ulogic;
     tlb_cmp_dbg_way3_class_match                    : in  std_ulogic;
     tlb_cmp_dbg_way3_extclass_match                 : in  std_ulogic;
     tlb_cmp_dbg_way3_state_match                    : in  std_ulogic;
     tlb_cmp_dbg_way3_thdid_match                    : in  std_ulogic;
     tlb_cmp_dbg_way3_pid_match                      : in  std_ulogic;
     tlb_cmp_dbg_way3_lpid_match                     : in  std_ulogic;
     tlb_cmp_dbg_way3_ind_match                      : in  std_ulogic;
     tlb_cmp_dbg_way3_iprot_match                    : in  std_ulogic;

     ----------- lrat debug signals
     lrat_dbg_tag1_addr_enable    : in  std_ulogic;
     lrat_dbg_tag2_matchline_q    : in  std_ulogic_vector(0 to 7);     
     lrat_dbg_entry0_addr_match   : in  std_ulogic;  -- tag2
     lrat_dbg_entry0_lpid_match   : in  std_ulogic;
     lrat_dbg_entry0_entry_v      : in  std_ulogic;
     lrat_dbg_entry0_entry_x      : in  std_ulogic;
     lrat_dbg_entry0_size         : in  std_ulogic_vector(0 to 3);
     lrat_dbg_entry1_addr_match   : in  std_ulogic;  -- tag2
     lrat_dbg_entry1_lpid_match   : in  std_ulogic;
     lrat_dbg_entry1_entry_v      : in  std_ulogic;
     lrat_dbg_entry1_entry_x      : in  std_ulogic;
     lrat_dbg_entry1_size         : in  std_ulogic_vector(0 to 3);
     lrat_dbg_entry2_addr_match   : in  std_ulogic;  -- tag2
     lrat_dbg_entry2_lpid_match   : in  std_ulogic;
     lrat_dbg_entry2_entry_v      : in  std_ulogic;
     lrat_dbg_entry2_entry_x      : in  std_ulogic;
     lrat_dbg_entry2_size         : in  std_ulogic_vector(0 to 3);
     lrat_dbg_entry3_addr_match   : in  std_ulogic;  -- tag2
     lrat_dbg_entry3_lpid_match   : in  std_ulogic;
     lrat_dbg_entry3_entry_v      : in  std_ulogic;
     lrat_dbg_entry3_entry_x      : in  std_ulogic;
     lrat_dbg_entry3_size         : in  std_ulogic_vector(0 to 3);
     lrat_dbg_entry4_addr_match   : in  std_ulogic; -- tag2
     lrat_dbg_entry4_lpid_match   : in  std_ulogic;
     lrat_dbg_entry4_entry_v      : in  std_ulogic;
     lrat_dbg_entry4_entry_x      : in  std_ulogic;
     lrat_dbg_entry4_size         : in  std_ulogic_vector(0 to 3);
     lrat_dbg_entry5_addr_match   : in  std_ulogic; -- tag2
     lrat_dbg_entry5_lpid_match   : in  std_ulogic;
     lrat_dbg_entry5_entry_v      : in  std_ulogic;
     lrat_dbg_entry5_entry_x      : in  std_ulogic;
     lrat_dbg_entry5_size         : in  std_ulogic_vector(0 to 3);
     lrat_dbg_entry6_addr_match   : in  std_ulogic;  -- tag2
     lrat_dbg_entry6_lpid_match   : in  std_ulogic;
     lrat_dbg_entry6_entry_v      : in  std_ulogic;
     lrat_dbg_entry6_entry_x      : in  std_ulogic;
     lrat_dbg_entry6_size         : in  std_ulogic_vector(0 to 3);
     lrat_dbg_entry7_addr_match   : in  std_ulogic; -- tag2
     lrat_dbg_entry7_lpid_match   : in  std_ulogic;
     lrat_dbg_entry7_entry_v      : in  std_ulogic;
     lrat_dbg_entry7_entry_x      : in  std_ulogic;
     lrat_dbg_entry7_size         : in  std_ulogic_vector(0 to 3);
     
     ----------- mmq_htw debug signals
     htw_dbg_seq_idle                 : in  std_ulogic;  
     htw_dbg_pte0_seq_idle            : in  std_ulogic;  
     htw_dbg_pte1_seq_idle            : in  std_ulogic;  
     htw_dbg_seq_q                    : in std_ulogic_vector(0 to 1);
     htw_dbg_inptr_q                  : in std_ulogic_vector(0 to 1);
     htw_dbg_pte0_seq_q               : in std_ulogic_vector(0 to 2);
     htw_dbg_pte1_seq_q               : in std_ulogic_vector(0 to 2);
     htw_dbg_ptereload_ptr_q          : in std_ulogic;
     htw_dbg_lsuptr_q                 : in std_ulogic_vector(0 to 1);
     htw_dbg_req_valid_q              : in std_ulogic_vector(0 to 3);
     htw_dbg_resv_valid_vec           : in std_ulogic_vector(0 to 3);
     htw_dbg_tag4_clr_resv_q          : in std_ulogic_vector(0 to 3);
     htw_dbg_tag4_clr_resv_terms      : in std_ulogic_vector(0 to 3);  -- tag4, threadwise condensed into to  tlbivax, tlbilx, tlbwe, ptereload
     htw_dbg_pte0_score_ptr_q         : in std_ulogic_vector(0 to 1);
     htw_dbg_pte0_score_cl_offset_q   : in std_ulogic_vector(58 to 60);
     htw_dbg_pte0_score_error_q       : in std_ulogic_vector(0 to 2);
     htw_dbg_pte0_score_qwbeat_q      : in std_ulogic_vector(0 to 3); -- 4 beats of data per CL
     htw_dbg_pte0_score_pending_q     : in std_ulogic;
     htw_dbg_pte0_score_ibit_q        : in std_ulogic;
     htw_dbg_pte0_score_dataval_q     : in std_ulogic;
     htw_dbg_pte0_reld_for_me_tm1     : in std_ulogic;
     htw_dbg_pte1_score_ptr_q         : in std_ulogic_vector(0 to 1);
     htw_dbg_pte1_score_cl_offset_q   : in std_ulogic_vector(58 to 60);
     htw_dbg_pte1_score_error_q       : in std_ulogic_vector(0 to 2);
     htw_dbg_pte1_score_qwbeat_q      : in std_ulogic_vector(0 to 3); -- 4 beats of data per CL
     htw_dbg_pte1_score_pending_q     : in std_ulogic;
     htw_dbg_pte1_score_ibit_q        : in std_ulogic;
     htw_dbg_pte1_score_dataval_q     : in std_ulogic;
     htw_dbg_pte1_reld_for_me_tm1     : in std_ulogic;

     ----------- lsu debug signals
     mm_xu_lsu_req              : in     std_ulogic_vector(0 to thdid_width-1);    
     -- 0=tlbivax_op, 1=tlbi_complete, 2=mmu read with core_tag=01100, 3=mmu read with core_tag=01101
     mm_xu_lsu_ttype            : in     std_ulogic_vector(0 to 1); 
     mm_xu_lsu_wimge            : in     std_ulogic_vector(0 to 4);
     mm_xu_lsu_u                : in     std_ulogic_vector(0 to 3);    
     mm_xu_lsu_addr             : in     std_ulogic_vector(22 to 63);
     mm_xu_lsu_lpid             : in  std_ulogic_vector(0 to 7); -- tlbivax data
     mm_xu_lsu_gs               : in  std_ulogic;  -- tlbivax data
     mm_xu_lsu_ind              : in  std_ulogic;  -- tlbivax data
     mm_xu_lsu_lbit             : in  std_ulogic;  -- -- tlbivax data, "L" bit, for large vs. small
     xu_mm_lsu_token            : in  std_ulogic;
     
     
     ----------- misc top level debug signals
     tlb_mas_tlbre            : in std_ulogic;  
     tlb_mas_tlbsx_hit        : in std_ulogic;  
     tlb_mas_tlbsx_miss       : in std_ulogic;  
     tlb_mas_dtlb_error       : in std_ulogic; 
     tlb_mas_itlb_error       : in std_ulogic; 
     tlb_mas_thdid            : in std_ulogic_vector(0 to 3); 
     lrat_mas_tlbre           : in std_ulogic;  
     lrat_mas_tlbsx_hit       : in std_ulogic;  
     lrat_mas_tlbsx_miss      : in std_ulogic;  
     lrat_mas_thdid           : in std_ulogic_vector(0 to 3);
     lrat_tag3_hit_status     : in std_ulogic_vector(0 to 3); -- val,hit,multihit,inval_pgsize
     lrat_tag3_hit_entry      : in std_ulogic_vector(0 to 2);

     tlb_seq_ierat_req               : in  std_ulogic;
     tlb_seq_derat_req               : in  std_ulogic;
     mm_xu_hold_req                  : in std_ulogic_vector(0 to 3);
     xu_mm_hold_ack                  : in std_ulogic_vector(0 to 3);
     mm_xu_hold_done                 : in std_ulogic_vector(0 to 3);
     mmucsr0_tlb0fi                  : in std_ulogic;
     tlbwe_back_inv_valid            : in std_ulogic;
     tlbwe_back_inv_attr             : in std_ulogic_vector(18 to 19);
     xu_mm_lmq_stq_empty             : in std_ulogic;
     iu_mm_lmq_empty                 : in std_ulogic;
     mm_xu_eratmiss_done             : in std_ulogic_vector(0 to 3);
     mm_iu_barrier_done              : in std_ulogic_vector(0 to 3);
     mm_xu_ex3_flush_req             : in std_ulogic_vector(0 to 3);
     mm_xu_illeg_instr               : in std_ulogic_vector(0 to 3);
     lrat_tag4_hit_status            : in std_ulogic_vector(0 to 3);
     lrat_tag4_hit_entry             : in std_ulogic_vector(0 to 2);
     mm_xu_cr0_eq                    : in std_ulogic_vector(0 to 3); -- for record forms
     mm_xu_cr0_eq_valid              : in std_ulogic_vector(0 to 3);  -- for record forms
     tlb_htw_req_valid               : in std_ulogic;
     htw_lsu_req_valid               : in std_ulogic;
     htw_dbg_lsu_thdid               : in std_ulogic_vector(0 to 1);
     htw_lsu_ttype                   : in std_ulogic_vector(0 to 1);
     htw_lsu_addr                    : in std_ulogic_vector(22 to 63);
     ptereload_req_taken             : in std_ulogic;
     ptereload_req_pte               : in std_ulogic_vector(0 to 63)  -- pte entry
     


);

  -- synopsys translate_off


  -- synopsys translate_on
end mmq_dbg;


architecture mmq_dbg of mmq_dbg is

constant tagpos_epn      : natural  := 0;
constant tagpos_pid      : natural  := 52; -- 14 bits
constant tagpos_is       : natural  := 66; 
constant tagpos_class    : natural  := 68;
constant tagpos_state    : natural  := 70; -- state: 0:pr 1:gs 2:as 3:cm
constant tagpos_thdid    : natural  := 74; 
constant tagpos_size     : natural  := 78; 
constant tagpos_type     : natural  := 82; -- derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
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
constant waypos_tid      : natural  := 144; -- 14 bits

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
constant eratpos_rsv      : natural  := 102;
constant eratpos_wlc      : natural  := 103;
constant eratpos_resvattr : natural  := 105;
constant eratpos_vf       : natural  := 106;
constant eratpos_ubits    : natural  := 107;
constant eratpos_wimge    : natural  := 111;
constant eratpos_usxwr    : natural  := 116;
constant eratpos_gs       : natural  := 122;
constant eratpos_ts       : natural  := 123;
constant eratpos_tid      : natural  := 124;  -- 8 bits

signal pc_mm_trace_bus_enable_q                     : std_ulogic;                       -- input=>pc_mm_trace_bus_enable, sleep=>Y,   needs_sreset=>0
signal pc_mm_debug_mux1_ctrls_q                     : std_ulogic_vector(0 to 15);    -- input=>pc_mm_debug_mux1_ctrls,  act=>pc_mm_trace_bus_enable_q, sleep=>Y, needs_sreset=>0
signal pc_mm_debug_mux1_ctrls_loc_d, pc_mm_debug_mux1_ctrls_loc_q   : std_ulogic_vector(0 to 15);    
signal trigger_data_out_d, trigger_data_out_q       : std_ulogic_vector(0 to 11);
signal trace_data_out_d, trace_data_out_q           : std_ulogic_vector(0 to 87);
signal trace_data_out_int_q                         : std_ulogic_vector(0 to 7);
signal debug_d,  debug_q                            : std_ulogic_vector(0 to 371);     -- act=>pc_mm_trace_bus_enable_q,  sleep=>Y,  needs_sreset=>0, scan=>N
signal trigger_d,  trigger_q                        : std_ulogic_vector(0 to 47);      -- act=>pc_mm_trace_bus_enable_q,  sleep=>Y,  needs_sreset=>0, scan=>N
signal debug_bus_in_q               : std_ulogic_vector(0 to 87);
signal trace_triggers_in_q          : std_ulogic_vector(0 to 11);

constant trace_bus_enable_offset   : integer := 0;
constant debug_mux1_ctrls_offset   : integer := trace_bus_enable_offset        + 1;
constant debug_mux1_ctrls_loc_offset  : integer := debug_mux1_ctrls_offset         + pc_mm_debug_mux1_ctrls_q'length;
constant trigger_data_out_offset   : natural := debug_mux1_ctrls_loc_offset         + pc_mm_debug_mux1_ctrls_loc_q'length;
constant trace_data_out_offset     : natural := trigger_data_out_offset        + trigger_data_out_q'length;
constant trace_data_out_int_offset : natural := trace_data_out_offset          + trace_data_out_q'length;
constant scan_right                : natural := trace_data_out_int_offset      + trace_data_out_int_q'length-1;

signal dbg_group0        : std_ulogic_vector(0 to 87);
signal dbg_group1        : std_ulogic_vector(0 to 87);
signal dbg_group2        : std_ulogic_vector(0 to 87);
signal dbg_group3        : std_ulogic_vector(0 to 87);
signal dbg_group4        : std_ulogic_vector(0 to 87);
signal dbg_group5        : std_ulogic_vector(0 to 87);
signal dbg_group6        : std_ulogic_vector(0 to 87);
signal dbg_group7        : std_ulogic_vector(0 to 87);
signal dbg_group8        : std_ulogic_vector(0 to 87);
signal dbg_group9        : std_ulogic_vector(0 to 87);

signal dbg_group10a      : std_ulogic_vector(0 to 87);
signal dbg_group11a      : std_ulogic_vector(0 to 87);
signal dbg_group12a      : std_ulogic_vector(0 to 87);
signal dbg_group13a      : std_ulogic_vector(0 to 87);
signal dbg_group14a      : std_ulogic_vector(0 to 87);
signal dbg_group15a      : std_ulogic_vector(0 to 87);
signal dbg_group10b      : std_ulogic_vector(0 to 87);
signal dbg_group11b      : std_ulogic_vector(0 to 87);
signal dbg_group12b      : std_ulogic_vector(0 to 87);
signal dbg_group13b      : std_ulogic_vector(0 to 87);
signal dbg_group14b      : std_ulogic_vector(0 to 87);
signal dbg_group15b      : std_ulogic_vector(0 to 87);
signal dbg_group10       : std_ulogic_vector(0 to 87);
signal dbg_group11       : std_ulogic_vector(0 to 87);
signal dbg_group12       : std_ulogic_vector(0 to 87);
signal dbg_group13       : std_ulogic_vector(0 to 87);
signal dbg_group14       : std_ulogic_vector(0 to 87);
signal dbg_group15       : std_ulogic_vector(0 to 87);

constant group12_offset  : natural := 68;
constant group13_offset  : natural := 112;

signal trg_group0       : std_ulogic_vector(0 to 11);
signal trg_group1       : std_ulogic_vector(0 to 11);
signal trg_group2       : std_ulogic_vector(0 to 11);
signal trg_group3a      : std_ulogic_vector(0 to 11);
signal trg_group3b      : std_ulogic_vector(0 to 11);
signal trg_group3       : std_ulogic_vector(0 to 11);

signal dbg_group0a         : std_ulogic_vector(24 to 55);

signal tlb_ctl_dbg_tag1_valid   : std_ulogic;
signal tlb_ctl_dbg_tag1_thdid   : std_ulogic_vector(0 to 1);
signal tlb_ctl_dbg_tag1_type    : std_ulogic_vector(0 to 2);
signal tlb_ctl_dbg_tag1_wq      : std_ulogic_vector(0 to 1);
signal tlb_ctl_dbg_tag1_gs      : std_ulogic;  
signal tlb_ctl_dbg_tag1_pr      : std_ulogic;  
signal tlb_ctl_dbg_tag1_atsel   : std_ulogic;  
signal tlb_cmp_dbg_tag4_thdid   : std_ulogic_vector(0 to 1); -- encoded
signal tlb_cmp_dbg_tag4_type    : std_ulogic_vector(0 to 2); -- encoded
signal tlb_cmp_dbg_tag4_valid   : std_ulogic;
signal tlb_cmp_dbg_tag5_wayhit          : std_ulogic_vector(0 to tlb_ways);
signal tlb_cmp_dbg_tag5_thdid           : std_ulogic_vector(0 to 1); -- encoded
signal tlb_cmp_dbg_tag5_type            : std_ulogic_vector(0 to 2); -- encoded
signal tlb_cmp_dbg_tag5_class           : std_ulogic_vector(0 to 1);  -- what kind of derat is it?
signal tlb_cmp_dbg_tag5_iorderat_rel_val : std_ulogic;  -- i or d
signal tlb_cmp_dbg_tag5_iorderat_rel_hit : std_ulogic;  -- i or d
signal tlb_cmp_dbg_tag5_way              : std_ulogic_vector(0 to 167);
signal tlb_cmp_dbg_tag5_lru_dataout      : std_ulogic_vector(0 to 11); 


signal unused_dc  :  std_ulogic_vector(0 to 11);  
-- synopsys translate_off
-- synopsys translate_on

-- Pervasive
signal pc_func_slp_sl_thold_1    : std_ulogic;
signal pc_func_slp_sl_thold_0    : std_ulogic;
signal pc_func_slp_sl_thold_0_b  : std_ulogic;
signal pc_func_slp_sl_force      : std_ulogic;
signal pc_func_slp_nsl_thold_1    : std_ulogic;
signal pc_func_slp_nsl_thold_0    : std_ulogic;
signal pc_func_slp_nsl_thold_0_b  : std_ulogic;
signal pc_func_slp_nsl_force      : std_ulogic;
signal pc_sg_1               : std_ulogic;
signal pc_sg_0               : std_ulogic;
signal pc_fce_1               : std_ulogic;
signal pc_fce_0               : std_ulogic;

signal siv, sov                      : std_ulogic_vector(0 to scan_right);

signal tidn                     : std_ulogic;
signal tiup                     : std_ulogic;



begin

-----------------------------------------------------------------------
-- Logic
-----------------------------------------------------------------------

tidn <= '0';
tiup <= '1';

pc_mm_debug_mux1_ctrls_loc_d <= pc_mm_debug_mux1_ctrls_q; -- local timing latches

 
-----------------------------------------------------------------------
-- debug input signals from various logic entities
-----------------------------------------------------------------------
debug_d(12)         <= tlb_ctl_dbg_tag0_valid;
debug_d(13 to 14)   <= tlb_ctl_dbg_tag0_thdid(0 to 1);
debug_d(15 to 17)   <= tlb_ctl_dbg_tag0_type(0 to 2);
debug_d(18 to 19)   <= tlb_ctl_dbg_tag0_wq(0 to 1);
debug_d(20)         <= tlb_ctl_dbg_tag0_gs;  
debug_d(21)         <= tlb_ctl_dbg_tag0_pr;  
debug_d(22)         <= tlb_ctl_dbg_tag0_atsel;  
debug_d(23)    <= '0';

tlb_ctl_dbg_tag1_valid          <= debug_q(12);
tlb_ctl_dbg_tag1_thdid(0 to 1)  <= debug_q(13 to 14);
tlb_ctl_dbg_tag1_type(0 to 2)   <= debug_q(15 to 17);
tlb_ctl_dbg_tag1_wq(0 to 1)     <= debug_q(18 to 19);
tlb_ctl_dbg_tag1_gs             <= debug_q(20);  
tlb_ctl_dbg_tag1_pr             <= debug_q(21);  
tlb_ctl_dbg_tag1_atsel          <= debug_q(22);  



-- tlb_low_data
-- [0:51] - EPN
-- [52:55] - SIZE (4b)
-- [56:59] - ThdID
-- [60:61] - Class
-- [62] - ExtClass
-- [63] - TID_NZ
-- [64:65] - reserved (2b)
-- [66:73] - 8b for LPID
-- [74:83] - parity 10bits
debug_d(192 to 275) <= TLB_CMP_DBG_TAG4_WAY(0 to 83); 
tlb_cmp_dbg_tag5_way(0 to 83) <= debug_q(192 to 275); 

-- tlb_high_data
-- [84]      - [0]     - X-bit
-- [85:87]   - [1:3]   - reserved (3b)
-- [88:117]  - [4:33]  - RPN (30b)
-- [118:119] - [34:35] - R,C
-- [120:121] - [36:37] - WLC (2b)
-- [122]     - [38]    - ResvAttr
-- [123]     - [39]    - VF
-- [124]     - [40]    - IND
-- [125:128] - [41:44] - U0-U3
-- [129:133] - [45:49] - WIMGE
-- [134:135] - [50:51] - UX,SX
-- [136:137] - [52:53] - UW,SW
-- [138:139] - [54:55] - UR,SR
-- [140]     - [56] - GS
-- [141]     - [57] - TS
-- [142:143] - [58:59] - reserved (2b)
-- [144:149] - [60:65] - 6b TID msbs
-- [150:157] - [66:73] - 8b TID lsbs
-- [158:167] - [74:83] - parity 10bits
debug_d(276 to 359) <= TLB_CMP_DBG_TAG4_WAY(84 to 167); 
tlb_cmp_dbg_tag5_way(84 to 167) <= debug_q(276 to 359); 

-- lru data format
--  [0:3] - valid(0:3)
--  [4:6] - LRU
--  [7] - parity
--  [8:11] - iprot(0:3)
--  [12:14] - reserved
--  [15] - parity
debug_d(360 to 371) <= tlb_cmp_dbg_tag4_lru_dataout_q(0 to 11); 
tlb_cmp_dbg_tag5_lru_dataout(0 to 11) <= debug_q(360 to 371); 


trigger_d(0 to 11)  <= (others => '0');
trigger_d(12 to 23) <= (others => '0');
trigger_d(24 to 35) <= (others => '0');
trigger_d(36 to 47) <= (others => '0');
                         

--group0   (slowspr interface)
dbg_group0(0)     <= spr_dbg_slowspr_val_int;  -- spr_int phase
dbg_group0(1)     <= spr_dbg_slowspr_rw_int;
dbg_group0(2 to 3)   <= spr_dbg_slowspr_etid_int;
dbg_group0(4 to 13)  <= spr_dbg_slowspr_addr_int;
dbg_group0(14)    <= spr_dbg_slowspr_done_out;  -- spr_out phase
dbg_group0(15)    <= spr_dbg_match_any_mmu;   -- spr_int phase
dbg_group0(16)    <= spr_dbg_match_any_mas;
dbg_group0(17)    <= spr_dbg_match_pid;
dbg_group0(18)    <= spr_dbg_match_lpidr;
dbg_group0(19)    <= spr_dbg_match_mas2; 
dbg_group0(20)    <= spr_dbg_match_mas01_64b;  
dbg_group0(21)    <= spr_dbg_match_mas56_64b;  
dbg_group0(22)    <= spr_dbg_match_mas73_64b;  
dbg_group0(23)    <= spr_dbg_match_mas81_64b;  

-- alternate bit muxes when 64b decodes 19:23=00000
dbg_group0a(24)    <= spr_dbg_match_mmucr0;
dbg_group0a(25)    <= spr_dbg_match_mmucr1;
dbg_group0a(26)    <= spr_dbg_match_mmucr2;
dbg_group0a(27)    <= spr_dbg_match_mmucr3;
dbg_group0a(28)    <= spr_dbg_match_mmucsr0;
dbg_group0a(29)    <= spr_dbg_match_mmucfg;
dbg_group0a(30)    <= spr_dbg_match_tlb0cfg;
dbg_group0a(31)    <= spr_dbg_match_tlb0ps;
dbg_group0a(32)    <= spr_dbg_match_lratcfg;
dbg_group0a(33)    <= spr_dbg_match_lratps;  
dbg_group0a(34)    <= spr_dbg_match_eptcfg;  
dbg_group0a(35)    <= spr_dbg_match_lper;
dbg_group0a(36)    <= spr_dbg_match_lperu;
dbg_group0a(37)    <= spr_dbg_match_mas0; 
dbg_group0a(38)    <= spr_dbg_match_mas1;  
dbg_group0a(39)    <= spr_dbg_match_mas2u; 
dbg_group0a(40)    <= spr_dbg_match_mas3;  
dbg_group0a(41)    <= spr_dbg_match_mas4;  
dbg_group0a(42)    <= spr_dbg_match_mas5;  
dbg_group0a(43)    <= spr_dbg_match_mas6;  
dbg_group0a(44)    <= spr_dbg_match_mas7;  
dbg_group0a(45)    <= spr_dbg_match_mas8;  
dbg_group0a(46)    <= tlb_mas_tlbre;  
dbg_group0a(47)    <= tlb_mas_tlbsx_hit;  
dbg_group0a(48)    <= tlb_mas_tlbsx_miss;  
dbg_group0a(49)    <= tlb_mas_dtlb_error; 
dbg_group0a(50)    <= tlb_mas_itlb_error; 
dbg_group0a(51)    <= tlb_mas_thdid(2) or tlb_mas_thdid(3); -- encoded
dbg_group0a(52)    <= tlb_mas_thdid(1) or tlb_mas_thdid(3); -- encoded
dbg_group0a(53)    <= lrat_mas_tlbre;  
dbg_group0a(54)    <= lrat_mas_thdid(2) or lrat_mas_thdid(3); -- encoded
dbg_group0a(55)    <= lrat_mas_thdid(1) or lrat_mas_thdid(3); -- encoded
-- alternate bit muxes when 64b decodes 19:23/=00000
dbg_group0(24 to 55) <= ((24 to 55 => spr_dbg_match_64b) and spr_dbg_slowspr_data_out(0 to 31)) or
                        ((24 to 55 => not(spr_dbg_match_64b)) and dbg_group0a(24 to 55));
dbg_group0(56 to 87) <= spr_dbg_slowspr_data_out(32 to 63);


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

--group1   (invalidate, local generation)
dbg_group1(0 to 4) <= inval_dbg_seq_q(0 to 4);
dbg_group1(5)      <= inval_dbg_ex6_valid;
dbg_group1(6 to 7) <= inval_dbg_ex6_thdid(0 to 1);  -- encoded
dbg_group1(8 to 9) <= inval_dbg_ex6_ttype(1 to 2);  -- encoded
dbg_group1(10)     <= htw_lsu_req_valid;
dbg_group1(11)     <= mmucsr0_tlb0fi;
dbg_group1(12)     <= tlbwe_back_inv_valid;
dbg_group1(13)     <= inval_dbg_snoop_forme;
dbg_group1(14)     <= inval_dbg_an_ac_back_inv_q(4); -- L bit
dbg_group1(15)     <= inval_dbg_an_ac_back_inv_q(7); -- local bit
dbg_group1(16 to 50) <= inval_dbg_snoop_attr_q(0 to 34);
dbg_group1(51 to 52) <= inval_dbg_snoop_attr_tlb_spec_q(18 to 19);
dbg_group1(53 to 87) <= inval_dbg_snoop_vpn_q(17 to 51);


--group2   (invalidate, bus snoops)
dbg_group2(0 to 4)  <= inval_dbg_seq_q(0 to 4);
dbg_group2(5)        <= inval_dbg_snoop_forme;
dbg_group2(6)        <= inval_dbg_snoop_local_reject;
dbg_group2(7 to 13)  <= inval_dbg_an_ac_back_inv_q(2 to 8);  -- 2=valid b, 3=target b, 4=L, 5=GS, 6=IND, 7=local, 8=reject
dbg_group2(14 to 21) <= inval_dbg_an_ac_back_inv_lpar_id_q(0 to 7);
dbg_group2(22 to 63) <= inval_dbg_an_ac_back_inv_addr_q(22 to 63);
dbg_group2(64 to 66) <= inval_dbg_snoop_valid_q(0 to 2);
dbg_group2(67 to 87) <= inval_dbg_snoop_attr_q(0 to 19) & inval_dbg_snoop_attr_q(34);


--group3   (lsu interface)
dbg_group3(0 to 4)   <= inval_dbg_seq_q(0 to 4);
dbg_group3(5)        <= inval_dbg_ex6_valid;
dbg_group3(6 to 7)   <= inval_dbg_ex6_thdid(0 to 1);  -- encoded
dbg_group3(8 to 9)   <= inval_dbg_ex6_ttype(1 to 2);  -- encoded
dbg_group3(10)        <= inval_dbg_snoop_forme;
dbg_group3(11)        <= inval_dbg_an_ac_back_inv_q(7);  -- 2=valid b, 3=target b, 4=L, 5=GS, 6=IND, 7=local, 8=reject
dbg_group3(12)        <= xu_mm_lmq_stq_empty;
dbg_group3(13)        <= iu_mm_lmq_empty;
dbg_group3(14 to 15)  <= htw_dbg_seq_q(0 to 1);
dbg_group3(16)         <= htw_lsu_req_valid;
dbg_group3(17 to 18)  <= htw_dbg_lsu_thdid(0 to 1);
dbg_group3(19 to 20)  <= htw_lsu_ttype(0 to 1);
dbg_group3(21)         <= xu_mm_lsu_token;
dbg_group3(22)         <= inval_dbg_lsu_tokens_q(1);
dbg_group3(23)         <= or_reduce(mm_xu_lsu_req);    
dbg_group3(24 to 25)  <= mm_xu_lsu_ttype;  -- 0=tlbivax_op L=0, 1=tlbi_complete, 2=mmu read with core_tag=01100, 3=mmu read with core_tag=01101
dbg_group3(26 to 30)  <= mm_xu_lsu_wimge;
dbg_group3(31)        <= mm_xu_lsu_ind;    -- tlbivax sec enc data
dbg_group3(32)        <= mm_xu_lsu_gs;     -- tlbivax sec enc data
dbg_group3(33)        <= mm_xu_lsu_lbit;  -- tlbivax sec enc data, "L" bit, for large vs. small
dbg_group3(34 to 37) <= mm_xu_lsu_u;    
dbg_group3(38 to 45) <= mm_xu_lsu_lpid;  -- tlbivax lpar id data
dbg_group3(46 to 87) <= mm_xu_lsu_addr(22 to 63);


tlb_cmp_dbg_tag5_iorderat_rel_val <= or_reduce(tlb_cmp_dbg_tag5_erat_rel_val(0 to 3) or tlb_cmp_dbg_tag5_erat_rel_val(5 to 8));  -- i or d
tlb_cmp_dbg_tag5_iorderat_rel_hit <= tlb_cmp_dbg_tag5_erat_rel_val(4) or tlb_cmp_dbg_tag5_erat_rel_val(9);  -- i or d
 
--group4   (sequencers, the big picture)
dbg_group4(0 to 5)   <= tlb_ctl_dbg_seq_q(0 to 5);  -- tlb_seq_q
dbg_group4(6 to 7)   <= tlb_ctl_dbg_tag0_thdid(0 to 1); -- encoded
dbg_group4(8 to 10)  <= tlb_ctl_dbg_tag0_type(0 to 2); -- encoded
dbg_group4(11)       <= tlb_ctl_dbg_any_tag_flush_sig;
dbg_group4(12 to 15) <= tlb_cmp_dbg_tag4_wayhit(0 to 3);
dbg_group4(16 to 19) <= mm_xu_eratmiss_done(0 to 3);
dbg_group4(20 to 23) <= mm_iu_barrier_done(0 to 3);
dbg_group4(24 to 27) <= mm_xu_ex3_flush_req(0 to 3);
dbg_group4(28)       <= tlb_cmp_dbg_tag5_iorderat_rel_val;  -- i or d
dbg_group4(29)       <= tlb_cmp_dbg_tag5_iorderat_rel_hit;  -- i or d
dbg_group4(30 to 31) <= htw_dbg_seq_q(0 to 1);
dbg_group4(32 to 34) <= htw_dbg_pte0_seq_q(0 to 2);
dbg_group4(35 to 37) <= htw_dbg_pte1_seq_q(0 to 2);
dbg_group4(38 to 42) <= inval_dbg_seq_q(0 to 4);
dbg_group4(43)       <= mmucsr0_tlb0fi;
dbg_group4(44)       <= inval_dbg_ex6_valid;
dbg_group4(45 to 46) <= inval_dbg_ex6_thdid(0 to 1);  -- encoded
dbg_group4(47 to 49) <= inval_dbg_ex6_ttype(0 to 2);  -- encoded  tlbilx & tlbivax & eratilx & erativax, csync, isync
dbg_group4(50)       <= inval_dbg_snoop_forme;
dbg_group4(51 to 57) <= inval_dbg_an_ac_back_inv_q(2 to 8);  -- 2=valid b, 3=target b, 4=L, 5=GS, 6=IND, 7=local, 8=reject
dbg_group4(58)       <= xu_mm_lmq_stq_empty;
dbg_group4(59)       <= iu_mm_lmq_empty;
dbg_group4(60 to 63) <= mm_xu_hold_req(0 to 3);
dbg_group4(64 to 67) <= xu_mm_hold_ack(0 to 3);
dbg_group4(68 to 71) <= mm_xu_hold_done(0 to 3);
dbg_group4(72 to 74) <= inval_dbg_snoop_valid_q(0 to 2); 
dbg_group4(75 to 77) <= inval_dbg_snoop_ack_q(0 to 2); 
dbg_group4(78)       <= or_reduce(mm_xu_lsu_req);
dbg_group4(79 to 80) <= mm_xu_lsu_ttype;  -- 0=tlbivax_op L=0, 1=tlbi_complete, 2=mmu read with core_tag=01100, 3=mmu read with core_tag=01101
dbg_group4(81)       <= or_reduce(mm_xu_illeg_instr);
dbg_group4(82 to 85) <= tlb_cmp_dbg_tag5_except_type_q(0 to 3);   -- tag5 except valid/type, (hv_priv | lrat_miss | pt_fault | pt_inelig)
dbg_group4(86 to 87) <= tlb_cmp_dbg_tag5_except_thdid_q(0 to 1);  -- tag5 encoded thdid

--group5 (tlb_req)
dbg_group5(0)        <=  tlb_req_dbg_ierat_iu5_valid_q;
dbg_group5(1 to 2)   <=  tlb_req_dbg_ierat_iu5_thdid(0 to 1);  -- encoded
dbg_group5(3 to 6)   <=  tlb_req_dbg_ierat_iu5_state_q(0 to 3);
dbg_group5(7)        <=  tlb_seq_ierat_req;
dbg_group5(8 to 9)   <=  tlb_req_dbg_ierat_inptr_q(0 to 1);
dbg_group5(10 to 11) <=  tlb_req_dbg_ierat_outptr_q(0 to 1);
dbg_group5(12 to 15) <=  tlb_req_dbg_ierat_req_valid_q(0 to 3);
dbg_group5(16 to 19) <=  tlb_req_dbg_ierat_req_nonspec_q(0 to 3);
dbg_group5(20 to 27) <=  tlb_req_dbg_ierat_req_thdid(0 to 7); -- encoded
dbg_group5(28 to 31) <=  tlb_req_dbg_ierat_req_dup_q(0 to 3);
dbg_group5(32)       <=  tlb_req_dbg_derat_ex6_valid_q;
dbg_group5(33 to 34) <=  tlb_req_dbg_derat_ex6_thdid(0 to 1); -- encoded
dbg_group5(35 to 38) <=  tlb_req_dbg_derat_ex6_state_q(0 to 3);
dbg_group5(39)       <=  tlb_seq_derat_req;
dbg_group5(40 to 41) <=  tlb_req_dbg_derat_inptr_q(0 to 1);
dbg_group5(42 to 43) <=  tlb_req_dbg_derat_outptr_q(0 to 1);
dbg_group5(44 to 47) <=  tlb_req_dbg_derat_req_valid_q(0 to 3);
dbg_group5(48 to 55) <=  tlb_req_dbg_derat_req_thdid(0 to 7); -- encoded
dbg_group5(56 to 63) <=  tlb_req_dbg_derat_req_ttype_q(0 to 7);
dbg_group5(64 to 67) <=  tlb_req_dbg_derat_req_dup_q(0 to 3);
dbg_group5(68 to 87) <=  tlb_cmp_dbg_erat_dup_q(0 to 19);

     -- unused tag bits for certain ops are re-purposed as below:
     --  unused tagpos_is def is mas1_v, mas1_iprot for tlbwe, and is pte.valid & 0 for ptereloads
     --  unused tagpos_pt, tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
     --  unused tagpos_atsel | tagpos_esel used as indirect entry's thdid to update tlb_entry.thdid for ptereloads
     --  unused tagpos_wq used as htw reserv write enab & dup bits (set in htw) for ptereloads
     --  unused esel for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number (1 thru 5)
     --  unused "is" for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number msb (9 thru 13, or 17 thru 21)
     --  unused HES bit for snoops is used as mmucsr0.tlb0fi full invalidate of all non-protected entries

-- some encoding of debug sigs
 -- ttype:  derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
tlb_cmp_dbg_tag4_valid   <= or_reduce(tlb_cmp_dbg_tag4(tagpos_thdid to tagpos_thdid+3));

tlb_cmp_dbg_tag4_thdid(0)   <= (tlb_cmp_dbg_tag4(tagpos_thdid+2) or tlb_cmp_dbg_tag4(tagpos_thdid+3));  -- encoded
tlb_cmp_dbg_tag4_thdid(1)   <= (tlb_cmp_dbg_tag4(tagpos_thdid+1) or tlb_cmp_dbg_tag4(tagpos_thdid+3));  -- encoded

tlb_cmp_dbg_tag4_type(0)   <= (tlb_cmp_dbg_tag4(tagpos_type_snoop) or tlb_cmp_dbg_tag4(tagpos_type_tlbre) or 
                                tlb_cmp_dbg_tag4(tagpos_type_tlbwe) or tlb_cmp_dbg_tag4(tagpos_type_ptereload));  -- encoded
tlb_cmp_dbg_tag4_type(1)   <= (tlb_cmp_dbg_tag4(tagpos_type_tlbsx) or tlb_cmp_dbg_tag4(tagpos_type_tlbsrx) or 
                                tlb_cmp_dbg_tag4(tagpos_type_tlbwe) or tlb_cmp_dbg_tag4(tagpos_type_ptereload));  -- encoded
tlb_cmp_dbg_tag4_type(2)   <= (tlb_cmp_dbg_tag4(tagpos_type_ierat) or tlb_cmp_dbg_tag4(tagpos_type_tlbsrx) or 
                                tlb_cmp_dbg_tag4(tagpos_type_tlbre) or tlb_cmp_dbg_tag4(tagpos_type_ptereload));  -- encoded

--group6   (general erat and search compare values, truncated epn)
dbg_group6(0)         <= tlb_cmp_dbg_tag4_valid;  -- or_reduce of thdid;
dbg_group6(1 to 2)   <= tlb_cmp_dbg_tag4_thdid(0 to 1);  -- encoded
dbg_group6(3 to 5)   <= tlb_cmp_dbg_tag4_type(0 to 2);  -- encoded
dbg_group6(6 to 7)   <= tlb_cmp_dbg_tag4(tagpos_class to tagpos_class+1);
dbg_group6(8 to 9)   <= tlb_cmp_dbg_tag4(tagpos_is to tagpos_is+1);
dbg_group6(10 to 12) <= tlb_cmp_dbg_tag4(tagpos_esel to tagpos_esel+2);
dbg_group6(13)       <= tlb_cmp_dbg_tag4(tagpos_cm);
dbg_group6(14)       <= tlb_cmp_dbg_tag4(tagpos_pr);
dbg_group6(15)       <= tlb_cmp_dbg_tag4(tagpos_ind);
dbg_group6(16)       <= tlb_cmp_dbg_tag4(tagpos_endflag);
dbg_group6(17 to 23) <= tlb_cmp_dbg_addr4(0 to 6);
dbg_group6(24 to 27) <= tlb_cmp_dbg_tag4_wayhit(0 to tlb_ways-1);
dbg_group6(28)        <= tlb_cmp_dbg_tag4(tagpos_gs);
dbg_group6(29 to 36) <= tlb_cmp_dbg_tag4(tagpos_lpid to tagpos_lpid+7);
dbg_group6(37)       <= tlb_cmp_dbg_tag4(tagpos_as);
dbg_group6(38 to 51) <= tlb_cmp_dbg_tag4(tagpos_pid to tagpos_pid+13);
dbg_group6(52 to 87) <= tlb_cmp_dbg_tag4(tagpos_epn+16 to tagpos_epn+51);



--group7 (detailed compare/match)
dbg_group7(0)         <= tlb_cmp_dbg_tag4_valid;
dbg_group7(1 to 2)   <= tlb_cmp_dbg_tag4_thdid(0 to 1);
dbg_group7(3 to 5)   <= tlb_cmp_dbg_tag4_type(0 to 2);
dbg_group7(6 to 7)   <= tlb_cmp_dbg_tag4(tagpos_is to tagpos_is+1);
dbg_group7(8 to 9)   <= tlb_cmp_dbg_tag4(tagpos_class to tagpos_class+1);
dbg_group7(10 to 12) <= tlb_cmp_dbg_tag4(tagpos_esel to tagpos_esel+2);
dbg_group7(13 to 19) <= tlb_cmp_dbg_addr4(0 to 6);
dbg_group7(20 to 23) <= tlb_cmp_dbg_tag4_wayhit(0 to 3);

debug_d(24 to 32) <= tlb_cmp_dbg_addr_enable(0 to 8);  -- these are tag3 versions coming in
debug_d(33)        <= tlb_cmp_dbg_pgsize_enable;
debug_d(34)        <= tlb_cmp_dbg_class_enable;
debug_d(35 to 36) <= tlb_cmp_dbg_extclass_enable(0 to 1);
debug_d(37 to 38) <= tlb_cmp_dbg_state_enable(0 to 1);
debug_d(39)       <= tlb_cmp_dbg_thdid_enable;
debug_d(40)       <= tlb_cmp_dbg_pid_enable;
debug_d(41)       <= tlb_cmp_dbg_lpid_enable;
debug_d(42)       <= tlb_cmp_dbg_ind_enable;
debug_d(43)       <= tlb_cmp_dbg_iprot_enable;
debug_d(44) <= tlb_cmp_dbg_way0_entry_v;    
debug_d(45) <= tlb_cmp_dbg_way0_addr_match;
debug_d(46) <= tlb_cmp_dbg_way0_pgsize_match;
debug_d(47) <= tlb_cmp_dbg_way0_class_match;
debug_d(48) <= tlb_cmp_dbg_way0_extclass_match;
debug_d(49) <= tlb_cmp_dbg_way0_state_match;
debug_d(50) <= tlb_cmp_dbg_way0_thdid_match;
debug_d(51) <= tlb_cmp_dbg_way0_pid_match;
debug_d(52) <= tlb_cmp_dbg_way0_lpid_match;
debug_d(53) <= tlb_cmp_dbg_way0_ind_match;
debug_d(54) <= tlb_cmp_dbg_way0_iprot_match;
debug_d(55) <= tlb_cmp_dbg_way1_entry_v;
debug_d(56) <= tlb_cmp_dbg_way1_addr_match;
debug_d(57) <= tlb_cmp_dbg_way1_pgsize_match;
debug_d(58) <= tlb_cmp_dbg_way1_class_match;
debug_d(59) <= tlb_cmp_dbg_way1_extclass_match;
debug_d(60) <= tlb_cmp_dbg_way1_state_match;
debug_d(61) <= tlb_cmp_dbg_way1_thdid_match;
debug_d(62) <= tlb_cmp_dbg_way1_pid_match;
debug_d(63) <= tlb_cmp_dbg_way1_lpid_match;
debug_d(64) <= tlb_cmp_dbg_way1_ind_match;
debug_d(65) <= tlb_cmp_dbg_way1_iprot_match;
debug_d(66) <= tlb_cmp_dbg_way2_entry_v;
debug_d(67) <= tlb_cmp_dbg_way2_addr_match;
debug_d(68) <= tlb_cmp_dbg_way2_pgsize_match;
debug_d(69) <= tlb_cmp_dbg_way2_class_match;
debug_d(70) <= tlb_cmp_dbg_way2_extclass_match;
debug_d(71) <= tlb_cmp_dbg_way2_state_match;
debug_d(72) <= tlb_cmp_dbg_way2_thdid_match;
debug_d(73) <= tlb_cmp_dbg_way2_pid_match;
debug_d(74) <= tlb_cmp_dbg_way2_lpid_match;
debug_d(75) <= tlb_cmp_dbg_way2_ind_match;
debug_d(76) <= tlb_cmp_dbg_way2_iprot_match;
debug_d(77) <= tlb_cmp_dbg_way3_entry_v;
debug_d(78) <= tlb_cmp_dbg_way3_addr_match;
debug_d(79) <= tlb_cmp_dbg_way3_pgsize_match;
debug_d(80) <= tlb_cmp_dbg_way3_class_match;
debug_d(81) <= tlb_cmp_dbg_way3_extclass_match;
debug_d(82) <= tlb_cmp_dbg_way3_state_match;
debug_d(83) <= tlb_cmp_dbg_way3_thdid_match;
debug_d(84) <= tlb_cmp_dbg_way3_pid_match;
debug_d(85) <= tlb_cmp_dbg_way3_lpid_match;
debug_d(86) <= tlb_cmp_dbg_way3_ind_match;
debug_d(87) <= tlb_cmp_dbg_way3_iprot_match;

dbg_group7(24 to 87) <= debug_q(24 to 87);  -- tag4 phase, see below

     -- unused tag bits for certain ops are re-purposed as below:
     --  unused tagpos_is def is mas1_v, mas1_iprot for tlbwe, and is pte.valid & 0 for ptereloads
     --  unused tagpos_pt, tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
     --  unused tagpos_atsel | tagpos_esel used as indirect entry's thdid to update tlb_entry.thdid for ptereloads
     --  unused tagpos_wq used as htw reserv write enab & dup bits (set in htw) for ptereloads
     --  unused esel for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number (1 thru 5)
     --  unused "is" for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number msb (9 thru 13, or 17 thru 21)
     --  unused HES bit for snoops is used as mmucsr0.tlb0fi full invalidate of all non-protected entries
     --  unused class is derat ttype for derat miss, 0=load,1=store,2=epid load,3=epid store
     
--group8   (erat miss, tlbre, tlbsx mas updates and parerr)
dbg_group8(0)         <= tlb_cmp_dbg_tag4_valid;
dbg_group8(1 to 2)   <= tlb_cmp_dbg_tag4_thdid(0 to 1);
dbg_group8(3 to 5)   <= tlb_cmp_dbg_tag4_type(0 to 2);
dbg_group8(6 to 7)   <= tlb_cmp_dbg_tag4(tagpos_class to tagpos_class+1);
dbg_group8(8)         <= tlb_cmp_dbg_tag4(tagpos_cm);
dbg_group8(9)         <= tlb_cmp_dbg_tag4(tagpos_gs);
dbg_group8(10)        <= tlb_cmp_dbg_tag4(tagpos_pr);
dbg_group8(11)        <= tlb_cmp_dbg_tag4(tagpos_endflag);
dbg_group8(12)        <= tlb_cmp_dbg_tag4(tagpos_atsel);
dbg_group8(13 to 15) <= tlb_cmp_dbg_tag4(tagpos_esel to tagpos_esel+2);
dbg_group8(16 to 19) <= tlb_cmp_dbg_tag4(tagpos_size to tagpos_size+3);
dbg_group8(20 to 33) <= tlb_cmp_dbg_tag4(tagpos_pid to tagpos_pid+13);
dbg_group8(34 to 58) <= tlb_cmp_dbg_tag4(tagpos_epn+27 to tagpos_epn+51);
dbg_group8(59 to 65) <= tlb_cmp_dbg_addr4(0 to 6);
dbg_group8(66 to 69) <= tlb_cmp_dbg_tag4_wayhit(0 to tlb_ways-1);
dbg_group8(70)        <= tlb_mas_dtlb_error;
dbg_group8(71)        <= tlb_mas_itlb_error;
dbg_group8(72)        <= tlb_mas_tlbsx_hit;
dbg_group8(73)        <= tlb_mas_tlbsx_miss;
dbg_group8(74)        <= tlb_mas_tlbre;
dbg_group8(75)        <= lrat_mas_tlbre;
dbg_group8(76)        <= lrat_mas_tlbsx_hit;
dbg_group8(77 )       <= lrat_mas_tlbsx_miss;
dbg_group8(78 to 80) <= lrat_tag4_hit_entry(0 to 2);
dbg_group8(81 to 85) <= tlb_cmp_dbg_tag4_parerr(0 to 4); -- way0 to 3, lru
dbg_group8(86)        <= or_reduce(mm_xu_cr0_eq_valid);
dbg_group8(87)        <= or_reduce(mm_xu_cr0_eq and mm_xu_cr0_eq_valid);


--group9   (tlbwe, ptereload write control)
dbg_group9(0)         <= tlb_cmp_dbg_tag4_valid;
dbg_group9(1 to 2)   <= tlb_cmp_dbg_tag4_thdid(0 to 1);
dbg_group9(3 to 5)   <= tlb_cmp_dbg_tag4_type(0 to 2);
dbg_group9(6)         <= tlb_cmp_dbg_tag4(tagpos_gs);
dbg_group9(7)         <= tlb_cmp_dbg_tag4(tagpos_pr);
dbg_group9(8)         <= tlb_cmp_dbg_tag4(tagpos_cm);
dbg_group9(9)         <= tlb_cmp_dbg_tag4(tagpos_hes);
dbg_group9(10 to 11) <= tlb_cmp_dbg_tag4(tagpos_wq to tagpos_wq+1);
dbg_group9(12)        <= tlb_cmp_dbg_tag4(tagpos_atsel);
dbg_group9(13 to 15) <= tlb_cmp_dbg_tag4(tagpos_esel to tagpos_esel+2);
dbg_group9(16 to 17) <= tlb_cmp_dbg_tag4(tagpos_is to tagpos_is+1);
dbg_group9(18)        <= tlb_cmp_dbg_tag4(tagpos_pt);
dbg_group9(19)        <= tlb_cmp_dbg_tag4(tagpos_recform);
dbg_group9(20)        <= tlb_cmp_dbg_tag4(tagpos_ind);
dbg_group9(21 to 27) <= tlb_cmp_dbg_addr4(0 to 6);
dbg_group9(28 to 31) <= tlb_cmp_dbg_tag4_wayhit(0 to tlb_ways-1);
dbg_group9(32 to 43) <= tlb_cmp_dbg_tag4_lru_dataout_q(0 to 11);   -- current valid. lru, iprot
dbg_group9(44 to 47) <= lrat_tag4_hit_status(0 to 3);
dbg_group9(48 to 50) <= lrat_tag4_hit_entry(0 to 2);
dbg_group9(51)       <= or_reduce(mm_iu_barrier_done);
dbg_group9(52 to 55) <= tlb_ctl_dbg_resv_valid(0 to 3);
dbg_group9(56 to 59) <= tlb_ctl_dbg_resv_match_vec_q(0 to 3);   -- tag4
dbg_group9(60 to 63) <= tlb_ctl_dbg_tag5_tlb_write_q(0 to 3);     -- tag5
dbg_group9(64 to 75) <= tlb_cmp_dbg_tag5_lru_datain_q(0 to 11);   -- tag5
dbg_group9(76)       <= tlb_cmp_dbg_tag5_lru_write;   -- all bits the same
dbg_group9(77)       <= or_reduce(mm_xu_illeg_instr);
dbg_group9(78 to 81) <= tlb_cmp_dbg_tag5_except_type_q(0 to 3);   -- tag5 except valid/type, (hv_priv | lrat_miss | pt_fault | pt_inelig)
dbg_group9(82 to 83) <= tlb_cmp_dbg_tag5_except_thdid_q(0 to 1);  -- tag5 encoded thdid
dbg_group9(84)       <= tlbwe_back_inv_valid;           -- valid
dbg_group9(85)       <= tlbwe_back_inv_attr(18);     -- not extclass enable
dbg_group9(86)       <= tlbwe_back_inv_attr(19);     -- tid_nz
dbg_group9(87)       <= '0';



debug_d(0 to 1)   <= tlb_cmp_dbg_tag4_thdid;  -- tag5 thdid encoded
debug_d(2 to 4)   <= tlb_cmp_dbg_tag4_type;   -- tag5 type encoded
debug_d(5 to 6)   <= tlb_cmp_dbg_tag4(tagpos_class to tagpos_class+1);  -- what kind of derat is it?
debug_d(7 to 11)  <= tlb_cmp_dbg_tag4_wayhit(0 to tlb_ways);  

tlb_cmp_dbg_tag5_thdid(0 to 1)  <= debug_q(0 to 1);
tlb_cmp_dbg_tag5_type(0 to 2)   <= debug_q(2 to 4);
tlb_cmp_dbg_tag5_class(0 to 1)  <= debug_q(5 to 6);
tlb_cmp_dbg_tag5_wayhit(0 to 4)  <= debug_q(7 to 11);


--group10   (erat reload bus, epn) --------> can mux tlb_datain(0:83) epn for tlbwe/ptereload ops
dbg_group10a(0)        <= tlb_cmp_dbg_tag5_iorderat_rel_val;
dbg_group10a(1 to 2)   <= tlb_cmp_dbg_tag5_thdid(0 to 1);
dbg_group10a(3 to 5)   <= tlb_cmp_dbg_tag5_type(0 to 2);
dbg_group10a(6 to 7)   <= tlb_cmp_dbg_tag5_class(0 to 1);  -- what kind of derat is it?
dbg_group10a(8 to 11)  <= tlb_cmp_dbg_tag5_wayhit(0 to tlb_ways-1);
dbg_group10a(12 to 21) <= tlb_cmp_dbg_tag5_erat_rel_val(0 to 9);
dbg_group10a(22 to 87) <= tlb_cmp_dbg_tag5_erat_rel_data(eratpos_epn to eratpos_wren);

-- tlb_low_data
-- [0:51] - EPN
-- [52:55] - SIZE (4b)
-- [56:59] - ThdID
-- [60:61] - Class
-- [62] - ExtClass
-- [63] - TID_NZ
-- [64:65] - reserved (2b)
-- [66:73] - 8b for LPID
-- [74:83] - parity 10bits
dbg_group10b(0 to 83) <= tlb_cmp_dbg_tag5_tlb_datain_q(0 to 83);  -- tlb_datain epn
dbg_group10b(84) <= Eq(tlb_cmp_dbg_tag5_type(0 to 2),"110") and or_reduce(tlb_ctl_dbg_tag5_tlb_write_q);  -- tlbwe
dbg_group10b(85) <= Eq(tlb_cmp_dbg_tag5_type(0 to 2),"111") and or_reduce(tlb_ctl_dbg_tag5_tlb_write_q);  -- ptereload
dbg_group10b(86) <= (tlb_ctl_dbg_tag5_tlb_write_q(2) or tlb_ctl_dbg_tag5_tlb_write_q(3));
dbg_group10b(87) <= (tlb_ctl_dbg_tag5_tlb_write_q(1) or tlb_ctl_dbg_tag5_tlb_write_q(3));

dbg_group10 <= dbg_group10b when mmucr2(8)='1' else dbg_group10a;


--group11   (erat reload bus, rpn) --------> can mux tlb_datain(84:167) rpn for tlbwe/ptereload ops
dbg_group11a(0)        <= tlb_cmp_dbg_tag5_iorderat_rel_val;
dbg_group11a(1 to 2)   <= tlb_cmp_dbg_tag5_thdid(0 to 1);
dbg_group11a(3 to 5)   <= tlb_cmp_dbg_tag5_type(0 to 2);
dbg_group11a(6 to 7)   <= tlb_cmp_dbg_tag5_class(0 to 1);  -- what kind of derat is it?
dbg_group11a(8 to 11)  <= tlb_cmp_dbg_tag5_wayhit(0 to tlb_ways-1);
dbg_group11a(12 to 21) <= tlb_cmp_dbg_tag5_erat_rel_val(0 to 9);
dbg_group11a(22 to 87) <= tlb_cmp_dbg_tag5_erat_rel_data(eratpos_rpnrsvd to eratpos_tid+7);

-- tlb_high_data
-- [84]      - [0]     - X-bit
-- [85:87]   - [1:3]   - reserved (3b)
-- [88:117]  - [4:33]  - RPN (30b)
-- [118:119] - [34:35] - R,C
-- [120:121] - [36:37] - WLC (2b)
-- [122]     - [38]    - ResvAttr
-- [123]     - [39]    - VF
-- [124]     - [40]    - IND
-- [125:128] - [41:44] - U0-U3
-- [129:133] - [45:49] - WIMGE
-- [134:135] - [50:51] - UX,SX
-- [136:137] - [52:53] - UW,SW
-- [138:139] - [54:55] - UR,SR
-- [140]     - [56] - GS
-- [141]     - [57] - TS
-- [142:143] - [58:59] - reserved (2b)
-- [144:149] - [60:65] - 6b TID msbs
-- [150:157] - [66:73] - 8b TID lsbs
-- [158:167] - [74:83] - parity 10bits
dbg_group11b(0 to 83) <= tlb_cmp_dbg_tag5_tlb_datain_q(84 to 167);  -- tlb_datain rpn
dbg_group11b(84) <= Eq(tlb_cmp_dbg_tag5_type(0 to 2),"110") and or_reduce(tlb_ctl_dbg_tag5_tlb_write_q);  -- tlbwe
dbg_group11b(85) <= Eq(tlb_cmp_dbg_tag5_type(0 to 2),"111") and or_reduce(tlb_ctl_dbg_tag5_tlb_write_q);  -- ptereload
dbg_group11b(86) <= (tlb_ctl_dbg_tag5_tlb_write_q(2) or tlb_ctl_dbg_tag5_tlb_write_q(3));
dbg_group11b(87) <= (tlb_ctl_dbg_tag5_tlb_write_q(1) or tlb_ctl_dbg_tag5_tlb_write_q(3));

dbg_group11 <= dbg_group11b when mmucr2(8)='1' else dbg_group11a;

--group12   (reservations)
dbg_group12a(0)        <= tlb_ctl_dbg_tag1_valid;
dbg_group12a(1 to 2)   <= tlb_ctl_dbg_tag1_thdid(0 to 1);
dbg_group12a(3 to 5)   <= tlb_ctl_dbg_tag1_type(0 to 2);
dbg_group12a(6 to 7)   <= tlb_ctl_dbg_tag1_wq(0 to 1);

dbg_group12a(8 to 11)  <= tlb_ctl_dbg_resv_valid(0 to 3);
dbg_group12a(12 to 15) <= tlb_ctl_dbg_set_resv(0 to 3);
dbg_group12a(16 to 19) <= tlb_ctl_dbg_resv_match_vec_q(0 to 3);   -- tag4

debug_d(group12_offset+20)    <= tlb_ctl_dbg_resv0_tag0_lpid_match;
debug_d(group12_offset+21)    <= tlb_ctl_dbg_resv0_tag0_pid_match;
debug_d(group12_offset+22)    <= tlb_ctl_dbg_resv0_tag0_as_snoop_match;
debug_d(group12_offset+23)    <= tlb_ctl_dbg_resv0_tag0_gs_snoop_match;
debug_d(group12_offset+24)    <= tlb_ctl_dbg_resv0_tag0_as_tlbwe_match;
debug_d(group12_offset+25)    <= tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match;
debug_d(group12_offset+26)    <= tlb_ctl_dbg_resv0_tag0_ind_match;
debug_d(group12_offset+27)    <= tlb_ctl_dbg_resv0_tag0_epn_loc_match;
debug_d(group12_offset+28)    <= tlb_ctl_dbg_resv0_tag0_epn_glob_match;
debug_d(group12_offset+29)    <= tlb_ctl_dbg_resv0_tag0_class_match;
debug_d(group12_offset+30)    <= tlb_ctl_dbg_resv1_tag0_lpid_match;
debug_d(group12_offset+31)    <= tlb_ctl_dbg_resv1_tag0_pid_match;
debug_d(group12_offset+32)    <= tlb_ctl_dbg_resv1_tag0_as_snoop_match;
debug_d(group12_offset+33)    <= tlb_ctl_dbg_resv1_tag0_gs_snoop_match;
debug_d(group12_offset+34)    <= tlb_ctl_dbg_resv1_tag0_as_tlbwe_match;
debug_d(group12_offset+35)    <= tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match;
debug_d(group12_offset+36)    <= tlb_ctl_dbg_resv1_tag0_ind_match;
debug_d(group12_offset+37)    <= tlb_ctl_dbg_resv1_tag0_epn_loc_match;
debug_d(group12_offset+38)    <= tlb_ctl_dbg_resv1_tag0_epn_glob_match;
debug_d(group12_offset+39)    <= tlb_ctl_dbg_resv1_tag0_class_match;
debug_d(group12_offset+40)    <= tlb_ctl_dbg_resv2_tag0_lpid_match;
debug_d(group12_offset+41)    <= tlb_ctl_dbg_resv2_tag0_pid_match;
debug_d(group12_offset+42)    <= tlb_ctl_dbg_resv2_tag0_as_snoop_match;
debug_d(group12_offset+43)    <= tlb_ctl_dbg_resv2_tag0_gs_snoop_match;
debug_d(group12_offset+44)    <= tlb_ctl_dbg_resv2_tag0_as_tlbwe_match;
debug_d(group12_offset+45)    <= tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match;
debug_d(group12_offset+46)    <= tlb_ctl_dbg_resv2_tag0_ind_match;
debug_d(group12_offset+47)    <= tlb_ctl_dbg_resv2_tag0_epn_loc_match;
debug_d(group12_offset+48)    <= tlb_ctl_dbg_resv2_tag0_epn_glob_match;
debug_d(group12_offset+49)    <= tlb_ctl_dbg_resv2_tag0_class_match;
debug_d(group12_offset+50)    <= tlb_ctl_dbg_resv3_tag0_lpid_match;
debug_d(group12_offset+51)    <= tlb_ctl_dbg_resv3_tag0_pid_match;
debug_d(group12_offset+52)    <= tlb_ctl_dbg_resv3_tag0_as_snoop_match;
debug_d(group12_offset+53)    <= tlb_ctl_dbg_resv3_tag0_gs_snoop_match;
debug_d(group12_offset+54)    <= tlb_ctl_dbg_resv3_tag0_as_tlbwe_match;
debug_d(group12_offset+55)    <= tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match;
debug_d(group12_offset+56)    <= tlb_ctl_dbg_resv3_tag0_ind_match;
debug_d(group12_offset+57)    <= tlb_ctl_dbg_resv3_tag0_epn_loc_match;
debug_d(group12_offset+58)    <= tlb_ctl_dbg_resv3_tag0_epn_glob_match;
debug_d(group12_offset+59)    <= tlb_ctl_dbg_resv3_tag0_class_match;

dbg_group12a(20 to 59) <= debug_q(group12_offset+20 to group12_offset+59);  -- tag1

dbg_group12a(60 to 63) <= tlb_ctl_dbg_clr_resv_q(0 to 3);  -- tag5
dbg_group12a(64 to 67) <= tlb_ctl_dbg_clr_resv_terms(0 to 3);  -- tag5, threadwise condensed into to  tlbivax, tlbilx, tlbwe, ptereload

dbg_group12a(68 to 71) <= htw_dbg_req_valid_q(0 to 3);
dbg_group12a(72 to 75) <= htw_dbg_resv_valid_vec(0 to 3);
dbg_group12a(76 to 79) <= htw_dbg_tag4_clr_resv_q(0 to 3);
dbg_group12a(80 to 83) <= htw_dbg_tag4_clr_resv_terms(0 to 3);  -- tag4, threadwise condensed into to  tlbivax, tlbilx, tlbwe, ptereload
dbg_group12a(84 to 87) <= "0000"; 

-- tlb_low_data
-- [0:51] - EPN
-- [52:55] - SIZE (4b)
-- [56:59] - ThdID
-- [60:61] - Class
-- [62] - ExtClass
-- [63] - TID_NZ
-- [64:65] - reserved (2b)
-- [66:73] - 8b for LPID
-- [74:83] - parity 10bits
dbg_group12b(0 to 83) <= tlb_cmp_dbg_tag5_way(0 to 83);  -- tag5 way epn
dbg_group12b(84) <= (tlb_cmp_dbg_tag5_lru_dataout(0) and tlb_cmp_dbg_tag5_wayhit(0)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(1) and tlb_cmp_dbg_tag5_wayhit(1)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(2) and tlb_cmp_dbg_tag5_wayhit(2)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(3) and tlb_cmp_dbg_tag5_wayhit(3));  -- valid
dbg_group12b(85) <= (tlb_cmp_dbg_tag5_lru_dataout(8) and tlb_cmp_dbg_tag5_wayhit(0)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(9) and tlb_cmp_dbg_tag5_wayhit(1)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(10) and tlb_cmp_dbg_tag5_wayhit(2)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(11) and tlb_cmp_dbg_tag5_wayhit(3));  -- iprot
dbg_group12b(86) <= tlb_cmp_dbg_tag5_lru_dataout(4);                                              -- encoded lru way msb
dbg_group12b(87)       <= (not(tlb_cmp_dbg_tag5_lru_dataout(4)) and tlb_cmp_dbg_tag5_lru_dataout(5)) or 
                                 (tlb_cmp_dbg_tag5_lru_dataout(4) and tlb_cmp_dbg_tag5_lru_dataout(6));  -- encoded lru way lsb

dbg_group12 <= dbg_group12b when mmucr2(9)='1' else dbg_group12a;

     -- unused tag bits for certain ops are re-purposed as below:
     --  unused tagpos_is def is mas1_v, mas1_iprot for tlbwe, and is pte.valid & 0 for ptereloads
     --  unused tagpos_pt, tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
     --  unused tagpos_atsel | tagpos_esel used as indirect entry's thdid to update tlb_entry.thdid for ptereloads
     --  unused tagpos_wq used as htw reserv write enab & dup bits (set in htw) for ptereloads
     --  unused esel for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number (1 thru 5)
     --  unused "is" for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number msb (9 thru 13, or 17 thru 21)
     --  unused HES bit for snoops is used as mmucsr0.tlb0fi full invalidate of all non-protected entries
     --  unused class is derat ttype for derat miss, 0=load,1=store,2=epid load,3=epid store

          -- type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload

--group13   (lrat match logic)
dbg_group13a(0)        <= lrat_dbg_tag1_addr_enable;  -- tlb_addr_cap_q(1)
dbg_group13a(1)        <= tlb_ctl_dbg_tag1_valid;
dbg_group13a(2 to 3)   <= tlb_ctl_dbg_tag1_thdid(0 to 1);
dbg_group13a(4 to 5)   <= (tlb_ctl_dbg_tag1_type(0) and tlb_ctl_dbg_tag1_type(1)) & (tlb_ctl_dbg_tag1_type(0) and tlb_ctl_dbg_tag1_type(2));  -- tlbsx,tlbre,tlbwe,ptereload
dbg_group13a(6)        <= tlb_ctl_dbg_tag1_gs;  
dbg_group13a(7)        <= tlb_ctl_dbg_tag1_pr;  
dbg_group13a(8)        <= tlb_ctl_dbg_tag1_atsel;  
dbg_group13a(9 to 11)  <= lrat_tag3_hit_entry(0 to 2);
dbg_group13a(12 to 15) <= lrat_tag3_hit_status(0 to 3);  -- hit_status to  val,hit,multihit,inval_pgsize

debug_d(group13_offset+16)       <= lrat_dbg_entry0_addr_match;  -- tag1
debug_d(group13_offset+17)       <= lrat_dbg_entry0_lpid_match;
debug_d(group13_offset+18)       <= lrat_dbg_entry0_entry_v;
debug_d(group13_offset+19)       <= lrat_dbg_entry0_entry_x;
debug_d(group13_offset+20 to group13_offset+23) <= lrat_dbg_entry0_size(0 to 3);
debug_d(group13_offset+24)       <= lrat_dbg_entry1_addr_match;  -- tag1
debug_d(group13_offset+25)       <= lrat_dbg_entry1_lpid_match;
debug_d(group13_offset+26)       <= lrat_dbg_entry1_entry_v;
debug_d(group13_offset+27)       <= lrat_dbg_entry1_entry_x;
debug_d(group13_offset+28 to group13_offset+31) <= lrat_dbg_entry1_size(0 to 3);
debug_d(group13_offset+32)       <= lrat_dbg_entry2_addr_match;  -- tag1
debug_d(group13_offset+33)       <= lrat_dbg_entry2_lpid_match;
debug_d(group13_offset+34)       <= lrat_dbg_entry2_entry_v;
debug_d(group13_offset+35)       <= lrat_dbg_entry2_entry_x;
debug_d(group13_offset+36 to group13_offset+39) <= lrat_dbg_entry2_size(0 to 3);
debug_d(group13_offset+40)       <= lrat_dbg_entry3_addr_match;  -- tag1
debug_d(group13_offset+41)       <= lrat_dbg_entry3_lpid_match;
debug_d(group13_offset+42)       <= lrat_dbg_entry3_entry_v;
debug_d(group13_offset+43)       <= lrat_dbg_entry3_entry_x;
debug_d(group13_offset+44 to group13_offset+47) <= lrat_dbg_entry3_size(0 to 3);
debug_d(group13_offset+48)       <= lrat_dbg_entry4_addr_match ; -- tag1
debug_d(group13_offset+49)       <= lrat_dbg_entry4_lpid_match;
debug_d(group13_offset+50)       <= lrat_dbg_entry4_entry_v;
debug_d(group13_offset+51)       <= lrat_dbg_entry4_entry_x;
debug_d(group13_offset+52 to group13_offset+55) <= lrat_dbg_entry4_size(0 to 3);
debug_d(group13_offset+56)       <= lrat_dbg_entry5_addr_match ; -- tag1
debug_d(group13_offset+57)       <= lrat_dbg_entry5_lpid_match;
debug_d(group13_offset+58)       <= lrat_dbg_entry5_entry_v;
debug_d(group13_offset+59)       <= lrat_dbg_entry5_entry_x;
debug_d(group13_offset+60 to group13_offset+63) <= lrat_dbg_entry5_size(0 to 3);
debug_d(group13_offset+64)       <= lrat_dbg_entry6_addr_match;  -- tag1
debug_d(group13_offset+65)       <= lrat_dbg_entry6_lpid_match;
debug_d(group13_offset+66)       <= lrat_dbg_entry6_entry_v;
debug_d(group13_offset+67)       <= lrat_dbg_entry6_entry_x;
debug_d(group13_offset+68 to group13_offset+71) <= lrat_dbg_entry6_size(0 to 3);
debug_d(group13_offset+72)       <= lrat_dbg_entry7_addr_match; -- tag1
debug_d(group13_offset+73)       <= lrat_dbg_entry7_lpid_match;
debug_d(group13_offset+74)       <= lrat_dbg_entry7_entry_v;
debug_d(group13_offset+75)       <= lrat_dbg_entry7_entry_x;
debug_d(group13_offset+76 to group13_offset+79) <= lrat_dbg_entry7_size(0 to 3);

dbg_group13a(16 to 79) <= debug_q(group13_offset+16 to group13_offset+79);  -- tag2
dbg_group13a(80 to 87) <= lrat_dbg_tag2_matchline_q(0 to 7);

-- tlb_high_data
-- [84]      - [0]     - X-bit
-- [85:87]   - [1:3]   - reserved (3b)
-- [88:117]  - [4:33]  - RPN (30b)
-- [118:119] - [34:35] - R,C
-- [120:121] - [36:37] - WLC (2b)
-- [122]     - [38]    - ResvAttr
-- [123]     - [39]    - VF
-- [124]     - [40]    - IND
-- [125:128] - [41:44] - U0-U3
-- [129:133] - [45:49] - WIMGE
-- [134:135] - [50:51] - UX,SX
-- [136:137] - [52:53] - UW,SW
-- [138:139] - [54:55] - UR,SR
-- [140]     - [56] - GS
-- [141]     - [57] - TS
-- [142:143] - [58:59] - reserved (2b)
-- [144:149] - [60:65] - 6b TID msbs
-- [150:157] - [66:73] - 8b TID lsbs
-- [158:167] - [74:83] - parity 10bits
dbg_group13b(0 to 83) <= tlb_cmp_dbg_tag5_way(84 to 167);  -- tag5 way rpn
dbg_group13b(84) <= (tlb_cmp_dbg_tag5_lru_dataout(0) and tlb_cmp_dbg_tag5_wayhit(0)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(1) and tlb_cmp_dbg_tag5_wayhit(1)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(2) and tlb_cmp_dbg_tag5_wayhit(2)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(3) and tlb_cmp_dbg_tag5_wayhit(3));  -- valid
dbg_group13b(85) <= (tlb_cmp_dbg_tag5_lru_dataout(8) and tlb_cmp_dbg_tag5_wayhit(0)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(9) and tlb_cmp_dbg_tag5_wayhit(1)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(10) and tlb_cmp_dbg_tag5_wayhit(2)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(11) and tlb_cmp_dbg_tag5_wayhit(3));  -- iprot
dbg_group13b(86) <= tlb_cmp_dbg_tag5_lru_dataout(4);                                         -- encoded lru way msb
dbg_group13b(87)       <= (not(tlb_cmp_dbg_tag5_lru_dataout(4)) and tlb_cmp_dbg_tag5_lru_dataout(5)) or 
                                 (tlb_cmp_dbg_tag5_lru_dataout(4) and tlb_cmp_dbg_tag5_lru_dataout(6));  -- encoded lru way lsb


dbg_group13 <= dbg_group13b when mmucr2(9)='1' else dbg_group13a;


--group14   (htw control)
dbg_group14a(0 to 1)   <= htw_dbg_seq_q(0 to 1);
dbg_group14a(2 to 3)   <= htw_dbg_inptr_q(0 to 1);
dbg_group14a(4)        <= htw_dbg_ptereload_ptr_q;
dbg_group14a(5 to 6)   <= htw_dbg_lsuptr_q(0 to 1);
dbg_group14a(7)        <= htw_lsu_ttype(1); 
dbg_group14a(8 to 9)   <= htw_dbg_lsu_thdid(0 to 1);   -- encoded
dbg_group14a(10 to 51) <= htw_lsu_addr(22 to 63);
dbg_group14a(52 to 54) <= htw_dbg_pte0_seq_q(0 to 2);
dbg_group14a(55 to 56) <= htw_dbg_pte0_score_ptr_q(0 to 1);
dbg_group14a(57 to 59) <= htw_dbg_pte0_score_cl_offset_q(58 to 60);
dbg_group14a(60 to 62) <= htw_dbg_pte0_score_error_q(0 to 2);
dbg_group14a(63 to 66) <= htw_dbg_pte0_score_qwbeat_q(0 to 3); -- 4 beats of data per CL
dbg_group14a(67)       <= htw_dbg_pte0_score_pending_q;
dbg_group14a(68)       <= htw_dbg_pte0_score_ibit_q;
dbg_group14a(69)       <= htw_dbg_pte0_score_dataval_q;
dbg_group14a(70 to 72) <= htw_dbg_pte1_seq_q(0 to 2);
dbg_group14a(73 to 74) <= htw_dbg_pte1_score_ptr_q(0 to 1);
dbg_group14a(75 to 77) <= htw_dbg_pte1_score_cl_offset_q(58 to 60);
dbg_group14a(78 to 80) <= htw_dbg_pte1_score_error_q(0 to 2);
dbg_group14a(81 to 84) <= htw_dbg_pte1_score_qwbeat_q(0 to 3); -- 4 beats of data per CL
dbg_group14a(85)       <= htw_dbg_pte1_score_pending_q;
dbg_group14a(86)       <= htw_dbg_pte1_score_ibit_q;
dbg_group14a(87)       <= htw_dbg_pte1_score_dataval_q;

-- tlb_low_data
-- [0:51] - EPN
-- [52:55] - SIZE (4b)
-- [56:59] - ThdID
-- [60:61] - Class
-- [62] - ExtClass
-- [63] - TID_NZ
-- [64:65] - reserved (2b)
-- [66:73] - 8b for LPID
-- [74:83] - parity 10bits

-- tlb_high_data
-- [84]      - [0]     - X-bit
-- [85:87]   - [1:3]   - reserved (3b)
-- [88:117]  - [4:33]  - RPN (30b)
-- [118:119] - [34:35] - R,C
-- [120:121] - [36:37] - WLC (2b)
-- [122]     - [38]    - ResvAttr
-- [123]     - [39]    - VF
-- [124]     - [40]    - IND
-- [125:128] - [41:44] - U0-U3
-- [129:133] - [45:49] - WIMGE
-- [134:135] - [50:51] - UX,SX
-- [136:137] - [52:53] - UW,SW
-- [138:139] - [54:55] - UR,SR
-- [140]     - [56] - GS
-- [141]     - [57] - TS
-- [142:143] - [58:59] - reserved (2b)
-- [144:149] - [60:65] - 6b TID msbs
-- [150:157] - [66:73] - 8b TID lsbs
-- [158:167] - [74:83] - parity 10bits
dbg_group14b(0) <= (tlb_cmp_dbg_tag5_lru_dataout(0) and tlb_cmp_dbg_tag5_wayhit(0)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(1) and tlb_cmp_dbg_tag5_wayhit(1)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(2) and tlb_cmp_dbg_tag5_wayhit(2)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(3) and tlb_cmp_dbg_tag5_wayhit(3));  -- valid
dbg_group14b(1) <= (tlb_cmp_dbg_tag5_lru_dataout(8) and tlb_cmp_dbg_tag5_wayhit(0)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(9) and tlb_cmp_dbg_tag5_wayhit(1)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(10) and tlb_cmp_dbg_tag5_wayhit(2)) or
                     (tlb_cmp_dbg_tag5_lru_dataout(11) and tlb_cmp_dbg_tag5_wayhit(3));  -- iprot

dbg_group14b(2) <= tlb_cmp_dbg_tag5_way(140);  -- gs
dbg_group14b(3) <= tlb_cmp_dbg_tag5_way(141);  -- ts
dbg_group14b(4 to 11) <= tlb_cmp_dbg_tag5_way(66 to 73);  -- tlpid
dbg_group14b(12 to 25) <= tlb_cmp_dbg_tag5_way(144 to 157);  -- tid, 14bits
dbg_group14b(26 to 45) <= tlb_cmp_dbg_tag5_way(32 to 51);  -- epn truncated to lower 20b
dbg_group14b(46 to 49) <= tlb_cmp_dbg_tag5_way(52 to 55);  -- size
dbg_group14b(50 to 53) <= tlb_cmp_dbg_tag5_way(56 to 59);  -- thdid
dbg_group14b(54) <= tlb_cmp_dbg_tag5_way(84);  -- xbit
dbg_group14b(55) <= tlb_cmp_dbg_tag5_way(40);  -- ind
dbg_group14b(56 to 57) <= tlb_cmp_dbg_tag5_way(60 to 61);  -- class
dbg_group14b(58 to 77) <= tlb_cmp_dbg_tag5_way(98 to 117);  -- rpn truncated to lower 20b
dbg_group14b(78 to 81) <= tlb_cmp_dbg_tag5_way(130 to 133);   -- imge
dbg_group14b(82 to 87) <= tlb_cmp_dbg_tag5_way(134 to 139);   -- user/sup prot bits

dbg_group14 <= dbg_group14b when mmucr2(10)='1' else dbg_group14a;

--group15   (ptereload pte)
dbg_group15a(0 to 1)   <= htw_dbg_seq_q(0 to 1);
dbg_group15a(2 to 4)   <= htw_dbg_pte0_seq_q(0 to 2);
dbg_group15a(5 to 7)   <= htw_dbg_pte1_seq_q(0 to 2);
dbg_group15a(8)        <= htw_lsu_req_valid;
dbg_group15a(9 to 21)  <= htw_lsu_addr(48 to 60);
dbg_group15a(22)       <= htw_dbg_ptereload_ptr_q;
dbg_group15a(23)       <= ptereload_req_taken;
dbg_group15a(24 to 87) <= ptereload_req_pte(0 to 63);  -- pte entry


dbg_group15b(0 to 73)  <= tlb_cmp_dbg_tag5_way(0 to 73);  -- tag5 way epn
dbg_group15b(74 to 77) <= tlb_cmp_dbg_tag5_lru_dataout(0 to 3); 
dbg_group15b(78 to 81) <= tlb_cmp_dbg_tag5_lru_dataout(8 to 11); 
dbg_group15b(82)       <= tlb_cmp_dbg_tag5_lru_dataout(4);                               -- encoded lsu way msb
dbg_group15b(83)       <= (not(tlb_cmp_dbg_tag5_lru_dataout(4)) and tlb_cmp_dbg_tag5_lru_dataout(5)) or 
                                 (tlb_cmp_dbg_tag5_lru_dataout(4) and tlb_cmp_dbg_tag5_lru_dataout(6)); -- encoded lsu way lsb
dbg_group15b(84 to 87) <= tlb_cmp_dbg_tag5_wayhit(0 to 3); 

dbg_group15 <= dbg_group15b when mmucr2(10)='1' else dbg_group15a;


-- trigger group0
trg_group0(0)     <= not(tlb_ctl_dbg_seq_idle);
trg_group0(1 to 2)   <= tlb_ctl_dbg_tag0_thdid(0 to 1);  -- encoded
trg_group0(3 to 5)   <= tlb_ctl_dbg_tag0_type(0 to 2);   -- encoded
trg_group0(6)     <= not(inval_dbg_seq_idle);  
trg_group0(7)     <= inval_dbg_seq_snoop_inprogress;   -- bus snoop
trg_group0(8)     <= not(htw_dbg_seq_idle);  
trg_group0(9)     <= not(htw_dbg_pte0_seq_idle);  
trg_group0(10)    <= not(htw_dbg_pte1_seq_idle);  
trg_group0(11)    <= tlb_cmp_dbg_tag5_any_exception;  -- big or gate


-- trigger group1
trg_group1(0 to 5)   <= tlb_ctl_dbg_seq_q(0 to 5);
trg_group1(6 to 10)  <= inval_dbg_seq_q(0 to 4);
trg_group1(11)       <= tlb_ctl_dbg_seq_any_done_sig or tlb_ctl_dbg_seq_abort or inval_dbg_seq_snoop_done or inval_dbg_seq_local_done or inval_dbg_seq_tlb0fi_done or inval_dbg_seq_tlbwe_snoop_done;


-- trigger group2
trg_group2(0)     <= tlb_req_dbg_ierat_iu5_valid_q;
trg_group2(1)     <= tlb_req_dbg_derat_ex6_valid_q;
trg_group2(2)     <= tlb_ctl_dbg_any_tlb_req_sig;
trg_group2(3)     <= tlb_ctl_dbg_any_req_taken_sig;
trg_group2(4)     <= tlb_ctl_dbg_seq_any_done_sig or tlb_ctl_dbg_seq_abort;
trg_group2(5)     <= inval_dbg_ex6_valid;  ---------------->  need tlbivax/erativax indication?
trg_group2(6)     <= mmucsr0_tlb0fi;
trg_group2(7)     <= inval_dbg_snoop_forme;
trg_group2(8)     <= tlbwe_back_inv_valid;
trg_group2(9)     <= htw_lsu_req_valid;
trg_group2(10)    <= inval_dbg_seq_snoop_done or inval_dbg_seq_local_done or inval_dbg_seq_tlb0fi_done or inval_dbg_seq_tlbwe_snoop_done;
trg_group2(11)    <= or_reduce(mm_xu_lsu_req);


-- trigger group3
trg_group3a(0) <= spr_dbg_slowspr_val_int;
trg_group3a(1) <= spr_dbg_slowspr_rw_int;
trg_group3a(2 to 3) <= spr_dbg_slowspr_etid_int;
trg_group3a(4) <= spr_dbg_match_64b;
trg_group3a(5) <= spr_dbg_match_any_mmu;  -- int phase
trg_group3a(6) <= spr_dbg_match_any_mas;
trg_group3a(7) <= spr_dbg_match_mmucr0 or spr_dbg_match_mmucr1 or spr_dbg_match_mmucr2 or spr_dbg_match_mmucr3;
trg_group3a(8) <= spr_dbg_match_pid or spr_dbg_match_lpidr;
trg_group3a(9) <= spr_dbg_match_lper or spr_dbg_match_lperu;
trg_group3a(10) <= spr_dbg_slowspr_val_out;
trg_group3a(11) <= spr_dbg_slowspr_done_out;

trg_group3b(0)         <= tlb_htw_req_valid;
trg_group3b(1 to 2)   <= htw_dbg_seq_q(0 to 1);
trg_group3b(3 to 5)   <= htw_dbg_pte0_seq_q(0 to 2);
trg_group3b(6 to 8)   <= htw_dbg_pte1_seq_q(0 to 2);
trg_group3b(9)         <= htw_dbg_pte0_reld_for_me_tm1 or htw_dbg_pte1_reld_for_me_tm1;
trg_group3b(10)        <= or_reduce(htw_dbg_pte0_score_error_q or htw_dbg_pte1_score_error_q);
trg_group3b(11)        <= tlb_cmp_dbg_tag5_any_exception;

trg_group3 <= trg_group3b when mmucr2(11)='1' else trg_group3a;



dbg_mux0: entity clib.c_debug_mux16
  port map(
           vd => vdd, 
           gd => gnd,
  
           select_bits          => pc_mm_debug_mux1_ctrls_loc_q,
           trace_data_in        => debug_bus_in_q,
           trigger_data_in      => trace_triggers_in_q,
                       
           dbg_group0          => dbg_group0,
           dbg_group1          => dbg_group1,
           dbg_group2          => dbg_group2,
           dbg_group3          => dbg_group3,
           dbg_group4          => dbg_group4,
           dbg_group5          => dbg_group5,
           dbg_group6          => dbg_group6,
           dbg_group7          => dbg_group7,
           dbg_group8          => dbg_group8,
           dbg_group9          => dbg_group9,
           dbg_group10         => dbg_group10,
           dbg_group11         => dbg_group11,
           dbg_group12         => dbg_group12,
           dbg_group13         => dbg_group13,
           dbg_group14         => dbg_group14,
           dbg_group15         => dbg_group15,                     
                      
           trg_group0         => trg_group0,
           trg_group1         => trg_group1,
           trg_group2         => trg_group2,
           trg_group3         => trg_group3,
                       
           trace_data_out       => trace_data_out_d,
           trigger_data_out     => trigger_data_out_d
);

trace_triggers_out      <= trigger_data_out_q;
debug_bus_out           <= trace_data_out_q;
debug_bus_out_int       <= trace_data_out_int_q;


-- unused spare signal assignments
unused_dc(0) <= TLB_MAS_THDID(0);
unused_dc(1) <= LRAT_MAS_THDID(0);
unused_dc(2) <= LRAT_MAS_THDID(0);
unused_dc(3) <= INVAL_DBG_LSU_TOKENS_Q(0);
unused_dc(4) <= TLB_CMP_DBG_TAG4(82);  -- tagpos_derat, not used for type encoding of '0'
unused_dc(5) <= TLB_CMP_DBG_TAG4(106);  -- tagpos_lrat

unused_dc(6) <= or_reduce(TLB_CMP_DBG_TAG4(0 TO 7)); -- tagpos_epn
unused_dc(7) <= or_reduce(TLB_CMP_DBG_TAG4(8 TO 15));
unused_dc(8) <= TLB_CMP_DBG_TAG5_WAYHIT(4);

unused_dc(9) <= DEBUG_Q(23);
unused_dc(10) <= or_reduce(TRIGGER_Q(0 to 47));
unused_dc(11) <= tlb_cmp_dbg_tag5_lru_dataout(7); -- lru parity bit


-----------------------------------------------------------------------
-- Latches
-----------------------------------------------------------------------

trace_bus_enable_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_sl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => pc_mm_trace_bus_enable,
            dout    => pc_mm_trace_bus_enable_q);
debug_mux1_ctrls_latch : tri_rlmreg_p
  generic map (width => pc_mm_debug_mux1_ctrls_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_mm_trace_bus_enable_q,
            forcee => pc_func_slp_sl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            scin    => siv(debug_mux1_ctrls_offset to debug_mux1_ctrls_offset + pc_mm_debug_mux1_ctrls_q'length-1),
            scout   => sov(debug_mux1_ctrls_offset to debug_mux1_ctrls_offset + pc_mm_debug_mux1_ctrls_q'length-1),
            din     => pc_mm_debug_mux1_ctrls,
            dout    => pc_mm_debug_mux1_ctrls_q);
debug_mux1_ctrls_loc_latch : tri_rlmreg_p
  generic map (width => pc_mm_debug_mux1_ctrls_loc_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_mm_trace_bus_enable_q,
            forcee => pc_func_slp_sl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            scin    => siv(debug_mux1_ctrls_loc_offset to debug_mux1_ctrls_loc_offset + pc_mm_debug_mux1_ctrls_loc_q'length-1),
            scout   => sov(debug_mux1_ctrls_loc_offset to debug_mux1_ctrls_loc_offset + pc_mm_debug_mux1_ctrls_loc_q'length-1),
            din     => pc_mm_debug_mux1_ctrls_loc_d,
            dout    => pc_mm_debug_mux1_ctrls_loc_q);
trigger_data_latch: tri_rlmreg_p
  generic map (width => trigger_data_out_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => pc_mm_trace_bus_enable_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            scout   => sov(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            din     => trigger_data_out_d,
            dout    => trigger_data_out_q);

trace_data_out_latch: tri_rlmreg_p
  generic map (width => trace_data_out_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => pc_mm_trace_bus_enable_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(trace_data_out_offset to trace_data_out_offset + trace_data_out_q'length-1),
            scout   => sov(trace_data_out_offset to trace_data_out_offset + trace_data_out_q'length-1),
            din     => trace_data_out_d,
            dout    => trace_data_out_q);

trace_data_out_int_latch: tri_rlmreg_p
  generic map (width => trace_data_out_int_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => pc_mm_trace_bus_enable_q,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv(trace_data_out_int_offset to trace_data_out_int_offset + trace_data_out_int_q'length-1),
            scout   => sov(trace_data_out_int_offset to trace_data_out_int_offset + trace_data_out_int_q'length-1),
            din     => trace_data_out_d(0 to 7),
            dout    => trace_data_out_int_q);

debug_latch : tri_regk
  generic map (width => debug_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_mm_trace_bus_enable_q,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => debug_d,
            dout    => debug_q);

trigger_latch : tri_regk
  generic map (width => trigger_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_mm_trace_bus_enable_q,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => trigger_d,
            dout    => trigger_q);


debug_bus_in_latch : tri_regk
  generic map (width => debug_bus_in_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_mm_trace_bus_enable_q,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => debug_bus_in,
            dout    => debug_bus_in_q);

trace_triggers_in_latch : tri_regk
  generic map (width => trace_triggers_in_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_mm_trace_bus_enable_q,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b, 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => trace_triggers_in,
            dout    => trace_triggers_in_q);

-------------------------------------------------
-- pervasive
-------------------------------------------------

perv_2to1_plat: tri_plat
  generic map (width => 4, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_func_slp_sl_thold_2,
            din(1)      => pc_func_slp_nsl_thold_2,
            din(2)      => pc_sg_2,
            din(3)      => pc_fce_2,
            q(0)        => pc_func_slp_sl_thold_1,
            q(1)        => pc_func_slp_nsl_thold_1,
            q(2)        => pc_sg_1,
            q(3)        => pc_fce_1);

perv_1to0_plat: tri_plat
  generic map (width => 4, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_func_slp_sl_thold_1,
            din(1)      => pc_func_slp_nsl_thold_1,
            din(2)      => pc_sg_1,
            din(3)      => pc_fce_1,
            q(0)        => pc_func_slp_sl_thold_0,
            q(1)        => pc_func_slp_nsl_thold_0,
            q(2)        => pc_sg_0,
            q(3)        => pc_fce_0);

perv_sl_lcbor: tri_lcbor
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
siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);


end mmq_dbg;
