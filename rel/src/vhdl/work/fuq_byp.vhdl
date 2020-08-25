-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

-- Synopsys translate, Issues resolved: NONE

library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 

ENTITY fuq_byp IS
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
PORT(
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

       f_byp_si                  :in   std_ulogic; --perv
       f_byp_so                  :out  std_ulogic; --perv
       rf1_act                   :in   std_ulogic; --act

       f_dcd_rf1_bypsel_a_res0   :in   std_ulogic;
       f_dcd_rf1_bypsel_a_res1   :in   std_ulogic;
       f_dcd_rf1_bypsel_a_load0  :in   std_ulogic;
       f_dcd_rf1_bypsel_a_load1  :in   std_ulogic;
       f_dcd_rf1_bypsel_b_res0   :in   std_ulogic;
       f_dcd_rf1_bypsel_b_res1   :in   std_ulogic;
       f_dcd_rf1_bypsel_b_load0  :in   std_ulogic;
       f_dcd_rf1_bypsel_b_load1  :in   std_ulogic;
       f_dcd_rf1_bypsel_c_res0   :in   std_ulogic;
       f_dcd_rf1_bypsel_c_res1   :in   std_ulogic;
       f_dcd_rf1_bypsel_c_load0  :in   std_ulogic;
       f_dcd_rf1_bypsel_c_load1  :in   std_ulogic;

        
       f_rnd_ex6_res_sign         :in  std_ulogic;            
       f_rnd_ex6_res_expo         :in  std_ulogic_vector(1 to 13);   
       f_rnd_ex6_res_frac         :in  std_ulogic_vector(0 to 52);
       f_dcd_rf1_uc_fc_hulp       :in  std_ulogic ;

       f_dcd_rf1_div_beg          :in  std_ulogic;
       f_dcd_rf1_uc_fa_pos        :in  std_ulogic;
       f_dcd_rf1_uc_fc_pos        :in  std_ulogic;
       f_dcd_rf1_uc_fb_pos        :in  std_ulogic;
       f_dcd_rf1_uc_fc_0_5        :in  std_ulogic;
       f_dcd_rf1_uc_fc_1_0        :in  std_ulogic;
       f_dcd_rf1_uc_fc_1_minus    :in  std_ulogic;
       f_dcd_rf1_uc_fb_1_0        :in  std_ulogic;
       f_dcd_rf1_uc_fb_0_75       :in  std_ulogic;
       f_dcd_rf1_uc_fb_0_5        :in  std_ulogic;


       f_fpr_ex7_frt_sign         :in   std_ulogic                  ;
       f_fpr_ex7_frt_expo         :in   std_ulogic_vector  (1 to 13);
       f_fpr_ex7_frt_frac         :in   std_ulogic_vector  (0 to 52);
       f_fpr_ex7_load_sign        :in   std_ulogic                  ;
       f_fpr_ex7_load_expo        :in   std_ulogic_vector  (3 to 13);
       f_fpr_ex7_load_frac        :in   std_ulogic_vector  (0 to 52);

       f_fpr_ex6_load_sign        :in  std_ulogic;
       f_fpr_ex6_load_expo        :in  std_ulogic_vector(3 to 13);
       f_fpr_ex6_load_frac        :in  std_ulogic_vector(0 to 52);
     
       f_fpr_rf1_a_sign           :in  std_ulogic;
       f_fpr_rf1_a_expo           :in  std_ulogic_vector(1 to 13);
       f_fpr_rf1_a_frac           :in  std_ulogic_vector(0 to 52); --[0] is implicit bit

       f_fpr_rf1_c_sign           :in  std_ulogic;
       f_fpr_rf1_c_expo           :in  std_ulogic_vector(1 to 13);
       f_fpr_rf1_c_frac           :in  std_ulogic_vector(0 to 52); --[0] is implicit bit

       f_fpr_rf1_b_sign           :in  std_ulogic;
       f_fpr_rf1_b_expo           :in  std_ulogic_vector(1 to 13);
       f_fpr_rf1_b_frac           :in  std_ulogic_vector(0 to 52); --[0] is implicit bit

       f_dcd_rf1_aop_valid        :in  std_ulogic;
       f_dcd_rf1_cop_valid        :in  std_ulogic;
       f_dcd_rf1_bop_valid        :in  std_ulogic;
       f_dcd_rf1_sp               :in  std_ulogic;
       f_dcd_rf1_to_integer_b     :in  std_ulogic;
       f_dcd_rf1_emin_dp          :in  std_ulogic;
       f_dcd_rf1_emin_sp          :in  std_ulogic;

       f_byp_fmt_ex1_a_expo       :out std_ulogic_vector(1 to 13);
       f_byp_fmt_ex1_c_expo       :out std_ulogic_vector(1 to 13);
       f_byp_fmt_ex1_b_expo       :out std_ulogic_vector(1 to 13);
       f_byp_eie_ex1_a_expo       :out std_ulogic_vector(1 to 13);
       f_byp_eie_ex1_c_expo       :out std_ulogic_vector(1 to 13);
       f_byp_eie_ex1_b_expo       :out std_ulogic_vector(1 to 13);
       f_byp_alg_ex1_a_expo       :out std_ulogic_vector(1 to 13);
       f_byp_alg_ex1_c_expo       :out std_ulogic_vector(1 to 13);
       f_byp_alg_ex1_b_expo       :out std_ulogic_vector(1 to 13);

       f_byp_fmt_ex1_a_sign       :out std_ulogic;
       f_byp_fmt_ex1_c_sign       :out std_ulogic;
       f_byp_fmt_ex1_b_sign       :out std_ulogic;
       f_byp_pic_ex1_a_sign       :out std_ulogic;
       f_byp_pic_ex1_c_sign       :out std_ulogic;
       f_byp_pic_ex1_b_sign       :out std_ulogic;
       f_byp_alg_ex1_b_sign       :out std_ulogic;

       f_byp_fmt_ex1_a_frac       :out std_ulogic_vector(0 to 52);
       f_byp_fmt_ex1_c_frac       :out std_ulogic_vector(0 to 52);
       f_byp_fmt_ex1_b_frac       :out std_ulogic_vector(0 to 52);
       f_byp_alg_ex1_b_frac       :out std_ulogic_vector(0 to 52);
       f_byp_mul_ex1_a_frac       :out std_ulogic_vector(0 to 52) ;--mul
       f_byp_mul_ex1_a_frac_17    :out std_ulogic                 ;--mul
       f_byp_mul_ex1_a_frac_35    :out std_ulogic                 ;--mul
       f_byp_mul_ex1_c_frac       :out std_ulogic_vector(0 to 53)  --mul


);

-- synopsys translate_off
-- synopsys translate_on


end fuq_byp; -- ENTITY

architecture fuq_byp of fuq_byp is

  constant tiup         :std_ulogic := '1';
  constant tidn         :std_ulogic := '0';
  constant k_emin_dp    :std_ulogic_vector(1 to 13) := "0000000000001";
  constant k_emin_sp    :std_ulogic_vector(1 to 13) := "0001110000001"; 
  constant k_toint      :std_ulogic_vector(1 to 13) := "0010001101001";
  constant expo_zero    :std_ulogic_vector(1 to 13) := "0000000000001";
  constant expo_bias    :std_ulogic_vector(1 to 13) := "0001111111111";
  constant expo_bias_m1 :std_ulogic_vector(1 to 13) := "0001111111110";
      ----------------------------------
      -- 57-bias is done after Ea+Ec-Eb
      ----------------------------------
      -- bias + 162 - 56
      -- bias + 106        1023+106 = 1129
      --
      -- 0_0011_1111_1111
      --         110 1010 106 =
      -------------------------------
      -- 0 0100 0110 1001
      -------------------------------

  signal  rf1_c_k_expo       :std_ulogic_vector(1 to 13);
  signal  rf1_b_k_expo       :std_ulogic_vector(1 to 13);
  signal  rf1_a_k_expo       :std_ulogic_vector(1 to 13);
  signal  rf1_a_k_frac       :std_ulogic_vector(0 to 52); 
  signal  rf1_c_k_frac       :std_ulogic_vector(0 to 52); 
  signal  rf1_b_k_frac       :std_ulogic_vector(0 to 52); 

  signal  rf1_a_expo_prebyp   :std_ulogic_vector(1 to 13);
  signal  rf1_c_expo_prebyp   :std_ulogic_vector(1 to 13);
  signal  rf1_b_expo_prebyp   :std_ulogic_vector(1 to 13);
  signal  rf1_a_frac_prebyp   :std_ulogic_vector(0 to 52);
  signal  rf1_c_frac_prebyp   :std_ulogic_vector(0 to 52);
  signal  rf1_b_frac_prebyp   :std_ulogic_vector(0 to 52);
  signal  rf1_a_sign_prebyp   :std_ulogic;
  signal  rf1_c_sign_prebyp   :std_ulogic;
  signal  rf1_b_sign_prebyp   :std_ulogic;


  signal rf1_a_sign_pre1_b :std_ulogic;
  signal rf1_a_sign_pre2_b :std_ulogic;
  signal rf1_a_sign_pre    :std_ulogic;
  signal rf1_c_sign_pre1_b :std_ulogic;
  signal rf1_c_sign_pre2_b :std_ulogic;
  signal rf1_c_sign_pre    :std_ulogic;
  signal rf1_b_sign_pre1_b :std_ulogic;
  signal rf1_b_sign_pre2_b :std_ulogic;
  signal rf1_b_sign_pre    :std_ulogic;

  signal  aop_valid_sign ,  cop_valid_sign ,  bop_valid_sign       :std_ulogic;
  signal  aop_valid_plus ,  cop_valid_plus ,  bop_valid_plus       :std_ulogic;


  signal spare_unused :std_ulogic_vector(0 to 3);
  signal unused :std_ulogic;
  signal thold_0, forcee, thold_0_b, sg_0  :std_ulogic ; 


  signal ex1_b_frac_si , ex1_b_frac_so :std_ulogic_vector(0 to 52);
  signal ex1_frac_a_fmt_si   , ex1_frac_a_fmt_so   :std_ulogic_vector(0 to 52);
  signal ex1_frac_c_fmt_si   , ex1_frac_c_fmt_so   :std_ulogic_vector(0 to 52);
  signal ex1_frac_b_fmt_si   , ex1_frac_b_fmt_so   :std_ulogic_vector(0 to 52);
  signal frac_mul_c_si   , frac_mul_c_so   :std_ulogic_vector(0 to 53);
  signal frac_mul_a_si   , frac_mul_a_so   :std_ulogic_vector(0 to 54);

  signal ex1_expo_a_eie_si, ex1_expo_a_eie_so    :std_ulogic_vector(0 to 13);
  signal ex1_expo_b_eie_si, ex1_expo_b_eie_so    :std_ulogic_vector(0 to 13);
  signal ex1_expo_c_eie_si, ex1_expo_c_eie_so    :std_ulogic_vector(0 to 13);
  signal ex1_expo_a_fmt_si, ex1_expo_a_fmt_so    :std_ulogic_vector(0 to 13);
  signal ex1_expo_b_fmt_si, ex1_expo_b_fmt_so    :std_ulogic_vector(0 to 13);
  signal ex1_expo_c_fmt_si, ex1_expo_c_fmt_so    :std_ulogic_vector(0 to 13);
  signal ex1_expo_b_alg_si, ex1_expo_b_alg_so    :std_ulogic_vector(0 to 13);
  signal ex1_expo_a_alg_si, ex1_expo_a_alg_so    :std_ulogic_vector(0 to 12);
  signal ex1_expo_c_alg_si, ex1_expo_c_alg_so    :std_ulogic_vector(0 to 12);

  signal act_si, act_so :std_ulogic_vector(0 to 3);


  signal   sel_a_no_byp_s    :std_ulogic;
  signal   sel_c_no_byp_s    :std_ulogic;
  signal   sel_b_no_byp_s    :std_ulogic;
    signal   sel_a_res0_s  :std_ulogic;
    signal   sel_a_res1_s  :std_ulogic;
    signal   sel_a_load0_s :std_ulogic;
    signal   sel_a_load1_s :std_ulogic;
    signal   sel_c_res0_s  :std_ulogic;
    signal   sel_c_res1_s  :std_ulogic;
    signal   sel_c_load0_s :std_ulogic;
    signal   sel_c_load1_s :std_ulogic;
    signal   sel_b_res0_s  :std_ulogic;
    signal   sel_b_res1_s  :std_ulogic;
    signal   sel_b_load0_s :std_ulogic;
    signal   sel_b_load1_s :std_ulogic;

  signal   sel_a_no_byp    :std_ulogic;
  signal   sel_c_no_byp    :std_ulogic;
  signal   sel_b_no_byp    :std_ulogic;


  signal   sel_a_imm   :std_ulogic;
  signal   sel_a_res0  :std_ulogic;
  signal   sel_a_res1  :std_ulogic;
  signal   sel_a_load0 :std_ulogic;
  signal   sel_a_load1 :std_ulogic;
  signal   sel_c_imm   :std_ulogic;
  signal   sel_c_res0  :std_ulogic;
  signal   sel_c_res1  :std_ulogic;
  signal   sel_c_load0 :std_ulogic;
  signal   sel_c_load1 :std_ulogic;
  signal   sel_b_imm   :std_ulogic;
  signal   sel_b_res0  :std_ulogic;
  signal   sel_b_res1  :std_ulogic;
  signal   sel_b_load0 :std_ulogic;
  signal   sel_b_load1 :std_ulogic;


  signal   ex6_load_expo :std_ulogic_vector(1 to 13);

  signal rf1_b_frac_alg_b, ex1_b_frac_alg_b :std_ulogic_vector(0 to 52);
  signal rf1_a_frac_fmt_b, ex1_a_frac_fmt_b :std_ulogic_vector(0 to 52);
  signal rf1_c_frac_fmt_b, ex1_c_frac_fmt_b :std_ulogic_vector(0 to 52);
  signal rf1_b_frac_fmt_b, ex1_b_frac_fmt_b :std_ulogic_vector(0 to 52);
  signal ex1_a_frac_mul_17_b, ex1_a_frac_mul_35_b :std_ulogic;
  signal ex1_a_frac_mul_b :std_ulogic_vector(0 to 52);
  signal ex1_c_frac_mul_b :std_ulogic_vector(0 to 53);
  signal rf1_a_frac_mul_17_b, rf1_a_frac_mul_35_b :std_ulogic;
  signal rf1_a_frac_mul_b :std_ulogic_vector(0 to 52);
  signal rf1_c_frac_mul_b :std_ulogic_vector(0 to 53);
  signal rf1_b_sign_alg_b, ex1_b_sign_alg_b :std_ulogic ;
  signal rf1_b_expo_alg_b, ex1_b_expo_alg_b :std_ulogic_vector(1 to 13);
  signal rf1_c_expo_alg_b, ex1_c_expo_alg_b :std_ulogic_vector(1 to 13);
  signal rf1_a_expo_alg_b, ex1_a_expo_alg_b :std_ulogic_vector(1 to 13);
  signal rf1_a_sign_fmt_b, ex1_a_sign_fmt_b :std_ulogic          ;
  signal rf1_a_expo_fmt_b, ex1_a_expo_fmt_b :std_ulogic_vector(1 to 13) ;
  signal rf1_c_sign_fmt_b, ex1_c_sign_fmt_b :std_ulogic         ;
  signal rf1_c_expo_fmt_b, ex1_c_expo_fmt_b :std_ulogic_vector(1 to 13) ;
  signal rf1_b_sign_fmt_b, ex1_b_sign_fmt_b :std_ulogic         ;
  signal rf1_b_expo_fmt_b, ex1_b_expo_fmt_b :std_ulogic_vector(1 to 13) ;
  signal rf1_a_sign_pic_b, ex1_a_sign_pic_b :std_ulogic          ;
  signal rf1_a_expo_eie_b, ex1_a_expo_eie_b :std_ulogic_vector(1 to 13) ;
  signal rf1_c_sign_pic_b, ex1_c_sign_pic_b :std_ulogic          ;
  signal rf1_c_expo_eie_b, ex1_c_expo_eie_b :std_ulogic_vector(1 to 13) ;
  signal rf1_b_sign_pic_b, ex1_b_sign_pic_b :std_ulogic          ;
  signal rf1_b_expo_eie_b, ex1_b_expo_eie_b :std_ulogic_vector(1 to 13) ;
  signal cop_uc_imm , bop_uc_imm :std_ulogic;

 signal rf1_a_sign_fpr :std_ulogic;
 signal rf1_c_sign_fpr :std_ulogic;
 signal rf1_b_sign_fpr :std_ulogic;
 signal rf1_a_expo_fpr :std_ulogic_vector(1 to 13);
 signal rf1_c_expo_fpr :std_ulogic_vector(1 to 13);
 signal rf1_b_expo_fpr :std_ulogic_vector(1 to 13);
 signal rf1_a_frac_fpr :std_ulogic_vector(0 to 52);
 signal rf1_c_frac_fpr :std_ulogic_vector(0 to 52);
 signal rf1_b_frac_fpr :std_ulogic_vector(0 to 52);

 signal ex6_sign_res_ear  :std_ulogic;
 signal ex6_sign_res_dly  :std_ulogic;
 signal ex6_sign_lod_ear  :std_ulogic;
 signal ex6_sign_lod_dly  :std_ulogic;
 signal ex6_expo_res_ear :std_ulogic_vector(1 to 13);
 signal ex6_expo_res_dly :std_ulogic_vector(1 to 13);
 signal ex6_expo_lod_ear :std_ulogic_vector(1 to 13);
 signal ex6_expo_lod_dly :std_ulogic_vector(1 to 13);
 signal ex6_frac_res_ear :std_ulogic_vector(0 to 52);
 signal ex6_frac_res_dly :std_ulogic_vector(0 to 52);
 signal ex6_frac_lod_ear :std_ulogic_vector(0 to 52);
 signal ex6_frac_lod_dly :std_ulogic_vector(0 to 52);
  signal rf1_a_expo_pre1_b :std_ulogic_vector(1 to 13);
  signal rf1_c_expo_pre1_b :std_ulogic_vector(1 to 13);
  signal rf1_b_expo_pre1_b :std_ulogic_vector(1 to 13);
  signal rf1_a_expo_pre2_b :std_ulogic_vector(1 to 13);
  signal rf1_c_expo_pre2_b :std_ulogic_vector(1 to 13);
  signal rf1_b_expo_pre2_b :std_ulogic_vector(1 to 13);
  signal rf1_a_expo_pre3_b :std_ulogic_vector(1 to 13);
  signal rf1_c_expo_pre3_b :std_ulogic_vector(1 to 13);
  signal rf1_b_expo_pre3_b :std_ulogic_vector(1 to 13);
  signal rf1_a_expo_pre    :std_ulogic_vector(1 to 13);
  signal rf1_c_expo_pre    :std_ulogic_vector(1 to 13);
  signal rf1_b_expo_pre    :std_ulogic_vector(1 to 13);
  signal rf1_a_frac_pre :std_ulogic_vector(0 to 52);
  signal rf1_c_frac_pre :std_ulogic_vector(0 to 52);
  signal rf1_b_frac_pre :std_ulogic_vector(0 to 52);
       signal rf1_a_frac_pre1_b :std_ulogic_vector(0 to 52);
       signal rf1_a_frac_pre2_b :std_ulogic_vector(0 to 52);
       signal rf1_c_frac_pre1_b :std_ulogic_vector(0 to 52);
       signal rf1_c_frac_pre2_b :std_ulogic_vector(0 to 52);
       signal rf1_c_frac_pre3_b :std_ulogic_vector(0 to 52);
       signal rf1_b_frac_pre1_b :std_ulogic_vector(0 to 52);
       signal rf1_b_frac_pre2_b :std_ulogic_vector(0 to 52);
       signal rf1_b_frac_pre3_b :std_ulogic_vector(0 to 1);

  signal byp_ex1_d1clk, byp_ex1_d2clk :std_ulogic;
  signal byp_ex1_lclk  : clk_logic;
  signal rf1_c_frac_pre3_hulp_b ,rf1_hulp_sp , rf1_c_frac_pre_hulp  ,  rf1_c_frac_prebyp_hulp   :std_ulogic ;

   signal  temp_rf1_c_frac_mul  :std_ulogic_vector(0 to 53);
   signal  temp_rf1_a_frac_mul  :std_ulogic_vector(0 to 52);
   signal  temp_rf1_a_frac_mul_17  :std_ulogic;
   signal  temp_rf1_a_frac_mul_35  :std_ulogic;

-- synopsys translate_off








-- synopsys translate_on

 signal ex1_b_frac_alg :std_ulogic_vector(0 to 52);        
 signal ex1_b_frac_fmt :std_ulogic_vector(0 to 52);        
 signal ex1_a_frac_fmt :std_ulogic_vector(0 to 52);        
 signal ex1_c_frac_fmt :std_ulogic_vector(0 to 52);        
 signal ex1_b_sign_alg    :std_ulogic ;
 signal ex1_b_sign_fmt    :std_ulogic ;
 signal ex1_a_sign_fmt    :std_ulogic ;
 signal ex1_c_sign_fmt    :std_ulogic ;
 signal ex1_b_sign_pic    :std_ulogic ;
 signal ex1_a_sign_pic    :std_ulogic ;
 signal ex1_c_sign_pic    :std_ulogic ;
 signal ex1_b_expo_alg    :std_ulogic_vector(1 to 13) ;
 signal ex1_a_expo_alg    :std_ulogic_vector(1 to 13) ;
 signal ex1_c_expo_alg    :std_ulogic_vector(1 to 13) ;
 signal ex1_b_expo_fmt    :std_ulogic_vector(1 to 13) ;
 signal ex1_a_expo_fmt    :std_ulogic_vector(1 to 13) ;
 signal ex1_c_expo_fmt    :std_ulogic_vector(1 to 13) ;
 signal ex1_b_expo_eie    :std_ulogic_vector(1 to 13) ;
 signal ex1_a_expo_eie    :std_ulogic_vector(1 to 13) ;
 signal ex1_c_expo_eie    :std_ulogic_vector(1 to 13) ;


  

begin

  unused <= rf1_a_expo_pre3_b(1) or rf1_a_expo_pre3_b(2) or 
            rf1_c_expo_pre3_b(1) or rf1_c_expo_pre3_b(2) or rf1_c_expo_pre3_b(3) or 
            rf1_b_expo_pre3_b(1) or rf1_b_expo_pre3_b(2) or rf1_b_expo_pre3_b(3) or
            rf1_a_k_expo(1) or rf1_a_k_expo(2) or
            or_reduce( rf1_c_k_expo(1 to 12) ) or 
            or_reduce( rf1_b_k_expo(1 to 3) )  or
            or_reduce( rf1_a_k_frac(0 to 52) ) or 
            or_reduce( rf1_b_k_frac(2 to 52) ) ;


--#=##############################################################
--# pervasive
--#=##############################################################

    
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



--#=##############################################################
--# act
--#=##############################################################


    act_lat:  tri_rlmreg_p generic map (width=> 4, expand_type => expand_type, needs_sreset => 0 ) port map ( 
        delay_lclkr =>  delay_lclkr ,-- tidn ,--in
        mpw1_b      =>  mpw1_b      ,-- tidn ,--in
        mpw2_b      =>  mpw2_b      ,-- tidn ,--in
        forcee => forcee,-- tidn ,--in

        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => act_so  ,                      
        scin             => act_si  ,                    
        -------------------
         din(0)             => spare_unused(0),
         din(1)             => spare_unused(1),
         din(2)             => spare_unused(2),
         din(3)             => spare_unused(3),
        -------------------
        dout(0)             => spare_unused(0),
        dout(1)             => spare_unused(1),
        dout(2)             => spare_unused(2) ,
        dout(3)             => spare_unused(3) );


    byp_ex1_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        delay_lclkr =>  delay_lclkr ,-- tidn ,--in
        mpw1_b      =>  mpw1_b      ,-- tidn ,--in
        mpw2_b      =>  mpw2_b      ,-- tidn ,--in
        forcee => forcee,-- tidn ,--in
        nclk        =>  nclk                 ,--in
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        act         =>  rf1_act              ,--in
        sg          =>  sg_0                 ,--in
        thold_b     =>  thold_0_b            ,--in
        d1clk       =>  byp_ex1_d1clk        ,--out
        d2clk       =>  byp_ex1_d2clk        ,--out
        lclk        =>  byp_ex1_lclk        );--out




--=================================================
-- Constants for the immediate data
--=================================================

      rf1_a_k_expo(1 to  2) <= tidn & tidn ;
      rf1_a_k_expo(3 to 13) <=
             ( (3 to 13=> not f_dcd_rf1_to_integer_b) and  k_toint  (3 to 13) ) or 
             ( (3 to 13=>     f_dcd_rf1_emin_dp     ) and  k_emin_dp(3 to 13) ) or 
             ( (3 to 13=>     f_dcd_rf1_emin_sp     ) and  k_emin_sp(3 to 13) ) ;


      rf1_c_k_expo(1 to  3) <= tidn & tidn & tidn ;
      rf1_c_k_expo(4 to 12) <= (4 to 12 => tiup);
      rf1_c_k_expo(13) <=
            ( not cop_uc_imm          and expo_bias(13)    ) or  -- non divide
            ( f_dcd_rf1_uc_fc_1_0     and expo_bias(13)    ) or  -- div/sqrt
            ( f_dcd_rf1_uc_fc_0_5     and expo_bias_m1(13) ) or  -- div/sqrt
            ( f_dcd_rf1_uc_fc_1_minus and expo_bias_m1(13) ) ;   -- div/sqrt

      rf1_b_k_expo(1 to  3) <= tidn & tidn & tidn ;
      rf1_b_k_expo(4 to 13) <=
            ( (4 to 13=> not bop_uc_imm      ) and expo_zero(4 to 13)    ) or  -- non divide
            ( (4 to 13=> f_dcd_rf1_uc_fb_1_0 ) and expo_bias(4 to 13)    ) or  -- div/sqrt
            ( (4 to 13=> f_dcd_rf1_uc_fb_0_5 ) and expo_bias_m1(4 to 13) ) or  -- div/sqrt
            ( (4 to 13=> f_dcd_rf1_uc_fb_0_75) and expo_bias_m1(4 to 13) ) ;   -- div/sqrt


      rf1_a_k_frac(0 to 52) <= tidn & (1 to 52 => tidn);

      -- c is invalid for divide , a is valid ... but want multiplier output to be zero for divide first step (prenorm)
      rf1_c_k_frac(0)       <= not f_dcd_rf1_div_beg ; -- tiup ;
      rf1_c_k_frac(1 to 52) <= (1 to 52 => f_dcd_rf1_uc_fc_1_minus);
            
      rf1_b_k_frac(0)       <= bop_uc_imm ;
      rf1_b_k_frac(1)       <= f_dcd_rf1_uc_fb_0_75 ;
      rf1_b_k_frac(2 to 52) <= (2 to 52 => tidn);


 --=====================================================================
 -- selects for operand bypass muxes (also known as: data forwarding )
 --=====================================================================


      -- forcing invalid causes selection of immediate data

      cop_uc_imm  <= f_dcd_rf1_uc_fc_0_5 or f_dcd_rf1_uc_fc_1_0 or f_dcd_rf1_uc_fc_1_minus ;
      bop_uc_imm  <= f_dcd_rf1_uc_fb_0_5 or f_dcd_rf1_uc_fb_1_0 or f_dcd_rf1_uc_fb_0_75 ;


      aop_valid_sign <= (f_dcd_rf1_aop_valid and not f_dcd_rf1_uc_fa_pos) ; 
      cop_valid_sign <= (f_dcd_rf1_cop_valid and not f_dcd_rf1_uc_fc_pos and not cop_uc_imm) ;
      bop_valid_sign <= (f_dcd_rf1_bop_valid and not f_dcd_rf1_uc_fb_pos and not bop_uc_imm) ;

      aop_valid_plus <= (f_dcd_rf1_aop_valid ); 
      cop_valid_plus <= (f_dcd_rf1_cop_valid and not cop_uc_imm);
      bop_valid_plus <= (f_dcd_rf1_bop_valid and not bop_uc_imm);

      sel_a_no_byp_s  <= not( f_dcd_rf1_bypsel_a_res0 or f_dcd_rf1_bypsel_a_res1 or f_dcd_rf1_bypsel_a_load0 or f_dcd_rf1_bypsel_a_load1 or not aop_valid_sign);     
      sel_c_no_byp_s  <= not( f_dcd_rf1_bypsel_c_res0 or f_dcd_rf1_bypsel_c_res1 or f_dcd_rf1_bypsel_c_load0 or f_dcd_rf1_bypsel_c_load1 or not cop_valid_sign);     
      sel_b_no_byp_s  <= not( f_dcd_rf1_bypsel_b_res0 or f_dcd_rf1_bypsel_b_res1 or f_dcd_rf1_bypsel_b_load0 or f_dcd_rf1_bypsel_b_load1 or not bop_valid_sign);     

      sel_a_no_byp  <= not( f_dcd_rf1_bypsel_a_res0 or f_dcd_rf1_bypsel_a_res1 or f_dcd_rf1_bypsel_a_load0 or f_dcd_rf1_bypsel_a_load1 or not aop_valid_plus);     
      sel_c_no_byp  <= not( f_dcd_rf1_bypsel_c_res0 or f_dcd_rf1_bypsel_c_res1 or f_dcd_rf1_bypsel_c_load0 or f_dcd_rf1_bypsel_c_load1 or not cop_valid_plus);     
      sel_b_no_byp  <= not( f_dcd_rf1_bypsel_b_res0 or f_dcd_rf1_bypsel_b_res1 or f_dcd_rf1_bypsel_b_load0 or f_dcd_rf1_bypsel_b_load1 or not bop_valid_plus);     


      sel_a_res0_s  <=     aop_valid_sign and f_dcd_rf1_bypsel_a_res0  ;
      sel_a_res1_s  <=     aop_valid_sign and f_dcd_rf1_bypsel_a_res1  ;
      sel_a_load0_s <=     aop_valid_sign and f_dcd_rf1_bypsel_a_load0 ;
      sel_a_load1_s <=     aop_valid_sign and f_dcd_rf1_bypsel_a_load1 ;

      sel_c_res0_s  <=     cop_valid_sign and f_dcd_rf1_bypsel_c_res0  ;
      sel_c_res1_s  <=     cop_valid_sign and f_dcd_rf1_bypsel_c_res1  ;
      sel_c_load0_s <=     cop_valid_sign and f_dcd_rf1_bypsel_c_load0 ;
      sel_c_load1_s <=     cop_valid_sign and f_dcd_rf1_bypsel_c_load1 ;
  
      sel_b_res0_s  <=     bop_valid_sign and f_dcd_rf1_bypsel_b_res0  ;
      sel_b_res1_s  <=     bop_valid_sign and f_dcd_rf1_bypsel_b_res1  ;
      sel_b_load0_s <=     bop_valid_sign and f_dcd_rf1_bypsel_b_load0 ;
      sel_b_load1_s <=     bop_valid_sign and f_dcd_rf1_bypsel_b_load1 ;

      sel_a_imm   <= not aop_valid_plus ;
      sel_a_res0  <=     aop_valid_plus and f_dcd_rf1_bypsel_a_res0  ;
      sel_a_res1  <=     aop_valid_plus and f_dcd_rf1_bypsel_a_res1  ;
      sel_a_load0 <=     aop_valid_plus and f_dcd_rf1_bypsel_a_load0 ;
      sel_a_load1 <=     aop_valid_plus and f_dcd_rf1_bypsel_a_load1 ;

      sel_c_imm   <= not cop_valid_plus ;
      sel_c_res0  <=     cop_valid_plus and f_dcd_rf1_bypsel_c_res0  ;
      sel_c_res1  <=     cop_valid_plus and f_dcd_rf1_bypsel_c_res1  ;
      sel_c_load0 <=     cop_valid_plus and f_dcd_rf1_bypsel_c_load0 ;
      sel_c_load1 <=     cop_valid_plus and f_dcd_rf1_bypsel_c_load1 ;

      sel_b_imm   <= not bop_valid_plus ;
      sel_b_res0  <=     bop_valid_plus and f_dcd_rf1_bypsel_b_res0  ;
      sel_b_res1  <=     bop_valid_plus and f_dcd_rf1_bypsel_b_res1  ;
      sel_b_load0 <=     bop_valid_plus and f_dcd_rf1_bypsel_b_load0 ;
      sel_b_load1 <=     bop_valid_plus and f_dcd_rf1_bypsel_b_load1 ;

      
       --------------------------
       -- sign bit data forwarding
       --------------------------

                  ex6_sign_res_ear  <=  f_rnd_ex6_res_sign; 
                  ex6_sign_res_dly  <=  f_fpr_ex7_frt_sign;
                  ex6_sign_lod_ear  <=  f_fpr_ex6_load_sign;
                  ex6_sign_lod_dly  <=  f_fpr_ex7_load_sign;

fwd_a_sign_pre1:  rf1_a_sign_pre1_b <= not( ( sel_a_res0_s  and  ex6_sign_res_ear  ) or ( sel_a_res1_s  and  ex6_sign_res_dly  )  ); 
fwd_a_sign_pre2:  rf1_a_sign_pre2_b <= not( ( sel_a_load0_s and  ex6_sign_lod_ear  ) or ( sel_a_load1_s and  ex6_sign_lod_dly  )  );
fwd_a_sign_pre:   rf1_a_sign_pre    <= not(  rf1_a_sign_pre1_b and rf1_a_sign_pre2_b );

fwd_c_sign_pre1:  rf1_c_sign_pre1_b <= not( ( sel_c_res0_s  and  ex6_sign_res_ear  ) or ( sel_c_res1_s  and  ex6_sign_res_dly  ) ); 
fwd_c_sign_pre2:  rf1_c_sign_pre2_b <= not( ( sel_c_load0_s and  ex6_sign_lod_ear  ) or ( sel_c_load1_s and  ex6_sign_lod_dly  ) ); 
fwd_c_sign_pre:   rf1_c_sign_pre    <= not( rf1_c_sign_pre1_b and rf1_c_sign_pre2_b );
                                 
fwd_b_sign_pre1:  rf1_b_sign_pre1_b <= not( ( sel_b_res0_s  and  ex6_sign_res_ear  ) or ( sel_b_res1_s  and  ex6_sign_res_dly  ) ); 
fwd_b_sign_pre2:  rf1_b_sign_pre2_b <= not( ( sel_b_load0_s and  ex6_sign_lod_ear  ) or ( sel_b_load1_s and  ex6_sign_lod_dly  ) );
fwd_b_sign_pre:   rf1_b_sign_pre    <= not( rf1_b_sign_pre1_b and rf1_b_sign_pre2_b );

                  rf1_a_sign_prebyp <= rf1_a_sign_pre ; -- may need to manually rebuffer
                  rf1_c_sign_prebyp <= rf1_c_sign_pre ; -- may need to manually rebuffer
                  rf1_b_sign_prebyp <= rf1_b_sign_pre ; -- may need to manually rebuffer

       --------------------------
       -- exponent data forwarding
       --------------------------

       ex6_load_expo(1 to 13)    <= tidn & tidn & f_fpr_ex6_load_expo(3 to 13) ; 
       ex6_expo_res_ear(1 to 13) <= f_rnd_ex6_res_expo(1 to 13);
       ex6_expo_res_dly(1 to 13) <= f_fpr_ex7_frt_expo(1 to 13);
       ex6_expo_lod_ear(1 to 13) <=      ex6_load_expo(1 to 13);
       ex6_expo_lod_dly(1 to 13) <= tidn & tidn & f_fpr_ex7_load_expo(3 to 13) ;


fwd_a_expo_pre1_01:  rf1_a_expo_pre1_b( 1) <= not( ( sel_a_res0 and ex6_expo_res_ear( 1) ) or  ( sel_a_res1 and ex6_expo_res_dly( 1) ) );
fwd_a_expo_pre1_02:  rf1_a_expo_pre1_b( 2) <= not( ( sel_a_res0 and ex6_expo_res_ear( 2) ) or  ( sel_a_res1 and ex6_expo_res_dly( 2) ) );
fwd_a_expo_pre1_03:  rf1_a_expo_pre1_b( 3) <= not( ( sel_a_res0 and ex6_expo_res_ear( 3) ) or  ( sel_a_res1 and ex6_expo_res_dly( 3) ) );
fwd_a_expo_pre1_04:  rf1_a_expo_pre1_b( 4) <= not( ( sel_a_res0 and ex6_expo_res_ear( 4) ) or  ( sel_a_res1 and ex6_expo_res_dly( 4) ) );
fwd_a_expo_pre1_05:  rf1_a_expo_pre1_b( 5) <= not( ( sel_a_res0 and ex6_expo_res_ear( 5) ) or  ( sel_a_res1 and ex6_expo_res_dly( 5) ) );
fwd_a_expo_pre1_06:  rf1_a_expo_pre1_b( 6) <= not( ( sel_a_res0 and ex6_expo_res_ear( 6) ) or  ( sel_a_res1 and ex6_expo_res_dly( 6) ) );
fwd_a_expo_pre1_07:  rf1_a_expo_pre1_b( 7) <= not( ( sel_a_res0 and ex6_expo_res_ear( 7) ) or  ( sel_a_res1 and ex6_expo_res_dly( 7) ) );
fwd_a_expo_pre1_08:  rf1_a_expo_pre1_b( 8) <= not( ( sel_a_res0 and ex6_expo_res_ear( 8) ) or  ( sel_a_res1 and ex6_expo_res_dly( 8) ) );
fwd_a_expo_pre1_09:  rf1_a_expo_pre1_b( 9) <= not( ( sel_a_res0 and ex6_expo_res_ear( 9) ) or  ( sel_a_res1 and ex6_expo_res_dly( 9) ) );
fwd_a_expo_pre1_10:  rf1_a_expo_pre1_b(10) <= not( ( sel_a_res0 and ex6_expo_res_ear(10) ) or  ( sel_a_res1 and ex6_expo_res_dly(10) ) );
fwd_a_expo_pre1_11:  rf1_a_expo_pre1_b(11) <= not( ( sel_a_res0 and ex6_expo_res_ear(11) ) or  ( sel_a_res1 and ex6_expo_res_dly(11) ) );
fwd_a_expo_pre1_12:  rf1_a_expo_pre1_b(12) <= not( ( sel_a_res0 and ex6_expo_res_ear(12) ) or  ( sel_a_res1 and ex6_expo_res_dly(12) ) );
fwd_a_expo_pre1_13:  rf1_a_expo_pre1_b(13) <= not( ( sel_a_res0 and ex6_expo_res_ear(13) ) or  ( sel_a_res1 and ex6_expo_res_dly(13) ) );

fwd_c_expo_pre1_01:  rf1_c_expo_pre1_b( 1) <= not( ( sel_c_res0 and ex6_expo_res_ear( 1) ) or  ( sel_c_res1 and ex6_expo_res_dly( 1) ) );
fwd_c_expo_pre1_02:  rf1_c_expo_pre1_b( 2) <= not( ( sel_c_res0 and ex6_expo_res_ear( 2) ) or  ( sel_c_res1 and ex6_expo_res_dly( 2) ) );
fwd_c_expo_pre1_03:  rf1_c_expo_pre1_b( 3) <= not( ( sel_c_res0 and ex6_expo_res_ear( 3) ) or  ( sel_c_res1 and ex6_expo_res_dly( 3) ) );
fwd_c_expo_pre1_04:  rf1_c_expo_pre1_b( 4) <= not( ( sel_c_res0 and ex6_expo_res_ear( 4) ) or  ( sel_c_res1 and ex6_expo_res_dly( 4) ) );
fwd_c_expo_pre1_05:  rf1_c_expo_pre1_b( 5) <= not( ( sel_c_res0 and ex6_expo_res_ear( 5) ) or  ( sel_c_res1 and ex6_expo_res_dly( 5) ) );
fwd_c_expo_pre1_06:  rf1_c_expo_pre1_b( 6) <= not( ( sel_c_res0 and ex6_expo_res_ear( 6) ) or  ( sel_c_res1 and ex6_expo_res_dly( 6) ) );
fwd_c_expo_pre1_07:  rf1_c_expo_pre1_b( 7) <= not( ( sel_c_res0 and ex6_expo_res_ear( 7) ) or  ( sel_c_res1 and ex6_expo_res_dly( 7) ) );
fwd_c_expo_pre1_08:  rf1_c_expo_pre1_b( 8) <= not( ( sel_c_res0 and ex6_expo_res_ear( 8) ) or  ( sel_c_res1 and ex6_expo_res_dly( 8) ) );
fwd_c_expo_pre1_09:  rf1_c_expo_pre1_b( 9) <= not( ( sel_c_res0 and ex6_expo_res_ear( 9) ) or  ( sel_c_res1 and ex6_expo_res_dly( 9) ) );
fwd_c_expo_pre1_10:  rf1_c_expo_pre1_b(10) <= not( ( sel_c_res0 and ex6_expo_res_ear(10) ) or  ( sel_c_res1 and ex6_expo_res_dly(10) ) );
fwd_c_expo_pre1_11:  rf1_c_expo_pre1_b(11) <= not( ( sel_c_res0 and ex6_expo_res_ear(11) ) or  ( sel_c_res1 and ex6_expo_res_dly(11) ) );
fwd_c_expo_pre1_12:  rf1_c_expo_pre1_b(12) <= not( ( sel_c_res0 and ex6_expo_res_ear(12) ) or  ( sel_c_res1 and ex6_expo_res_dly(12) ) );
fwd_c_expo_pre1_13:  rf1_c_expo_pre1_b(13) <= not( ( sel_c_res0 and ex6_expo_res_ear(13) ) or  ( sel_c_res1 and ex6_expo_res_dly(13) ) );

fwd_b_expo_pre1_01:  rf1_b_expo_pre1_b( 1) <= not( ( sel_b_res0 and ex6_expo_res_ear( 1) ) or  ( sel_b_res1 and ex6_expo_res_dly( 1) ) );
fwd_b_expo_pre1_02:  rf1_b_expo_pre1_b( 2) <= not( ( sel_b_res0 and ex6_expo_res_ear( 2) ) or  ( sel_b_res1 and ex6_expo_res_dly( 2) ) );
fwd_b_expo_pre1_03:  rf1_b_expo_pre1_b( 3) <= not( ( sel_b_res0 and ex6_expo_res_ear( 3) ) or  ( sel_b_res1 and ex6_expo_res_dly( 3) ) );
fwd_b_expo_pre1_04:  rf1_b_expo_pre1_b( 4) <= not( ( sel_b_res0 and ex6_expo_res_ear( 4) ) or  ( sel_b_res1 and ex6_expo_res_dly( 4) ) );
fwd_b_expo_pre1_05:  rf1_b_expo_pre1_b( 5) <= not( ( sel_b_res0 and ex6_expo_res_ear( 5) ) or  ( sel_b_res1 and ex6_expo_res_dly( 5) ) );
fwd_b_expo_pre1_06:  rf1_b_expo_pre1_b( 6) <= not( ( sel_b_res0 and ex6_expo_res_ear( 6) ) or  ( sel_b_res1 and ex6_expo_res_dly( 6) ) );
fwd_b_expo_pre1_07:  rf1_b_expo_pre1_b( 7) <= not( ( sel_b_res0 and ex6_expo_res_ear( 7) ) or  ( sel_b_res1 and ex6_expo_res_dly( 7) ) );
fwd_b_expo_pre1_08:  rf1_b_expo_pre1_b( 8) <= not( ( sel_b_res0 and ex6_expo_res_ear( 8) ) or  ( sel_b_res1 and ex6_expo_res_dly( 8) ) );
fwd_b_expo_pre1_09:  rf1_b_expo_pre1_b( 9) <= not( ( sel_b_res0 and ex6_expo_res_ear( 9) ) or  ( sel_b_res1 and ex6_expo_res_dly( 9) ) );
fwd_b_expo_pre1_10:  rf1_b_expo_pre1_b(10) <= not( ( sel_b_res0 and ex6_expo_res_ear(10) ) or  ( sel_b_res1 and ex6_expo_res_dly(10) ) );
fwd_b_expo_pre1_11:  rf1_b_expo_pre1_b(11) <= not( ( sel_b_res0 and ex6_expo_res_ear(11) ) or  ( sel_b_res1 and ex6_expo_res_dly(11) ) );
fwd_b_expo_pre1_12:  rf1_b_expo_pre1_b(12) <= not( ( sel_b_res0 and ex6_expo_res_ear(12) ) or  ( sel_b_res1 and ex6_expo_res_dly(12) ) );
fwd_b_expo_pre1_13:  rf1_b_expo_pre1_b(13) <= not( ( sel_b_res0 and ex6_expo_res_ear(13) ) or  ( sel_b_res1 and ex6_expo_res_dly(13) ) );


fwd_a_expo_pre2_01:  rf1_a_expo_pre2_b( 1) <= not( (sel_a_load0 and ex6_expo_lod_ear( 1) ) or  (sel_a_load1 and ex6_expo_lod_dly( 1) ) );
fwd_a_expo_pre2_02:  rf1_a_expo_pre2_b( 2) <= not( (sel_a_load0 and ex6_expo_lod_ear( 2) ) or  (sel_a_load1 and ex6_expo_lod_dly( 2) ) );
fwd_a_expo_pre2_03:  rf1_a_expo_pre2_b( 3) <= not( (sel_a_load0 and ex6_expo_lod_ear( 3) ) or  (sel_a_load1 and ex6_expo_lod_dly( 3) ) );
fwd_a_expo_pre2_04:  rf1_a_expo_pre2_b( 4) <= not( (sel_a_load0 and ex6_expo_lod_ear( 4) ) or  (sel_a_load1 and ex6_expo_lod_dly( 4) ) );
fwd_a_expo_pre2_05:  rf1_a_expo_pre2_b( 5) <= not( (sel_a_load0 and ex6_expo_lod_ear( 5) ) or  (sel_a_load1 and ex6_expo_lod_dly( 5) ) );
fwd_a_expo_pre2_06:  rf1_a_expo_pre2_b( 6) <= not( (sel_a_load0 and ex6_expo_lod_ear( 6) ) or  (sel_a_load1 and ex6_expo_lod_dly( 6) ) );
fwd_a_expo_pre2_07:  rf1_a_expo_pre2_b( 7) <= not( (sel_a_load0 and ex6_expo_lod_ear( 7) ) or  (sel_a_load1 and ex6_expo_lod_dly( 7) ) );
fwd_a_expo_pre2_08:  rf1_a_expo_pre2_b( 8) <= not( (sel_a_load0 and ex6_expo_lod_ear( 8) ) or  (sel_a_load1 and ex6_expo_lod_dly( 8) ) );
fwd_a_expo_pre2_09:  rf1_a_expo_pre2_b( 9) <= not( (sel_a_load0 and ex6_expo_lod_ear( 9) ) or  (sel_a_load1 and ex6_expo_lod_dly( 9) ) );
fwd_a_expo_pre2_10:  rf1_a_expo_pre2_b(10) <= not( (sel_a_load0 and ex6_expo_lod_ear(10) ) or  (sel_a_load1 and ex6_expo_lod_dly(10) ) );
fwd_a_expo_pre2_11:  rf1_a_expo_pre2_b(11) <= not( (sel_a_load0 and ex6_expo_lod_ear(11) ) or  (sel_a_load1 and ex6_expo_lod_dly(11) ) );
fwd_a_expo_pre2_12:  rf1_a_expo_pre2_b(12) <= not( (sel_a_load0 and ex6_expo_lod_ear(12) ) or  (sel_a_load1 and ex6_expo_lod_dly(12) ) );
fwd_a_expo_pre2_13:  rf1_a_expo_pre2_b(13) <= not( (sel_a_load0 and ex6_expo_lod_ear(13) ) or  (sel_a_load1 and ex6_expo_lod_dly(13) ) );

fwd_c_expo_pre2_01:  rf1_c_expo_pre2_b( 1) <= not( (sel_c_load0 and ex6_expo_lod_ear( 1) ) or  (sel_c_load1 and ex6_expo_lod_dly( 1) ) );
fwd_c_expo_pre2_02:  rf1_c_expo_pre2_b( 2) <= not( (sel_c_load0 and ex6_expo_lod_ear( 2) ) or  (sel_c_load1 and ex6_expo_lod_dly( 2) ) );
fwd_c_expo_pre2_03:  rf1_c_expo_pre2_b( 3) <= not( (sel_c_load0 and ex6_expo_lod_ear( 3) ) or  (sel_c_load1 and ex6_expo_lod_dly( 3) ) );
fwd_c_expo_pre2_04:  rf1_c_expo_pre2_b( 4) <= not( (sel_c_load0 and ex6_expo_lod_ear( 4) ) or  (sel_c_load1 and ex6_expo_lod_dly( 4) ) );
fwd_c_expo_pre2_05:  rf1_c_expo_pre2_b( 5) <= not( (sel_c_load0 and ex6_expo_lod_ear( 5) ) or  (sel_c_load1 and ex6_expo_lod_dly( 5) ) );
fwd_c_expo_pre2_06:  rf1_c_expo_pre2_b( 6) <= not( (sel_c_load0 and ex6_expo_lod_ear( 6) ) or  (sel_c_load1 and ex6_expo_lod_dly( 6) ) );
fwd_c_expo_pre2_07:  rf1_c_expo_pre2_b( 7) <= not( (sel_c_load0 and ex6_expo_lod_ear( 7) ) or  (sel_c_load1 and ex6_expo_lod_dly( 7) ) );
fwd_c_expo_pre2_08:  rf1_c_expo_pre2_b( 8) <= not( (sel_c_load0 and ex6_expo_lod_ear( 8) ) or  (sel_c_load1 and ex6_expo_lod_dly( 8) ) );
fwd_c_expo_pre2_09:  rf1_c_expo_pre2_b( 9) <= not( (sel_c_load0 and ex6_expo_lod_ear( 9) ) or  (sel_c_load1 and ex6_expo_lod_dly( 9) ) );
fwd_c_expo_pre2_10:  rf1_c_expo_pre2_b(10) <= not( (sel_c_load0 and ex6_expo_lod_ear(10) ) or  (sel_c_load1 and ex6_expo_lod_dly(10) ) );
fwd_c_expo_pre2_11:  rf1_c_expo_pre2_b(11) <= not( (sel_c_load0 and ex6_expo_lod_ear(11) ) or  (sel_c_load1 and ex6_expo_lod_dly(11) ) );
fwd_c_expo_pre2_12:  rf1_c_expo_pre2_b(12) <= not( (sel_c_load0 and ex6_expo_lod_ear(12) ) or  (sel_c_load1 and ex6_expo_lod_dly(12) ) );
fwd_c_expo_pre2_13:  rf1_c_expo_pre2_b(13) <= not( (sel_c_load0 and ex6_expo_lod_ear(13) ) or  (sel_c_load1 and ex6_expo_lod_dly(13) ) );

fwd_b_expo_pre2_01:  rf1_b_expo_pre2_b( 1) <= not( (sel_b_load0 and ex6_expo_lod_ear( 1) ) or  (sel_b_load1 and ex6_expo_lod_dly( 1) ) );
fwd_b_expo_pre2_02:  rf1_b_expo_pre2_b( 2) <= not( (sel_b_load0 and ex6_expo_lod_ear( 2) ) or  (sel_b_load1 and ex6_expo_lod_dly( 2) ) );
fwd_b_expo_pre2_03:  rf1_b_expo_pre2_b( 3) <= not( (sel_b_load0 and ex6_expo_lod_ear( 3) ) or  (sel_b_load1 and ex6_expo_lod_dly( 3) ) );
fwd_b_expo_pre2_04:  rf1_b_expo_pre2_b( 4) <= not( (sel_b_load0 and ex6_expo_lod_ear( 4) ) or  (sel_b_load1 and ex6_expo_lod_dly( 4) ) );
fwd_b_expo_pre2_05:  rf1_b_expo_pre2_b( 5) <= not( (sel_b_load0 and ex6_expo_lod_ear( 5) ) or  (sel_b_load1 and ex6_expo_lod_dly( 5) ) );
fwd_b_expo_pre2_06:  rf1_b_expo_pre2_b( 6) <= not( (sel_b_load0 and ex6_expo_lod_ear( 6) ) or  (sel_b_load1 and ex6_expo_lod_dly( 6) ) );
fwd_b_expo_pre2_07:  rf1_b_expo_pre2_b( 7) <= not( (sel_b_load0 and ex6_expo_lod_ear( 7) ) or  (sel_b_load1 and ex6_expo_lod_dly( 7) ) );
fwd_b_expo_pre2_08:  rf1_b_expo_pre2_b( 8) <= not( (sel_b_load0 and ex6_expo_lod_ear( 8) ) or  (sel_b_load1 and ex6_expo_lod_dly( 8) ) );
fwd_b_expo_pre2_09:  rf1_b_expo_pre2_b( 9) <= not( (sel_b_load0 and ex6_expo_lod_ear( 9) ) or  (sel_b_load1 and ex6_expo_lod_dly( 9) ) );
fwd_b_expo_pre2_10:  rf1_b_expo_pre2_b(10) <= not( (sel_b_load0 and ex6_expo_lod_ear(10) ) or  (sel_b_load1 and ex6_expo_lod_dly(10) ) );
fwd_b_expo_pre2_11:  rf1_b_expo_pre2_b(11) <= not( (sel_b_load0 and ex6_expo_lod_ear(11) ) or  (sel_b_load1 and ex6_expo_lod_dly(11) ) );
fwd_b_expo_pre2_12:  rf1_b_expo_pre2_b(12) <= not( (sel_b_load0 and ex6_expo_lod_ear(12) ) or  (sel_b_load1 and ex6_expo_lod_dly(12) ) );
fwd_b_expo_pre2_13:  rf1_b_expo_pre2_b(13) <= not( (sel_b_load0 and ex6_expo_lod_ear(13) ) or  (sel_b_load1 and ex6_expo_lod_dly(13) ) );




fwd_a_expo_pre3_01:   rf1_a_expo_pre3_b( 1) <= not( tidn  ); 
fwd_a_expo_pre3_02:   rf1_a_expo_pre3_b( 2) <= not( tidn  ); 
fwd_a_expo_pre3_03:   rf1_a_expo_pre3_b( 3) <= not( sel_a_imm and  rf1_a_k_expo( 3)  ); 
fwd_a_expo_pre3_04:   rf1_a_expo_pre3_b( 4) <= not( sel_a_imm and  rf1_a_k_expo( 4)  ); 
fwd_a_expo_pre3_05:   rf1_a_expo_pre3_b( 5) <= not( sel_a_imm and  rf1_a_k_expo( 5)  ); 
fwd_a_expo_pre3_06:   rf1_a_expo_pre3_b( 6) <= not( sel_a_imm and  rf1_a_k_expo( 6)  ); 
fwd_a_expo_pre3_07:   rf1_a_expo_pre3_b( 7) <= not( sel_a_imm and  rf1_a_k_expo( 7)  ); 
fwd_a_expo_pre3_08:   rf1_a_expo_pre3_b( 8) <= not( sel_a_imm and  rf1_a_k_expo( 8)  ); 
fwd_a_expo_pre3_09:   rf1_a_expo_pre3_b( 9) <= not( sel_a_imm and  rf1_a_k_expo( 9)  ); 
fwd_a_expo_pre3_10:   rf1_a_expo_pre3_b(10) <= not( sel_a_imm and  rf1_a_k_expo(10)  ); 
fwd_a_expo_pre3_11:   rf1_a_expo_pre3_b(11) <= not( sel_a_imm and  rf1_a_k_expo(11)  ); 
fwd_a_expo_pre3_12:   rf1_a_expo_pre3_b(12) <= not( sel_a_imm and  rf1_a_k_expo(12)  ); 
fwd_a_expo_pre3_13:   rf1_a_expo_pre3_b(13) <= not( sel_a_imm and  rf1_a_k_expo(13)  ); 

fwd_c_expo_pre3_01:   rf1_c_expo_pre3_b( 1) <= not( tidn   ); 
fwd_c_expo_pre3_02:   rf1_c_expo_pre3_b( 2) <= not( tidn   ); 
fwd_c_expo_pre3_03:   rf1_c_expo_pre3_b( 3) <= not( tidn   ); 
fwd_c_expo_pre3_04:   rf1_c_expo_pre3_b( 4) <= not( sel_c_imm ); 
fwd_c_expo_pre3_05:   rf1_c_expo_pre3_b( 5) <= not( sel_c_imm ); 
fwd_c_expo_pre3_06:   rf1_c_expo_pre3_b( 6) <= not( sel_c_imm ); 
fwd_c_expo_pre3_07:   rf1_c_expo_pre3_b( 7) <= not( sel_c_imm ); 
fwd_c_expo_pre3_08:   rf1_c_expo_pre3_b( 8) <= not( sel_c_imm ); 
fwd_c_expo_pre3_09:   rf1_c_expo_pre3_b( 9) <= not( sel_c_imm ); 
fwd_c_expo_pre3_10:   rf1_c_expo_pre3_b(10) <= not( sel_c_imm ); 
fwd_c_expo_pre3_11:   rf1_c_expo_pre3_b(11) <= not( sel_c_imm ); 
fwd_c_expo_pre3_12:   rf1_c_expo_pre3_b(12) <= not( sel_c_imm ); 
fwd_c_expo_pre3_13:   rf1_c_expo_pre3_b(13) <= not( sel_c_imm and  rf1_c_k_expo(13)  ); 

fwd_b_expo_pre3_01:   rf1_b_expo_pre3_b( 1) <= not( tidn  ); 
fwd_b_expo_pre3_02:   rf1_b_expo_pre3_b( 2) <= not( tidn  ); 
fwd_b_expo_pre3_03:   rf1_b_expo_pre3_b( 3) <= not( tidn  ); 
fwd_b_expo_pre3_04:   rf1_b_expo_pre3_b( 4) <= not( sel_b_imm and  rf1_b_k_expo( 4)  ); 
fwd_b_expo_pre3_05:   rf1_b_expo_pre3_b( 5) <= not( sel_b_imm and  rf1_b_k_expo( 5)  ); 
fwd_b_expo_pre3_06:   rf1_b_expo_pre3_b( 6) <= not( sel_b_imm and  rf1_b_k_expo( 6)  ); 
fwd_b_expo_pre3_07:   rf1_b_expo_pre3_b( 7) <= not( sel_b_imm and  rf1_b_k_expo( 7)  ); 
fwd_b_expo_pre3_08:   rf1_b_expo_pre3_b( 8) <= not( sel_b_imm and  rf1_b_k_expo( 8)  ); 
fwd_b_expo_pre3_09:   rf1_b_expo_pre3_b( 9) <= not( sel_b_imm and  rf1_b_k_expo( 9)  ); 
fwd_b_expo_pre3_10:   rf1_b_expo_pre3_b(10) <= not( sel_b_imm and  rf1_b_k_expo(10)  ); 
fwd_b_expo_pre3_11:   rf1_b_expo_pre3_b(11) <= not( sel_b_imm and  rf1_b_k_expo(11)  ); 
fwd_b_expo_pre3_12:   rf1_b_expo_pre3_b(12) <= not( sel_b_imm and  rf1_b_k_expo(12)  ); 
fwd_b_expo_pre3_13:   rf1_b_expo_pre3_b(13) <= not( sel_b_imm and  rf1_b_k_expo(13)  ); 


fwd_a_expo_pre_01: rf1_a_expo_pre( 1) <= not( rf1_a_expo_pre1_b( 1) and rf1_a_expo_pre2_b( 1)  );
fwd_a_expo_pre_02: rf1_a_expo_pre( 2) <= not( rf1_a_expo_pre1_b( 2) and rf1_a_expo_pre2_b( 2)  );
fwd_a_expo_pre_03: rf1_a_expo_pre( 3) <= not( rf1_a_expo_pre1_b( 3) and rf1_a_expo_pre2_b( 3) and rf1_a_expo_pre3_b( 3) );
fwd_a_expo_pre_04: rf1_a_expo_pre( 4) <= not( rf1_a_expo_pre1_b( 4) and rf1_a_expo_pre2_b( 4) and rf1_a_expo_pre3_b( 4) );
fwd_a_expo_pre_05: rf1_a_expo_pre( 5) <= not( rf1_a_expo_pre1_b( 5) and rf1_a_expo_pre2_b( 5) and rf1_a_expo_pre3_b( 5) );
fwd_a_expo_pre_06: rf1_a_expo_pre( 6) <= not( rf1_a_expo_pre1_b( 6) and rf1_a_expo_pre2_b( 6) and rf1_a_expo_pre3_b( 6) );
fwd_a_expo_pre_07: rf1_a_expo_pre( 7) <= not( rf1_a_expo_pre1_b( 7) and rf1_a_expo_pre2_b( 7) and rf1_a_expo_pre3_b( 7) );
fwd_a_expo_pre_08: rf1_a_expo_pre( 8) <= not( rf1_a_expo_pre1_b( 8) and rf1_a_expo_pre2_b( 8) and rf1_a_expo_pre3_b( 8) );
fwd_a_expo_pre_09: rf1_a_expo_pre( 9) <= not( rf1_a_expo_pre1_b( 9) and rf1_a_expo_pre2_b( 9) and rf1_a_expo_pre3_b( 9) );
fwd_a_expo_pre_10: rf1_a_expo_pre(10) <= not( rf1_a_expo_pre1_b(10) and rf1_a_expo_pre2_b(10) and rf1_a_expo_pre3_b(10) );
fwd_a_expo_pre_11: rf1_a_expo_pre(11) <= not( rf1_a_expo_pre1_b(11) and rf1_a_expo_pre2_b(11) and rf1_a_expo_pre3_b(11) );
fwd_a_expo_pre_12: rf1_a_expo_pre(12) <= not( rf1_a_expo_pre1_b(12) and rf1_a_expo_pre2_b(12) and rf1_a_expo_pre3_b(12) );
fwd_a_expo_pre_13: rf1_a_expo_pre(13) <= not( rf1_a_expo_pre1_b(13) and rf1_a_expo_pre2_b(13) and rf1_a_expo_pre3_b(13) );

fwd_c_expo_pre_01: rf1_c_expo_pre( 1) <= not( rf1_c_expo_pre1_b( 1) and rf1_c_expo_pre2_b( 1) );
fwd_c_expo_pre_02: rf1_c_expo_pre( 2) <= not( rf1_c_expo_pre1_b( 2) and rf1_c_expo_pre2_b( 2) );
fwd_c_expo_pre_03: rf1_c_expo_pre( 3) <= not( rf1_c_expo_pre1_b( 3) and rf1_c_expo_pre2_b( 3) );
fwd_c_expo_pre_04: rf1_c_expo_pre( 4) <= not( rf1_c_expo_pre1_b( 4) and rf1_c_expo_pre2_b( 4) and rf1_c_expo_pre3_b( 4) );
fwd_c_expo_pre_05: rf1_c_expo_pre( 5) <= not( rf1_c_expo_pre1_b( 5) and rf1_c_expo_pre2_b( 5) and rf1_c_expo_pre3_b( 5) );
fwd_c_expo_pre_06: rf1_c_expo_pre( 6) <= not( rf1_c_expo_pre1_b( 6) and rf1_c_expo_pre2_b( 6) and rf1_c_expo_pre3_b( 6) );
fwd_c_expo_pre_07: rf1_c_expo_pre( 7) <= not( rf1_c_expo_pre1_b( 7) and rf1_c_expo_pre2_b( 7) and rf1_c_expo_pre3_b( 7) );
fwd_c_expo_pre_08: rf1_c_expo_pre( 8) <= not( rf1_c_expo_pre1_b( 8) and rf1_c_expo_pre2_b( 8) and rf1_c_expo_pre3_b( 8) );
fwd_c_expo_pre_09: rf1_c_expo_pre( 9) <= not( rf1_c_expo_pre1_b( 9) and rf1_c_expo_pre2_b( 9) and rf1_c_expo_pre3_b( 9) );
fwd_c_expo_pre_10: rf1_c_expo_pre(10) <= not( rf1_c_expo_pre1_b(10) and rf1_c_expo_pre2_b(10) and rf1_c_expo_pre3_b(10) );
fwd_c_expo_pre_11: rf1_c_expo_pre(11) <= not( rf1_c_expo_pre1_b(11) and rf1_c_expo_pre2_b(11) and rf1_c_expo_pre3_b(11) );
fwd_c_expo_pre_12: rf1_c_expo_pre(12) <= not( rf1_c_expo_pre1_b(12) and rf1_c_expo_pre2_b(12) and rf1_c_expo_pre3_b(12) );
fwd_c_expo_pre_13: rf1_c_expo_pre(13) <= not( rf1_c_expo_pre1_b(13) and rf1_c_expo_pre2_b(13) and rf1_c_expo_pre3_b(13) );

fwd_b_expo_pre_01: rf1_b_expo_pre( 1) <= not( rf1_b_expo_pre1_b( 1) and rf1_b_expo_pre2_b( 1) );
fwd_b_expo_pre_02: rf1_b_expo_pre( 2) <= not( rf1_b_expo_pre1_b( 2) and rf1_b_expo_pre2_b( 2) );
fwd_b_expo_pre_03: rf1_b_expo_pre( 3) <= not( rf1_b_expo_pre1_b( 3) and rf1_b_expo_pre2_b( 3) );
fwd_b_expo_pre_04: rf1_b_expo_pre( 4) <= not( rf1_b_expo_pre1_b( 4) and rf1_b_expo_pre2_b( 4) and rf1_b_expo_pre3_b( 4) );
fwd_b_expo_pre_05: rf1_b_expo_pre( 5) <= not( rf1_b_expo_pre1_b( 5) and rf1_b_expo_pre2_b( 5) and rf1_b_expo_pre3_b( 5) );
fwd_b_expo_pre_06: rf1_b_expo_pre( 6) <= not( rf1_b_expo_pre1_b( 6) and rf1_b_expo_pre2_b( 6) and rf1_b_expo_pre3_b( 6) );
fwd_b_expo_pre_07: rf1_b_expo_pre( 7) <= not( rf1_b_expo_pre1_b( 7) and rf1_b_expo_pre2_b( 7) and rf1_b_expo_pre3_b( 7) );
fwd_b_expo_pre_08: rf1_b_expo_pre( 8) <= not( rf1_b_expo_pre1_b( 8) and rf1_b_expo_pre2_b( 8) and rf1_b_expo_pre3_b( 8) );
fwd_b_expo_pre_09: rf1_b_expo_pre( 9) <= not( rf1_b_expo_pre1_b( 9) and rf1_b_expo_pre2_b( 9) and rf1_b_expo_pre3_b( 9) );
fwd_b_expo_pre_10: rf1_b_expo_pre(10) <= not( rf1_b_expo_pre1_b(10) and rf1_b_expo_pre2_b(10) and rf1_b_expo_pre3_b(10) );
fwd_b_expo_pre_11: rf1_b_expo_pre(11) <= not( rf1_b_expo_pre1_b(11) and rf1_b_expo_pre2_b(11) and rf1_b_expo_pre3_b(11) );
fwd_b_expo_pre_12: rf1_b_expo_pre(12) <= not( rf1_b_expo_pre1_b(12) and rf1_b_expo_pre2_b(12) and rf1_b_expo_pre3_b(12) );
fwd_b_expo_pre_13: rf1_b_expo_pre(13) <= not( rf1_b_expo_pre1_b(13) and rf1_b_expo_pre2_b(13) and rf1_b_expo_pre3_b(13) );


                    rf1_a_expo_prebyp(1 to 13) <= rf1_a_expo_pre(1 to 13); -- may need to manually repower
                    rf1_c_expo_prebyp(1 to 13) <= rf1_c_expo_pre(1 to 13); -- may need to manually repower
                    rf1_b_expo_prebyp(1 to 13) <= rf1_b_expo_pre(1 to 13); -- may need to manually repower

       --------------------------
       -- fraction
       --------------------------

       ex6_frac_res_ear(0 to 52) <=  f_rnd_ex6_res_frac(0 to 52);
       ex6_frac_res_dly(0 to 52) <=  f_fpr_ex7_frt_frac(0 to 52); 
       ex6_frac_lod_ear(0 to 52) <= f_fpr_ex6_load_frac(0 to 52);
       ex6_frac_lod_dly(0 to 52) <= f_fpr_ex7_load_frac(0 to 52); 





fwd_c_frac_pre3_00: rf1_c_frac_pre3_b( 0) <= not( sel_c_imm and rf1_c_k_frac( 0) );
fwd_c_frac_pre3_01: rf1_c_frac_pre3_b( 1) <= not( sel_c_imm and rf1_c_k_frac( 1) );
fwd_c_frac_pre3_02: rf1_c_frac_pre3_b( 2) <= not( sel_c_imm and rf1_c_k_frac( 2) );
fwd_c_frac_pre3_03: rf1_c_frac_pre3_b( 3) <= not( sel_c_imm and rf1_c_k_frac( 3) );
fwd_c_frac_pre3_04: rf1_c_frac_pre3_b( 4) <= not( sel_c_imm and rf1_c_k_frac( 4) );
fwd_c_frac_pre3_05: rf1_c_frac_pre3_b( 5) <= not( sel_c_imm and rf1_c_k_frac( 5) );
fwd_c_frac_pre3_06: rf1_c_frac_pre3_b( 6) <= not( sel_c_imm and rf1_c_k_frac( 6) );
fwd_c_frac_pre3_07: rf1_c_frac_pre3_b( 7) <= not( sel_c_imm and rf1_c_k_frac( 7) );
fwd_c_frac_pre3_08: rf1_c_frac_pre3_b( 8) <= not( sel_c_imm and rf1_c_k_frac( 8) );
fwd_c_frac_pre3_09: rf1_c_frac_pre3_b( 9) <= not( sel_c_imm and rf1_c_k_frac( 9) );
fwd_c_frac_pre3_10: rf1_c_frac_pre3_b(10) <= not( sel_c_imm and rf1_c_k_frac(10) );
fwd_c_frac_pre3_11: rf1_c_frac_pre3_b(11) <= not( sel_c_imm and rf1_c_k_frac(11) );
fwd_c_frac_pre3_12: rf1_c_frac_pre3_b(12) <= not( sel_c_imm and rf1_c_k_frac(12) );
fwd_c_frac_pre3_13: rf1_c_frac_pre3_b(13) <= not( sel_c_imm and rf1_c_k_frac(13) );
fwd_c_frac_pre3_14: rf1_c_frac_pre3_b(14) <= not( sel_c_imm and rf1_c_k_frac(14) );
fwd_c_frac_pre3_15: rf1_c_frac_pre3_b(15) <= not( sel_c_imm and rf1_c_k_frac(15) );
fwd_c_frac_pre3_16: rf1_c_frac_pre3_b(16) <= not( sel_c_imm and rf1_c_k_frac(16) );
fwd_c_frac_pre3_17: rf1_c_frac_pre3_b(17) <= not( sel_c_imm and rf1_c_k_frac(17) );
fwd_c_frac_pre3_18: rf1_c_frac_pre3_b(18) <= not( sel_c_imm and rf1_c_k_frac(18) );
fwd_c_frac_pre3_19: rf1_c_frac_pre3_b(19) <= not( sel_c_imm and rf1_c_k_frac(19) );
fwd_c_frac_pre3_20: rf1_c_frac_pre3_b(20) <= not( sel_c_imm and rf1_c_k_frac(20) );
fwd_c_frac_pre3_21: rf1_c_frac_pre3_b(21) <= not( sel_c_imm and rf1_c_k_frac(21) );
fwd_c_frac_pre3_22: rf1_c_frac_pre3_b(22) <= not( sel_c_imm and rf1_c_k_frac(22) );
fwd_c_frac_pre3_23: rf1_c_frac_pre3_b(23) <= not( sel_c_imm and rf1_c_k_frac(23) );
fwd_c_frac_pre3_24: rf1_c_frac_pre3_b(24) <= not( sel_c_imm and rf1_c_k_frac(24) );
fwd_c_frac_pre3_25: rf1_c_frac_pre3_b(25) <= not( sel_c_imm and rf1_c_k_frac(25) );
fwd_c_frac_pre3_26: rf1_c_frac_pre3_b(26) <= not( sel_c_imm and rf1_c_k_frac(26) );
fwd_c_frac_pre3_27: rf1_c_frac_pre3_b(27) <= not( sel_c_imm and rf1_c_k_frac(27) );
fwd_c_frac_pre3_28: rf1_c_frac_pre3_b(28) <= not( sel_c_imm and rf1_c_k_frac(28) );
fwd_c_frac_pre3_29: rf1_c_frac_pre3_b(29) <= not( sel_c_imm and rf1_c_k_frac(29) );
fwd_c_frac_pre3_30: rf1_c_frac_pre3_b(30) <= not( sel_c_imm and rf1_c_k_frac(30) );
fwd_c_frac_pre3_31: rf1_c_frac_pre3_b(31) <= not( sel_c_imm and rf1_c_k_frac(31) );
fwd_c_frac_pre3_32: rf1_c_frac_pre3_b(32) <= not( sel_c_imm and rf1_c_k_frac(32) );
fwd_c_frac_pre3_33: rf1_c_frac_pre3_b(33) <= not( sel_c_imm and rf1_c_k_frac(33) );
fwd_c_frac_pre3_34: rf1_c_frac_pre3_b(34) <= not( sel_c_imm and rf1_c_k_frac(34) );
fwd_c_frac_pre3_35: rf1_c_frac_pre3_b(35) <= not( sel_c_imm and rf1_c_k_frac(35) );
fwd_c_frac_pre3_36: rf1_c_frac_pre3_b(36) <= not( sel_c_imm and rf1_c_k_frac(36) );
fwd_c_frac_pre3_37: rf1_c_frac_pre3_b(37) <= not( sel_c_imm and rf1_c_k_frac(37) );
fwd_c_frac_pre3_38: rf1_c_frac_pre3_b(38) <= not( sel_c_imm and rf1_c_k_frac(38) );
fwd_c_frac_pre3_39: rf1_c_frac_pre3_b(39) <= not( sel_c_imm and rf1_c_k_frac(39) );
fwd_c_frac_pre3_40: rf1_c_frac_pre3_b(40) <= not( sel_c_imm and rf1_c_k_frac(40) );
fwd_c_frac_pre3_41: rf1_c_frac_pre3_b(41) <= not( sel_c_imm and rf1_c_k_frac(41) );
fwd_c_frac_pre3_42: rf1_c_frac_pre3_b(42) <= not( sel_c_imm and rf1_c_k_frac(42) );
fwd_c_frac_pre3_43: rf1_c_frac_pre3_b(43) <= not( sel_c_imm and rf1_c_k_frac(43) );
fwd_c_frac_pre3_44: rf1_c_frac_pre3_b(44) <= not( sel_c_imm and rf1_c_k_frac(44) );
fwd_c_frac_pre3_45: rf1_c_frac_pre3_b(45) <= not( sel_c_imm and rf1_c_k_frac(45) );
fwd_c_frac_pre3_46: rf1_c_frac_pre3_b(46) <= not( sel_c_imm and rf1_c_k_frac(46) );
fwd_c_frac_pre3_47: rf1_c_frac_pre3_b(47) <= not( sel_c_imm and rf1_c_k_frac(47) );
fwd_c_frac_pre3_48: rf1_c_frac_pre3_b(48) <= not( sel_c_imm and rf1_c_k_frac(48) );
fwd_c_frac_pre3_49: rf1_c_frac_pre3_b(49) <= not( sel_c_imm and rf1_c_k_frac(49) );
fwd_c_frac_pre3_50: rf1_c_frac_pre3_b(50) <= not( sel_c_imm and rf1_c_k_frac(50) );
fwd_c_frac_pre3_51: rf1_c_frac_pre3_b(51) <= not( sel_c_imm and rf1_c_k_frac(51) );
fwd_c_frac_pre3_52: rf1_c_frac_pre3_b(52) <= not( sel_c_imm and rf1_c_k_frac(52) );

fwd_c_frac_pre3_24h: rf1_c_frac_pre3_hulp_b <= not( (sel_c_imm and rf1_c_k_frac(24)) or rf1_hulp_sp );

rf1_hulp_sp <= f_dcd_rf1_sp and  f_dcd_rf1_uc_fc_hulp ;


fwd_b_frac_pre3_00: rf1_b_frac_pre3_b( 0) <= not( sel_b_imm and rf1_b_k_frac( 0) );
fwd_b_frac_pre3_01: rf1_b_frac_pre3_b( 1) <= not( sel_b_imm and rf1_b_k_frac( 1) );



fwd_a_frac_pre1_00: rf1_a_frac_pre1_b( 0) <= not( (sel_a_res0 and ex6_frac_res_ear( 0) ) or (sel_a_res1 and ex6_frac_res_dly( 0) ) );
fwd_a_frac_pre1_01: rf1_a_frac_pre1_b( 1) <= not( (sel_a_res0 and ex6_frac_res_ear( 1) ) or (sel_a_res1 and ex6_frac_res_dly( 1) ) );
fwd_a_frac_pre1_02: rf1_a_frac_pre1_b( 2) <= not( (sel_a_res0 and ex6_frac_res_ear( 2) ) or (sel_a_res1 and ex6_frac_res_dly( 2) ) );
fwd_a_frac_pre1_03: rf1_a_frac_pre1_b( 3) <= not( (sel_a_res0 and ex6_frac_res_ear( 3) ) or (sel_a_res1 and ex6_frac_res_dly( 3) ) );
fwd_a_frac_pre1_04: rf1_a_frac_pre1_b( 4) <= not( (sel_a_res0 and ex6_frac_res_ear( 4) ) or (sel_a_res1 and ex6_frac_res_dly( 4) ) );
fwd_a_frac_pre1_05: rf1_a_frac_pre1_b( 5) <= not( (sel_a_res0 and ex6_frac_res_ear( 5) ) or (sel_a_res1 and ex6_frac_res_dly( 5) ) );
fwd_a_frac_pre1_06: rf1_a_frac_pre1_b( 6) <= not( (sel_a_res0 and ex6_frac_res_ear( 6) ) or (sel_a_res1 and ex6_frac_res_dly( 6) ) );
fwd_a_frac_pre1_07: rf1_a_frac_pre1_b( 7) <= not( (sel_a_res0 and ex6_frac_res_ear( 7) ) or (sel_a_res1 and ex6_frac_res_dly( 7) ) );
fwd_a_frac_pre1_08: rf1_a_frac_pre1_b( 8) <= not( (sel_a_res0 and ex6_frac_res_ear( 8) ) or (sel_a_res1 and ex6_frac_res_dly( 8) ) );
fwd_a_frac_pre1_09: rf1_a_frac_pre1_b( 9) <= not( (sel_a_res0 and ex6_frac_res_ear( 9) ) or (sel_a_res1 and ex6_frac_res_dly( 9) ) );
fwd_a_frac_pre1_10: rf1_a_frac_pre1_b(10) <= not( (sel_a_res0 and ex6_frac_res_ear(10) ) or (sel_a_res1 and ex6_frac_res_dly(10) ) );
fwd_a_frac_pre1_11: rf1_a_frac_pre1_b(11) <= not( (sel_a_res0 and ex6_frac_res_ear(11) ) or (sel_a_res1 and ex6_frac_res_dly(11) ) );
fwd_a_frac_pre1_12: rf1_a_frac_pre1_b(12) <= not( (sel_a_res0 and ex6_frac_res_ear(12) ) or (sel_a_res1 and ex6_frac_res_dly(12) ) );
fwd_a_frac_pre1_13: rf1_a_frac_pre1_b(13) <= not( (sel_a_res0 and ex6_frac_res_ear(13) ) or (sel_a_res1 and ex6_frac_res_dly(13) ) );
fwd_a_frac_pre1_14: rf1_a_frac_pre1_b(14) <= not( (sel_a_res0 and ex6_frac_res_ear(14) ) or (sel_a_res1 and ex6_frac_res_dly(14) ) );
fwd_a_frac_pre1_15: rf1_a_frac_pre1_b(15) <= not( (sel_a_res0 and ex6_frac_res_ear(15) ) or (sel_a_res1 and ex6_frac_res_dly(15) ) );
fwd_a_frac_pre1_16: rf1_a_frac_pre1_b(16) <= not( (sel_a_res0 and ex6_frac_res_ear(16) ) or (sel_a_res1 and ex6_frac_res_dly(16) ) );
fwd_a_frac_pre1_17: rf1_a_frac_pre1_b(17) <= not( (sel_a_res0 and ex6_frac_res_ear(17) ) or (sel_a_res1 and ex6_frac_res_dly(17) ) );
fwd_a_frac_pre1_18: rf1_a_frac_pre1_b(18) <= not( (sel_a_res0 and ex6_frac_res_ear(18) ) or (sel_a_res1 and ex6_frac_res_dly(18) ) );
fwd_a_frac_pre1_19: rf1_a_frac_pre1_b(19) <= not( (sel_a_res0 and ex6_frac_res_ear(19) ) or (sel_a_res1 and ex6_frac_res_dly(19) ) );
fwd_a_frac_pre1_20: rf1_a_frac_pre1_b(20) <= not( (sel_a_res0 and ex6_frac_res_ear(20) ) or (sel_a_res1 and ex6_frac_res_dly(20) ) );
fwd_a_frac_pre1_21: rf1_a_frac_pre1_b(21) <= not( (sel_a_res0 and ex6_frac_res_ear(21) ) or (sel_a_res1 and ex6_frac_res_dly(21) ) );
fwd_a_frac_pre1_22: rf1_a_frac_pre1_b(22) <= not( (sel_a_res0 and ex6_frac_res_ear(22) ) or (sel_a_res1 and ex6_frac_res_dly(22) ) );
fwd_a_frac_pre1_23: rf1_a_frac_pre1_b(23) <= not( (sel_a_res0 and ex6_frac_res_ear(23) ) or (sel_a_res1 and ex6_frac_res_dly(23) ) );
fwd_a_frac_pre1_24: rf1_a_frac_pre1_b(24) <= not( (sel_a_res0 and ex6_frac_res_ear(24) ) or (sel_a_res1 and ex6_frac_res_dly(24) ) );
fwd_a_frac_pre1_25: rf1_a_frac_pre1_b(25) <= not( (sel_a_res0 and ex6_frac_res_ear(25) ) or (sel_a_res1 and ex6_frac_res_dly(25) ) );
fwd_a_frac_pre1_26: rf1_a_frac_pre1_b(26) <= not( (sel_a_res0 and ex6_frac_res_ear(26) ) or (sel_a_res1 and ex6_frac_res_dly(26) ) );
fwd_a_frac_pre1_27: rf1_a_frac_pre1_b(27) <= not( (sel_a_res0 and ex6_frac_res_ear(27) ) or (sel_a_res1 and ex6_frac_res_dly(27) ) );
fwd_a_frac_pre1_28: rf1_a_frac_pre1_b(28) <= not( (sel_a_res0 and ex6_frac_res_ear(28) ) or (sel_a_res1 and ex6_frac_res_dly(28) ) );
fwd_a_frac_pre1_29: rf1_a_frac_pre1_b(29) <= not( (sel_a_res0 and ex6_frac_res_ear(29) ) or (sel_a_res1 and ex6_frac_res_dly(29) ) );
fwd_a_frac_pre1_30: rf1_a_frac_pre1_b(30) <= not( (sel_a_res0 and ex6_frac_res_ear(30) ) or (sel_a_res1 and ex6_frac_res_dly(30) ) );
fwd_a_frac_pre1_31: rf1_a_frac_pre1_b(31) <= not( (sel_a_res0 and ex6_frac_res_ear(31) ) or (sel_a_res1 and ex6_frac_res_dly(31) ) );
fwd_a_frac_pre1_32: rf1_a_frac_pre1_b(32) <= not( (sel_a_res0 and ex6_frac_res_ear(32) ) or (sel_a_res1 and ex6_frac_res_dly(32) ) );
fwd_a_frac_pre1_33: rf1_a_frac_pre1_b(33) <= not( (sel_a_res0 and ex6_frac_res_ear(33) ) or (sel_a_res1 and ex6_frac_res_dly(33) ) );
fwd_a_frac_pre1_34: rf1_a_frac_pre1_b(34) <= not( (sel_a_res0 and ex6_frac_res_ear(34) ) or (sel_a_res1 and ex6_frac_res_dly(34) ) );
fwd_a_frac_pre1_35: rf1_a_frac_pre1_b(35) <= not( (sel_a_res0 and ex6_frac_res_ear(35) ) or (sel_a_res1 and ex6_frac_res_dly(35) ) );
fwd_a_frac_pre1_36: rf1_a_frac_pre1_b(36) <= not( (sel_a_res0 and ex6_frac_res_ear(36) ) or (sel_a_res1 and ex6_frac_res_dly(36) ) );
fwd_a_frac_pre1_37: rf1_a_frac_pre1_b(37) <= not( (sel_a_res0 and ex6_frac_res_ear(37) ) or (sel_a_res1 and ex6_frac_res_dly(37) ) );
fwd_a_frac_pre1_38: rf1_a_frac_pre1_b(38) <= not( (sel_a_res0 and ex6_frac_res_ear(38) ) or (sel_a_res1 and ex6_frac_res_dly(38) ) );
fwd_a_frac_pre1_39: rf1_a_frac_pre1_b(39) <= not( (sel_a_res0 and ex6_frac_res_ear(39) ) or (sel_a_res1 and ex6_frac_res_dly(39) ) );
fwd_a_frac_pre1_40: rf1_a_frac_pre1_b(40) <= not( (sel_a_res0 and ex6_frac_res_ear(40) ) or (sel_a_res1 and ex6_frac_res_dly(40) ) );
fwd_a_frac_pre1_41: rf1_a_frac_pre1_b(41) <= not( (sel_a_res0 and ex6_frac_res_ear(41) ) or (sel_a_res1 and ex6_frac_res_dly(41) ) );
fwd_a_frac_pre1_42: rf1_a_frac_pre1_b(42) <= not( (sel_a_res0 and ex6_frac_res_ear(42) ) or (sel_a_res1 and ex6_frac_res_dly(42) ) );
fwd_a_frac_pre1_43: rf1_a_frac_pre1_b(43) <= not( (sel_a_res0 and ex6_frac_res_ear(43) ) or (sel_a_res1 and ex6_frac_res_dly(43) ) );
fwd_a_frac_pre1_44: rf1_a_frac_pre1_b(44) <= not( (sel_a_res0 and ex6_frac_res_ear(44) ) or (sel_a_res1 and ex6_frac_res_dly(44) ) );
fwd_a_frac_pre1_45: rf1_a_frac_pre1_b(45) <= not( (sel_a_res0 and ex6_frac_res_ear(45) ) or (sel_a_res1 and ex6_frac_res_dly(45) ) );
fwd_a_frac_pre1_46: rf1_a_frac_pre1_b(46) <= not( (sel_a_res0 and ex6_frac_res_ear(46) ) or (sel_a_res1 and ex6_frac_res_dly(46) ) );
fwd_a_frac_pre1_47: rf1_a_frac_pre1_b(47) <= not( (sel_a_res0 and ex6_frac_res_ear(47) ) or (sel_a_res1 and ex6_frac_res_dly(47) ) );
fwd_a_frac_pre1_48: rf1_a_frac_pre1_b(48) <= not( (sel_a_res0 and ex6_frac_res_ear(48) ) or (sel_a_res1 and ex6_frac_res_dly(48) ) );
fwd_a_frac_pre1_49: rf1_a_frac_pre1_b(49) <= not( (sel_a_res0 and ex6_frac_res_ear(49) ) or (sel_a_res1 and ex6_frac_res_dly(49) ) );
fwd_a_frac_pre1_50: rf1_a_frac_pre1_b(50) <= not( (sel_a_res0 and ex6_frac_res_ear(50) ) or (sel_a_res1 and ex6_frac_res_dly(50) ) );
fwd_a_frac_pre1_51: rf1_a_frac_pre1_b(51) <= not( (sel_a_res0 and ex6_frac_res_ear(51) ) or (sel_a_res1 and ex6_frac_res_dly(51) ) );
fwd_a_frac_pre1_52: rf1_a_frac_pre1_b(52) <= not( (sel_a_res0 and ex6_frac_res_ear(52) ) or (sel_a_res1 and ex6_frac_res_dly(52) ) );


fwd_c_frac_pre1_00: rf1_c_frac_pre1_b( 0) <= not( (sel_c_res0 and ex6_frac_res_ear( 0) ) or (sel_c_res1 and ex6_frac_res_dly( 0) ) );
fwd_c_frac_pre1_01: rf1_c_frac_pre1_b( 1) <= not( (sel_c_res0 and ex6_frac_res_ear( 1) ) or (sel_c_res1 and ex6_frac_res_dly( 1) ) );
fwd_c_frac_pre1_02: rf1_c_frac_pre1_b( 2) <= not( (sel_c_res0 and ex6_frac_res_ear( 2) ) or (sel_c_res1 and ex6_frac_res_dly( 2) ) );
fwd_c_frac_pre1_03: rf1_c_frac_pre1_b( 3) <= not( (sel_c_res0 and ex6_frac_res_ear( 3) ) or (sel_c_res1 and ex6_frac_res_dly( 3) ) );
fwd_c_frac_pre1_04: rf1_c_frac_pre1_b( 4) <= not( (sel_c_res0 and ex6_frac_res_ear( 4) ) or (sel_c_res1 and ex6_frac_res_dly( 4) ) );
fwd_c_frac_pre1_05: rf1_c_frac_pre1_b( 5) <= not( (sel_c_res0 and ex6_frac_res_ear( 5) ) or (sel_c_res1 and ex6_frac_res_dly( 5) ) );
fwd_c_frac_pre1_06: rf1_c_frac_pre1_b( 6) <= not( (sel_c_res0 and ex6_frac_res_ear( 6) ) or (sel_c_res1 and ex6_frac_res_dly( 6) ) );
fwd_c_frac_pre1_07: rf1_c_frac_pre1_b( 7) <= not( (sel_c_res0 and ex6_frac_res_ear( 7) ) or (sel_c_res1 and ex6_frac_res_dly( 7) ) );
fwd_c_frac_pre1_08: rf1_c_frac_pre1_b( 8) <= not( (sel_c_res0 and ex6_frac_res_ear( 8) ) or (sel_c_res1 and ex6_frac_res_dly( 8) ) );
fwd_c_frac_pre1_09: rf1_c_frac_pre1_b( 9) <= not( (sel_c_res0 and ex6_frac_res_ear( 9) ) or (sel_c_res1 and ex6_frac_res_dly( 9) ) );
fwd_c_frac_pre1_10: rf1_c_frac_pre1_b(10) <= not( (sel_c_res0 and ex6_frac_res_ear(10) ) or (sel_c_res1 and ex6_frac_res_dly(10) ) );
fwd_c_frac_pre1_11: rf1_c_frac_pre1_b(11) <= not( (sel_c_res0 and ex6_frac_res_ear(11) ) or (sel_c_res1 and ex6_frac_res_dly(11) ) );
fwd_c_frac_pre1_12: rf1_c_frac_pre1_b(12) <= not( (sel_c_res0 and ex6_frac_res_ear(12) ) or (sel_c_res1 and ex6_frac_res_dly(12) ) );
fwd_c_frac_pre1_13: rf1_c_frac_pre1_b(13) <= not( (sel_c_res0 and ex6_frac_res_ear(13) ) or (sel_c_res1 and ex6_frac_res_dly(13) ) );
fwd_c_frac_pre1_14: rf1_c_frac_pre1_b(14) <= not( (sel_c_res0 and ex6_frac_res_ear(14) ) or (sel_c_res1 and ex6_frac_res_dly(14) ) );
fwd_c_frac_pre1_15: rf1_c_frac_pre1_b(15) <= not( (sel_c_res0 and ex6_frac_res_ear(15) ) or (sel_c_res1 and ex6_frac_res_dly(15) ) );
fwd_c_frac_pre1_16: rf1_c_frac_pre1_b(16) <= not( (sel_c_res0 and ex6_frac_res_ear(16) ) or (sel_c_res1 and ex6_frac_res_dly(16) ) );
fwd_c_frac_pre1_17: rf1_c_frac_pre1_b(17) <= not( (sel_c_res0 and ex6_frac_res_ear(17) ) or (sel_c_res1 and ex6_frac_res_dly(17) ) );
fwd_c_frac_pre1_18: rf1_c_frac_pre1_b(18) <= not( (sel_c_res0 and ex6_frac_res_ear(18) ) or (sel_c_res1 and ex6_frac_res_dly(18) ) );
fwd_c_frac_pre1_19: rf1_c_frac_pre1_b(19) <= not( (sel_c_res0 and ex6_frac_res_ear(19) ) or (sel_c_res1 and ex6_frac_res_dly(19) ) );
fwd_c_frac_pre1_20: rf1_c_frac_pre1_b(20) <= not( (sel_c_res0 and ex6_frac_res_ear(20) ) or (sel_c_res1 and ex6_frac_res_dly(20) ) );
fwd_c_frac_pre1_21: rf1_c_frac_pre1_b(21) <= not( (sel_c_res0 and ex6_frac_res_ear(21) ) or (sel_c_res1 and ex6_frac_res_dly(21) ) );
fwd_c_frac_pre1_22: rf1_c_frac_pre1_b(22) <= not( (sel_c_res0 and ex6_frac_res_ear(22) ) or (sel_c_res1 and ex6_frac_res_dly(22) ) );
fwd_c_frac_pre1_23: rf1_c_frac_pre1_b(23) <= not( (sel_c_res0 and ex6_frac_res_ear(23) ) or (sel_c_res1 and ex6_frac_res_dly(23) ) );
fwd_c_frac_pre1_24: rf1_c_frac_pre1_b(24) <= not( (sel_c_res0 and ex6_frac_res_ear(24) ) or (sel_c_res1 and ex6_frac_res_dly(24) ) );
fwd_c_frac_pre1_25: rf1_c_frac_pre1_b(25) <= not( (sel_c_res0 and ex6_frac_res_ear(25) ) or (sel_c_res1 and ex6_frac_res_dly(25) ) );
fwd_c_frac_pre1_26: rf1_c_frac_pre1_b(26) <= not( (sel_c_res0 and ex6_frac_res_ear(26) ) or (sel_c_res1 and ex6_frac_res_dly(26) ) );
fwd_c_frac_pre1_27: rf1_c_frac_pre1_b(27) <= not( (sel_c_res0 and ex6_frac_res_ear(27) ) or (sel_c_res1 and ex6_frac_res_dly(27) ) );
fwd_c_frac_pre1_28: rf1_c_frac_pre1_b(28) <= not( (sel_c_res0 and ex6_frac_res_ear(28) ) or (sel_c_res1 and ex6_frac_res_dly(28) ) );
fwd_c_frac_pre1_29: rf1_c_frac_pre1_b(29) <= not( (sel_c_res0 and ex6_frac_res_ear(29) ) or (sel_c_res1 and ex6_frac_res_dly(29) ) );
fwd_c_frac_pre1_30: rf1_c_frac_pre1_b(30) <= not( (sel_c_res0 and ex6_frac_res_ear(30) ) or (sel_c_res1 and ex6_frac_res_dly(30) ) );
fwd_c_frac_pre1_31: rf1_c_frac_pre1_b(31) <= not( (sel_c_res0 and ex6_frac_res_ear(31) ) or (sel_c_res1 and ex6_frac_res_dly(31) ) );
fwd_c_frac_pre1_32: rf1_c_frac_pre1_b(32) <= not( (sel_c_res0 and ex6_frac_res_ear(32) ) or (sel_c_res1 and ex6_frac_res_dly(32) ) );
fwd_c_frac_pre1_33: rf1_c_frac_pre1_b(33) <= not( (sel_c_res0 and ex6_frac_res_ear(33) ) or (sel_c_res1 and ex6_frac_res_dly(33) ) );
fwd_c_frac_pre1_34: rf1_c_frac_pre1_b(34) <= not( (sel_c_res0 and ex6_frac_res_ear(34) ) or (sel_c_res1 and ex6_frac_res_dly(34) ) );
fwd_c_frac_pre1_35: rf1_c_frac_pre1_b(35) <= not( (sel_c_res0 and ex6_frac_res_ear(35) ) or (sel_c_res1 and ex6_frac_res_dly(35) ) );
fwd_c_frac_pre1_36: rf1_c_frac_pre1_b(36) <= not( (sel_c_res0 and ex6_frac_res_ear(36) ) or (sel_c_res1 and ex6_frac_res_dly(36) ) );
fwd_c_frac_pre1_37: rf1_c_frac_pre1_b(37) <= not( (sel_c_res0 and ex6_frac_res_ear(37) ) or (sel_c_res1 and ex6_frac_res_dly(37) ) );
fwd_c_frac_pre1_38: rf1_c_frac_pre1_b(38) <= not( (sel_c_res0 and ex6_frac_res_ear(38) ) or (sel_c_res1 and ex6_frac_res_dly(38) ) );
fwd_c_frac_pre1_39: rf1_c_frac_pre1_b(39) <= not( (sel_c_res0 and ex6_frac_res_ear(39) ) or (sel_c_res1 and ex6_frac_res_dly(39) ) );
fwd_c_frac_pre1_40: rf1_c_frac_pre1_b(40) <= not( (sel_c_res0 and ex6_frac_res_ear(40) ) or (sel_c_res1 and ex6_frac_res_dly(40) ) );
fwd_c_frac_pre1_41: rf1_c_frac_pre1_b(41) <= not( (sel_c_res0 and ex6_frac_res_ear(41) ) or (sel_c_res1 and ex6_frac_res_dly(41) ) );
fwd_c_frac_pre1_42: rf1_c_frac_pre1_b(42) <= not( (sel_c_res0 and ex6_frac_res_ear(42) ) or (sel_c_res1 and ex6_frac_res_dly(42) ) );
fwd_c_frac_pre1_43: rf1_c_frac_pre1_b(43) <= not( (sel_c_res0 and ex6_frac_res_ear(43) ) or (sel_c_res1 and ex6_frac_res_dly(43) ) );
fwd_c_frac_pre1_44: rf1_c_frac_pre1_b(44) <= not( (sel_c_res0 and ex6_frac_res_ear(44) ) or (sel_c_res1 and ex6_frac_res_dly(44) ) );
fwd_c_frac_pre1_45: rf1_c_frac_pre1_b(45) <= not( (sel_c_res0 and ex6_frac_res_ear(45) ) or (sel_c_res1 and ex6_frac_res_dly(45) ) );
fwd_c_frac_pre1_46: rf1_c_frac_pre1_b(46) <= not( (sel_c_res0 and ex6_frac_res_ear(46) ) or (sel_c_res1 and ex6_frac_res_dly(46) ) );
fwd_c_frac_pre1_47: rf1_c_frac_pre1_b(47) <= not( (sel_c_res0 and ex6_frac_res_ear(47) ) or (sel_c_res1 and ex6_frac_res_dly(47) ) );
fwd_c_frac_pre1_48: rf1_c_frac_pre1_b(48) <= not( (sel_c_res0 and ex6_frac_res_ear(48) ) or (sel_c_res1 and ex6_frac_res_dly(48) ) );
fwd_c_frac_pre1_49: rf1_c_frac_pre1_b(49) <= not( (sel_c_res0 and ex6_frac_res_ear(49) ) or (sel_c_res1 and ex6_frac_res_dly(49) ) );
fwd_c_frac_pre1_50: rf1_c_frac_pre1_b(50) <= not( (sel_c_res0 and ex6_frac_res_ear(50) ) or (sel_c_res1 and ex6_frac_res_dly(50) ) );
fwd_c_frac_pre1_51: rf1_c_frac_pre1_b(51) <= not( (sel_c_res0 and ex6_frac_res_ear(51) ) or (sel_c_res1 and ex6_frac_res_dly(51) ) );
fwd_c_frac_pre1_52: rf1_c_frac_pre1_b(52) <= not( (sel_c_res0 and ex6_frac_res_ear(52) ) or (sel_c_res1 and ex6_frac_res_dly(52) ) );


fwd_b_frac_pre1_00: rf1_b_frac_pre1_b( 0) <= not( (sel_b_res0 and ex6_frac_res_ear( 0) ) or (sel_b_res1 and ex6_frac_res_dly( 0) ) );
fwd_b_frac_pre1_01: rf1_b_frac_pre1_b( 1) <= not( (sel_b_res0 and ex6_frac_res_ear( 1) ) or (sel_b_res1 and ex6_frac_res_dly( 1) ) );
fwd_b_frac_pre1_02: rf1_b_frac_pre1_b( 2) <= not( (sel_b_res0 and ex6_frac_res_ear( 2) ) or (sel_b_res1 and ex6_frac_res_dly( 2) ) );
fwd_b_frac_pre1_03: rf1_b_frac_pre1_b( 3) <= not( (sel_b_res0 and ex6_frac_res_ear( 3) ) or (sel_b_res1 and ex6_frac_res_dly( 3) ) );
fwd_b_frac_pre1_04: rf1_b_frac_pre1_b( 4) <= not( (sel_b_res0 and ex6_frac_res_ear( 4) ) or (sel_b_res1 and ex6_frac_res_dly( 4) ) );
fwd_b_frac_pre1_05: rf1_b_frac_pre1_b( 5) <= not( (sel_b_res0 and ex6_frac_res_ear( 5) ) or (sel_b_res1 and ex6_frac_res_dly( 5) ) );
fwd_b_frac_pre1_06: rf1_b_frac_pre1_b( 6) <= not( (sel_b_res0 and ex6_frac_res_ear( 6) ) or (sel_b_res1 and ex6_frac_res_dly( 6) ) );
fwd_b_frac_pre1_07: rf1_b_frac_pre1_b( 7) <= not( (sel_b_res0 and ex6_frac_res_ear( 7) ) or (sel_b_res1 and ex6_frac_res_dly( 7) ) );
fwd_b_frac_pre1_08: rf1_b_frac_pre1_b( 8) <= not( (sel_b_res0 and ex6_frac_res_ear( 8) ) or (sel_b_res1 and ex6_frac_res_dly( 8) ) );
fwd_b_frac_pre1_09: rf1_b_frac_pre1_b( 9) <= not( (sel_b_res0 and ex6_frac_res_ear( 9) ) or (sel_b_res1 and ex6_frac_res_dly( 9) ) );
fwd_b_frac_pre1_10: rf1_b_frac_pre1_b(10) <= not( (sel_b_res0 and ex6_frac_res_ear(10) ) or (sel_b_res1 and ex6_frac_res_dly(10) ) );
fwd_b_frac_pre1_11: rf1_b_frac_pre1_b(11) <= not( (sel_b_res0 and ex6_frac_res_ear(11) ) or (sel_b_res1 and ex6_frac_res_dly(11) ) );
fwd_b_frac_pre1_12: rf1_b_frac_pre1_b(12) <= not( (sel_b_res0 and ex6_frac_res_ear(12) ) or (sel_b_res1 and ex6_frac_res_dly(12) ) );
fwd_b_frac_pre1_13: rf1_b_frac_pre1_b(13) <= not( (sel_b_res0 and ex6_frac_res_ear(13) ) or (sel_b_res1 and ex6_frac_res_dly(13) ) );
fwd_b_frac_pre1_14: rf1_b_frac_pre1_b(14) <= not( (sel_b_res0 and ex6_frac_res_ear(14) ) or (sel_b_res1 and ex6_frac_res_dly(14) ) );
fwd_b_frac_pre1_15: rf1_b_frac_pre1_b(15) <= not( (sel_b_res0 and ex6_frac_res_ear(15) ) or (sel_b_res1 and ex6_frac_res_dly(15) ) );
fwd_b_frac_pre1_16: rf1_b_frac_pre1_b(16) <= not( (sel_b_res0 and ex6_frac_res_ear(16) ) or (sel_b_res1 and ex6_frac_res_dly(16) ) );
fwd_b_frac_pre1_17: rf1_b_frac_pre1_b(17) <= not( (sel_b_res0 and ex6_frac_res_ear(17) ) or (sel_b_res1 and ex6_frac_res_dly(17) ) );
fwd_b_frac_pre1_18: rf1_b_frac_pre1_b(18) <= not( (sel_b_res0 and ex6_frac_res_ear(18) ) or (sel_b_res1 and ex6_frac_res_dly(18) ) );
fwd_b_frac_pre1_19: rf1_b_frac_pre1_b(19) <= not( (sel_b_res0 and ex6_frac_res_ear(19) ) or (sel_b_res1 and ex6_frac_res_dly(19) ) );
fwd_b_frac_pre1_20: rf1_b_frac_pre1_b(20) <= not( (sel_b_res0 and ex6_frac_res_ear(20) ) or (sel_b_res1 and ex6_frac_res_dly(20) ) );
fwd_b_frac_pre1_21: rf1_b_frac_pre1_b(21) <= not( (sel_b_res0 and ex6_frac_res_ear(21) ) or (sel_b_res1 and ex6_frac_res_dly(21) ) );
fwd_b_frac_pre1_22: rf1_b_frac_pre1_b(22) <= not( (sel_b_res0 and ex6_frac_res_ear(22) ) or (sel_b_res1 and ex6_frac_res_dly(22) ) );
fwd_b_frac_pre1_23: rf1_b_frac_pre1_b(23) <= not( (sel_b_res0 and ex6_frac_res_ear(23) ) or (sel_b_res1 and ex6_frac_res_dly(23) ) );
fwd_b_frac_pre1_24: rf1_b_frac_pre1_b(24) <= not( (sel_b_res0 and ex6_frac_res_ear(24) ) or (sel_b_res1 and ex6_frac_res_dly(24) ) );
fwd_b_frac_pre1_25: rf1_b_frac_pre1_b(25) <= not( (sel_b_res0 and ex6_frac_res_ear(25) ) or (sel_b_res1 and ex6_frac_res_dly(25) ) );
fwd_b_frac_pre1_26: rf1_b_frac_pre1_b(26) <= not( (sel_b_res0 and ex6_frac_res_ear(26) ) or (sel_b_res1 and ex6_frac_res_dly(26) ) );
fwd_b_frac_pre1_27: rf1_b_frac_pre1_b(27) <= not( (sel_b_res0 and ex6_frac_res_ear(27) ) or (sel_b_res1 and ex6_frac_res_dly(27) ) );
fwd_b_frac_pre1_28: rf1_b_frac_pre1_b(28) <= not( (sel_b_res0 and ex6_frac_res_ear(28) ) or (sel_b_res1 and ex6_frac_res_dly(28) ) );
fwd_b_frac_pre1_29: rf1_b_frac_pre1_b(29) <= not( (sel_b_res0 and ex6_frac_res_ear(29) ) or (sel_b_res1 and ex6_frac_res_dly(29) ) );
fwd_b_frac_pre1_30: rf1_b_frac_pre1_b(30) <= not( (sel_b_res0 and ex6_frac_res_ear(30) ) or (sel_b_res1 and ex6_frac_res_dly(30) ) );
fwd_b_frac_pre1_31: rf1_b_frac_pre1_b(31) <= not( (sel_b_res0 and ex6_frac_res_ear(31) ) or (sel_b_res1 and ex6_frac_res_dly(31) ) );
fwd_b_frac_pre1_32: rf1_b_frac_pre1_b(32) <= not( (sel_b_res0 and ex6_frac_res_ear(32) ) or (sel_b_res1 and ex6_frac_res_dly(32) ) );
fwd_b_frac_pre1_33: rf1_b_frac_pre1_b(33) <= not( (sel_b_res0 and ex6_frac_res_ear(33) ) or (sel_b_res1 and ex6_frac_res_dly(33) ) );
fwd_b_frac_pre1_34: rf1_b_frac_pre1_b(34) <= not( (sel_b_res0 and ex6_frac_res_ear(34) ) or (sel_b_res1 and ex6_frac_res_dly(34) ) );
fwd_b_frac_pre1_35: rf1_b_frac_pre1_b(35) <= not( (sel_b_res0 and ex6_frac_res_ear(35) ) or (sel_b_res1 and ex6_frac_res_dly(35) ) );
fwd_b_frac_pre1_36: rf1_b_frac_pre1_b(36) <= not( (sel_b_res0 and ex6_frac_res_ear(36) ) or (sel_b_res1 and ex6_frac_res_dly(36) ) );
fwd_b_frac_pre1_37: rf1_b_frac_pre1_b(37) <= not( (sel_b_res0 and ex6_frac_res_ear(37) ) or (sel_b_res1 and ex6_frac_res_dly(37) ) );
fwd_b_frac_pre1_38: rf1_b_frac_pre1_b(38) <= not( (sel_b_res0 and ex6_frac_res_ear(38) ) or (sel_b_res1 and ex6_frac_res_dly(38) ) );
fwd_b_frac_pre1_39: rf1_b_frac_pre1_b(39) <= not( (sel_b_res0 and ex6_frac_res_ear(39) ) or (sel_b_res1 and ex6_frac_res_dly(39) ) );
fwd_b_frac_pre1_40: rf1_b_frac_pre1_b(40) <= not( (sel_b_res0 and ex6_frac_res_ear(40) ) or (sel_b_res1 and ex6_frac_res_dly(40) ) );
fwd_b_frac_pre1_41: rf1_b_frac_pre1_b(41) <= not( (sel_b_res0 and ex6_frac_res_ear(41) ) or (sel_b_res1 and ex6_frac_res_dly(41) ) );
fwd_b_frac_pre1_42: rf1_b_frac_pre1_b(42) <= not( (sel_b_res0 and ex6_frac_res_ear(42) ) or (sel_b_res1 and ex6_frac_res_dly(42) ) );
fwd_b_frac_pre1_43: rf1_b_frac_pre1_b(43) <= not( (sel_b_res0 and ex6_frac_res_ear(43) ) or (sel_b_res1 and ex6_frac_res_dly(43) ) );
fwd_b_frac_pre1_44: rf1_b_frac_pre1_b(44) <= not( (sel_b_res0 and ex6_frac_res_ear(44) ) or (sel_b_res1 and ex6_frac_res_dly(44) ) );
fwd_b_frac_pre1_45: rf1_b_frac_pre1_b(45) <= not( (sel_b_res0 and ex6_frac_res_ear(45) ) or (sel_b_res1 and ex6_frac_res_dly(45) ) );
fwd_b_frac_pre1_46: rf1_b_frac_pre1_b(46) <= not( (sel_b_res0 and ex6_frac_res_ear(46) ) or (sel_b_res1 and ex6_frac_res_dly(46) ) );
fwd_b_frac_pre1_47: rf1_b_frac_pre1_b(47) <= not( (sel_b_res0 and ex6_frac_res_ear(47) ) or (sel_b_res1 and ex6_frac_res_dly(47) ) );
fwd_b_frac_pre1_48: rf1_b_frac_pre1_b(48) <= not( (sel_b_res0 and ex6_frac_res_ear(48) ) or (sel_b_res1 and ex6_frac_res_dly(48) ) );
fwd_b_frac_pre1_49: rf1_b_frac_pre1_b(49) <= not( (sel_b_res0 and ex6_frac_res_ear(49) ) or (sel_b_res1 and ex6_frac_res_dly(49) ) );
fwd_b_frac_pre1_50: rf1_b_frac_pre1_b(50) <= not( (sel_b_res0 and ex6_frac_res_ear(50) ) or (sel_b_res1 and ex6_frac_res_dly(50) ) );
fwd_b_frac_pre1_51: rf1_b_frac_pre1_b(51) <= not( (sel_b_res0 and ex6_frac_res_ear(51) ) or (sel_b_res1 and ex6_frac_res_dly(51) ) );
fwd_b_frac_pre1_52: rf1_b_frac_pre1_b(52) <= not( (sel_b_res0 and ex6_frac_res_ear(52) ) or (sel_b_res1 and ex6_frac_res_dly(52) ) );





fwd_a_frac_pre2_00: rf1_a_frac_pre2_b( 0) <= not( (sel_a_load0 and ex6_frac_lod_ear( 0) ) or (sel_a_load1 and ex6_frac_lod_dly( 0) ) );
fwd_a_frac_pre2_01: rf1_a_frac_pre2_b( 1) <= not( (sel_a_load0 and ex6_frac_lod_ear( 1) ) or (sel_a_load1 and ex6_frac_lod_dly( 1) ) );
fwd_a_frac_pre2_02: rf1_a_frac_pre2_b( 2) <= not( (sel_a_load0 and ex6_frac_lod_ear( 2) ) or (sel_a_load1 and ex6_frac_lod_dly( 2) ) );
fwd_a_frac_pre2_03: rf1_a_frac_pre2_b( 3) <= not( (sel_a_load0 and ex6_frac_lod_ear( 3) ) or (sel_a_load1 and ex6_frac_lod_dly( 3) ) );
fwd_a_frac_pre2_04: rf1_a_frac_pre2_b( 4) <= not( (sel_a_load0 and ex6_frac_lod_ear( 4) ) or (sel_a_load1 and ex6_frac_lod_dly( 4) ) );
fwd_a_frac_pre2_05: rf1_a_frac_pre2_b( 5) <= not( (sel_a_load0 and ex6_frac_lod_ear( 5) ) or (sel_a_load1 and ex6_frac_lod_dly( 5) ) );
fwd_a_frac_pre2_06: rf1_a_frac_pre2_b( 6) <= not( (sel_a_load0 and ex6_frac_lod_ear( 6) ) or (sel_a_load1 and ex6_frac_lod_dly( 6) ) );
fwd_a_frac_pre2_07: rf1_a_frac_pre2_b( 7) <= not( (sel_a_load0 and ex6_frac_lod_ear( 7) ) or (sel_a_load1 and ex6_frac_lod_dly( 7) ) );
fwd_a_frac_pre2_08: rf1_a_frac_pre2_b( 8) <= not( (sel_a_load0 and ex6_frac_lod_ear( 8) ) or (sel_a_load1 and ex6_frac_lod_dly( 8) ) );
fwd_a_frac_pre2_09: rf1_a_frac_pre2_b( 9) <= not( (sel_a_load0 and ex6_frac_lod_ear( 9) ) or (sel_a_load1 and ex6_frac_lod_dly( 9) ) );
fwd_a_frac_pre2_10: rf1_a_frac_pre2_b(10) <= not( (sel_a_load0 and ex6_frac_lod_ear(10) ) or (sel_a_load1 and ex6_frac_lod_dly(10) ) );
fwd_a_frac_pre2_11: rf1_a_frac_pre2_b(11) <= not( (sel_a_load0 and ex6_frac_lod_ear(11) ) or (sel_a_load1 and ex6_frac_lod_dly(11) ) );
fwd_a_frac_pre2_12: rf1_a_frac_pre2_b(12) <= not( (sel_a_load0 and ex6_frac_lod_ear(12) ) or (sel_a_load1 and ex6_frac_lod_dly(12) ) );
fwd_a_frac_pre2_13: rf1_a_frac_pre2_b(13) <= not( (sel_a_load0 and ex6_frac_lod_ear(13) ) or (sel_a_load1 and ex6_frac_lod_dly(13) ) );
fwd_a_frac_pre2_14: rf1_a_frac_pre2_b(14) <= not( (sel_a_load0 and ex6_frac_lod_ear(14) ) or (sel_a_load1 and ex6_frac_lod_dly(14) ) );
fwd_a_frac_pre2_15: rf1_a_frac_pre2_b(15) <= not( (sel_a_load0 and ex6_frac_lod_ear(15) ) or (sel_a_load1 and ex6_frac_lod_dly(15) ) );
fwd_a_frac_pre2_16: rf1_a_frac_pre2_b(16) <= not( (sel_a_load0 and ex6_frac_lod_ear(16) ) or (sel_a_load1 and ex6_frac_lod_dly(16) ) );
fwd_a_frac_pre2_17: rf1_a_frac_pre2_b(17) <= not( (sel_a_load0 and ex6_frac_lod_ear(17) ) or (sel_a_load1 and ex6_frac_lod_dly(17) ) );
fwd_a_frac_pre2_18: rf1_a_frac_pre2_b(18) <= not( (sel_a_load0 and ex6_frac_lod_ear(18) ) or (sel_a_load1 and ex6_frac_lod_dly(18) ) );
fwd_a_frac_pre2_19: rf1_a_frac_pre2_b(19) <= not( (sel_a_load0 and ex6_frac_lod_ear(19) ) or (sel_a_load1 and ex6_frac_lod_dly(19) ) );
fwd_a_frac_pre2_20: rf1_a_frac_pre2_b(20) <= not( (sel_a_load0 and ex6_frac_lod_ear(20) ) or (sel_a_load1 and ex6_frac_lod_dly(20) ) );
fwd_a_frac_pre2_21: rf1_a_frac_pre2_b(21) <= not( (sel_a_load0 and ex6_frac_lod_ear(21) ) or (sel_a_load1 and ex6_frac_lod_dly(21) ) );
fwd_a_frac_pre2_22: rf1_a_frac_pre2_b(22) <= not( (sel_a_load0 and ex6_frac_lod_ear(22) ) or (sel_a_load1 and ex6_frac_lod_dly(22) ) );
fwd_a_frac_pre2_23: rf1_a_frac_pre2_b(23) <= not( (sel_a_load0 and ex6_frac_lod_ear(23) ) or (sel_a_load1 and ex6_frac_lod_dly(23) ) );
fwd_a_frac_pre2_24: rf1_a_frac_pre2_b(24) <= not( (sel_a_load0 and ex6_frac_lod_ear(24) ) or (sel_a_load1 and ex6_frac_lod_dly(24) ) );
fwd_a_frac_pre2_25: rf1_a_frac_pre2_b(25) <= not( (sel_a_load0 and ex6_frac_lod_ear(25) ) or (sel_a_load1 and ex6_frac_lod_dly(25) ) );
fwd_a_frac_pre2_26: rf1_a_frac_pre2_b(26) <= not( (sel_a_load0 and ex6_frac_lod_ear(26) ) or (sel_a_load1 and ex6_frac_lod_dly(26) ) );
fwd_a_frac_pre2_27: rf1_a_frac_pre2_b(27) <= not( (sel_a_load0 and ex6_frac_lod_ear(27) ) or (sel_a_load1 and ex6_frac_lod_dly(27) ) );
fwd_a_frac_pre2_28: rf1_a_frac_pre2_b(28) <= not( (sel_a_load0 and ex6_frac_lod_ear(28) ) or (sel_a_load1 and ex6_frac_lod_dly(28) ) );
fwd_a_frac_pre2_29: rf1_a_frac_pre2_b(29) <= not( (sel_a_load0 and ex6_frac_lod_ear(29) ) or (sel_a_load1 and ex6_frac_lod_dly(29) ) );
fwd_a_frac_pre2_30: rf1_a_frac_pre2_b(30) <= not( (sel_a_load0 and ex6_frac_lod_ear(30) ) or (sel_a_load1 and ex6_frac_lod_dly(30) ) );
fwd_a_frac_pre2_31: rf1_a_frac_pre2_b(31) <= not( (sel_a_load0 and ex6_frac_lod_ear(31) ) or (sel_a_load1 and ex6_frac_lod_dly(31) ) );
fwd_a_frac_pre2_32: rf1_a_frac_pre2_b(32) <= not( (sel_a_load0 and ex6_frac_lod_ear(32) ) or (sel_a_load1 and ex6_frac_lod_dly(32) ) );
fwd_a_frac_pre2_33: rf1_a_frac_pre2_b(33) <= not( (sel_a_load0 and ex6_frac_lod_ear(33) ) or (sel_a_load1 and ex6_frac_lod_dly(33) ) );
fwd_a_frac_pre2_34: rf1_a_frac_pre2_b(34) <= not( (sel_a_load0 and ex6_frac_lod_ear(34) ) or (sel_a_load1 and ex6_frac_lod_dly(34) ) );
fwd_a_frac_pre2_35: rf1_a_frac_pre2_b(35) <= not( (sel_a_load0 and ex6_frac_lod_ear(35) ) or (sel_a_load1 and ex6_frac_lod_dly(35) ) );
fwd_a_frac_pre2_36: rf1_a_frac_pre2_b(36) <= not( (sel_a_load0 and ex6_frac_lod_ear(36) ) or (sel_a_load1 and ex6_frac_lod_dly(36) ) );
fwd_a_frac_pre2_37: rf1_a_frac_pre2_b(37) <= not( (sel_a_load0 and ex6_frac_lod_ear(37) ) or (sel_a_load1 and ex6_frac_lod_dly(37) ) );
fwd_a_frac_pre2_38: rf1_a_frac_pre2_b(38) <= not( (sel_a_load0 and ex6_frac_lod_ear(38) ) or (sel_a_load1 and ex6_frac_lod_dly(38) ) );
fwd_a_frac_pre2_39: rf1_a_frac_pre2_b(39) <= not( (sel_a_load0 and ex6_frac_lod_ear(39) ) or (sel_a_load1 and ex6_frac_lod_dly(39) ) );
fwd_a_frac_pre2_40: rf1_a_frac_pre2_b(40) <= not( (sel_a_load0 and ex6_frac_lod_ear(40) ) or (sel_a_load1 and ex6_frac_lod_dly(40) ) );
fwd_a_frac_pre2_41: rf1_a_frac_pre2_b(41) <= not( (sel_a_load0 and ex6_frac_lod_ear(41) ) or (sel_a_load1 and ex6_frac_lod_dly(41) ) );
fwd_a_frac_pre2_42: rf1_a_frac_pre2_b(42) <= not( (sel_a_load0 and ex6_frac_lod_ear(42) ) or (sel_a_load1 and ex6_frac_lod_dly(42) ) );
fwd_a_frac_pre2_43: rf1_a_frac_pre2_b(43) <= not( (sel_a_load0 and ex6_frac_lod_ear(43) ) or (sel_a_load1 and ex6_frac_lod_dly(43) ) );
fwd_a_frac_pre2_44: rf1_a_frac_pre2_b(44) <= not( (sel_a_load0 and ex6_frac_lod_ear(44) ) or (sel_a_load1 and ex6_frac_lod_dly(44) ) );
fwd_a_frac_pre2_45: rf1_a_frac_pre2_b(45) <= not( (sel_a_load0 and ex6_frac_lod_ear(45) ) or (sel_a_load1 and ex6_frac_lod_dly(45) ) );
fwd_a_frac_pre2_46: rf1_a_frac_pre2_b(46) <= not( (sel_a_load0 and ex6_frac_lod_ear(46) ) or (sel_a_load1 and ex6_frac_lod_dly(46) ) );
fwd_a_frac_pre2_47: rf1_a_frac_pre2_b(47) <= not( (sel_a_load0 and ex6_frac_lod_ear(47) ) or (sel_a_load1 and ex6_frac_lod_dly(47) ) );
fwd_a_frac_pre2_48: rf1_a_frac_pre2_b(48) <= not( (sel_a_load0 and ex6_frac_lod_ear(48) ) or (sel_a_load1 and ex6_frac_lod_dly(48) ) );
fwd_a_frac_pre2_49: rf1_a_frac_pre2_b(49) <= not( (sel_a_load0 and ex6_frac_lod_ear(49) ) or (sel_a_load1 and ex6_frac_lod_dly(49) ) );
fwd_a_frac_pre2_50: rf1_a_frac_pre2_b(50) <= not( (sel_a_load0 and ex6_frac_lod_ear(50) ) or (sel_a_load1 and ex6_frac_lod_dly(50) ) );
fwd_a_frac_pre2_51: rf1_a_frac_pre2_b(51) <= not( (sel_a_load0 and ex6_frac_lod_ear(51) ) or (sel_a_load1 and ex6_frac_lod_dly(51) ) );
fwd_a_frac_pre2_52: rf1_a_frac_pre2_b(52) <= not( (sel_a_load0 and ex6_frac_lod_ear(52) ) or (sel_a_load1 and ex6_frac_lod_dly(52) ) );

fwd_c_frac_pre2_00: rf1_c_frac_pre2_b( 0) <= not( (sel_c_load0 and ex6_frac_lod_ear( 0) ) or (sel_c_load1 and ex6_frac_lod_dly( 0) ) );
fwd_c_frac_pre2_01: rf1_c_frac_pre2_b( 1) <= not( (sel_c_load0 and ex6_frac_lod_ear( 1) ) or (sel_c_load1 and ex6_frac_lod_dly( 1) ) );
fwd_c_frac_pre2_02: rf1_c_frac_pre2_b( 2) <= not( (sel_c_load0 and ex6_frac_lod_ear( 2) ) or (sel_c_load1 and ex6_frac_lod_dly( 2) ) );
fwd_c_frac_pre2_03: rf1_c_frac_pre2_b( 3) <= not( (sel_c_load0 and ex6_frac_lod_ear( 3) ) or (sel_c_load1 and ex6_frac_lod_dly( 3) ) );
fwd_c_frac_pre2_04: rf1_c_frac_pre2_b( 4) <= not( (sel_c_load0 and ex6_frac_lod_ear( 4) ) or (sel_c_load1 and ex6_frac_lod_dly( 4) ) );
fwd_c_frac_pre2_05: rf1_c_frac_pre2_b( 5) <= not( (sel_c_load0 and ex6_frac_lod_ear( 5) ) or (sel_c_load1 and ex6_frac_lod_dly( 5) ) );
fwd_c_frac_pre2_06: rf1_c_frac_pre2_b( 6) <= not( (sel_c_load0 and ex6_frac_lod_ear( 6) ) or (sel_c_load1 and ex6_frac_lod_dly( 6) ) );
fwd_c_frac_pre2_07: rf1_c_frac_pre2_b( 7) <= not( (sel_c_load0 and ex6_frac_lod_ear( 7) ) or (sel_c_load1 and ex6_frac_lod_dly( 7) ) );
fwd_c_frac_pre2_08: rf1_c_frac_pre2_b( 8) <= not( (sel_c_load0 and ex6_frac_lod_ear( 8) ) or (sel_c_load1 and ex6_frac_lod_dly( 8) ) );
fwd_c_frac_pre2_09: rf1_c_frac_pre2_b( 9) <= not( (sel_c_load0 and ex6_frac_lod_ear( 9) ) or (sel_c_load1 and ex6_frac_lod_dly( 9) ) );
fwd_c_frac_pre2_10: rf1_c_frac_pre2_b(10) <= not( (sel_c_load0 and ex6_frac_lod_ear(10) ) or (sel_c_load1 and ex6_frac_lod_dly(10) ) );
fwd_c_frac_pre2_11: rf1_c_frac_pre2_b(11) <= not( (sel_c_load0 and ex6_frac_lod_ear(11) ) or (sel_c_load1 and ex6_frac_lod_dly(11) ) );
fwd_c_frac_pre2_12: rf1_c_frac_pre2_b(12) <= not( (sel_c_load0 and ex6_frac_lod_ear(12) ) or (sel_c_load1 and ex6_frac_lod_dly(12) ) );
fwd_c_frac_pre2_13: rf1_c_frac_pre2_b(13) <= not( (sel_c_load0 and ex6_frac_lod_ear(13) ) or (sel_c_load1 and ex6_frac_lod_dly(13) ) );
fwd_c_frac_pre2_14: rf1_c_frac_pre2_b(14) <= not( (sel_c_load0 and ex6_frac_lod_ear(14) ) or (sel_c_load1 and ex6_frac_lod_dly(14) ) );
fwd_c_frac_pre2_15: rf1_c_frac_pre2_b(15) <= not( (sel_c_load0 and ex6_frac_lod_ear(15) ) or (sel_c_load1 and ex6_frac_lod_dly(15) ) );
fwd_c_frac_pre2_16: rf1_c_frac_pre2_b(16) <= not( (sel_c_load0 and ex6_frac_lod_ear(16) ) or (sel_c_load1 and ex6_frac_lod_dly(16) ) );
fwd_c_frac_pre2_17: rf1_c_frac_pre2_b(17) <= not( (sel_c_load0 and ex6_frac_lod_ear(17) ) or (sel_c_load1 and ex6_frac_lod_dly(17) ) );
fwd_c_frac_pre2_18: rf1_c_frac_pre2_b(18) <= not( (sel_c_load0 and ex6_frac_lod_ear(18) ) or (sel_c_load1 and ex6_frac_lod_dly(18) ) );
fwd_c_frac_pre2_19: rf1_c_frac_pre2_b(19) <= not( (sel_c_load0 and ex6_frac_lod_ear(19) ) or (sel_c_load1 and ex6_frac_lod_dly(19) ) );
fwd_c_frac_pre2_20: rf1_c_frac_pre2_b(20) <= not( (sel_c_load0 and ex6_frac_lod_ear(20) ) or (sel_c_load1 and ex6_frac_lod_dly(20) ) );
fwd_c_frac_pre2_21: rf1_c_frac_pre2_b(21) <= not( (sel_c_load0 and ex6_frac_lod_ear(21) ) or (sel_c_load1 and ex6_frac_lod_dly(21) ) );
fwd_c_frac_pre2_22: rf1_c_frac_pre2_b(22) <= not( (sel_c_load0 and ex6_frac_lod_ear(22) ) or (sel_c_load1 and ex6_frac_lod_dly(22) ) );
fwd_c_frac_pre2_23: rf1_c_frac_pre2_b(23) <= not( (sel_c_load0 and ex6_frac_lod_ear(23) ) or (sel_c_load1 and ex6_frac_lod_dly(23) ) );
fwd_c_frac_pre2_24: rf1_c_frac_pre2_b(24) <= not( (sel_c_load0 and ex6_frac_lod_ear(24) ) or (sel_c_load1 and ex6_frac_lod_dly(24) ) );
fwd_c_frac_pre2_25: rf1_c_frac_pre2_b(25) <= not( (sel_c_load0 and ex6_frac_lod_ear(25) ) or (sel_c_load1 and ex6_frac_lod_dly(25) ) );
fwd_c_frac_pre2_26: rf1_c_frac_pre2_b(26) <= not( (sel_c_load0 and ex6_frac_lod_ear(26) ) or (sel_c_load1 and ex6_frac_lod_dly(26) ) );
fwd_c_frac_pre2_27: rf1_c_frac_pre2_b(27) <= not( (sel_c_load0 and ex6_frac_lod_ear(27) ) or (sel_c_load1 and ex6_frac_lod_dly(27) ) );
fwd_c_frac_pre2_28: rf1_c_frac_pre2_b(28) <= not( (sel_c_load0 and ex6_frac_lod_ear(28) ) or (sel_c_load1 and ex6_frac_lod_dly(28) ) );
fwd_c_frac_pre2_29: rf1_c_frac_pre2_b(29) <= not( (sel_c_load0 and ex6_frac_lod_ear(29) ) or (sel_c_load1 and ex6_frac_lod_dly(29) ) );
fwd_c_frac_pre2_30: rf1_c_frac_pre2_b(30) <= not( (sel_c_load0 and ex6_frac_lod_ear(30) ) or (sel_c_load1 and ex6_frac_lod_dly(30) ) );
fwd_c_frac_pre2_31: rf1_c_frac_pre2_b(31) <= not( (sel_c_load0 and ex6_frac_lod_ear(31) ) or (sel_c_load1 and ex6_frac_lod_dly(31) ) );
fwd_c_frac_pre2_32: rf1_c_frac_pre2_b(32) <= not( (sel_c_load0 and ex6_frac_lod_ear(32) ) or (sel_c_load1 and ex6_frac_lod_dly(32) ) );
fwd_c_frac_pre2_33: rf1_c_frac_pre2_b(33) <= not( (sel_c_load0 and ex6_frac_lod_ear(33) ) or (sel_c_load1 and ex6_frac_lod_dly(33) ) );
fwd_c_frac_pre2_34: rf1_c_frac_pre2_b(34) <= not( (sel_c_load0 and ex6_frac_lod_ear(34) ) or (sel_c_load1 and ex6_frac_lod_dly(34) ) );
fwd_c_frac_pre2_35: rf1_c_frac_pre2_b(35) <= not( (sel_c_load0 and ex6_frac_lod_ear(35) ) or (sel_c_load1 and ex6_frac_lod_dly(35) ) );
fwd_c_frac_pre2_36: rf1_c_frac_pre2_b(36) <= not( (sel_c_load0 and ex6_frac_lod_ear(36) ) or (sel_c_load1 and ex6_frac_lod_dly(36) ) );
fwd_c_frac_pre2_37: rf1_c_frac_pre2_b(37) <= not( (sel_c_load0 and ex6_frac_lod_ear(37) ) or (sel_c_load1 and ex6_frac_lod_dly(37) ) );
fwd_c_frac_pre2_38: rf1_c_frac_pre2_b(38) <= not( (sel_c_load0 and ex6_frac_lod_ear(38) ) or (sel_c_load1 and ex6_frac_lod_dly(38) ) );
fwd_c_frac_pre2_39: rf1_c_frac_pre2_b(39) <= not( (sel_c_load0 and ex6_frac_lod_ear(39) ) or (sel_c_load1 and ex6_frac_lod_dly(39) ) );
fwd_c_frac_pre2_40: rf1_c_frac_pre2_b(40) <= not( (sel_c_load0 and ex6_frac_lod_ear(40) ) or (sel_c_load1 and ex6_frac_lod_dly(40) ) );
fwd_c_frac_pre2_41: rf1_c_frac_pre2_b(41) <= not( (sel_c_load0 and ex6_frac_lod_ear(41) ) or (sel_c_load1 and ex6_frac_lod_dly(41) ) );
fwd_c_frac_pre2_42: rf1_c_frac_pre2_b(42) <= not( (sel_c_load0 and ex6_frac_lod_ear(42) ) or (sel_c_load1 and ex6_frac_lod_dly(42) ) );
fwd_c_frac_pre2_43: rf1_c_frac_pre2_b(43) <= not( (sel_c_load0 and ex6_frac_lod_ear(43) ) or (sel_c_load1 and ex6_frac_lod_dly(43) ) );
fwd_c_frac_pre2_44: rf1_c_frac_pre2_b(44) <= not( (sel_c_load0 and ex6_frac_lod_ear(44) ) or (sel_c_load1 and ex6_frac_lod_dly(44) ) );
fwd_c_frac_pre2_45: rf1_c_frac_pre2_b(45) <= not( (sel_c_load0 and ex6_frac_lod_ear(45) ) or (sel_c_load1 and ex6_frac_lod_dly(45) ) );
fwd_c_frac_pre2_46: rf1_c_frac_pre2_b(46) <= not( (sel_c_load0 and ex6_frac_lod_ear(46) ) or (sel_c_load1 and ex6_frac_lod_dly(46) ) );
fwd_c_frac_pre2_47: rf1_c_frac_pre2_b(47) <= not( (sel_c_load0 and ex6_frac_lod_ear(47) ) or (sel_c_load1 and ex6_frac_lod_dly(47) ) );
fwd_c_frac_pre2_48: rf1_c_frac_pre2_b(48) <= not( (sel_c_load0 and ex6_frac_lod_ear(48) ) or (sel_c_load1 and ex6_frac_lod_dly(48) ) );
fwd_c_frac_pre2_49: rf1_c_frac_pre2_b(49) <= not( (sel_c_load0 and ex6_frac_lod_ear(49) ) or (sel_c_load1 and ex6_frac_lod_dly(49) ) );
fwd_c_frac_pre2_50: rf1_c_frac_pre2_b(50) <= not( (sel_c_load0 and ex6_frac_lod_ear(50) ) or (sel_c_load1 and ex6_frac_lod_dly(50) ) );
fwd_c_frac_pre2_51: rf1_c_frac_pre2_b(51) <= not( (sel_c_load0 and ex6_frac_lod_ear(51) ) or (sel_c_load1 and ex6_frac_lod_dly(51) ) );
fwd_c_frac_pre2_52: rf1_c_frac_pre2_b(52) <= not( (sel_c_load0 and ex6_frac_lod_ear(52) ) or (sel_c_load1 and ex6_frac_lod_dly(52) ) );

fwd_b_frac_pre2_00: rf1_b_frac_pre2_b( 0) <= not( (sel_b_load0 and ex6_frac_lod_ear( 0) ) or (sel_b_load1 and ex6_frac_lod_dly( 0) ) );
fwd_b_frac_pre2_01: rf1_b_frac_pre2_b( 1) <= not( (sel_b_load0 and ex6_frac_lod_ear( 1) ) or (sel_b_load1 and ex6_frac_lod_dly( 1) ) );
fwd_b_frac_pre2_02: rf1_b_frac_pre2_b( 2) <= not( (sel_b_load0 and ex6_frac_lod_ear( 2) ) or (sel_b_load1 and ex6_frac_lod_dly( 2) ) );
fwd_b_frac_pre2_03: rf1_b_frac_pre2_b( 3) <= not( (sel_b_load0 and ex6_frac_lod_ear( 3) ) or (sel_b_load1 and ex6_frac_lod_dly( 3) ) );
fwd_b_frac_pre2_04: rf1_b_frac_pre2_b( 4) <= not( (sel_b_load0 and ex6_frac_lod_ear( 4) ) or (sel_b_load1 and ex6_frac_lod_dly( 4) ) );
fwd_b_frac_pre2_05: rf1_b_frac_pre2_b( 5) <= not( (sel_b_load0 and ex6_frac_lod_ear( 5) ) or (sel_b_load1 and ex6_frac_lod_dly( 5) ) );
fwd_b_frac_pre2_06: rf1_b_frac_pre2_b( 6) <= not( (sel_b_load0 and ex6_frac_lod_ear( 6) ) or (sel_b_load1 and ex6_frac_lod_dly( 6) ) );
fwd_b_frac_pre2_07: rf1_b_frac_pre2_b( 7) <= not( (sel_b_load0 and ex6_frac_lod_ear( 7) ) or (sel_b_load1 and ex6_frac_lod_dly( 7) ) );
fwd_b_frac_pre2_08: rf1_b_frac_pre2_b( 8) <= not( (sel_b_load0 and ex6_frac_lod_ear( 8) ) or (sel_b_load1 and ex6_frac_lod_dly( 8) ) );
fwd_b_frac_pre2_09: rf1_b_frac_pre2_b( 9) <= not( (sel_b_load0 and ex6_frac_lod_ear( 9) ) or (sel_b_load1 and ex6_frac_lod_dly( 9) ) );
fwd_b_frac_pre2_10: rf1_b_frac_pre2_b(10) <= not( (sel_b_load0 and ex6_frac_lod_ear(10) ) or (sel_b_load1 and ex6_frac_lod_dly(10) ) );
fwd_b_frac_pre2_11: rf1_b_frac_pre2_b(11) <= not( (sel_b_load0 and ex6_frac_lod_ear(11) ) or (sel_b_load1 and ex6_frac_lod_dly(11) ) );
fwd_b_frac_pre2_12: rf1_b_frac_pre2_b(12) <= not( (sel_b_load0 and ex6_frac_lod_ear(12) ) or (sel_b_load1 and ex6_frac_lod_dly(12) ) );
fwd_b_frac_pre2_13: rf1_b_frac_pre2_b(13) <= not( (sel_b_load0 and ex6_frac_lod_ear(13) ) or (sel_b_load1 and ex6_frac_lod_dly(13) ) );
fwd_b_frac_pre2_14: rf1_b_frac_pre2_b(14) <= not( (sel_b_load0 and ex6_frac_lod_ear(14) ) or (sel_b_load1 and ex6_frac_lod_dly(14) ) );
fwd_b_frac_pre2_15: rf1_b_frac_pre2_b(15) <= not( (sel_b_load0 and ex6_frac_lod_ear(15) ) or (sel_b_load1 and ex6_frac_lod_dly(15) ) );
fwd_b_frac_pre2_16: rf1_b_frac_pre2_b(16) <= not( (sel_b_load0 and ex6_frac_lod_ear(16) ) or (sel_b_load1 and ex6_frac_lod_dly(16) ) );
fwd_b_frac_pre2_17: rf1_b_frac_pre2_b(17) <= not( (sel_b_load0 and ex6_frac_lod_ear(17) ) or (sel_b_load1 and ex6_frac_lod_dly(17) ) );
fwd_b_frac_pre2_18: rf1_b_frac_pre2_b(18) <= not( (sel_b_load0 and ex6_frac_lod_ear(18) ) or (sel_b_load1 and ex6_frac_lod_dly(18) ) );
fwd_b_frac_pre2_19: rf1_b_frac_pre2_b(19) <= not( (sel_b_load0 and ex6_frac_lod_ear(19) ) or (sel_b_load1 and ex6_frac_lod_dly(19) ) );
fwd_b_frac_pre2_20: rf1_b_frac_pre2_b(20) <= not( (sel_b_load0 and ex6_frac_lod_ear(20) ) or (sel_b_load1 and ex6_frac_lod_dly(20) ) );
fwd_b_frac_pre2_21: rf1_b_frac_pre2_b(21) <= not( (sel_b_load0 and ex6_frac_lod_ear(21) ) or (sel_b_load1 and ex6_frac_lod_dly(21) ) );
fwd_b_frac_pre2_22: rf1_b_frac_pre2_b(22) <= not( (sel_b_load0 and ex6_frac_lod_ear(22) ) or (sel_b_load1 and ex6_frac_lod_dly(22) ) );
fwd_b_frac_pre2_23: rf1_b_frac_pre2_b(23) <= not( (sel_b_load0 and ex6_frac_lod_ear(23) ) or (sel_b_load1 and ex6_frac_lod_dly(23) ) );
fwd_b_frac_pre2_24: rf1_b_frac_pre2_b(24) <= not( (sel_b_load0 and ex6_frac_lod_ear(24) ) or (sel_b_load1 and ex6_frac_lod_dly(24) ) );
fwd_b_frac_pre2_25: rf1_b_frac_pre2_b(25) <= not( (sel_b_load0 and ex6_frac_lod_ear(25) ) or (sel_b_load1 and ex6_frac_lod_dly(25) ) );
fwd_b_frac_pre2_26: rf1_b_frac_pre2_b(26) <= not( (sel_b_load0 and ex6_frac_lod_ear(26) ) or (sel_b_load1 and ex6_frac_lod_dly(26) ) );
fwd_b_frac_pre2_27: rf1_b_frac_pre2_b(27) <= not( (sel_b_load0 and ex6_frac_lod_ear(27) ) or (sel_b_load1 and ex6_frac_lod_dly(27) ) );
fwd_b_frac_pre2_28: rf1_b_frac_pre2_b(28) <= not( (sel_b_load0 and ex6_frac_lod_ear(28) ) or (sel_b_load1 and ex6_frac_lod_dly(28) ) );
fwd_b_frac_pre2_29: rf1_b_frac_pre2_b(29) <= not( (sel_b_load0 and ex6_frac_lod_ear(29) ) or (sel_b_load1 and ex6_frac_lod_dly(29) ) );
fwd_b_frac_pre2_30: rf1_b_frac_pre2_b(30) <= not( (sel_b_load0 and ex6_frac_lod_ear(30) ) or (sel_b_load1 and ex6_frac_lod_dly(30) ) );
fwd_b_frac_pre2_31: rf1_b_frac_pre2_b(31) <= not( (sel_b_load0 and ex6_frac_lod_ear(31) ) or (sel_b_load1 and ex6_frac_lod_dly(31) ) );
fwd_b_frac_pre2_32: rf1_b_frac_pre2_b(32) <= not( (sel_b_load0 and ex6_frac_lod_ear(32) ) or (sel_b_load1 and ex6_frac_lod_dly(32) ) );
fwd_b_frac_pre2_33: rf1_b_frac_pre2_b(33) <= not( (sel_b_load0 and ex6_frac_lod_ear(33) ) or (sel_b_load1 and ex6_frac_lod_dly(33) ) );
fwd_b_frac_pre2_34: rf1_b_frac_pre2_b(34) <= not( (sel_b_load0 and ex6_frac_lod_ear(34) ) or (sel_b_load1 and ex6_frac_lod_dly(34) ) );
fwd_b_frac_pre2_35: rf1_b_frac_pre2_b(35) <= not( (sel_b_load0 and ex6_frac_lod_ear(35) ) or (sel_b_load1 and ex6_frac_lod_dly(35) ) );
fwd_b_frac_pre2_36: rf1_b_frac_pre2_b(36) <= not( (sel_b_load0 and ex6_frac_lod_ear(36) ) or (sel_b_load1 and ex6_frac_lod_dly(36) ) );
fwd_b_frac_pre2_37: rf1_b_frac_pre2_b(37) <= not( (sel_b_load0 and ex6_frac_lod_ear(37) ) or (sel_b_load1 and ex6_frac_lod_dly(37) ) );
fwd_b_frac_pre2_38: rf1_b_frac_pre2_b(38) <= not( (sel_b_load0 and ex6_frac_lod_ear(38) ) or (sel_b_load1 and ex6_frac_lod_dly(38) ) );
fwd_b_frac_pre2_39: rf1_b_frac_pre2_b(39) <= not( (sel_b_load0 and ex6_frac_lod_ear(39) ) or (sel_b_load1 and ex6_frac_lod_dly(39) ) );
fwd_b_frac_pre2_40: rf1_b_frac_pre2_b(40) <= not( (sel_b_load0 and ex6_frac_lod_ear(40) ) or (sel_b_load1 and ex6_frac_lod_dly(40) ) );
fwd_b_frac_pre2_41: rf1_b_frac_pre2_b(41) <= not( (sel_b_load0 and ex6_frac_lod_ear(41) ) or (sel_b_load1 and ex6_frac_lod_dly(41) ) );
fwd_b_frac_pre2_42: rf1_b_frac_pre2_b(42) <= not( (sel_b_load0 and ex6_frac_lod_ear(42) ) or (sel_b_load1 and ex6_frac_lod_dly(42) ) );
fwd_b_frac_pre2_43: rf1_b_frac_pre2_b(43) <= not( (sel_b_load0 and ex6_frac_lod_ear(43) ) or (sel_b_load1 and ex6_frac_lod_dly(43) ) );
fwd_b_frac_pre2_44: rf1_b_frac_pre2_b(44) <= not( (sel_b_load0 and ex6_frac_lod_ear(44) ) or (sel_b_load1 and ex6_frac_lod_dly(44) ) );
fwd_b_frac_pre2_45: rf1_b_frac_pre2_b(45) <= not( (sel_b_load0 and ex6_frac_lod_ear(45) ) or (sel_b_load1 and ex6_frac_lod_dly(45) ) );
fwd_b_frac_pre2_46: rf1_b_frac_pre2_b(46) <= not( (sel_b_load0 and ex6_frac_lod_ear(46) ) or (sel_b_load1 and ex6_frac_lod_dly(46) ) );
fwd_b_frac_pre2_47: rf1_b_frac_pre2_b(47) <= not( (sel_b_load0 and ex6_frac_lod_ear(47) ) or (sel_b_load1 and ex6_frac_lod_dly(47) ) );
fwd_b_frac_pre2_48: rf1_b_frac_pre2_b(48) <= not( (sel_b_load0 and ex6_frac_lod_ear(48) ) or (sel_b_load1 and ex6_frac_lod_dly(48) ) );
fwd_b_frac_pre2_49: rf1_b_frac_pre2_b(49) <= not( (sel_b_load0 and ex6_frac_lod_ear(49) ) or (sel_b_load1 and ex6_frac_lod_dly(49) ) );
fwd_b_frac_pre2_50: rf1_b_frac_pre2_b(50) <= not( (sel_b_load0 and ex6_frac_lod_ear(50) ) or (sel_b_load1 and ex6_frac_lod_dly(50) ) );
fwd_b_frac_pre2_51: rf1_b_frac_pre2_b(51) <= not( (sel_b_load0 and ex6_frac_lod_ear(51) ) or (sel_b_load1 and ex6_frac_lod_dly(51) ) );
fwd_b_frac_pre2_52: rf1_b_frac_pre2_b(52) <= not( (sel_b_load0 and ex6_frac_lod_ear(52) ) or (sel_b_load1 and ex6_frac_lod_dly(52) ) );


fwd_a_frac_pre_00:  rf1_a_frac_pre( 0) <= not( rf1_a_frac_pre1_b( 0) and rf1_a_frac_pre2_b( 0)  ); 
fwd_a_frac_pre_01:  rf1_a_frac_pre( 1) <= not( rf1_a_frac_pre1_b( 1) and rf1_a_frac_pre2_b( 1)  ); 
fwd_a_frac_pre_02:  rf1_a_frac_pre( 2) <= not( rf1_a_frac_pre1_b( 2) and rf1_a_frac_pre2_b( 2)  ); 
fwd_a_frac_pre_03:  rf1_a_frac_pre( 3) <= not( rf1_a_frac_pre1_b( 3) and rf1_a_frac_pre2_b( 3)  ); 
fwd_a_frac_pre_04:  rf1_a_frac_pre( 4) <= not( rf1_a_frac_pre1_b( 4) and rf1_a_frac_pre2_b( 4)  ); 
fwd_a_frac_pre_05:  rf1_a_frac_pre( 5) <= not( rf1_a_frac_pre1_b( 5) and rf1_a_frac_pre2_b( 5)  ); 
fwd_a_frac_pre_06:  rf1_a_frac_pre( 6) <= not( rf1_a_frac_pre1_b( 6) and rf1_a_frac_pre2_b( 6)  ); 
fwd_a_frac_pre_07:  rf1_a_frac_pre( 7) <= not( rf1_a_frac_pre1_b( 7) and rf1_a_frac_pre2_b( 7)  ); 
fwd_a_frac_pre_08:  rf1_a_frac_pre( 8) <= not( rf1_a_frac_pre1_b( 8) and rf1_a_frac_pre2_b( 8)  ); 
fwd_a_frac_pre_09:  rf1_a_frac_pre( 9) <= not( rf1_a_frac_pre1_b( 9) and rf1_a_frac_pre2_b( 9)  ); 
fwd_a_frac_pre_10:  rf1_a_frac_pre(10) <= not( rf1_a_frac_pre1_b(10) and rf1_a_frac_pre2_b(10)  ); 
fwd_a_frac_pre_11:  rf1_a_frac_pre(11) <= not( rf1_a_frac_pre1_b(11) and rf1_a_frac_pre2_b(11)  ); 
fwd_a_frac_pre_12:  rf1_a_frac_pre(12) <= not( rf1_a_frac_pre1_b(12) and rf1_a_frac_pre2_b(12)  ); 
fwd_a_frac_pre_13:  rf1_a_frac_pre(13) <= not( rf1_a_frac_pre1_b(13) and rf1_a_frac_pre2_b(13)  ); 
fwd_a_frac_pre_14:  rf1_a_frac_pre(14) <= not( rf1_a_frac_pre1_b(14) and rf1_a_frac_pre2_b(14)  ); 
fwd_a_frac_pre_15:  rf1_a_frac_pre(15) <= not( rf1_a_frac_pre1_b(15) and rf1_a_frac_pre2_b(15)  ); 
fwd_a_frac_pre_16:  rf1_a_frac_pre(16) <= not( rf1_a_frac_pre1_b(16) and rf1_a_frac_pre2_b(16)  ); 
fwd_a_frac_pre_17:  rf1_a_frac_pre(17) <= not( rf1_a_frac_pre1_b(17) and rf1_a_frac_pre2_b(17)  ); 
fwd_a_frac_pre_18:  rf1_a_frac_pre(18) <= not( rf1_a_frac_pre1_b(18) and rf1_a_frac_pre2_b(18)  ); 
fwd_a_frac_pre_19:  rf1_a_frac_pre(19) <= not( rf1_a_frac_pre1_b(19) and rf1_a_frac_pre2_b(19)  ); 
fwd_a_frac_pre_20:  rf1_a_frac_pre(20) <= not( rf1_a_frac_pre1_b(20) and rf1_a_frac_pre2_b(20)  ); 
fwd_a_frac_pre_21:  rf1_a_frac_pre(21) <= not( rf1_a_frac_pre1_b(21) and rf1_a_frac_pre2_b(21)  ); 
fwd_a_frac_pre_22:  rf1_a_frac_pre(22) <= not( rf1_a_frac_pre1_b(22) and rf1_a_frac_pre2_b(22)  ); 
fwd_a_frac_pre_23:  rf1_a_frac_pre(23) <= not( rf1_a_frac_pre1_b(23) and rf1_a_frac_pre2_b(23)  ); 
fwd_a_frac_pre_24:  rf1_a_frac_pre(24) <= not( rf1_a_frac_pre1_b(24) and rf1_a_frac_pre2_b(24)  ); 
fwd_a_frac_pre_25:  rf1_a_frac_pre(25) <= not( rf1_a_frac_pre1_b(25) and rf1_a_frac_pre2_b(25)  ); 
fwd_a_frac_pre_26:  rf1_a_frac_pre(26) <= not( rf1_a_frac_pre1_b(26) and rf1_a_frac_pre2_b(26)  ); 
fwd_a_frac_pre_27:  rf1_a_frac_pre(27) <= not( rf1_a_frac_pre1_b(27) and rf1_a_frac_pre2_b(27)  ); 
fwd_a_frac_pre_28:  rf1_a_frac_pre(28) <= not( rf1_a_frac_pre1_b(28) and rf1_a_frac_pre2_b(28)  ); 
fwd_a_frac_pre_29:  rf1_a_frac_pre(29) <= not( rf1_a_frac_pre1_b(29) and rf1_a_frac_pre2_b(29)  ); 
fwd_a_frac_pre_30:  rf1_a_frac_pre(30) <= not( rf1_a_frac_pre1_b(30) and rf1_a_frac_pre2_b(30)  ); 
fwd_a_frac_pre_31:  rf1_a_frac_pre(31) <= not( rf1_a_frac_pre1_b(31) and rf1_a_frac_pre2_b(31)  ); 
fwd_a_frac_pre_32:  rf1_a_frac_pre(32) <= not( rf1_a_frac_pre1_b(32) and rf1_a_frac_pre2_b(32)  ); 
fwd_a_frac_pre_33:  rf1_a_frac_pre(33) <= not( rf1_a_frac_pre1_b(33) and rf1_a_frac_pre2_b(33)  ); 
fwd_a_frac_pre_34:  rf1_a_frac_pre(34) <= not( rf1_a_frac_pre1_b(34) and rf1_a_frac_pre2_b(34)  ); 
fwd_a_frac_pre_35:  rf1_a_frac_pre(35) <= not( rf1_a_frac_pre1_b(35) and rf1_a_frac_pre2_b(35)  ); 
fwd_a_frac_pre_36:  rf1_a_frac_pre(36) <= not( rf1_a_frac_pre1_b(36) and rf1_a_frac_pre2_b(36)  ); 
fwd_a_frac_pre_37:  rf1_a_frac_pre(37) <= not( rf1_a_frac_pre1_b(37) and rf1_a_frac_pre2_b(37)  ); 
fwd_a_frac_pre_38:  rf1_a_frac_pre(38) <= not( rf1_a_frac_pre1_b(38) and rf1_a_frac_pre2_b(38)  ); 
fwd_a_frac_pre_39:  rf1_a_frac_pre(39) <= not( rf1_a_frac_pre1_b(39) and rf1_a_frac_pre2_b(39)  ); 
fwd_a_frac_pre_40:  rf1_a_frac_pre(40) <= not( rf1_a_frac_pre1_b(40) and rf1_a_frac_pre2_b(40)  ); 
fwd_a_frac_pre_41:  rf1_a_frac_pre(41) <= not( rf1_a_frac_pre1_b(41) and rf1_a_frac_pre2_b(41)  ); 
fwd_a_frac_pre_42:  rf1_a_frac_pre(42) <= not( rf1_a_frac_pre1_b(42) and rf1_a_frac_pre2_b(42)  ); 
fwd_a_frac_pre_43:  rf1_a_frac_pre(43) <= not( rf1_a_frac_pre1_b(43) and rf1_a_frac_pre2_b(43)  ); 
fwd_a_frac_pre_44:  rf1_a_frac_pre(44) <= not( rf1_a_frac_pre1_b(44) and rf1_a_frac_pre2_b(44)  ); 
fwd_a_frac_pre_45:  rf1_a_frac_pre(45) <= not( rf1_a_frac_pre1_b(45) and rf1_a_frac_pre2_b(45)  ); 
fwd_a_frac_pre_46:  rf1_a_frac_pre(46) <= not( rf1_a_frac_pre1_b(46) and rf1_a_frac_pre2_b(46)  ); 
fwd_a_frac_pre_47:  rf1_a_frac_pre(47) <= not( rf1_a_frac_pre1_b(47) and rf1_a_frac_pre2_b(47)  ); 
fwd_a_frac_pre_48:  rf1_a_frac_pre(48) <= not( rf1_a_frac_pre1_b(48) and rf1_a_frac_pre2_b(48)  ); 
fwd_a_frac_pre_49:  rf1_a_frac_pre(49) <= not( rf1_a_frac_pre1_b(49) and rf1_a_frac_pre2_b(49)  ); 
fwd_a_frac_pre_50:  rf1_a_frac_pre(50) <= not( rf1_a_frac_pre1_b(50) and rf1_a_frac_pre2_b(50)  ); 
fwd_a_frac_pre_51:  rf1_a_frac_pre(51) <= not( rf1_a_frac_pre1_b(51) and rf1_a_frac_pre2_b(51)  ); 
fwd_a_frac_pre_52:  rf1_a_frac_pre(52) <= not( rf1_a_frac_pre1_b(52) and rf1_a_frac_pre2_b(52)  ); 

fwd_c_frac_pre_00:  rf1_c_frac_pre( 0) <= not( rf1_c_frac_pre1_b( 0) and rf1_c_frac_pre2_b( 0) and rf1_c_frac_pre3_b( 0) );
fwd_c_frac_pre_01:  rf1_c_frac_pre( 1) <= not( rf1_c_frac_pre1_b( 1) and rf1_c_frac_pre2_b( 1) and rf1_c_frac_pre3_b( 1) );
fwd_c_frac_pre_02:  rf1_c_frac_pre( 2) <= not( rf1_c_frac_pre1_b( 2) and rf1_c_frac_pre2_b( 2) and rf1_c_frac_pre3_b( 2) );
fwd_c_frac_pre_03:  rf1_c_frac_pre( 3) <= not( rf1_c_frac_pre1_b( 3) and rf1_c_frac_pre2_b( 3) and rf1_c_frac_pre3_b( 3) );
fwd_c_frac_pre_04:  rf1_c_frac_pre( 4) <= not( rf1_c_frac_pre1_b( 4) and rf1_c_frac_pre2_b( 4) and rf1_c_frac_pre3_b( 4) );
fwd_c_frac_pre_05:  rf1_c_frac_pre( 5) <= not( rf1_c_frac_pre1_b( 5) and rf1_c_frac_pre2_b( 5) and rf1_c_frac_pre3_b( 5) );
fwd_c_frac_pre_06:  rf1_c_frac_pre( 6) <= not( rf1_c_frac_pre1_b( 6) and rf1_c_frac_pre2_b( 6) and rf1_c_frac_pre3_b( 6) );
fwd_c_frac_pre_07:  rf1_c_frac_pre( 7) <= not( rf1_c_frac_pre1_b( 7) and rf1_c_frac_pre2_b( 7) and rf1_c_frac_pre3_b( 7) );
fwd_c_frac_pre_08:  rf1_c_frac_pre( 8) <= not( rf1_c_frac_pre1_b( 8) and rf1_c_frac_pre2_b( 8) and rf1_c_frac_pre3_b( 8) );
fwd_c_frac_pre_09:  rf1_c_frac_pre( 9) <= not( rf1_c_frac_pre1_b( 9) and rf1_c_frac_pre2_b( 9) and rf1_c_frac_pre3_b( 9) );
fwd_c_frac_pre_10:  rf1_c_frac_pre(10) <= not( rf1_c_frac_pre1_b(10) and rf1_c_frac_pre2_b(10) and rf1_c_frac_pre3_b(10) );
fwd_c_frac_pre_11:  rf1_c_frac_pre(11) <= not( rf1_c_frac_pre1_b(11) and rf1_c_frac_pre2_b(11) and rf1_c_frac_pre3_b(11) );
fwd_c_frac_pre_12:  rf1_c_frac_pre(12) <= not( rf1_c_frac_pre1_b(12) and rf1_c_frac_pre2_b(12) and rf1_c_frac_pre3_b(12) );
fwd_c_frac_pre_13:  rf1_c_frac_pre(13) <= not( rf1_c_frac_pre1_b(13) and rf1_c_frac_pre2_b(13) and rf1_c_frac_pre3_b(13) );
fwd_c_frac_pre_14:  rf1_c_frac_pre(14) <= not( rf1_c_frac_pre1_b(14) and rf1_c_frac_pre2_b(14) and rf1_c_frac_pre3_b(14) );
fwd_c_frac_pre_15:  rf1_c_frac_pre(15) <= not( rf1_c_frac_pre1_b(15) and rf1_c_frac_pre2_b(15) and rf1_c_frac_pre3_b(15) );
fwd_c_frac_pre_16:  rf1_c_frac_pre(16) <= not( rf1_c_frac_pre1_b(16) and rf1_c_frac_pre2_b(16) and rf1_c_frac_pre3_b(16) );
fwd_c_frac_pre_17:  rf1_c_frac_pre(17) <= not( rf1_c_frac_pre1_b(17) and rf1_c_frac_pre2_b(17) and rf1_c_frac_pre3_b(17) );
fwd_c_frac_pre_18:  rf1_c_frac_pre(18) <= not( rf1_c_frac_pre1_b(18) and rf1_c_frac_pre2_b(18) and rf1_c_frac_pre3_b(18) );
fwd_c_frac_pre_19:  rf1_c_frac_pre(19) <= not( rf1_c_frac_pre1_b(19) and rf1_c_frac_pre2_b(19) and rf1_c_frac_pre3_b(19) );
fwd_c_frac_pre_20:  rf1_c_frac_pre(20) <= not( rf1_c_frac_pre1_b(20) and rf1_c_frac_pre2_b(20) and rf1_c_frac_pre3_b(20) );
fwd_c_frac_pre_21:  rf1_c_frac_pre(21) <= not( rf1_c_frac_pre1_b(21) and rf1_c_frac_pre2_b(21) and rf1_c_frac_pre3_b(21) );
fwd_c_frac_pre_22:  rf1_c_frac_pre(22) <= not( rf1_c_frac_pre1_b(22) and rf1_c_frac_pre2_b(22) and rf1_c_frac_pre3_b(22) );
fwd_c_frac_pre_23:  rf1_c_frac_pre(23) <= not( rf1_c_frac_pre1_b(23) and rf1_c_frac_pre2_b(23) and rf1_c_frac_pre3_b(23) );
fwd_c_frac_pre_24:  rf1_c_frac_pre(24) <= not( rf1_c_frac_pre1_b(24) and rf1_c_frac_pre2_b(24) and rf1_c_frac_pre3_b(24) );
fwd_c_frac_pre_25:  rf1_c_frac_pre(25) <= not( rf1_c_frac_pre1_b(25) and rf1_c_frac_pre2_b(25) and rf1_c_frac_pre3_b(25) );
fwd_c_frac_pre_26:  rf1_c_frac_pre(26) <= not( rf1_c_frac_pre1_b(26) and rf1_c_frac_pre2_b(26) and rf1_c_frac_pre3_b(26) );
fwd_c_frac_pre_27:  rf1_c_frac_pre(27) <= not( rf1_c_frac_pre1_b(27) and rf1_c_frac_pre2_b(27) and rf1_c_frac_pre3_b(27) );
fwd_c_frac_pre_28:  rf1_c_frac_pre(28) <= not( rf1_c_frac_pre1_b(28) and rf1_c_frac_pre2_b(28) and rf1_c_frac_pre3_b(28) );
fwd_c_frac_pre_29:  rf1_c_frac_pre(29) <= not( rf1_c_frac_pre1_b(29) and rf1_c_frac_pre2_b(29) and rf1_c_frac_pre3_b(29) );
fwd_c_frac_pre_30:  rf1_c_frac_pre(30) <= not( rf1_c_frac_pre1_b(30) and rf1_c_frac_pre2_b(30) and rf1_c_frac_pre3_b(30) );
fwd_c_frac_pre_31:  rf1_c_frac_pre(31) <= not( rf1_c_frac_pre1_b(31) and rf1_c_frac_pre2_b(31) and rf1_c_frac_pre3_b(31) );
fwd_c_frac_pre_32:  rf1_c_frac_pre(32) <= not( rf1_c_frac_pre1_b(32) and rf1_c_frac_pre2_b(32) and rf1_c_frac_pre3_b(32) );
fwd_c_frac_pre_33:  rf1_c_frac_pre(33) <= not( rf1_c_frac_pre1_b(33) and rf1_c_frac_pre2_b(33) and rf1_c_frac_pre3_b(33) );
fwd_c_frac_pre_34:  rf1_c_frac_pre(34) <= not( rf1_c_frac_pre1_b(34) and rf1_c_frac_pre2_b(34) and rf1_c_frac_pre3_b(34) );
fwd_c_frac_pre_35:  rf1_c_frac_pre(35) <= not( rf1_c_frac_pre1_b(35) and rf1_c_frac_pre2_b(35) and rf1_c_frac_pre3_b(35) );
fwd_c_frac_pre_36:  rf1_c_frac_pre(36) <= not( rf1_c_frac_pre1_b(36) and rf1_c_frac_pre2_b(36) and rf1_c_frac_pre3_b(36) );
fwd_c_frac_pre_37:  rf1_c_frac_pre(37) <= not( rf1_c_frac_pre1_b(37) and rf1_c_frac_pre2_b(37) and rf1_c_frac_pre3_b(37) );
fwd_c_frac_pre_38:  rf1_c_frac_pre(38) <= not( rf1_c_frac_pre1_b(38) and rf1_c_frac_pre2_b(38) and rf1_c_frac_pre3_b(38) );
fwd_c_frac_pre_39:  rf1_c_frac_pre(39) <= not( rf1_c_frac_pre1_b(39) and rf1_c_frac_pre2_b(39) and rf1_c_frac_pre3_b(39) );
fwd_c_frac_pre_40:  rf1_c_frac_pre(40) <= not( rf1_c_frac_pre1_b(40) and rf1_c_frac_pre2_b(40) and rf1_c_frac_pre3_b(40) );
fwd_c_frac_pre_41:  rf1_c_frac_pre(41) <= not( rf1_c_frac_pre1_b(41) and rf1_c_frac_pre2_b(41) and rf1_c_frac_pre3_b(41) );
fwd_c_frac_pre_42:  rf1_c_frac_pre(42) <= not( rf1_c_frac_pre1_b(42) and rf1_c_frac_pre2_b(42) and rf1_c_frac_pre3_b(42) );
fwd_c_frac_pre_43:  rf1_c_frac_pre(43) <= not( rf1_c_frac_pre1_b(43) and rf1_c_frac_pre2_b(43) and rf1_c_frac_pre3_b(43) );
fwd_c_frac_pre_44:  rf1_c_frac_pre(44) <= not( rf1_c_frac_pre1_b(44) and rf1_c_frac_pre2_b(44) and rf1_c_frac_pre3_b(44) );
fwd_c_frac_pre_45:  rf1_c_frac_pre(45) <= not( rf1_c_frac_pre1_b(45) and rf1_c_frac_pre2_b(45) and rf1_c_frac_pre3_b(45) );
fwd_c_frac_pre_46:  rf1_c_frac_pre(46) <= not( rf1_c_frac_pre1_b(46) and rf1_c_frac_pre2_b(46) and rf1_c_frac_pre3_b(46) );
fwd_c_frac_pre_47:  rf1_c_frac_pre(47) <= not( rf1_c_frac_pre1_b(47) and rf1_c_frac_pre2_b(47) and rf1_c_frac_pre3_b(47) );
fwd_c_frac_pre_48:  rf1_c_frac_pre(48) <= not( rf1_c_frac_pre1_b(48) and rf1_c_frac_pre2_b(48) and rf1_c_frac_pre3_b(48) );
fwd_c_frac_pre_49:  rf1_c_frac_pre(49) <= not( rf1_c_frac_pre1_b(49) and rf1_c_frac_pre2_b(49) and rf1_c_frac_pre3_b(49) );
fwd_c_frac_pre_50:  rf1_c_frac_pre(50) <= not( rf1_c_frac_pre1_b(50) and rf1_c_frac_pre2_b(50) and rf1_c_frac_pre3_b(50) );
fwd_c_frac_pre_51:  rf1_c_frac_pre(51) <= not( rf1_c_frac_pre1_b(51) and rf1_c_frac_pre2_b(51) and rf1_c_frac_pre3_b(51) );
fwd_c_frac_pre_52:  rf1_c_frac_pre(52) <= not( rf1_c_frac_pre1_b(52) and rf1_c_frac_pre2_b(52) and rf1_c_frac_pre3_b(52) );

fwd_c_frac_pre_24h: rf1_c_frac_pre_hulp <= not( rf1_c_frac_pre1_b(24) and rf1_c_frac_pre2_b(24) and rf1_c_frac_pre3_hulp_b );


fwd_b_frac_pre_00:  rf1_b_frac_pre( 0) <= not( rf1_b_frac_pre1_b( 0) and rf1_b_frac_pre2_b( 0) and rf1_b_frac_pre3_b( 0) );
fwd_b_frac_pre_01:  rf1_b_frac_pre( 1) <= not( rf1_b_frac_pre1_b( 1) and rf1_b_frac_pre2_b( 1) and rf1_b_frac_pre3_b( 1) );
fwd_b_frac_pre_02:  rf1_b_frac_pre( 2) <= not( rf1_b_frac_pre1_b( 2) and rf1_b_frac_pre2_b( 2)      );
fwd_b_frac_pre_03:  rf1_b_frac_pre( 3) <= not( rf1_b_frac_pre1_b( 3) and rf1_b_frac_pre2_b( 3)      );
fwd_b_frac_pre_04:  rf1_b_frac_pre( 4) <= not( rf1_b_frac_pre1_b( 4) and rf1_b_frac_pre2_b( 4)      );
fwd_b_frac_pre_05:  rf1_b_frac_pre( 5) <= not( rf1_b_frac_pre1_b( 5) and rf1_b_frac_pre2_b( 5)      );
fwd_b_frac_pre_06:  rf1_b_frac_pre( 6) <= not( rf1_b_frac_pre1_b( 6) and rf1_b_frac_pre2_b( 6)      );
fwd_b_frac_pre_07:  rf1_b_frac_pre( 7) <= not( rf1_b_frac_pre1_b( 7) and rf1_b_frac_pre2_b( 7)      );
fwd_b_frac_pre_08:  rf1_b_frac_pre( 8) <= not( rf1_b_frac_pre1_b( 8) and rf1_b_frac_pre2_b( 8)      );
fwd_b_frac_pre_09:  rf1_b_frac_pre( 9) <= not( rf1_b_frac_pre1_b( 9) and rf1_b_frac_pre2_b( 9)      );
fwd_b_frac_pre_10:  rf1_b_frac_pre(10) <= not( rf1_b_frac_pre1_b(10) and rf1_b_frac_pre2_b(10)      );
fwd_b_frac_pre_11:  rf1_b_frac_pre(11) <= not( rf1_b_frac_pre1_b(11) and rf1_b_frac_pre2_b(11)      );
fwd_b_frac_pre_12:  rf1_b_frac_pre(12) <= not( rf1_b_frac_pre1_b(12) and rf1_b_frac_pre2_b(12)      );
fwd_b_frac_pre_13:  rf1_b_frac_pre(13) <= not( rf1_b_frac_pre1_b(13) and rf1_b_frac_pre2_b(13)      );
fwd_b_frac_pre_14:  rf1_b_frac_pre(14) <= not( rf1_b_frac_pre1_b(14) and rf1_b_frac_pre2_b(14)      );
fwd_b_frac_pre_15:  rf1_b_frac_pre(15) <= not( rf1_b_frac_pre1_b(15) and rf1_b_frac_pre2_b(15)      );
fwd_b_frac_pre_16:  rf1_b_frac_pre(16) <= not( rf1_b_frac_pre1_b(16) and rf1_b_frac_pre2_b(16)      );
fwd_b_frac_pre_17:  rf1_b_frac_pre(17) <= not( rf1_b_frac_pre1_b(17) and rf1_b_frac_pre2_b(17)      );
fwd_b_frac_pre_18:  rf1_b_frac_pre(18) <= not( rf1_b_frac_pre1_b(18) and rf1_b_frac_pre2_b(18)      );
fwd_b_frac_pre_19:  rf1_b_frac_pre(19) <= not( rf1_b_frac_pre1_b(19) and rf1_b_frac_pre2_b(19)      );
fwd_b_frac_pre_20:  rf1_b_frac_pre(20) <= not( rf1_b_frac_pre1_b(20) and rf1_b_frac_pre2_b(20)      );
fwd_b_frac_pre_21:  rf1_b_frac_pre(21) <= not( rf1_b_frac_pre1_b(21) and rf1_b_frac_pre2_b(21)      );
fwd_b_frac_pre_22:  rf1_b_frac_pre(22) <= not( rf1_b_frac_pre1_b(22) and rf1_b_frac_pre2_b(22)      );
fwd_b_frac_pre_23:  rf1_b_frac_pre(23) <= not( rf1_b_frac_pre1_b(23) and rf1_b_frac_pre2_b(23)      );
fwd_b_frac_pre_24:  rf1_b_frac_pre(24) <= not( rf1_b_frac_pre1_b(24) and rf1_b_frac_pre2_b(24)      );
fwd_b_frac_pre_25:  rf1_b_frac_pre(25) <= not( rf1_b_frac_pre1_b(25) and rf1_b_frac_pre2_b(25)      );
fwd_b_frac_pre_26:  rf1_b_frac_pre(26) <= not( rf1_b_frac_pre1_b(26) and rf1_b_frac_pre2_b(26)      );
fwd_b_frac_pre_27:  rf1_b_frac_pre(27) <= not( rf1_b_frac_pre1_b(27) and rf1_b_frac_pre2_b(27)      );
fwd_b_frac_pre_28:  rf1_b_frac_pre(28) <= not( rf1_b_frac_pre1_b(28) and rf1_b_frac_pre2_b(28)      );
fwd_b_frac_pre_29:  rf1_b_frac_pre(29) <= not( rf1_b_frac_pre1_b(29) and rf1_b_frac_pre2_b(29)      );
fwd_b_frac_pre_30:  rf1_b_frac_pre(30) <= not( rf1_b_frac_pre1_b(30) and rf1_b_frac_pre2_b(30)      );
fwd_b_frac_pre_31:  rf1_b_frac_pre(31) <= not( rf1_b_frac_pre1_b(31) and rf1_b_frac_pre2_b(31)      );
fwd_b_frac_pre_32:  rf1_b_frac_pre(32) <= not( rf1_b_frac_pre1_b(32) and rf1_b_frac_pre2_b(32)      );
fwd_b_frac_pre_33:  rf1_b_frac_pre(33) <= not( rf1_b_frac_pre1_b(33) and rf1_b_frac_pre2_b(33)      );
fwd_b_frac_pre_34:  rf1_b_frac_pre(34) <= not( rf1_b_frac_pre1_b(34) and rf1_b_frac_pre2_b(34)      );
fwd_b_frac_pre_35:  rf1_b_frac_pre(35) <= not( rf1_b_frac_pre1_b(35) and rf1_b_frac_pre2_b(35)      );
fwd_b_frac_pre_36:  rf1_b_frac_pre(36) <= not( rf1_b_frac_pre1_b(36) and rf1_b_frac_pre2_b(36)      );
fwd_b_frac_pre_37:  rf1_b_frac_pre(37) <= not( rf1_b_frac_pre1_b(37) and rf1_b_frac_pre2_b(37)      );
fwd_b_frac_pre_38:  rf1_b_frac_pre(38) <= not( rf1_b_frac_pre1_b(38) and rf1_b_frac_pre2_b(38)      );
fwd_b_frac_pre_39:  rf1_b_frac_pre(39) <= not( rf1_b_frac_pre1_b(39) and rf1_b_frac_pre2_b(39)      );
fwd_b_frac_pre_40:  rf1_b_frac_pre(40) <= not( rf1_b_frac_pre1_b(40) and rf1_b_frac_pre2_b(40)      );
fwd_b_frac_pre_41:  rf1_b_frac_pre(41) <= not( rf1_b_frac_pre1_b(41) and rf1_b_frac_pre2_b(41)      );
fwd_b_frac_pre_42:  rf1_b_frac_pre(42) <= not( rf1_b_frac_pre1_b(42) and rf1_b_frac_pre2_b(42)      );
fwd_b_frac_pre_43:  rf1_b_frac_pre(43) <= not( rf1_b_frac_pre1_b(43) and rf1_b_frac_pre2_b(43)      );
fwd_b_frac_pre_44:  rf1_b_frac_pre(44) <= not( rf1_b_frac_pre1_b(44) and rf1_b_frac_pre2_b(44)      );
fwd_b_frac_pre_45:  rf1_b_frac_pre(45) <= not( rf1_b_frac_pre1_b(45) and rf1_b_frac_pre2_b(45)      );
fwd_b_frac_pre_46:  rf1_b_frac_pre(46) <= not( rf1_b_frac_pre1_b(46) and rf1_b_frac_pre2_b(46)      );
fwd_b_frac_pre_47:  rf1_b_frac_pre(47) <= not( rf1_b_frac_pre1_b(47) and rf1_b_frac_pre2_b(47)      );
fwd_b_frac_pre_48:  rf1_b_frac_pre(48) <= not( rf1_b_frac_pre1_b(48) and rf1_b_frac_pre2_b(48)      );
fwd_b_frac_pre_49:  rf1_b_frac_pre(49) <= not( rf1_b_frac_pre1_b(49) and rf1_b_frac_pre2_b(49)      );
fwd_b_frac_pre_50:  rf1_b_frac_pre(50) <= not( rf1_b_frac_pre1_b(50) and rf1_b_frac_pre2_b(50)      );
fwd_b_frac_pre_51:  rf1_b_frac_pre(51) <= not( rf1_b_frac_pre1_b(51) and rf1_b_frac_pre2_b(51)      );
fwd_b_frac_pre_52:  rf1_b_frac_pre(52) <= not( rf1_b_frac_pre1_b(52) and rf1_b_frac_pre2_b(52)      );

       

       rf1_a_frac_prebyp(0 to 52) <= rf1_a_frac_pre(0 to 52);-- may need to manually repower
       rf1_c_frac_prebyp(0 to 52) <= rf1_c_frac_pre(0 to 52);
       rf1_b_frac_prebyp(0 to 52) <= rf1_b_frac_pre(0 to 52);
       rf1_c_frac_prebyp_hulp     <= rf1_c_frac_pre_hulp ;

 rf1_a_sign_fpr <= f_fpr_rf1_a_sign ; -- later on we may map in some inverters
 rf1_c_sign_fpr <= f_fpr_rf1_c_sign ;
 rf1_b_sign_fpr <= f_fpr_rf1_b_sign ;
 rf1_a_expo_fpr(1 to 13) <= f_fpr_rf1_a_expo(1 to 13) ;
 rf1_c_expo_fpr(1 to 13) <= f_fpr_rf1_c_expo(1 to 13) ;
 rf1_b_expo_fpr(1 to 13) <= f_fpr_rf1_b_expo(1 to 13) ;
 rf1_a_frac_fpr(0 to 52) <= f_fpr_rf1_a_frac(0 to 52) ;
 rf1_c_frac_fpr(0 to 52) <= f_fpr_rf1_c_frac(0 to 52) ;
 rf1_b_frac_fpr(0 to 52) <= f_fpr_rf1_b_frac(0 to 52) ;

-----------------------------------------------------------------------------------------
-- for the last level, need a seperate copy for each latch for the pass gate rules
--   (fpr is the late path ... so the mux is hierarchical to speed up that path)
-----------------------------------------------------------------------------------------

fwd_a_sign_fmt:    rf1_a_sign_fmt_b           <= not( (              sel_a_no_byp_s    and rf1_a_sign_fpr           ) or   rf1_a_sign_prebyp             );
fwd_a_sign_pic:    rf1_a_sign_pic_b           <= not( (              sel_a_no_byp_s    and rf1_a_sign_fpr           ) or   rf1_a_sign_prebyp             );
fwd_c_sign_fmt:    rf1_c_sign_fmt_b           <= not( (              sel_c_no_byp_s    and rf1_c_sign_fpr           ) or   rf1_c_sign_prebyp             );                            
fwd_c_sign_pic:    rf1_c_sign_pic_b           <= not( (              sel_c_no_byp_s    and rf1_c_sign_fpr           ) or   rf1_c_sign_prebyp             );                                                        
fwd_b_sign_fmt:    rf1_b_sign_fmt_b           <= not( (              sel_b_no_byp_s    and rf1_b_sign_fpr           ) or   rf1_b_sign_prebyp             );                            
fwd_b_sign_pic:    rf1_b_sign_pic_b           <= not( (              sel_b_no_byp_s    and rf1_b_sign_fpr           ) or   rf1_b_sign_prebyp             );
fwd_b_sign_alg:    rf1_b_sign_alg_b           <= not( (              sel_b_no_byp_s    and rf1_b_sign_fpr           ) or   rf1_b_sign_prebyp             );

fwd_a_expo_fmt:    rf1_a_expo_fmt_b(1 to 13)  <= not( ( (1 to 13  => sel_a_no_byp)     and rf1_a_expo_fpr(1 to 13)  ) or   rf1_a_expo_prebyp(1 to 13)    );
fwd_a_expo_eie:    rf1_a_expo_eie_b(1 to 13)  <= not( ( (1 to 13  => sel_a_no_byp)     and rf1_a_expo_fpr(1 to 13)  ) or   rf1_a_expo_prebyp(1 to 13)    );
fwd_a_expo_alg:    rf1_a_expo_alg_b(1 to 13)  <= not( ( (1 to 13  => sel_a_no_byp)     and rf1_a_expo_fpr(1 to 13)  ) or   rf1_a_expo_prebyp(1 to 13)    );
fwd_c_expo_fmt:    rf1_c_expo_fmt_b(1 to 13)  <= not( ( (1 to 13  => sel_c_no_byp)     and rf1_c_expo_fpr(1 to 13)  ) or   rf1_c_expo_prebyp(1 to 13)    );
fwd_c_expo_eie:    rf1_c_expo_eie_b(1 to 13)  <= not( ( (1 to 13  => sel_c_no_byp)     and rf1_c_expo_fpr(1 to 13)  ) or   rf1_c_expo_prebyp(1 to 13)    );
fwd_c_expo_alg:    rf1_c_expo_alg_b(1 to 13)  <= not( ( (1 to 13  => sel_c_no_byp)     and rf1_c_expo_fpr(1 to 13)  ) or   rf1_c_expo_prebyp(1 to 13)    );
fwd_b_expo_fmt:    rf1_b_expo_fmt_b(1 to 13)  <= not( ( (1 to 13  => sel_b_no_byp)     and rf1_b_expo_fpr(1 to 13)  ) or   rf1_b_expo_prebyp(1 to 13)    );       
fwd_b_expo_eie:    rf1_b_expo_eie_b(1 to 13)  <= not( ( (1 to 13  => sel_b_no_byp)     and rf1_b_expo_fpr(1 to 13)  ) or   rf1_b_expo_prebyp(1 to 13)    );       
fwd_b_expo_alg:    rf1_b_expo_alg_b(1 to 13)  <= not( ( (1 to 13  => sel_b_no_byp)     and rf1_b_expo_fpr(1 to 13)  ) or   rf1_b_expo_prebyp(1 to 13)    );       

fwd_a_frac_fmt_00: rf1_a_frac_fmt_b(0 to 23)  <= not( ( (0 to 23  => sel_a_no_byp)     AND rf1_a_frac_fpr(0 to 23)  ) or   rf1_a_frac_prebyp(0 to 23)    );
fwd_a_frac_mul_00: rf1_a_frac_mul_b(0 to 23)  <= not( ( (0 to 23  => sel_a_no_byp)     AND rf1_a_frac_fpr(0 to 23)  ) or   rf1_a_frac_prebyp(0 to 23)    );
fwd_a_frac_mul_17: rf1_a_frac_mul_17_b        <= not( (              sel_a_no_byp      AND rf1_a_frac_fpr(17)       ) or   rf1_a_frac_prebyp(17)         );
fwd_a_frac_fmt_24: rf1_a_frac_fmt_b(24 to 52) <= not( ( (24 to 52 => sel_a_no_byp)     AND rf1_a_frac_fpr(24 to 52) ) or   rf1_a_frac_prebyp(24 to 52)   );
fwd_a_frac_mul_24: rf1_a_frac_mul_b(24 to 52) <= not( ( (24 to 52 => sel_a_no_byp)     AND rf1_a_frac_fpr(24 to 52) ) or   rf1_a_frac_prebyp(24 to 52)   ); 
fwd_a_frac_mul_35: rf1_a_frac_mul_35_b        <= not( (              sel_a_no_byp      AND rf1_a_frac_fpr(35)       ) or   rf1_a_frac_prebyp(35)         ); 

fwd_c_frac_fmt_00: rf1_c_frac_fmt_b(0 to 23)  <= not( ( (0 to 23  => sel_c_no_byp)     AND rf1_c_frac_fpr(0 to 23)  ) or   rf1_c_frac_prebyp(0 to 23)    );
fwd_c_frac_mul_00: rf1_c_frac_mul_b(0 to 23)  <= not( ( (0 to 23  => sel_c_no_byp)     AND rf1_c_frac_fpr(0 to 23)  ) or   rf1_c_frac_prebyp(0 to 23)    );

fwd_c_frac_fmt_24: rf1_c_frac_fmt_b(24)       <= not( (              sel_c_no_byp      AND rf1_c_frac_fpr(24)       ) or   rf1_c_frac_prebyp(24)         );
fwd_c_frac_mul_24: rf1_c_frac_mul_b(24)       <= not( (              sel_c_no_byp      AND rf1_c_frac_fpr(24)       ) or   rf1_c_frac_prebyp_hulp        ); 

fwd_c_frac_fmt_25: rf1_c_frac_fmt_b(25 to 52) <= not( ( (25 to 52 => sel_c_no_byp)     AND rf1_c_frac_fpr(25 to 52) ) or   rf1_c_frac_prebyp(25 to 52)   );
fwd_c_frac_mul_25: rf1_c_frac_mul_b(25 to 52) <= not( ( (25 to 52 => sel_c_no_byp)     AND rf1_c_frac_fpr(25 to 52) ) or   rf1_c_frac_prebyp(25 to 52)   ); 
                   rf1_c_frac_mul_b(53)       <= not( f_dcd_rf1_uc_fc_hulp  and not f_dcd_rf1_sp );

fwd_b_frac_fmt_00: rf1_b_frac_fmt_b(0 to 23)  <= not( ( (0 to 23  => sel_b_no_byp)     AND rf1_b_frac_fpr(0 to 23)  ) or   rf1_b_frac_prebyp(0 to 23)    );
fwd_b_frac_alg_00: rf1_b_frac_alg_b(0 to 23)  <= not( ( (0 to 23  => sel_b_no_byp)     AND rf1_b_frac_fpr(0 to 23)  ) or   rf1_b_frac_prebyp(0 to 23)    );
fwd_b_frac_fmt_24: rf1_b_frac_fmt_b(24 to 52) <= not( ( (24 to 52 => sel_b_no_byp)     AND rf1_b_frac_fpr(24 to 52) ) or   rf1_b_frac_prebyp(24 to 52)   );
fwd_b_frac_alg_24: rf1_b_frac_alg_b(24 to 52) <= not( ( (24 to 52 => sel_b_no_byp)     AND rf1_b_frac_fpr(24 to 52) ) or   rf1_b_frac_prebyp(24 to 52)   ); 



--====================================================================
--== ex1 operand latches
--====================================================================

  ------------------ FRACTION ---------------------------------------





    ex1_frac_b_alg_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 53, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_b_frac_si              ,--in
        SCANOUT      =>  ex1_b_frac_so              ,--in
        D            =>  rf1_b_frac_alg_b(0 to 52)  ,--in
        QB           =>  ex1_b_frac_alg  (0 to 52) );--out

    ex1_frac_a_fmt_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 53, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_frac_a_fmt_si          ,--in
        SCANOUT      =>  ex1_frac_a_fmt_so          ,--in
        D(0 to 52)   =>  rf1_a_frac_fmt_b(0 to 52)  ,
        QB(0 to 52)  =>  ex1_a_frac_fmt  (0 to 52) );

    ex1_frac_c_fmt_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 53, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_frac_c_fmt_si          ,--in
        SCANOUT      =>  ex1_frac_c_fmt_so          ,--in
        D(0 to 52)   =>  rf1_c_frac_fmt_b(0 to 52)  ,
        QB(0 to 52)  =>  ex1_c_frac_fmt  (0 to 52) );

    ex1_frac_b_fmt_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 53, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_frac_b_fmt_si          ,--in
        SCANOUT      =>  ex1_frac_b_fmt_so          ,--in
        D(0 to 52)   =>  rf1_b_frac_fmt_b(0 to 52)  ,
        QB(0 to 52)  =>  ex1_b_frac_fmt  (0 to 52) );


    u_qi_bfa: ex1_b_frac_alg_b(0 to 52) <= not ex1_b_frac_alg(0 to 52) ;
    u_qi_bff: ex1_b_frac_fmt_b(0 to 52) <= not ex1_b_frac_fmt(0 to 52) ;
    u_qi_cff: ex1_c_frac_fmt_b(0 to 52) <= not ex1_c_frac_fmt(0 to 52) ;
    u_qi_aff: ex1_a_frac_fmt_b(0 to 52) <= not ex1_a_frac_fmt(0 to 52) ;

    u_di_cfm:    temp_rf1_c_frac_mul(0 to 53) <= not rf1_c_frac_mul_b(0 to 53) ;
    u_di_afm:    temp_rf1_a_frac_mul(0 to 52) <= not rf1_a_frac_mul_b(0 to 52) ;
    u_di_afm_17: temp_rf1_a_frac_mul_17       <= not rf1_a_frac_mul_17_b       ;
    u_di_afm_35: temp_rf1_a_frac_mul_35       <= not rf1_a_frac_mul_35_b       ;


    ex1_frac_c_mul_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 54, btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  frac_mul_c_si              ,--in
        SCANOUT      =>  frac_mul_c_so              ,--in
        D(0 to 52)   => temp_rf1_c_frac_mul(0 to 52)   ,--in
        D(53)        => temp_rf1_c_frac_mul(53)        ,--in  -- f_dcd_rf1_uc_fc_hulp,
        QB           => ex1_c_frac_mul_b(0 to 53)  );--out

    ex1_frac_a_mul_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 55, btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in  --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  frac_mul_a_si              ,--in
        SCANOUT      =>  frac_mul_a_so              ,--in
        D( 0)            => temp_rf1_a_frac_mul(0)  ,
        D( 1)            => temp_rf1_a_frac_mul(17) ,
        D( 2)            => temp_rf1_a_frac_mul(35) ,
        D( 3)            => temp_rf1_a_frac_mul(1)  ,
        D( 4)            => temp_rf1_a_frac_mul(18) ,
        D( 5)            => temp_rf1_a_frac_mul(36) ,
        D( 6)            => temp_rf1_a_frac_mul(2)  ,
        D( 7)            => temp_rf1_a_frac_mul(19) ,
        D( 8)            => temp_rf1_a_frac_mul(37) ,
        D( 9)            => temp_rf1_a_frac_mul(3)  ,
        D(10)            => temp_rf1_a_frac_mul(20) ,
        D(11)            => temp_rf1_a_frac_mul(38) ,
        D(12)            => temp_rf1_a_frac_mul(4)  ,
        D(13)            => temp_rf1_a_frac_mul(21) ,
        D(14)            => temp_rf1_a_frac_mul(39) ,
        D(15)            => temp_rf1_a_frac_mul(5)  ,
        D(16)            => temp_rf1_a_frac_mul(22) ,
        D(17)            => temp_rf1_a_frac_mul(40) ,
        D(18)            => temp_rf1_a_frac_mul(6)  ,
        D(19)            => temp_rf1_a_frac_mul(23) ,
        D(20)            => temp_rf1_a_frac_mul(41) ,
        D(21)            => temp_rf1_a_frac_mul(7)  ,
        D(22)            => temp_rf1_a_frac_mul(24) ,
        D(23)            => temp_rf1_a_frac_mul(42) ,
        D(24)            => temp_rf1_a_frac_mul(8)  ,
        D(25)            => temp_rf1_a_frac_mul(25) ,
        D(26)            => temp_rf1_a_frac_mul(43) ,
        D(27)            => temp_rf1_a_frac_mul(9)  ,
        D(28)            => temp_rf1_a_frac_mul(26) ,
        D(29)            => temp_rf1_a_frac_mul(44) ,
        D(30)            => temp_rf1_a_frac_mul(10) ,
        D(31)            => temp_rf1_a_frac_mul(27) ,
        D(32)            => temp_rf1_a_frac_mul(45) ,
        D(33)            => temp_rf1_a_frac_mul(11) ,
        D(34)            => temp_rf1_a_frac_mul(28) ,
        D(35)            => temp_rf1_a_frac_mul(46) ,
        D(36)            => temp_rf1_a_frac_mul(12) ,
        D(37)            => temp_rf1_a_frac_mul(29) ,
        D(38)            => temp_rf1_a_frac_mul(47) ,
        D(39)            => temp_rf1_a_frac_mul(13) ,
        D(40)            => temp_rf1_a_frac_mul(30) ,
        D(41)            => temp_rf1_a_frac_mul(48) ,
        D(42)            => temp_rf1_a_frac_mul(14) ,
        D(43)            => temp_rf1_a_frac_mul(31) ,
        D(44)            => temp_rf1_a_frac_mul(49) ,
        D(45)            => temp_rf1_a_frac_mul(15) ,
        D(46)            => temp_rf1_a_frac_mul(32) ,
        D(47)            => temp_rf1_a_frac_mul(50) ,
        D(48)            => temp_rf1_a_frac_mul(16) ,
        D(49)            => temp_rf1_a_frac_mul(33) ,
        D(50)            => temp_rf1_a_frac_mul(51) ,
        D(51)            => temp_rf1_a_frac_mul_17  , -- copy of 17 for bit stacking
        D(52)            => temp_rf1_a_frac_mul(34) ,
        D(53)            => temp_rf1_a_frac_mul(52) ,
        D(54)            => temp_rf1_a_frac_mul_35  , -- copy of 35 for bit stacking
        ------------------------------------------
        QB( 0)          => ex1_a_frac_mul_b(0)  ,
        QB( 1)          => ex1_a_frac_mul_b(17) , -- real copy of bit 17
        QB( 2)          => ex1_a_frac_mul_b(35) , -- real copy of bit 35
        QB( 3)          => ex1_a_frac_mul_b(1)  ,
        QB( 4)          => ex1_a_frac_mul_b(18) ,
        QB( 5)          => ex1_a_frac_mul_b(36) ,
        QB( 6)          => ex1_a_frac_mul_b(2)  ,
        QB( 7)          => ex1_a_frac_mul_b(19) ,
        QB( 8)          => ex1_a_frac_mul_b(37) ,
        QB( 9)          => ex1_a_frac_mul_b(3)  ,
        QB(10)          => ex1_a_frac_mul_b(20) ,
        QB(11)          => ex1_a_frac_mul_b(38) ,
        QB(12)          => ex1_a_frac_mul_b(4)  ,
        QB(13)          => ex1_a_frac_mul_b(21) ,
        QB(14)          => ex1_a_frac_mul_b(39) ,
        QB(15)          => ex1_a_frac_mul_b(5)  ,
        QB(16)          => ex1_a_frac_mul_b(22) ,
        QB(17)          => ex1_a_frac_mul_b(40) ,
        QB(18)          => ex1_a_frac_mul_b(6)  ,
        QB(19)          => ex1_a_frac_mul_b(23) ,
        QB(20)          => ex1_a_frac_mul_b(41) ,
        QB(21)          => ex1_a_frac_mul_b(7)  ,
        QB(22)          => ex1_a_frac_mul_b(24) ,
        QB(23)          => ex1_a_frac_mul_b(42) ,
        QB(24)          => ex1_a_frac_mul_b(8)  ,
        QB(25)          => ex1_a_frac_mul_b(25) ,
        QB(26)          => ex1_a_frac_mul_b(43) ,
        QB(27)          => ex1_a_frac_mul_b(9)  ,
        QB(28)          => ex1_a_frac_mul_b(26) ,
        QB(29)          => ex1_a_frac_mul_b(44) ,
        QB(30)          => ex1_a_frac_mul_b(10) ,
        QB(31)          => ex1_a_frac_mul_b(27) ,
        QB(32)          => ex1_a_frac_mul_b(45) ,
        QB(33)          => ex1_a_frac_mul_b(11) ,
        QB(34)          => ex1_a_frac_mul_b(28) ,
        QB(35)          => ex1_a_frac_mul_b(46) ,
        QB(36)          => ex1_a_frac_mul_b(12) ,
        QB(37)          => ex1_a_frac_mul_b(29) ,
        QB(38)          => ex1_a_frac_mul_b(47) ,
        QB(39)          => ex1_a_frac_mul_b(13) ,
        QB(40)          => ex1_a_frac_mul_b(30) ,
        QB(41)          => ex1_a_frac_mul_b(48) ,
        QB(42)          => ex1_a_frac_mul_b(14) ,
        QB(43)          => ex1_a_frac_mul_b(31) ,
        QB(44)          => ex1_a_frac_mul_b(49) ,
        QB(45)          => ex1_a_frac_mul_b(15) ,
        QB(46)          => ex1_a_frac_mul_b(32) ,
        QB(47)          => ex1_a_frac_mul_b(50) ,
        QB(48)          => ex1_a_frac_mul_b(16) ,
        QB(49)          => ex1_a_frac_mul_b(33) ,
        QB(50)          => ex1_a_frac_mul_b(51) ,
        QB(51)          => ex1_a_frac_mul_17_b  , -- copy of 17 for bit stacking
        QB(52)          => ex1_a_frac_mul_b(34) ,
        QB(53)          => ex1_a_frac_mul_b(52) ,
        QB(54)          => ex1_a_frac_mul_35_b ); -- copy of 35 for bit stacking


  bfa_oinv:   f_byp_alg_ex1_b_frac(0 to 52) <= not ex1_b_frac_alg_b(0 to 52) ;
              f_byp_fmt_ex1_a_frac(0 to 52) <= not ex1_a_frac_fmt_b(0 to 52);
              f_byp_fmt_ex1_c_frac(0 to 52) <= not ex1_c_frac_fmt_b(0 to 52);  
              f_byp_fmt_ex1_b_frac(0 to 52) <= not ex1_b_frac_fmt_b(0 to 52);      
 afm_oinv:    f_byp_mul_ex1_a_frac(0 to 52) <= not ex1_a_frac_mul_b(0 to 52);
 afm_oinv_17: f_byp_mul_ex1_a_frac_17       <= not ex1_a_frac_mul_17_b ;
 afm_oinv_35: f_byp_mul_ex1_a_frac_35       <= not ex1_a_frac_mul_35_b ;
 cfm_oinv:    f_byp_mul_ex1_c_frac(0 to 53) <= not ex1_c_frac_mul_b(0 to 53) ;


  ------------------ EXPONENT SIGN ----------------------------------

    ex1_expo_b_alg_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 14, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_expo_b_alg_si          ,--in
        SCANOUT      =>  ex1_expo_b_alg_so          ,--in
        D(0)         =>  rf1_b_sign_alg_b           ,
        D(1 to 13)   =>  rf1_b_expo_alg_b(1 to 13)  ,
        QB(0)        =>  ex1_b_sign_alg             ,
        QB(1 to 13)  =>  ex1_b_expo_alg  (1 to 13) );

    ex1_expo_c_alg_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 13, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_expo_c_alg_si          ,--in
        SCANOUT      =>  ex1_expo_c_alg_so          ,--in
        D            =>  rf1_c_expo_alg_b(1 to 13)  ,
        QB           =>  ex1_c_expo_alg  (1 to 13) );

    ex1_expo_a_alg_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 13, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_expo_a_alg_si          ,--in
        SCANOUT      =>  ex1_expo_a_alg_so          ,--in
        D            =>  rf1_a_expo_alg_b(1 to 13)  ,
        QB           =>  ex1_a_expo_alg  (1 to 13) );


    ex1_expo_b_fmt_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 14, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_expo_b_fmt_si          ,--in
        SCANOUT      =>  ex1_expo_b_fmt_so          ,--in
        D(0)         =>  rf1_b_sign_fmt_b           ,
        D(1 to 13)   =>  rf1_b_expo_fmt_b(1 to 13)  ,
        QB(0)        =>  ex1_b_sign_fmt             ,
        QB(1 to 13)  =>  ex1_b_expo_fmt  (1 to 13) );

    ex1_expo_a_fmt_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 14, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_expo_a_fmt_si          ,--in
        SCANOUT      =>  ex1_expo_a_fmt_so          ,--in
        D(0)         =>  rf1_a_sign_fmt_b           ,
        D(1 to 13)   =>  rf1_a_expo_fmt_b(1 to 13)  ,
        QB(0)        =>  ex1_a_sign_fmt             ,
        QB(1 to 13)  =>  ex1_a_expo_fmt  (1 to 13) );

    ex1_expo_c_fmt_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 14, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_expo_c_fmt_si          ,--in
        SCANOUT      =>  ex1_expo_c_fmt_so          ,--in
        D(0)         =>  rf1_c_sign_fmt_b           ,
        D(1 to 13)   =>  rf1_c_expo_fmt_b(1 to 13)  ,
        QB(0)        =>  ex1_c_sign_fmt             ,
        QB(1 to 13)  =>  ex1_c_expo_fmt  (1 to 13) );

    ex1_expo_b_eie_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 14, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_expo_b_eie_si          ,--in
        SCANOUT      =>  ex1_expo_b_eie_so          ,--in
        D(0)         =>  rf1_b_sign_pic_b           ,
        D(1 to 13)   =>  rf1_b_expo_eie_b(1 to 13)  ,
        QB(0)        =>  ex1_b_sign_pic             ,
        QB(1 to 13)  =>  ex1_b_expo_eie  (1 to 13) );

    ex1_expo_a_eie_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 14, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_expo_a_eie_si          ,--in
        SCANOUT      =>  ex1_expo_a_eie_so          ,--in
        D(0)         =>  rf1_a_sign_pic_b           ,
        D(1 to 13)   =>  rf1_a_expo_eie_b(1 to 13)  ,
        QB(0)        =>  ex1_a_sign_pic             ,
        QB(1 to 13)  =>  ex1_a_expo_eie  (1 to 13) );

    ex1_expo_c_eie_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 14, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK         =>  byp_ex1_lclk               ,--in      --lclk.clk
        D1CLK        =>  byp_ex1_d1clk              ,--in
        D2CLK        =>  byp_ex1_d2clk              ,--in
        SCANIN       =>  ex1_expo_c_eie_si          ,--in
        SCANOUT      =>  ex1_expo_c_eie_so          ,--in
        D(0)         =>  rf1_c_sign_pic_b           ,
        D(1 to 13)   =>  rf1_c_expo_eie_b(1 to 13)  ,
        QB(0)        =>  ex1_c_sign_pic             ,
        QB(1 to 13)  =>  ex1_c_expo_eie  (1 to 13) );





        ex1_b_sign_alg_b          <= not ex1_b_sign_alg ;
        ex1_b_sign_fmt_b          <= not ex1_b_sign_fmt ;
        ex1_a_sign_fmt_b          <= not ex1_a_sign_fmt ;
        ex1_c_sign_fmt_b          <= not ex1_c_sign_fmt ;
        ex1_b_sign_pic_b          <= not ex1_b_sign_pic ;
        ex1_a_sign_pic_b          <= not ex1_a_sign_pic ;
        ex1_c_sign_pic_b          <= not ex1_c_sign_pic ;

        ex1_b_expo_alg_b(1 to 13) <= not ex1_b_expo_alg(1 to 13);
        ex1_c_expo_alg_b(1 to 13) <= not ex1_c_expo_alg(1 to 13);
        ex1_a_expo_alg_b(1 to 13) <= not ex1_a_expo_alg(1 to 13);
        ex1_b_expo_fmt_b(1 to 13) <= not ex1_b_expo_fmt(1 to 13);
        ex1_c_expo_fmt_b(1 to 13) <= not ex1_c_expo_fmt(1 to 13);
        ex1_a_expo_fmt_b(1 to 13) <= not ex1_a_expo_fmt(1 to 13);
        ex1_b_expo_eie_b(1 to 13) <= not ex1_b_expo_eie(1 to 13);
        ex1_c_expo_eie_b(1 to 13) <= not ex1_c_expo_eie(1 to 13);
        ex1_a_expo_eie_b(1 to 13) <= not ex1_a_expo_eie(1 to 13);


        f_byp_alg_ex1_b_sign           <= not ex1_b_sign_alg_b;
        f_byp_alg_ex1_b_expo(1 to 13)  <= not ex1_b_expo_alg_b(1 to 13); 
        f_byp_alg_ex1_c_expo(1 to 13)  <= not ex1_c_expo_alg_b(1 to 13);
        f_byp_alg_ex1_a_expo(1 to 13)  <= not ex1_a_expo_alg_b(1 to 13);

        f_byp_fmt_ex1_a_sign           <= not ex1_a_sign_fmt_b          ;
        f_byp_fmt_ex1_a_expo(1 to 13)  <= not ex1_a_expo_fmt_b(1 to 13) ;
        f_byp_fmt_ex1_c_sign           <= not ex1_c_sign_fmt_b          ;
        f_byp_fmt_ex1_c_expo(1 to 13)  <= not ex1_c_expo_fmt_b(1 to 13) ;
        f_byp_fmt_ex1_b_sign           <= not ex1_b_sign_fmt_b          ;
        f_byp_fmt_ex1_b_expo(1 to 13)  <= not ex1_b_expo_fmt_b(1 to 13) ;

        f_byp_pic_ex1_a_sign          <= not ex1_a_sign_pic_b          ;
        f_byp_eie_ex1_a_expo(1 to 13) <= not ex1_a_expo_eie_b(1 to 13) ;
        f_byp_pic_ex1_c_sign          <= not ex1_c_sign_pic_b          ;
        f_byp_eie_ex1_c_expo(1 to 13) <= not ex1_c_expo_eie_b(1 to 13) ;
        f_byp_pic_ex1_b_sign          <= not ex1_b_sign_pic_b          ;
        f_byp_eie_ex1_b_expo(1 to 13) <= not ex1_b_expo_eie_b(1 to 13) ;
  


--====================================================================
--== scan chain
--====================================================================

   act_si(0 to 3)              <= act_so(1 to 3)             & f_byp_si            ;
   ex1_b_frac_si(0 to 52)      <= ex1_b_frac_so(1 to 52)     & act_so(0)           ;
   ex1_frac_a_fmt_si(0 to 52)  <= ex1_frac_a_fmt_so(1 to 52) & ex1_b_frac_so(0)    ;
   ex1_frac_c_fmt_si(0 to 52)  <= ex1_frac_c_fmt_so(1 to 52) & ex1_frac_a_fmt_so(0)   ;
   ex1_frac_b_fmt_si(0 to 52)  <= ex1_frac_b_fmt_so(1 to 52) & ex1_frac_c_fmt_so(0)   ;
   frac_mul_c_si(0 to 53)      <= frac_mul_c_so(1 to 53)     & ex1_frac_b_fmt_so(0)   ;
   frac_mul_a_si(0 to 54)      <= frac_mul_a_so(1 to 54)     & frac_mul_c_so(0)    ;
   ex1_expo_a_eie_si(0 to 13)  <= ex1_expo_a_eie_so(1 to 13) & frac_mul_a_so(0)    ;
   ex1_expo_c_eie_si(0 to 13)  <= ex1_expo_c_eie_so(1 to 13) & ex1_expo_a_eie_so(0); 
   ex1_expo_b_eie_si(0 to 13)  <= ex1_expo_b_eie_so(1 to 13) & ex1_expo_c_eie_so(0); 
   ex1_expo_a_fmt_si(0 to 13)  <= ex1_expo_a_fmt_so(1 to 13) & ex1_expo_b_eie_so(0); 
   ex1_expo_c_fmt_si(0 to 13)  <= ex1_expo_c_fmt_so(1 to 13) & ex1_expo_a_fmt_so(0); 
   ex1_expo_b_fmt_si(0 to 13)  <= ex1_expo_b_fmt_so(1 to 13) & ex1_expo_c_fmt_so(0); 
   ex1_expo_b_alg_si(0 to 13)  <= ex1_expo_b_alg_so(1 to 13) & ex1_expo_b_fmt_so(0); 
   ex1_expo_a_alg_si(0 to 12)  <= ex1_expo_a_alg_so(1 to 12) & ex1_expo_b_alg_so(0);
   ex1_expo_c_alg_si(0 to 12)  <= ex1_expo_c_alg_so(1 to 12) & ex1_expo_a_alg_so(0);
   f_byp_so                    <=                              ex1_expo_c_alg_so(0) ;



end; -- fuq_byp ARCHITECTURE
