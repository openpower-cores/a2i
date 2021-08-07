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

--  Description:  XU Exception Handler
--
library ieee,ibm,support,work,tri,clib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_cpl is
generic(
   expand_type                      :     integer :=  2;
   threads                          :     integer :=  4;
   eff_ifar                         :     integer := 62;
    uc_ifar                         :     integer := 21;
   regsize                          :     integer := 64;
   hvmode                           :     integer := 1;
   a2mode                           :     integer := 1);
port(
   -- Clocks
   nclk                             : in  clk_logic;

   -- CHIP IO
   ac_tc_debug_trigger              : out std_ulogic_vector(0 to threads-1);

   -- Pervasive
   an_ac_scan_dis_dc_b              : in  std_ulogic;
   pc_xu_ccflush_dc                 : in  std_ulogic;
   clkoff_dc_b                      : in  std_ulogic;
   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic;
   mpw1_dc_b                        : in  std_ulogic;
   mpw2_dc_b                        : in  std_ulogic;
   func_sl_thold_2                  : in  std_ulogic;
   func_nsl_thold_2                 : in  std_ulogic;
   func_slp_sl_thold_2              : in  std_ulogic;
   func_slp_nsl_thold_2             : in  std_ulogic;
   cfg_sl_thold_2                   : in  std_ulogic;
   cfg_slp_sl_thold_2               : in  std_ulogic;
   sg_2                             : in  std_ulogic;
   fce_2                            : in  std_ulogic;
   func_scan_in                     : in  std_ulogic_vector(50 to 53);
   func_scan_out                    : out std_ulogic_vector(50 to 53);
   bcfg_scan_in                     : in  std_ulogic;
   bcfg_scan_out                    : out std_ulogic;
   ccfg_scan_in                     : in  std_ulogic;
   ccfg_scan_out                    : out std_ulogic;
   dcfg_scan_in                     : in  std_ulogic;
   dcfg_scan_out                    : out std_ulogic;

   -- Valids
   dec_cpl_rf0_act                  : in  std_ulogic;
   dec_cpl_rf0_tid                  : in  std_ulogic_vector(0 to threads-1);
   dec_cpl_rf1_val                  : in  std_ulogic_vector(0 to threads-1);
   dec_cpl_rf1_issued               : in  std_ulogic_vector(0 to threads-1);

   -- IU Inputs
   dec_cpl_ex2_error                : in std_ulogic_vector(0 to 2);
   dec_cpl_ex2_match                : in std_ulogic;

   -- FU Inputs
   fu_xu_rf1_act                    : in  std_ulogic_vector(0 to threads-1);
   fu_xu_ex1_ifar                   : in  std_ulogic_vector(0 to eff_ifar*threads-1);
   fu_xu_ex2_ifar_issued            : in  std_ulogic_vector(0 to threads-1);
   fu_xu_ex2_ifar_val               : in  std_ulogic_vector(0 to threads-1);
   fu_xu_ex2_instr_type             : in  std_ulogic_vector(0 to 3*threads-1);
   fu_xu_ex2_instr_match            : in  std_ulogic_vector(0 to threads-1);
   fu_xu_ex2_is_ucode               : in  std_ulogic_vector(0 to threads-1);

   -- PC Inputs
   pc_xu_step                       : in  std_ulogic_vector(0 to threads-1);
   pc_xu_stop                       : in  std_ulogic_vector(0 to threads-1);
   pc_xu_dbg_action                 : in  std_ulogic_vector(0 to 3*threads-1);
   pc_xu_force_ude                  : in  std_ulogic_vector(0 to threads-1);
   xu_pc_step_done                  : out std_ulogic_vector(0 to threads-1);
   pc_xu_init_reset                 : in  std_ulogic;

   -- Bypass Inputs
   byp_cpl_ex1_cr_bit               : in  std_ulogic;

   -- Decode Inputs
   dec_cpl_rf1_pred_taken_cnt       : in  std_ulogic;
   dec_cpl_rf1_instr                : in  std_ulogic_vector(0 to 31);
   dec_cpl_ex3_is_any_store         : in  std_ulogic;
   dec_cpl_ex2_is_any_store_dac     : in  std_ulogic;
   dec_cpl_ex2_is_any_load_dac      : in  std_ulogic;
   dec_cpl_ex3_instr_priv           : in  std_ulogic;
   dec_cpl_ex3_instr_hypv           : in  std_ulogic;
   dec_cpl_ex1_epid_instr           : in  std_ulogic;
   dec_cpl_ex3_tlb_illeg            : in  std_ulogic;
   dec_cpl_ex3_axu_instr_type       : in  std_ulogic_vector(0 to 2);
   dec_cpl_rf1_ucode_val            : in  std_ulogic_vector(0 to threads-1);
   dec_cpl_ex3_mtdp_nr              : in  std_ulogic;
   lsu_xu_ex4_mtdp_cr_status        : in  std_ulogic;  
   dec_cpl_ex3_mc_dep_chk_val       : in  std_ulogic_vector(0 to threads-1);
   dec_cpl_ex2_illegal_op           : in  std_ulogic;
   dec_cpl_ex3_mult_coll            : in  std_ulogic;
   fxa_cpl_ex2_div_coll             : in  std_ulogic_vector(0 to threads-1);

   -- Async Interrupt Req Interface
   spr_cpl_ext_interrupt            : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_udec_interrupt           : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_perf_interrupt           : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_dec_interrupt            : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_fit_interrupt            : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_crit_interrupt           : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_wdog_interrupt           : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_dbell_interrupt          : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_cdbell_interrupt         : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_gdbell_interrupt         : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_gcdbell_interrupt        : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_gmcdbell_interrupt       : in  std_ulogic_vector(0 to threads-1);
   
   cpl_spr_ex5_dbell_taken          : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_cdbell_taken         : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gdbell_taken         : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gcdbell_taken        : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gmcdbell_taken       : out std_ulogic_vector(0 to threads-1);

   -- IFAR
   dec_cpl_rf1_ifar                 : in  std_ulogic_vector(62-eff_ifar to 61);
     
   -- Debug Compares
   spr_cpl_iac1_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_iac2_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_iac3_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_iac4_en                  : in  std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac1r_cmpr_async     : in  std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac2r_cmpr_async     : in  std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac1r_cmpr           : in  std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac2r_cmpr           : in  std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac3r_cmpr           : in  std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac4r_cmpr           : in  std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac1w_cmpr           : in  std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac2w_cmpr           : in  std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac3w_cmpr           : in  std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac4w_cmpr           : in  std_ulogic_vector(0 to threads-1);

   -- Interrupt Interface
   cpl_spr_ex5_act                  : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_int                  : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gint                 : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_cint                 : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_mcint                : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_nia                  : out std_ulogic_vector(0 to eff_ifar*threads-1);
   cpl_spr_ex5_esr                  : out std_ulogic_vector(0 to 17*threads-1);
   cpl_spr_ex5_mcsr                 : out std_ulogic_vector(0 to 15*threads-1);
   cpl_spr_ex5_dbsr                 : out std_ulogic_vector(0 to 19*threads-1);
   cpl_spr_ex5_dear_save            : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_dear_update_saved    : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_dear_update          : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_dbsr_update          : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_esr_update           : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_srr0_dec             : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_force_gsrr           : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_dbsr_ide             : out std_ulogic_vector(0 to threads-1);
   spr_cpl_dbsr_ide                 : in  std_ulogic_vector(0 to threads-1);

   -- ALU Inputs
   alu_cpl_ex1_eff_addr             : in  std_ulogic_vector(62 to 63);

   -- Machine Check Interrupts
   mm_xu_local_snoop_reject         : in  std_ulogic_vector(0 to threads-1);
   mm_xu_lru_par_err                : in  std_ulogic_vector(0 to threads-1);
   mm_xu_tlb_par_err                : in  std_ulogic_vector(0 to threads-1);
   mm_xu_tlb_multihit_err           : in  std_ulogic_vector(0 to threads-1);
   lsu_xu_ex3_derat_par_err         : in  std_ulogic_vector(0 to threads-1);
   lsu_xu_ex4_derat_par_err         : in  std_ulogic_vector(0 to threads-1);
   lsu_xu_ex3_derat_multihit_err    : in  std_ulogic_vector(0 to threads-1);
   lsu_xu_ex3_l2_uc_ecc_err         : in  std_ulogic_vector(0 to threads-1);
   lsu_xu_ex3_ddir_par_err          : in  std_ulogic;
   lsu_xu_ex4_n_lsu_ddmh_flush      : in  std_ulogic_vector(0 to 3);
   lsu_xu_ex6_datc_par_err          : in  std_ulogic;
   spr_cpl_external_mchk            : in  std_ulogic_vector(0 to threads-1);

   -- PC Errors
   xu_pc_err_attention_instr        : out std_ulogic_vector(0 to threads-1);
   xu_pc_err_nia_miscmpr            : out std_ulogic_vector(0 to threads-1);
   xu_pc_err_debug_event            : out std_ulogic_vector(0 to threads-1);

   -- Data Storage
   lsu_xu_ex3_dsi                   : in  std_ulogic_vector(0 to threads-1);
   derat_xu_ex3_dsi                 : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_ex3_ct_le                : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_ex3_ct_be                : in  std_ulogic_vector(0 to threads-1);

   -- Alignment
   lsu_xu_ex3_align                 : in  std_ulogic_vector(0 to threads-1);

   -- Program
   spr_cpl_ex3_spr_illeg            : in  std_ulogic;
   spr_cpl_ex3_spr_priv             : in  std_ulogic;
   alu_cpl_ex3_trap_val             : in  std_ulogic;

   -- Hypv Privledge
   spr_cpl_ex3_spr_hypv             : in  std_logic;

   -- Data TLB Miss
   derat_xu_ex3_miss                : in  std_ulogic_vector(0 to threads-1);

   -- uCode
   dec_cpl_ex2_is_ucode             : in  std_ulogic;

   -- RAM
   pc_xu_ram_mode                   : in  std_ulogic;
   pc_xu_ram_thread                 : in  std_ulogic_vector(0 to 1);
   pc_xu_ram_execute                : in  std_ulogic;
   xu_iu_ram_issue                  : out std_ulogic_vector(0 to threads-1);
   xu_pc_ram_interrupt              : out std_ulogic;
   xu_pc_ram_done                   : out std_ulogic;
   pc_xu_ram_flush_thread           : in  std_ulogic;

   -- Run State
   cpl_spr_stop                     : out std_ulogic_vector(0 to threads-1);
   xu_pc_stop_dbg_event             : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_instr_cpl            : out std_ulogic_vector(0 to threads-1);
   spr_cpl_quiesce                  : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_quiesce                  : out std_ulogic_vector(0 to threads-1);
   spr_cpl_ex2_run_ctl_flush        : in  std_ulogic_vector(0 to threads-1);

   -- MMU Flushes
   mm_xu_illeg_instr                : in  std_ulogic_vector(0 to threads-1);
   mm_xu_tlb_miss                   : in  std_ulogic_vector(0 to threads-1);
   mm_xu_pt_fault                   : in  std_ulogic_vector(0 to threads-1);
   mm_xu_tlb_inelig                 : in  std_ulogic_vector(0 to threads-1);
   mm_xu_lrat_miss                  : in  std_ulogic_vector(0 to threads-1);
   mm_xu_hv_priv                    : in  std_ulogic_vector(0 to threads-1);
   mm_xu_esr_pt                     : in  std_ulogic_vector(0 to threads-1);
   mm_xu_esr_data                   : in  std_ulogic_vector(0 to threads-1);
   mm_xu_esr_epid                   : in  std_ulogic_vector(0 to threads-1);
   mm_xu_esr_st                     : in  std_ulogic_vector(0 to threads-1);
   mm_xu_hold_req                   : in  std_ulogic_vector(0 to threads-1);
   mm_xu_hold_done                  : in  std_ulogic_vector(0 to threads-1);
   xu_mm_hold_ack                   : out std_ulogic_vector(0 to threads-1);
   mm_xu_eratmiss_done              : in  std_ulogic_vector(0 to threads-1);
   mm_xu_ex3_flush_req              : in  std_ulogic_vector(0 to threads-1);

   -- LSU Flushes
   lsu_xu_l2_ecc_err_flush          : in  std_ulogic_vector(0 to threads-1);
   lsu_xu_datc_perr_recovery        : in  std_ulogic;
   lsu_xu_ex3_dep_flush             : in  std_ulogic;
   lsu_xu_ex3_n_flush_req           : in  std_ulogic;
   lsu_xu_ex3_ldq_hit_flush         : in  std_ulogic;
   lsu_xu_ex4_ldq_full_flush        : in  std_ulogic;
   derat_xu_ex3_n_flush_req         : in  std_ulogic_vector(0 to threads-1);
   lsu_xu_ex3_inval_align_2ucode    : in  std_ulogic;
   lsu_xu_ex3_attr                  : in  std_ulogic_vector(0 to 8);
   lsu_xu_ex3_derat_vf              : in  std_ulogic;

   -- AXU Flushes
   fu_xu_ex3_ap_int_req             : in  std_ulogic_vector(0 to threads-1);
   fu_xu_ex3_trap                   : in  std_ulogic_vector(0 to threads-1);
   fu_xu_ex3_n_flush                : in  std_ulogic_vector(0 to threads-1);
   fu_xu_ex3_np1_flush              : in  std_ulogic_vector(0 to threads-1);
   fu_xu_ex3_flush2ucode            : in  std_ulogic_vector(0 to threads-1);
   fu_xu_ex2_async_block            : in  std_ulogic_vector(0 to threads-1);

   -- IU Flushes
   xu_iu_ex5_br_taken               : out std_ulogic;
   xu_iu_ex5_ifar                   : out std_ulogic_vector(62-eff_ifar to 61);
   xu_iu_flush                      : out std_ulogic_vector(0 to threads-1);
   xu_iu_iu0_flush_ifar             : out std_ulogic_vector(0 to eff_ifar*threads-1);
   xu_iu_uc_flush_ifar              : out std_ulogic_vector(0 to uc_ifar*threads-1);
   xu_iu_flush_2ucode               : out std_ulogic_vector(0 to threads-1);
   xu_iu_flush_2ucode_type          : out std_ulogic_vector(0 to threads-1);
   xu_iu_ucode_restart              : out std_ulogic_vector(0 to threads-1);
   xu_iu_ex5_ppc_cpl                : out std_ulogic_vector(0 to threads-1);

   -- Flushes
   xu_rf0_flush                     : out std_ulogic_vector(0 to threads-1);
   xu_rf1_flush                     : out std_ulogic_vector(0 to threads-1);
   xu_ex1_flush                     : out std_ulogic_vector(0 to threads-1);
   xu_ex2_flush                     : out std_ulogic_vector(0 to threads-1);
   xu_ex3_flush                     : out std_ulogic_vector(0 to threads-1);
   xu_ex4_flush                     : out std_ulogic_vector(0 to threads-1);
   xu_ex5_flush                     : out std_ulogic_vector(0 to threads-1);

   xu_n_is2_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_n_rf0_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_n_rf1_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_n_ex1_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_n_ex2_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_n_ex3_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_n_ex4_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_n_ex5_flush                   : out std_ulogic_vector(0 to threads-1);

   xu_s_rf1_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_s_ex1_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_s_ex2_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_s_ex3_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_s_ex4_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_s_ex5_flush                   : out std_ulogic_vector(0 to threads-1);

   xu_w_rf1_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_w_ex1_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_w_ex2_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_w_ex3_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_w_ex4_flush                   : out std_ulogic_vector(0 to threads-1);
   xu_w_ex5_flush                   : out std_ulogic_vector(0 to threads-1);

   xu_lsu_ex4_val                   : out std_ulogic_vector(0 to threads-1);
   xu_lsu_ex4_flush_local           : out std_ulogic_vector(0 to threads-1);
   xu_mm_ex4_flush                  : out std_ulogic_vector(0 to threads-1);
   xu_mm_ex5_flush                  : out std_ulogic_vector(0 to threads-1);
   xu_mm_ierat_flush                : out std_ulogic_vector(0 to threads-1);
   xu_mm_ierat_miss                 : out std_ulogic_vector(0 to threads-1);
   
   -- Barrier
   xu_lsu_ex5_set_barr              : out std_ulogic_vector(0 to threads-1);
   cpl_fxa_ex5_set_barr             : out std_ulogic_vector(0 to threads-1);
   cpl_iu_set_barr_tid              : out std_ulogic_vector(0 to threads-1);

   -- SPR Bus
   cpl_byp_ex3_spr_rt               : out std_ulogic_vector(64-regsize to 63);
   mux_cpl_ex4_rt                   : in  std_ulogic_vector(64-regsize to 63);

   -- SPR Bits
   spr_bit_act                      : in  std_ulogic;
   cpl_spr_dbcr0_edm                : out std_ulogic_vector(0 to threads-1);
   spr_cpl_fp_precise               : in  std_ulogic_vector(0 to threads-1);
   spr_xucr0_mddp                   : in  std_ulogic;
   spr_xucr0_mdcp                   : in  std_ulogic;
   spr_msr_de                       : in  std_ulogic_vector(0 to threads-1);
   spr_msr_spv                      : in  std_ulogic_vector(0 to threads-1);
   spr_msr_fp                       : in  std_ulogic_vector(0 to threads-1);
   spr_msr_pr                       : in  std_ulogic_vector(0 to threads-1);
   spr_msr_gs                       : in  std_ulogic_vector(0 to threads-1);
   spr_msr_me                       : in  std_ulogic_vector(0 to threads-1);
   spr_msr_cm                       : in  std_ulogic_vector(0 to threads-1);
   spr_msr_ucle                     : in  std_ulogic_vector(0 to threads-1);
   spr_msrp_uclep                   : in  std_ulogic_vector(0 to threads-1);
   spr_ccr2_notlb                   : in  std_ulogic;
   spr_ccr2_ucode_dis               : in  std_ulogic;
   spr_ccr2_ap                      : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr0_idm                    : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr0_icmp                   : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr0_brt                    : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr0_trap                   : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr0_ret                    : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr0_irpt                   : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr3_ivc                    : in  std_ulogic_vector(0 to threads-1);
   spr_epcr_dsigs                   : in  std_ulogic_vector(0 to threads-1);
   spr_epcr_isigs                   : in  std_ulogic_vector(0 to threads-1);
   spr_epcr_extgs                   : in  std_ulogic_vector(0 to threads-1);
   spr_epcr_dtlbgs                  : in  std_ulogic_vector(0 to threads-1);
   spr_epcr_itlbgs                  : in  std_ulogic_vector(0 to threads-1);
   spr_xucr4_div_barr_thres         : out std_ulogic_vector(0 to 7);
   spr_ccr0_we                      : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr1_iac12m                 : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr1_iac34m                 : in  std_ulogic_vector(0 to threads-1);
   spr_epcr_duvd                    : in  std_ulogic_vector(0 to threads-1);
   spr_xucr0_clkg_ctl               : in  std_ulogic_vector(2 to 2);
   spr_xucr4_mmu_mchk               : out std_ulogic;
   
   cpl_msr_gs                       : out std_ulogic_vector(0 to threads-1);
   cpl_msr_pr                       : out std_ulogic_vector(0 to threads-1);
   cpl_msr_fp                       : out std_ulogic_vector(0 to threads-1);
   cpl_msr_spv                      : out std_ulogic_vector(0 to threads-1);
   cpl_ccr2_ap                      : out std_ulogic_vector(0 to threads-1);

   -- Slow SPR Bus
   mux_cpl_slowspr_flush            : in  std_ulogic_vector(0 to threads-1);
   mux_cpl_slowspr_done             : in  std_ulogic_vector(0 to threads-1);
   dec_cpl_ex1_is_slowspr_wr        : in  std_ulogic;
   dec_cpl_ex3_ddmh_en              : in  std_ulogic;
   dec_cpl_ex3_back_inv             : in  std_ulogic;
    
   -- Cache invalidate
   xu_lsu_ici                       : out std_ulogic;
   xu_lsu_dci                       : out std_ulogic;
   
   -- Perf
   pc_xu_event_bus_enable           : in  std_ulogic;  
   cpl_perf_tx_events               : out std_ulogic_vector(0 to 75);
   spr_cpl_async_int                : in  std_ulogic_vector(0 to 3*threads-1);
   xu_mm_ex5_perf_itlb              : out std_ulogic_vector(0 to threads-1);
   xu_mm_ex5_perf_dtlb              : out std_ulogic_vector(0 to threads-1);

   -- Parity
   spr_cpl_ex3_sprg_ce              : in  std_ulogic;
   spr_cpl_ex3_sprg_ue              : in  std_ulogic;
   iu_xu_ierat_ex2_flush_req        : in  std_ulogic_vector(0 to threads-1);
   iu_xu_ierat_ex3_par_err          : in  std_ulogic_vector(0 to threads-1);
   iu_xu_ierat_ex4_par_err          : in  std_ulogic_vector(0 to threads-1);
   
   -- Regfile Parity
	fu_xu_ex3_regfile_err_det	      : in  std_ulogic_vector(0 to threads-1);
	xu_fu_regfile_seq_beg	         : out std_ulogic;
	fu_xu_regfile_seq_end	         : in  std_ulogic;
	gpr_cpl_ex3_regfile_err_det	   : in  std_ulogic;
	cpl_gpr_regfile_seq_beg	         : out std_ulogic;
	gpr_cpl_regfile_seq_end	         : in  std_ulogic;
   xu_pc_err_mcsr_summary           : out std_ulogic_vector(0 to threads-1);
   xu_pc_err_ditc_overrun           : out std_ulogic;
   xu_pc_err_local_snoop_reject     : out std_ulogic;
   xu_pc_err_tlb_lru_parity         : out std_ulogic;
   xu_pc_err_ext_mchk               : out std_ulogic;
   xu_pc_err_ierat_multihit         : out std_ulogic;
   xu_pc_err_derat_multihit         : out std_ulogic;
   xu_pc_err_tlb_multihit           : out std_ulogic;
   xu_pc_err_ierat_parity           : out std_ulogic;
   xu_pc_err_derat_parity           : out std_ulogic;
   xu_pc_err_tlb_parity             : out std_ulogic;
   xu_pc_err_mchk_disabled          : out std_ulogic;
   xu_pc_err_sprg_ue                : out std_ulogic_vector(0 to threads-1);
   
   -- Debug
   pc_xu_instr_trace_mode           : in  std_ulogic;
   pc_xu_trace_bus_enable           : in  std_ulogic;  
   dec_cpl_rf1_instr_trace_val      : in  std_ulogic;
   dec_cpl_rf1_instr_trace_type     : in  std_ulogic_vector(0 to 1);
   dec_cpl_ex3_instr_trace_val      : in  std_ulogic;
   cpl_dec_in_ucode                 : out std_ulogic_vector(0 to threads-1);
   cpl_debug_mux_ctrls              : in  std_ulogic_vector(0 to 15);
   cpl_debug_data_in                : in  std_ulogic_vector(0 to 87);
   cpl_debug_data_out               : out std_ulogic_vector(0 to 87);
   cpl_trigger_data_in              : in  std_ulogic_vector(0 to 11);
   cpl_trigger_data_out             : out std_ulogic_vector(0 to 11);
   fxa_cpl_debug                    : in  std_ulogic_vector(0 to 272);
   
   -- Power
   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_cpl;
architecture xuq_cpl of xuq_cpl is

constant ivos                                         : integer := 26;
constant ifar_repwr                                   : integer := (eff_ifar+2)/8;
constant MSL                                          : integer := 1274;

constant PREVn                                        : integer := 0;   -- Exception Caused by previous instruction
constant BTAn                                         : integer := 1;   -- Branch Target Address Miscompare
constant DEPn                                         : integer := 2;   -- LSU Dependancy Flush
constant IMISSn                                       : integer := 3;   -- I-ERAT Miss
constant IMCHKn                                       : integer := 4;   -- Machine Check Interrupt
constant DBG0n                                        : integer := 5;   -- Debug Interrupt (IVC,IAC)
constant ITLBn                                        : integer := 6;   -- Instruction TLB Interrupt
constant ISTORn                                       : integer := 7;   -- Instruction Storage Interrupt
constant ILRATn                                       : integer := 8;   -- Instruction LRAT Interrupt
constant FPEn                                         : integer := 9;   -- Parity Error Flush
constant PROG0n                                       : integer := 10;  -- Program Interrupt (Illegal Op)
constant PROG1n                                       : integer := 11;  -- Program Interrupt (Privledeged Op)
constant UNAVAILn                                     : integer := 12;  -- FP, AP, or Vector Unavailable
constant PROG2n                                       : integer := 13;  -- Program Interrupt (Unimplemented Op)
constant PROG3n                                       : integer := 14;  -- Program Interrupt (FP or AP Enabled)
constant HPRIVn                                       : integer := 15;  -- Embedded Hypervisor Privilege Interrupt
constant PROG0An                                      : integer := 16;  -- Program Interrupt (tlbwe Illegal MAS settings)
constant DMCHKn                                       : integer := 17;  -- Machine Check Interrupt
constant DTLBn                                        : integer := 18;  -- Data TLB Interrupt
constant DMISSn                                       : integer := 19;  -- D-ERAT Miss
constant DSTORn                                       : integer := 20;  -- Data Storage Interrupt
constant ALIGNn                                       : integer := 21;  -- Alignment Interrupt
constant DLRATn                                       : integer := 22;  -- Data LRAT Interrupt
constant DBG1n                                        : integer := 23;  -- Debug Interrupt (DAC,RET,BRT,TRAP)
constant F2Un                                         : integer := 24;  -- N Flush to uCode
constant FwBSn                                        : integer := 25;  -- N Flush w/Barrier Set
constant Fn                                           : integer := 26;  -- N Flush
constant INSTRnp1                                     : integer := 27;  -- RFI, SC, TRAP Instruction
constant MCHKnp1                                      : integer := 28;  -- Machine Check Interrupt
constant GDBMCHKnp1                                   : integer := 29;  -- Guest Processor Doorbell Machine Check Interrupt
constant DBG3np1                                      : integer := 30;  -- Async Debug Interrupt (UDE,IDE,IRPT)
constant CRITnp1                                      : integer := 31;  -- Critical External Input Interrupt
constant WDOGnp1                                      : integer := 32;  -- Watchdog Interrupt
constant CDBELLnp1                                    : integer := 33;  -- Processor Doorbell Critical Interrupt
constant GCDBELLnp1                                   : integer := 34;  -- Guest Processor Doorbell Critical Interrupt
constant EXTnp1                                       : integer := 35;  -- External Input Interrupt
constant FITnp1                                       : integer := 36;  -- Fixed Interval Timer Interrupt
constant DECnp1                                       : integer := 37;  -- Decrementer Interrupt
constant DBELLnp1                                     : integer := 38;  -- Processor Doorbell
constant GDBELLnp1                                    : integer := 39;  -- Guest Processor Doorbell
constant UDECnp1                                      : integer := 40;  -- User Decrementer
constant PERFnp1                                      : integer := 41;  -- Performance Monitor
constant Fnp1                                         : integer := 42;  -- NP1 Flush
constant TRAP                                         : integer := 0;
constant SC                                           : integer := 1;
constant RFI                                          : integer := 2;
constant FP                                           : integer := 0;
constant AP                                           : integer := 1;
constant VEC                                          : integer := 2;
constant DLK                                          : integer := 0;
constant PT                                           : integer := 1; 
constant VF                                           : integer := 2; 
constant TLBI                                         : integer := 3;
constant RW                                           : integer := 4;
constant UCT                                          : integer := 5;
constant APENA                                        : integer := 0;
constant FPENA                                        : integer := 1;
-- Types
type TID_ARR                                         is array (0 to ifar_repwr-1) of std_ulogic_vector(0 to threads-1);
type DAC                                             is array (1 to 4) of std_ulogic_vector(0 to threads-1);
type DAC_A                                           is array (1 to 2) of std_ulogic_vector(0 to threads-1);
type ARY3                                            is array (0 to threads-1) of std_ulogic_vector(0 to 2);
type ARY4                                            is array (0 to threads-1) of std_ulogic_vector(0 to 3);
type ARY5                                            is array (0 to threads-1) of std_ulogic_vector(0 to 4);
type ARY6                                            is array (0 to threads-1) of std_ulogic_vector(0 to 5);
type ARY7                                            is array (0 to threads-1) of std_ulogic_vector(0 to 6);
type ARY9                                            is array (0 to threads-1) of std_ulogic_vector(0 to 8);
type ARY64                                           is array (0 to threads-1) of std_ulogic_vector(0 to 63);
type ARY_FPRI                                        is array (0 to threads-1) of std_ulogic_vector(0 to Fnp1);
type ARY_IFAR                                        is array (0 to threads-1) of std_ulogic_vector(0 to 61);
type ARY_BLOCK                                       is array (0 to threads-1) of std_ulogic_vector(1 to 7);
subtype  IFAR                                        is std_ulogic_vector(62-eff_ifar to 61);
subtype  IFAR_UC                                     is std_ulogic_vector(62-uc_ifar to 61);
subtype  TID                                         is std_ulogic_vector(0 to threads-1);
-- Latches
signal is2_flush_q                                            : std_ulogic_vector(0 to threads-1);        -- input=>any_flush                  , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal rf0_flush_q                                            : std_ulogic_vector(0 to threads-1);        -- input=>is2_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal rf1_flush_q                                            : std_ulogic_vector(0 to threads-1);        -- input=>rf0_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal rf1_tid_q                                              : std_ulogic_vector(0 to threads-1);        -- input=>dec_cpl_rf0_tid            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex1_axu_act_q                                          : std_ulogic_vector(0 to threads-1);        -- input=>fu_xu_rf1_act              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex1_byte_rev_q,            rf1_byte_rev                : std_ulogic;                               -- input=>rf1_byte_rev               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_flush_q                                            : std_ulogic_vector(0 to threads-1);        -- input=>rf1_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal ex1_is_any_ldstmw_q,       rf1_is_any_ldstmw           : std_ulogic;                               -- input=>rf1_is_any_ldstmw          , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_attn_q,             rf1_is_attn                 : std_ulogic;                               -- input=>rf1_is_attn                , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_dci_q,              ex1_is_dci_d                : std_ulogic;                               -- input=>ex1_is_dci_d               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_dlock_q,            rf1_is_dlock                : std_ulogic;                               -- input=>rf1_is_dlock               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_ehpriv_q,           rf1_is_ehpriv               : std_ulogic;                               -- input=>rf1_is_ehpriv              , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_erativax_q,         rf1_is_erativax             : std_ulogic;                               -- input=>rf1_is_erativax            , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_ici_q,              ex1_is_ici_d                : std_ulogic;                               -- input=>ex1_is_ici_d               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_icswx_q,            rf1_is_icswx                : std_ulogic;                               -- input=>rf1_is_icswx               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_ilock_q,            rf1_is_ilock                : std_ulogic;                               -- input=>rf1_is_ilock               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_isync_q,            rf1_is_isync                : std_ulogic;                               -- input=>rf1_is_isync               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_mfspr_q,            rf1_is_mfspr                : std_ulogic;                               -- input=>rf1_is_mfspr               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_mtmsr_q,            rf1_is_mtmsr                : std_ulogic;                               -- input=>rf1_is_mtmsr               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_mtspr_q,            rf1_is_mtspr                : std_ulogic;                               -- input=>rf1_is_mtspr               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_rfci_q,             rf1_is_rfci                 : std_ulogic;                               -- input=>rf1_is_rfci                , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_rfgi_q,             rf1_is_rfgi                 : std_ulogic;                               -- input=>rf1_is_rfgi                , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_rfi_q,              rf1_is_rfi                  : std_ulogic;                               -- input=>rf1_is_rfi                 , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_rfmci_q,            rf1_is_rfmci                : std_ulogic;                               -- input=>rf1_is_rfmci               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_sc_q,               rf1_is_sc                   : std_ulogic;                               -- input=>rf1_is_sc                  , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_tlbivax_q,          rf1_is_tlbivax              : std_ulogic;                               -- input=>rf1_is_tlbivax             , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_wrtee_q,            rf1_is_wrtee                : std_ulogic;                               -- input=>rf1_is_wrtee               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_wrteei_q,           rf1_is_wrteei               : std_ulogic;                               -- input=>rf1_is_wrteei              , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_mtxucr0_q,          rf1_is_mtxucr0              : std_ulogic;                               -- input=>rf1_is_mtxucr0             , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_is_tlbwe_q,            rf1_is_tlbwe                : std_ulogic;                               -- input=>rf1_is_tlbwe               , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_sc_lev_q,              rf1_sc_lev                  : std_ulogic;                               -- input=>rf1_sc_lev                 , act=>exx_act(0)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_ucode_val_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>rf1_ucode_val              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex1_xu_val_q                                           : std_ulogic_vector(0 to threads-1);        -- input=>rf1_xu_val                 , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex2_axu_act_q                                          : std_ulogic_vector(0 to threads-1);        -- input=>ex1_axu_act_q              , act=>tiup                 , scan=>N, sleep=>N, needs_sreset=>1
signal ex2_any_wrtee_q,           ex2_any_wrtee_d             : std_ulogic;                               -- input=>ex2_any_wrtee_d            , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_br_taken_q                                         : std_ulogic;                               -- input=>ex1_br_taken               , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_br_update_q                                        : std_ulogic;                               -- input=>ex1_br_update              , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_byte_rev_q                                         : std_ulogic;                               -- input=>ex1_byte_rev_q             , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_ctr_dec_update_q                                   : std_ulogic;                               -- input=>ex1_ctr_dec_update         , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_epid_instr_q                                       : std_ulogic;                               -- input=>dec_cpl_ex1_epid_instr     , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_flush_q                                            : std_ulogic_vector(0 to threads-1);        -- input=>ex1_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal ex2_is_attn_q                                          : std_ulogic;                               -- input=>ex1_is_attn_q              , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_dci_q                                           : std_ulogic;                               -- input=>ex1_is_dci_q               , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_dlock_q                                         : std_ulogic;                               -- input=>ex1_is_dlock_q             , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_ehpriv_q                                        : std_ulogic;                               -- input=>ex1_is_ehpriv_q            , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_erativax_q                                      : std_ulogic;                               -- input=>ex1_is_erativax_q          , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_ici_q                                           : std_ulogic;                               -- input=>ex1_is_ici_q               , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_icswx_q                                         : std_ulogic;                               -- input=>ex1_is_icswx_q             , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_ilock_q                                         : std_ulogic;                               -- input=>ex1_is_ilock_q             , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_isync_q                                         : std_ulogic;                               -- input=>ex1_is_isync_q             , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_mtmsr_q                                         : std_ulogic;                               -- input=>ex1_is_mtmsr_q             , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_rfci_q                                          : std_ulogic;                               -- input=>ex1_is_rfci_q              , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_rfgi_q                                          : std_ulogic;                               -- input=>ex1_is_rfgi_q              , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_rfi_q                                           : std_ulogic;                               -- input=>ex1_is_rfi_q               , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_rfmci_q                                         : std_ulogic;                               -- input=>ex1_is_rfmci_q             , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_sc_q                                            : std_ulogic;                               -- input=>ex1_is_sc_q                , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_slowspr_wr_q                                    : std_ulogic;                               -- input=>dec_cpl_ex1_is_slowspr_wr  , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_tlbivax_q                                       : std_ulogic;                               -- input=>ex1_is_tlbivax_q           , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_is_tlbwe_q                                         : std_ulogic;                               -- input=>ex1_is_tlbwe_q             , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_lr_update_q                                        : std_ulogic;                               -- input=>ex1_lr_update              , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_n_align_int_q,         ex2_n_align_int_d           : std_ulogic;                               -- input=>ex2_n_align_int_d          , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_sc_lev_q                                           : std_ulogic;                               -- input=>ex1_sc_lev_q               , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_taken_bclr_q                                       : std_ulogic;                               -- input=>ex1_taken_bclr             , act=>exx_act(1)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex2_ucode_val_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>ex1_ucode_val              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex2_xu_val_q                                           : std_ulogic_vector(0 to threads-1);        -- input=>ex1_xu_val                 , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex2_is_mtxucr0_q                                       : std_ulogic;                               -- input=>ex1_is_mtxucr0_q          , act=>exx_act(1)            , scan=>N, sleep=>N, needs_sreset=>0
signal ex3_async_int_block_q,     ex3_async_int_block_d       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_async_int_block_d      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_axu_instr_match_q                                  : std_ulogic_vector(0 to threads-1);        -- input=>fu_xu_ex2_instr_match      , act=>ex2_axu_act_q        , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_axu_instr_type_q                                   : std_ulogic_vector(0 to 3*threads-1);      -- input=>fu_xu_ex2_instr_type       , act=>ex2_axu_act_q        , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_axu_is_ucode_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>fu_xu_ex2_is_ucode         , act=>ex2_axu_act_q        , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_axu_val_q                                          : std_ulogic_vector(0 to threads-1);        -- input=>ex2_axu_val                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_br_flush_ifar_q                                    : std_ulogic_vector(62-eff_ifar to 61);     -- input=>ex2_br_flush_ifar          , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_br_taken_q                                         : std_ulogic;                               -- input=>ex2_br_taken_q             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_br_update_q                                        : std_ulogic;                               -- input=>ex2_br_update_q            , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_byte_rev_q                                         : std_ulogic;                               -- input=>ex2_byte_rev_q             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_ctr_dec_update_q                                   : std_ulogic;                               -- input=>ex2_ctr_dec_update_q       , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_div_coll_q,            ex3_div_coll_d              : std_ulogic_vector(0 to threads-1);        -- input=>ex3_div_coll_d             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_epid_instr_q                                       : std_ulogic;                               -- input=>ex2_epid_instr_q           , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_flush_q                                            : std_ulogic_vector(0 to threads-1);        -- input=>ex2_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_ierat_flush_req_q                                  : std_ulogic_vector(0 to threads-1);        -- input=>iu_xu_ierat_ex2_flush_req  , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_illegal_op_q                                       : std_ulogic;                               -- input=>dec_cpl_ex2_illegal_op     , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_any_load_dac_q                                  : std_ulogic;                               -- input=>dec_cpl_ex2_is_any_load_dac, act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_any_store_dac_q                                 : std_ulogic;                               --input=>dec_cpl_ex2_is_any_store_dac, act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_attn_q                                          : std_ulogic;                               -- input=>ex2_is_attn_q              , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_dci_q                                           : std_ulogic;                               -- input=>ex2_is_dci_q               , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_dlock_q                                         : std_ulogic;                               -- input=>ex2_is_dlock_q             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_ehpriv_q                                        : std_ulogic;                               -- input=>ex2_is_ehpriv_q            , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_ici_q                                           : std_ulogic;                               -- input=>ex2_is_ici_q               , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_icswx_q                                         : std_ulogic;                               -- input=>ex2_is_icswx_q             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_ilock_q                                         : std_ulogic;                               -- input=>ex2_is_ilock_q             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_isync_q                                         : std_ulogic;                               -- input=>ex2_is_isync_q             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_mtmsr_q                                         : std_ulogic;                               -- input=>ex2_is_mtmsr_q             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_rfci_q                                          : std_ulogic;                               -- input=>ex2_is_rfci_q              , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_rfgi_q                                          : std_ulogic;                               -- input=>ex2_is_rfgi_q              , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_rfi_q                                           : std_ulogic;                               -- input=>ex2_is_rfi_q               , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_rfmci_q                                         : std_ulogic;                               -- input=>ex2_is_rfmci_q             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_sc_q                                            : std_ulogic;                               -- input=>ex2_is_sc_q                , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_tlbwe_q                                         : std_ulogic;                               -- input=>ex2_is_tlbwe_q             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_is_slowspr_wr_q                                    : std_ulogic;                               -- input=>ex2_is_slowspr_wr_q        , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_iu_error_q,            ex3_iu_error_d              : std_ulogic_vector(1 to 7);                -- input=>ex3_iu_error_d             , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_lr_update_q                                        : std_ulogic;                               -- input=>ex2_lr_update_q            , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_lrat_miss_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_lrat_miss            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_mmu_esr_data_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_esr_data             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_mmu_esr_epid_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_esr_epid             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_mmu_esr_pt_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_esr_pt               , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_mmu_esr_st_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_esr_st               , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_mmu_hv_priv_q                                      : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_hv_priv              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_mtiar_q,               ex2_mtiar                   : std_ulogic;                               -- input=>ex2_mtiar                  , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_n_align_int_q                                      : std_ulogic;                               -- input=>ex2_n_align_int_q          , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_n_dcpe_flush_q,        ex3_n_dcpe_flush_d          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_dcpe_flush_d         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_n_l2_ecc_err_flush_q                               : std_ulogic_vector(0 to threads-1);        -- input=>lsu_xu_l2_ecc_err_flush    , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_np1_run_ctl_flush_q                                : std_ulogic_vector(0 to threads-1);        -- input=>spr_cpl_ex2_run_ctl_flush  , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_sc_lev_q                                           : std_ulogic;                               -- input=>ex2_sc_lev_q               , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_taken_bclr_q                                       : std_ulogic;                               -- input=>ex2_taken_bclr_q           , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_tlb_inelig_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_tlb_inelig           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_tlb_local_snoop_reject_q                           : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_local_snoop_reject   , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_tlb_lru_par_err_q                                  : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_lru_par_err          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_tlb_illeg_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_illeg_instr          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_tlb_miss_q                                         : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_tlb_miss             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_tlb_multihit_err_q                                 : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_tlb_multihit_err     , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_tlb_par_err_q                                      : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_tlb_par_err          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_tlb_pt_fault_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_pt_fault             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_ucode_val_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>ex2_ucode_val              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_xu_instr_match_q                                   : std_ulogic;                               -- input=>dec_cpl_ex2_match          , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_xu_is_ucode_q                                      : std_ulogic;                               -- input=>dec_cpl_ex2_is_ucode       , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_xu_val_q                                           : std_ulogic_vector(0 to threads-1);        -- input=>ex2_xu_val                 , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_axu_async_block_q                                  : std_ulogic_vector(0 to threads-1);        -- input=>fu_xu_ex2_async_block      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex3_is_mtxucr0_q                                       : std_ulogic;                               -- input=>ex2_is_mtxucr0_q           , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_np1_instr_flush_q,     ex3_np1_instr_flush_d       : std_ulogic;                               -- input=>ex3_np1_instr_flush_d      , act=>exx_act(2)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_apena_prog_int_q,      ex3_n_apena_prog_int        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_apena_prog_int       , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_axu_is_ucode_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>ex3_axu_is_ucode_q         , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_axu_trap_q                                         : std_ulogic_vector(0 to threads-1);        -- input=>fu_xu_ex3_trap             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_axu_val_q                                          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_axu_val                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_base_int_block_q                                   : std_ulogic_vector(0 to threads-1);        -- input=>ex3_base_int_block         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_br_flush_ifar_q                                    : std_ulogic_vector(62-eff_ifar to 61);     -- input=>ex3_br_flush_ifar_q        , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_br_taken_q                                         : std_ulogic;                               -- input=>ex3_br_taken_q             , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_br_update_q                                        : std_ulogic;                               -- input=>ex3_br_update_q            , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_byte_rev_q                                         : std_ulogic;                               -- input=>ex3_byte_rev_q             , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_ctr_dec_update_q                                   : std_ulogic;                               -- input=>ex3_ctr_dec_update_q       , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_debug_flush_en_q,      ex4_debug_flush_en_d        : std_ulogic_vector(0 to threads-1);        -- input=>ex4_debug_flush_en_d       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_debug_int_en_q,        ex3_debug_int_en            : std_ulogic_vector(0 to threads-1);        -- input=>ex3_debug_int_en           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_flush_q                                            : std_ulogic_vector(0 to threads-1);        -- input=>ex3_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_fpena_prog_int_q,      ex3_n_fpena_prog_int        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_fpena_prog_int       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_iac1_cmpr_q,           ex3_iac1_cmpr               : std_ulogic_vector(0 to threads-1);        -- input=>ex3_iac1_cmpr              , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_iac2_cmpr_q,           ex3_iac2_cmpr               : std_ulogic_vector(0 to threads-1);        -- input=>ex3_iac2_cmpr              , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_iac3_cmpr_q,           ex3_iac3_cmpr               : std_ulogic_vector(0 to threads-1);        -- input=>ex3_iac3_cmpr              , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_iac4_cmpr_q,           ex3_iac4_cmpr               : std_ulogic_vector(0 to threads-1);        -- input=>ex3_iac4_cmpr              , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_instr_cpl_q,           ex4_instr_cpl_d             : std_ulogic_vector(0 to threads-1);        -- input=>ex4_instr_cpl_d            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_is_any_load_dac_q                                  : std_ulogic;                               -- input=>ex3_is_any_load_dac_q      , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_is_any_store_dac_q                                 : std_ulogic;                               -- input=>ex3_is_any_store_dac_q     , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_is_attn_q                                          : std_ulogic;                               -- input=>ex3_is_attn_q              , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_is_dci_q                                           : std_ulogic;                               -- input=>ex3_is_dci_q               , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_is_ehpriv_q                                        : std_ulogic;                               -- input=>ex3_is_ehpriv_q            , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_is_ici_q                                           : std_ulogic;                               -- input=>ex3_is_ici_q               , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_is_isync_q                                         : std_ulogic;                               -- input=>ex3_is_isync_q             , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_is_mtmsr_q                                         : std_ulogic;                               -- input=>ex3_is_mtmsr_q             , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_is_tlbwe_q                                         : std_ulogic;                               -- input=>ex3_is_tlbwe_q             , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_is_slowspr_wr_q                                    : std_ulogic;                               -- input=>ex3_is_slowspr_wr_q        , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_lr_update_q                                        : std_ulogic;                               -- input=>ex3_lr_update_q            , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_mcsr_q,                ex4_mcsr_d                  : std_ulogic_vector(0 to 14*threads-1);     -- input=>ex4_mcsr_d                 , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_mem_attr_q                                         : std_ulogic_vector(lsu_xu_ex3_attr'range); -- input=>lsu_xu_ex3_attr            , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_mmu_esr_data_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>ex3_mmu_esr_data_q         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_mmu_esr_epid_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>ex3_mmu_esr_epid_q         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_mmu_esr_pt_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_mmu_esr_pt_q           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_mmu_esr_st_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_mmu_esr_st_q           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_mmu_esr_val_q,         ex4_mmu_esr_val_d           : std_ulogic_vector(0 to threads-1);        -- input=>ex4_mmu_esr_val_d          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_mmu_hold_val_q,        ex3_mmu_hold_val            : std_ulogic_vector(0 to threads-1);        -- input=>ex3_mmu_hold_val           , act=>tiup                 , scan=>Y, sleep=>Y, needs_sreset=>1
signal ex4_mtdp_nr_q                                          : std_ulogic;                               -- input=>dec_cpl_ex3_mtdp_nr        , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_mtiar_q                                            : std_ulogic;                               -- input=>ex3_mtiar_q                , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_n_2ucode_flush_q,      ex3_n_2ucode_flush          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_2ucode_flush         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_align_int_q,         ex3_n_align_int             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_align_int            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_any_hpriv_int_q,     ex4_n_any_hpriv_int_d       : std_ulogic_vector(0 to threads-1);        -- input=>ex4_n_any_hpriv_int_d      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_any_unavail_int_q,   ex3_n_any_unavail_int       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_any_unavail_int      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ap_unavail_int_q,    ex3_n_ap_unavail_int        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_ap_unavail_int       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_barr_flush_q,        ex3_n_barr_flush            : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_barr_flush           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_bclr_ta_miscmpr_flush_q,ex3_n_bclr_ta_miscmpr_flush : std_ulogic_vector(0 to threads-1);     -- input=>ex3_n_bclr_ta_miscmpr_flush, act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_brt_dbg_cint_q,      ex3_n_brt_dbg_cint          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_brt_dbg_cint         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_dac_dbg_cint_q,      ex3_n_dac_dbg_cint          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_dac_dbg_cint         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ddmh_mchk_en_q,      ex4_n_ddmh_mchk_en_d        : std_ulogic_vector(0 to threads-1);        -- input=>ex4_n_ddmh_mchk_en_d       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_dep_flush_q,         ex3_n_dep_flush             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_dep_flush            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_deratre_par_mchk_mcint_q,ex3_n_deratre_par_mchk_mcint : std_ulogic_vector(0 to threads-1);  -- input=>ex3_n_deratre_par_mchk_mcint, act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_dlk0_dstor_int_q,    ex3_n_dlk0_dstor_int        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_dlk0_dstor_int       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_dlk1_dstor_int_q,    ex3_n_dlk1_dstor_int        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_dlk1_dstor_int       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_dlrat_int_q,         ex3_n_dlrat_int             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_dlrat_int            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_dmchk_mcint_q,       ex3_n_dmchk_mcint           : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_dmchk_mcint          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_dmiss_flush_q,       ex3_n_dmiss_flush           : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_dmiss_flush          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_dstor_int_q,         ex3_n_dstor_int             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_dstor_int            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_dtlb_int_q,          ex3_n_dtlb_int              : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_dtlb_int             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ena_prog_int_q,      ex3_n_ena_prog_int          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_ena_prog_int         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_flush_q,             ex3_n_flush                 : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_flush                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_pe_flush_q,          ex3_n_pe_flush              : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_pe_flush             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_tlb_mchk_flush_q,    ex3_n_tlb_mchk_flush        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_tlb_mchk_flush       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_fp_unavail_int_q,    ex3_n_fp_unavail_int        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_fp_unavail_int       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_fu_rfpe_flush_q,     ex4_n_fu_rfpe_flush_d       : std_ulogic_vector(0 to threads-1);        -- input=>ex4_n_fu_rfpe_flush_d      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_iac_dbg_cint_q,      ex3_n_iac_dbg_cint          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_iac_dbg_cint         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ieratre_par_mchk_mcint_q,ex3_n_ieratre_par_mchk_mcint : std_ulogic_vector(0 to threads-1);  -- input=>ex3_n_ieratre_par_mchk_mcint, act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ilrat_int_q,         ex3_n_ilrat_int             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_ilrat_int            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_imchk_mcint_q,       ex3_n_imchk_mcint           : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_imchk_mcint          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_imiss_flush_q,       ex3_n_imiss_flush           : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_imiss_flush          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_instr_dbg_cint_q,    ex3_n_instr_dbg_cint        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_instr_dbg_cint       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_istor_int_q,         ex3_n_istor_int             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_istor_int            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_itlb_int_q,          ex3_n_itlb_int              : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_itlb_int             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ivc_dbg_cint_q,      ex3_n_ivc_dbg_cint          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_ivc_dbg_cint         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ivc_dbg_match_q,     ex3_n_ivc_dbg_match         : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_ivc_dbg_match        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ldq_hit_flush_q,     ex3_n_ldq_hit_flush         : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_ldq_hit_flush        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_lsu_ddmh_flush_en_q, ex4_n_lsu_ddmh_flush_en_d   : std_ulogic_vector(0 to threads-1);        -- input=>ex4_n_lsu_ddmh_flush_en_d  , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_lsu_flush_q,         ex3_n_lsu_flush             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_lsu_flush            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_memattr_miscmpr_flush_q,ex3_n_memattr_miscmpr_flush : std_ulogic_vector(0 to threads-1);     -- input=>ex3_n_memattr_miscmpr_flush, act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_mmu_hpriv_int_q,     ex3_n_mmu_hpriv_int         : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_mmu_hpriv_int        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_pil_prog_int_q,      ex3_n_pil_prog_int          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_pil_prog_int         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ppr_prog_int_q,      ex3_n_ppr_prog_int          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_ppr_prog_int         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ptemiss_dlrat_int_q, ex3_n_ptemiss_dlrat_int     : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_ptemiss_dlrat_int    , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_puo_prog_int_q,      ex3_n_puo_prog_int          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_puo_prog_int         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ret_dbg_cint_q,      ex3_n_ret_dbg_cint          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_ret_dbg_cint         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_thrctl_stop_flush_q, ex3_n_thrctl_stop_flush     : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_thrctl_stop_flush    , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_tlbwemiss_dlrat_int_q,ex3_n_tlbwemiss_dlrat_int   : std_ulogic_vector(0 to threads-1);       -- input=>ex3_n_tlbwemiss_dlrat_int  , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_tlbwe_pil_prog_int_q,ex3_n_tlbwe_pil_prog_int    : std_ulogic_vector(0 to threads-1);       -- input=>ex3_n_tlbwe_pil_prog_int    , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_trap_dbg_cint_q,     ex3_n_trap_dbg_cint         : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_trap_dbg_cint        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_uct_dstor_int_q,     ex3_n_uct_dstor_int         : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_uct_dstor_int        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_vec_unavail_int_q,   ex3_n_vec_unavail_int       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_vec_unavail_int      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_vf_dstor_int_q,      ex3_n_vf_dstor_int          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_vf_dstor_int         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_xu_rfpe_flush_q,     ex4_n_xu_rfpe_flush_d       : std_ulogic_vector(0 to threads-1);        -- input=>ex4_n_xu_rfpe_flush_d      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_cdbell_cint_q,     ex3_np1_cdbell_cint         : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_cdbell_cint        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_crit_cint_q,       ex3_np1_crit_cint           : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_crit_cint          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_dbell_int_q,       ex3_np1_dbell_int           : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_dbell_int          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_dec_int_q,         ex3_np1_dec_int             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_dec_int            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_ext_int_q,         ex3_np1_ext_int             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_ext_int            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_ext_mchk_mcint_q,  ex3_np1_ext_mchk_mcint      : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_ext_mchk_mcint     , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_fit_int_q,         ex3_np1_fit_int             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_fit_int            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_flush_q,           ex3_np1_flush               : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_flush              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_gcdbell_cint_q,    ex3_np1_gcdbell_cint        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_gcdbell_cint       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_gdbell_int_q,      ex3_np1_gdbell_int          : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_gdbell_int         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_gmcdbell_cint_q,   ex3_np1_gmcdbell_cint       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_gmcdbell_cint      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_ide_dbg_cint_q,    ex3_np1_ide_dbg_cint        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_ide_dbg_cint       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_instr_int_q,       ex3_np1_instr_int           : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_instr_int          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_perf_int_q,        ex3_np1_perf_int            : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_perf_int           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_ptr_prog_int_q,    ex3_np1_ptr_prog_int        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_ptr_prog_int       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_rfi_q,             ex3_np1_rfi                 : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_rfi                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_run_ctl_flush_q,   ex3_np1_run_ctl_flush       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_run_ctl_flush      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_sc_int_q,          ex3_np1_sc_int              : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_sc_int             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_ude_dbg_cint_q,    ex3_np1_ude_dbg_cint        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_ude_dbg_cint       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_ude_dbg_event_q,   ex3_np1_ude_dbg_event       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_ude_dbg_event      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_udec_int_q,        ex3_np1_udec_int            : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_udec_int           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_wdog_cint_q,       ex3_np1_wdog_cint           : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_wdog_cint          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_np1_fu_flush_q,        ex3_np1_fu_flush            : std_ulogic_vector(0 to threads-1);        -- input=>ex3_np1_fu_flush           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_ieratsx_par_mchk_mcint_q,ex3_n_ieratsx_par_mchk_mcint : std_ulogic_vector(0 to threads-1);   -- input=>ex3_n_ieratsx_par_mchk_mcint,act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_tlbmh_mchk_mcint_q                               : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_tlbmh_mchk_mcint     , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_sprg_ue_flush_q                                  : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_sprg_ue_flush        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_rwaccess_dstor_int_q, ex3_n_rwaccess_dstor_int   : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_rwaccess_dstor_int   , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_exaccess_istor_int_q, ex3_n_exaccess_istor_int   : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_exaccess_istor_int   , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_sc_lev_q                                           : std_ulogic;                               -- input=>ex3_sc_lev_q               , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_siar_sel_q,            ex4_siar_sel_d              : std_ulogic_vector(0 to 1);                -- input=>ex4_siar_sel_d             , act=>ex4_siar_sel_act     , scan=>Y, sleep=>N, needs_sreset=>0, init=>1
signal ex4_step_q,                ex4_step_d                  : std_ulogic_vector(0 to threads-1);        -- input=>ex4_step_d                 , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_taken_bclr_q                                       : std_ulogic;                               -- input=>ex3_taken_bclr_q           , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_tlb_inelig_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_tlb_inelig_q           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_ucode_val_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>ex3_ucode_val              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_xu_is_ucode_q                                      : std_ulogic;                               -- input=>ex3_xu_is_ucode_q          , act=>exx_act(3)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_xu_val_q                                           : std_ulogic_vector(0 to threads-1);        -- input=>ex3_xu_val                 , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_cia_act_q,             ex3_cia_act                 : std_ulogic_vector(0 to threads-1);        -- input=>ex3_cia_act                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_n_async_dacr_dbg_cint_q, ex3_n_async_dacr_dbg_cint : std_ulogic_vector(0 to threads-1);        -- input=>ex3_n_async_dacr_dbg_cint  , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_dac1r_cmpr_async_q,     ex4_dac1r_cmpr_async_d     : std_ulogic_vector(0 to threads-1);        -- input=>ex4_dacr_cmpr_d            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_dac2r_cmpr_async_q,     ex4_dac2r_cmpr_async_d     : std_ulogic_vector(0 to threads-1);        -- input=>ex4_dacw_cmpr_d            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_thread_stop_q,         ex3_thread_stop             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_thread_stop            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_icmp_event_on_int_ok_q, ex4_icmp_event_on_int_ok   : std_ulogic_vector(0 to threads-1);        -- input=>ex4_icmp_event_on_int_ok   , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_any_val_q                                          : std_ulogic_vector(0 to threads-1);        -- input=>ex4_any_val                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_attn_flush_q,          ex4_attn_flush              : std_ulogic_vector(0 to threads-1);        -- input=>ex4_attn_flush             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_axu_trap_pie_q,        ex5_axu_trap_pie_d          : std_ulogic_vector(0 to threads-1);        -- input=>ex5_axu_trap_pie_d         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_br_taken_q                                         : std_ulogic;                               -- input=>ex4_br_taken_q             , act=>exx_act(4)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_cdbell_taken_q,        ex5_cdbell_taken_d          : std_ulogic_vector(0 to threads-1);        -- input=>ex5_cdbell_taken_d         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_check_bclr_q,          ex5_check_bclr_d            : std_ulogic_vector(0 to threads-1);        -- input=>ex5_check_bclr_d           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_cia_p1_q,              ex5_cia_p1_d                : std_ulogic_vector(62-eff_ifar to 61);     -- input=>ex5_cia_p1_d               , act=>exx_act(4)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_dbell_taken_q,         ex5_dbell_taken_d           : std_ulogic_vector(0 to threads-1);        -- input=>ex5_dbell_taken_d          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_dbsr_update_q,         ex4_dbsr_update             : std_ulogic_vector(0 to threads-1);        -- input=>ex4_dbsr_update            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_dear_update_saved_q,   ex5_dear_update_saved_d     : std_ulogic_vector(0 to threads-1);        -- input=>ex5_dear_update_saved_d    , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_deratre_par_err_q                                  : std_ulogic_vector(0 to threads-1);        -- input=>lsu_xu_ex4_derat_par_err   , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_div_set_barr_q,        ex5_div_set_barr_d          : std_ulogic_vector(0 to threads-1);        -- input=>ex5_div_set_barr_d         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_dsigs_q,               ex5_dsigs_d                 : std_ulogic_vector(0 to threads-1);        -- input=>ex5_dsigs_d                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_dtlbgs_q,              ex5_dtlbgs_d                : std_ulogic_vector(0 to threads-1);        -- input=>ex5_dtlbgs_d               , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_err_nia_miscmpr_q,     ex5_err_nia_miscmpr_d       : std_ulogic_vector(0 to threads-1);        -- input=>ex5_err_nia_miscmpr_d      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_ext_dbg_err_q,         ex5_ext_dbg_err_d           : std_ulogic_vector(0 to threads-1);        -- input=>ex5_ext_dbg_err_d          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_ext_dbg_ext_q,         ex5_ext_dbg_ext_d           : std_ulogic_vector(0 to threads-1);        -- input=>ex5_ext_dbg_ext_d          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_extgs_q,               ex5_extgs_d                 : std_ulogic_vector(0 to threads-1);        -- input=>ex5_extgs_d                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_flush_q                                            : std_ulogic_vector(0 to threads-1);        -- input=>ex4_flush                  , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_force_gsrr_q,          ex5_force_gsrr_d            : std_ulogic_vector(0 to threads-1);        -- input=>ex5_force_gsrr_d           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_gcdbell_taken_q,       ex5_gcdbell_taken_d         : std_ulogic_vector(0 to threads-1);        -- input=>ex5_gcdbell_taken_d        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_gdbell_taken_q,        ex5_gdbell_taken_d          : std_ulogic_vector(0 to threads-1);        -- input=>ex5_gdbell_taken_d         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_gmcdbell_taken_q,      ex5_gmcdbell_taken_d        : std_ulogic_vector(0 to threads-1);        -- input=>ex5_gmcdbell_taken_d       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_ieratre_par_err_q                                  : std_ulogic_vector(0 to threads-1);        -- input=>iu_xu_ierat_ex4_par_err    , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_in_ucode_q,            ex5_in_ucode_d              : std_ulogic_vector(0 to threads-1);        -- input=>ex5_in_ucode_d             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_instr_cpl_q,           ex4_instr_cpl               : std_ulogic_vector(0 to threads-1);        -- input=>ex4_instr_cpl              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_is_any_rfi_q,          ex4_is_any_rfi              : std_ulogic_vector(0 to threads-1);        -- input=>ex4_is_any_rfi             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_is_attn_q,             ex5_is_attn_d               : std_ulogic_vector(0 to threads-1);        -- input=>ex5_is_attn_d              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_is_crit_int_q                                      : std_ulogic_vector(0 to threads-1);        -- input=>ex4_is_crit_int            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_is_mchk_int_q                                      : std_ulogic_vector(0 to threads-1);        -- input=>ex4_is_mchk_int            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_is_mtmsr_q                                         : std_ulogic;                               -- input=>ex4_is_mtmsr_q             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_is_isync_q                                         : std_ulogic;                               -- input=>ex4_is_isync_q             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_is_tlbwe_q                                         : std_ulogic;                               -- input=>ex4_is_tlbwe_q             , act=>exx_act(4)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_isigs_q,               ex5_isigs_d                 : std_ulogic_vector(0 to threads-1);        -- input=>ex5_isigs_d                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_itlbgs_q,              ex5_itlbgs_d                : std_ulogic_vector(0 to threads-1);        -- input=>ex5_itlbgs_d               , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_lsu_set_barr_q,        ex5_lsu_set_barr_d          : std_ulogic_vector(0 to threads-1);        -- input=>ex5_lsu_set_barr_d         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_mem_attr_val_q,        ex4_mem_attr_val            : std_ulogic_vector(0 to threads-1);        -- input=>ex4_mem_attr_val           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_mmu_hold_val_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>ex4_mmu_hold_val_q         , act=>tiup                 , scan=>Y, sleep=>Y, needs_sreset=>1
signal ex5_n_dmiss_flush_q,       ex4_n_dmiss_flush           : std_ulogic_vector(0 to threads-1);        -- input=>ex4_n_dmiss_flush          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_n_ext_dbg_stopc_flush_q,ex5_n_ext_dbg_stopc_flush_d : std_ulogic;                              -- input=>ex5_n_ext_dbg_stopc_flush_d, act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_n_ext_dbg_stopt_flush_q,ex5_n_ext_dbg_stopt_flush_d : std_ulogic_vector(0 to threads-1);       -- input=>ex5_n_ext_dbg_stopt_flush_d, act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_n_imiss_flush_q,       ex4_n_imiss_flush           : std_ulogic_vector(0 to threads-1);        -- input=>ex4_n_imiss_flush          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_n_ptemiss_dlrat_int_q                              : std_ulogic_vector(0 to threads-1);        -- input=>ex4_n_ptemiss_dlrat_int_q  , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_np1_icmp_dbg_cint_q,   ex5_np1_icmp_dbg_cint_d     : std_ulogic_vector(0 to threads-1);        -- input=>ex5_np1_icmp_dbg_cint_d    , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_np1_icmp_dbg_event_q,  ex5_np1_icmp_dbg_event_d    : std_ulogic_vector(0 to threads-1);        -- input=>ex5_np1_icmp_dbg_event_d   , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_np1_run_ctl_flush_q,   ex4_np1_run_ctl_flush       : std_ulogic_vector(0 to threads-1);        -- input=>ex4_np1_run_ctl_flush      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_dbsr_ide_q,            ex5_dbsr_ide_d              : std_ulogic_vector(0 to threads-1);        -- input=>ex5_dbsr_ide_d             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_perf_dtlb_q,           ex5_perf_dtlb_d             : std_ulogic_vector(0 to threads-1);        -- input=>ex5_perf_dtlb_d            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_perf_itlb_q,           ex5_perf_itlb_d             : std_ulogic_vector(0 to threads-1);        -- input=>ex5_perf_itlb_d            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_ram_done_q,            ex5_ram_done_d              : std_ulogic;                               -- input=>ex5_ram_done_d             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_ram_issue_q,           ex5_ram_issue_d             : std_ulogic_vector(0 to threads-1);        -- input=>ex5_ram_issue_d            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_rt_q                                               : std_ulogic_vector(64-regsize to 63);      -- input=>mux_cpl_ex4_rt             , act=>exx_act(4)           , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_sel_rt_q,              ex5_sel_rt_d                : std_ulogic_vector(0 to threads-1);        -- input=>ex5_sel_rt_d               , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_srr0_dec_q,            ex5_srr0_dec_d              : std_ulogic_vector(0 to threads-1);        -- input=>ex5_srr0_dec_d             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_tlb_inelig_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex4_tlb_inelig_q           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_uc_cia_val_q,          ex5_uc_cia_val_d            : std_ulogic_vector(0 to threads-1);        -- input=>ex5_uc_cia_val_d           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_xu_ifar_q,             ex5_xu_ifar_d               : IFAR;                                     -- input=>ex5_xu_ifar_d              , act=>exx_act(4)           , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_xu_val_q                                           : std_ulogic_vector(0 to threads-1);        -- input=>ex4_xu_val                 , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_n_flush_sprg_ue_flush_q, ex4_n_flush_sprg_ue_flush : std_ulogic_vector(0 to threads-1);        -- input=>ex4_n_flush_sprg_ue_flush  , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_mcsr_act_q                                         : std_ulogic_vector(0 to threads-1);        -- input=>ex4_mcsr_act               , act=>tiup                , scan=>Y, sleep=>N, needs_sreset=>1
signal ex6_mcsr_act_q,            ex6_mcsr_act_d              : std_ulogic;                               -- input=>ex6_mcsr_act_d             , act=>tiup                , scan=>Y, sleep=>N, needs_sreset=>1
signal ex6_late_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex5_late_flush_q(0)        , act=>tiup                 , scan=>N, sleep=>N, needs_sreset=>1
signal ex6_mmu_hold_val_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>ex5_mmu_hold_val_q         , act=>tiup                 , scan=>N, sleep=>Y, needs_sreset=>1
signal ex6_ram_done_q                                         : std_ulogic;                               -- input=>ex5_ram_done_q             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex6_ram_interrupt_q,       ex6_ram_interrupt_d         : std_ulogic;                               -- input=>ex6_ram_interrupt_d        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex6_ram_issue_q,           ex6_ram_issue_d             : std_ulogic_vector(0 to threads-1);        -- input=>ex6_ram_issue_d            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex7_ram_issue_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>ex6_ram_issue_q            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex8_ram_issue_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>ex7_ram_issue_q            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex6_set_barr_q,            ex6_set_barr_d              : std_ulogic_vector(0 to threads-1);        -- input=>ex6_set_barr_d             , act=>tiup                 , scan=>N, sleep=>N, needs_sreset=>1
signal ex6_step_done_q,           ex5_step_done               : std_ulogic_vector(0 to threads-1);        -- input=>ex5_step_done              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex6_xu_val_q                                           : std_ulogic_vector(0 to threads-1);        -- input=>ex5_xu_val_q               , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex6_is_tlbwe_q                                         : std_ulogic;                               -- input=>ex5_is_tlbwe_q             , act=>tiup                 , scan=>N, sleep=>N, needs_sreset=>0
signal ex7_is_tlbwe_q,            ex7_is_tlbwe_d              : std_ulogic_vector(0 to threads-1);        -- input=>ex7_is_tlbwe_d             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex8_is_tlbwe_q                                         : std_ulogic_vector(0 to threads-1);        -- input=>ex7_is_tlbwe_q             , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ccr2_ap_q                                              : std_ulogic_vector(0 to threads-1);        -- input=>spr_ccr2_ap                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal cpl_quiesced_q,            cpl_quiesced_d              : std_ulogic_vector(0 to threads-1);        -- input=>cpl_quiesced_d             , act=>tiup                 , scan=>Y, sleep=>Y, needs_sreset=>1
signal dbcr0_idm_q                                            : std_ulogic_vector(0 to threads-1);        -- input=>spr_dbcr0_idm              , act=>spr_bit_act_q          , scan=>Y, sleep=>N, needs_sreset=>1
signal dci_val_q,                 dci_val_d                   : std_ulogic;                               -- input=>dci_val_d                  , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal debug_event_en_q,          debug_event_en_d            : std_ulogic_vector(0 to threads-1);        -- input=>debug_event_en_d           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal derat_hold_present_q,      derat_hold_present_d        : std_ulogic_vector(0 to threads-1);        -- input=>derat_hold_present_d       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ext_dbg_act_err_q,         ext_dbg_act_err_d           : std_ulogic_vector(0 to threads-1);        -- input=>ext_dbg_act_err_d          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ext_dbg_act_ext_q,         ext_dbg_act_ext_d           : std_ulogic_vector(0 to threads-1);        -- input=>ext_dbg_act_ext_d          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ext_dbg_stop_core_q,       ext_dbg_stop_core_d         : std_ulogic_vector(0 to threads-1);        -- input=>ext_dbg_stop_core_d        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ext_dbg_stop_n_q,          ext_dbg_stop_n_d            : std_ulogic_vector(0 to threads-1);        -- input=>ext_dbg_stop_n_d           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal external_mchk_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>spr_cpl_external_mchk        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal exx_instr_async_block_q,   exx_instr_async_block_d     : ARY_BLOCK;                                -- input=>exx_instr_async_block_d    , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal exx_multi_flush_q,         exx_multi_flush_d           : std_ulogic_vector(0 to threads-1);        -- input=>exx_multi_flush_d          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal force_ude_q                                            : std_ulogic_vector(0 to threads-1);        -- input=>pc_xu_force_ude            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal fu_rf_seq_end_q                                        : std_ulogic;                               -- input=>fu_xu_regfile_seq_end      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal fu_rfpe_ack_q,             fu_rfpe_ack_d               : std_ulogic_vector(0 to 1);                -- input=>fu_rfpe_ack_d              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal fu_rfpe_hold_present_q,    fu_rfpe_hold_present_d      : std_ulogic;                               -- input=>fu_rfpe_hold_present_d     , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ici_hold_present_q,        ici_hold_present_d          : std_ulogic_vector(0 to 2);                -- input=>ici_hold_present_d         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ici_val_q,                 ici_val_d                   : std_ulogic;                               -- input=>ici_val_d                  , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ierat_hold_present_q,      ierat_hold_present_d        : std_ulogic_vector(0 to threads-1);        -- input=>ierat_hold_present_d       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal mmu_eratmiss_done_q                                    : std_ulogic_vector(0 to threads-1);        -- input=>mm_xu_eratmiss_done        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal mmu_hold_present_q,        mmu_hold_present_d          : std_ulogic_vector(0 to threads-1);        -- input=>mmu_hold_present_d         , act=>tiup                 , scan=>Y, sleep=>Y, needs_sreset=>1
signal mmu_hold_request_q,        mmu_hold_request_d          : std_ulogic_vector(0 to threads-1);        -- input=>mmu_hold_request_d         , act=>tiup                 , scan=>Y, sleep=>Y, needs_sreset=>1
signal msr_cm_q                                               : std_ulogic_vector(0 to threads-1);        -- input=>spr_msr_cm                 , act=>spr_bit_w_int_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal msr_de_q                                               : std_ulogic_vector(0 to threads-1);        -- input=>spr_msr_de                 , act=>spr_bit_w_int_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal msr_fp_q                                               : std_ulogic_vector(0 to threads-1);        -- input=>spr_msr_fp                 , act=>spr_bit_w_int_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal msr_gs_q                                               : std_ulogic_vector(0 to threads-1);        -- input=>spr_msr_gs                 , act=>spr_bit_w_int_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal msr_me_q                                               : std_ulogic_vector(0 to threads-1);        -- input=>spr_msr_me                 , act=>spr_bit_w_int_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal msr_pr_q                                               : std_ulogic_vector(0 to threads-1);        -- input=>spr_msr_pr                 , act=>spr_bit_w_int_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal msr_spv_q                                              : std_ulogic_vector(0 to threads-1);        -- input=>spr_msr_spv                , act=>spr_bit_w_int_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal msr_ucle_q                                             : std_ulogic_vector(0 to threads-1);        -- input=>spr_msr_ucle               , act=>spr_bit_w_int_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal msrp_uclep_q                                           : std_ulogic_vector(0 to threads-1);        -- input=>spr_msrp_uclep             , act=>spr_bit_act_q          , scan=>Y, sleep=>N, needs_sreset=>1
signal pc_dbg_action_q                                        : std_ulogic_vector(0 to 3*threads-1);      -- input=>pc_xu_dbg_action           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal pc_dbg_stop_q,             pc_dbg_stop_d               : std_ulogic_vector(0 to threads-1);        -- input=>pc_dbg_stop_d              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal pc_dbg_stop_2_q,           pc_dbg_stop                 : std_ulogic_vector(0 to threads-1);        -- input=>pc_dbg_stop                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal pc_err_mcsr_rpt_q,         pc_err_mcsr_rpt_d           : std_ulogic_vector(0 to 10);               -- input=>pc_err_mcsr_rpt_d          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal pc_err_mcsr_summary_q,     pc_err_mcsr_summary_d       : std_ulogic_vector(0 to threads-1);        -- input=>pc_err_mcsr_summary_d      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal pc_init_reset_q                                        : std_ulogic;                               -- input=>pc_xu_init_reset           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal quiesced_q,                quiesced_d                  : std_ulogic;                               -- input=>quiesced_d                 , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ram_flush_q,               ram_flush_d                 : std_ulogic_vector(0 to threads-1);        -- input=>ram_flush_d                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ram_ip_q,                  ram_ip_d                    : std_ulogic_vector(0 to threads-1);        -- input=>ram_ip_d                   , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ram_mode_q,                ram_mode_d                  : std_ulogic_vector(0 to threads-1);        -- input=>ram_mode_d                 , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal slowspr_flush_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>mux_cpl_slowspr_flush      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal spr_cpl_async_int_q                                    : std_ulogic_vector(0 to 3*threads-1);      -- input=>spr_cpl_async_int          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ram_execute_q,             ram_execute_d               : std_ulogic_vector(0 to threads-1);        -- input=>ram_execute_d              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ssprwr_ip_q,               ssprwr_ip_d                 : std_ulogic_vector(0 to threads-1);        -- input=>ssprwr_ip_d                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal exx_cm_hold_q                                          : std_ulogic_vector(0 to threads-1);        -- input=>exx_cm_hold                , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex1_n_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>rf1_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex1_s_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>rf1_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex1_w_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>rf1_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex2_n_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex1_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex2_s_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex1_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex2_w_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex1_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex3_n_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex2_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex3_s_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex2_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex3_w_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex2_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex4_n_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex4_s_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex4_w_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex5_n_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex4_flush                  , act=>ex4_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex5_s_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex4_flush                  , act=>ex4_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_ex5_w_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex4_flush                  , act=>ex4_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_is2_n_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>any_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_rf0_n_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>is2_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_rf1_n_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>rf0_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_rf1_s_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>rf0_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_rf1_w_flush_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>rf0_flush                  , act=>exx_flush_inf_act    , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_np1_irpt_dbg_cint_q,  ex4_np1_irpt_dbg_cint        : std_ulogic_vector(0 to threads-1);        -- input=>ex4_np1_irpt_dbg_cint     , act=>tiup                  , scan=>Y, sleep=>N, needs_sreset=>1
signal ex6_np1_irpt_dbg_cint_q,  ex6_np1_irpt_dbg_cint_d      : std_ulogic_vector(0 to threads-1);        -- input=>ex6_np1_irpt_dbg_cint_d   , act=>tiup                  , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_np1_irpt_dbg_event_q,  ex4_np1_irpt_dbg_event      : std_ulogic_vector(0 to threads-1);        -- input=>ex4_np1_irpt_dbg_event     , act=>tiup                  , scan=>Y, sleep=>N, needs_sreset=>1
signal ex6_np1_irpt_dbg_event_q,  ex6_np1_irpt_dbg_event_d    : std_ulogic_vector(0 to threads-1);        -- input=>ex6_np1_irpt_dbg_event_d   , act=>tiup                  , scan=>Y, sleep=>N, needs_sreset=>1
signal clkg_ctl_q                                             : std_ulogic;                               --input=>spr_xucr0_clkg_ctl(2)       , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_rf_seq_end_q                                        : std_ulogic;                               -- input=>gpr_cpl_regfile_seq_end    , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_rfpe_ack_q,             xu_rfpe_ack_d               : std_ulogic_vector(0 to 1);                -- input=>xu_rfpe_ack_d              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal xu_rfpe_hold_present_q,    xu_rfpe_hold_present_d      : std_ulogic;                               -- input=>xu_rfpe_hold_present_d     , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal exx_act_q,                 exx_act_d                   : std_ulogic_vector(0 to 4);                -- input=>exx_act_d                  , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_mchk_int_en_q,         ex3_mchk_int_en             : std_ulogic_vector(0 to threads-1);        -- input=>ex3_mchk_int_en            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_mchk_int_en_q                                      : std_ulogic_vector(0 to threads-1);        -- input=>ex4_mchk_int_en_q          , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>0
signal trace_bus_enable_q                                     : std_ulogic;                               -- input=>pc_xu_trace_bus_enable     , act=>tiup                 , scan=>Y, sleep=>Y, needs_sreset=>0
signal ex1_instr_trace_type_q                                 : std_ulogic_vector(0 to 1);                -- input=>dec_cpl_rf1_instr_trace_type,act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_instr_trace_val_q                                  : std_ulogic;                               -- input=>dec_cpl_rf1_instr_trace_val, act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex1_xu_issued_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>dec_cpl_rf1_issued         , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>0
signal ex2_xu_issued_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>ex1_xu_issued_q            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_xu_issued_q                                        : std_ulogic_vector(0 to threads-1);        -- input=>ex2_xu_issued_q            , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_xu_issued_q,           ex3_xu_issued               : std_ulogic_vector(0 to threads-1);        -- input=>ex3_xu_issued              , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>0
signal ex3_axu_issued_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>fu_xu_ex2_ifar_issued      , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_axu_issued_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_axu_issued_q           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>0
signal ex2_instr_dbg_q                                        : std_ulogic_vector(0 to 31);               -- input=>ex1_instr                  , act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex2_instr_trace_type_q                                 : std_ulogic_vector(0 to 1);                -- input=>ex1_instr_trace_type_q     , act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_instr_trace_val_q                                  : std_ulogic;                               -- input=>dec_cpl_ex3_instr_trace_val, act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_axu_val_dbg_q                                      : std_ulogic_vector(0 to threads-1);        -- input=>ex4_axu_val                , act=>trace_bus_enable_q   , scan=>N, sleep=>Y, needs_sreset=>0
signal ex5_instr_cpl_dbg_q                                    : std_ulogic_vector(0 to threads-1);        -- input=>ex4_instr_cpl              , act=>trace_bus_enable_q   , scan=>N, sleep=>Y, needs_sreset=>0
signal ex5_instr_trace_val_q                                  : std_ulogic;                               -- input=>ex4_instr_trace_val_q      , act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_siar_q,                ex5_siar_d                  : std_ulogic_vector(62-eff_ifar to 61);     -- input=>ex5_siar_d                 , act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_siar_cpl_q,            ex5_siar_cpl_d              : std_ulogic;                               -- input=>ex5_siar_cpl_d             , act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_siar_gs_q,             ex5_siar_gs_d               : std_ulogic;                               -- input=>ex5_siar_gs_d              , act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_siar_issued_q,         ex5_siar_issued_d           : std_ulogic;                               -- input=>ex5_siar_issued_d          , act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_siar_pr_q,             ex5_siar_pr_d               : std_ulogic;                               -- input=>ex5_siar_pr_d              , act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_siar_tid_q,            ex5_siar_tid_d              : std_ulogic_vector(0 to 1);                -- input=>ex5_siar_tid_d             , act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex5_ucode_end_dbg_q                                    : std_ulogic_vector(0 to threads-1);        -- input=>ex4_ucode_end              , act=>trace_bus_enable_q   , scan=>Y, sleep=>Y, needs_sreset=>0
signal ex5_ucode_val_dbg_q                                    : std_ulogic_vector(0 to threads-1);        -- input=>ex4_ucode_val              , act=>trace_bus_enable_q   , scan=>Y, sleep=>Y, needs_sreset=>0
signal instr_trace_mode_q                                     : std_ulogic;                               -- input=>pc_xu_instr_trace_mode     , act=>trace_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal debug_data_out_q,          debug_data_out_d            : std_ulogic_vector(0 to 87);               -- input=>debug_data_out_d           , act=>trace_bus_enable_q   , scan=>Y, sleep=>Y, needs_sreset=>0
signal debug_mux_ctrls_q                                      : std_ulogic_vector(0 to 15);               -- input=>cpl_debug_mux_ctrls        , act=>trace_bus_enable_q   , scan=>Y, sleep=>Y, needs_sreset=>0
signal debug_mux_ctrls_int_q,     debug_mux_ctrls_int         : std_ulogic_vector(0 to 15);               -- input=>debug_mux_ctrls_int        , act=>trace_bus_enable_q   , scan=>Y, sleep=>Y, needs_sreset=>0
signal trigger_data_out_q,        trigger_data_out_d          : std_ulogic_vector(0 to 11);               -- input=>trigger_data_out_d         , act=>trace_bus_enable_q   , scan=>Y, sleep=>Y, needs_sreset=>0
signal event_bus_enable_q                                     : std_ulogic;                               -- input=>pc_xu_event_bus_enable     , act=>tiup                 , scan=>Y, sleep=>Y, needs_sreset=>0
signal ex2_perf_event_q,          ex2_perf_event_d            : std_ulogic_vector(0 to 2);                -- input=>ex2_perf_event_d           , act=>event_bus_enable_q   , scan=>N, sleep=>N, needs_sreset=>0
signal ex3_perf_event_q                                       : std_ulogic_vector(0 to 2);                -- input=>ex2_perf_event_q           , act=>event_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal ex4_perf_event_q,          ex4_perf_event_d            : std_ulogic_vector(0 to 3);                -- input=>ex4_perf_event_d           , act=>event_bus_enable_q   , scan=>N, sleep=>N, needs_sreset=>0
signal ex5_perf_event_q,          ex5_perf_event_d            : std_ulogic_vector(0 to 14*threads-1);     -- input=>ex5_perf_event_d           , act=>event_bus_enable_q   , scan=>Y, sleep=>N, needs_sreset=>0
signal spr_bit_act_q                                          : std_ulogic;                               -- input=>spr_bit_act                , act=>tiup                 , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
signal clk_override_q                                         : std_ulogic;                               -- input=>clk_override_q         , act=>tidn                 , scan=>Y, sleep=>N, needs_sreset=>0, ring=>ccfg,

signal spare_0_q,                 spare_0_d                   : std_ulogic_vector(0 to 15);               -- input=>spare_0_d,             act=>tidn,
signal spare_1_q,                 spare_1_d                   : std_ulogic_vector(0 to 15);               -- input=>spare_1_d,             act=>tidn,
signal spare_2_q,                 spare_2_d                   : std_ulogic_vector(0 to 15);               -- input=>spare_2_d,             act=>tidn,
signal spare_3_q,                 spare_3_d                   : std_ulogic_vector(0 to 15);               -- input=>spare_3_d,             act=>tidn,
signal spare_4_q,                 spare_4_d                   : std_ulogic_vector(0 to 7);                -- input=>spare_4_d,             act=>tidn,
signal spare_5_q,                 spare_5_d                   : std_ulogic_vector(0 to 3);                -- input=>spare_5_d,             act=>tidn,

-- Per thread controls
signal ex2_ifar_b_q                                           : std_ulogic_vector(0 to eff_ifar*threads-1);--input=>ex1_xu_ifar                , act=>ex1_ifar_act(t)      , scan=>N, sleep=>N, needs_sreset=>0, iterator=>(t)
signal ex3_ifar_q                                             : std_ulogic_vector(0 to eff_ifar*threads-1);--input=>ex2_ifar                   , act=>ex2_ifar_act(t)      , scan=>Y, sleep=>N, needs_sreset=>0, iterator=>(t)
signal ex4_ifar_q                                             : std_ulogic_vector(0 to eff_ifar*threads-1);--input=>ex3_ifar_q                 , act=>ex3_ifar_act(t)      , scan=>N, sleep=>N, needs_sreset=>0, iterator=>(t)
signal ex5_nia_b_q                                            : std_ulogic_vector(0 to eff_ifar*threads-1);
signal ex4_epid_instr_q                                       : std_ulogic_vector(0 to threads-1);        -- input=>ex3_epid_instr_q           , act=>ex3_esr_bit_act      , scan=>N, sleep=>N, needs_sreset=>1
signal ex4_is_any_store_q                                     : std_ulogic_vector(0 to threads-1);        -- input=>dec_cpl_ex3_is_any_store   , act=>ex3_esr_bit_act      , scan=>N, sleep=>N, needs_sreset=>1
signal ex5_flush_2ucode_q,        ex5_flush_2ucode_d          : std_ulogic_vector(0 to threads-1);        -- input=>ex5_flush_2ucode_d         , act=>ex4_flush_act        , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_ucode_restart_q,       ex5_ucode_restart_d         : std_ulogic_vector(0 to threads-1);        -- input=>ex5_ucode_restart_d        , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_mem_attr_le_q,         ex5_mem_attr_le_d           : std_ulogic_vector(0 to threads-1);        -- input=>ex5_mem_attr_le_d          , act=>ex4_flush_act        , scan=>Y, sleep=>N, needs_sreset=>1
signal ex4_dacr_cmpr_q,           ex4_dacr_cmpr_d             : DAC;                                      -- input=>ex4_dacr_cmpr_d            , act=>exx_act(3)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex4_dacw_cmpr_q,           ex4_dacw_cmpr_d             : DAC;                                      -- input=>ex4_dacw_cmpr_d            , act=>exx_act(3)           , scan=>N, sleep=>N, needs_sreset=>0
signal ex5_late_flush_q,          ex5_late_flush_d            : TID_ARR;                                  -- input=>ex5_late_flush_d           , act=>tiup                 , scan=>Y, sleep=>N, needs_sreset=>1
signal ex5_esr_q,                 ex5_esr_d                   : std_ulogic_vector(0 to 17*threads-1);     -- input=>ex5_esr_d                  , act=>ex4_esr_act(t)       , scan=>Y, sleep=>N, needs_sreset=>1, iterator=>(t)
signal ex5_dbsr_q,                ex5_dbsr_d                  : std_ulogic_vector(0 to 19*threads-1);     -- input=>ex5_dbsr_d                 , act=>ex4_dbsr_act(t)      , scan=>Y, sleep=>N, needs_sreset=>1, iterator=>(t)
signal ex5_mcsr_q,                ex5_mcsr_d                  : std_ulogic_vector(0 to 15*threads-1);     -- input=>ex5_mcsr_d                 , act=>ex4_mcsr_act(t)      , scan=>Y, sleep=>N, needs_sreset=>1, iterator=>(t)
signal dbg_flushcond_q,           dbg_flushcond_d             : ARY64;                                    -- input=>dbg_flushcond_d            , act=>trace_bus_enable_q   , scan=>N, sleep=>Y, needs_sreset=>0

-- Scanchains
constant is2_flush_offset                             : integer := 0;
constant rf0_flush_offset                             : integer := is2_flush_offset               + is2_flush_q'length;
constant rf1_flush_offset                             : integer := rf0_flush_offset               + rf0_flush_q'length;
constant rf1_tid_offset                               : integer := rf1_flush_offset               + rf1_flush_q'length;
constant ex1_axu_act_offset                           : integer := rf1_tid_offset                 + rf1_tid_q'length;
constant ex1_byte_rev_offset                          : integer := ex1_axu_act_offset             + ex1_axu_act_q'length;
constant ex1_flush_offset                             : integer := ex1_byte_rev_offset            + 1;
constant ex1_is_any_ldstmw_offset                     : integer := ex1_flush_offset               + ex1_flush_q'length;
constant ex1_is_attn_offset                           : integer := ex1_is_any_ldstmw_offset       + 1;
constant ex1_is_dci_offset                            : integer := ex1_is_attn_offset             + 1;
constant ex1_is_dlock_offset                          : integer := ex1_is_dci_offset              + 1;
constant ex1_is_ehpriv_offset                         : integer := ex1_is_dlock_offset            + 1;
constant ex1_is_erativax_offset                       : integer := ex1_is_ehpriv_offset           + 1;
constant ex1_is_ici_offset                            : integer := ex1_is_erativax_offset         + 1;
constant ex1_is_icswx_offset                          : integer := ex1_is_ici_offset              + 1;
constant ex1_is_ilock_offset                          : integer := ex1_is_icswx_offset            + 1;
constant ex1_is_isync_offset                          : integer := ex1_is_ilock_offset            + 1;
constant ex1_is_mfspr_offset                          : integer := ex1_is_isync_offset            + 1;
constant ex1_is_mtmsr_offset                          : integer := ex1_is_mfspr_offset            + 1;
constant ex1_is_mtspr_offset                          : integer := ex1_is_mtmsr_offset            + 1;
constant ex1_is_rfci_offset                           : integer := ex1_is_mtspr_offset            + 1;
constant ex1_is_rfgi_offset                           : integer := ex1_is_rfci_offset             + 1;
constant ex1_is_rfi_offset                            : integer := ex1_is_rfgi_offset             + 1;
constant ex1_is_rfmci_offset                          : integer := ex1_is_rfi_offset              + 1;
constant ex1_is_sc_offset                             : integer := ex1_is_rfmci_offset            + 1;
constant ex1_is_tlbivax_offset                        : integer := ex1_is_sc_offset               + 1;
constant ex1_is_wrtee_offset                          : integer := ex1_is_tlbivax_offset          + 1;
constant ex1_is_wrteei_offset                         : integer := ex1_is_wrtee_offset            + 1;
constant ex1_is_mtxucr0_offset                        : integer := ex1_is_wrteei_offset           + 1;
constant ex1_is_tlbwe_offset                          : integer := ex1_is_mtxucr0_offset          + 1;
constant ex1_sc_lev_offset                            : integer := ex1_is_tlbwe_offset            + 1;
constant ex1_ucode_val_offset                         : integer := ex1_sc_lev_offset              + 1;
constant ex1_xu_val_offset                            : integer := ex1_ucode_val_offset           + ex1_ucode_val_q'length;
constant ex2_flush_offset                             : integer := ex1_xu_val_offset              + ex1_xu_val_q'length;
constant ex2_ucode_val_offset                         : integer := ex2_flush_offset               + ex2_flush_q'length;
constant ex2_xu_val_offset                            : integer := ex2_ucode_val_offset           + ex2_ucode_val_q'length;
constant ex3_async_int_block_offset                   : integer := ex2_xu_val_offset              + ex2_xu_val_q'length;
constant ex3_axu_instr_match_offset                   : integer := ex3_async_int_block_offset     + ex3_async_int_block_q'length;
constant ex3_axu_instr_type_offset                    : integer := ex3_axu_instr_match_offset     + ex3_axu_instr_match_q'length;
constant ex3_axu_is_ucode_offset                      : integer := ex3_axu_instr_type_offset      + ex3_axu_instr_type_q'length;
constant ex3_axu_val_offset                           : integer := ex3_axu_is_ucode_offset        + ex3_axu_is_ucode_q'length;
constant ex3_br_flush_ifar_offset                     : integer := ex3_axu_val_offset             + ex3_axu_val_q'length;
constant ex3_br_taken_offset                          : integer := ex3_br_flush_ifar_offset       + ex3_br_flush_ifar_q'length;
constant ex3_br_update_offset                         : integer := ex3_br_taken_offset            + 1;
constant ex3_byte_rev_offset                          : integer := ex3_br_update_offset           + 1;
constant ex3_ctr_dec_update_offset                    : integer := ex3_byte_rev_offset            + 1;
constant ex3_div_coll_offset                          : integer := ex3_ctr_dec_update_offset      + 1;
constant ex3_epid_instr_offset                        : integer := ex3_div_coll_offset            + ex3_div_coll_q'length;
constant ex3_flush_offset                             : integer := ex3_epid_instr_offset          + 1;
constant ex3_ierat_flush_req_offset                   : integer := ex3_flush_offset               + ex3_flush_q'length;
constant ex3_illegal_op_offset                        : integer := ex3_ierat_flush_req_offset     + ex3_ierat_flush_req_q'length;
constant ex3_is_any_load_dac_offset                   : integer := ex3_illegal_op_offset          + 1;
constant ex3_is_any_store_dac_offset                  : integer := ex3_is_any_load_dac_offset     + 1;
constant ex3_is_attn_offset                           : integer := ex3_is_any_store_dac_offset    + 1;
constant ex3_is_dci_offset                            : integer := ex3_is_attn_offset             + 1;
constant ex3_is_dlock_offset                          : integer := ex3_is_dci_offset              + 1;
constant ex3_is_ehpriv_offset                         : integer := ex3_is_dlock_offset            + 1;
constant ex3_is_ici_offset                            : integer := ex3_is_ehpriv_offset           + 1;
constant ex3_is_icswx_offset                          : integer := ex3_is_ici_offset              + 1;
constant ex3_is_ilock_offset                          : integer := ex3_is_icswx_offset            + 1;
constant ex3_is_isync_offset                          : integer := ex3_is_ilock_offset            + 1;
constant ex3_is_mtmsr_offset                          : integer := ex3_is_isync_offset            + 1;
constant ex3_is_rfci_offset                           : integer := ex3_is_mtmsr_offset            + 1;
constant ex3_is_rfgi_offset                           : integer := ex3_is_rfci_offset             + 1;
constant ex3_is_rfi_offset                            : integer := ex3_is_rfgi_offset             + 1;
constant ex3_is_rfmci_offset                          : integer := ex3_is_rfi_offset              + 1;
constant ex3_is_sc_offset                             : integer := ex3_is_rfmci_offset            + 1;
constant ex3_is_tlbwe_offset                          : integer := ex3_is_sc_offset               + 1;
constant ex3_is_slowspr_wr_offset                     : integer := ex3_is_tlbwe_offset            + 1;
constant ex3_iu_error_offset                          : integer := ex3_is_slowspr_wr_offset       + 1;
constant ex3_lr_update_offset                         : integer := ex3_iu_error_offset            + ex3_iu_error_q'length;
constant ex3_lrat_miss_offset                         : integer := ex3_lr_update_offset           + 1;
constant ex3_mmu_esr_data_offset                      : integer := ex3_lrat_miss_offset           + ex3_lrat_miss_q'length;
constant ex3_mmu_esr_epid_offset                      : integer := ex3_mmu_esr_data_offset        + ex3_mmu_esr_data_q'length;
constant ex3_mmu_esr_pt_offset                        : integer := ex3_mmu_esr_epid_offset        + ex3_mmu_esr_epid_q'length;
constant ex3_mmu_esr_st_offset                        : integer := ex3_mmu_esr_pt_offset          + ex3_mmu_esr_pt_q'length;
constant ex3_mmu_hv_priv_offset                       : integer := ex3_mmu_esr_st_offset          + ex3_mmu_esr_st_q'length;
constant ex3_mtiar_offset                             : integer := ex3_mmu_hv_priv_offset         + ex3_mmu_hv_priv_q'length;
constant ex3_n_align_int_offset                       : integer := ex3_mtiar_offset               + 1;
constant ex3_n_dcpe_flush_offset                      : integer := ex3_n_align_int_offset         + 1;
constant ex3_n_l2_ecc_err_flush_offset                : integer := ex3_n_dcpe_flush_offset        + ex3_n_dcpe_flush_q'length;
constant ex3_np1_run_ctl_flush_offset                 : integer := ex3_n_l2_ecc_err_flush_offset  + ex3_n_l2_ecc_err_flush_q'length;
constant ex3_sc_lev_offset                            : integer := ex3_np1_run_ctl_flush_offset   + ex3_np1_run_ctl_flush_q'length;
constant ex3_taken_bclr_offset                        : integer := ex3_sc_lev_offset              + 1;
constant ex3_tlb_inelig_offset                        : integer := ex3_taken_bclr_offset          + 1;
constant ex3_tlb_local_snoop_reject_offset            : integer := ex3_tlb_inelig_offset          + ex3_tlb_inelig_q'length;
constant ex3_tlb_lru_par_err_offset                   : integer := ex3_tlb_local_snoop_reject_offset + ex3_tlb_local_snoop_reject_q'length;
constant ex3_tlb_illeg_offset                         : integer := ex3_tlb_lru_par_err_offset     + ex3_tlb_lru_par_err_q'length;
constant ex3_tlb_miss_offset                          : integer := ex3_tlb_illeg_offset           + ex3_tlb_illeg_q'length;
constant ex3_tlb_multihit_err_offset                  : integer := ex3_tlb_miss_offset            + ex3_tlb_miss_q'length;
constant ex3_tlb_par_err_offset                       : integer := ex3_tlb_multihit_err_offset    + ex3_tlb_multihit_err_q'length;
constant ex3_tlb_pt_fault_offset                      : integer := ex3_tlb_par_err_offset         + ex3_tlb_par_err_q'length;
constant ex3_ucode_val_offset                         : integer := ex3_tlb_pt_fault_offset        + ex3_tlb_pt_fault_q'length;
constant ex3_xu_instr_match_offset                    : integer := ex3_ucode_val_offset           + ex3_ucode_val_q'length;
constant ex3_xu_is_ucode_offset                       : integer := ex3_xu_instr_match_offset      + 1;
constant ex3_xu_val_offset                            : integer := ex3_xu_is_ucode_offset         + 1;
constant ex3_axu_async_block_offset                   : integer := ex3_xu_val_offset              + ex3_xu_val_q'length;
constant ex3_is_mtxucr0_offset                        : integer := ex3_axu_async_block_offset     + ex3_axu_async_block_q'length;
constant ex3_np1_instr_flush_offset                   : integer := ex3_is_mtxucr0_offset          + 1;
constant ex4_apena_prog_int_offset                    : integer := ex3_np1_instr_flush_offset     + 1;
constant ex4_axu_is_ucode_offset                      : integer := ex4_apena_prog_int_offset      + ex4_apena_prog_int_q'length;
constant ex4_axu_trap_offset                          : integer := ex4_axu_is_ucode_offset        + ex4_axu_is_ucode_q'length;
constant ex4_axu_val_offset                           : integer := ex4_axu_trap_offset            + ex4_axu_trap_q'length;
constant ex4_base_int_block_offset                    : integer := ex4_axu_val_offset             + ex4_axu_val_q'length;
constant ex4_br_flush_ifar_offset                     : integer := ex4_base_int_block_offset      + ex4_base_int_block_q'length;
constant ex4_br_taken_offset                          : integer := ex4_br_flush_ifar_offset       + ex4_br_flush_ifar_q'length;
constant ex4_br_update_offset                         : integer := ex4_br_taken_offset            + 1;
constant ex4_byte_rev_offset                          : integer := ex4_br_update_offset           + 1;
constant ex4_ctr_dec_update_offset                    : integer := ex4_byte_rev_offset            + 1;
constant ex4_debug_flush_en_offset                    : integer := ex4_ctr_dec_update_offset      + 1;
constant ex4_debug_int_en_offset                      : integer := ex4_debug_flush_en_offset      + ex4_debug_flush_en_q'length;
constant ex4_flush_offset                             : integer := ex4_debug_int_en_offset        + ex4_debug_int_en_q'length;
constant ex4_fpena_prog_int_offset                    : integer := ex4_flush_offset               + ex4_flush_q'length;
constant ex4_iac1_cmpr_offset                         : integer := ex4_fpena_prog_int_offset      + ex4_fpena_prog_int_q'length;
constant ex4_iac2_cmpr_offset                         : integer := ex4_iac1_cmpr_offset           + ex4_iac1_cmpr_q'length;
constant ex4_iac3_cmpr_offset                         : integer := ex4_iac2_cmpr_offset           + ex4_iac2_cmpr_q'length;
constant ex4_iac4_cmpr_offset                         : integer := ex4_iac3_cmpr_offset           + ex4_iac3_cmpr_q'length;
constant ex4_instr_cpl_offset                         : integer := ex4_iac4_cmpr_offset           + ex4_iac4_cmpr_q'length;
constant ex4_is_any_load_dac_offset                   : integer := ex4_instr_cpl_offset           + ex4_instr_cpl_q'length;
constant ex4_is_any_store_dac_offset                  : integer := ex4_is_any_load_dac_offset     + 1;
constant ex4_is_attn_offset                           : integer := ex4_is_any_store_dac_offset    + 1;
constant ex4_is_dci_offset                            : integer := ex4_is_attn_offset             + 1;
constant ex4_is_ehpriv_offset                         : integer := ex4_is_dci_offset              + 1;
constant ex4_is_ici_offset                            : integer := ex4_is_ehpriv_offset           + 1;
constant ex4_is_isync_offset                          : integer := ex4_is_ici_offset              + 1;
constant ex4_is_mtmsr_offset                          : integer := ex4_is_isync_offset            + 1;
constant ex4_is_tlbwe_offset                          : integer := ex4_is_mtmsr_offset            + 1;
constant ex4_is_slowspr_wr_offset                     : integer := ex4_is_tlbwe_offset            + 1;
constant ex4_lr_update_offset                         : integer := ex4_is_slowspr_wr_offset       + 1;
constant ex4_mcsr_offset                              : integer := ex4_lr_update_offset           + 1;
constant ex4_mem_attr_offset                          : integer := ex4_mcsr_offset                + ex4_mcsr_q'length;
constant ex4_mmu_esr_data_offset                      : integer := ex4_mem_attr_offset            + ex4_mem_attr_q'length;
constant ex4_mmu_esr_epid_offset                      : integer := ex4_mmu_esr_data_offset        + ex4_mmu_esr_data_q'length;
constant ex4_mmu_esr_pt_offset                        : integer := ex4_mmu_esr_epid_offset        + ex4_mmu_esr_epid_q'length;
constant ex4_mmu_esr_st_offset                        : integer := ex4_mmu_esr_pt_offset          + ex4_mmu_esr_pt_q'length;
constant ex4_mmu_esr_val_offset                       : integer := ex4_mmu_esr_st_offset          + ex4_mmu_esr_st_q'length;
constant ex4_mmu_hold_val_offset                      : integer := ex4_mmu_esr_val_offset         + ex4_mmu_esr_val_q'length;
constant ex4_mtdp_nr_offset                           : integer := ex4_mmu_hold_val_offset        + ex4_mmu_hold_val_q'length;
constant ex4_mtiar_offset                             : integer := ex4_mtdp_nr_offset             + 1;
constant ex4_n_2ucode_flush_offset                    : integer := ex4_mtiar_offset               + 1;
constant ex4_n_align_int_offset                       : integer := ex4_n_2ucode_flush_offset      + ex4_n_2ucode_flush_q'length;
constant ex4_n_any_hpriv_int_offset                   : integer := ex4_n_align_int_offset         + ex4_n_align_int_q'length;
constant ex4_n_any_unavail_int_offset                 : integer := ex4_n_any_hpriv_int_offset     + ex4_n_any_hpriv_int_q'length;
constant ex4_n_ap_unavail_int_offset                  : integer := ex4_n_any_unavail_int_offset   + ex4_n_any_unavail_int_q'length;
constant ex4_n_barr_flush_offset                      : integer := ex4_n_ap_unavail_int_offset    + ex4_n_ap_unavail_int_q'length;
constant ex4_n_bclr_ta_miscmpr_flush_offset           : integer := ex4_n_barr_flush_offset        + ex4_n_barr_flush_q'length;
constant ex4_n_brt_dbg_cint_offset                    : integer := ex4_n_bclr_ta_miscmpr_flush_offset + ex4_n_bclr_ta_miscmpr_flush_q'length;
constant ex4_n_dac_dbg_cint_offset                    : integer := ex4_n_brt_dbg_cint_offset      + ex4_n_brt_dbg_cint_q'length;
constant ex4_n_ddmh_mchk_en_offset                    : integer := ex4_n_dac_dbg_cint_offset      + ex4_n_dac_dbg_cint_q'length;
constant ex4_n_dep_flush_offset                       : integer := ex4_n_ddmh_mchk_en_offset      + ex4_n_ddmh_mchk_en_q'length;
constant ex4_n_deratre_par_mchk_mcint_offset          : integer := ex4_n_dep_flush_offset         + ex4_n_dep_flush_q'length;
constant ex4_n_dlk0_dstor_int_offset                  : integer := ex4_n_deratre_par_mchk_mcint_offset + ex4_n_deratre_par_mchk_mcint_q'length;
constant ex4_n_dlk1_dstor_int_offset                  : integer := ex4_n_dlk0_dstor_int_offset    + ex4_n_dlk0_dstor_int_q'length;
constant ex4_n_dlrat_int_offset                       : integer := ex4_n_dlk1_dstor_int_offset    + ex4_n_dlk1_dstor_int_q'length;
constant ex4_n_dmchk_mcint_offset                     : integer := ex4_n_dlrat_int_offset         + ex4_n_dlrat_int_q'length;
constant ex4_n_dmiss_flush_offset                     : integer := ex4_n_dmchk_mcint_offset       + ex4_n_dmchk_mcint_q'length;
constant ex4_n_dstor_int_offset                       : integer := ex4_n_dmiss_flush_offset       + ex4_n_dmiss_flush_q'length;
constant ex4_n_dtlb_int_offset                        : integer := ex4_n_dstor_int_offset         + ex4_n_dstor_int_q'length;
constant ex4_n_ena_prog_int_offset                    : integer := ex4_n_dtlb_int_offset          + ex4_n_dtlb_int_q'length;
constant ex4_n_flush_offset                           : integer := ex4_n_ena_prog_int_offset      + ex4_n_ena_prog_int_q'length;
constant ex4_n_pe_flush_offset                        : integer := ex4_n_flush_offset             + ex4_n_flush_q'length;
constant ex4_n_tlb_mchk_flush_offset                  : integer := ex4_n_pe_flush_offset          + ex4_n_pe_flush_q'length;
constant ex4_n_fp_unavail_int_offset                  : integer := ex4_n_tlb_mchk_flush_offset    + ex4_n_tlb_mchk_flush_q'length;
constant ex4_n_fu_rfpe_flush_offset                   : integer := ex4_n_fp_unavail_int_offset    + ex4_n_fp_unavail_int_q'length;
constant ex4_n_iac_dbg_cint_offset                    : integer := ex4_n_fu_rfpe_flush_offset     + ex4_n_fu_rfpe_flush_q'length;
constant ex4_n_ieratre_par_mchk_mcint_offset          : integer := ex4_n_iac_dbg_cint_offset      + ex4_n_iac_dbg_cint_q'length;
constant ex4_n_ilrat_int_offset                       : integer := ex4_n_ieratre_par_mchk_mcint_offset + ex4_n_ieratre_par_mchk_mcint_q'length;
constant ex4_n_imchk_mcint_offset                     : integer := ex4_n_ilrat_int_offset         + ex4_n_ilrat_int_q'length;
constant ex4_n_imiss_flush_offset                     : integer := ex4_n_imchk_mcint_offset       + ex4_n_imchk_mcint_q'length;
constant ex4_n_instr_dbg_cint_offset                  : integer := ex4_n_imiss_flush_offset       + ex4_n_imiss_flush_q'length;
constant ex4_n_istor_int_offset                       : integer := ex4_n_instr_dbg_cint_offset    + ex4_n_instr_dbg_cint_q'length;
constant ex4_n_itlb_int_offset                        : integer := ex4_n_istor_int_offset         + ex4_n_istor_int_q'length;
constant ex4_n_ivc_dbg_cint_offset                    : integer := ex4_n_itlb_int_offset          + ex4_n_itlb_int_q'length;
constant ex4_n_ivc_dbg_match_offset                   : integer := ex4_n_ivc_dbg_cint_offset      + ex4_n_ivc_dbg_cint_q'length;
constant ex4_n_ldq_hit_flush_offset                   : integer := ex4_n_ivc_dbg_match_offset     + ex4_n_ivc_dbg_match_q'length;
constant ex4_n_lsu_ddmh_flush_en_offset               : integer := ex4_n_ldq_hit_flush_offset     + ex4_n_ldq_hit_flush_q'length;
constant ex4_n_lsu_flush_offset                       : integer := ex4_n_lsu_ddmh_flush_en_offset + ex4_n_lsu_ddmh_flush_en_q'length;
constant ex4_n_memattr_miscmpr_flush_offset           : integer := ex4_n_lsu_flush_offset         + ex4_n_lsu_flush_q'length;
constant ex4_n_mmu_hpriv_int_offset                   : integer := ex4_n_memattr_miscmpr_flush_offset + ex4_n_memattr_miscmpr_flush_q'length;
constant ex4_n_pil_prog_int_offset                    : integer := ex4_n_mmu_hpriv_int_offset     + ex4_n_mmu_hpriv_int_q'length;
constant ex4_n_ppr_prog_int_offset                    : integer := ex4_n_pil_prog_int_offset      + ex4_n_pil_prog_int_q'length;
constant ex4_n_ptemiss_dlrat_int_offset               : integer := ex4_n_ppr_prog_int_offset      + ex4_n_ppr_prog_int_q'length;
constant ex4_n_puo_prog_int_offset                    : integer := ex4_n_ptemiss_dlrat_int_offset + ex4_n_ptemiss_dlrat_int_q'length;
constant ex4_n_ret_dbg_cint_offset                    : integer := ex4_n_puo_prog_int_offset      + ex4_n_puo_prog_int_q'length;
constant ex4_n_thrctl_stop_flush_offset               : integer := ex4_n_ret_dbg_cint_offset      + ex4_n_ret_dbg_cint_q'length;
constant ex4_n_tlbwemiss_dlrat_int_offset             : integer := ex4_n_thrctl_stop_flush_offset + ex4_n_thrctl_stop_flush_q'length;
constant ex4_n_tlbwe_pil_prog_int_offset              : integer := ex4_n_tlbwemiss_dlrat_int_offset + ex4_n_tlbwemiss_dlrat_int_q'length;
constant ex4_n_trap_dbg_cint_offset                   : integer := ex4_n_tlbwe_pil_prog_int_offset + ex4_n_tlbwe_pil_prog_int_q'length;
constant ex4_n_uct_dstor_int_offset                   : integer := ex4_n_trap_dbg_cint_offset     + ex4_n_trap_dbg_cint_q'length;
constant ex4_n_vec_unavail_int_offset                 : integer := ex4_n_uct_dstor_int_offset     + ex4_n_uct_dstor_int_q'length;
constant ex4_n_vf_dstor_int_offset                    : integer := ex4_n_vec_unavail_int_offset   + ex4_n_vec_unavail_int_q'length;
constant ex4_n_xu_rfpe_flush_offset                   : integer := ex4_n_vf_dstor_int_offset      + ex4_n_vf_dstor_int_q'length;
constant ex4_np1_cdbell_cint_offset                   : integer := ex4_n_xu_rfpe_flush_offset     + ex4_n_xu_rfpe_flush_q'length;
constant ex4_np1_crit_cint_offset                     : integer := ex4_np1_cdbell_cint_offset     + ex4_np1_cdbell_cint_q'length;
constant ex4_np1_dbell_int_offset                     : integer := ex4_np1_crit_cint_offset       + ex4_np1_crit_cint_q'length;
constant ex4_np1_dec_int_offset                       : integer := ex4_np1_dbell_int_offset       + ex4_np1_dbell_int_q'length;
constant ex4_np1_ext_int_offset                       : integer := ex4_np1_dec_int_offset         + ex4_np1_dec_int_q'length;
constant ex4_np1_ext_mchk_mcint_offset                : integer := ex4_np1_ext_int_offset         + ex4_np1_ext_int_q'length;
constant ex4_np1_fit_int_offset                       : integer := ex4_np1_ext_mchk_mcint_offset  + ex4_np1_ext_mchk_mcint_q'length;
constant ex4_np1_flush_offset                         : integer := ex4_np1_fit_int_offset         + ex4_np1_fit_int_q'length;
constant ex4_np1_gcdbell_cint_offset                  : integer := ex4_np1_flush_offset           + ex4_np1_flush_q'length;
constant ex4_np1_gdbell_int_offset                    : integer := ex4_np1_gcdbell_cint_offset    + ex4_np1_gcdbell_cint_q'length;
constant ex4_np1_gmcdbell_cint_offset                 : integer := ex4_np1_gdbell_int_offset      + ex4_np1_gdbell_int_q'length;
constant ex4_np1_ide_dbg_cint_offset                  : integer := ex4_np1_gmcdbell_cint_offset   + ex4_np1_gmcdbell_cint_q'length;
constant ex4_np1_instr_int_offset                     : integer := ex4_np1_ide_dbg_cint_offset    + ex4_np1_ide_dbg_cint_q'length;
constant ex4_np1_perf_int_offset                      : integer := ex4_np1_instr_int_offset       + ex4_np1_instr_int_q'length;
constant ex4_np1_ptr_prog_int_offset                  : integer := ex4_np1_perf_int_offset        + ex4_np1_perf_int_q'length;
constant ex4_np1_rfi_offset                           : integer := ex4_np1_ptr_prog_int_offset    + ex4_np1_ptr_prog_int_q'length;
constant ex4_np1_run_ctl_flush_offset                 : integer := ex4_np1_rfi_offset             + ex4_np1_rfi_q'length;
constant ex4_np1_sc_int_offset                        : integer := ex4_np1_run_ctl_flush_offset   + ex4_np1_run_ctl_flush_q'length;
constant ex4_np1_ude_dbg_cint_offset                  : integer := ex4_np1_sc_int_offset          + ex4_np1_sc_int_q'length;
constant ex4_np1_ude_dbg_event_offset                 : integer := ex4_np1_ude_dbg_cint_offset    + ex4_np1_ude_dbg_cint_q'length;
constant ex4_np1_udec_int_offset                      : integer := ex4_np1_ude_dbg_event_offset   + ex4_np1_ude_dbg_event_q'length;
constant ex4_np1_wdog_cint_offset                     : integer := ex4_np1_udec_int_offset        + ex4_np1_udec_int_q'length;
constant ex4_np1_fu_flush_offset                      : integer := ex4_np1_wdog_cint_offset       + ex4_np1_wdog_cint_q'length;
constant ex4_n_ieratsx_par_mchk_mcint_offset          : integer := ex4_np1_fu_flush_offset        + ex4_np1_fu_flush_q'length;
constant ex4_n_tlbmh_mchk_mcint_offset                : integer := ex4_n_ieratsx_par_mchk_mcint_offset + ex4_n_ieratsx_par_mchk_mcint_q'length;
constant ex4_n_sprg_ue_flush_offset                   : integer := ex4_n_tlbmh_mchk_mcint_offset  + ex4_n_tlbmh_mchk_mcint_q'length;
constant ex4_n_rwaccess_dstor_int_offset              : integer := ex4_n_sprg_ue_flush_offset     + ex4_n_sprg_ue_flush_q'length;
constant ex4_n_exaccess_istor_int_offset              : integer := ex4_n_rwaccess_dstor_int_offset + ex4_n_rwaccess_dstor_int_q'length;
constant ex4_sc_lev_offset                            : integer := ex4_n_exaccess_istor_int_offset + ex4_n_exaccess_istor_int_q'length;
constant ex4_siar_sel_offset                          : integer := ex4_sc_lev_offset              + 1;
constant ex4_step_offset                              : integer := ex4_siar_sel_offset            + ex4_siar_sel_q'length;
constant ex4_taken_bclr_offset                        : integer := ex4_step_offset                + ex4_step_q'length;
constant ex4_tlb_inelig_offset                        : integer := ex4_taken_bclr_offset          + 1;
constant ex4_ucode_val_offset                         : integer := ex4_tlb_inelig_offset          + ex4_tlb_inelig_q'length;
constant ex4_xu_is_ucode_offset                       : integer := ex4_ucode_val_offset           + ex4_ucode_val_q'length;
constant ex4_xu_val_offset                            : integer := ex4_xu_is_ucode_offset         + 1;
constant ex4_cia_act_offset                           : integer := ex4_xu_val_offset              + ex4_xu_val_q'length;
constant ex4_n_async_dacr_dbg_cint_offset             : integer := ex4_cia_act_offset             + ex4_cia_act_q'length;
constant ex4_dac1r_cmpr_async_offset                  : integer := ex4_n_async_dacr_dbg_cint_offset + ex4_n_async_dacr_dbg_cint_q'length;
constant ex4_dac2r_cmpr_async_offset                  : integer := ex4_dac1r_cmpr_async_offset    + ex4_dac1r_cmpr_async_q'length;
constant ex4_thread_stop_offset                       : integer := ex4_dac2r_cmpr_async_offset    + ex4_dac2r_cmpr_async_q'length;
constant ex5_icmp_event_on_int_ok_offset              : integer := ex4_thread_stop_offset         + ex4_thread_stop_q'length;
constant ex5_any_val_offset                           : integer := ex5_icmp_event_on_int_ok_offset + ex5_icmp_event_on_int_ok_q'length;
constant ex5_attn_flush_offset                        : integer := ex5_any_val_offset             + ex5_any_val_q'length;
constant ex5_axu_trap_pie_offset                      : integer := ex5_attn_flush_offset          + ex5_attn_flush_q'length;
constant ex5_br_taken_offset                          : integer := ex5_axu_trap_pie_offset        + ex5_axu_trap_pie_q'length;
constant ex5_cdbell_taken_offset                      : integer := ex5_br_taken_offset            + 1;
constant ex5_check_bclr_offset                        : integer := ex5_cdbell_taken_offset        + ex5_cdbell_taken_q'length;
constant ex5_cia_p1_offset                            : integer := ex5_check_bclr_offset          + ex5_check_bclr_q'length;
constant ex5_dbell_taken_offset                       : integer := ex5_cia_p1_offset              + ex5_cia_p1_q'length;
constant ex5_dbsr_update_offset                       : integer := ex5_dbell_taken_offset         + ex5_dbell_taken_q'length;
constant ex5_dear_update_saved_offset                 : integer := ex5_dbsr_update_offset         + ex5_dbsr_update_q'length;
constant ex5_deratre_par_err_offset                   : integer := ex5_dear_update_saved_offset   + ex5_dear_update_saved_q'length;
constant ex5_div_set_barr_offset                      : integer := ex5_deratre_par_err_offset     + ex5_deratre_par_err_q'length;
constant ex5_dsigs_offset                             : integer := ex5_div_set_barr_offset        + ex5_div_set_barr_q'length;
constant ex5_dtlbgs_offset                            : integer := ex5_dsigs_offset               + ex5_dsigs_q'length;
constant ex5_err_nia_miscmpr_offset                   : integer := ex5_dtlbgs_offset              + ex5_dtlbgs_q'length;
constant ex5_ext_dbg_err_offset                       : integer := ex5_err_nia_miscmpr_offset     + ex5_err_nia_miscmpr_q'length;
constant ex5_ext_dbg_ext_offset                       : integer := ex5_ext_dbg_err_offset         + ex5_ext_dbg_err_q'length;
constant ex5_extgs_offset                             : integer := ex5_ext_dbg_ext_offset         + ex5_ext_dbg_ext_q'length;
constant ex5_flush_offset                             : integer := ex5_extgs_offset               + ex5_extgs_q'length;
constant ex5_force_gsrr_offset                        : integer := ex5_flush_offset               + ex5_flush_q'length;
constant ex5_gcdbell_taken_offset                     : integer := ex5_force_gsrr_offset          + ex5_force_gsrr_q'length;
constant ex5_gdbell_taken_offset                      : integer := ex5_gcdbell_taken_offset       + ex5_gcdbell_taken_q'length;
constant ex5_gmcdbell_taken_offset                    : integer := ex5_gdbell_taken_offset        + ex5_gdbell_taken_q'length;
constant ex5_ieratre_par_err_offset                   : integer := ex5_gmcdbell_taken_offset      + ex5_gmcdbell_taken_q'length;
constant ex5_in_ucode_offset                          : integer := ex5_ieratre_par_err_offset     + ex5_ieratre_par_err_q'length;
constant ex5_instr_cpl_offset                         : integer := ex5_in_ucode_offset            + ex5_in_ucode_q'length;
constant ex5_is_any_rfi_offset                        : integer := ex5_instr_cpl_offset           + ex5_instr_cpl_q'length;
constant ex5_is_attn_offset                           : integer := ex5_is_any_rfi_offset          + ex5_is_any_rfi_q'length;
constant ex5_is_crit_int_offset                       : integer := ex5_is_attn_offset             + ex5_is_attn_q'length;
constant ex5_is_mchk_int_offset                       : integer := ex5_is_crit_int_offset         + ex5_is_crit_int_q'length;
constant ex5_is_mtmsr_offset                          : integer := ex5_is_mchk_int_offset         + ex5_is_mchk_int_q'length;
constant ex5_is_isync_offset                          : integer := ex5_is_mtmsr_offset            + 1;
constant ex5_is_tlbwe_offset                          : integer := ex5_is_isync_offset            + 1;
constant ex5_isigs_offset                             : integer := ex5_is_tlbwe_offset            + 1;
constant ex5_itlbgs_offset                            : integer := ex5_isigs_offset               + ex5_isigs_q'length;
constant ex5_lsu_set_barr_offset                      : integer := ex5_itlbgs_offset              + ex5_itlbgs_q'length;
constant ex5_mem_attr_val_offset                      : integer := ex5_lsu_set_barr_offset        + ex5_lsu_set_barr_q'length;
constant ex5_mmu_hold_val_offset                      : integer := ex5_mem_attr_val_offset        + ex5_mem_attr_val_q'length;
constant ex5_n_dmiss_flush_offset                     : integer := ex5_mmu_hold_val_offset        + ex5_mmu_hold_val_q'length;
constant ex5_n_ext_dbg_stopc_flush_offset             : integer := ex5_n_dmiss_flush_offset       + ex5_n_dmiss_flush_q'length;
constant ex5_n_ext_dbg_stopt_flush_offset             : integer := ex5_n_ext_dbg_stopc_flush_offset + 1;
constant ex5_n_imiss_flush_offset                     : integer := ex5_n_ext_dbg_stopt_flush_offset + ex5_n_ext_dbg_stopt_flush_q'length;
constant ex5_n_ptemiss_dlrat_int_offset               : integer := ex5_n_imiss_flush_offset       + ex5_n_imiss_flush_q'length;
constant ex5_np1_icmp_dbg_cint_offset                 : integer := ex5_n_ptemiss_dlrat_int_offset + ex5_n_ptemiss_dlrat_int_q'length;
constant ex5_np1_icmp_dbg_event_offset                : integer := ex5_np1_icmp_dbg_cint_offset   + ex5_np1_icmp_dbg_cint_q'length;
constant ex5_np1_run_ctl_flush_offset                 : integer := ex5_np1_icmp_dbg_event_offset  + ex5_np1_icmp_dbg_event_q'length;
constant ex5_dbsr_ide_offset                          : integer := ex5_np1_run_ctl_flush_offset   + ex5_np1_run_ctl_flush_q'length;
constant ex5_perf_dtlb_offset                         : integer := ex5_dbsr_ide_offset            + ex5_dbsr_ide_q'length;
constant ex5_perf_itlb_offset                         : integer := ex5_perf_dtlb_offset           + ex5_perf_dtlb_q'length;
constant ex5_ram_done_offset                          : integer := ex5_perf_itlb_offset           + ex5_perf_itlb_q'length;
constant ex5_ram_issue_offset                         : integer := ex5_ram_done_offset            + 1;
constant ex5_rt_offset                                : integer := ex5_ram_issue_offset           + ex5_ram_issue_q'length;
constant ex5_sel_rt_offset                            : integer := ex5_rt_offset                  + ex5_rt_q'length;
constant ex5_srr0_dec_offset                          : integer := ex5_sel_rt_offset              + ex5_sel_rt_q'length;
constant ex5_tlb_inelig_offset                        : integer := ex5_srr0_dec_offset            + ex5_srr0_dec_q'length;
constant ex5_uc_cia_val_offset                        : integer := ex5_tlb_inelig_offset          + ex5_tlb_inelig_q'length;
constant ex5_xu_ifar_offset                           : integer := ex5_uc_cia_val_offset          + ex5_uc_cia_val_q'length;
constant ex5_xu_val_offset                            : integer := ex5_xu_ifar_offset             + ex5_xu_ifar_q'length;
constant ex5_n_flush_sprg_ue_flush_offset             : integer := ex5_xu_val_offset              + ex5_xu_val_q'length;
constant ex5_mcsr_act_offset                          : integer := ex5_n_flush_sprg_ue_flush_offset + ex5_n_flush_sprg_ue_flush_q'length;
constant ex6_mcsr_act_offset                          : integer := ex5_mcsr_act_offset            + ex5_mcsr_act_q'length;
constant ex6_ram_done_offset                          : integer := ex6_mcsr_act_offset            + 1;
constant ex6_ram_interrupt_offset                     : integer := ex6_ram_done_offset            + 1;
constant ex6_ram_issue_offset                         : integer := ex6_ram_interrupt_offset       + 1;
constant ex7_ram_issue_offset                         : integer := ex6_ram_issue_offset           + ex6_ram_issue_q'length;
constant ex8_ram_issue_offset                         : integer := ex7_ram_issue_offset           + ex7_ram_issue_q'length;
constant ex6_step_done_offset                         : integer := ex8_ram_issue_offset           + ex8_ram_issue_q'length;
constant ex6_xu_val_offset                            : integer := ex6_step_done_offset           + ex6_step_done_q'length;
constant ex7_is_tlbwe_offset                          : integer := ex6_xu_val_offset              + ex6_xu_val_q'length;
constant ex8_is_tlbwe_offset                          : integer := ex7_is_tlbwe_offset            + ex7_is_tlbwe_q'length;
constant ccr2_ap_offset                               : integer := ex8_is_tlbwe_offset            + ex8_is_tlbwe_q'length;
constant cpl_quiesced_offset                          : integer := ccr2_ap_offset                 + ccr2_ap_q'length;
constant dbcr0_idm_offset                             : integer := cpl_quiesced_offset            + cpl_quiesced_q'length;
constant dci_val_offset                               : integer := dbcr0_idm_offset               + dbcr0_idm_q'length;
constant debug_event_en_offset                        : integer := dci_val_offset                 + 1;
constant derat_hold_present_offset                    : integer := debug_event_en_offset          + debug_event_en_q'length;
constant ext_dbg_act_err_offset                       : integer := derat_hold_present_offset      + derat_hold_present_q'length;
constant ext_dbg_act_ext_offset                       : integer := ext_dbg_act_err_offset         + ext_dbg_act_err_q'length;
constant ext_dbg_stop_core_offset                     : integer := ext_dbg_act_ext_offset         + ext_dbg_act_ext_q'length;
constant ext_dbg_stop_n_offset                        : integer := ext_dbg_stop_core_offset       + ext_dbg_stop_core_q'length;
constant external_mchk_offset                         : integer := ext_dbg_stop_n_offset          + ext_dbg_stop_n_q'length;
constant exx_multi_flush_offset                       : integer := external_mchk_offset           + external_mchk_q'length;
constant force_ude_offset                             : integer := exx_multi_flush_offset         + exx_multi_flush_q'length;
constant fu_rf_seq_end_offset                         : integer := force_ude_offset               + force_ude_q'length;
constant fu_rfpe_ack_offset                           : integer := fu_rf_seq_end_offset           + 1;
constant fu_rfpe_hold_present_offset                  : integer := fu_rfpe_ack_offset             + fu_rfpe_ack_q'length;
constant ici_hold_present_offset                      : integer := fu_rfpe_hold_present_offset    + 1;
constant ici_val_offset                               : integer := ici_hold_present_offset        + ici_hold_present_q'length;
constant ierat_hold_present_offset                    : integer := ici_val_offset                 + 1;
constant mmu_eratmiss_done_offset                     : integer := ierat_hold_present_offset      + ierat_hold_present_q'length;
constant mmu_hold_present_offset                      : integer := mmu_eratmiss_done_offset       + mmu_eratmiss_done_q'length;
constant mmu_hold_request_offset                      : integer := mmu_hold_present_offset        + mmu_hold_present_q'length;
constant msr_cm_offset                                : integer := mmu_hold_request_offset        + mmu_hold_request_q'length;
constant msr_de_offset                                : integer := msr_cm_offset                  + msr_cm_q'length;
constant msr_fp_offset                                : integer := msr_de_offset                  + msr_de_q'length;
constant msr_gs_offset                                : integer := msr_fp_offset                  + msr_fp_q'length;
constant msr_me_offset                                : integer := msr_gs_offset                  + msr_gs_q'length;
constant msr_pr_offset                                : integer := msr_me_offset                  + msr_me_q'length;
constant msr_spv_offset                               : integer := msr_pr_offset                  + msr_pr_q'length;
constant msr_ucle_offset                              : integer := msr_spv_offset                 + msr_spv_q'length;
constant msrp_uclep_offset                            : integer := msr_ucle_offset                + msr_ucle_q'length;
constant pc_dbg_action_offset                         : integer := msrp_uclep_offset              + msrp_uclep_q'length;
constant pc_dbg_stop_offset                           : integer := pc_dbg_action_offset           + pc_dbg_action_q'length;
constant pc_dbg_stop_2_offset                         : integer := pc_dbg_stop_offset             + pc_dbg_stop_q'length;
constant pc_err_mcsr_rpt_offset                       : integer := pc_dbg_stop_2_offset           + pc_dbg_stop_2_q'length;
constant pc_err_mcsr_summary_offset                   : integer := pc_err_mcsr_rpt_offset         + pc_err_mcsr_rpt_q'length;
constant pc_init_reset_offset                         : integer := pc_err_mcsr_summary_offset     + pc_err_mcsr_summary_q'length;
constant quiesced_offset                              : integer := pc_init_reset_offset           + 1;
constant ram_flush_offset                             : integer := quiesced_offset                + 1;
constant ram_ip_offset                                : integer := ram_flush_offset               + ram_flush_q'length;
constant ram_mode_offset                              : integer := ram_ip_offset                  + ram_ip_q'length;
constant slowspr_flush_offset                         : integer := ram_mode_offset                + ram_mode_q'length;
constant spr_cpl_async_int_offset                     : integer := slowspr_flush_offset           + slowspr_flush_q'length;
constant ram_execute_offset                           : integer := spr_cpl_async_int_offset       + spr_cpl_async_int_q'length;
constant ssprwr_ip_offset                             : integer := ram_execute_offset             + ram_execute_q'length;
constant exx_cm_hold_offset                           : integer := ssprwr_ip_offset               + ssprwr_ip_q'length;
constant xu_ex1_n_flush_offset                        : integer := exx_cm_hold_offset             + exx_cm_hold_q'length;
constant xu_ex1_s_flush_offset                        : integer := xu_ex1_n_flush_offset          + xu_ex1_n_flush_q'length;
constant xu_ex1_w_flush_offset                        : integer := xu_ex1_s_flush_offset          + xu_ex1_s_flush_q'length;
constant xu_ex2_n_flush_offset                        : integer := xu_ex1_w_flush_offset          + xu_ex1_w_flush_q'length;
constant xu_ex2_s_flush_offset                        : integer := xu_ex2_n_flush_offset          + xu_ex2_n_flush_q'length;
constant xu_ex2_w_flush_offset                        : integer := xu_ex2_s_flush_offset          + xu_ex2_s_flush_q'length;
constant xu_ex3_n_flush_offset                        : integer := xu_ex2_w_flush_offset          + xu_ex2_w_flush_q'length;
constant xu_ex3_s_flush_offset                        : integer := xu_ex3_n_flush_offset          + xu_ex3_n_flush_q'length;
constant xu_ex3_w_flush_offset                        : integer := xu_ex3_s_flush_offset          + xu_ex3_s_flush_q'length;
constant xu_ex4_n_flush_offset                        : integer := xu_ex3_w_flush_offset          + xu_ex3_w_flush_q'length;
constant xu_ex4_s_flush_offset                        : integer := xu_ex4_n_flush_offset          + xu_ex4_n_flush_q'length;
constant xu_ex4_w_flush_offset                        : integer := xu_ex4_s_flush_offset          + xu_ex4_s_flush_q'length;
constant xu_ex5_n_flush_offset                        : integer := xu_ex4_w_flush_offset          + xu_ex4_w_flush_q'length;
constant xu_ex5_s_flush_offset                        : integer := xu_ex5_n_flush_offset          + xu_ex5_n_flush_q'length;
constant xu_ex5_w_flush_offset                        : integer := xu_ex5_s_flush_offset          + xu_ex5_s_flush_q'length;
constant xu_is2_n_flush_offset                        : integer := xu_ex5_w_flush_offset          + xu_ex5_w_flush_q'length;
constant xu_rf0_n_flush_offset                        : integer := xu_is2_n_flush_offset          + xu_is2_n_flush_q'length;
constant xu_rf1_n_flush_offset                        : integer := xu_rf0_n_flush_offset          + xu_rf0_n_flush_q'length;
constant xu_rf1_s_flush_offset                        : integer := xu_rf1_n_flush_offset          + xu_rf1_n_flush_q'length;
constant xu_rf1_w_flush_offset                        : integer := xu_rf1_s_flush_offset          + xu_rf1_s_flush_q'length;
constant ex5_np1_irpt_dbg_cint_offset                 : integer := xu_rf1_w_flush_offset          + xu_rf1_w_flush_q'length;
constant ex6_np1_irpt_dbg_cint_offset                 : integer := ex5_np1_irpt_dbg_cint_offset   + ex5_np1_irpt_dbg_cint_q'length;
constant ex5_np1_irpt_dbg_event_offset                : integer := ex6_np1_irpt_dbg_cint_offset   + ex6_np1_irpt_dbg_cint_q'length;
constant ex6_np1_irpt_dbg_event_offset                : integer := ex5_np1_irpt_dbg_event_offset  + ex5_np1_irpt_dbg_event_q'length;
constant clkg_ctl_offset                              : integer := ex6_np1_irpt_dbg_event_offset  + ex6_np1_irpt_dbg_event_q'length;
constant xu_rf_seq_end_offset                         : integer := clkg_ctl_offset                + 1;
constant xu_rfpe_ack_offset                           : integer := xu_rf_seq_end_offset           + 1;
constant xu_rfpe_hold_present_offset                  : integer := xu_rfpe_ack_offset             + xu_rfpe_ack_q'length;
constant exx_act_offset                               : integer := xu_rfpe_hold_present_offset    + 1;
constant ex4_mchk_int_en_offset                       : integer := exx_act_offset                 + exx_act_q'length;
constant ex5_mchk_int_en_offset                       : integer := ex4_mchk_int_en_offset         + ex4_mchk_int_en_q'length;
constant trace_bus_enable_offset                      : integer := ex5_mchk_int_en_offset         + ex5_mchk_int_en_q'length;
constant ex1_instr_trace_type_offset                  : integer := trace_bus_enable_offset        + 1;
constant ex1_instr_trace_val_offset                   : integer := ex1_instr_trace_type_offset    + ex1_instr_trace_type_q'length;
constant ex1_xu_issued_offset                         : integer := ex1_instr_trace_val_offset     + 1;
constant ex2_xu_issued_offset                         : integer := ex1_xu_issued_offset           + ex1_xu_issued_q'length;
constant ex3_xu_issued_offset                         : integer := ex2_xu_issued_offset           + ex2_xu_issued_q'length;
constant ex4_xu_issued_offset                         : integer := ex3_xu_issued_offset           + ex3_xu_issued_q'length;
constant ex3_axu_issued_offset                        : integer := ex4_xu_issued_offset           + ex4_xu_issued_q'length;
constant ex4_axu_issued_offset                        : integer := ex3_axu_issued_offset          + ex3_axu_issued_q'length;
constant ex2_instr_dbg_offset                         : integer := ex4_axu_issued_offset          + ex4_axu_issued_q'length;
constant ex2_instr_trace_type_offset                  : integer := ex2_instr_dbg_offset           + ex2_instr_dbg_q'length;
constant ex4_instr_trace_val_offset                   : integer := ex2_instr_trace_type_offset    + ex2_instr_trace_type_q'length;
constant ex5_instr_trace_val_offset                   : integer := ex4_instr_trace_val_offset     + 1;
constant ex5_siar_offset                              : integer := ex5_instr_trace_val_offset     + 1;
constant ex5_siar_cpl_offset                          : integer := ex5_siar_offset                + ex5_siar_q'length;
constant ex5_siar_gs_offset                           : integer := ex5_siar_cpl_offset            + 1;
constant ex5_siar_issued_offset                       : integer := ex5_siar_gs_offset             + 1;
constant ex5_siar_pr_offset                           : integer := ex5_siar_issued_offset         + 1;
constant ex5_siar_tid_offset                          : integer := ex5_siar_pr_offset             + 1;
constant ex5_ucode_end_dbg_offset                     : integer := ex5_siar_tid_offset            + ex5_siar_tid_q'length;
constant ex5_ucode_val_dbg_offset                     : integer := ex5_ucode_end_dbg_offset       + ex5_ucode_end_dbg_q'length;
constant instr_trace_mode_offset                      : integer := ex5_ucode_val_dbg_offset       + ex5_ucode_val_dbg_q'length;
constant debug_data_out_offset                        : integer := instr_trace_mode_offset        + 1;
constant debug_mux_ctrls_offset                       : integer := debug_data_out_offset          + debug_data_out_q'length;
constant debug_mux_ctrls_int_offset                   : integer := debug_mux_ctrls_offset         + debug_mux_ctrls_q'length;
constant trigger_data_out_offset                      : integer := debug_mux_ctrls_int_offset     + debug_mux_ctrls_int_q'length;
constant event_bus_enable_offset                      : integer := trigger_data_out_offset        + trigger_data_out_q'length;
constant ex3_perf_event_offset                        : integer := event_bus_enable_offset        + 1;
constant ex5_perf_event_offset                        : integer := ex3_perf_event_offset          + ex3_perf_event_q'length;
constant spr_bit_act_offset                           : integer := ex5_perf_event_offset          + ex5_perf_event_q'length;
constant spare_0_offset                               : integer := spr_bit_act_offset             + 1;
constant spare_1_offset                               : integer := spare_0_offset                 + spare_0_q'length;
constant spare_2_offset                               : integer := spare_1_offset                 + spare_1_q'length;
constant spare_3_offset                               : integer := spare_2_offset                 + spare_2_q'length;
constant spare_4_offset                               : integer := spare_3_offset                 + spare_3_q'length;
constant spare_5_offset                               : integer := spare_4_offset                 + spare_4_q'length;

constant exx_instr_async_block_offset                 : integer := spare_5_offset                 + spare_5_q'length;
constant ex5_late_flush_offset                        : integer := exx_instr_async_block_offset   + exx_instr_async_block_q(0)'length*threads;
constant ex5_esr_offset                               : integer := ex5_late_flush_offset          + ifar_repwr*threads;
constant ex5_dbsr_offset                              : integer := ex5_esr_offset                + ex5_esr_q'length;
constant ex5_mcsr_offset                              : integer := ex5_dbsr_offset                + ex5_dbsr_q'length;
constant ex4_uc_cia_offset                            : integer := ex5_mcsr_offset                + ex5_mcsr_q'length;
constant ex4_axu_instr_type_offset                    : integer := ex4_uc_cia_offset              + IFAR_UC'length*threads;
constant ex5_mem_attr_offset                          : integer := ex4_axu_instr_type_offset      + 3*threads;
constant ex5_ivo_sel_offset                           : integer := ex5_mem_attr_offset            + ex4_mem_attr_q'length*threads;
constant ex5_nia_b_offset                             : integer := ex5_ivo_sel_offset             + ivos*threads;
constant ex2_ifar_b_offset                            : integer := ex5_nia_b_offset               + eff_ifar*threads;
constant ex3_ifar_offset                              : integer := ex2_ifar_b_offset              + eff_ifar*threads;
constant ex4_ifar_offset                              : integer := ex3_ifar_offset                + eff_ifar*threads;
constant ex4_epid_instr_offset                        : integer := ex4_ifar_offset                + eff_ifar*threads;
constant ex4_is_any_store_offset                      : integer := ex4_epid_instr_offset          + ex4_epid_instr_q'length;
constant ex5_flush_2ucode_offset                      : integer := ex4_is_any_store_offset        + ex4_is_any_store_q'length;
constant ex5_ucode_restart_offset                     : integer := ex5_flush_2ucode_offset        + ex5_flush_2ucode_q'length;
constant ex5_mem_attr_le_offset                       : integer := ex5_ucode_restart_offset       + ex5_ucode_restart_q'length;
constant ex5_cm_hold_cond_offset                      : integer := ex5_mem_attr_le_offset         + ex5_mem_attr_le_q'length;
constant ex3_async_int_block_cond_offset              : integer := ex5_cm_hold_cond_offset        + 1;
constant ex3_base_int_block_offset                    : integer := ex3_async_int_block_cond_offset+ 1;
constant ex3_mchk_int_block_offset                    : integer := ex3_base_int_block_offset      + 1; 
constant exx_thread_stop_mcflush_offset               : integer := ex3_mchk_int_block_offset      + 1; 
constant exx_lateflush_mcflush_offset                 : integer := exx_thread_stop_mcflush_offset + 1;
constant exx_csi_mcflush_offset                       : integer := exx_lateflush_mcflush_offset   + 1;
constant exx_hold0_mcflush_offset                     : integer := exx_csi_mcflush_offset         + 1;
constant exx_hold1_mcflush_offset                     : integer := exx_hold0_mcflush_offset       + 1;
constant exx_barr_mcflush_offset                      : integer := exx_hold1_mcflush_offset       + 1;
constant rfpe_quiesce_offset                          : integer := exx_barr_mcflush_offset        + 1;
constant scan_right                                   : integer := rfpe_quiesce_offset            + 1;
signal siv                                            : std_ulogic_vector(0 to scan_right-1);
signal sov                                            : std_ulogic_vector(0 to scan_right-1);
signal siv_3                                          : std_ulogic_vector(0 to 1);
signal sov_3                                          : std_ulogic_vector(0 to 1);
constant dd1_clk_override_offset_ccfg                 : integer := 0;
constant scan_right_ccfg                              : integer := dd1_clk_override_offset_ccfg   + 1;
signal siv_ccfg                                       : std_ulogic_vector(0 to scan_right_ccfg-1);
signal sov_ccfg                                       : std_ulogic_vector(0 to scan_right_ccfg-1);
constant ex4_cia_b_offset_bcfg                        : integer := 0;
constant mcsr_rpt_offset_bcfg                         : integer := ex4_cia_b_offset_bcfg          + IFAR'length*threads;
constant mcsr_rpt2_offset_bcfg                        : integer := mcsr_rpt_offset_bcfg           + pc_err_mcsr_rpt_q'length*threads;
constant scan_right_bcfg                              : integer := mcsr_rpt2_offset_bcfg          + pc_err_mcsr_rpt_q'length*threads;
signal siv_bcfg                                       : std_ulogic_vector(0 to scan_right_bcfg-1);
signal sov_bcfg                                       : std_ulogic_vector(0 to scan_right_bcfg-1);
constant scan_right_dcfg                              : integer := 1;
signal siv_dcfg                                       : std_ulogic_vector(0 to scan_right_dcfg-1);
signal sov_dcfg                                       : std_ulogic_vector(0 to scan_right_dcfg-1);
-- Signals
signal tiup, tidn                                     : std_ulogic;
-- Valids
signal rf1_xu_val                                     : std_ulogic_vector(0 to threads-1);
signal ex1_xu_val                                     : std_ulogic_vector(0 to threads-1);
signal ex2_xu_val                                     : std_ulogic_vector(0 to threads-1);
signal ex3_xu_val                                     : std_ulogic_vector(0 to threads-1);
signal ex4_xu_val                                     : std_ulogic_vector(0 to threads-1);
signal ex2_axu_val                                    : std_ulogic_vector(0 to threads-1);
signal ex3_axu_val                                    : std_ulogic_vector(0 to threads-1);
signal ex4_axu_val                                    : std_ulogic_vector(0 to threads-1);
signal ex3_any_val                                    : std_ulogic_vector(0 to threads-1);
signal ex4_any_val                                    : std_ulogic_vector(0 to threads-1);
signal ex3_anyuc_val                                  : std_ulogic_vector(0 to threads-1);
signal ex4_anyuc_val                                  : std_ulogic_vector(0 to threads-1);
signal ex3_anyuc_val_q                                : std_ulogic_vector(0 to threads-1);
signal ex4_anyuc_val_q                                : std_ulogic_vector(0 to threads-1);
signal rf1_ucode_val                                  : std_ulogic_vector(0 to threads-1);
signal ex1_ucode_val                                  : std_ulogic_vector(0 to threads-1);
signal ex2_ucode_val                                  : std_ulogic_vector(0 to threads-1);
signal ex3_ucode_val                                  : std_ulogic_vector(0 to threads-1);
signal ex4_ucode_val                                  : std_ulogic_vector(0 to threads-1);
signal ex3_xuuc_val_q                                 : std_ulogic_vector(0 to threads-1);
signal ex4_xuuc_val_q                                 : std_ulogic_vector(0 to threads-1);
signal ex3_xuuc_val                                   : std_ulogic_vector(0 to threads-1);
signal ex4_xuuc_val                                   : std_ulogic_vector(0 to threads-1);
signal ex3_dep_val                                    : std_ulogic_vector(0 to threads-1);
-- Flushes
signal iu_flush                                       : std_ulogic_vector(0 to threads-1);
signal any_flush                                      : std_ulogic_vector(0 to threads-1);
signal is2_flush                                      : std_ulogic_vector(0 to threads-1);
signal rf0_flush                                      : std_ulogic_vector(0 to threads-1);
signal rf1_flush                                      : std_ulogic_vector(0 to threads-1);
signal ex1_flush                                      : std_ulogic_vector(0 to threads-1);
signal ex2_flush                                      : std_ulogic_vector(0 to threads-1);
signal ex3_flush                                      : std_ulogic_vector(0 to threads-1);
signal ex4_flush                                      : std_ulogic_vector(0 to threads-1);
-- Other Stuff
signal spare_0_lclk                                   : clk_logic;
signal spare_1_lclk                                   : clk_logic;
signal spare_2_lclk                                   : clk_logic;
signal spare_3_lclk                                   : clk_logic;
signal spare_4_lclk                                   : clk_logic;
signal spare_5_lclk                                   : clk_logic;
signal spare_0_d1clk, spare_0_d2clk                   : std_ulogic;
signal spare_1_d1clk, spare_1_d2clk                   : std_ulogic;
signal spare_2_d1clk, spare_2_d2clk                   : std_ulogic;
signal spare_3_d1clk, spare_3_d2clk                   : std_ulogic;
signal spare_4_d1clk, spare_4_d2clk                   : std_ulogic;
signal spare_5_d1clk, spare_5_d2clk                   : std_ulogic;
signal func_scan_rpwr2_in                             : std_ulogic_vector(3 to 3);
signal func_scan_rpwr_in, func_scan_rpwr_out          : std_ulogic_vector(0 to 3);
signal func_scan_out_gate                             : std_ulogic_vector(50 to 53);
signal ccfg_scan_rpwr_in, ccfg_scan_rpwr_out          : std_ulogic_vector(0 to 0);
signal ccfg_scan_out_gate                             : std_ulogic_vector(0 to 0);
signal bcfg_scan_rpwr_in, bcfg_scan_rpwr_out          : std_ulogic_vector(0 to 0);
signal bcfg_scan_out_gate                             : std_ulogic_vector(0 to 0);
signal dcfg_scan_rpwr_in, dcfg_scan_rpwr_out          : std_ulogic_vector(0 to 0);
signal dcfg_scan_out_gate                             : std_ulogic_vector(0 to 0);
signal mcsr_bcfg_slp_sl_d1clk                         : std_ulogic;
signal mcsr_bcfg_slp_sl_d2clk                         : std_ulogic;
signal mcsr_bcfg_slp_sl_lclk                          : clk_logic;
signal bcfg_so_d2clk                                  : std_ulogic;
signal bcfg_so_lclk                                   : clk_logic;
signal func_slp_sl_thold_1                            : std_ulogic;
signal func_slp_nsl_thold_1                           : std_ulogic;
signal func_sl_thold_1                                : std_ulogic;
signal func_nsl_thold_1                               : std_ulogic;
signal cfg_sl_thold_1                                 : std_ulogic;
signal cfg_slp_sl_thold_1                             : std_ulogic;
signal fce_1                                          : std_ulogic;
signal sg_1                                           : std_ulogic;
signal func_slp_sl_thold_0                            : std_ulogic;
signal func_slp_nsl_thold_0                           : std_ulogic;
signal func_sl_thold_0                                : std_ulogic;
signal func_nsl_thold_0                               : std_ulogic;
signal cfg_sl_thold_0                                 : std_ulogic;
signal cfg_slp_sl_thold_0                             : std_ulogic;
signal fce_0                                          : std_ulogic;
signal sg_0                                           : std_ulogic;
signal cfg_sl_force                                   : std_ulogic;
signal cfg_sl_thold_0_b                               : std_ulogic;
signal bcfg_sl_force                                  : std_ulogic;
signal bcfg_sl_thold_0_b                              : std_ulogic;
signal dcfg_sl_force                                  : std_ulogic;
signal dcfg_sl_thold_0_b                              : std_ulogic;
signal cfg_slp_sl_force                               : std_ulogic;
signal cfg_slp_sl_thold_0_b                           : std_ulogic;
signal bcfg_slp_sl_force                              : std_ulogic;
signal bcfg_slp_sl_thold_0_b                          : std_ulogic;
signal func_sl_force                                  : std_ulogic;
signal func_sl_thold_0_b                              : std_ulogic;
signal func_nsl_force                                 : std_ulogic;
signal func_nsl_thold_0_b                             : std_ulogic;
signal func_slp_sl_force                              : std_ulogic;
signal func_slp_sl_thold_0_b                          : std_ulogic;
signal func_slp_nsl_force                             : std_ulogic;
signal func_slp_nsl_thold_0_b                         : std_ulogic;
signal so_force                                       : std_ulogic;
signal ccfg_so_thold_0_b                              : std_ulogic;
signal bcfg_so_thold_0_b                              : std_ulogic;
signal dcfg_so_thold_0_b                              : std_ulogic;
signal func_so_thold_0_b                              : std_ulogic;
signal rf1_is_ldbrx,  rf1_is_lwbrx,  rf1_is_lhbrx     : std_ulogic;
signal rf1_is_stdbrx, rf1_is_stwbrx, rf1_is_sthbrx    : std_ulogic;
signal rf1_is_icblc, rf1_is_icbtls                    : std_ulogic;
signal rf1_is_dcblc, rf1_is_dcbtls, rf1_is_dcbtstls   : std_ulogic;
signal rf1_is_wait,  rf1_is_eratre                    : std_ulogic;
signal ex4_np1_mtiar_flush, ex3_np1_mtiar_flush       : std_ulogic_vector(0 to threads-1);
signal ex1_instr                                      : std_ulogic_vector(0 to 31);
signal ex1_branch,ex1_br_mispred,ex1_br_taken         : std_ulogic;
signal ex1_br_update, ex1_is_bclr                     : std_ulogic;
signal ex1_lr_update, ex1_ctr_dec_update              : std_ulogic;
signal ex1_taken_bclr                                 : std_ulogic;
signal ex1_xu_ifar                                    : IFAR;
signal ex1_ifar_sel,       ex1_ifar_sel_b             : std_ulogic_vector(ex2_ifar_b_q'range);
signal ex2_br_flush                                   : std_ulogic_vector(0 to threads-1);
signal ex2_br_flush_ifar                              : IFAR;
signal ex2_ifar                                       : std_ulogic_vector(ex2_ifar_b_q'range);
signal ex4_cia_cmpr                                   : std_ulogic_vector(0 to threads-1);
signal ex3_lr_cmprh,     ex3_lr_cmprl                 : std_ulogic_vector(0 to threads-1);
signal ex3_cia_cmprh,    ex3_cia_cmprl                : std_ulogic_vector(0 to threads-1);
signal ex4_cia_cmprh,    ex4_cia_cmprl                : std_ulogic_vector(0 to threads-1);
signal ex3_bclr_cmpr_b                                : std_ulogic_vector(0 to threads-1);
signal ex4_taken_bclr,        ex5_check_bclr          : std_ulogic_vector(0 to threads-1);
signal ex4_ucode_end                                  : std_ulogic_vector(0 to threads-1);
signal ex3_async_int_block                            : std_ulogic_vector(0 to threads-1);
signal ex3_async_int_block_noaxu                      : std_ulogic_vector(0 to threads-1);
signal ex3_base_int_block                             : std_ulogic_vector(0 to threads-1);
signal ex3_mchk_int_block                             : std_ulogic_vector(0 to threads-1);
signal ex3_esr_bit_act                                : std_ulogic_vector(0 to threads-1);
signal ex4_n_flush                                    : std_ulogic_vector(0 to threads-1);
signal ex4_np1_flush                                  : std_ulogic_vector(0 to threads-1);
signal ex4_cia_p1_out                                 : std_ulogic_vector(0 to eff_ifar*threads-1);
signal ex5_ram_interrupt                              : std_ulogic_vector(0 to threads-1);
signal ex4_check_cia                                  : std_ulogic_vector(0 to threads-1);
signal ex3_ct                                         : std_ulogic_vector(0 to threads-1);
signal ex4_is_base_int,ex4_is_crit_int,ex4_is_mchk_int: std_ulogic_vector(0 to threads-1);
signal ex5_is_base_hint,ex5_is_base_gint              : std_ulogic_vector(0 to threads-1);
signal ex3_np1_step_flush                             : std_ulogic_vector(0 to threads-1);
signal ex4_clear_bclr_chk                             : std_ulogic_vector(0 to threads-1);
signal ex5_is_any_int,ex5_is_any_gint,ex5_is_any_hint : std_ulogic_vector(0 to threads-1);
signal ex3_lr_cmpr, ex3_cia_cmpr                      : std_ulogic_vector(0 to threads-1);
signal ex3_mem_attr_chk                               : std_ulogic_vector(0 to threads-1);
signal ex3_mem_attr_cmpr                              : std_ulogic_vector(0 to threads-1);
signal ex4_mem_attr_act                               : std_ulogic_vector(0 to threads-1);
signal ex4_is_any_store                               : std_ulogic_vector(0 to threads-1);
signal ex4_epid_instr                                 : std_ulogic_vector(0 to threads-1);
signal ex4_flush_act                                  : std_ulogic_vector(0 to threads-1);
signal ex4_ucode_restart                              : std_ulogic_vector(0 to threads-1);
signal ex4_uc_cia_val                                 : std_ulogic_vector(0 to threads-1);
signal ex5_flush_update                               : std_ulogic_vector(0 to threads-1);
signal ex4_cm                                         : std_ulogic_vector(0 to threads-1);
signal exx_multi_flush                                : std_ulogic_vector(0 to threads-1);
signal hold_state_0, hold_state_1                     : std_ulogic_vector(0 to threads-1);
signal spr_givpr                                      : std_ulogic_vector(62-eff_ifar to 51);
signal spr_ivpr                                       : std_ulogic_vector(62-eff_ifar to 51);
signal spr_ctr                                        : std_ulogic_vector(0 to (regsize)*threads-1);
signal spr_lr                                         : std_ulogic_vector(0 to (regsize)*threads-1);
signal spr_iar                                        : std_ulogic_vector(0 to (eff_ifar)*threads-1);
signal spr_xucr3_cm_hold_dly                          : std_ulogic_vector(0 to 3);
signal spr_xucr3_stop_dly                             : std_ulogic_vector(0 to 3);
signal spr_xucr3_hold0_dly                            : std_ulogic_vector(0 to 3);
signal spr_xucr3_hold1_dly                            : std_ulogic_vector(0 to 3);
signal spr_xucr3_csi_dly                              : std_ulogic_vector(0 to 3);
signal spr_xucr3_int_dly                              : std_ulogic_vector(0 to 3);
signal spr_xucr3_asyncblk_dly                         : std_ulogic_vector(0 to 3);
signal spr_xucr3_flush_dly                            : std_ulogic_vector(0 to 3);
signal spr_xucr4_barr_dly                             : std_ulogic_vector(0 to 3);
signal spr_xucr4_lsu_bar_dis                          : std_ulogic;
signal spr_xucr4_div_bar_dis                          : std_ulogic;
signal spr_xucr4_mddmh                                : std_ulogic;
signal spr_xucr4_mmu_mchk_int                         : std_ulogic;
signal ex3_np1_mtxucr0_flush                          : std_ulogic_vector(0 to threads-1);
signal ex4_n_lsu_flush                                : std_ulogic_vector(0 to threads-1);         
signal ex4_n_lsu_ddmh_flush                           : std_ulogic_vector(0 to threads-1);
signal ex3_div_coll                                   : std_ulogic_vector(0 to threads-1);
signal ex3_non_uc_val                                 : std_ulogic_vector(0 to threads-1);
signal ex3_n_ieratmiss_itlb_int                       : std_ulogic_vector(0 to threads-1);
signal ex3_n_tlbmiss_itlb_int                         : std_ulogic_vector(0 to threads-1);
signal ex3_n_iemh_mchk_mcint_xuuc                     : std_ulogic_vector(0 to threads-1);
signal ex3_n_iepe_mchk_mcint_xuuc                     : std_ulogic_vector(0 to threads-1);
signal ex3_n_il2ecc_mchk_mcint_xuuc                   : std_ulogic_vector(0 to threads-1);
signal ex3_n_dpovr_mchk_mcint                         : std_ulogic_vector(0 to threads-1);
signal ex3_n_demh_mchk_mcint_xu                       : std_ulogic_vector(0 to threads-1);
signal ex3_n_depe_mchk_mcint_xu                       : std_ulogic_vector(0 to threads-1);
signal ex3_n_dl2ecc_mchk_mcint                        : std_ulogic_vector(0 to threads-1);
signal ex3_n_ddpe_mchk_mcint_xu                       : std_ulogic_vector(0 to threads-1);
signal ex3_n_dcpe_mchk_mcint                          : std_ulogic_vector(0 to threads-1);
signal ex3_n_tlbmh_mchk_mcint                         : std_ulogic_vector(0 to threads-1);
signal ex3_n_tlbpe_mchk_mcint                         : std_ulogic_vector(0 to threads-1);
signal ex3_n_tlblru_mchk_mcint                        : std_ulogic_vector(0 to threads-1);
signal ex3_n_tlbsrej_mchk_mcint                       : std_ulogic_vector(0 to threads-1);
signal ex3_n_i1w1lock_dstor_int                       : std_ulogic_vector(0 to threads-1);
signal ex3_n_tlbi_dstor_int                           : std_ulogic_vector(0 to threads-1);
signal ex3_n_pt_dstor_int                             : std_ulogic_vector(0 to threads-1);
signal ex3_n_tlbi_istor_int                           : std_ulogic_vector(0 to threads-1);
signal ex3_n_pt_istor_int                             : std_ulogic_vector(0 to threads-1);
signal ex3_n_ldstmw_align_int                         : std_ulogic_vector(0 to threads-1);
signal ex3_n_ldst_align_int                           : std_ulogic_vector(0 to threads-1); 
signal ex3_n_sprpil_prog_int_xu                       : std_ulogic_vector(0 to threads-1); 
signal ex3_n_tlbpil_prog_int_xu                       : std_ulogic_vector(0 to threads-1); 
signal ex3_n_mmupil_prog_int_xu                       : std_ulogic_vector(0 to threads-1); 
signal ex3_n_iupil_prog_int_xuuc                      : std_ulogic_vector(0 to threads-1);
signal ex3_n_xupil_prog_int_xuuc                      : std_ulogic_vector(0 to threads-1); 
signal ex3_n_ppr_prog_int_en                          : std_ulogic_vector(0 to threads-1);       
signal ex3_n_sprppr_prog_int_xuuc                     : std_ulogic_vector(0 to threads-1); 
signal ex3_n_instrppr_prog_int_xuuc                   : std_ulogic_vector(0 to threads-1);
signal ex3_n_fu_fp_unavail_int_axu                    : std_ulogic_vector(0 to threads-1);
signal ex3_n_xu_fp_unavail_int_xuuc                   : std_ulogic_vector(0 to threads-1);
signal ex3_n_fu_ap_unavail_int_axu                    : std_ulogic_vector(0 to threads-1);
signal ex3_n_xu_ap_unavail_int_xuuc                   : std_ulogic_vector(0 to threads-1);
signal ex3_n_fu_vec_unavail_int_axu                   : std_ulogic_vector(0 to threads-1);
signal ex3_n_xu_vec_unavail_int_xuuc                  : std_ulogic_vector(0 to threads-1);
signal ex3_n_deratmiss_dtlb_int                       : std_ulogic_vector(0 to threads-1);
signal ex3_n_tlbmiss_dtlb_int                         : std_ulogic_vector(0 to threads-1);
signal ex3_n_dacr_dbg_cint_xu                         : std_ulogic_vector(0 to threads-1);   
signal ex3_n_dacw_dbg_cint_xu                         : std_ulogic_vector(0 to threads-1);
signal msr_guest_priv                                 : std_ulogic_vector(0 to threads-1);
signal ex3_n_spr_hpriv_int_xuuc                       : std_ulogic_vector(0 to threads-1);  
signal ex3_n_instr_hpriv_int_xuuc                     : std_ulogic_vector(0 to threads-1);
signal ex3_n_ehpriv_hpriv_int                         : std_ulogic_vector(0 to threads-1);    
signal ex3_np1_dbg_cint_en                            : std_ulogic_vector(0 to threads-1);
signal ex3_np1_instr_flush                            : std_ulogic_vector(0 to threads-1);      
signal ex3_np1_init_flush                             : std_ulogic_vector(0 to threads-1);       
signal ex3_n_ram_flush                                : std_ulogic_vector(0 to threads-1);         
signal ex3_n_mmuhold_flush                            : std_ulogic_vector(0 to threads-1);     
signal ex3_n_ici_flush                                : std_ulogic_vector(0 to threads-1);        
signal ex3_n_dci_flush                                : std_ulogic_vector(0 to threads-1);         
signal ex3_n_mmu_flush                                : std_ulogic_vector(0 to threads-1);                                   
signal ex3_n_multcoll_flush                           : std_ulogic_vector(0 to threads-1);    
signal ex3_n_lsu_dcpe_flush                           : std_ulogic_vector(0 to threads-1);    
signal ex3_n_fu_rfpe_flush, ex3_n_fu_rfpe_det         : std_ulogic_vector(0 to threads-1);
signal ex3_n_xu_rfpe_flush                            : std_ulogic_vector(0 to threads-1);
signal ex3_n_sprg_ue_flush                            : std_ulogic_vector(0 to threads-1);
signal ex3_np1_sprg_ce_flush                          : std_ulogic_vector(0 to threads-1);
signal ex3_n_fu_dep_flush                             : std_ulogic_vector(0 to threads-1);          
signal ex3_n_lsualign_2ucode_flush                    : std_ulogic_vector(0 to threads-1);
signal ex3_n_fu_2ucode_flush                          : std_ulogic_vector(0 to threads-1);
signal ex3_n_derat_dep_flush                          : std_ulogic_vector(0 to threads-1);
signal ex3_n_lsu_dep_flush                            : std_ulogic_vector(0 to threads-1);  
signal ex3_n_lsu_ddpe_flush                           : std_ulogic_vector(0 to threads-1);
signal ex4_n_ldq_full_flush                           : std_ulogic_vector(0 to threads-1);
signal ex4_n_ieratre_par_mcint                        : std_ulogic_vector(0 to threads-1);
signal ex4_n_deratre_par_mcint                        : std_ulogic_vector(0 to threads-1);
signal ex4_n_tlbwemiss_dlrat_int                      : std_ulogic_vector(0 to threads-1);
signal ex4_n_tlbwe_pil_prog_int                       : std_ulogic_vector(0 to threads-1); 
signal ex4_n_tlbmh_mchk_mcint                         : std_ulogic_vector(0 to threads-1); 
signal ex4_n_tlbpar_mchk_mcint                        : std_ulogic_vector(0 to threads-1); 
signal ex4_n_mmu_hpriv_int                            : std_ulogic_vector(0 to threads-1);
signal ex4_ena_prog_int                               : std_ulogic_vector(0 to threads-1);
signal ex4_barrier_flush                              : std_ulogic_vector(0 to threads-1);
signal ex4_lsu_barr_flush                             : std_ulogic_vector(0 to threads-1);
signal ex4_div_barr_flush                             : std_ulogic_vector(0 to threads-1);
signal ex3_hold_block                                 : std_ulogic_vector(0 to threads-1);
signal ex5_csi                                        : std_ulogic_vector(0 to threads-1);
signal exx_thread_stop_mcflush                        : std_ulogic_vector(0 to threads-1);
signal exx_lateflush_mcflush                          : std_ulogic_vector(0 to threads-1);
signal exx_csi_mcflush                                : std_ulogic_vector(0 to threads-1);
signal exx_hold0_mcflush                              : std_ulogic_vector(0 to threads-1);
signal exx_hold1_mcflush                              : std_ulogic_vector(0 to threads-1);
signal exx_barr_mcflush                               : std_ulogic_vector(0 to threads-1);
signal ex4_late_flush                                 : std_ulogic_vector(0 to threads-1);
signal ex4_n_ddmh_mchk_mcint                          : std_ulogic_vector(0 to threads-1);
signal ex3_n_ierat_flush                              : std_ulogic_vector(0 to threads-1);
signal ex3_async_int_block_cond                       : std_ulogic_vector(0 to threads-1);
signal ex3_base_int_block_cond                        : std_ulogic_vector(0 to threads-1);
signal ex3_mchk_int_block_cond                        : std_ulogic_vector(0 to threads-1); 
signal ex5_cm_hold_cond                               : std_ulogic_vector(0 to threads-1); 
signal exx_cm_hold                                    : std_ulogic_vector(0 to threads-1); 
signal ex5_cia_p1                                     : IFAR;
signal ex5_msr_cm                                     : std_ulogic;
signal ex2_msr_updater                                : std_ulogic;
signal ex4_async_block                                : std_ulogic_vector(0 to threads-1);
signal any_ext_perf_ints                              : std_ulogic_vector(0 to threads-1);
signal any_ext_perf_int                               : std_ulogic;
signal ext_int_asserted, crit_int_asserted            : std_ulogic_vector(0 to threads-1); 
signal perf_int_asserted                              : std_ulogic_vector(0 to threads-1); 
signal rf1_is_dci                                     : std_ulogic;
signal rf1_is_ici                                     : std_ulogic;
signal rf1_th_fld_val                                 : std_ulogic;
signal rf1_opcode_is_31                               : boolean;
signal rf1_opcode_is_0                                : boolean;
signal rf1_opcode_is_19                               : boolean;
signal ex3_dlk_dstor_cond0, ex3_dlk_dstor_cond1       : std_ulogic_vector(0 to threads-1);
signal ex3_dlk_dstor_cond2, ex3_dlk_dstor_cond        : std_ulogic_vector(0 to threads-1);
signal ex4_n_fu_rfpe_flush                            : std_ulogic_vector(0 to threads-1);
signal ex4_n_xu_rfpe_flush                            : std_ulogic_vector(0 to threads-1);
signal ex4_n_flush_pri_ehpriv                         : std_ulogic_vector(0 to threads-1);
signal ici_hold_present                               : std_ulogic;
signal ex4_n_fu_rfpe_set,   ex4_n_xu_rfpe_set         : std_ulogic;
signal pc_err_mcsr, pc_err_mcsr_rpt                   : std_ulogic_vector(0 to 11*threads-1);
signal dbg_group0, dbg_group1, dbg_group2, dbg_group3,
       dbg_group4, dbg_group5, dbg_group6, dbg_group7, 
       dbg_group8, dbg_group9, dbg_group10,dbg_group11,
       dbg_group12,dbg_group13,dbg_group14,dbg_group15,
       dbg_group16,dbg_group17,dbg_group18,dbg_group19,
       dbg_group20,dbg_group21,dbg_group22,dbg_group23,
       dbg_group24,dbg_group25,dbg_group26,dbg_group27,
       dbg_group28,dbg_group29,dbg_group30,dbg_group31: std_ulogic_vector(0 to 87);
signal trg_group0 ,trg_group1 ,trg_group2 ,trg_group3 : std_ulogic_vector(0 to 11);
signal cpl_debug_data_in_int                          : std_ulogic_vector(0 to 87);
signal dbg_match                                      : ARY3;
signal dbg_misc                                       : ARY4;
signal dbg_valids, dbg_valids_opc, dbg_msr, dbg_int_types   : ARY5;
signal dbg_async_block                                : ARY7;
signal dbg_iuflush                                    : ARY9;
signal ex5_flush_pri_enc_dbg,dbg_hold                 : ARY6;
signal ex4_cia_out                                    : ARY_IFAR;
signal ex5_axu_ucode_val_opc                          : std_ulogic_vector(0 to threads-1);
signal ex5_axu_val_dbg_opc,  ex5_xu_val_dbg_opc       : std_ulogic_vector(0 to threads-1);
signal br_debug                                       : std_ulogic_vector(0 to 11);
signal ex4_xu_siar_val,  ex4_axu_siar_val             : std_ulogic;
signal ex4_siar_cpl                                   : std_ulogic_vector(0 to threads-1);
signal ex4_siar_sel_act                               : std_ulogic;
signal ex4_siar_axu_sel                               : std_ulogic;
signal ex4_siar_tid, ex4_siar_sel, siar_cm            : std_ulogic_vector(0 to 3);
signal ex5_xu_ppc_cpl,        ex5_axu_ppc_cpl         : std_ulogic_vector(0 to threads-1);
signal ex5_xu_trace_val,      ex5_axu_trace_val       : std_ulogic;
signal exx_act                                        : std_ulogic_vector(0 to 4);
signal ex1_ifar_act, ex2_ifar_act, ex3_ifar_act       : std_ulogic_vector(0 to threads-1);
signal ex4_nia_act                                    : std_ulogic_vector(0 to threads-1);
signal ex2_axu_act                                    : std_ulogic;
signal ex4_dbsr_act, ex4_mcsr_act, ex4_esr_act        : std_ulogic_vector(0 to threads-1);
signal ex5_mcsr_act                                   : std_ulogic;
signal ex3_uc_cia_act                                 : std_ulogic_vector(0 to threads-1);
signal exx_flush_inf_act, ex4_flush_inf_act           : std_ulogic;
signal spr_bit_w_int_act                              : std_ulogic;
signal exx_np1_icmp_dbg_cint                          : std_ulogic_vector(0 to threads-1);
signal exx_np1_icmp_dbg_event                         : std_ulogic_vector(0 to threads-1);
signal ex4_np1_icmp_dbg_en                            : std_ulogic_vector(0 to threads-1);
signal ex4_n_flush_pri_icmp                           : std_ulogic_vector(0 to threads-1);
signal ex4_n_flush_pri_irpt                           : std_ulogic_vector(0 to threads-1);
signal ex4_np1_icmp_dbg_event                         : std_ulogic_vector(0 to threads-1);
signal ex4_np1_icmp_dbg_cint                          : std_ulogic_vector(0 to threads-1);
signal ex4_icmp_async_block                           : std_ulogic_vector(0 to threads-1);
signal exx_np1_irpt_dbg_cint                          : std_ulogic_vector(0 to threads-1);
signal exx_np1_irpt_dbg_event                         : std_ulogic_vector(0 to threads-1);
signal ex4_n_flush_pri_dacr_async                     : std_ulogic_vector(0 to threads-1);
signal ex4_ram_cpl                                    : std_ulogic_vector(0 to threads-1);
signal ex4_siar_cm_mask                               : IFAR;
signal ex3_n_tlb_mchk_flush_en                        : std_ulogic_vector(0 to threads-1);
signal ex3_n_tlbmh_mchk_flush                         : std_ulogic_vector(0 to threads-1);
signal ex3_n_tlbpe_mchk_flush                         : std_ulogic_vector(0 to threads-1);
signal ex3_n_dexx_mchk_flush_en                       : std_ulogic_vector(0 to threads-1);
signal ex3_n_demh_mchk_flush                          : std_ulogic_vector(0 to threads-1);
signal ex3_n_depe_mchk_flush                          : std_ulogic_vector(0 to threads-1);
signal ex3_n_mmu_mchk_flush_only                      : std_ulogic;
signal ex3_is_any_ldst                                : std_ulogic;
signal ex5_ram_issue_gated                            : std_ulogic_vector(0 to threads-1);
signal rfpe_quiesced                                  : std_ulogic;
signal rfpe_quiesce_cond_b, rfpe_quiesced_ctr_zero_b  : std_ulogic;
signal ex4_axu_trap_pie                               : std_ulogic_vector(0 to threads-1);
signal rf1_is_tlbre                                   : std_ulogic;
signal rf1_is_tlbsx, rf1_is_tlbsrx                    : std_ulogic;
signal tlbsx_async_block_set                          : std_ulogic_vector(0 to threads-1);
signal tlbsx_async_block_clr                          : std_ulogic_vector(0 to threads-1);

begin


tiup <= '1';
tidn <= '0';

exx_act_d      <= (clk_override_q or clkg_ctl_q or dec_cpl_rf0_act) & exx_act(0 to 3);

exx_act(0)     <= exx_act_q(0);
exx_act(1)     <= exx_act_q(1);
exx_act(2)     <= exx_act_q(2);
exx_act(3)     <= exx_act_q(3) or or_reduce(ex3_axu_val_q);
exx_act(4)     <= exx_act_q(4);

ex2_axu_act    <= or_reduce(ex2_axu_act_q) or clk_override_q;

ex1_ifar_act   <= ex1_xu_val_q or ex1_xu_issued_q or ex1_ucode_val_q or ex1_axu_act_q or (0 to threads-1=>clk_override_q);
ex2_ifar_act   <= ex2_xu_val_q or ex2_xu_issued_q or ex2_ucode_val_q or ex2_axu_act_q or (0 to threads-1=>clk_override_q);
ex3_ifar_act   <= ex3_xu_val_q or ex3_xu_issued_q or ex3_ucode_val_q or ex3_axu_val_q or (0 to threads-1=>clk_override_q) or ex3_axu_issued_q;

spr_bit_w_int_act    <= spr_bit_act_q or clkg_ctl_q;

-- Deocode
rf1_opcode_is_31  <= dec_cpl_rf1_instr(0 to 5) = "011111";
rf1_opcode_is_0   <= dec_cpl_rf1_instr(0 to 5) = "000000";
rf1_opcode_is_19  <= dec_cpl_rf1_instr(0 to 5) = "010011";
rf1_is_tlbsx      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1110010010" else '0';  -- 31/914
rf1_is_tlbsrx     <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1101010010" else '0';  -- 31/850
rf1_is_tlbre      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1110110010" else '0';  -- 31/946
rf1_is_tlbwe      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1111010010" else '0';  -- 31/978
rf1_is_eratre     <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0010110011" else '0';  -- 31/179
rf1_is_wait       <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0000111110" else '0';
rf1_is_icblc      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0011100110" else '0';
rf1_is_icbtls     <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0111100110" else '0';
rf1_is_dcblc      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0110000110" else '0';
rf1_is_dcbtls     <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0010100110" else '0';
rf1_is_dcbtstls   <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0010000110" else '0';
rf1_is_rfi        <= '1' when rf1_opcode_is_19 and dec_cpl_rf1_instr(21 to 30) = "0000110010" else '0'; -- 19/50
rf1_is_rfci       <= '1' when rf1_opcode_is_19 and dec_cpl_rf1_instr(21 to 30) = "0000110011" else '0'; -- 19/51
rf1_is_rfgi       <= '1' when rf1_opcode_is_19 and dec_cpl_rf1_instr(21 to 30) = "0001100110" else '0'; -- 19/102
rf1_is_rfmci      <= '1' when rf1_opcode_is_19 and dec_cpl_rf1_instr(21 to 30) = "0000100110" else '0'; -- 19/38
rf1_is_mfspr      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0101010011" else '0'; -- 31/339
rf1_is_mtspr      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0111010011" else '0'; -- 31/467
rf1_is_mtmsr      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0010010010" else '0'; -- 31/146
rf1_is_wrtee      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0010000011" else '0'; -- 31/131
rf1_is_wrteei     <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0010100011" else '0'; -- 31/163
rf1_is_erativax   <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1100110011" else '0'; -- 31/819
rf1_is_isync      <= '1' when rf1_opcode_is_19 and dec_cpl_rf1_instr(21 to 30) = "0010010110" else '0'; -- 19/150
rf1_is_sc         <= '1' when                      dec_cpl_rf1_instr( 0 to  5) = "010001"     else '0'; -- 17
rf1_is_dci        <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0111000110" else '0'; -- 31/454
rf1_is_ici        <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1111000110" else '0'; -- 31/966
rf1_is_tlbivax    <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1100010010" else '0'; -- 31/786
rf1_is_ehpriv     <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "0100001110" else '0'; -- 31/270
rf1_is_attn       <= '1' when rf1_opcode_is_0  and dec_cpl_rf1_instr(21 to 30) = "0100000000" else '0'; -- 0/256
rf1_is_icswx      <= '1' when rf1_opcode_is_31 and (dec_cpl_rf1_instr(21 to 30) = "0110010110" or           -- 31/406
                                                    dec_cpl_rf1_instr(21 to 30) = "1110110110") else '0';   -- 31/950
rf1_is_any_ldstmw <= '1' when dec_cpl_rf1_instr(0 to 4) = "10111" else '0';                                       -- 46/47
rf1_sc_lev        <= dec_cpl_rf1_instr(26);

rf1_is_ldbrx      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1000010100" else '0';
rf1_is_lwbrx      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1000010110" else '0';
rf1_is_lhbrx      <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1100010110" else '0';
rf1_is_stdbrx     <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1010010100" else '0';
rf1_is_stwbrx     <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1010010110" else '0';
rf1_is_sthbrx     <= '1' when rf1_opcode_is_31 and dec_cpl_rf1_instr(21 to 30) = "1110010110" else '0';

rf1_byte_rev      <= rf1_is_lhbrx or rf1_is_lwbrx or rf1_is_ldbrx or rf1_is_sthbrx or rf1_is_stwbrx or rf1_is_stdbrx;
rf1_is_dlock      <= rf1_is_dcblc or rf1_is_dcbtls or rf1_is_dcbtstls;
rf1_is_ilock      <= rf1_is_icblc or rf1_is_icbtls;

rf1_is_mtxucr0    <= rf1_is_mtspr and (dec_cpl_rf1_instr(11 to 20) = "1011011111");   -- 1014

rf1_th_fld_val    <= (dec_cpl_rf1_instr(7 to 10) = "0000") or (dec_cpl_rf1_instr(7 to 10) = "0010");
ex1_is_dci_d      <= rf1_is_dci and rf1_th_fld_val;
ex1_is_ici_d      <= rf1_is_ici and rf1_th_fld_val;

ex3_np1_instr_flush_d            <= (ex2_is_mtmsr_q       or
                                     ex2_is_isync_q       or
                                     ex2_is_tlbivax_q     or
                                     ex2_is_erativax_q    or
                                     ex2_is_attn_q        or
                                     ex2_is_dci_q         or
                                     ex2_is_ici_q);


spare_4_d(0)      <= not (rf1_is_tlbsx or rf1_is_tlbsrx);
spare_4_d(1 to 3) <= not spare_4_q(0 to 2);

spare_4_d(4 to 7) <= not (tlbsx_async_block_set or (spare_4_q(4 to 7) and not tlbsx_async_block_clr));

tlbsx_async_block_set   <= gate(ex4_instr_cpl_q,spare_4_q(3));
tlbsx_async_block_clr   <= ex4_anyuc_val_q or ex5_is_any_int or ex4_thread_stop_q;

   
xuq_cpl_slice : for t in 0 to threads-1 generate

   signal ex4_cia_b_q,           ex4_cia_b_d             : IFAR;
   signal ex4_uc_cia_q,          ex4_uc_cia_d            : IFAR_UC;
   signal ex4_axu_instr_type_q,  ex4_axu_instr_type_d    : std_ulogic_vector(0 to 2);
   signal ex5_mem_attr_q                                 : std_ulogic_vector(lsu_xu_ex3_attr'range);     
   signal ex5_ivo_sel_q,         ex4_ivo_sel             : std_ulogic_vector(0 to ivos-1);
   signal ex5_flush_pri_dbg_q                            : std_ulogic_vector(0 to Fnp1);                 -- input=>ex4_flush_pri,            act=>trace_bus_enable_q,   sleep=>Y,   needs_sreset=>0, scan=>N
   signal ex4_cia_flush,         flush_ifar              : IFAR;
   signal ex4_axu_instr_type                             : std_ulogic_vector(0 to 2);
   signal ex3_ifar, ex4_ifar, ex3_spr_lr                 : IFAR;
   signal ex5_flush_ifar                                 : IFAR;
   signal ex4_n_flush_cond,      ex4_n_flush_pri         : std_ulogic_vector(0 to Fn);
   signal ex4_np1_flush_cond,    ex4_np1_flush_pri       : std_ulogic_vector(Fn+1 to Fnp1);
   signal ex4_np1_flush_pri_nongated                     : std_ulogic_vector(Fn+1 to Fnp1);
   signal ex4_np1_flush_pri_instr                        : std_ulogic_vector(0 to RFI);
   signal ex4_flush_pri                                  : std_ulogic_vector(0 to Fnp1);
   signal ex4_n_flush_pri_unavail                        : std_ulogic_vector(0 to VEC);
   signal ex4_n_flush_pri_ena                            : std_ulogic_vector(0 to 1);
   signal ex5_ivo_mask_guest                             : std_ulogic_vector(0 to ivos-1);
   signal ex5_ivo_guest_sel, ex5_ivo_hypv_sel            : std_ulogic_vector(0 to ivos-1);
   signal ex5_ivo                                        : std_ulogic_vector(52 to 59);
   signal ex4_nia                                        : IFAR;
   signal ex4_nia_instr, ex4_nia_cpl                     : IFAR;
   signal ex4_cia                                        : IFAR;
   signal ex4_cia_p1                                     : IFAR;
   signal ex4_cia_sel, ex4_nia_sel                       : IFAR;
   signal ex4_uc_nia                                     : IFAR_UC;
   signal ex4_esr_mask                                   : std_ulogic_vector(0 to cpl_spr_ex5_esr'length/threads-1);
   signal ex4_cm_mask                                    : IFAR;
   signal ex4_dbsr_cond                                  : std_ulogic_vector(0 to 1);
   signal ex4_dbsr_en_cond                               : std_ulogic_vector(0 to 1);
   signal ex4_esr_cond,          ex4_esr_pri             : std_ulogic_vector(0 to UCT);

   begin


   --=============================================================================
   --=============================================================================
   --
   -- Interrupt Conditions
   --
   --=============================================================================
   --=============================================================================

   -------------------------------------------------------------------------------
   -- Critical External Input Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_crit_cint(t)             <= spr_cpl_crit_interrupt(t) and not ex3_async_int_block(t);

   -------------------------------------------------------------------------------
   -- Machine Check Interrupt
   -------------------------------------------------------------------------------
   -- Enable
   ex3_mchk_int_en(t)              <= (msr_me_q(t) or msr_gs_q(t)) and not ex3_mchk_int_block(t);

   -------------------------------------------------------------------------------
   -- N Flushes [tlb parity error flush]
   -------------------------------------------------------------------------------
   ex3_n_tlbmh_mchk_flush(t)        <= ex3_n_tlb_mchk_flush_en(t) and ex3_tlb_multihit_err_q(t);
   ex3_n_tlbpe_mchk_flush(t)        <= ex3_n_tlb_mchk_flush_en(t) and ex3_tlb_par_err_q(t);   
   
   ex3_n_tlb_mchk_flush(t)          <=                      ex3_n_tlbmh_mchk_flush(t) or
                                                            ex3_n_tlbpe_mchk_flush(t);

   -------------------------------------------------------------------------------
   -- Instr Machine Check Interrupt
   -------------------------------------------------------------------------------
   ex3_n_tlb_mchk_flush_en(t)       <= ex3_n_mmu_mchk_flush_only and mmu_eratmiss_done_q(t);
   ex3_n_ieratsx_par_mchk_mcint(t)  <= ex3_xu_val(t) and iu_xu_ierat_ex3_par_err(t);

   -- Conditions
   ex3_n_iemh_mchk_mcint_xuuc(t)    <= ex3_iu_error_q(6);
   ex3_n_iepe_mchk_mcint_xuuc(t)    <= ex3_iu_error_q(5);
   ex3_n_il2ecc_mchk_mcint_xuuc(t)  <= ex3_iu_error_q(2);
   ex3_n_tlbmh_mchk_mcint(t)        <= not ex3_n_tlb_mchk_flush_en(t) and ex3_tlb_multihit_err_q(t);
   ex3_n_tlbpe_mchk_mcint(t)        <= not ex3_n_tlb_mchk_flush_en(t) and ex3_tlb_par_err_q(t);   
   ex3_n_tlblru_mchk_mcint(t)       <= ex3_tlb_lru_par_err_q(t);       
   ex3_n_tlbsrej_mchk_mcint(t)      <= ex3_tlb_local_snoop_reject_q(t);
   ex3_n_ieratre_par_mchk_mcint(t)  <= ex5_xu_val_q(t) and ex5_ieratre_par_err_q(t);
   
   spare_5_d(t)                     <= not(ex3_n_tlbpe_mchk_mcint(t) or ex3_n_tlblru_mchk_mcint(t));
   
   -- Summary
   ex3_n_imchk_mcint(t)             <=(ex3_xuuc_val(t) and (ex3_n_iemh_mchk_mcint_xuuc(t) or  
                                                            ex3_n_iepe_mchk_mcint_xuuc(t) or  
                                                            ex3_n_il2ecc_mchk_mcint_xuuc(t)))
                                                            or
                                                            ex3_n_tlbmh_mchk_mcint(t) or
                                                            ex3_n_tlbpe_mchk_mcint(t) or
                                                            ex3_n_tlblru_mchk_mcint(t) or 
                                                            ex3_n_tlbsrej_mchk_mcint(t) or
                                                            ex3_n_ieratre_par_mchk_mcint(t);

   -------------------------------------------------------------------------------
   -- Data Machine Check Interrupt
   -------------------------------------------------------------------------------
   ex3_n_dexx_mchk_flush_en(t)      <= ex3_n_mmu_mchk_flush_only and ex3_is_any_ldst;

   -- Conditions
   ex3_n_demh_mchk_mcint_xu(t)      <= not ex3_n_dexx_mchk_flush_en(t) and lsu_xu_ex3_derat_multihit_err(t);
   ex3_n_depe_mchk_mcint_xu(t)      <= not ex3_n_dexx_mchk_flush_en(t) and lsu_xu_ex3_derat_par_err(t);
   ex3_n_dl2ecc_mchk_mcint(t)       <= lsu_xu_ex3_l2_uc_ecc_err(t);
   ex3_n_ddpe_mchk_mcint_xu(t)      <= lsu_xu_ex3_ddir_par_err  and spr_xucr0_mddp;
   ex3_n_deratre_par_mchk_mcint(t)  <= ex5_xu_val_q(t) and ex5_deratre_par_err_q(t);

   ex3_n_dpovr_mchk_mcint(t)        <= ex4_xu_val(t) and ex4_mtdp_nr_q and not lsu_xu_ex4_mtdp_cr_status; 
   ex3_n_dcpe_mchk_mcint(t)         <= ex6_xu_val_q(t) and lsu_xu_ex6_datc_par_err    and spr_xucr0_mdcp;


   -- Summary
   ex3_n_dmchk_mcint(t)             <=(ex3_xu_val(t)   and (ex3_n_demh_mchk_mcint_xu(t) or
                                                            ex3_n_depe_mchk_mcint_xu(t) or
                                                            ex3_n_ddpe_mchk_mcint_xu(t)))
                                                            or
                                                            ex3_n_dl2ecc_mchk_mcint(t) or
                                                            ex3_n_dpovr_mchk_mcint(t) or
                                                            ex3_n_dcpe_mchk_mcint(t) or
                                                            ex3_n_deratre_par_mchk_mcint(t);

   ex4_n_ddmh_mchk_en_d(t)          <= ex3_xu_val(t) and dec_cpl_ex3_ddmh_en and spr_xucr4_mddmh;
   ex4_n_ddmh_mchk_mcint(t)         <= ex4_n_ddmh_mchk_en_q(t) and lsu_xu_ex4_n_lsu_ddmh_flush(t);

   -------------------------------------------------------------------------------
   -- Async Machine Check Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_ext_mchk_mcint(t)        <=  external_mchk_q(t) and not ex3_async_int_block(t);
                                                            
   -------------------------------------------------------------------------------
   -- Data Storage Interrupt
   -------------------------------------------------------------------------------
   ex3_ct(t)                        <=(spr_cpl_ex3_ct_le(t) and     lsu_xu_ex3_attr(8)) or
                                      (spr_cpl_ex3_ct_be(t) and not lsu_xu_ex3_attr(8));

   ex3_dlk_dstor_cond0(t)           <=                           msrp_uclep_q(t) and msr_gs_q(t);
   ex3_dlk_dstor_cond1(t)           <= not msr_ucle_q(t) and not msrp_uclep_q(t);
   ex3_dlk_dstor_cond2(t)           <= not msr_ucle_q(t) and                     not msr_gs_q(t);
   
   ex3_dlk_dstor_cond(t)            <= ex3_dlk_dstor_cond0(t) or
                                       ex3_dlk_dstor_cond1(t) or
                                       ex3_dlk_dstor_cond2(t);
   -- Conditions
   ex3_n_rwaccess_dstor_int(t)      <= ex3_xuuc_val(t) and derat_xu_ex3_dsi(t);
   ex3_n_i1w1lock_dstor_int(t)      <= ex3_xu_val(t) and lsu_xu_ex3_dsi(t);                                                                     
   ex3_n_uct_dstor_int(t)           <= ex3_xu_val(t) and ex3_is_icswx_q and not ex3_ct(t);                                              
   ex3_n_dlk0_dstor_int(t)          <= ex3_xu_val(t) and msr_pr_q(t) and ex3_dlk_dstor_cond(t) and ex3_is_dlock_q;                         
   ex3_n_dlk1_dstor_int(t)          <= ex3_xu_val(t) and msr_pr_q(t) and ex3_dlk_dstor_cond(t) and ex3_is_ilock_q;                         
   ex3_n_tlbi_dstor_int(t)          <= ex3_tlb_inelig_q(t)   and ex3_mmu_esr_data_q(t);      -- PTE Realod when all ways are IPROT=1
   ex3_n_pt_dstor_int(t)            <= ex3_tlb_pt_fault_q(t) and ex3_mmu_esr_data_q(t);      -- HTW attempted to install invalid entry in TLB
   ex3_n_vf_dstor_int(t)            <= ex3_xuuc_val(t) and lsu_xu_ex3_derat_vf and ex3_is_any_ldst;                   
   -- Summary
   ex3_n_dstor_int(t)               <=                      ex3_n_rwaccess_dstor_int(t) or
                                                            ex3_n_i1w1lock_dstor_int(t) or
                                                            ex3_n_uct_dstor_int(t) or
                                                            ex3_n_dlk0_dstor_int(t) or
                                                            ex3_n_dlk1_dstor_int(t) or
                                                            ex3_n_tlbi_dstor_int(t) or
                                                            ex3_n_pt_dstor_int(t) or
                                                            ex3_n_vf_dstor_int(t);

   -------------------------------------------------------------------------------
   -- Instruction Storage Interrupt
   -------------------------------------------------------------------------------
   -- Conditions
   ex3_n_exaccess_istor_int(t)      <= ex3_xuuc_val(t)  and   ex3_iu_error_q(4);
   ex3_n_tlbi_istor_int(t)          <= ex3_tlb_inelig_q(t)   and not ex3_mmu_esr_data_q(t);  -- PTE Realod when all ways are IPROT=1
   ex3_n_pt_istor_int(t)            <= ex3_tlb_pt_fault_q(t) and not ex3_mmu_esr_data_q(t);  -- HTW attempted to install invalid entry in TLB
   -- Summary
   ex3_n_istor_int(t)               <=                      ex3_n_exaccess_istor_int(t) or
                                                            ex3_n_tlbi_istor_int(t) or
                                                            ex3_n_pt_istor_int(t);
   
   -------------------------------------------------------------------------------
   -- External Input Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_ext_int(t)               <= spr_cpl_ext_interrupt(t) and not ex3_async_int_block(t);

   -------------------------------------------------------------------------------
   -- Alignment Interrupt
   -------------------------------------------------------------------------------
   -- Conditions
   ex3_n_ldstmw_align_int(t)        <= ex3_ucode_val(t) and ex3_n_align_int_q;
   ex3_n_ldst_align_int(t)          <= ex3_xu_val(t)    and lsu_xu_ex3_align(t);
   -- Summary
   ex3_n_align_int(t)               <=                      ex3_n_ldstmw_align_int(t) or
                                                            ex3_n_ldst_align_int(t);

   -------------------------------------------------------------------------------
   -- Program Interrupt [illegal]
   -------------------------------------------------------------------------------
   -- Conditions
   -- Priv SPR accessed in problem state needs to get Priv-Prog Int even if it's an illegal SPR.
   ex3_n_sprpil_prog_int_xu(t)      <= spr_cpl_ex3_spr_illeg and not (spr_cpl_ex3_spr_priv and msr_pr_q(t));
   ex3_n_tlbpil_prog_int_xu(t)      <= dec_cpl_ex3_tlb_illeg;
   ex3_n_mmupil_prog_int_xu(t)      <= mm_xu_illeg_instr(t) and not ex7_is_tlbwe_q(t);
   ex3_n_xupil_prog_int_xuuc(t)     <= ex3_illegal_op_q;
   ex3_n_iupil_prog_int_xuuc(t)     <= ex3_iu_error_q(1);
   -- Summary
   ex3_n_pil_prog_int(t)            <=(ex3_xuuc_val(t) and (ex3_n_iupil_prog_int_xuuc(t) or
                                                            ex3_n_xupil_prog_int_xuuc(t)))
                                                            or
                                      (ex3_xu_val(t)   and (ex3_n_sprpil_prog_int_xu(t) or
                                                            ex3_n_tlbpil_prog_int_xu(t) or
                                                            ex3_n_mmupil_prog_int_xu(t)));

   -------------------------------------------------------------------------------
   -- Program Interrupt [illegal MAS settings]
   -------------------------------------------------------------------------------
   ex3_n_tlbwe_pil_prog_int(t)      <= ex3_tlb_illeg_q(t)   and     ex8_is_tlbwe_q(t);

   -------------------------------------------------------------------------------
   -- Program Interrupt [privileged]
   -------------------------------------------------------------------------------
   -- Enable
   ex3_n_ppr_prog_int_en(t)         <= msr_pr_q(t) and not (ex3_n_dlk0_dstor_int(t) or
                                                            ex3_n_dlk1_dstor_int(t));
   -- Conditions
   ex3_n_sprppr_prog_int_xuuc(t)    <= spr_cpl_ex3_spr_priv;
   ex3_n_instrppr_prog_int_xuuc(t)  <= dec_cpl_ex3_instr_priv and not ex3_is_ehpriv_q;
   -- Summary
   ex3_n_ppr_prog_int(t)            <= ex3_n_ppr_prog_int_en(t) and
                                       ex3_xuuc_val(t) and (ex3_n_sprppr_prog_int_xuuc(t) or
                                                            ex3_n_instrppr_prog_int_xuuc(t));

   -------------------------------------------------------------------------------
   -- Program Interrupt [unimplemented]
   -------------------------------------------------------------------------------
   -- Add the 2ucode flush.. otherwise could run into priority problems.
   ex3_n_puo_prog_int(t)            <= (ex3_ucode_val(t) or ex3_n_2ucode_flush(t)) and  spr_ccr2_ucode_dis;

   -------------------------------------------------------------------------------
   -- Program Interrupt [trap]
   -------------------------------------------------------------------------------
   ex3_np1_ptr_prog_int(t)          <= ex3_xu_val(t) and alu_cpl_ex3_trap_val and not (spr_dbcr0_trap(t) and msr_de_q(t) and dbcr0_idm_q(t) and debug_event_en_q(t));

   -------------------------------------------------------------------------------
   -- Program Interrupt [enabled]
   -------------------------------------------------------------------------------
   -- Enable
   -- Need to block while base interrupts are in progress, until (FE0|FE1)==0.  This will keep this from occuring twice.
   ex3_n_fpena_prog_int(t)          <= fu_xu_ex3_trap(t) and spr_cpl_fp_precise(t) and not ex3_async_int_block_noaxu(t);
   ex3_n_apena_prog_int(t)          <= ex3_any_val(t) and fu_xu_ex3_ap_int_req(t);
   -- Summary
   ex3_n_ena_prog_int(t)            <= 
                                                            ex3_n_fpena_prog_int(t) or
                                                            ex3_n_apena_prog_int(t);

   -------------------------------------------------------------------------------
   -- XX Unavailable Interrupt
   -------------------------------------------------------------------------------
   -- Conditions
   ex3_n_fu_fp_unavail_int_axu(t)   <= ex3_axu_instr_type_q(2+3*t)   and not msr_fp_q(t);
   ex3_n_xu_fp_unavail_int_xuuc(t)  <= dec_cpl_ex3_axu_instr_type(2) and not msr_fp_q(t);
   ex3_n_fu_ap_unavail_int_axu(t)   <= ex3_axu_instr_type_q(3*t)     and not ccr2_ap_q(t);
   ex3_n_xu_ap_unavail_int_xuuc(t)  <= dec_cpl_ex3_axu_instr_type(0) and not ccr2_ap_q(t);   
   ex3_n_fu_vec_unavail_int_axu(t)  <= ex3_axu_instr_type_q(1+3*t)   and not msr_spv_q(t);
   ex3_n_xu_vec_unavail_int_xuuc(t) <= dec_cpl_ex3_axu_instr_type(1) and not msr_spv_q(t);
   -- Summary
   ex3_n_fp_unavail_int(t)          <=(ex3_axu_val(t)  and  ex3_n_fu_fp_unavail_int_axu(t)) or
                                      (ex3_xuuc_val(t) and  ex3_n_xu_fp_unavail_int_xuuc(t));

   ex3_n_ap_unavail_int(t)          <=(ex3_axu_val(t)  and  ex3_n_fu_ap_unavail_int_axu(t)) or
                                      (ex3_xuuc_val(t) and  ex3_n_xu_ap_unavail_int_xuuc(t));

   ex3_n_vec_unavail_int(t)         <=(ex3_axu_val(t)  and  ex3_n_fu_vec_unavail_int_axu(t)) or
                                      (ex3_xuuc_val(t) and  ex3_n_xu_vec_unavail_int_xuuc(t));

   ex3_n_any_unavail_int(t)         <=(ex3_axu_val(t)  and (ex3_n_fu_fp_unavail_int_axu(t) or
                                                            ex3_n_fu_ap_unavail_int_axu(t) or
                                                            ex3_n_fu_vec_unavail_int_axu(t)))
                                                            or
                                      (ex3_xuuc_val(t) and (ex3_n_xu_fp_unavail_int_xuuc(t) or
                                                            ex3_n_xu_ap_unavail_int_xuuc(t) or
                                                            ex3_n_xu_vec_unavail_int_xuuc(t)));

   -------------------------------------------------------------------------------
   -- Instruction Based Interrupts [rfi,sc,trap]
   -------------------------------------------------------------------------------
   -- Conditions
   ex3_np1_sc_int(t)                <= ex3_xu_val(t) and ex3_is_sc_q;
   ex3_np1_rfi(t)                   <= ex3_xu_val(t) and (ex3_is_rfmci_q or ex3_is_rfci_q or ex3_is_rfi_q or ex3_is_rfgi_q);
   -- Summary
   ex3_np1_instr_int(t)             <=                      ex3_np1_ptr_prog_int(t) or
                                                            ex3_np1_sc_int(t) or                                                      
                                                            ex3_np1_rfi(t);

   -------------------------------------------------------------------------------
   -- Decrementer Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_dec_int(t)               <= spr_cpl_dec_interrupt(t)   and not ex3_async_int_block(t);

   -------------------------------------------------------------------------------
   -- Fixed Interval Timer Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_fit_int(t)               <= spr_cpl_fit_interrupt(t)   and not ex3_async_int_block(t);

   -------------------------------------------------------------------------------
   -- Watchdog Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_wdog_cint(t)             <= spr_cpl_wdog_interrupt(t)  and not ex3_async_int_block(t);

   -------------------------------------------------------------------------------
   -- Data TLB Interrupt
   -------------------------------------------------------------------------------
   -- Conditions
   ex3_n_deratmiss_dtlb_int(t)      <= ex3_xuuc_val(t)   and     derat_xu_ex3_miss(t)   and     spr_ccr2_notlb;
   ex3_n_tlbmiss_dtlb_int(t)        <= ex3_tlb_miss_q(t) and     ex3_mmu_esr_data_q(t)  and not spr_ccr2_notlb;
   -- Summary
   ex3_n_dtlb_int(t)                <=                      ex3_n_deratmiss_dtlb_int(t) or
                                                            ex3_n_tlbmiss_dtlb_int(t);
   -------------------------------------------------------------------------------
   -- Instruction TLB Interrupt
   -------------------------------------------------------------------------------
   -- Conditions
   ex3_n_ieratmiss_itlb_int(t)      <= ex3_xuuc_val(t)   and     ex3_iu_error_q(7)      and     spr_ccr2_notlb;
   ex3_n_tlbmiss_itlb_int(t)        <= ex3_tlb_miss_q(t) and not ex3_mmu_esr_data_q(t)  and not spr_ccr2_notlb;
   -- Summary
   ex3_n_itlb_int(t)                <=                      ex3_n_ieratmiss_itlb_int(t) or
                                                            ex3_n_tlbmiss_itlb_int(t);

   -------------------------------------------------------------------------------
   -- Debug Interrupts [synchronous]
   -------------------------------------------------------------------------------
   -- Enabled
   debug_event_en_d(t)              <= not (spr_epcr_duvd(t) and not spr_msr_gs(t) and not spr_msr_pr(t));

   -- Conditions
   -- Note: BRT & ICMP don't record in the DBSR if MSR[DE]=0
   ex3_n_brt_dbg_cint(t)            <= ex3_xu_val(t)    and ex3_br_update_q                 and spr_dbcr0_brt(t)  and msr_de_q(t) and debug_event_en_q(t);
   ex3_n_trap_dbg_cint(t)           <= ex3_xu_val(t)    and alu_cpl_ex3_trap_val            and spr_dbcr0_trap(t)                 and debug_event_en_q(t);
   ex3_n_ret_dbg_cint(t)            <= ex3_xu_val(t)    and (ex3_is_rfi_q or ex3_is_rfgi_q) and spr_dbcr0_ret(t)                  and debug_event_en_q(t);

   ex3_n_iac_dbg_cint(t)            <= not ram_mode_q(t) and not ex5_in_ucode_q(t) and
                                     ((ex3_xuuc_val(t)   and not ex3_xu_is_ucode_q) or
                                      (ex3_axu_val(t)    and not ex3_axu_is_ucode_q(t))) and
                                                           (ex3_iac1_cmpr(t) or
                                                            ex3_iac2_cmpr(t) or
                                                            ex3_iac3_cmpr(t) or
                                                            ex3_iac4_cmpr(t))         and debug_event_en_q(t);
                                                    
   ex3_n_async_dacr_dbg_cint(t)     <=                     not ex3_async_int_block(t) and
                                                           (fxu_cpl_ex3_dac1r_cmpr_async(t) or 
                                                            fxu_cpl_ex3_dac2r_cmpr_async(t));
                                                    
   ex3_n_dacr_dbg_cint_xu(t)        <=                      fxu_cpl_ex3_dac1r_cmpr(t) or
                                                            fxu_cpl_ex3_dac2r_cmpr(t) or
                                                            fxu_cpl_ex3_dac3r_cmpr(t) or
                                                            fxu_cpl_ex3_dac4r_cmpr(t);
                                                    
   ex3_n_dacw_dbg_cint_xu(t)        <=                      fxu_cpl_ex3_dac1w_cmpr(t) or
                                                            fxu_cpl_ex3_dac2w_cmpr(t) or
                                                            fxu_cpl_ex3_dac3w_cmpr(t) or
                                                            fxu_cpl_ex3_dac4w_cmpr(t);

   ex3_n_dac_dbg_cint(t)            <=(ex3_xu_val(t) and (  ex3_n_dacr_dbg_cint_xu(t) or
                                                            ex3_n_dacw_dbg_cint_xu(t))) and debug_event_en_q(t);
                                                    

   ex3_n_ivc_dbg_match(t)          <= not ex5_in_ucode_q(t) and (
                                      (ex3_xuuc_val(t)   and   ex3_xu_instr_match_q     and not ex3_xu_is_ucode_q) or
                                      (ex3_axu_val(t)    and   ex3_axu_instr_match_q(t) and not ex3_axu_is_ucode_q(t)));

   ex3_n_ivc_dbg_cint(t)            <= spr_dbcr3_ivc(t) and ex3_n_ivc_dbg_match(t) and debug_event_en_q(t);
                                      
   ex3_n_instr_dbg_cint(t)          <= ex4_debug_flush_en_d(t) and (ex3_n_ivc_dbg_cint(t) or ex3_n_iac_dbg_cint(t));

   -------------------------------------------------------------------------------
   -- Debug Interrupts [asynchronous]
   -------------------------------------------------------------------------------
   -- Enable
   ex3_np1_dbg_cint_en(t)           <= not ex3_async_int_block(t);
   ex3_np1_ide_dbg_cint(t)          <= ex3_np1_dbg_cint_en(t) and debug_event_en_q(t) and
                                                            spr_cpl_dbsr_ide(t) and dbcr0_idm_q(t) and msr_de_q(t);
   ex3_np1_ude_dbg_cint(t)          <= ex3_np1_dbg_cint_en(t) and 
                                                            force_ude_q(t) and debug_event_en_q(t);

   ex3_np1_ude_dbg_event(t)         <=                      force_ude_q(t) and debug_event_en_q(t);


   -------------------------------------------------------------------------------
   -- Doorbell Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_dbell_int(t)             <= spr_cpl_dbell_interrupt(t)    and not ex3_async_int_block(t);
   
   -------------------------------------------------------------------------------
   -- Critical Doorbell Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_cdbell_cint(t)           <= spr_cpl_cdbell_interrupt(t)   and not ex3_async_int_block(t);

   -------------------------------------------------------------------------------
   -- Guest Doorbell Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_gdbell_int(t)            <= spr_cpl_gdbell_interrupt(t)   and not ex3_async_int_block(t);
   
   -------------------------------------------------------------------------------
   -- Guest Critical Doorbell Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_gcdbell_cint(t)          <= spr_cpl_gcdbell_interrupt(t)  and not ex3_async_int_block(t);

   -------------------------------------------------------------------------------
   -- Guest Machine Check Doorbell Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_gmcdbell_cint(t)         <= spr_cpl_gmcdbell_interrupt(t) and not ex3_async_int_block(t);


   -------------------------------------------------------------------------------
   -- Hypervisor Privilege Interrupt
   -------------------------------------------------------------------------------
   -- Enable
   msr_guest_priv(t)                <= not msr_pr_q(t) and msr_gs_q(t);
   -- Conditions
   ex3_n_spr_hpriv_int_xuuc(t)      <= msr_guest_priv(t) and spr_cpl_ex3_spr_hypv;
   ex3_n_instr_hpriv_int_xuuc(t)    <= msr_guest_priv(t) and dec_cpl_ex3_instr_hypv;
   ex3_n_ehpriv_hpriv_int(t)        <= ex3_xu_val(t)     and ex3_is_ehpriv_q;
      -- tlbwe when all ways are IPROT=1 or attempted to install invalid entry in LRAT
   ex3_n_mmu_hpriv_int(t)           <= msr_guest_priv(t) and ex3_mmu_hv_priv_q(t);
   -- Summary
   ex4_n_any_hpriv_int_d(t)         <=(ex3_xuuc_val(t) and (ex3_n_spr_hpriv_int_xuuc(t) or  
                                                            ex3_n_instr_hpriv_int_xuuc(t)))
                                                            or
                                                            ex3_n_ehpriv_hpriv_int(t) or
                                                            ex3_n_mmu_hpriv_int(t);
                             
                                                    
   -------------------------------------------------------------------------------
   -- Instruction LRAT Interrupt
   -------------------------------------------------------------------------------
   ex3_n_ilrat_int(t)               <= ex3_lrat_miss_q(t) and     ex3_mmu_esr_pt_q(t) and not ex3_mmu_esr_data_q(t); -- PTE Reload missed in the LRAT
   
   -------------------------------------------------------------------------------
   -- Data LRAT Interrupt
   -------------------------------------------------------------------------------
   -- Conditions
   ex3_n_ptemiss_dlrat_int(t)       <= ex3_lrat_miss_q(t) and     ex3_mmu_esr_pt_q(t) and     ex3_mmu_esr_data_q(t); -- PTE Reload missed in the LRAT
   ex3_n_tlbwemiss_dlrat_int(t)     <= ex3_lrat_miss_q(t) and not ex3_mmu_esr_pt_q(t);                               -- tlbwe      missed in the LRAT
   -- Summary
   ex3_n_dlrat_int(t)               <=                      ex3_n_ptemiss_dlrat_int(t) or  
                                                            ex3_n_tlbwemiss_dlrat_int(t);


   -------------------------------------------------------------------------------
   -- User Decrementer Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_udec_int(t)              <= spr_cpl_udec_interrupt(t) and not ex3_async_int_block(t);

   -------------------------------------------------------------------------------
   -- Performance Monitor Interrupt
   -------------------------------------------------------------------------------
   ex3_np1_perf_int(t)              <= spr_cpl_perf_interrupt(t) and not ex3_async_int_block(t);
   
   --=============================================================================
   --=============================================================================
   --
   -- Flush Conditions
   --
   --=============================================================================
   --=============================================================================

   -------------------------------------------------------------------------------
   -- NP1 Flushes
   -------------------------------------------------------------------------------
   -- Conditions
   ex3_np1_instr_flush(t)           <= ex3_xu_val(t)  and  ex3_np1_instr_flush_q;
                                                            
   ex3_np1_sprg_ce_flush(t)         <= or_reduce(ex3_xu_val) and spr_cpl_ex3_sprg_ce;

   ex3_np1_fu_flush(t)              <=                  not ex3_flush(t) and 
                                                        not fu_xu_ex3_flush2ucode(t) and
                                                            fu_xu_ex3_np1_flush(t);

   ex3_np1_run_ctl_flush(t)         <= or_reduce(ex3_xu_val) and ex3_np1_run_ctl_flush_q(t);
   
   ex3_non_uc_val(t)                <=(ex3_xu_val(t)    and not ex3_xu_is_ucode_q) or
                                      (ex3_axu_val(t)   and not ex3_axu_is_ucode_q(t));

   ex3_np1_step_flush(t)            <= ex4_step_q(t) and ex3_non_uc_val(t);
   
   ex3_np1_init_flush(t)            <= pc_init_reset_q;
   
   ex3_np1_mtxucr0_flush(t)         <= or_reduce(ex3_xu_val) and ex3_is_mtxucr0_q;
   
   -- Summary
   ex3_np1_flush(t)                 <=                      ex3_np1_instr_flush(t) or 
                                                            ex3_np1_mtiar_flush(t) or
                                                            ex3_np1_run_ctl_flush(t) or 
                                                            ex3_np1_step_flush(t) or            
                                                            ex3_np1_init_flush(t) or
                                                            ex3_np1_sprg_ce_flush(t) or
                                                            ex3_np1_mtxucr0_flush(t) or
                                                            slowspr_flush_q(t);

   -------------------------------------------------------------------------------
   -- N Flush [I-ERAT Miss]
   -------------------------------------------------------------------------------
   ex3_n_imiss_flush(t)             <= ex3_xuuc_val(t) and ex3_iu_error_q(7)    and not spr_ccr2_notlb;
   ex4_n_imiss_flush(t)             <= ex4_n_flush_pri(IMISSn);

   -------------------------------------------------------------------------------
   -- N Flush [D-ERAT Miss]
   -------------------------------------------------------------------------------
   ex3_n_dmiss_flush(t)             <= ex3_xuuc_val(t) and derat_xu_ex3_miss(t) and not spr_ccr2_notlb;
   ex4_n_dmiss_flush(t)             <= ex4_n_flush_pri(DMISSn);
   
   -------------------------------------------------------------------------------
   -- N Flush [Dependant]
   -------------------------------------------------------------------------------

   -- tlb structural hazard due to tlb reload
   ex3_n_derat_dep_flush(t)         <= ex3_xuuc_val(t) and  derat_xu_ex3_n_flush_req(t);
   -- dependant op following load miss
   ex3_n_lsu_dep_flush(t)           <= (ex3_xuuc_val(t) or ex3_dep_val(t)) and lsu_xu_ex3_dep_flush;
   -- dependant op following load miss (FU version)
   ex3_n_fu_dep_flush(t)            <=                  not ex3_flush(t) and 
                                                        not fu_xu_ex3_flush2ucode(t) and
                                                            fu_xu_ex3_n_flush(t);

   ex3_n_dep_flush(t)               <=                      ex3_n_lsu_dep_flush(t) or
                                                            ex3_n_derat_dep_flush(t) or 
                                                            ex3_n_fu_dep_flush(t);
  
   -------------------------------------------------------------------------------
   -- N Flush [Load Queue Hit]
   -------------------------------------------------------------------------------
   ex3_n_ldq_hit_flush(t)           <= lsu_xu_ex3_ldq_hit_flush;

   -------------------------------------------------------------------------------
   -- N Flush [Load Queue Full]
   -------------------------------------------------------------------------------
--   ex3_n_ldq_full_flush(t)         <= lsu_xu_ex4_ldq_full_flush;
   ex4_n_ldq_full_flush(t)         <= ex4_xu_val_q(t) and lsu_xu_ex4_ldq_full_flush;
   



   -------------------------------------------------------------------------------
   -- N Flushes
   -------------------------------------------------------------------------------
   -- Conditions
   ex3_n_ram_flush(t)               <= ram_flush_q(t);
   ex3_n_mmuhold_flush(t)           <= ex3_mmu_hold_val(t);
   ex3_n_ici_flush(t)               <= or_reduce(ex3_xu_val) and not ex3_xu_val(t) and ex3_is_ici_q;     -- N Flushes other threads
   ex3_n_dci_flush(t)               <= or_reduce(ex3_xu_val) and not ex3_xu_val(t) and ex3_is_dci_q;     -- N Flushes other threads
   ex3_n_mmu_flush(t)               <= mm_xu_ex3_flush_req(t);
   ex3_n_thrctl_stop_flush(t)       <= (pc_dbg_stop_q(t) and not pc_dbg_stop_2_q(t)) and not (ex5_in_ucode_q(t) or ex4_ucode_val(t));
   ex3_n_multcoll_flush(t)          <= ex3_xu_val(t)   and  dec_cpl_ex3_mult_coll;
   ex3_n_ierat_flush(t)             <= ex3_anyuc_val(t) and ex3_ierat_flush_req_q(t);

   -- Summary
   ex3_n_flush(t)                   <=                      ex3_n_ram_flush(t) or
                                                            ex3_n_mmuhold_flush(t) or
                                                            ex3_n_ici_flush(t) or
                                                            ex3_n_dci_flush(t) or
                                                            ex3_n_mmu_flush(t) or
                                                            ex3_n_ierat_flush(t) or
                                                            ex5_n_ext_dbg_stopc_flush_q or
                                                            ex3_n_thrctl_stop_flush(t) or
                                                            ex3_n_multcoll_flush(t);

   ex4_n_lsu_ddmh_flush_en_d(t)     <= (or_reduce(ex3_xu_val) and dec_cpl_ex3_ddmh_en) or dec_cpl_ex3_back_inv;
   ex4_n_lsu_ddmh_flush(t)          <= ex4_n_lsu_ddmh_flush_en_q(t) and lsu_xu_ex4_n_lsu_ddmh_flush(t);       -- N Flushes all threads
   
   ex3_n_lsu_flush(t)               <= lsu_xu_ex3_n_flush_req;
   ex4_n_lsu_flush(t)               <= ex4_xu_val_q(t) and  ex4_n_lsu_flush_q(t);

   -------------------------------------------------------------------------------
   -- N Flushes [parity errors]
   -------------------------------------------------------------------------------
   ex3_n_demh_mchk_flush(t)         <= ex3_n_dexx_mchk_flush_en(t) and ex3_xu_val(t) and lsu_xu_ex3_derat_multihit_err(t);
   ex3_n_depe_mchk_flush(t)         <= ex3_n_dexx_mchk_flush_en(t) and ex3_xu_val(t) and lsu_xu_ex3_derat_par_err(t);
   ex3_n_lsu_dcpe_flush(t)          <= or_reduce(ex6_xu_val_q) and lsu_xu_ex6_datc_par_err;
   ex3_n_lsu_ddpe_flush(t)          <= or_reduce(ex3_xu_val) and lsu_xu_ex3_ddir_par_err;                      -- N Flushes all threads
   ex3_n_fu_rfpe_flush(t)           <= or_reduce(ex3_n_fu_rfpe_det);                                           -- N Flushes all threads
   ex3_n_xu_rfpe_flush(t)           <= or_reduce(ex3_xuuc_val or ex3_dep_val) and gpr_cpl_ex3_regfile_err_det; -- N Flushes all threads
   ex3_n_sprg_ue_flush(t)           <= ex3_xu_val(t) and spr_cpl_ex3_sprg_ue;

   -- Summary
   ex3_n_pe_flush(t)                <=                      ex3_n_l2_ecc_err_flush_q(t) or
                                                            ex3_n_dcpe_flush_q(t) or
                                                            ex3_n_lsu_dcpe_flush(t) or
                                                            ex3_n_lsu_ddpe_flush(t) or
                                                            ex3_n_fu_rfpe_flush(t) or
                                                            ex3_n_xu_rfpe_flush(t) or
                                                            ex3_n_sprg_ue_flush(t) or
                                                            ex3_n_demh_mchk_flush(t) or
                                                            ex3_n_depe_mchk_flush(t);

   -------------------------------------------------------------------------------
   -- N Flushes [to uCode]
   -------------------------------------------------------------------------------
   -- Conditions
   ex3_n_lsualign_2ucode_flush(t)   <= ex3_xu_val(t)    and lsu_xu_ex3_inval_align_2ucode;
   ex3_n_fu_2ucode_flush(t)         <=                  not ex3_flush(t) and 
                                                            fu_xu_ex3_flush2ucode(t) and
                                                            fu_xu_ex3_n_flush(t); 
   -- Summary
   ex3_n_2ucode_flush(t)            <=                      ex3_n_lsualign_2ucode_flush(t) or
                                                            ex3_n_fu_2ucode_flush(t);

   -------------------------------------------------------------------------------
   -- N Flushes [Barrier Set]
   -------------------------------------------------------------------------------
   -- TID of the collision indicates which thread the original divide is running on
   -- if that gets flushed, do not set the barrier.
   ex3_div_coll_d(t)                <= fxa_cpl_ex2_div_coll(t) and not any_flush(t);
   ex3_div_coll(t)                  <= ex3_div_coll_q(t)       and not any_flush(t);

   ex3_n_barr_flush(t)              <= ex3_xu_val(t)    and or_reduce(ex3_div_coll);


   --=============================================================================
   --=============================================================================
   --
   -- Multi Cycle Flush Generation
   --
   --=============================================================================
   --=============================================================================
   ex5_step_done(t)                 <= ex4_step_q(t) and    (ex5_instr_cpl_q(t) or ex5_is_any_int(t) or ex5_n_ext_dbg_stopc_flush_q or ex5_n_ext_dbg_stopt_flush_q(t));
   ex4_np1_run_ctl_flush(t)         <= or_reduce(ex4_xu_val) and ex4_np1_run_ctl_flush_q(t);
   ex4_attn_flush(t)                <= ex4_xu_val(t) and ex4_is_attn_q;   
   
   ex3_thread_stop(t)               <= ex5_step_done(t) or
                                       ex5_np1_run_ctl_flush_q(t) or
                                       ex4_n_thrctl_stop_flush_q(t) or
                                       ex5_attn_flush_q(t);

   ex5_csi(t)                       <=(ex5_xu_val_q(t) and (ex5_is_mtmsr_q or ex5_is_isync_q)) or
                                       ex5_is_any_int(t) or 
                                       ex5_is_any_rfi_q(t);
                                       
   -- Hold the xu_iu_flush interface, during multi cycle flushes
   ex4_flush_act(t)           <= ex4_n_flush(t) or ex4_np1_flush(t);

   -------------------------------------------------------------------------------
   -- Hold Reqests - per thread
   -------------------------------------------------------------------------------
   hold_state_0(t)         <= mmu_hold_present_q(t)    or 
                              derat_hold_present_q(t)  or 
                              ierat_hold_present_q(t)  or 
                              ex5_np1_irpt_dbg_cint_q(t);

   -- MMU Hold req:
   -- either a local generated local or global tlbivax holds the source thead..
   -- or an incoming from bus global tlbivax that holds all threads
   -- or a load/store that misses in derat   holds source thread until miss is resolved from tlb
   mmu_hold_request_d(t)   <= mm_xu_hold_req(t)                or (mmu_hold_request_q(t)    and     or_reduce(ex3_hold_block));   
   ex3_mmu_hold_val(t)     <=                                      mmu_hold_request_q(t)    and not or_reduce(ex3_hold_block);
   xu_mm_hold_ack(t)       <= ex6_mmu_hold_val_q(t);  -- Stage out a few cycles for safety.

   mmu_hold_present_d(t)      <= ex3_mmu_hold_val(t)              or (mmu_hold_present_q(t)    and not mm_xu_hold_done(t));
   ierat_hold_present_d(t)    <= ex4_n_imiss_flush(t)             or (ierat_hold_present_q(t)  and not mmu_eratmiss_done_q(t));
   derat_hold_present_d(t)    <= ex4_n_dmiss_flush(t)             or (derat_hold_present_q(t)  and not mmu_eratmiss_done_q(t));
   -- Hold present needs to stay on long enough for any MMU sourced interrupts to cccur
   
   -------------------------------------------------------------------------------
   -- Flush/Interrupt Condition Generation
   -------------------------------------------------------------------------------
   -- External Debug Actions
   ext_dbg_stop_n_d(t)     <=((pc_dbg_action_q(3*t to 3*t+2) = "010") or
                              (pc_dbg_action_q(3*t to 3*t+2) = "110"));
   ext_dbg_stop_core_d(t)  <=((pc_dbg_action_q(3*t to 3*t+2) = "011") or
                              (pc_dbg_action_q(3*t to 3*t+2) = "111"));
   ext_dbg_act_err_d(t)    <=  pc_dbg_action_q(3*t to 3*t+2) = "100";
   ext_dbg_act_ext_d(t)    <=((pc_dbg_action_q(3*t to 3*t+2) = "101") or
                              (pc_dbg_action_q(3*t to 3*t+2) = "110") or
                              (pc_dbg_action_q(3*t to 3*t+2) = "111"));

   cpl_spr_dbcr0_edm(t)    <= or_reduce(pc_dbg_action_q(3*t to 3*t+2));

   pc_dbg_stop_d(t)        <= pc_xu_stop(t) and not ex5_in_ucode_q(t);

   ex5_ext_dbg_err_d(t)    <= ext_dbg_act_err_q(t) and ex4_dbsr_update(t);
   ex5_ext_dbg_ext_d(t)    <= ext_dbg_act_ext_q(t) and ex4_dbsr_update(t);

   ex4_step_d(t)           <= pc_xu_step(t);
   
   ex3_ifar                <= ex3_ifar_q(eff_ifar*t to eff_ifar*(t+1)-1);
   ex4_ifar                <= ex4_ifar_q(eff_ifar*t to eff_ifar*(t+1)-1);
 
   ex3_spr_lr              <= spr_lr(regsize*t to regsize*(t+1)-3);
   
   ex3_lr_cmprl(t)         <= '1' when ex3_ifar(32 to 61)         = ex3_spr_lr(32 to 61)      else '0';
   ex3_cia_cmprl(t)        <= '1' when ex3_ifar(32 to 61)         = ex4_cia(32 to 61)         else '0';
   ex4_cia_cmprl(t)        <= '1' when ex4_ifar(32 to 61)         = ex4_cia(32 to 61)         else '0';
   xuq_cpl_cmprh_gen0 : if IFAR'left < 32 generate
   ex3_lr_cmprh(t)         <= '1' when ex3_ifar(IFAR'left to 31)  = ex3_spr_lr(IFAR'left to 31) else '0';
   ex3_cia_cmprh(t)        <= '1' when ex3_ifar(IFAR'left to 31)  = ex4_cia(IFAR'left to 31)    else '0';
   ex4_cia_cmprh(t)        <= '1' when ex4_ifar(IFAR'left to 31)  = ex4_cia(IFAR'left to 31)    else '0';
   end generate;
   xuq_cpl_cmprh_gen1 : if IFAR'left >= 32 generate
   ex3_lr_cmprh(t)         <= '1';
   ex3_cia_cmprh(t)        <= '1';
   ex4_cia_cmprh(t)        <= '1';
   end generate;

   -- Don't care the upperhalf of the compare in 32b mode
   ex3_lr_cmpr(t)          <= ex3_anyuc_val_q(t) and ex3_lr_cmprl(t)   and (ex3_lr_cmprh(t)   or not msr_cm_q(t));
   ex3_cia_cmpr(t)         <= ex3_anyuc_val_q(t) and ex3_cia_cmprl(t)  and (ex3_cia_cmprh(t)  or not msr_cm_q(t));
   ex4_cia_cmpr(t)         <= ex4_anyuc_val_q(t) and ex4_cia_cmprl(t)  and (ex4_cia_cmprh(t)  or not msr_cm_q(t));
              
   -- BLR Checking
   -- Clear the bit on a valid instruction or a flush.  If the XU redirects via flush,
   -- the fetch will be guaranteed correct next time and there is no need for the check.
   ex4_clear_bclr_chk(t)   <= (ex4_anyuc_val_q(t)  and not ram_mode_q(t)) or ex5_late_flush_q(0)(t);
   
   ex4_taken_bclr(t)       <= (ex4_taken_bclr_q    and     ex4_xu_val(t));
   ex5_check_bclr_d(t)     <= (ex5_check_bclr_q(t) and not ex4_clear_bclr_chk(t)) or   -- Clear on next valid instr or flush
                               ex4_taken_bclr(t);                                      -- Set after bclr
                               
   ex5_check_bclr(t)       <= ex5_check_bclr_q(t) and not  ex4_clear_bclr_chk(t);                               

   ex3_bclr_cmpr_b(t)      <= (not ex3_lr_cmpr(t)  and ex4_taken_bclr(t)) or      -- bclr with instr BTB, ex4_cia not updated yet
                              (not ex3_cia_cmpr(t) and ex5_check_bclr(t));      -- use ex4_cia here, LR could have updated due bclrl

   ex3_n_bclr_ta_miscmpr_flush(t)   <= not ram_mode_q(t) and ex3_anyuc_val(t) and ex3_bclr_cmpr_b(t);
   
   -- IFAR Checking
   ex4_check_cia(t)           <=((ex4_xu_val_q(t) or ex4_axu_val_q(t)) and not ex5_in_ucode_q(t)) or  -- Don't check the end of a ucode op...
                                 ex4_ucode_val_q(t);                                                  -- Check uCode issue

   ex5_err_nia_miscmpr_d(t)   <= ex4_instr_cpl(t) and ex4_check_cia(t) and not ex4_cia_cmpr(t) and not (ex4_taken_bclr(t) or ex5_check_bclr_q(t));
      
   -- Page Crossing detection
   ex4_mem_attr_act(t)     <= ex4_ucode_val(t);

   ex4_mem_attr_val(t)     <=(ex4_ucode_val(t)      and (ex4_is_any_store_dac_q or ex4_is_any_load_dac_q)) or 
                             (ex5_mem_attr_val_q(t) and  ex5_in_ucode_q(t));

   ex3_mem_attr_cmpr(t)    <= '1' when lsu_xu_ex3_attr = ex5_mem_attr_q else '0';

   ex3_mem_attr_chk(t)     <= ex5_in_ucode_q(t) and ex5_mem_attr_val_q(t) and                         -- uCode attributes valid
                              (ex3_xu_val(t)   and (ex3_is_any_store_dac_q or                   -- Valid store
                                                    ex3_is_any_load_dac_q));                    -- Valid load

   ex3_n_memattr_miscmpr_flush(t)   <= ex3_mem_attr_chk(t) and not ex3_mem_attr_cmpr(t);
   
   ex5_mem_attr_le_d(t)    <= ex4_mem_attr_q(8) xor ex4_byte_rev_q;

   -- uCode
   ex4_ucode_end(t)        <=     ex5_in_ucode_q(t) and ((ex4_xu_val_q(t)  and not ex4_xu_is_ucode_q) or
                                                         (ex4_axu_val_q(t) and not ex4_axu_is_ucode_q(t)) or
                                                          ex5_is_any_int(t));

   ex5_in_ucode_d(t)          <= ex4_ucode_val(t) or (ex5_in_ucode_q(t) and not (((ex4_np1_flush(t) or ex4_n_flush(t)) and ex4_ucode_restart(t)) or ex5_is_any_int(t)));
   
   -- Interrupt blocking
   ssprwr_ip_d(t)          <=(ex4_xu_val(t) and ex4_is_slowspr_wr_q) or
                             (ssprwr_ip_q(t) and not mux_cpl_slowspr_done(t));
   
   exx_instr_async_block_d(t)(1)          <= rf1_xu_val(t) and (rf1_is_wait or rf1_is_eratre or rf1_is_tlbwe or rf1_is_tlbre or rf1_is_tlbsx or rf1_is_tlbsrx);
   exx_instr_async_block_d(t)(2 to 7)     <= exx_instr_async_block_q(t)(1 to 6);
      
   
   -- In RAM Mode
   -- In uCode
   -- XU uCode Start
   --AXU uCode Start
   -- Wait instruction in pipe
   -- If MSR is updated here a potential interrupt will not get
   --    the updated value... blocking is easiest for timing.
   ex3_async_int_block_cond(t)   <= (ex2_xu_val_q(t) and (ex2_msr_updater or ex2_mtiar or ex2_is_slowspr_wr_q)) or
                                    or_reduce(exx_instr_async_block_q(t)) or 
                                    ex4_n_flush_cond(IMISSn) or ex4_n_flush_cond(DMISSn);  
                                    -- MMU Hold present not needed, exx_hold0_mcflush will be on in time

   ex3_base_int_block_cond(t)    <= ex4_is_mchk_int(t) or ex4_is_crit_int(t) or ex4_is_base_int(t);
   ex3_mchk_int_block_cond(t)    <= ex4_is_mchk_int(t);
   
   ex3_hold_block(t)       <= ssprwr_ip_q(t) or
                              ex5_in_ucode_q(t);

   ex3_async_int_block_noaxu(t)  <= 
                              ssprwr_ip_q(t) or
                              ram_mode_q(t) or
                              ex5_in_ucode_q(t) or
                              ex3_async_int_block_q(t) or
                              exx_hold0_mcflush(t) or
                              exx_hold1_mcflush(t) or                              
                              ex4_async_block(t) or                              
                              ex4_base_int_block_q(t) or
                              spare_4_q(4+t);
                              
                                                                  
   -- Don't block FPenabled ints due to ICMP.  FPenabled has higher priority.
   ex3_async_int_block(t)  <= ex3_async_int_block_noaxu(t) or ex3_axu_async_block_q(t) or ex4_icmp_async_block(t);
                              
   -- Timing Note:  base_int_block is causing timing problems.  Replacing it with a latched version + ex4_async_block
   --    to cover the first cycle after.  Can also remove IMISS/DMISS, as they are also included.
                              

   ex3_debug_int_en(t)     <= msr_de_q(t) and dbcr0_idm_q(t) and not (ex4_is_crit_int(t) or ex4_is_mchk_int(t) or ext_dbg_stop_n_q(t) or ext_dbg_stop_core_q(t));
   
   ex4_debug_flush_en_d(t) <= ex3_debug_int_en(t) or ext_dbg_stop_n_q(t) or ext_dbg_stop_core_q(t);

   -- This signal will clock gate ESR[FP,AP,SPV,ST,EPID]
   -- so they are saved during uCode, flush-to-uCode, and HW table walk
   -- Update for non-ucode instructions or on uCode pre-issue.
   -- Need to also catch the last cycle of ucode.
   -- Use in_ucode for this, we flush after so there's cycles to account for this to clear.
   ex3_esr_bit_act(t)   <= not (ex3_flush(t) and not ex4_n_flush_pri(F2Un)) and 
                              (ex3_ucode_val_q(t) or                        
                              (ex3_xu_val_q(t)  and not (ex5_in_ucode_q(t) or ex3_xu_is_ucode_q    )) or
                              (ex3_axu_val_q(t) and not (ex5_in_ucode_q(t) or ex3_axu_is_ucode_q(t))));

   -------------------------------------------------------------------------------
   -- IFAR Mux
   -------------------------------------------------------------------------------
   ex5_sel_rt_d(t)      <= ex4_np1_mtiar_flush(t) or ex4_is_any_rfi(t);

   with s3'(ex5_is_any_hint(t) & ex5_is_any_gint(t) & ex5_sel_rt_q(t)) select
      ex5_flush_ifar          <= spr_ivpr(62-eff_ifar to 51)  & ex5_ivo & "00"   when "100",
                                 spr_givpr(62-eff_ifar to 51)  & ex5_ivo & "00"  when "010",
                                 ex5_rt_q(62-eff_ifar to 61)                     when others;


   flush_ifar_repwr : for r in 1 to ifar_repwr-1 generate
      with (ex5_late_flush_q(r)(t)) select
         flush_ifar(64-8*(r+1) to 63-8*r)    <= not ex4_cia_b_q(64-8*(r+1) to 63-8*r)        when '1',
                                                ex2_br_flush_ifar(64-8*(r+1) to 63-8*r)      when others;
   end generate;
      with (ex5_late_flush_q(0)(t)) select
         flush_ifar(56 to 61)                <= not ex4_cia_b_q(56 to 61)                    when '1',
                                                ex2_br_flush_ifar(56 to 61)                  when others;

   -------------------------------------------------------------------------------
   -- Next instruction address
   -------------------------------------------------------------------------------
   ex4_instr_cpl_d(t)   <=((ex3_xu_val(t)    and not ex3_xu_is_ucode_q) or
                           (ex3_axu_val(t)   and not ex3_axu_is_ucode_q(t)));

   ex4_instr_cpl(t)     <= not ram_mode_q(t) and ex4_instr_cpl_q(t) and not ex4_flush(t);
   ex4_ram_cpl(t)       <=                       ex4_instr_cpl_q(t) and not ex4_flush(t);

   ex5_flush_update(t)  <= ex5_is_any_int(t) or ex5_is_any_rfi_q(t) or ex5_sel_rt_q(t);

   -- Update NIA on a taken branch
   with (ex4_xu_val_q(t) and ex4_br_update_q) select
      ex4_nia_instr     <= ex4_br_flush_ifar_q                    when '1',      -- Branch IFAR
                           ex4_cia_p1                             when others;   -- Current IFAR + 1

   -- Update CIA due to flushes
   with ex5_flush_update(t) select
      ex4_cia_flush     <= ex5_flush_ifar                         when '1',
                           ex4_cia                                when others;

   -- Update NIA when a new instr completes
   with (ex4_instr_cpl(t)) select
      ex4_nia_cpl       <= (ex4_nia_instr and ex4_cm_mask)         when '1',      -- Next Instr
                           (ex4_cia_flush and ex4_cm_mask)         when others;   -- Current/No Instr (or Flushed IAR)
                           
   ex4_nia              <= ex4_nia_cpl;
   ex4_cia              <= not ex4_cia_b_q;
   ex4_cia_b_d          <= not ex4_nia;
                                                           
   ex4_cia_p1           <= std_ulogic_vector(unsigned(ex4_cia) + 1);
        
   -- Preserve the upper 32bits of the ifar until msr_cm_q is stable.
   ex5_cm_hold_cond(t)  <= (ex5_xu_val_q(t) and ex5_is_mtmsr_q) or ex5_is_any_int(t) or ex5_is_any_rfi_q(t);

   ex4_cm(t)            <= msr_cm_q(t) or exx_cm_hold(t);

   ex4_cm_mask(32 to 61)      <= (others=>'1');
   xuq_cpl_cm_mask_gen : if IFAR'left < 32 generate
      ex4_cm_mask(IFAR'left to 31)        <= (others=>ex4_cm(t));
   end generate;
   
   ex3_cia_act(t)       <= ex4_instr_cpl_q(t) or ex5_flush_update(t) or exx_cm_hold(t) or exx_cm_hold_q(t) or spr_xucr0_clkg_ctl(2);
   
   ex4_nia_act(t)       <= ex4_cia_act_q(t) or ex3_cia_act(t) or ex4_n_flush(t) or ex4_np1_flush(t);
   
   -------------------------------------------------------------------------------
   -- uCode "Next instruction address"
   -------------------------------------------------------------------------------
   ex5_uc_cia_val_d(t)  <= ex5_in_ucode_q(t) and  ex4_uc_cia_val(t);
   ex4_uc_cia_val(t)    <= ex5_in_ucode_q(t) and (ex5_uc_cia_val_q(t) or ex4_any_val(t));
   
   ex3_uc_cia_act(t)    <= clkg_ctl_q or (ex5_in_ucode_q(t) and (ex4_xu_val_q(t) or ex4_axu_val_q(t)));

   -- Capture NIA when a new instr completes
   -- The IU needs the IFAR of the op being flushed (if there is one there)
   with (ex4_xu_val_q(t) or ex4_axu_val_q(t)) select
      ex4_uc_nia        <= ex4_ifar(IFAR_UC'range)                      when '1',
                           ex4_uc_cia_q                                 when others;
                           
   -- Don't capture ops that were flushed into the capture latch (See note above)
   with ex4_n_flush(t) select
      ex4_uc_cia_d      <= ex4_uc_cia_q                                 when '1',
                           ex4_uc_nia                                   when others;

   xu_iu_uc_flush_ifar(uc_ifar*t to uc_ifar*(t+1)-1)  <= ex4_uc_cia_q;

   -------------------------------------------------------------------------------
   -- Exception Priority
   -------------------------------------------------------------------------------
   ex4_dbsr_cond(0)                <= ex4_n_ivc_dbg_cint_q(t) or 
                                      ex4_n_iac_dbg_cint_q(t);

   ex4_dbsr_cond(1)                <= ex4_n_dac_dbg_cint_q(t) or 
                                      ex4_n_ret_dbg_cint_q(t) or 
                                      ex4_n_brt_dbg_cint_q(t) or
                                      ex4_n_trap_dbg_cint_q(t);

   -- Only allow the DBSR to be set, if:
   --    the interrupt occured
   --    the instruction completed
   ex4_dbsr_en_cond(0)                   <= ex4_anyuc_val(t) or   ex4_n_flush_pri(DBG0n);  
   ex4_dbsr_en_cond(1)                   <= ex4_anyuc_val(t) or   ex4_n_flush_pri(DBG1n);  

   ex4_n_flush_cond(PREVn)          <= exx_np1_irpt_dbg_cint(t) or exx_np1_icmp_dbg_cint(t) or (ex4_debug_flush_en_q(t) and ex4_n_async_dacr_dbg_cint_q(t));
   ex4_n_flush_cond(BTAn)           <= ex4_n_bclr_ta_miscmpr_flush_q(t);
   ex4_n_flush_cond(DEPn)           <= ex4_n_dep_flush_q(t) or ex4_n_tlb_mchk_flush_q(t);
   ex4_n_flush_cond(IMISSn)         <= ex4_n_imiss_flush_q(t);
   ex4_n_flush_cond(IMCHKn)         <= ex4_n_imchk_mcint_q(t) or ex4_n_ieratsx_par_mchk_mcint_q(t);
   ex4_n_flush_cond(DBG0n)          <= ex4_n_instr_dbg_cint_q(t);
   ex4_n_flush_cond(ITLBn)          <= ex4_n_itlb_int_q(t);
   ex4_n_flush_cond(ISTORn)         <= ex4_n_istor_int_q(t);
   ex4_n_flush_cond(ILRATn)         <= ex4_n_ilrat_int_q(t);
   ex4_n_flush_cond(FPEn)           <= ex4_n_pe_flush_q(t) or ex4_n_lsu_ddmh_flush(t);
   ex4_n_flush_cond(PROG0n)         <= ex4_n_pil_prog_int_q(t);
   ex4_n_flush_cond(UNAVAILn)       <= ex4_n_any_unavail_int_q(t);
   ex4_n_flush_cond(PROG1n)         <= ex4_n_ppr_prog_int_q(t);
   ex4_n_flush_cond(PROG2n)         <= ex4_n_puo_prog_int_q(t);
   ex4_n_flush_cond(PROG3n)         <= ex4_n_ena_prog_int_q(t);
   ex4_n_flush_cond(HPRIVn)         <= ex4_n_any_hpriv_int_q(t);
   ex4_n_flush_cond(PROG0An)        <= ex4_n_tlbwe_pil_prog_int_q(t);
   ex4_n_flush_cond(DMCHKn)         <= ex4_n_dmchk_mcint_q(t) or ex4_n_ddmh_mchk_mcint(t);
   ex4_n_flush_cond(DTLBn)          <= ex4_n_dtlb_int_q(t);
   ex4_n_flush_cond(DMISSn)         <= ex4_n_dmiss_flush_q(t);
   ex4_n_flush_cond(DSTORn)         <= ex4_n_dstor_int_q(t);
   ex4_n_flush_cond(ALIGNn)         <= ex4_n_align_int_q(t) or ex4_n_memattr_miscmpr_flush_q(t);
   ex4_n_flush_cond(DLRATn)         <= ex4_n_dlrat_int_q(t);
   ex4_n_flush_cond(DBG1n)          <= ex4_debug_flush_en_q(t) and ex4_dbsr_cond(1);
   ex4_n_flush_cond(F2Un)           <= ex4_n_2ucode_flush_q(t);
   ex4_n_flush_cond(FwBSn)          <= ex4_n_barr_flush_q(t) or (ex4_xu_val_q(t) and ex4_n_ldq_hit_flush_q(t));
   ex4_n_flush_cond(Fn)             <= ex4_n_flush_q(t) or ex4_n_ldq_full_flush(t) or ex4_n_lsu_flush(t) or ex4_thread_stop_q(t);

   ex4_np1_flush_cond(INSTRnp1)     <= ex4_np1_instr_int_q(t);
   ex4_np1_flush_cond(MCHKnp1)      <= ex4_np1_ext_mchk_mcint_q(t);
   ex4_np1_flush_cond(GDBMCHKnp1)   <= ex4_np1_gmcdbell_cint_q(t);
   ex4_np1_flush_cond(DBG3np1)      <= ex4_debug_flush_en_q(t) and (ex4_np1_ide_dbg_cint_q(t) or ex4_np1_ude_dbg_cint_q(t));
   ex4_np1_flush_cond(CRITnp1)      <= ex4_np1_crit_cint_q(t);
   ex4_np1_flush_cond(WDOGnp1)      <= ex4_np1_wdog_cint_q(t);
   ex4_np1_flush_cond(CDBELLnp1)    <= ex4_np1_cdbell_cint_q(t);
   ex4_np1_flush_cond(GCDBELLnp1)   <= ex4_np1_gcdbell_cint_q(t);  
   ex4_np1_flush_cond(EXTnp1)       <= ex4_np1_ext_int_q(t);
   ex4_np1_flush_cond(FITnp1)       <= ex4_np1_fit_int_q(t);
   ex4_np1_flush_cond(DECnp1)       <= ex4_np1_dec_int_q(t);
   ex4_np1_flush_cond(DBELLnp1)     <= ex4_np1_dbell_int_q(t);
   ex4_np1_flush_cond(GDBELLnp1)    <= ex4_np1_gdbell_int_q(t);  
   ex4_np1_flush_cond(UDECnp1)      <= ex4_np1_udec_int_q(t);
   ex4_np1_flush_cond(PERFnp1)      <= ex4_np1_perf_int_q(t);
   ex4_np1_flush_cond(Fnp1)         <= ex4_np1_flush_q(t) or ex4_ucode_end(t) or ex4_np1_fu_flush_q(t);

   xu_cpl_n_pri : entity work.xuq_cpl_pri(xuq_cpl_pri)
   generic map (size => ex4_n_flush_cond'length)
   port map(
      cond                             => ex4_n_flush_cond,
      pri                              => ex4_n_flush_pri,
      or_cond                          => ex4_n_flush(t));
   
   xu_cpl_np1_pri : entity work.xuq_cpl_pri(xuq_cpl_pri)
   generic map (size => ex4_np1_flush_cond'length)
   port map(
      cond                             => ex4_np1_flush_cond,
      pri                              => ex4_np1_flush_pri_nongated,
      or_cond                          => ex4_np1_flush(t));
   
   ex4_np1_flush_pri    <= gate(ex4_np1_flush_pri_nongated,(not ex4_n_flush(t)));
   
   ex4_flush_pri        <= ex4_n_flush_pri & ex4_np1_flush_pri;
   
   ex4_async_block(t)         <= ex4_n_flush(t) or ex4_np1_flush(t);
      
   xu_lsu_ex4_val(t)          <= ex4_xu_val_q(t);

   xu_lsu_ex4_flush_local(t)  <= or_reduce(ex4_n_flush_cond(PREVn to ISTORn)) or 
                                           ex4_n_flush_cond(PROG0n) or
                                           ex4_n_flush_cond(PROG1n) or
                                           ex4_n_flush_cond(UNAVAILn) or
                                           ex4_n_flush_cond(PROG3n) or
                                 ex4_n_dmchk_mcint_q(t) or                                   -- DMCHKn
                                 or_reduce(ex4_n_flush_cond(DTLBn to ALIGNn)) or
                                 (ex4_debug_flush_en_q(t) and ex4_n_dac_dbg_cint_q(t)) or    -- DBG1n
                                           ex4_n_flush_cond(F2Un) or 
                                 ex4_n_flush_cond(FPEn) or                                   -- FPEn
                                 (ex4_xu_val_q(t) and ex4_n_ldq_hit_flush_q(t)) or           -- Fn
                                 ex4_n_flush_q(t) or ex4_n_lsu_flush(t) or                   -- Fn
                                 ex4_thread_stop_q(t) or                                     -- Fn
                                 ex4_flush_q(t);
   
   ex5_flush_pri_enc_dbg(t)   <= gate("000001",ex5_flush_pri_dbg_q(0)) or   
                                 gate("000010",ex5_flush_pri_dbg_q(1)) or   
                                 gate("000011",ex5_flush_pri_dbg_q(2)) or   
                                 gate("000100",ex5_flush_pri_dbg_q(3)) or   
                                 gate("000101",ex5_flush_pri_dbg_q(4)) or   
                                 gate("000110",ex5_flush_pri_dbg_q(5)) or   
                                 gate("000111",ex5_flush_pri_dbg_q(6)) or   
                                 gate("001000",ex5_flush_pri_dbg_q(7)) or   
                                 gate("001001",ex5_flush_pri_dbg_q(8)) or   
                                 gate("001010",ex5_flush_pri_dbg_q(9)) or   
                                 gate("001011",ex5_flush_pri_dbg_q(10)) or   
                                 gate("001100",ex5_flush_pri_dbg_q(11)) or   
                                 gate("001101",ex5_flush_pri_dbg_q(12)) or   
                                 gate("001110",ex5_flush_pri_dbg_q(13)) or   
                                 gate("001111",ex5_flush_pri_dbg_q(14)) or   
                                 gate("010000",ex5_flush_pri_dbg_q(15)) or   
                                 gate("010001",ex5_flush_pri_dbg_q(16)) or   
                                 gate("010010",ex5_flush_pri_dbg_q(17)) or   
                                 gate("010011",ex5_flush_pri_dbg_q(18)) or   
                                 gate("010100",ex5_flush_pri_dbg_q(19)) or   
                                 gate("010101",ex5_flush_pri_dbg_q(20)) or   
                                 gate("010110",ex5_flush_pri_dbg_q(21)) or   
                                 gate("010111",ex5_flush_pri_dbg_q(22)) or   
                                 gate("011000",ex5_flush_pri_dbg_q(23)) or   
                                 gate("011001",ex5_flush_pri_dbg_q(24)) or   
                                 gate("011010",ex5_flush_pri_dbg_q(25)) or   
                                 gate("011011",ex5_flush_pri_dbg_q(26)) or   
                                 gate("011100",ex5_flush_pri_dbg_q(27)) or   
                                 gate("011101",ex5_flush_pri_dbg_q(28)) or   
                                 gate("011110",ex5_flush_pri_dbg_q(29)) or   
                                 gate("011111",ex5_flush_pri_dbg_q(30)) or   
                                 gate("100000",ex5_flush_pri_dbg_q(31)) or   
                                 gate("100001",ex5_flush_pri_dbg_q(32)) or   
                                 gate("100010",ex5_flush_pri_dbg_q(33)) or   
                                 gate("100011",ex5_flush_pri_dbg_q(34)) or   
                                 gate("100100",ex5_flush_pri_dbg_q(35)) or   
                                 gate("100101",ex5_flush_pri_dbg_q(36)) or   
                                 gate("100110",ex5_flush_pri_dbg_q(37)) or   
                                 gate("100111",ex5_flush_pri_dbg_q(38)) or   
                                 gate("101000",ex5_flush_pri_dbg_q(39)) or
                                 gate("101001",ex5_flush_pri_dbg_q(40)) or
                                 gate("101010",ex5_flush_pri_dbg_q(41)) or
                                 gate("101011",ex5_flush_pri_dbg_q(42));


   ex4_n_flush_pri_dacr_async(t)    <= ex4_n_flush_cond(PREVn)       and ex4_n_async_dacr_dbg_cint_q(t);

   ex4_np1_flush_pri_instr(TRAP)    <= not ex4_n_flush(t) and ex4_np1_ptr_prog_int_q(t);
   ex4_np1_flush_pri_instr(SC)      <= not ex4_n_flush(t) and ex4_np1_sc_int_q(t);
   ex4_np1_flush_pri_instr(RFI)     <= not ex4_n_flush(t) and ex4_np1_rfi_q(t);
   
   ex4_n_flush_pri_unavail(FP)      <= ex4_n_flush_pri(UNAVAILn)     and ex4_n_fp_unavail_int_q(t);
   ex4_n_flush_pri_unavail(AP)      <= ex4_n_flush_pri(UNAVAILn)     and ex4_n_ap_unavail_int_q(t);
   ex4_n_flush_pri_unavail(VEC)     <= ex4_n_flush_pri(UNAVAILn)     and ex4_n_vec_unavail_int_q(t);
   
   ex4_n_flush_pri_ena(APENA)       <= ex4_n_flush_pri(PROG3n)       and ex4_apena_prog_int_q(t);
   ex4_n_flush_pri_ena(FPENA)       <= ex4_n_flush_pri(PROG3n)       and ex4_fpena_prog_int_q(t);

   ex4_n_flush_pri_ehpriv(t)        <= ex4_n_flush_pri(HPRIVn)       and ex4_is_ehpriv_q;
   
   ex4_n_flush_sprg_ue_flush(t)     <= ex4_n_flush_pri(FPEn)         and ex4_n_sprg_ue_flush_q(t);

   -- Delay ICMP until just before the next instruction.  This strategy should account for barrier ops
   
   ex4_icmp_event_on_int_ok(t)      <= ex4_n_flush_pri_ehpriv(t) or ex4_np1_flush_pri_instr(SC) or ex4_np1_flush_pri_instr(TRAP);
   
   -- ehpriv/sc/trap causes a flushes, but still needs to set the DBSR.
   -- ICMP can only occur or record when DE=1
   ex4_np1_icmp_dbg_en(t)           <= spr_dbcr0_icmp(t) and msr_de_q(t) and debug_event_en_q(t);   
   ex4_np1_icmp_dbg_event(t)        <= ex4_np1_icmp_dbg_en(t) and (ex4_instr_cpl(t) or ex4_icmp_event_on_int_ok(t));
   ex4_np1_icmp_dbg_cint(t)         <= ex4_np1_icmp_dbg_en(t) and  ex4_instr_cpl(t) and ex4_debug_flush_en_q(t);
   
   ex4_icmp_async_block(t)          <=(ex4_np1_icmp_dbg_en(t) and (ex3_anyuc_val_q(t) or ex4_instr_cpl_q(t))) or ex5_np1_icmp_dbg_cint_q(t);
   
   ex5_np1_icmp_dbg_event_d(t)      <=(ex4_np1_icmp_dbg_event(t)   and not                        ((ex5_is_any_int(t) and not ex5_icmp_event_on_int_ok_q(t)) or ex4_thread_stop_q(t))) or
                                      (ex5_np1_icmp_dbg_event_q(t) and not (ex4_anyuc_val_q(t) or  (ex5_is_any_int(t)                                        or ex4_thread_stop_q(t))));

   ex5_np1_icmp_dbg_cint_d(t)       <=(ex4_np1_icmp_dbg_cint(t)    and not                         (ex5_is_any_int(t) or ex4_thread_stop_q(t))) or
                                      (ex5_np1_icmp_dbg_cint_q(t)  and not (ex4_anyuc_val_q(t) or   ex5_is_any_int(t) or ex4_thread_stop_q(t)));
   
   -- Actually take the ICMP just before the next instruction.
   exx_np1_icmp_dbg_cint(t)         <= ex5_np1_icmp_dbg_cint_q(t)  and (ex4_anyuc_val_q(t) or ex4_thread_stop_q(t));
   exx_np1_icmp_dbg_event(t)        <= ex5_np1_icmp_dbg_event_q(t) and (ex4_anyuc_val_q(t) or ex4_thread_stop_q(t) or (ex5_is_any_int(t) and ex5_icmp_event_on_int_ok_q(t)));
   
   ex4_n_flush_pri_icmp(t)          <= ex4_n_flush_pri(PREVn) and exx_np1_icmp_dbg_cint(t);
   
   
   -- Do the same business with IRPT...
   ex4_np1_irpt_dbg_cint(t)         <= ex4_is_base_int(t) and debug_event_en_q(t) and spr_dbcr0_irpt(t) and ex4_debug_flush_en_q(t);
   ex4_np1_irpt_dbg_event(t)        <= ex4_is_base_int(t) and debug_event_en_q(t) and spr_dbcr0_irpt(t);
   
   ex6_np1_irpt_dbg_cint_d(t)       <= ex5_np1_irpt_dbg_cint_q(t)  or 
                                      (ex6_np1_irpt_dbg_cint_q(t)  and     ex4_base_int_block_q(t));
   exx_np1_irpt_dbg_cint(t)         <= ex6_np1_irpt_dbg_cint_q(t)  and not ex4_base_int_block_q(t);   

   ex6_np1_irpt_dbg_event_d(t)      <= ex5_np1_irpt_dbg_event_q(t) or 
                                      (ex6_np1_irpt_dbg_event_q(t) and     ex4_base_int_block_q(t));
   exx_np1_irpt_dbg_event(t)        <= ex6_np1_irpt_dbg_event_q(t) and not ex4_base_int_block_q(t);   

   ex4_n_flush_pri_irpt(t)          <= ex4_n_flush_pri(PREVn) and exx_np1_irpt_dbg_cint(t);
   
      
   ex4_ivo_sel(0)       <= ex4_np1_flush_pri(CRITnp1);
   ex4_ivo_sel(1)       <= ex4_mchk_int_en_q(t) and (ex4_n_flush_pri(IMCHKn) or ex4_n_flush_pri(DMCHKn) or ex4_np1_flush_pri(MCHKnp1));
   ex4_ivo_sel(2)       <= ex4_n_flush_pri(DSTORn);
   ex4_ivo_sel(3)       <= ex4_n_flush_pri(ISTORn);
   ex4_ivo_sel(4)       <= ex4_np1_flush_pri(EXTnp1);
   ex4_ivo_sel(5)       <= ex4_n_flush_pri(ALIGNn);
   ex4_ivo_sel(6)       <= ex4_n_flush_pri(PROG0n) or ex4_n_flush_pri(PROG0An) or ex4_n_flush_pri(PROG1n) or ex4_n_flush_pri(PROG2n) or ex4_n_flush_pri(PROG3n) or ex4_np1_flush_pri_instr(TRAP);
   ex4_ivo_sel(7)       <= ex4_n_flush_pri_unavail(FP);
   ex4_ivo_sel(8)       <= ex4_np1_flush_pri_instr(SC) and not ex4_sc_lev_q;
   ex4_ivo_sel(9)       <= ex4_n_flush_pri_unavail(AP);
   ex4_ivo_sel(10)      <= ex4_np1_flush_pri(DECnp1);
   ex4_ivo_sel(11)      <= ex4_np1_flush_pri(FITnp1);
   ex4_ivo_sel(12)      <= ex4_np1_flush_pri(WDOGnp1);
   ex4_ivo_sel(13)      <= ex4_n_flush_pri(DTLBn);
   ex4_ivo_sel(14)      <= ex4_n_flush_pri(ITLBn);
   ex4_ivo_sel(15)      <= (ex4_debug_int_en_q(t) and (ex4_n_flush_pri(DBG0n) or ex4_n_flush_pri(DBG1n) or ex4_np1_flush_pri(DBG3np1) or ex4_n_flush_pri_dacr_async(t) or ex4_n_flush_pri_icmp(t) or ex4_n_flush_pri_irpt(t)));
   ex4_ivo_sel(16)      <= ex4_n_flush_pri_unavail(VEC);
   ex4_ivo_sel(17)      <= ex4_np1_flush_pri(DBELLnp1);
   ex4_ivo_sel(18)      <= ex4_np1_flush_pri(CDBELLnp1);
   ex4_ivo_sel(19)      <= ex4_np1_flush_pri(GDBELLnp1);
   ex4_ivo_sel(20)      <= ex4_np1_flush_pri(GCDBELLnp1) or ex4_np1_flush_pri(GDBMCHKnp1);
   ex4_ivo_sel(21)      <= ex4_np1_flush_pri_instr(SC) and     ex4_sc_lev_q;
   ex4_ivo_sel(22)      <= ex4_n_flush_pri(HPRIVn);
   ex4_ivo_sel(23)      <= ex4_n_flush_pri(ILRATn) or ex4_n_flush_pri(DLRATn);
   ex4_ivo_sel(24)      <= ex4_np1_flush_pri(UDECnp1);
   ex4_ivo_sel(25)      <= ex4_np1_flush_pri(PERFnp1);
   

   ex5_dsigs_d(t)       <= msr_gs_q(t) and spr_epcr_dsigs(t) and not ex4_esr_pri(VF);
   ex5_isigs_d(t)       <= msr_gs_q(t) and spr_epcr_isigs(t);
   ex5_extgs_d(t)       <= msr_gs_q(t) and spr_epcr_extgs(t);
   ex5_dtlbgs_d(t)      <= msr_gs_q(t) and spr_epcr_dtlbgs(t);
   ex5_itlbgs_d(t)      <= msr_gs_q(t) and spr_epcr_itlbgs(t);

   ex5_ivo_mask_guest(0)   <= '0';
   ex5_ivo_mask_guest(1)   <= '0';
   ex5_ivo_mask_guest(2)   <= ex5_dsigs_q(t) and not ex5_tlb_inelig_q(t);
   ex5_ivo_mask_guest(3)   <= ex5_isigs_q(t) and not ex5_tlb_inelig_q(t);
   ex5_ivo_mask_guest(4)   <= ex5_extgs_q(t);
   ex5_ivo_mask_guest(5)   <= '0';
   ex5_ivo_mask_guest(6)   <= '0';
   ex5_ivo_mask_guest(7)   <= '0';
   ex5_ivo_mask_guest(8)   <= msr_gs_q(t);
   ex5_ivo_mask_guest(9)   <= '0';
   ex5_ivo_mask_guest(10)  <= '0';
   ex5_ivo_mask_guest(11)  <= '0';
   ex5_ivo_mask_guest(12)  <= '0';
   ex5_ivo_mask_guest(13)  <= ex5_dtlbgs_q(t);
   ex5_ivo_mask_guest(14)  <= ex5_itlbgs_q(t);
   ex5_ivo_mask_guest(15)  <= '0';
   ex5_ivo_mask_guest(16)  <= '0';
   ex5_ivo_mask_guest(17)  <= '0';
   ex5_ivo_mask_guest(18)  <= '0';
   ex5_ivo_mask_guest(19)  <= '0';
   ex5_ivo_mask_guest(20)  <= '0';
   ex5_ivo_mask_guest(21)  <= '0';
   ex5_ivo_mask_guest(22)  <= '0';
   ex5_ivo_mask_guest(23)  <= '0';
   ex5_ivo_mask_guest(24)  <= '0';
   ex5_ivo_mask_guest(25)  <= '0';
   
   ex5_ivo_guest_sel    <= ex5_ivo_sel_q and     ex5_ivo_mask_guest;
   ex5_ivo_hypv_sel     <= ex5_ivo_sel_q and not ex5_ivo_mask_guest;

   ex5_is_any_gint(t)   <= or_reduce(ex5_ivo_guest_sel);
   ex5_is_any_hint(t)   <= or_reduce(ex5_ivo_hypv_sel);

   ex5_is_any_int(t)    <= or_reduce(ex5_ivo_sel_q);
   ex4_is_any_rfi(t)    <= ex4_np1_flush_pri_instr(RFI);

   ex5_is_base_hint(t)  <= or_reduce(ex5_ivo_hypv_sel(2 to 11))  or or_reduce(ex5_ivo_hypv_sel(13 to 14))  or or_reduce(ex5_ivo_hypv_sel(16 to 17))  or ex5_ivo_hypv_sel(19)  or or_reduce(ex5_ivo_hypv_sel(21 to 25));
   ex5_is_base_gint(t)  <= or_reduce(ex5_ivo_guest_sel(2 to 11)) or or_reduce(ex5_ivo_guest_sel(13 to 14)) or or_reduce(ex5_ivo_guest_sel(16 to 17)) or ex5_ivo_guest_sel(19) or or_reduce(ex5_ivo_guest_sel(21 to 25));
   ex4_is_base_int(t)   <= or_reduce(ex4_ivo_sel(2 to 11))       or or_reduce(ex4_ivo_sel(13 to 14))       or or_reduce(ex4_ivo_sel(16 to 17))       or ex4_ivo_sel(19)       or or_reduce(ex4_ivo_sel(21 to 25));

   ex4_is_crit_int(t)   <= ex4_ivo_sel(0) or ex4_ivo_sel(12) or ex4_ivo_sel(15) or ex4_ivo_sel(18) or ex4_ivo_sel(20);
   ex4_is_mchk_int(t)   <= ex4_ivo_sel(1);

   ex5_ivo           <= gate(x"02",ex5_ivo_sel_q( 0)) or   -- IVOR0    Critical Input
                        gate(x"00",ex5_ivo_sel_q( 1)) or   -- IVOR1    Machine Check
                        gate(x"06",ex5_ivo_sel_q( 2)) or   -- IVOR2    Data Storage
                        gate(x"08",ex5_ivo_sel_q( 3)) or   -- IVOR3    Instr Storage
                        gate(x"0A",ex5_ivo_sel_q( 4)) or   -- IVOR4    External Input
                        gate(x"0C",ex5_ivo_sel_q( 5)) or   -- IVOR5    Alignment
                        gate(x"0E",ex5_ivo_sel_q( 6)) or   -- IVOR6    Program
                        gate(x"10",ex5_ivo_sel_q( 7)) or   -- IVOR7    FP Unavailable
                        gate(x"12",ex5_ivo_sel_q( 8)) or   -- IVOR8    System Call
                        gate(x"14",ex5_ivo_sel_q( 9)) or   -- IVOR9    AP Unavailable
                        gate(x"16",ex5_ivo_sel_q(10)) or   -- IVOR10   Decrementer
                        gate(x"18",ex5_ivo_sel_q(11)) or   -- IVOR11   Fixed Interval Timer
                        gate(x"1A",ex5_ivo_sel_q(12)) or   -- IVOR12   Watchdog
                        gate(x"1C",ex5_ivo_sel_q(13)) or   -- IVOR13   Data TLB Error
                        gate(x"1E",ex5_ivo_sel_q(14)) or   -- IVOR14   Instr TLB Error
                        gate(x"04",ex5_ivo_sel_q(15)) or   -- IVOR15   Debug
                        gate(x"20",ex5_ivo_sel_q(16)) or   -- IVOR32   Vector Unavailable
                        gate(x"28",ex5_ivo_sel_q(17)) or   -- IVOR36   Doorbell
                        gate(x"2A",ex5_ivo_sel_q(18)) or   -- IVOR37   Doorbell Critical
                        gate(x"2C",ex5_ivo_sel_q(19)) or   -- IVOR38   Guest Doorbell
                        gate(x"2E",ex5_ivo_sel_q(20)) or   -- IVOR39   Guest Doorbell Critical / Guest Doorbell Machine Check
                        gate(x"30",ex5_ivo_sel_q(21)) or   -- IVOR40   Embedded Hypervisor System Call
                        gate(x"32",ex5_ivo_sel_q(22)) or   -- IVOR41   Embedded Hypervisor Privilege
                        gate(x"34",ex5_ivo_sel_q(23)) or   -- IVOR42   LRAT Error
                        gate(x"80",ex5_ivo_sel_q(24)) or   -- IVORXX   User Decrementer
                        gate(x"82",ex5_ivo_sel_q(25));     -- IVORXX   Performance Monitor

   -- Guest Doorbell is an oddball.  It's directed to hypervisor, but it updates GSRR0/GSRR1
   ex5_force_gsrr_d(t)        <= ex4_np1_flush_pri(GDBELLnp1);

   -------------------------------------------------------------------------------
   -- IO assignments
   -------------------------------------------------------------------------------
   -- This signal will decrement the SRR0 by 1, since the AXU's trap comes on past completion, but the
   -- architecture specifies that SRR0 be the address of the instruction that caused the trap.
   -- This should only be set if the trap was unmasked.  If it was unmasked by an rfi/mtmsr it
   -- should get the address of the next instruction.
   -- **NOTE** repurposing for other interrupts as well...
   
   ex4_ena_prog_int(t)           <= ex4_n_flush_pri_ena(FPENA) and not ex5_axu_trap_pie_q(t);
   ex4_n_ieratre_par_mcint(t)    <= ex4_n_flush_pri(IMCHKn)    and     ex4_n_ieratre_par_mchk_mcint_q(t);
   ex4_n_deratre_par_mcint(t)    <= ex4_n_flush_pri(DMCHKn)    and     ex4_n_deratre_par_mchk_mcint_q(t);
   ex4_n_mmu_hpriv_int(t)        <= ex4_n_flush_pri(HPRIVn)    and     ex4_n_mmu_hpriv_int_q(t);
   ex4_n_tlbwemiss_dlrat_int(t)  <= ex4_n_flush_pri(DLRATn)    and     ex4_n_tlbwemiss_dlrat_int_q(t);
   ex4_n_tlbwe_pil_prog_int(t)   <= ex4_n_flush_pri(PROG0An);
   ex4_n_tlbmh_mchk_mcint(t)     <= ex4_n_flush_pri(IMCHKn)    and     ex4_n_tlbmh_mchk_mcint_q(t)  and not mmu_eratmiss_done_q(t);
   ex4_n_tlbpar_mchk_mcint(t)    <= ex4_n_flush_pri(IMCHKn)    and     spare_5_q(t)                 and not mmu_eratmiss_done_q(t);


   
   ex5_srr0_dec_d(t)             <= ex4_ena_prog_int(t) or 
                                    ex4_n_ieratre_par_mcint(t) or ex4_n_deratre_par_mcint(t) or 
                                    ex4_n_mmu_hpriv_int(t)     or 
                                    ex4_n_tlbwemiss_dlrat_int(t) or
                                    ex4_n_tlbwe_pil_prog_int(t) or
                                    ex4_n_tlbmh_mchk_mcint(t) or
                                    ex4_n_tlbpar_mchk_mcint(t);
   
   -- If any instruction completes after the trap signal has gone high, signal an imprecise interrupt
   -- FP uCode complete comes after the trap signal has gone high, use ex5_in_ucode_q to block this.

   -- Need to account for cycles between ex4 & ex7...
   --                               EX4              EX5             EX6               EX7
   ex4_axu_trap_pie(t)           <= not(spare_1_d(t)) or spare_1_q(t) or spare_1_q(4+t) or spare_1_q(8+t);
   
   ex5_axu_trap_pie_d(t)         <= ex4_axu_trap_q(t) and (ex4_axu_trap_pie(t) or ex5_axu_trap_pie_q(t));
   

   -- Save a side copy of the dear on D-ERAT misses
   -- Use that copy to update the dear for D-ERAT misses which resulted in an interrupt during HTW.
   ex5_dear_update_saved_d(t)       <= derat_hold_present_q(t);
   cpl_spr_ex5_dear_update_saved(t) <= ex5_dear_update_saved_q(t);
   cpl_spr_ex5_dear_save(t)         <= ex5_n_dmiss_flush_q(t);

   -- Select which INTs will update which regs ... These lists go by IVOR#
   cpl_spr_ex5_dear_update(t)    <= ex5_ivo_sel_q(2) or ex5_ivo_sel_q(5) or ex5_ivo_sel_q(13) or (ex5_ivo_sel_q(23) and ex5_n_ptemiss_dlrat_int_q(t));
   cpl_spr_ex5_esr_update(t)     <= ex5_ivo_sel_q(2) or ex5_ivo_sel_q(5) or ex5_ivo_sel_q(13) or ex5_ivo_sel_q(6) or ex5_ivo_sel_q(3) or ex5_ivo_sel_q(16) or ex5_ivo_sel_q(23);

   -- Don't allow lower priority DBSR events to be set if a higher priority event exists
   -- Use the IVC/IAC signals that are not gated with MSR[DE] and DBCR[IDM]
   ex4_dbsr_update(t)           <= or_reduce(ex4_dbsr_cond and ex4_dbsr_en_cond) or exx_np1_icmp_dbg_event(t) or exx_np1_irpt_dbg_event(t) or ex4_n_flush_pri_dacr_async(t) or ex4_np1_ude_dbg_event_q(t);
   ex4_dbsr_act(t)               <= clkg_ctl_q or or_reduce(ex4_dbsr_cond)       or exx_np1_icmp_dbg_event(t) or exx_np1_irpt_dbg_event(t) or ex4_n_flush_pri_dacr_async(t) or ex4_np1_ude_dbg_event_q(t);

   ex4_esr_act(t)                <= clkg_ctl_q or ex4_n_flush_pri(PROG0n) or ex4_n_flush_pri(PROG1n) or ex4_n_flush_pri(PROG2n) or ex4_n_flush_pri(PROG3n) or ex4_n_flush_pri(PROG0An) or 
                                                  ex4_n_flush_pri(ALIGNn) or ex4_n_flush_pri(UNAVAILn) or ex4_np1_ptr_prog_int_q(t) or 
                                                  ex4_n_flush_pri(DSTORn) or ex4_n_flush_pri(DLRATn) or ex4_n_flush_pri(DTLBn) or 
                                                  ex4_n_flush_pri(ISTORn) or ex4_n_flush_pri(ILRATn);
   ex4_mcsr_act(t)               <= clkg_ctl_q or ex4_n_flush_cond(IMCHKn) or ex4_n_flush_cond(DMCHKn) or ex4_np1_flush_cond(MCHKnp1);
                                   
   ex4_mcsr_d(0+14*t)         <=                       ex3_n_dpovr_mchk_mcint(t);         -- DPOVR:   Data Port Overrun
   ex4_mcsr_d(1+14*t)         <=                       ex3_n_tlbsrej_mchk_mcint(t);       -- TLBIVAXSR:TLBivax Snoop Reject
   ex4_mcsr_d(2+14*t)         <=                       ex3_n_tlblru_mchk_mcint(t);        -- TLBLRUPE: TLB LRU Parity Error
   ex4_mcsr_d(3+14*t)         <= ex3_xuuc_val_q(t) and ex3_n_il2ecc_mchk_mcint_xuuc(t);   -- IL2ECC:  I$ L2 UC ECC Error
   ex4_mcsr_d(4+14*t)         <=                       ex3_n_dl2ecc_mchk_mcint(t);        -- DL2ECC:  D$ L2 UC ECC Error
   ex4_mcsr_d(5+14*t)         <= ex3_xu_val_q(t)   and ex3_n_ddpe_mchk_mcint_xu(t);       -- DDPE:    D$ Dir  Parity Error
   ex4_mcsr_d(6+14*t)         <=                       ex3_np1_ext_mchk_mcint(t);         -- EXT:     External Machine Check
   ex4_mcsr_d(7+14*t)         <=                       ex3_n_dcpe_mchk_mcint(t);          -- DCPE:    D$ Data Parity Error
   ex4_mcsr_d(8+14*t)         <= ex3_xuuc_val_q(t) and ex3_n_iemh_mchk_mcint_xuuc(t);     -- IEMH:    I-ERAT Multi-Hit
   ex4_mcsr_d(9+14*t)         <= ex3_xu_val_q(t)   and lsu_xu_ex3_derat_multihit_err(t);  -- DEMH:    D-ERAT Multi-Hit
   ex4_mcsr_d(10+14*t)        <=                       ex3_tlb_multihit_err_q(t);         -- TLBMH:   TLB Multi-Hit
   ex4_mcsr_d(11+14*t)        <=(ex3_xuuc_val_q(t) and ex3_n_iepe_mchk_mcint_xuuc(t)) or  -- IEPE:    I-ERAT Parity Error
                                                       ex3_n_ieratre_par_mchk_mcint(t);
   ex4_mcsr_d(12+14*t)        <=(ex3_xu_val_q(t)   and lsu_xu_ex3_derat_par_err(t)) or    -- DEPE:    D-ERAT Parity Error
                                (                      ex3_n_deratre_par_mchk_mcint(t));
   ex4_mcsr_d(13+14*t)        <=                       ex3_tlb_par_err_q(t);              -- TLBPE:   TLB Parity Error
   
   
   ex5_mcsr_d(0+15*t)         <= ex4_n_flush_pri(DMCHKn)    and ex4_mcsr_q(0+14*t);                -- DPOVR:   Data Port Overrun
   ex5_mcsr_d(1+15*t)         <= ex4_n_flush_pri(DMCHKn)    and ex4_n_ddmh_mchk_mcint(t);          -- DDMH:    Data Cache Directory MultiHit
   ex5_mcsr_d(2+15*t)         <= ex4_n_flush_pri(IMCHKn)    and ex4_mcsr_q(1+14*t);                -- TLBIVAXSR:TLBivax Snoop Reject
   ex5_mcsr_d(3+15*t)         <= ex4_n_flush_pri(IMCHKn)    and ex4_mcsr_q(2+14*t);                -- TLBLRUPE: TLB LRU Parity Error
   ex5_mcsr_d(4+15*t)         <= ex4_n_flush_pri(IMCHKn)    and ex4_mcsr_q(3+14*t);                -- IL2ECC:  I$ L2 UC ECC Error
   ex5_mcsr_d(5+15*t)         <= ex4_n_flush_pri(DMCHKn)    and ex4_mcsr_q(4+14*t);                -- DL2ECC:  D$ L2 UC ECC Error
   ex5_mcsr_d(6+15*t)         <= ex4_n_flush_pri(DMCHKn)    and ex4_mcsr_q(5+14*t);                -- DDPE:    D$ Dir  Parity Error
   ex5_mcsr_d(7+15*t)         <= ex4_np1_flush_pri(MCHKnp1) and ex4_mcsr_q(6+14*t);                -- EXT:     External Machine Check
   ex5_mcsr_d(8+15*t)         <= ex4_n_flush_pri(DMCHKn)    and ex4_mcsr_q(7+14*t);                -- DCPE:    D$ Data Parity Error
   ex5_mcsr_d(9+15*t)         <= ex4_n_flush_pri(IMCHKn)    and ex4_mcsr_q(8+14*t);                -- IEMH:    I-ERAT Multi-Hit
   ex5_mcsr_d(10+15*t)        <= ex4_n_flush_pri(DMCHKn)    and ex4_mcsr_q(9+14*t);                -- DEMH:    D-ERAT Multi-Hit
   ex5_mcsr_d(11+15*t)        <= ex4_n_flush_pri(IMCHKn)    and ex4_mcsr_q(10+14*t);               -- TLBMH:   TLB Multi-Hit
   ex5_mcsr_d(12+15*t)        <= ex4_n_flush_pri(IMCHKn)    and(ex4_mcsr_q(11+14*t) or 
                                                             ex4_n_ieratsx_par_mchk_mcint_q(t));   -- IEPE:    I-ERAT Parity Error
   ex5_mcsr_d(13+15*t)        <= ex4_n_flush_pri(DMCHKn)    and ex4_mcsr_q(12+14*t);               -- DEPE:    D-ERAT Parity Error
   ex5_mcsr_d(14+15*t)        <= ex4_n_flush_pri(IMCHKn)    and ex4_mcsr_q(13+14*t);               -- TLBPE:   TLB Parity Error
   
   pc_err_mcsr(0+11*t)        <= ex5_mcsr_act_q(t) and ex5_mcsr_q(0+15*t);  -- DPOVR:   Data Port Overrun
   pc_err_mcsr(1+11*t)        <= ex5_mcsr_act_q(t) and ex5_mcsr_q(2+15*t);  -- TLBIVAXSR:TLBivax Snoop Reject
   pc_err_mcsr(2+11*t)        <= ex5_mcsr_act_q(t) and ex5_mcsr_q(3+15*t);  -- TLBLRUPE: TLB LRU Parity Error
   pc_err_mcsr(3+11*t)        <= ex5_mcsr_act_q(t) and ex5_mcsr_q(7+15*t);  -- EXT:     External Machine Check
   pc_err_mcsr(4+11*t)        <= ex5_mcsr_act_q(t) and ex5_mcsr_q(9+15*t);  -- IEMH:    I-ERAT Multi-Hit
   pc_err_mcsr(5+11*t)        <= ex5_mcsr_act_q(t) and ex5_mcsr_q(10+15*t); -- DEMH:    D-ERAT Multi-Hit
   pc_err_mcsr(6+11*t)        <= ex5_mcsr_act_q(t) and ex5_mcsr_q(11+15*t); -- TLBMH:   TLB Multi-Hit
   pc_err_mcsr(7+11*t)        <= ex5_mcsr_act_q(t) and ex5_mcsr_q(12+15*t); -- IEPE:    I-ERAT Parity Error
   pc_err_mcsr(8+11*t)        <= ex5_mcsr_act_q(t) and ex5_mcsr_q(13+15*t); -- DEPE:    D-ERAT Parity Error
   pc_err_mcsr(9+11*t)        <= ex5_mcsr_act_q(t) and ex5_mcsr_q(14+15*t); -- TLBPE:   TLB Parity Error
   pc_err_mcsr(10+11*t)       <= not ex5_mchk_int_en_q(t) and or_reduce(pc_err_mcsr(11*t to 11*t+9)); -- MCHK when machine checks are disabled.
   pc_err_mcsr_summary_d(t)   <= or_reduce(pc_err_mcsr_rpt(11*t to 11*t+9));

   ex4_esr_mask(0)            <= ex4_n_flush_pri(PROG0n) or ex4_n_flush_pri(PROG0An);
   ex4_esr_mask(1)            <= ex4_n_flush_pri(PROG1n);
   ex4_esr_mask(2)            <= ex4_np1_flush_pri_instr(TRAP);
   ex4_esr_mask(3)            <= ex4_n_flush_pri(ALIGNn) or ex4_n_flush_pri(DSTORn) or ex4_n_flush_pri(DTLBn)  or ex4_n_flush_pri(DLRATn) or
                                 ex4_n_flush_pri(PROG0n) or ex4_n_flush_pri(PROG1n) or ex4_n_flush_pri(PROG2n) or ex4_n_flush_pri(PROG3n);
   ex4_esr_mask(4)            <= ex4_n_flush_pri(ALIGNn) or ex4_n_flush_pri(DSTORn) or ex4_n_flush_pri(DTLBn)  or ex4_n_flush_pri(DLRATn);
   ex4_esr_mask(5)            <= ex4_n_flush_pri(DSTORn);
   ex4_esr_mask(6)            <= ex4_n_flush_pri(DSTORn);
   ex4_esr_mask(7)            <= ex4_esr_mask(3);
   ex4_esr_mask(8)            <= ex4_n_flush_pri(PROG2n);
   ex4_esr_mask(9)            <= '0';
   ex4_esr_mask(10)           <= ex4_n_flush_pri_ena(FPENA);
   ex4_esr_mask(11)           <= ex4_n_flush_pri(DSTORn);
   ex4_esr_mask(12)           <= ex4_n_flush_pri(DLRATn);
   ex4_esr_mask(13)           <= ex4_n_flush_pri(ISTORn) or ex4_n_flush_pri(DSTORn);
   ex4_esr_mask(14)           <= ex4_n_flush_pri(ISTORn) or ex4_n_flush_pri(DSTORn) or ex4_n_flush_pri(ILRATn) or ex4_n_flush_pri(DLRATn);
   ex4_esr_mask(15)           <= ex4_esr_mask(3) or ex4_n_flush_pri_unavail(VEC);
   ex4_esr_mask(16)           <= ex4_esr_mask(4);

   ex4_mmu_esr_val_d(t)       <= ex3_tlb_inelig_q(t) or ex3_tlb_pt_fault_q(t) or ex3_tlb_miss_q(t);

   -- Force Instruction Type for AP/FP Enabled Interrupts
   with ex4_n_flush_pri_ena select
      ex4_axu_instr_type         <= "001"                   when "01",
                                    "100"                   when "10",
                                    ex4_axu_instr_type_q    when others;

   with ex4_mmu_esr_val_q(t) select
      ex4_is_any_store(t)        <= ex4_mmu_esr_st_q(t)     when '1',
                                    ex4_is_any_store_q(t)   when others;
                                    

   with ex4_mmu_esr_val_q(t) select
      ex4_epid_instr(t)          <= ex4_mmu_esr_epid_q(t)   when '1',
                                    ex4_epid_instr_q(t)     when others;
                                    
   
   ex4_esr_cond(DLK)   <= ex4_n_flush_pri(DSTORn) and (ex4_n_dlk0_dstor_int_q(t) or ex4_n_dlk1_dstor_int_q(t));
   ex4_esr_cond(PT)    <= ex4_mmu_esr_pt_q(t);
   ex4_esr_cond(VF)    <= ex4_n_flush_pri(DSTORn) and  ex4_n_vf_dstor_int_q(t);
   ex4_esr_cond(TLBI)  <= ex4_tlb_inelig_q(t);
   ex4_esr_cond(RW)    <=(ex4_n_flush_pri(DSTORn) and  ex4_n_rwaccess_dstor_int_q(t)) or
                         (ex4_n_flush_pri(ISTORn) and  ex4_n_exaccess_istor_int_q(t));
   ex4_esr_cond(UCT)   <= ex4_n_flush_pri(DSTORn) and  ex4_n_uct_dstor_int_q(t);
   
   xu_cpl_esr_pri : entity work.xuq_cpl_pri(xuq_cpl_pri)
   generic map (size => ex4_esr_cond'length)
   port map(
      cond                             => ex4_esr_cond,
      pri                              => ex4_esr_pri);


   ex5_esr_d(0+17*t)    <= ex4_esr_mask(0);                                                           -- PIL:  Illegal
   ex5_esr_d(1+17*t)    <= ex4_esr_mask(1);                                                           -- PPR:  Privledged
   ex5_esr_d(2+17*t)    <= ex4_esr_mask(2)  and ex4_np1_ptr_prog_int_q(t);                            -- PTR:  Trap
   ex5_esr_d(3+17*t)    <= ex4_esr_mask(3)  and ex4_axu_instr_type(2);                                -- FP:   Floating Point
   ex5_esr_d(4+17*t)    <= ex4_esr_mask(4)  and ex4_is_any_store(t)  and not ex4_esr_pri(UCT);        -- ST:   Store
   ex5_esr_d(5+17*t)    <= ex4_esr_mask(5)  and ex4_esr_pri(DLK)     and ex4_n_dlk0_dstor_int_q(t);   -- DLK0:
   ex5_esr_d(6+17*t)    <= ex4_esr_mask(6)  and ex4_esr_pri(DLK)     and ex4_n_dlk1_dstor_int_q(t);   -- DLK1:
   ex5_esr_d(7+17*t)    <= ex4_esr_mask(7)  and ex4_axu_instr_type(0);                                -- AP:   Auxillary
   ex5_esr_d(8+17*t)    <= ex4_esr_mask(8);                                                           -- PUO:  Unimplemented
   ex5_esr_d(9+17*t)    <= ex4_esr_mask(9);                                                           -- BO:   Byte Ordering
   ex5_esr_d(10+17*t)   <= ex4_esr_mask(10) and ex5_axu_trap_pie_q(t);                                -- PIE:  Imprecise
   ex5_esr_d(11+17*t)   <= ex4_esr_mask(11) and ex4_esr_pri(UCT);                                     -- UCT:   Unvailable Coprocessor Type
   ex5_esr_d(12+17*t)   <= ex4_esr_mask(12) and ex4_mmu_esr_data_q(t);                                -- DATA:  Data Access
   ex5_esr_d(13+17*t)   <= ex4_esr_mask(13) and ex4_esr_pri(TLBI);                                    -- TLBI:  TLB Ineligible
   ex5_esr_d(14+17*t)   <= ex4_esr_mask(14) and ex4_esr_pri(PT);                                      -- PT:    Page Table
   ex5_esr_d(15+17*t)   <= ex4_esr_mask(15) and ex4_axu_instr_type(1);                                -- SPV:  Vector
   ex5_esr_d(16+17*t)   <= ex4_esr_mask(16) and ex4_epid_instr(t);                                    -- EPID: External PID

   ex5_dbsr_d(0+19*t)   <=                         ex4_np1_ude_dbg_event_q(t);                          -- UDE:  Unconditional Debug Event
   ex5_dbsr_d(1+19*t)   <=                         exx_np1_icmp_dbg_event(t);                           -- ICMP: Instr Complete  (Must have MSR[DE]=1)
   ex5_dbsr_d(2+19*t)   <= ex4_dbsr_en_cond(1) and ex4_n_brt_dbg_cint_q(t);                             -- BRT:  Branch Taken    (Must have MSR[DE]=1)
   ex5_dbsr_d(3+19*t)   <=                         exx_np1_irpt_dbg_event(t);                           -- IRPT: Interrupt Taken
   ex5_dbsr_d(4+19*t)   <= ex4_dbsr_en_cond(1) and ex4_n_trap_dbg_cint_q(t);                            -- TRAP: Trap Taken
   ex5_dbsr_d(5+19*t)   <= ex4_dbsr_en_cond(0) and ex4_iac1_cmpr_q(t)      and ex4_anyuc_val_q(t);      -- IAC1: Instruction Address Compare
   ex5_dbsr_d(6+19*t)   <= ex4_dbsr_en_cond(0) and ex4_iac2_cmpr_q(t)      and ex4_anyuc_val_q(t);      -- IAC2: Instruction Address Compare
   ex5_dbsr_d(7+19*t)   <= ex4_dbsr_en_cond(0) and ex4_iac3_cmpr_q(t)      and ex4_anyuc_val_q(t);      -- IAC3: Instruction Address Compare
   ex5_dbsr_d(8+19*t)   <= ex4_dbsr_en_cond(0) and ex4_iac4_cmpr_q(t)      and ex4_anyuc_val_q(t);      -- IAC4: Instruction Address Compare
   ex5_dbsr_d(9+19*t)   <=(ex4_dbsr_en_cond(1) and ex4_dacr_cmpr_q(1)(t)   and ex4_anyuc_val_q(t)) or   -- DAC1R Read Data Address Compare
                           ex4_dac1r_cmpr_async_q(t);
   ex5_dbsr_d(10+19*t)  <= ex4_dbsr_en_cond(1) and ex4_dacw_cmpr_q(1)(t)   and ex4_anyuc_val_q(t);      -- DAC1W Write Data Address Compare
   ex5_dbsr_d(11+19*t)  <=(ex4_dbsr_en_cond(1) and ex4_dacr_cmpr_q(2)(t)   and ex4_anyuc_val_q(t)) or   -- DAC2R Read Data Address Compare
                           ex4_dac2r_cmpr_async_q(t);
   ex5_dbsr_d(12+19*t)  <= ex4_dbsr_en_cond(1) and ex4_dacw_cmpr_q(2)(t)   and ex4_anyuc_val_q(t);      -- DAC2W Write Data Address Compare
   ex5_dbsr_d(13+19*t)  <= ex4_dbsr_en_cond(1) and ex4_n_ret_dbg_cint_q(t);                             -- RET   Return Debug Event
   ex5_dbsr_d(14+19*t)  <= ex4_dbsr_en_cond(1) and ex4_dacr_cmpr_q(3)(t)   and ex4_anyuc_val_q(t);      -- DAC3R Read Data Address Compare
   ex5_dbsr_d(15+19*t)  <= ex4_dbsr_en_cond(1) and ex4_dacw_cmpr_q(3)(t)   and ex4_anyuc_val_q(t);      -- DAC3W Write Data Address Compare
   ex5_dbsr_d(16+19*t)  <= ex4_dbsr_en_cond(1) and ex4_dacr_cmpr_q(4)(t)   and ex4_anyuc_val_q(t);      -- DAC4R Read Data Address Compare
   ex5_dbsr_d(17+19*t)  <= ex4_dbsr_en_cond(1) and ex4_dacw_cmpr_q(4)(t)   and ex4_anyuc_val_q(t);      -- DAC4W Write Data Address Compare
   ex5_dbsr_d(18+19*t)  <= ex4_dbsr_en_cond(0) and ex4_n_ivc_dbg_cint_q(t);                             -- IVC:  Instruction Value Compare
   
   ex5_dbsr_ide_d(t)    <=(ex4_dac1r_cmpr_async_q(t) or ex4_dac2r_cmpr_async_q(t)) and not ex5_in_ucode_q(t);
   cpl_spr_ex5_dbsr_ide(t)    <= ex5_dbsr_ide_q(t);


   -- restart = flush to IU0
   -- Restart must default to be on in all cases except when in ucode
   -- Restart when an interrupt occurs in all cases
   -- Restart @ ucode end
   -- Restart if a flush to ucode while in ucode occurs (unaligned ld update forms)
   ex4_ucode_restart(t)                                     <= not ex4_uc_cia_val(t) or 
                                                                  (ex4_np1_flush_pri(Fnp1) and ex4_ucode_end(t)) or
                                                                   ex4_n_flush_pri(F2Un) or
                                                                   ex5_is_any_int(t);
   with ex4_flush_act(t) select
      ex5_ucode_restart_d(t)  <= ex4_ucode_restart(t)                            when '1',
                                (ex5_ucode_restart_q(t) or ex5_is_any_int(t))    when others;
                                                                   
   ex5_flush_2ucode_d(t)                                    <= ex4_n_flush_pri(F2Un);

   ex5_ram_interrupt(t)                                     <= ram_ip_q(t) and ex5_is_any_int(t);
   ex5_ram_issue_d(t)                                       <= ram_ip_q(t) and ex5_late_flush_q(0)(t);                             

   -- Mux correct instruction type for ESR
   with s2'((ex3_xu_val_q(t) or ex3_ucode_val_q(t)) & ex3_axu_val_q(t)) select
      ex4_axu_instr_type_d                <= dec_cpl_ex3_axu_instr_type          when "10",
                                             ex3_axu_instr_type_q(3*t to 3*t+2)  when "01",
                                             "000"                               when others;
                                             


   -- Special Handling for Trap Events
   -- with ex4_np1_flush_pri_instr(TRAP) select
   --    ex4_nia_muxed     <= ex4_cia                       when '1',
   --                         ex4_nia                       when others;
   ex4_cia_sel       <= fanout((not ex4_n_flush(t) and     ex4_np1_ptr_prog_int_q(t)),eff_ifar);
   ex4_nia_sel       <= fanout((    ex4_n_flush(t) or  not ex4_np1_ptr_prog_int_q(t)),eff_ifar);

   ex5_dbell_taken_d(t)                                     <= ex4_np1_flush_pri(DBELLnp1);
   ex5_cdbell_taken_d(t)                                    <= ex4_np1_flush_pri(CDBELLnp1);
   ex5_gdbell_taken_d(t)                                    <= ex4_np1_flush_pri(GDBELLnp1);
   ex5_gcdbell_taken_d(t)                                   <= ex4_np1_flush_pri(GCDBELLnp1);
   ex5_gmcdbell_taken_d(t)                                  <= ex4_np1_flush_pri(GDBMCHKnp1);

   xu_iu_iu0_flush_ifar(eff_ifar*t to eff_ifar*(t+1)-1)     <= flush_ifar;
   ex4_cia_p1_out(eff_ifar*t to eff_ifar*(t+1)-1)           <= ex4_cia_p1;
   cpl_spr_ex5_nia(eff_ifar*t to eff_ifar*(t+1)-1)          <= not ex5_nia_b_q(eff_ifar*t to eff_ifar*(t+1)-1);
   spr_iar(eff_ifar*t to eff_ifar*(t+1)-1)                  <= ex4_cia when ram_mode_q(t)='1' else ex4_cia_p1;


   ex3_n_fu_rfpe_det(t)                                     <= not (ex3_flush_q(t) or ex3_flush(t)) and fu_xu_ex3_regfile_err_det(t);

   ex4_n_fu_rfpe_flush_d(t)                                 <= ex3_n_fu_rfpe_det(t);
   ex4_n_xu_rfpe_flush_d(t)                                 <= (ex3_xuuc_val(t) or ex3_dep_val(t)) and  gpr_cpl_ex3_regfile_err_det;

   ex4_n_fu_rfpe_flush(t)                                   <= ex4_n_flush_pri(FPEn) and ex4_n_fu_rfpe_flush_q(t);
   ex4_n_xu_rfpe_flush(t)                                   <= ex4_n_flush_pri(FPEn) and ex4_n_xu_rfpe_flush_q(t);
   
   ex4_barrier_flush(t)                                     <= ex4_n_flush_pri(FwBSn);

   cia_out_gen_32 : if eff_ifar /= 62 generate
      ex4_cia_out(t)                                        <= (0 to 62-eff_ifar=>'0') & ex4_cia;
   end generate;
   cia_out_gen_64 : if eff_ifar  = 62 generate
      ex4_cia_out(t)                                        <= ex4_cia;
   end generate;

   -------------------------------------------------------------------------------
   -- Replicated Latches
   -------------------------------------------------------------------------------
   ex4_cia_b_latch : tri_rlmreg_p
 generic map(width   => ex4_cia_b_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk,
               vd      => vdd,
               gd      => gnd,
               act     => ex3_cia_act(t),
               forcee => bcfg_sl_force,
               d_mode  => d_mode_dc,
               delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b,
               mpw2_b  => mpw2_dc_b,
               thold_b => bcfg_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv_bcfg(ex4_cia_b_offset_bcfg + ex4_cia_b_q'length*t to ex4_cia_b_offset_bcfg + ex4_cia_b_q'length*(t+1)-1),
               scout   => sov_bcfg(ex4_cia_b_offset_bcfg + ex4_cia_b_q'length*t to ex4_cia_b_offset_bcfg + ex4_cia_b_q'length*(t+1)-1),
               din     => ex4_cia_b_d,
               dout    => ex4_cia_b_q);
   ex4_uc_cia_latch : tri_rlmreg_p
 generic map (width => ex4_uc_cia_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map (nclk    => nclk,
               vd      => vdd,
               gd      => gnd,
               act     => ex3_uc_cia_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc,
               delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b,
               mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex4_uc_cia_offset + ex4_uc_cia_q'length*t to ex4_uc_cia_offset + ex4_uc_cia_q'length*(t+1)-1),
               scout   => sov(ex4_uc_cia_offset + ex4_uc_cia_q'length*t to ex4_uc_cia_offset + ex4_uc_cia_q'length*(t+1)-1),
               din     => ex4_uc_cia_d,
               dout    => ex4_uc_cia_q);
   ex4_axu_instr_type_latch : tri_rlmreg_p
 generic map (width => ex4_axu_instr_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_esr_bit_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex4_axu_instr_type_offset + ex4_axu_instr_type_q'length*t to ex4_axu_instr_type_offset + ex4_axu_instr_type_q'length*(t+1)-1),
               scout   => sov(ex4_axu_instr_type_offset + ex4_axu_instr_type_q'length*t to ex4_axu_instr_type_offset + ex4_axu_instr_type_q'length*(t+1)-1),
               din     => ex4_axu_instr_type_d,
               dout    => ex4_axu_instr_type_q);
   ex4_is_any_store_latch : tri_rlmlatch_p
 generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
   port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_esr_bit_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex4_is_any_store_offset+t),
               scout   => sov(ex4_is_any_store_offset+t),
               din     => dec_cpl_ex3_is_any_store,
               dout    => ex4_is_any_store_q(t));
   ex4_epid_instr_latch : tri_rlmlatch_p
 generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
   port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_esr_bit_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex4_epid_instr_offset+t),
               scout   => sov(ex4_epid_instr_offset+t),
               din     => ex3_epid_instr_q,
               dout    => ex4_epid_instr_q(t));
   ex5_mem_attr_latch : tri_rlmreg_p
 generic map (width => ex5_mem_attr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map (nclk    => nclk,
               vd      => vdd,
               gd      => gnd,
               act     => ex4_mem_attr_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc,
               delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b,
               mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_mem_attr_offset + ex5_mem_attr_q'length*t to ex5_mem_attr_offset + ex5_mem_attr_q'length*(t+1)-1),
               scout   => sov(ex5_mem_attr_offset + ex5_mem_attr_q'length*t to ex5_mem_attr_offset + ex5_mem_attr_q'length*(t+1)-1),
               din     => ex4_mem_attr_q,
               dout    => ex5_mem_attr_q);
   ex5_flush_2ucode_latch : tri_rlmlatch_p
 generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
   port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_flush_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_flush_2ucode_offset+t),
               scout   => sov(ex5_flush_2ucode_offset+t),
               din     => ex5_flush_2ucode_d(t),
               dout    => ex5_flush_2ucode_q(t));
   ex5_ucode_restart_latch : tri_rlmlatch_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_ucode_restart_offset+t),
               scout   => sov(ex5_ucode_restart_offset+t),
               din     => ex5_ucode_restart_d(t),
               dout    => ex5_ucode_restart_q(t));
   ex5_mem_attr_le_latch : tri_rlmlatch_p
 generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
   port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_flush_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_mem_attr_le_offset+t),
               scout   => sov(ex5_mem_attr_le_offset+t),
               din     => ex5_mem_attr_le_d(t),
               dout    => ex5_mem_attr_le_q(t));
   ex5_ivo_sel_latch : tri_rlmreg_p
     generic map (width => ex5_ivo_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => exx_flush_inf_act,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_ivo_sel_offset + ex5_ivo_sel_q'length*t to ex5_ivo_sel_offset + ex5_ivo_sel_q'length*(t+1)-1),
               scout   => sov(ex5_ivo_sel_offset + ex5_ivo_sel_q'length*t to ex5_ivo_sel_offset + ex5_ivo_sel_q'length*(t+1)-1),
               din     => ex4_ivo_sel,
               dout    => ex5_ivo_sel_q);
   ex5_nia_b_latch : entity tri.tri_aoi22_nlats_wlcb(tri_aoi22_nlats_wlcb)
     generic map (width => eff_ifar, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_nia_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_nia_b_offset + eff_ifar*t to ex5_nia_b_offset + eff_ifar*(t+1)-1),
               scout   => sov(ex5_nia_b_offset + eff_ifar*t to ex5_nia_b_offset + eff_ifar*(t+1)-1),
               A1      => ex4_cia,
               A2      => ex4_cia_sel,
               B1      => ex4_nia,
               B2      => ex4_nia_sel,
               QB      => ex5_nia_b_q(eff_ifar*t to eff_ifar*(t+1)-1));
   ex5_flush_pri_dbg_latch : tri_regk
     generic map (width => ex5_flush_pri_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable_q,
               forcee => func_slp_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_nsl_thold_0_b,
               din     => ex4_flush_pri,
               dout    => ex5_flush_pri_dbg_q);
   exx_instr_async_block_latch : tri_rlmreg_p
     generic map (width => exx_instr_async_block_q(t)'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(exx_instr_async_block_offset+exx_instr_async_block_q(t)'length*t to exx_instr_async_block_offset + exx_instr_async_block_q(t)'length*(t+1)-1),
               scout   => sov(exx_instr_async_block_offset+exx_instr_async_block_q(t)'length*t to exx_instr_async_block_offset + exx_instr_async_block_q(t)'length*(t+1)-1),
               din     => exx_instr_async_block_d(t),
               dout    => exx_instr_async_block_q(t));
   ex5_esr_latch : tri_rlmreg_p
     generic map (width => ex5_esr_q'length/threads, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_esr_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_esr_offset+(ex5_esr_q'length*t)/threads to ex5_esr_offset+((ex5_esr_q'length*(t+1))/threads)-1),
               scout   => sov(ex5_esr_offset+(ex5_esr_q'length*t)/threads to ex5_esr_offset+((ex5_esr_q'length*(t+1))/threads)-1),
               din     => ex5_esr_d((ex5_esr_q'length*t)/threads to ((ex5_esr_q'length*(t+1))/threads)-1),
               dout    => ex5_esr_q((ex5_esr_q'length*t)/threads to ((ex5_esr_q'length*(t+1))/threads)-1));
   ex5_dbsr_latch : tri_rlmreg_p
     generic map (width => ex5_dbsr_q'length/threads, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_dbsr_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_dbsr_offset+(ex5_dbsr_q'length*t)/threads to ex5_dbsr_offset+((ex5_dbsr_q'length*(t+1))/threads)-1),
               scout   => sov(ex5_dbsr_offset+(ex5_dbsr_q'length*t)/threads to ex5_dbsr_offset+((ex5_dbsr_q'length*(t+1))/threads)-1),
               din     => ex5_dbsr_d((ex5_dbsr_q'length*t)/threads to ((ex5_dbsr_q'length*(t+1))/threads)-1),
               dout    => ex5_dbsr_q((ex5_dbsr_q'length*t)/threads to ((ex5_dbsr_q'length*(t+1))/threads)-1));
   ex5_mcsr_latch : tri_rlmreg_p
     generic map (width => ex5_mcsr_q'length/threads, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mcsr_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_mcsr_offset+(ex5_mcsr_q'length*t)/threads to ex5_mcsr_offset+((ex5_mcsr_q'length*(t+1))/threads)-1),
               scout   => sov(ex5_mcsr_offset+(ex5_mcsr_q'length*t)/threads to ex5_mcsr_offset+((ex5_mcsr_q'length*(t+1))/threads)-1),
               din     => ex5_mcsr_d((ex5_mcsr_q'length*t)/threads to ((ex5_mcsr_q'length*(t+1))/threads)-1),
               dout    => ex5_mcsr_q((ex5_mcsr_q'length*t)/threads to ((ex5_mcsr_q'length*(t+1))/threads)-1));
   dbg_flushcond_latch : tri_regk
     generic map (width => dbg_flushcond_q(t)'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable_q,
               forcee => func_slp_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_nsl_thold_0_b,
               din     => dbg_flushcond_d(t),
               dout    => dbg_flushcond_q(t));
   ex5_np1_icmp_dbg_cint_latch : tri_rlmreg_p
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_np1_icmp_dbg_cint_offset+t to ex5_np1_icmp_dbg_cint_offset+t),
               scout   => sov(ex5_np1_icmp_dbg_cint_offset+t to ex5_np1_icmp_dbg_cint_offset+t),
               din(0)  => ex5_np1_icmp_dbg_cint_d(t),
               dout(0) => ex5_np1_icmp_dbg_cint_q(t));
   ex5_np1_icmp_dbg_event_latch : tri_rlmreg_p
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_np1_icmp_dbg_event_offset+t to ex5_np1_icmp_dbg_event_offset+t),
               scout   => sov(ex5_np1_icmp_dbg_event_offset+t to ex5_np1_icmp_dbg_event_offset+t),
               din(0)  => ex5_np1_icmp_dbg_event_d(t),
               dout(0) => ex5_np1_icmp_dbg_event_q(t));

   -------------------------------------------------------------------------------
   -- Performance Monitor
   -------------------------------------------------------------------------------
   ex5_perf_itlb_d(t)         <= ex4_n_flush_pri(ITLBn);
   ex5_perf_dtlb_d(t)         <= ex4_n_flush_pri(DTLBn);
   
   xu_mm_ex5_perf_itlb(t)     <= ex5_perf_itlb_q(t);
   xu_mm_ex5_perf_dtlb(t)     <= ex5_perf_dtlb_q(t);

   ex5_perf_event_d(00+14*t)  <= ex4_instr_cpl(t);                                                             -- PPE Commit
   ex5_perf_event_d(01+14*t)  <= ex4_xuuc_val(t);                                                              -- Integer Commit
   ex5_perf_event_d(02+14*t)  <= ex4_np1_flush_pri(Fnp1) and ex4_ucode_end(t);                                 -- uCode Commit
   ex5_perf_event_d(03+14*t)  <= ex2_br_flush(t) or ex4_n_flush(t) or ex4_np1_flush(t);                        -- Any Flush
   ex5_perf_event_d(04+14*t)  <= ex4_xu_val(t)    and ex4_perf_event_q(0);                                     -- Branch Commit
   ex5_perf_event_d(05+14*t)  <= ex4_anyuc_val(t) and ex4_perf_event_q(1);                                     -- Branch Mispredict Commit
   ex5_perf_event_d(06+14*t)  <= ex4_anyuc_val(t) and ex4_perf_event_q(2);                                     -- Branch Taken Commit
   ex5_perf_event_d(07+14*t)  <= ex4_n_flush_pri(BTAn);                                                        -- Branch TA Mispredict Commit
   ex5_perf_event_d(08+14*t)  <= ex4_anyuc_val(t) and ex4_perf_event_q(3);                                     -- Mult/Div collision
   ex5_perf_event_d(09+14*t)  <= (ext_int_asserted(t)  or ex5_perf_event_q(09+14*t)) and not ex5_ivo_sel_q(4); -- External Interrupt Pending
   ex5_perf_event_d(10+14*t)  <= (crit_int_asserted(t) or ex5_perf_event_q(10+14*t)) and not ex5_ivo_sel_q(0); -- Critical External Interrupt Pending
   ex5_perf_event_d(11+14*t)  <= (perf_int_asserted(t) or ex5_perf_event_q(11+14*t)) and not ex5_ivo_sel_q(25);-- Performance Mon Interrupt Pending
   ex5_perf_event_d(12+14*t)  <= ex4_anyuc_val(t) and ex4_n_ivc_dbg_match_q(t);                                -- Opcode Match
   ex5_perf_event_d(13+14*t)  <= ex4_instr_cpl(t) and not or_reduce(spr_ccr0_we);                              -- Concurrent Run Instructions

   cpl_perf_tx_events(00+19*t)<= ex5_perf_event_q(00+14*t);                -- PPE Commit
   cpl_perf_tx_events(01+19*t)<= ex5_perf_event_q(01+14*t);                -- Integer Commit
   cpl_perf_tx_events(02+19*t)<= ex5_perf_event_q(02+14*t);                -- uCode Commit
   cpl_perf_tx_events(03+19*t)<= ex5_perf_event_q(03+14*t);                -- Any Flush
   cpl_perf_tx_events(04+19*t)<= ex5_perf_event_q(04+14*t);                -- Branch Commit
   cpl_perf_tx_events(05+19*t)<= ex5_perf_event_q(05+14*t);                -- Branch Mispredict Commit
   cpl_perf_tx_events(06+19*t)<= ex5_perf_event_q(06+14*t);                -- Branch Taken Commit
   cpl_perf_tx_events(07+19*t)<= ex5_perf_event_q(07+14*t);                -- Branch TA Mispredict Commit
   cpl_perf_tx_events(08+19*t)<= ex5_perf_event_q(08+14*t);                -- Mult/Div collision
   cpl_perf_tx_events(09+19*t)<= ex5_perf_event_q(09+14*t);                -- External Interrupt Pending
   cpl_perf_tx_events(10+19*t)<= ex5_perf_event_q(10+14*t);                -- Critical External Interrupt Pending
   cpl_perf_tx_events(11+19*t)<= ex5_perf_event_q(11+14*t);                -- Performance Mon Interrupt Pending
   cpl_perf_tx_events(12+19*t)<= ex5_perf_event_q(12+14*t);                -- Opcode Match
   cpl_perf_tx_events(13+19*t)<= ex5_perf_event_q(13+14*t);                -- Concurrent Run Instructions
   cpl_perf_tx_events(14+19*t)<= any_ext_perf_int;                         -- External, Critical, Perf Interrupts Taken (any thread)
   cpl_perf_tx_events(15+19*t)<= ex5_ivo_sel_q(4);                         -- External Interrupt Taken
   cpl_perf_tx_events(16+19*t)<= ex5_ivo_sel_q(0);                         -- Critical External Interrupt Taken
   cpl_perf_tx_events(17+19*t)<= ex5_ivo_sel_q(25);                        -- Performance Mon Interrupt Taken
   cpl_perf_tx_events(18+19*t)<= ex5_ivo_sel_q(17) or ex5_ivo_sel_q(18);   -- Processor Doorbell or Critical Doorbell Taken

   any_ext_perf_ints(t)       <= ex5_ivo_sel_q(4) or ex5_ivo_sel_q(0) or ex5_ivo_sel_q(25);
   
   ext_int_asserted(t)        <= spr_cpl_async_int(0+3*t) and not spr_cpl_async_int_q(0+3*t);
   crit_int_asserted(t)       <= spr_cpl_async_int(1+3*t) and not spr_cpl_async_int_q(1+3*t);
   perf_int_asserted(t)       <= spr_cpl_async_int(2+3*t) and not spr_cpl_async_int_q(2+3*t);   

   mark_unused(ex4_esr_pri(VF));
   mark_unused(ex4_esr_pri(RW));

   --                            Ucode Completing           Type is FP                      Not LD/ST
   ex5_axu_ucode_val_opc(t)   <= ex5_ucode_end_dbg_q(t) and ex4_axu_instr_type_q(2) and not ex5_mem_attr_val_q(t);
   
   ex5_axu_val_dbg_opc(t)     <= ex5_axu_val_dbg_q(t) or  ex5_axu_ucode_val_opc(t);
   ex5_xu_val_dbg_opc(t)      <= ex5_xu_val_q(t) and not  ex5_axu_ucode_val_opc(t);
   

end generate;



any_ext_perf_int           <= or_reduce(any_ext_perf_ints);

-------------------------------------------------------------------------------
-- Branch Sub-Unit
-------------------------------------------------------------------------------
xu_cpl_br : entity work.xuq_cpl_br(xuq_cpl_br)
generic map(
   expand_type                      => expand_type,
   threads                          => threads,
   eff_ifar                         => eff_ifar,
    uc_ifar                         => uc_ifar,
   regsize                          => regsize)
port map(
   nclk                             => nclk,
   d_mode_dc                        => d_mode_dc,
   delay_lclkr_dc                   => delay_lclkr_dc,
   mpw1_dc_b                        => mpw1_dc_b,
   mpw2_dc_b                        => mpw2_dc_b,
   func_sl_thold_0_b                => func_sl_thold_0_b,
   func_sl_force => func_sl_force,
   sg_0                             => sg_0,
   scan_in                          => siv_3(0),
   scan_out                         => sov_3(0),
   rf1_act                          => exx_act(0),
   ex1_act                          => exx_act(1), 
   rf1_tid                          => rf1_tid_q,
   ex1_tid                          => ex1_xu_val_q,
   ex1_xu_val                       => ex1_xu_val,
   dec_cpl_rf1_ifar                 => dec_cpl_rf1_ifar,
   ex1_xu_ifar                      => ex1_xu_ifar,
   dec_cpl_rf1_pred_taken_cnt       => dec_cpl_rf1_pred_taken_cnt,
   dec_cpl_rf1_instr                => dec_cpl_rf1_instr,
   byp_cpl_ex1_cr_bit               => byp_cpl_ex1_cr_bit,
   spr_lr                           => spr_lr,
   spr_ctr                          => spr_ctr,
   ex2_br_flush                     => ex2_br_flush,
   ex2_br_flush_ifar                => ex2_br_flush_ifar,
   ex1_branch                       => ex1_branch,
   ex1_br_mispred                   => ex1_br_mispred,
   ex1_br_taken                     => ex1_br_taken,
   ex1_br_update                    => ex1_br_update,
   ex1_is_bcctr                     => open,
   ex1_is_bclr                      => ex1_is_bclr,
   ex1_lr_update                    => ex1_lr_update,
   ex1_ctr_dec_update               => ex1_ctr_dec_update,
   ex1_instr                        => ex1_instr,
   spr_msr_cm                       => msr_cm_q,
   br_debug                         => br_debug,
   vdd                              => vdd,
   gnd                              => gnd
);

-------------------------------------------------------------------------------
-- SPR Sub-Unit
-------------------------------------------------------------------------------
xu_cpl_spr : entity work.xuq_cpl_spr(xuq_cpl_spr)
generic map(
   hvmode                           => hvmode,
   a2mode                           => a2mode,
   expand_type                      => expand_type,
   threads                          => threads,
   regsize                          => regsize,
   eff_ifar                         => eff_ifar)
port map(
   nclk                             => nclk,
   d_mode_dc                        => d_mode_dc,
   delay_lclkr_dc                   => delay_lclkr_dc,
   mpw1_dc_b                        => mpw1_dc_b,
   mpw2_dc_b                        => mpw2_dc_b,
   dcfg_sl_force => dcfg_sl_force,
   dcfg_sl_thold_0_b                => dcfg_sl_thold_0_b,
   func_sl_force => func_sl_force,
   func_sl_thold_0_b                => func_sl_thold_0_b,
   func_nsl_force => func_nsl_force,
   func_nsl_thold_0_b               => func_nsl_thold_0_b,
   sg_0                             => sg_0,
   scan_in                          => siv_3(1),
   scan_out                         => sov_3(1),
   dcfg_scan_in                     => siv_dcfg(0),
   dcfg_scan_out                    => sov_dcfg(0),
   spr_bit_act                      => spr_bit_act_q,
   exx_act                          => exx_act(1 to 4),
   ex1_instr                        => ex1_instr(11 to 20),
   ex2_tid                          => ex2_xu_val_q,
   ex2_ifar                         => ex2_ifar,
   ex1_is_mfspr                     => ex1_is_mfspr_q,
   ex1_is_mtspr                     => ex1_is_mtspr_q,
   ex4_lr_update                    => ex4_lr_update_q,
   ex4_ctr_dec_update               => ex4_ctr_dec_update_q,
   ex5_val                          => ex5_xu_val_q,
   ex5_spr_wd                       => ex5_rt_q,
   ex5_cia_p1                       => ex5_cia_p1,
   ex2_mtiar                        => ex2_mtiar,
   cpl_byp_ex3_spr_rt               => cpl_byp_ex3_spr_rt,
   ex3_iac1_cmpr                    => ex3_iac1_cmpr,
   ex3_iac2_cmpr                    => ex3_iac2_cmpr,
   ex3_iac3_cmpr                    => ex3_iac3_cmpr,
   ex3_iac4_cmpr                    => ex3_iac4_cmpr,
   spr_cpl_iac1_en                  => spr_cpl_iac1_en,
   spr_cpl_iac2_en                  => spr_cpl_iac2_en,
   spr_cpl_iac3_en                  => spr_cpl_iac3_en,
   spr_cpl_iac4_en                  => spr_cpl_iac4_en,
   spr_dbcr1_iac12m                 => spr_dbcr1_iac12m,
   spr_dbcr1_iac34m                 => spr_dbcr1_iac34m,
   spr_iar                          => spr_iar,
   spr_msr_cm                       => msr_cm_q,
	spr_givpr                        => spr_givpr,
	spr_ivpr                         => spr_ivpr,
	spr_ctr                          => spr_ctr,
	spr_lr                           => spr_lr,
	spr_xucr3_cm_hold_dly            => spr_xucr3_cm_hold_dly,
	spr_xucr3_stop_dly               => spr_xucr3_stop_dly,
	spr_xucr3_hold0_dly              => spr_xucr3_hold0_dly,
	spr_xucr3_hold1_dly              => spr_xucr3_hold1_dly,
	spr_xucr3_csi_dly                => spr_xucr3_csi_dly,
	spr_xucr3_int_dly                => spr_xucr3_int_dly,
	spr_xucr3_asyncblk_dly           => spr_xucr3_asyncblk_dly,
	spr_xucr3_flush_dly              => spr_xucr3_flush_dly,
	spr_xucr4_div_bar_dis            => spr_xucr4_div_bar_dis,
	spr_xucr4_lsu_bar_dis            => spr_xucr4_lsu_bar_dis,
	spr_xucr4_barr_dly               => spr_xucr4_barr_dly,
   spr_xucr4_div_barr_thres         => spr_xucr4_div_barr_thres,
   spr_xucr4_mddmh                  => spr_xucr4_mddmh,
   spr_xucr4_mmu_mchk               => spr_xucr4_mmu_mchk_int,
   vdd                              => vdd,
   gnd                              => gnd
);

-------------------------------------------------------------------------------
-- Error Macros
-------------------------------------------------------------------------------
xu_cpl_sprg_ue_err_rpt : entity tri.tri_direct_err_rpt(tri_direct_err_rpt) 
generic map(width => threads, expand_type => expand_type)
port map (  vd => vdd, gd => gnd,
            err_in   => ex5_n_flush_sprg_ue_flush_q,
            err_out  => xu_pc_err_sprg_ue);

xu_cpl_err_debug_rpt : entity tri.tri_direct_err_rpt(tri_direct_err_rpt) 
generic map (width => threads, expand_type => expand_type)
port map (vd => vdd, gd => gnd,
          err_in        => ex5_ext_dbg_err_q,
          err_out       => xu_pc_err_debug_event);

xu_cpl_err_attn_rpt : entity tri.tri_direct_err_rpt(tri_direct_err_rpt) 
generic map (width => threads, expand_type => expand_type)
port map (vd => vdd, gd => gnd,
          err_in        => ex5_is_attn_q,
          err_out       => xu_pc_err_attention_instr);

xu_cpl_err_nia_rpt : entity tri.tri_direct_err_rpt(tri_direct_err_rpt) 
generic map (width => threads, expand_type => expand_type)
port map (vd => vdd, gd => gnd,
          err_in        => ex5_err_nia_miscmpr_q,
          err_out       => xu_pc_err_nia_miscmpr);


ex6_mcsr_act_d       <= or_reduce(ex5_mcsr_act_q);
ex5_mcsr_act         <= ex6_mcsr_act_d or ex6_mcsr_act_q;

bcfg_lcbnd: entity tri.tri_lcbnd
generic map (expand_type => expand_type )
port map(act         => ex5_mcsr_act,
         vd          => vdd,
         gd          => gnd,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b      => mpw1_dc_b,
         mpw2_b      => mpw2_dc_b,
         nclk        => nclk,
         forcee => bcfg_slp_sl_force,
         sg          => sg_0,
         thold_b     => bcfg_slp_sl_thold_0_b,
         d1clk       => mcsr_bcfg_slp_sl_d1clk,
         d2clk       => mcsr_bcfg_slp_sl_d2clk,
         lclk        => mcsr_bcfg_slp_sl_lclk);

bcfg_lcbs: tri_lcbs
generic map (expand_type => expand_type )
port map(vd          => vdd,
         gd          => gnd,
         delay_lclkr => delay_lclkr_dc,
         nclk        => nclk,
         forcee => so_force,
         thold_b     => bcfg_so_thold_0_b,
         dclk        => bcfg_so_d2clk,
         lclk        => bcfg_so_lclk);

xu_cpl_err_mcsr_rpt : entity tri.tri_err_rpt
generic map (width => pc_err_mcsr'length, mask_reset_value => (pc_err_mcsr'range=>'0'), inline => false, expand_type => expand_type)
port map (vd => vdd, gd => gnd,
   err_d1clk     => mcsr_bcfg_slp_sl_d1clk,
   err_d2clk     => mcsr_bcfg_slp_sl_d2clk,
   err_lclk      => mcsr_bcfg_slp_sl_lclk,
   err_scan_in   => siv_bcfg(mcsr_rpt_offset_bcfg  to mcsr_rpt_offset_bcfg  + pc_err_mcsr'length-1),
   err_scan_out  => sov_bcfg(mcsr_rpt_offset_bcfg  to mcsr_rpt_offset_bcfg  + pc_err_mcsr'length-1),
   mode_dclk     => bcfg_so_d2clk,
   mode_lclk     => bcfg_so_lclk,
   mode_scan_in  => siv_bcfg(mcsr_rpt2_offset_bcfg to mcsr_rpt2_offset_bcfg + pc_err_mcsr'length-1),
   mode_scan_out => sov_bcfg(mcsr_rpt2_offset_bcfg to mcsr_rpt2_offset_bcfg + pc_err_mcsr'length-1),
   err_in        => pc_err_mcsr,
   err_out       => pc_err_mcsr_rpt);

   pc_err_mcsr_rpt_d             <= or_reduce_t(pc_err_mcsr_rpt,threads);
   
   xu_pc_err_mcsr_summary        <= pc_err_mcsr_summary_q;
   xu_pc_err_ditc_overrun        <= pc_err_mcsr_rpt_q(0);
   xu_pc_err_local_snoop_reject  <= pc_err_mcsr_rpt_q(1);
   xu_pc_err_tlb_lru_parity      <= pc_err_mcsr_rpt_q(2);
   xu_pc_err_ext_mchk            <= pc_err_mcsr_rpt_q(3);
   xu_pc_err_ierat_multihit      <= pc_err_mcsr_rpt_q(4);
   xu_pc_err_derat_multihit      <= pc_err_mcsr_rpt_q(5);
   xu_pc_err_tlb_multihit        <= pc_err_mcsr_rpt_q(6);
   xu_pc_err_ierat_parity        <= pc_err_mcsr_rpt_q(7);
   xu_pc_err_derat_parity        <= pc_err_mcsr_rpt_q(8);
   xu_pc_err_tlb_parity          <= pc_err_mcsr_rpt_q(9);
   xu_pc_err_mchk_disabled       <= pc_err_mcsr_rpt_q(10);
   

ex5_cm_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 1, clockgate => 0)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_cm_hold_cond_offset),
            scout   => sov(ex5_cm_hold_cond_offset),
            delay   => spr_xucr3_cm_hold_dly,
            din     => ex5_cm_hold_cond,
            dout    => exx_cm_hold);

-------------------------------------------------------------------------------
-- Block Conditions
-------------------------------------------------------------------------------
ex3_async_int_block_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 1)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_async_int_block_cond_offset),
            scout   => sov(ex3_async_int_block_cond_offset),
            delay   => spr_xucr3_asyncblk_dly,
            din     => ex3_async_int_block_cond,
            dout    => ex3_async_int_block_d);

ex3_base_int_block_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 1, clockgate => 0)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_base_int_block_offset),
            scout   => sov(ex3_base_int_block_offset),
            delay   => spr_xucr3_int_dly,
            din     => ex3_base_int_block_cond,
            dout    => ex3_base_int_block);

ex3_mchk_int_block_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 1, clockgate => 0)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_mchk_int_block_offset),
            scout   => sov(ex3_mchk_int_block_offset),
            delay   => spr_xucr3_int_dly,
            din     => ex3_mchk_int_block_cond,
            dout    => ex3_mchk_int_block);

-------------------------------------------------------------------------------
-- Multi-Cycle Flushes
-------------------------------------------------------------------------------
exx_thread_stop_mcflush_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 1)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_thread_stop_mcflush_offset),
            scout   => sov(exx_thread_stop_mcflush_offset),
            delay   => spr_xucr3_stop_dly,
            din     => ex4_thread_stop_q,
            dout    => exx_thread_stop_mcflush);

exx_csi_mcflush_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 1)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_csi_mcflush_offset),
            scout   => sov(exx_csi_mcflush_offset),
            delay   => spr_xucr3_csi_dly,
            din     => ex5_csi,
            dout    => exx_csi_mcflush);

exx_lateflush_mcflush_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 0)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_lateflush_mcflush_offset),
            scout   => sov(exx_lateflush_mcflush_offset),
            delay   => spr_xucr3_flush_dly,
            din     => ex4_late_flush,
            dout    => exx_lateflush_mcflush);

exx_hold0_mcflush_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 1)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_hold0_mcflush_offset),
            scout   => sov(exx_hold0_mcflush_offset),
            delay   => spr_xucr3_hold0_dly,
            din     => hold_state_0,
            dout    => exx_hold0_mcflush);

exx_hold1_mcflush_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 1)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_hold1_mcflush_offset),
            scout   => sov(exx_hold1_mcflush_offset),
            delay   => spr_xucr3_hold1_dly,
            din     => hold_state_1,
            dout    => exx_hold1_mcflush);

exx_barr_mcflush_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => threads, expand_type => expand_type, passthru => 0)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_barr_mcflush_offset),
            scout   => sov(exx_barr_mcflush_offset),
            delay   => spr_xucr4_barr_dly,
            din     => ex4_barrier_flush,
            dout    => exx_barr_mcflush);


exx_multi_flush_d <= exx_thread_stop_mcflush or
                     exx_hold0_mcflush or
                     exx_hold1_mcflush or
                     exx_barr_mcflush or
                     exx_csi_mcflush;                     

exx_multi_flush   <= exx_lateflush_mcflush or
                     exx_multi_flush_q;


-------------------------------------------------------------------------------
-- Flush Pipe
-------------------------------------------------------------------------------
xu_iu_ex5_ppc_cpl  <= ex5_instr_cpl_q;

iu_flush       <= ex2_br_flush     or ex5_late_flush_q(0);
xu_iu_flush    <= iu_flush;

ex4_late_flush <=                     ex4_np1_flush or  ex4_n_flush;

ex5_late_flush_repwr : for r in 0 to ifar_repwr-1 generate
   ex5_late_flush_d(r)  <=            ex4_np1_flush or  ex4_n_flush or exx_multi_flush   or hold_state_1;
end generate;

exx_flush_inf_act    <= clkg_ctl_q or or_reduce(any_flush or is2_flush_q);
ex4_flush_inf_act    <= clkg_ctl_q or or_reduce(ex4_flush or ex5_flush_q);

any_flush      <= ex2_br_flush     or ex4_np1_flush or  ex4_n_flush or exx_multi_flush   or hold_state_1;
is2_flush      <= ex2_br_flush     or ex4_np1_flush or  ex4_n_flush or exx_multi_flush   or hold_state_1;
rf0_flush      <= ex2_br_flush     or ex4_np1_flush or  ex4_n_flush or exx_multi_flush   or hold_state_1;
rf1_flush      <= ex2_br_flush     or ex4_np1_flush or  ex4_n_flush or exx_multi_flush   or hold_state_1;
ex1_flush      <= ex2_br_flush     or ex4_np1_flush or  ex4_n_flush or exx_multi_flush   or hold_state_1;
ex2_flush      <=                     ex4_np1_flush or  ex4_n_flush or exx_multi_flush   or hold_state_1;
ex3_flush      <=                     ex4_np1_flush or  ex4_n_flush or exx_multi_flush   or hold_state_1;
ex4_flush      <=                                       ex4_n_flush or exx_multi_flush_q or hold_state_1;

xu_rf0_flush   <= rf0_flush_q;
xu_rf1_flush   <= rf1_flush_q;
xu_ex1_flush   <= ex1_flush_q;
xu_ex2_flush   <= ex2_flush_q;
xu_ex3_flush   <= ex3_flush_q;
xu_ex4_flush   <= ex4_flush_q;
xu_ex5_flush   <= ex5_flush_q;

xu_n_is2_flush <= xu_is2_n_flush_q;
xu_n_rf0_flush <= xu_rf0_n_flush_q;
xu_n_rf1_flush <= xu_rf1_n_flush_q;
xu_n_ex1_flush <= xu_ex1_n_flush_q;
xu_n_ex2_flush <= xu_ex2_n_flush_q;
xu_n_ex3_flush <= xu_ex3_n_flush_q;
xu_n_ex4_flush <= xu_ex4_n_flush_q;
xu_n_ex5_flush <= xu_ex5_n_flush_q;

xu_s_rf1_flush <= xu_rf1_s_flush_q;
xu_s_ex1_flush <= xu_ex1_s_flush_q;
xu_s_ex2_flush <= xu_ex2_s_flush_q;
xu_s_ex3_flush <= xu_ex3_s_flush_q;
xu_s_ex4_flush <= xu_ex4_s_flush_q;
xu_s_ex5_flush <= xu_ex5_s_flush_q;

xu_w_rf1_flush <= xu_rf1_w_flush_q;
xu_w_ex1_flush <= xu_ex1_w_flush_q;
xu_w_ex2_flush <= xu_ex2_w_flush_q;
xu_w_ex3_flush <= xu_ex3_w_flush_q;
xu_w_ex4_flush <= xu_ex4_w_flush_q;
xu_w_ex5_flush <= xu_ex5_w_flush_q;

-- MMU needs special flushes to avoid flushing a I/D-ERAT miss inside the MMU.
-- However, the I/D-ERAT miss still needs to get flushed out of the XU.
xu_mm_ex4_flush   <= ex4_flush_q;
xu_mm_ex5_flush   <= ex5_flush_q       and not ex5_n_dmiss_flush_q;
xu_mm_ierat_flush <= is2_flush_q       and not ierat_hold_present_q; -- Gets set by ex5
xu_mm_ierat_miss  <=                           ex5_n_imiss_flush_q;

-------------------------------------------------------------------------------
-- Valid Shadow Pipes
-------------------------------------------------------------------------------
rf1_xu_val     <= dec_cpl_rf1_val         and not rf1_flush_q;
ex1_xu_val     <= ex1_xu_val_q            and not ex1_flush_q and not ex1_flush; -- Branch resolve needs fast flush
ex2_xu_val     <= ex2_xu_val_q            and not ex2_flush;
ex3_xu_val     <= ex3_xu_val_q            and not ex3_flush;
ex4_xu_val     <= ex4_xu_val_q            and not ex4_flush;

ex2_axu_val    <= fu_xu_ex2_ifar_val      and not ex2_flush_q and not ex2_flush;
ex3_axu_val    <= ex3_axu_val_q           and not ex3_flush;
ex4_axu_val    <= ex4_axu_val_q           and not ex4_flush;

rf1_ucode_val  <= dec_cpl_rf1_ucode_val   and not rf1_flush_q and not rf1_flush;
ex1_ucode_val  <= ex1_ucode_val_q         and not ex1_flush;
ex2_ucode_val  <= ex2_ucode_val_q         and not ex2_flush;
ex3_ucode_val  <= ex3_ucode_val_q         and not ex3_flush;
ex4_ucode_val  <= ex4_ucode_val_q         and not ex4_flush;

ex3_any_val    <= (ex3_xu_val_q or ex3_axu_val_q)     and not ex3_flush;
ex4_any_val    <= (ex4_xu_val_q or ex4_axu_val_q)     and not ex4_flush;


ex3_anyuc_val  <= ex3_anyuc_val_q         and not ex3_flush;
ex4_anyuc_val  <= ex4_anyuc_val_q         and not ex4_flush;
                   
ex3_anyuc_val_q<= (ex3_xu_val_q or ex3_axu_val_q or
                   ex3_ucode_val_q);

ex4_anyuc_val_q<= (ex4_xu_val_q or ex4_axu_val_q or
                   ex4_ucode_val_q);

ex3_xuuc_val_q <= (ex3_xu_val_q or ex3_ucode_val_q);
ex4_xuuc_val_q <= (ex4_xu_val_q or ex4_ucode_val_q);

ex3_xuuc_val   <= ex3_xuuc_val_q          and not ex3_flush;
ex4_xuuc_val   <= ex4_xuuc_val_q          and not ex4_flush;

ex3_dep_val    <= dec_cpl_ex3_mc_dep_chk_val          and not ex3_flush;

-------------------------------------------------------------------------------
-- Misc Logic
-------------------------------------------------------------------------------
ex3_n_mmu_mchk_flush_only        <= not spr_ccr2_notlb and not spr_xucr4_mmu_mchk_int;

ex3_is_any_ldst                  <= ex3_is_any_load_dac_q or ex3_is_any_store_dac_q or ex3_is_icswx_q;


ex2_msr_updater   <= ex2_is_mtmsr_q    or ex2_any_wrtee_q or 
                     ex2_is_rfi_q      or ex2_is_rfgi_q or 
                     ex2_is_rfci_q     or ex2_is_rfmci_q;

ex5_cia_p1_d      <= mux_t(ex4_cia_p1_out,ex4_xu_val_q);

ex5_msr_cm        <= or_reduce(ex5_xu_val_q and msr_cm_q);

ex5_cia_p1(32 to 61)             <= ex5_cia_p1_q(32 to 61);
ex5_cia_p1_gen : if IFAR'left < 32 generate
   ex5_cia_p1(IFAR'left to 31)   <= gate(ex5_cia_p1_q(IFAR'left to 31),ex5_msr_cm);
end generate;

ex2_n_align_int_d <= ex1_is_any_ldstmw_q and or_reduce(alu_cpl_ex1_eff_addr(62 to 63));

ex1_taken_bclr    <= ex1_is_bclr and ex1_br_taken;

ex5_n_ext_dbg_stopc_flush_d  <= or_reduce(ex4_dbsr_update and ext_dbg_stop_core_q);

ex5_n_ext_dbg_stopt_flush_d  <=           ex4_dbsr_update and ext_dbg_stop_n_q;

ex3_n_dcpe_flush_d   <= (0 to threads-1=>lsu_xu_datc_perr_recovery);

ex2_ifar             <= not ex2_ifar_b_q;

ex3_np1_mtiar_flush  <= gate(ex3_xu_val,ex3_mtiar_q);
ex4_np1_mtiar_flush  <= gate(ex4_xu_val,ex4_mtiar_q);

ex2_any_wrtee_d   <= ex1_is_wrtee_q or ex1_is_wrteei_q;

ex7_is_tlbwe_d    <= gate(ex6_xu_val_q,ex6_is_tlbwe_q);

with s3'(pc_xu_ram_mode & pc_xu_ram_thread) select
   ram_mode_d     <= "1000" when "100",
                     "0100" when "101",
                     "0010" when "110",
                     "0001" when "111",
                     "0000" when others;

with s3'(pc_xu_ram_execute & pc_xu_ram_thread) select
   ram_execute_d  <= "1000" when "100",
                     "0100" when "101",
                     "0010" when "110",
                     "0001" when "111",
                     "0000" when others;

with s3'(pc_xu_ram_flush_thread & pc_xu_ram_thread) select
   ram_flush_d    <= "1000" when "100",
                     "0100" when "101",
                     "0010" when "110",
                     "0001" when "111",
                     "0000" when others;


ram_ip_d          <= ram_mode_q and (ram_execute_q or                                     -- Set on Execute
                                    (ram_ip_q and not (ex4_ram_cpl or ex5_is_any_int)));  -- Cleared on completion or interrupt
                        
-- ex5_ram_issue_q comes on when a ram instruction gets flushed.
-- However, if it gets flushed within two cycles of getting issued,
-- the iu does not flush it.  accounting for this here.
ex5_ram_issue_gated  <= ex5_ram_issue_q and not (ex7_ram_issue_q or ex8_ram_issue_q);

ex5_ram_done_d       <= or_reduce(ram_ip_q and ram_mode_q and gate(ex4_xu_val,not(ex4_xu_is_ucode_q)));
ex6_ram_issue_d      <= ram_mode_q and (ram_execute_q or ex5_ram_issue_gated) and not ex5_ram_interrupt;
ex6_ram_interrupt_d  <= or_reduce(ex5_ram_interrupt);
xu_iu_ram_issue      <= ex6_ram_issue_q;
xu_pc_ram_interrupt  <= ex6_ram_interrupt_q;
xu_pc_ram_done       <= ex6_ram_done_q;
xu_pc_step_done      <= ex6_step_done_q;

with dec_cpl_ex2_error select
   ex3_iu_error_d    <= "1000000" when "001",
                        "0100000" when "010",
                        "0010000" when "011",
                        "0001000" when "100",
                        "0000100" when "101",
                        "0000010" when "110",
                        "0000001" when "111",
                        "0000000" when others;
                        
ex4_dac1r_cmpr_async_d  <= fxu_cpl_ex3_dac1r_cmpr_async;
ex4_dac2r_cmpr_async_d  <= fxu_cpl_ex3_dac2r_cmpr_async;

ex4_dacr_cmpr_d(1)   <= fxu_cpl_ex3_dac1r_cmpr;
ex4_dacr_cmpr_d(2)   <= fxu_cpl_ex3_dac2r_cmpr;
ex4_dacr_cmpr_d(3)   <= fxu_cpl_ex3_dac3r_cmpr;
ex4_dacr_cmpr_d(4)   <= fxu_cpl_ex3_dac4r_cmpr;

ex4_dacw_cmpr_d(1)   <= fxu_cpl_ex3_dac1w_cmpr;
ex4_dacw_cmpr_d(2)   <= fxu_cpl_ex3_dac2w_cmpr;
ex4_dacw_cmpr_d(3)   <= fxu_cpl_ex3_dac3w_cmpr;
ex4_dacw_cmpr_d(4)   <= fxu_cpl_ex3_dac4w_cmpr;

ex5_is_attn_d        <= gate(ex4_xu_val,ex4_is_attn_q);

ex5_xu_ifar_d        <= mux_t(ex4_ifar_q,ex4_xu_val_q);

-------------------------------------------------------------------------------
-- Barrier Set
-------------------------------------------------------------------------------
-- These two should be mutually exclusive
ex4_lsu_barr_flush   <= ex4_barrier_flush and ex4_n_ldq_hit_flush_q;
ex4_div_barr_flush   <= ex4_barrier_flush and ex4_n_barr_flush_q;

ex5_lsu_set_barr_d   <= gate(ex4_lsu_barr_flush,not(spr_xucr4_lsu_bar_dis));
ex5_div_set_barr_d   <= gate(ex4_div_barr_flush,not(spr_xucr4_div_bar_dis));

xu_lsu_ex5_set_barr  <= ex5_lsu_set_barr_q;
cpl_fxa_ex5_set_barr <= ex5_div_set_barr_q;

ex6_set_barr_d       <= ex5_lsu_set_barr_q;  

cpl_iu_set_barr_tid   <= ex6_set_barr_q;

-------------------------------------------------------------------------------
-- Quiesce State
-------------------------------------------------------------------------------
cpl_quiesced_d          <= not(
                           ssprwr_ip_q or
                           ex5_in_ucode_q or
                           ex3_async_int_block_q or 
                           hold_state_0 or
                           hold_state_1);
                              
cpl_spr_quiesce         <= cpl_quiesced_q;

quiesced_d              <= and_reduce(spr_cpl_quiesce);
                          
-------------------------------------------------------------------------------
-- Hold Generation - per core
-------------------------------------------------------------------------------
hold_state_1            <=(others=>
                          (ici_hold_present       or
                           fu_rfpe_hold_present_q or
                           xu_rfpe_hold_present_q));        

dci_val_d               <= or_reduce(ex4_xu_val) and ex4_is_dci_q;
ici_val_d               <= or_reduce(ex4_xu_val) and ex4_is_ici_q;

ici_hold_present_d(0 to 2) <= ici_val_d & ici_hold_present_q(0 to 1);
ici_hold_present        <= or_reduce(ici_hold_present_q);

ex4_n_fu_rfpe_set       <= or_reduce(ex4_n_fu_rfpe_flush);
ex4_n_xu_rfpe_set       <= or_reduce(ex4_n_xu_rfpe_flush);

-- Put the set in the equation to force wait at least 192 cycles for a divide/slowspr to clear out
rfpe_quiesce_cond_b     <= ex4_n_fu_rfpe_set or ex4_n_xu_rfpe_set or not quiesced_q;

rfpe_quiesced           <= not rfpe_quiesce_cond_b and not rfpe_quiesced_ctr_zero_b;

rfpe_quiesce_fctr : entity work.xuq_cpl_fctr(xuq_cpl_fctr)
generic map (threads => 1, expand_type => expand_type, passthru => 0, clockgate => 0, delay_width => 8)
port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rfpe_quiesce_offset),
            scout   => sov(rfpe_quiesce_offset),
            delay   => "11000000",
            din(0)  => rfpe_quiesce_cond_b,
            dout(0) => rfpe_quiesced_ctr_zero_b);

fu_rfpe_hold_present_d  <= (ex4_n_fu_rfpe_set or fu_rfpe_hold_present_q) and not (rfpe_quiesced and fu_rf_seq_end_q);
xu_rfpe_hold_present_d  <= (ex4_n_xu_rfpe_set or xu_rfpe_hold_present_q) and not (rfpe_quiesced and xu_rf_seq_end_q);

fu_rfpe_ack_d(0)        <= fu_rfpe_hold_present_q and rfpe_quiesced;
fu_rfpe_ack_d(1)        <= fu_rfpe_ack_d(0) and not fu_rfpe_ack_q(0);
xu_fu_regfile_seq_beg   <= fu_rfpe_ack_q(1);

xu_rfpe_ack_d(0)        <= xu_rfpe_hold_present_q and rfpe_quiesced;
xu_rfpe_ack_d(1)        <= xu_rfpe_ack_d(0) and not xu_rfpe_ack_q(0);
cpl_gpr_regfile_seq_beg <= xu_rfpe_ack_q(1);

-------------------------------------------------------------------------------
-- IO assignments
-------------------------------------------------------------------------------
pc_dbg_stop             <= pc_dbg_stop_q and not (ex5_in_ucode_q or ex4_ucode_val);
cpl_spr_stop            <= pc_dbg_stop_2_q;
xu_lsu_dci              <= dci_val_q;
xu_lsu_ici              <= ici_val_q;
xu_pc_stop_dbg_event    <= (0 to threads-1=>ex5_n_ext_dbg_stopc_flush_q) or ex5_n_ext_dbg_stopt_flush_q;
ac_tc_debug_trigger     <= ex5_ext_dbg_ext_q;
xu_iu_ex5_ifar          <= ex5_xu_ifar_q;
xu_iu_ex5_br_taken      <= or_reduce(ex5_xu_val_q) and ex5_br_taken_q;
cpl_spr_ex5_instr_cpl   <= ex5_any_val_q;
spr_xucr4_mmu_mchk      <= spr_xucr4_mmu_mchk_int;

xu_iu_flush_2ucode      <= ex5_flush_2ucode_q;
xu_iu_ucode_restart     <= ex5_ucode_restart_q;
xu_iu_flush_2ucode_type <= ex5_mem_attr_le_q;

cpl_spr_ex5_act         <= ex5_late_flush_q(0) or ex6_late_flush_q;
cpl_spr_ex5_int         <= ex5_is_base_hint;
cpl_spr_ex5_gint        <= ex5_is_base_gint;
cpl_spr_ex5_cint        <= ex5_is_crit_int_q;
cpl_spr_ex5_mcint       <= ex5_is_mchk_int_q;
cpl_spr_ex5_srr0_dec    <= ex5_srr0_dec_q;
cpl_spr_ex5_force_gsrr  <= ex5_force_gsrr_q;
cpl_spr_ex5_dbsr_update <= ex5_dbsr_update_q;
cpl_spr_ex5_esr         <= ex5_esr_q; 
cpl_spr_ex5_mcsr        <= ex5_mcsr_q;
cpl_spr_ex5_dbsr        <= ex5_dbsr_q;
cpl_spr_ex5_dbell_taken     <= ex5_dbell_taken_q;
cpl_spr_ex5_cdbell_taken    <= ex5_cdbell_taken_q;
cpl_spr_ex5_gdbell_taken    <= ex5_gdbell_taken_q;
cpl_spr_ex5_gcdbell_taken   <= ex5_gcdbell_taken_q;
cpl_spr_ex5_gmcdbell_taken  <= ex5_gmcdbell_taken_q;

cpl_dec_in_ucode      <= ex5_in_ucode_q;

cpl_msr_gs            <= msr_gs_q;
cpl_msr_pr            <= msr_pr_q;
cpl_msr_fp            <= msr_fp_q;
cpl_msr_spv           <= msr_spv_q;
cpl_ccr2_ap           <= ccr2_ap_q;

-------------------------------------------------------------------------------
-- Performance Counters
-------------------------------------------------------------------------------
ex2_perf_event_d(0)        <= ex1_branch;
ex2_perf_event_d(1)        <= ex1_br_mispred;
ex2_perf_event_d(2)        <= ex1_br_taken;

ex4_perf_event_d(0)        <= ex3_perf_event_q(0);
ex4_perf_event_d(1)        <= ex3_perf_event_q(1);
ex4_perf_event_d(2)        <= ex3_perf_event_q(2);
ex4_perf_event_d(3)        <= or_reduce(ex3_n_multcoll_flush);

-------------------------------------------------------------------------------
-- SIAR
-------------------------------------------------------------------------------
ex4_xu_siar_val            <= or_reduce(ex4_xuuc_val   and not ex5_in_ucode_q);
ex4_axu_siar_val           <= or_reduce(ex4_axu_val    and not ex5_in_ucode_q);
ex4_siar_cpl               <=          (ex4_instr_cpl  and not ex5_in_ucode_q) or ex4_ucode_val;

-- Kill the issued bit if the IU issued an Error.  The IFAR is invalid in this case.
ex3_xu_issued              <= gate(ex3_xu_issued_q,not(or_reduce(ex3_iu_error_q)));

ex4_siar_sel_act           <= ex4_xu_siar_val and ex4_axu_siar_val and trace_bus_enable_q;
ex4_siar_sel_d(0 to 1)     <= ex4_siar_sel_q(1) & ex4_siar_sel_q(0);

with ex4_siar_sel_act select
   ex4_siar_axu_sel        <= ex4_siar_sel_q(1)    when '1',      -- Tiebreaker
                              ex4_axu_siar_val     when others;
                              
with (ex4_siar_axu_sel and not ex4_instr_trace_val_q) select
   ex4_siar_tid            <=  ex4_axu_issued_q                      when '1',
                               ex4_xu_issued_q                       when others;

with (ex4_siar_axu_sel and not ex4_instr_trace_val_q) select
   ex4_siar_sel            <= (ex4_axu_val_q  and not ex5_in_ucode_q)   when '1',
                              (ex4_xuuc_val_q and not ex5_in_ucode_q)   when others;


ex4_siar_cm_mask(32 to 61)      <= (others=>'1');
xuq_cpl_siar_cm_mask_gen : if IFAR'left < 32 generate
   ex4_siar_cm_mask(IFAR'left to 31)      <= (others=>or_reduce(msr_cm_q and ex4_siar_sel));
end generate;
ex5_siar_d                 <= ex4_siar_cm_mask and mux_t(ex4_ifar_q,ex4_siar_sel);
ex5_siar_gs_d              <= or_reduce(msr_gs_q      and ex4_siar_sel);
ex5_siar_pr_d              <= or_reduce(msr_pr_q      and ex4_siar_sel);
ex5_siar_cpl_d             <= or_reduce(ex4_siar_cpl  and ex4_siar_sel);
ex5_siar_issued_d          <= or_reduce(ex4_siar_tid);
with s4'(ex4_siar_cpl  and ex4_siar_sel) select
   ex5_siar_tid_d          <= "00"  when "1000",
                              "01"  when "0100",
                              "10"  when "0010",
                              "11"  when others;
                              
mark_unused(ex5_siar_issued_q);

-------------------------------------------------------------------------------
-- Debug
-------------------------------------------------------------------------------
-- NOTE: The following bits can be muxed onto the perf event bus:
--          0:15, 22:36, 44:59, 66:81

-- Rotates on  0:21, 22:43, 44:65, 66:87

dbg_subgroup_gen : for t in 0 to threads-1 generate
dbg_valids_opc(t)(0 to 4) <= ex5_xu_val_dbg_opc(t) & ex5_axu_val_dbg_opc(t) & ex5_instr_cpl_dbg_q(t) & ex5_ucode_val_dbg_q(t) & ex5_ucode_end_dbg_q(t);
dbg_valids(t)(0 to 4)   <= ex5_xu_val_q(t) & ex5_axu_val_dbg_q(t) & ex5_instr_cpl_dbg_q(t) & ex5_ucode_val_dbg_q(t) & ex5_ucode_end_dbg_q(t);
dbg_iuflush(t)(0 to 8)  <= ex2_br_flush(t) & iu_flush(t) & ex5_is_any_hint(t) & ex5_is_any_gint(t) & ex5_ucode_restart_q(t) & ex5_flush_2ucode_q(t) & ex5_mem_attr_le_q(t) & hold_state_0(t) & hold_state_1(t);
dbg_msr(t)(0 to 4)      <= msr_de_q(t) & msr_cm_q(t) & msr_gs_q(t) & msr_me_q(t) & msr_pr_q(t);
dbg_match(t)(0)         <= ex5_dbsr_q(18+19*t);
dbg_match(t)(1)         <= ex5_dbsr_q(5+19*t)  or ex5_dbsr_q(6+19*t)  or ex5_dbsr_q(7+19*t)  or ex5_dbsr_q(8+19*t);
dbg_match(t)(2)         <= ex5_dbsr_q(9+19*t)  or ex5_dbsr_q(10+19*t) or ex5_dbsr_q(11+19*t) or ex5_dbsr_q(12+19*t) or
                           ex5_dbsr_q(14+19*t) or ex5_dbsr_q(15+19*t) or ex5_dbsr_q(16+19*t) or ex5_dbsr_q(17+19*t);                                                      
dbg_flushcond_d(t)(00)  <= ex3_n_lsu_ddpe_flush(t);

dbg_flushcond_d(t)(01)  <= ex3_n_barr_flush(t);

dbg_flushcond_d(t)(02)  <= ex3_n_l2_ecc_err_flush_q(t);
dbg_flushcond_d(t)(03)  <= ex3_n_dcpe_flush_q(t);
dbg_flushcond_d(t)(04)  <= ex3_n_dlk0_dstor_int(t);
dbg_flushcond_d(t)(05)  <= ex3_n_dlk1_dstor_int(t);
dbg_flushcond_d(t)(06)  <= ex3_n_ieratre_par_mchk_mcint(t);
dbg_flushcond_d(t)(07)  <= ex3_np1_sprg_ce_flush(t);
dbg_flushcond_d(t)(08)  <= ex3_n_2ucode_flush(t);
dbg_flushcond_d(t)(09)  <= ex3_n_lsualign_2ucode_flush(t);
dbg_flushcond_d(t)(10)  <= ex3_n_fu_2ucode_flush(t);
dbg_flushcond_d(t)(11)  <= ex3_n_mmuhold_flush(t);
dbg_flushcond_d(t)(12)  <= ex3_n_lsu_dcpe_flush(t);
dbg_flushcond_d(t)(13)  <= ex5_n_ext_dbg_stopc_flush_q;
dbg_flushcond_d(t)(14)  <= ex5_n_ext_dbg_stopt_flush_q(t);
dbg_flushcond_d(t)(15)  <= ex3_n_dci_flush(t);
dbg_flushcond_d(t)(16)  <= ex3_n_ici_flush(t);
dbg_flushcond_d(t)(17)  <= ex3_n_multcoll_flush(t);
dbg_flushcond_d(t)(18)  <= ex3_n_ram_flush(t);
dbg_flushcond_d(t)(19)  <= ex3_n_derat_dep_flush(t);
dbg_flushcond_d(t)(20)  <= ex3_n_lsu_dep_flush(t);
dbg_flushcond_d(t)(21)  <= ex3_n_dep_flush(t);
dbg_flushcond_d(t)(22)  <= ex3_n_thrctl_stop_flush(t);
dbg_flushcond_d(t)(23)  <= ex3_n_bclr_ta_miscmpr_flush(t);
dbg_flushcond_d(t)(24)  <= ex3_n_memattr_miscmpr_flush(t);
dbg_flushcond_d(t)(25)  <= ex3_np1_instr_flush(t);
dbg_flushcond_d(t)(26)  <= ex3_n_ldq_hit_flush(t);
dbg_flushcond_d(t)(27)  <= ex3_np1_fu_flush(t);
dbg_flushcond_d(t)(28)  <= ex3_n_fu_dep_flush(t);
dbg_flushcond_d(t)(29)  <= ex3_n_mmu_flush(t);
dbg_flushcond_d(t)(30)  <= ex3_n_tlbmiss_dtlb_int(t);
dbg_flushcond_d(t)(31)  <= ex3_n_deratmiss_dtlb_int(t);
dbg_flushcond_d(t)(32)  <= ex3_n_tlbmiss_itlb_int(t);
dbg_flushcond_d(t)(33)  <= ex3_n_ieratmiss_itlb_int(t);
dbg_flushcond_d(t)(34)  <= ex3_n_apena_prog_int(t);
dbg_flushcond_d(t)(35)  <= ex3_n_fpena_prog_int(t);
dbg_flushcond_d(t)(36)  <= ex3_n_tlbpil_prog_int_xu(t)          and ex3_xu_val(t);
dbg_flushcond_d(t)(37)  <= ex3_n_sprpil_prog_int_xu(t)          and ex3_xu_val(t);
dbg_flushcond_d(t)(38)  <= ex3_n_iupil_prog_int_xuuc(t)         and ex3_xuuc_val(t);
dbg_flushcond_d(t)(39)  <= ex3_n_mmupil_prog_int_xu(t)          and ex3_xu_val(t);
dbg_flushcond_d(t)(40)  <= ex3_n_xupil_prog_int_xuuc(t)         and ex3_xuuc_val(t);
dbg_flushcond_d(t)(41)  <= ex3_n_puo_prog_int(t);
dbg_flushcond_d(t)(42)  <= ex3_n_sprppr_prog_int_xuuc(t)        and ex3_xuuc_val(t);
dbg_flushcond_d(t)(43)  <= ex3_n_instrppr_prog_int_xuuc(t)      and ex3_xuuc_val(t);
dbg_flushcond_d(t)(44)  <= ex3_np1_ptr_prog_int(t);
dbg_flushcond_d(t)(45)  <= ex3_n_any_unavail_int(t);
dbg_flushcond_d(t)(46)  <= ex3_n_ldst_align_int(t);
dbg_flushcond_d(t)(47)  <= ex3_n_ldstmw_align_int(t);
dbg_flushcond_d(t)(48)  <= ex3_n_vf_dstor_int(t);
dbg_flushcond_d(t)(49)  <= ex3_n_tlbi_dstor_int(t);
dbg_flushcond_d(t)(50)  <= ex3_n_i1w1lock_dstor_int(t);
dbg_flushcond_d(t)(51)  <= ex3_n_rwaccess_dstor_int(t);
dbg_flushcond_d(t)(52)  <= ex3_n_uct_dstor_int(t);
dbg_flushcond_d(t)(53)  <= ex3_n_pt_dstor_int(t);
dbg_flushcond_d(t)(54)  <= ex3_n_tlbi_istor_int(t);
dbg_flushcond_d(t)(55)  <= ex3_n_exaccess_istor_int(t);
dbg_flushcond_d(t)(56)  <= ex3_n_pt_istor_int(t);
dbg_flushcond_d(t)(57)  <= ex3_np1_instr_int(t);
dbg_flushcond_d(t)(58)  <= ex3_n_ptemiss_dlrat_int(t);
dbg_flushcond_d(t)(59)  <= ex3_n_tlbwemiss_dlrat_int(t);
dbg_flushcond_d(t)(60)  <= ex3_n_spr_hpriv_int_xuuc(t)          and ex3_xuuc_val(t);
dbg_flushcond_d(t)(61)  <= ex3_n_instr_hpriv_int_xuuc(t)        and ex3_xuuc_val(t);
dbg_flushcond_d(t)(62)  <= ex3_n_mmu_hpriv_int(t);
dbg_flushcond_d(t)(63)  <= ex3_n_ehpriv_hpriv_int(t);


dbg_hold(t)(0 to 5)        <= mmu_hold_present_q(t) & derat_hold_present_q(t) & ierat_hold_present_q(t) & ici_hold_present & fu_rfpe_hold_present_q & xu_rfpe_hold_present_q;
dbg_async_block(t)(0 to 6) <= ssprwr_ip_q(t) & ex5_in_ucode_q(t) & ram_mode_q(t) & ex3_async_int_block_q(t) & ex4_icmp_async_block(t) & exx_hold0_mcflush(t) & exx_hold1_mcflush(t);
dbg_int_types(t)(0 to 4)   <= ex4_is_mchk_int(t) & ex4_is_crit_int(t) & ex5_is_any_hint(t) & ex5_is_any_gint(t) & ex5_is_any_rfi_q(t);
dbg_misc(t)(0 to 3)        <= ex5_tlb_inelig_q(t) & ex5_dear_update_saved_q(t) & exx_cm_hold(t) & ex3_esr_bit_act(t);


end generate;

ex5_xu_ppc_cpl             <= (ex5_xu_val_q      and not (ex5_in_ucode_q or ex5_ucode_end_dbg_q)) or ex5_ucode_val_dbg_q;
ex5_axu_ppc_cpl            <= (ex5_axu_val_dbg_q and not (ex5_in_ucode_q or ex5_ucode_end_dbg_q));

ex5_axu_trace_val          <=    instr_trace_mode_q and or_reduce(ex5_axu_ppc_cpl);
ex5_xu_trace_val           <= ex5_instr_trace_val_q and or_reduce(ex5_xu_ppc_cpl);

siar_cm(0)        <= msr_cm_q(0) and not ex5_instr_trace_val_q;
siar_cm(1 to 2)   <= msr_cm_q(1 to 2);
siar_cm(3)        <=(msr_cm_q(3) and not ex5_instr_trace_val_q) or ex5_xu_trace_val;

--                0:4                 5                   6:11                    12:73             74:82         83:87
dbg_group0  <= dbg_valids(0) & ex5_in_ucode_q(0) & ex5_flush_pri_enc_dbg(0) & ex4_cia_out(0) & dbg_iuflush(0) & dbg_msr(0);
dbg_group1  <= dbg_valids(1) & ex5_in_ucode_q(1) & ex5_flush_pri_enc_dbg(1) & ex4_cia_out(1) & dbg_iuflush(1) & dbg_msr(1);
dbg_group2  <= dbg_valids(2) & ex5_in_ucode_q(2) & ex5_flush_pri_enc_dbg(2) & ex4_cia_out(2) & dbg_iuflush(2) & dbg_msr(2);
dbg_group3  <= dbg_valids(3) & ex5_in_ucode_q(3) & ex5_flush_pri_enc_dbg(3) & ex4_cia_out(3) & dbg_iuflush(3) & dbg_msr(3);
--                 0:4             5:9            10:14            15:19         20:23              24:30                31:41                  42:55              56:63                   64:71                         72:79                     80:87
dbg_group4  <= dbg_valids_opc(0) & dbg_valids_opc(1) & dbg_valids_opc(2) & dbg_valids_opc(3) & ex5_in_ucode_q & ex1_instr(0 to 6) & ex1_instr(21 to 31) & ex1_instr(7 to 20) & ex4_cia_out(0)(54 to 61) & ex4_cia_out(1)(54 to 61) & ex4_cia_out(2)(54 to 61) & ex4_cia_out(3)(54 to 61);
--                0:4                 5                   6:11                       12:75                       76:82                 83:87
dbg_group5  <= dbg_valids(0) & ex5_in_ucode_q(0) & ex5_flush_pri_enc_dbg(0) & dbg_flushcond_q(0)(0 to 63) & dbg_iuflush(0)(0 to 6) & dbg_msr(0);
dbg_group6  <= dbg_valids(1) & ex5_in_ucode_q(1) & ex5_flush_pri_enc_dbg(1) & dbg_flushcond_q(1)(0 to 63) & dbg_iuflush(1)(0 to 6) & dbg_msr(1);
dbg_group7  <= dbg_valids(2) & ex5_in_ucode_q(2) & ex5_flush_pri_enc_dbg(2) & dbg_flushcond_q(2)(0 to 63) & dbg_iuflush(2)(0 to 6) & dbg_msr(2);
dbg_group8  <= dbg_valids(3) & ex5_in_ucode_q(3) & ex5_flush_pri_enc_dbg(3) & dbg_flushcond_q(3)(0 to 63) & dbg_iuflush(3)(0 to 6) & dbg_msr(3);
--                0:4                 5                   6:11                  12:20               21:52
dbg_group9  <= dbg_valids(0) & ex5_in_ucode_q(0) & ex5_flush_pri_enc_dbg(0) & dbg_iuflush(0) & ex1_instr(0 to 31) & 
               dbg_hold(0)(0 to 5) & dbg_async_block(0)(0 to 6) & dbg_int_types(0)(0 to 4) & dbg_misc(0)(0 to 3) &  -- 53:75
               br_debug & '0'; -- 76:87

dbg_group10 <= dbg_valids(1) & ex5_in_ucode_q(1) & ex5_flush_pri_enc_dbg(1) & dbg_iuflush(1) & ex1_instr(0 to 31) & 
               dbg_hold(1)(0 to 5) & dbg_async_block(1)(0 to 6) & dbg_int_types(1)(0 to 4) & dbg_misc(1)(0 to 3) &  -- 53:75
               br_debug & '0'; -- 76:87

dbg_group11 <= dbg_valids(2) & ex5_in_ucode_q(2) & ex5_flush_pri_enc_dbg(2) & dbg_iuflush(2) & ex1_instr(0 to 31) & 
               dbg_hold(2)(0 to 5) & dbg_async_block(2)(0 to 6) & dbg_int_types(2)(0 to 4) & dbg_misc(2)(0 to 3) &  -- 53:75
               br_debug & '0'; -- 76:87

dbg_group12 <= dbg_valids(3) & ex5_in_ucode_q(3) & ex5_flush_pri_enc_dbg(3) & dbg_iuflush(3) & ex1_instr(0 to 31) & 
               dbg_hold(3)(0 to 5) & dbg_async_block(3)(0 to 6) & dbg_int_types(3)(0 to 4) & dbg_misc(3)(0 to 3) &  -- 53:75
               br_debug & '0'; -- 76:87
               
--               0:61            62              63          64:67           68                69               70:71          72:75              76:79              80:83                84:87
dbg_group13 <= ex5_siar_q & ex5_siar_gs_q & ex5_siar_pr_q & siar_cm & ex5_siar_cpl_q & ex5_siar_cpl_q & ex5_siar_tid_q & ex4_xu_issued_q & ex4_axu_issued_q & ex5_instr_cpl_q & ex5_ucode_val_dbg_q;
--               0:31               32:55    56          57:58                59:63          64           65:66             67
dbg_group14 <= ex2_instr_dbg_q & x"0ABCDE" & '1' & ex2_instr_trace_type_q & (59 to 63=>'0') & '1' & ex2_instr_trace_type_q & '1' & (68 to 87=>'0');
--                   0:31               32:36             37                    38:43                 44              45
dbg_group15 <= ex1_instr(0 to 31) & dbg_valids(0) & ex5_in_ucode_q(0) & ex5_flush_pri_enc_dbg(0) & iu_flush(0) & ex5_ucode_restart_q(0) &
                                    dbg_valids(1) & ex5_in_ucode_q(1) & ex5_flush_pri_enc_dbg(1) & iu_flush(1) & ex5_ucode_restart_q(1) &
                                    dbg_valids(2) & ex5_in_ucode_q(2) & ex5_flush_pri_enc_dbg(2) & iu_flush(2) & ex5_ucode_restart_q(2) &
                                    dbg_valids(3) & ex5_in_ucode_q(3) & ex5_flush_pri_enc_dbg(3) & iu_flush(3) & ex5_ucode_restart_q(3);
dbg_group16 <= (others=>'0');
dbg_group17 <= (others=>'0');
dbg_group18 <= (others=>'0');
dbg_group19 <= (others=>'0');
dbg_group20 <= (others=>'0');
dbg_group21 <= (others=>'0');
dbg_group22 <= (others=>'0');
dbg_group23 <= (others=>'0');
dbg_group24 <= (others=>'0');
dbg_group25 <= (others=>'0');
dbg_group26 <= (others=>'0');
dbg_group27 <= (others=>'0');
dbg_group28 <= fxa_cpl_debug(0 to 87);
dbg_group29 <= fxa_cpl_debug(88 to 175);
dbg_group30 <= fxa_cpl_debug(207 to 272) & fxa_cpl_debug(176 to 197);
dbg_group31 <= fxa_cpl_debug(198 to 272) & ex5_xu_ifar_q(49 to 61);
trg_group0  <= dbg_valids(0)(0 to 4) & dbg_iuflush(0)(0 to 3) & dbg_match(0)(0 to 2);
trg_group1  <= dbg_valids(1)(0 to 4) & dbg_iuflush(1)(0 to 3) & dbg_match(1)(0 to 2);
trg_group2  <= dbg_valids(2)(0 to 4) & dbg_iuflush(2)(0 to 3) & dbg_match(2)(0 to 2);
trg_group3  <= dbg_valids(3)(0 to 4) & dbg_iuflush(3)(0 to 3) & dbg_match(3)(0 to 2);

-- fxa_group0( 0:87)    (88) Instruction / Mult/Div
-- fxa_group1(88:175)   (88) Issue Interface
-- fxa_group2(176:197)  (22) GPR Parity Error
-- fxa_group3(198:263)  (66) Reload Write Data
-- fxa_group4(264:272)  (09) Reload Write Addr/Valid


with s2'(ex1_instr_trace_val_q & ex4_instr_trace_val_q) select
   debug_mux_ctrls_int     <= x"71E0"              when "10",  -- Group 14
                              x"69E0"              when "01",  -- Group 13
                              debug_mux_ctrls_q    when others;


cpl_debug_data_in_int(0 to 55)   <= cpl_debug_data_in(0 to 55);
cpl_debug_data_in_int(56)        <= cpl_debug_data_in(56)         or ex5_axu_trace_val;
cpl_debug_data_in_int(57 to 63)  <= cpl_debug_data_in(57 to 63);
cpl_debug_data_in_int(64)        <= cpl_debug_data_in(64)         or ex5_axu_trace_val;
cpl_debug_data_in_int(65 to 66)  <= cpl_debug_data_in(65 to 66);
cpl_debug_data_in_int(67)        <= cpl_debug_data_in(67)         or ex5_axu_trace_val;
cpl_debug_data_in_int(68 to 87)  <= cpl_debug_data_in(68 to 87);

xu_debug_mux : entity clib.c_debug_mux32(c_debug_mux32)
port map(
   vd                => vdd,
   gd                => gnd,
   select_bits       => debug_mux_ctrls_int_q,
   trace_data_in     => cpl_debug_data_in_int,
   trigger_data_in   => cpl_trigger_data_in,
   dbg_group0        => dbg_group0,
   dbg_group1        => dbg_group1,
   dbg_group2        => dbg_group2,
   dbg_group3        => dbg_group3,
   dbg_group4        => dbg_group4,
   dbg_group5        => dbg_group5,
   dbg_group6        => dbg_group6,
   dbg_group7        => dbg_group7,
   dbg_group8        => dbg_group8,
   dbg_group9        => dbg_group9,
   dbg_group10       => dbg_group10,
   dbg_group11       => dbg_group11,
   dbg_group12       => dbg_group12,
   dbg_group13       => dbg_group13,
   dbg_group14       => dbg_group14,
   dbg_group15       => dbg_group15,
   dbg_group16       => dbg_group16,
   dbg_group17       => dbg_group17,
   dbg_group18       => dbg_group18,
   dbg_group19       => dbg_group19,
   dbg_group20       => dbg_group20,
   dbg_group21       => dbg_group21,
   dbg_group22       => dbg_group22,
   dbg_group23       => dbg_group23,
   dbg_group24       => dbg_group24,
   dbg_group25       => dbg_group25,
   dbg_group26       => dbg_group26,
   dbg_group27       => dbg_group27,
   dbg_group28       => dbg_group28,
   dbg_group29       => dbg_group29,
   dbg_group30       => dbg_group30,
   dbg_group31       => dbg_group31,
   trg_group0        => trg_group0,
   trg_group1        => trg_group1,
   trg_group2        => trg_group2,
   trg_group3        => trg_group3,
   trigger_data_out  => trigger_data_out_d,
   trace_data_out    => debug_data_out_d);

cpl_trigger_data_out <= trigger_data_out_q;
cpl_debug_data_out   <= debug_data_out_q;


-- Unused Signals
mark_unused(ex3_iu_error_q(3));
mark_unused(spare_0_q);
mark_unused(spare_1_q);
mark_unused(spare_2_q);
mark_unused(spare_3_q);
mark_unused(spare_4_q);


-------------------------------------------------------------------------------
-- Latches
-------------------------------------------------------------------------------
is2_flush_latch : tri_rlmreg_p
  generic map (width => is2_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(is2_flush_offset to is2_flush_offset + is2_flush_q'length-1),
            scout   => sov(is2_flush_offset to is2_flush_offset + is2_flush_q'length-1),
            din     => any_flush                  ,
            dout    => is2_flush_q);
rf0_flush_latch : tri_rlmreg_p
  generic map (width => rf0_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rf0_flush_offset to rf0_flush_offset + rf0_flush_q'length-1),
            scout   => sov(rf0_flush_offset to rf0_flush_offset + rf0_flush_q'length-1),
            din     => is2_flush                  ,
            dout    => rf0_flush_q);
rf1_flush_latch : tri_rlmreg_p
  generic map (width => rf1_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rf1_flush_offset to rf1_flush_offset + rf1_flush_q'length-1),
            scout   => sov(rf1_flush_offset to rf1_flush_offset + rf1_flush_q'length-1),
            din     => rf0_flush                  ,
            dout    => rf1_flush_q);
rf1_tid_latch : tri_rlmreg_p
  generic map (width => rf1_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rf1_tid_offset to rf1_tid_offset + rf1_tid_q'length-1),
            scout   => sov(rf1_tid_offset to rf1_tid_offset + rf1_tid_q'length-1),
            din     => dec_cpl_rf0_tid            ,
            dout    => rf1_tid_q);
ex1_axu_act_latch : tri_rlmreg_p
  generic map (width => ex1_axu_act_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_axu_act_offset to ex1_axu_act_offset + ex1_axu_act_q'length-1),
            scout   => sov(ex1_axu_act_offset to ex1_axu_act_offset + ex1_axu_act_q'length-1),
            din     => fu_xu_rf1_act              ,
            dout    => ex1_axu_act_q);
ex1_byte_rev_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_byte_rev_offset),
            scout   => sov(ex1_byte_rev_offset),
            din     => rf1_byte_rev,
            dout    => ex1_byte_rev_q);
ex1_flush_latch : tri_rlmreg_p
  generic map (width => ex1_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_flush_offset to ex1_flush_offset + ex1_flush_q'length-1),
            scout   => sov(ex1_flush_offset to ex1_flush_offset + ex1_flush_q'length-1),
            din     => rf1_flush                  ,
            dout    => ex1_flush_q);
ex1_is_any_ldstmw_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_any_ldstmw_offset),
            scout   => sov(ex1_is_any_ldstmw_offset),
            din     => rf1_is_any_ldstmw,
            dout    => ex1_is_any_ldstmw_q);
ex1_is_attn_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_attn_offset),
            scout   => sov(ex1_is_attn_offset),
            din     => rf1_is_attn,
            dout    => ex1_is_attn_q);
ex1_is_dci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_dci_offset),
            scout   => sov(ex1_is_dci_offset),
            din     => ex1_is_dci_d,
            dout    => ex1_is_dci_q);
ex1_is_dlock_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_dlock_offset),
            scout   => sov(ex1_is_dlock_offset),
            din     => rf1_is_dlock,
            dout    => ex1_is_dlock_q);
ex1_is_ehpriv_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_ehpriv_offset),
            scout   => sov(ex1_is_ehpriv_offset),
            din     => rf1_is_ehpriv,
            dout    => ex1_is_ehpriv_q);
ex1_is_erativax_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_erativax_offset),
            scout   => sov(ex1_is_erativax_offset),
            din     => rf1_is_erativax,
            dout    => ex1_is_erativax_q);
ex1_is_ici_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_ici_offset),
            scout   => sov(ex1_is_ici_offset),
            din     => ex1_is_ici_d,
            dout    => ex1_is_ici_q);
ex1_is_icswx_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_icswx_offset),
            scout   => sov(ex1_is_icswx_offset),
            din     => rf1_is_icswx,
            dout    => ex1_is_icswx_q);
ex1_is_ilock_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_ilock_offset),
            scout   => sov(ex1_is_ilock_offset),
            din     => rf1_is_ilock,
            dout    => ex1_is_ilock_q);
ex1_is_isync_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_isync_offset),
            scout   => sov(ex1_is_isync_offset),
            din     => rf1_is_isync,
            dout    => ex1_is_isync_q);
ex1_is_mfspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_mfspr_offset),
            scout   => sov(ex1_is_mfspr_offset),
            din     => rf1_is_mfspr,
            dout    => ex1_is_mfspr_q);
ex1_is_mtmsr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_mtmsr_offset),
            scout   => sov(ex1_is_mtmsr_offset),
            din     => rf1_is_mtmsr,
            dout    => ex1_is_mtmsr_q);
ex1_is_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_mtspr_offset),
            scout   => sov(ex1_is_mtspr_offset),
            din     => rf1_is_mtspr,
            dout    => ex1_is_mtspr_q);
ex1_is_rfci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_rfci_offset),
            scout   => sov(ex1_is_rfci_offset),
            din     => rf1_is_rfci,
            dout    => ex1_is_rfci_q);
ex1_is_rfgi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_rfgi_offset),
            scout   => sov(ex1_is_rfgi_offset),
            din     => rf1_is_rfgi,
            dout    => ex1_is_rfgi_q);
ex1_is_rfi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_rfi_offset),
            scout   => sov(ex1_is_rfi_offset),
            din     => rf1_is_rfi,
            dout    => ex1_is_rfi_q);
ex1_is_rfmci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_rfmci_offset),
            scout   => sov(ex1_is_rfmci_offset),
            din     => rf1_is_rfmci,
            dout    => ex1_is_rfmci_q);
ex1_is_sc_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_sc_offset),
            scout   => sov(ex1_is_sc_offset),
            din     => rf1_is_sc,
            dout    => ex1_is_sc_q);
ex1_is_tlbivax_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_tlbivax_offset),
            scout   => sov(ex1_is_tlbivax_offset),
            din     => rf1_is_tlbivax,
            dout    => ex1_is_tlbivax_q);
ex1_is_wrtee_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_wrtee_offset),
            scout   => sov(ex1_is_wrtee_offset),
            din     => rf1_is_wrtee,
            dout    => ex1_is_wrtee_q);
ex1_is_wrteei_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_wrteei_offset),
            scout   => sov(ex1_is_wrteei_offset),
            din     => rf1_is_wrteei,
            dout    => ex1_is_wrteei_q);
ex1_is_mtxucr0_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_mtxucr0_offset),
            scout   => sov(ex1_is_mtxucr0_offset),
            din     => rf1_is_mtxucr0,
            dout    => ex1_is_mtxucr0_q);
ex1_is_tlbwe_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_tlbwe_offset),
            scout   => sov(ex1_is_tlbwe_offset),
            din     => rf1_is_tlbwe,
            dout    => ex1_is_tlbwe_q);
ex1_sc_lev_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_sc_lev_offset),
            scout   => sov(ex1_sc_lev_offset),
            din     => rf1_sc_lev,
            dout    => ex1_sc_lev_q);
ex1_ucode_val_latch : tri_rlmreg_p
  generic map (width => ex1_ucode_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_ucode_val_offset to ex1_ucode_val_offset + ex1_ucode_val_q'length-1),
            scout   => sov(ex1_ucode_val_offset to ex1_ucode_val_offset + ex1_ucode_val_q'length-1),
            din     => rf1_ucode_val              ,
            dout    => ex1_ucode_val_q);
ex1_xu_val_latch : tri_rlmreg_p
  generic map (width => ex1_xu_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_xu_val_offset to ex1_xu_val_offset + ex1_xu_val_q'length-1),
            scout   => sov(ex1_xu_val_offset to ex1_xu_val_offset + ex1_xu_val_q'length-1),
            din     => rf1_xu_val                 ,
            dout    => ex1_xu_val_q);
ex2_axu_act_latch : tri_regk
  generic map (width => ex2_axu_act_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_axu_act_q              ,
            dout    => ex2_axu_act_q);
ex2_any_wrtee_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_any_wrtee_d,
            dout(0) => ex2_any_wrtee_q);
ex2_br_taken_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_br_taken               ,
            dout(0) => ex2_br_taken_q);
ex2_br_update_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_br_update              ,
            dout(0) => ex2_br_update_q);
ex2_byte_rev_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_byte_rev_q             ,
            dout(0) => ex2_byte_rev_q);
ex2_ctr_dec_update_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_ctr_dec_update         ,
            dout(0) => ex2_ctr_dec_update_q);
ex2_epid_instr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => dec_cpl_ex1_epid_instr     ,
            dout(0) => ex2_epid_instr_q);
ex2_flush_latch : tri_rlmreg_p
  generic map (width => ex2_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_flush_offset to ex2_flush_offset + ex2_flush_q'length-1),
            scout   => sov(ex2_flush_offset to ex2_flush_offset + ex2_flush_q'length-1),
            din     => ex1_flush                  ,
            dout    => ex2_flush_q);
ex2_is_attn_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_attn_q              ,
            dout(0) => ex2_is_attn_q);
ex2_is_dci_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_dci_q               ,
            dout(0) => ex2_is_dci_q);
ex2_is_dlock_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_dlock_q             ,
            dout(0) => ex2_is_dlock_q);
ex2_is_ehpriv_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_ehpriv_q            ,
            dout(0) => ex2_is_ehpriv_q);
ex2_is_erativax_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_erativax_q          ,
            dout(0) => ex2_is_erativax_q);
ex2_is_ici_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_ici_q               ,
            dout(0) => ex2_is_ici_q);
ex2_is_icswx_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_icswx_q             ,
            dout(0) => ex2_is_icswx_q);
ex2_is_ilock_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_ilock_q             ,
            dout(0) => ex2_is_ilock_q);
ex2_is_isync_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_isync_q             ,
            dout(0) => ex2_is_isync_q);
ex2_is_mtmsr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_mtmsr_q             ,
            dout(0) => ex2_is_mtmsr_q);
ex2_is_rfci_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_rfci_q              ,
            dout(0) => ex2_is_rfci_q);
ex2_is_rfgi_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_rfgi_q              ,
            dout(0) => ex2_is_rfgi_q);
ex2_is_rfi_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_rfi_q               ,
            dout(0) => ex2_is_rfi_q);
ex2_is_rfmci_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_rfmci_q             ,
            dout(0) => ex2_is_rfmci_q);
ex2_is_sc_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_sc_q                ,
            dout(0) => ex2_is_sc_q);
ex2_is_slowspr_wr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => dec_cpl_ex1_is_slowspr_wr  ,
            dout(0) => ex2_is_slowspr_wr_q);
ex2_is_tlbivax_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_tlbivax_q           ,
            dout(0) => ex2_is_tlbivax_q);
ex2_is_tlbwe_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_tlbwe_q             ,
            dout(0) => ex2_is_tlbwe_q);
ex2_lr_update_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_lr_update              ,
            dout(0) => ex2_lr_update_q);
ex2_n_align_int_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_n_align_int_d,
            dout(0) => ex2_n_align_int_q);
ex2_sc_lev_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_sc_lev_q               ,
            dout(0) => ex2_sc_lev_q);
ex2_taken_bclr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_taken_bclr             ,
            dout(0) => ex2_taken_bclr_q);
ex2_ucode_val_latch : tri_rlmreg_p
  generic map (width => ex2_ucode_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_ucode_val_offset to ex2_ucode_val_offset + ex2_ucode_val_q'length-1),
            scout   => sov(ex2_ucode_val_offset to ex2_ucode_val_offset + ex2_ucode_val_q'length-1),
            din     => ex1_ucode_val              ,
            dout    => ex2_ucode_val_q);
ex2_xu_val_latch : tri_rlmreg_p
  generic map (width => ex2_xu_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_xu_val_offset to ex2_xu_val_offset + ex2_xu_val_q'length-1),
            scout   => sov(ex2_xu_val_offset to ex2_xu_val_offset + ex2_xu_val_q'length-1),
            din     => ex1_xu_val                 ,
            dout    => ex2_xu_val_q);
ex2_is_mtxucr0_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)            ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_is_mtxucr0_q          ,
            dout(0) => ex2_is_mtxucr0_q);
ex3_async_int_block_latch : tri_rlmreg_p
  generic map (width => ex3_async_int_block_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_async_int_block_offset to ex3_async_int_block_offset + ex3_async_int_block_q'length-1),
            scout   => sov(ex3_async_int_block_offset to ex3_async_int_block_offset + ex3_async_int_block_q'length-1),
            din     => ex3_async_int_block_d,
            dout    => ex3_async_int_block_q);
ex3_axu_instr_match_latch : tri_rlmreg_p
  generic map (width => ex3_axu_instr_match_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex2_axu_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_axu_instr_match_offset to ex3_axu_instr_match_offset + ex3_axu_instr_match_q'length-1),
            scout   => sov(ex3_axu_instr_match_offset to ex3_axu_instr_match_offset + ex3_axu_instr_match_q'length-1),
            din     => fu_xu_ex2_instr_match      ,
            dout    => ex3_axu_instr_match_q);
ex3_axu_instr_type_latch : tri_rlmreg_p
  generic map (width => ex3_axu_instr_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex2_axu_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_axu_instr_type_offset to ex3_axu_instr_type_offset + ex3_axu_instr_type_q'length-1),
            scout   => sov(ex3_axu_instr_type_offset to ex3_axu_instr_type_offset + ex3_axu_instr_type_q'length-1),
            din     => fu_xu_ex2_instr_type       ,
            dout    => ex3_axu_instr_type_q);
ex3_axu_is_ucode_latch : tri_rlmreg_p
  generic map (width => ex3_axu_is_ucode_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex2_axu_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_axu_is_ucode_offset to ex3_axu_is_ucode_offset + ex3_axu_is_ucode_q'length-1),
            scout   => sov(ex3_axu_is_ucode_offset to ex3_axu_is_ucode_offset + ex3_axu_is_ucode_q'length-1),
            din     => fu_xu_ex2_is_ucode         ,
            dout    => ex3_axu_is_ucode_q);
ex3_axu_val_latch : tri_rlmreg_p
  generic map (width => ex3_axu_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_axu_val_offset to ex3_axu_val_offset + ex3_axu_val_q'length-1),
            scout   => sov(ex3_axu_val_offset to ex3_axu_val_offset + ex3_axu_val_q'length-1),
            din     => ex2_axu_val                ,
            dout    => ex3_axu_val_q);
ex3_br_flush_ifar_latch : tri_rlmreg_p
  generic map (width => ex3_br_flush_ifar_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_br_flush_ifar_offset to ex3_br_flush_ifar_offset + ex3_br_flush_ifar_q'length-1),
            scout   => sov(ex3_br_flush_ifar_offset to ex3_br_flush_ifar_offset + ex3_br_flush_ifar_q'length-1),
            din     => ex2_br_flush_ifar          ,
            dout    => ex3_br_flush_ifar_q);
ex3_br_taken_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_br_taken_offset),
            scout   => sov(ex3_br_taken_offset),
            din     => ex2_br_taken_q             ,
            dout    => ex3_br_taken_q);
ex3_br_update_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_br_update_offset),
            scout   => sov(ex3_br_update_offset),
            din     => ex2_br_update_q            ,
            dout    => ex3_br_update_q);
ex3_byte_rev_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_byte_rev_offset),
            scout   => sov(ex3_byte_rev_offset),
            din     => ex2_byte_rev_q             ,
            dout    => ex3_byte_rev_q);
ex3_ctr_dec_update_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_ctr_dec_update_offset),
            scout   => sov(ex3_ctr_dec_update_offset),
            din     => ex2_ctr_dec_update_q       ,
            dout    => ex3_ctr_dec_update_q);
ex3_div_coll_latch : tri_rlmreg_p
  generic map (width => ex3_div_coll_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_div_coll_offset to ex3_div_coll_offset + ex3_div_coll_q'length-1),
            scout   => sov(ex3_div_coll_offset to ex3_div_coll_offset + ex3_div_coll_q'length-1),
            din     => ex3_div_coll_d,
            dout    => ex3_div_coll_q);
ex3_epid_instr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_epid_instr_offset),
            scout   => sov(ex3_epid_instr_offset),
            din     => ex2_epid_instr_q           ,
            dout    => ex3_epid_instr_q);
ex3_flush_latch : tri_rlmreg_p
  generic map (width => ex3_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_flush_offset to ex3_flush_offset + ex3_flush_q'length-1),
            scout   => sov(ex3_flush_offset to ex3_flush_offset + ex3_flush_q'length-1),
            din     => ex2_flush                  ,
            dout    => ex3_flush_q);
ex3_ierat_flush_req_latch : tri_rlmreg_p
  generic map (width => ex3_ierat_flush_req_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_ierat_flush_req_offset to ex3_ierat_flush_req_offset + ex3_ierat_flush_req_q'length-1),
            scout   => sov(ex3_ierat_flush_req_offset to ex3_ierat_flush_req_offset + ex3_ierat_flush_req_q'length-1),
            din     => iu_xu_ierat_ex2_flush_req  ,
            dout    => ex3_ierat_flush_req_q);
ex3_illegal_op_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_illegal_op_offset),
            scout   => sov(ex3_illegal_op_offset),
            din     => dec_cpl_ex2_illegal_op     ,
            dout    => ex3_illegal_op_q);
ex3_is_any_load_dac_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_any_load_dac_offset),
            scout   => sov(ex3_is_any_load_dac_offset),
            din     => dec_cpl_ex2_is_any_load_dac,
            dout    => ex3_is_any_load_dac_q);
ex3_is_any_store_dac_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_any_store_dac_offset),
            scout   => sov(ex3_is_any_store_dac_offset),
            din     => dec_cpl_ex2_is_any_store_dac,
            dout    => ex3_is_any_store_dac_q);
ex3_is_attn_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_attn_offset),
            scout   => sov(ex3_is_attn_offset),
            din     => ex2_is_attn_q              ,
            dout    => ex3_is_attn_q);
ex3_is_dci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_dci_offset),
            scout   => sov(ex3_is_dci_offset),
            din     => ex2_is_dci_q               ,
            dout    => ex3_is_dci_q);
ex3_is_dlock_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_dlock_offset),
            scout   => sov(ex3_is_dlock_offset),
            din     => ex2_is_dlock_q             ,
            dout    => ex3_is_dlock_q);
ex3_is_ehpriv_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_ehpriv_offset),
            scout   => sov(ex3_is_ehpriv_offset),
            din     => ex2_is_ehpriv_q            ,
            dout    => ex3_is_ehpriv_q);
ex3_is_ici_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_ici_offset),
            scout   => sov(ex3_is_ici_offset),
            din     => ex2_is_ici_q               ,
            dout    => ex3_is_ici_q);
ex3_is_icswx_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_icswx_offset),
            scout   => sov(ex3_is_icswx_offset),
            din     => ex2_is_icswx_q             ,
            dout    => ex3_is_icswx_q);
ex3_is_ilock_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_ilock_offset),
            scout   => sov(ex3_is_ilock_offset),
            din     => ex2_is_ilock_q             ,
            dout    => ex3_is_ilock_q);
ex3_is_isync_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_isync_offset),
            scout   => sov(ex3_is_isync_offset),
            din     => ex2_is_isync_q             ,
            dout    => ex3_is_isync_q);
ex3_is_mtmsr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_mtmsr_offset),
            scout   => sov(ex3_is_mtmsr_offset),
            din     => ex2_is_mtmsr_q             ,
            dout    => ex3_is_mtmsr_q);
ex3_is_rfci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_rfci_offset),
            scout   => sov(ex3_is_rfci_offset),
            din     => ex2_is_rfci_q              ,
            dout    => ex3_is_rfci_q);
ex3_is_rfgi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_rfgi_offset),
            scout   => sov(ex3_is_rfgi_offset),
            din     => ex2_is_rfgi_q              ,
            dout    => ex3_is_rfgi_q);
ex3_is_rfi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_rfi_offset),
            scout   => sov(ex3_is_rfi_offset),
            din     => ex2_is_rfi_q               ,
            dout    => ex3_is_rfi_q);
ex3_is_rfmci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_rfmci_offset),
            scout   => sov(ex3_is_rfmci_offset),
            din     => ex2_is_rfmci_q             ,
            dout    => ex3_is_rfmci_q);
ex3_is_sc_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_sc_offset),
            scout   => sov(ex3_is_sc_offset),
            din     => ex2_is_sc_q                ,
            dout    => ex3_is_sc_q);
ex3_is_tlbwe_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_tlbwe_offset),
            scout   => sov(ex3_is_tlbwe_offset),
            din     => ex2_is_tlbwe_q             ,
            dout    => ex3_is_tlbwe_q);
ex3_is_slowspr_wr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_slowspr_wr_offset),
            scout   => sov(ex3_is_slowspr_wr_offset),
            din     => ex2_is_slowspr_wr_q        ,
            dout    => ex3_is_slowspr_wr_q);
ex3_iu_error_latch : tri_rlmreg_p
  generic map (width => ex3_iu_error_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_iu_error_offset to ex3_iu_error_offset + ex3_iu_error_q'length-1),
            scout   => sov(ex3_iu_error_offset to ex3_iu_error_offset + ex3_iu_error_q'length-1),
            din     => ex3_iu_error_d,
            dout    => ex3_iu_error_q);
ex3_lr_update_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_lr_update_offset),
            scout   => sov(ex3_lr_update_offset),
            din     => ex2_lr_update_q            ,
            dout    => ex3_lr_update_q);
ex3_lrat_miss_latch : tri_rlmreg_p
  generic map (width => ex3_lrat_miss_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_lrat_miss_offset to ex3_lrat_miss_offset + ex3_lrat_miss_q'length-1),
            scout   => sov(ex3_lrat_miss_offset to ex3_lrat_miss_offset + ex3_lrat_miss_q'length-1),
            din     => mm_xu_lrat_miss            ,
            dout    => ex3_lrat_miss_q);
ex3_mmu_esr_data_latch : tri_rlmreg_p
  generic map (width => ex3_mmu_esr_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_mmu_esr_data_offset to ex3_mmu_esr_data_offset + ex3_mmu_esr_data_q'length-1),
            scout   => sov(ex3_mmu_esr_data_offset to ex3_mmu_esr_data_offset + ex3_mmu_esr_data_q'length-1),
            din     => mm_xu_esr_data             ,
            dout    => ex3_mmu_esr_data_q);
ex3_mmu_esr_epid_latch : tri_rlmreg_p
  generic map (width => ex3_mmu_esr_epid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_mmu_esr_epid_offset to ex3_mmu_esr_epid_offset + ex3_mmu_esr_epid_q'length-1),
            scout   => sov(ex3_mmu_esr_epid_offset to ex3_mmu_esr_epid_offset + ex3_mmu_esr_epid_q'length-1),
            din     => mm_xu_esr_epid             ,
            dout    => ex3_mmu_esr_epid_q);
ex3_mmu_esr_pt_latch : tri_rlmreg_p
  generic map (width => ex3_mmu_esr_pt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_mmu_esr_pt_offset to ex3_mmu_esr_pt_offset + ex3_mmu_esr_pt_q'length-1),
            scout   => sov(ex3_mmu_esr_pt_offset to ex3_mmu_esr_pt_offset + ex3_mmu_esr_pt_q'length-1),
            din     => mm_xu_esr_pt               ,
            dout    => ex3_mmu_esr_pt_q);
ex3_mmu_esr_st_latch : tri_rlmreg_p
  generic map (width => ex3_mmu_esr_st_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_mmu_esr_st_offset to ex3_mmu_esr_st_offset + ex3_mmu_esr_st_q'length-1),
            scout   => sov(ex3_mmu_esr_st_offset to ex3_mmu_esr_st_offset + ex3_mmu_esr_st_q'length-1),
            din     => mm_xu_esr_st               ,
            dout    => ex3_mmu_esr_st_q);
ex3_mmu_hv_priv_latch : tri_rlmreg_p
  generic map (width => ex3_mmu_hv_priv_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_mmu_hv_priv_offset to ex3_mmu_hv_priv_offset + ex3_mmu_hv_priv_q'length-1),
            scout   => sov(ex3_mmu_hv_priv_offset to ex3_mmu_hv_priv_offset + ex3_mmu_hv_priv_q'length-1),
            din     => mm_xu_hv_priv              ,
            dout    => ex3_mmu_hv_priv_q);
ex3_mtiar_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_mtiar_offset),
            scout   => sov(ex3_mtiar_offset),
            din     => ex2_mtiar,
            dout    => ex3_mtiar_q);
ex3_n_align_int_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_n_align_int_offset),
            scout   => sov(ex3_n_align_int_offset),
            din     => ex2_n_align_int_q          ,
            dout    => ex3_n_align_int_q);
ex3_n_dcpe_flush_latch : tri_rlmreg_p
  generic map (width => ex3_n_dcpe_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_n_dcpe_flush_offset to ex3_n_dcpe_flush_offset + ex3_n_dcpe_flush_q'length-1),
            scout   => sov(ex3_n_dcpe_flush_offset to ex3_n_dcpe_flush_offset + ex3_n_dcpe_flush_q'length-1),
            din     => ex3_n_dcpe_flush_d,
            dout    => ex3_n_dcpe_flush_q);
ex3_n_l2_ecc_err_flush_latch : tri_rlmreg_p
  generic map (width => ex3_n_l2_ecc_err_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_n_l2_ecc_err_flush_offset to ex3_n_l2_ecc_err_flush_offset + ex3_n_l2_ecc_err_flush_q'length-1),
            scout   => sov(ex3_n_l2_ecc_err_flush_offset to ex3_n_l2_ecc_err_flush_offset + ex3_n_l2_ecc_err_flush_q'length-1),
            din     => lsu_xu_l2_ecc_err_flush    ,
            dout    => ex3_n_l2_ecc_err_flush_q);
ex3_np1_run_ctl_flush_latch : tri_rlmreg_p
  generic map (width => ex3_np1_run_ctl_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_np1_run_ctl_flush_offset to ex3_np1_run_ctl_flush_offset + ex3_np1_run_ctl_flush_q'length-1),
            scout   => sov(ex3_np1_run_ctl_flush_offset to ex3_np1_run_ctl_flush_offset + ex3_np1_run_ctl_flush_q'length-1),
            din     => spr_cpl_ex2_run_ctl_flush  ,
            dout    => ex3_np1_run_ctl_flush_q);
ex3_sc_lev_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_sc_lev_offset),
            scout   => sov(ex3_sc_lev_offset),
            din     => ex2_sc_lev_q               ,
            dout    => ex3_sc_lev_q);
ex3_taken_bclr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_taken_bclr_offset),
            scout   => sov(ex3_taken_bclr_offset),
            din     => ex2_taken_bclr_q           ,
            dout    => ex3_taken_bclr_q);
ex3_tlb_inelig_latch : tri_rlmreg_p
  generic map (width => ex3_tlb_inelig_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tlb_inelig_offset to ex3_tlb_inelig_offset + ex3_tlb_inelig_q'length-1),
            scout   => sov(ex3_tlb_inelig_offset to ex3_tlb_inelig_offset + ex3_tlb_inelig_q'length-1),
            din     => mm_xu_tlb_inelig           ,
            dout    => ex3_tlb_inelig_q);
ex3_tlb_local_snoop_reject_latch : tri_rlmreg_p
  generic map (width => ex3_tlb_local_snoop_reject_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tlb_local_snoop_reject_offset to ex3_tlb_local_snoop_reject_offset + ex3_tlb_local_snoop_reject_q'length-1),
            scout   => sov(ex3_tlb_local_snoop_reject_offset to ex3_tlb_local_snoop_reject_offset + ex3_tlb_local_snoop_reject_q'length-1),
            din     => mm_xu_local_snoop_reject   ,
            dout    => ex3_tlb_local_snoop_reject_q);
ex3_tlb_lru_par_err_latch : tri_rlmreg_p
  generic map (width => ex3_tlb_lru_par_err_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tlb_lru_par_err_offset to ex3_tlb_lru_par_err_offset + ex3_tlb_lru_par_err_q'length-1),
            scout   => sov(ex3_tlb_lru_par_err_offset to ex3_tlb_lru_par_err_offset + ex3_tlb_lru_par_err_q'length-1),
            din     => mm_xu_lru_par_err          ,
            dout    => ex3_tlb_lru_par_err_q);
ex3_tlb_illeg_latch : tri_rlmreg_p
  generic map (width => ex3_tlb_illeg_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tlb_illeg_offset to ex3_tlb_illeg_offset + ex3_tlb_illeg_q'length-1),
            scout   => sov(ex3_tlb_illeg_offset to ex3_tlb_illeg_offset + ex3_tlb_illeg_q'length-1),
            din     => mm_xu_illeg_instr          ,
            dout    => ex3_tlb_illeg_q);
ex3_tlb_miss_latch : tri_rlmreg_p
  generic map (width => ex3_tlb_miss_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tlb_miss_offset to ex3_tlb_miss_offset + ex3_tlb_miss_q'length-1),
            scout   => sov(ex3_tlb_miss_offset to ex3_tlb_miss_offset + ex3_tlb_miss_q'length-1),
            din     => mm_xu_tlb_miss             ,
            dout    => ex3_tlb_miss_q);
ex3_tlb_multihit_err_latch : tri_rlmreg_p
  generic map (width => ex3_tlb_multihit_err_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tlb_multihit_err_offset to ex3_tlb_multihit_err_offset + ex3_tlb_multihit_err_q'length-1),
            scout   => sov(ex3_tlb_multihit_err_offset to ex3_tlb_multihit_err_offset + ex3_tlb_multihit_err_q'length-1),
            din     => mm_xu_tlb_multihit_err     ,
            dout    => ex3_tlb_multihit_err_q);
ex3_tlb_par_err_latch : tri_rlmreg_p
  generic map (width => ex3_tlb_par_err_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tlb_par_err_offset to ex3_tlb_par_err_offset + ex3_tlb_par_err_q'length-1),
            scout   => sov(ex3_tlb_par_err_offset to ex3_tlb_par_err_offset + ex3_tlb_par_err_q'length-1),
            din     => mm_xu_tlb_par_err          ,
            dout    => ex3_tlb_par_err_q);
ex3_tlb_pt_fault_latch : tri_rlmreg_p
  generic map (width => ex3_tlb_pt_fault_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_tlb_pt_fault_offset to ex3_tlb_pt_fault_offset + ex3_tlb_pt_fault_q'length-1),
            scout   => sov(ex3_tlb_pt_fault_offset to ex3_tlb_pt_fault_offset + ex3_tlb_pt_fault_q'length-1),
            din     => mm_xu_pt_fault             ,
            dout    => ex3_tlb_pt_fault_q);
ex3_ucode_val_latch : tri_rlmreg_p
  generic map (width => ex3_ucode_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_ucode_val_offset to ex3_ucode_val_offset + ex3_ucode_val_q'length-1),
            scout   => sov(ex3_ucode_val_offset to ex3_ucode_val_offset + ex3_ucode_val_q'length-1),
            din     => ex2_ucode_val              ,
            dout    => ex3_ucode_val_q);
ex3_xu_instr_match_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_xu_instr_match_offset),
            scout   => sov(ex3_xu_instr_match_offset),
            din     => dec_cpl_ex2_match          ,
            dout    => ex3_xu_instr_match_q);
ex3_xu_is_ucode_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_xu_is_ucode_offset),
            scout   => sov(ex3_xu_is_ucode_offset),
            din     => dec_cpl_ex2_is_ucode       ,
            dout    => ex3_xu_is_ucode_q);
ex3_xu_val_latch : tri_rlmreg_p
  generic map (width => ex3_xu_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_xu_val_offset to ex3_xu_val_offset + ex3_xu_val_q'length-1),
            scout   => sov(ex3_xu_val_offset to ex3_xu_val_offset + ex3_xu_val_q'length-1),
            din     => ex2_xu_val                 ,
            dout    => ex3_xu_val_q);
ex3_axu_async_block_latch : tri_rlmreg_p
  generic map (width => ex3_axu_async_block_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_axu_async_block_offset to ex3_axu_async_block_offset + ex3_axu_async_block_q'length-1),
            scout   => sov(ex3_axu_async_block_offset to ex3_axu_async_block_offset + ex3_axu_async_block_q'length-1),
            din     => fu_xu_ex2_async_block      ,
            dout    => ex3_axu_async_block_q);
ex3_is_mtxucr0_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)            ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_mtxucr0_offset),
            scout   => sov(ex3_is_mtxucr0_offset),
            din     => ex2_is_mtxucr0_q          ,
            dout    => ex3_is_mtxucr0_q);
ex3_np1_instr_flush_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_np1_instr_flush_offset),
            scout   => sov(ex3_np1_instr_flush_offset),
            din     => ex3_np1_instr_flush_d,
            dout    => ex3_np1_instr_flush_q);
ex4_apena_prog_int_latch : tri_rlmreg_p
  generic map (width => ex4_apena_prog_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_apena_prog_int_offset to ex4_apena_prog_int_offset + ex4_apena_prog_int_q'length-1),
            scout   => sov(ex4_apena_prog_int_offset to ex4_apena_prog_int_offset + ex4_apena_prog_int_q'length-1),
            din     => ex3_n_apena_prog_int,
            dout    => ex4_apena_prog_int_q);
ex4_axu_is_ucode_latch : tri_rlmreg_p
  generic map (width => ex4_axu_is_ucode_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_axu_is_ucode_offset to ex4_axu_is_ucode_offset + ex4_axu_is_ucode_q'length-1),
            scout   => sov(ex4_axu_is_ucode_offset to ex4_axu_is_ucode_offset + ex4_axu_is_ucode_q'length-1),
            din     => ex3_axu_is_ucode_q         ,
            dout    => ex4_axu_is_ucode_q);
ex4_axu_trap_latch : tri_rlmreg_p
  generic map (width => ex4_axu_trap_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_axu_trap_offset to ex4_axu_trap_offset + ex4_axu_trap_q'length-1),
            scout   => sov(ex4_axu_trap_offset to ex4_axu_trap_offset + ex4_axu_trap_q'length-1),
            din     => fu_xu_ex3_trap             ,
            dout    => ex4_axu_trap_q);
ex4_axu_val_latch : tri_rlmreg_p
  generic map (width => ex4_axu_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_axu_val_offset to ex4_axu_val_offset + ex4_axu_val_q'length-1),
            scout   => sov(ex4_axu_val_offset to ex4_axu_val_offset + ex4_axu_val_q'length-1),
            din     => ex3_axu_val                ,
            dout    => ex4_axu_val_q);
ex4_base_int_block_latch : tri_rlmreg_p
  generic map (width => ex4_base_int_block_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_base_int_block_offset to ex4_base_int_block_offset + ex4_base_int_block_q'length-1),
            scout   => sov(ex4_base_int_block_offset to ex4_base_int_block_offset + ex4_base_int_block_q'length-1),
            din     => ex3_base_int_block         ,
            dout    => ex4_base_int_block_q);
ex4_br_flush_ifar_latch : tri_rlmreg_p
  generic map (width => ex4_br_flush_ifar_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_br_flush_ifar_offset to ex4_br_flush_ifar_offset + ex4_br_flush_ifar_q'length-1),
            scout   => sov(ex4_br_flush_ifar_offset to ex4_br_flush_ifar_offset + ex4_br_flush_ifar_q'length-1),
            din     => ex3_br_flush_ifar_q        ,
            dout    => ex4_br_flush_ifar_q);
ex4_br_taken_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_br_taken_offset),
            scout   => sov(ex4_br_taken_offset),
            din     => ex3_br_taken_q             ,
            dout    => ex4_br_taken_q);
ex4_br_update_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_br_update_offset),
            scout   => sov(ex4_br_update_offset),
            din     => ex3_br_update_q            ,
            dout    => ex4_br_update_q);
ex4_byte_rev_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_byte_rev_offset),
            scout   => sov(ex4_byte_rev_offset),
            din     => ex3_byte_rev_q             ,
            dout    => ex4_byte_rev_q);
ex4_ctr_dec_update_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_ctr_dec_update_offset),
            scout   => sov(ex4_ctr_dec_update_offset),
            din     => ex3_ctr_dec_update_q       ,
            dout    => ex4_ctr_dec_update_q);
ex4_debug_flush_en_latch : tri_rlmreg_p
  generic map (width => ex4_debug_flush_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_debug_flush_en_offset to ex4_debug_flush_en_offset + ex4_debug_flush_en_q'length-1),
            scout   => sov(ex4_debug_flush_en_offset to ex4_debug_flush_en_offset + ex4_debug_flush_en_q'length-1),
            din     => ex4_debug_flush_en_d,
            dout    => ex4_debug_flush_en_q);
ex4_debug_int_en_latch : tri_rlmreg_p
  generic map (width => ex4_debug_int_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_debug_int_en_offset to ex4_debug_int_en_offset + ex4_debug_int_en_q'length-1),
            scout   => sov(ex4_debug_int_en_offset to ex4_debug_int_en_offset + ex4_debug_int_en_q'length-1),
            din     => ex3_debug_int_en,
            dout    => ex4_debug_int_en_q);
ex4_flush_latch : tri_rlmreg_p
  generic map (width => ex4_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_flush_offset to ex4_flush_offset + ex4_flush_q'length-1),
            scout   => sov(ex4_flush_offset to ex4_flush_offset + ex4_flush_q'length-1),
            din     => ex3_flush                  ,
            dout    => ex4_flush_q);
ex4_fpena_prog_int_latch : tri_rlmreg_p
  generic map (width => ex4_fpena_prog_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_fpena_prog_int_offset to ex4_fpena_prog_int_offset + ex4_fpena_prog_int_q'length-1),
            scout   => sov(ex4_fpena_prog_int_offset to ex4_fpena_prog_int_offset + ex4_fpena_prog_int_q'length-1),
            din     => ex3_n_fpena_prog_int,
            dout    => ex4_fpena_prog_int_q);
ex4_iac1_cmpr_latch : tri_rlmreg_p
  generic map (width => ex4_iac1_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_iac1_cmpr_offset to ex4_iac1_cmpr_offset + ex4_iac1_cmpr_q'length-1),
            scout   => sov(ex4_iac1_cmpr_offset to ex4_iac1_cmpr_offset + ex4_iac1_cmpr_q'length-1),
            din     => ex3_iac1_cmpr,
            dout    => ex4_iac1_cmpr_q);
ex4_iac2_cmpr_latch : tri_rlmreg_p
  generic map (width => ex4_iac2_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_iac2_cmpr_offset to ex4_iac2_cmpr_offset + ex4_iac2_cmpr_q'length-1),
            scout   => sov(ex4_iac2_cmpr_offset to ex4_iac2_cmpr_offset + ex4_iac2_cmpr_q'length-1),
            din     => ex3_iac2_cmpr,
            dout    => ex4_iac2_cmpr_q);
ex4_iac3_cmpr_latch : tri_rlmreg_p
  generic map (width => ex4_iac3_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_iac3_cmpr_offset to ex4_iac3_cmpr_offset + ex4_iac3_cmpr_q'length-1),
            scout   => sov(ex4_iac3_cmpr_offset to ex4_iac3_cmpr_offset + ex4_iac3_cmpr_q'length-1),
            din     => ex3_iac3_cmpr,
            dout    => ex4_iac3_cmpr_q);
ex4_iac4_cmpr_latch : tri_rlmreg_p
  generic map (width => ex4_iac4_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_iac4_cmpr_offset to ex4_iac4_cmpr_offset + ex4_iac4_cmpr_q'length-1),
            scout   => sov(ex4_iac4_cmpr_offset to ex4_iac4_cmpr_offset + ex4_iac4_cmpr_q'length-1),
            din     => ex3_iac4_cmpr,
            dout    => ex4_iac4_cmpr_q);
ex4_instr_cpl_latch : tri_rlmreg_p
  generic map (width => ex4_instr_cpl_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_instr_cpl_offset to ex4_instr_cpl_offset + ex4_instr_cpl_q'length-1),
            scout   => sov(ex4_instr_cpl_offset to ex4_instr_cpl_offset + ex4_instr_cpl_q'length-1),
            din     => ex4_instr_cpl_d,
            dout    => ex4_instr_cpl_q);
ex4_is_any_load_dac_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_any_load_dac_offset),
            scout   => sov(ex4_is_any_load_dac_offset),
            din     => ex3_is_any_load_dac_q      ,
            dout    => ex4_is_any_load_dac_q);
ex4_is_any_store_dac_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_any_store_dac_offset),
            scout   => sov(ex4_is_any_store_dac_offset),
            din     => ex3_is_any_store_dac_q     ,
            dout    => ex4_is_any_store_dac_q);
ex4_is_attn_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_attn_offset),
            scout   => sov(ex4_is_attn_offset),
            din     => ex3_is_attn_q              ,
            dout    => ex4_is_attn_q);
ex4_is_dci_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_dci_offset),
            scout   => sov(ex4_is_dci_offset),
            din     => ex3_is_dci_q               ,
            dout    => ex4_is_dci_q);
ex4_is_ehpriv_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_ehpriv_offset),
            scout   => sov(ex4_is_ehpriv_offset),
            din     => ex3_is_ehpriv_q            ,
            dout    => ex4_is_ehpriv_q);
ex4_is_ici_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_ici_offset),
            scout   => sov(ex4_is_ici_offset),
            din     => ex3_is_ici_q               ,
            dout    => ex4_is_ici_q);
ex4_is_isync_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_isync_offset),
            scout   => sov(ex4_is_isync_offset),
            din     => ex3_is_isync_q             ,
            dout    => ex4_is_isync_q);
ex4_is_mtmsr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_mtmsr_offset),
            scout   => sov(ex4_is_mtmsr_offset),
            din     => ex3_is_mtmsr_q             ,
            dout    => ex4_is_mtmsr_q);
ex4_is_tlbwe_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_tlbwe_offset),
            scout   => sov(ex4_is_tlbwe_offset),
            din     => ex3_is_tlbwe_q             ,
            dout    => ex4_is_tlbwe_q);
ex4_is_slowspr_wr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_slowspr_wr_offset),
            scout   => sov(ex4_is_slowspr_wr_offset),
            din     => ex3_is_slowspr_wr_q        ,
            dout    => ex4_is_slowspr_wr_q);
ex4_lr_update_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_lr_update_offset),
            scout   => sov(ex4_lr_update_offset),
            din     => ex3_lr_update_q            ,
            dout    => ex4_lr_update_q);
ex4_mcsr_latch : tri_rlmreg_p
  generic map (width => ex4_mcsr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mcsr_offset to ex4_mcsr_offset + ex4_mcsr_q'length-1),
            scout   => sov(ex4_mcsr_offset to ex4_mcsr_offset + ex4_mcsr_q'length-1),
            din     => ex4_mcsr_d,
            dout    => ex4_mcsr_q);
ex4_mem_attr_latch : tri_rlmreg_p
  generic map (width => ex4_mem_attr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mem_attr_offset to ex4_mem_attr_offset + ex4_mem_attr_q'length-1),
            scout   => sov(ex4_mem_attr_offset to ex4_mem_attr_offset + ex4_mem_attr_q'length-1),
            din     => lsu_xu_ex3_attr            ,
            dout    => ex4_mem_attr_q);
ex4_mmu_esr_data_latch : tri_rlmreg_p
  generic map (width => ex4_mmu_esr_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mmu_esr_data_offset to ex4_mmu_esr_data_offset + ex4_mmu_esr_data_q'length-1),
            scout   => sov(ex4_mmu_esr_data_offset to ex4_mmu_esr_data_offset + ex4_mmu_esr_data_q'length-1),
            din     => ex3_mmu_esr_data_q         ,
            dout    => ex4_mmu_esr_data_q);
ex4_mmu_esr_epid_latch : tri_rlmreg_p
  generic map (width => ex4_mmu_esr_epid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mmu_esr_epid_offset to ex4_mmu_esr_epid_offset + ex4_mmu_esr_epid_q'length-1),
            scout   => sov(ex4_mmu_esr_epid_offset to ex4_mmu_esr_epid_offset + ex4_mmu_esr_epid_q'length-1),
            din     => ex3_mmu_esr_epid_q         ,
            dout    => ex4_mmu_esr_epid_q);
ex4_mmu_esr_pt_latch : tri_rlmreg_p
  generic map (width => ex4_mmu_esr_pt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mmu_esr_pt_offset to ex4_mmu_esr_pt_offset + ex4_mmu_esr_pt_q'length-1),
            scout   => sov(ex4_mmu_esr_pt_offset to ex4_mmu_esr_pt_offset + ex4_mmu_esr_pt_q'length-1),
            din     => ex3_mmu_esr_pt_q           ,
            dout    => ex4_mmu_esr_pt_q);
ex4_mmu_esr_st_latch : tri_rlmreg_p
  generic map (width => ex4_mmu_esr_st_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mmu_esr_st_offset to ex4_mmu_esr_st_offset + ex4_mmu_esr_st_q'length-1),
            scout   => sov(ex4_mmu_esr_st_offset to ex4_mmu_esr_st_offset + ex4_mmu_esr_st_q'length-1),
            din     => ex3_mmu_esr_st_q           ,
            dout    => ex4_mmu_esr_st_q);
ex4_mmu_esr_val_latch : tri_rlmreg_p
  generic map (width => ex4_mmu_esr_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mmu_esr_val_offset to ex4_mmu_esr_val_offset + ex4_mmu_esr_val_q'length-1),
            scout   => sov(ex4_mmu_esr_val_offset to ex4_mmu_esr_val_offset + ex4_mmu_esr_val_q'length-1),
            din     => ex4_mmu_esr_val_d,
            dout    => ex4_mmu_esr_val_q);
ex4_mmu_hold_val_latch : tri_rlmreg_p
  generic map (width => ex4_mmu_hold_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mmu_hold_val_offset to ex4_mmu_hold_val_offset + ex4_mmu_hold_val_q'length-1),
            scout   => sov(ex4_mmu_hold_val_offset to ex4_mmu_hold_val_offset + ex4_mmu_hold_val_q'length-1),
            din     => ex3_mmu_hold_val,
            dout    => ex4_mmu_hold_val_q);
ex4_mtdp_nr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mtdp_nr_offset),
            scout   => sov(ex4_mtdp_nr_offset),
            din     => dec_cpl_ex3_mtdp_nr        ,
            dout    => ex4_mtdp_nr_q);
ex4_mtiar_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mtiar_offset),
            scout   => sov(ex4_mtiar_offset),
            din     => ex3_mtiar_q                ,
            dout    => ex4_mtiar_q);
ex4_n_2ucode_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_2ucode_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_2ucode_flush_offset to ex4_n_2ucode_flush_offset + ex4_n_2ucode_flush_q'length-1),
            scout   => sov(ex4_n_2ucode_flush_offset to ex4_n_2ucode_flush_offset + ex4_n_2ucode_flush_q'length-1),
            din     => ex3_n_2ucode_flush,
            dout    => ex4_n_2ucode_flush_q);
ex4_n_align_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_align_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_align_int_offset to ex4_n_align_int_offset + ex4_n_align_int_q'length-1),
            scout   => sov(ex4_n_align_int_offset to ex4_n_align_int_offset + ex4_n_align_int_q'length-1),
            din     => ex3_n_align_int,
            dout    => ex4_n_align_int_q);
ex4_n_any_hpriv_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_any_hpriv_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_any_hpriv_int_offset to ex4_n_any_hpriv_int_offset + ex4_n_any_hpriv_int_q'length-1),
            scout   => sov(ex4_n_any_hpriv_int_offset to ex4_n_any_hpriv_int_offset + ex4_n_any_hpriv_int_q'length-1),
            din     => ex4_n_any_hpriv_int_d,
            dout    => ex4_n_any_hpriv_int_q);
ex4_n_any_unavail_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_any_unavail_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_any_unavail_int_offset to ex4_n_any_unavail_int_offset + ex4_n_any_unavail_int_q'length-1),
            scout   => sov(ex4_n_any_unavail_int_offset to ex4_n_any_unavail_int_offset + ex4_n_any_unavail_int_q'length-1),
            din     => ex3_n_any_unavail_int,
            dout    => ex4_n_any_unavail_int_q);
ex4_n_ap_unavail_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_ap_unavail_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ap_unavail_int_offset to ex4_n_ap_unavail_int_offset + ex4_n_ap_unavail_int_q'length-1),
            scout   => sov(ex4_n_ap_unavail_int_offset to ex4_n_ap_unavail_int_offset + ex4_n_ap_unavail_int_q'length-1),
            din     => ex3_n_ap_unavail_int,
            dout    => ex4_n_ap_unavail_int_q);
ex4_n_barr_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_barr_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_barr_flush_offset to ex4_n_barr_flush_offset + ex4_n_barr_flush_q'length-1),
            scout   => sov(ex4_n_barr_flush_offset to ex4_n_barr_flush_offset + ex4_n_barr_flush_q'length-1),
            din     => ex3_n_barr_flush,
            dout    => ex4_n_barr_flush_q);
ex4_n_bclr_ta_miscmpr_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_bclr_ta_miscmpr_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_bclr_ta_miscmpr_flush_offset to ex4_n_bclr_ta_miscmpr_flush_offset + ex4_n_bclr_ta_miscmpr_flush_q'length-1),
            scout   => sov(ex4_n_bclr_ta_miscmpr_flush_offset to ex4_n_bclr_ta_miscmpr_flush_offset + ex4_n_bclr_ta_miscmpr_flush_q'length-1),
            din     => ex3_n_bclr_ta_miscmpr_flush,
            dout    => ex4_n_bclr_ta_miscmpr_flush_q);
ex4_n_brt_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex4_n_brt_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_brt_dbg_cint_offset to ex4_n_brt_dbg_cint_offset + ex4_n_brt_dbg_cint_q'length-1),
            scout   => sov(ex4_n_brt_dbg_cint_offset to ex4_n_brt_dbg_cint_offset + ex4_n_brt_dbg_cint_q'length-1),
            din     => ex3_n_brt_dbg_cint,
            dout    => ex4_n_brt_dbg_cint_q);
ex4_n_dac_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex4_n_dac_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_dac_dbg_cint_offset to ex4_n_dac_dbg_cint_offset + ex4_n_dac_dbg_cint_q'length-1),
            scout   => sov(ex4_n_dac_dbg_cint_offset to ex4_n_dac_dbg_cint_offset + ex4_n_dac_dbg_cint_q'length-1),
            din     => ex3_n_dac_dbg_cint,
            dout    => ex4_n_dac_dbg_cint_q);
ex4_n_ddmh_mchk_en_latch : tri_rlmreg_p
  generic map (width => ex4_n_ddmh_mchk_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ddmh_mchk_en_offset to ex4_n_ddmh_mchk_en_offset + ex4_n_ddmh_mchk_en_q'length-1),
            scout   => sov(ex4_n_ddmh_mchk_en_offset to ex4_n_ddmh_mchk_en_offset + ex4_n_ddmh_mchk_en_q'length-1),
            din     => ex4_n_ddmh_mchk_en_d,
            dout    => ex4_n_ddmh_mchk_en_q);
ex4_n_dep_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_dep_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_dep_flush_offset to ex4_n_dep_flush_offset + ex4_n_dep_flush_q'length-1),
            scout   => sov(ex4_n_dep_flush_offset to ex4_n_dep_flush_offset + ex4_n_dep_flush_q'length-1),
            din     => ex3_n_dep_flush,
            dout    => ex4_n_dep_flush_q);
ex4_n_deratre_par_mchk_mcint_latch : tri_rlmreg_p
  generic map (width => ex4_n_deratre_par_mchk_mcint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_deratre_par_mchk_mcint_offset to ex4_n_deratre_par_mchk_mcint_offset + ex4_n_deratre_par_mchk_mcint_q'length-1),
            scout   => sov(ex4_n_deratre_par_mchk_mcint_offset to ex4_n_deratre_par_mchk_mcint_offset + ex4_n_deratre_par_mchk_mcint_q'length-1),
            din     => ex3_n_deratre_par_mchk_mcint,
            dout    => ex4_n_deratre_par_mchk_mcint_q);
ex4_n_dlk0_dstor_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_dlk0_dstor_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_dlk0_dstor_int_offset to ex4_n_dlk0_dstor_int_offset + ex4_n_dlk0_dstor_int_q'length-1),
            scout   => sov(ex4_n_dlk0_dstor_int_offset to ex4_n_dlk0_dstor_int_offset + ex4_n_dlk0_dstor_int_q'length-1),
            din     => ex3_n_dlk0_dstor_int,
            dout    => ex4_n_dlk0_dstor_int_q);
ex4_n_dlk1_dstor_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_dlk1_dstor_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_dlk1_dstor_int_offset to ex4_n_dlk1_dstor_int_offset + ex4_n_dlk1_dstor_int_q'length-1),
            scout   => sov(ex4_n_dlk1_dstor_int_offset to ex4_n_dlk1_dstor_int_offset + ex4_n_dlk1_dstor_int_q'length-1),
            din     => ex3_n_dlk1_dstor_int,
            dout    => ex4_n_dlk1_dstor_int_q);
ex4_n_dlrat_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_dlrat_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_dlrat_int_offset to ex4_n_dlrat_int_offset + ex4_n_dlrat_int_q'length-1),
            scout   => sov(ex4_n_dlrat_int_offset to ex4_n_dlrat_int_offset + ex4_n_dlrat_int_q'length-1),
            din     => ex3_n_dlrat_int,
            dout    => ex4_n_dlrat_int_q);
ex4_n_dmchk_mcint_latch : tri_rlmreg_p
  generic map (width => ex4_n_dmchk_mcint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_dmchk_mcint_offset to ex4_n_dmchk_mcint_offset + ex4_n_dmchk_mcint_q'length-1),
            scout   => sov(ex4_n_dmchk_mcint_offset to ex4_n_dmchk_mcint_offset + ex4_n_dmchk_mcint_q'length-1),
            din     => ex3_n_dmchk_mcint,
            dout    => ex4_n_dmchk_mcint_q);
ex4_n_dmiss_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_dmiss_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_dmiss_flush_offset to ex4_n_dmiss_flush_offset + ex4_n_dmiss_flush_q'length-1),
            scout   => sov(ex4_n_dmiss_flush_offset to ex4_n_dmiss_flush_offset + ex4_n_dmiss_flush_q'length-1),
            din     => ex3_n_dmiss_flush,
            dout    => ex4_n_dmiss_flush_q);
ex4_n_dstor_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_dstor_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_dstor_int_offset to ex4_n_dstor_int_offset + ex4_n_dstor_int_q'length-1),
            scout   => sov(ex4_n_dstor_int_offset to ex4_n_dstor_int_offset + ex4_n_dstor_int_q'length-1),
            din     => ex3_n_dstor_int,
            dout    => ex4_n_dstor_int_q);
ex4_n_dtlb_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_dtlb_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_dtlb_int_offset to ex4_n_dtlb_int_offset + ex4_n_dtlb_int_q'length-1),
            scout   => sov(ex4_n_dtlb_int_offset to ex4_n_dtlb_int_offset + ex4_n_dtlb_int_q'length-1),
            din     => ex3_n_dtlb_int,
            dout    => ex4_n_dtlb_int_q);
ex4_n_ena_prog_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_ena_prog_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ena_prog_int_offset to ex4_n_ena_prog_int_offset + ex4_n_ena_prog_int_q'length-1),
            scout   => sov(ex4_n_ena_prog_int_offset to ex4_n_ena_prog_int_offset + ex4_n_ena_prog_int_q'length-1),
            din     => ex3_n_ena_prog_int,
            dout    => ex4_n_ena_prog_int_q);
ex4_n_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_flush_offset to ex4_n_flush_offset + ex4_n_flush_q'length-1),
            scout   => sov(ex4_n_flush_offset to ex4_n_flush_offset + ex4_n_flush_q'length-1),
            din     => ex3_n_flush,
            dout    => ex4_n_flush_q);
ex4_n_pe_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_pe_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_pe_flush_offset to ex4_n_pe_flush_offset + ex4_n_pe_flush_q'length-1),
            scout   => sov(ex4_n_pe_flush_offset to ex4_n_pe_flush_offset + ex4_n_pe_flush_q'length-1),
            din     => ex3_n_pe_flush,
            dout    => ex4_n_pe_flush_q);
ex4_n_tlb_mchk_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_tlb_mchk_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_tlb_mchk_flush_offset to ex4_n_tlb_mchk_flush_offset + ex4_n_tlb_mchk_flush_q'length-1),
            scout   => sov(ex4_n_tlb_mchk_flush_offset to ex4_n_tlb_mchk_flush_offset + ex4_n_tlb_mchk_flush_q'length-1),
            din     => ex3_n_tlb_mchk_flush,
            dout    => ex4_n_tlb_mchk_flush_q);
ex4_n_fp_unavail_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_fp_unavail_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_fp_unavail_int_offset to ex4_n_fp_unavail_int_offset + ex4_n_fp_unavail_int_q'length-1),
            scout   => sov(ex4_n_fp_unavail_int_offset to ex4_n_fp_unavail_int_offset + ex4_n_fp_unavail_int_q'length-1),
            din     => ex3_n_fp_unavail_int,
            dout    => ex4_n_fp_unavail_int_q);
ex4_n_fu_rfpe_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_fu_rfpe_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_fu_rfpe_flush_offset to ex4_n_fu_rfpe_flush_offset + ex4_n_fu_rfpe_flush_q'length-1),
            scout   => sov(ex4_n_fu_rfpe_flush_offset to ex4_n_fu_rfpe_flush_offset + ex4_n_fu_rfpe_flush_q'length-1),
            din     => ex4_n_fu_rfpe_flush_d,
            dout    => ex4_n_fu_rfpe_flush_q);
ex4_n_iac_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex4_n_iac_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_iac_dbg_cint_offset to ex4_n_iac_dbg_cint_offset + ex4_n_iac_dbg_cint_q'length-1),
            scout   => sov(ex4_n_iac_dbg_cint_offset to ex4_n_iac_dbg_cint_offset + ex4_n_iac_dbg_cint_q'length-1),
            din     => ex3_n_iac_dbg_cint,
            dout    => ex4_n_iac_dbg_cint_q);
ex4_n_ieratre_par_mchk_mcint_latch : tri_rlmreg_p
  generic map (width => ex4_n_ieratre_par_mchk_mcint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ieratre_par_mchk_mcint_offset to ex4_n_ieratre_par_mchk_mcint_offset + ex4_n_ieratre_par_mchk_mcint_q'length-1),
            scout   => sov(ex4_n_ieratre_par_mchk_mcint_offset to ex4_n_ieratre_par_mchk_mcint_offset + ex4_n_ieratre_par_mchk_mcint_q'length-1),
            din     => ex3_n_ieratre_par_mchk_mcint,
            dout    => ex4_n_ieratre_par_mchk_mcint_q);
ex4_n_ilrat_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_ilrat_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ilrat_int_offset to ex4_n_ilrat_int_offset + ex4_n_ilrat_int_q'length-1),
            scout   => sov(ex4_n_ilrat_int_offset to ex4_n_ilrat_int_offset + ex4_n_ilrat_int_q'length-1),
            din     => ex3_n_ilrat_int,
            dout    => ex4_n_ilrat_int_q);
ex4_n_imchk_mcint_latch : tri_rlmreg_p
  generic map (width => ex4_n_imchk_mcint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_imchk_mcint_offset to ex4_n_imchk_mcint_offset + ex4_n_imchk_mcint_q'length-1),
            scout   => sov(ex4_n_imchk_mcint_offset to ex4_n_imchk_mcint_offset + ex4_n_imchk_mcint_q'length-1),
            din     => ex3_n_imchk_mcint,
            dout    => ex4_n_imchk_mcint_q);
ex4_n_imiss_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_imiss_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_imiss_flush_offset to ex4_n_imiss_flush_offset + ex4_n_imiss_flush_q'length-1),
            scout   => sov(ex4_n_imiss_flush_offset to ex4_n_imiss_flush_offset + ex4_n_imiss_flush_q'length-1),
            din     => ex3_n_imiss_flush,
            dout    => ex4_n_imiss_flush_q);
ex4_n_instr_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex4_n_instr_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_instr_dbg_cint_offset to ex4_n_instr_dbg_cint_offset + ex4_n_instr_dbg_cint_q'length-1),
            scout   => sov(ex4_n_instr_dbg_cint_offset to ex4_n_instr_dbg_cint_offset + ex4_n_instr_dbg_cint_q'length-1),
            din     => ex3_n_instr_dbg_cint,
            dout    => ex4_n_instr_dbg_cint_q);
ex4_n_istor_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_istor_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_istor_int_offset to ex4_n_istor_int_offset + ex4_n_istor_int_q'length-1),
            scout   => sov(ex4_n_istor_int_offset to ex4_n_istor_int_offset + ex4_n_istor_int_q'length-1),
            din     => ex3_n_istor_int,
            dout    => ex4_n_istor_int_q);
ex4_n_itlb_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_itlb_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_itlb_int_offset to ex4_n_itlb_int_offset + ex4_n_itlb_int_q'length-1),
            scout   => sov(ex4_n_itlb_int_offset to ex4_n_itlb_int_offset + ex4_n_itlb_int_q'length-1),
            din     => ex3_n_itlb_int,
            dout    => ex4_n_itlb_int_q);
ex4_n_ivc_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex4_n_ivc_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ivc_dbg_cint_offset to ex4_n_ivc_dbg_cint_offset + ex4_n_ivc_dbg_cint_q'length-1),
            scout   => sov(ex4_n_ivc_dbg_cint_offset to ex4_n_ivc_dbg_cint_offset + ex4_n_ivc_dbg_cint_q'length-1),
            din     => ex3_n_ivc_dbg_cint,
            dout    => ex4_n_ivc_dbg_cint_q);
ex4_n_ivc_dbg_match_latch : tri_rlmreg_p
  generic map (width => ex4_n_ivc_dbg_match_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ivc_dbg_match_offset to ex4_n_ivc_dbg_match_offset + ex4_n_ivc_dbg_match_q'length-1),
            scout   => sov(ex4_n_ivc_dbg_match_offset to ex4_n_ivc_dbg_match_offset + ex4_n_ivc_dbg_match_q'length-1),
            din     => ex3_n_ivc_dbg_match,
            dout    => ex4_n_ivc_dbg_match_q);
ex4_n_ldq_hit_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_ldq_hit_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ldq_hit_flush_offset to ex4_n_ldq_hit_flush_offset + ex4_n_ldq_hit_flush_q'length-1),
            scout   => sov(ex4_n_ldq_hit_flush_offset to ex4_n_ldq_hit_flush_offset + ex4_n_ldq_hit_flush_q'length-1),
            din     => ex3_n_ldq_hit_flush,
            dout    => ex4_n_ldq_hit_flush_q);
ex4_n_lsu_ddmh_flush_en_latch : tri_rlmreg_p
  generic map (width => ex4_n_lsu_ddmh_flush_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_lsu_ddmh_flush_en_offset to ex4_n_lsu_ddmh_flush_en_offset + ex4_n_lsu_ddmh_flush_en_q'length-1),
            scout   => sov(ex4_n_lsu_ddmh_flush_en_offset to ex4_n_lsu_ddmh_flush_en_offset + ex4_n_lsu_ddmh_flush_en_q'length-1),
            din     => ex4_n_lsu_ddmh_flush_en_d,
            dout    => ex4_n_lsu_ddmh_flush_en_q);
ex4_n_lsu_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_lsu_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_lsu_flush_offset to ex4_n_lsu_flush_offset + ex4_n_lsu_flush_q'length-1),
            scout   => sov(ex4_n_lsu_flush_offset to ex4_n_lsu_flush_offset + ex4_n_lsu_flush_q'length-1),
            din     => ex3_n_lsu_flush,
            dout    => ex4_n_lsu_flush_q);
ex4_n_memattr_miscmpr_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_memattr_miscmpr_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_memattr_miscmpr_flush_offset to ex4_n_memattr_miscmpr_flush_offset + ex4_n_memattr_miscmpr_flush_q'length-1),
            scout   => sov(ex4_n_memattr_miscmpr_flush_offset to ex4_n_memattr_miscmpr_flush_offset + ex4_n_memattr_miscmpr_flush_q'length-1),
            din     => ex3_n_memattr_miscmpr_flush,
            dout    => ex4_n_memattr_miscmpr_flush_q);
ex4_n_mmu_hpriv_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_mmu_hpriv_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_mmu_hpriv_int_offset to ex4_n_mmu_hpriv_int_offset + ex4_n_mmu_hpriv_int_q'length-1),
            scout   => sov(ex4_n_mmu_hpriv_int_offset to ex4_n_mmu_hpriv_int_offset + ex4_n_mmu_hpriv_int_q'length-1),
            din     => ex3_n_mmu_hpriv_int,
            dout    => ex4_n_mmu_hpriv_int_q);
ex4_n_pil_prog_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_pil_prog_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_pil_prog_int_offset to ex4_n_pil_prog_int_offset + ex4_n_pil_prog_int_q'length-1),
            scout   => sov(ex4_n_pil_prog_int_offset to ex4_n_pil_prog_int_offset + ex4_n_pil_prog_int_q'length-1),
            din     => ex3_n_pil_prog_int,
            dout    => ex4_n_pil_prog_int_q);
ex4_n_ppr_prog_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_ppr_prog_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ppr_prog_int_offset to ex4_n_ppr_prog_int_offset + ex4_n_ppr_prog_int_q'length-1),
            scout   => sov(ex4_n_ppr_prog_int_offset to ex4_n_ppr_prog_int_offset + ex4_n_ppr_prog_int_q'length-1),
            din     => ex3_n_ppr_prog_int,
            dout    => ex4_n_ppr_prog_int_q);
ex4_n_ptemiss_dlrat_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_ptemiss_dlrat_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ptemiss_dlrat_int_offset to ex4_n_ptemiss_dlrat_int_offset + ex4_n_ptemiss_dlrat_int_q'length-1),
            scout   => sov(ex4_n_ptemiss_dlrat_int_offset to ex4_n_ptemiss_dlrat_int_offset + ex4_n_ptemiss_dlrat_int_q'length-1),
            din     => ex3_n_ptemiss_dlrat_int,
            dout    => ex4_n_ptemiss_dlrat_int_q);
ex4_n_puo_prog_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_puo_prog_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_puo_prog_int_offset to ex4_n_puo_prog_int_offset + ex4_n_puo_prog_int_q'length-1),
            scout   => sov(ex4_n_puo_prog_int_offset to ex4_n_puo_prog_int_offset + ex4_n_puo_prog_int_q'length-1),
            din     => ex3_n_puo_prog_int,
            dout    => ex4_n_puo_prog_int_q);
ex4_n_ret_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex4_n_ret_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ret_dbg_cint_offset to ex4_n_ret_dbg_cint_offset + ex4_n_ret_dbg_cint_q'length-1),
            scout   => sov(ex4_n_ret_dbg_cint_offset to ex4_n_ret_dbg_cint_offset + ex4_n_ret_dbg_cint_q'length-1),
            din     => ex3_n_ret_dbg_cint,
            dout    => ex4_n_ret_dbg_cint_q);
ex4_n_thrctl_stop_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_thrctl_stop_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_thrctl_stop_flush_offset to ex4_n_thrctl_stop_flush_offset + ex4_n_thrctl_stop_flush_q'length-1),
            scout   => sov(ex4_n_thrctl_stop_flush_offset to ex4_n_thrctl_stop_flush_offset + ex4_n_thrctl_stop_flush_q'length-1),
            din     => ex3_n_thrctl_stop_flush,
            dout    => ex4_n_thrctl_stop_flush_q);
ex4_n_tlbwemiss_dlrat_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_tlbwemiss_dlrat_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_tlbwemiss_dlrat_int_offset to ex4_n_tlbwemiss_dlrat_int_offset + ex4_n_tlbwemiss_dlrat_int_q'length-1),
            scout   => sov(ex4_n_tlbwemiss_dlrat_int_offset to ex4_n_tlbwemiss_dlrat_int_offset + ex4_n_tlbwemiss_dlrat_int_q'length-1),
            din     => ex3_n_tlbwemiss_dlrat_int,
            dout    => ex4_n_tlbwemiss_dlrat_int_q);
ex4_n_tlbwe_pil_prog_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_tlbwe_pil_prog_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_tlbwe_pil_prog_int_offset to ex4_n_tlbwe_pil_prog_int_offset + ex4_n_tlbwe_pil_prog_int_q'length-1),
            scout   => sov(ex4_n_tlbwe_pil_prog_int_offset to ex4_n_tlbwe_pil_prog_int_offset + ex4_n_tlbwe_pil_prog_int_q'length-1),
            din     => ex3_n_tlbwe_pil_prog_int,
            dout    => ex4_n_tlbwe_pil_prog_int_q);
ex4_n_trap_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex4_n_trap_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_trap_dbg_cint_offset to ex4_n_trap_dbg_cint_offset + ex4_n_trap_dbg_cint_q'length-1),
            scout   => sov(ex4_n_trap_dbg_cint_offset to ex4_n_trap_dbg_cint_offset + ex4_n_trap_dbg_cint_q'length-1),
            din     => ex3_n_trap_dbg_cint,
            dout    => ex4_n_trap_dbg_cint_q);
ex4_n_uct_dstor_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_uct_dstor_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_uct_dstor_int_offset to ex4_n_uct_dstor_int_offset + ex4_n_uct_dstor_int_q'length-1),
            scout   => sov(ex4_n_uct_dstor_int_offset to ex4_n_uct_dstor_int_offset + ex4_n_uct_dstor_int_q'length-1),
            din     => ex3_n_uct_dstor_int,
            dout    => ex4_n_uct_dstor_int_q);
ex4_n_vec_unavail_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_vec_unavail_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_vec_unavail_int_offset to ex4_n_vec_unavail_int_offset + ex4_n_vec_unavail_int_q'length-1),
            scout   => sov(ex4_n_vec_unavail_int_offset to ex4_n_vec_unavail_int_offset + ex4_n_vec_unavail_int_q'length-1),
            din     => ex3_n_vec_unavail_int,
            dout    => ex4_n_vec_unavail_int_q);
ex4_n_vf_dstor_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_vf_dstor_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_vf_dstor_int_offset to ex4_n_vf_dstor_int_offset + ex4_n_vf_dstor_int_q'length-1),
            scout   => sov(ex4_n_vf_dstor_int_offset to ex4_n_vf_dstor_int_offset + ex4_n_vf_dstor_int_q'length-1),
            din     => ex3_n_vf_dstor_int,
            dout    => ex4_n_vf_dstor_int_q);
ex4_n_xu_rfpe_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_xu_rfpe_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_xu_rfpe_flush_offset to ex4_n_xu_rfpe_flush_offset + ex4_n_xu_rfpe_flush_q'length-1),
            scout   => sov(ex4_n_xu_rfpe_flush_offset to ex4_n_xu_rfpe_flush_offset + ex4_n_xu_rfpe_flush_q'length-1),
            din     => ex4_n_xu_rfpe_flush_d,
            dout    => ex4_n_xu_rfpe_flush_q);
ex4_np1_cdbell_cint_latch : tri_rlmreg_p
  generic map (width => ex4_np1_cdbell_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_cdbell_cint_offset to ex4_np1_cdbell_cint_offset + ex4_np1_cdbell_cint_q'length-1),
            scout   => sov(ex4_np1_cdbell_cint_offset to ex4_np1_cdbell_cint_offset + ex4_np1_cdbell_cint_q'length-1),
            din     => ex3_np1_cdbell_cint,
            dout    => ex4_np1_cdbell_cint_q);
ex4_np1_crit_cint_latch : tri_rlmreg_p
  generic map (width => ex4_np1_crit_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_crit_cint_offset to ex4_np1_crit_cint_offset + ex4_np1_crit_cint_q'length-1),
            scout   => sov(ex4_np1_crit_cint_offset to ex4_np1_crit_cint_offset + ex4_np1_crit_cint_q'length-1),
            din     => ex3_np1_crit_cint,
            dout    => ex4_np1_crit_cint_q);
ex4_np1_dbell_int_latch : tri_rlmreg_p
  generic map (width => ex4_np1_dbell_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_dbell_int_offset to ex4_np1_dbell_int_offset + ex4_np1_dbell_int_q'length-1),
            scout   => sov(ex4_np1_dbell_int_offset to ex4_np1_dbell_int_offset + ex4_np1_dbell_int_q'length-1),
            din     => ex3_np1_dbell_int,
            dout    => ex4_np1_dbell_int_q);
ex4_np1_dec_int_latch : tri_rlmreg_p
  generic map (width => ex4_np1_dec_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_dec_int_offset to ex4_np1_dec_int_offset + ex4_np1_dec_int_q'length-1),
            scout   => sov(ex4_np1_dec_int_offset to ex4_np1_dec_int_offset + ex4_np1_dec_int_q'length-1),
            din     => ex3_np1_dec_int,
            dout    => ex4_np1_dec_int_q);
ex4_np1_ext_int_latch : tri_rlmreg_p
  generic map (width => ex4_np1_ext_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_ext_int_offset to ex4_np1_ext_int_offset + ex4_np1_ext_int_q'length-1),
            scout   => sov(ex4_np1_ext_int_offset to ex4_np1_ext_int_offset + ex4_np1_ext_int_q'length-1),
            din     => ex3_np1_ext_int,
            dout    => ex4_np1_ext_int_q);
ex4_np1_ext_mchk_mcint_latch : tri_rlmreg_p
  generic map (width => ex4_np1_ext_mchk_mcint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_ext_mchk_mcint_offset to ex4_np1_ext_mchk_mcint_offset + ex4_np1_ext_mchk_mcint_q'length-1),
            scout   => sov(ex4_np1_ext_mchk_mcint_offset to ex4_np1_ext_mchk_mcint_offset + ex4_np1_ext_mchk_mcint_q'length-1),
            din     => ex3_np1_ext_mchk_mcint,
            dout    => ex4_np1_ext_mchk_mcint_q);
ex4_np1_fit_int_latch : tri_rlmreg_p
  generic map (width => ex4_np1_fit_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_fit_int_offset to ex4_np1_fit_int_offset + ex4_np1_fit_int_q'length-1),
            scout   => sov(ex4_np1_fit_int_offset to ex4_np1_fit_int_offset + ex4_np1_fit_int_q'length-1),
            din     => ex3_np1_fit_int,
            dout    => ex4_np1_fit_int_q);
ex4_np1_flush_latch : tri_rlmreg_p
  generic map (width => ex4_np1_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_flush_offset to ex4_np1_flush_offset + ex4_np1_flush_q'length-1),
            scout   => sov(ex4_np1_flush_offset to ex4_np1_flush_offset + ex4_np1_flush_q'length-1),
            din     => ex3_np1_flush,
            dout    => ex4_np1_flush_q);
ex4_np1_gcdbell_cint_latch : tri_rlmreg_p
  generic map (width => ex4_np1_gcdbell_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_gcdbell_cint_offset to ex4_np1_gcdbell_cint_offset + ex4_np1_gcdbell_cint_q'length-1),
            scout   => sov(ex4_np1_gcdbell_cint_offset to ex4_np1_gcdbell_cint_offset + ex4_np1_gcdbell_cint_q'length-1),
            din     => ex3_np1_gcdbell_cint,
            dout    => ex4_np1_gcdbell_cint_q);
ex4_np1_gdbell_int_latch : tri_rlmreg_p
  generic map (width => ex4_np1_gdbell_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_gdbell_int_offset to ex4_np1_gdbell_int_offset + ex4_np1_gdbell_int_q'length-1),
            scout   => sov(ex4_np1_gdbell_int_offset to ex4_np1_gdbell_int_offset + ex4_np1_gdbell_int_q'length-1),
            din     => ex3_np1_gdbell_int,
            dout    => ex4_np1_gdbell_int_q);
ex4_np1_gmcdbell_cint_latch : tri_rlmreg_p
  generic map (width => ex4_np1_gmcdbell_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_gmcdbell_cint_offset to ex4_np1_gmcdbell_cint_offset + ex4_np1_gmcdbell_cint_q'length-1),
            scout   => sov(ex4_np1_gmcdbell_cint_offset to ex4_np1_gmcdbell_cint_offset + ex4_np1_gmcdbell_cint_q'length-1),
            din     => ex3_np1_gmcdbell_cint,
            dout    => ex4_np1_gmcdbell_cint_q);
ex4_np1_ide_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex4_np1_ide_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_ide_dbg_cint_offset to ex4_np1_ide_dbg_cint_offset + ex4_np1_ide_dbg_cint_q'length-1),
            scout   => sov(ex4_np1_ide_dbg_cint_offset to ex4_np1_ide_dbg_cint_offset + ex4_np1_ide_dbg_cint_q'length-1),
            din     => ex3_np1_ide_dbg_cint,
            dout    => ex4_np1_ide_dbg_cint_q);
ex4_np1_instr_int_latch : tri_rlmreg_p
  generic map (width => ex4_np1_instr_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_instr_int_offset to ex4_np1_instr_int_offset + ex4_np1_instr_int_q'length-1),
            scout   => sov(ex4_np1_instr_int_offset to ex4_np1_instr_int_offset + ex4_np1_instr_int_q'length-1),
            din     => ex3_np1_instr_int,
            dout    => ex4_np1_instr_int_q);
ex4_np1_perf_int_latch : tri_rlmreg_p
  generic map (width => ex4_np1_perf_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_perf_int_offset to ex4_np1_perf_int_offset + ex4_np1_perf_int_q'length-1),
            scout   => sov(ex4_np1_perf_int_offset to ex4_np1_perf_int_offset + ex4_np1_perf_int_q'length-1),
            din     => ex3_np1_perf_int,
            dout    => ex4_np1_perf_int_q);
ex4_np1_ptr_prog_int_latch : tri_rlmreg_p
  generic map (width => ex4_np1_ptr_prog_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_ptr_prog_int_offset to ex4_np1_ptr_prog_int_offset + ex4_np1_ptr_prog_int_q'length-1),
            scout   => sov(ex4_np1_ptr_prog_int_offset to ex4_np1_ptr_prog_int_offset + ex4_np1_ptr_prog_int_q'length-1),
            din     => ex3_np1_ptr_prog_int,
            dout    => ex4_np1_ptr_prog_int_q);
ex4_np1_rfi_latch : tri_rlmreg_p
  generic map (width => ex4_np1_rfi_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_rfi_offset to ex4_np1_rfi_offset + ex4_np1_rfi_q'length-1),
            scout   => sov(ex4_np1_rfi_offset to ex4_np1_rfi_offset + ex4_np1_rfi_q'length-1),
            din     => ex3_np1_rfi,
            dout    => ex4_np1_rfi_q);
ex4_np1_run_ctl_flush_latch : tri_rlmreg_p
  generic map (width => ex4_np1_run_ctl_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_run_ctl_flush_offset to ex4_np1_run_ctl_flush_offset + ex4_np1_run_ctl_flush_q'length-1),
            scout   => sov(ex4_np1_run_ctl_flush_offset to ex4_np1_run_ctl_flush_offset + ex4_np1_run_ctl_flush_q'length-1),
            din     => ex3_np1_run_ctl_flush,
            dout    => ex4_np1_run_ctl_flush_q);
ex4_np1_sc_int_latch : tri_rlmreg_p
  generic map (width => ex4_np1_sc_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_sc_int_offset to ex4_np1_sc_int_offset + ex4_np1_sc_int_q'length-1),
            scout   => sov(ex4_np1_sc_int_offset to ex4_np1_sc_int_offset + ex4_np1_sc_int_q'length-1),
            din     => ex3_np1_sc_int,
            dout    => ex4_np1_sc_int_q);
ex4_np1_ude_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex4_np1_ude_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_ude_dbg_cint_offset to ex4_np1_ude_dbg_cint_offset + ex4_np1_ude_dbg_cint_q'length-1),
            scout   => sov(ex4_np1_ude_dbg_cint_offset to ex4_np1_ude_dbg_cint_offset + ex4_np1_ude_dbg_cint_q'length-1),
            din     => ex3_np1_ude_dbg_cint,
            dout    => ex4_np1_ude_dbg_cint_q);
ex4_np1_ude_dbg_event_latch : tri_rlmreg_p
  generic map (width => ex4_np1_ude_dbg_event_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_ude_dbg_event_offset to ex4_np1_ude_dbg_event_offset + ex4_np1_ude_dbg_event_q'length-1),
            scout   => sov(ex4_np1_ude_dbg_event_offset to ex4_np1_ude_dbg_event_offset + ex4_np1_ude_dbg_event_q'length-1),
            din     => ex3_np1_ude_dbg_event,
            dout    => ex4_np1_ude_dbg_event_q);
ex4_np1_udec_int_latch : tri_rlmreg_p
  generic map (width => ex4_np1_udec_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_udec_int_offset to ex4_np1_udec_int_offset + ex4_np1_udec_int_q'length-1),
            scout   => sov(ex4_np1_udec_int_offset to ex4_np1_udec_int_offset + ex4_np1_udec_int_q'length-1),
            din     => ex3_np1_udec_int,
            dout    => ex4_np1_udec_int_q);
ex4_np1_wdog_cint_latch : tri_rlmreg_p
  generic map (width => ex4_np1_wdog_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_wdog_cint_offset to ex4_np1_wdog_cint_offset + ex4_np1_wdog_cint_q'length-1),
            scout   => sov(ex4_np1_wdog_cint_offset to ex4_np1_wdog_cint_offset + ex4_np1_wdog_cint_q'length-1),
            din     => ex3_np1_wdog_cint,
            dout    => ex4_np1_wdog_cint_q);
ex4_np1_fu_flush_latch : tri_rlmreg_p
  generic map (width => ex4_np1_fu_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1    )
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_np1_fu_flush_offset to ex4_np1_fu_flush_offset + ex4_np1_fu_flush_q'length-1),
            scout   => sov(ex4_np1_fu_flush_offset to ex4_np1_fu_flush_offset + ex4_np1_fu_flush_q'length-1),
            din     => ex3_np1_fu_flush,
            dout    => ex4_np1_fu_flush_q);
ex4_n_ieratsx_par_mchk_mcint_latch : tri_rlmreg_p
  generic map (width => ex4_n_ieratsx_par_mchk_mcint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1      )
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_ieratsx_par_mchk_mcint_offset to ex4_n_ieratsx_par_mchk_mcint_offset + ex4_n_ieratsx_par_mchk_mcint_q'length-1),
            scout   => sov(ex4_n_ieratsx_par_mchk_mcint_offset to ex4_n_ieratsx_par_mchk_mcint_offset + ex4_n_ieratsx_par_mchk_mcint_q'length-1),
            din     => ex3_n_ieratsx_par_mchk_mcint,
            dout    => ex4_n_ieratsx_par_mchk_mcint_q);
ex4_n_tlbmh_mchk_mcint_latch : tri_rlmreg_p
  generic map (width => ex4_n_tlbmh_mchk_mcint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1    )
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_tlbmh_mchk_mcint_offset to ex4_n_tlbmh_mchk_mcint_offset + ex4_n_tlbmh_mchk_mcint_q'length-1),
            scout   => sov(ex4_n_tlbmh_mchk_mcint_offset to ex4_n_tlbmh_mchk_mcint_offset + ex4_n_tlbmh_mchk_mcint_q'length-1),
            din     => ex3_n_tlbmh_mchk_mcint     ,
            dout    => ex4_n_tlbmh_mchk_mcint_q);
ex4_n_sprg_ue_flush_latch : tri_rlmreg_p
  generic map (width => ex4_n_sprg_ue_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_sprg_ue_flush_offset to ex4_n_sprg_ue_flush_offset + ex4_n_sprg_ue_flush_q'length-1),
            scout   => sov(ex4_n_sprg_ue_flush_offset to ex4_n_sprg_ue_flush_offset + ex4_n_sprg_ue_flush_q'length-1),
            din     => ex3_n_sprg_ue_flush        ,
            dout    => ex4_n_sprg_ue_flush_q);
ex4_n_rwaccess_dstor_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_rwaccess_dstor_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_rwaccess_dstor_int_offset to ex4_n_rwaccess_dstor_int_offset + ex4_n_rwaccess_dstor_int_q'length-1),
            scout   => sov(ex4_n_rwaccess_dstor_int_offset to ex4_n_rwaccess_dstor_int_offset + ex4_n_rwaccess_dstor_int_q'length-1),
            din     => ex3_n_rwaccess_dstor_int,
            dout    => ex4_n_rwaccess_dstor_int_q);
ex4_n_exaccess_istor_int_latch : tri_rlmreg_p
  generic map (width => ex4_n_exaccess_istor_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_exaccess_istor_int_offset to ex4_n_exaccess_istor_int_offset + ex4_n_exaccess_istor_int_q'length-1),
            scout   => sov(ex4_n_exaccess_istor_int_offset to ex4_n_exaccess_istor_int_offset + ex4_n_exaccess_istor_int_q'length-1),
            din     => ex3_n_exaccess_istor_int,
            dout    => ex4_n_exaccess_istor_int_q);
ex4_sc_lev_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_sc_lev_offset),
            scout   => sov(ex4_sc_lev_offset),
            din     => ex3_sc_lev_q               ,
            dout    => ex4_sc_lev_q);
ex4_siar_sel_latch : tri_rlmreg_p
  generic map (width => ex4_siar_sel_q'length, init => 1, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_siar_sel_act     ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_siar_sel_offset to ex4_siar_sel_offset + ex4_siar_sel_q'length-1),
            scout   => sov(ex4_siar_sel_offset to ex4_siar_sel_offset + ex4_siar_sel_q'length-1),
            din     => ex4_siar_sel_d,
            dout    => ex4_siar_sel_q);
ex4_step_latch : tri_rlmreg_p
  generic map (width => ex4_step_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_step_offset to ex4_step_offset + ex4_step_q'length-1),
            scout   => sov(ex4_step_offset to ex4_step_offset + ex4_step_q'length-1),
            din     => ex4_step_d,
            dout    => ex4_step_q);
ex4_taken_bclr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_taken_bclr_offset),
            scout   => sov(ex4_taken_bclr_offset),
            din     => ex3_taken_bclr_q           ,
            dout    => ex4_taken_bclr_q);
ex4_tlb_inelig_latch : tri_rlmreg_p
  generic map (width => ex4_tlb_inelig_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_tlb_inelig_offset to ex4_tlb_inelig_offset + ex4_tlb_inelig_q'length-1),
            scout   => sov(ex4_tlb_inelig_offset to ex4_tlb_inelig_offset + ex4_tlb_inelig_q'length-1),
            din     => ex3_tlb_inelig_q           ,
            dout    => ex4_tlb_inelig_q);
ex4_ucode_val_latch : tri_rlmreg_p
  generic map (width => ex4_ucode_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_ucode_val_offset to ex4_ucode_val_offset + ex4_ucode_val_q'length-1),
            scout   => sov(ex4_ucode_val_offset to ex4_ucode_val_offset + ex4_ucode_val_q'length-1),
            din     => ex3_ucode_val              ,
            dout    => ex4_ucode_val_q);
ex4_xu_is_ucode_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_xu_is_ucode_offset),
            scout   => sov(ex4_xu_is_ucode_offset),
            din     => ex3_xu_is_ucode_q          ,
            dout    => ex4_xu_is_ucode_q);
ex4_xu_val_latch : tri_rlmreg_p
  generic map (width => ex4_xu_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_xu_val_offset to ex4_xu_val_offset + ex4_xu_val_q'length-1),
            scout   => sov(ex4_xu_val_offset to ex4_xu_val_offset + ex4_xu_val_q'length-1),
            din     => ex3_xu_val                 ,
            dout    => ex4_xu_val_q);
ex4_cia_act_latch : tri_rlmreg_p
  generic map (width => ex4_cia_act_q'length, init => 0, expand_type => expand_type, needs_sreset => 1                                           )
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_cia_act_offset to ex4_cia_act_offset + ex4_cia_act_q'length-1),
            scout   => sov(ex4_cia_act_offset to ex4_cia_act_offset + ex4_cia_act_q'length-1),
            din     => ex3_cia_act,
            dout    => ex4_cia_act_q);
ex4_n_async_dacr_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex4_n_async_dacr_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_n_async_dacr_dbg_cint_offset to ex4_n_async_dacr_dbg_cint_offset + ex4_n_async_dacr_dbg_cint_q'length-1),
            scout   => sov(ex4_n_async_dacr_dbg_cint_offset to ex4_n_async_dacr_dbg_cint_offset + ex4_n_async_dacr_dbg_cint_q'length-1),
            din     => ex3_n_async_dacr_dbg_cint,
            dout    => ex4_n_async_dacr_dbg_cint_q);
ex4_dac1r_cmpr_async_latch : tri_rlmreg_p
  generic map (width => ex4_dac1r_cmpr_async_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_dac1r_cmpr_async_offset to ex4_dac1r_cmpr_async_offset + ex4_dac1r_cmpr_async_q'length-1),
            scout   => sov(ex4_dac1r_cmpr_async_offset to ex4_dac1r_cmpr_async_offset + ex4_dac1r_cmpr_async_q'length-1),
            din     => ex4_dac1r_cmpr_async_d,
            dout    => ex4_dac1r_cmpr_async_q);
ex4_dac2r_cmpr_async_latch : tri_rlmreg_p
  generic map (width => ex4_dac2r_cmpr_async_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_dac2r_cmpr_async_offset to ex4_dac2r_cmpr_async_offset + ex4_dac2r_cmpr_async_q'length-1),
            scout   => sov(ex4_dac2r_cmpr_async_offset to ex4_dac2r_cmpr_async_offset + ex4_dac2r_cmpr_async_q'length-1),
            din     => ex4_dac2r_cmpr_async_d,
            dout    => ex4_dac2r_cmpr_async_q);
ex4_thread_stop_latch : tri_rlmreg_p
  generic map (width => ex4_thread_stop_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_thread_stop_offset to ex4_thread_stop_offset + ex4_thread_stop_q'length-1),
            scout   => sov(ex4_thread_stop_offset to ex4_thread_stop_offset + ex4_thread_stop_q'length-1),
            din     => ex3_thread_stop,
            dout    => ex4_thread_stop_q);
ex5_icmp_event_on_int_ok_latch : tri_rlmreg_p
  generic map (width => ex5_icmp_event_on_int_ok_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_icmp_event_on_int_ok_offset to ex5_icmp_event_on_int_ok_offset + ex5_icmp_event_on_int_ok_q'length-1),
            scout   => sov(ex5_icmp_event_on_int_ok_offset to ex5_icmp_event_on_int_ok_offset + ex5_icmp_event_on_int_ok_q'length-1),
            din     => ex4_icmp_event_on_int_ok,
            dout    => ex5_icmp_event_on_int_ok_q);
ex5_any_val_latch : tri_rlmreg_p
  generic map (width => ex5_any_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_any_val_offset to ex5_any_val_offset + ex5_any_val_q'length-1),
            scout   => sov(ex5_any_val_offset to ex5_any_val_offset + ex5_any_val_q'length-1),
            din     => ex4_any_val                ,
            dout    => ex5_any_val_q);
ex5_attn_flush_latch : tri_rlmreg_p
  generic map (width => ex5_attn_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_attn_flush_offset to ex5_attn_flush_offset + ex5_attn_flush_q'length-1),
            scout   => sov(ex5_attn_flush_offset to ex5_attn_flush_offset + ex5_attn_flush_q'length-1),
            din     => ex4_attn_flush,
            dout    => ex5_attn_flush_q);
ex5_axu_trap_pie_latch : tri_rlmreg_p
  generic map (width => ex5_axu_trap_pie_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_axu_trap_pie_offset to ex5_axu_trap_pie_offset + ex5_axu_trap_pie_q'length-1),
            scout   => sov(ex5_axu_trap_pie_offset to ex5_axu_trap_pie_offset + ex5_axu_trap_pie_q'length-1),
            din     => ex5_axu_trap_pie_d,
            dout    => ex5_axu_trap_pie_q);
ex5_br_taken_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_br_taken_offset),
            scout   => sov(ex5_br_taken_offset),
            din     => ex4_br_taken_q             ,
            dout    => ex5_br_taken_q);
ex5_cdbell_taken_latch : tri_rlmreg_p
  generic map (width => ex5_cdbell_taken_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_cdbell_taken_offset to ex5_cdbell_taken_offset + ex5_cdbell_taken_q'length-1),
            scout   => sov(ex5_cdbell_taken_offset to ex5_cdbell_taken_offset + ex5_cdbell_taken_q'length-1),
            din     => ex5_cdbell_taken_d,
            dout    => ex5_cdbell_taken_q);
ex5_check_bclr_latch : tri_rlmreg_p
  generic map (width => ex5_check_bclr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_check_bclr_offset to ex5_check_bclr_offset + ex5_check_bclr_q'length-1),
            scout   => sov(ex5_check_bclr_offset to ex5_check_bclr_offset + ex5_check_bclr_q'length-1),
            din     => ex5_check_bclr_d,
            dout    => ex5_check_bclr_q);
ex5_cia_p1_latch : tri_rlmreg_p
  generic map (width => ex5_cia_p1_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_cia_p1_offset to ex5_cia_p1_offset + ex5_cia_p1_q'length-1),
            scout   => sov(ex5_cia_p1_offset to ex5_cia_p1_offset + ex5_cia_p1_q'length-1),
            din     => ex5_cia_p1_d,
            dout    => ex5_cia_p1_q);
ex5_dbell_taken_latch : tri_rlmreg_p
  generic map (width => ex5_dbell_taken_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dbell_taken_offset to ex5_dbell_taken_offset + ex5_dbell_taken_q'length-1),
            scout   => sov(ex5_dbell_taken_offset to ex5_dbell_taken_offset + ex5_dbell_taken_q'length-1),
            din     => ex5_dbell_taken_d,
            dout    => ex5_dbell_taken_q);
ex5_dbsr_update_latch : tri_rlmreg_p
  generic map (width => ex5_dbsr_update_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dbsr_update_offset to ex5_dbsr_update_offset + ex5_dbsr_update_q'length-1),
            scout   => sov(ex5_dbsr_update_offset to ex5_dbsr_update_offset + ex5_dbsr_update_q'length-1),
            din     => ex4_dbsr_update,
            dout    => ex5_dbsr_update_q);
ex5_dear_update_saved_latch : tri_rlmreg_p
  generic map (width => ex5_dear_update_saved_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dear_update_saved_offset to ex5_dear_update_saved_offset + ex5_dear_update_saved_q'length-1),
            scout   => sov(ex5_dear_update_saved_offset to ex5_dear_update_saved_offset + ex5_dear_update_saved_q'length-1),
            din     => ex5_dear_update_saved_d,
            dout    => ex5_dear_update_saved_q);
ex5_deratre_par_err_latch : tri_rlmreg_p
  generic map (width => ex5_deratre_par_err_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_deratre_par_err_offset to ex5_deratre_par_err_offset + ex5_deratre_par_err_q'length-1),
            scout   => sov(ex5_deratre_par_err_offset to ex5_deratre_par_err_offset + ex5_deratre_par_err_q'length-1),
            din     => lsu_xu_ex4_derat_par_err   ,
            dout    => ex5_deratre_par_err_q);
ex5_div_set_barr_latch : tri_rlmreg_p
  generic map (width => ex5_div_set_barr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_div_set_barr_offset to ex5_div_set_barr_offset + ex5_div_set_barr_q'length-1),
            scout   => sov(ex5_div_set_barr_offset to ex5_div_set_barr_offset + ex5_div_set_barr_q'length-1),
            din     => ex5_div_set_barr_d,
            dout    => ex5_div_set_barr_q);
ex5_dsigs_latch : tri_rlmreg_p
  generic map (width => ex5_dsigs_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dsigs_offset to ex5_dsigs_offset + ex5_dsigs_q'length-1),
            scout   => sov(ex5_dsigs_offset to ex5_dsigs_offset + ex5_dsigs_q'length-1),
            din     => ex5_dsigs_d,
            dout    => ex5_dsigs_q);
ex5_dtlbgs_latch : tri_rlmreg_p
  generic map (width => ex5_dtlbgs_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dtlbgs_offset to ex5_dtlbgs_offset + ex5_dtlbgs_q'length-1),
            scout   => sov(ex5_dtlbgs_offset to ex5_dtlbgs_offset + ex5_dtlbgs_q'length-1),
            din     => ex5_dtlbgs_d,
            dout    => ex5_dtlbgs_q);
ex5_err_nia_miscmpr_latch : tri_rlmreg_p
  generic map (width => ex5_err_nia_miscmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_err_nia_miscmpr_offset to ex5_err_nia_miscmpr_offset + ex5_err_nia_miscmpr_q'length-1),
            scout   => sov(ex5_err_nia_miscmpr_offset to ex5_err_nia_miscmpr_offset + ex5_err_nia_miscmpr_q'length-1),
            din     => ex5_err_nia_miscmpr_d,
            dout    => ex5_err_nia_miscmpr_q);
ex5_ext_dbg_err_latch : tri_rlmreg_p
  generic map (width => ex5_ext_dbg_err_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_ext_dbg_err_offset to ex5_ext_dbg_err_offset + ex5_ext_dbg_err_q'length-1),
            scout   => sov(ex5_ext_dbg_err_offset to ex5_ext_dbg_err_offset + ex5_ext_dbg_err_q'length-1),
            din     => ex5_ext_dbg_err_d,
            dout    => ex5_ext_dbg_err_q);
ex5_ext_dbg_ext_latch : tri_rlmreg_p
  generic map (width => ex5_ext_dbg_ext_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_ext_dbg_ext_offset to ex5_ext_dbg_ext_offset + ex5_ext_dbg_ext_q'length-1),
            scout   => sov(ex5_ext_dbg_ext_offset to ex5_ext_dbg_ext_offset + ex5_ext_dbg_ext_q'length-1),
            din     => ex5_ext_dbg_ext_d,
            dout    => ex5_ext_dbg_ext_q);
ex5_extgs_latch : tri_rlmreg_p
  generic map (width => ex5_extgs_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_extgs_offset to ex5_extgs_offset + ex5_extgs_q'length-1),
            scout   => sov(ex5_extgs_offset to ex5_extgs_offset + ex5_extgs_q'length-1),
            din     => ex5_extgs_d,
            dout    => ex5_extgs_q);
ex5_flush_latch : tri_rlmreg_p
  generic map (width => ex5_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_flush_offset to ex5_flush_offset + ex5_flush_q'length-1),
            scout   => sov(ex5_flush_offset to ex5_flush_offset + ex5_flush_q'length-1),
            din     => ex4_flush                  ,
            dout    => ex5_flush_q);
ex5_force_gsrr_latch : tri_rlmreg_p
  generic map (width => ex5_force_gsrr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_force_gsrr_offset to ex5_force_gsrr_offset + ex5_force_gsrr_q'length-1),
            scout   => sov(ex5_force_gsrr_offset to ex5_force_gsrr_offset + ex5_force_gsrr_q'length-1),
            din     => ex5_force_gsrr_d,
            dout    => ex5_force_gsrr_q);
ex5_gcdbell_taken_latch : tri_rlmreg_p
  generic map (width => ex5_gcdbell_taken_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_gcdbell_taken_offset to ex5_gcdbell_taken_offset + ex5_gcdbell_taken_q'length-1),
            scout   => sov(ex5_gcdbell_taken_offset to ex5_gcdbell_taken_offset + ex5_gcdbell_taken_q'length-1),
            din     => ex5_gcdbell_taken_d,
            dout    => ex5_gcdbell_taken_q);
ex5_gdbell_taken_latch : tri_rlmreg_p
  generic map (width => ex5_gdbell_taken_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_gdbell_taken_offset to ex5_gdbell_taken_offset + ex5_gdbell_taken_q'length-1),
            scout   => sov(ex5_gdbell_taken_offset to ex5_gdbell_taken_offset + ex5_gdbell_taken_q'length-1),
            din     => ex5_gdbell_taken_d,
            dout    => ex5_gdbell_taken_q);
ex5_gmcdbell_taken_latch : tri_rlmreg_p
  generic map (width => ex5_gmcdbell_taken_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_gmcdbell_taken_offset to ex5_gmcdbell_taken_offset + ex5_gmcdbell_taken_q'length-1),
            scout   => sov(ex5_gmcdbell_taken_offset to ex5_gmcdbell_taken_offset + ex5_gmcdbell_taken_q'length-1),
            din     => ex5_gmcdbell_taken_d,
            dout    => ex5_gmcdbell_taken_q);
ex5_ieratre_par_err_latch : tri_rlmreg_p
  generic map (width => ex5_ieratre_par_err_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_ieratre_par_err_offset to ex5_ieratre_par_err_offset + ex5_ieratre_par_err_q'length-1),
            scout   => sov(ex5_ieratre_par_err_offset to ex5_ieratre_par_err_offset + ex5_ieratre_par_err_q'length-1),
            din     => iu_xu_ierat_ex4_par_err    ,
            dout    => ex5_ieratre_par_err_q);
ex5_in_ucode_latch : tri_rlmreg_p
  generic map (width => ex5_in_ucode_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_in_ucode_offset to ex5_in_ucode_offset + ex5_in_ucode_q'length-1),
            scout   => sov(ex5_in_ucode_offset to ex5_in_ucode_offset + ex5_in_ucode_q'length-1),
            din     => ex5_in_ucode_d,
            dout    => ex5_in_ucode_q);
ex5_instr_cpl_latch : tri_rlmreg_p
  generic map (width => ex5_instr_cpl_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_instr_cpl_offset to ex5_instr_cpl_offset + ex5_instr_cpl_q'length-1),
            scout   => sov(ex5_instr_cpl_offset to ex5_instr_cpl_offset + ex5_instr_cpl_q'length-1),
            din     => ex4_instr_cpl,
            dout    => ex5_instr_cpl_q);
ex5_is_any_rfi_latch : tri_rlmreg_p
  generic map (width => ex5_is_any_rfi_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_any_rfi_offset to ex5_is_any_rfi_offset + ex5_is_any_rfi_q'length-1),
            scout   => sov(ex5_is_any_rfi_offset to ex5_is_any_rfi_offset + ex5_is_any_rfi_q'length-1),
            din     => ex4_is_any_rfi,
            dout    => ex5_is_any_rfi_q);
ex5_is_attn_latch : tri_rlmreg_p
  generic map (width => ex5_is_attn_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_attn_offset to ex5_is_attn_offset + ex5_is_attn_q'length-1),
            scout   => sov(ex5_is_attn_offset to ex5_is_attn_offset + ex5_is_attn_q'length-1),
            din     => ex5_is_attn_d,
            dout    => ex5_is_attn_q);
ex5_is_crit_int_latch : tri_rlmreg_p
  generic map (width => ex5_is_crit_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_crit_int_offset to ex5_is_crit_int_offset + ex5_is_crit_int_q'length-1),
            scout   => sov(ex5_is_crit_int_offset to ex5_is_crit_int_offset + ex5_is_crit_int_q'length-1),
            din     => ex4_is_crit_int            ,
            dout    => ex5_is_crit_int_q);
ex5_is_mchk_int_latch : tri_rlmreg_p
  generic map (width => ex5_is_mchk_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_mchk_int_offset to ex5_is_mchk_int_offset + ex5_is_mchk_int_q'length-1),
            scout   => sov(ex5_is_mchk_int_offset to ex5_is_mchk_int_offset + ex5_is_mchk_int_q'length-1),
            din     => ex4_is_mchk_int            ,
            dout    => ex5_is_mchk_int_q);
ex5_is_mtmsr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_mtmsr_offset),
            scout   => sov(ex5_is_mtmsr_offset),
            din     => ex4_is_mtmsr_q             ,
            dout    => ex5_is_mtmsr_q);
ex5_is_isync_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_isync_offset),
            scout   => sov(ex5_is_isync_offset),
            din     => ex4_is_isync_q             ,
            dout    => ex5_is_isync_q);
ex5_is_tlbwe_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_tlbwe_offset),
            scout   => sov(ex5_is_tlbwe_offset),
            din     => ex4_is_tlbwe_q             ,
            dout    => ex5_is_tlbwe_q);
ex5_isigs_latch : tri_rlmreg_p
  generic map (width => ex5_isigs_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_isigs_offset to ex5_isigs_offset + ex5_isigs_q'length-1),
            scout   => sov(ex5_isigs_offset to ex5_isigs_offset + ex5_isigs_q'length-1),
            din     => ex5_isigs_d,
            dout    => ex5_isigs_q);
ex5_itlbgs_latch : tri_rlmreg_p
  generic map (width => ex5_itlbgs_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_itlbgs_offset to ex5_itlbgs_offset + ex5_itlbgs_q'length-1),
            scout   => sov(ex5_itlbgs_offset to ex5_itlbgs_offset + ex5_itlbgs_q'length-1),
            din     => ex5_itlbgs_d,
            dout    => ex5_itlbgs_q);
ex5_lsu_set_barr_latch : tri_rlmreg_p
  generic map (width => ex5_lsu_set_barr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_lsu_set_barr_offset to ex5_lsu_set_barr_offset + ex5_lsu_set_barr_q'length-1),
            scout   => sov(ex5_lsu_set_barr_offset to ex5_lsu_set_barr_offset + ex5_lsu_set_barr_q'length-1),
            din     => ex5_lsu_set_barr_d,
            dout    => ex5_lsu_set_barr_q);
ex5_mem_attr_val_latch : tri_rlmreg_p
  generic map (width => ex5_mem_attr_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_mem_attr_val_offset to ex5_mem_attr_val_offset + ex5_mem_attr_val_q'length-1),
            scout   => sov(ex5_mem_attr_val_offset to ex5_mem_attr_val_offset + ex5_mem_attr_val_q'length-1),
            din     => ex4_mem_attr_val,
            dout    => ex5_mem_attr_val_q);
ex5_mmu_hold_val_latch : tri_rlmreg_p
  generic map (width => ex5_mmu_hold_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_mmu_hold_val_offset to ex5_mmu_hold_val_offset + ex5_mmu_hold_val_q'length-1),
            scout   => sov(ex5_mmu_hold_val_offset to ex5_mmu_hold_val_offset + ex5_mmu_hold_val_q'length-1),
            din     => ex4_mmu_hold_val_q,
            dout    => ex5_mmu_hold_val_q);
ex5_n_dmiss_flush_latch : tri_rlmreg_p
  generic map (width => ex5_n_dmiss_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_n_dmiss_flush_offset to ex5_n_dmiss_flush_offset + ex5_n_dmiss_flush_q'length-1),
            scout   => sov(ex5_n_dmiss_flush_offset to ex5_n_dmiss_flush_offset + ex5_n_dmiss_flush_q'length-1),
            din     => ex4_n_dmiss_flush,
            dout    => ex5_n_dmiss_flush_q);
ex5_n_ext_dbg_stopc_flush_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_n_ext_dbg_stopc_flush_offset),
            scout   => sov(ex5_n_ext_dbg_stopc_flush_offset),
            din     => ex5_n_ext_dbg_stopc_flush_d,
            dout    => ex5_n_ext_dbg_stopc_flush_q);
ex5_n_ext_dbg_stopt_flush_latch : tri_rlmreg_p
  generic map (width => ex5_n_ext_dbg_stopt_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_n_ext_dbg_stopt_flush_offset to ex5_n_ext_dbg_stopt_flush_offset + ex5_n_ext_dbg_stopt_flush_q'length-1),
            scout   => sov(ex5_n_ext_dbg_stopt_flush_offset to ex5_n_ext_dbg_stopt_flush_offset + ex5_n_ext_dbg_stopt_flush_q'length-1),
            din     => ex5_n_ext_dbg_stopt_flush_d,
            dout    => ex5_n_ext_dbg_stopt_flush_q);
ex5_n_imiss_flush_latch : tri_rlmreg_p
  generic map (width => ex5_n_imiss_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_n_imiss_flush_offset to ex5_n_imiss_flush_offset + ex5_n_imiss_flush_q'length-1),
            scout   => sov(ex5_n_imiss_flush_offset to ex5_n_imiss_flush_offset + ex5_n_imiss_flush_q'length-1),
            din     => ex4_n_imiss_flush,
            dout    => ex5_n_imiss_flush_q);
ex5_n_ptemiss_dlrat_int_latch : tri_rlmreg_p
  generic map (width => ex5_n_ptemiss_dlrat_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_n_ptemiss_dlrat_int_offset to ex5_n_ptemiss_dlrat_int_offset + ex5_n_ptemiss_dlrat_int_q'length-1),
            scout   => sov(ex5_n_ptemiss_dlrat_int_offset to ex5_n_ptemiss_dlrat_int_offset + ex5_n_ptemiss_dlrat_int_q'length-1),
            din     => ex4_n_ptemiss_dlrat_int_q  ,
            dout    => ex5_n_ptemiss_dlrat_int_q);
ex5_np1_run_ctl_flush_latch : tri_rlmreg_p
  generic map (width => ex5_np1_run_ctl_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_np1_run_ctl_flush_offset to ex5_np1_run_ctl_flush_offset + ex5_np1_run_ctl_flush_q'length-1),
            scout   => sov(ex5_np1_run_ctl_flush_offset to ex5_np1_run_ctl_flush_offset + ex5_np1_run_ctl_flush_q'length-1),
            din     => ex4_np1_run_ctl_flush,
            dout    => ex5_np1_run_ctl_flush_q);
ex5_dbsr_ide_latch : tri_rlmreg_p
  generic map (width => ex5_dbsr_ide_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dbsr_ide_offset to ex5_dbsr_ide_offset + ex5_dbsr_ide_q'length-1),
            scout   => sov(ex5_dbsr_ide_offset to ex5_dbsr_ide_offset + ex5_dbsr_ide_q'length-1),
            din     => ex5_dbsr_ide_d,
            dout    => ex5_dbsr_ide_q);
ex5_perf_dtlb_latch : tri_rlmreg_p
  generic map (width => ex5_perf_dtlb_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_perf_dtlb_offset to ex5_perf_dtlb_offset + ex5_perf_dtlb_q'length-1),
            scout   => sov(ex5_perf_dtlb_offset to ex5_perf_dtlb_offset + ex5_perf_dtlb_q'length-1),
            din     => ex5_perf_dtlb_d,
            dout    => ex5_perf_dtlb_q);
ex5_perf_itlb_latch : tri_rlmreg_p
  generic map (width => ex5_perf_itlb_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_perf_itlb_offset to ex5_perf_itlb_offset + ex5_perf_itlb_q'length-1),
            scout   => sov(ex5_perf_itlb_offset to ex5_perf_itlb_offset + ex5_perf_itlb_q'length-1),
            din     => ex5_perf_itlb_d,
            dout    => ex5_perf_itlb_q);
ex5_ram_done_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_ram_done_offset),
            scout   => sov(ex5_ram_done_offset),
            din     => ex5_ram_done_d,
            dout    => ex5_ram_done_q);
ex5_ram_issue_latch : tri_rlmreg_p
  generic map (width => ex5_ram_issue_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_ram_issue_offset to ex5_ram_issue_offset + ex5_ram_issue_q'length-1),
            scout   => sov(ex5_ram_issue_offset to ex5_ram_issue_offset + ex5_ram_issue_q'length-1),
            din     => ex5_ram_issue_d,
            dout    => ex5_ram_issue_q);
ex5_rt_latch : tri_rlmreg_p
  generic map (width => ex5_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_rt_offset to ex5_rt_offset + ex5_rt_q'length-1),
            scout   => sov(ex5_rt_offset to ex5_rt_offset + ex5_rt_q'length-1),
            din     => mux_cpl_ex4_rt             ,
            dout    => ex5_rt_q);
ex5_sel_rt_latch : tri_rlmreg_p
  generic map (width => ex5_sel_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_sel_rt_offset to ex5_sel_rt_offset + ex5_sel_rt_q'length-1),
            scout   => sov(ex5_sel_rt_offset to ex5_sel_rt_offset + ex5_sel_rt_q'length-1),
            din     => ex5_sel_rt_d,
            dout    => ex5_sel_rt_q);
ex5_srr0_dec_latch : tri_rlmreg_p
  generic map (width => ex5_srr0_dec_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_srr0_dec_offset to ex5_srr0_dec_offset + ex5_srr0_dec_q'length-1),
            scout   => sov(ex5_srr0_dec_offset to ex5_srr0_dec_offset + ex5_srr0_dec_q'length-1),
            din     => ex5_srr0_dec_d,
            dout    => ex5_srr0_dec_q);
ex5_tlb_inelig_latch : tri_rlmreg_p
  generic map (width => ex5_tlb_inelig_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_tlb_inelig_offset to ex5_tlb_inelig_offset + ex5_tlb_inelig_q'length-1),
            scout   => sov(ex5_tlb_inelig_offset to ex5_tlb_inelig_offset + ex5_tlb_inelig_q'length-1),
            din     => ex4_tlb_inelig_q           ,
            dout    => ex5_tlb_inelig_q);
ex5_uc_cia_val_latch : tri_rlmreg_p
  generic map (width => ex5_uc_cia_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_uc_cia_val_offset to ex5_uc_cia_val_offset + ex5_uc_cia_val_q'length-1),
            scout   => sov(ex5_uc_cia_val_offset to ex5_uc_cia_val_offset + ex5_uc_cia_val_q'length-1),
            din     => ex5_uc_cia_val_d,
            dout    => ex5_uc_cia_val_q);
ex5_xu_ifar_latch : tri_rlmreg_p
  generic map (width => ex5_xu_ifar_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_xu_ifar_offset to ex5_xu_ifar_offset + ex5_xu_ifar_q'length-1),
            scout   => sov(ex5_xu_ifar_offset to ex5_xu_ifar_offset + ex5_xu_ifar_q'length-1),
            din     => ex5_xu_ifar_d,
            dout    => ex5_xu_ifar_q);
ex5_xu_val_latch : tri_rlmreg_p
  generic map (width => ex5_xu_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_xu_val_offset to ex5_xu_val_offset + ex5_xu_val_q'length-1),
            scout   => sov(ex5_xu_val_offset to ex5_xu_val_offset + ex5_xu_val_q'length-1),
            din     => ex4_xu_val                 ,
            dout    => ex5_xu_val_q);
ex5_n_flush_sprg_ue_flush_latch : tri_rlmreg_p
  generic map (width => ex5_n_flush_sprg_ue_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_n_flush_sprg_ue_flush_offset to ex5_n_flush_sprg_ue_flush_offset + ex5_n_flush_sprg_ue_flush_q'length-1),
            scout   => sov(ex5_n_flush_sprg_ue_flush_offset to ex5_n_flush_sprg_ue_flush_offset + ex5_n_flush_sprg_ue_flush_q'length-1),
            din     => ex4_n_flush_sprg_ue_flush,
            dout    => ex5_n_flush_sprg_ue_flush_q);
ex5_mcsr_act_latch : tri_rlmreg_p
  generic map (width => ex5_mcsr_act_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_mcsr_act_offset to ex5_mcsr_act_offset + ex5_mcsr_act_q'length-1),
            scout   => sov(ex5_mcsr_act_offset to ex5_mcsr_act_offset + ex5_mcsr_act_q'length-1),
            din     => ex4_mcsr_act               ,
            dout    => ex5_mcsr_act_q);
ex6_mcsr_act_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_mcsr_act_offset),
            scout   => sov(ex6_mcsr_act_offset),
            din     => ex6_mcsr_act_d             ,
            dout    => ex6_mcsr_act_q);
ex6_late_flush_latch : tri_regk
  generic map (width => ex6_late_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex5_late_flush_q(0),
            dout    => ex6_late_flush_q);
ex6_mmu_hold_val_latch : tri_regk
  generic map (width => ex6_mmu_hold_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_nsl_thold_0_b,
            din     => ex5_mmu_hold_val_q,
            dout    => ex6_mmu_hold_val_q);
ex6_ram_done_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_ram_done_offset),
            scout   => sov(ex6_ram_done_offset),
            din     => ex5_ram_done_q             ,
            dout    => ex6_ram_done_q);
ex6_ram_interrupt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_ram_interrupt_offset),
            scout   => sov(ex6_ram_interrupt_offset),
            din     => ex6_ram_interrupt_d,
            dout    => ex6_ram_interrupt_q);
ex6_ram_issue_latch : tri_rlmreg_p
  generic map (width => ex6_ram_issue_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_ram_issue_offset to ex6_ram_issue_offset + ex6_ram_issue_q'length-1),
            scout   => sov(ex6_ram_issue_offset to ex6_ram_issue_offset + ex6_ram_issue_q'length-1),
            din     => ex6_ram_issue_d,
            dout    => ex6_ram_issue_q);
ex7_ram_issue_latch : tri_rlmreg_p
  generic map (width => ex7_ram_issue_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex7_ram_issue_offset to ex7_ram_issue_offset + ex7_ram_issue_q'length-1),
            scout   => sov(ex7_ram_issue_offset to ex7_ram_issue_offset + ex7_ram_issue_q'length-1),
            din     => ex6_ram_issue_q,
            dout    => ex7_ram_issue_q);
ex8_ram_issue_latch : tri_rlmreg_p
  generic map (width => ex8_ram_issue_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex8_ram_issue_offset to ex8_ram_issue_offset + ex8_ram_issue_q'length-1),
            scout   => sov(ex8_ram_issue_offset to ex8_ram_issue_offset + ex8_ram_issue_q'length-1),
            din     => ex7_ram_issue_q,
            dout    => ex8_ram_issue_q);
ex6_set_barr_latch : tri_regk
  generic map (width => ex6_set_barr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex6_set_barr_d,
            dout    => ex6_set_barr_q);
ex6_step_done_latch : tri_rlmreg_p
  generic map (width => ex6_step_done_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_step_done_offset to ex6_step_done_offset + ex6_step_done_q'length-1),
            scout   => sov(ex6_step_done_offset to ex6_step_done_offset + ex6_step_done_q'length-1),
            din     => ex5_step_done,
            dout    => ex6_step_done_q);
ex6_xu_val_latch : tri_rlmreg_p
  generic map (width => ex6_xu_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_xu_val_offset to ex6_xu_val_offset + ex6_xu_val_q'length-1),
            scout   => sov(ex6_xu_val_offset to ex6_xu_val_offset + ex6_xu_val_q'length-1),
            din     => ex5_xu_val_q               ,
            dout    => ex6_xu_val_q);
ex6_is_tlbwe_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_is_tlbwe_q             ,
            dout(0) => ex6_is_tlbwe_q);
ex7_is_tlbwe_latch : tri_rlmreg_p
  generic map (width => ex7_is_tlbwe_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex7_is_tlbwe_offset to ex7_is_tlbwe_offset + ex7_is_tlbwe_q'length-1),
            scout   => sov(ex7_is_tlbwe_offset to ex7_is_tlbwe_offset + ex7_is_tlbwe_q'length-1),
            din     => ex7_is_tlbwe_d,
            dout    => ex7_is_tlbwe_q);
ex8_is_tlbwe_latch : tri_rlmreg_p
  generic map (width => ex8_is_tlbwe_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex8_is_tlbwe_offset to ex8_is_tlbwe_offset + ex8_is_tlbwe_q'length-1),
            scout   => sov(ex8_is_tlbwe_offset to ex8_is_tlbwe_offset + ex8_is_tlbwe_q'length-1),
            din     => ex7_is_tlbwe_q             ,
            dout    => ex8_is_tlbwe_q);
ccr2_ap_latch : tri_rlmreg_p
  generic map (width => ccr2_ap_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ccr2_ap_offset to ccr2_ap_offset + ccr2_ap_q'length-1),
            scout   => sov(ccr2_ap_offset to ccr2_ap_offset + ccr2_ap_q'length-1),
            din     => spr_ccr2_ap                ,
            dout    => ccr2_ap_q);
cpl_quiesced_latch : tri_rlmreg_p
  generic map (width => cpl_quiesced_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(cpl_quiesced_offset to cpl_quiesced_offset + cpl_quiesced_q'length-1),
            scout   => sov(cpl_quiesced_offset to cpl_quiesced_offset + cpl_quiesced_q'length-1),
            din     => cpl_quiesced_d,
            dout    => cpl_quiesced_q);
dbcr0_idm_latch : tri_rlmreg_p
  generic map (width => dbcr0_idm_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act_q                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr0_idm_offset to dbcr0_idm_offset + dbcr0_idm_q'length-1),
            scout   => sov(dbcr0_idm_offset to dbcr0_idm_offset + dbcr0_idm_q'length-1),
            din     => spr_dbcr0_idm              ,
            dout    => dbcr0_idm_q);
dci_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dci_val_offset),
            scout   => sov(dci_val_offset),
            din     => dci_val_d,
            dout    => dci_val_q);
debug_event_en_latch : tri_rlmreg_p
  generic map (width => debug_event_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(debug_event_en_offset to debug_event_en_offset + debug_event_en_q'length-1),
            scout   => sov(debug_event_en_offset to debug_event_en_offset + debug_event_en_q'length-1),
            din     => debug_event_en_d,
            dout    => debug_event_en_q);
derat_hold_present_latch : tri_rlmreg_p
  generic map (width => derat_hold_present_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(derat_hold_present_offset to derat_hold_present_offset + derat_hold_present_q'length-1),
            scout   => sov(derat_hold_present_offset to derat_hold_present_offset + derat_hold_present_q'length-1),
            din     => derat_hold_present_d,
            dout    => derat_hold_present_q);
ext_dbg_act_err_latch : tri_rlmreg_p
  generic map (width => ext_dbg_act_err_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ext_dbg_act_err_offset to ext_dbg_act_err_offset + ext_dbg_act_err_q'length-1),
            scout   => sov(ext_dbg_act_err_offset to ext_dbg_act_err_offset + ext_dbg_act_err_q'length-1),
            din     => ext_dbg_act_err_d,
            dout    => ext_dbg_act_err_q);
ext_dbg_act_ext_latch : tri_rlmreg_p
  generic map (width => ext_dbg_act_ext_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ext_dbg_act_ext_offset to ext_dbg_act_ext_offset + ext_dbg_act_ext_q'length-1),
            scout   => sov(ext_dbg_act_ext_offset to ext_dbg_act_ext_offset + ext_dbg_act_ext_q'length-1),
            din     => ext_dbg_act_ext_d,
            dout    => ext_dbg_act_ext_q);
ext_dbg_stop_core_latch : tri_rlmreg_p
  generic map (width => ext_dbg_stop_core_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ext_dbg_stop_core_offset to ext_dbg_stop_core_offset + ext_dbg_stop_core_q'length-1),
            scout   => sov(ext_dbg_stop_core_offset to ext_dbg_stop_core_offset + ext_dbg_stop_core_q'length-1),
            din     => ext_dbg_stop_core_d,
            dout    => ext_dbg_stop_core_q);
ext_dbg_stop_n_latch : tri_rlmreg_p
  generic map (width => ext_dbg_stop_n_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ext_dbg_stop_n_offset to ext_dbg_stop_n_offset + ext_dbg_stop_n_q'length-1),
            scout   => sov(ext_dbg_stop_n_offset to ext_dbg_stop_n_offset + ext_dbg_stop_n_q'length-1),
            din     => ext_dbg_stop_n_d,
            dout    => ext_dbg_stop_n_q);
external_mchk_latch : tri_rlmreg_p
  generic map (width => external_mchk_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(external_mchk_offset to external_mchk_offset + external_mchk_q'length-1),
            scout   => sov(external_mchk_offset to external_mchk_offset + external_mchk_q'length-1),
            din     => spr_cpl_external_mchk        ,
            dout    => external_mchk_q);
exx_multi_flush_latch : tri_rlmreg_p
  generic map (width => exx_multi_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_multi_flush_offset to exx_multi_flush_offset + exx_multi_flush_q'length-1),
            scout   => sov(exx_multi_flush_offset to exx_multi_flush_offset + exx_multi_flush_q'length-1),
            din     => exx_multi_flush_d,
            dout    => exx_multi_flush_q);
force_ude_latch : tri_rlmreg_p
  generic map (width => force_ude_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(force_ude_offset to force_ude_offset + force_ude_q'length-1),
            scout   => sov(force_ude_offset to force_ude_offset + force_ude_q'length-1),
            din     => pc_xu_force_ude            ,
            dout    => force_ude_q);
fu_rf_seq_end_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(fu_rf_seq_end_offset),
            scout   => sov(fu_rf_seq_end_offset),
            din     => fu_xu_regfile_seq_end      ,
            dout    => fu_rf_seq_end_q);
fu_rfpe_ack_latch : tri_rlmreg_p
  generic map (width => fu_rfpe_ack_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(fu_rfpe_ack_offset to fu_rfpe_ack_offset + fu_rfpe_ack_q'length-1),
            scout   => sov(fu_rfpe_ack_offset to fu_rfpe_ack_offset + fu_rfpe_ack_q'length-1),
            din     => fu_rfpe_ack_d,
            dout    => fu_rfpe_ack_q);
fu_rfpe_hold_present_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(fu_rfpe_hold_present_offset),
            scout   => sov(fu_rfpe_hold_present_offset),
            din     => fu_rfpe_hold_present_d,
            dout    => fu_rfpe_hold_present_q);
ici_hold_present_latch : tri_rlmreg_p
  generic map (width => ici_hold_present_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ici_hold_present_offset to ici_hold_present_offset + ici_hold_present_q'length-1),
            scout   => sov(ici_hold_present_offset to ici_hold_present_offset + ici_hold_present_q'length-1),
            din     => ici_hold_present_d,
            dout    => ici_hold_present_q);
ici_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ici_val_offset),
            scout   => sov(ici_val_offset),
            din     => ici_val_d,
            dout    => ici_val_q);
ierat_hold_present_latch : tri_rlmreg_p
  generic map (width => ierat_hold_present_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ierat_hold_present_offset to ierat_hold_present_offset + ierat_hold_present_q'length-1),
            scout   => sov(ierat_hold_present_offset to ierat_hold_present_offset + ierat_hold_present_q'length-1),
            din     => ierat_hold_present_d,
            dout    => ierat_hold_present_q);
mmu_eratmiss_done_latch : tri_rlmreg_p
  generic map (width => mmu_eratmiss_done_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mmu_eratmiss_done_offset to mmu_eratmiss_done_offset + mmu_eratmiss_done_q'length-1),
            scout   => sov(mmu_eratmiss_done_offset to mmu_eratmiss_done_offset + mmu_eratmiss_done_q'length-1),
            din     => mm_xu_eratmiss_done        ,
            dout    => mmu_eratmiss_done_q);
mmu_hold_present_latch : tri_rlmreg_p
  generic map (width => mmu_hold_present_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mmu_hold_present_offset to mmu_hold_present_offset + mmu_hold_present_q'length-1),
            scout   => sov(mmu_hold_present_offset to mmu_hold_present_offset + mmu_hold_present_q'length-1),
            din     => mmu_hold_present_d,
            dout    => mmu_hold_present_q);
mmu_hold_request_latch : tri_rlmreg_p
  generic map (width => mmu_hold_request_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mmu_hold_request_offset to mmu_hold_request_offset + mmu_hold_request_q'length-1),
            scout   => sov(mmu_hold_request_offset to mmu_hold_request_offset + mmu_hold_request_q'length-1),
            din     => mmu_hold_request_d,
            dout    => mmu_hold_request_q);
msr_cm_latch : tri_rlmreg_p
  generic map (width => msr_cm_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_w_int_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msr_cm_offset to msr_cm_offset + msr_cm_q'length-1),
            scout   => sov(msr_cm_offset to msr_cm_offset + msr_cm_q'length-1),
            din     => spr_msr_cm                 ,
            dout    => msr_cm_q);
msr_de_latch : tri_rlmreg_p
  generic map (width => msr_de_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_w_int_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msr_de_offset to msr_de_offset + msr_de_q'length-1),
            scout   => sov(msr_de_offset to msr_de_offset + msr_de_q'length-1),
            din     => spr_msr_de                 ,
            dout    => msr_de_q);
msr_fp_latch : tri_rlmreg_p
  generic map (width => msr_fp_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_w_int_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msr_fp_offset to msr_fp_offset + msr_fp_q'length-1),
            scout   => sov(msr_fp_offset to msr_fp_offset + msr_fp_q'length-1),
            din     => spr_msr_fp                 ,
            dout    => msr_fp_q);
msr_gs_latch : tri_rlmreg_p
  generic map (width => msr_gs_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_w_int_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msr_gs_offset to msr_gs_offset + msr_gs_q'length-1),
            scout   => sov(msr_gs_offset to msr_gs_offset + msr_gs_q'length-1),
            din     => spr_msr_gs                 ,
            dout    => msr_gs_q);
msr_me_latch : tri_rlmreg_p
  generic map (width => msr_me_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_w_int_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msr_me_offset to msr_me_offset + msr_me_q'length-1),
            scout   => sov(msr_me_offset to msr_me_offset + msr_me_q'length-1),
            din     => spr_msr_me                 ,
            dout    => msr_me_q);
msr_pr_latch : tri_rlmreg_p
  generic map (width => msr_pr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_w_int_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msr_pr_offset to msr_pr_offset + msr_pr_q'length-1),
            scout   => sov(msr_pr_offset to msr_pr_offset + msr_pr_q'length-1),
            din     => spr_msr_pr                 ,
            dout    => msr_pr_q);
msr_spv_latch : tri_rlmreg_p
  generic map (width => msr_spv_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_w_int_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msr_spv_offset to msr_spv_offset + msr_spv_q'length-1),
            scout   => sov(msr_spv_offset to msr_spv_offset + msr_spv_q'length-1),
            din     => spr_msr_spv                ,
            dout    => msr_spv_q);
msr_ucle_latch : tri_rlmreg_p
  generic map (width => msr_ucle_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_w_int_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msr_ucle_offset to msr_ucle_offset + msr_ucle_q'length-1),
            scout   => sov(msr_ucle_offset to msr_ucle_offset + msr_ucle_q'length-1),
            din     => spr_msr_ucle               ,
            dout    => msr_ucle_q);
msrp_uclep_latch : tri_rlmreg_p
  generic map (width => msrp_uclep_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act_q                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msrp_uclep_offset to msrp_uclep_offset + msrp_uclep_q'length-1),
            scout   => sov(msrp_uclep_offset to msrp_uclep_offset + msrp_uclep_q'length-1),
            din     => spr_msrp_uclep             ,
            dout    => msrp_uclep_q);
pc_dbg_action_latch : tri_rlmreg_p
  generic map (width => pc_dbg_action_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_dbg_action_offset to pc_dbg_action_offset + pc_dbg_action_q'length-1),
            scout   => sov(pc_dbg_action_offset to pc_dbg_action_offset + pc_dbg_action_q'length-1),
            din     => pc_xu_dbg_action           ,
            dout    => pc_dbg_action_q);
pc_dbg_stop_latch : tri_rlmreg_p
  generic map (width => pc_dbg_stop_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_dbg_stop_offset to pc_dbg_stop_offset + pc_dbg_stop_q'length-1),
            scout   => sov(pc_dbg_stop_offset to pc_dbg_stop_offset + pc_dbg_stop_q'length-1),
            din     => pc_dbg_stop_d,
            dout    => pc_dbg_stop_q);
pc_dbg_stop_2_latch : tri_rlmreg_p
  generic map (width => pc_dbg_stop_2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_dbg_stop_2_offset to pc_dbg_stop_2_offset + pc_dbg_stop_2_q'length-1),
            scout   => sov(pc_dbg_stop_2_offset to pc_dbg_stop_2_offset + pc_dbg_stop_2_q'length-1),
            din     => pc_dbg_stop,
            dout    => pc_dbg_stop_2_q);
pc_err_mcsr_rpt_latch : tri_rlmreg_p
  generic map (width => pc_err_mcsr_rpt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_err_mcsr_rpt_offset to pc_err_mcsr_rpt_offset + pc_err_mcsr_rpt_q'length-1),
            scout   => sov(pc_err_mcsr_rpt_offset to pc_err_mcsr_rpt_offset + pc_err_mcsr_rpt_q'length-1),
            din     => pc_err_mcsr_rpt_d,
            dout    => pc_err_mcsr_rpt_q);
pc_err_mcsr_summary_latch : tri_rlmreg_p
  generic map (width => pc_err_mcsr_summary_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_err_mcsr_summary_offset to pc_err_mcsr_summary_offset + pc_err_mcsr_summary_q'length-1),
            scout   => sov(pc_err_mcsr_summary_offset to pc_err_mcsr_summary_offset + pc_err_mcsr_summary_q'length-1),
            din     => pc_err_mcsr_summary_d,
            dout    => pc_err_mcsr_summary_q);
pc_init_reset_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(pc_init_reset_offset),
            scout   => sov(pc_init_reset_offset),
            din     => pc_xu_init_reset           ,
            dout    => pc_init_reset_q);
quiesced_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(quiesced_offset),
            scout   => sov(quiesced_offset),
            din     => quiesced_d,
            dout    => quiesced_q);
ram_flush_latch : tri_rlmreg_p
  generic map (width => ram_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ram_flush_offset to ram_flush_offset + ram_flush_q'length-1),
            scout   => sov(ram_flush_offset to ram_flush_offset + ram_flush_q'length-1),
            din     => ram_flush_d,
            dout    => ram_flush_q);
ram_ip_latch : tri_rlmreg_p
  generic map (width => ram_ip_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ram_ip_offset to ram_ip_offset + ram_ip_q'length-1),
            scout   => sov(ram_ip_offset to ram_ip_offset + ram_ip_q'length-1),
            din     => ram_ip_d,
            dout    => ram_ip_q);
ram_mode_latch : tri_rlmreg_p
  generic map (width => ram_mode_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ram_mode_offset to ram_mode_offset + ram_mode_q'length-1),
            scout   => sov(ram_mode_offset to ram_mode_offset + ram_mode_q'length-1),
            din     => ram_mode_d,
            dout    => ram_mode_q);
slowspr_flush_latch : tri_rlmreg_p
  generic map (width => slowspr_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(slowspr_flush_offset to slowspr_flush_offset + slowspr_flush_q'length-1),
            scout   => sov(slowspr_flush_offset to slowspr_flush_offset + slowspr_flush_q'length-1),
            din     => mux_cpl_slowspr_flush      ,
            dout    => slowspr_flush_q);
spr_cpl_async_int_latch : tri_rlmreg_p
  generic map (width => spr_cpl_async_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(spr_cpl_async_int_offset to spr_cpl_async_int_offset + spr_cpl_async_int_q'length-1),
            scout   => sov(spr_cpl_async_int_offset to spr_cpl_async_int_offset + spr_cpl_async_int_q'length-1),
            din     => spr_cpl_async_int          ,
            dout    => spr_cpl_async_int_q);
ram_execute_latch : tri_rlmreg_p
  generic map (width => ram_execute_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ram_execute_offset to ram_execute_offset + ram_execute_q'length-1),
            scout   => sov(ram_execute_offset to ram_execute_offset + ram_execute_q'length-1),
            din     => ram_execute_d,
            dout    => ram_execute_q);
ssprwr_ip_latch : tri_rlmreg_p
  generic map (width => ssprwr_ip_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ssprwr_ip_offset to ssprwr_ip_offset + ssprwr_ip_q'length-1),
            scout   => sov(ssprwr_ip_offset to ssprwr_ip_offset + ssprwr_ip_q'length-1),
            din     => ssprwr_ip_d,
            dout    => ssprwr_ip_q);
exx_cm_hold_latch : tri_rlmreg_p
  generic map (width => exx_cm_hold_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_cm_hold_offset to exx_cm_hold_offset + exx_cm_hold_q'length-1),
            scout   => sov(exx_cm_hold_offset to exx_cm_hold_offset + exx_cm_hold_q'length-1),
            din     => exx_cm_hold                ,
            dout    => exx_cm_hold_q);
xu_ex1_n_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex1_n_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex1_n_flush_offset to xu_ex1_n_flush_offset + xu_ex1_n_flush_q'length-1),
            scout   => sov(xu_ex1_n_flush_offset to xu_ex1_n_flush_offset + xu_ex1_n_flush_q'length-1),
            din     => rf1_flush                  ,
            dout    => xu_ex1_n_flush_q);
xu_ex1_s_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex1_s_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex1_s_flush_offset to xu_ex1_s_flush_offset + xu_ex1_s_flush_q'length-1),
            scout   => sov(xu_ex1_s_flush_offset to xu_ex1_s_flush_offset + xu_ex1_s_flush_q'length-1),
            din     => rf1_flush                  ,
            dout    => xu_ex1_s_flush_q);
xu_ex1_w_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex1_w_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex1_w_flush_offset to xu_ex1_w_flush_offset + xu_ex1_w_flush_q'length-1),
            scout   => sov(xu_ex1_w_flush_offset to xu_ex1_w_flush_offset + xu_ex1_w_flush_q'length-1),
            din     => rf1_flush                  ,
            dout    => xu_ex1_w_flush_q);
xu_ex2_n_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex2_n_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex2_n_flush_offset to xu_ex2_n_flush_offset + xu_ex2_n_flush_q'length-1),
            scout   => sov(xu_ex2_n_flush_offset to xu_ex2_n_flush_offset + xu_ex2_n_flush_q'length-1),
            din     => ex1_flush                  ,
            dout    => xu_ex2_n_flush_q);
xu_ex2_s_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex2_s_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex2_s_flush_offset to xu_ex2_s_flush_offset + xu_ex2_s_flush_q'length-1),
            scout   => sov(xu_ex2_s_flush_offset to xu_ex2_s_flush_offset + xu_ex2_s_flush_q'length-1),
            din     => ex1_flush                  ,
            dout    => xu_ex2_s_flush_q);
xu_ex2_w_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex2_w_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex2_w_flush_offset to xu_ex2_w_flush_offset + xu_ex2_w_flush_q'length-1),
            scout   => sov(xu_ex2_w_flush_offset to xu_ex2_w_flush_offset + xu_ex2_w_flush_q'length-1),
            din     => ex1_flush                  ,
            dout    => xu_ex2_w_flush_q);
xu_ex3_n_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex3_n_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex3_n_flush_offset to xu_ex3_n_flush_offset + xu_ex3_n_flush_q'length-1),
            scout   => sov(xu_ex3_n_flush_offset to xu_ex3_n_flush_offset + xu_ex3_n_flush_q'length-1),
            din     => ex2_flush                  ,
            dout    => xu_ex3_n_flush_q);
xu_ex3_s_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex3_s_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex3_s_flush_offset to xu_ex3_s_flush_offset + xu_ex3_s_flush_q'length-1),
            scout   => sov(xu_ex3_s_flush_offset to xu_ex3_s_flush_offset + xu_ex3_s_flush_q'length-1),
            din     => ex2_flush                  ,
            dout    => xu_ex3_s_flush_q);
xu_ex3_w_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex3_w_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex3_w_flush_offset to xu_ex3_w_flush_offset + xu_ex3_w_flush_q'length-1),
            scout   => sov(xu_ex3_w_flush_offset to xu_ex3_w_flush_offset + xu_ex3_w_flush_q'length-1),
            din     => ex2_flush                  ,
            dout    => xu_ex3_w_flush_q);
xu_ex4_n_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex4_n_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex4_n_flush_offset to xu_ex4_n_flush_offset + xu_ex4_n_flush_q'length-1),
            scout   => sov(xu_ex4_n_flush_offset to xu_ex4_n_flush_offset + xu_ex4_n_flush_q'length-1),
            din     => ex3_flush                  ,
            dout    => xu_ex4_n_flush_q);
xu_ex4_s_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex4_s_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex4_s_flush_offset to xu_ex4_s_flush_offset + xu_ex4_s_flush_q'length-1),
            scout   => sov(xu_ex4_s_flush_offset to xu_ex4_s_flush_offset + xu_ex4_s_flush_q'length-1),
            din     => ex3_flush                  ,
            dout    => xu_ex4_s_flush_q);
xu_ex4_w_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex4_w_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex4_w_flush_offset to xu_ex4_w_flush_offset + xu_ex4_w_flush_q'length-1),
            scout   => sov(xu_ex4_w_flush_offset to xu_ex4_w_flush_offset + xu_ex4_w_flush_q'length-1),
            din     => ex3_flush                  ,
            dout    => xu_ex4_w_flush_q);
xu_ex5_n_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex5_n_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex5_n_flush_offset to xu_ex5_n_flush_offset + xu_ex5_n_flush_q'length-1),
            scout   => sov(xu_ex5_n_flush_offset to xu_ex5_n_flush_offset + xu_ex5_n_flush_q'length-1),
            din     => ex4_flush                  ,
            dout    => xu_ex5_n_flush_q);
xu_ex5_s_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex5_s_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex5_s_flush_offset to xu_ex5_s_flush_offset + xu_ex5_s_flush_q'length-1),
            scout   => sov(xu_ex5_s_flush_offset to xu_ex5_s_flush_offset + xu_ex5_s_flush_q'length-1),
            din     => ex4_flush                  ,
            dout    => xu_ex5_s_flush_q);
xu_ex5_w_flush_latch : tri_rlmreg_p
  generic map (width => xu_ex5_w_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_ex5_w_flush_offset to xu_ex5_w_flush_offset + xu_ex5_w_flush_q'length-1),
            scout   => sov(xu_ex5_w_flush_offset to xu_ex5_w_flush_offset + xu_ex5_w_flush_q'length-1),
            din     => ex4_flush                  ,
            dout    => xu_ex5_w_flush_q);
xu_is2_n_flush_latch : tri_rlmreg_p
  generic map (width => xu_is2_n_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_is2_n_flush_offset to xu_is2_n_flush_offset + xu_is2_n_flush_q'length-1),
            scout   => sov(xu_is2_n_flush_offset to xu_is2_n_flush_offset + xu_is2_n_flush_q'length-1),
            din     => any_flush                  ,
            dout    => xu_is2_n_flush_q);
xu_rf0_n_flush_latch : tri_rlmreg_p
  generic map (width => xu_rf0_n_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_rf0_n_flush_offset to xu_rf0_n_flush_offset + xu_rf0_n_flush_q'length-1),
            scout   => sov(xu_rf0_n_flush_offset to xu_rf0_n_flush_offset + xu_rf0_n_flush_q'length-1),
            din     => is2_flush                  ,
            dout    => xu_rf0_n_flush_q);
xu_rf1_n_flush_latch : tri_rlmreg_p
  generic map (width => xu_rf1_n_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_rf1_n_flush_offset to xu_rf1_n_flush_offset + xu_rf1_n_flush_q'length-1),
            scout   => sov(xu_rf1_n_flush_offset to xu_rf1_n_flush_offset + xu_rf1_n_flush_q'length-1),
            din     => rf0_flush                  ,
            dout    => xu_rf1_n_flush_q);
xu_rf1_s_flush_latch : tri_rlmreg_p
  generic map (width => xu_rf1_s_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_rf1_s_flush_offset to xu_rf1_s_flush_offset + xu_rf1_s_flush_q'length-1),
            scout   => sov(xu_rf1_s_flush_offset to xu_rf1_s_flush_offset + xu_rf1_s_flush_q'length-1),
            din     => rf0_flush                  ,
            dout    => xu_rf1_s_flush_q);
xu_rf1_w_flush_latch : tri_rlmreg_p
  generic map (width => xu_rf1_w_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_flush_inf_act                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_rf1_w_flush_offset to xu_rf1_w_flush_offset + xu_rf1_w_flush_q'length-1),
            scout   => sov(xu_rf1_w_flush_offset to xu_rf1_w_flush_offset + xu_rf1_w_flush_q'length-1),
            din     => rf0_flush                  ,
            dout    => xu_rf1_w_flush_q);
ex5_np1_irpt_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex5_np1_irpt_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_np1_irpt_dbg_cint_offset to ex5_np1_irpt_dbg_cint_offset + ex5_np1_irpt_dbg_cint_q'length-1),
            scout   => sov(ex5_np1_irpt_dbg_cint_offset to ex5_np1_irpt_dbg_cint_offset + ex5_np1_irpt_dbg_cint_q'length-1),
            din     => ex4_np1_irpt_dbg_cint,
            dout    => ex5_np1_irpt_dbg_cint_q);
ex6_np1_irpt_dbg_cint_latch : tri_rlmreg_p
  generic map (width => ex6_np1_irpt_dbg_cint_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_np1_irpt_dbg_cint_offset to ex6_np1_irpt_dbg_cint_offset + ex6_np1_irpt_dbg_cint_q'length-1),
            scout   => sov(ex6_np1_irpt_dbg_cint_offset to ex6_np1_irpt_dbg_cint_offset + ex6_np1_irpt_dbg_cint_q'length-1),
            din     => ex6_np1_irpt_dbg_cint_d,
            dout    => ex6_np1_irpt_dbg_cint_q);
ex5_np1_irpt_dbg_event_latch : tri_rlmreg_p
  generic map (width => ex5_np1_irpt_dbg_event_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_np1_irpt_dbg_event_offset to ex5_np1_irpt_dbg_event_offset + ex5_np1_irpt_dbg_event_q'length-1),
            scout   => sov(ex5_np1_irpt_dbg_event_offset to ex5_np1_irpt_dbg_event_offset + ex5_np1_irpt_dbg_event_q'length-1),
            din     => ex4_np1_irpt_dbg_event,
            dout    => ex5_np1_irpt_dbg_event_q);
ex6_np1_irpt_dbg_event_latch : tri_rlmreg_p
  generic map (width => ex6_np1_irpt_dbg_event_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_np1_irpt_dbg_event_offset to ex6_np1_irpt_dbg_event_offset + ex6_np1_irpt_dbg_event_q'length-1),
            scout   => sov(ex6_np1_irpt_dbg_event_offset to ex6_np1_irpt_dbg_event_offset + ex6_np1_irpt_dbg_event_q'length-1),
            din     => ex6_np1_irpt_dbg_event_d,
            dout    => ex6_np1_irpt_dbg_event_q);
clkg_ctl_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(clkg_ctl_offset),
            scout   => sov(clkg_ctl_offset),
            din     => spr_xucr0_clkg_ctl(2)       ,
            dout    => clkg_ctl_q);
xu_rf_seq_end_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_rf_seq_end_offset),
            scout   => sov(xu_rf_seq_end_offset),
            din     => gpr_cpl_regfile_seq_end    ,
            dout    => xu_rf_seq_end_q);
xu_rfpe_ack_latch : tri_rlmreg_p
  generic map (width => xu_rfpe_ack_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_rfpe_ack_offset to xu_rfpe_ack_offset + xu_rfpe_ack_q'length-1),
            scout   => sov(xu_rfpe_ack_offset to xu_rfpe_ack_offset + xu_rfpe_ack_q'length-1),
            din     => xu_rfpe_ack_d,
            dout    => xu_rfpe_ack_q);
xu_rfpe_hold_present_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xu_rfpe_hold_present_offset),
            scout   => sov(xu_rfpe_hold_present_offset),
            din     => xu_rfpe_hold_present_d,
            dout    => xu_rfpe_hold_present_q);
exx_act_latch : tri_rlmreg_p
  generic map (width => exx_act_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_act_offset to exx_act_offset + exx_act_q'length-1),
            scout   => sov(exx_act_offset to exx_act_offset + exx_act_q'length-1),
            din     => exx_act_d,
            dout    => exx_act_q);
ex4_mchk_int_en_latch : tri_rlmreg_p
  generic map (width => ex4_mchk_int_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_mchk_int_en_offset to ex4_mchk_int_en_offset + ex4_mchk_int_en_q'length-1),
            scout   => sov(ex4_mchk_int_en_offset to ex4_mchk_int_en_offset + ex4_mchk_int_en_q'length-1),
            din     => ex3_mchk_int_en,
            dout    => ex4_mchk_int_en_q);
ex5_mchk_int_en_latch : tri_rlmreg_p
  generic map (width => ex5_mchk_int_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_mchk_int_en_offset to ex5_mchk_int_en_offset + ex5_mchk_int_en_q'length-1),
            scout   => sov(ex5_mchk_int_en_offset to ex5_mchk_int_en_offset + ex5_mchk_int_en_q'length-1),
            din     => ex4_mchk_int_en_q,
            dout    => ex5_mchk_int_en_q);
trace_bus_enable_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => pc_xu_trace_bus_enable     ,
            dout    => trace_bus_enable_q);
ex1_instr_trace_type_latch : tri_rlmreg_p
  generic map (width => ex1_instr_trace_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_instr_trace_type_offset to ex1_instr_trace_type_offset + ex1_instr_trace_type_q'length-1),
            scout   => sov(ex1_instr_trace_type_offset to ex1_instr_trace_type_offset + ex1_instr_trace_type_q'length-1),
            din     => dec_cpl_rf1_instr_trace_type,
            dout    => ex1_instr_trace_type_q);
ex1_instr_trace_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_instr_trace_val_offset),
            scout   => sov(ex1_instr_trace_val_offset),
            din     => dec_cpl_rf1_instr_trace_val,
            dout    => ex1_instr_trace_val_q);
ex1_xu_issued_latch : tri_rlmreg_p
  generic map (width => ex1_xu_issued_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_xu_issued_offset to ex1_xu_issued_offset + ex1_xu_issued_q'length-1),
            scout   => sov(ex1_xu_issued_offset to ex1_xu_issued_offset + ex1_xu_issued_q'length-1),
            din     => dec_cpl_rf1_issued         ,
            dout    => ex1_xu_issued_q);
ex2_xu_issued_latch : tri_rlmreg_p
  generic map (width => ex2_xu_issued_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_xu_issued_offset to ex2_xu_issued_offset + ex2_xu_issued_q'length-1),
            scout   => sov(ex2_xu_issued_offset to ex2_xu_issued_offset + ex2_xu_issued_q'length-1),
            din     => ex1_xu_issued_q            ,
            dout    => ex2_xu_issued_q);
ex3_xu_issued_latch : tri_rlmreg_p
  generic map (width => ex3_xu_issued_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_xu_issued_offset to ex3_xu_issued_offset + ex3_xu_issued_q'length-1),
            scout   => sov(ex3_xu_issued_offset to ex3_xu_issued_offset + ex3_xu_issued_q'length-1),
            din     => ex2_xu_issued_q            ,
            dout    => ex3_xu_issued_q);
ex4_xu_issued_latch : tri_rlmreg_p
  generic map (width => ex4_xu_issued_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_xu_issued_offset to ex4_xu_issued_offset + ex4_xu_issued_q'length-1),
            scout   => sov(ex4_xu_issued_offset to ex4_xu_issued_offset + ex4_xu_issued_q'length-1),
            din     => ex3_xu_issued ,
            dout    => ex4_xu_issued_q);
ex3_axu_issued_latch : tri_rlmreg_p
  generic map (width => ex3_axu_issued_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_axu_issued_offset to ex3_axu_issued_offset + ex3_axu_issued_q'length-1),
            scout   => sov(ex3_axu_issued_offset to ex3_axu_issued_offset + ex3_axu_issued_q'length-1),
            din     => fu_xu_ex2_ifar_issued      ,
            dout    => ex3_axu_issued_q);
ex4_axu_issued_latch : tri_rlmreg_p
  generic map (width => ex4_axu_issued_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_axu_issued_offset to ex4_axu_issued_offset + ex4_axu_issued_q'length-1),
            scout   => sov(ex4_axu_issued_offset to ex4_axu_issued_offset + ex4_axu_issued_q'length-1),
            din     => ex3_axu_issued_q           ,
            dout    => ex4_axu_issued_q);
ex2_instr_dbg_latch : tri_rlmreg_p
  generic map (width => ex2_instr_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_instr_dbg_offset to ex2_instr_dbg_offset + ex2_instr_dbg_q'length-1),
            scout   => sov(ex2_instr_dbg_offset to ex2_instr_dbg_offset + ex2_instr_dbg_q'length-1),
            din     => ex1_instr                  ,
            dout    => ex2_instr_dbg_q);
ex2_instr_trace_type_latch : tri_rlmreg_p
  generic map (width => ex2_instr_trace_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_instr_trace_type_offset to ex2_instr_trace_type_offset + ex2_instr_trace_type_q'length-1),
            scout   => sov(ex2_instr_trace_type_offset to ex2_instr_trace_type_offset + ex2_instr_trace_type_q'length-1),
            din     => ex1_instr_trace_type_q     ,
            dout    => ex2_instr_trace_type_q);
ex4_instr_trace_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_instr_trace_val_offset),
            scout   => sov(ex4_instr_trace_val_offset),
            din     => dec_cpl_ex3_instr_trace_val,
            dout    => ex4_instr_trace_val_q);
ex5_axu_val_dbg_latch : tri_regk
  generic map (width => ex5_axu_val_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_nsl_thold_0_b,
            din     => ex4_axu_val                ,
            dout    => ex5_axu_val_dbg_q);
ex5_instr_cpl_dbg_latch : tri_regk
  generic map (width => ex5_instr_cpl_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_nsl_thold_0_b,
            din     => ex4_instr_cpl              ,
            dout    => ex5_instr_cpl_dbg_q);
ex5_instr_trace_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_instr_trace_val_offset),
            scout   => sov(ex5_instr_trace_val_offset),
            din     => ex4_instr_trace_val_q      ,
            dout    => ex5_instr_trace_val_q);
ex5_siar_latch : tri_rlmreg_p
  generic map (width => ex5_siar_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_siar_offset to ex5_siar_offset + ex5_siar_q'length-1),
            scout   => sov(ex5_siar_offset to ex5_siar_offset + ex5_siar_q'length-1),
            din     => ex5_siar_d,
            dout    => ex5_siar_q);
ex5_siar_cpl_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_siar_cpl_offset),
            scout   => sov(ex5_siar_cpl_offset),
            din     => ex5_siar_cpl_d,
            dout    => ex5_siar_cpl_q);
ex5_siar_gs_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_siar_gs_offset),
            scout   => sov(ex5_siar_gs_offset),
            din     => ex5_siar_gs_d,
            dout    => ex5_siar_gs_q);
ex5_siar_issued_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_siar_issued_offset),
            scout   => sov(ex5_siar_issued_offset),
            din     => ex5_siar_issued_d,
            dout    => ex5_siar_issued_q);
ex5_siar_pr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_siar_pr_offset),
            scout   => sov(ex5_siar_pr_offset),
            din     => ex5_siar_pr_d,
            dout    => ex5_siar_pr_q);
ex5_siar_tid_latch : tri_rlmreg_p
  generic map (width => ex5_siar_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_siar_tid_offset to ex5_siar_tid_offset + ex5_siar_tid_q'length-1),
            scout   => sov(ex5_siar_tid_offset to ex5_siar_tid_offset + ex5_siar_tid_q'length-1),
            din     => ex5_siar_tid_d,
            dout    => ex5_siar_tid_q);
ex5_ucode_end_dbg_latch : tri_rlmreg_p
  generic map (width => ex5_ucode_end_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_ucode_end_dbg_offset to ex5_ucode_end_dbg_offset + ex5_ucode_end_dbg_q'length-1),
            scout   => sov(ex5_ucode_end_dbg_offset to ex5_ucode_end_dbg_offset + ex5_ucode_end_dbg_q'length-1),
            din     => ex4_ucode_end              ,
            dout    => ex5_ucode_end_dbg_q);
ex5_ucode_val_dbg_latch : tri_rlmreg_p
  generic map (width => ex5_ucode_val_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_ucode_val_dbg_offset to ex5_ucode_val_dbg_offset + ex5_ucode_val_dbg_q'length-1),
            scout   => sov(ex5_ucode_val_dbg_offset to ex5_ucode_val_dbg_offset + ex5_ucode_val_dbg_q'length-1),
            din     => ex4_ucode_val              ,
            dout    => ex5_ucode_val_dbg_q);
instr_trace_mode_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(instr_trace_mode_offset),
            scout   => sov(instr_trace_mode_offset),
            din     => pc_xu_instr_trace_mode     ,
            dout    => instr_trace_mode_q);
debug_data_out_latch : tri_rlmreg_p
  generic map (width => debug_data_out_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(debug_data_out_offset to debug_data_out_offset + debug_data_out_q'length-1),
            scout   => sov(debug_data_out_offset to debug_data_out_offset + debug_data_out_q'length-1),
            din     => debug_data_out_d,
            dout    => debug_data_out_q);
debug_mux_ctrls_latch : tri_rlmreg_p
  generic map (width => debug_mux_ctrls_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux_ctrls_q'length-1),
            scout   => sov(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux_ctrls_q'length-1),
            din     => cpl_debug_mux_ctrls        ,
            dout    => debug_mux_ctrls_q);
debug_mux_ctrls_int_latch : tri_rlmreg_p
  generic map (width => debug_mux_ctrls_int_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(debug_mux_ctrls_int_offset to debug_mux_ctrls_int_offset + debug_mux_ctrls_int_q'length-1),
            scout   => sov(debug_mux_ctrls_int_offset to debug_mux_ctrls_int_offset + debug_mux_ctrls_int_q'length-1),
            din     => debug_mux_ctrls_int,
            dout    => debug_mux_ctrls_int_q);
trigger_data_out_latch : tri_rlmreg_p
  generic map (width => trigger_data_out_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            scout   => sov(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            din     => trigger_data_out_d,
            dout    => trigger_data_out_q);
event_bus_enable_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(event_bus_enable_offset),
            scout   => sov(event_bus_enable_offset),
            din     => pc_xu_event_bus_enable     ,
            dout    => event_bus_enable_q);
ex2_perf_event_latch : tri_regk
  generic map (width => ex2_perf_event_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => event_bus_enable_q   ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_perf_event_d,
            dout    => ex2_perf_event_q);
ex3_perf_event_latch : tri_rlmreg_p
  generic map (width => ex3_perf_event_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => event_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_perf_event_offset to ex3_perf_event_offset + ex3_perf_event_q'length-1),
            scout   => sov(ex3_perf_event_offset to ex3_perf_event_offset + ex3_perf_event_q'length-1),
            din     => ex2_perf_event_q           ,
            dout    => ex3_perf_event_q);
ex4_perf_event_latch : tri_regk
  generic map (width => ex4_perf_event_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => event_bus_enable_q   ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_perf_event_d,
            dout    => ex4_perf_event_q);
ex5_perf_event_latch : tri_rlmreg_p
  generic map (width => ex5_perf_event_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => event_bus_enable_q   ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_perf_event_offset to ex5_perf_event_offset + ex5_perf_event_q'length-1),
            scout   => sov(ex5_perf_event_offset to ex5_perf_event_offset + ex5_perf_event_q'length-1),
            din     => ex5_perf_event_d,
            dout    => ex5_perf_event_q);
spr_bit_act_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(spr_bit_act_offset),
            scout   => sov(spr_bit_act_offset),
            din     => spr_bit_act,
            dout    => spr_bit_act_q);


dd1_clk_override_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => ccfg_so_thold_0_b,
            scin    => siv_ccfg(dd1_clk_override_offset_ccfg to dd1_clk_override_offset_ccfg),
            scout   => sov_ccfg(dd1_clk_override_offset_ccfg to dd1_clk_override_offset_ccfg),
            dout(0) => clk_override_q);


spare_0_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tidn,
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_0_lclk,
            d1clk       => spare_0_d1clk,
            d2clk       => spare_0_d2clk);
spare_0_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_0_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_0_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_0_lclk,
            D1CLK   => spare_0_d1clk,
            D2CLK   => spare_0_d2clk,
            SCANIN  => siv(spare_0_offset to spare_0_offset + spare_0_q'length-1),
            SCANOUT => sov(spare_0_offset to spare_0_offset + spare_0_q'length-1),
            D       => spare_0_d,
            QB      => spare_0_q);
spare_0_d   <= not spare_0_q;

spare_1_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tiup,
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_1_lclk,
            d1clk       => spare_1_d1clk,
            d2clk       => spare_1_d2clk);
spare_1_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_1_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_1_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_1_lclk,
            D1CLK   => spare_1_d1clk,
            D2CLK   => spare_1_d2clk,
            SCANIN  => siv(spare_1_offset to spare_1_offset + spare_1_q'length-1),
            SCANOUT => sov(spare_1_offset to spare_1_offset + spare_1_q'length-1),
            D       => spare_1_d,
            QB      => spare_1_q);
-- Need to account for cycles between ex4 & ex7...
spare_1_d(0 to 3)             <= not (ex4_instr_cpl and not ex5_in_ucode_q);        -- EX5
spare_1_d(4 to 7)             <= not spare_1_q(0 to 3);                             -- EX6
spare_1_d(8 to 11)            <= not spare_1_q(4 to 7);                             -- EX7
spare_1_d(12 to 15)           <= not spare_1_q(12 to 15);


spare_2_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tidn,
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_2_lclk,
            d1clk       => spare_2_d1clk,
            d2clk       => spare_2_d2clk);
spare_2_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_2_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_2_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_2_lclk,
            D1CLK   => spare_2_d1clk,
            D2CLK   => spare_2_d2clk,
            SCANIN  => siv(spare_2_offset to spare_2_offset + spare_2_q'length-1),
            SCANOUT => sov(spare_2_offset to spare_2_offset + spare_2_q'length-1),
            D       => spare_2_d,
            QB      => spare_2_q);
spare_2_d   <= not spare_2_q;

spare_3_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tidn,
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_3_lclk,
            d1clk       => spare_3_d1clk,
            d2clk       => spare_3_d2clk);
spare_3_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_3_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_3_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_3_lclk,
            D1CLK   => spare_3_d1clk,
            D2CLK   => spare_3_d2clk,
            SCANIN  => siv(spare_3_offset to spare_3_offset + spare_3_q'length-1),
            SCANOUT => sov(spare_3_offset to spare_3_offset + spare_3_q'length-1),
            D       => spare_3_d,
            QB      => spare_3_q);
spare_3_d   <= not spare_3_q;

spare_4_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tiup,
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_4_lclk,
            d1clk       => spare_4_d1clk,
            d2clk       => spare_4_d2clk);
spare_4_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_4_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_4_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_4_lclk,
            D1CLK   => spare_4_d1clk,
            D2CLK   => spare_4_d2clk,
            SCANIN  => siv(spare_4_offset to spare_4_offset + spare_4_q'length-1),
            SCANOUT => sov(spare_4_offset to spare_4_offset + spare_4_q'length-1),
            D       => spare_4_d,
            QB      => spare_4_q);

spare_5_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tiup,
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_5_lclk,
            d1clk       => spare_5_d1clk,
            d2clk       => spare_5_d2clk);
spare_5_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_5_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_5_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_5_lclk,
            D1CLK   => spare_5_d1clk,
            D2CLK   => spare_5_d2clk,
            SCANIN  => siv(spare_5_offset to spare_5_offset + spare_5_q'length-1),
            SCANOUT => sov(spare_5_offset to spare_5_offset + spare_5_q'length-1),
            D       => spare_5_d,
            QB      => spare_5_q);








ex4_dac_cmpr_gem : for t in 1 to 4 generate
   ex4_dacr_cmpr_latch : tri_regk
     generic map (width => ex4_dacr_cmpr_q(t)'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => exx_act(3)           ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex4_dacr_cmpr_d(t),
               dout    => ex4_dacr_cmpr_q(t));
   ex4_dacw_cmpr_latch : tri_regk
     generic map (width => ex4_dacw_cmpr_q(t)'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => exx_act(3)           ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex4_dacw_cmpr_d(t),
               dout    => ex4_dacw_cmpr_q(t));
end generate;

ex5_late_flush_gen : for t in 0 to ifar_repwr-1 generate
   ex5_late_flush_latch : tri_rlmreg_p
     generic map (width => ex5_late_flush_q(t)'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => exx_flush_inf_act,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_late_flush_offset+ex5_late_flush_q(t)'length*t to ex5_late_flush_offset + ex5_late_flush_q(t)'length*(t+1)-1),
               scout   => sov(ex5_late_flush_offset+ex5_late_flush_q(t)'length*t to ex5_late_flush_offset + ex5_late_flush_q(t)'length*(t+1)-1),
               din     => ex5_late_flush_d(t),
               dout    => ex5_late_flush_q(t));
end generate;
ex2_ifar_b_latch_gen : for t in 0 to threads-1 generate
   ex2_ifar_b_latch : entity tri.tri_aoi22_nlats_wlcb(tri_aoi22_nlats_wlcb)
   generic map (width => eff_ifar, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_ifar_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_ifar_b_offset+eff_ifar*t to ex2_ifar_b_offset+eff_ifar*(t+1)-1),
               scout   => sov(ex2_ifar_b_offset+eff_ifar*t to ex2_ifar_b_offset+eff_ifar*(t+1)-1),
               A1      => fu_xu_ex1_ifar(eff_ifar*t to eff_ifar*(t+1)-1),
               A2      => ex1_ifar_sel_b(eff_ifar*t to eff_ifar*(t+1)-1),
               B1      => ex1_xu_ifar,
               B2      => ex1_ifar_sel(eff_ifar*t to eff_ifar*(t+1)-1),
               QB      => ex2_ifar_b_q(eff_ifar*t to eff_ifar*(t+1)-1));               
   ex1_ifar_sel(eff_ifar*t to eff_ifar*(t+1)-1)      <= (others=>   (ex1_xu_val_q(t) or ex1_ucode_val_q(t)));
   ex1_ifar_sel_b(eff_ifar*t to eff_ifar*(t+1)-1)    <= (others=>not(ex1_xu_val_q(t) or ex1_ucode_val_q(t)));

   ex3_ifar_latch : tri_rlmreg_p
   generic map (width => eff_ifar, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_ifar_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_ifar_offset+eff_ifar*t to ex3_ifar_offset+eff_ifar*(t+1)-1),
               scout   => sov(ex3_ifar_offset+eff_ifar*t to ex3_ifar_offset+eff_ifar*(t+1)-1),
               din     => ex2_ifar(eff_ifar*t to eff_ifar*(t+1)-1),
               dout    => ex3_ifar_q(eff_ifar*t to eff_ifar*(t+1)-1));
   ex4_ifar_latch : tri_rlmreg_p
   generic map (width => eff_ifar, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_ifar_act(t),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex4_ifar_offset+eff_ifar*t to ex4_ifar_offset+eff_ifar*(t+1)-1),
               scout   => sov(ex4_ifar_offset+eff_ifar*t to ex4_ifar_offset+eff_ifar*(t+1)-1),
               din     => ex3_ifar_q(eff_ifar*t to eff_ifar*(t+1)-1),
               dout    => ex4_ifar_q(eff_ifar*t to eff_ifar*(t+1)-1));
end generate;

-------------------------------------------------
-- Pervasive
-------------------------------------------------
perv_2to1_reg: tri_plat
  generic map (width => 8, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => func_slp_sl_thold_2,
            din(1)      => func_slp_nsl_thold_2,
            din(2)      => func_sl_thold_2,
            din(3)      => func_nsl_thold_2,
            din(4)      => cfg_sl_thold_2,
            din(5)      => cfg_slp_sl_thold_2,
            din(6)      => sg_2,
            din(7)      => fce_2,
            q(0)        => func_slp_sl_thold_1,
            q(1)        => func_slp_nsl_thold_1,
            q(2)        => func_sl_thold_1,
            q(3)        => func_nsl_thold_1,
            q(4)        => cfg_sl_thold_1,
            q(5)        => cfg_slp_sl_thold_1,
            q(6)        => sg_1,
            q(7)        => fce_1);

perv_1to0_reg: tri_plat
  generic map (width => 8, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => func_slp_sl_thold_1,
            din(1)      => func_slp_nsl_thold_1,
            din(2)      => func_sl_thold_1,
            din(3)      => func_nsl_thold_1,
            din(4)      => cfg_sl_thold_1,
            din(5)      => cfg_slp_sl_thold_1,
            din(6)      => sg_1,
            din(7)      => fce_1,
            q(0)        => func_slp_sl_thold_0,
            q(1)        => func_slp_nsl_thold_0,
            q(2)        => func_sl_thold_0,
            q(3)        => func_nsl_thold_0,
            q(4)        => cfg_sl_thold_0,
            q(5)        => cfg_slp_sl_thold_0,
            q(6)        => sg_0,
            q(7)        => fce_0);

perv_lcbor_cfg_sl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => cfg_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee => cfg_sl_force,
            thold_b     => cfg_sl_thold_0_b);
            
bcfg_sl_force           <= cfg_sl_force;
bcfg_sl_thold_0_b       <= cfg_sl_thold_0_b;
dcfg_sl_force           <= cfg_sl_force;
dcfg_sl_thold_0_b       <= cfg_sl_thold_0_b;

perv_lcbor_cfg_slp: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => cfg_slp_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee => cfg_slp_sl_force,
            thold_b     => cfg_slp_sl_thold_0_b);
            
bcfg_slp_sl_force       <= cfg_slp_sl_force;
bcfg_slp_sl_thold_0_b   <= cfg_slp_sl_thold_0_b;

so_force                <= sg_0;
ccfg_so_thold_0_b       <= not cfg_sl_thold_0;
bcfg_so_thold_0_b       <= not cfg_sl_thold_0;
dcfg_so_thold_0_b       <= not cfg_sl_thold_0;
func_so_thold_0_b       <= not func_sl_thold_0;

perv_lcbor_func_sl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b);

perv_lcbor_func_slp_sl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_slp_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee => func_slp_sl_force,
            thold_b     => func_slp_sl_thold_0_b);

perv_lcbor_func_slp_nsl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_slp_nsl_thold_0,
            sg          => fce_0,
            act_dis     => tidn,
            forcee => func_slp_nsl_force,
            thold_b     => func_slp_nsl_thold_0_b);

perv_lcbor_func_nsl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_nsl_thold_0,
            sg          => fce_0,
            act_dis     => tidn,
            forcee => func_nsl_force,
            thold_b     => func_nsl_thold_0_b);

siv(   0 to MSL-1)               <= sov(   1 to MSL-1)      & func_scan_rpwr_in(0);
func_scan_rpwr_out(0)            <= sov(   0);

siv(MSL to 2*MSL-1)              <= sov(MSL+1 to 2*MSL-1)   & func_scan_rpwr_in(1);
func_scan_rpwr_out(1)            <= sov(MSL);

siv(2*MSL to siv'right)          <= sov(2*MSL+1 to siv'right) & func_scan_rpwr_in(2);
func_scan_rpwr_out(2)            <= sov(2*MSL);

siv_3(0 to siv_3'right)          <= sov_3(1 to siv_3'right) & func_scan_rpwr_in(3);
func_scan_rpwr_out(3)            <= sov_3(0);

siv_ccfg(0 to scan_right_ccfg-1) <= sov_ccfg(1 to scan_right_ccfg-1) & ccfg_scan_rpwr_in(0);
ccfg_scan_rpwr_out               <= sov_ccfg(0 to 0);

siv_bcfg(0 to scan_right_bcfg-1) <= sov_bcfg(1 to scan_right_bcfg-1) & bcfg_scan_rpwr_in(0);
bcfg_scan_rpwr_out               <= sov_bcfg(0 to 0);

siv_dcfg(0 to scan_right_dcfg-1) <= sov_dcfg(1 to scan_right_dcfg-1) & dcfg_scan_rpwr_in(0);
dcfg_scan_rpwr_out               <= sov_dcfg(0 to 0);

ccfg_scan_rpwr_0i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => ccfg_so_thold_0_b,
            scin(0) => ccfg_scan_in,
            scout   => ccfg_scan_rpwr_in(0 to 0),
            dout    => open);
ccfg_scan_rpwr_0o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => ccfg_so_thold_0_b,
            scin    => ccfg_scan_rpwr_out(0 to 0),
            scout   => ccfg_scan_out_gate(0 to 0),
            dout    => open);
bcfg_scan_rpwr_0i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => bcfg_so_thold_0_b,
            scin(0) => bcfg_scan_in,
            scout   => bcfg_scan_rpwr_in(0 to 0),
            dout    => open);
bcfg_scan_rpwr_0o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => bcfg_so_thold_0_b,
            scin    => bcfg_scan_rpwr_out(0 to 0),
            scout   => bcfg_scan_out_gate(0 to 0),
            dout    => open);
dcfg_scan_rpwr_0i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => dcfg_so_thold_0_b,
            scin(0) => dcfg_scan_in,
            scout   => dcfg_scan_rpwr_in(0 to 0),
            dout    => open);
dcfg_scan_rpwr_0o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => dcfg_so_thold_0_b,
            scin    => dcfg_scan_rpwr_out(0 to 0),
            scout   => dcfg_scan_out_gate(0 to 0),
            dout    => open);
func_scan_rpwr_50i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_in(50 to 50),
            scout   => func_scan_rpwr_in(0 to 0),
            dout    => open);
func_scan_rpwr_50o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_rpwr_out(0 to 0),
            scout   => func_scan_out_gate(50 to 50),
            dout    => open);
func_scan_rpwr_51i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_in(51 to 51),
            scout   => func_scan_rpwr_in(1 to 1),
            dout    => open);
func_scan_rpwr_51o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_rpwr_out(1 to 1),
            scout   => func_scan_out_gate(51 to 51),
            dout    => open);
func_scan_rpwr_52i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_in(52 to 52),
            scout   => func_scan_rpwr_in(2 to 2),
            dout    => open);
func_scan_rpwr_52o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_rpwr_out(2 to 2),
            scout   => func_scan_out_gate(52 to 52),
            dout    => open);
func_scan_rpwr_53i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_in(53 to 53),
            scout   => func_scan_rpwr2_in(3 to 3),
            dout    => open);
func_scan_rpwr_53i_2_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_rpwr2_in(3 to 3),
            scout   => func_scan_rpwr_in(3 to 3),
            dout    => open);
func_scan_rpwr_53o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_rpwr_out(3 to 3),
            scout   => func_scan_out_gate(53 to 53),
            dout    => open);

func_scan_out     <= gate(func_scan_out_gate,an_ac_scan_dis_dc_b);
ccfg_scan_out     <=      ccfg_scan_out_gate(0) and an_ac_scan_dis_dc_b;
bcfg_scan_out     <=      bcfg_scan_out_gate(0) and an_ac_scan_dis_dc_b;
dcfg_scan_out     <=      dcfg_scan_out_gate(0) and an_ac_scan_dis_dc_b;


end architecture xuq_cpl;
