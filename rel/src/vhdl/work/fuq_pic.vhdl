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


 
entity fuq_pic is
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic_vector(1 to 5); -- tidn,
       mpw1_b                                    :in   std_ulogic_vector(1 to 5); -- tidn,
       mpw2_b                                    :in   std_ulogic_vector(0 to 1); -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;

        f_pic_si                   :in  std_ulogic; --perv
        f_pic_so                   :out std_ulogic; --perv
        f_dcd_rf1_act              :in  std_ulogic; --act
        f_dcd_rf1_aop_valid        :in  std_ulogic;
        f_dcd_rf1_cop_valid        :in  std_ulogic;
        f_dcd_rf1_bop_valid        :in  std_ulogic;

        f_dcd_rf1_fsel_b           :in  std_ulogic;                 -- fsel
        f_dcd_rf1_from_integer_b   :in  std_ulogic;                 -- fcfid (signed integer)
        f_dcd_rf1_to_integer_b     :in  std_ulogic;                 -- fcti* (signed integer 32/64)
        f_dcd_rf1_rnd_to_int_b     :in  std_ulogic;                 -- fcti* (signed integer 32/64)
        f_dcd_rf1_math_b           :in  std_ulogic;                 -- fmul,fmad,fmsub,fadd,fsub,fnmsub,fnmadd
        f_dcd_rf1_est_recip_b      :in  std_ulogic;                 -- fres
        f_dcd_rf1_est_rsqrt_b      :in  std_ulogic;                 -- frsqrte
        f_dcd_rf1_move_b           :in  std_ulogic;                 -- fmr,fneg,fabs,fnabs
        f_dcd_rf1_compare_b        :in  std_ulogic;                 -- fcomp*
        f_dcd_rf1_prenorm_b        :in  std_ulogic;                 -- prenorm ?? need
        f_dcd_rf1_frsp_b           :in  std_ulogic;                 -- round-to-single-precision ?? need
        f_dcd_rf1_mv_to_scr_b      :in  std_ulogic;                  --mcrfs,mtfsf,mtfsfi,mtfsb0,mtfsb1
        f_dcd_rf1_mv_from_scr_b    :in  std_ulogic;                  --mffs
        f_dcd_rf1_div_beg          :in  std_ulogic;
        f_dcd_rf1_sqrt_beg         :in  std_ulogic;
        f_dcd_rf1_force_excp_dis   :in  std_ulogic; -- ve=ue=xe=ze=oe= 0
        f_dcd_rf1_ftdiv            :in  std_ulogic; 
        f_dcd_rf1_ftsqrt           :in  std_ulogic; 
        f_fmt_ex2_ae_ge_54         :in  std_ulogic; 
        f_fmt_ex2_be_ge_54         :in  std_ulogic; 
        f_fmt_ex2_be_ge_2          :in  std_ulogic; 
        f_fmt_ex2_be_ge_2044       :in  std_ulogic; 
        f_fmt_ex2_tdiv_rng_chk     :in  std_ulogic; 
        f_fmt_ex2_be_den           :in  std_ulogic; 
        f_dcd_rf1_sp               :in  std_ulogic;                 -- single precision output
        f_dcd_rf1_uns_b            :in  std_ulogic;                 -- convert unsigned
        f_dcd_rf1_word_b           :in  std_ulogic;                 -- convert word/dw
        f_dcd_rf1_sp_conv_b        :in  std_ulogic;                 -- convert sp/d
        f_dcd_rf1_pow2e_b          :in  std_ulogic;
        f_dcd_rf1_log2e_b          :in  std_ulogic;
        f_dcd_rf1_ordered_b        :in  std_ulogic;                 -- fcompo
        f_dcd_rf1_sub_op_b         :in  std_ulogic;                 -- fsub, fnmsub, fmsub (fcomp)
        f_dcd_rf1_op_rnd_v_b       :in  std_ulogic;                 -- fctidz, fctiwz, prenorm, fri*
        f_dcd_rf1_op_rnd_b         :in  std_ulogic_vector(0 to 1);  --
        f_dcd_rf1_inv_sign_b       :in  std_ulogic;                 -- fnmsub fnmadd
        f_dcd_rf1_sign_ctl_b       :in  std_ulogic_vector(0 to 1);  -- 0:fmr/fneg  1:fneg/fnabs
        f_dcd_rf1_sgncpy_b         :in std_ulogic;

        f_byp_pic_ex1_a_sign       :in  std_ulogic;
        f_byp_pic_ex1_c_sign       :in  std_ulogic;
        f_byp_pic_ex1_b_sign       :in  std_ulogic;


        f_dcd_rf1_nj_deno          :in  std_ulogic;                 -- force output den to zero
        f_dcd_rf1_nj_deni          :in  std_ulogic;                 -- force output den to zero

        f_cr2_ex1_fpscr_shadow     :in  std_ulogic_vector(0 to 7);

        f_fmt_ex1_sp_invalid       :in  std_ulogic;
        f_fmt_ex1_a_zero           :in  std_ulogic;
        f_fmt_ex1_a_expo_max       :in  std_ulogic;
        f_fmt_ex1_a_frac_zero      :in  std_ulogic;
        f_fmt_ex1_a_frac_msb       :in  std_ulogic;
        f_fmt_ex1_c_zero           :in  std_ulogic;
        f_fmt_ex1_c_expo_max       :in  std_ulogic;
        f_fmt_ex1_c_frac_zero      :in  std_ulogic;
        f_fmt_ex1_c_frac_msb       :in  std_ulogic;
        f_fmt_ex1_b_zero           :in  std_ulogic;
        f_fmt_ex1_b_expo_max       :in  std_ulogic;
        f_fmt_ex1_b_frac_zero      :in  std_ulogic;
        f_fmt_ex1_b_frac_msb       :in  std_ulogic;
        f_fmt_ex1_prod_zero        :in  std_ulogic;
        f_fmt_ex1_bexpu_le126      :in  std_ulogic; -- log2e/pow2e special cases
        f_fmt_ex1_gt126            :in  std_ulogic; -- log2e/pow2e special cases
        f_fmt_ex1_ge128            :in  std_ulogic; -- log2e/pow2e special cases
        f_fmt_ex1_inf_and_beyond_sp  :in  std_ulogic;
        f_alg_ex1_sign_frmw        :in  std_ulogic; --?? from_int word is always unsigned (do not need this signal)

        f_fmt_ex2_pass_sign        :in  std_ulogic;
        f_fmt_ex2_pass_msb         :in  std_ulogic;
        f_fmt_ex1_b_imp            :in  std_ulogic;
        f_fmt_ex1_b_frac_z32       :in  std_ulogic;

        f_eie_ex2_wd_ov            :in  std_ulogic;
        f_eie_ex2_dw_ov            :in  std_ulogic;
        f_eie_ex2_wd_ov_if         :in  std_ulogic;
        f_eie_ex2_dw_ov_if         :in  std_ulogic;
        f_eie_ex2_lt_bias          :in  std_ulogic;
        f_eie_ex2_eq_bias_m1       :in  std_ulogic;

        f_alg_ex2_sel_byp          :in  std_ulogic;
        f_alg_ex2_effsub_eac_b     :in  std_ulogic;
        f_alg_ex2_sh_unf           :in  std_ulogic;
        f_alg_ex2_sh_ovf           :in  std_ulogic;

        f_mad_ex2_uc_a_expo_den    :in  std_ulogic;
        f_mad_ex2_uc_a_expo_den_sp :in  std_ulogic;

        f_alg_ex3_int_fr           :in  std_ulogic;
        f_alg_ex3_int_fi           :in  std_ulogic;

        f_eov_ex4_may_ovf          :in  std_ulogic;
        f_add_ex4_fpcc_iu          :in std_ulogic_vector(0 to 3);
        f_add_ex4_sign_carry       :in  std_ulogic;
        f_add_ex4_to_int_ovf_wd    :in  std_ulogic_vector(0 to 1);
        f_add_ex4_to_int_ovf_dw    :in  std_ulogic_vector(0 to 1);


        f_pic_fmt_ex1_act          :out std_ulogic;
        f_pic_eie_ex1_act          :out std_ulogic;
        f_pic_mul_ex1_act          :out std_ulogic;
        f_pic_alg_ex1_act          :out std_ulogic;
        f_pic_cr2_ex1_act          :out std_ulogic;
        f_pic_tbl_ex1_act          :out std_ulogic;
        f_pic_add_ex1_act_b        :out std_ulogic;--set
        f_pic_lza_ex1_act_b        :out std_ulogic;--set
        f_pic_eov_ex2_act_b        :out std_ulogic;--set
        f_pic_nrm_ex3_act_b        :out std_ulogic;--set
        f_pic_rnd_ex3_act_b        :out std_ulogic;--set
        f_pic_scr_ex2_act_b        :out std_ulogic;--set



        f_pic_ex1_rnd_to_int                   :out std_ulogic;
        f_pic_ex1_fsel                         :out std_ulogic; 
        f_pic_ex1_frsp_ue1                     :out std_ulogic; 
        f_pic_ex2_frsp_ue1                     :out std_ulogic; 
        f_pic_ex2_ue1                          :out std_ulogic; 
        f_pic_ex1_effsub_raw                   :out std_ulogic; 
        f_pic_ex1_from_integer                 :out std_ulogic; 
        f_pic_ex1_sh_ovf_do                    :out std_ulogic; 
        f_pic_ex1_sh_ovf_ig_b                  :out std_ulogic; 
        f_pic_ex1_sh_unf_do                    :out std_ulogic; 
        f_pic_ex1_sh_unf_ig_b                  :out std_ulogic;

        f_pic_ex1_log2e                        :out std_ulogic;
        f_pic_ex1_pow2e                        :out std_ulogic;

        f_pic_ex1_ftdiv                        :out std_ulogic;
        f_pic_ex1_flush_en_sp                  :out std_ulogic;
        f_pic_ex1_flush_en_dp                  :out std_ulogic;

        f_pic_ex2_est_recip                    :out std_ulogic; 
        f_pic_ex2_est_rsqrt                    :out std_ulogic; 

        f_pic_ex2_force_sel_bexp               :out std_ulogic; 
        f_pic_ex2_lzo_dis_prod                 :out std_ulogic; 
        f_pic_ex2_sp_b                         :out std_ulogic; 
        f_pic_ex2_sp_lzo                       :out std_ulogic; 
        f_pic_ex2_to_integer                   :out std_ulogic;
        f_pic_ex2_prenorm                      :out std_ulogic;
        f_pic_ex2_math_bzer_b                  :out std_ulogic;
        f_pic_ex2_b_valid                      :out std_ulogic;
        f_pic_ex2_rnd_nr                       :out std_ulogic;
        f_pic_ex2_rnd_inf_ok                   :out std_ulogic;

        f_pic_ex3_cmp_sgnneg                   :out std_ulogic; 
        f_pic_ex3_cmp_sgnpos                   :out std_ulogic; 
        f_pic_ex3_is_eq                        :out std_ulogic; 
        f_pic_ex3_is_gt                        :out std_ulogic; 
        f_pic_ex3_is_lt                        :out std_ulogic; 
        f_pic_ex3_is_nan                       :out std_ulogic; 
        f_pic_ex3_sp_b                         :out std_ulogic; 
        f_pic_ex3_sel_est                      :out std_ulogic;        


        f_dcd_rf1_uc_ft_pos                    :in  std_ulogic; -- force div/sqrt result poitive
        f_dcd_rf1_uc_ft_neg                    :in  std_ulogic; -- force div/sqrt result poitive
        f_dcd_rf1_uc_mid                       :in  std_ulogic;
        f_dcd_rf1_uc_end                       :in  std_ulogic;
        f_dcd_rf1_uc_special                   :in  std_ulogic;
        f_dcd_ex2_uc_zx                        :in  std_ulogic;
        f_dcd_ex2_uc_vxidi                     :in  std_ulogic;
        f_dcd_ex2_uc_vxzdz                     :in  std_ulogic;
        f_dcd_ex2_uc_vxsqrt                    :in  std_ulogic;
        f_dcd_ex2_uc_vxsnan                    :in  std_ulogic;

        f_mad_ex3_uc_special                   :out std_ulogic;
        f_mad_ex3_uc_zx                        :out std_ulogic;
        f_mad_ex3_uc_vxidi                     :out std_ulogic;
        f_mad_ex3_uc_vxzdz                     :out std_ulogic;
        f_mad_ex3_uc_vxsqrt                    :out std_ulogic;
        f_mad_ex3_uc_vxsnan                    :out std_ulogic;
        f_mad_ex3_uc_res_sign                  :out std_ulogic;
        f_mad_ex3_uc_round_mode                :out std_ulogic_vector(0 to 1);





        f_pic_ex4_byp_prod_nz                  :out std_ulogic;
        f_pic_ex4_sel_est_b                    :out std_ulogic; 
        f_pic_ex1_nj_deni                      :out std_ulogic; 
        f_pic_ex4_nj_deno                      :out std_ulogic; 
        f_pic_ex4_oe                           :out std_ulogic; 
        f_pic_ex4_ov_en                        :out std_ulogic; 
        f_pic_ex4_ovf_en_oe0_b                 :out std_ulogic; 
        f_pic_ex4_ovf_en_oe1_b                 :out std_ulogic; 
        f_pic_ex4_quiet_b                      :out std_ulogic; 

        f_dcd_ex2_uc_inc_lsb                   :in  std_ulogic; 
        f_dcd_ex2_uc_guard                     :in  std_ulogic;
        f_dcd_ex2_uc_sticky                    :in  std_ulogic;
        f_dcd_ex2_uc_gs_v                      :in  std_ulogic; 

        f_pic_ex5_uc_inc_lsb                   :out std_ulogic; 
        f_pic_ex5_uc_guard                     :out std_ulogic; 
        f_pic_ex5_uc_sticky                    :out std_ulogic; 
        f_pic_ex5_uc_g_v                       :out std_ulogic; 
        f_pic_ex5_uc_s_v                       :out std_ulogic; 

        f_pic_ex4_rnd_inf_ok_b                 :out std_ulogic; 
        f_pic_ex4_rnd_ni_b                     :out std_ulogic; 
        f_pic_ex4_rnd_nr_b                     :out std_ulogic; 
        f_pic_ex4_sel_fpscr_b                  :out std_ulogic; 
        f_pic_ex4_sp_b                         :out std_ulogic; 
        f_pic_ex4_spec_inf_b                   :out std_ulogic; 
        f_pic_ex4_spec_sel_k_e                 :out std_ulogic; 
        f_pic_ex4_spec_sel_k_f                 :out std_ulogic;

        f_pic_ex4_to_int_ov_all                :out std_ulogic; 

        f_pic_ex4_to_integer_b                 :out std_ulogic; 
        f_pic_ex4_word_b                       :out std_ulogic; 
        f_pic_ex4_uns_b                        :out std_ulogic; 
        f_pic_ex4_ue                           :out std_ulogic; 
        f_pic_ex4_uf_en                        :out std_ulogic; 
        f_pic_ex4_unf_en_ue0_b                 :out std_ulogic; 
        f_pic_ex4_unf_en_ue1_b                 :out std_ulogic; 

        f_pic_ex5_en_exact_zero                :out std_ulogic; 
        f_pic_ex5_frsp                         :out std_ulogic; 
        f_pic_ex5_compare_b                    :out std_ulogic; 
        f_pic_ex5_fi_pipe_v_b                  :out std_ulogic; 
        f_pic_ex5_fi_spec_b                    :out std_ulogic; 
        f_pic_ex5_flag_vxcvi_b                 :out std_ulogic; 
        f_pic_ex5_flag_vxidi_b                 :out std_ulogic; 
        f_pic_ex5_flag_vximz_b                 :out std_ulogic; 
        f_pic_ex5_flag_vxisi_b                 :out std_ulogic; 
        f_pic_ex5_flag_vxsnan_b                :out std_ulogic; 
        f_pic_ex5_flag_vxsqrt_b                :out std_ulogic; 
        f_pic_ex5_flag_vxvc_b                  :out std_ulogic; 
        f_pic_ex5_flag_vxzdz_b                 :out std_ulogic; 
        f_pic_ex5_flag_zx_b                    :out std_ulogic; 
        f_pic_ex5_fprf_hold_b                  :out std_ulogic; 
        f_pic_ex5_fprf_pipe_v_b                :out std_ulogic; 
        f_pic_ex5_fprf_spec_b                  :out std_ulogic_vector(0 to 4); 
        f_pic_ex5_fr_pipe_v_b                  :out std_ulogic; 
        f_pic_ex5_fr_spec_b                    :out std_ulogic; 
        f_pic_ex5_invert_sign                  :out std_ulogic;

        f_pic_ex5_k_nan                        :out std_ulogic;
        f_pic_ex5_k_inf                        :out std_ulogic;
        f_pic_ex5_k_max                        :out std_ulogic;
        f_pic_ex5_k_zer                        :out std_ulogic;
        f_pic_ex5_k_one                        :out std_ulogic;
        f_pic_ex5_k_int_maxpos                 :out std_ulogic;
        f_pic_ex5_k_int_maxneg                 :out std_ulogic;
        f_pic_ex5_k_int_zer                    :out std_ulogic;
        f_pic_ex5_ox_pipe_v_b                  :out std_ulogic; 
        f_pic_ex5_round_sign                   :out std_ulogic; 
        f_pic_ex5_ux_pipe_v_b                  :out std_ulogic; 
        f_pic_ex5_scr_upd_move_b               :out std_ulogic; 
        f_pic_ex5_scr_upd_pipe_b               :out std_ulogic;
        f_pic_ex5_fpr_wr_dis_b                 :out std_ulogic

);



end fuq_pic; -- ENTITY

architecture fuq_pic of fuq_pic is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal thold_0_b , thold_0, forcee,  sg_0 :std_ulogic;
    signal rf1_act  , ex1_act  , ex2_act  , ex3_act  , ex4_act :std_ulogic;
    signal ex1_act_add :std_ulogic;
    signal ex1_act_lza :std_ulogic;
    signal ex2_act_eov :std_ulogic;
    signal ex2_act_scr :std_ulogic;
    signal ex3_act_nrm :std_ulogic;
    signal ex3_act_rnd :std_ulogic;
    signal spare_unused :std_ulogic_vector(0 to 3);
    signal act_so  ,     act_si       :std_ulogic_vector(0 to 20);

    signal ex1_ctl_so  , ex1_ctl_si   :std_ulogic_vector(0 to 42);
    signal ex2_ctl_so  , ex2_ctl_si   :std_ulogic_vector(0 to 56);
    signal ex3_ctl_so  , ex3_ctl_si   :std_ulogic_vector(0 to 33);
    signal ex4_ctl_so  , ex4_ctl_si   :std_ulogic_vector(0 to 28);
    signal ex2_flg_so  , ex2_flg_si   :std_ulogic_vector(0 to 17);
    signal ex3_scr_so  , ex3_scr_si   :std_ulogic_vector(0 to  7);
    signal ex3_flg_so  , ex3_flg_si   :std_ulogic_vector(0 to 46);
    signal ex4_scr_so  , ex4_scr_si   :std_ulogic_vector(0 to  7);
    signal ex4_flg_so  , ex4_flg_si   :std_ulogic_vector(0 to 37);                
    signal ex5_flg_so  , ex5_flg_si   :std_ulogic_vector(0 to 41);                 

    signal ex4_may_ovf           :std_ulogic;
    signal ex5_unused          :std_ulogic;
    signal ex2_a_sign            :std_ulogic;
    signal ex3_pass_nan          :std_ulogic;
    signal ex2_pass_x          :std_ulogic;

    signal ex1_rnd_fpscr, ex2_rnd_fpscr, ex3_rnd_fpscr :std_ulogic_vector(0 to 1);
    signal ex1_div_sign, ex2_div_sign, ex3_div_sign :std_ulogic ;

    signal ex3_ve        :std_ulogic ;
    signal ex3_oe        :std_ulogic ;
    signal ex3_ue        :std_ulogic ;
    signal ex3_ze        :std_ulogic ;
    signal ex3_xe        :std_ulogic ;
    signal ex3_nonieee   :std_ulogic ;
    signal ex3_rnd0      :std_ulogic ;
    signal ex3_rnd1      :std_ulogic ;
    signal ex4_ve        :std_ulogic ;
    signal ex4_oe        :std_ulogic ;
    signal ex4_ue        :std_ulogic ;
    signal ex4_ze        :std_ulogic ;
    signal ex4_xe        :std_ulogic ;
    signal ex4_nonieee   :std_ulogic ;
    signal ex4_rnd0      :std_ulogic ;
    signal ex4_rnd1      :std_ulogic ;
    signal ex2_toint_nan_sign :std_ulogic ;

    signal ex1_uc_ft_neg, ex2_uc_ft_neg, ex3_uc_ft_neg  :std_ulogic; 
    signal ex1_uc_ft_pos, ex2_uc_ft_pos, ex3_uc_ft_pos  :std_ulogic; 
    signal ex1_a_inf             :std_ulogic;
    signal ex1_a_nan             :std_ulogic;
    signal ex1_a_sign            :std_ulogic;
    signal ex1_b_inf             :std_ulogic;
    signal ex1_b_nan             :std_ulogic;
    signal ex1_b_sign            :std_ulogic;
    signal ex1_b_sign_adj        :std_ulogic;
    signal ex1_b_sign_adj_x      :std_ulogic;
    signal ex1_b_sign_alt        :std_ulogic;
    signal ex1_a_valid           :std_ulogic;
    signal ex1_c_valid           :std_ulogic;
    signal ex1_b_valid           :std_ulogic;
    signal ex1_c_inf             :std_ulogic;
    signal ex1_sp_invalid        :std_ulogic;
    signal ex2_sp_invalid        :std_ulogic;
    signal ex1_c_nan             :std_ulogic;
    signal ex1_c_sign            :std_ulogic;
    signal ex1_compare           :std_ulogic;
    signal ex1_div_beg           :std_ulogic;
    signal ex1_est_recip         :std_ulogic;
    signal ex1_est_rsqrt         :std_ulogic;
    signal ex1_op_rnd_v          :std_ulogic;
    signal ex1_op_rnd          :std_ulogic_vector(0 to 1);
    signal ex1_from_integer      :std_ulogic;
    signal ex1_frsp              :std_ulogic;
    signal ex1_fsel              :std_ulogic;
    signal ex1_inv_sign          :std_ulogic;
    signal ex1_lzo_dis           :std_ulogic;
    signal ex1_uc_mid, ex2_uc_mid, ex3_uc_mid, ex4_uc_mid            :std_ulogic;
    signal ex1_math              :std_ulogic;
    signal ex1_move              :std_ulogic;
    signal ex1_mv_from_scr       :std_ulogic;
    signal ex1_mv_to_scr         :std_ulogic;
    signal ex1_p_sign            :std_ulogic;
    signal ex1_prenorm           :std_ulogic;
    signal ex1_sign_ctl          :std_ulogic_vector(0 to 1);
    signal ex1_sp                :std_ulogic;
    signal ex1_sp_b              :std_ulogic;
    signal ex1_sqrt_beg          :std_ulogic;
    signal ex1_sub_op            :std_ulogic;
    signal ex1_to_integer        :std_ulogic;
    signal ex1_ordered         :std_ulogic;
    signal ex1_word              :std_ulogic;
    signal rf1_uns               :std_ulogic;
    signal rf1_sp_conv           :std_ulogic;
    signal ex1_uns               :std_ulogic;
    signal ex2_uns               :std_ulogic;
    signal ex3_uns               :std_ulogic;
    signal ex4_uns               :std_ulogic;
    signal ex1_sp_conv           :std_ulogic;
    signal ex2_a_frac_msb        :std_ulogic;
    signal ex2_a_inf             :std_ulogic;
    signal ex2_a_nan             :std_ulogic;
    signal ex2_a_zero            :std_ulogic;
    signal ex2_any_inf           :std_ulogic;
    signal ex2_b_frac_msb        :std_ulogic;
    signal ex2_b_inf             :std_ulogic;
    signal ex2_b_nan             :std_ulogic;
    signal ex2_b_sign_adj        :std_ulogic;
    signal ex2_to_int_uns_neg    :std_ulogic;
    signal ex3_to_int_uns_neg    :std_ulogic;
    signal ex4_to_int_uns_neg    :std_ulogic;
    signal ex2_wd_ov_x           :std_ulogic;
    signal ex2_dw_ov_x           :std_ulogic;
    signal ex2_b_sign_alt        :std_ulogic;
    signal ex2_b_zero            :std_ulogic;
    signal ex3_b_zero            :std_ulogic;
    signal ex2_c_frac_msb        :std_ulogic;
    signal ex2_c_inf             :std_ulogic;
    signal ex2_c_nan             :std_ulogic;
    signal ex2_c_zero            :std_ulogic;
    signal ex2_cmp_sgnneg  :std_ulogic;
    signal ex2_cmp_sgnpos  :std_ulogic;
    signal ex2_cmp_zero    :std_ulogic;
    signal ex2_compare           :std_ulogic;
    signal ex2_div_beg           :std_ulogic;
    signal ex3_div_beg           :std_ulogic;
    signal ex4_div_beg           :std_ulogic;
    signal ex2_est_recip         :std_ulogic;
    signal ex2_est_rsqrt         :std_ulogic;
    signal ex2_rnd_dis       :std_ulogic;
    signal ex2_op_rnd       :std_ulogic_vector(0 to 1);
    signal ex2_from_integer      :std_ulogic;
    signal ex2_frsp              :std_ulogic;
    signal ex2_fsel              :std_ulogic;
    signal ex2_gen_inf     :std_ulogic;
    signal ex2_gen_max     :std_ulogic;
    signal ex2_gen_nan     :std_ulogic;
    signal ex2_gen_zero    :std_ulogic;
    signal ex2_inf_sign    :std_ulogic;
    signal ex2_inv_sign          :std_ulogic;
    signal ex2_is_eq       :std_ulogic;
    signal ex2_is_gt       :std_ulogic;
    signal ex2_is_lt       :std_ulogic;
    signal ex2_is_nan      :std_ulogic;
    signal ex2_lzo_dis           :std_ulogic;
    signal ex2_math              :std_ulogic;
    signal ex2_move              :std_ulogic;
    signal ex2_mv_from_scr       :std_ulogic;
    signal ex2_mv_to_scr         :std_ulogic;
    signal ex2_neg_sqrt_nz       :std_ulogic;
    signal ex2_p_inf             :std_ulogic;
    signal ex2_p_sign            :std_ulogic;
    signal ex2_p_zero            :std_ulogic;
    signal ex2_pass_en           :std_ulogic;
    signal ex2_pass_nan          :std_ulogic;
    signal ex2_prenorm           :std_ulogic;
    signal ex2_quiet             :std_ulogic;
    signal ex2_rnd0              :std_ulogic;
    signal ex2_rnd1              :std_ulogic;
    signal ex2_rnd_inf_ok        :std_ulogic;
    signal ex2_rnd_nr            :std_ulogic;
    signal ex2_sp                :std_ulogic;
    signal ex2_sp_notrunc        :std_ulogic;
    signal ex2_sp_o_frsp         :std_ulogic;
    signal ex2_spec_sign         :std_ulogic;
    signal ex2_sqrt_beg          :std_ulogic;
    signal ex3_sqrt_beg          :std_ulogic;
    signal ex4_sqrt_beg          :std_ulogic;
    signal ex2_sub_op            :std_ulogic;
    signal ex2_to_integer        :std_ulogic;
    signal ex2_ue                :std_ulogic;
    signal ex2_ordered         :std_ulogic;
    signal ex2_nonieee           :std_ulogic;
    signal ex2_ze                :std_ulogic;
    signal ex2_ve                :std_ulogic;
    signal ex2_oe                :std_ulogic;
    signal ex2_xe                :std_ulogic;
    signal ex2_vxcvi             :std_ulogic;
    signal ex2_vxidi             :std_ulogic;
    signal ex2_vximz             :std_ulogic;
    signal ex2_vxisi             :std_ulogic;
    signal ex2_vxsnan            :std_ulogic;
    signal ex2_vxsqrt            :std_ulogic;
    signal ex2_vxvc              :std_ulogic;
    signal ex2_vxzdz             :std_ulogic;
    signal ex2_word              :std_ulogic;
    signal ex2_zx                :std_ulogic;
    signal ex3_b_sign_adj        :std_ulogic;
    signal ex3_b_sign_alt        :std_ulogic;
    signal ex3_cmp_sgnneg        :std_ulogic;
    signal ex3_cmp_sgnpos        :std_ulogic;
    signal ex3_compare           :std_ulogic;
    signal ex3_dw_ov             :std_ulogic;  
    signal ex3_dw_ov_if          :std_ulogic;  
    signal ex3_effsub_eac        :std_ulogic;  
    signal ex4_effsub_eac        :std_ulogic;  
    signal ex3_est_recip         :std_ulogic;
    signal ex3_est_rsqrt         :std_ulogic;
    signal ex3_rnd_dis           :std_ulogic;
    signal ex3_from_integer      :std_ulogic;
    signal ex3_frsp              :std_ulogic;
    signal ex3_fsel              :std_ulogic;
    signal ex3_gen_inf           :std_ulogic;
    signal ex3_gen_inf_mutex     :std_ulogic;
    signal ex3_gen_max_mutex     :std_ulogic;
    signal ex3_gen_max           :std_ulogic;
    signal ex3_gen_nan           :std_ulogic;
    signal ex3_gen_nan_mutex     :std_ulogic;
    signal ex3_gen_zer_mutex     :std_ulogic;
    signal ex3_gen_zero          :std_ulogic;
    signal ex3_inv_sign          :std_ulogic;
    signal ex3_is_eq             :std_ulogic;
    signal ex3_is_gt             :std_ulogic;
    signal ex3_is_lt             :std_ulogic;
    signal ex3_is_nan            :std_ulogic;
    signal ex3_math              :std_ulogic;
    signal ex3_move              :std_ulogic;
    signal ex3_mv_from_scr       :std_ulogic;
    signal ex3_mv_to_scr         :std_ulogic;
    signal ex3_oe_x              :std_ulogic;
    signal ex3_ov_en             :std_ulogic;
    signal ex3_ovf_en_oe0        :std_ulogic;
    signal ex3_ovf_en_oe1        :std_ulogic;
    signal ex3_p_sign            :std_ulogic;
    signal ex3_p_sign_may        :std_ulogic;
    signal ex3_prenorm           :std_ulogic;
    signal ex3_quiet             :std_ulogic;
    signal ex3_sel_byp           :std_ulogic;  
    signal ex3_sh_ovf            :std_ulogic;  
    signal ex3_sh_unf            :std_ulogic;  
    signal ex3_sign_nco          :std_ulogic;
    signal ex3_sign_pco          :std_ulogic;
    signal ex3_sp                :std_ulogic;
    signal ex3_sp_x              :std_ulogic;
    signal ex3_sp_conv           :std_ulogic;
    signal ex2_sp_conv           :std_ulogic;
    signal ex3_spec_sel_e        :std_ulogic;
    signal ex3_spec_sel_f        :std_ulogic;
    signal ex3_spec_sign         :std_ulogic;
    signal ex3_spec_sign_x       :std_ulogic;
    signal ex3_spec_sign_sel     :std_ulogic;
    signal ex3_sub_op            :std_ulogic;
    signal ex3_to_int_dw         :std_ulogic;
    signal ex3_to_int_ov         :std_ulogic;
    signal ex3_to_int_ov_if      :std_ulogic;
    signal ex3_to_int_wd         :std_ulogic;
    signal ex3_to_integer        :std_ulogic;
    signal ex3_ue_x              :std_ulogic;
    signal ex3_uf_en             :std_ulogic;
    signal ex3_unf_en_oe0        :std_ulogic;
    signal ex3_unf_en_oe1        :std_ulogic;
    signal ex3_vxcvi             :std_ulogic;
    signal ex3_vxidi             :std_ulogic;
    signal ex3_vximz             :std_ulogic;
    signal ex3_vxisi             :std_ulogic;
    signal ex3_vxsnan            :std_ulogic;
    signal ex3_vxsqrt            :std_ulogic;
    signal ex3_vxvc              :std_ulogic;
    signal ex3_vxzdz             :std_ulogic;
    signal ex3_wd_ov             :std_ulogic;
    signal ex3_wd_ov_if          :std_ulogic;  
    signal ex3_word              :std_ulogic;
    signal ex3_word_to           :std_ulogic;
    signal ex3_zx                :std_ulogic;
    signal ex4_compare           :std_ulogic;
    signal ex5_compare           :std_ulogic;
    signal ex4_en_exact_zero     :std_ulogic;
    signal ex4_est_recip         :std_ulogic;
    signal ex4_est_rsqrt         :std_ulogic;
    signal ex4_rnd_dis           :std_ulogic;
    signal ex4_fpr_wr_dis        :std_ulogic;
    signal ex4_fprf_pipe_v       :std_ulogic;
    signal ex4_fprf_spec         :std_ulogic_vector(0 to 4);
    signal ex4_fprf_spec_x       :std_ulogic_vector(0 to 4);
    signal ex4_fr_pipe_v         :std_ulogic;
    signal ex4_from_integer      :std_ulogic;
    signal ex4_frsp              :std_ulogic;
    signal ex5_frsp              :std_ulogic;
    signal ex4_fsel              :std_ulogic;
    signal ex4_gen_inf           :std_ulogic;
    signal ex4_gen_inf_sign      :std_ulogic;
    signal ex4_gen_max           :std_ulogic;
    signal ex4_gen_nan           :std_ulogic;
    signal ex4_pass_nan          :std_ulogic;
    signal ex4_gen_zero          :std_ulogic;
    signal ex4_inv_sign          :std_ulogic;
    signal ex4_invert_sign       :std_ulogic;
    signal ex4_k_max_fp          :std_ulogic;
    signal ex4_math              :std_ulogic;
    signal ex4_move              :std_ulogic;
    signal ex4_mv_from_scr       :std_ulogic;
    signal ex4_mv_to_scr         :std_ulogic;
    signal ex4_ov_en             :std_ulogic;
    signal ex4_ovf_en_oe0        :std_ulogic;
    signal ex4_ovf_en_oe1        :std_ulogic;
    signal ex4_ox_pipe_v         :std_ulogic;
    signal ex4_prenorm           :std_ulogic;
    signal ex4_quiet             :std_ulogic;
    signal ex4_rnd_en            :std_ulogic;
    signal ex4_rnd_inf_ok        :std_ulogic;
    signal ex4_rnd_pi            :std_ulogic;
    signal ex4_rnd_ni            :std_ulogic;
    signal ex4_rnd_nr            :std_ulogic;
    signal ex4_rnd_zr            :std_ulogic;
    signal ex4_rnd_nr_ok         :std_ulogic;
    signal ex4_round_sign        :std_ulogic;
    signal ex4_round_sign_x      :std_ulogic;
    signal ex4_scr_upd_move      :std_ulogic;
    signal ex4_scr_upd_pipe      :std_ulogic;
    signal ex4_sel_spec_e        :std_ulogic;
    signal ex4_sel_spec_f        :std_ulogic;
    signal ex4_sel_spec_fr       :std_ulogic;
    signal ex4_sign_nco          :std_ulogic;
    signal ex4_sign_pco          :std_ulogic;
    signal ex4_sign_nco_x        :std_ulogic;
    signal ex4_sign_pco_x        :std_ulogic;
    signal ex4_sign_nco_xx       :std_ulogic;
    signal ex4_sign_pco_xx       :std_ulogic;
    signal ex4_sp                :std_ulogic;
    signal ex4_spec_sel_e        :std_ulogic;
    signal ex4_spec_sel_f        :std_ulogic;
    signal ex4_sub_op            :std_ulogic;
    signal ex4_to_int_dw         :std_ulogic;  
    signal ex4_to_int_ov         :std_ulogic;  
    signal ex4_to_int_ov_if      :std_ulogic;
    signal ex4_to_int_wd         :std_ulogic;
    signal ex4_to_integer        :std_ulogic;
    signal ex4_uf_en             :std_ulogic;
    signal ex4_unf_en_oe0        :std_ulogic;
    signal ex4_unf_en_oe1        :std_ulogic;
    signal ex4_upd_fpscr_ops     :std_ulogic;
    signal ex4_vx                :std_ulogic;
    signal ex4_vxidi             :std_ulogic;
    signal ex4_vximz             :std_ulogic;
    signal ex4_vxisi             :std_ulogic;
    signal ex4_vxsnan            :std_ulogic;
    signal ex4_vxsqrt            :std_ulogic;
    signal ex4_vxvc              :std_ulogic;
    signal ex4_vxcvi             :std_ulogic;
    signal ex4_vxcvi_ov          :std_ulogic;
    signal ex4_to_int_ov_all_x   :std_ulogic;
    signal ex4_to_int_ov_all     :std_ulogic;
    signal ex4_to_int_ov_all_gt  :std_ulogic;
    signal ex4_to_int_k_sign     :std_ulogic;
    signal ex4_vxzdz             :std_ulogic;
    signal ex4_word              :std_ulogic;
    signal ex4_zx                :std_ulogic;
    signal ex5_en_exact_zero     :std_ulogic;
    signal ex5_fpr_wr_dis        :std_ulogic;
    signal ex5_fprf_pipe_v       :std_ulogic;
    signal ex5_fprf_spec         :std_ulogic_vector(0 to 4);
    signal ex5_fr_pipe_v         :std_ulogic;
    signal ex5_invert_sign       :std_ulogic;
    signal ex5_ox_pipe_v         :std_ulogic;
    signal ex5_round_sign        :std_ulogic;
    signal ex5_scr_upd_move      :std_ulogic;
    signal ex5_scr_upd_pipe      :std_ulogic;
    signal ex5_vxcvi             :std_ulogic;
    signal ex5_vxidi             :std_ulogic;  
    signal ex5_vximz             :std_ulogic;
    signal ex5_vxisi             :std_ulogic;
    signal ex5_vxsnan            :std_ulogic;
    signal ex5_vxsqrt            :std_ulogic;
    signal ex5_vxvc              :std_ulogic;
    signal ex5_vxzdz             :std_ulogic;
    signal ex5_zx                :std_ulogic;   
    signal ex5_k_nan          :std_ulogic;
    signal ex5_k_inf          :std_ulogic;
    signal ex5_k_max          :std_ulogic;
    signal ex5_k_zer          :std_ulogic;
    signal ex5_k_int_maxpos   :std_ulogic;
    signal ex5_k_int_maxneg   :std_ulogic;
    signal ex5_k_int_zer      :std_ulogic;
    signal ex4_gen_any        :std_ulogic;
    signal ex4_k_nan          :std_ulogic;
    signal ex4_k_inf          :std_ulogic;
    signal ex4_k_max          :std_ulogic;
    signal ex4_k_zer          :std_ulogic;
    signal ex4_k_int_maxpos   :std_ulogic;
    signal ex4_k_int_maxneg   :std_ulogic;
    signal ex4_k_int_zer      :std_ulogic;
    signal ex4_k_nan_x          :std_ulogic;
    signal ex4_k_inf_x          :std_ulogic;
    signal ex4_k_max_x          :std_ulogic;
    signal ex4_k_zer_x          :std_ulogic;
    signal ex2_a_valid :std_ulogic;       
    signal ex2_c_valid :std_ulogic;       
    signal ex2_b_valid :std_ulogic;       
    signal ex2_prod_zero :std_ulogic;       
    signal ex4_byp_prod_nz        :std_ulogic ;
    signal ex3_byp_prod_nz        :std_ulogic ;
    signal ex3_byp_prod_nz_sub    :std_ulogic ;
    signal ex3_a_valid            :std_ulogic ;
    signal ex3_c_valid            :std_ulogic ;
    signal ex3_b_valid            :std_ulogic ;
    signal ex3_prod_zero          :std_ulogic ;
    signal ex4_int_fr             :std_ulogic ;
    signal ex4_int_fi             :std_ulogic ;
    signal ex4_fi_spec    :std_ulogic;
    signal ex4_fr_spec    :std_ulogic;
    signal ex5_fi_spec    :std_ulogic;
    signal ex5_fr_spec    :std_ulogic;
    signal ex2_toint_genz :std_ulogic;
    signal ex2_a_snan      :std_ulogic;
    signal ex2_b_snan      :std_ulogic;
    signal ex2_c_snan      :std_ulogic;
    signal ex2_a_qnan      :std_ulogic;
    signal ex2_b_qnan      :std_ulogic;
    signal ex2_nan_op_grp1 :std_ulogic;
    signal ex2_nan_op_grp2 :std_ulogic;
    signal ex2_compo       :std_ulogic;
    signal ex5_fprf_hold   :std_ulogic;
    signal ex4_fprf_hold   :std_ulogic;
    signal ex4_fprf_hold_ops   :std_ulogic;
    signal ex1_bf_10000 :std_ulogic;
    signal ex2_bf_10000   :std_ulogic;
    signal ex3_bf_10000   :std_ulogic;

    signal ex1_rnd_to_int   :std_ulogic;
    signal ex2_rnd_to_int   :std_ulogic;
    signal ex3_rnd_to_int   :std_ulogic;
    signal ex4_rnd_to_int   :std_ulogic;
    signal ex3_lt_bias :std_ulogic;
    signal ex3_eq_bias_m1 :std_ulogic;
signal ex3_gen_rnd2int :std_ulogic;
signal ex3_gen_one_rnd2int :std_ulogic;
signal ex3_gen_zer_rnd2int :std_ulogic;
signal ex2_gen_one, ex3_gen_one, ex3_gen_one_mutex :std_ulogic;
signal ex4_gen_one :std_ulogic;
signal ex4_k_one :std_ulogic;
signal ex5_k_one :std_ulogic;
signal ex4_k_one_x :std_ulogic;
signal ex3_rnd2int_up :std_ulogic;
signal ex4_sel_est :std_ulogic;
signal ex1_ve             :std_ulogic;
signal ex1_oe             :std_ulogic;
signal ex1_ue             :std_ulogic;
signal ex1_ze             :std_ulogic;
signal ex1_xe             :std_ulogic;
signal ex1_nonieee        :std_ulogic;
signal ex1_rnd0           :std_ulogic;
signal ex1_rnd1           :std_ulogic;
signal ex1_rnd_dis        :std_ulogic;
  signal rf1_fsel           :std_ulogic;
  signal rf1_from_integer   :std_ulogic;
  signal rf1_to_integer     :std_ulogic;
  signal rf1_math           :std_ulogic;
  signal rf1_est_recip      :std_ulogic;
  signal rf1_est_rsqrt      :std_ulogic;
  signal rf1_move           :std_ulogic;
  signal rf1_compare        :std_ulogic;
  signal rf1_prenorm        :std_ulogic;
  signal rf1_frsp           :std_ulogic;
  signal rf1_mv_to_scr      :std_ulogic;
  signal rf1_mv_from_scr    :std_ulogic;
  signal rf1_div_beg       :std_ulogic;
  signal rf1_sqrt_beg       :std_ulogic;
  signal rf1_sp             :std_ulogic;
  signal rf1_word           :std_ulogic;
  signal rf1_ordered        :std_ulogic;
  signal rf1_sub_op         :std_ulogic;
  signal rf1_op_rnd_v       :std_ulogic;
  signal rf1_inv_sign       :std_ulogic;
  signal rf1_sign_ctl       :std_ulogic_vector(0 to 1);
  signal rf1_sgncpy, ex1_sgncpy       :std_ulogic;
  signal rf1_op_rnd         :std_ulogic_vector(0 to 1);
  signal rf1_rnd_to_int     :std_ulogic;
  signal ex2_effsub_eac :std_ulogic;
  signal ex1_flush_dis_dp, ex1_flush_dis_sp :std_ulogic;
  signal ex4_to_integer_ken :std_ulogic;
  signal rf1_log2e, rf1_pow2e :std_ulogic;
  signal ex1_log2e, ex1_pow2e :std_ulogic;
  signal ex2_log2e, ex2_pow2e :std_ulogic;
  signal ex3_log2e, ex3_pow2e :std_ulogic;
  signal ex4_log2e, ex4_pow2e :std_ulogic;
  signal ex2_log_ofzero :std_ulogic ;
  signal ex2_bexpu_le126      , ex2_gt126 , ex2_ge128     :std_ulogic;
  signal ex2_gen_nan_log :std_ulogic ;
  signal ex2_gen_inf_log :std_ulogic ;
  signal ex2_gen_inf_pow :std_ulogic ;
  signal ex2_gen_zero_pow :std_ulogic ;
  signal ex1_ovf_unf_dis, ex2_ovf_unf_dis, ex3_ovf_unf_dis, ex4_ovf_unf_dis :std_ulogic;
  signal ex2_exact_zero_sign :std_ulogic ;
  signal ex2_rnd_ni :std_ulogic ;
  signal ex2_gen_inf_sq :std_ulogic;
  signal ex2_gen_inf_dv :std_ulogic;
  signal ex2_gen_zer_sq :std_ulogic;
  signal ex2_gen_zer_dv :std_ulogic;
  signal ex2_gen_nan_sq :std_ulogic;
  signal ex2_gen_nan_dv :std_ulogic;
  signal ex2_prenorm_special :std_ulogic ;
  signal ex2_prenorm_sign  :std_ulogic ;

  signal ex3_uc_inc_lsb  , ex4_uc_inc_lsb  , ex5_uc_inc_lsb  :std_ulogic;
  signal ex3_uc_guard    , ex4_uc_guard    , ex5_uc_guard    :std_ulogic;
  signal ex3_uc_sticky   , ex4_uc_sticky   , ex5_uc_sticky   :std_ulogic;
  signal ex3_uc_gs_v     , ex4_uc_gs_v     , ex4_uc_s_v , ex4_uc_g_v, ex5_uc_s_v , ex5_uc_g_v    :std_ulogic;
  signal ex2_uc_g_ig     ,ex3_uc_g_ig     , ex4_uc_g_ig :std_ulogic;
  signal ex1_force_excp_dis :std_ulogic ;
  signal rf1_uc_end_nspec, ex1_uc_end_nspec :std_ulogic;
  signal rf1_uc_end_spec, ex1_uc_end_spec, ex2_uc_end_spec, ex3_uc_end_spec, ex4_uc_end_spec :std_ulogic;
  signal unused :std_ulogic;
  signal rf1_nj_deno_x, ex1_nj_deno, ex2_nj_deno, ex3_nj_deno, ex3_nj_deno_x, ex4_nj_deno : std_ulogic;
  signal rf1_nj_deni_x, ex1_nj_deni, rf1_den_ok :std_ulogic;
  signal ex2_gen_nan_pow :std_ulogic ;
  signal ex2_inf_and_beyond_sp :std_ulogic ;
  signal ex1_ftdiv, ex1_ftsqrt, ex2_ftdiv, ex2_ftsqrt, ex2_accuracy , ex2_b_imp :std_ulogic ; 


begin

  unused <= ex3_byp_prod_nz_sub or ex4_sel_spec_f or
            rf1_act or 
            ex2_op_rnd(0) or --lat--
            ex2_op_rnd(1) or --lat--
            ex3_b_sign_adj or  --lat--
            ex3_b_valid or --lat--
            ex3_gen_max or --lat-- ????
            ex3_sh_unf or --lat--
            ex3_sh_ovf or --lat--
            ex4_nonieee or --lat--
            ex4_xe or --lat--
            ex4_fsel or --lat--
            ex4_move or --lat--
            ex4_prenorm or --lat--
            ex4_div_beg or --lat--
            ex4_sqrt_beg or --lat--
            ex4_sub_op or --lat--
            ex4_log2e or --lat--
            ex4_pow2e or --lat--
            ex5_unused; --lat--


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

    

    act_lat:  tri_rlmreg_p generic map (width=> 21, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        forcee => forcee, --tidn,
        delay_lclkr      => delay_lclkr(4), --tidn,
        mpw1_b           => mpw1_b(4), --tidn,
        mpw2_b           => mpw2_b(0), --tidn,
        act              => fpu_enable, --tiup
        thold_b          => thold_0_b, --tiup,
        sg               => sg_0,  --tidn,
        scout            => act_so  ,                      
        scin             => act_si  ,                    
        -------------------
         din(0)             => spare_unused(0),
         din(1)             => spare_unused(1),
         din(2)             =>   tiup,         
         din(3)             => f_dcd_rf1_act,  
         din(4)             => f_dcd_rf1_act,  
         din(5)             => f_dcd_rf1_act,  
         din(6)             => f_dcd_rf1_act,  
         din(7)             => tiup,           
         din(8)             => f_dcd_rf1_act , 
         din(9)             => f_dcd_rf1_act,  
         din(10)            => f_dcd_rf1_act,  
         din(11)            => f_dcd_rf1_act,  
         din(12)            => ex1_act,
         din(13)            => ex1_act,
         din(14)            => ex1_act,
         din(15)            => ex2_act,
         din(16)            => ex2_act,
         din(17)            => ex2_act,
         din(18)            => ex3_act,
         din(19)            => spare_unused(2),
         din(20)            => spare_unused(3),
        -------------------
        dout(0)             => spare_unused(0),
        dout(1)             => spare_unused(1),
        dout(2)             => f_pic_fmt_ex1_act , --output
        dout(3)             => f_pic_eie_ex1_act , --output
        dout(4)             => f_pic_mul_ex1_act , --output
        dout(5)             => f_pic_alg_ex1_act , --output
        dout(6)             => f_pic_cr2_ex1_act , --output
        dout(7)             => rf1_act,
        dout(8)             => f_pic_tbl_ex1_act , --output
        dout(9)             => ex1_act,
        dout(10)            => ex1_act_add ,
        dout(11)            => ex1_act_lza ,
        dout(12)            => ex2_act,
        dout(13)            => ex2_act_eov ,
        dout(14)            => ex2_act_scr ,
        dout(15)            => ex3_act,
        dout(16)            => ex3_act_nrm ,
        dout(17)            => ex3_act_rnd ,
        dout(18)            => ex4_act,
        dout(19)            => spare_unused(2) ,
        dout(20)            => spare_unused(3) );



        f_pic_add_ex1_act_b  <= not  ex1_act_add ;
        f_pic_lza_ex1_act_b  <= not  ex1_act_lza ;
        f_pic_eov_ex2_act_b  <= not  ex2_act_eov ;
        f_pic_scr_ex2_act_b  <= not  ex2_act_scr ;
        f_pic_nrm_ex3_act_b  <= not  ex3_act_nrm ;
        f_pic_rnd_ex3_act_b  <= not  ex3_act_rnd ;



--//################################################################
--//# ex1 latches
--//################################################################


  rf1_fsel           <= not f_dcd_rf1_fsel_b           ;
  rf1_from_integer   <= not f_dcd_rf1_from_integer_b   ;
  rf1_to_integer     <= not f_dcd_rf1_to_integer_b     ;
  rf1_math           <= not f_dcd_rf1_math_b           ;
  rf1_est_recip      <= not f_dcd_rf1_est_recip_b      ;
  rf1_est_rsqrt      <= not f_dcd_rf1_est_rsqrt_b      ;
  rf1_move           <= not f_dcd_rf1_move_b           ;
  rf1_compare        <= not f_dcd_rf1_compare_b        ;
  rf1_prenorm        <= not(f_dcd_rf1_prenorm_b) or f_dcd_rf1_div_beg or f_dcd_rf1_sqrt_beg ;
  rf1_frsp           <= not f_dcd_rf1_frsp_b           ;
  rf1_mv_to_scr      <= not f_dcd_rf1_mv_to_scr_b      ;
  rf1_mv_from_scr    <= not f_dcd_rf1_mv_from_scr_b    ;
  rf1_div_beg        <=     f_dcd_rf1_div_beg          ;
  rf1_sqrt_beg       <=     f_dcd_rf1_sqrt_beg         ;
  rf1_sp             <= not f_dcd_rf1_sp               ;
  rf1_word           <= not f_dcd_rf1_word_b           ;
  rf1_uns            <= not f_dcd_rf1_uns_b            ;
  rf1_sp_conv        <= not f_dcd_rf1_sp_conv_b        ;
  rf1_ordered        <= not f_dcd_rf1_ordered_b        ;
  rf1_sub_op         <= not f_dcd_rf1_sub_op_b         ;
  rf1_op_rnd_v       <= not f_dcd_rf1_op_rnd_v_b       ;
  rf1_inv_sign       <= not f_dcd_rf1_inv_sign_b       ;
  rf1_sign_ctl(0)    <= not f_dcd_rf1_sign_ctl_b(0)    ;
  rf1_sign_ctl(1)    <= not f_dcd_rf1_sign_ctl_b(1)    ;
  rf1_sgncpy         <= not f_dcd_rf1_sgncpy_b         ;
  rf1_op_rnd(0)      <= not f_dcd_rf1_op_rnd_b(0)      ;
  rf1_op_rnd(1)      <= not f_dcd_rf1_op_rnd_b(1)      ;
  rf1_rnd_to_int     <= not f_dcd_rf1_rnd_to_int_b     ;
  rf1_log2e          <= not f_dcd_rf1_log2e_b ;
  rf1_pow2e          <= not f_dcd_rf1_pow2e_b ;
  rf1_uc_end_nspec   <= f_dcd_rf1_uc_end and not f_dcd_rf1_uc_special ;
  rf1_uc_end_spec    <= f_dcd_rf1_uc_end and     f_dcd_rf1_uc_special ;


  rf1_den_ok         <= rf1_move or rf1_mv_to_scr or rf1_mv_from_scr or rf1_fsel or f_dcd_rf1_uc_mid ;


  rf1_nj_deno_x      <= f_dcd_rf1_nj_deno  and
                    not f_dcd_rf1_div_beg  and 
                    not f_dcd_rf1_sqrt_beg and 
                    not rf1_to_integer     and  -- do not want denorm outputs in the middle of a divide
                    not rf1_den_ok ;

  rf1_nj_deni_x      <= f_dcd_rf1_nj_deni and
                    not rf1_den_ok        ; -- do not want denorm outputs in the middle of a divide



    ex1_ctl_lat:  tri_rlmreg_p generic map (width=> 43, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(1), --tidn,
        mpw1_b           => mpw1_b(1), --tidn,
        mpw2_b           => mpw2_b(0), --tidn,
        nclk             => nclk,
        act              => f_dcd_rf1_act, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex1_ctl_so  ,                      
        scin             => ex1_ctl_si  ,                    
        -------------------
         din( 0)            => rf1_fsel           ,
         din( 1)            => rf1_from_integer   ,
         din( 2)            => rf1_to_integer     ,
         din( 3)            => rf1_math           ,
         din( 4)            => rf1_est_recip      ,
         din( 5)            => rf1_est_rsqrt      ,
         din( 6)            => rf1_move           ,
         din( 7)            => rf1_compare        ,
         din( 8)            => rf1_prenorm        ,
         din( 9)            => rf1_frsp           ,
         din(10)            => rf1_mv_to_scr      ,
         din(11)            => rf1_mv_from_scr    ,
         din(12)            => rf1_div_beg        ,
         din(13)            => rf1_sqrt_beg       ,
         din(14)            => rf1_sp             ,
         din(15)            => rf1_word           ,
         din(16)            => rf1_ordered        ,
         din(17)            => rf1_sub_op         ,
         din(18)            => f_dcd_rf1_uc_mid   ,
         din(19)            => rf1_op_rnd_v       ,
         din(20)            => rf1_inv_sign       ,
         din(21)            => rf1_sign_ctl(0)    ,
         din(22)            => rf1_sign_ctl(1)    ,
         din(23)            => f_dcd_rf1_aop_valid   ,
         din(24)            => f_dcd_rf1_cop_valid   ,
         din(25)            => f_dcd_rf1_bop_valid   ,
         din(26)            => rf1_op_rnd(0)      ,
         din(27)            => rf1_op_rnd(1)      ,
         din(28)            => rf1_rnd_to_int     ,
         din(29)            => rf1_uns ,
         din(30)            => rf1_sp_conv ,
         din(31)            => rf1_sgncpy ,
         din(32)            => rf1_log2e ,
         din(33)            => rf1_pow2e ,
         din(34)            => f_dcd_rf1_uc_ft_pos ,
         din(35)            => f_dcd_rf1_uc_ft_neg ,
         din(36)            => f_dcd_rf1_force_excp_dis ,
         din(37)            => rf1_uc_end_nspec ,
         din(38)            => rf1_uc_end_spec ,
         din(39)            => rf1_nj_deno_x ,
         din(40)            => rf1_nj_deni_x ,
         din(41)            => f_dcd_rf1_ftdiv  , 
         din(42)            => f_dcd_rf1_ftsqrt , 

        -------------------
        dout( 0)            => ex1_fsel             ,
        dout( 1)            => ex1_from_integer     ,
        dout( 2)            => ex1_to_integer       ,
        dout( 3)            => ex1_math             ,
        dout( 4)            => ex1_est_recip        ,
        dout( 5)            => ex1_est_rsqrt        ,
        dout( 6)            => ex1_move             ,
        dout( 7)            => ex1_compare          ,
        dout( 8)            => ex1_prenorm          ,
        dout( 9)            => ex1_frsp             ,
        dout(10)            => ex1_mv_to_scr        ,
        dout(11)            => ex1_mv_from_scr      ,
        dout(12)            => ex1_div_beg          ,
        dout(13)            => ex1_sqrt_beg         ,
        dout(14)            => ex1_sp_b             ,
        dout(15)            => ex1_word             ,
        dout(16)            => ex1_ordered          ,
        dout(17)            => ex1_sub_op           ,
        dout(18)            => ex1_uc_mid           ,
        dout(19)            => ex1_op_rnd_v         ,
        dout(20)            => ex1_inv_sign         ,
        dout(21)            => ex1_sign_ctl  (0)    ,
        dout(22)            => ex1_sign_ctl  (1)    ,
        dout(23)            => ex1_a_valid          ,
        dout(24)            => ex1_c_valid          ,
        dout(25)            => ex1_b_valid          ,
        dout(26)            => ex1_op_rnd(0)        ,
        dout(27)            => ex1_op_rnd(1)        ,
        dout(28)            => ex1_rnd_to_int       ,
        dout(29)            => ex1_uns              ,
        dout(30)            => ex1_sp_conv          ,
        dout(31)            => ex1_sgncpy           ,
        dout(32)            => ex1_log2e            ,
        dout(33)            => ex1_pow2e            ,
        dout(34)            => ex1_uc_ft_pos        ,
        dout(35)            => ex1_uc_ft_neg        ,
        dout(36)            => ex1_force_excp_dis   ,
        dout(37)            => ex1_uc_end_nspec     ,
        dout(38)            => ex1_uc_end_spec      ,
        dout(39)            => ex1_nj_deno          ,
        dout(40)            => ex1_nj_deni          ,
        dout(41)            => ex1_ftdiv            , 
        dout(42)            => ex1_ftsqrt          ); 

 f_pic_ex1_ftdiv <= ex1_ftdiv ; 

 f_pic_ex1_nj_deni <= ex1_nj_deni ;

        ex1_ovf_unf_dis <= ex1_uc_mid or
                           ex1_prenorm or 
                           ex1_move or
                           ex1_fsel or
                           ex1_mv_to_scr or 
                           ex1_mv_from_scr ;

        ex1_ve      <= f_cr2_ex1_fpscr_shadow(0) and not ex1_force_excp_dis; -- 24
        ex1_oe      <= f_cr2_ex1_fpscr_shadow(1) and not ex1_force_excp_dis; -- 25
        ex1_ue      <= f_cr2_ex1_fpscr_shadow(2) and not ex1_force_excp_dis; -- 26
        ex1_ze      <= f_cr2_ex1_fpscr_shadow(3) and not ex1_force_excp_dis; -- 27
        ex1_xe      <= f_cr2_ex1_fpscr_shadow(4) and not ex1_force_excp_dis; -- 28
        ex1_nonieee <= f_cr2_ex1_fpscr_shadow(5); -- 29

        ex1_rnd_fpscr(0 to 1) <= f_cr2_ex1_fpscr_shadow(6 to 7);



        ex1_rnd0    <= ( f_cr2_ex1_fpscr_shadow(6) and not ex1_op_rnd_v ) or -- 30
                       ( ex1_op_rnd(0)             and     ex1_op_rnd_v );
        ex1_rnd1    <= ( f_cr2_ex1_fpscr_shadow(7) and not ex1_op_rnd_v ) or -- 31
                       ( ex1_op_rnd(1)             and     ex1_op_rnd_v ) ;
        ex1_rnd_dis <=   tidn and f_fmt_ex1_prod_zero and ex1_nj_deni ; -- force truncate "01"

        f_pic_ex1_rnd_to_int <= ex1_rnd_to_int ; --output--



        ex1_flush_dis_sp <= ex1_uc_mid or 
                            ex1_fsel or
                            ex1_log2e or -- denorm input forced to zero
                            ex1_pow2e or -- denorm input forced to zero
                            ex1_prenorm or
                            ex1_move or
                            ex1_to_integer or 
                            ex1_frsp ;-- (never prenorm frsp)

        ex1_flush_dis_dp <= ex1_flush_dis_sp or
                            ex1_from_integer or
                            ex1_ftdiv or  
                            ex1_ftsqrt or 
                            ex1_mv_to_scr ;

        f_pic_ex1_flush_en_sp <= not ex1_flush_dis_sp ;
        f_pic_ex1_flush_en_dp <= not ex1_flush_dis_dp ;

        f_pic_ex1_log2e  <= ex1_log2e;--output--
        f_pic_ex1_pow2e  <= ex1_pow2e;--output--


--//################################################################
--//# ex1 logic
--//################################################################
        -- fmr/fneg/fabs/fnabs
        -- fsel
        -- mffs
        -- mcrfs, mtcrf, mtfs*
        -- prenorm_sp prenorm_dp
        -- fcomp
        -- fmul fadd fsub fmadd fmsub fnmsub fnmadd
        -- fres,frsqrte
        -- frsp
        ---------------------------------------------
        --
        --

        f_pic_ex1_from_integer    <=     ex1_from_integer ; --output--
        f_pic_ex1_fsel            <=     ex1_fsel         ; --output--

        f_pic_ex1_sh_ovf_do       <= ex1_fsel        or     --output--
                                     ex1_move        or
                                     ex1_prenorm     or  
                                     ex1_mv_to_scr   or 
                                     ex1_mv_from_scr ; 

        f_pic_ex1_sh_ovf_ig_b     <= not( ex1_from_integer or  not ex1_b_valid ); --output--

        f_pic_ex1_sh_unf_do       <=     not ex1_b_valid   --output--
                                      or ex1_est_recip 
                                      or ex1_est_rsqrt ;

        f_pic_ex1_sh_unf_ig_b     <= not ex1_from_integer ; --output-- --UNSET--


ex1_a_sign  <=  f_byp_pic_ex1_a_sign       ;
ex1_c_sign  <=  f_byp_pic_ex1_c_sign       ;
ex1_b_sign  <=  f_byp_pic_ex1_b_sign       ;

        ex1_b_sign_adj_x          <= ex1_b_sign xor ex1_sub_op ; --addend sign adjusted
        ex1_p_sign                <= ex1_a_sign xor ex1_c_sign ; --product sign

        ex1_b_sign_adj <= -- multiply/divide always use p-sign
               (ex1_b_sign_adj_x   and         ex1_b_valid ) or 
               (ex1_p_sign         and     not ex1_b_valid ) ;

        ex1_div_sign <= (ex1_a_sign xor ex1_b_sign) and ex1_div_beg ;

       --//#------------------------------------------
       --//# effective subtract
       --//#------------------------------------------

        f_pic_ex1_effsub_raw      <=  --output--
            (ex1_math or ex1_compare) and ( ex1_b_sign_adj xor ex1_p_sign );

       --//#---------------------------------------------
       --//# sign logic  alter b-sign for funny moves
       --//#---------------------------------------------

       ex1_b_sign_alt <= 
             (    ex1_a_sign     and     ex1_move   and      ex1_sgncpy        and ex1_b_valid   ) or 
             (    ex1_b_sign     and     ex1_move   and      ex1_sign_ctl(0)   and ex1_b_valid  and not ex1_sgncpy  ) or 
             (not ex1_b_sign     and     ex1_move   and      ex1_sign_ctl(1)   and ex1_b_valid  and not ex1_sgncpy  ) or 
             ( f_alg_ex1_sign_frmw and ex1_from_integer and not ex1_uns and     ex1_word         ) or
             (    ex1_b_sign       and ex1_from_integer and not ex1_uns and not ex1_word         ) or
             (    ex1_b_sign_adj and                        (ex1_math or ex1_compare)            ) or 
             (    ex1_b_sign     and not ex1_move
                                 and not (ex1_math or ex1_compare)
                                 and      ex1_b_valid
                                 and not ex1_from_integer  ) ;


 
--//################################################################
--//# ex2 latches
--//################################################################

      ex1_lzo_dis <=
             ( ex1_uc_mid        ) or
             ( ex1_prenorm       ) or 
             ( ex1_fsel          ) or 
             ( ex1_move          ) or 
             ( ex1_from_integer  ) or
             ( ex1_est_recip     ) or 
             ( ex1_est_rsqrt     ) or 
             ( ex1_to_integer and not ex1_rnd_to_int); --f_pic_ex2_to_integer



       ex1_a_nan    <=  f_fmt_ex1_a_expo_max and not f_fmt_ex1_a_frac_zero and not ex1_uc_end_nspec and not ex1_uc_mid;
       ex1_c_nan    <=  f_fmt_ex1_c_expo_max and not f_fmt_ex1_c_frac_zero and not ex1_uc_end_nspec and not ex1_uc_mid;
       ex1_b_nan    <=  f_fmt_ex1_b_expo_max and not f_fmt_ex1_b_frac_zero and not ex1_uc_end_nspec and not ex1_uc_mid;

       ex1_a_inf    <=  f_fmt_ex1_a_expo_max and     f_fmt_ex1_a_frac_zero and not ex1_uc_end_nspec and not ex1_uc_mid;
       ex1_c_inf    <=  f_fmt_ex1_c_expo_max and     f_fmt_ex1_c_frac_zero and not ex1_uc_end_nspec and not ex1_uc_mid;
       ex1_b_inf    <=  f_fmt_ex1_b_expo_max and     f_fmt_ex1_b_frac_zero and not ex1_uc_end_nspec and not ex1_uc_mid;

       ex1_bf_10000 <= ( f_fmt_ex1_b_imp and f_fmt_ex1_b_frac_zero ) or -- imp=1, frac=0
                       ( f_fmt_ex1_b_imp and f_fmt_ex1_b_frac_z32 and ex1_word );


        f_pic_ex1_frsp_ue1 <= ex1_frsp and ex1_ue ;--output


   ex1_sp               <= not ex1_sp_b             ;


    ex2_ctl_lat:  tri_rlmreg_p generic map (width=> 57, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(2), --tidn,
        mpw1_b           => mpw1_b(2), --tidn,
        mpw2_b           => mpw2_b(0), --tidn,
        nclk             => nclk,
        act              => ex1_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex2_ctl_so  ,                      
        scin             => ex2_ctl_si  ,                    
        -------------------
         din( 0)            => ex1_fsel             ,
         din( 1)            => ex1_from_integer     ,
         din( 2)            => ex1_to_integer       ,
         din( 3)            => ex1_math             ,
         din( 4)            => ex1_est_recip        ,
         din( 5)            => ex1_est_rsqrt        ,
         din( 6)            => ex1_move             ,
         din( 7)            => ex1_compare          ,
         din( 8)            => ex1_prenorm          ,
         din( 9)            => ex1_frsp             ,
         din(10)            => ex1_mv_to_scr        ,
         din(11)            => ex1_mv_from_scr      ,
         din(12)            => ex1_div_beg          ,
         din(13)            => ex1_sqrt_beg         ,
         din(14)            => ex1_sp               ,
         din(15)            => ex1_word             ,
         din(16)            => ex1_ordered          ,
         din(17)            => ex1_sub_op           ,
         din(18)            => ex1_lzo_dis          ,
         din(19)            => ex1_rnd_dis          ,
         din(20)            => ex1_inv_sign         ,
         din(21)            => ex1_p_sign           ,
         din(22)            => ex1_b_sign_adj       ,
         din(23)            => ex1_b_sign_alt       ,
         din(24)            => ex1_a_sign           ,
         din(25)            => ex1_a_valid        ,
         din(26)            => ex1_c_valid        ,
         din(27)            => ex1_b_valid        ,
         din(28)            => f_fmt_ex1_prod_zero   ,
         din(29)            => ex1_rnd0      ,
         din(30)            => ex1_rnd1      ,
         din(31)            => ex1_rnd_to_int       ,
         din(32)            => ex1_ve               ,
         din(33)            => ex1_oe               ,
         din(34)            => ex1_ue               ,
         din(35)            => ex1_ze               ,
         din(36)            => ex1_xe               ,
         din(37)            => ex1_nonieee          ,
         din(38)            => ex1_rnd0             ,
         din(39)            => ex1_rnd1             ,
         din(40)            => ex1_sp_conv          ,
         din(41)            => ex1_uns              ,
         din(42)            => ex1_log2e            ,
         din(43)            => ex1_pow2e            ,
         din(44)            => ex1_ovf_unf_dis      ,
         din(45)            => ex1_rnd_fpscr(0)     ,
         din(46)            => ex1_rnd_fpscr(1)     ,
         din(47)            => ex1_div_sign         ,
         din(48)            => ex1_uc_ft_pos        ,
         din(49)            => ex1_uc_ft_neg        ,
         din(50)            => ex1_uc_mid           ,
         din(51)            => ex1_uc_end_spec      ,
         din(52)            => ex1_nj_deno          ,
         din(53)            => ex1_ftdiv            , 
         din(54)            => ex1_ftsqrt           , 
         din(55)            => tiup                 , -- tie to the accuracy level
         din(56)            => f_fmt_ex1_b_imp      , 
        dout( 0)            => ex2_fsel             ,
        dout( 1)            => ex2_from_integer     ,
        dout( 2)            => ex2_to_integer       ,
        dout( 3)            => ex2_math             ,
        dout( 4)            => ex2_est_recip        ,
        dout( 5)            => ex2_est_rsqrt        ,
        dout( 6)            => ex2_move             ,
        dout( 7)            => ex2_compare          ,
        dout( 8)            => ex2_prenorm          ,
        dout( 9)            => ex2_frsp             ,
        dout(10)            => ex2_mv_to_scr        ,
        dout(11)            => ex2_mv_from_scr      ,
        dout(12)            => ex2_div_beg          ,
        dout(13)            => ex2_sqrt_beg         ,
        dout(14)            => ex2_sp               ,
        dout(15)            => ex2_word             ,
        dout(16)            => ex2_ordered          ,
        dout(17)            => ex2_sub_op           ,
        dout(18)            => ex2_lzo_dis          ,
        dout(19)            => ex2_rnd_dis          ,
        dout(20)            => ex2_inv_sign         ,
        dout(21)            => ex2_p_sign           ,
        dout(22)            => ex2_b_sign_adj       ,
        dout(23)            => ex2_b_sign_alt       ,
        dout(24)            => ex2_a_sign           ,
        dout(25)            => ex2_a_valid          ,
        dout(26)            => ex2_c_valid          ,
        dout(27)            => ex2_b_valid          ,
        dout(28)            => ex2_prod_zero        ,
        dout(29)            => ex2_op_rnd(0)        ,
        dout(30)            => ex2_op_rnd(1)        ,
        dout(31)            => ex2_rnd_to_int       ,
        dout(32)            => ex2_ve               ,
        dout(33)            => ex2_oe               ,
        dout(34)            => ex2_ue               ,
        dout(35)            => ex2_ze               ,
        dout(36)            => ex2_xe               ,
        dout(37)            => ex2_nonieee        ,
        dout(38)            => ex2_rnd0           ,
        dout(39)            => ex2_rnd1           ,
        dout(40)            => ex2_sp_conv        ,
        dout(41)            => ex2_uns            ,
        dout(42)            => ex2_log2e          ,
        dout(43)            => ex2_pow2e          ,
        dout(44)            => ex2_ovf_unf_dis    ,
        dout(45)            => ex2_rnd_fpscr(0)   ,
        dout(46)            => ex2_rnd_fpscr(1)   ,
        dout(47)            => ex2_div_sign       ,
        dout(48)            => ex2_uc_ft_pos      ,
        dout(49)            => ex2_uc_ft_neg      ,
        dout(50)            => ex2_uc_mid         ,
        dout(51)            => ex2_uc_end_spec    ,
        dout(52)            => ex2_nj_deno        ,
        dout(53)            => ex2_ftdiv          , 
        dout(54)            => ex2_ftsqrt         , 
        dout(55)            => ex2_accuracy       , 
        dout(56)            => ex2_b_imp         ); 


  ex2_to_int_uns_neg <= ex2_to_integer and not ex2_rnd_to_int and ex2_uns and ex2_b_sign_alt;
  ex2_wd_ov_x <= f_eie_ex2_wd_ov;  -- or  ex2_to_int_uns_neg; -- keep uns neg seperate
  ex2_dw_ov_x <= f_eie_ex2_dw_ov;  -- or  ex2_to_int_uns_neg; -- keep uns neg seperate


 f_pic_ex2_frsp_ue1 <= ex2_frsp and ex2_ue;--output
 f_pic_ex2_b_valid  <= ex2_b_valid; --output
 f_pic_ex2_ue1      <= ex2_ue or ex2_ovf_unf_dis ;--output
 

              ex1_sp_invalid <=  ( f_fmt_ex1_sp_invalid and ex1_sp and not ex1_from_integer
                                                        and not ex1_uc_mid and not ex1_uc_end_nspec);


    ex2_flg_lat:  tri_rlmreg_p generic map (width=> 18, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(2), --tidn,
        mpw1_b           => mpw1_b(2), --tidn,
        mpw2_b           => mpw2_b(0), --tidn,
        nclk             => nclk,
        act              => ex1_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex2_flg_so  ,                      
        scin             => ex2_flg_si  ,                    
        -------------------
         din( 0)            => f_fmt_ex1_a_frac_msb ,
         din( 1)            => f_fmt_ex1_c_frac_msb ,
         din( 2)            => f_fmt_ex1_b_frac_msb ,
         din( 3)            => f_fmt_ex1_a_zero     ,
         din( 4)            => f_fmt_ex1_c_zero     ,
         din( 5)            => f_fmt_ex1_b_zero     ,
         din( 6)            => ex1_a_nan            ,
         din( 7)            => ex1_c_nan            ,
         din( 8)            => ex1_b_nan            ,
         din( 9)            => ex1_a_inf            ,
         din(10)            => ex1_b_inf            ,
         din(11)            => ex1_c_inf            ,
         din(12)            => ex1_sp_invalid       ,
         din(13)            => ex1_bf_10000         ,
         din(14)            => f_fmt_ex1_bexpu_le126 ,
         din(15)            => f_fmt_ex1_gt126       ,
         din(16)            => f_fmt_ex1_ge128       ,
         din(17)            => f_fmt_ex1_inf_and_beyond_sp ,
        -------------------
        dout( 0)            => ex2_a_frac_msb       ,
        dout( 1)            => ex2_c_frac_msb       ,
        dout( 2)            => ex2_b_frac_msb       ,
        dout( 3)            => ex2_a_zero           ,
        dout( 4)            => ex2_c_zero           ,
        dout( 5)            => ex2_b_zero           ,
        dout( 6)            => ex2_a_nan            ,
        dout( 7)            => ex2_c_nan            ,
        dout( 8)            => ex2_b_nan            ,
        dout( 9)            => ex2_a_inf            ,
        dout(10)            => ex2_b_inf            ,
        dout(11)            => ex2_c_inf            ,
        dout(12)            => ex2_sp_invalid       ,
        dout(13)            => ex2_bf_10000         ,
        dout(14)            => ex2_bexpu_le126      ,
        dout(15)            => ex2_gt126            ,
        dout(16)            => ex2_ge128            ,
        dout(17)            => ex2_inf_and_beyond_sp );



--//################################################################
--//# ex2 logic
--//################################################################

        f_pic_ex2_sp_b            <= not ex2_sp;         --output--
        f_pic_ex2_to_integer      <= ex2_to_integer and not ex2_rnd_to_int; --output-- --lza only
        f_pic_ex2_prenorm         <= ex2_prenorm ;


        f_pic_ex2_force_sel_bexp  <=  --output--
             (ex2_from_integer ) or
             (ex2_move         ) or
             (ex2_mv_to_scr    ) or 
             (ex2_mv_from_scr  ) or
             (ex2_prenorm      ) or 
             (ex2_est_recip    ) or
             (ex2_est_rsqrt    ) ;

        f_pic_ex2_est_recip <= ex2_est_recip;--output--feie
        f_pic_ex2_est_rsqrt <= ex2_est_rsqrt;--output--feie

        f_pic_ex2_sp_lzo          <= --output--
             (ex2_frsp             ) or
             (ex2_math and ex2_sp  );

        f_pic_ex2_lzo_dis_prod    <=  --output--
             (ex2_math and ex2_ue ) or 
             (ex2_frsp and ex2_ue ) or
             (ex2_lzo_dis         ); -- intermediate steps div/sqrt

        f_pic_ex2_math_bzer_b  <= not( ex2_math and ex2_b_zero );


        ex2_rnd_nr     <= not ex2_rnd_dis and not ex2_rnd0 and not  ex2_rnd1 ; 
        ex2_rnd_inf_ok <= not ex2_rnd_dis and     ex2_rnd0 and not (ex2_rnd1 xor ex2_b_sign_alt) ; 

 f_pic_ex2_rnd_nr     <= ex2_rnd_nr ;
 f_pic_ex2_rnd_inf_ok <= ex2_rnd_inf_ok ;

  --//#------------------------------------------------------
  --//# special cases from inputs
  --//#------------------------------------------------------
    --//# special cases can force 4 different results: PassNan genNan Inf Zero
    --//#   (the value of inf can be modified based on round-mode)
    --//#
    --//# ...................................................................
    --//#   @@ Specail Cases From inputs (other than NAN)
    --//#   COMPARE : no special cases other than NAN which sets NAN compare
    --//#
    --//#   FROMINT   : BZero          T=+Zero  FI=0 FR=0 UX=0 OX=0 FPRF=+Zero // all others are +/- NORM
    --//#
    --//#   TOINT     : BZero+         T=+Zero  FI=0 FR=0 UX=0 OX=0 FPRF=00000 (ALL TOINTEGER UX=0 OX=0 FPRF=00000)
    --//#   TOINT     : BZero-         T=+Zero  FI=0 FR=0 UX=0 OX=0 FPRF=00000 (ALL TOINTEGER UX=0 OX=0 FPRF=00000)
    --//#   TOINT     : BNan           T=80000  Fi=0 Fr=0 Ux=0 Ox=0 FPRF=00000 (ALL TOINTEGER UX=0 OX=0 FPRF=00000)
    --//#   TOINT     : BInf+          T=PIPE   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=00000 (ALL TOINTEGER UX=0 OX=0 FPRF=00000)
    --//#   TOINT     : BInf-          T=PIPE   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=00000 (ALL TOINTEGER UX=0 OX=0 FPRF=00000)
    --//#
    --//#   FRES      : BZer+          T=+INF   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=+INF  // ZX (Ve=1: hold FPRF)
    --//#   FRES      : BZer-          T=-INF   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=-INF  // ZX (Ve=1: hold FPRF)
    --//#   FRES      : BInf+          T=+Zer   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=+Zer
    --//#   FRES      : BInf-          T=-Zer   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=-Zer
    --//#   FRES      : BNAN           T=PASS   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=qNAN
    --//#
    --//#   FRSQRTE   : BZer+          T=Inf+   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf+  // ZX (Ve=1: hold FPRF)
    --//#   FRSQRTE   : BZer-          T=Inf-   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf-  // ZX (Ve=1: hold FPRF)
    --//#   FRSQRTE   : BInf-          T=NAN    Fi=0 Fr=0 Ux=0 Ox=0 FPRF=nan   // vxsqrt
    --//#   FRSQRTE   : B-             T=NAN    Fi=0 Fr=0 Ux=0 Ox=0 FPRF=nan   // vxsqrt
    --//#   FRSQRTE   : BInf+          T=Zer+   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer+
    --//#   FRSQRTE   : BNan           T=PASS   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=nan   // vxsnan[?12]
    --//#
    --//#   SQRT_END  : BZer+          T=Zer+   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer+
    --//#   SQRT_END  : BZer-          T=Zer-   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer-
    --//#   SQRT_END  : BINF-          T=NAN    Fi=0 Fr=0 Ux=0 Ox=0 FPRF=NAN   // vxsqrt
    --//#   SQRT_END  : B-             T=NAN    Fi=0 Fr=0 Ux=0 Ox=0 FPRF=NAN   // vxsqrt
    --//#   SQRT_END  : BINF+          T=Inf+   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf+
    --//#   SQRT_END  : BNan           T=PASS   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=nan   // vxsnan[?12]
    --//#
    --//#   DIV_BEG   : BZer+          T=Inf?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf?  // ZX (Ve=1: hold FPRF) (vxZDZ if A=Zer)
    --//#   DIV_BEG   : BZer-          T=Inf?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf?  // ZX (Ve=1: hold FPRF) (vxZDZ if A=Zer)
    --//#   DIV_BEG   : BNAN           T=Pass   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=nan   // vxsnan[?12]
    --//#   DIV_BEG   : BInf+          T=Zer?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer?  //                      (vxIDI if A=Inf)
    --//#   DIV_BEG   : BInf-          T=Zer?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer?  //                      (vxIDI if A=Inf)
    --//#   DIV_BEG   : Both,AInf      T=Inf?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf?  //
    --//#   DIV_BEG   : Both,AZer      T=Zer?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer?  //
    --//#
    --//#   FRSP      : BZer+          T=Zer+   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Zer+
    --//#   FRSP      : BZer-          T=Zer-   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Zer-
    --//#   FRSP      : BInf+          T=Inf+   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Inf+
    --//#   FRSP      : BInf-          T=Inf-   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Inf-
    --//#   FRSP      : BNan           T=Pass   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Nan?
    --//#
    --//#   MATH      : ANAN           T=Pass   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Nan?
    --//#   MATH      : BNAN           T=Pass   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Nan?
    --//#   MATH      : CNAN           T=Pass   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Nan?
    --//#   MATH      : BZer*AZer      T=Zer@@  Fi-0 Fr=0 Ux=0 Ox=0 Fprf=Zer@@  @@:ExactZero Rounding Rule
    --//#   MATH      : BZer*CZer      T=Zer@@  Fi-0 Fr=0 Ux=0 Ox=0 Fprf=Zer@@  @@:ExactZero Rounding Rule
    --//#
    --//#   MATH : AINF|CINF|BINF      T=???    Fi=0 Fr=0 Ux=0 Ox=0 Fprf=???
    --//#
    --//#    A   C   B
    --//#    Z   I   x  => GenNan : vxIMZ
    --//#    I   Z   x  => GenNan : vxIMZ
    --//#    I  !Z   I  => GenNan : vxISI if effsub
    --//#   !Z   I   I  => GenNan : vxISI if effsub
    --//#    I  !Z   I  => INF    :       if effadd // sign = psign
    --//#   !Z   I   I  => INF    :       if effadd // sign = psign
    --//#    I  !Z  !I  => INF    : psign
    --//#   !Z   I  !I  => INF    : psign
    --//#   !ZI !ZI  I  => INF    : bsign xor sub_op
    --//#

       --//#----------------------------------------------------
       --//# pass NAN  (math,est,frsp)
       --//#----------------------------------------------------

       ex2_a_snan      <= ex2_a_nan and not ex2_a_frac_msb;
       ex2_b_snan      <= ex2_b_nan and not ex2_b_frac_msb;
       ex2_c_snan      <= ex2_c_nan and not ex2_c_frac_msb;
       ex2_a_qnan      <= ex2_a_nan and     ex2_a_frac_msb;
       ex2_b_qnan      <= ex2_b_nan and     ex2_b_frac_msb;
       ex2_nan_op_grp1 <= ex2_math  or ex2_est_recip or ex2_est_rsqrt or ex2_frsp or ex2_compare
                          or ex2_rnd_to_int or ex2_div_beg or ex2_sqrt_beg ;
       ex2_nan_op_grp2 <= ex2_nan_op_grp1 or ex2_to_integer or  ex2_div_beg;
       ex2_compo       <= ex2_compare and ex2_ordered ;

       ex2_pass_en  <= (ex2_a_nan or ex2_c_nan or ex2_b_nan );
       ex2_pass_nan <= ex2_nan_op_grp1 and ex2_pass_en ;


       ex2_vxsnan  <= 
           (ex2_a_snan and ex2_nan_op_grp1    ) or 
           (ex2_c_snan and ex2_nan_op_grp1    ) or 
           (ex2_b_snan and ex2_nan_op_grp2    ) or 
           (f_dcd_ex2_uc_vxsnan               )  ; 
                       
       ex2_vxvc   <= --(2)
           (ex2_compo and ex2_a_qnan and not ex2_b_snan  ) or -- qnan
           (ex2_compo and ex2_b_qnan and not ex2_a_snan  ) or -- qnan
           (ex2_compo and ex2_a_snan and not ex2_ve      ) or -- snan
           (ex2_compo and ex2_b_snan and not ex2_ve      ) ;  -- snan

       ex2_vxcvi  <= --(3)
           (ex2_to_integer and ex2_b_nan and not ex2_rnd_to_int)  and not ex2_sp_invalid;

       ex2_vxzdz  <= f_dcd_ex2_uc_vxzdz or --(4) FDIV only
           (ex2_a_zero and ex2_b_zero and ex2_div_beg and not ex2_sp_invalid)  ;

       ex2_vxidi  <= f_dcd_ex2_uc_vxidi or --(5) FDIV only
           (ex2_a_inf  and ex2_b_inf  and ex2_div_beg  and not ex2_sp_invalid) ;



       --//#----------------------------------------------------
       --//# special case genNAN
       --//#----------------------------------------------------

       ex2_p_inf  <= ex2_a_inf  or ex2_c_inf;
       ex2_p_zero <= ex2_a_zero or ex2_c_zero;


       ex2_vximz  <= --(6)
          (ex2_math      and  ex2_p_inf and ex2_p_zero) and not ex2_sp_invalid;

       ex2_vxisi  <= --(7)
          (ex2_math      and  ex2_b_inf and ex2_p_inf and not ex2_p_zero and not f_alg_ex2_effsub_eac_b ) and not ex2_sp_invalid;

       ex2_vxsqrt <= f_dcd_ex2_uc_vxsqrt or --(8)
          ( (ex2_est_rsqrt or ex2_sqrt_beg)  and ex2_b_sign_alt and not ex2_b_zero  and not ex2_b_nan and not ex2_sp_invalid)  ;

       ex2_gen_nan_dv <=  (ex2_a_zero and ex2_b_zero     and ex2_div_beg ) or
                         ( (ex2_vxidi  or ex2_sp_invalid) and ex2_div_beg  );

       ex2_gen_nan_sq <= (ex2_vxsqrt or ex2_sp_invalid) and ex2_sqrt_beg ;
    
       ex2_gen_nan <= (ex2_b_nan and ex2_to_integer and not ex2_rnd_to_int) or
                      ex2_gen_nan_log or
                      ex2_gen_nan_pow or 
                      ex2_vxisi or
                      ex2_vximz or                      
                      (ex2_a_zero and ex2_b_zero and ex2_div_beg ) or
                      ex2_vxsqrt or
                      ex2_vxidi or 
           (ex2_sp_invalid and not ex2_pow2e and not ex2_log2e ) ;-- sp op requires exponent in sp range (except frsp)

       -- NAN             *log:QNAN_PASS   *pow: QNAN_PASS
       -- -INF            *log:QNAN_dflt    pow: +0
       -- +INF            *log:+INF        *pow: +INF
       --  -0             *log:-INF        *pow: +1
       --  +0             *log:-INF        *pow: +1
       -- NEG             *log:QNAN_dflt   *pow: xxxxx
       -- -0 <x< 2**-126  *log:-INF        *pow: xxxxx
       -- +0 <x< 2**-126  *log: xxxxx      *pow: +1
       -- -2**-126 <x<-0  *log: xxxxx      *pow: +1
       -- -INF <x<-126    *log: xxxxx       pow: 0


       


       ex2_log_ofzero    <= (ex2_log2e and ex2_b_zero ) or
                            (ex2_log2e and ex2_bexpu_le126 ); -- +/- denorm

       ex2_gen_one <= (ex2_pow2e and ex2_b_zero) or
                      (ex2_pow2e and ex2_bexpu_le126 ); -- small denorms pos/neg

       ex2_gen_nan_log <= ( ex2_log2e and ex2_b_sign_alt and not ex2_b_zero and not ex2_bexpu_le126 ) or  --also catches -INF input
                          ( ex2_log2e and ex2_b_nan );

       ex2_gen_inf_log <= ex2_log_ofzero or
                          (ex2_log2e and not ex2_b_sign_alt and ex2_b_inf ) or 
                          (ex2_log2e and not ex2_b_sign_alt and ex2_inf_and_beyond_sp ) ;

       ex2_gen_inf_pow <= (ex2_pow2e and not ex2_b_sign_alt and ex2_b_inf ) or 
                          (ex2_pow2e and not ex2_b_sign_alt and ex2_ge128 );

       ex2_gen_zero_pow <= (ex2_pow2e and  ex2_b_sign_alt and ex2_b_inf) or
                           (ex2_pow2e and  ex2_b_sign_alt and ex2_gt126);

       ex2_gen_nan_pow <= ( ex2_pow2e and ex2_b_nan ) ;

       --//#----------------------------------------------------
       --//# special case genINF
       --//#----------------------------------------------------

       ex2_zx <= f_dcd_ex2_uc_zx or
               (ex2_b_zero and not ex2_a_zero
                           and not ex2_a_inf
                           and not ex2_a_nan
                           and not ex2_sp_invalid 
                           and ( ex2_est_recip or ex2_est_rsqrt or ex2_div_beg ) );                               

       ex2_gen_inf_sq <= ex2_sqrt_beg and ex2_b_inf and not ex2_b_sign_alt ;
       ex2_gen_inf_dv <= (ex2_div_beg  and ex2_a_inf and not ex2_b_inf and not ex2_b_nan ) or
                         (ex2_div_beg  and ex2_zx    and not ex2_a_inf and not ex2_a_nan );

       ex2_gen_inf  <=
           (ex2_gen_inf_log              ) or 
           (ex2_gen_inf_pow              ) or 
           (ex2_to_integer and ex2_b_inf ) or 
           (ex2_zx                       ) or
           (ex2_frsp and ex2_b_inf       ) or
           (ex2_math and ex2_any_inf     ) or  -- priority will throw away the PassNan/GenNan cases
           (ex2_gen_inf_sq ) or
           (ex2_gen_inf_dv );

       ex2_inf_sign <= -- will be "ANDed" with ex2_math
           (     ex2_p_inf and                   ex2_p_sign     ) or -- could both be inf (effadd) and ok
           ( not ex2_p_inf and     ex2_b_inf and ex2_b_sign_adj );               


       ex2_any_inf <= ex2_a_inf or ex2_c_inf or ex2_b_inf ;

       --//#----------------------------------------------------
       --//# special case genMax
       --//#----------------------------------------------------

       ex2_gen_max  <=  -- these are inf/max depending on rnd mode.
           (ex2_to_integer and ex2_b_inf and not ex2_rnd_to_int);

       --//#----------------------------------------------------
       --//# special case genZero
       --//#----------------------------------------------------

       ex2_gen_zer_sq <= ex2_sqrt_beg    and ex2_b_zero ;
       ex2_gen_zer_dv <= ex2_div_beg     and ex2_b_inf and not ex2_a_nan and not ex2_a_inf ;

       ex2_gen_zero <=
           ( ex2_gen_zero_pow                                       ) or 
           ( ex2_math and (ex2_a_zero or ex2_c_zero) and ex2_b_zero ) or
           ( ex2_to_integer                          and ex2_b_zero ) or
           ( ex2_from_integer and not ex2_b_sign_alt and ex2_b_zero ) or
           ( ex2_frsp                                and ex2_b_zero ) or
           ( ex2_prenorm and not  ex2_div_beg        and ex2_b_zero ) or -- div by zero is INF
           ( ex2_est_recip                           and ex2_b_inf  ) or
           ( ex2_est_rsqrt   and not ex2_b_sign_alt  and ex2_b_inf  ) or
           ( ex2_gen_zer_sq ) or 
           ( ex2_gen_zer_dv );

       --//#----------------------------------------------------
       --//# special case special sign
       --//#----------------------------------------------------

       ex2_neg_sqrt_nz <= -- divide must use PSign
           ( ex2_est_rsqrt and ex2_b_sign_alt and not ex2_b_zero) ;

       ex2_toint_genz <= ex2_to_integer and  ex2_b_zero ;

       ex2_toint_nan_sign <= ex2_to_integer and not ex2_rnd_to_int and (ex2_pass_nan or ex2_gen_nan) and not ex2_uns;

       ex2_pass_x <= ex2_pass_nan or ex2_fsel ;

       ex2_rnd_ni <= ex2_rnd0 and ex2_rnd1 ;
       ex2_exact_zero_sign <=
            (    ex2_effsub_eac and  (ex2_rnd_ni xor ex2_inv_sign) ) or 
            (not ex2_effsub_eac and  (ex2_p_sign ) );               -- xor ex2_inv_sign


       ex2_prenorm_special <= ex2_gen_zer_dv or ex2_gen_inf_dv or ex2_gen_nan_dv or
                              ex2_gen_zer_sq or ex2_gen_inf_sq or ex2_gen_nan_sq ;

       ex2_prenorm_sign <=
             (ex2_div_sign    and ex2_gen_zer_dv   ) or 
             (ex2_div_sign    and ex2_gen_inf_dv   ) or 
             (tidn            and ex2_gen_inf_sq   ) or 
             (tidn            and ex2_gen_nan_sq   ) or 
             (tidn            and ex2_gen_nan_dv   ) or               
             (ex2_b_sign_alt  and ex2_gen_zer_sq   ) or
             (ex2_b_sign_alt  and not ex2_prenorm_special ) ;

       ex2_spec_sign <= 
           (     ex2_pass_x and f_fmt_ex2_pass_sign             ) or
           ( not ex2_pass_x and ex2_prenorm and ex2_prenorm_sign  and not ex2_gen_nan ) or 
           ( not ex2_pass_x and ex2_math and (ex2_a_zero or ex2_c_zero) and ex2_b_zero and ex2_exact_zero_sign and not ex2_inf_sign and not ex2_gen_nan) or -- exact_zero
           ( not ex2_pass_x and ex2_log_ofzero                                         and not ex2_gen_nan ) or 
           ( not ex2_pass_x and not ex2_math and ex2_b_sign_alt and not ex2_neg_sqrt_nz
                                                                and not ex2_prenorm
                                                                and not ex2_log2e
                                                                and not ex2_pow2e 
                                                                and not ex2_toint_genz and not ex2_gen_nan ) or 
           ( not ex2_pass_x and     ex2_math and ex2_inf_sign                          and not ex2_gen_nan ) or
           (     ex2_toint_nan_sign                                                    ) or 
           (    ex2_b_sign_alt and ex2_rnd_to_int                                      and not ex2_gen_nan  ) ; --sign in = sign out

       ex2_quiet <= 
            ex2_pass_nan and not f_fmt_ex2_pass_msb and (ex2_math       or
                                                         ex2_frsp       or
                                                         ex2_rnd_to_int or 
                                                         ex2_est_recip  or 
                                                         ex2_est_rsqrt     );
       
        
       --//#----------------------------------------------------
       --//# set up for compares
       --//#----------------------------------------------------

        ex2_cmp_zero <= ex2_a_zero and ex2_b_zero; -- and ex2_pass_en;

        -- b-sign was already flipped for compares
        ex2_is_nan     <= ( ex2_compare and     ex2_pass_nan ) ;

        ex2_is_eq      <= ( ex2_compare and not ex2_pass_nan and     ex2_cmp_zero ) or
                          ( (ex2_ftsqrt or ex2_ftdiv)  and     ex2_b_zero ) or
                          ( (ex2_ftsqrt or ex2_ftdiv)  and     ex2_b_inf  ) or
                          ( (ex2_ftsqrt or ex2_ftdiv)  and     ex2_b_nan  ) or
                          (                ex2_ftdiv   and     ex2_a_inf  ) or
                          (                ex2_ftdiv   and     ex2_a_nan  ) or
                          (  ex2_ftsqrt                and     ex2_b_sign_alt     ) or
                          (  ex2_ftsqrt and not f_fmt_ex2_be_ge_54                    ) or
                          (  ex2_ftdiv  and not f_fmt_ex2_ae_ge_54 and not ex2_a_zero ) or
                          (  ex2_ftdiv  and not f_fmt_ex2_be_ge_2                     ) or
                          (  ex2_ftdiv  and     f_fmt_ex2_be_ge_2044                  ) or
                          (  ex2_ftdiv  and     f_fmt_ex2_tdiv_rng_chk and not ex2_a_zero );

        ex2_is_gt      <= ( ex2_compare and not ex2_pass_nan and not ex2_cmp_zero and not ex2_a_sign  and not ex2_b_sign_alt ) or
                          ( (ex2_ftsqrt or ex2_ftdiv)  and not ex2_b_imp     ) or -- denormalize DP value
                          ( (ex2_ftsqrt or ex2_ftdiv)  and f_fmt_ex2_be_den  ) or -- detect denorm after prenorm
                          ( (ex2_ftsqrt or ex2_ftdiv)  and     ex2_b_zero    ) or
                          ( (ex2_ftsqrt or ex2_ftdiv)  and     ex2_b_inf     ) or
                          (                ex2_ftdiv   and     ex2_a_inf     ) ;


        ex2_is_lt      <= ( ex2_compare and not ex2_pass_nan and not ex2_cmp_zero and     ex2_a_sign  and     ex2_b_sign_alt ) or
                          ( ex2_ftdiv   and     ex2_accuracy ) or
                          ( ex2_ftsqrt  and     ex2_accuracy ) ;
        ex2_cmp_sgnneg <= ( ex2_compare and not ex2_pass_nan and not ex2_cmp_zero and     ex2_a_sign  and not ex2_b_sign_alt ) ;
        ex2_cmp_sgnpos <= ( ex2_compare and not ex2_pass_nan and not ex2_cmp_zero and not ex2_a_sign  and     ex2_b_sign_alt ) ;


--//################################################################
--//# ex3 latches
--//################################################################



    ex3_scr_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee, --tidn,
        delay_lclkr      => delay_lclkr(3), --tidn,
        mpw1_b           => mpw1_b(3), --tidn,
        mpw2_b           => mpw2_b(0) ,--tidn,
        nclk             => nclk,
        act              => ex2_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex3_scr_so  ,                      
        scin             => ex3_scr_si  ,                    
        -------------------
         din(0)             => ex2_ve        ,
         din(1)             => ex2_oe        ,
         din(2)             => ex2_ue        ,
         din(3)             => ex2_ze        ,
         din(4)             => ex2_xe        ,
         din(5)             => ex2_nonieee   ,
         din(6)             => ex2_rnd0      ,
         din(7)             => ex2_rnd1      ,
        -------------------
        dout(0)             => ex3_ve      ,
        dout(1)             => ex3_oe      ,
        dout(2)             => ex3_ue      ,
        dout(3)             => ex3_ze      ,
        dout(4)             => ex3_xe      ,
        dout(5)             => ex3_nonieee ,
        dout(6)             => ex3_rnd0    ,
        dout(7)             => ex3_rnd1   );


  --//#----------------------------------------------------
  --//# Don't truncate NaN's to SP on first divide/sqrt pass (*_beg = 1)

  ex2_sp_notrunc <= ex2_sp and not (
                   ( ex2_div_beg and (ex2_a_nan or ex2_b_nan)) or
                   ( ex2_sqrt_beg and ex2_b_nan)  );


        
  ex2_sp_o_frsp  <=  ex2_sp_notrunc  or  ex2_frsp;


    ex3_ctl_lat:  tri_rlmreg_p generic map (width=> 34, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(3), --tidn,
        mpw1_b           => mpw1_b(3), --tidn,
        mpw2_b           => mpw2_b(0), --tidn,
        nclk             => nclk,
        act              => ex2_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex3_ctl_so  ,                  
        scin             => ex3_ctl_si  ,                    
        -------------------
         din( 0)            => ex2_fsel             ,
         din( 1)            => ex2_from_integer     ,
         din( 2)            => ex2_to_integer       ,
         din( 3)            => ex2_math             ,
         din( 4)            => ex2_est_recip        ,
         din( 5)            => ex2_est_rsqrt        ,
         din( 6)            => ex2_move             ,
         din( 7)            => ex2_compare          ,
         din( 8)            => ex2_prenorm          ,
         din( 9)            => ex2_frsp             ,
         din(10)            => ex2_mv_to_scr        ,
         din(11)            => ex2_mv_from_scr      ,
         din(12)            => ex2_div_beg          ,
         din(13)            => ex2_sqrt_beg         ,
         din(14)            => ex2_sp_o_frsp        ,
         din(15)            => ex2_word             ,
         din(16)            => ex2_sub_op           ,
         din(17)            => ex2_rnd_dis          ,
         din(18)            => ex2_inv_sign         ,
         din(19)            => ex2_p_sign           ,
         din(20)            => ex2_b_sign_adj       ,
         din(21)            => ex2_b_sign_alt       ,
         din(22)            => ex2_a_valid          ,
         din(23)            => ex2_c_valid          ,
         din(24)            => ex2_b_valid          ,
         din(25)            => ex2_prod_zero        ,
         din(26)            => ex2_b_zero           ,
         din(27)            => ex2_rnd_to_int       ,
         din(28)            => ex2_sp_conv          ,
         din(29)            => ex2_uns              ,
         din(30)            => ex2_log2e            ,
         din(31)            => ex2_pow2e            ,
         din(32)            => ex2_ovf_unf_dis      ,
         din(33)            => ex2_nj_deno          ,
        -------------------
        dout( 0)            => ex3_fsel             ,
        dout( 1)            => ex3_from_integer     ,
        dout( 2)            => ex3_to_integer       ,
        dout( 3)            => ex3_math             ,
        dout( 4)            => ex3_est_recip        ,
        dout( 5)            => ex3_est_rsqrt        ,
        dout( 6)            => ex3_move             ,
        dout( 7)            => ex3_compare          ,
        dout( 8)            => ex3_prenorm          ,
        dout( 9)            => ex3_frsp             ,
        dout(10)            => ex3_mv_to_scr        ,
        dout(11)            => ex3_mv_from_scr      ,
        dout(12)            => ex3_div_beg          ,
        dout(13)            => ex3_sqrt_beg         ,
        dout(14)            => ex3_sp               ,
        dout(15)            => ex3_word             ,
        dout(16)            => ex3_sub_op           ,
        dout(17)            => ex3_rnd_dis          ,
        dout(18)            => ex3_inv_sign         ,
        dout(19)            => ex3_p_sign           ,
        dout(20)            => ex3_b_sign_adj       ,
        dout(21)            => ex3_b_sign_alt       ,
        dout(22)            => ex3_a_valid          ,
        dout(23)            => ex3_c_valid          ,
        dout(24)            => ex3_b_valid          ,
        dout(25)            => ex3_prod_zero        ,
        dout(26)            => ex3_b_zero           ,
        dout(27)            => ex3_rnd_to_int       ,
        dout(28)            => ex3_sp_conv          ,
        dout(29)            => ex3_uns              ,
        dout(30)            => ex3_log2e            ,
        dout(31)            => ex3_pow2e            ,
        dout(32)            => ex3_ovf_unf_dis      ,
        dout(33)            => ex3_nj_deno         );

        ex3_nj_deno_x <= ex3_nj_deno and not ex3_ue ;

        ex3_byp_prod_nz   <=    (     ex3_math                    and
                                  not ex3_b_zero                  and -- math,b=z cancells byp
                                  not ex3_prod_zero               and
                                     (ex3_a_valid or ex3_c_valid) and 
                                      ex3_sel_byp                           );

        ex3_byp_prod_nz_sub   <=    (     ex3_math                    and
                                          ex3_effsub_eac              and 
                                      not ex3_b_zero                  and -- math,b=z cancells byp
                                      not ex3_prod_zero               and
                                         (ex3_a_valid or ex3_c_valid) and 
                                          ex3_sel_byp                           );


   ex2_uc_g_ig <= (f_mad_ex2_uc_a_expo_den    and not ex2_ue             ) or
                  (f_mad_ex2_uc_a_expo_den_sp and not ex2_ue and  ex2_sp ) ;

  ex2_effsub_eac <= not f_alg_ex2_effsub_eac_b ;

    ex3_flg_lat:  tri_rlmreg_p generic map (width=> 47, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(3), --tidn,
        mpw1_b           => mpw1_b(3) ,--tidn,
        mpw2_b           => mpw2_b(0), --tidn,
        nclk             => nclk,
        act              => ex2_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex3_flg_so,                      
        scin             => ex3_flg_si  ,                    
        -------------------
         din( 0)            => ex2_vxsnan      ,--exceptions
         din( 1)            => ex2_vxvc        ,  
         din( 2)            => ex2_vxcvi       ,
         din( 3)            => ex2_vxzdz       ,
         din( 4)            => ex2_vxidi       ,
         din( 5)            => ex2_vximz       ,
         din( 6)            => ex2_vxisi       ,
         din( 7)            => ex2_vxsqrt      ,
         din( 8)            => ex2_zx          ,
         din( 9)            => ex2_gen_nan     , --sel_k
         din(10)            => ex2_gen_inf     ,
         din(11)            => ex2_gen_max     ,
         din(12)            => ex2_gen_zero    ,
         din(13)            => ex2_spec_sign   ,--sign special
         din(14)            => ex2_quiet       ,
         din(15)            => ex2_is_nan      ,--compares
         din(16)            => ex2_is_eq       ,
         din(17)            => ex2_is_gt       ,
         din(18)            => ex2_is_lt       ,
         din(19)            => ex2_cmp_sgnneg  ,
         din(20)            => ex2_cmp_sgnpos  ,
         din(21)            => ex2_wd_ov_x     , --f_eie_ex2_wd_ov ,-- flags from toInt exponent
         din(22)            => ex2_dw_ov_x     , --f_eie_ex2_dw_ov ,
         din(23)            => f_eie_ex2_wd_ov_if ,  
         din(24)            => f_eie_ex2_dw_ov_if ,
         din(25)            => ex2_to_int_uns_neg , 
         din(26)            => f_alg_ex2_sel_byp   ,  
         din(27)            => ex2_effsub_eac ,  
         din(28)            => f_alg_ex2_sh_unf    ,  
         din(29)            => f_alg_ex2_sh_ovf    ,
         din(30)            => ex2_pass_nan    ,
         din(31)            => ex2_bf_10000    ,
         din(32)            => f_eie_ex2_lt_bias    ,
         din(33)            => f_eie_ex2_eq_bias_m1 ,
         din(34)            => ex2_gen_one    ,
         din(35)            => ex2_rnd_fpscr(0) ,
         din(36)            => ex2_rnd_fpscr(1) ,
         din(37)            => ex2_div_sign ,
         din(38)            => ex2_uc_ft_pos ,
         din(39)            => ex2_uc_ft_neg ,
         din(40)            => f_dcd_ex2_uc_inc_lsb  ,
         din(41)            => f_dcd_ex2_uc_guard    ,
         din(42)            => f_dcd_ex2_uc_sticky   ,
         din(43)            => f_dcd_ex2_uc_gs_v     ,
         din(44)            => ex2_uc_g_ig ,
         din(45)            => ex2_uc_mid ,
         din(46)            => ex2_uc_end_spec ,
        -------------------
        dout( 0)            => ex3_vxsnan      ,--exceptions
        dout( 1)            => ex3_vxvc        ,  
        dout( 2)            => ex3_vxcvi       ,
        dout( 3)            => ex3_vxzdz       ,
        dout( 4)            => ex3_vxidi       ,
        dout( 5)            => ex3_vximz       ,
        dout( 6)            => ex3_vxisi       ,
        dout( 7)            => ex3_vxsqrt      ,
        dout( 8)            => ex3_zx          ,
        dout( 9)            => ex3_gen_nan     , --sel_k
        dout(10)            => ex3_gen_inf     ,
        dout(11)            => ex3_gen_max     ,
        dout(12)            => ex3_gen_zero    ,
        dout(13)            => ex3_spec_sign   ,--sign special
        dout(14)            => ex3_quiet       ,
        dout(15)            => ex3_is_nan      ,--compares
        dout(16)            => ex3_is_eq       ,
        dout(17)            => ex3_is_gt       ,
        dout(18)            => ex3_is_lt       ,
        dout(19)            => ex3_cmp_sgnneg  ,
        dout(20)            => ex3_cmp_sgnpos  ,
        dout(21)            => ex3_wd_ov       ,-- flags from toInt exponent
        dout(22)            => ex3_dw_ov       ,  
        dout(23)            => ex3_wd_ov_if    ,  
        dout(24)            => ex3_dw_ov_if    ,
        dout(25)            => ex3_to_int_uns_neg ,
        dout(26)            => ex3_sel_byp     ,  
        dout(27)            => ex3_effsub_eac  ,  
        dout(28)            => ex3_sh_unf      ,  
        dout(29)            => ex3_sh_ovf      ,
        dout(30)            => ex3_pass_nan    ,
        dout(31)            => ex3_bf_10000    ,
        dout(32)            => ex3_lt_bias     ,
        dout(33)            => ex3_eq_bias_m1  ,
        dout(34)            => ex3_gen_one      ,
        dout(35)            => ex3_rnd_fpscr(0) ,
        dout(36)            => ex3_rnd_fpscr(1) ,
        dout(37)            => ex3_div_sign     ,
        dout(38)            => ex3_uc_ft_pos   ,
        dout(39)            => ex3_uc_ft_neg   ,
        dout(40)            => ex3_uc_inc_lsb  ,
        dout(41)            => ex3_uc_guard    ,
        dout(42)            => ex3_uc_sticky   ,
        dout(43)            => ex3_uc_gs_v     ,
        dout(44)            => ex3_uc_g_ig     ,
        dout(45)            => ex3_uc_mid      ,
        dout(46)            => ex3_uc_end_spec ); 


        f_mad_ex3_uc_round_mode(0 to 1) <= ex3_rnd_fpscr(0 to 1); --output--
        f_mad_ex3_uc_res_sign           <= ex3_div_sign ;--output--
        f_mad_ex3_uc_zx                 <= ex3_zx and not ex3_pass_nan ;--output--
        f_mad_ex3_uc_special            <= ex3_pass_nan  or --output--
                                           ex3_gen_nan   or
                                           ex3_gen_zero  or
                                           ex3_gen_inf   ;
                                           
        f_mad_ex3_uc_vxidi              <= ex3_vxidi    ;--output--
        f_mad_ex3_uc_vxzdz              <= ex3_vxzdz    ;--output--
        f_mad_ex3_uc_vxsqrt             <= ex3_vxsqrt   ;--output--
        f_mad_ex3_uc_vxsnan             <= ex3_vxsnan   ;--output--

        f_pic_ex3_cmp_sgnneg      <= ex3_cmp_sgnneg; --output--
        f_pic_ex3_cmp_sgnpos      <= ex3_cmp_sgnpos; --output--
        f_pic_ex3_is_eq           <= ex3_is_eq     ; --output--
        f_pic_ex3_is_gt           <= ex3_is_gt     ; --output--
        f_pic_ex3_is_lt           <= ex3_is_lt     ; --output--
        f_pic_ex3_is_nan          <= ex3_is_nan    ; --output--

        f_pic_ex3_sel_est         <= ex3_est_recip or ex3_est_rsqrt; --output--
        f_pic_ex3_sp_b            <= not ex3_sp ; --output--



--//################################################################
--//# ex3 logic
--//################################################################

   --//##-----------------------------------------
   --//## mutex selects for specials
   --//##-----------------------------------------


   ex3_gen_rnd2int     <= ex3_rnd_to_int  and ex3_lt_bias ;
   ex3_gen_one_rnd2int <= ex3_gen_rnd2int and     ex3_rnd2int_up ;
   ex3_gen_zer_rnd2int <= ex3_gen_rnd2int and not ex3_rnd2int_up ;

   
   ex3_rnd2int_up <=
            (not ex3_rnd0 and not ex3_rnd1 and     ex3_eq_bias_m1 and not ex3_b_zero ) or
            (    ex3_rnd0 and not ex3_rnd1 and not ex3_b_sign_alt and not ex3_b_zero ) or --pos_inf   --f_alg_ex3_int_fi and **1
            (    ex3_rnd0 and     ex3_rnd1 and     ex3_b_sign_alt and not ex3_b_zero );   --neg_inf   --f_alg_ex3_int_fi and **1

-- **1 rnd_rnd to int spec does not block round up becuase b is zero. i think that may be a mistake.



   ex3_gen_nan_mutex <= ex3_gen_nan                           and not ex3_pass_nan ;
   ex3_gen_inf_mutex <= ex3_gen_inf                           and not ex3_pass_nan and not ex3_gen_nan ;
   ex3_gen_max_mutex <= ex3_gen_inf                           and not ex3_pass_nan and not ex3_gen_nan and not ex3_gen_inf;
   ex3_gen_zer_mutex <= (ex3_gen_zero or ex3_gen_zer_rnd2int) and not ex3_pass_nan and not ex3_gen_nan and not ex3_gen_one_rnd2int;
   ex3_gen_one_mutex <= (ex3_gen_one  or ex3_gen_one_rnd2int) and not ex3_pass_nan and not ex3_gen_nan ;





        ex3_word_to <= ex3_word and ex3_to_integer;
        ex3_to_int_wd    <=  ex3_to_integer and     ex3_word and not ex3_rnd_to_int;
        ex3_to_int_dw    <=  ex3_to_integer and not ex3_word and not ex3_rnd_to_int;
        ex3_to_int_ov    <=
          ( ex3_to_int_wd and ex3_wd_ov                                                ) or -- definitely overflowed (includes unsigned)
          ( ex3_to_int_dw and ex3_dw_ov                                                ) or -- definitely overflowed (includes unsigned)
          ( ex3_to_int_wd and ex3_wd_ov_if and not ex3_b_sign_alt and not ex3_uns      ) or -- definitely overflowed (excludes unsigned)
          ( ex3_to_int_dw and ex3_dw_ov_if and not ex3_b_sign_alt and not ex3_uns      ) or -- definitely overflowed (excludes unsigned)
          ( ex3_to_int_wd and ex3_wd_ov_if and     ex3_b_sign_alt and not(ex3_bf_10000 and not f_alg_ex3_int_fr) and not ex3_uns ) or  -- definitely overflowed
          ( ex3_to_int_dw and ex3_dw_ov_if and     ex3_b_sign_alt and not(ex3_bf_10000 and not f_alg_ex3_int_fr) and not ex3_uns ) ;   -- definitely overflowed

        ex3_to_int_ov_if <=  ex3_to_integer and not ex3_b_sign_alt; -- -- to_int positive
          

        ex3_spec_sel_e <=
             ex3_gen_rnd2int or 
             ex3_pass_nan or
             ex3_gen_nan  or
             ex3_gen_inf  or
             ex3_gen_zero or
             ex3_mv_from_scr ;

        ex3_spec_sel_f <=
            (ex3_gen_rnd2int and not ex3_pass_nan) or
            (ex3_gen_nan     and not ex3_pass_nan) or
            (ex3_gen_inf     and not ex3_pass_nan) or
            (ex3_gen_zero    and not ex3_pass_nan) ;


        ex3_ov_en <= (ex3_math or ex3_frsp or ex3_est_recip) and not ex3_ovf_unf_dis ; 
        ex3_uf_en <= ex3_ov_en ;

        ex3_oe_x  <= ex3_oe and ex3_ov_en;
        ex3_ue_x  <= ex3_ue and ex3_uf_en;

        ex3_ovf_en_oe0 <= ex3_ov_en and not ex3_oe ;
        ex3_ovf_en_oe1 <= ex3_ov_en and     ex3_oe ;
        ex3_unf_en_oe0 <= ex3_uf_en and not ex3_ue ;
        ex3_unf_en_oe1 <= ex3_uf_en and     ex3_ue ;


   --//##-----------------------------------------
   --//## sign logic
   --//##-----------------------------------------
     -- multiply always uses p_sign (already replicated)

   ex3_spec_sign_sel <= ex3_spec_sel_e  or
                        ex3_prenorm     or 
                        ex3_fsel        or
                        ex3_mv_from_scr or
                        ex3_rnd_to_int  or
                        ex3_log2e       or-- log2e/pow2e regular sign merged in later
                        ex3_pow2e       or
                        ex3_uc_ft_pos   or 
                        ex3_uc_ft_neg; 

   ex3_p_sign_may  <= ex3_math and ex3_effsub_eac ;

   ex3_spec_sign_x <= (ex3_spec_sign and not ex3_uc_ft_pos) or  ex3_uc_ft_neg;


   ex3_sign_pco <= -- favors p-sign
         (     ex3_spec_sign_sel and ex3_spec_sign_x            ) or
         ( not ex3_spec_sign_sel and ex3_b_sign_alt and not ex3_p_sign_may                                       ) or
         ( not ex3_spec_sign_sel and ex3_p_sign     and     ex3_p_sign_may  and not (ex3_prod_zero and ex3_math) ) or 
         ( not ex3_spec_sign_sel and ex3_b_sign_alt and     ex3_p_sign_may  and     (ex3_prod_zero and ex3_math) ); 
            
   ex3_sign_nco <= -- favors b-sign
         (     ex3_spec_sign_sel and ex3_spec_sign_x           ) or
         ( not ex3_spec_sign_sel and ex3_b_sign_alt and not(ex3_b_zero and ex3_math) ) or
         ( not ex3_spec_sign_sel and ex3_p_sign     and    (ex3_b_zero and ex3_math) );
                  

--//################################################################
--//# ex4 latches
--//################################################################


 
    ex4_scr_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee, --tidn,
        delay_lclkr      => delay_lclkr(4), --tidn,
        mpw1_b           => mpw1_b(4) ,--tidn,
        mpw2_b           => mpw2_b(0) ,--tidn,
        nclk             => nclk,
        act              => ex3_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex4_scr_so  ,                      
        scin             => ex4_scr_si  ,                    
        -------------------
         din(0)             => ex3_ve        ,
         din(1)             => ex3_oe_x      ,
         din(2)             => ex3_ue_x      ,
         din(3)             => ex3_ze        ,
         din(4)             => ex3_xe        ,
         din(5)             => ex3_nonieee   ,
         din(6)             => ex3_rnd0      ,
         din(7)             => ex3_rnd1      ,
        -------------------
        dout(0)             => ex4_ve      ,
        dout(1)             => ex4_oe      ,
        dout(2)             => ex4_ue      ,
        dout(3)             => ex4_ze      ,
        dout(4)             => ex4_xe      ,
        dout(5)             => ex4_nonieee ,
        dout(6)             => ex4_rnd0    ,
        dout(7)             => ex4_rnd1    );

 ex3_sp_x <= ex3_sp or ex3_sp_conv ;

    ex4_ctl_lat:  tri_rlmreg_p generic map (width=> 29, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee, --tidn,
        delay_lclkr      => delay_lclkr(4), --tidn,
        mpw1_b           => mpw1_b(4) ,--tidn,
        mpw2_b           => mpw2_b(0) ,--tidn,
        nclk             => nclk,
        act              => ex3_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex4_ctl_so  ,                      
        scin             => ex4_ctl_si  ,                    
        -------------------
         din( 0)            => ex3_fsel             ,
         din( 1)            => ex3_from_integer     ,
         din( 2)            => ex3_to_integer       ,
         din( 3)            => ex3_math             ,
         din( 4)            => ex3_est_recip        ,
         din( 5)            => ex3_est_rsqrt        ,
         din( 6)            => ex3_move             ,
         din( 7)            => ex3_compare          ,
         din( 8)            => ex3_prenorm          ,
         din( 9)            => ex3_frsp             ,
         din(10)            => ex3_mv_to_scr        ,
         din(11)            => ex3_mv_from_scr      ,
         din(12)            => ex3_div_beg          ,
         din(13)            => ex3_sqrt_beg         ,
         din(14)            => ex3_sp_x             ,
         din(15)            => ex3_word_to          ,
         din(16)            => ex3_sub_op           ,
         din(17)            => ex3_rnd_dis          ,
         din(18)            => ex3_inv_sign         ,
         din(19)            => ex3_sign_pco         ,
         din(20)            => ex3_sign_nco         ,
         din(21)            => ex3_byp_prod_nz      ,
         din(22)            => ex3_effsub_eac       ,
         din(23)            => ex3_rnd_to_int       ,
         din(24)            => ex3_uns              ,
         din(25)            => ex3_log2e            ,
         din(26)            => ex3_pow2e            ,  
         din(27)            => ex3_ovf_unf_dis      ,  
         din(28)            => ex3_nj_deno_x        ,
        -------------------
        dout( 0)            => ex4_fsel             ,
        dout( 1)            => ex4_from_integer     ,
        dout( 2)            => ex4_to_integer       ,
        dout( 3)            => ex4_math             ,
        dout( 4)            => ex4_est_recip        ,
        dout( 5)            => ex4_est_rsqrt        ,
        dout( 6)            => ex4_move             ,
        dout( 7)            => ex4_compare          ,
        dout( 8)            => ex4_prenorm          ,
        dout( 9)            => ex4_frsp             ,
        dout(10)            => ex4_mv_to_scr        ,
        dout(11)            => ex4_mv_from_scr      ,
        dout(12)            => ex4_div_beg          ,
        dout(13)            => ex4_sqrt_beg         ,
        dout(14)            => ex4_sp               ,
        dout(15)            => ex4_word             ,
        dout(16)            => ex4_sub_op           ,
        dout(17)            => ex4_rnd_dis          ,
        dout(18)            => ex4_inv_sign         ,
        dout(19)            => ex4_sign_pco         ,
        dout(20)            => ex4_sign_nco         ,
        dout(21)            => ex4_byp_prod_nz      ,
        dout(22)            => ex4_effsub_eac       ,
        dout(23)            => ex4_rnd_to_int       , 
        dout(24)            => ex4_uns              , 
        dout(25)            => ex4_log2e            , 
        dout(26)            => ex4_pow2e            ,
        dout(27)            => ex4_ovf_unf_dis      ,
        dout(28)            => ex4_nj_deno         );


        f_pic_ex4_byp_prod_nz  <= ex4_byp_prod_nz ;


    ex4_flg_lat:  tri_rlmreg_p generic map (width=> 38, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee, --tidn,
        delay_lclkr      => delay_lclkr(4), --tidn,
        mpw1_b           => mpw1_b(4) ,--tidn,
        mpw2_b           => mpw2_b(0) ,--tidn,
        nclk             => nclk,
        act              => ex3_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex4_flg_so  ,                      
        scin             => ex4_flg_si  ,                    
        -------------------
         din( 0)            => ex3_vxsnan        ,--exceptions
         din( 1)            => ex3_vxvc          ,  
         din( 2)            => ex3_vxcvi         ,
         din( 3)            => ex3_vxzdz         ,
         din( 4)            => ex3_vxidi         ,
         din( 5)            => ex3_vximz         ,
         din( 6)            => ex3_vxisi         ,
         din( 7)            => ex3_vxsqrt        ,
         din( 8)            => ex3_zx            ,
         din( 9)            => ex3_gen_nan_mutex     , --sel_k
         din(10)            => ex3_gen_inf_mutex     ,
         din(11)            => ex3_gen_max_mutex     ,
         din(12)            => ex3_gen_zer_mutex     ,
         din(13)            => ex3_gen_one_mutex     ,
         din(14)            => ex3_quiet       ,
         din(15)            => ex3_to_int_wd   ,-- flags from toInt exponent
         din(16)            => ex3_to_int_dw   ,  
         din(17)            => ex3_to_int_ov    ,  
         din(18)            => ex3_to_int_ov_if  ,
         din(19)            => ex3_to_int_uns_neg , 
         din(20)            => ex3_spec_sel_e  ,
         din(21)            => ex3_spec_sel_f  ,
         din(22)            => ex3_ov_en     ,
         din(23)            => ex3_uf_en     ,
         din(24)            => ex3_ovf_en_oe0,
         din(25)            => ex3_ovf_en_oe1,
         din(26)            => ex3_unf_en_oe0,
         din(27)            => ex3_unf_en_oe1,
         din(28)            => ex3_pass_nan  ,
         din(29)            => f_alg_ex3_int_fr ,
         din(30)            => f_alg_ex3_int_fi ,
         din(31)            => ex3_uc_inc_lsb  ,
         din(32)            => ex3_uc_guard    ,
         din(33)            => ex3_uc_sticky   ,
         din(34)            => ex3_uc_gs_v     ,
         din(35)            => ex3_uc_g_ig     ,
         din(36)            => ex3_uc_mid      ,
         din(37)            => ex3_uc_end_spec ,
        -------------------
        dout( 0)            => ex4_vxsnan      ,--exceptions
        dout( 1)            => ex4_vxvc        ,  
        dout( 2)            => ex4_vxcvi       ,
        dout( 3)            => ex4_vxzdz       ,
        dout( 4)            => ex4_vxidi       ,
        dout( 5)            => ex4_vximz       ,
        dout( 6)            => ex4_vxisi       ,
        dout( 7)            => ex4_vxsqrt      ,
        dout( 8)            => ex4_zx          ,
        dout( 9)            => ex4_gen_nan     , --sel_k
        dout(10)            => ex4_gen_inf     ,
        dout(11)            => ex4_gen_max     ,
        dout(12)            => ex4_gen_zero    ,
        dout(13)            => ex4_gen_one     ,
        dout(14)            => ex4_quiet       ,
        dout(15)            => ex4_to_int_wd   ,-- flags from toInt exponent
        dout(16)            => ex4_to_int_dw   ,  
        dout(17)            => ex4_to_int_ov   ,  
        dout(18)            => ex4_to_int_ov_if  ,
        dout(19)            => ex4_to_int_uns_neg , 
        dout(20)            => ex4_spec_sel_e ,
        dout(21)            => ex4_spec_sel_f ,
        dout(22)            => ex4_ov_en      ,
        dout(23)            => ex4_uf_en       ,
        dout(24)            => ex4_ovf_en_oe0  ,
        dout(25)            => ex4_ovf_en_oe1  ,
        dout(26)            => ex4_unf_en_oe0  ,
        dout(27)            => ex4_unf_en_oe1  ,
        dout(28)            => ex4_pass_nan    ,
        dout(29)            => ex4_int_fr      ,
        dout(30)            => ex4_int_fi      ,
        dout(31)            => ex4_uc_inc_lsb  ,
        dout(32)            => ex4_uc_guard    ,
        dout(33)            => ex4_uc_sticky   ,
        dout(34)            => ex4_uc_gs_v     ,
        dout(35)            => ex4_uc_g_ig     ,
        dout(36)            => ex4_uc_mid      ,
        dout(37)            => ex4_uc_end_spec ); 


        ex4_to_int_ov_all_x <= 
            ( ex4_to_int_ov                                                                              ) or
            ( f_add_ex4_to_int_ovf_wd(0)  and ex4_to_int_wd and     ex4_uns and not ex4_to_int_uns_neg   ) or  
            ( f_add_ex4_to_int_ovf_dw(0)  and ex4_to_int_dw and     ex4_uns and not ex4_to_int_uns_neg   ) or  
            ( f_add_ex4_to_int_ovf_wd(1)  and ex4_to_int_wd and not ex4_uns and ex4_to_int_ov_if         ) or 
            ( f_add_ex4_to_int_ovf_dw(1)  and ex4_to_int_dw and not ex4_uns and ex4_to_int_ov_if         ) ;

        ex4_to_int_ov_all <=
                 ex4_to_int_uns_neg or -- may not set vxcvi ... but the result will be zero
                 ex4_to_int_ov_all_x ; 

        

                                               -- only set flag if dont successfuly round to zero
                                               -- adder bit [99] was not flipped for the negate,
                                               -- so it is the carry-out ... "0" co means negative
        ex4_vxcvi_ov <= ex4_vxcvi           or                                                   
                        ex4_to_int_ov_all_x or                                                   
                   (ex4_to_int_uns_neg and not f_add_ex4_to_int_ovf_dw(0) and ex4_to_int_dw) or  
                   (ex4_to_int_uns_neg and not f_add_ex4_to_int_ovf_dw(0) and ex4_to_int_wd)   ; 


        ex4_fr_spec   <=    ( ex4_int_fr and ex4_to_integer and not ex4_rnd_to_int and not ex4_vxcvi_ov  ); 
        ex4_fi_spec   <=    ( ex4_int_fi and ex4_to_integer and not ex4_rnd_to_int and not ex4_vxcvi_ov  ); 

        ex4_sel_est <= (ex4_est_recip or ex4_est_rsqrt) and
                   not (ex4_pass_nan );   

        f_pic_ex4_quiet_b         <= not ex4_quiet ;--output--
        f_pic_ex4_sp_b            <= not ex4_sp    ;--output--
        f_pic_ex4_sel_est_b       <= not ex4_sel_est ;--output--

        f_pic_ex4_to_int_ov_all    <= ex4_to_int_ov_all    ;--output--

        f_pic_ex4_to_integer_b    <= not( ex4_to_integer and not ex4_rnd_to_int )   ;--output--
        f_pic_ex4_word_b          <= not ex4_word         ;--output--
        f_pic_ex4_uns_b           <= not ex4_uns          ;--output--

        f_pic_ex4_spec_sel_k_e    <= ex4_spec_sel_e ;--output--
        f_pic_ex4_spec_sel_k_f    <= ex4_spec_sel_f ;--output--

        f_pic_ex4_sel_fpscr_b     <= not ex4_mv_from_scr  ;--output--
        f_pic_ex4_spec_inf_b      <= not ex4_gen_inf      ;--output--


        f_pic_ex4_oe              <=     ex4_oe         ;--output--
        f_pic_ex4_ue              <=     ex4_ue         ;--output--
        f_pic_ex4_ov_en           <=     ex4_ov_en  and not ex4_spec_sel_e    ;--output--
        f_pic_ex4_uf_en           <=     ex4_uf_en  and not ex4_spec_sel_e    ;--output--
        f_pic_ex4_ovf_en_oe0_b    <= not ex4_ovf_en_oe0 ;--output--
        f_pic_ex4_unf_en_ue0_b    <= not ex4_unf_en_oe0 ;--output--

        f_pic_ex4_ovf_en_oe1_b    <= not( ex4_ovf_en_oe1 and not ex4_uc_mid );--output--
        f_pic_ex4_unf_en_ue1_b    <= not( ex4_unf_en_oe1 and not ex4_uc_mid );--output--

--//################################################################
--//# ex4 logic
--//################################################################
        -- fmr/fneg/fabs/fnabs
        -- fsel
        -- mffs
        -- mcrfs, mtcrf, mtfs*
        -- prenorm_sp prenorm_dp
        -- fcomp
        -- fmul fadd fsub fmadd fmsub fnmsub fnmadd
        -- fres,frsqrte
        -- frsp

        ex4_rnd_nr <= not ex4_rnd0 and not ex4_rnd1;
        ex4_rnd_zr <= not ex4_rnd0 and     ex4_rnd1;
        ex4_rnd_pi <=     ex4_rnd0 and not ex4_rnd1;
        ex4_rnd_ni <=     ex4_rnd0 and     ex4_rnd1;

        ex4_rnd_en <= not ex4_rnd_dis     and 
                      not ex4_sel_spec_e  and 
                      ( ex4_math or ex4_frsp or ex4_from_integer);
        ex4_rnd_inf_ok  <= ( ex4_rnd_en and ex4_rnd_pi and not ex4_round_sign ) or 
                           ( ex4_rnd_en and ex4_rnd_ni and     ex4_round_sign ) ;
        ex4_rnd_nr_ok   <=   ex4_rnd_en and ex4_rnd_nr ;
        f_pic_ex4_rnd_inf_ok_b    <= not ex4_rnd_inf_ok ;--output--
        f_pic_ex4_rnd_ni_b        <= not ex4_rnd_ni     ;--output--
        f_pic_ex4_rnd_nr_b        <= not ex4_rnd_nr_ok  ;--output--


----------------------------

        ex4_uc_g_v <= ex4_uc_gs_v and not ex4_uc_g_ig ;
        ex4_uc_s_v <= ex4_uc_gs_v ;

        f_pic_ex4_nj_deno            <= ex4_nj_deno    ;--output--
        f_pic_ex5_uc_inc_lsb         <= ex5_uc_inc_lsb ;--output--
        f_pic_ex5_uc_guard           <= ex5_uc_guard   ;--output--
        f_pic_ex5_uc_sticky          <= ex5_uc_sticky  ;--output--
        f_pic_ex5_uc_g_v             <= ex5_uc_g_v     ;--output--
        f_pic_ex5_uc_s_v             <= ex5_uc_s_v     ;--output--
----------------------------

  ex4_vx <=  ex4_vxsnan or 
             ex4_vxisi  or 
             ex4_vxidi  or 
             ex4_vxzdz  or 
             ex4_vximz  or 
             ex4_vxvc   or 
             ex4_vxsqrt or 
             ex4_vxcvi_ov  ;

  ex4_upd_fpscr_ops <=
            ( ex4_math and not ex4_uc_mid )  or  -- microcode only changes fpscr on last iteration
             ex4_est_recip    or 
             ex4_est_rsqrt    or
             ex4_to_integer   or 
             ex4_from_integer or
             ex4_frsp         or
             ex4_rnd_to_int   or 
             ex4_compare      ;  


  ex4_scr_upd_pipe <= ex4_upd_fpscr_ops and not ex4_ovf_unf_dis; 
  ex4_scr_upd_move <= ex4_mv_to_scr                            ; 


  ex4_fpr_wr_dis   <= -- does not include include iu cancel
            (ex4_fprf_hold     ) ; 



  ex4_sel_spec_e <= 
             ex4_gen_one  or 
             ex4_pass_nan or
             ex4_gen_nan  or
             ex4_gen_inf  or          
             ex4_gen_zero ;

  ex4_sel_spec_f <= 
             ex4_gen_one  or 
             ex4_gen_nan  or
             ex4_gen_inf  or          
             ex4_gen_zero ;

  ex4_sel_spec_fr <=
             ex4_gen_one    or 
             ex4_sel_spec_e or
             ex4_est_recip  or 
             ex4_est_rsqrt  or
             ex4_rnd_to_int ;

--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
--$$ the spec has changed , overflow <ex4_to_int_ov_all> for to_ineger should now set fr_pipe_v fr=00
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

  ex4_ox_pipe_v    <= not ex4_sel_spec_e  and not ex4_compare and not ex4_to_integer and not ex4_from_integer and not ex4_rnd_to_int and not ex4_uc_end_spec;
  ex4_fr_pipe_v    <= not ex4_sel_spec_fr and not ex4_compare and not ex4_to_integer                          and not ex4_rnd_to_int and not ex4_uc_end_spec;


  ex4_fprf_pipe_v  <= not ex4_sel_spec_e  and not ex4_compare and not( ex4_to_integer and not ex4_rnd_to_int) and not ex4_fprf_hold;   

  ex4_fprf_hold_ops <= ex4_to_integer or
                       ex4_frsp       or
                       ex4_rnd_to_int or 
                      (ex4_math       and not ex4_uc_mid) or 
                      (ex4_est_recip  and not ex4_uc_mid) or
                      (ex4_est_rsqrt  and not ex4_uc_mid) ;

  ex4_fprf_hold    <=
          (ex4_ve and ex4_vx and ex4_fprf_hold_ops ) or
          (ex4_ze and ex4_zx and ex4_fprf_hold_ops );

  -- FPRF
  -- 1 0 0 0 1  QNAN     [0]  qnan | den | (sign*zero)
  -- 0 1 0 0 1 -INF      [1]  sign * !zero
  -- 0 1 0 0 0 -norm     [2] !sign * !zero * !qnan
  -- 1 1 0 0 0 -den      [3]  zero
  -- 1 0 0 1 0 -zero     [4]  inf   | qnan
  -- 0 0 0 1 0 +zero
  -- 1 0 1 0 0 +den
  -- 0 0 1 0 0 +norm
  -- 0 0 1 0 1 +inf
  --
  -- ex4_pass_nan      10001  @
  -- ex4_gen_nan       10001  @
  -- ex4_gen_inf  (-)  01001
  -- ex4_gen_inf  (+)  00101
  -- ex4_gen_zero (-)  10010  @
  -- ex4_gen_zero (+)  00010  @
  -- ex4_gen_one  (+)  00100  +norm
  -- ex4_gen_one  (-)  01000  -norm

  ex4_gen_inf_sign <= ex4_round_sign xor (ex4_inv_sign and not ex4_pass_nan and not ex4_gen_nan) ;


  --[0] nan, -zer, -den, +den ... (spec does not create den)
  ex4_fprf_spec_x(0) <=
         ex4_pass_nan or
         ex4_gen_nan  or
       ( ex4_gen_zero and    (ex4_math and ex4_effsub_eac) and (ex4_rnd_ni     xor ex4_inv_sign) ) or  
       ( ex4_gen_zero and not(ex4_math and ex4_effsub_eac) and (ex4_round_sign xor ex4_inv_sign) );    

  ex4_fprf_spec_x(1) <= (                               ex4_gen_inf  and     ex4_gen_inf_sign ) or
                        ( ex4_gen_one and     ex4_round_sign                                  );
  ex4_fprf_spec_x(2) <= (                               ex4_gen_inf  and not ex4_gen_inf_sign ) or
                        ( ex4_gen_one and not ex4_round_sign                                  );
  ex4_fprf_spec_x(3) <=                                 ex4_gen_zero ;
  ex4_fprf_spec_x(4) <= ex4_pass_nan or ex4_gen_nan or  ex4_gen_inf  ;

  ex4_fprf_spec(0 to 4) <=
       ( (tidn & f_add_ex4_fpcc_iu(0 to 3))                              and     (0 to 4 => ex4_compare                 ) ) or               
       ( ex4_fprf_spec_x(0 to 4) and not (0 to 4 => ex4_to_integer_ken ) and not (0 to 4 => ex4_compare or ex4_fprf_hold) ) ;

  -- selects for constant (pipe and spec) ??? need mayOvf

  -- k depends on the rounding mode (also diff for to intetger)
  -- NAN : pipe does not create nan
  -- +/-   INF frac=0
  -- MAX   FP  frac=1
  -- MAX +int frac=1
  -- MAX -INT frac=0

  ex4_may_ovf <= f_eov_ex4_may_ovf;

  ex4_k_max_fp      <=
         ( ex4_may_ovf and ex4_rnd_zr                        ) or
         ( ex4_may_ovf and ex4_rnd_pi and     ex4_round_sign ) or 
         ( ex4_may_ovf and ex4_rnd_ni and not ex4_round_sign ) ;

  --exponent  1 <= tidn (sign)
  --exponent  2 <= tidn (2048)
  --exponent  3 <= msb  (1024) for inf/nan
  --exponent  4 <= sp    (512)
  --exponent  5 <= sp    (256)
  --exponent  6 <= sp    (128)
  --exponent  7 <= mid    (64)
  --exponent  8 <= mid    (64)
  --exponent  9 <= mid    (32)
  --exponent 10 <= mid    (16)
  --exponent 11 <= mid     (8)
  --exponent 12 <= mid     (4)
  --exponent 13 <= lsb     (1)


  ex4_gen_any <= ex4_gen_nan or
                 ex4_gen_inf or
                 ex4_gen_zero or
                 ex4_gen_one ;

  ex4_k_nan         <= (ex4_gen_nan or ex4_pass_nan)  and not ex4_to_integer_ken ;
                       
  ex4_k_inf         <= (     ex4_gen_inf and not ex4_to_integer_ken ) or
                       ( not ex4_gen_any and not ex4_to_integer_ken and ex4_may_ovf and not ex4_k_max_fp );

  ex4_k_max         <= (     ex4_gen_max and not ex4_to_integer_ken ) or 
                       ( not ex4_gen_any and not ex4_to_integer_ken and ex4_may_ovf and     ex4_k_max_fp );

  ex4_k_zer         <= (    ex4_gen_zero and not ex4_to_integer_ken ) or
                       (not ex4_gen_any  and not ex4_to_integer_ken and not ex4_may_ovf );

  ex4_k_one         <= ex4_gen_one ;


  ex4_to_integer_ken <= ex4_to_integer and not ex4_rnd_to_int ;


  ex4_k_int_zer     <= 
        (ex4_to_integer_ken and     ex4_uns and      ex4_gen_zero                                          )  or --uns
        (ex4_to_integer_ken and     ex4_uns and                           ex4_gen_nan                      )  or --uns
        (ex4_to_integer_ken and     ex4_uns and                                               ex4_sign_nco )  or --uns
        (ex4_to_integer_ken and not ex4_uns and      ex4_gen_zero                                          )  ;  --sgn
                      
  ex4_k_int_maxpos  <=
        ( ex4_to_integer_ken and     ex4_uns and not ex4_gen_zero and not ex4_gen_nan and not ex4_sign_nco ) or  --uns
        ( ex4_to_integer_ken and not ex4_uns and not ex4_gen_zero and not ex4_gen_nan and not ex4_sign_nco );    --sgn

  ex4_k_int_maxneg  <=
        ( ex4_to_integer_ken and not ex4_uns and not ex4_gen_zero and     ex4_gen_nan                      ) or  --sgn
        ( ex4_to_integer_ken and not ex4_uns and not ex4_gen_zero and                         ex4_sign_nco );    --sgn







   ex4_en_exact_zero <= ex4_math       and
                        ex4_effsub_eac and
                    not ex4_sel_spec_e ; -- nan_pass, gen_nan, gen_inf, gen_zero

   ex4_invert_sign   <= ex4_inv_sign and
                    not ex4_pass_nan and
                    not ex4_gen_nan  and
                    not (ex4_gen_zero and ex4_effsub_eac) ; -- (sign-of-exact-zero)


   ex4_sign_pco_x <= (not (ex4_gen_zero and ex4_math and ex4_effsub_eac) and ex4_sign_pco                  ) or
                     (    (ex4_gen_zero and ex4_math and ex4_effsub_eac) and (ex4_rnd_ni xor ex4_inv_sign) ); 
   ex4_sign_nco_x <= (not (ex4_gen_zero and ex4_math and ex4_effsub_eac) and ex4_sign_nco                  ) or
                     (    (ex4_gen_zero and ex4_math and ex4_effsub_eac) and (ex4_rnd_ni xor ex4_inv_sign) ); 

   ex4_round_sign    <=  -- co means a<b (for math only)
          (     f_add_ex4_sign_carry and  ex4_sign_pco  ) or  
          ( not f_add_ex4_sign_carry and  ex4_sign_nco  );


   ex4_to_int_k_sign <= -- sign bit in position 32 for word ops
         ( not ex4_word and not ex4_k_int_zer and     ex4_uns and not ex4_sign_nco ) or 
         ( not ex4_word and not ex4_k_int_zer and not ex4_uns and     ex4_sign_nco ) ; 

   ex4_to_int_ov_all_gt <= ex4_to_int_ov_all or ex4_k_int_zer ;

   ex4_sign_pco_xx <=  (ex4_sign_pco_x and not ex4_to_int_ov_all_gt ) or  (ex4_to_int_k_sign and ex4_to_int_ov_all_gt) ;
   ex4_sign_nco_xx <=  (ex4_sign_nco_x and not ex4_to_int_ov_all_gt ) or  (ex4_to_int_k_sign and ex4_to_int_ov_all_gt) ;


   ex4_round_sign_x  <=  -- co means a<b (for math only)
          (     f_add_ex4_sign_carry and  ex4_sign_pco_xx  ) or 
          ( not f_add_ex4_sign_carry and  ex4_sign_nco_xx  );

 
--//################################################################
--//# ex5 latches
--//################################################################

     ex4_k_nan_x         <= ( ex4_k_nan and not ex4_mv_from_scr );
     ex4_k_inf_x         <= ( ex4_k_inf and not ex4_mv_from_scr );
     ex4_k_max_x         <= ( ex4_k_max and not ex4_mv_from_scr );
     ex4_k_zer_x         <= ( ex4_k_zer or      ex4_mv_from_scr );
     ex4_k_one_x         <= ( ex4_k_one and not ex4_mv_from_scr );

    ex5_flg_lat:  tri_rlmreg_p generic map (width=> 42, expand_type => expand_type) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(5), --tidn,
        mpw1_b           => mpw1_b(5), --tidn,
        mpw2_b           => mpw2_b(1), --tidn,
        nclk             => nclk,
        act              => ex4_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex5_flg_so  ,                      
        scin             => ex5_flg_si  ,                    
        -------------------
         din( 0)            => ex4_zx           ,--exceptions
         din( 1)            => ex4_vxsnan       ,
         din( 2)            => ex4_vxisi        ,
         din( 3)            => ex4_vxidi        ,  
         din( 4)            => ex4_vxzdz        ,
         din( 5)            => ex4_vximz        ,
         din( 6)            => ex4_vxvc         ,
         din( 7)            => ex4_vxsqrt       ,
         din( 8)            => ex4_vxcvi_ov     ,
         din( 9)            => ex4_scr_upd_move ,-- write enables
         din(10)            => ex4_scr_upd_pipe ,
         din(11)            => ex4_fpr_wr_dis   ,
         din(12)            => ex4_ox_pipe_v    ,-- select pipe value
         din(13)            => ex4_fr_pipe_v    ,
         din(14)            => ex4_fprf_pipe_v  ,
         din(15 to 19)      => ex4_fprf_spec(0 to 4) , -- generate special value
         din(20)            => ex4_k_nan_x        ,
         din(21)            => ex4_k_inf_x        ,
         din(22)            => ex4_k_max_x        ,
         din(23)            => ex4_k_zer_x        ,
         din(24)            => ex4_k_one_x        ,
         din(25)            => ex4_k_int_maxpos   ,
         din(26)            => ex4_k_int_maxneg   ,
         din(27)            => ex4_k_int_zer      ,
         din(28)            => ex4_en_exact_zero   , -- sign
         din(29)            => ex4_invert_sign     ,

         din(30)            => ex4_round_sign_x  ,

         din(31)            => tidn     ,
         din(32)            => ex4_compare   ,
         din(33)            => ex4_frsp   ,
         din(34)            => ex4_fr_spec   ,
         din(35)            => ex4_fi_spec   ,
         din(36)            => ex4_fprf_hold  ,
         din(37)            => ex4_uc_inc_lsb  ,
         din(38)            => ex4_uc_guard    ,
         din(39)            => ex4_uc_sticky   ,
         din(40)            => ex4_uc_g_v     ,
         din(41)            => ex4_uc_s_v     ,
        -------------------
        dout( 0)            => ex5_zx           ,--exceptions
        dout( 1)            => ex5_vxsnan       ,
        dout( 2)            => ex5_vxisi        ,
        dout( 3)            => ex5_vxidi        ,  
        dout( 4)            => ex5_vxzdz        ,
        dout( 5)            => ex5_vximz        ,
        dout( 6)            => ex5_vxvc         ,
        dout( 7)            => ex5_vxsqrt       ,
        dout( 8)            => ex5_vxcvi        ,
        dout( 9)            => ex5_scr_upd_move ,-- write enables
        dout(10)            => ex5_scr_upd_pipe ,
        dout(11)            => ex5_fpr_wr_dis   ,
        dout(12)            => ex5_ox_pipe_v    ,-- select pipe values
        dout(13)            => ex5_fr_pipe_v    ,
        dout(14)            => ex5_fprf_pipe_v  ,
        dout(15 to 19)      => ex5_fprf_spec(0 to 4) , -- generate special value
        dout(20)            => ex5_k_nan        ,
        dout(21)            => ex5_k_inf        ,
        dout(22)            => ex5_k_max        ,
        dout(23)            => ex5_k_zer        ,
        dout(24)            => ex5_k_one        ,
        dout(25)            => ex5_k_int_maxpos ,
        dout(26)            => ex5_k_int_maxneg ,
        dout(27)            => ex5_k_int_zer    ,
        dout(28)            => ex5_en_exact_zero , -- sign
        dout(29)            => ex5_invert_sign   ,
        dout(30)            => ex5_round_sign    ,
        dout(31)            => ex5_unused  ,
        dout(32)            => ex5_compare ,
        dout(33)            => ex5_frsp ,
        dout(34)            => ex5_fr_spec ,
        dout(35)            => ex5_fi_spec ,
        dout(36)            => ex5_fprf_hold   ,
        dout(37)            => ex5_uc_inc_lsb  ,
        dout(38)            => ex5_uc_guard    ,
        dout(39)            => ex5_uc_sticky   ,
        dout(40)            => ex5_uc_g_v      ,
        dout(41)            => ex5_uc_s_v     );


        f_pic_ex5_frsp <= ex5_frsp ;

--//################################################################
--//# ex5 logic
--//################################################################
 

        f_pic_ex5_flag_zx_b       <= not ex5_zx           ;--output-- [05]
        f_pic_ex5_flag_vxsnan_b   <= not ex5_vxsnan       ;--output-- [07]
        f_pic_ex5_flag_vxisi_b    <= not ex5_vxisi        ;--output-- [08]
        f_pic_ex5_flag_vxidi_b    <= not ex5_vxidi        ;--output-- [09]
        f_pic_ex5_flag_vxzdz_b    <= not ex5_vxzdz        ;--output-- [10]
        f_pic_ex5_flag_vximz_b    <= not ex5_vximz        ;--output-- [11]
        f_pic_ex5_flag_vxvc_b     <= not ex5_vxvc         ;--output-- [12]
        f_pic_ex5_flag_vxsqrt_b   <= not ex5_vxsqrt       ;--output-- [22]
        f_pic_ex5_flag_vxcvi_b    <= not ex5_vxcvi        ;--output-- [23]

        f_pic_ex5_scr_upd_move_b  <= not ex5_scr_upd_move ;--output--
        f_pic_ex5_scr_upd_pipe_b  <= not ex5_scr_upd_pipe ;--output--
        f_pic_ex5_fpr_wr_dis_b    <= not ex5_fpr_wr_dis   ;--output--
        f_pic_ex5_compare_b       <= not ex5_compare      ;--output--

        f_pic_ex5_ox_pipe_v_b     <= not ex5_ox_pipe_v;   --output-- [03]
        f_pic_ex5_fr_pipe_v_b     <= not ex5_fr_pipe_v;   --output-- [13]
        f_pic_ex5_fprf_pipe_v_b   <= not ex5_fprf_pipe_v; --output-- [15:19]
 
        f_pic_ex5_fprf_spec_b(0 to 4) <= not ex5_fprf_spec(0 to 4);  --output--

        f_pic_ex5_k_nan           <= ex5_k_nan          ;--output--
        f_pic_ex5_k_inf           <= ex5_k_inf          ;--output--
        f_pic_ex5_k_max           <= ex5_k_max          ;--output--
        f_pic_ex5_k_zer           <= ex5_k_zer          ;--output--
        f_pic_ex5_k_one           <= ex5_k_one          ;--output--
        f_pic_ex5_k_int_maxpos    <= ex5_k_int_maxpos   ;--output--
        f_pic_ex5_k_int_maxneg    <= ex5_k_int_maxneg   ;--output--
        f_pic_ex5_k_int_zer       <= ex5_k_int_zer      ;--output--

        f_pic_ex5_en_exact_zero   <= ex5_en_exact_zero;--output--
        f_pic_ex5_invert_sign     <= ex5_invert_sign;  --output--
        f_pic_ex5_round_sign      <= ex5_round_sign;   --output--

        -----------------------------------------------------------


        f_pic_ex5_fi_pipe_v_b     <= not ex5_fr_pipe_v ;--output-- [14]
        f_pic_ex5_ux_pipe_v_b     <= not ex5_ox_pipe_v ;--output-- [04]
        f_pic_ex5_fprf_hold_b     <= not ex5_fprf_hold ; --output-- toint | (ve=1*(math|fprsp)*vx) ... not vxvc
        f_pic_ex5_fi_spec_b       <= not ex5_fi_spec; --output--
        f_pic_ex5_fr_spec_b       <= not ex5_fr_spec; --output--




--//################################################################
--//# scan string
--//################################################################


   ex1_ctl_si  (0 to 42) <= ex1_ctl_so  (1 to 42) & f_pic_si ;
   ex2_ctl_si  (0 to 56) <= ex2_ctl_so  (1 to 56) & ex1_ctl_so  (0);
   ex2_flg_si  (0 to 17) <= ex2_flg_so  (1 to 17) & ex2_ctl_so  (0);
   ex3_scr_si  (0 to  7) <= ex3_scr_so  (1 to  7) & ex2_flg_so  (0);
   ex3_ctl_si  (0 to 33) <= ex3_ctl_so  (1 to 33) & ex3_scr_so  (0);
   ex3_flg_si  (0 to 46) <= ex3_flg_so  (1 to 46) & ex3_ctl_so  (0);
   ex4_scr_si  (0 to  7) <= ex4_scr_so  (1 to  7) & ex3_flg_so  (0);
   ex4_ctl_si  (0 to 28) <= ex4_ctl_so  (1 to 28) & ex4_scr_so  (0);
   ex4_flg_si  (0 to 37) <= ex4_flg_so  (1 to 37) & ex4_ctl_so  (0);
   ex5_flg_si  (0 to 41) <= ex5_flg_so  (1 to 41) & ex4_flg_so  (0);
   act_si      (0 to 20) <= act_so      (1 to 20) & ex5_flg_so  (0);
   f_pic_so              <=  act_so  (0) ;


-------------------------


end; -- fuq_pic ARCHITECTURE
