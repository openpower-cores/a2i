-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

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

entity xuq_dec_a is
    generic(
        expand_type                         : integer := 2;
        threads                             : integer := 4;
        regmode                             : integer := 6;
        regsize                             : integer := 63;
        real_data_add                       : integer := 42;
        eff_ifar                            : integer := 62);
    port(
        nclk                                : in clk_logic;

        vdd                                 : inout power_logic;
        gnd                                 : inout power_logic;

        d_mode_dc                           : in  std_ulogic;
        delay_lclkr_dc                      : in  std_ulogic;
        mpw1_dc_b                           : in  std_ulogic;
        mpw2_dc_b                           : in  std_ulogic;
        func_sl_force : in  std_ulogic;
        func_sl_thold_0_b                   : in  std_ulogic;
        sg_0                                : in  std_ulogic;
        scan_in                             : in  std_ulogic;
        scan_out                            : out std_ulogic;

        iu_xu_is2_vld                       : in  std_ulogic;
        iu_xu_is2_ifar                      : in  std_ulogic_vector(62-eff_ifar to 61);
        iu_xu_is2_tid                       : in  std_ulogic_vector(0 to threads-1);
        iu_xu_is2_instr                     : in  std_ulogic_vector(0 to 31);
        iu_xu_is2_ta_vld                    : in  std_ulogic;
        iu_xu_is2_ta                        : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_s1_vld                    : in  std_ulogic;
        iu_xu_is2_s1                        : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_s2_vld                    : in  std_ulogic;
        iu_xu_is2_s2                        : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_s3_vld                    : in  std_ulogic;
        iu_xu_is2_s3                        : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_axu_ld_or_st              : in  std_ulogic;
        iu_xu_is2_axu_store                 : in  std_ulogic;
        iu_xu_is2_axu_ldst_size             : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_axu_ldst_update           : in  std_ulogic;
        iu_xu_is2_axu_ldst_forcealign       : in  std_ulogic;
        iu_xu_is2_axu_ldst_forceexcept      : in  std_ulogic;
        iu_xu_is2_axu_ldst_extpid           : in  std_ulogic;
        iu_xu_is2_axu_ldst_indexed          : in  std_ulogic;
        iu_xu_is2_axu_ldst_tag              : in  std_ulogic_vector(0 to 8);
        iu_xu_is2_axu_mftgpr                : in  std_ulogic;
        iu_xu_is2_axu_mffgpr                : in  std_ulogic;
        iu_xu_is2_axu_movedp                : in  std_ulogic;
        iu_xu_is2_axu_instr_type            : in  std_ulogic_vector(0 to 2);
        iu_xu_is2_pred_update               : in  std_ulogic;
        iu_xu_is2_pred_taken_cnt            : in  std_ulogic_vector(0 to 1);
        iu_xu_is2_error                     : in  std_ulogic_vector(0 to 2);
        iu_xu_is2_match                     : in  std_ulogic;
        iu_xu_is2_is_ucode                  : in  std_ulogic;
        iu_xu_is2_ucode_vld                 : in  std_ulogic;
        iu_xu_is2_gshare                    : in  std_ulogic_vector(0 to 3);
        xu_div_barr_done                    : out std_ulogic_vector(0 to threads-1);
        xu_div_coll_barr_done               : out std_ulogic_vector(0 to threads-1);

        dec_gpr_rf0_re0                     : out std_ulogic;
        dec_gpr_rf0_re1                     : out std_ulogic;
        dec_gpr_rf0_re2                     : out std_ulogic;
        dec_gpr_rf0_ra0                     : out std_ulogic_vector(0 to 7);
        dec_gpr_rf0_ra1                     : out std_ulogic_vector(0 to 7);
        dec_gpr_rf0_ra2                     : out std_ulogic_vector(0 to 7);
        dec_gpr_rel_ta_gpr                  : out std_ulogic_vector(0 to 7);
        dec_gpr_rel_wren                    : out std_ulogic;

        fxa_fxb_rf0_val                     : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_issued                  : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_ucode_val               : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_act                     : out std_ulogic;
        fxa_fxb_ex1_hold_ctr_flush          : out std_ulogic;
        fxa_fxb_rf0_instr                   : out std_ulogic_vector(0 to 31);
        fxa_fxb_rf0_tid                     : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_ta_vld                  : out std_ulogic;
        fxa_fxb_rf0_ta                      : out std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_error                   : out std_ulogic_vector(0 to 2);
        fxa_fxb_rf0_match                   : out std_ulogic;
        fxa_fxb_rf0_is_ucode                : out std_ulogic;
        fxa_fxb_rf0_gshare                  : out std_ulogic_vector(0 to 3);
        fxa_fxb_rf0_ifar                    : out std_ulogic_vector(62-eff_ifar to 61);
        fxa_fxb_rf0_s1_vld                  : out std_ulogic;
        fxa_fxb_rf0_s1                      : out std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_s2_vld                  : out std_ulogic;
        fxa_fxb_rf0_s2                      : out std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_s3_vld                  : out std_ulogic;
        fxa_fxb_rf0_s3                      : out std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_axu_instr_type          : out std_ulogic_vector(0 to 2);
        fxa_fxb_rf0_axu_ld_or_st            : out std_ulogic;
        fxa_fxb_rf0_axu_store               : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_forcealign     : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_forceexcept    : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_indexed        : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_tag            : out std_ulogic_vector(0 to 8);
        fxa_fxb_rf0_axu_mftgpr              : out std_ulogic;
        fxa_fxb_rf0_axu_mffgpr              : out std_ulogic;
        fxa_fxb_rf0_axu_movedp              : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_size           : out std_ulogic_vector(0 to 5);
        fxa_fxb_rf0_axu_ldst_update         : out std_ulogic;
        fxa_fxb_rf0_pred_update             : out std_ulogic;
        fxa_fxb_rf0_pred_taken_cnt          : out std_ulogic_vector(0 to 1);
        fxa_fxb_rf0_mc_dep_chk_val          : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf1_mul_val                 : out std_ulogic;
        fxa_fxb_rf1_muldiv_coll             : out std_ulogic;
        fxa_fxb_rf1_div_val                 : out std_ulogic;
        fxa_fxb_rf1_div_ctr                 : out std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_xu_epid_instr           : out std_ulogic;
        fxa_fxb_rf0_axu_is_extload          : out std_ulogic;
        fxa_fxb_rf0_axu_is_extstore         : out std_ulogic;
        fxa_fxb_rf0_spr_tid                 : out std_ulogic_vector(0 to threads-1); 
        fxa_fxb_rf0_cpl_tid                 : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_cpl_act                 : out std_ulogic;
        fxa_fxb_rf0_is_mfocrf               : out std_ulogic;
        fxa_fxb_rf0_3src_instr              : out std_ulogic;
        fxa_fxb_rf0_gpr0_zero               : out std_ulogic;
        fxa_fxb_rf0_use_imm                 : out std_ulogic;
        dec_cpl_ex3_mc_dep_chk_val          : out std_ulogic_vector(0 to threads-1);
        fxa_cpl_ex2_div_coll                : out std_ulogic_vector(0 to threads-1);
        cpl_fxa_ex5_set_barr                : in  std_ulogic_vector(0 to threads-1);
        fxa_iu_set_barr_tid                 : out std_ulogic_vector(0 to threads-1);
        spr_xucr4_div_barr_thres            : in  std_ulogic_vector(0 to 7);
        fxa_perf_muldiv_in_use              : out std_ulogic;

        xu_is2_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_rf0_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_rf1_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex1_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex2_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex3_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex4_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex5_flush                        : in  std_ulogic_vector(0 to threads-1);

        an_ac_back_inv                      : in  std_ulogic;
        an_ac_back_inv_addr                 : in  std_ulogic_vector(62 to 63);
        an_ac_back_inv_target_bit3          : in  std_ulogic;

        dec_spr_rf0_instr                   : out std_ulogic_vector(0 to 31);
        spr_xucr0_clkg_ctl_b0               : in  std_ulogic;

        xu_lsu_rf0_derat_is_extload         : out std_ulogic;
        xu_lsu_rf0_derat_is_extstore        : out std_ulogic;
        xu_lsu_rf0_derat_val                : out std_ulogic_vector(0 to threads-1);
        lsu_xu_rel_wren                     : in  std_ulogic;
        lsu_xu_rel_ta_gpr                   : in  std_ulogic_vector(0 to 7);

        dec_debug                           : out std_ulogic_vector(0 to 175)
    );
end xuq_dec_a;
ARCHITECTURE XUQ_DEC_A
          OF XUQ_DEC_A
          IS
SIGNAL TBL_3SRC_DEC_PT                   : STD_ULOGIC_VECTOR(1 TO 15)  := 
(OTHERS=> 'U');
SIGNAL TBL_GPR0_ZERO_PT                  : STD_ULOGIC_VECTOR(1 TO 33)  := 
(OTHERS=> 'U');
SIGNAL TBL_RF0_DEC_PT                    : STD_ULOGIC_VECTOR(1 TO 11)  := 
(OTHERS=> 'U');
SIGNAL TBL_RF0_EPID_DEC_PT               : STD_ULOGIC_VECTOR(1 TO 9)  := 
(OTHERS=> 'U');
SIGNAL TBL_USE_IMM_PT                    : STD_ULOGIC_VECTOR(1 TO 15)  := 
(OTHERS=> 'U');
subtype s2                                                              is std_ulogic_vector(0 to 1);
subtype s3                                                              is std_ulogic_vector(0 to 2);
constant tiup                                                           : std_ulogic := '1';
constant tidn                                                           : std_ulogic := '0';
signal rf0_axu_instr_type_q                                   : std_ulogic_vector(0 to 2);
signal rf0_axu_ld_or_st_q                                     : std_ulogic;
signal rf0_axu_ldst_extpid_q                                  : std_ulogic;
signal rf0_axu_ldst_forcealign_q                              : std_ulogic;
signal rf0_axu_ldst_forceexcept_q                             : std_ulogic;
signal rf0_axu_ldst_indexed_q                                 : std_ulogic;
signal rf0_axu_ldst_size_q                                    : std_ulogic_vector(0 to 5);
signal rf0_axu_ldst_tag_q                                     : std_ulogic_vector(0 to 8);
signal rf0_axu_ldst_update_q                                  : std_ulogic;
signal rf0_axu_mffgpr_q                                       : std_ulogic;
signal rf0_axu_mftgpr_q                                       : std_ulogic;
signal rf0_axu_movedp_q                                       : std_ulogic;
signal rf0_axu_store_q                                        : std_ulogic;
signal rf0_error_q                                            : std_ulogic_vector(0 to 2);
signal rf0_gshare_q                                           : std_ulogic_vector(0 to 3);
signal rf0_ifar_q                                             : std_ulogic_vector(62-eff_ifar to 61);
signal rf0_instr_q                                            : std_ulogic_vector(0 to 31);
signal rf0_is_ucode_q                                         : std_ulogic;
signal rf0_match_q                                            : std_ulogic;
signal rf0_pred_taken_cnt_q                                   : std_ulogic_vector(0 to 1);
signal rf0_pred_update_q                                      : std_ulogic;
signal rf0_s1_q                                               : std_ulogic_vector(0 to 5);
signal rf0_s1_vld_q,              rf0_s1_vld_d                : std_ulogic;
signal rf0_s2_q                                               : std_ulogic_vector(0 to 5);
signal rf0_s2_vld_q,              rf0_s2_vld_d                : std_ulogic;
signal rf0_s3_q                                               : std_ulogic_vector(0 to 5);
signal rf0_s3_vld_q,              rf0_s3_vld_d                : std_ulogic;
signal rf0_ta_q                                               : std_ulogic_vector(0 to 5);
signal rf0_ta_vld_q,              rf0_ta_vld_d                : std_ulogic;
signal rf0_tid_q                                              : std_ulogic_vector(0 to threads-1);
signal rf0_ucode_val_q,           rf0_ucode_val_d             : std_ulogic_vector(0 to threads-1);
signal rf0_val_q,                 rf0_val_d                   : std_ulogic_vector(0 to threads-1);
signal rf1_barrier_done_q,        rf0_barrier_done            : std_ulogic;
signal rf1_div_coll_q,            rf1_div_coll_d              : std_ulogic;
signal rf1_div_val_q,             rf0_div_val                 : std_ulogic_vector(0 to threads-1);
signal rf1_mul_valid_q,           rf0_mul_valid               : std_ulogic;
signal rf1_muldiv_coll_q,         rf0_muldiv_coll             : std_ulogic;
signal rf1_multdiv_val_q,         rf0_multdiv_val             : std_ulogic_vector(0 to threads-1);
signal rf1_recirc_ctr_q,          rf1_recirc_ctr_d            : std_ulogic_vector(0 to 7);
signal rf1_recirc_ctr_flush_q,    rf0_recirc_ctr_flush        : std_ulogic;
signal ex1_div_coll_q,            ex1_div_coll_d              : std_ulogic;
signal ex1_div_val_q,             ex1_div_val_d               : std_ulogic_vector(0 to threads-1);
signal ex1_muldiv_in_use_q                                    : std_ulogic;
signal ex1_multdiv_val_q,         ex1_multdiv_val_d           : std_ulogic_vector(0 to threads-1);
signal ex1_recirc_ctr_flush_q                                 : std_ulogic;
signal ex2_div_coll_q,            ex2_div_coll_d              : std_ulogic;
signal ex2_div_val_q,             ex2_div_val_d               : std_ulogic_vector(0 to threads-1);
signal ex2_multdiv_val_q,         ex2_multdiv_val_d           : std_ulogic_vector(0 to threads-1);
signal ex3_div_val_q,             ex3_div_val_d               : std_ulogic_vector(0 to threads-1);
signal ex3_multdiv_val_q,         ex3_multdiv_val_d           : std_ulogic_vector(0 to threads-1);
signal ex4_div_val_q,             ex4_div_val_d               : std_ulogic_vector(0 to threads-1);
signal ex5_div_val_q,             ex5_div_val_d               : std_ulogic_vector(0 to threads-1);
signal ex6_div_barr_val_q                                     : std_ulogic;
signal ex6_set_barr_q,            ex5_set_barr                : std_ulogic_vector(0 to threads-1);
signal an_ac_back_inv_q                                       : std_ulogic;
signal an_ac_back_inv_addr_q                                  : std_ulogic_vector(62 to 63);
signal an_ac_back_inv_target_bit3_q                           : std_ulogic;
signal back_inv_val_q,            back_inv_val_d              : std_ulogic;
signal coll_tid_q,                coll_tid_d                  : std_ulogic_vector(0 to threads-1);
signal div_barr_done_q,           div_barr_done_d             : std_ulogic_vector(0 to threads-1);
signal div_barr_thres_q                                       : std_ulogic_vector(0 to 7);
signal div_coll_barr_done_q,      div_coll_barr_done_d        : std_ulogic_vector(0 to threads-1);
signal hold_divide_q                                          : std_ulogic;
signal hold_error_q,              hold_error_d                : std_ulogic_vector(0 to 2);
signal hold_ifar_q,               hold_ifar_d                 : std_ulogic_vector(62-eff_ifar to 61);
signal hold_instr_q,              hold_instr_d                : std_ulogic_vector(0 to 31);
signal hold_is_ucode_q,           hold_is_ucode_d             : std_ulogic;
signal hold_match_q,              hold_match_d                : std_ulogic;
signal hold_s1_q,                 hold_s1_d                   : std_ulogic_vector(0 to 7);
signal hold_s1_vld_q,             hold_s1_vld_d               : std_ulogic;
signal hold_s2_q,                 hold_s2_d                   : std_ulogic_vector(0 to 7);
signal hold_s2_vld_q,             hold_s2_vld_d               : std_ulogic;
signal hold_s3_q,                 hold_s3_d                   : std_ulogic_vector(0 to 7);
signal hold_s3_vld_q,             hold_s3_vld_d               : std_ulogic;
signal hold_ta_q,                 hold_ta_d                   : std_ulogic_vector(0 to 7);
signal hold_ta_vld_q,             hold_ta_vld_d               : std_ulogic;
signal hold_tid_q,                hold_tid_d                  : std_ulogic_vector(0 to threads-1);
signal hold_use_imm_q,            hold_use_imm_d              : std_ulogic;
signal lsu_xu_rel_ta_gpr_q                                    : std_ulogic_vector(0 to 7);
signal lsu_xu_rel_wren_q                                      : std_ulogic;
signal spare_0_q,                 spare_0_d                   : std_ulogic_vector(0 to 15);
signal spare_1_q,                 spare_1_d                   : std_ulogic_vector(0 to 15);
constant rf0_axu_instr_type_offset                 : integer := 0;
constant rf0_axu_ld_or_st_offset                   : integer := rf0_axu_instr_type_offset      + rf0_axu_instr_type_q'length;
constant rf0_axu_ldst_extpid_offset                : integer := rf0_axu_ld_or_st_offset        + 1;
constant rf0_axu_ldst_forcealign_offset            : integer := rf0_axu_ldst_extpid_offset     + 1;
constant rf0_axu_ldst_forceexcept_offset           : integer := rf0_axu_ldst_forcealign_offset + 1;
constant rf0_axu_ldst_indexed_offset               : integer := rf0_axu_ldst_forceexcept_offset + 1;
constant rf0_axu_ldst_size_offset                  : integer := rf0_axu_ldst_indexed_offset    + 1;
constant rf0_axu_ldst_tag_offset                   : integer := rf0_axu_ldst_size_offset       + rf0_axu_ldst_size_q'length;
constant rf0_axu_ldst_update_offset                : integer := rf0_axu_ldst_tag_offset        + rf0_axu_ldst_tag_q'length;
constant rf0_axu_mffgpr_offset                     : integer := rf0_axu_ldst_update_offset     + 1;
constant rf0_axu_mftgpr_offset                     : integer := rf0_axu_mffgpr_offset          + 1;
constant rf0_axu_movedp_offset                     : integer := rf0_axu_mftgpr_offset          + 1;
constant rf0_axu_store_offset                      : integer := rf0_axu_movedp_offset          + 1;
constant rf0_error_offset                          : integer := rf0_axu_store_offset           + 1;
constant rf0_gshare_offset                         : integer := rf0_error_offset               + rf0_error_q'length;
constant rf0_ifar_offset                           : integer := rf0_gshare_offset              + rf0_gshare_q'length;
constant rf0_instr_offset                          : integer := rf0_ifar_offset                + rf0_ifar_q'length;
constant rf0_is_ucode_offset                       : integer := rf0_instr_offset               + rf0_instr_q'length;
constant rf0_match_offset                          : integer := rf0_is_ucode_offset            + 1;
constant rf0_pred_taken_cnt_offset                 : integer := rf0_match_offset               + 1;
constant rf0_pred_update_offset                    : integer := rf0_pred_taken_cnt_offset      + rf0_pred_taken_cnt_q'length;
constant rf0_s1_offset                             : integer := rf0_pred_update_offset         + 1;
constant rf0_s1_vld_offset                         : integer := rf0_s1_offset                  + rf0_s1_q'length;
constant rf0_s2_offset                             : integer := rf0_s1_vld_offset              + 1;
constant rf0_s2_vld_offset                         : integer := rf0_s2_offset                  + rf0_s2_q'length;
constant rf0_s3_offset                             : integer := rf0_s2_vld_offset              + 1;
constant rf0_s3_vld_offset                         : integer := rf0_s3_offset                  + rf0_s3_q'length;
constant rf0_ta_offset                             : integer := rf0_s3_vld_offset              + 1;
constant rf0_ta_vld_offset                         : integer := rf0_ta_offset                  + rf0_ta_q'length;
constant rf0_tid_offset                            : integer := rf0_ta_vld_offset              + 1;
constant rf0_ucode_val_offset                      : integer := rf0_tid_offset                 + rf0_tid_q'length;
constant rf0_val_offset                            : integer := rf0_ucode_val_offset           + rf0_ucode_val_q'length;
constant rf1_barrier_done_offset                   : integer := rf0_val_offset                 + rf0_val_q'length;
constant rf1_div_coll_offset                       : integer := rf1_barrier_done_offset        + 1;
constant rf1_div_val_offset                        : integer := rf1_div_coll_offset            + 1;
constant rf1_mul_valid_offset                      : integer := rf1_div_val_offset             + rf1_div_val_q'length;
constant rf1_muldiv_coll_offset                    : integer := rf1_mul_valid_offset           + 1;
constant rf1_multdiv_val_offset                    : integer := rf1_muldiv_coll_offset         + 1;
constant rf1_recirc_ctr_offset                     : integer := rf1_multdiv_val_offset         + rf1_multdiv_val_q'length;
constant rf1_recirc_ctr_flush_offset               : integer := rf1_recirc_ctr_offset          + rf1_recirc_ctr_q'length;
constant ex1_div_coll_offset                       : integer := rf1_recirc_ctr_flush_offset    + 1;
constant ex1_div_val_offset                        : integer := ex1_div_coll_offset            + 1;
constant ex1_muldiv_in_use_offset                  : integer := ex1_div_val_offset             + ex1_div_val_q'length;
constant ex1_multdiv_val_offset                    : integer := ex1_muldiv_in_use_offset       + 1;
constant ex1_recirc_ctr_flush_offset               : integer := ex1_multdiv_val_offset         + ex1_multdiv_val_q'length;
constant ex2_div_coll_offset                       : integer := ex1_recirc_ctr_flush_offset    + 1;
constant ex2_div_val_offset                        : integer := ex2_div_coll_offset            + 1;
constant ex2_multdiv_val_offset                    : integer := ex2_div_val_offset             + ex2_div_val_q'length;
constant ex3_div_val_offset                        : integer := ex2_multdiv_val_offset         + ex2_multdiv_val_q'length;
constant ex3_multdiv_val_offset                    : integer := ex3_div_val_offset             + ex3_div_val_q'length;
constant ex4_div_val_offset                        : integer := ex3_multdiv_val_offset         + ex3_multdiv_val_q'length;
constant ex5_div_val_offset                        : integer := ex4_div_val_offset             + ex4_div_val_q'length;
constant ex6_div_barr_val_offset                   : integer := ex5_div_val_offset             + ex5_div_val_q'length;
constant ex6_set_barr_offset                       : integer := ex6_div_barr_val_offset        + 1;
constant an_ac_back_inv_offset                     : integer := ex6_set_barr_offset            + ex6_set_barr_q'length;
constant an_ac_back_inv_addr_offset                : integer := an_ac_back_inv_offset          + 1;
constant an_ac_back_inv_target_bit3_offset         : integer := an_ac_back_inv_addr_offset     + an_ac_back_inv_addr_q'length;
constant back_inv_val_offset                       : integer := an_ac_back_inv_target_bit3_offset + 1;
constant coll_tid_offset                           : integer := back_inv_val_offset            + 1;
constant div_barr_done_offset                      : integer := coll_tid_offset                + coll_tid_q'length;
constant div_barr_thres_offset                     : integer := div_barr_done_offset           + div_barr_done_q'length;
constant div_coll_barr_done_offset                 : integer := div_barr_thres_offset          + div_barr_thres_q'length;
constant hold_divide_offset                        : integer := div_coll_barr_done_offset      + div_coll_barr_done_q'length;
constant hold_error_offset                         : integer := hold_divide_offset             + 1;
constant hold_ifar_offset                          : integer := hold_error_offset              + hold_error_q'length;
constant hold_instr_offset                         : integer := hold_ifar_offset               + hold_ifar_q'length;
constant hold_is_ucode_offset                      : integer := hold_instr_offset              + hold_instr_q'length;
constant hold_match_offset                         : integer := hold_is_ucode_offset           + 1;
constant hold_s1_offset                            : integer := hold_match_offset              + 1;
constant hold_s1_vld_offset                        : integer := hold_s1_offset                 + hold_s1_q'length;
constant hold_s2_offset                            : integer := hold_s1_vld_offset             + 1;
constant hold_s2_vld_offset                        : integer := hold_s2_offset                 + hold_s2_q'length;
constant hold_s3_offset                            : integer := hold_s2_vld_offset             + 1;
constant hold_s3_vld_offset                        : integer := hold_s3_offset                 + hold_s3_q'length;
constant hold_ta_offset                            : integer := hold_s3_vld_offset             + 1;
constant hold_ta_vld_offset                        : integer := hold_ta_offset                 + hold_ta_q'length;
constant hold_tid_offset                           : integer := hold_ta_vld_offset             + 1;
constant hold_use_imm_offset                       : integer := hold_tid_offset                + hold_tid_q'length;
constant lsu_xu_rel_ta_gpr_offset                  : integer := hold_use_imm_offset            + 1;
constant lsu_xu_rel_wren_offset                    : integer := lsu_xu_rel_ta_gpr_offset       + lsu_xu_rel_ta_gpr_q'length;
constant spare_0_offset                            : integer := lsu_xu_rel_wren_offset         + 1;
constant spare_1_offset                            : integer := spare_0_offset                         + spare_0_q'length;
constant scan_right                                : integer := spare_1_offset                         + spare_1_q'length;
signal siv                                                              : std_ulogic_vector(0 to scan_right-1);
signal sov                                                              : std_ulogic_vector(0 to scan_right-1);
signal spare_0_lclk                                                     : clk_logic;
signal spare_1_lclk                                                     : clk_logic;
signal spare_0_d1clk, spare_0_d2clk                                     : std_ulogic;
signal spare_1_d1clk, spare_1_d2clk                                     : std_ulogic;
signal rf0_is_mfocrf                                                    : std_ulogic;
signal rf0_valid                                                        : std_ulogic;
signal rf0_hold_latch_act                                               : std_ulogic;
signal rf0_multicyc_op                                                  : std_ulogic;
signal rf0_singlcyc_op                                                  : std_ulogic;
signal rf0_recirc_ctr_init                                              : std_ulogic_vector(0 to 7);
signal rf0_recirc_ctr_done                                              : std_ulogic;
signal rf0_recirc_ctr_start                                             : std_ulogic;
signal rf0_divide,                 rf0_multiply                         : std_ulogic;
signal rf0_muldiv_in_use,          rf1_muldiv_in_use                    : std_ulogic;
signal rf0_div_coll                                                     : std_ulogic;
signal rf0_derat_is_extload,       rf0_derat_is_extstore                : std_ulogic;
signal rf0_axu_is_extload,         rf0_axu_is_extstore                  : std_ulogic;
signal rf0_thread_num                                                   : std_ulogic_vector(0 to 1);
signal icswx_val                                                        : std_ulogic_vector(0 to threads-1);
signal icswx_thrd_dec                                                   : std_ulogic_vector(0 to threads-1);
signal rf0_3source_instr                                                : std_ulogic;
signal rf0_gpr0_zero                                                    : std_ulogic;
signal rf0_axu_gpr0_zero                                                : std_ulogic;
signal ex5_div_barr_val                                                 : std_ulogic;
signal rf0_recirc_ctr_dec                                               : std_ulogic_vector(0 to 7);
signal rf0_recirc_ctr_clear                                             : std_ulogic;
signal rf1_barrier_en                                                   : std_ulogic;
signal rf1_barrier_done                                                 : std_ulogic_vector(0 to threads-1);
signal rf0_div_valid                                                    : std_ulogic;
signal ex5_div_val                                                      : std_ulogic_vector(0 to threads-1);
signal rf1_hold_tid_flush                                               : std_ulogic;
signal rf0_tid                                                          : std_ulogic_vector(0 to threads-1);
signal rf0_use_imm                                                      : std_ulogic;
signal is2_act                                                          : std_ulogic;
signal rf0_instr                                                        : std_ulogic_vector(0 to 31);
  BEGIN 

fxa_fxb_rf0_spr_tid                  <=  rf0_tid or rf0_ucode_val_q;
fxa_fxb_rf0_cpl_act                  <=  or_reduce(rf0_tid or rf0_ucode_val_q);
fxa_fxb_rf0_cpl_tid                  <=  rf0_tid_q;
fxa_fxb_rf0_is_mfocrf                <=  rf0_is_mfocrf;
fxa_fxb_rf0_3src_instr               <=  rf0_3source_instr and not rf0_recirc_ctr_done;
fxa_fxb_rf0_gpr0_zero                <=  (rf0_gpr0_zero or rf0_axu_gpr0_zero) and not rf0_recirc_ctr_done;
rf0_axu_gpr0_zero                    <=  rf0_axu_ld_or_st_q and not or_reduce(rf0_s1_q);
dec_spr_rf0_instr                    <=  rf0_instr;
fxa_fxb_rf0_instr                    <=  rf0_instr;
mark_unused(spr_xucr0_clkg_ctl_b0);
is2_act                      <=  '1';
rf0_ucode_val_d              <=  iu_xu_is2_tid and (0 to threads-1=>iu_xu_is2_ucode_vld) and not xu_is2_flush;
rf0_val_d                    <=  iu_xu_is2_tid and (0 to threads-1=>iu_xu_is2_vld)       and not xu_is2_flush;
rf0_ta_vld_d                 <=  iu_xu_is2_ta_vld and or_reduce(iu_xu_is2_tid and (0 to threads-1=> iu_xu_is2_vld)                         and not xu_is2_flush);
rf0_s1_vld_d                 <=  iu_xu_is2_s1_vld and or_reduce(iu_xu_is2_tid and (0 to threads-1=>(iu_xu_is2_vld or iu_xu_is2_ucode_vld)) and not xu_is2_flush);
rf0_s2_vld_d                 <=  iu_xu_is2_s2_vld and or_reduce(iu_xu_is2_tid and (0 to threads-1=>(iu_xu_is2_vld or iu_xu_is2_ucode_vld)) and not xu_is2_flush);
rf0_s3_vld_d                 <=  iu_xu_is2_s3_vld and or_reduce(iu_xu_is2_tid and (0 to threads-1=>(iu_xu_is2_vld or iu_xu_is2_ucode_vld)) and not xu_is2_flush);
 WITH s2'(rf0_recirc_ctr_start & rf0_recirc_ctr_done)  SELECT         fxa_fxb_rf0_val          <=  "0000"                               when "10",
                                   hold_tid_q and not xu_rf0_flush      when "01",
                                   rf0_val_q  and not xu_rf0_flush      when others;
 WITH s2'(rf0_recirc_ctr_start & (rf0_recirc_ctr_done or rf0_recirc_ctr_flush))  SELECT         fxa_fxb_rf0_issued      <=  "0000"                                when "10",
                                   hold_tid_q                           when "01",
                                  (rf0_val_q or rf0_ucode_val_q)        when others;
 WITH s2'(rf0_recirc_ctr_start & rf0_recirc_ctr_done)  SELECT         fxa_fxb_rf0_ta_vld       <=  '0'                                  when "10",
                                   hold_ta_vld_q                        when "01",
                                   rf0_ta_vld_q                         when others;
fxa_fxb_rf0_ucode_val        <=  rf0_ucode_val_q and not xu_rf0_flush;
fxa_fxb_rf0_act              <=  or_reduce(rf0_val_q) or or_reduce(rf0_ucode_val_q) or rf0_recirc_ctr_done;
 WITH rf0_tid_q(0 to 3)  SELECT        rf0_thread_num                  <=  "11" when "0001",
                                         "10" when "0010",
                                         "01" when "0100",
                                         "00" when others;
rf0_valid                      <=  or_reduce(rf0_val_q and not xu_rf0_flush);
rf1_muldiv_in_use              <=  or_reduce(rf1_recirc_ctr_q);
rf0_muldiv_in_use              <=  rf1_muldiv_in_use or rf0_recirc_ctr_start;
fxa_perf_muldiv_in_use         <=  ex1_muldiv_in_use_q;
rf1_hold_tid_flush             <=  or_reduce(hold_tid_q and xu_rf1_flush);
rf0_recirc_ctr_flush           <=  rf1_muldiv_in_use and rf1_hold_tid_flush;
rf0_recirc_ctr_clear           <=  rf0_recirc_ctr_flush or not (rf0_muldiv_in_use);
rf0_recirc_ctr_start           <=  rf0_valid and not rf1_muldiv_in_use and  rf0_multicyc_op;
rf0_muldiv_coll                <=  rf0_valid and     rf1_muldiv_in_use and (rf0_multicyc_op or rf0_singlcyc_op);
rf0_div_coll                   <=  rf0_muldiv_coll      and rf0_divide;
with rf0_recirc_ctr_start select
      rf0_recirc_ctr_dec          <=  rf0_recirc_ctr_init                                 when '1',
                                    std_ulogic_vector(unsigned(rf1_recirc_ctr_q) - 1)   when others;
with rf0_recirc_ctr_clear select
      rf1_recirc_ctr_d            <=  (others=>'0')              when '1',
                                    rf0_recirc_ctr_dec         when others;
rf0_recirc_ctr_done            <=  '1' when (rf1_recirc_ctr_q = "00000001") else '0';
rf0_barrier_done               <=  hold_divide_q and (rf0_recirc_ctr_done or (rf0_recirc_ctr_flush and ex5_div_barr_val));
rf1_barrier_done               <=  (others=>rf1_barrier_done_q);
fxa_iu_set_barr_tid            <=  ex6_set_barr_q;
ex5_set_barr                   <=  gate(cpl_fxa_ex5_set_barr,rf1_muldiv_in_use);
coll_tid_d                     <=  (coll_tid_q or ex5_set_barr) and not rf1_barrier_done;
div_coll_barr_done_d           <=  (coll_tid_q or ex5_set_barr)  and not (0 to threads-1=>rf1_muldiv_in_use);
div_barr_done_d                <=  (hold_tid_q                   and     rf1_barrier_done) or
                                     icswx_val;
xu_div_coll_barr_done          <=  div_coll_barr_done_q;
xu_div_barr_done               <=  div_barr_done_q;
rf0_hold_latch_act             <=  rf0_recirc_ctr_start;
rf0_mul_valid                  <=  rf0_valid and rf0_multiply and not rf1_muldiv_in_use;
rf0_div_valid                  <=  rf0_valid and rf0_divide   and not rf1_muldiv_in_use;
fxa_fxb_rf1_div_val            <=  or_reduce(rf1_div_val_q);
fxa_fxb_rf1_mul_val            <=  rf1_mul_valid_q;
fxa_fxb_rf1_div_ctr            <=  rf1_recirc_ctr_q;
fxa_fxb_ex1_hold_ctr_flush     <=  ex1_recirc_ctr_flush_q;
rf1_barrier_en           <=  '1' when (rf1_recirc_ctr_q > div_barr_thres_q) else '0';
rf1_div_coll_d           <=  rf0_div_coll   and or_reduce(rf0_tid_q and not coll_tid_q) and not rf1_hold_tid_flush;
ex1_div_coll_d           <=  rf1_div_coll_q and rf1_barrier_en and hold_divide_q        and not rf1_hold_tid_flush;
ex2_div_coll_d           <=  ex1_div_coll_q                                             and not rf1_hold_tid_flush;
fxa_cpl_ex2_div_coll     <=  gate(hold_tid_q,ex2_div_coll_q);
fxa_fxb_rf1_muldiv_coll  <=  rf1_muldiv_coll_q;
rf0_div_val          <=  gate(rf0_val_q,rf0_div_valid);
ex1_div_val_d        <=  rf1_div_val_q and not xu_rf1_flush;
ex2_div_val_d        <=  ex1_div_val_q and not xu_ex1_flush;
ex3_div_val_d        <=  ex2_div_val_q and not xu_ex2_flush;
ex4_div_val_d        <=  ex3_div_val_q and not xu_ex3_flush;
ex5_div_val_d        <=  ex4_div_val_q and not xu_ex4_flush;
ex5_div_val          <=  ex5_div_val_q and not xu_ex5_flush;
ex5_div_barr_val     <= (or_reduce(ex5_div_val)) or
                         (ex6_div_barr_val_q and rf1_muldiv_in_use);
rf0_multdiv_val          <=  gate(rf0_val_q,rf0_recirc_ctr_start);
ex1_multdiv_val_d        <=  rf1_multdiv_val_q and not xu_rf1_flush;
ex2_multdiv_val_d        <=  ex1_multdiv_val_q and not xu_ex1_flush;
ex3_multdiv_val_d        <=  ex2_multdiv_val_q and not xu_ex2_flush;
fxa_fxb_rf0_mc_dep_chk_val           <=  rf0_multdiv_val;
dec_cpl_ex3_mc_dep_chk_val           <=  ex3_multdiv_val_q;
hold_tid_d                   <=  rf0_tid_q;
hold_instr_d                 <=  rf0_instr_q;
hold_ta_vld_d                <=  rf0_ta_vld_q;
hold_ta_d                    <=  rf0_ta_q & rf0_thread_num;
hold_error_d                 <=  rf0_error_q;
hold_match_d                 <=  rf0_match_q;
hold_is_ucode_d              <=  rf0_is_ucode_q;
hold_ifar_d                  <=  rf0_ifar_q;
hold_s1_d                    <=  rf0_s1_q & rf0_thread_num;
hold_s2_d                    <=  rf0_s2_q & rf0_thread_num;
hold_s3_d                    <=  rf0_s3_q & rf0_thread_num;
hold_s1_vld_d                <=  rf0_s1_vld_q;
hold_s2_vld_d                <=  rf0_s2_vld_q;
hold_s3_vld_d                <=  rf0_s3_vld_q;
hold_use_imm_d               <=  rf0_use_imm;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_tid          <= (rf0_val_q or rf0_ucode_val_q)    when '0',
                                   hold_tid_q                       when others;
with rf0_recirc_ctr_done select
                rf0_instr        <=  rf0_instr_q                      when '0',
                                   hold_instr_q                     when others;
with rf0_recirc_ctr_done select
        rf0_tid                  <=  rf0_tid_q                        when '0',
                                   hold_tid_q                       when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_ta           <=  rf0_ta_q & rf0_thread_num        when '0',
                                   hold_ta_q                        when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_error        <=  rf0_error_q                      when '0',
                                   hold_error_q                     when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_match        <=  rf0_match_q                      when '0',
                                   hold_match_q                     when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_is_ucode     <=  rf0_is_ucode_q                   when '0',
                                   hold_is_ucode_q                  when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_ifar          <=  rf0_ifar_q                       when '0',
                                   hold_ifar_q                      when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_s1           <=  rf0_s1_q & rf0_thread_num        when '0',
                                   hold_s1_q                        when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_s2           <=  rf0_s2_q & rf0_thread_num        when '0',
                                   hold_s2_q                        when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_s3           <=  rf0_s3_q & rf0_thread_num        when '0',
                                   hold_s3_q                        when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_s1_vld       <=  rf0_s1_vld_q                     when '0',
                                   hold_s1_vld_q                    when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_s2_vld       <=  rf0_s2_vld_q                     when '0',
                                   hold_s2_vld_q                    when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_s3_vld        <=  rf0_s3_vld_q                     when '0',
                                   hold_s3_vld_q                    when others;
with rf0_recirc_ctr_done select
        fxa_fxb_rf0_use_imm       <=  rf0_use_imm                     when '0',
                                   hold_use_imm_q                   when others;
fxa_fxb_rf0_axu_ld_or_st            <=  rf0_axu_ld_or_st_q   and not rf0_recirc_ctr_done;
fxa_fxb_rf0_axu_store               <=  rf0_axu_store_q      and not rf0_recirc_ctr_done;
fxa_fxb_rf0_axu_mftgpr              <=  rf0_axu_mftgpr_q     and not rf0_recirc_ctr_done;
fxa_fxb_rf0_axu_mffgpr              <=  rf0_axu_mffgpr_q     and not rf0_recirc_ctr_done;
fxa_fxb_rf0_axu_movedp              <=  rf0_axu_movedp_q     and not rf0_recirc_ctr_done;
fxa_fxb_rf0_pred_update             <=  rf0_pred_update_q    and not rf0_recirc_ctr_done;
fxa_fxb_rf0_gshare                  <=  rf0_gshare_q;
fxa_fxb_rf0_axu_instr_type          <=  rf0_axu_instr_type_q;
fxa_fxb_rf0_axu_ldst_forcealign     <=  rf0_axu_ldst_forcealign_q;
fxa_fxb_rf0_axu_ldst_forceexcept    <=  rf0_axu_ldst_forceexcept_q;
fxa_fxb_rf0_axu_ldst_indexed        <=  rf0_axu_ldst_indexed_q;
fxa_fxb_rf0_axu_ldst_tag            <=  rf0_axu_ldst_tag_q;
fxa_fxb_rf0_axu_ldst_size           <=  rf0_axu_ldst_size_q;
fxa_fxb_rf0_axu_ldst_update         <=  rf0_axu_ldst_update_q;
fxa_fxb_rf0_pred_taken_cnt          <=  rf0_pred_taken_cnt_q;
 WITH an_ac_back_inv_addr_q(62 to 63)  SELECT         icswx_thrd_dec           <=  "1000"   when "00",
                                   "0100"   when "01",
                                   "0010"   when "10",
                                   "0001"   when others;
back_inv_val_d               <=  an_ac_back_inv_q and an_ac_back_inv_target_bit3_q;
icswx_val                    <=  gate(icswx_thrd_dec, back_inv_val_q);
dec_gpr_rf0_re0              <=  rf0_s1_vld_q;
dec_gpr_rf0_re1              <=  rf0_s2_vld_q;
dec_gpr_rf0_re2              <=  rf0_s3_vld_q;
dec_gpr_rf0_ra0              <=  rf0_s1_q & rf0_thread_num;
dec_gpr_rf0_ra1              <=  rf0_s2_q & rf0_thread_num;
dec_gpr_rf0_ra2              <=  rf0_s3_q & rf0_thread_num;
dec_gpr_rel_wren             <=  lsu_xu_rel_wren_q;
dec_gpr_rel_ta_gpr           <=  lsu_xu_rel_ta_gpr_q;
rf0_axu_is_extload               <=  rf0_axu_ldst_extpid_q and ((rf0_axu_ld_or_st_q and not (rf0_axu_mftgpr_q or rf0_axu_mffgpr_q)) and not rf0_axu_store_q);
rf0_axu_is_extstore              <=  rf0_axu_ldst_extpid_q and ((rf0_axu_ld_or_st_q and not (rf0_axu_mftgpr_q or rf0_axu_mffgpr_q)) and     rf0_axu_store_q);
xu_lsu_rf0_derat_is_extload      <=  rf0_derat_is_extload  or rf0_axu_is_extload;
xu_lsu_rf0_derat_is_extstore     <=  rf0_derat_is_extstore or rf0_axu_is_extstore;
fxa_fxb_rf0_xu_epid_instr        <=  not rf0_recirc_ctr_done and (rf0_derat_is_extload or rf0_derat_is_extstore);
fxa_fxb_rf0_axu_is_extload       <=  not rf0_recirc_ctr_done and  rf0_axu_is_extload;
fxa_fxb_rf0_axu_is_extstore      <=  not rf0_recirc_ctr_done and  rf0_axu_is_extstore;
xu_lsu_rf0_derat_val         <=  rf0_val_q or rf0_ucode_val_q;
dec_debug(0 TO 87) <=  rf0_val_q                  &     
                           rf0_instr_q(0 to 5)        &     
                           rf0_instr_q(21 to 30)      &     
                           hold_instr_q(0 to 5)       &     
                           hold_instr_q(21 to 30)     &     
                           rf0_ta_vld_q               &     
                           rf0_s1_vld_q               &     
                           rf0_s2_vld_q               &     
                           rf0_s3_vld_q               &     
                           xu_rf0_flush               &     
                           hold_ta_vld_q              &     
                           ex1_recirc_ctr_flush_q     &     
                           rf0_recirc_ctr_start       &     
                           rf0_recirc_ctr_done        &     
                           rf1_recirc_ctr_q           &     
                           hold_tid_q                 &     
                           rf0_divide                 &     
                           rf0_multiply               &     
                           rf1_barrier_done_q         &     
                           ex6_set_barr_q             &     
                           coll_tid_q                 &     
                           div_coll_barr_done_q       &     
                           div_barr_done_q            &     
                           rf1_muldiv_coll_q          &     
                           rf1_div_coll_q             &     
                           ex1_div_coll_q             &     
                           cpl_fxa_ex5_set_barr       &     
                           ex5_div_barr_val           &     
                           back_inv_val_q;
dec_debug(88 TO 175) <=  rf0_val_q                  &     
                           rf0_instr_q                &     
                           rf0_ta_q                   &     
                           rf0_error_q                &     
                           rf0_match_q                &     
                           rf0_is_ucode_q             &     
                           rf0_s1_vld_q               &     
                           rf0_s2_vld_q               &     
                           rf0_s3_vld_q               &     
                           rf0_axu_ld_or_st_q         &     
                           rf0_axu_store_q            &     
                           rf0_axu_mftgpr_q           &     
                           rf0_axu_mffgpr_q           &     
                           rf0_axu_movedp_q           &     
                           rf0_pred_update_q          &     
                           rf0_gshare_q               &     
                           rf0_axu_instr_type_q       &     
                           rf0_axu_ldst_forcealign_q  &     
                           rf0_axu_ldst_forceexcept_q &     
                           rf0_axu_ldst_indexed_q     &     
                           rf0_axu_ldst_tag_q         &     
                           rf0_axu_ldst_size_q        &     
                           rf0_axu_ldst_update_q      &     
                           rf0_pred_taken_cnt_q       &     
                           rf0_recirc_ctr_done        &     
                           rf0_recirc_ctr_start       &     
                           rf1_muldiv_coll_q          &     
                           back_inv_val_q;
MQQ1:TBL_RF0_DEC_PT(1) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(11) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("01111110000010011"));
MQQ2:TBL_RF0_DEC_PT(2) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111111101001"));
MQQ3:TBL_RF0_DEC_PT(3) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111011101011"));
MQQ4:TBL_RF0_DEC_PT(4) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100001011"));
MQQ5:TBL_RF0_DEC_PT(5) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111011101001"));
MQQ6:TBL_RF0_DEC_PT(6) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111111001001"));
MQQ7:TBL_RF0_DEC_PT(7) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100001001"));
MQQ8:TBL_RF0_DEC_PT(8) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111111001011"));
MQQ9:TBL_RF0_DEC_PT(9) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111111101011"));
MQQ10:TBL_RF0_DEC_PT(10) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111111101001"));
MQQ11:TBL_RF0_DEC_PT(11) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("000111"));
MQQ12:RF0_RECIRC_CTR_INIT(0) <= 
    (TBL_RF0_DEC_PT(6));
MQQ13:RF0_RECIRC_CTR_INIT(1) <= 
    (TBL_RF0_DEC_PT(8) OR TBL_RF0_DEC_PT(10)
    );
MQQ14:RF0_RECIRC_CTR_INIT(2) <= 
    (TBL_RF0_DEC_PT(9));
MQQ15:RF0_RECIRC_CTR_INIT(3) <= 
    ('0');
MQQ16:RF0_RECIRC_CTR_INIT(4) <= 
    ('0');
MQQ17:RF0_RECIRC_CTR_INIT(5) <= 
    ('0');
MQQ18:RF0_RECIRC_CTR_INIT(6) <= 
    (TBL_RF0_DEC_PT(5) OR TBL_RF0_DEC_PT(7)
    );
MQQ19:RF0_RECIRC_CTR_INIT(7) <= 
    (TBL_RF0_DEC_PT(2) OR TBL_RF0_DEC_PT(6)
     OR TBL_RF0_DEC_PT(7) OR TBL_RF0_DEC_PT(8)
     OR TBL_RF0_DEC_PT(9) OR TBL_RF0_DEC_PT(10)
     OR TBL_RF0_DEC_PT(11));
MQQ20:RF0_SINGLCYC_OP <= 
    (TBL_RF0_DEC_PT(3) OR TBL_RF0_DEC_PT(4)
    );
MQQ21:RF0_MULTICYC_OP <= 
    (TBL_RF0_DEC_PT(5) OR TBL_RF0_DEC_PT(6)
     OR TBL_RF0_DEC_PT(7) OR TBL_RF0_DEC_PT(8)
     OR TBL_RF0_DEC_PT(9) OR TBL_RF0_DEC_PT(10)
     OR TBL_RF0_DEC_PT(11));
MQQ22:RF0_DIVIDE <= 
    (TBL_RF0_DEC_PT(6) OR TBL_RF0_DEC_PT(8)
     OR TBL_RF0_DEC_PT(9) OR TBL_RF0_DEC_PT(10)
    );
MQQ23:RF0_MULTIPLY <= 
    (TBL_RF0_DEC_PT(3) OR TBL_RF0_DEC_PT(4)
     OR TBL_RF0_DEC_PT(5) OR TBL_RF0_DEC_PT(7)
     OR TBL_RF0_DEC_PT(11));
MQQ24:RF0_IS_MFOCRF <= 
    (TBL_RF0_DEC_PT(1));

MQQ25:TBL_RF0_EPID_DEC_PT(1) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111110110110"));
MQQ26:TBL_RF0_EPID_DEC_PT(2) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111111111111"));
MQQ27:TBL_RF0_EPID_DEC_PT(3) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111111011111"));
MQQ28:TBL_RF0_EPID_DEC_PT(4) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111000001111"));
MQQ29:TBL_RF0_EPID_DEC_PT(5) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001001111"));
MQQ30:TBL_RF0_EPID_DEC_PT(6) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100011111"));
MQQ31:TBL_RF0_EPID_DEC_PT(7) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100011111"));
MQQ32:TBL_RF0_EPID_DEC_PT(8) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001111111"));
MQQ33:TBL_RF0_EPID_DEC_PT(9) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111010011111"));
MQQ34:RF0_DERAT_IS_EXTLOAD <= 
    (TBL_RF0_EPID_DEC_PT(3) OR TBL_RF0_EPID_DEC_PT(4)
     OR TBL_RF0_EPID_DEC_PT(6) OR TBL_RF0_EPID_DEC_PT(7)
    );
MQQ35:RF0_DERAT_IS_EXTSTORE <= 
    (TBL_RF0_EPID_DEC_PT(1) OR TBL_RF0_EPID_DEC_PT(2)
     OR TBL_RF0_EPID_DEC_PT(5) OR TBL_RF0_EPID_DEC_PT(8)
     OR TBL_RF0_EPID_DEC_PT(9));

MQQ36:TBL_3SRC_DEC_PT(1) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29)
     ) , STD_ULOGIC_VECTOR'("01111101001011"));
MQQ37:TBL_3SRC_DEC_PT(2) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111111111010010"));
MQQ38:TBL_3SRC_DEC_PT(3) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111111010110"));
MQQ39:TBL_3SRC_DEC_PT(4) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111101001010"));
MQQ40:TBL_3SRC_DEC_PT(5) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100100111"));
MQQ41:TBL_3SRC_DEC_PT(6) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100101011"));
MQQ42:TBL_3SRC_DEC_PT(7) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100101111"));
MQQ43:TBL_3SRC_DEC_PT(8) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111100110111"));
MQQ44:TBL_3SRC_DEC_PT(9) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111101001111"));
MQQ45:TBL_3SRC_DEC_PT(10) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("01111101010111"));
MQQ46:TBL_3SRC_DEC_PT(11) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29)
     ) , STD_ULOGIC_VECTOR'("01111100101011"));
MQQ47:TBL_3SRC_DEC_PT(12) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04)
     ) , STD_ULOGIC_VECTOR'("1010"));
MQQ48:TBL_3SRC_DEC_PT(13) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("1111100"));
MQQ49:TBL_3SRC_DEC_PT(14) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ50:TBL_3SRC_DEC_PT(15) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("1011"));
MQQ51:RF0_3SOURCE_INSTR <= 
    (TBL_3SRC_DEC_PT(1) OR TBL_3SRC_DEC_PT(2)
     OR TBL_3SRC_DEC_PT(3) OR TBL_3SRC_DEC_PT(4)
     OR TBL_3SRC_DEC_PT(5) OR TBL_3SRC_DEC_PT(6)
     OR TBL_3SRC_DEC_PT(7) OR TBL_3SRC_DEC_PT(8)
     OR TBL_3SRC_DEC_PT(9) OR TBL_3SRC_DEC_PT(10)
     OR TBL_3SRC_DEC_PT(11) OR TBL_3SRC_DEC_PT(12)
     OR TBL_3SRC_DEC_PT(13) OR TBL_3SRC_DEC_PT(14)
     OR TBL_3SRC_DEC_PT(15));

MQQ52:TBL_GPR0_ZERO_PT(1) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111001000110000000"));
MQQ53:TBL_GPR0_ZERO_PT(2) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_S1_Q(00) & 
    RF0_S1_Q(01) & RF0_S1_Q(02) & 
    RF0_S1_Q(03) & RF0_S1_Q(04) & 
    RF0_S1_Q(05) ) , STD_ULOGIC_VECTOR'("0111100000101000000"));
MQQ54:TBL_GPR0_ZERO_PT(3) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("011110001011000000"));
MQQ55:TBL_GPR0_ZERO_PT(4) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111001110110000000"));
MQQ56:TBL_GPR0_ZERO_PT(5) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111111110110000000"));
MQQ57:TBL_GPR0_ZERO_PT(6) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("011110001011000000"));
MQQ58:TBL_GPR0_ZERO_PT(7) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("011110001111000000"));
MQQ59:TBL_GPR0_ZERO_PT(8) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) & RF0_S1_Q(00) & 
    RF0_S1_Q(01) & RF0_S1_Q(02) & 
    RF0_S1_Q(03) & RF0_S1_Q(04) & 
    RF0_S1_Q(05) ) , STD_ULOGIC_VECTOR'("0111111010110000000"));
MQQ60:TBL_GPR0_ZERO_PT(9) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(30) & RF0_S1_Q(00) & 
    RF0_S1_Q(01) & RF0_S1_Q(02) & 
    RF0_S1_Q(03) & RF0_S1_Q(04) & 
    RF0_S1_Q(05) ) , STD_ULOGIC_VECTOR'("0111110001010000000"));
MQQ61:TBL_GPR0_ZERO_PT(10) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111110110011000000"));
MQQ62:TBL_GPR0_ZERO_PT(11) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111111010110000000"));
MQQ63:TBL_GPR0_ZERO_PT(12) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) & RF0_S1_Q(00) & 
    RF0_S1_Q(01) & RF0_S1_Q(02) & 
    RF0_S1_Q(03) & RF0_S1_Q(04) & 
    RF0_S1_Q(05) ) , STD_ULOGIC_VECTOR'("0111111111111000000"));
MQQ64:TBL_GPR0_ZERO_PT(13) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111110010010000000"));
MQQ65:TBL_GPR0_ZERO_PT(14) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("0111110010100011"));
MQQ66:TBL_GPR0_ZERO_PT(15) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111011100110000000"));
MQQ67:TBL_GPR0_ZERO_PT(16) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("011111001101110"));
MQQ68:TBL_GPR0_ZERO_PT(17) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) & RF0_S1_Q(00) & 
    RF0_S1_Q(01) & RF0_S1_Q(02) & 
    RF0_S1_Q(03) & RF0_S1_Q(04) & 
    RF0_S1_Q(05) ) , STD_ULOGIC_VECTOR'("0111111001010000000"));
MQQ69:TBL_GPR0_ZERO_PT(18) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("011110001111000000"));
MQQ70:TBL_GPR0_ZERO_PT(19) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) & RF0_S1_Q(00) & 
    RF0_S1_Q(01) & RF0_S1_Q(02) & 
    RF0_S1_Q(03) & RF0_S1_Q(04) & 
    RF0_S1_Q(05) ) , STD_ULOGIC_VECTOR'("011110000110011000000"));
MQQ71:TBL_GPR0_ZERO_PT(20) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) & RF0_S1_Q(00) & 
    RF0_S1_Q(01) & RF0_S1_Q(02) & 
    RF0_S1_Q(03) & RF0_S1_Q(04) & 
    RF0_S1_Q(05) ) , STD_ULOGIC_VECTOR'("0111110010101000000"));
MQQ72:TBL_GPR0_ZERO_PT(21) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("011110011111000000"));
MQQ73:TBL_GPR0_ZERO_PT(22) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("011110000111000000"));
MQQ74:TBL_GPR0_ZERO_PT(23) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111010101011000000"));
MQQ75:TBL_GPR0_ZERO_PT(24) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) & RF0_S1_Q(00) & 
    RF0_S1_Q(01) & RF0_S1_Q(02) & 
    RF0_S1_Q(03) & RF0_S1_Q(04) & 
    RF0_S1_Q(05) ) , STD_ULOGIC_VECTOR'("0111101000110000000"));
MQQ76:TBL_GPR0_ZERO_PT(25) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(30) & RF0_S1_Q(00) & 
    RF0_S1_Q(01) & RF0_S1_Q(02) & 
    RF0_S1_Q(03) & RF0_S1_Q(04) & 
    RF0_S1_Q(05) ) , STD_ULOGIC_VECTOR'("0111100101010000000"));
MQQ77:TBL_GPR0_ZERO_PT(26) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111000001010000000"));
MQQ78:TBL_GPR0_ZERO_PT(27) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111001001011000000"));
MQQ79:TBL_GPR0_ZERO_PT(28) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(05) & RF0_S1_Q(00) & 
    RF0_S1_Q(01) & RF0_S1_Q(02) & 
    RF0_S1_Q(03) & RF0_S1_Q(04) & 
    RF0_S1_Q(05) ) , STD_ULOGIC_VECTOR'("100000000"));
MQQ80:TBL_GPR0_ZERO_PT(29) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(21) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("01111000010110000000"));
MQQ81:TBL_GPR0_ZERO_PT(30) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(31) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("110100000000"));
MQQ82:TBL_GPR0_ZERO_PT(31) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(30) & RF0_INSTR_Q(31) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("111000000000"));
MQQ83:TBL_GPR0_ZERO_PT(32) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("0111101111000000"));
MQQ84:TBL_GPR0_ZERO_PT(33) <=
    Eq(( RF0_INSTR_Q(01) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04) & 
    RF0_S1_Q(00) & RF0_S1_Q(01) & 
    RF0_S1_Q(02) & RF0_S1_Q(03) & 
    RF0_S1_Q(04) & RF0_S1_Q(05)
     ) , STD_ULOGIC_VECTOR'("0111000000"));
MQQ85:RF0_GPR0_ZERO <= 
    (TBL_GPR0_ZERO_PT(1) OR TBL_GPR0_ZERO_PT(2)
     OR TBL_GPR0_ZERO_PT(3) OR TBL_GPR0_ZERO_PT(4)
     OR TBL_GPR0_ZERO_PT(5) OR TBL_GPR0_ZERO_PT(6)
     OR TBL_GPR0_ZERO_PT(7) OR TBL_GPR0_ZERO_PT(8)
     OR TBL_GPR0_ZERO_PT(9) OR TBL_GPR0_ZERO_PT(10)
     OR TBL_GPR0_ZERO_PT(11) OR TBL_GPR0_ZERO_PT(12)
     OR TBL_GPR0_ZERO_PT(13) OR TBL_GPR0_ZERO_PT(14)
     OR TBL_GPR0_ZERO_PT(15) OR TBL_GPR0_ZERO_PT(16)
     OR TBL_GPR0_ZERO_PT(17) OR TBL_GPR0_ZERO_PT(18)
     OR TBL_GPR0_ZERO_PT(19) OR TBL_GPR0_ZERO_PT(20)
     OR TBL_GPR0_ZERO_PT(21) OR TBL_GPR0_ZERO_PT(22)
     OR TBL_GPR0_ZERO_PT(23) OR TBL_GPR0_ZERO_PT(24)
     OR TBL_GPR0_ZERO_PT(25) OR TBL_GPR0_ZERO_PT(26)
     OR TBL_GPR0_ZERO_PT(27) OR TBL_GPR0_ZERO_PT(28)
     OR TBL_GPR0_ZERO_PT(29) OR TBL_GPR0_ZERO_PT(30)
     OR TBL_GPR0_ZERO_PT(31) OR TBL_GPR0_ZERO_PT(32)
     OR TBL_GPR0_ZERO_PT(33));

MQQ86:TBL_USE_IMM_PT(1) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(29) & RF0_INSTR_Q(30)
     ) , STD_ULOGIC_VECTOR'("011101101000"));
MQQ87:TBL_USE_IMM_PT(2) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111101010101"));
MQQ88:TBL_USE_IMM_PT(3) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111001000011"));
MQQ89:TBL_USE_IMM_PT(4) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(25) & 
    RF0_INSTR_Q(26) & RF0_INSTR_Q(27) & 
    RF0_INSTR_Q(28) & RF0_INSTR_Q(29) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111011010011"));
MQQ90:TBL_USE_IMM_PT(5) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(21) & RF0_INSTR_Q(22) & 
    RF0_INSTR_Q(23) & RF0_INSTR_Q(24) & 
    RF0_INSTR_Q(25) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("0111001001000"));
MQQ91:TBL_USE_IMM_PT(6) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(22) & RF0_INSTR_Q(23) & 
    RF0_INSTR_Q(24) & RF0_INSTR_Q(26) & 
    RF0_INSTR_Q(27) & RF0_INSTR_Q(28) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("01110110100"));
MQQ92:TBL_USE_IMM_PT(7) <=
    Eq(( RF0_INSTR_Q(01) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) ) , STD_ULOGIC_VECTOR'("001"));
MQQ93:TBL_USE_IMM_PT(8) <=
    Eq(( RF0_INSTR_Q(01) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("010"));
MQQ94:TBL_USE_IMM_PT(9) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(02) & RF0_INSTR_Q(03)
     ) , STD_ULOGIC_VECTOR'("0110"));
MQQ95:TBL_USE_IMM_PT(10) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(04)
     ) , STD_ULOGIC_VECTOR'("0110"));
MQQ96:TBL_USE_IMM_PT(11) <=
    Eq(( RF0_INSTR_Q(02) & RF0_INSTR_Q(03) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(31) ) , STD_ULOGIC_VECTOR'("10100"));
MQQ97:TBL_USE_IMM_PT(12) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(02) & 
    RF0_INSTR_Q(04) & RF0_INSTR_Q(05) & 
    RF0_INSTR_Q(30) ) , STD_ULOGIC_VECTOR'("11100"));
MQQ98:TBL_USE_IMM_PT(13) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01)
     ) , STD_ULOGIC_VECTOR'("10"));
MQQ99:TBL_USE_IMM_PT(14) <=
    Eq(( RF0_INSTR_Q(00) & RF0_INSTR_Q(01) & 
    RF0_INSTR_Q(03) & RF0_INSTR_Q(05)
     ) , STD_ULOGIC_VECTOR'("0100"));
MQQ100:TBL_USE_IMM_PT(15) <=
    Eq(( RF0_INSTR_Q(01) & RF0_INSTR_Q(04) & 
    RF0_INSTR_Q(05) ) , STD_ULOGIC_VECTOR'("011"));
MQQ101:RF0_USE_IMM <= 
    (TBL_USE_IMM_PT(1) OR TBL_USE_IMM_PT(2)
     OR TBL_USE_IMM_PT(3) OR TBL_USE_IMM_PT(4)
     OR TBL_USE_IMM_PT(5) OR TBL_USE_IMM_PT(6)
     OR TBL_USE_IMM_PT(7) OR TBL_USE_IMM_PT(8)
     OR TBL_USE_IMM_PT(9) OR TBL_USE_IMM_PT(10)
     OR TBL_USE_IMM_PT(11) OR TBL_USE_IMM_PT(12)
     OR TBL_USE_IMM_PT(13) OR TBL_USE_IMM_PT(14)
     OR TBL_USE_IMM_PT(15));

rf0_axu_instr_type_latch : tri_rlmreg_p
     generic map (width => rf0_axu_instr_type_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_instr_type_offset to rf0_axu_instr_type_offset + rf0_axu_instr_type_q'length-1),
               scout   => sov(rf0_axu_instr_type_offset to rf0_axu_instr_type_offset + rf0_axu_instr_type_q'length-1),
               din     => iu_xu_is2_axu_instr_type   ,
               dout    => rf0_axu_instr_type_q);
rf0_axu_ld_or_st_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_ld_or_st_offset),
               scout   => sov(rf0_axu_ld_or_st_offset),
               din     => iu_xu_is2_axu_ld_or_st     ,
               dout    => rf0_axu_ld_or_st_q);
rf0_axu_ldst_extpid_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_ldst_extpid_offset),
               scout   => sov(rf0_axu_ldst_extpid_offset),
               din     => iu_xu_is2_axu_ldst_extpid  ,
               dout    => rf0_axu_ldst_extpid_q);
rf0_axu_ldst_forcealign_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act            ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_ldst_forcealign_offset),
               scout   => sov(rf0_axu_ldst_forcealign_offset),
               din     => iu_xu_is2_axu_ldst_forcealign,
               dout    => rf0_axu_ldst_forcealign_q);
rf0_axu_ldst_forceexcept_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act           ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_ldst_forceexcept_offset),
               scout   => sov(rf0_axu_ldst_forceexcept_offset),
               din     => iu_xu_is2_axu_ldst_forceexcept,
               dout    => rf0_axu_ldst_forceexcept_q);
rf0_axu_ldst_indexed_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_ldst_indexed_offset),
               scout   => sov(rf0_axu_ldst_indexed_offset),
               din     => iu_xu_is2_axu_ldst_indexed ,
               dout    => rf0_axu_ldst_indexed_q);
rf0_axu_ldst_size_latch : tri_rlmreg_p
     generic map (width => rf0_axu_ldst_size_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_ldst_size_offset to rf0_axu_ldst_size_offset + rf0_axu_ldst_size_q'length-1),
               scout   => sov(rf0_axu_ldst_size_offset to rf0_axu_ldst_size_offset + rf0_axu_ldst_size_q'length-1),
               din     => iu_xu_is2_axu_ldst_size    ,
               dout    => rf0_axu_ldst_size_q);
rf0_axu_ldst_tag_latch : tri_rlmreg_p
     generic map (width => rf0_axu_ldst_tag_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_ldst_tag_offset to rf0_axu_ldst_tag_offset + rf0_axu_ldst_tag_q'length-1),
               scout   => sov(rf0_axu_ldst_tag_offset to rf0_axu_ldst_tag_offset + rf0_axu_ldst_tag_q'length-1),
               din     => iu_xu_is2_axu_ldst_tag     ,
               dout    => rf0_axu_ldst_tag_q);
rf0_axu_ldst_update_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_ldst_update_offset),
               scout   => sov(rf0_axu_ldst_update_offset),
               din     => iu_xu_is2_axu_ldst_update  ,
               dout    => rf0_axu_ldst_update_q);
rf0_axu_mffgpr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_mffgpr_offset),
               scout   => sov(rf0_axu_mffgpr_offset),
               din     => iu_xu_is2_axu_mffgpr       ,
               dout    => rf0_axu_mffgpr_q);
rf0_axu_mftgpr_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_mftgpr_offset),
               scout   => sov(rf0_axu_mftgpr_offset),
               din     => iu_xu_is2_axu_mftgpr       ,
               dout    => rf0_axu_mftgpr_q);
rf0_axu_movedp_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_movedp_offset),
               scout   => sov(rf0_axu_movedp_offset),
               din     => iu_xu_is2_axu_movedp       ,
               dout    => rf0_axu_movedp_q);
rf0_axu_store_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_axu_store_offset),
               scout   => sov(rf0_axu_store_offset),
               din     => iu_xu_is2_axu_store        ,
               dout    => rf0_axu_store_q);
rf0_error_latch : tri_rlmreg_p
     generic map (width => rf0_error_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_error_offset to rf0_error_offset + rf0_error_q'length-1),
               scout   => sov(rf0_error_offset to rf0_error_offset + rf0_error_q'length-1),
               din     => iu_xu_is2_error            ,
               dout    => rf0_error_q);
rf0_gshare_latch : tri_rlmreg_p
     generic map (width => rf0_gshare_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_gshare_offset to rf0_gshare_offset + rf0_gshare_q'length-1),
               scout   => sov(rf0_gshare_offset to rf0_gshare_offset + rf0_gshare_q'length-1),
               din     => iu_xu_is2_gshare           ,
               dout    => rf0_gshare_q);
rf0_ifar_latch : tri_rlmreg_p
     generic map (width => rf0_ifar_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_ifar_offset to rf0_ifar_offset + rf0_ifar_q'length-1),
               scout   => sov(rf0_ifar_offset to rf0_ifar_offset + rf0_ifar_q'length-1),
               din     => iu_xu_is2_ifar             ,
               dout    => rf0_ifar_q);
rf0_instr_latch : tri_rlmreg_p
     generic map (width => rf0_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_instr_offset to rf0_instr_offset + rf0_instr_q'length-1),
               scout   => sov(rf0_instr_offset to rf0_instr_offset + rf0_instr_q'length-1),
               din     => iu_xu_is2_instr            ,
               dout    => rf0_instr_q);
rf0_is_ucode_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_is_ucode_offset),
               scout   => sov(rf0_is_ucode_offset),
               din     => iu_xu_is2_is_ucode         ,
               dout    => rf0_is_ucode_q);
rf0_match_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_match_offset),
               scout   => sov(rf0_match_offset),
               din     => iu_xu_is2_match            ,
               dout    => rf0_match_q);
rf0_pred_taken_cnt_latch : tri_rlmreg_p
     generic map (width => rf0_pred_taken_cnt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_pred_taken_cnt_offset to rf0_pred_taken_cnt_offset + rf0_pred_taken_cnt_q'length-1),
               scout   => sov(rf0_pred_taken_cnt_offset to rf0_pred_taken_cnt_offset + rf0_pred_taken_cnt_q'length-1),
               din     => iu_xu_is2_pred_taken_cnt   ,
               dout    => rf0_pred_taken_cnt_q);
rf0_pred_update_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_pred_update_offset),
               scout   => sov(rf0_pred_update_offset),
               din     => iu_xu_is2_pred_update      ,
               dout    => rf0_pred_update_q);
rf0_s1_latch : tri_rlmreg_p
     generic map (width => rf0_s1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_s1_offset to rf0_s1_offset + rf0_s1_q'length-1),
               scout   => sov(rf0_s1_offset to rf0_s1_offset + rf0_s1_q'length-1),
               din     => iu_xu_is2_s1               ,
               dout    => rf0_s1_q);
rf0_s1_vld_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_s1_vld_offset),
               scout   => sov(rf0_s1_vld_offset),
               din     => rf0_s1_vld_d,
               dout    => rf0_s1_vld_q);
rf0_s2_latch : tri_rlmreg_p
     generic map (width => rf0_s2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_s2_offset to rf0_s2_offset + rf0_s2_q'length-1),
               scout   => sov(rf0_s2_offset to rf0_s2_offset + rf0_s2_q'length-1),
               din     => iu_xu_is2_s2               ,
               dout    => rf0_s2_q);
rf0_s2_vld_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_s2_vld_offset),
               scout   => sov(rf0_s2_vld_offset),
               din     => rf0_s2_vld_d,
               dout    => rf0_s2_vld_q);
rf0_s3_latch : tri_rlmreg_p
     generic map (width => rf0_s3_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_s3_offset to rf0_s3_offset + rf0_s3_q'length-1),
               scout   => sov(rf0_s3_offset to rf0_s3_offset + rf0_s3_q'length-1),
               din     => iu_xu_is2_s3               ,
               dout    => rf0_s3_q);
rf0_s3_vld_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_s3_vld_offset),
               scout   => sov(rf0_s3_vld_offset),
               din     => rf0_s3_vld_d,
               dout    => rf0_s3_vld_q);
rf0_ta_latch : tri_rlmreg_p
     generic map (width => rf0_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_ta_offset to rf0_ta_offset + rf0_ta_q'length-1),
               scout   => sov(rf0_ta_offset to rf0_ta_offset + rf0_ta_q'length-1),
               din     => iu_xu_is2_ta               ,
               dout    => rf0_ta_q);
rf0_ta_vld_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_ta_vld_offset),
               scout   => sov(rf0_ta_vld_offset),
               din     => rf0_ta_vld_d,
               dout    => rf0_ta_vld_q);
rf0_tid_latch : tri_rlmreg_p
     generic map (width => rf0_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => is2_act              ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_tid_offset to rf0_tid_offset + rf0_tid_q'length-1),
               scout   => sov(rf0_tid_offset to rf0_tid_offset + rf0_tid_q'length-1),
               din     => iu_xu_is2_tid              ,
               dout    => rf0_tid_q);
rf0_ucode_val_latch : tri_rlmreg_p
     generic map (width => rf0_ucode_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_ucode_val_offset to rf0_ucode_val_offset + rf0_ucode_val_q'length-1),
               scout   => sov(rf0_ucode_val_offset to rf0_ucode_val_offset + rf0_ucode_val_q'length-1),
               din     => rf0_ucode_val_d,
               dout    => rf0_ucode_val_q);
rf0_val_latch : tri_rlmreg_p
     generic map (width => rf0_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf0_val_offset to rf0_val_offset + rf0_val_q'length-1),
               scout   => sov(rf0_val_offset to rf0_val_offset + rf0_val_q'length-1),
               din     => rf0_val_d,
               dout    => rf0_val_q);
rf1_barrier_done_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_barrier_done_offset),
               scout   => sov(rf1_barrier_done_offset),
               din     => rf0_barrier_done,
               dout    => rf1_barrier_done_q);
rf1_div_coll_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_div_coll_offset),
               scout   => sov(rf1_div_coll_offset),
               din     => rf1_div_coll_d,
               dout    => rf1_div_coll_q);
rf1_div_val_latch : tri_rlmreg_p
     generic map (width => rf1_div_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_div_val_offset to rf1_div_val_offset + rf1_div_val_q'length-1),
               scout   => sov(rf1_div_val_offset to rf1_div_val_offset + rf1_div_val_q'length-1),
               din     => rf0_div_val,
               dout    => rf1_div_val_q);
rf1_mul_valid_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_mul_valid_offset),
               scout   => sov(rf1_mul_valid_offset),
               din     => rf0_mul_valid,
               dout    => rf1_mul_valid_q);
rf1_muldiv_coll_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_muldiv_coll_offset),
               scout   => sov(rf1_muldiv_coll_offset),
               din     => rf0_muldiv_coll,
               dout    => rf1_muldiv_coll_q);
rf1_multdiv_val_latch : tri_rlmreg_p
     generic map (width => rf1_multdiv_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_multdiv_val_offset to rf1_multdiv_val_offset + rf1_multdiv_val_q'length-1),
               scout   => sov(rf1_multdiv_val_offset to rf1_multdiv_val_offset + rf1_multdiv_val_q'length-1),
               din     => rf0_multdiv_val,
               dout    => rf1_multdiv_val_q);
rf1_recirc_ctr_latch : tri_rlmreg_p
     generic map (width => rf1_recirc_ctr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_recirc_ctr_offset to rf1_recirc_ctr_offset + rf1_recirc_ctr_q'length-1),
               scout   => sov(rf1_recirc_ctr_offset to rf1_recirc_ctr_offset + rf1_recirc_ctr_q'length-1),
               din     => rf1_recirc_ctr_d,
               dout    => rf1_recirc_ctr_q);
rf1_recirc_ctr_flush_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(rf1_recirc_ctr_flush_offset),
               scout   => sov(rf1_recirc_ctr_flush_offset),
               din     => rf0_recirc_ctr_flush,
               dout    => rf1_recirc_ctr_flush_q);
ex1_div_coll_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_div_coll_offset),
               scout   => sov(ex1_div_coll_offset),
               din     => ex1_div_coll_d,
               dout    => ex1_div_coll_q);
ex1_div_val_latch : tri_rlmreg_p
     generic map (width => ex1_div_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_div_val_offset to ex1_div_val_offset + ex1_div_val_q'length-1),
               scout   => sov(ex1_div_val_offset to ex1_div_val_offset + ex1_div_val_q'length-1),
               din     => ex1_div_val_d,
               dout    => ex1_div_val_q);
ex1_muldiv_in_use_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_muldiv_in_use_offset),
               scout   => sov(ex1_muldiv_in_use_offset),
               din     => rf1_muldiv_in_use          ,
               dout    => ex1_muldiv_in_use_q);
ex1_multdiv_val_latch : tri_rlmreg_p
     generic map (width => ex1_multdiv_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_multdiv_val_offset to ex1_multdiv_val_offset + ex1_multdiv_val_q'length-1),
               scout   => sov(ex1_multdiv_val_offset to ex1_multdiv_val_offset + ex1_multdiv_val_q'length-1),
               din     => ex1_multdiv_val_d,
               dout    => ex1_multdiv_val_q);
ex1_recirc_ctr_flush_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex1_recirc_ctr_flush_offset),
               scout   => sov(ex1_recirc_ctr_flush_offset),
               din     => rf1_recirc_ctr_flush_q     ,
               dout    => ex1_recirc_ctr_flush_q);
ex2_div_coll_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_div_coll_offset),
               scout   => sov(ex2_div_coll_offset),
               din     => ex2_div_coll_d,
               dout    => ex2_div_coll_q);
ex2_div_val_latch : tri_rlmreg_p
     generic map (width => ex2_div_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_div_val_offset to ex2_div_val_offset + ex2_div_val_q'length-1),
               scout   => sov(ex2_div_val_offset to ex2_div_val_offset + ex2_div_val_q'length-1),
               din     => ex2_div_val_d,
               dout    => ex2_div_val_q);
ex2_multdiv_val_latch : tri_rlmreg_p
     generic map (width => ex2_multdiv_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_multdiv_val_offset to ex2_multdiv_val_offset + ex2_multdiv_val_q'length-1),
               scout   => sov(ex2_multdiv_val_offset to ex2_multdiv_val_offset + ex2_multdiv_val_q'length-1),
               din     => ex2_multdiv_val_d,
               dout    => ex2_multdiv_val_q);
ex3_div_val_latch : tri_rlmreg_p
     generic map (width => ex3_div_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_div_val_offset to ex3_div_val_offset + ex3_div_val_q'length-1),
               scout   => sov(ex3_div_val_offset to ex3_div_val_offset + ex3_div_val_q'length-1),
               din     => ex3_div_val_d,
               dout    => ex3_div_val_q);
ex3_multdiv_val_latch : tri_rlmreg_p
     generic map (width => ex3_multdiv_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_multdiv_val_offset to ex3_multdiv_val_offset + ex3_multdiv_val_q'length-1),
               scout   => sov(ex3_multdiv_val_offset to ex3_multdiv_val_offset + ex3_multdiv_val_q'length-1),
               din     => ex3_multdiv_val_d,
               dout    => ex3_multdiv_val_q);
ex4_div_val_latch : tri_rlmreg_p
     generic map (width => ex4_div_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex4_div_val_offset to ex4_div_val_offset + ex4_div_val_q'length-1),
               scout   => sov(ex4_div_val_offset to ex4_div_val_offset + ex4_div_val_q'length-1),
               din     => ex4_div_val_d,
               dout    => ex4_div_val_q);
ex5_div_val_latch : tri_rlmreg_p
     generic map (width => ex5_div_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_div_val_offset to ex5_div_val_offset + ex5_div_val_q'length-1),
               scout   => sov(ex5_div_val_offset to ex5_div_val_offset + ex5_div_val_q'length-1),
               din     => ex5_div_val_d,
               dout    => ex5_div_val_q);
ex6_div_barr_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex6_div_barr_val_offset),
               scout   => sov(ex6_div_barr_val_offset),
               din     => ex5_div_barr_val           ,
               dout    => ex6_div_barr_val_q);
ex6_set_barr_latch : tri_rlmreg_p
     generic map (width => ex6_set_barr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex6_set_barr_offset to ex6_set_barr_offset + ex6_set_barr_q'length-1),
               scout   => sov(ex6_set_barr_offset to ex6_set_barr_offset + ex6_set_barr_q'length-1),
               din     => ex5_set_barr,
               dout    => ex6_set_barr_q);
an_ac_back_inv_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(an_ac_back_inv_offset),
               scout   => sov(an_ac_back_inv_offset),
               din     => an_ac_back_inv             ,
               dout    => an_ac_back_inv_q);
an_ac_back_inv_addr_latch : tri_rlmreg_p
     generic map (width => an_ac_back_inv_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => an_ac_back_inv_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(an_ac_back_inv_addr_offset to an_ac_back_inv_addr_offset + an_ac_back_inv_addr_q'length-1),
               scout   => sov(an_ac_back_inv_addr_offset to an_ac_back_inv_addr_offset + an_ac_back_inv_addr_q'length-1),
               din     => an_ac_back_inv_addr        ,
               dout    => an_ac_back_inv_addr_q);
an_ac_back_inv_target_bit3_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => an_ac_back_inv       ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(an_ac_back_inv_target_bit3_offset),
               scout   => sov(an_ac_back_inv_target_bit3_offset),
               din     => an_ac_back_inv_target_bit3 ,
               dout    => an_ac_back_inv_target_bit3_q);
back_inv_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(back_inv_val_offset),
               scout   => sov(back_inv_val_offset),
               din     => back_inv_val_d,
               dout    => back_inv_val_q);
coll_tid_latch : tri_rlmreg_p
     generic map (width => coll_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(coll_tid_offset to coll_tid_offset + coll_tid_q'length-1),
               scout   => sov(coll_tid_offset to coll_tid_offset + coll_tid_q'length-1),
               din     => coll_tid_d,
               dout    => coll_tid_q);
div_barr_done_latch : tri_rlmreg_p
     generic map (width => div_barr_done_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(div_barr_done_offset to div_barr_done_offset + div_barr_done_q'length-1),
               scout   => sov(div_barr_done_offset to div_barr_done_offset + div_barr_done_q'length-1),
               din     => div_barr_done_d,
               dout    => div_barr_done_q);
div_barr_thres_latch : tri_rlmreg_p
     generic map (width => div_barr_thres_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(div_barr_thres_offset to div_barr_thres_offset + div_barr_thres_q'length-1),
               scout   => sov(div_barr_thres_offset to div_barr_thres_offset + div_barr_thres_q'length-1),
               din     => spr_xucr4_div_barr_thres   ,
               dout    => div_barr_thres_q);
div_coll_barr_done_latch : tri_rlmreg_p
     generic map (width => div_coll_barr_done_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(div_coll_barr_done_offset to div_coll_barr_done_offset + div_coll_barr_done_q'length-1),
               scout   => sov(div_coll_barr_done_offset to div_coll_barr_done_offset + div_coll_barr_done_q'length-1),
               din     => div_coll_barr_done_d,
               dout    => div_coll_barr_done_q);
hold_divide_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_divide_offset),
               scout   => sov(hold_divide_offset),
               din     => rf0_divide                 ,
               dout    => hold_divide_q);
hold_error_latch : tri_rlmreg_p
     generic map (width => hold_error_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_error_offset to hold_error_offset + hold_error_q'length-1),
               scout   => sov(hold_error_offset to hold_error_offset + hold_error_q'length-1),
               din     => hold_error_d,
               dout    => hold_error_q);
hold_ifar_latch : tri_rlmreg_p
     generic map (width => hold_ifar_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_ifar_offset to hold_ifar_offset + hold_ifar_q'length-1),
               scout   => sov(hold_ifar_offset to hold_ifar_offset + hold_ifar_q'length-1),
               din     => hold_ifar_d,
               dout    => hold_ifar_q);
hold_instr_latch : tri_rlmreg_p
     generic map (width => hold_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_instr_offset to hold_instr_offset + hold_instr_q'length-1),
               scout   => sov(hold_instr_offset to hold_instr_offset + hold_instr_q'length-1),
               din     => hold_instr_d,
               dout    => hold_instr_q);
hold_is_ucode_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_is_ucode_offset),
               scout   => sov(hold_is_ucode_offset),
               din     => hold_is_ucode_d,
               dout    => hold_is_ucode_q);
hold_match_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_match_offset),
               scout   => sov(hold_match_offset),
               din     => hold_match_d,
               dout    => hold_match_q);
hold_s1_latch : tri_rlmreg_p
     generic map (width => hold_s1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_s1_offset to hold_s1_offset + hold_s1_q'length-1),
               scout   => sov(hold_s1_offset to hold_s1_offset + hold_s1_q'length-1),
               din     => hold_s1_d,
               dout    => hold_s1_q);
hold_s1_vld_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_s1_vld_offset),
               scout   => sov(hold_s1_vld_offset),
               din     => hold_s1_vld_d,
               dout    => hold_s1_vld_q);
hold_s2_latch : tri_rlmreg_p
     generic map (width => hold_s2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_s2_offset to hold_s2_offset + hold_s2_q'length-1),
               scout   => sov(hold_s2_offset to hold_s2_offset + hold_s2_q'length-1),
               din     => hold_s2_d,
               dout    => hold_s2_q);
hold_s2_vld_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_s2_vld_offset),
               scout   => sov(hold_s2_vld_offset),
               din     => hold_s2_vld_d,
               dout    => hold_s2_vld_q);
hold_s3_latch : tri_rlmreg_p
     generic map (width => hold_s3_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_s3_offset to hold_s3_offset + hold_s3_q'length-1),
               scout   => sov(hold_s3_offset to hold_s3_offset + hold_s3_q'length-1),
               din     => hold_s3_d,
               dout    => hold_s3_q);
hold_s3_vld_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_s3_vld_offset),
               scout   => sov(hold_s3_vld_offset),
               din     => hold_s3_vld_d,
               dout    => hold_s3_vld_q);
hold_ta_latch : tri_rlmreg_p
     generic map (width => hold_ta_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_ta_offset to hold_ta_offset + hold_ta_q'length-1),
               scout   => sov(hold_ta_offset to hold_ta_offset + hold_ta_q'length-1),
               din     => hold_ta_d,
               dout    => hold_ta_q);
hold_ta_vld_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_ta_vld_offset),
               scout   => sov(hold_ta_vld_offset),
               din     => hold_ta_vld_d,
               dout    => hold_ta_vld_q);
hold_tid_latch : tri_rlmreg_p
     generic map (width => hold_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_tid_offset to hold_tid_offset + hold_tid_q'length-1),
               scout   => sov(hold_tid_offset to hold_tid_offset + hold_tid_q'length-1),
               din     => hold_tid_d,
               dout    => hold_tid_q);
hold_use_imm_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => rf0_hold_latch_act   ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(hold_use_imm_offset),
               scout   => sov(hold_use_imm_offset),
               din     => hold_use_imm_d,
               dout    => hold_use_imm_q);
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
               din     => lsu_xu_rel_ta_gpr          ,
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
               din     => lsu_xu_rel_wren            ,
               dout    => lsu_xu_rel_wren_q);
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
END XUQ_DEC_A;

