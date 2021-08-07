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

 
entity fuq_rnd is 
generic( expand_type  : integer := 2  ); 
port( 
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; 
       act_dis                                   :in   std_ulogic; 
       flush                                     :in   std_ulogic; 
       delay_lclkr                               :in   std_ulogic_vector(5 to 6); 
       mpw1_b                                    :in   std_ulogic_vector(5 to 6); 
       mpw2_b                                    :in   std_ulogic_vector(1 to 1); 
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; 
       nclk                                      :in   clk_logic;

       f_rnd_si                                  :in   std_ulogic                    ;
       f_rnd_so                                  :out  std_ulogic                    ;
       ex3_act_b                                 :in   std_ulogic                    ;

       f_nrm_ex5_res                             :in   std_ulogic_vector(0 to 52)    ;
       f_nrm_ex5_int_lsbs                        :in   std_ulogic_vector(1 to 12)    ;
       f_nrm_ex5_int_sign                        :in   std_ulogic                    ;
       f_nrm_ex5_nrm_sticky_dp                   :in   std_ulogic                    ;
       f_nrm_ex5_nrm_guard_dp                    :in   std_ulogic                    ;
       f_nrm_ex5_nrm_lsb_dp                      :in   std_ulogic                    ;
       f_nrm_ex5_nrm_sticky_sp                   :in   std_ulogic                    ;
       f_nrm_ex5_nrm_guard_sp                    :in   std_ulogic                    ;
       f_nrm_ex5_nrm_lsb_sp                      :in   std_ulogic                    ;
       f_nrm_ex5_exact_zero                      :in   std_ulogic                    ;
       f_tbl_ex5_recip_den                       :in   std_ulogic                    ;

       f_pic_ex5_invert_sign                     :in   std_ulogic                    ;
       f_pic_ex5_en_exact_zero                   :in   std_ulogic                    ;


       f_pic_ex5_k_nan                           :in   std_ulogic                    ;
       f_pic_ex5_k_inf                           :in   std_ulogic                    ;
       f_pic_ex5_k_max                           :in   std_ulogic                    ;
       f_pic_ex5_k_zer                           :in   std_ulogic                    ;
       f_pic_ex5_k_one                           :in   std_ulogic                    ;
       f_pic_ex5_k_int_maxpos                    :in   std_ulogic                    ;
       f_pic_ex5_k_int_maxneg                    :in   std_ulogic                    ;
       f_pic_ex5_k_int_zer                       :in   std_ulogic                    ;

       f_pic_ex4_sel_est_b                       :in   std_ulogic                    ;
       f_tbl_ex5_est_frac                        :in   std_ulogic_vector(0 to 26)    ;

       f_pic_ex4_rnd_ni_b                        :in   std_ulogic                    ;
       f_pic_ex4_rnd_nr_b                        :in   std_ulogic                    ;
       f_pic_ex4_rnd_inf_ok_b                    :in   std_ulogic                    ;
       f_pic_ex5_uc_inc_lsb                      :in   std_ulogic                    ;
       f_pic_ex5_uc_guard                        :in   std_ulogic                    ;
       f_pic_ex5_uc_sticky                       :in   std_ulogic                    ;
       f_pic_ex5_uc_g_v                          :in   std_ulogic                    ;
       f_pic_ex5_uc_s_v                          :in   std_ulogic                    ;
            
       f_pic_ex4_sel_fpscr_b                     :in   std_ulogic                    ;
       f_pic_ex4_to_integer_b                    :in   std_ulogic                    ;
       f_pic_ex4_word_b                          :in   std_ulogic                    ;
       f_pic_ex4_uns_b                           :in   std_ulogic                    ;
       f_pic_ex4_sp_b                            :in   std_ulogic                    ;
       f_pic_ex4_spec_inf_b                      :in   std_ulogic                    ;
       f_pic_ex4_quiet_b                         :in   std_ulogic                    ;
       f_pic_ex4_nj_deno                         :in   std_ulogic                    ;
       f_pic_ex4_unf_en_ue0_b                    :in   std_ulogic                    ;
       f_pic_ex4_unf_en_ue1_b                    :in   std_ulogic                    ;
       f_pic_ex4_ovf_en_oe0_b                    :in   std_ulogic                    ;
       f_pic_ex4_ovf_en_oe1_b                    :in   std_ulogic                    ;
       f_pic_ex5_round_sign                      :in   std_ulogic                    ;
       f_scr_ex5_fpscr_rd_dat_dfp                :in   std_ulogic_vector(0 to 3)     ;
       f_scr_ex5_fpscr_rd_dat                    :in   std_ulogic_vector(0 to 31)    ;

       f_eov_ex5_sel_k_f                         :in   std_ulogic                    ;
       f_eov_ex5_sel_k_e                         :in   std_ulogic                    ;
       f_eov_ex5_sel_kif_f                       :in   std_ulogic                    ;
       f_eov_ex5_sel_kif_e                       :in   std_ulogic                    ;
       f_eov_ex5_ovf_expo                        :in   std_ulogic                    ;
       f_eov_ex5_ovf_if_expo                     :in   std_ulogic                    ;
       f_eov_ex5_unf_expo                        :in   std_ulogic                    ;
       f_eov_ex5_expo_p0                         :in   std_ulogic_vector(1 to 13)    ;
       f_eov_ex5_expo_p1                         :in   std_ulogic_vector(1 to 13)    ;
       f_eov_ex5_expo_p0_ue1oe1                  :in   std_ulogic_vector(3 to 7)     ;
       f_eov_ex5_expo_p1_ue1oe1                  :in   std_ulogic_vector(3 to 7)     ;
       f_pic_ex5_frsp                            :in   std_ulogic                    ;

       f_gst_ex5_logexp_v                        :in  std_ulogic;  
       f_gst_ex5_logexp_sign                     :in  std_ulogic;                   
       f_gst_ex5_logexp_exp                      :in  std_ulogic_vector(1 to 11);  
       f_gst_ex5_logexp_fract                    :in  std_ulogic_vector(0 to 19);

       f_rnd_ex6_res_sign                        :out  std_ulogic                    ;
       f_rnd_ex6_res_expo                        :out  std_ulogic_vector(1 to 13)    ;
       f_rnd_ex6_res_frac                        :out  std_ulogic_vector(0 to 52)    ;

       f_rnd_ex6_flag_up                         :out  std_ulogic                    ;
       f_rnd_ex6_flag_fi                         :out  std_ulogic                    ;
       f_rnd_ex6_flag_ox                         :out  std_ulogic                    ;
       f_rnd_ex6_flag_den                        :out  std_ulogic                    ;
       f_rnd_ex6_flag_sgn                        :out  std_ulogic                    ;
       f_rnd_ex6_flag_inf                        :out  std_ulogic                    ;
       f_rnd_ex6_flag_zer                        :out  std_ulogic                    ;
       f_rnd_ex6_flag_ux                         :out  std_ulogic                    ;

       f_mad_ex6_uc_sign                         :out  std_ulogic ;
       f_mad_ex6_uc_zero                         :out  std_ulogic 

); 
 
 

end fuq_rnd; 
 
 
architecture fuq_rnd of fuq_rnd is 
 
    constant tiup  :std_ulogic := '1';
    constant tidn  :std_ulogic := '0';
 
    signal sg_0                                  :std_ulogic                   ;
    signal thold_0_b, thold_0, forcee               :std_ulogic                   ;
    signal ex4_act                                 :std_ulogic                   ;
    signal ex3_act                                 :std_ulogic                   ;
    signal ex5_act                                 :std_ulogic                   ;
    signal act_spare_unused                        :std_ulogic_vector(0 to 2)    ;
    signal flag_spare_unused                       :std_ulogic                   ;
    signal act_so                                  :std_ulogic_vector(0 to 4)    ;
    signal act_si                                  :std_ulogic_vector(0 to 4)    ;
    signal ex5_ctl_so                              :std_ulogic_vector(0 to 15)   ;
    signal ex5_ctl_si                              :std_ulogic_vector(0 to 15)   ;
    signal ex6_frac_so                             :std_ulogic_vector(0 to 52)   ;
    signal ex6_frac_si                             :std_ulogic_vector(0 to 52)   ;
    signal ex6_expo_so                             :std_ulogic_vector(0 to 13)   ;
    signal ex6_expo_si                             :std_ulogic_vector(0 to 13)   ;
    signal ex6_flag_so                             :std_ulogic_vector(0 to 9)    ;
    signal ex6_flag_si                             :std_ulogic_vector(0 to 9)    ;
    signal ex5_quiet                               :std_ulogic                   ;
    signal ex5_rnd_ni                              :std_ulogic                   ;
    signal ex5_rnd_nr                              :std_ulogic                   ;
    signal ex5_rnd_inf_ok                          :std_ulogic                   ;
    signal ex5_rnd_frc_up                          :std_ulogic                   ;
    signal ex5_sel_fpscr                           :std_ulogic                   ;
    signal ex5_to_integer                          :std_ulogic                   ;
    signal ex5_word                                :std_ulogic                   ;
    signal ex5_sp                                  :std_ulogic                   ;
    signal ex5_spec_inf                            :std_ulogic                   ;
    signal ex5_flag_den                            :std_ulogic                   ;
    signal ex5_flag_inf                            :std_ulogic                   ;
    signal ex5_flag_zer                            :std_ulogic                   ;
    signal ex5_flag_ux                             :std_ulogic                   ;
    signal ex5_flag_up                             :std_ulogic                   ;
    signal ex5_flag_fi                             :std_ulogic                   ;
    signal ex5_flag_ox                             :std_ulogic                   ;
    signal ex5_all0_lo                             :std_ulogic                   ;
    signal ex5_all0_sp                             :std_ulogic                   ;
    signal ex5_all0                                :std_ulogic                   ;
    signal ex5_all1                                :std_ulogic                   ;
    signal ex5_frac_c                              :std_ulogic_vector(0 to 52)   ;
    signal ex5_frac_p1                             :std_ulogic_vector(0 to 52)   ;
    signal ex5_frac_p0                             :std_ulogic_vector(0 to 52)   ;
    signal ex5_frac_px                             :std_ulogic_vector(0 to 52)   ;
    signal ex5_frac_k                              :std_ulogic_vector(0 to 52)   ;
    signal ex5_frac_misc                           :std_ulogic_vector(0 to 52);
    signal ex5_to_int_data                         :std_ulogic_vector(0 to 63);
    signal ex5_to_int_imp                          :std_ulogic ;
    signal ex5_p0_sel_dflt                         :std_ulogic ;

    signal ex5_up                                  :std_ulogic                   ;
    signal ex5_up_sp                               :std_ulogic                   ;
    signal ex5_up_dp                               :std_ulogic                   ;
    signal ex5_res_frac                            :std_ulogic_vector(0 to 52)   ;
    signal ex5_res_sign                            :std_ulogic                   ;
    signal ex5_res_expo                            :std_ulogic_vector(1 to 13)   ;
    signal ex6_res_frac                            :std_ulogic_vector(0 to 52)   ;
    signal ex6_res_sign                            :std_ulogic                   ;
    signal ex6_res_expo                            :std_ulogic_vector(1 to 13)   ;
    signal ex6_flag_sgn                            :std_ulogic                   ;
    signal ex6_flag_den                            :std_ulogic                   ;
    signal ex6_flag_inf                            :std_ulogic                   ;
    signal ex6_flag_zer                            :std_ulogic                   ;
    signal ex6_flag_ux                             :std_ulogic                   ;
    signal ex6_flag_up                             :std_ulogic                   ;
    signal ex6_flag_fi                             :std_ulogic                   ;
    signal ex6_flag_ox                             :std_ulogic                   ;

    signal ex5_sel_up          :std_ulogic ;
    signal ex5_sel_up_b        :std_ulogic ;
    signal ex5_sel_up_dp       :std_ulogic ;
    signal ex5_sel_up_dp_b     :std_ulogic ;
    signal ex5_gox             :std_ulogic ;

    signal ex5_sgn_result_fp     :std_ulogic;
    signal ex5_res_sign_prez     :std_ulogic;
    signal ex5_exact_sgn_rst     :std_ulogic;
    signal ex5_exact_sgn_set     :std_ulogic;
    signal ex5_res_sel_k_f       :std_ulogic;
    signal ex5_res_sel_p1_e      :std_ulogic;
    signal ex5_res_clip_e        :std_ulogic;
    signal ex5_expo_sel_k        :std_ulogic;
    signal ex5_expo_sel_k_both   :std_ulogic;
    signal ex5_expo_p0_sel_k     :std_ulogic;
    signal ex5_expo_p0_sel_int   :std_ulogic;
    signal ex5_expo_p0_sel_gst   :std_ulogic;
    signal ex5_expo_p0_sel_dflt  :std_ulogic;
    signal ex5_expo_p1_sel_k     :std_ulogic;
    signal ex5_expo_p1_sel_dflt  :std_ulogic;
    signal ex5_sel_p0_joke       :std_ulogic;
    signal ex5_sel_p1_joke       :std_ulogic;
    signal ex5_expo_k            :std_ulogic_vector(1 to 13);
    signal ex5_expo_p0k          :std_ulogic_vector(1 to 13);
    signal ex5_expo_p1k          :std_ulogic_vector(1 to 13);
    signal ex5_expo_p0kx         :std_ulogic_vector(1 to 13);
    signal ex5_expo_p1kx         :std_ulogic_vector(1 to 13);
    signal ex5_unf_en_ue0        :std_ulogic;
    signal ex5_unf_en_ue1        :std_ulogic;
    signal ex5_ovf_en_oe0        :std_ulogic;
    signal ex5_ovf_en_oe1        :std_ulogic;
    signal ex5_ov_oe0            :std_ulogic;
    signal ex5_k_zero            :std_ulogic;
    signal ex5_sel_est           :std_ulogic;
    signal ex5_k_inf_nan_maxdp       :std_ulogic;
    signal ex5_k_inf_nan_max         :std_ulogic;
    signal ex5_k_inf_nan_zer         :std_ulogic;
    signal ex5_k_zer_sp              :std_ulogic;
    signal ex5_k_notzer              :std_ulogic;
    signal ex5_k_max_intmax_nan      :std_ulogic;
    signal ex5_k_max_intmax          :std_ulogic;
    signal ex5_k_max_intsgn          :std_ulogic;
    signal ex5_k_max_intmax_nsp      :std_ulogic;
    signal ex5_pwr4_spec_frsp        :std_ulogic;
    signal ex5_exact_zero_rnd :std_ulogic;
    signal ex5_rnd_ni_adj :std_ulogic;
    signal ex5_nrm_res_b :std_ulogic_vector(0 to 52);
    signal ex5_all0_gp2  :std_ulogic_vector(0 to 27);
    signal ex5_all0_gp4  :std_ulogic_vector(0 to 13);
    signal ex5_all0_gp8  :std_ulogic_vector(0 to 6);
    signal ex5_all0_gp16 :std_ulogic_vector(0 to 3);

    signal ex5_frac_c_gp2 :std_ulogic_vector(0 to 52);
    signal ex5_frac_c_gp4 :std_ulogic_vector(0 to 52);
    signal ex5_frac_c_gp8 :std_ulogic_vector(0 to 52);
    signal ex5_frac_g16 :std_ulogic_vector(0 to 6);
    signal ex5_frac_g32 :std_ulogic_vector(0 to 6);
    signal ex5_frac_g   :std_ulogic_vector(1 to 6);
 signal ex4_quiet           :std_ulogic;
 signal ex4_rnd_ni          :std_ulogic;
 signal ex4_rnd_nr          :std_ulogic;
 signal ex4_rnd_inf_ok      :std_ulogic;
 signal ex4_sel_fpscr       :std_ulogic;
 signal ex4_to_integer      :std_ulogic;
 signal ex4_word            :std_ulogic;
 signal ex4_uns             :std_ulogic;
 signal ex5_uns             :std_ulogic;
 signal ex4_sp              :std_ulogic;
 signal ex4_spec_inf        :std_ulogic;
 signal ex4_nj_deno         :std_ulogic;
 signal ex4_unf_en_ue0      :std_ulogic;
 signal ex4_unf_en_ue1      :std_ulogic;
 signal ex4_ovf_en_oe0      :std_ulogic;
 signal ex4_ovf_en_oe1      :std_ulogic;
 signal ex4_sel_est         :std_ulogic;
 signal ex5_guard_dp, ex5_guard_sp, ex5_sticky_dp, ex5_sticky_sp :std_ulogic;
 signal unused :std_ulogic;
 signal ex5_nj_deno, ex6_nj_deno   :std_ulogic;
 signal ex5_clip_deno :std_ulogic;
 signal ex5_est_log_pow :std_ulogic ; 


begin 


 unused <= ex5_frac_c(0)  or
           f_nrm_ex5_int_lsbs(1) ; 

     
     
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

   

    ex3_act <= not ex3_act_b ;
 
    act_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(5)  ,
        mpw1_b           => mpw1_b(5)       ,
        mpw2_b           => mpw2_b(1)       ,
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
         din(2)             => ex3_act,
         din(3)             => ex4_act,
         din(4)             => act_spare_unused(2),
        dout(0)             => act_spare_unused(0),
        dout(1)             => act_spare_unused(1),
        dout(2)             => ex4_act,
        dout(3)             => ex5_act,
        dout(4)             => act_spare_unused(2) );



        ex4_quiet            <= not f_pic_ex4_quiet_b            ;
        ex4_rnd_ni           <= not f_pic_ex4_rnd_ni_b           ;
        ex4_rnd_nr           <= not f_pic_ex4_rnd_nr_b           ;
        ex4_rnd_inf_ok       <= not f_pic_ex4_rnd_inf_ok_b       ;
        ex4_sel_fpscr        <= not f_pic_ex4_sel_fpscr_b        ;
        ex4_to_integer       <= not f_pic_ex4_to_integer_b       ;
        ex4_word             <= not f_pic_ex4_word_b             ;
        ex4_uns              <= not f_pic_ex4_uns_b              ;
        ex4_sp               <= not f_pic_ex4_sp_b               ;
        ex4_spec_inf         <= not f_pic_ex4_spec_inf_b         ;
        ex4_nj_deno          <=     f_pic_ex4_nj_deno            ;
        ex4_unf_en_ue0       <= not f_pic_ex4_unf_en_ue0_b       ;
        ex4_unf_en_ue1       <= not f_pic_ex4_unf_en_ue1_b       ;
        ex4_ovf_en_oe0       <= not f_pic_ex4_ovf_en_oe0_b       ;
        ex4_ovf_en_oe1       <= not f_pic_ex4_ovf_en_oe1_b       ;
        ex4_sel_est          <= not f_pic_ex4_sel_est_b          ;


    ex5_ctl_lat:  tri_rlmreg_p generic map (width=> 16, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(5)  ,
        mpw1_b           => mpw1_b(5)       ,
        mpw2_b           => mpw2_b(1)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex4_act, 
        scout            => ex5_ctl_so   ,                     
        scin             => ex5_ctl_si   ,                   
         din( 0)            => ex4_quiet            ,
         din( 1)            => ex4_rnd_ni           ,
         din( 2)            => ex4_rnd_nr           ,
         din( 3)            => ex4_rnd_inf_ok       ,
         din( 4)            => ex4_sel_fpscr        ,
         din( 5)            => ex4_to_integer       ,
         din( 6)            => ex4_word             ,
         din( 7)            => ex4_sp               ,
         din( 8)            => ex4_spec_inf         ,
         din( 9)            => ex4_nj_deno          ,
         din(10)            => ex4_unf_en_ue0       ,
         din(11)            => ex4_unf_en_ue1       ,
         din(12)            => ex4_ovf_en_oe0       ,
         din(13)            => ex4_ovf_en_oe1       ,
         din(14)            => ex4_sel_est          ,
         din(15)            => ex4_uns              ,
        dout( 0)            => ex5_quiet              ,
        dout( 1)            => ex5_rnd_ni             ,
        dout( 2)            => ex5_rnd_nr             ,
        dout( 3)            => ex5_rnd_inf_ok         ,
        dout( 4)            => ex5_sel_fpscr          ,
        dout( 5)            => ex5_to_integer         ,
        dout( 6)            => ex5_word               ,
        dout( 7)            => ex5_sp                 ,
        dout( 8)            => ex5_spec_inf           ,
        dout( 9)            => ex5_nj_deno            ,
        dout(10)            => ex5_unf_en_ue0    ,
        dout(11)            => ex5_unf_en_ue1    ,
        dout(12)            => ex5_ovf_en_oe0    ,
        dout(13)            => ex5_ovf_en_oe1    ,
        dout(14)            => ex5_sel_est       ,
        dout(15)            => ex5_uns          );

        ex5_rnd_frc_up       <=     f_pic_ex5_uc_inc_lsb ;

 



    ex5_guard_dp  <= ( f_nrm_ex5_nrm_guard_dp and not f_pic_ex5_uc_g_v ) or 
                     ( f_pic_ex5_uc_guard     and     f_pic_ex5_uc_g_v ) ;

    ex5_guard_sp  <= ( f_nrm_ex5_nrm_guard_sp and not f_pic_ex5_uc_g_v ) or 
                     ( f_pic_ex5_uc_guard     and     f_pic_ex5_uc_g_v ) ;

    ex5_sticky_dp <= ( f_nrm_ex5_nrm_sticky_dp ) or 
                     ( f_pic_ex5_uc_sticky     and     f_pic_ex5_uc_s_v ) ;

    ex5_sticky_sp <= ( f_nrm_ex5_nrm_sticky_sp ) or 
                     ( f_pic_ex5_uc_sticky     and     f_pic_ex5_uc_s_v ) ;



    ex5_up_sp <=
         ( ex5_rnd_frc_up                                           ) or 
         ( ex5_rnd_nr     and ex5_guard_sp and ex5_sticky_sp        ) or 
         ( ex5_rnd_nr     and ex5_guard_sp and f_nrm_ex5_nrm_lsb_sp ) or 
         ( ex5_rnd_inf_ok and ex5_guard_sp                          ) or 
         ( ex5_rnd_inf_ok and                  ex5_sticky_sp        ) ;

    ex5_up_dp <=
         ( ex5_rnd_frc_up                                            ) or 
         ( ex5_rnd_nr     and ex5_guard_dp and ex5_sticky_dp        ) or 
         ( ex5_rnd_nr     and ex5_guard_dp and f_nrm_ex5_nrm_lsb_dp ) or 
         ( ex5_rnd_inf_ok and ex5_guard_dp                          ) or 
         ( ex5_rnd_inf_ok and                  ex5_sticky_dp        ) ;

    ex5_up <=
         (ex5_up_sp and     ex5_sp) or
         (ex5_up_dp and not ex5_sp);

    ex5_sel_up      <=     ex5_up;
    ex5_sel_up_b    <= not ex5_up;
    ex5_sel_up_dp   <=     ex5_up_dp and not ex5_sp;
    ex5_sel_up_dp_b <= not ex5_up_dp and not ex5_sp;

    ex5_gox <=
         (    ex5_sp and ex5_guard_sp  ) or
         (    ex5_sp and ex5_sticky_sp ) or
         (not ex5_sp and ex5_guard_dp  ) or
         (not ex5_sp and ex5_sticky_dp ) ;


    ex5_nrm_res_b(0 to 52) <= not f_nrm_ex5_res(0 to 52);

    ex5_all0_gp2( 0) <= ex5_nrm_res_b( 0) and ex5_nrm_res_b( 1);
    ex5_all0_gp2( 1) <= ex5_nrm_res_b( 2) and ex5_nrm_res_b( 3);
    ex5_all0_gp2( 2) <= ex5_nrm_res_b( 4) and ex5_nrm_res_b( 5);
    ex5_all0_gp2( 3) <= ex5_nrm_res_b( 6) and ex5_nrm_res_b( 7);
    ex5_all0_gp2( 4) <= ex5_nrm_res_b( 8) and ex5_nrm_res_b( 9);
    ex5_all0_gp2( 5) <= ex5_nrm_res_b(10) and ex5_nrm_res_b(11);
    ex5_all0_gp2( 6) <= ex5_nrm_res_b(12) and ex5_nrm_res_b(13);
    ex5_all0_gp2( 7) <= ex5_nrm_res_b(14) and ex5_nrm_res_b(15);
    ex5_all0_gp2( 8) <= ex5_nrm_res_b(16) and ex5_nrm_res_b(17);
    ex5_all0_gp2( 9) <= ex5_nrm_res_b(18) and ex5_nrm_res_b(19);
    ex5_all0_gp2(10) <= ex5_nrm_res_b(20) and ex5_nrm_res_b(21);
    ex5_all0_gp2(11) <= ex5_nrm_res_b(22) and ex5_nrm_res_b(23); 
    ex5_all0_gp2(12) <= ex5_nrm_res_b(24) and ex5_nrm_res_b(25);
    ex5_all0_gp2(13) <= ex5_nrm_res_b(26) and ex5_nrm_res_b(27);
    ex5_all0_gp2(14) <= ex5_nrm_res_b(28) and ex5_nrm_res_b(29);
    ex5_all0_gp2(15) <= ex5_nrm_res_b(30) and ex5_nrm_res_b(31);
    ex5_all0_gp2(16) <= ex5_nrm_res_b(32) and ex5_nrm_res_b(33);
    ex5_all0_gp2(17) <= ex5_nrm_res_b(34) and ex5_nrm_res_b(35);
    ex5_all0_gp2(18) <= ex5_nrm_res_b(36) and ex5_nrm_res_b(37);
    ex5_all0_gp2(19) <= ex5_nrm_res_b(38) and ex5_nrm_res_b(39);
    ex5_all0_gp2(20) <= ex5_nrm_res_b(40) and ex5_nrm_res_b(41);
    ex5_all0_gp2(21) <= ex5_nrm_res_b(40) and ex5_nrm_res_b(41);
    ex5_all0_gp2(22) <= ex5_nrm_res_b(42) and ex5_nrm_res_b(43);
    ex5_all0_gp2(23) <= ex5_nrm_res_b(44) and ex5_nrm_res_b(45);
    ex5_all0_gp2(24) <= ex5_nrm_res_b(46) and ex5_nrm_res_b(47);
    ex5_all0_gp2(25) <= ex5_nrm_res_b(48) and ex5_nrm_res_b(49);
    ex5_all0_gp2(26) <= ex5_nrm_res_b(50) and ex5_nrm_res_b(51);
    ex5_all0_gp2(27) <= ex5_nrm_res_b(52) ;

    ex5_all0_gp4( 0)  <= ex5_all0_gp2( 0) and ex5_all0_gp2( 1);
    ex5_all0_gp4( 1)  <= ex5_all0_gp2( 2) and ex5_all0_gp2( 3);
    ex5_all0_gp4( 2)  <= ex5_all0_gp2( 4) and ex5_all0_gp2( 5);
    ex5_all0_gp4( 3)  <= ex5_all0_gp2( 6) and ex5_all0_gp2( 7);
    ex5_all0_gp4( 4)  <= ex5_all0_gp2( 8) and ex5_all0_gp2( 9);
    ex5_all0_gp4( 5)  <= ex5_all0_gp2(10) and ex5_all0_gp2(11); 
    ex5_all0_gp4( 6)  <= ex5_all0_gp2(12) and ex5_all0_gp2(13);
    ex5_all0_gp4( 7)  <= ex5_all0_gp2(14) and ex5_all0_gp2(15);
    ex5_all0_gp4( 8)  <= ex5_all0_gp2(16) and ex5_all0_gp2(17);
    ex5_all0_gp4( 9)  <= ex5_all0_gp2(18) and ex5_all0_gp2(19);
    ex5_all0_gp4(10)  <= ex5_all0_gp2(20) and ex5_all0_gp2(21);
    ex5_all0_gp4(11)  <= ex5_all0_gp2(22) and ex5_all0_gp2(23);
    ex5_all0_gp4(12)  <= ex5_all0_gp2(24) and ex5_all0_gp2(25);
    ex5_all0_gp4(13)  <= ex5_all0_gp2(26) and ex5_all0_gp2(27);

    ex5_all0_gp8( 0)  <= ex5_all0_gp4( 0) and ex5_all0_gp4( 1);
    ex5_all0_gp8( 1)  <= ex5_all0_gp4( 2) and ex5_all0_gp4( 3);
    ex5_all0_gp8( 2)  <= ex5_all0_gp4( 4) and ex5_all0_gp4( 5);
    ex5_all0_gp8( 3)  <= ex5_all0_gp4( 6) and ex5_all0_gp4( 7);
    ex5_all0_gp8( 4)  <= ex5_all0_gp4( 8) and ex5_all0_gp4( 9);
    ex5_all0_gp8( 5)  <= ex5_all0_gp4(10) and ex5_all0_gp4(11); 
    ex5_all0_gp8( 6)  <= ex5_all0_gp4(12) and ex5_all0_gp4(13);


    ex5_all0_gp16( 0)  <= ex5_all0_gp8( 0) and ex5_all0_gp8( 1);
    ex5_all0_gp16( 1)  <= ex5_all0_gp8( 2) ; 
    ex5_all0_gp16( 2)  <= ex5_all0_gp8( 3) and ex5_all0_gp8( 4);
    ex5_all0_gp16( 3)  <= ex5_all0_gp8( 5) and ex5_all0_gp8( 6);

    ex5_all0_sp        <= ex5_all0_gp16( 0) and ex5_all0_gp16( 1);
    ex5_all0_lo        <= ex5_all0_gp16( 2) and ex5_all0_gp16( 3); 


    ex5_all0 <= ex5_all0_sp and (ex5_sp or ex5_all0_lo );




    ex5_frac_c_gp2( 0)  <= f_nrm_ex5_res( 0) and  f_nrm_ex5_res( 1);
    ex5_frac_c_gp2( 1)  <= f_nrm_ex5_res( 1) and  f_nrm_ex5_res( 2);
    ex5_frac_c_gp2( 2)  <= f_nrm_ex5_res( 2) and  f_nrm_ex5_res( 3);
    ex5_frac_c_gp2( 3)  <= f_nrm_ex5_res( 3) and  f_nrm_ex5_res( 4);
    ex5_frac_c_gp2( 4)  <= f_nrm_ex5_res( 4) and  f_nrm_ex5_res( 5);
    ex5_frac_c_gp2( 5)  <= f_nrm_ex5_res( 5) and  f_nrm_ex5_res( 6);
    ex5_frac_c_gp2( 6)  <= f_nrm_ex5_res( 6) and  f_nrm_ex5_res( 7);
    ex5_frac_c_gp2( 7)  <= f_nrm_ex5_res( 7) ;
    ex5_frac_c_gp2( 8)  <= f_nrm_ex5_res( 8) and  f_nrm_ex5_res( 9);
    ex5_frac_c_gp2( 9)  <= f_nrm_ex5_res( 9) and  f_nrm_ex5_res(10);
    ex5_frac_c_gp2(10)  <= f_nrm_ex5_res(10) and  f_nrm_ex5_res(11);
    ex5_frac_c_gp2(11)  <= f_nrm_ex5_res(11) and  f_nrm_ex5_res(12);
    ex5_frac_c_gp2(12)  <= f_nrm_ex5_res(12) and  f_nrm_ex5_res(13);
    ex5_frac_c_gp2(13)  <= f_nrm_ex5_res(13) and  f_nrm_ex5_res(14);
    ex5_frac_c_gp2(14)  <= f_nrm_ex5_res(14) and  f_nrm_ex5_res(15);
    ex5_frac_c_gp2(15)  <= f_nrm_ex5_res(15) ;
    ex5_frac_c_gp2(16)  <= f_nrm_ex5_res(16) and  f_nrm_ex5_res(17);
    ex5_frac_c_gp2(17)  <= f_nrm_ex5_res(17) and  f_nrm_ex5_res(18);
    ex5_frac_c_gp2(18)  <= f_nrm_ex5_res(18) and  f_nrm_ex5_res(19);
    ex5_frac_c_gp2(19)  <= f_nrm_ex5_res(19) and  f_nrm_ex5_res(20);
    ex5_frac_c_gp2(20)  <= f_nrm_ex5_res(20) and  f_nrm_ex5_res(21);
    ex5_frac_c_gp2(21)  <= f_nrm_ex5_res(21) and  f_nrm_ex5_res(22);
    ex5_frac_c_gp2(22)  <= f_nrm_ex5_res(22) and  f_nrm_ex5_res(23);
    ex5_frac_c_gp2(23)  <= f_nrm_ex5_res(23) ;
    ex5_frac_c_gp2(24)  <= f_nrm_ex5_res(24) and  f_nrm_ex5_res(25);
    ex5_frac_c_gp2(25)  <= f_nrm_ex5_res(25) and  f_nrm_ex5_res(26);
    ex5_frac_c_gp2(26)  <= f_nrm_ex5_res(26) and  f_nrm_ex5_res(27);
    ex5_frac_c_gp2(27)  <= f_nrm_ex5_res(27) and  f_nrm_ex5_res(28);
    ex5_frac_c_gp2(28)  <= f_nrm_ex5_res(28) and  f_nrm_ex5_res(29);
    ex5_frac_c_gp2(29)  <= f_nrm_ex5_res(29) and  f_nrm_ex5_res(30);
    ex5_frac_c_gp2(30)  <= f_nrm_ex5_res(30) and  f_nrm_ex5_res(31);
    ex5_frac_c_gp2(31)  <= f_nrm_ex5_res(31) ;
    ex5_frac_c_gp2(32)  <= f_nrm_ex5_res(32) and  f_nrm_ex5_res(33);
    ex5_frac_c_gp2(33)  <= f_nrm_ex5_res(33) and  f_nrm_ex5_res(34);
    ex5_frac_c_gp2(34)  <= f_nrm_ex5_res(34) and  f_nrm_ex5_res(35);
    ex5_frac_c_gp2(35)  <= f_nrm_ex5_res(35) and  f_nrm_ex5_res(36);
    ex5_frac_c_gp2(36)  <= f_nrm_ex5_res(36) and  f_nrm_ex5_res(37);
    ex5_frac_c_gp2(37)  <= f_nrm_ex5_res(37) and  f_nrm_ex5_res(38);
    ex5_frac_c_gp2(38)  <= f_nrm_ex5_res(38) and  f_nrm_ex5_res(39);
    ex5_frac_c_gp2(39)  <= f_nrm_ex5_res(39) ;
    ex5_frac_c_gp2(40)  <= f_nrm_ex5_res(40) and  f_nrm_ex5_res(41);
    ex5_frac_c_gp2(41)  <= f_nrm_ex5_res(41) and  f_nrm_ex5_res(42);
    ex5_frac_c_gp2(42)  <= f_nrm_ex5_res(42) and  f_nrm_ex5_res(43);
    ex5_frac_c_gp2(43)  <= f_nrm_ex5_res(43) and  f_nrm_ex5_res(44);
    ex5_frac_c_gp2(44)  <= f_nrm_ex5_res(44) and  f_nrm_ex5_res(45);
    ex5_frac_c_gp2(45)  <= f_nrm_ex5_res(45) and  f_nrm_ex5_res(46);
    ex5_frac_c_gp2(46)  <= f_nrm_ex5_res(46) and  f_nrm_ex5_res(47);
    ex5_frac_c_gp2(47)  <= f_nrm_ex5_res(47) ;
    ex5_frac_c_gp2(48)  <= f_nrm_ex5_res(48) and  f_nrm_ex5_res(49);
    ex5_frac_c_gp2(49)  <= f_nrm_ex5_res(49) and  f_nrm_ex5_res(50);
    ex5_frac_c_gp2(50)  <= f_nrm_ex5_res(50) and  f_nrm_ex5_res(51);
    ex5_frac_c_gp2(51)  <= f_nrm_ex5_res(51) and  f_nrm_ex5_res(52);
    ex5_frac_c_gp2(52)  <= f_nrm_ex5_res(52) ;

    ex5_frac_c_gp4( 0)  <= ex5_frac_c_gp2( 0) and  ex5_frac_c_gp2( 2);
    ex5_frac_c_gp4( 1)  <= ex5_frac_c_gp2( 1) and  ex5_frac_c_gp2( 3);
    ex5_frac_c_gp4( 2)  <= ex5_frac_c_gp2( 2) and  ex5_frac_c_gp2( 4);
    ex5_frac_c_gp4( 3)  <= ex5_frac_c_gp2( 3) and  ex5_frac_c_gp2( 5);
    ex5_frac_c_gp4( 4)  <= ex5_frac_c_gp2( 4) and  ex5_frac_c_gp2( 6);
    ex5_frac_c_gp4( 5)  <= ex5_frac_c_gp2( 5) and  ex5_frac_c_gp2( 7);
    ex5_frac_c_gp4( 6)  <= ex5_frac_c_gp2( 6) ;
    ex5_frac_c_gp4( 7)  <= ex5_frac_c_gp2( 7) ;
    ex5_frac_c_gp4( 8)  <= ex5_frac_c_gp2( 8) and  ex5_frac_c_gp2(10);
    ex5_frac_c_gp4( 9)  <= ex5_frac_c_gp2( 9) and  ex5_frac_c_gp2(11);
    ex5_frac_c_gp4(10)  <= ex5_frac_c_gp2(10) and  ex5_frac_c_gp2(12);
    ex5_frac_c_gp4(11)  <= ex5_frac_c_gp2(11) and  ex5_frac_c_gp2(13);
    ex5_frac_c_gp4(12)  <= ex5_frac_c_gp2(12) and  ex5_frac_c_gp2(14);
    ex5_frac_c_gp4(13)  <= ex5_frac_c_gp2(13) and  ex5_frac_c_gp2(15);
    ex5_frac_c_gp4(14)  <= ex5_frac_c_gp2(14) ;
    ex5_frac_c_gp4(15)  <= ex5_frac_c_gp2(15) ;
    ex5_frac_c_gp4(16)  <= ex5_frac_c_gp2(16) and  ex5_frac_c_gp2(18);
    ex5_frac_c_gp4(17)  <= ex5_frac_c_gp2(17) and  ex5_frac_c_gp2(19);
    ex5_frac_c_gp4(18)  <= ex5_frac_c_gp2(18) and  ex5_frac_c_gp2(20);
    ex5_frac_c_gp4(19)  <= ex5_frac_c_gp2(19) and  ex5_frac_c_gp2(21);
    ex5_frac_c_gp4(20)  <= ex5_frac_c_gp2(20) and  ex5_frac_c_gp2(22);
    ex5_frac_c_gp4(21)  <= ex5_frac_c_gp2(21) and  ex5_frac_c_gp2(23);
    ex5_frac_c_gp4(22)  <= ex5_frac_c_gp2(22) ;
    ex5_frac_c_gp4(23)  <= ex5_frac_c_gp2(23) ;
    ex5_frac_c_gp4(24)  <= ex5_frac_c_gp2(24) and  ex5_frac_c_gp2(26);
    ex5_frac_c_gp4(25)  <= ex5_frac_c_gp2(25) and  ex5_frac_c_gp2(27);
    ex5_frac_c_gp4(26)  <= ex5_frac_c_gp2(26) and  ex5_frac_c_gp2(28);
    ex5_frac_c_gp4(27)  <= ex5_frac_c_gp2(27) and  ex5_frac_c_gp2(29);
    ex5_frac_c_gp4(28)  <= ex5_frac_c_gp2(28) and  ex5_frac_c_gp2(30);
    ex5_frac_c_gp4(29)  <= ex5_frac_c_gp2(29) and  ex5_frac_c_gp2(31);
    ex5_frac_c_gp4(30)  <= ex5_frac_c_gp2(30) ;
    ex5_frac_c_gp4(31)  <= ex5_frac_c_gp2(31) ;
    ex5_frac_c_gp4(32)  <= ex5_frac_c_gp2(32) and  ex5_frac_c_gp2(34);
    ex5_frac_c_gp4(33)  <= ex5_frac_c_gp2(33) and  ex5_frac_c_gp2(35);
    ex5_frac_c_gp4(34)  <= ex5_frac_c_gp2(34) and  ex5_frac_c_gp2(36);
    ex5_frac_c_gp4(35)  <= ex5_frac_c_gp2(35) and  ex5_frac_c_gp2(37);
    ex5_frac_c_gp4(36)  <= ex5_frac_c_gp2(36) and  ex5_frac_c_gp2(38);
    ex5_frac_c_gp4(37)  <= ex5_frac_c_gp2(37) and  ex5_frac_c_gp2(39);
    ex5_frac_c_gp4(38)  <= ex5_frac_c_gp2(38) ;
    ex5_frac_c_gp4(39)  <= ex5_frac_c_gp2(39) ;
    ex5_frac_c_gp4(40)  <= ex5_frac_c_gp2(40) and  ex5_frac_c_gp2(42);
    ex5_frac_c_gp4(41)  <= ex5_frac_c_gp2(41) and  ex5_frac_c_gp2(43);
    ex5_frac_c_gp4(42)  <= ex5_frac_c_gp2(42) and  ex5_frac_c_gp2(44);
    ex5_frac_c_gp4(43)  <= ex5_frac_c_gp2(43) and  ex5_frac_c_gp2(45);
    ex5_frac_c_gp4(44)  <= ex5_frac_c_gp2(44) and  ex5_frac_c_gp2(46);
    ex5_frac_c_gp4(45)  <= ex5_frac_c_gp2(45) and  ex5_frac_c_gp2(47);
    ex5_frac_c_gp4(46)  <= ex5_frac_c_gp2(46) ;
    ex5_frac_c_gp4(47)  <= ex5_frac_c_gp2(47) ;
    ex5_frac_c_gp4(48)  <= ex5_frac_c_gp2(48) and  ex5_frac_c_gp2(50);
    ex5_frac_c_gp4(49)  <= ex5_frac_c_gp2(49) and  ex5_frac_c_gp2(51);
    ex5_frac_c_gp4(50)  <= ex5_frac_c_gp2(50) and  ex5_frac_c_gp2(52);
    ex5_frac_c_gp4(51)  <= ex5_frac_c_gp2(51) ;
    ex5_frac_c_gp4(52)  <= ex5_frac_c_gp2(52) ;


    ex5_frac_c_gp8( 0)  <= ex5_frac_c_gp4( 0) and  ex5_frac_c_gp4( 4);
    ex5_frac_c_gp8( 1)  <= ex5_frac_c_gp4( 1) and  ex5_frac_c_gp4( 5);
    ex5_frac_c_gp8( 2)  <= ex5_frac_c_gp4( 2) and  ex5_frac_c_gp4( 6);
    ex5_frac_c_gp8( 3)  <= ex5_frac_c_gp4( 3) and  ex5_frac_c_gp4( 7);
    ex5_frac_c_gp8( 4)  <= ex5_frac_c_gp4( 4) ;
    ex5_frac_c_gp8( 5)  <= ex5_frac_c_gp4( 5) ;
    ex5_frac_c_gp8( 6)  <= ex5_frac_c_gp4( 6) ;
    ex5_frac_c_gp8( 7)  <= ex5_frac_c_gp4( 7) ;
    ex5_frac_c_gp8( 8)  <= ex5_frac_c_gp4( 8) and  ex5_frac_c_gp4(12);
    ex5_frac_c_gp8( 9)  <= ex5_frac_c_gp4( 9) and  ex5_frac_c_gp4(13);
    ex5_frac_c_gp8(10)  <= ex5_frac_c_gp4(10) and  ex5_frac_c_gp4(14);
    ex5_frac_c_gp8(11)  <= ex5_frac_c_gp4(11) and  ex5_frac_c_gp4(15);
    ex5_frac_c_gp8(12)  <= ex5_frac_c_gp4(12) ;
    ex5_frac_c_gp8(13)  <= ex5_frac_c_gp4(13) ;
    ex5_frac_c_gp8(14)  <= ex5_frac_c_gp4(14) ;
    ex5_frac_c_gp8(15)  <= ex5_frac_c_gp4(15) ;
    ex5_frac_c_gp8(16)  <= ex5_frac_c_gp4(16) and  ex5_frac_c_gp4(20);
    ex5_frac_c_gp8(17)  <= ex5_frac_c_gp4(17) and  ex5_frac_c_gp4(21);
    ex5_frac_c_gp8(18)  <= ex5_frac_c_gp4(18) and  ex5_frac_c_gp4(22);
    ex5_frac_c_gp8(19)  <= ex5_frac_c_gp4(19) and  ex5_frac_c_gp4(23);
    ex5_frac_c_gp8(20)  <= ex5_frac_c_gp4(20) ;
    ex5_frac_c_gp8(21)  <= ex5_frac_c_gp4(21) ;
    ex5_frac_c_gp8(22)  <= ex5_frac_c_gp4(22) ;
    ex5_frac_c_gp8(23)  <= ex5_frac_c_gp4(23) ;
    ex5_frac_c_gp8(24)  <= ex5_frac_c_gp4(24) and  ex5_frac_c_gp4(28);
    ex5_frac_c_gp8(25)  <= ex5_frac_c_gp4(25) and  ex5_frac_c_gp4(29);
    ex5_frac_c_gp8(26)  <= ex5_frac_c_gp4(26) and  ex5_frac_c_gp4(30);
    ex5_frac_c_gp8(27)  <= ex5_frac_c_gp4(27) and  ex5_frac_c_gp4(31);
    ex5_frac_c_gp8(28)  <= ex5_frac_c_gp4(28) ;
    ex5_frac_c_gp8(29)  <= ex5_frac_c_gp4(29) ;
    ex5_frac_c_gp8(30)  <= ex5_frac_c_gp4(30) ;
    ex5_frac_c_gp8(31)  <= ex5_frac_c_gp4(31) ;
    ex5_frac_c_gp8(32)  <= ex5_frac_c_gp4(32) and  ex5_frac_c_gp4(36);
    ex5_frac_c_gp8(33)  <= ex5_frac_c_gp4(33) and  ex5_frac_c_gp4(37);
    ex5_frac_c_gp8(34)  <= ex5_frac_c_gp4(34) and  ex5_frac_c_gp4(38);
    ex5_frac_c_gp8(35)  <= ex5_frac_c_gp4(35) and  ex5_frac_c_gp4(39);
    ex5_frac_c_gp8(36)  <= ex5_frac_c_gp4(36) ;
    ex5_frac_c_gp8(37)  <= ex5_frac_c_gp4(37) ;
    ex5_frac_c_gp8(38)  <= ex5_frac_c_gp4(38) ;
    ex5_frac_c_gp8(39)  <= ex5_frac_c_gp4(39) ;
    ex5_frac_c_gp8(40)  <= ex5_frac_c_gp4(40) and  ex5_frac_c_gp4(44);
    ex5_frac_c_gp8(41)  <= ex5_frac_c_gp4(41) and  ex5_frac_c_gp4(45);
    ex5_frac_c_gp8(42)  <= ex5_frac_c_gp4(42) and  ex5_frac_c_gp4(46);
    ex5_frac_c_gp8(43)  <= ex5_frac_c_gp4(43) and  ex5_frac_c_gp4(47);
    ex5_frac_c_gp8(44)  <= ex5_frac_c_gp4(44) ;
    ex5_frac_c_gp8(45)  <= ex5_frac_c_gp4(45) ;
    ex5_frac_c_gp8(46)  <= ex5_frac_c_gp4(46) ;
    ex5_frac_c_gp8(47)  <= ex5_frac_c_gp4(47) ;
    ex5_frac_c_gp8(48)  <= ex5_frac_c_gp4(48) and  ex5_frac_c_gp4(52);
    ex5_frac_c_gp8(49)  <= ex5_frac_c_gp4(49) ;
    ex5_frac_c_gp8(50)  <= ex5_frac_c_gp4(50) ;
    ex5_frac_c_gp8(51)  <= ex5_frac_c_gp4(51) ;
    ex5_frac_c_gp8(52)  <= ex5_frac_c_gp4(52) ;

    ex5_frac_c( 0 to  7) <=  ex5_frac_c_gp8( 0 to  7) and ( 0 to  7 => ex5_frac_g( 1) );
    ex5_frac_c( 8 to 15) <=  ex5_frac_c_gp8( 8 to 15) and ( 8 to 15 => ex5_frac_g( 2) );
    ex5_frac_c(16 to 23) <=  ex5_frac_c_gp8(16 to 23) and (16 to 23 => ex5_frac_g( 3) );
    ex5_frac_c(24)       <= (ex5_frac_c_gp8(24)       and              ex5_frac_g( 4) ) or ex5_sp ;
    ex5_frac_c(25 to 31) <=  ex5_frac_c_gp8(25 to 31) and (25 to 31 => ex5_frac_g( 4) );
    ex5_frac_c(32 to 39) <=  ex5_frac_c_gp8(32 to 39) and (32 to 39 => ex5_frac_g( 5) );
    ex5_frac_c(40 to 47) <=  ex5_frac_c_gp8(40 to 47) and (40 to 47 => ex5_frac_g( 6) );
    ex5_frac_c(48 to 52) <=  ex5_frac_c_gp8(48 to 52) ;


    ex5_frac_g16(0) <= ex5_frac_c_gp8( 0) and ex5_frac_c_gp8( 8);
    ex5_frac_g16(1) <= ex5_frac_c_gp8( 8) and ex5_frac_c_gp8(16);
    ex5_frac_g16(2) <= ex5_frac_c_gp8(16) ;
    ex5_frac_g16(3) <= ex5_frac_c_gp8(24) and ex5_frac_c_gp8(32)  ;
    ex5_frac_g16(4) <= ex5_frac_c_gp8(32) and ex5_frac_c_gp8(40)  ;
    ex5_frac_g16(5) <= ex5_frac_c_gp8(40) and ex5_frac_c_gp8(48)  ;
    ex5_frac_g16(6) <= ex5_frac_c_gp8(48) ;

    ex5_frac_g32(0) <= ex5_frac_g16(0) and ex5_frac_g16(2);
    ex5_frac_g32(1) <= ex5_frac_g16(1) ;
    ex5_frac_g32(2) <= ex5_frac_g16(2) ;
    ex5_frac_g32(3) <= ex5_frac_g16(3) and ex5_frac_g16(5);
    ex5_frac_g32(4) <= ex5_frac_g16(4) and ex5_frac_g16(6);
    ex5_frac_g32(5) <= ex5_frac_g16(5) ; 
    ex5_frac_g32(6) <= ex5_frac_g16(6) ;

    ex5_all1      <= ex5_frac_g32(0) and (ex5_sp or ex5_frac_g32(3) );
    ex5_frac_g(1) <= ex5_frac_g32(1) and (ex5_sp or ex5_frac_g32(3) );
    ex5_frac_g(2) <= ex5_frac_g32(2) and (ex5_sp or ex5_frac_g32(3) );
    ex5_frac_g(3) <= ex5_frac_g32(3) or   ex5_sp ;
    ex5_frac_g(4) <= ex5_frac_g32(4) ;
    ex5_frac_g(5) <= ex5_frac_g32(5) ; 
    ex5_frac_g(6) <= ex5_frac_g32(6) ;


    ex5_frac_p1(0)       <= f_nrm_ex5_res(0)        or ex5_frac_c(1); 
    ex5_frac_p1(1 to 51) <= f_nrm_ex5_res(1 to 51) xor ex5_frac_c(2 to 52);
    ex5_frac_p1(52)      <= not f_nrm_ex5_res(52);



    ex5_to_int_data( 0)       <= f_nrm_ex5_int_sign  ; 
    ex5_to_int_data( 1 to 10) <= f_nrm_ex5_res( 1 to 10) or  ( 1 to 10 =>     ex5_word) ; 
    ex5_to_int_data(      11) <= f_nrm_ex5_res(11)  or not ex5_to_int_imp or  ex5_word  ; 
    ex5_to_int_imp <= 
         f_nrm_ex5_res(1)  or 
         f_nrm_ex5_res(2)  or 
         f_nrm_ex5_res(3)  or 
         f_nrm_ex5_res(4)  or 
         f_nrm_ex5_res(5)  or 
         f_nrm_ex5_res(6)  or 
         f_nrm_ex5_res(7)  or 
         f_nrm_ex5_res(8)  or 
         f_nrm_ex5_res(9)  or 
         f_nrm_ex5_res(10) or 
         f_nrm_ex5_res(11) or
         ex5_word ;
    ex5_to_int_data(12)       <= f_nrm_ex5_res(12)       or                   ex5_word  ; 
    ex5_to_int_data(13 to 31) <= f_nrm_ex5_res(13 to 31) and (13 to 31 => not ex5_word) ; 
    ex5_to_int_data(32 to 52) <= f_nrm_ex5_res(32 to 52)     ;
    ex5_to_int_data(53 to 63) <= f_nrm_ex5_int_lsbs(2 to 12) ;



    ex5_p0_sel_dflt <= not ex5_to_integer     and
                       not ex5_sel_est        and
                       not f_gst_ex5_logexp_v and 
                       not ex5_sel_fpscr  ;

    ex5_frac_misc( 0)       <= (             ex5_sel_est          and f_tbl_ex5_est_frac(0)  ) or
                               (       f_gst_ex5_logexp_v         and f_gst_ex5_logexp_fract(0) ) ;


    ex5_frac_misc( 1 to 16) <= ( ( 1 to 16 => ex5_sel_est  )      and f_tbl_ex5_est_frac(1 to 16)     ) or
                               ( ( 1 to 16 => f_gst_ex5_logexp_v) and f_gst_ex5_logexp_fract(1 to 16) );

    ex5_frac_misc(17 to 19) <= ( (17 to 19 => ex5_sel_est  )      and f_tbl_ex5_est_frac(17 to 19)       ) or 
                               ( (17 to 19 => ex5_sel_fpscr)      and f_scr_ex5_fpscr_rd_dat_dfp(0 to 2) ) or 
                               ( (17 to 19 => f_gst_ex5_logexp_v) and f_gst_ex5_logexp_fract(17 to 19)   );

    ex5_frac_misc(      20) <= ( (            ex5_sel_est  )  and f_tbl_ex5_est_frac(20)             ) or 
                               ( (            ex5_sel_fpscr)  and f_scr_ex5_fpscr_rd_dat_dfp(3)      ) ;


    ex5_frac_misc(21 to 26) <= ( (21 to 26 => ex5_sel_est  )  and f_tbl_ex5_est_frac(21 to 26)   ) or 
                               ( (21 to 26 => ex5_sel_fpscr)  and f_scr_ex5_fpscr_rd_dat(0 to 5) ) ;
    ex5_frac_misc(27 to 52) <=   (27 to 52 => ex5_sel_fpscr)  and f_scr_ex5_fpscr_rd_dat(6 to 31);


    ex5_frac_p0(0) <= 
         ( ex5_p0_sel_dflt and f_nrm_ex5_res(0)    ) or
         ( ex5_to_integer  and ex5_to_int_imp      ) or 
         (                     ex5_frac_misc(0)    ) ; 
    ex5_frac_p0(1) <= 
         ( ex5_p0_sel_dflt    and f_nrm_ex5_res(1)          ) or
         ( ex5_to_integer     and ex5_to_int_data(12)       ) or
         (                        ex5_frac_misc(1)          ) or 
         (                        ex5_quiet                 ) ;
    ex5_frac_p0(2 to 19) <= 
         ( (2 to 19 => ex5_p0_sel_dflt)    and f_nrm_ex5_res( 2 to 19)     ) or
         ( (2 to 19 => ex5_to_integer )    and ex5_to_int_data(13 to 30)   ) or
         (                                     ex5_frac_misc(2 to 19)      ) ;
    ex5_frac_p0(20 to 52) <= 
         ( (20 to 52 => ex5_p0_sel_dflt) and f_nrm_ex5_res( 20 to 52)    ) or
         ( (20 to 52 => ex5_to_integer ) and ex5_to_int_data(31 to 63)   ) or
         (                                   ex5_frac_misc(20 to 52)    ) ;


    ex5_frac_px(0 to 23) <=
        ( (0 to 23 => ex5_sel_up_b) and ex5_frac_p0(0 to 23) ) or  
        ( (0 to 23 => ex5_sel_up  ) and ex5_frac_p1(0 to 23) ) ;  
    ex5_frac_px(24 to 52) <=
        ( (24 to 52 => ex5_sel_up_dp_b) and ex5_frac_p0(24 to 52) ) or  
        ( (24 to 52 => ex5_sel_up_dp  ) and ex5_frac_p1(24 to 52) ) ;  



    ex5_frac_k(0)        <=              ex5_k_notzer          or      ex5_word ; 
    ex5_frac_k(1)        <=              ex5_k_max_intmax_nan  or      ex5_word; 
    ex5_frac_k( 2 to 20) <= ( 2 to 20 => ex5_k_max_intmax      and not ex5_word    );
    ex5_frac_k(21)       <=              ex5_k_max_intsgn      ; 
    ex5_frac_k(22)       <=              ex5_k_max_intmax      ;
    ex5_frac_k(23)       <=              ex5_k_max_intmax      ;
    ex5_frac_k(24 to 52) <= (24 to 52 => ex5_k_max_intmax_nsp );

    ex5_k_notzer             <= not (f_pic_ex5_k_zer or f_pic_ex5_k_int_zer or f_pic_ex5_k_int_maxneg ); 
    ex5_k_max_intmax_nan     <=      f_pic_ex5_k_max or f_pic_ex5_k_int_maxpos or f_pic_ex5_k_nan ;
    ex5_k_max_intmax         <=      f_pic_ex5_k_max or f_pic_ex5_k_int_maxpos  ;
    ex5_k_max_intmax_nsp     <=     (f_pic_ex5_k_max or f_pic_ex5_k_int_maxpos )and not ex5_sp;

    ex5_k_max_intsgn  <= ( f_pic_ex5_k_max                                         ) or 
                         ( f_pic_ex5_k_int_maxpos and not ex5_word                 ) or 
                         ( f_pic_ex5_k_int_maxneg and     ex5_word and not ex5_uns ) or 
                         ( f_pic_ex5_k_int_maxpos and     ex5_word and     ex5_uns ) ;  
                                                                                       


    ex5_res_frac(0) <= 
        (ex5_frac_k(0)  and     ex5_res_sel_k_f ) or 
        (ex5_frac_px(0) and not ex5_res_sel_k_f ) ;

    ex5_res_frac(1 to 52) <= 
        (ex5_frac_k   (1 to 52) and (1 to 52=>     ex5_res_sel_k_f) ) or 
        (ex5_frac_px  (1 to 52) and (1 to 52=> not ex5_res_sel_k_f) ) ;




    ex5_k_inf_nan_max <= f_pic_ex5_k_nan or
                         f_pic_ex5_k_inf or
                         f_pic_ex5_k_max ;

    ex5_k_inf_nan_maxdp <= f_pic_ex5_k_nan or
                           f_pic_ex5_k_inf or
                          ( f_pic_ex5_k_max and not ex5_sp)  ;

    ex5_k_inf_nan_zer <= f_pic_ex5_k_nan or
                         f_pic_ex5_k_inf or
                         f_pic_ex5_k_zer ;

    ex5_k_zer_sp <= f_pic_ex5_k_zer and ex5_sp ; 


    ex5_expo_k( 1) <= tidn           ;
    ex5_expo_k( 2) <= tidn           ;
    ex5_expo_k( 3) <= ex5_k_inf_nan_max   or f_pic_ex5_k_int_maxpos                 or ex5_word ; 
    ex5_expo_k( 4) <= ex5_k_inf_nan_maxdp or f_pic_ex5_k_int_maxpos or ex5_k_zer_sp or ex5_word or f_pic_ex5_k_one ;
    ex5_expo_k( 5) <= ex5_k_inf_nan_maxdp or f_pic_ex5_k_int_maxpos or ex5_k_zer_sp or ex5_word or f_pic_ex5_k_one  ;
    ex5_expo_k( 6) <= ex5_k_inf_nan_maxdp or f_pic_ex5_k_int_maxpos or ex5_k_zer_sp or ex5_word or f_pic_ex5_k_one  ;
    ex5_expo_k( 7) <= ex5_k_inf_nan_max   or f_pic_ex5_k_int_maxpos                 or ex5_word or f_pic_ex5_k_one  ;
    ex5_expo_k( 8) <= ex5_k_inf_nan_max   or f_pic_ex5_k_int_maxpos                 or ex5_word or f_pic_ex5_k_one  ;
    ex5_expo_k( 9) <= ex5_k_inf_nan_max   or f_pic_ex5_k_int_maxpos                 or ex5_word or f_pic_ex5_k_one  ;
    ex5_expo_k(10) <= ex5_k_inf_nan_max   or f_pic_ex5_k_int_maxpos                 or ex5_word or f_pic_ex5_k_one  ;
    ex5_expo_k(11) <= ex5_k_inf_nan_max   or f_pic_ex5_k_int_maxpos                 or ex5_word or f_pic_ex5_k_one  ;
    ex5_expo_k(12) <= ex5_k_inf_nan_max   or f_pic_ex5_k_int_maxpos                 or ex5_word or f_pic_ex5_k_one  ;
    ex5_expo_k(13) <= ex5_k_inf_nan_zer   or f_pic_ex5_k_int_maxpos or ex5_k_zero
                                          or f_pic_ex5_k_int_maxneg                 or ex5_word or f_pic_ex5_k_one  ;



    ex5_expo_p0k(1 to 13) <=
        (  ex5_expo_k(1 to 13)                           and (1 to 13 => ex5_expo_p0_sel_k   ) ) or 
        (  (tidn & tidn & ex5_to_int_data(1 to 11))      and (1 to 13 => ex5_expo_p0_sel_int ) ) or 
        (  (tidn & tidn & f_gst_ex5_logexp_exp(1 to 11)) and (1 to 13 => ex5_expo_p0_sel_gst ) ) or
        (  ((1 to 12=>tidn) & tiup)                      and (1 to 13 => ex5_sel_fpscr       ) ) or
        (  f_eov_ex5_expo_p0(1 to 13)                    and (1 to 13 => ex5_expo_p0_sel_dflt) ) ; 

    ex5_expo_p1k(1 to 13) <=
        (  ex5_expo_k        (1 to 13) and (1 to 13 => ex5_expo_p1_sel_k   ) ) or 
        (  f_eov_ex5_expo_p1 (1 to 13) and (1 to 13 => ex5_expo_p1_sel_dflt) ) ; 

    ex5_expo_p0kx(1 to 7) <=
        ( ex5_expo_p0k(1 to 7) and (1 to 7 => not ex5_sel_p0_joke) ) or
        ( (tidn & tidn & f_eov_ex5_expo_p0_ue1oe1(3 to 7) )
                               and (1 to 7 =>     ex5_sel_p0_joke) ) ;

    ex5_expo_p1kx(1 to 7) <=
        ( ex5_expo_p1k(1 to 7) and (1 to 7 => not ex5_sel_p1_joke) ) or
        ( (tidn & tidn & f_eov_ex5_expo_p1_ue1oe1(3 to 7) )
                               and (1 to 7 =>     ex5_sel_p1_joke) ) ;


    ex5_expo_p0kx(8 to 12) <= ex5_expo_p0k(8 to 12); 
    ex5_expo_p1kx(8 to 12) <= ex5_expo_p1k(8 to 12); 

     

    ex5_expo_p0kx(13) <= ex5_expo_p0k(13);  
    ex5_expo_p1kx(13) <= ex5_expo_p1k(13) ; 


   ex5_res_expo( 1) <= ( ex5_expo_p0kx( 1) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_expo_p1kx( 1) and     ex5_res_sel_p1_e                        );
   ex5_res_expo( 2) <= ( ex5_expo_p0kx( 2) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_expo_p1kx( 2) and     ex5_res_sel_p1_e                        );
   ex5_res_expo( 3) <= ( ex5_expo_p0kx( 3) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_expo_p1kx( 3) and     ex5_res_sel_p1_e                        );

   ex5_res_expo( 4) <= ( ex5_expo_p0kx( 4) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_sp            and not ex5_res_sel_p1_e and     ex5_res_clip_e ) or 
                       ( ex5_expo_p1kx( 4) and     ex5_res_sel_p1_e                        );
   ex5_res_expo( 5) <= ( ex5_expo_p0kx( 5) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_sp            and not ex5_res_sel_p1_e and     ex5_res_clip_e ) or 
                       ( ex5_expo_p1kx( 5) and     ex5_res_sel_p1_e                        );
   ex5_res_expo( 6) <= ( ex5_expo_p0kx( 6) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_sp            and not ex5_res_sel_p1_e and     ex5_res_clip_e ) or 
                       ( ex5_expo_p1kx( 6) and     ex5_res_sel_p1_e                        );

   ex5_res_expo( 7) <= ( ex5_expo_p0kx( 7) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_expo_p1kx( 7) and     ex5_res_sel_p1_e                        );
   ex5_res_expo( 8) <= ( ex5_expo_p0kx( 8) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_expo_p1kx( 8) and     ex5_res_sel_p1_e                        );
   ex5_res_expo( 9) <= ( ex5_expo_p0kx( 9) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_expo_p1kx( 9) and     ex5_res_sel_p1_e                        );
   ex5_res_expo(10) <= ( ex5_expo_p0kx(10) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_expo_p1kx(10) and     ex5_res_sel_p1_e                        );
   ex5_res_expo(11) <= ( ex5_expo_p0kx(11) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_expo_p1kx(11) and     ex5_res_sel_p1_e                        );
   ex5_res_expo(12) <= ( ex5_expo_p0kx(12) and not ex5_res_sel_p1_e and not ex5_res_clip_e ) or  
                       ( ex5_expo_p1kx(12) and     ex5_res_sel_p1_e                        );
   ex5_res_expo(13) <= ( ex5_expo_p0kx(13) and not ex5_res_sel_p1_e                        ) or  
                       (                       not ex5_res_sel_p1_e and     ex5_res_clip_e ) or 
                       ( ex5_expo_p1kx(13) and     ex5_res_sel_p1_e                        );


    ex5_sgn_result_fp     <= f_pic_ex5_round_sign xor f_pic_ex5_invert_sign;

    ex5_res_sign_prez   <=
      ( ex5_sgn_result_fp     and not ( (ex5_to_integer or f_gst_ex5_logexp_v) and not ex5_expo_sel_k) ) or 
      ( ex5_to_int_data(0)    and     (  ex5_to_integer                        and not ex5_expo_sel_k) and not ex5_word ) or 
      ( f_gst_ex5_logexp_sign and     (                    f_gst_ex5_logexp_v  and not ex5_expo_sel_k) ) ;


    ex5_exact_zero_rnd <= f_nrm_ex5_exact_zero and
                      not f_nrm_ex5_nrm_sticky_dp ; 


    ex5_rnd_ni_adj <= ex5_rnd_ni xor f_pic_ex5_invert_sign;

    ex5_exact_sgn_rst <= f_pic_ex5_en_exact_zero and ex5_exact_zero_rnd and not ex5_rnd_ni_adj ;
    ex5_exact_sgn_set <= f_pic_ex5_en_exact_zero and ex5_exact_zero_rnd and     ex5_rnd_ni_adj ;

    ex5_res_sign <= (ex5_res_sign_prez and not ex5_exact_sgn_rst) or ex5_exact_sgn_set;



   ex5_res_sel_k_f <=
        ( f_eov_ex5_sel_kif_f  and ex5_all1 and ex5_up           ) or
        ( f_eov_ex5_sel_k_f                                      ) or
        ( ex5_clip_deno                                          ) or  
        ( ex5_sel_est   and  f_tbl_ex5_recip_den and ex5_nj_deno ) ;   


   ex5_res_sel_p1_e <=            ex5_all1 and ex5_up ;


   ex5_est_log_pow <= f_gst_ex5_logexp_v or ex5_sel_est ;

   ex5_res_clip_e   <=
        ( ex5_unf_en_ue0 and not f_nrm_ex5_res(0)    and not ex5_expo_sel_k and not ex5_est_log_pow) or 
        ( ex5_unf_en_ue0 and     f_eov_ex5_unf_expo  and not ex5_expo_sel_k and not ex5_est_log_pow) or 
        ( ex5_all0       and not ex5_to_integer      and not ex5_expo_sel_k and not ex5_est_log_pow) or  
        ( ex5_nj_deno    and not f_nrm_ex5_res(0)    and not ex5_expo_sel_k and not ex5_est_log_pow) ;  

    ex5_clip_deno <= ( ex5_nj_deno    and not f_nrm_ex5_res(0)    and not ex5_expo_sel_k and not ex5_est_log_pow) ;

    ex5_expo_sel_k      <= f_eov_ex5_sel_k_e;
    ex5_expo_sel_k_both <= f_eov_ex5_sel_k_e or f_eov_ex5_sel_kif_e;


    ex5_expo_p0_sel_k    <=     ex5_expo_sel_k ;
    ex5_expo_p0_sel_gst  <= not ex5_expo_sel_k and                            f_gst_ex5_logexp_v;
    ex5_expo_p0_sel_int  <= not ex5_expo_sel_k and     ex5_to_integer;
    ex5_expo_p0_sel_dflt <= not ex5_expo_sel_k and not ex5_to_integer and not f_gst_ex5_logexp_v;


    ex5_expo_p1_sel_k    <=     ex5_expo_sel_k_both;
    ex5_expo_p1_sel_dflt <= not ex5_expo_sel_k_both;

    ex5_sel_p0_joke <=  
        ( ex5_unf_en_ue1 and f_eov_ex5_unf_expo    ) or 
        ( ex5_ovf_en_oe1 and f_eov_ex5_ovf_expo    );
 
    ex5_sel_p1_joke <=  
        ( ex5_unf_en_ue1 and f_eov_ex5_unf_expo    ) or 
        ( ex5_ovf_en_oe1 and f_eov_ex5_ovf_expo    ) or
        ( ex5_ovf_en_oe1 and f_eov_ex5_ovf_if_expo );





    ex5_pwr4_spec_frsp <= ex5_unf_en_ue1 and not f_nrm_ex5_res(0) and f_pic_ex5_frsp ;

    ex5_flag_ox       <=
       ( f_eov_ex5_ovf_expo                            ) or 
       ( f_eov_ex5_ovf_if_expo and ex5_all1 and ex5_up ) ; 

    ex5_ov_oe0 <= ex5_flag_ox and ex5_ovf_en_oe0;

    ex5_flag_inf      <= 
       ( ex5_spec_inf                       ) or
       ( ex5_ov_oe0 and not f_pic_ex5_k_max ); 


    ex5_flag_up       <= ex5_ov_oe0 or ex5_up;  
    ex5_flag_fi       <= ex5_ov_oe0 or ex5_gox; 


    
    ex5_flag_ux       <= 
       ( ex5_unf_en_ue0 and not f_nrm_ex5_res(0) and not ex5_exact_zero_rnd and ex5_gox and not ex5_sel_est ) or 
       ( ex5_unf_en_ue0 and f_eov_ex5_unf_expo   and not ex5_exact_zero_rnd and ex5_gox                     ) or 
       ( ex5_unf_en_ue1 and f_eov_ex5_unf_expo   and not ex5_exact_zero_rnd                                 ) or 
       ( ex5_unf_en_ue1 and f_eov_ex5_unf_expo   and     ex5_sel_est                                        ) or 
       ( ex5_unf_en_ue0 and f_eov_ex5_unf_expo   and     ex5_sel_est                                        ) or 
       ( ex5_pwr4_spec_frsp                                                                                 );   



    ex5_k_zero <= f_pic_ex5_k_zer or f_pic_ex5_k_int_zer ;
 
    ex5_flag_zer      <=
       ( not ex5_sel_est     and not ex5_res_sel_k_f and ex5_all0 and not ex5_up             ) or 
       (                             ex5_res_sel_k_f and ex5_k_zero                          ) ;  

    ex5_flag_den    <=
       ( not ex5_sel_est and not ex5_res_frac(0)                   ) or 
       (     ex5_sel_est and f_tbl_ex5_recip_den                   ) or
       (     ex5_sel_est and ex5_unf_en_ue0 and f_eov_ex5_unf_expo ) ;  


 
 
    ex6_frac_lat:  tri_rlmreg_p generic map (width=> 53, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(6)  ,
        mpw1_b           => mpw1_b(6)       ,
        mpw2_b           => mpw2_b(1)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex5_act, 
        scout            => ex6_frac_so  ,                      
        scin             => ex6_frac_si  ,                    
        din              => ex5_res_frac(0 to 52),
        dout             => ex6_res_frac(0 to 52) );

    ex6_expo_lat:  tri_rlmreg_p generic map (width=> 14, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(6)  ,
        mpw1_b           => mpw1_b(6)       ,
        mpw2_b           => mpw2_b(1)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex5_act, 
        scout            => ex6_expo_so  ,                      
        scin             => ex6_expo_si  ,                    
         din(0)             => ex5_res_sign ,
         din(1 to 13)       => ex5_res_expo(1 to 13) ,
        dout(0)             => ex6_res_sign  ,
        dout(1 to 13)       => ex6_res_expo(1 to 13) );

    ex6_flag_lat:  tri_rlmreg_p generic map (width=> 10, expand_type => expand_type, needs_sreset => 1) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(6)  ,
        mpw1_b           => mpw1_b(6)       ,
        mpw2_b           => mpw2_b(1)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex5_act, 
        scout            => ex6_flag_so  ,                      
        scin             => ex6_flag_si  ,                    
         din(0)             => flag_spare_unused   ,
         din(1)             => ex5_res_sign        ,
         din(2)             => ex5_flag_den        ,
         din(3)             => ex5_flag_inf        ,
         din(4)             => ex5_flag_zer        ,
         din(5)             => ex5_flag_ux         ,
         din(6)             => ex5_flag_up         ,
         din(7)             => ex5_flag_fi         ,
         din(8)             => ex5_flag_ox         ,
         din(9)             => ex5_nj_deno         ,
        dout(0)             => flag_spare_unused   ,
        dout(1)             => ex6_flag_sgn        ,
        dout(2)             => ex6_flag_den        ,
        dout(3)             => ex6_flag_inf        ,
        dout(4)             => ex6_flag_zer        ,
        dout(5)             => ex6_flag_ux         ,
        dout(6)             => ex6_flag_up         ,
        dout(7)             => ex6_flag_fi         ,
        dout(8)             => ex6_flag_ox         ,
        dout(9)             => ex6_nj_deno        );


       f_rnd_ex6_res_sign          <= ex6_res_sign          ;
       f_rnd_ex6_res_expo(1 to 13) <= ex6_res_expo(1 to 13) ;
       f_rnd_ex6_res_frac(0 to 52) <= ex6_res_frac(0 to 52) ;

       f_rnd_ex6_flag_sgn          <=     ex6_flag_sgn                                       ;
       f_rnd_ex6_flag_den          <=     ex6_flag_den and                  not ex6_nj_deno  ;
       f_rnd_ex6_flag_inf          <=     ex6_flag_inf                                       ;
       f_rnd_ex6_flag_zer          <=     ex6_flag_zer or     (ex6_flag_den and ex6_nj_deno) ;
       f_rnd_ex6_flag_ux           <=     ex6_flag_ux  and not(ex6_flag_den and ex6_nj_deno) ;
       f_rnd_ex6_flag_up           <=     ex6_flag_up  and not(ex6_flag_den and ex6_nj_deno) ;
       f_rnd_ex6_flag_fi           <=     ex6_flag_fi  and not(ex6_flag_den and ex6_nj_deno) ;
       f_rnd_ex6_flag_ox           <=     ex6_flag_ox                                        ;


       f_mad_ex6_uc_sign           <=  ex6_res_sign;
       f_mad_ex6_uc_zero           <=  ex6_flag_zer and not ex6_flag_fi;


    act_si  (0 to 4)       <= act_so  (1 to 4)       & f_rnd_si ;
    ex5_ctl_si   (0 to 15) <= ex5_ctl_so  (1 to 15)  & act_so  (0) ;
    ex6_frac_si  (0 to 52) <= ex6_frac_so  (1 to 52) & ex5_ctl_so  (0) ;
    ex6_expo_si  (0 to 13) <= ex6_expo_so  (1 to 13) & ex6_frac_so  (0) ;
    ex6_flag_si  (0 to 9)  <= ex6_flag_so  (1 to 9)  & ex6_expo_so  (0) ;
    f_rnd_so               <= ex6_flag_so  (0);
 

end; 
 




 


