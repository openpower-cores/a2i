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

--  Description:  XU_B Decode
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY ibm;
USE ibm.std_ulogic_support.all;
USE ibm.std_ulogic_function_support.all;
LIBRARY support;
USE support.power_logic_pkg.all;
LIBRARY tri;
USE tri.tri_latches_pkg.all;
LIBRARY work;
USE work.xuq_pkg.all;

entity xuq_dec_b is
    generic(
        expand_type                         : integer := 2;
        threads                             : integer := 4;
        regmode                             : integer := 6;
        regsize                             : integer := 64;
        cl_size                             : natural := 6;             
        real_data_add                       : integer := 42;
        eff_ifar                            : integer := 62);
    port(
        nclk                                : in clk_logic;

        vdd                                 : inout power_logic;
        gnd                                 : inout power_logic;

        d_mode_dc                           : in std_ulogic;
        delay_lclkr_dc                      : in std_ulogic;
        mpw1_dc_b                           : in std_ulogic;
        mpw2_dc_b                           : in std_ulogic;
        func_sl_force : in std_ulogic;
        func_sl_thold_0_b                   : in std_ulogic;
        func_nsl_force : in std_ulogic;
        func_nsl_thold_0_b                  : in std_ulogic;
        func_slp_sl_force : in std_ulogic;
        func_slp_sl_thold_0_b               : in std_ulogic;
        func_slp_nsl_force : in std_ulogic;
        func_slp_nsl_thold_0_b              : in std_ulogic;
        sg_0                                : in std_ulogic;
        scan_in                             : in std_ulogic;
        scan_out                            : out std_ulogic;

        slowspr_val_in                      : in std_ulogic;
        slowspr_rw_in                       : in std_ulogic;
        slowspr_etid_in                     : in std_ulogic_vector(0 to 1);
        an_ac_dcr_act                       : in  std_ulogic;
        an_ac_dcr_val                       : in  std_ulogic;
        an_ac_dcr_read                      : in  std_ulogic;
        an_ac_dcr_etid                      : in  std_ulogic_vector(0 to 1);
        an_ac_dcr_ack                       : out std_ulogic;
        dec_byp_ex4_dcr_ack                          : out std_ulogic;

        xu_mm_rf1_is_tlbsxr                 : out std_ulogic;
        mm_xu_mmucr0_0_tlbsel               : in std_ulogic_vector(4 to 5);
        mm_xu_mmucr0_1_tlbsel               : in std_ulogic_vector(4 to 5);
        mm_xu_mmucr0_2_tlbsel               : in std_ulogic_vector(4 to 5);
        mm_xu_mmucr0_3_tlbsel               : in std_ulogic_vector(4 to 5);

        fxb_fxa_ex7_we0                     : out std_ulogic;
        fxb_fxa_ex7_wa0                     : out std_ulogic_vector(0 to 7);

        xu_rf1_flush                        : in std_ulogic_vector(0 to threads-1);
        xu_ex1_flush                        : in std_ulogic_vector(0 to threads-1);
        xu_ex2_flush                        : in std_ulogic_vector(0 to threads-1);
        xu_ex3_flush                        : in std_ulogic_vector(0 to threads-1);
        xu_ex4_flush                        : in std_ulogic_vector(0 to threads-1);
        xu_ex5_flush                        : in std_ulogic_vector(0 to threads-1);

        fxa_fxb_rf0_val                     : in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_issued                  : in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_ucode_val               : in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_act                     : in  std_ulogic;
        fxa_fxb_rf0_instr                   : in  std_ulogic_vector(0 to 31);
        fxa_fxb_rf0_tid                     : in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_ta_vld                  : in  std_ulogic;
        fxa_fxb_rf0_ta                      : in  std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_error                   : in  std_ulogic_vector(0 to 2);
        fxa_fxb_rf0_match                   : in  std_ulogic;
        fxa_fxb_rf0_is_ucode                : in  std_ulogic;
        fxa_fxb_rf0_gshare                  : in  std_ulogic_vector(0 to 3);
        fxa_fxb_rf0_ifar                    : in  std_ulogic_vector(62-eff_ifar to 61);
        fxa_fxb_rf0_s1_vld                  : in  std_ulogic;
        fxa_fxb_rf0_s1                      : in  std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_s2_vld                  : in  std_ulogic;
        fxa_fxb_rf0_s2                      : in  std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_s3_vld                  : in  std_ulogic;
        fxa_fxb_rf0_s3                      : in  std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_axu_instr_type          : in  std_ulogic_vector(0 to 2);
        fxa_fxb_rf0_axu_ld_or_st            : in  std_ulogic;
        fxa_fxb_rf0_axu_store               : in  std_ulogic;
        fxa_fxb_rf0_axu_ldst_forcealign     : in  std_ulogic;
        fxa_fxb_rf0_axu_ldst_forceexcept    : in  std_ulogic;
        fxa_fxb_rf0_axu_ldst_indexed        : in  std_ulogic;
        fxa_fxb_rf0_axu_ldst_tag            : in  std_ulogic_vector(0 to 8);
        fxa_fxb_rf0_axu_mftgpr              : in  std_ulogic;
        fxa_fxb_rf0_axu_mffgpr              : in  std_ulogic;
        fxa_fxb_rf0_axu_movedp              : in  std_ulogic;
        fxa_fxb_rf0_axu_ldst_size           : in  std_ulogic_vector(0 to 5);
        fxa_fxb_rf0_axu_ldst_update         : in  std_ulogic;
        fxa_fxb_rf0_pred_update             : in  std_ulogic;
        fxa_fxb_rf0_pred_taken_cnt          : in  std_ulogic_vector(0 to 1);
        fxa_fxb_rf0_mc_dep_chk_val          : in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf1_muldiv_coll             : in  std_ulogic;
        fxa_fxb_rf0_xu_epid_instr           : in  std_ulogic;
        fxa_fxb_rf0_axu_is_extload          : in  std_ulogic;
        fxa_fxb_rf0_axu_is_extstore         : in  std_ulogic;
        fxa_fxb_rf0_3src_instr              : in  std_ulogic;
        fxa_fxb_rf0_gpr0_zero               : in  std_ulogic;
        fxa_fxb_rf0_use_imm                 : in  std_ulogic;

        alu_dec_ex1_ipb_ba                  : in std_ulogic_vector(27 to 31);
        alu_dec_div_need_hole               : in std_ulogic;

        dec_byp_rf1_rs0_sel                 : out std_ulogic_vector(1 to 9);
        dec_byp_rf1_rs1_sel                 : out std_ulogic_vector(1 to 10);
        dec_byp_rf1_rs2_sel                 : out std_ulogic_vector(1 to 9);
        dec_byp_rf1_imm                     : out std_ulogic_vector(64-regsize to 63);
        dec_byp_rf1_instr                   : out std_ulogic_vector(6 to 25);
        dec_byp_rf1_cr_so_update            : out std_ulogic_vector(0 to 1);
        dec_byp_ex3_val                     : out std_ulogic_vector(0 to threads-1);
        dec_byp_rf1_cr_we                   : out std_ulogic;
        dec_byp_rf1_is_mcrf                 : out std_ulogic;
        dec_byp_rf1_use_crfld0              : out std_ulogic;
        dec_byp_rf1_alu_cmp                 : out std_ulogic;
        dec_byp_rf1_is_mtcrf                : out std_ulogic;
        dec_byp_rf1_is_mtocrf               : out std_ulogic;
        dec_byp_rf1_byp_val                 : out std_ulogic_vector(1 to 3);
        dec_byp_ex4_is_eratsxr              : out std_ulogic;
        dec_byp_rf1_ca_used                 : out std_ulogic;
        dec_byp_rf1_ov_used                 : out std_ulogic;
        dec_byp_ex4_dp_instr                : out std_ulogic;
        dec_byp_ex4_mtdp_val                : out std_ulogic;
        dec_byp_ex4_mfdp_val                : out std_ulogic;
        dec_byp_ex4_is_wchkall              : out std_ulogic;
        dec_byp_ex5_instr                   : out std_ulogic_vector(12 to 19);
        dec_byp_rf0_act                     : out std_ulogic;

        dec_alu_rf1_act                     : out std_ulogic;
        dec_alu_ex1_act                     : out std_ulogic;        
        dec_alu_rf1_sel                     : out std_ulogic_vector(0 to 3);
        dec_alu_rf1_add_rs0_inv             : out std_ulogic_vector(64-(2**regmode) to 63);
        dec_alu_rf1_add_ci                  : out std_ulogic;

dec_alu_rf1_mul_recform             : out std_ulogic;
dec_alu_rf1_div_recform             : out std_ulogic;
dec_alu_rf1_mul_ret                 : out std_ulogic;
dec_alu_rf1_mul_sign                : out std_ulogic;
dec_alu_rf1_mul_size                : out std_ulogic;
dec_alu_rf1_mul_imm                 : out std_ulogic;
dec_alu_rf1_div_sign                : out std_ulogic;
dec_alu_rf1_div_size                : out std_ulogic;
dec_alu_rf1_div_extd                : out std_ulogic;
dec_alu_rf1_is_cmpl                 : out std_ulogic;
dec_alu_rf1_tw_cmpsel               : out std_ulogic_vector(0 to 5);
dec_alu_ex1_is_cmp                  : out std_ulogic;
dec_rf1_is_isel                     : out std_ulogic;
dec_alu_rf1_xer_ov_update           : out std_ulogic;
dec_alu_rf1_xer_ca_update           : out std_ulogic;
dec_alu_rf1_sh_right                : out std_ulogic;
dec_alu_rf1_sh_word                 : out std_ulogic;
dec_alu_rf1_sgnxtd_byte             : out std_ulogic;
dec_alu_rf1_sgnxtd_half             : out std_ulogic;
dec_alu_rf1_sgnxtd_wd               : out std_ulogic;
dec_alu_rf1_sra_dw                  : out std_ulogic;
dec_alu_rf1_sra_wd                  : out std_ulogic;
dec_alu_rf1_chk_shov_dw             : out std_ulogic;
dec_alu_rf1_chk_shov_wd             : out std_ulogic;
dec_alu_rf1_use_me_ins_hi           : out std_ulogic;
dec_alu_rf1_use_me_ins_lo           : out std_ulogic;
dec_alu_rf1_use_mb_ins_hi           : out std_ulogic;
dec_alu_rf1_use_mb_ins_lo           : out std_ulogic;
dec_alu_rf1_use_me_rb_hi            : out std_ulogic;
dec_alu_rf1_use_me_rb_lo            : out std_ulogic;
dec_alu_rf1_use_mb_rb_hi            : out std_ulogic;
dec_alu_rf1_use_mb_rb_lo            : out std_ulogic;
dec_alu_rf1_use_rb_amt_hi           : out std_ulogic;
dec_alu_rf1_use_rb_amt_lo           : out std_ulogic;
dec_alu_rf1_zm_ins                  : out std_ulogic;
dec_alu_rf1_cr_logical              : out std_ulogic;
dec_alu_rf1_cr_log_fcn              : out std_ulogic_vector(0 to 3);
dec_alu_rf1_log_fcn                 : out std_ulogic_vector(0 to 3);
dec_alu_rf1_me_ins_b                : out std_ulogic_vector(0 to 5);
dec_alu_rf1_mb_ins                  : out std_ulogic_vector(0 to 5);
dec_alu_rf1_sh_amt                  : out std_ulogic_vector(0 to 5);
dec_alu_rf1_mb_gt_me                : out std_ulogic;
dec_alu_rf1_select_64bmode          : out std_ulogic;
alu_ex3_mul_done                    : in std_ulogic;
alu_ex2_div_done                    : in std_ulogic;
dec_rf1_tid                         : out std_ulogic_vector(0 to threads-1);
dec_ex1_tid                         : out std_ulogic_vector(0 to threads-1);
dec_ex2_tid                         : out std_ulogic_vector(0 to threads-1);
dec_ex3_tid                         : out std_ulogic_vector(0 to threads-1);
dec_ex4_tid                         : out std_ulogic_vector(0 to threads-1);
dec_ex5_tid                         : out std_ulogic_vector(0 to threads-1);
dec_byp_ex1_spr_sel                 : out std_ulogic;
dec_byp_ex4_is_mfcr                 : out std_ulogic;
dec_byp_ex3_tlb_sel                 : out std_ulogic_vector(0 to 1);
dec_spr_ex1_is_mtspr                : out std_ulogic;
dec_spr_ex1_is_mfspr                : out std_ulogic;
dec_cpl_rf1_val                     : out std_ulogic_vector(0 to threads-1);
dec_cpl_rf1_issued                  : out std_ulogic_vector(0 to threads-1);
dec_spr_rf1_val                     : out std_ulogic_vector(0 to threads-1);
dec_spr_ex4_val                     : out std_ulogic_vector(0 to threads-1);
dec_cpl_rf1_instr                   : out std_ulogic_vector(0 to 31);
dec_fspr_ex1_instr                  : out std_ulogic_vector(11 to 20);
dec_fspr_ex6_val                    : out std_ulogic_vector(0 to threads-1);
dec_cpl_rf1_ifar                    : out std_ulogic_vector(62-eff_ifar to 61);
dec_cpl_rf1_pred_taken_cnt          : out std_ulogic;
dec_cpl_rf1_ucode_val               : out std_ulogic_vector(0 to threads-1);
dec_cpl_ex2_error                   : out std_ulogic_vector(0 to 2);
dec_cpl_ex2_match                   : out std_ulogic;
dec_cpl_ex2_is_ucode                : out std_ulogic;
dec_cpl_ex3_is_any_store            : out std_ulogic;
ex2_is_any_load_dac                 : out std_ulogic;
ex2_is_any_store_dac                : out std_ulogic;
dec_cpl_ex3_mtdp_nr                 : out std_ulogic;
dec_cpl_ex3_instr_priv              : out std_ulogic;
dec_cpl_ex3_mult_coll               : out std_ulogic;
dec_cpl_ex3_tlb_illeg               : out std_ulogic;
dec_cpl_ex3_axu_instr_type          : out std_ulogic_vector(0 to 2);
dec_cpl_ex3_instr_hypv              : out std_ulogic;
dec_cpl_ex1_epid_instr              : out std_ulogic;
dec_cpl_ex2_illegal_op              : out std_ulogic;
dec_cpl_ex1_is_slowspr_wr           : out std_ulogic;
dec_cpl_ex3_ddmh_en                 : out std_ulogic;
dec_cpl_ex3_back_inv                : out std_ulogic;
xu_lsu_rf0_act                      : out std_ulogic;
xu_lsu_rf1_cache_acc                : out std_ulogic;
xu_lsu_rf1_axu_op_val               : out std_ulogic;
xu_lsu_rf1_axu_ldst_falign          : out std_ulogic;
xu_lsu_rf1_axu_ldst_fexcpt          : out std_ulogic;
xu_lsu_rf1_thrd_id                  : out std_ulogic_vector(0 to 3);
xu_lsu_rf1_optype1                  : out std_ulogic;
xu_lsu_rf1_optype2                  : out std_ulogic;
xu_lsu_rf1_optype4                  : out std_ulogic;
xu_lsu_rf1_optype8                  : out std_ulogic;
xu_lsu_rf1_optype16                 : out std_ulogic;
xu_lsu_rf1_optype32                 : out std_ulogic;
xu_lsu_rf1_target_gpr               : out std_ulogic_vector(0 to 8);
xu_lsu_rf1_load_instr               : out std_ulogic;
xu_lsu_rf1_store_instr              : out std_ulogic;
xu_lsu_rf1_dcbf_instr               : out std_ulogic;
xu_lsu_rf1_sync_instr               : out std_ulogic;
xu_lsu_rf1_mbar_instr               : out std_ulogic;
xu_lsu_rf1_l_fld                    : out std_ulogic_vector(0 to 1);
xu_lsu_rf1_dcbi_instr               : out std_ulogic;
xu_lsu_rf1_dcbz_instr               : out std_ulogic;
xu_lsu_rf1_dcbt_instr               : out std_ulogic;
xu_lsu_rf1_dcbtst_instr             : out std_ulogic;
xu_lsu_rf1_th_fld                   : out std_ulogic_vector(0 to 4);
xu_lsu_rf1_dcbtls_instr             : out std_ulogic;
xu_lsu_rf1_dcbtstls_instr           : out std_ulogic;
xu_lsu_rf1_dcblc_instr              : out std_ulogic;
xu_lsu_rf1_dcbst_instr              : out std_ulogic;
xu_lsu_rf1_icbi_instr               : out std_ulogic;
xu_lsu_rf1_icblc_instr              : out std_ulogic;
xu_lsu_rf1_icbt_instr               : out std_ulogic;
xu_lsu_rf1_icbtls_instr             : out std_ulogic;
xu_lsu_rf1_tlbsync_instr            : out std_ulogic;
xu_lsu_rf1_lock_instr               : out std_ulogic;
xu_lsu_rf1_mutex_hint               : out std_ulogic;
xu_lsu_rf1_algebraic                : out std_ulogic;
xu_lsu_rf1_byte_rev                 : out std_ulogic;
xu_lsu_rf1_src_gpr                  : out std_ulogic;
xu_lsu_rf1_src_axu                  : out std_ulogic;
xu_lsu_rf1_src_dp                   : out std_ulogic;
xu_lsu_rf1_targ_gpr                 : out std_ulogic;
xu_lsu_rf1_targ_axu                 : out std_ulogic;
xu_lsu_rf1_targ_dp                  : out std_ulogic;
xu_lsu_ex1_rotsel_ovrd              : out std_ulogic_vector(0 to 4);
lsu_xu_ex5_wren                     : in  std_ulogic;
lsu_xu_rel_wren                     : in  std_ulogic;
lsu_xu_rel_ta_gpr                   : in  std_ulogic_vector(0 to 7);
lsu_xu_need_hole                    : in  std_ulogic;
xu_lsu_rf1_src0_vld                 : out std_ulogic;
xu_lsu_rf1_src0_reg                 : out std_ulogic_vector(0 to 7);
xu_lsu_rf1_src1_vld                 : out std_ulogic;
xu_lsu_rf1_src1_reg                 : out std_ulogic_vector(0 to 7);
xu_lsu_rf1_targ_vld                 : out std_ulogic;
xu_lsu_rf1_targ_reg                 : out std_ulogic_vector(0 to 7);
xu_bx_ex1_mtdp_val                  : out std_ulogic;
xu_bx_ex1_mfdp_val                  : out std_ulogic;
xu_bx_ex1_ipc_thrd                 : out std_ulogic_vector(0 to 1);
xu_bx_ex2_ipc_ba                   : out std_ulogic_vector(0 to 4);
xu_bx_ex2_ipc_sz                   : out std_ulogic_vector(0 to 1);
xu_lsu_rf1_is_touch                 : out std_ulogic;
xu_lsu_rf1_is_msgsnd                : out std_ulogic;
xu_lsu_rf1_dci_instr                : out std_ulogic;
xu_lsu_rf1_ici_instr                : out std_ulogic;
xu_lsu_rf1_icswx_instr              : out std_ulogic;
xu_lsu_rf1_icswx_dot_instr          : out std_ulogic;
xu_lsu_rf1_icswx_epid               : out std_ulogic;
xu_lsu_rf1_ldawx_instr              : out std_ulogic;
xu_lsu_rf1_wclr_instr               : out std_ulogic;
xu_lsu_rf1_wchk_instr               : out std_ulogic;
xu_lsu_rf1_derat_ra_eq_ea           : out std_ulogic;
xu_lsu_rf1_cmd_act                  : out std_ulogic;
xu_lsu_rf1_data_act                 : out std_ulogic;
xu_lsu_rf1_mtspr_trace              : out std_ulogic;
xu_iu_rf1_val                       : out std_ulogic_vector(0 to threads-1);
xu_rf1_val                          : out std_ulogic_vector(0 to threads-1);
xu_rf1_is_tlbre                     : out std_ulogic;
xu_rf1_is_tlbwe                     : out std_ulogic;
xu_rf1_is_tlbsx                     : out std_ulogic;
xu_rf1_is_tlbsrx                    : out std_ulogic;
xu_rf1_is_tlbivax                   : out std_ulogic;
xu_rf1_is_tlbilx                    : out std_ulogic;
xu_rf1_is_eratre                    : out std_ulogic;
xu_rf1_is_eratwe                    : out std_ulogic;
xu_rf1_is_eratsx                    : out std_ulogic;
xu_rf1_is_eratsrx                   : out std_ulogic;
xu_rf1_is_erativax                  : out std_ulogic;
xu_rf1_is_eratilx                   : out std_ulogic;
xu_ex1_is_isync                     : out std_ulogic;
xu_ex1_is_csync                     : out std_ulogic;
xu_lsu_rf1_derat_act                : out std_ulogic;
xu_lsu_rf1_derat_is_load            : out std_ulogic;
xu_lsu_rf1_derat_is_store           : out std_ulogic;
xu_rf1_ws                           : out std_ulogic_vector(0 to 1);
xu_rf1_t                            : out std_ulogic_vector(0 to 2);
lsu_xu_is2_back_inv                 : in std_ulogic;
lsu_xu_is2_back_inv_addr            : in std_ulogic_vector(64-real_data_add to 63-cl_size);
byp_dec_rf1_xer_ca                  : in std_ulogic;
spr_dec_rf1_msr_ucle                : in std_ulogic_vector(0 to threads-1);
spr_dec_rf1_msrp_uclep              : in std_ulogic_vector(0 to threads-1);
spr_dec_rf1_epcr_dgtmi              : in std_ulogic_vector(0 to threads-1);
spr_dec_spr_xucr0_ssdly             : in std_ulogic_vector(0 to 4);
byp_xer_si                          : in std_ulogic_vector(0 to 7*threads-1);
xu_iu_ex6_pri                       : out std_ulogic_vector(0 to 2);
xu_iu_ex6_pri_val                   : out std_ulogic_vector(0 to 3);
xu_iu_need_hole                     : out std_ulogic;
fxb_fxa_ex6_clear_barrier           : out std_ulogic_vector(0 to threads-1);
xu_iu_ex5_gshare                    : out std_ulogic_vector(0 to 3);
xu_iu_ex5_getNIA                    : out std_ulogic;
xu_iu_ex5_val                       : out std_ulogic;
xu_iu_ex5_tid                       : out std_ulogic_vector(0 to threads-1);
xu_iu_ex5_br_update                 : out std_ulogic;
xu_iu_ex5_br_hist                   : out std_ulogic_vector(0 to 1);
xu_iu_ex5_bclr                      : out std_ulogic;
xu_iu_ex5_lk                        : out std_ulogic;
xu_iu_ex5_bh                        : out std_ulogic_vector(0 to 1);
pc_xu_trace_bus_enable              : in  std_ulogic;
pc_xu_instr_trace_mode              : in  std_ulogic;
pc_xu_instr_trace_tid               : in  std_ulogic_vector(0 to 1);
dec_byp_ex3_instr_trace_val         : out std_ulogic;
dec_byp_ex3_instr_trace_gate        : out std_ulogic;
dec_cpl_rf1_instr_trace_val         : out std_ulogic;
dec_cpl_rf1_instr_trace_type        : out std_ulogic_vector(0 to 1);
dec_cpl_ex3_instr_trace_val         : out std_ulogic;
xu_lsu_ex2_instr_trace_val          : out std_ulogic;
cpl_dec_in_ucode                    : in  std_ulogic_vector(0 to threads-1);
spr_bit_act                         : in  std_ulogic;
spr_msr_cm                          : in  std_ulogic_vector(0 to threads-1);
spr_ccr2_notlb                      : in  std_ulogic;
spr_ccr2_en_attn                    : in  std_ulogic;
spr_ccr2_en_ditc                    : in  std_ulogic;
spr_ccr2_en_pc                      : in  std_ulogic;
spr_ccr2_en_icswx                   : in  std_ulogic;
spr_ccr2_en_dcr                     : in  std_ulogic;
spr_xucr0_clkg_ctl                  : in  std_ulogic_vector(2 to 2);
byp_grp3_debug                      : out std_ulogic_vector(0 to 14);
byp_grp4_debug                      : out std_ulogic_vector(0 to 13);
byp_grp5_debug                      : out std_ulogic_vector(0 to 14);
dec_grp0_debug                      : out std_ulogic_vector(0 to 87);
dec_grp1_debug                      : out std_ulogic_vector(0 to 87)
    );
end xuq_dec_b;
ARCHITECTURE XUQ_DEC_B
          OF XUQ_DEC_B
          IS
--@@  Signal Declarations
SIGNAL TBL_LD_ST_DEC_PT                  : STD_ULOGIC_VECTOR(1 TO 77)  := 
(OTHERS=> 'U');
SIGNAL TBL_MASTER_DEC_PT                 : STD_ULOGIC_VECTOR(1 TO 97)  := 
(OTHERS=> 'U');
SIGNAL TBL_PRI_CHANGE_PT                 : STD_ULOGIC_VECTOR(1 TO 7)  := 
(OTHERS=> 'U');
SIGNAL TBL_RECFORM_DEC_PT                : STD_ULOGIC_VECTOR(1 TO 29)  := 
(OTHERS=> 'U');
SIGNAL TBL_VAL_STG_GATE_PT               : STD_ULOGIC_VECTOR(1 TO 47)  := 
(OTHERS=> 'U');
SIGNAL TBL_XER_DEC_PT                    : STD_ULOGIC_VECTOR(1 TO 37)  := 
(OTHERS=> 'U');
subtype s2                                                              is std_ulogic_vector(0 to 1);
subtype s3                                                              is std_ulogic_vector(0 to 2);
signal is1_need_hole_q,           is1_need_hole_d             : std_ulogic;
signal is2_need_hole_q,           is2_need_hole_d             : std_ulogic;
signal rf0_back_inv_q                                         : std_ulogic;
signal rf0_back_inv_addr_q                                    : std_ulogic_vector(64-real_data_add to 63-cl_size);
signal rf0_need_hole_q                                        : std_ulogic;
signal rf1_3src_instr_q                                       : std_ulogic;
signal rf1_act_q,                 rf0_act                     : std_ulogic;
signal rf1_axu_instr_type_q                                   : std_ulogic_vector(0 to 2);
signal rf1_axu_is_extload_q                                   : std_ulogic;
signal rf1_axu_is_extstore_q                                  : std_ulogic;
signal rf1_axu_ld_or_st_q                                     : std_ulogic;
signal rf1_axu_ldst_forcealign_q                              : std_ulogic;
signal rf1_axu_ldst_forceexcept_q                             : std_ulogic;
signal rf1_axu_ldst_indexed_q                                 : std_ulogic;
signal rf1_axu_ldst_size_q                                    : std_ulogic_vector(0 to 5);
signal rf1_axu_ldst_tag_q                                     : std_ulogic_vector(0 to 8);
signal rf1_axu_ldst_update_q                                  : std_ulogic;
signal rf1_axu_mffgpr_q                                       : std_ulogic;
signal rf1_axu_mftgpr_q                                       : std_ulogic;
signal rf1_axu_movedp_q                                       : std_ulogic;
signal rf1_axu_store_q                                        : std_ulogic;
signal rf1_back_inv_q                                         : std_ulogic;
signal rf1_back_inv_addr_q                                    : std_ulogic_vector(64-real_data_add to 63-cl_size);
signal rf1_error_q                                            : std_ulogic_vector(0 to 2);
signal rf1_gpr0_zero_q                                        : std_ulogic;
signal rf1_gshare_q                                           : std_ulogic_vector(0 to 3);
signal rf1_ifar_q                                             : std_ulogic_vector(62-eff_ifar to 61);
signal rf1_instr_q                                            : std_ulogic_vector(0 to 31);
signal rf1_instr_21to30_00_q,     rf1_instr_21to30_00_d       : std_ulogic_vector(21 to 30);
signal rf1_instr_21to30_01_q,     rf1_instr_21to30_01_d       : std_ulogic_vector(21 to 30);
signal rf1_instr_21to30_02_q,     rf1_instr_21to30_02_d       : std_ulogic_vector(21 to 30);
signal rf1_instr_21to30_03_q,     rf1_instr_21to30_03_d       : std_ulogic_vector(21 to 30);
signal rf1_instr_21to30_04_q,     rf1_instr_21to30_04_d       : std_ulogic_vector(21 to 30);
signal rf1_instr_21to30_05_q,     rf1_instr_21to30_05_d       : std_ulogic_vector(21 to 30);
signal rf1_instr_21to30_06_q,     rf1_instr_21to30_06_d       : std_ulogic_vector(21 to 30);
signal rf1_instr_21to30_07_q,     rf1_instr_21to30_07_d       : std_ulogic_vector(21 to 30);
signal rf1_instr_21to30_08_q,     rf1_instr_21to30_08_d       : std_ulogic_vector(21 to 30);
signal rf1_instr_21to30_09_q,     rf1_instr_21to30_09_d       : std_ulogic_vector(21 to 30);
signal rf1_instr_21to30_10_q,     rf1_instr_21to30_10_d       : std_ulogic_vector(21 to 30);
signal rf1_is_isel_q,             rf1_is_isel_d               : std_ulogic;
signal rf1_is_ucode_q                                         : std_ulogic;
signal rf1_issued_q                                           : std_ulogic_vector(0 to threads-1);
signal rf1_match_q                                            : std_ulogic;
signal rf1_mc_dep_chk_val_q,      rf1_mc_dep_chk_val_d        : std_ulogic_vector(0 to threads-1);
signal rf1_need_hole_q                                        : std_ulogic;
signal rf1_opcode_is_31_q,        rf1_opcode_is_31_d          : std_ulogic_vector(0 to 9);
signal rf1_pred_taken_cnt_q                                   : std_ulogic_vector(0 to 1);
signal rf1_pred_update_q                                      : std_ulogic;
signal rf1_s1_q                                               : std_ulogic_vector(0 to 7);
signal rf1_s1_vld_q                                           : std_ulogic;
signal rf1_s2_q                                               : std_ulogic_vector(0 to 7);
signal rf1_s2_vld_q                                           : std_ulogic;
signal rf1_s3_q                                               : std_ulogic_vector(0 to 7);
signal rf1_s3_vld_q                                           : std_ulogic;
signal rf1_ta_q                                               : std_ulogic_vector(0 to 7);
signal rf1_ta_vld_q                                           : std_ulogic;
signal rf1_tid_q                                              : std_ulogic_vector(0 to threads-1);
signal rf1_tid_2_q                                            : std_ulogic_vector(0 to threads-1);
signal rf1_ucode_val_q                                        : std_ulogic_vector(0 to threads-1);
signal rf1_use_imm_q                                          : std_ulogic;
signal rf1_val_q                                              : std_ulogic_vector(0 to threads-1);
signal rf1_val_iu_q                                           : std_ulogic_vector(0 to threads-1);
signal rf1_xu_epid_instr_q                                    : std_ulogic;
signal ex1_act_q,                 ex1_act_d                   : std_ulogic;
signal ex1_axu_instr_type_q,      ex1_axu_instr_type_d        : std_ulogic_vector(0 to 2);
signal ex1_axu_movedp_q                                       : std_ulogic;
signal ex1_back_inv_q                                         : std_ulogic;
signal ex1_bh_q                                               : std_ulogic_vector(0 to 1);
signal ex1_clear_barrier_q                                    : std_ulogic;
signal ex1_ddmh_en_q,             ex1_ddmh_en_d               : std_ulogic;
signal ex1_ditc_illeg_q,          ex1_ditc_illeg_d            : std_ulogic;
signal ex1_dp_indexed_q,          ex1_dp_indexed_d            : std_ulogic;
signal ex1_epid_instr_q,          ex1_epid_instr_d            : std_ulogic;
signal ex1_error_q                                            : std_ulogic_vector(0 to 2);
signal ex1_getNIA_q                                           : std_ulogic;
signal ex1_gpr_we_q,              ex1_gpr_we_d                : std_ulogic;
signal ex1_gshare_q                                           : std_ulogic_vector(0 to 3);
signal ex1_instr_q                                            : std_ulogic_vector(11 to 25);
signal ex1_instr_hypv_q                                       : std_ulogic;
signal ex1_instr_priv_q                                       : std_ulogic;
signal ex1_is_any_load_dac_q                                  : std_ulogic;
signal ex1_is_any_store_q                                     : std_ulogic;
signal ex1_is_any_store_dac_q                                 : std_ulogic;
signal ex1_is_attn_q                                          : std_ulogic;
signal ex1_is_bclr_q                                          : std_ulogic;
signal ex1_is_cmp_q                                           : std_ulogic;
signal ex1_is_csync_q,            rf1_is_csync                : std_ulogic;
signal ex1_is_eratsxr_q                                       : std_ulogic;
signal ex1_is_icswx_q,            ex1_is_icswx_d              : std_ulogic;
signal ex1_is_isync_q                                         : std_ulogic;
signal ex1_is_ld_w_update_q                                   : std_ulogic;
signal ex1_is_lmw_q                                           : std_ulogic;
signal ex1_is_lswi_q                                          : std_ulogic;
signal ex1_is_lswx_q                                          : std_ulogic;
signal ex1_is_mfcr_q                                          : std_ulogic;
signal ex1_is_mfspr_q                                         : std_ulogic;
signal ex1_is_msgclr_q                                        : std_ulogic;
signal ex1_is_msgsnd_q                                        : std_ulogic;
signal ex1_is_mtspr_q                                         : std_ulogic;
signal ex1_is_sc_q                                            : std_ulogic;
signal ex1_is_st_w_update_q                                   : std_ulogic;
signal ex1_is_ucode_q                                         : std_ulogic;
signal ex1_is_wchkall_q                                       : std_ulogic;
signal ex1_lk_q                                               : std_ulogic;
signal ex1_match_q                                            : std_ulogic;
signal ex1_mfdcr_instr_q,         rf1_mfdcr_instr             : std_ulogic;
signal ex1_mfdp_val_q,            ex1_mfdp_val_d              : std_ulogic;
signal ex1_mtdcr_instr_q,         rf1_mtdcr_instr             : std_ulogic;
signal ex1_mtdp_nr_q,             ex1_mtdp_nr_d               : std_ulogic;
signal ex1_mtdp_val_q,            ex1_mtdp_val_d              : std_ulogic;
signal ex1_muldiv_coll_q                                      : std_ulogic;
signal ex1_need_hole_q                                        : std_ulogic;
signal ex1_num_regs_q,            ex1_num_regs_d              : std_ulogic_vector(0 to 5);
signal ex1_ovr_rotsel_q,          ex1_ovr_rotsel_d            : std_ulogic;
signal ex1_pred_taken_cnt_q                                   : std_ulogic_vector(0 to 1);
signal ex1_pred_update_q                                      : std_ulogic;
signal ex1_pri_q                                              : std_ulogic_vector(0 to 2);
signal ex1_rotsel_ovrd_q,         ex1_rotsel_ovrd_d           : std_ulogic_vector(0 to 4);
signal ex1_s1_q                                               : std_ulogic_vector(0 to 7);
signal ex1_s2_q                                               : std_ulogic_vector(0 to 7);
signal ex1_s3_q                                               : std_ulogic_vector(0 to 7);
signal ex1_spr_sel_q                                          : std_ulogic;
signal ex1_ta_q                                               : std_ulogic_vector(0 to 7);
signal ex1_tid_q                                              : std_ulogic_vector(0 to threads-1);
signal ex1_tlb_data_val_q,        ex1_tlb_data_val_d          : std_ulogic;
signal ex1_tlb_illeg_q,           ex1_tlb_illeg_d             : std_ulogic;
signal ex1_trace_type_q,          rf1_trace_type              : std_ulogic_vector(0 to 1);
signal ex1_trace_val_q,           rf1_trace_val               : std_ulogic;
signal ex1_val_q,                 ex1_val_d                   : std_ulogic_vector(0 to threads-1);
signal ex1_axu_ld_or_st_q                                     : std_ulogic;
signal ex2_act_q,                 ex2_act_d                   : std_ulogic;
signal ex2_axu_instr_type_q                                   : std_ulogic_vector(0 to 2);
signal ex2_back_inv_q                                         : std_ulogic;
signal ex2_bh_q                                               : std_ulogic_vector(0 to 1);
signal ex2_clear_barrier_q                                    : std_ulogic;
signal ex2_ddmh_en_q                                          : std_ulogic;
signal ex2_ditc_illeg_q,          ex2_ditc_illeg_d            : std_ulogic;
signal ex2_error_q                                            : std_ulogic_vector(0 to 2);
signal ex2_getNIA_q                                           : std_ulogic;
signal ex2_gpr_we_q,              ex2_gpr_we_d                : std_ulogic;
signal ex2_gshare_q                                           : std_ulogic_vector(0 to 3);
signal ex2_instr_q                                            : std_ulogic_vector(12 to 25);
signal ex2_instr_hypv_q                                       : std_ulogic;
signal ex2_instr_priv_q                                       : std_ulogic;
signal ex2_ipb_ba_q,              ex2_ipb_ba_d                : std_ulogic_vector(0 to 4);
signal ex2_ipb_sz_q,              ex2_ipb_sz_d                : std_ulogic_vector(0 to 1);
signal ex2_is_any_load_dac_q                                  : std_ulogic;
signal ex2_is_any_store_q                                     : std_ulogic;
signal ex2_is_any_store_dac_q                                 : std_ulogic;
signal ex2_is_attn_q                                          : std_ulogic;
signal ex2_is_bclr_q                                          : std_ulogic;
signal ex2_is_eratsxr_q                                       : std_ulogic;
signal ex2_is_icswx_q                                         : std_ulogic;
signal ex2_is_ld_w_update_q                                   : std_ulogic;
signal ex2_is_lmw_q                                           : std_ulogic;
signal ex2_is_lswi_q                                          : std_ulogic;
signal ex2_is_lswx_q                                          : std_ulogic;
signal ex2_is_mfcr_q                                          : std_ulogic;
signal ex2_is_msgclr_q                                        : std_ulogic;
signal ex2_is_msgsnd_q                                        : std_ulogic;
signal ex2_is_sc_q                                            : std_ulogic;
signal ex2_is_st_w_update_q                                   : std_ulogic;
signal ex2_is_ucode_q                                         : std_ulogic;
signal ex2_is_wchkall_q                                       : std_ulogic;
signal ex2_lk_q                                               : std_ulogic;
signal ex2_match_q                                            : std_ulogic;
signal ex2_mfdp_val_q                                         : std_ulogic;
signal ex2_mtdp_nr_q                                          : std_ulogic;
signal ex2_mtdp_val_q                                         : std_ulogic;
signal ex2_muldiv_coll_q                                      : std_ulogic;
signal ex2_need_hole_q                                        : std_ulogic;
signal ex2_pred_taken_cnt_q                                   : std_ulogic_vector(0 to 1);
signal ex2_pred_update_q                                      : std_ulogic;
signal ex2_pri_q                                              : std_ulogic_vector(0 to 2);
signal ex2_ra_eq_rt_q,            ex2_ra_eq_rt_d              : std_ulogic;
signal ex2_ra_eq_zero_q,          ex2_ra_eq_zero_d            : std_ulogic;
signal ex2_ra_in_rng_lmw_q,       ex2_ra_in_rng_lmw_d         : std_ulogic;
signal ex2_ra_in_rng_nowrap_q,    ex2_ra_in_rng_nowrap_d      : std_ulogic;
signal ex2_ra_in_rng_wrap_q,      ex2_ra_in_rng_wrap_d        : std_ulogic;
signal ex2_range_wrap_q,          ex2_range_wrap_d            : std_ulogic;
signal ex2_rb_eq_rt_q,            ex2_rb_eq_rt_d              : std_ulogic;
signal ex2_rb_in_rng_nowrap_q,    ex2_rb_in_rng_nowrap_d      : std_ulogic;
signal ex2_rb_in_rng_wrap_q,      ex2_rb_in_rng_wrap_d        : std_ulogic;
signal ex2_slowspr_dcr_rd_q,      ex1_slowspr_dcr_rd          : std_ulogic;
signal ex2_ta_q                                               : std_ulogic_vector(0 to 7);
signal ex2_tid_q                                              : std_ulogic_vector(0 to threads-1);
signal ex2_tlb_data_val_q                                     : std_ulogic;
signal ex2_tlb_illeg_q                                        : std_ulogic;
signal ex2_trace_type_q                                       : std_ulogic_vector(0 to 1);
signal ex2_trace_val_q                                        : std_ulogic;
signal ex2_val_q,                 ex2_val_d                   : std_ulogic_vector(0 to threads-1);
signal ex3_act_q,                 ex3_act_d                   : std_ulogic;
signal ex3_axu_instr_type_q                                   : std_ulogic_vector(0 to 2);
signal ex3_back_inv_q                                         : std_ulogic;
signal ex3_bh_q                                               : std_ulogic_vector(0 to 1);
signal ex3_clear_barrier_q                                    : std_ulogic;
signal ex3_ddmh_en_q                                          : std_ulogic;
signal ex3_div_done_q                                         : std_ulogic;
signal ex3_getNIA_q                                           : std_ulogic;
signal ex3_gpr_we_q                                           : std_ulogic;
signal ex3_gshare_q                                           : std_ulogic_vector(0 to 3);
signal ex3_instr_q                                            : std_ulogic_vector(12 to 19);
signal ex3_instr_hypv_q                                       : std_ulogic;
signal ex3_instr_priv_q                                       : std_ulogic;
signal ex3_is_any_store_q                                     : std_ulogic;
signal ex3_is_bclr_q                                          : std_ulogic;
signal ex3_is_eratsxr_q                                       : std_ulogic;
signal ex3_is_mfcr_q                                          : std_ulogic;
signal ex3_is_wchkall_q                                       : std_ulogic;
signal ex3_lk_q                                               : std_ulogic;
signal ex3_mfdp_val_q                                         : std_ulogic;
signal ex3_mtdp_nr_q                                          : std_ulogic;
signal ex3_mtdp_val_q                                         : std_ulogic;
signal ex3_muldiv_coll_q                                      : std_ulogic;
signal ex3_need_hole_q                                        : std_ulogic;
signal ex3_pred_taken_cnt_q                                   : std_ulogic_vector(0 to 1);
signal ex3_pred_update_q                                      : std_ulogic;
signal ex3_pri_q                                              : std_ulogic_vector(0 to 2);
signal ex3_slowspr_dcr_rd_q                                   : std_ulogic;
signal ex3_ta_q                                               : std_ulogic_vector(0 to 7);
signal ex3_tid_q                                              : std_ulogic_vector(0 to threads-1);
signal ex3_tlb_data_val_q                                     : std_ulogic;
signal ex3_tlb_illeg_q                                        : std_ulogic;
signal ex3_trace_type_q                                       : std_ulogic_vector(0 to 1);
signal ex3_trace_val_q                                        : std_ulogic;
signal ex3_val_q,                 ex3_val_d                   : std_ulogic_vector(0 to threads-1);
signal ex4_act_q,                 ex4_act_d                   : std_ulogic;
signal ex4_bh_q                                               : std_ulogic_vector(0 to 1);
signal ex4_clear_barrier_q                                    : std_ulogic;
signal ex4_dp_instr_q,            ex4_dp_instr_d              : std_ulogic;
signal ex4_getNIA_q                                           : std_ulogic;
signal ex4_gpr_we_q,              ex4_gpr_we_d                : std_ulogic;
signal ex4_gshare_q                                           : std_ulogic_vector(0 to 3);
signal ex4_instr_q                                            : std_ulogic_vector(12 to 19);
signal ex4_is_bclr_q                                          : std_ulogic;
signal ex4_is_eratsxr_q                                       : std_ulogic;
signal ex4_is_mfcr_q                                          : std_ulogic;
signal ex4_is_wchkall_q                                       : std_ulogic;
signal ex4_lk_q                                               : std_ulogic;
signal ex4_mfdp_val_q                                         : std_ulogic;
signal ex4_mtdp_val_q                                         : std_ulogic;
signal ex4_pred_taken_cnt_q                                   : std_ulogic_vector(0 to 1);
signal ex4_pred_update_q                                      : std_ulogic;
signal ex4_pri_q                                              : std_ulogic_vector(0 to 2);
signal ex4_slowspr_dcr_rd_q                                   : std_ulogic;
signal ex4_ta_q                                               : std_ulogic_vector(0 to 7);
signal ex4_tid_q                                              : std_ulogic_vector(0 to threads-1);
signal ex4_val_q,                 ex4_val_d                   : std_ulogic_vector(0 to threads-1);
signal ex5_act_q,                 ex5_act_d                   : std_ulogic;
signal ex5_bh_q                                               : std_ulogic_vector(0 to 1);
signal ex5_clear_barrier_q                                    : std_ulogic;
signal ex5_getNIA_q                                           : std_ulogic;
signal ex5_gpr_we_q,              ex5_gpr_we_d                : std_ulogic;
signal ex5_gshare_q                                           : std_ulogic_vector(0 to 3);
signal ex5_instr_q                                            : std_ulogic_vector(12 to 19);
signal ex5_is_bclr_q                                          : std_ulogic;
signal ex5_lk_q                                               : std_ulogic;
signal ex5_pred_taken_cnt_q                                   : std_ulogic_vector(0 to 1);
signal ex5_pred_update_q                                      : std_ulogic;
signal ex5_pri_q                                              : std_ulogic_vector(0 to 2);
signal ex5_slowspr_dcr_rd_q,      ex5_slowspr_dcr_rd_d        : std_ulogic_vector(0 to threads-1);
signal ex5_ta_q                                               : std_ulogic_vector(0 to 7);
signal ex5_tid_q                                              : std_ulogic_vector(0 to threads-1);
signal ex5_val_q,                 ex5_val_d                   : std_ulogic_vector(0 to threads-1);
signal ex6_clear_barrier_q,       ex6_clear_barrier_d         : std_ulogic_vector(0 to threads-1);
signal ex6_gpr_we_q,              ex6_gpr_we_d                : std_ulogic;
signal ex6_pri_q                                              : std_ulogic_vector(0 to 2);
signal ex6_ta_q,                  ex6_ta_d                    : std_ulogic_vector(0 to 7);
signal ex6_val_q,                 ex6_val_d                   : std_ulogic_vector(0 to threads-1);
signal ex7_gpr_we_q                                           : std_ulogic;
signal ex7_ta_q                                               : std_ulogic_vector(0 to 7);
signal ex7_val_q                                              : std_ulogic_vector(0 to threads-1);
signal an_ac_dcr_val_q                                        : std_ulogic;
signal dcr_ack_q,                 dcr_ack                     : std_ulogic;
signal dcr_act_q                                              : std_ulogic;
signal dcr_etid_q                                             : std_ulogic_vector(0 to 1);
signal dcr_read_q                                             : std_ulogic;
signal dcr_val_q,                 dcr_val_d                   : std_ulogic;
signal instr_trace_mode_q                                     : std_ulogic;
signal instr_trace_tid_q                                      : std_ulogic_vector(0 to 1);
signal lsu_xu_need_hole_q,        lsu_xu_need_hole_d          : std_ulogic;
signal lsu_xu_rel_ta_gpr_q                                    : std_ulogic_vector(0 to 7);
signal lsu_xu_rel_wren_q                                      : std_ulogic;
signal mmucr0_0_tlbsel_q                                      : std_ulogic_vector(4 to 5);
signal mmucr0_1_tlbsel_q                                      : std_ulogic_vector(4 to 5);
signal mmucr0_2_tlbsel_q                                      : std_ulogic_vector(4 to 5);
signal mmucr0_3_tlbsel_q                                      : std_ulogic_vector(4 to 5);
signal slowspr_etid_q                                         : std_ulogic_vector(0 to 1);
signal slowspr_rw_q                                           : std_ulogic;
signal slowspr_val_q                                          : std_ulogic;
signal spr_ccr2_en_attn_q                                     : std_ulogic;
signal spr_ccr2_en_dcr_q                                      : std_ulogic;
signal spr_ccr2_en_ditc_q                                     : std_ulogic;
signal spr_ccr2_en_icswx_q                                    : std_ulogic;
signal spr_ccr2_en_pc_q                                       : std_ulogic;
signal spr_ccr2_notlb_q                                       : std_ulogic;
signal spr_msr_cm_q                                           : std_ulogic_vector(0 to threads-1);
signal t0_hold_ta_q                                           : std_ulogic_vector(0 to 5);
signal t1_hold_ta_q                                           : std_ulogic_vector(0 to 5);
signal t2_hold_ta_q                                           : std_ulogic_vector(0 to 5);
signal t3_hold_ta_q                                           : std_ulogic_vector(0 to 5);
signal trace_bus_enable_q                                     : std_ulogic;
signal clkg_ctl_q                                             : std_ulogic;
signal spr_bit_act_q                                          : std_ulogic;
signal spare_0_q,                  spare_0_d                  : std_ulogic_vector(0 to 15);
signal spare_1_q,                  spare_1_d                  : std_ulogic_vector(0 to 15);
constant is1_need_hole_offset                      : integer := 0;
constant is2_need_hole_offset                      : integer := is1_need_hole_offset           + 1;
constant rf0_back_inv_offset                       : integer := is2_need_hole_offset           + 1;
constant rf0_back_inv_addr_offset                  : integer := rf0_back_inv_offset            + 1;
constant rf0_need_hole_offset                      : integer := rf0_back_inv_addr_offset       + rf0_back_inv_addr_q'length;
constant rf1_act_offset                            : integer := rf0_need_hole_offset           + 1;
constant rf1_axu_ld_or_st_offset                   : integer := rf1_act_offset                 + 1;
constant rf1_back_inv_offset                       : integer := rf1_axu_ld_or_st_offset        + 1;
constant rf1_need_hole_offset                      : integer := rf1_back_inv_offset            + 1;
constant rf1_ta_vld_offset                         : integer := rf1_need_hole_offset           + 1;
constant rf1_ucode_val_offset                      : integer := rf1_ta_vld_offset              + 1;
constant rf1_val_offset                            : integer := rf1_ucode_val_offset           + rf1_ucode_val_q'length;
constant rf1_val_iu_offset                         : integer := rf1_val_offset                 + rf1_val_q'length;
constant ex1_act_offset                            : integer := rf1_val_iu_offset              + rf1_val_iu_q'length;
constant ex1_axu_instr_type_offset                 : integer := ex1_act_offset                 + 1;
constant ex1_axu_movedp_offset                     : integer := ex1_axu_instr_type_offset      + ex1_axu_instr_type_q'length;
constant ex1_back_inv_offset                       : integer := ex1_axu_movedp_offset          + 1;
constant ex1_bh_offset                             : integer := ex1_back_inv_offset            + 1;
constant ex1_clear_barrier_offset                  : integer := ex1_bh_offset                  + ex1_bh_q'length;
constant ex1_ddmh_en_offset                        : integer := ex1_clear_barrier_offset       + 1;
constant ex1_ditc_illeg_offset                     : integer := ex1_ddmh_en_offset             + 1;
constant ex1_dp_indexed_offset                     : integer := ex1_ditc_illeg_offset          + 1;
constant ex1_epid_instr_offset                     : integer := ex1_dp_indexed_offset          + 1;
constant ex1_error_offset                          : integer := ex1_epid_instr_offset          + 1;
constant ex1_getNIA_offset                         : integer := ex1_error_offset               + ex1_error_q'length;
constant ex1_gpr_we_offset                         : integer := ex1_getNIA_offset              + 1;
constant ex1_gshare_offset                         : integer := ex1_gpr_we_offset              + 1;
constant ex1_instr_offset                          : integer := ex1_gshare_offset              + ex1_gshare_q'length;
constant ex1_instr_hypv_offset                     : integer := ex1_instr_offset               + ex1_instr_q'length;
constant ex1_instr_priv_offset                     : integer := ex1_instr_hypv_offset          + 1;
constant ex1_is_any_load_dac_offset                : integer := ex1_instr_priv_offset          + 1;
constant ex1_is_any_store_offset                   : integer := ex1_is_any_load_dac_offset     + 1;
constant ex1_is_any_store_dac_offset               : integer := ex1_is_any_store_offset        + 1;
constant ex1_is_attn_offset                        : integer := ex1_is_any_store_dac_offset    + 1;
constant ex1_is_bclr_offset                        : integer := ex1_is_attn_offset             + 1;
constant ex1_is_cmp_offset                         : integer := ex1_is_bclr_offset             + 1;
constant ex1_is_csync_offset                       : integer := ex1_is_cmp_offset              + 1;
constant ex1_is_eratsxr_offset                     : integer := ex1_is_csync_offset            + 1;
constant ex1_is_icswx_offset                       : integer := ex1_is_eratsxr_offset          + 1;
constant ex1_is_isync_offset                       : integer := ex1_is_icswx_offset            + 1;
constant ex1_is_ld_w_update_offset                 : integer := ex1_is_isync_offset            + 1;
constant ex1_is_lmw_offset                         : integer := ex1_is_ld_w_update_offset      + 1;
constant ex1_is_lswi_offset                        : integer := ex1_is_lmw_offset              + 1;
constant ex1_is_lswx_offset                        : integer := ex1_is_lswi_offset             + 1;
constant ex1_is_mfcr_offset                        : integer := ex1_is_lswx_offset             + 1;
constant ex1_is_mfspr_offset                       : integer := ex1_is_mfcr_offset             + 1;
constant ex1_is_msgclr_offset                      : integer := ex1_is_mfspr_offset            + 1;
constant ex1_is_msgsnd_offset                      : integer := ex1_is_msgclr_offset           + 1;
constant ex1_is_mtspr_offset                       : integer := ex1_is_msgsnd_offset           + 1;
constant ex1_is_sc_offset                          : integer := ex1_is_mtspr_offset            + 1;
constant ex1_is_st_w_update_offset                 : integer := ex1_is_sc_offset               + 1;
constant ex1_is_ucode_offset                       : integer := ex1_is_st_w_update_offset      + 1;
constant ex1_is_wchkall_offset                     : integer := ex1_is_ucode_offset            + 1;
constant ex1_lk_offset                             : integer := ex1_is_wchkall_offset          + 1;
constant ex1_match_offset                          : integer := ex1_lk_offset                  + 1;
constant ex1_mfdcr_instr_offset                    : integer := ex1_match_offset               + 1;
constant ex1_mfdp_val_offset                       : integer := ex1_mfdcr_instr_offset         + 1;
constant ex1_mtdcr_instr_offset                    : integer := ex1_mfdp_val_offset            + 1;
constant ex1_mtdp_nr_offset                        : integer := ex1_mtdcr_instr_offset         + 1;
constant ex1_mtdp_val_offset                       : integer := ex1_mtdp_nr_offset             + 1;
constant ex1_muldiv_coll_offset                    : integer := ex1_mtdp_val_offset            + 1;
constant ex1_need_hole_offset                      : integer := ex1_muldiv_coll_offset         + 1;
constant ex1_num_regs_offset                       : integer := ex1_need_hole_offset           + 1;
constant ex1_ovr_rotsel_offset                     : integer := ex1_num_regs_offset            + ex1_num_regs_q'length;
constant ex1_pred_taken_cnt_offset                 : integer := ex1_ovr_rotsel_offset          + 1;
constant ex1_pred_update_offset                    : integer := ex1_pred_taken_cnt_offset      + ex1_pred_taken_cnt_q'length;
constant ex1_pri_offset                            : integer := ex1_pred_update_offset         + 1;
constant ex1_rotsel_ovrd_offset                    : integer := ex1_pri_offset                 + ex1_pri_q'length;
constant ex1_s1_offset                             : integer := ex1_rotsel_ovrd_offset         + ex1_rotsel_ovrd_q'length;
constant ex1_s2_offset                             : integer := ex1_s1_offset                  + ex1_s1_q'length;
constant ex1_s3_offset                             : integer := ex1_s2_offset                  + ex1_s2_q'length;
constant ex1_spr_sel_offset                        : integer := ex1_s3_offset                  + ex1_s3_q'length;
constant ex1_ta_offset                             : integer := ex1_spr_sel_offset             + 1;
constant ex1_tid_offset                            : integer := ex1_ta_offset                  + ex1_ta_q'length;
constant ex1_tlb_data_val_offset                   : integer := ex1_tid_offset                 + ex1_tid_q'length;
constant ex1_tlb_illeg_offset                      : integer := ex1_tlb_data_val_offset        + 1;
constant ex1_trace_type_offset                     : integer := ex1_tlb_illeg_offset           + 1;
constant ex1_trace_val_offset                      : integer := ex1_trace_type_offset          + ex1_trace_type_q'length;
constant ex1_val_offset                            : integer := ex1_trace_val_offset           + 1;
constant ex1_axu_ld_or_st_offset                   : integer := ex1_val_offset                 + ex1_val_q'length;
constant ex2_act_offset                            : integer := ex1_axu_ld_or_st_offset        + 1;
constant ex2_back_inv_offset                       : integer := ex2_act_offset                 + 1;
constant ex2_clear_barrier_offset                  : integer := ex2_back_inv_offset            + 1;
constant ex2_ipb_ba_offset                         : integer := ex2_clear_barrier_offset       + 1;
constant ex2_ipb_sz_offset                         : integer := ex2_ipb_ba_offset              + ex2_ipb_ba_q'length;
constant ex2_gpr_we_offset                         : integer := ex2_ipb_sz_offset              + ex2_ipb_sz_q'length;
constant ex2_is_ucode_offset                       : integer := ex2_gpr_we_offset              + 1;
constant ex2_muldiv_coll_offset                    : integer := ex2_is_ucode_offset            + 1;
constant ex2_need_hole_offset                      : integer := ex2_muldiv_coll_offset         + 1;
constant ex2_val_offset                            : integer := ex2_need_hole_offset           + 1;
constant ex3_act_offset                            : integer := ex2_val_offset                 + ex2_val_q'length;
constant ex3_axu_instr_type_offset                 : integer := ex3_act_offset                 + 1;
constant ex3_back_inv_offset                       : integer := ex3_axu_instr_type_offset      + ex3_axu_instr_type_q'length;
constant ex3_bh_offset                             : integer := ex3_back_inv_offset            + 1;
constant ex3_clear_barrier_offset                  : integer := ex3_bh_offset                  + ex3_bh_q'length;
constant ex3_ddmh_en_offset                        : integer := ex3_clear_barrier_offset       + 1;
constant ex3_div_done_offset                       : integer := ex3_ddmh_en_offset             + 1;
constant ex3_getNIA_offset                         : integer := ex3_div_done_offset            + 1;
constant ex3_gpr_we_offset                         : integer := ex3_getNIA_offset              + 1;
constant ex3_gshare_offset                         : integer := ex3_gpr_we_offset              + 1;
constant ex3_instr_offset                          : integer := ex3_gshare_offset              + ex3_gshare_q'length;
constant ex3_instr_hypv_offset                     : integer := ex3_instr_offset               + ex3_instr_q'length;
constant ex3_instr_priv_offset                     : integer := ex3_instr_hypv_offset          + 1;
constant ex3_is_any_store_offset                   : integer := ex3_instr_priv_offset          + 1;
constant ex3_is_bclr_offset                        : integer := ex3_is_any_store_offset        + 1;
constant ex3_is_eratsxr_offset                     : integer := ex3_is_bclr_offset             + 1;
constant ex3_is_mfcr_offset                        : integer := ex3_is_eratsxr_offset          + 1;
constant ex3_is_wchkall_offset                     : integer := ex3_is_mfcr_offset             + 1;
constant ex3_lk_offset                             : integer := ex3_is_wchkall_offset          + 1;
constant ex3_mfdp_val_offset                       : integer := ex3_lk_offset                  + 1;
constant ex3_mtdp_nr_offset                        : integer := ex3_mfdp_val_offset            + 1;
constant ex3_mtdp_val_offset                       : integer := ex3_mtdp_nr_offset             + 1;
constant ex3_muldiv_coll_offset                    : integer := ex3_mtdp_val_offset            + 1;
constant ex3_need_hole_offset                      : integer := ex3_muldiv_coll_offset         + 1;
constant ex3_pred_taken_cnt_offset                 : integer := ex3_need_hole_offset           + 1;
constant ex3_pred_update_offset                    : integer := ex3_pred_taken_cnt_offset      + ex3_pred_taken_cnt_q'length;
constant ex3_pri_offset                            : integer := ex3_pred_update_offset         + 1;
constant ex3_slowspr_dcr_rd_offset                 : integer := ex3_pri_offset                 + ex3_pri_q'length;
constant ex3_ta_offset                             : integer := ex3_slowspr_dcr_rd_offset      + 1;
constant ex3_tid_offset                            : integer := ex3_ta_offset                  + ex3_ta_q'length;
constant ex3_tlb_data_val_offset                   : integer := ex3_tid_offset                 + ex3_tid_q'length;
constant ex3_tlb_illeg_offset                      : integer := ex3_tlb_data_val_offset        + 1;
constant ex3_trace_type_offset                     : integer := ex3_tlb_illeg_offset           + 1;
constant ex3_trace_val_offset                      : integer := ex3_trace_type_offset          + ex3_trace_type_q'length;
constant ex3_val_offset                            : integer := ex3_trace_val_offset           + 1;
constant ex4_act_offset                            : integer := ex3_val_offset                 + ex3_val_q'length;
constant ex4_clear_barrier_offset                  : integer := ex4_act_offset                 + 1;
constant ex4_gpr_we_offset                         : integer := ex4_clear_barrier_offset       + 1;
constant ex4_val_offset                            : integer := ex4_gpr_we_offset              + 1;
constant ex5_act_offset                            : integer := ex4_val_offset                 + ex4_val_q'length;
constant ex5_bh_offset                             : integer := ex5_act_offset                 + 1;
constant ex5_clear_barrier_offset                  : integer := ex5_bh_offset                  + ex5_bh_q'length;
constant ex5_getNIA_offset                         : integer := ex5_clear_barrier_offset       + 1;
constant ex5_gpr_we_offset                         : integer := ex5_getNIA_offset              + 1;
constant ex5_gshare_offset                         : integer := ex5_gpr_we_offset              + 1;
constant ex5_instr_offset                          : integer := ex5_gshare_offset              + ex5_gshare_q'length;
constant ex5_is_bclr_offset                        : integer := ex5_instr_offset               + ex5_instr_q'length;
constant ex5_lk_offset                             : integer := ex5_is_bclr_offset             + 1;
constant ex5_pred_taken_cnt_offset                 : integer := ex5_lk_offset                  + 1;
constant ex5_pred_update_offset                    : integer := ex5_pred_taken_cnt_offset      + ex5_pred_taken_cnt_q'length;
constant ex5_pri_offset                            : integer := ex5_pred_update_offset         + 1;
constant ex5_slowspr_dcr_rd_offset                 : integer := ex5_pri_offset                 + ex5_pri_q'length;
constant ex5_ta_offset                             : integer := ex5_slowspr_dcr_rd_offset      + ex5_slowspr_dcr_rd_q'length;
constant ex5_tid_offset                            : integer := ex5_ta_offset                  + ex5_ta_q'length;
constant ex5_val_offset                            : integer := ex5_tid_offset                 + ex5_tid_q'length;
constant ex6_clear_barrier_offset                  : integer := ex5_val_offset                 + ex5_val_q'length;
constant ex6_gpr_we_offset                         : integer := ex6_clear_barrier_offset       + ex6_clear_barrier_q'length;
constant ex6_pri_offset                            : integer := ex6_gpr_we_offset              + 1;
constant ex6_ta_offset                             : integer := ex6_pri_offset                 + ex6_pri_q'length;
constant ex6_val_offset                            : integer := ex6_ta_offset                  + ex6_ta_q'length;
constant ex7_gpr_we_offset                         : integer := ex6_val_offset                 + ex6_val_q'length;
constant ex7_ta_offset                             : integer := ex7_gpr_we_offset              + 1;
constant ex7_val_offset                            : integer := ex7_ta_offset                  + ex7_ta_q'length;
constant an_ac_dcr_val_offset                      : integer := ex7_val_offset                 + ex7_val_q'length;
constant dcr_ack_offset                            : integer := an_ac_dcr_val_offset           + 1;
constant dcr_act_offset                            : integer := dcr_ack_offset                 + 1;
constant dcr_etid_offset                           : integer := dcr_act_offset                 + 1;
constant dcr_read_offset                           : integer := dcr_etid_offset                + dcr_etid_q'length;
constant dcr_val_offset                            : integer := dcr_read_offset                + 1;
constant instr_trace_mode_offset                   : integer := dcr_val_offset                 + 1;
constant instr_trace_tid_offset                    : integer := instr_trace_mode_offset        + 1;
constant lsu_xu_need_hole_offset                   : integer := instr_trace_tid_offset         + instr_trace_tid_q'length;
constant lsu_xu_rel_ta_gpr_offset                  : integer := lsu_xu_need_hole_offset        + 1;
constant lsu_xu_rel_wren_offset                    : integer := lsu_xu_rel_ta_gpr_offset       + lsu_xu_rel_ta_gpr_q'length;
constant mmucr0_0_tlbsel_offset                    : integer := lsu_xu_rel_wren_offset         + 1;
constant mmucr0_1_tlbsel_offset                    : integer := mmucr0_0_tlbsel_offset         + mmucr0_0_tlbsel_q'length;
constant mmucr0_2_tlbsel_offset                    : integer := mmucr0_1_tlbsel_offset         + mmucr0_1_tlbsel_q'length;
constant mmucr0_3_tlbsel_offset                    : integer := mmucr0_2_tlbsel_offset         + mmucr0_2_tlbsel_q'length;
constant slowspr_etid_offset                       : integer := mmucr0_3_tlbsel_offset         + mmucr0_3_tlbsel_q'length;
constant slowspr_rw_offset                         : integer := slowspr_etid_offset            + slowspr_etid_q'length;
constant slowspr_val_offset                        : integer := slowspr_rw_offset              + 1;
constant spr_ccr2_en_attn_offset                   : integer := slowspr_val_offset             + 1;
constant spr_ccr2_en_dcr_offset                    : integer := spr_ccr2_en_attn_offset        + 1;
constant spr_ccr2_en_ditc_offset                   : integer := spr_ccr2_en_dcr_offset         + 1;
constant spr_ccr2_en_icswx_offset                  : integer := spr_ccr2_en_ditc_offset        + 1;
constant spr_ccr2_en_pc_offset                     : integer := spr_ccr2_en_icswx_offset       + 1;
constant spr_ccr2_notlb_offset                     : integer := spr_ccr2_en_pc_offset          + 1;
constant spr_msr_cm_offset                         : integer := spr_ccr2_notlb_offset          + 1;
constant t0_hold_ta_offset                         : integer := spr_msr_cm_offset              + spr_msr_cm_q'length;
constant t1_hold_ta_offset                         : integer := t0_hold_ta_offset              + t0_hold_ta_q'length;
constant t2_hold_ta_offset                         : integer := t1_hold_ta_offset              + t1_hold_ta_q'length;
constant t3_hold_ta_offset                         : integer := t2_hold_ta_offset              + t2_hold_ta_q'length;
constant trace_bus_enable_offset                   : integer := t3_hold_ta_offset              + t3_hold_ta_q'length;
constant clkg_ctl_offset                           : integer := trace_bus_enable_offset        + 1;
constant spr_bit_act_offset                        : integer := clkg_ctl_offset                + 1;
constant spare_0_offset                            : integer := spr_bit_act_offset             + 1;
constant spare_1_offset                            : integer := spare_0_offset                 + spare_0_q'length;
constant xu_dec_sspr_offset                        : integer := spare_1_offset                 + spare_1_q'length;
constant scan_right                                : integer := xu_dec_sspr_offset             + 1;
signal siv                                                              : std_ulogic_vector(0 to scan_right-1);
signal sov                                                              : std_ulogic_vector(0 to scan_right-1);
signal spare_0_lclk                                                     : clk_logic;
signal spare_1_lclk                                                     : clk_logic;
signal spare_0_d1clk, spare_0_d2clk                                     : std_ulogic;
signal spare_1_d1clk, spare_1_d2clk                                     : std_ulogic;
signal rf0_opcode_is_31                                                 : std_ulogic;
signal rf1_opcode_is_31,    rf1_opcode_is_0,
           rf1_opcode_is_19,    rf1_opcode_is_62,   rf1_opcode_is_58        : boolean;
signal
    rf1_is_attn      ,    rf1_is_bc        ,    rf1_is_bclr      ,    rf1_is_dcbf      ,    rf1_is_dcbi      ,
    rf1_is_dcbst     ,    rf1_is_dcblc     ,    rf1_is_dcbt      ,    rf1_is_dcbtls    ,    rf1_is_dcbtst    ,
    rf1_is_dcbtstls  ,    rf1_is_dcbz      ,    rf1_is_dci       ,    rf1_is_eratilx   ,    rf1_is_erativax  ,
    rf1_is_eratre    ,    rf1_is_eratsx    ,    rf1_is_eratsrx   ,    rf1_is_eratwe    ,    rf1_is_ici       ,
    rf1_is_icbi      ,    rf1_is_icblc     ,    rf1_is_icbt      ,    rf1_is_icbtls    ,    rf1_is_isync     ,
    rf1_is_ld        ,    rf1_is_ldarx     ,    rf1_is_ldbrx     ,    rf1_is_ldu       ,    rf1_is_lhbrx     ,
    rf1_is_lmw       ,    rf1_is_lswi      ,    rf1_is_lswx      ,    rf1_is_lwa       ,    rf1_is_lwarx     ,
    rf1_is_lwbrx     ,    rf1_is_mfcr      ,    rf1_is_mfdp      ,    rf1_is_mfdpx     ,    rf1_is_mtdp      ,
    rf1_is_mtdpx     ,    rf1_is_mfspr     ,    rf1_is_mtcrf     ,    rf1_is_mtmsr     ,    rf1_is_mtspr     ,
    rf1_is_neg       ,    rf1_is_rfci      ,    rf1_is_rfi       ,    rf1_is_rfmci     ,    rf1_is_sc        ,
    rf1_is_std       ,    rf1_is_stdbrx    ,    rf1_is_stdcxr    ,    rf1_is_stdu      ,    rf1_is_sthbrx    ,
    rf1_is_stwcxr    ,    rf1_is_stwbrx    ,    rf1_is_subf      ,    rf1_is_subfc     ,    rf1_is_subfe     ,
    rf1_is_subfic    ,    rf1_is_subfme    ,    rf1_is_subfze    ,    rf1_is_td        ,    rf1_is_tdi       ,
    rf1_is_tlbilx    ,    rf1_is_tlbivax   ,    rf1_is_tlbre     ,    rf1_is_tlbsx     ,    rf1_is_tlbsrx    ,
                          rf1_is_tlbwe     ,    rf1_is_tlbwec    ,    rf1_is_tw        ,    rf1_is_twi       ,
    rf1_is_wrtee     ,    rf1_is_dcbstep   ,    rf1_is_dcbtep    ,    rf1_is_dcbfep    ,    rf1_is_dcbtstep  ,
    rf1_is_icbiep    ,    rf1_is_dcbzep    ,    rf1_is_rfgi      ,    rf1_is_ehpriv    ,    rf1_is_msgclr    ,
    rf1_is_msgsnd    ,    rf1_is_icswx     ,    rf1_is_icswepx   ,    rf1_is_wchkall   ,    rf1_is_wclr      ,
    rf1_is_mfdcr     ,    rf1_is_mfdcrux   ,    rf1_is_mfdcrx    ,    rf1_is_mtdcr     ,    rf1_is_mtdcrux   ,
    rf1_is_mtdcrx    ,    rf1_is_mulhd     ,    rf1_is_mulhdu    ,    rf1_is_mulhw     ,    rf1_is_mulhwu    ,
    rf1_is_mulld     ,    rf1_is_mulli     ,    rf1_is_mullw     ,    rf1_is_divd      ,    rf1_is_divdu     ,
    rf1_is_divw      ,    rf1_is_divwu     ,    rf1_is_divwe     ,    rf1_is_divweu    ,    rf1_is_divde     ,
    rf1_is_divdeu    ,    rf1_is_eratsxr   ,    rf1_is_tlbsxr    : std_ulogic;
signal tiup                                                             : std_ulogic;
signal tidn                                                             : std_ulogic;
signal rf1_add_ext                                                      : std_ulogic;
signal rf1_sub                                                          : std_ulogic;
signal rf1_is_any_store                                                 : std_ulogic;
signal rf1_is_any_load_axu                                              : std_ulogic;
signal rf1_is_any_store_axu                                             : std_ulogic;
signal rf1_is_any_load_dac                                              : std_ulogic;
signal rf1_is_any_store_dac                                             : std_ulogic;
signal rf1_imm_size                                                     : std_ulogic;
signal rf1_imm_signext                                                  : std_ulogic;
signal rf1_16b_imm                                                      : std_ulogic_vector(0 to 15);
signal rf1_64b_imm                                                      : std_ulogic_vector(0 to 63);
signal rf1_imm_sign_ext                                                 : std_ulogic_vector(0 to 63);
signal rf1_imm_shifted                                                  : std_ulogic_vector(0 to 63);
signal rf1_shift_imm                                                    : std_ulogic;
signal rf1_zero_imm                                                     : std_ulogic;
signal rf1_ones_imm                                                     : std_ulogic;
signal rf1_gpr0_zero                                                    : std_ulogic;
signal rf1_cache_acc                                                    : std_ulogic;
signal rf1_touch_drop                                                   : std_ulogic;
signal rf1_wclr_all                                                     : std_ulogic;
signal rf1_xer_ca                                                       : std_ulogic;
signal rf1_xer_ca_update                                                : std_ulogic;
signal rf1_xer_ov_update                                                : std_ulogic;
signal rf1_lk                                                           : std_ulogic;
signal rf1_bh                                                           : std_ulogic_vector(0 to 1);
signal rf1_cmp                                                          : std_ulogic;
signal rf1_cmp_lfld                                                     : std_ulogic;
signal rf1_is_st_w_update                                               : std_ulogic;
signal rf1_is_ld_w_update                                               : std_ulogic;
signal rf1_rs0_byp_cmp, rf1_rs1_byp_cmp, rf1_rs2_byp_cmp                : std_ulogic_vector(1 to 8);
signal rf1_rs0_byp_stageval, rf1_rs1_byp_stageval, rf1_rs2_byp_stageval : std_ulogic_vector(1 to 7);
signal rf1_rs0_byp_val                                                  : std_ulogic_vector(0 to 8);
signal rf1_rs1_byp_val                                                  : std_ulogic_vector(1 to 8);
signal rf1_rs2_byp_val                                                  : std_ulogic_vector(1 to 8);
signal rf1_rs0_sel                                                      : std_ulogic_vector(1 to 9);
signal rf1_rs1_sel                                                      : std_ulogic_vector(1 to 9);
signal rf1_rs2_sel                                                      : std_ulogic_vector(1 to 9);
signal rf1_cmp_uext                                                     : std_ulogic;
signal rf1_val_stg                                                      : std_ulogic;
signal rf1_val_w_ldstm                                                  : std_ulogic;
signal rf1_instr_priv                                                   : std_ulogic;
signal rf1_instr_hypv                                                   : std_ulogic;
signal rf1_use_crfld0                                                   : std_ulogic;
signal rf1_use_crfld0_nmult                                             : std_ulogic;
signal rf1_rs1_use_imm                                                  : std_ulogic;
signal ex3_tlbsel                                                       : std_ulogic_vector(12 to 13);
signal ex1_ipc_ln                                                       : std_ulogic_vector(0 to 1);
signal ex1_dp_rot_addr                                                  : std_ulogic_vector(0 to 5);
signal ex1_dp_rot_op_size                                               : std_ulogic_vector(0 to 5);
signal ex1_dp_rot_r_amt                                                 : std_ulogic_vector(0 to 5);
signal ex1_dp_rot_l_amt                                                 : std_ulogic_vector(0 to 5);
signal ex1_dp_rot_dir                                                   : std_ulogic_vector(0 to 1);
signal ex1_dp_rot_amt                                                   : std_ulogic_vector(0 to 5);
signal rf1_mfdp                                                         : std_ulogic;
signal rf1_mtdp                                                         : std_ulogic;
signal rf1_derat_is_load                                                : std_ulogic;
signal rf1_derat_is_store                                               : std_ulogic;
signal rf1_tlbsel                                                       : std_ulogic_vector(12 to 12);
signal rf1_tlb_illeg_ws                                                 : std_ulogic;
signal rf1_tlb_illeg_ws2                                                : std_ulogic;
signal rf1_tlb_illeg_ws3                                                : std_ulogic;
signal rf1_tlb_illeg_sel                                                : std_ulogic;
signal rf1_tlb_illeg_t                                                  : std_ulogic;
signal rf1_clear_barrier                                                : std_ulogic;
signal rf1_th_fld_b0                                                    : std_ulogic;
signal rf1_th_fld_c                                                     : std_ulogic;
signal rf1_th_fld_l2                                                    : std_ulogic;
signal rf1_num_bytes                                                    : std_ulogic_vector(0 to 7);
signal rf1_num_bytes_plus3                                              : std_ulogic_vector(0 to 7);
signal ex1_lower_bnd                                                    : std_ulogic_vector(0 to 5);
signal ex1_upper_bnd                                                    : std_ulogic_vector(0 to 5);
signal ex1_upper_bnd_wrap                                               : std_ulogic_vector(0 to 5);
signal ex2_ra_in_rng                                                    : std_ulogic;
signal ex2_rb_in_rng                                                    : std_ulogic;
signal slowspr_need_hole                                                : std_ulogic;
signal rf1_src0_vld                                                     : std_ulogic;
signal rf1_src0_reg                                                     : std_ulogic_vector(0 to 7);
signal rf1_src1_vld                                                     : std_ulogic;
signal rf1_src1_reg                                                     : std_ulogic_vector(0 to 7);
signal rf1_targ_vld                                                     : std_ulogic;
signal rf1_targ_reg                                                     : std_ulogic_vector(0 to 7);
signal rf1_spr_msr_cm                                                   : std_ulogic;
signal rf1_spr_sel                                                      : std_ulogic;
signal rf1_is_trap                                                      : std_ulogic;
signal rf1_cr_so_update                                                 : std_ulogic_vector(0 to 1);
signal rf1_cr_we                                                        : std_ulogic;
signal rf1_alu_cmp                                                      : std_ulogic;
signal rf1_pri                                                          : std_ulogic_vector(0 to 2);
signal rf1_instr_hypv_other                                             : std_ulogic;
signal rf1_instr_hypv_tbl                                               : std_ulogic;
signal rf1_instr_priv_other                                             : std_ulogic;
signal rf1_instr_priv_tbl                                               : std_ulogic;
signal rf1_sel                                                          : std_ulogic_vector(0 to 3);
signal rf1_imm_size_tbl                                                 : std_ulogic;
signal rf1_imm_signext_tbl                                              : std_ulogic;
signal rf1_getNIA                                                       : std_ulogic;
signal rf1_mtspr_trace                                                  : std_ulogic;
signal rf1_ldst_trgt_gate                                               : std_ulogic;
signal rf1_axu_instr_type                                               : std_ulogic_vector(0 to 2);
signal rf1_axu_ldst_forcealign                                          : std_ulogic;
signal rf1_axu_ldst_forceexcept                                         : std_ulogic;
signal rf1_axu_ldst_indexed_b                                           : std_ulogic;
signal rf1_axu_mftgpr                                                   : std_ulogic;
signal rf1_axu_mffgpr                                                   : std_ulogic;
signal rf1_axu_movedp                                                   : std_ulogic;
signal rf1_axu_ldst_size                                                : std_ulogic_vector(1 to 5);
signal rf1_axu_ldst_update                                              : std_ulogic;
signal rf1_axu_instr_priv                                               : std_ulogic;
signal ex1_is_slowspr_rd                                                : std_ulogic;
signal ex1_is_slowspr_wr                                                : std_ulogic;
signal ex5_slow_op_done                                                 : std_ulogic;
signal ex5_ta_etid                                                      : std_ulogic_vector(0 to 1);
signal ex5_hold_ta                                                      : std_ulogic_vector(t0_hold_ta_q'range);
signal dcr_val                                                          : std_ulogic;
signal rf1_xer_si_zero_b                                                : std_ulogic;
signal rf1_spr_xer_si                                                   : std_ulogic_vector(0 to 6);
signal rf1_force_64b_cmp, rf1_force_32b_cmp                             : std_ulogic;
signal rf1_trace_mtspr, rf1_trace_ldst                                  : std_ulogic;
signal instr_trace_tid                                                  : std_ulogic_vector(0 to threads-1);
signal rf1_is_touch, rf1_derat_ra_eq_ea                                 : std_ulogic;
signal rf1_target_gpr                                                   : std_ulogic_vector(0 to 8);
signal rf1_cmd_act, rf1_derat_act                                       : std_ulogic;
signal rf1_zero_imm_binv, rf1_ones_imm_binv                             : std_ulogic;
  BEGIN --@@ START OF EXECUTABLE CODE FOR XUQ_DEC_B

tiup  <=  '1';
tidn  <=  '0';
ex1_val_d                    <=  rf1_val_q and not xu_rf1_flush;
ex2_val_d                    <=  ex1_val_q and not xu_ex1_flush;
ex3_val_d                    <=  ex2_val_q and not xu_ex2_flush;
ex4_val_d                    <=  ex3_val_q and not xu_ex3_flush;
ex5_val_d                    <=  ex4_val_q and not xu_ex4_flush;
ex6_val_d                    <=  ex5_val_q and not xu_ex5_flush;
rf1_val_stg                  <=  or_reduce(rf1_val_q);
rf0_act              <=  fxa_fxb_rf0_act or rf0_back_inv_q or clkg_ctl_q;
dec_byp_rf0_act              <=  rf0_act;
ex1_act_d                    <=  rf1_act_q;
ex2_act_d                    <=  ex1_act_q;
ex3_act_d                    <=  ex2_act_q;
ex4_act_d                    <=  ex3_act_q;
ex5_act_d                    <=  ex4_act_q;
dec_alu_rf1_act              <=  rf1_act_q;
dec_alu_ex1_act              <=  ex1_act_q;
rf1_spr_msr_cm                <=  or_reduce(spr_msr_cm_q and rf1_tid_q);
rf1_cmp_lfld                  <=  rf1_instr_q(10);
rf1_force_64b_cmp             <=  rf1_is_tdi or rf1_is_td or (rf1_alu_cmp and     rf1_cmp_lfld) or rf1_back_inv_q;
rf1_force_32b_cmp             <=  rf1_is_twi or rf1_is_tw or (rf1_alu_cmp and not rf1_cmp_lfld);
dec_alu_rf1_select_64bmode    <=  (rf1_spr_msr_cm and not rf1_force_32b_cmp) or rf1_force_64b_cmp;
rf1_axu_ldst_forcealign      <=       rf1_axu_ldst_forcealign_q    and rf1_axu_ld_or_st_q;
rf1_axu_ldst_forceexcept     <=       rf1_axu_ldst_forceexcept_q   and rf1_axu_ld_or_st_q;
rf1_axu_ldst_indexed_b       <=   not(rf1_axu_ldst_indexed_q)      and rf1_axu_ld_or_st_q;
rf1_axu_mftgpr               <=       rf1_axu_mftgpr_q             and rf1_axu_ld_or_st_q;
rf1_axu_mffgpr               <=       rf1_axu_mffgpr_q             and rf1_axu_ld_or_st_q;
rf1_axu_movedp               <=       rf1_axu_movedp_q             and rf1_axu_ld_or_st_q;
rf1_axu_ldst_size            <=  gate(rf1_axu_ldst_size_q(1 to 5),     rf1_axu_ld_or_st_q);
rf1_axu_ldst_update          <=       rf1_axu_ldst_update_q        and rf1_axu_ld_or_st_q;
rf1_axu_instr_type           <=  gate(rf1_axu_instr_type_q,           (rf1_axu_ld_or_st_q or or_reduce(rf1_ucode_val_q)));
rf1_ldst_trgt_gate           <=  not(rf1_cache_acc) or rf1_is_st_w_update or rf1_axu_ldst_update;
ex1_gpr_we_d                 <=  rf1_ta_vld_q and     rf1_ldst_trgt_gate;
ex2_gpr_we_d                 <=  ex1_gpr_we_q and not ex1_slowspr_dcr_rd;
ex4_gpr_we_d                 <=  ex3_gpr_we_q;
ex5_gpr_we_d                 <=  ex4_gpr_we_q;
ex6_gpr_we_d                 <= (or_reduce(ex6_val_d) and (lsu_xu_ex5_wren or ex5_gpr_we_q)) or ex5_slow_op_done;
fxb_fxa_ex7_we0              <=  ex7_gpr_we_q;
fxb_fxa_ex7_wa0              <=  ex7_ta_q;
with instr_trace_tid_q select
      instr_trace_tid                <=  "1000"   when "00",
                                       "0100"   when "01",
                                       "0010"   when "10",
                                       "0001"   when others;
rf1_trace_val                    <=  instr_trace_mode_q and not rf1_is_ucode_q and
                                       or_reduce((rf1_val_q or rf1_ucode_val_q) and instr_trace_tid and not cpl_dec_in_ucode);
rf1_trace_mtspr                  <=  rf1_is_mtspr or rf1_is_mtmsr or rf1_is_mtcrf or rf1_is_wrtee;
rf1_trace_ldst                   <=  rf1_is_any_load_dac or rf1_is_any_store_dac or rf1_is_icswx or rf1_is_icswepx;
 WITH s2'(rf1_trace_mtspr & rf1_trace_ldst)  SELECT       rf1_trace_type                 <=  "10"     when "10",
                                       "11"     when "01",
                                       "01"     when others;
dec_cpl_rf1_instr_trace_val      <=  rf1_trace_val;
dec_byp_ex3_instr_trace_val      <=  ex3_trace_val_q and ex3_trace_type_q(0);
dec_cpl_ex3_instr_trace_val      <=  ex3_trace_val_q;
xu_lsu_ex2_instr_trace_val       <=  ex2_trace_val_q and and_reduce(ex2_trace_type_q);
dec_byp_ex3_instr_trace_gate     <=  ex3_trace_val_q and ex3_trace_type_q(0) and ex3_trace_type_q(1) and not or_reduce(spr_msr_cm_q and instr_trace_tid);
dec_cpl_rf1_instr_trace_type     <=  rf1_trace_type;
dcr_val                  <=  an_ac_dcr_val and spr_ccr2_en_dcr_q;
dcr_val_d                <=  dcr_val or (dcr_val_q and     or_reduce(ex4_val_q));
dcr_ack                  <=             (dcr_val_q and not or_reduce(ex4_val_q));
dec_byp_ex4_dcr_ack      <=  dcr_ack;
an_ac_dcr_ack            <=  dcr_ack_q;
ex5_slow_op_done         <=  (slowspr_val_q and slowspr_rw_q  ) or
                               (    dcr_ack   and     dcr_read_q);
dec_cpl_ex1_is_slowspr_wr    <=  ex1_is_slowspr_wr or (ex1_mtdcr_instr_q and spr_ccr2_en_dcr_q);
ex1_slowspr_dcr_rd       <=  ex1_is_slowspr_rd or ex1_mfdcr_instr_q;
ex5_slowspr_dcr_rd_d     <=  gate(ex4_val_q,ex4_slowspr_dcr_rd_q);
ex5_ta_etid              <=  gate(slowspr_etid_q,slowspr_val_q) or
                               gate(    dcr_etid_q,    dcr_val_q);
with ex5_ta_etid select
        ex5_hold_ta          <=  t0_hold_ta_q        when "00",
                               t1_hold_ta_q        when "01",
                               t2_hold_ta_q        when "10",
                               t3_hold_ta_q        when others;
with ex5_slow_op_done select
        ex6_ta_d             <=  ex5_ta_q                     when '0',
                               ex5_hold_ta & ex5_ta_etid    when others;
xu_iu_ex6_pri            <=  ex6_pri_q;
xu_iu_ex6_pri_val        <=  gate(ex6_val_q,or_reduce(ex6_pri_q));
xu_dec_sspr : entity work.xuq_dec_sspr(xuq_dec_sspr)
    generic map(
       expand_type                      => expand_type,
       threads                          => threads,
       ctr_size                         => spr_dec_spr_xucr0_ssdly'length)
    port map(
       nclk                             => nclk,
       d_mode_dc                        => d_mode_dc,
       delay_lclkr_dc                   => delay_lclkr_dc,
       mpw1_dc_b                        => mpw1_dc_b,
       mpw2_dc_b                        => mpw2_dc_b,
       func_sl_force => func_sl_force,
       func_sl_thold_0_b                => func_sl_thold_0_b,
       sg_0                             => sg_0,
       scan_in                          => siv(xu_dec_sspr_offset),
       scan_out                         => sov(xu_dec_sspr_offset),
       rf1_act                          => rf1_act_q,
       rf1_val                          => rf1_val_q,
       rf1_instr                        => rf1_instr_q,
       slowspr_need_hole                => slowspr_need_hole,
       spr_dec_spr_xucr0_ssdly          => spr_dec_spr_xucr0_ssdly,
       ex1_is_slowspr_rd                => ex1_is_slowspr_rd,
       ex1_is_slowspr_wr                => ex1_is_slowspr_wr,
       vdd                              => vdd,
       gnd                              => gnd);
lsu_xu_need_hole_d           <=  lsu_xu_need_hole;
is1_need_hole_d              <=  slowspr_need_hole;
is2_need_hole_d              <=  is1_need_hole_q or an_ac_dcr_val_q;
xu_iu_need_hole              <=  slowspr_need_hole or an_ac_dcr_val_q or alu_dec_div_need_hole or lsu_xu_need_hole_q;
dec_spr_ex1_is_mtspr             <=  ex1_is_mtspr_q;
dec_spr_ex1_is_mfspr             <=  ex1_is_mfspr_q;
dec_spr_ex4_val                  <=  ex4_val_q;
dec_cpl_rf1_ucode_val            <=  rf1_ucode_val_q;
ex2_is_any_load_dac              <=  ex2_is_any_load_dac_q;
ex2_is_any_store_dac             <=  ex2_is_any_store_dac_q;
dec_cpl_ex3_is_any_store         <=  ex3_is_any_store_q;
dec_cpl_ex3_instr_priv           <=  ex3_instr_priv_q;
dec_cpl_ex3_mtdp_nr              <=  ex3_mtdp_nr_q;
dec_cpl_ex3_instr_hypv           <=  ex3_instr_hypv_q;
ex1_axu_instr_type_d             <=  rf1_axu_instr_type;
dec_cpl_ex3_axu_instr_type       <=  ex3_axu_instr_type_q;
dec_cpl_rf1_issued               <=  rf1_issued_q;
dec_cpl_rf1_val                  <=  rf1_val_q;
dec_spr_rf1_val                  <=  rf1_val_q or rf1_ucode_val_q;
dec_cpl_rf1_instr                <=  rf1_instr_q;
dec_cpl_ex2_error                <=  ex2_error_q;
dec_cpl_ex2_match                <=  ex2_match_q;
dec_cpl_ex2_is_ucode             <=  ex2_is_ucode_q;
dec_fspr_ex1_instr               <=  ex1_instr_q(11 to 20);
dec_fspr_ex6_val                 <=  ex6_val_q;
xu_iu_ex5_val                <=  or_reduce(ex5_val_q and not xu_ex5_flush);
xu_iu_ex5_tid                <=  ex5_tid_q;
xu_iu_ex5_br_update          <=  ex5_pred_update_q;
xu_iu_ex5_br_hist            <=  ex5_pred_taken_cnt_q;
xu_iu_ex5_bclr               <=  ex5_is_bclr_q;
xu_iu_ex5_lk                 <=  ex5_lk_q;
xu_iu_ex5_bh                 <=  ex5_bh_q;
xu_iu_ex5_gshare             <=  ex5_gshare_q;
rf1_getNIA                   <=  rf1_is_bc and                                 
                                  (rf1_instr_q(6 to 10)  = "10100") and          
                                  (rf1_instr_q(11 to 15) = "11111") and          
                                  (rf1_instr_q(16 to 29) = "00000000000001") and 
                               not rf1_instr_q(30) and                           
                                   rf1_instr_q(31);
xu_iu_ex5_getNIA             <=  ex5_getNIA_q;
dec_byp_ex5_instr            <=  ex5_instr_q(12 to 19);
dec_byp_rf1_instr            <=  rf1_instr_q(6 to 25);
dec_byp_rf1_cr_so_update     <=  rf1_cr_so_update(0) & (rf1_cr_so_update(1) or rf1_use_crfld0);
dec_byp_ex3_val              <=  ex3_val_q;
dec_byp_rf1_cr_we            <=  rf1_cr_we or rf1_use_crfld0_nmult;
dec_byp_rf1_use_crfld0       <=  rf1_use_crfld0;
dec_byp_rf1_alu_cmp          <=  rf1_alu_cmp or rf1_use_crfld0;
dec_byp_rf1_is_mtocrf        <=  tidn;
dec_byp_rf1_byp_val(1) <=  or_reduce(rf1_tid_q and ex1_val_q);
dec_byp_rf1_byp_val(2) <=  or_reduce(rf1_tid_q and ex2_val_q);
dec_byp_rf1_byp_val(3) <=  or_reduce(rf1_tid_q and ex3_val_q);
dec_byp_ex4_is_eratsxr       <=  ex4_is_eratsxr_q;
dec_cpl_rf1_ifar             <=  rf1_ifar_q;
dec_cpl_rf1_pred_taken_cnt   <=  rf1_pred_taken_cnt_q(0);
dcdmrg : entity work.xuq_dec_dcdmrg(xuq_dec_dcdmrg)
    port map (
        i                           => rf1_instr_q,                    
        dec_alu_rf1_sel_rot_log     => open,        
        dec_alu_rf1_sh_right        => dec_alu_rf1_sh_right,           
        dec_alu_rf1_sh_word         => dec_alu_rf1_sh_word,            
        dec_alu_rf1_sgnxtd_byte     => dec_alu_rf1_sgnxtd_byte,        
        dec_alu_rf1_sgnxtd_half     => dec_alu_rf1_sgnxtd_half,        
        dec_alu_rf1_sgnxtd_wd       => dec_alu_rf1_sgnxtd_wd,          
        dec_alu_rf1_sra_dw          => dec_alu_rf1_sra_dw,             
        dec_alu_rf1_sra_wd          => dec_alu_rf1_sra_wd,             
        dec_alu_rf1_chk_shov_dw     => dec_alu_rf1_chk_shov_dw,        
        dec_alu_rf1_chk_shov_wd     => dec_alu_rf1_chk_shov_wd,        
        dec_alu_rf1_use_me_ins_hi   => dec_alu_rf1_use_me_ins_hi,      
        dec_alu_rf1_use_me_ins_lo   => dec_alu_rf1_use_me_ins_lo,      
        dec_alu_rf1_use_mb_ins_hi   => dec_alu_rf1_use_mb_ins_hi,      
        dec_alu_rf1_use_mb_ins_lo   => dec_alu_rf1_use_mb_ins_lo,      
        dec_alu_rf1_use_me_rb_hi    => dec_alu_rf1_use_me_rb_hi,       
        dec_alu_rf1_use_me_rb_lo    => dec_alu_rf1_use_me_rb_lo,       
        dec_alu_rf1_use_mb_rb_hi    => dec_alu_rf1_use_mb_rb_hi,       
        dec_alu_rf1_use_mb_rb_lo    => dec_alu_rf1_use_mb_rb_lo,       
        dec_alu_rf1_use_rb_amt_hi   => dec_alu_rf1_use_rb_amt_hi,      
        dec_alu_rf1_use_rb_amt_lo   => dec_alu_rf1_use_rb_amt_lo,      
        dec_alu_rf1_zm_ins          => dec_alu_rf1_zm_ins,             
        dec_alu_rf1_cr_logical      => dec_alu_rf1_cr_logical,         
        dec_alu_rf1_cr_log_fcn      => dec_alu_rf1_cr_log_fcn,         
        dec_alu_rf1_log_fcn         => dec_alu_rf1_log_fcn,            
        dec_alu_rf1_me_ins_b        => dec_alu_rf1_me_ins_b,           
        dec_alu_rf1_mb_ins          => dec_alu_rf1_mb_ins,             
        dec_alu_rf1_sh_amt          => dec_alu_rf1_sh_amt,             
        dec_alu_rf1_mb_gt_me        => dec_alu_rf1_mb_gt_me);
rf1_is_isel_d                <=  '1' when fxa_fxb_rf0_instr(0  to 5)  = "011111" and 
                                            fxa_fxb_rf0_instr(26 to 30) = "01111"  else '0';
dec_rf1_is_isel              <=  rf1_is_isel_q;
dec_alu_rf1_xer_ov_update    <=  rf1_xer_ov_update;
dec_alu_rf1_xer_ca_update    <=  rf1_xer_ca_update;
dec_rf1_tid                  <=  rf1_tid_2_q;
dec_ex1_tid                  <=  ex1_tid_q;
dec_ex2_tid                  <=  ex2_tid_q;
dec_ex3_tid                  <=  ex3_tid_q;
dec_ex4_tid                  <=  ex4_tid_q;
dec_ex5_tid                  <=  ex5_tid_q;
dec_byp_ex4_is_mfcr          <=  ex4_is_mfcr_q;
rf1_xer_si_zero_b            <=  or_reduce(rf1_spr_xer_si);
rf1_spr_xer_si               <=  (byp_xer_si(0  to 6)  and (0  to 6  => rf1_tid_q(0))) or
                                   (byp_xer_si(7  to 13) and (7  to 13 => rf1_tid_q(1))) or
                                   (byp_xer_si(14 to 20) and (14 to 20 => rf1_tid_q(2))) or
                                   (byp_xer_si(21 to 27) and (21 to 27 => rf1_tid_q(3)));
rf1_lk                       <=  rf1_instr_q(31);
rf1_bh                       <=  rf1_instr_q(19 to 20);
rf1_instr_hypv_other         <=  ((rf1_is_tlbwe  or rf1_is_tlbsrx   or rf1_is_tlbwec   or rf1_is_tlbilx                  ) and or_reduce(spr_dec_rf1_epcr_dgtmi and rf1_val_q)) or
                                   ((rf1_is_dcblc  or rf1_is_dcbtls   or rf1_is_dcbtstls or rf1_is_icblc   or rf1_is_icbtls) and or_reduce(spr_dec_rf1_msrp_uclep and rf1_val_q));
rf1_instr_hypv               <=  rf1_instr_hypv_tbl or rf1_instr_hypv_other;
rf1_axu_instr_priv           <=  rf1_axu_is_extstore_q or rf1_axu_is_extload_q or rf1_axu_movedp_q;
rf1_instr_priv_other         <=  (rf1_is_dcblc or rf1_is_dcbtls or rf1_is_dcbtstls or rf1_is_icblc or rf1_is_icbtls)
                                     and not or_reduce(spr_dec_rf1_msr_ucle and rf1_val_q);
rf1_instr_priv               <=  rf1_instr_priv_tbl or rf1_instr_priv_other or (rf1_axu_ld_or_st_q and rf1_axu_instr_priv);
rf1_mfdcr_instr              <=  rf1_is_mfdcr or rf1_is_mfdcrux or rf1_is_mfdcrx;
rf1_mtdcr_instr              <=  rf1_is_mtdcr or rf1_is_mtdcrux or rf1_is_mtdcrx;
 WITH s2'(rf1_is_lswi & rf1_is_lswx)  SELECT         rf1_num_bytes            <=  "00" & not or_reduce(rf1_instr_q(16 to 20)) & rf1_instr_q(16 to 20)  when "10",      
                                   '0'  & rf1_spr_xer_si                                                when "01",      
                                   (others=>tidn)                                                       when others;
rf1_num_bytes_plus3          <=  std_ulogic_vector(unsigned(rf1_num_bytes) + 3);
ex1_num_regs_d               <=  rf1_num_bytes_plus3(0 to 5);
ex1_lower_bnd                <=  ex1_ta_q(0 to 5);
ex1_upper_bnd                <=  std_ulogic_vector(unsigned(ex1_lower_bnd) + unsigned(ex1_num_regs_q));
ex1_upper_bnd_wrap           <=  '0' & ex1_upper_bnd(1 to 5);
ex2_range_wrap_d             <=  ex1_upper_bnd(0);
ex2_ra_in_rng_lmw_d          <=  '1' when ex1_s1_q(0 to 5) >= ex1_lower_bnd       else '0';
ex2_ra_in_rng_nowrap_d       <=  '1' when (ex1_s1_q(0 to 5) >= ex1_lower_bnd) and
                                            (ex1_s1_q(0 to 5) <  ex1_upper_bnd)     else '0';
ex2_ra_in_rng_wrap_d         <=  '1' when (ex1_s1_q(0 to 5) <  ex1_upper_bnd_wrap)else '0';
ex2_ra_in_rng                <=  (ex2_ra_in_rng_nowrap_q                         ) or
                                   (ex2_ra_in_rng_wrap_q   and     ex2_range_wrap_q);
ex2_rb_in_rng_nowrap_d       <=  '1' when (ex1_s2_q(0 to 5) >= ex1_lower_bnd) and
                                            (ex1_s2_q(0 to 5) <  ex1_upper_bnd)     else '0';
ex2_rb_in_rng_wrap_d         <=  '1' when (ex1_s2_q(0 to 5) <  ex1_upper_bnd_wrap)else '0';
ex2_rb_in_rng                <=  (ex2_rb_in_rng_nowrap_q                         ) or
                                   (ex2_rb_in_rng_wrap_q   and     ex2_range_wrap_q);
ex2_ra_eq_zero_d             <=  '1' when ex1_s1_q(0 to 5) = "000000"             else '0';
ex2_ra_eq_rt_d               <=          (ex1_s1_q(0 to 5) = ex1_ta_q(0 to 5)) and not ex1_axu_ld_or_st_q;
ex2_rb_eq_rt_d               <=  '1' when ex1_s2_q(0 to 5) = ex1_ta_q(0 to 5)     else '0';
ex1_ditc_illeg_d             <=  (rf1_is_mfdp or rf1_is_mfdpx or rf1_is_mtdp or rf1_is_mtdpx) and 
                                    not rf1_instr_q(20) and rf1_instr_q(16);
ex2_ditc_illeg_d             <=  (ex1_axu_ld_or_st_q and ex1_axu_movedp_q and not ex1_ovr_rotsel_q) or    
                                    ex1_ditc_illeg_q;
dec_cpl_ex2_illegal_op       <=      ex2_ditc_illeg_q
                                   or (ex2_is_icswx_q                       and not spr_ccr2_en_icswx_q)
                                   or (ex2_is_attn_q                        and not spr_ccr2_en_attn_q)
                                   or ((ex2_mtdp_val_q or ex2_mfdp_val_q)   and not spr_ccr2_en_ditc_q)
                                   or ((ex2_is_msgsnd_q or ex2_is_msgclr_q) and not spr_ccr2_en_pc_q)
                                   or (ex2_is_st_w_update_q                 and  ex2_ra_eq_zero_q)                        
                                   or (ex2_is_ld_w_update_q                 and (ex2_ra_eq_zero_q or                      
                                                                                 ex2_ra_eq_rt_q))
                                   or (ex2_is_lmw_q                         and  ex2_ra_in_rng_lmw_q)                     
                                   or (ex2_is_lswi_q                        and  ex2_ra_in_rng)                         
                                   or (ex2_is_lswx_q                        and (ex2_ra_eq_rt_q   or                      
                                                                                 ex2_rb_eq_rt_q   or
                                                                                 ex2_ra_in_rng  or
                                                                                 ex2_rb_in_rng))
                                   or (ex2_is_sc_q                          and or_reduce(ex2_instr_q(20 to 25)));
rf1_rs1_use_imm              <=  rf1_use_imm_q or
                                   rf1_axu_ldst_indexed_b or
                                   rf1_back_inv_q;
rf1_gpr0_zero                 <=  rf1_gpr0_zero_q or rf1_back_inv_q;
rf1_rs0_byp_cmp(1) <=  '1' when rf1_s1_q = ex1_ta_q             else '0';
rf1_rs0_byp_cmp(2) <=  '1' when rf1_s1_q = ex2_ta_q             else '0';
rf1_rs0_byp_cmp(3) <=  '1' when rf1_s1_q = ex3_ta_q             else '0';
rf1_rs0_byp_cmp(4) <=  '1' when rf1_s1_q = ex4_ta_q             else '0';
rf1_rs0_byp_cmp(5) <=  '1' when rf1_s1_q = ex5_ta_q             else '0';
rf1_rs0_byp_cmp(6) <=  '1' when rf1_s1_q = ex6_ta_q             else '0';
rf1_rs0_byp_cmp(7) <=  '1' when rf1_s1_q = ex7_ta_q             else '0';
rf1_rs0_byp_cmp(8) <=  '1' when rf1_s1_q = lsu_xu_rel_ta_gpr_q  else '0';
rf1_rs0_byp_stageval(1) <=  or_reduce(ex1_val_q) and ex1_gpr_we_q;
rf1_rs0_byp_stageval(2) <=  or_reduce(ex2_val_q) and ex2_gpr_we_q;
rf1_rs0_byp_stageval(3) <=  or_reduce(ex3_val_q) and ex3_gpr_we_q;
rf1_rs0_byp_stageval(4) <=  or_reduce(ex4_val_q) and ex4_gpr_we_q;
rf1_rs0_byp_stageval(5) <=  or_reduce(ex5_val_q) and ex5_gpr_we_q;
rf1_rs0_byp_stageval(6) <=  or_reduce(ex6_val_q) and ex6_gpr_we_q;
rf1_rs0_byp_stageval(7) <=  or_reduce(ex7_val_q) and ex7_gpr_we_q;
rf1_rs0_byp_val(0) <=  rf1_gpr0_zero;
rf1_rs0_byp_val(1) <=  rf1_rs0_byp_stageval(1) and rf1_s1_vld_q and rf1_rs0_byp_cmp(1);
rf1_rs0_byp_val(2) <=  rf1_rs0_byp_stageval(2) and rf1_s1_vld_q and rf1_rs0_byp_cmp(2);
rf1_rs0_byp_val(3) <=  rf1_rs0_byp_stageval(3) and rf1_s1_vld_q and rf1_rs0_byp_cmp(3);
rf1_rs0_byp_val(4) <=  rf1_rs0_byp_stageval(4) and rf1_s1_vld_q and rf1_rs0_byp_cmp(4);
rf1_rs0_byp_val(5) <=  rf1_rs0_byp_stageval(5) and rf1_s1_vld_q and rf1_rs0_byp_cmp(5);
rf1_rs0_byp_val(6) <=  rf1_rs0_byp_stageval(6) and rf1_s1_vld_q and rf1_rs0_byp_cmp(6);
rf1_rs0_byp_val(7) <=  rf1_rs0_byp_stageval(7) and rf1_s1_vld_q and rf1_rs0_byp_cmp(7);
rf1_rs0_byp_val(8) <=  lsu_xu_rel_wren_q       and rf1_s1_vld_q and rf1_rs0_byp_cmp(8);
rf1_rs0_sel(1) <=   rf1_rs0_byp_val(1) and not           rf1_rs0_byp_val(0);
rf1_rs0_sel(2) <=   rf1_rs0_byp_val(2) and not or_reduce(rf1_rs0_byp_val(0 to 1));
rf1_rs0_sel(3) <=   rf1_rs0_byp_val(3) and not or_reduce(rf1_rs0_byp_val(0 to 2));
rf1_rs0_sel(4) <=   rf1_rs0_byp_val(4) and not or_reduce(rf1_rs0_byp_val(0 to 3));
rf1_rs0_sel(5) <=   rf1_rs0_byp_val(5) and not or_reduce(rf1_rs0_byp_val(0 to 4));
rf1_rs0_sel(6) <=   rf1_rs0_byp_val(6) and not or_reduce(rf1_rs0_byp_val(0 to 5));
rf1_rs0_sel(7) <=   rf1_rs0_byp_val(7) and not or_reduce(rf1_rs0_byp_val(0 to 6));
rf1_rs0_sel(8) <=   rf1_rs0_byp_val(8) and not or_reduce(rf1_rs0_byp_val(0 to 7));
rf1_rs0_sel(9) <=                          not or_reduce(rf1_rs0_byp_val(0 to 8));
dec_byp_rf1_rs0_sel   <=  rf1_rs0_sel(1 to 9);
rf1_rs1_byp_cmp(1) <=  '1' when rf1_s2_q = ex1_ta_q             else '0';
rf1_rs1_byp_cmp(2) <=  '1' when rf1_s2_q = ex2_ta_q             else '0';
rf1_rs1_byp_cmp(3) <=  '1' when rf1_s2_q = ex3_ta_q             else '0';
rf1_rs1_byp_cmp(4) <=  '1' when rf1_s2_q = ex4_ta_q             else '0';
rf1_rs1_byp_cmp(5) <=  '1' when rf1_s2_q = ex5_ta_q             else '0';
rf1_rs1_byp_cmp(6) <=  '1' when rf1_s2_q = ex6_ta_q             else '0';
rf1_rs1_byp_cmp(7) <=  '1' when rf1_s2_q = ex7_ta_q             else '0';
rf1_rs1_byp_cmp(8) <=  '1' when rf1_s2_q = lsu_xu_rel_ta_gpr_q  else '0';
rf1_rs1_byp_stageval(1) <=  or_reduce(ex1_val_q) and ex1_gpr_we_q;
rf1_rs1_byp_stageval(2) <=  or_reduce(ex2_val_q) and ex2_gpr_we_q;
rf1_rs1_byp_stageval(3) <=  or_reduce(ex3_val_q) and ex3_gpr_we_q;
rf1_rs1_byp_stageval(4) <=  or_reduce(ex4_val_q) and ex4_gpr_we_q;
rf1_rs1_byp_stageval(5) <=  or_reduce(ex5_val_q) and ex5_gpr_we_q;
rf1_rs1_byp_stageval(6) <=  or_reduce(ex6_val_q) and ex6_gpr_we_q;
rf1_rs1_byp_stageval(7) <=  or_reduce(ex7_val_q) and ex7_gpr_we_q;
rf1_rs1_byp_val(1) <=  rf1_rs1_byp_stageval(1) and rf1_s2_vld_q and rf1_rs1_byp_cmp(1);
rf1_rs1_byp_val(2) <=  rf1_rs1_byp_stageval(2) and rf1_s2_vld_q and rf1_rs1_byp_cmp(2);
rf1_rs1_byp_val(3) <=  rf1_rs1_byp_stageval(3) and rf1_s2_vld_q and rf1_rs1_byp_cmp(3);
rf1_rs1_byp_val(4) <=  rf1_rs1_byp_stageval(4) and rf1_s2_vld_q and rf1_rs1_byp_cmp(4);
rf1_rs1_byp_val(5) <=  rf1_rs1_byp_stageval(5) and rf1_s2_vld_q and rf1_rs1_byp_cmp(5);
rf1_rs1_byp_val(6) <=  rf1_rs1_byp_stageval(6) and rf1_s2_vld_q and rf1_rs1_byp_cmp(6);
rf1_rs1_byp_val(7) <=  rf1_rs1_byp_stageval(7) and rf1_s2_vld_q and rf1_rs1_byp_cmp(7);
rf1_rs1_byp_val(8) <=  lsu_xu_rel_wren_q       and rf1_s2_vld_q and rf1_rs1_byp_cmp(8);
rf1_rs1_sel(1) <=   rf1_rs1_byp_val(1);
rf1_rs1_sel(2) <=   rf1_rs1_byp_val(2) and not           rf1_rs1_byp_val(1);
rf1_rs1_sel(3) <=   rf1_rs1_byp_val(3) and not or_reduce(rf1_rs1_byp_val(1 to 2));
rf1_rs1_sel(4) <=   rf1_rs1_byp_val(4) and not or_reduce(rf1_rs1_byp_val(1 to 3));
rf1_rs1_sel(5) <=   rf1_rs1_byp_val(5) and not or_reduce(rf1_rs1_byp_val(1 to 4));
rf1_rs1_sel(6) <=   rf1_rs1_byp_val(6) and not or_reduce(rf1_rs1_byp_val(1 to 5));
rf1_rs1_sel(7) <=   rf1_rs1_byp_val(7) and not or_reduce(rf1_rs1_byp_val(1 to 6));
rf1_rs1_sel(8) <=   rf1_rs1_byp_val(8) and not or_reduce(rf1_rs1_byp_val(1 to 7));
rf1_rs1_sel(9) <=                          not or_reduce(rf1_rs1_byp_val(1 to 8));
dec_byp_rf1_rs1_sel   <=  rf1_rs1_sel(1 to 9) & rf1_rs1_use_imm;
rf1_rs2_byp_cmp(1) <=  '1' when rf1_s3_q = ex1_ta_q             else '0';
rf1_rs2_byp_cmp(2) <=  '1' when rf1_s3_q = ex2_ta_q             else '0';
rf1_rs2_byp_cmp(3) <=  '1' when rf1_s3_q = ex3_ta_q             else '0';
rf1_rs2_byp_cmp(4) <=  '1' when rf1_s3_q = ex4_ta_q             else '0';
rf1_rs2_byp_cmp(5) <=  '1' when rf1_s3_q = ex5_ta_q             else '0';
rf1_rs2_byp_cmp(6) <=  '1' when rf1_s3_q = ex6_ta_q             else '0';
rf1_rs2_byp_cmp(7) <=  '1' when rf1_s3_q = ex7_ta_q             else '0';
rf1_rs2_byp_cmp(8) <=  '1' when rf1_s3_q = lsu_xu_rel_ta_gpr_q  else '0';
rf1_rs2_byp_stageval(1) <=  or_reduce(ex1_val_q) and ex1_gpr_we_q;
rf1_rs2_byp_stageval(2) <=  or_reduce(ex2_val_q) and ex2_gpr_we_q;
rf1_rs2_byp_stageval(3) <=  or_reduce(ex3_val_q) and ex3_gpr_we_q;
rf1_rs2_byp_stageval(4) <=  or_reduce(ex4_val_q) and ex4_gpr_we_q;
rf1_rs2_byp_stageval(5) <=  or_reduce(ex5_val_q) and ex5_gpr_we_q;
rf1_rs2_byp_stageval(6) <=  or_reduce(ex6_val_q) and ex6_gpr_we_q;
rf1_rs2_byp_stageval(7) <=  or_reduce(ex7_val_q) and ex7_gpr_we_q;
rf1_rs2_byp_val(1) <=  rf1_rs2_byp_stageval(1) and rf1_s3_vld_q and rf1_rs2_byp_cmp(1);
rf1_rs2_byp_val(2) <=  rf1_rs2_byp_stageval(2) and rf1_s3_vld_q and rf1_rs2_byp_cmp(2);
rf1_rs2_byp_val(3) <=  rf1_rs2_byp_stageval(3) and rf1_s3_vld_q and rf1_rs2_byp_cmp(3);
rf1_rs2_byp_val(4) <=  rf1_rs2_byp_stageval(4) and rf1_s3_vld_q and rf1_rs2_byp_cmp(4);
rf1_rs2_byp_val(5) <=  rf1_rs2_byp_stageval(5) and rf1_s3_vld_q and rf1_rs2_byp_cmp(5);
rf1_rs2_byp_val(6) <=  rf1_rs2_byp_stageval(6) and rf1_s3_vld_q and rf1_rs2_byp_cmp(6);
rf1_rs2_byp_val(7) <=  rf1_rs2_byp_stageval(7) and rf1_s3_vld_q and rf1_rs2_byp_cmp(7);
rf1_rs2_byp_val(8) <=  lsu_xu_rel_wren_q       and rf1_s3_vld_q and rf1_rs2_byp_cmp(8);
rf1_rs2_sel(1) <=   rf1_rs2_byp_val(1);
rf1_rs2_sel(2) <=   rf1_rs2_byp_val(2) and not           rf1_rs2_byp_val(1);
rf1_rs2_sel(3) <=   rf1_rs2_byp_val(3) and not or_reduce(rf1_rs2_byp_val(1 to 2));
rf1_rs2_sel(4) <=   rf1_rs2_byp_val(4) and not or_reduce(rf1_rs2_byp_val(1 to 3));
rf1_rs2_sel(5) <=   rf1_rs2_byp_val(5) and not or_reduce(rf1_rs2_byp_val(1 to 4));
rf1_rs2_sel(6) <=   rf1_rs2_byp_val(6) and not or_reduce(rf1_rs2_byp_val(1 to 5));
rf1_rs2_sel(7) <=   rf1_rs2_byp_val(7) and not or_reduce(rf1_rs2_byp_val(1 to 6));
rf1_rs2_sel(8) <=   rf1_rs2_byp_val(8) and not or_reduce(rf1_rs2_byp_val(1 to 7));
rf1_rs2_sel(9) <=                          not or_reduce(rf1_rs2_byp_val(1 to 8));
dec_byp_rf1_rs2_sel   <=  rf1_rs2_sel(1 to 9);
dec_alu_rf1_sel(0) <=  rf1_sel(0) or rf1_axu_ld_or_st_q or rf1_back_inv_q;
dec_alu_rf1_sel(1 TO 3) <=  rf1_sel(1 to 3);
dec_alu_ex1_is_cmp           <=  ex1_is_cmp_q;
rf1_xer_ca                   <=  byp_dec_rf1_xer_ca;
 WITH s2'(rf1_add_ext & rf1_sub)  SELECT        dec_alu_rf1_add_ci       <=  rf1_xer_ca           when "10",
                                  '1'                  when "01",
                                  '0'                  when others;
dec_alu_rf1_add_rs0_inv     <=  (others=>
                                 (rf1_is_subf or rf1_is_subfc or rf1_is_subfe or
                                  rf1_is_subfic or rf1_is_subfme or rf1_is_subfze or
                                  rf1_is_neg or rf1_cmp));
rf1_is_tlbsxr                <=  rf1_is_tlbsx and rf1_instr_q(31);
rf1_is_eratsxr               <=  rf1_is_eratsx and rf1_instr_q(31);
xu_mm_rf1_is_tlbsxr          <=  rf1_is_tlbsxr;
dec_alu_rf1_is_cmpl          <=  rf1_cmp_uext;
dec_alu_rf1_tw_cmpsel        <=  rf1_is_trap & rf1_instr_q(6 to 10);
dec_byp_ex1_spr_sel          <=  ex1_spr_sel_q;
xu_lsu_rf1_mtspr_trace       <=  rf1_mtspr_trace;
dec_alu_rf1_mul_ret          <=  rf1_is_mulhw or rf1_is_mulhwu or rf1_is_mulhd or rf1_is_mulhdu;
dec_alu_rf1_mul_size         <=  rf1_is_mulld or rf1_is_mulhd or rf1_is_mulhdu or rf1_is_mulli;
dec_alu_rf1_mul_imm          <=  rf1_is_mulli;
dec_alu_rf1_mul_sign         <=  not (rf1_is_mulhdu or rf1_is_mulhwu);
dec_alu_rf1_mul_recform      <=  rf1_instr_q(31) and
                                   (rf1_is_mulhd  or rf1_is_mulhdu or rf1_is_mulhw  or
                                    rf1_is_mulhwu or rf1_is_mulld  or rf1_is_mullw);
dec_alu_rf1_div_size         <=  rf1_is_divd  or rf1_is_divdu  or
                                   rf1_is_divde or rf1_is_divdeu;
dec_alu_rf1_div_extd         <=  rf1_is_divde or rf1_is_divdeu or
                                   rf1_is_divwe or rf1_is_divweu;
dec_alu_rf1_div_sign         <=  rf1_is_divw  or rf1_is_divd  or
                                   rf1_is_divwe or rf1_is_divde;
dec_alu_rf1_div_recform      <=  rf1_instr_q(31) and
                                   (rf1_is_divd  or rf1_is_divdu  or
                                    rf1_is_divw  or rf1_is_divwu  or
                                    rf1_is_divde or rf1_is_divdeu or
                                    rf1_is_divwe or rf1_is_divweu);
dec_cpl_ex3_mult_coll        <=  ex3_muldiv_coll_q or                                             
                                  ((ex3_div_done_q or alu_ex3_mul_done) and ex3_need_hole_q);
rf1_imm_size                 <=  rf1_imm_size_tbl or rf1_axu_ldst_indexed_b;
rf1_imm_signext              <=  rf1_imm_signext_tbl or rf1_axu_ldst_indexed_b;
 WITH (rf1_is_std or rf1_is_stdu or rf1_is_lwa or rf1_is_ld or rf1_is_ldu)  SELECT         rf1_16b_imm              <=  rf1_instr_q(16 to 31)                         when '0',
                                   rf1_instr_q(16 to 29) & (30 to 31 => tidn)    when others;
with rf1_back_inv_q select
        rf1_64b_imm              <=  (0 to (63-real_data_add) => '0')  & rf1_back_inv_addr_q & ((64-cl_size) to 63 => '0') when '1',
                                   (0 to 37 => '0') & rf1_instr_q(6 to 31)                                               when others;
 WITH s2'((rf1_imm_size and not rf1_back_inv_q) & rf1_imm_signext)  SELECT         rf1_imm_sign_ext         <=  (0 to 47 => rf1_16b_imm(0)) & rf1_16b_imm     when "11",
                                   (0 to 47 => '0')            & rf1_16b_imm     when "10",
                                   rf1_64b_imm                                   when others;
 WITH (rf1_shift_imm and not rf1_back_inv_q)  SELECT         rf1_imm_shifted          <=  rf1_imm_sign_ext                                when '0',
                                   rf1_imm_sign_ext(16 to 63) & (48 to 63 => '0')  when others;
rf1_zero_imm_binv            <=  rf1_zero_imm and not rf1_back_inv_q;
rf1_ones_imm_binv            <=  rf1_ones_imm and not rf1_back_inv_q;
dec_byp_rf1_imm              <=  (rf1_imm_shifted(64-regsize to 63) and (not (64-regsize to 63 => rf1_zero_imm_binv))) or (64-regsize to 63 => rf1_ones_imm_binv);
dec_byp_ex4_is_wchkall       <=  ex4_is_wchkall_q;
rf1_mfdp                     <=  rf1_is_mfdp or rf1_is_mfdpx or (rf1_axu_mffgpr and rf1_axu_movedp);
rf1_mtdp                     <=  rf1_is_mtdp or rf1_is_mtdpx or (rf1_axu_mftgpr and rf1_axu_movedp);
ex1_mtdp_nr_d                <= (rf1_is_mtdp or rf1_is_mtdpx) and not rf1_instr_q(31);
ex1_mtdp_val_d               <=  rf1_mtdp;
ex1_mfdp_val_d               <=  rf1_mfdp;
ex4_dp_instr_d               <=  ex3_mtdp_val_q or ex3_mfdp_val_q;
dec_byp_ex4_dp_instr         <=  ex4_dp_instr_q and spr_ccr2_en_ditc_q;
dec_byp_ex4_mtdp_val         <=  ex4_mtdp_val_q and spr_ccr2_en_ditc_q and or_reduce(ex4_val_q);
dec_byp_ex4_mfdp_val         <=  ex4_mfdp_val_q and spr_ccr2_en_ditc_q and or_reduce(ex4_val_q);
xu_bx_ex1_mtdp_val           <=  ex1_mtdp_val_q and or_reduce(ex2_val_d);
xu_bx_ex1_mfdp_val           <=  ex1_mfdp_val_q and or_reduce(ex2_val_d);
xu_bx_ex1_ipc_thrd          <=  "00" when ex1_tid_q = "1000" else
                                   "01" when ex1_tid_q = "0100" else
                                   "10" when ex1_tid_q = "0010" else
                                   "11" when ex1_tid_q = "0001" else
                                   "00";
ex1_dp_indexed_d             <=  rf1_is_mtdpx or rf1_is_mfdpx or
                                  ((rf1_axu_mffgpr or rf1_axu_mftgpr) and rf1_axu_movedp and not rf1_axu_ldst_indexed_b);
with ex1_dp_indexed_q select
        ex2_ipb_ba_d             <=  ex1_instr_q(11 to 15)        when '0',
                                   alu_dec_ex1_ipb_ba(27 to 31) when others;
xu_bx_ex2_ipc_ba            <=  ex2_ipb_ba_q;
ex2_ipb_sz_d                <=  ex1_instr_q(16 to 17);
xu_bx_ex2_ipc_sz            <=  ex2_ipb_sz_q;
ex1_ipc_ln                   <=  ex1_instr_q(18 to 19);
ex1_dp_rot_addr              <=  "01" & ex2_ipb_ba_d(3 to 4) & "00";
with ex2_ipb_sz_d select
        ex1_dp_rot_op_size       <=  "010000" when "10",      
                                   "001000" when "01",      
                                   "000100" when "00",      
                                   "000000" when others;
ex1_dp_rot_r_amt             <=  std_ulogic_vector(unsigned(ex1_dp_rot_addr) + unsigned(ex1_dp_rot_op_size));
ex1_dp_rot_l_amt             <=  std_ulogic_vector(32 - unsigned(ex1_dp_rot_r_amt));
ex1_dp_rot_dir               <=  "10" when (ex2_ipb_ba_d(3 to 4) < ex1_ipc_ln) or (ex1_axu_movedp_q = '0') else
                                   "00" when ex2_ipb_ba_d(3 to 4) = ex1_ipc_ln else
                                   "01" when ex2_ipb_ba_d(3 to 4) > ex1_ipc_ln else
                                   "11";
with ex1_dp_rot_dir select
        ex1_dp_rot_amt           <=  "000000"             when "00",
                                    ex1_dp_rot_r_amt    when "01",
                                    ex1_dp_rot_l_amt    when "10",
                                    "000000"             when others;
ex1_ovr_rotsel_d             <=  rf1_axu_mffgpr or rf1_axu_mftgpr;
ex1_epid_instr_d                 <=  rf1_xu_epid_instr_q or rf1_axu_is_extload_q or rf1_axu_is_extstore_q;
dec_cpl_ex1_epid_instr           <=  ex1_epid_instr_q;
xu_lsu_rf1_is_touch              <=  rf1_is_touch;
rf1_is_touch                     <=  rf1_is_dcbt or rf1_is_dcbtep or rf1_is_dcbtst or rf1_is_dcbtstep or rf1_is_icbt or
                                     ((rf1_is_dcbtls or rf1_is_dcbtstls or rf1_is_dcblc) and not (rf1_th_fld_c or rf1_th_fld_l2)) or
                                     ((rf1_is_icbtls or rf1_is_icblc)                    and not (rf1_th_fld_c or rf1_th_fld_l2));
rf1_th_fld_b0                    <=  rf1_instr_q(6) and (rf1_is_dcbt or rf1_is_dcbtep or rf1_is_dcbtst or rf1_is_dcbtstep);
rf1_th_fld_c                     <=  '1' when (rf1_th_fld_b0='0' and (rf1_instr_q(7 to 10) = "0000")) else '0';
rf1_th_fld_l2                    <=  '1' when (rf1_th_fld_b0='0' and (rf1_instr_q(7 to 10) = "0010")) else '0';
xu_lsu_rf1_target_gpr        <=  rf1_target_gpr;
with rf1_axu_ld_or_st_q select
        rf1_target_gpr           <=  '0' & rf1_ta_q(0 to 7) when '0',
                                   rf1_axu_ldst_tag_q     when others;
ex1_rotsel_ovrd_d            <=  rf1_axu_ldst_size(1 to 5);
xu_lsu_rf1_derat_ra_eq_ea    <=  rf1_derat_ra_eq_ea;
rf1_derat_ra_eq_ea           <=  rf1_back_inv_q or (rf1_val_stg and rf1_is_msgsnd) or rf1_mtspr_trace;
xu_lsu_rf1_thrd_id           <=  rf1_tid_q;
xu_lsu_rf1_axu_op_val        <=  rf1_axu_ld_or_st_q;
xu_lsu_rf1_axu_ldst_falign   <=  rf1_axu_ldst_forcealign    and rf1_val_stg;
xu_lsu_rf1_axu_ldst_fexcpt   <=  rf1_axu_ldst_forceexcept   and rf1_val_stg;
with ex1_ovr_rotsel_q select
        xu_lsu_ex1_rotsel_ovrd   <=  ex1_rotsel_ovrd_q         when '1',
                                   ex1_dp_rot_amt(1 to 5)   when others;
xu_lsu_rf0_act               <=  rf0_act;
xu_lsu_rf1_cache_acc         <=  rf1_cache_acc;
rf1_touch_drop               <=  (rf1_is_dcbt   or rf1_is_dcbtep   or rf1_is_dcbtst or rf1_is_dcbtstep or rf1_is_icbt or
                                    rf1_is_dcbtls or rf1_is_dcbtstls or rf1_is_dcblc  or rf1_is_icbtls   or rf1_is_icblc) and not (rf1_th_fld_l2 or rf1_th_fld_c);
rf1_wclr_all                 <=  rf1_is_wclr and not rf1_instr_q(9);
ex1_ddmh_en_d                <=  rf1_cache_acc and not (rf1_touch_drop or rf1_wclr_all);
dec_cpl_ex3_ddmh_en          <=  ex3_ddmh_en_q;
dec_cpl_ex3_back_inv         <=  ex3_back_inv_q;
xu_lsu_rf1_load_instr        <=  rf1_is_any_load_axu;
xu_lsu_rf1_store_instr       <=  rf1_is_any_store_axu;
xu_lsu_rf1_l_fld             <=  rf1_instr_q(9 to 10);
xu_lsu_rf1_th_fld            <=  rf1_instr_q(6 to 10);
xu_lsu_rf1_mutex_hint        <=  rf1_instr_q(31);
xu_lsu_rf1_byte_rev          <=  not or_reduce(rf1_ucode_val_q) and (rf1_is_lhbrx or rf1_is_lwbrx or rf1_is_ldbrx or rf1_is_sthbrx or rf1_is_stwbrx or rf1_is_stdbrx);
xu_lsu_rf1_dcbf_instr        <=  rf1_is_dcbf or rf1_is_dcbfep;
xu_lsu_rf1_dcbi_instr        <=  rf1_is_dcbi;
xu_lsu_rf1_dcbz_instr        <=  rf1_is_dcbz or rf1_is_dcbzep;
xu_lsu_rf1_dcbt_instr        <=  rf1_is_dcbt or rf1_is_dcbtep;
xu_lsu_rf1_dcbtst_instr      <=  rf1_is_dcbtst or rf1_is_dcbtstep;
xu_lsu_rf1_dcbtls_instr      <=  rf1_is_dcbtls;
xu_lsu_rf1_dcbtstls_instr    <=  rf1_is_dcbtstls;
xu_lsu_rf1_dcblc_instr       <=  rf1_is_dcblc;
xu_lsu_rf1_dcbst_instr       <=  rf1_is_dcbst or rf1_is_dcbstep;
xu_lsu_rf1_icbi_instr        <=  rf1_is_icbi or rf1_is_icbiep;
xu_lsu_rf1_icblc_instr       <=  rf1_is_icblc;
xu_lsu_rf1_icbt_instr        <=  rf1_is_icbt;
xu_lsu_rf1_icbtls_instr      <=  rf1_is_icbtls;
xu_lsu_rf1_lock_instr        <=  rf1_is_ldarx  or rf1_is_lwarx or rf1_is_stdcxr or rf1_is_stwcxr;
xu_lsu_rf1_dci_instr         <=  rf1_is_dci and rf1_val_stg;
xu_lsu_rf1_ici_instr         <=  rf1_is_ici and rf1_val_stg;
xu_iu_rf1_val                <=  rf1_val_iu_q;
xu_rf1_val                   <=  rf1_val_q;
xu_rf1_is_tlbre              <=  rf1_is_tlbre;
xu_rf1_is_tlbwe              <=  rf1_is_tlbwe;
xu_rf1_is_tlbsx              <=  rf1_is_tlbsx;
xu_rf1_is_tlbsrx             <=  rf1_is_tlbsrx;
xu_rf1_is_tlbilx             <=  rf1_is_tlbilx;
xu_rf1_is_tlbivax            <=  rf1_is_tlbivax;
xu_rf1_is_eratre             <=  rf1_is_eratre;
xu_rf1_is_eratwe             <=  rf1_is_eratwe;
xu_rf1_is_eratsx             <=  rf1_is_eratsx;
xu_rf1_is_eratsrx            <=  rf1_is_eratsrx;
xu_rf1_is_eratilx            <=  rf1_is_eratilx;
xu_rf1_is_erativax           <=  rf1_is_erativax;
xu_lsu_rf1_cmd_act           <=  rf1_cmd_act   or or_reduce(rf1_ucode_val_q);
xu_lsu_rf1_derat_act         <=  rf1_derat_act or or_reduce(rf1_ucode_val_q) or (rf1_val_stg and (rf1_is_isync or rf1_is_csync or rf1_is_eratre or rf1_is_eratwe or
                                                                                                    rf1_is_eratsx or rf1_is_eratilx or (rf1_is_wclr and rf1_instr_q(9))));
xu_lsu_rf1_derat_is_load     <=  rf1_derat_is_load  or (rf1_is_wclr and rf1_instr_q(9));
xu_lsu_rf1_derat_is_store    <=  rf1_derat_is_store;
xu_rf1_ws                    <=  rf1_instr_q(19 to 20);
xu_rf1_t                     <=  rf1_instr_q(8 to 10);
xu_ex1_is_isync              <=  ex1_is_isync_q;
xu_ex1_is_csync              <=  ex1_is_csync_q;
rf1_is_csync                 <=  rf1_is_sc or rf1_is_mtmsr or rf1_is_ehpriv or
                                   rf1_is_rfi or rf1_is_rfci or rf1_is_rfmci or rf1_is_rfgi or
                                   (rf1_is_mtspr and ((rf1_instr_q(11 to 20) = "1000000001") or   
                                                      (rf1_instr_q(11 to 20) = "1001001010")));
rf1_mc_dep_chk_val_d         <=  fxa_fxb_rf0_mc_dep_chk_val;
rf1_val_w_ldstm              <=  rf1_val_stg            or
                                   or_reduce(rf1_mc_dep_chk_val_q) or
                                   or_reduce(rf1_ucode_val_q);
rf1_targ_vld                 <=  rf1_ta_vld_q      when rf1_3src_instr_q = '0' else rf1_s3_vld_q;
rf1_targ_reg                 <=  rf1_ta_q          when rf1_3src_instr_q = '0' else rf1_s3_q;
rf1_src0_vld                 <=  rf1_s1_vld_q      when rf1_3src_instr_q = '0' else rf1_s1_vld_q;
rf1_src0_reg                 <=  rf1_s1_q          when rf1_3src_instr_q = '0' else rf1_s1_q;
rf1_src1_vld                 <=  rf1_s2_vld_q      when rf1_3src_instr_q = '0' else rf1_s2_vld_q;
rf1_src1_reg                 <=  rf1_s2_q          when rf1_3src_instr_q = '0' else rf1_s2_q;
xu_lsu_rf1_targ_vld          <=  rf1_targ_vld and rf1_val_w_ldstm;
xu_lsu_rf1_targ_reg          <=  rf1_targ_reg;
xu_lsu_rf1_src0_vld          <=  rf1_src0_vld and rf1_val_w_ldstm and not rf1_gpr0_zero_q;
xu_lsu_rf1_src0_reg          <=  rf1_src0_reg;
xu_lsu_rf1_src1_vld          <=  rf1_src1_vld and rf1_val_w_ldstm;
xu_lsu_rf1_src1_reg          <=  rf1_src1_reg;
ex3_tlbsel                   <=  mmucr0_0_tlbsel_q        when ex3_tid_q = "1000" else
                                   mmucr0_1_tlbsel_q        when ex3_tid_q = "0100" else
                                   mmucr0_2_tlbsel_q        when ex3_tid_q = "0010" else
                                   mmucr0_3_tlbsel_q        when ex3_tid_q = "0001" else
                                   "00";
 WITH s3'(ex3_tlb_data_val_q & ex3_tlbsel)  SELECT         dec_byp_ex3_tlb_sel      <=  "10"                     when "111",
                                   "01"                     when "110",
                                   "00"                     when others;
ex1_tlb_data_val_d            <=  rf1_is_eratre or rf1_is_eratsx;
rf1_tlbsel(12) <=  mmucr0_0_tlbsel_q(4)    when rf1_tid_q = "1000" else
                                    mmucr0_1_tlbsel_q(4)    when rf1_tid_q = "0100" else
                                    mmucr0_2_tlbsel_q(4)    when rf1_tid_q = "0010" else
                                    mmucr0_3_tlbsel_q(4)    when rf1_tid_q = "0001" else
                                    '0';
rf1_tlb_illeg_ws              <=  (rf1_is_eratwe or rf1_is_eratre) and rf1_instr_q(16 to 18)/="000";
rf1_tlb_illeg_ws2             <=  (rf1_is_eratwe or rf1_is_eratre) and rf1_instr_q(19 to 20)="10" and rf1_spr_msr_cm;
rf1_tlb_illeg_ws3             <=   rf1_is_eratwe                 and rf1_instr_q(19 to 20)="11" and rf1_tlbsel(12)='0';
rf1_tlb_illeg_t               <=  rf1_is_tlbilx and rf1_instr_q(8 to 10) = "010";
rf1_tlb_illeg_sel             <=  ((rf1_is_tlbwe or rf1_is_tlbre or rf1_is_tlbsx or rf1_is_tlbsrx or rf1_is_tlbilx or rf1_is_tlbivax) and spr_ccr2_notlb_q)
                                 or ((rf1_is_eratwe or rf1_is_eratre or rf1_is_eratsx) and not rf1_tlbsel(12))
                                 or ((rf1_is_erativax) and not spr_ccr2_notlb_q);
ex1_tlb_illeg_d               <=  rf1_tlb_illeg_ws or rf1_tlb_illeg_ws2 or rf1_tlb_illeg_ws3 or rf1_tlb_illeg_sel or rf1_tlb_illeg_t;
dec_cpl_ex3_tlb_illeg         <=  ex3_tlb_illeg_q;
rf1_clear_barrier            <=  rf1_is_mtmsr or rf1_is_rfci or rf1_is_rfi or rf1_is_rfmci or rf1_is_sc or rf1_is_rfgi or rf1_is_isync;
ex6_clear_barrier_d          <=  (0 to threads-1 => ex5_clear_barrier_q) and ex6_val_d;
fxb_fxa_ex6_clear_barrier    <=  ex6_clear_barrier_q;
byp_grp3_debug               <=  ex1_s1_q & ex1_ta_q(0 to 5) & ex1_gpr_we_q;
byp_grp4_debug               <=  ex1_s2_q & ex1_ta_q(0 to 5);
byp_grp5_debug               <=  ex1_s3_q & ex1_ta_q(0 to 5) & ex1_gpr_we_q;
dec_grp0_debug               <=   rf1_ucode_val_q            &
                                    rf1_val_q                  &
                                    rf1_instr_q                &
                                    rf1_cache_acc              &
                                    rf1_axu_ld_or_st_q         &
                                    rf1_is_any_load_axu        &
                                    rf1_is_any_store_axu       &
                                    rf1_derat_is_load          &
                                    rf1_derat_is_store         &
                                    rf1_derat_ra_eq_ea         &
                                    rf1_axu_ldst_forcealign    &
                                    rf1_axu_ldst_forceexcept   &
                                    rf1_is_any_load_dac        &
                                    rf1_is_any_store_dac       &
                                    rf1_is_touch               &
                                    rf1_target_gpr             &
                                    rf1_targ_vld               &
                                    rf1_targ_reg               &
                                    rf1_src0_vld               &
                                    rf1_src0_reg               &
                                    rf1_src1_vld               &
                                    rf1_src1_reg;
dec_grp1_debug               <=   rf1_ucode_val_q            &
                                    rf1_val_q                  &
                                    rf1_instr_q                &
                                    rf1_cache_acc              &
                                    rf1_axu_ld_or_st_q         &
                                    rf1_is_any_load_axu        &
                                    rf1_is_any_store_axu       &
                                    rf1_derat_is_load          &
                                    rf1_derat_is_store         &
                                    rf1_derat_ra_eq_ea         &
                                    rf1_axu_ldst_forcealign    &
                                    rf1_axu_ldst_forceexcept   &
                                    rf1_is_any_load_dac        &
                                    rf1_is_any_store_dac       &
                                    rf1_back_inv_q             &
                                    rf1_back_inv_addr_q;
rf1_is_attn                  <=  '1' when rf1_opcode_is_0              and   rf1_instr_21to30_00_q(21 to 30)    = "0100000000"                              else '0';
rf1_is_bc                    <=  '1' when                                    rf1_instr_q( 0 to  5)              = "010000"                                  else '0';
rf1_is_bclr                  <=  '1' when rf1_opcode_is_19             and   rf1_instr_21to30_00_q(21 to 30)    = "0000010000"                              else '0';
rf1_is_dcbf                  <=  '1' when rf1_opcode_is_31_q(0) = '1'  and   rf1_instr_21to30_00_q(21 to 30)    = "0001010110"                              else '0';
rf1_is_dcbi                  <=  '1' when rf1_opcode_is_31_q(0) = '1'  and   rf1_instr_21to30_00_q(21 to 30)    = "0111010110"                              else '0';
rf1_is_dcbst                 <=  '1' when rf1_opcode_is_31_q(0) = '1'  and   rf1_instr_21to30_00_q(21 to 30)    = "0000110110"                              else '0';
rf1_is_dcblc                 <=  '1' when rf1_opcode_is_31_q(0) = '1'  and   rf1_instr_21to30_00_q(21 to 30)    = "0110000110"                              else '0';
rf1_is_dcbt                  <=  '1' when rf1_opcode_is_31_q(0) = '1'  and   rf1_instr_21to30_00_q(21 to 30)    = "0100010110"                              else '0';
rf1_is_dcbtls                <=  '1' when rf1_opcode_is_31_q(0) = '1'  and   rf1_instr_21to30_00_q(21 to 30)    = "0010100110"                              else '0';
rf1_is_dcbtst                <=  '1' when rf1_opcode_is_31_q(0) = '1'  and   rf1_instr_21to30_01_q(21 to 30)    = "0011110110"                              else '0';
rf1_is_dcbtstls              <=  '1' when rf1_opcode_is_31_q(0) = '1'  and   rf1_instr_21to30_01_q(21 to 30)    = "0010000110"                              else '0';
rf1_is_dcbz                  <=  '1' when rf1_opcode_is_31_q(1) = '1'  and   rf1_instr_21to30_01_q(21 to 30)    = "1111110110"                              else '0';
rf1_is_dci                   <=  '1' when rf1_opcode_is_31_q(1) = '1'  and   rf1_instr_21to30_01_q(21 to 30)    = "0111000110"                              else '0';
rf1_is_eratilx               <=  '1' when rf1_opcode_is_31_q(1) = '1'  and   rf1_instr_21to30_01_q(21 to 30)    = "0000110011"                              else '0';
rf1_is_erativax              <=  '1' when rf1_opcode_is_31_q(1) = '1'  and   rf1_instr_21to30_01_q(21 to 30)    = "1100110011"                              else '0';
rf1_is_eratre                <=  '1' when rf1_opcode_is_31_q(1) = '1'  and   rf1_instr_21to30_01_q(21 to 30)    = "0010110011"                              else '0';
rf1_is_eratsx                <=  '1' when rf1_opcode_is_31_q(1) = '1'  and   rf1_instr_21to30_01_q(21 to 30)    = "0010010011"                              else '0';
rf1_is_eratsrx               <=  '1' when rf1_opcode_is_31_q(1) = '1'  and   rf1_instr_21to30_02_q(21 to 30)    = "1101110011"                              else '0';
rf1_is_eratwe                <=  '1' when rf1_opcode_is_31_q(1) = '1'  and   rf1_instr_21to30_02_q(21 to 30)    = "0011010011"                              else '0';
rf1_is_ici                   <=  '1' when rf1_opcode_is_31_q(2) = '1'  and   rf1_instr_21to30_02_q(21 to 30)    = "1111000110"                              else '0';
rf1_is_icbi                  <=  '1' when rf1_opcode_is_31_q(2) = '1'  and   rf1_instr_21to30_02_q(21 to 30)    = "1111010110"                              else '0';
rf1_is_icblc                 <=  '1' when rf1_opcode_is_31_q(2) = '1'  and   rf1_instr_21to30_02_q(21 to 30)    = "0011100110"                              else '0';
rf1_is_icbt                  <=  '1' when rf1_opcode_is_31_q(2) = '1'  and   rf1_instr_21to30_02_q(21 to 30)    = "0000010110"                              else '0';
rf1_is_icbtls                <=  '1' when rf1_opcode_is_31_q(2) = '1'  and   rf1_instr_21to30_02_q(21 to 30)    = "0111100110"                              else '0';
rf1_is_isync                 <=  '1' when rf1_opcode_is_19             and   rf1_instr_21to30_02_q(21 to 30)    = "0010010110"                              else '0';
rf1_is_ld                    <=  '1' when rf1_opcode_is_58             and   rf1_instr_q(30 to 31)              = "00"                                      else '0';
rf1_is_ldarx                 <=  '1' when rf1_opcode_is_31_q(2) = '1'  and   rf1_instr_21to30_03_q(21 to 30)    = "0001010100"                              else '0';
rf1_is_ldbrx                 <=  '1' when rf1_opcode_is_31_q(2) = '1'  and   rf1_instr_21to30_03_q(21 to 30)    = "1000010100"                              else '0';
rf1_is_ldu                   <=  '1' when rf1_opcode_is_58             and   rf1_instr_q(30 to 31)              = "01"                                      else '0';
rf1_is_lhbrx                 <=  '1' when rf1_opcode_is_31_q(2) = '1'  and   rf1_instr_21to30_03_q(21 to 30)    = "1100010110"                              else '0';
rf1_is_lmw                   <=  '1' when                                    rf1_instr_q( 0 to  5)              = "101110"                                  else '0';
rf1_is_lswi                  <=  '1' when rf1_opcode_is_31_q(3) = '1'  and   rf1_instr_21to30_03_q(21 to 30)    = "1001010101"                              else '0';
rf1_is_lswx                  <=  '1' when rf1_opcode_is_31_q(3) = '1'  and   rf1_instr_21to30_03_q(21 to 30)    = "1000010101"                              else '0';
rf1_is_lwa                   <=  '1' when rf1_opcode_is_58             and   rf1_instr_q(30 to 31)              = "10"                                      else '0';
rf1_is_lwarx                 <=  '1' when rf1_opcode_is_31_q(3) = '1'  and   rf1_instr_21to30_03_q(21 to 30)    = "0000010100"                              else '0';
rf1_is_lwbrx                 <=  '1' when rf1_opcode_is_31_q(3) = '1'  and   rf1_instr_21to30_03_q(21 to 30)    = "1000010110"                              else '0';
rf1_is_mfcr                  <=  '1' when rf1_opcode_is_31_q(3) = '1'  and  (rf1_instr_21to30_03_q(21 to 30) & rf1_instr_q(11) = "00000100110")             else '0';
rf1_is_mfdp                  <=  '1' when rf1_opcode_is_31_q(3) = '1'  and   rf1_instr_21to30_04_q(21 to 30)    = "0000100011"                              else '0';
rf1_is_mfdpx                 <=  '1' when rf1_opcode_is_31_q(3) = '1'  and   rf1_instr_21to30_04_q(21 to 30)    = "0000000011"                              else '0';
rf1_is_mtdp                  <=  '1' when rf1_opcode_is_31_q(3) = '1'  and   rf1_instr_21to30_04_q(21 to 30)    = "0001100011"                              else '0';
rf1_is_mtdpx                 <=  '1' when rf1_opcode_is_31_q(4) = '1'  and   rf1_instr_21to30_04_q(21 to 30)    = "0001000011"                              else '0';
rf1_is_mfspr                 <=  '1' when rf1_opcode_is_31_q(4) = '1'  and   rf1_instr_21to30_04_q(21 to 30)    = "0101010011"                              else '0';
rf1_is_mtcrf                 <=  '1' when rf1_opcode_is_31_q(4) = '1'  and   rf1_instr_21to30_04_q(21 to 30)    = "0010010000"                              else '0';
rf1_is_mtmsr                 <=  '1' when rf1_opcode_is_31_q(4) = '1'  and   rf1_instr_21to30_04_q(21 to 30)    = "0010010010"                              else '0';
rf1_is_mtspr                 <=  '1' when rf1_opcode_is_31_q(4) = '1'  and   rf1_instr_21to30_04_q(21 to 30)    = "0111010011"                              else '0';
rf1_is_neg                   <=  '1' when rf1_opcode_is_31_q(4) = '1'  and   rf1_instr_21to30_05_q(22 to 30)    = "001101000"                               else '0';
rf1_is_rfci                  <=  '1' when rf1_opcode_is_19             and   rf1_instr_21to30_05_q(21 to 30)    = "0000110011"                              else '0';
rf1_is_rfi                   <=  '1' when rf1_opcode_is_19             and   rf1_instr_21to30_05_q(21 to 30)    = "0000110010"                              else '0';
rf1_is_rfmci                 <=  '1' when rf1_opcode_is_19             and   rf1_instr_21to30_05_q(21 to 30)    = "0000100110"                              else '0';
rf1_is_sc                    <=  '1' when                                    rf1_instr_q( 0 to  5)              = "010001"                                  else '0';
rf1_is_std                   <=  '1' when rf1_opcode_is_62             and   rf1_instr_q(30 to 31)              = "00"                                      else '0';
rf1_is_stdbrx                <=  '1' when rf1_opcode_is_31_q(4) = '1'  and   rf1_instr_21to30_05_q(21 to 30)    = "1010010100"                              else '0';
rf1_is_stdcxr                <=  '1' when rf1_opcode_is_31_q(4) = '1'  and   rf1_instr_21to30_05_q(21 to 30)    = "0011010110"                              else '0';
rf1_is_stdu                  <=  '1' when rf1_opcode_is_62             and   rf1_instr_q(30 to 31)              = "01"                                      else '0';
rf1_is_sthbrx                <=  '1' when rf1_opcode_is_31_q(5) = '1'  and   rf1_instr_21to30_05_q(21 to 30)    = "1110010110"                              else '0';
rf1_is_stwcxr                <=  '1' when rf1_opcode_is_31_q(5) = '1'  and   rf1_instr_21to30_05_q(21 to 30)    = "0010010110"                              else '0';
rf1_is_stwbrx                <=  '1' when rf1_opcode_is_31_q(5) = '1'  and   rf1_instr_21to30_06_q(21 to 30)    = "1010010110"                              else '0';
rf1_is_subf                  <=  '1' when rf1_opcode_is_31_q(5) = '1'  and   rf1_instr_21to30_06_q(22 to 30)    = "000101000"                               else '0';
rf1_is_subfc                 <=  '1' when rf1_opcode_is_31_q(5) = '1'  and   rf1_instr_21to30_06_q(22 to 30)    = "000001000"                               else '0';
rf1_is_subfe                 <=  '1' when rf1_opcode_is_31_q(5) = '1'  and   rf1_instr_21to30_06_q(22 to 30)    = "010001000"                               else '0';
rf1_is_subfic                <=  '1' when                                    rf1_instr_q( 0 to  5)              = "001000"                                  else '0';
rf1_is_subfme                <=  '1' when rf1_opcode_is_31_q(5) = '1'  and   rf1_instr_21to30_06_q(22 to 30)    = "011101000"                               else '0';
rf1_is_subfze                <=  '1' when rf1_opcode_is_31_q(5) = '1'  and   rf1_instr_21to30_06_q(22 to 30)    = "011001000"                               else '0';
rf1_is_td                    <=  '1' when rf1_opcode_is_31_q(6) = '1'  and   rf1_instr_21to30_06_q(21 to 30)    = "0001000100"                              else '0';
rf1_is_tdi                   <=  '1' when                                    rf1_instr_q( 0 to  5)              = "000010"                                  else '0';
rf1_is_tlbilx                <=  '1' when rf1_opcode_is_31_q(6) = '1'  and   rf1_instr_21to30_06_q(21 to 30)    = "0000010010"                              else '0';
rf1_is_tlbivax               <=  '1' when rf1_opcode_is_31_q(6) = '1'  and   rf1_instr_21to30_07_q(21 to 30)    = "1100010010"                              else '0';
rf1_is_tlbre                 <=  '1' when rf1_opcode_is_31_q(6) = '1'  and   rf1_instr_21to30_07_q(21 to 30)    = "1110110010"                              else '0';
rf1_is_tlbsx                 <=  '1' when rf1_opcode_is_31_q(6) = '1'  and   rf1_instr_21to30_07_q(21 to 30)    = "1110010010"                              else '0';
rf1_is_tlbsrx                <=  '1' when rf1_opcode_is_31_q(6) = '1'  and   rf1_instr_21to30_07_q(21 to 30)    = "1101010010"                              else '0';
rf1_is_tlbwe                 <=  '1' when rf1_opcode_is_31_q(6) = '1'  and   rf1_instr_21to30_07_q(21 to 30)    = "1111010010"                              else '0';
rf1_is_tlbwec                <=  '0';
rf1_is_tw                    <=  '1' when rf1_opcode_is_31_q(6) = '1'  and   rf1_instr_21to30_07_q(21 to 30)    = "0000000100"                              else '0';
rf1_is_twi                   <=  '1' when                                    rf1_instr_q( 0 to  5)              = "000011"                                  else '0';
rf1_is_wrtee                 <=  '1' when rf1_opcode_is_31_q(7) = '1'  and   rf1_instr_21to30_07_q(21 to 30)    = "0010000011"                              else '0';
rf1_is_dcbstep               <=  '1' when rf1_opcode_is_31_q(7) = '1'  and   rf1_instr_21to30_07_q(21 to 30)    = "0000111111"                              else '0';
rf1_is_dcbtep                <=  '1' when rf1_opcode_is_31_q(7) = '1'  and   rf1_instr_21to30_08_q(21 to 30)    = "0100111111"                              else '0';
rf1_is_dcbfep                <=  '1' when rf1_opcode_is_31_q(7) = '1'  and   rf1_instr_21to30_08_q(21 to 30)    = "0001111111"                              else '0';
rf1_is_dcbtstep              <=  '1' when rf1_opcode_is_31_q(7) = '1'  and   rf1_instr_21to30_08_q(21 to 30)    = "0011111111"                              else '0';
rf1_is_icbiep                <=  '1' when rf1_opcode_is_31_q(7) = '1'  and   rf1_instr_21to30_08_q(21 to 30)    = "1111011111"                              else '0';
rf1_is_dcbzep                <=  '1' when rf1_opcode_is_31_q(7) = '1'  and   rf1_instr_21to30_08_q(21 to 30)    = "1111111111"                              else '0';
rf1_is_rfgi                  <=  '1' when rf1_opcode_is_19             and   rf1_instr_21to30_08_q(21 to 30)    = "0001100110"                              else '0';
rf1_is_ehpriv                <=  '1' when rf1_opcode_is_31_q(7) = '1'  and   rf1_instr_21to30_08_q(21 to 30)    = "0100001110"                              else '0';
rf1_is_msgclr                <=  '1' when rf1_opcode_is_31_q(8) = '1'  and   rf1_instr_21to30_08_q(21 to 30)    = "0011101110"                              else '0';
rf1_is_msgsnd                <=  '1' when rf1_opcode_is_31_q(8) = '1'  and   rf1_instr_21to30_09_q(21 to 30)    = "0011001110"                              else '0';
rf1_is_icswx                 <=  '1' when rf1_opcode_is_31_q(8) = '1'  and   rf1_instr_21to30_09_q(21 to 30)    = "0110010110"                              else '0';
rf1_is_icswepx               <=  '1' when rf1_opcode_is_31_q(8) = '1'  and   rf1_instr_21to30_09_q(21 to 30)    = "1110110110"                              else '0';
rf1_is_wchkall               <=  '1' when rf1_opcode_is_31_q(8) = '1'  and   rf1_instr_21to30_09_q(21 to 30)    = "1110000110"                              else '0';
rf1_is_wclr                  <=  '1' when rf1_opcode_is_31_q(8) = '1'  and   rf1_instr_21to30_09_q(21 to 30)    = "1110100110"                              else '0';
rf1_is_mfdcr                 <=  '1' when rf1_opcode_is_31_q(8) = '1'  and   rf1_instr_21to30_09_q(21 to 30)    = "0101000011"                              else '0';
rf1_is_mfdcrux               <=  '1' when rf1_opcode_is_31_q(8) = '1'  and   rf1_instr_21to30_09_q(21 to 30)    = "0100100011"                              else '0';
rf1_is_mfdcrx                <=  '1' when rf1_opcode_is_31_q(9) = '1'  and   rf1_instr_21to30_09_q(21 to 30)    = "0100000011"                              else '0';
rf1_is_mtdcr                 <=  '1' when rf1_opcode_is_31_q(9) = '1'  and   rf1_instr_21to30_10_q(21 to 30)    = "0111000011"                              else '0';
rf1_is_mtdcrux               <=  '1' when rf1_opcode_is_31_q(9) = '1'  and   rf1_instr_21to30_10_q(21 to 30)    = "0110100011"                              else '0';
rf1_is_mtdcrx                <=  '1' when rf1_opcode_is_31_q(9) = '1'  and   rf1_instr_21to30_10_q(21 to 30)    = "0110000011"                              else '0';
rf1_is_mulhd                 <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "001001001"                               else '0';
rf1_is_mulhdu                <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "000001001"                               else '0';
rf1_is_mulhw                 <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "001001011"                               else '0';
rf1_is_mulhwu                <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "000001011"                               else '0';
rf1_is_mulld                 <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "011101001"                               else '0';
rf1_is_mulli                 <=  '1' when                                    rf1_instr_q( 0 to  5)              = "000111"                                  else '0';
rf1_is_mullw                 <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "011101011"                               else '0';
rf1_is_divd                  <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "111101001"                               else '0';
rf1_is_divdu                 <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "111001001"                               else '0';
rf1_is_divw                  <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "111101011"                               else '0';
rf1_is_divwu                 <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "111001011"                               else '0';
rf1_is_divwe                 <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "110101011"                               else '0';
rf1_is_divweu                <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "110001011"                               else '0';
rf1_is_divde                 <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "110101001"                               else '0';
rf1_is_divdeu                <=  '1' when rf1_opcode_is_31             and   rf1_instr_q(22 to 30)              = "110001001"                               else '0';
opcode_31_gen : for i in 0 to 9 generate
rf1_opcode_is_31_d(i) <=  rf0_opcode_is_31;
end generate;
rf1_instr_21to30_00_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf1_instr_21to30_01_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf1_instr_21to30_02_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf1_instr_21to30_03_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf1_instr_21to30_04_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf1_instr_21to30_05_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf1_instr_21to30_06_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf1_instr_21to30_07_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf1_instr_21to30_08_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf1_instr_21to30_09_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf1_instr_21to30_10_d           <=  fxa_fxb_rf0_instr(21 to 30);
rf0_opcode_is_31             <=  '1' when fxa_fxb_rf0_instr(0 to 5) = "011111" else '0';
rf1_opcode_is_31             <=  rf1_instr_q(0 to 5) = "011111";
rf1_opcode_is_0              <=  rf1_instr_q(0 to 5) = "000000";
rf1_opcode_is_19             <=  rf1_instr_q(0 to 5) = "010011";
rf1_opcode_is_62             <=  rf1_instr_q(0 to 5) = "111110";
rf1_opcode_is_58             <=  rf1_instr_q(0 to 5) = "111010";
--
-- Final Table Listing
--          *INPUTS*========================*OUTPUTS*==============================================*
--          |                               |                                                      |
--          | rf1_instr_q                   |                                                      |
--          | |      rf1_instr_q            |                                                      |
--          | |      |          rf1_instr_q |                                                      |
--          | |      |          |           |                                                      |
--          | |      |          |           | dec_byp_rf1_is_mcrf                                  |
--          | |      |          |           | | dec_byp_rf1_is_mtcrf                               |
--          | |      |          |           | | | rf1_add_ext                                      |
--          | |      |          |           | | | | rf1_alu_cmp                                    |
--          | |      |          |           | | | | | rf1_cmp                                      |
--          | |      |          |           | | | | | | rf1_cmp_uext                               |
--          | |      |          |           | | | | | | | rf1_cr_so_update                         |
--          | |      |          |           | | | | | | | |  rf1_cr_we                             |
--          | |      |          |           | | | | | | | |  | rf1_imm_signext_tbl                 |
--          | |      |          |           | | | | | | | |  | | rf1_imm_size_tbl                  |
--          | |      |          |           | | | | | | | |  | | | rf1_instr_hypv_tbl              |
--          | |      |          |           | | | | | | | |  | | | | rf1_instr_priv_tbl            |
--          | |      |          |           | | | | | | | |  | | | | | rf1_is_trap                 |
--          | |      |          |           | | | | | | | |  | | | | | | rf1_ones_imm              |
--          | |      |          |           | | | | | | | |  | | | | | | | rf1_sel                 |
--          | |      |          |           | | | | | | | |  | | | | | | | |    rf1_shift_imm      |
--          | |      |          |           | | | | | | | |  | | | | | | | |    | rf1_spr_sel      |
--          | |      |          |           | | | | | | | |  | | | | | | | |    | | rf1_sub        |
--          | |      |          |           | | | | | | | |  | | | | | | | |    | | | rf1_zero_imm |
--          | |      |          |           | | | | | | | |  | | | | | | | |    | | | |            |
--          | 000000 2222222223 33          | | | | | | | 00 | | | | | | | 0000 | | | |            |
--          | 012345 1234567890 01          | | | | | | | 01 | | | | | | | 0123 | | | |            |
--          *TYPE*==========================+======================================================+
--          | PPPPPP PPPPPPPPPP PP          | P P P P P P PP P P P P P P P PPPP P P P P            |
--          *POLARITY*--------------------->| + + + + + + ++ + + + + + + + ++++ + + + +            |
--          *PHASE*------------------------>| T T T T T T TT T T T T T T T TTTT T T T T            |
--          *TERMS*=========================+======================================================+
--    1     | 010011 1000010000 --          | . . . . . . .. . . . . . . . .... . 1 . .            |
--    2     | 010011 0000000000 --          | 1 . . . . . .. 1 . . . . . . .... . . . .            |
--    3     | 010011 0000100110 --          | . . . . . . .. . . . 1 . . . .... . . . .            |
--    4     | 010011 0000110011 --          | . . . . . . .. . . . 1 . . . .... . . . .            |
--    5     | 010011 0-11000001 --          | . . . . . . 1. 1 . . . . . . .... . . . .            |
--    6     | 011111 0111111100 --          | . . . . . . .. . . . . . . . ...1 . . . .            |
--    7     | 010011 01-0100001 --          | . . . . . . 1. 1 . . . . . . .... . . . .            |
--    8     | 010011 0011-00001 --          | . . . . . . 1. 1 . . . . . . .... . . . .            |
--    9     | 010011 0-00100001 --          | . . . . . . 1. 1 . . . . . . .... . . . .            |
--   10     | 010011 0100-00001 --          | . . . . . . 1. 1 . . . . . . .... . . . .            |
--   11     | 010011 001-000001 --          | . . . . . . 1. 1 . . . . . . .... . . . .            |
--   12     | 011111 0101001110 --          | . . . . . . .. . . . . . . . .... . 1 . .            |
--   13     | 010011 000-100110 --          | . . . . . . .. . . . . 1 . . .... . 1 . .            |
--   14     | 011111 0000100000 --          | . . . . . 1 .. . . . . . . . .... . . . .            |
--   15     | 011111 0100001110 --          | . . . . . . .. . . . . 1 . . .... . . . .            |
--   16     | 010011 000011001- --          | . . . . . . .. . . . . 1 . . .... . 1 . .            |
--   17     | 011111 0010010000 --          | . 1 . . . . 1. . . . . . . . .... . . . .            |
--   18     | 011111 1000110110 --          | . . . . . . .. . . . 1 1 . . .... . . . .            |
--   19     | 011111 0001010011 --          | . . . . . . .. . . . . 1 . . .... . 1 . .            |
--   20     | 011111 -111000110 --          | . . . . . . .. . . . . 1 . . .... . . . .            |
--   21     | 01-111 110011101- --          | . . . . . . .. . . . . . . . .1.. . . . .            |
--   22     | 011111 1100110011 --          | . . . . . . .. . . . 1 1 . . 1... . . . .            |
--   23     | 011111 -001101000 --          | . . . . . . .. . . . . . . . 1... . . 1 1            |
--   24     | 01-111 111-011010 --          | . . . . . . .. . . . . . . . .1.. . . . .            |
--   25     | 011111 1111-11111 --          | . . . . . . .. . . . . 1 . . 1... . . . .            |
--   26     | 011111 1110110-10 --          | . . . . . . .. . . . . 1 . . .... . . . .            |
--   27     | 011111 0111010110 --          | . . . . . . .. . . . . 1 . . 1... . . . .            |
--   28     | 011111 0101-10011 --          | . . . . . . .. . . . . . . . .... . 1 . .            |
--   29     | 011111 1110-10010 --          | . . . . . . .. . . . 1 . . . .... . . . .            |
--   30     | 01111- -000011000 --          | . . . . . . .. . . . . . . . .1.. . . . .            |
--   31     | 011111 0010100011 --          | . . . . . . .. . . 1 . 1 . . 1... . . . .            |
--   32     | 011--1 011-011100 --          | . . . . . . .. . . . . . . . ..1. . . . .            |
--   33     | 011111 -0110010-0 --          | . . . . . . .. . . . . . . . .... . . . 1            |
--   34     | 011111 10-1010101 --          | . . . . . . .. . . 1 . . . . 1... . . . 1            |
--   35     | 011111 0010000011 --          | . . . . . . .. . . . . 1 . . 1... . . . 1            |
--   36     | 011--1 000-111100 --          | . . . . . . .. . . . . . . . ..1. . . . .            |
--   37     | 01-111 -000011011 --          | . . . . . . .. . . . . . . . .1.. . . . .            |
--   38     | 0-1111 11101-0110 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   39     | 011111 00100100-0 --          | . . . . . . .. . . . . . . . .... . . . 1            |
--   40     | 011111 -0111010-0 --          | . . 1 . . . .. . . . . . . 1 1... . . . .            |
--   41     | 011111 0011-01110 --          | . . . . . . .. . . . 1 1 . . 1... . . . .            |
--   42     | 0-1111 0-11100110 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   43     | 011111 0-11010011 --          | . . . . . . .. . . . . . . . 1... . . . 1            |
--   44     | 011111 001-010011 --          | . . . . . . .. . . . 1 1 . . .... . . . .            |
--   45     | 011111 000-000100 --          | . . . . 1 . .. . . . . . 1 . 1... . . 1 .            |
--   46     | 011111 00-0110011 --          | . . . . . . .. . . . 1 1 . . .... . . . .            |
--   47     | 011111 11-0010010 --          | . . . . . . .. . . . 1 . . . 1... . . . .            |
--   48     | 01-111 1100-110-0 --          | . . . . . . .. . . . . . . . .1.. . . . .            |
--   49     | 0-1111 110-010010 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   50     | 01-111 11-0-11010 --          | . . . . . . .. . . . . . . . .1.. . . . .            |
--   51     | 011111 11--010010 --          | . . . . . . .. . . . . 1 . . .... . . . .            |
--   52     | 011111 0000-00000 --          | . . . 1 1 . .1 1 . . . . . . 1... . . 1 .            |
--   53     | 011111 -000-01000 --          | . . . . . . .. . . . . . . . 1... . . 1 .            |
--   54     | 0-1111 0000110-11 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   55     | 011111 000--00011 --          | . . . . . . .. . . . . 1 . . .... . . . .            |
--   56     | 0-1111 0010-00110 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   57     | 011--1 01-0-11100 --          | . . . . . . .. . . . . . . . ..1. . . . .            |
--   58     | 011--1 0-00-11100 --          | . . . . . . .. . . . . . . . ..1. . . . .            |
--   59     | 011111 00-1-11111 --          | . . . . . . .. . . . . 1 . . 1... . . . .            |
--   60     | 0-1111 111--10110 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   61     | 0-1111 0101-101-1 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   62     | 0-1111 --00001010 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   63     | 0-1111 10-001010- --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   64     | 011111 00-0010010 --          | . . . . . . .. . . . . 1 . . 1... . . . .            |
--   65     | 011111 00-00111-1 --          | . . . . . . .. . . . . 1 . . 1... . . . .            |
--   66     | 011111 0--0011111 --          | . . . . . . .. . . . . 1 . . 1... . . . .            |
--   67     | 011111 0-00-11111 --          | . . . . . . .. . . . . 1 . . 1... . . . .            |
--   68     | 011111 -01-0010-0 --          | . . 1 . . . .. . . . . . . . 1... . . . .            |
--   69     | 0-1111 0011-1011- --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   70     | 0-1111 00-10101-0 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   71     | 0-1111 0-100-0110 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   72     | 0-1111 00000101-- --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   73     | 0-1111 0000-1011- --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   74     | 0-1111 000--1-111 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   75     | 0-1111 00-0-101-1 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   76     | 0-1111 ---0010110 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   77     | 0-1111 0--0-10111 --          | . . . . . . .. . . . . . . . 1... . . . .            |
--   78     | 011--1 -----01111 --          | . . . . . . .. . . . . . . . ..1. . . . .            |
--   79     | 010000 ---------- --          | . . . . . . .. . 1 1 . . . . .... . . . .            |
--   80     | 1-1010 ---------- -0          | . . . . . . .. . 1 1 . . . . 1... . . . .            |
--   81     | 011110 -------00- --          | . . . . . . .. . . . . . . . .1.. . . . .            |
--   82     | 001000 ---------- --          | . . . . . . .. . 1 1 . . . . 1... . . 1 .            |
--   83     | 001010 ---------- --          | . . . . . 1 .. . . 1 . . . . .... . . . .            |
--   84     | 1-1-10 ---------- 0-          | . . . . . . .. . 1 1 . . . . 1... . . . .            |
--   85     | 011110 ------0--- --          | . . . . . . .. . . . . . . . .1.. . . . .            |
--   86     | 01010- ---------- --          | . . . . . . .. . . . . . . . .1.. . . . .            |
--   87     | 00001- ---------- --          | . . . . 1 . .. . 1 1 . . 1 . 1... . . 1 .            |
--   88     | 001111 ---------- --          | . . . . . . .. . . . . . . . .... 1 . . .            |
--   89     | 011-01 ---------- --          | . . . . . . .. . . . . . . . .... 1 . . .            |
--   90     | 0101-1 ---------- --          | . . . . . . .. . . . . . . . .1.. . . . .            |
--   91     | 0110-1 ---------- --          | . . . . . . .. . . . . . . . .... 1 . . .            |
--   92     | 00101- ---------- --          | . . . 1 1 . .1 1 . . . . . . 1... . . 1 .            |
--   93     | 011-0- ---------- --          | . . . . . . .. . . 1 . . . . ..1. . . . .            |
--   94     | 10---- ---------- --          | . . . . . . .. . 1 1 . . . . 1... . . . .            |
--   95     | 0110-- ---------- --          | . . . . . . .. . . 1 . . . . ..1. . . . .            |
--   96     | -0--11 ---------- --          | . . . . . . .. . 1 1 . . . . .... . . . .            |
--   97     | -011-- ---------- --          | . . . . . . .. . 1 1 . . . . 1... . . . .            |
--          *======================================================================================*
--
-- Table TBL_MASTER_DEC Signal Assignments for Product Terms
MQQ1:TBL_MASTER_DEC_PT(1) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0100111000010000"));
MQQ2:TBL_MASTER_DEC_PT(2) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0100110000000000"));
MQQ3:TBL_MASTER_DEC_PT(3) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0100110000100110"));
MQQ4:TBL_MASTER_DEC_PT(4) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0100110000110011"));
MQQ5:TBL_MASTER_DEC_PT(5) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("010011011000001"));
MQQ6:TBL_MASTER_DEC_PT(6) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110111111100"));
MQQ7:TBL_MASTER_DEC_PT(7) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("010011010100001"));
MQQ8:TBL_MASTER_DEC_PT(8) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("010011001100001"));
MQQ9:TBL_MASTER_DEC_PT(9) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("010011000100001"));
MQQ10:TBL_MASTER_DEC_PT(10) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("010011010000001"));
MQQ11:TBL_MASTER_DEC_PT(11) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("010011001000001"));
MQQ12:TBL_MASTER_DEC_PT(12) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110101001110"));
MQQ13:TBL_MASTER_DEC_PT(13) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("010011000100110"));
MQQ14:TBL_MASTER_DEC_PT(14) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110000100000"));
MQQ15:TBL_MASTER_DEC_PT(15) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110100001110"));
MQQ16:TBL_MASTER_DEC_PT(16) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) ) , STD_ULOGIC_VECTOR'("010011000011001"));
MQQ17:TBL_MASTER_DEC_PT(17) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110010010000"));
MQQ18:TBL_MASTER_DEC_PT(18) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111000110110"));
MQQ19:TBL_MASTER_DEC_PT(19) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110001010011"));
MQQ20:TBL_MASTER_DEC_PT(20) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111111000110"));
MQQ21:TBL_MASTER_DEC_PT(21) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29)
     ) , STD_ULOGIC_VECTOR'("01111110011101"));
MQQ22:TBL_MASTER_DEC_PT(22) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111100110011"));
MQQ23:TBL_MASTER_DEC_PT(23) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001101000"));
MQQ24:TBL_MASTER_DEC_PT(24) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111111011010"));
MQQ25:TBL_MASTER_DEC_PT(25) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111111111111"));
MQQ26:TBL_MASTER_DEC_PT(26) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111111011010"));
MQQ27:TBL_MASTER_DEC_PT(27) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110111010110"));
MQQ28:TBL_MASTER_DEC_PT(28) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111010110011"));
MQQ29:TBL_MASTER_DEC_PT(29) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111111010010"));
MQQ30:TBL_MASTER_DEC_PT(30) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111000011000"));
MQQ31:TBL_MASTER_DEC_PT(31) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110010100011"));
MQQ32:TBL_MASTER_DEC_PT(32) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111011011100"));
MQQ33:TBL_MASTER_DEC_PT(33) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111101100100"));
MQQ34:TBL_MASTER_DEC_PT(34) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111101010101"));
MQQ35:TBL_MASTER_DEC_PT(35) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110010000011"));
MQQ36:TBL_MASTER_DEC_PT(36) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111000111100"));
MQQ37:TBL_MASTER_DEC_PT(37) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111000011011"));
MQQ38:TBL_MASTER_DEC_PT(38) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111111010110"));
MQQ39:TBL_MASTER_DEC_PT(39) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001001000"));
MQQ40:TBL_MASTER_DEC_PT(40) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111101110100"));
MQQ41:TBL_MASTER_DEC_PT(41) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001101110"));
MQQ42:TBL_MASTER_DEC_PT(42) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111011100110"));
MQQ43:TBL_MASTER_DEC_PT(43) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111011010011"));
MQQ44:TBL_MASTER_DEC_PT(44) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001010011"));
MQQ45:TBL_MASTER_DEC_PT(45) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111000000100"));
MQQ46:TBL_MASTER_DEC_PT(46) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111000110011"));
MQQ47:TBL_MASTER_DEC_PT(47) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111110010010"));
MQQ48:TBL_MASTER_DEC_PT(48) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111111001100"));
MQQ49:TBL_MASTER_DEC_PT(49) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111110010010"));
MQQ50:TBL_MASTER_DEC_PT(50) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111111011010"));
MQQ51:TBL_MASTER_DEC_PT(51) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111111010010"));
MQQ52:TBL_MASTER_DEC_PT(52) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111000000000"));
MQQ53:TBL_MASTER_DEC_PT(53) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100001000"));
MQQ54:TBL_MASTER_DEC_PT(54) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111000011011"));
MQQ55:TBL_MASTER_DEC_PT(55) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100000011"));
MQQ56:TBL_MASTER_DEC_PT(56) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111001000110"));
MQQ57:TBL_MASTER_DEC_PT(57) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("011101011100"));
MQQ58:TBL_MASTER_DEC_PT(58) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("011100011100"));
MQQ59:TBL_MASTER_DEC_PT(59) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100111111"));
MQQ60:TBL_MASTER_DEC_PT(60) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111111110110"));
MQQ61:TBL_MASTER_DEC_PT(61) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111101011011"));
MQQ62:TBL_MASTER_DEC_PT(62) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111100001010"));
MQQ63:TBL_MASTER_DEC_PT(63) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) ) , STD_ULOGIC_VECTOR'("0111110001010"));
MQQ64:TBL_MASTER_DEC_PT(64) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111000010010"));
MQQ65:TBL_MASTER_DEC_PT(65) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100001111"));
MQQ66:TBL_MASTER_DEC_PT(66) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100011111"));
MQQ67:TBL_MASTER_DEC_PT(67) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100011111"));
MQQ68:TBL_MASTER_DEC_PT(68) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111110100100"));
MQQ69:TBL_MASTER_DEC_PT(69) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) ) , STD_ULOGIC_VECTOR'("0111100111011"));
MQQ70:TBL_MASTER_DEC_PT(70) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111100101010"));
MQQ71:TBL_MASTER_DEC_PT(71) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111101000110"));
MQQ72:TBL_MASTER_DEC_PT(72) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) ) , STD_ULOGIC_VECTOR'("0111100000101"));
MQQ73:TBL_MASTER_DEC_PT(73) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) ) , STD_ULOGIC_VECTOR'("0111100001011"));
MQQ74:TBL_MASTER_DEC_PT(74) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("011110001111"));
MQQ75:TBL_MASTER_DEC_PT(75) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("011110001011"));
MQQ76:TBL_MASTER_DEC_PT(76) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("011110010110"));
MQQ77:TBL_MASTER_DEC_PT(77) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("011110010111"));
MQQ78:TBL_MASTER_DEC_PT(78) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011101111"));
MQQ79:TBL_MASTER_DEC_PT(79) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("010000"));
MQQ80:TBL_MASTER_DEC_PT(80) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("110100"));
MQQ81:TBL_MASTER_DEC_PT(81) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29)
     ) , STD_ULOGIC_VECTOR'("01111000"));
MQQ82:TBL_MASTER_DEC_PT(82) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("001000"));
MQQ83:TBL_MASTER_DEC_PT(83) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("001010"));
MQQ84:TBL_MASTER_DEC_PT(84) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("11100"));
MQQ85:TBL_MASTER_DEC_PT(85) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(27) ) , STD_ULOGIC_VECTOR'("0111100"));
MQQ86:TBL_MASTER_DEC_PT(86) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) ) , STD_ULOGIC_VECTOR'("01010"));
MQQ87:TBL_MASTER_DEC_PT(87) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) ) , STD_ULOGIC_VECTOR'("00001"));
MQQ88:TBL_MASTER_DEC_PT(88) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("001111"));
MQQ89:TBL_MASTER_DEC_PT(89) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("01101"));
MQQ90:TBL_MASTER_DEC_PT(90) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("01011"));
MQQ91:TBL_MASTER_DEC_PT(91) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("01101"));
MQQ92:TBL_MASTER_DEC_PT(92) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) ) , STD_ULOGIC_VECTOR'("00101"));
MQQ93:TBL_MASTER_DEC_PT(93) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(04)
     ) , STD_ULOGIC_VECTOR'("0110"));
MQQ94:TBL_MASTER_DEC_PT(94) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01)
     ) , STD_ULOGIC_VECTOR'("10"));
MQQ95:TBL_MASTER_DEC_PT(95) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03)
     ) , STD_ULOGIC_VECTOR'("0110"));
MQQ96:TBL_MASTER_DEC_PT(96) <=
    Eq(( RF1_INSTR_Q(01) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("011"));
MQQ97:TBL_MASTER_DEC_PT(97) <=
    Eq(( RF1_INSTR_Q(01) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) ) , STD_ULOGIC_VECTOR'("011"));
-- Table TBL_MASTER_DEC Signal Assignments for Outputs
MQQ98:DEC_BYP_RF1_IS_MCRF <= 
    (TBL_MASTER_DEC_PT(2));
MQQ99:DEC_BYP_RF1_IS_MTCRF <= 
    (TBL_MASTER_DEC_PT(17));
MQQ100:RF1_ADD_EXT <= 
    (TBL_MASTER_DEC_PT(40) OR TBL_MASTER_DEC_PT(68)
    );
MQQ101:RF1_ALU_CMP <= 
    (TBL_MASTER_DEC_PT(52) OR TBL_MASTER_DEC_PT(92)
    );
MQQ102:RF1_CMP <= 
    (TBL_MASTER_DEC_PT(45) OR TBL_MASTER_DEC_PT(52)
     OR TBL_MASTER_DEC_PT(87) OR TBL_MASTER_DEC_PT(92)
    );
MQQ103:RF1_CMP_UEXT <= 
    (TBL_MASTER_DEC_PT(14) OR TBL_MASTER_DEC_PT(83)
    );
MQQ104:RF1_CR_SO_UPDATE(00) <= 
    (TBL_MASTER_DEC_PT(5) OR TBL_MASTER_DEC_PT(7)
     OR TBL_MASTER_DEC_PT(8) OR TBL_MASTER_DEC_PT(9)
     OR TBL_MASTER_DEC_PT(10) OR TBL_MASTER_DEC_PT(11)
     OR TBL_MASTER_DEC_PT(17));
MQQ105:RF1_CR_SO_UPDATE(01) <= 
    (TBL_MASTER_DEC_PT(52) OR TBL_MASTER_DEC_PT(92)
    );
MQQ106:RF1_CR_WE <= 
    (TBL_MASTER_DEC_PT(2) OR TBL_MASTER_DEC_PT(5)
     OR TBL_MASTER_DEC_PT(7) OR TBL_MASTER_DEC_PT(8)
     OR TBL_MASTER_DEC_PT(9) OR TBL_MASTER_DEC_PT(10)
     OR TBL_MASTER_DEC_PT(11) OR TBL_MASTER_DEC_PT(52)
     OR TBL_MASTER_DEC_PT(92));
MQQ107:RF1_IMM_SIGNEXT_TBL <= 
    (TBL_MASTER_DEC_PT(79) OR TBL_MASTER_DEC_PT(80)
     OR TBL_MASTER_DEC_PT(82) OR TBL_MASTER_DEC_PT(84)
     OR TBL_MASTER_DEC_PT(87) OR TBL_MASTER_DEC_PT(94)
     OR TBL_MASTER_DEC_PT(96) OR TBL_MASTER_DEC_PT(97)
    );
MQQ108:RF1_IMM_SIZE_TBL <= 
    (TBL_MASTER_DEC_PT(31) OR TBL_MASTER_DEC_PT(34)
     OR TBL_MASTER_DEC_PT(79) OR TBL_MASTER_DEC_PT(80)
     OR TBL_MASTER_DEC_PT(82) OR TBL_MASTER_DEC_PT(83)
     OR TBL_MASTER_DEC_PT(84) OR TBL_MASTER_DEC_PT(87)
     OR TBL_MASTER_DEC_PT(93) OR TBL_MASTER_DEC_PT(94)
     OR TBL_MASTER_DEC_PT(95) OR TBL_MASTER_DEC_PT(96)
     OR TBL_MASTER_DEC_PT(97));
MQQ109:RF1_INSTR_HYPV_TBL <= 
    (TBL_MASTER_DEC_PT(3) OR TBL_MASTER_DEC_PT(4)
     OR TBL_MASTER_DEC_PT(18) OR TBL_MASTER_DEC_PT(22)
     OR TBL_MASTER_DEC_PT(29) OR TBL_MASTER_DEC_PT(41)
     OR TBL_MASTER_DEC_PT(44) OR TBL_MASTER_DEC_PT(46)
     OR TBL_MASTER_DEC_PT(47));
MQQ110:RF1_INSTR_PRIV_TBL <= 
    (TBL_MASTER_DEC_PT(13) OR TBL_MASTER_DEC_PT(15)
     OR TBL_MASTER_DEC_PT(16) OR TBL_MASTER_DEC_PT(18)
     OR TBL_MASTER_DEC_PT(19) OR TBL_MASTER_DEC_PT(20)
     OR TBL_MASTER_DEC_PT(22) OR TBL_MASTER_DEC_PT(25)
     OR TBL_MASTER_DEC_PT(26) OR TBL_MASTER_DEC_PT(27)
     OR TBL_MASTER_DEC_PT(31) OR TBL_MASTER_DEC_PT(35)
     OR TBL_MASTER_DEC_PT(41) OR TBL_MASTER_DEC_PT(44)
     OR TBL_MASTER_DEC_PT(46) OR TBL_MASTER_DEC_PT(51)
     OR TBL_MASTER_DEC_PT(55) OR TBL_MASTER_DEC_PT(59)
     OR TBL_MASTER_DEC_PT(64) OR TBL_MASTER_DEC_PT(65)
     OR TBL_MASTER_DEC_PT(66) OR TBL_MASTER_DEC_PT(67)
    );
MQQ111:RF1_IS_TRAP <= 
    (TBL_MASTER_DEC_PT(45) OR TBL_MASTER_DEC_PT(87)
    );
MQQ112:RF1_ONES_IMM <= 
    (TBL_MASTER_DEC_PT(40));
MQQ113:RF1_SEL(00) <= 
    (TBL_MASTER_DEC_PT(22) OR TBL_MASTER_DEC_PT(23)
     OR TBL_MASTER_DEC_PT(25) OR TBL_MASTER_DEC_PT(27)
     OR TBL_MASTER_DEC_PT(31) OR TBL_MASTER_DEC_PT(34)
     OR TBL_MASTER_DEC_PT(35) OR TBL_MASTER_DEC_PT(38)
     OR TBL_MASTER_DEC_PT(40) OR TBL_MASTER_DEC_PT(41)
     OR TBL_MASTER_DEC_PT(42) OR TBL_MASTER_DEC_PT(43)
     OR TBL_MASTER_DEC_PT(45) OR TBL_MASTER_DEC_PT(47)
     OR TBL_MASTER_DEC_PT(49) OR TBL_MASTER_DEC_PT(52)
     OR TBL_MASTER_DEC_PT(53) OR TBL_MASTER_DEC_PT(54)
     OR TBL_MASTER_DEC_PT(56) OR TBL_MASTER_DEC_PT(59)
     OR TBL_MASTER_DEC_PT(60) OR TBL_MASTER_DEC_PT(61)
     OR TBL_MASTER_DEC_PT(62) OR TBL_MASTER_DEC_PT(63)
     OR TBL_MASTER_DEC_PT(64) OR TBL_MASTER_DEC_PT(65)
     OR TBL_MASTER_DEC_PT(66) OR TBL_MASTER_DEC_PT(67)
     OR TBL_MASTER_DEC_PT(68) OR TBL_MASTER_DEC_PT(69)
     OR TBL_MASTER_DEC_PT(70) OR TBL_MASTER_DEC_PT(71)
     OR TBL_MASTER_DEC_PT(72) OR TBL_MASTER_DEC_PT(73)
     OR TBL_MASTER_DEC_PT(74) OR TBL_MASTER_DEC_PT(75)
     OR TBL_MASTER_DEC_PT(76) OR TBL_MASTER_DEC_PT(77)
     OR TBL_MASTER_DEC_PT(80) OR TBL_MASTER_DEC_PT(82)
     OR TBL_MASTER_DEC_PT(84) OR TBL_MASTER_DEC_PT(87)
     OR TBL_MASTER_DEC_PT(92) OR TBL_MASTER_DEC_PT(94)
     OR TBL_MASTER_DEC_PT(97));
MQQ114:RF1_SEL(01) <= 
    (TBL_MASTER_DEC_PT(21) OR TBL_MASTER_DEC_PT(24)
     OR TBL_MASTER_DEC_PT(30) OR TBL_MASTER_DEC_PT(37)
     OR TBL_MASTER_DEC_PT(48) OR TBL_MASTER_DEC_PT(50)
     OR TBL_MASTER_DEC_PT(81) OR TBL_MASTER_DEC_PT(85)
     OR TBL_MASTER_DEC_PT(86) OR TBL_MASTER_DEC_PT(90)
    );
MQQ115:RF1_SEL(02) <= 
    (TBL_MASTER_DEC_PT(32) OR TBL_MASTER_DEC_PT(36)
     OR TBL_MASTER_DEC_PT(57) OR TBL_MASTER_DEC_PT(58)
     OR TBL_MASTER_DEC_PT(78) OR TBL_MASTER_DEC_PT(93)
     OR TBL_MASTER_DEC_PT(95));
MQQ116:RF1_SEL(03) <= 
    (TBL_MASTER_DEC_PT(6));
MQQ117:RF1_SHIFT_IMM <= 
    (TBL_MASTER_DEC_PT(88) OR TBL_MASTER_DEC_PT(89)
     OR TBL_MASTER_DEC_PT(91));
MQQ118:RF1_SPR_SEL <= 
    (TBL_MASTER_DEC_PT(1) OR TBL_MASTER_DEC_PT(12)
     OR TBL_MASTER_DEC_PT(13) OR TBL_MASTER_DEC_PT(16)
     OR TBL_MASTER_DEC_PT(19) OR TBL_MASTER_DEC_PT(28)
    );
MQQ119:RF1_SUB <= 
    (TBL_MASTER_DEC_PT(23) OR TBL_MASTER_DEC_PT(45)
     OR TBL_MASTER_DEC_PT(52) OR TBL_MASTER_DEC_PT(53)
     OR TBL_MASTER_DEC_PT(82) OR TBL_MASTER_DEC_PT(87)
     OR TBL_MASTER_DEC_PT(92));
MQQ120:RF1_ZERO_IMM <= 
    (TBL_MASTER_DEC_PT(23) OR TBL_MASTER_DEC_PT(33)
     OR TBL_MASTER_DEC_PT(34) OR TBL_MASTER_DEC_PT(35)
     OR TBL_MASTER_DEC_PT(39) OR TBL_MASTER_DEC_PT(43)
    );

--
-- Final Table Listing
--          *INPUTS*==========================================================*OUTPUTS*============================================*
--          |                                                                 |                                                    |
--          | rf1_instr_q                                                     |                                                    |
--          | |      rf1_instr_q                                              |                                                    |
--          | |      | rf1_instr_q                                            | rf1_derat_is_load                                  |
--          | |      | |          rf1_instr_q                                 | | rf1_derat_is_store                               |
--          | |      | |          |  rf1_axu_ld_or_st_q                       | | | rf1_is_any_load_axu                            |
--          | |      | |          |  | rf1_axu_ldst_size_q                    | | | | rf1_is_any_load_dac                          |
--          | |      | |          |  | |      rf1_axu_mftgpr_q                | | | | | rf1_is_any_store                           |
--          | |      | |          |  | |      | rf1_axu_mffgpr_q              | | | | | | rf1_is_any_store_axu                     |
--          | |      | |          |  | |      | | rf1_axu_movedp_q            | | | | | | | rf1_is_any_store_dac                   |
--          | |      | |          |  | |      | | | rf1_axu_store_q           | | | | | | | | rf1_is_ld_w_update                   |
--          | |      | |          |  | |      | | | | rf1_xer_si_zero_b       | | | | | | | | | rf1_is_st_w_update                 |
--          | |      | |          |  | |      | | | | | rf1_axu_ldst_update_q | | | | | | | | | | xu_lsu_rf1_algebraic             |
--          | |      | |          |  | |      | | | | | |                     | | | | | | | | | | | xu_lsu_rf1_ldawx_instr         |
--          | |      | |          |  | |      | | | | | |                     | | | | | | | | | | | | xu_lsu_rf1_optype1           |
--          | |      | |          |  | |      | | | | | |                     | | | | | | | | | | | | | xu_lsu_rf1_optype16        |
--          | |      | |          |  | |      | | | | | |                     | | | | | | | | | | | | | | xu_lsu_rf1_optype2       |
--          | |      | |          |  | |      | | | | | |                     | | | | | | | | | | | | | | | xu_lsu_rf1_optype32    |
--          | |      | |          |  | |      | | | | | |                     | | | | | | | | | | | | | | | | xu_lsu_rf1_optype4   |
--          | |      | |          |  | |      | | | | | |                     | | | | | | | | | | | | | | | | | xu_lsu_rf1_optype8 |
--          | |      | |          |  | |      | | | | | |                     | | | | | | | | | | | | | | | | | |                  |
--          | 000000 0 2222222223 33 | 000000 | | | | | |                     | | | | | | | | | | | | | | | | | |                  |
--          | 012345 9 1234567890 01 | 012345 | | | | | |                     | | | | | | | | | | | | | | | | | |                  |
--          *TYPE*============================================================+====================================================+
--          | PPPPPP P PPPPPPPPPP PP P PPPPPP P P P P P P                     | P P P P P P P P P P P P P P P P P                  |
--          *POLARITY*------------------------------------------------------->| + + + + + + + + + + + + + + + + +                  |
--          *PHASE*---------------------------------------------------------->| T T T T T T T T T T T T T T T T T                  |
--          *TERMS*===========================================================+====================================================+
--    1     | 011111 1 1110100110 -- - ------ - - - - - -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--    2     | 011111 - 0011010100 -- - ------ - - - - - -                     | . . . . . . . . . . 1 . . . . . .                  |
--    3     | 011111 - 1111111111 -- - ------ - - - - - -                     | . 1 . . 1 . 1 . . . . . . . . . .                  |
--    4     | 011111 - 1111011111 -- - ------ - - - - - -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--    5     | 011111 - 0011110111 -- - ------ - - - - - -                     | . . . . . 1 . . 1 . . 1 . . . . .                  |
--    6     | 011111 - 1001010101 -- - ------ - - - - - -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--    7     | 011111 - 0110000110 -- - ------ - - - - - -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--    8     | 011111 - 1110110110 -- - ------ - - - - - -                     | . 1 . . 1 . . . . . . . . . . 1 .                  |
--    9     | 011111 - 101001010- -- - ------ - - - - 1 -                     | . 1 . . 1 . 1 . . . . . . . . . .                  |
--   10     | 011111 - 1111110110 -- - ------ - - - - - -                     | . 1 . . 1 . 1 . . . . . . . . . .                  |
--   11     | 011111 - 0011010110 -- - ------ - - - - - -                     | . . . . . 1 . . . . . . . . . . 1                  |
--   12     | 011111 - 1111010110 -- - ------ - - - - - -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--   13     | 011111 - 1011010101 -- - ------ - - - - - -                     | . 1 . . 1 . 1 . . . . . . . . . .                  |
--   14     | 011111 - 0000110110 -- - ------ - - - - - -                     | 1 . . . . . 1 . . . . . . . . . .                  |
--   15     | 011111 - 1000010100 -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . . . . . . 1                  |
--   16     | 011111 - 0001010110 -- - ------ - - - - - -                     | 1 . . . . . 1 . . . . . . . . . .                  |
--   17     | 011111 - 010001-111 -- - ------ - - - - - -                     | . . 1 . . . . . . . . . . 1 . . .                  |
--   18     | 011111 - 0-11100110 -- - ------ - - - - - -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--   19     | 011111 - 1100010110 -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . . . 1 . . .                  |
--   20     | 011111 - 0101010101 -- - ------ - - - - - -                     | 1 . 1 1 . . . . . 1 . . . . . 1 .                  |
--   21     | 011111 - 000-111111 -- - ------ - - - - - -                     | 1 . . . . . 1 . . . . . . . . . .                  |
--   22     | 011111 - 001101-111 -- - ------ - - - - - -                     | . . . . . 1 . . . . . 1 . . . . .                  |
--   23     | 011111 - -00001010- -- - ------ - - - - 1 -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--   24     | 011111 - 001-100110 -- - ------ - - - - - -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--   25     | 011111 - 1010010100 -- - ------ - - - - - -                     | . 1 . . 1 1 1 . . . . . . . . . 1                  |
--   26     | 011111 - 0000010100 -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . . . . . 1 .                  |
--   27     | 011111 - 1000010110 -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . . . . . 1 .                  |
--   28     | 011111 - 1110010110 -- - ------ - - - - - -                     | . 1 . . 1 1 1 . . . . . . 1 . . .                  |
--   29     | 011111 - 0101010111 -- - ------ - - - - - -                     | 1 . 1 1 . . . . . 1 . . . 1 . . .                  |
--   30     | 011111 - 01011101-1 -- - ------ - - - - - -                     | 1 . . 1 . . . 1 . . . . . . . . .                  |
--   31     | 011111 - 0010110101 -- - ------ - - - - - -                     | . 1 . . 1 1 1 . 1 . . . . . . . 1                  |
--   32     | 011111 - 0110110111 -- - ------ - - - - - -                     | . 1 . . 1 1 1 . 1 . . . . 1 . . .                  |
--   33     | 011111 - 00001101-1 -- - ------ - - - - - -                     | 1 . . 1 . . . 1 . . . . . . . . .                  |
--   34     | 011111 - 0010110111 -- - ------ - - - - - -                     | . 1 . . 1 1 1 . 1 . . . . . . 1 .                  |
--   35     | 011111 - 000001-101 -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . . . . . . 1                  |
--   36     | 011111 - 00100-0110 -- - ------ - - - - - -                     | . 1 . . 1 . 1 . . . . . . . . . .                  |
--   37     | 011111 - 0-10010110 -- - ------ - - - - - -                     | . 1 . . 1 . . . . . . . . . . 1 .                  |
--   38     | 011111 - 00-1010100 -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . . . . . . 1                  |
--   39     | 011111 - 000101-111 -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . 1 . . . . .                  |
--   40     | 011111 - 0-11010110 -- - ------ - - - - - -                     | . 1 . . 1 . 1 . . . . . . . . . .                  |
--   41     | 011111 - 001001-101 -- - ------ - - - - - -                     | . 1 . . 1 1 1 . . . . . . . . . 1                  |
--   42     | ------ - ---------- -- 1 ------ 0 0 0 0 - 1                     | . . . . . . . 1 . . . . . . . . .                  |
--   43     | ------ - ---------- -- 1 ------ 0 0 0 1 - 1                     | . . . . . . . . 1 . . . . . . . .                  |
--   44     | 011111 - 000001-111 -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . . . . . 1 .                  |
--   45     | 011111 - 011001-111 -- - ------ - - - - - -                     | . 1 . . 1 1 1 . . . . . . 1 . . .                  |
--   46     | 011111 - 0100-1-111 -- - ------ - - - - - -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--   47     | 011111 - 0-0-110111 -- - ------ - - - - - -                     | 1 . . 1 . . . 1 . . . . . . . . .                  |
--   48     | 011111 - 001001-111 -- - ------ - - - - - -                     | . 1 . . 1 1 1 . . . . . . . . 1 .                  |
--   49     | 011111 - -010010110 -- - ------ - - - - - -                     | . 1 . . 1 1 1 . . . . . . . . 1 .                  |
--   50     | 011111 - 0011-1-111 -- - ------ - - - - - -                     | . 1 . . 1 . 1 . . . . . . . . . .                  |
--   51     | 011111 - 0-0001011- -- - ------ - - - - - -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--   52     | 011111 - 0011-1011- -- - ------ - - - - - -                     | . 1 . . 1 . 1 . . . . . . . . . .                  |
--   53     | 111110 - ---------- 01 - ------ - - - - - -                     | . . . . . . . . 1 . . . . . . . .                  |
--   54     | 111010 - ---------- 01 - ------ - - - - - -                     | 1 . . 1 . . . 1 . . . . . . . . .                  |
--   55     | 100000 - ---------- -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . . . . . 1 .                  |
--   56     | 111010 - ---------- 00 - ------ - - - - - -                     | 1 . 1 1 . . . . . . . . . . . . 1                  |
--   57     | 111010 - ---------- 10 - ------ - - - - - -                     | 1 . 1 1 . . . . . 1 . . . . . 1 .                  |
--   58     | 101010 - ---------- -- - ------ - - - - - -                     | . . . . . . . . . 1 . . . . . . .                  |
--   59     | ------ - ---------- -- 1 ------ 0 0 0 0 - -                     | 1 . 1 1 . . . . . . . . . . . . .                  |
--   60     | ------ - ---------- -- 1 ------ 0 0 0 1 - -                     | . 1 . . 1 1 1 . . . . . . . . . .                  |
--   61     | 100010 - ---------- -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . 1 . . . . .                  |
--   62     | 1001-1 - ---------- -- - ------ - - - - - -                     | . . . . . . . . 1 . . . . . . . .                  |
--   63     | 10-101 - ---------- -- - ------ - - - - - -                     | . . . . . . . . 1 . . . . . . . .                  |
--   64     | 1010-0 - ---------- -- - ------ - - - - - -                     | 1 . 1 1 . . . . . . . . . 1 . . .                  |
--   65     | 10010- - ---------- -- - ------ - - - - - -                     | . 1 . . 1 1 1 . . . . . . . . 1 .                  |
--   66     | 111110 - ---------- 0- - ------ - - - - - -                     | . 1 . . 1 1 1 . . . . . . . . . 1                  |
--   67     | 101-10 - ---------- -- - ------ - - - - - -                     | 1 . . 1 . . . . . . . . . . . . .                  |
--   68     | 10-0-1 - ---------- -- - ------ - - - - - -                     | 1 . . 1 . . . 1 . . . . . . . . .                  |
--   69     | ------ - ---------- -- 1 -1---- - - - - - -                     | . . . . . . . . . . . . 1 . . . .                  |
--   70     | ------ - ---------- -- 1 1----- - - - - - -                     | . . . . . . . . . . . . . . 1 . .                  |
--   71     | ------ - ---------- -- 1 -----1 - - - - - -                     | . . . . . . . . . . . 1 . . . . .                  |
--   72     | 10011- - ---------- -- - ------ - - - - - -                     | . 1 . . 1 1 1 . . . . 1 . . . . .                  |
--   73     | ------ - ---------- -- 1 ----1- - - - - - -                     | . . . . . . . . . . . . . 1 . . .                  |
--   74     | 10110- - ---------- -- - ------ - - - - - -                     | . 1 . . 1 1 1 . . . . . . 1 . . .                  |
--   75     | ------ - ---------- -- 1 --1--- - - - - - -                     | . . . . . . . . . . . . . . . . 1                  |
--   76     | ------ - ---------- -- 1 ---1-- - - - - - -                     | . . . . . . . . . . . . . . . 1 .                  |
--   77     | 10-1-1 - ---------- -- - ------ - - - - - -                     | . 1 . . 1 . 1 . . . . . . . . . .                  |
--          *======================================================================================================================*
--
-- Table TBL_LD_ST_DEC Signal Assignments for Product Terms
MQQ121:TBL_LD_ST_DEC_PT(1) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(09) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("01111111110100110"));
MQQ122:TBL_LD_ST_DEC_PT(2) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110011010100"));
MQQ123:TBL_LD_ST_DEC_PT(3) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111111111111"));
MQQ124:TBL_LD_ST_DEC_PT(4) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111111011111"));
MQQ125:TBL_LD_ST_DEC_PT(5) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110011110111"));
MQQ126:TBL_LD_ST_DEC_PT(6) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111001010101"));
MQQ127:TBL_LD_ST_DEC_PT(7) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110110000110"));
MQQ128:TBL_LD_ST_DEC_PT(8) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111110110110"));
MQQ129:TBL_LD_ST_DEC_PT(9) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_XER_SI_ZERO_B
     ) , STD_ULOGIC_VECTOR'("0111111010010101"));
MQQ130:TBL_LD_ST_DEC_PT(10) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111111110110"));
MQQ131:TBL_LD_ST_DEC_PT(11) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110011010110"));
MQQ132:TBL_LD_ST_DEC_PT(12) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111111010110"));
MQQ133:TBL_LD_ST_DEC_PT(13) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111011010101"));
MQQ134:TBL_LD_ST_DEC_PT(14) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110000110110"));
MQQ135:TBL_LD_ST_DEC_PT(15) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111000010100"));
MQQ136:TBL_LD_ST_DEC_PT(16) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110001010110"));
MQQ137:TBL_LD_ST_DEC_PT(17) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111010001111"));
MQQ138:TBL_LD_ST_DEC_PT(18) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111011100110"));
MQQ139:TBL_LD_ST_DEC_PT(19) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111100010110"));
MQQ140:TBL_LD_ST_DEC_PT(20) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110101010101"));
MQQ141:TBL_LD_ST_DEC_PT(21) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111000111111"));
MQQ142:TBL_LD_ST_DEC_PT(22) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001101111"));
MQQ143:TBL_LD_ST_DEC_PT(23) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_XER_SI_ZERO_B ) , STD_ULOGIC_VECTOR'("011111000010101"));
MQQ144:TBL_LD_ST_DEC_PT(24) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001100110"));
MQQ145:TBL_LD_ST_DEC_PT(25) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111010010100"));
MQQ146:TBL_LD_ST_DEC_PT(26) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110000010100"));
MQQ147:TBL_LD_ST_DEC_PT(27) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111000010110"));
MQQ148:TBL_LD_ST_DEC_PT(28) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111110010110"));
MQQ149:TBL_LD_ST_DEC_PT(29) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110101010111"));
MQQ150:TBL_LD_ST_DEC_PT(30) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111010111011"));
MQQ151:TBL_LD_ST_DEC_PT(31) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110010110101"));
MQQ152:TBL_LD_ST_DEC_PT(32) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110110110111"));
MQQ153:TBL_LD_ST_DEC_PT(33) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111000011011"));
MQQ154:TBL_LD_ST_DEC_PT(34) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110010110111"));
MQQ155:TBL_LD_ST_DEC_PT(35) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111000001101"));
MQQ156:TBL_LD_ST_DEC_PT(36) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001000110"));
MQQ157:TBL_LD_ST_DEC_PT(37) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111010010110"));
MQQ158:TBL_LD_ST_DEC_PT(38) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001010100"));
MQQ159:TBL_LD_ST_DEC_PT(39) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111000101111"));
MQQ160:TBL_LD_ST_DEC_PT(40) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111011010110"));
MQQ161:TBL_LD_ST_DEC_PT(41) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001001101"));
MQQ162:TBL_LD_ST_DEC_PT(42) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_MFTGPR_Q & 
    RF1_AXU_MFFGPR_Q & RF1_AXU_MOVEDP_Q & 
    RF1_AXU_STORE_Q & RF1_AXU_LDST_UPDATE_Q
     ) , STD_ULOGIC_VECTOR'("100001"));
MQQ163:TBL_LD_ST_DEC_PT(43) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_MFTGPR_Q & 
    RF1_AXU_MFFGPR_Q & RF1_AXU_MOVEDP_Q & 
    RF1_AXU_STORE_Q & RF1_AXU_LDST_UPDATE_Q
     ) , STD_ULOGIC_VECTOR'("100011"));
MQQ164:TBL_LD_ST_DEC_PT(44) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111000001111"));
MQQ165:TBL_LD_ST_DEC_PT(45) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111011001111"));
MQQ166:TBL_LD_ST_DEC_PT(46) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111101001111"));
MQQ167:TBL_LD_ST_DEC_PT(47) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100110111"));
MQQ168:TBL_LD_ST_DEC_PT(48) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001001111"));
MQQ169:TBL_LD_ST_DEC_PT(49) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111010010110"));
MQQ170:TBL_LD_ST_DEC_PT(50) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100111111"));
MQQ171:TBL_LD_ST_DEC_PT(51) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29)
     ) , STD_ULOGIC_VECTOR'("01111100001011"));
MQQ172:TBL_LD_ST_DEC_PT(52) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29)
     ) , STD_ULOGIC_VECTOR'("01111100111011"));
MQQ173:TBL_LD_ST_DEC_PT(53) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("11111001"));
MQQ174:TBL_LD_ST_DEC_PT(54) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("11101001"));
MQQ175:TBL_LD_ST_DEC_PT(55) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("100000"));
MQQ176:TBL_LD_ST_DEC_PT(56) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("11101000"));
MQQ177:TBL_LD_ST_DEC_PT(57) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("11101010"));
MQQ178:TBL_LD_ST_DEC_PT(58) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("101010"));
MQQ179:TBL_LD_ST_DEC_PT(59) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_MFTGPR_Q & 
    RF1_AXU_MFFGPR_Q & RF1_AXU_MOVEDP_Q & 
    RF1_AXU_STORE_Q ) , STD_ULOGIC_VECTOR'("10000"));
MQQ180:TBL_LD_ST_DEC_PT(60) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_MFTGPR_Q & 
    RF1_AXU_MFFGPR_Q & RF1_AXU_MOVEDP_Q & 
    RF1_AXU_STORE_Q ) , STD_ULOGIC_VECTOR'("10001"));
MQQ181:TBL_LD_ST_DEC_PT(61) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("100010"));
MQQ182:TBL_LD_ST_DEC_PT(62) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("10011"));
MQQ183:TBL_LD_ST_DEC_PT(63) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("10101"));
MQQ184:TBL_LD_ST_DEC_PT(64) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("10100"));
MQQ185:TBL_LD_ST_DEC_PT(65) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) ) , STD_ULOGIC_VECTOR'("10010"));
MQQ186:TBL_LD_ST_DEC_PT(66) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("1111100"));
MQQ187:TBL_LD_ST_DEC_PT(67) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ188:TBL_LD_ST_DEC_PT(68) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ189:TBL_LD_ST_DEC_PT(69) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_LDST_SIZE_Q(01)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ190:TBL_LD_ST_DEC_PT(70) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_LDST_SIZE_Q(00)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ191:TBL_LD_ST_DEC_PT(71) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_LDST_SIZE_Q(05)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ192:TBL_LD_ST_DEC_PT(72) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) ) , STD_ULOGIC_VECTOR'("10011"));
MQQ193:TBL_LD_ST_DEC_PT(73) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_LDST_SIZE_Q(04)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ194:TBL_LD_ST_DEC_PT(74) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ195:TBL_LD_ST_DEC_PT(75) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_LDST_SIZE_Q(02)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ196:TBL_LD_ST_DEC_PT(76) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_LDST_SIZE_Q(03)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ197:TBL_LD_ST_DEC_PT(77) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("1011"));
-- Table TBL_LD_ST_DEC Signal Assignments for Outputs
MQQ198:RF1_DERAT_IS_LOAD <= 
    (TBL_LD_ST_DEC_PT(1) OR TBL_LD_ST_DEC_PT(4)
     OR TBL_LD_ST_DEC_PT(6) OR TBL_LD_ST_DEC_PT(7)
     OR TBL_LD_ST_DEC_PT(12) OR TBL_LD_ST_DEC_PT(14)
     OR TBL_LD_ST_DEC_PT(15) OR TBL_LD_ST_DEC_PT(16)
     OR TBL_LD_ST_DEC_PT(18) OR TBL_LD_ST_DEC_PT(19)
     OR TBL_LD_ST_DEC_PT(20) OR TBL_LD_ST_DEC_PT(21)
     OR TBL_LD_ST_DEC_PT(23) OR TBL_LD_ST_DEC_PT(24)
     OR TBL_LD_ST_DEC_PT(26) OR TBL_LD_ST_DEC_PT(27)
     OR TBL_LD_ST_DEC_PT(29) OR TBL_LD_ST_DEC_PT(30)
     OR TBL_LD_ST_DEC_PT(33) OR TBL_LD_ST_DEC_PT(35)
     OR TBL_LD_ST_DEC_PT(38) OR TBL_LD_ST_DEC_PT(39)
     OR TBL_LD_ST_DEC_PT(44) OR TBL_LD_ST_DEC_PT(46)
     OR TBL_LD_ST_DEC_PT(47) OR TBL_LD_ST_DEC_PT(51)
     OR TBL_LD_ST_DEC_PT(54) OR TBL_LD_ST_DEC_PT(55)
     OR TBL_LD_ST_DEC_PT(56) OR TBL_LD_ST_DEC_PT(57)
     OR TBL_LD_ST_DEC_PT(59) OR TBL_LD_ST_DEC_PT(61)
     OR TBL_LD_ST_DEC_PT(64) OR TBL_LD_ST_DEC_PT(67)
     OR TBL_LD_ST_DEC_PT(68));
MQQ199:RF1_DERAT_IS_STORE <= 
    (TBL_LD_ST_DEC_PT(3) OR TBL_LD_ST_DEC_PT(8)
     OR TBL_LD_ST_DEC_PT(9) OR TBL_LD_ST_DEC_PT(10)
     OR TBL_LD_ST_DEC_PT(13) OR TBL_LD_ST_DEC_PT(25)
     OR TBL_LD_ST_DEC_PT(28) OR TBL_LD_ST_DEC_PT(31)
     OR TBL_LD_ST_DEC_PT(32) OR TBL_LD_ST_DEC_PT(34)
     OR TBL_LD_ST_DEC_PT(36) OR TBL_LD_ST_DEC_PT(37)
     OR TBL_LD_ST_DEC_PT(40) OR TBL_LD_ST_DEC_PT(41)
     OR TBL_LD_ST_DEC_PT(45) OR TBL_LD_ST_DEC_PT(48)
     OR TBL_LD_ST_DEC_PT(49) OR TBL_LD_ST_DEC_PT(50)
     OR TBL_LD_ST_DEC_PT(52) OR TBL_LD_ST_DEC_PT(60)
     OR TBL_LD_ST_DEC_PT(65) OR TBL_LD_ST_DEC_PT(66)
     OR TBL_LD_ST_DEC_PT(72) OR TBL_LD_ST_DEC_PT(74)
     OR TBL_LD_ST_DEC_PT(77));
MQQ200:RF1_IS_ANY_LOAD_AXU <= 
    (TBL_LD_ST_DEC_PT(15) OR TBL_LD_ST_DEC_PT(17)
     OR TBL_LD_ST_DEC_PT(19) OR TBL_LD_ST_DEC_PT(20)
     OR TBL_LD_ST_DEC_PT(26) OR TBL_LD_ST_DEC_PT(27)
     OR TBL_LD_ST_DEC_PT(29) OR TBL_LD_ST_DEC_PT(35)
     OR TBL_LD_ST_DEC_PT(38) OR TBL_LD_ST_DEC_PT(39)
     OR TBL_LD_ST_DEC_PT(44) OR TBL_LD_ST_DEC_PT(55)
     OR TBL_LD_ST_DEC_PT(56) OR TBL_LD_ST_DEC_PT(57)
     OR TBL_LD_ST_DEC_PT(59) OR TBL_LD_ST_DEC_PT(61)
     OR TBL_LD_ST_DEC_PT(64));
MQQ201:RF1_IS_ANY_LOAD_DAC <= 
    (TBL_LD_ST_DEC_PT(1) OR TBL_LD_ST_DEC_PT(4)
     OR TBL_LD_ST_DEC_PT(6) OR TBL_LD_ST_DEC_PT(7)
     OR TBL_LD_ST_DEC_PT(12) OR TBL_LD_ST_DEC_PT(15)
     OR TBL_LD_ST_DEC_PT(18) OR TBL_LD_ST_DEC_PT(19)
     OR TBL_LD_ST_DEC_PT(20) OR TBL_LD_ST_DEC_PT(23)
     OR TBL_LD_ST_DEC_PT(24) OR TBL_LD_ST_DEC_PT(26)
     OR TBL_LD_ST_DEC_PT(27) OR TBL_LD_ST_DEC_PT(29)
     OR TBL_LD_ST_DEC_PT(30) OR TBL_LD_ST_DEC_PT(33)
     OR TBL_LD_ST_DEC_PT(35) OR TBL_LD_ST_DEC_PT(38)
     OR TBL_LD_ST_DEC_PT(39) OR TBL_LD_ST_DEC_PT(44)
     OR TBL_LD_ST_DEC_PT(46) OR TBL_LD_ST_DEC_PT(47)
     OR TBL_LD_ST_DEC_PT(51) OR TBL_LD_ST_DEC_PT(54)
     OR TBL_LD_ST_DEC_PT(55) OR TBL_LD_ST_DEC_PT(56)
     OR TBL_LD_ST_DEC_PT(57) OR TBL_LD_ST_DEC_PT(59)
     OR TBL_LD_ST_DEC_PT(61) OR TBL_LD_ST_DEC_PT(64)
     OR TBL_LD_ST_DEC_PT(67) OR TBL_LD_ST_DEC_PT(68)
    );
MQQ202:RF1_IS_ANY_STORE <= 
    (TBL_LD_ST_DEC_PT(3) OR TBL_LD_ST_DEC_PT(8)
     OR TBL_LD_ST_DEC_PT(9) OR TBL_LD_ST_DEC_PT(10)
     OR TBL_LD_ST_DEC_PT(13) OR TBL_LD_ST_DEC_PT(25)
     OR TBL_LD_ST_DEC_PT(28) OR TBL_LD_ST_DEC_PT(31)
     OR TBL_LD_ST_DEC_PT(32) OR TBL_LD_ST_DEC_PT(34)
     OR TBL_LD_ST_DEC_PT(36) OR TBL_LD_ST_DEC_PT(37)
     OR TBL_LD_ST_DEC_PT(40) OR TBL_LD_ST_DEC_PT(41)
     OR TBL_LD_ST_DEC_PT(45) OR TBL_LD_ST_DEC_PT(48)
     OR TBL_LD_ST_DEC_PT(49) OR TBL_LD_ST_DEC_PT(50)
     OR TBL_LD_ST_DEC_PT(52) OR TBL_LD_ST_DEC_PT(60)
     OR TBL_LD_ST_DEC_PT(65) OR TBL_LD_ST_DEC_PT(66)
     OR TBL_LD_ST_DEC_PT(72) OR TBL_LD_ST_DEC_PT(74)
     OR TBL_LD_ST_DEC_PT(77));
MQQ203:RF1_IS_ANY_STORE_AXU <= 
    (TBL_LD_ST_DEC_PT(5) OR TBL_LD_ST_DEC_PT(11)
     OR TBL_LD_ST_DEC_PT(22) OR TBL_LD_ST_DEC_PT(25)
     OR TBL_LD_ST_DEC_PT(28) OR TBL_LD_ST_DEC_PT(31)
     OR TBL_LD_ST_DEC_PT(32) OR TBL_LD_ST_DEC_PT(34)
     OR TBL_LD_ST_DEC_PT(41) OR TBL_LD_ST_DEC_PT(45)
     OR TBL_LD_ST_DEC_PT(48) OR TBL_LD_ST_DEC_PT(49)
     OR TBL_LD_ST_DEC_PT(60) OR TBL_LD_ST_DEC_PT(65)
     OR TBL_LD_ST_DEC_PT(66) OR TBL_LD_ST_DEC_PT(72)
     OR TBL_LD_ST_DEC_PT(74));
MQQ204:RF1_IS_ANY_STORE_DAC <= 
    (TBL_LD_ST_DEC_PT(3) OR TBL_LD_ST_DEC_PT(9)
     OR TBL_LD_ST_DEC_PT(10) OR TBL_LD_ST_DEC_PT(13)
     OR TBL_LD_ST_DEC_PT(14) OR TBL_LD_ST_DEC_PT(16)
     OR TBL_LD_ST_DEC_PT(21) OR TBL_LD_ST_DEC_PT(25)
     OR TBL_LD_ST_DEC_PT(28) OR TBL_LD_ST_DEC_PT(31)
     OR TBL_LD_ST_DEC_PT(32) OR TBL_LD_ST_DEC_PT(34)
     OR TBL_LD_ST_DEC_PT(36) OR TBL_LD_ST_DEC_PT(40)
     OR TBL_LD_ST_DEC_PT(41) OR TBL_LD_ST_DEC_PT(45)
     OR TBL_LD_ST_DEC_PT(48) OR TBL_LD_ST_DEC_PT(49)
     OR TBL_LD_ST_DEC_PT(50) OR TBL_LD_ST_DEC_PT(52)
     OR TBL_LD_ST_DEC_PT(60) OR TBL_LD_ST_DEC_PT(65)
     OR TBL_LD_ST_DEC_PT(66) OR TBL_LD_ST_DEC_PT(72)
     OR TBL_LD_ST_DEC_PT(74) OR TBL_LD_ST_DEC_PT(77)
    );
MQQ205:RF1_IS_LD_W_UPDATE <= 
    (TBL_LD_ST_DEC_PT(30) OR TBL_LD_ST_DEC_PT(33)
     OR TBL_LD_ST_DEC_PT(42) OR TBL_LD_ST_DEC_PT(47)
     OR TBL_LD_ST_DEC_PT(54) OR TBL_LD_ST_DEC_PT(68)
    );
MQQ206:RF1_IS_ST_W_UPDATE <= 
    (TBL_LD_ST_DEC_PT(5) OR TBL_LD_ST_DEC_PT(31)
     OR TBL_LD_ST_DEC_PT(32) OR TBL_LD_ST_DEC_PT(34)
     OR TBL_LD_ST_DEC_PT(43) OR TBL_LD_ST_DEC_PT(53)
     OR TBL_LD_ST_DEC_PT(62) OR TBL_LD_ST_DEC_PT(63)
    );
MQQ207:XU_LSU_RF1_ALGEBRAIC <= 
    (TBL_LD_ST_DEC_PT(20) OR TBL_LD_ST_DEC_PT(29)
     OR TBL_LD_ST_DEC_PT(57) OR TBL_LD_ST_DEC_PT(58)
    );
MQQ208:XU_LSU_RF1_LDAWX_INSTR <= 
    (TBL_LD_ST_DEC_PT(2));
MQQ209:XU_LSU_RF1_OPTYPE1 <= 
    (TBL_LD_ST_DEC_PT(5) OR TBL_LD_ST_DEC_PT(22)
     OR TBL_LD_ST_DEC_PT(39) OR TBL_LD_ST_DEC_PT(61)
     OR TBL_LD_ST_DEC_PT(71) OR TBL_LD_ST_DEC_PT(72)
    );
MQQ210:XU_LSU_RF1_OPTYPE16 <= 
    (TBL_LD_ST_DEC_PT(69));
MQQ211:XU_LSU_RF1_OPTYPE2 <= 
    (TBL_LD_ST_DEC_PT(17) OR TBL_LD_ST_DEC_PT(19)
     OR TBL_LD_ST_DEC_PT(28) OR TBL_LD_ST_DEC_PT(29)
     OR TBL_LD_ST_DEC_PT(32) OR TBL_LD_ST_DEC_PT(45)
     OR TBL_LD_ST_DEC_PT(64) OR TBL_LD_ST_DEC_PT(73)
     OR TBL_LD_ST_DEC_PT(74));
MQQ212:XU_LSU_RF1_OPTYPE32 <= 
    (TBL_LD_ST_DEC_PT(70));
MQQ213:XU_LSU_RF1_OPTYPE4 <= 
    (TBL_LD_ST_DEC_PT(8) OR TBL_LD_ST_DEC_PT(20)
     OR TBL_LD_ST_DEC_PT(26) OR TBL_LD_ST_DEC_PT(27)
     OR TBL_LD_ST_DEC_PT(34) OR TBL_LD_ST_DEC_PT(37)
     OR TBL_LD_ST_DEC_PT(44) OR TBL_LD_ST_DEC_PT(48)
     OR TBL_LD_ST_DEC_PT(49) OR TBL_LD_ST_DEC_PT(55)
     OR TBL_LD_ST_DEC_PT(57) OR TBL_LD_ST_DEC_PT(65)
     OR TBL_LD_ST_DEC_PT(76));
MQQ214:XU_LSU_RF1_OPTYPE8 <= 
    (TBL_LD_ST_DEC_PT(11) OR TBL_LD_ST_DEC_PT(15)
     OR TBL_LD_ST_DEC_PT(25) OR TBL_LD_ST_DEC_PT(31)
     OR TBL_LD_ST_DEC_PT(35) OR TBL_LD_ST_DEC_PT(38)
     OR TBL_LD_ST_DEC_PT(41) OR TBL_LD_ST_DEC_PT(56)
     OR TBL_LD_ST_DEC_PT(66) OR TBL_LD_ST_DEC_PT(75)
    );

--
-- Final Table Listing
--          *INPUTS*====================================*OUTPUTS*==========================*
--          |                                           |                                  |
--          | rf1_instr_q                               |                                  |
--          | |      rf1_instr_q                        |                                  |
--          | |      |          rf1_instr_q             | rf1_use_crfld0                   |
--          | |      |          | rf1_axu_mftgpr        | | rf1_use_crfld0_nmult           |
--          | |      |          | | rf1_axu_mffgpr      | | | xu_lsu_rf1_icswx_instr       |
--          | |      |          | | | rf1_axu_movedp    | | | | xu_lsu_rf1_icswx_dot_instr |
--          | |      |          | | | | rf1_val_stg     | | | | | xu_lsu_rf1_icswx_epid    |
--          | |      |          | | | | |               | | | | | | ex1_is_icswx_d         |
--          | |      |          | | | | |               | | | | | | |                      |
--          | 000000 2222222223 3 | | | |               | | | | | | |                      |
--          | 012345 1234567890 1 | | | |               | | | | | | |                      |
--          *TYPE*======================================+==================================+
--          | PPPPPP PPPPPPPPPP P P P P P               | P P P P P P                      |
--          *POLARITY*--------------------------------->| + + + + + +                      |
--          *PHASE*------------------------------------>| T T T T T T                      |
--          *TERMS*=====================================+==================================+
--    1     | 011111 1110110110 0 - - - -               | . . 1 . 1 1                      |
--    2     | 011111 0110010110 0 - - - -               | . . 1 . . 1                      |
--    3     | 011111 1110110110 1 - - - -               | . . . 1 1 1                      |
--    4     | 011111 0110010110 1 - - - -               | . . . 1 . 1                      |
--    5     | 0111-- 000--00011 1 - - - -               | 1 1 . . . .                      |
--    6     | 01-1-1 000-111100 1 - - - -               | 1 1 . . . .                      |
--    7     | 01-1-1 011-011100 1 - - - -               | 1 1 . . . .                      |
--    8     | 01-1-1 -000011011 1 - - - -               | 1 1 . . . .                      |
--    9     | 01-1-1 110011101- 1 - - - -               | 1 1 . . . .                      |
--   10     | 01-1-1 -0111010-- 1 - - - -               | 1 . . . . .                      |
--   11     | 01-1-1 -00-0010-1 1 - - - -               | 1 . . . . .                      |
--   12     | 01-1-1 111-011010 1 - - - -               | 1 1 . . . .                      |
--   13     | 0111-- -00-101000 1 - - - -               | 1 1 . . . .                      |
--   14     | 01-1-1 -011-010-0 1 - - - -               | . 1 . . . .                      |
--   15     | 0111-- -0000-1000 1 - - - -               | 1 1 . . . .                      |
--   16     | 01-1-1 0-00-11100 1 - - - -               | 1 1 . . . .                      |
--   17     | 01-1-1 01-0-11100 1 - - - -               | 1 1 . . . .                      |
--   18     | 01-1-1 --00001010 1 - - - -               | 1 1 . . . .                      |
--   19     | 01-1-1 11-0-11010 1 - - - -               | 1 1 . . . .                      |
--   20     | 01-1-1 1100-110-0 1 - - - -               | 1 1 . . . .                      |
--   21     | 01-1-1 -01-0010-0 1 - - - -               | 1 1 . . . .                      |
--   22     | 0111-0 -------00- 1 - - - -               | 1 1 . . . .                      |
--   23     | ------ ---------- 1 - 1 1 1               | 1 1 . . . .                      |
--   24     | ------ ---------- 1 1 - 1 1               | 1 1 . . . .                      |
--   25     | 0111-0 ------0--- 1 - - - -               | 1 1 . . . .                      |
--   26     | 0-1101 ---------- - - - - -               | 1 1 . . . .                      |
--   27     | 01110- ---------- - - - - -               | 1 1 . . . .                      |
--   28     | 0101-1 ---------- 1 - - - -               | 1 1 . . . .                      |
--   29     | 01-10- ---------- 1 - - - -               | 1 1 . . . .                      |
--          *==============================================================================*
--
-- Table TBL_RECFORM_DEC Signal Assignments for Product Terms
MQQ215:TBL_RECFORM_DEC_PT(1) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("01111111101101100"));
MQQ216:TBL_RECFORM_DEC_PT(2) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("01111101100101100"));
MQQ217:TBL_RECFORM_DEC_PT(3) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("01111111101101101"));
MQQ218:TBL_RECFORM_DEC_PT(4) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("01111101100101101"));
MQQ219:TBL_RECFORM_DEC_PT(5) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111000000111"));
MQQ220:TBL_RECFORM_DEC_PT(6) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01110001111001"));
MQQ221:TBL_RECFORM_DEC_PT(7) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01110110111001"));
MQQ222:TBL_RECFORM_DEC_PT(8) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01110000110111"));
MQQ223:TBL_RECFORM_DEC_PT(9) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111100111011"));
MQQ224:TBL_RECFORM_DEC_PT(10) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("011101110101"));
MQQ225:TBL_RECFORM_DEC_PT(11) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("011100001011"));
MQQ226:TBL_RECFORM_DEC_PT(12) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111110110101"));
MQQ227:TBL_RECFORM_DEC_PT(13) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111001010001"));
MQQ228:TBL_RECFORM_DEC_PT(14) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("011101101001"));
MQQ229:TBL_RECFORM_DEC_PT(15) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111000010001"));
MQQ230:TBL_RECFORM_DEC_PT(16) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111000111001"));
MQQ231:TBL_RECFORM_DEC_PT(17) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111010111001"));
MQQ232:TBL_RECFORM_DEC_PT(18) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111000010101"));
MQQ233:TBL_RECFORM_DEC_PT(19) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111110110101"));
MQQ234:TBL_RECFORM_DEC_PT(20) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111110011001"));
MQQ235:TBL_RECFORM_DEC_PT(21) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("011101001001"));
MQQ236:TBL_RECFORM_DEC_PT(22) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01110001"));
MQQ237:TBL_RECFORM_DEC_PT(23) <=
    Eq(( RF1_INSTR_Q(31) & RF1_AXU_MFFGPR & 
    RF1_AXU_MOVEDP & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ238:TBL_RECFORM_DEC_PT(24) <=
    Eq(( RF1_INSTR_Q(31) & RF1_AXU_MFTGPR & 
    RF1_AXU_MOVEDP & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("1111"));
MQQ239:TBL_RECFORM_DEC_PT(25) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111001"));
MQQ240:TBL_RECFORM_DEC_PT(26) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("01101"));
MQQ241:TBL_RECFORM_DEC_PT(27) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) ) , STD_ULOGIC_VECTOR'("01110"));
MQQ242:TBL_RECFORM_DEC_PT(28) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("010111"));
MQQ243:TBL_RECFORM_DEC_PT(29) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("01101"));
-- Table TBL_RECFORM_DEC Signal Assignments for Outputs
MQQ244:RF1_USE_CRFLD0 <= 
    (TBL_RECFORM_DEC_PT(5) OR TBL_RECFORM_DEC_PT(6)
     OR TBL_RECFORM_DEC_PT(7) OR TBL_RECFORM_DEC_PT(8)
     OR TBL_RECFORM_DEC_PT(9) OR TBL_RECFORM_DEC_PT(10)
     OR TBL_RECFORM_DEC_PT(11) OR TBL_RECFORM_DEC_PT(12)
     OR TBL_RECFORM_DEC_PT(13) OR TBL_RECFORM_DEC_PT(15)
     OR TBL_RECFORM_DEC_PT(16) OR TBL_RECFORM_DEC_PT(17)
     OR TBL_RECFORM_DEC_PT(18) OR TBL_RECFORM_DEC_PT(19)
     OR TBL_RECFORM_DEC_PT(20) OR TBL_RECFORM_DEC_PT(21)
     OR TBL_RECFORM_DEC_PT(22) OR TBL_RECFORM_DEC_PT(23)
     OR TBL_RECFORM_DEC_PT(24) OR TBL_RECFORM_DEC_PT(25)
     OR TBL_RECFORM_DEC_PT(26) OR TBL_RECFORM_DEC_PT(27)
     OR TBL_RECFORM_DEC_PT(28) OR TBL_RECFORM_DEC_PT(29)
    );
MQQ245:RF1_USE_CRFLD0_NMULT <= 
    (TBL_RECFORM_DEC_PT(5) OR TBL_RECFORM_DEC_PT(6)
     OR TBL_RECFORM_DEC_PT(7) OR TBL_RECFORM_DEC_PT(8)
     OR TBL_RECFORM_DEC_PT(9) OR TBL_RECFORM_DEC_PT(12)
     OR TBL_RECFORM_DEC_PT(13) OR TBL_RECFORM_DEC_PT(14)
     OR TBL_RECFORM_DEC_PT(15) OR TBL_RECFORM_DEC_PT(16)
     OR TBL_RECFORM_DEC_PT(17) OR TBL_RECFORM_DEC_PT(18)
     OR TBL_RECFORM_DEC_PT(19) OR TBL_RECFORM_DEC_PT(20)
     OR TBL_RECFORM_DEC_PT(21) OR TBL_RECFORM_DEC_PT(22)
     OR TBL_RECFORM_DEC_PT(23) OR TBL_RECFORM_DEC_PT(24)
     OR TBL_RECFORM_DEC_PT(25) OR TBL_RECFORM_DEC_PT(26)
     OR TBL_RECFORM_DEC_PT(27) OR TBL_RECFORM_DEC_PT(28)
     OR TBL_RECFORM_DEC_PT(29));
MQQ246:XU_LSU_RF1_ICSWX_INSTR <= 
    (TBL_RECFORM_DEC_PT(1) OR TBL_RECFORM_DEC_PT(2)
    );
MQQ247:XU_LSU_RF1_ICSWX_DOT_INSTR <= 
    (TBL_RECFORM_DEC_PT(3) OR TBL_RECFORM_DEC_PT(4)
    );
MQQ248:XU_LSU_RF1_ICSWX_EPID <= 
    (TBL_RECFORM_DEC_PT(1) OR TBL_RECFORM_DEC_PT(3)
    );
MQQ249:EX1_IS_ICSWX_D <= 
    (TBL_RECFORM_DEC_PT(1) OR TBL_RECFORM_DEC_PT(2)
     OR TBL_RECFORM_DEC_PT(3) OR TBL_RECFORM_DEC_PT(4)
    );

--
-- Final Table Listing
--          *INPUTS*===================================*OUTPUTS*=================*
--          |                                          |                         |
--          | rf1_instr_q                              | dec_byp_rf1_ca_used     |
--          | |      rf1_instr_q                       | | dec_byp_rf1_ov_used   |
--          | |      |          rf1_instr_q            | | | rf1_xer_ca_update   |
--          | |      |          |          rf1_instr_q | | | | rf1_xer_ov_update |
--          | |      |          |          |           | | | | |                 |
--          | 000000 1111111112 2222222223 3           | | | | |                 |
--          | 012345 1234567890 1234567890 1           | | | | |                 |
--          *TYPE*=====================================+=========================+
--          | PPPPPP PPPPPPPPPP PPPPPPPPPP P           | P P P P                 |
--          *POLARITY*-------------------------------->| + + + +                 |
--          *PHASE*----------------------------------->| T T T T                 |
--          *TERMS*====================================+=========================+
--    1     | 011111 0000100000 0101010011 -           | 1 1 . .                 |
--    2     | 011111 ---------- 110011101- -           | . . 1 .                 |
--    3     | 01-1-1 ---------- 110011101- 1           | . 1 . .                 |
--    4     | 0111-1 ---------- 001-010110 -           | . 1 . .                 |
--    5     | 011111 ---------- 100-101000 -           | . . . 1                 |
--    6     | 01-1-1 ---------- 011-011100 1           | . 1 . .                 |
--    7     | 011111 ---------- 1-00001010 -           | . . . 1                 |
--    8     | 01-1-1 ---------- 000-111100 1           | . 1 . .                 |
--    9     | 011111 ---------- 10111010-- -           | . . . 1                 |
--   10     | 0111-1 ---------- 0000-00000 -           | . 1 . .                 |
--   11     | 011111 ---------- 1011-010-0 -           | . . . 1                 |
--   12     | 01-1-1 ---------- 111-011010 1           | . 1 . .                 |
--   13     | 011111 ---------- 1100-110-0 -           | . . 1 .                 |
--   14     | 01-1-1 ---------- 1100-110-0 1           | . 1 . .                 |
--   15     | 01-1-1 ---------- 01-0-11100 1           | . 1 . .                 |
--   16     | 011111 ---------- 111--010-1 -           | . . . 1                 |
--   17     | 011111 ---------- 10-00010-0 -           | . . . 1                 |
--   18     | 01-1-1 ---------- 0-00-11100 1           | . 1 . .                 |
--   19     | 01-1-1 ---------- -0000-1011 1           | . 1 . .                 |
--   20     | 011111 ---------- -011-010-0 -           | 1 . 1 .                 |
--   21     | 011111 ---------- -01-0010-0 -           | 1 . . .                 |
--   22     | 01-1-1 ---------- 11-0-11010 1           | . 1 . .                 |
--   23     | 0111-- ---------- -00-101000 1           | . 1 . .                 |
--   24     | 01-1-1 ---------- -01-0010-0 1           | . 1 . .                 |
--   25     | 011111 ---------- -0-00010-0 -           | . . 1 .                 |
--   26     | 0111-- ---------- -0000-1000 1           | . 1 . .                 |
--   27     | 01-1-1 ---------- --00001010 1           | . 1 . .                 |
--   28     | 01-1-1 ---------- -0111010-- 1           | . 1 . .                 |
--   29     | 01-1-1 ---------- -00-0010-1 1           | . 1 . .                 |
--   30     | 001-00 ---------- ---------- -           | . . 1 .                 |
--   31     | 0111-0 ---------- -------00- 1           | . 1 . .                 |
--   32     | 00101- ---------- ---------- -           | . 1 . .                 |
--   33     | 0111-0 ---------- ------0--- 1           | . 1 . .                 |
--   34     | 001101 ---------- ---------- -           | . 1 1 .                 |
--   35     | 0101-1 ---------- ---------- 1           | . 1 . .                 |
--   36     | 01-10- ---------- ---------- 1           | . 1 . .                 |
--   37     | 01110- ---------- ---------- -           | . 1 . .                 |
--          *====================================================================*
--
-- Table TBL_XER_DEC Signal Assignments for Product Terms
MQQ250:TBL_XER_DEC_PT(1) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(11) & RF1_INSTR_Q(12) & 
    RF1_INSTR_Q(13) & RF1_INSTR_Q(14) & 
    RF1_INSTR_Q(15) & RF1_INSTR_Q(16) & 
    RF1_INSTR_Q(17) & RF1_INSTR_Q(18) & 
    RF1_INSTR_Q(19) & RF1_INSTR_Q(20) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100001000000101010011"));
MQQ251:TBL_XER_DEC_PT(2) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) ) , STD_ULOGIC_VECTOR'("011111110011101"));
MQQ252:TBL_XER_DEC_PT(3) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111100111011"));
MQQ253:TBL_XER_DEC_PT(4) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111001010110"));
MQQ254:TBL_XER_DEC_PT(5) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111100101000"));
MQQ255:TBL_XER_DEC_PT(6) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01110110111001"));
MQQ256:TBL_XER_DEC_PT(7) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111100001010"));
MQQ257:TBL_XER_DEC_PT(8) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01110001111001"));
MQQ258:TBL_XER_DEC_PT(9) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28)
     ) , STD_ULOGIC_VECTOR'("01111110111010"));
MQQ259:TBL_XER_DEC_PT(10) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111000000000"));
MQQ260:TBL_XER_DEC_PT(11) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111110110100"));
MQQ261:TBL_XER_DEC_PT(12) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111110110101"));
MQQ262:TBL_XER_DEC_PT(13) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111111001100"));
MQQ263:TBL_XER_DEC_PT(14) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111110011001"));
MQQ264:TBL_XER_DEC_PT(15) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111010111001"));
MQQ265:TBL_XER_DEC_PT(16) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111111110101"));
MQQ266:TBL_XER_DEC_PT(17) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111110000100"));
MQQ267:TBL_XER_DEC_PT(18) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111000111001"));
MQQ268:TBL_XER_DEC_PT(19) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111000010111"));
MQQ269:TBL_XER_DEC_PT(20) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111110110100"));
MQQ270:TBL_XER_DEC_PT(21) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111110100100"));
MQQ271:TBL_XER_DEC_PT(22) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111110110101"));
MQQ272:TBL_XER_DEC_PT(23) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111001010001"));
MQQ273:TBL_XER_DEC_PT(24) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("011101001001"));
MQQ274:TBL_XER_DEC_PT(25) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111110000100"));
MQQ275:TBL_XER_DEC_PT(26) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111000010001"));
MQQ276:TBL_XER_DEC_PT(27) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111000010101"));
MQQ277:TBL_XER_DEC_PT(28) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("011101110101"));
MQQ278:TBL_XER_DEC_PT(29) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("011100001011"));
MQQ279:TBL_XER_DEC_PT(30) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("00100"));
MQQ280:TBL_XER_DEC_PT(31) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01110001"));
MQQ281:TBL_XER_DEC_PT(32) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) ) , STD_ULOGIC_VECTOR'("00101"));
MQQ282:TBL_XER_DEC_PT(33) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("0111001"));
MQQ283:TBL_XER_DEC_PT(34) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("001101"));
MQQ284:TBL_XER_DEC_PT(35) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("010111"));
MQQ285:TBL_XER_DEC_PT(36) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("01101"));
MQQ286:TBL_XER_DEC_PT(37) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) ) , STD_ULOGIC_VECTOR'("01110"));
-- Table TBL_XER_DEC Signal Assignments for Outputs
MQQ287:DEC_BYP_RF1_CA_USED <= 
    (TBL_XER_DEC_PT(1) OR TBL_XER_DEC_PT(20)
     OR TBL_XER_DEC_PT(21));
MQQ288:DEC_BYP_RF1_OV_USED <= 
    (TBL_XER_DEC_PT(1) OR TBL_XER_DEC_PT(3)
     OR TBL_XER_DEC_PT(4) OR TBL_XER_DEC_PT(6)
     OR TBL_XER_DEC_PT(8) OR TBL_XER_DEC_PT(10)
     OR TBL_XER_DEC_PT(12) OR TBL_XER_DEC_PT(14)
     OR TBL_XER_DEC_PT(15) OR TBL_XER_DEC_PT(18)
     OR TBL_XER_DEC_PT(19) OR TBL_XER_DEC_PT(22)
     OR TBL_XER_DEC_PT(23) OR TBL_XER_DEC_PT(24)
     OR TBL_XER_DEC_PT(26) OR TBL_XER_DEC_PT(27)
     OR TBL_XER_DEC_PT(28) OR TBL_XER_DEC_PT(29)
     OR TBL_XER_DEC_PT(31) OR TBL_XER_DEC_PT(32)
     OR TBL_XER_DEC_PT(33) OR TBL_XER_DEC_PT(34)
     OR TBL_XER_DEC_PT(35) OR TBL_XER_DEC_PT(36)
     OR TBL_XER_DEC_PT(37));
MQQ289:RF1_XER_CA_UPDATE <= 
    (TBL_XER_DEC_PT(2) OR TBL_XER_DEC_PT(13)
     OR TBL_XER_DEC_PT(20) OR TBL_XER_DEC_PT(25)
     OR TBL_XER_DEC_PT(30) OR TBL_XER_DEC_PT(34)
    );
MQQ290:RF1_XER_OV_UPDATE <= 
    (TBL_XER_DEC_PT(5) OR TBL_XER_DEC_PT(7)
     OR TBL_XER_DEC_PT(9) OR TBL_XER_DEC_PT(11)
     OR TBL_XER_DEC_PT(16) OR TBL_XER_DEC_PT(17)
    );

--
-- Final Table Listing
--          *INPUTS*=============================*OUTPUTS*=*
--          |                                    |         |
--          | rf1_instr_q                        | rf1_pri |
--          | |      rf1_instr_q                 | |       |
--          | |      |               rf1_instr_q | |       |
--          | |      |               |           | |       |
--          | 000000 000011111111112 22222222233 | 000     |
--          | 012345 678901234567890 12345678901 | 012     |
--          *TYPE*===============================+=========+
--          | PPPPPP PPPPPPPPPPPPPPP PPPPPPPPPPP | PPP     |
--          *POLARITY*-------------------------->| +++     |
--          *PHASE*----------------------------->| TTT     |
--          *TERMS*==============================+=========+
--    1     | 011111 111111111111111 01101111000 | ..1     |
--    2     | 011111 000100001000010 01101111000 | 1..     |
--    3     | 011111 000010000100001 01101111000 | .1.     |
--    4     | 011111 001010010100101 01101111000 | 1.1     |
--    5     | 011111 001100011000110 01101111000 | .11     |
--    6     | 011111 000110001100011 01101111000 | 11.     |
--    7     | 011111 001110011100111 01101111000 | 111     |
--          *==============================================*
--
-- Table TBL_PRI_CHANGE Signal Assignments for Product Terms
MQQ291:TBL_PRI_CHANGE_PT(1) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(06) & RF1_INSTR_Q(07) & 
    RF1_INSTR_Q(08) & RF1_INSTR_Q(09) & 
    RF1_INSTR_Q(10) & RF1_INSTR_Q(11) & 
    RF1_INSTR_Q(12) & RF1_INSTR_Q(13) & 
    RF1_INSTR_Q(14) & RF1_INSTR_Q(15) & 
    RF1_INSTR_Q(16) & RF1_INSTR_Q(17) & 
    RF1_INSTR_Q(18) & RF1_INSTR_Q(19) & 
    RF1_INSTR_Q(20) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111111111111111111101101111000"));
MQQ292:TBL_PRI_CHANGE_PT(2) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(06) & RF1_INSTR_Q(07) & 
    RF1_INSTR_Q(08) & RF1_INSTR_Q(09) & 
    RF1_INSTR_Q(10) & RF1_INSTR_Q(11) & 
    RF1_INSTR_Q(12) & RF1_INSTR_Q(13) & 
    RF1_INSTR_Q(14) & RF1_INSTR_Q(15) & 
    RF1_INSTR_Q(16) & RF1_INSTR_Q(17) & 
    RF1_INSTR_Q(18) & RF1_INSTR_Q(19) & 
    RF1_INSTR_Q(20) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111100010000100001001101111000"));
MQQ293:TBL_PRI_CHANGE_PT(3) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(06) & RF1_INSTR_Q(07) & 
    RF1_INSTR_Q(08) & RF1_INSTR_Q(09) & 
    RF1_INSTR_Q(10) & RF1_INSTR_Q(11) & 
    RF1_INSTR_Q(12) & RF1_INSTR_Q(13) & 
    RF1_INSTR_Q(14) & RF1_INSTR_Q(15) & 
    RF1_INSTR_Q(16) & RF1_INSTR_Q(17) & 
    RF1_INSTR_Q(18) & RF1_INSTR_Q(19) & 
    RF1_INSTR_Q(20) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111100001000010000101101111000"));
MQQ294:TBL_PRI_CHANGE_PT(4) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(06) & RF1_INSTR_Q(07) & 
    RF1_INSTR_Q(08) & RF1_INSTR_Q(09) & 
    RF1_INSTR_Q(10) & RF1_INSTR_Q(11) & 
    RF1_INSTR_Q(12) & RF1_INSTR_Q(13) & 
    RF1_INSTR_Q(14) & RF1_INSTR_Q(15) & 
    RF1_INSTR_Q(16) & RF1_INSTR_Q(17) & 
    RF1_INSTR_Q(18) & RF1_INSTR_Q(19) & 
    RF1_INSTR_Q(20) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111100101001010010101101111000"));
MQQ295:TBL_PRI_CHANGE_PT(5) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(06) & RF1_INSTR_Q(07) & 
    RF1_INSTR_Q(08) & RF1_INSTR_Q(09) & 
    RF1_INSTR_Q(10) & RF1_INSTR_Q(11) & 
    RF1_INSTR_Q(12) & RF1_INSTR_Q(13) & 
    RF1_INSTR_Q(14) & RF1_INSTR_Q(15) & 
    RF1_INSTR_Q(16) & RF1_INSTR_Q(17) & 
    RF1_INSTR_Q(18) & RF1_INSTR_Q(19) & 
    RF1_INSTR_Q(20) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111100110001100011001101111000"));
MQQ296:TBL_PRI_CHANGE_PT(6) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(06) & RF1_INSTR_Q(07) & 
    RF1_INSTR_Q(08) & RF1_INSTR_Q(09) & 
    RF1_INSTR_Q(10) & RF1_INSTR_Q(11) & 
    RF1_INSTR_Q(12) & RF1_INSTR_Q(13) & 
    RF1_INSTR_Q(14) & RF1_INSTR_Q(15) & 
    RF1_INSTR_Q(16) & RF1_INSTR_Q(17) & 
    RF1_INSTR_Q(18) & RF1_INSTR_Q(19) & 
    RF1_INSTR_Q(20) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111100011000110001101101111000"));
MQQ297:TBL_PRI_CHANGE_PT(7) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(06) & RF1_INSTR_Q(07) & 
    RF1_INSTR_Q(08) & RF1_INSTR_Q(09) & 
    RF1_INSTR_Q(10) & RF1_INSTR_Q(11) & 
    RF1_INSTR_Q(12) & RF1_INSTR_Q(13) & 
    RF1_INSTR_Q(14) & RF1_INSTR_Q(15) & 
    RF1_INSTR_Q(16) & RF1_INSTR_Q(17) & 
    RF1_INSTR_Q(18) & RF1_INSTR_Q(19) & 
    RF1_INSTR_Q(20) & RF1_INSTR_Q(21) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_INSTR_Q(31)
     ) , STD_ULOGIC_VECTOR'("01111100111001110011101101111000"));
-- Table TBL_PRI_CHANGE Signal Assignments for Outputs
MQQ298:RF1_PRI(00) <= 
    (TBL_PRI_CHANGE_PT(2) OR TBL_PRI_CHANGE_PT(4)
     OR TBL_PRI_CHANGE_PT(6) OR TBL_PRI_CHANGE_PT(7)
    );
MQQ299:RF1_PRI(01) <= 
    (TBL_PRI_CHANGE_PT(3) OR TBL_PRI_CHANGE_PT(5)
     OR TBL_PRI_CHANGE_PT(6) OR TBL_PRI_CHANGE_PT(7)
    );
MQQ300:RF1_PRI(02) <= 
    (TBL_PRI_CHANGE_PT(1) OR TBL_PRI_CHANGE_PT(4)
     OR TBL_PRI_CHANGE_PT(5) OR TBL_PRI_CHANGE_PT(7)
    );

--
-- Final Table Listing
--          *INPUTS*==================================================*OUTPUTS*=========================================*
--          |                                                         |                                                 |
--          | rf1_instr_q                                             | rf1_cache_acc                                   |
--          | |      rf1_instr_q                                      | | xu_lsu_rf1_is_msgsnd                          |
--          | |      |          rf1_instr_q                           | | | xu_lsu_rf1_mbar_instr                       |
--          | |      |          |          rf1_instr_q                | | | | xu_lsu_rf1_sync_instr                     |
--          | |      |          |          |  rf1_axu_ld_or_st_q      | | | | | xu_lsu_rf1_tlbsync_instr                |
--          | |      |          |          |  | rf1_axu_mftgpr        | | | | | | xu_lsu_rf1_wclr_instr                 |
--          | |      |          |          |  | | rf1_axu_mffgpr      | | | | | | | xu_lsu_rf1_wchk_instr               |
--          | |      |          |          |  | | | rf1_axu_movedp    | | | | | | | | xu_lsu_rf1_src_gpr                |
--          | |      |          |          |  | | | | rf1_val_stg     | | | | | | | | | xu_lsu_rf1_src_axu              |
--          | |      |          |          |  | | | | |               | | | | | | | | | | xu_lsu_rf1_src_dp             |
--          | |      |          |          |  | | | | |               | | | | | | | | | | | xu_lsu_rf1_targ_gpr         |
--          | |      |          |          |  | | | | |               | | | | | | | | | | | | xu_lsu_rf1_targ_axu       |
--          | |      |          |          |  | | | | |               | | | | | | | | | | | | | xu_lsu_rf1_targ_dp      |
--          | |      |          |          |  | | | | |               | | | | | | | | | | | | | | rf1_cmd_act           |
--          | |      |          |          |  | | | | |               | | | | | | | | | | | | | | | xu_lsu_rf1_data_act |
--          | |      |          |          |  | | | | |               | | | | | | | | | | | | | | | | rf1_mtspr_trace   |
--          | |      |          |          |  | | | | |               | | | | | | | | | | | | | | | | | rf1_derat_act   |
--          | 000000 1111111112 2222222223 33 | | | | |               | | | | | | | | | | | | | | | | | |               |
--          | 012345 1234567890 1234567890 01 | | | | |               | | | | | | | | | | | | | | | | | |               |
--          *TYPE*====================================================+=================================================+
--          | PPPPPP PPPPPPPPPP PPPPPPPPPP PP P P P P P               | P P P P P P P P P P P P P P P P P               |
--          *POLARITY*----------------------------------------------->| + + + + + + + + + + + + + + + + +               |
--          *PHASE*-------------------------------------------------->| T T T T T T T T T T T T T T T T T               |
--          *TERMS*===================================================+=================================================+
--    1     | 011111 0111011111 0111010011 -- - - - - 1               | . . . . . . . . . . . . . 1 . 1 .               |
--    2     | 011111 ---------- 0000-00011 -- - - - 0 1               | . . . . . . . . . . 1 . . . . . .               |
--    3     | 011111 ---------- 1110000110 -- - - - - 1               | . . . . . . 1 . . . . . . . . . .               |
--    4     | 011111 ---------- 0011001110 -- - - - - 1               | . 1 . . . . . . . . . . . 1 . . .               |
--    5     | 011111 ---------- 1101010110 -- - - - - 1               | . . 1 . . . . . . . . . . 1 . . .               |
--    6     | 011111 ---------- 1000110110 -- - - - - 1               | . . . . 1 . . . . . . . . 1 . . .               |
--    7     | 011111 ---------- 1110100110 -- - - - - 1               | 1 . . . . 1 . . . . . . . 1 . . .               |
--    8     | 011111 ---------- 1001010110 -- - - - - 1               | . . . 1 . . . . . . . . . 1 . . .               |
--    9     | 011111 ---------- 1110-10110 -- - - - - 1               | . . . . . . . . . . . . . . 1 . .               |
--   10     | 011111 ---------- 0001-00011 -- - - - - 1               | . . . . . . . 1 . . . . 1 1 1 . .               |
--   11     | 011111 ---------- 0000-00011 -- - - - - 1               | . . . . . . . . . 1 . . . 1 1 . .               |
--   12     | 011111 ---------- 1111-11111 -- - - - - 1               | 1 . . . . . . . . . . . . 1 . . 1               |
--   13     | 011111 ---------- 0-11100110 -- - - - - 1               | 1 . . . . . . . . . . . . 1 . . 1               |
--   14     | 011111 ---------- 001--10111 -- - - - - 1               | . . . . . . . . . . . . . . 1 . .               |
--   15     | 011111 ---------- 0-1001011- -- - - - - 1               | . . . . . . . . . . . . . . 1 . .               |
--   16     | 011111 ---------- 001-01011- -- - - - - 1               | . . . . . . . . . . . . . . 1 . .               |
--   17     | 011111 ---------- -11-0-0110 -- - - - - 1               | . . . . . . . . . . . . . 1 . . .               |
--   18     | 011111 ---------- 00--01-111 -- - - - - 1               | . . . . . . . . . . . . . . 1 . .               |
--   19     | 011111 ---------- 0010-00110 -- - - - - 1               | 1 . . . . . . . . . . . . 1 . . 1               |
--   20     | 011111 ---------- 0-100-0110 -- - - - - 1               | 1 . . . . . . . . . . . . . . . 1               |
--   21     | 011111 ---------- 01010101-1 -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   22     | 011111 ---------- 0-1-010110 -- - - - - 1               | 1 . . . . . . . . . . . . . . . 1               |
--   23     | 011111 ---------- 0-00-11111 -- - - - - 1               | 1 . . . . . . . . . . . . 1 . . 1               |
--   24     | 011111 ---------- 00-1010100 -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   25     | 011111 ---------- 0000-10110 -- - - - - 1               | 1 . . . . . . . . . . . . 1 . . 1               |
--   26     | 011111 ---------- 00-1-11111 -- - - - - 1               | 1 . . . . . . . . . . . . 1 . . 1               |
--   27     | 011111 ---------- 000001010- -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   28     | 011111 ---------- 111--10110 -- - - - - 1               | 1 . . . . . . . . . . . . 1 . . 1               |
--   29     | 011111 ---------- 0011-1011- -- - - - - 1               | 1 . . . . . . . . . . . . 1 . . 1               |
--   30     | 011111 ---------- 10-00101-0 -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   31     | 011111 ---------- 0010-101-1 -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   32     | 011111 ---------- 1--0010110 -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   33     | 011111 ---------- 0-10-10111 -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   34     | 011111 ---------- 00-001-1-1 -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   35     | 011111 ---------- 0--001011- -- - - - - 1               | 1 . . . . . . . . . . . . 1 . . 1               |
--   36     | 011111 ---------- 00--01011- -- - - - - 1               | 1 . . . . . . . . . . . . 1 . . 1               |
--   37     | 011111 ---------- 0--001-111 -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   38     | 1-1010 ---------- ---------- -0 - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   39     | ------ ---------- ---------- -- 1 0 0 0 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   40     | 10-0-0 ---------- ---------- -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   41     | 111110 ---------- ---------- 0- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   42     | ------ ---------- ---------- -- - - 1 1 1               | . . . . . . . . . 1 . 1 . 1 1 . .               |
--   43     | ------ ---------- ---------- -- - 1 - 1 1               | . . . . . . . . 1 . . . 1 1 1 . .               |
--   44     | ------ ---------- ---------- -- - 1 - 0 1               | . . . . . . . . 1 . 1 . . 1 1 . .               |
--   45     | ------ ---------- ---------- -- - - 1 0 1               | . . . . . . . 1 . . . 1 . 1 1 . .               |
--   46     | 10-10- ---------- ---------- -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--   47     | 1001-- ---------- ---------- -- - - - - 1               | 1 . . . . . . . . . . . . 1 1 . 1               |
--          *===========================================================================================================*
--
-- Table TBL_VAL_STG_GATE Signal Assignments for Product Terms
MQQ301:TBL_VAL_STG_GATE_PT(1) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(11) & RF1_INSTR_Q(12) & 
    RF1_INSTR_Q(13) & RF1_INSTR_Q(14) & 
    RF1_INSTR_Q(15) & RF1_INSTR_Q(16) & 
    RF1_INSTR_Q(17) & RF1_INSTR_Q(18) & 
    RF1_INSTR_Q(19) & RF1_INSTR_Q(20) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111011101111101110100111"));
MQQ302:TBL_VAL_STG_GATE_PT(2) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_AXU_MOVEDP & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("01111100000001101"));
MQQ303:TBL_VAL_STG_GATE_PT(3) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("01111111100001101"));
MQQ304:TBL_VAL_STG_GATE_PT(4) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("01111100110011101"));
MQQ305:TBL_VAL_STG_GATE_PT(5) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("01111111010101101"));
MQQ306:TBL_VAL_STG_GATE_PT(6) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("01111110001101101"));
MQQ307:TBL_VAL_STG_GATE_PT(7) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("01111111101001101"));
MQQ308:TBL_VAL_STG_GATE_PT(8) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("01111110010101101"));
MQQ309:TBL_VAL_STG_GATE_PT(9) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("0111111110101101"));
MQQ310:TBL_VAL_STG_GATE_PT(10) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("0111110001000111"));
MQQ311:TBL_VAL_STG_GATE_PT(11) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("0111110000000111"));
MQQ312:TBL_VAL_STG_GATE_PT(12) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("0111111111111111"));
MQQ313:TBL_VAL_STG_GATE_PT(13) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("0111110111001101"));
MQQ314:TBL_VAL_STG_GATE_PT(14) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111001101111"));
MQQ315:TBL_VAL_STG_GATE_PT(15) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111010010111"));
MQQ316:TBL_VAL_STG_GATE_PT(16) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111001010111"));
MQQ317:TBL_VAL_STG_GATE_PT(17) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(22) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("01111111001101"));
MQQ318:TBL_VAL_STG_GATE_PT(18) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("01111100011111"));
MQQ319:TBL_VAL_STG_GATE_PT(19) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("0111110010001101"));
MQQ320:TBL_VAL_STG_GATE_PT(20) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111010001101"));
MQQ321:TBL_VAL_STG_GATE_PT(21) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("0111110101010111"));
MQQ322:TBL_VAL_STG_GATE_PT(22) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111010101101"));
MQQ323:TBL_VAL_STG_GATE_PT(23) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111000111111"));
MQQ324:TBL_VAL_STG_GATE_PT(24) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("0111110010101001"));
MQQ325:TBL_VAL_STG_GATE_PT(25) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("0111110000101101"));
MQQ326:TBL_VAL_STG_GATE_PT(26) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111001111111"));
MQQ327:TBL_VAL_STG_GATE_PT(27) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("0111110000010101"));
MQQ328:TBL_VAL_STG_GATE_PT(28) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111111101101"));
MQQ329:TBL_VAL_STG_GATE_PT(29) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111001110111"));
MQQ330:TBL_VAL_STG_GATE_PT(30) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111100010101"));
MQQ331:TBL_VAL_STG_GATE_PT(31) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(23) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(27) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111001010111"));
MQQ332:TBL_VAL_STG_GATE_PT(32) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111100101101"));
MQQ333:TBL_VAL_STG_GATE_PT(33) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(23) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_INSTR_Q(30) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("011111010101111"));
MQQ334:TBL_VAL_STG_GATE_PT(34) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(24) & RF1_INSTR_Q(25) & 
    RF1_INSTR_Q(26) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("01111100001111"));
MQQ335:TBL_VAL_STG_GATE_PT(35) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("01111100010111"));
MQQ336:TBL_VAL_STG_GATE_PT(36) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(22) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(27) & RF1_INSTR_Q(28) & 
    RF1_INSTR_Q(29) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("01111100010111"));
MQQ337:TBL_VAL_STG_GATE_PT(37) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(21) & RF1_INSTR_Q(24) & 
    RF1_INSTR_Q(25) & RF1_INSTR_Q(26) & 
    RF1_INSTR_Q(28) & RF1_INSTR_Q(29) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("01111100011111"));
MQQ338:TBL_VAL_STG_GATE_PT(38) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(02) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_INSTR_Q(05) & RF1_INSTR_Q(31) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("1101001"));
MQQ339:TBL_VAL_STG_GATE_PT(39) <=
    Eq(( RF1_AXU_LD_OR_ST_Q & RF1_AXU_MFTGPR & 
    RF1_AXU_MFFGPR & RF1_AXU_MOVEDP & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("10001"));
MQQ340:TBL_VAL_STG_GATE_PT(40) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(05) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("10001"));
MQQ341:TBL_VAL_STG_GATE_PT(41) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_INSTR_Q(04) & RF1_INSTR_Q(05) & 
    RF1_INSTR_Q(30) & RF1_VAL_STG
     ) , STD_ULOGIC_VECTOR'("11111001"));
MQQ342:TBL_VAL_STG_GATE_PT(42) <=
    Eq(( RF1_AXU_MFFGPR & RF1_AXU_MOVEDP & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("111"));
MQQ343:TBL_VAL_STG_GATE_PT(43) <=
    Eq(( RF1_AXU_MFTGPR & RF1_AXU_MOVEDP & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("111"));
MQQ344:TBL_VAL_STG_GATE_PT(44) <=
    Eq(( RF1_AXU_MFTGPR & RF1_AXU_MOVEDP & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("101"));
MQQ345:TBL_VAL_STG_GATE_PT(45) <=
    Eq(( RF1_AXU_MFFGPR & RF1_AXU_MOVEDP & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("101"));
MQQ346:TBL_VAL_STG_GATE_PT(46) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(03) & RF1_INSTR_Q(04) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("10101"));
MQQ347:TBL_VAL_STG_GATE_PT(47) <=
    Eq(( RF1_INSTR_Q(00) & RF1_INSTR_Q(01) & 
    RF1_INSTR_Q(02) & RF1_INSTR_Q(03) & 
    RF1_VAL_STG ) , STD_ULOGIC_VECTOR'("10011"));
-- Table TBL_VAL_STG_GATE Signal Assignments for Outputs
MQQ348:RF1_CACHE_ACC <= 
    (TBL_VAL_STG_GATE_PT(7) OR TBL_VAL_STG_GATE_PT(12)
     OR TBL_VAL_STG_GATE_PT(13) OR TBL_VAL_STG_GATE_PT(19)
     OR TBL_VAL_STG_GATE_PT(20) OR TBL_VAL_STG_GATE_PT(21)
     OR TBL_VAL_STG_GATE_PT(22) OR TBL_VAL_STG_GATE_PT(23)
     OR TBL_VAL_STG_GATE_PT(24) OR TBL_VAL_STG_GATE_PT(25)
     OR TBL_VAL_STG_GATE_PT(26) OR TBL_VAL_STG_GATE_PT(27)
     OR TBL_VAL_STG_GATE_PT(28) OR TBL_VAL_STG_GATE_PT(29)
     OR TBL_VAL_STG_GATE_PT(30) OR TBL_VAL_STG_GATE_PT(31)
     OR TBL_VAL_STG_GATE_PT(32) OR TBL_VAL_STG_GATE_PT(33)
     OR TBL_VAL_STG_GATE_PT(34) OR TBL_VAL_STG_GATE_PT(35)
     OR TBL_VAL_STG_GATE_PT(36) OR TBL_VAL_STG_GATE_PT(37)
     OR TBL_VAL_STG_GATE_PT(38) OR TBL_VAL_STG_GATE_PT(39)
     OR TBL_VAL_STG_GATE_PT(40) OR TBL_VAL_STG_GATE_PT(41)
     OR TBL_VAL_STG_GATE_PT(46) OR TBL_VAL_STG_GATE_PT(47)
    );
MQQ349:XU_LSU_RF1_IS_MSGSND <= 
    (TBL_VAL_STG_GATE_PT(4));
MQQ350:XU_LSU_RF1_MBAR_INSTR <= 
    (TBL_VAL_STG_GATE_PT(5));
MQQ351:XU_LSU_RF1_SYNC_INSTR <= 
    (TBL_VAL_STG_GATE_PT(8));
MQQ352:XU_LSU_RF1_TLBSYNC_INSTR <= 
    (TBL_VAL_STG_GATE_PT(6));
MQQ353:XU_LSU_RF1_WCLR_INSTR <= 
    (TBL_VAL_STG_GATE_PT(7));
MQQ354:XU_LSU_RF1_WCHK_INSTR <= 
    (TBL_VAL_STG_GATE_PT(3));
MQQ355:XU_LSU_RF1_SRC_GPR <= 
    (TBL_VAL_STG_GATE_PT(10) OR TBL_VAL_STG_GATE_PT(45)
    );
MQQ356:XU_LSU_RF1_SRC_AXU <= 
    (TBL_VAL_STG_GATE_PT(43) OR TBL_VAL_STG_GATE_PT(44)
    );
MQQ357:XU_LSU_RF1_SRC_DP <= 
    (TBL_VAL_STG_GATE_PT(11) OR TBL_VAL_STG_GATE_PT(42)
    );
MQQ358:XU_LSU_RF1_TARG_GPR <= 
    (TBL_VAL_STG_GATE_PT(2) OR TBL_VAL_STG_GATE_PT(44)
    );
MQQ359:XU_LSU_RF1_TARG_AXU <= 
    (TBL_VAL_STG_GATE_PT(42) OR TBL_VAL_STG_GATE_PT(45)
    );
MQQ360:XU_LSU_RF1_TARG_DP <= 
    (TBL_VAL_STG_GATE_PT(10) OR TBL_VAL_STG_GATE_PT(43)
    );
MQQ361:RF1_CMD_ACT <= 
    (TBL_VAL_STG_GATE_PT(1) OR TBL_VAL_STG_GATE_PT(4)
     OR TBL_VAL_STG_GATE_PT(5) OR TBL_VAL_STG_GATE_PT(6)
     OR TBL_VAL_STG_GATE_PT(7) OR TBL_VAL_STG_GATE_PT(8)
     OR TBL_VAL_STG_GATE_PT(10) OR TBL_VAL_STG_GATE_PT(11)
     OR TBL_VAL_STG_GATE_PT(12) OR TBL_VAL_STG_GATE_PT(13)
     OR TBL_VAL_STG_GATE_PT(17) OR TBL_VAL_STG_GATE_PT(19)
     OR TBL_VAL_STG_GATE_PT(21) OR TBL_VAL_STG_GATE_PT(23)
     OR TBL_VAL_STG_GATE_PT(24) OR TBL_VAL_STG_GATE_PT(25)
     OR TBL_VAL_STG_GATE_PT(26) OR TBL_VAL_STG_GATE_PT(27)
     OR TBL_VAL_STG_GATE_PT(28) OR TBL_VAL_STG_GATE_PT(29)
     OR TBL_VAL_STG_GATE_PT(30) OR TBL_VAL_STG_GATE_PT(31)
     OR TBL_VAL_STG_GATE_PT(32) OR TBL_VAL_STG_GATE_PT(33)
     OR TBL_VAL_STG_GATE_PT(34) OR TBL_VAL_STG_GATE_PT(35)
     OR TBL_VAL_STG_GATE_PT(36) OR TBL_VAL_STG_GATE_PT(37)
     OR TBL_VAL_STG_GATE_PT(38) OR TBL_VAL_STG_GATE_PT(39)
     OR TBL_VAL_STG_GATE_PT(40) OR TBL_VAL_STG_GATE_PT(41)
     OR TBL_VAL_STG_GATE_PT(42) OR TBL_VAL_STG_GATE_PT(43)
     OR TBL_VAL_STG_GATE_PT(44) OR TBL_VAL_STG_GATE_PT(45)
     OR TBL_VAL_STG_GATE_PT(46) OR TBL_VAL_STG_GATE_PT(47)
    );
MQQ362:XU_LSU_RF1_DATA_ACT <= 
    (TBL_VAL_STG_GATE_PT(9) OR TBL_VAL_STG_GATE_PT(10)
     OR TBL_VAL_STG_GATE_PT(11) OR TBL_VAL_STG_GATE_PT(14)
     OR TBL_VAL_STG_GATE_PT(15) OR TBL_VAL_STG_GATE_PT(16)
     OR TBL_VAL_STG_GATE_PT(18) OR TBL_VAL_STG_GATE_PT(21)
     OR TBL_VAL_STG_GATE_PT(24) OR TBL_VAL_STG_GATE_PT(27)
     OR TBL_VAL_STG_GATE_PT(30) OR TBL_VAL_STG_GATE_PT(31)
     OR TBL_VAL_STG_GATE_PT(32) OR TBL_VAL_STG_GATE_PT(33)
     OR TBL_VAL_STG_GATE_PT(34) OR TBL_VAL_STG_GATE_PT(37)
     OR TBL_VAL_STG_GATE_PT(38) OR TBL_VAL_STG_GATE_PT(39)
     OR TBL_VAL_STG_GATE_PT(40) OR TBL_VAL_STG_GATE_PT(41)
     OR TBL_VAL_STG_GATE_PT(42) OR TBL_VAL_STG_GATE_PT(43)
     OR TBL_VAL_STG_GATE_PT(44) OR TBL_VAL_STG_GATE_PT(45)
     OR TBL_VAL_STG_GATE_PT(46) OR TBL_VAL_STG_GATE_PT(47)
    );
MQQ363:RF1_MTSPR_TRACE <= 
    (TBL_VAL_STG_GATE_PT(1));
MQQ364:RF1_DERAT_ACT <= 
    (TBL_VAL_STG_GATE_PT(12) OR TBL_VAL_STG_GATE_PT(13)
     OR TBL_VAL_STG_GATE_PT(19) OR TBL_VAL_STG_GATE_PT(20)
     OR TBL_VAL_STG_GATE_PT(21) OR TBL_VAL_STG_GATE_PT(22)
     OR TBL_VAL_STG_GATE_PT(23) OR TBL_VAL_STG_GATE_PT(24)
     OR TBL_VAL_STG_GATE_PT(25) OR TBL_VAL_STG_GATE_PT(26)
     OR TBL_VAL_STG_GATE_PT(27) OR TBL_VAL_STG_GATE_PT(28)
     OR TBL_VAL_STG_GATE_PT(29) OR TBL_VAL_STG_GATE_PT(30)
     OR TBL_VAL_STG_GATE_PT(31) OR TBL_VAL_STG_GATE_PT(32)
     OR TBL_VAL_STG_GATE_PT(33) OR TBL_VAL_STG_GATE_PT(34)
     OR TBL_VAL_STG_GATE_PT(35) OR TBL_VAL_STG_GATE_PT(36)
     OR TBL_VAL_STG_GATE_PT(37) OR TBL_VAL_STG_GATE_PT(38)
     OR TBL_VAL_STG_GATE_PT(39) OR TBL_VAL_STG_GATE_PT(40)
     OR TBL_VAL_STG_GATE_PT(41) OR TBL_VAL_STG_GATE_PT(46)
     OR TBL_VAL_STG_GATE_PT(47));

mark_unused(rf1_num_bytes_plus3(6 to 7));
mark_unused(ex1_dp_rot_amt(0));
is1_need_hole_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(is1_need_hole_offset),
               scout   => sov(is1_need_hole_offset),
               din     => is1_need_hole_d,
               dout    => is1_need_hole_q);
is2_need_hole_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(is2_need_hole_offset),
               scout   => sov(is2_need_hole_offset),
               din     => is2_need_hole_d,
               dout    => is2_need_hole_q);
rf0_back_inv_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_slp_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_back_inv_offset),
               scout   => sov(rf0_back_inv_offset),
               din     => lsu_xu_is2_back_inv               ,
               dout    => rf0_back_inv_q);
rf0_back_inv_addr_latch : tri_rlmreg_p
     generic map (width => rf0_back_inv_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => lsu_xu_is2_back_inv  ,
               forcee => func_slp_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_back_inv_addr_offset to rf0_back_inv_addr_offset + rf0_back_inv_addr_q'length-1),
               scout   => sov(rf0_back_inv_addr_offset to rf0_back_inv_addr_offset + rf0_back_inv_addr_q'length-1),
               din     => lsu_xu_is2_back_inv_addr  ,
               dout    => rf0_back_inv_addr_q);
rf0_need_hole_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_need_hole_offset),
               scout   => sov(rf0_need_hole_offset),
               din     => is2_need_hole_q                   ,
               dout    => rf0_need_hole_q);
rf1_3src_instr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_3src_instr            ,
               dout(0) => rf1_3src_instr_q);
rf1_act_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_act_offset),
               scout   => sov(rf1_act_offset),
               din     => rf0_act,
               dout    => rf1_act_q);
rf1_axu_instr_type_latch : tri_regk
     generic map (width => rf1_axu_instr_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_axu_instr_type        ,
               dout    => rf1_axu_instr_type_q);
rf1_axu_is_extload_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_axu_is_extload        ,
               dout(0) => rf1_axu_is_extload_q);
rf1_axu_is_extstore_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_axu_is_extstore       ,
               dout(0) => rf1_axu_is_extstore_q);
rf1_axu_ld_or_st_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_axu_ld_or_st_offset),
               scout   => sov(rf1_axu_ld_or_st_offset),
               din     => fxa_fxb_rf0_axu_ld_or_st          ,
               dout    => rf1_axu_ld_or_st_q);
rf1_axu_ldst_forcealign_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_axu_ldst_forcealign   ,
               dout(0) => rf1_axu_ldst_forcealign_q);
rf1_axu_ldst_forceexcept_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_axu_ldst_forceexcept  ,
               dout(0) => rf1_axu_ldst_forceexcept_q);
rf1_axu_ldst_indexed_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_axu_ldst_indexed      ,
               dout(0) => rf1_axu_ldst_indexed_q);
rf1_axu_ldst_size_latch : tri_regk
     generic map (width => rf1_axu_ldst_size_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_axu_ldst_size         ,
               dout    => rf1_axu_ldst_size_q);
rf1_axu_ldst_tag_latch : tri_regk
     generic map (width => rf1_axu_ldst_tag_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_axu_ldst_tag          ,
               dout    => rf1_axu_ldst_tag_q);
rf1_axu_ldst_update_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_axu_ldst_update       ,
               dout(0) => rf1_axu_ldst_update_q);
rf1_axu_mffgpr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_axu_mffgpr            ,
               dout(0) => rf1_axu_mffgpr_q);
rf1_axu_mftgpr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_axu_mftgpr            ,
               dout(0) => rf1_axu_mftgpr_q);
rf1_axu_movedp_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_axu_movedp            ,
               dout(0) => rf1_axu_movedp_q);
rf1_axu_store_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_axu_store             ,
               dout(0) => rf1_axu_store_q);
rf1_back_inv_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_slp_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_back_inv_offset),
               scout   => sov(rf1_back_inv_offset),
               din     => rf0_back_inv_q                    ,
               dout    => rf1_back_inv_q);
rf1_back_inv_addr_latch : tri_regk
     generic map (width => rf1_back_inv_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_back_inv_q       ,
               forcee => func_slp_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_nsl_thold_0_b,
               din     => rf0_back_inv_addr_q       ,
               dout    => rf1_back_inv_addr_q);
rf1_error_latch : tri_regk
     generic map (width => rf1_error_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_error                 ,
               dout    => rf1_error_q);
rf1_gpr0_zero_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_gpr0_zero             ,
               dout(0) => rf1_gpr0_zero_q);
rf1_gshare_latch : tri_regk
     generic map (width => rf1_gshare_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_gshare                ,
               dout    => rf1_gshare_q);
rf1_ifar_latch : tri_regk
     generic map (width => rf1_ifar_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_ifar                  ,
               dout    => rf1_ifar_q);
rf1_instr_latch : tri_regk
     generic map (width => rf1_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_instr                 ,
               dout    => rf1_instr_q);
rf1_instr_21to30_00_latch : tri_regk
     generic map (width => rf1_instr_21to30_00_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_00_d,
               dout    => rf1_instr_21to30_00_q);
rf1_instr_21to30_01_latch : tri_regk
     generic map (width => rf1_instr_21to30_01_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_01_d,
               dout    => rf1_instr_21to30_01_q);
rf1_instr_21to30_02_latch : tri_regk
     generic map (width => rf1_instr_21to30_02_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_02_d,
               dout    => rf1_instr_21to30_02_q);
rf1_instr_21to30_03_latch : tri_regk
     generic map (width => rf1_instr_21to30_03_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_03_d,
               dout    => rf1_instr_21to30_03_q);
rf1_instr_21to30_04_latch : tri_regk
     generic map (width => rf1_instr_21to30_04_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_04_d,
               dout    => rf1_instr_21to30_04_q);
rf1_instr_21to30_05_latch : tri_regk
     generic map (width => rf1_instr_21to30_05_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_05_d,
               dout    => rf1_instr_21to30_05_q);
rf1_instr_21to30_06_latch : tri_regk
     generic map (width => rf1_instr_21to30_06_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_06_d,
               dout    => rf1_instr_21to30_06_q);
rf1_instr_21to30_07_latch : tri_regk
     generic map (width => rf1_instr_21to30_07_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_07_d,
               dout    => rf1_instr_21to30_07_q);
rf1_instr_21to30_08_latch : tri_regk
     generic map (width => rf1_instr_21to30_08_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_08_d,
               dout    => rf1_instr_21to30_08_q);
rf1_instr_21to30_09_latch : tri_regk
     generic map (width => rf1_instr_21to30_09_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_09_d,
               dout    => rf1_instr_21to30_09_q);
rf1_instr_21to30_10_latch : tri_regk
     generic map (width => rf1_instr_21to30_10_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_instr_21to30_10_d,
               dout    => rf1_instr_21to30_10_q);
rf1_is_isel_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => rf1_is_isel_d,
               dout(0) => rf1_is_isel_q);
rf1_is_ucode_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_is_ucode              ,
               dout(0) => rf1_is_ucode_q);
rf1_issued_latch : tri_regk
     generic map (width => rf1_issued_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_issued                ,
               dout    => rf1_issued_q);
rf1_match_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_match                 ,
               dout(0) => rf1_match_q);
rf1_mc_dep_chk_val_latch : tri_regk
     generic map (width => rf1_mc_dep_chk_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_mc_dep_chk_val_d,
               dout    => rf1_mc_dep_chk_val_q);
rf1_need_hole_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_need_hole_offset),
               scout   => sov(rf1_need_hole_offset),
               din     => rf0_need_hole_q                   ,
               dout    => rf1_need_hole_q);
rf1_opcode_is_31_latch : tri_regk
     generic map (width => rf1_opcode_is_31_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => rf1_opcode_is_31_d,
               dout    => rf1_opcode_is_31_q);
rf1_pred_taken_cnt_latch : tri_regk
     generic map (width => rf1_pred_taken_cnt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_pred_taken_cnt        ,
               dout    => rf1_pred_taken_cnt_q);
rf1_pred_update_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_pred_update           ,
               dout(0) => rf1_pred_update_q);
rf1_s1_latch : tri_regk
     generic map (width => rf1_s1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_s1                    ,
               dout    => rf1_s1_q);
rf1_s1_vld_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_s1_vld                ,
               dout(0) => rf1_s1_vld_q);
rf1_s2_latch : tri_regk
     generic map (width => rf1_s2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_s2                    ,
               dout    => rf1_s2_q);
rf1_s2_vld_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_s2_vld                ,
               dout(0) => rf1_s2_vld_q);
rf1_s3_latch : tri_regk
     generic map (width => rf1_s3_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_s3                    ,
               dout    => rf1_s3_q);
rf1_s3_vld_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_s3_vld                ,
               dout(0) => rf1_s3_vld_q);
rf1_ta_latch : tri_regk
     generic map (width => rf1_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_ta                    ,
               dout    => rf1_ta_q);
rf1_ta_vld_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_ta_vld_offset),
               scout   => sov(rf1_ta_vld_offset),
               din     => fxa_fxb_rf0_ta_vld                ,
               dout    => rf1_ta_vld_q);
rf1_tid_latch : tri_regk
     generic map (width => rf1_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_tid                   ,
               dout    => rf1_tid_q);
rf1_tid_2_latch : tri_regk
     generic map (width => rf1_tid_2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => fxa_fxb_rf0_tid                   ,
               dout    => rf1_tid_2_q);
rf1_ucode_val_latch : tri_rlmreg_p
     generic map (width => rf1_ucode_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_ucode_val_offset to rf1_ucode_val_offset + rf1_ucode_val_q'length-1),
               scout   => sov(rf1_ucode_val_offset to rf1_ucode_val_offset + rf1_ucode_val_q'length-1),
               din     => fxa_fxb_rf0_ucode_val             ,
               dout    => rf1_ucode_val_q);
rf1_use_imm_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_use_imm               ,
               dout(0) => rf1_use_imm_q);
rf1_val_latch : tri_rlmreg_p
     generic map (width => rf1_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_val_offset to rf1_val_offset + rf1_val_q'length-1),
               scout   => sov(rf1_val_offset to rf1_val_offset + rf1_val_q'length-1),
               din     => fxa_fxb_rf0_val                   ,
               dout    => rf1_val_q);
rf1_val_iu_latch : tri_rlmreg_p
     generic map (width => rf1_val_iu_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_val_iu_offset to rf1_val_iu_offset + rf1_val_iu_q'length-1),
               scout   => sov(rf1_val_iu_offset to rf1_val_iu_offset + rf1_val_iu_q'length-1),
               din     => fxa_fxb_rf0_val                   ,
               dout    => rf1_val_iu_q);
rf1_xu_epid_instr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_act              ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => fxa_fxb_rf0_xu_epid_instr         ,
               dout(0) => rf1_xu_epid_instr_q);
ex1_act_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_act_offset),
               scout   => sov(ex1_act_offset),
               din     => ex1_act_d,
               dout    => ex1_act_q);
ex1_axu_instr_type_latch : tri_rlmreg_p
     generic map (width => ex1_axu_instr_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_axu_instr_type_offset to ex1_axu_instr_type_offset + ex1_axu_instr_type_q'length-1),
               scout   => sov(ex1_axu_instr_type_offset to ex1_axu_instr_type_offset + ex1_axu_instr_type_q'length-1),
               din     => ex1_axu_instr_type_d,
               dout    => ex1_axu_instr_type_q);
ex1_axu_movedp_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_axu_movedp_offset),
               scout   => sov(ex1_axu_movedp_offset),
               din     => rf1_axu_movedp_q                  ,
               dout    => ex1_axu_movedp_q);
ex1_back_inv_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_slp_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_back_inv_offset),
               scout   => sov(ex1_back_inv_offset),
               din     => rf1_back_inv_q                    ,
               dout    => ex1_back_inv_q);
ex1_bh_latch : tri_rlmreg_p
     generic map (width => ex1_bh_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_bh_offset to ex1_bh_offset + ex1_bh_q'length-1),
               scout   => sov(ex1_bh_offset to ex1_bh_offset + ex1_bh_q'length-1),
               din     => rf1_bh                            ,
               dout    => ex1_bh_q);
ex1_clear_barrier_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_clear_barrier_offset),
               scout   => sov(ex1_clear_barrier_offset),
               din     => rf1_clear_barrier                 ,
               dout    => ex1_clear_barrier_q);
ex1_ddmh_en_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_ddmh_en_offset),
               scout   => sov(ex1_ddmh_en_offset),
               din     => ex1_ddmh_en_d,
               dout    => ex1_ddmh_en_q);
ex1_ditc_illeg_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_ditc_illeg_offset),
               scout   => sov(ex1_ditc_illeg_offset),
               din     => ex1_ditc_illeg_d,
               dout    => ex1_ditc_illeg_q);
ex1_dp_indexed_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_dp_indexed_offset),
               scout   => sov(ex1_dp_indexed_offset),
               din     => ex1_dp_indexed_d,
               dout    => ex1_dp_indexed_q);
ex1_epid_instr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_epid_instr_offset),
               scout   => sov(ex1_epid_instr_offset),
               din     => ex1_epid_instr_d,
               dout    => ex1_epid_instr_q);
ex1_error_latch : tri_rlmreg_p
     generic map (width => ex1_error_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_error_offset to ex1_error_offset + ex1_error_q'length-1),
               scout   => sov(ex1_error_offset to ex1_error_offset + ex1_error_q'length-1),
               din     => rf1_error_q                       ,
               dout    => ex1_error_q);
ex1_getNIA_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_getNIA_offset),
               scout   => sov(ex1_getNIA_offset),
               din     => rf1_getNIA                        ,
               dout    => ex1_getNIA_q);
ex1_gpr_we_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_gpr_we_offset),
               scout   => sov(ex1_gpr_we_offset),
               din     => ex1_gpr_we_d,
               dout    => ex1_gpr_we_q);
ex1_gshare_latch : tri_rlmreg_p
     generic map (width => ex1_gshare_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_gshare_offset to ex1_gshare_offset + ex1_gshare_q'length-1),
               scout   => sov(ex1_gshare_offset to ex1_gshare_offset + ex1_gshare_q'length-1),
               din     => rf1_gshare_q                      ,
               dout    => ex1_gshare_q);
ex1_instr_latch : tri_rlmreg_p
     generic map (width => ex1_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_instr_offset to ex1_instr_offset + ex1_instr_q'length-1),
               scout   => sov(ex1_instr_offset to ex1_instr_offset + ex1_instr_q'length-1),
               din     => rf1_instr_q(11 to 25),
               dout    => ex1_instr_q);
ex1_instr_hypv_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_instr_hypv_offset),
               scout   => sov(ex1_instr_hypv_offset),
               din     => rf1_instr_hypv                    ,
               dout    => ex1_instr_hypv_q);
ex1_instr_priv_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_instr_priv_offset),
               scout   => sov(ex1_instr_priv_offset),
               din     => rf1_instr_priv                    ,
               dout    => ex1_instr_priv_q);
ex1_is_any_load_dac_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_any_load_dac_offset),
               scout   => sov(ex1_is_any_load_dac_offset),
               din     => rf1_is_any_load_dac               ,
               dout    => ex1_is_any_load_dac_q);
ex1_is_any_store_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_any_store_offset),
               scout   => sov(ex1_is_any_store_offset),
               din     => rf1_is_any_store                  ,
               dout    => ex1_is_any_store_q);
ex1_is_any_store_dac_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_any_store_dac_offset),
               scout   => sov(ex1_is_any_store_dac_offset),
               din     => rf1_is_any_store_dac              ,
               dout    => ex1_is_any_store_dac_q);
ex1_is_attn_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_attn_offset),
               scout   => sov(ex1_is_attn_offset),
               din     => rf1_is_attn                       ,
               dout    => ex1_is_attn_q);
ex1_is_bclr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_bclr_offset),
               scout   => sov(ex1_is_bclr_offset),
               din     => rf1_is_bclr                       ,
               dout    => ex1_is_bclr_q);
ex1_is_cmp_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_cmp_offset),
               scout   => sov(ex1_is_cmp_offset),
               din     => rf1_cmp                           ,
               dout    => ex1_is_cmp_q);
ex1_is_csync_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_csync_offset),
               scout   => sov(ex1_is_csync_offset),
               din     => rf1_is_csync,
               dout    => ex1_is_csync_q);
ex1_is_eratsxr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_eratsxr_offset),
               scout   => sov(ex1_is_eratsxr_offset),
               din     => rf1_is_eratsxr                    ,
               dout    => ex1_is_eratsxr_q);
ex1_is_icswx_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_icswx_offset),
               scout   => sov(ex1_is_icswx_offset),
               din     => ex1_is_icswx_d,
               dout    => ex1_is_icswx_q);
ex1_is_isync_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_isync_offset),
               scout   => sov(ex1_is_isync_offset),
               din     => rf1_is_isync                      ,
               dout    => ex1_is_isync_q);
ex1_is_ld_w_update_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_ld_w_update_offset),
               scout   => sov(ex1_is_ld_w_update_offset),
               din     => rf1_is_ld_w_update                ,
               dout    => ex1_is_ld_w_update_q);
ex1_is_lmw_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_lmw_offset),
               scout   => sov(ex1_is_lmw_offset),
               din     => rf1_is_lmw                        ,
               dout    => ex1_is_lmw_q);
ex1_is_lswi_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_lswi_offset),
               scout   => sov(ex1_is_lswi_offset),
               din     => rf1_is_lswi                       ,
               dout    => ex1_is_lswi_q);
ex1_is_lswx_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_lswx_offset),
               scout   => sov(ex1_is_lswx_offset),
               din     => rf1_is_lswx                       ,
               dout    => ex1_is_lswx_q);
ex1_is_mfcr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_mfcr_offset),
               scout   => sov(ex1_is_mfcr_offset),
               din     => rf1_is_mfcr                       ,
               dout    => ex1_is_mfcr_q);
ex1_is_mfspr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_mfspr_offset),
               scout   => sov(ex1_is_mfspr_offset),
               din     => rf1_is_mfspr                      ,
               dout    => ex1_is_mfspr_q);
ex1_is_msgclr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_msgclr_offset),
               scout   => sov(ex1_is_msgclr_offset),
               din     => rf1_is_msgclr                     ,
               dout    => ex1_is_msgclr_q);
ex1_is_msgsnd_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_msgsnd_offset),
               scout   => sov(ex1_is_msgsnd_offset),
               din     => rf1_is_msgsnd                     ,
               dout    => ex1_is_msgsnd_q);
ex1_is_mtspr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_mtspr_offset),
               scout   => sov(ex1_is_mtspr_offset),
               din     => rf1_is_mtspr                      ,
               dout    => ex1_is_mtspr_q);
ex1_is_sc_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_sc_offset),
               scout   => sov(ex1_is_sc_offset),
               din     => rf1_is_sc                         ,
               dout    => ex1_is_sc_q);
ex1_is_st_w_update_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_st_w_update_offset),
               scout   => sov(ex1_is_st_w_update_offset),
               din     => rf1_is_st_w_update                ,
               dout    => ex1_is_st_w_update_q);
ex1_is_ucode_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_ucode_offset),
               scout   => sov(ex1_is_ucode_offset),
               din     => rf1_is_ucode_q                    ,
               dout    => ex1_is_ucode_q);
ex1_is_wchkall_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_is_wchkall_offset),
               scout   => sov(ex1_is_wchkall_offset),
               din     => rf1_is_wchkall                    ,
               dout    => ex1_is_wchkall_q);
ex1_lk_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_lk_offset),
               scout   => sov(ex1_lk_offset),
               din     => rf1_lk                            ,
               dout    => ex1_lk_q);
ex1_match_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_match_offset),
               scout   => sov(ex1_match_offset),
               din     => rf1_match_q                       ,
               dout    => ex1_match_q);
ex1_mfdcr_instr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_mfdcr_instr_offset),
               scout   => sov(ex1_mfdcr_instr_offset),
               din     => rf1_mfdcr_instr,
               dout    => ex1_mfdcr_instr_q);
ex1_mfdp_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_mfdp_val_offset),
               scout   => sov(ex1_mfdp_val_offset),
               din     => ex1_mfdp_val_d,
               dout    => ex1_mfdp_val_q);
ex1_mtdcr_instr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_mtdcr_instr_offset),
               scout   => sov(ex1_mtdcr_instr_offset),
               din     => rf1_mtdcr_instr,
               dout    => ex1_mtdcr_instr_q);
ex1_mtdp_nr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_mtdp_nr_offset),
               scout   => sov(ex1_mtdp_nr_offset),
               din     => ex1_mtdp_nr_d,
               dout    => ex1_mtdp_nr_q);
ex1_mtdp_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_mtdp_val_offset),
               scout   => sov(ex1_mtdp_val_offset),
               din     => ex1_mtdp_val_d,
               dout    => ex1_mtdp_val_q);
ex1_muldiv_coll_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_muldiv_coll_offset),
               scout   => sov(ex1_muldiv_coll_offset),
               din     => fxa_fxb_rf1_muldiv_coll           ,
               dout    => ex1_muldiv_coll_q);
ex1_need_hole_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_need_hole_offset),
               scout   => sov(ex1_need_hole_offset),
               din     => rf1_need_hole_q                   ,
               dout    => ex1_need_hole_q);
ex1_num_regs_latch : tri_rlmreg_p
     generic map (width => ex1_num_regs_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_num_regs_offset to ex1_num_regs_offset + ex1_num_regs_q'length-1),
               scout   => sov(ex1_num_regs_offset to ex1_num_regs_offset + ex1_num_regs_q'length-1),
               din     => ex1_num_regs_d,
               dout    => ex1_num_regs_q);
ex1_ovr_rotsel_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_ovr_rotsel_offset),
               scout   => sov(ex1_ovr_rotsel_offset),
               din     => ex1_ovr_rotsel_d,
               dout    => ex1_ovr_rotsel_q);
ex1_pred_taken_cnt_latch : tri_rlmreg_p
     generic map (width => ex1_pred_taken_cnt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_pred_taken_cnt_offset to ex1_pred_taken_cnt_offset + ex1_pred_taken_cnt_q'length-1),
               scout   => sov(ex1_pred_taken_cnt_offset to ex1_pred_taken_cnt_offset + ex1_pred_taken_cnt_q'length-1),
               din     => rf1_pred_taken_cnt_q              ,
               dout    => ex1_pred_taken_cnt_q);
ex1_pred_update_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_pred_update_offset),
               scout   => sov(ex1_pred_update_offset),
               din     => rf1_pred_update_q                 ,
               dout    => ex1_pred_update_q);
ex1_pri_latch : tri_rlmreg_p
     generic map (width => ex1_pri_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_pri_offset to ex1_pri_offset + ex1_pri_q'length-1),
               scout   => sov(ex1_pri_offset to ex1_pri_offset + ex1_pri_q'length-1),
               din     => rf1_pri                           ,
               dout    => ex1_pri_q);
ex1_rotsel_ovrd_latch : tri_rlmreg_p
     generic map (width => ex1_rotsel_ovrd_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_rotsel_ovrd_offset to ex1_rotsel_ovrd_offset + ex1_rotsel_ovrd_q'length-1),
               scout   => sov(ex1_rotsel_ovrd_offset to ex1_rotsel_ovrd_offset + ex1_rotsel_ovrd_q'length-1),
               din     => ex1_rotsel_ovrd_d,
               dout    => ex1_rotsel_ovrd_q);
ex1_s1_latch : tri_rlmreg_p
     generic map (width => ex1_s1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_s1_offset to ex1_s1_offset + ex1_s1_q'length-1),
               scout   => sov(ex1_s1_offset to ex1_s1_offset + ex1_s1_q'length-1),
               din     => rf1_s1_q                          ,
               dout    => ex1_s1_q);
ex1_s2_latch : tri_rlmreg_p
     generic map (width => ex1_s2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_s2_offset to ex1_s2_offset + ex1_s2_q'length-1),
               scout   => sov(ex1_s2_offset to ex1_s2_offset + ex1_s2_q'length-1),
               din     => rf1_s2_q                          ,
               dout    => ex1_s2_q);
ex1_s3_latch : tri_rlmreg_p
     generic map (width => ex1_s3_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_s3_offset to ex1_s3_offset + ex1_s3_q'length-1),
               scout   => sov(ex1_s3_offset to ex1_s3_offset + ex1_s3_q'length-1),
               din     => rf1_s3_q                          ,
               dout    => ex1_s3_q);
ex1_spr_sel_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_spr_sel_offset),
               scout   => sov(ex1_spr_sel_offset),
               din     => rf1_spr_sel                       ,
               dout    => ex1_spr_sel_q);
ex1_ta_latch : tri_rlmreg_p
     generic map (width => ex1_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_ta_offset to ex1_ta_offset + ex1_ta_q'length-1),
               scout   => sov(ex1_ta_offset to ex1_ta_offset + ex1_ta_q'length-1),
               din     => rf1_ta_q                          ,
               dout    => ex1_ta_q);
ex1_tid_latch : tri_rlmreg_p
     generic map (width => ex1_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_tid_offset to ex1_tid_offset + ex1_tid_q'length-1),
               scout   => sov(ex1_tid_offset to ex1_tid_offset + ex1_tid_q'length-1),
               din     => rf1_tid_q                         ,
               dout    => ex1_tid_q);
ex1_tlb_data_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_tlb_data_val_offset),
               scout   => sov(ex1_tlb_data_val_offset),
               din     => ex1_tlb_data_val_d,
               dout    => ex1_tlb_data_val_q);
ex1_tlb_illeg_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf1_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_tlb_illeg_offset),
               scout   => sov(ex1_tlb_illeg_offset),
               din     => ex1_tlb_illeg_d,
               dout    => ex1_tlb_illeg_q);
ex1_trace_type_latch : tri_rlmreg_p
     generic map (width => ex1_trace_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable_q   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_trace_type_offset to ex1_trace_type_offset + ex1_trace_type_q'length-1),
               scout   => sov(ex1_trace_type_offset to ex1_trace_type_offset + ex1_trace_type_q'length-1),
               din     => rf1_trace_type,
               dout    => ex1_trace_type_q);
ex1_trace_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable_q   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_trace_val_offset),
               scout   => sov(ex1_trace_val_offset),
               din     => rf1_trace_val,
               dout    => ex1_trace_val_q);
ex1_val_latch : tri_rlmreg_p
     generic map (width => ex1_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_val_offset to ex1_val_offset + ex1_val_q'length-1),
               scout   => sov(ex1_val_offset to ex1_val_offset + ex1_val_q'length-1),
               din     => ex1_val_d,
               dout    => ex1_val_q);
ex1_axu_ld_or_st_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_axu_ld_or_st_offset),
               scout   => sov(ex1_axu_ld_or_st_offset),
               din     => rf1_axu_ld_or_st_q,
               dout    => ex1_axu_ld_or_st_q);
ex2_act_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_act_offset),
               scout   => sov(ex2_act_offset),
               din     => ex2_act_d,
               dout    => ex2_act_q);
ex2_axu_instr_type_latch : tri_regk
     generic map (width => ex2_axu_instr_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex1_axu_instr_type_q              ,
               dout    => ex2_axu_instr_type_q);
ex2_back_inv_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_slp_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_back_inv_offset),
               scout   => sov(ex2_back_inv_offset),
               din     => ex1_back_inv_q                    ,
               dout    => ex2_back_inv_q);
ex2_bh_latch : tri_regk
     generic map (width => ex2_bh_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex1_bh_q                          ,
               dout    => ex2_bh_q);
ex2_clear_barrier_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_clear_barrier_offset),
               scout   => sov(ex2_clear_barrier_offset),
               din     => ex1_clear_barrier_q               ,
               dout    => ex2_clear_barrier_q);
ex2_ddmh_en_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_ddmh_en_q                     ,
               dout(0) => ex2_ddmh_en_q);
ex2_ditc_illeg_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex2_ditc_illeg_d,
               dout(0) => ex2_ditc_illeg_q);
ex2_error_latch : tri_regk
     generic map (width => ex2_error_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex1_error_q                       ,
               dout    => ex2_error_q);
ex2_getNIA_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_getNIA_q                      ,
               dout(0) => ex2_getNIA_q);
ex2_gpr_we_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_gpr_we_offset),
               scout   => sov(ex2_gpr_we_offset),
               din     => ex2_gpr_we_d,
               dout    => ex2_gpr_we_q);
ex2_gshare_latch : tri_regk
     generic map (width => ex2_gshare_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex1_gshare_q                      ,
               dout    => ex2_gshare_q);
ex2_instr_latch : tri_regk
     generic map (width => ex2_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex1_instr_q(12 to 25),
               dout    => ex2_instr_q);
ex2_instr_hypv_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_instr_hypv_q                  ,
               dout(0) => ex2_instr_hypv_q);
ex2_instr_priv_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_instr_priv_q                  ,
               dout(0) => ex2_instr_priv_q);
ex2_ipb_ba_latch : tri_rlmreg_p
     generic map (width => ex2_ipb_ba_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_ipb_ba_offset to ex2_ipb_ba_offset + ex2_ipb_ba_q'length-1),
               scout   => sov(ex2_ipb_ba_offset to ex2_ipb_ba_offset + ex2_ipb_ba_q'length-1),
               din     => ex2_ipb_ba_d,
               dout    => ex2_ipb_ba_q);
ex2_ipb_sz_latch : tri_rlmreg_p
     generic map (width => ex2_ipb_sz_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_ipb_sz_offset to ex2_ipb_sz_offset + ex2_ipb_sz_q'length-1),
               scout   => sov(ex2_ipb_sz_offset to ex2_ipb_sz_offset + ex2_ipb_sz_q'length-1),
               din     => ex2_ipb_sz_d,
               dout    => ex2_ipb_sz_q);
ex2_is_any_load_dac_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_any_load_dac_q             ,
               dout(0) => ex2_is_any_load_dac_q);
ex2_is_any_store_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_any_store_q                ,
               dout(0) => ex2_is_any_store_q);
ex2_is_any_store_dac_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_any_store_dac_q            ,
               dout(0) => ex2_is_any_store_dac_q);
ex2_is_attn_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_attn_q                     ,
               dout(0) => ex2_is_attn_q);
ex2_is_bclr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_bclr_q                     ,
               dout(0) => ex2_is_bclr_q);
ex2_is_eratsxr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_eratsxr_q                  ,
               dout(0) => ex2_is_eratsxr_q);
ex2_is_icswx_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_icswx_q                    ,
               dout(0) => ex2_is_icswx_q);
ex2_is_ld_w_update_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_ld_w_update_q              ,
               dout(0) => ex2_is_ld_w_update_q);
ex2_is_lmw_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_lmw_q                      ,
               dout(0) => ex2_is_lmw_q);
ex2_is_lswi_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_lswi_q                     ,
               dout(0) => ex2_is_lswi_q);
ex2_is_lswx_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_lswx_q                     ,
               dout(0) => ex2_is_lswx_q);
ex2_is_mfcr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_mfcr_q                     ,
               dout(0) => ex2_is_mfcr_q);
ex2_is_msgclr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_msgclr_q                   ,
               dout(0) => ex2_is_msgclr_q);
ex2_is_msgsnd_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_msgsnd_q                   ,
               dout(0) => ex2_is_msgsnd_q);
ex2_is_sc_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_sc_q                       ,
               dout(0) => ex2_is_sc_q);
ex2_is_st_w_update_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_st_w_update_q              ,
               dout(0) => ex2_is_st_w_update_q);
ex2_is_ucode_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_is_ucode_offset),
               scout   => sov(ex2_is_ucode_offset),
               din     => ex1_is_ucode_q                    ,
               dout    => ex2_is_ucode_q);
ex2_is_wchkall_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_is_wchkall_q                  ,
               dout(0) => ex2_is_wchkall_q);
ex2_lk_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_lk_q                          ,
               dout(0) => ex2_lk_q);
ex2_match_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_match_q                       ,
               dout(0) => ex2_match_q);
ex2_mfdp_val_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_mfdp_val_q                    ,
               dout(0) => ex2_mfdp_val_q);
ex2_mtdp_nr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_mtdp_nr_q                     ,
               dout(0) => ex2_mtdp_nr_q);
ex2_mtdp_val_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_mtdp_val_q                    ,
               dout(0) => ex2_mtdp_val_q);
ex2_muldiv_coll_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_muldiv_coll_offset),
               scout   => sov(ex2_muldiv_coll_offset),
               din     => ex1_muldiv_coll_q                 ,
               dout    => ex2_muldiv_coll_q);
ex2_need_hole_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_need_hole_offset),
               scout   => sov(ex2_need_hole_offset),
               din     => ex1_need_hole_q                   ,
               dout    => ex2_need_hole_q);
ex2_pred_taken_cnt_latch : tri_regk
     generic map (width => ex2_pred_taken_cnt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex1_pred_taken_cnt_q              ,
               dout    => ex2_pred_taken_cnt_q);
ex2_pred_update_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_pred_update_q                 ,
               dout(0) => ex2_pred_update_q);
ex2_pri_latch : tri_regk
     generic map (width => ex2_pri_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex1_pri_q                         ,
               dout    => ex2_pri_q);
ex2_ra_eq_rt_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex2_ra_eq_rt_d,
               dout(0) => ex2_ra_eq_rt_q);
ex2_ra_eq_zero_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex2_ra_eq_zero_d,
               dout(0) => ex2_ra_eq_zero_q);
ex2_ra_in_rng_lmw_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex2_ra_in_rng_lmw_d,
               dout(0) => ex2_ra_in_rng_lmw_q);
ex2_ra_in_rng_nowrap_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex2_ra_in_rng_nowrap_d,
               dout(0) => ex2_ra_in_rng_nowrap_q);
ex2_ra_in_rng_wrap_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex2_ra_in_rng_wrap_d,
               dout(0) => ex2_ra_in_rng_wrap_q);
ex2_range_wrap_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex2_range_wrap_d,
               dout(0) => ex2_range_wrap_q);
ex2_rb_eq_rt_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex2_rb_eq_rt_d,
               dout(0) => ex2_rb_eq_rt_q);
ex2_rb_in_rng_nowrap_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex2_rb_in_rng_nowrap_d,
               dout(0) => ex2_rb_in_rng_nowrap_q);
ex2_rb_in_rng_wrap_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex2_rb_in_rng_wrap_d,
               dout(0) => ex2_rb_in_rng_wrap_q);
ex2_slowspr_dcr_rd_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_slowspr_dcr_rd,
               dout(0) => ex2_slowspr_dcr_rd_q);
ex2_ta_latch : tri_regk
     generic map (width => ex2_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex1_ta_q                          ,
               dout    => ex2_ta_q);
ex2_tid_latch : tri_regk
     generic map (width => ex2_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex1_tid_q                         ,
               dout    => ex2_tid_q);
ex2_tlb_data_val_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_tlb_data_val_q                ,
               dout(0) => ex2_tlb_data_val_q);
ex2_tlb_illeg_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_tlb_illeg_q                   ,
               dout(0) => ex2_tlb_illeg_q);
ex2_trace_type_latch : tri_regk
     generic map (width => ex2_trace_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable_q   ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex1_trace_type_q                  ,
               dout    => ex2_trace_type_q);
ex2_trace_val_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable_q   ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex1_trace_val_q                   ,
               dout(0) => ex2_trace_val_q);
ex2_val_latch : tri_rlmreg_p
     generic map (width => ex2_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_val_offset to ex2_val_offset + ex2_val_q'length-1),
               scout   => sov(ex2_val_offset to ex2_val_offset + ex2_val_q'length-1),
               din     => ex2_val_d,
               dout    => ex2_val_q);
ex3_act_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_act_offset),
               scout   => sov(ex3_act_offset),
               din     => ex3_act_d,
               dout    => ex3_act_q);
ex3_axu_instr_type_latch : tri_rlmreg_p
     generic map (width => ex3_axu_instr_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_axu_instr_type_offset to ex3_axu_instr_type_offset + ex3_axu_instr_type_q'length-1),
               scout   => sov(ex3_axu_instr_type_offset to ex3_axu_instr_type_offset + ex3_axu_instr_type_q'length-1),
               din     => ex2_axu_instr_type_q              ,
               dout    => ex3_axu_instr_type_q);
ex3_back_inv_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_slp_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_back_inv_offset),
               scout   => sov(ex3_back_inv_offset),
               din     => ex2_back_inv_q                    ,
               dout    => ex3_back_inv_q);
ex3_bh_latch : tri_rlmreg_p
     generic map (width => ex3_bh_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_bh_offset to ex3_bh_offset + ex3_bh_q'length-1),
               scout   => sov(ex3_bh_offset to ex3_bh_offset + ex3_bh_q'length-1),
               din     => ex2_bh_q                          ,
               dout    => ex3_bh_q);
ex3_clear_barrier_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_clear_barrier_offset),
               scout   => sov(ex3_clear_barrier_offset),
               din     => ex2_clear_barrier_q               ,
               dout    => ex3_clear_barrier_q);
ex3_ddmh_en_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_ddmh_en_offset),
               scout   => sov(ex3_ddmh_en_offset),
               din     => ex2_ddmh_en_q                     ,
               dout    => ex3_ddmh_en_q);
ex3_div_done_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_div_done_offset),
               scout   => sov(ex3_div_done_offset),
               din     => alu_ex2_div_done                  ,
               dout    => ex3_div_done_q);
ex3_getNIA_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_getNIA_offset),
               scout   => sov(ex3_getNIA_offset),
               din     => ex2_getNIA_q                      ,
               dout    => ex3_getNIA_q);
ex3_gpr_we_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_gpr_we_offset),
               scout   => sov(ex3_gpr_we_offset),
               din     => ex2_gpr_we_q                      ,
               dout    => ex3_gpr_we_q);
ex3_gshare_latch : tri_rlmreg_p
     generic map (width => ex3_gshare_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_gshare_offset to ex3_gshare_offset + ex3_gshare_q'length-1),
               scout   => sov(ex3_gshare_offset to ex3_gshare_offset + ex3_gshare_q'length-1),
               din     => ex2_gshare_q                      ,
               dout    => ex3_gshare_q);
ex3_instr_latch : tri_rlmreg_p
     generic map (width => ex3_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_instr_offset to ex3_instr_offset + ex3_instr_q'length-1),
               scout   => sov(ex3_instr_offset to ex3_instr_offset + ex3_instr_q'length-1),
               din     => ex2_instr_q(12 to 19),
               dout    => ex3_instr_q);
ex3_instr_hypv_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_instr_hypv_offset),
               scout   => sov(ex3_instr_hypv_offset),
               din     => ex2_instr_hypv_q                  ,
               dout    => ex3_instr_hypv_q);
ex3_instr_priv_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_instr_priv_offset),
               scout   => sov(ex3_instr_priv_offset),
               din     => ex2_instr_priv_q                  ,
               dout    => ex3_instr_priv_q);
ex3_is_any_store_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_is_any_store_offset),
               scout   => sov(ex3_is_any_store_offset),
               din     => ex2_is_any_store_q                ,
               dout    => ex3_is_any_store_q);
ex3_is_bclr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_is_bclr_offset),
               scout   => sov(ex3_is_bclr_offset),
               din     => ex2_is_bclr_q                     ,
               dout    => ex3_is_bclr_q);
ex3_is_eratsxr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_is_eratsxr_offset),
               scout   => sov(ex3_is_eratsxr_offset),
               din     => ex2_is_eratsxr_q                  ,
               dout    => ex3_is_eratsxr_q);
ex3_is_mfcr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_is_mfcr_offset),
               scout   => sov(ex3_is_mfcr_offset),
               din     => ex2_is_mfcr_q                     ,
               dout    => ex3_is_mfcr_q);
ex3_is_wchkall_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_is_wchkall_offset),
               scout   => sov(ex3_is_wchkall_offset),
               din     => ex2_is_wchkall_q                  ,
               dout    => ex3_is_wchkall_q);
ex3_lk_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_lk_offset),
               scout   => sov(ex3_lk_offset),
               din     => ex2_lk_q                          ,
               dout    => ex3_lk_q);
ex3_mfdp_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_mfdp_val_offset),
               scout   => sov(ex3_mfdp_val_offset),
               din     => ex2_mfdp_val_q                    ,
               dout    => ex3_mfdp_val_q);
ex3_mtdp_nr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_mtdp_nr_offset),
               scout   => sov(ex3_mtdp_nr_offset),
               din     => ex2_mtdp_nr_q                     ,
               dout    => ex3_mtdp_nr_q);
ex3_mtdp_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_mtdp_val_offset),
               scout   => sov(ex3_mtdp_val_offset),
               din     => ex2_mtdp_val_q                    ,
               dout    => ex3_mtdp_val_q);
ex3_muldiv_coll_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_muldiv_coll_offset),
               scout   => sov(ex3_muldiv_coll_offset),
               din     => ex2_muldiv_coll_q                 ,
               dout    => ex3_muldiv_coll_q);
ex3_need_hole_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_need_hole_offset),
               scout   => sov(ex3_need_hole_offset),
               din     => ex2_need_hole_q                   ,
               dout    => ex3_need_hole_q);
ex3_pred_taken_cnt_latch : tri_rlmreg_p
     generic map (width => ex3_pred_taken_cnt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_pred_taken_cnt_offset to ex3_pred_taken_cnt_offset + ex3_pred_taken_cnt_q'length-1),
               scout   => sov(ex3_pred_taken_cnt_offset to ex3_pred_taken_cnt_offset + ex3_pred_taken_cnt_q'length-1),
               din     => ex2_pred_taken_cnt_q              ,
               dout    => ex3_pred_taken_cnt_q);
ex3_pred_update_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_pred_update_offset),
               scout   => sov(ex3_pred_update_offset),
               din     => ex2_pred_update_q                 ,
               dout    => ex3_pred_update_q);
ex3_pri_latch : tri_rlmreg_p
     generic map (width => ex3_pri_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_pri_offset to ex3_pri_offset + ex3_pri_q'length-1),
               scout   => sov(ex3_pri_offset to ex3_pri_offset + ex3_pri_q'length-1),
               din     => ex2_pri_q                         ,
               dout    => ex3_pri_q);
ex3_slowspr_dcr_rd_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_slowspr_dcr_rd_offset),
               scout   => sov(ex3_slowspr_dcr_rd_offset),
               din     => ex2_slowspr_dcr_rd_q              ,
               dout    => ex3_slowspr_dcr_rd_q);
ex3_ta_latch : tri_rlmreg_p
     generic map (width => ex3_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_ta_offset to ex3_ta_offset + ex3_ta_q'length-1),
               scout   => sov(ex3_ta_offset to ex3_ta_offset + ex3_ta_q'length-1),
               din     => ex2_ta_q                          ,
               dout    => ex3_ta_q);
ex3_tid_latch : tri_rlmreg_p
     generic map (width => ex3_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_tid_offset to ex3_tid_offset + ex3_tid_q'length-1),
               scout   => sov(ex3_tid_offset to ex3_tid_offset + ex3_tid_q'length-1),
               din     => ex2_tid_q                         ,
               dout    => ex3_tid_q);
ex3_tlb_data_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_tlb_data_val_offset),
               scout   => sov(ex3_tlb_data_val_offset),
               din     => ex2_tlb_data_val_q                ,
               dout    => ex3_tlb_data_val_q);
ex3_tlb_illeg_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_tlb_illeg_offset),
               scout   => sov(ex3_tlb_illeg_offset),
               din     => ex2_tlb_illeg_q                   ,
               dout    => ex3_tlb_illeg_q);
ex3_trace_type_latch : tri_rlmreg_p
     generic map (width => ex3_trace_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable_q   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_trace_type_offset to ex3_trace_type_offset + ex3_trace_type_q'length-1),
               scout   => sov(ex3_trace_type_offset to ex3_trace_type_offset + ex3_trace_type_q'length-1),
               din     => ex2_trace_type_q,
               dout    => ex3_trace_type_q);
ex3_trace_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable_q   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_trace_val_offset),
               scout   => sov(ex3_trace_val_offset),
               din     => ex2_trace_val_q                   ,
               dout    => ex3_trace_val_q);
ex3_val_latch : tri_rlmreg_p
     generic map (width => ex3_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_val_offset to ex3_val_offset + ex3_val_q'length-1),
               scout   => sov(ex3_val_offset to ex3_val_offset + ex3_val_q'length-1),
               din     => ex3_val_d,
               dout    => ex3_val_q);
ex4_act_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex4_act_offset),
               scout   => sov(ex4_act_offset),
               din     => ex4_act_d,
               dout    => ex4_act_q);
ex4_bh_latch : tri_regk
     generic map (width => ex4_bh_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex3_bh_q                          ,
               dout    => ex4_bh_q);
ex4_clear_barrier_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex4_clear_barrier_offset),
               scout   => sov(ex4_clear_barrier_offset),
               din     => ex3_clear_barrier_q               ,
               dout    => ex4_clear_barrier_q);
ex4_dp_instr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex4_dp_instr_d,
               dout(0) => ex4_dp_instr_q);
ex4_getNIA_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex3_getNIA_q                      ,
               dout(0) => ex4_getNIA_q);
ex4_gpr_we_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex4_gpr_we_offset),
               scout   => sov(ex4_gpr_we_offset),
               din     => ex4_gpr_we_d,
               dout    => ex4_gpr_we_q);
ex4_gshare_latch : tri_regk
     generic map (width => ex4_gshare_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex3_gshare_q                      ,
               dout    => ex4_gshare_q);
ex4_instr_latch : tri_regk
     generic map (width => ex4_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex3_instr_q                       ,
               dout    => ex4_instr_q);
ex4_is_bclr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex3_is_bclr_q                     ,
               dout(0) => ex4_is_bclr_q);
ex4_is_eratsxr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex3_is_eratsxr_q                  ,
               dout(0) => ex4_is_eratsxr_q);
ex4_is_mfcr_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex3_is_mfcr_q                     ,
               dout(0) => ex4_is_mfcr_q);
ex4_is_wchkall_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex3_is_wchkall_q                  ,
               dout(0) => ex4_is_wchkall_q);
ex4_lk_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex3_lk_q                          ,
               dout(0) => ex4_lk_q);
ex4_mfdp_val_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex3_mfdp_val_q                    ,
               dout(0) => ex4_mfdp_val_q);
ex4_mtdp_val_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex3_mtdp_val_q                    ,
               dout(0) => ex4_mtdp_val_q);
ex4_pred_taken_cnt_latch : tri_regk
     generic map (width => ex4_pred_taken_cnt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex3_pred_taken_cnt_q              ,
               dout    => ex4_pred_taken_cnt_q);
ex4_pred_update_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex3_pred_update_q                 ,
               dout(0) => ex4_pred_update_q);
ex4_pri_latch : tri_regk
     generic map (width => ex4_pri_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex3_pri_q                         ,
               dout    => ex4_pri_q);
ex4_slowspr_dcr_rd_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => ex3_slowspr_dcr_rd_q              ,
               dout(0) => ex4_slowspr_dcr_rd_q);
ex4_ta_latch : tri_regk
     generic map (width => ex4_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex3_ta_q                          ,
               dout    => ex4_ta_q);
ex4_tid_latch : tri_regk
     generic map (width => ex4_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex3_act_q            ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => ex3_tid_q                         ,
               dout    => ex4_tid_q);
ex4_val_latch : tri_rlmreg_p
     generic map (width => ex4_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex4_val_offset to ex4_val_offset + ex4_val_q'length-1),
               scout   => sov(ex4_val_offset to ex4_val_offset + ex4_val_q'length-1),
               din     => ex4_val_d,
               dout    => ex4_val_q);
ex5_act_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_act_offset),
               scout   => sov(ex5_act_offset),
               din     => ex5_act_d,
               dout    => ex5_act_q);
ex5_bh_latch : tri_rlmreg_p
     generic map (width => ex5_bh_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_bh_offset to ex5_bh_offset + ex5_bh_q'length-1),
               scout   => sov(ex5_bh_offset to ex5_bh_offset + ex5_bh_q'length-1),
               din     => ex4_bh_q                          ,
               dout    => ex5_bh_q);
ex5_clear_barrier_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_clear_barrier_offset),
               scout   => sov(ex5_clear_barrier_offset),
               din     => ex4_clear_barrier_q               ,
               dout    => ex5_clear_barrier_q);
ex5_getNIA_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_getNIA_offset),
               scout   => sov(ex5_getNIA_offset),
               din     => ex4_getNIA_q                      ,
               dout    => ex5_getNIA_q);
ex5_gpr_we_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_gpr_we_offset),
               scout   => sov(ex5_gpr_we_offset),
               din     => ex5_gpr_we_d,
               dout    => ex5_gpr_we_q);
ex5_gshare_latch : tri_rlmreg_p
     generic map (width => ex5_gshare_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_gshare_offset to ex5_gshare_offset + ex5_gshare_q'length-1),
               scout   => sov(ex5_gshare_offset to ex5_gshare_offset + ex5_gshare_q'length-1),
               din     => ex4_gshare_q                      ,
               dout    => ex5_gshare_q);
ex5_instr_latch : tri_rlmreg_p
     generic map (width => ex5_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_instr_offset to ex5_instr_offset + ex5_instr_q'length-1),
               scout   => sov(ex5_instr_offset to ex5_instr_offset + ex5_instr_q'length-1),
               din     => ex4_instr_q                       ,
               dout    => ex5_instr_q);
ex5_is_bclr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_is_bclr_offset),
               scout   => sov(ex5_is_bclr_offset),
               din     => ex4_is_bclr_q                     ,
               dout    => ex5_is_bclr_q);
ex5_lk_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_lk_offset),
               scout   => sov(ex5_lk_offset),
               din     => ex4_lk_q                          ,
               dout    => ex5_lk_q);
ex5_pred_taken_cnt_latch : tri_rlmreg_p
     generic map (width => ex5_pred_taken_cnt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_pred_taken_cnt_offset to ex5_pred_taken_cnt_offset + ex5_pred_taken_cnt_q'length-1),
               scout   => sov(ex5_pred_taken_cnt_offset to ex5_pred_taken_cnt_offset + ex5_pred_taken_cnt_q'length-1),
               din     => ex4_pred_taken_cnt_q              ,
               dout    => ex5_pred_taken_cnt_q);
ex5_pred_update_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_pred_update_offset),
               scout   => sov(ex5_pred_update_offset),
               din     => ex4_pred_update_q                 ,
               dout    => ex5_pred_update_q);
ex5_pri_latch : tri_rlmreg_p
     generic map (width => ex5_pri_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_pri_offset to ex5_pri_offset + ex5_pri_q'length-1),
               scout   => sov(ex5_pri_offset to ex5_pri_offset + ex5_pri_q'length-1),
               din     => ex4_pri_q                         ,
               dout    => ex5_pri_q);
ex5_slowspr_dcr_rd_latch : tri_rlmreg_p
     generic map (width => ex5_slowspr_dcr_rd_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_slowspr_dcr_rd_offset to ex5_slowspr_dcr_rd_offset + ex5_slowspr_dcr_rd_q'length-1),
               scout   => sov(ex5_slowspr_dcr_rd_offset to ex5_slowspr_dcr_rd_offset + ex5_slowspr_dcr_rd_q'length-1),
               din     => ex5_slowspr_dcr_rd_d,
               dout    => ex5_slowspr_dcr_rd_q);
ex5_ta_latch : tri_rlmreg_p
     generic map (width => ex5_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_ta_offset to ex5_ta_offset + ex5_ta_q'length-1),
               scout   => sov(ex5_ta_offset to ex5_ta_offset + ex5_ta_q'length-1),
               din     => ex4_ta_q                          ,
               dout    => ex5_ta_q);
ex5_tid_latch : tri_rlmreg_p
     generic map (width => ex5_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_tid_offset to ex5_tid_offset + ex5_tid_q'length-1),
               scout   => sov(ex5_tid_offset to ex5_tid_offset + ex5_tid_q'length-1),
               din     => ex4_tid_q                         ,
               dout    => ex5_tid_q);
ex5_val_latch : tri_rlmreg_p
     generic map (width => ex5_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_val_offset to ex5_val_offset + ex5_val_q'length-1),
               scout   => sov(ex5_val_offset to ex5_val_offset + ex5_val_q'length-1),
               din     => ex5_val_d,
               dout    => ex5_val_q);
ex6_clear_barrier_latch : tri_rlmreg_p
     generic map (width => ex6_clear_barrier_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex6_clear_barrier_offset to ex6_clear_barrier_offset + ex6_clear_barrier_q'length-1),
               scout   => sov(ex6_clear_barrier_offset to ex6_clear_barrier_offset + ex6_clear_barrier_q'length-1),
               din     => ex6_clear_barrier_d,
               dout    => ex6_clear_barrier_q);
ex6_gpr_we_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex6_gpr_we_offset),
               scout   => sov(ex6_gpr_we_offset),
               din     => ex6_gpr_we_d,
               dout    => ex6_gpr_we_q);
ex6_pri_latch : tri_rlmreg_p
     generic map (width => ex6_pri_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex5_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex6_pri_offset to ex6_pri_offset + ex6_pri_q'length-1),
               scout   => sov(ex6_pri_offset to ex6_pri_offset + ex6_pri_q'length-1),
               din     => ex5_pri_q                         ,
               dout    => ex6_pri_q);
ex6_ta_latch : tri_rlmreg_p
     generic map (width => ex6_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex6_ta_offset to ex6_ta_offset + ex6_ta_q'length-1),
               scout   => sov(ex6_ta_offset to ex6_ta_offset + ex6_ta_q'length-1),
               din     => ex6_ta_d,
               dout    => ex6_ta_q);
ex6_val_latch : tri_rlmreg_p
     generic map (width => ex6_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex6_val_offset to ex6_val_offset + ex6_val_q'length-1),
               scout   => sov(ex6_val_offset to ex6_val_offset + ex6_val_q'length-1),
               din     => ex6_val_d,
               dout    => ex6_val_q);
ex7_gpr_we_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex7_gpr_we_offset),
               scout   => sov(ex7_gpr_we_offset),
               din     => ex6_gpr_we_q                      ,
               dout    => ex7_gpr_we_q);
ex7_ta_latch : tri_rlmreg_p
     generic map (width => ex7_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex7_ta_offset to ex7_ta_offset + ex7_ta_q'length-1),
               scout   => sov(ex7_ta_offset to ex7_ta_offset + ex7_ta_q'length-1),
               din     => ex6_ta_q                          ,
               dout    => ex7_ta_q);
ex7_val_latch : tri_rlmreg_p
     generic map (width => ex7_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex7_val_offset to ex7_val_offset + ex7_val_q'length-1),
               scout   => sov(ex7_val_offset to ex7_val_offset + ex7_val_q'length-1),
               din     => ex6_val_q                         ,
               dout    => ex7_val_q);
an_ac_dcr_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(an_ac_dcr_val_offset),
               scout   => sov(an_ac_dcr_val_offset),
               din     => an_ac_dcr_val                     ,
               dout    => an_ac_dcr_val_q);
dcr_ack_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(dcr_ack_offset),
               scout   => sov(dcr_ack_offset),
               din     => dcr_ack,
               dout    => dcr_ack_q);
dcr_act_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(dcr_act_offset),
               scout   => sov(dcr_act_offset),
               din     => an_ac_dcr_act                     ,
               dout    => dcr_act_q);
dcr_etid_latch : tri_rlmreg_p
     generic map (width => dcr_etid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => dcr_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(dcr_etid_offset to dcr_etid_offset + dcr_etid_q'length-1),
               scout   => sov(dcr_etid_offset to dcr_etid_offset + dcr_etid_q'length-1),
               din     => an_ac_dcr_etid                    ,
               dout    => dcr_etid_q);
dcr_read_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => dcr_act_q            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(dcr_read_offset),
               scout   => sov(dcr_read_offset),
               din     => an_ac_dcr_read                    ,
               dout    => dcr_read_q);
dcr_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(dcr_val_offset),
               scout   => sov(dcr_val_offset),
               din     => dcr_val_d,
               dout    => dcr_val_q);
instr_trace_mode_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable_q   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(instr_trace_mode_offset),
               scout   => sov(instr_trace_mode_offset),
               din     => pc_xu_instr_trace_mode            ,
               dout    => instr_trace_mode_q);
instr_trace_tid_latch : tri_rlmreg_p
     generic map (width => instr_trace_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable_q   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(instr_trace_tid_offset to instr_trace_tid_offset + instr_trace_tid_q'length-1),
               scout   => sov(instr_trace_tid_offset to instr_trace_tid_offset + instr_trace_tid_q'length-1),
               din     => pc_xu_instr_trace_tid             ,
               dout    => instr_trace_tid_q);
lsu_xu_need_hole_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(lsu_xu_need_hole_offset),
               scout   => sov(lsu_xu_need_hole_offset),
               din     => lsu_xu_need_hole_d,
               dout    => lsu_xu_need_hole_q);
lsu_xu_rel_ta_gpr_latch : tri_rlmreg_p
     generic map (width => lsu_xu_rel_ta_gpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(lsu_xu_rel_ta_gpr_offset to lsu_xu_rel_ta_gpr_offset + lsu_xu_rel_ta_gpr_q'length-1),
               scout   => sov(lsu_xu_rel_ta_gpr_offset to lsu_xu_rel_ta_gpr_offset + lsu_xu_rel_ta_gpr_q'length-1),
               din     => lsu_xu_rel_ta_gpr                 ,
               dout    => lsu_xu_rel_ta_gpr_q);
lsu_xu_rel_wren_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(lsu_xu_rel_wren_offset),
               scout   => sov(lsu_xu_rel_wren_offset),
               din     => lsu_xu_rel_wren                   ,
               dout    => lsu_xu_rel_wren_q);
mmucr0_0_tlbsel_latch : tri_rlmreg_p
     generic map (width => mmucr0_0_tlbsel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(mmucr0_0_tlbsel_offset to mmucr0_0_tlbsel_offset + mmucr0_0_tlbsel_q'length-1),
               scout   => sov(mmucr0_0_tlbsel_offset to mmucr0_0_tlbsel_offset + mmucr0_0_tlbsel_q'length-1),
               din     => mm_xu_mmucr0_0_tlbsel             ,
               dout    => mmucr0_0_tlbsel_q);
mmucr0_1_tlbsel_latch : tri_rlmreg_p
     generic map (width => mmucr0_1_tlbsel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(mmucr0_1_tlbsel_offset to mmucr0_1_tlbsel_offset + mmucr0_1_tlbsel_q'length-1),
               scout   => sov(mmucr0_1_tlbsel_offset to mmucr0_1_tlbsel_offset + mmucr0_1_tlbsel_q'length-1),
               din     => mm_xu_mmucr0_1_tlbsel             ,
               dout    => mmucr0_1_tlbsel_q);
mmucr0_2_tlbsel_latch : tri_rlmreg_p
     generic map (width => mmucr0_2_tlbsel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(mmucr0_2_tlbsel_offset to mmucr0_2_tlbsel_offset + mmucr0_2_tlbsel_q'length-1),
               scout   => sov(mmucr0_2_tlbsel_offset to mmucr0_2_tlbsel_offset + mmucr0_2_tlbsel_q'length-1),
               din     => mm_xu_mmucr0_2_tlbsel             ,
               dout    => mmucr0_2_tlbsel_q);
mmucr0_3_tlbsel_latch : tri_rlmreg_p
     generic map (width => mmucr0_3_tlbsel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(mmucr0_3_tlbsel_offset to mmucr0_3_tlbsel_offset + mmucr0_3_tlbsel_q'length-1),
               scout   => sov(mmucr0_3_tlbsel_offset to mmucr0_3_tlbsel_offset + mmucr0_3_tlbsel_q'length-1),
               din     => mm_xu_mmucr0_3_tlbsel             ,
               dout    => mmucr0_3_tlbsel_q);
slowspr_etid_latch : tri_rlmreg_p
     generic map (width => slowspr_etid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => slowspr_val_in       ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(slowspr_etid_offset to slowspr_etid_offset + slowspr_etid_q'length-1),
               scout   => sov(slowspr_etid_offset to slowspr_etid_offset + slowspr_etid_q'length-1),
               din     => slowspr_etid_in                   ,
               dout    => slowspr_etid_q);
slowspr_rw_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => slowspr_val_in       ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(slowspr_rw_offset),
               scout   => sov(slowspr_rw_offset),
               din     => slowspr_rw_in                     ,
               dout    => slowspr_rw_q);
slowspr_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(slowspr_val_offset),
               scout   => sov(slowspr_val_offset),
               din     => slowspr_val_in                    ,
               dout    => slowspr_val_q);
spr_ccr2_en_attn_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => spr_bit_act_q          ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(spr_ccr2_en_attn_offset),
               scout   => sov(spr_ccr2_en_attn_offset),
               din     => spr_ccr2_en_attn                  ,
               dout    => spr_ccr2_en_attn_q);
spr_ccr2_en_dcr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => spr_bit_act_q          ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(spr_ccr2_en_dcr_offset),
               scout   => sov(spr_ccr2_en_dcr_offset),
               din     => spr_ccr2_en_dcr                   ,
               dout    => spr_ccr2_en_dcr_q);
spr_ccr2_en_ditc_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => spr_bit_act_q          ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(spr_ccr2_en_ditc_offset),
               scout   => sov(spr_ccr2_en_ditc_offset),
               din     => spr_ccr2_en_ditc                  ,
               dout    => spr_ccr2_en_ditc_q);
spr_ccr2_en_icswx_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => spr_bit_act_q          ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(spr_ccr2_en_icswx_offset),
               scout   => sov(spr_ccr2_en_icswx_offset),
               din     => spr_ccr2_en_icswx                 ,
               dout    => spr_ccr2_en_icswx_q);
spr_ccr2_en_pc_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => spr_bit_act_q          ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(spr_ccr2_en_pc_offset),
               scout   => sov(spr_ccr2_en_pc_offset),
               din     => spr_ccr2_en_pc                    ,
               dout    => spr_ccr2_en_pc_q);
spr_ccr2_notlb_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => spr_bit_act_q          ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(spr_ccr2_notlb_offset),
               scout   => sov(spr_ccr2_notlb_offset),
               din     => spr_ccr2_notlb                    ,
               dout    => spr_ccr2_notlb_q);
spr_msr_cm_latch : tri_rlmreg_p
     generic map (width => spr_msr_cm_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(spr_msr_cm_offset to spr_msr_cm_offset + spr_msr_cm_q'length-1),
               scout   => sov(spr_msr_cm_offset to spr_msr_cm_offset + spr_msr_cm_q'length-1),
               din     => spr_msr_cm                        ,
               dout    => spr_msr_cm_q);
t0_hold_ta_latch : tri_rlmreg_p
     generic map (width => t0_hold_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex5_slowspr_dcr_rd_q(0),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(t0_hold_ta_offset to t0_hold_ta_offset + t0_hold_ta_q'length-1),
               scout   => sov(t0_hold_ta_offset to t0_hold_ta_offset + t0_hold_ta_q'length-1),
               din     => ex5_ta_q(0 to 5)                          ,
               dout    => t0_hold_ta_q);
t1_hold_ta_latch : tri_rlmreg_p
     generic map (width => t1_hold_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex5_slowspr_dcr_rd_q(1),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(t1_hold_ta_offset to t1_hold_ta_offset + t1_hold_ta_q'length-1),
               scout   => sov(t1_hold_ta_offset to t1_hold_ta_offset + t1_hold_ta_q'length-1),
               din     => ex5_ta_q(0 to 5)                          ,
               dout    => t1_hold_ta_q);
t2_hold_ta_latch : tri_rlmreg_p
     generic map (width => t2_hold_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex5_slowspr_dcr_rd_q(2),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(t2_hold_ta_offset to t2_hold_ta_offset + t2_hold_ta_q'length-1),
               scout   => sov(t2_hold_ta_offset to t2_hold_ta_offset + t2_hold_ta_q'length-1),
               din     => ex5_ta_q(0 to 5)                          ,
               dout    => t2_hold_ta_q);
t3_hold_ta_latch : tri_rlmreg_p
     generic map (width => t3_hold_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex5_slowspr_dcr_rd_q(3),
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(t3_hold_ta_offset to t3_hold_ta_offset + t3_hold_ta_q'length-1),
               scout   => sov(t3_hold_ta_offset to t3_hold_ta_offset + t3_hold_ta_q'length-1),
               din     => ex5_ta_q(0 to 5)                          ,
               dout    => t3_hold_ta_q);
trace_bus_enable_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(trace_bus_enable_offset),
               scout   => sov(trace_bus_enable_offset),
               din     => pc_xu_trace_bus_enable            ,
               dout    => trace_bus_enable_q);
clkg_ctl_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(clkg_ctl_offset),
               scout   => sov(clkg_ctl_offset),
               din     => spr_xucr0_clkg_ctl(2),
               dout    => clkg_ctl_q);
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
spare_0_d    <=  not spare_0_q;
mark_unused(spare_0_q);
spare_1_lcb: entity tri.tri_lcbnd(tri_lcbnd)
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
spare_1_d    <=  not spare_1_q;
mark_unused(spare_1_q);
siv(0 TO siv'right) <=  sov(1 to siv'right) & scan_in;
scan_out  <=  sov(0);
END XUQ_DEC_B;
