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

entity xuq_ctrl is
generic(
        expand_type             : integer :=  2;
        threads                 : integer :=  4;
        eff_ifar                : integer := 62;
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

        func_scan_in                            :in     std_ulogic_vector(41 to 58);
        func_scan_out                           :out    std_ulogic_vector(41 to 58);
        an_ac_grffence_en_dc                    :in     std_ulogic;
        an_ac_scan_dis_dc_b                     :in     std_ulogic;
        an_ac_lbist_en_dc                       :in     std_ulogic;
        pc_xu_abist_raddr_0                     :in     std_ulogic_vector(5 to 9);
        pc_xu_abist_ena_dc                      :in     std_ulogic;
        pc_xu_abist_waddr_0                     :in     std_ulogic_vector(5 to 9);
        pc_xu_abist_di_0                        :in     std_ulogic_vector(0 to 3);
        pc_xu_abist_raw_dc_b                    :in     std_ulogic;
        pc_xu_ccflush_dc                        :in     std_ulogic;
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
        pc_xu_sg_3                              :in     std_ulogic_vector(0 to 4);
        pc_xu_func_sl_thold_3                   :in     std_ulogic_vector(0 to 4);
        pc_xu_func_slp_sl_thold_3               :in     std_ulogic_vector(0 to 4);
        pc_xu_func_nsl_thold_3                  :in     std_ulogic;
        pc_xu_func_slp_nsl_thold_3              :in     std_ulogic;
        pc_xu_gptr_sl_thold_3                   :in     std_ulogic;
        pc_xu_abst_sl_thold_3                   :in     std_ulogic;
        pc_xu_abst_slp_sl_thold_3               :in     std_ulogic;
        pc_xu_regf_sl_thold_3                   :in     std_ulogic;
        pc_xu_regf_slp_sl_thold_3               :in     std_ulogic;
        pc_xu_time_sl_thold_3                   :in     std_ulogic;
        pc_xu_cfg_sl_thold_3                    :in     std_ulogic;
        pc_xu_cfg_slp_sl_thold_3                :in     std_ulogic;
        pc_xu_ary_nsl_thold_3                   :in     std_ulogic;
        pc_xu_ary_slp_nsl_thold_3               :in     std_ulogic;
        pc_xu_repr_sl_thold_3                   :in     std_ulogic;
        pc_xu_fce_3                             :in     std_ulogic_vector(0 to 1);
        an_ac_scan_diag_dc                      :in     std_ulogic;
        sg_2                                    :out std_ulogic_vector(0 to 3);
        fce_2                                   :out std_ulogic_vector(0 to 1);
        func_sl_thold_2                         :out std_ulogic_vector(0 to 3);
        func_slp_sl_thold_2                     :out std_ulogic_vector(0 to 1);
        func_nsl_thold_2                        :out std_ulogic;
        func_slp_nsl_thold_2                    :out std_ulogic;
        abst_sl_thold_2                         :out std_ulogic;
        time_sl_thold_2                         :out std_ulogic;
        gptr_sl_thold_2                         :out std_ulogic;
        ary_nsl_thold_2                         :out std_ulogic;
        repr_sl_thold_2                         :out std_ulogic;
        cfg_sl_thold_2                          :out std_ulogic;
        cfg_slp_sl_thold_2                      :out std_ulogic;
        regf_slp_sl_thold_2                     :out std_ulogic;
        gptr_scan_in                            :in     std_ulogic;
        gptr_scan_out                           :out    std_ulogic;
        time_scan_in                            :in     std_ulogic;
        time_scan_out                           :out    std_ulogic;
        pc_xu_bolt_sl_thold_3                   :in     std_ulogic;
        pc_xu_bo_enable_3                       :in     std_ulogic;
        bolt_sl_thold_2                         :out std_ulogic;
        bo_enable_2                             :out std_ulogic;
        pc_xu_bo_unload                         :in     std_ulogic;
        pc_xu_bo_repair                         :in     std_ulogic;
        pc_xu_bo_reset                          :in     std_ulogic;
        pc_xu_bo_shdata                         :in     std_ulogic;
        pc_xu_bo_select                         :in     std_ulogic_vector(1 to 4);
        xu_pc_bo_fail                           :out    std_ulogic_vector(1 to 4);
        xu_pc_bo_diagout                        :out    std_ulogic_vector(1 to 4);

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
        fxb_fxa_ex6_clear_barrier               :out std_ulogic_vector(0 to threads-1);
        xu_iu_ex5_gshare                        :out std_ulogic_vector(0 to 3);
        xu_iu_ex5_getNIA                        :out std_ulogic;

        an_ac_stcx_complete                     :in  std_ulogic_vector(0 to threads-1);
        an_ac_stcx_pass                         :in  std_ulogic_vector(0 to threads-1);

        slowspr_val_in                          :in  std_ulogic;
        slowspr_rw_in                           :in  std_ulogic;
        slowspr_etid_in                         :in  std_ulogic_vector(0 to 1);
        slowspr_addr_in                         :in  std_ulogic_vector(0 to 9);
        slowspr_data_in                         :in  std_ulogic_vector(64-(2**regmode) to 63);
        slowspr_done_in                         :in  std_ulogic;

        an_ac_dcr_act                           :in  std_ulogic;
        an_ac_dcr_val                           :in  std_ulogic;
        an_ac_dcr_read                          :in  std_ulogic;
        an_ac_dcr_etid                          :in  std_ulogic_vector(0 to 1);
        an_ac_dcr_data                          :in  std_ulogic_vector(64-(2**regmode) to 63);
        an_ac_dcr_done                          :in  std_ulogic;

        lsu_xu_ex4_mtdp_cr_status               :in  std_ulogic;
        lsu_xu_ex4_mfdp_cr_status               :in  std_ulogic;
        dec_cpl_ex3_mc_dep_chk_val              :in  std_ulogic_vector(0 to threads-1);

        dec_spr_ex4_val                         :out std_ulogic_vector(0 to threads-1);
        dec_spr_ex1_epid_instr                  :out std_ulogic;
        mux_spr_ex2_rt                          :out std_ulogic_vector(64-(2**regmode) to 63);
        fxu_spr_ex1_rs0                         :out std_ulogic_vector(52 to 63);
        fxu_spr_ex1_rs1                         :out std_ulogic_vector(54 to 63);
        spr_msr_cm                              :in  std_ulogic_vector(0 to threads-1);
        spr_dec_spr_xucr0_ssdly                 :in  std_ulogic_vector(0 to 4);
        spr_ccr2_en_attn                        :in  std_ulogic;
        spr_ccr2_en_ditc                        :in  std_ulogic;
        spr_ccr2_en_pc                          :in  std_ulogic;
        spr_ccr2_en_icswx                       :in  std_ulogic;
        spr_ccr2_en_dcr                         :in  std_ulogic;
        spr_dec_rf1_epcr_dgtmi                  :in  std_ulogic_vector(0 to threads-1);
        spr_byp_ex4_is_mfxer                    :in  std_ulogic_vector(0 to threads-1);
        spr_byp_ex3_spr_rt                      :in  std_ulogic_vector(64-(2**regmode) to 63);
        spr_byp_ex4_is_mtxer                    :in  std_ulogic_vector(0 to threads-1);
        spr_ccr2_notlb                          :in  std_ulogic;
        dec_spr_rf1_val                         :out std_ulogic_vector(0 to threads-1);
        fxu_spr_ex1_rs2                         :out std_ulogic_vector(42 to 55);

        fxa_perf_muldiv_in_use                  :in  std_ulogic;
        spr_perf_tx_events                      :in  std_ulogic_vector(0 to 8*threads-1);
        xu_pc_event_data                        :out std_ulogic_vector(0 to 7);

        pc_xu_event_count_mode                  :in  std_ulogic_vector(0 to 2);
        pc_xu_event_mux_ctrls                   :in  std_ulogic_vector(0 to 47);

        fxu_debug_mux_ctrls                     :in  std_ulogic_vector(0 to 15);
        cpl_debug_mux_ctrls                     :in  std_ulogic_vector(0 to 15);
        lsu_debug_mux_ctrls                     :in  std_ulogic_vector(0 to 15);
        ctrl_trigger_data_in                    :in  std_ulogic_vector(0 to 11);
        ctrl_trigger_data_out                   :out std_ulogic_vector(0 to 11);
        ctrl_debug_data_in                      :in  std_ulogic_vector(0 to 87);
        ctrl_debug_data_out                     :out std_ulogic_vector(0 to 87);
        lsu_xu_data_debug0                      :in  std_ulogic_vector(0 to 87);
        lsu_xu_data_debug1                      :in  std_ulogic_vector(0 to 87);
        lsu_xu_data_debug2                      :in  std_ulogic_vector(0 to 87);
        fxa_cpl_debug                           :in  std_ulogic_vector(0 to 272);

        spr_msr_gs                              :in  std_ulogic_vector(0 to threads-1);
        spr_msr_ds                              :in  std_ulogic_vector(0 to threads-1);
        spr_msr_pr                              :in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_dac1                          :in  std_ulogic_vector(0 to 2*threads-1);
        spr_dbcr0_dac2                          :in  std_ulogic_vector(0 to 2*threads-1);
        spr_dbcr0_dac3                          :in  std_ulogic_vector(0 to 2*threads-1);
        spr_dbcr0_dac4                          :in  std_ulogic_vector(0 to 2*threads-1);

        ac_tc_debug_trigger                     :out std_ulogic_vector(0 to threads-1);

        bcfg_scan_in                            :in  std_ulogic;
        bcfg_scan_out                           :out std_ulogic;
        dcfg_scan_in                            :in  std_ulogic;
        dcfg_scan_out                           :out std_ulogic;

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

        spr_cpl_ext_interrupt                   :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_udec_interrupt                  :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_perf_interrupt                  :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_dec_interrupt                   :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_fit_interrupt                   :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_crit_interrupt                  :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_wdog_interrupt                  :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_dbell_interrupt                 :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_cdbell_interrupt                :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_gdbell_interrupt                :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_gcdbell_interrupt               :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_gmcdbell_interrupt              :in  std_ulogic_vector(0 to threads-1);

        cpl_spr_ex5_dbell_taken                 :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_cdbell_taken                :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_gdbell_taken                :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_gcdbell_taken               :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_gmcdbell_taken              :out std_ulogic_vector(0 to threads-1);

        cpl_spr_ex5_act                         :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_int                         :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_gint                        :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_cint                        :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_mcint                       :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_nia                         :out std_ulogic_vector(0 to eff_ifar*threads-1);
        cpl_spr_ex5_esr                         :out std_ulogic_vector(0 to 17*threads-1);
        cpl_spr_ex5_mcsr                        :out std_ulogic_vector(0 to 15*threads-1);
        cpl_spr_ex5_dbsr                        :out std_ulogic_vector(0 to 19*threads-1);
        cpl_spr_ex5_dear_save                   :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_dear_update_saved           :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_dear_update                 :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_dbsr_update                 :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_esr_update                  :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_srr0_dec                    :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_force_gsrr                  :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_dbsr_ide                    :out std_ulogic_vector(0 to threads-1);

        spr_cpl_dbsr_ide                        :in  std_ulogic_vector(0 to threads-1);

        mm_xu_local_snoop_reject                :in  std_ulogic_vector(0 to threads-1);
        mm_xu_lru_par_err                       :in  std_ulogic_vector(0 to threads-1);
        mm_xu_tlb_par_err                       :in  std_ulogic_vector(0 to threads-1);
        mm_xu_tlb_multihit_err                  :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_external_mchk                   :in  std_ulogic_vector(0 to threads-1);

        xu_pc_err_attention_instr               :out std_ulogic_vector(0 to threads-1);
        xu_pc_err_nia_miscmpr                   :out std_ulogic_vector(0 to threads-1);
        xu_pc_err_debug_event                   :out std_ulogic_vector(0 to threads-1);

        spr_cpl_ex3_ct_le                       :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_ex3_ct_be                       :in  std_ulogic_vector(0 to threads-1);

        spr_cpl_ex3_spr_illeg                   :in  std_ulogic;
        spr_cpl_ex3_spr_priv                    :in  std_ulogic;

        spr_cpl_ex3_spr_hypv                    :in  std_logic;

        cpl_spr_stop                            :out std_ulogic_vector(0 to threads-1);
        xu_pc_stop_dbg_event                    :out std_ulogic_vector(0 to threads-1);
        cpl_spr_ex5_instr_cpl                   :out std_ulogic_vector(0 to threads-1);
        spr_cpl_quiesce                         :in  std_ulogic_vector(0 to threads-1);
        cpl_spr_quiesce                         :out std_ulogic_vector(0 to threads-1);
        spr_cpl_ex2_run_ctl_flush               :in  std_ulogic_vector(0 to threads-1);

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

        xu_n_is2_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_n_rf0_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_n_rf1_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_n_ex1_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_n_ex2_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_n_ex3_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_n_ex4_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_n_ex5_flush                          : out std_ulogic_vector(0 to threads-1);

        xu_s_rf1_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_s_ex1_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_s_ex2_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_s_ex3_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_s_ex4_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_s_ex5_flush                          : out std_ulogic_vector(0 to threads-1);

        xu_w_rf1_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_w_ex1_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_w_ex2_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_w_ex3_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_w_ex4_flush                          : out std_ulogic_vector(0 to threads-1);
        xu_w_ex5_flush                          : out std_ulogic_vector(0 to threads-1);

        xu_lsu_ex4_flush_local                  :out std_ulogic_vector(0 to threads-1);
        xu_mm_ex4_flush                         :out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_flush                         :out std_ulogic_vector(0 to threads-1);
        xu_mm_ierat_flush                       :out std_ulogic_vector(0 to threads-1);
        xu_mm_ierat_miss                        :out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_perf_itlb                     :out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_perf_dtlb                     :out std_ulogic_vector(0 to threads-1);

        spr_bit_act                             :in  std_ulogic;
        spr_epcr_duvd                           :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_iac1_en                         :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_iac2_en                         :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_iac3_en                         :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_iac4_en                         :in  std_ulogic_vector(0 to threads-1);
        spr_dbcr1_iac12m                        :in  std_ulogic_vector(0 to threads-1);
        spr_dbcr1_iac34m                        :in  std_ulogic_vector(0 to threads-1);
        spr_cpl_fp_precise                      :in  std_ulogic_vector(0 to threads-1);
        spr_xucr0_mddp                          :in  std_ulogic;
        spr_xucr0_mdcp                          :in  std_ulogic;
        spr_msr_de                              :in  std_ulogic_vector(0 to threads-1);
        spr_msr_spv                             :in  std_ulogic_vector(0 to threads-1);
        spr_msr_fp                              :in  std_ulogic_vector(0 to threads-1);
        spr_msr_me                              :in  std_ulogic_vector(0 to threads-1);
        spr_msr_ucle                            :in  std_ulogic_vector(0 to threads-1);
        spr_msrp_uclep                          :in  std_ulogic_vector(0 to threads-1);
        spr_ccr2_ucode_dis                      :in  std_ulogic;
        spr_ccr2_ap                             :in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_idm                           :in  std_ulogic_vector(0 to threads-1);
        cpl_spr_dbcr0_edm                       :out std_ulogic_vector(0 to threads-1);
        spr_dbcr0_icmp                          :in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_brt                           :in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_trap                          :in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_ret                           :in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_irpt                          :in  std_ulogic_vector(0 to threads-1);
        spr_epcr_dsigs                          :in  std_ulogic_vector(0 to threads-1);
        spr_epcr_isigs                          :in  std_ulogic_vector(0 to threads-1);
        spr_epcr_extgs                          :in  std_ulogic_vector(0 to threads-1);
        spr_epcr_dtlbgs                         :in  std_ulogic_vector(0 to threads-1);
        spr_epcr_itlbgs                         :in  std_ulogic_vector(0 to threads-1);
        spr_xucr4_div_barr_thres                :out std_ulogic_vector(0 to 7);
        spr_ccr0_we                             :in  std_ulogic_vector(0 to threads-1);
        cpl_msr_gs                              :out std_ulogic_vector(0 to threads-1);
        cpl_msr_pr                              :out std_ulogic_vector(0 to threads-1);
        cpl_msr_fp                              :out std_ulogic_vector(0 to threads-1);
        cpl_msr_spv                             :out std_ulogic_vector(0 to threads-1);
        cpl_ccr2_ap                             :out std_ulogic_vector(0 to threads-1);
        spr_xucr0_clkg_ctl                      :in  std_ulogic_vector(1 to 3);
        spr_xucr4_mmu_mchk                      :out std_ulogic;

        spr_cpl_ex3_sprg_ce                     :in  std_ulogic;
        spr_cpl_ex3_sprg_ue                     :in  std_ulogic;
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
        xu_pc_err_sprg_ue                       :out std_ulogic_vector(0 to threads-1);

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
        xu_rf1_is_eratsrx                       :out std_ulogic;
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

        xu_lsu_mtspr_trace_en                   :in  std_ulogic_vector(0 to 3);
        xu_lsu_spr_xucr0_aflsta                 :in  std_ulogic;
        xu_lsu_spr_xucr0_flsta                  :in  std_ulogic;
        xu_lsu_spr_xucr0_l2siw                  :in  std_ulogic;
        xu_lsu_spr_xucr0_dcdis                  :in  std_ulogic;
        xu_lsu_spr_xucr0_wlk                    :in  std_ulogic;
        xu_lsu_spr_xucr0_clfc                   :in  std_ulogic;
        xu_lsu_spr_xucr0_flh2l2                 :in  std_ulogic;
        xu_lsu_spr_xucr0_cred                   :in  std_ulogic;
        xu_lsu_spr_xucr0_rel                    :in  std_ulogic;
        xu_lsu_spr_xucr0_mbar_ack               :in  std_ulogic;
        xu_lsu_spr_xucr0_tlbsync                :in  std_ulogic;                        
        xu_lsu_spr_xucr0_cls                    :in  std_ulogic;                        
        xu_lsu_spr_ccr2_dfrat                   :in  std_ulogic;
        xu_lsu_spr_ccr2_dfratsc                 :in  std_ulogic_vector(0 to 8);

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

        xu_lsu_slowspr_val                      :in  std_ulogic;
        xu_lsu_slowspr_rw                       :in  std_ulogic;
        xu_lsu_slowspr_etid                     :in  std_ulogic_vector(0 to 1);
        xu_lsu_slowspr_addr                     :in  std_ulogic_vector(0 to 9);
        xu_lsu_slowspr_data                     :in  std_ulogic_vector(64-(2**REGMODE) to 63);
        xu_lsu_slowspr_done                     :in  std_ulogic;
        slowspr_val_out                         :out std_ulogic;
        slowspr_rw_out                          :out std_ulogic;
        slowspr_etid_out                        :out std_ulogic_vector(0 to 1);
        slowspr_addr_out                        :out std_ulogic_vector(0 to 9);
        slowspr_data_out                        :out std_ulogic_vector(64-(2**REGMODE) to 63);
        slowspr_done_out                        :out std_ulogic;

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
                                               
        lsu_xu_spr_xucr0_cslc_xuop              :out std_ulogic;                        
        lsu_xu_spr_xucr0_cslc_binv              :out std_ulogic;                        
        lsu_xu_spr_xucr0_clo                    :out std_ulogic;                        
        lsu_xu_spr_xucr0_cul                    :out std_ulogic;                        
        lsu_xu_spr_epsc_epr                     :out std_ulogic_vector(0 to 3);
        lsu_xu_spr_epsc_egs                     :out std_ulogic_vector(0 to 3);
                                               
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

        xu_iu_stcx_complete                     : out   std_ulogic_vector(0 to 3);
     xu_iu_reld_core_tag_clone     :out     std_ulogic_vector(1 to 4);
     xu_iu_reld_data_coming_clone  :out     std_ulogic;
     xu_iu_reld_data_vld_clone     :out     std_ulogic;
     xu_iu_reld_ditc_clone         :out     std_ulogic;


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
        lsu_xu_quiesce                          :out std_ulogic_vector(0 to 3);
        lsu_xu_dbell_val                        :out std_ulogic;
        lsu_xu_dbell_type                       :out std_ulogic_vector(0 to 4);
        lsu_xu_dbell_brdcast                    :out std_ulogic;
        lsu_xu_dbell_lpid_match                 :out std_ulogic;
        lsu_xu_dbell_pirtag                     :out std_ulogic_vector(50 to 63);
                                               
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

        lsu_xu_cmd_debug                        :out  std_ulogic_vector(0 to 175);

        an_ac_lbist_ary_wrt_thru_dc             :in  std_ulogic;
        pc_xu_abist_g8t_wenb                    :in  std_ulogic;
        pc_xu_abist_g8t1p_renb_0                :in  std_ulogic;
        pc_xu_abist_g8t_bw_1                    :in  std_ulogic;
        pc_xu_abist_g8t_bw_0                    :in  std_ulogic;
        pc_xu_abist_wl32_comp_ena               :in  std_ulogic;
        pc_xu_abist_g8t_dcomp                   :in  std_ulogic_vector(0 to 3);
                                               
        vcs                                     :inout power_logic;
        vdd                                     :inout power_logic;
        gnd                                     :inout power_logic;
        nclk                                    :in  clk_logic;
        an_ac_coreid                            :in std_ulogic_vector(6 to 7);
        an_ac_atpg_en_dc                        :in  std_ulogic;
                                               
        ccfg_scan_in                            :in  std_ulogic;
        ccfg_scan_out                           :out std_ulogic;
        regf_scan_in                            :in  std_ulogic_vector(0 to 6);
        regf_scan_out                           :out std_ulogic_vector(0 to 6); 
        abst_scan_in                            :in  std_ulogic;
        abst_scan_out                           :out std_ulogic;
        repr_scan_in                            :in  std_ulogic;
        repr_scan_out                           :out std_ulogic
);

-- synopsys translate_off


-- synopsys translate_on
end xuq_ctrl;
architecture xuq_ctrl of xuq_ctrl is

signal clkoff_dc_b_b	                   :std_ulogic;	
signal d_mode_dc_b                               :std_ulogic;
signal delay_lclkr_dc_b                          :std_ulogic_vector(0 to 4);
signal mpw1_dc_b_b                               :std_ulogic_vector(0 to 4);
signal mpw2_dc_b_b                               :std_ulogic;
signal sg_2_b                                    :std_ulogic_vector(0 to 3);
signal fce_2_b                                   :std_ulogic_vector(0 to 1);
signal func_sl_thold_2_b                         :std_ulogic_vector(0 to 3);
signal func_slp_sl_thold_2_b                     :std_ulogic_vector(0 to 1);
signal func_nsl_thold_2_b                        :std_ulogic;
signal func_slp_nsl_thold_2_b                    :std_ulogic;
signal time_sl_thold_2_b                         :std_ulogic;
signal repr_sl_thold_2_b                         :std_ulogic;
signal cfg_slp_sl_thold_2_b                      :std_ulogic;
signal regf_slp_sl_thold_2_b                     :std_ulogic;
signal bolt_sl_thold_2_b                         : std_ulogic;
signal bo_enable_2_b                             : std_ulogic;

signal cam_clkoff_dc_b                     :std_ulogic;
signal cam_d_mode_dc                       :std_ulogic;
signal cam_act_dis_dc                      :std_ulogic;
signal cam_delay_lclkr_dc                  :std_ulogic_vector(0 to 4);
signal cam_mpw1_dc_b                       :std_ulogic_vector(0 to 4);
signal cam_mpw2_dc_b                       :std_ulogic;
signal xu_lsu_rf0_act                      :std_ulogic;
signal xu_lsu_rf1_cache_acc                :std_ulogic;
signal xu_lsu_rf1_thrd_id                  :std_ulogic_vector(0 to threads-1);
signal xu_lsu_rf1_optype1                  :std_ulogic;
signal xu_lsu_rf1_optype2                  :std_ulogic;
signal xu_lsu_rf1_optype4                  :std_ulogic;
signal xu_lsu_rf1_optype8                  :std_ulogic;
signal xu_lsu_rf1_optype16                 :std_ulogic;
signal xu_lsu_rf1_optype32                 :std_ulogic;
signal xu_lsu_rf1_target_gpr               :std_ulogic_vector(0 to 8);
signal xu_lsu_rf1_load_instr               :std_ulogic;
signal xu_lsu_rf1_store_instr              :std_ulogic;
signal xu_lsu_rf1_dcbf_instr               :std_ulogic;
signal xu_lsu_rf1_sync_instr               :std_ulogic;
signal xu_lsu_rf1_mbar_instr               :std_ulogic;
signal xu_lsu_rf1_l_fld                    :std_ulogic_vector(0 to 1);
signal xu_lsu_rf1_dcbi_instr               :std_ulogic;
signal xu_lsu_rf1_dcbz_instr               :std_ulogic;
signal xu_lsu_rf1_dcbt_instr               :std_ulogic;
signal xu_lsu_rf1_dcbtst_instr             :std_ulogic;
signal xu_lsu_rf1_th_fld                   :std_ulogic_vector(0 to 4);
signal xu_lsu_rf1_dcbtls_instr             :std_ulogic;
signal xu_lsu_rf1_dcbtstls_instr           :std_ulogic;
signal xu_lsu_rf1_dcblc_instr              :std_ulogic;
signal xu_lsu_rf1_dcbst_instr              :std_ulogic;
signal xu_lsu_rf1_icbi_instr               :std_ulogic;
signal xu_lsu_rf1_icblc_instr              :std_ulogic;
signal xu_lsu_rf1_icbt_instr               :std_ulogic;
signal xu_lsu_rf1_icbtls_instr             :std_ulogic;
signal xu_lsu_rf1_tlbsync_instr            :std_ulogic;
signal xu_lsu_rf1_lock_instr               :std_ulogic;
signal xu_lsu_rf1_mutex_hint               :std_ulogic;
signal xu_lsu_rf1_axu_op_val               :std_ulogic;
signal xu_lsu_rf1_axu_ldst_falign_int      :std_ulogic;
signal xu_lsu_rf1_axu_ldst_fexcpt          :std_ulogic;
signal xu_lsu_rf1_algebraic                :std_ulogic;
signal xu_lsu_rf1_byte_rev                 :std_ulogic;
signal xu_lsu_rf1_src_gpr                  :std_ulogic;
signal xu_lsu_rf1_src_axu                  :std_ulogic;
signal xu_lsu_rf1_src_dp                   :std_ulogic;
signal xu_lsu_rf1_targ_gpr                 :std_ulogic;
signal xu_lsu_rf1_targ_axu                 :std_ulogic;
signal xu_lsu_rf1_targ_dp                  :std_ulogic;
signal xu_lsu_ex4_val                      :std_ulogic_vector(0 to 3);         
signal xu_lsu_rf1_derat_act                :std_ulogic;
signal xu_lsu_rf1_derat_is_load            :std_ulogic;
signal xu_lsu_rf1_derat_is_store           :std_ulogic;
signal xu_lsu_rf1_src0_vld                 :std_ulogic;
signal xu_lsu_rf1_src0_reg                 :std_ulogic_vector(0 to 7);
signal xu_lsu_rf1_src1_vld                 :std_ulogic;
signal xu_lsu_rf1_src1_reg                 :std_ulogic_vector(0 to 7);
signal xu_lsu_rf1_targ_vld                 :std_ulogic;
signal xu_lsu_rf1_targ_reg                 :std_ulogic_vector(0 to 7);
signal xu_lsu_rf1_is_touch                 :std_ulogic;
signal xu_lsu_rf1_is_msgsnd                :std_ulogic;
signal xu_lsu_rf1_dci_instr                :std_ulogic;
signal xu_lsu_rf1_ici_instr                :std_ulogic;
signal xu_lsu_rf1_icswx_instr              :std_ulogic;
signal xu_lsu_rf1_icswx_dot_instr          :std_ulogic;
signal xu_lsu_rf1_icswx_epid               :std_ulogic;
signal xu_lsu_rf1_ldawx_instr              :std_ulogic;
signal xu_lsu_rf1_wclr_instr               :std_ulogic;
signal xu_lsu_rf1_wchk_instr               :std_ulogic;
signal xu_lsu_rf1_derat_ra_eq_ea           :std_ulogic;
signal xu_lsu_rf1_cmd_act                  :std_ulogic;
signal xu_lsu_rf1_mtspr_trace              :std_ulogic;
signal lsu_xu_ex5_wren                     :std_ulogic;                        
signal lsu_xu_rel_wren_int                 :std_ulogic;                        
signal lsu_xu_rel_ta_gpr_int               :std_ulogic_vector(0 to 7);         
signal xu_lsu_ex4_dvc1_en                  :std_ulogic;
signal xu_lsu_ex4_dvc2_en                  :std_ulogic;
signal xu_lsu_ex1_add_src0                 :std_ulogic_vector(64-regsize to 63);
signal xu_lsu_ex1_add_src1                 :std_ulogic_vector(64-regsize to 63);
signal xu_rf1_is_eratre_int                :std_ulogic;
signal xu_rf1_is_eratwe_int                :std_ulogic;
signal xu_rf1_is_eratsx_int                :std_ulogic;
signal xu_rf1_is_eratsrx_int               :std_ulogic;
signal xu_rf1_is_eratilx_int               :std_ulogic;
signal xu_rf1_is_erativax_int              :std_ulogic;
signal xu_ex1_is_isync_int                 :std_ulogic;
signal xu_ex1_is_csync_int                 :std_ulogic;
signal xu_rf1_ws_int                       :std_ulogic_vector(0 to 1);
signal xu_rf1_t_int                        :std_ulogic_vector(0 to 2);
signal xu_ex1_rs_is_int                    :std_ulogic_vector(0 to 8);
signal xu_ex1_ra_entry_int                 :std_ulogic_vector(7 to 11);
signal lsu_xu_ex4_tlb_data                 :std_ulogic_vector(64-(2**regmode) to 63);
signal lsu_xu_is2_back_inv                 :std_ulogic;
signal lsu_xu_is2_back_inv_addr            :std_ulogic_vector(64-real_data_add to 63-cl_size);
signal lsu_xu_ex4_cr_upd                   :std_ulogic;
signal lsu_xu_ex5_cr_rslt                  :std_ulogic;
signal lsu_xu_ex3_derat_par_err            :std_ulogic_vector(0 to threads-1);
signal lsu_xu_ex3_derat_multihit_err       :std_ulogic_vector(0 to threads-1);
signal lsu_xu_ex3_l2_uc_ecc_err            :std_ulogic_vector(0 to 3);
signal lsu_xu_ex3_ddir_par_err             :std_ulogic;
signal lsu_xu_ex4_n_lsu_ddmh_flush         :std_ulogic_vector(0 to threads-1);
signal lsu_xu_ex3_dsi                      :std_ulogic_vector(0 to threads-1);
signal derat_xu_ex3_dsi                    :std_ulogic_vector(0 to threads-1);
signal lsu_xu_ex3_align                    :std_ulogic_vector(0 to threads-1);
signal derat_xu_ex3_miss                   :std_ulogic_vector(0 to threads-1);
signal lsu_xu_l2_ecc_err_flush             :std_ulogic_vector(0 to threads-1);
signal lsu_xu_datc_perr_recovery           :std_ulogic;
signal lsu_xu_ex3_dep_flush                :std_ulogic;
signal lsu_xu_ex3_n_flush_req              :std_ulogic;
signal lsu_xu_ex3_ldq_hit_flush            :std_ulogic;
signal lsu_xu_ex4_ldq_full_flush           :std_ulogic;
signal derat_xu_ex3_n_flush_req            :std_ulogic_vector(0 to threads-1);
signal lsu_xu_ex3_inval_align_2ucode       :std_ulogic;
signal lsu_xu_ex3_attr                     :std_ulogic_vector(0 to 8);
signal lsu_xu_ex3_derat_vf                 :std_ulogic;
signal xu_lsu_ex4_flush_local_int          :std_ulogic_vector(0 to 3);       
signal xu_lsu_dci                          :std_ulogic;
signal xu_rf0_flush                        :std_ulogic_vector(0 to threads-1);
signal xu_rf1_flush                        :std_ulogic_vector(0 to threads-1);
signal xu_ex1_flush                        :std_ulogic_vector(0 to threads-1);
signal xu_ex2_flush                        :std_ulogic_vector(0 to threads-1);
signal xu_ex3_flush                        :std_ulogic_vector(0 to threads-1);
signal xu_ex4_flush                        :std_ulogic_vector(0 to threads-1);
signal bcfg_scan_out_int                   :std_ulogic;
signal ccfg_scan_out_int                   :std_ulogic;
signal dcfg_scan_out_int                   :std_ulogic;
signal xu_ex4_rs_data_int                  :std_ulogic_vector(64-(2**regmode) to 63);
signal xu_lsu_ex5_set_barr                 :std_ulogic_vector(0 to threads-1);
signal xu_ex1_eff_addr_int                 :std_ulogic_vector(64-(dc_size-3) to 63);
signal lsu_xu_ex4_derat_par_err            :std_ulogic_vector(0 to 3);
signal fxu_trigger_data_in                 :std_ulogic_vector(0 to 11);
signal fxu_debug_data_in                   :std_ulogic_vector(0 to 87);
signal fxu_trigger_data_out                :std_ulogic_vector(0 to 11);
signal fxu_debug_data_out                  :std_ulogic_vector(0 to 87);
signal cpl_debug_data_in                   :std_ulogic_vector(0 to 87);
signal cpl_debug_data_out                  :std_ulogic_vector(0 to 87);
signal cpl_trigger_data_in                 :std_ulogic_vector(0 to 11);
signal cpl_trigger_data_out                :std_ulogic_vector(0 to 11);
signal lsu_trigger_data_in                 :std_ulogic_vector(0 to 11);
signal lsu_debug_data_in                   :std_ulogic_vector(0 to 87);
signal lsu_trigger_data_out                :std_ulogic_vector(0 to 11);
signal lsu_debug_data_out                  :std_ulogic_vector(0 to 87);
signal ary_slp_nsl_thold_2                 :std_ulogic;
signal abst_slp_sl_thold_2                 :std_ulogic;
signal xu_n_ex5_flush_int                  :std_ulogic_vector(0 to threads-1);
signal lsu_xu_need_hole                    :std_ulogic;
signal xu_lsu_ex2_instr_trace_val          :std_ulogic;
signal g8t_clkoff_dc_b                     :std_ulogic;
signal g8t_d_mode_dc                       :std_ulogic;
signal g8t_delay_lclkr_dc                  :std_ulogic_vector(0 to 4);
signal g8t_mpw1_dc_b                       :std_ulogic_vector(0 to 4);
signal g8t_mpw2_dc_b                       :std_ulogic;
signal spr_xucr4_mmu_mchk_int              :std_ulogic;  


begin

xu_n_ex5_flush      <= xu_n_ex5_flush_int;
spr_xucr4_mmu_mchk  <= spr_xucr4_mmu_mchk_int;

fxu_trigger_data_in  <= ctrl_trigger_data_in;
fxu_debug_data_in    <= ctrl_debug_data_in;
cpl_debug_data_in    <= fxu_debug_data_out;
cpl_trigger_data_in  <= fxu_trigger_data_out;
lsu_debug_data_in    <= cpl_debug_data_out;
lsu_trigger_data_in  <= cpl_trigger_data_out;
ctrl_debug_data_out  <= lsu_debug_data_out;
ctrl_trigger_data_out<= lsu_trigger_data_out;

clkoff_dc_b <= clkoff_dc_b_b;
d_mode_dc <= d_mode_dc_b;
delay_lclkr_dc <= delay_lclkr_dc_b;
mpw1_dc_b <= mpw1_dc_b_b;
mpw2_dc_b <= mpw2_dc_b_b;
sg_2 <= sg_2_b;
fce_2 <= fce_2_b;
func_sl_thold_2 <= func_sl_thold_2_b;
func_slp_sl_thold_2 <= func_slp_sl_thold_2_b;
func_nsl_thold_2 <= func_nsl_thold_2_b;
func_slp_nsl_thold_2 <= func_slp_nsl_thold_2_b;
time_sl_thold_2 <= time_sl_thold_2_b;
repr_sl_thold_2 <= repr_sl_thold_2_b;
cfg_slp_sl_thold_2 <= cfg_slp_sl_thold_2_b;
regf_slp_sl_thold_2 <= regf_slp_sl_thold_2_b;
bolt_sl_thold_2 <= bolt_sl_thold_2_b;
bo_enable_2 <= bo_enable_2_b;

    xuq_cpl_fxub : entity work.xuq_cpl_fxub(xuq_cpl_fxub)
    generic map(
        expand_type                         => expand_type,
        threads                             => threads,
        eff_ifar                            => eff_ifar,
        regmode                             => regmode,
        regsize                             => regsize,
        hvmode                              => hvmode,
        dc_size                             => dc_size,
        cl_size                             => cl_size,
        real_data_add                       => real_data_add,
        uc_ifar                             => uc_ifar,
        fxu_synth                           => fxu_synth,
        a2mode                              => a2mode)
    port map(
        nclk                            => nclk,
        vdd                             => vdd,
        gnd                             => gnd,
        vcs                             => vcs,

        func_scan_in                        => func_scan_in(50 to 58),
        func_scan_out                       => func_scan_out(50 to 58),
        an_ac_scan_dis_dc_b                 => an_ac_scan_dis_dc_b,
        pc_xu_ccflush_dc                    => pc_xu_ccflush_dc,
        clkoff_dc_b                         => clkoff_dc_b_b,
        d_mode_dc                           => d_mode_dc_b,
        delay_lclkr_dc                      => delay_lclkr_dc_b,
        mpw1_dc_b                           => mpw1_dc_b_b,
        mpw2_dc_b                           => mpw2_dc_b_b,
        g6t_clkoff_dc_b                     => g6t_clkoff_dc_b,
        g6t_d_mode_dc                       => g6t_d_mode_dc,
        g6t_delay_lclkr_dc                  => g6t_delay_lclkr_dc,
        g6t_mpw1_dc_b                       => g6t_mpw1_dc_b,
        g6t_mpw2_dc_b                       => g6t_mpw2_dc_b,
        g8t_clkoff_dc_b                     => g8t_clkoff_dc_b,
        g8t_d_mode_dc                       => g8t_d_mode_dc,
        g8t_delay_lclkr_dc                  => g8t_delay_lclkr_dc,
        g8t_mpw1_dc_b                       => g8t_mpw1_dc_b,
        g8t_mpw2_dc_b                       => g8t_mpw2_dc_b,
        cam_clkoff_dc_b                     => cam_clkoff_dc_b,
        cam_d_mode_dc                       => cam_d_mode_dc,
        cam_delay_lclkr_dc                  => cam_delay_lclkr_dc,
        cam_act_dis_dc                      => cam_act_dis_dc,
        cam_mpw1_dc_b                       => cam_mpw1_dc_b,
        cam_mpw2_dc_b                       => cam_mpw2_dc_b,
        pc_xu_sg_3                          => pc_xu_sg_3,
        pc_xu_func_sl_thold_3               => pc_xu_func_sl_thold_3,
        pc_xu_func_slp_sl_thold_3           => pc_xu_func_slp_sl_thold_3,
        pc_xu_func_nsl_thold_3              => pc_xu_func_nsl_thold_3,
        pc_xu_func_slp_nsl_thold_3          => pc_xu_func_slp_nsl_thold_3,
        pc_xu_gptr_sl_thold_3               => pc_xu_gptr_sl_thold_3,
        pc_xu_abst_sl_thold_3               => pc_xu_abst_sl_thold_3,
        pc_xu_abst_slp_sl_thold_3           => pc_xu_abst_slp_sl_thold_3,
        pc_xu_regf_sl_thold_3               => pc_xu_regf_sl_thold_3,
        pc_xu_regf_slp_sl_thold_3           => pc_xu_regf_slp_sl_thold_3,
        pc_xu_time_sl_thold_3               => pc_xu_time_sl_thold_3,
        pc_xu_cfg_sl_thold_3                => pc_xu_cfg_sl_thold_3,
        pc_xu_cfg_slp_sl_thold_3            => pc_xu_cfg_slp_sl_thold_3,
        pc_xu_ary_nsl_thold_3               => pc_xu_ary_nsl_thold_3,
        pc_xu_ary_slp_nsl_thold_3           => pc_xu_ary_slp_nsl_thold_3,
        pc_xu_repr_sl_thold_3               => pc_xu_repr_sl_thold_3,
        pc_xu_fce_3                         => pc_xu_fce_3,
        pc_xu_bolt_sl_thold_3               => pc_xu_bolt_sl_thold_3,
        pc_xu_bo_enable_3                   => pc_xu_bo_enable_3,
        bolt_sl_thold_2                     => bolt_sl_thold_2_b,
        bo_enable_2                         => bo_enable_2_b,
        an_ac_scan_diag_dc                  => an_ac_scan_diag_dc,
        sg_2                                => sg_2_b,
        fce_2                               => fce_2_b,
        func_sl_thold_2                     => func_sl_thold_2_b,
        func_slp_sl_thold_2                 => func_slp_sl_thold_2_b,
        func_nsl_thold_2                    => func_nsl_thold_2_b,
        func_slp_nsl_thold_2                => func_slp_nsl_thold_2_b,
        abst_sl_thold_2                     => abst_sl_thold_2,
        abst_slp_sl_thold_2                 => abst_slp_sl_thold_2,
        time_sl_thold_2                     => time_sl_thold_2_b,
        gptr_sl_thold_2                     => gptr_sl_thold_2,
        ary_nsl_thold_2                     => ary_nsl_thold_2,
        ary_slp_nsl_thold_2                 => ary_slp_nsl_thold_2,
        repr_sl_thold_2                     => repr_sl_thold_2_b,
        cfg_sl_thold_2                      => cfg_sl_thold_2,
        cfg_slp_sl_thold_2                  => cfg_slp_sl_thold_2_b,
        regf_slp_sl_thold_2                 => regf_slp_sl_thold_2_b,
        gptr_scan_in                        => gptr_scan_in,
        gptr_scan_out                       => gptr_scan_out,
        fxa_fxb_rf0_val                     => fxa_fxb_rf0_val,
        fxa_fxb_rf0_issued                  => fxa_fxb_rf0_issued,
        fxa_fxb_rf0_ucode_val               => fxa_fxb_rf0_ucode_val,
        fxa_fxb_rf0_act                     => fxa_fxb_rf0_act,
        fxa_fxb_ex1_hold_ctr_flush          => fxa_fxb_ex1_hold_ctr_flush,
        fxa_fxb_rf0_instr                   => fxa_fxb_rf0_instr,
        fxa_fxb_rf0_tid                     => fxa_fxb_rf0_tid,
        fxa_fxb_rf0_ta_vld                  => fxa_fxb_rf0_ta_vld,
        fxa_fxb_rf0_ta                      => fxa_fxb_rf0_ta,
        fxa_fxb_rf0_error                   => fxa_fxb_rf0_error,
        fxa_fxb_rf0_match                   => fxa_fxb_rf0_match,
        fxa_fxb_rf0_is_ucode                => fxa_fxb_rf0_is_ucode,
        fxa_fxb_rf0_gshare                  => fxa_fxb_rf0_gshare,
        fxa_fxb_rf0_ifar                    => fxa_fxb_rf0_ifar,
        fxa_fxb_rf0_s1_vld                  => fxa_fxb_rf0_s1_vld,
        fxa_fxb_rf0_s1                      => fxa_fxb_rf0_s1,
        fxa_fxb_rf0_s2_vld                  => fxa_fxb_rf0_s2_vld,
        fxa_fxb_rf0_s2                      => fxa_fxb_rf0_s2,
        fxa_fxb_rf0_s3_vld                  => fxa_fxb_rf0_s3_vld,
        fxa_fxb_rf0_s3                      => fxa_fxb_rf0_s3,
        fxa_fxb_rf0_axu_instr_type          => fxa_fxb_rf0_axu_instr_type,
        fxa_fxb_rf0_axu_ld_or_st            => fxa_fxb_rf0_axu_ld_or_st,
        fxa_fxb_rf0_axu_store               => fxa_fxb_rf0_axu_store,
        fxa_fxb_rf0_axu_ldst_forcealign     => fxa_fxb_rf0_axu_ldst_forcealign,
        fxa_fxb_rf0_axu_ldst_forceexcept    => fxa_fxb_rf0_axu_ldst_forceexcept,
        fxa_fxb_rf0_axu_ldst_indexed        => fxa_fxb_rf0_axu_ldst_indexed,
        fxa_fxb_rf0_axu_ldst_tag            => fxa_fxb_rf0_axu_ldst_tag,
        fxa_fxb_rf0_axu_mftgpr              => fxa_fxb_rf0_axu_mftgpr,
        fxa_fxb_rf0_axu_mffgpr              => fxa_fxb_rf0_axu_mffgpr,
        fxa_fxb_rf0_axu_movedp              => fxa_fxb_rf0_axu_movedp,
        fxa_fxb_rf0_axu_ldst_size           => fxa_fxb_rf0_axu_ldst_size,
        fxa_fxb_rf0_axu_ldst_update         => fxa_fxb_rf0_axu_ldst_update,
        fxa_fxb_rf0_pred_update             => fxa_fxb_rf0_pred_update,
        fxa_fxb_rf0_pred_taken_cnt          => fxa_fxb_rf0_pred_taken_cnt,
        fxa_fxb_rf0_mc_dep_chk_val          => fxa_fxb_rf0_mc_dep_chk_val,
        fxa_fxb_rf1_mul_val                 => fxa_fxb_rf1_mul_val,
        fxa_fxb_rf1_div_val                 => fxa_fxb_rf1_div_val,
        fxa_fxb_rf1_div_ctr                 => fxa_fxb_rf1_div_ctr,
        fxa_fxb_rf0_xu_epid_instr           => fxa_fxb_rf0_xu_epid_instr,
        fxa_fxb_rf0_axu_is_extload          => fxa_fxb_rf0_axu_is_extload,
        fxa_fxb_rf0_axu_is_extstore         => fxa_fxb_rf0_axu_is_extstore,
        fxa_fxb_rf0_is_mfocrf               => fxa_fxb_rf0_is_mfocrf,
        fxa_fxb_rf0_3src_instr              => fxa_fxb_rf0_3src_instr,
        fxa_fxb_rf0_gpr0_zero               => fxa_fxb_rf0_gpr0_zero,
        fxa_fxb_rf0_use_imm                 => fxa_fxb_rf0_use_imm,
        fxa_fxb_rf1_muldiv_coll             => fxa_fxb_rf1_muldiv_coll,
        fxa_cpl_ex2_div_coll                => fxa_cpl_ex2_div_coll,  
        fxb_fxa_ex7_we0                     => fxb_fxa_ex7_we0,
        fxb_fxa_ex7_wa0                     => fxb_fxa_ex7_wa0,
        fxb_fxa_ex7_wd0                     => fxb_fxa_ex7_wd0,
        fxa_fxb_rf1_do0                     => fxa_fxb_rf1_do0,
        fxa_fxb_rf1_do1                     => fxa_fxb_rf1_do1,
        fxa_fxb_rf1_do2                     => fxa_fxb_rf1_do2,
        xu_lsu_rf0_act                      => xu_lsu_rf0_act,
        xu_lsu_rf1_cache_acc                => xu_lsu_rf1_cache_acc,
        xu_lsu_rf1_thrd_id                  => xu_lsu_rf1_thrd_id,
        xu_lsu_rf1_optype1                  => xu_lsu_rf1_optype1,
        xu_lsu_rf1_optype2                  => xu_lsu_rf1_optype2,
        xu_lsu_rf1_optype4                  => xu_lsu_rf1_optype4,
        xu_lsu_rf1_optype8                  => xu_lsu_rf1_optype8,
        xu_lsu_rf1_optype16                 => xu_lsu_rf1_optype16,
        xu_lsu_rf1_optype32                 => xu_lsu_rf1_optype32,
        xu_lsu_rf1_target_gpr               => xu_lsu_rf1_target_gpr,
        xu_lsu_rf1_load_instr               => xu_lsu_rf1_load_instr,
        xu_lsu_rf1_store_instr              => xu_lsu_rf1_store_instr,
        xu_lsu_rf1_dcbf_instr               => xu_lsu_rf1_dcbf_instr,
        xu_lsu_rf1_sync_instr               => xu_lsu_rf1_sync_instr,
        xu_lsu_rf1_mbar_instr               => xu_lsu_rf1_mbar_instr,
        xu_lsu_rf1_l_fld                    => xu_lsu_rf1_l_fld,
        xu_lsu_rf1_dcbi_instr               => xu_lsu_rf1_dcbi_instr,
        xu_lsu_rf1_dcbz_instr               => xu_lsu_rf1_dcbz_instr,
        xu_lsu_rf1_dcbt_instr               => xu_lsu_rf1_dcbt_instr,
        xu_lsu_rf1_dcbtst_instr             => xu_lsu_rf1_dcbtst_instr,
        xu_lsu_rf1_th_fld                   => xu_lsu_rf1_th_fld,
        xu_lsu_rf1_dcbtls_instr             => xu_lsu_rf1_dcbtls_instr,
        xu_lsu_rf1_dcbtstls_instr           => xu_lsu_rf1_dcbtstls_instr,
        xu_lsu_rf1_dcblc_instr              => xu_lsu_rf1_dcblc_instr,
        xu_lsu_rf1_dcbst_instr              => xu_lsu_rf1_dcbst_instr,
        xu_lsu_rf1_icbi_instr               => xu_lsu_rf1_icbi_instr,
        xu_lsu_rf1_icblc_instr              => xu_lsu_rf1_icblc_instr,
        xu_lsu_rf1_icbt_instr               => xu_lsu_rf1_icbt_instr,
        xu_lsu_rf1_icbtls_instr             => xu_lsu_rf1_icbtls_instr,
        xu_lsu_rf1_tlbsync_instr            => xu_lsu_rf1_tlbsync_instr,
        xu_lsu_rf1_lock_instr               => xu_lsu_rf1_lock_instr,
        xu_lsu_rf1_mutex_hint               => xu_lsu_rf1_mutex_hint,
        xu_lsu_rf1_axu_op_val               => xu_lsu_rf1_axu_op_val,
        xu_lsu_rf1_axu_ldst_falign          => xu_lsu_rf1_axu_ldst_falign_int,
        xu_lsu_rf1_axu_ldst_fexcpt          => xu_lsu_rf1_axu_ldst_fexcpt,
        xu_lsu_ex1_store_data               => xu_lsu_ex1_store_data,
        xu_lsu_rf1_algebraic                => xu_lsu_rf1_algebraic,
        xu_lsu_rf1_byte_rev                 => xu_lsu_rf1_byte_rev,
        xu_lsu_rf1_src_gpr                  => xu_lsu_rf1_src_gpr,
        xu_lsu_rf1_src_axu                  => xu_lsu_rf1_src_axu,
        xu_lsu_rf1_src_dp                   => xu_lsu_rf1_src_dp,
        xu_lsu_rf1_targ_gpr                 => xu_lsu_rf1_targ_gpr,
        xu_lsu_rf1_targ_axu                 => xu_lsu_rf1_targ_axu,
        xu_lsu_rf1_targ_dp                  => xu_lsu_rf1_targ_dp,
        xu_lsu_ex4_val                      => xu_lsu_ex4_val,
        xu_lsu_ex1_rotsel_ovrd              => xu_lsu_ex1_rotsel_ovrd,
        xu_lsu_rf1_derat_act                => xu_lsu_rf1_derat_act,
        xu_lsu_rf1_derat_is_load            => xu_lsu_rf1_derat_is_load,
        xu_lsu_rf1_derat_is_store           => xu_lsu_rf1_derat_is_store,
        xu_lsu_rf1_src0_vld                 => xu_lsu_rf1_src0_vld,
        xu_lsu_rf1_src0_reg                 => xu_lsu_rf1_src0_reg,
        xu_lsu_rf1_src1_vld                 => xu_lsu_rf1_src1_vld,
        xu_lsu_rf1_src1_reg                 => xu_lsu_rf1_src1_reg,
        xu_lsu_rf1_targ_vld                 => xu_lsu_rf1_targ_vld,
        xu_lsu_rf1_targ_reg                 => xu_lsu_rf1_targ_reg,
        xu_bx_ex1_mtdp_val                  => xu_bx_ex1_mtdp_val,
        xu_bx_ex1_mfdp_val                  => xu_bx_ex1_mfdp_val,
        xu_bx_ex1_ipc_thrd                  => xu_bx_ex1_ipc_thrd,
        xu_bx_ex2_ipc_ba                    => xu_bx_ex2_ipc_ba,
        xu_bx_ex2_ipc_sz                    => xu_bx_ex2_ipc_sz,
        xu_lsu_rf1_is_touch                 => xu_lsu_rf1_is_touch,
        xu_lsu_rf1_is_msgsnd                => xu_lsu_rf1_is_msgsnd,
        xu_lsu_rf1_dci_instr                => xu_lsu_rf1_dci_instr,
        xu_lsu_rf1_ici_instr                => xu_lsu_rf1_ici_instr,
        xu_lsu_rf1_icswx_instr              => xu_lsu_rf1_icswx_instr,
        xu_lsu_rf1_icswx_dot_instr          => xu_lsu_rf1_icswx_dot_instr,
        xu_lsu_rf1_icswx_epid               => xu_lsu_rf1_icswx_epid,
        xu_lsu_rf1_ldawx_instr              => xu_lsu_rf1_ldawx_instr,
        xu_lsu_rf1_wclr_instr               => xu_lsu_rf1_wclr_instr,
        xu_lsu_rf1_wchk_instr               => xu_lsu_rf1_wchk_instr,
        xu_lsu_rf1_derat_ra_eq_ea           => xu_lsu_rf1_derat_ra_eq_ea,
        xu_lsu_rf1_cmd_act                  => xu_lsu_rf1_cmd_act,
        xu_lsu_rf1_data_act                 => xu_lsu_rf1_data_act,
        xu_lsu_rf1_mtspr_trace              => xu_lsu_rf1_mtspr_trace,
        lsu_xu_ex5_wren                     => lsu_xu_ex5_wren,
        lsu_xu_rel_wren                     => lsu_xu_rel_wren_int,
        lsu_xu_rel_ta_gpr                   => lsu_xu_rel_ta_gpr_int,
        lsu_xu_need_hole                    => lsu_xu_need_hole,
        lsu_xu_rot_ex6_data_b               => lsu_xu_rot_ex6_data_b,
        lsu_xu_rot_rel_data                 => lsu_xu_rot_rel_data,
        xu_lsu_ex4_dvc1_en                  => xu_lsu_ex4_dvc1_en,
        xu_lsu_ex4_dvc2_en                  => xu_lsu_ex4_dvc2_en,
        lsu_xu_ex2_dvc1_st_cmp              => lsu_xu_ex2_dvc1_st_cmp,
        lsu_xu_ex2_dvc2_st_cmp              => lsu_xu_ex2_dvc2_st_cmp,
        lsu_xu_ex8_dvc1_ld_cmp              => lsu_xu_ex8_dvc1_ld_cmp,
        lsu_xu_ex8_dvc2_ld_cmp              => lsu_xu_ex8_dvc2_ld_cmp,
        lsu_xu_rel_dvc1_en                  => lsu_xu_rel_dvc1_en,
        lsu_xu_rel_dvc2_en                  => lsu_xu_rel_dvc2_en,
        lsu_xu_rel_dvc_thrd_id              => lsu_xu_rel_dvc_thrd_id,
        lsu_xu_rel_dvc1_cmp                 => lsu_xu_rel_dvc1_cmp,
        lsu_xu_rel_dvc2_cmp                 => lsu_xu_rel_dvc2_cmp,
        xu_lsu_ex1_add_src0                 => xu_lsu_ex1_add_src0,
        xu_lsu_ex1_add_src1                 => xu_lsu_ex1_add_src1,
        xu_ex1_eff_addr_int                 => xu_ex1_eff_addr_int,
        xu_lsu_ex5_set_barr                 => xu_lsu_ex5_set_barr,
        cpl_fxa_ex5_set_barr                => cpl_fxa_ex5_set_barr,
        cpl_iu_set_barr_tid                  => cpl_iu_set_barr_tid,
        xu_iu_rf1_val                       => xu_iu_rf1_val,
        xu_rf1_val                          => xu_rf1_val,
        xu_rf1_is_tlbre                     => xu_rf1_is_tlbre,
        xu_rf1_is_tlbwe                     => xu_rf1_is_tlbwe,
        xu_rf1_is_tlbsx                     => xu_rf1_is_tlbsx,
        xu_rf1_is_tlbsrx                    => xu_rf1_is_tlbsrx,
        xu_rf1_is_tlbilx                    => xu_rf1_is_tlbilx,
        xu_rf1_is_tlbivax                   => xu_rf1_is_tlbivax,
        xu_rf1_is_eratre                    => xu_rf1_is_eratre_int,
        xu_rf1_is_eratwe                    => xu_rf1_is_eratwe_int,
        xu_rf1_is_eratsx                    => xu_rf1_is_eratsx_int,
        xu_rf1_is_eratsrx                   => xu_rf1_is_eratsrx_int,
        xu_rf1_is_eratilx                   => xu_rf1_is_eratilx_int,
        xu_rf1_is_erativax                  => xu_rf1_is_erativax_int,
        xu_ex1_is_isync                     => xu_ex1_is_isync_int,
        xu_ex1_is_csync                     => xu_ex1_is_csync_int,
        xu_rf1_ws                           => xu_rf1_ws_int,
        xu_rf1_t                            => xu_rf1_t_int,
        xu_ex1_rs_is                        => xu_ex1_rs_is_int,
        xu_ex1_ra_entry                     => xu_ex1_ra_entry_int,
        xu_ex1_rb                           => xu_ex1_rb,
        xu_ex2_eff_addr                     => xu_ex2_eff_addr,
        xu_ex4_rs_data                      => xu_ex4_rs_data_int,
        lsu_xu_ex4_tlb_data                 => lsu_xu_ex4_tlb_data,
        iu_xu_ex4_tlb_data                  => iu_xu_ex4_tlb_data,
        xu_mm_derat_epn                     => xu_mm_derat_epn,
        lsu_xu_is2_back_inv                 => lsu_xu_is2_back_inv,
        lsu_xu_is2_back_inv_addr            => lsu_xu_is2_back_inv_addr,
        mm_xu_mmucr0_0_tlbsel               => mm_xu_derat_mmucr0_0(4 to 5),
        mm_xu_mmucr0_1_tlbsel               => mm_xu_derat_mmucr0_1(4 to 5),
        mm_xu_mmucr0_2_tlbsel               => mm_xu_derat_mmucr0_2(4 to 5),
        mm_xu_mmucr0_3_tlbsel               => mm_xu_derat_mmucr0_3(4 to 5),
        xu_mm_rf1_is_tlbsxr                 => xu_mm_rf1_is_tlbsxr,
        mm_xu_cr0_eq_valid                  => mm_xu_cr0_eq_valid,
        mm_xu_cr0_eq                        => mm_xu_cr0_eq,
        fu_xu_ex4_cr_val                    => fu_xu_ex4_cr_val,
        fu_xu_ex4_cr_noflush                => fu_xu_ex4_cr_noflush,
        fu_xu_ex4_cr0                       => fu_xu_ex4_cr0,
        fu_xu_ex4_cr0_bf                    => fu_xu_ex4_cr0_bf,
        fu_xu_ex4_cr1                       => fu_xu_ex4_cr1,
        fu_xu_ex4_cr1_bf                    => fu_xu_ex4_cr1_bf,
        fu_xu_ex4_cr2                       => fu_xu_ex4_cr2,
        fu_xu_ex4_cr2_bf                    => fu_xu_ex4_cr2_bf,
        fu_xu_ex4_cr3                       => fu_xu_ex4_cr3,
        fu_xu_ex4_cr3_bf                    => fu_xu_ex4_cr3_bf,
        xu_pc_ram_data                      => xu_pc_ram_data,
        xu_iu_ex5_val                       => xu_iu_ex5_val,
        xu_iu_ex5_tid                       => xu_iu_ex5_tid,
        xu_iu_ex5_br_update                 => xu_iu_ex5_br_update,
        xu_iu_ex5_br_hist                   => xu_iu_ex5_br_hist,
        xu_iu_ex5_bclr                      => xu_iu_ex5_bclr,
        xu_iu_ex5_lk                        => xu_iu_ex5_lk,
        xu_iu_ex5_bh                        => xu_iu_ex5_bh,
        xu_iu_ex6_pri                       => xu_iu_ex6_pri,
        xu_iu_ex6_pri_val                   => xu_iu_ex6_pri_val,
        xu_iu_spr_xer                       => xu_iu_spr_xer,
        xu_iu_slowspr_done                  => xu_iu_slowspr_done,
        xu_iu_need_hole                     => xu_iu_need_hole,
        fxb_fxa_ex6_clear_barrier           => fxb_fxa_ex6_clear_barrier,
        xu_iu_ex5_gshare                    => xu_iu_ex5_gshare,
        xu_iu_ex5_getNIA                    => xu_iu_ex5_getNIA,
        an_ac_stcx_complete                 => an_ac_stcx_complete,
        an_ac_stcx_pass                     => an_ac_stcx_pass,

        an_ac_back_inv                      => an_ac_back_inv,
        an_ac_back_inv_addr                 => an_ac_back_inv_addr(58 to 63),
        an_ac_back_inv_target_bit3          => an_ac_back_inv_target_bit3,
        slowspr_val_in                      => slowspr_val_in,
        slowspr_rw_in                       => slowspr_rw_in,
        slowspr_etid_in                     => slowspr_etid_in,
        slowspr_addr_in                     => slowspr_addr_in,
        slowspr_data_in                     => slowspr_data_in,
        slowspr_done_in                     => slowspr_done_in,
        an_ac_dcr_act                       => an_ac_dcr_act,
        an_ac_dcr_val                       => an_ac_dcr_val,
        an_ac_dcr_read                      => an_ac_dcr_read,
        an_ac_dcr_etid                      => an_ac_dcr_etid,
        an_ac_dcr_data                      => an_ac_dcr_data,
        an_ac_dcr_done                      => an_ac_dcr_done,
        lsu_xu_ex4_mtdp_cr_status           => lsu_xu_ex4_mtdp_cr_status,
        lsu_xu_ex4_mfdp_cr_status           => lsu_xu_ex4_mfdp_cr_status,
        dec_cpl_ex3_mc_dep_chk_val          => dec_cpl_ex3_mc_dep_chk_val,
        lsu_xu_ex4_cr_upd                   => lsu_xu_ex4_cr_upd,
        lsu_xu_ex5_cr_rslt                  => lsu_xu_ex5_cr_rslt,
        dec_spr_ex4_val                     => dec_spr_ex4_val,
        dec_spr_ex1_epid_instr              => dec_spr_ex1_epid_instr,
        mux_spr_ex2_rt                      => mux_spr_ex2_rt,
        fxu_spr_ex1_rs0                     => fxu_spr_ex1_rs0,
        fxu_spr_ex1_rs1                     => fxu_spr_ex1_rs1,
        spr_msr_cm                          => spr_msr_cm,
        spr_dec_spr_xucr0_ssdly             => spr_dec_spr_xucr0_ssdly,
        spr_ccr2_en_attn                    => spr_ccr2_en_attn,
        spr_ccr2_en_ditc                    => spr_ccr2_en_ditc,
        spr_ccr2_en_pc                      => spr_ccr2_en_pc,
        spr_ccr2_en_icswx                   => spr_ccr2_en_icswx,
        spr_ccr2_en_dcr                     => spr_ccr2_en_dcr,
        spr_dec_rf1_epcr_dgtmi              => spr_dec_rf1_epcr_dgtmi,
        spr_dec_rf1_msr_ucle                => spr_msr_ucle,
        spr_dec_rf1_msrp_uclep              => spr_msrp_uclep,
        spr_byp_ex4_is_mfxer                => spr_byp_ex4_is_mfxer,
        spr_byp_ex3_spr_rt                  => spr_byp_ex3_spr_rt,
        spr_byp_ex4_is_mtxer                => spr_byp_ex4_is_mtxer,
        spr_ccr2_notlb                      => spr_ccr2_notlb,
        dec_spr_rf1_val                     => dec_spr_rf1_val,
        fxu_spr_ex1_rs2                     => fxu_spr_ex1_rs2,
        fxa_perf_muldiv_in_use              => fxa_perf_muldiv_in_use,
        spr_perf_tx_events                  => spr_perf_tx_events,
        xu_pc_event_data                    => xu_pc_event_data,
        pc_xu_event_bus_enable              => pc_xu_event_bus_enable,
        pc_xu_event_count_mode              => pc_xu_event_count_mode,
        pc_xu_event_mux_ctrls               => pc_xu_event_mux_ctrls,
        pc_xu_trace_bus_enable              => pc_xu_trace_bus_enable,
        pc_xu_instr_trace_mode              => pc_xu_instr_trace_mode,
        pc_xu_instr_trace_tid               => pc_xu_instr_trace_tid,
        xu_lsu_ex2_instr_trace_val          => xu_lsu_ex2_instr_trace_val,
        fxu_debug_mux_ctrls                 => fxu_debug_mux_ctrls,
        fxu_trigger_data_in                 => fxu_trigger_data_in,
        fxu_debug_data_in                   => fxu_debug_data_in,
        fxu_trigger_data_out                => fxu_trigger_data_out,
        fxu_debug_data_out                  => fxu_debug_data_out,
        lsu_xu_data_debug0                  => lsu_xu_data_debug0,
        lsu_xu_data_debug1                  => lsu_xu_data_debug1,
        lsu_xu_data_debug2                  => lsu_xu_data_debug2,
        spr_msr_gs                          => spr_msr_gs,
        spr_msr_ds                          => spr_msr_ds,
        spr_msr_pr                          => spr_msr_pr,
        spr_dbcr0_dac1                      => spr_dbcr0_dac1,
        spr_dbcr0_dac2                      => spr_dbcr0_dac2,
        spr_dbcr0_dac3                      => spr_dbcr0_dac3,
        spr_dbcr0_dac4                      => spr_dbcr0_dac4,
        spr_xucr4_mmu_mchk                  => spr_xucr4_mmu_mchk_int,
        ac_tc_debug_trigger                 => ac_tc_debug_trigger,
        bcfg_scan_in                        => bcfg_scan_in,
        bcfg_scan_out                       => bcfg_scan_out_int,
        ccfg_scan_in                        => ccfg_scan_in,
        ccfg_scan_out                       => ccfg_scan_out_int,
        dcfg_scan_in                        => dcfg_scan_in,
        dcfg_scan_out                       => dcfg_scan_out_int,
        dec_cpl_rf0_act                     => dec_cpl_rf0_act,
        dec_cpl_rf0_tid                     => dec_cpl_rf0_tid,
        fu_xu_rf1_act                       => fu_xu_rf1_act,
        fu_xu_ex1_ifar                      => fu_xu_ex1_ifar,
        fu_xu_ex2_ifar_val                  => fu_xu_ex2_ifar_val,
        fu_xu_ex2_ifar_issued               => fu_xu_ex2_ifar_issued,
        fu_xu_ex2_instr_type                => fu_xu_ex2_instr_type,
        fu_xu_ex2_instr_match               => fu_xu_ex2_instr_match,
        fu_xu_ex2_is_ucode                  => fu_xu_ex2_is_ucode,
        pc_xu_step                          => pc_xu_step,
        pc_xu_stop                          => pc_xu_stop,
        pc_xu_dbg_action                    => pc_xu_dbg_action,
        pc_xu_force_ude                     => pc_xu_force_ude,
        xu_pc_step_done                     => xu_pc_step_done,
        pc_xu_init_reset                    => pc_xu_init_reset,
        spr_cpl_ext_interrupt               => spr_cpl_ext_interrupt,
        spr_cpl_udec_interrupt              => spr_cpl_udec_interrupt,
        spr_cpl_perf_interrupt              => spr_cpl_perf_interrupt,
        spr_cpl_dec_interrupt               => spr_cpl_dec_interrupt,
        spr_cpl_fit_interrupt               => spr_cpl_fit_interrupt,
        spr_cpl_crit_interrupt              => spr_cpl_crit_interrupt,
        spr_cpl_wdog_interrupt              => spr_cpl_wdog_interrupt,
        spr_cpl_dbell_interrupt             => spr_cpl_dbell_interrupt,
        spr_cpl_cdbell_interrupt            => spr_cpl_cdbell_interrupt,
        spr_cpl_gdbell_interrupt            => spr_cpl_gdbell_interrupt,
        spr_cpl_gcdbell_interrupt           => spr_cpl_gcdbell_interrupt,
        spr_cpl_gmcdbell_interrupt          => spr_cpl_gmcdbell_interrupt,
        cpl_spr_ex5_dbell_taken             => cpl_spr_ex5_dbell_taken,
        cpl_spr_ex5_cdbell_taken            => cpl_spr_ex5_cdbell_taken,
        cpl_spr_ex5_gdbell_taken            => cpl_spr_ex5_gdbell_taken,
        cpl_spr_ex5_gcdbell_taken           => cpl_spr_ex5_gcdbell_taken,
        cpl_spr_ex5_gmcdbell_taken          => cpl_spr_ex5_gmcdbell_taken,
        cpl_spr_ex5_act                     => cpl_spr_ex5_act,
        cpl_spr_ex5_int                     => cpl_spr_ex5_int,
        cpl_spr_ex5_gint                    => cpl_spr_ex5_gint,
        cpl_spr_ex5_cint                    => cpl_spr_ex5_cint,
        cpl_spr_ex5_mcint                   => cpl_spr_ex5_mcint,
        cpl_spr_ex5_nia                     => cpl_spr_ex5_nia,
        cpl_spr_ex5_esr                     => cpl_spr_ex5_esr,
        cpl_spr_ex5_mcsr                    => cpl_spr_ex5_mcsr,
        cpl_spr_ex5_dbsr                    => cpl_spr_ex5_dbsr,
        cpl_spr_ex5_dear_save               => cpl_spr_ex5_dear_save,
        cpl_spr_ex5_dear_update_saved       => cpl_spr_ex5_dear_update_saved,
        cpl_spr_ex5_dear_update             => cpl_spr_ex5_dear_update,
        cpl_spr_ex5_dbsr_update             => cpl_spr_ex5_dbsr_update,
        cpl_spr_ex5_esr_update              => cpl_spr_ex5_esr_update,
        cpl_spr_ex5_srr0_dec                => cpl_spr_ex5_srr0_dec,
        cpl_spr_ex5_force_gsrr              => cpl_spr_ex5_force_gsrr,
        cpl_spr_ex5_dbsr_ide                => cpl_spr_ex5_dbsr_ide,
        spr_cpl_dbsr_ide                    => spr_cpl_dbsr_ide,
        mm_xu_local_snoop_reject            => mm_xu_local_snoop_reject,
        mm_xu_lru_par_err                   => mm_xu_lru_par_err,
        mm_xu_tlb_par_err                   => mm_xu_tlb_par_err,
        mm_xu_tlb_multihit_err              => mm_xu_tlb_multihit_err,
        lsu_xu_ex3_derat_par_err            => lsu_xu_ex3_derat_par_err,
        lsu_xu_ex4_derat_par_err            => lsu_xu_ex4_derat_par_err,
        lsu_xu_ex3_derat_multihit_err       => lsu_xu_ex3_derat_multihit_err,
        lsu_xu_ex3_l2_uc_ecc_err            => lsu_xu_ex3_l2_uc_ecc_err,
        lsu_xu_ex3_ddir_par_err             => lsu_xu_ex3_ddir_par_err,
        lsu_xu_ex4_n_lsu_ddmh_flush         => lsu_xu_ex4_n_lsu_ddmh_flush,
        lsu_xu_ex6_datc_par_err             => lsu_xu_ex6_datc_par_err,
        spr_cpl_external_mchk               => spr_cpl_external_mchk,
        xu_pc_err_attention_instr           => xu_pc_err_attention_instr,
        xu_pc_err_nia_miscmpr               => xu_pc_err_nia_miscmpr,
        xu_pc_err_debug_event               => xu_pc_err_debug_event,
        lsu_xu_ex3_dsi                      => lsu_xu_ex3_dsi,
        derat_xu_ex3_dsi                    => derat_xu_ex3_dsi,
        spr_cpl_ex3_ct_le                   => spr_cpl_ex3_ct_le,
        spr_cpl_ex3_ct_be                   => spr_cpl_ex3_ct_be,
        lsu_xu_ex3_align                    => lsu_xu_ex3_align,
        spr_cpl_ex3_spr_illeg               => spr_cpl_ex3_spr_illeg,
        spr_cpl_ex3_spr_priv                => spr_cpl_ex3_spr_priv,
        spr_cpl_ex3_spr_hypv                => spr_cpl_ex3_spr_hypv,
        derat_xu_ex3_miss                   => derat_xu_ex3_miss,
        pc_xu_ram_mode                      => pc_xu_ram_mode,
        pc_xu_ram_thread                    => pc_xu_ram_thread,
        pc_xu_ram_execute                   => pc_xu_ram_execute,
        xu_iu_ram_issue                     => xu_iu_ram_issue,
        xu_pc_ram_interrupt                 => xu_pc_ram_interrupt,
        xu_pc_ram_done                      => xu_pc_ram_done,
        pc_xu_ram_flush_thread              => pc_xu_ram_flush_thread,
        cpl_spr_stop                        => cpl_spr_stop,
        xu_pc_stop_dbg_event                => xu_pc_stop_dbg_event,
        cpl_spr_ex5_instr_cpl               => cpl_spr_ex5_instr_cpl,
        spr_cpl_quiesce                     => spr_cpl_quiesce,
        cpl_spr_quiesce                     => cpl_spr_quiesce,
        spr_cpl_ex2_run_ctl_flush           => spr_cpl_ex2_run_ctl_flush,
        mm_xu_illeg_instr                   => mm_xu_illeg_instr,
        mm_xu_tlb_miss                      => mm_xu_tlb_miss,
        mm_xu_pt_fault                      => mm_xu_pt_fault,
        mm_xu_tlb_inelig                    => mm_xu_tlb_inelig,
        mm_xu_lrat_miss                     => mm_xu_lrat_miss,
        mm_xu_hv_priv                       => mm_xu_hv_priv,
        mm_xu_esr_pt                        => mm_xu_esr_pt,
        mm_xu_esr_data                      => mm_xu_esr_data,
        mm_xu_esr_epid                      => mm_xu_esr_epid,
        mm_xu_esr_st                        => mm_xu_esr_st,
        mm_xu_hold_req                      => mm_xu_hold_req,
        mm_xu_hold_done                     => mm_xu_hold_done,
        xu_mm_hold_ack                      => xu_mm_hold_ack,
        mm_xu_eratmiss_done                 => mm_xu_eratmiss_done,
        mm_xu_ex3_flush_req                 => mm_xu_ex3_flush_req,
        lsu_xu_l2_ecc_err_flush             => lsu_xu_l2_ecc_err_flush,
        lsu_xu_datc_perr_recovery           => lsu_xu_datc_perr_recovery,
        lsu_xu_ex3_dep_flush                => lsu_xu_ex3_dep_flush,
        lsu_xu_ex3_n_flush_req              => lsu_xu_ex3_n_flush_req,
        lsu_xu_ex3_ldq_hit_flush            => lsu_xu_ex3_ldq_hit_flush,
        lsu_xu_ex4_ldq_full_flush           => lsu_xu_ex4_ldq_full_flush,
        derat_xu_ex3_n_flush_req            => derat_xu_ex3_n_flush_req,
        lsu_xu_ex3_inval_align_2ucode       => lsu_xu_ex3_inval_align_2ucode,
        lsu_xu_ex3_attr                     => lsu_xu_ex3_attr,
        lsu_xu_ex3_derat_vf                 => lsu_xu_ex3_derat_vf,
        fu_xu_ex3_ap_int_req                => fu_xu_ex3_ap_int_req,
        fu_xu_ex3_trap                      => fu_xu_ex3_trap,
        fu_xu_ex3_n_flush                   => fu_xu_ex3_n_flush,
        fu_xu_ex3_np1_flush                 => fu_xu_ex3_np1_flush,
        fu_xu_ex3_flush2ucode               => fu_xu_ex3_flush2ucode,
        fu_xu_ex2_async_block               => fu_xu_ex2_async_block,
        xu_iu_ex5_br_taken                  => xu_iu_ex5_br_taken,
        xu_iu_ex5_ifar                      => xu_iu_ex5_ifar,
        xu_iu_flush                         => xu_iu_flush,
        xu_iu_iu0_flush_ifar                => xu_iu_iu0_flush_ifar,
        xu_iu_uc_flush_ifar                 => xu_iu_uc_flush_ifar,
        xu_iu_flush_2ucode                  => xu_iu_flush_2ucode,
        xu_iu_flush_2ucode_type             => xu_iu_flush_2ucode_type,
        xu_iu_ucode_restart                 => xu_iu_ucode_restart,
        xu_iu_ex5_ppc_cpl                   => xu_iu_ex5_ppc_cpl,
        xu_rf0_flush                        => xu_rf0_flush,
        xu_rf1_flush                        => xu_rf1_flush,
        xu_ex1_flush                        => xu_ex1_flush,
        xu_ex2_flush                        => xu_ex2_flush,
        xu_ex3_flush                        => xu_ex3_flush,
        xu_ex4_flush                        => xu_ex4_flush,
        xu_n_is2_flush                      => xu_n_is2_flush,
        xu_n_rf0_flush                      => xu_n_rf0_flush,
        xu_n_rf1_flush                      => xu_n_rf1_flush,
        xu_n_ex1_flush                      => xu_n_ex1_flush,
        xu_n_ex2_flush                      => xu_n_ex2_flush,
        xu_n_ex3_flush                      => xu_n_ex3_flush,
        xu_n_ex4_flush                      => xu_n_ex4_flush,
        xu_n_ex5_flush                      => xu_n_ex5_flush_int,
        xu_s_rf1_flush                      => xu_s_rf1_flush,
        xu_s_ex1_flush                      => xu_s_ex1_flush,
        xu_s_ex2_flush                      => xu_s_ex2_flush,
        xu_s_ex3_flush                      => xu_s_ex3_flush,
        xu_s_ex4_flush                      => xu_s_ex4_flush,
        xu_s_ex5_flush                      => xu_s_ex5_flush,
        xu_w_rf1_flush                      => xu_w_rf1_flush,
        xu_w_ex1_flush                      => xu_w_ex1_flush,
        xu_w_ex2_flush                      => xu_w_ex2_flush,
        xu_w_ex3_flush                      => xu_w_ex3_flush,
        xu_w_ex4_flush                      => xu_w_ex4_flush,
        xu_w_ex5_flush                      => xu_w_ex5_flush,
        xu_lsu_ex4_flush_local              => xu_lsu_ex4_flush_local_int,
        xu_mm_ex4_flush                     => xu_mm_ex4_flush,
        xu_mm_ex5_flush                     => xu_mm_ex5_flush,
        xu_mm_ierat_flush                   => xu_mm_ierat_flush,
        xu_mm_ierat_miss                    => xu_mm_ierat_miss,
        xu_mm_ex5_perf_itlb                 => xu_mm_ex5_perf_itlb,
        xu_mm_ex5_perf_dtlb                 => xu_mm_ex5_perf_dtlb,
        spr_cpl_iac1_en                     => spr_cpl_iac1_en,
        spr_cpl_iac2_en                     => spr_cpl_iac2_en,
        spr_cpl_iac3_en                     => spr_cpl_iac3_en,
        spr_cpl_iac4_en                     => spr_cpl_iac4_en,
        spr_bit_act                         => spr_bit_act,
        spr_epcr_duvd                       => spr_epcr_duvd,
        spr_dbcr1_iac12m                    => spr_dbcr1_iac12m,
        spr_dbcr1_iac34m                    => spr_dbcr1_iac34m,
        spr_cpl_fp_precise                  => spr_cpl_fp_precise,
        spr_xucr0_mddp                      => spr_xucr0_mddp,
        spr_xucr0_mdcp                      => spr_xucr0_mdcp,
        spr_msr_de                          => spr_msr_de,
        spr_msr_spv                         => spr_msr_spv,
        spr_msr_fp                          => spr_msr_fp,
        spr_msr_me                          => spr_msr_me,
        spr_msr_ucle                        => spr_msr_ucle,
        spr_msrp_uclep                      => spr_msrp_uclep,
        spr_ccr2_ucode_dis                  => spr_ccr2_ucode_dis,
        spr_ccr2_ap                         => spr_ccr2_ap,
        spr_dbcr0_idm                       => spr_dbcr0_idm,
        cpl_spr_dbcr0_edm                   => cpl_spr_dbcr0_edm,
        spr_dbcr0_icmp                      => spr_dbcr0_icmp,
        spr_dbcr0_brt                       => spr_dbcr0_brt,
        spr_dbcr0_trap                      => spr_dbcr0_trap,
        spr_dbcr0_ret                       => spr_dbcr0_ret,
        spr_dbcr0_irpt                      => spr_dbcr0_irpt,
        spr_epcr_dsigs                      => spr_epcr_dsigs,
        spr_epcr_isigs                      => spr_epcr_isigs,
        spr_epcr_extgs                      => spr_epcr_extgs,
        spr_epcr_dtlbgs                     => spr_epcr_dtlbgs,
        spr_epcr_itlbgs                     => spr_epcr_itlbgs,
        spr_xucr4_div_barr_thres            => spr_xucr4_div_barr_thres,
        spr_ccr0_we                         => spr_ccr0_we,
        cpl_msr_gs                          => cpl_msr_gs,
        cpl_msr_pr                          => cpl_msr_pr,
        cpl_msr_fp                          => cpl_msr_fp,
        cpl_msr_spv                         => cpl_msr_spv,
        cpl_ccr2_ap                         => cpl_ccr2_ap,
        xu_lsu_ici                          => xu_lsu_ici,
        xu_lsu_dci                          => xu_lsu_dci,
        spr_xucr0_clkg_ctl                  => spr_xucr0_clkg_ctl(2 to 2),
        spr_cpl_ex3_sprg_ce                 => spr_cpl_ex3_sprg_ce,
        spr_cpl_ex3_sprg_ue                 => spr_cpl_ex3_sprg_ue,
        iu_xu_ierat_ex2_flush_req           => iu_xu_ierat_ex2_flush_req,
        iu_xu_ierat_ex3_par_err             => iu_xu_ierat_ex3_par_err,
        iu_xu_ierat_ex4_par_err             => iu_xu_ierat_ex4_par_err,
        fu_xu_ex3_regfile_err_det	    => fu_xu_ex3_regfile_err_det,
        xu_fu_regfile_seq_beg	            => xu_fu_regfile_seq_beg,
        fu_xu_regfile_seq_end	            => fu_xu_regfile_seq_end,
        gpr_cpl_ex3_regfile_err_det	    => gpr_cpl_ex3_regfile_err_det,
        cpl_gpr_regfile_seq_beg	            => cpl_gpr_regfile_seq_beg,
        gpr_cpl_regfile_seq_end	            => gpr_cpl_regfile_seq_end,
        xu_pc_err_mcsr_summary              => xu_pc_err_mcsr_summary,
        xu_pc_err_ditc_overrun              => xu_pc_err_ditc_overrun,
        xu_pc_err_local_snoop_reject        => xu_pc_err_local_snoop_reject,
        xu_pc_err_tlb_lru_parity            => xu_pc_err_tlb_lru_parity,
        xu_pc_err_ext_mchk                  => xu_pc_err_ext_mchk,
        xu_pc_err_ierat_multihit            => xu_pc_err_ierat_multihit,
        xu_pc_err_derat_multihit            => xu_pc_err_derat_multihit,
        xu_pc_err_tlb_multihit              => xu_pc_err_tlb_multihit,
        xu_pc_err_ierat_parity              => xu_pc_err_ierat_parity,
        xu_pc_err_derat_parity              => xu_pc_err_derat_parity,
        xu_pc_err_tlb_parity                => xu_pc_err_tlb_parity,
        xu_pc_err_mchk_disabled             => xu_pc_err_mchk_disabled,
        xu_pc_err_sprg_ue                   => xu_pc_err_sprg_ue,
        cpl_debug_mux_ctrls                 => cpl_debug_mux_ctrls,
        cpl_debug_data_in                   => cpl_debug_data_in,
        cpl_debug_data_out                  => cpl_debug_data_out,
        cpl_trigger_data_in                 => cpl_trigger_data_in,
        cpl_trigger_data_out                => cpl_trigger_data_out,
        fxa_cpl_debug                       => fxa_cpl_debug
    );

lsucmd : entity work.xuq_lsu_cmd(xuq_lsu_cmd)
generic map(expand_type      => expand_type,
            lmq_entries      => lmq_entries,
            l_endian_m       => l_endian_m,
            regmode          => regmode,
            dc_size          => dc_size,
            cl_size          => cl_size,
            real_data_add    => real_data_add,
            a2mode           => a2mode,
            load_credits     => load_credits,
            store_credits    => store_credits,
            bcfg_epn_0to15     => bcfg_epn_0to15,
            bcfg_epn_16to31    => bcfg_epn_16to31,
            bcfg_epn_32to47    => bcfg_epn_32to47,
            bcfg_epn_48to51    => bcfg_epn_48to51,
            bcfg_rpn_22to31    => bcfg_rpn_22to31,
            bcfg_rpn_32to47    => bcfg_rpn_32to47,
            bcfg_rpn_48to51    => bcfg_rpn_48to51,
            st_data_32B_mode => st_data_32B_mode)
port map(
     xu_lsu_rf0_act                     => xu_lsu_rf0_act,
     xu_lsu_rf1_cmd_act                 => xu_lsu_rf1_cmd_act,
     xu_lsu_rf1_axu_op_val              => xu_lsu_rf1_axu_op_val,
     xu_lsu_rf1_axu_ldst_falign         => xu_lsu_rf1_axu_ldst_falign_int,
     xu_lsu_rf1_axu_ldst_fexcpt         => xu_lsu_rf1_axu_ldst_fexcpt,
     xu_lsu_rf1_cache_acc               => xu_lsu_rf1_cache_acc,
     xu_lsu_rf1_thrd_id                 => xu_lsu_rf1_thrd_id,
     xu_lsu_rf1_optype1                 => xu_lsu_rf1_optype1,
     xu_lsu_rf1_optype2                 => xu_lsu_rf1_optype2,
     xu_lsu_rf1_optype4                 => xu_lsu_rf1_optype4,
     xu_lsu_rf1_optype8                 => xu_lsu_rf1_optype8,
     xu_lsu_rf1_optype16                => xu_lsu_rf1_optype16,
     xu_lsu_rf1_optype32                => xu_lsu_rf1_optype32,
     xu_lsu_rf1_target_gpr              => xu_lsu_rf1_target_gpr,
     xu_lsu_rf1_mtspr_trace             => xu_lsu_rf1_mtspr_trace,
     xu_lsu_rf1_load_instr              => xu_lsu_rf1_load_instr,
     xu_lsu_rf1_store_instr             => xu_lsu_rf1_store_instr,
     xu_lsu_rf1_dcbf_instr              => xu_lsu_rf1_dcbf_instr,
     xu_lsu_rf1_sync_instr              => xu_lsu_rf1_sync_instr,
     xu_lsu_rf1_l_fld                   => xu_lsu_rf1_l_fld,
     xu_lsu_rf1_dcbi_instr              => xu_lsu_rf1_dcbi_instr,
     xu_lsu_rf1_dcbz_instr              => xu_lsu_rf1_dcbz_instr,
     xu_lsu_rf1_dcbt_instr              => xu_lsu_rf1_dcbt_instr,
     xu_lsu_rf1_dcbtst_instr            => xu_lsu_rf1_dcbtst_instr,
     xu_lsu_rf1_th_fld                  => xu_lsu_rf1_th_fld,
     xu_lsu_rf1_dcbtls_instr            => xu_lsu_rf1_dcbtls_instr,
     xu_lsu_rf1_dcbtstls_instr          => xu_lsu_rf1_dcbtstls_instr,
     xu_lsu_rf1_dcblc_instr             => xu_lsu_rf1_dcblc_instr,
     xu_lsu_rf1_dcbst_instr             => xu_lsu_rf1_dcbst_instr,
     xu_lsu_rf1_icbi_instr              => xu_lsu_rf1_icbi_instr,
     xu_lsu_rf1_icblc_instr             => xu_lsu_rf1_icblc_instr,
     xu_lsu_rf1_icbt_instr              => xu_lsu_rf1_icbt_instr,
     xu_lsu_rf1_icbtls_instr            => xu_lsu_rf1_icbtls_instr,
     xu_lsu_rf1_icswx_instr             => xu_lsu_rf1_icswx_instr,
     xu_lsu_rf1_icswx_dot_instr         => xu_lsu_rf1_icswx_dot_instr,
     xu_lsu_rf1_icswx_epid              => xu_lsu_rf1_icswx_epid,
     xu_lsu_rf1_tlbsync_instr           => xu_lsu_rf1_tlbsync_instr,
     xu_lsu_rf1_ldawx_instr             => xu_lsu_rf1_ldawx_instr,
     xu_lsu_rf1_wclr_instr              => xu_lsu_rf1_wclr_instr,
     xu_lsu_rf1_wchk_instr              => xu_lsu_rf1_wchk_instr,
     xu_lsu_rf1_lock_instr              => xu_lsu_rf1_lock_instr,
     xu_lsu_rf1_mutex_hint              => xu_lsu_rf1_mutex_hint,
     xu_lsu_rf1_mbar_instr              => xu_lsu_rf1_mbar_instr,
     xu_lsu_rf1_is_msgsnd               => xu_lsu_rf1_is_msgsnd,
     xu_lsu_rf1_dci_instr               => xu_lsu_rf1_dci_instr,
     xu_lsu_rf1_ici_instr               => xu_lsu_rf1_ici_instr,
     xu_lsu_rf1_algebraic               => xu_lsu_rf1_algebraic,
     xu_lsu_rf1_byte_rev                => xu_lsu_rf1_byte_rev,
     xu_lsu_rf1_src_gpr                 => xu_lsu_rf1_src_gpr,
     xu_lsu_rf1_src_axu                 => xu_lsu_rf1_src_axu,
     xu_lsu_rf1_src_dp                  => xu_lsu_rf1_src_dp,
     xu_lsu_rf1_targ_gpr                => xu_lsu_rf1_targ_gpr,
     xu_lsu_rf1_targ_axu                => xu_lsu_rf1_targ_axu,
     xu_lsu_rf1_targ_dp                 => xu_lsu_rf1_targ_dp,
     xu_lsu_ex4_val                     => xu_lsu_ex4_val,
     xu_lsu_ex1_add_src0                => xu_lsu_ex1_add_src0,
     xu_lsu_ex1_add_src1                => xu_lsu_ex1_add_src1,
     xu_lsu_ex2_instr_trace_val         => xu_lsu_ex2_instr_trace_val,

     xu_lsu_rf1_src0_vld                => xu_lsu_rf1_src0_vld,
     xu_lsu_rf1_src0_reg                => xu_lsu_rf1_src0_reg,
     xu_lsu_rf1_src1_vld                => xu_lsu_rf1_src1_vld,
     xu_lsu_rf1_src1_reg                => xu_lsu_rf1_src1_reg,
     xu_lsu_rf1_targ_vld                => xu_lsu_rf1_targ_vld,
     xu_lsu_rf1_targ_reg                => xu_lsu_rf1_targ_reg,

     pc_xu_inj_dcachedir_parity         => pc_xu_inj_dcachedir_parity,
     pc_xu_inj_dcachedir_multihit       => pc_xu_inj_dcachedir_multihit,

     derat_xu_ex3_n_flush_req           => derat_xu_ex3_n_flush_req,
     derat_xu_ex3_miss                  => derat_xu_ex3_miss,
     derat_xu_ex3_dsi                   => derat_xu_ex3_dsi,
     lsu_xu_ex3_derat_multihit_err      => lsu_xu_ex3_derat_multihit_err,
     lsu_xu_ex3_derat_par_err           => lsu_xu_ex3_derat_par_err,
     lsu_xu_ex4_derat_par_err           => lsu_xu_ex4_derat_par_err,

     ex4_256st_data                     => ex4_256st_data,
     xu_lsu_ex4_dvc1_en                 => xu_lsu_ex4_dvc1_en,
     xu_lsu_ex4_dvc2_en                 => xu_lsu_ex4_dvc2_en,

     xu_lsu_mtspr_trace_en              => xu_lsu_mtspr_trace_en,
     spr_xucr0_clkg_ctl_b1              => spr_xucr0_clkg_ctl(1),
     spr_xucr0_clkg_ctl_b3              => spr_xucr0_clkg_ctl(3),
     spr_xucr4_mmu_mchk                 => spr_xucr4_mmu_mchk_int,
     xu_lsu_spr_xucr0_aflsta            => xu_lsu_spr_xucr0_aflsta,
     xu_lsu_spr_xucr0_flsta             => xu_lsu_spr_xucr0_flsta,
     xu_lsu_spr_xucr0_l2siw             => xu_lsu_spr_xucr0_l2siw,
     xu_lsu_spr_xucr0_dcdis             => xu_lsu_spr_xucr0_dcdis,
     xu_lsu_spr_xucr0_wlk               => xu_lsu_spr_xucr0_wlk,
     xu_lsu_spr_xucr0_flh2l2            => xu_lsu_spr_xucr0_flh2l2,
     xu_lsu_spr_xucr0_clfc              => xu_lsu_spr_xucr0_clfc,
     xu_lsu_spr_xucr0_cred              => xu_lsu_spr_xucr0_cred,
     xu_lsu_spr_xucr0_rel               => xu_lsu_spr_xucr0_rel,
     xu_lsu_spr_xucr0_mbar_ack          => xu_lsu_spr_xucr0_mbar_ack,
     xu_lsu_spr_xucr0_tlbsync           => xu_lsu_spr_xucr0_tlbsync,
     xu_lsu_spr_xucr0_cls               => xu_lsu_spr_xucr0_cls,
     xu_lsu_spr_ccr2_dfrat              => xu_lsu_spr_ccr2_dfrat,
     xu_lsu_spr_ccr2_dfratsc            => xu_lsu_spr_ccr2_dfratsc,
     xu_lsu_ex5_set_barr                => xu_lsu_ex5_set_barr,

     an_ac_flh2l2_gate                  => an_ac_flh2l2_gate,

     xu_lsu_dci                         => xu_lsu_dci,

     xu_lsu_rf0_derat_val               => xu_lsu_rf0_derat_val,
     xu_lsu_rf1_derat_act               => xu_lsu_rf1_derat_act,
     xu_lsu_rf1_derat_ra_eq_ea          => xu_lsu_rf1_derat_ra_eq_ea,
     xu_lsu_rf1_derat_is_load           => xu_lsu_rf1_derat_is_load,
     xu_lsu_rf1_derat_is_store          => xu_lsu_rf1_derat_is_store,
     xu_lsu_rf0_derat_is_extload        => xu_lsu_rf0_derat_is_extload,
     xu_lsu_rf0_derat_is_extstore       => xu_lsu_rf0_derat_is_extstore,
     xu_lsu_rf1_is_eratre               => xu_rf1_is_eratre_int,
     xu_lsu_rf1_is_eratwe               => xu_rf1_is_eratwe_int,
     xu_lsu_rf1_is_eratsx               => xu_rf1_is_eratsx_int,
     xu_lsu_rf1_is_eratilx              => xu_rf1_is_eratilx_int,
     xu_lsu_ex1_is_isync                => xu_ex1_is_isync_int,
     xu_lsu_ex1_is_csync                => xu_ex1_is_csync_int,
     xu_lsu_rf1_is_touch                => xu_lsu_rf1_is_touch,
     xu_lsu_rf1_ws                      => xu_rf1_ws_int,
     xu_lsu_rf1_t                       => xu_rf1_t_int,
     xu_lsu_ex1_rs_is                   => xu_ex1_rs_is_int,
     xu_lsu_ex1_ra_entry                => xu_ex1_ra_entry_int(7 to 11),
     xu_lsu_ex4_rs_data                 => xu_ex4_rs_data_int,
     xu_lsu_msr_gs                      => spr_msr_gs,
     xu_lsu_msr_pr                      => spr_msr_pr,
     xu_lsu_msr_ds                      => spr_msr_ds,
     xu_lsu_msr_cm                      => spr_msr_cm,
     xu_lsu_hid_mmu_mode                => xu_lsu_hid_mmu_mode,
     ex6_ld_par_err                     => ex6_ld_par_err,

     xu_lsu_rf0_flush                   => xu_rf0_flush,
     xu_lsu_rf1_flush                   => xu_rf1_flush,
     xu_lsu_ex1_flush                   => xu_ex1_flush,
     xu_lsu_ex2_flush                   => xu_ex2_flush,
     xu_lsu_ex3_flush                   => xu_ex3_flush,
     xu_lsu_ex4_flush                   => xu_ex4_flush,
     xu_lsu_ex5_flush                   => xu_n_ex5_flush_int,
                                        
     lsu_xu_ex4_tlb_data                => lsu_xu_ex4_tlb_data,
     xu_mm_derat_req                    => xu_mm_derat_req,
     xu_mm_derat_thdid                  => xu_mm_derat_thdid,
     xu_mm_derat_state                  => xu_mm_derat_state,
     xu_mm_derat_tid                    => xu_mm_derat_tid,
     xu_mm_derat_lpid                   => xu_mm_derat_lpid,
     xu_mm_derat_ttype                  => xu_mm_derat_ttype,
     mm_xu_derat_rel_val                => mm_xu_derat_rel_val,
     mm_xu_derat_rel_data               => mm_xu_derat_rel_data,
     mm_xu_derat_pid0                   => mm_xu_derat_pid0,
     mm_xu_derat_pid1                   => mm_xu_derat_pid1,
     mm_xu_derat_pid2                   => mm_xu_derat_pid2,
     mm_xu_derat_pid3                   => mm_xu_derat_pid3,
     mm_xu_derat_mmucr0_0               => mm_xu_derat_mmucr0_0,
     mm_xu_derat_mmucr0_1               => mm_xu_derat_mmucr0_1,
     mm_xu_derat_mmucr0_2               => mm_xu_derat_mmucr0_2,
     mm_xu_derat_mmucr0_3               => mm_xu_derat_mmucr0_3,
     xu_mm_derat_mmucr0                 => xu_mm_derat_mmucr0,
     xu_mm_derat_mmucr0_we              => xu_mm_derat_mmucr0_we,
     mm_xu_derat_mmucr1                 => mm_xu_derat_mmucr1,
     xu_mm_derat_mmucr1                 => xu_mm_derat_mmucr1,
     xu_mm_derat_mmucr1_we              => xu_mm_derat_mmucr1_we,
     mm_xu_derat_snoop_coming           => mm_xu_derat_snoop_coming,
     mm_xu_derat_snoop_val              => mm_xu_derat_snoop_val,
     mm_xu_derat_snoop_attr             => mm_xu_derat_snoop_attr,
     mm_xu_derat_snoop_vpn              => mm_xu_derat_snoop_vpn ,
     xu_mm_derat_snoop_ack              => xu_mm_derat_snoop_ack ,
                                       
     xu_lsu_slowspr_val                 => xu_lsu_slowspr_val,
     xu_lsu_slowspr_rw                  => xu_lsu_slowspr_rw,
     xu_lsu_slowspr_etid                => xu_lsu_slowspr_etid,
     xu_lsu_slowspr_addr                => xu_lsu_slowspr_addr,
     xu_lsu_slowspr_data                => xu_lsu_slowspr_data,
     xu_lsu_slowspr_done                => xu_lsu_slowspr_done,
     slowspr_val_out                    => slowspr_val_out,
     slowspr_rw_out                     => slowspr_rw_out,
     slowspr_etid_out                   => slowspr_etid_out,
     slowspr_addr_out                   => slowspr_addr_out,
     slowspr_data_out                   => slowspr_data_out,
     slowspr_done_out                   => slowspr_done_out,

     ex1_optype1                        => ex1_optype1,
     ex1_optype2                        => ex1_optype2,
     ex1_optype4                        => ex1_optype4,
     ex1_optype8                        => ex1_optype8,
     ex1_optype16                       => ex1_optype16,
     ex1_optype32                       => ex1_optype32,
     ex1_saxu_instr                     => ex1_saxu_instr,
     ex1_sdp_instr                      => ex1_sdp_instr,
     ex1_stgpr_instr                    => ex1_stgpr_instr,
     ex1_store_instr                    => ex1_store_instr,
     ex1_axu_op_val                     => ex1_axu_op_val,

     lsu_xu_ex3_align                   => lsu_xu_ex3_align,
     lsu_xu_ex3_dsi                     => lsu_xu_ex3_dsi,
     lsu_xu_ex3_inval_align_2ucode      => lsu_xu_ex3_inval_align_2ucode,
     lsu_xu_ex3_attr                    => lsu_xu_ex3_attr,
     lsu_xu_ex3_derat_vf                => lsu_xu_ex3_derat_vf,

     lsu_xu_ex3_n_flush_req             => lsu_xu_ex3_n_flush_req,
     lsu_xu_ex4_ldq_full_flush          => lsu_xu_ex4_ldq_full_flush,
     lsu_xu_ex3_ldq_hit_flush           => lsu_xu_ex3_ldq_hit_flush,
     lsu_xu_ex3_dep_flush               => lsu_xu_ex3_dep_flush,
     lsu_xu_datc_perr_recovery          => lsu_xu_datc_perr_recovery,
     lsu_xu_l2_ecc_err_flush            => lsu_xu_l2_ecc_err_flush,

     ex3_algebraic                      => ex3_algebraic,
     ex3_data_swap                      => ex3_data_swap,
     ex3_thrd_id                        => ex3_thrd_id,
     xu_fu_ex3_eff_addr                 => xu_fu_ex3_eff_addr,

     lsu_xu_ex3_ddir_par_err            => lsu_xu_ex3_ddir_par_err,
     lsu_xu_ex4_n_lsu_ddmh_flush        => lsu_xu_ex4_n_lsu_ddmh_flush,

     lsu_xu_is2_back_inv                => lsu_xu_is2_back_inv,
     lsu_xu_is2_back_inv_addr           => lsu_xu_is2_back_inv_addr,
     lsu_xu_ex4_cr_upd                  => lsu_xu_ex4_cr_upd,
     lsu_xu_ex5_cr_rslt                 => lsu_xu_ex5_cr_rslt,

     rel_upd_dcarr_val                  => rel_upd_dcarr_val,

     lsu_xu_ex5_wren                    => lsu_xu_ex5_wren,
     lsu_xu_rel_wren                    => lsu_xu_rel_wren_int,
     lsu_xu_rel_ta_gpr                  => lsu_xu_rel_ta_gpr_int,
     lsu_xu_need_hole                   => lsu_xu_need_hole,
     xu_fu_ex5_reload_val               => xu_fu_ex5_reload_val,
     xu_fu_ex5_load_val                 => xu_fu_ex5_load_val,
     xu_fu_ex5_load_tag                 => xu_fu_ex5_load_tag,

     dcarr_up_way_addr                  => dcarr_up_way_addr,

     lsu_xu_spr_xucr0_cslc_xuop         => lsu_xu_spr_xucr0_cslc_xuop,
     lsu_xu_spr_xucr0_cslc_binv         => lsu_xu_spr_xucr0_cslc_binv,
     lsu_xu_spr_xucr0_clo               => lsu_xu_spr_xucr0_clo,
     lsu_xu_spr_xucr0_cul               => lsu_xu_spr_xucr0_cul,
     lsu_xu_spr_epsc_epr                => lsu_xu_spr_epsc_epr,
     lsu_xu_spr_epsc_egs                => lsu_xu_spr_epsc_egs,

     ex4_load_op_hit                    => ex4_load_op_hit,
     ex4_store_hit                      => ex4_store_hit,
     ex4_axu_op_val                     => ex4_axu_op_val,
     spr_dvc1_act                       => spr_dvc1_act,
     spr_dvc2_act                       => spr_dvc2_act,
     spr_dvc1_dbg                       => spr_dvc1_dbg,
     spr_dvc2_dbg                       => spr_dvc2_dbg,

     an_ac_req_ld_pop                   => an_ac_req_ld_pop,
     an_ac_req_st_pop                   => an_ac_req_st_pop,
     an_ac_req_st_gather                => an_ac_req_st_gather,
     an_ac_req_st_pop_thrd              => an_ac_req_st_pop_thrd,
     an_ac_reld_data_val                => an_ac_reld_data_vld,
     an_ac_reld_core_tag                => an_ac_reld_core_tag,
     an_ac_reld_qw                      => an_ac_reld_qw,
     an_ac_reld_data                    => an_ac_reld_data,
     an_ac_reld_ecc_err                 => an_ac_reld_ecc_err,
     an_ac_reld_ecc_err_ue              => an_ac_reld_ecc_err_ue,
     an_ac_reld_data_coming             => an_ac_reld_data_coming,
     an_ac_reld_ditc                    => an_ac_reld_ditc,
     an_ac_reld_crit_qw                 => an_ac_reld_crit_qw,
     an_ac_reld_l1_dump                 => an_ac_reld_l1_dump,

     an_ac_back_inv                     => an_ac_back_inv,
     an_ac_back_inv_addr                => an_ac_back_inv_addr,
     an_ac_back_inv_target_bit1         => an_ac_back_inv_target_bit1,
     an_ac_back_inv_target_bit4         => an_ac_back_inv_target_bit4,

     an_ac_req_spare_ctrl_a1            => an_ac_req_spare_ctrl_a1,

     an_ac_stcx_complete                => an_ac_stcx_complete,
     xu_iu_stcx_complete                => xu_iu_stcx_complete,
     xu_iu_reld_core_tag_clone    => xu_iu_reld_core_tag_clone,
     xu_iu_reld_data_coming_clone => xu_iu_reld_data_coming_clone,
     xu_iu_reld_data_vld_clone    => xu_iu_reld_data_vld_clone,
     xu_iu_reld_ditc_clone        => xu_iu_reld_ditc_clone,
                   
     lsu_reld_data_vld          => lsu_reld_data_vld,
     lsu_reld_core_tag          => lsu_reld_core_tag,
     lsu_reld_qw                => lsu_reld_qw,  
     lsu_reld_ditc              => lsu_reld_ditc,
     lsu_reld_ecc_err           => lsu_reld_ecc_err,
     lsu_reld_data              => lsu_reld_data,
     lsu_req_st_pop             => lsu_req_st_pop,
     lsu_req_st_pop_thrd        => lsu_req_st_pop_thrd,

     ac_an_reld_ditc_pop_int    => ac_an_reld_ditc_pop_int,
     ac_an_reld_ditc_pop_q      => ac_an_reld_ditc_pop_q  ,
     bx_ib_empty_int            => bx_ib_empty_int        ,
     bx_ib_empty_q              => bx_ib_empty_q          ,


     i_x_ra                             => iu_xu_ra,
     i_x_request                        => iu_xu_request,
     i_x_wimge                          => iu_xu_wimge,
     i_x_thread                         => iu_xu_thread,
     i_x_userdef                        => iu_xu_userdef,

     mm_xu_lsu_req                      => mm_xu_lsu_req,
     mm_xu_lsu_ttype                    => mm_xu_lsu_ttype,
     mm_xu_lsu_wimge                    => mm_xu_lsu_wimge,
     mm_xu_lsu_u                        => mm_xu_lsu_u,
     mm_xu_lsu_addr                     => mm_xu_lsu_addr,
     mm_xu_lsu_lpid                     => mm_xu_lsu_lpid, 
     mm_xu_lsu_lpidr                    => mm_xu_lsu_lpidr, 
     mm_xu_lsu_gs                       => mm_xu_lsu_gs  ,
     mm_xu_lsu_ind                      => mm_xu_lsu_ind ,
     mm_xu_lsu_lbit                     => mm_xu_lsu_lbit,
     xu_mm_lsu_token                    => xu_mm_lsu_token,

     bx_lsu_ob_pwr_tok                  => bx_lsu_ob_pwr_tok,
     bx_lsu_ob_req_val                  => bx_lsu_ob_req_val,
     bx_lsu_ob_ditc_val                 => bx_lsu_ob_ditc_val,
     bx_lsu_ob_thrd                     => bx_lsu_ob_thrd,
     bx_lsu_ob_qw                       => bx_lsu_ob_qw,
     bx_lsu_ob_dest                     => bx_lsu_ob_dest,
     bx_lsu_ob_data                     => bx_lsu_ob_data,
     bx_lsu_ob_addr                     => bx_lsu_ob_addr,
                                
     lsu_bx_cmd_avail                   => lsu_bx_cmd_avail,
     lsu_bx_cmd_sent                    => lsu_bx_cmd_sent,
     lsu_bx_cmd_stall                   => lsu_bx_cmd_stall,

     lsu_xu_ldq_barr_done               => lsu_xu_ldq_barr_done,
     lsu_xu_barr_done                   => lsu_xu_barr_done,

     ldq_rel_data_val_early             => ldq_rel_data_val_early,
     ldq_rel_op_size                    => ldq_rel_op_size,
     ldq_rel_addr                       => ldq_rel_addr,
     ldq_rel_data_val                   => ldq_rel_data_val,
     ldq_rel_rot_sel                    => ldq_rel_rot_sel,
     ldq_rel_axu_val                    => ldq_rel_axu_val,
     ldq_rel_ci                         => ldq_rel_ci,
     ldq_rel_thrd_id                    => ldq_rel_thrd_id,
     ldq_rel_le_mode                    => ldq_rel_le_mode,
     ldq_rel_algebraic                  => ldq_rel_algebraic,
     ldq_rel_256_data                   => ldq_rel_256_data,
     ldq_rel_dvc1_en                    => ldq_rel_dvc1_en,
     ldq_rel_dvc2_en                    => ldq_rel_dvc2_en,
     ldq_rel_beat_crit_qw               => ldq_rel_beat_crit_qw,
     ldq_rel_beat_crit_qw_block         => ldq_rel_beat_crit_qw_block,

     xu_iu_ex4_loadmiss_qentry          => xu_iu_ex4_loadmiss_qentry,
     xu_iu_ex4_loadmiss_target          => xu_iu_ex4_loadmiss_target,
     xu_iu_ex4_loadmiss_target_type     => xu_iu_ex4_loadmiss_target_type,
     xu_iu_ex4_loadmiss_tid             => xu_iu_ex4_loadmiss_tid,
     xu_iu_ex5_loadmiss_qentry          => xu_iu_ex5_loadmiss_qentry,
     xu_iu_ex5_loadmiss_target          => xu_iu_ex5_loadmiss_target,
     xu_iu_ex5_loadmiss_target_type     => xu_iu_ex5_loadmiss_target_type,
     xu_iu_ex5_loadmiss_tid             => xu_iu_ex5_loadmiss_tid,
     xu_iu_complete_qentry              => xu_iu_complete_qentry,
     xu_iu_complete_tid                 => xu_iu_complete_tid,
     xu_iu_complete_target_type         => xu_iu_complete_target_type,

     xu_iu_ex6_icbi_val                 => xu_iu_ex6_icbi_val,
     xu_iu_ex6_icbi_addr                => xu_iu_ex6_icbi_addr,

     xu_iu_larx_done_tid                => xu_iu_larx_done_tid,
     xu_mm_lmq_stq_empty                => xu_mm_lmq_stq_empty,
     lsu_xu_quiesce                     => lsu_xu_quiesce,
     lsu_xu_dbell_val                   => lsu_xu_dbell_val,
     lsu_xu_dbell_type                  => lsu_xu_dbell_type,
     lsu_xu_dbell_brdcast               => lsu_xu_dbell_brdcast,
     lsu_xu_dbell_lpid_match            => lsu_xu_dbell_lpid_match,
     lsu_xu_dbell_pirtag                => lsu_xu_dbell_pirtag,

     ac_an_req_pwr_token                => ac_an_req_pwr_token,
     ac_an_req                          => ac_an_req,
     ac_an_req_ra                       => ac_an_req_ra,
     ac_an_req_ttype                    => ac_an_req_ttype,
     ac_an_req_thread                   => ac_an_req_thread,
     ac_an_req_wimg_w                   => ac_an_req_wimg_w,
     ac_an_req_wimg_i                   => ac_an_req_wimg_i,
     ac_an_req_wimg_m                   => ac_an_req_wimg_m,
     ac_an_req_wimg_g                   => ac_an_req_wimg_g,
     ac_an_req_endian                   => ac_an_req_endian,
     ac_an_req_user_defined             => ac_an_req_user_defined,
     ac_an_req_spare_ctrl_a0            => ac_an_req_spare_ctrl_a0,
     ac_an_req_ld_core_tag              => ac_an_req_ld_core_tag,
     ac_an_req_ld_xfr_len               => ac_an_req_ld_xfr_len,
     ac_an_st_byte_enbl                 => ac_an_st_byte_enbl,
     ac_an_st_data                      => ac_an_st_data,
     ac_an_st_data_pwr_token            => ac_an_st_data_pwr_token,
    
     lsu_xu_ex3_l2_uc_ecc_err           => lsu_xu_ex3_l2_uc_ecc_err,
     xu_pc_err_dcachedir_parity         => xu_pc_err_dcachedir_parity,
     xu_pc_err_dcachedir_multihit       => xu_pc_err_dcachedir_multihit,
     xu_pc_err_l2intrf_ecc              => xu_pc_err_l2intrf_ecc,
     xu_pc_err_l2intrf_ue               => xu_pc_err_l2intrf_ue,
     xu_pc_err_invld_reld               => xu_pc_err_invld_reld,
     xu_pc_err_l2credit_overrun         => xu_pc_err_l2credit_overrun,
     pc_xu_event_bus_enable             => pc_xu_event_bus_enable,
     pc_xu_event_count_mode             => pc_xu_event_count_mode,
     pc_xu_lsu_event_mux_ctrls          => pc_xu_lsu_event_mux_ctrls,
     pc_xu_cache_par_err_event          => pc_xu_cache_par_err_event,
     xu_pc_lsu_event_data               => xu_pc_lsu_event_data,

     pc_xu_trace_bus_enable             => pc_xu_trace_bus_enable,
     lsu_debug_mux_ctrls                => lsu_debug_mux_ctrls,
     trigger_data_in                    => lsu_trigger_data_in,
     debug_data_in                      => lsu_debug_data_in,
     trigger_data_out                   => lsu_trigger_data_out,
     debug_data_out                     => lsu_debug_data_out,
     lsu_xu_cmd_debug                   => lsu_xu_cmd_debug,

     vcs                                => vcs,
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,

     pc_xu_abist_g8t_wenb               => pc_xu_abist_g8t_wenb,
     pc_xu_abist_g8t1p_renb_0           => pc_xu_abist_g8t1p_renb_0,
     pc_xu_abist_di_0                   => pc_xu_abist_di_0,
     pc_xu_abist_g8t_bw_1               => pc_xu_abist_g8t_bw_1,
     pc_xu_abist_g8t_bw_0               => pc_xu_abist_g8t_bw_0,
     pc_xu_abist_waddr_0                => pc_xu_abist_waddr_0(5 to 9),
     pc_xu_abist_raddr_0                => pc_xu_abist_raddr_0(5 to 9),
     an_ac_lbist_ary_wrt_thru_dc        => an_ac_lbist_ary_wrt_thru_dc,
     pc_xu_abist_ena_dc                 => pc_xu_abist_ena_dc,
     pc_xu_abist_wl32_comp_ena          => pc_xu_abist_wl32_comp_ena,
     pc_xu_abist_raw_dc_b               => pc_xu_abist_raw_dc_b,
     pc_xu_abist_g8t_dcomp              => pc_xu_abist_g8t_dcomp,
     pc_xu_bo_unload                    => pc_xu_bo_unload,
     pc_xu_bo_repair                    => pc_xu_bo_repair,
     pc_xu_bo_reset                     => pc_xu_bo_reset,
     pc_xu_bo_shdata                    => pc_xu_bo_shdata,
     pc_xu_bo_select                    => pc_xu_bo_select,
     xu_pc_bo_fail                      => xu_pc_bo_fail,
     xu_pc_bo_diagout                   => xu_pc_bo_diagout,

     an_ac_grffence_en_dc               => an_ac_grffence_en_dc,
     an_ac_coreid                       => an_ac_coreid,
     pc_xu_init_reset                   => pc_xu_init_reset,
     pc_xu_ccflush_dc                   => pc_xu_ccflush_dc,
     an_ac_scan_dis_dc_b                => an_ac_scan_dis_dc_b,
     an_ac_atpg_en_dc                   => an_ac_atpg_en_dc,
     an_ac_scan_diag_dc                 => an_ac_scan_diag_dc,
     an_ac_lbist_en_dc                  => an_ac_lbist_en_dc,
     clkoff_dc_b                        => clkoff_dc_b_b,
     sg_2                               => sg_2_b(2 to 3),
     fce_2                              => fce_2_b(1),
     func_sl_thold_2                    => func_sl_thold_2_b(2 to 3),
     func_nsl_thold_2                   => func_nsl_thold_2_b,
     func_slp_sl_thold_2                => func_slp_sl_thold_2_b(1),
     func_slp_nsl_thold_2               => func_slp_nsl_thold_2_b,
     cfg_slp_sl_thold_2                 => cfg_slp_sl_thold_2_b,
     ary_slp_nsl_thold_2                => ary_slp_nsl_thold_2,
     regf_slp_sl_thold_2                => regf_slp_sl_thold_2_b,
     abst_slp_sl_thold_2                => abst_slp_sl_thold_2,
     time_sl_thold_2                    => time_sl_thold_2_b,
     repr_sl_thold_2                    => repr_sl_thold_2_b,
     bolt_sl_thold_2                    => bolt_sl_thold_2_b,
     bo_enable_2                        => bo_enable_2_b,
     d_mode_dc                          => d_mode_dc_b,
     delay_lclkr_dc                     => delay_lclkr_dc_b,
     mpw1_dc_b                          => mpw1_dc_b_b,
     mpw2_dc_b                          => mpw2_dc_b_b,
     g8t_clkoff_dc_b                    => g8t_clkoff_dc_b,
     g8t_d_mode_dc                      => g8t_d_mode_dc,
     g8t_delay_lclkr_dc                 => g8t_delay_lclkr_dc,
     g8t_mpw1_dc_b                      => g8t_mpw1_dc_b,
     g8t_mpw2_dc_b                      => g8t_mpw2_dc_b,
     cam_clkoff_dc_b                    => cam_clkoff_dc_b,
     cam_d_mode_dc                      => cam_d_mode_dc,
     cam_delay_lclkr_dc                 => cam_delay_lclkr_dc,
     cam_act_dis_dc                     => cam_act_dis_dc,
     cam_mpw1_dc_b                      => cam_mpw1_dc_b,
     cam_mpw2_dc_b                      => cam_mpw2_dc_b,
     bcfg_scan_in                       => bcfg_scan_out_int,
     bcfg_scan_out                      => bcfg_scan_out,
     ccfg_scan_in                       => ccfg_scan_out_int,
     ccfg_scan_out                      => ccfg_scan_out,
     dcfg_scan_in                       => dcfg_scan_out_int,
     dcfg_scan_out                      => dcfg_scan_out,
     regf_scan_in                       => regf_scan_in,
     regf_scan_out                      => regf_scan_out,
     abst_scan_in                       => abst_scan_in,
     time_scan_in                       => time_scan_in,
     repr_scan_in                       => repr_scan_in,
     abst_scan_out                      => abst_scan_out,
     time_scan_out                      => time_scan_out,
     repr_scan_out                      => repr_scan_out,
     func_scan_in                       => func_scan_in(41 to 49),
     func_scan_out                      => func_scan_out(41 to 49)
);

xu_lsu_ex4_flush_local <= xu_lsu_ex4_flush_local_int;

xu_rf1_is_eratre           <= xu_rf1_is_eratre_int;
xu_rf1_is_eratwe           <= xu_rf1_is_eratwe_int;
xu_rf1_is_eratsx           <= xu_rf1_is_eratsx_int;
xu_rf1_is_eratsrx          <= xu_rf1_is_eratsrx_int;
xu_rf1_is_eratilx          <= xu_rf1_is_eratilx_int;
xu_rf1_is_erativax         <= xu_rf1_is_erativax_int;
xu_ex1_is_isync            <= xu_ex1_is_isync_int;
xu_ex1_is_csync            <= xu_ex1_is_csync_int;
xu_rf1_ws                  <= xu_rf1_ws_int;
xu_rf1_t                   <= xu_rf1_t_int;
xu_ex1_rs_is               <= xu_ex1_rs_is_int;
xu_ex1_ra_entry            <= xu_ex1_ra_entry_int(8 to 11);
xu_ex4_rs_data             <= xu_ex4_rs_data_int;
xu_lsu_ex1_eff_addr        <= xu_ex1_eff_addr_int;
lsu_xu_rel_wren            <= lsu_xu_rel_wren_int;
lsu_xu_rel_ta_gpr          <= lsu_xu_rel_ta_gpr_int;
xu_lsu_rf1_axu_ldst_falign <= xu_lsu_rf1_axu_ldst_falign_int;

end xuq_ctrl;  

