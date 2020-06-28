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

  


 
ENTITY fuq_sto IS 
generic(
       expand_type               : integer := 2  ); 
PORT( 
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; 
       act_dis                                   :in   std_ulogic; 
       flush                                     :in   std_ulogic; 
       delay_lclkr                               :in   std_ulogic_vector(1 to 2); 
       mpw1_b                                    :in   std_ulogic_vector(1 to 2); 
       mpw2_b                                    :in   std_ulogic_vector(0 to 0); 
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; 
       nclk                                      :in   clk_logic;

       f_sto_si                                  :in   std_ulogic;
       f_sto_so                                  :out  std_ulogic;
       f_dcd_rf1_sto_act                         :in   std_ulogic;
 
       f_fpr_ex1_s_expo_extra                    :in   std_ulogic ;
       f_fpr_ex1_s_par                           :in   std_ulogic_vector(0 to 7)  ;
       f_sto_ex2_s_parity_check                  :out  std_ulogic   ;

       f_dcd_rf1_sto_dp                          :in   std_ulogic                    ;
       f_dcd_rf1_sto_sp                          :in   std_ulogic                    ;
       f_dcd_rf1_sto_wd                          :in   std_ulogic                    ;

       f_byp_rf1_s_sign                          :in   std_ulogic                    ;
       f_byp_rf1_s_expo                          :in   std_ulogic_vector(1 to 11)    ;
       f_byp_rf1_s_frac                          :in   std_ulogic_vector(0 to 52)    ;

       f_sto_ex2_sto_data                        :out  std_ulogic_vector(0 to 63)    

); 
 
 
 
end fuq_sto; 
 
 
architecture fuq_sto of fuq_sto is 
 
    constant tiup  :std_ulogic := '1';
    constant tidn  :std_ulogic := '0';
 
    signal sg_0                                    :std_ulogic                   ;
    signal thold_0_b, thold_0                      :std_ulogic                   ;

    signal rf1_act                                 :std_ulogic                   ;
    signal ex1_act                                 :std_ulogic                   ;
    signal spare_unused                        :std_ulogic_vector(0 to 2)    ;
    signal act_so                                  :std_ulogic_vector(0 to 3)    ;
    signal act_si                                  :std_ulogic_vector(0 to 3)    ;
    signal ex1_sins_so                             :std_ulogic_vector(0 to 2)    ;
    signal ex1_sins_si                             :std_ulogic_vector(0 to 2)    ;
    signal ex1_sop_so                              :std_ulogic_vector(0 to 64)   ;
    signal ex1_sop_si                              :std_ulogic_vector(0 to 64)   ;
    signal ex2_sto_so                              :std_ulogic_vector(0 to 72)   ;
    signal ex2_sto_si                              :std_ulogic_vector(0 to 72)   ;
    signal ex1_s_sign                              :std_ulogic;
    signal ex1_s_expo                              :std_ulogic_vector(1 to 11);
    signal ex1_s_frac                              :std_ulogic_vector(0 to 52);
    signal ex1_sto_data                            :std_ulogic_vector(0 to 63)   ;
    signal ex2_sto_data                            :std_ulogic_vector(0 to 63)   ;
    signal ex1_sto_dp                              :std_ulogic ;
    signal ex1_sto_sp                              :std_ulogic ;
    signal ex1_sto_wd                              :std_ulogic ;
    signal ex1_den_ramt8_02     :std_ulogic;
    signal ex1_den_ramt8_18     :std_ulogic;
    signal ex1_den_ramt4_12     :std_ulogic;
    signal ex1_den_ramt4_08     :std_ulogic;
    signal ex1_den_ramt4_04     :std_ulogic;
    signal ex1_den_ramt4_00     :std_ulogic;
    signal ex1_den_ramt1_03     :std_ulogic;
    signal ex1_den_ramt1_02     :std_ulogic;
    signal ex1_den_ramt1_01     :std_ulogic;
    signal ex1_den_ramt1_00     :std_ulogic;
    signal ex1_expo_eq896       :std_ulogic;
    signal ex1_expo_ge896       :std_ulogic;
    signal ex1_expo_lt896       :std_ulogic;
    signal ex1_sts_lt896        :std_ulogic;
    signal ex1_sts_ge896        :std_ulogic;
    signal ex1_sts_expo_nz      :std_ulogic;
    signal ex1_fixden           :std_ulogic;
    signal ex1_fixden_small     :std_ulogic;
    signal ex1_fixden_big       :std_ulogic;
    signal ex1_std_nonden       :std_ulogic;
    signal ex1_std_fixden_big   :std_ulogic;
    signal ex1_std_fixden_small :std_ulogic;
    signal ex1_std_nonbig       :std_ulogic;
    signal ex1_std_nonden_wd    :std_ulogic;
    signal ex1_std_lamt8_02     :std_ulogic;
    signal ex1_std_lamt8_10     :std_ulogic;
    signal ex1_std_lamt8_18     :std_ulogic;
    signal ex1_std_lamt2_0      :std_ulogic;
    signal ex1_std_lamt2_2      :std_ulogic;
    signal ex1_std_lamt2_4      :std_ulogic;
    signal ex1_std_lamt2_6      :std_ulogic;
    signal ex1_std_lamt1_0      :std_ulogic;
    signal ex1_std_lamt1_1      :std_ulogic;
    signal ex1_sts_sh8          :std_ulogic_vector(0 to 23) ;
    signal ex1_sts_sh4          :std_ulogic_vector(0 to 23) ;
    signal ex1_sts_sh1          :std_ulogic_vector(0 to 23) ;
    signal ex1_sts_nrm          :std_ulogic_vector(0 to 23) ;
    signal ex1_sts_frac         :std_ulogic_vector(1 to 23) ;
    signal ex1_sts_expo         :std_ulogic_vector(1 to 8) ;
    signal ex1_clz02_or         :std_ulogic_vector(0 to 10) ;
    signal ex1_clz02_enc4       :std_ulogic_vector(0 to 10) ;
    signal ex1_clz04_or         :std_ulogic_vector(0 to 5) ;
    signal ex1_clz04_enc3       :std_ulogic_vector(0 to 5) ;
    signal ex1_clz04_enc4       :std_ulogic_vector(0 to 5) ;
    signal ex1_clz08_or         :std_ulogic_vector(0 to 2) ;
    signal ex1_clz08_enc2       :std_ulogic_vector(0 to 2) ;
    signal ex1_clz08_enc3       :std_ulogic_vector(0 to 2) ;
    signal ex1_clz08_enc4       :std_ulogic_vector(0 to 2) ;
    signal ex1_clz16_or         :std_ulogic_vector(0 to 1) ;
    signal ex1_clz16_enc1       :std_ulogic_vector(0 to 1) ;
    signal ex1_clz16_enc2       :std_ulogic_vector(0 to 1) ;
    signal ex1_clz16_enc3       :std_ulogic_vector(0 to 1) ;
    signal ex1_clz16_enc4       :std_ulogic_vector(0 to 1) ;
    signal ex1_sto_clz          :std_ulogic_vector(0 to 4) ;
    signal ex1_expo_nonden      :std_ulogic_vector(1 to 11) ;
    signal ex1_expo_fixden      :std_ulogic_vector(1 to 11) ;
    signal ex1_std_expo         :std_ulogic_vector(1 to 11) ;
    signal ex1_std_frac_nrm     :std_ulogic_vector(1 to 52) ;
    signal ex1_std_sh8          :std_ulogic_vector(0 to 23) ;
    signal ex1_std_sh2          :std_ulogic_vector(0 to 23) ;
    signal ex1_std_frac_den     :std_ulogic_vector(1 to 23) ;
    signal ex1_ge874            :std_ulogic;
    signal ex1_any_edge         :std_ulogic;
   signal ex2_sto_data_rot0_b , ex2_sto_data_rot1_b :std_ulogic_vector(0 to 63);

 signal ex2_sto_wd, ex2_sto_sp :std_ulogic_vector(0 to 3);
  signal forcee :std_ulogic;
  
  
  signal ex1_s_party_chick, ex2_s_party_chick :std_ulogic ;
  signal ex1_s_party : std_ulogic_vector(0 to 7);
  signal unused :std_ulogic;





begin 




   unused <= ex1_sts_sh1(0) or ex1_sts_nrm(0) or ex1_std_sh2(0) ;

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


 
 
    rf1_act <= f_dcd_rf1_sto_act;

    act_lat:  tri_rlmreg_p generic map (width=> 4, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        forcee => forcee,       
        delay_lclkr      => delay_lclkr(1), 
        mpw1_b           => mpw1_b(1),      
        mpw2_b           => mpw2_b(0),      
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0,
        scout            => act_so   ,                     
        scin             => act_si   ,                   
        din(0)           => rf1_act,
        din(1 to 3)      => spare_unused(0 to 2) ,
        dout(0)          => ex1_act ,
        dout(1 to 3)     => spare_unused(0 to 2) );



    ex1_sins_lat:  entity tri.tri_rlmreg_p generic map (width=> 3, expand_type => expand_type,  ibuf => true ) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(1)  ,
        mpw1_b           => mpw1_b(1)       ,
        mpw2_b           => mpw2_b(0)       ,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => rf1_act, 
        vd               => vdd,
        gd               => gnd,
        scout            => ex1_sins_so  ,                      
        scin             => ex1_sins_si  ,                    
        din(0)           => f_dcd_rf1_sto_dp ,
        din(1)           => f_dcd_rf1_sto_sp ,
        din(2)           => f_dcd_rf1_sto_wd ,
        dout(0)           => ex1_sto_dp ,
        dout(1)           => ex1_sto_sp ,
        dout(2)           => ex1_sto_wd );

    ex1_sop_lat:  entity tri.tri_rlmreg_p generic map (width=> 65, expand_type => expand_type, needs_sreset => 0,  ibuf => true) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(1)  ,
        mpw1_b           => mpw1_b(1)       ,
        mpw2_b           => mpw2_b(0)       ,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => rf1_act, 
        vd               => vdd,
        gd               => gnd,
        scout            => ex1_sop_so  ,                      
        scin             => ex1_sop_si  ,                    
        din(0)           => f_byp_rf1_s_sign  ,
        din(1 to 11)     => f_byp_rf1_s_expo(1 to 11) ,
        din(12 to 64)    => f_byp_rf1_s_frac(0 to 52) ,
        dout(0)           => ex1_s_sign ,
        dout(1 to 11)     => ex1_s_expo(1 to 11),
        dout(12 to 64)    => ex1_s_frac(0 to 52) );


 



    ex1_den_ramt8_02 <=     ex1_s_expo(6) and     ex1_s_expo(7);
    ex1_den_ramt8_18 <=     ex1_s_expo(6) and not ex1_s_expo(7);

    ex1_den_ramt4_12 <= not ex1_s_expo(8) and not ex1_s_expo(9);
    ex1_den_ramt4_08 <= not ex1_s_expo(8) and     ex1_s_expo(9);
    ex1_den_ramt4_04 <=     ex1_s_expo(8) and not ex1_s_expo(9);
    ex1_den_ramt4_00 <=     ex1_s_expo(8) and     ex1_s_expo(9);

    ex1_den_ramt1_03 <= not ex1_s_expo(10) and not ex1_s_expo(11);
    ex1_den_ramt1_02 <= not ex1_s_expo(10) and     ex1_s_expo(11);
    ex1_den_ramt1_01 <=     ex1_s_expo(10) and not ex1_s_expo(11);
    ex1_den_ramt1_00 <=     ex1_s_expo(10) and     ex1_s_expo(11);

    ex1_expo_eq896 <= not ex1_s_expo(1)  and 
                          ex1_s_expo(2)  and 
                          ex1_s_expo(3)  and 
                          ex1_s_expo(4)  and 
                      not ex1_s_expo(5)  and 
                      not ex1_s_expo(6)  and 
                      not ex1_s_expo(7)  and 
                      not ex1_s_expo(8)  and 
                      not ex1_s_expo(9)  and 
                      not ex1_s_expo(10) and 
                      not ex1_s_expo(11)   ;

    ex1_expo_ge896 <=
         ( ex1_s_expo(1)                                     ) or
         ( ex1_s_expo(2) and ex1_s_expo(3) and ex1_s_expo(4) ) ;                


    ex1_ge874 <= 
         ( ex1_s_expo(1)                                     ) or
         ( ex1_s_expo(2) and ex1_s_expo(3) and ex1_s_expo(4) ) or
         ( ex1_s_expo(2) and ex1_s_expo(3) and ex1_s_expo(5) and  ex1_s_expo(6) );
         
    
    ex1_expo_lt896 <= not ex1_expo_ge896;
    ex1_sts_lt896  <= ex1_sto_sp and ex1_expo_lt896 and ex1_ge874 ; 
    ex1_sts_ge896  <= ex1_sto_sp and ex1_expo_ge896 ;

    ex1_sts_sh8(0 to 23) <=
          ( (0 to 23 => ex1_den_ramt8_02) and ( (0 to  1 => tidn) & ex1_s_frac(0 to 21) ) ) or 
          ( (0 to 23 => ex1_den_ramt8_18) and ( (0 to 17 => tidn) & ex1_s_frac(0 to  5) ) ) ;

    ex1_sts_sh4(0 to 23) <=
          ( (0 to 23 => ex1_den_ramt4_12) and ( (0 to 11 => tidn) & ex1_sts_sh8(0 to 11) ) ) or 
          ( (0 to 23 => ex1_den_ramt4_08) and ( (0 to  7 => tidn) & ex1_sts_sh8(0 to 15) ) ) or 
          ( (0 to 23 => ex1_den_ramt4_04) and ( (0 to  3 => tidn) & ex1_sts_sh8(0 to 19) ) ) or 
          ( (0 to 23 => ex1_den_ramt4_00) and (                     ex1_sts_sh8(0 to 23) ) ) ;

    ex1_sts_sh1(0 to 23) <=
          ( (0 to 23 => ex1_den_ramt1_03) and ( (0 to  2 => tidn) & ex1_sts_sh4(0 to 20) ) ) or 
          ( (0 to 23 => ex1_den_ramt1_02) and ( (0 to  1 => tidn) & ex1_sts_sh4(0 to 21) ) ) or 
          ( (0 to 23 => ex1_den_ramt1_01) and (             tidn  & ex1_sts_sh4(0 to 22) ) ) or 
          ( (0 to 23 => ex1_den_ramt1_00) and (                     ex1_sts_sh4(0 to 23) ) ) ;

    ex1_sts_nrm(0 to 23) <=
          ( (0 to 23 =>     ex1_expo_eq896) and ( tidn & ex1_s_frac(0 to 22) )  ) or 
          ( (0 to 23 => not ex1_expo_eq896) and (        ex1_s_frac(0 to 23) )  ) ;

    ex1_sts_frac(1 to 23) <=
          ( (1 to 23 => ex1_sts_lt896) and ex1_sts_sh1(1 to 23) ) or 
          ( (1 to 23 => ex1_sts_ge896) and ex1_sts_nrm(1 to 23) ) ;


    ex1_sts_expo_nz <= ex1_sto_sp and  ex1_expo_ge896 ;
    ex1_sts_expo(1)      <= ex1_s_expo(1)       and           ex1_sts_expo_nz ;
    ex1_sts_expo(2 to 7) <= ex1_s_expo(5 to 10) and (2 to 7=> ex1_sts_expo_nz);
    ex1_sts_expo(8)      <= ex1_s_expo(11) and ex1_s_frac(0)      and           ex1_sts_expo_nz ;




    ex1_clz02_or  ( 0) <=     ex1_s_frac( 2) or  ex1_s_frac( 3);
    ex1_clz02_enc4( 0) <= not ex1_s_frac( 2) and ex1_s_frac( 3);
       
    ex1_clz02_or  ( 1) <=     ex1_s_frac( 4) or  ex1_s_frac( 5);
    ex1_clz02_enc4( 1) <= not ex1_s_frac( 4) and ex1_s_frac( 5);
       
    ex1_clz02_or  ( 2) <=     ex1_s_frac( 6) or  ex1_s_frac( 7);
    ex1_clz02_enc4( 2) <= not ex1_s_frac( 6) and ex1_s_frac( 7);
       
    ex1_clz02_or  ( 3) <=     ex1_s_frac( 8) or  ex1_s_frac( 9);
    ex1_clz02_enc4( 3) <= not ex1_s_frac( 8) and ex1_s_frac( 9);
       
    ex1_clz02_or  ( 4) <=     ex1_s_frac(10) or  ex1_s_frac(11);
    ex1_clz02_enc4( 4) <= not ex1_s_frac(10) and ex1_s_frac(11);
       
    ex1_clz02_or  ( 5) <=     ex1_s_frac(12) or  ex1_s_frac(13);
    ex1_clz02_enc4( 5) <= not ex1_s_frac(12) and ex1_s_frac(13);
       
    ex1_clz02_or  ( 6) <=     ex1_s_frac(14) or  ex1_s_frac(15);
    ex1_clz02_enc4( 6) <= not ex1_s_frac(14) and ex1_s_frac(15);
       
    ex1_clz02_or  ( 7) <=     ex1_s_frac(16) or  ex1_s_frac(17);
    ex1_clz02_enc4( 7) <= not ex1_s_frac(16) and ex1_s_frac(17);
       
    ex1_clz02_or  ( 8) <=     ex1_s_frac(18) or  ex1_s_frac(19);
    ex1_clz02_enc4( 8) <= not ex1_s_frac(18) and ex1_s_frac(19);
       
    ex1_clz02_or  ( 9) <=     ex1_s_frac(20) or  ex1_s_frac(21);
    ex1_clz02_enc4( 9) <= not ex1_s_frac(20) and ex1_s_frac(21);
       
    ex1_clz02_or  (10) <=     ex1_s_frac(22) or  ex1_s_frac(23);
    ex1_clz02_enc4(10) <= not ex1_s_frac(22) and ex1_s_frac(23);


    ex1_clz04_or  ( 0) <=                            ex1_clz02_or( 0) or  ex1_clz02_or  ( 1)  ;
    ex1_clz04_enc3( 0) <=                        not ex1_clz02_or( 0) and ex1_clz02_or  ( 1)  ;
    ex1_clz04_enc4( 0) <= ex1_clz02_enc4( 0) or (not ex1_clz02_or( 0) and ex1_clz02_enc4( 1) );

    ex1_clz04_or  ( 1) <=                            ex1_clz02_or( 2) or  ex1_clz02_or  ( 3)  ;
    ex1_clz04_enc3( 1) <=                        not ex1_clz02_or( 2) and ex1_clz02_or  ( 3)  ;
    ex1_clz04_enc4( 1) <= ex1_clz02_enc4( 2) or (not ex1_clz02_or( 2) and ex1_clz02_enc4( 3) );

    ex1_clz04_or  ( 2) <=                            ex1_clz02_or( 4) or  ex1_clz02_or  ( 5)  ;
    ex1_clz04_enc3( 2) <=                        not ex1_clz02_or( 4) and ex1_clz02_or  ( 5)  ;
    ex1_clz04_enc4( 2) <= ex1_clz02_enc4( 4) or (not ex1_clz02_or( 4) and ex1_clz02_enc4( 5) );

    ex1_clz04_or  ( 3) <=                            ex1_clz02_or( 6) or  ex1_clz02_or  ( 7)  ;
    ex1_clz04_enc3( 3) <=                        not ex1_clz02_or( 6) and ex1_clz02_or  ( 7)  ;
    ex1_clz04_enc4( 3) <= ex1_clz02_enc4( 6) or (not ex1_clz02_or( 6) and ex1_clz02_enc4( 7) );

    ex1_clz04_or  ( 4) <=                            ex1_clz02_or( 8) or  ex1_clz02_or  ( 9)  ;
    ex1_clz04_enc3( 4) <=                        not ex1_clz02_or( 8) and ex1_clz02_or  ( 9)  ;
    ex1_clz04_enc4( 4) <= ex1_clz02_enc4( 8) or (not ex1_clz02_or( 8) and ex1_clz02_enc4( 9) );

    ex1_clz04_or  ( 5) <=                            ex1_clz02_or(10) ;
    ex1_clz04_enc3( 5) <= tidn;
    ex1_clz04_enc4( 5) <= ex1_clz02_enc4(10);


    ex1_clz08_or  ( 0) <=                            ex1_clz04_or( 0) or  ex1_clz04_or  ( 1)  ;
    ex1_clz08_enc2( 0) <=                        not ex1_clz04_or( 0) and ex1_clz04_or  ( 1)  ;
    ex1_clz08_enc3( 0) <= ex1_clz04_enc3( 0) or (not ex1_clz04_or( 0) and ex1_clz04_enc3( 1) );
    ex1_clz08_enc4( 0) <= ex1_clz04_enc4( 0) or (not ex1_clz04_or( 0) and ex1_clz04_enc4( 1) );

    ex1_clz08_or  ( 1) <=                            ex1_clz04_or( 2) or  ex1_clz04_or  ( 3)  ;
    ex1_clz08_enc2( 1) <=                        not ex1_clz04_or( 2) and ex1_clz04_or  ( 3)  ;
    ex1_clz08_enc3( 1) <= ex1_clz04_enc3( 2) or (not ex1_clz04_or( 2) and ex1_clz04_enc3( 3) );
    ex1_clz08_enc4( 1) <= ex1_clz04_enc4( 2) or (not ex1_clz04_or( 2) and ex1_clz04_enc4( 3) );

    ex1_clz08_or  ( 2) <=                            ex1_clz04_or( 4) or  ex1_clz04_or  ( 5)  ;
    ex1_clz08_enc2( 2) <=                        not ex1_clz04_or( 4) and ex1_clz04_or  ( 5)  ;
    ex1_clz08_enc3( 2) <= ex1_clz04_enc3( 4) or (not ex1_clz04_or( 4) and ex1_clz04_enc3( 5) );
    ex1_clz08_enc4( 2) <= ex1_clz04_enc4( 4) or (not ex1_clz04_or( 4) and ex1_clz04_enc4( 5) );


    ex1_clz16_or  ( 0) <=                            ex1_clz08_or( 0) or  ex1_clz08_or  ( 1)  ;
    ex1_clz16_enc1( 0) <=                        not ex1_clz08_or( 0) and ex1_clz08_or  ( 1)  ;
    ex1_clz16_enc2( 0) <= ex1_clz08_enc2( 0) or (not ex1_clz08_or( 0) and ex1_clz08_enc2( 1) );
    ex1_clz16_enc3( 0) <= ex1_clz08_enc3( 0) or (not ex1_clz08_or( 0) and ex1_clz08_enc3( 1) );
    ex1_clz16_enc4( 0) <= ex1_clz08_enc4( 0) or (not ex1_clz08_or( 0) and ex1_clz08_enc4( 1) );

    ex1_clz16_or  ( 1) <=                            ex1_clz08_or( 2) ;
    ex1_clz16_enc1( 1) <= tidn;
    ex1_clz16_enc2( 1) <= ex1_clz08_enc2( 2) ;
    ex1_clz16_enc3( 1) <= ex1_clz08_enc3( 2) ;
    ex1_clz16_enc4( 1) <= ex1_clz08_enc4( 2) ;


    ex1_sto_clz( 0) <=                        not ex1_clz16_or( 0) and ex1_clz16_or  ( 1)  ;
    ex1_sto_clz( 1) <= ex1_clz16_enc1( 0) or (not ex1_clz16_or( 0) and ex1_clz16_enc1( 1) );
    ex1_sto_clz( 2) <= ex1_clz16_enc2( 0) or (not ex1_clz16_or( 0) and ex1_clz16_enc2( 1) );
    ex1_sto_clz( 3) <= ex1_clz16_enc3( 0) or (not ex1_clz16_or( 0) and ex1_clz16_enc3( 1) );
    ex1_sto_clz( 4) <= ex1_clz16_enc4( 0) or (not ex1_clz16_or( 0) and ex1_clz16_enc4( 1) );

    ex1_any_edge <= ( ex1_clz16_or( 0) or ex1_clz16_or  ( 1) );
       


  ex1_fixden       <= ex1_s_expo(2) and not ex1_s_frac(0); 
  ex1_fixden_small <= ex1_s_expo(2) and not ex1_s_frac(0) and     ex1_s_frac(1);
  ex1_fixden_big   <= ex1_s_expo(2) and not ex1_s_frac(0) and not ex1_s_frac(1);

  ex1_std_nonden       <= ex1_sto_dp and not ex1_fixden     ; 
  ex1_std_fixden_big   <= ex1_sto_dp and     ex1_fixden_big ;   
  ex1_std_fixden_small <= ex1_sto_dp and     ex1_fixden_small ; 
  ex1_std_nonbig       <= ex1_sto_dp and not ex1_fixden_big;

  ex1_expo_nonden(1 to 10) <= ex1_s_expo(1 to 10) and (1 to 10=> ex1_std_nonbig );
  ex1_expo_nonden(11)      <= ex1_s_expo(11) and ex1_s_frac(0) and ex1_std_nonden ;

  ex1_expo_fixden(1)       <= tidn        ; 
  ex1_expo_fixden(2)       <= ex1_any_edge; 
  ex1_expo_fixden(3)       <= ex1_any_edge; 
  ex1_expo_fixden(4)       <= tidn        ; 
  ex1_expo_fixden(5)       <= ex1_any_edge; 
  ex1_expo_fixden(6)       <= ex1_any_edge; 
  ex1_expo_fixden(7 to 11) <= not ex1_sto_clz(0 to 4) and (0 to 4 => ex1_any_edge) ;

  ex1_std_expo(1 to 11) <=
      ( ex1_expo_nonden(1 to 11)                                      ) or 
      ( ex1_expo_fixden(1 to 11) and (1 to 11=> ex1_std_fixden_big)   );

  
  ex1_std_nonden_wd <= ex1_std_nonden or ex1_sto_wd;

  ex1_std_frac_nrm(1 to 20) <=
        (  ex1_s_frac( 2 to 21)         and ( 1 to 20=> ex1_std_fixden_small) ) or 
        (  ex1_s_frac( 1 to 20)         and ( 1 to 20=> ex1_std_nonden)       ) ;
  ex1_std_frac_nrm(21 to 52) <= 
        ( (ex1_s_frac(22 to 52) & tidn) and  (21 to 52=> ex1_std_fixden_small)  ) or 
        (  ex1_s_frac(21 to 52)         and  (21 to 52=> ex1_std_nonden_wd)     ) ;


  ex1_std_lamt8_02 <= not ex1_sto_clz(0) and not ex1_sto_clz(1) ; 
  ex1_std_lamt8_10 <= not ex1_sto_clz(0) and     ex1_sto_clz(1) ; 
  ex1_std_lamt8_18 <=     ex1_sto_clz(0) and not ex1_sto_clz(1) ; 

  ex1_std_lamt2_0 <= not ex1_sto_clz(2) and not ex1_sto_clz(3) ;
  ex1_std_lamt2_2 <= not ex1_sto_clz(2) and     ex1_sto_clz(3) ;
  ex1_std_lamt2_4 <=     ex1_sto_clz(2) and not ex1_sto_clz(3) ;
  ex1_std_lamt2_6 <=     ex1_sto_clz(2) and     ex1_sto_clz(3) ;

  ex1_std_lamt1_0 <= ex1_std_fixden_big and not ex1_sto_clz(4) ;
  ex1_std_lamt1_1 <= ex1_std_fixden_big and     ex1_sto_clz(4) ;


   ex1_std_sh8(0 to 23) <= 
        ( ( ex1_s_frac( 2 to 23) & (0 to  1=> tidn) ) and (0 to 23=> ex1_std_lamt8_02 ) ) or 
        ( ( ex1_s_frac(10 to 23) & (0 to  9=> tidn) ) and (0 to 23=> ex1_std_lamt8_10 ) ) or 
        ( ( ex1_s_frac(18 to 23) & (0 to 17=> tidn) ) and (0 to 23=> ex1_std_lamt8_18 ) ) ;
  ex1_std_sh2(0 to 23) <= 
        (   ex1_std_sh8(0 to 23)                     and (0 to 23=> ex1_std_lamt2_0) ) or 
        (  (ex1_std_sh8(2 to 23) & (0 to 1=> tidn) ) and (0 to 23=> ex1_std_lamt2_2) ) or 
        (  (ex1_std_sh8(4 to 23) & (0 to 3=> tidn) ) and (0 to 23=> ex1_std_lamt2_4) ) or 
        (  (ex1_std_sh8(6 to 23) & (0 to 5=> tidn) ) and (0 to 23=> ex1_std_lamt2_6) ) ;
  ex1_std_frac_den(1 to 23) <=
        (   ex1_std_sh2(1 to 23)         and (1 to 23=> ex1_std_lamt1_0) ) or 
        (  (ex1_std_sh2(2 to 23) & tidn) and (1 to 23=> ex1_std_lamt1_1) ) ;




  ex1_sto_data(0)        <= ex1_s_sign  and not ex1_sto_wd; 

  ex1_sto_data(1 to 8)   <= ex1_sts_expo(1 to 8)  or
                            ex1_std_expo(1 to 8);

  ex1_sto_data(9 to 11)  <= ex1_sts_frac(1 to 3)  or
                            ex1_std_expo(9 to 11);

  ex1_sto_data(12 to 31) <= ex1_sts_frac(4 to 23)     or
                            ex1_std_frac_nrm(1 to 20) or 
                            ex1_std_frac_den(1 to 20) ;

  ex1_sto_data(32 to 34) <= ex1_std_frac_nrm(21 to 23) or 
                            ex1_std_frac_den(21 to 23) ;

  ex1_sto_data(35 to 63) <= ex1_std_frac_nrm(24 to 52) ; 


  ex2_sto_lat:  entity tri.tri_rlmreg_p  generic map (width=> 73, expand_type => expand_type, needs_sreset => 0,  ibuf => true) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(2)  ,
        mpw1_b           => mpw1_b(2)       ,
        mpw2_b           => mpw2_b(0)       ,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex1_act, 
        vd               => vdd,
        gd               => gnd,
        scout            => ex2_sto_so  ,                      
        scin             => ex2_sto_si  ,                    
        din(0 to 63)     => ex1_sto_data(0 to 63) ,
        din(64)          => ex1_sto_sp ,
        din(65)          => ex1_sto_sp ,
        din(66)          => ex1_sto_sp ,
        din(67)          => ex1_sto_sp ,
        din(68)          => ex1_sto_wd ,
        din(69)          => ex1_sto_wd ,
        din(70)          => ex1_sto_wd ,
        din(71)          => ex1_sto_wd ,
        din(72)          => ex1_s_party_chick ,

        dout(0 to 63)     => ex2_sto_data(0 to 63) ,
        dout(64)          => ex2_sto_sp(0)         ,
        dout(65)          => ex2_sto_sp(1)         ,
        dout(66)          => ex2_sto_sp(2)         ,
        dout(67)          => ex2_sto_sp(3)         ,
        dout(68)          => ex2_sto_wd(0)         ,
        dout(69)          => ex2_sto_wd(1)         ,
        dout(70)          => ex2_sto_wd(2)         ,
        dout(71)          => ex2_sto_wd(3)         ,
        dout(72)          => ex2_s_party_chick    );

   f_sto_ex2_s_parity_check <= ex2_s_party_chick ;





  ex1_s_party(0)  <= ex1_s_sign     xor f_fpr_ex1_s_expo_extra  xor ex1_s_expo(1)  xor ex1_s_expo(2)  xor ex1_s_expo(3)  xor
                     ex1_s_expo(4)  xor ex1_s_expo(5)  xor ex1_s_expo(6)  xor ex1_s_expo(7) ;
  ex1_s_party(1)  <= ex1_s_expo(8)  xor ex1_s_expo(9)  xor ex1_s_expo(10) xor ex1_s_expo(11) xor ex1_s_frac(0) xor
                     ex1_s_frac(1)  xor ex1_s_frac(2)  xor ex1_s_frac(3)  xor ex1_s_frac(4) ;
  ex1_s_party(2)  <= ex1_s_frac(5)  xor ex1_s_frac(6)  xor ex1_s_frac(7)  xor ex1_s_frac(8)  xor
                     ex1_s_frac(9)  xor ex1_s_frac(10) xor ex1_s_frac(11) xor ex1_s_frac(12) ;
  ex1_s_party(3)  <= ex1_s_frac(13) xor ex1_s_frac(14) xor ex1_s_frac(15) xor ex1_s_frac(16) xor
                     ex1_s_frac(17) xor ex1_s_frac(18) xor ex1_s_frac(19) xor ex1_s_frac(20) ;
  ex1_s_party(4)  <= ex1_s_frac(21) xor ex1_s_frac(22) xor ex1_s_frac(23) xor ex1_s_frac(24) xor
                     ex1_s_frac(25) xor ex1_s_frac(26) xor ex1_s_frac(27) xor ex1_s_frac(28) ;
  ex1_s_party(5)  <= ex1_s_frac(29) xor ex1_s_frac(30) xor ex1_s_frac(31) xor ex1_s_frac(32) xor
                     ex1_s_frac(33) xor ex1_s_frac(34) xor ex1_s_frac(35) xor ex1_s_frac(36) ;
  ex1_s_party(6)  <= ex1_s_frac(37) xor ex1_s_frac(38) xor ex1_s_frac(39) xor ex1_s_frac(40) xor
                     ex1_s_frac(41) xor ex1_s_frac(42) xor ex1_s_frac(43) xor ex1_s_frac(44) ;
  ex1_s_party(7)  <= ex1_s_frac(45) xor ex1_s_frac(46) xor ex1_s_frac(47) xor ex1_s_frac(48) xor
                     ex1_s_frac(49) xor ex1_s_frac(50) xor ex1_s_frac(51) xor ex1_s_frac(52) ;


       ex1_s_party_chick <= (ex1_s_party(0) xor f_fpr_ex1_s_par(0) ) or
                            (ex1_s_party(1) xor f_fpr_ex1_s_par(1) ) or
                            (ex1_s_party(2) xor f_fpr_ex1_s_par(2) ) or
                            (ex1_s_party(3) xor f_fpr_ex1_s_par(3) ) or
                            (ex1_s_party(4) xor f_fpr_ex1_s_par(4) ) or
                            (ex1_s_party(5) xor f_fpr_ex1_s_par(5) ) or
                            (ex1_s_party(6) xor f_fpr_ex1_s_par(6) ) or
                            (ex1_s_party(7) xor f_fpr_ex1_s_par(7) ) ;



u_rot0_0:   ex2_sto_data_rot0_b(0)   <= not( ex2_sto_data(0)   and  not ex2_sto_wd(0)  );
u_rot0_1:   ex2_sto_data_rot0_b(1)   <= not( ex2_sto_data(1)   and  not ex2_sto_wd(0)  );
u_rot0_2:   ex2_sto_data_rot0_b(2)   <= not( ex2_sto_data(2)   and  not ex2_sto_wd(0)  );
u_rot0_3:   ex2_sto_data_rot0_b(3)   <= not( ex2_sto_data(3)   and  not ex2_sto_wd(0)  );
u_rot0_4:   ex2_sto_data_rot0_b(4)   <= not( ex2_sto_data(4)   and  not ex2_sto_wd(0)  );
u_rot0_5:   ex2_sto_data_rot0_b(5)   <= not( ex2_sto_data(5)   and  not ex2_sto_wd(0)  );
u_rot0_6:   ex2_sto_data_rot0_b(6)   <= not( ex2_sto_data(6)   and  not ex2_sto_wd(0)  );
u_rot0_7:   ex2_sto_data_rot0_b(7)   <= not( ex2_sto_data(7)   and  not ex2_sto_wd(0)  );
u_rot0_8:   ex2_sto_data_rot0_b(8)   <= not( ex2_sto_data(8)   and  not ex2_sto_wd(1)  );
u_rot0_9:   ex2_sto_data_rot0_b(9)   <= not( ex2_sto_data(9)   and  not ex2_sto_wd(1)  );
u_rot0_10:  ex2_sto_data_rot0_b(10)  <= not( ex2_sto_data(10)  and  not ex2_sto_wd(1)  );
u_rot0_11:  ex2_sto_data_rot0_b(11)  <= not( ex2_sto_data(11)  and  not ex2_sto_wd(1)  );
u_rot0_12:  ex2_sto_data_rot0_b(12)  <= not( ex2_sto_data(12)  and  not ex2_sto_wd(1)  );
u_rot0_13:  ex2_sto_data_rot0_b(13)  <= not( ex2_sto_data(13)  and  not ex2_sto_wd(1)  );
u_rot0_14:  ex2_sto_data_rot0_b(14)  <= not( ex2_sto_data(14)  and  not ex2_sto_wd(1)  );
u_rot0_15:  ex2_sto_data_rot0_b(15)  <= not( ex2_sto_data(15)  and  not ex2_sto_wd(1)  );
u_rot0_16:  ex2_sto_data_rot0_b(16)  <= not( ex2_sto_data(16)  and  not ex2_sto_wd(2)  );
u_rot0_17:  ex2_sto_data_rot0_b(17)  <= not( ex2_sto_data(17)  and  not ex2_sto_wd(2)  );
u_rot0_18:  ex2_sto_data_rot0_b(18)  <= not( ex2_sto_data(18)  and  not ex2_sto_wd(2)  );
u_rot0_19:  ex2_sto_data_rot0_b(19)  <= not( ex2_sto_data(19)  and  not ex2_sto_wd(2)  );
u_rot0_20:  ex2_sto_data_rot0_b(20)  <= not( ex2_sto_data(20)  and  not ex2_sto_wd(2)  );
u_rot0_21:  ex2_sto_data_rot0_b(21)  <= not( ex2_sto_data(21)  and  not ex2_sto_wd(2)  );
u_rot0_22:  ex2_sto_data_rot0_b(22)  <= not( ex2_sto_data(22)  and  not ex2_sto_wd(2)  );
u_rot0_23:  ex2_sto_data_rot0_b(23)  <= not( ex2_sto_data(23)  and  not ex2_sto_wd(2)  );
u_rot0_24:  ex2_sto_data_rot0_b(24)  <= not( ex2_sto_data(24)  and  not ex2_sto_wd(3)  );
u_rot0_25:  ex2_sto_data_rot0_b(25)  <= not( ex2_sto_data(25)  and  not ex2_sto_wd(3)  );
u_rot0_26:  ex2_sto_data_rot0_b(26)  <= not( ex2_sto_data(26)  and  not ex2_sto_wd(3)  );
u_rot0_27:  ex2_sto_data_rot0_b(27)  <= not( ex2_sto_data(27)  and  not ex2_sto_wd(3)  );
u_rot0_28:  ex2_sto_data_rot0_b(28)  <= not( ex2_sto_data(28)  and  not ex2_sto_wd(3)  );
u_rot0_29:  ex2_sto_data_rot0_b(29)  <= not( ex2_sto_data(29)  and  not ex2_sto_wd(3)  );
u_rot0_30:  ex2_sto_data_rot0_b(30)  <= not( ex2_sto_data(30)  and  not ex2_sto_wd(3)  );
u_rot0_31:  ex2_sto_data_rot0_b(31)  <= not( ex2_sto_data(31)  and  not ex2_sto_wd(3)  );
u_rot0_32:  ex2_sto_data_rot0_b(32)  <= not( ex2_sto_data(0)   and      ex2_sto_sp(0)  );
u_rot0_33:  ex2_sto_data_rot0_b(33)  <= not( ex2_sto_data(1)   and      ex2_sto_sp(0)  );
u_rot0_34:  ex2_sto_data_rot0_b(34)  <= not( ex2_sto_data(2)   and      ex2_sto_sp(0)  );
u_rot0_35:  ex2_sto_data_rot0_b(35)  <= not( ex2_sto_data(3)   and      ex2_sto_sp(0)  );
u_rot0_36:  ex2_sto_data_rot0_b(36)  <= not( ex2_sto_data(4)   and      ex2_sto_sp(0)  );
u_rot0_37:  ex2_sto_data_rot0_b(37)  <= not( ex2_sto_data(5)   and      ex2_sto_sp(0)  );
u_rot0_38:  ex2_sto_data_rot0_b(38)  <= not( ex2_sto_data(6)   and      ex2_sto_sp(0)  );
u_rot0_39:  ex2_sto_data_rot0_b(39)  <= not( ex2_sto_data(7)   and      ex2_sto_sp(0)  );
u_rot0_40:  ex2_sto_data_rot0_b(40)  <= not( ex2_sto_data(8)   and      ex2_sto_sp(1)  );
u_rot0_41:  ex2_sto_data_rot0_b(41)  <= not( ex2_sto_data(9)   and      ex2_sto_sp(1)  );
u_rot0_42:  ex2_sto_data_rot0_b(42)  <= not( ex2_sto_data(10)  and      ex2_sto_sp(1)  );
u_rot0_43:  ex2_sto_data_rot0_b(43)  <= not( ex2_sto_data(11)  and      ex2_sto_sp(1)  );
u_rot0_44:  ex2_sto_data_rot0_b(44)  <= not( ex2_sto_data(12)  and      ex2_sto_sp(1)  );
u_rot0_45:  ex2_sto_data_rot0_b(45)  <= not( ex2_sto_data(13)  and      ex2_sto_sp(1)  );
u_rot0_46:  ex2_sto_data_rot0_b(46)  <= not( ex2_sto_data(14)  and      ex2_sto_sp(1)  );
u_rot0_47:  ex2_sto_data_rot0_b(47)  <= not( ex2_sto_data(15)  and      ex2_sto_sp(1)  );
u_rot0_48:  ex2_sto_data_rot0_b(48)  <= not( ex2_sto_data(16)  and      ex2_sto_sp(2)  );
u_rot0_49:  ex2_sto_data_rot0_b(49)  <= not( ex2_sto_data(17)  and      ex2_sto_sp(2)  );
u_rot0_50:  ex2_sto_data_rot0_b(50)  <= not( ex2_sto_data(18)  and      ex2_sto_sp(2)  );
u_rot0_51:  ex2_sto_data_rot0_b(51)  <= not( ex2_sto_data(19)  and      ex2_sto_sp(2)  );
u_rot0_52:  ex2_sto_data_rot0_b(52)  <= not( ex2_sto_data(20)  and      ex2_sto_sp(2)  );
u_rot0_53:  ex2_sto_data_rot0_b(53)  <= not( ex2_sto_data(21)  and      ex2_sto_sp(2)  );
u_rot0_54:  ex2_sto_data_rot0_b(54)  <= not( ex2_sto_data(22)  and      ex2_sto_sp(2)  );
u_rot0_55:  ex2_sto_data_rot0_b(55)  <= not( ex2_sto_data(23)  and      ex2_sto_sp(2)  );
u_rot0_56:  ex2_sto_data_rot0_b(56)  <= not( ex2_sto_data(24)  and      ex2_sto_sp(3)  );
u_rot0_57:  ex2_sto_data_rot0_b(57)  <= not( ex2_sto_data(25)  and      ex2_sto_sp(3)  );
u_rot0_58:  ex2_sto_data_rot0_b(58)  <= not( ex2_sto_data(26)  and      ex2_sto_sp(3)  );
u_rot0_59:  ex2_sto_data_rot0_b(59)  <= not( ex2_sto_data(27)  and      ex2_sto_sp(3)  );
u_rot0_60:  ex2_sto_data_rot0_b(60)  <= not( ex2_sto_data(28)  and      ex2_sto_sp(3)  );
u_rot0_61:  ex2_sto_data_rot0_b(61)  <= not( ex2_sto_data(29)  and      ex2_sto_sp(3)  );
u_rot0_62:  ex2_sto_data_rot0_b(62)  <= not( ex2_sto_data(30)  and      ex2_sto_sp(3)  );
u_rot0_63:  ex2_sto_data_rot0_b(63)  <= not( ex2_sto_data(31)  and      ex2_sto_sp(3)  );


u_rot1_0:   ex2_sto_data_rot1_b(0)   <= not( ex2_sto_data(32)  and      ex2_sto_wd(0)  );
u_rot1_1:   ex2_sto_data_rot1_b(1)   <= not( ex2_sto_data(33)  and      ex2_sto_wd(0)  );
u_rot1_2:   ex2_sto_data_rot1_b(2)   <= not( ex2_sto_data(34)  and      ex2_sto_wd(0)  );
u_rot1_3:   ex2_sto_data_rot1_b(3)   <= not( ex2_sto_data(35)  and      ex2_sto_wd(0)  );
u_rot1_4:   ex2_sto_data_rot1_b(4)   <= not( ex2_sto_data(36)  and      ex2_sto_wd(0)  );
u_rot1_5:   ex2_sto_data_rot1_b(5)   <= not( ex2_sto_data(37)  and      ex2_sto_wd(0)  );
u_rot1_6:   ex2_sto_data_rot1_b(6)   <= not( ex2_sto_data(38)  and      ex2_sto_wd(0)  );
u_rot1_7:   ex2_sto_data_rot1_b(7)   <= not( ex2_sto_data(39)  and      ex2_sto_wd(0)  );
u_rot1_8:   ex2_sto_data_rot1_b(8)   <= not( ex2_sto_data(40)  and      ex2_sto_wd(1)  );
u_rot1_9:   ex2_sto_data_rot1_b(9)   <= not( ex2_sto_data(41)  and      ex2_sto_wd(1)  );
u_rot1_10:  ex2_sto_data_rot1_b(10)  <= not( ex2_sto_data(42)  and      ex2_sto_wd(1)  );
u_rot1_11:  ex2_sto_data_rot1_b(11)  <= not( ex2_sto_data(43)  and      ex2_sto_wd(1)  );
u_rot1_12:  ex2_sto_data_rot1_b(12)  <= not( ex2_sto_data(44)  and      ex2_sto_wd(1)  );
u_rot1_13:  ex2_sto_data_rot1_b(13)  <= not( ex2_sto_data(45)  and      ex2_sto_wd(1)  );
u_rot1_14:  ex2_sto_data_rot1_b(14)  <= not( ex2_sto_data(46)  and      ex2_sto_wd(1)  );
u_rot1_15:  ex2_sto_data_rot1_b(15)  <= not( ex2_sto_data(47)  and      ex2_sto_wd(1)  );
u_rot1_16:  ex2_sto_data_rot1_b(16)  <= not( ex2_sto_data(48)  and      ex2_sto_wd(2)  );
u_rot1_17:  ex2_sto_data_rot1_b(17)  <= not( ex2_sto_data(49)  and      ex2_sto_wd(2)  );
u_rot1_18:  ex2_sto_data_rot1_b(18)  <= not( ex2_sto_data(50)  and      ex2_sto_wd(2)  );
u_rot1_19:  ex2_sto_data_rot1_b(19)  <= not( ex2_sto_data(51)  and      ex2_sto_wd(2)  );
u_rot1_20:  ex2_sto_data_rot1_b(20)  <= not( ex2_sto_data(52)  and      ex2_sto_wd(2)  );
u_rot1_21:  ex2_sto_data_rot1_b(21)  <= not( ex2_sto_data(53)  and      ex2_sto_wd(2)  );
u_rot1_22:  ex2_sto_data_rot1_b(22)  <= not( ex2_sto_data(54)  and      ex2_sto_wd(2)  );
u_rot1_23:  ex2_sto_data_rot1_b(23)  <= not( ex2_sto_data(55)  and      ex2_sto_wd(2)  );
u_rot1_24:  ex2_sto_data_rot1_b(24)  <= not( ex2_sto_data(56)  and      ex2_sto_wd(3)  );
u_rot1_25:  ex2_sto_data_rot1_b(25)  <= not( ex2_sto_data(57)  and      ex2_sto_wd(3)  );
u_rot1_26:  ex2_sto_data_rot1_b(26)  <= not( ex2_sto_data(58)  and      ex2_sto_wd(3)  );
u_rot1_27:  ex2_sto_data_rot1_b(27)  <= not( ex2_sto_data(59)  and      ex2_sto_wd(3)  );
u_rot1_28:  ex2_sto_data_rot1_b(28)  <= not( ex2_sto_data(60)  and      ex2_sto_wd(3)  );
u_rot1_29:  ex2_sto_data_rot1_b(29)  <= not( ex2_sto_data(61)  and      ex2_sto_wd(3)  );
u_rot1_30:  ex2_sto_data_rot1_b(30)  <= not( ex2_sto_data(62)  and      ex2_sto_wd(3)  );
u_rot1_31:  ex2_sto_data_rot1_b(31)  <= not( ex2_sto_data(63)  and      ex2_sto_wd(3)  );
u_rot1_32:  ex2_sto_data_rot1_b(32)  <= not( ex2_sto_data(32)  and  not ex2_sto_sp(0)  );
u_rot1_33:  ex2_sto_data_rot1_b(33)  <= not( ex2_sto_data(33)  and  not ex2_sto_sp(0)  );
u_rot1_34:  ex2_sto_data_rot1_b(34)  <= not( ex2_sto_data(34)  and  not ex2_sto_sp(0)  );
u_rot1_35:  ex2_sto_data_rot1_b(35)  <= not( ex2_sto_data(35)  and  not ex2_sto_sp(0)  );
u_rot1_36:  ex2_sto_data_rot1_b(36)  <= not( ex2_sto_data(36)  and  not ex2_sto_sp(0)  );
u_rot1_37:  ex2_sto_data_rot1_b(37)  <= not( ex2_sto_data(37)  and  not ex2_sto_sp(0)  );
u_rot1_38:  ex2_sto_data_rot1_b(38)  <= not( ex2_sto_data(38)  and  not ex2_sto_sp(0)  );
u_rot1_39:  ex2_sto_data_rot1_b(39)  <= not( ex2_sto_data(39)  and  not ex2_sto_sp(0)  );
u_rot1_40:  ex2_sto_data_rot1_b(40)  <= not( ex2_sto_data(40)  and  not ex2_sto_sp(1)  );
u_rot1_41:  ex2_sto_data_rot1_b(41)  <= not( ex2_sto_data(41)  and  not ex2_sto_sp(1)  );
u_rot1_42:  ex2_sto_data_rot1_b(42)  <= not( ex2_sto_data(42)  and  not ex2_sto_sp(1)  );
u_rot1_43:  ex2_sto_data_rot1_b(43)  <= not( ex2_sto_data(43)  and  not ex2_sto_sp(1)  );
u_rot1_44:  ex2_sto_data_rot1_b(44)  <= not( ex2_sto_data(44)  and  not ex2_sto_sp(1)  );
u_rot1_45:  ex2_sto_data_rot1_b(45)  <= not( ex2_sto_data(45)  and  not ex2_sto_sp(1)  );
u_rot1_46:  ex2_sto_data_rot1_b(46)  <= not( ex2_sto_data(46)  and  not ex2_sto_sp(1)  );
u_rot1_47:  ex2_sto_data_rot1_b(47)  <= not( ex2_sto_data(47)  and  not ex2_sto_sp(1)  );
u_rot1_48:  ex2_sto_data_rot1_b(48)  <= not( ex2_sto_data(48)  and  not ex2_sto_sp(2)  );
u_rot1_49:  ex2_sto_data_rot1_b(49)  <= not( ex2_sto_data(49)  and  not ex2_sto_sp(2)  );
u_rot1_50:  ex2_sto_data_rot1_b(50)  <= not( ex2_sto_data(50)  and  not ex2_sto_sp(2)  );
u_rot1_51:  ex2_sto_data_rot1_b(51)  <= not( ex2_sto_data(51)  and  not ex2_sto_sp(2)  );
u_rot1_52:  ex2_sto_data_rot1_b(52)  <= not( ex2_sto_data(52)  and  not ex2_sto_sp(2)  );
u_rot1_53:  ex2_sto_data_rot1_b(53)  <= not( ex2_sto_data(53)  and  not ex2_sto_sp(2)  );
u_rot1_54:  ex2_sto_data_rot1_b(54)  <= not( ex2_sto_data(54)  and  not ex2_sto_sp(2)  );
u_rot1_55:  ex2_sto_data_rot1_b(55)  <= not( ex2_sto_data(55)  and  not ex2_sto_sp(2)  );
u_rot1_56:  ex2_sto_data_rot1_b(56)  <= not( ex2_sto_data(56)  and  not ex2_sto_sp(3)  );
u_rot1_57:  ex2_sto_data_rot1_b(57)  <= not( ex2_sto_data(57)  and  not ex2_sto_sp(3)  );
u_rot1_58:  ex2_sto_data_rot1_b(58)  <= not( ex2_sto_data(58)  and  not ex2_sto_sp(3)  );
u_rot1_59:  ex2_sto_data_rot1_b(59)  <= not( ex2_sto_data(59)  and  not ex2_sto_sp(3)  );
u_rot1_60:  ex2_sto_data_rot1_b(60)  <= not( ex2_sto_data(60)  and  not ex2_sto_sp(3)  );
u_rot1_61:  ex2_sto_data_rot1_b(61)  <= not( ex2_sto_data(61)  and  not ex2_sto_sp(3)  );
u_rot1_62:  ex2_sto_data_rot1_b(62)  <= not( ex2_sto_data(62)  and  not ex2_sto_sp(3)  );
u_rot1_63:  ex2_sto_data_rot1_b(63)  <= not( ex2_sto_data(63)  and  not ex2_sto_sp(3)  );


u_rot: f_sto_ex2_sto_data(0 to 63) <= not( ex2_sto_data_rot0_b(0 to 63) and ex2_sto_data_rot1_b(0 to 63) );





    ex1_sins_si (0 to 2)   <= ex1_sins_so (1 to 2)   & f_sto_si ;
    ex1_sop_si  (0 to 64)  <= ex1_sop_so  (1 to 64)  & ex1_sins_so (0) ;
    ex2_sto_si  (0 to 72)  <= ex2_sto_so  (1 to 72)  & ex1_sop_so  (0) ;
    act_si      (0 to 3 )  <= act_so      ( 1 to 3)  & ex2_sto_so  (0);
    f_sto_so               <= act_so  (0) ; 


end; 
  



