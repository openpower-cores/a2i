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


 
ENTITY fuq_tblexp IS
generic(
       expand_type               : integer := 2  ); 
PORT( 
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

       si                                        :in   std_ulogic                    ;
       so                                        :out  std_ulogic                    ;
       ex1_act_b                                 :in   std_ulogic                    ;

       f_pic_ex2_ue1                             :in   std_ulogic; 
       f_pic_ex2_sp_b                            :in   std_ulogic; 
       f_pic_ex2_est_recip                       :in   std_ulogic; 
       f_pic_ex2_est_rsqrt                       :in   std_ulogic;
       f_eie_ex2_tbl_expo                        :in   std_ulogic_vector(1 to 13);
       f_fmt_ex2_lu_den_recip                    :in   std_ulogic  ;
       f_fmt_ex2_lu_den_rsqrto                   :in   std_ulogic  ;

       f_tbe_ex3_recip_ue1                       :out  std_ulogic ; 
       f_tbe_ex3_lu_sh                           :out  std_ulogic ;
       f_tbe_ex3_match_en_sp                     :out  std_ulogic ;
       f_tbe_ex3_match_en_dp                     :out  std_ulogic ;
       f_tbe_ex3_recip_2046                      :out  std_ulogic ;
       f_tbe_ex3_recip_2045                      :out  std_ulogic ;      
       f_tbe_ex3_recip_2044                      :out  std_ulogic ;
       f_tbe_ex3_may_ov                          :out  std_ulogic ;
       f_tbe_ex3_res_expo                        :out  std_ulogic_vector(1 to 13)    

); 
 
 

end fuq_tblexp; 
 
 
architecture fuq_tblexp of fuq_tblexp is 
 
    constant tiup  :std_ulogic := '1';
    constant tidn  :std_ulogic := '0';

    signal thold_0_b, thold_0, forcee,  sg_0 : std_ulogic;
    signal act_spare_unused :std_ulogic_vector(0 to 3);
    signal ex2_act :std_ulogic;
    signal act_so  ,  act_si   :std_ulogic_vector(0 to 4);                   
    signal ex3_expo_so  ,  ex3_expo_si   :std_ulogic_vector(0 to 19);                   
    signal ex2_res_expo  :std_ulogic_vector(1 to 13);
    signal ex3_res_expo                  :std_ulogic_vector(1 to 13);
    signal ex3_recip_2044, ex2_recip_2044, ex2_recip_ue1 :std_ulogic;
    signal ex3_recip_2045, ex2_recip_2045, ex3_recip_ue1 :std_ulogic;
    signal ex3_recip_2046, ex2_recip_2046 :std_ulogic;
    signal ex3_force_expo_den :std_ulogic;

    signal ex2_b_expo_adj_b :std_ulogic_vector(1 to 13);
    signal ex2_b_expo_adj   :std_ulogic_vector(1 to 13);
    signal ex2_recip_k      :std_ulogic_vector(1 to 13);
    signal ex2_recip_p      :std_ulogic_vector(1 to 13);
    signal ex2_recip_g      :std_ulogic_vector(2 to 13);
    signal ex2_recip_t      :std_ulogic_vector(2 to 12);
    signal ex2_recip_c      :std_ulogic_vector(2 to 13);
    signal ex2_recip_expo   :std_ulogic_vector(1 to 13);
    signal ex2_rsqrt_k      :std_ulogic_vector(1 to 13);
    signal ex2_rsqrt_p      :std_ulogic_vector(1 to 13);
    signal ex2_rsqrt_g      :std_ulogic_vector(2 to 13);
    signal ex2_rsqrt_t      :std_ulogic_vector(2 to 12);
    signal ex2_rsqrt_c      :std_ulogic_vector(2 to 13);
    signal ex2_rsqrt_expo   :std_ulogic_vector(1 to 13);
    signal ex2_rsqrt_bsh_b  :std_ulogic_vector(1 to 13);

  signal ex2_recip_g2 :std_ulogic_vector(2 to 13);
  signal ex2_recip_t2 :std_ulogic_vector(2 to 11);
  signal ex2_recip_g4 :std_ulogic_vector(2 to 13);
  signal ex2_recip_t4 :std_ulogic_vector(2 to  9);
  signal ex2_recip_g8 :std_ulogic_vector(2 to 13);
  signal ex2_recip_t8 :std_ulogic_vector(2 to  5);

  signal ex2_rsqrt_g2 :std_ulogic_vector(2 to 13);
  signal ex2_rsqrt_t2 :std_ulogic_vector(2 to 11);
  signal ex2_rsqrt_g4 :std_ulogic_vector(2 to 13);
  signal ex2_rsqrt_t4 :std_ulogic_vector(2 to  9);
  signal ex2_rsqrt_g8 :std_ulogic_vector(2 to 13);
  signal ex2_rsqrt_t8 :std_ulogic_vector(2 to  5);
  signal ex1_act :std_ulogic;

  signal ex2_lu_sh, ex3_lu_sh :std_ulogic;
   signal ex3_res_expo_c, ex3_res_expo_g8_b, ex3_res_expo_g4, ex3_res_expo_g2_b :std_ulogic_vector(2 to 13);
   signal ex3_res_decr, ex3_res_expo_b :std_ulogic_vector(1 to 13);
   signal ex3_decr_expo :std_ulogic;

  signal ex2_mid_match_ifsp, ex2_mid_match_ifdp :std_ulogic;
  signal ex2_match_en_dp,    ex2_match_en_sp :std_ulogic;
  signal ex3_match_en_dp,    ex3_match_en_sp :std_ulogic;
  signal ex2_com_match  :std_ulogic;
  signal ex3_recip_2044_dp, ex3_recip_2045_dp, ex3_recip_2046_dp :std_ulogic;
   



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
    



 

    ex1_act <= not ex1_act_b ;

    act_lat: tri_rlmreg_p  generic map (width=> 5, expand_type => expand_type) port map ( 
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
        din(0)           => act_spare_unused(0),
        din(1)           => act_spare_unused(1),
        din(2)           => ex1_act,
        din(3)           => act_spare_unused(2),
        din(4)           => act_spare_unused(3),
        dout(0)          => act_spare_unused(0),
        dout(1)          => act_spare_unused(1),
        dout(2)          => ex2_act,
        dout(3)          => act_spare_unused(2),
        dout(4)          => act_spare_unused(3) );





  ex2_b_expo_adj(1 to 13) <= f_eie_ex2_tbl_expo(1 to 13);
  ex2_b_expo_adj_b(1 to 13) <= not ex2_b_expo_adj(1 to 13);

  

  ex2_recip_k(1 to 13) <= (1 to 2=> tidn) & (3 to 12=> tiup) & tidn ;

  ex2_recip_p(1 to 13) <= ex2_recip_k(1 to 13) xor ex2_b_expo_adj_b(1 to 13) ;
  ex2_recip_g(2 to 13) <= ex2_recip_k(2 to 13) and ex2_b_expo_adj_b(2 to 13) ;
  ex2_recip_t(2 to 12) <= ex2_recip_k(2 to 12)  or ex2_b_expo_adj_b(2 to 12) ;

  ex2_recip_g2(13) <= ex2_recip_g(13);
  ex2_recip_g2(12) <= ex2_recip_g(12) or (ex2_recip_t(12) and ex2_recip_g(13) );
  ex2_recip_g2(11) <= ex2_recip_g(11) or (ex2_recip_t(11) and ex2_recip_g(12) );
  ex2_recip_g2(10) <= ex2_recip_g(10) or (ex2_recip_t(10) and ex2_recip_g(11) );
  ex2_recip_g2( 9) <= ex2_recip_g( 9) or (ex2_recip_t( 9) and ex2_recip_g(10) );
  ex2_recip_g2( 8) <= ex2_recip_g( 8) or (ex2_recip_t( 8) and ex2_recip_g( 9) );
  ex2_recip_g2( 7) <= ex2_recip_g( 7) or (ex2_recip_t( 7) and ex2_recip_g( 8) );
  ex2_recip_g2( 6) <= ex2_recip_g( 6) or (ex2_recip_t( 6) and ex2_recip_g( 7) );
  ex2_recip_g2( 5) <= ex2_recip_g( 5) or (ex2_recip_t( 5) and ex2_recip_g( 6) );
  ex2_recip_g2( 4) <= ex2_recip_g( 4) or (ex2_recip_t( 4) and ex2_recip_g( 5) );
  ex2_recip_g2( 3) <= ex2_recip_g( 3) or (ex2_recip_t( 3) and ex2_recip_g( 4) );
  ex2_recip_g2( 2) <= ex2_recip_g( 2) or (ex2_recip_t( 2) and ex2_recip_g( 3) );

  ex2_recip_t2(11) <=                    (ex2_recip_t(11) and ex2_recip_t(12) );
  ex2_recip_t2(10) <=                    (ex2_recip_t(10) and ex2_recip_t(11) );
  ex2_recip_t2( 9) <=                    (ex2_recip_t( 9) and ex2_recip_t(10) );
  ex2_recip_t2( 8) <=                    (ex2_recip_t( 8) and ex2_recip_t( 9) );
  ex2_recip_t2( 7) <=                    (ex2_recip_t( 7) and ex2_recip_t( 8) );
  ex2_recip_t2( 6) <=                    (ex2_recip_t( 6) and ex2_recip_t( 7) );
  ex2_recip_t2( 5) <=                    (ex2_recip_t( 5) and ex2_recip_t( 6) );
  ex2_recip_t2( 4) <=                    (ex2_recip_t( 4) and ex2_recip_t( 5) );
  ex2_recip_t2( 3) <=                    (ex2_recip_t( 3) and ex2_recip_t( 4) );
  ex2_recip_t2( 2) <=                    (ex2_recip_t( 2) and ex2_recip_t( 3) );

  ex2_recip_g4(13) <= ex2_recip_g2(13);
  ex2_recip_g4(12) <= ex2_recip_g2(12);
  ex2_recip_g4(11) <= ex2_recip_g2(11) or (ex2_recip_t2(11) and ex2_recip_g2(13) );
  ex2_recip_g4(10) <= ex2_recip_g2(10) or (ex2_recip_t2(10) and ex2_recip_g2(12) );
  ex2_recip_g4( 9) <= ex2_recip_g2( 9) or (ex2_recip_t2( 9) and ex2_recip_g2(11) );
  ex2_recip_g4( 8) <= ex2_recip_g2( 8) or (ex2_recip_t2( 8) and ex2_recip_g2(10) );
  ex2_recip_g4( 7) <= ex2_recip_g2( 7) or (ex2_recip_t2( 7) and ex2_recip_g2( 9) );
  ex2_recip_g4( 6) <= ex2_recip_g2( 6) or (ex2_recip_t2( 6) and ex2_recip_g2( 8) );
  ex2_recip_g4( 5) <= ex2_recip_g2( 5) or (ex2_recip_t2( 5) and ex2_recip_g2( 7) );
  ex2_recip_g4( 4) <= ex2_recip_g2( 4) or (ex2_recip_t2( 4) and ex2_recip_g2( 6) );
  ex2_recip_g4( 3) <= ex2_recip_g2( 3) or (ex2_recip_t2( 3) and ex2_recip_g2( 5) );
  ex2_recip_g4( 2) <= ex2_recip_g2( 2) or (ex2_recip_t2( 2) and ex2_recip_g2( 4) );

  ex2_recip_t4( 9) <=                     (ex2_recip_t2( 9) and ex2_recip_t2(11) );
  ex2_recip_t4( 8) <=                     (ex2_recip_t2( 8) and ex2_recip_t2(10) );
  ex2_recip_t4( 7) <=                     (ex2_recip_t2( 7) and ex2_recip_t2( 9) );
  ex2_recip_t4( 6) <=                     (ex2_recip_t2( 6) and ex2_recip_t2( 8) );
  ex2_recip_t4( 5) <=                     (ex2_recip_t2( 5) and ex2_recip_t2( 7) );
  ex2_recip_t4( 4) <=                     (ex2_recip_t2( 4) and ex2_recip_t2( 6) );
  ex2_recip_t4( 3) <=                     (ex2_recip_t2( 3) and ex2_recip_t2( 5) );
  ex2_recip_t4( 2) <=                     (ex2_recip_t2( 2) and ex2_recip_t2( 4) );

  ex2_recip_g8(13) <= ex2_recip_g4(13);
  ex2_recip_g8(12) <= ex2_recip_g4(12);
  ex2_recip_g8(11) <= ex2_recip_g4(11);
  ex2_recip_g8(10) <= ex2_recip_g4(10);
  ex2_recip_g8( 9) <= ex2_recip_g4( 9) or (ex2_recip_t4( 9) and ex2_recip_g4(13) );
  ex2_recip_g8( 8) <= ex2_recip_g4( 8) or (ex2_recip_t4( 8) and ex2_recip_g4(12) );
  ex2_recip_g8( 7) <= ex2_recip_g4( 7) or (ex2_recip_t4( 7) and ex2_recip_g4(11) );
  ex2_recip_g8( 6) <= ex2_recip_g4( 6) or (ex2_recip_t4( 6) and ex2_recip_g4(10) );
  ex2_recip_g8( 5) <= ex2_recip_g4( 5) or (ex2_recip_t4( 5) and ex2_recip_g4( 9) );
  ex2_recip_g8( 4) <= ex2_recip_g4( 4) or (ex2_recip_t4( 4) and ex2_recip_g4( 8) );
  ex2_recip_g8( 3) <= ex2_recip_g4( 3) or (ex2_recip_t4( 3) and ex2_recip_g4( 7) );
  ex2_recip_g8( 2) <= ex2_recip_g4( 2) or (ex2_recip_t4( 2) and ex2_recip_g4( 6) );

  ex2_recip_t8( 5) <=                     (ex2_recip_t4( 5) and ex2_recip_t4( 9) );
  ex2_recip_t8( 4) <=                     (ex2_recip_t4( 4) and ex2_recip_t4( 8) );
  ex2_recip_t8( 3) <=                     (ex2_recip_t4( 3) and ex2_recip_t4( 7) );
  ex2_recip_t8( 2) <=                     (ex2_recip_t4( 2) and ex2_recip_t4( 6) );

  ex2_recip_c(13) <= ex2_recip_g8(13);
  ex2_recip_c(12) <= ex2_recip_g8(12);
  ex2_recip_c(11) <= ex2_recip_g8(11);
  ex2_recip_c(10) <= ex2_recip_g8(10);
  ex2_recip_c( 9) <= ex2_recip_g8( 9);
  ex2_recip_c( 8) <= ex2_recip_g8( 8);
  ex2_recip_c( 7) <= ex2_recip_g8( 7);
  ex2_recip_c( 6) <= ex2_recip_g8( 6);
  ex2_recip_c( 5) <= ex2_recip_g8( 5) or (ex2_recip_t8( 5) and ex2_recip_g8(13) );
  ex2_recip_c( 4) <= ex2_recip_g8( 4) or (ex2_recip_t8( 4) and ex2_recip_g8(12) );
  ex2_recip_c( 3) <= ex2_recip_g8( 3) or (ex2_recip_t8( 3) and ex2_recip_g8(11) );
  ex2_recip_c( 2) <= ex2_recip_g8( 2) or (ex2_recip_t8( 2) and ex2_recip_g8(10) );


  ex2_recip_expo(1 to 12) <= ex2_recip_p(1 to 12) xor ex2_recip_c(2 to 13);
  ex2_recip_expo(13)      <= ex2_recip_p(13);
 


  ex2_rsqrt_k(1 to 13) <= tidn & tidn & tiup & tidn & (5 to 12=> tiup) & ex2_b_expo_adj_b(13);
  ex2_rsqrt_bsh_b(1 to 13) <= ex2_b_expo_adj_b(1) & ex2_b_expo_adj_b(1 to 12); 

  ex2_rsqrt_p(1 to 13) <= ex2_rsqrt_k(1 to 13) xor ex2_rsqrt_bsh_b(1 to 13) ;
  ex2_rsqrt_g(2 to 13) <= ex2_rsqrt_k(2 to 13) and ex2_rsqrt_bsh_b(2 to 13) ;
  ex2_rsqrt_t(2 to 12) <= ex2_rsqrt_k(2 to 12)  or ex2_rsqrt_bsh_b(2 to 12) ;

 

  ex2_rsqrt_g2(13) <= ex2_rsqrt_g(13);
  ex2_rsqrt_g2(12) <= ex2_rsqrt_g(12) or (ex2_rsqrt_t(12) and ex2_rsqrt_g(13) );
  ex2_rsqrt_g2(11) <= ex2_rsqrt_g(11) or (ex2_rsqrt_t(11) and ex2_rsqrt_g(12) );
  ex2_rsqrt_g2(10) <= ex2_rsqrt_g(10) or (ex2_rsqrt_t(10) and ex2_rsqrt_g(11) );
  ex2_rsqrt_g2( 9) <= ex2_rsqrt_g( 9) or (ex2_rsqrt_t( 9) and ex2_rsqrt_g(10) );
  ex2_rsqrt_g2( 8) <= ex2_rsqrt_g( 8) or (ex2_rsqrt_t( 8) and ex2_rsqrt_g( 9) );
  ex2_rsqrt_g2( 7) <= ex2_rsqrt_g( 7) or (ex2_rsqrt_t( 7) and ex2_rsqrt_g( 8) );
  ex2_rsqrt_g2( 6) <= ex2_rsqrt_g( 6) or (ex2_rsqrt_t( 6) and ex2_rsqrt_g( 7) );
  ex2_rsqrt_g2( 5) <= ex2_rsqrt_g( 5) or (ex2_rsqrt_t( 5) and ex2_rsqrt_g( 6) );
  ex2_rsqrt_g2( 4) <= ex2_rsqrt_g( 4) or (ex2_rsqrt_t( 4) and ex2_rsqrt_g( 5) );
  ex2_rsqrt_g2( 3) <= ex2_rsqrt_g( 3) or (ex2_rsqrt_t( 3) and ex2_rsqrt_g( 4) );
  ex2_rsqrt_g2( 2) <= ex2_rsqrt_g( 2) or (ex2_rsqrt_t( 2) and ex2_rsqrt_g( 3) );

  ex2_rsqrt_t2(11) <=                    (ex2_rsqrt_t(11) and ex2_rsqrt_t(12) );
  ex2_rsqrt_t2(10) <=                    (ex2_rsqrt_t(10) and ex2_rsqrt_t(11) );
  ex2_rsqrt_t2( 9) <=                    (ex2_rsqrt_t( 9) and ex2_rsqrt_t(10) );
  ex2_rsqrt_t2( 8) <=                    (ex2_rsqrt_t( 8) and ex2_rsqrt_t( 9) );
  ex2_rsqrt_t2( 7) <=                    (ex2_rsqrt_t( 7) and ex2_rsqrt_t( 8) );
  ex2_rsqrt_t2( 6) <=                    (ex2_rsqrt_t( 6) and ex2_rsqrt_t( 7) );
  ex2_rsqrt_t2( 5) <=                    (ex2_rsqrt_t( 5) and ex2_rsqrt_t( 6) );
  ex2_rsqrt_t2( 4) <=                    (ex2_rsqrt_t( 4) and ex2_rsqrt_t( 5) );
  ex2_rsqrt_t2( 3) <=                    (ex2_rsqrt_t( 3) and ex2_rsqrt_t( 4) );
  ex2_rsqrt_t2( 2) <=                    (ex2_rsqrt_t( 2) and ex2_rsqrt_t( 3) );

  ex2_rsqrt_g4(13) <= ex2_rsqrt_g2(13);
  ex2_rsqrt_g4(12) <= ex2_rsqrt_g2(12);
  ex2_rsqrt_g4(11) <= ex2_rsqrt_g2(11) or (ex2_rsqrt_t2(11) and ex2_rsqrt_g2(13) );
  ex2_rsqrt_g4(10) <= ex2_rsqrt_g2(10) or (ex2_rsqrt_t2(10) and ex2_rsqrt_g2(12) );
  ex2_rsqrt_g4( 9) <= ex2_rsqrt_g2( 9) or (ex2_rsqrt_t2( 9) and ex2_rsqrt_g2(11) );
  ex2_rsqrt_g4( 8) <= ex2_rsqrt_g2( 8) or (ex2_rsqrt_t2( 8) and ex2_rsqrt_g2(10) );
  ex2_rsqrt_g4( 7) <= ex2_rsqrt_g2( 7) or (ex2_rsqrt_t2( 7) and ex2_rsqrt_g2( 9) );
  ex2_rsqrt_g4( 6) <= ex2_rsqrt_g2( 6) or (ex2_rsqrt_t2( 6) and ex2_rsqrt_g2( 8) );
  ex2_rsqrt_g4( 5) <= ex2_rsqrt_g2( 5) or (ex2_rsqrt_t2( 5) and ex2_rsqrt_g2( 7) );
  ex2_rsqrt_g4( 4) <= ex2_rsqrt_g2( 4) or (ex2_rsqrt_t2( 4) and ex2_rsqrt_g2( 6) );
  ex2_rsqrt_g4( 3) <= ex2_rsqrt_g2( 3) or (ex2_rsqrt_t2( 3) and ex2_rsqrt_g2( 5) );
  ex2_rsqrt_g4( 2) <= ex2_rsqrt_g2( 2) or (ex2_rsqrt_t2( 2) and ex2_rsqrt_g2( 4) );

  ex2_rsqrt_t4( 9) <=                     (ex2_rsqrt_t2( 9) and ex2_rsqrt_t2(11) );
  ex2_rsqrt_t4( 8) <=                     (ex2_rsqrt_t2( 8) and ex2_rsqrt_t2(10) );
  ex2_rsqrt_t4( 7) <=                     (ex2_rsqrt_t2( 7) and ex2_rsqrt_t2( 9) );
  ex2_rsqrt_t4( 6) <=                     (ex2_rsqrt_t2( 6) and ex2_rsqrt_t2( 8) );
  ex2_rsqrt_t4( 5) <=                     (ex2_rsqrt_t2( 5) and ex2_rsqrt_t2( 7) );
  ex2_rsqrt_t4( 4) <=                     (ex2_rsqrt_t2( 4) and ex2_rsqrt_t2( 6) );
  ex2_rsqrt_t4( 3) <=                     (ex2_rsqrt_t2( 3) and ex2_rsqrt_t2( 5) );
  ex2_rsqrt_t4( 2) <=                     (ex2_rsqrt_t2( 2) and ex2_rsqrt_t2( 4) );

  ex2_rsqrt_g8(13) <= ex2_rsqrt_g4(13);
  ex2_rsqrt_g8(12) <= ex2_rsqrt_g4(12);
  ex2_rsqrt_g8(11) <= ex2_rsqrt_g4(11);
  ex2_rsqrt_g8(10) <= ex2_rsqrt_g4(10);
  ex2_rsqrt_g8( 9) <= ex2_rsqrt_g4( 9) or (ex2_rsqrt_t4( 9) and ex2_rsqrt_g4(13) );
  ex2_rsqrt_g8( 8) <= ex2_rsqrt_g4( 8) or (ex2_rsqrt_t4( 8) and ex2_rsqrt_g4(12) );
  ex2_rsqrt_g8( 7) <= ex2_rsqrt_g4( 7) or (ex2_rsqrt_t4( 7) and ex2_rsqrt_g4(11) );
  ex2_rsqrt_g8( 6) <= ex2_rsqrt_g4( 6) or (ex2_rsqrt_t4( 6) and ex2_rsqrt_g4(10) );
  ex2_rsqrt_g8( 5) <= ex2_rsqrt_g4( 5) or (ex2_rsqrt_t4( 5) and ex2_rsqrt_g4( 9) );
  ex2_rsqrt_g8( 4) <= ex2_rsqrt_g4( 4) or (ex2_rsqrt_t4( 4) and ex2_rsqrt_g4( 8) );
  ex2_rsqrt_g8( 3) <= ex2_rsqrt_g4( 3) or (ex2_rsqrt_t4( 3) and ex2_rsqrt_g4( 7) );
  ex2_rsqrt_g8( 2) <= ex2_rsqrt_g4( 2) or (ex2_rsqrt_t4( 2) and ex2_rsqrt_g4( 6) );

  ex2_rsqrt_t8( 5) <=                     (ex2_rsqrt_t4( 5) and ex2_rsqrt_t4( 9) );
  ex2_rsqrt_t8( 4) <=                     (ex2_rsqrt_t4( 4) and ex2_rsqrt_t4( 8) );
  ex2_rsqrt_t8( 3) <=                     (ex2_rsqrt_t4( 3) and ex2_rsqrt_t4( 7) );
  ex2_rsqrt_t8( 2) <=                     (ex2_rsqrt_t4( 2) and ex2_rsqrt_t4( 6) );

  ex2_rsqrt_c(13) <= ex2_rsqrt_g8(13);
  ex2_rsqrt_c(12) <= ex2_rsqrt_g8(12);
  ex2_rsqrt_c(11) <= ex2_rsqrt_g8(11);
  ex2_rsqrt_c(10) <= ex2_rsqrt_g8(10);
  ex2_rsqrt_c( 9) <= ex2_rsqrt_g8( 9);
  ex2_rsqrt_c( 8) <= ex2_rsqrt_g8( 8);
  ex2_rsqrt_c( 7) <= ex2_rsqrt_g8( 7);
  ex2_rsqrt_c( 6) <= ex2_rsqrt_g8( 6);
  ex2_rsqrt_c( 5) <= ex2_rsqrt_g8( 5) or (ex2_rsqrt_t8( 5) and ex2_rsqrt_g8(13) );
  ex2_rsqrt_c( 4) <= ex2_rsqrt_g8( 4) or (ex2_rsqrt_t8( 4) and ex2_rsqrt_g8(12) );
  ex2_rsqrt_c( 3) <= ex2_rsqrt_g8( 3) or (ex2_rsqrt_t8( 3) and ex2_rsqrt_g8(11) );
  ex2_rsqrt_c( 2) <= ex2_rsqrt_g8( 2) or (ex2_rsqrt_t8( 2) and ex2_rsqrt_g8(10) );



  ex2_rsqrt_expo(1 to 12) <= ex2_rsqrt_p(1 to 12) xor ex2_rsqrt_c(2 to 13);
  ex2_rsqrt_expo(13)      <= ex2_rsqrt_p(13);


  ex2_res_expo(1 to 13) <=
      ( (1 to 13=> f_pic_ex2_est_rsqrt) and ex2_rsqrt_expo(1 to 13) ) or 
      ( (1 to 13=> f_pic_ex2_est_recip) and ex2_recip_expo(1 to 13) ) ;



        

  ex2_mid_match_ifsp <= not f_eie_ex2_tbl_expo( 4) and 
                        not f_eie_ex2_tbl_expo( 5) and 
                        not f_eie_ex2_tbl_expo( 6) ;   

  ex2_mid_match_ifdp <=     f_eie_ex2_tbl_expo( 4) and 
                            f_eie_ex2_tbl_expo( 5) and 
                            f_eie_ex2_tbl_expo( 6) ;   

  ex2_com_match      <= not f_eie_ex2_tbl_expo( 1) and 
                        not f_eie_ex2_tbl_expo( 2) and 
                            f_eie_ex2_tbl_expo( 3) and 
                            f_eie_ex2_tbl_expo( 7) and 
                            f_eie_ex2_tbl_expo( 8) and 
                            f_eie_ex2_tbl_expo( 9) and 
                            f_eie_ex2_tbl_expo(10) and 
                            f_eie_ex2_tbl_expo(11) ;   

   ex2_match_en_dp  <= ex2_com_match and     f_pic_ex2_sp_b and ex2_mid_match_ifdp ;
   ex2_match_en_sp  <= ex2_com_match and not f_pic_ex2_sp_b and ex2_mid_match_ifsp ;

   ex2_recip_2046 <=     f_pic_ex2_est_recip    and             
                         f_eie_ex2_tbl_expo(12) and 
                     not f_eie_ex2_tbl_expo(13)   ; 

   ex2_recip_2045 <=     f_pic_ex2_est_recip    and             
                     not f_eie_ex2_tbl_expo(12) and 
                         f_eie_ex2_tbl_expo(13)   ; 

   ex2_recip_2044 <=     f_pic_ex2_est_recip    and             
                     not f_eie_ex2_tbl_expo(12) and 
                     not f_eie_ex2_tbl_expo(13)   ; 

    ex2_recip_ue1 <= f_pic_ex2_est_recip    and   f_pic_ex2_ue1 ;

  

    ex2_lu_sh <= (f_fmt_ex2_lu_den_recip  and f_pic_ex2_est_recip                            ) or 
                 (f_fmt_ex2_lu_den_rsqrto and f_pic_ex2_est_rsqrt and not f_eie_ex2_tbl_expo(13) );

   ex3_expo_lat: tri_rlmreg_p  generic map (width=> 20, expand_type => expand_type) port map ( 
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
        scout            => ex3_expo_so  ,                      
        scin             => ex3_expo_si  ,
                    
        din(0 to 12)     => ex2_res_expo(1 to 13)   ,
        din(13)          => ex2_match_en_dp ,
        din(14)          => ex2_match_en_sp ,
        din(15)          => ex2_recip_2046 ,
        din(16)          => ex2_recip_2045 ,
        din(17)          => ex2_recip_2044 ,
        din(18)          => ex2_lu_sh      ,
        din(19)          => ex2_recip_ue1  ,
        dout(0 to 12)    => ex3_res_expo(1 to 13)  ,
        dout(13)         => ex3_match_en_dp        ,
        dout(14)         => ex3_match_en_sp        ,
        dout(15)         => ex3_recip_2046         ,
        dout(16)         => ex3_recip_2045         ,
        dout(17)         => ex3_recip_2044         ,
        dout(18)         => ex3_lu_sh              ,
        dout(19)         => ex3_recip_ue1         );





   f_tbe_ex3_match_en_sp <= ex3_match_en_sp       ; 
   f_tbe_ex3_match_en_dp <= ex3_match_en_dp       ; 
   f_tbe_ex3_recip_2046  <= ex3_recip_2046        ; 
   f_tbe_ex3_recip_2045  <= ex3_recip_2045        ; 
   f_tbe_ex3_recip_2044  <= ex3_recip_2044        ; 
   f_tbe_ex3_lu_sh       <= ex3_lu_sh             ; 
   f_tbe_ex3_recip_ue1   <= ex3_recip_ue1         ; 

   ex3_recip_2046_dp <= ex3_recip_2046 and ex3_match_en_dp and not ex3_recip_ue1 ; 
   ex3_recip_2045_dp <= ex3_recip_2045 and ex3_match_en_dp and not ex3_recip_ue1 ; 
   ex3_recip_2044_dp <= ex3_recip_2044 and ex3_match_en_dp and not ex3_recip_ue1 ; 
   ex3_force_expo_den <=  ex3_recip_2046_dp or ex3_recip_2045_dp; 

   ex3_decr_expo <= 
       ( ex3_lu_sh and     ex3_recip_ue1                            ) or
       ( ex3_lu_sh and not ex3_recip_ue1 and not ex3_recip_2046_dp
                                         and not ex3_recip_2045_dp
                                         and not ex3_recip_2044_dp  );



   ex3_res_expo_b(1 to 13) <= not ex3_res_expo(1 to 13);

   ex3_res_expo_g2_b(13) <= not( ex3_res_expo  (13)                         );
   ex3_res_expo_g2_b(12) <= not( ex3_res_expo  (12) or   ex3_res_expo  (13) );
   ex3_res_expo_g2_b(11) <= not( ex3_res_expo  (11) or   ex3_res_expo  (12) );
   ex3_res_expo_g2_b(10) <= not( ex3_res_expo  (10) or   ex3_res_expo  (11) );
   ex3_res_expo_g2_b( 9) <= not( ex3_res_expo  ( 9) or   ex3_res_expo  (10) );
   ex3_res_expo_g2_b( 8) <= not( ex3_res_expo  ( 8) or   ex3_res_expo  ( 9) );
   ex3_res_expo_g2_b( 7) <= not( ex3_res_expo  ( 7) or   ex3_res_expo  ( 8) );
   ex3_res_expo_g2_b( 6) <= not( ex3_res_expo  ( 6) or   ex3_res_expo  ( 7) );
   ex3_res_expo_g2_b( 5) <= not( ex3_res_expo  ( 5) or   ex3_res_expo  ( 6) );
   ex3_res_expo_g2_b( 4) <= not( ex3_res_expo  ( 4) or   ex3_res_expo  ( 5) );
   ex3_res_expo_g2_b( 3) <= not( ex3_res_expo  ( 3) or   ex3_res_expo  ( 4) );
   ex3_res_expo_g2_b( 2) <= not( ex3_res_expo  ( 2) or   ex3_res_expo  ( 3) );

   ex3_res_expo_g4  (13) <= not( ex3_res_expo_g2_b(13)                            );
   ex3_res_expo_g4  (12) <= not( ex3_res_expo_g2_b(12)                            );
   ex3_res_expo_g4  (11) <= not( ex3_res_expo_g2_b(11) and  ex3_res_expo_g2_b(13) );
   ex3_res_expo_g4  (10) <= not( ex3_res_expo_g2_b(10) and  ex3_res_expo_g2_b(12) );
   ex3_res_expo_g4  ( 9) <= not( ex3_res_expo_g2_b( 9) and  ex3_res_expo_g2_b(11) );
   ex3_res_expo_g4  ( 8) <= not( ex3_res_expo_g2_b( 8) and  ex3_res_expo_g2_b(10) );
   ex3_res_expo_g4  ( 7) <= not( ex3_res_expo_g2_b( 7) and  ex3_res_expo_g2_b( 9) );
   ex3_res_expo_g4  ( 6) <= not( ex3_res_expo_g2_b( 6) and  ex3_res_expo_g2_b( 8) );
   ex3_res_expo_g4  ( 5) <= not( ex3_res_expo_g2_b( 5) and  ex3_res_expo_g2_b( 7) );
   ex3_res_expo_g4  ( 4) <= not( ex3_res_expo_g2_b( 4) and  ex3_res_expo_g2_b( 6) );
   ex3_res_expo_g4  ( 3) <= not( ex3_res_expo_g2_b( 3) and  ex3_res_expo_g2_b( 5) );
   ex3_res_expo_g4  ( 2) <= not( ex3_res_expo_g2_b( 2) and  ex3_res_expo_g2_b( 4) );

   ex3_res_expo_g8_b(13) <= not( ex3_res_expo_g4  (13)                            );
   ex3_res_expo_g8_b(12) <= not( ex3_res_expo_g4  (12)                            );
   ex3_res_expo_g8_b(11) <= not( ex3_res_expo_g4  (11)                            );
   ex3_res_expo_g8_b(10) <= not( ex3_res_expo_g4  (10)                            );
   ex3_res_expo_g8_b( 9) <= not( ex3_res_expo_g4  ( 9) or   ex3_res_expo_g4  (13) );
   ex3_res_expo_g8_b( 8) <= not( ex3_res_expo_g4  ( 8) or   ex3_res_expo_g4  (12) );
   ex3_res_expo_g8_b( 7) <= not( ex3_res_expo_g4  ( 7) or   ex3_res_expo_g4  (11) );
   ex3_res_expo_g8_b( 6) <= not( ex3_res_expo_g4  ( 6) or   ex3_res_expo_g4  (10) );
   ex3_res_expo_g8_b( 5) <= not( ex3_res_expo_g4  ( 5) or   ex3_res_expo_g4  ( 9) );
   ex3_res_expo_g8_b( 4) <= not( ex3_res_expo_g4  ( 4) or   ex3_res_expo_g4  ( 8) );
   ex3_res_expo_g8_b( 3) <= not( ex3_res_expo_g4  ( 3) or   ex3_res_expo_g4  ( 7) );
   ex3_res_expo_g8_b( 2) <= not( ex3_res_expo_g4  ( 2) or   ex3_res_expo_g4  ( 6) );

   ex3_res_expo_c   (13) <= not( ex3_res_expo_g8_b(13)                            );
   ex3_res_expo_c   (12) <= not( ex3_res_expo_g8_b(12)                            );
   ex3_res_expo_c   (11) <= not( ex3_res_expo_g8_b(11)                            );
   ex3_res_expo_c   (10) <= not( ex3_res_expo_g8_b(10)                            );
   ex3_res_expo_c   ( 9) <= not( ex3_res_expo_g8_b( 9)                            );
   ex3_res_expo_c   ( 8) <= not( ex3_res_expo_g8_b( 8)                            );
   ex3_res_expo_c   ( 7) <= not( ex3_res_expo_g8_b( 7)                            );
   ex3_res_expo_c   ( 6) <= not( ex3_res_expo_g8_b( 6)                            );
   ex3_res_expo_c   ( 5) <= not( ex3_res_expo_g8_b( 5) and  ex3_res_expo_g8_b(13) );
   ex3_res_expo_c   ( 4) <= not( ex3_res_expo_g8_b( 4) and  ex3_res_expo_g8_b(12) );
   ex3_res_expo_c   ( 3) <= not( ex3_res_expo_g8_b( 3) and  ex3_res_expo_g8_b(11) );
   ex3_res_expo_c   ( 2) <= not( ex3_res_expo_g8_b( 2) and  ex3_res_expo_g8_b(10) );


   ex3_res_decr(1 to 12) <= ex3_res_expo_b(1 to 12) xor ex3_res_expo_c(2 to 13);
   ex3_res_decr(13)      <= ex3_res_expo_b(13) ;


   f_tbe_ex3_res_expo( 1) <= ( ex3_res_expo( 1) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr( 1) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo( 2) <= ( ex3_res_expo( 2) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr( 2) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo( 3) <= ( ex3_res_expo( 3) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr( 3) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo( 4) <= ( ex3_res_expo( 4) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr( 4) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo( 5) <= ( ex3_res_expo( 5) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr( 5) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo( 6) <= ( ex3_res_expo( 6) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr( 6) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo( 7) <= ( ex3_res_expo( 7) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr( 7) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo( 8) <= ( ex3_res_expo( 8) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr( 8) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo( 9) <= ( ex3_res_expo( 9) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr( 9) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo(10) <= ( ex3_res_expo(10) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr(10) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo(11) <= ( ex3_res_expo(11) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr(11) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo(12) <= ( ex3_res_expo(12) and not ex3_decr_expo and not ex3_force_expo_den ) or  
                             ( ex3_res_decr(12) and     ex3_decr_expo                            );
   f_tbe_ex3_res_expo(13) <= ( ex3_res_expo(13) and not ex3_decr_expo                            ) or  
                             ( ex3_res_decr(13) and     ex3_decr_expo                            ) or
                             (                                                ex3_force_expo_den );




  f_tbe_ex3_may_ov <= 
            (not ex3_res_expo(1) and  ex3_res_expo(2)                                         ) or 
            (not ex3_res_expo(1) and  ex3_res_expo(3) and ex3_res_expo(4)                     ) or
            (not ex3_res_expo(1) and  ex3_res_expo(3) and ex3_res_expo(5)                     ) or
            (not ex3_res_expo(1) and  ex3_res_expo(3) and ex3_res_expo(6)                     ) or
            (not ex3_res_expo(1) and  ex3_res_expo(3) and ex3_res_expo(7)                     ) or
            (not ex3_res_expo(1) and  ex3_res_expo(3) and ex3_res_expo(8) and ex3_res_expo(9) );





    ex3_expo_si  (0 to 19)  <= ex3_expo_so  (1 to 19) & si;
    act_si  (0 to 4)        <= act_so  (1 to 4)       & ex3_expo_so  (0);
    so                      <= act_so  (0);


end; 
  





