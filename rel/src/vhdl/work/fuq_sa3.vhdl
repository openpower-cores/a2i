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
       clkoff_b                                  :in   std_ulogic; 
       act_dis                                   :in   std_ulogic; 
       flush                                     :in   std_ulogic; 
       delay_lclkr                               :in   std_ulogic_vector(2 to 3); 
       mpw1_b                                    :in   std_ulogic_vector(2 to 3); 
       mpw2_b                                    :in   std_ulogic_vector(0 to 0); 
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; 
       nclk                                      :in   clk_logic;



       f_sa3_si                  :in  std_ulogic; 
       f_sa3_so                  :out std_ulogic; 
       ex1_act_b                 :in  std_ulogic; 

       f_mul_ex2_sum              :in  std_ulogic_vector(54 to 161); 
       f_mul_ex2_car              :in  std_ulogic_vector(54 to 161);
       f_alg_ex2_res              :in  std_ulogic_vector(0  to 162);

       f_sa3_ex3_s_lza           :out std_ulogic_vector(0  to 162); 
       f_sa3_ex3_c_lza           :out std_ulogic_vector(53 to 161); 

       f_sa3_ex3_s_add           :out std_ulogic_vector(0  to 162); 
       f_sa3_ex3_c_add           :out std_ulogic_vector(53 to 161)  
);



end fuq_sa3; 

architecture fuq_sa3 of fuq_sa3 is

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';

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


  
  
  
               
  
  ex2_sum_b(54) <= not(   not(f_mul_ex2_sum(54) or f_mul_ex2_car(54)) xor f_alg_ex2_res(54)  );                            
  ex2_car_b(53) <= not(      (f_mul_ex2_sum(54) or f_mul_ex2_car(54))  or f_alg_ex2_res(54)  );             
  
               

  
        u_algi:    ex2_alg_b(0 to 52)      <= not f_alg_ex2_res(0 to 52)  ;

  

    u_pre_a:   f_alg_ex2_res_b(55 to 161) <= not( f_alg_ex2_res(55 to 161) );
    u_pre_s:   f_mul_ex2_sum_b(55 to 161) <= not( f_mul_ex2_sum(55 to 161) );
    u_pre_c:   f_mul_ex2_car_b(55 to 161) <= not( f_mul_ex2_car(55 to 161) );

 
  res_csa_55: entity clib.c_prism_csa32  port map (  
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(55), 
       b    => f_mul_ex2_sum_b(55), 
       c    => f_mul_ex2_car_b(55), 
       sum  => ex2_sum_b(55)      , 
       car  => ex2_car_b(54)     ); 
  res_csa_56: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(56), 
       b    => f_mul_ex2_sum_b(56), 
       c    => f_mul_ex2_car_b(56), 
       sum  => ex2_sum_b(56)      , 
       car  => ex2_car_b(55)     ); 
  res_csa_57: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(57), 
       b    => f_mul_ex2_sum_b(57), 
       c    => f_mul_ex2_car_b(57), 
       sum  => ex2_sum_b(57)      , 
       car  => ex2_car_b(56)     ); 
  res_csa_58: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(58), 
       b    => f_mul_ex2_sum_b(58), 
       c    => f_mul_ex2_car_b(58), 
       sum  => ex2_sum_b(58)      , 
       car  => ex2_car_b(57)     ); 
  res_csa_59: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(59), 
       b    => f_mul_ex2_sum_b(59), 
       c    => f_mul_ex2_car_b(59), 
       sum  => ex2_sum_b(59)      , 
       car  => ex2_car_b(58)     ); 
  res_csa_60: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(60), 
       b    => f_mul_ex2_sum_b(60), 
       c    => f_mul_ex2_car_b(60), 
       sum  => ex2_sum_b(60)      , 
       car  => ex2_car_b(59)     ); 
  res_csa_61: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(61), 
       b    => f_mul_ex2_sum_b(61), 
       c    => f_mul_ex2_car_b(61), 
       sum  => ex2_sum_b(61)      , 
       car  => ex2_car_b(60)     ); 
  res_csa_62: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(62), 
       b    => f_mul_ex2_sum_b(62), 
       c    => f_mul_ex2_car_b(62), 
       sum  => ex2_sum_b(62)      , 
       car  => ex2_car_b(61)     ); 
  res_csa_63: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(63), 
       b    => f_mul_ex2_sum_b(63), 
       c    => f_mul_ex2_car_b(63), 
       sum  => ex2_sum_b(63)      , 
       car  => ex2_car_b(62)     ); 
  res_csa_64: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(64), 
       b    => f_mul_ex2_sum_b(64), 
       c    => f_mul_ex2_car_b(64), 
       sum  => ex2_sum_b(64)      , 
       car  => ex2_car_b(63)     ); 
  res_csa_65: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(65), 
       b    => f_mul_ex2_sum_b(65), 
       c    => f_mul_ex2_car_b(65), 
       sum  => ex2_sum_b(65)      , 
       car  => ex2_car_b(64)     ); 
  res_csa_66: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(66), 
       b    => f_mul_ex2_sum_b(66), 
       c    => f_mul_ex2_car_b(66), 
       sum  => ex2_sum_b(66)      , 
       car  => ex2_car_b(65)     ); 
  res_csa_67: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(67), 
       b    => f_mul_ex2_sum_b(67), 
       c    => f_mul_ex2_car_b(67), 
       sum  => ex2_sum_b(67)      , 
       car  => ex2_car_b(66)     ); 
  res_csa_68: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(68), 
       b    => f_mul_ex2_sum_b(68), 
       c    => f_mul_ex2_car_b(68), 
       sum  => ex2_sum_b(68)      , 
       car  => ex2_car_b(67)     ); 
  res_csa_69: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(69), 
       b    => f_mul_ex2_sum_b(69), 
       c    => f_mul_ex2_car_b(69), 
       sum  => ex2_sum_b(69)      , 
       car  => ex2_car_b(68)     ); 
  res_csa_70: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(70), 
       b    => f_mul_ex2_sum_b(70), 
       c    => f_mul_ex2_car_b(70), 
       sum  => ex2_sum_b(70)      , 
       car  => ex2_car_b(69)     ); 
  res_csa_71: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(71), 
       b    => f_mul_ex2_sum_b(71), 
       c    => f_mul_ex2_car_b(71), 
       sum  => ex2_sum_b(71)      , 
       car  => ex2_car_b(70)     ); 
  res_csa_72: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(72), 
       b    => f_mul_ex2_sum_b(72), 
       c    => f_mul_ex2_car_b(72), 
       sum  => ex2_sum_b(72)      , 
       car  => ex2_car_b(71)     ); 
  res_csa_73: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(73), 
       b    => f_mul_ex2_sum_b(73), 
       c    => f_mul_ex2_car_b(73), 
       sum  => ex2_sum_b(73)      , 
       car  => ex2_car_b(72)     ); 
  res_csa_74: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(74), 
       b    => f_mul_ex2_sum_b(74), 
       c    => f_mul_ex2_car_b(74), 
       sum  => ex2_sum_b(74)      , 
       car  => ex2_car_b(73)     ); 
  res_csa_75: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(75), 
       b    => f_mul_ex2_sum_b(75), 
       c    => f_mul_ex2_car_b(75), 
       sum  => ex2_sum_b(75)      , 
       car  => ex2_car_b(74)     ); 
  res_csa_76: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(76), 
       b    => f_mul_ex2_sum_b(76), 
       c    => f_mul_ex2_car_b(76), 
       sum  => ex2_sum_b(76)      , 
       car  => ex2_car_b(75)     ); 
  res_csa_77: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(77), 
       b    => f_mul_ex2_sum_b(77), 
       c    => f_mul_ex2_car_b(77), 
       sum  => ex2_sum_b(77)      , 
       car  => ex2_car_b(76)     ); 
  res_csa_78: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(78), 
       b    => f_mul_ex2_sum_b(78), 
       c    => f_mul_ex2_car_b(78), 
       sum  => ex2_sum_b(78)      , 
       car  => ex2_car_b(77)     ); 
  res_csa_79: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(79), 
       b    => f_mul_ex2_sum_b(79), 
       c    => f_mul_ex2_car_b(79), 
       sum  => ex2_sum_b(79)      , 
       car  => ex2_car_b(78)     ); 
  res_csa_80: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(80), 
       b    => f_mul_ex2_sum_b(80), 
       c    => f_mul_ex2_car_b(80), 
       sum  => ex2_sum_b(80)      , 
       car  => ex2_car_b(79)     ); 
  res_csa_81: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(81), 
       b    => f_mul_ex2_sum_b(81), 
       c    => f_mul_ex2_car_b(81), 
       sum  => ex2_sum_b(81)      , 
       car  => ex2_car_b(80)     ); 
  res_csa_82: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(82), 
       b    => f_mul_ex2_sum_b(82), 
       c    => f_mul_ex2_car_b(82), 
       sum  => ex2_sum_b(82)      , 
       car  => ex2_car_b(81)     ); 
  res_csa_83: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(83), 
       b    => f_mul_ex2_sum_b(83), 
       c    => f_mul_ex2_car_b(83), 
       sum  => ex2_sum_b(83)      , 
       car  => ex2_car_b(82)     ); 
  res_csa_84: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(84), 
       b    => f_mul_ex2_sum_b(84), 
       c    => f_mul_ex2_car_b(84), 
       sum  => ex2_sum_b(84)      , 
       car  => ex2_car_b(83)     ); 
  res_csa_85: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(85), 
       b    => f_mul_ex2_sum_b(85), 
       c    => f_mul_ex2_car_b(85), 
       sum  => ex2_sum_b(85)      , 
       car  => ex2_car_b(84)     ); 
  res_csa_86: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(86), 
       b    => f_mul_ex2_sum_b(86), 
       c    => f_mul_ex2_car_b(86), 
       sum  => ex2_sum_b(86)      , 
       car  => ex2_car_b(85)     ); 
  res_csa_87: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(87), 
       b    => f_mul_ex2_sum_b(87), 
       c    => f_mul_ex2_car_b(87), 
       sum  => ex2_sum_b(87)      , 
       car  => ex2_car_b(86)     ); 
  res_csa_88: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(88), 
       b    => f_mul_ex2_sum_b(88), 
       c    => f_mul_ex2_car_b(88), 
       sum  => ex2_sum_b(88)      , 
       car  => ex2_car_b(87)     ); 
  res_csa_89: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(89), 
       b    => f_mul_ex2_sum_b(89), 
       c    => f_mul_ex2_car_b(89), 
       sum  => ex2_sum_b(89)      , 
       car  => ex2_car_b(88)     ); 
  res_csa_90: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(90), 
       b    => f_mul_ex2_sum_b(90), 
       c    => f_mul_ex2_car_b(90), 
       sum  => ex2_sum_b(90)      , 
       car  => ex2_car_b(89)     ); 
  res_csa_91: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(91), 
       b    => f_mul_ex2_sum_b(91), 
       c    => f_mul_ex2_car_b(91), 
       sum  => ex2_sum_b(91)      , 
       car  => ex2_car_b(90)     ); 
  res_csa_92: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(92), 
       b    => f_mul_ex2_sum_b(92), 
       c    => f_mul_ex2_car_b(92), 
       sum  => ex2_sum_b(92)      , 
       car  => ex2_car_b(91)     ); 
  res_csa_93: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(93), 
       b    => f_mul_ex2_sum_b(93), 
       c    => f_mul_ex2_car_b(93), 
       sum  => ex2_sum_b(93)      , 
       car  => ex2_car_b(92)     ); 
  res_csa_94: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(94), 
       b    => f_mul_ex2_sum_b(94), 
       c    => f_mul_ex2_car_b(94), 
       sum  => ex2_sum_b(94)      , 
       car  => ex2_car_b(93)     ); 
  res_csa_95: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(95), 
       b    => f_mul_ex2_sum_b(95), 
       c    => f_mul_ex2_car_b(95), 
       sum  => ex2_sum_b(95)      , 
       car  => ex2_car_b(94)     ); 
  res_csa_96: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(96), 
       b    => f_mul_ex2_sum_b(96), 
       c    => f_mul_ex2_car_b(96), 
       sum  => ex2_sum_b(96)      , 
       car  => ex2_car_b(95)     ); 
  res_csa_97: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(97), 
       b    => f_mul_ex2_sum_b(97), 
       c    => f_mul_ex2_car_b(97), 
       sum  => ex2_sum_b(97)      , 
       car  => ex2_car_b(96)     ); 
  res_csa_98: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(98), 
       b    => f_mul_ex2_sum_b(98), 
       c    => f_mul_ex2_car_b(98), 
       sum  => ex2_sum_b(98)      , 
       car  => ex2_car_b(97)     ); 
  res_csa_99: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(99), 
       b    => f_mul_ex2_sum_b(99), 
       c    => f_mul_ex2_car_b(99), 
       sum  => ex2_sum_b(99)      , 
       car  => ex2_car_b(98)     ); 
  res_csa_100: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(100), 
       b    => f_mul_ex2_sum_b(100), 
       c    => f_mul_ex2_car_b(100), 
       sum  => ex2_sum_b(100)      , 
       car  => ex2_car_b(99)     ); 
  res_csa_101: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(101), 
       b    => f_mul_ex2_sum_b(101), 
       c    => f_mul_ex2_car_b(101), 
       sum  => ex2_sum_b(101)      , 
       car  => ex2_car_b(100)     ); 
  res_csa_102: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(102), 
       b    => f_mul_ex2_sum_b(102), 
       c    => f_mul_ex2_car_b(102), 
       sum  => ex2_sum_b(102)      , 
       car  => ex2_car_b(101)     ); 
  res_csa_103: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(103), 
       b    => f_mul_ex2_sum_b(103), 
       c    => f_mul_ex2_car_b(103), 
       sum  => ex2_sum_b(103)      , 
       car  => ex2_car_b(102)     ); 
  res_csa_104: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(104), 
       b    => f_mul_ex2_sum_b(104), 
       c    => f_mul_ex2_car_b(104), 
       sum  => ex2_sum_b(104)      , 
       car  => ex2_car_b(103)     ); 
  res_csa_105: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(105), 
       b    => f_mul_ex2_sum_b(105), 
       c    => f_mul_ex2_car_b(105), 
       sum  => ex2_sum_b(105)      , 
       car  => ex2_car_b(104)     ); 
  res_csa_106: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(106), 
       b    => f_mul_ex2_sum_b(106), 
       c    => f_mul_ex2_car_b(106), 
       sum  => ex2_sum_b(106)      , 
       car  => ex2_car_b(105)     ); 
  res_csa_107: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(107), 
       b    => f_mul_ex2_sum_b(107), 
       c    => f_mul_ex2_car_b(107), 
       sum  => ex2_sum_b(107)      , 
       car  => ex2_car_b(106)     ); 
  res_csa_108: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(108), 
       b    => f_mul_ex2_sum_b(108), 
       c    => f_mul_ex2_car_b(108), 
       sum  => ex2_sum_b(108)      , 
       car  => ex2_car_b(107)     ); 
  res_csa_109: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(109), 
       b    => f_mul_ex2_sum_b(109), 
       c    => f_mul_ex2_car_b(109), 
       sum  => ex2_sum_b(109)      , 
       car  => ex2_car_b(108)     ); 
  res_csa_110: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(110), 
       b    => f_mul_ex2_sum_b(110), 
       c    => f_mul_ex2_car_b(110), 
       sum  => ex2_sum_b(110)      , 
       car  => ex2_car_b(109)     ); 
  res_csa_111: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(111), 
       b    => f_mul_ex2_sum_b(111), 
       c    => f_mul_ex2_car_b(111), 
       sum  => ex2_sum_b(111)      , 
       car  => ex2_car_b(110)     ); 
  res_csa_112: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(112), 
       b    => f_mul_ex2_sum_b(112), 
       c    => f_mul_ex2_car_b(112), 
       sum  => ex2_sum_b(112)      , 
       car  => ex2_car_b(111)     ); 
  res_csa_113: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(113), 
       b    => f_mul_ex2_sum_b(113), 
       c    => f_mul_ex2_car_b(113), 
       sum  => ex2_sum_b(113)      , 
       car  => ex2_car_b(112)     ); 
  res_csa_114: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(114), 
       b    => f_mul_ex2_sum_b(114), 
       c    => f_mul_ex2_car_b(114), 
       sum  => ex2_sum_b(114)      , 
       car  => ex2_car_b(113)     ); 
  res_csa_115: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(115), 
       b    => f_mul_ex2_sum_b(115), 
       c    => f_mul_ex2_car_b(115), 
       sum  => ex2_sum_b(115)      , 
       car  => ex2_car_b(114)     ); 
  res_csa_116: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(116), 
       b    => f_mul_ex2_sum_b(116), 
       c    => f_mul_ex2_car_b(116), 
       sum  => ex2_sum_b(116)      , 
       car  => ex2_car_b(115)     ); 
  res_csa_117: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(117), 
       b    => f_mul_ex2_sum_b(117), 
       c    => f_mul_ex2_car_b(117), 
       sum  => ex2_sum_b(117)      , 
       car  => ex2_car_b(116)     ); 
  res_csa_118: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(118), 
       b    => f_mul_ex2_sum_b(118), 
       c    => f_mul_ex2_car_b(118), 
       sum  => ex2_sum_b(118)      , 
       car  => ex2_car_b(117)     ); 
  res_csa_119: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(119), 
       b    => f_mul_ex2_sum_b(119), 
       c    => f_mul_ex2_car_b(119), 
       sum  => ex2_sum_b(119)      , 
       car  => ex2_car_b(118)     ); 
  res_csa_120: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(120), 
       b    => f_mul_ex2_sum_b(120), 
       c    => f_mul_ex2_car_b(120), 
       sum  => ex2_sum_b(120)      , 
       car  => ex2_car_b(119)     ); 
  res_csa_121: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(121), 
       b    => f_mul_ex2_sum_b(121), 
       c    => f_mul_ex2_car_b(121), 
       sum  => ex2_sum_b(121)      , 
       car  => ex2_car_b(120)     ); 
  res_csa_122: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(122), 
       b    => f_mul_ex2_sum_b(122), 
       c    => f_mul_ex2_car_b(122), 
       sum  => ex2_sum_b(122)      , 
       car  => ex2_car_b(121)     ); 
  res_csa_123: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(123), 
       b    => f_mul_ex2_sum_b(123), 
       c    => f_mul_ex2_car_b(123), 
       sum  => ex2_sum_b(123)      , 
       car  => ex2_car_b(122)     ); 
  res_csa_124: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(124), 
       b    => f_mul_ex2_sum_b(124), 
       c    => f_mul_ex2_car_b(124), 
       sum  => ex2_sum_b(124)      , 
       car  => ex2_car_b(123)     ); 
  res_csa_125: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(125), 
       b    => f_mul_ex2_sum_b(125), 
       c    => f_mul_ex2_car_b(125), 
       sum  => ex2_sum_b(125)      , 
       car  => ex2_car_b(124)     ); 
  res_csa_126: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(126), 
       b    => f_mul_ex2_sum_b(126), 
       c    => f_mul_ex2_car_b(126), 
       sum  => ex2_sum_b(126)      , 
       car  => ex2_car_b(125)     ); 
  res_csa_127: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(127), 
       b    => f_mul_ex2_sum_b(127), 
       c    => f_mul_ex2_car_b(127), 
       sum  => ex2_sum_b(127)      , 
       car  => ex2_car_b(126)     ); 
  res_csa_128: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(128), 
       b    => f_mul_ex2_sum_b(128), 
       c    => f_mul_ex2_car_b(128), 
       sum  => ex2_sum_b(128)      , 
       car  => ex2_car_b(127)     ); 
  res_csa_129: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(129), 
       b    => f_mul_ex2_sum_b(129), 
       c    => f_mul_ex2_car_b(129), 
       sum  => ex2_sum_b(129)      , 
       car  => ex2_car_b(128)     ); 
  res_csa_130: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(130), 
       b    => f_mul_ex2_sum_b(130), 
       c    => f_mul_ex2_car_b(130), 
       sum  => ex2_sum_b(130)      , 
       car  => ex2_car_b(129)     ); 
  res_csa_131: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(131), 
       b    => f_mul_ex2_sum_b(131), 
       c    => f_mul_ex2_car_b(131), 
       sum  => ex2_sum_b(131)      , 
       car  => ex2_car_b(130)     ); 
  res_csa_132: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(132), 
       b    => f_mul_ex2_sum_b(132), 
       c    => f_mul_ex2_car_b(132), 
       sum  => ex2_sum_b(132)      , 
       car  => ex2_car_b(131)     ); 
  res_csa_133: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(133), 
       b    => f_mul_ex2_sum_b(133), 
       c    => f_mul_ex2_car_b(133), 
       sum  => ex2_sum_b(133)      , 
       car  => ex2_car_b(132)     ); 
  res_csa_134: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(134), 
       b    => f_mul_ex2_sum_b(134), 
       c    => f_mul_ex2_car_b(134), 
       sum  => ex2_sum_b(134)      , 
       car  => ex2_car_b(133)     ); 
  res_csa_135: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(135), 
       b    => f_mul_ex2_sum_b(135), 
       c    => f_mul_ex2_car_b(135), 
       sum  => ex2_sum_b(135)      , 
       car  => ex2_car_b(134)     ); 
  res_csa_136: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(136), 
       b    => f_mul_ex2_sum_b(136), 
       c    => f_mul_ex2_car_b(136), 
       sum  => ex2_sum_b(136)      , 
       car  => ex2_car_b(135)     ); 
  res_csa_137: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(137), 
       b    => f_mul_ex2_sum_b(137), 
       c    => f_mul_ex2_car_b(137), 
       sum  => ex2_sum_b(137)      , 
       car  => ex2_car_b(136)     ); 
  res_csa_138: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(138), 
       b    => f_mul_ex2_sum_b(138), 
       c    => f_mul_ex2_car_b(138), 
       sum  => ex2_sum_b(138)      , 
       car  => ex2_car_b(137)     ); 
  res_csa_139: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(139), 
       b    => f_mul_ex2_sum_b(139), 
       c    => f_mul_ex2_car_b(139), 
       sum  => ex2_sum_b(139)      , 
       car  => ex2_car_b(138)     ); 
  res_csa_140: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(140), 
       b    => f_mul_ex2_sum_b(140), 
       c    => f_mul_ex2_car_b(140), 
       sum  => ex2_sum_b(140)      , 
       car  => ex2_car_b(139)     ); 
  res_csa_141: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(141), 
       b    => f_mul_ex2_sum_b(141), 
       c    => f_mul_ex2_car_b(141), 
       sum  => ex2_sum_b(141)      , 
       car  => ex2_car_b(140)     ); 
  res_csa_142: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(142), 
       b    => f_mul_ex2_sum_b(142), 
       c    => f_mul_ex2_car_b(142), 
       sum  => ex2_sum_b(142)      , 
       car  => ex2_car_b(141)     ); 
  res_csa_143: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(143), 
       b    => f_mul_ex2_sum_b(143), 
       c    => f_mul_ex2_car_b(143), 
       sum  => ex2_sum_b(143)      , 
       car  => ex2_car_b(142)     ); 
  res_csa_144: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(144), 
       b    => f_mul_ex2_sum_b(144), 
       c    => f_mul_ex2_car_b(144), 
       sum  => ex2_sum_b(144)      , 
       car  => ex2_car_b(143)     ); 
  res_csa_145: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(145), 
       b    => f_mul_ex2_sum_b(145), 
       c    => f_mul_ex2_car_b(145), 
       sum  => ex2_sum_b(145)      , 
       car  => ex2_car_b(144)     ); 
  res_csa_146: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(146), 
       b    => f_mul_ex2_sum_b(146), 
       c    => f_mul_ex2_car_b(146), 
       sum  => ex2_sum_b(146)      , 
       car  => ex2_car_b(145)     ); 
  res_csa_147: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(147), 
       b    => f_mul_ex2_sum_b(147), 
       c    => f_mul_ex2_car_b(147), 
       sum  => ex2_sum_b(147)      , 
       car  => ex2_car_b(146)     ); 
  res_csa_148: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(148), 
       b    => f_mul_ex2_sum_b(148), 
       c    => f_mul_ex2_car_b(148), 
       sum  => ex2_sum_b(148)      , 
       car  => ex2_car_b(147)     ); 
  res_csa_149: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(149), 
       b    => f_mul_ex2_sum_b(149), 
       c    => f_mul_ex2_car_b(149), 
       sum  => ex2_sum_b(149)      , 
       car  => ex2_car_b(148)     ); 
  res_csa_150: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(150), 
       b    => f_mul_ex2_sum_b(150), 
       c    => f_mul_ex2_car_b(150), 
       sum  => ex2_sum_b(150)      , 
       car  => ex2_car_b(149)     ); 
  res_csa_151: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(151), 
       b    => f_mul_ex2_sum_b(151), 
       c    => f_mul_ex2_car_b(151), 
       sum  => ex2_sum_b(151)      , 
       car  => ex2_car_b(150)     ); 
  res_csa_152: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(152), 
       b    => f_mul_ex2_sum_b(152), 
       c    => f_mul_ex2_car_b(152), 
       sum  => ex2_sum_b(152)      , 
       car  => ex2_car_b(151)     ); 
  res_csa_153: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(153), 
       b    => f_mul_ex2_sum_b(153), 
       c    => f_mul_ex2_car_b(153), 
       sum  => ex2_sum_b(153)      , 
       car  => ex2_car_b(152)     ); 
  res_csa_154: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(154), 
       b    => f_mul_ex2_sum_b(154), 
       c    => f_mul_ex2_car_b(154), 
       sum  => ex2_sum_b(154)      , 
       car  => ex2_car_b(153)     ); 
  res_csa_155: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(155), 
       b    => f_mul_ex2_sum_b(155), 
       c    => f_mul_ex2_car_b(155), 
       sum  => ex2_sum_b(155)      , 
       car  => ex2_car_b(154)     ); 
  res_csa_156: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(156), 
       b    => f_mul_ex2_sum_b(156), 
       c    => f_mul_ex2_car_b(156), 
       sum  => ex2_sum_b(156)      , 
       car  => ex2_car_b(155)     ); 
  res_csa_157: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(157), 
       b    => f_mul_ex2_sum_b(157), 
       c    => f_mul_ex2_car_b(157), 
       sum  => ex2_sum_b(157)      , 
       car  => ex2_car_b(156)     ); 
  res_csa_158: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(158), 
       b    => f_mul_ex2_sum_b(158), 
       c    => f_mul_ex2_car_b(158), 
       sum  => ex2_sum_b(158)      , 
       car  => ex2_car_b(157)     ); 
  res_csa_159: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(159), 
       b    => f_mul_ex2_sum_b(159), 
       c    => f_mul_ex2_car_b(159), 
       sum  => ex2_sum_b(159)      , 
       car  => ex2_car_b(158)     ); 
  res_csa_160: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(160), 
       b    => f_mul_ex2_sum_b(160), 
       c    => f_mul_ex2_car_b(160), 
       sum  => ex2_sum_b(160)      , 
       car  => ex2_car_b(159)     ); 
  res_csa_161: entity clib.c_prism_csa32  port map ( 
       vd   => vdd,
       gd   => gnd,
       a    => f_alg_ex2_res_b(161), 
       b    => f_mul_ex2_sum_b(161), 
       c    => f_mul_ex2_car_b(161), 
       sum  => ex2_sum_b(161)      , 
       car  => ex2_car_b(160)     ); 

  ex2_sum_b(53)        <= not f_alg_ex2_res(53)       ;
  ex2_sum_b(162)       <= not f_alg_ex2_res(162)      ;
  ex2_car_b(161)       <= tiup;





    ex3_000_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 53, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => sa3_ex3_lclk               ,
        D1CLK            => sa3_ex3_d1clk              ,
        D2CLK            => sa3_ex3_d2clk              ,
        SCANIN           => ex3_000_si                 ,                    
        SCANOUT          => ex3_000_so                 ,                      
        D                => ex2_alg_b(0 to 52)     ,
        QB               => ex3_sum(0 to 52)          );

    ex3_053_sum_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 110, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => sa3_ex3_lclk               ,
        D1CLK            => sa3_ex3_d1clk              ,
        D2CLK            => sa3_ex3_d2clk              ,
        SCANIN           => ex3_053_sum_si             ,                    
        SCANOUT          => ex3_053_sum_so             ,                      
        D                => ex2_sum_b(53 to 162)         ,
        QB               => ex3_sum(53 to 162)        );

    ex3_053_car_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 109, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => sa3_ex3_lclk               ,
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


    ex1_act <= not ex1_act_b ;

    act_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(2)   ,
        mpw1_b           => mpw1_b(2)        ,
        mpw2_b           => mpw2_b(0)        ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => act_so  ,                      
        scin             => act_si  ,                    
        din(0)             => act_spare_unused(0),
        din(1)             => act_spare_unused(1),
        din(2)             => ex1_act,
        din(3)             => act_spare_unused(2),
        din(4)             => act_spare_unused(3),
        dout(0)            => act_spare_unused(0),
        dout(1)            => act_spare_unused(1),
        dout(2)            => ex2_act,
        dout(3)            => act_spare_unused(2) ,
        dout(4)            => act_spare_unused(3) );

    sa3_ex3_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        delay_lclkr =>  delay_lclkr(3) ,
        mpw1_b      =>  mpw1_b(3)      ,
        mpw2_b      =>  mpw2_b(0)      ,
        forcee => forcee,
        nclk        =>  nclk                 ,
        vd          =>  vdd                  ,
        gd          =>  gnd                  ,
        act         =>  ex2_act              ,
        sg          =>  sg_0                 ,
        thold_b     =>  thold_0_b            ,
        d1clk       =>  sa3_ex3_d1clk        ,
        d2clk       =>  sa3_ex3_d2clk        ,
        lclk        =>  sa3_ex3_lclk        );



   ex3_053_car_si(0 to 108) <=  ex3_053_car_so(1 to 108) & f_sa3_si ;
   ex3_053_sum_si(0 to 109) <=  ex3_053_sum_so(1 to 109) & ex3_053_car_so(0);
   ex3_000_si(0 to 52)      <=  ex3_000_so(1 to 52)      & ex3_053_sum_so(0) ;
   act_si(0 to 4)           <=  act_so  (1 to 4)         & ex3_000_so(0);
   f_sa3_so                 <=  act_so(0);


end; 
