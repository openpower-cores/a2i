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



entity fuq_fmt is
generic(    expand_type               : integer := 2  ); 
port( 
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


       f_fmt_si                  :in   std_ulogic; 
       f_fmt_so                  :out  std_ulogic; 
       rf1_act                   :in   std_ulogic; 
       ex1_act                   :in   std_ulogic; 

       f_byp_fmt_ex1_a_sign           :in   std_ulogic;
       f_byp_fmt_ex1_c_sign           :in   std_ulogic;
       f_byp_fmt_ex1_b_sign           :in   std_ulogic;
       f_byp_fmt_ex1_a_expo           :in   std_ulogic_vector(1 to 13);
       f_byp_fmt_ex1_c_expo           :in   std_ulogic_vector(1 to 13);
       f_byp_fmt_ex1_b_expo           :in   std_ulogic_vector(1 to 13);
       f_byp_fmt_ex1_a_frac           :in   std_ulogic_vector(0 to 52);
       f_byp_fmt_ex1_c_frac           :in   std_ulogic_vector(0 to 52);
       f_byp_fmt_ex1_b_frac           :in   std_ulogic_vector(0 to 52);

       f_dcd_rf1_aop_valid        :in   std_ulogic                 ;
       f_dcd_rf1_cop_valid        :in   std_ulogic                 ;
       f_dcd_rf1_bop_valid        :in   std_ulogic                 ;
       f_dcd_rf1_from_integer_b   :in   std_ulogic                 ;
       f_dcd_rf1_fsel_b           :in   std_ulogic                 ;
       f_dcd_rf1_force_pass_b     :in   std_ulogic                 ;

        f_dcd_rf1_sp            :in   std_ulogic ;

        f_dcd_ex1_perr_force_c     :in  std_ulogic;
        f_dcd_ex1_perr_fsel_ovrd   :in  std_ulogic;

       
       f_pic_ex1_ftdiv            :in  std_ulogic;
       f_pic_ex1_flush_en_sp      :in  std_ulogic;
       f_pic_ex1_flush_en_dp      :in  std_ulogic;

       f_pic_ex1_nj_deni          :in  std_ulogic ;
       f_dcd_rf1_uc_end           :in  std_ulogic;
       f_dcd_rf1_uc_mid           :in  std_ulogic; 
       f_dcd_rf1_uc_special       :in  std_ulogic;
       f_dcd_rf1_sgncpy_b         :in  std_ulogic;

       f_fmt_ex2_lu_den_recip     :out  std_ulogic                 ;
       f_fmt_ex2_lu_den_rsqrto    :out  std_ulogic                 ;

       f_fmt_ex1_bop_byt          :out  std_ulogic_vector(45 to 52) ;

       f_fmt_ex1_a_zero           :out  std_ulogic                 ;
       f_fmt_ex1_a_expo_max       :out  std_ulogic                 ;
       f_fmt_ex1_a_frac_zero      :out  std_ulogic                 ;
       f_fmt_ex1_a_frac_msb       :out  std_ulogic                 ;

       f_fmt_ex1_c_zero           :out  std_ulogic                 ;
       f_fmt_ex1_c_expo_max       :out  std_ulogic                 ;
       f_fmt_ex1_c_frac_zero      :out  std_ulogic                 ;
       f_fmt_ex1_c_frac_msb       :out  std_ulogic                 ;

       f_fmt_ex1_b_zero           :out  std_ulogic                 ;
       f_fmt_ex1_b_expo_max       :out  std_ulogic                 ;
       f_fmt_ex1_b_frac_zero      :out  std_ulogic                 ;
       f_fmt_ex1_b_frac_msb       :out  std_ulogic                 ;
       f_fmt_ex1_b_imp            :out  std_ulogic                 ;
       f_fmt_ex1_b_frac_z32       :out  std_ulogic                 ;

       f_fmt_ex1_prod_zero        :out  std_ulogic                 ;
       f_fmt_ex1_pass_sel         :out  std_ulogic                 ;

       f_fmt_ex1_sp_invalid       :out  std_ulogic                 ;
       f_fmt_ex1_bexpu_le126      :out  std_ulogic                 ;
       f_fmt_ex1_gt126            :out  std_ulogic                 ;
       f_fmt_ex1_ge128            :out  std_ulogic                 ;
       f_fmt_ex1_inf_and_beyond_sp :out  std_ulogic                 ;

       f_mad_ex2_uc_a_expo_den    :out  std_ulogic ;
       f_mad_ex2_uc_a_expo_den_sp :out  std_ulogic ;

       f_ex2_b_den_flush          :out  std_ulogic                 ;

       f_fmt_ex2_fsel_bsel        :out  std_ulogic                 ;
       f_fmt_ex2_pass_sign        :out  std_ulogic                 ;
       f_fmt_ex2_pass_msb         :out  std_ulogic                 ;
       f_fmt_ex1_b_frac           :out  std_ulogic_vector(1 to 19) ;
       f_fmt_ex1_b_sign_gst       :out  std_ulogic                 ;
       f_fmt_ex1_b_expo_gst_b     :out  std_ulogic_vector(1 to 13);

       f_fpr_ex1_a_par            :in   std_ulogic_vector(0 to 7)  ;
       f_fpr_ex1_c_par            :in   std_ulogic_vector(0 to 7)  ;
       f_fpr_ex1_b_par            :in   std_ulogic_vector(0 to 7)  ;
       f_mad_ex2_a_parity_check   :out  std_ulogic                 ;
       f_mad_ex2_c_parity_check   :out  std_ulogic                 ;
       f_mad_ex2_b_parity_check   :out  std_ulogic                 ;

       f_fmt_ex2_ae_ge_54         :out  std_ulogic                 ;
       f_fmt_ex2_be_ge_54         :out  std_ulogic                 ;
       f_fmt_ex2_be_ge_2          :out  std_ulogic                 ;
       f_fmt_ex2_be_ge_2044       :out  std_ulogic                 ;
       f_fmt_ex2_tdiv_rng_chk     :out  std_ulogic                 ;
       f_fmt_ex2_be_den           :out  std_ulogic                 ;
       f_fmt_ex2_pass_frac        :out  std_ulogic_vector(0 to 52)  

);



end fuq_fmt; 

architecture fuq_fmt of fuq_fmt is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal thold_0_b, thold_0, forcee        :std_ulogic;
    signal sg_0                           :std_ulogic;
    signal spare_unused                     :std_ulogic_vector(0 to 3);
    signal act_si                           :std_ulogic_vector(0 to  6);
    signal act_so                           :std_ulogic_vector(0 to  6);

    signal ex1_ctl_si                       :std_ulogic_vector(0 to  8);
    signal ex1_ctl_so                       :std_ulogic_vector(0 to  8);
    signal ex2_pass_si                      :std_ulogic_vector(0 to 79);
    signal ex2_pass_so                      :std_ulogic_vector(0 to 79);
    signal ex2_pass_frac            :std_ulogic_vector(0 to 52);
    signal ex1_from_integer         :std_ulogic;
    signal ex1_fsel                 :std_ulogic;
    signal ex1_force_pass           :std_ulogic;
    signal ex1_a_sign               :std_ulogic;
    signal ex1_c_sign               :std_ulogic;
    signal ex1_b_sign               :std_ulogic;
    signal ex2_fsel_bsel            :std_ulogic;
    signal ex2_pass_sign            :std_ulogic;
    signal ex1_a_frac          :std_ulogic_vector(0 to 52);
    signal ex1_c_frac          :std_ulogic_vector(0 to 52);
    signal ex1_b_frac          :std_ulogic_vector(0 to 52);
    signal ex1_pass_frac_ac    :std_ulogic_vector(0 to 52);
    signal ex1_pass_frac       :std_ulogic_vector(0 to 52); 
    signal ex1_a_frac_msb      :std_ulogic;
    signal ex1_a_expo_min      :std_ulogic;
    signal ex1_a_expo_max      :std_ulogic;
    signal ex1_a_frac_zero     :std_ulogic;
    signal ex1_c_frac_msb      :std_ulogic;
    signal ex1_c_expo_min      :std_ulogic;
    signal ex1_c_expo_max      :std_ulogic;
    signal ex1_c_frac_zero     :std_ulogic;
    signal ex1_b_frac_msb      :std_ulogic;
    signal ex1_b_expo_min      :std_ulogic;
    signal ex1_b_expo_max      :std_ulogic;
    signal ex1_b_frac_zero     :std_ulogic;
    signal ex1_b_frac_z32      :std_ulogic;
    signal ex1_a_nan           :std_ulogic;
    signal ex1_c_nan           :std_ulogic;
    signal ex1_b_nan           :std_ulogic;
    signal ex1_nan_pass        :std_ulogic;
    signal ex1_pass_sel        :std_ulogic;
    signal ex1_fsel_cif        :std_ulogic;
    signal ex1_fsel_bsel       :std_ulogic;
    signal ex1_mux_a_sel       :std_ulogic;
    signal ex1_mux_c_sel       :std_ulogic;
    signal ex1_pass_sign_ac    :std_ulogic;
    signal ex1_pass_sign       :std_ulogic;
    signal ex1_a_expo          :std_ulogic_vector(1 to 13);
    signal ex1_b_expo          :std_ulogic_vector(1 to 13);
    signal ex1_c_expo          :std_ulogic_vector(1 to 13);
    signal ex1_a_expo_b        :std_ulogic_vector(1 to 13);
    signal ex1_c_expo_b        :std_ulogic_vector(1 to 13);
    signal ex1_b_expo_b        :std_ulogic_vector(1 to 13);
    signal rf1_aop_valid_b     :std_ulogic;
    signal rf1_cop_valid_b     :std_ulogic;
    signal rf1_bop_valid_b     :std_ulogic;
    signal ex1_aop_valid       :std_ulogic;
    signal ex1_cop_valid       :std_ulogic;
    signal ex1_bop_valid       :std_ulogic;
    signal ex1_a_zero          :std_ulogic;
    signal ex1_c_zero          :std_ulogic;
    signal ex1_b_zero          :std_ulogic;
    signal ex1_a_zero_x        :std_ulogic;
    signal ex1_c_zero_x        :std_ulogic;
    signal ex1_b_zero_x        :std_ulogic;
    signal ex1_a_sp_expo_ok_1 :std_ulogic;
    signal ex1_c_sp_expo_ok_1 :std_ulogic;
    signal ex1_b_sp_expo_ok_1 :std_ulogic;
    signal ex1_a_sp_expo_ok_2 :std_ulogic;
    signal ex1_c_sp_expo_ok_2 :std_ulogic;
    signal ex1_b_sp_expo_ok_2 :std_ulogic;
    signal ex1_a_sp_expo_ok_3 :std_ulogic;
    signal ex1_c_sp_expo_ok_3 :std_ulogic;
    signal ex1_b_sp_expo_ok_3 :std_ulogic;
    signal ex1_a_sp_expo_ok_4 :std_ulogic;
    signal ex1_c_sp_expo_ok_4 :std_ulogic;
    signal ex1_b_sp_expo_ok_4 :std_ulogic;
    signal ex2_pass_dp :std_ulogic_vector(0 to 52);
  signal ex1_from_integer_b :std_ulogic;
  signal ex1_fsel_b         :std_ulogic;
  signal ex1_aop_valid_b    :std_ulogic;
  signal ex1_cop_valid_b    :std_ulogic;
  signal ex1_bop_valid_b    :std_ulogic;
  signal ex1_b_den_flush, ex1_b_den_sp , ex1_a_den_sp , ex1_b_den_dp , ex2_b_den_flush :std_ulogic;
  signal ex1_lu_den_part, ex1_lu_den_recip, ex1_lu_den_rsqrto :std_ulogic;
  signal                  ex2_lu_den_recip, ex2_lu_den_rsqrto :std_ulogic;
  signal ex1_recip_lo , ex1_rsqrt_lo :std_ulogic; 
  signal ex1_bfrac_eq_126, ex1_bfrac_126_nz :std_ulogic;
  signal ex1_bexpo_ge897_hi   :std_ulogic;
  signal ex1_bexpo_ge897_mid1 :std_ulogic;
  signal ex1_bexpo_ge897_mid2 :std_ulogic;
  signal ex1_bexpo_ge897_lo   :std_ulogic;
  signal ex1_bexpo_ge897      :std_ulogic;
  signal ex1_bexpu_eq6  :std_ulogic ;
  signal ex1_bexpu_ge7  :std_ulogic ;
  signal ex1_bexpu_ge7_lo  :std_ulogic ;
  signal ex1_bexpu_ge7_mid  :std_ulogic ;
  signal ex1_a_sp,  ex1_c_sp , ex1_b_sp :std_ulogic ;
  signal ex1_b_frac_zero_sp, ex1_b_frac_zero_dp :std_ulogic ;
  signal ex1_a_denz ,   ex1_c_denz ,   ex1_b_denz :std_ulogic ;
  signal ex1_a_frac_chop, ex1_c_frac_chop, ex1_b_frac_chop :std_ulogic_vector(0 to 52);

 signal rf1_sgncpy, ex1_sgncpy , ex1_uc_mid :std_ulogic;
 signal rf1_force_pass :std_ulogic;
 signal rf1_uc_end_nspec, rf1_uc_end_spec, ex1_uc_end_nspec :std_ulogic;
 signal ex1_uc_a_expo_den  , ex2_uc_a_expo_den  :std_ulogic ;
 signal ex1_uc_a_expo_den_sp  , ex2_uc_a_expo_den_sp  :std_ulogic ;

  signal ex1_a_expo_ltx381_sp, ex1_a_expo_ltx381, ex1_a_expo_00xx_xxxx_xxxx, ex1_a_expo_xx11_1xxx_xxxx, ex1_a_expo_xxxx_x000_0000 :std_ulogic;
  signal ex1_c_expo_ltx381_sp, ex1_c_expo_ltx381, ex1_c_expo_00xx_xxxx_xxxx, ex1_c_expo_xx11_1xxx_xxxx, ex1_c_expo_xxxx_x000_0000 :std_ulogic;
  signal ex1_b_expo_ltx381_sp, ex1_b_expo_ltx381, ex1_b_expo_00xx_xxxx_xxxx, ex1_b_expo_xx11_1xxx_xxxx, ex1_b_expo_xxxx_x000_0000 :std_ulogic;
  signal ex1_a_sp_inf_alias_tail, ex1_c_sp_inf_alias_tail, ex1_b_sp_inf_alias_tail :std_ulogic;
       signal ex2_a_party_chick , ex2_c_party_chick , ex2_b_party_chick :std_ulogic ;
       signal ex1_a_party_chick , ex1_c_party_chick , ex1_b_party_chick :std_ulogic ;
  signal ex1_a_party, ex1_c_party, ex1_b_party :std_ulogic_vector(0 to 7);
  signal ex1_b_expo_ge1151 :std_ulogic ;
   signal ex1_ae_234567, ex1_ae_89, ex1_ae_abc, ex1_ae_ge_54, ex2_ae_ge_54 :std_ulogic ;
   signal ex1_be_234567, ex1_be_89, ex1_be_abc, ex1_be_ge_54, ex2_be_ge_54 :std_ulogic ;
signal ex1_be_ge_2, ex2_be_ge_2, ex1_be_or_23456789abc :std_ulogic;
signal ex1_be_ge_2044, ex2_be_ge_2044, ex1_be_and_3456789ab :std_ulogic; 
   signal ex1_aembex_car_b, ex1_aembey_car_b :std_ulogic_vector(0 to 12) ;
   signal ex1_aembex_sum_b, ex1_aembey_sum_b :std_ulogic_vector(1 to 13) ;
   signal ex1_aembex_g1,    ex1_aembey_g1    :std_ulogic_vector(2 to 12) ;
   signal ex1_aembex_t1,    ex1_aembey_t1    :std_ulogic_vector(2 to 12) ;
   signal ex1_aembex_g2,    ex1_aembey_g2    :std_ulogic_vector(0 to 5) ;
   signal ex1_aembex_t2,    ex1_aembey_t2    :std_ulogic_vector(0 to 4) ;
   signal ex1_aembex_g4,    ex1_aembey_g4    :std_ulogic_vector(0 to 2) ;
   signal ex1_aembex_t4,    ex1_aembey_t4    :std_ulogic_vector(0 to 1) ;
   signal ex2_aembex_g4,    ex2_aembey_g4    :std_ulogic_vector(0 to 2) ;
   signal ex2_aembex_t4,    ex2_aembey_t4    :std_ulogic_vector(0 to 1) ;
   signal ex2_aembex_g8,    ex2_aembey_g8    :std_ulogic_vector(0 to 1);
   signal ex2_aembex_t8,    ex2_aembey_t8    :std_ulogic_vector(0 to 0);
   signal ex2_aembex_c2,    ex2_aembey_c2    :std_ulogic;
   signal ex1_aembex_sgn,   ex1_aembey_sgn   :std_ulogic;
   signal ex2_aembex_sgn,   ex2_aembey_sgn   :std_ulogic;
   signal ex2_aembex_res_sgn, ex2_aembey_res_sgn :std_ulogic;
   signal unused :std_ulogic;
   signal ex1_be_den, ex2_be_den :std_ulogic;




begin

unused <= ex1_aembex_car_b(0)  or
          ex1_aembex_sum_b(13) or 
          ex1_aembex_t1(12)    or 
          ex1_aembey_car_b(0)  or 
          ex1_aembey_sum_b(13) or 
          ex1_aembey_t1(12) ;


    
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




    act_lat:  tri_rlmreg_p generic map (width=> 7, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(1)  ,
        mpw1_b           => mpw1_b(1)       ,
        mpw2_b           => mpw2_b(0)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => act_so  ,                      
        scin             => act_si  ,                    
         din(0)             => spare_unused(0),
         din(1)             => spare_unused(1),
         din(2)             => f_dcd_rf1_sp ,
         din(3)             => f_dcd_rf1_sp ,     
         din(4)             => f_dcd_rf1_sp ,     
         din(5)             => spare_unused(2),
         din(6)             => spare_unused(3),
        dout(0)             => spare_unused(0),
        dout(1)             => spare_unused(1),
        dout(2)             => ex1_a_sp ,
        dout(3)             => ex1_c_sp ,     
        dout(4)             => ex1_b_sp ,     
        dout(5)             => spare_unused(2) ,
        dout(6)             => spare_unused(3) );




       rf1_aop_valid_b  <= not f_dcd_rf1_aop_valid;
       rf1_cop_valid_b  <= not f_dcd_rf1_cop_valid;
       rf1_bop_valid_b  <= not f_dcd_rf1_bop_valid;



    ex1_a_frac(0 to 52)  <= f_byp_fmt_ex1_a_frac(0 to 52);
    ex1_c_frac(0 to 52)  <= f_byp_fmt_ex1_c_frac(0 to 52);
    ex1_b_frac(0 to 52)  <= f_byp_fmt_ex1_b_frac(0 to 52);


    ex1_a_sign <= f_byp_fmt_ex1_a_sign ;
    ex1_c_sign <= f_byp_fmt_ex1_c_sign ;
    ex1_b_sign <= f_byp_fmt_ex1_b_sign ;

    ex1_a_expo(1 to 13) <= f_byp_fmt_ex1_a_expo(1 to 13);
    ex1_c_expo(1 to 13) <= f_byp_fmt_ex1_c_expo(1 to 13);
    ex1_b_expo(1 to 13) <= f_byp_fmt_ex1_b_expo(1 to 13);

    ex1_a_expo_b(1 to 13) <= not ex1_a_expo(1 to 13);
    ex1_c_expo_b(1 to 13) <= not ex1_c_expo(1 to 13) ;
    ex1_b_expo_b(1 to 13) <= not ex1_b_expo(1 to 13) ;

    f_fmt_ex1_b_sign_gst  <= ex1_b_sign ;
    rf1_sgncpy <= not f_dcd_rf1_sgncpy_b;
    rf1_uc_end_nspec <= f_dcd_rf1_uc_end and not f_dcd_rf1_uc_special ;
    rf1_uc_end_spec  <= f_dcd_rf1_uc_end and     f_dcd_rf1_uc_special ;
    rf1_force_pass   <= (not f_dcd_rf1_force_pass_b) or rf1_uc_end_spec;


    ex1_ctl_lat:  tri_rlmreg_p generic map (width=> 9, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(1)  ,
        mpw1_b           => mpw1_b(1)       ,
        mpw2_b           => mpw2_b(0)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => rf1_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex1_ctl_so  ,                      
        scin             => ex1_ctl_si  ,                    
         din(0)             => f_dcd_rf1_from_integer_b ,
         din(1)             => f_dcd_rf1_fsel_b ,
         din(2)             => rf1_force_pass ,
         din(3)             => rf1_aop_valid_b,
         din(4)             => rf1_cop_valid_b,
         din(5)             => rf1_bop_valid_b,
         din(6)             => rf1_sgncpy      ,
         din(7)             => rf1_uc_end_nspec,
         din(8)             => f_dcd_rf1_uc_mid,
        dout(0)             => ex1_from_integer_b ,
        dout(1)             => ex1_fsel_b  ,
        dout(2)             => ex1_force_pass ,
        dout(3)             => ex1_aop_valid_b,
        dout(4)             => ex1_cop_valid_b,
        dout(5)             => ex1_bop_valid_b,
        dout(6)             => ex1_sgncpy     ,
        dout(7)             => ex1_uc_end_nspec ,
        dout(8)             => ex1_uc_mid      );

        ex1_from_integer <= not ex1_from_integer_b ;
        ex1_fsel         <= not ex1_fsel_b         ;
        ex1_aop_valid    <= not ex1_aop_valid_b    ;
        ex1_cop_valid    <= not ex1_cop_valid_b    ;
        ex1_bop_valid    <= not ex1_bop_valid_b    ;


  f_fmt_ex1_bop_byt(45 to 52) <= ex1_b_frac(45 to 52);


  f_fmt_ex1_b_expo_gst_b(1 to 13) <= not ex1_b_expo(1 to 13) ;


  ex1_bexpo_ge897_hi   <= not ex1_b_expo(1) and 
                              ex1_b_frac(0); 
  ex1_bexpo_ge897_mid1 <= ex1_b_expo(2)  or  ex1_b_expo(3) ;
  ex1_bexpo_ge897_mid2 <= ex1_b_expo(4) and  ex1_b_expo(5) and ex1_b_expo(6) ;
  ex1_bexpo_ge897_lo   <= ex1_b_expo(7)  or  ex1_b_expo(8)  or ex1_b_expo(9)  or
                          ex1_b_expo(10) or  ex1_b_expo(11) or ex1_b_expo(12) or
                                                               ex1_b_expo(13) ; 

  ex1_bexpo_ge897      <=
           ( ex1_bexpo_ge897_hi and ex1_bexpo_ge897_mid1                        ) or 
           ( ex1_bexpo_ge897_hi and ex1_bexpo_ge897_mid2 and ex1_bexpo_ge897_lo ) ;

  ex1_bexpu_ge7_mid <= ex1_b_expo(4)  or ex1_b_expo(5)  or ex1_b_expo(6)  or 
                       ex1_b_expo(7)  or ex1_b_expo(8)  or ex1_b_expo(9)  or ex1_b_expo(10);
  ex1_bexpu_ge7_lo  <= ex1_b_expo(11) and ex1_b_expo(12) ;

  ex1_bexpu_ge7 <=
      ( not ex1_b_expo(1) and ex1_b_expo(2)                       ) or
      ( not ex1_b_expo(1) and ex1_b_expo(3) and ex1_bexpu_ge7_mid ) or 
      ( not ex1_b_expo(1) and ex1_b_expo(3) and ex1_bexpu_ge7_lo  ) ;

  ex1_bexpu_eq6 <= 
         not ex1_b_expo(1)  and 
         not ex1_b_expo(2)  and 
             ex1_b_expo(3)  and 
         not ex1_b_expo(4)  and 
         not ex1_b_expo(5)  and 
         not ex1_b_expo(6)  and 
         not ex1_b_expo(7)  and 
         not ex1_b_expo(8)  and 
         not ex1_b_expo(9)  and 
         not ex1_b_expo(10) and 
             ex1_b_expo(11) and 
         not ex1_b_expo(12) and 
             ex1_b_expo(13) ;   


  f_fmt_ex1_bexpu_le126 <= not   ex1_bexpo_ge897; 
  f_fmt_ex1_gt126       <=       ex1_bexpu_ge7 or 
                                (ex1_bexpu_eq6 and ex1_bfrac_eq_126 and ex1_bfrac_126_nz ) ;
  f_fmt_ex1_ge128       <=       ex1_bexpu_ge7 ;  

 ex1_b_expo_ge1151 <=                                                          
       (  ex1_b_expo_b(1) and not ex1_b_expo_b(2)                         ) or 
       (  ex1_b_expo_b(1) and not ex1_b_expo_b(3) and not ex1_b_expo_b(4) ) or 
       (  ex1_b_expo_b(1) and not ex1_b_expo_b(3) and not ex1_b_expo_b(5) ) or 
       (  ex1_b_expo_b(1) and not ex1_b_expo_b(3) and not ex1_b_expo_b(6) ) or 
       (  ex1_b_expo_b(1) and not ex1_b_expo_b(3) and not ex1_b_expo_b(7)      
                                                  and not ex1_b_expo_b(8)      
                                                  and not ex1_b_expo_b(9)      
                                                  and not ex1_b_expo_b(10)     
                                                  and not ex1_b_expo_b(11)     
                                                  and not ex1_b_expo_b(12)     
                                                  and not ex1_b_expo_b(13) );  
 

  f_fmt_ex1_inf_and_beyond_sp <= ex1_b_expo_max  or ex1_b_expo_ge1151 ;
                       
              


  ex1_bfrac_eq_126     <= ex1_b_frac(0) and 
                          ex1_b_frac(1) and 
                          ex1_b_frac(2) and 
                          ex1_b_frac(3) and 
                          ex1_b_frac(4) and 
                          ex1_b_frac(5) ;   


  ex1_bfrac_126_nz <= ex1_b_frac(6)  or
                      ex1_b_frac(7)  or 
                      ex1_b_frac(8)  or 
                      ex1_b_frac(9)  or 
                      ex1_b_frac(10) or 
                      ex1_b_frac(11) or 
                      ex1_b_frac(12) or 
                      ex1_b_frac(13) or 
                      ex1_b_frac(14) or 
                      ex1_b_frac(15) or 
                      ex1_b_frac(16) or 
                      ex1_b_frac(17) or 
                      ex1_b_frac(18) or 
                      ex1_b_frac(19) or 
                      ex1_b_frac(20) or 
                      ex1_b_frac(21) or 
                      ex1_b_frac(22) or 
                      ex1_b_frac(23) ;


  
       ex1_a_frac_msb  <=     ex1_a_frac(1);
       ex1_c_frac_msb  <=     ex1_c_frac(1);
       ex1_b_frac_msb  <=     ex1_b_frac(1);

       ex1_a_expo_min  <= not ex1_a_frac(0) ;
       ex1_c_expo_min  <= not ex1_c_frac(0) ;
       ex1_b_expo_min  <= not ex1_b_frac(0) ;

       ex1_a_expo_max  <=     ex1_a_expo_b(1)    and 
                              ex1_a_expo_b(2)    and 
                          not ex1_a_expo_b(3)    and 
                          not ex1_a_expo_b(4)    and 
                          not ex1_a_expo_b(5)    and 
                          not ex1_a_expo_b(6)    and 
                          not ex1_a_expo_b(7)    and 
                          not ex1_a_expo_b(8)    and 
                          not ex1_a_expo_b(9)    and 
                          not ex1_a_expo_b(10)   and 
                          not ex1_a_expo_b(11)   and 
                          not ex1_a_expo_b(12)   and 
                          not ex1_a_expo_b(13)   ;

       ex1_c_expo_max  <=     ex1_c_expo_b(1)    and 
                              ex1_c_expo_b(2)    and 
                          not ex1_c_expo_b(3)    and 
                          not ex1_c_expo_b(4)    and 
                          not ex1_c_expo_b(5)    and 
                          not ex1_c_expo_b(6)    and 
                          not ex1_c_expo_b(7)    and 
                          not ex1_c_expo_b(8)    and 
                          not ex1_c_expo_b(9)    and 
                          not ex1_c_expo_b(10)   and 
                          not ex1_c_expo_b(11)   and 
                          not ex1_c_expo_b(12)   and 
                          not ex1_c_expo_b(13)   ;

       ex1_b_expo_max  <=     ex1_b_expo_b(1)    and 
                              ex1_b_expo_b(2)    and 
                          not ex1_b_expo_b(3)    and 
                          not ex1_b_expo_b(4)    and 
                          not ex1_b_expo_b(5)    and 
                          not ex1_b_expo_b(6)    and 
                          not ex1_b_expo_b(7)    and 
                          not ex1_b_expo_b(8)    and 
                          not ex1_b_expo_b(9)    and 
                          not ex1_b_expo_b(10)   and 
                          not ex1_b_expo_b(11)   and 
                          not ex1_b_expo_b(12)   and 
                          not ex1_b_expo_b(13)   ;


     ex1_a_frac_zero <= 
                         not ex1_a_frac( 1) and 
                         not ex1_a_frac( 2) and 
                         not ex1_a_frac( 3) and 
                         not ex1_a_frac( 4) and 
                         not ex1_a_frac( 5) and 
                         not ex1_a_frac( 6) and 
                         not ex1_a_frac( 7) and 
                         not ex1_a_frac( 8) and 
                         not ex1_a_frac( 9) and 
                         not ex1_a_frac(10) and 
                         not ex1_a_frac(11) and 
                         not ex1_a_frac(12) and 
                         not ex1_a_frac(13) and 
                         not ex1_a_frac(14) and 
                         not ex1_a_frac(15) and 
                         not ex1_a_frac(16) and 
                         not ex1_a_frac(17) and 
                         not ex1_a_frac(18) and 
                         not ex1_a_frac(19) and 
                         not ex1_a_frac(20) and 
                         not ex1_a_frac(21) and 
                         not ex1_a_frac(22) and 
                         not ex1_a_frac(23) and  
                         not ex1_a_frac(24) and 
                         not ex1_a_frac(25) and 
                         not ex1_a_frac(26) and 
                         not ex1_a_frac(27) and 
                         not ex1_a_frac(28) and 
                         not ex1_a_frac(29) and 
                         not ex1_a_frac(30) and 
                         not ex1_a_frac(31) and 
                         not ex1_a_frac(32) and 
                         not ex1_a_frac(33) and 
                         not ex1_a_frac(34) and 
                         not ex1_a_frac(35) and 
                         not ex1_a_frac(36) and 
                         not ex1_a_frac(37) and 
                         not ex1_a_frac(38) and 
                         not ex1_a_frac(39) and 
                         not ex1_a_frac(40) and 
                         not ex1_a_frac(41) and 
                         not ex1_a_frac(42) and 
                         not ex1_a_frac(43) and 
                         not ex1_a_frac(44) and 
                         not ex1_a_frac(45) and 
                         not ex1_a_frac(46) and 
                         not ex1_a_frac(47) and 
                         not ex1_a_frac(48) and 
                         not ex1_a_frac(49) and 
                         not ex1_a_frac(50) and 
                         not ex1_a_frac(51) and 
                         not ex1_a_frac(52) ;

     ex1_c_frac_zero <= 
                         not ex1_c_frac( 1) and 
                         not ex1_c_frac( 2) and 
                         not ex1_c_frac( 3) and 
                         not ex1_c_frac( 4) and 
                         not ex1_c_frac( 5) and 
                         not ex1_c_frac( 6) and 
                         not ex1_c_frac( 7) and 
                         not ex1_c_frac( 8) and 
                         not ex1_c_frac( 9) and 
                         not ex1_c_frac(10) and 
                         not ex1_c_frac(11) and 
                         not ex1_c_frac(12) and 
                         not ex1_c_frac(13) and 
                         not ex1_c_frac(14) and 
                         not ex1_c_frac(15) and 
                         not ex1_c_frac(16) and 
                         not ex1_c_frac(17) and 
                         not ex1_c_frac(18) and 
                         not ex1_c_frac(19) and 
                         not ex1_c_frac(20) and 
                         not ex1_c_frac(21) and 
                         not ex1_c_frac(22) and 
                         not ex1_c_frac(23) and 
                         not ex1_c_frac(24) and 
                         not ex1_c_frac(25) and 
                         not ex1_c_frac(26) and 
                         not ex1_c_frac(27) and 
                         not ex1_c_frac(28) and 
                         not ex1_c_frac(29) and 
                         not ex1_c_frac(30) and 
                         not ex1_c_frac(31) and 
                         not ex1_c_frac(32) and 
                         not ex1_c_frac(33) and 
                         not ex1_c_frac(34) and 
                         not ex1_c_frac(35) and 
                         not ex1_c_frac(36) and 
                         not ex1_c_frac(37) and 
                         not ex1_c_frac(38) and 
                         not ex1_c_frac(39) and 
                         not ex1_c_frac(40) and 
                         not ex1_c_frac(41) and 
                         not ex1_c_frac(42) and 
                         not ex1_c_frac(43) and 
                         not ex1_c_frac(44) and 
                         not ex1_c_frac(45) and 
                         not ex1_c_frac(46) and 
                         not ex1_c_frac(47) and 
                         not ex1_c_frac(48) and 
                         not ex1_c_frac(49) and 
                         not ex1_c_frac(50) and 
                         not ex1_c_frac(51) and 
                         not ex1_c_frac(52) ;


     ex1_b_frac_zero_sp <= 
                         not ex1_b_frac( 1) and 
                         not ex1_b_frac( 2) and 
                         not ex1_b_frac( 3) and 
                         not ex1_b_frac( 4) and 
                         not ex1_b_frac( 5) and 
                         not ex1_b_frac( 6) and 
                         not ex1_b_frac( 7) and 
                         not ex1_b_frac( 8) and 
                         not ex1_b_frac( 9) and 
                         not ex1_b_frac(10) and 
                         not ex1_b_frac(11) and 
                         not ex1_b_frac(12) and 
                         not ex1_b_frac(13) and 
                         not ex1_b_frac(14) and 
                         not ex1_b_frac(15) and 
                         not ex1_b_frac(16) and 
                         not ex1_b_frac(17) and 
                         not ex1_b_frac(18) and 
                         not ex1_b_frac(19) and 
                         not ex1_b_frac(20) and 
                         not ex1_b_frac(21) and 
                         not ex1_b_frac(22) and 
                         not ex1_b_frac(23) ;

            ex1_b_frac_zero <= ex1_b_frac_zero_sp and               ex1_b_frac_zero_dp ;

     ex1_b_frac_z32  <= 
                         not ex1_b_frac(24) and 
                         not ex1_b_frac(25) and 
                         not ex1_b_frac(26) and 
                         not ex1_b_frac(27) and 
                         not ex1_b_frac(28) and 
                         not ex1_b_frac(29) and 
                         not ex1_b_frac(30) and 
                         not ex1_b_frac(31) ;
    f_fmt_ex1_b_frac_z32 <=  ex1_b_frac_zero_sp and ex1_b_frac_z32; 
    ex1_b_frac_zero_dp <=    ex1_b_frac_z32 and 
                         not ex1_b_frac(32) and 
                         not ex1_b_frac(33) and 
                         not ex1_b_frac(34) and 
                         not ex1_b_frac(35) and 
                         not ex1_b_frac(36) and 
                         not ex1_b_frac(37) and 
                         not ex1_b_frac(38) and 
                         not ex1_b_frac(39) and 
                         not ex1_b_frac(40) and 
                         not ex1_b_frac(41) and 
                         not ex1_b_frac(42) and 
                         not ex1_b_frac(43) and 
                         not ex1_b_frac(44) and 
                         not ex1_b_frac(45) and 
                         not ex1_b_frac(46) and 
                         not ex1_b_frac(47) and 
                         not ex1_b_frac(48) and 
                         not ex1_b_frac(49) and 
                         not ex1_b_frac(50) and 
                         not ex1_b_frac(51) and 
                         not ex1_b_frac(52) ;
 

     f_fmt_ex1_b_frac(1 to 19) <= ex1_b_frac(1 to 19) ; 

   ex1_a_denz <= (not ex1_a_frac(0) or ex1_a_expo_ltx381_sp) and f_pic_ex1_nj_deni ; 
   ex1_c_denz <= (not ex1_c_frac(0) or ex1_c_expo_ltx381_sp) and f_pic_ex1_nj_deni ; 
   ex1_b_denz <= (not ex1_b_frac(0) or ex1_b_expo_ltx381_sp) and f_pic_ex1_nj_deni and not ex1_from_integer; 

       ex1_a_zero_x <= ( ex1_a_denz or (ex1_a_expo_min and ex1_a_frac_zero) );
       ex1_c_zero_x <= ( ex1_c_denz or (ex1_c_expo_min and ex1_c_frac_zero) );
       ex1_b_zero_x <= ( ex1_b_denz or (ex1_b_expo_min and ex1_b_frac_zero) ) and (not ex1_from_integer or not ex1_b_sign );

       

       ex1_b_den_flush <= ex1_b_den_sp or ex1_b_den_dp or ex1_a_den_sp; 

       ex1_b_den_dp <= f_pic_ex1_flush_en_dp    and
                             ex1_bop_valid      and
                             ex1_b_expo_min     and 
                         not ex1_b_frac_zero    and
                         not f_pic_ex1_nj_deni  and  
                         not ex1_b_expo(5)        ; 

       ex1_b_den_sp <= f_pic_ex1_flush_en_sp    and 
                             ex1_bop_valid      and
                             ex1_b_expo_min     and 
                         not ex1_b_frac_zero    and 
                         not(f_pic_ex1_nj_deni and not ex1_from_integer)  and  
                             ex1_b_expo(5)         ; 

       ex1_a_den_sp <= f_pic_ex1_ftdiv          and  
                             ex1_aop_valid      and
                             ex1_a_expo_min     and 
                         not ex1_a_frac_zero    and 
                         not f_pic_ex1_nj_deni  and  
                             ex1_a_expo(5)         ; 



       ex1_lu_den_part <= ex1_b_frac(1)  and
                          ex1_b_frac(2)  and 
                          ex1_b_frac(3)  and 
                          ex1_b_frac(4)  and 
                          ex1_b_frac(5)  and 
                          ex1_b_frac(6)  and 
                          ex1_b_frac(7)  and 
                          ex1_b_frac(8)  and 
                          ex1_b_frac(9)  and 
                          ex1_b_frac(10) and 
                          ex1_b_frac(11) and 
                          ex1_b_frac(12) ;

       ex1_recip_lo <=
                        ex1_b_frac(14) or
                        ex1_b_frac(15) or
                        ex1_b_frac(16) or
                        ex1_b_frac(17) or
                      ( ex1_b_frac(18) and ex1_b_frac(19)  ) or  
                      ( ex1_b_frac(18) and ex1_b_frac(20)  ) ;




       ex1_rsqrt_lo <=
                ex1_b_frac(13) or
                ex1_b_frac(14) or
                ex1_b_frac(15) or
                ex1_b_frac(16) or
              ( ex1_b_frac(17) and ex1_b_frac(18) )  or
              ( ex1_b_frac(17) and ex1_b_frac(19) )  or
              ( ex1_b_frac(17) and ex1_b_frac(20) and ex1_b_frac(21) )  ;

             

       ex1_lu_den_recip  <= 
          (ex1_lu_den_part and ex1_b_frac(13) and  ex1_recip_lo   );

       ex1_lu_den_rsqrto <=
          (ex1_lu_den_part and ex1_rsqrt_lo );

       f_fmt_ex2_lu_den_recip  <= ex2_lu_den_recip;
       f_fmt_ex2_lu_den_rsqrto <= ex2_lu_den_rsqrto; 




       ex1_a_zero <= ex1_aop_valid and ex1_a_zero_x ;
       ex1_c_zero <= ex1_cop_valid and ex1_c_zero_x ;
       ex1_b_zero <= ex1_bop_valid and ex1_b_zero_x ;

      

       f_fmt_ex1_a_zero      <= ex1_a_zero ;
       f_fmt_ex1_a_expo_max  <= ex1_aop_valid and ex1_a_expo_max ;
       f_fmt_ex1_a_frac_zero <= ex1_a_frac_zero ;
       f_fmt_ex1_a_frac_msb  <= ex1_a_frac_msb  ;

       f_fmt_ex1_c_zero      <= ex1_c_zero ;
       f_fmt_ex1_c_expo_max  <= ex1_cop_valid and ex1_c_expo_max  ;
       f_fmt_ex1_c_frac_zero <= ex1_c_frac_zero ;
       f_fmt_ex1_c_frac_msb  <= ex1_c_frac_msb  ;

       f_fmt_ex1_b_zero      <= ex1_b_zero ;
       f_fmt_ex1_b_expo_max  <= ex1_bop_valid and ex1_b_expo_max  ;
       f_fmt_ex1_b_frac_zero <= ex1_b_frac_zero ;
       f_fmt_ex1_b_frac_msb  <= ex1_b_frac_msb  ;
       f_fmt_ex1_b_imp       <= ex1_b_frac(0)   ;

       f_fmt_ex1_prod_zero   <= ex1_a_zero or ex1_c_zero   ;


       ex1_a_nan <= ex1_a_expo_max and not ex1_a_frac_zero and not ex1_from_integer and not ex1_sgncpy and not ex1_uc_end_nspec and not ex1_uc_mid and not f_dcd_ex1_perr_fsel_ovrd;
       ex1_c_nan <= ex1_c_expo_max and not ex1_c_frac_zero and not ex1_from_integer and not ex1_fsel   and not ex1_uc_end_nspec and not ex1_uc_mid; 
       ex1_b_nan <= ex1_b_expo_max and not ex1_b_frac_zero and not ex1_from_integer and not ex1_fsel   and not ex1_uc_end_nspec and not ex1_uc_mid;

       ex1_nan_pass <= ex1_a_nan or ex1_c_nan or ex1_b_nan ;
       ex1_pass_sel <= ex1_nan_pass or ex1_fsel or ex1_force_pass ;

       f_fmt_ex1_pass_sel      <= ex1_pass_sel    ;

       ex1_fsel_cif <= ( ex1_fsel and not ex1_a_sign and not f_dcd_ex1_perr_fsel_ovrd ) or  
                       ( ex1_fsel and     ex1_a_zero and not f_dcd_ex1_perr_fsel_ovrd ) or  
                       ( f_dcd_ex1_perr_force_c      and     f_dcd_ex1_perr_fsel_ovrd );    

       ex1_fsel_bsel <= ex1_fsel and ( ex1_a_nan or not ex1_fsel_cif );

       ex1_mux_a_sel <= ex1_a_nan and not ex1_fsel;

       ex1_mux_c_sel <=
              ( not ex1_a_nan and not ex1_b_nan and ex1_c_nan    ) or
              (     ex1_a_nan and not ex1_fsel                   ) or
              ( not ex1_a_nan and     ex1_fsel  and ex1_fsel_cif );

       ex1_pass_sign_ac <=
                (     ex1_mux_a_sel and ex1_a_sign ) or
                ( not ex1_mux_a_sel and ex1_c_sign ) ;
       ex1_pass_sign    <=
                (     ex1_mux_c_sel and ex1_pass_sign_ac ) or
                ( not ex1_mux_c_sel and ex1_b_sign       ) ;


       ex1_a_frac_chop(0 to 23) <= ex1_a_frac(0 to 23);
       ex1_c_frac_chop(0 to 23) <= ex1_c_frac(0 to 23);
       ex1_b_frac_chop(0 to 23) <= ex1_b_frac(0 to 23);

       ex1_a_frac_chop(24 to 52) <= ex1_a_frac(24 to 52); 
       ex1_c_frac_chop(24 to 52) <= ex1_c_frac(24 to 52); 
       ex1_b_frac_chop(24 to 52) <= ex1_b_frac(24 to 52); 


       ex1_a_expo_ltx381_sp <= ex1_a_expo_ltx381 and ex1_a_sp ;
       ex1_c_expo_ltx381_sp <= ex1_c_expo_ltx381 and ex1_c_sp ;
       ex1_b_expo_ltx381_sp <= ex1_b_expo_ltx381 and ex1_b_sp ;

       ex1_a_expo_ltx381 <=
             ( not ex1_a_expo_b(1)                                                                           ) or 
             (     ex1_a_expo_00xx_xxxx_xxxx and not ex1_a_expo_xx11_1xxx_xxxx                               ) or 
             (     ex1_a_expo_00xx_xxxx_xxxx and     ex1_a_expo_xx11_1xxx_xxxx and ex1_a_expo_xxxx_x000_0000 )  ;


       ex1_a_expo_00xx_xxxx_xxxx <=     ex1_a_expo_b(2)  and
                                        ex1_a_expo_b(3)  ;
       ex1_a_expo_xx11_1xxx_xxxx <= not ex1_a_expo_b(4)  and
                                    not ex1_a_expo_b(5)  and
                                    not ex1_a_expo_b(6)  ;
       ex1_a_expo_xxxx_x000_0000 <=     ex1_a_expo_b(7)  and
                                        ex1_a_expo_b(8)  and
                                        ex1_a_expo_b(9)  and
                                        ex1_a_expo_b(10) and
                                        ex1_a_expo_b(11) and
                                        ex1_a_expo_b(12) and
                                        ex1_a_expo_b(13) ;

       ex1_c_expo_ltx381 <=
             ( not ex1_c_expo_b(1)                                                                           ) or 
             (     ex1_c_expo_00xx_xxxx_xxxx and not ex1_c_expo_xx11_1xxx_xxxx                               ) or 
             (     ex1_c_expo_00xx_xxxx_xxxx and     ex1_c_expo_xx11_1xxx_xxxx and ex1_c_expo_xxxx_x000_0000 )  ;


       ex1_c_expo_00xx_xxxx_xxxx <=     ex1_c_expo_b(2)  and
                                        ex1_c_expo_b(3)  ;
       ex1_c_expo_xx11_1xxx_xxxx <= not ex1_c_expo_b(4)  and
                                    not ex1_c_expo_b(5)  and
                                    not ex1_c_expo_b(6)  ;
       ex1_c_expo_xxxx_x000_0000 <=     ex1_c_expo_b(7)  and
                                        ex1_c_expo_b(8)  and
                                        ex1_c_expo_b(9)  and
                                        ex1_c_expo_b(10) and
                                        ex1_c_expo_b(11) and
                                        ex1_c_expo_b(12) and
                                        ex1_c_expo_b(13) ;


       ex1_b_expo_ltx381 <=
             ( not ex1_b_expo_b(1)                                                                           ) or 
             (     ex1_b_expo_00xx_xxxx_xxxx and not ex1_b_expo_xx11_1xxx_xxxx                               ) or 
             (     ex1_b_expo_00xx_xxxx_xxxx and     ex1_b_expo_xx11_1xxx_xxxx and ex1_b_expo_xxxx_x000_0000 )  ;


       ex1_b_expo_00xx_xxxx_xxxx <=     ex1_b_expo_b(2)  and
                                        ex1_b_expo_b(3)  ;
       ex1_b_expo_xx11_1xxx_xxxx <= not ex1_b_expo_b(4)  and
                                    not ex1_b_expo_b(5)  and
                                    not ex1_b_expo_b(6)  ;
       ex1_b_expo_xxxx_x000_0000 <=     ex1_b_expo_b(7)  and
                                        ex1_b_expo_b(8)  and
                                        ex1_b_expo_b(9)  and
                                        ex1_b_expo_b(10) and
                                        ex1_b_expo_b(11) and
                                        ex1_b_expo_b(12) and
                                        ex1_b_expo_b(13) ;

       ex1_pass_frac_ac(0 to 52) <= 
                ( (0 to 52 =>     ex1_mux_a_sel) and ex1_a_frac_chop(0 to 52) ) or
                ( (0 to 52 => not ex1_mux_a_sel) and ex1_c_frac_chop(0 to 52) );
       ex1_pass_frac(0 to 52) <=
                ( (0 to 52 =>     ex1_mux_c_sel) and ex1_pass_frac_ac(0 to 52) ) or
                ( (0 to 52 => not ex1_mux_c_sel) and ex1_b_frac_chop(0 to 52)  );


       ex1_uc_a_expo_den  <=
               ( not ex1_a_expo_b(1)       ) or 
               (     ex1_a_expo_b(2)  and       
                     ex1_a_expo_b(3)  and       
                     ex1_a_expo_b(4)  and       
                     ex1_a_expo_b(5)  and       
                     ex1_a_expo_b(6)  and       
                     ex1_a_expo_b(7)  and       
                     ex1_a_expo_b(8)  and       
                     ex1_a_expo_b(9)  and       
                     ex1_a_expo_b(10) and       
                     ex1_a_expo_b(11) and       
                     ex1_a_expo_b(12) and       
                     ex1_a_expo_b(13)     );



       ex1_uc_a_expo_den_sp  <= ex1_a_expo_ltx381 ;

       ex1_a_sp_inf_alias_tail <=
                 not ex1_a_expo_b(7)  and  
                 not ex1_a_expo_b(8)  and  
                 not ex1_a_expo_b(9)  and  
                 not ex1_a_expo_b(10) and  
                 not ex1_a_expo_b(11) and  
                 not ex1_a_expo_b(12) and  
                 not ex1_a_expo_b(13) ;
       ex1_c_sp_inf_alias_tail <=
                 not ex1_c_expo_b(7)  and  
                 not ex1_c_expo_b(8)  and  
                 not ex1_c_expo_b(9)  and  
                 not ex1_c_expo_b(10) and  
                 not ex1_c_expo_b(11) and  
                 not ex1_c_expo_b(12) and  
                 not ex1_c_expo_b(13) ;
       ex1_b_sp_inf_alias_tail <=
                 not ex1_b_expo_b(7)  and  
                 not ex1_b_expo_b(8)  and  
                 not ex1_b_expo_b(9)  and  
                 not ex1_b_expo_b(10) and  
                 not ex1_b_expo_b(11) and  
                 not ex1_b_expo_b(12) and  
                 not ex1_b_expo_b(13) ;


       ex1_a_sp_expo_ok_1 <= 
                     ex1_a_expo_b(1) and  
                     ex1_a_expo_b(2) and  
                 not ex1_a_expo_b(3) and  
                     ex1_a_expo_b(4) and  
                     ex1_a_expo_b(5) and  
                     ex1_a_expo_b(6) and  
                 not ex1_a_sp_inf_alias_tail ;

       ex1_c_sp_expo_ok_1 <= 
                     ex1_c_expo_b(1) and  
                     ex1_c_expo_b(2) and  
                 not ex1_c_expo_b(3) and  
                     ex1_c_expo_b(4) and  
                     ex1_c_expo_b(5) and  
                     ex1_c_expo_b(6) and  
                 not ex1_c_sp_inf_alias_tail ;

       ex1_b_sp_expo_ok_1 <= 
                     ex1_b_expo_b(1) and  
                     ex1_b_expo_b(2) and  
                 not ex1_b_expo_b(3) and  
                     ex1_b_expo_b(4) and  
                     ex1_b_expo_b(5) and  
                     ex1_b_expo_b(6) and  
                 not ex1_b_sp_inf_alias_tail ;

       ex1_a_sp_expo_ok_2 <= 
                     ex1_a_expo_b(1) and  
                     ex1_a_expo_b(2) and  
                     ex1_a_expo_b(3) and  
                 not ex1_a_expo_b(4) and  
                 not ex1_a_expo_b(5) and  
                 not ex1_a_expo_b(6) ;    

       ex1_c_sp_expo_ok_2 <= 
                     ex1_c_expo_b(1) and  
                     ex1_c_expo_b(2) and  
                     ex1_c_expo_b(3) and  
                 not ex1_c_expo_b(4) and  
                 not ex1_c_expo_b(5) and  
                 not ex1_c_expo_b(6) ;    

       ex1_b_sp_expo_ok_2 <= 
                     ex1_b_expo_b(1) and  
                     ex1_b_expo_b(2) and  
                     ex1_b_expo_b(3) and  
                 not ex1_b_expo_b(4) and  
                 not ex1_b_expo_b(5) and  
                 not ex1_b_expo_b(6) ;    





       ex1_a_sp_expo_ok_3 <= 
                     ex1_a_expo_b(1) and  
                     ex1_a_expo_b(2) and  
                     ex1_a_expo_b(3) and  
                 not ex1_a_expo_b(4) and  
                 not ex1_a_expo_b(5) and  
                     ex1_a_expo_b(6) and  
                 not ex1_a_expo_b(7) and  
                 not ex1_a_expo_b(8) and  
                 not ex1_a_expo_b(9) ;    

       ex1_c_sp_expo_ok_3 <= 
                     ex1_c_expo_b(1) and  
                     ex1_c_expo_b(2) and  
                     ex1_c_expo_b(3) and  
                 not ex1_c_expo_b(4) and  
                 not ex1_c_expo_b(5) and  
                     ex1_c_expo_b(6) and  
                 not ex1_c_expo_b(7) and  
                 not ex1_c_expo_b(8) and  
                 not ex1_c_expo_b(9) ;    

       ex1_b_sp_expo_ok_3 <= 
                     ex1_b_expo_b(1) and  
                     ex1_b_expo_b(2) and  
                     ex1_b_expo_b(3) and  
                 not ex1_b_expo_b(4) and  
                 not ex1_b_expo_b(5) and  
                     ex1_b_expo_b(6) and  
                 not ex1_b_expo_b(7) and  
                 not ex1_b_expo_b(8) and  
                 not ex1_b_expo_b(9) ;    


       ex1_a_sp_expo_ok_4 <= 
                     ex1_a_expo_b(1) and  
                     ex1_a_expo_b(2) and  
                     ex1_a_expo_b(3) and  
                 not ex1_a_expo_b(4) and  
                 not ex1_a_expo_b(5) and  
                     ex1_a_expo_b(6) and  
                 not ex1_a_expo_b(7) and  
                 not ex1_a_expo_b(8) and  
                     ex1_a_expo_b(9) and  
                    ( ( not ex1_a_expo_b(10) and not ex1_a_expo_b(11) ) or 
                      ( not ex1_a_expo_b(10) and not ex1_a_expo_b(12) ) ) ;   


       ex1_c_sp_expo_ok_4 <= 
                     ex1_c_expo_b(1) and  
                     ex1_c_expo_b(2) and  
                     ex1_c_expo_b(3) and  
                 not ex1_c_expo_b(4) and  
                 not ex1_c_expo_b(5) and  
                     ex1_c_expo_b(6) and  
                 not ex1_c_expo_b(7) and  
                 not ex1_c_expo_b(8) and  
                     ex1_c_expo_b(9) and  
                    ( ( not ex1_c_expo_b(10) and not ex1_c_expo_b(11) ) or 
                      ( not ex1_c_expo_b(10) and not ex1_c_expo_b(12) ) ) ;   

       ex1_b_sp_expo_ok_4 <= 
                     ex1_b_expo_b(1) and  
                     ex1_b_expo_b(2) and  
                     ex1_b_expo_b(3) and  
                 not ex1_b_expo_b(4) and  
                 not ex1_b_expo_b(5) and  
                     ex1_b_expo_b(6) and  
                 not ex1_b_expo_b(7) and  
                 not ex1_b_expo_b(8) and  
                     ex1_b_expo_b(9) and  
                    ( ( not ex1_b_expo_b(10) and not ex1_b_expo_b(11) ) or 
                      ( not ex1_b_expo_b(10) and not ex1_b_expo_b(12) ) ) ;   






       


       f_fmt_ex1_sp_invalid <=
                     ( not ex1_a_sp_expo_ok_1 and
                       not ex1_a_sp_expo_ok_2 and
                       not ex1_a_sp_expo_ok_3 and
                       not ex1_a_sp_expo_ok_4 and
                       not ex1_a_expo_max     and
                       not ex1_a_zero_x              ) or 
                     ( not ex1_c_sp_expo_ok_1 and
                       not ex1_c_sp_expo_ok_2 and
                       not ex1_c_sp_expo_ok_3 and
                       not ex1_c_sp_expo_ok_4 and
                       not ex1_c_expo_max and
                       not ex1_c_zero_x              ) or 
                     ( not ex1_b_sp_expo_ok_1 and
                       not ex1_b_sp_expo_ok_2 and
                       not ex1_b_sp_expo_ok_3 and
                       not ex1_b_sp_expo_ok_4 and
                       not ex1_b_expo_max     and
                       not ex1_b_zero_x               ) ;





  ex1_a_party(0)  <= ex1_a_sign     xor ex1_a_expo(2)  xor ex1_a_expo(3)  xor ex1_a_expo(4)  xor ex1_a_expo(5)  xor
                     ex1_a_expo(6)  xor ex1_a_expo(7)  xor ex1_a_expo(8)  xor ex1_a_expo(9) ;
  ex1_a_party(1)  <= ex1_a_expo(10) xor ex1_a_expo(11) xor ex1_a_expo(12) xor ex1_a_expo(13) xor ex1_a_frac(0) xor
                     ex1_a_frac(1)  xor ex1_a_frac(2)  xor ex1_a_frac(3)  xor ex1_a_frac(4) ;
  ex1_a_party(2)  <= ex1_a_frac(5)  xor ex1_a_frac(6)  xor ex1_a_frac(7)  xor ex1_a_frac(8)  xor
                     ex1_a_frac(9)  xor ex1_a_frac(10) xor ex1_a_frac(11) xor ex1_a_frac(12) ;
  ex1_a_party(3)  <= ex1_a_frac(13) xor ex1_a_frac(14) xor ex1_a_frac(15) xor ex1_a_frac(16) xor
                     ex1_a_frac(17) xor ex1_a_frac(18) xor ex1_a_frac(19) xor ex1_a_frac(20) ;
  ex1_a_party(4)  <= ex1_a_frac(21) xor ex1_a_frac(22) xor ex1_a_frac(23) xor ex1_a_frac(24) xor
                     ex1_a_frac(25) xor ex1_a_frac(26) xor ex1_a_frac(27) xor ex1_a_frac(28) ;
  ex1_a_party(5)  <= ex1_a_frac(29) xor ex1_a_frac(30) xor ex1_a_frac(31) xor ex1_a_frac(32) xor
                     ex1_a_frac(33) xor ex1_a_frac(34) xor ex1_a_frac(35) xor ex1_a_frac(36) ;
  ex1_a_party(6)  <= ex1_a_frac(37) xor ex1_a_frac(38) xor ex1_a_frac(39) xor ex1_a_frac(40) xor
                     ex1_a_frac(41) xor ex1_a_frac(42) xor ex1_a_frac(43) xor ex1_a_frac(44) ;
  ex1_a_party(7)  <= ex1_a_frac(45) xor ex1_a_frac(46) xor ex1_a_frac(47) xor ex1_a_frac(48) xor
                     ex1_a_frac(49) xor ex1_a_frac(50) xor ex1_a_frac(51) xor ex1_a_frac(52) ;

  ex1_c_party(0)  <= ex1_c_sign     xor ex1_c_expo(2)  xor ex1_c_expo(3)  xor ex1_c_expo(4)  xor ex1_c_expo(5)  xor
                     ex1_c_expo(6)  xor ex1_c_expo(7)  xor ex1_c_expo(8)  xor ex1_c_expo(9) ;
  ex1_c_party(1)  <= ex1_c_expo(10) xor ex1_c_expo(11) xor ex1_c_expo(12) xor ex1_c_expo(13) xor ex1_c_frac(0) xor
                     ex1_c_frac(1)  xor ex1_c_frac(2)  xor ex1_c_frac(3)  xor ex1_c_frac(4) ;
  ex1_c_party(2)  <= ex1_c_frac(5)  xor ex1_c_frac(6)  xor ex1_c_frac(7)  xor ex1_c_frac(8)  xor
                     ex1_c_frac(9)  xor ex1_c_frac(10) xor ex1_c_frac(11) xor ex1_c_frac(12) ;
  ex1_c_party(3)  <= ex1_c_frac(13) xor ex1_c_frac(14) xor ex1_c_frac(15) xor ex1_c_frac(16) xor
                     ex1_c_frac(17) xor ex1_c_frac(18) xor ex1_c_frac(19) xor ex1_c_frac(20) ;
  ex1_c_party(4)  <= ex1_c_frac(21) xor ex1_c_frac(22) xor ex1_c_frac(23) xor ex1_c_frac(24) xor
                     ex1_c_frac(25) xor ex1_c_frac(26) xor ex1_c_frac(27) xor ex1_c_frac(28) ;
  ex1_c_party(5)  <= ex1_c_frac(29) xor ex1_c_frac(30) xor ex1_c_frac(31) xor ex1_c_frac(32) xor
                     ex1_c_frac(33) xor ex1_c_frac(34) xor ex1_c_frac(35) xor ex1_c_frac(36) ;
  ex1_c_party(6)  <= ex1_c_frac(37) xor ex1_c_frac(38) xor ex1_c_frac(39) xor ex1_c_frac(40) xor
                     ex1_c_frac(41) xor ex1_c_frac(42) xor ex1_c_frac(43) xor ex1_c_frac(44) ;
  ex1_c_party(7)  <= ex1_c_frac(45) xor ex1_c_frac(46) xor ex1_c_frac(47) xor ex1_c_frac(48) xor
                     ex1_c_frac(49) xor ex1_c_frac(50) xor ex1_c_frac(51) xor ex1_c_frac(52) ;


  ex1_b_party(0)  <= ex1_b_sign     xor ex1_b_expo(2)  xor ex1_b_expo(3)  xor ex1_b_expo(4)  xor ex1_b_expo(5)  xor
                     ex1_b_expo(6)  xor ex1_b_expo(7)  xor ex1_b_expo(8)  xor ex1_b_expo(9) ;
  ex1_b_party(1)  <= ex1_b_expo(10) xor ex1_b_expo(11) xor ex1_b_expo(12) xor ex1_b_expo(13) xor ex1_b_frac(0) xor
                     ex1_b_frac(1)  xor ex1_b_frac(2)  xor ex1_b_frac(3)  xor ex1_b_frac(4) ;
  ex1_b_party(2)  <= ex1_b_frac(5)  xor ex1_b_frac(6)  xor ex1_b_frac(7)  xor ex1_b_frac(8)  xor
                     ex1_b_frac(9)  xor ex1_b_frac(10) xor ex1_b_frac(11) xor ex1_b_frac(12) ;
  ex1_b_party(3)  <= ex1_b_frac(13) xor ex1_b_frac(14) xor ex1_b_frac(15) xor ex1_b_frac(16) xor
                     ex1_b_frac(17) xor ex1_b_frac(18) xor ex1_b_frac(19) xor ex1_b_frac(20) ;
  ex1_b_party(4)  <= ex1_b_frac(21) xor ex1_b_frac(22) xor ex1_b_frac(23) xor ex1_b_frac(24) xor
                     ex1_b_frac(25) xor ex1_b_frac(26) xor ex1_b_frac(27) xor ex1_b_frac(28) ;
  ex1_b_party(5)  <= ex1_b_frac(29) xor ex1_b_frac(30) xor ex1_b_frac(31) xor ex1_b_frac(32) xor
                     ex1_b_frac(33) xor ex1_b_frac(34) xor ex1_b_frac(35) xor ex1_b_frac(36) ;
  ex1_b_party(6)  <= ex1_b_frac(37) xor ex1_b_frac(38) xor ex1_b_frac(39) xor ex1_b_frac(40) xor
                     ex1_b_frac(41) xor ex1_b_frac(42) xor ex1_b_frac(43) xor ex1_b_frac(44) ;
  ex1_b_party(7)  <= ex1_b_frac(45) xor ex1_b_frac(46) xor ex1_b_frac(47) xor ex1_b_frac(48) xor
                     ex1_b_frac(49) xor ex1_b_frac(50) xor ex1_b_frac(51) xor ex1_b_frac(52) ;


       ex1_a_party_chick <= (ex1_a_party(0) xor f_fpr_ex1_a_par(0) ) or
                            (ex1_a_party(1) xor f_fpr_ex1_a_par(1) ) or
                            (ex1_a_party(2) xor f_fpr_ex1_a_par(2) ) or
                            (ex1_a_party(3) xor f_fpr_ex1_a_par(3) ) or
                            (ex1_a_party(4) xor f_fpr_ex1_a_par(4) ) or
                            (ex1_a_party(5) xor f_fpr_ex1_a_par(5) ) or
                            (ex1_a_party(6) xor f_fpr_ex1_a_par(6) ) or
                            (ex1_a_party(7) xor f_fpr_ex1_a_par(7) ) ;

       ex1_c_party_chick <= (ex1_c_party(0) xor f_fpr_ex1_c_par(0) ) or
                            (ex1_c_party(1) xor f_fpr_ex1_c_par(1) ) or
                            (ex1_c_party(2) xor f_fpr_ex1_c_par(2) ) or
                            (ex1_c_party(3) xor f_fpr_ex1_c_par(3) ) or
                            (ex1_c_party(4) xor f_fpr_ex1_c_par(4) ) or
                            (ex1_c_party(5) xor f_fpr_ex1_c_par(5) ) or
                            (ex1_c_party(6) xor f_fpr_ex1_c_par(6) ) or
                            (ex1_c_party(7) xor f_fpr_ex1_c_par(7) ) ;

       ex1_b_party_chick <= (ex1_b_party(0) xor f_fpr_ex1_b_par(0) ) or
                            (ex1_b_party(1) xor f_fpr_ex1_b_par(1) ) or
                            (ex1_b_party(2) xor f_fpr_ex1_b_par(2) ) or
                            (ex1_b_party(3) xor f_fpr_ex1_b_par(3) ) or
                            (ex1_b_party(4) xor f_fpr_ex1_b_par(4) ) or
                            (ex1_b_party(5) xor f_fpr_ex1_b_par(5) ) or
                            (ex1_b_party(6) xor f_fpr_ex1_b_par(6) ) or
                            (ex1_b_party(7) xor f_fpr_ex1_b_par(7) ) ;





   ex1_be_den  <= 
           (     ex1_b_expo(1)      ) or 
           ( not ex1_b_expo(2)  and    
             not ex1_b_expo(3)  and    
             not ex1_b_expo(4)  and    
             not ex1_b_expo(5)  and    
             not ex1_b_expo(6)  and    
             not ex1_b_expo(7)  and    
             not ex1_b_expo(8)  and    
             not ex1_b_expo(9)  and    
             not ex1_b_expo(10) and    
             not ex1_b_expo(11) and    
             not ex1_b_expo(12) and    
             not ex1_b_expo(13)     ); 



   ex1_ae_234567   <= ex1_a_expo(2)  or ex1_a_expo(3) or ex1_a_expo(4)  or
                       ex1_a_expo(5)  or ex1_a_expo(6) or ex1_a_expo(7)  ;
   ex1_ae_89        <= ex1_a_expo(8) and ex1_a_expo(9) ;
   ex1_ae_abc       <= ex1_a_expo(10) or (ex1_a_expo(11) and  ex1_a_expo(12) ) ;

   ex1_ae_ge_54 <=
      (not ex1_a_expo(1) and ex1_ae_234567            ) or 
      (not ex1_a_expo(1) and ex1_ae_89 and ex1_ae_abc ) ;

   ex1_be_234567   <= ex1_b_expo(2)  or ex1_b_expo(3) or ex1_b_expo(4)  or
                       ex1_b_expo(5)  or ex1_b_expo(6) or ex1_b_expo(7)  ;
   ex1_be_89        <= ex1_b_expo(8) and ex1_b_expo(9) ;
   ex1_be_abc       <= ex1_b_expo(10) or (ex1_b_expo(11) and  ex1_b_expo(12) ) ;

   ex1_be_ge_54 <=
      (not ex1_b_expo(1) and ex1_be_234567            ) or 
      (not ex1_b_expo(1) and ex1_be_89 and ex1_be_abc ) ;


   ex1_be_or_23456789abc <=
              ex1_b_expo(2)  or 
              ex1_b_expo(3)  or 
              ex1_b_expo(4)  or 
              ex1_b_expo(5)  or 
              ex1_b_expo(6)  or 
              ex1_b_expo(7)  or 
              ex1_b_expo(8)  or 
              ex1_b_expo(9)  or 
              ex1_b_expo(10) or 
              ex1_b_expo(11) or 
              ex1_b_expo(12) ;

   ex1_be_and_3456789ab <= 
              ex1_b_expo(3)  and 
              ex1_b_expo(4)  and 
              ex1_b_expo(5)  and 
              ex1_b_expo(6)  and 
              ex1_b_expo(7)  and 
              ex1_b_expo(8)  and 
              ex1_b_expo(9)  and 
              ex1_b_expo(10) and 
              ex1_b_expo(11) ;

   ex1_be_ge_2    <=   not ex1_b_expo(1) and ex1_be_or_23456789abc ;
   ex1_be_ge_2044 <= ( not ex1_b_expo(1) and ex1_be_and_3456789ab ) or
                     ( not ex1_b_expo(1) and ex1_b_expo(2)        ) ;





   ex1_aembex_car_b( 0) <= not( ex1_a_expo( 1)  or ex1_b_expo_b( 1) ) ; 
   ex1_aembex_car_b( 1) <= not( ex1_a_expo( 2)  or ex1_b_expo_b( 2) ) ; 
   ex1_aembex_car_b( 2) <= not( ex1_a_expo( 3)  or ex1_b_expo_b( 3) ) ; 
   ex1_aembex_car_b( 3) <= not( ex1_a_expo( 4) and ex1_b_expo_b( 4) ) ; 
   ex1_aembex_car_b( 4) <= not( ex1_a_expo( 5) and ex1_b_expo_b( 5) ) ; 
   ex1_aembex_car_b( 5) <= not( ex1_a_expo( 6) and ex1_b_expo_b( 6) ) ; 
   ex1_aembex_car_b( 6) <= not( ex1_a_expo( 7) and ex1_b_expo_b( 7) ) ; 
   ex1_aembex_car_b( 7) <= not( ex1_a_expo( 8) and ex1_b_expo_b( 8) ) ; 
   ex1_aembex_car_b( 8) <= not( ex1_a_expo( 9) and ex1_b_expo_b( 9) ) ; 
   ex1_aembex_car_b( 9) <= not( ex1_a_expo(10) and ex1_b_expo_b(10) ) ; 
   ex1_aembex_car_b(10) <= not( ex1_a_expo(11) and ex1_b_expo_b(11) ) ; 
   ex1_aembex_car_b(11) <= not( ex1_a_expo(12)  or ex1_b_expo_b(12) ) ; 
   ex1_aembex_car_b(12) <= not( ex1_a_expo(13) and ex1_b_expo_b(13) ) ; 

   ex1_aembex_sum_b( 1) <=    ( ex1_a_expo( 1) xor ex1_b_expo_b( 1) ) ; 
   ex1_aembex_sum_b( 2) <=    ( ex1_a_expo( 2) xor ex1_b_expo_b( 2) ) ; 
   ex1_aembex_sum_b( 3) <=    ( ex1_a_expo( 3) xor ex1_b_expo_b( 3) ) ; 
   ex1_aembex_sum_b( 4) <= not( ex1_a_expo( 4) xor ex1_b_expo_b( 4) ) ; 
   ex1_aembex_sum_b( 5) <= not( ex1_a_expo( 5) xor ex1_b_expo_b( 5) ) ; 
   ex1_aembex_sum_b( 6) <= not( ex1_a_expo( 6) xor ex1_b_expo_b( 6) ) ; 
   ex1_aembex_sum_b( 7) <= not( ex1_a_expo( 7) xor ex1_b_expo_b( 7) ) ; 
   ex1_aembex_sum_b( 8) <= not( ex1_a_expo( 8) xor ex1_b_expo_b( 8) ) ; 
   ex1_aembex_sum_b( 9) <= not( ex1_a_expo( 9) xor ex1_b_expo_b( 9) ) ; 
   ex1_aembex_sum_b(10) <= not( ex1_a_expo(10) xor ex1_b_expo_b(10) ) ; 
   ex1_aembex_sum_b(11) <= not( ex1_a_expo(11) xor ex1_b_expo_b(11) ) ; 
   ex1_aembex_sum_b(12) <=    ( ex1_a_expo(12) xor ex1_b_expo_b(12) ) ; 
   ex1_aembex_sum_b(13) <= not( ex1_a_expo(13) xor ex1_b_expo_b(13) ) ; 


   ex1_aembex_sgn         <=     ex1_aembex_sum_b(1) xor       ex1_aembex_car_b(1) ;

   ex1_aembex_g1(2 to 12) <= not(ex1_aembex_sum_b(2 to 12) or  ex1_aembex_car_b(2 to 12) );
   ex1_aembex_t1(2 to 12) <= not(ex1_aembex_sum_b(2 to 12) and ex1_aembex_car_b(2 to 12) );

   
   ex1_aembex_g2(0)       <= ex1_aembex_g1( 2) or ( ex1_aembex_t1( 2) and ex1_aembex_g1( 3) );
   ex1_aembex_g2(1)       <= ex1_aembex_g1( 4) or ( ex1_aembex_t1( 4) and ex1_aembex_g1( 5) );
   ex1_aembex_g2(2)       <= ex1_aembex_g1( 6) or ( ex1_aembex_t1( 6) and ex1_aembex_g1( 7) );
   ex1_aembex_g2(3)       <= ex1_aembex_g1( 8) or ( ex1_aembex_t1( 8) and ex1_aembex_g1( 9) );
   ex1_aembex_g2(4)       <= ex1_aembex_g1(10) or ( ex1_aembex_t1(10) and ex1_aembex_g1(11) );
   ex1_aembex_g2(5)       <= ex1_aembex_g1(12) ;

   ex1_aembex_t2(0)       <=                  ( ex1_aembex_t1( 2) and ex1_aembex_t1( 3) );
   ex1_aembex_t2(1)       <=                  ( ex1_aembex_t1( 4) and ex1_aembex_t1( 5) );
   ex1_aembex_t2(2)       <=                  ( ex1_aembex_t1( 6) and ex1_aembex_t1( 7) );
   ex1_aembex_t2(3)       <=                  ( ex1_aembex_t1( 8) and ex1_aembex_t1( 9) );
   ex1_aembex_t2(4)       <=                  ( ex1_aembex_t1(10) and ex1_aembex_t1(11) );


   ex1_aembex_g4(0)       <= ex1_aembex_g2( 0) or ( ex1_aembex_t2( 0) and ex1_aembex_g2( 1) );
   ex1_aembex_g4(1)       <= ex1_aembex_g2( 2) or ( ex1_aembex_t2( 2) and ex1_aembex_g2( 3) );
   ex1_aembex_g4(2)       <= ex1_aembex_g2( 4) or ( ex1_aembex_t2( 4) and ex1_aembex_g2( 5) );

   ex1_aembex_t4(0)       <=                  ( ex1_aembex_t2( 0) and ex1_aembex_t2( 1) );
   ex1_aembex_t4(1)       <=                  ( ex1_aembex_t2( 2) and ex1_aembex_t2( 3) );



   ex1_aembey_car_b( 0) <= not( ex1_a_expo( 1) and ex1_b_expo_b( 1) ) ; 
   ex1_aembey_car_b( 1) <= not( ex1_a_expo( 2) and ex1_b_expo_b( 2) ) ; 
   ex1_aembey_car_b( 2) <= not( ex1_a_expo( 3) and ex1_b_expo_b( 3) ) ; 
   ex1_aembey_car_b( 3) <= not( ex1_a_expo( 4)  or ex1_b_expo_b( 4) ) ; 
   ex1_aembey_car_b( 4) <= not( ex1_a_expo( 5)  or ex1_b_expo_b( 5) ) ; 
   ex1_aembey_car_b( 5) <= not( ex1_a_expo( 6)  or ex1_b_expo_b( 6) ) ; 
   ex1_aembey_car_b( 6) <= not( ex1_a_expo( 7)  or ex1_b_expo_b( 7) ) ; 
   ex1_aembey_car_b( 7) <= not( ex1_a_expo( 8)  or ex1_b_expo_b( 8) ) ; 
   ex1_aembey_car_b( 8) <= not( ex1_a_expo( 9)  or ex1_b_expo_b( 9) ) ; 
   ex1_aembey_car_b( 9) <= not( ex1_a_expo(10)  or ex1_b_expo_b(10) ) ; 
   ex1_aembey_car_b(10) <= not( ex1_a_expo(11)  or ex1_b_expo_b(11) ) ; 
   ex1_aembey_car_b(11) <= not( ex1_a_expo(12) and ex1_b_expo_b(12) ) ; 
   ex1_aembey_car_b(12) <= not( ex1_a_expo(13)  or ex1_b_expo_b(13) ) ; 

   ex1_aembey_sum_b( 1) <= not( ex1_a_expo( 1) xor ex1_b_expo_b( 1) ) ; 
   ex1_aembey_sum_b( 2) <= not( ex1_a_expo( 2) xor ex1_b_expo_b( 2) ) ; 
   ex1_aembey_sum_b( 3) <= not( ex1_a_expo( 3) xor ex1_b_expo_b( 3) ) ; 
   ex1_aembey_sum_b( 4) <=    ( ex1_a_expo( 4) xor ex1_b_expo_b( 4) ) ; 
   ex1_aembey_sum_b( 5) <=    ( ex1_a_expo( 5) xor ex1_b_expo_b( 5) ) ; 
   ex1_aembey_sum_b( 6) <=    ( ex1_a_expo( 6) xor ex1_b_expo_b( 6) ) ; 
   ex1_aembey_sum_b( 7) <=    ( ex1_a_expo( 7) xor ex1_b_expo_b( 7) ) ; 
   ex1_aembey_sum_b( 8) <=    ( ex1_a_expo( 8) xor ex1_b_expo_b( 8) ) ; 
   ex1_aembey_sum_b( 9) <=    ( ex1_a_expo( 9) xor ex1_b_expo_b( 9) ) ; 
   ex1_aembey_sum_b(10) <=    ( ex1_a_expo(10) xor ex1_b_expo_b(10) ) ; 
   ex1_aembey_sum_b(11) <=    ( ex1_a_expo(11) xor ex1_b_expo_b(11) ) ; 
   ex1_aembey_sum_b(12) <= not( ex1_a_expo(12) xor ex1_b_expo_b(12) ) ; 
   ex1_aembey_sum_b(13) <=    ( ex1_a_expo(13) xor ex1_b_expo_b(13) ) ; 


   ex1_aembey_sgn         <=     ex1_aembey_sum_b(1) xor       ex1_aembey_car_b(1) ;

   ex1_aembey_g1(2 to 12) <= not(ex1_aembey_sum_b(2 to 12) or  ex1_aembey_car_b(2 to 12) );
   ex1_aembey_t1(2 to 12) <= not(ex1_aembey_sum_b(2 to 12) and ex1_aembey_car_b(2 to 12) );

   
   ex1_aembey_g2(0)       <= ex1_aembey_g1( 2) or ( ex1_aembey_t1( 2) and ex1_aembey_g1( 3) );
   ex1_aembey_g2(1)       <= ex1_aembey_g1( 4) or ( ex1_aembey_t1( 4) and ex1_aembey_g1( 5) );
   ex1_aembey_g2(2)       <= ex1_aembey_g1( 6) or ( ex1_aembey_t1( 6) and ex1_aembey_g1( 7) );
   ex1_aembey_g2(3)       <= ex1_aembey_g1( 8) or ( ex1_aembey_t1( 8) and ex1_aembey_g1( 9) );
   ex1_aembey_g2(4)       <= ex1_aembey_g1(10) or ( ex1_aembey_t1(10) and ex1_aembey_g1(11) );
   ex1_aembey_g2(5)       <= ex1_aembey_g1(12) ;

   ex1_aembey_t2(0)       <=                  ( ex1_aembey_t1( 2) and ex1_aembey_t1( 3) );
   ex1_aembey_t2(1)       <=                  ( ex1_aembey_t1( 4) and ex1_aembey_t1( 5) );
   ex1_aembey_t2(2)       <=                  ( ex1_aembey_t1( 6) and ex1_aembey_t1( 7) );
   ex1_aembey_t2(3)       <=                  ( ex1_aembey_t1( 8) and ex1_aembey_t1( 9) );
   ex1_aembey_t2(4)       <=                  ( ex1_aembey_t1(10) and ex1_aembey_t1(11) );


   ex1_aembey_g4(0)       <= ex1_aembey_g2( 0) or ( ex1_aembey_t2( 0) and ex1_aembey_g2( 1) );
   ex1_aembey_g4(1)       <= ex1_aembey_g2( 2) or ( ex1_aembey_t2( 2) and ex1_aembey_g2( 3) );
   ex1_aembey_g4(2)       <= ex1_aembey_g2( 4) or ( ex1_aembey_t2( 4) and ex1_aembey_g2( 5) );

   ex1_aembey_t4(0)       <=                  ( ex1_aembey_t2( 0) and ex1_aembey_t2( 1) );
   ex1_aembey_t4(1)       <=                  ( ex1_aembey_t2( 2) and ex1_aembey_t2( 3) );







    ex2_pass_lat:  tri_rlmreg_p generic map (width=> 80, expand_type => expand_type, ibuf => true, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(2)  ,
        mpw1_b           => mpw1_b(2)       ,
        mpw2_b           => mpw2_b(0)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => ex1_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex2_pass_so  ,                      
        scin             => ex2_pass_si  ,                    
         din(0)             => ex1_fsel_bsel ,
         din(1)             => ex1_pass_sign ,         
         din(2 to 54)       => ex1_pass_frac(0 to 52) ,
         din(55)            => ex1_b_den_flush,
         din(56)            => ex1_lu_den_recip,
         din(57)            => ex1_lu_den_rsqrto ,
         din(58)            => ex1_uc_a_expo_den ,
         din(59)            => ex1_uc_a_expo_den_sp ,
         din(60)            => ex1_a_party_chick ,
         din(61)            => ex1_c_party_chick ,
         din(62)            => ex1_b_party_chick ,
         din(63)            => ex1_ae_ge_54 ,
         din(64)            => ex1_be_ge_54 ,
         din(65)            => ex1_be_ge_2    ,
         din(66)            => ex1_be_ge_2044 ,
         din(67)            => ex1_aembex_g4(0)  , 
         din(68)            => ex1_aembex_t4(0)  , 
         din(69)            => ex1_aembex_g4(1)  , 
         din(70)            => ex1_aembex_t4(1)  , 
         din(71)            => ex1_aembex_g4(2)  , 
         din(72)            => ex1_aembey_g4(0)  , 
         din(73)            => ex1_aembey_t4(0)  , 
         din(74)            => ex1_aembey_g4(1)  , 
         din(75)            => ex1_aembey_t4(1)  , 
         din(76)            => ex1_aembey_g4(2)  , 
         din(77)            => ex1_aembex_sgn    , 
         din(78)            => ex1_aembey_sgn    , 
         din(79)            => ex1_be_den        , 
        dout(0)             => ex2_fsel_bsel   ,
        dout(1)             => ex2_pass_sign   ,
        dout(2 to 54)       => ex2_pass_frac  (0 to 52),
        dout(55)            => ex2_b_den_flush ,
        dout(56)            => ex2_lu_den_recip,
        dout(57)            => ex2_lu_den_rsqrto,
        dout(58)            => ex2_uc_a_expo_den  ,
        dout(59)            => ex2_uc_a_expo_den_sp ,
        dout(60)            => ex2_a_party_chick   ,
        dout(61)            => ex2_c_party_chick   ,
        dout(62)            => ex2_b_party_chick   ,
        dout(63)            => ex2_ae_ge_54 ,
        dout(64)            => ex2_be_ge_54 ,
        dout(65)            => ex2_be_ge_2    ,
        dout(66)            => ex2_be_ge_2044 ,
        dout(67)            => ex2_aembex_g4(0)  , 
        dout(68)            => ex2_aembex_t4(0)  , 
        dout(69)            => ex2_aembex_g4(1)  , 
        dout(70)            => ex2_aembex_t4(1)  , 
        dout(71)            => ex2_aembex_g4(2)  , 
        dout(72)            => ex2_aembey_g4(0)  , 
        dout(73)            => ex2_aembey_t4(0)  , 
        dout(74)            => ex2_aembey_g4(1)  , 
        dout(75)            => ex2_aembey_t4(1)  , 
        dout(76)            => ex2_aembey_g4(2)  , 
        dout(77)            => ex2_aembex_sgn    , 
        dout(78)            => ex2_aembey_sgn    , 
        dout(79)            => ex2_be_den       ); 


       f_mad_ex2_a_parity_check <= ex2_a_party_chick ;
       f_mad_ex2_c_parity_check <= ex2_c_party_chick ;
       f_mad_ex2_b_parity_check <= ex2_b_party_chick ;


       f_mad_ex2_uc_a_expo_den    <= ex2_uc_a_expo_den ;
       f_mad_ex2_uc_a_expo_den_sp <= ex2_uc_a_expo_den_sp ;
       f_ex2_b_den_flush <= ex2_b_den_flush ;

       f_fmt_ex2_fsel_bsel          <=     ex2_fsel_bsel          ;
       f_fmt_ex2_pass_sign          <=     ex2_pass_sign          ;
       f_fmt_ex2_pass_msb           <=     ex2_pass_frac(1)       ;

       ex2_pass_dp( 0 to 52)     <= ex2_pass_frac(0 to 52) ;
       f_fmt_ex2_pass_frac(0 to 52) <= ex2_pass_dp(0 to 52) ; 



  ex2_aembex_g8(0) <= ex2_aembex_g4(0) or ( ex2_aembex_t4(0) and ex2_aembex_g4(1) );
  ex2_aembex_g8(1) <= ex2_aembex_g4(2) ;
  ex2_aembex_t8(0) <=                     ( ex2_aembex_t4(0) and ex2_aembex_t4(1) );
  ex2_aembex_c2    <= ex2_aembex_g8(0) or ( ex2_aembex_t8(0) and ex2_aembex_g8(1) );

  ex2_aembey_g8(0) <= ex2_aembey_g4(0) or ( ex2_aembey_t4(0) and ex2_aembey_g4(1) );
  ex2_aembey_g8(1) <= ex2_aembey_g4(2) ;
  ex2_aembey_t8(0) <=                     ( ex2_aembey_t4(0) and ex2_aembey_t4(1) );
  ex2_aembey_c2    <= ex2_aembey_g8(0) or ( ex2_aembey_t8(0) and ex2_aembey_g8(1) );

  ex2_aembex_res_sgn <=  ex2_aembex_c2 xor     ex2_aembex_sgn ;
  ex2_aembey_res_sgn <=  ex2_aembey_c2 xor     ex2_aembey_sgn ;


       f_fmt_ex2_tdiv_rng_chk <= 
            ( not ex2_aembex_res_sgn ) or 
            (     ex2_aembey_res_sgn )  ; 

       f_fmt_ex2_be_den <=  ex2_be_den ;

       f_fmt_ex2_ae_ge_54     <= ex2_ae_ge_54   ;
       f_fmt_ex2_be_ge_54     <= ex2_be_ge_54   ;
       f_fmt_ex2_be_ge_2      <= ex2_be_ge_2    ;
       f_fmt_ex2_be_ge_2044   <= ex2_be_ge_2044 ;







  ex1_ctl_si       (0 to  8)  <= ex1_ctl_so      (1 to  8)   & f_fmt_si ;
  ex2_pass_si      (0 to 79)  <= ex2_pass_so     (1 to 79)   & ex1_ctl_so    (0); 
  act_si           (0 to  6)  <= act_so          (1 to  6)   & ex2_pass_so   (0); 
  f_fmt_so                    <= act_so  (0); 



end; 
   
   




