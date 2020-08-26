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
library clib ;



entity fuq_mul is
generic( expand_type  : integer := 2  ); 
port(

       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic; -- tidn,
       mpw1_b                                    :in   std_ulogic; -- tidn,
       mpw2_b                                    :in   std_ulogic; -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;

       f_mul_si                  :in  std_ulogic; --perv
       f_mul_so                  :out std_ulogic; --perv
       ex1_act                   :in  std_ulogic; --act

       f_fmt_ex1_a_frac          :in  std_ulogic_vector(0 to 52) ;-- implicit bit already generated
       f_fmt_ex1_a_frac_17       :in  std_ulogic;-- new port for replicated bit
       f_fmt_ex1_a_frac_35       :in  std_ulogic;-- new port for replicated bit
       f_fmt_ex1_c_frac          :in  std_ulogic_vector(0 to 53) ;-- implicit bit already generated

       f_mul_ex2_sum             :out std_ulogic_vector(1 to 108); 
       f_mul_ex2_car             :out std_ulogic_vector(1 to 108)
);


end fuq_mul; -- ENTITY

architecture fuq_mul of fuq_mul is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal thold_0_b, thold_0, forcee                       :std_ulogic;
    signal sg_0                           :std_ulogic;
    signal spare_unused                     :std_ulogic_vector(0 to 3);
    ----------------------------------------
    signal act_so , act_si                 :std_ulogic_vector(0 to 3);--SCAN
    signal m92_0_so, m92_1_so, m92_2_so    :std_ulogic;
    ----------------------------------------
 signal pp3_05 :std_ulogic_vector(36 to 108) ;
 signal pp3_04 :std_ulogic_vector(35 to 108) ;
 signal pp3_03 :std_ulogic_vector(18 to 90) ;
 signal pp3_02 :std_ulogic_vector(17 to 90) ;
 signal pp3_01 :std_ulogic_vector(0 to 72) ;
 signal pp3_00 :std_ulogic_vector(0 to 72) ;


    signal hot_one_msb_unused :std_ulogic;
    signal hot_one_74 :std_ulogic;
    signal hot_one_92 :std_ulogic;
    signal xtd_unused :std_ulogic;


    signal pp5_00 :std_ulogic_vector(1 to 108);
    signal pp5_01 :std_ulogic_vector(1 to 108);


begin

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


    act_lat:  tri_rlmreg_p generic map (width=> 4, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,--i-- tidn,
        delay_lclkr      => delay_lclkr  ,--i-- tidn,
        mpw1_b           => mpw1_b       ,--i-- tidn,
        mpw2_b           => mpw2_b       ,--i-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0,
        scout            => act_so,                      
        scin             => act_si,
        -------------------
        din(0)           => spare_unused(0),
        din(1)           => spare_unused(1),
        din(2)           => spare_unused(2),
        din(3)           => spare_unused(3),
        -------------------
        dout(0)          => spare_unused(0),
        dout(1)          => spare_unused(1),
        dout(2)          => spare_unused(2) ,
        dout(3)          => spare_unused(3) );

act_si(0 to 3)        <= act_so(1 to 3) & m92_2_so;

f_mul_so  <= act_so(0) ; 





--//################################################################
--//# ex1 logic
--//################################################################

--//# NUMBERING SYSTEM RELATIVE TO COMPRESSOR TREE
--//#
--//#    0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111
--//#    0000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000
--//#    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
--//#  0 ..DdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..................................................
--//#  1 ..1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s................................................
--//#  2 ....1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..............................................
--//#  3 ......1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s............................................
--//#  4 ........1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..........................................
--//#  5 ..........1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s........................................
--//#  6 ............1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s......................................
--//#  7 ..............1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s....................................
--//#  8 ................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..................................

--//#  9 ..................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s................................
--//# 10 ....................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..............................
--//# 11 ......................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s............................
--//# 12 ........................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..........................
--//# 13 ..........................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s........................
--//# 14 ............................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s......................
--//# 15 ..............................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s....................
--//# 16 ................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..................
--//# 17 ..................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s................

--//# 18 ....................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..............
--//# 19 ......................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s............
--//# 20 ........................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..........
--//# 21 ..........................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s........
--//# 22 ............................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s......
--//# 23 ..............................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s....
--//# 24 ................................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..
--//# 25 ..................................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s
--//# 26 ...................................................assDdddddddddddddddddddddddddddddddddddddddddddddddddddddD



m92_2: entity work.fuq_mul_92(fuq_mul_92) generic map(inst=> 2, expand_type => expand_type) port map( 
       vdd                => vdd                         ,--i--
       gnd                => gnd                         ,--i--
       nclk               => nclk                        ,--i--
       forcee => forcee,--i--
       lcb_delay_lclkr    => delay_lclkr                 ,--i-- tidn
       lcb_mpw1_b         => mpw1_b                      ,--i-- mpw1_b   others=0
       lcb_mpw2_b         => mpw2_b                      ,--i-- mpw2_b   others=0
       thold_b            => thold_0_b                   ,--i--
       lcb_sg             => sg_0                        ,--i--
       si                 => f_mul_si                    ,--i--
       so                 => m92_0_so                    ,--o--
       ex1_act            => ex1_act                     ,--i--
       ----------------------
       c_frac(0 to 53)    => f_fmt_ex1_c_frac(0 to 53)   ,--i-- Multiplicand (shift me)
       a_frac(17 to 34)   => f_fmt_ex1_a_frac(35 to 52)  ,--i-- Multiplier   (recode me)
       a_frac(35)         => tidn                        ,--i-- Multiplier   (recode me)
       hot_one_out        => hot_one_92                  ,--o--
       sum92(2 to 74)     => pp3_05(36 to 108)           ,--o--
       car92(1 to 74)     => pp3_04(35 to 108)          );--o--

m92_1: entity work.fuq_mul_92(fuq_mul_92) generic map(inst=> 1, expand_type => expand_type) port map( 
       vdd                => vdd                         ,--i--
       gnd                => gnd                         ,--i--
       nclk               => nclk                        ,--i--
       forcee => forcee,--i--
       lcb_delay_lclkr    => delay_lclkr                 ,--i-- tidn
       lcb_mpw1_b         => mpw1_b                      ,--i-- mpw1_b   others=0
       lcb_mpw2_b         => mpw2_b                      ,--i-- mpw2_b   others=0
       thold_b            => thold_0_b                   ,--i--
       lcb_sg             => sg_0                        ,--i--
       si                 => m92_0_so                    ,--i--
       so                 => m92_1_so                    ,--o-- v
       ex1_act            => ex1_act                     ,--i--
       ---------------------
       c_frac(0 to 53)    => f_fmt_ex1_c_frac(0 to 53)   ,--i-- Multiplicand (shift me)
       a_frac(17 to 34)   => f_fmt_ex1_a_frac(17 to 34)  ,--i-- Multiplier   (recode me)
       a_frac(35)         => f_fmt_ex1_a_frac_35         ,--i-- Multiplier   (recode me)
       hot_one_out        => hot_one_74                  ,--o--
       sum92(2 to 74)     => pp3_03(18 to 90)            ,--o--
       car92(1 to 74)     => pp3_02(17 to 90)           );--o--

m92_0: entity work.fuq_mul_92(fuq_mul_92) generic map(inst=> 0, expand_type => expand_type) port map( 
       vdd                => vdd                         ,--i--
       gnd                => gnd                         ,--i--
       nclk               => nclk                        ,--i--
       forcee => forcee,--i--
       lcb_delay_lclkr    => delay_lclkr                 ,--i-- tidn
       lcb_mpw1_b         => mpw1_b                      ,--i-- mpw1_b   others=0
       lcb_mpw2_b         => mpw2_b                      ,--i-- mpw2_b   others=0
       thold_b            => thold_0_b                   ,--i--
       lcb_sg             => sg_0                        ,--i--
       si                 => m92_1_so                    ,--i--
       so                 => m92_2_so                    ,--o--
       ex1_act            => ex1_act                     ,--i--
       ---------------------
       c_frac(0 to 53)    => f_fmt_ex1_c_frac(0 to 53)   ,--i-- Multiplicand (shift me)
       a_frac(17)         => tidn                        ,--i-- Multiplier (recode me)
       a_frac(18 to 34)   => f_fmt_ex1_a_frac(0 to 16)   ,--i-- Multiplier (recode me)
       a_frac(35)         => f_fmt_ex1_a_frac_17         ,--i-- Multiplier (recode me)
       hot_one_out        => hot_one_msb_unused          ,--o--
       sum92(2 to 74)     => pp3_01(0 to 72)             ,--o--
       car92(1)           => xtd_unused                  ,--o--
       car92(2 to 74)     => pp3_00(0 to 72)            );--o--



 --//##################################################
 --//# Compressor Level 4  , 5
 --//##################################################

 m62: entity work.fuq_mul_62(fuq_mul_62) port map(
          vdd               => vdd,
          gnd               => gnd,
          hot_one_92        => hot_one_92        ,--i--
          hot_one_74        => hot_one_74        ,--i--
          pp3_05(36 to 108) => pp3_05(36 to 108) ,--i--
          pp3_04(35 to 108) => pp3_04(35 to 108) ,--i--
          pp3_03(18 to  90) => pp3_03(18 to  90) ,--i--
          pp3_02(17 to  90) => pp3_02(17 to  90) ,--i--
          pp3_01( 0 to  72) => pp3_01( 0 to  72) ,--i--
          pp3_00( 0 to  72) => pp3_00( 0 to  72) ,--i--

          sum62(1 to 108)   => pp5_01(1 to 108)  ,--o--
          car62(1 to 108)   => pp5_00(1 to 108) );--o--


--//################################################################
--//# ex2 logic
--//################################################################

   f_mul_ex2_sum(1 to 108) <=  pp5_01(1 to 108); --output
   f_mul_ex2_car(1 to 108) <=  pp5_00(1 to 108); --output

--//################################################################
--//# scan string
--//################################################################


end; -- fuq_mul ARCHITECTURE
