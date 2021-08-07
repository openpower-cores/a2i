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
       clkoff_b                                  :in   std_ulogic; 
       act_dis                                   :in   std_ulogic; 
       flush                                     :in   std_ulogic; 
       delay_lclkr                               :in   std_ulogic; 
       mpw1_b                                    :in   std_ulogic; 
       mpw2_b                                    :in   std_ulogic; 
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; 
       nclk                                      :in   clk_logic;

       f_mul_si                  :in  std_ulogic; 
       f_mul_so                  :out std_ulogic; 
       ex1_act                   :in  std_ulogic; 

       f_fmt_ex1_a_frac          :in  std_ulogic_vector(0 to 52) ;
       f_fmt_ex1_a_frac_17       :in  std_ulogic;
       f_fmt_ex1_a_frac_35       :in  std_ulogic;
       f_fmt_ex1_c_frac          :in  std_ulogic_vector(0 to 53) ;

       f_mul_ex2_sum             :out std_ulogic_vector(1 to 108); 
       f_mul_ex2_car             :out std_ulogic_vector(1 to 108)
);



end fuq_mul; 

architecture fuq_mul of fuq_mul is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal thold_0_b, thold_0, forcee                       :std_ulogic;
    signal sg_0                           :std_ulogic;
    signal spare_unused                     :std_ulogic_vector(0 to 3);
    signal act_so , act_si                 :std_ulogic_vector(0 to 3);
    signal m92_0_so, m92_1_so, m92_2_so    :std_ulogic;
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




    act_lat:  tri_rlmreg_p generic map (width=> 4, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr  ,
        mpw1_b           => mpw1_b       ,
        mpw2_b           => mpw2_b       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0,
        scout            => act_so,                      
        scin             => act_si,
        din(0)           => spare_unused(0),
        din(1)           => spare_unused(1),
        din(2)           => spare_unused(2),
        din(3)           => spare_unused(3),
        dout(0)          => spare_unused(0),
        dout(1)          => spare_unused(1),
        dout(2)          => spare_unused(2) ,
        dout(3)          => spare_unused(3) );

act_si(0 to 3)        <= act_so(1 to 3) & m92_2_so;

f_mul_so  <= act_so(0) ; 











m92_2: entity work.fuq_mul_92(fuq_mul_92) generic map(inst=> 2, expand_type => expand_type) port map( 
       vdd                => vdd                         ,
       gnd                => gnd                         ,
       nclk               => nclk                        ,
       forcee => forcee,
       lcb_delay_lclkr    => delay_lclkr                 ,
       lcb_mpw1_b         => mpw1_b                      ,
       lcb_mpw2_b         => mpw2_b                      ,
       thold_b            => thold_0_b                   ,
       lcb_sg             => sg_0                        ,
       si                 => f_mul_si                    ,
       so                 => m92_0_so                    ,
       ex1_act            => ex1_act                     ,
       c_frac(0 to 53)    => f_fmt_ex1_c_frac(0 to 53)   ,
       a_frac(17 to 34)   => f_fmt_ex1_a_frac(35 to 52)  ,
       a_frac(35)         => tidn                        ,
       hot_one_out        => hot_one_92                  ,
       sum92(2 to 74)     => pp3_05(36 to 108)           ,
       car92(1 to 74)     => pp3_04(35 to 108)          );

m92_1: entity work.fuq_mul_92(fuq_mul_92) generic map(inst=> 1, expand_type => expand_type) port map( 
       vdd                => vdd                         ,
       gnd                => gnd                         ,
       nclk               => nclk                        ,
       forcee => forcee,
       lcb_delay_lclkr    => delay_lclkr                 ,
       lcb_mpw1_b         => mpw1_b                      ,
       lcb_mpw2_b         => mpw2_b                      ,
       thold_b            => thold_0_b                   ,
       lcb_sg             => sg_0                        ,
       si                 => m92_0_so                    ,
       so                 => m92_1_so                    ,
       ex1_act            => ex1_act                     ,
       c_frac(0 to 53)    => f_fmt_ex1_c_frac(0 to 53)   ,
       a_frac(17 to 34)   => f_fmt_ex1_a_frac(17 to 34)  ,
       a_frac(35)         => f_fmt_ex1_a_frac_35         ,
       hot_one_out        => hot_one_74                  ,
       sum92(2 to 74)     => pp3_03(18 to 90)            ,
       car92(1 to 74)     => pp3_02(17 to 90)           );

m92_0: entity work.fuq_mul_92(fuq_mul_92) generic map(inst=> 0, expand_type => expand_type) port map( 
       vdd                => vdd                         ,
       gnd                => gnd                         ,
       nclk               => nclk                        ,
       forcee => forcee,
       lcb_delay_lclkr    => delay_lclkr                 ,
       lcb_mpw1_b         => mpw1_b                      ,
       lcb_mpw2_b         => mpw2_b                      ,
       thold_b            => thold_0_b                   ,
       lcb_sg             => sg_0                        ,
       si                 => m92_1_so                    ,
       so                 => m92_2_so                    ,
       ex1_act            => ex1_act                     ,
       c_frac(0 to 53)    => f_fmt_ex1_c_frac(0 to 53)   ,
       a_frac(17)         => tidn                        ,
       a_frac(18 to 34)   => f_fmt_ex1_a_frac(0 to 16)   ,
       a_frac(35)         => f_fmt_ex1_a_frac_17         ,
       hot_one_out        => hot_one_msb_unused          ,
       sum92(2 to 74)     => pp3_01(0 to 72)             ,
       car92(1)           => xtd_unused                  ,
       car92(2 to 74)     => pp3_00(0 to 72)            );




 m62: entity work.fuq_mul_62(fuq_mul_62) port map(
          vdd               => vdd,
          gnd               => gnd,
          hot_one_92        => hot_one_92        ,
          hot_one_74        => hot_one_74        ,
          pp3_05(36 to 108) => pp3_05(36 to 108) ,
          pp3_04(35 to 108) => pp3_04(35 to 108) ,
          pp3_03(18 to  90) => pp3_03(18 to  90) ,
          pp3_02(17 to  90) => pp3_02(17 to  90) ,
          pp3_01( 0 to  72) => pp3_01( 0 to  72) ,
          pp3_00( 0 to  72) => pp3_00( 0 to  72) ,

          sum62(1 to 108)   => pp5_01(1 to 108)  ,
          car62(1 to 108)   => pp5_00(1 to 108) );



   f_mul_ex2_sum(1 to 108) <=  pp5_01(1 to 108); 
   f_mul_ex2_car(1 to 108) <=  pp5_00(1 to 108); 



end; 





     




