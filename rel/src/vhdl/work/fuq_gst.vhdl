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




--==##########################################################################
--==###  FUQ_GST.VHDL                                                #########
--==###  side pipe for graphics estimates                            #########
--==###  flogefp, fexptefp                                           #########
--==###                                                              #########
--==##########################################################################

library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 


entity fuq_gst is
  
generic ( 
        expand_type : integer  := 2 );-- 0 = ibm, 1 = non-ibm
port (
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic_vector(2 to 5); -- tidn,
       mpw1_b                                    :in   std_ulogic_vector(2 to 5); -- tidn,
       mpw2_b                                    :in   std_ulogic_vector(0 to 1); -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;
        ----------------------------------------------------------------------------
        f_gst_si                   :in  std_ulogic; --perv  scan
        f_gst_so                   :out std_ulogic; --perv  scan
        rf1_act                    :in  std_ulogic; 
        ----------------------------------------------------------------------------
        f_fmt_ex1_b_sign_gst       :in std_ulogic;
        f_fmt_ex1_b_expo_gst_b     :in std_ulogic_vector(01 to 13); 
        f_fmt_ex1_b_frac_gst       :in std_ulogic_vector(01 to 19);        
        ----------------------------------------------------------------------------
        f_pic_ex1_floges           :in  std_ulogic;      
        f_pic_ex1_fexptes          :in  std_ulogic;        
        ----------------------------------------------------------------------------
        f_gst_ex5_logexp_v         :out std_ulogic;  
        f_gst_ex5_logexp_sign      :out std_ulogic;                   -- needs to be right off of a latch
        f_gst_ex5_logexp_exp       :out std_ulogic_vector(01 to 11);  -- needs to be right off of a latch
        f_gst_ex5_logexp_fract     :out std_ulogic_vector(00 to 19)   -- needs to be right off of a latch
);      ----------------------------------------------------------------------------





  
end fuq_gst;

--==################################################
architecture fuq_gst of fuq_gst is

constant tiup : std_ulogic := '1';
constant tidn : std_ulogic := '0';
    
signal sg_0       :std_ulogic;
signal thold_0_b , thold_0, forcee    :std_ulogic;

------------------------------------------------------------------------



signal ex2_gst_ctrl_lat_scout  :std_ulogic_vector(0 to 1);                    
signal ex2_gst_ctrl_lat_scin   :std_ulogic_vector(0 to 1);
signal ex3_gst_ctrl_lat_scout  :std_ulogic_vector(0 to 1);                    
signal ex3_gst_ctrl_lat_scin   :std_ulogic_vector(0 to 1);
signal ex4_gst_ctrl_lat_scout  :std_ulogic_vector(0 to 3);                    
signal ex4_gst_ctrl_lat_scin   :std_ulogic_vector(0 to 3);
signal ex5_gst_ctrl_lat_scout  :std_ulogic_vector(0 to 1);                    
signal ex5_gst_ctrl_lat_scin   :std_ulogic_vector(0 to 1);
signal ex2_gst_stage_lat_scout  :std_ulogic_vector(0 to 32);                    
signal ex2_gst_stage_lat_scin   :std_ulogic_vector(0 to 32);  
signal ex3_gst_stage_lat_scout  :std_ulogic_vector(0 to 19);                    
signal ex3_gst_stage_lat_scin   :std_ulogic_vector(0 to 19);  
signal ex4_gst_stage_lat_scout  :std_ulogic_vector(0 to 23);                    
signal ex4_gst_stage_lat_scin   :std_ulogic_vector(0 to 23);  
signal ex5_gst_stage_lat_scout  :std_ulogic_vector(0 to 31);                    
signal ex5_gst_stage_lat_scin   :std_ulogic_vector(0 to 31);

signal ex4_log_dp_bias  :std_ulogic_vector(1 to 11);
signal ex4_logof1_specialcase    : std_ulogic;
signal ex3_logof1_specialcase    : std_ulogic;

signal ex4_signbit_din, ex5_signbit : std_ulogic;
signal ex4_log_signbit : std_ulogic;

signal f1, f2, f3, f4, f5             : std_ulogic;
signal f6, f7, f8, f9, f10            : std_ulogic;
signal s1, s2, s3                     : std_ulogic;
signal c4, c5, c6, c7                 : std_ulogic;
signal a4, a5, a6                     : std_ulogic;
signal a7, a8, a9, a10, a11           : std_ulogic;

signal ex2_f  :std_ulogic_vector(1 to 11);
signal ex2_a  :std_ulogic_vector(4 to 11);
signal ex2_c  :std_ulogic_vector(4 to 11);

signal ex2_log_fsum  :std_ulogic_vector(4 to 7) ;
signal ex2_log_fcarryin  :std_ulogic_vector(3 to 6);

signal ex2_b_sign  :std_ulogic ;
signal ex2_b_biased_13exp  :std_ulogic_vector(1 to 13);
signal ex2_b_biased_11exp  :std_ulogic_vector(1 to 11);

signal ex2_b_ubexp_sum  :std_ulogic_vector(1 to 11);
signal ex2_b_ubexp_cout  :std_ulogic_vector(2 to 11);
signal ex2_b_ubexp       :std_ulogic_vector(1 to 11);

signal ex2_b_fract  :std_ulogic_vector(1 to 19);
        
signal         f_fmt_ex1_b_expo_gst  :std_ulogic_vector(1 to 13); 
        
signal ex1_floges      : std_ulogic;
signal ex1_fexptes      : std_ulogic;
signal ex2_floges      : std_ulogic;
signal ex2_fexptes      : std_ulogic;
signal ex3_floges      : std_ulogic;
signal ex3_fexptes      : std_ulogic;
signal ex4_floges      : std_ulogic;
signal ex4_fexptes      : std_ulogic;
signal ex5_floges      : std_ulogic;
signal ex5_fexptes      : std_ulogic;

signal ex2_log_a_addend_b, ex2_log_b_addend_b  :std_ulogic_vector(1 to 11);

signal ex3_mantissa, ex4_mantissa, ex3_mantissa_precomp,ex3_mantissa_precomp_b :std_ulogic_vector(1 to 19);
signal ex2_log_mantissa_precomp, ex3_mantissa_neg, ex2_mantissa_din  :std_ulogic_vector(1 to 19);
signal ex2_shamt,ex3_shamt, ex4_shamt :std_ulogic_vector(0 to 4);
signal ex3_negate,ex4_negate, ex3_b_sign      : std_ulogic;

signal ex2_mantissa_shlev0  :std_ulogic_vector(00 to 19);
signal ex2_mantissa_shlev1  :std_ulogic_vector(00 to 22);  -- 0 to 3
signal ex2_mantissa_shlev2  :std_ulogic_vector(00 to 34);  -- 0 to 12
signal ex2_mantissa_shlev3  :std_ulogic_vector(00 to 50);  -- 0 to 16

signal ex2_pow_int  :std_ulogic_vector(1 to 8) ;                                
signal ex2_pow_frac  :std_ulogic_vector(1 to 11) ;



signal ex4_mantissa_shlev0  :std_ulogic_vector(01 to 19);
signal ex4_mantissa_shlev1  :std_ulogic_vector(01 to 22);  -- 0 to 3
signal ex4_mantissa_shlev2  :std_ulogic_vector(01 to 34);  -- 0 to 12
signal ex4_mantissa_shlev3  :std_ulogic_vector(01 to 50);  -- 0 to 16

signal ex4_exponent_a_addend_b :std_ulogic_vector(01 to 11);
signal ex4_exponent_b_addend_b :std_ulogic_vector(01 to 11);

signal ex4_log_a_addend_b :std_ulogic_vector(01 to 11);
signal ex4_log_b_addend_b :std_ulogic_vector(01 to 11);
signal ex4_pow_a_addend_b :std_ulogic_vector(01 to 11);
signal ex4_pow_b_addend_b :std_ulogic_vector(01 to 11);

signal ex4_biased_exponent_result :std_ulogic_vector(01 to 11);
signal ex5_biased_exponent_result :std_ulogic_vector(01 to 11);

signal ex4_log_mantissa_postsh         :std_ulogic_vector(01 to 19);
signal ex4_log_fract       :std_ulogic_vector(01 to 19);
signal ex4_pow_fract, ex4_pow_fract_b        :std_ulogic_vector(01 to 11);
signal ex4_fract_din         :std_ulogic_vector(00 to 19);
signal ex5_fract         :std_ulogic_vector(00 to 19);

signal l1_enc00, l1_enc01, l1_enc10, l1_enc11  :std_ulogic;
signal l2_enc00, l2_enc01, l2_enc10, l2_enc11  :std_ulogic;
signal l3_enc00, l3_enc01    :std_ulogic;
signal l1_e00, l1_e01, l1_e10, l1_e11  :std_ulogic;
signal l2_e00, l2_e01, l2_e10, l2_e11  :std_ulogic;
signal l3_e00, l3_e01    :std_ulogic;


signal ex4_f,ex4_f_b        :std_ulogic_vector(01 to 11);
 
------------------------------------------------------------------------
signal   eb1, eb2, eb3, eb4, eb5, eb6, eb7, eb8, eb9, eb10 : std_ulogic; 

signal   ea4, ea5, ea6, ea7, ea8, ea9, ea10, ea11                 : std_ulogic;
signal   ec4, ec5, ec6, ec7                                       : std_ulogic;
signal   es1, es2, es3                                            : std_ulogic;
signal   ex4_ea, ex4_ec                                  : std_ulogic_vector(4 to 11);


signal ex4_addend1, ex4_addend2, ex4_addend3     : std_ulogic_vector(1 to 11);
signal ex4_fsum    : std_ulogic_vector(1 to 11);
signal ex4_fcarryin  : std_ulogic_vector(1 to 11);
signal ex4_powf_a_addend_b    : std_ulogic_vector(1 to 11);
signal ex4_powf_b_addend_b    : std_ulogic_vector(1 to 11);

signal zeros :std_ulogic_vector(01 to 16);
signal ex2_powsh_no_sat_lft, ex2_powsh_no_sat_rgt :std_ulogic ;

signal ex1_act, ex2_act, ex3_act, ex4_act :std_ulogic;
signal act_so, act_si :std_ulogic_vector(0 to 7);
signal act_spare_unused :std_ulogic_vector(0 to 3);
signal unused :std_ulogic;
signal ex2_ube_g2_b , ex2_ube_g4, ex2_ube_g8_b :std_ulogic_vector(2 to 11) ;



signal s2_0, s2_1, s3_0, s3_1, sx :std_ulogic;
signal s7_if_s1, s7_if_s20, s7_if_s30, s7_if_sx, s7_if_s31, s7_if_s21 :std_ulogic;
signal c6_if_s1, c6_if_s20, c6_if_s30, c6_if_sx, c6_if_s31, c6_if_s21 :std_ulogic;

signal s6_if_s1, s6_if_s20, s6_if_s30, s6_if_sx, s6_if_s31, s6_if_s21 :std_ulogic;
signal c5_if_s1, c5_if_s20, c5_if_s30, c5_if_sx, c5_if_s31, c5_if_s21 :std_ulogic;

signal s5_if_s1, s5_if_s20, s5_if_s30, s5_if_sx, s5_if_s31, s5_if_s21 :std_ulogic;
signal c4_if_s1, c4_if_s20, c4_if_s30, c4_if_sx, c4_if_s31, c4_if_s21 :std_ulogic;

signal s4_if_s1, s4_if_s20, s4_if_s30, s4_if_sx, s4_if_s31, s4_if_s21 :std_ulogic;
signal c3_if_s1, c3_if_s20, c3_if_s30, c3_if_sx, c3_if_s31, c3_if_s21 :std_ulogic;

signal es4_if_s1, es4_if_s20, es4_if_s30, es4_if_sx, es4_if_s31, es4_if_s21 :std_ulogic;
signal ec3_if_s1, ec3_if_s20, ec3_if_s30, ec3_if_sx, ec3_if_s31, ec3_if_s21 :std_ulogic;

signal es5_if_s1, es5_if_s20, es5_if_s30, es5_if_sx, es5_if_s31, es5_if_s21 :std_ulogic;
signal ec4_if_s1, ec4_if_s20, ec4_if_s30, ec4_if_sx, ec4_if_s31, ec4_if_s21 :std_ulogic;

signal es6_if_s1, es6_if_s20, es6_if_s30, es6_if_sx, es6_if_s31, es6_if_s21 :std_ulogic;
signal ec5_if_s1, ec5_if_s20, ec5_if_s30, ec5_if_sx, ec5_if_s31, ec5_if_s21 :std_ulogic;

signal es7_if_s1, es7_if_s20, es7_if_s30, es7_if_sx, es7_if_s31, es7_if_s21 :std_ulogic;
signal ec6_if_s1, ec6_if_s20, ec6_if_s30, ec6_if_sx, ec6_if_s31, ec6_if_s21 :std_ulogic;

   signal es2_0, es2_1, esx, es3_0, es3_1 :std_ulogic ;




begin
--==##########################################
--# pervasive
--==##########################################


unused <= ex2_b_biased_13exp(1) or ex2_b_biased_13exp(2) or 
          ex2_b_ubexp(2) or ex2_b_ubexp(3) or
          ex2_mantissa_shlev3(0) or 
          ex2_mantissa_shlev3(1) or 
          ex2_mantissa_shlev3(2) or 
          ex2_mantissa_shlev3(3) or 
          ex2_mantissa_shlev3(4) or 
          ex2_mantissa_shlev3(5) or 
          ex2_mantissa_shlev3(6) or 
          ex2_mantissa_shlev3(7) or 
          ex2_mantissa_shlev3(27) or 
          ex2_mantissa_shlev3(28) or 
          ex2_mantissa_shlev3(29) or 
          ex2_mantissa_shlev3(30) or 
          ex2_mantissa_shlev3(31) or 
          ex2_mantissa_shlev3(32) or 
          ex2_mantissa_shlev3(33) or 
          ex2_mantissa_shlev3(34) or 
          ex2_mantissa_shlev3(35) or 
          ex2_mantissa_shlev3(36) or 
          ex2_mantissa_shlev3(37) or 
          ex2_mantissa_shlev3(38) or 
          ex2_mantissa_shlev3(39) or 
          ex2_mantissa_shlev3(40) or 
          ex2_mantissa_shlev3(41) or 
          ex2_mantissa_shlev3(42) or 
          ex2_mantissa_shlev3(43) or 
          ex2_mantissa_shlev3(44) or 
          ex2_mantissa_shlev3(45) or 
          ex2_mantissa_shlev3(46) or 
          ex2_mantissa_shlev3(47) or 
          ex2_mantissa_shlev3(48) or 
          ex2_mantissa_shlev3(49) or 
          ex2_mantissa_shlev3(50) or
          or_reduce( ex4_mantissa_shlev3(1 to 31) ) or
          or_reduce( ex2_a(4 to 7)        ) or
          or_reduce( ex2_c(4 to 11)       ) or
          or_reduce( ex4_addend1(1 to 11) ) or
          or_reduce( ex4_addend2(1 to 11) ) or
          or_reduce( ex4_addend3(1 to 11) ) or
          s2                      or 
          s3                      or 
          es2                     or 
          es3                     ; 
          

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


--==##########################################



    act_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(4),
        mpw1_b           => mpw1_b(4),
        mpw2_b           => mpw2_b(0),
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => act_so  ,                      
        scin             => act_si  ,                    
        -------------------
        din(0)           => act_spare_unused(0),
        din(1)           => act_spare_unused(1),
        din(2)           => rf1_act,
        din(3)           => ex1_act,
        din(4)           => ex2_act,
        din(5)           => ex3_act,
        din(6)           => act_spare_unused(2),
        din(7)           => act_spare_unused(3),
        -------------------
        dout(0)          => act_spare_unused(0),
        dout(1)          => act_spare_unused(1),
        dout(2)          => ex1_act,
        dout(3)          => ex2_act,   
        dout(4)          => ex3_act,
        dout(5)          => ex4_act,
        dout(6)          => act_spare_unused(2) ,
        dout(7)          => act_spare_unused(3) );


--==##########################################


zeros <= (1 to 16 => tidn);







       
     ex1_floges <=   f_pic_ex1_floges;
     ex1_fexptes <=   f_pic_ex1_fexptes;



  -----------------------------------------------------------------------
    ex2_gst_ctrl_lat :  tri_rlmreg_p generic map (expand_type => expand_type, width=> 2, needs_sreset => 0) port map ( 
        forcee => forcee,  
        delay_lclkr      => delay_lclkr(2),
        mpw1_b           => mpw1_b(2),
        mpw2_b           => mpw2_b(0),
        vd               => vdd,   gd               => gnd,
        nclk             => nclk,  thold_b          => thold_0_b,  sg               => sg_0,
        -------------------
        act              => ex1_act,
        -------------------
        scout            => ex2_gst_ctrl_lat_scout,                       
        scin             => ex2_gst_ctrl_lat_scin,                   
        -------------------
        din(00)          => ex1_floges,
        din(01)          => ex1_fexptes,
        -------------------
        dout(00)         => ex2_floges,
        dout(01)         => ex2_fexptes 
        );
      -----------------------------------------------------------------------



------------------------------------------------------------------------
------------------------------------------------------------------------


f_fmt_ex1_b_expo_gst <= not f_fmt_ex1_b_expo_gst_b;

  -----------------------------------------------------------------------
    ex2_gst_stage_lat:  tri_rlmreg_p generic map (expand_type => expand_type, width=> 33, needs_sreset => 0) port map ( 
        forcee => forcee,  
        delay_lclkr      => delay_lclkr(2),
        mpw1_b           => mpw1_b(2),
        mpw2_b           => mpw2_b(0),
        vd               => vdd,   gd               => gnd,
        nclk             => nclk,  thold_b          => thold_0_b,  sg               => sg_0,
        -------------------
        act              => ex1_act,
        -------------------
        scout            => ex2_gst_stage_lat_scout,                     
        scin             => ex2_gst_stage_lat_scin,                   
        -------------------
        din(00)          => f_fmt_ex1_b_sign_gst,
        din(01 to 13)    => f_fmt_ex1_b_expo_gst,
        din(14 to 32)    => f_fmt_ex1_b_frac_gst,

        -------------------
        dout(00)         => ex2_b_sign,          
        dout(01 to 13)   => ex2_b_biased_13exp,  
        dout(14 to 32)   => ex2_b_fract         

        );
        

--******************************************************************************
--* LOG ESTIMATE CALCULATION, FRACTIONAL PORTION
--******************************************************************************

ex2_f(1 to 11) <= ex2_b_fract(1 to 11);


f1  <= ex2_f(1);
f2  <= ex2_f(2);
f3  <= ex2_f(3);
f4  <= ex2_f(4);
f5  <= ex2_f(5);
f6  <= ex2_f(6);
f7  <= ex2_f(7);
f8  <= ex2_f(8);
f9  <= ex2_f(9);
f10 <= ex2_f(10);

s1   <= (not f1 and not f2 and not f3 and not f4 );    --0
s2_0 <= (not f1 and not f2 and not f3 and     f4 ) or  --1
        (not f1 and not f2 and     f3 and not f4 );    --2
s3_0 <= (not f1 and not f2 and     f3 and     f4 ) or  --3
        (not f1 and     f2 and not f3            );    --4,5
sx   <= (not f1 and     f2 and     f3            )or   --6,7
        (    f1 and not f2 and not f3 and not f4 );    --8
s3_1 <= (    f1 and not f2 and not f3 and     f4 ) or  --9
        (    f1 and not f2 and     f3            );    --10,11
s2_1 <= (    f1 and     f2                       );    --12,13,14,15

s2 <= s2_0 or s2_1 ;
s3 <= s3_0 or s3_1 ;


--------------------------------------------------------------------------------

c4 <= sx ;
c5 <= s3_0 or s3_1 ;
c6 <= sx   or s2_0;
c7 <= sx   or s3_0 ;







a4 <= (s1    and     f3) or 
      (s2_0  and     f2) or 
      (s2_1  and not f2);

a5 <= (s1    and     f4) or 
      (s2_0  and     f3) or 
      (s2_1  and not f3) or 
      (s3_0  and     f2) or 
      (s3_1  and not f2);

a6 <= (s1    and     f5) or 
      (s2_0  and     f4) or 
      (s2_1  and not f4) or 
      (s3_0  and     f3) or 
      (s3_1  and not f3);

a7 <= (s1    and     f6) or 
      (s2_0  and     f5) or 
      (s2_1  and not f5) or 
      (s3_0  and     f4) or 
      (s3_1  and not f4);


a8 <= (s1    and     f7) or 
      (s2_0  and     f6) or 
      (s2_1  and not f6) or 
      (s3_0  and     f5) or 
      (s3_1  and not f5);

a9 <= (s1    and     f8) or 
      (s2_0  and     f7) or 
      (s2_1  and not f7) or 
      (s3_0  and     f6) or 
      (s3_1  and not f6);

a10 <= (s1   and     f9) or 
       (s2_0 and     f8) or 
       (s2_1 and not f8) or 
       (s3_0 and     f7) or 
       (s3_1 and not f7);

a11 <= (s1   and     f10) or 
       (s2_0 and     f9)  or 
       (s2_1 and not f9)  or 
       (s3_0 and     f8)  or 
       (s3_1 and not f8);

--------------------------------------------------------------------------------

ex2_a(4 to 11) <=  a4 & a5 & a6 & a7 & a8 & a9 & a10 & a11;
ex2_c(4 to 11) <=  c4 & c5 & c6 & c7 & tidn & tidn & tidn & tidn;






 c3_if_s1  <= f4 and     f3 ;
 c3_if_s20 <= f4 and     f2 ;
 c3_if_s30 <= tidn          ;
 c3_if_sx  <= f4            ;
 c3_if_s31 <= tidn          ;
 c3_if_s21 <= f4 and not f2 ;

 s4_if_s1  <=     f4 xor     f3 ;
 s4_if_s20 <=     f4 xor     f2 ;
 s4_if_s30 <=     f4            ;
 s4_if_sx  <= not f4            ;
 s4_if_s31 <=     f4            ;
 s4_if_s21 <=     f4 xor not f2 ;


 c4_if_s1  <= f5 and     f4 ;
 c4_if_s20 <= f5 and     f3 ;
 c4_if_s30 <= f5 or      f2 ;
 c4_if_sx  <= tidn          ;
 c4_if_s31 <= f5 or  not f2 ;
 c4_if_s21 <= f5 and not f3 ;

 s5_if_s1  <=     f5 xor     f4 ;
 s5_if_s20 <=     f5 xor     f3 ;
 s5_if_s30 <=     f5 xor not f2 ;
 s5_if_sx  <=     f5            ;
 s5_if_s31 <=     f5 xor     f2 ;
 s5_if_s21 <=     f5 xor not f3 ;


 c5_if_s1  <= f6 and     f5 ;
 c5_if_s20 <= f6 or      f4 ;
 c5_if_s30 <= f6 and     f3 ;  
 c5_if_sx  <= f6            ;
 c5_if_s31 <= f6 and not f3 ;
 c5_if_s21 <= f6 and not f4 ;

 s6_if_s1  <=     f6 xor     f5 ;
 s6_if_s20 <=     f6 xor not f4 ;
 s6_if_s30 <=     f6 xor     f3 ;  
 s6_if_sx  <= not f6            ;
 s6_if_s31 <=     f6 xor not f3 ;
 s6_if_s21 <=     f6 xor not f4 ;


 c6_if_s1  <= f7 and     f6 ;
 c6_if_s20 <= f7 and     f5 ;
 c6_if_s30 <= f7 or      f4 ;
 c6_if_sx  <= f7            ;
 c6_if_s31 <= f7 and not f4 ;
 c6_if_s21 <= f7 and not f5 ;

 s7_if_s1  <=     f7 xor     f6 ;
 s7_if_s20 <=     f7 xor     f5 ;
 s7_if_s30 <=     f7 xor not f4 ;
 s7_if_sx  <= not f7            ;
 s7_if_s31 <=     f7 xor not f4 ;
 s7_if_s21 <=     f7 xor not f5 ;



  ex2_log_fsum(4) <=
    ( s1   and s4_if_s1  ) or 
    ( s2_0 and s4_if_s20 ) or 
    ( s3_0 and s4_if_s30 ) or 
    ( sx   and s4_if_sx  ) or 
    ( s3_1 and s4_if_s31 ) or 
    ( s2_1 and s4_if_s21 ) ; 

  ex2_log_fcarryin(3) <= 
    ( s1   and c3_if_s1  ) or 
    ( s2_0 and c3_if_s20 ) or 
    ( s3_0 and c3_if_s30 ) or 
    ( sx   and c3_if_sx  ) or 
    ( s3_1 and c3_if_s31 ) or 
    ( s2_1 and c3_if_s21 ) ; 



  ex2_log_fsum(5) <=
    ( s1   and s5_if_s1  ) or 
    ( s2_0 and s5_if_s20 ) or 
    ( s3_0 and s5_if_s30 ) or 
    ( sx   and s5_if_sx  ) or 
    ( s3_1 and s5_if_s31 ) or 
    ( s2_1 and s5_if_s21 ) ; 

  ex2_log_fcarryin(4) <= 
    ( s1   and c4_if_s1  ) or 
    ( s2_0 and c4_if_s20 ) or 
    ( s3_0 and c4_if_s30 ) or 
    ( sx   and c4_if_sx  ) or 
    ( s3_1 and c4_if_s31 ) or 
    ( s2_1 and c4_if_s21 ) ; 



  ex2_log_fsum(6) <=
    ( s1   and s6_if_s1  ) or 
    ( s2_0 and s6_if_s20 ) or 
    ( s3_0 and s6_if_s30 ) or 
    ( sx   and s6_if_sx  ) or 
    ( s3_1 and s6_if_s31 ) or 
    ( s2_1 and s6_if_s21 ) ; 

  ex2_log_fcarryin(5) <= 
    ( s1   and c5_if_s1  ) or 
    ( s2_0 and c5_if_s20 ) or 
    ( s3_0 and c5_if_s30 ) or 
    ( sx   and c5_if_sx  ) or 
    ( s3_1 and c5_if_s31 ) or 
    ( s2_1 and c5_if_s21 ) ; 




  ex2_log_fsum(7) <=
    ( s1   and s7_if_s1  ) or 
    ( s2_0 and s7_if_s20 ) or 
    ( s3_0 and s7_if_s30 ) or 
    ( sx   and s7_if_sx  ) or 
    ( s3_1 and s7_if_s31 ) or 
    ( s2_1 and s7_if_s21 ) ; 

  ex2_log_fcarryin(6) <= 
    ( s1   and c6_if_s1  ) or 
    ( s2_0 and c6_if_s20 ) or 
    ( s3_0 and c6_if_s30 ) or 
    ( sx   and c6_if_sx  ) or 
    ( s3_1 and c6_if_s31 ) or 
    ( s2_1 and c6_if_s21 ) ; 

  ex2_log_a_addend_b(1)  <= not( ex2_f(1) ) ;
  ex2_log_a_addend_b(2)  <= not( ex2_f(2) ) ;
  ex2_log_a_addend_b(3)  <= not( ex2_f(3) ) ;
  ex2_log_a_addend_b(4)  <= not( ex2_log_fsum(4) );
  ex2_log_a_addend_b(5)  <= not( ex2_log_fsum(5) );
  ex2_log_a_addend_b(6)  <= not( ex2_log_fsum(6) );
  ex2_log_a_addend_b(7)  <= not( ex2_log_fsum(7) );
  ex2_log_a_addend_b(8)  <= not( ex2_f(8) );
  ex2_log_a_addend_b(9)  <= not( ex2_f(9) );
  ex2_log_a_addend_b(10) <= not( ex2_f(10));
  ex2_log_a_addend_b(11) <= not( ex2_f(11));

  ex2_log_b_addend_b(1)  <= not( tidn     ) ;
  ex2_log_b_addend_b(2)  <= not( tidn     ) ;
  ex2_log_b_addend_b(3)  <= not( ex2_log_fcarryin(3) );
  ex2_log_b_addend_b(4)  <= not( ex2_log_fcarryin(4) );
  ex2_log_b_addend_b(5)  <= not( ex2_log_fcarryin(5) );
  ex2_log_b_addend_b(6)  <= not( ex2_log_fcarryin(6) );
  ex2_log_b_addend_b(7)  <= not( tidn      );
  ex2_log_b_addend_b(8)  <= not( ex2_a(8)  );
  ex2_log_b_addend_b(9)  <= not( ex2_a(9)  );
  ex2_log_b_addend_b(10) <= not( ex2_a(10) );
  ex2_log_b_addend_b(11) <= not( ex2_a(11) );




--------------------------------------------------------------------------------
-- unbias the exponent
--------------------------------------------------------------------------------
-- bias is DP, so subtract 1023

ex2_b_biased_11exp(1 to 11) <= ex2_b_biased_13exp(3 to 13);

-- add -1023 (10000000001)

ex2_b_ubexp_sum(01)       <= not ex2_b_biased_11exp(01);
ex2_b_ubexp_sum(02 to 10) <=     ex2_b_biased_11exp(02 to 10);
ex2_b_ubexp_sum(11)       <= not ex2_b_biased_11exp(11);


ex2_ube_g2_b(11) <= not( ex2_b_biased_11exp(11)                            );
ex2_ube_g2_b(10) <= not( ex2_b_biased_11exp(10) and ex2_b_biased_11exp(11) );
ex2_ube_g2_b( 9) <= not( ex2_b_biased_11exp( 9) and ex2_b_biased_11exp(10) );
ex2_ube_g2_b( 8) <= not( ex2_b_biased_11exp( 8) and ex2_b_biased_11exp( 9) );
ex2_ube_g2_b( 7) <= not( ex2_b_biased_11exp( 7) and ex2_b_biased_11exp( 8) );
ex2_ube_g2_b( 6) <= not( ex2_b_biased_11exp( 6) and ex2_b_biased_11exp( 7) );
ex2_ube_g2_b( 5) <= not( ex2_b_biased_11exp( 5) and ex2_b_biased_11exp( 6) );
ex2_ube_g2_b( 4) <= not( ex2_b_biased_11exp( 4) and ex2_b_biased_11exp( 5) );
ex2_ube_g2_b( 3) <= not( ex2_b_biased_11exp( 3) and ex2_b_biased_11exp( 4) );
ex2_ube_g2_b( 2) <= not( ex2_b_biased_11exp( 2) and ex2_b_biased_11exp( 3) );


ex2_ube_g4  (11) <= not( ex2_ube_g2_b(11)                     );
ex2_ube_g4  (10) <= not( ex2_ube_g2_b(10)                     );
ex2_ube_g4  ( 9) <= not( ex2_ube_g2_b( 9) or ex2_ube_g2_b(11) );
ex2_ube_g4  ( 8) <= not( ex2_ube_g2_b( 8) or ex2_ube_g2_b(10) );
ex2_ube_g4  ( 7) <= not( ex2_ube_g2_b( 7) or ex2_ube_g2_b( 9) );
ex2_ube_g4  ( 6) <= not( ex2_ube_g2_b( 6) or ex2_ube_g2_b( 8) );
ex2_ube_g4  ( 5) <= not( ex2_ube_g2_b( 5) or ex2_ube_g2_b( 7) );
ex2_ube_g4  ( 4) <= not( ex2_ube_g2_b( 4) or ex2_ube_g2_b( 6) );
ex2_ube_g4  ( 3) <= not( ex2_ube_g2_b( 3) or ex2_ube_g2_b( 5) );
ex2_ube_g4  ( 2) <= not( ex2_ube_g2_b( 2) or ex2_ube_g2_b( 4) );

ex2_ube_g8_b(11) <= not( ex2_ube_g4(11) );
ex2_ube_g8_b(10) <= not( ex2_ube_g4(10) );
ex2_ube_g8_b( 9) <= not( ex2_ube_g4( 9) );
ex2_ube_g8_b( 8) <= not( ex2_ube_g4( 8) );
ex2_ube_g8_b( 7) <= not( ex2_ube_g4( 7) and ex2_ube_g4(11) );
ex2_ube_g8_b( 6) <= not( ex2_ube_g4( 6) and ex2_ube_g4(10) );
ex2_ube_g8_b( 5) <= not( ex2_ube_g4( 5) and ex2_ube_g4( 9) );
ex2_ube_g8_b( 4) <= not( ex2_ube_g4( 4) and ex2_ube_g4( 8) );
ex2_ube_g8_b( 3) <= not( ex2_ube_g4( 3) and ex2_ube_g4( 7) );
ex2_ube_g8_b( 2) <= not( ex2_ube_g4( 2) and ex2_ube_g4( 6) );

ex2_b_ubexp_cout(11) <= not( ex2_ube_g8_b(11) ) ;
ex2_b_ubexp_cout(10) <= not( ex2_ube_g8_b(10) ) ;
ex2_b_ubexp_cout( 9) <= not( ex2_ube_g8_b( 9) ) ;
ex2_b_ubexp_cout( 8) <= not( ex2_ube_g8_b( 8) ) ;
ex2_b_ubexp_cout( 7) <= not( ex2_ube_g8_b( 7) ) ;
ex2_b_ubexp_cout( 6) <= not( ex2_ube_g8_b( 6) ) ;
ex2_b_ubexp_cout( 5) <= not( ex2_ube_g8_b( 5) ) ;
ex2_b_ubexp_cout( 4) <= not( ex2_ube_g8_b( 4) ) ;
ex2_b_ubexp_cout( 3) <= not( ex2_ube_g8_b( 3) or ex2_ube_g8_b(11) );
ex2_b_ubexp_cout( 2) <= not( ex2_ube_g8_b( 2) or ex2_ube_g8_b(10) );

ex2_b_ubexp(01 to 10) <= ex2_b_ubexp_sum(01 to 10) xor ex2_b_ubexp_cout(02 to 11);
ex2_b_ubexp(11)       <= ex2_b_ubexp_sum(11);

--------------------------------------------------------------------------------

ex2_logadd11: entity work.fuq_gst_add11(fuq_gst_add11) port map(  -- not really an 11 bit adder
       a_b(0 to 10) => ex2_log_a_addend_b(1 to 11),
       b_b(0 to 10) => ex2_log_b_addend_b(1 to 11),
     --------------------------------------------------------
     s0(0 to 10)  => ex2_log_mantissa_precomp(9 to 19)
     );
   -----------------------------------------------------------------------


  ex2_log_mantissa_precomp(1 to 8) <= ex2_b_ubexp(4 to 11);

------------------------------------------------------------------------------------------------------------------------
-- for fexptes, shift mantissa based on the exponent (un-normalize)

ex2_mantissa_shlev0(00 to 19) <= tiup & ex2_b_fract(01 to 19);

ex2_shamt(0 to 4) <= ex2_b_ubexp(1) & ex2_b_ubexp(08 to 11);

--timing note: the shift amount comes after the adder to unbias the exponent.
--             it would be faster to use the biased exponent but use the shift controls different.
--
--             1 2 3 4 5 6 7 8 9 A B
--             0 1 1 1 1 1 1 1 1 1 1  bias =1023
--             1 0 0 0 0 0 0 0 0 0 1  add -1023 to unbias
--             for small shifts   unbiased 01 = biased 00
--             for small shifts   unbiased 10 = biased 01
--             for small shifts   unbiased 11 = biased 10
--             for small shifts   unbiased 00 = biased 11


ex2_powsh_no_sat_lft <= not ex2_b_ubexp(2) and  
                        not ex2_b_ubexp(3) and  
                        not ex2_b_ubexp(4) and  
                        not ex2_b_ubexp(5) and  
                        not ex2_b_ubexp(6) and  
                        not ex2_b_ubexp(7)    ; 
 
ex2_powsh_no_sat_rgt <=     ex2_b_ubexp(2) and  
                            ex2_b_ubexp(3) and  
                            ex2_b_ubexp(4) and  
                            ex2_b_ubexp(5) and  
                            ex2_b_ubexp(6) and  
                            ex2_b_ubexp(7)    ; 
 

l1_e00 <= not ex2_shamt(3) and not ex2_shamt(4);
l1_e01 <= not ex2_shamt(3) and     ex2_shamt(4);
l1_e10 <=     ex2_shamt(3) and not ex2_shamt(4);
l1_e11 <=     ex2_shamt(3) and     ex2_shamt(4);
    
l2_e00 <= not ex2_shamt(1) and not ex2_shamt(2);
l2_e01 <= not ex2_shamt(1) and     ex2_shamt(2);
l2_e10 <=     ex2_shamt(1) and not ex2_shamt(2);
l2_e11 <=     ex2_shamt(1) and     ex2_shamt(2);
    

 l3_e00 <= not ex2_shamt(0) and ex2_powsh_no_sat_lft;
 l3_e01 <=     ex2_shamt(0) and ex2_powsh_no_sat_rgt;


ex2_mantissa_shlev1(00 to 22) <= (zeros(01 to 03) & (ex2_mantissa_shlev0(00 to 19)                  ) and (00 to 22 => l1_e00)) or 
                                 (zeros(01 to 02) & (ex2_mantissa_shlev0(00 to 19) & zeros(01)      ) and (00 to 22 => l1_e01)) or
                                 (zeros(01      ) & (ex2_mantissa_shlev0(00 to 19) & zeros(01 to 02)) and (00 to 22 => l1_e10)) or 
                                 (                  (ex2_mantissa_shlev0(00 to 19) & zeros(01 to 03)) and (00 to 22 => l1_e11)) ;

                                 
ex2_mantissa_shlev2(00 to 34) <= (zeros(01 to 12) & (ex2_mantissa_shlev1(00 to 22)                  ) and (00 to 34 => l2_e00)) or 
                                 (zeros(01 to 08) & (ex2_mantissa_shlev1(00 to 22) & zeros(01 to 04)) and (00 to 34 => l2_e01)) or
                                 (zeros(01 to 04) & (ex2_mantissa_shlev1(00 to 22) & zeros(01 to 08)) and (00 to 34 => l2_e10)) or 
                                 (                  (ex2_mantissa_shlev1(00 to 22) & zeros(01 to 12)) and (00 to 34 => l2_e11)) ;

                                 
ex2_mantissa_shlev3(00 to 50) <= (                  (ex2_mantissa_shlev2(00 to 34) & zeros(01 to 16)) and (00 to 50 => l3_e00)) or 
                                 (zeros(01 to 16) & (ex2_mantissa_shlev2(00 to 34)                  ) and (00 to 50 => l3_e01)) ;


ex2_pow_int(1 to 8)   <= ex2_mantissa_shlev3(08 to 15);                              
ex2_pow_frac(1 to 11) <= ex2_mantissa_shlev3(16 to 26);



ex2_mantissa_din(1 to 19) <= ((ex2_pow_int(1 to 8) & ex2_pow_frac(1 to 11)) and (1 to 19 => ex2_fexptes)) or
                             (ex2_log_mantissa_precomp(1 to 19)             and (1 to 19 => ex2_floges ));

  -----------------------------------------------------------------------
  -----------------------------------------------------------------------
  -----------------------------------------------------------------------
  -----------------------------------------------------------------------
    ex3_gst_ctrl_lat :  tri_rlmreg_p generic map (expand_type => expand_type, width=> 2, needs_sreset => 0) port map ( 
        forcee => forcee,  
        delay_lclkr      => delay_lclkr(3),
        mpw1_b           => mpw1_b(3),
        mpw2_b           => mpw2_b(0),
        vd               => vdd,   gd               => gnd,
        nclk             => nclk,  thold_b          => thold_0_b,  sg               => sg_0,
        -------------------
        act              => ex2_act,
        -------------------
        scout            => ex3_gst_ctrl_lat_scout,                       
        scin             => ex3_gst_ctrl_lat_scin,                   
        -------------------
        din(00)          => ex2_floges,
        din(01)          => ex2_fexptes,
        -------------------
        dout(00)         => ex3_floges,
        dout(01)         => ex3_fexptes
        );
      -----------------------------------------------------------------------

    ex3_gst_stage_lat:  tri_rlmreg_p generic map (expand_type => expand_type, width => 20, needs_sreset => 0  ) port map ( 
        forcee => forcee,  
        delay_lclkr      => delay_lclkr(3),
        mpw1_b           => mpw1_b(3),
        mpw2_b           => mpw2_b(0),
        vd               => vdd,   gd               => gnd,
        nclk             => nclk,  thold_b          => thold_0_b,  sg               => sg_0,
        -------------------
        act              => ex2_act,
        -------------------
        scout            => ex3_gst_stage_lat_scout,                     
        scin             => ex3_gst_stage_lat_scin,                   
        -------------------
        din(00 to 18)    => ex2_mantissa_din,
        din(19)          => ex2_b_sign,
        -------------------
        dout(00 to 18)   => ex3_mantissa_precomp,            
        dout(19)         => ex3_b_sign

        );
      -----------------------------------------------------------------------
      -----------------------------------------------------------------------
      -----------------------------------------------------------------------

      
ex3_mantissa_precomp_b <= not ex3_mantissa_precomp(1 to 19);

  -----------------------------------------------------------------------
ex3_log_inc: entity work.fuq_gst_inc19(fuq_gst_inc19) port map( 
     a(1 to 19) => ex3_mantissa_precomp_b(1 to 19),
     --------------------------------------------------------
     o(1 to 19) => ex3_mantissa_neg(1 to 19)
     );
   -----------------------------------------------------------------------

ex3_negate <= (ex3_mantissa_precomp(1) and ex3_floges) or (ex3_fexptes and ex3_b_sign);

  ex3_mantissa(1 to 19) <= (    ex3_mantissa_neg(1 to 19)     and     (1 to 19 => ex3_negate)) or
                           (    ex3_mantissa_precomp(1 to 19) and not (1 to 19 => ex3_negate));



  -----------------------------------------------------------------------
ex3_log_loa: entity work.fuq_gst_loa(fuq_gst_loa) port map( 
     a(1 to 19) => ex3_mantissa,
     --------------------------------------------------------
     shamt(0 to 4) => ex3_shamt(0 to 4)
     );
   -----------------------------------------------------------------------

ex3_logof1_specialcase <= not or_reduce(ex3_shamt(0 to 4));

  -----------------------------------------------------------------------
    ex4_gst_ctrl_lat :  tri_rlmreg_p generic map (expand_type => expand_type, width=> 4, needs_sreset => 0) port map ( 
        forcee => forcee,  
        delay_lclkr      => delay_lclkr(4),
        mpw1_b           => mpw1_b(4),
        mpw2_b           => mpw2_b(0),
        vd               => vdd,   gd               => gnd,
        nclk             => nclk,  thold_b          => thold_0_b,  sg               => sg_0,
        -------------------
        act              => ex3_act,
        -------------------
        scout            => ex4_gst_ctrl_lat_scout,                       
        scin             => ex4_gst_ctrl_lat_scin,                   
        -------------------
        din(00)          => ex3_floges,
        din(01)          => ex3_fexptes,
        din(02)          => ex3_negate,
        din(03)          => ex3_logof1_specialcase,
        -------------------
        dout(00)         => ex4_floges,
        dout(01)         => ex4_fexptes,
        dout(02)         => ex4_negate,
        dout(03)         => ex4_logof1_specialcase     
        );
   

    ex4_gst_stage_lat:  tri_rlmreg_p generic map (expand_type => expand_type, width => 24, needs_sreset => 0  ) port map ( 
        forcee => forcee,  
        delay_lclkr      => delay_lclkr(4),
        mpw1_b           => mpw1_b(4),
        mpw2_b           => mpw2_b(0),
        vd               => vdd,   gd               => gnd,
        nclk             => nclk,  thold_b          => thold_0_b,  sg               => sg_0,
        -------------------
        act              => ex3_act,
        -------------------
        scout            => ex4_gst_stage_lat_scout,                     
        scin             => ex4_gst_stage_lat_scin,                   
        -------------------
        din(00 to 18)    => ex3_mantissa,
        din(19 to 23)    => ex3_shamt,
        -------------------
        dout(00 to 18)   => ex4_mantissa,            
        dout(19 to 23)   => ex4_shamt 
        );
   -----------------------------------------------------------------------
   -----------------------------------------------------------------------
   -----------------------------------------------------------------------

-- shift mantissa for log (shamt is set to zeros for exp)
-- log mantissa gets normalized here



ex4_mantissa_shlev0(01 to 19) <= ex4_mantissa(01 to 19);


l1_enc00 <= not ex4_shamt(3) and not ex4_shamt(4);
l1_enc01 <= not ex4_shamt(3) and     ex4_shamt(4);
l1_enc10 <=     ex4_shamt(3) and not ex4_shamt(4);
l1_enc11 <=     ex4_shamt(3) and     ex4_shamt(4);

l2_enc00 <= not ex4_shamt(1) and not ex4_shamt(2);
l2_enc01 <= not ex4_shamt(1) and     ex4_shamt(2);
l2_enc10 <=     ex4_shamt(1) and not ex4_shamt(2);
l2_enc11 <=     ex4_shamt(1) and     ex4_shamt(2);

l3_enc00 <= not ex4_shamt(0); 
l3_enc01 <=     ex4_shamt(0);   






ex4_mantissa_shlev1(01 to 22) <= (zeros(01 to 03) & (ex4_mantissa_shlev0(01 to 19)                  ) and (01 to 22 => l1_enc00)) or 
                                 (zeros(01 to 02) & (ex4_mantissa_shlev0(01 to 19) & zeros(01)      ) and (01 to 22 => l1_enc01)) or
                                 (zeros(01      ) & (ex4_mantissa_shlev0(01 to 19) & zeros(01 to 02)) and (01 to 22 => l1_enc10)) or 
                                 (                  (ex4_mantissa_shlev0(01 to 19) & zeros(01 to 03)) and (01 to 22 => l1_enc11)) ;

                                 

ex4_mantissa_shlev2(01 to 34) <= (zeros(01 to 12) & (ex4_mantissa_shlev1(01 to 22)                  ) and (01 to 34 => l2_enc00)) or 
                                 (zeros(01 to 08) & (ex4_mantissa_shlev1(01 to 22) & zeros(01 to 04)) and (01 to 34 => l2_enc01)) or
                                 (zeros(01 to 04) & (ex4_mantissa_shlev1(01 to 22) & zeros(01 to 08)) and (01 to 34 => l2_enc10)) or 
                                 (                  (ex4_mantissa_shlev1(01 to 22) & zeros(01 to 12)) and (01 to 34 => l2_enc11)) ;

                                 
ex4_mantissa_shlev3(01 to 50) <= (zeros(01 to 16) & (ex4_mantissa_shlev2(01 to 34)                  ) and (01 to 50 => l3_enc00)) or 
                                 (                  (ex4_mantissa_shlev2(01 to 34) & zeros(01 to 16)) and (01 to 50 => l3_enc01)) ;



                                 
ex4_log_mantissa_postsh(01 to 19) <= ex4_mantissa_shlev3(32 to 50);

------------------------------------------------------------------------------------------------------------------------
-- pow fract logic

ex4_f(1 to 11) <= ex4_mantissa(9 to 19);
-- ************************************
-- ** vexptefp fract logic
-- ************************************

     eb1 <= ex4_f(1);
     eb2 <= ex4_f(2);
     eb3 <= ex4_f(3);
     eb4 <= ex4_f(4);
     eb5 <= ex4_f(5);
     eb6 <= ex4_f(6);
     eb7 <= ex4_f(7);
     eb8 <= ex4_f(8);
     eb9 <= ex4_f(9);
     eb10 <= ex4_f(10);

 ex4_f_b(1 to 11) <= not ex4_f(1 to 11);
    
--0000 ^s2
--0001 ^s2
--0010 ^s2
--0011 ^s2
--0100 ^s3
--0101 ^s3
--0110 ^s3
--0111  --
--1000  --
--1001  --
--1010  s3
--1011  s3
--1100  s3
--1101  s2
--1110  s2
--1111  s1
      
   es2_0 <= ( not eb1 and not eb2                         )    ;--0,1,2,3
   es3_0 <= ( not eb1 and     eb2 and not eb3             ) or  --4,5
            ( not eb1 and     eb2 and     eb3 and not eb4 )    ;--6
   esx   <= ( not eb1 and     eb2 and     eb3 and     eb4 ) or  --7
            (     eb1 and not eb2 and not eb3             )    ;--8,9
   es3_1 <= (     eb1 and not eb2 and     eb3             ) or  --10,11
            (     eb1 and     eb2 and not eb3 and not eb4 )    ;--12
   es2_1 <= (     eb1 and     eb2 and not eb3 and     eb4 ) or  --13
            (     eb1 and     eb2 and     eb3 and not eb4 )    ;--14
   es1   <= (     eb1 and     eb2 and     eb3 and     eb4 )    ;--15

   es2 <= es2_0 or es2_1;
   es3 <= es3_0 or es3_1;

   ec4 <= esx ;
   ec5 <= es3_0 or es3_1;
   ec6 <= esx   or es2_1;
   ec7 <= esx   or es3_1;




 ec3_if_s20 <=     not eb4 and     eb2 ;
 ec3_if_s30 <=     tidn                ;
 ec3_if_sx  <=     not eb4             ;
 ec3_if_s31 <=     tidn                ;  
 ec3_if_s21 <=     not eb4 and not eb2 ;
 ec3_if_s1  <=     not eb4 and not eb3 ;

 es4_if_s20 <=     not eb4 xor     eb2 ;
 es4_if_s30 <=     not eb4             ;
 es4_if_sx  <=         eb4             ;
 es4_if_s31 <=     not eb4             ;  
 es4_if_s21 <=     not eb4 xor not eb2 ;
 es4_if_s1  <=     not eb4 xor not eb3 ;


 ec4_if_s20 <=     not eb5 and     eb3 ;
 ec4_if_s30 <=     not eb5 or      eb2 ;
 ec4_if_sx  <=         tidn            ;
 ec4_if_s31 <=     not eb5 or  not eb2 ;
 ec4_if_s21 <=     not eb5 and not eb3 ;
 ec4_if_s1  <=     not eb5 and not eb4 ;

 es5_if_s20 <=     not eb5 xor     eb3 ;
 es5_if_s30 <=     not eb5 xor not eb2 ;
 es5_if_sx  <=     not eb5             ;
 es5_if_s31 <=     not eb5 xor     eb2 ;
 es5_if_s21 <=     not eb5 xor not eb3 ;
 es5_if_s1  <=     not eb5 xor not eb4 ;


 ec5_if_s20 <=     not eb6 and     eb4 ;
 ec5_if_s30 <=     not eb6 and     eb3 ;
 ec5_if_sx  <=     not eb6             ;
 ec5_if_s31 <=     not eb6 and not eb3 ;  
 ec5_if_s21 <=     not eb6 or  not eb4 ;
 ec5_if_s1  <=     not eb6 and not eb5 ;

 es6_if_s20 <=     not eb6 xor     eb4 ;
 es6_if_s30 <=     not eb6 xor     eb3 ;
 es6_if_sx  <=         eb6             ;
 es6_if_s31 <=     not eb6 xor not eb3 ;
 es6_if_s21 <=     not eb6 xor     eb4 ;
 es6_if_s1  <=     not eb6 xor not eb5 ;

 ec6_if_s20 <=     not eb7 and     eb5 ;
 ec6_if_s30 <=     not eb7 and     eb4 ;
 ec6_if_sx  <=     not eb7             ;
 ec6_if_s31 <=     not eb7 or  not eb4 ;
 ec6_if_s21 <=     not eb7 and not eb5 ;
 ec6_if_s1  <=     not eb7 and not eb6 ;

 es7_if_s20 <=     not eb7 xor     eb5 ;
 es7_if_s30 <=     not eb7 xor     eb4 ;
 es7_if_sx  <=         eb7             ;
 es7_if_s31 <=     not eb7 xor     eb4 ;
 es7_if_s21 <=     not eb7 xor not eb5 ;
 es7_if_s1  <=     not eb7 xor not eb6 ;


 




  
   ea4  <= (es1   and not eb3) or
           (es2_0 and     eb2) or
           (es2_1 and not eb2);

   ea5  <= (es1   and not eb4) or
           (es2_0 and     eb3) or
           (es2_1 and not eb3) or 
           (es3_0 and     eb2) or
           (es3_1 and not eb2);

   ea6  <= (es1   and not eb5) or
           (es2_0 and     eb4) or
           (es2_1 and not eb4) or 
           (es3_0 and     eb3) or
           (es3_1 and not eb3);

   ea7  <= (es1   and not eb6) or
           (es2_0 and     eb5) or
           (es2_1 and not eb5) or 
           (es3_0 and     eb4) or
           (es3_1 and not eb4);

   ea8  <= (es1   and not eb7) or
           (es2_0 and     eb6) or
           (es2_1 and not eb6) or 
           (es3_0 and     eb5) or
           (es3_1 and not eb5);

   ea9  <= (es1   and not eb8) or
           (es2_0 and     eb7) or
           (es2_1 and not eb7) or 
           (es3_0 and     eb6) or
           (es3_1 and not eb6);

   ea10 <= (es1   and not eb9) or
           (es2_0 and     eb8) or
           (es2_1 and not eb8) or 
           (es3_0 and     eb7) or
           (es3_1 and not eb7);

   ea11 <= (es1   and not eb10) or
           (es2_0 and     eb9) or
           (es2_1 and not eb9) or 
           (es3_0 and     eb8) or
           (es3_1 and not eb8);


--------------------------------------------------------------------------------



ex4_ea(4 to 11) <=  ea4 & ea5 & ea6 & ea7 & ea8 & ea9 & ea10 & ea11;
ex4_ec(4 to 11) <=  ec4 & ec5 & ec6 & ec7 & zeros(1 to 4);

ex4_addend1(1 to 11) <= ex4_f_b(1 to 11);  
ex4_addend2(1 to 11) <= zeros(1 to 3) & ex4_ea(4 to 11);
ex4_addend3(1 to 11) <= zeros(1 to 3) & ex4_ec(4 to 11);                    

 ex4_fsum(1)      <= ex4_f_b(1) ;
 ex4_fsum(2)      <= ex4_f_b(2) ;
 ex4_fsum(3)      <= ex4_f_b(3) ;
 ex4_fsum(4) <=
    ( es1   and es4_if_s1  ) or 
    ( es2_0 and es4_if_s20 ) or 
    ( es3_0 and es4_if_s30 ) or 
    ( esx   and es4_if_sx  ) or 
    ( es3_1 and es4_if_s31 ) or 
    ( es2_1 and es4_if_s21 ) ; 
 ex4_fsum(5)      <=
    ( es1   and es5_if_s1  ) or 
    ( es2_0 and es5_if_s20 ) or 
    ( es3_0 and es5_if_s30 ) or 
    ( esx   and es5_if_sx  ) or 
    ( es3_1 and es5_if_s31 ) or 
    ( es2_1 and es5_if_s21 ) ; 
 ex4_fsum(6)      <= 
    ( es1   and es6_if_s1  ) or 
    ( es2_0 and es6_if_s20 ) or 
    ( es3_0 and es6_if_s30 ) or 
    ( esx   and es6_if_sx  ) or 
    ( es3_1 and es6_if_s31 ) or 
    ( es2_1 and es6_if_s21 ) ; 
 ex4_fsum(7)      <= 
    ( es1   and es7_if_s1  ) or 
    ( es2_0 and es7_if_s20 ) or 
    ( es3_0 and es7_if_s30 ) or 
    ( esx   and es7_if_sx  ) or 
    ( es3_1 and es7_if_s31 ) or 
    ( es2_1 and es7_if_s21 ) ; 
 ex4_fsum(8)      <= ex4_f_b(8)  ;
 ex4_fsum(9)      <= ex4_f_b(9)  ; 
 ex4_fsum(10)     <= ex4_f_b(10) ; 
 ex4_fsum(11)     <= ex4_f_b(11) ; 



 ex4_fcarryin(1)  <= tidn;
 ex4_fcarryin(2)  <= tidn;
 ex4_fcarryin(3) <= 
    ( es1   and ec3_if_s1  ) or 
    ( es2_0 and ec3_if_s20 ) or 
    ( es3_0 and ec3_if_s30 ) or 
    ( esx   and ec3_if_sx  ) or 
    ( es3_1 and ec3_if_s31 ) or 
    ( es2_1 and ec3_if_s21 ) ; 
 ex4_fcarryin(4)  <=  
    ( es1   and ec4_if_s1  ) or 
    ( es2_0 and ec4_if_s20 ) or 
    ( es3_0 and ec4_if_s30 ) or 
    ( esx   and ec4_if_sx  ) or 
    ( es3_1 and ec4_if_s31 ) or 
    ( es2_1 and ec4_if_s21 ) ; 
 ex4_fcarryin(5)  <=
    ( es1   and ec5_if_s1  ) or 
    ( es2_0 and ec5_if_s20 ) or 
    ( es3_0 and ec5_if_s30 ) or 
    ( esx   and ec5_if_sx  ) or 
    ( es3_1 and ec5_if_s31 ) or 
    ( es2_1 and ec5_if_s21 ) ; 
 ex4_fcarryin(6)  <= 
    ( es1   and ec6_if_s1  ) or 
    ( es2_0 and ec6_if_s20 ) or 
    ( es3_0 and ec6_if_s30 ) or 
    ( esx   and ec6_if_sx  ) or 
    ( es3_1 and ec6_if_s31 ) or 
    ( es2_1 and ec6_if_s21 ) ; 
 ex4_fcarryin(7)  <= tidn ;
 ex4_fcarryin(8)  <= ea8  ;
 ex4_fcarryin(9)  <= ea9  ;
 ex4_fcarryin(10) <= ea10 ;
 ex4_fcarryin(11) <= ea11 ;

ex4_powf_a_addend_b <= not ex4_fsum(1 to 11);
ex4_powf_b_addend_b <= not (ex4_fcarryin(1 to 11) );
          
ex4_powfractadd11: entity work.fuq_gst_add11(fuq_gst_add11) port map( 
     a_b(0 to 10) => ex4_powf_a_addend_b,
     b_b(0 to 10) => ex4_powf_b_addend_b,
     --------------------------------------------------------
     s0(0 to 10)  => ex4_pow_fract_b
     );

ex4_pow_fract <= not ex4_pow_fract_b;


------------------------------------------------------------------------------------------------------------------------
ex4_log_dp_bias <= ("01111110111" and (1 to 11 => not ex4_logof1_specialcase)) or -- not (dp bias +9)
                   ("11111111101" and (1 to 11 =>     ex4_logof1_specialcase));  -- results in exp of 000..1, which is zero

ex4_log_a_addend_b(1 to 11) <= zeros(1 to 6) & ex4_shamt(0 to 4);
ex4_log_b_addend_b(1 to 11) <= ex4_log_dp_bias;  

ex4_pow_a_addend_b(1 to 11) <= not (ex4_mantissa(1) & ex4_mantissa(1) & ex4_mantissa(1) & ex4_mantissa(1 to 8));
ex4_pow_b_addend_b(1 to 11) <= "10000000000";  -- dp bias


ex4_exponent_a_addend_b <= (ex4_log_a_addend_b and (1 to 11 => ex4_floges )) or
                           (ex4_pow_a_addend_b and (1 to 11 => ex4_fexptes)) ;

ex4_exponent_b_addend_b <= (ex4_log_b_addend_b and (1 to 11 => ex4_floges )) or
                           (ex4_pow_b_addend_b and (1 to 11 => ex4_fexptes)) ;

  -----------------------------------------------------------------------

ex4_explogadd11: entity work.fuq_gst_add11(fuq_gst_add11) port map( 
     a_b(0 to 10) => ex4_exponent_a_addend_b,
     b_b(0 to 10) => ex4_exponent_b_addend_b,
     --------------------------------------------------------
     s0(0 to 10)  => ex4_biased_exponent_result
     );
   -----------------------------------------------------------------------




   ex4_log_fract <= ex4_log_mantissa_postsh(01 to 19);
   ex4_log_signbit <= ex4_negate;


   ex4_signbit_din <= ex4_log_signbit and ex4_floges;

   
   ex4_fract_din <= (((not ex4_logof1_specialcase) & ex4_log_fract(1 to 19)) and (0 to 19 => ex4_floges )) or
                    ((tiup & ex4_pow_fract(1 to 11) & zeros(1 to 8))         and (0 to 19 => ex4_fexptes)) ;

  -----------------------------------------------------------------------
  -----------------------------------------------------------------------
  -----------------------------------------------------------------------
    ex5_gst_ctrl_lat :  tri_rlmreg_p generic map (expand_type => expand_type, width=> 2, needs_sreset => 0) port map ( 
        forcee => forcee,  
        delay_lclkr      => delay_lclkr(5),
        mpw1_b           => mpw1_b(5),
        mpw2_b           => mpw2_b(1),
        vd               => vdd,   gd               => gnd,
        nclk             => nclk,  thold_b          => thold_0_b,  sg               => sg_0,
        -------------------
        act              => ex4_act,
        -------------------
        scout            => ex5_gst_ctrl_lat_scout,                       
        scin             => ex5_gst_ctrl_lat_scin,                   
        -------------------
        din(00)          => ex4_floges,
        din(01)          => ex4_fexptes,
        -------------------
        dout(00)         => ex5_floges,
        dout(01)         => ex5_fexptes
        );
   

   
    ex5_gst_stage_lat:  tri_rlmreg_p generic map (expand_type => expand_type, width => 32, needs_sreset => 0 ) port map ( 
        forcee => forcee,  
        delay_lclkr      => delay_lclkr(5),
        mpw1_b           => mpw1_b(5),
        mpw2_b           => mpw2_b(1),
        vd               => vdd,   gd               => gnd,
        nclk             => nclk,  thold_b          => thold_0_b,  sg               => sg_0,
        -------------------
        act              => ex4_act,
        -------------------
        scout            => ex5_gst_stage_lat_scout,                     
        scin             => ex5_gst_stage_lat_scin,                   
        -------------------
        din(00)          => ex4_signbit_din,
        din(01 to 11)    => ex4_biased_exponent_result,
        din(12 to 31)    => ex4_fract_din,
        -------------------
        dout(00)         => ex5_signbit,        
        dout(01 to 11)   => ex5_biased_exponent_result,
        dout(12 to 31)   => ex5_fract       

        );

        
   -----------------------------------------------------------------------
   -----------------------------------------------------------------------
   -----------------------------------------------------------------------


        f_gst_ex5_logexp_sign      <= ex5_signbit;
        f_gst_ex5_logexp_exp       <= ex5_biased_exponent_result;
        f_gst_ex5_logexp_fract     <= ex5_fract;
        f_gst_ex5_logexp_v         <= ex5_floges or ex5_fexptes;
        

                   
ex2_gst_ctrl_lat_scin(0 to 1)   <= f_gst_si & ex2_gst_ctrl_lat_scout(0);                   
ex3_gst_ctrl_lat_scin(0 to 1)   <= ex2_gst_ctrl_lat_scout(1) & ex3_gst_ctrl_lat_scout(0);                    
ex4_gst_ctrl_lat_scin(0 to 3)   <= ex3_gst_ctrl_lat_scout(1) & ex4_gst_ctrl_lat_scout(0 to  2);                     
ex5_gst_ctrl_lat_scin(0 to 1)   <= ex4_gst_ctrl_lat_scout(3) & ex5_gst_ctrl_lat_scout(0);                    
ex2_gst_stage_lat_scin(0 to 32) <= ex5_gst_ctrl_lat_scout(1) & ex2_gst_stage_lat_scout(0 to 31);                      
ex3_gst_stage_lat_scin(0 to 19) <= ex2_gst_stage_lat_scout(32) & ex3_gst_stage_lat_scout(0 to 18);                      
ex4_gst_stage_lat_scin(0 to 23) <= ex3_gst_stage_lat_scout(19) & ex4_gst_stage_lat_scout(0 to 22);                     
ex5_gst_stage_lat_scin(0 to 31) <= ex4_gst_stage_lat_scout(23) & ex5_gst_stage_lat_scout(0 to 30); 


act_si(0 to 7) <= act_so(1 to 7) & ex5_gst_stage_lat_scout(31);

f_gst_so <= act_so(0);



end fuq_gst;
