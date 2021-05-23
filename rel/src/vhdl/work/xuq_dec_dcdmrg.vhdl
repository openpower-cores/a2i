-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


LIBRARY work ;
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

entity xuq_dec_dcdmrg is
    port (
        i                                   : in  std_ulogic_vector(0 to 31);
        dec_alu_rf1_sel_rot_log             : out std_ulogic;
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
        dec_alu_rf1_mb_gt_me                : out std_ulogic
    );
-- synopsys translate_off
-- synopsys translate_on

end xuq_dec_dcdmrg;

architecture xuq_dec_dcdmrg of xuq_dec_dcdmrg is
    constant tiup                   : std_ulogic := '1';
    constant tidn                   : std_ulogic := '0';

    signal cmp_byt                  : std_ulogic;
    signal cr_log                   : std_ulogic;
    signal rotlw                    : std_ulogic;
    signal imm_log                  : std_ulogic;
    signal rotld                    : std_ulogic;
    signal x31                      : std_ulogic;
    signal f0_xxxx00                : std_ulogic;
    signal f0_xxx0xx                : std_ulogic;
    signal f0_xxxx0x                : std_ulogic;
    signal f1_1xxxx                 : std_ulogic;
    signal f1_111xx                 : std_ulogic;
    signal f1_110xx                 : std_ulogic;
    signal f1_x1x1x                 : std_ulogic;
    signal f1_x1xx0                 : std_ulogic;
    signal f1_x1xx1                 : std_ulogic;
    signal f1_xxx00                 : std_ulogic;
    signal f1_xxx11                 : std_ulogic;
    signal f1_xx10x                 : std_ulogic;
    signal f2_11xxx                 : std_ulogic;
    signal f2_xxx0x                 : std_ulogic;
    signal f2_111xx                 : std_ulogic;
    signal f1_xxx01                 : std_ulogic;
    signal f1_xxx10                 : std_ulogic;
    signal f2_xx01x                 : std_ulogic;
    signal f2_xx00x                 : std_ulogic;
    signal rotlw_nm                 : std_ulogic;
    signal rotlw_pass               : std_ulogic;
    signal rotld_pass               : std_ulogic;
    signal sh_lft_rb                : std_ulogic;
    signal sh_lft_rb_dw             : std_ulogic;
    signal sh_rgt                   : std_ulogic;
    signal sh_rgt_rb                : std_ulogic;
    signal sh_rgt_rb_dw             : std_ulogic;
    signal shift_imm                : std_ulogic;
    signal sh_rb                    : std_ulogic;
    signal sh_rb_dw                 : std_ulogic;
    signal sh_rb_wd                 : std_ulogic;
    signal x31_sh_log_sgn           : std_ulogic;
    signal op_sgn_xtd               : std_ulogic;
    signal op_sra                   : std_ulogic;
    signal wd_if_sh                 : std_ulogic;
    signal xtd_log                  : std_ulogic;
    signal sh_word_int              : std_ulogic;
    signal imm_xor_or               : std_ulogic;
    signal imm_and_or               : std_ulogic;
    signal xtd_nor                  : std_ulogic;
    signal xtd_eqv_orc_nand         : std_ulogic;
    signal xtd_nand                 : std_ulogic;
    signal xtd_andc_xor_or          : std_ulogic;
    signal xtd_and_eqv_orc          : std_ulogic;
    signal xtd_or_orc               : std_ulogic;
    signal xtd_xor_or               : std_ulogic;
    signal sel_ins_amt_hi           : std_ulogic;
    signal sel_ins_me_lo_wd         : std_ulogic;
    signal sel_ins_me_lo_dw         : std_ulogic;
    signal sel_ins_amt_lo           : std_ulogic;
    signal sel_ins_me_hi            : std_ulogic;
    signal rot_imm_mb               : std_ulogic;
    signal gt5_g_45                 : std_ulogic;
    signal gt5_g_23                 : std_ulogic;
    signal gt5_g_1                  : std_ulogic;
    signal gt5_t_23                 : std_ulogic;
    signal gt5_t_1                  : std_ulogic;
    signal mb_gt_me_cmp_wd0_b       : std_ulogic;
    signal mb_gt_me_cmp_wd1_b       : std_ulogic;
    signal mb_gt_me_cmp_wd2_b       : std_ulogic;
    signal mb_gt_me_cmp_wd          : std_ulogic;
    signal gt6_g_45                 : std_ulogic;
    signal gt6_g_23                 : std_ulogic;
    signal gt6_g_01                 : std_ulogic;
    signal gt6_t_23                 : std_ulogic;
    signal gt6_t_01                 : std_ulogic;
    signal mb_gt_me_cmp_dw0_b       : std_ulogic;
    signal mb_gt_me_cmp_dw1_b       : std_ulogic;
    signal mb_gt_me_cmp_dw2_b       : std_ulogic;
    signal mb_gt_me_cmp_dw          : std_ulogic;
    signal me_ins                   : std_ulogic_vector(0 to 5);
    signal gt5_in0                  : std_ulogic_vector(1 to 5);
    signal gt5_in1                  : std_ulogic_vector(1 to 5);
    signal gt6_in0                  : std_ulogic_vector(0 to 5);
    signal gt6_in1                  : std_ulogic_vector(0 to 5);
    signal gt5_g_b                  : std_ulogic_vector(1 to 5);
    signal gt5_t_b                  : std_ulogic_vector(1 to 4);
    signal gt6_g_b                  : std_ulogic_vector(0 to 5);
    signal gt6_t_b                  : std_ulogic_vector(0 to 4);
    signal f0_xxxx11                : std_ulogic;
    signal f1_0xxxx                 : std_ulogic;
    signal f1_1xxx0                 : std_ulogic;
    signal f1_xxxx0                 : std_ulogic;
    signal f1_xxxx1                 : std_ulogic;
    signal f2_xxx1x                 : std_ulogic;
    signal f1_xx1xx                 : std_ulogic;
    signal xtd_nand_or_orc          : std_ulogic;
    signal rld_cr                   : std_ulogic;
    signal rld_cl                   : std_ulogic;
    signal rld_icr                  : std_ulogic;
    signal rld_icl                  : std_ulogic;
    signal rld_ic                   : std_ulogic;
    signal rld_imi                  : std_ulogic;
    signal sh_lft_imm_dw            : std_ulogic;
    signal sh_lft_imm               : std_ulogic;
    signal sh_rgt_imm_dw            : std_ulogic;
    signal sh_rgt_imm               : std_ulogic;
    signal rotld_en_mbgtme          : std_ulogic;
    signal rf1_log_fcn              : std_ulogic_vector(0 to 3);
    signal isel                     : std_ulogic;

begin

    ----------------------------------------------------
    -- decode primary field opcode bits [0:5]        ---
    ----------------------------------------------------
    isel                        <= '1' when x31='1' and i(26 to 30) = "01111" else '0';

    cmp_byt                     <= '1' when x31='1' and i(21 to 30) = "0111111100" else '0';   -- 31/508

    cr_log                      <=  not i(0) and     i(1) and not i(2) and  not i(3) and     i(4) and     i(5) ;    --010011 (19)
    rotlw                       <=  not i(0) and     i(1) and not i(2) and      i(3)                           ;    --0101xx (20:23)
    imm_log                     <=  not i(0) and     i(1) and     i(2) and (not i(3) or  not i(4)             );    --0110xx (24:27)
                                                                                                                    --01110x (28,29)
    rotld                       <=  not i(0) and     i(1) and     i(2) and      i(3) and     i(4) and not i(5) ;    --011110 (30)
    x31                         <=  not i(0) and     i(1) and     i(2) and      i(3) and     i(4) and     i(5) ;    --011111 (31)

    f0_xxxx00                   <=                                                       not i(4) and not i(5) ;
    f0_xxx0xx                   <=                                          not i(3)                           ;
    f0_xxxx0x                   <=                                                       not i(4)              ;
    f0_xxxx11                   <=                                                           i(4) and     i(5) ;


    -----------------------------------------------------
    -- decode i(21:25)
    -----------------------------------------------------

    f1_0xxxx                    <= not i(21)                                                      ;
    f1_110xx                    <=     i(21) and i(22) and not i(23)                              ;
    f1_111xx                    <=     i(21) and i(22) and     i(23)                              ;
    f1_1xxx0                    <=     i(21) and                                        not i(25) ;
    f1_1xxxx                    <=     i(21)                                                      ;
    f1_x1x1x                    <=               i(22)  and                   i(24)               ;
    f1_xx1xx                    <=                              i(23)                             ;
    f1_x1xx0                    <=               i(22)  and                             not i(25) ;
    f1_x1xx1                    <=               i(22)  and                                 i(25) ;
    f1_xx10x                    <=                              i(23) and not i(24)               ;
    f1_xxx01                    <=                                        not i(24) and     i(25) ;
    f1_xxx11                    <=                                            i(24) and     i(25) ;
    f1_xxxx0                    <=                                                      not i(25) ;
    f1_xxxx1                    <=                                                          i(25) ;
    f1_xxx00                    <=                                        not i(24) and not i(25) ;
    f1_xxx10                    <=                                            i(24) and not i(25) ;

    -----------------------------------------------------
    -- decode i(26:30)
    -----------------------------------------------------

    f2_11xxx                    <= i(26) and     i(27)                                           ; -- shifts / logicals / sign_xtd
    f2_xxx0x                    <=                                       not i(29)               ; -- word / double
    f2_111xx                    <= i(26) and     i(27) and     i(28)                             ;
    f2_xx01x                    <=                         not i(28) and     i(29)               ;
    f2_xx00x                    <=                         not i(28) and not i(29)               ;
    f2_xxx1x                    <=                                           i(29)               ;


    rotlw_nm                    <= rotlw and f0_xxxx11 ;
    rotlw_pass                  <= rotlw   and f0_xxxx00 ;

    rotld_pass                  <= rld_imi  ;

    sh_lft_rb                   <= x31 and f1_0xxxx ;
    sh_lft_rb_dw                <= x31 and f1_0xxxx and f2_xxx1x ;
    sh_rgt                      <= x31 and f1_1xxxx ;
    sh_rgt_rb                   <= x31 and f1_1xxx0 ;
    sh_rgt_rb_dw                <= x31 and f1_1xxx0 and f2_xxx1x ;
    shift_imm                   <= x31 and f1_xxxx1 ;
    sh_rb                       <= x31 and f1_xxxx0 ;
    sh_rb_dw                    <= x31 and f1_xxxx0 and f2_xxx1x ;
    sh_rb_wd                    <= x31 and f1_xxxx0 and f2_xxx0x ;
    x31_sh_log_sgn              <= x31 and f2_11xxx ;
    op_sgn_xtd                  <= x31 and f1_111xx ;
    op_sra                      <= x31 and f1_110xx ;
    wd_if_sh                    <= x31 and f2_xxx0x ;
    xtd_log                     <= x31 and f2_111xx ;

    sh_lft_imm_dw               <= tidn;
    sh_lft_imm                  <= tidn;
    sh_rgt_imm_dw               <= x31 and i(21) and i(25) and i(29) ;
    sh_rgt_imm                  <= x31 and i(21) and i(25) ;

    -----------------------------------------------------
    -- output signal
    -----------------------------------------------------

    -- (select to rot/log result instead of the adder result)
    dec_alu_rf1_sel_rot_log     <= (cmp_byt  ) or
                                   (cr_log   ) or
                                   (rotlw    ) or
                                   (imm_log  ) or
                                   (rotld    ) or
                                   (x31_sh_log_sgn );

    -- (zero out the mask to pass "insert_data" as the result)
    dec_alu_rf1_zm_ins          <= (isel       ) or
                                   (cmp_byt    ) or
                                   (cr_log     ) or
                                   (xtd_log    ) or
                                   (imm_log    ) or
                                   (op_sgn_xtd ); -- sgn extends

    -- (only needs to be correct when shifting)
    dec_alu_rf1_sh_right         <= sh_rgt;

    sh_word_int                 <=(rotlw ) or
                                  (wd_if_sh );

    -- (only needs to be correct when shifting)
    dec_alu_rf1_sh_word                     <=  sh_word_int ;
    dec_alu_rf1_cr_logical                  <= cr_log ;

    dec_alu_rf1_sgnxtd_byte                 <= op_sgn_xtd and f1_xxx01 and not isel;
    dec_alu_rf1_sgnxtd_half                 <= op_sgn_xtd and f1_xxx00 and not isel;
    dec_alu_rf1_sgnxtd_wd                   <= op_sgn_xtd and f1_xxx10 and not isel;
    dec_alu_rf1_sra_dw                      <= op_sra     and f2_xx01x and not isel;
    dec_alu_rf1_sra_wd                      <= op_sra     and f2_xx00x and not isel;

    dec_alu_rf1_cr_log_fcn(0)               <= i(25) ;
    dec_alu_rf1_cr_log_fcn(1)               <= i(24) ;
    dec_alu_rf1_cr_log_fcn(2)               <= i(23) ;
    dec_alu_rf1_cr_log_fcn(3)               <= i(22) ;

    imm_xor_or                  <= f0_xxx0xx ;
    imm_and_or                  <= f0_xxxx0x ;
    xtd_nor                     <= f1_xxx11 ;
    xtd_eqv_orc_nand            <= f1_x1xx0 ;
    xtd_nand                    <= f1_x1x1x ;
    xtd_nand_or_orc             <= f1_xx1xx ;
    xtd_andc_xor_or             <= f1_xxx01 ;
    xtd_and_eqv_orc             <= f1_xxx00 ;
    xtd_or_orc                  <= f1_xx10x ;
    xtd_xor_or                  <= f1_x1xx1 ;


    with cmp_byt select
      dec_alu_rf1_log_fcn  <= "1001"            when '1',
                              rf1_log_fcn       when others;


    rf1_log_fcn(0)      <= (xtd_log and xtd_nor           ) or -- xtd_log nor
                           (xtd_log and xtd_eqv_orc_nand  ) or -- xtd_log eqv,orc,nand
                           (cmp_byt                       )  ; -- xnor

    rf1_log_fcn(1)      <= (xtd_log and xtd_xor_or        ) or -- xtd_log xor,or
                           (xtd_log and xtd_nand          ) or -- xtd_log nand
                           (imm_log and imm_xor_or        ) or -- xor,or
                           (rotlw_pass                    ) or -- pass  rlwimi
                           (rotld_pass                    )  ; -- pass  rldimi

    rf1_log_fcn(2)      <= (xtd_log and xtd_andc_xor_or   ) or -- xtd_log andc,xor,or
                           (xtd_log and xtd_nand_or_orc   ) or -- xtd_log nand_or_orc
                           (imm_log and imm_xor_or        )  ; -- xor,or


    rf1_log_fcn(3)      <= (cmp_byt                       ) or -- xnor
                           (xtd_log and xtd_and_eqv_orc   ) or -- xtd_log and,eqv_orc
                           (xtd_log and xtd_or_orc        ) or -- xtd_log or,orc
                           (imm_log and imm_and_or        ) or -- and,or
                           (rotlw_pass                    ) or -- pass  rlwimi
                           (rotld_pass                    )  ; -- pass  rldimi


    dec_alu_rf1_chk_shov_dw                 <= (sh_rb_dw );
    dec_alu_rf1_chk_shov_wd                 <= (sh_rb_wd );


    -----------------------------------------------

    dec_alu_rf1_me_ins_b(0 to 5)            <= not me_ins(0 to 5) ;

    me_ins(0)                   <= ( rotlw                        ) or -- force_msb
                                   (     i(26) and sel_ins_me_hi  ) or
                                   ( not i(30) and sel_ins_amt_hi ) ;

    me_ins(1 to 5)              <= (     i(26 to 30) and (1 to 5=> sel_ins_me_lo_wd) ) or
                                   (     i(21 to 25) and (1 to 5=> sel_ins_me_lo_dw) ) or
                                   ( not i(16 to 20) and (1 to 5=> sel_ins_amt_lo  ) )  ;

    sel_ins_me_lo_wd            <= rotlw ;
    sel_ins_me_lo_dw            <= rld_cr or rld_icr ;

    sel_ins_amt_lo              <= rld_ic or rld_imi or sh_lft_rb ;
    sel_ins_amt_hi              <= rld_ic or rld_imi or sh_lft_rb_dw ;
    sel_ins_me_hi               <= rld_cr or rld_icr ;


    dec_alu_rf1_use_me_rb_hi                <= ( sh_lft_rb_dw );
    dec_alu_rf1_use_me_rb_lo                <= ( sh_lft_rb    );

    dec_alu_rf1_use_me_ins_hi               <= rld_cr or rld_icr or rld_imi or rld_ic or rotlw or sh_lft_imm_dw ;
    dec_alu_rf1_use_me_ins_lo               <= rld_cr or rld_icr or rld_imi or rld_ic or rotlw or sh_lft_imm    ;

    rld_icl                     <= rotld and not i(27) and not i(28) and not i(29) ;
    rld_icr                     <= rotld and not i(27) and not i(28) and     i(29) ;
    rld_ic                      <= rotld and not i(27) and     i(28) and not i(29) ;
    rld_imi                     <= rotld and not i(27) and     i(28) and     i(29) ;
    rld_cl                      <= rotld and     i(27)                             and not i(30);
    rld_cr                      <= rotld and     i(27)                             and     i(30);


    -----------------------------------------------

    dec_alu_rf1_mb_ins(0)       <= ( i(26) and rot_imm_mb   ) or
                                   ( i(30) and shift_imm ) or
                                   ( rotlw               ) or -- force_msb
                                   ( wd_if_sh            ) ;  -- force_msb


    dec_alu_rf1_mb_ins(1 to 5)  <= ( i(21 to 25) and (1 to 5=> rot_imm_mb   ) ) or
                                   ( i(16 to 20) and (1 to 5=> shift_imm ) )  ;


    rot_imm_mb                  <= ( rotlw              ) or
                                   ( rld_cl or rld_icl or rld_ic or rld_imi  ) ;


    dec_alu_rf1_use_mb_rb_lo                <= sh_rgt_rb     ;
    dec_alu_rf1_use_mb_rb_hi                <= sh_rgt_rb_dw  ;
   dec_alu_rf1_use_mb_ins_hi               <=  rld_cl or rld_icl or rld_imi or rld_ic or rotlw or sh_rgt_imm_dw or wd_if_sh;
   dec_alu_rf1_use_mb_ins_lo               <=  rld_cl or rld_icl or rld_imi or rld_ic or rotlw or sh_rgt_imm    ;


    -----------------------------------------------

    dec_alu_rf1_use_rb_amt_hi   <= ( rld_cr    ) or
                                   ( rld_cl    ) or
                                   ( sh_rb_dw  )  ;



    dec_alu_rf1_use_rb_amt_lo   <= ( rld_cr    ) or
                                   ( rld_cl    ) or
                                   ( rotlw_nm  ) or -- rlwnm
                                   ( sh_rb     )  ;



    dec_alu_rf1_sh_amt(0)                   <= i(30) and not sh_word_int   ;
    dec_alu_rf1_sh_amt(1 to 5)              <= i(16 to 20)                 ;

    -----------------------------------------------


    rotld_en_mbgtme             <= rld_imi or rld_ic ;

    dec_alu_rf1_mb_gt_me                    <= (mb_gt_me_cmp_wd and rotlw    ) or
                                   (mb_gt_me_cmp_dw and rotld_en_mbgtme ) ; -- rldic,rldimi



    ---------------------------------------------

    gt5_in1(1 to 5)             <=                 i(21 to 25) ; -- mb
    gt5_in0(1 to 5)             <=             not i(26 to 30) ; -- me

    gt6_in1(0 to 5)             <=     i(26) &     i(21 to 25) ; -- mb
    gt6_in0(0 to 5)             <=     i(30) &     i(16 to 20) ; -- me not( not amt )

    --------------------------------------------

    gt5_g_b(1 to 5)             <= not( gt5_in0(1 to 5) and gt5_in1(1 to 5) );
    gt5_t_b(1 to 4)             <= not( gt5_in0(1 to 4) or  gt5_in1(1 to 4) );

    gt5_g_45                    <= not( gt5_g_b(4) and (gt5_t_b(4) or gt5_g_b(5) ) );
    gt5_g_23                    <= not( gt5_g_b(2) and (gt5_t_b(2) or gt5_g_b(3) ) );
    gt5_g_1                     <= not( gt5_g_b(1) );

    gt5_t_23                    <= not( gt5_t_b(2) or gt5_t_b(3) );
    gt5_t_1                     <= not( gt5_t_b(1) );

    mb_gt_me_cmp_wd0_b          <= not( gt5_g_1  );
    mb_gt_me_cmp_wd1_b          <= not( gt5_g_23 and  gt5_t_1 );
    mb_gt_me_cmp_wd2_b          <= not( gt5_g_45 and  gt5_t_1 and gt5_t_23 );

    mb_gt_me_cmp_wd             <= not( mb_gt_me_cmp_wd0_b and mb_gt_me_cmp_wd1_b and mb_gt_me_cmp_wd2_b );

    ----------------------------------------------

    gt6_g_b(0 to 5)             <= not( gt6_in0(0 to 5) and gt6_in1(0 to 5) );
    gt6_t_b(0 to 4)             <= not( gt6_in0(0 to 4) or  gt6_in1(0 to 4) );

    gt6_g_45                    <= not( gt6_g_b(4) and (gt6_t_b(4) or gt6_g_b(5) ) );
    gt6_g_23                    <= not( gt6_g_b(2) and (gt6_t_b(2) or gt6_g_b(3) ) );
    gt6_g_01                    <= not( gt6_g_b(0) and (gt6_t_b(0) or gt6_g_b(1) ) );

    gt6_t_23                    <= not( gt6_t_b(2) or gt6_t_b(3) );
    gt6_t_01                    <= not( gt6_t_b(0) or gt6_t_b(1) );

    mb_gt_me_cmp_dw0_b          <= not( gt6_g_01  );
    mb_gt_me_cmp_dw1_b          <= not( gt6_g_23 and  gt6_t_01 );
    mb_gt_me_cmp_dw2_b          <= not( gt6_g_45 and  gt6_t_01 and gt6_t_23 );

    mb_gt_me_cmp_dw             <= not( mb_gt_me_cmp_dw0_b and mb_gt_me_cmp_dw1_b and mb_gt_me_cmp_dw2_b );

    ----------------------------------------------
    
    mark_unused(i(6 to 15));
    mark_unused(i(31));


end architecture xuq_dec_dcdmrg;
