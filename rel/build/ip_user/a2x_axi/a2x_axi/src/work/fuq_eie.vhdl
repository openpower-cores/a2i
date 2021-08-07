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




 
entity fuq_eie is 
generic(  expand_type               : integer := 2  ); 
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

       f_eie_si                                  :in   std_ulogic                    ;
       f_eie_so                                  :out  std_ulogic                    ;
       ex1_act                                   :in   std_ulogic                    ;

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

       f_eie_ex2_lt_bias                         :out  std_ulogic                    ; 
       f_eie_ex2_eq_bias_m1                      :out  std_ulogic                    ; 
       f_eie_ex2_wd_ov                           :out  std_ulogic                    ; 
       f_eie_ex2_dw_ov                           :out  std_ulogic                    ; 
       f_eie_ex2_wd_ov_if                        :out  std_ulogic                    ; 
       f_eie_ex2_dw_ov_if                        :out  std_ulogic                    ; 
       f_eie_ex2_lzo_expo                        :out  std_ulogic_vector(1 to 13)    ; 
       f_eie_ex2_b_expo                          :out  std_ulogic_vector(1 to 13)    ; 
       f_eie_ex2_use_bexp                        :out  std_ulogic;
       f_eie_ex3_iexp                            :out  std_ulogic_vector(1 to 13)      

); 
 
 

end fuq_eie; 
 
 
architecture fuq_eie of fuq_eie is  
 
    constant tiup  :std_ulogic := '1';
    constant tidn  :std_ulogic := '0';
 
    signal sg_0                                  :std_ulogic                   ;
    signal thold_0_b , thold_0, forcee              :std_ulogic                   ;

    signal ex2_act                                 :std_ulogic                   ;
    signal act_spare_unused                        :std_ulogic_vector(0 to 3)    ;
    signal act_so                                  :std_ulogic_vector(0 to 4)    ;
    signal act_si                                  :std_ulogic_vector(0 to 4)    ;
    signal ex2_bop_so                              :std_ulogic_vector(0 to 12)   ;
    signal ex2_bop_si                              :std_ulogic_vector(0 to 12)   ;
    signal ex2_pop_so                              :std_ulogic_vector(0 to 12)   ;
    signal ex2_pop_si                              :std_ulogic_vector(0 to 12)   ;
    signal ex2_ctl_so                              :std_ulogic_vector(0 to 6)    ;
    signal ex2_ctl_si                              :std_ulogic_vector(0 to 6)    ;
    signal ex3_iexp_so                             :std_ulogic_vector(0 to 13)   ;
    signal ex3_iexp_si                             :std_ulogic_vector(0 to 13)   ;
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


   signal ex2_b_expo_fixed :std_ulogic_vector(1 to 13); 
   signal ex1_ge_bias, ex1_lt_bias, ex1_eq_bias_m1 :std_ulogic;
   signal ex2_lt_bias, ex2_eq_bias_m1 :std_ulogic;
  signal  ex1_ep56_g2 :std_ulogic_vector( 2 to 12);
  signal  ex1_ep56_t2 :std_ulogic_vector( 2 to 10);
  signal  ex1_ep56_g4 :std_ulogic_vector( 2 to 12);
  signal  ex1_ep56_t4 :std_ulogic_vector( 2 to 8);
  signal  ex1_ep56_g8 :std_ulogic_vector( 2 to 12);
  signal  ex1_ep56_t8 :std_ulogic_vector( 2 to 4);



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



 


    act_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(2)  ,
        mpw1_b           => mpw1_b(2)       ,
        mpw2_b           => mpw2_b(0)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => fpu_enable, 
        scout            => act_so   ,                     
        scin             => act_si   ,                   
         din(0)             => act_spare_unused(0),
         din(1)             => act_spare_unused(1),
         din(2)             => ex1_act,
         din(3)             => act_spare_unused(2),
         din(4)             => act_spare_unused(3),
        dout(0)             => act_spare_unused(0),
        dout(1)             => act_spare_unused(1),
        dout(2)             => ex2_act,
        dout(3)             => act_spare_unused(2),
        dout(4)             => act_spare_unused(3) );



    ex1_a_expo(1 to 13) <= f_byp_eie_ex1_a_expo(1 to 13);
    ex1_c_expo(1 to 13) <= f_byp_eie_ex1_c_expo(1 to 13);
    ex1_b_expo(1 to 13) <= f_byp_eie_ex1_b_expo(1 to 13);



    
    ex1_ep56_sum( 1) <= not( ex1_a_expo( 1) xor ex1_c_expo( 1) ); 
    ex1_ep56_sum( 2) <= not( ex1_a_expo( 2) xor ex1_c_expo( 2) ); 
    ex1_ep56_sum( 3) <= not( ex1_a_expo( 3) xor ex1_c_expo( 3) ); 
    ex1_ep56_sum( 4) <=    ( ex1_a_expo( 4) xor ex1_c_expo( 4) ); 
    ex1_ep56_sum( 5) <=    ( ex1_a_expo( 5) xor ex1_c_expo( 5) ); 
    ex1_ep56_sum( 6) <=    ( ex1_a_expo( 6) xor ex1_c_expo( 6) ); 
    ex1_ep56_sum( 7) <=    ( ex1_a_expo( 7) xor ex1_c_expo( 7) ); 
    ex1_ep56_sum( 8) <= not( ex1_a_expo( 8) xor ex1_c_expo( 8) ); 
    ex1_ep56_sum( 9) <= not( ex1_a_expo( 9) xor ex1_c_expo( 9) ); 
    ex1_ep56_sum(10) <= not( ex1_a_expo(10) xor ex1_c_expo(10) ); 
    ex1_ep56_sum(11) <=    ( ex1_a_expo(11) xor ex1_c_expo(11) ); 
    ex1_ep56_sum(12) <=    ( ex1_a_expo(12) xor ex1_c_expo(12) ); 
    ex1_ep56_sum(13) <= not( ex1_a_expo(13) xor ex1_c_expo(13) ); 
  
    ex1_ep56_car( 1) <=    ( ex1_a_expo( 2) or  ex1_c_expo( 2) ); 
    ex1_ep56_car( 2) <=    ( ex1_a_expo( 3) or  ex1_c_expo( 3) ); 
    ex1_ep56_car( 3) <=    ( ex1_a_expo( 4) and ex1_c_expo( 4) ); 
    ex1_ep56_car( 4) <=    ( ex1_a_expo( 5) and ex1_c_expo( 5) ); 
    ex1_ep56_car( 5) <=    ( ex1_a_expo( 6) and ex1_c_expo( 6) ); 
    ex1_ep56_car( 6) <=    ( ex1_a_expo( 7) and ex1_c_expo( 7) ); 
    ex1_ep56_car( 7) <=    ( ex1_a_expo( 8) or  ex1_c_expo( 8) ); 
    ex1_ep56_car( 8) <=    ( ex1_a_expo( 9) or  ex1_c_expo( 9) ); 
    ex1_ep56_car( 9) <=    ( ex1_a_expo(10) or  ex1_c_expo(10) ); 
    ex1_ep56_car(10) <=    ( ex1_a_expo(11) and ex1_c_expo(11) ); 
    ex1_ep56_car(11) <=    ( ex1_a_expo(12) and ex1_c_expo(12) ); 
    ex1_ep56_car(12) <=    ( ex1_a_expo(13) or  ex1_c_expo(13) ); 
    
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





   ex1_p_expo_adj(1 to 13) <=
         ( ex1_ep56_s(1 to 13) and (1 to 13 => not f_pic_ex1_fsel) ) or 
         ( ex1_c_expo(1 to 13) and (1 to 13 =>     f_pic_ex1_fsel) );

   


   ex1_from_k( 1) <= tidn; 
   ex1_from_k( 2) <= tidn; 
   ex1_from_k( 3) <= tiup; 
   ex1_from_k( 4) <= tidn; 
   ex1_from_k( 5) <= tidn; 
   ex1_from_k( 6) <= tiup; 
   ex1_from_k( 7) <= tidn; 
   ex1_from_k( 8) <= tiup; 
   ex1_from_k( 9) <= tidn; 
   ex1_from_k(10) <= tidn; 
   ex1_from_k(11) <= tidn; 
   ex1_from_k(12) <= tidn; 
   ex1_from_k(13) <= tiup; 

   ex1_b_expo_adj(1 to 13) <=
       ( ex1_from_k  (1 to 13) and (1 to 13=>     f_pic_ex1_from_integer ) ) or 
       ( ex1_b_expo  (1 to 13) and (1 to 13=> not f_pic_ex1_from_integer ) ) ;




     


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




     ex1_ge_bias   <= 
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
    ex1_eq_bias_m1 <= 
         not ex1_b_expo(1)  and 
         not ex1_b_expo(2)  and 
         not ex1_b_expo(3)  and 
             ex1_b_expo(4)  and 
             ex1_b_expo(5)  and 
             ex1_b_expo(6)  and 
             ex1_b_expo(7)  and 
             ex1_b_expo(8)  and 
             ex1_b_expo(9)  and 
             ex1_b_expo(10) and 
             ex1_b_expo(11) and 
             ex1_b_expo(12) and 
         not ex1_b_expo(13) ;   

                 

  ex2_bop_lat:  tri_rlmreg_p generic map (width=> 13, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(2)  ,
        mpw1_b           => mpw1_b(2)       ,
        mpw2_b           => mpw2_b(0)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex1_act, 
        scout            => ex2_bop_so  ,                      
        scin             => ex2_bop_si  ,                    
         din(0 to 12)       => ex1_b_expo_adj  (1 to 13)   ,
        dout(0 to 12)       => ex2_b_expo_adj  (1 to 13)  );
 
  ex2_pop_lat:  tri_rlmreg_p generic map (width=> 13, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(2)  ,
        mpw1_b           => mpw1_b(2)       ,
        mpw2_b           => mpw2_b(0)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex1_act, 
        scout            => ex2_pop_so  ,                      
        scin             => ex2_pop_si  ,                    
         din(0 to 12)       => ex1_p_expo_adj  (1 to 13)   ,
        dout(0 to 12)       => ex2_p_expo_adj  (1 to 13)  );
 
  ex2_ctl_lat:  tri_rlmreg_p generic map (width=> 7, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(2)  ,
        mpw1_b           => mpw1_b(2)       ,
        mpw2_b           => mpw2_b(0)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex1_act, 
        scout            => ex2_ctl_so  ,                      
        scin             => ex2_ctl_si  ,                    
         din(0)             => ex1_dw_ge ,
         din(1)             => ex1_wd_ge ,
         din(2)             => ex1_wd_eq ,
         din(3)             => ex1_dw_eq ,
         din(4)             => f_pic_ex1_fsel,
         din(5)             => ex1_lt_bias ,
         din(6)             => ex1_eq_bias_m1, 
        dout(0)             => ex2_dw_ge    ,  
        dout(1)             => ex2_wd_ge    ,  
        dout(2)             => ex2_wd_eq    ,  
        dout(3)             => ex2_dw_eq    ,  
        dout(4)             => ex2_fsel     ,  
        dout(5)             => ex2_lt_bias  ,  
        dout(6)             => ex2_eq_bias_m1 );  

        f_eie_ex2_lt_bias    <= ex2_lt_bias;
        f_eie_ex2_eq_bias_m1 <= ex2_eq_bias_m1;

       ex2_p_expo(1 to 13) <=     ex2_p_expo_adj  (1 to 13);
       ex2_b_expo(1 to 13) <=     ex2_b_expo_adj  (1 to 13);

       f_eie_ex2_wd_ov      <=     ex2_wd_ge   ;
       f_eie_ex2_dw_ov      <=     ex2_dw_ge   ;
       f_eie_ex2_wd_ov_if   <=     ex2_wd_eq   ;
       f_eie_ex2_dw_ov_if   <=     ex2_dw_eq   ;

       f_eie_ex2_lzo_expo(1 to 13) <=     ex2_p_expo_adj  (1 to 13) ;
       f_eie_ex2_b_expo(1 to 13) <= ex2_b_expo(1 to 13);
       f_eie_ex2_tbl_expo(1 to 13) <= ex2_b_expo(1 to 13);


 ex2_b_expo_fixed(1 to 13) <= ex2_b_expo(1 to 13) ;

 f_eie_ex2_use_bexp <= ex2_iexp_b_sel ;

       ex2_iexp_b_sel <=
           (f_alg_ex2_sel_byp and not ex2_fsel and f_pic_ex2_math_bzer_b )   or 
            f_fmt_ex2_fsel_bsel      or  
            f_pic_ex2_force_sel_bexp or  
            f_pic_ex2_frsp_ue1 ;         

       ex2_iexp(1 to 13) <=
          ( ex2_b_expo_fixed(1 to 13) and (1 to 13 =>     ex2_iexp_b_sel) ) or 
          ( ex2_p_expo(1 to 13)       and (1 to 13 => not ex2_iexp_b_sel) ) ;


  ex3_iexp_lat:  tri_rlmreg_p generic map (width=> 14, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(3)  ,
        mpw1_b           => mpw1_b(3)       ,
        mpw2_b           => mpw2_b(0)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex2_act, 
        scout            => ex3_iexp_so  ,                      
        scin             => ex3_iexp_si  ,                    
         din(0)             => f_pic_ex2_sp_b   ,
         din(1 to 13)       => ex2_iexp  (1 to 13)   ,
        dout(0)             => ex3_sp_b               ,
        dout(1 to 13)       => ex3_iexp  (1 to 13)   );




       f_eie_ex3_iexp(1 to 13)    <=     ex3_iexp(1 to 13)   ;





    ex2_bop_si     (0 to 12)  <= ex2_bop_so     (1 to 12)  &  f_eie_si;
    ex2_pop_si     (0 to 12)  <= ex2_pop_so     (1 to 12)  &  ex2_bop_so  (0);
    ex2_ctl_si     (0 to 6)   <= ex2_ctl_so     (1 to 6)   &  ex2_pop_so  (0);
    ex3_iexp_si    (0 to 13)  <= ex3_iexp_so    (1 to 13)  &  ex2_ctl_so  (0);
    act_si         (0 to 4)   <= act_so         (1 to 4)   &  ex3_iexp_so  (0);
    f_eie_so                  <=   act_so  (0);


end; 
  






