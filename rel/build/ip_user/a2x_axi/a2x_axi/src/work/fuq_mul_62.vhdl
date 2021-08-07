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




end fuq_mul_62; 

architecture fuq_mul_62 of fuq_mul_62 is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';


    signal pp4_03                   :std_ulogic_vector( 18 to 108);
    signal pp4_02                   :std_ulogic_vector( 34 to 108);
    signal pp4_01                   :std_ulogic_vector(  1 to  90);
    signal pp4_00                   :std_ulogic_vector(  0 to  74);
    signal pp5_00                   :std_ulogic_vector(  0 to 108);
    signal pp5_01                   :std_ulogic_vector(  1 to 108);
    signal pp5_00_ko                :std_ulogic_vector( 17 to  73);

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
          pp3_00(0) or pp3_01(0) ;









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



                            pp4_03(93 to 108)  <= pp3_05_buf(93 to 108) ;
                            pp4_02(93 to 108)  <= pp3_04_buf(93 to 108) ;
                            pp4_02(92)         <= tidn ;

pp4_01_csa_92: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(92)            ,
        b                => pp3_04_buf(92)            ,
        c                => hot_one_92_buf            ,
        sum              => pp4_03(92)                ,
        car              => pp4_02(91)               );
pp4_01_csa_91: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(
        a                => pp3_05_buf(91)            ,
        b                => pp3_04_buf(91)            ,
        sum              => pp4_03(91)                ,
        car              => pp4_02(90)               );
pp4_01_csa_90: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(90)            ,
        b                => pp3_04_buf(90)            ,
        c                => pp3_03_buf(90)            ,
        sum              => pp4_03(90)                ,
        car              => pp4_02(89)               );
pp4_01_csa_89: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(89)            ,
        b                => pp3_04_buf(89)            ,
        c                => pp3_03_buf(89)            ,
        sum              => pp4_03(89)                ,
        car              => pp4_02(88)               );
pp4_01_csa_88: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(88)            ,
        b                => pp3_04_buf(88)            ,
        c                => pp3_03_buf(88)            ,
        sum              => pp4_03(88)                ,
        car              => pp4_02(87)               );
pp4_01_csa_87: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(87)            ,
        b                => pp3_04_buf(87)            ,
        c                => pp3_03_buf(87)            ,
        sum              => pp4_03(87)                ,
        car              => pp4_02(86)               );
pp4_01_csa_86: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(86)            ,
        b                => pp3_04_buf(86)            ,
        c                => pp3_03_buf(86)            ,
        sum              => pp4_03(86)                ,
        car              => pp4_02(85)               );
pp4_01_csa_85: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(85)            ,
        b                => pp3_04_buf(85)            ,
        c                => pp3_03_buf(85)            ,
        sum              => pp4_03(85)                ,
        car              => pp4_02(84)               );
pp4_01_csa_84: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(84)            ,
        b                => pp3_04_buf(84)            ,
        c                => pp3_03_buf(84)            ,
        sum              => pp4_03(84)                ,
        car              => pp4_02(83)               );
pp4_01_csa_83: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(83)            ,
        b                => pp3_04_buf(83)            ,
        c                => pp3_03_buf(83)            ,
        sum              => pp4_03(83)                ,
        car              => pp4_02(82)               );
pp4_01_csa_82: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(82)            ,
        b                => pp3_04_buf(82)            ,
        c                => pp3_03_buf(82)            ,
        sum              => pp4_03(82)                ,
        car              => pp4_02(81)               );
pp4_01_csa_81: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(81)            ,
        b                => pp3_04_buf(81)            ,
        c                => pp3_03_buf(81)            ,
        sum              => pp4_03(81)                ,
        car              => pp4_02(80)               );
pp4_01_csa_80: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(80)            ,
        b                => pp3_04_buf(80)            ,
        c                => pp3_03_buf(80)            ,
        sum              => pp4_03(80)                ,
        car              => pp4_02(79)               );
pp4_01_csa_79: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(79)            ,
        b                => pp3_04_buf(79)            ,
        c                => pp3_03_buf(79)            ,
        sum              => pp4_03(79)                ,
        car              => pp4_02(78)               );
pp4_01_csa_78: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(78)            ,
        b                => pp3_04_buf(78)            ,
        c                => pp3_03_buf(78)            ,
        sum              => pp4_03(78)                ,
        car              => pp4_02(77)               );
pp4_01_csa_77: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(77)            ,
        b                => pp3_04_buf(77)            ,
        c                => pp3_03_buf(77)            ,
        sum              => pp4_03(77)                ,
        car              => pp4_02(76)               );
pp4_01_csa_76: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(76)            ,
        b                => pp3_04_buf(76)            ,
        c                => pp3_03_buf(76)            ,
        sum              => pp4_03(76)                ,
        car              => pp4_02(75)               );
pp4_01_csa_75: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(75)            ,
        b                => pp3_04_buf(75)            ,
        c                => pp3_03_buf(75)            ,
        sum              => pp4_03(75)                ,
        car              => pp4_02(74)               );
pp4_01_csa_74: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(74)            ,
        b                => pp3_04_buf(74)            ,
        c                => pp3_03_buf(74)            ,
        sum              => pp4_03(74)                ,
        car              => pp4_02(73)               );
pp4_01_csa_73: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(73)            ,
        b                => pp3_04_buf(73)            ,
        c                => pp3_03_buf(73)            ,
        sum              => pp4_03(73)                ,
        car              => pp4_02(72)               );
pp4_01_csa_72: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(72)            ,
        b                => pp3_04_buf(72)            ,
        c                => pp3_03_buf(72)            ,
        sum              => pp4_03(72)                ,
        car              => pp4_02(71)               );
pp4_01_csa_71: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(71)            ,
        b                => pp3_04_buf(71)            ,
        c                => pp3_03_buf(71)            ,
        sum              => pp4_03(71)                ,
        car              => pp4_02(70)               );
pp4_01_csa_70: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(70)            ,
        b                => pp3_04_buf(70)            ,
        c                => pp3_03_buf(70)            ,
        sum              => pp4_03(70)                ,
        car              => pp4_02(69)               );
pp4_01_csa_69: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(69)            ,
        b                => pp3_04_buf(69)            ,
        c                => pp3_03_buf(69)            ,
        sum              => pp4_03(69)                ,
        car              => pp4_02(68)               );
pp4_01_csa_68: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(68)            ,
        b                => pp3_04_buf(68)            ,
        c                => pp3_03_buf(68)            ,
        sum              => pp4_03(68)                ,
        car              => pp4_02(67)               );
pp4_01_csa_67: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(67)            ,
        b                => pp3_04_buf(67)            ,
        c                => pp3_03_buf(67)            ,
        sum              => pp4_03(67)                ,
        car              => pp4_02(66)               );
pp4_01_csa_66: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(66)            ,
        b                => pp3_04_buf(66)            ,
        c                => pp3_03_buf(66)            ,
        sum              => pp4_03(66)                ,
        car              => pp4_02(65)               );
pp4_01_csa_65: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(65)            ,
        b                => pp3_04_buf(65)            ,
        c                => pp3_03_buf(65)            ,
        sum              => pp4_03(65)                ,
        car              => pp4_02(64)               );
pp4_01_csa_64: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(64)            ,
        b                => pp3_04_buf(64)            ,
        c                => pp3_03_buf(64)            ,
        sum              => pp4_03(64)                ,
        car              => pp4_02(63)               );
pp4_01_csa_63: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(63)            ,
        b                => pp3_04_buf(63)            ,
        c                => pp3_03_buf(63)            ,
        sum              => pp4_03(63)                ,
        car              => pp4_02(62)               );
pp4_01_csa_62: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(62)            ,
        b                => pp3_04_buf(62)            ,
        c                => pp3_03_buf(62)            ,
        sum              => pp4_03(62)                ,
        car              => pp4_02(61)               );
pp4_01_csa_61: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(61)            ,
        b                => pp3_04_buf(61)            ,
        c                => pp3_03_buf(61)            ,
        sum              => pp4_03(61)                ,
        car              => pp4_02(60)               );
pp4_01_csa_60: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(60)            ,
        b                => pp3_04_buf(60)            ,
        c                => pp3_03_buf(60)            ,
        sum              => pp4_03(60)                ,
        car              => pp4_02(59)               );
pp4_01_csa_59: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(59)            ,
        b                => pp3_04_buf(59)            ,
        c                => pp3_03_buf(59)            ,
        sum              => pp4_03(59)                ,
        car              => pp4_02(58)               );
pp4_01_csa_58: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(58)            ,
        b                => pp3_04_buf(58)            ,
        c                => pp3_03_buf(58)            ,
        sum              => pp4_03(58)                ,
        car              => pp4_02(57)               );
pp4_01_csa_57: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(57)            ,
        b                => pp3_04_buf(57)            ,
        c                => pp3_03_buf(57)            ,
        sum              => pp4_03(57)                ,
        car              => pp4_02(56)               );
pp4_01_csa_56: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(56)            ,
        b                => pp3_04_buf(56)            ,
        c                => pp3_03_buf(56)            ,
        sum              => pp4_03(56)                ,
        car              => pp4_02(55)               );
pp4_01_csa_55: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(55)            ,
        b                => pp3_04_buf(55)            ,
        c                => pp3_03_buf(55)            ,
        sum              => pp4_03(55)                ,
        car              => pp4_02(54)               );
pp4_01_csa_54: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(54)            ,
        b                => pp3_04_buf(54)            ,
        c                => pp3_03_buf(54)            ,
        sum              => pp4_03(54)                ,
        car              => pp4_02(53)               );
pp4_01_csa_53: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(53)            ,
        b                => pp3_04_buf(53)            ,
        c                => pp3_03_buf(53)            ,
        sum              => pp4_03(53)                ,
        car              => pp4_02(52)               );
pp4_01_csa_52: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(52)            ,
        b                => pp3_04_buf(52)            ,
        c                => pp3_03_buf(52)            ,
        sum              => pp4_03(52)                ,
        car              => pp4_02(51)               );
pp4_01_csa_51: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(51)            ,
        b                => pp3_04_buf(51)            ,
        c                => pp3_03_buf(51)            ,
        sum              => pp4_03(51)                ,
        car              => pp4_02(50)               );
pp4_01_csa_50: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(50)            ,
        b                => pp3_04_buf(50)            ,
        c                => pp3_03_buf(50)            ,
        sum              => pp4_03(50)                ,
        car              => pp4_02(49)               );
pp4_01_csa_49: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(49)            ,
        b                => pp3_04_buf(49)            ,
        c                => pp3_03_buf(49)            ,
        sum              => pp4_03(49)                ,
        car              => pp4_02(48)               );
pp4_01_csa_48: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(48)            ,
        b                => pp3_04_buf(48)            ,
        c                => pp3_03_buf(48)            ,
        sum              => pp4_03(48)                ,
        car              => pp4_02(47)               );
pp4_01_csa_47: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(47)            ,
        b                => pp3_04_buf(47)            ,
        c                => pp3_03_buf(47)            ,
        sum              => pp4_03(47)                ,
        car              => pp4_02(46)               );
pp4_01_csa_46: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(46)            ,
        b                => pp3_04_buf(46)            ,
        c                => pp3_03_buf(46)            ,
        sum              => pp4_03(46)                ,
        car              => pp4_02(45)               );
pp4_01_csa_45: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(45)            ,
        b                => pp3_04_buf(45)            ,
        c                => pp3_03_buf(45)            ,
        sum              => pp4_03(45)                ,
        car              => pp4_02(44)               );
pp4_01_csa_44: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(44)            ,
        b                => pp3_04_buf(44)            ,
        c                => pp3_03_buf(44)            ,
        sum              => pp4_03(44)                ,
        car              => pp4_02(43)               );
pp4_01_csa_43: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(43)            ,
        b                => pp3_04_buf(43)            ,
        c                => pp3_03_buf(43)            ,
        sum              => pp4_03(43)                ,
        car              => pp4_02(42)               );
pp4_01_csa_42: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(42)            ,
        b                => pp3_04_buf(42)            ,
        c                => pp3_03_buf(42)            ,
        sum              => pp4_03(42)                ,
        car              => pp4_02(41)               );
pp4_01_csa_41: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(41)            ,
        b                => pp3_04_buf(41)            ,
        c                => pp3_03_buf(41)            ,
        sum              => pp4_03(41)                ,
        car              => pp4_02(40)               );
pp4_01_csa_40: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(40)            ,
        b                => pp3_04_buf(40)            ,
        c                => pp3_03_buf(40)            ,
        sum              => pp4_03(40)                ,
        car              => pp4_02(39)               );
pp4_01_csa_39: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(39)            ,
        b                => pp3_04_buf(39)            ,
        c                => pp3_03_buf(39)            ,
        sum              => pp4_03(39)                ,
        car              => pp4_02(38)               );
pp4_01_csa_38: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(38)            ,
        b                => pp3_04_buf(38)            ,
        c                => pp3_03_buf(38)            ,
        sum              => pp4_03(38)                ,
        car              => pp4_02(37)               );
pp4_01_csa_37: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(37)            ,
        b                => pp3_04_buf(37)            ,
        c                => pp3_03_buf(37)            ,
        sum              => pp4_03(37)                ,
        car              => pp4_02(36)               );
pp4_01_csa_36: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_05_buf(36)            ,
        b                => pp3_04_buf(36)            ,
        c                => pp3_03_buf(36)            ,
        sum              => pp4_03(36)                ,
        car              => pp4_02(35)               );
pp4_01_csa_35: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_04_buf(35)            ,
        b                => pp3_03_buf(35)            ,
        sum              => pp4_03(35)                ,
        car              => pp4_02(34)               );

                            pp4_03(18 to 34) <= pp3_03_buf(18 to 34)  ;






                            pp4_01(73 to 90) <= pp3_02_buf(73 to 90)         ;
                            pp4_00(74)       <= hot_one_74_buf           ;
                            pp4_00(73)       <= tidn ;
                            pp4_00(72)       <= tidn ;

pp4_00_csa_72: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(72)            ,
        b                => pp3_01_buf(72)            ,
        c                => pp3_00_buf(72)            ,
        sum              => pp4_01(72)                ,
        car              => pp4_00(71)               );
pp4_00_csa_71: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(71)            ,
        b                => pp3_01_buf(71)            ,
        c                => pp3_00_buf(71)            ,
        sum              => pp4_01(71)                ,
        car              => pp4_00(70)               );
pp4_00_csa_70: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(70)            ,
        b                => pp3_01_buf(70)            ,
        c                => pp3_00_buf(70)            ,
        sum              => pp4_01(70)                ,
        car              => pp4_00(69)               );
pp4_00_csa_69: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(69)            ,
        b                => pp3_01_buf(69)            ,
        c                => pp3_00_buf(69)            ,
        sum              => pp4_01(69)                ,
        car              => pp4_00(68)               );
pp4_00_csa_68: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(68)            ,
        b                => pp3_01_buf(68)            ,
        c                => pp3_00_buf(68)            ,
        sum              => pp4_01(68)                ,
        car              => pp4_00(67)               );
pp4_00_csa_67: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(67)            ,
        b                => pp3_01_buf(67)            ,
        c                => pp3_00_buf(67)            ,
        sum              => pp4_01(67)                ,
        car              => pp4_00(66)               );
pp4_00_csa_66: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(66)            ,
        b                => pp3_01_buf(66)            ,
        c                => pp3_00_buf(66)            ,
        sum              => pp4_01(66)                ,
        car              => pp4_00(65)               );
pp4_00_csa_65: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(65)            ,
        b                => pp3_01_buf(65)            ,
        c                => pp3_00_buf(65)            ,
        sum              => pp4_01(65)                ,
        car              => pp4_00(64)               );
pp4_00_csa_64: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(64)            ,
        b                => pp3_01_buf(64)            ,
        c                => pp3_00_buf(64)            ,
        sum              => pp4_01(64)                ,
        car              => pp4_00(63)               );
pp4_00_csa_63: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(63)            ,
        b                => pp3_01_buf(63)            ,
        c                => pp3_00_buf(63)            ,
        sum              => pp4_01(63)                ,
        car              => pp4_00(62)               );
pp4_00_csa_62: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(62)            ,
        b                => pp3_01_buf(62)            ,
        c                => pp3_00_buf(62)            ,
        sum              => pp4_01(62)                ,
        car              => pp4_00(61)               );
pp4_00_csa_61: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(61)            ,
        b                => pp3_01_buf(61)            ,
        c                => pp3_00_buf(61)            ,
        sum              => pp4_01(61)                ,
        car              => pp4_00(60)               );
pp4_00_csa_60: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(60)            ,
        b                => pp3_01_buf(60)            ,
        c                => pp3_00_buf(60)            ,
        sum              => pp4_01(60)                ,
        car              => pp4_00(59)               );
pp4_00_csa_59: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(59)            ,
        b                => pp3_01_buf(59)            ,
        c                => pp3_00_buf(59)            ,
        sum              => pp4_01(59)                ,
        car              => pp4_00(58)               );
pp4_00_csa_58: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(58)            ,
        b                => pp3_01_buf(58)            ,
        c                => pp3_00_buf(58)            ,
        sum              => pp4_01(58)                ,
        car              => pp4_00(57)               );
pp4_00_csa_57: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(57)            ,
        b                => pp3_01_buf(57)            ,
        c                => pp3_00_buf(57)            ,
        sum              => pp4_01(57)                ,
        car              => pp4_00(56)               );
pp4_00_csa_56: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(56)            ,
        b                => pp3_01_buf(56)            ,
        c                => pp3_00_buf(56)            ,
        sum              => pp4_01(56)                ,
        car              => pp4_00(55)               );
pp4_00_csa_55: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(55)            ,
        b                => pp3_01_buf(55)            ,
        c                => pp3_00_buf(55)            ,
        sum              => pp4_01(55)                ,
        car              => pp4_00(54)               );
pp4_00_csa_54: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(54)            ,
        b                => pp3_01_buf(54)            ,
        c                => pp3_00_buf(54)            ,
        sum              => pp4_01(54)                ,
        car              => pp4_00(53)               );
pp4_00_csa_53: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(53)            ,
        b                => pp3_01_buf(53)            ,
        c                => pp3_00_buf(53)            ,
        sum              => pp4_01(53)                ,
        car              => pp4_00(52)               );
pp4_00_csa_52: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(52)            ,
        b                => pp3_01_buf(52)            ,
        c                => pp3_00_buf(52)            ,
        sum              => pp4_01(52)                ,
        car              => pp4_00(51)               );
pp4_00_csa_51: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(51)            ,
        b                => pp3_01_buf(51)            ,
        c                => pp3_00_buf(51)            ,
        sum              => pp4_01(51)                ,
        car              => pp4_00(50)               );
pp4_00_csa_50: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(50)            ,
        b                => pp3_01_buf(50)            ,
        c                => pp3_00_buf(50)            ,
        sum              => pp4_01(50)                ,
        car              => pp4_00(49)               );
pp4_00_csa_49: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(49)            ,
        b                => pp3_01_buf(49)            ,
        c                => pp3_00_buf(49)            ,
        sum              => pp4_01(49)                ,
        car              => pp4_00(48)               );
pp4_00_csa_48: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(48)            ,
        b                => pp3_01_buf(48)            ,
        c                => pp3_00_buf(48)            ,
        sum              => pp4_01(48)                ,
        car              => pp4_00(47)               );
pp4_00_csa_47: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(47)            ,
        b                => pp3_01_buf(47)            ,
        c                => pp3_00_buf(47)            ,
        sum              => pp4_01(47)                ,
        car              => pp4_00(46)               );
pp4_00_csa_46: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(46)            ,
        b                => pp3_01_buf(46)            ,
        c                => pp3_00_buf(46)            ,
        sum              => pp4_01(46)                ,
        car              => pp4_00(45)               );
pp4_00_csa_45: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(45)            ,
        b                => pp3_01_buf(45)            ,
        c                => pp3_00_buf(45)            ,
        sum              => pp4_01(45)                ,
        car              => pp4_00(44)               );
pp4_00_csa_44: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(44)            ,
        b                => pp3_01_buf(44)            ,
        c                => pp3_00_buf(44)            ,
        sum              => pp4_01(44)                ,
        car              => pp4_00(43)               );
pp4_00_csa_43: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(43)            ,
        b                => pp3_01_buf(43)            ,
        c                => pp3_00_buf(43)            ,
        sum              => pp4_01(43)                ,
        car              => pp4_00(42)               );
pp4_00_csa_42: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(42)            ,
        b                => pp3_01_buf(42)            ,
        c                => pp3_00_buf(42)            ,
        sum              => pp4_01(42)                ,
        car              => pp4_00(41)               );
pp4_00_csa_41: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(41)            ,
        b                => pp3_01_buf(41)            ,
        c                => pp3_00_buf(41)            ,
        sum              => pp4_01(41)                ,
        car              => pp4_00(40)               );
pp4_00_csa_40: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(40)            ,
        b                => pp3_01_buf(40)            ,
        c                => pp3_00_buf(40)            ,
        sum              => pp4_01(40)                ,
        car              => pp4_00(39)               );
pp4_00_csa_39: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(39)            ,
        b                => pp3_01_buf(39)            ,
        c                => pp3_00_buf(39)            ,
        sum              => pp4_01(39)                ,
        car              => pp4_00(38)               );
pp4_00_csa_38: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(38)            ,
        b                => pp3_01_buf(38)            ,
        c                => pp3_00_buf(38)            ,
        sum              => pp4_01(38)                ,
        car              => pp4_00(37)               );
pp4_00_csa_37: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(37)            ,
        b                => pp3_01_buf(37)            ,
        c                => pp3_00_buf(37)            ,
        sum              => pp4_01(37)                ,
        car              => pp4_00(36)               );
pp4_00_csa_36: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(36)            ,
        b                => pp3_01_buf(36)            ,
        c                => pp3_00_buf(36)            ,
        sum              => pp4_01(36)                ,
        car              => pp4_00(35)               );
pp4_00_csa_35: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(35)            ,
        b                => pp3_01_buf(35)            ,
        c                => pp3_00_buf(35)            ,
        sum              => pp4_01(35)                ,
        car              => pp4_00(34)               );
pp4_00_csa_34: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(34)            ,
        b                => pp3_01_buf(34)            ,
        c                => pp3_00_buf(34)            ,
        sum              => pp4_01(34)                ,
        car              => pp4_00(33)               );
pp4_00_csa_33: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(33)            ,
        b                => pp3_01_buf(33)            ,
        c                => pp3_00_buf(33)            ,
        sum              => pp4_01(33)                ,
        car              => pp4_00(32)               );
pp4_00_csa_32: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(32)            ,
        b                => pp3_01_buf(32)            ,
        c                => pp3_00_buf(32)            ,
        sum              => pp4_01(32)                ,
        car              => pp4_00(31)               );
pp4_00_csa_31: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(31)            ,
        b                => pp3_01_buf(31)            ,
        c                => pp3_00_buf(31)            ,
        sum              => pp4_01(31)                ,
        car              => pp4_00(30)               );
pp4_00_csa_30: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(30)            ,
        b                => pp3_01_buf(30)            ,
        c                => pp3_00_buf(30)            ,
        sum              => pp4_01(30)                ,
        car              => pp4_00(29)               );
pp4_00_csa_29: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(29)            ,
        b                => pp3_01_buf(29)            ,
        c                => pp3_00_buf(29)            ,
        sum              => pp4_01(29)                ,
        car              => pp4_00(28)               );
pp4_00_csa_28: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(28)            ,
        b                => pp3_01_buf(28)            ,
        c                => pp3_00_buf(28)            ,
        sum              => pp4_01(28)                ,
        car              => pp4_00(27)               );
pp4_00_csa_27: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(27)            ,
        b                => pp3_01_buf(27)            ,
        c                => pp3_00_buf(27)            ,
        sum              => pp4_01(27)                ,
        car              => pp4_00(26)               );
pp4_00_csa_26: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(26)            ,
        b                => pp3_01_buf(26)            ,
        c                => pp3_00_buf(26)            ,
        sum              => pp4_01(26)                ,
        car              => pp4_00(25)               );
pp4_00_csa_25: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(25)            ,
        b                => pp3_01_buf(25)            ,
        c                => pp3_00_buf(25)            ,
        sum              => pp4_01(25)                ,
        car              => pp4_00(24)               );
pp4_00_csa_24: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(24)            ,
        b                => pp3_01_buf(24)            ,
        c                => pp3_00_buf(24)            ,
        sum              => pp4_01(24)                ,
        car              => pp4_00(23)               );
pp4_00_csa_23: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(23)            ,
        b                => pp3_01_buf(23)            ,
        c                => pp3_00_buf(23)            ,
        sum              => pp4_01(23)                ,
        car              => pp4_00(22)               );
pp4_00_csa_22: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(22)            ,
        b                => pp3_01_buf(22)            ,
        c                => pp3_00_buf(22)            ,
        sum              => pp4_01(22)                ,
        car              => pp4_00(21)               );
pp4_00_csa_21: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(21)            ,
        b                => pp3_01_buf(21)            ,
        c                => pp3_00_buf(21)            ,
        sum              => pp4_01(21)                ,
        car              => pp4_00(20)               );
pp4_00_csa_20: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(20)            ,
        b                => pp3_01_buf(20)            ,
        c                => pp3_00_buf(20)            ,
        sum              => pp4_01(20)                ,
        car              => pp4_00(19)               );
pp4_00_csa_19: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(19)            ,
        b                => pp3_01_buf(19)            ,
        c                => pp3_00_buf(19)            ,
        sum              => pp4_01(19)                ,
        car              => pp4_00(18)               );
pp4_00_csa_18: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(18)            ,
        b                => pp3_01_buf(18)            ,
        c                => pp3_00_buf(18)            ,
        sum              => pp4_01(18)                ,
        car              => pp4_00(17)               );
pp4_00_csa_17: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp3_02_buf(17)            ,
        b                => pp3_01_buf(17)            ,
        c                => pp3_00_buf(17)            ,
        sum              => pp4_01(17)                ,
        car              => pp4_00(16)               );
pp4_00_csa_16: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(16)            ,
        b                => pp3_00_buf(16)            ,
        sum              => pp4_01(16)                ,
        car              => pp4_00(15)               );
pp4_00_csa_15: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(15)            ,
        b                => pp3_00_buf(15)            ,
        sum              => pp4_01(15)                ,
        car              => pp4_00(14)               );
pp4_00_csa_14: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(14)            ,
        b                => pp3_00_buf(14)            ,
        sum              => pp4_01(14)                ,
        car              => pp4_00(13)               );
pp4_00_csa_13: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(13)            ,
        b                => pp3_00_buf(13)            ,
        sum              => pp4_01(13)                ,
        car              => pp4_00(12)               );
pp4_00_csa_12: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(12)            ,
        b                => pp3_00_buf(12)            ,
        sum              => pp4_01(12)                ,
        car              => pp4_00(11)               );
pp4_00_csa_11: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(11)            ,
        b                => pp3_00_buf(11)            ,
        sum              => pp4_01(11)                ,
        car              => pp4_00(10)               );
pp4_00_csa_10: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(10)            ,
        b                => pp3_00_buf(10)            ,
        sum              => pp4_01(10)                ,
        car              => pp4_00(9)                );
pp4_00_csa_09: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(9)             ,
        b                => pp3_00_buf(9)             ,
        sum              => pp4_01(9)                 ,
        car              => pp4_00(8)                );
pp4_00_csa_08: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(8)             ,
        b                => pp3_00_buf(8)             ,
        sum              => pp4_01(8)                 ,
        car              => pp4_00(7)                );
pp4_00_csa_07: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(7)             ,
        b                => pp3_00_buf(7)             ,
        sum              => pp4_01(7)                 ,
        car              => pp4_00(6)                );
pp4_00_csa_06: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(6)             ,
        b                => pp3_00_buf(6)             ,
        sum              => pp4_01(6)                 ,
        car              => pp4_00(5)                );
pp4_00_csa_05: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(5)             ,
        b                => pp3_00_buf(5)             ,
        sum              => pp4_01(5)                 ,
        car              => pp4_00(4)                );
pp4_00_csa_04: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(4)             ,
        b                => pp3_00_buf(4)             ,
        sum              => pp4_01(4)                 ,
        car              => pp4_00(3)                );
pp4_00_csa_03: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(3)             ,
        b                => pp3_00_buf(3)             ,
        sum              => pp4_01(3)                 ,
        car              => pp4_00(2)                );
pp4_00_csa_02: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(2)             ,
        b                => pp3_00_buf(2)             ,
        sum              => pp4_01(2)                 ,
        car              => pp4_00(1)                );
pp4_00_csa_01: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp3_01_buf(1)             ,
        b                => pp3_00_buf(1)             ,
        sum              => pp4_01(1)                 ,
        car              => pp4_00(0)                );




 


                            pp5_01(91 to 108)      <= pp4_03(91 to 108) ;
                            pp5_00(93 to 108)      <= pp4_02(93 to 108) ;
                            pp5_00(92)             <= tidn ;
                            pp5_00(91)             <= pp4_02(91);
                            pp5_00(90)             <= tidn;

pp5_00_csa_90: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(90)                ,
        b                => pp4_02(90)                ,
        c                => pp4_01(90)                ,
        sum              => pp5_01(90)                ,
        car              => pp5_00(89)               );
pp5_00_csa_89: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(89)                ,
        b                => pp4_02(89)                ,
        c                => pp4_01(89)                ,
        sum              => pp5_01(89)                ,
        car              => pp5_00(88)               );
pp5_00_csa_88: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(88)                ,
        b                => pp4_02(88)                ,
        c                => pp4_01(88)                ,
        sum              => pp5_01(88)                ,
        car              => pp5_00(87)               );
pp5_00_csa_87: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(87)                ,
        b                => pp4_02(87)                ,
        c                => pp4_01(87)                ,
        sum              => pp5_01(87)                ,
        car              => pp5_00(86)               );
pp5_00_csa_86: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(86)                ,
        b                => pp4_02(86)                ,
        c                => pp4_01(86)                ,
        sum              => pp5_01(86)                ,
        car              => pp5_00(85)               );
pp5_00_csa_85: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(85)                ,
        b                => pp4_02(85)                ,
        c                => pp4_01(85)                ,
        sum              => pp5_01(85)                ,
        car              => pp5_00(84)               );
pp5_00_csa_84: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(84)                ,
        b                => pp4_02(84)                ,
        c                => pp4_01(84)                ,
        sum              => pp5_01(84)                ,
        car              => pp5_00(83)               );
pp5_00_csa_83: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(83)                ,
        b                => pp4_02(83)                ,
        c                => pp4_01(83)                ,
        sum              => pp5_01(83)                ,
        car              => pp5_00(82)               );
pp5_00_csa_82: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(82)                ,
        b                => pp4_02(82)                ,
        c                => pp4_01(82)                ,
        sum              => pp5_01(82)                ,
        car              => pp5_00(81)               );
pp5_00_csa_81: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(81)                ,
        b                => pp4_02(81)                ,
        c                => pp4_01(81)                ,
        sum              => pp5_01(81)                ,
        car              => pp5_00(80)               );
pp5_00_csa_80: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(80)                ,
        b                => pp4_02(80)                ,
        c                => pp4_01(80)                ,
        sum              => pp5_01(80)                ,
        car              => pp5_00(79)               );
pp5_00_csa_79: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(79)                ,
        b                => pp4_02(79)                ,
        c                => pp4_01(79)                ,
        sum              => pp5_01(79)                ,
        car              => pp5_00(78)               );
pp5_00_csa_78: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(78)                ,
        b                => pp4_02(78)                ,
        c                => pp4_01(78)                ,
        sum              => pp5_01(78)                ,
        car              => pp5_00(77)               );
pp5_00_csa_77: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(77)                ,
        b                => pp4_02(77)                ,
        c                => pp4_01(77)                ,
        sum              => pp5_01(77)                ,
        car              => pp5_00(76)               );
pp5_00_csa_76: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(76)                ,
        b                => pp4_02(76)                ,
        c                => pp4_01(76)                ,
        sum              => pp5_01(76)                ,
        car              => pp5_00(75)               );
pp5_00_csa_75: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(75)                ,
        b                => pp4_02(75)                ,
        c                => pp4_01(75)                ,
        sum              => pp5_01(75)                ,
        car              => pp5_00(74)               );
pp5_00_csa_74: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(74)                ,
        b                => pp4_02(74)                ,
        c                => pp4_01(74)                ,
        d                => pp4_00(74)                ,
        ki               => tidn                      ,
        ko               => pp5_00_ko(73)             ,
        sum              => pp5_01(74)                ,
        car              => pp5_00(73)               );
pp5_00_csa_73: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(73)                ,
        b                => pp4_02(73)                ,
        c                => pp4_01(73)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(73)             ,
        ko               => pp5_00_ko(72)             ,
        sum              => pp5_01(73)                ,
        car              => pp5_00(72)               );
pp5_00_csa_72: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(72)                ,
        b                => pp4_02(72)                ,
        c                => pp4_01(72)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(72)             ,
        ko               => pp5_00_ko(71)             ,
        sum              => pp5_01(72)                ,
        car              => pp5_00(71)               );
pp5_00_csa_71: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(71)                ,
        b                => pp4_02(71)                ,
        c                => pp4_01(71)                ,
        d                => pp4_00(71)                ,
        ki               => pp5_00_ko(71)             ,
        ko               => pp5_00_ko(70)             ,
        sum              => pp5_01(71)                ,
        car              => pp5_00(70)               );
pp5_00_csa_70: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(70)                ,
        b                => pp4_02(70)                ,
        c                => pp4_01(70)                ,
        d                => pp4_00(70)                ,
        ki               => pp5_00_ko(70)             ,
        ko               => pp5_00_ko(69)             ,
        sum              => pp5_01(70)                ,
        car              => pp5_00(69)               );
pp5_00_csa_69: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(69)                ,
        b                => pp4_02(69)                ,
        c                => pp4_01(69)                ,
        d                => pp4_00(69)                ,
        ki               => pp5_00_ko(69)             ,
        ko               => pp5_00_ko(68)             ,
        sum              => pp5_01(69)                ,
        car              => pp5_00(68)               );
pp5_00_csa_68: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(68)                ,
        b                => pp4_02(68)                ,
        c                => pp4_01(68)                ,
        d                => pp4_00(68)                ,
        ki               => pp5_00_ko(68)             ,
        ko               => pp5_00_ko(67)             ,
        sum              => pp5_01(68)                ,
        car              => pp5_00(67)               );
pp5_00_csa_67: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(67)                ,
        b                => pp4_02(67)                ,
        c                => pp4_01(67)                ,
        d                => pp4_00(67)                ,
        ki               => pp5_00_ko(67)             ,
        ko               => pp5_00_ko(66)             ,
        sum              => pp5_01(67)                ,
        car              => pp5_00(66)               );
pp5_00_csa_66: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(66)                ,
        b                => pp4_02(66)                ,
        c                => pp4_01(66)                ,
        d                => pp4_00(66)                ,
        ki               => pp5_00_ko(66)             ,
        ko               => pp5_00_ko(65)             ,
        sum              => pp5_01(66)                ,
        car              => pp5_00(65)               );
pp5_00_csa_65: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(65)                ,
        b                => pp4_02(65)                ,
        c                => pp4_01(65)                ,
        d                => pp4_00(65)                ,
        ki               => pp5_00_ko(65)             ,
        ko               => pp5_00_ko(64)             ,
        sum              => pp5_01(65)                ,
        car              => pp5_00(64)               );
pp5_00_csa_64: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(64)                ,
        b                => pp4_02(64)                ,
        c                => pp4_01(64)                ,
        d                => pp4_00(64)                ,
        ki               => pp5_00_ko(64)             ,
        ko               => pp5_00_ko(63)             ,
        sum              => pp5_01(64)                ,
        car              => pp5_00(63)               );
pp5_00_csa_63: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(63)                ,
        b                => pp4_02(63)                ,
        c                => pp4_01(63)                ,
        d                => pp4_00(63)                ,
        ki               => pp5_00_ko(63)             ,
        ko               => pp5_00_ko(62)             ,
        sum              => pp5_01(63)                ,
        car              => pp5_00(62)               );
pp5_00_csa_62: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(62)                ,
        b                => pp4_02(62)                ,
        c                => pp4_01(62)                ,
        d                => pp4_00(62)                ,
        ki               => pp5_00_ko(62)             ,
        ko               => pp5_00_ko(61)             ,
        sum              => pp5_01(62)                ,
        car              => pp5_00(61)               );
pp5_00_csa_61: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(61)                ,
        b                => pp4_02(61)                ,
        c                => pp4_01(61)                ,
        d                => pp4_00(61)                ,
        ki               => pp5_00_ko(61)             ,
        ko               => pp5_00_ko(60)             ,
        sum              => pp5_01(61)                ,
        car              => pp5_00(60)               );
pp5_00_csa_60: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(60)                ,
        b                => pp4_02(60)                ,
        c                => pp4_01(60)                ,
        d                => pp4_00(60)                ,
        ki               => pp5_00_ko(60)             ,
        ko               => pp5_00_ko(59)             ,
        sum              => pp5_01(60)                ,
        car              => pp5_00(59)               );
pp5_00_csa_59: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(59)                ,
        b                => pp4_02(59)                ,
        c                => pp4_01(59)                ,
        d                => pp4_00(59)                ,
        ki               => pp5_00_ko(59)             ,
        ko               => pp5_00_ko(58)             ,
        sum              => pp5_01(59)                ,
        car              => pp5_00(58)               );
pp5_00_csa_58: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(58)                ,
        b                => pp4_02(58)                ,
        c                => pp4_01(58)                ,
        d                => pp4_00(58)                ,
        ki               => pp5_00_ko(58)             ,
        ko               => pp5_00_ko(57)             ,
        sum              => pp5_01(58)                ,
        car              => pp5_00(57)               );
pp5_00_csa_57: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(57)                ,
        b                => pp4_02(57)                ,
        c                => pp4_01(57)                ,
        d                => pp4_00(57)                ,
        ki               => pp5_00_ko(57)             ,
        ko               => pp5_00_ko(56)             ,
        sum              => pp5_01(57)                ,
        car              => pp5_00(56)               );
pp5_00_csa_56: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(56)                ,
        b                => pp4_02(56)                ,
        c                => pp4_01(56)                ,
        d                => pp4_00(56)                ,
        ki               => pp5_00_ko(56)             ,
        ko               => pp5_00_ko(55)             ,
        sum              => pp5_01(56)                ,
        car              => pp5_00(55)               );
pp5_00_csa_55: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(55)                ,
        b                => pp4_02(55)                ,
        c                => pp4_01(55)                ,
        d                => pp4_00(55)                ,
        ki               => pp5_00_ko(55)             ,
        ko               => pp5_00_ko(54)             ,
        sum              => pp5_01(55)                ,
        car              => pp5_00(54)               );
pp5_00_csa_54: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(54)                ,
        b                => pp4_02(54)                ,
        c                => pp4_01(54)                ,
        d                => pp4_00(54)                ,
        ki               => pp5_00_ko(54)             ,
        ko               => pp5_00_ko(53)             ,
        sum              => pp5_01(54)                ,
        car              => pp5_00(53)               );
pp5_00_csa_53: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(53)                ,
        b                => pp4_02(53)                ,
        c                => pp4_01(53)                ,
        d                => pp4_00(53)                ,
        ki               => pp5_00_ko(53)             ,
        ko               => pp5_00_ko(52)             ,
        sum              => pp5_01(53)                ,
        car              => pp5_00(52)               );
pp5_00_csa_52: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(52)                ,
        b                => pp4_02(52)                ,
        c                => pp4_01(52)                ,
        d                => pp4_00(52)                ,
        ki               => pp5_00_ko(52)             ,
        ko               => pp5_00_ko(51)             ,
        sum              => pp5_01(52)                ,
        car              => pp5_00(51)               );
pp5_00_csa_51: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(51)                ,
        b                => pp4_02(51)                ,
        c                => pp4_01(51)                ,
        d                => pp4_00(51)                ,
        ki               => pp5_00_ko(51)             ,
        ko               => pp5_00_ko(50)             ,
        sum              => pp5_01(51)                ,
        car              => pp5_00(50)               );
pp5_00_csa_50: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(50)                ,
        b                => pp4_02(50)                ,
        c                => pp4_01(50)                ,
        d                => pp4_00(50)                ,
        ki               => pp5_00_ko(50)             ,
        ko               => pp5_00_ko(49)             ,
        sum              => pp5_01(50)                ,
        car              => pp5_00(49)               );
pp5_00_csa_49: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(49)                ,
        b                => pp4_02(49)                ,
        c                => pp4_01(49)                ,
        d                => pp4_00(49)                ,
        ki               => pp5_00_ko(49)             ,
        ko               => pp5_00_ko(48)             ,
        sum              => pp5_01(49)                ,
        car              => pp5_00(48)               );
pp5_00_csa_48: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(48)                ,
        b                => pp4_02(48)                ,
        c                => pp4_01(48)                ,
        d                => pp4_00(48)                ,
        ki               => pp5_00_ko(48)             ,
        ko               => pp5_00_ko(47)             ,
        sum              => pp5_01(48)                ,
        car              => pp5_00(47)               );
pp5_00_csa_47: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(47)                ,
        b                => pp4_02(47)                ,
        c                => pp4_01(47)                ,
        d                => pp4_00(47)                ,
        ki               => pp5_00_ko(47)             ,
        ko               => pp5_00_ko(46)             ,
        sum              => pp5_01(47)                ,
        car              => pp5_00(46)               );
pp5_00_csa_46: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(46)                ,
        b                => pp4_02(46)                ,
        c                => pp4_01(46)                ,
        d                => pp4_00(46)                ,
        ki               => pp5_00_ko(46)             ,
        ko               => pp5_00_ko(45)             ,
        sum              => pp5_01(46)                ,
        car              => pp5_00(45)               );
pp5_00_csa_45: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(45)                ,
        b                => pp4_02(45)                ,
        c                => pp4_01(45)                ,
        d                => pp4_00(45)                ,
        ki               => pp5_00_ko(45)             ,
        ko               => pp5_00_ko(44)             ,
        sum              => pp5_01(45)                ,
        car              => pp5_00(44)               );
pp5_00_csa_44: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(44)                ,
        b                => pp4_02(44)                ,
        c                => pp4_01(44)                ,
        d                => pp4_00(44)                ,
        ki               => pp5_00_ko(44)             ,
        ko               => pp5_00_ko(43)             ,
        sum              => pp5_01(44)                ,
        car              => pp5_00(43)               );
pp5_00_csa_43: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(43)                ,
        b                => pp4_02(43)                ,
        c                => pp4_01(43)                ,
        d                => pp4_00(43)                ,
        ki               => pp5_00_ko(43)             ,
        ko               => pp5_00_ko(42)             ,
        sum              => pp5_01(43)                ,
        car              => pp5_00(42)               );
pp5_00_csa_42: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(42)                ,
        b                => pp4_02(42)                ,
        c                => pp4_01(42)                ,
        d                => pp4_00(42)                ,
        ki               => pp5_00_ko(42)             ,
        ko               => pp5_00_ko(41)             ,
        sum              => pp5_01(42)                ,
        car              => pp5_00(41)               );
pp5_00_csa_41: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(41)                ,
        b                => pp4_02(41)                ,
        c                => pp4_01(41)                ,
        d                => pp4_00(41)                ,
        ki               => pp5_00_ko(41)             ,
        ko               => pp5_00_ko(40)             ,
        sum              => pp5_01(41)                ,
        car              => pp5_00(40)               );
pp5_00_csa_40: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(40)                ,
        b                => pp4_02(40)                ,
        c                => pp4_01(40)                ,
        d                => pp4_00(40)                ,
        ki               => pp5_00_ko(40)             ,
        ko               => pp5_00_ko(39)             ,
        sum              => pp5_01(40)                ,
        car              => pp5_00(39)               );
pp5_00_csa_39: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(39)                ,
        b                => pp4_02(39)                ,
        c                => pp4_01(39)                ,
        d                => pp4_00(39)                ,
        ki               => pp5_00_ko(39)             ,
        ko               => pp5_00_ko(38)             ,
        sum              => pp5_01(39)                ,
        car              => pp5_00(38)               );
pp5_00_csa_38: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(38)                ,
        b                => pp4_02(38)                ,
        c                => pp4_01(38)                ,
        d                => pp4_00(38)                ,
        ki               => pp5_00_ko(38)             ,
        ko               => pp5_00_ko(37)             ,
        sum              => pp5_01(38)                ,
        car              => pp5_00(37)               );
pp5_00_csa_37: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(37)                ,
        b                => pp4_02(37)                ,
        c                => pp4_01(37)                ,
        d                => pp4_00(37)                ,
        ki               => pp5_00_ko(37)             ,
        ko               => pp5_00_ko(36)             ,
        sum              => pp5_01(37)                ,
        car              => pp5_00(36)               );
pp5_00_csa_36: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(36)                ,
        b                => pp4_02(36)                ,
        c                => pp4_01(36)                ,
        d                => pp4_00(36)                ,
        ki               => pp5_00_ko(36)             ,
        ko               => pp5_00_ko(35)             ,
        sum              => pp5_01(36)                ,
        car              => pp5_00(35)               );
pp5_00_csa_35: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(35)                ,
        b                => pp4_02(35)                ,
        c                => pp4_01(35)                ,
        d                => pp4_00(35)                ,
        ki               => pp5_00_ko(35)             ,
        ko               => pp5_00_ko(34)             ,
        sum              => pp5_01(35)                ,
        car              => pp5_00(34)               );
pp5_00_csa_34: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(34)                ,
        b                => pp4_02(34)                ,
        c                => pp4_01(34)                ,
        d                => pp4_00(34)                ,
        ki               => pp5_00_ko(34)             ,
        ko               => pp5_00_ko(33)             ,
        sum              => pp5_01(34)                ,
        car              => pp5_00(33)               );
pp5_00_csa_33: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(33)                ,
        b                => pp4_01(33)                ,
        c                => pp4_00(33)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(33)             ,
        ko               => pp5_00_ko(32)             ,
        sum              => pp5_01(33)                ,
        car              => pp5_00(32)               );
pp5_00_csa_32: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(32)                ,
        b                => pp4_01(32)                ,
        c                => pp4_00(32)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(32)             ,
        ko               => pp5_00_ko(31)             ,
        sum              => pp5_01(32)                ,
        car              => pp5_00(31)               );
pp5_00_csa_31: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(31)                ,
        b                => pp4_01(31)                ,
        c                => pp4_00(31)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(31)             ,
        ko               => pp5_00_ko(30)             ,
        sum              => pp5_01(31)                ,
        car              => pp5_00(30)               );
pp5_00_csa_30: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(30)                ,
        b                => pp4_01(30)                ,
        c                => pp4_00(30)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(30)             ,
        ko               => pp5_00_ko(29)             ,
        sum              => pp5_01(30)                ,
        car              => pp5_00(29)               );
pp5_00_csa_29: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(29)                ,
        b                => pp4_01(29)                ,
        c                => pp4_00(29)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(29)             ,
        ko               => pp5_00_ko(28)             ,
        sum              => pp5_01(29)                ,
        car              => pp5_00(28)               );
pp5_00_csa_28: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(28)                ,
        b                => pp4_01(28)                ,
        c                => pp4_00(28)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(28)             ,
        ko               => pp5_00_ko(27)             ,
        sum              => pp5_01(28)                ,
        car              => pp5_00(27)               );
pp5_00_csa_27: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(27)                ,
        b                => pp4_01(27)                ,
        c                => pp4_00(27)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(27)             ,
        ko               => pp5_00_ko(26)             ,
        sum              => pp5_01(27)                ,
        car              => pp5_00(26)               );
pp5_00_csa_26: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(26)                ,
        b                => pp4_01(26)                ,
        c                => pp4_00(26)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(26)             ,
        ko               => pp5_00_ko(25)             ,
        sum              => pp5_01(26)                ,
        car              => pp5_00(25)               );
pp5_00_csa_25: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(25)                ,
        b                => pp4_01(25)                ,
        c                => pp4_00(25)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(25)             ,
        ko               => pp5_00_ko(24)             ,
        sum              => pp5_01(25)                ,
        car              => pp5_00(24)               );
pp5_00_csa_24: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(24)                ,
        b                => pp4_01(24)                ,
        c                => pp4_00(24)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(24)             ,
        ko               => pp5_00_ko(23)             ,
        sum              => pp5_01(24)                ,
        car              => pp5_00(23)               );
pp5_00_csa_23: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(23)                ,
        b                => pp4_01(23)                ,
        c                => pp4_00(23)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(23)             ,
        ko               => pp5_00_ko(22)             ,
        sum              => pp5_01(23)                ,
        car              => pp5_00(22)               );
pp5_00_csa_22: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(22)                ,
        b                => pp4_01(22)                ,
        c                => pp4_00(22)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(22)             ,
        ko               => pp5_00_ko(21)             ,
        sum              => pp5_01(22)                ,
        car              => pp5_00(21)               );
pp5_00_csa_21: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(21)                ,
        b                => pp4_01(21)                ,
        c                => pp4_00(21)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(21)             ,
        ko               => pp5_00_ko(20)             ,
        sum              => pp5_01(21)                ,
        car              => pp5_00(20)               );
pp5_00_csa_20: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(20)                ,
        b                => pp4_01(20)                ,
        c                => pp4_00(20)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(20)             ,
        ko               => pp5_00_ko(19)             ,
        sum              => pp5_01(20)                ,
        car              => pp5_00(19)               );
pp5_00_csa_19: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(19)                ,
        b                => pp4_01(19)                ,
        c                => pp4_00(19)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(19)             ,
        ko               => pp5_00_ko(18)             ,
        sum              => pp5_01(19)                ,
        car              => pp5_00(18)               );
pp5_00_csa_18: entity clib.c_prism_csa42  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_03(18)                ,
        b                => pp4_01(18)                ,
        c                => pp4_00(18)                ,
        d                => tidn                      ,
        ki               => pp5_00_ko(18)             ,
        ko               => pp5_00_ko(17)             ,
        sum              => pp5_01(18)                ,
        car              => pp5_00(17)               );
pp5_00_csa_17: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                => pp4_01(17)                ,
        b                => pp4_00(17)                ,
        c                => pp5_00_ko(17)             ,
        sum              => pp5_01(17)                ,
        car              => pp5_00(16)               );
pp5_00_csa_16: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(16)                ,
        b                => pp4_00(16)                ,
        sum              => pp5_01(16)                ,
        car              => pp5_00(15)               );
pp5_00_csa_15: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(15)                ,
        b                => pp4_00(15)                ,
        sum              => pp5_01(15)                ,
        car              => pp5_00(14)               );
pp5_00_csa_14: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(14)                ,
        b                => pp4_00(14)                ,
        sum              => pp5_01(14)                ,
        car              => pp5_00(13)               );
pp5_00_csa_13: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(13)                ,
        b                => pp4_00(13)                ,
        sum              => pp5_01(13)                ,
        car              => pp5_00(12)               );
pp5_00_csa_12: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(12)                ,
        b                => pp4_00(12)                ,
        sum              => pp5_01(12)                ,
        car              => pp5_00(11)               );
pp5_00_csa_11: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(11)                ,
        b                => pp4_00(11)                ,
        sum              => pp5_01(11)                ,
        car              => pp5_00(10)               );
pp5_00_csa_10: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(10)                ,
        b                => pp4_00(10)                ,
        sum              => pp5_01(10)                ,
        car              => pp5_00(9)                );
pp5_00_csa_09: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(9)                 ,
        b                => pp4_00(9)                 ,
        sum              => pp5_01(9)                 ,
        car              => pp5_00(8)                );
pp5_00_csa_08: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(8)                 ,
        b                => pp4_00(8)                 ,
        sum              => pp5_01(8)                 ,
        car              => pp5_00(7)                );
pp5_00_csa_07: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(7)                 ,
        b                => pp4_00(7)                 ,
        sum              => pp5_01(7)                 ,
        car              => pp5_00(6)                );
pp5_00_csa_06: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(6)                 ,
        b                => pp4_00(6)                 ,
        sum              => pp5_01(6)                 ,
        car              => pp5_00(5)                );
pp5_00_csa_05: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(5)                 ,
        b                => pp4_00(5)                 ,
        sum              => pp5_01(5)                 ,
        car              => pp5_00(4)                );
pp5_00_csa_04: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(4)                 ,
        b                => pp4_00(4)                 ,
        sum              => pp5_01(4)                 ,
        car              => pp5_00(3)                );
pp5_00_csa_03: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(3)                 ,
        b                => pp4_00(3)                 ,
        sum              => pp5_01(3)                 ,
        car              => pp5_00(2)                );
pp5_00_csa_02: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(2)                 ,
        b                => pp4_00(2)                 ,
        sum              => pp5_01(2)                 ,
        car              => pp5_00(1)                );
pp5_00_csa_01: entity work.fuq_csa22_h2(fuq_csa22_h2) port map( 
        a                => pp4_01(1)                 ,
        b                => pp4_00(1)                 ,
        sum              => pp5_01(1)                 ,
        car              => pp5_00(0)                );



   sum62(1 to 108) <=  pp5_01(1 to 108); 
   car62(1 to 108) <=  pp5_00(1 to 108); 


end; 



