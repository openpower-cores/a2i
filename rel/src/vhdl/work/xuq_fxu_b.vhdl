-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

LIBRARY ieee;       USE ieee.std_logic_1164.all;
LIBRARY support;    
                    USE support.power_logic_pkg.all;
LIBRARY tri;        USE tri.tri_latches_pkg.all;
LIBRARY work;       USE work.xuq_pkg.all;

entity xuq_fxu_b is
    generic(
        expand_type                     : integer := 2;
        threads                         : integer := 4;
        eff_ifar                        : integer := 62;
        regmode                         : integer := 6;
        regsize                         : integer := 64;
        a2mode                          : integer := 1;
        hvmode                          : integer := 1;
        dc_size                         : natural := 14;
        cl_size                         : natural := 6;             
        real_data_add                   : integer := 42;
        fxu_synth                       : integer := 0);
    port(
        nclk                            : in clk_logic;
        vdd                             : inout power_logic;
        gnd                             : inout power_logic;
        vcs                             : inout power_logic;

        func_scan_in                        : in     std_ulogic_vector(54 to 58);
        func_scan_out                       : out    std_ulogic_vector(54 to 58);
        an_ac_scan_dis_dc_b                 : in     std_ulogic;
        pc_xu_ccflush_dc                    : in     std_ulogic;
        clkoff_dc_b                         : out std_ulogic;
        d_mode_dc                           : out std_ulogic;
        delay_lclkr_dc                      : out std_ulogic_vector(0 to 4);
        mpw1_dc_b                           : out std_ulogic_vector(0 to 4);
        mpw2_dc_b                           : out std_ulogic;
        g6t_clkoff_dc_b                     : out std_ulogic;
        g6t_d_mode_dc                       : out std_ulogic;
        g6t_delay_lclkr_dc                  : out std_ulogic_vector(0 to 4);
        g6t_mpw1_dc_b                       : out std_ulogic_vector(0 to 4);
        g6t_mpw2_dc_b                       : out std_ulogic;
        g8t_clkoff_dc_b                     : out std_ulogic;
        g8t_d_mode_dc                       : out std_ulogic;
        g8t_delay_lclkr_dc                  : out std_ulogic_vector(0 to 4);
        g8t_mpw1_dc_b                       : out std_ulogic_vector(0 to 4);
        g8t_mpw2_dc_b                       : out std_ulogic;
        cam_clkoff_dc_b                     : out std_ulogic;
        cam_d_mode_dc                       : out std_ulogic;
        cam_delay_lclkr_dc                  : out std_ulogic_vector(0 to 4);
        cam_act_dis_dc                      : out std_ulogic;
        cam_mpw1_dc_b                       : out std_ulogic_vector(0 to 4);
        cam_mpw2_dc_b                       : out std_ulogic;
        pc_xu_sg_3                          : in     std_ulogic_vector(0 to 4);
        pc_xu_func_sl_thold_3               : in     std_ulogic_vector(0 to 4);
        pc_xu_func_slp_sl_thold_3           : in     std_ulogic_vector(0 to 4);
        pc_xu_func_nsl_thold_3              : in     std_ulogic;
        pc_xu_func_slp_nsl_thold_3          : in     std_ulogic;
        pc_xu_gptr_sl_thold_3               : in     std_ulogic;
        pc_xu_abst_sl_thold_3               : in     std_ulogic;
        pc_xu_abst_slp_sl_thold_3           : in     std_ulogic;
        pc_xu_regf_sl_thold_3               : in     std_ulogic;
        pc_xu_regf_slp_sl_thold_3           : in     std_ulogic;
        pc_xu_time_sl_thold_3               : in     std_ulogic;
        pc_xu_cfg_sl_thold_3                : in     std_ulogic;
        pc_xu_cfg_slp_sl_thold_3            : in     std_ulogic;
        pc_xu_ary_nsl_thold_3               : in     std_ulogic;
        pc_xu_ary_slp_nsl_thold_3           : in     std_ulogic;
        pc_xu_repr_sl_thold_3               : in     std_ulogic;
        pc_xu_bolt_sl_thold_3               : in     std_ulogic;
        pc_xu_bo_enable_3                   : in     std_ulogic;
        pc_xu_fce_3                         : in     std_ulogic_vector(0 to 1);
        an_ac_scan_diag_dc                  : in     std_ulogic;
        sg_2                                : out std_ulogic_vector(0 to 3);
        fce_2                               : out std_ulogic_vector(0 to 1);
        func_sl_thold_2                     : out std_ulogic_vector(0 to 3);
        func_slp_sl_thold_2                 : out std_ulogic_vector(0 to 1);
        func_nsl_thold_2                    : out std_ulogic;
        func_slp_nsl_thold_2                : out std_ulogic;
        abst_sl_thold_2                     : out std_ulogic;
        abst_slp_sl_thold_2                 : out std_ulogic;
        time_sl_thold_2                     : out std_ulogic;
        gptr_sl_thold_2                     : out std_ulogic;
        ary_nsl_thold_2                     : out std_ulogic;
        ary_slp_nsl_thold_2                 : out std_ulogic;
        repr_sl_thold_2                     : out std_ulogic;
        cfg_sl_thold_2                      : out std_ulogic;
        cfg_slp_sl_thold_2                  : out std_ulogic;
        regf_slp_sl_thold_2                 : out std_ulogic;
        bolt_sl_thold_2                     : out std_ulogic;
        bo_enable_2                         : out std_ulogic;
        gptr_scan_in                        : in     std_ulogic;
        gptr_scan_out                       : out    std_ulogic;

        fxa_fxb_rf0_val                     : in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_issued                  : in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_ucode_val               : in  std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_act                     : in  std_ulogic;
        fxa_fxb_ex1_hold_ctr_flush          : in  std_ulogic;
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
        fxa_fxb_rf1_mul_val                 : in  std_ulogic;
        fxa_fxb_rf1_div_val                 : in  std_ulogic;
        fxa_fxb_rf1_div_ctr                 : in  std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_xu_epid_instr           : in  std_ulogic;
        fxa_fxb_rf0_axu_is_extload          : in  std_ulogic;
        fxa_fxb_rf0_axu_is_extstore         : in  std_ulogic;
        fxa_fxb_rf0_is_mfocrf               : in  std_ulogic;
        fxa_fxb_rf0_3src_instr              : in  std_ulogic;
        fxa_fxb_rf0_gpr0_zero               : in  std_ulogic;
        fxa_fxb_rf0_use_imm                 : in  std_ulogic;
        fxa_fxb_rf1_muldiv_coll             : in  std_ulogic;
        fxb_fxa_ex7_we0                     : out std_ulogic;
        fxb_fxa_ex7_wa0                     : out std_ulogic_vector(0 to 7);
        fxb_fxa_ex7_wd0                     : out std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do0                     : in  std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do1                     : in  std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do2                     : in  std_ulogic_vector(64-regsize to 63);

        xu_lsu_rf0_act                      : out std_ulogic;
        xu_lsu_rf1_cache_acc                : out std_ulogic;
        xu_lsu_rf1_thrd_id                  : out std_ulogic_vector(0 to threads-1);
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
        xu_lsu_rf1_axu_op_val               : out std_ulogic;
        xu_lsu_rf1_axu_ldst_falign          : out std_ulogic;
        xu_lsu_rf1_axu_ldst_fexcpt          : out std_ulogic;
        xu_lsu_ex1_store_data               : out std_ulogic_vector(64-(2**regmode) to 63);
        xu_lsu_rf1_algebraic                : out std_ulogic;
        xu_lsu_rf1_byte_rev                 : out std_ulogic;
        xu_lsu_rf1_src_gpr                  : out std_ulogic;
        xu_lsu_rf1_src_axu                  : out std_ulogic;
        xu_lsu_rf1_src_dp                   : out std_ulogic;
        xu_lsu_rf1_targ_gpr                 : out std_ulogic;
        xu_lsu_rf1_targ_axu                 : out std_ulogic;
        xu_lsu_rf1_targ_dp                  : out std_ulogic;
        xu_lsu_ex1_rotsel_ovrd              : out std_ulogic_vector(0 to 4);
        xu_lsu_rf1_derat_act                : out std_ulogic;
        xu_lsu_rf1_derat_is_load            : out std_ulogic;
        xu_lsu_rf1_derat_is_store           : out std_ulogic;
        xu_lsu_rf1_src0_vld                 : out std_ulogic;
        xu_lsu_rf1_src0_reg                 : out std_ulogic_vector(0 to 7);
        xu_lsu_rf1_src1_vld                 : out std_ulogic;
        xu_lsu_rf1_src1_reg                 : out std_ulogic_vector(0 to 7);
        xu_lsu_rf1_targ_vld                 : out std_ulogic;
        xu_lsu_rf1_targ_reg                 : out std_ulogic_vector(0 to 7);
        xu_bx_ex1_mtdp_val                 : out std_ulogic;
        xu_bx_ex1_mfdp_val                 : out std_ulogic;
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
        lsu_xu_ex5_wren                     : in  std_ulogic;                        
        lsu_xu_rel_wren                     : in  std_ulogic;                        
        lsu_xu_rel_ta_gpr                   : in  std_ulogic_vector(0 to 7);         
        lsu_xu_need_hole                    : in  std_ulogic;
        lsu_xu_rot_ex6_data_b               : in  std_ulogic_vector(64-(2**regmode) to 63);
        lsu_xu_rot_rel_data                 : in  std_ulogic_vector(64-(2**regmode) to 63);
        xu_lsu_ex4_dvc1_en                  : out std_ulogic;
        xu_lsu_ex4_dvc2_en                  : out std_ulogic;
        lsu_xu_ex2_dvc1_st_cmp              : in  std_ulogic_vector(8-(2**regmode)/8 to 7);
        lsu_xu_ex2_dvc2_st_cmp              : in  std_ulogic_vector(8-(2**regmode)/8 to 7);
        lsu_xu_ex8_dvc1_ld_cmp              : in  std_ulogic_vector(8-(2**regmode)/8 to 7);
        lsu_xu_ex8_dvc2_ld_cmp              : in  std_ulogic_vector(8-(2**regmode)/8 to 7);
        lsu_xu_rel_dvc1_en                  : in  std_ulogic;
        lsu_xu_rel_dvc2_en                  : in  std_ulogic;
        lsu_xu_rel_dvc_thrd_id              : in  std_ulogic_vector(0 to 3);
        lsu_xu_rel_dvc1_cmp                 : in  std_ulogic_vector(8-(2**regmode)/8 to 7);
        lsu_xu_rel_dvc2_cmp                 : in  std_ulogic_vector(8-(2**regmode)/8 to 7);
        xu_lsu_ex1_add_src0                 : out std_ulogic_vector(64-regsize to 63);
        xu_lsu_ex1_add_src1                 : out std_ulogic_vector(64-regsize to 63);

        xu_ex1_eff_addr_int                 : out std_ulogic_vector(64-(dc_size-3) to 63);

        xu_iu_rf1_val                       : out std_ulogic_vector(0 to threads-1);
        xu_rf1_val                          : out std_ulogic_vector(0 to threads-1);
        xu_rf1_is_tlbre                     : out std_ulogic;
        xu_rf1_is_tlbwe                     : out std_ulogic;
        xu_rf1_is_tlbsx                     : out std_ulogic;
        xu_rf1_is_tlbsrx                    : out std_ulogic;
        xu_rf1_is_tlbilx                    : out std_ulogic;
        xu_rf1_is_tlbivax                   : out std_ulogic;
        xu_rf1_is_eratre                    : out std_ulogic;
        xu_rf1_is_eratwe                    : out std_ulogic;
        xu_rf1_is_eratsx                    : out std_ulogic;
        xu_rf1_is_eratsrx                   : out std_ulogic;
        xu_rf1_is_eratilx                   : out std_ulogic;
        xu_rf1_is_erativax                  : out std_ulogic;
        xu_ex1_is_isync                     : out std_ulogic;
        xu_ex1_is_csync                     : out std_ulogic;
        xu_rf1_ws                           : out std_ulogic_vector(0 to 1);
        xu_rf1_t                            : out std_ulogic_vector(0 to 2);
        xu_ex1_rs_is                        : out std_ulogic_vector(0 to 8);
        xu_ex1_ra_entry                     : out std_ulogic_vector(7 to 11);
        xu_ex1_rb                           : out std_ulogic_vector(64-(2**regmode) to 51);
        xu_ex2_eff_addr                     : out std_ulogic_vector(64-(2**regmode) to 63);
        xu_ex4_rs_data                      : out std_ulogic_vector(64-(2**regmode) to 63);
        lsu_xu_ex4_tlb_data                 : in  std_ulogic_vector(64-(2**regmode) to 63);
        iu_xu_ex4_tlb_data                  : in  std_ulogic_vector(64-(2**regmode) to 63);

        xu_mm_derat_epn                     : out std_ulogic_vector(62-eff_ifar to 51);

        lsu_xu_is2_back_inv                 : in std_ulogic;
        lsu_xu_is2_back_inv_addr            : in std_ulogic_vector(64-real_data_add to 63-cl_size);

        mm_xu_mmucr0_0_tlbsel               : in  std_ulogic_vector(4 to 5);
        mm_xu_mmucr0_1_tlbsel               : in  std_ulogic_vector(4 to 5);
        mm_xu_mmucr0_2_tlbsel               : in  std_ulogic_vector(4 to 5);
        mm_xu_mmucr0_3_tlbsel               : in  std_ulogic_vector(4 to 5);

        xu_mm_rf1_is_tlbsxr                 : out std_ulogic;
        mm_xu_cr0_eq_valid                  : in  std_ulogic_vector(0 to threads-1);
        mm_xu_cr0_eq                        : in  std_ulogic_vector(0 to threads-1);

        fu_xu_ex4_cr_val                    : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex4_cr_noflush                : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex4_cr0                       : in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr0_bf                    : in  std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr1                       : in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr1_bf                    : in  std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr2                       : in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr2_bf                    : in  std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr3                       : in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr3_bf                    : in  std_ulogic_vector(0 to 2);

        xu_pc_ram_data                      : out std_ulogic_vector(64-(2**regmode) to 63);

        xu_iu_ex5_val                       : out std_ulogic;
        xu_iu_ex5_tid                       : out std_ulogic_vector(0 to threads-1);
        xu_iu_ex5_br_update                 : out std_ulogic;
        xu_iu_ex5_br_hist                   : out std_ulogic_vector(0 to 1);
        xu_iu_ex5_bclr                      : out std_ulogic;
        xu_iu_ex5_lk                        : out std_ulogic;
        xu_iu_ex5_bh                        : out std_ulogic_vector(0 to 1);
        xu_iu_ex6_pri                       : out std_ulogic_vector(0 to 2);
        xu_iu_ex6_pri_val                   : out std_ulogic_vector(0 to 3);
        xu_iu_spr_xer                       : out std_ulogic_vector(0 to 7*threads-1);
        xu_iu_slowspr_done                  : out std_ulogic_vector(0 to threads-1);
        xu_iu_need_hole                     : out std_ulogic;
        fxb_fxa_ex6_clear_barrier           : out std_ulogic_vector(0 to threads-1);
        xu_iu_ex5_gshare                    : out std_ulogic_vector(0 to 3);
        xu_iu_ex5_getNIA                    : out std_ulogic;

        an_ac_stcx_complete                 : in  std_ulogic_vector(0 to threads-1);
        an_ac_stcx_pass                     : in  std_ulogic_vector(0 to threads-1);

        an_ac_back_inv                      : in  std_ulogic;
        an_ac_back_inv_addr                 : in  std_ulogic_vector(58 to 63);
        an_ac_back_inv_target_bit3          : in  std_ulogic;

        slowspr_val_in                      : in  std_ulogic;
        slowspr_rw_in                       : in  std_ulogic;
        slowspr_etid_in                     : in  std_ulogic_vector(0 to 1);
        slowspr_addr_in                     : in  std_ulogic_vector(0 to 9);
        slowspr_data_in                     : in  std_ulogic_vector(64-(2**regmode) to 63);
        slowspr_done_in                     : in  std_ulogic;

        an_ac_dcr_act                       : in  std_ulogic;
        an_ac_dcr_val                       : in  std_ulogic;
        an_ac_dcr_read                      : in  std_ulogic;
        an_ac_dcr_etid                      : in  std_ulogic_vector(0 to 1);
        an_ac_dcr_data                      : in  std_ulogic_vector(64-(2**regmode) to 63);
        an_ac_dcr_done                      : in  std_ulogic;
        an_ac_dcr_ack                       : out std_ulogic;
        
        lsu_xu_ex4_mtdp_cr_status           : in  std_ulogic;
        lsu_xu_ex4_mfdp_cr_status           : in  std_ulogic;

        lsu_xu_ex4_cr_upd                   : in std_ulogic;
        lsu_xu_ex5_cr_rslt                  : in std_ulogic;

        dec_cpl_ex3_mult_coll               : out std_ulogic;
        dec_cpl_ex3_axu_instr_type          : out std_ulogic_vector(0 to 2);
        dec_cpl_ex3_instr_hypv              : out std_ulogic;
        dec_cpl_rf1_ucode_val               : out std_ulogic_vector(0 to threads-1);
        dec_cpl_ex2_error                   : out std_ulogic_vector(0 to 2);
        dec_cpl_ex2_match                   : out std_ulogic;
        dec_cpl_ex2_is_ucode                : out std_ulogic;
        dec_cpl_rf1_ifar                    : out std_ulogic_vector(62-eff_ifar to 61);
        dec_cpl_ex3_is_any_store            : out std_ulogic;
        dec_cpl_ex2_is_any_load_dac         : out std_ulogic;
        dec_cpl_ex3_instr_priv              : out std_ulogic;
        dec_cpl_ex1_epid_instr              : out std_ulogic;
        dec_cpl_ex2_illegal_op              : out std_ulogic;
        alu_cpl_ex3_trap_val                : out std_ulogic;
        mux_cpl_ex4_rt                      : out std_ulogic_vector(64-(2**regmode) to 63);
        dec_cpl_ex2_is_any_store_dac        : out std_ulogic;
        dec_cpl_ex3_tlb_illeg               : out std_ulogic;
        dec_cpl_ex3_mtdp_nr                 : out std_ulogic;
        mux_cpl_slowspr_done                : out std_ulogic_vector(0 to threads-1);
        mux_cpl_slowspr_flush               : out std_ulogic_vector(0 to threads-1);
        dec_cpl_rf1_val                     : out std_ulogic_vector(0 to threads-1);
        dec_cpl_rf1_issued                  : out std_ulogic_vector(0 to threads-1);
        dec_cpl_rf1_instr                   : out std_ulogic_vector(0 to 31);
        cpl_byp_ex3_spr_rt                  : in  std_ulogic_vector(64-(2**regmode) to 63);
        byp_cpl_ex1_cr_bit                  : out std_ulogic;
        dec_cpl_rf1_pred_taken_cnt          : out std_ulogic;
        dec_cpl_ex1_is_slowspr_wr           : out std_ulogic;
        dec_cpl_ex3_ddmh_en                 : out std_ulogic;
        dec_cpl_ex3_back_inv                : out std_ulogic;

        xu_rf1_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex1_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex2_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex3_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex4_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex5_flush                        : in  std_ulogic_vector(0 to threads-1);

        dec_spr_ex4_val                     : out std_ulogic_vector(0 to threads-1);
        mux_spr_ex2_rt                      : out std_ulogic_vector(64-(2**regmode) to 63);
        fxu_spr_ex1_rs0                     : out std_ulogic_vector(52 to 63);
        fxu_spr_ex1_rs1                     : out std_ulogic_vector(54 to 63);
        spr_msr_cm                          : in  std_ulogic_vector(0 to threads-1);
        spr_dec_spr_xucr0_ssdly             : in std_ulogic_vector(0 to 4);
        spr_ccr2_en_attn                    : in  std_ulogic;
        spr_ccr2_en_ditc                    : in  std_ulogic;
        spr_ccr2_en_pc                      : in  std_ulogic;
        spr_ccr2_en_icswx                   : in  std_ulogic;
        spr_ccr2_en_dcr                     : in  std_ulogic;
        spr_dec_rf1_epcr_dgtmi              : in  std_ulogic_vector(0 to threads-1);
        spr_dec_rf1_msr_ucle                : in  std_ulogic_vector(0 to threads-1);
        spr_dec_rf1_msrp_uclep              : in  std_ulogic_vector(0 to threads-1);
        spr_byp_ex4_is_mfxer                : in  std_ulogic_vector(0 to threads-1);
        spr_byp_ex3_spr_rt                  : in  std_ulogic_vector(64-(2**regmode) to 63);
        spr_byp_ex4_is_mtxer                : in  std_ulogic_vector(0 to threads-1);
        spr_ccr2_notlb                      : in  std_ulogic;
        dec_spr_rf1_val                     : out std_ulogic_vector(0 to threads-1);
        fxu_spr_ex1_rs2                     : out std_ulogic_vector(42 to 55);

        cpl_perf_tx_events                  : in  std_ulogic_vector(0 to 75);
        spr_perf_tx_events                  : in  std_ulogic_vector(0 to 8*threads-1);
        fxa_perf_muldiv_in_use              : in  std_ulogic;
        xu_pc_event_data                    : out std_ulogic_vector(0 to 7);

        pc_xu_event_bus_enable              : in  std_ulogic;
        pc_xu_event_count_mode              : in  std_ulogic_vector(0 to 2);
        pc_xu_event_mux_ctrls               : in  std_ulogic_vector(0 to 47);

        pc_xu_trace_bus_enable              : in  std_ulogic;
        pc_xu_instr_trace_mode              : in  std_ulogic;
        pc_xu_instr_trace_tid               : in  std_ulogic_vector(0 to 1);
        dec_cpl_rf1_instr_trace_val         : out std_ulogic;
        dec_cpl_rf1_instr_trace_type        : out std_ulogic_vector(0 to 1);
        dec_cpl_ex3_instr_trace_val         : out std_ulogic;
        xu_lsu_ex2_instr_trace_val          : out std_ulogic;
        cpl_dec_in_ucode                    : in  std_ulogic_vector(0 to threads-1);
        fxu_debug_mux_ctrls                 : in  std_ulogic_vector(0 to 15);
        fxu_trigger_data_in                 : in  std_ulogic_vector(0 to 11);
        fxu_debug_data_in                   : in  std_ulogic_vector(0 to 87);
        fxu_trigger_data_out                : out std_ulogic_vector(0 to 11);
        fxu_debug_data_out                  : out std_ulogic_vector(0 to 87);
        lsu_xu_data_debug0                  : in  std_ulogic_vector(0 to 87);
        lsu_xu_data_debug1                  : in  std_ulogic_vector(0 to 87);
        lsu_xu_data_debug2                  : in  std_ulogic_vector(0 to 87);

        fxu_cpl_ex3_dac1r_cmpr_async        : out std_ulogic_vector(0 to threads-1);
        fxu_cpl_ex3_dac2r_cmpr_async        : out std_ulogic_vector(0 to threads-1);
        fxu_cpl_ex3_dac1r_cmpr              : out std_ulogic_vector(0 to threads-1);
        fxu_cpl_ex3_dac2r_cmpr              : out std_ulogic_vector(0 to threads-1);
        fxu_cpl_ex3_dac3r_cmpr              : out std_ulogic_vector(0 to threads-1);
        fxu_cpl_ex3_dac4r_cmpr              : out std_ulogic_vector(0 to threads-1);
        fxu_cpl_ex3_dac1w_cmpr              : out std_ulogic_vector(0 to threads-1);
        fxu_cpl_ex3_dac2w_cmpr              : out std_ulogic_vector(0 to threads-1);
        fxu_cpl_ex3_dac3w_cmpr              : out std_ulogic_vector(0 to threads-1);
        fxu_cpl_ex3_dac4w_cmpr              : out std_ulogic_vector(0 to threads-1);

        spr_bit_act                         : in  std_ulogic;
        spr_msr_gs                          : in  std_ulogic_vector(0 to threads-1);
        spr_msr_ds                          : in  std_ulogic_vector(0 to threads-1);
        spr_msr_pr                          : in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_dac1                      : in  std_ulogic_vector(0 to 2*threads-1);
        spr_dbcr0_dac2                      : in  std_ulogic_vector(0 to 2*threads-1);
        spr_dbcr0_dac3                      : in  std_ulogic_vector(0 to 2*threads-1);
        spr_dbcr0_dac4                      : in  std_ulogic_vector(0 to 2*threads-1);
        spr_dbcr3_ivc                       : out std_ulogic_vector(0 to threads-1);
        spr_xucr0_clkg_ctl                  : in  std_ulogic_vector(2 to 2)
    );
    --  synopsys translate_off


    --  synopsys translate_on
end xuq_fxu_b;

architecture xuq_fxu_b of xuq_fxu_b is
    constant tiup                           : std_ulogic := '1';
    constant tidn                           : std_ulogic := '0';

    signal sg_2_b                                : std_ulogic_vector(0 to 3);
    signal fce_2_b                               : std_ulogic_vector(0 to 1);
    signal func_sl_thold_2_b                     : std_ulogic_vector(0 to 3);
    signal func_slp_sl_thold_2_b                 : std_ulogic_vector(0 to 1);
    signal func_slp_nsl_thold_2_b                : std_ulogic;
    signal func_nsl_thold_2_b                    : std_ulogic;
    signal clkoff_dc_b_b                         : std_ulogic;
    signal d_mode_dc_b                           : std_ulogic;
    signal delay_lclkr_dc_b                      : std_ulogic_vector(0 to 4);
    signal mpw1_dc_b_b                           : std_ulogic_vector(0 to 4);
    signal mpw2_dc_b_b                           : std_ulogic;

    signal func_slp_sl_thold_1              : std_ulogic;
    signal func_slp_nsl_thold_1             : std_ulogic;
    signal func_sl_thold_1                  : std_ulogic;
    signal func_nsl_thold_1                 : std_ulogic;
    signal sg_1                             : std_ulogic;
    signal fce_1                            : std_ulogic;
    signal func_slp_sl_thold_0              : std_ulogic;
    signal func_slp_nsl_thold_0             : std_ulogic;
    signal func_sl_thold_0                  : std_ulogic;
    signal func_nsl_thold_0                 : std_ulogic;
    signal sg_0                             : std_ulogic;
    signal fce_0                            : std_ulogic;
    signal func_sl_force                    : std_ulogic;
    signal func_nsl_force                   : std_ulogic;
    signal func_sl_thold_0_b                : std_ulogic;
    signal func_nsl_thold_0_b               : std_ulogic;
    signal func_slp_sl_force                : std_ulogic;
    signal func_slp_sl_thold_0_b            : std_ulogic;
    signal func_slp_nsl_force               : std_ulogic;
    signal func_slp_nsl_thold_0_b           : std_ulogic;
    signal      so_force                    : std_ulogic;
    signal func_so_thold_0_b                : std_ulogic;

    signal dec_spr_ex1_is_mfspr             : std_ulogic;
    signal dec_spr_ex1_is_mtspr             : std_ulogic;

    signal byp_alu_ex1_rs0                  : std_ulogic_vector(64-regsize to 63);
    signal byp_alu_ex1_rs1                  : std_ulogic_vector(64-regsize to 63);
    signal alu_byp_ex2_rt                   : std_ulogic_vector(64-regsize to 63);
    signal alu_byp_ex2_rt_b                   : std_ulogic_vector(64-regsize to 63);
    signal alu_byp_ex1_log_rt               : std_ulogic_vector(64-regsize to 63);     
    signal byp_spr_ex6_rt                   : std_ulogic_vector(64-regsize to 63);
    signal byp_alu_ex1_mulsrc_0             : std_ulogic_vector(64-regsize to 63);
    signal byp_alu_ex1_mulsrc_1             : std_ulogic_vector(64-regsize to 63);
    signal byp_alu_ex1_divsrc_0             : std_ulogic_vector(64-regsize to 63);
    signal byp_alu_ex1_divsrc_1             : std_ulogic_vector(64-regsize to 63);
    signal alu_ex2_div_done                 : std_ulogic;
    signal alu_ex3_mul_done                 : std_ulogic;
    signal alu_ex4_mul_done                 : std_ulogic;
    signal alu_byp_ex3_cr_div               : std_ulogic_vector(0 to 4);
    signal alu_byp_ex3_xer_div              : std_ulogic_vector(0 to 3);
    signal dec_byp_rf1_rs0_sel              : std_ulogic_vector(1 to 9);
    signal dec_byp_rf1_rs1_sel              : std_ulogic_vector(1 to 10);
    signal dec_byp_rf1_rs2_sel              : std_ulogic_vector(1 to 9);
    signal dec_byp_rf1_instr                : std_ulogic_vector(6 to 25);
    signal dec_byp_rf1_cr_so_update         : std_ulogic_vector(0 to 1);
    signal dec_byp_ex3_val                  : std_ulogic_vector(0 to threads-1);
    signal dec_byp_rf1_cr_we                : std_ulogic;
    signal dec_byp_rf1_is_mcrf              : std_ulogic;
    signal dec_byp_rf1_use_crfld0           : std_ulogic;
    signal dec_byp_rf1_alu_cmp              : std_ulogic;
    signal dec_byp_rf1_is_mtcrf             : std_ulogic;
    signal dec_byp_rf1_is_mtocrf            : std_ulogic;
    signal dec_byp_rf1_byp_val              : std_ulogic_vector(1 to 3);
    signal dec_byp_ex4_is_eratsxr           : std_ulogic;
    signal dec_byp_ex3_tlb_sel              : std_ulogic_vector(0 to 1);
    signal dec_alu_rf1_div_val              : std_ulogic;
    signal dec_alu_rf1_div_sign             : std_ulogic;
    signal dec_alu_rf1_div_size             : std_ulogic;
    signal dec_alu_rf1_div_extd             : std_ulogic;
    signal dec_alu_rf1_div_recform          : std_ulogic;
    signal dec_alu_rf1_sel                  : std_ulogic_vector(0 to 3); 
    signal dec_alu_rf1_add_rs0_inv          : std_ulogic_vector(64-regsize to 63);
    signal dec_alu_rf1_add_ci               : std_ulogic;
    signal dec_alu_rf1_is_cmpl              : std_ulogic;
    signal dec_alu_rf1_tw_cmpsel            : std_ulogic_vector(0 to 5);
    signal dec_rf1_is_isel                  : std_ulogic;
    signal dec_alu_rf1_xer_ov_update        : std_ulogic;
    signal dec_alu_rf1_xer_ca_update        : std_ulogic;
    signal dec_alu_rf1_sh_right             : std_ulogic;
    signal dec_alu_rf1_sh_word              : std_ulogic;
    signal dec_alu_rf1_sgnxtd_byte          : std_ulogic;
    signal dec_alu_rf1_sgnxtd_half          : std_ulogic;
    signal dec_alu_rf1_sgnxtd_wd            : std_ulogic;
    signal dec_alu_rf1_sra_dw               : std_ulogic;
    signal dec_alu_rf1_sra_wd               : std_ulogic;
    signal dec_alu_rf1_chk_shov_dw          : std_ulogic;
    signal dec_alu_rf1_chk_shov_wd          : std_ulogic;
    signal dec_alu_rf1_use_me_ins_hi        : std_ulogic;
    signal dec_alu_rf1_use_me_ins_lo        : std_ulogic;
    signal dec_alu_rf1_use_mb_ins_hi        : std_ulogic;
    signal dec_alu_rf1_use_mb_ins_lo        : std_ulogic;
    signal dec_alu_rf1_use_me_rb_hi         : std_ulogic;
    signal dec_alu_rf1_use_me_rb_lo         : std_ulogic;
    signal dec_alu_rf1_use_mb_rb_hi         : std_ulogic;
    signal dec_alu_rf1_use_mb_rb_lo         : std_ulogic;
    signal dec_alu_rf1_use_rb_amt_hi        : std_ulogic;
    signal dec_alu_rf1_use_rb_amt_lo        : std_ulogic;
    signal dec_alu_rf1_zm_ins               : std_ulogic;
    signal dec_alu_rf1_log_fcn              : std_ulogic_vector(0 to 3);
    signal dec_alu_rf1_me_ins_b             : std_ulogic_vector(0 to 5);
    signal dec_alu_rf1_mb_ins               : std_ulogic_vector(0 to 5);
    signal dec_alu_rf1_sh_amt               : std_ulogic_vector(0 to 5);
    signal dec_alu_rf1_mb_gt_me             : std_ulogic;
    signal dec_alu_rf1_mul_recform          : std_ulogic;
    signal dec_alu_rf1_mul_val              : std_ulogic;
    signal dec_alu_rf1_mul_ret              : std_ulogic;
    signal dec_alu_rf1_mul_sign             : std_ulogic;
    signal dec_alu_rf1_mul_size             : std_ulogic;
    signal dec_alu_rf1_mul_imm              : std_ulogic;
    signal dec_alu_ex1_is_cmp               : std_ulogic;
    signal dec_alu_rf1_select_64bmode       : std_ulogic;
    signal dec_byp_rf1_imm                  : std_ulogic_vector(64-regsize to 63);
    signal dec_rf1_tid                      : std_ulogic_vector(0 to threads-1);
    signal dec_ex1_tid                      : std_ulogic_vector(0 to threads-1);
    signal dec_ex2_tid                      : std_ulogic_vector(0 to threads-1);
    signal dec_ex3_tid                      : std_ulogic_vector(0 to threads-1);
    signal dec_ex4_tid                      : std_ulogic_vector(0 to threads-1);
    signal dec_ex5_tid                      : std_ulogic_vector(0 to threads-1);
    signal dec_byp_rf1_ca_used              : std_ulogic;
    signal dec_byp_rf1_ov_used              : std_ulogic;
    signal dec_byp_ex4_dp_instr             : std_ulogic;
    signal dec_byp_ex4_mtdp_val             : std_ulogic;
    signal dec_byp_ex4_mfdp_val             : std_ulogic;
    signal dec_byp_ex4_is_wchkall           : std_ulogic;
    signal dec_byp_ex1_spr_sel              : std_ulogic;
    signal dec_byp_ex4_is_mfcr              : std_ulogic;
    signal alu_byp_ex5_mul_rt               : std_ulogic_vector(64-regsize to 63);
    signal alu_byp_ex3_div_rt               : std_ulogic_vector(64-regsize to 63);
    signal alu_dec_ex1_ipb_ba               : std_ulogic_vector(27 to 31);
    signal alu_dec_div_need_hole            : std_ulogic;
    signal byp_dec_rf1_xer_ca               : std_ulogic;
    signal alu_byp_ex2_cr_recform           : std_ulogic_vector(0 to 3);
    signal alu_byp_ex5_cr_mul               : std_ulogic_vector(0 to 4);
    signal alu_byp_ex2_xer                  : std_ulogic_vector(0 to 3);
    signal alu_byp_ex5_xer_mul              : std_ulogic_vector(0 to 3);
    signal dec_byp_ex5_instr                : std_ulogic_vector(12 to 19);
    signal dec_byp_rf0_act                  : std_ulogic;
    signal ex2_is_any_store_dac             : std_ulogic;
    signal ex2_is_any_load_dac              : std_ulogic;
    signal fspr_byp_ex3_spr_rt              : std_ulogic_vector(64-regsize to 63);
    signal dec_fspr_ex1_instr               : std_ulogic_vector(11 to 20);
    signal dec_fspr_ex6_val                 : std_ulogic_vector(0 to threads-1);
    signal byp_alu_rf1_isel_fcn             : std_ulogic_vector(0 to 3);
    signal dec_byp_ex4_dcr_ack              : std_ulogic;
    signal byp_perf_tx_events               : std_ulogic_vector(0 to 3*threads-1);
    signal dec_byp_ex3_instr_trace_val      : std_ulogic;
    signal dec_byp_ex3_instr_trace_gate     : std_ulogic;
    signal ex7_we0                          : std_ulogic;
    signal ex7_wa0                          : std_ulogic_vector(0 to 7);
    signal ex7_wd0                          : std_ulogic_vector(64-regsize to 63);
    signal dec_alu_rf1_act                  : std_ulogic;
    signal dec_alu_ex1_act                  : std_ulogic;        
    
    signal siv_54, sov_54                   : std_ulogic_vector(0 to 2);
    signal siv_55, sov_55                   : std_ulogic_vector(0 to 2);
    signal siv_56, sov_56                   : std_ulogic_vector(0 to 4);
    signal siv_57, sov_57                   : std_ulogic_vector(0 to 3);
    signal siv_58, sov_58                   : std_ulogic_vector(0 to 2);
    signal byp_xer_si                       : std_ulogic_vector(0 to 7*threads-1);
    signal gpr_we0_debug                    : std_ulogic_vector(0 to 87);
    signal byp_grp0_debug                   : std_ulogic_vector(0 to 87);
    signal byp_grp1_debug                   : std_ulogic_vector(0 to 87);
    signal byp_grp2_debug                   : std_ulogic_vector(0 to 87);
    signal byp_grp3_debug                   : std_ulogic_vector(0 to 87);
    signal byp_grp4_debug                   : std_ulogic_vector(0 to 87);
    signal byp_grp5_debug                   : std_ulogic_vector(0 to 87);
    signal byp_grp6_debug                   : std_ulogic_vector(0 to 87);
    signal byp_grp7_debug                   : std_ulogic_vector(0 to 87);
    signal byp_grp8_debug                   : std_ulogic_vector(22 to 87);
    signal dec_grp0_debug                   : std_ulogic_vector(0 to 87);
    signal dec_grp1_debug                   : std_ulogic_vector(0 to 87);
    signal dbg_group0, dbg_group1, dbg_group2, dbg_group3,
           dbg_group4, dbg_group5, dbg_group6, dbg_group7, 
           dbg_group8, dbg_group9, dbg_group10,dbg_group11,
           dbg_group12,dbg_group13,dbg_group14,dbg_group15: std_ulogic_vector(0 to 87);
    signal trg_group0 ,trg_group1 ,trg_group2 ,trg_group3 : std_ulogic_vector(0 to 11);

begin

    sg_2 <= sg_2_b;
    fce_2 <= fce_2_b;
    func_sl_thold_2 <= func_sl_thold_2_b;
    func_slp_sl_thold_2 <= func_slp_sl_thold_2_b;
    func_slp_nsl_thold_2 <= func_slp_nsl_thold_2_b;
    func_nsl_thold_2 <= func_nsl_thold_2_b;
    clkoff_dc_b <= clkoff_dc_b_b;
    d_mode_dc <= d_mode_dc_b;
    delay_lclkr_dc <= delay_lclkr_dc_b;
    mpw1_dc_b <= mpw1_dc_b_b;
    mpw2_dc_b <= mpw2_dc_b_b;

    perv_2to1_reg: tri_plat
        generic map (width => 6, expand_type => expand_type)
        port map (vd        => vdd,
                  gd        => gnd,
                  nclk      => nclk,
                  flush     => pc_xu_ccflush_dc,
                  din(0)    => func_slp_sl_thold_2_b(0),
                  din(1)    => func_slp_nsl_thold_2_b,
                  din(2)    => func_sl_thold_2_b(0),
                  din(3)    => func_nsl_thold_2_b,
                  din(4)    => fce_2_b(0),
                  din(5)    => sg_2_b(0),
                  q(0)      => func_slp_sl_thold_1,
                  q(1)      => func_slp_nsl_thold_1,
                  q(2)      => func_sl_thold_1,
                  q(3)      => func_nsl_thold_1,
                  q(4)      => fce_1,
                  q(5)      => sg_1
                  );

    perv_1to0_reg: tri_plat
        generic map (width => 6, expand_type => expand_type)
        port map (vd        => vdd,
                  gd        => gnd,
                  nclk      => nclk,
                  flush     => pc_xu_ccflush_dc,
                  din(0)    => func_slp_sl_thold_1,
                  din(1)    => func_slp_nsl_thold_1,
                  din(2)    => func_sl_thold_1,
                  din(3)    => func_nsl_thold_1,
                  din(4)    => fce_1,
                  din(5)    => sg_1,
                  q(0)      => func_slp_sl_thold_0,
                  q(1)      => func_slp_nsl_thold_0,
                  q(2)      => func_sl_thold_0,
                  q(3)      => func_nsl_thold_0,
                  q(4)      => fce_0,
                  q(5)      => sg_0
                  );

    perv_lcbor_func_nsl: tri_lcbor
        generic map (expand_type => expand_type)
        port map (clkoff_b  => clkoff_dc_b_b,
                  thold     => func_nsl_thold_0,
                  sg        => fce_0,
                  act_dis   => tidn,
                  forcee => func_nsl_force,
                  thold_b   => func_nsl_thold_0_b);

    perv_lcbor_func_sl: tri_lcbor
        generic map (expand_type => expand_type)
        port map (clkoff_b  => clkoff_dc_b_b,
                  thold     => func_sl_thold_0,
                  sg        => sg_0,
                  act_dis   => tidn,
                  forcee => func_sl_force,
                  thold_b   => func_sl_thold_0_b);

    perv_lcbor_func_slp_sl: tri_lcbor
        generic map (expand_type => expand_type)
        port map (clkoff_b  => clkoff_dc_b_b,
                  thold     => func_slp_sl_thold_0,
                  sg        => sg_0,
                  act_dis   => tidn,
                  forcee => func_slp_sl_force,
                  thold_b   => func_slp_sl_thold_0_b);

    perv_lcbor_func_slp_nsl: tri_lcbor
        generic map (expand_type => expand_type)
        port map (clkoff_b  => clkoff_dc_b_b,
                  thold     => func_slp_nsl_thold_0,
                  sg        => fce_0,
                  act_dis   => tidn,
                  forcee => func_slp_nsl_force,
                  thold_b   => func_slp_nsl_thold_0_b);
                  
        so_force           <= sg_0;   
   func_so_thold_0_b       <= not func_sl_thold_0;
    dec_alu_rf1_mul_val         <= fxa_fxb_rf1_mul_val;
    dec_alu_rf1_div_val         <= fxa_fxb_rf1_div_val;

    xu_iu_spr_xer                   <= byp_xer_si;
    dec_cpl_ex2_is_any_store_dac    <= ex2_is_any_store_dac;
    dec_cpl_ex2_is_any_load_dac     <= ex2_is_any_load_dac;

    xu_byp : entity work.xuq_byp(xuq_byp)
    generic map(
        threads                         => threads,
        expand_type                     => expand_type,
        regsize                         => regsize,
        eff_ifar                        => eff_ifar)
    port map(
        nclk                            => nclk,
        vdd                             => vdd,
        gnd                             => gnd,
        d_mode_dc                       => d_mode_dc_b,
        delay_lclkr_dc                  => delay_lclkr_dc_b(4),
        mpw1_dc_b                       => mpw1_dc_b_b(4),
        mpw2_dc_b                       => mpw2_dc_b_b,
        func_sl_force => func_sl_force,
        func_sl_thold_0_b               => func_sl_thold_0_b,
        func_nsl_force => func_nsl_force,
        func_nsl_thold_0_b              => func_nsl_thold_0_b,
        func_slp_sl_force => func_slp_sl_force,
        func_slp_sl_thold_0_b           => func_slp_sl_thold_0_b,
        sg_0                            => sg_0,
        scan_in(0)                      => siv_55(1),
        scan_in(1)                      => siv_56(1),
        scan_out(0)                     => sov_55(1),
        scan_out(1)                     => sov_56(1),
        pc_xu_trace_bus_enable          => pc_xu_trace_bus_enable,
        dec_byp_ex3_instr_trace_val     => dec_byp_ex3_instr_trace_val,
        dec_byp_ex3_instr_trace_gate    => dec_byp_ex3_instr_trace_gate,
        fu_xu_ex4_cr_val                => fu_xu_ex4_cr_val,
        fu_xu_ex4_cr_noflush            => fu_xu_ex4_cr_noflush,
        fu_xu_ex4_cr0                   => fu_xu_ex4_cr0,
        fu_xu_ex4_cr0_bf                => fu_xu_ex4_cr0_bf,
        fu_xu_ex4_cr1                   => fu_xu_ex4_cr1,
        fu_xu_ex4_cr1_bf                => fu_xu_ex4_cr1_bf,
        fu_xu_ex4_cr2                   => fu_xu_ex4_cr2,
        fu_xu_ex4_cr2_bf                => fu_xu_ex4_cr2_bf,
        fu_xu_ex4_cr3                   => fu_xu_ex4_cr3,
        fu_xu_ex4_cr3_bf                => fu_xu_ex4_cr3_bf,
        mm_xu_cr0_eq_valid              => mm_xu_cr0_eq_valid,
        mm_xu_cr0_eq                    => mm_xu_cr0_eq,
        an_ac_stcx_complete             => an_ac_stcx_complete,
        an_ac_stcx_pass                 => an_ac_stcx_pass,
        an_ac_back_inv                  => an_ac_back_inv,
        an_ac_back_inv_addr             => an_ac_back_inv_addr,
        an_ac_back_inv_target_bit3      => an_ac_back_inv_target_bit3,
        xu_ex3_flush                    => xu_ex3_flush,
        xu_ex4_flush                    => xu_ex4_flush,
        xu_ex5_flush                    => xu_ex5_flush,
        fxa_fxb_rf0_is_mfocrf           => fxa_fxb_rf0_is_mfocrf,
        dec_alu_rf1_sel                 => dec_alu_rf1_sel(2 to 2),
        dec_byp_rf1_rs0_sel             => dec_byp_rf1_rs0_sel,
        dec_byp_rf1_rs1_sel             => dec_byp_rf1_rs1_sel,
        dec_byp_rf1_rs2_sel             => dec_byp_rf1_rs2_sel,
        dec_byp_rf1_imm                 => dec_byp_rf1_imm,
        dec_byp_rf1_instr               => dec_byp_rf1_instr,
        dec_byp_rf1_cr_so_update        => dec_byp_rf1_cr_so_update,
        dec_byp_ex3_val                 => dec_byp_ex3_val,
        dec_byp_rf1_cr_we               => dec_byp_rf1_cr_we,
        dec_byp_rf1_is_mcrf             => dec_byp_rf1_is_mcrf,
        dec_byp_rf1_use_crfld0          => dec_byp_rf1_use_crfld0,
        dec_byp_rf1_alu_cmp             => dec_byp_rf1_alu_cmp,
        dec_byp_rf1_is_mtcrf            => dec_byp_rf1_is_mtcrf,
        dec_byp_rf1_is_mtocrf           => dec_byp_rf1_is_mtocrf,
        dec_byp_rf1_is_isel             => dec_rf1_is_isel,
        dec_byp_rf1_byp_val             => dec_byp_rf1_byp_val,
        dec_byp_ex4_is_eratsxr          => dec_byp_ex4_is_eratsxr,
        dec_rf1_tid                     => dec_rf1_tid,
        dec_ex1_tid                     => dec_ex1_tid,
        dec_ex2_tid                     => dec_ex2_tid,
        dec_ex3_tid                     => dec_ex3_tid,
        dec_ex5_tid                     => dec_ex5_tid,
        dec_byp_rf1_ca_used             => dec_byp_rf1_ca_used,
        dec_byp_rf1_ov_used             => dec_byp_rf1_ov_used,
        dec_byp_ex4_dp_instr            => dec_byp_ex4_dp_instr,
        dec_byp_ex4_mtdp_val            => dec_byp_ex4_mtdp_val,
        dec_byp_ex4_mfdp_val            => dec_byp_ex4_mfdp_val,
        lsu_xu_ex4_mtdp_cr_status       => lsu_xu_ex4_mtdp_cr_status,
        lsu_xu_ex4_mfdp_cr_status       => lsu_xu_ex4_mfdp_cr_status,
        dec_byp_ex4_is_wchkall          => dec_byp_ex4_is_wchkall,
        lsu_xu_ex4_cr_upd               => lsu_xu_ex4_cr_upd,
        lsu_xu_ex5_cr_rslt              => lsu_xu_ex5_cr_rslt,
        fxa_fxb_rf1_do0                 => fxa_fxb_rf1_do0,
        fxa_fxb_rf1_do1                 => fxa_fxb_rf1_do1,
        fxa_fxb_rf1_do2                 => fxa_fxb_rf1_do2,
        spr_byp_ex4_is_mtxer            => spr_byp_ex4_is_mtxer,
        lsu_xu_rot_rel_data             => lsu_xu_rot_rel_data,
        alu_byp_ex2_cr_recform          => alu_byp_ex2_cr_recform,
        alu_byp_ex5_cr_mul              => alu_byp_ex5_cr_mul,
        alu_byp_ex3_cr_div              => alu_byp_ex3_cr_div,
        alu_byp_ex2_xer                 => alu_byp_ex2_xer,
        alu_byp_ex5_xer_mul             => alu_byp_ex5_xer_mul,
        alu_byp_ex3_xer_div             => alu_byp_ex3_xer_div,
        alu_ex4_mul_done                => alu_ex4_mul_done,
        alu_ex2_div_done                => alu_ex2_div_done,
        mux_cpl_ex4_rt                  => mux_cpl_ex4_rt, 
        byp_spr_ex6_rt                  => byp_spr_ex6_rt, 
        fxb_fxa_ex7_wd0                 => ex7_wd0,
        xu_ex1_rs_is                    => xu_ex1_rs_is,
        xu_ex1_ra_entry                 => xu_ex1_ra_entry,
        xu_ex1_rb                       => xu_ex1_rb,
        xu_lsu_ex1_store_data           => xu_lsu_ex1_store_data,
        fxu_spr_ex1_rs2                 => fxu_spr_ex1_rs2,
        fxu_spr_ex1_rs1                 => fxu_spr_ex1_rs1,
        fxu_spr_ex1_rs0                 => fxu_spr_ex1_rs0,
        byp_xer_si                      => byp_xer_si,
        byp_dec_rf1_xer_ca              => byp_dec_rf1_xer_ca,
        byp_alu_ex1_rs0                 => byp_alu_ex1_rs0,
        byp_alu_ex1_rs1                 => byp_alu_ex1_rs1,
        byp_alu_ex1_mulsrc_0            => byp_alu_ex1_mulsrc_0,
        byp_alu_ex1_mulsrc_1            => byp_alu_ex1_mulsrc_1,
        byp_alu_ex1_divsrc_0            => byp_alu_ex1_divsrc_0,
        byp_alu_ex1_divsrc_1            => byp_alu_ex1_divsrc_1,
        byp_cpl_ex1_cr_bit              => byp_cpl_ex1_cr_bit,
        dec_byp_ex5_instr               => dec_byp_ex5_instr,
        dec_byp_rf0_act                 => dec_byp_rf0_act,
        xu_lsu_ex1_add_src0             => xu_lsu_ex1_add_src0,
        xu_lsu_ex1_add_src1             => xu_lsu_ex1_add_src1,
        byp_alu_rf1_isel_fcn            => byp_alu_rf1_isel_fcn,
        spr_msr_cm                      => spr_msr_cm,
        xu_ex4_rs_data                  => xu_ex4_rs_data,
        dec_byp_ex1_spr_sel             => dec_byp_ex1_spr_sel,
        slowspr_val_in                  => slowspr_val_in,
        slowspr_rw_in                   => slowspr_rw_in,
        slowspr_etid_in                 => slowspr_etid_in,
        slowspr_addr_in                 => slowspr_addr_in,
        slowspr_data_in                 => slowspr_data_in,
        slowspr_done_in                 => slowspr_done_in,
        dec_byp_ex4_dcr_ack             => dec_byp_ex4_dcr_ack,
        an_ac_dcr_act                   => an_ac_dcr_act,
        an_ac_dcr_read                  => an_ac_dcr_read,
        an_ac_dcr_etid                  => an_ac_dcr_etid,
        an_ac_dcr_data                  => an_ac_dcr_data,
        an_ac_dcr_done                  => an_ac_dcr_done,
        xu_iu_slowspr_done              => xu_iu_slowspr_done,
        mux_cpl_slowspr_done            => mux_cpl_slowspr_done,
        mux_cpl_slowspr_flush           => mux_cpl_slowspr_flush,
        lsu_xu_ex5_wren                 => lsu_xu_ex5_wren,
        dec_byp_ex4_is_mfcr             => dec_byp_ex4_is_mfcr,
        spr_byp_ex4_is_mfxer            => spr_byp_ex4_is_mfxer,
        dec_byp_ex3_tlb_sel             => dec_byp_ex3_tlb_sel,
        alu_byp_ex1_log_rt              => alu_byp_ex1_log_rt,     
        alu_byp_ex2_rt                  => alu_byp_ex2_rt,
        cpl_byp_ex3_spr_rt              => cpl_byp_ex3_spr_rt,
        spr_byp_ex3_spr_rt              => spr_byp_ex3_spr_rt,
        fspr_byp_ex3_spr_rt             => fspr_byp_ex3_spr_rt,
        alu_byp_ex5_mul_rt              => alu_byp_ex5_mul_rt,
        alu_byp_ex3_div_rt              => alu_byp_ex3_div_rt,
        lsu_xu_ex4_tlb_data             => lsu_xu_ex4_tlb_data,
         iu_xu_ex4_tlb_data             => iu_xu_ex4_tlb_data,
        lsu_xu_rot_ex6_data_b           => lsu_xu_rot_ex6_data_b,
        xu_mm_derat_epn                 => xu_mm_derat_epn,
        xu_pc_ram_data                  => xu_pc_ram_data,
        byp_perf_tx_events              => byp_perf_tx_events,
        byp_grp0_debug                  => byp_grp0_debug,
        byp_grp1_debug                  => byp_grp1_debug,
        byp_grp2_debug                  => byp_grp2_debug,
        byp_grp3_debug                  => byp_grp3_debug(15 to 87),
        byp_grp4_debug                  => byp_grp4_debug(14 to 87),
        byp_grp5_debug                  => byp_grp5_debug(15 to 87),
        byp_grp6_debug                  => byp_grp6_debug,
        byp_grp7_debug                  => byp_grp7_debug,
        byp_grp8_debug                  => byp_grp8_debug
        );

    xu_dec_b : entity work.xuq_dec_b(xuq_dec_b)
    generic map(
        expand_type                         => expand_type,
        threads                             => threads,
        regmode                             => regmode,
        regsize                             => regsize,
        cl_size                             => cl_size,
        real_data_add                       => real_data_add,
        eff_ifar                            => eff_ifar)
    port map(
        nclk                                => nclk,
        vdd                                 => vdd,
        gnd                                 => gnd,
        d_mode_dc                           => d_mode_dc_b,
        delay_lclkr_dc                      => delay_lclkr_dc_b(4),
        mpw1_dc_b                           => mpw1_dc_b_b(4),
        mpw2_dc_b                           => mpw2_dc_b_b,
        func_nsl_force => func_nsl_force,
        func_nsl_thold_0_b                  => func_nsl_thold_0_b,
        func_sl_force => func_sl_force,
        func_sl_thold_0_b                   => func_sl_thold_0_b,
        func_slp_sl_force => func_slp_sl_force,
        func_slp_sl_thold_0_b               => func_slp_sl_thold_0_b,
        func_slp_nsl_force => func_slp_nsl_force,
        func_slp_nsl_thold_0_b              => func_slp_nsl_thold_0_b,
        sg_0                                => sg_0,
        scan_in                             => siv_54(1),
        scan_out                            => sov_54(1),
        pc_xu_trace_bus_enable              => pc_xu_trace_bus_enable,
        pc_xu_instr_trace_mode              => pc_xu_instr_trace_mode,
        pc_xu_instr_trace_tid               => pc_xu_instr_trace_tid,        
        dec_byp_ex3_instr_trace_val         => dec_byp_ex3_instr_trace_val,
        dec_byp_ex3_instr_trace_gate        => dec_byp_ex3_instr_trace_gate,
        dec_cpl_rf1_instr_trace_val         => dec_cpl_rf1_instr_trace_val,
        dec_cpl_rf1_instr_trace_type        => dec_cpl_rf1_instr_trace_type,
        dec_cpl_ex3_instr_trace_val         => dec_cpl_ex3_instr_trace_val,
        xu_lsu_ex2_instr_trace_val          => xu_lsu_ex2_instr_trace_val,
        cpl_dec_in_ucode                    => cpl_dec_in_ucode,
        slowspr_val_in                      => slowspr_val_in,
        slowspr_rw_in                       => slowspr_rw_in,
        slowspr_etid_in                     => slowspr_etid_in,
        dec_byp_ex4_dcr_ack                 => dec_byp_ex4_dcr_ack,
        an_ac_dcr_act                       => an_ac_dcr_act,
        an_ac_dcr_val                       => an_ac_dcr_val,
        an_ac_dcr_read                      => an_ac_dcr_read,
        an_ac_dcr_etid                      => an_ac_dcr_etid,
        an_ac_dcr_ack                       => an_ac_dcr_ack,
        mm_xu_mmucr0_0_tlbsel               => mm_xu_mmucr0_0_tlbsel,
        mm_xu_mmucr0_1_tlbsel               => mm_xu_mmucr0_1_tlbsel,
        mm_xu_mmucr0_2_tlbsel               => mm_xu_mmucr0_2_tlbsel,
        mm_xu_mmucr0_3_tlbsel               => mm_xu_mmucr0_3_tlbsel,
        xu_mm_rf1_is_tlbsxr                 => xu_mm_rf1_is_tlbsxr,
        fxb_fxa_ex7_we0                     => ex7_we0,
        fxb_fxa_ex7_wa0                     => ex7_wa0,
        dec_byp_ex4_is_mfcr                 => dec_byp_ex4_is_mfcr,
        dec_byp_ex3_tlb_sel                 => dec_byp_ex3_tlb_sel,
        xu_rf1_flush                        => xu_rf1_flush,
        xu_ex1_flush                        => xu_ex1_flush,
        xu_ex2_flush                        => xu_ex2_flush,
        xu_ex3_flush                        => xu_ex3_flush,
        xu_ex4_flush                        => xu_ex4_flush,
        xu_ex5_flush                        => xu_ex5_flush,
        fxa_fxb_rf0_val                     => fxa_fxb_rf0_val,
        fxa_fxb_rf0_issued                  => fxa_fxb_rf0_issued,
        fxa_fxb_rf0_ucode_val               => fxa_fxb_rf0_ucode_val,
        fxa_fxb_rf0_act                     => fxa_fxb_rf0_act,
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
        fxa_fxb_rf0_xu_epid_instr           => fxa_fxb_rf0_xu_epid_instr,
        fxa_fxb_rf0_axu_is_extload          => fxa_fxb_rf0_axu_is_extload,
        fxa_fxb_rf0_axu_is_extstore         => fxa_fxb_rf0_axu_is_extstore,
        fxa_fxb_rf0_3src_instr              => fxa_fxb_rf0_3src_instr,
        fxa_fxb_rf0_gpr0_zero               => fxa_fxb_rf0_gpr0_zero,
        fxa_fxb_rf0_use_imm                 => fxa_fxb_rf0_use_imm,
        fxa_fxb_rf1_muldiv_coll             => fxa_fxb_rf1_muldiv_coll,
        alu_dec_ex1_ipb_ba                  => alu_dec_ex1_ipb_ba,
        alu_dec_div_need_hole               => alu_dec_div_need_hole,
        dec_byp_rf1_rs0_sel                 => dec_byp_rf1_rs0_sel,
        dec_byp_rf1_rs1_sel                 => dec_byp_rf1_rs1_sel,
        dec_byp_rf1_rs2_sel                 => dec_byp_rf1_rs2_sel,
        dec_byp_rf1_instr                   => dec_byp_rf1_instr,
        dec_byp_rf1_cr_so_update            => dec_byp_rf1_cr_so_update,
        dec_byp_ex3_val                     => dec_byp_ex3_val,
        dec_byp_rf1_cr_we                   => dec_byp_rf1_cr_we,
        dec_byp_rf1_is_mcrf                 => dec_byp_rf1_is_mcrf,
        dec_byp_rf1_use_crfld0              => dec_byp_rf1_use_crfld0,
        dec_byp_rf1_alu_cmp                 => dec_byp_rf1_alu_cmp,
        dec_byp_rf1_is_mtcrf                => dec_byp_rf1_is_mtcrf,
        dec_byp_rf1_is_mtocrf               => dec_byp_rf1_is_mtocrf,
        dec_byp_rf1_byp_val                 => dec_byp_rf1_byp_val,
        dec_byp_ex4_is_eratsxr              => dec_byp_ex4_is_eratsxr,
        dec_byp_rf1_ca_used                 => dec_byp_rf1_ca_used,
        dec_byp_rf1_ov_used                 => dec_byp_rf1_ov_used,
        dec_byp_ex4_dp_instr                => dec_byp_ex4_dp_instr,
        dec_byp_ex4_mtdp_val                => dec_byp_ex4_mtdp_val,
        dec_byp_ex4_mfdp_val                => dec_byp_ex4_mfdp_val,
        dec_byp_ex4_is_wchkall              => dec_byp_ex4_is_wchkall,
        dec_alu_rf1_act                             => dec_alu_rf1_act,
        dec_alu_ex1_act                             => dec_alu_ex1_act,
        dec_alu_rf1_sel                     => dec_alu_rf1_sel,
        dec_alu_rf1_add_rs0_inv             => dec_alu_rf1_add_rs0_inv,
        dec_alu_rf1_add_ci                  => dec_alu_rf1_add_ci,
        dec_alu_rf1_is_cmpl                 => dec_alu_rf1_is_cmpl,
        dec_alu_rf1_tw_cmpsel               => dec_alu_rf1_tw_cmpsel,
        dec_rf1_is_isel                     => dec_rf1_is_isel,
        dec_alu_rf1_xer_ov_update           => dec_alu_rf1_xer_ov_update,
        dec_alu_rf1_xer_ca_update           => dec_alu_rf1_xer_ca_update,
        dec_alu_rf1_sh_right                => dec_alu_rf1_sh_right,
        dec_alu_rf1_sh_word                 => dec_alu_rf1_sh_word,
        dec_alu_rf1_sgnxtd_byte             => dec_alu_rf1_sgnxtd_byte,
        dec_alu_rf1_sgnxtd_half             => dec_alu_rf1_sgnxtd_half,
        dec_alu_rf1_sgnxtd_wd               => dec_alu_rf1_sgnxtd_wd,
        dec_alu_rf1_sra_dw                  => dec_alu_rf1_sra_dw,
        dec_alu_rf1_sra_wd                  => dec_alu_rf1_sra_wd,
        dec_alu_rf1_chk_shov_dw             => dec_alu_rf1_chk_shov_dw,
        dec_alu_rf1_chk_shov_wd             => dec_alu_rf1_chk_shov_wd,
        dec_alu_rf1_use_me_ins_hi           => dec_alu_rf1_use_me_ins_hi,
        dec_alu_rf1_use_me_ins_lo           => dec_alu_rf1_use_me_ins_lo,
        dec_alu_rf1_use_mb_ins_hi           => dec_alu_rf1_use_mb_ins_hi,
        dec_alu_rf1_use_mb_ins_lo           => dec_alu_rf1_use_mb_ins_lo,
        dec_alu_rf1_use_me_rb_hi            => dec_alu_rf1_use_me_rb_hi,
        dec_alu_rf1_use_me_rb_lo            => dec_alu_rf1_use_me_rb_lo,
        dec_alu_rf1_use_mb_rb_hi            => dec_alu_rf1_use_mb_rb_hi,
        dec_alu_rf1_use_mb_rb_lo            => dec_alu_rf1_use_mb_rb_lo,
        dec_alu_rf1_use_rb_amt_hi           => dec_alu_rf1_use_rb_amt_hi,
        dec_alu_rf1_use_rb_amt_lo           => dec_alu_rf1_use_rb_amt_lo,
        dec_alu_rf1_zm_ins                  => dec_alu_rf1_zm_ins,
        dec_alu_rf1_log_fcn                 => dec_alu_rf1_log_fcn,
        dec_alu_rf1_me_ins_b                => dec_alu_rf1_me_ins_b,
        dec_alu_rf1_mb_ins                  => dec_alu_rf1_mb_ins,
        dec_alu_rf1_sh_amt                  => dec_alu_rf1_sh_amt,
        dec_alu_rf1_mb_gt_me                => dec_alu_rf1_mb_gt_me,
        alu_ex3_mul_done                    => alu_ex3_mul_done,
        alu_ex2_div_done                    => alu_ex2_div_done,
        dec_alu_rf1_mul_recform             => dec_alu_rf1_mul_recform,
        dec_alu_rf1_div_recform             => dec_alu_rf1_div_recform,
        dec_alu_rf1_mul_ret                 => dec_alu_rf1_mul_ret,
        dec_alu_rf1_mul_sign                => dec_alu_rf1_mul_sign,
        dec_alu_rf1_mul_size                => dec_alu_rf1_mul_size,
        dec_alu_rf1_mul_imm                 => dec_alu_rf1_mul_imm,
        dec_alu_rf1_div_sign                => dec_alu_rf1_div_sign,
        dec_alu_rf1_div_size                => dec_alu_rf1_div_size,
        dec_alu_rf1_div_extd                => dec_alu_rf1_div_extd,
        dec_alu_ex1_is_cmp                  => dec_alu_ex1_is_cmp,
        dec_alu_rf1_select_64bmode          => dec_alu_rf1_select_64bmode,
        dec_cpl_rf1_ifar                    => dec_cpl_rf1_ifar,
        dec_byp_rf1_imm                     => dec_byp_rf1_imm,
        dec_rf1_tid                         => dec_rf1_tid,
        dec_ex1_tid                         => dec_ex1_tid,
        dec_ex2_tid                         => dec_ex2_tid,
        dec_ex3_tid                         => dec_ex3_tid,
        dec_ex4_tid                         => dec_ex4_tid,
        dec_ex5_tid                         => dec_ex5_tid,
        dec_byp_ex1_spr_sel                 => dec_byp_ex1_spr_sel,
        dec_spr_ex1_is_mtspr                => dec_spr_ex1_is_mtspr,
        dec_spr_ex1_is_mfspr                => dec_spr_ex1_is_mfspr,
        dec_cpl_rf1_val                     => dec_cpl_rf1_val,
        dec_cpl_rf1_issued                  => dec_cpl_rf1_issued,
        dec_spr_rf1_val                     => dec_spr_rf1_val,
        dec_spr_ex4_val                     => dec_spr_ex4_val,
        dec_fspr_ex1_instr                  => dec_fspr_ex1_instr,
        dec_fspr_ex6_val                    => dec_fspr_ex6_val,
        dec_cpl_rf1_instr                   => dec_cpl_rf1_instr,
        dec_cpl_rf1_pred_taken_cnt          => dec_cpl_rf1_pred_taken_cnt,
        dec_cpl_ex1_is_slowspr_wr           => dec_cpl_ex1_is_slowspr_wr,
        dec_cpl_ex3_ddmh_en                 => dec_cpl_ex3_ddmh_en,
        dec_cpl_ex3_back_inv                => dec_cpl_ex3_back_inv,
        dec_cpl_ex2_error                   => dec_cpl_ex2_error,
        dec_cpl_ex2_match                   => dec_cpl_ex2_match,
        dec_cpl_ex2_is_ucode                => dec_cpl_ex2_is_ucode,
        dec_cpl_ex3_is_any_store            => dec_cpl_ex3_is_any_store,
        ex2_is_any_store_dac                => ex2_is_any_store_dac,
        ex2_is_any_load_dac                 => ex2_is_any_load_dac,
        dec_cpl_ex3_instr_priv              => dec_cpl_ex3_instr_priv,
        dec_cpl_ex1_epid_instr              => dec_cpl_ex1_epid_instr,
        dec_cpl_ex2_illegal_op              => dec_cpl_ex2_illegal_op,
        dec_cpl_ex3_mtdp_nr                 => dec_cpl_ex3_mtdp_nr,
        dec_cpl_ex3_mult_coll               => dec_cpl_ex3_mult_coll,
        dec_cpl_ex3_tlb_illeg               => dec_cpl_ex3_tlb_illeg,
        dec_cpl_ex3_axu_instr_type          => dec_cpl_ex3_axu_instr_type,
        dec_cpl_ex3_instr_hypv              => dec_cpl_ex3_instr_hypv,
        dec_cpl_rf1_ucode_val               => dec_cpl_rf1_ucode_val,
        byp_dec_rf1_xer_ca                  => byp_dec_rf1_xer_ca,
        spr_dec_rf1_epcr_dgtmi              => spr_dec_rf1_epcr_dgtmi,
        spr_dec_rf1_msr_ucle                => spr_dec_rf1_msr_ucle,
        spr_dec_rf1_msrp_uclep              => spr_dec_rf1_msrp_uclep,
        xu_lsu_rf0_act                      => xu_lsu_rf0_act,
        xu_lsu_rf1_cache_acc                => xu_lsu_rf1_cache_acc,
        xu_lsu_rf1_axu_op_val               => xu_lsu_rf1_axu_op_val,
        xu_lsu_rf1_axu_ldst_falign          => xu_lsu_rf1_axu_ldst_falign,
        xu_lsu_rf1_axu_ldst_fexcpt          => xu_lsu_rf1_axu_ldst_fexcpt,
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
        xu_lsu_rf1_algebraic                => xu_lsu_rf1_algebraic,
        xu_lsu_rf1_byte_rev                 => xu_lsu_rf1_byte_rev,
        xu_lsu_rf1_src_gpr                  => xu_lsu_rf1_src_gpr,
        xu_lsu_rf1_src_axu                  => xu_lsu_rf1_src_axu,
        xu_lsu_rf1_src_dp                   => xu_lsu_rf1_src_dp,
        xu_lsu_rf1_targ_gpr                 => xu_lsu_rf1_targ_gpr,
        xu_lsu_rf1_targ_axu                 => xu_lsu_rf1_targ_axu,
        xu_lsu_rf1_targ_dp                  => xu_lsu_rf1_targ_dp,
        xu_lsu_ex1_rotsel_ovrd              => xu_lsu_ex1_rotsel_ovrd,
        lsu_xu_ex5_wren                     => lsu_xu_ex5_wren,
        lsu_xu_rel_wren                     => lsu_xu_rel_wren,
        lsu_xu_rel_ta_gpr                   => lsu_xu_rel_ta_gpr,
        lsu_xu_need_hole                    => lsu_xu_need_hole,
        xu_lsu_rf1_src0_vld                 => xu_lsu_rf1_src0_vld,
        xu_lsu_rf1_src0_reg                 => xu_lsu_rf1_src0_reg,
        xu_lsu_rf1_src1_vld                 => xu_lsu_rf1_src1_vld,
        xu_lsu_rf1_src1_reg                 => xu_lsu_rf1_src1_reg,
        xu_lsu_rf1_targ_vld                 => xu_lsu_rf1_targ_vld,
        xu_lsu_rf1_targ_reg                 => xu_lsu_rf1_targ_reg,
        xu_bx_ex1_mtdp_val                  => xu_bx_ex1_mtdp_val,
        xu_bx_ex1_mfdp_val                  => xu_bx_ex1_mfdp_val,
         xu_bx_ex1_ipc_thrd                 =>  xu_bx_ex1_ipc_thrd,
         xu_bx_ex2_ipc_ba                   =>  xu_bx_ex2_ipc_ba,
         xu_bx_ex2_ipc_sz                   =>  xu_bx_ex2_ipc_sz,
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
        xu_iu_rf1_val                       => xu_iu_rf1_val,
        xu_rf1_val                          => xu_rf1_val,
        xu_rf1_is_tlbre                     => xu_rf1_is_tlbre,
        xu_rf1_is_tlbwe                     => xu_rf1_is_tlbwe,
        xu_rf1_is_tlbsx                     => xu_rf1_is_tlbsx,
        xu_rf1_is_tlbsrx                    => xu_rf1_is_tlbsrx,
        xu_rf1_is_tlbivax                   => xu_rf1_is_tlbivax,
        xu_rf1_is_tlbilx                    => xu_rf1_is_tlbilx,
        xu_rf1_is_eratre                    => xu_rf1_is_eratre,
        xu_rf1_is_eratwe                    => xu_rf1_is_eratwe,
        xu_rf1_is_eratsx                    => xu_rf1_is_eratsx,
        xu_rf1_is_eratsrx                   => xu_rf1_is_eratsrx,
        xu_rf1_is_erativax                  => xu_rf1_is_erativax,
        xu_rf1_is_eratilx                   => xu_rf1_is_eratilx,
        xu_ex1_is_isync                     => xu_ex1_is_isync,
        xu_ex1_is_csync                     => xu_ex1_is_csync,
        xu_lsu_rf1_derat_act                => xu_lsu_rf1_derat_act,
        xu_lsu_rf1_derat_is_load            => xu_lsu_rf1_derat_is_load,
        xu_lsu_rf1_derat_is_store           => xu_lsu_rf1_derat_is_store,
        xu_rf1_ws                           => xu_rf1_ws,
        xu_rf1_t                            => xu_rf1_t,
        lsu_xu_is2_back_inv                 => lsu_xu_is2_back_inv,
        lsu_xu_is2_back_inv_addr            => lsu_xu_is2_back_inv_addr,
        xu_iu_ex6_pri                       => xu_iu_ex6_pri,
        xu_iu_ex6_pri_val                   => xu_iu_ex6_pri_val,
        fxb_fxa_ex6_clear_barrier           => fxb_fxa_ex6_clear_barrier,
        xu_iu_ex5_gshare                    => xu_iu_ex5_gshare,
        xu_iu_ex5_getNIA                    => xu_iu_ex5_getNIA,
        xu_iu_need_hole                     => xu_iu_need_hole,
        byp_xer_si                          => byp_xer_si,
        xu_iu_ex5_val                       => xu_iu_ex5_val,
        xu_iu_ex5_tid                       => xu_iu_ex5_tid,
        xu_iu_ex5_br_update                 => xu_iu_ex5_br_update,
        xu_iu_ex5_br_hist                   => xu_iu_ex5_br_hist,
        xu_iu_ex5_bclr                      => xu_iu_ex5_bclr,
        xu_iu_ex5_lk                        => xu_iu_ex5_lk,
        xu_iu_ex5_bh                        => xu_iu_ex5_bh,
        dec_byp_ex5_instr                   => dec_byp_ex5_instr,
        dec_byp_rf0_act                     => dec_byp_rf0_act,
        spr_msr_cm                          => spr_msr_cm,
        spr_ccr2_notlb                      => spr_ccr2_notlb,
        spr_dec_spr_xucr0_ssdly             => spr_dec_spr_xucr0_ssdly,
        spr_ccr2_en_attn                    => spr_ccr2_en_attn,
        spr_ccr2_en_pc                      => spr_ccr2_en_pc,
        spr_ccr2_en_ditc                    => spr_ccr2_en_ditc,
        spr_ccr2_en_icswx                   => spr_ccr2_en_icswx,
        spr_ccr2_en_dcr                     => spr_ccr2_en_dcr,
        spr_xucr0_clkg_ctl                  => spr_xucr0_clkg_ctl,
        spr_bit_act                         => spr_bit_act,
        byp_grp3_debug                      => byp_grp3_debug(0 to 14),
        byp_grp4_debug                      => byp_grp4_debug(0 to 13),
        byp_grp5_debug                      => byp_grp5_debug(0 to 14),
        dec_grp0_debug                      => dec_grp0_debug,
        dec_grp1_debug                      => dec_grp1_debug
        );

    xu_alu : entity work.xuq_alu(xuq_alu)
    generic map(
        expand_type                     => expand_type,
        regmode                         => regmode,
        a2mode                          => a2mode,
        threads                         => threads,
        dc_size                         => dc_size,
        fxu_synth                       => fxu_synth)
    port map(
        nclk                            => nclk,
        vdd                             => vdd,
        gnd                             => gnd,
        d_mode_dc                       => d_mode_dc_b,
        delay_lclkr_dc                  => delay_lclkr_dc_b(4),
        mpw1_dc_b                       => mpw1_dc_b_b(4),
        mpw2_dc_b                       => mpw2_dc_b_b,
        func_sl_force => func_sl_force,
        func_sl_thold_0_b               => func_sl_thold_0_b,
        sg_0                            => sg_0,
        scan_in(0)                      => siv_57(1),
        scan_in(1)                      => siv_58(1),
        scan_out(0)                     => sov_57(1),
        scan_out(1)                     => sov_58(1),
        spr_msr_cm                      => spr_msr_cm,
        dec_alu_rf1_act                             => dec_alu_rf1_act,
        dec_alu_ex1_act                             => dec_alu_ex1_act,
        dec_alu_rf1_sel                 => dec_alu_rf1_sel,
        dec_alu_rf1_add_rs0_inv         => dec_alu_rf1_add_rs0_inv,
        dec_alu_rf1_add_ci              => dec_alu_rf1_add_ci,
        dec_alu_rf1_is_cmpl             => dec_alu_rf1_is_cmpl,
        dec_alu_rf1_tw_cmpsel           => dec_alu_rf1_tw_cmpsel,
        dec_alu_rf1_xer_ov_update       => dec_alu_rf1_xer_ov_update,
        dec_alu_rf1_xer_ca_update       => dec_alu_rf1_xer_ca_update,
        dec_alu_rf1_sh_right            => dec_alu_rf1_sh_right,
        dec_alu_rf1_sh_word             => dec_alu_rf1_sh_word,
        dec_alu_rf1_sgnxtd_byte         => dec_alu_rf1_sgnxtd_byte,
        dec_alu_rf1_sgnxtd_half         => dec_alu_rf1_sgnxtd_half,
        dec_alu_rf1_sgnxtd_wd           => dec_alu_rf1_sgnxtd_wd,
        dec_alu_rf1_sra_dw              => dec_alu_rf1_sra_dw,
        dec_alu_rf1_sra_wd              => dec_alu_rf1_sra_wd,
        dec_alu_rf1_chk_shov_dw         => dec_alu_rf1_chk_shov_dw,
        dec_alu_rf1_chk_shov_wd         => dec_alu_rf1_chk_shov_wd,
        dec_alu_rf1_use_me_ins_hi       => dec_alu_rf1_use_me_ins_hi,
        dec_alu_rf1_use_me_ins_lo       => dec_alu_rf1_use_me_ins_lo,
        dec_alu_rf1_use_mb_ins_hi       => dec_alu_rf1_use_mb_ins_hi,
        dec_alu_rf1_use_mb_ins_lo       => dec_alu_rf1_use_mb_ins_lo,
        dec_alu_rf1_use_me_rb_hi        => dec_alu_rf1_use_me_rb_hi,
        dec_alu_rf1_use_me_rb_lo        => dec_alu_rf1_use_me_rb_lo,
        dec_alu_rf1_use_mb_rb_hi        => dec_alu_rf1_use_mb_rb_hi,
        dec_alu_rf1_use_mb_rb_lo        => dec_alu_rf1_use_mb_rb_lo,
        dec_alu_rf1_use_rb_amt_hi       => dec_alu_rf1_use_rb_amt_hi,
        dec_alu_rf1_use_rb_amt_lo       => dec_alu_rf1_use_rb_amt_lo,
        dec_alu_rf1_zm_ins              => dec_alu_rf1_zm_ins,
        dec_alu_rf1_log_fcn             => dec_alu_rf1_log_fcn,
        dec_alu_rf1_me_ins_b            => dec_alu_rf1_me_ins_b,
        dec_alu_rf1_mb_ins              => dec_alu_rf1_mb_ins,
        dec_alu_rf1_sh_amt              => dec_alu_rf1_sh_amt,
        dec_alu_rf1_mb_gt_me            => dec_alu_rf1_mb_gt_me,
        byp_alu_rf1_isel_fcn            => byp_alu_rf1_isel_fcn,
        fxa_fxb_ex1_hold_ctr_flush      => fxa_fxb_ex1_hold_ctr_flush,
        dec_ex2_tid                     => dec_ex2_tid,
        dec_ex4_tid                     => dec_ex4_tid,
        dec_alu_rf1_mul_recform         => dec_alu_rf1_mul_recform,
        dec_alu_rf1_div_recform         => dec_alu_rf1_div_recform,
        dec_alu_rf1_mul_val             => dec_alu_rf1_mul_val,
        dec_alu_rf1_mul_ret             => dec_alu_rf1_mul_ret,
        dec_alu_rf1_mul_sign            => dec_alu_rf1_mul_sign,
        dec_alu_rf1_mul_size            => dec_alu_rf1_mul_size,
        dec_alu_rf1_mul_imm             => dec_alu_rf1_mul_imm,
        dec_alu_rf1_div_val             => dec_alu_rf1_div_val,
        dec_alu_rf1_div_sign            => dec_alu_rf1_div_sign,
        dec_alu_rf1_div_size            => dec_alu_rf1_div_size,
        dec_alu_rf1_div_extd            => dec_alu_rf1_div_extd,
        fxa_fxb_rf1_div_ctr             => fxa_fxb_rf1_div_ctr,
        dec_alu_ex1_is_cmp              => dec_alu_ex1_is_cmp,
        dec_alu_rf1_select_64bmode      => dec_alu_rf1_select_64bmode,
        alu_cpl_ex3_trap_val            => alu_cpl_ex3_trap_val,
        byp_alu_ex1_rs0                 => byp_alu_ex1_rs0,
        byp_alu_ex1_rs1                 => byp_alu_ex1_rs1,
        byp_alu_ex1_mulsrc_0            => byp_alu_ex1_mulsrc_0,
        byp_alu_ex1_mulsrc_1            => byp_alu_ex1_mulsrc_1,
        byp_alu_ex1_divsrc_0            => byp_alu_ex1_divsrc_0,
        byp_alu_ex1_divsrc_1            => byp_alu_ex1_divsrc_1,
        xu_ex1_eff_addr_int             => xu_ex1_eff_addr_int,
        xu_ex2_eff_addr                 => xu_ex2_eff_addr,
        alu_byp_ex5_mul_rt              => alu_byp_ex5_mul_rt,
        alu_byp_ex3_div_rt              => alu_byp_ex3_div_rt,
        alu_ex2_div_done                => alu_ex2_div_done,
        alu_dec_ex1_ipb_ba              => alu_dec_ex1_ipb_ba,
        alu_dec_div_need_hole           => alu_dec_div_need_hole,
        alu_ex3_mul_done                => alu_ex3_mul_done,
        alu_ex4_mul_done                => alu_ex4_mul_done,
        alu_byp_ex2_cr_recform          => alu_byp_ex2_cr_recform,
        alu_byp_ex5_cr_mul              => alu_byp_ex5_cr_mul,
        alu_byp_ex3_cr_div              => alu_byp_ex3_cr_div,
        alu_byp_ex2_xer                 => alu_byp_ex2_xer,
        alu_byp_ex5_xer_mul             => alu_byp_ex5_xer_mul,
        alu_byp_ex3_xer_div             => alu_byp_ex3_xer_div,
        alu_byp_ex1_log_rt              => alu_byp_ex1_log_rt, 
        alu_byp_ex2_rt                  => alu_byp_ex2_rt);

    mux_spr_ex2_rt              <= alu_byp_ex2_rt;
    alu_byp_ex2_rt_b <= alu_byp_ex2_rt;

    xu_perv : entity work.xuq_perv(xuq_perv)
    generic map(
         expand_type => expand_type)
    port map(
         vdd                        => vdd,
         gnd                        => gnd,
         nclk                       => nclk,
         pc_xu_sg_3                 => pc_xu_sg_3,
         pc_xu_func_sl_thold_3      => pc_xu_func_sl_thold_3,
         pc_xu_func_slp_sl_thold_3  => pc_xu_func_slp_sl_thold_3,
         pc_xu_gptr_sl_thold_3      => pc_xu_gptr_sl_thold_3,
         pc_xu_func_nsl_thold_3     => pc_xu_func_nsl_thold_3,
         pc_xu_func_slp_nsl_thold_3 => pc_xu_func_slp_nsl_thold_3,
         pc_xu_abst_sl_thold_3      => pc_xu_abst_sl_thold_3,
         pc_xu_abst_slp_sl_thold_3  => pc_xu_abst_slp_sl_thold_3,
         pc_xu_regf_sl_thold_3      => pc_xu_regf_sl_thold_3,
         pc_xu_regf_slp_sl_thold_3  => pc_xu_regf_slp_sl_thold_3,
         pc_xu_time_sl_thold_3      => pc_xu_time_sl_thold_3,
         pc_xu_ary_nsl_thold_3      => pc_xu_ary_nsl_thold_3,
         pc_xu_ary_slp_nsl_thold_3  => pc_xu_ary_slp_nsl_thold_3,
         pc_xu_repr_sl_thold_3      => pc_xu_repr_sl_thold_3,
         pc_xu_cfg_sl_thold_3       => pc_xu_cfg_sl_thold_3,
         pc_xu_cfg_slp_sl_thold_3   => pc_xu_cfg_slp_sl_thold_3,
         pc_xu_bolt_sl_thold_3      => pc_xu_bolt_sl_thold_3,
         pc_xu_bo_enable_3          => pc_xu_bo_enable_3,
         pc_xu_fce_3                => pc_xu_fce_3,
         pc_xu_ccflush_dc           => pc_xu_ccflush_dc,
         an_ac_scan_diag_dc         => an_ac_scan_diag_dc,
         an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b,
         sg_2                       => sg_2_b,
         func_sl_thold_2            => func_sl_thold_2_b,
         func_slp_sl_thold_2        => func_slp_sl_thold_2_b,
         func_nsl_thold_2           => func_nsl_thold_2_b,
         func_slp_nsl_thold_2       => func_slp_nsl_thold_2_b,
         ary_nsl_thold_2            => ary_nsl_thold_2,
         ary_slp_nsl_thold_2        => ary_slp_nsl_thold_2,
         time_sl_thold_2            => time_sl_thold_2,
         gptr_sl_thold_2            => gptr_sl_thold_2,
         abst_sl_thold_2            => abst_sl_thold_2,
         abst_slp_sl_thold_2        => abst_slp_sl_thold_2,
         regf_sl_thold_2            => open,
         repr_sl_thold_2            => repr_sl_thold_2,
         cfg_sl_thold_2             => cfg_sl_thold_2,
         cfg_slp_sl_thold_2         => cfg_slp_sl_thold_2,
         regf_slp_sl_thold_2        => regf_slp_sl_thold_2,
         bolt_sl_thold_2            => bolt_sl_thold_2,
         bo_enable_2                => bo_enable_2,
         sg_0                       => open,
         sg_1                       => open,
         ary_nsl_thold_0            => open,
         abst_sl_thold_0            => open,
         time_sl_thold_0            => open,
         repr_sl_thold_0            => open,
         fce_2                      => fce_2_b,
         clkoff_dc_b                => clkoff_dc_b_b,
         d_mode_dc                  => d_mode_dc_b,
         delay_lclkr_dc             => delay_lclkr_dc_b,
         mpw1_dc_b                  => mpw1_dc_b_b,
         mpw2_dc_b                  => mpw2_dc_b_b,
         g6t_clkoff_dc_b            => g6t_clkoff_dc_b,
         g6t_d_mode_dc              => g6t_d_mode_dc,
         g6t_delay_lclkr_dc         => g6t_delay_lclkr_dc,
         g6t_mpw1_dc_b              => g6t_mpw1_dc_b,
         g6t_mpw2_dc_b              => g6t_mpw2_dc_b,
         g8t_clkoff_dc_b            => g8t_clkoff_dc_b,
         g8t_d_mode_dc              => g8t_d_mode_dc,
         g8t_delay_lclkr_dc         => g8t_delay_lclkr_dc,
         g8t_mpw1_dc_b              => g8t_mpw1_dc_b,
         g8t_mpw2_dc_b              => g8t_mpw2_dc_b,
         cam_clkoff_dc_b            => cam_clkoff_dc_b,
         cam_d_mode_dc              => cam_d_mode_dc,
         cam_delay_lclkr_dc         => cam_delay_lclkr_dc,
         cam_act_dis_dc             => cam_act_dis_dc,
         cam_mpw1_dc_b              => cam_mpw1_dc_b,
         cam_mpw2_dc_b              => cam_mpw2_dc_b,
         gptr_scan_in               => gptr_scan_in,
         gptr_scan_out              => gptr_scan_out
    );

    xu_perf : entity work.xuq_perf(xuq_perf)
    generic map(
       expand_type                      => expand_type)
    port map(
       nclk                             => nclk,
       func_sl_thold_2                  => func_sl_thold_2_b(1),
       sg_2                             => sg_2_b(1),
       d_mode_dc                        => d_mode_dc_b,
       delay_lclkr_dc                   => delay_lclkr_dc_b(4),
       mpw1_dc_b                        => mpw1_dc_b_b(4),
       mpw2_dc_b                        => mpw2_dc_b_b,
       clkoff_dc_b                      => clkoff_dc_b_b,
       pc_xu_ccflush_dc                 => pc_xu_ccflush_dc,
       scan_in                          => siv_56(2),
       scan_out                         => sov_56(2),
       cpl_perf_tx_events               => cpl_perf_tx_events,
       spr_perf_tx_events               => spr_perf_tx_events,
       byp_perf_tx_events               => byp_perf_tx_events,
       fxa_perf_muldiv_in_use           => fxa_perf_muldiv_in_use,
       pc_xu_event_bus_enable           => pc_xu_event_bus_enable,
       pc_xu_event_count_mode           => pc_xu_event_count_mode,
       pc_xu_event_mux_ctrls            => pc_xu_event_mux_ctrls,
       xu_pc_event_data                 => xu_pc_event_data,
       spr_msr_gs                       => spr_msr_gs,
       spr_msr_pr                       => spr_msr_pr,
       vdd                              => vdd,
       gnd                              => gnd);

    
    xu_fxu_debug : entity work.xuq_debug(xuq_debug)
    generic map(
       expand_type                      => expand_type)
    port map(
       nclk                             => nclk,
       d_mode_dc                        => d_mode_dc_b,
       delay_lclkr_dc                   => delay_lclkr_dc_b(4),
       mpw1_dc_b                        => mpw1_dc_b_b(4),
       mpw2_dc_b                        => mpw2_dc_b_b,
       func_slp_sl_thold_0_b            => func_slp_sl_thold_0_b,
       func_slp_sl_force => func_slp_sl_force,
       sg_0                             => sg_0,
       scan_in                          => siv_56(3),
       scan_out                         => sov_56(3),
       dec_byp_ex3_instr_trace_val      => dec_byp_ex3_instr_trace_val,
       pc_xu_trace_bus_enable           => pc_xu_trace_bus_enable,
       debug_mux_ctrls                  => fxu_debug_mux_ctrls,
       trigger_data_in                  => fxu_trigger_data_in,
       debug_data_in                    => fxu_debug_data_in,
       trigger_data_out                 => fxu_trigger_data_out,
       debug_data_out                   => fxu_debug_data_out,
       dbg_group0                       => dbg_group0,
       dbg_group1                       => dbg_group1,
       dbg_group2                       => dbg_group2,
       dbg_group3                       => dbg_group3,
       dbg_group4                       => dbg_group4,
       dbg_group5                       => dbg_group5,
       dbg_group6                       => dbg_group6,
       dbg_group7                       => dbg_group7,
       dbg_group8                       => dbg_group8,
       dbg_group9                       => dbg_group9,
       dbg_group10                      => dbg_group10,
       dbg_group11                      => dbg_group11,
       dbg_group12                      => dbg_group12,
       dbg_group13                      => dbg_group13,
       dbg_group14                      => dbg_group14,
       dbg_group15                      => dbg_group15,
       trg_group0                       => trg_group0,
       trg_group1                       => trg_group1,
       trg_group2                       => trg_group2,
       trg_group3                       => trg_group3,
       vdd                              => vdd,
       gnd                              => gnd
    );

   fxb_fxa_ex7_we0   <= ex7_we0;
   fxb_fxa_ex7_wa0   <= ex7_wa0;
   fxb_fxa_ex7_wd0   <= ex7_wd0;
   
   gpr_we0_debug(0 to 65)  <= ex7_wd0(0 to 63) & ex7_we0 & ex7_wa0(0);  
   gpr_we0_debug(66 to 87) <= ex7_we0 & ex7_wa0 & (9 to 21=>'0');

   dbg_group0  <= (others=>'0'); 
   dbg_group1  <= byp_grp1_debug;
   dbg_group2  <= (others=>'0'); 
   dbg_group3  <= (others=>'0'); 
   dbg_group4  <= (others=>'0'); 
   dbg_group5  <= (others=>'0'); 
   dbg_group6  <= byp_grp6_debug;
   dbg_group7  <= byp_grp7_debug;
   dbg_group8  <= (0 to 21=>'0') & byp_grp8_debug;
   dbg_group9  <= (others=>'0'); 
   dbg_group10 <= (others=>'0'); 
   dbg_group11 <= dec_grp1_debug;
   dbg_group12 <= lsu_xu_data_debug0;
   dbg_group13 <= lsu_xu_data_debug1;
   dbg_group14 <= lsu_xu_data_debug2;
   dbg_group15 <= (others=>'0');
   trg_group0  <= (others=>'0');
   trg_group1  <= (others=>'0');
   trg_group2  <= (others=>'0');
   trg_group3  <= (others=>'0');
   
   mark_unused(byp_grp0_debug);
   mark_unused(byp_grp2_debug);
   mark_unused(byp_grp3_debug);
   mark_unused(byp_grp4_debug);
   mark_unused(byp_grp5_debug);
   mark_unused(gpr_we0_debug);
   mark_unused(dec_grp0_debug);

    xu_fxu_spr : entity work.xuq_fxu_spr(xuq_fxu_spr)
    generic map (
       hvmode                           => hvmode,
       a2mode                           => a2mode,
       expand_type                      => expand_type,
       threads                          => threads,
       regsize                          => regsize,
       eff_ifar                         => eff_ifar)
    port map(
       nclk                             => nclk,
       d_mode_dc                        => d_mode_dc_b,
       delay_lclkr_dc                   => delay_lclkr_dc_b(4),
       mpw1_dc_b                        => mpw1_dc_b_b(4),
       mpw2_dc_b                        => mpw2_dc_b_b,
       func_sl_force => func_sl_force,
       func_sl_thold_0_b                => func_sl_thold_0_b,
       func_nsl_force => func_nsl_force,
       func_nsl_thold_0_b               => func_nsl_thold_0_b,
       sg_0                             => sg_0,
       scan_in                          => siv_57(2),
       scan_out                         => sov_57(2),
       ex1_tid                          => dec_ex1_tid,
       ex1_instr                        => dec_fspr_ex1_instr,
       dec_spr_ex1_is_mfspr             => dec_spr_ex1_is_mfspr,
       dec_spr_ex1_is_mtspr             => dec_spr_ex1_is_mtspr,
       ex6_val                          => dec_fspr_ex6_val,
       ex6_spr_wd                       => byp_spr_ex6_rt,
       fspr_byp_ex3_spr_rt              => fspr_byp_ex3_spr_rt,
       mux_spr_ex2_rt                   => alu_byp_ex2_rt_b,
       ex2_is_any_load_dac              => ex2_is_any_load_dac,
       ex2_is_any_store_dac             => ex2_is_any_store_dac,
       xu_lsu_ex4_dvc1_en               => xu_lsu_ex4_dvc1_en,
       xu_lsu_ex4_dvc2_en               => xu_lsu_ex4_dvc2_en,
       lsu_xu_ex2_dvc1_st_cmp           => lsu_xu_ex2_dvc1_st_cmp,
       lsu_xu_ex2_dvc2_st_cmp           => lsu_xu_ex2_dvc2_st_cmp,
       lsu_xu_ex8_dvc1_ld_cmp           => lsu_xu_ex8_dvc1_ld_cmp,
       lsu_xu_ex8_dvc2_ld_cmp           => lsu_xu_ex8_dvc2_ld_cmp,
       lsu_xu_rel_dvc1_en               => lsu_xu_rel_dvc1_en,
       lsu_xu_rel_dvc2_en               => lsu_xu_rel_dvc2_en,
       lsu_xu_rel_dvc_thrd_id           => lsu_xu_rel_dvc_thrd_id,
       lsu_xu_rel_dvc1_cmp              => lsu_xu_rel_dvc1_cmp,
       lsu_xu_rel_dvc2_cmp              => lsu_xu_rel_dvc2_cmp,
       fxu_cpl_ex3_dac1r_cmpr_async     => fxu_cpl_ex3_dac1r_cmpr_async,
       fxu_cpl_ex3_dac2r_cmpr_async     => fxu_cpl_ex3_dac2r_cmpr_async,
       fxu_cpl_ex3_dac1r_cmpr           => fxu_cpl_ex3_dac1r_cmpr,
       fxu_cpl_ex3_dac2r_cmpr           => fxu_cpl_ex3_dac2r_cmpr,
       fxu_cpl_ex3_dac3r_cmpr           => fxu_cpl_ex3_dac3r_cmpr,
       fxu_cpl_ex3_dac4r_cmpr           => fxu_cpl_ex3_dac4r_cmpr,
       fxu_cpl_ex3_dac1w_cmpr           => fxu_cpl_ex3_dac1w_cmpr,
       fxu_cpl_ex3_dac2w_cmpr           => fxu_cpl_ex3_dac2w_cmpr,
       fxu_cpl_ex3_dac3w_cmpr           => fxu_cpl_ex3_dac3w_cmpr,
       fxu_cpl_ex3_dac4w_cmpr           => fxu_cpl_ex3_dac4w_cmpr,
       spr_bit_act                      => spr_bit_act,
       spr_msr_pr                       => spr_msr_pr,
       spr_msr_ds                       => spr_msr_ds,
       spr_dbcr0_dac1                   => spr_dbcr0_dac1,
       spr_dbcr0_dac2                   => spr_dbcr0_dac2,
       spr_dbcr0_dac3                   => spr_dbcr0_dac3,
       spr_dbcr0_dac4                   => spr_dbcr0_dac4,
        spr_dbcr3_ivc                    => spr_dbcr3_ivc,
       vdd                              => vdd,
       gnd                              => gnd
    );

func_scan_rpwr_54i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc_b(4),
            thold_b => func_so_thold_0_b,
            scin    => siv_54(siv_54'left to siv_54'left),
            scout   => sov_54(sov_54'left to sov_54'left),
            dout    => open);
func_scan_rpwr_54o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc_b(4),
            thold_b => func_so_thold_0_b,
            scin    => siv_54(siv_54'right to siv_54'right),
            scout   => sov_54(sov_54'right to sov_54'right),
            dout    => open);
func_scan_rpwr_55i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc_b(4),
            thold_b => func_so_thold_0_b,
            scin    => siv_55(siv_55'left to siv_55'left),
            scout   => sov_55(sov_55'left to sov_55'left),
            dout    => open);
func_scan_rpwr_55o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc_b(4),
            thold_b => func_so_thold_0_b,
            scin    => siv_55(siv_55'right to siv_55'right),
            scout   => sov_55(sov_55'right to sov_55'right),
            dout    => open);
func_scan_rpwr_56i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc_b(4),
            thold_b => func_so_thold_0_b,
            scin    => siv_56(siv_56'left to siv_56'left),
            scout   => sov_56(sov_56'left to sov_56'left),
            dout    => open);
func_scan_rpwr_56o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc_b(4),
            thold_b => func_so_thold_0_b,
            scin    => siv_56(siv_56'right to siv_56'right),
            scout   => sov_56(sov_56'right to sov_56'right),
            dout    => open);
func_scan_rpwr_57i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc_b(4),
            thold_b => func_so_thold_0_b,
            scin    => siv_57(siv_57'left to siv_57'left),
            scout   => sov_57(sov_57'left to sov_57'left),
            dout    => open);
func_scan_rpwr_57o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc_b(4),
            thold_b => func_so_thold_0_b,
            scin    => siv_57(siv_57'right to siv_57'right),
            scout   => sov_57(sov_57'right to sov_57'right),
            dout    => open);
func_scan_rpwr_58i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc_b(4),
            thold_b => func_so_thold_0_b,
            scin    => siv_58(siv_58'left to siv_58'left),
            scout   => sov_58(sov_58'left to sov_58'left),
            dout    => open);
func_scan_rpwr_58o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc_b(4),
            thold_b => func_so_thold_0_b,
            scin    => siv_58(siv_58'right to siv_58'right),
            scout   => sov_58(sov_58'right to sov_58'right),
            dout    => open);


siv_54(0 to sov_54'right)              <= sov_54(1 to sov_54'right) & func_scan_in(54);
func_scan_out(54)                      <= sov_54(0) and an_ac_scan_dis_dc_b;
siv_55(0 to sov_55'right)              <= sov_55(1 to sov_55'right) & func_scan_in(55);
func_scan_out(55)                      <= sov_55(0) and an_ac_scan_dis_dc_b;
siv_56(0 to sov_56'right)              <= sov_56(1 to sov_56'right) & func_scan_in(56);
func_scan_out(56)                      <= sov_56(0) and an_ac_scan_dis_dc_b;
siv_57(0 to sov_57'right)              <= sov_57(1 to sov_57'right) & func_scan_in(57);
func_scan_out(57)                      <= sov_57(0) and an_ac_scan_dis_dc_b;
siv_58(0 to sov_58'right)              <= sov_58(1 to sov_58'right) & func_scan_in(58);
func_scan_out(58)                      <= sov_58(0) and an_ac_scan_dis_dc_b;




end architecture xuq_fxu_b;
