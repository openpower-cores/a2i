-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

  
library ieee,ibm,support,tri, work; 
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 
library clib ;

entity fuq_sa3 is
generic(expand_type: integer := 2  ); 
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



       f_sa3_si                  :in  std_ulogic; --perv
       f_sa3_so                  :out std_ulogic; --perv
       ex1_act_b                 :in  std_ulogic; --act

       f_mul_ex2_sum              :in  std_ulogic_vector(54 to 161); 
       f_mul_ex2_car              :in  std_ulogic_vector(54 to 161);
       f_alg_ex2_res              :in  std_ulogic_vector(0  to 162);

       f_sa3_ex3_s_lza           :out std_ulogic_vector(0  to 162); -- data
       f_sa3_ex3_c_lza           :out std_ulogic_vector(53 to 161); -- data

       f_sa3_ex3_s_add           :out std_ulogic_vector(0  to 162); -- data
       f_sa3_ex3_c_add           :out std_ulogic_vector(53 to 161)  -- data
);



end fuq_sa3; -- ENTITY

architecture fuq_sa3 of fuq_sa3 is

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';

--//#################################
--//# sigdef : functional
--//#################################
  signal thold_0_b, thold_0, forcee , sg_0 :std_ulogic;
  signal act_spare_unused :std_ulogic_vector(0 to 3);
  signal ex2_act :std_ulogic;
  signal act_so  , act_si   :std_ulogic_vector(0 to 4);
  signal ex3_sum :std_ulogic_vector(0 to 162);
  signal ex3_car :std_ulogic_vector(53 to 161);
  signal ex1_act :std_ulogic;
  signal ex3_053_sum_si, ex3_053_sum_so :std_ulogic_vector(0 to 109);
  signal ex3_053_car_si, ex3_053_car_so :std_ulogic_vector(0 to 108);
  signal ex3_000_si, ex3_000_so :std_ulogic_vector(0 to 52);
  signal ex3_sum_lza_b, ex3_sum_add_b :std_ulogic_vector(0 to  162);
  signal ex3_car_lza_b, ex3_car_add_b :std_ulogic_vector(53 to 161);
  signal sa3_ex3_d2clk , sa3_ex3_d1clk :std_ulogic;
  signal sa3_ex3_lclk  : clk_logic;

  signal ex2_alg_b    :std_ulogic_vector(0 to 52)   ; 
  signal ex2_sum_b    :std_ulogic_vector(53 to 162) ; 
  signal ex2_car_b    :std_ulogic_vector(53 to 161) ; 
  
  signal f_alg_ex2_res_b,  f_mul_ex2_sum_b, f_mul_ex2_car_b  :std_ulogic_vector(55 to 161);


  
  

  












begin


--//################################################################
--//# ex2 logic
--//################################################################
  
  
  -- this model                       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  -- aligner  000 001 002 ....... 052 053 054  055 056 .... 158 159 160 161 162
  -- mul sum  xxx xxx xxx ....... xxx xxx 054* 055 056 .... 158 159 160 xxx xxx
  -- mul car  xxx xxx xxx ....... xxx xxx 054* 055 056 .... 158 159 xxx xxx xxx
  -- rid PB   "1" "1" "1" ....... "1" "1" "1"  "0" "0" .... "0" "0" "0" "0" "0"
  --
  -- 54* is the pseudo bit ... at most 1 is on
  
               
  
  ex2_sum_b(54) <= not(   not(f_mul_ex2_sum(54) or f_mul_ex2_car(54)) xor f_alg_ex2_res(54)  );                            
  ex2_car_b(53) <= not(      (f_mul_ex2_sum(54) or f_mul_ex2_car(54))  or f_alg_ex2_res(54)  );             
  
  -- rest of bits are normal as expected
               

  -- with 3:2 is it equivalent to invert all the inputs, or invert all the outputs
  
        u_algi:    ex2_alg_b(0 to 52)      <= not f_alg_ex2_res(0 to 52)  ;

  

    u_pre_a:   f_alg_ex2_res_b(55 to 161) <= not( f_alg_ex2_res(55 to 161) );
    u_pre_s:   f_mul_ex2_sum_b(55 to 161) <= not( f_mul_ex2_sum(55 to 161) );
    u_pre_c:   f_mul_ex2_car_b(55 to 161) <= not( f_mul_ex2_car(55 to 161) );

 
  res_csa_55: entity clib.c_prism_csa32  port map (  --MLT32_X1_A12TH
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(55), --i--
       b    => f_mul_ex2_sum_b(55), --i--
       c    => f_mul_ex2_car_b(55), --i--
       sum  => ex2_sum_b(55)      , --o--
       car  => ex2_car_b(54)     ); --o--
  res_csa_56: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(56), --i--
       b    => f_mul_ex2_sum_b(56), --i--
       c    => f_mul_ex2_car_b(56), --i--
       sum  => ex2_sum_b(56)      , --o--
       car  => ex2_car_b(55)     ); --o--
  res_csa_57: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(57), --i--
       b    => f_mul_ex2_sum_b(57), --i--
       c    => f_mul_ex2_car_b(57), --i--
       sum  => ex2_sum_b(57)      , --o--
       car  => ex2_car_b(56)     ); --o--
  res_csa_58: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(58), --i--
       b    => f_mul_ex2_sum_b(58), --i--
       c    => f_mul_ex2_car_b(58), --i--
       sum  => ex2_sum_b(58)      , --o--
       car  => ex2_car_b(57)     ); --o--
  res_csa_59: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(59), --i--
       b    => f_mul_ex2_sum_b(59), --i--
       c    => f_mul_ex2_car_b(59), --i--
       sum  => ex2_sum_b(59)      , --o--
       car  => ex2_car_b(58)     ); --o--
  res_csa_60: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(60), --i--
       b    => f_mul_ex2_sum_b(60), --i--
       c    => f_mul_ex2_car_b(60), --i--
       sum  => ex2_sum_b(60)      , --o--
       car  => ex2_car_b(59)     ); --o--
  res_csa_61: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(61), --i--
       b    => f_mul_ex2_sum_b(61), --i--
       c    => f_mul_ex2_car_b(61), --i--
       sum  => ex2_sum_b(61)      , --o--
       car  => ex2_car_b(60)     ); --o--
  res_csa_62: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(62), --i--
       b    => f_mul_ex2_sum_b(62), --i--
       c    => f_mul_ex2_car_b(62), --i--
       sum  => ex2_sum_b(62)      , --o--
       car  => ex2_car_b(61)     ); --o--
  res_csa_63: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(63), --i--
       b    => f_mul_ex2_sum_b(63), --i--
       c    => f_mul_ex2_car_b(63), --i--
       sum  => ex2_sum_b(63)      , --o--
       car  => ex2_car_b(62)     ); --o--
  res_csa_64: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(64), --i--
       b    => f_mul_ex2_sum_b(64), --i--
       c    => f_mul_ex2_car_b(64), --i--
       sum  => ex2_sum_b(64)      , --o--
       car  => ex2_car_b(63)     ); --o--
  res_csa_65: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(65), --i--
       b    => f_mul_ex2_sum_b(65), --i--
       c    => f_mul_ex2_car_b(65), --i--
       sum  => ex2_sum_b(65)      , --o--
       car  => ex2_car_b(64)     ); --o--
  res_csa_66: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(66), --i--
       b    => f_mul_ex2_sum_b(66), --i--
       c    => f_mul_ex2_car_b(66), --i--
       sum  => ex2_sum_b(66)      , --o--
       car  => ex2_car_b(65)     ); --o--
  res_csa_67: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(67), --i--
       b    => f_mul_ex2_sum_b(67), --i--
       c    => f_mul_ex2_car_b(67), --i--
       sum  => ex2_sum_b(67)      , --o--
       car  => ex2_car_b(66)     ); --o--
  res_csa_68: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(68), --i--
       b    => f_mul_ex2_sum_b(68), --i--
       c    => f_mul_ex2_car_b(68), --i--
       sum  => ex2_sum_b(68)      , --o--
       car  => ex2_car_b(67)     ); --o--
  res_csa_69: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(69), --i--
       b    => f_mul_ex2_sum_b(69), --i--
       c    => f_mul_ex2_car_b(69), --i--
       sum  => ex2_sum_b(69)      , --o--
       car  => ex2_car_b(68)     ); --o--
  res_csa_70: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(70), --i--
       b    => f_mul_ex2_sum_b(70), --i--
       c    => f_mul_ex2_car_b(70), --i--
       sum  => ex2_sum_b(70)      , --o--
       car  => ex2_car_b(69)     ); --o--
  res_csa_71: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(71), --i--
       b    => f_mul_ex2_sum_b(71), --i--
       c    => f_mul_ex2_car_b(71), --i--
       sum  => ex2_sum_b(71)      , --o--
       car  => ex2_car_b(70)     ); --o--
  res_csa_72: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(72), --i--
       b    => f_mul_ex2_sum_b(72), --i--
       c    => f_mul_ex2_car_b(72), --i--
       sum  => ex2_sum_b(72)      , --o--
       car  => ex2_car_b(71)     ); --o--
  res_csa_73: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(73), --i--
       b    => f_mul_ex2_sum_b(73), --i--
       c    => f_mul_ex2_car_b(73), --i--
       sum  => ex2_sum_b(73)      , --o--
       car  => ex2_car_b(72)     ); --o--
  res_csa_74: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(74), --i--
       b    => f_mul_ex2_sum_b(74), --i--
       c    => f_mul_ex2_car_b(74), --i--
       sum  => ex2_sum_b(74)      , --o--
       car  => ex2_car_b(73)     ); --o--
  res_csa_75: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(75), --i--
       b    => f_mul_ex2_sum_b(75), --i--
       c    => f_mul_ex2_car_b(75), --i--
       sum  => ex2_sum_b(75)      , --o--
       car  => ex2_car_b(74)     ); --o--
  res_csa_76: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(76), --i--
       b    => f_mul_ex2_sum_b(76), --i--
       c    => f_mul_ex2_car_b(76), --i--
       sum  => ex2_sum_b(76)      , --o--
       car  => ex2_car_b(75)     ); --o--
  res_csa_77: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(77), --i--
       b    => f_mul_ex2_sum_b(77), --i--
       c    => f_mul_ex2_car_b(77), --i--
       sum  => ex2_sum_b(77)      , --o--
       car  => ex2_car_b(76)     ); --o--
  res_csa_78: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(78), --i--
       b    => f_mul_ex2_sum_b(78), --i--
       c    => f_mul_ex2_car_b(78), --i--
       sum  => ex2_sum_b(78)      , --o--
       car  => ex2_car_b(77)     ); --o--
  res_csa_79: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(79), --i--
       b    => f_mul_ex2_sum_b(79), --i--
       c    => f_mul_ex2_car_b(79), --i--
       sum  => ex2_sum_b(79)      , --o--
       car  => ex2_car_b(78)     ); --o--
  res_csa_80: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(80), --i--
       b    => f_mul_ex2_sum_b(80), --i--
       c    => f_mul_ex2_car_b(80), --i--
       sum  => ex2_sum_b(80)      , --o--
       car  => ex2_car_b(79)     ); --o--
  res_csa_81: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(81), --i--
       b    => f_mul_ex2_sum_b(81), --i--
       c    => f_mul_ex2_car_b(81), --i--
       sum  => ex2_sum_b(81)      , --o--
       car  => ex2_car_b(80)     ); --o--
  res_csa_82: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(82), --i--
       b    => f_mul_ex2_sum_b(82), --i--
       c    => f_mul_ex2_car_b(82), --i--
       sum  => ex2_sum_b(82)      , --o--
       car  => ex2_car_b(81)     ); --o--
  res_csa_83: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(83), --i--
       b    => f_mul_ex2_sum_b(83), --i--
       c    => f_mul_ex2_car_b(83), --i--
       sum  => ex2_sum_b(83)      , --o--
       car  => ex2_car_b(82)     ); --o--
  res_csa_84: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(84), --i--
       b    => f_mul_ex2_sum_b(84), --i--
       c    => f_mul_ex2_car_b(84), --i--
       sum  => ex2_sum_b(84)      , --o--
       car  => ex2_car_b(83)     ); --o--
  res_csa_85: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(85), --i--
       b    => f_mul_ex2_sum_b(85), --i--
       c    => f_mul_ex2_car_b(85), --i--
       sum  => ex2_sum_b(85)      , --o--
       car  => ex2_car_b(84)     ); --o--
  res_csa_86: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(86), --i--
       b    => f_mul_ex2_sum_b(86), --i--
       c    => f_mul_ex2_car_b(86), --i--
       sum  => ex2_sum_b(86)      , --o--
       car  => ex2_car_b(85)     ); --o--
  res_csa_87: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(87), --i--
       b    => f_mul_ex2_sum_b(87), --i--
       c    => f_mul_ex2_car_b(87), --i--
       sum  => ex2_sum_b(87)      , --o--
       car  => ex2_car_b(86)     ); --o--
  res_csa_88: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(88), --i--
       b    => f_mul_ex2_sum_b(88), --i--
       c    => f_mul_ex2_car_b(88), --i--
       sum  => ex2_sum_b(88)      , --o--
       car  => ex2_car_b(87)     ); --o--
  res_csa_89: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(89), --i--
       b    => f_mul_ex2_sum_b(89), --i--
       c    => f_mul_ex2_car_b(89), --i--
       sum  => ex2_sum_b(89)      , --o--
       car  => ex2_car_b(88)     ); --o--
  res_csa_90: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(90), --i--
       b    => f_mul_ex2_sum_b(90), --i--
       c    => f_mul_ex2_car_b(90), --i--
       sum  => ex2_sum_b(90)      , --o--
       car  => ex2_car_b(89)     ); --o--
  res_csa_91: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(91), --i--
       b    => f_mul_ex2_sum_b(91), --i--
       c    => f_mul_ex2_car_b(91), --i--
       sum  => ex2_sum_b(91)      , --o--
       car  => ex2_car_b(90)     ); --o--
  res_csa_92: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(92), --i--
       b    => f_mul_ex2_sum_b(92), --i--
       c    => f_mul_ex2_car_b(92), --i--
       sum  => ex2_sum_b(92)      , --o--
       car  => ex2_car_b(91)     ); --o--
  res_csa_93: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(93), --i--
       b    => f_mul_ex2_sum_b(93), --i--
       c    => f_mul_ex2_car_b(93), --i--
       sum  => ex2_sum_b(93)      , --o--
       car  => ex2_car_b(92)     ); --o--
  res_csa_94: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(94), --i--
       b    => f_mul_ex2_sum_b(94), --i--
       c    => f_mul_ex2_car_b(94), --i--
       sum  => ex2_sum_b(94)      , --o--
       car  => ex2_car_b(93)     ); --o--
  res_csa_95: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(95), --i--
       b    => f_mul_ex2_sum_b(95), --i--
       c    => f_mul_ex2_car_b(95), --i--
       sum  => ex2_sum_b(95)      , --o--
       car  => ex2_car_b(94)     ); --o--
  res_csa_96: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(96), --i--
       b    => f_mul_ex2_sum_b(96), --i--
       c    => f_mul_ex2_car_b(96), --i--
       sum  => ex2_sum_b(96)      , --o--
       car  => ex2_car_b(95)     ); --o--
  res_csa_97: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(97), --i--
       b    => f_mul_ex2_sum_b(97), --i--
       c    => f_mul_ex2_car_b(97), --i--
       sum  => ex2_sum_b(97)      , --o--
       car  => ex2_car_b(96)     ); --o--
  res_csa_98: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(98), --i--
       b    => f_mul_ex2_sum_b(98), --i--
       c    => f_mul_ex2_car_b(98), --i--
       sum  => ex2_sum_b(98)      , --o--
       car  => ex2_car_b(97)     ); --o--
  res_csa_99: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(99), --i--
       b    => f_mul_ex2_sum_b(99), --i--
       c    => f_mul_ex2_car_b(99), --i--
       sum  => ex2_sum_b(99)      , --o--
       car  => ex2_car_b(98)     ); --o--
  res_csa_100: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(100), --i--
       b    => f_mul_ex2_sum_b(100), --i--
       c    => f_mul_ex2_car_b(100), --i--
       sum  => ex2_sum_b(100)      , --o--
       car  => ex2_car_b(99)     ); --o--
  res_csa_101: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(101), --i--
       b    => f_mul_ex2_sum_b(101), --i--
       c    => f_mul_ex2_car_b(101), --i--
       sum  => ex2_sum_b(101)      , --o--
       car  => ex2_car_b(100)     ); --o--
  res_csa_102: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(102), --i--
       b    => f_mul_ex2_sum_b(102), --i--
       c    => f_mul_ex2_car_b(102), --i--
       sum  => ex2_sum_b(102)      , --o--
       car  => ex2_car_b(101)     ); --o--
  res_csa_103: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(103), --i--
       b    => f_mul_ex2_sum_b(103), --i--
       c    => f_mul_ex2_car_b(103), --i--
       sum  => ex2_sum_b(103)      , --o--
       car  => ex2_car_b(102)     ); --o--
  res_csa_104: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(104), --i--
       b    => f_mul_ex2_sum_b(104), --i--
       c    => f_mul_ex2_car_b(104), --i--
       sum  => ex2_sum_b(104)      , --o--
       car  => ex2_car_b(103)     ); --o--
  res_csa_105: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(105), --i--
       b    => f_mul_ex2_sum_b(105), --i--
       c    => f_mul_ex2_car_b(105), --i--
       sum  => ex2_sum_b(105)      , --o--
       car  => ex2_car_b(104)     ); --o--
  res_csa_106: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(106), --i--
       b    => f_mul_ex2_sum_b(106), --i--
       c    => f_mul_ex2_car_b(106), --i--
       sum  => ex2_sum_b(106)      , --o--
       car  => ex2_car_b(105)     ); --o--
  res_csa_107: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(107), --i--
       b    => f_mul_ex2_sum_b(107), --i--
       c    => f_mul_ex2_car_b(107), --i--
       sum  => ex2_sum_b(107)      , --o--
       car  => ex2_car_b(106)     ); --o--
  res_csa_108: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(108), --i--
       b    => f_mul_ex2_sum_b(108), --i--
       c    => f_mul_ex2_car_b(108), --i--
       sum  => ex2_sum_b(108)      , --o--
       car  => ex2_car_b(107)     ); --o--
  res_csa_109: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(109), --i--
       b    => f_mul_ex2_sum_b(109), --i--
       c    => f_mul_ex2_car_b(109), --i--
       sum  => ex2_sum_b(109)      , --o--
       car  => ex2_car_b(108)     ); --o--
  res_csa_110: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(110), --i--
       b    => f_mul_ex2_sum_b(110), --i--
       c    => f_mul_ex2_car_b(110), --i--
       sum  => ex2_sum_b(110)      , --o--
       car  => ex2_car_b(109)     ); --o--
  res_csa_111: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(111), --i--
       b    => f_mul_ex2_sum_b(111), --i--
       c    => f_mul_ex2_car_b(111), --i--
       sum  => ex2_sum_b(111)      , --o--
       car  => ex2_car_b(110)     ); --o--
  res_csa_112: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(112), --i--
       b    => f_mul_ex2_sum_b(112), --i--
       c    => f_mul_ex2_car_b(112), --i--
       sum  => ex2_sum_b(112)      , --o--
       car  => ex2_car_b(111)     ); --o--
  res_csa_113: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(113), --i--
       b    => f_mul_ex2_sum_b(113), --i--
       c    => f_mul_ex2_car_b(113), --i--
       sum  => ex2_sum_b(113)      , --o--
       car  => ex2_car_b(112)     ); --o--
  res_csa_114: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(114), --i--
       b    => f_mul_ex2_sum_b(114), --i--
       c    => f_mul_ex2_car_b(114), --i--
       sum  => ex2_sum_b(114)      , --o--
       car  => ex2_car_b(113)     ); --o--
  res_csa_115: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(115), --i--
       b    => f_mul_ex2_sum_b(115), --i--
       c    => f_mul_ex2_car_b(115), --i--
       sum  => ex2_sum_b(115)      , --o--
       car  => ex2_car_b(114)     ); --o--
  res_csa_116: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(116), --i--
       b    => f_mul_ex2_sum_b(116), --i--
       c    => f_mul_ex2_car_b(116), --i--
       sum  => ex2_sum_b(116)      , --o--
       car  => ex2_car_b(115)     ); --o--
  res_csa_117: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(117), --i--
       b    => f_mul_ex2_sum_b(117), --i--
       c    => f_mul_ex2_car_b(117), --i--
       sum  => ex2_sum_b(117)      , --o--
       car  => ex2_car_b(116)     ); --o--
  res_csa_118: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(118), --i--
       b    => f_mul_ex2_sum_b(118), --i--
       c    => f_mul_ex2_car_b(118), --i--
       sum  => ex2_sum_b(118)      , --o--
       car  => ex2_car_b(117)     ); --o--
  res_csa_119: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(119), --i--
       b    => f_mul_ex2_sum_b(119), --i--
       c    => f_mul_ex2_car_b(119), --i--
       sum  => ex2_sum_b(119)      , --o--
       car  => ex2_car_b(118)     ); --o--
  res_csa_120: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(120), --i--
       b    => f_mul_ex2_sum_b(120), --i--
       c    => f_mul_ex2_car_b(120), --i--
       sum  => ex2_sum_b(120)      , --o--
       car  => ex2_car_b(119)     ); --o--
  res_csa_121: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(121), --i--
       b    => f_mul_ex2_sum_b(121), --i--
       c    => f_mul_ex2_car_b(121), --i--
       sum  => ex2_sum_b(121)      , --o--
       car  => ex2_car_b(120)     ); --o--
  res_csa_122: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(122), --i--
       b    => f_mul_ex2_sum_b(122), --i--
       c    => f_mul_ex2_car_b(122), --i--
       sum  => ex2_sum_b(122)      , --o--
       car  => ex2_car_b(121)     ); --o--
  res_csa_123: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(123), --i--
       b    => f_mul_ex2_sum_b(123), --i--
       c    => f_mul_ex2_car_b(123), --i--
       sum  => ex2_sum_b(123)      , --o--
       car  => ex2_car_b(122)     ); --o--
  res_csa_124: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(124), --i--
       b    => f_mul_ex2_sum_b(124), --i--
       c    => f_mul_ex2_car_b(124), --i--
       sum  => ex2_sum_b(124)      , --o--
       car  => ex2_car_b(123)     ); --o--
  res_csa_125: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(125), --i--
       b    => f_mul_ex2_sum_b(125), --i--
       c    => f_mul_ex2_car_b(125), --i--
       sum  => ex2_sum_b(125)      , --o--
       car  => ex2_car_b(124)     ); --o--
  res_csa_126: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(126), --i--
       b    => f_mul_ex2_sum_b(126), --i--
       c    => f_mul_ex2_car_b(126), --i--
       sum  => ex2_sum_b(126)      , --o--
       car  => ex2_car_b(125)     ); --o--
  res_csa_127: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(127), --i--
       b    => f_mul_ex2_sum_b(127), --i--
       c    => f_mul_ex2_car_b(127), --i--
       sum  => ex2_sum_b(127)      , --o--
       car  => ex2_car_b(126)     ); --o--
  res_csa_128: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(128), --i--
       b    => f_mul_ex2_sum_b(128), --i--
       c    => f_mul_ex2_car_b(128), --i--
       sum  => ex2_sum_b(128)      , --o--
       car  => ex2_car_b(127)     ); --o--
  res_csa_129: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(129), --i--
       b    => f_mul_ex2_sum_b(129), --i--
       c    => f_mul_ex2_car_b(129), --i--
       sum  => ex2_sum_b(129)      , --o--
       car  => ex2_car_b(128)     ); --o--
  res_csa_130: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(130), --i--
       b    => f_mul_ex2_sum_b(130), --i--
       c    => f_mul_ex2_car_b(130), --i--
       sum  => ex2_sum_b(130)      , --o--
       car  => ex2_car_b(129)     ); --o--
  res_csa_131: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(131), --i--
       b    => f_mul_ex2_sum_b(131), --i--
       c    => f_mul_ex2_car_b(131), --i--
       sum  => ex2_sum_b(131)      , --o--
       car  => ex2_car_b(130)     ); --o--
  res_csa_132: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(132), --i--
       b    => f_mul_ex2_sum_b(132), --i--
       c    => f_mul_ex2_car_b(132), --i--
       sum  => ex2_sum_b(132)      , --o--
       car  => ex2_car_b(131)     ); --o--
  res_csa_133: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(133), --i--
       b    => f_mul_ex2_sum_b(133), --i--
       c    => f_mul_ex2_car_b(133), --i--
       sum  => ex2_sum_b(133)      , --o--
       car  => ex2_car_b(132)     ); --o--
  res_csa_134: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(134), --i--
       b    => f_mul_ex2_sum_b(134), --i--
       c    => f_mul_ex2_car_b(134), --i--
       sum  => ex2_sum_b(134)      , --o--
       car  => ex2_car_b(133)     ); --o--
  res_csa_135: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(135), --i--
       b    => f_mul_ex2_sum_b(135), --i--
       c    => f_mul_ex2_car_b(135), --i--
       sum  => ex2_sum_b(135)      , --o--
       car  => ex2_car_b(134)     ); --o--
  res_csa_136: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(136), --i--
       b    => f_mul_ex2_sum_b(136), --i--
       c    => f_mul_ex2_car_b(136), --i--
       sum  => ex2_sum_b(136)      , --o--
       car  => ex2_car_b(135)     ); --o--
  res_csa_137: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(137), --i--
       b    => f_mul_ex2_sum_b(137), --i--
       c    => f_mul_ex2_car_b(137), --i--
       sum  => ex2_sum_b(137)      , --o--
       car  => ex2_car_b(136)     ); --o--
  res_csa_138: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(138), --i--
       b    => f_mul_ex2_sum_b(138), --i--
       c    => f_mul_ex2_car_b(138), --i--
       sum  => ex2_sum_b(138)      , --o--
       car  => ex2_car_b(137)     ); --o--
  res_csa_139: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(139), --i--
       b    => f_mul_ex2_sum_b(139), --i--
       c    => f_mul_ex2_car_b(139), --i--
       sum  => ex2_sum_b(139)      , --o--
       car  => ex2_car_b(138)     ); --o--
  res_csa_140: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(140), --i--
       b    => f_mul_ex2_sum_b(140), --i--
       c    => f_mul_ex2_car_b(140), --i--
       sum  => ex2_sum_b(140)      , --o--
       car  => ex2_car_b(139)     ); --o--
  res_csa_141: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(141), --i--
       b    => f_mul_ex2_sum_b(141), --i--
       c    => f_mul_ex2_car_b(141), --i--
       sum  => ex2_sum_b(141)      , --o--
       car  => ex2_car_b(140)     ); --o--
  res_csa_142: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(142), --i--
       b    => f_mul_ex2_sum_b(142), --i--
       c    => f_mul_ex2_car_b(142), --i--
       sum  => ex2_sum_b(142)      , --o--
       car  => ex2_car_b(141)     ); --o--
  res_csa_143: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(143), --i--
       b    => f_mul_ex2_sum_b(143), --i--
       c    => f_mul_ex2_car_b(143), --i--
       sum  => ex2_sum_b(143)      , --o--
       car  => ex2_car_b(142)     ); --o--
  res_csa_144: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(144), --i--
       b    => f_mul_ex2_sum_b(144), --i--
       c    => f_mul_ex2_car_b(144), --i--
       sum  => ex2_sum_b(144)      , --o--
       car  => ex2_car_b(143)     ); --o--
  res_csa_145: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(145), --i--
       b    => f_mul_ex2_sum_b(145), --i--
       c    => f_mul_ex2_car_b(145), --i--
       sum  => ex2_sum_b(145)      , --o--
       car  => ex2_car_b(144)     ); --o--
  res_csa_146: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(146), --i--
       b    => f_mul_ex2_sum_b(146), --i--
       c    => f_mul_ex2_car_b(146), --i--
       sum  => ex2_sum_b(146)      , --o--
       car  => ex2_car_b(145)     ); --o--
  res_csa_147: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(147), --i--
       b    => f_mul_ex2_sum_b(147), --i--
       c    => f_mul_ex2_car_b(147), --i--
       sum  => ex2_sum_b(147)      , --o--
       car  => ex2_car_b(146)     ); --o--
  res_csa_148: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(148), --i--
       b    => f_mul_ex2_sum_b(148), --i--
       c    => f_mul_ex2_car_b(148), --i--
       sum  => ex2_sum_b(148)      , --o--
       car  => ex2_car_b(147)     ); --o--
  res_csa_149: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(149), --i--
       b    => f_mul_ex2_sum_b(149), --i--
       c    => f_mul_ex2_car_b(149), --i--
       sum  => ex2_sum_b(149)      , --o--
       car  => ex2_car_b(148)     ); --o--
  res_csa_150: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(150), --i--
       b    => f_mul_ex2_sum_b(150), --i--
       c    => f_mul_ex2_car_b(150), --i--
       sum  => ex2_sum_b(150)      , --o--
       car  => ex2_car_b(149)     ); --o--
  res_csa_151: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(151), --i--
       b    => f_mul_ex2_sum_b(151), --i--
       c    => f_mul_ex2_car_b(151), --i--
       sum  => ex2_sum_b(151)      , --o--
       car  => ex2_car_b(150)     ); --o--
  res_csa_152: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(152), --i--
       b    => f_mul_ex2_sum_b(152), --i--
       c    => f_mul_ex2_car_b(152), --i--
       sum  => ex2_sum_b(152)      , --o--
       car  => ex2_car_b(151)     ); --o--
  res_csa_153: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(153), --i--
       b    => f_mul_ex2_sum_b(153), --i--
       c    => f_mul_ex2_car_b(153), --i--
       sum  => ex2_sum_b(153)      , --o--
       car  => ex2_car_b(152)     ); --o--
  res_csa_154: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(154), --i--
       b    => f_mul_ex2_sum_b(154), --i--
       c    => f_mul_ex2_car_b(154), --i--
       sum  => ex2_sum_b(154)      , --o--
       car  => ex2_car_b(153)     ); --o--
  res_csa_155: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(155), --i--
       b    => f_mul_ex2_sum_b(155), --i--
       c    => f_mul_ex2_car_b(155), --i--
       sum  => ex2_sum_b(155)      , --o--
       car  => ex2_car_b(154)     ); --o--
  res_csa_156: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(156), --i--
       b    => f_mul_ex2_sum_b(156), --i--
       c    => f_mul_ex2_car_b(156), --i--
       sum  => ex2_sum_b(156)      , --o--
       car  => ex2_car_b(155)     ); --o--
  res_csa_157: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(157), --i--
       b    => f_mul_ex2_sum_b(157), --i--
       c    => f_mul_ex2_car_b(157), --i--
       sum  => ex2_sum_b(157)      , --o--
       car  => ex2_car_b(156)     ); --o--
  res_csa_158: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(158), --i--
       b    => f_mul_ex2_sum_b(158), --i--
       c    => f_mul_ex2_car_b(158), --i--
       sum  => ex2_sum_b(158)      , --o--
       car  => ex2_car_b(157)     ); --o--
  res_csa_159: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(159), --i--
       b    => f_mul_ex2_sum_b(159), --i--
       c    => f_mul_ex2_car_b(159), --i--
       sum  => ex2_sum_b(159)      , --o--
       car  => ex2_car_b(158)     ); --o--
  res_csa_160: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(160), --i--
       b    => f_mul_ex2_sum_b(160), --i--
       c    => f_mul_ex2_car_b(160), --i--
       sum  => ex2_sum_b(160)      , --o--
       car  => ex2_car_b(159)     ); --o--
  res_csa_161: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(161), --i--
       b    => f_mul_ex2_sum_b(161), --i--
       c    => f_mul_ex2_car_b(161), --i--
       sum  => ex2_sum_b(161)      , --o--
       car  => ex2_car_b(160)     ); --o--

  ex2_sum_b(53)        <= not f_alg_ex2_res(53)       ;
  ex2_sum_b(162)       <= not f_alg_ex2_res(162)      ;
  ex2_car_b(161)       <= tiup;

--//################################################################
--//# functional latches
--//################################################################

-- 053:068  : 16sum, 16 carry
-- 069:084
-- 085:100
-- 101:116
-- 117:132
-- 133:148
-- 149:164



    ex3_000_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 53, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => sa3_ex3_lclk               ,--lclk.clk
        D1CLK            => sa3_ex3_d1clk              ,
        D2CLK            => sa3_ex3_d2clk              ,
        SCANIN           => ex3_000_si                 ,                    
        SCANOUT          => ex3_000_so                 ,                      
        D                => ex2_alg_b(0 to 52)     ,
        QB               => ex3_sum(0 to 52)          );

    ex3_053_sum_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 110, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => sa3_ex3_lclk               ,--lclk.clk
        D1CLK            => sa3_ex3_d1clk              ,
        D2CLK            => sa3_ex3_d2clk              ,
        SCANIN           => ex3_053_sum_si             ,                    
        SCANOUT          => ex3_053_sum_so             ,                      
        D                => ex2_sum_b(53 to 162)         ,
        QB               => ex3_sum(53 to 162)        );

    ex3_053_car_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 109, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => sa3_ex3_lclk               ,--lclk.clk
        D1CLK            => sa3_ex3_d1clk              ,
        D2CLK            => sa3_ex3_d2clk              ,
        SCANIN           => ex3_053_car_si             ,                    
        SCANOUT          => ex3_053_car_so             ,                      
        D                => ex2_car_b(53 to 161)         ,
        QB               => ex3_car(53 to 161)        );





  inv_sum_lza: ex3_sum_lza_b(0 to 162)     <= not ex3_sum(0 to 162)     ;
  inv_car_lza: ex3_car_lza_b(53 to 161)    <= not ex3_car(53 to 161)    ;
  inv_sum_add: ex3_sum_add_b(0 to 162)     <= not ex3_sum(0 to 162)     ;
  inv_car_add: ex3_car_add_b(53 to 161)    <= not ex3_car(53 to 161)    ;

  buf_sum_lza: f_sa3_ex3_s_lza(0 to 162)   <= not ex3_sum_lza_b(0 to 162)  ;
  buf_car_lza: f_sa3_ex3_c_lza(53 to 161)  <= not ex3_car_lza_b(53 to 161) ;
  buf_sum_add: f_sa3_ex3_s_add(0 to 162)   <= not ex3_sum_add_b(0 to 162)  ;
  buf_car_add: f_sa3_ex3_c_add(53 to 161)  <= not ex3_car_add_b(53 to 161) ;




--//################################################################
--//# pervasive
--//################################################################

    
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

--//################################################################
--//# act
--//################################################################

    ex1_act <= not ex1_act_b ;

    act_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(2)   ,-- tidn,
        mpw1_b           => mpw1_b(2)        ,-- tidn,
        mpw2_b           => mpw2_b(0)        ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => act_so  ,                      
        scin             => act_si  ,                    
        -------------------
        din(0)             => act_spare_unused(0),
        din(1)             => act_spare_unused(1),
        din(2)             => ex1_act,
        din(3)             => act_spare_unused(2),
        din(4)             => act_spare_unused(3),
        -------------------
        dout(0)            => act_spare_unused(0),
        dout(1)            => act_spare_unused(1),
        dout(2)            => ex2_act,
        dout(3)            => act_spare_unused(2) ,
        dout(4)            => act_spare_unused(3) );

    sa3_ex3_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        delay_lclkr =>  delay_lclkr(3) ,-- tidn ,--in
        mpw1_b      =>  mpw1_b(3)      ,-- tidn ,--in
        mpw2_b      =>  mpw2_b(0)      ,-- tidn ,--in
        forcee => forcee,-- tidn ,--in
        nclk        =>  nclk                 ,--in
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        act         =>  ex2_act              ,--in
        sg          =>  sg_0                 ,--in
        thold_b     =>  thold_0_b            ,--in
        d1clk       =>  sa3_ex3_d1clk        ,--out
        d2clk       =>  sa3_ex3_d2clk        ,--out
        lclk        =>  sa3_ex3_lclk        );--out


--//################################################################
--//# scan string
--//################################################################

   ex3_053_car_si(0 to 108) <=  ex3_053_car_so(1 to 108) & f_sa3_si ;
   ex3_053_sum_si(0 to 109) <=  ex3_053_sum_so(1 to 109) & ex3_053_car_so(0);
   ex3_000_si(0 to 52)      <=  ex3_000_so(1 to 52)      & ex3_053_sum_so(0) ;
   act_si(0 to 4)           <=  act_so  (1 to 4)         & ex3_000_so(0);
   f_sa3_so                 <=  act_so(0);


end; -- fuq_sa3 ARCHITECTURE
