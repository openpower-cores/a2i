-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

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

entity xuq_cpl_fxub is
generic(
        expand_type             : integer :=  2;
        threads                 : integer :=  4;
        eff_ifar                : integer := 62;
        uc_ifar                 : integer := 21;
        regsize                 : integer := 64;
        hvmode                  : integer := 1;
        regmode                 : integer := 6;
        dc_size                 : natural := 14;
        cl_size                 : natural := 6;             -- 2^6 = 64 Bytes CacheLines
        real_data_add           : integer := 42;
        fxu_synth               : integer := 0;
        a2mode                  : integer := 1);
port(

        ---------------------------------------------------------------------
        -- Clocks & Power
        ---------------------------------------------------------------------
        nclk                            : in clk_logic;
        vdd                             : inout power_logic;
        gnd                             : inout power_logic;
        vcs                             : inout power_logic;

        ---------------------------------------------------------------------
        -- Pervasive
        ---------------------------------------------------------------------
        func_scan_in                        : in     std_ulogic_vector(50 to 58);
        func_scan_out                       : out    std_ulogic_vector(50 to 58);
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

        ---------------------------------------------------------------------
        -- Interface with FXU A
        ---------------------------------------------------------------------
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
        fxa_cpl_ex2_div_coll                : in  std_ulogic_vector(0 to threads-1);
        fxb_fxa_ex7_we0                     : out std_ulogic;
        fxb_fxa_ex7_wa0                     : out std_ulogic_vector(0 to 7);
        fxb_fxa_ex7_wd0                     : out std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do0                     : in  std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do1                     : in  std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do2                     : in  std_ulogic_vector(64-regsize to 63);

        ---------------------------------------------------------------------
        -- Interface with LSU
        ---------------------------------------------------------------------
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
        xu_lsu_ex4_val                      : out std_ulogic_vector(0 to threads-1);    -- There is a valid Instruction in EX4
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
        xu_bx_ex1_mtdp_val                  : out std_ulogic;
        xu_bx_ex1_mfdp_val                  : out std_ulogic;
        xu_bx_ex1_ipc_thrd                  : out std_ulogic_vector(0 to 1);
        xu_bx_ex2_ipc_ba                    : out std_ulogic_vector(0 to 4);
        xu_bx_ex2_ipc_sz                    : out std_ulogic_vector(0 to 1);
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
        lsu_xu_ex5_wren                     : in  std_ulogic;                        -- FXU Load Hit Write is Valid in EX5
        lsu_xu_rel_wren                     : in  std_ulogic;                        -- FXU Reload is Valid
        lsu_xu_rel_ta_gpr                   : in  std_ulogic_vector(0 to 7);         -- FXU Reload Target Register
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

        ---------------------------------------------------------------------
        -- Effective Address
        ---------------------------------------------------------------------
        xu_ex1_eff_addr_int                 : out std_ulogic_vector(64-(dc_size-3) to 63);

        -- Barrier
        xu_lsu_ex5_set_barr                 : out std_ulogic_vector(0 to threads-1);
        cpl_fxa_ex5_set_barr                : out std_ulogic_vector(0 to threads-1);
        cpl_iu_set_barr_tid                 : out std_ulogic_vector(0 to threads-1);

        ---------------------------------------------------------------------
        -- TLB ops interface
        ---------------------------------------------------------------------
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

        ---------------------------------------------------------------------
        -- D-ERAT Req Interface
        ---------------------------------------------------------------------
        xu_mm_derat_epn                     : out std_ulogic_vector(62-eff_ifar to 51);

        ---------------------------------------------------------------------
        -- Back Invalidate
        ---------------------------------------------------------------------
        lsu_xu_is2_back_inv                 : in std_ulogic;
        lsu_xu_is2_back_inv_addr            : in std_ulogic_vector(64-real_data_add to 63-cl_size);

        ---------------------------------------------------------------------
        -- TLBRE
        ---------------------------------------------------------------------
        mm_xu_mmucr0_0_tlbsel               : in  std_ulogic_vector(4 to 5);
        mm_xu_mmucr0_1_tlbsel               : in  std_ulogic_vector(4 to 5);
        mm_xu_mmucr0_2_tlbsel               : in  std_ulogic_vector(4 to 5);
        mm_xu_mmucr0_3_tlbsel               : in  std_ulogic_vector(4 to 5);

        ---------------------------------------------------------------------
        -- TLBSX./TLBSRX.
        ---------------------------------------------------------------------
        xu_mm_rf1_is_tlbsxr                 : out std_ulogic;
        mm_xu_cr0_eq_valid                  : in  std_ulogic_vector(0 to threads-1);
        mm_xu_cr0_eq                        : in  std_ulogic_vector(0 to threads-1);

        ---------------------------------------------------------------------
        -- FU CR Write
        ---------------------------------------------------------------------
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

        ---------------------------------------------------------------------
        -- RAM
        ---------------------------------------------------------------------
        xu_pc_ram_data                      : out std_ulogic_vector(64-(2**regmode) to 63);

        ---------------------------------------------------------------------
        -- Interface with IU
        ---------------------------------------------------------------------
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

        ---------------------------------------------------------------------
        -- L2 STCX complete
        ---------------------------------------------------------------------
        an_ac_stcx_complete                 : in  std_ulogic_vector(0 to threads-1);
        an_ac_stcx_pass                     : in  std_ulogic_vector(0 to threads-1);

        ---------------------------------------------------------------------
        -- icswx. interface
        ---------------------------------------------------------------------
        an_ac_back_inv                      : in  std_ulogic;
        an_ac_back_inv_addr                 : in  std_ulogic_vector(58 to 63);
        an_ac_back_inv_target_bit3          : in  std_ulogic;

        ---------------------------------------------------------------------
        -- Slow SPR Bus
        ---------------------------------------------------------------------
        slowspr_val_in                      : in  std_ulogic;
        slowspr_rw_in                       : in  std_ulogic;
        slowspr_etid_in                     : in  std_ulogic_vector(0 to 1);
        slowspr_addr_in                     : in  std_ulogic_vector(0 to 9);
        slowspr_data_in                     : in  std_ulogic_vector(64-(2**regmode) to 63);
        slowspr_done_in                     : in  std_ulogic;

        ---------------------------------------------------------------------
        -- DCR Bus
        ---------------------------------------------------------------------
        an_ac_dcr_act                       : in  std_ulogic;
        an_ac_dcr_val                       : in  std_ulogic;
        an_ac_dcr_read                      : in  std_ulogic;
        an_ac_dcr_etid                      : in  std_ulogic_vector(0 to 1);
        an_ac_dcr_data                      : in  std_ulogic_vector(64-(2**regmode) to 63);
        an_ac_dcr_done                      : in  std_ulogic;
        
        ---------------------------------------------------------------------
        -- MT/MFDCR CR
        ---------------------------------------------------------------------
        lsu_xu_ex4_mtdp_cr_status           : in  std_ulogic;
        lsu_xu_ex4_mfdp_cr_status           : in  std_ulogic;
        dec_cpl_ex3_mc_dep_chk_val          : in  std_ulogic_vector(0 to threads-1);

        ---------------------------------------------------------------------
        -- ldawx/wchkall
        ---------------------------------------------------------------------
        lsu_xu_ex4_cr_upd                   : in std_ulogic;
        lsu_xu_ex5_cr_rslt                  : in std_ulogic;

        ---------------------------------------------------------------------
        -- Interface with SPR
        ---------------------------------------------------------------------
        dec_spr_ex4_val                     : out std_ulogic_vector(0 to threads-1);
        dec_spr_ex1_epid_instr              : out std_ulogic;
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

        ---------------------------------------------------------------------
        -- Perf Events
        ---------------------------------------------------------------------
        fxa_perf_muldiv_in_use              : in  std_ulogic;
        spr_perf_tx_events                  : in  std_ulogic_vector(0 to 8*threads-1);
        xu_pc_event_data                    : out std_ulogic_vector(0 to 7);

        ---------------------------------------------------------------------
        -- PC Control Interface
        ---------------------------------------------------------------------
        pc_xu_event_bus_enable              : in  std_ulogic;
        pc_xu_event_count_mode              : in  std_ulogic_vector(0 to 2);
        pc_xu_event_mux_ctrls               : in  std_ulogic_vector(0 to 47);

        ---------------------------------------------------------------------
        -- Debug Ramp & Controls
        ---------------------------------------------------------------------
        pc_xu_trace_bus_enable              : in  std_ulogic;
        pc_xu_instr_trace_mode              : in  std_ulogic;
        pc_xu_instr_trace_tid               : in  std_ulogic_vector(0 to 1);
        xu_lsu_ex2_instr_trace_val          : out std_ulogic;
        fxu_debug_mux_ctrls                 : in  std_ulogic_vector(0 to 15);
        fxu_trigger_data_in                 : in  std_ulogic_vector(0 to 11);
        fxu_debug_data_in                   : in  std_ulogic_vector(0 to 87);
        fxu_trigger_data_out                : out std_ulogic_vector(0 to 11);
        fxu_debug_data_out                  : out std_ulogic_vector(0 to 87);
        lsu_xu_data_debug0                  : in  std_ulogic_vector(0 to 87);
        lsu_xu_data_debug1                  : in  std_ulogic_vector(0 to 87);
        lsu_xu_data_debug2                  : in  std_ulogic_vector(0 to 87);

        ---------------------------------------------------------------------
        -- SPR Bits
        ---------------------------------------------------------------------
        spr_msr_gs                          : in  std_ulogic_vector(0 to threads-1);
        spr_msr_ds                          : in  std_ulogic_vector(0 to threads-1);
        spr_msr_pr                          : in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_dac1                      : in  std_ulogic_vector(0 to 2*threads-1);
        spr_dbcr0_dac2                      : in  std_ulogic_vector(0 to 2*threads-1);
        spr_dbcr0_dac3                      : in  std_ulogic_vector(0 to 2*threads-1);
        spr_dbcr0_dac4                      : in  std_ulogic_vector(0 to 2*threads-1);
        spr_xucr0_clkg_ctl                  : in  std_ulogic_vector(2 to 2);
         
        -- CHIP IO
        ac_tc_debug_trigger              : out std_ulogic_vector(0 to threads-1);

        -- Pervasive
        ccfg_scan_in                     : in  std_ulogic;
        ccfg_scan_out                    : out std_ulogic;
        bcfg_scan_in                     : in  std_ulogic;
        bcfg_scan_out                    : out std_ulogic;
        dcfg_scan_in                     : in  std_ulogic;
        dcfg_scan_out                    : out std_ulogic;

        -- Valids
        dec_cpl_rf0_act                  : in  std_ulogic;
        dec_cpl_rf0_tid                  : in  std_ulogic_vector(0 to threads-1);


        -- FU Inputs
        fu_xu_rf1_act                    : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex1_ifar                   : in  std_ulogic_vector(0 to eff_ifar*threads-1);
        fu_xu_ex2_ifar_val               : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex2_ifar_issued            : in  std_ulogic_vector(0 to threads-1);
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

        -- Hypv Privledge
        spr_cpl_ex3_spr_hypv             : in  std_logic;

        -- Data TLB Miss
        derat_xu_ex3_miss                : in  std_ulogic_vector(0 to threads-1);

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
        xu_lsu_ex4_flush_local           : out std_ulogic_vector(0 to threads-1);
        xu_mm_ex4_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_mm_ierat_flush                : out std_ulogic_vector(0 to threads-1);
        xu_mm_ierat_miss                 : out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_perf_itlb              : out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_perf_dtlb              : out std_ulogic_vector(0 to threads-1);


        -- SPR Bits
        spr_bit_act                      : in  std_ulogic;
        spr_cpl_iac1_en                  : in  std_ulogic_vector(0 to threads-1);
        spr_cpl_iac2_en                  : in  std_ulogic_vector(0 to threads-1);
        spr_cpl_iac3_en                  : in  std_ulogic_vector(0 to threads-1);
        spr_cpl_iac4_en                  : in  std_ulogic_vector(0 to threads-1);
        spr_dbcr1_iac12m                 : in  std_ulogic_vector(0 to threads-1);
        spr_dbcr1_iac34m                 : in  std_ulogic_vector(0 to threads-1);
        spr_cpl_fp_precise               : in  std_ulogic_vector(0 to threads-1);
        spr_xucr0_mddp                   : in  std_ulogic;
        spr_xucr0_mdcp                   : in  std_ulogic;
        spr_msr_de                       : in  std_ulogic_vector(0 to threads-1);
        spr_msr_spv                      : in  std_ulogic_vector(0 to threads-1);
        spr_msr_fp                       : in  std_ulogic_vector(0 to threads-1);
        spr_msr_me                       : in  std_ulogic_vector(0 to threads-1);
        spr_msr_ucle                     : in  std_ulogic_vector(0 to threads-1);
        spr_msrp_uclep                   : in  std_ulogic_vector(0 to threads-1);
        spr_ccr2_ucode_dis               : in  std_ulogic;
        spr_ccr2_ap                      : in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_idm                    : in  std_ulogic_vector(0 to threads-1);
        cpl_spr_dbcr0_edm                : out std_ulogic_vector(0 to threads-1);
        spr_dbcr0_icmp                   : in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_brt                    : in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_trap                   : in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_ret                    : in  std_ulogic_vector(0 to threads-1);
        spr_dbcr0_irpt                   : in  std_ulogic_vector(0 to threads-1);
        spr_epcr_dsigs                   : in  std_ulogic_vector(0 to threads-1);
        spr_epcr_isigs                   : in  std_ulogic_vector(0 to threads-1);
        spr_epcr_extgs                   : in  std_ulogic_vector(0 to threads-1);
        spr_epcr_dtlbgs                  : in  std_ulogic_vector(0 to threads-1);
        spr_epcr_itlbgs                  : in  std_ulogic_vector(0 to threads-1);
        spr_xucr4_div_barr_thres         : out std_ulogic_vector(0 to 7);
        spr_ccr0_we                      : in  std_ulogic_vector(0 to threads-1);
        spr_epcr_duvd                    : in  std_ulogic_vector(0 to threads-1);
        cpl_msr_gs                       : out std_ulogic_vector(0 to threads-1);
        cpl_msr_pr                       : out std_ulogic_vector(0 to threads-1);
        cpl_msr_fp                       : out std_ulogic_vector(0 to threads-1);
        cpl_msr_spv                      : out std_ulogic_vector(0 to threads-1);
        cpl_ccr2_ap                      : out std_ulogic_vector(0 to threads-1);
        spr_xucr4_mmu_mchk               : out std_ulogic;

        -- Cache invalidate
        xu_lsu_ici                       : out std_ulogic;
        xu_lsu_dci                       : out std_ulogic;

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
        cpl_debug_mux_ctrls              : in  std_ulogic_vector(0 to 15);
        cpl_debug_data_in                : in  std_ulogic_vector(0 to 87);
        cpl_debug_data_out               : out std_ulogic_vector(0 to 87);
        cpl_trigger_data_in              : in  std_ulogic_vector(0 to 11);
        cpl_trigger_data_out             : out std_ulogic_vector(0 to 11);
        fxa_cpl_debug                    : in  std_ulogic_vector(0 to 272)
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_cpl_fxub;
architecture xuq_cpl_fxub of xuq_cpl_fxub is

signal clkoff_dc_b_b                         : std_ulogic;
signal d_mode_dc_b                           : std_ulogic;
signal delay_lclkr_dc_b                      : std_ulogic_vector(0 to 4);
signal mpw1_dc_b_b                           : std_ulogic_vector(0 to 4);
signal mpw2_dc_b_b                           : std_ulogic;
signal sg_2_b                                : std_ulogic_vector(0 to 3);
signal fce_2_b                               : std_ulogic_vector(0 to 1);
signal func_sl_thold_2_b                     : std_ulogic_vector(0 to 3);
signal func_slp_sl_thold_2_b                 : std_ulogic_vector(0 to 1);
signal func_nsl_thold_2_b                    : std_ulogic;
signal func_slp_nsl_thold_2_b                : std_ulogic;
signal cfg_sl_thold_2_b                      : std_ulogic;
signal cfg_slp_sl_thold_2_b                  : std_ulogic;

signal dec_cpl_ex3_mult_coll            :std_ulogic;
signal dec_cpl_ex3_axu_instr_type       :std_ulogic_vector(0 to 2);
signal dec_cpl_ex3_instr_hypv           :std_ulogic;
signal dec_cpl_rf1_ucode_val            :std_ulogic_vector(0 to threads-1);
signal dec_cpl_ex2_error                :std_ulogic_vector(0 to 2);
signal dec_cpl_ex2_match                :std_ulogic;
signal dec_cpl_ex2_is_ucode             :std_ulogic;
signal dec_cpl_rf1_ifar                 :std_ulogic_vector(62-eff_ifar to 61);
signal dec_cpl_ex3_is_any_store         :std_ulogic;
signal dec_cpl_ex2_is_any_load_dac      :std_ulogic;
signal dec_cpl_ex3_instr_priv           :std_ulogic;
signal dec_ex1_epid_instr               :std_ulogic;
signal dec_cpl_ex2_illegal_op           :std_ulogic;
signal alu_cpl_ex3_trap_val             :std_ulogic;
signal mux_cpl_ex4_rt                   :std_ulogic_vector(64-(2**regmode) to 63);
signal dec_cpl_ex2_is_any_store_dac     :std_ulogic;
signal dec_cpl_ex3_tlb_illeg            :std_ulogic;
signal dec_cpl_ex3_mtdp_nr              :std_ulogic;
signal mux_cpl_slowspr_done             :std_ulogic_vector(0 to threads-1);
signal mux_cpl_slowspr_flush            :std_ulogic_vector(0 to threads-1);
signal dec_cpl_rf1_val                  :std_ulogic_vector(0 to threads-1);
signal dec_cpl_rf1_issued               :std_ulogic_vector(0 to threads-1);
signal dec_cpl_rf1_instr                :std_ulogic_vector(0 to 31);
signal cpl_byp_ex3_spr_rt               :std_ulogic_vector(64-(2**regmode) to 63);
signal byp_cpl_ex1_cr_bit               :std_ulogic;
signal dec_cpl_rf1_pred_taken_cnt       :std_ulogic;
signal dec_cpl_ex1_is_slowspr_wr        :std_ulogic;
signal dec_cpl_ex3_ddmh_en              :std_ulogic;
signal dec_cpl_ex3_back_inv             :std_ulogic;
signal fxu_cpl_ex3_dac1r_cmpr_async     :std_ulogic_vector(0 to threads-1);
signal fxu_cpl_ex3_dac2r_cmpr_async     :std_ulogic_vector(0 to threads-1);
signal fxu_cpl_ex3_dac1r_cmpr           :std_ulogic_vector(0 to threads-1);
signal fxu_cpl_ex3_dac2r_cmpr           :std_ulogic_vector(0 to threads-1);
signal fxu_cpl_ex3_dac3r_cmpr           :std_ulogic_vector(0 to threads-1);
signal fxu_cpl_ex3_dac4r_cmpr           :std_ulogic_vector(0 to threads-1);
signal fxu_cpl_ex3_dac1w_cmpr           :std_ulogic_vector(0 to threads-1);
signal fxu_cpl_ex3_dac2w_cmpr           :std_ulogic_vector(0 to threads-1);
signal fxu_cpl_ex3_dac3w_cmpr           :std_ulogic_vector(0 to threads-1);
signal fxu_cpl_ex3_dac4w_cmpr           :std_ulogic_vector(0 to threads-1);
signal xu_ex1_eff_addr                  :std_ulogic_vector(64-(dc_size-3) to 63);
signal xu_rf0_flush_int                 :std_ulogic_vector(0 to threads-1);
signal xu_rf1_flush_int                 :std_ulogic_vector(0 to threads-1);
signal xu_ex1_flush_int                 :std_ulogic_vector(0 to threads-1);
signal xu_ex2_flush_int                 :std_ulogic_vector(0 to threads-1);
signal xu_ex3_flush_int                 :std_ulogic_vector(0 to threads-1);
signal xu_ex4_flush_int                 :std_ulogic_vector(0 to threads-1);
signal xu_ex5_flush_int                 :std_ulogic_vector(0 to threads-1);
signal cpl_perf_tx_events               :std_ulogic_vector(0 to 75);
signal spr_cpl_async_int                :std_ulogic_vector(0 to 3*threads-1);
signal spr_dbcr3_ivc_int                :std_ulogic_vector(0 to threads-1);
signal dec_cpl_rf1_instr_trace_val      :std_ulogic;
signal dec_cpl_rf1_instr_trace_type     :std_ulogic_vector(0 to 1);
signal dec_cpl_ex3_instr_trace_val      :std_ulogic;
signal cpl_dec_in_ucode                 :std_ulogic_vector(0 to threads-1);



begin

perf_count : for t in 0 to threads-1 generate
spr_cpl_async_int(0+3*t)  <= spr_perf_tx_events(5+8*t);
spr_cpl_async_int(1+3*t)  <= spr_perf_tx_events(6+8*t);
spr_cpl_async_int(2+3*t)  <= spr_perf_tx_events(7+8*t);
end generate;

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
cfg_sl_thold_2 <= cfg_sl_thold_2_b;
cfg_slp_sl_thold_2 <= cfg_slp_sl_thold_2_b;

    xuq_fxu_b : entity work.xuq_fxu_b(xuq_fxu_b)
    generic map(
        expand_type                         => expand_type,
        threads                             => threads,
        eff_ifar                            => eff_ifar,
        regmode                             => regmode,
        regsize                             => regsize,
        a2mode                              => a2mode,
        hvmode                              => hvmode,
        dc_size                             => dc_size,
        cl_size                             => cl_size,
        real_data_add                       => real_data_add,
        fxu_synth                           => fxu_synth)
    port map(
        nclk                                => nclk,
        vdd                                 => vdd,
        gnd                                 => gnd,
        vcs                                 => vcs,
        func_scan_in                        => func_scan_in(54 to 58),
        func_scan_out                       => func_scan_out(54 to 58),
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
        pc_xu_bolt_sl_thold_3               => pc_xu_bolt_sl_thold_3,
        pc_xu_bo_enable_3                   => pc_xu_bo_enable_3,
        pc_xu_fce_3                         => pc_xu_fce_3,
        an_ac_scan_diag_dc                  => an_ac_scan_diag_dc,
        sg_2                                => sg_2_b,
        fce_2                               => fce_2_b,
        func_sl_thold_2                     => func_sl_thold_2_b,
        func_slp_sl_thold_2                 => func_slp_sl_thold_2_b,
        func_nsl_thold_2                    => func_nsl_thold_2_b,
        func_slp_nsl_thold_2                => func_slp_nsl_thold_2_b,
        abst_sl_thold_2                     => abst_sl_thold_2,
        abst_slp_sl_thold_2                 => abst_slp_sl_thold_2,
        time_sl_thold_2                     => time_sl_thold_2,
        gptr_sl_thold_2                     => gptr_sl_thold_2,
        ary_nsl_thold_2                     => ary_nsl_thold_2,
        ary_slp_nsl_thold_2                 => ary_slp_nsl_thold_2,
        repr_sl_thold_2                     => repr_sl_thold_2,
        cfg_sl_thold_2                      => cfg_sl_thold_2_b,
        cfg_slp_sl_thold_2                  => cfg_slp_sl_thold_2_b,
        regf_slp_sl_thold_2                 => regf_slp_sl_thold_2,
        bolt_sl_thold_2                     => bolt_sl_thold_2,
        bo_enable_2                         => bo_enable_2,
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
        fxa_fxb_rf1_muldiv_coll             => fxa_fxb_rf1_muldiv_coll,
        fxa_fxb_rf1_div_val                 => fxa_fxb_rf1_div_val,
        fxa_fxb_rf1_div_ctr                 => fxa_fxb_rf1_div_ctr,
        fxa_fxb_rf0_xu_epid_instr           => fxa_fxb_rf0_xu_epid_instr,
        fxa_fxb_rf0_axu_is_extload          => fxa_fxb_rf0_axu_is_extload,
        fxa_fxb_rf0_axu_is_extstore         => fxa_fxb_rf0_axu_is_extstore,
        fxa_fxb_rf0_is_mfocrf               => fxa_fxb_rf0_is_mfocrf,
        fxa_fxb_rf0_3src_instr              => fxa_fxb_rf0_3src_instr,
        fxa_fxb_rf0_gpr0_zero               => fxa_fxb_rf0_gpr0_zero,
        fxa_fxb_rf0_use_imm                 => fxa_fxb_rf0_use_imm,
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
        xu_lsu_rf1_axu_ldst_falign          => xu_lsu_rf1_axu_ldst_falign,
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
        lsu_xu_rel_wren                     => lsu_xu_rel_wren,
        lsu_xu_rel_ta_gpr                   => lsu_xu_rel_ta_gpr,
        lsu_xu_need_hole                    => lsu_xu_need_hole,
        lsu_xu_rot_ex6_data_b               => lsu_xu_rot_ex6_data_b,
        lsu_xu_rot_rel_data                 => lsu_xu_rot_rel_data(64-(2**regmode) to 63),
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
        xu_ex1_eff_addr_int                 => xu_ex1_eff_addr,
        xu_iu_rf1_val                       => xu_iu_rf1_val,
        xu_rf1_val                          => xu_rf1_val,
        xu_rf1_is_tlbre                     => xu_rf1_is_tlbre,
        xu_rf1_is_tlbwe                     => xu_rf1_is_tlbwe,
        xu_rf1_is_tlbsx                     => xu_rf1_is_tlbsx,
        xu_rf1_is_tlbsrx                    => xu_rf1_is_tlbsrx,
        xu_rf1_is_tlbilx                    => xu_rf1_is_tlbilx,
        xu_rf1_is_tlbivax                   => xu_rf1_is_tlbivax,
        xu_rf1_is_eratre                    => xu_rf1_is_eratre,
        xu_rf1_is_eratwe                    => xu_rf1_is_eratwe,
        xu_rf1_is_eratsx                    => xu_rf1_is_eratsx,
        xu_rf1_is_eratsrx                   => xu_rf1_is_eratsrx,
        xu_rf1_is_eratilx                   => xu_rf1_is_eratilx,
        xu_rf1_is_erativax                  => xu_rf1_is_erativax,
        xu_ex1_is_isync                     => xu_ex1_is_isync,
        xu_ex1_is_csync                     => xu_ex1_is_csync,
        xu_rf1_ws                           => xu_rf1_ws,
        xu_rf1_t                            => xu_rf1_t,
        xu_ex1_rs_is                        => xu_ex1_rs_is,
        xu_ex1_ra_entry                     => xu_ex1_ra_entry,
        xu_ex1_rb                           => xu_ex1_rb,
        xu_ex2_eff_addr                     => xu_ex2_eff_addr,
        xu_ex4_rs_data                      => xu_ex4_rs_data,
        lsu_xu_ex4_tlb_data                 => lsu_xu_ex4_tlb_data,
        iu_xu_ex4_tlb_data                  => iu_xu_ex4_tlb_data,
        xu_mm_derat_epn                     => xu_mm_derat_epn,
        lsu_xu_is2_back_inv                 => lsu_xu_is2_back_inv,
        lsu_xu_is2_back_inv_addr            => lsu_xu_is2_back_inv_addr,
        mm_xu_mmucr0_0_tlbsel               => mm_xu_mmucr0_0_tlbsel,
        mm_xu_mmucr0_1_tlbsel               => mm_xu_mmucr0_1_tlbsel,
        mm_xu_mmucr0_2_tlbsel               => mm_xu_mmucr0_2_tlbsel,
        mm_xu_mmucr0_3_tlbsel               => mm_xu_mmucr0_3_tlbsel,
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
        an_ac_back_inv_addr                 => an_ac_back_inv_addr,
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
        lsu_xu_ex4_cr_upd                   => lsu_xu_ex4_cr_upd,
        lsu_xu_ex5_cr_rslt                  => lsu_xu_ex5_cr_rslt,
        dec_cpl_ex3_mult_coll               => dec_cpl_ex3_mult_coll,
        dec_cpl_ex3_axu_instr_type          => dec_cpl_ex3_axu_instr_type,
        dec_cpl_ex3_instr_hypv              => dec_cpl_ex3_instr_hypv,
        dec_cpl_rf1_ucode_val               => dec_cpl_rf1_ucode_val,
        dec_cpl_ex2_error                   => dec_cpl_ex2_error,
        dec_cpl_ex2_match                   => dec_cpl_ex2_match,
        dec_cpl_ex2_is_ucode                => dec_cpl_ex2_is_ucode,
        dec_cpl_rf1_ifar                    => dec_cpl_rf1_ifar,
        dec_cpl_ex3_is_any_store            => dec_cpl_ex3_is_any_store,
        dec_cpl_ex2_is_any_load_dac         => dec_cpl_ex2_is_any_load_dac,
        dec_cpl_ex3_instr_priv              => dec_cpl_ex3_instr_priv,
        dec_cpl_ex1_epid_instr              => dec_ex1_epid_instr,
        dec_cpl_ex2_illegal_op              => dec_cpl_ex2_illegal_op,
        alu_cpl_ex3_trap_val                => alu_cpl_ex3_trap_val,
        mux_cpl_ex4_rt                      => mux_cpl_ex4_rt,
        dec_cpl_ex2_is_any_store_dac        => dec_cpl_ex2_is_any_store_dac,
        dec_cpl_ex3_tlb_illeg               => dec_cpl_ex3_tlb_illeg,
        dec_cpl_ex3_mtdp_nr                 => dec_cpl_ex3_mtdp_nr,
        mux_cpl_slowspr_done                => mux_cpl_slowspr_done,
        mux_cpl_slowspr_flush               => mux_cpl_slowspr_flush,
        dec_cpl_rf1_val                     => dec_cpl_rf1_val,
        dec_cpl_rf1_issued                  => dec_cpl_rf1_issued,
        dec_cpl_rf1_instr                   => dec_cpl_rf1_instr,
        cpl_byp_ex3_spr_rt                  => cpl_byp_ex3_spr_rt,
        byp_cpl_ex1_cr_bit                  => byp_cpl_ex1_cr_bit,
        dec_cpl_rf1_pred_taken_cnt          => dec_cpl_rf1_pred_taken_cnt,
        dec_cpl_ex1_is_slowspr_wr           => dec_cpl_ex1_is_slowspr_wr,
        dec_cpl_ex3_ddmh_en                 => dec_cpl_ex3_ddmh_en,
        dec_cpl_ex3_back_inv                => dec_cpl_ex3_back_inv,
        xu_rf1_flush                        => xu_rf1_flush_int,
        xu_ex1_flush                        => xu_ex1_flush_int,
        xu_ex2_flush                        => xu_ex2_flush_int,
        xu_ex3_flush                        => xu_ex3_flush_int,
        xu_ex4_flush                        => xu_ex4_flush_int,
        xu_ex5_flush                        => xu_ex5_flush_int,
        dec_spr_ex4_val                     => dec_spr_ex4_val,
        mux_spr_ex2_rt                      => mux_spr_ex2_rt,
        fxu_spr_ex1_rs0                     => fxu_spr_ex1_rs0,
        fxu_spr_ex1_rs1                     => fxu_spr_ex1_rs1,
        spr_bit_act                         => spr_bit_act,
        spr_msr_cm                          => spr_msr_cm,
        spr_dec_spr_xucr0_ssdly             => spr_dec_spr_xucr0_ssdly,
        spr_ccr2_en_attn                    => spr_ccr2_en_attn,
        spr_ccr2_en_ditc                    => spr_ccr2_en_ditc,
        spr_ccr2_en_pc                      => spr_ccr2_en_pc,
        spr_ccr2_en_icswx                   => spr_ccr2_en_icswx,
        spr_ccr2_en_dcr                     => spr_ccr2_en_dcr,
        spr_dec_rf1_epcr_dgtmi              => spr_dec_rf1_epcr_dgtmi,
        spr_dec_rf1_msrp_uclep              => spr_dec_rf1_msrp_uclep,
        spr_dec_rf1_msr_ucle                => spr_dec_rf1_msr_ucle,
        spr_byp_ex4_is_mfxer                => spr_byp_ex4_is_mfxer,
        spr_byp_ex3_spr_rt                  => spr_byp_ex3_spr_rt,
        spr_byp_ex4_is_mtxer                => spr_byp_ex4_is_mtxer,
        spr_ccr2_notlb                      => spr_ccr2_notlb,
        dec_spr_rf1_val                     => dec_spr_rf1_val,
        fxu_spr_ex1_rs2                     => fxu_spr_ex1_rs2,
        fxa_perf_muldiv_in_use              => fxa_perf_muldiv_in_use,
        cpl_perf_tx_events                  => cpl_perf_tx_events,
        spr_perf_tx_events                  => spr_perf_tx_events,
        xu_pc_event_data                    => xu_pc_event_data,
        pc_xu_event_bus_enable              => pc_xu_event_bus_enable,
        pc_xu_event_count_mode              => pc_xu_event_count_mode,
        pc_xu_event_mux_ctrls               => pc_xu_event_mux_ctrls,
        pc_xu_trace_bus_enable              => pc_xu_trace_bus_enable,
        pc_xu_instr_trace_mode              => pc_xu_instr_trace_mode,
        pc_xu_instr_trace_tid               => pc_xu_instr_trace_tid,
        xu_lsu_ex2_instr_trace_val          => xu_lsu_ex2_instr_trace_val,
        dec_cpl_rf1_instr_trace_val         => dec_cpl_rf1_instr_trace_val,    
        dec_cpl_rf1_instr_trace_type        => dec_cpl_rf1_instr_trace_type,   
        dec_cpl_ex3_instr_trace_val         => dec_cpl_ex3_instr_trace_val,    
        cpl_dec_in_ucode                    => cpl_dec_in_ucode,
        lsu_xu_data_debug0                  => lsu_xu_data_debug0,
        lsu_xu_data_debug1                  => lsu_xu_data_debug1,
        lsu_xu_data_debug2                  => lsu_xu_data_debug2,
        fxu_debug_mux_ctrls                 => fxu_debug_mux_ctrls,
        fxu_debug_data_in                   => fxu_debug_data_in,
        fxu_trigger_data_in                 => fxu_trigger_data_in,
        fxu_debug_data_out                  => fxu_debug_data_out,
        fxu_trigger_data_out                => fxu_trigger_data_out,
        fxu_cpl_ex3_dac1r_cmpr_async        => fxu_cpl_ex3_dac1r_cmpr_async,
        fxu_cpl_ex3_dac2r_cmpr_async        => fxu_cpl_ex3_dac2r_cmpr_async,
        fxu_cpl_ex3_dac1r_cmpr              => fxu_cpl_ex3_dac1r_cmpr,
        fxu_cpl_ex3_dac2r_cmpr              => fxu_cpl_ex3_dac2r_cmpr,
        fxu_cpl_ex3_dac3r_cmpr              => fxu_cpl_ex3_dac3r_cmpr,
        fxu_cpl_ex3_dac4r_cmpr              => fxu_cpl_ex3_dac4r_cmpr,
        fxu_cpl_ex3_dac1w_cmpr              => fxu_cpl_ex3_dac1w_cmpr,
        fxu_cpl_ex3_dac2w_cmpr              => fxu_cpl_ex3_dac2w_cmpr,
        fxu_cpl_ex3_dac3w_cmpr              => fxu_cpl_ex3_dac3w_cmpr,
        fxu_cpl_ex3_dac4w_cmpr              => fxu_cpl_ex3_dac4w_cmpr,
        spr_msr_gs                          => spr_msr_gs,
        spr_msr_ds                          => spr_msr_ds,
        spr_msr_pr                          => spr_msr_pr,
        spr_dbcr0_dac1                      => spr_dbcr0_dac1,
        spr_dbcr0_dac2                      => spr_dbcr0_dac2,
        spr_dbcr0_dac3                      => spr_dbcr0_dac3,
        spr_dbcr0_dac4                      => spr_dbcr0_dac4,
        spr_dbcr3_ivc                       => spr_dbcr3_ivc_int,
        spr_xucr0_clkg_ctl                  => spr_xucr0_clkg_ctl(2 to 2)
    );

    xu_cpl : entity work.xuq_cpl(xuq_cpl)
   generic map(
      expand_type                      => expand_type,
      threads                          => threads,
      regsize                          => regsize,
      eff_ifar                         => eff_ifar)
   port map(
      -- Clocks
      nclk                             => nclk,
      -- CHIP IO
      ac_tc_debug_trigger              => ac_tc_debug_trigger,
      -- Pervasive
      an_ac_scan_dis_dc_b             => an_ac_scan_dis_dc_b,
      pc_xu_ccflush_dc                => pc_xu_ccflush_dc,
      clkoff_dc_b                     => clkoff_dc_b_b,
      d_mode_dc                       => d_mode_dc_b,
      delay_lclkr_dc                  => delay_lclkr_dc_b(3),
      mpw1_dc_b                       => mpw1_dc_b_b(3),
      mpw2_dc_b                       => mpw2_dc_b_b,
      func_slp_sl_thold_2             => func_slp_sl_thold_2_b(0),
      func_slp_nsl_thold_2            => func_slp_nsl_thold_2_b,
      func_sl_thold_2                 => func_sl_thold_2_b(0),
      func_nsl_thold_2                => func_nsl_thold_2_b,
      cfg_sl_thold_2                  => cfg_sl_thold_2_b,
      cfg_slp_sl_thold_2              => cfg_slp_sl_thold_2_b,
      sg_2                            => sg_2_b(0),
      fce_2                           => fce_2_b(0),
      func_scan_in                    => func_scan_in(50 to 53),
      func_scan_out                   => func_scan_out(50 to 53),
      bcfg_scan_in                    => bcfg_scan_in,
      bcfg_scan_out                   => bcfg_scan_out,
      ccfg_scan_in                    => ccfg_scan_in,
      ccfg_scan_out                   => ccfg_scan_out,
      dcfg_scan_in                    => dcfg_scan_in,
      dcfg_scan_out                   => dcfg_scan_out,

      -- Valids
      dec_cpl_rf0_act                  => dec_cpl_rf0_act,
      dec_cpl_rf0_tid                  => dec_cpl_rf0_tid,
      dec_cpl_rf1_val                  => dec_cpl_rf1_val,
      dec_cpl_rf1_issued               => dec_cpl_rf1_issued,
      -- FU Inputs
      fu_xu_rf1_act                    => fu_xu_rf1_act,
      fu_xu_ex2_ifar_val               => fu_xu_ex2_ifar_val,
      fu_xu_ex2_ifar_issued            => fu_xu_ex2_ifar_issued,
      fu_xu_ex1_ifar                   => fu_xu_ex1_ifar,
      fu_xu_ex2_instr_type             => fu_xu_ex2_instr_type,
      fu_xu_ex2_instr_match            => fu_xu_ex2_instr_match,
      fu_xu_ex2_is_ucode               => fu_xu_ex2_is_ucode,
      fu_xu_ex3_trap                   => fu_xu_ex3_trap,
      fu_xu_ex3_ap_int_req             => fu_xu_ex3_ap_int_req,
      -- PC Inputs
      pc_xu_step                       => pc_xu_step,
      pc_xu_stop                       => pc_xu_stop,
      pc_xu_dbg_action                 => pc_xu_dbg_action,
      pc_xu_force_ude                  => pc_xu_force_ude,
      xu_pc_step_done                  => xu_pc_step_done,
      -- Bypass Inputs
      byp_cpl_ex1_cr_bit               => byp_cpl_ex1_cr_bit,
      -- Decode Inputs
      dec_cpl_rf1_pred_taken_cnt       => dec_cpl_rf1_pred_taken_cnt,
      dec_cpl_rf1_instr                => dec_cpl_rf1_instr,
      dec_cpl_ex2_error                => dec_cpl_ex2_error,
      dec_cpl_ex2_match                => dec_cpl_ex2_match,
      dec_cpl_ex2_is_ucode             => dec_cpl_ex2_is_ucode,
      dec_cpl_ex3_is_any_store         => dec_cpl_ex3_is_any_store,
      dec_cpl_ex2_is_any_store_dac     => dec_cpl_ex2_is_any_store_dac,
      dec_cpl_ex2_is_any_load_dac      => dec_cpl_ex2_is_any_load_dac,
      dec_cpl_ex3_instr_priv           => dec_cpl_ex3_instr_priv,
      dec_cpl_ex1_epid_instr           => dec_ex1_epid_instr,
      dec_cpl_ex2_illegal_op           => dec_cpl_ex2_illegal_op,
      dec_cpl_ex3_mult_coll            => dec_cpl_ex3_mult_coll,
      dec_cpl_ex3_tlb_illeg            => dec_cpl_ex3_tlb_illeg,
      dec_cpl_ex3_axu_instr_type       => dec_cpl_ex3_axu_instr_type,
      dec_cpl_ex3_mc_dep_chk_val       => dec_cpl_ex3_mc_dep_chk_val,
      dec_cpl_rf1_ucode_val            => dec_cpl_rf1_ucode_val,
      dec_cpl_ex3_mtdp_nr              => dec_cpl_ex3_mtdp_nr,
      lsu_xu_ex4_mtdp_cr_status        => lsu_xu_ex4_mtdp_cr_status,
      dec_cpl_ex3_instr_hypv           => dec_cpl_ex3_instr_hypv,
      fxa_cpl_ex2_div_coll             => fxa_cpl_ex2_div_coll,
      -- Async Interrupt Req Interface
      spr_cpl_ext_interrupt            => spr_cpl_ext_interrupt,
      spr_cpl_dec_interrupt            => spr_cpl_dec_interrupt,
      spr_cpl_udec_interrupt           => spr_cpl_udec_interrupt,
      spr_cpl_perf_interrupt           => spr_cpl_perf_interrupt,
      spr_cpl_fit_interrupt            => spr_cpl_fit_interrupt,
      spr_cpl_crit_interrupt           => spr_cpl_crit_interrupt,
      spr_cpl_wdog_interrupt           => spr_cpl_wdog_interrupt,
      spr_cpl_dbell_interrupt          => spr_cpl_dbell_interrupt,
      spr_cpl_cdbell_interrupt         => spr_cpl_cdbell_interrupt,
      spr_cpl_gdbell_interrupt         => spr_cpl_gdbell_interrupt,
      spr_cpl_gcdbell_interrupt        => spr_cpl_gcdbell_interrupt,
      spr_cpl_gmcdbell_interrupt       => spr_cpl_gmcdbell_interrupt,
      cpl_spr_ex5_dbell_taken          => cpl_spr_ex5_dbell_taken,
      cpl_spr_ex5_cdbell_taken         => cpl_spr_ex5_cdbell_taken,
      cpl_spr_ex5_gdbell_taken         => cpl_spr_ex5_gdbell_taken,
      cpl_spr_ex5_gcdbell_taken        => cpl_spr_ex5_gcdbell_taken,
      cpl_spr_ex5_gmcdbell_taken       => cpl_spr_ex5_gmcdbell_taken,
      -- Debug Compares
      dec_cpl_rf1_ifar                 => dec_cpl_rf1_ifar,
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
      -- Interrupt Interface
      cpl_spr_ex5_act                  => cpl_spr_ex5_act,
      cpl_spr_ex5_int                  => cpl_spr_ex5_int,
      cpl_spr_ex5_gint                 => cpl_spr_ex5_gint,
      cpl_spr_ex5_cint                 => cpl_spr_ex5_cint,
      cpl_spr_ex5_mcint                => cpl_spr_ex5_mcint,
      cpl_spr_ex5_nia                  => cpl_spr_ex5_nia,
      cpl_spr_ex5_esr                  => cpl_spr_ex5_esr,
      cpl_spr_ex5_mcsr                 => cpl_spr_ex5_mcsr,
      cpl_spr_ex5_dbsr                 => cpl_spr_ex5_dbsr,
      cpl_spr_ex5_dear_save            => cpl_spr_ex5_dear_save,
      cpl_spr_ex5_dear_update_saved    => cpl_spr_ex5_dear_update_saved,
      cpl_spr_ex5_dear_update          => cpl_spr_ex5_dear_update,
      cpl_spr_ex5_dbsr_update          => cpl_spr_ex5_dbsr_update,
      cpl_spr_ex5_esr_update           => cpl_spr_ex5_esr_update,
      cpl_spr_ex5_srr0_dec             => cpl_spr_ex5_srr0_dec,
      cpl_spr_ex5_force_gsrr           => cpl_spr_ex5_force_gsrr,
      cpl_spr_ex5_dbsr_ide             => cpl_spr_ex5_dbsr_ide,
      spr_cpl_dbsr_ide                 => spr_cpl_dbsr_ide,
      -- ALU Inputs
      alu_cpl_ex1_eff_addr             => xu_ex1_eff_addr(62 to 63),
      -- Machine Check Interrupts
      mm_xu_local_snoop_reject         => mm_xu_local_snoop_reject,
      mm_xu_lru_par_err                => mm_xu_lru_par_err,
      mm_xu_tlb_par_err                => mm_xu_tlb_par_err,
      mm_xu_tlb_multihit_err           => mm_xu_tlb_multihit_err,
      lsu_xu_ex3_derat_par_err         => lsu_xu_ex3_derat_par_err,
      lsu_xu_ex4_derat_par_err         => lsu_xu_ex4_derat_par_err,
      lsu_xu_ex3_derat_multihit_err    => lsu_xu_ex3_derat_multihit_err,
      lsu_xu_ex3_l2_uc_ecc_err         => lsu_xu_ex3_l2_uc_ecc_err,
      lsu_xu_ex3_ddir_par_err          => lsu_xu_ex3_ddir_par_err,
      lsu_xu_ex4_n_lsu_ddmh_flush      => lsu_xu_ex4_n_lsu_ddmh_flush,
      lsu_xu_ex6_datc_par_err          => lsu_xu_ex6_datc_par_err,
      spr_cpl_external_mchk            => spr_cpl_external_mchk,
      -- ATTN complete
      xu_pc_err_attention_instr        => xu_pc_err_attention_instr,
      xu_pc_err_nia_miscmpr            => xu_pc_err_nia_miscmpr,
      xu_pc_err_debug_event            => xu_pc_err_debug_event,
      -- Data Storage
      derat_xu_ex3_dsi                 => derat_xu_ex3_dsi,
      lsu_xu_ex3_dsi                   => lsu_xu_ex3_dsi,
      spr_cpl_ex3_ct_le                => spr_cpl_ex3_ct_le,
      spr_cpl_ex3_ct_be                => spr_cpl_ex3_ct_be,
      -- Alignment
      lsu_xu_ex3_align                 => lsu_xu_ex3_align,
      -- Program
      spr_cpl_ex3_spr_illeg            => spr_cpl_ex3_spr_illeg,
      spr_cpl_ex3_spr_priv             => spr_cpl_ex3_spr_priv,
      alu_cpl_ex3_trap_val             => alu_cpl_ex3_trap_val,
      -- Hypv Privledge
      spr_cpl_ex3_spr_hypv             => spr_cpl_ex3_spr_hypv,
      -- Data TLB Miss
      derat_xu_ex3_miss                => derat_xu_ex3_miss,
      mm_xu_illeg_instr                => mm_xu_illeg_instr,
      -- Instr TLB Miss
      mm_xu_tlb_miss                   => mm_xu_tlb_miss,
      -- RAM
      pc_xu_ram_mode                   => pc_xu_ram_mode,
      pc_xu_ram_thread                 => pc_xu_ram_thread,
      pc_xu_ram_execute                => pc_xu_ram_execute,
      pc_xu_ram_flush_thread           => pc_xu_ram_flush_thread,
      xu_iu_ram_issue                  => xu_iu_ram_issue,
      xu_pc_ram_interrupt              => xu_pc_ram_interrupt,
      xu_pc_ram_done                   => xu_pc_ram_done,
      pc_xu_init_reset                 => pc_xu_init_reset,
      -- Run State
      cpl_spr_stop                     => cpl_spr_stop,
      cpl_spr_ex5_instr_cpl            => cpl_spr_ex5_instr_cpl,
      xu_pc_stop_dbg_event             => xu_pc_stop_dbg_event,
      spr_cpl_quiesce                  => spr_cpl_quiesce,
      cpl_spr_quiesce                  => cpl_spr_quiesce,
      spr_cpl_ex2_run_ctl_flush        => spr_cpl_ex2_run_ctl_flush,
      -- MMU Flushes
      mm_xu_pt_fault                   => mm_xu_pt_fault,
      mm_xu_tlb_inelig                 => mm_xu_tlb_inelig,
      mm_xu_lrat_miss                  => mm_xu_lrat_miss,
      mm_xu_hv_priv                    => mm_xu_hv_priv,
      mm_xu_esr_pt                     => mm_xu_esr_pt,
      mm_xu_esr_data                   => mm_xu_esr_data,
      mm_xu_esr_epid                   => mm_xu_esr_epid,
      mm_xu_esr_st                     => mm_xu_esr_st,
      mm_xu_hold_req                   => mm_xu_hold_req,
      mm_xu_hold_done                  => mm_xu_hold_done,
      xu_mm_hold_ack                   => xu_mm_hold_ack,
      mm_xu_eratmiss_done              => mm_xu_eratmiss_done,
      mm_xu_ex3_flush_req              => mm_xu_ex3_flush_req,
      -- LSU Flushes
      lsu_xu_l2_ecc_err_flush          => lsu_xu_l2_ecc_err_flush,
      lsu_xu_datc_perr_recovery        => lsu_xu_datc_perr_recovery,
      lsu_xu_ex3_dep_flush             => lsu_xu_ex3_dep_flush,
      lsu_xu_ex3_n_flush_req           => lsu_xu_ex3_n_flush_req,
      lsu_xu_ex3_ldq_hit_flush         => lsu_xu_ex3_ldq_hit_flush,
      lsu_xu_ex4_ldq_full_flush        => lsu_xu_ex4_ldq_full_flush,
      derat_xu_ex3_n_flush_req         => derat_xu_ex3_n_flush_req,
      lsu_xu_ex3_inval_align_2ucode    => lsu_xu_ex3_inval_align_2ucode,
      lsu_xu_ex3_attr                  => lsu_xu_ex3_attr,
      lsu_xu_ex3_derat_vf              => lsu_xu_ex3_derat_vf,
      -- AXU Flushes
      fu_xu_ex3_n_flush                => fu_xu_ex3_n_flush,
      fu_xu_ex3_np1_flush              => fu_xu_ex3_np1_flush,
      fu_xu_ex3_flush2ucode            => fu_xu_ex3_flush2ucode,
      fu_xu_ex2_async_block            => fu_xu_ex2_async_block,
      -- IU Flushes
      xu_iu_ex5_br_taken               => xu_iu_ex5_br_taken,
      xu_iu_ex5_ifar                   => xu_iu_ex5_ifar,
      xu_iu_flush                      => xu_iu_flush,
      xu_iu_iu0_flush_ifar             => xu_iu_iu0_flush_ifar,
      xu_iu_uc_flush_ifar              => xu_iu_uc_flush_ifar,
      xu_iu_flush_2ucode               => xu_iu_flush_2ucode,
      xu_iu_flush_2ucode_type          => xu_iu_flush_2ucode_type,
      xu_iu_ucode_restart              => xu_iu_ucode_restart,
      xu_iu_ex5_ppc_cpl                => xu_iu_ex5_ppc_cpl,
      -- Flushes
      xu_n_is2_flush                   => xu_n_is2_flush,
      xu_n_rf0_flush                   => xu_n_rf0_flush,
      xu_n_rf1_flush                   => xu_n_rf1_flush,
      xu_n_ex1_flush                   => xu_n_ex1_flush,
      xu_n_ex2_flush                   => xu_n_ex2_flush,
      xu_n_ex3_flush                   => xu_n_ex3_flush,
      xu_n_ex4_flush                   => xu_n_ex4_flush,
      xu_n_ex5_flush                   => xu_n_ex5_flush,
      xu_s_rf1_flush                   => xu_s_rf1_flush,
      xu_s_ex1_flush                   => xu_s_ex1_flush,
      xu_s_ex2_flush                   => xu_s_ex2_flush,
      xu_s_ex3_flush                   => xu_s_ex3_flush,
      xu_s_ex4_flush                   => xu_s_ex4_flush,
      xu_s_ex5_flush                   => xu_s_ex5_flush,
      xu_w_rf1_flush                   => xu_w_rf1_flush,
      xu_w_ex1_flush                   => xu_w_ex1_flush,
      xu_w_ex2_flush                   => xu_w_ex2_flush,
      xu_w_ex3_flush                   => xu_w_ex3_flush,
      xu_w_ex4_flush                   => xu_w_ex4_flush,
      xu_w_ex5_flush                   => xu_w_ex5_flush,
      xu_rf0_flush                     => xu_rf0_flush_int,
      xu_rf1_flush                     => xu_rf1_flush_int,
      xu_ex1_flush                     => xu_ex1_flush_int,
      xu_ex2_flush                     => xu_ex2_flush_int,
      xu_ex3_flush                     => xu_ex3_flush_int,
      xu_ex4_flush                     => xu_ex4_flush_int,
      xu_ex5_flush                     => xu_ex5_flush_int,
      xu_mm_ex4_flush                  => xu_mm_ex4_flush,
      xu_mm_ex5_flush                  => xu_mm_ex5_flush,
      xu_mm_ierat_flush                => xu_mm_ierat_flush,
      xu_mm_ierat_miss                 => xu_mm_ierat_miss,
      xu_mm_ex5_perf_itlb              => xu_mm_ex5_perf_itlb,
      xu_mm_ex5_perf_dtlb              => xu_mm_ex5_perf_dtlb,
      xu_lsu_ex4_flush_local           => xu_lsu_ex4_flush_local,
      xu_lsu_dci                       => xu_lsu_dci,
      xu_lsu_ici                       => xu_lsu_ici,
      xu_lsu_ex4_val                   => xu_lsu_ex4_val,
      -- Parity
      spr_cpl_ex3_sprg_ue              => spr_cpl_ex3_sprg_ue,
      spr_cpl_ex3_sprg_ce              => spr_cpl_ex3_sprg_ce,
      iu_xu_ierat_ex2_flush_req        => iu_xu_ierat_ex2_flush_req,
      iu_xu_ierat_ex3_par_err          => iu_xu_ierat_ex3_par_err,
      iu_xu_ierat_ex4_par_err          => iu_xu_ierat_ex4_par_err,
      -- Regfile Parity
       fu_xu_ex3_regfile_err_det          => fu_xu_ex3_regfile_err_det,
       xu_fu_regfile_seq_beg             => xu_fu_regfile_seq_beg,
       fu_xu_regfile_seq_end             => fu_xu_regfile_seq_end,
       gpr_cpl_ex3_regfile_err_det     => gpr_cpl_ex3_regfile_err_det,
       cpl_gpr_regfile_seq_beg           => cpl_gpr_regfile_seq_beg,
       gpr_cpl_regfile_seq_end           => gpr_cpl_regfile_seq_end,
       xu_pc_err_mcsr_summary           => xu_pc_err_mcsr_summary,
       xu_pc_err_ditc_overrun           => xu_pc_err_ditc_overrun,
       xu_pc_err_local_snoop_reject     => xu_pc_err_local_snoop_reject,
       xu_pc_err_tlb_lru_parity         => xu_pc_err_tlb_lru_parity,
       xu_pc_err_ext_mchk               => xu_pc_err_ext_mchk,
       xu_pc_err_ierat_multihit         => xu_pc_err_ierat_multihit,
       xu_pc_err_derat_multihit         => xu_pc_err_derat_multihit,
       xu_pc_err_tlb_multihit           => xu_pc_err_tlb_multihit,
       xu_pc_err_ierat_parity           => xu_pc_err_ierat_parity,
       xu_pc_err_derat_parity           => xu_pc_err_derat_parity,
       xu_pc_err_mchk_disabled          => xu_pc_err_mchk_disabled,
       xu_pc_err_tlb_parity             => xu_pc_err_tlb_parity,
       xu_pc_err_sprg_ue                => xu_pc_err_sprg_ue,
      -- Perf
      cpl_perf_tx_events               => cpl_perf_tx_events,
      spr_cpl_async_int                => spr_cpl_async_int,
      -- Barrier
      xu_lsu_ex5_set_barr              => xu_lsu_ex5_set_barr,
      cpl_fxa_ex5_set_barr             => cpl_fxa_ex5_set_barr,
      cpl_iu_set_barr_tid               => cpl_iu_set_barr_tid,
      -- Read Data
      cpl_byp_ex3_spr_rt               => cpl_byp_ex3_spr_rt,
      -- Write Data
      mux_cpl_ex4_rt                   => mux_cpl_ex4_rt,
      -- SPR Bits
      spr_bit_act                      => spr_bit_act,
      spr_cpl_iac1_en                  => spr_cpl_iac1_en,
      spr_cpl_iac2_en                  => spr_cpl_iac2_en,
      spr_cpl_iac3_en                  => spr_cpl_iac3_en,
      spr_cpl_iac4_en                  => spr_cpl_iac4_en,
      spr_dbcr1_iac12m                 => spr_dbcr1_iac12m,
      spr_dbcr1_iac34m                 => spr_dbcr1_iac34m,
      spr_cpl_fp_precise               => spr_cpl_fp_precise,
      spr_xucr0_mddp                   => spr_xucr0_mddp,
      spr_xucr0_mdcp                   => spr_xucr0_mdcp,
      spr_msr_de                       => spr_msr_de,
      spr_msr_spv                      => spr_msr_spv,
      spr_msr_fp                       => spr_msr_fp,
      spr_msr_pr                       => spr_msr_pr,
      spr_msr_gs                       => spr_msr_gs,
      spr_msr_me                       => spr_msr_me,
      spr_msr_cm                       => spr_msr_cm,
      spr_msr_ucle                     => spr_msr_ucle,
      spr_msrp_uclep                   => spr_msrp_uclep,
      spr_ccr2_notlb                   => spr_ccr2_notlb,
      spr_ccr2_ucode_dis               => spr_ccr2_ucode_dis,
      spr_ccr2_ap                      => spr_ccr2_ap,
      spr_dbcr0_idm                    => spr_dbcr0_idm,
      cpl_spr_dbcr0_edm                => cpl_spr_dbcr0_edm,
      spr_dbcr0_icmp                   => spr_dbcr0_icmp,
      spr_dbcr0_brt                    => spr_dbcr0_brt,
      spr_dbcr0_trap                   => spr_dbcr0_trap,
      spr_dbcr0_ret                    => spr_dbcr0_ret,
      spr_dbcr0_irpt                   => spr_dbcr0_irpt,
      spr_dbcr3_ivc                    => spr_dbcr3_ivc_int,
      spr_epcr_dsigs                   => spr_epcr_dsigs,
      spr_epcr_isigs                   => spr_epcr_isigs,
      spr_epcr_extgs                   => spr_epcr_extgs,
      spr_epcr_dtlbgs                  => spr_epcr_dtlbgs,
      spr_epcr_itlbgs                  => spr_epcr_itlbgs,
      spr_xucr4_div_barr_thres         => spr_xucr4_div_barr_thres,
      spr_xucr4_mmu_mchk               => spr_xucr4_mmu_mchk,
      spr_ccr0_we                      => spr_ccr0_we,
      spr_epcr_duvd                    => spr_epcr_duvd,
      cpl_msr_gs                       => cpl_msr_gs,
      cpl_msr_pr                       => cpl_msr_pr,
      cpl_msr_fp                       => cpl_msr_fp,
      cpl_msr_spv                      => cpl_msr_spv,
      cpl_ccr2_ap                      => cpl_ccr2_ap,
      spr_xucr0_clkg_ctl               => spr_xucr0_clkg_ctl(2 to 2),
      -- Slow SPR Bus
      mux_cpl_slowspr_flush            => mux_cpl_slowspr_flush,
      mux_cpl_slowspr_done             => mux_cpl_slowspr_done,
      dec_cpl_ex1_is_slowspr_wr        => dec_cpl_ex1_is_slowspr_wr,
      dec_cpl_ex3_ddmh_en              => dec_cpl_ex3_ddmh_en,
      dec_cpl_ex3_back_inv             => dec_cpl_ex3_back_inv,
      -- Debug
      pc_xu_event_bus_enable           => pc_xu_event_bus_enable,
      pc_xu_trace_bus_enable           => pc_xu_trace_bus_enable,
      pc_xu_instr_trace_mode           => pc_xu_instr_trace_mode,
      dec_cpl_rf1_instr_trace_val      => dec_cpl_rf1_instr_trace_val,
      dec_cpl_rf1_instr_trace_type     => dec_cpl_rf1_instr_trace_type,
      dec_cpl_ex3_instr_trace_val      => dec_cpl_ex3_instr_trace_val,
      cpl_dec_in_ucode                 => cpl_dec_in_ucode,
      cpl_debug_mux_ctrls              => cpl_debug_mux_ctrls,
      cpl_debug_data_in                => cpl_debug_data_in,
      cpl_debug_data_out               => cpl_debug_data_out,
      cpl_trigger_data_in              => cpl_trigger_data_in,
      cpl_trigger_data_out             => cpl_trigger_data_out,
      fxa_cpl_debug                    => fxa_cpl_debug,
      -- Power
      vdd                              => vdd,
      gnd                              => gnd
   );

xu_ex1_eff_addr_int     <= xu_ex1_eff_addr;
xu_rf0_flush            <= xu_rf0_flush_int;
xu_rf1_flush            <= xu_rf1_flush_int;
xu_ex1_flush            <= xu_ex1_flush_int;
xu_ex2_flush            <= xu_ex2_flush_int;
xu_ex3_flush            <= xu_ex3_flush_int;
xu_ex4_flush            <= xu_ex4_flush_int;
dec_spr_ex1_epid_instr  <= dec_ex1_epid_instr;

end xuq_cpl_fxub;
