-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


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

entity xuq_alu_mult is
    generic (
        expand_type                     : integer := 2;
        regmode                         : integer := 6;
        a2mode                          : integer := 1;
        threads                         : integer := 4;
        fxu_synth                       : integer := 0);
    port (
        nclk                            : in clk_logic;
        vdd                             : inout power_logic;
        gnd                             : inout power_logic;

        d_mode_dc                       : in std_ulogic;
        delay_lclkr_dc                  : in std_ulogic;
        mpw1_dc_b                       : in std_ulogic;
        mpw2_dc_b                       : in std_ulogic;
        func_sl_force : in std_ulogic;
        func_sl_thold_0_b               : in std_ulogic;
        sg_0                            : in std_ulogic;
        scan_in                         : in std_ulogic;
        scan_out                        : out std_ulogic;

        dec_alu_rf1_mul_recform         : in std_ulogic;
        dec_alu_rf1_mul_val             : in std_ulogic;
        dec_alu_rf1_mul_ret             : in std_ulogic;                   
        dec_alu_rf1_mul_sign            : in std_ulogic;                   
        dec_alu_rf1_mul_size            : in std_ulogic;                   
        dec_alu_rf1_mul_imm             : in std_ulogic;                   
        dec_alu_rf1_xer_ov_update       : in std_ulogic;
        fxa_fxb_ex1_hold_ctr_flush      : in std_ulogic;

        ex4_spr_msr_cm                  : in std_ulogic;

        byp_alu_ex1_mulsrc_0            : in std_ulogic_vector(0 to 2**regmode-1);
        byp_alu_ex1_mulsrc_1            : in std_ulogic_vector(0 to 2**regmode-1);
        alu_byp_ex5_xer_mul             : out std_ulogic_vector(0 to 3);
        alu_byp_ex5_cr_mul              : out std_ulogic_vector(0 to 4);

        alu_byp_ex5_mul_rt              : out std_ulogic_vector(0 to 2**regmode-1);

        alu_ex3_mul_done                : out std_ulogic;
        alu_ex4_mul_done                : out std_ulogic
    );
    --  synopsys translate_off
    --  synopsys translate_on
end xuq_alu_mult;

architecture xuq_alu_mult of xuq_alu_mult is
    constant tiup                                                   : std_ulogic := '1';
    constant tidn                                                   : std_ulogic := '0';
    subtype s2                                                      is std_ulogic_vector(0 to 1);
    subtype s4                                                      is std_ulogic_vector(0 to 3);
    subtype s5                                                      is std_ulogic_vector(0 to 4);
    subtype s6                                                      is std_ulogic_vector(0 to 5);

    signal ex1_mulstage,  ex1_mulstage_shift                        : std_ulogic_vector(0 to 3);
    signal ex1_mul_val                                              : std_ulogic;
    signal ex2_ready_stage                                          : std_ulogic_vector(0 to 3);
    signal ex5_cmp0_eq                                              : std_ulogic;
    signal ex5_cmp0_gt                                              : std_ulogic;
    signal ex5_cmp0_lt                                              : std_ulogic;
    signal ex5_mul_cr_valid                                         : std_ulogic;
    signal ex5_xer_ov                                               : std_ulogic;
    signal ex3_recycle_s                                            : std_ulogic_vector(196 to 264);
    signal ex3_recycle_c                                            : std_ulogic_vector(196 to 264);
    signal ex4_pp5_0s                                               : std_ulogic_vector(196 to 264);
    signal ex4_pp5_0c                                               : std_ulogic_vector(196 to 264);
    signal ex3_recyc_sh00                                           : std_ulogic;
    signal ex3_recyc_sh32                                           : std_ulogic;
    signal ex3_xtd                                                  : std_ulogic;
    signal ex3_xtd_196_or                                           : std_ulogic;
    signal ex3_xtd_196_and                                          : std_ulogic;
    signal ex3_xtd_197_or                                           : std_ulogic;
    signal ex3_xtd_197_and                                          : std_ulogic;
    signal ex3_xtd_ge1                                              : std_ulogic;
    signal ex3_xtd_ge2                                              : std_ulogic;
    signal ex3_xtd_ge3                                              : std_ulogic;
    signal ex1_bs_sign                                              : std_ulogic;
    signal ex1_bd_sign                                              : std_ulogic;
    signal ex4_xi                                                   : std_ulogic_vector(0 to 63);
    signal ex4_yi                                                   : std_ulogic_vector(0 to 63);
    signal ex4_p                                                    : std_ulogic_vector(0 to 63);
    signal ex4_g                                                    : std_ulogic_vector(1 to 63);
    signal ex4_t                                                    : std_ulogic_vector(1 to 63);
    signal ex4_res                                                  : std_ulogic_vector(0 to 63);
    signal rslt_lo_act                                              : std_ulogic;
    signal ex4_ret_mulhw                                            : std_ulogic;
    signal ex4_ret_mullw                                            : std_ulogic;
    signal ex4_ret_mulli                                            : std_ulogic;
    signal ex4_ret_mulld                                            : std_ulogic;
    signal ex4_ret_mulldo                                           : std_ulogic;
    signal ex4_ret_mulhd                                            : std_ulogic;

    signal ex5_result                                               : std_ulogic_vector(0 to 63);
    signal ex4_all0_test                                            : std_ulogic_vector(0 to 63);
    signal ex4_all0_test_mid                                        : std_ulogic;
    signal ex4_all1_test                                            : std_ulogic_vector(0 to 63);
    signal ex4_all1_test_mid                                        : std_ulogic;
    signal ex4_all0                                                 : std_ulogic;
    signal ex4_all1                                                 : std_ulogic;
    signal ex4_all0_lo                                              : std_ulogic;
    signal ex4_all0_hi                                              : std_ulogic;
    signal ex4_all1_hi                                              : std_ulogic;
    signal ex5_sign_rt_cmp0                                         : std_ulogic;
    signal ex5_eq                                                   : std_ulogic;
    signal ex4_cout_32                                              : std_ulogic;
    signal ex4_xi_b                                                 : std_ulogic_vector(0 to 63);
    signal ex4_yi_b                                                 : std_ulogic_vector(0 to 63);
    signal ex1_mulsrc0_act, ex1_mulsrc1_act                         : std_ulogic;
    signal ex2_bs_lo, ex2_bd_lo                                     : std_ulogic_vector(32 to 63);
    signal ex2_act, ex3_act, ex4_act                                : std_ulogic;

    signal ex1_mul_val_q                                            : std_ulogic;                                           
    signal ex2_mulstage_q                                           : std_ulogic_vector(0 to 3);                            
    signal ex3_mulstage_q                                           : std_ulogic_vector(0 to 3);
    signal ex4_mulstage_q                                           : std_ulogic_vector(0 to 3);
    signal ex5_mulstage_q                                           : std_ulogic_vector(0 to 3);
    signal ex1_is_recform_q                                         : std_ulogic;                                           
    signal ex2_is_recform_q                                         : std_ulogic;
    signal ex3_is_recform_q                                         : std_ulogic;
    signal ex4_is_recform_q                                         : std_ulogic;
    signal ex5_is_recform_q                                         : std_ulogic;
    signal ex1_retsel_q,             ex1_retsel_d                   : std_ulogic_vector(0 to 2);                            
    signal ex2_retsel_q                                             : std_ulogic_vector(0 to 2);
    signal ex3_retsel_q                                             : std_ulogic_vector(0 to 2);
    signal ex4_retsel_q                                             : std_ulogic_vector(0 to 2);
    signal ex1_mul_size_q                                           : std_ulogic;
    signal ex1_mul_sign_q                                           : std_ulogic;
    signal ex3_mul_done_q,           ex3_mul_done_d                 : std_ulogic;                                           
    signal ex4_mul_done_q                                           : std_ulogic;
    signal ex5_mul_done_q                                           : std_ulogic;
    signal ex1_xer_ov_update_q                                      : std_ulogic;                                           
    signal ex2_xer_ov_update_q                                      : std_ulogic;
    signal ex3_xer_ov_update_q                                      : std_ulogic;
    signal ex4_xer_ov_update_q                                      : std_ulogic;
    signal ex5_xer_ov_update_q                                      : std_ulogic;
    signal ex2_bs_lo_sign_q,            ex2_bs_lo_sign_d            : std_ulogic;                                           
    signal ex2_bd_lo_sign_q,            ex2_bd_lo_sign_d            : std_ulogic;
    signal ex4_ci_q,                    ex4_ci_d                    : std_ulogic;
    signal ex5_res_q                                                : std_ulogic_vector(0 to 63);
    signal ex5_all0_q                                               : std_ulogic;                                           
    signal ex5_all1_q                                               : std_ulogic;
    signal ex5_all0_lo_q                                            : std_ulogic;
    signal ex5_all0_hi_q                                            : std_ulogic;
    signal ex5_all1_hi_q                                            : std_ulogic;
    signal carry_32_dly1_q                                          : std_ulogic;                                           
    signal all0_lo_dly1_q                                           : std_ulogic;                                           
    signal all0_lo_dly2_q                                           : std_ulogic;
    signal all0_lo_dly3_q                                           : std_ulogic;
    signal rslt_lo_q,                   rslt_lo_d                   : std_ulogic_vector(0 to 31);                           
    signal rslt_lo_dly_q,               rslt_lo_dly_d               : std_ulogic_vector(0 to 31);                           
    signal ex2_mulsrc_0_q,              ex1_mulsrc_0                : std_ulogic_vector(0 to 63);     
    signal ex2_mulsrc_1_q,              ex1_mulsrc_1                : std_ulogic_vector(0 to 63);     
    signal ex5_rslt_hw_q,               ex5_rslt_hw_d               : std_ulogic_vector(0 to 7);
    signal ex5_rslt_ld_li_q,            ex5_rslt_ld_li_d            : std_ulogic_vector(0 to 7);
    signal ex5_rslt_ldo_q,              ex5_rslt_ldo_d              : std_ulogic_vector(0 to 7);
    signal ex5_rslt_lw_hd_q,            ex5_rslt_lw_hd_d            : std_ulogic_vector(0 to 7);
    signal ex5_cmp0_sel_reshi_q,        ex5_cmp0_sel_reshi_d        : std_ulogic;
    signal ex5_cmp0_sel_reslo_q,        ex5_cmp0_sel_reslo_d        : std_ulogic;
    signal ex5_cmp0_sel_reslodly_q,     ex5_cmp0_sel_reslodly_d     : std_ulogic;
    signal ex5_cmp0_sel_reslodly2_q,    ex5_cmp0_sel_reslodly2_d    : std_ulogic;
    signal ex5_eq_sel_all0_b_q,         ex5_eq_sel_all0_b_d         : std_ulogic;
    signal ex5_eq_sel_all0_hi_b_q,      ex5_eq_sel_all0_hi_b_d      : std_ulogic;
    signal ex5_eq_sel_all0_lo_b_q,      ex5_eq_sel_all0_lo_b_d      : std_ulogic;
    signal ex5_eq_sel_all0_lo1_b_q,     ex5_eq_sel_all0_lo1_b_d     : std_ulogic;
    signal ex5_eq_sel_all0_lo2_b_q,     ex5_eq_sel_all0_lo2_b_d     : std_ulogic;
    signal ex5_eq_sel_all0_lo3_b_q,     ex5_eq_sel_all0_lo3_b_d     : std_ulogic;
    signal ex5_ret_mullw_q                                          : std_ulogic;
    signal ex5_ret_mulldo_q                                         : std_ulogic;
    signal ex5_cmp0_undef_q,            ex5_cmp0_undef_d            : std_ulogic;
    constant ex1_mul_val_offset                                     : integer := 1;
    constant ex2_mulstage_offset                                    : integer := ex1_mul_val_offset             + 1;
    constant ex3_mulstage_offset                                    : integer := ex2_mulstage_offset            + ex2_mulstage_q'length;
    constant ex4_mulstage_offset                                    : integer := ex3_mulstage_offset            + ex3_mulstage_q'length;
    constant ex5_mulstage_offset                                    : integer := ex4_mulstage_offset            + ex4_mulstage_q'length;
    constant ex1_retsel_offset                                      : integer := ex5_mulstage_offset            + ex5_mulstage_q'length;
    constant ex2_retsel_offset                                      : integer := ex1_retsel_offset              + ex1_retsel_q'length;
    constant ex3_retsel_offset                                      : integer := ex2_retsel_offset              + ex2_retsel_q'length;
    constant ex4_retsel_offset                                      : integer := ex3_retsel_offset              + ex3_retsel_q'length;
    constant ex3_mul_done_offset                                    : integer := ex4_retsel_offset              + ex4_retsel_q'length;
    constant ex4_mul_done_offset                                    : integer := ex3_mul_done_offset            + 1;
    constant ex5_mul_done_offset                                    : integer := ex4_mul_done_offset            + 1;
    constant ex1_is_recform_offset                                  : integer := ex5_mul_done_offset            + 1;
    constant ex2_is_recform_offset                                  : integer := ex1_is_recform_offset          + 1;
    constant ex3_is_recform_offset                                  : integer := ex2_is_recform_offset          + 1;
    constant ex4_is_recform_offset                                  : integer := ex3_is_recform_offset          + 1;
    constant ex5_is_recform_offset                                  : integer := ex4_is_recform_offset          + 1;
    constant ex1_xer_ov_update_offset                               : integer := ex5_is_recform_offset          + 1;
    constant ex2_xer_ov_update_offset                               : integer := ex1_xer_ov_update_offset       + 1;
    constant ex3_xer_ov_update_offset                               : integer := ex2_xer_ov_update_offset       + 1;
    constant ex4_xer_ov_update_offset                               : integer := ex3_xer_ov_update_offset       + 1;
    constant ex5_xer_ov_update_offset                               : integer := ex4_xer_ov_update_offset       + 1;
    constant ex1_mul_size_offset                                    : integer := ex5_xer_ov_update_offset       + 1;
    constant ex1_mul_sign_offset                                    : integer := ex1_mul_size_offset            + 1;
    constant ex2_bs_lo_sign_offset                                  : integer := ex1_mul_sign_offset            + 1;
    constant ex2_bd_lo_sign_offset                                  : integer := ex2_bs_lo_sign_offset          + 1;
    constant ex5_all0_offset                                        : integer := ex2_bd_lo_sign_offset          + 1;
    constant ex5_all1_offset                                        : integer := ex5_all0_offset                + 1;
    constant ex5_all0_lo_offset                                     : integer := ex5_all1_offset                + 1;
    constant ex5_all0_hi_offset                                     : integer := ex5_all0_lo_offset             + 1;
    constant ex5_all1_hi_offset                                     : integer := ex5_all0_hi_offset             + 1;
    constant ex4_ci_offset                                          : integer := ex5_all1_hi_offset             + 1;
    constant ex5_res_offset                                         : integer := ex4_ci_offset                  + 1;
    constant carry_32_dly1_offset                                   : integer := ex5_res_offset                 + ex5_res_q'length;
    constant all0_lo_dly1_offset                                    : integer := carry_32_dly1_offset           + 1;
    constant all0_lo_dly2_offset                                    : integer := all0_lo_dly1_offset            + 1;
    constant all0_lo_dly3_offset                                    : integer := all0_lo_dly2_offset            + 1;
    constant rslt_lo_offset                                         : integer := all0_lo_dly3_offset            + 1;
    constant rslt_lo_dly_offset                                     : integer := rslt_lo_offset                 + rslt_lo_q'length;
    constant ex2_mulsrc_0_offset                                    : integer := rslt_lo_dly_offset             + rslt_lo_dly_q'length;
    constant ex2_mulsrc_1_offset                                    : integer := ex2_mulsrc_0_offset            + ex2_mulsrc_0_q'length;
    constant ex5_rslt_hw_offset                                     : integer := ex2_mulsrc_1_offset            + ex2_mulsrc_1_q'length;
    constant ex5_rslt_ld_li_offset                                  : integer := ex5_rslt_hw_offset             + ex5_rslt_hw_q'length;
    constant ex5_rslt_ldo_offset                                    : integer := ex5_rslt_ld_li_offset          + ex5_rslt_ld_li_q'length;
    constant ex5_rslt_lw_hd_offset                                  : integer := ex5_rslt_ldo_offset            + ex5_rslt_ldo_q'length;
    constant ex5_cmp0_sel_reshi_offset                              : integer := ex5_rslt_lw_hd_offset          + ex5_rslt_lw_hd_q'length;
    constant ex5_cmp0_sel_reslo_offset                              : integer := ex5_cmp0_sel_reshi_offset      + 1;
    constant ex5_cmp0_sel_reslodly_offset                           : integer := ex5_cmp0_sel_reslo_offset      + 1;
    constant ex5_cmp0_sel_reslodly2_offset                          : integer := ex5_cmp0_sel_reslodly_offset   + 1;
    constant ex5_eq_sel_all0_b_offset                               : integer := ex5_cmp0_sel_reslodly2_offset  + 1;
    constant ex5_eq_sel_all0_hi_b_offset                            : integer := ex5_eq_sel_all0_b_offset       + 1;
    constant ex5_eq_sel_all0_lo_b_offset                            : integer := ex5_eq_sel_all0_hi_b_offset    + 1;
    constant ex5_eq_sel_all0_lo1_b_offset                           : integer := ex5_eq_sel_all0_lo_b_offset    + 1;
    constant ex5_eq_sel_all0_lo2_b_offset                           : integer := ex5_eq_sel_all0_lo1_b_offset   + 1;
    constant ex5_eq_sel_all0_lo3_b_offset                           : integer := ex5_eq_sel_all0_lo2_b_offset   + 1;
    constant ex5_ret_mullw_offset                                   : integer := ex5_eq_sel_all0_lo3_b_offset   + 1;
    constant ex5_ret_mulldo_offset                                  : integer := ex5_ret_mullw_offset           + 1;
    constant ex5_cmp0_undef_offset                                  : integer := ex5_ret_mulldo_offset          + 1;
    constant scan_right                                             : integer := ex5_cmp0_undef_offset          + 1;

    signal siv                                                      : std_ulogic_vector(0 to scan_right-1);
    signal sov                                                      : std_ulogic_vector(0 to scan_right-1);

begin

    ex1_retsel_d            <= dec_alu_rf1_mul_ret & dec_alu_rf1_mul_size & dec_alu_rf1_mul_imm;
    ex5_mul_cr_valid        <= ex5_is_recform_q         and                    ex5_mul_done_q;

    ex1_mul_val         <= ex1_mul_val_q and not fxa_fxb_ex1_hold_ctr_flush;
    ex1_mulstage_shift  <= tidn & gate(ex2_mulstage_q(0 to 2),not(fxa_fxb_ex1_hold_ctr_flush));

mult_64b_stagecnt : if regmode = 6 generate
    with ex1_mul_val select
        ex1_mulstage  <=  "1000"                            when '1',
                          ex1_mulstage_shift                when others;
end generate;
mult_32b_stagecnt : if regmode = 5 generate
    ex1_mulstage  <=  "0000";
end generate;





    ex2_bs_lo_sign_d            <= ((ex1_bs_sign and ex1_mul_sign_q and (ex1_mulstage(1) or ex1_mulstage(3))) and     ex1_mul_size_q ) or
                                   ( ex1_bs_sign and ex1_mul_sign_q                                           and not ex1_mul_size_q ) or
                                   ( ex1_bs_sign and ex1_mul_sign_q and  ex1_mulstage(1)                      and     ex1_retsel_q(2));
    ex2_bd_lo_sign_d            <= ((ex1_bd_sign and ex1_mul_sign_q and (ex1_mulstage(2) or ex1_mulstage(3))) and     ex1_mul_size_q ) or
                                   ( ex1_bd_sign and ex1_mul_sign_q                                           and not ex1_mul_size_q ) or
                                   ( ex1_bd_sign and ex1_mul_sign_q                                           and     ex1_retsel_q(2));

    ex1_mulsrc0_act   <= or_reduce(ex1_mulstage);
    ex1_mulsrc1_act   <= ex1_mulstage(0) or ex1_mulstage(2);

    with ex1_mul_val_q select
         ex1_mulsrc_0(0 to 63)   <= byp_alu_ex1_mulsrc_0(0  to 63)                         when '1',
                                    ex2_mulsrc_0_q(32 to 63) & ex2_mulsrc_0_q(0 to 31)     when others;
                                   

    with ex1_mul_val_q select
        ex1_mulsrc_1(0 to 63)    <= byp_alu_ex1_mulsrc_1(0  to 63)                         when '1',
                                    ex2_mulsrc_1_q(32 to 63) & ex2_mulsrc_1_q(0 to 31)     when others;
                                    
    with (ex1_mulstage(1) or ex1_mulstage(3)) select
        ex1_bd_sign              <= ex2_mulsrc_1_q(32)   when '1',
                                    ex1_mulsrc_1(32)     when others;
    
                                   
    ex1_bs_sign                 <= ex1_mulsrc_0(32);
    ex2_bs_lo                   <= ex2_mulsrc_0_q(32 to 63);
    ex2_bd_lo                   <= ex2_mulsrc_1_q(32 to 63);


    mcore : entity work.xuq_alu_mult_core(xuq_alu_mult_core)
        generic map (expand_type => expand_type)
        port map (
            nclk                        => nclk,
            vdd                         => vdd,
            gnd                         => gnd,
            delay_lclkr_dc              => delay_lclkr_dc,
            mpw1_dc_b                   => mpw1_dc_b,
            mpw2_dc_b                   => mpw2_dc_b,
            func_sl_force => func_sl_force,
            func_sl_thold_0_b           => func_sl_thold_0_b,
            sg_0                        => sg_0,
            scan_in                     => siv(0),
            scan_out                    => sov(0),
            ex2_act                     => ex2_act,
            ex3_act                     => ex3_act,
            ex2_bs_lo_sign              => ex2_bs_lo_sign_q,
            ex2_bd_lo_sign              => ex2_bd_lo_sign_q,
            ex2_bs_lo                   => ex2_bs_lo,
            ex2_bd_lo                   => ex2_bd_lo,
            ex3_recycle_s               => ex3_recycle_s(196 to 264),
            ex3_recycle_c               => ex3_recycle_c(196 to 263),
            ex4_pp5_0s_out              => ex4_pp5_0s,
            ex4_pp5_0c_out              => ex4_pp5_0c(196 to 263));

    ex4_pp5_0c(264)             <= tidn;
    
    ex2_act                     <= or_reduce(ex2_mulstage_q);
    ex3_act                     <= or_reduce(ex3_mulstage_q);
    ex4_act                     <= or_reduce(ex4_mulstage_q);


    ex4_ci_d                    <= (carry_32_dly1_q and   ex3_mulstage_q(2)                         ) or 
                                   (ex4_cout_32     and ((ex3_mulstage_q(3) and ex3_retsel_q(1)) or
                                                         (ex3_mulstage_q(1) and ex3_retsel_q(2)))   );

    ex4_xi                      <= ex4_pp5_0s(200 to 263);
    ex4_yi                      <= ex4_pp5_0c(200 to 263);

    ex4_p                       <= ex4_xi(0 to 63) xor ex4_yi(0 to 63);
    ex4_g                       <= ex4_xi(1 to 63) and ex4_yi(1 to 63);
    ex4_t                       <= ex4_xi(1 to 63)  or ex4_yi(1 to 63);

    ex4_xi_b(0 to 63)           <= not ex4_xi(0 to 63) ;
    ex4_yi_b(0 to 63)           <= not ex4_yi(0 to 63) ;

    cla64ci: entity work.xuq_add(xuq_add)
    port map(
         x_b(0 to 63)           => ex4_xi_b(0 to 63),
         y_b(0 to 63)           => ex4_yi_b(0 to 63),
         ci(8)                  => ex4_ci_q,
         sum(0 to 63)           => ex4_res(0 to 63),
         cout_32                => ex4_cout_32,
         cout_0                 => open);

    ex3_recyc_sh32              <= ex3_retsel_q(1) and (ex3_mulstage_q(1) or ex3_mulstage_q(3));
    ex3_recyc_sh00              <= ex3_retsel_q(1) and (ex3_mulstage_q(2)) ;

    ex3_xtd_196_or              <= ex4_pp5_0s(196) or  ex4_pp5_0c(196);
    ex3_xtd_196_and             <= ex4_pp5_0s(196) and ex4_pp5_0c(196);
    ex3_xtd_197_or              <= ex4_pp5_0s(197) or  ex4_pp5_0c(197);
    ex3_xtd_197_and             <= ex4_pp5_0s(197) and ex4_pp5_0c(197);

    ex3_xtd_ge1                 <= ex3_xtd_196_or  or ex3_xtd_197_or;
    ex3_xtd_ge2                 <= ex3_xtd_196_or  or ex3_xtd_197_and;
    ex3_xtd_ge3                 <= ex3_xtd_196_and or (ex3_xtd_196_or and ex3_xtd_197_or);


    ex3_xtd                     <= (ex3_mulstage_q(1) and ex3_retsel_q(1) and not ex3_xtd_ge1) or
                                   (ex3_mulstage_q(2) and ex3_retsel_q(1) and not ex3_xtd_ge2) or
                                   (ex3_mulstage_q(3) and ex3_retsel_q(1) and not ex3_xtd_ge3) ;

    ex3_recycle_s(196)          <= ex4_pp5_0s(196) and (ex3_retsel_q(1) and not ex3_mulstage_q(0));
    ex3_recycle_c(196)          <= ex4_pp5_0c(196) and (ex3_retsel_q(1) and not ex3_mulstage_q(0)) ;

    ex3_recycle_s(197)          <= ex4_pp5_0s(197) and (ex3_retsel_q(1) and not ex3_mulstage_q(0)) ;
    ex3_recycle_c(197)          <= ex4_pp5_0c(197) and (ex3_retsel_q(1) and not ex3_mulstage_q(0)) ;

    ex3_recycle_s(198 to 264)   <= ( (198 to 264=> ex3_recyc_sh00) and (                       ex4_pp5_0s(198 to 264)        ) ) or
                                   ( (198 to 264=> ex3_recyc_sh32) and ( (0 to 31=> ex3_xtd) & ex4_pp5_0s(198 to 231) & tidn ) ) ;

    ex3_recycle_c(198 to 264)   <= ( (198 to 264=> ex3_recyc_sh00) and (                       ex4_pp5_0c(198 to 264)        ) ) or
                                   ( (198 to 264=> ex3_recyc_sh32) and ( (0 to 31=> tidn)    & ex4_pp5_0c(198 to 231) & tidn ) ) ;

    rslt_lo_act                 <= ex5_mulstage_q(0) or ex5_mulstage_q(2);

    rslt_lo_d                   <= ex5_res_q(32 to 63);
    rslt_lo_dly_d               <= rslt_lo_q;


    ex4_ret_mulhw               <=     ex4_retsel_q(0) and not ex4_retsel_q(1) and not ex4_retsel_q(2)                            ;
    ex4_ret_mullw               <= not ex4_retsel_q(0) and not ex4_retsel_q(1) and not ex4_retsel_q(2)                            ;
    ex4_ret_mulli               <=                                                     ex4_retsel_q(2)                            ;
    ex4_ret_mulld               <= not ex4_retsel_q(0) and     ex4_retsel_q(1) and not ex4_retsel_q(2) and not ex4_xer_ov_update_q;
    ex4_ret_mulldo              <= not ex4_retsel_q(0) and     ex4_retsel_q(1) and not ex4_retsel_q(2) and     ex4_xer_ov_update_q;
    ex4_ret_mulhd               <=     ex4_retsel_q(0) and     ex4_retsel_q(1) and not ex4_retsel_q(2)                            ;

    ex5_rslt_hw_d               <= (others=>(ex4_ret_mulhw                 ));
    ex5_rslt_ld_li_d            <= (others=>(ex4_ret_mulli or ex4_ret_mulld));
    ex5_rslt_ldo_d              <= (others=>(ex4_ret_mulldo                ));
    ex5_rslt_lw_hd_d            <= (others=>(ex4_ret_mullw or ex4_ret_mulhd));

    ex5_result                  <= (((0 to 31 => '0')    & ex5_res_q(0 to 31)) and fanout(ex5_rslt_hw_q   ,64)) or   
                                   ((ex5_res_q(32 to 63) & rslt_lo_q         ) and fanout(ex5_rslt_ld_li_q,64)) or 
                                   ((rslt_lo_q           & rslt_lo_dly_q     ) and fanout(ex5_rslt_ldo_q  ,64)) or   
                                   ((ex5_res_q                               ) and fanout(ex5_rslt_lw_hd_q,64));

    ex4_all0_test(0 to 62)      <= ( not ex4_p(0 to 62) and not ex4_t(1 to 63) ) or
                                   (     ex4_p(0 to 62) and     ex4_t(1 to 63) ) ;
    ex4_all0_test(63)           <= ( not ex4_p(63)      and not ex4_ci_q         ) or
                                   (     ex4_p(63)      and     ex4_ci_q         ) ;
    ex4_all0_test_mid           <= ( not ex4_p(31)      and not ex4_cout_32      ) or
                                   (     ex4_p(31)      and     ex4_cout_32      ) ;

    ex4_all1_test(0 to 62)      <= (     ex4_p(0 to 62) and not ex4_g(1 to 63) ) or
                                   ( not ex4_p(0 to 62) and     ex4_g(1 to 63) );
    ex4_all1_test(63)           <= (     ex4_p(63)      and not ex4_ci_q         ) or
                                   ( not ex4_p(63)      and     ex4_ci_q         );
    ex4_all1_test_mid           <= (     ex4_p(31)      and not ex4_cout_32      ) or
                                   ( not ex4_p(31)      and     ex4_cout_32      );

    ex4_all0                    <= and_reduce( ex4_all0_test(0 to 63)  );
    ex4_all1                    <= and_reduce( ex4_all1_test(0 to 63)  );
    ex4_all0_lo                 <= and_reduce( ex4_all0_test(32 to 63) );
    ex4_all0_hi                 <= and_reduce( ex4_all0_test(0 to 30) & ex4_all0_test_mid );
    ex4_all1_hi                 <= and_reduce( ex4_all1_test(0 to 30) & ex4_all1_test_mid );




    ex5_cmp0_undef_d          <=   ex4_ret_mulhw                   and     ex4_spr_msr_cm;

    ex5_cmp0_sel_reshi_d      <= ( ex4_ret_mulhw                                         ) or
                                 ((ex4_ret_mullw or ex4_ret_mulhd) and     ex4_spr_msr_cm);
    ex5_cmp0_sel_reslo_d      <= ((ex4_ret_mullw or ex4_ret_mulhd) and not ex4_spr_msr_cm) or
                                 ( ex4_ret_mulld                   and     ex4_spr_msr_cm);
    ex5_cmp0_sel_reslodly_d   <= ( ex4_ret_mulld                   and not ex4_spr_msr_cm) or
                                 ( ex4_ret_mulldo                  and     ex4_spr_msr_cm);
    ex5_cmp0_sel_reslodly2_d  <= ( ex4_ret_mulldo                  and not ex4_spr_msr_cm);
    
    ex5_sign_rt_cmp0    <=(ex5_cmp0_sel_reshi_q       and ex5_res_q(0)     ) or
                          (ex5_cmp0_sel_reslo_q       and ex5_res_q(32)    ) or
                          (ex5_cmp0_sel_reslodly_q    and rslt_lo_q(0)     ) or
                          (ex5_cmp0_sel_reslodly2_q   and rslt_lo_dly_q(0) ); 
    



   ex5_eq_sel_all0_hi_b_d  <= not( ex4_ret_mulhw                         );

   ex5_eq_sel_all0_b_d     <= not((ex4_ret_mullw  and     ex4_spr_msr_cm) or
                                  (ex4_ret_mulhd  and     ex4_spr_msr_cm));

   ex5_eq_sel_all0_lo_b_d  <= not((ex4_ret_mullw  and not ex4_spr_msr_cm) or                       
                                  (ex4_ret_mulhd  and not ex4_spr_msr_cm) or 
                                  (ex4_ret_mulld  and     ex4_spr_msr_cm));

   ex5_eq_sel_all0_lo1_b_d <= not((ex4_ret_mulldo and     ex4_spr_msr_cm));

   ex5_eq_sel_all0_lo2_b_d <= not( ex4_ret_mulld                         );

   ex5_eq_sel_all0_lo3_b_d <= not( ex4_ret_mulldo                        );


   ex5_eq   <= (ex5_eq_sel_all0_b_q     or ex5_all0_q    ) and
               (ex5_eq_sel_all0_lo_b_q  or ex5_all0_lo_q ) and
               (ex5_eq_sel_all0_lo1_b_q or all0_lo_dly1_q) and
               (ex5_eq_sel_all0_lo2_b_q or all0_lo_dly2_q) and
               (ex5_eq_sel_all0_lo3_b_q or all0_lo_dly3_q) and
               (ex5_eq_sel_all0_hi_b_q  or ex5_all0_hi_q );

    ex5_cmp0_eq                 <=                              ex5_eq and not ex5_cmp0_undef_q;
    ex5_cmp0_gt                 <= not ex5_sign_rt_cmp0 and not ex5_eq and not ex5_cmp0_undef_q;
    ex5_cmp0_lt                 <=     ex5_sign_rt_cmp0 and not ex5_eq and not ex5_cmp0_undef_q;



     ex5_xer_ov                  <= (ex5_ret_mullw_q  and ((not ex5_res_q(32) and not ex5_all0_hi_q) or
                                                           (    ex5_res_q(32) and not ex5_all1_hi_q))) or
                                    (ex5_ret_mulldo_q and ((not rslt_lo_q(0)  and not ex5_all0_q   ) or
                                                           (    rslt_lo_q(0)  and not ex5_all1_q   )));


    alu_byp_ex5_mul_rt          <= ex5_result;
    alu_byp_ex5_cr_mul          <= ex5_cmp0_lt & ex5_cmp0_gt & ex5_cmp0_eq & (ex5_xer_ov and ex5_xer_ov_update_q) & ex5_mul_cr_valid;
    alu_byp_ex5_xer_mul         <= ex5_xer_ov & tidn & ex5_xer_ov_update_q & tidn;



    ex2_ready_stage(0)      <= (                        not ex2_retsel_q(1) and not ex2_retsel_q(2)                            )    ;
    ex2_ready_stage(1)      <= (                                                    ex2_retsel_q(2)                            )    ;
    ex2_ready_stage(2)      <= (not ex2_retsel_q(0) and     ex2_retsel_q(1) and not ex2_retsel_q(2) and not ex2_xer_ov_update_q)    ;
    ex2_ready_stage(3)      <= (not ex2_retsel_q(0) and     ex2_retsel_q(1) and not ex2_retsel_q(2) and     ex2_xer_ov_update_q) or
                               (    ex2_retsel_q(0) and     ex2_retsel_q(1) and not ex2_retsel_q(2)                            )    ;


    ex3_mul_done_d      <= or_reduce(ex2_ready_stage and ex2_mulstage_q);

    alu_ex3_mul_done    <= ex3_mul_done_q;
    alu_ex4_mul_done    <= ex4_mul_done_q;


    mark_unused(ex3_recycle_c(264));
    mark_unused(ex5_mulstage_q(1));
    mark_unused(ex5_mulstage_q(3));

    ex1_mul_val_latch : tri_rlmlatch_p
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
                  scin          => siv(ex1_mul_val_offset),
                  scout         => sov(ex1_mul_val_offset),
                  din           => dec_alu_rf1_mul_val,
                  dout          => ex1_mul_val_q);
    ex2_mulstage_latch : tri_rlmreg_p
        generic map (width => ex2_mulstage_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex2_mulstage_offset to ex2_mulstage_offset + ex2_mulstage_q'length-1),
                  scout         => sov(ex2_mulstage_offset to ex2_mulstage_offset + ex2_mulstage_q'length-1),
                  din           => ex1_mulstage,
                  dout          => ex2_mulstage_q);
    ex3_mulstage_latch : tri_rlmreg_p
        generic map (width => ex3_mulstage_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex3_mulstage_offset to ex3_mulstage_offset + ex3_mulstage_q'length-1),
                  scout         => sov(ex3_mulstage_offset to ex3_mulstage_offset + ex3_mulstage_q'length-1),
                  din           => ex2_mulstage_q,
                  dout          => ex3_mulstage_q);
    ex4_mulstage_latch : tri_rlmreg_p
        generic map (width => ex4_mulstage_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex4_mulstage_offset to ex4_mulstage_offset + ex4_mulstage_q'length-1),
                  scout         => sov(ex4_mulstage_offset to ex4_mulstage_offset + ex4_mulstage_q'length-1),
                  din           => ex3_mulstage_q,
                  dout          => ex4_mulstage_q);
    ex5_mulstage_latch : tri_rlmreg_p
        generic map (width => ex5_mulstage_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex5_mulstage_offset to ex5_mulstage_offset + ex5_mulstage_q'length-1),
                  scout         => sov(ex5_mulstage_offset to ex5_mulstage_offset + ex5_mulstage_q'length-1),
                  din           => ex4_mulstage_q,
                  dout          => ex5_mulstage_q);
    ex1_retsel_latch : tri_rlmreg_p
        generic map (width => ex1_retsel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => dec_alu_rf1_mul_val,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_retsel_offset to ex1_retsel_offset + ex1_retsel_q'length-1),
                  scout         => sov(ex1_retsel_offset to ex1_retsel_offset + ex1_retsel_q'length-1),
                  din           => ex1_retsel_d,
                  dout          => ex1_retsel_q);
    ex2_retsel_latch : tri_rlmreg_p
        generic map (width => ex2_retsel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => ex1_mul_val_q,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex2_retsel_offset to ex2_retsel_offset + ex2_retsel_q'length-1),
                  scout         => sov(ex2_retsel_offset to ex2_retsel_offset + ex2_retsel_q'length-1),
                  din           => ex1_retsel_q,
                  dout          => ex2_retsel_q);
    ex3_retsel_latch : tri_rlmreg_p
        generic map (width => ex3_retsel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex3_retsel_offset to ex3_retsel_offset + ex3_retsel_q'length-1),
                  scout         => sov(ex3_retsel_offset to ex3_retsel_offset + ex3_retsel_q'length-1),
                  din           => ex2_retsel_q,
                  dout          => ex3_retsel_q);
    ex4_retsel_latch : tri_rlmreg_p
        generic map (width => ex4_retsel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex4_retsel_offset to ex4_retsel_offset + ex4_retsel_q'length-1),
                  scout         => sov(ex4_retsel_offset to ex4_retsel_offset + ex4_retsel_q'length-1),
                  din           => ex3_retsel_q,
                  dout          => ex4_retsel_q);
    ex3_mul_done_latch : tri_rlmlatch_p
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
                  scin          => siv(ex3_mul_done_offset),
                  scout         => sov(ex3_mul_done_offset),
                  din           => ex3_mul_done_d,
                  dout          => ex3_mul_done_q);
    ex4_mul_done_latch : tri_rlmlatch_p
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
                  scin          => siv(ex4_mul_done_offset),
                  scout         => sov(ex4_mul_done_offset),
                  din           => ex3_mul_done_q,
                  dout          => ex4_mul_done_q);
    ex5_mul_done_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_mul_done_offset),
                  scout         => sov(ex5_mul_done_offset),
                  din           => ex4_mul_done_q,
                  dout          => ex5_mul_done_q);
    ex1_is_recform_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => dec_alu_rf1_mul_val,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_is_recform_offset),
                  scout         => sov(ex1_is_recform_offset),
                  din           => dec_alu_rf1_mul_recform,
                  dout          => ex1_is_recform_q);
    ex2_is_recform_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_is_recform_offset),
                  scout         => sov(ex2_is_recform_offset),
                  din           => ex1_is_recform_q,
                  dout          => ex2_is_recform_q);
    ex3_is_recform_latch : tri_rlmlatch_p
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
                  scin          => siv(ex3_is_recform_offset),
                  scout         => sov(ex3_is_recform_offset),
                  din           => ex2_is_recform_q,
                  dout          => ex3_is_recform_q);
    ex4_is_recform_latch : tri_rlmlatch_p
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
                  scin          => siv(ex4_is_recform_offset),
                  scout         => sov(ex4_is_recform_offset),
                  din           => ex3_is_recform_q,
                  dout          => ex4_is_recform_q);
    ex5_is_recform_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_is_recform_offset),
                  scout         => sov(ex5_is_recform_offset),
                  din           => ex4_is_recform_q,
                  dout          => ex5_is_recform_q);
    ex1_xer_ov_update_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => dec_alu_rf1_mul_val,
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
                  din           => ex1_xer_ov_update_q,
                  dout          => ex2_xer_ov_update_q);
    ex3_xer_ov_update_latch : tri_rlmlatch_p
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
                  scin          => siv(ex3_xer_ov_update_offset),
                  scout         => sov(ex3_xer_ov_update_offset),
                  din           => ex2_xer_ov_update_q,
                  dout          => ex3_xer_ov_update_q);
    ex4_xer_ov_update_latch : tri_rlmlatch_p
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
                  scin          => siv(ex4_xer_ov_update_offset),
                  scout         => sov(ex4_xer_ov_update_offset),
                  din           => ex3_xer_ov_update_q,
                  dout          => ex4_xer_ov_update_q);
    ex5_xer_ov_update_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_xer_ov_update_offset),
                  scout         => sov(ex5_xer_ov_update_offset),
                  din           => ex4_xer_ov_update_q,
                  dout          => ex5_xer_ov_update_q);
    ex1_mul_size_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => dec_alu_rf1_mul_val,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_mul_size_offset),
                  scout         => sov(ex1_mul_size_offset),
                  din           => dec_alu_rf1_mul_size,
                  dout          => ex1_mul_size_q);
    ex1_mul_sign_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => dec_alu_rf1_mul_val,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_mul_sign_offset),
                  scout         => sov(ex1_mul_sign_offset),
                  din           => dec_alu_rf1_mul_sign,
                  dout          => ex1_mul_sign_q);
    ex2_bs_lo_sign_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_bs_lo_sign_offset),
                  scout         => sov(ex2_bs_lo_sign_offset),
                  din           => ex2_bs_lo_sign_d,
                  dout          => ex2_bs_lo_sign_q);
    ex2_bd_lo_sign_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_bd_lo_sign_offset),
                  scout         => sov(ex2_bd_lo_sign_offset),
                  din           => ex2_bd_lo_sign_d,
                  dout          => ex2_bd_lo_sign_q);
    ex5_all0_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_all0_offset),
                  scout         => sov(ex5_all0_offset),
                  din           => ex4_all0,
                  dout          => ex5_all0_q);
    ex5_all1_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_all1_offset),
                  scout         => sov(ex5_all1_offset),
                  din           => ex4_all1,
                  dout          => ex5_all1_q);
    ex5_all0_lo_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_all0_lo_offset),
                  scout         => sov(ex5_all0_lo_offset),
                  din           => ex4_all0_lo,
                  dout          => ex5_all0_lo_q);
    ex5_all0_hi_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_all0_hi_offset),
                  scout         => sov(ex5_all0_hi_offset),
                  din           => ex4_all0_hi,
                  dout          => ex5_all0_hi_q);
    ex5_all1_hi_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_all1_hi_offset),
                  scout         => sov(ex5_all1_hi_offset),
                  din           => ex4_all1_hi,
                  dout          => ex5_all1_hi_q);
    ex4_ci_latch : tri_rlmlatch_p
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
                  scin          => siv(ex4_ci_offset),
                  scout         => sov(ex4_ci_offset),
                  din           => ex4_ci_d,
                  dout          => ex4_ci_q);
    ex5_res_latch : tri_rlmreg_p
        generic map (width => ex5_res_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => ex4_act,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex5_res_offset to ex5_res_offset + ex5_res_q'length-1),
                  scout         => sov(ex5_res_offset to ex5_res_offset + ex5_res_q'length-1),
                  din           => ex4_res,
                  dout          => ex5_res_q);
    carry_32_dly1_latch : tri_rlmlatch_p
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
                  scin          => siv(carry_32_dly1_offset),
                  scout         => sov(carry_32_dly1_offset),
                  din           => ex4_cout_32,
                  dout          => carry_32_dly1_q);
    all0_lo_dly1_latch : tri_rlmlatch_p
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
                  scin          => siv(all0_lo_dly1_offset),
                  scout         => sov(all0_lo_dly1_offset),
                  din           => ex5_all0_lo_q,
                  dout          => all0_lo_dly1_q);
    all0_lo_dly2_latch : tri_rlmlatch_p
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
                  scin          => siv(all0_lo_dly2_offset),
                  scout         => sov(all0_lo_dly2_offset),
                  din           => all0_lo_dly1_q,
                  dout          => all0_lo_dly2_q);
    all0_lo_dly3_latch : tri_rlmlatch_p
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
                  scin          => siv(all0_lo_dly3_offset),
                  scout         => sov(all0_lo_dly3_offset),
                  din           => all0_lo_dly2_q,
                  dout          => all0_lo_dly3_q);
    rslt_lo_latch : tri_rlmreg_p
        generic map (width => rslt_lo_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => rslt_lo_act,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(rslt_lo_offset to rslt_lo_offset + rslt_lo_q'length-1),
                  scout         => sov(rslt_lo_offset to rslt_lo_offset + rslt_lo_q'length-1),
                  din           => rslt_lo_d,
                  dout          => rslt_lo_q);
    rslt_lo_dly_latch : tri_rlmreg_p
        generic map (width => rslt_lo_dly_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(rslt_lo_dly_offset to rslt_lo_dly_offset + rslt_lo_dly_q'length-1),
                  scout         => sov(rslt_lo_dly_offset to rslt_lo_dly_offset + rslt_lo_dly_q'length-1),
                  din           => rslt_lo_dly_d,
                  dout          => rslt_lo_dly_q);
   ex2_mulsrc_0_latch : tri_rlmreg_p
     generic map (width => ex2_mulsrc_0_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_mulsrc0_act,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_mulsrc_0_offset to ex2_mulsrc_0_offset + ex2_mulsrc_0_q'length-1),
               scout   => sov(ex2_mulsrc_0_offset to ex2_mulsrc_0_offset + ex2_mulsrc_0_q'length-1),
               din     => ex1_mulsrc_0,
               dout    => ex2_mulsrc_0_q);
   ex2_mulsrc_1_latch : tri_rlmreg_p
     generic map (width => ex2_mulsrc_1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex1_mulsrc1_act,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex2_mulsrc_1_offset to ex2_mulsrc_1_offset + ex2_mulsrc_1_q'length-1),
               scout   => sov(ex2_mulsrc_1_offset to ex2_mulsrc_1_offset + ex2_mulsrc_1_q'length-1),
               din     => ex1_mulsrc_1,
               dout    => ex2_mulsrc_1_q);
   ex5_rslt_hw_latch : tri_rlmreg_p
     generic map (width => ex5_rslt_hw_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_rslt_hw_offset to ex5_rslt_hw_offset + ex5_rslt_hw_q'length-1),
               scout   => sov(ex5_rslt_hw_offset to ex5_rslt_hw_offset + ex5_rslt_hw_q'length-1),
               din     => ex5_rslt_hw_d,
               dout    => ex5_rslt_hw_q);
   ex5_rslt_ld_li_latch : tri_rlmreg_p
     generic map (width => ex5_rslt_ld_li_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_rslt_ld_li_offset to ex5_rslt_ld_li_offset + ex5_rslt_ld_li_q'length-1),
               scout   => sov(ex5_rslt_ld_li_offset to ex5_rslt_ld_li_offset + ex5_rslt_ld_li_q'length-1),
               din     => ex5_rslt_ld_li_d,
               dout    => ex5_rslt_ld_li_q);
   ex5_rslt_ldo_latch : tri_rlmreg_p
     generic map (width => ex5_rslt_ldo_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_rslt_ldo_offset to ex5_rslt_ldo_offset + ex5_rslt_ldo_q'length-1),
               scout   => sov(ex5_rslt_ldo_offset to ex5_rslt_ldo_offset + ex5_rslt_ldo_q'length-1),
               din     => ex5_rslt_ldo_d,
               dout    => ex5_rslt_ldo_q);
   ex5_rslt_lw_hd_latch : tri_rlmreg_p
     generic map (width => ex5_rslt_lw_hd_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_rslt_lw_hd_offset to ex5_rslt_lw_hd_offset + ex5_rslt_lw_hd_q'length-1),
               scout   => sov(ex5_rslt_lw_hd_offset to ex5_rslt_lw_hd_offset + ex5_rslt_lw_hd_q'length-1),
               din     => ex5_rslt_lw_hd_d,
               dout    => ex5_rslt_lw_hd_q);
   ex5_cmp0_sel_reshi_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_cmp0_sel_reshi_offset),
               scout   => sov(ex5_cmp0_sel_reshi_offset),
               din     => ex5_cmp0_sel_reshi_d,
               dout    => ex5_cmp0_sel_reshi_q);
   ex5_cmp0_sel_reslo_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_cmp0_sel_reslo_offset),
               scout   => sov(ex5_cmp0_sel_reslo_offset),
               din     => ex5_cmp0_sel_reslo_d,
               dout    => ex5_cmp0_sel_reslo_q);
   ex5_cmp0_sel_reslodly_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_cmp0_sel_reslodly_offset),
               scout   => sov(ex5_cmp0_sel_reslodly_offset),
               din     => ex5_cmp0_sel_reslodly_d,
               dout    => ex5_cmp0_sel_reslodly_q);
   ex5_cmp0_sel_reslodly2_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_cmp0_sel_reslodly2_offset),
               scout   => sov(ex5_cmp0_sel_reslodly2_offset),
               din     => ex5_cmp0_sel_reslodly2_d,
               dout    => ex5_cmp0_sel_reslodly2_q);
   ex5_eq_sel_all0_b_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_eq_sel_all0_b_offset),
               scout   => sov(ex5_eq_sel_all0_b_offset),
               din     => ex5_eq_sel_all0_b_d,
               dout    => ex5_eq_sel_all0_b_q);
   ex5_eq_sel_all0_lo_b_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_eq_sel_all0_lo_b_offset),
               scout   => sov(ex5_eq_sel_all0_lo_b_offset),
               din     => ex5_eq_sel_all0_lo_b_d,
               dout    => ex5_eq_sel_all0_lo_b_q);
   ex5_eq_sel_all0_hi_b_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_eq_sel_all0_hi_b_offset),
               scout   => sov(ex5_eq_sel_all0_hi_b_offset),
               din     => ex5_eq_sel_all0_hi_b_d,
               dout    => ex5_eq_sel_all0_hi_b_q);
   ex5_eq_sel_all0_lo1_b_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_eq_sel_all0_lo1_b_offset),
               scout   => sov(ex5_eq_sel_all0_lo1_b_offset),
               din     => ex5_eq_sel_all0_lo1_b_d,
               dout    => ex5_eq_sel_all0_lo1_b_q);
   ex5_eq_sel_all0_lo2_b_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_eq_sel_all0_lo2_b_offset),
               scout   => sov(ex5_eq_sel_all0_lo2_b_offset),
               din     => ex5_eq_sel_all0_lo2_b_d,
               dout    => ex5_eq_sel_all0_lo2_b_q);
   ex5_eq_sel_all0_lo3_b_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_eq_sel_all0_lo3_b_offset),
               scout   => sov(ex5_eq_sel_all0_lo3_b_offset),
               din     => ex5_eq_sel_all0_lo3_b_d,
               dout    => ex5_eq_sel_all0_lo3_b_q);
   ex5_ret_mullw_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_ret_mullw_offset),
               scout   => sov(ex5_ret_mullw_offset),
               din     => ex4_ret_mullw,
               dout    => ex5_ret_mullw_q);
   ex5_ret_mulldo_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_ret_mulldo_offset),
               scout   => sov(ex5_ret_mulldo_offset),
               din     => ex4_ret_mulldo,
               dout    => ex5_ret_mulldo_q);
   ex5_cmp0_undef_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex4_mul_done_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex5_cmp0_undef_offset),
               scout   => sov(ex5_cmp0_undef_offset),
               din     => ex5_cmp0_undef_d,
               dout    => ex5_cmp0_undef_q);

    siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in;
    scan_out             <= sov(0);

end architecture xuq_alu_mult;
