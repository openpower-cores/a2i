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

entity xuq_alu_add is
    generic(
        expand_type                     : integer := 2;
        dc_size                         : natural := 14;
        regsize                         : integer := 64;
        fxu_synth                       : integer := 0);
    port(
        nclk                            : in clk_logic;

        vdd                             : inout power_logic;
        gnd                             : inout power_logic;

        dec_alu_rf1_add_act             : in std_ulogic;
        d_mode_dc                       : in std_ulogic;
        delay_lclkr_dc                  : in std_ulogic;
        mpw1_dc_b                       : in std_ulogic;
        mpw2_dc_b                       : in std_ulogic;
        func_sl_force : in std_ulogic;
        func_sl_thold_0_b               : in std_ulogic;
        sg_0                            : in std_ulogic;
        scan_in                         : in std_ulogic;
        scan_out                        : out std_ulogic;

        dec_alu_rf1_select_64bmode      : in std_ulogic;

        dec_alu_rf1_add_rs0_inv         : in std_ulogic_vector(64-regsize to 63);
        dec_alu_rf1_add_ci              : in std_ulogic;
        dec_alu_rf1_is_cmpl             : in std_ulogic;
        dec_alu_rf1_tw_cmpsel           : in std_ulogic_vector(0 to 5);
        dec_alu_ex1_is_cmp              : in std_ulogic;

        byp_alu_ex1_rs0                 : in std_ulogic_vector(64-regsize to 63);
        byp_alu_ex1_rs1                 : in std_ulogic_vector(64-regsize to 63);

        log_add_ex2_rt                  :in  std_ulogic_vector(64-regsize to 63);
        alu_byp_ex2_rt                  :out std_ulogic_vector(64-regsize to 63);

        add_log_ex1_add_rt              : out std_ulogic_vector(64-regsize to 63);
        ex2_cr_recform                  : out std_ulogic_vector(0 to 3);

        xu_ex1_eff_addr_int             : out std_ulogic_vector(64-(dc_size-3) to 63);
        xu_ex2_eff_addr                 : out std_ulogic_vector(64-regsize to 63);

        ex3_trap_val                    : out std_ulogic;

        ex2_add_xer_ov                  : out std_ulogic;
        ex2_add_xer_ca                  : out std_ulogic
    );
    -- synopsys translate_off

    -- synopsys translate_on



end xuq_alu_add;
architecture xuq_alu_add of xuq_alu_add is
    constant msb                                    : integer := 64-regsize;
    constant tiup                                   : std_ulogic := '1';
    constant tidn                                   : std_ulogic := '0';

    signal ex1_add_act_q                            : std_ulogic;
    signal ex1_rs0_inv_q,       ex1_rs0_inv_q_b     : std_ulogic_vector(64-regsize to 63);
    signal ex1_add_ci_q                             : std_ulogic;
    signal ex1_is_cmpl_q                            : std_ulogic;
    signal ex1_tw_cmpsel_q                          : std_ulogic_vector(0 to 5);
    signal ex2_add_xer_ca_q,    ex2_add_xer_ca_d    : std_ulogic;
    signal ex2_rs0_msb_q,       ex2_rs0_msb_d       : std_ulogic;
    signal ex2_rs1_msb_q,       ex2_rs1_msb_d       : std_ulogic;
    signal ex2_is_cmpl_q                            : std_ulogic;
    signal ex2_overflow_q                           : std_ulogic;
    signal ex2_tw_cmpsel_q                          : std_ulogic_vector(0 to 5);
    signal ex2_is_cmp_q                             : std_ulogic;
    signal ex2_eff_addr_q,  ex2_eff_addr_q_b,      ex2_eff_addr_d      : std_ulogic_vector(64-regsize to 63);
    signal ex3_trap_val_q,      ex3_trap_val_d      : std_ulogic;
    signal ex1_select_64bmode_q                     : std_ulogic;
    signal ex2_select_32bcmp_q, ex1_select_32bcmp   : std_ulogic;
    constant ex1_add_act_offset                     : integer := 0;
    constant ex1_rs0_inv_offset                     : integer := ex1_add_act_offset         + 1;
    constant ex1_add_ci_offset                      : integer := ex1_rs0_inv_offset         + ex1_rs0_inv_q'length;
    constant ex1_is_cmpl_offset                     : integer := ex1_add_ci_offset          + 1;
    constant ex1_tw_cmpsel_offset                   : integer := ex1_is_cmpl_offset         + 1;
    constant ex2_add_xer_ca_offset                  : integer := ex1_tw_cmpsel_offset       + ex1_tw_cmpsel_q'length;
    constant ex2_rs0_msb_offset                     : integer := ex2_add_xer_ca_offset      + 1;
    constant ex2_rs1_msb_offset                     : integer := ex2_rs0_msb_offset         + 1;
    constant ex2_is_cmpl_offset                     : integer := ex2_rs1_msb_offset         + 1;
    constant ex2_overflow_offset                    : integer := ex2_is_cmpl_offset         + 1;
    constant ex2_tw_cmpsel_offset                   : integer := ex2_overflow_offset        + 1;
    constant ex2_is_cmp_offset                      : integer := ex2_tw_cmpsel_offset       + ex2_tw_cmpsel_q'length;
    constant ex2_eff_addr_offset                    : integer := ex2_is_cmp_offset          + 1;
    constant ex3_trap_val_offset                    : integer := ex2_eff_addr_offset        + ex2_eff_addr_q'length;
    constant ex1_select_64bmode_offset              : integer := ex3_trap_val_offset        + 1;
    constant ex2_select_32bcmp_offset               : integer := ex1_select_64bmode_offset  + 1;
    constant scan_right                             : integer := ex2_select_32bcmp_offset   + 1;
    signal siv                                      : std_ulogic_vector(0 to scan_right-1);
    signal sov                                      : std_ulogic_vector(0 to scan_right-1);
    signal ex1_lclk_int                             : clk_logic;
    signal ex1_d1clk_int, ex1_d2clk_int             : std_ulogic;
    signal ex2_lclk_int                             : clk_logic;
    signal ex2_d1clk_int, ex2_d2clk_int             : std_ulogic;
    signal ex1_aop_00                               : std_ulogic;
    signal ex1_bop_00                               : std_ulogic;
    signal ex1_aop_32                               : std_ulogic;
    signal ex1_bop_32                               : std_ulogic;
    signal ex1_x_b, ex1_y_b , ex1_y                 : std_ulogic_vector(64-regsize to 63);
    signal aop_rep_b , bop_rep_b                    : std_ulogic_vector(64-regsize to 63);
    signal ex1_add_rslt                             : std_ulogic_vector(64-regsize to 63);
    signal ex1_cout_32                              : std_ulogic;
    signal ex1_cout_00                              : std_ulogic;
    signal ex2_diff_sign                            : std_ulogic;
    signal ex2_cmp0_eq                              : std_ulogic;
    signal ex2_rslt_gt_s                            : std_ulogic;
    signal ex2_rslt_lt_s                            : std_ulogic;
    signal ex2_rslt_gt_u                            : std_ulogic;
    signal ex2_rslt_lt_u                            : std_ulogic;
    signal ex2_cmp_eq                               : std_ulogic;
    signal ex2_cmp_gt                               : std_ulogic;
    signal ex2_cmp_lt                               : std_ulogic;
    signal ex2_sign_cmp                             : std_ulogic;
    signal ex2_rt_msb                               : std_ulogic;
    signal ex1_overflow                             : std_ulogic;
    signal ex2_cmp0_lo  ,       ex2_cmp0_hi         : std_ulogic;
    signal ex1_sgn00_32,      ex1_sgn11_32          : std_ulogic;
    signal ex1_sgn00_64,      ex1_sgn11_64          : std_ulogic;
    signal ex1_ovf32_00_b,    ex1_ovf32_11_b        : std_ulogic;
    signal ex1_ovf64_00_b,    ex1_ovf64_11_b        : std_ulogic;

    signal eff0_b, eff0, eff1_b, eff1               : std_ulogic_vector(64-(dc_size-3) to 63);
    signal alu_byp_ex2_rt_b                         : std_ulogic_vector(64-regsize to 63);









begin


    ex1_select_32bcmp          <= not ex1_select_64bmode_q;

    aop_rep_b <= not( byp_alu_ex1_rs0 ) ;
    bop_rep_b <= not( byp_alu_ex1_rs1 ) ;

    u_aop_xor:    ex1_x_b    <= aop_rep_b xor ex1_rs0_inv_q ; 
    u_bop_i:      ex1_y      <= not bop_rep_b ; 
    u_bop_ii:     ex1_y_b    <= not ex1_y     ; 
    u_aop_slow00: ex1_aop_00 <= not ex1_x_b(msb);                               
    u_aop_slow32: ex1_aop_32 <= not ex1_x_b(32) ;                               
    u_bop_slow00: ex1_bop_00 <= not ex1_y_b(msb);                               
    u_bop_slow32: ex1_bop_32 <= not ex1_y_b(32) ;                               


    csa: entity work.xuq_add(xuq_add)
    port map(
         x_b(0 to 63)           => ex1_x_b,
         y_b(0 to 63)           => ex1_y_b,
         ci(8)                  => ex1_add_ci_q,
         sum(0 to 63)           => ex1_add_rslt,
         cout_32                => ex1_cout_32,
         cout_0                 => ex1_cout_00);

    ex1_sgn00_32 <= not ex1_select_64bmode_q and not ex1_aop_32 and not ex1_bop_32  ; 
    ex1_sgn11_32 <= not ex1_select_64bmode_q and     ex1_aop_32 and     ex1_bop_32  ; 
    ex1_sgn00_64 <=     ex1_select_64bmode_q and not ex1_aop_00 and not ex1_bop_00  ; 
    ex1_sgn11_64 <=     ex1_select_64bmode_q and     ex1_aop_00 and     ex1_bop_00  ; 

    ex1_ovf32_00_b <= not(     ex1_add_rslt(32)  and ex1_sgn00_32 ); 
    ex1_ovf32_11_b <= not( not ex1_add_rslt(32)  and ex1_sgn11_32 ); 
    ex1_ovf64_00_b <= not(     ex1_add_rslt(msb) and ex1_sgn00_64 ); 
    ex1_ovf64_11_b <= not( not ex1_add_rslt(msb) and ex1_sgn11_64 ); 

    ex1_overflow <= not ( ex1_ovf64_00_b and
                          ex1_ovf64_11_b and
                          ex1_ovf32_00_b and
                          ex1_ovf32_11_b  );


                           
    ex2_add_xer_ov      <= ex2_overflow_q;

    
    
add_64b_compare : if regsize = 64 generate

   or3232: entity work.xuq_alu_or3232(xuq_alu_or3232)    
      generic map (expand_type => expand_type)   
      port map(
         d        => log_add_ex2_rt(0 to 63) ,
         or_hi_b  => ex2_cmp0_hi           ,
         or_lo_b  => ex2_cmp0_lo          );

     ex2_cmp0_eq  <= (ex2_cmp0_hi or ex2_select_32bcmp_q) and   ex2_cmp0_lo;

    with ex1_select_32bcmp select
        ex2_rs0_msb_d   <= byp_alu_ex1_rs0(32)      when '1',
                           byp_alu_ex1_rs0(0)       when others;
    with ex1_select_32bcmp select
        ex2_rs1_msb_d   <= byp_alu_ex1_rs1(32)      when '1',
                           byp_alu_ex1_rs1(0)       when others;
    with ex2_select_32bcmp_q select
        ex2_rt_msb      <= log_add_ex2_rt(32)       when '1',
                           log_add_ex2_rt(0)        when others;
end generate;


   u_ex2_rt_bufi: alu_byp_ex2_rt_b <= not log_add_ex2_rt   ;
   u_ex2_rt_buf:  alu_byp_ex2_rt   <= not alu_byp_ex2_rt_b ;

add_32b_compare : if regsize = 32 generate
    ex2_cmp0_lo         <= not or_reduce(log_add_ex2_rt(32  to 63));
    ex2_cmp0_hi         <= '1';
    ex2_cmp0_eq         <= ex2_cmp0_lo;
    ex2_rs0_msb_d       <= byp_alu_ex1_rs0(32);
    ex2_rs1_msb_d       <= byp_alu_ex1_rs1(32);
    ex2_rt_msb          <= log_add_ex2_rt(32);
end generate;

    ex2_diff_sign  <= (ex2_rs0_msb_q xor ex2_rs1_msb_q) and ex2_is_cmp_q;

    with ex2_is_cmp_q select
        ex2_sign_cmp    <= ex2_add_xer_ca_q         when '1',       
                           ex2_rt_msb               when others;    

    ex2_rslt_gt_s       <= ((ex2_rs1_msb_q and ex2_diff_sign) or (not ex2_sign_cmp and not ex2_diff_sign)) and not ex2_cmp0_eq;    
    ex2_rslt_lt_s       <= ((ex2_rs0_msb_q and ex2_diff_sign) or (    ex2_sign_cmp and not ex2_diff_sign)) and not ex2_cmp0_eq;    

    ex2_rslt_gt_u       <= ((ex2_rs0_msb_q and ex2_diff_sign) or (not ex2_sign_cmp and not ex2_diff_sign)) and not ex2_cmp0_eq;    
    ex2_rslt_lt_u       <= ((ex2_rs1_msb_q and ex2_diff_sign) or (    ex2_sign_cmp and not ex2_diff_sign)) and not ex2_cmp0_eq;    

    ex2_cmp_eq          <= ex2_cmp0_eq;
    ex2_cmp_gt          <= (not ex2_is_cmpl_q and ex2_rslt_gt_s) or (ex2_is_cmpl_q and ex2_rslt_gt_u);
    ex2_cmp_lt          <= (not ex2_is_cmpl_q and ex2_rslt_lt_s) or (ex2_is_cmpl_q and ex2_rslt_lt_u);

    ex2_cr_recform      <= ex2_cmp_lt & ex2_cmp_gt & ex2_cmp_eq & ex2_overflow_q;

    ex3_trap_val_d      <=  ex2_tw_cmpsel_q(0) and (
                           (ex2_tw_cmpsel_q(1) and ex2_rslt_lt_s) or
                           (ex2_tw_cmpsel_q(2) and ex2_rslt_gt_s) or
                           (ex2_tw_cmpsel_q(3) and ex2_cmp_eq)    or
                           (ex2_tw_cmpsel_q(4) and ex2_rslt_lt_u) or
                           (ex2_tw_cmpsel_q(5) and ex2_rslt_gt_u));

    ex3_trap_val        <= ex3_trap_val_q;

    with ex1_select_32bcmp select
        ex2_add_xer_ca_d    <= ex1_cout_32                  when '1',
                               ex1_cout_00                  when others;

    ex2_add_xer_ca      <= ex2_add_xer_ca_q;

add_64b_retval : if regsize = 64 generate
    add_log_ex1_add_rt  <=  ex1_add_rslt;
    ex2_eff_addr_d      <= (ex1_add_rslt(0 to 31) and (0 to 31 => ex1_select_64bmode_q)) & ex1_add_rslt(32 to 63);
end generate;
add_32b_retval : if regsize = 32 generate
    add_log_ex1_add_rt  <= ex1_add_rslt(32 to 63);
    ex2_eff_addr_d      <= ex1_add_rslt(32 to 63);
end generate;

    u_eff0_inv1: eff0_b <= not byp_alu_ex1_rs0(64-(dc_size-3) to 63) ;
    u_eff0_inv2: eff0   <= not eff0_b ;                               
    u_eff1_inv1: eff1_b <= not byp_alu_ex1_rs1(64-(dc_size-3) to 63) ;
    u_eff1_inv2: eff1   <= not eff1_b ;                               

    xu_ex1_eff_addr_int <= std_ulogic_vector( unsigned(eff0) +  unsigned(eff1) ); 
    
    xu_ex2_eff_addr     <= ex2_eff_addr_q;

    ex1_add_act_latch : tri_rlmlatch_p
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
                  scin          => siv(ex1_add_act_offset),
                  scout         => sov(ex1_add_act_offset),
                  din           => dec_alu_rf1_add_act,
                  dout          => ex1_add_act_q);
    ex1_add_ci_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => dec_alu_rf1_add_act,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_add_ci_offset),
                  scout         => sov(ex1_add_ci_offset),
                  din           => dec_alu_rf1_add_ci,
                  dout          => ex1_add_ci_q);
    ex1_is_cmpl_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => dec_alu_rf1_add_act,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_is_cmpl_offset),
                  scout         => sov(ex1_is_cmpl_offset),
                  din           => dec_alu_rf1_is_cmpl,
                  dout          => ex1_is_cmpl_q);
    ex1_tw_cmpsel_latch : tri_rlmreg_p
        generic map (width => ex1_tw_cmpsel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => dec_alu_rf1_add_act,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex1_tw_cmpsel_offset to ex1_tw_cmpsel_offset + ex1_tw_cmpsel_q'length-1),
                  scout         => sov(ex1_tw_cmpsel_offset to ex1_tw_cmpsel_offset + ex1_tw_cmpsel_q'length-1),
                  din           => dec_alu_rf1_tw_cmpsel,
                  dout          => ex1_tw_cmpsel_q);
    ex2_add_xer_ca_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk          => nclk,
                  vd            => vdd,
                  gd            => gnd,
                  act           => ex1_add_act_q,
                  forcee => func_sl_force,
                  d_mode        => d_mode_dc,
                  delay_lclkr   => delay_lclkr_dc,
                  mpw1_b        => mpw1_dc_b,
                  mpw2_b        => mpw2_dc_b,
                  thold_b       => func_sl_thold_0_b,
                  sg            => sg_0,
                  scin          => siv(ex2_add_xer_ca_offset),
                  scout         => sov(ex2_add_xer_ca_offset),
                  din           => ex2_add_xer_ca_d,
                  dout          => ex2_add_xer_ca_q);
    ex2_rs0_msb_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_rs0_msb_offset),
                  scout         => sov(ex2_rs0_msb_offset),
                  din           => ex2_rs0_msb_d,
                  dout          => ex2_rs0_msb_q);
    ex2_rs1_msb_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_rs1_msb_offset),
                  scout         => sov(ex2_rs1_msb_offset),
                  din           => ex2_rs1_msb_d,
                  dout          => ex2_rs1_msb_q);
    ex2_is_cmpl_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_is_cmpl_offset),
                  scout         => sov(ex2_is_cmpl_offset),
                  din           => ex1_is_cmpl_q,
                  dout          => ex2_is_cmpl_q);
    ex2_overflow_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_overflow_offset),
                  scout         => sov(ex2_overflow_offset),
                  din           => ex1_overflow,
                  dout          => ex2_overflow_q);
    ex2_tw_cmpsel_latch : tri_rlmreg_p
        generic map (width => ex2_tw_cmpsel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex2_tw_cmpsel_offset to ex2_tw_cmpsel_offset + ex2_tw_cmpsel_q'length-1),
                  scout         => sov(ex2_tw_cmpsel_offset to ex2_tw_cmpsel_offset + ex2_tw_cmpsel_q'length-1),
                  din           => ex1_tw_cmpsel_q,
                  dout          => ex2_tw_cmpsel_q);
    ex2_is_cmp_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_is_cmp_offset),
                  scout         => sov(ex2_is_cmp_offset),
                  din           => dec_alu_ex1_is_cmp,
                  dout          => ex2_is_cmp_q);
    ex3_trap_val_latch : tri_rlmlatch_p
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
                  scin          => siv(ex3_trap_val_offset),
                  scout         => sov(ex3_trap_val_offset),
                  din           => ex3_trap_val_d,
                  dout          => ex3_trap_val_q);
      ex1_select_64bmode_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk    => nclk, vd => vdd, gd => gnd,
                  act     => tiup,
                  forcee => func_sl_force,
                  d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
                  mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
                  thold_b => func_sl_thold_0_b,
                  sg      => sg_0,
                  scin    => siv(ex1_select_64bmode_offset),
                  scout   => sov(ex1_select_64bmode_offset),
                  din     => dec_alu_rf1_select_64bmode,
                  dout    => ex1_select_64bmode_q);
      ex2_select_32bcmp_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk    => nclk, vd => vdd, gd => gnd,
                  act     => tiup,
                  forcee => func_sl_force,
                  d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
                  mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
                  thold_b => func_sl_thold_0_b,
                  sg      => sg_0,
                  scin    => siv(ex2_select_32bcmp_offset),
                  scout   => sov(ex2_select_32bcmp_offset),
                  din     => ex1_select_32bcmp,
                  dout    => ex2_select_32bcmp_q);



ex2_lcb: entity tri.tri_lcbnd(tri_lcbnd)          
   port map(vd          => vdd,                   
            gd          => gnd,                   
            act         => ex1_add_act_q,         
            nclk        => nclk,                  
            forcee => func_sl_force,         
            thold_b     => func_sl_thold_0_b,     
            delay_lclkr => delay_lclkr_dc,        
            mpw1_b      => mpw1_dc_b,             
            mpw2_b      => mpw2_dc_b,             
            sg          => sg_0,                  
            lclk        => ex2_lclk_int,          
            d1clk       => ex2_d1clk_int,         
            d2clk       => ex2_d2clk_int);        

ex1_lcb: entity tri.tri_lcbnd(tri_lcbnd)          
   port map(vd          => vdd,                   
            gd          => gnd,                   
            act         => dec_alu_rf1_add_act,   
            nclk        => nclk,                  
            forcee => func_sl_force,         
            thold_b     => func_sl_thold_0_b,     
            delay_lclkr => delay_lclkr_dc,        
            mpw1_b      => mpw1_dc_b,             
            mpw2_b      => mpw2_dc_b,             
            sg          => sg_0,                  
            lclk        => ex1_lclk_int,          
            d1clk       => ex1_d1clk_int,         
            d2clk       => ex1_d2clk_int);        


 ex2_eff_addr_lat: entity tri.tri_inv_nlats(tri_inv_nlats)                                                
     generic map (width => ex2_eff_addr_q'length, expand_type => expand_type, btr => "NLI0001_X1_A12TH", init=>(ex2_eff_addr_q'range=>'0'))  
     port map (vd => vdd, gd => gnd,                                                                      
               LCLK    => ex2_lclk_int,                                                                   
               D1CLK   => ex2_d1clk_int,                                                                  
               D2CLK   => ex2_d2clk_int,                                                                  
               SCANIN  => siv(ex2_eff_addr_offset to ex2_eff_addr_offset + ex2_eff_addr_q'length-1),      
               SCANOUT => sov(ex2_eff_addr_offset to ex2_eff_addr_offset + ex2_eff_addr_q'length-1),      
               D       => ex2_eff_addr_d,                                                                 
               QB      => ex2_eff_addr_q_b );                                                             

  u_ex2_eff_addr_q: ex2_eff_addr_q <= not ex2_eff_addr_q_b ;

 ex1_rs0_inv_lat: entity tri.tri_inv_nlats(tri_inv_nlats)                                                
     generic map (width => ex1_rs0_inv_q'length, expand_type => expand_type, btr => "NLI0001_X1_A12TH", init=>(ex1_rs0_inv_q'range=>'0')) 
     port map (vd => vdd, gd => gnd,                                                                    
               LCLK    => ex1_lclk_int,                                                                 
               D1CLK   => ex1_d1clk_int,                                                                
               D2CLK   => ex1_d2clk_int,                                                                
               SCANIN  => siv(ex1_rs0_inv_offset to ex1_rs0_inv_offset + ex1_rs0_inv_q'length-1),       
               SCANOUT => sov(ex1_rs0_inv_offset to ex1_rs0_inv_offset + ex1_rs0_inv_q'length-1),       
               D       => dec_alu_rf1_add_rs0_inv,                                                      
               QB      => ex1_rs0_inv_q_b );                                                             

  u_ex1_rs0_inv_q:  ex1_rs0_inv_q  <= not ex1_rs0_inv_q_b  ;



    siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in;
    scan_out <= sov(0);

end architecture xuq_alu_add;
