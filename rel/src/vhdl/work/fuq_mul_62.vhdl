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

--//##########################################
--//## double precision 9:2 compressor
--//##########################################

entity fuq_mul_62 is
port(

       vdd              : inout power_logic;                  
       gnd              : inout power_logic;                  
       hot_one_92       :in std_ulogic;
       hot_one_74       :in std_ulogic;
       pp3_05           :in std_ulogic_vector(36 to 108);
       pp3_04           :in std_ulogic_vector(35 to 108);
       pp3_03           :in std_ulogic_vector(18 to  90);
       pp3_02           :in std_ulogic_vector(17 to  90);
       pp3_01           :in std_ulogic_vector( 0 to  72);
       pp3_00           :in std_ulogic_vector( 0 to  72);

       sum62            :out std_ulogic_vector(1 to 108); 
       car62            :out std_ulogic_vector(1 to 108) 

);



end fuq_mul_62; -- ENTITY

architecture fuq_mul_62 of fuq_mul_62 is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';


    signal pp4_03                   :std_ulogic_vector( 18 to 108);-- sum
    signal pp4_02                   :std_ulogic_vector( 34 to 108);-- car
    signal pp4_01                   :std_ulogic_vector(  1 to  90);-- sum
    signal pp4_00                   :std_ulogic_vector(  0 to  74);-- car
    signal pp5_00                   :std_ulogic_vector(  0 to 108);-- sum
    signal pp5_01                   :std_ulogic_vector(  1 to 108);-- car
    signal pp5_00_ko                :std_ulogic_vector( 17 to  73);-- ko

    signal pp3_05_inv, pp3_05_buf  :std_ulogic_vector(36 to 108);
    signal pp3_04_inv, pp3_04_buf  :std_ulogic_vector(35 to 108);
    signal pp3_03_inv, pp3_03_buf  :std_ulogic_vector(18 to  90);
    signal pp3_02_inv, pp3_02_buf  :std_ulogic_vector(17 to  90);
    signal pp3_01_inv              :std_ulogic_vector( 1 to  72);
    signal             pp3_01_buf  :std_ulogic_vector( 1 to  72);
    signal pp3_00_inv              :std_ulogic_vector( 1 to  72);
    signal             pp3_00_buf  :std_ulogic_vector( 1 to  72);
    signal hot_one_92_inv, hot_one_92_buf      :std_ulogic;
    signal hot_one_74_inv, hot_one_74_buf      :std_ulogic;
    signal unused :std_ulogic;






 











begin

unused <= pp4_02(92) or pp4_00(72) or pp4_00(73) or pp4_00(0) or pp5_00(0) or
          pp3_00(0) or pp3_01(0) ;-- 2 primary inputs


--//###########################################################
--//# LEON CHART
--//###########################################################
--  o : no logic done on the signal
--  c : carry
--  u : sum
--  h : hot1
--  H : hot 1 latched
--  s : sign
--  a : ! sign
--  d : data from the booth muxes
--  wWW :   01a / ass
--  Kz :    1a / 00


 --//##################################################
 --//# Compressor Level 4
 --//##################################################


--//#    0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111
--//#    0000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000
--//#    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
--//#    ....................................ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd pp3_05
--//#    ...................................dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd pp3_04
--//#    ..................ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd_d................ pp3_03
--//#    -------------------------------------------------------------------------------------------------------------
--//#    ..................ooooooooooooooooouuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuoooooooooooooooo pp4_03
--//#    ..................................cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc_oooooooooooooooo pp4_02


 inv_p3_05:   pp3_05_inv(36 to 108) <= not pp3_05(36 to 108);
 inv_p3_04:   pp3_04_inv(35 to 108) <= not pp3_04(35 to 108);
 inv_p3_03:   pp3_03_inv(18 to  90) <= not pp3_03(18 to  90);
 inv_p3_02:   pp3_02_inv(17 to  90) <= not pp3_02(17 to  90);
 inv_p3_01:   pp3_01_inv( 1 to  72) <= not pp3_01( 1 to  72);
 inv_p3_00:   pp3_00_inv( 1 to  72) <= not pp3_00( 1 to  72);
 inv_hot_one_92:   hot_one_92_inv   <= not hot_one_92 ;
 inv_hot_one_74:   hot_one_74_inv   <= not hot_one_74 ;

 buf_pp3_05:   pp3_05_buf(36 to 108) <= not pp3_05_inv(36 to 108);
 buf_pp3_04:   pp3_04_buf(35 to 108) <= not pp3_04_inv(35 to 108);
 buf_pp3_03:   pp3_03_buf(18 to  90) <= not pp3_03_inv(18 to  90);
 buf_pp3_02:   pp3_02_buf(17 to  90) <= not pp3_02_inv(17 to  90);
 buf_pp3_01:   pp3_01_buf( 1 to  72) <= not pp3_01_inv( 1 to  72);
 buf_pp3_00:   pp3_00_buf( 1 to  72) <= not pp3_00_inv( 1 to  72);
 buf_hot_one_92: hot_one_92_buf      <= not hot_one_92_inv ;
 buf_hot_one_74: hot_one_74_buf      <= not hot_one_74_inv ;

------------------------------------


                            pp4_03(93 to 108)  <= pp3_05_buf(93 to 108) ;
                            pp4_02(93 to 108)  <= pp3_04_buf(93 to 108) ;
                            pp4_02(92)         <= tidn ;

pp4_01_csa_92: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(92)            ,--i--
        b                => pp3_04_buf(92)            ,--i--
        c                => hot_one_92_buf            ,--i--
        sum              => pp4_03(92)                ,--o--
        car              => pp4_02(91)               );--o--
pp4_01_csa_91: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(
        a                => pp3_05_buf(91)            ,--i--
        b                => pp3_04_buf(91)            ,--i--
        sum              => pp4_03(91)                ,--o--
        car              => pp4_02(90)               );--o--
pp4_01_csa_90: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(90)            ,--i--
        b                => pp3_04_buf(90)            ,--i--
        c                => pp3_03_buf(90)            ,--i--
        sum              => pp4_03(90)                ,--o--
        car              => pp4_02(89)               );--o--
pp4_01_csa_89: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(89)            ,--i--
        b                => pp3_04_buf(89)            ,--i--
        c                => pp3_03_buf(89)            ,--i--
        sum              => pp4_03(89)                ,--o--
        car              => pp4_02(88)               );--o--
pp4_01_csa_88: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(88)            ,--i--
        b                => pp3_04_buf(88)            ,--i--
        c                => pp3_03_buf(88)            ,--i--
        sum              => pp4_03(88)                ,--o--
        car              => pp4_02(87)               );--o--
pp4_01_csa_87: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(87)            ,--i--
        b                => pp3_04_buf(87)            ,--i--
        c                => pp3_03_buf(87)            ,--i--
        sum              => pp4_03(87)                ,--o--
        car              => pp4_02(86)               );--o--
pp4_01_csa_86: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(86)            ,--i--
        b                => pp3_04_buf(86)            ,--i--
        c                => pp3_03_buf(86)            ,--i--
        sum              => pp4_03(86)                ,--o--
        car              => pp4_02(85)               );--o--
pp4_01_csa_85: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(85)            ,--i--
        b                => pp3_04_buf(85)            ,--i--
        c                => pp3_03_buf(85)            ,--i--
        sum              => pp4_03(85)                ,--o--
        car              => pp4_02(84)               );--o--
pp4_01_csa_84: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(84)            ,--i--
        b                => pp3_04_buf(84)            ,--i--
        c                => pp3_03_buf(84)            ,--i--
        sum              => pp4_03(84)                ,--o--
        car              => pp4_02(83)               );--o--
pp4_01_csa_83: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(83)            ,--i--
        b                => pp3_04_buf(83)            ,--i--
        c                => pp3_03_buf(83)            ,--i--
        sum              => pp4_03(83)                ,--o--
        car              => pp4_02(82)               );--o--
pp4_01_csa_82: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(82)            ,--i--
        b                => pp3_04_buf(82)            ,--i--
        c                => pp3_03_buf(82)            ,--i--
        sum              => pp4_03(82)                ,--o--
        car              => pp4_02(81)               );--o--
pp4_01_csa_81: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(81)            ,--i--
        b                => pp3_04_buf(81)            ,--i--
        c                => pp3_03_buf(81)            ,--i--
        sum              => pp4_03(81)                ,--o--
        car              => pp4_02(80)               );--o--
pp4_01_csa_80: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(80)            ,--i--
        b                => pp3_04_buf(80)            ,--i--
        c                => pp3_03_buf(80)            ,--i--
        sum              => pp4_03(80)                ,--o--
        car              => pp4_02(79)               );--o--
pp4_01_csa_79: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(79)            ,--i--
        b                => pp3_04_buf(79)            ,--i--
        c                => pp3_03_buf(79)            ,--i--
        sum              => pp4_03(79)                ,--o--
        car              => pp4_02(78)               );--o--
pp4_01_csa_78: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(78)            ,--i--
        b                => pp3_04_buf(78)            ,--i--
        c                => pp3_03_buf(78)            ,--i--
        sum              => pp4_03(78)                ,--o--
        car              => pp4_02(77)               );--o--
pp4_01_csa_77: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(77)            ,--i--
        b                => pp3_04_buf(77)            ,--i--
        c                => pp3_03_buf(77)            ,--i--
        sum              => pp4_03(77)                ,--o--
        car              => pp4_02(76)               );--o--
pp4_01_csa_76: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(76)            ,--i--
        b                => pp3_04_buf(76)            ,--i--
        c                => pp3_03_buf(76)            ,--i--
        sum              => pp4_03(76)                ,--o--
        car              => pp4_02(75)               );--o--
pp4_01_csa_75: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(75)            ,--i--
        b                => pp3_04_buf(75)            ,--i--
        c                => pp3_03_buf(75)            ,--i--
        sum              => pp4_03(75)                ,--o--
        car              => pp4_02(74)               );--o--
pp4_01_csa_74: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(74)            ,--i--
        b                => pp3_04_buf(74)            ,--i--
        c                => pp3_03_buf(74)            ,--i--
        sum              => pp4_03(74)                ,--o--
        car              => pp4_02(73)               );--o--
pp4_01_csa_73: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(73)            ,--i--
        b                => pp3_04_buf(73)            ,--i--
        c                => pp3_03_buf(73)            ,--i--
        sum              => pp4_03(73)                ,--o--
        car              => pp4_02(72)               );--o--
pp4_01_csa_72: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(72)            ,--i--
        b                => pp3_04_buf(72)            ,--i--
        c                => pp3_03_buf(72)            ,--i--
        sum              => pp4_03(72)                ,--o--
        car              => pp4_02(71)               );--o--
pp4_01_csa_71: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(71)            ,--i--
        b                => pp3_04_buf(71)            ,--i--
        c                => pp3_03_buf(71)            ,--i--
        sum              => pp4_03(71)                ,--o--
        car              => pp4_02(70)               );--o--
pp4_01_csa_70: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(70)            ,--i--
        b                => pp3_04_buf(70)            ,--i--
        c                => pp3_03_buf(70)            ,--i--
        sum              => pp4_03(70)                ,--o--
        car              => pp4_02(69)               );--o--
pp4_01_csa_69: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(69)            ,--i--
        b                => pp3_04_buf(69)            ,--i--
        c                => pp3_03_buf(69)            ,--i--
        sum              => pp4_03(69)                ,--o--
        car              => pp4_02(68)               );--o--
pp4_01_csa_68: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(68)            ,--i--
        b                => pp3_04_buf(68)            ,--i--
        c                => pp3_03_buf(68)            ,--i--
        sum              => pp4_03(68)                ,--o--
        car              => pp4_02(67)               );--o--
pp4_01_csa_67: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(67)            ,--i--
        b                => pp3_04_buf(67)            ,--i--
        c                => pp3_03_buf(67)            ,--i--
        sum              => pp4_03(67)                ,--o--
        car              => pp4_02(66)               );--o--
pp4_01_csa_66: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(66)            ,--i--
        b                => pp3_04_buf(66)            ,--i--
        c                => pp3_03_buf(66)            ,--i--
        sum              => pp4_03(66)                ,--o--
        car              => pp4_02(65)               );--o--
pp4_01_csa_65: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(65)            ,--i--
        b                => pp3_04_buf(65)            ,--i--
        c                => pp3_03_buf(65)            ,--i--
        sum              => pp4_03(65)                ,--o--
        car              => pp4_02(64)               );--o--
pp4_01_csa_64: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(64)            ,--i--
        b                => pp3_04_buf(64)            ,--i--
        c                => pp3_03_buf(64)            ,--i--
        sum              => pp4_03(64)                ,--o--
        car              => pp4_02(63)               );--o--
pp4_01_csa_63: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(63)            ,--i--
        b                => pp3_04_buf(63)            ,--i--
        c                => pp3_03_buf(63)            ,--i--
        sum              => pp4_03(63)                ,--o--
        car              => pp4_02(62)               );--o--
pp4_01_csa_62: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(62)            ,--i--
        b                => pp3_04_buf(62)            ,--i--
        c                => pp3_03_buf(62)            ,--i--
        sum              => pp4_03(62)                ,--o--
        car              => pp4_02(61)               );--o--
pp4_01_csa_61: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(61)            ,--i--
        b                => pp3_04_buf(61)            ,--i--
        c                => pp3_03_buf(61)            ,--i--
        sum              => pp4_03(61)                ,--o--
        car              => pp4_02(60)               );--o--
pp4_01_csa_60: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(60)            ,--i--
        b                => pp3_04_buf(60)            ,--i--
        c                => pp3_03_buf(60)            ,--i--
        sum              => pp4_03(60)                ,--o--
        car              => pp4_02(59)               );--o--
pp4_01_csa_59: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(59)            ,--i--
        b                => pp3_04_buf(59)            ,--i--
        c                => pp3_03_buf(59)            ,--i--
        sum              => pp4_03(59)                ,--o--
        car              => pp4_02(58)               );--o--
pp4_01_csa_58: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(58)            ,--i--
        b                => pp3_04_buf(58)            ,--i--
        c                => pp3_03_buf(58)            ,--i--
        sum              => pp4_03(58)                ,--o--
        car              => pp4_02(57)               );--o--
pp4_01_csa_57: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(57)            ,--i--
        b                => pp3_04_buf(57)            ,--i--
        c                => pp3_03_buf(57)            ,--i--
        sum              => pp4_03(57)                ,--o--
        car              => pp4_02(56)               );--o--
pp4_01_csa_56: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(56)            ,--i--
        b                => pp3_04_buf(56)            ,--i--
        c                => pp3_03_buf(56)            ,--i--
        sum              => pp4_03(56)                ,--o--
        car              => pp4_02(55)               );--o--
pp4_01_csa_55: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(55)            ,--i--
        b                => pp3_04_buf(55)            ,--i--
        c                => pp3_03_buf(55)            ,--i--
        sum              => pp4_03(55)                ,--o--
        car              => pp4_02(54)               );--o--
pp4_01_csa_54: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(54)            ,--i--
        b                => pp3_04_buf(54)            ,--i--
        c                => pp3_03_buf(54)            ,--i--
        sum              => pp4_03(54)                ,--o--
        car              => pp4_02(53)               );--o--
pp4_01_csa_53: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(53)            ,--i--
        b                => pp3_04_buf(53)            ,--i--
        c                => pp3_03_buf(53)            ,--i--
        sum              => pp4_03(53)                ,--o--
        car              => pp4_02(52)               );--o--
pp4_01_csa_52: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(52)            ,--i--
        b                => pp3_04_buf(52)            ,--i--
        c                => pp3_03_buf(52)            ,--i--
        sum              => pp4_03(52)                ,--o--
        car              => pp4_02(51)               );--o--
pp4_01_csa_51: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(51)            ,--i--
        b                => pp3_04_buf(51)            ,--i--
        c                => pp3_03_buf(51)            ,--i--
        sum              => pp4_03(51)                ,--o--
        car              => pp4_02(50)               );--o--
pp4_01_csa_50: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(50)            ,--i--
        b                => pp3_04_buf(50)            ,--i--
        c                => pp3_03_buf(50)            ,--i--
        sum              => pp4_03(50)                ,--o--
        car              => pp4_02(49)               );--o--
pp4_01_csa_49: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(49)            ,--i--
        b                => pp3_04_buf(49)            ,--i--
        c                => pp3_03_buf(49)            ,--i--
        sum              => pp4_03(49)                ,--o--
        car              => pp4_02(48)               );--o--
pp4_01_csa_48: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(48)            ,--i--
        b                => pp3_04_buf(48)            ,--i--
        c                => pp3_03_buf(48)            ,--i--
        sum              => pp4_03(48)                ,--o--
        car              => pp4_02(47)               );--o--
pp4_01_csa_47: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(47)            ,--i--
        b                => pp3_04_buf(47)            ,--i--
        c                => pp3_03_buf(47)            ,--i--
        sum              => pp4_03(47)                ,--o--
        car              => pp4_02(46)               );--o--
pp4_01_csa_46: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(46)            ,--i--
        b                => pp3_04_buf(46)            ,--i--
        c                => pp3_03_buf(46)            ,--i--
        sum              => pp4_03(46)                ,--o--
        car              => pp4_02(45)               );--o--
pp4_01_csa_45: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(45)            ,--i--
        b                => pp3_04_buf(45)            ,--i--
        c                => pp3_03_buf(45)            ,--i--
        sum              => pp4_03(45)                ,--o--
        car              => pp4_02(44)               );--o--
pp4_01_csa_44: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(44)            ,--i--
        b                => pp3_04_buf(44)            ,--i--
        c                => pp3_03_buf(44)            ,--i--
        sum              => pp4_03(44)                ,--o--
        car              => pp4_02(43)               );--o--
pp4_01_csa_43: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(43)            ,--i--
        b                => pp3_04_buf(43)            ,--i--
        c                => pp3_03_buf(43)            ,--i--
        sum              => pp4_03(43)                ,--o--
        car              => pp4_02(42)               );--o--
pp4_01_csa_42: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(42)            ,--i--
        b                => pp3_04_buf(42)            ,--i--
        c                => pp3_03_buf(42)            ,--i--
        sum              => pp4_03(42)                ,--o--
        car              => pp4_02(41)               );--o--
pp4_01_csa_41: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(41)            ,--i--
        b                => pp3_04_buf(41)            ,--i--
        c                => pp3_03_buf(41)            ,--i--
        sum              => pp4_03(41)                ,--o--
        car              => pp4_02(40)               );--o--
pp4_01_csa_40: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(40)            ,--i--
        b                => pp3_04_buf(40)            ,--i--
        c                => pp3_03_buf(40)            ,--i--
        sum              => pp4_03(40)                ,--o--
        car              => pp4_02(39)               );--o--
pp4_01_csa_39: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(39)            ,--i--
        b                => pp3_04_buf(39)            ,--i--
        c                => pp3_03_buf(39)            ,--i--
        sum              => pp4_03(39)                ,--o--
        car              => pp4_02(38)               );--o--
pp4_01_csa_38: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(38)            ,--i--
        b                => pp3_04_buf(38)            ,--i--
        c                => pp3_03_buf(38)            ,--i--
        sum              => pp4_03(38)                ,--o--
        car              => pp4_02(37)               );--o--
pp4_01_csa_37: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(37)            ,--i--
        b                => pp3_04_buf(37)            ,--i--
        c                => pp3_03_buf(37)            ,--i--
        sum              => pp4_03(37)                ,--o--
        car              => pp4_02(36)               );--o--
pp4_01_csa_36: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(36)            ,--i--
        b                => pp3_04_buf(36)            ,--i--
        c                => pp3_03_buf(36)            ,--i--
        sum              => pp4_03(36)                ,--o--
        car              => pp4_02(35)               );--o--
pp4_01_csa_35: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_04_buf(35)            ,--i--
        b                => pp3_03_buf(35)            ,--i--
        sum              => pp4_03(35)                ,--o--
        car              => pp4_02(34)               );--o--

                            pp4_03(18 to 34) <= pp3_03_buf(18 to 34)  ;


--//#    0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111
--//#    0000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000
--//#    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
--//#    .................dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.................. pp3_02
--//#    ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd_d.................................. pp3_01
--//#    ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.................................... pp3_00
--//#    -------------------------------------------------------------------------------------------------------------
--//#    uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuoooooooooooooooooo.................. pp4_01
--//#    cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc__o.................................. pp4_00




                            pp4_01(73 to 90) <= pp3_02_buf(73 to 90)         ;
                            pp4_00(74)       <= hot_one_74_buf           ;
                            pp4_00(73)       <= tidn ;
                            pp4_00(72)       <= tidn ;

pp4_00_csa_72: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(72)            ,--i--
        b                => pp3_01_buf(72)            ,--i--
        c                => pp3_00_buf(72)            ,--i--
        sum              => pp4_01(72)                ,--o--
        car              => pp4_00(71)               );--o--
pp4_00_csa_71: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(71)            ,--i--
        b                => pp3_01_buf(71)            ,--i--
        c                => pp3_00_buf(71)            ,--i--
        sum              => pp4_01(71)                ,--o--
        car              => pp4_00(70)               );--o--
pp4_00_csa_70: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(70)            ,--i--
        b                => pp3_01_buf(70)            ,--i--
        c                => pp3_00_buf(70)            ,--i--
        sum              => pp4_01(70)                ,--o--
        car              => pp4_00(69)               );--o--
pp4_00_csa_69: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(69)            ,--i--
        b                => pp3_01_buf(69)            ,--i--
        c                => pp3_00_buf(69)            ,--i--
        sum              => pp4_01(69)                ,--o--
        car              => pp4_00(68)               );--o--
pp4_00_csa_68: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(68)            ,--i--
        b                => pp3_01_buf(68)            ,--i--
        c                => pp3_00_buf(68)            ,--i--
        sum              => pp4_01(68)                ,--o--
        car              => pp4_00(67)               );--o--
pp4_00_csa_67: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(67)            ,--i--
        b                => pp3_01_buf(67)            ,--i--
        c                => pp3_00_buf(67)            ,--i--
        sum              => pp4_01(67)                ,--o--
        car              => pp4_00(66)               );--o--
pp4_00_csa_66: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(66)            ,--i--
        b                => pp3_01_buf(66)            ,--i--
        c                => pp3_00_buf(66)            ,--i--
        sum              => pp4_01(66)                ,--o--
        car              => pp4_00(65)               );--o--
pp4_00_csa_65: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(65)            ,--i--
        b                => pp3_01_buf(65)            ,--i--
        c                => pp3_00_buf(65)            ,--i--
        sum              => pp4_01(65)                ,--o--
        car              => pp4_00(64)               );--o--
pp4_00_csa_64: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(64)            ,--i--
        b                => pp3_01_buf(64)            ,--i--
        c                => pp3_00_buf(64)            ,--i--
        sum              => pp4_01(64)                ,--o--
        car              => pp4_00(63)               );--o--
pp4_00_csa_63: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(63)            ,--i--
        b                => pp3_01_buf(63)            ,--i--
        c                => pp3_00_buf(63)            ,--i--
        sum              => pp4_01(63)                ,--o--
        car              => pp4_00(62)               );--o--
pp4_00_csa_62: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(62)            ,--i--
        b                => pp3_01_buf(62)            ,--i--
        c                => pp3_00_buf(62)            ,--i--
        sum              => pp4_01(62)                ,--o--
        car              => pp4_00(61)               );--o--
pp4_00_csa_61: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(61)            ,--i--
        b                => pp3_01_buf(61)            ,--i--
        c                => pp3_00_buf(61)            ,--i--
        sum              => pp4_01(61)                ,--o--
        car              => pp4_00(60)               );--o--
pp4_00_csa_60: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(60)            ,--i--
        b                => pp3_01_buf(60)            ,--i--
        c                => pp3_00_buf(60)            ,--i--
        sum              => pp4_01(60)                ,--o--
        car              => pp4_00(59)               );--o--
pp4_00_csa_59: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(59)            ,--i--
        b                => pp3_01_buf(59)            ,--i--
        c                => pp3_00_buf(59)            ,--i--
        sum              => pp4_01(59)                ,--o--
        car              => pp4_00(58)               );--o--
pp4_00_csa_58: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(58)            ,--i--
        b                => pp3_01_buf(58)            ,--i--
        c                => pp3_00_buf(58)            ,--i--
        sum              => pp4_01(58)                ,--o--
        car              => pp4_00(57)               );--o--
pp4_00_csa_57: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(57)            ,--i--
        b                => pp3_01_buf(57)            ,--i--
        c                => pp3_00_buf(57)            ,--i--
        sum              => pp4_01(57)                ,--o--
        car              => pp4_00(56)               );--o--
pp4_00_csa_56: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(56)            ,--i--
        b                => pp3_01_buf(56)            ,--i--
        c                => pp3_00_buf(56)            ,--i--
        sum              => pp4_01(56)                ,--o--
        car              => pp4_00(55)               );--o--
pp4_00_csa_55: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(55)            ,--i--
        b                => pp3_01_buf(55)            ,--i--
        c                => pp3_00_buf(55)            ,--i--
        sum              => pp4_01(55)                ,--o--
        car              => pp4_00(54)               );--o--
pp4_00_csa_54: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(54)            ,--i--
        b                => pp3_01_buf(54)            ,--i--
        c                => pp3_00_buf(54)            ,--i--
        sum              => pp4_01(54)                ,--o--
        car              => pp4_00(53)               );--o--
pp4_00_csa_53: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(53)            ,--i--
        b                => pp3_01_buf(53)            ,--i--
        c                => pp3_00_buf(53)            ,--i--
        sum              => pp4_01(53)                ,--o--
        car              => pp4_00(52)               );--o--
pp4_00_csa_52: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(52)            ,--i--
        b                => pp3_01_buf(52)            ,--i--
        c                => pp3_00_buf(52)            ,--i--
        sum              => pp4_01(52)                ,--o--
        car              => pp4_00(51)               );--o--
pp4_00_csa_51: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(51)            ,--i--
        b                => pp3_01_buf(51)            ,--i--
        c                => pp3_00_buf(51)            ,--i--
        sum              => pp4_01(51)                ,--o--
        car              => pp4_00(50)               );--o--
pp4_00_csa_50: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(50)            ,--i--
        b                => pp3_01_buf(50)            ,--i--
        c                => pp3_00_buf(50)            ,--i--
        sum              => pp4_01(50)                ,--o--
        car              => pp4_00(49)               );--o--
pp4_00_csa_49: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(49)            ,--i--
        b                => pp3_01_buf(49)            ,--i--
        c                => pp3_00_buf(49)            ,--i--
        sum              => pp4_01(49)                ,--o--
        car              => pp4_00(48)               );--o--
pp4_00_csa_48: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(48)            ,--i--
        b                => pp3_01_buf(48)            ,--i--
        c                => pp3_00_buf(48)            ,--i--
        sum              => pp4_01(48)                ,--o--
        car              => pp4_00(47)               );--o--
pp4_00_csa_47: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(47)            ,--i--
        b                => pp3_01_buf(47)            ,--i--
        c                => pp3_00_buf(47)            ,--i--
        sum              => pp4_01(47)                ,--o--
        car              => pp4_00(46)               );--o--
pp4_00_csa_46: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(46)            ,--i--
        b                => pp3_01_buf(46)            ,--i--
        c                => pp3_00_buf(46)            ,--i--
        sum              => pp4_01(46)                ,--o--
        car              => pp4_00(45)               );--o--
pp4_00_csa_45: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(45)            ,--i--
        b                => pp3_01_buf(45)            ,--i--
        c                => pp3_00_buf(45)            ,--i--
        sum              => pp4_01(45)                ,--o--
        car              => pp4_00(44)               );--o--
pp4_00_csa_44: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(44)            ,--i--
        b                => pp3_01_buf(44)            ,--i--
        c                => pp3_00_buf(44)            ,--i--
        sum              => pp4_01(44)                ,--o--
        car              => pp4_00(43)               );--o--
pp4_00_csa_43: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(43)            ,--i--
        b                => pp3_01_buf(43)            ,--i--
        c                => pp3_00_buf(43)            ,--i--
        sum              => pp4_01(43)                ,--o--
        car              => pp4_00(42)               );--o--
pp4_00_csa_42: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(42)            ,--i--
        b                => pp3_01_buf(42)            ,--i--
        c                => pp3_00_buf(42)            ,--i--
        sum              => pp4_01(42)                ,--o--
        car              => pp4_00(41)               );--o--
pp4_00_csa_41: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(41)            ,--i--
        b                => pp3_01_buf(41)            ,--i--
        c                => pp3_00_buf(41)            ,--i--
        sum              => pp4_01(41)                ,--o--
        car              => pp4_00(40)               );--o--
pp4_00_csa_40: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(40)            ,--i--
        b                => pp3_01_buf(40)            ,--i--
        c                => pp3_00_buf(40)            ,--i--
        sum              => pp4_01(40)                ,--o--
        car              => pp4_00(39)               );--o--
pp4_00_csa_39: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(39)            ,--i--
        b                => pp3_01_buf(39)            ,--i--
        c                => pp3_00_buf(39)            ,--i--
        sum              => pp4_01(39)                ,--o--
        car              => pp4_00(38)               );--o--
pp4_00_csa_38: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(38)            ,--i--
        b                => pp3_01_buf(38)            ,--i--
        c                => pp3_00_buf(38)            ,--i--
        sum              => pp4_01(38)                ,--o--
        car              => pp4_00(37)               );--o--
pp4_00_csa_37: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(37)            ,--i--
        b                => pp3_01_buf(37)            ,--i--
        c                => pp3_00_buf(37)            ,--i--
        sum              => pp4_01(37)                ,--o--
        car              => pp4_00(36)               );--o--
pp4_00_csa_36: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(36)            ,--i--
        b                => pp3_01_buf(36)            ,--i--
        c                => pp3_00_buf(36)            ,--i--
        sum              => pp4_01(36)                ,--o--
        car              => pp4_00(35)               );--o--
pp4_00_csa_35: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(35)            ,--i--
        b                => pp3_01_buf(35)            ,--i--
        c                => pp3_00_buf(35)            ,--i--
        sum              => pp4_01(35)                ,--o--
        car              => pp4_00(34)               );--o--
pp4_00_csa_34: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(34)            ,--i--
        b                => pp3_01_buf(34)            ,--i--
        c                => pp3_00_buf(34)            ,--i--
        sum              => pp4_01(34)                ,--o--
        car              => pp4_00(33)               );--o--
pp4_00_csa_33: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(33)            ,--i--
        b                => pp3_01_buf(33)            ,--i--
        c                => pp3_00_buf(33)            ,--i--
        sum              => pp4_01(33)                ,--o--
        car              => pp4_00(32)               );--o--
pp4_00_csa_32: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(32)            ,--i--
        b                => pp3_01_buf(32)            ,--i--
        c                => pp3_00_buf(32)            ,--i--
        sum              => pp4_01(32)                ,--o--
        car              => pp4_00(31)               );--o--
pp4_00_csa_31: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(31)            ,--i--
        b                => pp3_01_buf(31)            ,--i--
        c                => pp3_00_buf(31)            ,--i--
        sum              => pp4_01(31)                ,--o--
        car              => pp4_00(30)               );--o--
pp4_00_csa_30: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(30)            ,--i--
        b                => pp3_01_buf(30)            ,--i--
        c                => pp3_00_buf(30)            ,--i--
        sum              => pp4_01(30)                ,--o--
        car              => pp4_00(29)               );--o--
pp4_00_csa_29: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(29)            ,--i--
        b                => pp3_01_buf(29)            ,--i--
        c                => pp3_00_buf(29)            ,--i--
        sum              => pp4_01(29)                ,--o--
        car              => pp4_00(28)               );--o--
pp4_00_csa_28: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(28)            ,--i--
        b                => pp3_01_buf(28)            ,--i--
        c                => pp3_00_buf(28)            ,--i--
        sum              => pp4_01(28)                ,--o--
        car              => pp4_00(27)               );--o--
pp4_00_csa_27: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(27)            ,--i--
        b                => pp3_01_buf(27)            ,--i--
        c                => pp3_00_buf(27)            ,--i--
        sum              => pp4_01(27)                ,--o--
        car              => pp4_00(26)               );--o--
pp4_00_csa_26: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(26)            ,--i--
        b                => pp3_01_buf(26)            ,--i--
        c                => pp3_00_buf(26)            ,--i--
        sum              => pp4_01(26)                ,--o--
        car              => pp4_00(25)               );--o--
pp4_00_csa_25: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(25)            ,--i--
        b                => pp3_01_buf(25)            ,--i--
        c                => pp3_00_buf(25)            ,--i--
        sum              => pp4_01(25)                ,--o--
        car              => pp4_00(24)               );--o--
pp4_00_csa_24: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(24)            ,--i--
        b                => pp3_01_buf(24)            ,--i--
        c                => pp3_00_buf(24)            ,--i--
        sum              => pp4_01(24)                ,--o--
        car              => pp4_00(23)               );--o--
pp4_00_csa_23: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(23)            ,--i--
        b                => pp3_01_buf(23)            ,--i--
        c                => pp3_00_buf(23)            ,--i--
        sum              => pp4_01(23)                ,--o--
        car              => pp4_00(22)               );--o--
pp4_00_csa_22: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(22)            ,--i--
        b                => pp3_01_buf(22)            ,--i--
        c                => pp3_00_buf(22)            ,--i--
        sum              => pp4_01(22)                ,--o--
        car              => pp4_00(21)               );--o--
pp4_00_csa_21: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(21)            ,--i--
        b                => pp3_01_buf(21)            ,--i--
        c                => pp3_00_buf(21)            ,--i--
        sum              => pp4_01(21)                ,--o--
        car              => pp4_00(20)               );--o--
pp4_00_csa_20: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(20)            ,--i--
        b                => pp3_01_buf(20)            ,--i--
        c                => pp3_00_buf(20)            ,--i--
        sum              => pp4_01(20)                ,--o--
        car              => pp4_00(19)               );--o--
pp4_00_csa_19: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(19)            ,--i--
        b                => pp3_01_buf(19)            ,--i--
        c                => pp3_00_buf(19)            ,--i--
        sum              => pp4_01(19)                ,--o--
        car              => pp4_00(18)               );--o--
pp4_00_csa_18: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(18)            ,--i--
        b                => pp3_01_buf(18)            ,--i--
        c                => pp3_00_buf(18)            ,--i--
        sum              => pp4_01(18)                ,--o--
        car              => pp4_00(17)               );--o--
pp4_00_csa_17: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(17)            ,--i--
        b                => pp3_01_buf(17)            ,--i--
        c                => pp3_00_buf(17)            ,--i--
        sum              => pp4_01(17)                ,--o--
        car              => pp4_00(16)               );--o--
pp4_00_csa_16: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(16)            ,--i--
        b                => pp3_00_buf(16)            ,--i--
        sum              => pp4_01(16)                ,--o--
        car              => pp4_00(15)               );--o--
pp4_00_csa_15: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(15)            ,--i--
        b                => pp3_00_buf(15)            ,--i--
        sum              => pp4_01(15)                ,--o--
        car              => pp4_00(14)               );--o--
pp4_00_csa_14: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(14)            ,--i--
        b                => pp3_00_buf(14)            ,--i--
        sum              => pp4_01(14)                ,--o--
        car              => pp4_00(13)               );--o--
pp4_00_csa_13: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(13)            ,--i--
        b                => pp3_00_buf(13)            ,--i--
        sum              => pp4_01(13)                ,--o--
        car              => pp4_00(12)               );--o--
pp4_00_csa_12: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(12)            ,--i--
        b                => pp3_00_buf(12)            ,--i--
        sum              => pp4_01(12)                ,--o--
        car              => pp4_00(11)               );--o--
pp4_00_csa_11: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(11)            ,--i--
        b                => pp3_00_buf(11)            ,--i--
        sum              => pp4_01(11)                ,--o--
        car              => pp4_00(10)               );--o--
pp4_00_csa_10: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(10)            ,--i--
        b                => pp3_00_buf(10)            ,--i--
        sum              => pp4_01(10)                ,--o--
        car              => pp4_00(9)                );--o--
pp4_00_csa_09: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(9)             ,--i--
        b                => pp3_00_buf(9)             ,--i--
        sum              => pp4_01(9)                 ,--o--
        car              => pp4_00(8)                );--o--
pp4_00_csa_08: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(8)             ,--i--
        b                => pp3_00_buf(8)             ,--i--
        sum              => pp4_01(8)                 ,--o--
        car              => pp4_00(7)                );--o--
pp4_00_csa_07: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(7)             ,--i--
        b                => pp3_00_buf(7)             ,--i--
        sum              => pp4_01(7)                 ,--o--
        car              => pp4_00(6)                );--o--
pp4_00_csa_06: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(6)             ,--i--
        b                => pp3_00_buf(6)             ,--i--
        sum              => pp4_01(6)                 ,--o--
        car              => pp4_00(5)                );--o--
pp4_00_csa_05: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(5)             ,--i--
        b                => pp3_00_buf(5)             ,--i--
        sum              => pp4_01(5)                 ,--o--
        car              => pp4_00(4)                );--o--
pp4_00_csa_04: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(4)             ,--i--
        b                => pp3_00_buf(4)             ,--i--
        sum              => pp4_01(4)                 ,--o--
        car              => pp4_00(3)                );--o--
pp4_00_csa_03: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(3)             ,--i--
        b                => pp3_00_buf(3)             ,--i--
        sum              => pp4_01(3)                 ,--o--
        car              => pp4_00(2)                );--o--
pp4_00_csa_02: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(2)             ,--i--
        b                => pp3_00_buf(2)             ,--i--
        sum              => pp4_01(2)                 ,--o--
        car              => pp4_00(1)                );--o--
pp4_00_csa_01: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(1)             ,--i--
        b                => pp3_00_buf(1)             ,--i--
        sum              => pp4_01(1)                 ,--o--
        car              => pp4_00(0)                );--o--


 --//##################################################
 --//# Compressor Level 5
 --//##################################################

--//#    0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111
--//#    0000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000
--//#    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
--//#    ..................ooooooooooooooooouuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuoooooooooooooooo pp4_03
--//#    ..................................cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc_oooooooooooooooo pp4_02
--//#    uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuoooooooooooooooooo.................. pp4_01
--//#    cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc__o.................................. pp4_00
--//#    -------------------------------------------------------------------------------------------------------------
--//#    uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuoooooooooooooooooo pp5_01
--//#    cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc_o_oooooooooooooooo pp5_00
 


                            pp5_01(91 to 108)      <= pp4_03(91 to 108) ;
                            pp5_00(93 to 108)      <= pp4_02(93 to 108) ;
                            pp5_00(92)             <= tidn ;
                            pp5_00(91)             <= pp4_02(91);
                            pp5_00(90)             <= tidn;

pp5_00_csa_90: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(90)                ,--i--
        b                => pp4_02(90)                ,--i--
        c                => pp4_01(90)                ,--i--
        sum              => pp5_01(90)                ,--o--
        car              => pp5_00(89)               );--o--
pp5_00_csa_89: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(89)                ,--i--
        b                => pp4_02(89)                ,--i--
        c                => pp4_01(89)                ,--i--
        sum              => pp5_01(89)                ,--o--
        car              => pp5_00(88)               );--o--
pp5_00_csa_88: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(88)                ,--i--
        b                => pp4_02(88)                ,--i--
        c                => pp4_01(88)                ,--i--
        sum              => pp5_01(88)                ,--o--
        car              => pp5_00(87)               );--o--
pp5_00_csa_87: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(87)                ,--i--
        b                => pp4_02(87)                ,--i--
        c                => pp4_01(87)                ,--i--
        sum              => pp5_01(87)                ,--o--
        car              => pp5_00(86)               );--o--
pp5_00_csa_86: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(86)                ,--i--
        b                => pp4_02(86)                ,--i--
        c                => pp4_01(86)                ,--i--
        sum              => pp5_01(86)                ,--o--
        car              => pp5_00(85)               );--o--
pp5_00_csa_85: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(85)                ,--i--
        b                => pp4_02(85)                ,--i--
        c                => pp4_01(85)                ,--i--
        sum              => pp5_01(85)                ,--o--
        car              => pp5_00(84)               );--o--
pp5_00_csa_84: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(84)                ,--i--
        b                => pp4_02(84)                ,--i--
        c                => pp4_01(84)                ,--i--
        sum              => pp5_01(84)                ,--o--
        car              => pp5_00(83)               );--o--
pp5_00_csa_83: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(83)                ,--i--
        b                => pp4_02(83)                ,--i--
        c                => pp4_01(83)                ,--i--
        sum              => pp5_01(83)                ,--o--
        car              => pp5_00(82)               );--o--
pp5_00_csa_82: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(82)                ,--i--
        b                => pp4_02(82)                ,--i--
        c                => pp4_01(82)                ,--i--
        sum              => pp5_01(82)                ,--o--
        car              => pp5_00(81)               );--o--
pp5_00_csa_81: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(81)                ,--i--
        b                => pp4_02(81)                ,--i--
        c                => pp4_01(81)                ,--i--
        sum              => pp5_01(81)                ,--o--
        car              => pp5_00(80)               );--o--
pp5_00_csa_80: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(80)                ,--i--
        b                => pp4_02(80)                ,--i--
        c                => pp4_01(80)                ,--i--
        sum              => pp5_01(80)                ,--o--
        car              => pp5_00(79)               );--o--
pp5_00_csa_79: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(79)                ,--i--
        b                => pp4_02(79)                ,--i--
        c                => pp4_01(79)                ,--i--
        sum              => pp5_01(79)                ,--o--
        car              => pp5_00(78)               );--o--
pp5_00_csa_78: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(78)                ,--i--
        b                => pp4_02(78)                ,--i--
        c                => pp4_01(78)                ,--i--
        sum              => pp5_01(78)                ,--o--
        car              => pp5_00(77)               );--o--
pp5_00_csa_77: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(77)                ,--i--
        b                => pp4_02(77)                ,--i--
        c                => pp4_01(77)                ,--i--
        sum              => pp5_01(77)                ,--o--
        car              => pp5_00(76)               );--o--
pp5_00_csa_76: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(76)                ,--i--
        b                => pp4_02(76)                ,--i--
        c                => pp4_01(76)                ,--i--
        sum              => pp5_01(76)                ,--o--
        car              => pp5_00(75)               );--o--
pp5_00_csa_75: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(75)                ,--i--
        b                => pp4_02(75)                ,--i--
        c                => pp4_01(75)                ,--i--
        sum              => pp5_01(75)                ,--o--
        car              => pp5_00(74)               );--o--
pp5_00_csa_74: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(74)                ,--i--
        b                => pp4_02(74)                ,--i--
        c                => pp4_01(74)                ,--i--
        d                => pp4_00(74)                ,--i--
        ki               => tidn                      ,--i--
        ko               => pp5_00_ko(73)             ,--o--
        sum              => pp5_01(74)                ,--o--
        car              => pp5_00(73)               );--o--
pp5_00_csa_73: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(73)                ,--i--
        b                => pp4_02(73)                ,--i--
        c                => pp4_01(73)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(73)             ,--i--
        ko               => pp5_00_ko(72)             ,--o--
        sum              => pp5_01(73)                ,--o--
        car              => pp5_00(72)               );--o--
pp5_00_csa_72: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(72)                ,--i--
        b                => pp4_02(72)                ,--i--
        c                => pp4_01(72)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(72)             ,--i--
        ko               => pp5_00_ko(71)             ,--o--
        sum              => pp5_01(72)                ,--o--
        car              => pp5_00(71)               );--o--
pp5_00_csa_71: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(71)                ,--i--
        b                => pp4_02(71)                ,--i--
        c                => pp4_01(71)                ,--i--
        d                => pp4_00(71)                ,--i--
        ki               => pp5_00_ko(71)             ,--i--
        ko               => pp5_00_ko(70)             ,--o--
        sum              => pp5_01(71)                ,--o--
        car              => pp5_00(70)               );--o--
pp5_00_csa_70: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(70)                ,--i--
        b                => pp4_02(70)                ,--i--
        c                => pp4_01(70)                ,--i--
        d                => pp4_00(70)                ,--i--
        ki               => pp5_00_ko(70)             ,--i--
        ko               => pp5_00_ko(69)             ,--o--
        sum              => pp5_01(70)                ,--o--
        car              => pp5_00(69)               );--o--
pp5_00_csa_69: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(69)                ,--i--
        b                => pp4_02(69)                ,--i--
        c                => pp4_01(69)                ,--i--
        d                => pp4_00(69)                ,--i--
        ki               => pp5_00_ko(69)             ,--i--
        ko               => pp5_00_ko(68)             ,--o--
        sum              => pp5_01(69)                ,--o--
        car              => pp5_00(68)               );--o--
pp5_00_csa_68: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(68)                ,--i--
        b                => pp4_02(68)                ,--i--
        c                => pp4_01(68)                ,--i--
        d                => pp4_00(68)                ,--i--
        ki               => pp5_00_ko(68)             ,--i--
        ko               => pp5_00_ko(67)             ,--o--
        sum              => pp5_01(68)                ,--o--
        car              => pp5_00(67)               );--o--
pp5_00_csa_67: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(67)                ,--i--
        b                => pp4_02(67)                ,--i--
        c                => pp4_01(67)                ,--i--
        d                => pp4_00(67)                ,--i--
        ki               => pp5_00_ko(67)             ,--i--
        ko               => pp5_00_ko(66)             ,--o--
        sum              => pp5_01(67)                ,--o--
        car              => pp5_00(66)               );--o--
pp5_00_csa_66: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(66)                ,--i--
        b                => pp4_02(66)                ,--i--
        c                => pp4_01(66)                ,--i--
        d                => pp4_00(66)                ,--i--
        ki               => pp5_00_ko(66)             ,--i--
        ko               => pp5_00_ko(65)             ,--o--
        sum              => pp5_01(66)                ,--o--
        car              => pp5_00(65)               );--o--
pp5_00_csa_65: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(65)                ,--i--
        b                => pp4_02(65)                ,--i--
        c                => pp4_01(65)                ,--i--
        d                => pp4_00(65)                ,--i--
        ki               => pp5_00_ko(65)             ,--i--
        ko               => pp5_00_ko(64)             ,--o--
        sum              => pp5_01(65)                ,--o--
        car              => pp5_00(64)               );--o--
pp5_00_csa_64: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(64)                ,--i--
        b                => pp4_02(64)                ,--i--
        c                => pp4_01(64)                ,--i--
        d                => pp4_00(64)                ,--i--
        ki               => pp5_00_ko(64)             ,--i--
        ko               => pp5_00_ko(63)             ,--o--
        sum              => pp5_01(64)                ,--o--
        car              => pp5_00(63)               );--o--
pp5_00_csa_63: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(63)                ,--i--
        b                => pp4_02(63)                ,--i--
        c                => pp4_01(63)                ,--i--
        d                => pp4_00(63)                ,--i--
        ki               => pp5_00_ko(63)             ,--i--
        ko               => pp5_00_ko(62)             ,--o--
        sum              => pp5_01(63)                ,--o--
        car              => pp5_00(62)               );--o--
pp5_00_csa_62: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(62)                ,--i--
        b                => pp4_02(62)                ,--i--
        c                => pp4_01(62)                ,--i--
        d                => pp4_00(62)                ,--i--
        ki               => pp5_00_ko(62)             ,--i--
        ko               => pp5_00_ko(61)             ,--o--
        sum              => pp5_01(62)                ,--o--
        car              => pp5_00(61)               );--o--
pp5_00_csa_61: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(61)                ,--i--
        b                => pp4_02(61)                ,--i--
        c                => pp4_01(61)                ,--i--
        d                => pp4_00(61)                ,--i--
        ki               => pp5_00_ko(61)             ,--i--
        ko               => pp5_00_ko(60)             ,--o--
        sum              => pp5_01(61)                ,--o--
        car              => pp5_00(60)               );--o--
pp5_00_csa_60: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(60)                ,--i--
        b                => pp4_02(60)                ,--i--
        c                => pp4_01(60)                ,--i--
        d                => pp4_00(60)                ,--i--
        ki               => pp5_00_ko(60)             ,--i--
        ko               => pp5_00_ko(59)             ,--o--
        sum              => pp5_01(60)                ,--o--
        car              => pp5_00(59)               );--o--
pp5_00_csa_59: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(59)                ,--i--
        b                => pp4_02(59)                ,--i--
        c                => pp4_01(59)                ,--i--
        d                => pp4_00(59)                ,--i--
        ki               => pp5_00_ko(59)             ,--i--
        ko               => pp5_00_ko(58)             ,--o--
        sum              => pp5_01(59)                ,--o--
        car              => pp5_00(58)               );--o--
pp5_00_csa_58: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(58)                ,--i--
        b                => pp4_02(58)                ,--i--
        c                => pp4_01(58)                ,--i--
        d                => pp4_00(58)                ,--i--
        ki               => pp5_00_ko(58)             ,--i--
        ko               => pp5_00_ko(57)             ,--o--
        sum              => pp5_01(58)                ,--o--
        car              => pp5_00(57)               );--o--
pp5_00_csa_57: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(57)                ,--i--
        b                => pp4_02(57)                ,--i--
        c                => pp4_01(57)                ,--i--
        d                => pp4_00(57)                ,--i--
        ki               => pp5_00_ko(57)             ,--i--
        ko               => pp5_00_ko(56)             ,--o--
        sum              => pp5_01(57)                ,--o--
        car              => pp5_00(56)               );--o--
pp5_00_csa_56: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(56)                ,--i--
        b                => pp4_02(56)                ,--i--
        c                => pp4_01(56)                ,--i--
        d                => pp4_00(56)                ,--i--
        ki               => pp5_00_ko(56)             ,--i--
        ko               => pp5_00_ko(55)             ,--o--
        sum              => pp5_01(56)                ,--o--
        car              => pp5_00(55)               );--o--
pp5_00_csa_55: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(55)                ,--i--
        b                => pp4_02(55)                ,--i--
        c                => pp4_01(55)                ,--i--
        d                => pp4_00(55)                ,--i--
        ki               => pp5_00_ko(55)             ,--i--
        ko               => pp5_00_ko(54)             ,--o--
        sum              => pp5_01(55)                ,--o--
        car              => pp5_00(54)               );--o--
pp5_00_csa_54: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(54)                ,--i--
        b                => pp4_02(54)                ,--i--
        c                => pp4_01(54)                ,--i--
        d                => pp4_00(54)                ,--i--
        ki               => pp5_00_ko(54)             ,--i--
        ko               => pp5_00_ko(53)             ,--o--
        sum              => pp5_01(54)                ,--o--
        car              => pp5_00(53)               );--o--
pp5_00_csa_53: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(53)                ,--i--
        b                => pp4_02(53)                ,--i--
        c                => pp4_01(53)                ,--i--
        d                => pp4_00(53)                ,--i--
        ki               => pp5_00_ko(53)             ,--i--
        ko               => pp5_00_ko(52)             ,--o--
        sum              => pp5_01(53)                ,--o--
        car              => pp5_00(52)               );--o--
pp5_00_csa_52: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(52)                ,--i--
        b                => pp4_02(52)                ,--i--
        c                => pp4_01(52)                ,--i--
        d                => pp4_00(52)                ,--i--
        ki               => pp5_00_ko(52)             ,--i--
        ko               => pp5_00_ko(51)             ,--o--
        sum              => pp5_01(52)                ,--o--
        car              => pp5_00(51)               );--o--
pp5_00_csa_51: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(51)                ,--i--
        b                => pp4_02(51)                ,--i--
        c                => pp4_01(51)                ,--i--
        d                => pp4_00(51)                ,--i--
        ki               => pp5_00_ko(51)             ,--i--
        ko               => pp5_00_ko(50)             ,--o--
        sum              => pp5_01(51)                ,--o--
        car              => pp5_00(50)               );--o--
pp5_00_csa_50: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(50)                ,--i--
        b                => pp4_02(50)                ,--i--
        c                => pp4_01(50)                ,--i--
        d                => pp4_00(50)                ,--i--
        ki               => pp5_00_ko(50)             ,--i--
        ko               => pp5_00_ko(49)             ,--o--
        sum              => pp5_01(50)                ,--o--
        car              => pp5_00(49)               );--o--
pp5_00_csa_49: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(49)                ,--i--
        b                => pp4_02(49)                ,--i--
        c                => pp4_01(49)                ,--i--
        d                => pp4_00(49)                ,--i--
        ki               => pp5_00_ko(49)             ,--i--
        ko               => pp5_00_ko(48)             ,--o--
        sum              => pp5_01(49)                ,--o--
        car              => pp5_00(48)               );--o--
pp5_00_csa_48: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(48)                ,--i--
        b                => pp4_02(48)                ,--i--
        c                => pp4_01(48)                ,--i--
        d                => pp4_00(48)                ,--i--
        ki               => pp5_00_ko(48)             ,--i--
        ko               => pp5_00_ko(47)             ,--o--
        sum              => pp5_01(48)                ,--o--
        car              => pp5_00(47)               );--o--
pp5_00_csa_47: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(47)                ,--i--
        b                => pp4_02(47)                ,--i--
        c                => pp4_01(47)                ,--i--
        d                => pp4_00(47)                ,--i--
        ki               => pp5_00_ko(47)             ,--i--
        ko               => pp5_00_ko(46)             ,--o--
        sum              => pp5_01(47)                ,--o--
        car              => pp5_00(46)               );--o--
pp5_00_csa_46: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(46)                ,--i--
        b                => pp4_02(46)                ,--i--
        c                => pp4_01(46)                ,--i--
        d                => pp4_00(46)                ,--i--
        ki               => pp5_00_ko(46)             ,--i--
        ko               => pp5_00_ko(45)             ,--o--
        sum              => pp5_01(46)                ,--o--
        car              => pp5_00(45)               );--o--
pp5_00_csa_45: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(45)                ,--i--
        b                => pp4_02(45)                ,--i--
        c                => pp4_01(45)                ,--i--
        d                => pp4_00(45)                ,--i--
        ki               => pp5_00_ko(45)             ,--i--
        ko               => pp5_00_ko(44)             ,--o--
        sum              => pp5_01(45)                ,--o--
        car              => pp5_00(44)               );--o--
pp5_00_csa_44: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(44)                ,--i--
        b                => pp4_02(44)                ,--i--
        c                => pp4_01(44)                ,--i--
        d                => pp4_00(44)                ,--i--
        ki               => pp5_00_ko(44)             ,--i--
        ko               => pp5_00_ko(43)             ,--o--
        sum              => pp5_01(44)                ,--o--
        car              => pp5_00(43)               );--o--
pp5_00_csa_43: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(43)                ,--i--
        b                => pp4_02(43)                ,--i--
        c                => pp4_01(43)                ,--i--
        d                => pp4_00(43)                ,--i--
        ki               => pp5_00_ko(43)             ,--i--
        ko               => pp5_00_ko(42)             ,--o--
        sum              => pp5_01(43)                ,--o--
        car              => pp5_00(42)               );--o--
pp5_00_csa_42: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(42)                ,--i--
        b                => pp4_02(42)                ,--i--
        c                => pp4_01(42)                ,--i--
        d                => pp4_00(42)                ,--i--
        ki               => pp5_00_ko(42)             ,--i--
        ko               => pp5_00_ko(41)             ,--o--
        sum              => pp5_01(42)                ,--o--
        car              => pp5_00(41)               );--o--
pp5_00_csa_41: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(41)                ,--i--
        b                => pp4_02(41)                ,--i--
        c                => pp4_01(41)                ,--i--
        d                => pp4_00(41)                ,--i--
        ki               => pp5_00_ko(41)             ,--i--
        ko               => pp5_00_ko(40)             ,--o--
        sum              => pp5_01(41)                ,--o--
        car              => pp5_00(40)               );--o--
pp5_00_csa_40: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(40)                ,--i--
        b                => pp4_02(40)                ,--i--
        c                => pp4_01(40)                ,--i--
        d                => pp4_00(40)                ,--i--
        ki               => pp5_00_ko(40)             ,--i--
        ko               => pp5_00_ko(39)             ,--o--
        sum              => pp5_01(40)                ,--o--
        car              => pp5_00(39)               );--o--
pp5_00_csa_39: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(39)                ,--i--
        b                => pp4_02(39)                ,--i--
        c                => pp4_01(39)                ,--i--
        d                => pp4_00(39)                ,--i--
        ki               => pp5_00_ko(39)             ,--i--
        ko               => pp5_00_ko(38)             ,--o--
        sum              => pp5_01(39)                ,--o--
        car              => pp5_00(38)               );--o--
pp5_00_csa_38: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(38)                ,--i--
        b                => pp4_02(38)                ,--i--
        c                => pp4_01(38)                ,--i--
        d                => pp4_00(38)                ,--i--
        ki               => pp5_00_ko(38)             ,--i--
        ko               => pp5_00_ko(37)             ,--o--
        sum              => pp5_01(38)                ,--o--
        car              => pp5_00(37)               );--o--
pp5_00_csa_37: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(37)                ,--i--
        b                => pp4_02(37)                ,--i--
        c                => pp4_01(37)                ,--i--
        d                => pp4_00(37)                ,--i--
        ki               => pp5_00_ko(37)             ,--i--
        ko               => pp5_00_ko(36)             ,--o--
        sum              => pp5_01(37)                ,--o--
        car              => pp5_00(36)               );--o--
pp5_00_csa_36: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(36)                ,--i--
        b                => pp4_02(36)                ,--i--
        c                => pp4_01(36)                ,--i--
        d                => pp4_00(36)                ,--i--
        ki               => pp5_00_ko(36)             ,--i--
        ko               => pp5_00_ko(35)             ,--o--
        sum              => pp5_01(36)                ,--o--
        car              => pp5_00(35)               );--o--
pp5_00_csa_35: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(35)                ,--i--
        b                => pp4_02(35)                ,--i--
        c                => pp4_01(35)                ,--i--
        d                => pp4_00(35)                ,--i--
        ki               => pp5_00_ko(35)             ,--i--
        ko               => pp5_00_ko(34)             ,--o--
        sum              => pp5_01(35)                ,--o--
        car              => pp5_00(34)               );--o--
pp5_00_csa_34: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(34)                ,--i--
        b                => pp4_02(34)                ,--i--
        c                => pp4_01(34)                ,--i--
        d                => pp4_00(34)                ,--i--
        ki               => pp5_00_ko(34)             ,--i--
        ko               => pp5_00_ko(33)             ,--o--
        sum              => pp5_01(34)                ,--o--
        car              => pp5_00(33)               );--o--
pp5_00_csa_33: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(33)                ,--i--
        b                => pp4_01(33)                ,--i--
        c                => pp4_00(33)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(33)             ,--i--
        ko               => pp5_00_ko(32)             ,--o--
        sum              => pp5_01(33)                ,--o--
        car              => pp5_00(32)               );--o--
pp5_00_csa_32: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(32)                ,--i--
        b                => pp4_01(32)                ,--i--
        c                => pp4_00(32)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(32)             ,--i--
        ko               => pp5_00_ko(31)             ,--o--
        sum              => pp5_01(32)                ,--o--
        car              => pp5_00(31)               );--o--
pp5_00_csa_31: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(31)                ,--i--
        b                => pp4_01(31)                ,--i--
        c                => pp4_00(31)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(31)             ,--i--
        ko               => pp5_00_ko(30)             ,--o--
        sum              => pp5_01(31)                ,--o--
        car              => pp5_00(30)               );--o--
pp5_00_csa_30: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(30)                ,--i--
        b                => pp4_01(30)                ,--i--
        c                => pp4_00(30)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(30)             ,--i--
        ko               => pp5_00_ko(29)             ,--o--
        sum              => pp5_01(30)                ,--o--
        car              => pp5_00(29)               );--o--
pp5_00_csa_29: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(29)                ,--i--
        b                => pp4_01(29)                ,--i--
        c                => pp4_00(29)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(29)             ,--i--
        ko               => pp5_00_ko(28)             ,--o--
        sum              => pp5_01(29)                ,--o--
        car              => pp5_00(28)               );--o--
pp5_00_csa_28: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(28)                ,--i--
        b                => pp4_01(28)                ,--i--
        c                => pp4_00(28)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(28)             ,--i--
        ko               => pp5_00_ko(27)             ,--o--
        sum              => pp5_01(28)                ,--o--
        car              => pp5_00(27)               );--o--
pp5_00_csa_27: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(27)                ,--i--
        b                => pp4_01(27)                ,--i--
        c                => pp4_00(27)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(27)             ,--i--
        ko               => pp5_00_ko(26)             ,--o--
        sum              => pp5_01(27)                ,--o--
        car              => pp5_00(26)               );--o--
pp5_00_csa_26: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(26)                ,--i--
        b                => pp4_01(26)                ,--i--
        c                => pp4_00(26)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(26)             ,--i--
        ko               => pp5_00_ko(25)             ,--o--
        sum              => pp5_01(26)                ,--o--
        car              => pp5_00(25)               );--o--
pp5_00_csa_25: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(25)                ,--i--
        b                => pp4_01(25)                ,--i--
        c                => pp4_00(25)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(25)             ,--i--
        ko               => pp5_00_ko(24)             ,--o--
        sum              => pp5_01(25)                ,--o--
        car              => pp5_00(24)               );--o--
pp5_00_csa_24: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(24)                ,--i--
        b                => pp4_01(24)                ,--i--
        c                => pp4_00(24)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(24)             ,--i--
        ko               => pp5_00_ko(23)             ,--o--
        sum              => pp5_01(24)                ,--o--
        car              => pp5_00(23)               );--o--
pp5_00_csa_23: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(23)                ,--i--
        b                => pp4_01(23)                ,--i--
        c                => pp4_00(23)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(23)             ,--i--
        ko               => pp5_00_ko(22)             ,--o--
        sum              => pp5_01(23)                ,--o--
        car              => pp5_00(22)               );--o--
pp5_00_csa_22: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(22)                ,--i--
        b                => pp4_01(22)                ,--i--
        c                => pp4_00(22)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(22)             ,--i--
        ko               => pp5_00_ko(21)             ,--o--
        sum              => pp5_01(22)                ,--o--
        car              => pp5_00(21)               );--o--
pp5_00_csa_21: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(21)                ,--i--
        b                => pp4_01(21)                ,--i--
        c                => pp4_00(21)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(21)             ,--i--
        ko               => pp5_00_ko(20)             ,--o--
        sum              => pp5_01(21)                ,--o--
        car              => pp5_00(20)               );--o--
pp5_00_csa_20: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(20)                ,--i--
        b                => pp4_01(20)                ,--i--
        c                => pp4_00(20)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(20)             ,--i--
        ko               => pp5_00_ko(19)             ,--o--
        sum              => pp5_01(20)                ,--o--
        car              => pp5_00(19)               );--o--
pp5_00_csa_19: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(19)                ,--i--
        b                => pp4_01(19)                ,--i--
        c                => pp4_00(19)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(19)             ,--i--
        ko               => pp5_00_ko(18)             ,--o--
        sum              => pp5_01(19)                ,--o--
        car              => pp5_00(18)               );--o--
pp5_00_csa_18: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(18)                ,--i--
        b                => pp4_01(18)                ,--i--
        c                => pp4_00(18)                ,--i--
        d                => tidn                      ,--i--
        ki               => pp5_00_ko(18)             ,--i--
        ko               => pp5_00_ko(17)             ,--o--
        sum              => pp5_01(18)                ,--o--
        car              => pp5_00(17)               );--o--
pp5_00_csa_17: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_01(17)                ,--i--
        b                => pp4_00(17)                ,--i--
        c                => pp5_00_ko(17)             ,--i--
        sum              => pp5_01(17)                ,--o--
        car              => pp5_00(16)               );--o--
pp5_00_csa_16: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(16)                ,--i--
        b                => pp4_00(16)                ,--i--
        sum              => pp5_01(16)                ,--o--
        car              => pp5_00(15)               );--o--
pp5_00_csa_15: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(15)                ,--i--
        b                => pp4_00(15)                ,--i--
        sum              => pp5_01(15)                ,--o--
        car              => pp5_00(14)               );--o--
pp5_00_csa_14: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(14)                ,--i--
        b                => pp4_00(14)                ,--i--
        sum              => pp5_01(14)                ,--o--
        car              => pp5_00(13)               );--o--
pp5_00_csa_13: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(13)                ,--i--
        b                => pp4_00(13)                ,--i--
        sum              => pp5_01(13)                ,--o--
        car              => pp5_00(12)               );--o--
pp5_00_csa_12: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(12)                ,--i--
        b                => pp4_00(12)                ,--i--
        sum              => pp5_01(12)                ,--o--
        car              => pp5_00(11)               );--o--
pp5_00_csa_11: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(11)                ,--i--
        b                => pp4_00(11)                ,--i--
        sum              => pp5_01(11)                ,--o--
        car              => pp5_00(10)               );--o--
pp5_00_csa_10: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(10)                ,--i--
        b                => pp4_00(10)                ,--i--
        sum              => pp5_01(10)                ,--o--
        car              => pp5_00(9)                );--o--
pp5_00_csa_09: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(9)                 ,--i--
        b                => pp4_00(9)                 ,--i--
        sum              => pp5_01(9)                 ,--o--
        car              => pp5_00(8)                );--o--
pp5_00_csa_08: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(8)                 ,--i--
        b                => pp4_00(8)                 ,--i--
        sum              => pp5_01(8)                 ,--o--
        car              => pp5_00(7)                );--o--
pp5_00_csa_07: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(7)                 ,--i--
        b                => pp4_00(7)                 ,--i--
        sum              => pp5_01(7)                 ,--o--
        car              => pp5_00(6)                );--o--
pp5_00_csa_06: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(6)                 ,--i--
        b                => pp4_00(6)                 ,--i--
        sum              => pp5_01(6)                 ,--o--
        car              => pp5_00(5)                );--o--
pp5_00_csa_05: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(5)                 ,--i--
        b                => pp4_00(5)                 ,--i--
        sum              => pp5_01(5)                 ,--o--
        car              => pp5_00(4)                );--o--
pp5_00_csa_04: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(4)                 ,--i--
        b                => pp4_00(4)                 ,--i--
        sum              => pp5_01(4)                 ,--o--
        car              => pp5_00(3)                );--o--
pp5_00_csa_03: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(3)                 ,--i--
        b                => pp4_00(3)                 ,--i--
        sum              => pp5_01(3)                 ,--o--
        car              => pp5_00(2)                );--o--
pp5_00_csa_02: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(2)                 ,--i--
        b                => pp4_00(2)                 ,--i--
        sum              => pp5_01(2)                 ,--o--
        car              => pp5_00(1)                );--o--
pp5_00_csa_01: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(1)                 ,--i--
        b                => pp4_00(1)                 ,--i--
        sum              => pp5_01(1)                 ,--o--
        car              => pp5_00(0)                );--o--



   sum62(1 to 108) <=  pp5_01(1 to 108); -- just a rename
   car62(1 to 108) <=  pp5_00(1 to 108); -- just a rename


end; -- fuq_mul_62 ARCHITECTURE
