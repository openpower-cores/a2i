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




library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 
   use work.iuq_pkg.all;

---------------------------------------------------------------------


entity iuq_axu_fu_dep is
generic(
        expand_type                             : integer := 2; 
        fpr_addr_width                          : integer := 5; 
        lmq_entries                             : integer := 8;
        needs_sreset                            : integer := 1);   
port(
   	nclk                                 	: in  clk_logic;                
        ---------------------------------------------------------------------
        vdd                                 	: inout power_logic;
        gnd                                 	: inout power_logic;
        ---------------------------------------------------------------------
   	i_dep_si                            	: in std_ulogic;
   	i_dep_so                           	: out std_ulogic;
        
     	pc_iu_func_sl_thold_0_b            : in std_ulogic;
     	pc_iu_sg_0                         : in std_ulogic;
     	forcee : in std_ulogic;
     	d_mode                             : in std_ulogic;
     	delay_lclkr                        : in std_ulogic;
     	mpw1_b                             : in std_ulogic;
     	mpw2_b                             : in std_ulogic;        

        ---------------------------------------------------------------------

        i_afd_is1_is_ucode                      : in  std_ulogic;
        i_afd_is1_to_ucode                      : in  std_ulogic;
        i_afd_is2_is_ucode                      : out std_ulogic;

        i_afd_config_iucr                       : in  std_ulogic_vector(1 to 7);  -- IUCR2(33:39)
        
       
        i_afd_is1_instr_v                     	: in  std_ulogic;
        i_afd_is1_instr                     	: in  std_ulogic_vector(26 to 31);
                
        i_afd_is1_fra_v                     	: in  std_ulogic;                
        i_afd_is1_frb_v                     	: in  std_ulogic;                
        i_afd_is1_frc_v                     	: in  std_ulogic;
        i_afd_is1_frt_v                     	: in  std_ulogic;
        
        i_afd_is1_prebubble1                     : in  std_ulogic;
        i_afd_is1_est_bubble3                    : in  std_ulogic;

        iu_au_is1_cr_user_v                     : in  std_ulogic;  -- FXU op reads CR
        i_afd_is1_cr_setter                     : in  std_ulogic;  -- FXU op alters CR
        i_afd_is1_cr_writer                     : in  std_ulogic;  -- AXU op alters CR
        
        i_afd_is1_fra                     	: in  std_ulogic_vector(0 to 6);                
        i_afd_is1_frb                     	: in  std_ulogic_vector(0 to 6);                
        i_afd_is1_frc                     	: in  std_ulogic_vector(0 to 6);    
        i_afd_is1_frt                     	: in  std_ulogic_vector(0 to 6);
        i_afd_is1_fra_buf                       : in  std_ulogic_vector(1 to 6);  
        i_afd_is1_frb_buf                       : in  std_ulogic_vector(1 to 6);  
        i_afd_is1_frc_buf                       : in  std_ulogic_vector(1 to 6);  
        i_afd_is1_frt_buf                       : in  std_ulogic_vector(1 to 6);  
        
        i_afd_is1_ifar                     	: in  std_ulogic_vector(56 to 61);
                
        i_afd_is1_instr_ldst_v                  : in  std_ulogic;                
        i_afd_is1_instr_ld_v                    : in  std_ulogic;                         
        i_afd_is1_instr_sto_v                   : in  std_ulogic;  

        ---------------------------------------------------------------------

        i_afi_is2_take                          : in  std_ulogic;
        
        -- LMQ signals
        ---------------------------------------------------------------------
        xu_au_loadmiss_vld                        : in std_ulogic;  
        xu_au_loadmiss_qentry                     : in std_ulogic_vector(0 to lmq_entries-1);
        xu_au_loadmiss_target                     : in std_ulogic_vector(0 to 8);
        xu_au_loadmiss_target_type                : in std_ulogic_vector(0 to 1);

        xu_au_loadmiss_complete_vld               : in std_ulogic;  
        xu_au_loadmiss_complete_qentry            : in std_ulogic_vector(0 to lmq_entries-1);
        xu_au_loadmiss_complete_type              : in std_ulogic_vector(0 to 1);  
        
        -- AXU signals
        ---------------------------------------------------------------------
        iu_au_is1_hold                            : in  std_ulogic;

        iu_au_is1_instr_match                     : in  std_ulogic; 
        
        iu_au_is2_stall                           : in  std_ulogic;  

        xu_iu_is2_flush                           : in  std_ulogic;  
        
        iu_au_is1_flush                           : in  std_ulogic;             
        iu_au_is2_flush                           : in  std_ulogic;
        iu_au_rf0_flush                           : in  std_ulogic;
        iu_au_rf1_flush                           : in  std_ulogic;
        iu_au_ex1_flush                           : in  std_ulogic;
        iu_au_ex2_flush                           : in  std_ulogic;
        iu_au_ex3_flush                           : in  std_ulogic;
        iu_au_ex4_flush                           : in  std_ulogic;
        iu_au_ex5_flush                           : in  std_ulogic;
        
        au_iu_is1_dep_hit                         : out std_ulogic;
        au_iu_is1_dep_hit_b                       : out std_ulogic;
            
        au_iu_is2_issue_stall                     : out std_ulogic;
        ---------------------------------------------------------------------

        i_axu_is1_early_v                       : out std_ulogic;
        
        i_axu_is2_instr_v                       : out std_ulogic;

        i_axu_is2_instr_match                   : out std_ulogic; 
        ---------------------------------------------------------------------

        i_axu_is2_fra                     	: out  std_ulogic_vector(0 to 6);
        i_axu_is2_frb                     	: out  std_ulogic_vector(0 to 6);
        i_axu_is2_frc                     	: out  std_ulogic_vector(0 to 6);
        i_axu_is2_frt                     	: out  std_ulogic_vector(0 to 6);
        
        i_axu_is2_fra_v                   	: out  std_ulogic;
        i_axu_is2_frb_v                     	: out  std_ulogic;
        i_axu_is2_frc_v                     	: out  std_ulogic;

                   
        ---------------------------------------------------------------------
        fu_iu_uc_special                        : in std_ulogic;

        iu_fu_ex2_n_flush                       : out std_ulogic;
        
        ---------------------------------------------------------------------

        ifdp_is2_est_bubble3                    : out std_ulogic;
        ifdp_ex5_fmul_uc_complete               : out std_ulogic;        
        ifdp_is2_bypsel                         : out std_ulogic_vector(0 to 5);

        i_afd_ignore_flush_is1                  : in  std_ulogic;
        i_afd_ignore_flush_is2                  : out std_ulogic;

        i_afd_is1_divsqrt                        : in  std_ulogic; 
        i_afd_is1_stall_rep                      : in  std_ulogic; 
        
        i_afd_fmul_uc_is1                       : in  std_ulogic;
        i_afd_in_ucode_mode_or1d                : in  std_ulogic; 
        i_afd_in_ucode_mode_or1d_b              : out std_ulogic; 
                
        fu_dep_debug                            : out std_ulogic_vector(0 to 23);
        au_iu_is2_axubusy                       : out std_ulogic   -- for single step
       
                
        );

  -- synopsys translate_off

  -- synopsys translate_on

    
end iuq_axu_fu_dep;

--------------------------------------------------------------------------------------------------------------------------------------------------------

architecture iuq_axu_fu_dep of iuq_axu_fu_dep is

signal  tidn                           : std_ulogic;
signal  tiup                           : std_ulogic;

signal  is1_ex6_a_bypass, is1_ex6_b_bypass, is1_ex6_c_bypass    : std_ulogic;

signal  spare_unused : std_ulogic_vector(00 to 58);
signal iucr2_ss_ignore_flush,disable_cgat       : std_ulogic;

signal lm_tar        : std_ulogic_vector(0 to 5);
signal lm0_valid     : std_ulogic;
signal lm0_valid_din : std_ulogic;
signal lm0_ta        : std_ulogic_vector(0 to 5);
signal lm0_ta_din    : std_ulogic_vector(0 to 5);
signal lm1_valid     : std_ulogic;
signal lm1_valid_din : std_ulogic;
signal lm1_ta        : std_ulogic_vector(0 to 5);
signal lm1_ta_din    : std_ulogic_vector(0 to 5);
signal lm2_valid     : std_ulogic;
signal lm2_valid_din : std_ulogic;
signal lm2_ta        : std_ulogic_vector(0 to 5);
signal lm2_ta_din    : std_ulogic_vector(0 to 5);
signal lm3_valid     : std_ulogic;
signal lm3_valid_din : std_ulogic;
signal lm3_ta        : std_ulogic_vector(0 to 5);
signal lm3_ta_din    : std_ulogic_vector(0 to 5);
signal lm4_valid     : std_ulogic;
signal lm4_valid_din : std_ulogic;
signal lm4_ta        : std_ulogic_vector(0 to 5);
signal lm4_ta_din    : std_ulogic_vector(0 to 5);
signal lm5_valid     : std_ulogic;
signal lm5_valid_din : std_ulogic;
signal lm5_ta        : std_ulogic_vector(0 to 5);
signal lm5_ta_din    : std_ulogic_vector(0 to 5);
signal lm6_valid     : std_ulogic;
signal lm6_valid_din : std_ulogic;
signal lm6_ta        : std_ulogic_vector(0 to 5);
signal lm6_ta_din    : std_ulogic_vector(0 to 5);
signal lm7_valid     : std_ulogic;
signal lm7_valid_din : std_ulogic;
signal lm7_ta        : std_ulogic_vector(0 to 5);
signal lm7_ta_din    : std_ulogic_vector(0 to 5);

signal lmiss_qentry    :  std_ulogic_vector(0 to 7);
signal lmiss_complete  :  std_ulogic_vector(0 to 7);
signal lmiss_comp_v    : std_ulogic;
signal lmiss_comp, lmiss_comp_ex0, lmiss_comp_ex1, lmiss_comp_ex2, lmiss_comp_ex3  :  std_ulogic_vector(0 to 7);

signal lmiss_comp_ex1_latch_scout, lmiss_comp_ex1_latch_scin  :  std_ulogic_vector(0 to 7);
signal lmiss_comp_ex2_latch_scout, lmiss_comp_ex2_latch_scin  :  std_ulogic_vector(0 to 7);
signal lmiss_comp_ex3_latch_scout, lmiss_comp_ex3_latch_scin  :  std_ulogic_vector(0 to 7);
signal lmc_ex4_latch_scin, lmc_ex4_latch_scout  :  std_ulogic_vector(0 to 6);
signal lmc_ex5_latch_scin, lmc_ex5_latch_scout  :  std_ulogic;                
signal lmc_ex6_latch_scin, lmc_ex6_latch_scout  :  std_ulogic;                

           
signal is1_cancel_bypass : std_ulogic;
signal is1_bypsel : std_ulogic_vector(0 to 5);
signal is2_bypsel : std_ulogic_vector(0 to 5);

signal spare_l2 : std_ulogic_vector(0 to 4);

signal is2_frt_v_din, rf1_frt_v_din, rf0_frt_v_din   : std_ulogic; 
signal ex1_frt_v_din, ex2_frt_v_din, ex3_frt_v_din: std_ulogic;
signal disable_bypass_chicken_switch,  dis_byp_is1: std_ulogic;
signal is1_ld_v, is1_ld_v_din : std_ulogic;
signal is2_ld_v, is2_ld_v_din : std_ulogic;
signal rf0_ld_v_din : std_ulogic;
signal rf1_ld_v_din : std_ulogic;
signal ex1_ld_v_din : std_ulogic;
signal ex2_ld_v_din : std_ulogic;
signal ex3_ld_v_din : std_ulogic;

signal rf0_ld_v : std_ulogic;
signal rf1_ld_v : std_ulogic;
signal ex1_ld_v, ex2_ld_v, ex3_ld_v, ex4_ld_v: std_ulogic;


signal bubble3_is1, bubble3_is2                : std_ulogic;
signal bubble3_rf0, bubble3_rf1, bubble3_ex1   : std_ulogic;

signal bubble3_is1_db             : std_ulogic;

signal bubble3_is2_din                : std_ulogic;
signal bubble3_rf0_din, bubble3_rf1_din   : std_ulogic;


signal is1_fra : std_ulogic_vector(0 to 5);
signal is1_frb : std_ulogic_vector(0 to 5);
signal is1_frc : std_ulogic_vector(0 to 5);

signal is2_fra : std_ulogic_vector(0 to 5);
signal is2_frb : std_ulogic_vector(0 to 5);
signal is2_frc : std_ulogic_vector(0 to 5);
 
signal         is1_ldst_v                   	:  std_ulogic ;     
signal is2_act, rf0_act, rf1_act, ex1_act, ex2_act, ex3_act : std_ulogic;
signal is2_act_l2, rf0_act_l2, rf1_act_l2, ex1_act_l2, ex2_act_l2, ex3_act_l2 : std_ulogic;
signal is2_act_din, rf0_act_din, rf1_act_din, ex1_act_din, ex2_act_din, ex3_act_din : std_ulogic;

signal is1_fra_v : std_ulogic;
signal is1_frb_v : std_ulogic;
signal is1_frc_v : std_ulogic;
signal is1_crs_v : std_ulogic;

signal is2_fra_v : std_ulogic;
signal is2_frb_v : std_ulogic;
signal is2_frc_v : std_ulogic;

signal is1_prebubble_skip : std_ulogic;

signal is1_frt_v : std_ulogic;
signal is2_frt_v : std_ulogic;
signal rf0_frt_v : std_ulogic;
signal rf1_frt_v : std_ulogic;
signal ex1_frt_v, ex2_frt_v, ex3_frt_v, ex4_frt_v: std_ulogic;

signal  ex3_frt_v_forbyp : std_ulogic;

signal is1_instr_v : std_ulogic;
signal is2_instr_v : std_ulogic;
signal rf0_instr_v : std_ulogic;
signal rf1_instr_v : std_ulogic;
signal ex1_instr_v, ex2_instr_v, ex3_instr_v, ex4_instr_v, ex5_instr_v, ex6_instr_v : std_ulogic;

signal is1_instr_v_din : std_ulogic;
signal is2_instr_v_din : std_ulogic;
signal rf0_instr_v_din : std_ulogic;
signal rf1_instr_v_din : std_ulogic;
signal ex1_instr_v_din, ex2_instr_v_din, ex3_instr_v_din, ex4_instr_v_din, ex5_instr_v_din: std_ulogic;

signal is1_fmul_uc_din : std_ulogic;
signal is2_fmul_uc_din : std_ulogic;
signal rf0_fmul_uc_din : std_ulogic;
signal rf1_fmul_uc_din : std_ulogic;
signal ex1_fmul_uc_din, ex2_fmul_uc_din, ex3_fmul_uc_din, ex4_fmul_uc_din, ex5_fmul_uc_din: std_ulogic;
signal is1_fmul_uc : std_ulogic;
signal is2_fmul_uc : std_ulogic;
signal rf0_fmul_uc : std_ulogic;
signal rf1_fmul_uc : std_ulogic;
signal ex1_fmul_uc, ex2_fmul_uc, ex3_fmul_uc, ex4_fmul_uc, ex5_fmul_uc: std_ulogic;


signal is1_lmq_waw_hit, is1_lmq_waw_hit_b, is1_waw_cr_hit : std_ulogic;

signal is1_ta : std_ulogic_vector(0 to 5);
signal is2_ta : std_ulogic_vector(0 to 5);
signal rf0_ta : std_ulogic_vector(0 to 5);
signal rf1_ta : std_ulogic_vector(0 to 5);
signal ex1_ta : std_ulogic_vector(0 to 5);
signal ex2_ta : std_ulogic_vector(0 to 5);
signal ex3_ta : std_ulogic_vector(0 to 5);
signal ex4_ta : std_ulogic_vector(0 to 5);



signal is1_crt_v, is1_crt_v_din: std_ulogic;
signal is2_crt_v, is2_crt_v_din: std_ulogic;
signal rf0_crt_v, rf0_crt_v_din: std_ulogic;
signal rf1_crt_v, rf1_crt_v_din: std_ulogic;
signal ex1_crt_v, ex1_crt_v_din: std_ulogic;
signal ex2_crt_v, ex2_crt_v_din: std_ulogic;
signal ex3_crt_v, ex3_crt_v_din: std_ulogic;
signal ex4_crt_v: std_ulogic;

signal raw_cr_hit : std_ulogic;
signal is1_store_v : std_ulogic;
signal raw_fra_hit, raw_frb_hit, raw_frc_hit, is1_raw_hit, is1_dep_hit: std_ulogic;
signal raw_fra_hit_b, raw_frb_hit_b, raw_frc_hit_b, is1_dep_hit_b, is1_dep_hit_buf1,is1_dep_hit_buf2_b : std_ulogic;
signal is1_waw_load_hit  : std_ulogic;
signal stall_is2_b : std_ulogic;
signal stall_is2   : std_ulogic;

signal is1_stage_din, is1_stage_din_premux  : std_ulogic_vector(0 to 42);
signal is2_stage_dout_premux          : std_ulogic_vector(0 to 42);
signal is2_stage_dout : std_ulogic_vector(0 to 42);
signal is2_stage_latch_scin : std_ulogic_vector(0 to 42);
signal is2_stage_latch_scout : std_ulogic_vector(0 to 42);

signal is2_instr_ldst_v : std_ulogic;
signal is2_bypass_latch_scin, is2_bypass_latch_scout : std_ulogic_vector(0 to 5);
signal rf0_sp_latch_scin, rf0_sp_latch_scout   : std_ulogic_vector(0 to 14);
signal rf1_sp_latch_scin, rf1_sp_latch_scout   : std_ulogic_vector(0 to 14);
signal ex1_sp_latch_scin, ex1_sp_latch_scout   : std_ulogic_vector(0 to 14);
signal ex2_sp_latch_scin, ex2_sp_latch_scout   : std_ulogic_vector(0 to 13);
signal ex3_sp_latch_scin, ex3_sp_latch_scout   : std_ulogic_vector(0 to 13);
signal ex4_sp_latch_scin, ex4_sp_latch_scout   : std_ulogic_vector(0 to 12);
signal ex5_sp_latch_scin, ex5_sp_latch_scout   : std_ulogic_vector(0 to 10);
signal ex6_sp_latch_scin, ex6_sp_latch_scout   : std_ulogic_vector(0 to 1);
signal busy_latch_scin, busy_latch_scout   : std_ulogic_vector(0 to 2);
signal act_latch_scin, act_latch_scout   : std_ulogic_vector(0 to 7);

signal lmq0_latch_scin,lmq0_latch_scout  : std_ulogic_vector(0 to 6);
signal lmq1_latch_scin,lmq1_latch_scout  : std_ulogic_vector(0 to 6);
signal lmq2_latch_scin,lmq2_latch_scout  : std_ulogic_vector(0 to 6);
signal lmq3_latch_scin,lmq3_latch_scout  : std_ulogic_vector(0 to 6);
signal lmq4_latch_scin,lmq4_latch_scout  : std_ulogic_vector(0 to 6);
signal lmq5_latch_scin,lmq5_latch_scout  : std_ulogic_vector(0 to 6);
signal lmq6_latch_scin,lmq6_latch_scout  : std_ulogic_vector(0 to 6);
signal lmq7_latch_scin,lmq7_latch_scout  : std_ulogic_vector(0 to 6);

signal is1_cmiss_flush              : std_ulogic; 
signal is2_cmiss_flush              : std_ulogic;
signal is2_cmiss_flush_q            : std_ulogic;
signal is2_cmiss_flush_din          : std_ulogic;
signal rf0_cmiss_flush              : std_ulogic;
signal rf1_cmiss_flush              : std_ulogic;
signal ex1_cmiss_flush              : std_ulogic;
signal ex2_cmiss_flush              : std_ulogic;
signal rf0_cmiss_flush_din          : std_ulogic;
signal rf1_cmiss_flush_din          : std_ulogic;
signal ex1_cmiss_flush_din          : std_ulogic;

signal rf0_cmiss_waw_flush          : std_ulogic;
signal rf1_cmiss_waw_flush          : std_ulogic;
signal ex1_cmiss_waw_flush          : std_ulogic;

signal ignore_flush_is1, ignore_flush_is2  : std_ulogic;
signal ignore_flush_rf0, ignore_flush_rf1  : std_ulogic;
signal ignore_flush_ex1, ignore_flush_ex2  : std_ulogic;
signal ignore_flush_ex3, ignore_flush_ex4  : std_ulogic;
signal ignore_flush_ex5, ignore_flush_ex6  : std_ulogic;

signal ignore_flush_rf0_din, ignore_flush_rf1_din  : std_ulogic;
signal ignore_flush_ex1_din, ignore_flush_ex2_din  : std_ulogic;
signal ignore_flush_ex3_din, ignore_flush_ex4_din  : std_ulogic;
signal ignore_flush_ex5_din, ignore_flush_is2_din  : std_ulogic;




signal is1_hold_v_b          : std_ulogic;
signal is1_WAW_CRorLDhit_b          : std_ulogic;
signal is1_allbut_RAW    : std_ulogic;
signal is1_raw_hit_b   : std_ulogic;

signal debug_scin  :std_ulogic_vector(0 to 15);
signal debug_scout :std_ulogic_vector(0 to 15);

signal uc_rc_ld             :std_ulogic;                                       
signal uc_rc_l2             :std_ulogic;                                       
signal uc_end_is1           :std_ulogic;                                       
signal ppc_rc_latch_scin    :std_ulogic; 
signal ppc_rc_latch_scout   :std_ulogic;
signal raw_frb_uc_hit_b, raw_frb_uc_hit   :std_ulogic;
signal is1_dep_hit_db           :std_ulogic;
signal is1_raw_hit_db           :std_ulogic;
signal raw_fra_hit_db           :std_ulogic;       
signal raw_frb_hit_db           :std_ulogic;
signal raw_frc_hit_db           :std_ulogic;
signal is1_prebubble_skip_db    :std_ulogic;
signal is1_instr_v_din_db           :std_ulogic;
signal raw_cr_hit_db            :std_ulogic;               
signal      is1_raw_hit_earlystuff_b  :std_ulogic; 
signal is1_lmq_waw_hit_db       :std_ulogic;        
signal is1_waw_load_hit_db      :std_ulogic;  
signal iu_au_is1_hold_db        :std_ulogic;
signal iu_au_is2_stall_db       :std_ulogic;
signal iu_au_is1_flush_db       :std_ulogic;
signal iu_au_is2_flush_db       :std_ulogic;
signal iu_au_rf0_flush_db       :std_ulogic;       

signal lmiss_comp_type                                 :std_ulogic_vector(0 to 1);

signal lm_v                                            :std_ulogic_vector(0 to 7);
signal set_lm0, set_lm0_1d, clear_lm0   :std_ulogic;
signal set_lm1, set_lm1_1d, clear_lm1   :std_ulogic;
signal set_lm2, set_lm2_1d, clear_lm2   :std_ulogic;
signal set_lm3, set_lm3_1d, clear_lm3   :std_ulogic;
signal set_lm4, set_lm4_1d, clear_lm4   :std_ulogic;
signal set_lm5, set_lm5_1d, clear_lm5   :std_ulogic;
signal set_lm6, set_lm6_1d, clear_lm6   :std_ulogic;
signal set_lm7, set_lm7_1d, clear_lm7   :std_ulogic;


signal  lmc_ex3, lmc_ex4                :std_ulogic_vector(0 to 5);
signal  lmc_ex3_v, lmc_ex4_v, lmc_ex5_v, lmc_ex6_v            :std_ulogic;

signal is1_ld6_a_bypass, is1_ld6_b_bypass, is1_ld6_c_bypass   :std_ulogic;

signal ppc_div_sqrt_is1                                :std_ulogic;

signal fu_busy,fu_busy_l2                              :std_ulogic;

signal is1_to_ucode, is1_is_ucode, is1_singlestep_ucode ,is1_singlestep_pn ,      is1_singlestep               :std_ulogic;
signal config_iucr              :std_ulogic_vector(1 to 7);
signal is2_axubusy, fmul_uc_busy, fmul_uc_busy_l2, ignore_flush_busy, ignore_flush_busy_l2, is2_ignore_flush_busy        :std_ulogic;

signal is1_stall_rep_b, is1_stall_rep, uc_rc_adv, uc_rc_go_b, uc_rc_ho_b      :std_ulogic;





 






  


    
begin




tidn      <= '0';
tiup      <= '1';
    
-- ############################################


spare_unused(49)       <= d_mode;
spare_unused(43 to 48) <= i_afd_is1_fra_buf(1 to 6); 
spare_unused(37 to 42) <= i_afd_is1_frb_buf(1 to 6); 
spare_unused(31 to 36) <= i_afd_is1_frc_buf(1 to 6); 
spare_unused(25 to 30) <= i_afd_is1_frt_buf(1 to 6); 
spare_unused(24)       <= i_afd_is1_instr_sto_v;

spare_unused(18 to 22) <= i_afd_is1_instr(26 to 30);
spare_unused(17)       <= i_afd_is1_fra(0);
spare_unused(16)       <= i_afd_is1_frb(0);
spare_unused(15)       <= i_afd_is1_frc(0);

spare_unused(23)       <= tidn; 
spare_unused(11)       <= tidn; 
spare_unused(12)       <= tidn; 
spare_unused(13)       <= tidn; 

-- ############################################

uc_end_is1 <= is1_fmul_uc and is1_instr_v;
spare_unused(50 to 55) <= i_afd_is1_ifar(56 to 61);




   is1_stall_rep_b <= not i_afd_is1_stall_rep ;
   is1_stall_rep   <= i_afd_is1_stall_rep ;  
   -- hold on to the original rc bit
   uc_rc_adv       <= (i_afd_is1_divsqrt and i_afd_is1_instr(31)) or (not i_afd_is1_divsqrt and uc_rc_l2);

   
uc_rc_go:   uc_rc_go_b <= not( is1_stall_rep_b and uc_rc_adv );
uc_rc_ho:   uc_rc_ho_b <= not( is1_stall_rep   and uc_rc_l2  );
uc_rc_do:   uc_rc_ld   <= not( uc_rc_go_b and uc_rc_ho_b );
 

  ppc_rc_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset, width => 1)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin(0)     => ppc_rc_latch_scin,
      scout(0)    => ppc_rc_latch_scout,
      ---------------------------------------------
      din(0)   => uc_rc_ld,
      ---------------------------------------------
      dout(0)  => uc_rc_l2
      ---------------------------------------------
    );



-- sig reassign for portability
is1_ta(0 to 5) <= i_afd_is1_frt(1 to 6);  -- bit 1 is the ucode bit


is1_frt_v <= i_afd_is1_frt_v;

is1_fra(0 to 5) <= i_afd_is1_fra(1 to 6);-- bit 1 is the ucode bit

is1_frb(0 to 5) <= i_afd_is1_frb(1 to 6);-- bit 1 is the ucode bit

is1_frc(0 to 5) <= i_afd_is1_frc(1 to 6);-- bit 1 is the ucode bit




is1_fra_v <= i_afd_is1_fra_v;
is1_frb_v <= i_afd_is1_frb_v;  
is1_frc_v <= i_afd_is1_frc_v;

is1_crs_v <= iu_au_is1_cr_user_v;       -- FXU op reads CR
is1_crt_v <= i_afd_is1_cr_writer or (uc_end_is1 and uc_rc_l2);  -- AXU cr writer op

  
is1_instr_v <= i_afd_is1_instr_v;  

bubble3_is1 <= i_afd_is1_est_bubble3;
  

config_iucr(1) <= i_afd_config_iucr(1);  --IUCR2(33) DISBYP
config_iucr(2) <= i_afd_config_iucr(2);  --IUCR2(34) SSAXU
config_iucr(3) <= i_afd_config_iucr(3);  --IUCR2(35) SSUC
config_iucr(4) <= i_afd_config_iucr(4);  --IUCR2(36) RESERVED FOR BGQ (disable store bypass)
config_iucr(5) <= i_afd_config_iucr(5);  --IUCR2(37) DISCGAT (disable clock gating in IU_AXU)
config_iucr(6) <= i_afd_config_iucr(6);  --IUCR2(38) SSFDIVPN (PROPOSED, single step fdiv* and fsqrt* prenorms)
config_iucr(7) <= i_afd_config_iucr(7);  --IUCR2(39) RESERVED FOR BGQ

spare_unused(56) <= config_iucr(4);
iucr2_ss_ignore_flush <= config_iucr(6);
spare_unused(57) <= config_iucr(7);
 disable_cgat <= config_iucr(5);
spare_unused(58) <= disable_cgat;

-----------------------------------------------------------------------
-- RAW

----------------------------------------------------
--and regular bypass is ex6-rf1, loads ex7-rf1
--ok. writethru for math is ex6-rf0, loads ex7-rf0

-- Math Bypass/Writethru                    Load Bypass/Writethru
--
-- IS1   <-\            fadd stfd          IS1   <-\              fadd stfd
-- IS2     |                               IS2     |
-- RF0<-\WT|  fadd stfd                    RF0<-\WT|    fadd stfd
-- RF1<-\BP|  fadd xxxx                    RF1<-\BP|    fadd xxxx
-- EX1  |  |                               EX1  |  |
-- EX2  |  |                               EX2  |  |
-- EX3  |>-/BYP         fadd xxxx          EX3  |  |
-- EX4  |>-/WT          fadd fadd          EX4  |>-/BYP           lfd  xxxx
-- EX5  |                                  EX5  |>-/WT            lfd  lfd
-- EX6>-/     fadd fadd                    EX6  |
-- EX7                                     EX7>-/       lfd  lfd

-- dis_byp_is1 will shut off bypasses and WT cases for math target writers, but for loads, WT is allowed.


  
                     
        

axu_raw_cmp: entity work.iuq_axu_fu_dep_cmp(iuq_axu_fu_dep_cmp) 
port map (
     vdd            => vdd,
     gnd            => gnd,
     lm_v           => lm_v,
     is1_instr_v    => is1_instr_v,
     lmc_ex4_v      =>   lmc_ex4_v,   
     dis_byp_is1    =>   dis_byp_is1,
     is1_store_v    =>   is1_store_v,     
     ex3_ld_v       =>   ex3_ld_v ,
     ex4_ld_v       =>   ex4_ld_v ,     
     uc_end_is1     =>   uc_end_is1 , 
                                   
     is2_frt_v      =>   is2_frt_v,   
     rf0_frt_v      =>   rf0_frt_v,   
     rf1_frt_v      =>   rf1_frt_v,   
     ex1_frt_v      =>   ex1_frt_v,   
     ex2_frt_v      =>   ex2_frt_v,   
     ex3_frt_v      =>   ex3_frt_v,   
     ex4_frt_v      =>   ex4_frt_v,   
     lm0_ta         => lm0_ta,        
     lm1_ta         => lm1_ta,        
     lm2_ta         => lm2_ta,        
     lm3_ta         => lm3_ta,        
     lm4_ta         => lm4_ta,        
     lm5_ta         => lm5_ta,        
     lm6_ta         => lm6_ta,        
     lm7_ta         => lm7_ta,        
     lmc_ex4        => lmc_ex4,       
     ex4_ta         => ex4_ta ,       
     ex3_ta         => ex3_ta ,       
     ex2_ta         => ex2_ta ,       
     ex1_ta         => ex1_ta ,       
     rf1_ta         => rf1_ta ,       
     rf0_ta         => rf0_ta ,       
     is2_ta         => is2_ta ,       

     is1_fra_v      => is1_fra_v,
     is1_frb_v      => is1_frb_v,
     is1_frc_v      => is1_frc_v,
     is1_frt_v      => is1_frt_v,     
     
     is1_fra        => is1_fra ,      
     is1_frb        => is1_frb ,      
     is1_frc        => is1_frc ,      
     is1_ta         => is1_ta   ,     
                                     
     raw_fra_hit_b    => raw_fra_hit_b ,
     raw_frb_hit_b    => raw_frb_hit_b ,
     raw_frc_hit_b    => raw_frc_hit_b ,
     raw_frb_uc_hit_b => raw_frb_uc_hit_b,
     is1_lmq_waw_hit_b => is1_lmq_waw_hit_b
      
);

   raw_fra_hit <= not raw_fra_hit_b; 
   raw_frb_hit <= not raw_frb_hit_b; 
   raw_frc_hit <= not raw_frc_hit_b;

   
-- FXU read CR, AXU write CR dependency for fcmp* (AXU does not read the CR)
-- (bubble3's are 3 cycles longer)
-- IS1   >-\
-- IS2     |
-- RF0     |
-- RF1>-\  |
-- EX1  |  |
-- EX2  |<-/
-- EX3  |
-- EX4  |
-- EX5<-/
-- EX6

raw_cr_hit  <= is1_crs_v and ((is2_crt_v and is2_instr_v)  or
                              (rf0_crt_v and rf0_instr_v)  or
                              (rf1_crt_v and rf1_instr_v)  or
                              (ex1_crt_v and ex1_instr_v)  or  
                              (ex2_crt_v and ex2_instr_v)  or  -- these stages, ex2,ex3,ex4 are only active for bubble3 instrs
                              (ex3_crt_v and ex3_instr_v)  or
                              (ex4_crt_v and ex4_instr_v) );
                                                                                                                      
  
                                                                                                                      
  

is1_raw_hit_earlystuff_b <= not ((is1_instr_v and (is1_prebubble_skip or is1_singlestep)) or raw_cr_hit);

axudep_rawhit_nand4:   is1_raw_hit <= not(raw_fra_hit_b and raw_frb_hit_b and raw_frc_hit_b and is1_raw_hit_earlystuff_b);

is1_prebubble_skip <= i_afd_is1_prebubble1 and is2_instr_v;

    -- is1_prebubble_skip is meant to hold off issueing an instruction for a cycle based on the instruction.
    -- currently, this is used for mffs instructions, since the fpscr is updated in ex7 we need to make sure
    -- nothing is updating the fpscr while its being read.
-----------------------------------------------------------------------
-- WAW


-- everything is an ex6 exit except for loads, which are ex7
-- This is redundant due to the waw_load_hit logic below
-- is1_waw_hit <= ((is1_frt_v and is1_instr_v and not is1_ld_v) and (is2_frt_v and is2_instr_v and is2_ld_v) and (is1_ta = is2_ta));

-- this is fxu cr write following fpu cr write (like rc=1) bubble3 indicates fpu cr writer
-- bubble3 instructions write in essentially ex8, but they write the ex4 CR bus.  So the below
-- ensures we don't write out of order.
is1_waw_cr_hit     <= i_afd_is1_cr_setter and (bubble3_is2 or bubble3_rf0 or bubble3_rf1); 


-- WAWs involving loads need additional protection.  Cache misses occur in stage ex4 and LMQ reflects them in ex5.
-- Instructions with WAWs dependencies on loads will be stalled in is1 until the load is in rf1.
-- After that the LMQ would continue the stall if necessary, or cmiss_flush if already issued
-- Instructions in is0 when the load is in ex4 are protected by the LMQ from the beginning.
is1_waw_load_hit <= (is1_frt_v and is2_frt_v and is2_ld_v and (is2_ta = is1_ta)) or
                    (is1_frt_v and rf0_frt_v and rf0_ld_v and (rf0_ta = is1_ta)) ;

-----------------------------------------------------------------------






is1_lmq_waw_hit <= not is1_lmq_waw_hit_b;

axudep_hold_v_nand2:              is1_hold_v_b <= not (iu_au_is1_hold and is1_instr_v);

axudep_WAW_CRorLDhit_nor2:        is1_WAW_CRorLDhit_b <= not (is1_waw_load_hit or is1_waw_cr_hit);

axudep_allbut_RAW_nand3:           is1_allbut_RAW <= not (is1_lmq_waw_hit_b and is1_WAW_CRorLDhit_b and is1_hold_v_b);

is1_raw_hit_b <= not is1_raw_hit;
spare_unused(10) <= is1_raw_hit_b;

raw_frb_uc_hit <=   not raw_frb_uc_hit_b;
 
axudep_dephit_nor3: is1_dep_hit_b <= not (is1_allbut_RAW or is1_raw_hit or raw_frb_uc_hit);      

axudep_dephit_buf1: is1_dep_hit_buf1 <= not is1_dep_hit_b;
axudep_dephit_buf2: is1_dep_hit_buf2_b <= not is1_dep_hit_buf1;
au_iu_is1_dep_hit_b <= is1_dep_hit_buf2_b;


is1_dep_hit <= not is1_dep_hit_b;

au_iu_is1_dep_hit <=  is1_dep_hit;

------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------
-- shadow pipe logic

-- "exit" is defined as the cycle where the register address and write enable are valid to write to the regfile.
-- latches exist in the bypass macro to ensure that the data can then be read in the following cycle (writethru latches)
-- bypass happens in the same cycle as "exit"

-- instr valids
                
is2_instr_v_din <= is2_instr_v and (not iu_au_is2_flush or ignore_flush_is2);   


rf0_instr_v_din <= rf0_instr_v and not iu_au_rf0_flush;
rf1_instr_v_din <= rf1_instr_v and not iu_au_rf1_flush;     
ex1_instr_v_din <= ex1_instr_v and not iu_au_ex1_flush;
ex2_instr_v_din <= ex2_instr_v and not iu_au_ex2_flush;  
ex3_instr_v_din <= ex3_instr_v and not iu_au_ex3_flush;    
ex4_instr_v_din <= ex4_instr_v and not iu_au_ex4_flush;      
ex5_instr_v_din <= ex5_instr_v and not iu_au_ex5_flush;      

is2_fmul_uc_din <= is2_fmul_uc and is2_instr_v_din and i_afi_is2_take;
rf0_fmul_uc_din <= rf0_fmul_uc and rf0_instr_v_din;
rf1_fmul_uc_din <= rf1_fmul_uc and rf1_instr_v_din;
ex1_fmul_uc_din <= ex1_fmul_uc and ex1_instr_v_din;
ex2_fmul_uc_din <= ex2_fmul_uc and ex2_instr_v_din;
ex3_fmul_uc_din <= ex3_fmul_uc and ex3_instr_v_din;
ex4_fmul_uc_din <= ex4_fmul_uc and ex4_instr_v_din;
ex5_fmul_uc_din <= ex5_fmul_uc and ex5_instr_v_din;

          
bubble3_is2_din <= bubble3_is2 and is2_instr_v_din;
bubble3_rf0_din <= bubble3_rf0 and rf0_instr_v_din;
bubble3_rf1_din <= bubble3_rf1 and rf1_instr_v_din;
      


ignore_flush_is2_din <= ignore_flush_is2 and i_afi_is2_take and not iu_au_is2_flush;
ignore_flush_rf0_din <= ignore_flush_rf0 and not iu_au_rf0_flush;
ignore_flush_rf1_din <= ignore_flush_rf1 and not iu_au_rf1_flush;
ignore_flush_ex1_din <= ignore_flush_ex1 and not iu_au_ex1_flush;
ignore_flush_ex2_din <= ignore_flush_ex2 and not iu_au_ex2_flush;
ignore_flush_ex3_din <= ignore_flush_ex3 and not iu_au_ex3_flush;
ignore_flush_ex4_din <= ignore_flush_ex4 and not iu_au_ex4_flush;
ignore_flush_ex5_din <= ignore_flush_ex5 and not iu_au_ex5_flush;




          
 -- frt valids (target valids are shut off to line up RAW stalls correctly for bypass)
 
                                                  
-- everything is an ex6 exit now, except for loads, which are ex7
is2_frt_v_din <=   is2_frt_v     and (not iu_au_is2_flush or ignore_flush_is2)  and stall_is2_b;
rf0_frt_v_din <=   rf0_frt_v     and  not iu_au_rf0_flush; 
rf1_frt_v_din <=   rf1_frt_v     and  not iu_au_rf1_flush; 
ex1_frt_v_din <=   ex1_frt_v     and  not iu_au_ex1_flush;
ex2_frt_v_din <=   ex2_frt_v     and  not iu_au_ex2_flush;    
ex3_frt_v_din <=   ex3_frt_v     and  not iu_au_ex3_flush;     
                                                


is1_crt_v_din <= is1_crt_v;
is2_crt_v_din <= is2_crt_v;
rf0_crt_v_din <= rf0_crt_v;
rf1_crt_v_din <= rf1_crt_v;
ex1_crt_v_din <= ex1_crt_v and bubble3_ex1;   -- bubble3=1 for rc=1 instructions and mcrfs. bubble3=0 for fcmpu fcmpo ;
ex2_crt_v_din <= ex2_crt_v;                   -- (so ex2_crt_v, ex3_crt_v and ex4_crt_v will only be on for bubble3 instructions)
ex3_crt_v_din <= ex3_crt_v;

                          
------------------------------------------------------------------------------------------------------------------------

-- Load Miss Queue



four_loadmiss_entries :
   if (lmq_entries = 4) generate
   
lmiss_qentry(0 to 3)   <= xu_au_loadmiss_qentry(0 to 3);
lmiss_complete(0 to 3) <= xu_au_loadmiss_complete_qentry(0 to 3);
lmiss_qentry(4 to 7)   <= "0000";
lmiss_complete(4 to 7) <= "0000";


 end generate four_loadmiss_entries;
    
eight_loadmiss_entries :
   if (lmq_entries = 8) generate
   
lmiss_qentry   <= xu_au_loadmiss_qentry;
lmiss_complete <= xu_au_loadmiss_complete_qentry;

 end generate eight_loadmiss_entries;

lmiss_comp_type <= xu_au_loadmiss_complete_type;
lmiss_comp(0 to 7) <= lmiss_complete(0 to 7);
lmiss_comp_v <= xu_au_loadmiss_complete_vld and (lmiss_comp_type = "01"); -- this is equivalent to stage RF1/ex0



lm_tar(0 to 5) <= xu_au_loadmiss_target(3) & xu_au_loadmiss_target(4 to 8);  -- tack on ucode addr bit

lm_v(0 to 7) <= lm0_valid & lm1_valid & lm2_valid & lm3_valid & lm4_valid & lm5_valid & lm6_valid & lm7_valid ;   

set_lm0 <= xu_au_loadmiss_vld and lmiss_qentry(0) and (xu_au_loadmiss_target_type = "01") and not iu_au_ex4_flush;
set_lm1 <= xu_au_loadmiss_vld and lmiss_qentry(1) and (xu_au_loadmiss_target_type = "01") and not iu_au_ex4_flush;
set_lm2 <= xu_au_loadmiss_vld and lmiss_qentry(2) and (xu_au_loadmiss_target_type = "01") and not iu_au_ex4_flush;
set_lm3 <= xu_au_loadmiss_vld and lmiss_qentry(3) and (xu_au_loadmiss_target_type = "01") and not iu_au_ex4_flush;
set_lm4 <= xu_au_loadmiss_vld and lmiss_qentry(4) and (xu_au_loadmiss_target_type = "01") and not iu_au_ex4_flush;
set_lm5 <= xu_au_loadmiss_vld and lmiss_qentry(5) and (xu_au_loadmiss_target_type = "01") and not iu_au_ex4_flush;
set_lm6 <= xu_au_loadmiss_vld and lmiss_qentry(6) and (xu_au_loadmiss_target_type = "01") and not iu_au_ex4_flush;
set_lm7 <= xu_au_loadmiss_vld and lmiss_qentry(7) and (xu_au_loadmiss_target_type = "01") and not iu_au_ex4_flush;

clear_lm0 <= lmiss_comp_ex3(0) or (set_lm0_1d and iu_au_ex5_flush);
clear_lm1 <= lmiss_comp_ex3(1) or (set_lm1_1d and iu_au_ex5_flush);
clear_lm2 <= lmiss_comp_ex3(2) or (set_lm2_1d and iu_au_ex5_flush);
clear_lm3 <= lmiss_comp_ex3(3) or (set_lm3_1d and iu_au_ex5_flush);
clear_lm4 <= lmiss_comp_ex3(4) or (set_lm4_1d and iu_au_ex5_flush);
clear_lm5 <= lmiss_comp_ex3(5) or (set_lm5_1d and iu_au_ex5_flush);
clear_lm6 <= lmiss_comp_ex3(6) or (set_lm6_1d and iu_au_ex5_flush);
clear_lm7 <= lmiss_comp_ex3(7) or (set_lm7_1d and iu_au_ex5_flush);

lmiss_comp_ex0(0) <= (lmiss_comp_v and lmiss_comp(0));
lmiss_comp_ex0(1) <= (lmiss_comp_v and lmiss_comp(1));
lmiss_comp_ex0(2) <= (lmiss_comp_v and lmiss_comp(2));
lmiss_comp_ex0(3) <= (lmiss_comp_v and lmiss_comp(3));
lmiss_comp_ex0(4) <= (lmiss_comp_v and lmiss_comp(4));
lmiss_comp_ex0(5) <= (lmiss_comp_v and lmiss_comp(5));
lmiss_comp_ex0(6) <= (lmiss_comp_v and lmiss_comp(6));
lmiss_comp_ex0(7) <= (lmiss_comp_v and lmiss_comp(7));



-- Q entry 0
lm0_valid_din      <= '1'             when set_lm0 ='1'       else    -- set
                      '0'             when clear_lm0 ='1'     else    -- clear
                       lm0_valid;                                     -- hold
lm0_ta_din(0 to 5) <=  lm_tar(0 to 5) when set_lm0 ='1'       else    -- set
                       lm0_ta(0 to 5);                                -- hold
                                                           
                                                           
lm1_valid_din      <= '1'             when set_lm1 ='1'       else    -- set
                      '0'             when clear_lm1 ='1'     else    -- clear
                       lm1_valid;                                     -- hold
lm1_ta_din(0 to 5) <=  lm_tar(0 to 5) when set_lm1 ='1'       else    -- set
                       lm1_ta(0 to 5);                                -- hold
                                                           
                                                           
lm2_valid_din      <= '1'             when set_lm2 ='1'       else    -- set
                      '0'             when clear_lm2 ='1'     else    -- clear
                       lm2_valid;                                     -- hold
lm2_ta_din(0 to 5) <=  lm_tar(0 to 5) when set_lm2 ='1'       else    -- set
                       lm2_ta(0 to 5);                                -- hold
                                                           
                                                           
lm3_valid_din      <= '1'             when set_lm3 ='1'       else    -- set
                      '0'             when clear_lm3 ='1'     else    -- clear
                       lm3_valid;                                     -- hold
lm3_ta_din(0 to 5) <=  lm_tar(0 to 5) when set_lm3 ='1'       else    -- set
                       lm3_ta(0 to 5);                                -- hold
                                                           
                                                           
lm4_valid_din      <= '1'             when set_lm4 ='1'       else    -- set
                      '0'             when clear_lm4 ='1'     else    -- clear
                       lm4_valid;                                     -- hold
lm4_ta_din(0 to 5) <=  lm_tar(0 to 5) when set_lm4 ='1'       else    -- set
                       lm4_ta(0 to 5);                                -- hold
                                                           
                                                           
lm5_valid_din      <= '1'             when set_lm5 ='1'       else    -- set
                      '0'             when clear_lm5 ='1'     else    -- clear
                       lm5_valid;                                     -- hold
lm5_ta_din(0 to 5) <=  lm_tar(0 to 5) when set_lm5 ='1'       else    -- set
                       lm5_ta(0 to 5);                                -- hold
                                                           
                                                           
lm6_valid_din      <= '1'             when set_lm6 ='1'       else    -- set
                      '0'             when clear_lm6 ='1'     else    -- clear
                       lm6_valid;                                     -- hold
lm6_ta_din(0 to 5) <=  lm_tar(0 to 5) when set_lm6 ='1'       else    -- set
                       lm6_ta(0 to 5);                                -- hold
                                                           
                                                           
lm7_valid_din      <= '1'             when set_lm7 ='1'       else    -- set
                      '0'             when clear_lm7 ='1'     else    -- clear
                       lm7_valid;                                     -- hold
lm7_ta_din(0 to 5) <=  lm_tar(0 to 5) when set_lm7 ='1'       else    -- set
                       lm7_ta(0 to 5);                                -- hold


-- lmiss_comp is equivalent to stage RF1 (10/13/2008)
lmc_ex3(0 to 5)     <=   (lm0_ta(0 to 5) and (0 to 5 => lmiss_comp_ex3(0)))  or                 
                         (lm1_ta(0 to 5) and (0 to 5 => lmiss_comp_ex3(1)))  or
                         (lm2_ta(0 to 5) and (0 to 5 => lmiss_comp_ex3(2)))  or
                         (lm3_ta(0 to 5) and (0 to 5 => lmiss_comp_ex3(3)))  or
                         (lm4_ta(0 to 5) and (0 to 5 => lmiss_comp_ex3(4)))  or
                         (lm5_ta(0 to 5) and (0 to 5 => lmiss_comp_ex3(5)))  or
                         (lm6_ta(0 to 5) and (0 to 5 => lmiss_comp_ex3(6)))  or
                         (lm7_ta(0 to 5) and (0 to 5 => lmiss_comp_ex3(7)));

-- lmiss_comp is equivalent to stage RF1 (10/13/2008)
lmc_ex3_v <= or_reduce(lmiss_comp_ex3(0 to 7));  


   lmiss_comp_ex1_latch : tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset, width => 8)
   port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => lmiss_comp_ex1_latch_scin(0 to 7),
      scout    => lmiss_comp_ex1_latch_scout(0 to 7),
      ---------------------------------------------
      din      => lmiss_comp_ex0,
      ---------------------------------------------
      dout     => lmiss_comp_ex1
      ---------------------------------------------
      );

   lmiss_comp_ex2_latch : tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset, width => 8)
   port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => lmiss_comp_ex2_latch_scin(0 to 7),
      scout    => lmiss_comp_ex2_latch_scout(0 to 7),
      ---------------------------------------------
      din      => lmiss_comp_ex1,
      ---------------------------------------------
      dout     => lmiss_comp_ex2
      ---------------------------------------------
      );

   lmiss_comp_ex3_latch : tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset, width => 8)
   port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => lmiss_comp_ex3_latch_scin(0 to 7),
      scout    => lmiss_comp_ex3_latch_scout(0 to 7),
      ---------------------------------------------
      din      => lmiss_comp_ex2,
      ---------------------------------------------
      dout     => lmiss_comp_ex3
      ---------------------------------------------
      );

   lmc_ex4_latch : tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset, width => 7)
   port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => lmc_ex4_latch_scin(0 to 6),
      scout    => lmc_ex4_latch_scout(0 to 6),
      ---------------------------------------------
      din(0 to 5)      => lmc_ex3(0 to 5),
      din(6)           => lmc_ex3_v,
      ---------------------------------------------
      dout(0 to 5)     => lmc_ex4(0 to 5),
      dout(6)          => lmc_ex4_v
      ---------------------------------------------
      );

   lmc_ex5_latch : tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset, width => 1)
   port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin(0)     => lmc_ex5_latch_scin,           
      scout(0)    => lmc_ex5_latch_scout,         
      ---------------------------------------------
      din(0)           => lmc_ex4_v,
      ---------------------------------------------
      dout(0)              => lmc_ex5_v
      ---------------------------------------------
      );

   lmc_ex6_latch : tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset, width => 1)
   port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin(0)     => lmc_ex6_latch_scin,           
      scout(0)    => lmc_ex6_latch_scout,         
      ---------------------------------------------
      din(0)               => lmc_ex5_v,
      ---------------------------------------------
      dout(0)              => lmc_ex6_v
      ---------------------------------------------
      );



      
------------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------------

is1_fmul_uc <=   i_afd_fmul_uc_is1 ;

is1_fmul_uc_din <= is1_fmul_uc and is1_instr_v_din;

ppc_div_sqrt_is1 <= i_afd_ignore_flush_is1;

is1_to_ucode  <= i_afd_is1_to_ucode;
is1_is_ucode <= i_afd_is1_is_ucode; 

  




-- block ucode on special cases (invalid op, div by 0, etc) except last instruction
-- ppc_div_sqrt_is1 is activated by the fdiv and fsqrt instruction.

is1_instr_v_din <= is1_instr_v
                       and
                   (not is1_dep_hit)
                       and
                   (not iu_au_is1_flush)
                       and
                   (not i_afd_is1_to_ucode or ppc_div_sqrt_is1);      --  to_ucode (e.g. prenorms) dies here unless fdiv or fsqrt


-- Out to Issue for Early IS2 valid.
i_axu_is1_early_v <= is1_instr_v
                       and
                     (not i_afd_is1_to_ucode or ppc_div_sqrt_is1)       --  to_ucode (e.g. prenorms) dies here unless fdiv or fsqrt
                     and not i_afd_is1_instr_ldst_v;
  
is1_ldst_v   <=    i_afd_is1_instr_ldst_v and not is1_dep_hit and not i_afd_is1_to_ucode and not iu_au_is1_flush;

is1_ld_v <= i_afd_is1_instr_ld_v;
spare_unused(14) <= is1_ld_v;

is1_ld_v_din <= i_afd_is1_instr_ld_v and is1_instr_v and not is1_dep_hit and not iu_au_is1_flush and not i_afd_is1_to_ucode;  
is1_store_v <= i_afd_is1_instr_ldst_v and not i_afd_is1_instr_ld_v;

-- can't have back-to-back fdiv or fsqrt.  The flush would be real for the 2nd instr.

ignore_flush_is1 <= (i_afd_is1_divsqrt and not i_afd_is1_stall_rep) and not iu_au_is1_flush;  


spare_unused(00) <= i_afd_is1_frt(0);

is1_stage_din_premux   <= 
                   is1_ta(0 to 5) &         -- 0 to 5
                   is1_ld_v_din &             -- 6
                   i_afd_in_ucode_mode_or1d & -- 7
                   is1_instr_v_din &        -- 8   instruction valid
                   is1_frt_v &              -- 9
                   is1_is_ucode &           -- 10
                   fu_iu_uc_special &       -- 11  unused
                   is1_fmul_uc_din  &       -- 12
                   is1_cmiss_flush &        -- 13
                   is1_raw_hit &            -- 14
                   is1_fra(0 to 5) &        -- 15 to 20
                   tidn &                   -- 21  spare
                   is1_frb(0 to 5) &        -- 22 to 27
                   is1_frc(0 to 5) &        -- 28 to 33
                   ignore_flush_is1 &       -- 34
                   is1_fra_v  &             -- 35
                   is1_frb_v  &             -- 36
                   is1_frc_v  &             -- 37
                   is1_ldst_v        &      -- 38
                   is1_crt_v_din     &      -- 39
                   bubble3_is1       &      -- 40
                   iu_au_is1_instr_match &  -- 41
                   tidn ;                   -- 42   used to wrap is2_cmiss_flush (not spare)

                                      
                   
-- iu_au_is2_stall (from iuq_fxu_dep.vhdl) is ignored by the fu issue logic (iuq_axu_fu_iss.vhdl) during the ppc instructions
-- of div and sqrt, that action is mirrored here
stall_is2 <= iu_au_is2_stall and not (i_afi_is2_take and ignore_flush_is2);    -- ignore_flush_is2 indicates ppc div or sqrt

stall_is2_b <= not stall_is2;

is1_stage_din <=  (is1_stage_din_premux  and (0 to (is1_stage_din'length-1) =>  stall_is2_b))
                               or
                  (is2_stage_dout_premux and (0 to (is1_stage_din'length-1) =>  stall_is2));  -- feedback if stalled


   is2_stage_latch : tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset, width => is2_stage_dout'length)
   port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => is2_stage_latch_scin(0 to ((is2_stage_dout'length)-1)),
      scout    => is2_stage_latch_scout(0 to ((is2_stage_dout'length)-1)),
      ---------------------------------------------
      din            => is1_stage_din,
      ---------------------------------------------
      dout           => is2_stage_dout
      ---------------------------------------------
      );

      is2_stage_dout_premux <= is2_stage_dout(0 to 5) &
                              (is2_stage_dout(6) and (not iu_au_is2_flush or ignore_flush_is2)) &  -- flushing on a stall
                               is2_stage_dout(7) &
                              (is2_stage_dout(8) and (not iu_au_is2_flush or ignore_flush_is2)) &  -- flushing on a stall
                               is2_stage_dout(9 to 41) &
                              (is2_stage_dout(42) or is2_cmiss_flush) ;   

is2_ta(0 to 5) <= is2_stage_dout(0 to 5);
is2_ld_v <=  is2_stage_dout(6);

is2_ld_v_din <= is2_ld_v and is2_instr_v and not iu_au_is2_flush and stall_is2_b;  
rf0_ld_v_din <= rf0_ld_v and rf0_instr_v_din;
rf1_ld_v_din <= rf1_ld_v and rf1_instr_v_din;  
ex1_ld_v_din <= ex1_ld_v and ex1_instr_v_din;
ex2_ld_v_din <= ex2_ld_v and ex2_instr_v_din;  
ex3_ld_v_din <= ex3_ld_v and ex3_instr_v_din;    

i_afd_in_ucode_mode_or1d_b  <=  not is2_stage_dout(7);

is2_instr_v <= is2_stage_dout(8);

is2_frt_v  <= is2_stage_dout(9) and is2_instr_v;


is2_cmiss_flush_q <= is2_stage_dout(13);  -- from is1


i_afd_is2_is_ucode <= is2_stage_dout(10);

is2_crt_v  <= is2_stage_dout(39);

spare_unused(01) <= is2_stage_dout(11); -- fu_iu_uc_special




ifdp_is2_est_bubble3 <= is2_stage_dout(40);
bubble3_is2          <= is2_stage_dout(40);

spare_unused(02) <= is2_stage_dout(14);

i_axu_is2_fra <= tidn & is2_stage_dout(15 to 20);  
i_axu_is2_frb <= tidn & is2_stage_dout(22 to 27);
i_axu_is2_frc <= tidn & is2_stage_dout(28 to 33);
i_axu_is2_frt <= is2_stage_dout(7) & is2_stage_dout(0 to 5);

is2_fra <= is2_stage_dout(15 to 20);
is2_frb <= is2_stage_dout(22 to 27);
is2_frc <= is2_stage_dout(28 to 33);

ignore_flush_is2 <= is2_stage_dout(34) and not xu_iu_is2_flush;  

i_afd_ignore_flush_is2 <= is2_stage_dout(34); 

is2_fra_v <= is2_stage_dout(35);
is2_frb_v <= is2_stage_dout(36);
is2_frc_v <= is2_stage_dout(37);


i_axu_is2_fra_v <=  is2_fra_v;
i_axu_is2_frb_v <=  is2_frb_v;
i_axu_is2_frc_v <=  is2_frc_v;

is2_instr_ldst_v       <= is2_stage_dout(38);
spare_unused(03)       <= is2_stage_dout(21);

i_axu_is2_instr_match <= is2_stage_dout(41);

is2_fmul_uc <= is2_stage_dout(12);
  
 
--------------------------------------
      
au_iu_is2_issue_stall <= (is2_instr_v and not is2_instr_ldst_v) and not i_afi_is2_take;
                         
i_axu_is2_instr_v <= is2_instr_v and not is2_instr_ldst_v;

--------------------------------------
------------------------------------------------------------------------------------------------------------------------



  -----------------------------------------------------------------------
  -- bypass





  disable_bypass_chicken_switch <= config_iucr(1);   

-- this is for the ex6-ex1 FPR bypass
  dis_byp_is1 <= disable_bypass_chicken_switch;  
-- note:  this does not disable the writethru case for loads (EX8->RF1) we can cover that with the single step AXU chicken switches

-- this is for the ex6-ex1 bypass
is1_cancel_bypass <= stall_is2 or dis_byp_is1 or is1_store_v;  


-- arith to arith bypass logic
 is1_ex6_a_bypass <= (is1_fra_v and is1_instr_v_din and ex3_frt_v_forbyp and ex3_instr_v_din and not ex3_ld_v  and (ex3_ta = is1_fra)) and not is1_cancel_bypass;  

 is1_ex6_b_bypass <= (is1_frb_v and is1_instr_v_din and ex3_frt_v_forbyp and ex3_instr_v_din and not ex3_ld_v  and (ex3_ta = is1_frb)) and not is1_cancel_bypass;

 is1_ex6_c_bypass <= (is1_frc_v and is1_instr_v_din and ex3_frt_v_forbyp and ex3_instr_v_din and not ex3_ld_v  and (ex3_ta = is1_frc)) and not is1_cancel_bypass;



-- load to arith bypass logic
is1_ld6_a_bypass <= ((is1_fra_v and is1_instr_v_din and ex4_ld_v  and (ex4_ta = is1_fra)) and not is1_cancel_bypass); --  or  -- load hit
                 -- ((is1_fra_v and is1_instr_v     and lmc_ex3_v and (lmc_ex3 = is1_fra)) and not is1_cancel_bypass);   -- load miss complete

is1_ld6_b_bypass <= ((is1_frb_v and is1_instr_v_din and ex4_ld_v  and (ex4_ta = is1_frb)) and not is1_cancel_bypass); --  or  -- load hit
                 -- ((is1_frb_v and is1_instr_v     and lmc_ex3_v and (lmc_ex3 = is1_frb)) and not is1_cancel_bypass);   -- load miss complete

is1_ld6_c_bypass <= ((is1_frc_v and is1_instr_v_din and ex4_ld_v  and (ex4_ta = is1_frc)) and not is1_cancel_bypass); --   or  -- load hit
                 -- ((is1_frc_v and is1_instr_v     and lmc_ex3_v and (lmc_ex3 = is1_frc)) and not is1_cancel_bypass);   -- load miss complete


is1_bypsel(0) <= is1_ld6_a_bypass; -- ld bypassed to fa ex1
is1_bypsel(1) <= is1_ld6_c_bypass; -- ld bypassed to fc ex1
is1_bypsel(2) <= is1_ld6_b_bypass; -- ld bypassed to fb ex1
                
is1_bypsel(3) <= is1_ex6_a_bypass; -- ex6 bypassed to fa ex1
is1_bypsel(4) <= is1_ex6_c_bypass; -- ex6 bypassed to fc ex1
is1_bypsel(5) <= is1_ex6_b_bypass; -- ex6 bypassed to fb ex1

                
   is2_bypass_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 6)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => is2_bypass_latch_scin,
      scout    => is2_bypass_latch_scout,
      ---------------------------------------------
      din(0 to 5)   => is1_bypsel,
      ---------------------------------------------
      dout(0 to 5)  => is2_bypsel
      ---------------------------------------------
    );

       ifdp_is2_bypsel <= is2_bypsel;

--

 -----------------------------------------------------------------------
 -- latches for clock gating/timing


is2_act_din <= is2_instr_v or disable_cgat;
rf0_act_din <= rf0_instr_v or disable_cgat;
rf1_act_din <= rf1_instr_v or disable_cgat;
ex1_act_din <= ex1_instr_v or disable_cgat;
ex2_act_din <= ex2_instr_v or disable_cgat;
ex3_act_din <= ex3_instr_v or disable_cgat;

 
    act_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 8)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => act_latch_scin,
      scout    => act_latch_scout,
      ---------------------------------------------
      din(0)       => is2_act_din,
      din(1)       => rf0_act_din,
      din(2)       => rf1_act_din,
      din(3)       => ex1_act_din,
      din(4)       => ex2_act_din,
      din(5)       => ex3_act_din,
      din(6)       => spare_l2(3),
      din(7)       => spare_l2(4),
             
      ---------------------------------------------
      dout(0)      => is2_act_l2,
      dout(1)      => rf0_act_l2,
      dout(2)      => rf1_act_l2,
      dout(3)      => ex1_act_l2,      
      dout(4)      => ex2_act_l2,
      dout(5)      => ex3_act_l2,
      dout(6)      => spare_l2(3),
      dout(7)      => spare_l2(4)
      
      ---------------------------------------------
      );

 -----------------------------------------------------------------------


-- shadow pipe staging

is2_act <= is2_instr_v or is2_act_l2;

   rf0_sp_latch : tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 15)
   port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => is2_act,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => rf0_sp_latch_scin(0 to 14),
      scout    => rf0_sp_latch_scout(0 to 14),
      ---------------------------------------------
      din(0 to 5)  => is2_ta(0 to 5),
      din(6)       => is2_ld_v_din,  
      din(7)       => spare_l2(0),
      din(8)       => is2_instr_v_din,
      din(9)       => is2_frt_v_din,
      din(10)      => is2_fmul_uc_din,
      din(11)      => is2_crt_v_din,
      din(12)      => bubble3_is2_din, 
      din(13)      => is2_cmiss_flush_din,  -- flush due to waw with cmiss
      din(14)      => ignore_flush_is2_din,           
      ---------------------------------------------
      dout(0 to 5) => rf0_ta(0 to 5),
      dout(6)      => rf0_ld_v,               
      dout(7)      => spare_l2(0), 
      dout(8)      => rf0_instr_v,            
      dout(9)      => rf0_frt_v,              
      dout(10)     => rf0_fmul_uc,           
      dout(11)     => rf0_crt_v,                        
      dout(12)     => bubble3_rf0,        
      dout(13)     => rf0_cmiss_flush,
      dout(14)     => ignore_flush_rf0
      ---------------------------------------------
      );
      
spare_unused(04) <= tidn;

rf0_act <= rf0_instr_v or rf0_act_l2;

   rf1_sp_latch : tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 15)
   port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => rf0_act,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => rf1_sp_latch_scin(0 to 14),
      scout    => rf1_sp_latch_scout(0 to 14),
      ---------------------------------------------
      din(0 to 5)  => rf0_ta(0 to 5),
      din(6)       => rf0_ld_v_din,
      din(7)       => spare_l2(1),
      din(8)       => rf0_instr_v_din,
      din(9)       => rf0_frt_v_din,
      din(10)      => rf0_fmul_uc_din,
      din(11)      => rf0_crt_v_din,
      din(12)      => bubble3_rf0_din, 
      din(13)      => rf0_cmiss_flush_din,
      din(14)      => ignore_flush_rf0_din,
           
      ---------------------------------------------
      dout(0 to 5) => rf1_ta(0 to 5),
      dout(6)      => rf1_ld_v,               
      dout(7)      => spare_l2(1), 
      dout(8)      => rf1_instr_v,            
      dout(9)      => rf1_frt_v,              
      dout(10)     => rf1_fmul_uc,           
      dout(11)     => rf1_crt_v,                         
      dout(12)     => bubble3_rf1,        
      dout(13)     => rf1_cmiss_flush,
      dout(14)     => ignore_flush_rf1      
      ---------------------------------------------
      );

    spare_unused(05) <= tidn;

    rf1_act <= rf1_instr_v or rf1_act_l2;
    
    ex1_sp_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 15)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => rf1_act,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => ex1_sp_latch_scin,
      scout    => ex1_sp_latch_scout,
      ---------------------------------------------
      din(0 to 5)  => rf1_ta(0 to 5),
      din(6)       => rf1_ld_v_din,                    
      din(7)       => spare_l2(2),  
      din(8)       => rf1_instr_v_din,         
      din(9)       => rf1_frt_v_din,           
      din(10)      => rf1_fmul_uc_din,            
      din(11)      => rf1_crt_v_din,                          
      din(12)      => bubble3_rf1_din,      
      din(13)      => rf1_cmiss_flush_din,   -- one flush will suffice
      din(14)      => ignore_flush_rf1_din,
      ---------------------------------------------
      dout(0 to 5) => ex1_ta(0 to 5),
      dout(6)      => ex1_ld_v,                    
      dout(7)      => spare_l2(2), 
      dout(8)      => ex1_instr_v,            
      dout(9)      => ex1_frt_v,              
      dout(10)     => ex1_fmul_uc,           
      dout(11)     => ex1_crt_v,                        
      dout(12)     => bubble3_ex1,        
      dout(13)     => ex1_cmiss_flush,
      dout(14)     => ignore_flush_ex1
      ---------------------------------------------
      );

    spare_unused(06) <= tidn;


    ex1_act <= ex1_instr_v or ex1_act_l2;
    
    ex2_sp_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 14)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      act      => ex1_act,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => ex2_sp_latch_scin,
      scout    => ex2_sp_latch_scout,
      ---------------------------------------------
      din(0 to 5)  => ex1_ta(0 to 5),
      din(06)      => ex1_ld_v_din,
      din(07)      => xu_au_loadmiss_target(0),       
      din(08)      => ex1_instr_v_din,
      din(09)      => ex1_frt_v_din,
      din(10)      => ex1_fmul_uc_din,
      din(11)      => ex1_crt_v_din,               
      din(12)      => ex1_cmiss_flush_din,
      din(13)      => ignore_flush_ex1_din,
      ---------------------------------------------
      dout(0 to 5) => ex2_ta(0 to 5),
      dout(06)     => ex2_ld_v,
      dout(07)     => spare_unused(07),       
      dout(08)     => ex2_instr_v,
      dout(09)     => ex2_frt_v,
      dout(10)     => ex2_fmul_uc,
      dout(11)     => ex2_crt_v,
      dout(12)     => ex2_cmiss_flush,
      dout(13)     => ignore_flush_ex2
      ---------------------------------------------
      );

    ex2_act <= ex2_instr_v or ex2_act_l2;

    ex3_sp_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 14)  
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      act      => ex2_act,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => ex3_sp_latch_scin,
      scout    => ex3_sp_latch_scout,
      ---------------------------------------------
      din(0 to 5)   => ex2_ta(0 to 5),
      din(6)        => ex2_ld_v_din,                     
      din(7)        => xu_au_loadmiss_target(1), 
      din(8)        => ex2_instr_v_din,        
      din(9)        => ex2_frt_v_din,          
      din(10)       => ex2_fmul_uc_din,           
      din(11)       => ex2_crt_v_din,                         
      din(12)       => ex2_frt_v,        -- for bypass
      din(13)       => ignore_flush_ex2_din,
      ---------------------------------------------
      dout(0 to 5)   => ex3_ta(0 to 5),
      dout(6)        => ex3_ld_v,                    
      dout(7)        => spare_unused(08),
      dout(8)        => ex3_instr_v,           
      dout(9)        => ex3_frt_v,             
      dout(10)       => ex3_fmul_uc,          
      dout(11)       => ex3_crt_v,                       
      dout(12)       => ex3_frt_v_forbyp,
      dout(13)       => ignore_flush_ex3
      ---------------------------------------------
      );


    ex3_act <= ex3_instr_v or ex3_act_l2;
      
    ex4_sp_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 13)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => ex3_act,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => ex4_sp_latch_scin,
      scout    => ex4_sp_latch_scout,
      ---------------------------------------------
      din(0 to 5)  => ex3_ta(0 to 5),
      din(6)       => ex3_ld_v_din,      
      din(7)       => ex3_instr_v_din,
      din(8)       => ex3_frt_v_din,
      din(9)       => ex3_fmul_uc_din,
      din(10)      => ex3_crt_v_din,
      din(11)      => xu_au_loadmiss_target(2),
      din(12)      => ignore_flush_ex3_din,
      ---------------------------------------------
      dout(0 to 5) => ex4_ta(0 to 5),
      dout(6)      => ex4_ld_v,      
      dout(7)      => ex4_instr_v,
      dout(8)      => ex4_frt_v,
      dout(9)      => ex4_fmul_uc,
      dout(10)     => ex4_crt_v,
      dout(11)     => spare_unused(09),
      dout(12)     => ignore_flush_ex4
      ---------------------------------------------
      );



      
    ex5_sp_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 11)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => ex5_sp_latch_scin,
      scout    => ex5_sp_latch_scout,
      ---------------------------------------------
      din(0)       => ex4_instr_v_din,       
      din(1)       => ex4_fmul_uc_din,
      din(2)       => set_lm0,
      din(3)       => set_lm1,
      din(4)       => set_lm2,
      din(5)       => set_lm3,
      din(6)       => set_lm4,
      din(7)       => set_lm5,
      din(8)       => set_lm6,
      din(9)       => set_lm7,
      din(10)      => ignore_flush_ex4_din,                                  
      ---------------------------------------------
      dout(0)      => ex5_instr_v,      
      dout(1)      => ex5_fmul_uc,
      dout(2)      => set_lm0_1d,
      dout(3)      => set_lm1_1d,
      dout(4)      => set_lm2_1d,
      dout(5)      => set_lm3_1d,
      dout(6)      => set_lm4_1d,
      dout(7)      => set_lm5_1d,
      dout(8)      => set_lm6_1d,
      dout(9)      => set_lm7_1d,
      dout(10)     => ignore_flush_ex5
 
      ---------------------------------------------
      );

ifdp_ex5_fmul_uc_complete <= ex5_fmul_uc;

    ex6_sp_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 2)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => ex6_sp_latch_scin,
      scout    => ex6_sp_latch_scout,
      ---------------------------------------------
      din(0)       => ex5_instr_v_din,       
      din(1)       => ignore_flush_ex5_din,         
      ---------------------------------------------
      dout(0)      => ex6_instr_v,   
      dout(1)      => ignore_flush_ex6   
      ---------------------------------------------
      );

      ----------------------------------------------------------------------------------
      ----------------------------------------------------------------------------------
      -- Single step chicken switch stuff

      
    busy_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 3)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => busy_latch_scin,
      scout    => busy_latch_scout,
      ---------------------------------------------
      din(0)       => fu_busy,         
      din(1)       => fmul_uc_busy,
      din(2)       => ignore_flush_busy,
       
      ---------------------------------------------
      dout(0)      => fu_busy_l2,        
      dout(1)      => fmul_uc_busy_l2,
      dout(2)      => ignore_flush_busy_l2
   
      ---------------------------------------------
      );


      


ignore_flush_busy <= is2_stage_dout(34) or 
                     ignore_flush_rf0 or ignore_flush_rf1 or ignore_flush_ex1 or ignore_flush_ex2 or
                     ignore_flush_ex3 or ignore_flush_ex4 or ignore_flush_ex5 or ignore_flush_ex6;

is2_ignore_flush_busy <= is2_stage_dout(34) or ignore_flush_busy_l2; 


fu_busy <=                is2_instr_v or rf0_instr_v or rf1_instr_v or
           ex1_instr_v or ex2_instr_v or ex3_instr_v or ex4_instr_v or ex5_instr_v or ex6_instr_v or
           lmc_ex4_v or lmc_ex5_v or lmc_ex6_v or  -- want to cover the time when the reload is coming back also
           lm0_valid   or lm1_valid   or lm2_valid   or lm3_valid   or
           lm4_valid   or lm5_valid   or lm6_valid   or lm7_valid; 

      is2_axubusy <= is2_instr_v or fu_busy_l2;
au_iu_is2_axubusy <= is2_axubusy ;

fmul_uc_busy <= is2_fmul_uc_din or rf0_fmul_uc_din or rf1_fmul_uc_din or ex1_fmul_uc_din or
                ex2_fmul_uc_din or ex3_fmul_uc_din or ex4_fmul_uc_din or ex5_fmul_uc_din;


is1_singlestep_ucode <= ( ((is1_to_ucode or is1_is_ucode) and is2_axubusy)     -- create stall when (is1 has ucode op) and (axu is busy)
                       or ( is1_fmul_uc                   and is2_axubusy)     -- create stall when (is1 is fmul_uc)   and (axu is busy)
                       or ( fmul_uc_busy_l2                              ) )   -- create stall when fmul_uc is in the pipe
                       and config_iucr(3);                                       -- note: nop after fmul_uc will issue since its an XU op

is1_singlestep_pn <=    ((ppc_div_sqrt_is1 and is2_axubusy) or    -- create stall when (is1 has fdiv/fsqrt op) and (axu is busy)
                         (is1_instr_v and is2_ignore_flush_busy))
                         and iucr2_ss_ignore_flush ;


 is1_singlestep       <= is1_singlestep_ucode or is1_singlestep_pn or (is2_axubusy and config_iucr(2));

 

           
-----------------------------------------------------------------------
--LMQ latches
-----------------------------------------------------------------------
    lmq0_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 7)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => lmq0_latch_scin,
      scout    => lmq0_latch_scout,
      ---------------------------------------------
      din(0)       => lm0_valid_din,
      din(1 to 6)  => lm0_ta_din(0 to 5),
      ---------------------------------------------
      dout(0)      => lm0_valid,
      dout(1 to 6) => lm0_ta(0 to 5)
      ---------------------------------------------
      );
    lmq1_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 7)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      --d_mode   => d_mode,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => lmq1_latch_scin ,
      scout    => lmq1_latch_scout,
      ---------------------------------------------
      din(0)       => lm1_valid_din,
      din(1 to 6)  => lm1_ta_din(0 to 5),
      ---------------------------------------------
      dout(0)      => lm1_valid,
      dout(1 to 6) => lm1_ta(0 to 5)
      ---------------------------------------------
      );
    lmq2_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 7)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => lmq2_latch_scin,
      scout    => lmq2_latch_scout,
      ---------------------------------------------
      din(0)       => lm2_valid_din,
      din(1 to 6)  => lm2_ta_din(0 to 5),
      ---------------------------------------------
      dout(0)      => lm2_valid,
      dout(1 to 6) => lm2_ta(0 to 5)
      ---------------------------------------------
      );
    lmq3_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 7)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => lmq3_latch_scin,
      scout    => lmq3_latch_scout,
      ---------------------------------------------
      din(0)       => lm3_valid_din,
      din(1 to 6)  => lm3_ta_din(0 to 5),
      ---------------------------------------------
      dout(0)      => lm3_valid,
      dout(1 to 6) => lm3_ta(0 to 5)
      ---------------------------------------------
      );
    lmq4_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 7)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => lmq4_latch_scin,
      scout    => lmq4_latch_scout,
      ---------------------------------------------
      din(0)       => lm4_valid_din,
      din(1 to 6)  => lm4_ta_din(0 to 5),
      ---------------------------------------------
      dout(0)      => lm4_valid,
      dout(1 to 6) => lm4_ta(0 to 5)
      ---------------------------------------------
      );
    lmq5_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 7)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => lmq5_latch_scin,
      scout    => lmq5_latch_scout,
      ---------------------------------------------
      din(0)       => lm5_valid_din,
      din(1 to 6)  => lm5_ta_din(0 to 5),
      ---------------------------------------------
      dout(0)      => lm5_valid,
      dout(1 to 6) => lm5_ta(0 to 5)
      ---------------------------------------------
      );
    lmq6_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 7)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b => pc_iu_func_sl_thold_0_b,
      sg      => pc_iu_sg_0,
      scin     => lmq6_latch_scin,
      scout    => lmq6_latch_scout,
      ---------------------------------------------
      din(0)       => lm6_valid_din,
      din(1 to 6)  => lm6_ta_din(0 to 5),
      ---------------------------------------------
      dout(0)      => lm6_valid,
      dout(1 to 6) => lm6_ta(0 to 5)
      ---------------------------------------------
      );
    lmq7_latch: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 7)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b => pc_iu_func_sl_thold_0_b,
      sg      => pc_iu_sg_0,
      scin     => lmq7_latch_scin,
      scout    => lmq7_latch_scout,
      ---------------------------------------------
      din(0)       => lm7_valid_din,
      din(1 to 6)  => lm7_ta_din(0 to 5),
      ---------------------------------------------
      dout(0)      => lm7_valid,
      dout(1 to 6) => lm7_ta(0 to 5)
      ---------------------------------------------
      );

      
-----------------------------------------------------------------------


-- cache miss (xu_au_loadmiss_vld=1) is a stage ex4 signal
-- fop in is1 has raw or waw dependency on load that just got a cmiss.  is1 must be flushed

is1_cmiss_flush <= ex4_ld_v and xu_au_loadmiss_vld and not is1_stall_rep and is1_instr_v and
                               ((is1_frt_v and (ex4_ta(0 to 5) = is1_ta(0 to 5))) 
                                          or
                                (is1_fra_v and (ex4_ta(0 to 5) = is1_fra(0 to 5))) 
                                          or
                                (is1_frb_v and (ex4_ta(0 to 5) = is1_frb(0 to 5))) 
                                          or
                                (is1_frc_v and (ex4_ta(0 to 5) = is1_frc(0 to 5)))); 


-- cache miss (xu_au_loadmiss_vld=1) is a stage ex4 signal
-- fop in is2 has raw or war dependency on load that just got a cmiss.  is2 must be flushed


is2_cmiss_flush <= ex4_ld_v and xu_au_loadmiss_vld and is2_instr_v and
                               ((is2_frt_v and (ex4_ta(0 to 5) = is2_ta(0 to 5))) 
                                          or
                                (is2_fra_v and (ex4_ta(0 to 5) = is2_fra(0 to 5))) 
                                          or
                                (is2_frb_v and (ex4_ta(0 to 5) = is2_frb(0 to 5))) 
                                          or
                                (is2_frc_v and (ex4_ta(0 to 5) = is2_frc(0 to 5)))); 
                             
-- WAW checking for loads
rf0_cmiss_waw_flush <=  ex4_ld_v and xu_au_loadmiss_vld and rf0_instr_v and (rf0_frt_v and (ex4_ta(0 to 5) = rf0_ta(0 to 5)));
rf1_cmiss_waw_flush <=  ex4_ld_v and xu_au_loadmiss_vld and rf1_instr_v and (rf1_frt_v and (ex4_ta(0 to 5) = rf1_ta(0 to 5)));
ex1_cmiss_waw_flush <=  ex4_ld_v and xu_au_loadmiss_vld and ex1_instr_v and (ex1_frt_v and (ex4_ta(0 to 5) = ex1_ta(0 to 5)));


is2_cmiss_flush_din <= (is2_cmiss_flush or is2_cmiss_flush_q or is2_stage_dout(42));   -- passing the flush down the pipe

rf0_cmiss_flush_din <= rf0_cmiss_flush or rf0_cmiss_waw_flush;
rf1_cmiss_flush_din <= rf1_cmiss_flush or rf1_cmiss_waw_flush;
ex1_cmiss_flush_din <= ex1_cmiss_flush or ex1_cmiss_waw_flush;

-- Output to FU
iu_fu_ex2_n_flush <= ex2_cmiss_flush and ex2_instr_v;  -- fop in ex1 must be flushed due to waw dependency that got a cmiss

 
-----------------------------------------------------------------------




  debug_latch_for_timing: tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 16)
    port map (
      nclk     => nclk, vd       => vdd,     gd       => gnd,
      forcee => forcee, mpw1_b => mpw1_b,    mpw2_b   => mpw2_b,
      delay_lclkr => delay_lclkr, 
      act      => tiup,
      thold_b => pc_iu_func_sl_thold_0_b,
      sg      => pc_iu_sg_0,
      scin        => debug_scin,
      scout       => debug_scout,
      ---------------------------------------------
      din(0)       => is1_dep_hit,
      din(1)       => is1_raw_hit,
      din(2)       => raw_fra_hit,       
      din(3)       => raw_frb_hit,
      din(4)       => raw_frc_hit,
      din(5)       => is1_prebubble_skip,
      din(6)       => raw_cr_hit,       
      din(7)       => bubble3_is1,      
      din(8)       => is1_lmq_waw_hit,  
      din(9)       => is1_waw_load_hit, 
      din(10)      => iu_au_is1_hold,
      din(11)      => iu_au_is2_stall,
      din(12)      => iu_au_is1_flush,
      din(13)      => iu_au_is2_flush,
      din(14)      => iu_au_rf0_flush,
      din(15)      => is1_instr_v_din,        
      ---------------------------------------------
      dout(0)      => is1_dep_hit_db,
      dout(1)      => is1_raw_hit_db,
      dout(2)      => raw_fra_hit_db,       
      dout(3)      => raw_frb_hit_db,
      dout(4)      => raw_frc_hit_db,
      dout(5)      => is1_prebubble_skip_db,
      dout(6)      => raw_cr_hit_db,       
      dout(7)      => bubble3_is1_db,      
      dout(8)      => is1_lmq_waw_hit_db,  
      dout(9)      => is1_waw_load_hit_db, 
      dout(10)     => iu_au_is1_hold_db,
      dout(11)     => iu_au_is2_stall_db,
      dout(12)     => iu_au_is1_flush_db,
      dout(13)     => iu_au_is2_flush_db,
      dout(14)     => iu_au_rf0_flush_db,
      dout(15)     => is1_instr_v_din_db        
       ---------------------------------------------
    );

  -----------------------------------------------------------------------

-- note that is1 instr_v_db is delayed by 1 cycle from the other valids (for timing)
fu_dep_debug(0 to 23) <=  is1_dep_hit_db        & is1_raw_hit_db        & raw_fra_hit_db        & raw_frb_hit_db        &
                          raw_frc_hit_db        & is1_prebubble_skip_db & raw_cr_hit_db         & bubble3_is1_db        &  
                          is1_lmq_waw_hit_db    & is1_waw_load_hit_db   & iu_au_is1_hold_db     & iu_au_is2_stall_db    &
                          iu_au_is1_flush_db    & iu_au_is2_flush_db    & iu_au_rf0_flush_db    & is1_instr_v_din_db        &
                          is2_instr_v           & rf0_instr_v           & rf1_instr_v           &
                          is2_ta(1 to 5);                    

  -----------------------------------------------------------------------



-- scan chain

ppc_rc_latch_scin <= i_dep_si;

is2_stage_latch_scin(0) <= ppc_rc_latch_scout;

is2_stage_latch_scin(1 to 42) <= is2_stage_latch_scout(0 to 41);

is2_bypass_latch_scin(0)      <= is2_stage_latch_scout(42);  
is2_bypass_latch_scin(1 to 5) <= is2_bypass_latch_scout(0 to 4);

rf0_sp_latch_scin(0)        <=  is2_bypass_latch_scout(5);
rf0_sp_latch_scin(1 to 14)  <=  rf0_sp_latch_scout(0 to 13);

rf1_sp_latch_scin(0)        <=  rf0_sp_latch_scout(14);
rf1_sp_latch_scin(1 to 14)  <=  rf1_sp_latch_scout(0 to 13);

ex1_sp_latch_scin(0)        <=  rf1_sp_latch_scout(14);
ex1_sp_latch_scin(1 to 14)  <=  ex1_sp_latch_scout(0 to 13);

ex2_sp_latch_scin(0)        <=  ex1_sp_latch_scout(14);
ex2_sp_latch_scin(1 to 13)  <=  ex2_sp_latch_scout(0 to 12);

ex3_sp_latch_scin(0)        <=  ex2_sp_latch_scout(13);
ex3_sp_latch_scin(1 to 13)  <=  ex3_sp_latch_scout(0 to 12);

ex4_sp_latch_scin(0)        <=  ex3_sp_latch_scout(13);
ex4_sp_latch_scin(1 to 12)  <=  ex4_sp_latch_scout(0 to 11);

ex5_sp_latch_scin(0)        <=  ex4_sp_latch_scout(12);
ex5_sp_latch_scin(1 to 10)  <=  ex5_sp_latch_scout(0 to 9);

ex6_sp_latch_scin(0)        <=  ex5_sp_latch_scout(10);
ex6_sp_latch_scin(1)        <=  ex6_sp_latch_scout(0);

busy_latch_scin(0)          <= ex6_sp_latch_scout(1);
busy_latch_scin(1 to 2)     <= busy_latch_scout(0 to 1);

act_latch_scin(0)          <= busy_latch_scout(2);
act_latch_scin(1 to 7)     <= act_latch_scout(0 to 6);


lmq0_latch_scin(0)         <=  act_latch_scout(7);
lmq0_latch_scin(1 to 6)    <=  lmq0_latch_scout(0 to 5);

lmq1_latch_scin(0)         <=  lmq0_latch_scout(6);
lmq1_latch_scin(1 to 6)    <=  lmq1_latch_scout(0 to 5);

lmq2_latch_scin(0)         <=  lmq1_latch_scout(6);
lmq2_latch_scin(1 to 6)    <=  lmq2_latch_scout(0 to 5);

lmq3_latch_scin(0)         <=  lmq2_latch_scout(6);
lmq3_latch_scin(1 to 6)    <=  lmq3_latch_scout(0 to 5);

lmq4_latch_scin(0)         <=  lmq3_latch_scout(6);
lmq4_latch_scin(1 to 6)    <=  lmq4_latch_scout(0 to 5);

lmq5_latch_scin(0)         <=  lmq4_latch_scout(6);
lmq5_latch_scin(1 to 6)    <=  lmq5_latch_scout(0 to 5);

lmq6_latch_scin(0)         <=  lmq5_latch_scout(6);
lmq6_latch_scin(1 to 6)    <=  lmq6_latch_scout(0 to 5);

lmq7_latch_scin(0)         <=  lmq6_latch_scout(6);
lmq7_latch_scin(1 to 6)    <=  lmq7_latch_scout(0 to 5);

lmiss_comp_ex1_latch_scin(0)      <= lmq7_latch_scout(6);
lmiss_comp_ex1_latch_scin(1 to 7) <= lmiss_comp_ex1_latch_scout(0 to 6);

lmiss_comp_ex2_latch_scin(0)      <= lmiss_comp_ex1_latch_scout(7);
lmiss_comp_ex2_latch_scin(1 to 7) <= lmiss_comp_ex2_latch_scout(0 to 6);

lmiss_comp_ex3_latch_scin(0)      <= lmiss_comp_ex2_latch_scout(7);
lmiss_comp_ex3_latch_scin(1 to 7) <= lmiss_comp_ex3_latch_scout(0 to 6);

lmc_ex4_latch_scin(0)            <= lmiss_comp_ex3_latch_scout(7);
lmc_ex4_latch_scin(1 to 6)       <= lmc_ex4_latch_scout(0 to 5);

lmc_ex5_latch_scin <= lmc_ex4_latch_scout(6);
lmc_ex6_latch_scin <= lmc_ex5_latch_scout;

debug_scin(0) <= lmc_ex6_latch_scout;
debug_scin(1 to 15) <= debug_scout(0 to 14);


i_dep_so <= debug_scout(15); 



end iuq_axu_fu_dep;
