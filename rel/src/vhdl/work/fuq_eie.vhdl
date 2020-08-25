-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

   

library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 


-- assuming the operand latches are in here, does not need to be true.

-- is1
-- is2
-- rf0
-- rf1
-- ex1  <== this macro
-- ex2  <== this macro
-- ex3  <== this macro

 
entity fuq_eie is 
generic(  expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port( 

       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic_vector(2 to 3); -- tidn,
       mpw1_b                                    :in   std_ulogic_vector(2 to 3); -- tidn,
       mpw2_b                                    :in   std_ulogic_vector(0 to 0); -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;

       f_eie_si                                  :in   std_ulogic                    ;-- perv
       f_eie_so                                  :out  std_ulogic                    ;-- perv
       ex1_act                                   :in   std_ulogic                    ;-- act

       f_byp_eie_ex1_a_expo                      :in   std_ulogic_vector(1 to 13)    ;
       f_byp_eie_ex1_c_expo                      :in   std_ulogic_vector(1 to 13)    ;
       f_byp_eie_ex1_b_expo                      :in   std_ulogic_vector(1 to 13)    ;

       f_pic_ex1_from_integer                    :in   std_ulogic                    ;
       f_pic_ex1_fsel                            :in   std_ulogic                    ;
       f_pic_ex2_frsp_ue1                        :in   std_ulogic                    ;

       f_alg_ex2_sel_byp                         :in   std_ulogic                    ;
       f_fmt_ex2_fsel_bsel                       :in   std_ulogic                    ;
       f_pic_ex2_force_sel_bexp                  :in   std_ulogic                    ;
       f_pic_ex2_sp_b                            :in   std_ulogic                    ;
       f_pic_ex2_math_bzer_b                     :in   std_ulogic                    ;

       f_eie_ex2_tbl_expo                        :out  std_ulogic_vector(1 to 13)    ;

       f_eie_ex2_lt_bias                         :out  std_ulogic                    ; --f_pic
       f_eie_ex2_eq_bias_m1                      :out  std_ulogic                    ; --f_pic
       f_eie_ex2_wd_ov                           :out  std_ulogic                    ; --f_pic
       f_eie_ex2_dw_ov                           :out  std_ulogic                    ; --f_pic
       f_eie_ex2_wd_ov_if                        :out  std_ulogic                    ; --f_pic
       f_eie_ex2_dw_ov_if                        :out  std_ulogic                    ; --f_pic
       f_eie_ex2_lzo_expo                        :out  std_ulogic_vector(1 to 13)    ; --dlza to lzo
       f_eie_ex2_b_expo                          :out  std_ulogic_vector(1 to 13)    ; --dlza to lzo
       f_eie_ex2_use_bexp                        :out  std_ulogic;
       f_eie_ex3_iexp                            :out  std_ulogic_vector(1 to 13)      --deov to lzasub

); -- end ports
 
 

end fuq_eie; -- ENTITY
 
 
architecture fuq_eie of fuq_eie is  
 
    constant tiup  :std_ulogic := '1';
    constant tidn  :std_ulogic := '0';
 
    signal sg_0                                  :std_ulogic                   ;
    signal thold_0_b , thold_0, forcee              :std_ulogic                   ;

    signal ex2_act                                 :std_ulogic                   ;
    signal act_spare_unused                        :std_ulogic_vector(0 to 3)    ;
    -------------------
    signal act_so                                  :std_ulogic_vector(0 to 4)    ;--SCAN
    signal act_si                                  :std_ulogic_vector(0 to 4)    ;--SCAN
    signal ex2_bop_so                              :std_ulogic_vector(0 to 12)   ;--SCAN
    signal ex2_bop_si                              :std_ulogic_vector(0 to 12)   ;--SCAN
    signal ex2_pop_so                              :std_ulogic_vector(0 to 12)   ;--SCAN
    signal ex2_pop_si                              :std_ulogic_vector(0 to 12)   ;--SCAN
    signal ex2_ctl_so                              :std_ulogic_vector(0 to 6)    ;--SCAN
    signal ex2_ctl_si                              :std_ulogic_vector(0 to 6)    ;--SCAN
    signal ex3_iexp_so                             :std_ulogic_vector(0 to 13)   ;--SCAN
    signal ex3_iexp_si                             :std_ulogic_vector(0 to 13)   ;--SCAN
    -------------------
    signal ex1_a_expo                              :std_ulogic_vector(1 to 13) ;
    signal ex1_c_expo                              :std_ulogic_vector(1 to 13) ;
    signal ex1_b_expo                              :std_ulogic_vector(1 to 13) ;
    signal ex1_ep56_sum                            :std_ulogic_vector(1 to 13) ;
    signal ex1_ep56_car                            :std_ulogic_vector(1 to 12) ;
    signal ex1_ep56_p                              :std_ulogic_vector(1 to 13) ;
    signal ex1_ep56_g                              :std_ulogic_vector(2 to 12) ;
    signal ex1_ep56_t                              :std_ulogic_vector(2 to 11) ;
    signal ex1_ep56_s                              :std_ulogic_vector(1 to 13) ;
    signal ex1_ep56_c                              :std_ulogic_vector(2 to 12) ;
    signal ex1_p_expo_adj                          :std_ulogic_vector(1 to 13) ;
    signal ex1_from_k                              :std_ulogic_vector(1 to 13) ;
    signal ex1_b_expo_adj                          :std_ulogic_vector(1 to 13) ;
    signal ex2_p_expo                              :std_ulogic_vector(1 to 13) ;
    signal ex2_b_expo                              :std_ulogic_vector(1 to 13) ;
    signal ex2_iexp                                :std_ulogic_vector(1 to 13) ;
    signal ex2_b_expo_adj                          :std_ulogic_vector(1 to 13) ;
    signal ex2_p_expo_adj                          :std_ulogic_vector(1 to 13) ;
    signal ex3_iexp                                :std_ulogic_vector(1 to 13) ;
    signal ex1_wd_ge_bot                           :std_ulogic    ;
    signal ex1_dw_ge_bot                           :std_ulogic    ;
    signal ex1_ge_2048                             :std_ulogic    ;
    signal ex1_ge_1024                             :std_ulogic    ;
    signal ex1_dw_ge_mid                           :std_ulogic    ;
    signal ex1_wd_ge_mid                           :std_ulogic    ;
    signal ex1_dw_ge                               :std_ulogic    ;
    signal ex1_wd_ge                               :std_ulogic    ;
    signal ex1_dw_eq_top                           :std_ulogic    ;
    signal ex1_wd_eq_bot                           :std_ulogic    ;
    signal ex1_wd_eq                               :std_ulogic    ;
    signal ex1_dw_eq                               :std_ulogic    ;
    signal ex2_iexp_b_sel                          :std_ulogic    ;
    signal ex2_dw_ge                               :std_ulogic    ;
    signal ex2_wd_ge                               :std_ulogic    ;
    signal ex2_wd_eq                               :std_ulogic    ;
    signal ex2_dw_eq                               :std_ulogic    ;
    signal ex2_fsel                                :std_ulogic    ;
    signal ex3_sp_b                                :std_ulogic    ;


   signal ex2_b_expo_fixed :std_ulogic_vector(1 to 13); --experiment sp_den/dp_fmt
   signal ex1_ge_bias, ex1_lt_bias, ex1_eq_bias_m1 :std_ulogic;
   signal ex2_lt_bias, ex2_eq_bias_m1 :std_ulogic;
  signal  ex1_ep56_g2 :std_ulogic_vector( 2 to 12);
  signal  ex1_ep56_t2 :std_ulogic_vector( 2 to 10);
  signal  ex1_ep56_g4 :std_ulogic_vector( 2 to 12);
  signal  ex1_ep56_t4 :std_ulogic_vector( 2 to 8);
  signal  ex1_ep56_g8 :std_ulogic_vector( 2 to 12);
  signal  ex1_ep56_t8 :std_ulogic_vector( 2 to 4);



begin 
 
--//############################################
--//# pervasive
--//############################################

    
    thold_reg_0:  tri_plat  generic map (expand_type => expand_type) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,  
         flush     => flush ,
         din(0)    => thold_1,   
         q(0)      => thold_0  ); 
    
    sg_reg_0:  tri_plat     generic map (expand_type => expand_type) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,
         flush     => flush ,
         din(0)    => sg_1  ,     
         q(0)      => sg_0  );   


    lcbor_0: tri_lcbor generic map (expand_type => expand_type ) port map (
        clkoff_b     => clkoff_b,
        thold        => thold_0,  
        sg           => sg_0,
        act_dis      => act_dis,
        forcee => forcee,
        thold_b      => thold_0_b );



 
--//############################################
--//# ACT LATCHES
--//############################################


    act_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(2)  ,--tidn,
        mpw1_b           => mpw1_b(2)       ,--tidn,
        mpw2_b           => mpw2_b(0)       ,--tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => fpu_enable, 
        scout            => act_so   ,                     
        scin             => act_si   ,                   
        -------------------
         din(0)             => act_spare_unused(0),
         din(1)             => act_spare_unused(1),
         din(2)             => ex1_act,
         din(3)             => act_spare_unused(2),
         din(4)             => act_spare_unused(3),
        -------------------
        dout(0)             => act_spare_unused(0),
        dout(1)             => act_spare_unused(1),
        dout(2)             => ex2_act,
        dout(3)             => act_spare_unused(2),
        dout(4)             => act_spare_unused(3) );


--//##############################################
--//# EX1 latch inputs from rf1
--//##############################################

    ex1_a_expo(1 to 13) <= f_byp_eie_ex1_a_expo(1 to 13);
    ex1_c_expo(1 to 13) <= f_byp_eie_ex1_c_expo(1 to 13);
    ex1_b_expo(1 to 13) <= f_byp_eie_ex1_b_expo(1 to 13);


--//##############################################
--//# EX1 logic
--//##############################################

  --//##-------------------------------------------------------------------------
  --//## Product Exponent adder (+56 scouta subtract gives final resutl)
  --//##-------------------------------------------------------------------------
    -- rebiased from 1023 to 4095 ... (append 2 ones)
    -- ep56 : Ec + Ea -bias
    -- ep0  : Ec + Ea -bias + 56 = Ec + Ea -4095 + 56
    --
    --  0_0011_1111_1111
    --  1_1100_0000_0001  !1023 + 1 = -1023
    --           11_1000  56
    --------------------
    --  1_1100_0011_1001 + Ea + Ec
    --
    
    ex1_ep56_sum( 1) <= not( ex1_a_expo( 1) xor ex1_c_expo( 1) ); -- 1
    ex1_ep56_sum( 2) <= not( ex1_a_expo( 2) xor ex1_c_expo( 2) ); -- 1
    ex1_ep56_sum( 3) <= not( ex1_a_expo( 3) xor ex1_c_expo( 3) ); -- 1
    ex1_ep56_sum( 4) <=    ( ex1_a_expo( 4) xor ex1_c_expo( 4) ); -- 0
    ex1_ep56_sum( 5) <=    ( ex1_a_expo( 5) xor ex1_c_expo( 5) ); -- 0
    ex1_ep56_sum( 6) <=    ( ex1_a_expo( 6) xor ex1_c_expo( 6) ); -- 0
    ex1_ep56_sum( 7) <=    ( ex1_a_expo( 7) xor ex1_c_expo( 7) ); -- 0
    ex1_ep56_sum( 8) <= not( ex1_a_expo( 8) xor ex1_c_expo( 8) ); -- 1
    ex1_ep56_sum( 9) <= not( ex1_a_expo( 9) xor ex1_c_expo( 9) ); -- 1
    ex1_ep56_sum(10) <= not( ex1_a_expo(10) xor ex1_c_expo(10) ); -- 1
    ex1_ep56_sum(11) <=    ( ex1_a_expo(11) xor ex1_c_expo(11) ); -- 0
    ex1_ep56_sum(12) <=    ( ex1_a_expo(12) xor ex1_c_expo(12) ); -- 0
    ex1_ep56_sum(13) <= not( ex1_a_expo(13) xor ex1_c_expo(13) ); -- 1
  
    ex1_ep56_car( 1) <=    ( ex1_a_expo( 2) or  ex1_c_expo( 2) ); -- 1
    ex1_ep56_car( 2) <=    ( ex1_a_expo( 3) or  ex1_c_expo( 3) ); -- 1
    ex1_ep56_car( 3) <=    ( ex1_a_expo( 4) and ex1_c_expo( 4) ); -- 0
    ex1_ep56_car( 4) <=    ( ex1_a_expo( 5) and ex1_c_expo( 5) ); -- 0
    ex1_ep56_car( 5) <=    ( ex1_a_expo( 6) and ex1_c_expo( 6) ); -- 0
    ex1_ep56_car( 6) <=    ( ex1_a_expo( 7) and ex1_c_expo( 7) ); -- 0
    ex1_ep56_car( 7) <=    ( ex1_a_expo( 8) or  ex1_c_expo( 8) ); -- 1
    ex1_ep56_car( 8) <=    ( ex1_a_expo( 9) or  ex1_c_expo( 9) ); -- 1
    ex1_ep56_car( 9) <=    ( ex1_a_expo(10) or  ex1_c_expo(10) ); -- 1
    ex1_ep56_car(10) <=    ( ex1_a_expo(11) and ex1_c_expo(11) ); -- 0
    ex1_ep56_car(11) <=    ( ex1_a_expo(12) and ex1_c_expo(12) ); -- 0
    ex1_ep56_car(12) <=    ( ex1_a_expo(13) or  ex1_c_expo(13) ); -- 1
    
    ex1_ep56_p(1 to 12) <= ex1_ep56_sum(1 to 12) xor ex1_ep56_car(1 to 12);
    ex1_ep56_p(13)      <= ex1_ep56_sum(13);  
    ex1_ep56_g(2 to 12) <= ex1_ep56_sum(2 to 12) and ex1_ep56_car(2 to 12);
    ex1_ep56_t(2 to 11) <= ex1_ep56_sum(2 to 11) or  ex1_ep56_car(2 to 11);
    
    ex1_ep56_s(1 to 11) <= ex1_ep56_p(1 to 11) xor ex1_ep56_c(2 to 12);    
    ex1_ep56_s(12) <= ex1_ep56_p(12);
    ex1_ep56_s(13) <= ex1_ep56_p(13);


    ex1_ep56_g2(12) <= ex1_ep56_g(12) ;
    ex1_ep56_g2(11) <= ex1_ep56_g(11) or (ex1_ep56_t(11) and ex1_ep56_g(12)) ;
    ex1_ep56_g2(10) <= ex1_ep56_g(10) or (ex1_ep56_t(10) and ex1_ep56_g(11)) ;
    ex1_ep56_g2( 9) <= ex1_ep56_g( 9) or (ex1_ep56_t( 9) and ex1_ep56_g(10)) ;
    ex1_ep56_g2( 8) <= ex1_ep56_g( 8) or (ex1_ep56_t( 8) and ex1_ep56_g( 9)) ;
    ex1_ep56_g2( 7) <= ex1_ep56_g( 7) or (ex1_ep56_t( 7) and ex1_ep56_g( 8)) ;
    ex1_ep56_g2( 6) <= ex1_ep56_g( 6) or (ex1_ep56_t( 6) and ex1_ep56_g( 7)) ;
    ex1_ep56_g2( 5) <= ex1_ep56_g( 5) or (ex1_ep56_t( 5) and ex1_ep56_g( 6)) ;
    ex1_ep56_g2( 4) <= ex1_ep56_g( 4) or (ex1_ep56_t( 4) and ex1_ep56_g( 5)) ;
    ex1_ep56_g2( 3) <= ex1_ep56_g( 3) or (ex1_ep56_t( 3) and ex1_ep56_g( 4)) ;
    ex1_ep56_g2( 2) <= ex1_ep56_g( 2) or (ex1_ep56_t( 2) and ex1_ep56_g( 3)) ;

    ex1_ep56_t2(10) <=                   (ex1_ep56_t(10) and ex1_ep56_t(11)) ;
    ex1_ep56_t2( 9) <=                   (ex1_ep56_t( 9) and ex1_ep56_t(10)) ;
    ex1_ep56_t2( 8) <=                   (ex1_ep56_t( 8) and ex1_ep56_t( 9)) ;
    ex1_ep56_t2( 7) <=                   (ex1_ep56_t( 7) and ex1_ep56_t( 8)) ;
    ex1_ep56_t2( 6) <=                   (ex1_ep56_t( 6) and ex1_ep56_t( 7)) ;
    ex1_ep56_t2( 5) <=                   (ex1_ep56_t( 5) and ex1_ep56_t( 6)) ;
    ex1_ep56_t2( 4) <=                   (ex1_ep56_t( 4) and ex1_ep56_t( 5)) ;
    ex1_ep56_t2( 3) <=                   (ex1_ep56_t( 3) and ex1_ep56_t( 4)) ;
    ex1_ep56_t2( 2) <=                   (ex1_ep56_t( 2) and ex1_ep56_t( 3)) ;

    ex1_ep56_g4(12) <= ex1_ep56_g2(12) ;
    ex1_ep56_g4(11) <= ex1_ep56_g2(11) ;
    ex1_ep56_g4(10) <= ex1_ep56_g2(10) or (ex1_ep56_t2(10) and ex1_ep56_g2(12)) ;
    ex1_ep56_g4( 9) <= ex1_ep56_g2( 9) or (ex1_ep56_t2( 9) and ex1_ep56_g2(11)) ;
    ex1_ep56_g4( 8) <= ex1_ep56_g2( 8) or (ex1_ep56_t2( 8) and ex1_ep56_g2(10)) ;
    ex1_ep56_g4( 7) <= ex1_ep56_g2( 7) or (ex1_ep56_t2( 7) and ex1_ep56_g2( 9)) ;
    ex1_ep56_g4( 6) <= ex1_ep56_g2( 6) or (ex1_ep56_t2( 6) and ex1_ep56_g2( 8)) ;
    ex1_ep56_g4( 5) <= ex1_ep56_g2( 5) or (ex1_ep56_t2( 5) and ex1_ep56_g2( 7)) ;
    ex1_ep56_g4( 4) <= ex1_ep56_g2( 4) or (ex1_ep56_t2( 4) and ex1_ep56_g2( 6)) ;
    ex1_ep56_g4( 3) <= ex1_ep56_g2( 3) or (ex1_ep56_t2( 3) and ex1_ep56_g2( 5)) ;
    ex1_ep56_g4( 2) <= ex1_ep56_g2( 2) or (ex1_ep56_t2( 2) and ex1_ep56_g2( 4)) ;

    ex1_ep56_t4( 8) <=                    (ex1_ep56_t2( 8) and ex1_ep56_t2(10)) ;
    ex1_ep56_t4( 7) <=                    (ex1_ep56_t2( 7) and ex1_ep56_t2( 9)) ;
    ex1_ep56_t4( 6) <=                    (ex1_ep56_t2( 6) and ex1_ep56_t2( 8)) ;
    ex1_ep56_t4( 5) <=                    (ex1_ep56_t2( 5) and ex1_ep56_t2( 7)) ;
    ex1_ep56_t4( 4) <=                    (ex1_ep56_t2( 4) and ex1_ep56_t2( 6)) ;
    ex1_ep56_t4( 3) <=                    (ex1_ep56_t2( 3) and ex1_ep56_t2( 5)) ;
    ex1_ep56_t4( 2) <=                    (ex1_ep56_t2( 2) and ex1_ep56_t2( 4)) ;

    ex1_ep56_g8(12) <= ex1_ep56_g4(12) ;
    ex1_ep56_g8(11) <= ex1_ep56_g4(11) ;
    ex1_ep56_g8(10) <= ex1_ep56_g4(10) ;
    ex1_ep56_g8( 9) <= ex1_ep56_g4( 9) ;
    ex1_ep56_g8( 8) <= ex1_ep56_g4( 8) or (ex1_ep56_t4( 8) and ex1_ep56_g4(12)) ;
    ex1_ep56_g8( 7) <= ex1_ep56_g4( 7) or (ex1_ep56_t4( 7) and ex1_ep56_g4(11)) ;
    ex1_ep56_g8( 6) <= ex1_ep56_g4( 6) or (ex1_ep56_t4( 6) and ex1_ep56_g4(10)) ;
    ex1_ep56_g8( 5) <= ex1_ep56_g4( 5) or (ex1_ep56_t4( 5) and ex1_ep56_g4( 9)) ;
    ex1_ep56_g8( 4) <= ex1_ep56_g4( 4) or (ex1_ep56_t4( 4) and ex1_ep56_g4( 8)) ;
    ex1_ep56_g8( 3) <= ex1_ep56_g4( 3) or (ex1_ep56_t4( 3) and ex1_ep56_g4( 7)) ;
    ex1_ep56_g8( 2) <= ex1_ep56_g4( 2) or (ex1_ep56_t4( 2) and ex1_ep56_g4( 6)) ;

    ex1_ep56_t8( 4) <=                    (ex1_ep56_t4( 4) and ex1_ep56_t4( 8)) ;
    ex1_ep56_t8( 3) <=                    (ex1_ep56_t4( 3) and ex1_ep56_t4( 7)) ;
    ex1_ep56_t8( 2) <=                    (ex1_ep56_t4( 2) and ex1_ep56_t4( 6)) ;

    ex1_ep56_c(12) <= ex1_ep56_g8(12) ;
    ex1_ep56_c(11) <= ex1_ep56_g8(11) ;
    ex1_ep56_c(10) <= ex1_ep56_g8(10) ;
    ex1_ep56_c( 9) <= ex1_ep56_g8( 9) ;
    ex1_ep56_c( 8) <= ex1_ep56_g8( 8) ;
    ex1_ep56_c( 7) <= ex1_ep56_g8( 7) ;
    ex1_ep56_c( 6) <= ex1_ep56_g8( 6) ;
    ex1_ep56_c( 5) <= ex1_ep56_g8( 5) ;
    ex1_ep56_c( 4) <= ex1_ep56_g8( 4) or (ex1_ep56_t8( 4) and ex1_ep56_g8(12)) ;
    ex1_ep56_c( 3) <= ex1_ep56_g8( 3) or (ex1_ep56_t8( 3) and ex1_ep56_g8(11)) ;
    ex1_ep56_c( 2) <= ex1_ep56_g8( 2) or (ex1_ep56_t8( 2) and ex1_ep56_g8(10)) ;




   --//##---------------------------------------
   --//## hold onto c_exponent for fsel
   --//##---------------------------------------

   ex1_p_expo_adj(1 to 13) <=
         ( ex1_ep56_s(1 to 13) and (1 to 13 => not f_pic_ex1_fsel) ) or 
         ( ex1_c_expo(1 to 13) and (1 to 13 =>     f_pic_ex1_fsel) );

   
   --//##---------------------------------------
   --//## select b exponent
   --//##---------------------------------------

         -- From integer exponent
         -- lsb is at position 162, and value = bias
         -- therefore set b_expo to (bias+162)
         -- 0_1111_1111_1111   1023 = bias
         --         101_0010    162
         -- ----------------   ----
         -- 1_0000_0101_0001   4096+57
         -- 1 2345 6789 0123

   ex1_from_k( 1) <= tidn; -- 4096
   ex1_from_k( 2) <= tidn; -- 2048
   ex1_from_k( 3) <= tiup; -- 1024
   ex1_from_k( 4) <= tidn; --  512
   ex1_from_k( 5) <= tidn; --  256
   ex1_from_k( 6) <= tiup; --  128
   ex1_from_k( 7) <= tidn; --   64
   ex1_from_k( 8) <= tiup; --   32
   ex1_from_k( 9) <= tidn; --   16
   ex1_from_k(10) <= tidn; --    8
   ex1_from_k(11) <= tidn; --    4
   ex1_from_k(12) <= tidn; --    2
   ex1_from_k(13) <= tiup; --    1

   ex1_b_expo_adj(1 to 13) <=
       ( ex1_from_k  (1 to 13) and (1 to 13=>     f_pic_ex1_from_integer ) ) or 
       ( ex1_b_expo  (1 to 13) and (1 to 13=> not f_pic_ex1_from_integer ) ) ;



   --//##---------------------------------------
   --//## to integer overflow boundaries
   --//##---------------------------------------
     -- convert to signed_word:
     --      pos int ov ge 2**31             1023+31
     --              ov eq 2**30 * rnd_up    1023+30 <= just look at final MSB position
     --      neg int ov gt 2**31             1023+31
     --      neg int ov eq 2**31             1023+31 & frac[1:*] != 0

     -- convert to signed_doubleword:
     --      pos int ov ge 2**63             1023+63  1086
     --              ov eq 2**62 * rnd_up    1023+62  1085 <=== just look at final msb position
     --      neg int ov gt 2**63             1023+63  1086
     --      neg int ov eq 2**63             1023+63  1086 & frac[1:*] != 0;
     --
     --   0_0011_1111_1111   bias 1023
     --            10_0000   32
     --   0_0100 0001 1111   <=== ge
     --
     --   0_0011_1111_1111   bias 1023
     --             1_1111   31
     --   0_0100 0001 1110   <=== eq
     --
     --   0_0011_1111_1111   bias 1023
     --           100_0000   64
     --   0_0100 0011 1111  <==== ge  1087
     --
     --   0_0011_1111_1111   bias 1023
     --            11_1111   63
     --   0_0100 0011 1110  <==== eq  1086
     --
     --               1111
     --   1 2345 6789 0123
     --
     -- if exponent less than bias (1023)
     -- positive input  if +rnd_up  result = +ulp (ok)  int  1
     -- positive input  if -rnd_up  result =   +0 (ok)  int  0
     -- negative input  if +rnd_up  result = -ulp (ok)  int -1 (no increment)
     -- negative input  if -rnd_up  result =   +0      <== ??force sign??
     --     normalizer shifts wrong (98)=1
     


     ex1_wd_ge_bot <=      ex1_b_expo( 9) and
                           ex1_b_expo(10) and 
                           ex1_b_expo(11) and 
                           ex1_b_expo(12) and 
                           ex1_b_expo(13) ;

     ex1_dw_ge_bot <=      ex1_b_expo( 8) and
                           ex1_wd_ge_bot  ;
                          
     ex1_ge_2048    <= not ex1_b_expo( 1) and ex1_b_expo( 2) ;
     ex1_ge_1024    <= not ex1_b_expo( 1) and ex1_b_expo( 3) ;

     ex1_dw_ge_mid  <=     ex1_b_expo( 4) or                           
                           ex1_b_expo( 5) or                           
                           ex1_b_expo( 6) or                           
                           ex1_b_expo( 7) ;

     ex1_wd_ge_mid  <=     ex1_b_expo( 8) or 
                           ex1_dw_ge_mid  ;
                       
     ex1_dw_ge <=  ( ex1_ge_2048                   ) or
                   ( ex1_ge_1024 and ex1_dw_ge_mid ) or 
                   ( ex1_ge_1024 and ex1_dw_ge_bot ) ;

     ex1_wd_ge <=  ( ex1_ge_2048                   ) or
                   ( ex1_ge_1024 and ex1_wd_ge_mid ) or 
                   ( ex1_ge_1024 and ex1_wd_ge_bot ) ;

     ex1_dw_eq_top <=  not ex1_b_expo( 1) and
                       not ex1_b_expo( 2) and
                           ex1_b_expo( 3) and 
                       not ex1_b_expo( 4) and
                       not ex1_b_expo( 5) and
                       not ex1_b_expo( 6) and
                       not ex1_b_expo( 7) ;

     ex1_wd_eq_bot <=      ex1_b_expo( 9) and
                           ex1_b_expo(10) and 
                           ex1_b_expo(11) and 
                           ex1_b_expo(12) and 
                       not ex1_b_expo(13) ;

     ex1_wd_eq     <=      ex1_dw_eq_top  and
                       not ex1_b_expo( 8) and
                           ex1_wd_eq_bot ;

     ex1_dw_eq     <=      ex1_dw_eq_top  and
                           ex1_b_expo( 8) and
                           ex1_wd_eq_bot ;




     ex1_ge_bias   <= -- for rnd_to_int
         (not ex1_b_expo(1) and ex1_b_expo(2)       ) or  
         (not ex1_b_expo(1) and ex1_b_expo(3)       ) or 
         (not ex1_b_expo(1) and ex1_b_expo(4)  and
                                ex1_b_expo(5)  and
                                ex1_b_expo(6)  and
                                ex1_b_expo(7)  and
                                ex1_b_expo(8)  and
                                ex1_b_expo(9)  and
                                ex1_b_expo(10) and
                                ex1_b_expo(11) and
                                ex1_b_expo(12) and
                                ex1_b_expo(13)      );

    ex1_lt_bias <= not ex1_ge_bias;
    ex1_eq_bias_m1 <= -- rnd-to-int nearest rounds up
         not ex1_b_expo(1)  and -- sign
         not ex1_b_expo(2)  and -- 2048
         not ex1_b_expo(3)  and -- 1024
             ex1_b_expo(4)  and -- 512
             ex1_b_expo(5)  and -- 256
             ex1_b_expo(6)  and -- 128
             ex1_b_expo(7)  and -- 64
             ex1_b_expo(8)  and -- 32
             ex1_b_expo(9)  and -- 16
             ex1_b_expo(10) and -- 8
             ex1_b_expo(11) and -- 4
             ex1_b_expo(12) and -- 2
         not ex1_b_expo(13) ;   -- 1

                 
--//##############################################
--//# EX2 latches
--//##############################################

  ex2_bop_lat:  tri_rlmreg_p generic map (width=> 13, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(2)  ,--tidn,
        mpw1_b           => mpw1_b(2)       ,--tidn,
        mpw2_b           => mpw2_b(0)       ,--tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex1_act, 
        scout            => ex2_bop_so  ,                      
        scin             => ex2_bop_si  ,                    
        -------------------
         din(0 to 12)       => ex1_b_expo_adj  (1 to 13)   ,
        dout(0 to 12)       => ex2_b_expo_adj  (1 to 13)  );--LAT--
 
  ex2_pop_lat:  tri_rlmreg_p generic map (width=> 13, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(2)  ,--tidn,
        mpw1_b           => mpw1_b(2)       ,--tidn,
        mpw2_b           => mpw2_b(0)       ,--tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex1_act, 
        scout            => ex2_pop_so  ,                      
        scin             => ex2_pop_si  ,                    
        -------------------
         din(0 to 12)       => ex1_p_expo_adj  (1 to 13)   ,
        dout(0 to 12)       => ex2_p_expo_adj  (1 to 13)  );--LAT--
 
  ex2_ctl_lat:  tri_rlmreg_p generic map (width=> 7, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(2)  ,--tidn,
        mpw1_b           => mpw1_b(2)       ,--tidn,
        mpw2_b           => mpw2_b(0)       ,--tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex1_act, 
        scout            => ex2_ctl_so  ,                      
        scin             => ex2_ctl_si  ,                    
        -------------------
         din(0)             => ex1_dw_ge ,
         din(1)             => ex1_wd_ge ,
         din(2)             => ex1_wd_eq ,
         din(3)             => ex1_dw_eq ,
         din(4)             => f_pic_ex1_fsel,
         din(5)             => ex1_lt_bias ,
         din(6)             => ex1_eq_bias_m1, 
        -------------------
        dout(0)             => ex2_dw_ge    ,  --LAT--
        dout(1)             => ex2_wd_ge    ,  --LAT--
        dout(2)             => ex2_wd_eq    ,  --LAT--
        dout(3)             => ex2_dw_eq    ,  --LAT--
        dout(4)             => ex2_fsel     ,  --LAT--
        dout(5)             => ex2_lt_bias  ,  --LAT--
        dout(6)             => ex2_eq_bias_m1 );  --LAT--

        f_eie_ex2_lt_bias    <= ex2_lt_bias;--output --f_pic
        f_eie_ex2_eq_bias_m1 <= ex2_eq_bias_m1;--output --f_pic

       ex2_p_expo(1 to 13) <=     ex2_p_expo_adj  (1 to 13);
       ex2_b_expo(1 to 13) <=     ex2_b_expo_adj  (1 to 13);

       f_eie_ex2_wd_ov      <=     ex2_wd_ge   ;--output --f_pic
       f_eie_ex2_dw_ov      <=     ex2_dw_ge   ;--output --f_pic
       f_eie_ex2_wd_ov_if   <=     ex2_wd_eq   ;--output --f_pic
       f_eie_ex2_dw_ov_if   <=     ex2_dw_eq   ;--output --f_pic

       f_eie_ex2_lzo_expo(1 to 13) <=     ex2_p_expo_adj  (1 to 13) ;--output --dlza for lzo
       f_eie_ex2_b_expo(1 to 13) <= ex2_b_expo(1 to 13);
       f_eie_ex2_tbl_expo(1 to 13) <= ex2_b_expo(1 to 13);

--//##############################################
--//# EX2 logic
--//##############################################

 ex2_b_expo_fixed(1 to 13) <= ex2_b_expo(1 to 13) ;

 f_eie_ex2_use_bexp <= ex2_iexp_b_sel ;

       ex2_iexp_b_sel <=
           (f_alg_ex2_sel_byp and not ex2_fsel and f_pic_ex2_math_bzer_b )   or --NAN/shOv
            f_fmt_ex2_fsel_bsel      or  -- fsel
            f_pic_ex2_force_sel_bexp or  -- by opcode
            f_pic_ex2_frsp_ue1 ;         -- frsp with ue=1 always does bypass because must normalize anyway
                                         -- if frsp(ue=1) has a shift unf, then loose bits and canot normalize)

       ex2_iexp(1 to 13) <=
          ( ex2_b_expo_fixed(1 to 13) and (1 to 13 =>     ex2_iexp_b_sel) ) or --experiment sp_den/dp_fmt
          ( ex2_p_expo(1 to 13)       and (1 to 13 => not ex2_iexp_b_sel) ) ;

--//##############################################
--//# EX3 latches
--//##############################################

  ex3_iexp_lat:  tri_rlmreg_p generic map (width=> 14, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(3)  ,--tidn,
        mpw1_b           => mpw1_b(3)       ,--tidn,
        mpw2_b           => mpw2_b(0)       ,--tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex2_act, 
        scout            => ex3_iexp_so  ,                      
        scin             => ex3_iexp_si  ,                    
        -------------------
         din(0)             => f_pic_ex2_sp_b   ,
         din(1 to 13)       => ex2_iexp  (1 to 13)   ,
        -------------------
        dout(0)             => ex3_sp_b               ,--LAT--
        dout(1 to 13)       => ex3_iexp  (1 to 13)   );--LAT--




       f_eie_ex3_iexp(1 to 13)    <=     ex3_iexp(1 to 13)   ;--output--feov


--//##############################################
--//# EX3 logic
--//##############################################

--//############################################
--//# scan
--//############################################


    ex2_bop_si     (0 to 12)  <= ex2_bop_so     (1 to 12)  &  f_eie_si;
    ex2_pop_si     (0 to 12)  <= ex2_pop_so     (1 to 12)  &  ex2_bop_so  (0);
    ex2_ctl_si     (0 to 6)   <= ex2_ctl_so     (1 to 6)   &  ex2_pop_so  (0);
    ex3_iexp_si    (0 to 13)  <= ex3_iexp_so    (1 to 13)  &  ex2_ctl_so  (0);
    act_si         (0 to 4)   <= act_so         (1 to 4)   &  ex3_iexp_so  (0);
    f_eie_so                  <=   act_so  (0);


end; -- fuq_eie ARCHITECTURE
