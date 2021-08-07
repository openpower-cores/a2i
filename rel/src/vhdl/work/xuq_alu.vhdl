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

LIBRARY ieee;       USE ieee.std_logic_1164.all;
                    USE ieee.numeric_std.all;
LIBRARY ibm;        
                    USE ibm.std_ulogic_support.all;
                    USE ibm.std_ulogic_unsigned.all;
                    USE ibm.std_ulogic_function_support.all;
LIBRARY support;    
                    USE support.power_logic_pkg.all;
LIBRARY tri;        USE tri.tri_latches_pkg.all;
LIBRARY work;       USE work.xuq_pkg.all;

entity xuq_alu is
    generic(
        expand_type                                 : integer := 2;
        regmode                                     : integer := 6;
        a2mode                                      : integer := 1;
        threads                                     : integer := 4;
        dc_size                                     : natural := 14;
        fxu_synth                                   : integer := 0);
    port(
        -- Clocks
        nclk                                        : in clk_logic;

        -- Pervasive
        d_mode_dc                                   : in  std_ulogic;
        delay_lclkr_dc                              : in  std_ulogic;
        mpw1_dc_b                                   : in  std_ulogic;
        mpw2_dc_b                                   : in  std_ulogic;
        func_sl_force : in  std_ulogic;
        func_sl_thold_0_b                           : in  std_ulogic;
        sg_0                                        : in  std_ulogic;
        scan_in                                     : in  std_ulogic_vector(0 to 1);
        scan_out                                    : out std_ulogic_vector(0 to 1);

        -- Power
        vdd                                         : inout power_logic;
        gnd                                         : inout power_logic;

        -- MSR[CM] Need to do 64 bit math
        spr_msr_cm                                  : in  std_ulogic_vector(0 to threads-1);

        -- Decode Inputs
        dec_alu_rf1_act                             : in  std_ulogic;
        dec_alu_ex1_act                             : in  std_ulogic;        
        dec_alu_rf1_sel                             : in  std_ulogic_vector(0 to 3);
        dec_alu_rf1_add_rs0_inv                     : in  std_ulogic_vector(64-(2**regmode) to 63);
        dec_alu_rf1_add_ci                          : in  std_ulogic;
        dec_alu_rf1_is_cmpl                         : in  std_ulogic;
        dec_alu_rf1_tw_cmpsel                       : in  std_ulogic_vector(0 to 5);
        dec_ex2_tid                                 : in  std_ulogic_vector(0 to threads-1);
        dec_ex4_tid                                 : in  std_ulogic_vector(0 to threads-1);
        dec_alu_rf1_mul_recform                     : in  std_ulogic;
        dec_alu_rf1_mul_val                         : in  std_ulogic;
        dec_alu_rf1_mul_ret                         : in  std_ulogic;
        dec_alu_rf1_mul_sign                        : in  std_ulogic;
        dec_alu_rf1_mul_size                        : in  std_ulogic;
        dec_alu_rf1_mul_imm                         : in  std_ulogic;
        fxa_fxb_rf1_div_ctr                         : in  std_ulogic_vector(0 to 7);
        dec_alu_rf1_div_val                         : in  std_ulogic;
        dec_alu_rf1_div_sign                        : in  std_ulogic;
        dec_alu_rf1_div_size                        : in  std_ulogic;
        dec_alu_rf1_div_extd                        : in  std_ulogic;
        dec_alu_rf1_div_recform                     : in  std_ulogic;
        dec_alu_ex1_is_cmp                          : in  std_ulogic;
        dec_alu_rf1_select_64bmode                  : in std_ulogic;
        fxa_fxb_ex1_hold_ctr_flush                  : in  std_ulogic;

        ----- Source Data -----
        -- GPR Sources from Bypass
        byp_alu_ex1_rs0                             : in  std_ulogic_vector(64-(2**regmode) to 63);
        byp_alu_ex1_rs1                             : in  std_ulogic_vector(64-(2**regmode) to 63);
        byp_alu_ex1_mulsrc_0                        : in  std_ulogic_vector(64-(2**regmode) to 63);
        byp_alu_ex1_mulsrc_1                        : in  std_ulogic_vector(64-(2**regmode) to 63);
        byp_alu_ex1_divsrc_0                        : in  std_ulogic_vector(64-(2**regmode) to 63);
        byp_alu_ex1_divsrc_1                        : in  std_ulogic_vector(64-(2**regmode) to 63);

        -- Effective Addresses
        xu_ex1_eff_addr_int                         : out std_ulogic_vector(64-(dc_size-3) to 63);
        xu_ex2_eff_addr                             : out std_ulogic_vector(64-(2**regmode) to 63);

        -- Target Data
        alu_byp_ex5_mul_rt                          : out std_ulogic_vector(64-(2**regmode) to 63);
        alu_byp_ex3_div_rt                          : out std_ulogic_vector(64-(2**regmode) to 63);
        alu_ex2_div_done                            : out std_ulogic;
        alu_dec_ex1_ipb_ba                          : out std_ulogic_vector(27 to 31);
        alu_dec_ex1_ipb_sz                          : out std_ulogic_vector(18 to 19);
        alu_dec_div_need_hole                       : out std_ulogic;
        alu_ex3_mul_done                            : out std_ulogic;
        alu_ex4_mul_done                            : out std_ulogic;
        alu_cpl_ex3_trap_val                        : out std_ulogic;
        alu_byp_ex2_rt                              : out std_ulogic_vector(64-(2**regmode) to 63);
        alu_byp_ex1_log_rt                          : out std_ulogic_vector(64-(2**regmode) to 63);

        -- BYP XER
        dec_alu_rf1_xer_ov_update                   : in  std_ulogic;
        dec_alu_rf1_xer_ca_update                   : in  std_ulogic;
        dec_alu_rf1_sh_right                        : in  std_ulogic;                    
        dec_alu_rf1_sh_word                         : in  std_ulogic;                    
        dec_alu_rf1_sgnxtd_byte                     : in  std_ulogic;                    
        dec_alu_rf1_sgnxtd_half                     : in  std_ulogic;                    
        dec_alu_rf1_sgnxtd_wd                       : in  std_ulogic;                    
        dec_alu_rf1_sra_dw                          : in  std_ulogic;                    
        dec_alu_rf1_sra_wd                          : in  std_ulogic;                    
        dec_alu_rf1_chk_shov_dw                     : in  std_ulogic;                    
        dec_alu_rf1_chk_shov_wd                     : in  std_ulogic;                    
        dec_alu_rf1_use_me_ins_hi                   : in  std_ulogic;                    
        dec_alu_rf1_use_me_ins_lo                   : in  std_ulogic;                    
        dec_alu_rf1_use_mb_ins_hi                   : in  std_ulogic;                    
        dec_alu_rf1_use_mb_ins_lo                   : in  std_ulogic;                    
        dec_alu_rf1_use_me_rb_hi                    : in  std_ulogic;                    
        dec_alu_rf1_use_me_rb_lo                    : in  std_ulogic;                    
        dec_alu_rf1_use_mb_rb_hi                    : in  std_ulogic;                    
        dec_alu_rf1_use_mb_rb_lo                    : in  std_ulogic;                    
        dec_alu_rf1_use_rb_amt_hi                   : in  std_ulogic;                    
        dec_alu_rf1_use_rb_amt_lo                   : in  std_ulogic;                    
        dec_alu_rf1_zm_ins                          : in  std_ulogic;                    
        byp_alu_rf1_isel_fcn                        : in  std_ulogic_vector(0 to 3);
        dec_alu_rf1_log_fcn                         : in  std_ulogic_vector(0 to 3);     
        dec_alu_rf1_me_ins_b                        : in  std_ulogic_vector(0 to 5);     
        dec_alu_rf1_mb_ins                          : in  std_ulogic_vector(0 to 5);     
        dec_alu_rf1_sh_amt                          : in  std_ulogic_vector(0 to 5);     
        dec_alu_rf1_mb_gt_me                        : in  std_ulogic;                    
        alu_byp_ex2_xer                             : out std_ulogic_vector(0 to 3);
        alu_byp_ex5_xer_mul                         : out std_ulogic_vector(0 to 3);
        alu_byp_ex3_xer_div                         : out std_ulogic_vector(0 to 3);

        -- CR Result to bypass
        alu_byp_ex2_cr_recform                      : out std_ulogic_vector(0 to 3);
        alu_byp_ex5_cr_mul                          : out std_ulogic_vector(0 to 4);
        alu_byp_ex3_cr_div                          : out std_ulogic_vector(0 to 4)
    );
    -- synopsys translate_off
    -- synopsys translate_on
end xuq_alu;

architecture xuq_alu of xuq_alu is
    constant tiup                                   : std_ulogic := '1';
    constant tidn                                   : std_ulogic := '0';
    constant regsize                                : integer := 2**regmode;

    signal add_log_ex1_add_rt                       : std_ulogic_vector(64-regsize to 63);
    signal rf1_is_add_op                            : std_ulogic;
    signal rf1_is_rot_op                            : std_ulogic;
    signal rf1_is_cmpb_op                           : std_ulogic;
    signal ex2_add_xer_ov                           : std_ulogic;
    signal ex2_add_xer_ca                           : std_ulogic;
    signal ex2_rot_xer_ca                           : std_ulogic;
    signal ex3_div_xer_ov                           : std_ulogic;
    signal ex3_div_xer_ov_update                    : std_ulogic;
    signal ex2_spr_msr_cm                           : std_ulogic;
    signal ex4_spr_msr_cm                           : std_ulogic;
    signal ex2_cr_recform                           : std_ulogic_vector(0 to 3);
    signal log_add_ex2_rt                           : std_ulogic_vector(64-(2**regmode) to 63);
    signal ex2_xer_ca                               : std_ulogic;
    signal rf1_sel_rot_log                          : std_ulogic;
    signal byp_alu_ex1_rs0_b, byp_alu_ex1_rs1_b     : std_ulogic_vector(64-(2**regmode) to 63);

    ---------------------------------------------------------------------
    -- Latch Signals
    ---------------------------------------------------------------------
    signal ex1_xer_ov_update_q                      : std_ulogic;           -- Valids for XER[OV], XER[CA]
    signal ex2_xer_ov_update_q, ex2_xer_ov_update_d : std_ulogic;
    signal ex1_xer_ca_update_q                      : std_ulogic;
    signal ex2_xer_ca_update_q, ex2_xer_ca_update_d : std_ulogic;
    signal ex1_is_add_op_q                          : std_ulogic;           -- Unit valids
    signal ex1_is_rot_op_q                          : std_ulogic;
    signal ex2_is_rot_op_q                          : std_ulogic;
    signal spr_msr_cm_q                             : std_ulogic_vector(0 to threads-1);

    ---------------------------------------------------------------------
    -- Scanchain
    ---------------------------------------------------------------------
    constant ex1_xer_ov_update_offset               : integer := 3;
    constant ex2_xer_ov_update_offset               : integer := ex1_xer_ov_update_offset       + 1;
    constant ex1_xer_ca_update_offset               : integer := ex2_xer_ov_update_offset       + 1;
    constant ex2_xer_ca_update_offset               : integer := ex1_xer_ca_update_offset       + 1;
    constant ex1_is_add_op_offset                   : integer := ex2_xer_ca_update_offset       + 1;
    constant ex1_is_rot_op_offset                   : integer := ex1_is_add_op_offset           + 1;
    constant ex2_is_rot_op_offset                   : integer := ex1_is_rot_op_offset           + 1;
    constant spr_msr_cm_offset                      : integer := ex2_is_rot_op_offset           + 1;
    constant scan_right                             : integer := spr_msr_cm_offset              + spr_msr_cm_q'length;
    signal siv                                      : std_ulogic_vector(0 to scan_right-1);
    signal sov                                      : std_ulogic_vector(0 to scan_right-1);




begin

    ---------------------------------------------------------------------
    -- Source Buffering
    ---------------------------------------------------------------------
    u_s0i:     byp_alu_ex1_rs0_b      <= not byp_alu_ex1_rs0;
    u_s1i:     byp_alu_ex1_rs1_b      <= not byp_alu_ex1_rs1;

    ---------------------------------------------------------------------
    --
    ---------------------------------------------------------------------
    ex2_spr_msr_cm          <= or_reduce(spr_msr_cm_q and dec_ex2_tid);
    ex4_spr_msr_cm          <= or_reduce(spr_msr_cm_q and dec_ex4_tid);

    rf1_sel_rot_log         <= not dec_alu_rf1_sel(0);  

    rf1_is_add_op           <= dec_alu_rf1_sel(0);
    rf1_is_rot_op           <= dec_alu_rf1_sel(1);
    rf1_is_cmpb_op          <= dec_alu_rf1_sel(3);

    alu_dec_ex1_ipb_ba      <= byp_alu_ex1_rs0(59 to 63);
    alu_dec_ex1_ipb_sz      <= byp_alu_ex1_rs0(50 to 51);

    ---------------------------------------------------------------------
    -- XER Update
    ---------------------------------------------------------------------

    ex2_xer_ca_update_d    <= ex1_xer_ca_update_q and (ex1_is_add_op_q or ex1_is_rot_op_q);
    ex2_xer_ov_update_d    <= ex1_xer_ov_update_q and  ex1_is_add_op_q;

    with ex2_is_rot_op_q select
      ex2_xer_ca           <= ex2_rot_xer_ca    when '1',
                              ex2_add_xer_ca    when others;
                              
    alu_byp_ex2_xer         <= ex2_add_xer_ov  & ex2_xer_ca     & ex2_xer_ov_update_q   & ex2_xer_ca_update_q;
    alu_byp_ex3_xer_div     <= ex3_div_xer_ov  & tidn           & ex3_div_xer_ov_update & tidn;

    alu_byp_ex2_cr_recform  <= ex2_cr_recform(0 to 2) & (ex2_cr_recform(3) and ex2_xer_ov_update_q);

    ---------------------------------------------------------------------
    -- Add
    ---------------------------------------------------------------------
    xu_alu_add : entity work.xuq_alu_add(xuq_alu_add)
    generic map(
        expand_type                     => expand_type,
        dc_size                         => dc_size,
        regsize                         => regsize,
        fxu_synth                       => fxu_synth)
    port map(
        nclk                            => nclk,
        vdd                             => vdd,
        gnd                             => gnd,
        dec_alu_rf1_add_act             => dec_alu_rf1_act,
        d_mode_dc                       => d_mode_dc,
        delay_lclkr_dc                  => delay_lclkr_dc,
        mpw1_dc_b                       => mpw1_dc_b,
        mpw2_dc_b                       => mpw2_dc_b,
        func_sl_force => func_sl_force,
        func_sl_thold_0_b               => func_sl_thold_0_b,
        sg_0                            => sg_0,
        scan_in                         => siv(0),
        scan_out                        => sov(0),
        dec_alu_rf1_select_64bmode      => dec_alu_rf1_select_64bmode,
        dec_alu_rf1_add_rs0_inv         => dec_alu_rf1_add_rs0_inv,
        dec_alu_rf1_add_ci              => dec_alu_rf1_add_ci,
        dec_alu_rf1_is_cmpl             => dec_alu_rf1_is_cmpl,
        dec_alu_rf1_tw_cmpsel           => dec_alu_rf1_tw_cmpsel,
        dec_alu_ex1_is_cmp              => dec_alu_ex1_is_cmp,
        byp_alu_ex1_rs0                 => byp_alu_ex1_rs0,
        byp_alu_ex1_rs1                 => byp_alu_ex1_rs1,
        log_add_ex2_rt                  => log_add_ex2_rt,
        alu_byp_ex2_rt                  => alu_byp_ex2_rt,
        add_log_ex1_add_rt              => add_log_ex1_add_rt,
        xu_ex1_eff_addr_int             => xu_ex1_eff_addr_int,
        xu_ex2_eff_addr                 => xu_ex2_eff_addr,
        ex2_cr_recform                  => ex2_cr_recform,
        ex3_trap_val                    => alu_cpl_ex3_trap_val,
        ex2_add_xer_ov                  => ex2_add_xer_ov,
        ex2_add_xer_ca                  => ex2_add_xer_ca);

    ---------------------------------------------------------------------
    -- Multiply
    ---------------------------------------------------------------------
    xu_alu_mult : entity work.xuq_alu_mult(xuq_alu_mult)
    generic map(
        expand_type                     => expand_type,
        regmode                         => regmode,
        a2mode                          => a2mode,
        threads                         => threads,
        fxu_synth                       => fxu_synth)
    port map(
        nclk                            => nclk,
        vdd                             => vdd,
        gnd                             => gnd,
        d_mode_dc                       => d_mode_dc,
        delay_lclkr_dc                  => delay_lclkr_dc,
        mpw1_dc_b                       => mpw1_dc_b,
        mpw2_dc_b                       => mpw2_dc_b,
        func_sl_force => func_sl_force,
        func_sl_thold_0_b               => func_sl_thold_0_b,
        sg_0                            => sg_0,
        scan_in                         => siv(1),
        scan_out                        => sov(1),
        dec_alu_rf1_mul_recform         => dec_alu_rf1_mul_recform,
        dec_alu_rf1_mul_val             => dec_alu_rf1_mul_val,
        dec_alu_rf1_mul_ret             => dec_alu_rf1_mul_ret,
        dec_alu_rf1_mul_sign            => dec_alu_rf1_mul_sign,
        dec_alu_rf1_mul_size            => dec_alu_rf1_mul_size,
        dec_alu_rf1_mul_imm             => dec_alu_rf1_mul_imm,
        dec_alu_rf1_xer_ov_update       => dec_alu_rf1_xer_ov_update,
        fxa_fxb_ex1_hold_ctr_flush      => fxa_fxb_ex1_hold_ctr_flush,
        ex4_spr_msr_cm                  => ex4_spr_msr_cm,
        byp_alu_ex1_mulsrc_0            => byp_alu_ex1_mulsrc_0,
        byp_alu_ex1_mulsrc_1            => byp_alu_ex1_mulsrc_1,
        alu_ex3_mul_done                => alu_ex3_mul_done,
        alu_ex4_mul_done                => alu_ex4_mul_done,
        alu_byp_ex5_mul_rt              => alu_byp_ex5_mul_rt,
        alu_byp_ex5_xer_mul             => alu_byp_ex5_xer_mul,
        alu_byp_ex5_cr_mul              => alu_byp_ex5_cr_mul);

    ---------------------------------------------------------------------
    -- Divide
    ---------------------------------------------------------------------
    xuq_alu_div : entity work.xuq_alu_div(xuq_alu_div)
    generic map(
        expand_type                     => expand_type,
        regsize                         => regsize)
    port map(
        nclk                            => nclk,
        vdd                             => vdd,
        gnd                             => gnd,
        d_mode_dc                       => d_mode_dc,
        delay_lclkr_dc                  => delay_lclkr_dc,
        mpw1_dc_b                       => mpw1_dc_b,
        mpw2_dc_b                       => mpw2_dc_b,
        func_sl_force => func_sl_force,
        func_sl_thold_0_b               => func_sl_thold_0_b,
        sg_0                            => sg_0,
        scan_in                         => scan_in(0),
        scan_out                        => scan_out(0),
        fxa_fxb_rf1_div_ctr             => fxa_fxb_rf1_div_ctr,
        dec_alu_rf1_div_val             => dec_alu_rf1_div_val,
        dec_alu_rf1_div_sign            => dec_alu_rf1_div_sign,
        dec_alu_rf1_div_size            => dec_alu_rf1_div_size,
        dec_alu_rf1_div_extd            => dec_alu_rf1_div_extd,
        dec_alu_rf1_div_recform         => dec_alu_rf1_div_recform,
        byp_alu_ex1_divsrc_0            => byp_alu_ex1_divsrc_0,
        byp_alu_ex1_divsrc_1            => byp_alu_ex1_divsrc_1,
        fxa_fxb_ex1_hold_ctr_flush      => fxa_fxb_ex1_hold_ctr_flush,
        dec_alu_rf1_xer_ov_update       => dec_alu_rf1_xer_ov_update,
        alu_dec_div_need_hole           => alu_dec_div_need_hole,
        alu_byp_ex3_div_rt              => alu_byp_ex3_div_rt,
        alu_ex2_div_done                => alu_ex2_div_done,
        ex3_div_xer_ov                  => ex3_div_xer_ov,
        ex3_div_xer_ov_update           => ex3_div_xer_ov_update,
        alu_byp_ex3_cr_div              => alu_byp_ex3_cr_div,
        ex2_spr_msr_cm                  => ex2_spr_msr_cm);

    ---------------------------------------------------------------------
    -- MRG
    ---------------------------------------------------------------------
    xuq_alu_mrg : entity work.xuq_alu_mrg(xuq_alu_mrg)
    generic map(
        expand_type                     => expand_type)
    port map(
        nclk                            => nclk,
        vdd                             => vdd,
        gnd                             => gnd,
        d_mode_dc                       => d_mode_dc,
        delay_lclkr_dc                  => delay_lclkr_dc,
        mpw1_dc_b                       => mpw1_dc_b,
        mpw2_dc_b                       => mpw2_dc_b,
        func_sl_force => func_sl_force,
        func_sl_thold_0_b               => func_sl_thold_0_b,
        sg_0                            => sg_0,
        scan_in                         => siv(2),
        scan_out                        => sov(2),
        rf1_act                         => dec_alu_rf1_act,
        ex1_act                         => dec_alu_ex1_act,
        dec_alu_rf1_zm_ins               => dec_alu_rf1_zm_ins,
        dec_alu_rf1_mb_ins               => dec_alu_rf1_mb_ins,
        dec_alu_rf1_me_ins_b             => dec_alu_rf1_me_ins_b,
        dec_alu_rf1_sh_amt               => dec_alu_rf1_sh_amt,
        dec_alu_rf1_sh_right             => dec_alu_rf1_sh_right,
        dec_alu_rf1_sh_word              => dec_alu_rf1_sh_word,
        dec_alu_rf1_use_rb_amt_hi        => dec_alu_rf1_use_rb_amt_hi,
        dec_alu_rf1_use_rb_amt_lo        => dec_alu_rf1_use_rb_amt_lo,
        dec_alu_rf1_use_me_rb_hi         => dec_alu_rf1_use_me_rb_hi,
        dec_alu_rf1_use_me_rb_lo         => dec_alu_rf1_use_me_rb_lo,
        dec_alu_rf1_use_mb_rb_hi         => dec_alu_rf1_use_mb_rb_hi,
        dec_alu_rf1_use_mb_rb_lo         => dec_alu_rf1_use_mb_rb_lo,
        dec_alu_rf1_use_me_ins_hi        => dec_alu_rf1_use_me_ins_hi,
        dec_alu_rf1_use_me_ins_lo        => dec_alu_rf1_use_me_ins_lo,
        dec_alu_rf1_use_mb_ins_hi        => dec_alu_rf1_use_mb_ins_hi,
        dec_alu_rf1_use_mb_ins_lo        => dec_alu_rf1_use_mb_ins_lo,
        dec_alu_rf1_chk_shov_wd          => dec_alu_rf1_chk_shov_wd,
        dec_alu_rf1_chk_shov_dw          => dec_alu_rf1_chk_shov_dw,
        dec_alu_rf1_mb_gt_me             => dec_alu_rf1_mb_gt_me,
        dec_alu_rf1_cmp_byt              => rf1_is_cmpb_op,
        dec_alu_rf1_sgnxtd_byte          => dec_alu_rf1_sgnxtd_byte,
        dec_alu_rf1_sgnxtd_half          => dec_alu_rf1_sgnxtd_half,
        dec_alu_rf1_sgnxtd_wd            => dec_alu_rf1_sgnxtd_wd,
        dec_alu_rf1_sra_wd               => dec_alu_rf1_sra_wd,
        dec_alu_rf1_sra_dw               => dec_alu_rf1_sra_dw,
        byp_alu_rf1_isel_fcn             => byp_alu_rf1_isel_fcn,
        dec_alu_rf1_log_fcn              => dec_alu_rf1_log_fcn,
        dec_alu_rf1_sel_rot_log          => rf1_sel_rot_log,
        byp_alu_ex1_rs0_b                => byp_alu_ex1_rs0_b,
        byp_alu_ex1_rs1_b                => byp_alu_ex1_rs1_b,
        add_mrg_ex1_add_rt               => add_log_ex1_add_rt,
        alu_byp_ex1_log_rt               => alu_byp_ex1_log_rt,
        mrg_add_ex2_rt                   => log_add_ex2_rt,
        ex2_mrg_xer_ca                   => ex2_rot_xer_ca);
        
        
                mark_unused(dec_alu_rf1_sel(2));
    ---------------------------------------------------------------------
    -- Latches
    ---------------------------------------------------------------------
    ex1_xer_ov_update_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => tiup,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_xer_ov_update_offset),
                  scout         => sov(ex1_xer_ov_update_offset),
                  din           => dec_alu_rf1_xer_ov_update,
                  dout          => ex1_xer_ov_update_q);
    ex2_xer_ov_update_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => tiup,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex2_xer_ov_update_offset),
                  scout         => sov(ex2_xer_ov_update_offset),
                  din           => ex2_xer_ov_update_d,
                  dout          => ex2_xer_ov_update_q);
    ex1_xer_ca_update_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => tiup,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_xer_ca_update_offset),
                  scout         => sov(ex1_xer_ca_update_offset),
                  din           => dec_alu_rf1_xer_ca_update,
                  dout          => ex1_xer_ca_update_q);
    ex2_xer_ca_update_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => tiup,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex2_xer_ca_update_offset),
                  scout         => sov(ex2_xer_ca_update_offset),
                  din           => ex2_xer_ca_update_d,
                  dout          => ex2_xer_ca_update_q);
    ex1_is_add_op_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => tiup,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_is_add_op_offset),
                  scout         => sov(ex1_is_add_op_offset),
                  din           => rf1_is_add_op,
                  dout          => ex1_is_add_op_q);
    ex1_is_rot_op_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => tiup,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_is_rot_op_offset),
                  scout         => sov(ex1_is_rot_op_offset),
                  din           => rf1_is_rot_op,
                  dout          => ex1_is_rot_op_q);
    ex2_is_rot_op_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => tiup,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex2_is_rot_op_offset),
                  scout         => sov(ex2_is_rot_op_offset),
                  din           => ex1_is_rot_op_q,
                  dout          => ex2_is_rot_op_q);
    spr_msr_cm_latch : tri_rlmreg_p
        generic map (width => spr_msr_cm_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => tiup,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(spr_msr_cm_offset to spr_msr_cm_offset + spr_msr_cm_q'length-1),
                  scout         => sov(spr_msr_cm_offset to spr_msr_cm_offset + spr_msr_cm_q'length-1),
                  din           => spr_msr_cm,
                  dout          => spr_msr_cm_q);
    siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in(1);
    scan_out(1) <= sov(0);

end architecture xuq_alu;
