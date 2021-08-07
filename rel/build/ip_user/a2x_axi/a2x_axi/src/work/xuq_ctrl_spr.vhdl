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

library ieee,ibm,support,work,tri,clib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_ctrl_spr is
generic(
        expand_type             : integer :=  2;
        threads                 : integer :=  4;
        eff_ifar                : integer := 62;
        spr_xucr0_init_mod      : integer := 0;
        uc_ifar                 : integer := 21;
        regsize                 : integer := 64;
        hvmode                  : integer := 1;
        regmode                 : integer := 6;
        dc_size                 : natural := 14;
        cl_size                 : natural := 6;             
        real_data_add           : integer := 42;
        fxu_synth               : integer := 0;
        a2mode                  : integer := 1;
        lmq_entries             : integer := 8;
        l_endian_m              : integer := 1;         
        load_credits            : integer := 4;
        store_credits           : integer := 20;
        st_data_32B_mode        : integer := 1;       
        bcfg_epn_0to15          : integer := 0;
        bcfg_epn_16to31         : integer := 0;
        bcfg_epn_32to47         : integer := (2**16)-1;  
        bcfg_epn_48to51         : integer := (2**4)-1; 
        bcfg_rpn_22to31         : integer := (2**10)-1;
        bcfg_rpn_32to47         : integer := (2**16)-1;  
        bcfg_rpn_48to51         : integer := (2**4)-1); 
port(

        fxa_fxb_rf0_val                         :in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_issued                      :in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_ucode_val                   :in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_act                         :in  std_ulogic;
        fxa_fxb_ex1_hold_ctr_flush              :in  std_ulogic;
        fxa_fxb_rf0_instr                       :in  std_ulogic_vector(0 to 31);
        fxa_fxb_rf0_tid                         :in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_ta_vld                      :in  std_ulogic;
        fxa_fxb_rf0_ta                          :in  std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_error                       :in  std_ulogic_vector(0 to 2);
        fxa_fxb_rf0_match                       :in  std_ulogic;
        fxa_fxb_rf0_is_ucode                    :in  std_ulogic;
        fxa_fxb_rf0_gshare                      :in  std_ulogic_vector(0 to 3);
        fxa_fxb_rf0_ifar                        :in  std_ulogic_vector(62-eff_ifar to 61);
        fxa_fxb_rf0_s1_vld                      :in  std_ulogic;
        fxa_fxb_rf0_s1                          :in  std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_s2_vld                      :in  std_ulogic;
        fxa_fxb_rf0_s2                          :in  std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_s3_vld                      :in  std_ulogic;
        fxa_fxb_rf0_s3                          :in  std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_axu_instr_type              :in  std_ulogic_vector(0 to 2);
        fxa_fxb_rf0_axu_ld_or_st                :in  std_ulogic;
        fxa_fxb_rf0_axu_store                   :in  std_ulogic;
        fxa_fxb_rf0_axu_ldst_forcealign         :in  std_ulogic;
        fxa_fxb_rf0_axu_ldst_forceexcept        :in  std_ulogic;
        fxa_fxb_rf0_axu_ldst_indexed            :in  std_ulogic;
        fxa_fxb_rf0_axu_ldst_tag                :in  std_ulogic_vector(0 to 8);
        fxa_fxb_rf0_axu_mftgpr                  :in  std_ulogic;
        fxa_fxb_rf0_axu_mffgpr                  :in  std_ulogic;
        fxa_fxb_rf0_axu_movedp                  :in  std_ulogic;
        fxa_fxb_rf0_axu_ldst_size               :in  std_ulogic_vector(0 to 5);
        fxa_fxb_rf0_axu_ldst_update             :in  std_ulogic;
        fxa_fxb_rf0_pred_update                 :in  std_ulogic;
        fxa_fxb_rf0_pred_taken_cnt              :in  std_ulogic_vector(0 to 1);
        fxa_fxb_rf0_mc_dep_chk_val              :in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf1_mul_val                     :in  std_ulogic;
        fxa_fxb_rf1_div_val                     :in  std_ulogic;
        fxa_fxb_rf1_div_ctr                     :in  std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_xu_epid_instr               :in  std_ulogic;
        fxa_fxb_rf0_axu_is_extload              :in  std_ulogic;
        fxa_fxb_rf0_axu_is_extstore             :in  std_ulogic;
        fxa_fxb_rf0_is_mfocrf                   :in  std_ulogic;
        fxa_fxb_rf0_3src_instr                  :in  std_ulogic;
        fxa_fxb_rf0_gpr0_zero                   :in  std_ulogic;
        fxa_fxb_rf0_use_imm                     :in  std_ulogic;
        fxa_fxb_rf1_muldiv_coll                 :in  std_ulogic;
        fxa_cpl_ex2_div_coll                    :in  std_ulogic_vector(0 to threads-1);
        fxb_fxa_ex7_we0                         :out std_ulogic;
        fxb_fxa_ex7_wa0                         :out std_ulogic_vector(0 to 7);
        fxb_fxa_ex7_wd0                         :out std_ulogic_vector(64-regsize to 63);
        fxb_fxa_ex6_clear_barrier               :out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf1_do0                         :in  std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do1                         :in  std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do2                         :in  std_ulogic_vector(64-regsize to 63);

        xu_bx_ex1_mtdp_val                      :out std_ulogic;
        xu_bx_ex1_mfdp_val                      :out std_ulogic;
        xu_bx_ex1_ipc_thrd                      :out std_ulogic_vector(0 to 1);
        xu_bx_ex2_ipc_ba                        :out std_ulogic_vector(0 to 4);
        xu_bx_ex2_ipc_sz                        :out std_ulogic_vector(0 to 1);

        xu_mm_derat_epn                         :out std_ulogic_vector(62-eff_ifar to 51);

        xu_mm_rf1_is_tlbsxr                     :out std_ulogic;
        mm_xu_cr0_eq_valid                      :in  std_ulogic_vector(0 to threads-1);
        mm_xu_cr0_eq                            :in  std_ulogic_vector(0 to threads-1);

        fu_xu_ex4_cr_val                        :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex4_cr_noflush                    :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex4_cr0                           :in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr0_bf                        :in  std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr1                           :in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr1_bf                        :in  std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr2                           :in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr2_bf                        :in  std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr3                           :in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr3_bf                        :in  std_ulogic_vector(0 to 2);

        pc_xu_ram_mode                          :in  std_ulogic;
        pc_xu_ram_thread                        :in  std_ulogic_vector(0 to 1);
        pc_xu_ram_execute                       :in  std_ulogic;
        pc_xu_ram_flush_thread                  :in  std_ulogic;
        xu_iu_ram_issue                         :out std_ulogic_vector(0 to threads-1);
        xu_pc_ram_interrupt                     :out std_ulogic;
        xu_pc_ram_done                          :out std_ulogic;
        xu_pc_ram_data                          :out std_ulogic_vector(64-(2**regmode) to 63);
        pc_xu_msrovride_enab                    :in  std_ulogic;
        pc_xu_msrovride_gs                      :in  std_ulogic;  
        pc_xu_msrovride_de                      :in  std_ulogic;  


        xu_iu_ex5_val                           :out std_ulogic;
        xu_iu_ex5_tid                           :out std_ulogic_vector(0 to threads-1);
        xu_iu_ex5_br_update                     :out std_ulogic;
        xu_iu_ex5_br_hist                       :out std_ulogic_vector(0 to 1);
        xu_iu_ex5_bclr                          :out std_ulogic;
        xu_iu_ex5_lk                            :out std_ulogic;
        xu_iu_ex5_bh                            :out std_ulogic_vector(0 to 1);
        xu_iu_ex6_pri                           :out std_ulogic_vector(0 to 2);
        xu_iu_ex6_pri_val                       :out std_ulogic_vector(0 to 3);
        xu_iu_spr_xer                           :out std_ulogic_vector(0 to 7*threads-1);
        xu_iu_slowspr_done                      :out std_ulogic_vector(0 to threads-1);
        xu_iu_need_hole                         :out std_ulogic;
        xu_iu_ex5_gshare                        :out std_ulogic_vector(0 to 3);
        xu_iu_ex5_getNIA                        :out std_ulogic;

        an_ac_stcx_complete                     :in  std_ulogic_vector(0 to threads-1);
        an_ac_stcx_pass                         :in  std_ulogic_vector(0 to threads-1);
        xu_iu_stcx_complete                     : out   std_ulogic_vector(0 to 3);
        xu_iu_reld_core_tag_clone     :out     std_ulogic_vector(1 to 4);
        xu_iu_reld_data_coming_clone  :out     std_ulogic;
        xu_iu_reld_data_vld_clone     :out     std_ulogic;
        xu_iu_reld_ditc_clone         :out     std_ulogic;

        slowspr_val_in                          :in  std_ulogic;
        slowspr_rw_in                           :in  std_ulogic;
        slowspr_etid_in                         :in  std_ulogic_vector(0 to 1);
        slowspr_addr_in                         :in  std_ulogic_vector(0 to 9);
        slowspr_data_in                         :in  std_ulogic_vector(64-(2**regmode) to 63);
        slowspr_done_in                         :in  std_ulogic;
        slowspr_val_out                         :out std_ulogic;
        slowspr_rw_out                          :out std_ulogic;
        slowspr_etid_out                        :out std_ulogic_vector(0 to 1);
        slowspr_addr_out                        :out std_ulogic_vector(0 to 9);
        slowspr_data_out                        :out std_ulogic_vector(64-(2**REGMODE) to 63);
        slowspr_done_out                        :out std_ulogic;

        an_ac_dcr_act                           :in  std_ulogic;
        an_ac_dcr_val                           :in  std_ulogic;
        an_ac_dcr_read                          :in  std_ulogic;
        an_ac_dcr_etid                          :in  std_ulogic_vector(0 to 1);
        an_ac_dcr_data                          :in  std_ulogic_vector(64-(2**regmode) to 63);
        an_ac_dcr_done                          :in  std_ulogic;

        lsu_xu_ex4_mtdp_cr_status               :in  std_ulogic;
        lsu_xu_ex4_mfdp_cr_status               :in  std_ulogic;
        dec_cpl_ex3_mc_dep_chk_val              :in  std_ulogic_vector(0 to threads-1);

        xu_pc_event_data                        :out std_ulogic_vector(0 to 7);

        pc_xu_event_count_mode                  :in  std_ulogic_vector(0 to 2);
        pc_xu_event_mux_ctrls                   :in  std_ulogic_vector(0 to 47);

        fxu_debug_mux_ctrls                     :in  std_ulogic_vector(0 to 15);
        cpl_debug_mux_ctrls                     :in  std_ulogic_vector(0 to 15);
        lsu_debug_mux_ctrls                     :in  std_ulogic_vector(0 to 15);
        spr_debug_mux_ctrls                     :in  std_ulogic_vector(0 to 15);
        trigger_data_in                         :in  std_ulogic_vector(0 to 11);
        trigger_data_out                        :out std_ulogic_vector(0 to 11);
        debug_data_in                           :in  std_ulogic_vector(0 to 87);
        debug_data_out                          :out std_ulogic_vector(0 to 87);
        lsu_xu_data_debug0                      :in  std_ulogic_vector(0 to 87);
        lsu_xu_data_debug1                      :in  std_ulogic_vector(0 to 87);
        lsu_xu_data_debug2                      :in  std_ulogic_vector(0 to 87);
        fxa_cpl_debug                           :in  std_ulogic_vector(0 to 272);


        ac_tc_debug_trigger                     :out std_ulogic_vector(0 to threads-1);

        dec_cpl_rf0_act                         :in  std_ulogic;
        dec_cpl_rf0_tid                         :in  std_ulogic_vector(0 to threads-1);

        fu_xu_rf1_act                           :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex1_ifar                          :in  std_ulogic_vector(0 to eff_ifar*threads-1);
        fu_xu_ex2_ifar_val                      :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex2_ifar_issued                   :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex2_instr_type                    :in  std_ulogic_vector(0 to 3*threads-1);
        fu_xu_ex2_instr_match                   :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex2_is_ucode                      :in  std_ulogic_vector(0 to threads-1);

        pc_xu_step                              :in  std_ulogic_vector(0 to threads-1);
        pc_xu_stop                              :in  std_ulogic_vector(0 to threads-1);
        pc_xu_dbg_action                        :in  std_ulogic_vector(0 to 3*threads-1);
        pc_xu_force_ude                         :in  std_ulogic_vector(0 to threads-1);
        xu_pc_step_done                         :out std_ulogic_vector(0 to threads-1);
        pc_xu_init_reset                        :in  std_ulogic;

        mm_xu_local_snoop_reject                :in  std_ulogic_vector(0 to threads-1);
        mm_xu_lru_par_err                       :in  std_ulogic_vector(0 to threads-1);
        mm_xu_tlb_par_err                       :in  std_ulogic_vector(0 to threads-1);
        mm_xu_tlb_multihit_err                  :in  std_ulogic_vector(0 to threads-1);
        an_ac_external_mchk                     :in  std_ulogic_vector(0 to threads-1);

        xu_pc_err_attention_instr               :out std_ulogic_vector(0 to threads-1);
        xu_pc_err_nia_miscmpr                   :out std_ulogic_vector(0 to threads-1);
        xu_pc_err_debug_event                   :out std_ulogic_vector(0 to threads-1);

        xu_pc_stop_dbg_event                    :out std_ulogic_vector(0 to threads-1);

        mm_xu_illeg_instr                       :in  std_ulogic_vector(0 to threads-1);
        mm_xu_tlb_miss                          :in  std_ulogic_vector(0 to threads-1);
        mm_xu_pt_fault                          :in  std_ulogic_vector(0 to threads-1);
        mm_xu_tlb_inelig                        :in  std_ulogic_vector(0 to threads-1);
        mm_xu_lrat_miss                         :in  std_ulogic_vector(0 to threads-1);
        mm_xu_hv_priv                           :in  std_ulogic_vector(0 to threads-1);
        mm_xu_esr_pt                            :in  std_ulogic_vector(0 to threads-1);
        mm_xu_esr_data                          :in  std_ulogic_vector(0 to threads-1);
        mm_xu_esr_epid                          :in  std_ulogic_vector(0 to threads-1);
        mm_xu_esr_st                            :in  std_ulogic_vector(0 to threads-1);
        mm_xu_hold_req                          :in  std_ulogic_vector(0 to threads-1);
        mm_xu_hold_done                         :in  std_ulogic_vector(0 to threads-1);
        xu_mm_hold_ack                          :out std_ulogic_vector(0 to threads-1);
        mm_xu_eratmiss_done                     :in  std_ulogic_vector(0 to threads-1);
        mm_xu_ex3_flush_req                     :in  std_ulogic_vector(0 to threads-1);

        fu_xu_ex3_ap_int_req                    :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex3_trap                          :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex3_n_flush                       :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex3_np1_flush                     :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex3_flush2ucode                   :in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex2_async_block                   :in  std_ulogic_vector(0 to threads-1);

        xu_iu_ex5_br_taken                      :out std_ulogic;
        xu_iu_ex5_ifar                          :out std_ulogic_vector(62-eff_ifar to 61);
        xu_iu_flush                             :out std_ulogic_vector(0 to threads-1);
        xu_iu_iu0_flush_ifar                    :out std_ulogic_vector(0 to eff_ifar*threads-1);
        xu_iu_uc_flush_ifar                     :out std_ulogic_vector(0 to uc_ifar*threads-1);
        xu_iu_flush_2ucode                      :out std_ulogic_vector(0 to threads-1);
        xu_iu_flush_2ucode_type                 :out std_ulogic_vector(0 to threads-1);
        xu_iu_ucode_restart                     :out std_ulogic_vector(0 to threads-1);
        xu_iu_ex5_ppc_cpl                       :out std_ulogic_vector(0 to threads-1);

        xu_n_is2_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_n_rf0_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_n_rf1_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_n_ex1_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_n_ex2_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_n_ex3_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_n_ex4_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_n_ex5_flush                          :out std_ulogic_vector(0 to threads-1);

        xu_s_rf1_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_s_ex1_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_s_ex2_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_s_ex3_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_s_ex4_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_s_ex5_flush                          :out std_ulogic_vector(0 to threads-1);

        xu_w_rf1_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_w_ex1_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_w_ex2_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_w_ex3_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_w_ex4_flush                          :out std_ulogic_vector(0 to threads-1);
        xu_w_ex5_flush                          :out std_ulogic_vector(0 to threads-1);

        xu_lsu_ex4_flush_local                  :out std_ulogic_vector(0 to threads-1);
        xu_mm_ex4_flush                         :out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_flush                         :out std_ulogic_vector(0 to threads-1);
        xu_mm_ierat_flush                       :out std_ulogic_vector(0 to threads-1);
        xu_mm_ierat_miss                        :out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_perf_itlb                     :out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_perf_dtlb                     :out std_ulogic_vector(0 to threads-1);

        spr_xucr4_div_barr_thres                :out std_ulogic_vector(0 to 7);

        iu_xu_ierat_ex2_flush_req               :in  std_ulogic_vector(0 to threads-1);
        iu_xu_ierat_ex3_par_err                 :in  std_ulogic_vector(0 to threads-1);
        iu_xu_ierat_ex4_par_err                 :in  std_ulogic_vector(0 to threads-1);

        fu_xu_ex3_regfile_err_det               :in  std_ulogic_vector(0 to threads-1);
        xu_fu_regfile_seq_beg                   :out std_ulogic;
        fu_xu_regfile_seq_end                   :in  std_ulogic;
        gpr_cpl_ex3_regfile_err_det             :in  std_ulogic;
        cpl_gpr_regfile_seq_beg                 :out std_ulogic;
        gpr_cpl_regfile_seq_end                 :in  std_ulogic;
        xu_pc_err_mcsr_summary                  :out std_ulogic_vector(0 to threads-1);
        xu_pc_err_ditc_overrun                  :out std_ulogic;
        xu_pc_err_local_snoop_reject            :out std_ulogic;
        xu_pc_err_tlb_lru_parity                :out std_ulogic;
        xu_pc_err_ext_mchk                      :out std_ulogic;
        xu_pc_err_ierat_multihit                :out std_ulogic;
        xu_pc_err_derat_multihit                :out std_ulogic;
        xu_pc_err_tlb_multihit                  :out std_ulogic;
        xu_pc_err_ierat_parity                  :out std_ulogic;
        xu_pc_err_derat_parity                  :out std_ulogic;
        xu_pc_err_tlb_parity                    :out std_ulogic;
        xu_pc_err_mchk_disabled                 :out std_ulogic;

        xu_iu_rf1_val                           :out std_ulogic_vector(0 to threads-1);
        xu_rf1_val                              :out std_ulogic_vector(0 to threads-1);
        xu_rf1_is_tlbre                         :out std_ulogic;
        xu_rf1_is_tlbwe                         :out std_ulogic;
        xu_rf1_is_tlbsx                         :out std_ulogic;
        xu_rf1_is_tlbsrx                        :out std_ulogic;
        xu_rf1_is_tlbilx                        :out std_ulogic;
        xu_rf1_is_tlbivax                       :out std_ulogic;
        xu_rf1_is_eratre                        :out std_ulogic;
        xu_rf1_is_eratwe                        :out std_ulogic;
        xu_rf1_is_eratsx                        :out std_ulogic;
        xu_rf1_is_eratilx                       :out std_ulogic;
        xu_rf1_is_erativax                      :out std_ulogic;
        xu_ex1_is_isync                         :out std_ulogic;
        xu_ex1_is_csync                         :out std_ulogic;
        xu_rf1_ws                               :out std_ulogic_vector(0 to 1);
        xu_rf1_t                                :out std_ulogic_vector(0 to 2);
        xu_ex1_rs_is                            :out std_ulogic_vector(0 to 8);
        xu_ex1_ra_entry                         :out std_ulogic_vector(8 to 11);
        xu_ex4_rs_data                          :out std_ulogic_vector(64-(2**regmode) to 63);

        xu_lsu_rf1_data_act                     :out std_ulogic;
        xu_lsu_rf1_axu_ldst_falign              :out std_ulogic;
        xu_lsu_ex1_store_data                   :out std_ulogic_vector(64-(2**regmode) to 63);
        xu_lsu_ex1_rotsel_ovrd                  :out std_ulogic_vector(0 to 4);
        xu_lsu_ex1_eff_addr                     :out std_ulogic_vector(64-(dc_size-3) to 63);

        cpl_fxa_ex5_set_barr                    :out std_ulogic_vector(0 to threads-1);
        cpl_iu_set_barr_tid                     :out std_ulogic_vector(0 to threads-1);

        lsu_xu_ex6_datc_par_err                 :in std_ulogic;

        lsu_xu_ex2_dvc1_st_cmp                  :in std_ulogic_vector(8-(2**regmode)/8 to 7);
        lsu_xu_ex2_dvc2_st_cmp                  :in std_ulogic_vector(8-(2**regmode)/8 to 7);
        lsu_xu_ex8_dvc1_ld_cmp                  :in std_ulogic_vector(8-(2**regmode)/8 to 7);
        lsu_xu_ex8_dvc2_ld_cmp                  :in std_ulogic_vector(8-(2**regmode)/8 to 7);
        lsu_xu_rel_dvc1_en                      :in std_ulogic;
        lsu_xu_rel_dvc2_en                      :in std_ulogic;
        lsu_xu_rel_dvc_thrd_id                  :in std_ulogic_vector(0 to 3);
        lsu_xu_rel_dvc1_cmp                     :in std_ulogic_vector(8-(2**regmode)/8 to 7);
        lsu_xu_rel_dvc2_cmp                     :in std_ulogic_vector(8-(2**regmode)/8 to 7);

        lsu_xu_rot_ex6_data_b                   :in std_ulogic_vector(64-(2**regmode) to 63);
        lsu_xu_rot_rel_data                     :in std_ulogic_vector(64-(2**regmode) to 63);
        pc_xu_trace_bus_enable                  :in std_ulogic;
        pc_xu_instr_trace_mode                  :in std_ulogic;
        pc_xu_instr_trace_tid                   :in std_ulogic_vector(0 to 1);
        iu_xu_ex4_tlb_data                      :in std_ulogic_vector(64-(2**regmode) to 63);

        pc_xu_inj_dcachedir_parity              :in  std_ulogic;
        pc_xu_inj_dcachedir_multihit            :in  std_ulogic;

        ex4_256st_data                          :in  std_ulogic_vector(0 to 255);
                                             
        an_ac_flh2l2_gate                       :in  std_ulogic;                        
                                                                                              
        xu_lsu_rf0_derat_val                    :in  std_ulogic_vector(0 to 3);         
        xu_lsu_rf0_derat_is_extload             :in  std_ulogic;                      
        xu_lsu_rf0_derat_is_extstore            :in  std_ulogic;                      
        xu_lsu_hid_mmu_mode                     :in  std_ulogic;                        
        ex6_ld_par_err                          :in  std_ulogic;                        
                                               
        xu_mm_derat_req                         :out std_ulogic;
        xu_mm_derat_thdid                       :out std_ulogic_vector(0 to 3);
        xu_mm_derat_state                       :out std_ulogic_vector(0 to 3);
        xu_mm_derat_tid                         :out std_ulogic_vector(0 to 13);
        xu_mm_derat_lpid                        :out std_ulogic_vector(0 to 7);
        xu_mm_derat_ttype                       :out std_ulogic_vector(0 to 1);
        mm_xu_derat_rel_val                     :in  std_ulogic_vector(0 to 4);
        mm_xu_derat_rel_data                    :in  std_ulogic_vector(0 to 131);
        mm_xu_derat_pid0                        :in  std_ulogic_vector(0 to 13);         
        mm_xu_derat_pid1                        :in  std_ulogic_vector(0 to 13);         
        mm_xu_derat_pid2                        :in  std_ulogic_vector(0 to 13);         
        mm_xu_derat_pid3                        :in  std_ulogic_vector(0 to 13);         
        mm_xu_derat_mmucr0_0                    :in  std_ulogic_vector(0 to 19);
        mm_xu_derat_mmucr0_1                    :in  std_ulogic_vector(0 to 19);
        mm_xu_derat_mmucr0_2                    :in  std_ulogic_vector(0 to 19);
        mm_xu_derat_mmucr0_3                    :in  std_ulogic_vector(0 to 19);
        xu_mm_derat_mmucr0                      :out std_ulogic_vector(0 to 17);
        xu_mm_derat_mmucr0_we                   :out std_ulogic_vector(0 to 3);
        mm_xu_derat_mmucr1                      :in  std_ulogic_vector(0 to 9);
        xu_mm_derat_mmucr1                      :out std_ulogic_vector(0 to 4);
        xu_mm_derat_mmucr1_we                   :out std_ulogic;
        mm_xu_derat_snoop_coming                :in  std_ulogic;
        mm_xu_derat_snoop_val                   :in  std_ulogic;
        mm_xu_derat_snoop_attr                  :in  std_ulogic_vector(0 to 25);
        mm_xu_derat_snoop_vpn                   :in  std_ulogic_vector(64-(2**REGMODE) to 51);
        xu_mm_derat_snoop_ack                   :out std_ulogic;
                                               
        ex1_optype1                             :out std_ulogic;
        ex1_optype2                             :out std_ulogic;
        ex1_optype4                             :out std_ulogic;
        ex1_optype8                             :out std_ulogic;
        ex1_optype16                            :out std_ulogic;
        ex1_optype32                            :out std_ulogic;
        ex1_saxu_instr                          :out std_ulogic;
        ex1_sdp_instr                           :out std_ulogic;
        ex1_stgpr_instr                         :out std_ulogic;
        ex1_store_instr                         :out std_ulogic;
        ex1_axu_op_val                          :out std_ulogic;                                               
                                               
        ex3_algebraic                           :out std_ulogic;
        ex3_data_swap                           :out std_ulogic;
        ex3_thrd_id                             :out std_ulogic_vector(0 to 3);
        xu_fu_ex3_eff_addr                      :out std_ulogic_vector(59 to 63);
        xu_lsu_ici                              :out std_ulogic;

        rel_upd_dcarr_val                       :out std_ulogic;
                                               
        xu_fu_ex5_reload_val                    :out std_ulogic;
        xu_fu_ex5_load_val                      :out std_ulogic_vector(0 to 3);
        xu_fu_ex5_load_tag                      :out std_ulogic_vector(0 to 8);
                                               
        dcarr_up_way_addr                       :out std_ulogic_vector(0 to 2);
                                                                                           
        ex4_load_op_hit                         :out std_ulogic;
        ex4_store_hit                           :out std_ulogic;
        ex4_axu_op_val                          :out std_ulogic;
        spr_dvc1_act                            :out std_ulogic;
        spr_dvc2_act                            :out std_ulogic;
        spr_dvc1_dbg                            :out std_ulogic_vector(64-(2**regmode) to 63);
        spr_dvc2_dbg                            :out std_ulogic_vector(64-(2**regmode) to 63);
                                               
        an_ac_req_ld_pop                        :in  std_ulogic;
        an_ac_req_st_pop                        :in  std_ulogic;
        an_ac_req_st_gather                     :in  std_ulogic;
        an_ac_req_st_pop_thrd                   :in  std_ulogic_vector(0 to 2);   
                                               
        an_ac_reld_data_vld                     :in  std_ulogic;
        an_ac_reld_core_tag                     :in  std_ulogic_vector(0 to 4);
        an_ac_reld_qw                           :in  std_ulogic_vector(57 to 59);
        an_ac_reld_data                         :in  std_ulogic_vector(0 to 127);
        an_ac_reld_data_coming                  :in  std_ulogic;
        an_ac_reld_ditc                         :in  std_ulogic;
        an_ac_reld_crit_qw                      :in  std_ulogic;
        an_ac_reld_l1_dump                      :in  std_ulogic;
                                               
        an_ac_reld_ecc_err                      :in  std_ulogic;
        an_ac_reld_ecc_err_ue                   :in  std_ulogic;
                                               
        an_ac_back_inv                          :in  std_ulogic;
        an_ac_back_inv_addr                     :in  std_ulogic_vector(64-real_data_add to 63);
        an_ac_back_inv_target_bit1              :in  std_ulogic;
        an_ac_back_inv_target_bit3              :in  std_ulogic;
        an_ac_back_inv_target_bit4              :in  std_ulogic;
        an_ac_req_spare_ctrl_a1                 :in  std_ulogic_vector(0 to 3);


        lsu_reld_data_vld                       :out std_ulogic;                      
        lsu_reld_core_tag                       :out std_ulogic_vector(3 to 4);       
        lsu_reld_qw                             :out std_ulogic_vector(58 to 59);     
        lsu_reld_ditc                           :out std_ulogic;                      
        lsu_reld_ecc_err                        :out std_ulogic;                      
        lsu_reld_data                           :out std_ulogic_vector(0 to 127);     

        lsu_req_st_pop                          :out std_ulogic;                  
        lsu_req_st_pop_thrd                     :out std_ulogic_vector(0 to 2);   

     ac_an_reld_ditc_pop_int    : in  std_ulogic_vector(0 to 3);
     ac_an_reld_ditc_pop_q      : out std_ulogic_vector(0 to 3);
     bx_ib_empty_int            : in  std_ulogic_vector(0 to 3);
     bx_ib_empty_q              : out std_ulogic_vector(0 to 3);

        iu_xu_ra                                :in  std_ulogic_vector(64-real_data_add to 59);
        iu_xu_request                           :in  std_ulogic;
        iu_xu_wimge                             :in  std_ulogic_vector(0 to 4);
        iu_xu_thread                            :in  std_ulogic_vector(0 to 3);
        iu_xu_userdef                           :in  std_ulogic_vector(0 to 3);

        mm_xu_lsu_req                           :in  std_ulogic_vector(0 to 3);
        mm_xu_lsu_ttype                         :in  std_ulogic_vector(0 to 1);
        mm_xu_lsu_wimge                         :in  std_ulogic_vector(0 to 4);
        mm_xu_lsu_u                             :in  std_ulogic_vector(0 to 3);
        mm_xu_lsu_addr                          :in  std_ulogic_vector(64-real_data_add to 63);
        mm_xu_lsu_lpid                          :in  std_ulogic_vector(0 to 7); 
        mm_xu_lsu_lpidr                         :in  std_ulogic_vector(0 to 7); 
        mm_xu_lsu_gs                            :in  std_ulogic;
        mm_xu_lsu_ind                           :in  std_ulogic;
        mm_xu_lsu_lbit                          :in  std_ulogic;                   
        xu_mm_lsu_token                         :out std_ulogic;

        bx_lsu_ob_pwr_tok                       :in  std_ulogic;
        bx_lsu_ob_req_val                       :in  std_ulogic;                  
        bx_lsu_ob_ditc_val                      :in  std_ulogic;                  
        bx_lsu_ob_thrd                          :in  std_ulogic_vector(0 to 1);   
        bx_lsu_ob_qw                            :in  std_ulogic_vector(58 to 59); 
        bx_lsu_ob_dest                          :in  std_ulogic_vector(0 to 14);  
        bx_lsu_ob_data                          :in  std_ulogic_vector(0 to 127); 
        bx_lsu_ob_addr                          :in  std_ulogic_vector(64-real_data_add to 57); 
        lsu_bx_cmd_avail                        :out std_ulogic;
        lsu_bx_cmd_sent                         :out std_ulogic;
        lsu_bx_cmd_stall                        :out std_ulogic;

        lsu_xu_ldq_barr_done                    :out std_ulogic_vector(0 to 3);         
        lsu_xu_barr_done                        :out std_ulogic_vector(0 to 3);

        ldq_rel_data_val_early                  :out std_ulogic;
        ldq_rel_op_size                         :out std_ulogic_vector(0 to 5);
        ldq_rel_addr                            :out std_ulogic_vector(64-(dc_size-3) to 58);
        ldq_rel_data_val                        :out std_ulogic;
        ldq_rel_rot_sel                         :out std_ulogic_vector(0 to 4);
        ldq_rel_axu_val                         :out std_ulogic;
        ldq_rel_ci                              :out std_ulogic;
        ldq_rel_thrd_id                         :out std_ulogic_vector(0 to 3);
        ldq_rel_le_mode                         :out std_ulogic;
        ldq_rel_algebraic                       :out std_ulogic;
        ldq_rel_256_data                        :out std_ulogic_vector(0 to 255);

        ldq_rel_dvc1_en                         :out std_ulogic;
        ldq_rel_dvc2_en                         :out std_ulogic;
        ldq_rel_beat_crit_qw                    :out std_ulogic;
        ldq_rel_beat_crit_qw_block              :out std_ulogic;                        
        lsu_xu_rel_wren                         :out std_ulogic;
        lsu_xu_rel_ta_gpr                       :out std_ulogic_vector(0 to 7);

        xu_iu_ex4_loadmiss_qentry               :out std_ulogic_vector(0 to lmq_entries-1);
        xu_iu_ex4_loadmiss_target               :out std_ulogic_vector(0 to 8);
        xu_iu_ex4_loadmiss_target_type          :out std_ulogic_vector(0 to 1);
        xu_iu_ex4_loadmiss_tid                  :out std_ulogic_vector(0 to 3);
        xu_iu_ex5_loadmiss_qentry               :out std_ulogic_vector(0 to lmq_entries-1);
        xu_iu_ex5_loadmiss_target               :out std_ulogic_vector(0 to 8);
        xu_iu_ex5_loadmiss_target_type          :out std_ulogic_vector(0 to 1);
        xu_iu_ex5_loadmiss_tid                  :out std_ulogic_vector(0 to 3);
        xu_iu_complete_qentry                   :out std_ulogic_vector(0 to lmq_entries-1);
        xu_iu_complete_tid                      :out std_ulogic_vector(0 to 3);
        xu_iu_complete_target_type              :out std_ulogic_vector(0 to 1);
                                               
        xu_iu_ex6_icbi_val                      :out std_ulogic_vector(0 to 3);
        xu_iu_ex6_icbi_addr                     :out std_ulogic_vector(64-real_data_add to 57);     
                                               
        xu_iu_larx_done_tid                     :out std_ulogic_vector(0 to 3);
        xu_mm_lmq_stq_empty                     :out std_ulogic;
        xu_ex1_rb                               :out std_ulogic_vector(64-(2**regmode) to 51);
        xu_ex2_eff_addr                         :out std_ulogic_vector(64-(2**regmode) to 63);
                                               
        ac_an_req_pwr_token                     :out std_ulogic;
        ac_an_req                               :out std_ulogic;
        ac_an_req_ra                            :out std_ulogic_vector(64-real_data_add to 63);
        ac_an_req_ttype                         :out std_ulogic_vector(0 to 5);
        ac_an_req_thread                        :out std_ulogic_vector(0 to 2);
        ac_an_req_wimg_w                        :out std_ulogic;
        ac_an_req_wimg_i                        :out std_ulogic;
        ac_an_req_wimg_m                        :out std_ulogic;
        ac_an_req_wimg_g                        :out std_ulogic;
        ac_an_req_endian                        :out std_ulogic;
        ac_an_req_user_defined                  :out std_ulogic_vector(0 to 3);
        ac_an_req_spare_ctrl_a0                 :out std_ulogic_vector(0 to 3);
        ac_an_req_ld_core_tag                   :out std_ulogic_vector(0 to 4);
        ac_an_req_ld_xfr_len                    :out std_ulogic_vector(0 to 2);
        ac_an_st_byte_enbl                      :out std_ulogic_vector(0 to 15+(st_data_32B_mode*16));
        ac_an_st_data                           :out std_ulogic_vector(0 to 127+(st_data_32B_mode*128));
        ac_an_st_data_pwr_token                 :out std_ulogic;

        xu_pc_err_dcachedir_parity              :out std_ulogic;
        xu_pc_err_dcachedir_multihit            :out std_ulogic;
        xu_pc_err_l2intrf_ecc                   :out std_ulogic;
        xu_pc_err_l2intrf_ue                    :out std_ulogic;
        xu_pc_err_invld_reld                    :out std_ulogic;
        xu_pc_err_l2credit_overrun              :out std_ulogic;
                                               
        pc_xu_event_bus_enable                  :in  std_ulogic;
        pc_xu_lsu_event_mux_ctrls               :in  std_ulogic_vector(0 to 47);
        pc_xu_cache_par_err_event               :in  std_ulogic;
        xu_pc_lsu_event_data                    :out std_ulogic_vector(0 to 7);
        fxa_perf_muldiv_in_use                  :in  std_ulogic;
                                               
        dec_spr_rf0_tid                         :in  std_ulogic_vector(0 to threads-1);
        dec_spr_rf0_instr                       :in  std_ulogic_vector(0 to 31);

        ac_an_dcr_act                           :out std_ulogic;
        ac_an_dcr_val                           :out std_ulogic;
        ac_an_dcr_read                          :out std_ulogic;
        ac_an_dcr_user                          :out std_ulogic;
        ac_an_dcr_etid                          :out std_ulogic_vector(0 to 1);
        ac_an_dcr_addr                          :out std_ulogic_vector(11 to 20);
        ac_an_dcr_data                          :out std_ulogic_vector(64-regsize to 63);

        xu_pc_running                           :out std_ulogic_vector(0 to threads-1);
        xu_iu_run_thread                        :out std_ulogic_vector(0 to threads-1);
        xu_iu_single_instr_mode                 :out std_ulogic_vector(0 to threads-1);
        xu_iu_raise_iss_pri                     :out std_ulogic_vector(0 to threads-1);
        xu_pc_spr_ccr0_we                       :out std_ulogic_vector(0 to threads-1);

        iu_xu_quiesce                           :in  std_ulogic_vector(0 to threads-1);
        mm_xu_quiesce                           :in  std_ulogic_vector(0 to threads-1);
        bx_xu_quiesce                           :in  std_ulogic_vector(0 to threads-1);

        pc_xu_extirpts_dis_on_stop              :in  std_ulogic;
        pc_xu_timebase_dis_on_stop              :in  std_ulogic;
        pc_xu_decrem_dis_on_stop                :in  std_ulogic;

        pc_xu_msrovride_pr                      :in  std_ulogic;

        xu_pc_err_llbust_attempt                :out std_ulogic_vector(0 to threads-1);
        xu_pc_err_llbust_failed                 :out std_ulogic_vector(0 to threads-1);   

        pc_xu_reset_wd_complete                 :in  std_ulogic;
        pc_xu_reset_1_complete                  :in  std_ulogic;
        pc_xu_reset_2_complete                  :in  std_ulogic;
        pc_xu_reset_3_complete                  :in  std_ulogic;
        ac_tc_reset_1_request                   :out std_ulogic;
        ac_tc_reset_2_request                   :out std_ulogic;
        ac_tc_reset_3_request                   :out std_ulogic;
        ac_tc_reset_wd_request                  :out std_ulogic;

        pc_xu_inj_llbust_attempt                :in  std_ulogic_vector(0 to threads-1);
        pc_xu_inj_llbust_failed                 :in  std_ulogic_vector(0 to threads-1);
        pc_xu_inj_wdt_reset                     :in  std_ulogic_vector(0 to threads-1);
        xu_pc_err_wdt_reset                     :out std_ulogic_vector(0 to threads-1);

        pc_xu_inj_sprg_ecc                      :in  std_ulogic_vector(0 to threads-1);
        xu_pc_err_sprg_ecc                      :out std_ulogic_vector(0 to threads-1);
        xu_pc_err_sprg_ue                       :out std_ulogic_vector(0 to threads-1);

        spr_msr_is                              :out std_ulogic_vector(0 to threads-1);
        spr_msr_gs                              :out std_ulogic_vector(0 to threads-1);
        spr_msr_pr                              :out std_ulogic_vector(0 to threads-1);
        spr_msr_ds                              :out std_ulogic_vector(0 to threads-1);
        spr_msr_cm                              :out std_ulogic_vector(0 to threads-1);
        spr_msr_fp                              :out std_ulogic_vector(0 to threads-1);
        spr_msr_spv                             :out std_ulogic_vector(0 to threads-1);
        spr_ccr2_ap                             :out std_ulogic_vector(0 to threads-1);
        spr_ccr2_en_dcr                         :out std_ulogic;
        spr_ccr2_notlb                          :out std_ulogic;
        spr_ccr2_en_ditc                        :out std_ulogic;
        xu_lsu_spr_xucr0_dcdis                  :out std_ulogic;
        xu_lsu_spr_xucr0_rel                    :out std_ulogic;
        xu_pc_spr_ccr0_pme                      :out std_ulogic_vector(0 to 1);
        xu_iu_spr_ccr2_ifratsc                  :out std_ulogic_vector(0 to 8);
        xu_iu_spr_ccr2_ifrat                    :out std_ulogic;
        spr_xucr0_clkg_ctl_b0                   :out std_ulogic;
        xu_mm_spr_epcr_dmiuh                    :out std_ulogic_vector(0 to threads-1);
        xu_mm_spr_epcr_dgtmi                    :out std_ulogic_vector(0 to threads-1);
        cpl_msr_gs                              :out std_ulogic_vector(0 to threads-1);
        cpl_msr_pr                              :out std_ulogic_vector(0 to threads-1);
        cpl_msr_fp                              :out std_ulogic_vector(0 to threads-1);
        cpl_msr_spv                             :out std_ulogic_vector(0 to threads-1);
        cpl_ccr2_ap                             :out std_ulogic_vector(0 to threads-1);
        spr_xucr4_mmu_mchk                      :out std_ulogic;

        pc_xu_bolt_sl_thold_3                   :in     std_ulogic;
        pc_xu_bo_enable_3                       :in     std_ulogic;
        bolt_sl_thold_2                         :out std_ulogic;
        bo_enable_2                             :out std_ulogic;
        pc_xu_bo_unload                         :in     std_ulogic;
        pc_xu_bo_repair                         :in     std_ulogic;
        pc_xu_bo_reset                          :in     std_ulogic;
        pc_xu_bo_shdata                         :in     std_ulogic;
        pc_xu_bo_select                         :in     std_ulogic_vector(0 to 4);
        xu_pc_bo_fail                           :out    std_ulogic_vector(0 to 4);
        xu_pc_bo_diagout                        :out    std_ulogic_vector(0 to 4);
        an_ac_coreid                            :in  std_ulogic_vector(54 to 61);
        spr_pvr_version_dc                      :in  std_ulogic_vector(8 to 15);
        spr_pvr_revision_dc                     :in  std_ulogic_vector(12 to 15);
        an_ac_atpg_en_dc                        :in  std_ulogic;
        an_ac_ext_interrupt                     :in  std_ulogic_vector(0 to threads-1);
        an_ac_crit_interrupt                    :in  std_ulogic_vector(0 to threads-1);
        an_ac_perf_interrupt                    :in  std_ulogic_vector(0 to threads-1);
        an_ac_reservation_vld                   :in  std_ulogic_vector(0 to threads-1);
        an_ac_grffence_en_dc                    :in  std_ulogic;
        an_ac_tb_update_pulse                   :in  std_ulogic;
        an_ac_tb_update_enable                  :in  std_ulogic;
        an_ac_sleep_en                          :in  std_ulogic_vector(0 to threads-1);
        an_ac_hang_pulse                        :in  std_ulogic_vector(0 to threads-1);
        an_ac_scan_dis_dc_b                     :in  std_ulogic;
        an_ac_lbist_en_dc                       :in  std_ulogic;
        an_ac_lbist_ary_wrt_thru_dc             :in  std_ulogic;
        ac_tc_machine_check                     :out std_ulogic_vector(0 to threads-1);
        pc_xu_abist_raddr_0                     :in  std_ulogic_vector(4 to 9);
        pc_xu_abist_ena_dc                      :in  std_ulogic;
        pc_xu_abist_waddr_0                     :in  std_ulogic_vector(4 to 9);
        pc_xu_abist_di_0                        :in  std_ulogic_vector(0 to 3);
        pc_xu_abist_raw_dc_b                    :in  std_ulogic;
        pc_xu_ccflush_dc                        :in  std_ulogic;
        pc_xu_abist_g8t_wenb                    :in  std_ulogic;
        pc_xu_abist_g8t1p_renb_0                :in  std_ulogic;
        pc_xu_abist_g8t_bw_1                    :in  std_ulogic;
        pc_xu_abist_g8t_bw_0                    :in  std_ulogic;
        pc_xu_abist_wl32_comp_ena               :in  std_ulogic;
        pc_xu_abist_g8t_dcomp                   :in  std_ulogic_vector(0 to 3);
        clkoff_dc_b                             :out std_ulogic;
        d_mode_dc                               :out std_ulogic;
        delay_lclkr_dc                          :out std_ulogic_vector(0 to 4);
        mpw1_dc_b                               :out std_ulogic_vector(0 to 4);
        mpw2_dc_b                               :out std_ulogic;
        g6t_clkoff_dc_b                         :out std_ulogic;
        g6t_d_mode_dc                           :out std_ulogic;
        g6t_delay_lclkr_dc                      :out std_ulogic_vector(0 to 4);
        g6t_mpw1_dc_b                           :out std_ulogic_vector(0 to 4);
        g6t_mpw2_dc_b                           :out std_ulogic;
        pc_xu_sg_3                              :in  std_ulogic_vector(0 to 4);
        pc_xu_func_sl_thold_3                   :in  std_ulogic_vector(0 to 4);
        pc_xu_func_slp_sl_thold_3               :in  std_ulogic_vector(0 to 4);
        pc_xu_func_nsl_thold_3                  :in  std_ulogic;
        pc_xu_func_slp_nsl_thold_3              :in  std_ulogic;
        pc_xu_gptr_sl_thold_3                   :in  std_ulogic;
        pc_xu_abst_sl_thold_3                   :in  std_ulogic;
        pc_xu_abst_slp_sl_thold_3               :in  std_ulogic;
        pc_xu_regf_sl_thold_3                   :in  std_ulogic;
        pc_xu_regf_slp_sl_thold_3               :in  std_ulogic;
        pc_xu_time_sl_thold_3                   :in  std_ulogic;
        pc_xu_cfg_sl_thold_3                    :in  std_ulogic;
        pc_xu_cfg_slp_sl_thold_3                :in  std_ulogic;
        pc_xu_ary_nsl_thold_3                   :in  std_ulogic;
        pc_xu_ary_slp_nsl_thold_3               :in  std_ulogic;
        pc_xu_repr_sl_thold_3                   :in  std_ulogic;
        pc_xu_fce_3                             :in  std_ulogic_vector(0 to 1);
        an_ac_scan_diag_dc                      :in  std_ulogic;
        sg_2                                    :out std_ulogic_vector(0 to 3);
        fce_2                                   :out std_ulogic_vector(0 to 1);
        func_sl_thold_2                         :out std_ulogic_vector(0 to 3);
        func_slp_sl_thold_2                     :out std_ulogic_vector(0 to 1);
        func_slp_nsl_thold_2                    :out std_ulogic;
        func_nsl_thold_2                        :out std_ulogic;
        abst_sl_thold_2                         :out std_ulogic;
        time_sl_thold_2                         :out std_ulogic;
        gptr_sl_thold_2                         :out std_ulogic;
        ary_nsl_thold_2                         :out std_ulogic;
        repr_sl_thold_2                         :out std_ulogic;
        cfg_sl_thold_2                          :out std_ulogic;
        cfg_slp_sl_thold_2                      :out std_ulogic;
        regf_slp_sl_thold_2                     :out std_ulogic;
        gptr_scan_in                            :in  std_ulogic;
        gptr_scan_out                           :out std_ulogic;
        time_scan_in                            :in  std_ulogic;
        time_scan_out                           :out std_ulogic;
        ccfg_scan_in                            :in  std_ulogic;
        ccfg_scan_out                           :out std_ulogic;
        regf_scan_in                            :in  std_ulogic_vector(0 to 6);
        regf_scan_out                           :out std_ulogic_vector(0 to 6); 
        abst_scan_in                            :in  std_ulogic_vector(0 to 1);
        abst_scan_out                           :out std_ulogic_vector(0 to 1);
        repr_scan_in                            :in  std_ulogic;
        repr_scan_out                           :out std_ulogic;
        func_scan_in                            :in  std_ulogic_vector(35 to 58);
        func_scan_out                           :out std_ulogic_vector(35 to 58);
        bcfg_scan_in                            :in  std_ulogic;
        bcfg_scan_out                           :out std_ulogic;
        dcfg_scan_in                            :in  std_ulogic;
        dcfg_scan_out                           :out std_ulogic;
                                               
        vcs                                     :inout power_logic;
        vdd                                     :inout power_logic;
        gnd                                     :inout power_logic;
        nclk                                    :in  clk_logic
);

-- synopsys translate_off


-- synopsys translate_on
end xuq_ctrl_spr;
architecture xuq_ctrl_spr of xuq_ctrl_spr is

signal bolt_sl_thold_2_b                         : std_ulogic;
signal bo_enable_2_b                             : std_ulogic;
signal clkoff_dc_b_b                             : std_ulogic;
signal d_mode_dc_b                               : std_ulogic;
signal delay_lclkr_dc_b                          : std_ulogic_vector(0 to 4);
signal mpw1_dc_b_b                               : std_ulogic_vector(0 to 4);
signal mpw2_dc_b_b                               : std_ulogic;
signal sg_2_b                                    : std_ulogic_vector(0 to 3);
signal fce_2_b                                   : std_ulogic_vector(0 to 1);
signal func_sl_thold_2_b                         : std_ulogic_vector(0 to 3);
signal func_slp_sl_thold_2_b                     : std_ulogic_vector(0 to 1);
signal func_slp_nsl_thold_2_b                    : std_ulogic;
signal func_nsl_thold_2_b                        : std_ulogic;
signal abst_sl_thold_2_b                         : std_ulogic;
signal time_sl_thold_2_b                         : std_ulogic;
signal gptr_sl_thold_2_b                         : std_ulogic;
signal ary_nsl_thold_2_b                         : std_ulogic;
signal repr_sl_thold_2_b                         : std_ulogic;
signal cfg_sl_thold_2_b                          : std_ulogic;
signal cfg_slp_sl_thold_2_b                      : std_ulogic;

signal dec_spr_ex4_val                          :std_ulogic_vector(0 to threads-1);
signal dec_spr_ex1_epid_instr                   :std_ulogic;
signal mux_spr_ex2_rt                           :std_ulogic_vector(64-(2**regmode) to 63);
signal fxu_spr_ex1_rs0                          :std_ulogic_vector(52 to 63);
signal fxu_spr_ex1_rs1                          :std_ulogic_vector(54 to 63);
signal spr_msr_cm_int                           :std_ulogic_vector(0 to threads-1);
signal spr_dec_spr_xucr0_ssdly                  :std_ulogic_vector(0 to 4);
signal spr_ccr2_en_attn                         :std_ulogic;
signal spr_ccr2_en_ditc_int                     :std_ulogic;
signal spr_ccr2_en_pc                           :std_ulogic;
signal spr_ccr2_en_icswx                        :std_ulogic;
signal spr_ccr2_en_dcr_int                      :std_ulogic;
signal spr_dec_rf1_epcr_dgtmi                   :std_ulogic_vector(0 to threads-1);
signal spr_byp_ex4_is_mfxer                     :std_ulogic_vector(0 to threads-1);
signal spr_byp_ex3_spr_rt                       :std_ulogic_vector(64-(2**regmode) to 63);
signal spr_byp_ex4_is_mtxer                     :std_ulogic_vector(0 to threads-1);
signal spr_ccr2_notlb_int                       :std_ulogic;
signal dec_spr_rf1_val                          :std_ulogic_vector(0 to threads-1);
signal fxu_spr_ex1_rs2                          :std_ulogic_vector(42 to 55);
signal spr_perf_tx_events                       :std_ulogic_vector(0 to 8*threads-1);
signal spr_msr_gs_int                           :std_ulogic_vector(0 to threads-1);
signal spr_msr_ds_int                           :std_ulogic_vector(0 to threads-1);
signal spr_msr_pr_int                           :std_ulogic_vector(0 to threads-1);
signal spr_dbcr0_dac1                           :std_ulogic_vector(0 to 2*threads-1);
signal spr_dbcr0_dac2                           :std_ulogic_vector(0 to 2*threads-1);
signal spr_dbcr0_dac3                           :std_ulogic_vector(0 to 2*threads-1);
signal spr_dbcr0_dac4                           :std_ulogic_vector(0 to 2*threads-1);
signal spr_cpl_external_mchk                    :std_ulogic_vector(0 to threads-1);
signal spr_cpl_ext_interrupt                    :std_ulogic_vector(0 to threads-1);
signal spr_cpl_dec_interrupt                    :std_ulogic_vector(0 to threads-1);
signal spr_cpl_udec_interrupt                   :std_ulogic_vector(0 to threads-1);
signal spr_cpl_perf_interrupt                   :std_ulogic_vector(0 to threads-1);
signal spr_cpl_fit_interrupt                    :std_ulogic_vector(0 to threads-1);
signal spr_cpl_crit_interrupt                   :std_ulogic_vector(0 to threads-1);
signal spr_cpl_wdog_interrupt                   :std_ulogic_vector(0 to threads-1);   
signal spr_cpl_dbell_interrupt                  :std_ulogic_vector(0 to threads-1);
signal spr_cpl_cdbell_interrupt                 :std_ulogic_vector(0 to threads-1);
signal spr_cpl_gdbell_interrupt                 :std_ulogic_vector(0 to threads-1);
signal spr_cpl_gcdbell_interrupt                :std_ulogic_vector(0 to threads-1);
signal spr_cpl_gmcdbell_interrupt               :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_dbell_taken                  :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_cdbell_taken                 :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_gdbell_taken                 :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_gcdbell_taken                :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_gmcdbell_taken               :std_ulogic_vector(0 to threads-1);
signal spr_bit_act                              :std_ulogic;
signal cpl_spr_ex5_act                          :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_int                          :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_gint                         :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_cint                         :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_mcint                        :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_nia                          :std_ulogic_vector(0 to eff_ifar*threads-1);
signal cpl_spr_ex5_esr                          :std_ulogic_vector(0 to 17*threads-1);
signal cpl_spr_ex5_mcsr                         :std_ulogic_vector(0 to 15*threads-1);
signal cpl_spr_ex5_dbsr                         :std_ulogic_vector(0 to 19*threads-1);
signal cpl_spr_ex5_dear_update                  :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_dear_update_saved            :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_dear_save                    :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_dbsr_update                  :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_esr_update                   :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_srr0_dec                     :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_force_gsrr                   :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_dbsr_ide                     :std_ulogic_vector(0 to threads-1);
signal spr_cpl_dbsr_ide                         :std_ulogic_vector(0 to threads-1);
signal spr_cpl_ex3_ct_le                        :std_ulogic_vector(0 to threads-1);
signal spr_cpl_ex3_ct_be                        :std_ulogic_vector(0 to threads-1);
signal spr_cpl_ex3_spr_hypv                     :std_ulogic;
signal spr_cpl_ex3_spr_illeg                    :std_ulogic;
signal spr_cpl_ex3_spr_priv                     :std_ulogic;
signal cpl_spr_stop                             :std_ulogic_vector(0 to threads-1);
signal cpl_spr_ex5_instr_cpl                    :std_ulogic_vector(0 to threads-1);
signal cpl_spr_quiesce                          :std_ulogic_vector(0 to threads-1);
signal spr_cpl_quiesce                          :std_ulogic_vector(0 to threads-1);
signal spr_cpl_ex2_run_ctl_flush                :std_ulogic_vector(0 to threads-1);
signal spr_cpl_fp_precise                       :std_ulogic_vector(0 to threads-1);
signal spr_cpl_iac1_en                          :std_ulogic_vector(0 to threads-1);
signal spr_cpl_iac2_en                          :std_ulogic_vector(0 to threads-1);
signal spr_cpl_iac3_en                          :std_ulogic_vector(0 to threads-1);
signal spr_cpl_iac4_en                          :std_ulogic_vector(0 to threads-1);
signal spr_dbcr1_iac12m                         :std_ulogic_vector(0 to threads-1);
signal spr_dbcr1_iac34m                         :std_ulogic_vector(0 to threads-1);
signal spr_epcr_duvd                            :std_ulogic_vector(0 to threads-1);
signal spr_xucr0_mddp                           :std_ulogic;
signal spr_xucr0_mdcp                           :std_ulogic;
signal spr_msr_de                               :std_ulogic_vector(0 to threads-1);
signal spr_msr_spv_int                          :std_ulogic_vector(0 to threads-1);
signal spr_msr_fp_int                           :std_ulogic_vector(0 to threads-1);
signal spr_msr_me                               :std_ulogic_vector(0 to threads-1);
signal spr_msr_ucle                             :std_ulogic_vector(0 to threads-1);
signal spr_msrp_uclep                           :std_ulogic_vector(0 to threads-1);
signal spr_ccr2_ucode_dis                       :std_ulogic;
signal spr_ccr2_ap_int                          :std_ulogic_vector(0 to 3);
signal cpl_spr_dbcr0_edm                        :std_ulogic_vector(0 to threads-1);
signal spr_dbcr0_idm                            :std_ulogic_vector(0 to threads-1);
signal spr_dbcr0_icmp                           :std_ulogic_vector(0 to threads-1);
signal spr_dbcr0_brt                            :std_ulogic_vector(0 to threads-1);
signal spr_dbcr0_trap                           :std_ulogic_vector(0 to threads-1);
signal spr_dbcr0_ret                            :std_ulogic_vector(0 to threads-1);
signal spr_dbcr0_irpt                           :std_ulogic_vector(0 to threads-1);
signal spr_epcr_dsigs                           :std_ulogic_vector(0 to threads-1);
signal spr_epcr_isigs                           :std_ulogic_vector(0 to threads-1);
signal spr_epcr_extgs                           :std_ulogic_vector(0 to threads-1);
signal spr_epcr_dtlbgs                          :std_ulogic_vector(0 to threads-1);
signal spr_epcr_itlbgs                          :std_ulogic_vector(0 to threads-1);
signal spr_cpl_ex3_sprg_ce                      :std_ulogic;
signal spr_cpl_ex3_sprg_ue                      :std_ulogic;
signal xu_lsu_slowspr_val                       :std_ulogic;
signal xu_lsu_slowspr_rw                        :std_ulogic;
signal xu_lsu_slowspr_etid                      :std_ulogic_vector(0 to 1);
signal xu_lsu_slowspr_addr                      :std_ulogic_vector(0 to 9);
signal xu_lsu_slowspr_data                      :std_ulogic_vector(64-(2**REGMODE) to 63);
signal xu_lsu_slowspr_done                      :std_ulogic;
signal lsu_xu_dbell_val                         :std_ulogic;
signal lsu_xu_dbell_type                        :std_ulogic_vector(0 to 4);
signal lsu_xu_dbell_brdcast                     :std_ulogic;
signal lsu_xu_dbell_lpid_match                  :std_ulogic;
signal lsu_xu_dbell_pirtag                      :std_ulogic_vector(50 to 63);
signal lsu_xu_quiesce                           :std_ulogic_vector(0 to threads-1);
signal xu_lsu_mtspr_trace_en                    :std_ulogic_vector(0 to threads-1);
signal lsu_xu_spr_xucr0_cslc_xuop               :std_ulogic;
signal lsu_xu_spr_xucr0_cslc_binv               :std_ulogic;
signal lsu_xu_spr_xucr0_clo                     :std_ulogic;
signal lsu_xu_spr_xucr0_cul                     :std_ulogic;
signal lsu_xu_spr_epsc_epr                      :std_ulogic_vector(0 to 3);
signal lsu_xu_spr_epsc_egs                      :std_ulogic_vector(0 to 3);
signal xu_lsu_spr_xucr0_aflsta                  :std_ulogic;
signal xu_lsu_spr_xucr0_flsta                   :std_ulogic;
signal xu_lsu_spr_xucr0_l2siw                   :std_ulogic;
signal xu_lsu_spr_xucr0_dcdis_int               :std_ulogic;
signal xu_lsu_spr_xucr0_wlk                     :std_ulogic;
signal xu_lsu_spr_xucr0_clfc                    :std_ulogic;
signal xu_lsu_spr_xucr0_flh2l2                  :std_ulogic;
signal xu_lsu_spr_xucr0_cred                    :std_ulogic;
signal xu_lsu_spr_xucr0_rel_int                 :std_ulogic;
signal xu_lsu_spr_xucr0_mbar_ack                :std_ulogic;
signal xu_lsu_spr_xucr0_tlbsync                 :std_ulogic;
signal xu_lsu_spr_xucr0_cls                     :std_ulogic;
signal xu_lsu_spr_ccr2_dfrat                    :std_ulogic;
signal xu_lsu_spr_ccr2_dfratsc                  :std_ulogic_vector(0 to 8);
signal ctrl_bcfg_scan_in                        :std_ulogic;
signal ctrl_ccfg_scan_in                        :std_ulogic;
signal ctrl_dcfg_scan_in                        :std_ulogic;
signal ctrl_time_scan_in                        :std_ulogic;
signal ctrl_repr_scan_in                        :std_ulogic;
signal ctrl_gptr_scan_in                        :std_ulogic;
signal ctrl_bcfg_scan_out                       :std_ulogic;
signal ctrl_ccfg_scan_out                       :std_ulogic;
signal ctrl_dcfg_scan_out                       :std_ulogic;
signal ctrl_time_scan_out                       :std_ulogic;
signal ctrl_repr_scan_out                       :std_ulogic;
signal ctrl_gptr_scan_out                       :std_ulogic;
signal spr_bcfg_scan_in                         :std_ulogic;
signal spr_ccfg_scan_in                         :std_ulogic;
signal spr_dcfg_scan_in                         :std_ulogic;
signal spr_time_scan_in                         :std_ulogic;
signal spr_repr_scan_in                         :std_ulogic;
signal spr_gptr_scan_in                         :std_ulogic;
signal spr_bcfg_scan_out                        :std_ulogic;
signal spr_ccfg_scan_out                        :std_ulogic;
signal spr_dcfg_scan_out                        :std_ulogic;
signal spr_time_scan_out                        :std_ulogic;
signal spr_repr_scan_out                        :std_ulogic;
signal spr_gptr_scan_out                        :std_ulogic;
signal xu_s_rf1_flush_int                       :std_ulogic_vector(0 to threads-1);
signal xu_s_ex1_flush_int                       :std_ulogic_vector(0 to threads-1);
signal xu_s_ex2_flush_int                       :std_ulogic_vector(0 to threads-1);
signal xu_s_ex3_flush_int                       :std_ulogic_vector(0 to threads-1);
signal xu_s_ex4_flush_int                       :std_ulogic_vector(0 to threads-1);
signal xu_s_ex5_flush_int                       :std_ulogic_vector(0 to threads-1);
signal spr_ccr0_we                              :std_ulogic_vector(0 to threads-1);
signal spr_xucr0_clkg_ctl                       :std_ulogic_vector(0 to 3);
signal spr_debug_data_in                        :std_ulogic_vector(0 to 87);
signal spr_debug_data_out                       :std_ulogic_vector(0 to 87);
signal spr_trigger_data_in                      :std_ulogic_vector(0 to 11);
signal spr_trigger_data_out                     :std_ulogic_vector(0 to 11);
signal ctrl_debug_data_in                       :std_ulogic_vector(0 to 87);
signal ctrl_debug_data_out                      :std_ulogic_vector(0 to 87);
signal ctrl_trigger_data_in                     :std_ulogic_vector(0 to 11);
signal ctrl_trigger_data_out                    :std_ulogic_vector(0 to 11);
signal lsu_xu_cmd_debug                         :std_ulogic_vector(0 to 175);

begin

ctrl_trigger_data_in    <= trigger_data_in;
ctrl_debug_data_in      <= debug_data_in;
spr_debug_data_in       <= ctrl_debug_data_out;
spr_trigger_data_in     <= ctrl_trigger_data_out;
debug_data_out          <= spr_debug_data_out;
trigger_data_out        <= spr_trigger_data_out;

ctrl_bcfg_scan_in  <= bcfg_scan_in;
ctrl_ccfg_scan_in  <= ccfg_scan_in;
ctrl_dcfg_scan_in  <= dcfg_scan_in;
ctrl_time_scan_in  <= time_scan_in;
ctrl_repr_scan_in  <= repr_scan_in;
ctrl_gptr_scan_in  <= gptr_scan_in;

spr_bcfg_scan_in  <= ctrl_bcfg_scan_out;
spr_ccfg_scan_in  <= ctrl_ccfg_scan_out;
spr_dcfg_scan_in  <= ctrl_dcfg_scan_out;
spr_time_scan_in  <= ctrl_time_scan_out;
spr_repr_scan_in  <= ctrl_repr_scan_out;
spr_gptr_scan_in  <= ctrl_gptr_scan_out;

bcfg_scan_out     <= spr_bcfg_scan_out;
ccfg_scan_out     <= spr_ccfg_scan_out;
dcfg_scan_out     <= spr_dcfg_scan_out;
time_scan_out     <= spr_time_scan_out;
repr_scan_out     <= spr_repr_scan_out;
gptr_scan_out     <= spr_gptr_scan_out;


xu_lsu_slowspr_done <= '0';

xu_s_rf1_flush    <= xu_s_rf1_flush_int;   
xu_s_ex1_flush    <= xu_s_ex1_flush_int;   
xu_s_ex2_flush    <= xu_s_ex2_flush_int;   
xu_s_ex3_flush    <= xu_s_ex3_flush_int;   
xu_s_ex4_flush    <= xu_s_ex4_flush_int;   
xu_s_ex5_flush    <= xu_s_ex5_flush_int;   

xu_mm_spr_epcr_dgtmi <= spr_dec_rf1_epcr_dgtmi;

xu_pc_spr_ccr0_we <= spr_ccr0_we;

bolt_sl_thold_2 <= bolt_sl_thold_2_b;
bo_enable_2 <= bo_enable_2_b;
clkoff_dc_b <= clkoff_dc_b_b;
d_mode_dc <= d_mode_dc_b;
delay_lclkr_dc <= delay_lclkr_dc_b;
mpw1_dc_b <= mpw1_dc_b_b;
mpw2_dc_b <= mpw2_dc_b_b;
sg_2 <= sg_2_b;
fce_2 <= fce_2_b;
func_sl_thold_2 <= func_sl_thold_2_b;
func_slp_sl_thold_2 <= func_slp_sl_thold_2_b;
func_slp_nsl_thold_2 <= func_slp_nsl_thold_2_b;
func_nsl_thold_2 <= func_nsl_thold_2_b;
abst_sl_thold_2 <= abst_sl_thold_2_b;
time_sl_thold_2 <= time_sl_thold_2_b;
gptr_sl_thold_2 <= gptr_sl_thold_2_b;
ary_nsl_thold_2 <= ary_nsl_thold_2_b;
repr_sl_thold_2 <= repr_sl_thold_2_b;
cfg_sl_thold_2 <= cfg_sl_thold_2_b;
cfg_slp_sl_thold_2 <= cfg_slp_sl_thold_2_b;


ctrl : entity work.xuq_ctrl(xuq_ctrl)
generic map(
        expand_type             => expand_type,
        threads                 => threads,
        eff_ifar                => eff_ifar,
        uc_ifar                 => uc_ifar,
        regsize                 => regsize,
        hvmode                  => hvmode,
        regmode                 => regmode,
        dc_size                 => dc_size,
        cl_size                 => cl_size,
        real_data_add           => real_data_add,
        fxu_synth               => fxu_synth,
        a2mode                  => a2mode,
        lmq_entries             => lmq_entries,
        l_endian_m              => l_endian_m,
        load_credits            => load_credits,
        store_credits           => store_credits,
        st_data_32B_mode        => st_data_32B_mode,
        bcfg_epn_0to15          => bcfg_epn_0to15,
        bcfg_epn_16to31         => bcfg_epn_16to31,
        bcfg_epn_32to47         => bcfg_epn_32to47,
        bcfg_epn_48to51         => bcfg_epn_48to51,
        bcfg_rpn_22to31         => bcfg_rpn_22to31,
        bcfg_rpn_32to47         => bcfg_rpn_32to47,
        bcfg_rpn_48to51         => bcfg_rpn_48to51)
port map(

        an_ac_grffence_en_dc                    => an_ac_grffence_en_dc,
        an_ac_scan_dis_dc_b                     => an_ac_scan_dis_dc_b,
        an_ac_lbist_en_dc                       => an_ac_lbist_en_dc,
        pc_xu_abist_raddr_0                     => pc_xu_abist_raddr_0(5 to 9),
        pc_xu_abist_ena_dc                      => pc_xu_abist_ena_dc,
        pc_xu_abist_waddr_0                     => pc_xu_abist_waddr_0(5 to 9),
        pc_xu_abist_di_0                        => pc_xu_abist_di_0,
        pc_xu_abist_raw_dc_b                    => pc_xu_abist_raw_dc_b,
        pc_xu_ccflush_dc                        => pc_xu_ccflush_dc,
        clkoff_dc_b                             => clkoff_dc_b_b,
        d_mode_dc                               => d_mode_dc_b,
        delay_lclkr_dc                          => delay_lclkr_dc_b,
        mpw1_dc_b                               => mpw1_dc_b_b,
        mpw2_dc_b                               => mpw2_dc_b_b,
        g6t_clkoff_dc_b                         => g6t_clkoff_dc_b,
        g6t_d_mode_dc                           => g6t_d_mode_dc,
        g6t_delay_lclkr_dc                      => g6t_delay_lclkr_dc,
        g6t_mpw1_dc_b                           => g6t_mpw1_dc_b,
        g6t_mpw2_dc_b                           => g6t_mpw2_dc_b,
        pc_xu_sg_3                              => pc_xu_sg_3,
        pc_xu_func_sl_thold_3                   => pc_xu_func_sl_thold_3,
        pc_xu_func_slp_sl_thold_3               => pc_xu_func_slp_sl_thold_3,
        pc_xu_func_nsl_thold_3                  => pc_xu_func_nsl_thold_3,
        pc_xu_func_slp_nsl_thold_3              => pc_xu_func_slp_nsl_thold_3,
        pc_xu_gptr_sl_thold_3                   => pc_xu_gptr_sl_thold_3,
        pc_xu_abst_sl_thold_3                   => pc_xu_abst_sl_thold_3,
        pc_xu_abst_slp_sl_thold_3               => pc_xu_abst_slp_sl_thold_3,
        pc_xu_regf_sl_thold_3                   => pc_xu_regf_sl_thold_3,
        pc_xu_regf_slp_sl_thold_3               => pc_xu_regf_slp_sl_thold_3,
        pc_xu_time_sl_thold_3                   => pc_xu_time_sl_thold_3,
        pc_xu_cfg_sl_thold_3                    => pc_xu_cfg_sl_thold_3,
        pc_xu_cfg_slp_sl_thold_3                => pc_xu_cfg_slp_sl_thold_3,
        pc_xu_ary_nsl_thold_3                   => pc_xu_ary_nsl_thold_3,
        pc_xu_ary_slp_nsl_thold_3               => pc_xu_ary_slp_nsl_thold_3,
        pc_xu_repr_sl_thold_3                   => pc_xu_repr_sl_thold_3,
        pc_xu_fce_3                             => pc_xu_fce_3,
        an_ac_scan_diag_dc                      => an_ac_scan_diag_dc,
        sg_2                                    => sg_2_b,
        fce_2                                   => fce_2_b,
        func_sl_thold_2                         => func_sl_thold_2_b,
        func_slp_sl_thold_2                     => func_slp_sl_thold_2_b,
        func_slp_nsl_thold_2                    => func_slp_nsl_thold_2_b,
        func_nsl_thold_2                        => func_nsl_thold_2_b,
        abst_sl_thold_2                         => abst_sl_thold_2_b,
        time_sl_thold_2                         => time_sl_thold_2_b,
        gptr_sl_thold_2                         => gptr_sl_thold_2_b,
        ary_nsl_thold_2                         => ary_nsl_thold_2_b,
        repr_sl_thold_2                         => repr_sl_thold_2_b,
        bolt_sl_thold_2                         => bolt_sl_thold_2_b,
        bo_enable_2                             => bo_enable_2_b,
        cfg_sl_thold_2                          => cfg_sl_thold_2_b,
        cfg_slp_sl_thold_2                      => cfg_slp_sl_thold_2_b,
        regf_slp_sl_thold_2                     => regf_slp_sl_thold_2,
        pc_xu_bolt_sl_thold_3                   => pc_xu_bolt_sl_thold_3,
        pc_xu_bo_enable_3                       => pc_xu_bo_enable_3,

        fxa_fxb_rf0_val                         => fxa_fxb_rf0_val,
        fxa_fxb_rf0_issued                      => fxa_fxb_rf0_issued,
        fxa_fxb_rf0_ucode_val                   => fxa_fxb_rf0_ucode_val,
        fxa_fxb_rf0_act                         => fxa_fxb_rf0_act,
        fxa_fxb_ex1_hold_ctr_flush              => fxa_fxb_ex1_hold_ctr_flush,
        fxa_fxb_rf0_instr                       => fxa_fxb_rf0_instr,
        fxa_fxb_rf0_tid                         => fxa_fxb_rf0_tid,
        fxa_fxb_rf0_ta_vld                      => fxa_fxb_rf0_ta_vld,
        fxa_fxb_rf0_ta                          => fxa_fxb_rf0_ta,
        fxa_fxb_rf0_error                       => fxa_fxb_rf0_error,
        fxa_fxb_rf0_match                       => fxa_fxb_rf0_match,
        fxa_fxb_rf0_is_ucode                    => fxa_fxb_rf0_is_ucode,
        fxa_fxb_rf0_gshare                      => fxa_fxb_rf0_gshare,
        fxa_fxb_rf0_ifar                        => fxa_fxb_rf0_ifar,
        fxa_fxb_rf0_s1_vld                      => fxa_fxb_rf0_s1_vld,
        fxa_fxb_rf0_s1                          => fxa_fxb_rf0_s1,
        fxa_fxb_rf0_s2_vld                      => fxa_fxb_rf0_s2_vld,
        fxa_fxb_rf0_s2                          => fxa_fxb_rf0_s2,
        fxa_fxb_rf0_s3_vld                      => fxa_fxb_rf0_s3_vld,
        fxa_fxb_rf0_s3                          => fxa_fxb_rf0_s3,
        fxa_fxb_rf0_axu_instr_type              => fxa_fxb_rf0_axu_instr_type,
        fxa_fxb_rf0_axu_ld_or_st                => fxa_fxb_rf0_axu_ld_or_st,
        fxa_fxb_rf0_axu_store                   => fxa_fxb_rf0_axu_store,
        fxa_fxb_rf0_axu_ldst_forcealign         => fxa_fxb_rf0_axu_ldst_forcealign,
        fxa_fxb_rf0_axu_ldst_forceexcept        => fxa_fxb_rf0_axu_ldst_forceexcept,
        fxa_fxb_rf0_axu_ldst_indexed            => fxa_fxb_rf0_axu_ldst_indexed,
        fxa_fxb_rf0_axu_ldst_tag                => fxa_fxb_rf0_axu_ldst_tag,
        fxa_fxb_rf0_axu_mftgpr                  => fxa_fxb_rf0_axu_mftgpr,
        fxa_fxb_rf0_axu_mffgpr                  => fxa_fxb_rf0_axu_mffgpr,
        fxa_fxb_rf0_axu_movedp                  => fxa_fxb_rf0_axu_movedp,
        fxa_fxb_rf0_axu_ldst_size               => fxa_fxb_rf0_axu_ldst_size,
        fxa_fxb_rf0_axu_ldst_update             => fxa_fxb_rf0_axu_ldst_update,
        fxa_fxb_rf0_pred_update                 => fxa_fxb_rf0_pred_update,
        fxa_fxb_rf0_pred_taken_cnt              => fxa_fxb_rf0_pred_taken_cnt,
        fxa_fxb_rf0_mc_dep_chk_val              => fxa_fxb_rf0_mc_dep_chk_val,
        fxa_fxb_rf1_mul_val                     => fxa_fxb_rf1_mul_val,
        fxa_fxb_rf1_div_val                     => fxa_fxb_rf1_div_val,
        fxa_fxb_rf1_div_ctr                     => fxa_fxb_rf1_div_ctr,
        fxa_fxb_rf0_xu_epid_instr               => fxa_fxb_rf0_xu_epid_instr,
        fxa_fxb_rf0_axu_is_extload              => fxa_fxb_rf0_axu_is_extload,
        fxa_fxb_rf0_axu_is_extstore             => fxa_fxb_rf0_axu_is_extstore,
        fxa_fxb_rf0_is_mfocrf                   => fxa_fxb_rf0_is_mfocrf,
        fxa_fxb_rf0_3src_instr                  => fxa_fxb_rf0_3src_instr,
        fxa_fxb_rf0_gpr0_zero                   => fxa_fxb_rf0_gpr0_zero,
        fxa_fxb_rf0_use_imm                     => fxa_fxb_rf0_use_imm,
        fxa_fxb_rf1_muldiv_coll                 => fxa_fxb_rf1_muldiv_coll,
        fxa_cpl_ex2_div_coll                    => fxa_cpl_ex2_div_coll,
        fxb_fxa_ex7_we0                         => fxb_fxa_ex7_we0,
        fxb_fxa_ex7_wa0                         => fxb_fxa_ex7_wa0,
        fxb_fxa_ex7_wd0                         => fxb_fxa_ex7_wd0,
        fxa_fxb_rf1_do0                         => fxa_fxb_rf1_do0,
        fxa_fxb_rf1_do1                         => fxa_fxb_rf1_do1,
        fxa_fxb_rf1_do2                         => fxa_fxb_rf1_do2,

        xu_bx_ex1_mtdp_val                      => xu_bx_ex1_mtdp_val,
        xu_bx_ex1_mfdp_val                      => xu_bx_ex1_mfdp_val,
        xu_bx_ex1_ipc_thrd                      => xu_bx_ex1_ipc_thrd,
        xu_bx_ex2_ipc_ba                        => xu_bx_ex2_ipc_ba,
        xu_bx_ex2_ipc_sz                        => xu_bx_ex2_ipc_sz,

        xu_mm_derat_epn                         => xu_mm_derat_epn,

        xu_mm_rf1_is_tlbsxr                     => xu_mm_rf1_is_tlbsxr,
        mm_xu_cr0_eq_valid                      => mm_xu_cr0_eq_valid,
        mm_xu_cr0_eq                            => mm_xu_cr0_eq,

        fu_xu_ex4_cr_val                        => fu_xu_ex4_cr_val,
        fu_xu_ex4_cr_noflush                    => fu_xu_ex4_cr_noflush,
        fu_xu_ex4_cr0                           => fu_xu_ex4_cr0,
        fu_xu_ex4_cr0_bf                        => fu_xu_ex4_cr0_bf,
        fu_xu_ex4_cr1                           => fu_xu_ex4_cr1,
        fu_xu_ex4_cr1_bf                        => fu_xu_ex4_cr1_bf,
        fu_xu_ex4_cr2                           => fu_xu_ex4_cr2,
        fu_xu_ex4_cr2_bf                        => fu_xu_ex4_cr2_bf,
        fu_xu_ex4_cr3                           => fu_xu_ex4_cr3,
        fu_xu_ex4_cr3_bf                        => fu_xu_ex4_cr3_bf,

        pc_xu_ram_mode                          => pc_xu_ram_mode,
        pc_xu_ram_thread                        => pc_xu_ram_thread,
        pc_xu_ram_execute                       => pc_xu_ram_execute,
        pc_xu_ram_flush_thread                  => pc_xu_ram_flush_thread,
        xu_iu_ram_issue                         => xu_iu_ram_issue,
        xu_pc_ram_interrupt                     => xu_pc_ram_interrupt,
        xu_pc_ram_done                          => xu_pc_ram_done,
        xu_pc_ram_data                          => xu_pc_ram_data,

        xu_iu_ex5_val                           => xu_iu_ex5_val,
        xu_iu_ex5_tid                           => xu_iu_ex5_tid,
        xu_iu_ex5_br_update                     => xu_iu_ex5_br_update,
        xu_iu_ex5_br_hist                       => xu_iu_ex5_br_hist,
        xu_iu_ex5_bclr                          => xu_iu_ex5_bclr,
        xu_iu_ex5_lk                            => xu_iu_ex5_lk,
        xu_iu_ex5_bh                            => xu_iu_ex5_bh,
        xu_iu_ex6_pri                           => xu_iu_ex6_pri,
        xu_iu_ex6_pri_val                       => xu_iu_ex6_pri_val,
        xu_iu_spr_xer                           => xu_iu_spr_xer,
        xu_iu_slowspr_done                      => xu_iu_slowspr_done,
        xu_iu_need_hole                         => xu_iu_need_hole,
        fxb_fxa_ex6_clear_barrier               => fxb_fxa_ex6_clear_barrier,
        xu_iu_ex5_gshare                        => xu_iu_ex5_gshare,
        xu_iu_ex5_getNIA                        => xu_iu_ex5_getNIA,

        an_ac_stcx_complete                     => an_ac_stcx_complete,
        an_ac_stcx_pass                         => an_ac_stcx_pass,
        xu_iu_stcx_complete                     => xu_iu_stcx_complete,                   
        xu_iu_reld_core_tag_clone    => xu_iu_reld_core_tag_clone,
        xu_iu_reld_data_coming_clone => xu_iu_reld_data_coming_clone,
        xu_iu_reld_data_vld_clone    => xu_iu_reld_data_vld_clone,
        xu_iu_reld_ditc_clone        => xu_iu_reld_ditc_clone,

        slowspr_val_in                          => slowspr_val_in,
        slowspr_rw_in                           => slowspr_rw_in,
        slowspr_etid_in                         => slowspr_etid_in,
        slowspr_addr_in                         => slowspr_addr_in,
        slowspr_data_in                         => slowspr_data_in,
        slowspr_done_in                         => slowspr_done_in,

        an_ac_dcr_act                           => an_ac_dcr_act,
        an_ac_dcr_val                           => an_ac_dcr_val,
        an_ac_dcr_read                          => an_ac_dcr_read,
        an_ac_dcr_etid                          => an_ac_dcr_etid,
        an_ac_dcr_data                          => an_ac_dcr_data,
        an_ac_dcr_done                          => an_ac_dcr_done,
        
        lsu_xu_ex4_mtdp_cr_status               => lsu_xu_ex4_mtdp_cr_status,
        lsu_xu_ex4_mfdp_cr_status               => lsu_xu_ex4_mfdp_cr_status,
        dec_cpl_ex3_mc_dep_chk_val              => dec_cpl_ex3_mc_dep_chk_val,

        dec_spr_ex4_val                         => dec_spr_ex4_val,
        dec_spr_ex1_epid_instr                  => dec_spr_ex1_epid_instr,
        mux_spr_ex2_rt                          => mux_spr_ex2_rt,
        fxu_spr_ex1_rs0                         => fxu_spr_ex1_rs0,
        fxu_spr_ex1_rs1                         => fxu_spr_ex1_rs1,
        spr_msr_cm                              => spr_msr_cm_int,
        spr_dec_spr_xucr0_ssdly                 => spr_dec_spr_xucr0_ssdly,
        spr_ccr2_en_attn                        => spr_ccr2_en_attn,
        spr_ccr2_en_ditc                        => spr_ccr2_en_ditc_int,
        spr_ccr2_en_pc                          => spr_ccr2_en_pc,
        spr_ccr2_en_icswx                       => spr_ccr2_en_icswx,
        spr_ccr2_en_dcr                         => spr_ccr2_en_dcr_int,
        spr_dec_rf1_epcr_dgtmi                  => spr_dec_rf1_epcr_dgtmi,
        spr_byp_ex4_is_mfxer                    => spr_byp_ex4_is_mfxer,
        spr_byp_ex3_spr_rt                      => spr_byp_ex3_spr_rt,
        spr_byp_ex4_is_mtxer                    => spr_byp_ex4_is_mtxer,
        spr_ccr2_notlb                          => spr_ccr2_notlb_int,
        dec_spr_rf1_val                         => dec_spr_rf1_val,
        fxu_spr_ex1_rs2                         => fxu_spr_ex1_rs2,

        fxa_perf_muldiv_in_use                  => fxa_perf_muldiv_in_use,
        spr_perf_tx_events                      => spr_perf_tx_events,
        xu_pc_event_data                        => xu_pc_event_data,

        pc_xu_event_count_mode                  => pc_xu_event_count_mode,
        pc_xu_event_mux_ctrls                   => pc_xu_event_mux_ctrls,

        fxu_debug_mux_ctrls                     => fxu_debug_mux_ctrls,
        cpl_debug_mux_ctrls                     => cpl_debug_mux_ctrls,
        lsu_debug_mux_ctrls                     => lsu_debug_mux_ctrls,
        ctrl_trigger_data_in                    => ctrl_trigger_data_in,
        ctrl_trigger_data_out                   => ctrl_trigger_data_out,
        ctrl_debug_data_in                      => ctrl_debug_data_in,
        ctrl_debug_data_out                     => ctrl_debug_data_out,
        lsu_xu_data_debug0                      => lsu_xu_data_debug0,
        lsu_xu_data_debug1                      => lsu_xu_data_debug1,
        lsu_xu_data_debug2                      => lsu_xu_data_debug2,
        fxa_cpl_debug                           => fxa_cpl_debug,

        spr_msr_gs                              => spr_msr_gs_int,
        spr_msr_ds                              => spr_msr_ds_int,
        spr_msr_pr                              => spr_msr_pr_int,
        spr_dbcr0_dac1                          => spr_dbcr0_dac1,
        spr_dbcr0_dac2                          => spr_dbcr0_dac2,
        spr_dbcr0_dac3                          => spr_dbcr0_dac3,
        spr_dbcr0_dac4                          => spr_dbcr0_dac4,

        ac_tc_debug_trigger                     => ac_tc_debug_trigger,

        dec_cpl_rf0_act                         => dec_cpl_rf0_act,
        dec_cpl_rf0_tid                         => dec_cpl_rf0_tid,

        fu_xu_rf1_act                           => fu_xu_rf1_act,
        fu_xu_ex1_ifar                          => fu_xu_ex1_ifar,
        fu_xu_ex2_ifar_val                      => fu_xu_ex2_ifar_val,
        fu_xu_ex2_ifar_issued                   => fu_xu_ex2_ifar_issued,
        fu_xu_ex2_instr_type                    => fu_xu_ex2_instr_type,
        fu_xu_ex2_instr_match                   => fu_xu_ex2_instr_match,
        fu_xu_ex2_is_ucode                      => fu_xu_ex2_is_ucode,

        pc_xu_stop                              => pc_xu_stop,
        pc_xu_step                              => pc_xu_step,
        pc_xu_dbg_action                        => pc_xu_dbg_action,
        pc_xu_force_ude                         => pc_xu_force_ude,
        xu_pc_step_done                         => xu_pc_step_done,
        pc_xu_init_reset                        => pc_xu_init_reset,

        spr_cpl_external_mchk                   => spr_cpl_external_mchk,
        spr_cpl_ext_interrupt                   => spr_cpl_ext_interrupt,
        spr_cpl_udec_interrupt                  => spr_cpl_udec_interrupt,
        spr_cpl_perf_interrupt                  => spr_cpl_perf_interrupt,
        spr_cpl_dec_interrupt                   => spr_cpl_dec_interrupt,
        spr_cpl_fit_interrupt                   => spr_cpl_fit_interrupt,
        spr_cpl_crit_interrupt                  => spr_cpl_crit_interrupt,
        spr_cpl_wdog_interrupt                  => spr_cpl_wdog_interrupt,
        spr_cpl_dbell_interrupt                 => spr_cpl_dbell_interrupt,
        spr_cpl_cdbell_interrupt                => spr_cpl_cdbell_interrupt,
        spr_cpl_gdbell_interrupt                => spr_cpl_gdbell_interrupt,
        spr_cpl_gcdbell_interrupt               => spr_cpl_gcdbell_interrupt,
        spr_cpl_gmcdbell_interrupt              => spr_cpl_gmcdbell_interrupt,
        cpl_spr_ex5_dbell_taken                 => cpl_spr_ex5_dbell_taken,
        cpl_spr_ex5_cdbell_taken                => cpl_spr_ex5_cdbell_taken,
        cpl_spr_ex5_gdbell_taken                => cpl_spr_ex5_gdbell_taken,
        cpl_spr_ex5_gcdbell_taken               => cpl_spr_ex5_gcdbell_taken,
        cpl_spr_ex5_gmcdbell_taken              => cpl_spr_ex5_gmcdbell_taken,

        cpl_spr_ex5_act                         => cpl_spr_ex5_act,
        cpl_spr_ex5_int                         => cpl_spr_ex5_int,
        cpl_spr_ex5_gint                        => cpl_spr_ex5_gint,
        cpl_spr_ex5_cint                        => cpl_spr_ex5_cint,
        cpl_spr_ex5_mcint                       => cpl_spr_ex5_mcint,
        cpl_spr_ex5_nia                         => cpl_spr_ex5_nia,
        cpl_spr_ex5_esr                         => cpl_spr_ex5_esr,
        cpl_spr_ex5_mcsr                        => cpl_spr_ex5_mcsr,
        cpl_spr_ex5_dbsr                        => cpl_spr_ex5_dbsr,
        cpl_spr_ex5_dear_save                   => cpl_spr_ex5_dear_save,
        cpl_spr_ex5_dear_update_saved           => cpl_spr_ex5_dear_update_saved,
        cpl_spr_ex5_dear_update                 => cpl_spr_ex5_dear_update,
        cpl_spr_ex5_dbsr_update                 => cpl_spr_ex5_dbsr_update,
        cpl_spr_ex5_esr_update                  => cpl_spr_ex5_esr_update,
        cpl_spr_ex5_srr0_dec                    => cpl_spr_ex5_srr0_dec,
        cpl_spr_ex5_force_gsrr                  => cpl_spr_ex5_force_gsrr,
        cpl_spr_ex5_dbsr_ide                    => cpl_spr_ex5_dbsr_ide,
        spr_cpl_dbsr_ide                        => spr_cpl_dbsr_ide,

        mm_xu_local_snoop_reject                => mm_xu_local_snoop_reject,
        mm_xu_lru_par_err                       => mm_xu_lru_par_err,
        mm_xu_tlb_par_err                       => mm_xu_tlb_par_err,
        mm_xu_tlb_multihit_err                  => mm_xu_tlb_multihit_err,

        xu_pc_err_attention_instr               => xu_pc_err_attention_instr,
        xu_pc_err_nia_miscmpr                   => xu_pc_err_nia_miscmpr,
        xu_pc_err_debug_event                   => xu_pc_err_debug_event,

        spr_cpl_ex3_ct_le                       => spr_cpl_ex3_ct_le,
        spr_cpl_ex3_ct_be                       => spr_cpl_ex3_ct_be,

        spr_cpl_ex3_spr_illeg                   => spr_cpl_ex3_spr_illeg,
        spr_cpl_ex3_spr_priv                    => spr_cpl_ex3_spr_priv,

        spr_cpl_ex3_spr_hypv                    => spr_cpl_ex3_spr_hypv,

        cpl_spr_stop                            => cpl_spr_stop,
        cpl_spr_ex5_instr_cpl                   => cpl_spr_ex5_instr_cpl,
        spr_cpl_quiesce                         => spr_cpl_quiesce,
        cpl_spr_quiesce                         => cpl_spr_quiesce,
        spr_cpl_ex2_run_ctl_flush               => spr_cpl_ex2_run_ctl_flush,
        xu_pc_stop_dbg_event                    => xu_pc_stop_dbg_event,

        mm_xu_illeg_instr                       => mm_xu_illeg_instr,
        mm_xu_tlb_miss                          => mm_xu_tlb_miss,
        mm_xu_pt_fault                          => mm_xu_pt_fault,
        mm_xu_tlb_inelig                        => mm_xu_tlb_inelig,
        mm_xu_lrat_miss                         => mm_xu_lrat_miss,
        mm_xu_hv_priv                           => mm_xu_hv_priv,
        mm_xu_esr_pt                            => mm_xu_esr_pt,
        mm_xu_esr_data                          => mm_xu_esr_data,
        mm_xu_esr_epid                          => mm_xu_esr_epid,
        mm_xu_esr_st                            => mm_xu_esr_st,
        mm_xu_hold_req                          => mm_xu_hold_req,
        mm_xu_hold_done                         => mm_xu_hold_done,
        xu_mm_hold_ack                          => xu_mm_hold_ack,
        mm_xu_eratmiss_done                     => mm_xu_eratmiss_done,
        mm_xu_ex3_flush_req                     => mm_xu_ex3_flush_req,

        fu_xu_ex3_ap_int_req                    => fu_xu_ex3_ap_int_req,
        fu_xu_ex3_trap                          => fu_xu_ex3_trap,
        fu_xu_ex3_n_flush                       => fu_xu_ex3_n_flush,
        fu_xu_ex3_np1_flush                     => fu_xu_ex3_np1_flush,
        fu_xu_ex3_flush2ucode                   => fu_xu_ex3_flush2ucode,
        fu_xu_ex2_async_block                   => fu_xu_ex2_async_block,

        xu_iu_ex5_br_taken                      => xu_iu_ex5_br_taken,
        xu_iu_ex5_ifar                          => xu_iu_ex5_ifar,
        xu_iu_flush                             => xu_iu_flush,
        xu_iu_iu0_flush_ifar                    => xu_iu_iu0_flush_ifar,
        xu_iu_uc_flush_ifar                     => xu_iu_uc_flush_ifar,
        xu_iu_flush_2ucode                      => xu_iu_flush_2ucode,
        xu_iu_flush_2ucode_type                 => xu_iu_flush_2ucode_type,
        xu_iu_ucode_restart                     => xu_iu_ucode_restart,
        xu_iu_ex5_ppc_cpl                       => xu_iu_ex5_ppc_cpl,

        xu_n_is2_flush                          => xu_n_is2_flush,
        xu_n_rf0_flush                          => xu_n_rf0_flush,
        xu_n_rf1_flush                          => xu_n_rf1_flush,
        xu_n_ex1_flush                          => xu_n_ex1_flush,
        xu_n_ex2_flush                          => xu_n_ex2_flush,
        xu_n_ex3_flush                          => xu_n_ex3_flush,
        xu_n_ex4_flush                          => xu_n_ex4_flush,
        xu_n_ex5_flush                          => xu_n_ex5_flush,
        xu_s_rf1_flush                          => xu_s_rf1_flush_int,
        xu_s_ex1_flush                          => xu_s_ex1_flush_int,
        xu_s_ex2_flush                          => xu_s_ex2_flush_int,
        xu_s_ex3_flush                          => xu_s_ex3_flush_int,
        xu_s_ex4_flush                          => xu_s_ex4_flush_int,
        xu_s_ex5_flush                          => xu_s_ex5_flush_int,
        xu_w_rf1_flush                          => xu_w_rf1_flush,
        xu_w_ex1_flush                          => xu_w_ex1_flush,
        xu_w_ex2_flush                          => xu_w_ex2_flush,
        xu_w_ex3_flush                          => xu_w_ex3_flush,
        xu_w_ex4_flush                          => xu_w_ex4_flush,
        xu_w_ex5_flush                          => xu_w_ex5_flush,
        xu_lsu_ex4_flush_local                  => xu_lsu_ex4_flush_local,
        xu_mm_ex4_flush                         => xu_mm_ex4_flush,
        xu_mm_ex5_flush                         => xu_mm_ex5_flush,
        xu_mm_ierat_flush                       => xu_mm_ierat_flush,
        xu_mm_ierat_miss                        => xu_mm_ierat_miss,
        xu_mm_ex5_perf_itlb                     => xu_mm_ex5_perf_itlb,
        xu_mm_ex5_perf_dtlb                     => xu_mm_ex5_perf_dtlb,

        spr_bit_act                             => spr_bit_act,
        spr_cpl_iac1_en                         => spr_cpl_iac1_en,
        spr_cpl_iac2_en                         => spr_cpl_iac2_en,
        spr_cpl_iac3_en                         => spr_cpl_iac3_en,
        spr_cpl_iac4_en                         => spr_cpl_iac4_en,
        spr_dbcr1_iac12m                        => spr_dbcr1_iac12m,
        spr_dbcr1_iac34m                        => spr_dbcr1_iac34m,
        spr_epcr_duvd                           => spr_epcr_duvd,
        spr_cpl_fp_precise                      => spr_cpl_fp_precise,
        spr_xucr0_mddp                          => spr_xucr0_mddp,
        spr_xucr0_mdcp                          => spr_xucr0_mdcp,
        spr_msr_de                              => spr_msr_de,
        spr_msr_spv                             => spr_msr_spv_int,
        spr_msr_fp                              => spr_msr_fp_int,
        spr_msr_me                              => spr_msr_me,
        spr_msr_ucle                            => spr_msr_ucle,
        spr_msrp_uclep                          => spr_msrp_uclep,
        spr_ccr2_ucode_dis                      => spr_ccr2_ucode_dis,
        spr_ccr2_ap                             => spr_ccr2_ap_int,
        spr_dbcr0_idm                           => spr_dbcr0_idm,
        cpl_spr_dbcr0_edm                       => cpl_spr_dbcr0_edm,
        spr_dbcr0_icmp                          => spr_dbcr0_icmp,
        spr_dbcr0_brt                           => spr_dbcr0_brt,
        spr_dbcr0_trap                          => spr_dbcr0_trap,
        spr_dbcr0_ret                           => spr_dbcr0_ret,
        spr_dbcr0_irpt                          => spr_dbcr0_irpt,
        spr_epcr_dsigs                          => spr_epcr_dsigs,
        spr_epcr_isigs                          => spr_epcr_isigs,
        spr_epcr_extgs                          => spr_epcr_extgs,
        spr_epcr_dtlbgs                         => spr_epcr_dtlbgs,
        spr_epcr_itlbgs                         => spr_epcr_itlbgs,
        spr_xucr4_div_barr_thres                => spr_xucr4_div_barr_thres,
        spr_ccr0_we                             => spr_ccr0_we,
        cpl_msr_gs                              => cpl_msr_gs,
        cpl_msr_pr                              => cpl_msr_pr,
        cpl_msr_fp                              => cpl_msr_fp,
        cpl_msr_spv                             => cpl_msr_spv,
        cpl_ccr2_ap                             => cpl_ccr2_ap,
        spr_xucr0_clkg_ctl                      => spr_xucr0_clkg_ctl(1 to 3),
        spr_xucr4_mmu_mchk                      => spr_xucr4_mmu_mchk,

        spr_cpl_ex3_sprg_ce                     => spr_cpl_ex3_sprg_ce,
        spr_cpl_ex3_sprg_ue                     => spr_cpl_ex3_sprg_ue,
        iu_xu_ierat_ex2_flush_req               => iu_xu_ierat_ex2_flush_req,
        iu_xu_ierat_ex3_par_err                 => iu_xu_ierat_ex3_par_err,
        iu_xu_ierat_ex4_par_err                 => iu_xu_ierat_ex4_par_err,

        fu_xu_ex3_regfile_err_det               => fu_xu_ex3_regfile_err_det,
        xu_fu_regfile_seq_beg                   => xu_fu_regfile_seq_beg,
        fu_xu_regfile_seq_end                   => fu_xu_regfile_seq_end,
        gpr_cpl_ex3_regfile_err_det             => gpr_cpl_ex3_regfile_err_det,
        cpl_gpr_regfile_seq_beg                 => cpl_gpr_regfile_seq_beg,
        gpr_cpl_regfile_seq_end                 => gpr_cpl_regfile_seq_end,
        xu_pc_err_mcsr_summary                  => xu_pc_err_mcsr_summary,
        xu_pc_err_ditc_overrun                  => xu_pc_err_ditc_overrun,
        xu_pc_err_local_snoop_reject            => xu_pc_err_local_snoop_reject,
        xu_pc_err_tlb_lru_parity                => xu_pc_err_tlb_lru_parity,
        xu_pc_err_ext_mchk                      => xu_pc_err_ext_mchk,
        xu_pc_err_ierat_multihit                => xu_pc_err_ierat_multihit,
        xu_pc_err_derat_multihit                => xu_pc_err_derat_multihit,
        xu_pc_err_tlb_multihit                  => xu_pc_err_tlb_multihit,
        xu_pc_err_ierat_parity                  => xu_pc_err_ierat_parity,
        xu_pc_err_derat_parity                  => xu_pc_err_derat_parity,
        xu_pc_err_tlb_parity                    => xu_pc_err_tlb_parity,
        xu_pc_err_mchk_disabled                 => xu_pc_err_mchk_disabled,
        xu_pc_err_sprg_ue                       => xu_pc_err_sprg_ue,

        xu_iu_rf1_val                           => xu_iu_rf1_val,
        xu_rf1_val                              => xu_rf1_val,
        xu_rf1_is_tlbre                         => xu_rf1_is_tlbre,
        xu_rf1_is_tlbwe                         => xu_rf1_is_tlbwe,
        xu_rf1_is_tlbsx                         => xu_rf1_is_tlbsx,
        xu_rf1_is_tlbsrx                        => xu_rf1_is_tlbsrx,
        xu_rf1_is_tlbilx                        => xu_rf1_is_tlbilx,
        xu_rf1_is_tlbivax                       => xu_rf1_is_tlbivax,
        xu_rf1_is_eratre                        => xu_rf1_is_eratre,
        xu_rf1_is_eratwe                        => xu_rf1_is_eratwe,
        xu_rf1_is_eratsx                        => xu_rf1_is_eratsx,
        xu_rf1_is_eratilx                       => xu_rf1_is_eratilx,
        xu_rf1_is_erativax                      => xu_rf1_is_erativax,
        xu_ex1_is_isync                         => xu_ex1_is_isync,
        xu_ex1_is_csync                         => xu_ex1_is_csync,
        xu_rf1_ws                               => xu_rf1_ws,
        xu_rf1_t                                => xu_rf1_t,
        xu_ex1_rs_is                            => xu_ex1_rs_is,
        xu_ex1_ra_entry                         => xu_ex1_ra_entry,
        xu_ex4_rs_data                          => xu_ex4_rs_data,

        xu_lsu_rf1_data_act                     => xu_lsu_rf1_data_act,
        xu_lsu_rf1_axu_ldst_falign              => xu_lsu_rf1_axu_ldst_falign,
        xu_lsu_ex1_store_data                   => xu_lsu_ex1_store_data,
        xu_lsu_ex1_rotsel_ovrd                  => xu_lsu_ex1_rotsel_ovrd,
        xu_lsu_ex1_eff_addr                     => xu_lsu_ex1_eff_addr,

        cpl_fxa_ex5_set_barr                    => cpl_fxa_ex5_set_barr,
        cpl_iu_set_barr_tid                      => cpl_iu_set_barr_tid,

        lsu_xu_ex6_datc_par_err                 => lsu_xu_ex6_datc_par_err,
                                                     
        lsu_xu_ex2_dvc1_st_cmp                  => lsu_xu_ex2_dvc1_st_cmp,
        lsu_xu_ex2_dvc2_st_cmp                  => lsu_xu_ex2_dvc2_st_cmp,
        lsu_xu_ex8_dvc1_ld_cmp                  => lsu_xu_ex8_dvc1_ld_cmp,
        lsu_xu_ex8_dvc2_ld_cmp                  => lsu_xu_ex8_dvc2_ld_cmp,
        lsu_xu_rel_dvc1_en                      => lsu_xu_rel_dvc1_en,
        lsu_xu_rel_dvc2_en                      => lsu_xu_rel_dvc2_en,
        lsu_xu_rel_dvc_thrd_id                  => lsu_xu_rel_dvc_thrd_id,
        lsu_xu_rel_dvc1_cmp                     => lsu_xu_rel_dvc1_cmp,
        lsu_xu_rel_dvc2_cmp                     => lsu_xu_rel_dvc2_cmp,

        lsu_xu_rot_ex6_data_b                   => lsu_xu_rot_ex6_data_b,
        lsu_xu_rot_rel_data                     => lsu_xu_rot_rel_data,
        pc_xu_trace_bus_enable                  => pc_xu_trace_bus_enable,
        pc_xu_instr_trace_mode                  => pc_xu_instr_trace_mode,
        pc_xu_instr_trace_tid                   => pc_xu_instr_trace_tid,
        iu_xu_ex4_tlb_data                      => iu_xu_ex4_tlb_data,

        pc_xu_inj_dcachedir_parity              => pc_xu_inj_dcachedir_parity,
        pc_xu_inj_dcachedir_multihit            => pc_xu_inj_dcachedir_multihit,

        ex4_256st_data                          => ex4_256st_data,

        xu_lsu_mtspr_trace_en                   => xu_lsu_mtspr_trace_en,
        xu_lsu_spr_xucr0_aflsta                 => xu_lsu_spr_xucr0_aflsta,
        xu_lsu_spr_xucr0_flsta                  => xu_lsu_spr_xucr0_flsta,
        xu_lsu_spr_xucr0_l2siw                  => xu_lsu_spr_xucr0_l2siw,
        xu_lsu_spr_xucr0_dcdis                  => xu_lsu_spr_xucr0_dcdis_int,
        xu_lsu_spr_xucr0_wlk                    => xu_lsu_spr_xucr0_wlk,
        xu_lsu_spr_xucr0_clfc                   => xu_lsu_spr_xucr0_clfc,
        xu_lsu_spr_xucr0_flh2l2                 => xu_lsu_spr_xucr0_flh2l2,
        xu_lsu_spr_xucr0_cred                   => xu_lsu_spr_xucr0_cred,
        xu_lsu_spr_xucr0_rel                    => xu_lsu_spr_xucr0_rel_int,
        xu_lsu_spr_xucr0_mbar_ack               => xu_lsu_spr_xucr0_mbar_ack,
        xu_lsu_spr_xucr0_tlbsync                => xu_lsu_spr_xucr0_tlbsync,
        xu_lsu_spr_xucr0_cls                    => xu_lsu_spr_xucr0_cls,
        xu_lsu_spr_ccr2_dfrat                   => xu_lsu_spr_ccr2_dfrat,
        xu_lsu_spr_ccr2_dfratsc                 => xu_lsu_spr_ccr2_dfratsc,
        
        an_ac_flh2l2_gate                       => an_ac_flh2l2_gate,
        
        xu_lsu_rf0_derat_val                    => xu_lsu_rf0_derat_val,
        xu_lsu_rf0_derat_is_extload             => xu_lsu_rf0_derat_is_extload,
        xu_lsu_rf0_derat_is_extstore            => xu_lsu_rf0_derat_is_extstore,
        
        
        xu_lsu_hid_mmu_mode                     => xu_lsu_hid_mmu_mode,
        ex6_ld_par_err                          => ex6_ld_par_err,
        
        xu_mm_derat_req                         => xu_mm_derat_req,
        xu_mm_derat_thdid                       => xu_mm_derat_thdid,
        xu_mm_derat_state                       => xu_mm_derat_state,
        xu_mm_derat_tid                         => xu_mm_derat_tid,
        xu_mm_derat_lpid                        => xu_mm_derat_lpid,
        xu_mm_derat_ttype                       => xu_mm_derat_ttype,
        mm_xu_derat_rel_val                     => mm_xu_derat_rel_val,
        mm_xu_derat_rel_data                    => mm_xu_derat_rel_data,
        mm_xu_derat_pid0                        => mm_xu_derat_pid0,
        mm_xu_derat_pid1                        => mm_xu_derat_pid1,
        mm_xu_derat_pid2                        => mm_xu_derat_pid2,
        mm_xu_derat_pid3                        => mm_xu_derat_pid3,
        mm_xu_derat_mmucr0_0                    => mm_xu_derat_mmucr0_0,
        mm_xu_derat_mmucr0_1                    => mm_xu_derat_mmucr0_1,
        mm_xu_derat_mmucr0_2                    => mm_xu_derat_mmucr0_2,
        mm_xu_derat_mmucr0_3                    => mm_xu_derat_mmucr0_3,
        xu_mm_derat_mmucr0                      => xu_mm_derat_mmucr0,
        xu_mm_derat_mmucr0_we                   => xu_mm_derat_mmucr0_we,
        mm_xu_derat_mmucr1                      => mm_xu_derat_mmucr1,
        xu_mm_derat_mmucr1                      => xu_mm_derat_mmucr1,
        xu_mm_derat_mmucr1_we                   => xu_mm_derat_mmucr1_we,
        mm_xu_derat_snoop_coming                => mm_xu_derat_snoop_coming,
        mm_xu_derat_snoop_val                   => mm_xu_derat_snoop_val,
        mm_xu_derat_snoop_attr                  => mm_xu_derat_snoop_attr,
        mm_xu_derat_snoop_vpn                   => mm_xu_derat_snoop_vpn,
        xu_mm_derat_snoop_ack                   => xu_mm_derat_snoop_ack,
        
        xu_lsu_slowspr_val                      => xu_lsu_slowspr_val,
        xu_lsu_slowspr_rw                       => xu_lsu_slowspr_rw,
        xu_lsu_slowspr_etid                     => xu_lsu_slowspr_etid,
        xu_lsu_slowspr_addr                     => xu_lsu_slowspr_addr,
        xu_lsu_slowspr_data                     => xu_lsu_slowspr_data,
        xu_lsu_slowspr_done                     => xu_lsu_slowspr_done,
        slowspr_val_out                         => slowspr_val_out,
        slowspr_rw_out                          => slowspr_rw_out,
        slowspr_etid_out                        => slowspr_etid_out,
        slowspr_addr_out                        => slowspr_addr_out,
        slowspr_data_out                        => slowspr_data_out,
        slowspr_done_out                        => slowspr_done_out,
        
        ex1_optype1                             => ex1_optype1,
        ex1_optype2                             => ex1_optype2,
        ex1_optype4                             => ex1_optype4,
        ex1_optype8                             => ex1_optype8,
        ex1_optype16                            => ex1_optype16,
        ex1_optype32                            => ex1_optype32,
        ex1_saxu_instr                          => ex1_saxu_instr,
        ex1_sdp_instr                           => ex1_sdp_instr,
        ex1_stgpr_instr                         => ex1_stgpr_instr,
        ex1_store_instr                         => ex1_store_instr,
        ex1_axu_op_val                          => ex1_axu_op_val,
        
        ex3_algebraic                           => ex3_algebraic,
        ex3_data_swap                           => ex3_data_swap,
        ex3_thrd_id                             => ex3_thrd_id,
        xu_fu_ex3_eff_addr                      => xu_fu_ex3_eff_addr,
        xu_lsu_ici                              => xu_lsu_ici,
        
        rel_upd_dcarr_val                       => rel_upd_dcarr_val,
                           
        xu_fu_ex5_reload_val                    => xu_fu_ex5_reload_val,
        xu_fu_ex5_load_val                      => xu_fu_ex5_load_val,
        xu_fu_ex5_load_tag                      => xu_fu_ex5_load_tag,
        
        dcarr_up_way_addr                       => dcarr_up_way_addr,
        
        lsu_xu_spr_xucr0_cslc_xuop              => lsu_xu_spr_xucr0_cslc_xuop,
        lsu_xu_spr_xucr0_cslc_binv              => lsu_xu_spr_xucr0_cslc_binv,
        lsu_xu_spr_xucr0_clo                    => lsu_xu_spr_xucr0_clo,
        lsu_xu_spr_xucr0_cul                    => lsu_xu_spr_xucr0_cul,
        lsu_xu_spr_epsc_epr                     => lsu_xu_spr_epsc_epr,
        lsu_xu_spr_epsc_egs                     => lsu_xu_spr_epsc_egs,
        
        ex4_load_op_hit                         => ex4_load_op_hit,
        ex4_store_hit                           => ex4_store_hit,
        ex4_axu_op_val                          => ex4_axu_op_val,
        spr_dvc1_act                            => spr_dvc1_act,
        spr_dvc2_act                            => spr_dvc2_act,
        spr_dvc1_dbg                            => spr_dvc1_dbg,
        spr_dvc2_dbg                            => spr_dvc2_dbg,
        
        an_ac_req_ld_pop                        => an_ac_req_ld_pop,
        an_ac_req_st_pop                        => an_ac_req_st_pop,
        an_ac_req_st_gather                     => an_ac_req_st_gather,
        an_ac_req_st_pop_thrd                   => an_ac_req_st_pop_thrd,
        an_ac_reld_data_vld                     => an_ac_reld_data_vld,
        an_ac_reld_core_tag                     => an_ac_reld_core_tag,
        an_ac_reld_qw                           => an_ac_reld_qw,
        an_ac_reld_data                         => an_ac_reld_data,
        an_ac_reld_data_coming                  => an_ac_reld_data_coming,
        an_ac_reld_ditc                         => an_ac_reld_ditc,
        an_ac_reld_crit_qw                      => an_ac_reld_crit_qw,
        an_ac_reld_l1_dump                      => an_ac_reld_l1_dump,
        an_ac_reld_ecc_err                      => an_ac_reld_ecc_err,
        an_ac_reld_ecc_err_ue                   => an_ac_reld_ecc_err_ue,
        an_ac_back_inv                          => an_ac_back_inv,
        an_ac_back_inv_addr                     => an_ac_back_inv_addr,
        an_ac_back_inv_target_bit1              => an_ac_back_inv_target_bit1,
        an_ac_back_inv_target_bit3              => an_ac_back_inv_target_bit3,
        an_ac_back_inv_target_bit4              => an_ac_back_inv_target_bit4,
        an_ac_req_spare_ctrl_a1                 => an_ac_req_spare_ctrl_a1,

        lsu_reld_data_vld                       => lsu_reld_data_vld,
        lsu_reld_core_tag                       => lsu_reld_core_tag,
        lsu_reld_qw                             => lsu_reld_qw,
        lsu_reld_ditc                           => lsu_reld_ditc,
        lsu_reld_ecc_err                        => lsu_reld_ecc_err,
        lsu_reld_data                           => lsu_reld_data,

        lsu_req_st_pop                          => lsu_req_st_pop,
        lsu_req_st_pop_thrd                     => lsu_req_st_pop_thrd,

        ac_an_reld_ditc_pop_int    => ac_an_reld_ditc_pop_int,
        ac_an_reld_ditc_pop_q      => ac_an_reld_ditc_pop_q  ,
        bx_ib_empty_int            => bx_ib_empty_int        ,
        bx_ib_empty_q              => bx_ib_empty_q          ,
                                                  
        iu_xu_ra                                => iu_xu_ra,
        iu_xu_request                           => iu_xu_request,
        iu_xu_wimge                             => iu_xu_wimge,
        iu_xu_thread                            => iu_xu_thread,
        iu_xu_userdef                           => iu_xu_userdef,
                                                  
        mm_xu_lsu_req                           => mm_xu_lsu_req,
        mm_xu_lsu_ttype                         => mm_xu_lsu_ttype,
        mm_xu_lsu_wimge                         => mm_xu_lsu_wimge,
        mm_xu_lsu_u                             => mm_xu_lsu_u,
        mm_xu_lsu_addr                          => mm_xu_lsu_addr,
        mm_xu_lsu_lpid                          => mm_xu_lsu_lpid,
        mm_xu_lsu_lpidr                         => mm_xu_lsu_lpidr,
        mm_xu_lsu_gs                            => mm_xu_lsu_gs,
        mm_xu_lsu_ind                           => mm_xu_lsu_ind,
        mm_xu_lsu_lbit                          => mm_xu_lsu_lbit,
        xu_mm_lsu_token                         => xu_mm_lsu_token,
                                                  
        bx_lsu_ob_pwr_tok                       => bx_lsu_ob_pwr_tok,
        bx_lsu_ob_req_val                       => bx_lsu_ob_req_val,
        bx_lsu_ob_ditc_val                      => bx_lsu_ob_ditc_val,
        bx_lsu_ob_thrd                          => bx_lsu_ob_thrd,
        bx_lsu_ob_qw                            => bx_lsu_ob_qw,
        bx_lsu_ob_dest                          => bx_lsu_ob_dest,
        bx_lsu_ob_data                          => bx_lsu_ob_data,
        bx_lsu_ob_addr                          => bx_lsu_ob_addr,
        lsu_bx_cmd_avail                        => lsu_bx_cmd_avail,
        lsu_bx_cmd_sent                         => lsu_bx_cmd_sent,
        lsu_bx_cmd_stall                        => lsu_bx_cmd_stall,

        lsu_xu_ldq_barr_done                    => lsu_xu_ldq_barr_done,
        lsu_xu_barr_done                        => lsu_xu_barr_done,
                                                  
        ldq_rel_data_val_early                  => ldq_rel_data_val_early,
        ldq_rel_op_size                         => ldq_rel_op_size,
        ldq_rel_addr                            => ldq_rel_addr,
        ldq_rel_data_val                        => ldq_rel_data_val,
        ldq_rel_rot_sel                         => ldq_rel_rot_sel,
        ldq_rel_axu_val                         => ldq_rel_axu_val,
        ldq_rel_ci                              => ldq_rel_ci,
        ldq_rel_thrd_id                         => ldq_rel_thrd_id,
        ldq_rel_le_mode                         => ldq_rel_le_mode,
        ldq_rel_algebraic                       => ldq_rel_algebraic,
        ldq_rel_256_data                        => ldq_rel_256_data,
        ldq_rel_dvc1_en                         => ldq_rel_dvc1_en,
        ldq_rel_dvc2_en                         => ldq_rel_dvc2_en,
        ldq_rel_beat_crit_qw                    => ldq_rel_beat_crit_qw,
        ldq_rel_beat_crit_qw_block              => ldq_rel_beat_crit_qw_block,
        lsu_xu_rel_wren                         => lsu_xu_rel_wren,
        lsu_xu_rel_ta_gpr                       => lsu_xu_rel_ta_gpr,

        xu_iu_ex4_loadmiss_qentry               => xu_iu_ex4_loadmiss_qentry,
        xu_iu_ex4_loadmiss_target               => xu_iu_ex4_loadmiss_target,
        xu_iu_ex4_loadmiss_target_type          => xu_iu_ex4_loadmiss_target_type,
        xu_iu_ex4_loadmiss_tid                  => xu_iu_ex4_loadmiss_tid,
        xu_iu_ex5_loadmiss_qentry               => xu_iu_ex5_loadmiss_qentry,
        xu_iu_ex5_loadmiss_target               => xu_iu_ex5_loadmiss_target,
        xu_iu_ex5_loadmiss_target_type          => xu_iu_ex5_loadmiss_target_type,
        xu_iu_ex5_loadmiss_tid                  => xu_iu_ex5_loadmiss_tid,
        xu_iu_complete_qentry                   => xu_iu_complete_qentry,
        xu_iu_complete_tid                      => xu_iu_complete_tid,
        xu_iu_complete_target_type              => xu_iu_complete_target_type,
                                                  
        xu_iu_ex6_icbi_val                      => xu_iu_ex6_icbi_val,
        xu_iu_ex6_icbi_addr                     => xu_iu_ex6_icbi_addr,

        xu_iu_larx_done_tid                     => xu_iu_larx_done_tid,
        xu_mm_lmq_stq_empty                     => xu_mm_lmq_stq_empty,
        lsu_xu_quiesce                          => lsu_xu_quiesce,
        lsu_xu_dbell_val                        => lsu_xu_dbell_val,
        lsu_xu_dbell_type                       => lsu_xu_dbell_type,
        lsu_xu_dbell_brdcast                    => lsu_xu_dbell_brdcast,
        lsu_xu_dbell_lpid_match                 => lsu_xu_dbell_lpid_match,
        lsu_xu_dbell_pirtag                     => lsu_xu_dbell_pirtag,
                                                  
        xu_ex1_rb                               => xu_ex1_rb,
        xu_ex2_eff_addr                         => xu_ex2_eff_addr,
                                                  
        ac_an_req_pwr_token                     => ac_an_req_pwr_token,
        ac_an_req                               => ac_an_req,
        ac_an_req_ra                            => ac_an_req_ra,
        ac_an_req_ttype                         => ac_an_req_ttype,
        ac_an_req_thread                        => ac_an_req_thread,
        ac_an_req_wimg_w                        => ac_an_req_wimg_w,
        ac_an_req_wimg_i                        => ac_an_req_wimg_i,
        ac_an_req_wimg_m                        => ac_an_req_wimg_m,
        ac_an_req_wimg_g                        => ac_an_req_wimg_g,
        ac_an_req_endian                        => ac_an_req_endian,
        ac_an_req_user_defined                  => ac_an_req_user_defined,
        ac_an_req_spare_ctrl_a0                 => ac_an_req_spare_ctrl_a0,
        ac_an_req_ld_core_tag                   => ac_an_req_ld_core_tag,
        ac_an_req_ld_xfr_len                    => ac_an_req_ld_xfr_len,
        ac_an_st_byte_enbl                      => ac_an_st_byte_enbl,
        ac_an_st_data                           => ac_an_st_data,
        ac_an_st_data_pwr_token                 => ac_an_st_data_pwr_token,
                                                  
        xu_pc_err_dcachedir_parity              => xu_pc_err_dcachedir_parity,
        xu_pc_err_dcachedir_multihit            => xu_pc_err_dcachedir_multihit,
        xu_pc_err_l2intrf_ecc                   => xu_pc_err_l2intrf_ecc,
        xu_pc_err_l2intrf_ue                    => xu_pc_err_l2intrf_ue,
        xu_pc_err_invld_reld                    => xu_pc_err_invld_reld,
        xu_pc_err_l2credit_overrun              => xu_pc_err_l2credit_overrun,
                                                  
        pc_xu_event_bus_enable                  => pc_xu_event_bus_enable,
        pc_xu_lsu_event_mux_ctrls               => pc_xu_lsu_event_mux_ctrls,
        pc_xu_cache_par_err_event               => pc_xu_cache_par_err_event,
        xu_pc_lsu_event_data                    => xu_pc_lsu_event_data,
                                                  
        lsu_xu_cmd_debug                        => lsu_xu_cmd_debug,
                                                 
        an_ac_lbist_ary_wrt_thru_dc             => an_ac_lbist_ary_wrt_thru_dc,
        pc_xu_abist_g8t_wenb                    => pc_xu_abist_g8t_wenb,
        pc_xu_abist_g8t1p_renb_0                => pc_xu_abist_g8t1p_renb_0,
        pc_xu_abist_g8t_bw_1                    => pc_xu_abist_g8t_bw_1,
        pc_xu_abist_g8t_bw_0                    => pc_xu_abist_g8t_bw_0,
        pc_xu_abist_wl32_comp_ena               => pc_xu_abist_wl32_comp_ena,
        pc_xu_abist_g8t_dcomp                   => pc_xu_abist_g8t_dcomp,
        pc_xu_bo_unload                         => pc_xu_bo_unload,
        pc_xu_bo_repair                         => pc_xu_bo_repair,
        pc_xu_bo_reset                          => pc_xu_bo_reset,
        pc_xu_bo_shdata                         => pc_xu_bo_shdata,
        pc_xu_bo_select                         => pc_xu_bo_select(1 to 4),
        xu_pc_bo_fail                           => xu_pc_bo_fail(1 to 4),
        xu_pc_bo_diagout                        => xu_pc_bo_diagout(1 to 4),
                                                  
        vcs                                     => vcs,
        vdd                                     => vdd,
        gnd                                     => gnd,
        nclk                                    => nclk,
        an_ac_coreid                            => an_ac_coreid(60 to 61),
        an_ac_atpg_en_dc                        => an_ac_atpg_en_dc,

        bcfg_scan_in                            => ctrl_bcfg_scan_in,
        bcfg_scan_out                           => ctrl_bcfg_scan_out,
        dcfg_scan_in                            => ctrl_dcfg_scan_in,
        dcfg_scan_out                           => ctrl_dcfg_scan_out,
        gptr_scan_in                            => ctrl_gptr_scan_in,
        gptr_scan_out                           => ctrl_gptr_scan_out,
        time_scan_in                            => ctrl_time_scan_in,
        time_scan_out                           => ctrl_time_scan_out,
        func_scan_in                            => func_scan_in(41 to 58),
        func_scan_out                           => func_scan_out(41 to 58),
        ccfg_scan_in                            => ctrl_ccfg_scan_in,
        ccfg_scan_out                           => ctrl_ccfg_scan_out,
        regf_scan_in                            => regf_scan_in,
        regf_scan_out                           => regf_scan_out,
        abst_scan_in                            => abst_scan_in(0),
        abst_scan_out                           => abst_scan_out(0),
        repr_scan_in                            => ctrl_repr_scan_in,
        repr_scan_out                           => ctrl_repr_scan_out
);

xu_spr : entity work.xuq_spr(xuq_spr)
generic map(
        hvmode                          => hvmode,
        a2mode                          => a2mode,
        expand_type                     => expand_type,
        threads                         => threads,
        regsize                         => regsize,
        eff_ifar                        => eff_ifar,
        spr_xucr0_init_mod              => spr_xucr0_init_mod)
port map(
        nclk                                    => nclk,
   
        an_ac_coreid                            => an_ac_coreid,
        spr_pvr_version_dc                      => spr_pvr_version_dc,
        spr_pvr_revision_dc                     => spr_pvr_revision_dc,
        an_ac_ext_interrupt                     => an_ac_ext_interrupt,
        an_ac_crit_interrupt                    => an_ac_crit_interrupt,
        an_ac_perf_interrupt                    => an_ac_perf_interrupt,
        an_ac_reservation_vld                   => an_ac_reservation_vld,
        an_ac_tb_update_pulse                   => an_ac_tb_update_pulse,
        an_ac_tb_update_enable                  => an_ac_tb_update_enable,
        an_ac_sleep_en                          => an_ac_sleep_en,
        an_ac_hang_pulse                        => an_ac_hang_pulse,
        ac_tc_machine_check                     => ac_tc_machine_check,
        an_ac_external_mchk                     => an_ac_external_mchk,
        pc_xu_instr_trace_mode                  => pc_xu_instr_trace_mode,
        pc_xu_instr_trace_tid                   => pc_xu_instr_trace_tid,                                                
        an_ac_scan_dis_dc_b                     => an_ac_scan_dis_dc_b,
        an_ac_scan_diag_dc                      => an_ac_scan_diag_dc,
        pc_xu_ccflush_dc                        => pc_xu_ccflush_dc,
        clkoff_dc_b                             => clkoff_dc_b_b,
        d_mode_dc                               => d_mode_dc_b,
        delay_lclkr_dc                          => delay_lclkr_dc_b(2),
        mpw1_dc_b                               => mpw1_dc_b_b(2),
        mpw2_dc_b                               => mpw2_dc_b_b,
        func_sl_thold_2                         => func_sl_thold_2_b(1),
        func_slp_sl_thold_2                     => func_slp_sl_thold_2_b(0),
        func_nsl_thold_2                        => func_nsl_thold_2_b,
        func_slp_nsl_thold_2                    => func_slp_nsl_thold_2_b,
        cfg_sl_thold_2                          => cfg_sl_thold_2_b,        
        cfg_slp_sl_thold_2                      => cfg_slp_sl_thold_2_b,
        ary_nsl_thold_2                         => ary_nsl_thold_2_b,
        time_sl_thold_2                         => time_sl_thold_2_b,
        gptr_sl_thold_2                         => gptr_sl_thold_2_b,
        abst_sl_thold_2                         => abst_sl_thold_2_b,
        repr_sl_thold_2                         => repr_sl_thold_2_b,
        sg_2                                    => sg_2_b(1),
        fce_2                                   => fce_2_b(0),
        func_scan_in                            => func_scan_in(35 to 40),
        func_scan_out                           => func_scan_out(35 to 40),
        bcfg_scan_in                            => spr_bcfg_scan_in,
        bcfg_scan_out                           => spr_bcfg_scan_out,
        ccfg_scan_in                            => spr_ccfg_scan_in,
        ccfg_scan_out                           => spr_ccfg_scan_out,
        dcfg_scan_in                            => spr_dcfg_scan_in,
        dcfg_scan_out                           => spr_dcfg_scan_out,
        time_scan_in                            => spr_time_scan_in,
        time_scan_out                           => spr_time_scan_out,
        abst_scan_in                            => abst_scan_in(1),
        abst_scan_out                           => abst_scan_out(1),
        repr_scan_in                            => spr_repr_scan_in,
        repr_scan_out                           => spr_repr_scan_out,
        gptr_scan_in                            => spr_gptr_scan_in,
        gptr_scan_out                           => spr_gptr_scan_out,
                                               
        dec_spr_rf0_tid                         => dec_spr_rf0_tid,
        dec_spr_rf0_instr                       => dec_spr_rf0_instr,
        dec_spr_rf1_val                         => dec_spr_rf1_val,
        dec_spr_ex1_epid_instr                  => dec_spr_ex1_epid_instr,
        dec_spr_ex4_val                         => dec_spr_ex4_val,
                                                
        spr_byp_ex3_spr_rt                      => spr_byp_ex3_spr_rt,
                                                
        fxu_spr_ex1_rs2                         => fxu_spr_ex1_rs2,
                                                
        fxu_spr_ex1_rs0                         => fxu_spr_ex1_rs0,
        fxu_spr_ex1_rs1                         => fxu_spr_ex1_rs1,
        mux_spr_ex2_rt                          => mux_spr_ex2_rt,
                                                
        cpl_spr_ex5_act                         => cpl_spr_ex5_act,
        cpl_spr_ex5_int                         => cpl_spr_ex5_int,
        cpl_spr_ex5_gint                        => cpl_spr_ex5_gint,
        cpl_spr_ex5_cint                        => cpl_spr_ex5_cint,
        cpl_spr_ex5_mcint                       => cpl_spr_ex5_mcint,
        cpl_spr_ex5_nia                         => cpl_spr_ex5_nia,
        cpl_spr_ex5_esr                         => cpl_spr_ex5_esr,
        cpl_spr_ex5_mcsr                        => cpl_spr_ex5_mcsr,
        cpl_spr_ex5_dbsr                        => cpl_spr_ex5_dbsr,
        cpl_spr_ex5_dear_save                   => cpl_spr_ex5_dear_save,
        cpl_spr_ex5_dear_update_saved           => cpl_spr_ex5_dear_update_saved,
        cpl_spr_ex5_dear_update                 => cpl_spr_ex5_dear_update,
        cpl_spr_ex5_dbsr_update                 => cpl_spr_ex5_dbsr_update,
        cpl_spr_ex5_esr_update                  => cpl_spr_ex5_esr_update,
        cpl_spr_ex5_srr0_dec                    => cpl_spr_ex5_srr0_dec,
        cpl_spr_ex5_force_gsrr                  => cpl_spr_ex5_force_gsrr,
        cpl_spr_ex5_dbsr_ide                    => cpl_spr_ex5_dbsr_ide,
        spr_cpl_dbsr_ide                        => spr_cpl_dbsr_ide,
                                               
        spr_cpl_external_mchk                   => spr_cpl_external_mchk,
        spr_cpl_ext_interrupt                   => spr_cpl_ext_interrupt,
        spr_cpl_udec_interrupt                  => spr_cpl_udec_interrupt,
        spr_cpl_perf_interrupt                  => spr_cpl_perf_interrupt,
        spr_cpl_dec_interrupt                   => spr_cpl_dec_interrupt,
        spr_cpl_fit_interrupt                   => spr_cpl_fit_interrupt,
        spr_cpl_crit_interrupt                  => spr_cpl_crit_interrupt,
        spr_cpl_wdog_interrupt                  => spr_cpl_wdog_interrupt,
        spr_cpl_dbell_interrupt                 => spr_cpl_dbell_interrupt,
        spr_cpl_cdbell_interrupt                => spr_cpl_cdbell_interrupt,
        spr_cpl_gdbell_interrupt                => spr_cpl_gdbell_interrupt,
        spr_cpl_gcdbell_interrupt               => spr_cpl_gcdbell_interrupt,
        spr_cpl_gmcdbell_interrupt              => spr_cpl_gmcdbell_interrupt,
        cpl_spr_ex5_dbell_taken                 => cpl_spr_ex5_dbell_taken,
        cpl_spr_ex5_cdbell_taken                => cpl_spr_ex5_cdbell_taken,
        cpl_spr_ex5_gdbell_taken                => cpl_spr_ex5_gdbell_taken,
        cpl_spr_ex5_gcdbell_taken               => cpl_spr_ex5_gcdbell_taken,
        cpl_spr_ex5_gmcdbell_taken              => cpl_spr_ex5_gmcdbell_taken,

        lsu_xu_dbell_val                        => lsu_xu_dbell_val,
        lsu_xu_dbell_type                       => lsu_xu_dbell_type,
        lsu_xu_dbell_brdcast                    => lsu_xu_dbell_brdcast,
        lsu_xu_dbell_lpid_match                 => lsu_xu_dbell_lpid_match,
        lsu_xu_dbell_pirtag                     => lsu_xu_dbell_pirtag,

        xu_lsu_slowspr_val                      => xu_lsu_slowspr_val,
        xu_lsu_slowspr_rw                       => xu_lsu_slowspr_rw,
        xu_lsu_slowspr_etid                     => xu_lsu_slowspr_etid,
        xu_lsu_slowspr_addr                     => xu_lsu_slowspr_addr,
        xu_lsu_slowspr_data                     => xu_lsu_slowspr_data,
                                                
        ac_an_dcr_act                           => ac_an_dcr_act,
        ac_an_dcr_val                           => ac_an_dcr_val,
        ac_an_dcr_read                          => ac_an_dcr_read,
        ac_an_dcr_user                          => ac_an_dcr_user,
        ac_an_dcr_etid                          => ac_an_dcr_etid,
        ac_an_dcr_addr                          => ac_an_dcr_addr,
        ac_an_dcr_data                          => ac_an_dcr_data,

        xu_ex4_flush                            => xu_s_ex4_flush_int,
        xu_ex5_flush                            => xu_s_ex5_flush_int,

        spr_cpl_fp_precise                      => spr_cpl_fp_precise,
        spr_cpl_ex3_spr_hypv                    => spr_cpl_ex3_spr_hypv,
        spr_cpl_ex3_spr_illeg                   => spr_cpl_ex3_spr_illeg,
        spr_cpl_ex3_spr_priv                    => spr_cpl_ex3_spr_priv,
        spr_cpl_ex3_ct_le                       => spr_cpl_ex3_ct_le,
        spr_cpl_ex3_ct_be                       => spr_cpl_ex3_ct_be,

        cpl_spr_stop                            => cpl_spr_stop,
        xu_pc_running                           => xu_pc_running,
        xu_iu_run_thread                        => xu_iu_run_thread,
        xu_iu_single_instr_mode                 => xu_iu_single_instr_mode,
        xu_iu_raise_iss_pri                     => xu_iu_raise_iss_pri,
        spr_cpl_ex2_run_ctl_flush               => spr_cpl_ex2_run_ctl_flush,
        xu_pc_spr_ccr0_we                       => spr_ccr0_we,
                                               
        iu_xu_quiesce                           => iu_xu_quiesce,
        lsu_xu_quiesce                          => lsu_xu_quiesce,
        mm_xu_quiesce                           => mm_xu_quiesce,
        bx_xu_quiesce                           => bx_xu_quiesce,
        spr_cpl_quiesce                         => spr_cpl_quiesce,
        cpl_spr_quiesce                         => cpl_spr_quiesce,
                                               
        pc_xu_extirpts_dis_on_stop              => pc_xu_extirpts_dis_on_stop,
        pc_xu_timebase_dis_on_stop              => pc_xu_timebase_dis_on_stop,
        pc_xu_decrem_dis_on_stop                => pc_xu_decrem_dis_on_stop,
                                               
        pc_xu_ram_mode                          => pc_xu_ram_mode,
        pc_xu_ram_thread                        => pc_xu_ram_thread,
        pc_xu_msrovride_enab                    => pc_xu_msrovride_enab,
        pc_xu_msrovride_pr                      => pc_xu_msrovride_pr,
        pc_xu_msrovride_gs                      => pc_xu_msrovride_gs,
        pc_xu_msrovride_de                      => pc_xu_msrovride_de,
                                               
        cpl_spr_ex5_instr_cpl                   => cpl_spr_ex5_instr_cpl,
        xu_pc_err_llbust_attempt                => xu_pc_err_llbust_attempt,
        xu_pc_err_llbust_failed                 => xu_pc_err_llbust_failed,
                                               
        spr_byp_ex4_is_mtxer                    => spr_byp_ex4_is_mtxer,
        spr_byp_ex4_is_mfxer                    => spr_byp_ex4_is_mfxer,
                                               
        pc_xu_reset_wd_complete                 => pc_xu_reset_wd_complete,
        pc_xu_reset_1_complete                  => pc_xu_reset_1_complete,
        pc_xu_reset_2_complete                  => pc_xu_reset_2_complete,
        pc_xu_reset_3_complete                  => pc_xu_reset_3_complete,
        ac_tc_reset_1_request                   => ac_tc_reset_1_request,
        ac_tc_reset_2_request                   => ac_tc_reset_2_request,
        ac_tc_reset_3_request                   => ac_tc_reset_3_request,
        ac_tc_reset_wd_request                  => ac_tc_reset_wd_request,
                                               
        pc_xu_inj_llbust_attempt                => pc_xu_inj_llbust_attempt,
        pc_xu_inj_llbust_failed                 => pc_xu_inj_llbust_failed,
        pc_xu_inj_wdt_reset                     => pc_xu_inj_wdt_reset,
        xu_pc_err_wdt_reset                     => xu_pc_err_wdt_reset,
                                               
        spr_cpl_ex3_sprg_ce                     => spr_cpl_ex3_sprg_ce,
        spr_cpl_ex3_sprg_ue                     => spr_cpl_ex3_sprg_ue,
        pc_xu_inj_sprg_ecc                      => pc_xu_inj_sprg_ecc,
        xu_pc_err_sprg_ecc                      => xu_pc_err_sprg_ecc,
                                               
        spr_perf_tx_events                      => spr_perf_tx_events,
        xu_lsu_mtspr_trace_en                   => xu_lsu_mtspr_trace_en,

       spr_bit_act                              => spr_bit_act,
        spr_cpl_iac1_en                         => spr_cpl_iac1_en,
        spr_cpl_iac2_en                         => spr_cpl_iac2_en,
        spr_cpl_iac3_en                         => spr_cpl_iac3_en,
        spr_cpl_iac4_en                         => spr_cpl_iac4_en,
        spr_dbcr1_iac12m                        => spr_dbcr1_iac12m,
        spr_dbcr1_iac34m                        => spr_dbcr1_iac34m,
        spr_epcr_duvd                           => spr_epcr_duvd,
        lsu_xu_spr_xucr0_cslc_xuop              => lsu_xu_spr_xucr0_cslc_xuop,
        lsu_xu_spr_xucr0_cslc_binv              => lsu_xu_spr_xucr0_cslc_binv,
        lsu_xu_spr_xucr0_clo                    => lsu_xu_spr_xucr0_clo,
        lsu_xu_spr_xucr0_cul                    => lsu_xu_spr_xucr0_cul,
        lsu_xu_spr_epsc_epr                     => lsu_xu_spr_epsc_epr,
        lsu_xu_spr_epsc_egs                     => lsu_xu_spr_epsc_egs,
        spr_epcr_extgs                          => spr_epcr_extgs,
        spr_msr_pr                              => spr_msr_pr_int,
        spr_msr_is                              => spr_msr_is,
        spr_msr_cm                              => spr_msr_cm_int,
        spr_msr_gs                              => spr_msr_gs_int,
        spr_msr_me                              => spr_msr_me,
        xu_lsu_spr_xucr0_clfc                   => xu_lsu_spr_xucr0_clfc,
        xu_pc_spr_ccr0_pme                      => xu_pc_spr_ccr0_pme,
        spr_ccr2_en_dcr                         => spr_ccr2_en_dcr_int,
        spr_ccr2_en_pc                          => spr_ccr2_en_pc,
        xu_iu_spr_ccr2_ifratsc                  => xu_iu_spr_ccr2_ifratsc,
        xu_iu_spr_ccr2_ifrat                    => xu_iu_spr_ccr2_ifrat,
        xu_lsu_spr_ccr2_dfratsc                 => xu_lsu_spr_ccr2_dfratsc,
        xu_lsu_spr_ccr2_dfrat                   => xu_lsu_spr_ccr2_dfrat,
        spr_ccr2_ucode_dis                      => spr_ccr2_ucode_dis,
        spr_ccr2_ap                             => spr_ccr2_ap_int,
        spr_ccr2_en_attn                        => spr_ccr2_en_attn,
        spr_ccr2_en_ditc                        => spr_ccr2_en_ditc_int,
        spr_ccr2_en_icswx                       => spr_ccr2_en_icswx,
        spr_ccr2_notlb                          => spr_ccr2_notlb_int,
        xu_lsu_spr_xucr0_mbar_ack               => xu_lsu_spr_xucr0_mbar_ack,
        xu_lsu_spr_xucr0_tlbsync                => xu_lsu_spr_xucr0_tlbsync,
        spr_dec_spr_xucr0_ssdly                 => spr_dec_spr_xucr0_ssdly,
        spr_xucr0_cls                           => xu_lsu_spr_xucr0_cls,
        xu_lsu_spr_xucr0_aflsta                 => xu_lsu_spr_xucr0_aflsta,
        spr_xucr0_mddp                          => spr_xucr0_mddp,
        xu_lsu_spr_xucr0_cred                   => xu_lsu_spr_xucr0_cred,
        xu_lsu_spr_xucr0_rel                    => xu_lsu_spr_xucr0_rel_int,
        spr_xucr0_mdcp                          => spr_xucr0_mdcp,
        xu_lsu_spr_xucr0_flsta                  => xu_lsu_spr_xucr0_flsta,
        xu_lsu_spr_xucr0_l2siw                  => xu_lsu_spr_xucr0_l2siw,
        xu_lsu_spr_xucr0_flh2l2                 => xu_lsu_spr_xucr0_flh2l2,
        xu_lsu_spr_xucr0_dcdis                  => xu_lsu_spr_xucr0_dcdis_int,
        xu_lsu_spr_xucr0_wlk                    => xu_lsu_spr_xucr0_wlk,
        cpl_spr_dbcr0_edm                       => cpl_spr_dbcr0_edm,
        spr_dbcr0_idm                           => spr_dbcr0_idm,
        spr_dbcr0_icmp                          => spr_dbcr0_icmp,
        spr_dbcr0_brt                           => spr_dbcr0_brt,
        spr_dbcr0_irpt                          => spr_dbcr0_irpt,
        spr_dbcr0_trap                          => spr_dbcr0_trap,
        spr_dbcr0_dac1                          => spr_dbcr0_dac1,
        spr_dbcr0_dac2                          => spr_dbcr0_dac2,
        spr_dbcr0_ret                           => spr_dbcr0_ret,
        spr_dbcr0_dac3                          => spr_dbcr0_dac3,
        spr_dbcr0_dac4                          => spr_dbcr0_dac4,
        spr_epcr_dtlbgs                         => spr_epcr_dtlbgs,
        spr_epcr_itlbgs                         => spr_epcr_itlbgs,
        spr_epcr_dsigs                          => spr_epcr_dsigs,
        spr_epcr_isigs                          => spr_epcr_isigs,
        spr_epcr_dgtmi                          => spr_dec_rf1_epcr_dgtmi,
        xu_mm_spr_epcr_dmiuh                    => xu_mm_spr_epcr_dmiuh,
        spr_msr_ucle                            => spr_msr_ucle,
        spr_msr_spv                             => spr_msr_spv_int,
        spr_msr_fp                              => spr_msr_fp_int,
        spr_msr_de                              => spr_msr_de,
        spr_msr_ds                              => spr_msr_ds_int,
        spr_msrp_uclep                          => spr_msrp_uclep,
        spr_xucr0_clkg_ctl                      => spr_xucr0_clkg_ctl,

        an_ac_lbist_ary_wrt_thru_dc             => an_ac_lbist_ary_wrt_thru_dc,
        pc_xu_abist_ena_dc                      => pc_xu_abist_ena_dc,
        pc_xu_abist_g8t_wenb                    => pc_xu_abist_g8t_wenb,
        pc_xu_abist_waddr_0                     => pc_xu_abist_waddr_0(4 to 9),
        pc_xu_abist_di_0                        => pc_xu_abist_di_0,
        pc_xu_abist_g8t1p_renb_0                => pc_xu_abist_g8t1p_renb_0,
        pc_xu_abist_raddr_0                     => pc_xu_abist_raddr_0(4 to 9),
        pc_xu_abist_wl32_comp_ena               => pc_xu_abist_wl32_comp_ena,
        pc_xu_abist_raw_dc_b                    => pc_xu_abist_raw_dc_b,
        pc_xu_abist_g8t_dcomp                   => pc_xu_abist_g8t_dcomp,
        pc_xu_abist_g8t_bw_1                    => pc_xu_abist_g8t_bw_1,
        pc_xu_abist_g8t_bw_0                    => pc_xu_abist_g8t_bw_0,
        bolt_sl_thold_2                         => bolt_sl_thold_2_b,
        bo_enable_2                             => bo_enable_2_b,
        pc_xu_bo_unload                         => pc_xu_bo_unload,
        pc_xu_bo_repair                         => pc_xu_bo_repair,
        pc_xu_bo_reset                          => pc_xu_bo_reset,
        pc_xu_bo_shdata                         => pc_xu_bo_shdata,
        pc_xu_bo_select                         => pc_xu_bo_select(0),
        xu_pc_bo_fail                           => xu_pc_bo_fail(0),
        xu_pc_bo_diagout                        => xu_pc_bo_diagout(0),
                                               
        lsu_xu_cmd_debug                        => lsu_xu_cmd_debug,
        pc_xu_trace_bus_enable                  => pc_xu_trace_bus_enable,
        spr_debug_mux_ctrls                     => spr_debug_mux_ctrls,
        spr_debug_data_in                       => spr_debug_data_in,
        spr_debug_data_out                      => spr_debug_data_out,
        spr_trigger_data_in                     => spr_trigger_data_in,
        spr_trigger_data_out                    => spr_trigger_data_out,
                                               
        vcs                                     => vcs,
        vdd                                     => vdd,
        gnd                                     => gnd
);

spr_msr_gs              <= spr_msr_gs_int;
spr_msr_pr              <= spr_msr_pr_int;
spr_msr_ds              <= spr_msr_ds_int;
spr_msr_cm              <= spr_msr_cm_int;
spr_msr_fp              <= spr_msr_fp_int;
spr_msr_spv             <= spr_msr_spv_int;
spr_ccr2_ap             <= spr_ccr2_ap_int;
spr_ccr2_en_dcr         <= spr_ccr2_en_dcr_int;
spr_ccr2_notlb          <= spr_ccr2_notlb_int;
spr_ccr2_en_ditc        <= spr_ccr2_en_ditc_int;
xu_lsu_spr_xucr0_dcdis  <= xu_lsu_spr_xucr0_dcdis_int;
xu_lsu_spr_xucr0_rel    <= xu_lsu_spr_xucr0_rel_int;
spr_xucr0_clkg_ctl_b0   <= spr_xucr0_clkg_ctl(0);

end xuq_ctrl_spr;  

