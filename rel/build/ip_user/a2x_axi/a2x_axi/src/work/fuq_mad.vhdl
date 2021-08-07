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

entity fuq_mad is
generic(
     expand_type                    : integer := 2  ); 
port (
        f_dcd_ex6_cancel          :in  std_ulogic;    
   
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
        f_fpr_ex7_frt_sign        :in   std_ulogic                  ;
        f_fpr_ex7_frt_expo        :in   std_ulogic_vector  (1 to 13);
        f_fpr_ex7_frt_frac        :in   std_ulogic_vector  (0 to 52);
        f_fpr_ex7_load_sign       :in   std_ulogic                  ;
        f_fpr_ex7_load_expo       :in   std_ulogic_vector  (3 to 13);
        f_fpr_ex7_load_frac       :in   std_ulogic_vector  (0 to 52);
        f_fpr_ex6_load_sign        :in  std_ulogic;
        f_fpr_ex6_load_expo        :in  std_ulogic_vector(3 to 13);
        f_fpr_ex6_load_frac        :in  std_ulogic_vector(0 to 52);
        f_fpr_rf1_a_sign           :in  std_ulogic;
        f_fpr_rf1_a_expo           :in  std_ulogic_vector(1 to 13) ;
        f_fpr_rf1_a_frac           :in  std_ulogic_vector(0 to 52) ;
        f_fpr_ex1_a_par            :in  std_ulogic_vector(0 to 7);

        f_fpr_rf1_c_sign           :in  std_ulogic;
        f_fpr_rf1_c_expo           :in  std_ulogic_vector(1 to 13) ;
        f_fpr_rf1_c_frac           :in  std_ulogic_vector(0 to 52) ;
        f_fpr_ex1_c_par            :in  std_ulogic_vector(0 to 7);

        f_fpr_rf1_b_sign           :in  std_ulogic;
        f_fpr_rf1_b_expo           :in  std_ulogic_vector(1 to 13) ;
        f_fpr_rf1_b_frac           :in  std_ulogic_vector(0 to 52) ;
        f_fpr_ex1_b_par            :in  std_ulogic_vector(0 to 7);

        f_dcd_rf1_aop_valid        :in  std_ulogic;
        f_dcd_rf1_cop_valid        :in  std_ulogic;
        f_dcd_rf1_bop_valid        :in  std_ulogic;
        f_dcd_rf1_sp               :in  std_ulogic; 
        f_dcd_rf1_emin_dp          :in  std_ulogic;                 
        f_dcd_rf1_emin_sp          :in  std_ulogic;                 
        f_dcd_rf1_force_pass_b     :in  std_ulogic;                 

        f_dcd_rf1_fsel_b           :in  std_ulogic;                 
        f_dcd_rf1_from_integer_b   :in  std_ulogic;                 
        f_dcd_rf1_to_integer_b     :in  std_ulogic;                 
        f_dcd_rf1_rnd_to_int_b     :in  std_ulogic;                 
        f_dcd_rf1_math_b           :in  std_ulogic;                 
        f_dcd_rf1_est_recip_b      :in  std_ulogic;                 
        f_dcd_rf1_est_rsqrt_b      :in  std_ulogic;                 
        f_dcd_rf1_move_b           :in  std_ulogic;                 
        f_dcd_rf1_prenorm_b        :in  std_ulogic;                 
        f_dcd_rf1_frsp_b           :in  std_ulogic;                 
        f_dcd_rf1_compare_b        :in  std_ulogic;                 
        f_dcd_rf1_ordered_b        :in  std_ulogic;                 

        f_dcd_rf1_pow2e_b          :in  std_ulogic;                 
        f_dcd_rf1_log2e_b          :in  std_ulogic;                 

        f_dcd_rf1_ftdiv            :in  std_ulogic;                 
        f_dcd_rf1_ftsqrt           :in  std_ulogic;                 


        f_dcd_rf1_nj_deno          :in  std_ulogic;                 
        f_dcd_rf1_nj_deni          :in  std_ulogic;                 

        f_dcd_rf1_sp_conv_b        :in  std_ulogic;                 
        f_dcd_rf1_word_b           :in  std_ulogic;                 
        f_dcd_rf1_uns_b            :in  std_ulogic;                 
        f_dcd_rf1_sub_op_b         :in  std_ulogic;                 

        f_dcd_rf1_force_excp_dis   :in  std_ulogic;

        f_dcd_rf1_op_rnd_v_b       :in  std_ulogic;                 
        f_dcd_rf1_op_rnd_b         :in  std_ulogic_vector(0 to 1);  
        f_dcd_rf1_inv_sign_b       :in  std_ulogic;                 
        f_dcd_rf1_sign_ctl_b       :in  std_ulogic_vector(0 to 1);  
        f_dcd_rf1_sgncpy_b         :in  std_ulogic;                 
        
        f_dcd_rf1_fpscr_bit_data_b :in  std_ulogic_vector(0 to 3);  
        f_dcd_rf1_fpscr_bit_mask_b :in  std_ulogic_vector(0 to 3);  
        f_dcd_rf1_fpscr_nib_mask_b :in  std_ulogic_vector(0 to 8);  

        f_dcd_rf1_mv_to_scr_b      :in  std_ulogic;                 
        f_dcd_rf1_mv_from_scr_b    :in  std_ulogic;                 
        f_dcd_rf1_mtfsbx_b         :in  std_ulogic;                 
        f_dcd_rf1_mcrfs_b          :in  std_ulogic;                 
        f_dcd_rf1_mtfsf_b          :in  std_ulogic;                 
        f_dcd_rf1_mtfsfi_b         :in  std_ulogic;                 

        f_dcd_ex1_perr_force_c     :in  std_ulogic;
        f_dcd_ex1_perr_fsel_ovrd   :in  std_ulogic;

        f_dcd_rf1_uc_fc_hulp       :in  std_ulogic;
        f_dcd_rf1_uc_fa_pos        :in  std_ulogic;
        f_dcd_rf1_uc_fc_pos        :in  std_ulogic;
        f_dcd_rf1_uc_fb_pos        :in  std_ulogic;
        f_dcd_rf1_uc_fc_0_5        :in  std_ulogic;
        f_dcd_rf1_uc_fc_1_0        :in  std_ulogic;
        f_dcd_rf1_uc_fc_1_minus    :in  std_ulogic;
        f_dcd_rf1_uc_fb_1_0        :in  std_ulogic;
        f_dcd_rf1_uc_fb_0_75       :in  std_ulogic;
        f_dcd_rf1_uc_fb_0_5        :in  std_ulogic;
        f_dcd_rf1_uc_ft_pos        :in  std_ulogic;
        f_dcd_rf1_uc_ft_neg        :in  std_ulogic;

        f_dcd_rf1_div_beg          :in std_ulogic; 
        f_dcd_rf1_sqrt_beg         :in std_ulogic; 
        f_dcd_rf1_uc_mid           :in std_ulogic;
        f_dcd_rf1_uc_end           :in std_ulogic;
        f_dcd_rf1_uc_special       :in std_ulogic;
        f_dcd_ex2_uc_zx            :in std_ulogic;
        f_dcd_ex2_uc_vxidi         :in std_ulogic;
        f_dcd_ex2_uc_vxzdz         :in std_ulogic;
        f_dcd_ex2_uc_vxsqrt        :in std_ulogic;
        f_dcd_ex2_uc_vxsnan        :in std_ulogic;

        f_dcd_ex2_uc_inc_lsb       :in  std_ulogic;
        f_dcd_ex2_uc_gs_v          :in  std_ulogic;
        f_dcd_ex2_uc_gs            :in  std_ulogic_vector(0 to 1);

        f_mad_ex6_uc_sign          :out std_ulogic;
        f_mad_ex6_uc_zero          :out std_ulogic;
        f_mad_ex3_uc_special       :out std_ulogic;
        f_mad_ex3_uc_zx            :out std_ulogic;
        f_mad_ex3_uc_vxidi         :out std_ulogic;
        f_mad_ex3_uc_vxzdz         :out std_ulogic;
        f_mad_ex3_uc_vxsqrt        :out std_ulogic;
        f_mad_ex3_uc_vxsnan        :out std_ulogic;
        f_mad_ex3_uc_res_sign      :out std_ulogic;
        f_mad_ex3_uc_round_mode    :out std_ulogic_vector(0 to 1);

        f_mad_ex2_a_parity_check   :out std_ulogic;
        f_mad_ex2_c_parity_check   :out std_ulogic;
        f_mad_ex2_b_parity_check   :out std_ulogic;


        f_ex2_b_den_flush          :out  std_ulogic                 ;

        f_scr_ex7_cr_fld           :out std_ulogic_vector (0 to 3)     ;
        f_add_ex4_fpcc_iu          :out std_ulogic_vector (0 to 3)     ;
        f_pic_ex5_fpr_wr_dis_b     :out std_ulogic                     ;
        f_rnd_ex6_res_expo         :out std_ulogic_vector (1 to 13)    ;
        f_rnd_ex6_res_frac         :out std_ulogic_vector (0 to 52)    ;
        f_rnd_ex6_res_sign         :out std_ulogic ;
        f_scr_ex7_fx_thread0       :out std_ulogic_vector (0 to 3)     ;
        f_scr_ex7_fx_thread1       :out std_ulogic_vector (0 to 3)     ;
        f_scr_ex7_fx_thread2       :out std_ulogic_vector (0 to 3)     ;
        f_scr_ex7_fx_thread3       :out std_ulogic_vector (0 to 3)     ;

        rf1_thread_b               :in  std_ulogic_vector(0 to 3) ;
        f_dcd_rf1_act              :in  std_ulogic; 
        vdd                        : inout power_logic;
        gnd                        : inout power_logic;
        scan_in                    :in  std_ulogic_vector(0 to 17);
        scan_out                   :out std_ulogic_vector(0 to 17);

        clkoff_b                   :in  std_ulogic; 
        act_dis                    :in  std_ulogic; 
        flush                      :in  std_ulogic; 
        delay_lclkr                :in  std_ulogic_vector(1 to 7); 
        mpw1_b                     :in  std_ulogic_vector(1 to 7); 
        mpw2_b                     :in  std_ulogic_vector(0 to 1); 
        thold_1                    :in  std_ulogic;
        sg_1                       :in  std_ulogic;
        fpu_enable                 :in  std_ulogic;
        nclk                       :in  clk_logic       
);      

end fuq_mad;


architecture fuq_mad of fuq_mad is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal f_fmt_ex1_inf_and_beyond_sp :std_ulogic ;
    signal perv_eie_sg_1      :std_ulogic; 
    signal perv_eov_sg_1      :std_ulogic; 
    signal perv_fmt_sg_1      :std_ulogic; 
    signal perv_mul_sg_1      :std_ulogic; 
    signal perv_alg_sg_1      :std_ulogic; 
    signal perv_add_sg_1      :std_ulogic; 
    signal perv_lza_sg_1      :std_ulogic; 
    signal perv_nrm_sg_1      :std_ulogic; 
    signal perv_rnd_sg_1      :std_ulogic; 
    signal perv_scr_sg_1      :std_ulogic; 
    signal perv_pic_sg_1      :std_ulogic; 
    signal perv_cr2_sg_1      :std_ulogic; 
    signal perv_eie_thold_1   :std_ulogic; 
    signal perv_eov_thold_1   :std_ulogic; 
    signal perv_fmt_thold_1   :std_ulogic; 
    signal perv_mul_thold_1   :std_ulogic; 
    signal perv_alg_thold_1   :std_ulogic; 
    signal perv_add_thold_1   :std_ulogic; 
    signal perv_lza_thold_1   :std_ulogic; 
    signal perv_nrm_thold_1   :std_ulogic; 
    signal perv_rnd_thold_1   :std_ulogic; 
    signal perv_scr_thold_1   :std_ulogic; 
    signal perv_pic_thold_1   :std_ulogic; 
    signal perv_cr2_thold_1   :std_ulogic; 
    signal perv_eie_fpu_enable  :std_ulogic; 
    signal perv_eov_fpu_enable  :std_ulogic; 
    signal perv_fmt_fpu_enable  :std_ulogic; 
    signal perv_mul_fpu_enable  :std_ulogic; 
    signal perv_alg_fpu_enable  :std_ulogic; 
    signal perv_add_fpu_enable  :std_ulogic; 
    signal perv_lza_fpu_enable  :std_ulogic; 
    signal perv_nrm_fpu_enable  :std_ulogic; 
    signal perv_rnd_fpu_enable  :std_ulogic; 
    signal perv_scr_fpu_enable  :std_ulogic; 
    signal perv_pic_fpu_enable  :std_ulogic; 
    signal perv_cr2_fpu_enable  :std_ulogic; 



    signal f_eov_ex4_may_ovf                        :std_ulogic ;
    signal f_add_ex4_flag_eq                        :std_ulogic ;
    signal f_add_ex4_flag_gt                        :std_ulogic ;
    signal f_add_ex4_flag_lt                        :std_ulogic ;
    signal f_add_ex4_flag_nan                       :std_ulogic ;
    signal f_add_ex4_res                            :std_ulogic_vector (0 to 162)   ;
    signal f_add_ex4_sign_carry                     :std_ulogic ;
    signal f_add_ex4_sticky                         :std_ulogic ;
    signal f_add_ex4_to_int_ovf_dw                  :std_ulogic_vector(0 to 1) ;
    signal f_add_ex4_to_int_ovf_wd                  :std_ulogic_vector(0 to 1) ;
    signal f_alg_ex2_effsub_eac_b                   :std_ulogic ;
    signal f_alg_ex2_prod_z                         :std_ulogic ;
    signal f_alg_ex2_res                            :std_ulogic_vector (0 to 162)   ;
    signal f_alg_ex2_sel_byp                        :std_ulogic ;
    signal f_alg_ex2_sh_ovf                         :std_ulogic ;
    signal f_alg_ex2_sh_unf                         :std_ulogic ;
    signal f_alg_ex3_frc_sel_p1                     :std_ulogic ;
    signal f_alg_ex3_int_fi                         :std_ulogic ;
    signal f_alg_ex3_int_fr                         :std_ulogic ;
    signal f_alg_ex3_sticky                         :std_ulogic ;

    signal f_byp_fmt_ex1_a_expo                     :std_ulogic_vector (1 to 13)    ;
    signal f_byp_eie_ex1_a_expo                     :std_ulogic_vector (1 to 13)    ;
    signal f_byp_alg_ex1_a_expo                     :std_ulogic_vector (1 to 13)    ;
    signal f_byp_fmt_ex1_b_expo                     :std_ulogic_vector (1 to 13)    ;
    signal f_byp_eie_ex1_b_expo                     :std_ulogic_vector (1 to 13)    ;
    signal f_byp_alg_ex1_b_expo                     :std_ulogic_vector (1 to 13)    ;
    signal f_byp_fmt_ex1_c_expo                     :std_ulogic_vector (1 to 13)    ;
    signal f_byp_eie_ex1_c_expo                     :std_ulogic_vector (1 to 13)    ;
    signal f_byp_alg_ex1_c_expo                     :std_ulogic_vector (1 to 13)    ;
    signal f_byp_fmt_ex1_a_frac                     :std_ulogic_vector (0 to 52)    ;
    signal f_byp_fmt_ex1_c_frac                     :std_ulogic_vector (0 to 52)    ;
    signal f_byp_fmt_ex1_b_frac                     :std_ulogic_vector (0 to 52)    ;
    signal f_byp_mul_ex1_a_frac                     :std_ulogic_vector (0 to 52)    ;
    signal f_byp_mul_ex1_a_frac_17                  :std_ulogic                     ;
    signal f_byp_mul_ex1_a_frac_35                  :std_ulogic                     ;
    signal f_byp_mul_ex1_c_frac                     :std_ulogic_vector (0 to 53)    ;
    signal f_byp_alg_ex1_b_frac                     :std_ulogic_vector (0 to 52)    ;
    signal f_byp_fmt_ex1_a_sign                     :std_ulogic ;
    signal f_byp_fmt_ex1_b_sign                     :std_ulogic ;
    signal f_byp_fmt_ex1_c_sign                     :std_ulogic ;
    signal f_byp_pic_ex1_a_sign                     :std_ulogic ;
    signal f_byp_pic_ex1_b_sign                     :std_ulogic ;
    signal f_byp_pic_ex1_c_sign                     :std_ulogic ;
    signal f_byp_alg_ex1_b_sign                     :std_ulogic ;

    signal f_cr2_ex1_fpscr_shadow                   :std_ulogic_vector(0 to 7)     ;
    signal f_pic_ex2_rnd_inf_ok                     :std_ulogic ;
    signal f_pic_ex2_rnd_nr                         :std_ulogic ;
    signal f_cr2_ex3_fpscr_bit_data_b               :std_ulogic_vector(0 to 3);  
    signal f_cr2_ex3_fpscr_bit_mask_b               :std_ulogic_vector(0 to 3); 
    signal f_cr2_ex3_fpscr_nib_mask_b               :std_ulogic_vector(0 to 8);  
    signal f_cr2_ex3_mcrfs_b                        :std_ulogic ;
    signal f_cr2_ex3_mtfsbx_b                       :std_ulogic ;
    signal f_cr2_ex3_mtfsf_b                        :std_ulogic ;
    signal f_cr2_ex3_mtfsfi_b                       :std_ulogic ;
    signal f_cr2_ex3_thread_b                       :std_ulogic_vector(0 to 3);
    signal f_pic_add_ex1_act_b                      :std_ulogic ;
    signal f_pic_alg_ex1_act                        :std_ulogic ;
    signal f_pic_cr2_ex1_act                        :std_ulogic ;
    signal f_pic_eie_ex1_act                        :std_ulogic ;
    signal f_pic_eov_ex2_act_b                      :std_ulogic ;
    signal f_pic_ex1_effsub_raw                     :std_ulogic ;
    signal f_pic_ex1_from_integer                   :std_ulogic ;
    signal f_pic_ex1_fsel                           :std_ulogic ;
    signal f_pic_ex1_sh_ovf_do                      :std_ulogic ;
    signal f_pic_ex1_sh_ovf_ig_b                    :std_ulogic ;
    signal f_pic_ex1_sh_unf_do                      :std_ulogic ;
    signal f_pic_ex1_sh_unf_ig_b                    :std_ulogic ;
    signal f_pic_ex2_force_sel_bexp                 :std_ulogic ;
    signal f_pic_ex2_lzo_dis_prod                   :std_ulogic ;
    signal f_pic_ex2_sp_b                           :std_ulogic ;
    signal f_pic_ex2_sp_lzo                         :std_ulogic ;
    signal f_pic_ex2_to_integer                     :std_ulogic ;
    signal f_pic_ex2_prenorm                        :std_ulogic ;
    signal f_pic_ex3_cmp_sgnneg                     :std_ulogic ;
    signal f_pic_ex3_cmp_sgnpos                     :std_ulogic ;
    signal f_pic_ex3_is_eq                          :std_ulogic ;
    signal f_pic_ex3_is_gt                          :std_ulogic ;
    signal f_pic_ex3_is_lt                          :std_ulogic ;
    signal f_pic_ex3_is_nan                         :std_ulogic ;
    signal f_pic_ex3_sel_est                        :std_ulogic ;
    signal f_pic_ex3_sp_b                           :std_ulogic ;
    signal f_pic_ex4_nj_deno                        :std_ulogic ;
    signal f_pic_ex4_oe                             :std_ulogic ;
    signal f_pic_ex4_ov_en                          :std_ulogic ;
    signal f_pic_ex4_ovf_en_oe0_b                   :std_ulogic ;
    signal f_pic_ex4_ovf_en_oe1_b                   :std_ulogic ;
    signal f_pic_ex4_quiet_b                        :std_ulogic ;
    signal f_pic_ex5_uc_inc_lsb                     :std_ulogic ;
    signal f_pic_ex5_uc_guard                       :std_ulogic ;
    signal f_pic_ex5_uc_sticky                      :std_ulogic ;
    signal f_pic_ex5_uc_g_v                         :std_ulogic ;
    signal f_pic_ex5_uc_s_v                         :std_ulogic ;
    signal f_pic_ex4_rnd_inf_ok_b                   :std_ulogic ;
    signal f_pic_ex4_rnd_ni_b                       :std_ulogic ;
    signal f_pic_ex4_rnd_nr_b                       :std_ulogic ;
    signal f_pic_ex4_sel_est_b                      :std_ulogic ;
    signal f_pic_ex4_sel_fpscr_b                    :std_ulogic ;
    signal f_pic_ex4_sp_b                           :std_ulogic ;
    signal f_pic_ex4_spec_inf_b                     :std_ulogic ;
    signal f_pic_ex4_spec_sel_k_e                   :std_ulogic ;
    signal f_pic_ex4_spec_sel_k_f                   :std_ulogic ;
    signal f_pic_ex4_to_int_ov_all                  :std_ulogic ;
    signal f_pic_ex4_to_integer_b                   :std_ulogic ;
    signal f_pic_ex4_word_b                         :std_ulogic ;
    signal f_pic_ex4_uns_b                          :std_ulogic ;
    signal f_pic_ex4_ue                             :std_ulogic ;
    signal f_pic_ex4_uf_en                          :std_ulogic ;
    signal f_pic_ex4_unf_en_ue0_b                   :std_ulogic ;
    signal f_pic_ex4_unf_en_ue1_b                   :std_ulogic ;
    signal f_pic_ex5_en_exact_zero                  :std_ulogic ;
    signal f_pic_ex5_compare_b                      :std_ulogic ;
    signal f_pic_ex2_ue1                            :std_ulogic ;
    signal f_pic_ex2_frsp_ue1                       :std_ulogic ;
    signal f_pic_ex1_frsp_ue1                       :std_ulogic ;
    signal f_pic_ex5_frsp                           :std_ulogic ;
    signal f_pic_ex5_fi_pipe_v_b                    :std_ulogic ;
    signal f_pic_ex5_fi_spec_b                      :std_ulogic ;
    signal f_pic_ex5_flag_vxcvi_b                   :std_ulogic ;
    signal f_pic_ex5_flag_vxidi_b                   :std_ulogic ;
    signal f_pic_ex5_flag_vximz_b                   :std_ulogic ;
    signal f_pic_ex5_flag_vxisi_b                   :std_ulogic ;
    signal f_pic_ex5_flag_vxsnan_b                  :std_ulogic ;
    signal f_pic_ex5_flag_vxsqrt_b                  :std_ulogic ;
    signal f_pic_ex5_flag_vxvc_b                    :std_ulogic ;
    signal f_pic_ex5_flag_vxzdz_b                   :std_ulogic ;
    signal f_pic_ex5_flag_zx_b                      :std_ulogic ;
    signal f_pic_ex5_fprf_hold_b                    :std_ulogic ;
    signal f_pic_ex5_fprf_pipe_v_b                  :std_ulogic ;
    signal f_pic_ex5_fprf_spec_b                    :std_ulogic_vector (0 to 4)     ;
    signal f_pic_ex5_fr_pipe_v_b                    :std_ulogic ;
    signal f_pic_ex5_fr_spec_b                      :std_ulogic ;
    signal f_pic_ex5_invert_sign                    :std_ulogic ;
    signal f_pic_ex4_byp_prod_nz                    :std_ulogic ;
    signal f_pic_ex5_k_nan                          :std_ulogic ;
    signal f_pic_ex5_k_inf                          :std_ulogic ;
    signal f_pic_ex5_k_max                          :std_ulogic ;
    signal f_pic_ex5_k_zer                          :std_ulogic ;
    signal f_pic_ex5_k_one                          :std_ulogic ;
    signal f_pic_ex5_k_int_maxpos                   :std_ulogic ;
    signal f_pic_ex5_k_int_maxneg                   :std_ulogic ;
    signal f_pic_ex5_k_int_zer                      :std_ulogic ;
    signal f_pic_ex5_ox_pipe_v_b                    :std_ulogic ;
    signal f_pic_ex5_round_sign                     :std_ulogic ;
    signal f_pic_ex5_scr_upd_move_b                 :std_ulogic ;
    signal f_pic_ex5_scr_upd_pipe_b                 :std_ulogic ;
    signal f_pic_ex5_ux_pipe_v_b                    :std_ulogic ;
    signal f_pic_fmt_ex1_act                        :std_ulogic ;
    signal f_pic_lza_ex1_act_b                      :std_ulogic ;
    signal f_pic_mul_ex1_act                        :std_ulogic ;
    signal f_pic_nrm_ex3_act_b                      :std_ulogic ;
    signal f_pic_rnd_ex3_act_b                      :std_ulogic ;
    signal f_pic_scr_ex2_act_b                      :std_ulogic ;
    signal f_eie_ex2_dw_ov                          :std_ulogic ;
    signal f_eie_ex2_dw_ov_if                       :std_ulogic ;
    signal f_eie_ex2_lzo_expo                       :std_ulogic_vector (1 to 13)    ;
    signal f_eie_ex2_b_expo                         :std_ulogic_vector (1 to 13)    ;
    signal f_eie_ex2_tbl_expo                       :std_ulogic_vector (1 to 13)    ;
    signal f_eie_ex2_wd_ov                          :std_ulogic ;
    signal f_eie_ex2_wd_ov_if                       :std_ulogic ;
    signal f_eie_ex3_iexp                           :std_ulogic_vector (1 to 13)    ;
    signal f_eov_ex5_expo_p0                        :std_ulogic_vector (1 to 13)    ;
    signal f_eov_ex5_expo_p0_ue1oe1                 :std_ulogic_vector (3 to 7)     ;
    signal f_eov_ex5_expo_p1                        :std_ulogic_vector (1 to 13)    ;
    signal f_eov_ex5_expo_p1_ue1oe1                 :std_ulogic_vector (3 to 7)     ;
    signal f_eov_ex5_ovf_expo                       :std_ulogic ;
    signal f_eov_ex5_ovf_if_expo                    :std_ulogic ;
    signal f_eov_ex5_sel_k_e                        :std_ulogic ;
    signal f_eov_ex5_sel_k_f                        :std_ulogic ;
    signal f_eov_ex5_sel_kif_e                      :std_ulogic ;
    signal f_eov_ex5_sel_kif_f                      :std_ulogic ;
    signal f_eov_ex5_unf_expo                       :std_ulogic ;
    signal f_fmt_ex1_a_expo_max                     :std_ulogic ;
    signal f_fmt_ex1_a_zero                         :std_ulogic ;
    signal f_fmt_ex1_a_frac_msb                     :std_ulogic ;
    signal f_fmt_ex1_a_frac_zero                    :std_ulogic ;
    signal f_fmt_ex1_b_expo_max                     :std_ulogic ;
    signal f_fmt_ex1_b_zero                         :std_ulogic ;
    signal f_fmt_ex1_b_frac_msb                     :std_ulogic ;
    signal f_fmt_ex1_b_frac_z32                     :std_ulogic;
    signal f_fmt_ex1_b_frac_zero                    :std_ulogic ;
    signal f_fmt_ex1_bop_byt                        :std_ulogic_vector(45 to 52)    ;
    signal f_fmt_ex1_c_expo_max                     :std_ulogic ;
    signal f_fmt_ex1_c_zero                         :std_ulogic ;
    signal f_fmt_ex1_c_frac_msb                     :std_ulogic ;
    signal f_fmt_ex1_c_frac_zero                    :std_ulogic ;
    signal f_fmt_ex1_sp_invalid                     :std_ulogic ;
    signal f_fmt_ex1_pass_sel                       :std_ulogic ;
    signal f_fmt_ex1_prod_zero                      :std_ulogic ;
    signal f_fmt_ex2_fsel_bsel                      :std_ulogic ;
    signal f_fmt_ex2_pass_frac                      :std_ulogic_vector (0 to 52)    ;
    signal f_fmt_ex2_pass_sign                      :std_ulogic ;
    signal f_fmt_ex2_pass_msb                       :std_ulogic ;
    signal f_fmt_ex1_b_imp                          :std_ulogic ;
    signal f_lza_ex4_lza_amt                        :std_ulogic_vector (0 to 7)     ;
    signal f_lza_ex4_lza_dcd64_cp1                  :std_ulogic_vector(0 to 2);
    signal f_lza_ex4_lza_dcd64_cp2                  :std_ulogic_vector(0 to 1);
    signal f_lza_ex4_lza_dcd64_cp3                  :std_ulogic_vector(0 to 0);     
    signal f_lza_ex4_sh_rgt_en                      :std_ulogic; 
    signal f_lza_ex4_sh_rgt_en_eov                  :std_ulogic; 
    signal f_lza_ex4_lza_amt_eov                    :std_ulogic_vector (0 to 7)     ;
    signal f_lza_ex4_no_lza_edge                    :std_ulogic ;
    signal f_mul_ex2_car                            :std_ulogic_vector (1 to 108)   ;
    signal f_mul_ex2_sum                            :std_ulogic_vector (1 to 108)   ;
    signal f_nrm_ex4_extra_shift                    :std_ulogic ;
    signal f_nrm_ex5_exact_zero                     :std_ulogic ;
    signal f_nrm_ex5_fpscr_wr_dat                   :std_ulogic_vector (0 to 31)    ;
    signal f_nrm_ex5_fpscr_wr_dat_dfp               :std_ulogic_vector (0 to 3)    ;
    signal f_nrm_ex5_int_lsbs                       :std_ulogic_vector (1 to 12)    ;
    signal f_nrm_ex5_int_sign                       :std_ulogic;
    signal f_nrm_ex5_nrm_guard_dp                   :std_ulogic ;
    signal f_nrm_ex5_nrm_guard_sp                   :std_ulogic ;
    signal f_nrm_ex5_nrm_lsb_dp                     :std_ulogic ;
    signal f_nrm_ex5_nrm_lsb_sp                     :std_ulogic ;
    signal f_nrm_ex5_nrm_sticky_dp                  :std_ulogic ;
    signal f_nrm_ex5_nrm_sticky_sp                  :std_ulogic ;
    signal f_nrm_ex5_res                            :std_ulogic_vector (0 to 52)    ;
    signal f_rnd_ex6_flag_den                       :std_ulogic ;
    signal f_rnd_ex6_flag_fi                        :std_ulogic ;
    signal f_rnd_ex6_flag_inf                       :std_ulogic ;
    signal f_rnd_ex6_flag_ox                        :std_ulogic ;
    signal f_rnd_ex6_flag_sgn                       :std_ulogic ;
    signal f_rnd_ex6_flag_up                        :std_ulogic ;
    signal f_rnd_ex6_flag_ux                        :std_ulogic ;
    signal f_rnd_ex6_flag_zer                       :std_ulogic ;
    signal f_sa3_ex3_c_lza                          :std_ulogic_vector (53 to 161)  ;
    signal f_sa3_ex3_s_lza                          :std_ulogic_vector (0 to 162)  ;
    signal f_sa3_ex3_c_add                          :std_ulogic_vector (53 to 161)  ;
    signal f_sa3_ex3_s_add                          :std_ulogic_vector (0 to 162)  ;
    signal f_scr_ex5_fpscr_rd_dat_dfp               :std_ulogic_vector (0 to 3)     ;
    signal f_scr_ex5_fpscr_rd_dat                   :std_ulogic_vector (0 to 31)    ;
    signal f_cr2_ex5_fpscr_rd_dat                   :std_ulogic_vector (24 to 31)    ;
    signal f_cr2_ex6_fpscr_rd_dat                   :std_ulogic_vector (24 to 31)    ;
    signal f_pic_tbl_ex1_act                        :std_ulogic;


    signal f_pic_ex2_math_bzer_b  :std_ulogic;
    signal perv_sa3_thold_1  :std_ulogic;
    signal perv_sa3_sg_1     :std_ulogic;
    signal perv_sa3_fpu_enable :std_ulogic;
    signal f_pic_ex2_b_valid   :std_ulogic;
    signal f_alg_ex2_byp_nonflip   :std_ulogic;
    signal f_pic_ex1_rnd_to_int :std_ulogic;
    signal f_eie_ex2_lt_bias :std_ulogic;
    signal f_eie_ex2_eq_bias_m1 :std_ulogic;
    signal f_pic_ex2_est_recip :std_ulogic;
    signal f_pic_ex2_est_rsqrt :std_ulogic;
signal f_tbe_ex3_may_ov :std_ulogic;
signal f_tbe_ex3_res_expo :std_ulogic_vector(1 to 13);
signal perv_tbe_sg_1, perv_tbe_thold_1, perv_tbe_fpu_enable :std_ulogic;
signal perv_tbl_sg_1, perv_tbl_thold_1, perv_tbl_fpu_enable :std_ulogic;
signal f_tbe_ex3_recip_2046 :std_ulogic;
signal f_tbe_ex3_recip_2045 :std_ulogic;
signal f_fmt_ex1_b_frac :std_ulogic_vector(1 to 19);
signal f_tbl_ex5_est_frac :std_ulogic_vector(0 to 26);
signal f_tbl_ex5_recip_den :std_ulogic;
signal f_eie_ex2_use_bexp :std_ulogic;
signal rnd_ex6_res_sign            :std_ulogic;
signal rnd_ex6_res_expo            :std_ulogic_vector(1 to 13);
signal rnd_ex6_res_frac            :std_ulogic_vector(0 to 52);
signal f_pic_ex1_flush_en_dp, f_pic_ex1_flush_en_sp, f_pic_ex1_ftdiv :std_ulogic; 
signal f_fmt_ex2_lu_den_recip , f_fmt_ex2_lu_den_rsqrto :std_ulogic;
signal f_tbe_ex3_recip_2044, f_tbe_ex3_lu_sh :std_ulogic;

signal f_lze_ex2_lzo_din :std_ulogic_vector(0 to 162);               
signal f_lze_ex3_sh_rgt_amt :std_ulogic_vector(0 to 7) ;
signal f_lze_ex3_sh_rgt_en       :std_ulogic; 
signal f_alg_ex1_sign_frmw :std_ulogic;
signal f_tbe_ex3_match_en_sp ,  f_tbe_ex3_match_en_dp  :std_ulogic;
signal f_tbl_ex4_unf_expo     :std_ulogic;
signal f_tbe_ex3_recip_ue1    :std_ulogic ;
signal f_fmt_ex1_bexpu_le126  :std_ulogic ;
signal f_fmt_ex1_gt126        :std_ulogic ;
signal f_fmt_ex1_ge128        :std_ulogic ;
signal f_gst_ex5_logexp_v        :std_ulogic         ;
signal f_gst_ex5_logexp_sign     :std_ulogic         ;
signal f_gst_ex5_logexp_exp      :std_ulogic_vector(1 to 11);
signal f_gst_ex5_logexp_fract    :std_ulogic_vector(0 to 19);
signal f_fmt_ex1_b_sign_gst      :std_ulogic;
signal f_fmt_ex1_b_expo_gst_b    :std_ulogic_vector(1 to 13);
signal f_pic_ex1_log2e           :std_ulogic;
signal f_pic_ex1_pow2e           :std_ulogic;
signal f_mad_ex2_uc_a_expo_den , f_mad_ex2_uc_a_expo_den_sp :std_ulogic; 
signal f_pic_ex1_nj_deni :std_ulogic;
signal f_fmt_ex2_ae_ge_54, f_fmt_ex2_be_ge_54, f_fmt_ex2_be_ge_2, f_fmt_ex2_be_ge_2044, f_fmt_ex2_tdiv_rng_chk :std_ulogic ;
signal f_fmt_ex2_be_den :std_ulogic;


begin





fbyp : entity WORK.fuq_byp(fuq_byp) generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(1)              ,
        mpw1_b                                           => mpw1_b(1)                   ,
        mpw2_b                                           => mpw2_b(0)                   ,
        thold_1                                          => perv_fmt_thold_1         ,
        sg_1                                             => perv_fmt_sg_1            ,
        fpu_enable                                       => perv_fmt_fpu_enable      ,

        f_byp_si                                         => scan_in(0)               ,
        f_byp_so                                         => scan_out(0)              ,
        rf1_act                                          => f_dcd_rf1_act            ,

        f_fpr_ex7_frt_sign                               => f_fpr_ex7_frt_sign             ,
        f_fpr_ex7_frt_expo(1 to 13)                      => f_fpr_ex7_frt_expo(1 to 13)    ,
        f_fpr_ex7_frt_frac(0 to 52)                      => f_fpr_ex7_frt_frac(0 to 52)    ,
        f_fpr_ex7_load_sign                              => f_fpr_ex7_load_sign            ,
        f_fpr_ex7_load_expo(3 to 13)                     => f_fpr_ex7_load_expo(3 to 13)   ,
        f_fpr_ex7_load_frac(0 to 52)                     => f_fpr_ex7_load_frac(0 to 52)   ,

        f_dcd_rf1_div_beg                                => f_dcd_rf1_div_beg          ,
        f_dcd_rf1_uc_fa_pos                              => f_dcd_rf1_uc_fa_pos        ,
        f_dcd_rf1_uc_fc_pos                              => f_dcd_rf1_uc_fc_pos        ,
        f_dcd_rf1_uc_fb_pos                              => f_dcd_rf1_uc_fb_pos        ,
        f_dcd_rf1_uc_fc_0_5                              => f_dcd_rf1_uc_fc_0_5        ,
        f_dcd_rf1_uc_fc_1_0                              => f_dcd_rf1_uc_fc_1_0        ,
        f_dcd_rf1_uc_fc_1_minus                          => f_dcd_rf1_uc_fc_1_minus    ,
        f_dcd_rf1_uc_fb_1_0                              => f_dcd_rf1_uc_fb_1_0        ,
        f_dcd_rf1_uc_fb_0_75                             => f_dcd_rf1_uc_fb_0_75       ,
        f_dcd_rf1_uc_fb_0_5                              => f_dcd_rf1_uc_fb_0_5        ,

       f_dcd_rf1_uc_fc_hulp                              => f_dcd_rf1_uc_fc_hulp      ,
       f_dcd_rf1_bypsel_a_res0                           => f_dcd_rf1_bypsel_a_res0   ,
       f_dcd_rf1_bypsel_a_res1                           => f_dcd_rf1_bypsel_a_res1   ,
       f_dcd_rf1_bypsel_a_load0                          => f_dcd_rf1_bypsel_a_load0  ,
       f_dcd_rf1_bypsel_a_load1                          => f_dcd_rf1_bypsel_a_load1  ,
       f_dcd_rf1_bypsel_b_res0                           => f_dcd_rf1_bypsel_b_res0   ,
       f_dcd_rf1_bypsel_b_res1                           => f_dcd_rf1_bypsel_b_res1   ,
       f_dcd_rf1_bypsel_b_load0                          => f_dcd_rf1_bypsel_b_load0  ,
       f_dcd_rf1_bypsel_b_load1                          => f_dcd_rf1_bypsel_b_load1  ,
       f_dcd_rf1_bypsel_c_res0                           => f_dcd_rf1_bypsel_c_res0   ,
       f_dcd_rf1_bypsel_c_res1                           => f_dcd_rf1_bypsel_c_res1   ,
       f_dcd_rf1_bypsel_c_load0                          => f_dcd_rf1_bypsel_c_load0  ,
       f_dcd_rf1_bypsel_c_load1                          => f_dcd_rf1_bypsel_c_load1  ,

        f_rnd_ex6_res_sign                               => rnd_ex6_res_sign                                  ,
        f_rnd_ex6_res_expo(1 to 13)                      => rnd_ex6_res_expo(1 to 13)                         ,
        f_rnd_ex6_res_frac(0 to 52)                      => rnd_ex6_res_frac(0 to 52)                         ,
        f_fpr_ex6_load_sign                              => f_fpr_ex6_load_sign                               ,
        f_fpr_ex6_load_expo(3 to 13)                     => f_fpr_ex6_load_expo(3 to 13)                      ,
        f_fpr_ex6_load_frac(0 to 52)                     => f_fpr_ex6_load_frac(0 to 52)                      ,
        f_fpr_rf1_a_sign                                 => f_fpr_rf1_a_sign                                  ,
        f_fpr_rf1_a_expo(1 to 13)                        => f_fpr_rf1_a_expo(1 to 13)                         ,
        f_fpr_rf1_a_frac(0 to 52)                        => f_fpr_rf1_a_frac(0 to 52)                         ,
        f_fpr_rf1_c_sign                                 => f_fpr_rf1_c_sign                                  ,
        f_fpr_rf1_c_expo(1 to 13)                        => f_fpr_rf1_c_expo(1 to 13)                         ,
        f_fpr_rf1_c_frac(0 to 52)                        => f_fpr_rf1_c_frac(0 to 52)                         ,
        f_fpr_rf1_b_sign                                 => f_fpr_rf1_b_sign                                  ,
        f_fpr_rf1_b_expo(1 to 13)                        => f_fpr_rf1_b_expo(1 to 13)                         ,
        f_fpr_rf1_b_frac(0 to 52)                        => f_fpr_rf1_b_frac(0 to 52)                         ,
        f_dcd_rf1_aop_valid                              => f_dcd_rf1_aop_valid                               ,
        f_dcd_rf1_cop_valid                              => f_dcd_rf1_cop_valid                               ,
        f_dcd_rf1_bop_valid                              => f_dcd_rf1_bop_valid                               ,
        f_dcd_rf1_sp                                     => f_dcd_rf1_sp                                      ,
        f_dcd_rf1_to_integer_b                           => f_dcd_rf1_to_integer_b                            ,
        f_dcd_rf1_emin_dp                                => f_dcd_rf1_emin_dp                                 ,
        f_dcd_rf1_emin_sp                                => f_dcd_rf1_emin_sp                                 ,

        f_byp_fmt_ex1_a_expo(1 to 13)                    => f_byp_fmt_ex1_a_expo(1 to 13)                     ,
        f_byp_eie_ex1_a_expo(1 to 13)                    => f_byp_eie_ex1_a_expo(1 to 13)                     ,
        f_byp_alg_ex1_a_expo(1 to 13)                    => f_byp_alg_ex1_a_expo(1 to 13)                     ,
        f_byp_fmt_ex1_c_expo(1 to 13)                    => f_byp_fmt_ex1_c_expo(1 to 13)                     ,
        f_byp_eie_ex1_c_expo(1 to 13)                    => f_byp_eie_ex1_c_expo(1 to 13)                     ,
        f_byp_alg_ex1_c_expo(1 to 13)                    => f_byp_alg_ex1_c_expo(1 to 13)                     ,
        f_byp_fmt_ex1_b_expo(1 to 13)                    => f_byp_fmt_ex1_b_expo(1 to 13)                     ,
        f_byp_eie_ex1_b_expo(1 to 13)                    => f_byp_eie_ex1_b_expo(1 to 13)                     ,
        f_byp_alg_ex1_b_expo(1 to 13)                    => f_byp_alg_ex1_b_expo(1 to 13)                     ,
        f_byp_fmt_ex1_a_sign                             => f_byp_fmt_ex1_a_sign                              ,
        f_byp_fmt_ex1_c_sign                             => f_byp_fmt_ex1_c_sign                              ,
        f_byp_fmt_ex1_b_sign                             => f_byp_fmt_ex1_b_sign                              ,
        f_byp_pic_ex1_a_sign                             => f_byp_pic_ex1_a_sign                              ,
        f_byp_pic_ex1_c_sign                             => f_byp_pic_ex1_c_sign                              ,
        f_byp_pic_ex1_b_sign                             => f_byp_pic_ex1_b_sign                              ,
        f_byp_alg_ex1_b_sign                             => f_byp_alg_ex1_b_sign                              ,
        f_byp_mul_ex1_a_frac_17                          => f_byp_mul_ex1_a_frac_17                           ,
        f_byp_mul_ex1_a_frac_35                          => f_byp_mul_ex1_a_frac_35                           ,
        f_byp_mul_ex1_a_frac(0 to 52)                    => f_byp_mul_ex1_a_frac(0 to 52)                     ,
        f_byp_fmt_ex1_a_frac(0 to 52)                    => f_byp_fmt_ex1_a_frac(0 to 52)                     ,
        f_byp_mul_ex1_c_frac(0 to 52)                    => f_byp_mul_ex1_c_frac(0 to 52)                     ,
        f_byp_mul_ex1_c_frac(53)                         => f_byp_mul_ex1_c_frac(53)                          ,
        f_byp_fmt_ex1_c_frac(0 to 52)                    => f_byp_fmt_ex1_c_frac(0 to 52)                     ,
        f_byp_alg_ex1_b_frac(0 to 52)                    => f_byp_alg_ex1_b_frac(0 to 52)                     ,
        f_byp_fmt_ex1_b_frac(0 to 52)                    => f_byp_fmt_ex1_b_frac(0 to 52)                    );



ffmt : entity WORK.fuq_fmt(fuq_fmt)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(1 to 2)              ,
        mpw1_b                                           => mpw1_b(1 to 2)                   ,
        mpw2_b                                           => mpw2_b(0 to 0)                   ,
        thold_1                                          => perv_fmt_thold_1         ,
        sg_1                                             => perv_fmt_sg_1            ,
        fpu_enable                                       => perv_fmt_fpu_enable      ,

        f_fmt_si                                         => scan_in(1)                                        ,
        f_fmt_so                                         => scan_out(1)                                       ,
        rf1_act                                          => f_dcd_rf1_act                                     ,
        ex1_act                                          => f_pic_fmt_ex1_act                                 ,

        f_fpr_ex1_a_par(0 to 7)                          => f_fpr_ex1_a_par(0 to 7)                           ,
        f_fpr_ex1_c_par(0 to 7)                          => f_fpr_ex1_c_par(0 to 7)                           ,
        f_fpr_ex1_b_par(0 to 7)                          => f_fpr_ex1_b_par(0 to 7)                           ,

        f_mad_ex2_a_parity_check                         => f_mad_ex2_a_parity_check                          ,
        f_mad_ex2_c_parity_check                         => f_mad_ex2_c_parity_check                          ,
        f_mad_ex2_b_parity_check                         => f_mad_ex2_b_parity_check                          ,
        f_fmt_ex2_ae_ge_54                               => f_fmt_ex2_ae_ge_54                                ,
        f_fmt_ex2_be_ge_54                               => f_fmt_ex2_be_ge_54                                ,
        f_fmt_ex2_be_ge_2                                => f_fmt_ex2_be_ge_2                                 ,
        f_fmt_ex2_be_ge_2044                             => f_fmt_ex2_be_ge_2044                              ,
        f_fmt_ex2_tdiv_rng_chk                           => f_fmt_ex2_tdiv_rng_chk                            ,
        f_fmt_ex2_be_den                                 => f_fmt_ex2_be_den                                  ,
        f_byp_fmt_ex1_a_sign                             => f_byp_fmt_ex1_a_sign                              ,
        f_byp_fmt_ex1_c_sign                             => f_byp_fmt_ex1_c_sign                              ,
        f_byp_fmt_ex1_b_sign                             => f_byp_fmt_ex1_b_sign                              ,
        f_byp_fmt_ex1_a_expo(1 to 13)                    => f_byp_fmt_ex1_a_expo(1 to 13)                     ,
        f_byp_fmt_ex1_c_expo(1 to 13)                    => f_byp_fmt_ex1_c_expo(1 to 13)                     ,
        f_byp_fmt_ex1_b_expo(1 to 13)                    => f_byp_fmt_ex1_b_expo(1 to 13)                     ,

        f_byp_fmt_ex1_a_frac(0 to 52)                    => f_byp_fmt_ex1_a_frac(0 to 52)                     ,
        f_byp_fmt_ex1_c_frac(0 to 52)                    => f_byp_fmt_ex1_c_frac(0 to 52)                     ,
        f_byp_fmt_ex1_b_frac(0 to 52)                    => f_byp_fmt_ex1_b_frac(0 to 52)                     ,

        f_dcd_rf1_sp                                     => f_dcd_rf1_sp                                      ,
        f_dcd_rf1_from_integer_b                         => f_dcd_rf1_from_integer_b                          ,
        f_dcd_rf1_sgncpy_b                               => f_dcd_rf1_sgncpy_b                                ,
        f_dcd_rf1_uc_mid                                 => f_dcd_rf1_uc_mid                                  ,
        f_dcd_rf1_uc_end                                 => f_dcd_rf1_uc_end                                  ,
        f_dcd_rf1_uc_special                             => f_dcd_rf1_uc_special                              ,
        f_dcd_rf1_aop_valid                              => f_dcd_rf1_aop_valid                               ,
        f_dcd_rf1_cop_valid                              => f_dcd_rf1_cop_valid                               ,
        f_dcd_rf1_bop_valid                              => f_dcd_rf1_bop_valid                               ,
        f_dcd_rf1_fsel_b                                 => f_dcd_rf1_fsel_b                                  ,
        f_dcd_rf1_force_pass_b                           => f_dcd_rf1_force_pass_b                            ,
        f_dcd_ex1_perr_force_c                           => f_dcd_ex1_perr_force_c                            ,
        f_dcd_ex1_perr_fsel_ovrd                         => f_dcd_ex1_perr_fsel_ovrd                          ,
        f_pic_ex1_ftdiv                                  => f_pic_ex1_ftdiv                                   ,
        f_pic_ex1_flush_en_sp                            => f_pic_ex1_flush_en_sp                             ,
        f_pic_ex1_flush_en_dp                            => f_pic_ex1_flush_en_dp                             ,
        f_pic_ex1_nj_deni                                => f_pic_ex1_nj_deni                                 ,
        f_fmt_ex2_lu_den_recip                           => f_fmt_ex2_lu_den_recip                            ,
        f_fmt_ex2_lu_den_rsqrto                          => f_fmt_ex2_lu_den_rsqrto                           ,
        f_fmt_ex1_bop_byt(45 to 52)                      => f_fmt_ex1_bop_byt(45 to 52)                       ,
        f_fmt_ex1_b_frac(1 to 19)                        => f_fmt_ex1_b_frac(1 to 19)                         ,
        f_fmt_ex1_bexpu_le126                            => f_fmt_ex1_bexpu_le126                             ,
        f_fmt_ex1_gt126                                  => f_fmt_ex1_gt126                                   ,
        f_fmt_ex1_ge128                                  => f_fmt_ex1_ge128                                   ,
        f_fmt_ex1_inf_and_beyond_sp                      => f_fmt_ex1_inf_and_beyond_sp                       ,

        f_fmt_ex1_b_sign_gst                             => f_fmt_ex1_b_sign_gst                              ,
        f_fmt_ex1_b_expo_gst_b(1 to 13)                  => f_fmt_ex1_b_expo_gst_b(1 to 13)                   ,
        f_mad_ex2_uc_a_expo_den                          => f_mad_ex2_uc_a_expo_den                           ,
        f_mad_ex2_uc_a_expo_den_sp                       => f_mad_ex2_uc_a_expo_den_sp                        ,
        f_fmt_ex1_a_zero                                 => f_fmt_ex1_a_zero                                  ,
        f_fmt_ex1_a_expo_max                             => f_fmt_ex1_a_expo_max                              ,
        f_fmt_ex1_a_frac_zero                            => f_fmt_ex1_a_frac_zero                             ,
        f_fmt_ex1_a_frac_msb                             => f_fmt_ex1_a_frac_msb                              ,
        f_fmt_ex1_c_zero                                 => f_fmt_ex1_c_zero                                  ,
        f_fmt_ex1_c_expo_max                             => f_fmt_ex1_c_expo_max                              ,
        f_fmt_ex1_c_frac_zero                            => f_fmt_ex1_c_frac_zero                             ,
        f_fmt_ex1_c_frac_msb                             => f_fmt_ex1_c_frac_msb                              ,
        f_fmt_ex1_b_zero                                 => f_fmt_ex1_b_zero                                  ,
        f_fmt_ex1_b_expo_max                             => f_fmt_ex1_b_expo_max                              ,
        f_fmt_ex1_b_frac_zero                            => f_fmt_ex1_b_frac_zero                             ,
        f_fmt_ex1_b_frac_msb                             => f_fmt_ex1_b_frac_msb                              ,
        f_fmt_ex1_b_frac_z32                             => f_fmt_ex1_b_frac_z32                              ,
        f_fmt_ex1_prod_zero                              => f_fmt_ex1_prod_zero                               ,
        f_fmt_ex1_pass_sel                               => f_fmt_ex1_pass_sel                                ,
        f_fmt_ex1_sp_invalid                             => f_fmt_ex1_sp_invalid                              ,
        f_ex2_b_den_flush                                => f_ex2_b_den_flush                                 ,
        f_fmt_ex2_fsel_bsel                              => f_fmt_ex2_fsel_bsel                               ,
        f_fmt_ex2_pass_sign                              => f_fmt_ex2_pass_sign                               ,
        f_fmt_ex2_pass_msb                               => f_fmt_ex2_pass_msb                                ,
        f_fmt_ex1_b_imp                                  => f_fmt_ex1_b_imp                                   ,
        f_fmt_ex2_pass_frac(0 to 52)                     => f_fmt_ex2_pass_frac(0 to 52)                     );





feie : entity WORK.fuq_eie(fuq_eie)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(2 to 3)              ,
        mpw1_b                                           => mpw1_b(2 to 3)                   ,
        mpw2_b                                           => mpw2_b(0 to 0)                   ,
        thold_1                                          => perv_eie_thold_1         ,
        sg_1                                             => perv_eie_sg_1            ,
        fpu_enable                                       => perv_eie_fpu_enable      ,

        f_eie_si                                         => scan_in(2)                                        ,
        f_eie_so                                         => scan_out(2)                                       ,
        ex1_act                                          => f_pic_eie_ex1_act                                 ,
        f_byp_eie_ex1_a_expo(1 to 13)                    => f_byp_eie_ex1_a_expo(1 to 13)                     ,
        f_byp_eie_ex1_c_expo(1 to 13)                    => f_byp_eie_ex1_c_expo(1 to 13)                     ,
        f_byp_eie_ex1_b_expo(1 to 13)                    => f_byp_eie_ex1_b_expo(1 to 13)                     ,
        f_pic_ex1_from_integer                           => f_pic_ex1_from_integer                            ,
        f_pic_ex1_fsel                                   => f_pic_ex1_fsel                                    ,
        f_pic_ex2_frsp_ue1                               => f_pic_ex2_frsp_ue1                                ,
        f_alg_ex2_sel_byp                                => f_alg_ex2_sel_byp                                 ,
        f_fmt_ex2_fsel_bsel                              => f_fmt_ex2_fsel_bsel                               ,
        f_pic_ex2_force_sel_bexp                         => f_pic_ex2_force_sel_bexp                          ,
        f_pic_ex2_sp_b                                   => f_pic_ex2_sp_b                                    ,
        f_pic_ex2_math_bzer_b                            => f_pic_ex2_math_bzer_b                             ,
        f_eie_ex2_lt_bias                                => f_eie_ex2_lt_bias                                 ,
        f_eie_ex2_eq_bias_m1                             => f_eie_ex2_eq_bias_m1                              ,
        f_eie_ex2_wd_ov                                  => f_eie_ex2_wd_ov                                   ,
        f_eie_ex2_dw_ov                                  => f_eie_ex2_dw_ov                                   ,
        f_eie_ex2_wd_ov_if                               => f_eie_ex2_wd_ov_if                                ,
        f_eie_ex2_dw_ov_if                               => f_eie_ex2_dw_ov_if                                ,
        f_eie_ex2_lzo_expo(1 to 13)                      => f_eie_ex2_lzo_expo(1 to 13)                       ,
        f_eie_ex2_b_expo(1 to 13)                        => f_eie_ex2_b_expo(1 to 13)                         ,
        f_eie_ex2_use_bexp                               => f_eie_ex2_use_bexp                                ,
        f_eie_ex2_tbl_expo(1 to 13)                      => f_eie_ex2_tbl_expo(1 to 13)                       ,
        f_eie_ex3_iexp(1 to 13)                          => f_eie_ex3_iexp(1 to 13)                          );



feov : entity WORK.fuq_eov(fuq_eov)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(4 to 5)              ,
        mpw1_b                                           => mpw1_b(4 to 5)                   ,
        mpw2_b                                           => mpw2_b(0 to 1)                   ,
        thold_1                                          => perv_eov_thold_1         ,
        sg_1                                             => perv_eov_sg_1            ,
        fpu_enable                                       => perv_eov_fpu_enable      ,

        f_eov_si                                         => scan_in(3)                                        ,
        f_eov_so                                         => scan_out(3)                                       ,
        ex2_act_b                                        => f_pic_eov_ex2_act_b                               ,
        f_tbl_ex4_unf_expo                               => f_tbl_ex4_unf_expo                                ,
        f_tbe_ex3_may_ov                                 => f_tbe_ex3_may_ov                                  ,
        f_tbe_ex3_expo(1 to 13)                          => f_tbe_ex3_res_expo(1 to 13)                       ,
        f_pic_ex3_sel_est                                => f_pic_ex3_sel_est                                 ,
        f_eie_ex3_iexp(1 to 13)                          => f_eie_ex3_iexp(1 to 13)                           ,
        f_pic_ex3_sp_b                                   => f_pic_ex3_sp_b                                    ,
        f_lza_ex4_sh_rgt_en_eov                          => f_lza_ex4_sh_rgt_en_eov                           ,
        f_pic_ex4_oe                                     => f_pic_ex4_oe                                      ,
        f_pic_ex4_ue                                     => f_pic_ex4_ue                                      ,
        f_pic_ex4_ov_en                                  => f_pic_ex4_ov_en                                   ,
        f_pic_ex4_uf_en                                  => f_pic_ex4_uf_en                                   ,
        f_pic_ex4_spec_sel_k_e                           => f_pic_ex4_spec_sel_k_e                            ,
        f_pic_ex4_spec_sel_k_f                           => f_pic_ex4_spec_sel_k_f                            ,
        f_pic_ex4_sel_ov_spec                            => tidn                                              ,

        f_pic_ex4_to_int_ov_all                          => f_pic_ex4_to_int_ov_all                           ,

        f_lza_ex4_no_lza_edge                            => f_lza_ex4_no_lza_edge                             ,
        f_lza_ex4_lza_amt_eov(0 to 7)                    => f_lza_ex4_lza_amt_eov(0 to 7)                     ,
        f_nrm_ex4_extra_shift                            => f_nrm_ex4_extra_shift                             ,
        f_eov_ex4_may_ovf                                => f_eov_ex4_may_ovf                                 ,
        f_eov_ex5_sel_k_f                                => f_eov_ex5_sel_k_f                                 ,
        f_eov_ex5_sel_k_e                                => f_eov_ex5_sel_k_e                                 ,
        f_eov_ex5_sel_kif_f                              => f_eov_ex5_sel_kif_f                               ,
        f_eov_ex5_sel_kif_e                              => f_eov_ex5_sel_kif_e                               ,
        f_eov_ex5_unf_expo                               => f_eov_ex5_unf_expo                                ,
        f_eov_ex5_ovf_expo                               => f_eov_ex5_ovf_expo                                ,
        f_eov_ex5_ovf_if_expo                            => f_eov_ex5_ovf_if_expo                             ,
        f_eov_ex5_expo_p0(1 to 13)                       => f_eov_ex5_expo_p0(1 to 13)                        ,
        f_eov_ex5_expo_p1(1 to 13)                       => f_eov_ex5_expo_p1(1 to 13)                        ,
        f_eov_ex5_expo_p0_ue1oe1(3 to 7)                 => f_eov_ex5_expo_p0_ue1oe1(3 to 7)                  ,
        f_eov_ex5_expo_p1_ue1oe1(3 to 7)                 => f_eov_ex5_expo_p1_ue1oe1(3 to 7)                 );


fmul : entity WORK.fuq_mul(fuq_mul)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(2)              ,
        mpw1_b                                           => mpw1_b(2)                   ,
        mpw2_b                                           => mpw2_b(0)                   ,
        thold_1                                          => perv_mul_thold_1         ,
        sg_1                                             => perv_mul_sg_1            ,
        fpu_enable                                       => perv_mul_fpu_enable      ,

        f_mul_si                                         => scan_in(4)                                        ,
        f_mul_so                                         => scan_out(4)                                       ,
        ex1_act                                          => f_pic_mul_ex1_act                                 ,
        f_fmt_ex1_a_frac(0 to 52)                        => f_byp_mul_ex1_a_frac(0 to 52)                     ,
        f_fmt_ex1_a_frac_17                              => f_byp_mul_ex1_a_frac_17                           ,
        f_fmt_ex1_a_frac_35                              => f_byp_mul_ex1_a_frac_35                           ,
        f_fmt_ex1_c_frac(0 to 53)                        => f_byp_mul_ex1_c_frac(0 to 53)                     ,
        f_mul_ex2_sum(1 to 108)                          => f_mul_ex2_sum(1 to 108)                           ,
        f_mul_ex2_car(1 to 108)                          => f_mul_ex2_car(1 to 108)                          );


falg : entity WORK.fuq_alg(fuq_alg)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(1 to 3)              ,
        mpw1_b                                           => mpw1_b(1 to 3)                   ,
        mpw2_b                                           => mpw2_b(0 to 0)                   ,
        thold_1                                          => perv_alg_thold_1         ,
        sg_1                                             => perv_alg_sg_1            ,
        fpu_enable                                       => perv_alg_fpu_enable      ,

        f_alg_si                                         => scan_in(5)                                        ,
        f_alg_so                                         => scan_out(5)                                       ,
        rf1_act                                          => f_dcd_rf1_act                                     ,
        ex1_act                                          => f_pic_alg_ex1_act                                 ,
        f_dcd_rf1_sp                                     => f_dcd_rf1_sp                                      ,

        f_pic_ex1_frsp_ue1                               => f_pic_ex1_frsp_ue1                               ,

        f_byp_alg_ex1_b_frac(0 to 52)                    => f_byp_alg_ex1_b_frac(0 to 52)                     ,
        f_byp_alg_ex1_b_sign                             => f_byp_alg_ex1_b_sign                              ,
        f_byp_alg_ex1_b_expo(1 to 13)                    => f_byp_alg_ex1_b_expo(1 to 13)                     ,
        f_byp_alg_ex1_a_expo(1 to 13)                    => f_byp_alg_ex1_a_expo(1 to 13)                     ,
        f_byp_alg_ex1_c_expo(1 to 13)                    => f_byp_alg_ex1_c_expo(1 to 13)                     ,

        f_fmt_ex1_prod_zero                              => f_fmt_ex1_prod_zero                               ,
        f_fmt_ex1_b_zero                                 => f_fmt_ex1_b_zero                                  ,
        f_fmt_ex1_pass_sel                               => f_fmt_ex1_pass_sel                                ,
        f_fmt_ex2_pass_frac(0 to 52)                     => f_fmt_ex2_pass_frac(0 to 52)                      ,
        f_dcd_rf1_word_b                                 => f_dcd_rf1_word_b                                  ,
        f_dcd_rf1_uns_b                                  => f_dcd_rf1_uns_b                                   ,
        f_dcd_rf1_from_integer_b                         => f_dcd_rf1_from_integer_b                          ,
        f_dcd_rf1_to_integer_b                           => f_dcd_rf1_to_integer_b                            ,
        f_pic_ex1_rnd_to_int                             => f_pic_ex1_rnd_to_int                              ,
        f_pic_ex1_effsub_raw                             => f_pic_ex1_effsub_raw                              ,
        f_pic_ex1_sh_unf_ig_b                            => f_pic_ex1_sh_unf_ig_b                             ,
        f_pic_ex1_sh_unf_do                              => f_pic_ex1_sh_unf_do                               ,
        f_pic_ex1_sh_ovf_ig_b                            => f_pic_ex1_sh_ovf_ig_b                             ,
        f_pic_ex1_sh_ovf_do                              => f_pic_ex1_sh_ovf_do                               ,
        f_pic_ex2_rnd_nr                                 => f_pic_ex2_rnd_nr                                  ,
        f_pic_ex2_rnd_inf_ok                             => f_pic_ex2_rnd_inf_ok                              ,
        f_alg_ex1_sign_frmw                              => f_alg_ex1_sign_frmw                               ,
        f_alg_ex2_res(0 to 162)                          => f_alg_ex2_res(0 to 162)                           ,
        f_alg_ex2_sel_byp                                => f_alg_ex2_sel_byp                                 ,
        f_alg_ex2_effsub_eac_b                           => f_alg_ex2_effsub_eac_b                            ,
        f_alg_ex2_prod_z                                 => f_alg_ex2_prod_z                                  ,
        f_alg_ex2_sh_unf                                 => f_alg_ex2_sh_unf                                  ,
        f_alg_ex2_sh_ovf                                 => f_alg_ex2_sh_ovf                                  ,
        f_alg_ex2_byp_nonflip                            => f_alg_ex2_byp_nonflip                             ,
        f_alg_ex3_frc_sel_p1                             => f_alg_ex3_frc_sel_p1                              ,
        f_alg_ex3_sticky                                 => f_alg_ex3_sticky                                  ,
        f_alg_ex3_int_fr                                 => f_alg_ex3_int_fr                                  ,
        f_alg_ex3_int_fi                                 => f_alg_ex3_int_fi                                 );



fsa3 : entity WORK.fuq_sa3(fuq_sa3)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(2 to 3)              ,
        mpw1_b                                           => mpw1_b(2 to 3)                   ,
        mpw2_b                                           => mpw2_b(0 to 0)                   ,
        thold_1                                          => perv_sa3_thold_1         ,
        sg_1                                             => perv_sa3_sg_1            ,
        fpu_enable                                       => perv_sa3_fpu_enable      ,

        f_sa3_si                                         => scan_in(6)                                        ,
        f_sa3_so                                         => scan_out(6)                                       ,
        ex1_act_b                                        => f_pic_add_ex1_act_b                               ,
        f_mul_ex2_sum(54 to 161)                         => f_mul_ex2_sum(1 to 108)                           ,
        f_mul_ex2_car(54 to 161)                         => f_mul_ex2_car(1 to 108)                           ,
        f_alg_ex2_res(0  to 162)                         => f_alg_ex2_res(0  to 162)                          ,
        f_sa3_ex3_s_lza(0  to 162)                       => f_sa3_ex3_s_lza(0  to 162)                            ,
        f_sa3_ex3_c_lza(53 to 161)                       => f_sa3_ex3_c_lza(53 to 161)                            ,
        f_sa3_ex3_s_add(0  to 162)                       => f_sa3_ex3_s_add(0  to 162)                            ,
        f_sa3_ex3_c_add(53 to 161)                       => f_sa3_ex3_c_add(53 to 161)                           );



fadd : entity WORK.fuq_add(fuq_add)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(3 to 4)              ,
        mpw1_b                                           => mpw1_b(3 to 4)                   ,
        mpw2_b                                           => mpw2_b(0 to 0)                   ,
        thold_1                                          => perv_add_thold_1         ,
        sg_1                                             => perv_add_sg_1            ,
        fpu_enable                                       => perv_add_fpu_enable      ,

        f_add_si                                         => scan_in(7)                                        ,
        f_add_so                                         => scan_out(7)                                       ,
        ex1_act_b                                        => f_pic_add_ex1_act_b                               ,
        f_sa3_ex3_s(0 to 162)                            => f_sa3_ex3_s_add(0 to 162)                         ,
        f_sa3_ex3_c(53 to 161)                           => f_sa3_ex3_c_add(53 to 161)                        ,
        f_alg_ex3_frc_sel_p1                             => f_alg_ex3_frc_sel_p1                              ,
        f_alg_ex3_sticky                                 => f_alg_ex3_sticky                                  ,
        f_alg_ex2_effsub_eac_b                           => f_alg_ex2_effsub_eac_b                            ,
        f_alg_ex2_prod_z                                 => f_alg_ex2_prod_z                                  ,
        f_pic_ex3_is_gt                                  => f_pic_ex3_is_gt                                   ,
        f_pic_ex3_is_lt                                  => f_pic_ex3_is_lt                                   ,
        f_pic_ex3_is_eq                                  => f_pic_ex3_is_eq                                   ,
        f_pic_ex3_is_nan                                 => f_pic_ex3_is_nan                                  ,
        f_pic_ex3_cmp_sgnpos                             => f_pic_ex3_cmp_sgnpos                              ,
        f_pic_ex3_cmp_sgnneg                             => f_pic_ex3_cmp_sgnneg                              ,
        f_add_ex4_res(0 to 162)                          => f_add_ex4_res(0 to 162)                           ,
        f_add_ex4_flag_nan                               => f_add_ex4_flag_nan                                ,
        f_add_ex4_flag_gt                                => f_add_ex4_flag_gt                                 ,
        f_add_ex4_flag_lt                                => f_add_ex4_flag_lt                                 ,
        f_add_ex4_flag_eq                                => f_add_ex4_flag_eq                                 ,
        f_add_ex4_fpcc_iu(0 to 3)                        => f_add_ex4_fpcc_iu(0 to 3)                         ,
        f_add_ex4_sign_carry                             => f_add_ex4_sign_carry                              ,
        f_add_ex4_to_int_ovf_wd(0 to 1)                  => f_add_ex4_to_int_ovf_wd(0 to 1)                   ,
        f_add_ex4_to_int_ovf_dw(0 to 1)                  => f_add_ex4_to_int_ovf_dw(0 to 1)                   ,
        f_add_ex4_sticky                                 => f_add_ex4_sticky                                 );



flze : entity WORK.fuq_lze(fuq_lze)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(2 to 3)              ,
        mpw1_b                                           => mpw1_b(2 to 3)                   ,
        mpw2_b                                           => mpw2_b(0 to 0)                   ,
        thold_1                                          => perv_lza_thold_1         ,
        sg_1                                             => perv_lza_sg_1            ,
        fpu_enable                                       => perv_lza_fpu_enable      ,

        f_lze_si                                         => scan_in(8)                                        ,
        f_lze_so                                         => scan_out(8)                                       ,
        ex1_act_b                                        => f_pic_lza_ex1_act_b                               ,
        f_eie_ex2_lzo_expo(1 to 13)                      => f_eie_ex2_lzo_expo(1 to 13)                       ,
        f_eie_ex2_b_expo(1 to 13)                        => f_eie_ex2_b_expo(1 to 13)                         ,
        f_pic_ex2_est_recip                              => f_pic_ex2_est_recip                               ,
        f_pic_ex2_est_rsqrt                              => f_pic_ex2_est_rsqrt                               ,
        f_alg_ex2_byp_nonflip                            => f_alg_ex2_byp_nonflip                             ,
        f_eie_ex2_use_bexp                               => f_eie_ex2_use_bexp                                ,
        f_pic_ex2_b_valid                                => f_pic_ex2_b_valid                                 ,
        f_pic_ex2_lzo_dis_prod                           => f_pic_ex2_lzo_dis_prod                            ,
        f_pic_ex2_sp_lzo                                 => f_pic_ex2_sp_lzo                                  ,
        f_pic_ex2_frsp_ue1                               => f_pic_ex2_frsp_ue1                                ,
        f_fmt_ex2_pass_msb_dp                            => f_fmt_ex2_pass_frac(0)                            ,
        f_alg_ex2_sel_byp                                => f_alg_ex2_sel_byp                                 ,
        f_pic_ex2_to_integer                             => f_pic_ex2_to_integer                              ,
        f_pic_ex2_prenorm                                => f_pic_ex2_prenorm                                 ,


       f_lze_ex2_lzo_din(0 to 162)                       => f_lze_ex2_lzo_din(0 to 162)                       ,
       f_lze_ex3_sh_rgt_amt(0 to 7)                      => f_lze_ex3_sh_rgt_amt(0 to 7)                      ,
       f_lze_ex3_sh_rgt_en                               => f_lze_ex3_sh_rgt_en                              );



flza : entity WORK.fuq_lza(fuq_lza)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(3 to 4)              ,
        mpw1_b                                           => mpw1_b(3 to 4)                   ,
        mpw2_b                                           => mpw2_b(0 to 0)                   ,
        thold_1                                          => perv_lza_thold_1         ,
        sg_1                                             => perv_lza_sg_1            ,
        fpu_enable                                       => perv_lza_fpu_enable      ,

        f_lza_si                                         => scan_in(9)                                        ,
        f_lza_so                                         => scan_out(9)                                       ,
        ex1_act_b                                        => f_pic_lza_ex1_act_b                               ,
        f_sa3_ex3_s(0 to 162)                            => f_sa3_ex3_s_lza(0 to 162)                         ,
        f_sa3_ex3_c(53 to 161)                           => f_sa3_ex3_c_lza(53 to 161)                        ,
        f_alg_ex2_effsub_eac_b                           => f_alg_ex2_effsub_eac_b                            ,

        f_lze_ex2_lzo_din(0 to 162)                      => f_lze_ex2_lzo_din(0 to 162)                       ,
        f_lze_ex3_sh_rgt_amt(0 to 7)                     => f_lze_ex3_sh_rgt_amt(0 to 7)                      ,
        f_lze_ex3_sh_rgt_en                              => f_lze_ex3_sh_rgt_en                               ,

        f_lza_ex4_no_lza_edge                            => f_lza_ex4_no_lza_edge                             ,
        f_lza_ex4_lza_amt(0 to 7)                        => f_lza_ex4_lza_amt(0 to 7)                         ,
        f_lza_ex4_sh_rgt_en                              => f_lza_ex4_sh_rgt_en                               ,
        f_lza_ex4_sh_rgt_en_eov                          => f_lza_ex4_sh_rgt_en_eov                           ,
        f_lza_ex4_lza_dcd64_cp1(0 to 2)                  => f_lza_ex4_lza_dcd64_cp1(0 to 2)                   ,
        f_lza_ex4_lza_dcd64_cp2(0 to 1)                  => f_lza_ex4_lza_dcd64_cp2(0 to 1)                   ,
        f_lza_ex4_lza_dcd64_cp3(0)                       => f_lza_ex4_lza_dcd64_cp3(0)                        ,

        f_lza_ex4_lza_amt_eov(0 to 7)                    => f_lza_ex4_lza_amt_eov(0 to 7)                    );


fnrm : entity WORK.fuq_nrm(fuq_nrm)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(4 to 5)              ,
        mpw1_b                                           => mpw1_b(4 to 5)                   ,
        mpw2_b                                           => mpw2_b(0 to 1)                   ,
        thold_1                                          => perv_nrm_thold_1         ,
        sg_1                                             => perv_nrm_sg_1            ,
        fpu_enable                                       => perv_nrm_fpu_enable      ,

        f_nrm_si                                         => scan_in(10)                                       ,
        f_nrm_so                                         => scan_out(10)                                      ,
        ex3_act_b                                        => f_pic_nrm_ex3_act_b                               ,

        f_lza_ex4_sh_rgt_en                              => f_lza_ex4_sh_rgt_en                               ,
        f_lza_ex4_lza_amt_cp1                            => f_lza_ex4_lza_amt(0 to 7)                         ,
        f_lza_ex4_lza_dcd64_cp1(0 to 2)                  => f_lza_ex4_lza_dcd64_cp1(0 to 2)                   ,
        f_lza_ex4_lza_dcd64_cp2(0 to 1)                  => f_lza_ex4_lza_dcd64_cp2(0 to 1)                   ,
        f_lza_ex4_lza_dcd64_cp3(0)                       => f_lza_ex4_lza_dcd64_cp3(0)                        ,

        f_add_ex4_res(0 to 162)                          => f_add_ex4_res(0 to 162)                           ,
        f_add_ex4_sticky                                 => f_add_ex4_sticky                                  ,
        f_pic_ex4_byp_prod_nz                            => f_pic_ex4_byp_prod_nz                             ,
        f_nrm_ex5_res(0 to 52)                           => f_nrm_ex5_res(0 to 52)                            ,
        f_nrm_ex5_int_lsbs(1 to 12)                      => f_nrm_ex5_int_lsbs(1 to 12)                       ,
        f_nrm_ex5_int_sign                               => f_nrm_ex5_int_sign                                ,
        f_nrm_ex5_nrm_sticky_dp                          => f_nrm_ex5_nrm_sticky_dp                           ,
        f_nrm_ex5_nrm_guard_dp                           => f_nrm_ex5_nrm_guard_dp                            ,
        f_nrm_ex5_nrm_lsb_dp                             => f_nrm_ex5_nrm_lsb_dp                              ,
        f_nrm_ex5_nrm_sticky_sp                          => f_nrm_ex5_nrm_sticky_sp                           ,
        f_nrm_ex5_nrm_guard_sp                           => f_nrm_ex5_nrm_guard_sp                            ,
        f_nrm_ex5_nrm_lsb_sp                             => f_nrm_ex5_nrm_lsb_sp                              ,
        f_nrm_ex5_exact_zero                             => f_nrm_ex5_exact_zero                              ,
        f_nrm_ex4_extra_shift                            => f_nrm_ex4_extra_shift                             ,
        f_nrm_ex5_fpscr_wr_dat_dfp(0 to 3)               => f_nrm_ex5_fpscr_wr_dat_dfp(0 to 3)                ,
        f_nrm_ex5_fpscr_wr_dat(0 to 31)                  => f_nrm_ex5_fpscr_wr_dat(0 to 31)                  );



frnd : entity WORK.fuq_rnd(fuq_rnd)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(5 to 6)              ,
        mpw1_b                                           => mpw1_b(5 to 6)                   ,
        mpw2_b                                           => mpw2_b(1 to 1)                   ,
        thold_1                                          => perv_rnd_thold_1         ,
        sg_1                                             => perv_rnd_sg_1            ,
        fpu_enable                                       => perv_rnd_fpu_enable      ,

        f_rnd_si                                         => scan_in(11)                                       ,
        f_rnd_so                                         => scan_out(11)                                      ,
        ex3_act_b                                        => f_pic_rnd_ex3_act_b                               ,
        f_pic_ex4_sel_est_b                              => f_pic_ex4_sel_est_b                               ,
        f_tbl_ex5_est_frac(0 to 26)                      => f_tbl_ex5_est_frac(0 to 26)                       ,
        f_nrm_ex5_res(0 to 52)                           => f_nrm_ex5_res(0 to 52)                            ,
        f_nrm_ex5_int_lsbs(1 to 12)                      => f_nrm_ex5_int_lsbs(1 to 12)                       ,
        f_nrm_ex5_int_sign                               => f_nrm_ex5_int_sign                                ,
        f_nrm_ex5_nrm_sticky_dp                          => f_nrm_ex5_nrm_sticky_dp                           ,
        f_nrm_ex5_nrm_guard_dp                           => f_nrm_ex5_nrm_guard_dp                            ,
        f_nrm_ex5_nrm_lsb_dp                             => f_nrm_ex5_nrm_lsb_dp                              ,
        f_nrm_ex5_nrm_sticky_sp                          => f_nrm_ex5_nrm_sticky_sp                           ,
        f_nrm_ex5_nrm_guard_sp                           => f_nrm_ex5_nrm_guard_sp                            ,
        f_nrm_ex5_nrm_lsb_sp                             => f_nrm_ex5_nrm_lsb_sp                              ,
        f_nrm_ex5_exact_zero                             => f_nrm_ex5_exact_zero                              ,
        f_pic_ex5_invert_sign                            => f_pic_ex5_invert_sign                             ,
        f_pic_ex5_en_exact_zero                          => f_pic_ex5_en_exact_zero                           ,
        f_pic_ex5_k_nan                                  => f_pic_ex5_k_nan                                   ,
        f_pic_ex5_k_inf                                  => f_pic_ex5_k_inf                                   ,
        f_pic_ex5_k_max                                  => f_pic_ex5_k_max                                   ,
        f_pic_ex5_k_zer                                  => f_pic_ex5_k_zer                                   ,
        f_pic_ex5_k_one                                  => f_pic_ex5_k_one                                   ,
        f_pic_ex5_k_int_maxpos                           => f_pic_ex5_k_int_maxpos                            ,
        f_pic_ex5_k_int_maxneg                           => f_pic_ex5_k_int_maxneg                            ,
        f_pic_ex5_k_int_zer                              => f_pic_ex5_k_int_zer                               ,
        f_tbl_ex5_recip_den                              => f_tbl_ex5_recip_den                               ,
        f_pic_ex4_rnd_ni_b                               => f_pic_ex4_rnd_ni_b                                ,
        f_pic_ex4_rnd_nr_b                               => f_pic_ex4_rnd_nr_b                                ,
        f_pic_ex4_rnd_inf_ok_b                           => f_pic_ex4_rnd_inf_ok_b                            ,
        f_pic_ex5_uc_inc_lsb                             => f_pic_ex5_uc_inc_lsb                              ,
        f_pic_ex5_uc_guard                               => f_pic_ex5_uc_guard                                ,
        f_pic_ex5_uc_sticky                              => f_pic_ex5_uc_sticky                               ,
        f_pic_ex5_uc_g_v                                 => f_pic_ex5_uc_g_v                                  ,
        f_pic_ex5_uc_s_v                                 => f_pic_ex5_uc_s_v                                  ,
        f_pic_ex4_sel_fpscr_b                            => f_pic_ex4_sel_fpscr_b                             ,
        f_pic_ex4_to_integer_b                           => f_pic_ex4_to_integer_b                            ,
        f_pic_ex4_word_b                                 => f_pic_ex4_word_b                                  ,
        f_pic_ex4_uns_b                                  => f_pic_ex4_uns_b                                   ,
        f_pic_ex4_sp_b                                   => f_pic_ex4_sp_b                                    ,
        f_pic_ex4_spec_inf_b                             => f_pic_ex4_spec_inf_b                              ,
        f_pic_ex4_quiet_b                                => f_pic_ex4_quiet_b                                 ,
        f_pic_ex4_nj_deno                                => f_pic_ex4_nj_deno                                 ,
        f_pic_ex4_unf_en_ue0_b                           => f_pic_ex4_unf_en_ue0_b                            ,
        f_pic_ex4_unf_en_ue1_b                           => f_pic_ex4_unf_en_ue1_b                            ,
        f_pic_ex4_ovf_en_oe0_b                           => f_pic_ex4_ovf_en_oe0_b                            ,
        f_pic_ex4_ovf_en_oe1_b                           => f_pic_ex4_ovf_en_oe1_b                            ,
        f_pic_ex5_round_sign                             => f_pic_ex5_round_sign                              ,
        f_scr_ex5_fpscr_rd_dat_dfp(0 to 3)               => f_scr_ex5_fpscr_rd_dat_dfp(0 to 3)                ,
        f_scr_ex5_fpscr_rd_dat(0 to 31)                  => f_scr_ex5_fpscr_rd_dat(0 to 31)                   ,
        f_eov_ex5_sel_k_f                                => f_eov_ex5_sel_k_f                                 ,
        f_eov_ex5_sel_k_e                                => f_eov_ex5_sel_k_e                                 ,
        f_eov_ex5_sel_kif_f                              => f_eov_ex5_sel_kif_f                               ,
        f_eov_ex5_sel_kif_e                              => f_eov_ex5_sel_kif_e                               ,
        f_eov_ex5_ovf_expo                               => f_eov_ex5_ovf_expo                                ,
        f_eov_ex5_ovf_if_expo                            => f_eov_ex5_ovf_if_expo                             ,
        f_eov_ex5_unf_expo                               => f_eov_ex5_unf_expo                                ,
        f_pic_ex5_frsp                                   => f_pic_ex5_frsp                                    ,
        f_eov_ex5_expo_p0(1 to 13)                       => f_eov_ex5_expo_p0(1 to 13)                        ,
        f_eov_ex5_expo_p1(1 to 13)                       => f_eov_ex5_expo_p1(1 to 13)                        ,
        f_eov_ex5_expo_p0_ue1oe1(3 to 7)                 => f_eov_ex5_expo_p0_ue1oe1(3 to 7)                  ,
        f_eov_ex5_expo_p1_ue1oe1(3 to 7)                 => f_eov_ex5_expo_p1_ue1oe1(3 to 7)                  ,
        f_gst_ex5_logexp_v                               => f_gst_ex5_logexp_v                                ,
        f_gst_ex5_logexp_sign                            => f_gst_ex5_logexp_sign                             ,
        f_gst_ex5_logexp_exp(1 to 11)                    => f_gst_ex5_logexp_exp(1 to 11)                     ,
        f_gst_ex5_logexp_fract(0 to 19)                  => f_gst_ex5_logexp_fract(0 to 19)                   ,
        f_mad_ex6_uc_sign                                => f_mad_ex6_uc_sign                                 ,
        f_mad_ex6_uc_zero                                => f_mad_ex6_uc_zero                                 ,
        f_rnd_ex6_res_sign                               =>   rnd_ex6_res_sign                                ,
        f_rnd_ex6_res_expo(1 to 13)                      =>   rnd_ex6_res_expo(1 to 13)                       ,
        f_rnd_ex6_res_frac(0 to 52)                      =>   rnd_ex6_res_frac(0 to 52)                       ,
        f_rnd_ex6_flag_up                                => f_rnd_ex6_flag_up                                 ,
        f_rnd_ex6_flag_fi                                => f_rnd_ex6_flag_fi                                 ,
        f_rnd_ex6_flag_ox                                => f_rnd_ex6_flag_ox                                 ,
        f_rnd_ex6_flag_den                               => f_rnd_ex6_flag_den                                ,
        f_rnd_ex6_flag_sgn                               => f_rnd_ex6_flag_sgn                                ,
        f_rnd_ex6_flag_inf                               => f_rnd_ex6_flag_inf                                ,
        f_rnd_ex6_flag_zer                               => f_rnd_ex6_flag_zer                                ,
        f_rnd_ex6_flag_ux                                => f_rnd_ex6_flag_ux                                );
        


        f_rnd_ex6_res_sign                               <=   rnd_ex6_res_sign                                ;
        f_rnd_ex6_res_expo(1 to 13)                      <=   rnd_ex6_res_expo(1 to 13)                       ;
        f_rnd_ex6_res_frac(0 to 52)                      <=   rnd_ex6_res_frac(0 to 52)                       ;


fgst : entity WORK.fuq_gst(fuq_gst)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(2 to 5)              ,
        mpw1_b                                           => mpw1_b(2 to 5)                   ,
        mpw2_b                                           => mpw2_b(0 to 1)                   ,
        thold_1                                          => perv_rnd_thold_1         ,
        sg_1                                             => perv_rnd_sg_1            ,
        fpu_enable                                       => perv_rnd_fpu_enable      ,

        f_gst_si                                         => scan_in(12)                                       ,
        f_gst_so                                         => scan_out(12)                                      ,
        rf1_act                                          => f_dcd_rf1_act                                     ,
        f_fmt_ex1_b_sign_gst                             => f_fmt_ex1_b_sign_gst                              ,
        f_fmt_ex1_b_expo_gst_b(1 to 13)                  => f_fmt_ex1_b_expo_gst_b(1 to 13)                   ,
        f_fmt_ex1_b_frac_gst(1 to 19)                    => f_fmt_ex1_b_frac(1 to 19)                         ,
        f_pic_ex1_floges                                 => f_pic_ex1_log2e                                   ,
        f_pic_ex1_fexptes                                => f_pic_ex1_pow2e                                   ,
        f_gst_ex5_logexp_v                               => f_gst_ex5_logexp_v                                ,
        f_gst_ex5_logexp_sign                            => f_gst_ex5_logexp_sign                             ,
        f_gst_ex5_logexp_exp(1 to 11)                    => f_gst_ex5_logexp_exp(1 to 11)                     ,
        f_gst_ex5_logexp_fract(0 to 19)                  => f_gst_ex5_logexp_fract(0 to 19)                  );




fpic : entity WORK.fuq_pic(fuq_pic)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(1 to 5)              ,
        mpw1_b                                           => mpw1_b(1 to 5)                   ,
        mpw2_b                                           => mpw2_b(0 to 1)                   ,
        thold_1                                          => perv_pic_thold_1         ,
        sg_1                                             => perv_pic_sg_1            ,
        fpu_enable                                       => perv_pic_fpu_enable      ,

        f_pic_si                                         => scan_in(13)                                       ,
        f_pic_so                                         => scan_out(13)                                      ,
        f_dcd_rf1_act                                    => f_dcd_rf1_act                                     ,
        f_cr2_ex1_fpscr_shadow(0 to 7)                   => f_cr2_ex1_fpscr_shadow(0 to 7)                    ,
        f_dcd_rf1_pow2e_b                                => f_dcd_rf1_pow2e_b                                 ,
        f_dcd_rf1_log2e_b                                => f_dcd_rf1_log2e_b                                 ,
        f_byp_pic_ex1_a_sign                             => f_byp_pic_ex1_a_sign                              ,
        f_byp_pic_ex1_c_sign                             => f_byp_pic_ex1_c_sign                              ,
        f_byp_pic_ex1_b_sign                             => f_byp_pic_ex1_b_sign                              ,
        f_dcd_rf1_aop_valid                              => f_dcd_rf1_aop_valid                               ,
        f_dcd_rf1_cop_valid                              => f_dcd_rf1_cop_valid                               ,
        f_dcd_rf1_bop_valid                              => f_dcd_rf1_bop_valid                               ,
        f_dcd_rf1_uc_ft_neg                              => f_dcd_rf1_uc_ft_neg                               ,
        f_dcd_rf1_uc_ft_pos                              => f_dcd_rf1_uc_ft_pos                               ,
        f_dcd_rf1_fsel_b                                 => f_dcd_rf1_fsel_b                                  ,
        f_dcd_rf1_from_integer_b                         => f_dcd_rf1_from_integer_b                          ,
        f_dcd_rf1_to_integer_b                           => f_dcd_rf1_to_integer_b                            ,
        f_dcd_rf1_rnd_to_int_b                           => f_dcd_rf1_rnd_to_int_b                            ,
        f_dcd_rf1_math_b                                 => f_dcd_rf1_math_b                                  ,
        f_dcd_rf1_est_recip_b                            => f_dcd_rf1_est_recip_b                             ,
        f_dcd_rf1_ftdiv                                  => f_dcd_rf1_ftdiv                                   ,
        f_dcd_rf1_ftsqrt                                 => f_dcd_rf1_ftsqrt                                  ,
        f_fmt_ex2_ae_ge_54                               => f_fmt_ex2_ae_ge_54                                ,
        f_fmt_ex2_be_ge_54                               => f_fmt_ex2_be_ge_54                                ,
        f_fmt_ex2_be_ge_2                                => f_fmt_ex2_be_ge_2                                 ,
        f_fmt_ex2_be_ge_2044                             => f_fmt_ex2_be_ge_2044                              ,
        f_fmt_ex2_tdiv_rng_chk                           => f_fmt_ex2_tdiv_rng_chk                            ,
        f_fmt_ex2_be_den                                 => f_fmt_ex2_be_den                                  ,

        f_dcd_rf1_est_rsqrt_b                            => f_dcd_rf1_est_rsqrt_b                             ,
        f_dcd_rf1_move_b                                 => f_dcd_rf1_move_b                                  ,
        f_dcd_rf1_prenorm_b                              => f_dcd_rf1_prenorm_b                               ,
        f_dcd_rf1_frsp_b                                 => f_dcd_rf1_frsp_b                                  ,
        f_dcd_rf1_sp                                     => f_dcd_rf1_sp                                      ,
        f_dcd_rf1_sp_conv_b                              => f_dcd_rf1_sp_conv_b                               ,
        f_dcd_rf1_word_b                                 => f_dcd_rf1_word_b                                  ,
        f_dcd_rf1_uns_b                                  => f_dcd_rf1_uns_b                                   ,
        f_dcd_rf1_sub_op_b                               => f_dcd_rf1_sub_op_b                                ,
        f_dcd_rf1_op_rnd_v_b                             => f_dcd_rf1_op_rnd_v_b                              ,
        f_dcd_rf1_op_rnd_b(0 to 1)                       => f_dcd_rf1_op_rnd_b(0 to 1)                        ,
        f_dcd_rf1_inv_sign_b                             => f_dcd_rf1_inv_sign_b                              ,
        f_dcd_rf1_sign_ctl_b(0 to 1)                     => f_dcd_rf1_sign_ctl_b(0 to 1)                      ,
        f_dcd_rf1_sgncpy_b                               => f_dcd_rf1_sgncpy_b                                ,
        f_dcd_rf1_nj_deno                                => f_dcd_rf1_nj_deno                                 ,
        f_dcd_rf1_mv_to_scr_b                            => f_dcd_rf1_mv_to_scr_b                             ,
        f_dcd_rf1_mv_from_scr_b                          => f_dcd_rf1_mv_from_scr_b                           ,
        f_dcd_rf1_compare_b                              => f_dcd_rf1_compare_b                               ,
        f_dcd_rf1_ordered_b                              => f_dcd_rf1_ordered_b                               ,
        f_alg_ex1_sign_frmw                              => f_alg_ex1_sign_frmw                               ,
        f_dcd_rf1_force_excp_dis                         => f_dcd_rf1_force_excp_dis                          ,
        f_pic_ex1_log2e                                  => f_pic_ex1_log2e                                   ,
        f_pic_ex1_pow2e                                  => f_pic_ex1_pow2e                                   ,
        f_fmt_ex1_bexpu_le126                            => f_fmt_ex1_bexpu_le126                             ,
        f_fmt_ex1_gt126                                  => f_fmt_ex1_gt126                                   ,
        f_fmt_ex1_ge128                                  => f_fmt_ex1_ge128                                   ,
        f_fmt_ex1_inf_and_beyond_sp                      => f_fmt_ex1_inf_and_beyond_sp                       ,
        f_fmt_ex1_sp_invalid                             => f_fmt_ex1_sp_invalid                              ,
        f_fmt_ex1_a_zero                                 => f_fmt_ex1_a_zero                                  ,
        f_fmt_ex1_a_expo_max                             => f_fmt_ex1_a_expo_max                              ,
        f_fmt_ex1_a_frac_zero                            => f_fmt_ex1_a_frac_zero                             ,
        f_fmt_ex1_a_frac_msb                             => f_fmt_ex1_a_frac_msb                              ,
        f_fmt_ex1_c_zero                                 => f_fmt_ex1_c_zero                                  ,
        f_fmt_ex1_c_expo_max                             => f_fmt_ex1_c_expo_max                              ,
        f_fmt_ex1_c_frac_zero                            => f_fmt_ex1_c_frac_zero                             ,
        f_fmt_ex1_c_frac_msb                             => f_fmt_ex1_c_frac_msb                              ,
        f_fmt_ex1_b_zero                                 => f_fmt_ex1_b_zero                                  ,
        f_fmt_ex1_b_expo_max                             => f_fmt_ex1_b_expo_max                              ,
        f_fmt_ex1_b_frac_zero                            => f_fmt_ex1_b_frac_zero                             ,
        f_fmt_ex1_b_frac_msb                             => f_fmt_ex1_b_frac_msb                              ,
        f_fmt_ex1_prod_zero                              => f_fmt_ex1_prod_zero                               ,
        f_fmt_ex2_pass_sign                              => f_fmt_ex2_pass_sign                               ,
        f_fmt_ex2_pass_msb                               => f_fmt_ex2_pass_msb                                ,
        f_fmt_ex1_b_frac_z32                             => f_fmt_ex1_b_frac_z32                              ,
        f_fmt_ex1_b_imp                                  => f_fmt_ex1_b_imp                                   ,
        f_eie_ex2_wd_ov                                  => f_eie_ex2_wd_ov                                   ,
        f_eie_ex2_dw_ov                                  => f_eie_ex2_dw_ov                                   ,
        f_eie_ex2_wd_ov_if                               => f_eie_ex2_wd_ov_if                                ,
        f_eie_ex2_dw_ov_if                               => f_eie_ex2_dw_ov_if                                ,
        f_eie_ex2_lt_bias                                => f_eie_ex2_lt_bias                                 ,
        f_eie_ex2_eq_bias_m1                             => f_eie_ex2_eq_bias_m1                              ,
        f_alg_ex2_sel_byp                                => f_alg_ex2_sel_byp                                 ,
        f_alg_ex2_effsub_eac_b                           => f_alg_ex2_effsub_eac_b                            ,
        f_alg_ex2_sh_unf                                 => f_alg_ex2_sh_unf                                  ,
        f_alg_ex2_sh_ovf                                 => f_alg_ex2_sh_ovf                                  ,
        f_alg_ex3_int_fr                                 => f_alg_ex3_int_fr                                  ,
        f_alg_ex3_int_fi                                 => f_alg_ex3_int_fi                                  ,
        f_eov_ex4_may_ovf                                => f_eov_ex4_may_ovf                                 ,
        f_add_ex4_fpcc_iu(0)                             => f_add_ex4_flag_lt                                 ,
        f_add_ex4_fpcc_iu(1)                             => f_add_ex4_flag_gt                                 ,
        f_add_ex4_fpcc_iu(2)                             => f_add_ex4_flag_eq                                 ,
        f_add_ex4_fpcc_iu(3)                             => f_add_ex4_flag_nan                                ,
        f_add_ex4_sign_carry                             => f_add_ex4_sign_carry                              ,
        f_dcd_rf1_div_beg                                => f_dcd_rf1_div_beg                                 ,
        f_dcd_rf1_sqrt_beg                               => f_dcd_rf1_sqrt_beg                                ,
        f_pic_ex5_fpr_wr_dis_b                           => f_pic_ex5_fpr_wr_dis_b                            ,
        f_add_ex4_to_int_ovf_wd(0 to 1)                  => f_add_ex4_to_int_ovf_wd(0 to 1)                   ,
        f_add_ex4_to_int_ovf_dw(0 to 1)                  => f_add_ex4_to_int_ovf_dw(0 to 1)                   ,
        f_pic_ex1_ftdiv                                  => f_pic_ex1_ftdiv                                   ,
        f_pic_ex1_flush_en_sp                            => f_pic_ex1_flush_en_sp                             ,
        f_pic_ex1_flush_en_dp                            => f_pic_ex1_flush_en_dp                             ,
        f_pic_ex1_rnd_to_int                             => f_pic_ex1_rnd_to_int                              ,

        f_pic_fmt_ex1_act                                => f_pic_fmt_ex1_act                                 ,
        f_pic_eie_ex1_act                                => f_pic_eie_ex1_act                                 ,
        f_pic_mul_ex1_act                                => f_pic_mul_ex1_act                                 ,
        f_pic_alg_ex1_act                                => f_pic_alg_ex1_act                                 ,
        f_pic_cr2_ex1_act                                => f_pic_cr2_ex1_act                                 ,
        f_pic_tbl_ex1_act                                => f_pic_tbl_ex1_act                                 ,

        f_pic_add_ex1_act_b                              => f_pic_add_ex1_act_b                               ,
        f_pic_lza_ex1_act_b                              => f_pic_lza_ex1_act_b                               ,
        f_pic_eov_ex2_act_b                              => f_pic_eov_ex2_act_b                               ,
        f_pic_nrm_ex3_act_b                              => f_pic_nrm_ex3_act_b                               ,
        f_pic_rnd_ex3_act_b                              => f_pic_rnd_ex3_act_b                               ,
        f_pic_scr_ex2_act_b                              => f_pic_scr_ex2_act_b                               ,
        f_pic_ex1_effsub_raw                             => f_pic_ex1_effsub_raw                              ,
        f_pic_ex3_sel_est                                => f_pic_ex3_sel_est                                 ,
        f_pic_ex1_from_integer                           => f_pic_ex1_from_integer                            ,
        f_pic_ex2_ue1                                    => f_pic_ex2_ue1                                     ,
        f_pic_ex2_frsp_ue1                               => f_pic_ex2_frsp_ue1                                ,
        f_pic_ex1_frsp_ue1                               => f_pic_ex1_frsp_ue1                                ,
        f_pic_ex1_fsel                                   => f_pic_ex1_fsel                                    ,
        f_pic_ex1_sh_ovf_do                              => f_pic_ex1_sh_ovf_do                               ,
        f_pic_ex1_sh_ovf_ig_b                            => f_pic_ex1_sh_ovf_ig_b                             ,
        f_pic_ex1_sh_unf_do                              => f_pic_ex1_sh_unf_do                               ,
        f_pic_ex1_sh_unf_ig_b                            => f_pic_ex1_sh_unf_ig_b                             ,
        f_pic_ex2_est_recip                              => f_pic_ex2_est_recip                               ,
        f_pic_ex2_est_rsqrt                              => f_pic_ex2_est_rsqrt                               ,
        f_pic_ex2_force_sel_bexp                         => f_pic_ex2_force_sel_bexp                          ,
        f_pic_ex2_lzo_dis_prod                           => f_pic_ex2_lzo_dis_prod                            ,
        f_pic_ex2_sp_b                                   => f_pic_ex2_sp_b                                    ,
        f_pic_ex2_sp_lzo                                 => f_pic_ex2_sp_lzo                                  ,
        f_pic_ex2_to_integer                             => f_pic_ex2_to_integer                              ,
        f_pic_ex2_prenorm                                => f_pic_ex2_prenorm                                 ,
        f_pic_ex2_b_valid                                => f_pic_ex2_b_valid                                 ,
        f_pic_ex2_rnd_nr                                 => f_pic_ex2_rnd_nr                                  ,
        f_pic_ex2_rnd_inf_ok                             => f_pic_ex2_rnd_inf_ok                              ,
        f_pic_ex2_math_bzer_b                            => f_pic_ex2_math_bzer_b                             ,
        f_pic_ex3_cmp_sgnneg                             => f_pic_ex3_cmp_sgnneg                              ,
        f_pic_ex3_cmp_sgnpos                             => f_pic_ex3_cmp_sgnpos                              ,
        f_pic_ex3_is_eq                                  => f_pic_ex3_is_eq                                   ,
        f_pic_ex3_is_gt                                  => f_pic_ex3_is_gt                                   ,
        f_pic_ex3_is_lt                                  => f_pic_ex3_is_lt                                   ,
        f_pic_ex3_is_nan                                 => f_pic_ex3_is_nan                                  ,
        f_pic_ex3_sp_b                                   => f_pic_ex3_sp_b                                    ,
        f_dcd_rf1_uc_mid                                 => f_dcd_rf1_uc_mid                                  ,
        f_dcd_rf1_uc_end                                 => f_dcd_rf1_uc_end                                  ,
        f_dcd_rf1_uc_special                             => f_dcd_rf1_uc_special                              ,
        f_mad_ex2_uc_a_expo_den_sp                       => f_mad_ex2_uc_a_expo_den_sp                        ,
        f_mad_ex2_uc_a_expo_den                          => f_mad_ex2_uc_a_expo_den                           ,
        f_dcd_ex2_uc_zx                                  => f_dcd_ex2_uc_zx                                   ,
        f_dcd_ex2_uc_vxidi                               => f_dcd_ex2_uc_vxidi                                ,
        f_dcd_ex2_uc_vxzdz                               => f_dcd_ex2_uc_vxzdz                                ,
        f_dcd_ex2_uc_vxsqrt                              => f_dcd_ex2_uc_vxsqrt                               ,
        f_dcd_ex2_uc_vxsnan                              => f_dcd_ex2_uc_vxsnan                               ,
        f_mad_ex3_uc_special                             => f_mad_ex3_uc_special                              ,
        f_mad_ex3_uc_zx                                  => f_mad_ex3_uc_zx                                   ,
        f_mad_ex3_uc_vxidi                               => f_mad_ex3_uc_vxidi                                ,
        f_mad_ex3_uc_vxzdz                               => f_mad_ex3_uc_vxzdz                                ,
        f_mad_ex3_uc_vxsqrt                              => f_mad_ex3_uc_vxsqrt                               ,
        f_mad_ex3_uc_vxsnan                              => f_mad_ex3_uc_vxsnan                               ,
        f_mad_ex3_uc_res_sign                            => f_mad_ex3_uc_res_sign                             ,
        f_mad_ex3_uc_round_mode(0 to 1)                  => f_mad_ex3_uc_round_mode(0 to 1)                   ,
        f_pic_ex4_byp_prod_nz                            => f_pic_ex4_byp_prod_nz                             ,
        f_pic_ex4_sel_est_b                              => f_pic_ex4_sel_est_b                               ,
        f_pic_ex4_nj_deno                                => f_pic_ex4_nj_deno                                 ,
        f_pic_ex4_oe                                     => f_pic_ex4_oe                                      ,
        f_pic_ex4_ov_en                                  => f_pic_ex4_ov_en                                   ,
        f_pic_ex4_ovf_en_oe0_b                           => f_pic_ex4_ovf_en_oe0_b                            ,
        f_pic_ex4_ovf_en_oe1_b                           => f_pic_ex4_ovf_en_oe1_b                            ,
        f_pic_ex4_quiet_b                                => f_pic_ex4_quiet_b                                 ,
        f_pic_ex4_rnd_inf_ok_b                           => f_pic_ex4_rnd_inf_ok_b                            ,
        f_pic_ex4_rnd_ni_b                               => f_pic_ex4_rnd_ni_b                                ,
        f_pic_ex4_rnd_nr_b                               => f_pic_ex4_rnd_nr_b                                ,
        f_pic_ex4_sel_fpscr_b                            => f_pic_ex4_sel_fpscr_b                             ,
        f_pic_ex4_sp_b                                   => f_pic_ex4_sp_b                                    ,
        f_pic_ex4_spec_inf_b                             => f_pic_ex4_spec_inf_b                              ,
        f_pic_ex4_spec_sel_k_e                           => f_pic_ex4_spec_sel_k_e                            ,
        f_pic_ex4_spec_sel_k_f                           => f_pic_ex4_spec_sel_k_f                            ,
        f_dcd_ex2_uc_inc_lsb                             => f_dcd_ex2_uc_inc_lsb                              ,
        f_dcd_ex2_uc_guard                               => f_dcd_ex2_uc_gs(0)                                ,
        f_dcd_ex2_uc_sticky                              => f_dcd_ex2_uc_gs(1)                                ,
        f_dcd_ex2_uc_gs_v                                => f_dcd_ex2_uc_gs_v                                 ,
        f_pic_ex5_uc_inc_lsb                             => f_pic_ex5_uc_inc_lsb                              ,
        f_pic_ex5_uc_guard                               => f_pic_ex5_uc_guard                                ,
        f_pic_ex5_uc_sticky                              => f_pic_ex5_uc_sticky                               ,
        f_pic_ex5_uc_g_v                                 => f_pic_ex5_uc_g_v                                  ,
        f_pic_ex5_uc_s_v                                 => f_pic_ex5_uc_s_v                                  ,
        f_pic_ex4_to_int_ov_all                          => f_pic_ex4_to_int_ov_all                           ,
        f_pic_ex4_to_integer_b                           => f_pic_ex4_to_integer_b                            ,
        f_pic_ex4_word_b                                 => f_pic_ex4_word_b                                  ,
        f_pic_ex4_uns_b                                  => f_pic_ex4_uns_b                                   ,
        f_pic_ex4_ue                                     => f_pic_ex4_ue                                      ,
        f_pic_ex4_uf_en                                  => f_pic_ex4_uf_en                                   ,
        f_pic_ex4_unf_en_ue0_b                           => f_pic_ex4_unf_en_ue0_b                            ,
        f_pic_ex4_unf_en_ue1_b                           => f_pic_ex4_unf_en_ue1_b                            ,
        f_pic_ex5_en_exact_zero                          => f_pic_ex5_en_exact_zero                           ,
        f_pic_ex5_compare_b                              => f_pic_ex5_compare_b                               ,
        f_pic_ex5_frsp                                   => f_pic_ex5_frsp                                    ,
        f_pic_ex5_fi_pipe_v_b                            => f_pic_ex5_fi_pipe_v_b                             ,
        f_pic_ex5_fi_spec_b                              => f_pic_ex5_fi_spec_b                               ,
        f_pic_ex5_flag_vxcvi_b                           => f_pic_ex5_flag_vxcvi_b                            ,
        f_pic_ex5_flag_vxidi_b                           => f_pic_ex5_flag_vxidi_b                            ,
        f_pic_ex5_flag_vximz_b                           => f_pic_ex5_flag_vximz_b                            ,
        f_pic_ex5_flag_vxisi_b                           => f_pic_ex5_flag_vxisi_b                            ,
        f_pic_ex5_flag_vxsnan_b                          => f_pic_ex5_flag_vxsnan_b                           ,
        f_pic_ex5_flag_vxsqrt_b                          => f_pic_ex5_flag_vxsqrt_b                           ,
        f_pic_ex5_flag_vxvc_b                            => f_pic_ex5_flag_vxvc_b                             ,
        f_pic_ex5_flag_vxzdz_b                           => f_pic_ex5_flag_vxzdz_b                            ,
        f_pic_ex5_flag_zx_b                              => f_pic_ex5_flag_zx_b                               ,
        f_pic_ex5_fprf_hold_b                            => f_pic_ex5_fprf_hold_b                             ,
        f_pic_ex5_fprf_pipe_v_b                          => f_pic_ex5_fprf_pipe_v_b                           ,
        f_pic_ex5_fprf_spec_b(0 to 4)                    => f_pic_ex5_fprf_spec_b(0 to 4)                     ,
        f_pic_ex5_fr_pipe_v_b                            => f_pic_ex5_fr_pipe_v_b                             ,
        f_pic_ex5_fr_spec_b                              => f_pic_ex5_fr_spec_b                               ,
        f_pic_ex5_invert_sign                            => f_pic_ex5_invert_sign                             ,
        f_pic_ex5_k_nan                                  => f_pic_ex5_k_nan                                   ,
        f_pic_ex5_k_inf                                  => f_pic_ex5_k_inf                                   ,
        f_pic_ex5_k_max                                  => f_pic_ex5_k_max                                   ,
        f_pic_ex5_k_zer                                  => f_pic_ex5_k_zer                                   ,
        f_pic_ex5_k_one                                  => f_pic_ex5_k_one                                   ,
        f_pic_ex5_k_int_maxpos                           => f_pic_ex5_k_int_maxpos                            ,
        f_pic_ex5_k_int_maxneg                           => f_pic_ex5_k_int_maxneg                            ,
        f_pic_ex5_k_int_zer                              => f_pic_ex5_k_int_zer                               ,
        f_pic_ex5_ox_pipe_v_b                            => f_pic_ex5_ox_pipe_v_b                             ,
        f_pic_ex5_round_sign                             => f_pic_ex5_round_sign                              ,
        f_pic_ex5_scr_upd_move_b                         => f_pic_ex5_scr_upd_move_b                          ,
        f_pic_ex5_scr_upd_pipe_b                         => f_pic_ex5_scr_upd_pipe_b                          ,
        f_pic_ex1_nj_deni                                => f_pic_ex1_nj_deni                                 ,
        f_dcd_rf1_nj_deni                                => f_dcd_rf1_nj_deni                                 ,
        f_pic_ex5_ux_pipe_v_b                            => f_pic_ex5_ux_pipe_v_b                            );

fcr2 : entity WORK.fuq_cr2(fuq_cr2)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(1 to 7)              ,
        mpw1_b                                           => mpw1_b(1 to 7)                   ,
        mpw2_b                                           => mpw2_b(0 to 1)                   ,
        thold_1                                          => perv_cr2_thold_1         ,
        sg_1                                             => perv_cr2_sg_1            ,
        fpu_enable                                       => perv_cr2_fpu_enable      ,


        f_cr2_si                                         => scan_in(14)                            ,
        f_cr2_so                                         => scan_out(14)                           ,
        rf1_act                                          => f_dcd_rf1_act                          ,
        ex1_act                                          => f_pic_cr2_ex1_act                      ,
        rf1_thread_b(0 to 3)                             => rf1_thread_b(0 to 3)                   ,
        f_dcd_ex6_cancel                                 => f_dcd_ex6_cancel                       ,
        f_fmt_ex1_bop_byt(45 to 52)                      => f_fmt_ex1_bop_byt(45 to 52)            ,
        f_dcd_rf1_fpscr_bit_data_b(0 to 3)               => f_dcd_rf1_fpscr_bit_data_b(0 to 3)     ,
        f_dcd_rf1_fpscr_bit_mask_b(0 to 3)               => f_dcd_rf1_fpscr_bit_mask_b(0 to 3)     ,
        f_dcd_rf1_fpscr_nib_mask_b(0 to 8)               => f_dcd_rf1_fpscr_nib_mask_b(0 to 8)     ,
        f_dcd_rf1_mtfsbx_b                               => f_dcd_rf1_mtfsbx_b                     ,
        f_dcd_rf1_mcrfs_b                                => f_dcd_rf1_mcrfs_b                      ,
        f_dcd_rf1_mtfsf_b                                => f_dcd_rf1_mtfsf_b                      ,
        f_dcd_rf1_mtfsfi_b                               => f_dcd_rf1_mtfsfi_b                     ,
        f_cr2_ex3_thread_b(0 to 3)                       => f_cr2_ex3_thread_b(0 to 3)             ,
        f_cr2_ex3_fpscr_bit_data_b(0 to 3)               => f_cr2_ex3_fpscr_bit_data_b(0 to 3)     ,
        f_cr2_ex3_fpscr_bit_mask_b(0 to 3)               => f_cr2_ex3_fpscr_bit_mask_b(0 to 3)     ,
        f_cr2_ex3_fpscr_nib_mask_b(0 to 8)               => f_cr2_ex3_fpscr_nib_mask_b(0 to 8)     ,
        f_cr2_ex3_mtfsbx_b                               => f_cr2_ex3_mtfsbx_b                     ,
        f_cr2_ex3_mcrfs_b                                => f_cr2_ex3_mcrfs_b                      ,
        f_cr2_ex3_mtfsf_b                                => f_cr2_ex3_mtfsf_b                      ,
        f_cr2_ex3_mtfsfi_b                               => f_cr2_ex3_mtfsfi_b                     ,
        f_cr2_ex5_fpscr_rd_dat(24 to 31)                 => f_cr2_ex5_fpscr_rd_dat(24 to 31)       ,
        f_cr2_ex6_fpscr_rd_dat(24 to 31)                 => f_cr2_ex6_fpscr_rd_dat(24 to 31)       ,
        f_cr2_ex1_fpscr_shadow(0 to 7)                   => f_cr2_ex1_fpscr_shadow(0 to 7)        );



fscr : entity WORK.fuq_scr(fuq_scr) generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(4 to 7)              ,
        mpw1_b                                           => mpw1_b(4 to 7)                   ,
        mpw2_b                                           => mpw2_b(0 to 1)                   ,
        thold_1                                          => perv_scr_thold_1         ,
        sg_1                                             => perv_scr_sg_1            ,
        fpu_enable                                       => perv_scr_fpu_enable      ,

        f_scr_si                                         => scan_in(15)                                       ,
        f_scr_so                                         => scan_out(15)                                      ,
        ex2_act_b                                        => f_pic_scr_ex2_act_b                               ,
        f_cr2_ex3_thread_b(0 to 3)                       => f_cr2_ex3_thread_b(0 to 3)                        ,

        f_dcd_ex6_cancel                                 => f_dcd_ex6_cancel                       ,

        f_pic_ex5_scr_upd_move_b                         => f_pic_ex5_scr_upd_move_b                          ,
        f_pic_ex5_scr_upd_pipe_b                         => f_pic_ex5_scr_upd_pipe_b                          ,
        f_pic_ex5_fprf_spec_b(0 to 4)                    => f_pic_ex5_fprf_spec_b(0 to 4)                     ,
        f_pic_ex5_compare_b                              => f_pic_ex5_compare_b                               ,
        f_pic_ex5_fprf_pipe_v_b                          => f_pic_ex5_fprf_pipe_v_b                           ,
        f_pic_ex5_fprf_hold_b                            => f_pic_ex5_fprf_hold_b                             ,
        f_pic_ex5_fi_spec_b                              => f_pic_ex5_fi_spec_b                               ,
        f_pic_ex5_fi_pipe_v_b                            => f_pic_ex5_fi_pipe_v_b                             ,
        f_pic_ex5_fr_spec_b                              => f_pic_ex5_fr_spec_b                               ,
        f_pic_ex5_fr_pipe_v_b                            => f_pic_ex5_fr_pipe_v_b                             ,
        f_pic_ex5_ox_spec_b                              => tiup                                              ,
        f_pic_ex5_ox_pipe_v_b                            => f_pic_ex5_ox_pipe_v_b                             ,
        f_pic_ex5_ux_spec_b                              => tiup                                              ,
        f_pic_ex5_ux_pipe_v_b                            => f_pic_ex5_ux_pipe_v_b                             ,
        f_pic_ex5_flag_vxsnan_b                          => f_pic_ex5_flag_vxsnan_b                           ,
        f_pic_ex5_flag_vxisi_b                           => f_pic_ex5_flag_vxisi_b                            ,
        f_pic_ex5_flag_vxidi_b                           => f_pic_ex5_flag_vxidi_b                            ,
        f_pic_ex5_flag_vxzdz_b                           => f_pic_ex5_flag_vxzdz_b                            ,
        f_pic_ex5_flag_vximz_b                           => f_pic_ex5_flag_vximz_b                            ,
        f_pic_ex5_flag_vxvc_b                            => f_pic_ex5_flag_vxvc_b                             ,
        f_pic_ex5_flag_vxsqrt_b                          => f_pic_ex5_flag_vxsqrt_b                           ,
        f_pic_ex5_flag_vxcvi_b                           => f_pic_ex5_flag_vxcvi_b                            ,
        f_pic_ex5_flag_zx_b                              => f_pic_ex5_flag_zx_b                               ,
        f_nrm_ex5_fpscr_wr_dat_dfp(0 to 3)               => f_nrm_ex5_fpscr_wr_dat_dfp(0 to 3)                ,
        f_nrm_ex5_fpscr_wr_dat(0 to 31)                  => f_nrm_ex5_fpscr_wr_dat(0 to 31)                   ,
        f_cr2_ex3_fpscr_bit_data_b(0 to 3)               => f_cr2_ex3_fpscr_bit_data_b(0 to 3)     ,
        f_cr2_ex3_fpscr_bit_mask_b(0 to 3)               => f_cr2_ex3_fpscr_bit_mask_b(0 to 3)     ,
        f_cr2_ex3_fpscr_nib_mask_b(0 to 8)               => f_cr2_ex3_fpscr_nib_mask_b(0 to 8)     ,
        f_cr2_ex3_mtfsbx_b                               => f_cr2_ex3_mtfsbx_b                     ,
        f_cr2_ex3_mcrfs_b                                => f_cr2_ex3_mcrfs_b                      ,
        f_cr2_ex3_mtfsf_b                                => f_cr2_ex3_mtfsf_b                      ,
        f_cr2_ex3_mtfsfi_b                               => f_cr2_ex3_mtfsfi_b                     ,
        f_rnd_ex6_flag_up                                => f_rnd_ex6_flag_up                                 ,
        f_rnd_ex6_flag_fi                                => f_rnd_ex6_flag_fi                                 ,
        f_rnd_ex6_flag_ox                                => f_rnd_ex6_flag_ox                                 ,
        f_rnd_ex6_flag_den                               => f_rnd_ex6_flag_den                                ,
        f_rnd_ex6_flag_sgn                               => f_rnd_ex6_flag_sgn                                ,
        f_rnd_ex6_flag_inf                               => f_rnd_ex6_flag_inf                                ,
        f_rnd_ex6_flag_zer                               => f_rnd_ex6_flag_zer                                ,
        f_rnd_ex6_flag_ux                                => f_rnd_ex6_flag_ux                                 ,
        f_cr2_ex6_fpscr_rd_dat(24 to 31)                 => f_cr2_ex6_fpscr_rd_dat(24 to 31)                  ,
        f_cr2_ex5_fpscr_rd_dat(24 to 31)                 => f_cr2_ex5_fpscr_rd_dat(24 to 31)                  ,
        f_scr_ex5_fpscr_rd_dat(0 to 31)                  => f_scr_ex5_fpscr_rd_dat(0 to 31)                   ,
        f_scr_ex5_fpscr_rd_dat_dfp(0 to 3)               => f_scr_ex5_fpscr_rd_dat_dfp(0 to 3)                ,
        f_scr_ex7_cr_fld(0 to 3)                         => f_scr_ex7_cr_fld(0 to 3)                          ,
        f_scr_ex7_fx_thread0(0 to 3)                     => f_scr_ex7_fx_thread0(0 to 3)                      ,
        f_scr_ex7_fx_thread1(0 to 3)                     => f_scr_ex7_fx_thread1(0 to 3)                      ,
        f_scr_ex7_fx_thread2(0 to 3)                     => f_scr_ex7_fx_thread2(0 to 3)                      ,
        f_scr_ex7_fx_thread3(0 to 3)                     => f_scr_ex7_fx_thread3(0 to 3)                     );


ftbe : entity WORK.fuq_tblexp(fuq_tblexp) generic map( expand_type => expand_type)  port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(2 to 3)              ,
        mpw1_b                                           => mpw1_b(2 to 3)                   ,
        mpw2_b                                           => mpw2_b(0 to 0)                   ,
        thold_1                                          => perv_tbe_thold_1         ,
        sg_1                                             => perv_tbe_sg_1            ,
        fpu_enable                                       => perv_tbe_fpu_enable      ,

        si                                               => scan_in(16)                                       ,
        so                                               => scan_out(16)                                      ,
        ex1_act_b                                        => f_pic_lza_ex1_act_b                               ,
        f_pic_ex2_ue1                                    => f_pic_ex2_ue1                                     ,
        f_pic_ex2_sp_b                                   => f_pic_ex2_sp_b                                    ,
        f_pic_ex2_est_recip                              => f_pic_ex2_est_recip                               ,
        f_pic_ex2_est_rsqrt                              => f_pic_ex2_est_rsqrt                               ,
        f_eie_ex2_tbl_expo(1 to 13)                      => f_eie_ex2_tbl_expo(1 to 13)                       ,
        f_fmt_ex2_lu_den_recip                           => f_fmt_ex2_lu_den_recip                            ,
        f_fmt_ex2_lu_den_rsqrto                          => f_fmt_ex2_lu_den_rsqrto                           ,
        f_tbe_ex3_match_en_sp                            => f_tbe_ex3_match_en_sp                             ,
        f_tbe_ex3_match_en_dp                            => f_tbe_ex3_match_en_dp                             ,
        f_tbe_ex3_recip_2046                             => f_tbe_ex3_recip_2046                              ,
        f_tbe_ex3_recip_2045                             => f_tbe_ex3_recip_2045                              ,
        f_tbe_ex3_recip_2044                             => f_tbe_ex3_recip_2044                              ,
        f_tbe_ex3_lu_sh                                  => f_tbe_ex3_lu_sh                                   ,
        f_tbe_ex3_recip_ue1                              => f_tbe_ex3_recip_ue1                               ,
        f_tbe_ex3_may_ov                                 => f_tbe_ex3_may_ov                                  ,
        f_tbe_ex3_res_expo(1 to 13)                      => f_tbe_ex3_res_expo(1 to 13)                      );

ftbl : entity WORK.fuq_tbllut(fuq_tbllut)  generic map( expand_type => expand_type) port map( 
        vdd                                              => vdd                      ,
        gnd                                              => gnd                      ,
        nclk                                             => nclk                     ,
        clkoff_b                                         => clkoff_b                 ,
        act_dis                                          => act_dis                  ,
        flush                                            => flush                    ,
        delay_lclkr                                      => delay_lclkr(2 to 5)              ,
        mpw1_b                                           => mpw1_b(2 to 5)                   ,
        mpw2_b                                           => mpw2_b(0 to 1)                   ,
        thold_1                                          => perv_tbl_thold_1         ,
        sg_1                                             => perv_tbl_sg_1            ,
        fpu_enable                                       => perv_tbl_fpu_enable      ,

        si                                               => scan_in(17)                                       ,
        so                                               => scan_out(17)                                      ,
        ex1_act                                          => f_pic_tbl_ex1_act                                 ,
        f_fmt_ex1_b_frac(1 to 6)                         => f_fmt_ex1_b_frac(1 to 6)                          ,
        f_fmt_ex2_b_frac(7 to 22)                        => f_fmt_ex2_pass_frac(7 to 22)                      ,
        f_tbe_ex2_expo_lsb                               => f_eie_ex2_tbl_expo(13)                            ,
        f_tbe_ex2_est_recip                              => f_pic_ex2_est_recip                               ,
        f_tbe_ex2_est_rsqrt                              => f_pic_ex2_est_rsqrt                               ,
        f_tbe_ex3_recip_ue1                              => f_tbe_ex3_recip_ue1                               ,
        f_tbe_ex3_lu_sh                                  => f_tbe_ex3_lu_sh                                   ,
        f_tbe_ex3_match_en_sp                            => f_tbe_ex3_match_en_sp                             ,
        f_tbe_ex3_match_en_dp                            => f_tbe_ex3_match_en_dp                             ,
        f_tbe_ex3_recip_2046                             => f_tbe_ex3_recip_2046                              ,
        f_tbe_ex3_recip_2045                             => f_tbe_ex3_recip_2045                              ,
        f_tbe_ex3_recip_2044                             => f_tbe_ex3_recip_2044                              ,
        f_tbl_ex5_est_frac(0 to 26)                      => f_tbl_ex5_est_frac(0 to 26)                       ,
        f_tbl_ex4_unf_expo                               => f_tbl_ex4_unf_expo                                ,
        f_tbl_ex5_recip_den                              => f_tbl_ex5_recip_den                              );







    perv_tbl_sg_1     <= sg_1      ;
    perv_tbe_sg_1     <= sg_1      ;
    perv_eie_sg_1     <= sg_1      ;
    perv_eov_sg_1     <= sg_1      ;
    perv_fmt_sg_1     <= sg_1      ;
    perv_mul_sg_1     <= sg_1      ;
    perv_alg_sg_1     <= sg_1      ;
    perv_sa3_sg_1     <= sg_1      ;
    perv_add_sg_1     <= sg_1      ;
    perv_lza_sg_1     <= sg_1      ;
    perv_nrm_sg_1     <= sg_1      ;
    perv_rnd_sg_1     <= sg_1      ;
    perv_scr_sg_1     <= sg_1      ;
    perv_pic_sg_1     <= sg_1      ;
    perv_cr2_sg_1     <= sg_1      ;

    perv_tbl_thold_1  <= thold_1   ;
    perv_tbe_thold_1  <= thold_1   ;
    perv_eie_thold_1  <= thold_1   ;
    perv_eov_thold_1  <= thold_1   ;
    perv_fmt_thold_1  <= thold_1   ;
    perv_mul_thold_1  <= thold_1   ;
    perv_alg_thold_1  <= thold_1   ;
    perv_sa3_thold_1  <= thold_1   ;
    perv_add_thold_1  <= thold_1   ;
    perv_lza_thold_1  <= thold_1   ;
    perv_nrm_thold_1  <= thold_1   ;
    perv_rnd_thold_1  <= thold_1   ;
    perv_scr_thold_1  <= thold_1   ;
    perv_pic_thold_1  <= thold_1   ;
    perv_cr2_thold_1  <= thold_1   ;

    perv_tbl_fpu_enable <= fpu_enable  ;
    perv_tbe_fpu_enable <= fpu_enable  ;
    perv_eie_fpu_enable <= fpu_enable  ;
    perv_eov_fpu_enable <= fpu_enable  ;
    perv_fmt_fpu_enable <= fpu_enable  ;
    perv_mul_fpu_enable <= fpu_enable  ;
    perv_alg_fpu_enable <= fpu_enable  ;
    perv_sa3_fpu_enable <= fpu_enable  ;
    perv_add_fpu_enable <= fpu_enable  ;
    perv_lza_fpu_enable <= fpu_enable  ;
    perv_nrm_fpu_enable <= fpu_enable  ;
    perv_rnd_fpu_enable <= fpu_enable  ;
    perv_scr_fpu_enable <= fpu_enable  ;
    perv_pic_fpu_enable <= fpu_enable  ;
    perv_cr2_fpu_enable <= fpu_enable  ;



 

end fuq_mad;




