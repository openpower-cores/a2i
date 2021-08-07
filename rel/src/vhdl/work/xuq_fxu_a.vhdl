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

--  Description:  xuq_fxu_a_A Top
--
LIBRARY ieee;       USE ieee.std_logic_1164.all;
LIBRARY support;    
                    USE support.power_logic_pkg.all;
LIBRARY tri;        USE tri.tri_latches_pkg.all;
LIBRARY work;       USE work.xuq_pkg.mark_unused;

entity xuq_fxu_a is
    generic(
        expand_type                         : integer := 2;
        threads                             : integer := 4;
        eff_ifar                            : integer := 62;
        regmode                             : integer := 6;
        regsize                             : integer := 64;
        a2mode                              : integer := 1;
        hvmode                              : integer := 1;
        real_data_add                       : integer := 42);
    port(
        ---------------------------------------------------------------------
        -- Clocks & Power
        ---------------------------------------------------------------------
        nclk                                : in clk_logic;
        vdd                                 : inout power_logic;
        gnd                                 : inout power_logic;
        vcs                                 : inout power_logic;

        ---------------------------------------------------------------------
        -- Pervasive
        ---------------------------------------------------------------------
        an_ac_scan_dis_dc_b                 : in     std_ulogic;     
        func_scan_in                        : in     std_ulogic_vector(14 to 14);
        func_scan_out                       : out    std_ulogic_vector(14 to 14);
        abst_scan_in                        : in     std_ulogic;
        abst_scan_out                       : out    std_ulogic;
        pc_xu_abist_raddr_0                 : in     std_ulogic_vector(2 to 9);
        pc_xu_abist_raddr_1                 : in     std_ulogic_vector(2 to 9);
        pc_xu_abist_grf_renb_0              : in     std_ulogic;
        pc_xu_abist_grf_renb_1              : in     std_ulogic;
        pc_xu_abist_ena_dc                  : in     std_ulogic;
        pc_xu_abist_waddr_0                 : in     std_ulogic_vector(2 to 9);
        pc_xu_abist_waddr_1                 : in     std_ulogic_vector(2 to 9);
        pc_xu_abist_grf_wenb_0              : in     std_ulogic;
        pc_xu_abist_grf_wenb_1              : in     std_ulogic;
        pc_xu_abist_di_0                    : in     std_ulogic_vector(0 to 3);
        pc_xu_abist_di_1                    : in     std_ulogic_vector(0 to 3);
        pc_xu_abist_wl144_comp_ena          : in     std_ulogic;
        pc_xu_abist_raw_dc_b                : in     std_ulogic;
        pc_xu_ccflush_dc                    : in     std_ulogic;
        bo_enable_2                         : in     std_ulogic; -- general bolt-on enable, probably DC
        pc_xu_bo_reset                      : in     std_ulogic; -- execute sticky bit decode
        pc_xu_bo_unload                     : in     std_ulogic;
        pc_xu_bo_load                       : in     std_ulogic;
        pc_xu_bo_shdata                     : in     std_ulogic; -- shift data for timing write
        pc_xu_bo_select                     : in     std_ulogic_vector(0 to 1); -- select for mask and hier writes
        xu_pc_bo_fail                       : out    std_ulogic_vector(0 to 1); -- fail/no-fix reg
        xu_pc_bo_diagout                    : out    std_ulogic_vector(0 to 1);
        clkoff_dc_b                         : in     std_ulogic;
        d_mode_dc                           : in     std_ulogic;
        delay_lclkr_dc                      : in     std_ulogic_vector(4 to 4);
        mpw1_dc_b                           : in     std_ulogic_vector(4 to 4);
        mpw2_dc_b                           : in     std_ulogic;
        an_ac_scan_diag_dc                  : in     std_ulogic;
        an_ac_lbist_ary_wrt_thru_dc         : in     std_ulogic;
        scan_dis_dc_b                       : in     std_ulogic;
        sg_2                                : in     std_ulogic_vector(0 to 0);
        fce_2                               : in     std_ulogic_vector(0 to 0);
        func_sl_thold_2                     : in     std_ulogic_vector(0 to 0);
        func_nsl_thold_2                    : in     std_ulogic;
        abst_sl_thold_2                     : in     std_ulogic;
        time_sl_thold_2                     : in     std_ulogic;
        gptr_sl_thold_2                     : in     std_ulogic;
        bolt_sl_thold_2                     : in     std_ulogic;
        ary_nsl_thold_2                     : in     std_ulogic;
        time_scan_in                        : in     std_ulogic;
        time_scan_out                       : out    std_ulogic;
        gptr_scan_in                        : in     std_ulogic;
        gptr_scan_out                       : out    std_ulogic;

        ---------------------------------------------------------------------
        -- Interface with IU
        ---------------------------------------------------------------------
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
        xu_iu_multdiv_done                  : out std_ulogic_vector(0 to threads-1);
        xu_iu_membar_tid                    : out std_ulogic_vector(0 to threads-1);

        ---------------------------------------------------------------------
        -- Interface with LSU
        ---------------------------------------------------------------------
        lsu_xu_ldq_barr_done                : in  std_ulogic_vector(0 to threads-1);
        lsu_xu_barr_done                    : in  std_ulogic_vector(0 to threads-1);

        ---------------------------------------------------------------------
        -- Interface with FXU B
        ---------------------------------------------------------------------
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
        fxa_fxb_rf0_axu_mftgpr              : out std_ulogic;
        fxa_fxb_rf0_axu_mffgpr              : out std_ulogic;
        fxa_fxb_rf0_axu_movedp              : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_size           : out std_ulogic_vector(0 to 5);
        fxa_fxb_rf0_axu_ldst_update         : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_forcealign     : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_forceexcept    : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_indexed        : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_tag            : out std_ulogic_vector(0 to 8);
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
        fxb_fxa_ex7_we0                     : in  std_ulogic;
        fxb_fxa_ex7_wa0                     : in  std_ulogic_vector(0 to 7);
        fxb_fxa_ex7_wd0                     : in  std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do0                     : out std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do1                     : out std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do2                     : out std_ulogic_vector(64-regsize to 63);
        fxb_fxa_ex6_clear_barrier           : in  std_ulogic_vector(0 to threads-1);
        fxa_perf_muldiv_in_use              : out std_ulogic;

        ---------------------------------------------------------------------
        -- Flushes
        ---------------------------------------------------------------------
        xu_is2_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_rf0_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_rf1_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex1_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex2_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex3_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex4_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex5_flush                        : in  std_ulogic_vector(0 to threads-1);
        fxa_cpl_ex2_div_coll                : out std_ulogic_vector(0 to threads-1);
        cpl_fxa_ex5_set_barr                : in  std_ulogic_vector(0 to threads-1);
        fxa_iu_set_barr_tid                 : out std_ulogic_vector(0 to threads-1);
        spr_xucr4_div_barr_thres            : in  std_ulogic_vector(0 to 7);

        ---------------------------------------------------------------------
        -- ICSWX
        ---------------------------------------------------------------------
        an_ac_back_inv                      : in  std_ulogic;
        an_ac_back_inv_addr                 : in  std_ulogic_vector(62 to 63);
        an_ac_back_inv_target_bit3          : in  std_ulogic;

        ---------------------------------------------------------------------
        -- Interface with SPR
        ---------------------------------------------------------------------
        dec_spr_rf0_instr                   : out std_ulogic_vector(0 to 31);

        ---------------------------------------------------------------------
        -- Parity
        ---------------------------------------------------------------------
        pc_xu_inj_regfile_parity            : in std_ulogic_vector(0 to 3);
        xu_pc_err_regfile_parity            : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_regfile_ue                : out std_ulogic_vector(0 to 3);
        gpr_cpl_ex3_regfile_err_det         : out std_ulogic;
        cpl_gpr_regfile_seq_beg             : in  std_ulogic;
        gpr_cpl_regfile_seq_end             : out std_ulogic;

        ---------------------------------------------------------------------
        -- Interface with LSU
        ---------------------------------------------------------------------
        xu_lsu_rf0_derat_is_extload         : out std_ulogic;
        xu_lsu_rf0_derat_is_extstore        : out std_ulogic;
        xu_lsu_rf0_derat_val                : out std_ulogic_vector(0 to threads-1);
        lsu_xu_rel_wren                     : in  std_ulogic;
        lsu_xu_rel_ta_gpr                   : in  std_ulogic_vector(0 to 7);
        lsu_xu_rot_rel_data                 : in  std_ulogic_vector(64-(2**regmode) to 63+(2**regmode)/8);
        
        spr_xucr0_clkg_ctl_b0               : in  std_ulogic;
        fxa_cpl_debug                       : out std_ulogic_vector(0 to 272)
    );
    --  synopsys translate_off

    --  synopsys translate_on
end xuq_fxu_a;

architecture xuq_fxu_a of xuq_fxu_a is
    constant tiup                           : std_ulogic := '1';
    constant tidn                           : std_ulogic := '0';

    ---------------------------------------------------------------------
    -- Pervasive Signals
    ---------------------------------------------------------------------
    signal func_sl_thold_1                  : std_ulogic;
    signal func_nsl_thold_1                 : std_ulogic;
    signal time_sl_thold_1                  : std_ulogic;
    signal gptr_sl_thold_1                  : std_ulogic;
    signal bolt_sl_thold_1                  : std_ulogic;
    signal sg_1                             : std_ulogic;
    signal fce_1                            : std_ulogic_vector(0 to 1);
    signal abst_sl_thold_1                  : std_ulogic;
    signal ary_nsl_thold_1                  : std_ulogic;
    signal func_sl_thold_0                  : std_ulogic;
    signal func_nsl_thold_0                 : std_ulogic;
    signal time_sl_thold_0                  : std_ulogic;
    signal gptr_sl_thold_0                  : std_ulogic;
    signal bolt_sl_thold_0                  : std_ulogic;
    signal sg_0                             : std_ulogic;
    signal fce_0                            : std_ulogic_vector(0 to 1);
    signal abst_sl_thold_0                  : std_ulogic;
    signal ary_nsl_thold_0                  : std_ulogic;
    signal func_sl_force                    : std_ulogic;
    signal func_nsl_force                   : std_ulogic;
    signal func_sl_thold_0_b                : std_ulogic;
    signal func_nsl_thold_0_b               : std_ulogic;
    signal func_scan_rpwr_in                : std_ulogic_vector(14 to 14);
    signal func_scan_rpwr_out               : std_ulogic_vector(14 to 14);
    signal func_scan_out_gate               : std_ulogic_vector(14 to 14);
    signal func_so_thold_0_b, so_force      : std_ulogic;

    ---------------------------------------------------------------------
    -- ABIST
    ---------------------------------------------------------------------
    signal abst_sl_thold_0_b                : std_ulogic;
    signal abst_sl_force                    : std_ulogic;
    signal pc_xu_abist_raddr_0_q            : std_ulogic_vector(2 to 9);
    signal pc_xu_abist_raddr_1_q            : std_ulogic_vector(2 to 9);
    signal pc_xu_abist_grf_renb_0_q         : std_ulogic;
    signal pc_xu_abist_grf_renb_1_q         : std_ulogic;
    signal pc_xu_abist_waddr_0_q            : std_ulogic_vector(2 to 9);
    signal pc_xu_abist_waddr_1_q            : std_ulogic_vector(2 to 9);
    signal pc_xu_abist_grf_wenb_0_q         : std_ulogic;
    signal pc_xu_abist_grf_wenb_1_q         : std_ulogic;
    signal pc_xu_abist_di_0_q               : std_ulogic_vector(0 to 3);
    signal pc_xu_abist_di_1_q               : std_ulogic_vector(0 to 3);
    signal pc_xu_abist_wl144_comp_ena_q     : std_ulogic;
    signal slat_force                       : std_ulogic;
    signal abst_slat_thold_b                : std_ulogic;
    signal abst_slat_d2clk                  : std_ulogic;
    signal abst_slat_lclk                   : clk_logic;
    signal abist_siv                        : std_ulogic_vector(0 to 45);
    signal abist_sov                        : std_ulogic_vector(0 to 45);
    signal abst_scan_in_q                   : std_ulogic;
    signal abst_scan_out_int                : std_ulogic;
    signal abst_scan_out_q                  : std_ulogic;
    signal abst_scan_in_2_q                 : std_ulogic;
    signal abst_scan_out_2_q                : std_ulogic;

    ---------------------------------------------------------------------
    -- Scan Chain
    ---------------------------------------------------------------------
    signal siv_14                           : std_ulogic_vector(0 to 1);
    signal sov_14                           : std_ulogic_vector(0 to 1);

    ---------------------------------------------------------------------
    -- GPR Signals
    ---------------------------------------------------------------------
    signal dec_gpr_rf0_re0                  : std_ulogic;
    signal dec_gpr_rf0_re1                  : std_ulogic;
    signal dec_gpr_rf0_re2                  : std_ulogic;
    signal dec_gpr_rf0_ra0                  : std_ulogic_vector(0 to 7);
    signal dec_gpr_rf0_ra1                  : std_ulogic_vector(0 to 7);
    signal dec_gpr_rf0_ra2                  : std_ulogic_vector(0 to 7);
    signal dec_gpr_rel_ta_gpr               : std_ulogic_vector(0 to 7);
    signal dec_gpr_rel_wren                 : std_ulogic;
    signal gpr_rel_data                     : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal gpr_data_out_0                   : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal gpr_data_out_1                   : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal gpr_data_out_2                   : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal xu_div_coll_barr_done            : std_ulogic_vector(0 to threads-1);
    signal xu_div_barr_done                 : std_ulogic_vector(0 to threads-1);
    signal gpr_debug                        : std_ulogic_vector(0 to 21);
    signal dec_debug                        : std_ulogic_vector(0 to 175);
    signal gpr_we1_debug                    : std_ulogic_vector(0 to 74);
    
begin

    fxa_cpl_debug    <= dec_debug & gpr_debug & (0 to 74=>'0');
    
    gpr_we1_debug(0 to 65)    <= gpr_rel_data(0 to 63) & dec_gpr_rel_wren & dec_gpr_rel_ta_gpr(0);
    gpr_we1_debug(66 to 74)   <= dec_gpr_rel_wren & dec_gpr_rel_ta_gpr;   
    
    mark_unused(gpr_we1_debug);

    ---------------------------------------------------------------------
    -- Clear Barrier
    ---------------------------------------------------------------------
    xu_iu_membar_tid            <= lsu_xu_ldq_barr_done or xu_div_coll_barr_done;
    
    xu_iu_multdiv_done          <= xu_div_barr_done or fxb_fxa_ex6_clear_barrier or lsu_xu_barr_done;

    ---------------------------------------------------------------------
    -- ABIST latches
    ---------------------------------------------------------------------
    abist_reg: tri_rlmreg_p
        generic map (init => 0, expand_type => expand_type, width => 45, needs_sreset => 0)
        port map (vd                                => vdd,
                  gd                                => gnd,
                  nclk                              => nclk,
                  act                               => pc_xu_abist_ena_dc,
                  thold_b                           => abst_sl_thold_0_b,
                  sg                                => sg_0,
                  forcee => abst_sl_force,
                  delay_lclkr                       => delay_lclkr_dc(4),
                  mpw1_b                            => mpw1_dc_b(4),
                  mpw2_b                            => mpw2_dc_b,
                  d_mode                            => d_mode_dc,
                  scin                              => abist_siv(1 to 45),
                  scout                             => abist_sov(1 to 45),
                  din(0 to 7)                       => pc_xu_abist_raddr_0,
                  din(8 to 15)                      => pc_xu_abist_raddr_1,
                  din(16)                           => pc_xu_abist_grf_renb_0,
                  din(17)                           => pc_xu_abist_grf_renb_1,
                  din(18 to 25)                     => pc_xu_abist_waddr_0,
                  din(26 to 33)                     => pc_xu_abist_waddr_1,
                  din(34)                           => pc_xu_abist_grf_wenb_0,
                  din(35)                           => pc_xu_abist_grf_wenb_1,
                  din(36 to 39)                     => pc_xu_abist_di_0,
                  din(40 to 43)                     => pc_xu_abist_di_1,
                  din(44)                           => pc_xu_abist_wl144_comp_ena,
                  ---------------------------------------------------------------------
                  dout(0 to 7)                      => pc_xu_abist_raddr_0_q,
                  dout(8 to 15)                     => pc_xu_abist_raddr_1_q,
                  dout(16)                          => pc_xu_abist_grf_renb_0_q,
                  dout(17)                          => pc_xu_abist_grf_renb_1_q,
                  dout(18 to 25)                    => pc_xu_abist_waddr_0_q,
                  dout(26 to 33)                    => pc_xu_abist_waddr_1_q,
                  dout(34)                          => pc_xu_abist_grf_wenb_0_q,
                  dout(35)                          => pc_xu_abist_grf_wenb_1_q,
                  dout(36 to 39)                    => pc_xu_abist_di_0_q,
                  dout(40 to 43)                    => pc_xu_abist_di_1_q,
                  dout(44)                          => pc_xu_abist_wl144_comp_ena_q);

    slat_force                  <= sg_0;
    abst_slat_thold_b           <= NOT abst_sl_thold_0;

    perv_lcbs_abst: tri_lcbs
        generic map (expand_type => expand_type )
        port map (vd                                => vdd,
                  gd                                => gnd,
                  delay_lclkr                       => delay_lclkr_dc(4),
                  nclk                              => nclk,
                  forcee => slat_force,
                  thold_b                           => abst_slat_thold_b,
                  dclk                              => abst_slat_d2clk,
                  lclk                              => abst_slat_lclk );

    perv_abst_stg: tri_slat_scan
        generic map (width => 4, init => (1 to 4=>'0'), expand_type => expand_type)
        port map (vd                                => vdd,
                  gd                                => gnd,
                  dclk                              => abst_slat_d2clk,
                  lclk                              => abst_slat_lclk,
                  scan_in(0)                        => abst_scan_in,
                  scan_in(1)                        => abst_scan_out_int,
                  scan_in(2)                        => abst_scan_in_q,
                  scan_in(3)                        => abst_scan_out_q,
                  scan_out(0)                       => abst_scan_in_q,
                  scan_out(1)                       => abst_scan_out_q,
                  scan_out(2)                       => abst_scan_in_2_q,
                  scan_out(3)                       => abst_scan_out_2_q);


    abist_siv                   <= abist_sov(1 to abist_sov'right) & abst_scan_in_2_q;
    abst_scan_out_int           <= abist_sov(0);
    abst_scan_out               <= abst_scan_out_2_q and scan_dis_dc_b;



    -------------------------------------------------
    -- Pervasive
    -------------------------------------------------
    perv_2to1_reg: tri_plat
        generic map (width => 10, expand_type => expand_type)
        port map (vd        => vdd,
                  gd        => gnd,
                  nclk      => nclk,
                  flush     => pc_xu_ccflush_dc,
                  din(0)    => abst_sl_thold_2,
                  din(1)    => func_sl_thold_2(0),
                  din(2)    => sg_2(0),
                  din(3)    => fce_2(0),
                  din(4)    => fce_2(0),
                  din(5)    => ary_nsl_thold_2,
                  din(6)    => time_sl_thold_2,
                  din(7)    => gptr_sl_thold_2,
                  din(8)    => bolt_sl_thold_2,
                  din(9)    => func_nsl_thold_2,
                  q(0)      => abst_sl_thold_1,
                  q(1)      => func_sl_thold_1,
                  q(2)      => sg_1,
                  q(3)      => fce_1(0),
                  q(4)      => fce_1(1),
                  q(5)      => ary_nsl_thold_1,
                  q(6)      => time_sl_thold_1,
                  q(7)      => gptr_sl_thold_1,
                  q(8)      => bolt_sl_thold_1,
                  q(9)      => func_nsl_thold_1);

    perv_1to0_reg: tri_plat
        generic map (width => 10, expand_type => expand_type)
        port map (vd        => vdd,
                  gd        => gnd,
                  nclk      => nclk,
                  flush     => pc_xu_ccflush_dc,
                  din(0)    => abst_sl_thold_1,
                  din(1)    => func_sl_thold_1,
                  din(2)    => sg_1,
                  din(3)    => fce_1(0),
                  din(4)    => fce_1(1),
                  din(5)    => ary_nsl_thold_1,
                  din(6)    => time_sl_thold_1,
                  din(7)    => gptr_sl_thold_1,
                  din(8)    => bolt_sl_thold_1,
                  din(9)    => func_nsl_thold_1,
                  q(0)      => abst_sl_thold_0,
                  q(1)      => func_sl_thold_0,
                  q(2)      => sg_0,
                  q(3)      => fce_0(0),
                  q(4)      => fce_0(1),
                  q(5)      => ary_nsl_thold_0,
                  q(6)      => time_sl_thold_0,
                  q(7)      => gptr_sl_thold_0,
                  q(8)      => bolt_sl_thold_0,
                  q(9)      => func_nsl_thold_0);

    perv_lcbor_func_nsl: tri_lcbor
        generic map (expand_type => expand_type)
        port map (clkoff_b  => clkoff_dc_b,
                  thold     => func_nsl_thold_0,
                  sg        => fce_0(0),
                  act_dis   => tidn,
                  forcee => func_nsl_force,
                  thold_b   => func_nsl_thold_0_b);

    perv_lcbor_func_sl: tri_lcbor
        generic map (expand_type => expand_type)
        port map (clkoff_b  => clkoff_dc_b,
                  thold     => func_sl_thold_0,
                  sg        => sg_0,
                  act_dis   => tidn,
                  forcee => func_sl_force,
                  thold_b   => func_sl_thold_0_b);

    perv_lcbor_abst_sl: tri_lcbor
        generic map (expand_type => expand_type)
        port map (clkoff_b  => clkoff_dc_b,
                  thold     => abst_sl_thold_0,
                  sg        => sg_0,
                  act_dis   => tidn,
                  forcee => abst_sl_force,
                  thold_b   => abst_sl_thold_0_b);

   so_force                <= sg_0;
   func_so_thold_0_b       <= not func_sl_thold_0;


    -------------------------------------------------------------------------------
    -- Decode A
    -------------------------------------------------------------------------------
    xu_dec_a : entity work.xuq_dec_a(xuq_dec_a)
    generic map(
        expand_type                         => expand_type,
        threads                             => threads,
        regmode                             => regmode,
        regsize                             => regsize,
        real_data_add                       => real_data_add,
        eff_ifar                            => eff_ifar)
    port map(
        nclk                                => nclk,
        vdd                                 => vdd,
        gnd                                 => gnd,
        d_mode_dc                           => d_mode_dc,
        delay_lclkr_dc                      => delay_lclkr_dc(4),
        mpw1_dc_b                           => mpw1_dc_b(4),
        mpw2_dc_b                           => mpw2_dc_b,
        func_sl_force => func_sl_force,
        func_sl_thold_0_b                   => func_sl_thold_0_b,
        sg_0                                => sg_0,
        scan_in                             => siv_14(0),
        scan_out                            => sov_14(0),
        iu_xu_is2_vld                       => iu_xu_is2_vld,
        iu_xu_is2_ifar                      => iu_xu_is2_ifar,
        iu_xu_is2_tid                       => iu_xu_is2_tid,
        iu_xu_is2_instr                     => iu_xu_is2_instr,
        iu_xu_is2_ta_vld                    => iu_xu_is2_ta_vld,
        iu_xu_is2_ta                        => iu_xu_is2_ta,
        iu_xu_is2_s1_vld                    => iu_xu_is2_s1_vld,
        iu_xu_is2_s1                        => iu_xu_is2_s1,
        iu_xu_is2_s2_vld                    => iu_xu_is2_s2_vld,
        iu_xu_is2_s2                        => iu_xu_is2_s2,
        iu_xu_is2_s3_vld                    => iu_xu_is2_s3_vld,
        iu_xu_is2_s3                        => iu_xu_is2_s3,
        iu_xu_is2_axu_ld_or_st              => iu_xu_is2_axu_ld_or_st,
        iu_xu_is2_axu_store                 => iu_xu_is2_axu_store,
        iu_xu_is2_axu_ldst_size             => iu_xu_is2_axu_ldst_size,
        iu_xu_is2_axu_ldst_update           => iu_xu_is2_axu_ldst_update,
        iu_xu_is2_axu_ldst_forcealign       => iu_xu_is2_axu_ldst_forcealign,
        iu_xu_is2_axu_ldst_forceexcept      => iu_xu_is2_axu_ldst_forceexcept,
        iu_xu_is2_axu_ldst_extpid           => iu_xu_is2_axu_ldst_extpid,
        iu_xu_is2_axu_ldst_indexed          => iu_xu_is2_axu_ldst_indexed,
        iu_xu_is2_axu_ldst_tag              => iu_xu_is2_axu_ldst_tag,
        iu_xu_is2_axu_mftgpr                => iu_xu_is2_axu_mftgpr,
        iu_xu_is2_axu_mffgpr                => iu_xu_is2_axu_mffgpr,
        iu_xu_is2_axu_movedp                => iu_xu_is2_axu_movedp,
        iu_xu_is2_axu_instr_type            => iu_xu_is2_axu_instr_type,
        iu_xu_is2_pred_update               => iu_xu_is2_pred_update,
        iu_xu_is2_pred_taken_cnt            => iu_xu_is2_pred_taken_cnt,
        iu_xu_is2_error                     => iu_xu_is2_error,
        iu_xu_is2_match                     => iu_xu_is2_match,
        iu_xu_is2_is_ucode                  => iu_xu_is2_is_ucode,
        iu_xu_is2_ucode_vld                 => iu_xu_is2_ucode_vld,
        iu_xu_is2_gshare                    => iu_xu_is2_gshare,
        xu_div_coll_barr_done               => xu_div_coll_barr_done,
        xu_div_barr_done                    => xu_div_barr_done,
        dec_gpr_rf0_re0                     => dec_gpr_rf0_re0,
        dec_gpr_rf0_re1                     => dec_gpr_rf0_re1,
        dec_gpr_rf0_re2                     => dec_gpr_rf0_re2,
        dec_gpr_rf0_ra0                     => dec_gpr_rf0_ra0,
        dec_gpr_rf0_ra1                     => dec_gpr_rf0_ra1,
        dec_gpr_rf0_ra2                     => dec_gpr_rf0_ra2,
        dec_gpr_rel_ta_gpr                  => dec_gpr_rel_ta_gpr,
        dec_gpr_rel_wren                    => dec_gpr_rel_wren,
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
        fxa_fxb_rf0_axu_mftgpr              => fxa_fxb_rf0_axu_mftgpr,
        fxa_fxb_rf0_axu_mffgpr              => fxa_fxb_rf0_axu_mffgpr,
        fxa_fxb_rf0_axu_movedp              => fxa_fxb_rf0_axu_movedp,
        fxa_fxb_rf0_axu_ldst_size           => fxa_fxb_rf0_axu_ldst_size,
        fxa_fxb_rf0_axu_ldst_update         => fxa_fxb_rf0_axu_ldst_update,
        fxa_fxb_rf0_axu_ldst_forcealign     => fxa_fxb_rf0_axu_ldst_forcealign,
        fxa_fxb_rf0_axu_ldst_forceexcept    => fxa_fxb_rf0_axu_ldst_forceexcept,
        fxa_fxb_rf0_axu_ldst_indexed        => fxa_fxb_rf0_axu_ldst_indexed,
        fxa_fxb_rf0_axu_ldst_tag            => fxa_fxb_rf0_axu_ldst_tag,
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
        fxa_fxb_rf0_spr_tid                 => fxa_fxb_rf0_spr_tid,
        fxa_fxb_rf0_cpl_tid                 => fxa_fxb_rf0_cpl_tid,
        fxa_fxb_rf0_cpl_act                 => fxa_fxb_rf0_cpl_act,
        fxa_fxb_rf0_is_mfocrf               => fxa_fxb_rf0_is_mfocrf,
        fxa_fxb_rf0_3src_instr              => fxa_fxb_rf0_3src_instr,
        fxa_fxb_rf0_gpr0_zero               => fxa_fxb_rf0_gpr0_zero,
        fxa_fxb_rf0_use_imm                 => fxa_fxb_rf0_use_imm,
        dec_cpl_ex3_mc_dep_chk_val          => dec_cpl_ex3_mc_dep_chk_val,
        fxa_perf_muldiv_in_use              => fxa_perf_muldiv_in_use,
        xu_is2_flush                        => xu_is2_flush,
        xu_rf0_flush                        => xu_rf0_flush,
        xu_rf1_flush                        => xu_rf1_flush,
        xu_ex1_flush                        => xu_ex1_flush,
        xu_ex2_flush                        => xu_ex2_flush,
        xu_ex3_flush                        => xu_ex3_flush,
        xu_ex4_flush                        => xu_ex4_flush,
        xu_ex5_flush                        => xu_ex5_flush,
        fxa_cpl_ex2_div_coll                => fxa_cpl_ex2_div_coll,
        cpl_fxa_ex5_set_barr                => cpl_fxa_ex5_set_barr,
        fxa_iu_set_barr_tid                 => fxa_iu_set_barr_tid,
        spr_xucr4_div_barr_thres            => spr_xucr4_div_barr_thres,
        an_ac_back_inv                      => an_ac_back_inv,
        an_ac_back_inv_addr                 => an_ac_back_inv_addr,
        an_ac_back_inv_target_bit3          => an_ac_back_inv_target_bit3,
        dec_spr_rf0_instr                   => dec_spr_rf0_instr,
        xu_lsu_rf0_derat_is_extload         => xu_lsu_rf0_derat_is_extload,
        xu_lsu_rf0_derat_is_extstore        => xu_lsu_rf0_derat_is_extstore,
        xu_lsu_rf0_derat_val                => xu_lsu_rf0_derat_val,
        lsu_xu_rel_wren                     => lsu_xu_rel_wren,
        lsu_xu_rel_ta_gpr                   => lsu_xu_rel_ta_gpr,
        spr_xucr0_clkg_ctl_b0               => spr_xucr0_clkg_ctl_b0,
        dec_debug                           => dec_debug);

    ---------------------------------------------------------------------
    -- GPR
    ---------------------------------------------------------------------
    gpr_rel_data                <= lsu_xu_rot_rel_data & "000000";

    xuq_fxu_gpr : entity work.xuq_fxu_gpr(xuq_fxu_gpr)
    generic map(
        expand_type                     => expand_type,
        regsize                         => regsize,
        threads                         => threads)
    port map(
        vdd                             => vdd,
        gnd                             => gnd,
        nclk                            => nclk,

        d_mode_dc                       => d_mode_dc,
        delay_lclkr_dc                  => delay_lclkr_dc(4),
        clkoff_dc_b                     => clkoff_dc_b,
        mpw1_dc_b                       => mpw1_dc_b(4),
        mpw2_dc_b                       => mpw2_dc_b,
        func_sl_force => func_sl_force,
        func_sl_thold_0_b               => func_sl_thold_0_b,
        func_nsl_force => func_nsl_force,
        func_nsl_thold_0_b              => func_nsl_thold_0_b,
        sg_0                            => sg_0,
        scan_in                         => siv_14(1),
        scan_out                        => sov_14(1),
        an_ac_scan_diag_dc              => an_ac_scan_diag_dc,
 
        r0e_addr_abist                  => pc_xu_abist_raddr_0_q(2 to 9),
        r1e_addr_abist                  => pc_xu_abist_raddr_1_q(2 to 9),
        r0e_en_abist                    => pc_xu_abist_grf_renb_0_q,
        r1e_en_abist                    => pc_xu_abist_grf_renb_1_q,
        r0e_sel_lbist                   => an_ac_lbist_ary_wrt_thru_dc,
        r1e_sel_lbist                   => an_ac_lbist_ary_wrt_thru_dc,
        abist_en                        => pc_xu_abist_ena_dc,
        lbist_en                        => an_ac_lbist_ary_wrt_thru_dc,
        w0e_addr_abist                  => pc_xu_abist_waddr_0_q(2 to 9),
        w0l_addr_abist                  => pc_xu_abist_waddr_1_q(2 to 9),
        w0e_en_abist                    => pc_xu_abist_grf_wenb_0_q,
        w0l_en_abist                    => pc_xu_abist_grf_wenb_1_q,
        w0e_data_abist                  => pc_xu_abist_di_0_q,
        w0l_data_abist                  => pc_xu_abist_di_1_q,
        r0e_abist_comp_en               => pc_xu_abist_wl144_comp_ena_q,
        r1e_abist_comp_en               => pc_xu_abist_wl144_comp_ena_q,
        abist_raw_dc_b                  => pc_xu_abist_raw_dc_b,

        bo_enable_2                     => bo_enable_2,                     -- general bolt-on enable, probably DC
        pc_xu_bo_reset                  => pc_xu_bo_reset,                      -- execute sticky bit decode
        pc_xu_bo_unload                 => pc_xu_bo_unload,
        pc_xu_bo_load                   => pc_xu_bo_load,
        pc_xu_bo_shdata                 => pc_xu_bo_shdata,                     -- shift data for timing write
        pc_xu_bo_select                 => pc_xu_bo_select,                     -- select for mask and hier writes
        xu_pc_bo_fail                   => xu_pc_bo_fail,                       -- fail/no-fix reg
        xu_pc_bo_diagout                => xu_pc_bo_diagout,

        lcb_fce_0                       => fce_0(1),
        lcb_scan_diag_dc                => an_ac_scan_diag_dc,
        lcb_scan_dis_dc_b               => scan_dis_dc_b,
        lcb_sg_0                        => sg_0,
        lcb_abst_sl_thold_0             => abst_sl_thold_0,
        lcb_ary_nsl_thold_0             => ary_nsl_thold_0,
        lcb_time_sl_thold_0             => time_sl_thold_0,        
        lcb_gptr_sl_thold_0             => gptr_sl_thold_0,
        lcb_bolt_sl_thold_0             => bolt_sl_thold_0,

        gpr_abst_scan_in                => abist_siv(0),
        gpr_abst_scan_out               => abist_sov(0),
        gpr_time_scan_in                => time_scan_in,
        gpr_time_scan_out               => time_scan_out,
        gpr_gptr_scan_in                => gptr_scan_in,
        gpr_gptr_scan_out               => gptr_scan_out,

        pc_xu_inj_regfile_parity        => pc_xu_inj_regfile_parity,
        xu_pc_err_regfile_parity        => xu_pc_err_regfile_parity,
        xu_pc_err_regfile_ue            => xu_pc_err_regfile_ue,
        gpr_cpl_ex3_regfile_err_det     => gpr_cpl_ex3_regfile_err_det,
        cpl_gpr_regfile_seq_beg         => cpl_gpr_regfile_seq_beg,    
        gpr_cpl_regfile_seq_end         => gpr_cpl_regfile_seq_end,    

        r0_en                           => dec_gpr_rf0_re0,
        r0_addr_func                    => dec_gpr_rf0_ra0,
        r0_data_out                     => gpr_data_out_0,

        r1_en                           => dec_gpr_rf0_re1,
        r1_addr_func                    => dec_gpr_rf0_ra1,
        r1_data_out                     => gpr_data_out_1,

        r2_en                           => dec_gpr_rf0_re2,
        r2_addr_func                    => dec_gpr_rf0_ra2,
        r2_data_out                     => gpr_data_out_2,

        w_e_act                         => fxb_fxa_ex7_we0,
        w_e_addr_func                   => fxb_fxa_ex7_wa0,
        w_e_data_func                   => fxb_fxa_ex7_wd0,

        w_l_act                         => dec_gpr_rel_wren,
        w_l_addr_func                   => dec_gpr_rel_ta_gpr,
        w_l_data_func                   => gpr_rel_data,
        
        gpr_debug                       => gpr_debug);

    fxa_fxb_rf1_do0             <= gpr_data_out_0(64-regsize to 63);
    fxa_fxb_rf1_do1             <= gpr_data_out_1(64-regsize to 63);
    fxa_fxb_rf1_do2             <= gpr_data_out_2(64-regsize to 63);

siv_14(0 to sov_14'right)       <= sov_14(1 to sov_14'right) & func_scan_rpwr_in(14);
func_scan_rpwr_out(14)          <= sov_14(0);
func_scan_out(14)               <= func_scan_out_gate(14) and an_ac_scan_dis_dc_b;

func_scan_rpwr_i_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc(4),
            thold_b => func_so_thold_0_b,
            scin    => func_scan_in(14 to 14),
            scout   => func_scan_rpwr_in(14 to 14),
            dout    => open);
func_scan_rpwr_o_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc(4),
            thold_b => func_so_thold_0_b,
            scin    => func_scan_rpwr_out(14 to 14),
            scout   => func_scan_out_gate(14 to 14),
            dout    => open);


mark_unused(gpr_data_out_0(64 to 77));
mark_unused(gpr_data_out_1(64 to 77));
mark_unused(gpr_data_out_2(64 to 77));


end architecture xuq_fxu_a;

