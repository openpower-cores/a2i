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

entity fuq_mad is
generic(
     expand_type                    : integer := 2  ); -- 0 - ibm tech, 1 - other );
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
        ----------------------------------------------------------------------------
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

        ----------------------------------------------------------------------------
        f_dcd_rf1_aop_valid        :in  std_ulogic;
        f_dcd_rf1_cop_valid        :in  std_ulogic;
        f_dcd_rf1_bop_valid        :in  std_ulogic;
        f_dcd_rf1_sp               :in  std_ulogic; -- off for frsp
        f_dcd_rf1_emin_dp          :in  std_ulogic;                 -- prenorm_dp
        f_dcd_rf1_emin_sp          :in  std_ulogic;                 -- prenorm_sp, frsp
        f_dcd_rf1_force_pass_b     :in  std_ulogic;                 -- fmr,fnabbs,fabs,fneg,mtfsf

        f_dcd_rf1_fsel_b           :in  std_ulogic;                 -- fsel
        f_dcd_rf1_from_integer_b   :in  std_ulogic;                 -- fcfid (signed integer)
        f_dcd_rf1_to_integer_b     :in  std_ulogic;                 -- fcti* (signed integer 32/64)
        f_dcd_rf1_rnd_to_int_b     :in  std_ulogic;                 -- fri*
        f_dcd_rf1_math_b           :in  std_ulogic;                 -- fmul,fmad,fmsub,fadd,fsub,fnmsub,fnmadd
        f_dcd_rf1_est_recip_b      :in  std_ulogic;                 -- fres
        f_dcd_rf1_est_rsqrt_b      :in  std_ulogic;                 -- frsqrte
        f_dcd_rf1_move_b           :in  std_ulogic;                 -- fmr,fneg,fabs,fnabs
        f_dcd_rf1_prenorm_b        :in  std_ulogic;                 -- prenorm ?? need
        f_dcd_rf1_frsp_b           :in  std_ulogic;                 -- round-to-single-precision ?? need
        f_dcd_rf1_compare_b        :in  std_ulogic;                 -- fcomp*
        f_dcd_rf1_ordered_b        :in  std_ulogic;                 -- fcompo

        f_dcd_rf1_pow2e_b          :in  std_ulogic;                 -- pow2e  sp,  den==>0
        f_dcd_rf1_log2e_b          :in  std_ulogic;                 -- log2e  sp,  den==>0

        f_dcd_rf1_ftdiv            :in  std_ulogic;                 -- ftdiv
        f_dcd_rf1_ftsqrt           :in  std_ulogic;                 -- ftsqrt


        f_dcd_rf1_nj_deno          :in  std_ulogic;                 -- force output den to zero
        f_dcd_rf1_nj_deni          :in  std_ulogic;                 -- force  input den to zero

        f_dcd_rf1_sp_conv_b        :in  std_ulogic;                 -- for sp/dp convert
        f_dcd_rf1_word_b           :in  std_ulogic;                 -- for converts word/dw
        f_dcd_rf1_uns_b            :in  std_ulogic;                 -- for converts unsigned
        f_dcd_rf1_sub_op_b         :in  std_ulogic;                 -- fsub, fnmsub, fmsub

        f_dcd_rf1_force_excp_dis   :in  std_ulogic;

        f_dcd_rf1_op_rnd_v_b       :in  std_ulogic;                 -- rounding mode = nearest
        f_dcd_rf1_op_rnd_b         :in  std_ulogic_vector(0 to 1);  -- rounding mode = positive infinity
        f_dcd_rf1_inv_sign_b       :in  std_ulogic;                 -- fnmsub fnmadd
        f_dcd_rf1_sign_ctl_b       :in  std_ulogic_vector(0 to 1);  -- 0:fmr/fneg  1:fneg/fnabs
        f_dcd_rf1_sgncpy_b         :in  std_ulogic;                 -- for sgncpy instruction :
                                                                    -- BValid=1 Avalid=0 move=1 sgncpy=1
                                                                    -- sgnctl=fabs=00 <11 for _b>
                                                                    -- force pass, rnd_v=0, ovf_unf_dis,
        
        f_dcd_rf1_fpscr_bit_data_b :in  std_ulogic_vector(0 to 3);  --data to write to nibble (other than mtfsf)
        f_dcd_rf1_fpscr_bit_mask_b :in  std_ulogic_vector(0 to 3);  --enable update of bit within the nibble
        f_dcd_rf1_fpscr_nib_mask_b :in  std_ulogic_vector(0 to 8);  --enable update of this nibble
                                                                      -- [8] = 0 except
                                                                      --  if (mtfsi AND w=1 AND bf=000 )                 <= 0000_0000_1
                                                                      --  if (mtfsf AND L==1)                            <= 1111_1111_1
                                                                      --  if (mtfsf AND L=0 and w=1 and flm=xxxx_xxxx_1) <= 0000_0000_1
                                                                      --  if (mtfsf AND L=0 and w=1 and flm=xxxx_xxxx_0) <= 0000_0000_0
                                                                      --  if (mtfsf AND L=0 and w=0 and flm=xxxx_xxxx_1) <= dddd_dddd_0

        f_dcd_rf1_mv_to_scr_b      :in  std_ulogic;                 --mcrfs,mtfsf,mtfsfi,mtfsb0,mtfsb1
        f_dcd_rf1_mv_from_scr_b    :in  std_ulogic;                 --mffs
        f_dcd_rf1_mtfsbx_b         :in  std_ulogic;                 --fpscr set bit, reset bit
        f_dcd_rf1_mcrfs_b          :in  std_ulogic;                 --move fpscr field to cr and reset exceptions
        f_dcd_rf1_mtfsf_b          :in  std_ulogic;                 --move fpr data to fpscr
        f_dcd_rf1_mtfsfi_b         :in  std_ulogic;                 --move immediate data to fpscr

        f_dcd_ex1_perr_force_c     :in  std_ulogic;
        f_dcd_ex1_perr_fsel_ovrd   :in  std_ulogic;

        f_dcd_rf1_uc_fc_hulp       :in  std_ulogic;--byp  : bit 53 of multiplier
        f_dcd_rf1_uc_fa_pos        :in  std_ulogic;--byp  : immediate data
        f_dcd_rf1_uc_fc_pos        :in  std_ulogic;--byp  : immediate data
        f_dcd_rf1_uc_fb_pos        :in  std_ulogic;--byp  : immediate data
        f_dcd_rf1_uc_fc_0_5        :in  std_ulogic;--byp  : immediate data
        f_dcd_rf1_uc_fc_1_0        :in  std_ulogic;--byp  : immediate data
        f_dcd_rf1_uc_fc_1_minus    :in  std_ulogic;--byp  : immediate data
        f_dcd_rf1_uc_fb_1_0        :in  std_ulogic;--byp  : immediate data
        f_dcd_rf1_uc_fb_0_75       :in  std_ulogic;--byp  : immediate data
        f_dcd_rf1_uc_fb_0_5        :in  std_ulogic;--byp  : immediate data
        f_dcd_rf1_uc_ft_pos        :in  std_ulogic;--pic
        f_dcd_rf1_uc_ft_neg        :in  std_ulogic;--pic

        f_dcd_rf1_div_beg          :in std_ulogic; --old
        f_dcd_rf1_sqrt_beg         :in std_ulogic; --old
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


        f_ex2_b_den_flush          :out  std_ulogic                 ;--iu (does not include all gating) ???

        f_scr_ex7_cr_fld           :out std_ulogic_vector (0 to 3)     ;--o--
        f_add_ex4_fpcc_iu          :out std_ulogic_vector (0 to 3)     ;--o--
        f_pic_ex5_fpr_wr_dis_b     :out std_ulogic                     ;--o--
        f_rnd_ex6_res_expo         :out std_ulogic_vector (1 to 13)    ;--o--
        f_rnd_ex6_res_frac         :out std_ulogic_vector (0 to 52)    ;--o--
        f_rnd_ex6_res_sign         :out std_ulogic ;--o--
        f_scr_ex7_fx_thread0       :out std_ulogic_vector (0 to 3)     ;--o--
        f_scr_ex7_fx_thread1       :out std_ulogic_vector (0 to 3)     ;--o--
        f_scr_ex7_fx_thread2       :out std_ulogic_vector (0 to 3)     ;--o--
        f_scr_ex7_fx_thread3       :out std_ulogic_vector (0 to 3)     ;--o--

         ----------------------------------------------------------------------------
        rf1_thread_b               :in  std_ulogic_vector(0 to 3) ;
        f_dcd_rf1_act              :in  std_ulogic; 
        ----------------------------------------------------------------------------
        vdd                        : inout power_logic;
        gnd                        : inout power_logic;
        scan_in                    :in  std_ulogic_vector(0 to 17);
        scan_out                   :out std_ulogic_vector(0 to 17);

        clkoff_b                   :in  std_ulogic; -- tiup
        act_dis                    :in  std_ulogic; -- ??tidn??
        flush                      :in  std_ulogic; -- ??tidn??
        delay_lclkr                :in  std_ulogic_vector(1 to 7); -- tidn,
        mpw1_b                     :in  std_ulogic_vector(1 to 7); -- tidn,
        mpw2_b                     :in  std_ulogic_vector(0 to 1); -- tidn,
        thold_1                    :in  std_ulogic;
        sg_1                       :in  std_ulogic;
        fpu_enable                 :in  std_ulogic;
        nclk                       :in  clk_logic       
);      ----------------------------------------------------------------------------

end fuq_mad;


architecture fuq_mad of fuq_mad is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal f_fmt_ex1_inf_and_beyond_sp :std_ulogic ;
    signal perv_eie_sg_1      :std_ulogic; --PERV--
    signal perv_eov_sg_1      :std_ulogic; --PERV--
    signal perv_fmt_sg_1      :std_ulogic; --PERV--
    signal perv_mul_sg_1      :std_ulogic; --PERV--
    signal perv_alg_sg_1      :std_ulogic; --PERV--
    signal perv_add_sg_1      :std_ulogic; --PERV--
    signal perv_lza_sg_1      :std_ulogic; --PERV--
    signal perv_nrm_sg_1      :std_ulogic; --PERV--
    signal perv_rnd_sg_1      :std_ulogic; --PERV--
    signal perv_scr_sg_1      :std_ulogic; --PERV--
    signal perv_pic_sg_1      :std_ulogic; --PERV--
    signal perv_cr2_sg_1      :std_ulogic; --PERV--
    signal perv_eie_thold_1   :std_ulogic; --PERV--
    signal perv_eov_thold_1   :std_ulogic; --PERV--
    signal perv_fmt_thold_1   :std_ulogic; --PERV--
    signal perv_mul_thold_1   :std_ulogic; --PERV--
    signal perv_alg_thold_1   :std_ulogic; --PERV--
    signal perv_add_thold_1   :std_ulogic; --PERV--
    signal perv_lza_thold_1   :std_ulogic; --PERV--
    signal perv_nrm_thold_1   :std_ulogic; --PERV--
    signal perv_rnd_thold_1   :std_ulogic; --PERV--
    signal perv_scr_thold_1   :std_ulogic; --PERV--
    signal perv_pic_thold_1   :std_ulogic; --PERV--
    signal perv_cr2_thold_1   :std_ulogic; --PERV--
    signal perv_eie_fpu_enable  :std_ulogic; --PERV--
    signal perv_eov_fpu_enable  :std_ulogic; --PERV--
    signal perv_fmt_fpu_enable  :std_ulogic; --PERV--
    signal perv_mul_fpu_enable  :std_ulogic; --PERV--
    signal perv_alg_fpu_enable  :std_ulogic; --PERV--
    signal perv_add_fpu_enable  :std_ulogic; --PERV--
    signal perv_lza_fpu_enable  :std_ulogic; --PERV--
    signal perv_nrm_fpu_enable  :std_ulogic; --PERV--
    signal perv_rnd_fpu_enable  :std_ulogic; --PERV--
    signal perv_scr_fpu_enable  :std_ulogic; --PERV--
    signal perv_pic_fpu_enable  :std_ulogic; --PERV--
    signal perv_cr2_fpu_enable  :std_ulogic; --PERV--



    signal f_eov_ex4_may_ovf                        :std_ulogic ;
    signal f_add_ex4_flag_eq                        :std_ulogic ;--o--
    signal f_add_ex4_flag_gt                        :std_ulogic ;--o--
    signal f_add_ex4_flag_lt                        :std_ulogic ;--o--
    signal f_add_ex4_flag_nan                       :std_ulogic ;--o--
    signal f_add_ex4_res                            :std_ulogic_vector (0 to 162)   ;--o--
    signal f_add_ex4_sign_carry                     :std_ulogic ;--o--
    signal f_add_ex4_sticky                         :std_ulogic ;--o--
    signal f_add_ex4_to_int_ovf_dw                  :std_ulogic_vector(0 to 1) ;--o--
    signal f_add_ex4_to_int_ovf_wd                  :std_ulogic_vector(0 to 1) ;--o--
    signal f_alg_ex2_effsub_eac_b                   :std_ulogic ;--o--
    signal f_alg_ex2_prod_z                         :std_ulogic ;--o--
    signal f_alg_ex2_res                            :std_ulogic_vector (0 to 162)   ;--o--
    signal f_alg_ex2_sel_byp                        :std_ulogic ;--o--
    signal f_alg_ex2_sh_ovf                         :std_ulogic ;--o--
    signal f_alg_ex2_sh_unf                         :std_ulogic ;--o--
    signal f_alg_ex3_frc_sel_p1                     :std_ulogic ;--o--
    signal f_alg_ex3_int_fi                         :std_ulogic ;--o--
    signal f_alg_ex3_int_fr                         :std_ulogic ;--o--
    signal f_alg_ex3_sticky                         :std_ulogic ;--o--

    signal f_byp_fmt_ex1_a_expo                     :std_ulogic_vector (1 to 13)    ;--o--
    signal f_byp_eie_ex1_a_expo                     :std_ulogic_vector (1 to 13)    ;--o--
    signal f_byp_alg_ex1_a_expo                     :std_ulogic_vector (1 to 13)    ;--o--
    signal f_byp_fmt_ex1_b_expo                     :std_ulogic_vector (1 to 13)    ;--o--
    signal f_byp_eie_ex1_b_expo                     :std_ulogic_vector (1 to 13)    ;--o--
    signal f_byp_alg_ex1_b_expo                     :std_ulogic_vector (1 to 13)    ;--o--
    signal f_byp_fmt_ex1_c_expo                     :std_ulogic_vector (1 to 13)    ;--o--
    signal f_byp_eie_ex1_c_expo                     :std_ulogic_vector (1 to 13)    ;--o--
    signal f_byp_alg_ex1_c_expo                     :std_ulogic_vector (1 to 13)    ;--o--
    signal f_byp_fmt_ex1_a_frac                     :std_ulogic_vector (0 to 52)    ;--o--
    signal f_byp_fmt_ex1_c_frac                     :std_ulogic_vector (0 to 52)    ;--o--
    signal f_byp_fmt_ex1_b_frac                     :std_ulogic_vector (0 to 52)    ;--o--
    signal f_byp_mul_ex1_a_frac                     :std_ulogic_vector (0 to 52)    ;--o--
    signal f_byp_mul_ex1_a_frac_17                  :std_ulogic                     ;--o--
    signal f_byp_mul_ex1_a_frac_35                  :std_ulogic                     ;--o--
    signal f_byp_mul_ex1_c_frac                     :std_ulogic_vector (0 to 53)    ;--o--
    signal f_byp_alg_ex1_b_frac                     :std_ulogic_vector (0 to 52)    ;--o--
    signal f_byp_fmt_ex1_a_sign                     :std_ulogic ;--o--
    signal f_byp_fmt_ex1_b_sign                     :std_ulogic ;--o--
    signal f_byp_fmt_ex1_c_sign                     :std_ulogic ;--o--
    signal f_byp_pic_ex1_a_sign                     :std_ulogic ;--o--
    signal f_byp_pic_ex1_b_sign                     :std_ulogic ;--o--
    signal f_byp_pic_ex1_c_sign                     :std_ulogic ;--o--
    signal f_byp_alg_ex1_b_sign                     :std_ulogic ;--o--

    signal f_cr2_ex1_fpscr_shadow                   :std_ulogic_vector(0 to 7)     ;--o--
    signal f_pic_ex2_rnd_inf_ok                     :std_ulogic ;--o--
    signal f_pic_ex2_rnd_nr                         :std_ulogic ;--o--
    signal f_cr2_ex3_fpscr_bit_data_b               :std_ulogic_vector(0 to 3);  
    signal f_cr2_ex3_fpscr_bit_mask_b               :std_ulogic_vector(0 to 3); 
    signal f_cr2_ex3_fpscr_nib_mask_b               :std_ulogic_vector(0 to 8);  
    signal f_cr2_ex3_mcrfs_b                        :std_ulogic ;--o--
    signal f_cr2_ex3_mtfsbx_b                       :std_ulogic ;--o--
    signal f_cr2_ex3_mtfsf_b                        :std_ulogic ;--o--
    signal f_cr2_ex3_mtfsfi_b                       :std_ulogic ;--o--
    signal f_cr2_ex3_thread_b                       :std_ulogic_vector(0 to 3);--o--
    signal f_pic_add_ex1_act_b                      :std_ulogic ;--o--
    signal f_pic_alg_ex1_act                        :std_ulogic ;--o--
    signal f_pic_cr2_ex1_act                        :std_ulogic ;--o--
    signal f_pic_eie_ex1_act                        :std_ulogic ;--o--
    signal f_pic_eov_ex2_act_b                      :std_ulogic ;--o--
    signal f_pic_ex1_effsub_raw                     :std_ulogic ;--o--
    signal f_pic_ex1_from_integer                   :std_ulogic ;--o--
    signal f_pic_ex1_fsel                           :std_ulogic ;--o--
    signal f_pic_ex1_sh_ovf_do                      :std_ulogic ;--o--
    signal f_pic_ex1_sh_ovf_ig_b                    :std_ulogic ;--o--
    signal f_pic_ex1_sh_unf_do                      :std_ulogic ;--o--
    signal f_pic_ex1_sh_unf_ig_b                    :std_ulogic ;--o--
    signal f_pic_ex2_force_sel_bexp                 :std_ulogic ;--o--
    signal f_pic_ex2_lzo_dis_prod                   :std_ulogic ;--o--
    signal f_pic_ex2_sp_b                           :std_ulogic ;--o--
    signal f_pic_ex2_sp_lzo                         :std_ulogic ;--o--
    signal f_pic_ex2_to_integer                     :std_ulogic ;--o--
    signal f_pic_ex2_prenorm                        :std_ulogic ;--o--
    signal f_pic_ex3_cmp_sgnneg                     :std_ulogic ;--o--
    signal f_pic_ex3_cmp_sgnpos                     :std_ulogic ;--o--
    signal f_pic_ex3_is_eq                          :std_ulogic ;--o--
    signal f_pic_ex3_is_gt                          :std_ulogic ;--o--
    signal f_pic_ex3_is_lt                          :std_ulogic ;--o--
    signal f_pic_ex3_is_nan                         :std_ulogic ;--o--
    signal f_pic_ex3_sel_est                        :std_ulogic ;--o--
    signal f_pic_ex3_sp_b                           :std_ulogic ;--o--
    signal f_pic_ex4_nj_deno                        :std_ulogic ;--o--
    signal f_pic_ex4_oe                             :std_ulogic ;--o--
    signal f_pic_ex4_ov_en                          :std_ulogic ;--o--
    signal f_pic_ex4_ovf_en_oe0_b                   :std_ulogic ;--o--
    signal f_pic_ex4_ovf_en_oe1_b                   :std_ulogic ;--o--
    signal f_pic_ex4_quiet_b                        :std_ulogic ;--o--
    signal f_pic_ex5_uc_inc_lsb                     :std_ulogic ;--o--
    signal f_pic_ex5_uc_guard                       :std_ulogic ;--o--
    signal f_pic_ex5_uc_sticky                      :std_ulogic ;--o--
    signal f_pic_ex5_uc_g_v                         :std_ulogic ;--o--
    signal f_pic_ex5_uc_s_v                         :std_ulogic ;--o--
    signal f_pic_ex4_rnd_inf_ok_b                   :std_ulogic ;--o--
    signal f_pic_ex4_rnd_ni_b                       :std_ulogic ;--o--
    signal f_pic_ex4_rnd_nr_b                       :std_ulogic ;--o--
    signal f_pic_ex4_sel_est_b                      :std_ulogic ;--o--
    signal f_pic_ex4_sel_fpscr_b                    :std_ulogic ;--o--
    signal f_pic_ex4_sp_b                           :std_ulogic ;--o--
    signal f_pic_ex4_spec_inf_b                     :std_ulogic ;--o--
    signal f_pic_ex4_spec_sel_k_e                   :std_ulogic ;--o--
    signal f_pic_ex4_spec_sel_k_f                   :std_ulogic ;--o--
    signal f_pic_ex4_to_int_ov_all                  :std_ulogic ;--o--
    signal f_pic_ex4_to_integer_b                   :std_ulogic ;--o--
    signal f_pic_ex4_word_b                         :std_ulogic ;--o--
    signal f_pic_ex4_uns_b                          :std_ulogic ;--o--
    signal f_pic_ex4_ue                             :std_ulogic ;--o--
    signal f_pic_ex4_uf_en                          :std_ulogic ;--o--
    signal f_pic_ex4_unf_en_ue0_b                   :std_ulogic ;--o--
    signal f_pic_ex4_unf_en_ue1_b                   :std_ulogic ;--o--
    signal f_pic_ex5_en_exact_zero                  :std_ulogic ;--o--
    signal f_pic_ex5_compare_b                      :std_ulogic ;--o--
    signal f_pic_ex2_ue1                            :std_ulogic ;--o--
    signal f_pic_ex2_frsp_ue1                       :std_ulogic ;--o--
    signal f_pic_ex1_frsp_ue1                       :std_ulogic ;--o--
    signal f_pic_ex5_frsp                           :std_ulogic ;--o--
    signal f_pic_ex5_fi_pipe_v_b                    :std_ulogic ;--o--
    signal f_pic_ex5_fi_spec_b                      :std_ulogic ;--o--
    signal f_pic_ex5_flag_vxcvi_b                   :std_ulogic ;--o--
    signal f_pic_ex5_flag_vxidi_b                   :std_ulogic ;--o--
    signal f_pic_ex5_flag_vximz_b                   :std_ulogic ;--o--
    signal f_pic_ex5_flag_vxisi_b                   :std_ulogic ;--o--
    signal f_pic_ex5_flag_vxsnan_b                  :std_ulogic ;--o--
    signal f_pic_ex5_flag_vxsqrt_b                  :std_ulogic ;--o--
    signal f_pic_ex5_flag_vxvc_b                    :std_ulogic ;--o--
    signal f_pic_ex5_flag_vxzdz_b                   :std_ulogic ;--o--
    signal f_pic_ex5_flag_zx_b                      :std_ulogic ;--o--
    signal f_pic_ex5_fprf_hold_b                    :std_ulogic ;--o--
    signal f_pic_ex5_fprf_pipe_v_b                  :std_ulogic ;--o--
    signal f_pic_ex5_fprf_spec_b                    :std_ulogic_vector (0 to 4)     ;--o--
    signal f_pic_ex5_fr_pipe_v_b                    :std_ulogic ;--o--
    signal f_pic_ex5_fr_spec_b                      :std_ulogic ;--o--
    signal f_pic_ex5_invert_sign                    :std_ulogic ;--o--
    signal f_pic_ex4_byp_prod_nz                    :std_ulogic ;--o--
    signal f_pic_ex5_k_nan                          :std_ulogic ;
    signal f_pic_ex5_k_inf                          :std_ulogic ;
    signal f_pic_ex5_k_max                          :std_ulogic ;
    signal f_pic_ex5_k_zer                          :std_ulogic ;
    signal f_pic_ex5_k_one                          :std_ulogic ;
    signal f_pic_ex5_k_int_maxpos                   :std_ulogic ;
    signal f_pic_ex5_k_int_maxneg                   :std_ulogic ;
    signal f_pic_ex5_k_int_zer                      :std_ulogic ;
    signal f_pic_ex5_ox_pipe_v_b                    :std_ulogic ;--o--
    signal f_pic_ex5_round_sign                     :std_ulogic ;--o--
    signal f_pic_ex5_scr_upd_move_b                 :std_ulogic ;--o--
    signal f_pic_ex5_scr_upd_pipe_b                 :std_ulogic ;--o--
    signal f_pic_ex5_ux_pipe_v_b                    :std_ulogic ;--o--
    signal f_pic_fmt_ex1_act                        :std_ulogic ;--o--
    signal f_pic_lza_ex1_act_b                      :std_ulogic ;--o--
    signal f_pic_mul_ex1_act                        :std_ulogic ;--o--
    signal f_pic_nrm_ex3_act_b                      :std_ulogic ;--o--
    signal f_pic_rnd_ex3_act_b                      :std_ulogic ;--o--
    signal f_pic_scr_ex2_act_b                      :std_ulogic ;--o--
    signal f_eie_ex2_dw_ov                          :std_ulogic ;--o--
    signal f_eie_ex2_dw_ov_if                       :std_ulogic ;--o--
    signal f_eie_ex2_lzo_expo                       :std_ulogic_vector (1 to 13)    ;--o--
    signal f_eie_ex2_b_expo                         :std_ulogic_vector (1 to 13)    ;--o--
    signal f_eie_ex2_tbl_expo                       :std_ulogic_vector (1 to 13)    ;--o--
    signal f_eie_ex2_wd_ov                          :std_ulogic ;--o--
    signal f_eie_ex2_wd_ov_if                       :std_ulogic ;--o--
    signal f_eie_ex3_iexp                           :std_ulogic_vector (1 to 13)    ;--o--
    signal f_eov_ex5_expo_p0                        :std_ulogic_vector (1 to 13)    ;--o--
    signal f_eov_ex5_expo_p0_ue1oe1                 :std_ulogic_vector (3 to 7)     ;--o--
    signal f_eov_ex5_expo_p1                        :std_ulogic_vector (1 to 13)    ;--o--
    signal f_eov_ex5_expo_p1_ue1oe1                 :std_ulogic_vector (3 to 7)     ;--o--
    signal f_eov_ex5_ovf_expo                       :std_ulogic ;--o--
    signal f_eov_ex5_ovf_if_expo                    :std_ulogic ;--o--
    signal f_eov_ex5_sel_k_e                        :std_ulogic ;--o--
    signal f_eov_ex5_sel_k_f                        :std_ulogic ;--o--
    signal f_eov_ex5_sel_kif_e                      :std_ulogic ;--o--
    signal f_eov_ex5_sel_kif_f                      :std_ulogic ;--o--
    signal f_eov_ex5_unf_expo                       :std_ulogic ;--o--
    signal f_fmt_ex1_a_expo_max                     :std_ulogic ;--o--
    signal f_fmt_ex1_a_zero                         :std_ulogic ;--o--
    signal f_fmt_ex1_a_frac_msb                     :std_ulogic ;--o--
    signal f_fmt_ex1_a_frac_zero                    :std_ulogic ;--o--
    signal f_fmt_ex1_b_expo_max                     :std_ulogic ;--o--
    signal f_fmt_ex1_b_zero                         :std_ulogic ;--o--
    signal f_fmt_ex1_b_frac_msb                     :std_ulogic ;--o--
    signal f_fmt_ex1_b_frac_z32                     :std_ulogic;
    signal f_fmt_ex1_b_frac_zero                    :std_ulogic ;--o--
    signal f_fmt_ex1_bop_byt                        :std_ulogic_vector(45 to 52)    ;--o--
    signal f_fmt_ex1_c_expo_max                     :std_ulogic ;--o--
    signal f_fmt_ex1_c_zero                         :std_ulogic ;--o--
    signal f_fmt_ex1_c_frac_msb                     :std_ulogic ;--o--
    signal f_fmt_ex1_c_frac_zero                    :std_ulogic ;--o--
    signal f_fmt_ex1_sp_invalid                     :std_ulogic ;--o--
    signal f_fmt_ex1_pass_sel                       :std_ulogic ;--o--
    signal f_fmt_ex1_prod_zero                      :std_ulogic ;--o--
    signal f_fmt_ex2_fsel_bsel                      :std_ulogic ;--o--
    signal f_fmt_ex2_pass_frac                      :std_ulogic_vector (0 to 52)    ;--o--
    signal f_fmt_ex2_pass_sign                      :std_ulogic ;--o--
    signal f_fmt_ex2_pass_msb                       :std_ulogic ;--o--
    signal f_fmt_ex1_b_imp                          :std_ulogic ;--o--
    signal f_lza_ex4_lza_amt                        :std_ulogic_vector (0 to 7)     ;--o--
    signal f_lza_ex4_lza_dcd64_cp1                  :std_ulogic_vector(0 to 2);
    signal f_lza_ex4_lza_dcd64_cp2                  :std_ulogic_vector(0 to 1);
    signal f_lza_ex4_lza_dcd64_cp3                  :std_ulogic_vector(0 to 0);     
    signal f_lza_ex4_sh_rgt_en                      :std_ulogic; 
    signal f_lza_ex4_sh_rgt_en_eov                  :std_ulogic; 
    signal f_lza_ex4_lza_amt_eov                    :std_ulogic_vector (0 to 7)     ;--o--
    signal f_lza_ex4_no_lza_edge                    :std_ulogic ;--o--
    signal f_mul_ex2_car                            :std_ulogic_vector (1 to 108)   ;--o--
    signal f_mul_ex2_sum                            :std_ulogic_vector (1 to 108)   ;--o--
    signal f_nrm_ex4_extra_shift                    :std_ulogic ;--o--
    signal f_nrm_ex5_exact_zero                     :std_ulogic ;--o--
    signal f_nrm_ex5_fpscr_wr_dat                   :std_ulogic_vector (0 to 31)    ;--o--
    signal f_nrm_ex5_fpscr_wr_dat_dfp               :std_ulogic_vector (0 to 3)    ;--o--
    signal f_nrm_ex5_int_lsbs                       :std_ulogic_vector (1 to 12)    ;--o--
    signal f_nrm_ex5_int_sign                       :std_ulogic;
    signal f_nrm_ex5_nrm_guard_dp                   :std_ulogic ;--o--
    signal f_nrm_ex5_nrm_guard_sp                   :std_ulogic ;--o--
    signal f_nrm_ex5_nrm_lsb_dp                     :std_ulogic ;--o--
    signal f_nrm_ex5_nrm_lsb_sp                     :std_ulogic ;--o--
    signal f_nrm_ex5_nrm_sticky_dp                  :std_ulogic ;--o--
    signal f_nrm_ex5_nrm_sticky_sp                  :std_ulogic ;--o--
    signal f_nrm_ex5_res                            :std_ulogic_vector (0 to 52)    ;--o--
    signal f_rnd_ex6_flag_den                       :std_ulogic ;--o--
    signal f_rnd_ex6_flag_fi                        :std_ulogic ;--o--
    signal f_rnd_ex6_flag_inf                       :std_ulogic ;--o--
    signal f_rnd_ex6_flag_ox                        :std_ulogic ;--o--
    signal f_rnd_ex6_flag_sgn                       :std_ulogic ;--o--
    signal f_rnd_ex6_flag_up                        :std_ulogic ;--o--
    signal f_rnd_ex6_flag_ux                        :std_ulogic ;--o--
    signal f_rnd_ex6_flag_zer                       :std_ulogic ;--o--
    signal f_sa3_ex3_c_lza                          :std_ulogic_vector (53 to 161)  ;--o--
    signal f_sa3_ex3_s_lza                          :std_ulogic_vector (0 to 162)  ;--o--
    signal f_sa3_ex3_c_add                          :std_ulogic_vector (53 to 161)  ;--o--
    signal f_sa3_ex3_s_add                          :std_ulogic_vector (0 to 162)  ;--o--
    signal f_scr_ex5_fpscr_rd_dat_dfp               :std_ulogic_vector (0 to 3)     ;--o--
    signal f_scr_ex5_fpscr_rd_dat                   :std_ulogic_vector (0 to 31)    ;--o--
    signal f_cr2_ex5_fpscr_rd_dat                   :std_ulogic_vector (24 to 31)    ;--o--
    signal f_cr2_ex6_fpscr_rd_dat                   :std_ulogic_vector (24 to 31)    ;--o--
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
signal f_mad_ex2_uc_a_expo_den , f_mad_ex2_uc_a_expo_den_sp :std_ulogic; -- a exponent <= 0
signal f_pic_ex1_nj_deni :std_ulogic;
signal f_fmt_ex2_ae_ge_54, f_fmt_ex2_be_ge_54, f_fmt_ex2_be_ge_2, f_fmt_ex2_be_ge_2044, f_fmt_ex2_tdiv_rng_chk :std_ulogic ;
signal f_fmt_ex2_be_den :std_ulogic;


begin





fbyp : entity WORK.fuq_byp(fuq_byp) generic map( expand_type => expand_type) port map( -- fuq_byp.vhdl
----------------------------------------------------------- -- fuq_byp.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        delay_lclkr                                      => delay_lclkr(1)              ,--i--
        mpw1_b                                           => mpw1_b(1)                   ,--i--
        mpw2_b                                           => mpw2_b(0)                   ,--i--
        thold_1                                          => perv_fmt_thold_1         ,--i--
        sg_1                                             => perv_fmt_sg_1            ,--i--
        fpu_enable                                       => perv_fmt_fpu_enable      ,--i--

        f_byp_si                                         => scan_in(0)               ,--i--fbyp
        f_byp_so                                         => scan_out(0)              ,--o--fbyp
        rf1_act                                          => f_dcd_rf1_act            ,--i--fbyp

        f_fpr_ex7_frt_sign                               => f_fpr_ex7_frt_sign             ,--i--fbyp
        f_fpr_ex7_frt_expo(1 to 13)                      => f_fpr_ex7_frt_expo(1 to 13)    ,--i--fbyp
        f_fpr_ex7_frt_frac(0 to 52)                      => f_fpr_ex7_frt_frac(0 to 52)    ,--i--fbyp
        f_fpr_ex7_load_sign                              => f_fpr_ex7_load_sign            ,--i--fbyp
        f_fpr_ex7_load_expo(3 to 13)                     => f_fpr_ex7_load_expo(3 to 13)   ,--i--fbyp
        f_fpr_ex7_load_frac(0 to 52)                     => f_fpr_ex7_load_frac(0 to 52)   ,--i--fbyp

        f_dcd_rf1_div_beg                                => f_dcd_rf1_div_beg          ,--i--fbyp
        f_dcd_rf1_uc_fa_pos                              => f_dcd_rf1_uc_fa_pos        ,--i--fbyp
        f_dcd_rf1_uc_fc_pos                              => f_dcd_rf1_uc_fc_pos        ,--i--fbyp
        f_dcd_rf1_uc_fb_pos                              => f_dcd_rf1_uc_fb_pos        ,--i--fbyp
        f_dcd_rf1_uc_fc_0_5                              => f_dcd_rf1_uc_fc_0_5        ,--i--fbyp
        f_dcd_rf1_uc_fc_1_0                              => f_dcd_rf1_uc_fc_1_0        ,--i--fbyp
        f_dcd_rf1_uc_fc_1_minus                          => f_dcd_rf1_uc_fc_1_minus    ,--i--fbyp
        f_dcd_rf1_uc_fb_1_0                              => f_dcd_rf1_uc_fb_1_0        ,--i--fbyp
        f_dcd_rf1_uc_fb_0_75                             => f_dcd_rf1_uc_fb_0_75       ,--i--fbyp
        f_dcd_rf1_uc_fb_0_5                              => f_dcd_rf1_uc_fb_0_5        ,--i--fbyp

       f_dcd_rf1_uc_fc_hulp                              => f_dcd_rf1_uc_fc_hulp      ,--i--fbyp
       f_dcd_rf1_bypsel_a_res0                           => f_dcd_rf1_bypsel_a_res0   ,--i--fbyp
       f_dcd_rf1_bypsel_a_res1                           => f_dcd_rf1_bypsel_a_res1   ,--i--fbyp
       f_dcd_rf1_bypsel_a_load0                          => f_dcd_rf1_bypsel_a_load0  ,--i--fbyp
       f_dcd_rf1_bypsel_a_load1                          => f_dcd_rf1_bypsel_a_load1  ,--i--fbyp
       f_dcd_rf1_bypsel_b_res0                           => f_dcd_rf1_bypsel_b_res0   ,--i--fbyp
       f_dcd_rf1_bypsel_b_res1                           => f_dcd_rf1_bypsel_b_res1   ,--i--fbyp
       f_dcd_rf1_bypsel_b_load0                          => f_dcd_rf1_bypsel_b_load0  ,--i--fbyp
       f_dcd_rf1_bypsel_b_load1                          => f_dcd_rf1_bypsel_b_load1  ,--i--fbyp
       f_dcd_rf1_bypsel_c_res0                           => f_dcd_rf1_bypsel_c_res0   ,--i--fbyp
       f_dcd_rf1_bypsel_c_res1                           => f_dcd_rf1_bypsel_c_res1   ,--i--fbyp
       f_dcd_rf1_bypsel_c_load0                          => f_dcd_rf1_bypsel_c_load0  ,--i--fbyp
       f_dcd_rf1_bypsel_c_load1                          => f_dcd_rf1_bypsel_c_load1  ,--i--fbyp

        f_rnd_ex6_res_sign                               => rnd_ex6_res_sign                                  ,--i--fbyp
        f_rnd_ex6_res_expo(1 to 13)                      => rnd_ex6_res_expo(1 to 13)                         ,--i--fbyp
        f_rnd_ex6_res_frac(0 to 52)                      => rnd_ex6_res_frac(0 to 52)                         ,--i--fbyp
        f_fpr_ex6_load_sign                              => f_fpr_ex6_load_sign                               ,--i--fbyp
        f_fpr_ex6_load_expo(3 to 13)                     => f_fpr_ex6_load_expo(3 to 13)                      ,--i--fbyp
        f_fpr_ex6_load_frac(0 to 52)                     => f_fpr_ex6_load_frac(0 to 52)                      ,--i--fbyp
        f_fpr_rf1_a_sign                                 => f_fpr_rf1_a_sign                                  ,--i--fbyp
        f_fpr_rf1_a_expo(1 to 13)                        => f_fpr_rf1_a_expo(1 to 13)                         ,--i--fbyp
        f_fpr_rf1_a_frac(0 to 52)                        => f_fpr_rf1_a_frac(0 to 52)                         ,--i--fbyp
        f_fpr_rf1_c_sign                                 => f_fpr_rf1_c_sign                                  ,--i--fbyp
        f_fpr_rf1_c_expo(1 to 13)                        => f_fpr_rf1_c_expo(1 to 13)                         ,--i--fbyp
        f_fpr_rf1_c_frac(0 to 52)                        => f_fpr_rf1_c_frac(0 to 52)                         ,--i--fbyp
        f_fpr_rf1_b_sign                                 => f_fpr_rf1_b_sign                                  ,--i--fbyp
        f_fpr_rf1_b_expo(1 to 13)                        => f_fpr_rf1_b_expo(1 to 13)                         ,--i--fbyp
        f_fpr_rf1_b_frac(0 to 52)                        => f_fpr_rf1_b_frac(0 to 52)                         ,--i--fbyp
        f_dcd_rf1_aop_valid                              => f_dcd_rf1_aop_valid                               ,--i--fbyp
        f_dcd_rf1_cop_valid                              => f_dcd_rf1_cop_valid                               ,--i--fbyp
        f_dcd_rf1_bop_valid                              => f_dcd_rf1_bop_valid                               ,--i--fbyp
        f_dcd_rf1_sp                                     => f_dcd_rf1_sp                                      ,--i--fbyp
        f_dcd_rf1_to_integer_b                           => f_dcd_rf1_to_integer_b                            ,--i--fbyp
        f_dcd_rf1_emin_dp                                => f_dcd_rf1_emin_dp                                 ,--i--fbyp
        f_dcd_rf1_emin_sp                                => f_dcd_rf1_emin_sp                                 ,--i--fbyp

        f_byp_fmt_ex1_a_expo(1 to 13)                    => f_byp_fmt_ex1_a_expo(1 to 13)                     ,--o--fbyp
        f_byp_eie_ex1_a_expo(1 to 13)                    => f_byp_eie_ex1_a_expo(1 to 13)                     ,--o--fbyp
        f_byp_alg_ex1_a_expo(1 to 13)                    => f_byp_alg_ex1_a_expo(1 to 13)                     ,--o--fbyp
        f_byp_fmt_ex1_c_expo(1 to 13)                    => f_byp_fmt_ex1_c_expo(1 to 13)                     ,--o--fbyp
        f_byp_eie_ex1_c_expo(1 to 13)                    => f_byp_eie_ex1_c_expo(1 to 13)                     ,--o--fbyp
        f_byp_alg_ex1_c_expo(1 to 13)                    => f_byp_alg_ex1_c_expo(1 to 13)                     ,--o--fbyp
        f_byp_fmt_ex1_b_expo(1 to 13)                    => f_byp_fmt_ex1_b_expo(1 to 13)                     ,--o--fbyp
        f_byp_eie_ex1_b_expo(1 to 13)                    => f_byp_eie_ex1_b_expo(1 to 13)                     ,--o--fbyp
        f_byp_alg_ex1_b_expo(1 to 13)                    => f_byp_alg_ex1_b_expo(1 to 13)                     ,--o--fbyp
        f_byp_fmt_ex1_a_sign                             => f_byp_fmt_ex1_a_sign                              ,--o--fbyp
        f_byp_fmt_ex1_c_sign                             => f_byp_fmt_ex1_c_sign                              ,--o--fbyp
        f_byp_fmt_ex1_b_sign                             => f_byp_fmt_ex1_b_sign                              ,--o--fbyp
        f_byp_pic_ex1_a_sign                             => f_byp_pic_ex1_a_sign                              ,--o--fbyp
        f_byp_pic_ex1_c_sign                             => f_byp_pic_ex1_c_sign                              ,--o--fbyp
        f_byp_pic_ex1_b_sign                             => f_byp_pic_ex1_b_sign                              ,--o--fbyp
        f_byp_alg_ex1_b_sign                             => f_byp_alg_ex1_b_sign                              ,--o--fbyp
        f_byp_mul_ex1_a_frac_17                          => f_byp_mul_ex1_a_frac_17                           ,--o--fbyp
        f_byp_mul_ex1_a_frac_35                          => f_byp_mul_ex1_a_frac_35                           ,--o--fbyp
        f_byp_mul_ex1_a_frac(0 to 52)                    => f_byp_mul_ex1_a_frac(0 to 52)                     ,--o--fbyp
        f_byp_fmt_ex1_a_frac(0 to 52)                    => f_byp_fmt_ex1_a_frac(0 to 52)                     ,--o--fbyp
        f_byp_mul_ex1_c_frac(0 to 52)                    => f_byp_mul_ex1_c_frac(0 to 52)                     ,--o--fbyp
        f_byp_mul_ex1_c_frac(53)                         => f_byp_mul_ex1_c_frac(53)                          ,--o--fbyp
        f_byp_fmt_ex1_c_frac(0 to 52)                    => f_byp_fmt_ex1_c_frac(0 to 52)                     ,--o--fbyp
        f_byp_alg_ex1_b_frac(0 to 52)                    => f_byp_alg_ex1_b_frac(0 to 52)                     ,--o--fbyp
        f_byp_fmt_ex1_b_frac(0 to 52)                    => f_byp_fmt_ex1_b_frac(0 to 52)                    );--o--fbyp
----------------------------------------------------------- -- fuq_byp.vhdl



ffmt : entity WORK.fuq_fmt(fuq_fmt)  generic map( expand_type => expand_type) port map( -- fuq_fmt.vhdl
------------------------------------------------------------- fuq_fmt.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        delay_lclkr                                      => delay_lclkr(1 to 2)              ,--i--
        mpw1_b                                           => mpw1_b(1 to 2)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 0)                   ,--i--
        thold_1                                          => perv_fmt_thold_1         ,--i--
        sg_1                                             => perv_fmt_sg_1            ,--i--
        fpu_enable                                       => perv_fmt_fpu_enable      ,--i--

        f_fmt_si                                         => scan_in(1)                                        ,--i--ffmt
        f_fmt_so                                         => scan_out(1)                                       ,--o--ffmt
        rf1_act                                          => f_dcd_rf1_act                                     ,--i--ffmt
        ex1_act                                          => f_pic_fmt_ex1_act                                 ,--i--ffmt

        f_fpr_ex1_a_par(0 to 7)                          => f_fpr_ex1_a_par(0 to 7)                           ,--i--ffmt
        f_fpr_ex1_c_par(0 to 7)                          => f_fpr_ex1_c_par(0 to 7)                           ,--i--ffmt
        f_fpr_ex1_b_par(0 to 7)                          => f_fpr_ex1_b_par(0 to 7)                           ,--i--ffmt

        f_mad_ex2_a_parity_check                         => f_mad_ex2_a_parity_check                          ,--o--ffmt
        f_mad_ex2_c_parity_check                         => f_mad_ex2_c_parity_check                          ,--o--ffmt
        f_mad_ex2_b_parity_check                         => f_mad_ex2_b_parity_check                          ,--o--ffmt
        f_fmt_ex2_ae_ge_54                               => f_fmt_ex2_ae_ge_54                                ,--o--ffmt
        f_fmt_ex2_be_ge_54                               => f_fmt_ex2_be_ge_54                                ,--o--ffmt
        f_fmt_ex2_be_ge_2                                => f_fmt_ex2_be_ge_2                                 ,--o--ffmt
        f_fmt_ex2_be_ge_2044                             => f_fmt_ex2_be_ge_2044                              ,--o--ffmt
        f_fmt_ex2_tdiv_rng_chk                           => f_fmt_ex2_tdiv_rng_chk                            ,--o--ffmt
        f_fmt_ex2_be_den                                 => f_fmt_ex2_be_den                                  ,--o--ffmt
        f_byp_fmt_ex1_a_sign                             => f_byp_fmt_ex1_a_sign                              ,--i--ffmt
        f_byp_fmt_ex1_c_sign                             => f_byp_fmt_ex1_c_sign                              ,--i--ffmt
        f_byp_fmt_ex1_b_sign                             => f_byp_fmt_ex1_b_sign                              ,--i--ffmt
        f_byp_fmt_ex1_a_expo(1 to 13)                    => f_byp_fmt_ex1_a_expo(1 to 13)                     ,--i--ffmt
        f_byp_fmt_ex1_c_expo(1 to 13)                    => f_byp_fmt_ex1_c_expo(1 to 13)                     ,--i--ffmt
        f_byp_fmt_ex1_b_expo(1 to 13)                    => f_byp_fmt_ex1_b_expo(1 to 13)                     ,--i--ffmt

        f_byp_fmt_ex1_a_frac(0 to 52)                    => f_byp_fmt_ex1_a_frac(0 to 52)                     ,--i--ffmt
        f_byp_fmt_ex1_c_frac(0 to 52)                    => f_byp_fmt_ex1_c_frac(0 to 52)                     ,--i--ffmt
        f_byp_fmt_ex1_b_frac(0 to 52)                    => f_byp_fmt_ex1_b_frac(0 to 52)                     ,--i--ffmt

        f_dcd_rf1_sp                                     => f_dcd_rf1_sp                                      ,--i--ffmt
        f_dcd_rf1_from_integer_b                         => f_dcd_rf1_from_integer_b                          ,--i--ffmt
        f_dcd_rf1_sgncpy_b                               => f_dcd_rf1_sgncpy_b                                ,--i--ffmt
        f_dcd_rf1_uc_mid                                 => f_dcd_rf1_uc_mid                                  ,--i--ffmt
        f_dcd_rf1_uc_end                                 => f_dcd_rf1_uc_end                                  ,--i--ffmt
        f_dcd_rf1_uc_special                             => f_dcd_rf1_uc_special                              ,--i--ffmt
        f_dcd_rf1_aop_valid                              => f_dcd_rf1_aop_valid                               ,--i--ffmt
        f_dcd_rf1_cop_valid                              => f_dcd_rf1_cop_valid                               ,--i--ffmt
        f_dcd_rf1_bop_valid                              => f_dcd_rf1_bop_valid                               ,--i--ffmt
        f_dcd_rf1_fsel_b                                 => f_dcd_rf1_fsel_b                                  ,--i--ffmt
        f_dcd_rf1_force_pass_b                           => f_dcd_rf1_force_pass_b                            ,--i--ffmt
        f_dcd_ex1_perr_force_c                           => f_dcd_ex1_perr_force_c                            ,
        f_dcd_ex1_perr_fsel_ovrd                         => f_dcd_ex1_perr_fsel_ovrd                          ,
        f_pic_ex1_ftdiv                                  => f_pic_ex1_ftdiv                                   ,--i--ffmt
        f_pic_ex1_flush_en_sp                            => f_pic_ex1_flush_en_sp                             ,--i--ffmt
        f_pic_ex1_flush_en_dp                            => f_pic_ex1_flush_en_dp                             ,--i--ffmt
        f_pic_ex1_nj_deni                                => f_pic_ex1_nj_deni                                 ,--i--ffmt (connect)
        f_fmt_ex2_lu_den_recip                           => f_fmt_ex2_lu_den_recip                            ,--o--ffmt
        f_fmt_ex2_lu_den_rsqrto                          => f_fmt_ex2_lu_den_rsqrto                           ,--o--ffmt
        f_fmt_ex1_bop_byt(45 to 52)                      => f_fmt_ex1_bop_byt(45 to 52)                       ,--o--ffmt
        f_fmt_ex1_b_frac(1 to 19)                        => f_fmt_ex1_b_frac(1 to 19)                         ,--o--ffmt
        f_fmt_ex1_bexpu_le126                            => f_fmt_ex1_bexpu_le126                             ,--o--ffmt
        f_fmt_ex1_gt126                                  => f_fmt_ex1_gt126                                   ,--o--ffmt
        f_fmt_ex1_ge128                                  => f_fmt_ex1_ge128                                   ,--o--ffmt
        f_fmt_ex1_inf_and_beyond_sp                      => f_fmt_ex1_inf_and_beyond_sp                       ,--o--ffmt

        f_fmt_ex1_b_sign_gst                             => f_fmt_ex1_b_sign_gst                              ,--o--ffmt
        f_fmt_ex1_b_expo_gst_b(1 to 13)                  => f_fmt_ex1_b_expo_gst_b(1 to 13)                   ,--o--ffmt
        f_mad_ex2_uc_a_expo_den                          => f_mad_ex2_uc_a_expo_den                           ,--o--ffmt
        f_mad_ex2_uc_a_expo_den_sp                       => f_mad_ex2_uc_a_expo_den_sp                        ,--o--ffmt
        f_fmt_ex1_a_zero                                 => f_fmt_ex1_a_zero                                  ,--o--ffmt
        f_fmt_ex1_a_expo_max                             => f_fmt_ex1_a_expo_max                              ,--o--ffmt
        f_fmt_ex1_a_frac_zero                            => f_fmt_ex1_a_frac_zero                             ,--o--ffmt
        f_fmt_ex1_a_frac_msb                             => f_fmt_ex1_a_frac_msb                              ,--o--ffmt
        f_fmt_ex1_c_zero                                 => f_fmt_ex1_c_zero                                  ,--o--ffmt
        f_fmt_ex1_c_expo_max                             => f_fmt_ex1_c_expo_max                              ,--o--ffmt
        f_fmt_ex1_c_frac_zero                            => f_fmt_ex1_c_frac_zero                             ,--o--ffmt
        f_fmt_ex1_c_frac_msb                             => f_fmt_ex1_c_frac_msb                              ,--o--ffmt
        f_fmt_ex1_b_zero                                 => f_fmt_ex1_b_zero                                  ,--o--ffmt
        f_fmt_ex1_b_expo_max                             => f_fmt_ex1_b_expo_max                              ,--o--ffmt
        f_fmt_ex1_b_frac_zero                            => f_fmt_ex1_b_frac_zero                             ,--o--ffmt
        f_fmt_ex1_b_frac_msb                             => f_fmt_ex1_b_frac_msb                              ,--o--ffmt
        f_fmt_ex1_b_frac_z32                             => f_fmt_ex1_b_frac_z32                              ,--o--ffmt
        f_fmt_ex1_prod_zero                              => f_fmt_ex1_prod_zero                               ,--o--ffmt
        f_fmt_ex1_pass_sel                               => f_fmt_ex1_pass_sel                                ,--o--ffmt
        f_fmt_ex1_sp_invalid                             => f_fmt_ex1_sp_invalid                              ,--o--ffmt
        f_ex2_b_den_flush                                => f_ex2_b_den_flush                                 ,--o--ffmt
        f_fmt_ex2_fsel_bsel                              => f_fmt_ex2_fsel_bsel                               ,--o--ffmt
        f_fmt_ex2_pass_sign                              => f_fmt_ex2_pass_sign                               ,--o--ffmt
        f_fmt_ex2_pass_msb                               => f_fmt_ex2_pass_msb                                ,--o--ffmt
        f_fmt_ex1_b_imp                                  => f_fmt_ex1_b_imp                                   ,--o--ffmt
        f_fmt_ex2_pass_frac(0 to 52)                     => f_fmt_ex2_pass_frac(0 to 52)                     );--o--ffmt
------------------------------------------------------------- fuq_fmt.vhdl





feie : entity WORK.fuq_eie(fuq_eie)  generic map( expand_type => expand_type) port map( -- fuq_eie.vhdl
------------------------------------------------------------- fuq_eie.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        delay_lclkr                                      => delay_lclkr(2 to 3)              ,--i--
        mpw1_b                                           => mpw1_b(2 to 3)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 0)                   ,--i--
        thold_1                                          => perv_eie_thold_1         ,--i--
        sg_1                                             => perv_eie_sg_1            ,--i--
        fpu_enable                                       => perv_eie_fpu_enable      ,--i--

        f_eie_si                                         => scan_in(2)                                        ,--i--feie
        f_eie_so                                         => scan_out(2)                                       ,--o--feie
        ex1_act                                          => f_pic_eie_ex1_act                                 ,--i--feie
        f_byp_eie_ex1_a_expo(1 to 13)                    => f_byp_eie_ex1_a_expo(1 to 13)                     ,--i--feie
        f_byp_eie_ex1_c_expo(1 to 13)                    => f_byp_eie_ex1_c_expo(1 to 13)                     ,--i--feie
        f_byp_eie_ex1_b_expo(1 to 13)                    => f_byp_eie_ex1_b_expo(1 to 13)                     ,--i--feie
        f_pic_ex1_from_integer                           => f_pic_ex1_from_integer                            ,--i--feie
        f_pic_ex1_fsel                                   => f_pic_ex1_fsel                                    ,--i--feie
        f_pic_ex2_frsp_ue1                               => f_pic_ex2_frsp_ue1                                ,--i--feie
        f_alg_ex2_sel_byp                                => f_alg_ex2_sel_byp                                 ,--i--feie
        f_fmt_ex2_fsel_bsel                              => f_fmt_ex2_fsel_bsel                               ,--i--feie
        f_pic_ex2_force_sel_bexp                         => f_pic_ex2_force_sel_bexp                          ,--i--feie
        f_pic_ex2_sp_b                                   => f_pic_ex2_sp_b                                    ,--i--feie
        f_pic_ex2_math_bzer_b                            => f_pic_ex2_math_bzer_b                             ,--i--feie
        f_eie_ex2_lt_bias                                => f_eie_ex2_lt_bias                                 ,--o--feie
        f_eie_ex2_eq_bias_m1                             => f_eie_ex2_eq_bias_m1                              ,--o--feie
        f_eie_ex2_wd_ov                                  => f_eie_ex2_wd_ov                                   ,--o--feie
        f_eie_ex2_dw_ov                                  => f_eie_ex2_dw_ov                                   ,--o--feie
        f_eie_ex2_wd_ov_if                               => f_eie_ex2_wd_ov_if                                ,--o--feie
        f_eie_ex2_dw_ov_if                               => f_eie_ex2_dw_ov_if                                ,--o--feie
        f_eie_ex2_lzo_expo(1 to 13)                      => f_eie_ex2_lzo_expo(1 to 13)                       ,--o--feie
        f_eie_ex2_b_expo(1 to 13)                        => f_eie_ex2_b_expo(1 to 13)                         ,--o--feie
        f_eie_ex2_use_bexp                               => f_eie_ex2_use_bexp                                ,--o--feie
        f_eie_ex2_tbl_expo(1 to 13)                      => f_eie_ex2_tbl_expo(1 to 13)                       ,--o--feie
        f_eie_ex3_iexp(1 to 13)                          => f_eie_ex3_iexp(1 to 13)                          );--o--feie
------------------------------------------------------------- fuq_eie.vhdl



feov : entity WORK.fuq_eov(fuq_eov)  generic map( expand_type => expand_type) port map( -- fuq_eov.vhdl
------------------------------------------------------------- fuq_eov.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(4 to 5)              ,--i--
        mpw1_b                                           => mpw1_b(4 to 5)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 1)                   ,--i--
        thold_1                                          => perv_eov_thold_1         ,--i--
        sg_1                                             => perv_eov_sg_1            ,--i--
        fpu_enable                                       => perv_eov_fpu_enable      ,--i--

        f_eov_si                                         => scan_in(3)                                        ,--i--feov
        f_eov_so                                         => scan_out(3)                                       ,--o--feov
        ex2_act_b                                        => f_pic_eov_ex2_act_b                               ,--i--feov
        f_tbl_ex4_unf_expo                               => f_tbl_ex4_unf_expo                                ,--i--feov
        f_tbe_ex3_may_ov                                 => f_tbe_ex3_may_ov                                  ,--i--feov
        f_tbe_ex3_expo(1 to 13)                          => f_tbe_ex3_res_expo(1 to 13)                       ,--i--feov
        f_pic_ex3_sel_est                                => f_pic_ex3_sel_est                                 ,--i--feov
        f_eie_ex3_iexp(1 to 13)                          => f_eie_ex3_iexp(1 to 13)                           ,--i--feov
        f_pic_ex3_sp_b                                   => f_pic_ex3_sp_b                                    ,--i--feov
        f_lza_ex4_sh_rgt_en_eov                          => f_lza_ex4_sh_rgt_en_eov                           ,--i--feov
        f_pic_ex4_oe                                     => f_pic_ex4_oe                                      ,--i--feov
        f_pic_ex4_ue                                     => f_pic_ex4_ue                                      ,--i--feov
        f_pic_ex4_ov_en                                  => f_pic_ex4_ov_en                                   ,--i--feov
        f_pic_ex4_uf_en                                  => f_pic_ex4_uf_en                                   ,--i--feov
        f_pic_ex4_spec_sel_k_e                           => f_pic_ex4_spec_sel_k_e                            ,--i--feov
        f_pic_ex4_spec_sel_k_f                           => f_pic_ex4_spec_sel_k_f                            ,--i--feov
        f_pic_ex4_sel_ov_spec                            => tidn                                              ,--i--feov  UNUSED DELETE

        f_pic_ex4_to_int_ov_all                          => f_pic_ex4_to_int_ov_all                           ,--i--feov

        f_lza_ex4_no_lza_edge                            => f_lza_ex4_no_lza_edge                             ,--i--feov
        f_lza_ex4_lza_amt_eov(0 to 7)                    => f_lza_ex4_lza_amt_eov(0 to 7)                     ,--i--feov
        f_nrm_ex4_extra_shift                            => f_nrm_ex4_extra_shift                             ,--i--feov
        f_eov_ex4_may_ovf                                => f_eov_ex4_may_ovf                                 ,--o--feov
        f_eov_ex5_sel_k_f                                => f_eov_ex5_sel_k_f                                 ,--o--feov
        f_eov_ex5_sel_k_e                                => f_eov_ex5_sel_k_e                                 ,--o--feov
        f_eov_ex5_sel_kif_f                              => f_eov_ex5_sel_kif_f                               ,--o--feov
        f_eov_ex5_sel_kif_e                              => f_eov_ex5_sel_kif_e                               ,--o--feov
        f_eov_ex5_unf_expo                               => f_eov_ex5_unf_expo                                ,--o--feov
        f_eov_ex5_ovf_expo                               => f_eov_ex5_ovf_expo                                ,--o--feov
        f_eov_ex5_ovf_if_expo                            => f_eov_ex5_ovf_if_expo                             ,--o--feov
        f_eov_ex5_expo_p0(1 to 13)                       => f_eov_ex5_expo_p0(1 to 13)                        ,--o--feov
        f_eov_ex5_expo_p1(1 to 13)                       => f_eov_ex5_expo_p1(1 to 13)                        ,--o--feov
        f_eov_ex5_expo_p0_ue1oe1(3 to 7)                 => f_eov_ex5_expo_p0_ue1oe1(3 to 7)                  ,--o--feov
        f_eov_ex5_expo_p1_ue1oe1(3 to 7)                 => f_eov_ex5_expo_p1_ue1oe1(3 to 7)                 );--o--feov
------------------------------------------------------------- fuq_eov.vhdl


fmul : entity WORK.fuq_mul(fuq_mul)  generic map( expand_type => expand_type) port map( -- fuq_mul.vhdl
------------------------------------------------------------- fuq_mul.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        delay_lclkr                                      => delay_lclkr(2)              ,--i--
        mpw1_b                                           => mpw1_b(2)                   ,--i--
        mpw2_b                                           => mpw2_b(0)                   ,--i--
        thold_1                                          => perv_mul_thold_1         ,--i--
        sg_1                                             => perv_mul_sg_1            ,--i--
        fpu_enable                                       => perv_mul_fpu_enable      ,--i--

        f_mul_si                                         => scan_in(4)                                        ,--i--fmul
        f_mul_so                                         => scan_out(4)                                       ,--o--fmul
        ex1_act                                          => f_pic_mul_ex1_act                                 ,--i--fmul
        f_fmt_ex1_a_frac(0 to 52)                        => f_byp_mul_ex1_a_frac(0 to 52)                     ,--i--fmul
        f_fmt_ex1_a_frac_17                              => f_byp_mul_ex1_a_frac_17                           ,--i--fmul
        f_fmt_ex1_a_frac_35                              => f_byp_mul_ex1_a_frac_35                           ,--i--fmul
        f_fmt_ex1_c_frac(0 to 53)                        => f_byp_mul_ex1_c_frac(0 to 53)                     ,--i--fmul
        f_mul_ex2_sum(1 to 108)                          => f_mul_ex2_sum(1 to 108)                           ,--o--fmul
        f_mul_ex2_car(1 to 108)                          => f_mul_ex2_car(1 to 108)                          );--o--fmul
------------------------------------------------------------- fuq_mul.vhdl


falg : entity WORK.fuq_alg(fuq_alg)  generic map( expand_type => expand_type) port map( -- fuq_alg.vhdl
------------------------------------------------------------- fuq_alg.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        delay_lclkr                                      => delay_lclkr(1 to 3)              ,--i--
        mpw1_b                                           => mpw1_b(1 to 3)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 0)                   ,--i--
        thold_1                                          => perv_alg_thold_1         ,--i--
        sg_1                                             => perv_alg_sg_1            ,--i--
        fpu_enable                                       => perv_alg_fpu_enable      ,--i--

        f_alg_si                                         => scan_in(5)                                        ,--i--falg
        f_alg_so                                         => scan_out(5)                                       ,--o--falg
        rf1_act                                          => f_dcd_rf1_act                                     ,--i--falg
        ex1_act                                          => f_pic_alg_ex1_act                                 ,--i--falg
        f_dcd_rf1_sp                                     => f_dcd_rf1_sp                                      ,--i--falg

        f_pic_ex1_frsp_ue1                               => f_pic_ex1_frsp_ue1                               ,--i--feie WRONG cycle (move to ex2)

        f_byp_alg_ex1_b_frac(0 to 52)                    => f_byp_alg_ex1_b_frac(0 to 52)                     ,--i--falg
        f_byp_alg_ex1_b_sign                             => f_byp_alg_ex1_b_sign                              ,--i--falg
        f_byp_alg_ex1_b_expo(1 to 13)                    => f_byp_alg_ex1_b_expo(1 to 13)                     ,--i--falg
        f_byp_alg_ex1_a_expo(1 to 13)                    => f_byp_alg_ex1_a_expo(1 to 13)                     ,--i--falg
        f_byp_alg_ex1_c_expo(1 to 13)                    => f_byp_alg_ex1_c_expo(1 to 13)                     ,--i--falg

        f_fmt_ex1_prod_zero                              => f_fmt_ex1_prod_zero                               ,--i--falg
        f_fmt_ex1_b_zero                                 => f_fmt_ex1_b_zero                                  ,--i--falg
        f_fmt_ex1_pass_sel                               => f_fmt_ex1_pass_sel                                ,--i--falg
        f_fmt_ex2_pass_frac(0 to 52)                     => f_fmt_ex2_pass_frac(0 to 52)                      ,--i--falg
        f_dcd_rf1_word_b                                 => f_dcd_rf1_word_b                                  ,--i--falg
        f_dcd_rf1_uns_b                                  => f_dcd_rf1_uns_b                                   ,--i--falg
        f_dcd_rf1_from_integer_b                         => f_dcd_rf1_from_integer_b                          ,--i--falg
        f_dcd_rf1_to_integer_b                           => f_dcd_rf1_to_integer_b                            ,--i--falg
        f_pic_ex1_rnd_to_int                             => f_pic_ex1_rnd_to_int                              ,--i--falg
        f_pic_ex1_effsub_raw                             => f_pic_ex1_effsub_raw                              ,--i--falg
        f_pic_ex1_sh_unf_ig_b                            => f_pic_ex1_sh_unf_ig_b                             ,--i--falg
        f_pic_ex1_sh_unf_do                              => f_pic_ex1_sh_unf_do                               ,--i--falg
        f_pic_ex1_sh_ovf_ig_b                            => f_pic_ex1_sh_ovf_ig_b                             ,--i--falg
        f_pic_ex1_sh_ovf_do                              => f_pic_ex1_sh_ovf_do                               ,--i--falg
        f_pic_ex2_rnd_nr                                 => f_pic_ex2_rnd_nr                                  ,--i--falg
        f_pic_ex2_rnd_inf_ok                             => f_pic_ex2_rnd_inf_ok                              ,--i--falg
        f_alg_ex1_sign_frmw                              => f_alg_ex1_sign_frmw                               ,--o--falg
        f_alg_ex2_res(0 to 162)                          => f_alg_ex2_res(0 to 162)                           ,--o--falg
        f_alg_ex2_sel_byp                                => f_alg_ex2_sel_byp                                 ,--o--falg
        f_alg_ex2_effsub_eac_b                           => f_alg_ex2_effsub_eac_b                            ,--o--falg
        f_alg_ex2_prod_z                                 => f_alg_ex2_prod_z                                  ,--o--falg
        f_alg_ex2_sh_unf                                 => f_alg_ex2_sh_unf                                  ,--o--falg
        f_alg_ex2_sh_ovf                                 => f_alg_ex2_sh_ovf                                  ,--o--falg
        f_alg_ex2_byp_nonflip                            => f_alg_ex2_byp_nonflip                             ,--o--falg
        f_alg_ex3_frc_sel_p1                             => f_alg_ex3_frc_sel_p1                              ,--o--falg
        f_alg_ex3_sticky                                 => f_alg_ex3_sticky                                  ,--o--falg
        f_alg_ex3_int_fr                                 => f_alg_ex3_int_fr                                  ,--o--falg
        f_alg_ex3_int_fi                                 => f_alg_ex3_int_fi                                 );--o--falg
------------------------------------------------------------- fuq_alg.vhdl



fsa3 : entity WORK.fuq_sa3(fuq_sa3)  generic map( expand_type => expand_type) port map( -- fuq_sa3.vhdl
------------------------------------------------------------- fuq_sa3.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(2 to 3)              ,--i--
        mpw1_b                                           => mpw1_b(2 to 3)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 0)                   ,--i--
        thold_1                                          => perv_sa3_thold_1         ,--i--
        sg_1                                             => perv_sa3_sg_1            ,--i--
        fpu_enable                                       => perv_sa3_fpu_enable      ,--i--

        f_sa3_si                                         => scan_in(6)                                        ,--i--fsa3
        f_sa3_so                                         => scan_out(6)                                       ,--o--fsa3
        ex1_act_b                                        => f_pic_add_ex1_act_b                               ,--i--fsa3
        f_mul_ex2_sum(54 to 161)                         => f_mul_ex2_sum(1 to 108)                           ,--i--fsa3
        f_mul_ex2_car(54 to 161)                         => f_mul_ex2_car(1 to 108)                           ,--i--fsa3
        f_alg_ex2_res(0  to 162)                         => f_alg_ex2_res(0  to 162)                          ,--i--fsa3
        f_sa3_ex3_s_lza(0  to 162)                       => f_sa3_ex3_s_lza(0  to 162)                            ,--o--fsa3
        f_sa3_ex3_c_lza(53 to 161)                       => f_sa3_ex3_c_lza(53 to 161)                            ,--o--fsa3
        f_sa3_ex3_s_add(0  to 162)                       => f_sa3_ex3_s_add(0  to 162)                            ,--o--fsa3
        f_sa3_ex3_c_add(53 to 161)                       => f_sa3_ex3_c_add(53 to 161)                           );--o--fsa3
------------------------------------------------------------- fuq_sa3.vhdl



fadd : entity WORK.fuq_add(fuq_add)  generic map( expand_type => expand_type) port map( -- fuq_add.vhdl
------------------------------------------------------------- fuq_add.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(3 to 4)              ,--i--
        mpw1_b                                           => mpw1_b(3 to 4)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 0)                   ,--i--
        thold_1                                          => perv_add_thold_1         ,--i--
        sg_1                                             => perv_add_sg_1            ,--i--
        fpu_enable                                       => perv_add_fpu_enable      ,--i--

        f_add_si                                         => scan_in(7)                                        ,--i--fadd
        f_add_so                                         => scan_out(7)                                       ,--o--fadd
        ex1_act_b                                        => f_pic_add_ex1_act_b                               ,--i--fadd
        f_sa3_ex3_s(0 to 162)                            => f_sa3_ex3_s_add(0 to 162)                         ,--i--fadd
        f_sa3_ex3_c(53 to 161)                           => f_sa3_ex3_c_add(53 to 161)                        ,--i--fadd
        f_alg_ex3_frc_sel_p1                             => f_alg_ex3_frc_sel_p1                              ,--i--fadd
        f_alg_ex3_sticky                                 => f_alg_ex3_sticky                                  ,--i--fadd
        f_alg_ex2_effsub_eac_b                           => f_alg_ex2_effsub_eac_b                            ,--i--fadd
        f_alg_ex2_prod_z                                 => f_alg_ex2_prod_z                                  ,--i--fadd
        f_pic_ex3_is_gt                                  => f_pic_ex3_is_gt                                   ,--i--fadd
        f_pic_ex3_is_lt                                  => f_pic_ex3_is_lt                                   ,--i--fadd
        f_pic_ex3_is_eq                                  => f_pic_ex3_is_eq                                   ,--i--fadd
        f_pic_ex3_is_nan                                 => f_pic_ex3_is_nan                                  ,--i--fadd
        f_pic_ex3_cmp_sgnpos                             => f_pic_ex3_cmp_sgnpos                              ,--i--fadd
        f_pic_ex3_cmp_sgnneg                             => f_pic_ex3_cmp_sgnneg                              ,--i--fadd
        f_add_ex4_res(0 to 162)                          => f_add_ex4_res(0 to 162)                           ,--o--fadd
        f_add_ex4_flag_nan                               => f_add_ex4_flag_nan                                ,--o--fadd
        f_add_ex4_flag_gt                                => f_add_ex4_flag_gt                                 ,--o--fadd
        f_add_ex4_flag_lt                                => f_add_ex4_flag_lt                                 ,--o--fadd
        f_add_ex4_flag_eq                                => f_add_ex4_flag_eq                                 ,--o--fadd
        f_add_ex4_fpcc_iu(0 to 3)                        => f_add_ex4_fpcc_iu(0 to 3)                         ,--o--fadd
        f_add_ex4_sign_carry                             => f_add_ex4_sign_carry                              ,--o--fadd
        f_add_ex4_to_int_ovf_wd(0 to 1)                  => f_add_ex4_to_int_ovf_wd(0 to 1)                   ,--o--fadd
        f_add_ex4_to_int_ovf_dw(0 to 1)                  => f_add_ex4_to_int_ovf_dw(0 to 1)                   ,--o--fadd
        f_add_ex4_sticky                                 => f_add_ex4_sticky                                 );--o--fadd
------------------------------------------------------------- fuq_add.vhdl



flze : entity WORK.fuq_lze(fuq_lze)  generic map( expand_type => expand_type) port map( -- fuq_lze.vhdl
------------------------------------------------------------- fuq_lze.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(2 to 3)              ,--i--
        mpw1_b                                           => mpw1_b(2 to 3)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 0)                   ,--i--
        thold_1                                          => perv_lza_thold_1         ,--i--
        sg_1                                             => perv_lza_sg_1            ,--i--
        fpu_enable                                       => perv_lza_fpu_enable      ,--i--

        f_lze_si                                         => scan_in(8)                                        ,--i--flze
        f_lze_so                                         => scan_out(8)                                       ,--o--flze
        ex1_act_b                                        => f_pic_lza_ex1_act_b                               ,--i--flze
        f_eie_ex2_lzo_expo(1 to 13)                      => f_eie_ex2_lzo_expo(1 to 13)                       ,--i--flze
        f_eie_ex2_b_expo(1 to 13)                        => f_eie_ex2_b_expo(1 to 13)                         ,--i--flze
        f_pic_ex2_est_recip                              => f_pic_ex2_est_recip                               ,--i--flze
        f_pic_ex2_est_rsqrt                              => f_pic_ex2_est_rsqrt                               ,--i--flze
        f_alg_ex2_byp_nonflip                            => f_alg_ex2_byp_nonflip                             ,--i--flze
        f_eie_ex2_use_bexp                               => f_eie_ex2_use_bexp                                ,--i--flze
        f_pic_ex2_b_valid                                => f_pic_ex2_b_valid                                 ,--i--flze
        f_pic_ex2_lzo_dis_prod                           => f_pic_ex2_lzo_dis_prod                            ,--i--flze
        f_pic_ex2_sp_lzo                                 => f_pic_ex2_sp_lzo                                  ,--i--flze
        f_pic_ex2_frsp_ue1                               => f_pic_ex2_frsp_ue1                                ,--i--flze
        f_fmt_ex2_pass_msb_dp                            => f_fmt_ex2_pass_frac(0)                            ,--i--flze
        f_alg_ex2_sel_byp                                => f_alg_ex2_sel_byp                                 ,--i--flze
        f_pic_ex2_to_integer                             => f_pic_ex2_to_integer                              ,--i--flze
        f_pic_ex2_prenorm                                => f_pic_ex2_prenorm                                 ,--i--flze


       f_lze_ex2_lzo_din(0 to 162)                       => f_lze_ex2_lzo_din(0 to 162)                       ,--o--flze
       f_lze_ex3_sh_rgt_amt(0 to 7)                      => f_lze_ex3_sh_rgt_amt(0 to 7)                      ,--o--flze
       f_lze_ex3_sh_rgt_en                               => f_lze_ex3_sh_rgt_en                              );--o--flze

------------------------------------------------------------- fuq_lze.vhdl


flza : entity WORK.fuq_lza(fuq_lza)  generic map( expand_type => expand_type) port map( -- fuq_lza.vhdl
------------------------------------------------------------- fuq_lza.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(3 to 4)              ,--i--
        mpw1_b                                           => mpw1_b(3 to 4)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 0)                   ,--i--
        thold_1                                          => perv_lza_thold_1         ,--i--
        sg_1                                             => perv_lza_sg_1            ,--i--
        fpu_enable                                       => perv_lza_fpu_enable      ,--i--

        f_lza_si                                         => scan_in(9)                                        ,--i--flza
        f_lza_so                                         => scan_out(9)                                       ,--o--flza
        ex1_act_b                                        => f_pic_lza_ex1_act_b                               ,--i--flza
        f_sa3_ex3_s(0 to 162)                            => f_sa3_ex3_s_lza(0 to 162)                         ,--i--flza
        f_sa3_ex3_c(53 to 161)                           => f_sa3_ex3_c_lza(53 to 161)                        ,--i--flza
        f_alg_ex2_effsub_eac_b                           => f_alg_ex2_effsub_eac_b                            ,--i--flza

        f_lze_ex2_lzo_din(0 to 162)                      => f_lze_ex2_lzo_din(0 to 162)                       ,--i--flza
        f_lze_ex3_sh_rgt_amt(0 to 7)                     => f_lze_ex3_sh_rgt_amt(0 to 7)                      ,--i--flza
        f_lze_ex3_sh_rgt_en                              => f_lze_ex3_sh_rgt_en                               ,--i--flza

        f_lza_ex4_no_lza_edge                            => f_lza_ex4_no_lza_edge                             ,--o--flza
        f_lza_ex4_lza_amt(0 to 7)                        => f_lza_ex4_lza_amt(0 to 7)                         ,--o--flza
        f_lza_ex4_sh_rgt_en                              => f_lza_ex4_sh_rgt_en                               ,--o--flza
        f_lza_ex4_sh_rgt_en_eov                          => f_lza_ex4_sh_rgt_en_eov                           ,--o--flza
        f_lza_ex4_lza_dcd64_cp1(0 to 2)                  => f_lza_ex4_lza_dcd64_cp1(0 to 2)                   ,--o--flza
        f_lza_ex4_lza_dcd64_cp2(0 to 1)                  => f_lza_ex4_lza_dcd64_cp2(0 to 1)                   ,--o--flza
        f_lza_ex4_lza_dcd64_cp3(0)                       => f_lza_ex4_lza_dcd64_cp3(0)                        ,--o--flza

        f_lza_ex4_lza_amt_eov(0 to 7)                    => f_lza_ex4_lza_amt_eov(0 to 7)                    );--o--flza
------------------------------------------------------------- fuq_lza.vhdl


fnrm : entity WORK.fuq_nrm(fuq_nrm)  generic map( expand_type => expand_type) port map( -- fuq_nrm.vhdl
------------------------------------------------------------- fuq_nrm.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(4 to 5)              ,--i--
        mpw1_b                                           => mpw1_b(4 to 5)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 1)                   ,--i--
        thold_1                                          => perv_nrm_thold_1         ,--i--
        sg_1                                             => perv_nrm_sg_1            ,--i--
        fpu_enable                                       => perv_nrm_fpu_enable      ,--i--

        f_nrm_si                                         => scan_in(10)                                       ,--i--fnrm
        f_nrm_so                                         => scan_out(10)                                      ,--o--fnrm
        ex3_act_b                                        => f_pic_nrm_ex3_act_b                               ,--i--fnrm

        f_lza_ex4_sh_rgt_en                              => f_lza_ex4_sh_rgt_en                               ,--i--fnrm
        f_lza_ex4_lza_amt_cp1                            => f_lza_ex4_lza_amt(0 to 7)                         ,--i--fnrm
        f_lza_ex4_lza_dcd64_cp1(0 to 2)                  => f_lza_ex4_lza_dcd64_cp1(0 to 2)                   ,--o--fnrm
        f_lza_ex4_lza_dcd64_cp2(0 to 1)                  => f_lza_ex4_lza_dcd64_cp2(0 to 1)                   ,--o--fnrm
        f_lza_ex4_lza_dcd64_cp3(0)                       => f_lza_ex4_lza_dcd64_cp3(0)                        ,--o--fnrm

        f_add_ex4_res(0 to 162)                          => f_add_ex4_res(0 to 162)                           ,--i--fnrm
        f_add_ex4_sticky                                 => f_add_ex4_sticky                                  ,--i--fnrm
        f_pic_ex4_byp_prod_nz                            => f_pic_ex4_byp_prod_nz                             ,--i--fnrm
        f_nrm_ex5_res(0 to 52)                           => f_nrm_ex5_res(0 to 52)                            ,--o--fnrm
        f_nrm_ex5_int_lsbs(1 to 12)                      => f_nrm_ex5_int_lsbs(1 to 12)                       ,--o--fnrm
        f_nrm_ex5_int_sign                               => f_nrm_ex5_int_sign                                ,--o--fnrm
        f_nrm_ex5_nrm_sticky_dp                          => f_nrm_ex5_nrm_sticky_dp                           ,--o--fnrm
        f_nrm_ex5_nrm_guard_dp                           => f_nrm_ex5_nrm_guard_dp                            ,--o--fnrm
        f_nrm_ex5_nrm_lsb_dp                             => f_nrm_ex5_nrm_lsb_dp                              ,--o--fnrm
        f_nrm_ex5_nrm_sticky_sp                          => f_nrm_ex5_nrm_sticky_sp                           ,--o--fnrm
        f_nrm_ex5_nrm_guard_sp                           => f_nrm_ex5_nrm_guard_sp                            ,--o--fnrm
        f_nrm_ex5_nrm_lsb_sp                             => f_nrm_ex5_nrm_lsb_sp                              ,--o--fnrm
        f_nrm_ex5_exact_zero                             => f_nrm_ex5_exact_zero                              ,--o--fnrm
        f_nrm_ex4_extra_shift                            => f_nrm_ex4_extra_shift                             ,--o--fnrm
        f_nrm_ex5_fpscr_wr_dat_dfp(0 to 3)               => f_nrm_ex5_fpscr_wr_dat_dfp(0 to 3)                ,--o--fnrm
        f_nrm_ex5_fpscr_wr_dat(0 to 31)                  => f_nrm_ex5_fpscr_wr_dat(0 to 31)                  );--o--fnrm
------------------------------------------------------------- fuq_nrm.vhdl



frnd : entity WORK.fuq_rnd(fuq_rnd)  generic map( expand_type => expand_type) port map( -- fuq_rnd.vhdl
------------------------------------------------------------- fuq_rnd.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(5 to 6)              ,--i--
        mpw1_b                                           => mpw1_b(5 to 6)                   ,--i--
        mpw2_b                                           => mpw2_b(1 to 1)                   ,--i--
        thold_1                                          => perv_rnd_thold_1         ,--i--
        sg_1                                             => perv_rnd_sg_1            ,--i--
        fpu_enable                                       => perv_rnd_fpu_enable      ,--i--

        f_rnd_si                                         => scan_in(11)                                       ,--i--frnd
        f_rnd_so                                         => scan_out(11)                                      ,--o--frnd
        ex3_act_b                                        => f_pic_rnd_ex3_act_b                               ,--i--frnd
        f_pic_ex4_sel_est_b                              => f_pic_ex4_sel_est_b                               ,--i--frnd
        f_tbl_ex5_est_frac(0 to 26)                      => f_tbl_ex5_est_frac(0 to 26)                       ,--i--frnd
        f_nrm_ex5_res(0 to 52)                           => f_nrm_ex5_res(0 to 52)                            ,--i--frnd
        f_nrm_ex5_int_lsbs(1 to 12)                      => f_nrm_ex5_int_lsbs(1 to 12)                       ,--i--frnd
        f_nrm_ex5_int_sign                               => f_nrm_ex5_int_sign                                ,--i--frnd
        f_nrm_ex5_nrm_sticky_dp                          => f_nrm_ex5_nrm_sticky_dp                           ,--i--frnd
        f_nrm_ex5_nrm_guard_dp                           => f_nrm_ex5_nrm_guard_dp                            ,--i--frnd
        f_nrm_ex5_nrm_lsb_dp                             => f_nrm_ex5_nrm_lsb_dp                              ,--i--frnd
        f_nrm_ex5_nrm_sticky_sp                          => f_nrm_ex5_nrm_sticky_sp                           ,--i--frnd
        f_nrm_ex5_nrm_guard_sp                           => f_nrm_ex5_nrm_guard_sp                            ,--i--frnd
        f_nrm_ex5_nrm_lsb_sp                             => f_nrm_ex5_nrm_lsb_sp                              ,--i--frnd
        f_nrm_ex5_exact_zero                             => f_nrm_ex5_exact_zero                              ,--i--frnd
        f_pic_ex5_invert_sign                            => f_pic_ex5_invert_sign                             ,--i--frnd
        f_pic_ex5_en_exact_zero                          => f_pic_ex5_en_exact_zero                           ,--i--frnd
        f_pic_ex5_k_nan                                  => f_pic_ex5_k_nan                                   ,--i--frnd
        f_pic_ex5_k_inf                                  => f_pic_ex5_k_inf                                   ,--i--frnd
        f_pic_ex5_k_max                                  => f_pic_ex5_k_max                                   ,--i--frnd
        f_pic_ex5_k_zer                                  => f_pic_ex5_k_zer                                   ,--i--frnd
        f_pic_ex5_k_one                                  => f_pic_ex5_k_one                                   ,--i--frnd
        f_pic_ex5_k_int_maxpos                           => f_pic_ex5_k_int_maxpos                            ,--i--frnd
        f_pic_ex5_k_int_maxneg                           => f_pic_ex5_k_int_maxneg                            ,--i--frnd
        f_pic_ex5_k_int_zer                              => f_pic_ex5_k_int_zer                               ,--i--frnd
        f_tbl_ex5_recip_den                              => f_tbl_ex5_recip_den                               ,--i--frnd
        f_pic_ex4_rnd_ni_b                               => f_pic_ex4_rnd_ni_b                                ,--i--frnd
        f_pic_ex4_rnd_nr_b                               => f_pic_ex4_rnd_nr_b                                ,--i--frnd
        f_pic_ex4_rnd_inf_ok_b                           => f_pic_ex4_rnd_inf_ok_b                            ,--i--frnd
        f_pic_ex5_uc_inc_lsb                             => f_pic_ex5_uc_inc_lsb                              ,--i--frnd
        f_pic_ex5_uc_guard                               => f_pic_ex5_uc_guard                                ,--i--frnd
        f_pic_ex5_uc_sticky                              => f_pic_ex5_uc_sticky                               ,--i--frnd
        f_pic_ex5_uc_g_v                                 => f_pic_ex5_uc_g_v                                  ,--i--frnd
        f_pic_ex5_uc_s_v                                 => f_pic_ex5_uc_s_v                                  ,--i--frnd
        f_pic_ex4_sel_fpscr_b                            => f_pic_ex4_sel_fpscr_b                             ,--i--frnd
        f_pic_ex4_to_integer_b                           => f_pic_ex4_to_integer_b                            ,--i--frnd
        f_pic_ex4_word_b                                 => f_pic_ex4_word_b                                  ,--i--frnd
        f_pic_ex4_uns_b                                  => f_pic_ex4_uns_b                                   ,--i--frnd
        f_pic_ex4_sp_b                                   => f_pic_ex4_sp_b                                    ,--i--frnd
        f_pic_ex4_spec_inf_b                             => f_pic_ex4_spec_inf_b                              ,--i--frnd
        f_pic_ex4_quiet_b                                => f_pic_ex4_quiet_b                                 ,--i--frnd
        f_pic_ex4_nj_deno                                => f_pic_ex4_nj_deno                                 ,--i--frnd
        f_pic_ex4_unf_en_ue0_b                           => f_pic_ex4_unf_en_ue0_b                            ,--i--frnd
        f_pic_ex4_unf_en_ue1_b                           => f_pic_ex4_unf_en_ue1_b                            ,--i--frnd
        f_pic_ex4_ovf_en_oe0_b                           => f_pic_ex4_ovf_en_oe0_b                            ,--i--frnd
        f_pic_ex4_ovf_en_oe1_b                           => f_pic_ex4_ovf_en_oe1_b                            ,--i--frnd
        f_pic_ex5_round_sign                             => f_pic_ex5_round_sign                              ,--i--frnd
        f_scr_ex5_fpscr_rd_dat_dfp(0 to 3)               => f_scr_ex5_fpscr_rd_dat_dfp(0 to 3)                ,--i--frnd
        f_scr_ex5_fpscr_rd_dat(0 to 31)                  => f_scr_ex5_fpscr_rd_dat(0 to 31)                   ,--i--frnd
        f_eov_ex5_sel_k_f                                => f_eov_ex5_sel_k_f                                 ,--i--frnd
        f_eov_ex5_sel_k_e                                => f_eov_ex5_sel_k_e                                 ,--i--frnd
        f_eov_ex5_sel_kif_f                              => f_eov_ex5_sel_kif_f                               ,--i--frnd
        f_eov_ex5_sel_kif_e                              => f_eov_ex5_sel_kif_e                               ,--i--frnd
        f_eov_ex5_ovf_expo                               => f_eov_ex5_ovf_expo                                ,--i--frnd
        f_eov_ex5_ovf_if_expo                            => f_eov_ex5_ovf_if_expo                             ,--i--frnd
        f_eov_ex5_unf_expo                               => f_eov_ex5_unf_expo                                ,--i--frnd
        f_pic_ex5_frsp                                   => f_pic_ex5_frsp                                    ,--i--frnd
        f_eov_ex5_expo_p0(1 to 13)                       => f_eov_ex5_expo_p0(1 to 13)                        ,--i--frnd
        f_eov_ex5_expo_p1(1 to 13)                       => f_eov_ex5_expo_p1(1 to 13)                        ,--i--frnd
        f_eov_ex5_expo_p0_ue1oe1(3 to 7)                 => f_eov_ex5_expo_p0_ue1oe1(3 to 7)                  ,--i--frnd
        f_eov_ex5_expo_p1_ue1oe1(3 to 7)                 => f_eov_ex5_expo_p1_ue1oe1(3 to 7)                  ,--i--frnd
        f_gst_ex5_logexp_v                               => f_gst_ex5_logexp_v                                ,--i--frnd
        f_gst_ex5_logexp_sign                            => f_gst_ex5_logexp_sign                             ,--i--frnd
        f_gst_ex5_logexp_exp(1 to 11)                    => f_gst_ex5_logexp_exp(1 to 11)                     ,--i--frnd
        f_gst_ex5_logexp_fract(0 to 19)                  => f_gst_ex5_logexp_fract(0 to 19)                   ,--i--frnd
        f_mad_ex6_uc_sign                                => f_mad_ex6_uc_sign                                 ,--o--frnd
        f_mad_ex6_uc_zero                                => f_mad_ex6_uc_zero                                 ,--o--frnd
        f_rnd_ex6_res_sign                               =>   rnd_ex6_res_sign                                ,--o--frnd
        f_rnd_ex6_res_expo(1 to 13)                      =>   rnd_ex6_res_expo(1 to 13)                       ,--o--frnd
        f_rnd_ex6_res_frac(0 to 52)                      =>   rnd_ex6_res_frac(0 to 52)                       ,--o--frnd
        f_rnd_ex6_flag_up                                => f_rnd_ex6_flag_up                                 ,--o--frnd
        f_rnd_ex6_flag_fi                                => f_rnd_ex6_flag_fi                                 ,--o--frnd
        f_rnd_ex6_flag_ox                                => f_rnd_ex6_flag_ox                                 ,--o--frnd
        f_rnd_ex6_flag_den                               => f_rnd_ex6_flag_den                                ,--o--frnd
        f_rnd_ex6_flag_sgn                               => f_rnd_ex6_flag_sgn                                ,--o--frnd
        f_rnd_ex6_flag_inf                               => f_rnd_ex6_flag_inf                                ,--o--frnd
        f_rnd_ex6_flag_zer                               => f_rnd_ex6_flag_zer                                ,--o--frnd
        f_rnd_ex6_flag_ux                                => f_rnd_ex6_flag_ux                                );--o--frnd
------------------------------------------------------------- fuq_rnd.vhdl
        


        f_rnd_ex6_res_sign                               <=   rnd_ex6_res_sign                                ;
        f_rnd_ex6_res_expo(1 to 13)                      <=   rnd_ex6_res_expo(1 to 13)                       ;
        f_rnd_ex6_res_frac(0 to 52)                      <=   rnd_ex6_res_frac(0 to 52)                       ;


fgst : entity WORK.fuq_gst(fuq_gst)  generic map( expand_type => expand_type) port map( -- fuq_gst.vhdl
------------------------------------------------------------- fuq_gst.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(2 to 5)              ,--i--
        mpw1_b                                           => mpw1_b(2 to 5)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 1)                   ,--i--
        thold_1                                          => perv_rnd_thold_1         ,--i--
        sg_1                                             => perv_rnd_sg_1            ,--i--
        fpu_enable                                       => perv_rnd_fpu_enable      ,--i--

        f_gst_si                                         => scan_in(12)                                       ,--i--fgst
        f_gst_so                                         => scan_out(12)                                      ,--o--fgst
        rf1_act                                          => f_dcd_rf1_act                                     ,--i--fgst  (connect)
        f_fmt_ex1_b_sign_gst                             => f_fmt_ex1_b_sign_gst                              ,--i--fgst
        f_fmt_ex1_b_expo_gst_b(1 to 13)                  => f_fmt_ex1_b_expo_gst_b(1 to 13)                   ,--i--fgst
        f_fmt_ex1_b_frac_gst(1 to 19)                    => f_fmt_ex1_b_frac(1 to 19)                         ,--i--fgst
        f_pic_ex1_floges                                 => f_pic_ex1_log2e                                   ,--i--fgst
        f_pic_ex1_fexptes                                => f_pic_ex1_pow2e                                   ,--i--fgst
        f_gst_ex5_logexp_v                               => f_gst_ex5_logexp_v                                ,--o--fgst
        f_gst_ex5_logexp_sign                            => f_gst_ex5_logexp_sign                             ,--o--fgst
        f_gst_ex5_logexp_exp(1 to 11)                    => f_gst_ex5_logexp_exp(1 to 11)                     ,--o--fgst
        f_gst_ex5_logexp_fract(0 to 19)                  => f_gst_ex5_logexp_fract(0 to 19)                  );--o--fgst
------------------------------------------------------------- fuq_gst.vhdl




fpic : entity WORK.fuq_pic(fuq_pic)  generic map( expand_type => expand_type) port map( -- fuq_pic.vhdl
------------------------------------------------------------- fuq_pic.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        delay_lclkr                                      => delay_lclkr(1 to 5)              ,--i--
        mpw1_b                                           => mpw1_b(1 to 5)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 1)                   ,--i--
        thold_1                                          => perv_pic_thold_1         ,--i--
        sg_1                                             => perv_pic_sg_1            ,--i--
        fpu_enable                                       => perv_pic_fpu_enable      ,--i--

        f_pic_si                                         => scan_in(13)                                       ,--i--fpic
        f_pic_so                                         => scan_out(13)                                      ,--o--fpic
        f_dcd_rf1_act                                    => f_dcd_rf1_act                                     ,--i--fpic
        f_cr2_ex1_fpscr_shadow(0 to 7)                   => f_cr2_ex1_fpscr_shadow(0 to 7)                    ,--i--fpic
        f_dcd_rf1_pow2e_b                                => f_dcd_rf1_pow2e_b                                 ,--i--fpic
        f_dcd_rf1_log2e_b                                => f_dcd_rf1_log2e_b                                 ,--i--fpic
        f_byp_pic_ex1_a_sign                             => f_byp_pic_ex1_a_sign                              ,--i--fpic
        f_byp_pic_ex1_c_sign                             => f_byp_pic_ex1_c_sign                              ,--i--fpic
        f_byp_pic_ex1_b_sign                             => f_byp_pic_ex1_b_sign                              ,--i--fpic
        f_dcd_rf1_aop_valid                              => f_dcd_rf1_aop_valid                               ,--i--fpic
        f_dcd_rf1_cop_valid                              => f_dcd_rf1_cop_valid                               ,--i--fpic
        f_dcd_rf1_bop_valid                              => f_dcd_rf1_bop_valid                               ,--i--fpic
        f_dcd_rf1_uc_ft_neg                              => f_dcd_rf1_uc_ft_neg                               ,--i--fpic
        f_dcd_rf1_uc_ft_pos                              => f_dcd_rf1_uc_ft_pos                               ,--i--fpic
        f_dcd_rf1_fsel_b                                 => f_dcd_rf1_fsel_b                                  ,--i--fpic
        f_dcd_rf1_from_integer_b                         => f_dcd_rf1_from_integer_b                          ,--i--fpic
        f_dcd_rf1_to_integer_b                           => f_dcd_rf1_to_integer_b                            ,--i--fpic
        f_dcd_rf1_rnd_to_int_b                           => f_dcd_rf1_rnd_to_int_b                            ,--i--fpic
        f_dcd_rf1_math_b                                 => f_dcd_rf1_math_b                                  ,--i--fpic
        f_dcd_rf1_est_recip_b                            => f_dcd_rf1_est_recip_b                             ,--i--fpic
        f_dcd_rf1_ftdiv                                  => f_dcd_rf1_ftdiv                                   ,--i--fpic
        f_dcd_rf1_ftsqrt                                 => f_dcd_rf1_ftsqrt                                  ,--i--fpic
        f_fmt_ex2_ae_ge_54                               => f_fmt_ex2_ae_ge_54                                ,--i--fpic
        f_fmt_ex2_be_ge_54                               => f_fmt_ex2_be_ge_54                                ,--i--fpic
        f_fmt_ex2_be_ge_2                                => f_fmt_ex2_be_ge_2                                 ,--i--fpic
        f_fmt_ex2_be_ge_2044                             => f_fmt_ex2_be_ge_2044                              ,--i--fpic
        f_fmt_ex2_tdiv_rng_chk                           => f_fmt_ex2_tdiv_rng_chk                            ,--i--fpic
        f_fmt_ex2_be_den                                 => f_fmt_ex2_be_den                                  ,--i--fpic

        f_dcd_rf1_est_rsqrt_b                            => f_dcd_rf1_est_rsqrt_b                             ,--i--fpic
        f_dcd_rf1_move_b                                 => f_dcd_rf1_move_b                                  ,--i--fpic
        f_dcd_rf1_prenorm_b                              => f_dcd_rf1_prenorm_b                               ,--i--fpic
        f_dcd_rf1_frsp_b                                 => f_dcd_rf1_frsp_b                                  ,--i--fpic
        f_dcd_rf1_sp                                     => f_dcd_rf1_sp                                      ,--i--fpic
        f_dcd_rf1_sp_conv_b                              => f_dcd_rf1_sp_conv_b                               ,--i--fpic
        f_dcd_rf1_word_b                                 => f_dcd_rf1_word_b                                  ,--i--fpic
        f_dcd_rf1_uns_b                                  => f_dcd_rf1_uns_b                                   ,--i--fpic
        f_dcd_rf1_sub_op_b                               => f_dcd_rf1_sub_op_b                                ,--i--fpic
        f_dcd_rf1_op_rnd_v_b                             => f_dcd_rf1_op_rnd_v_b                              ,--i--fpic
        f_dcd_rf1_op_rnd_b(0 to 1)                       => f_dcd_rf1_op_rnd_b(0 to 1)                        ,--i--fpic
        f_dcd_rf1_inv_sign_b                             => f_dcd_rf1_inv_sign_b                              ,--i--fpic
        f_dcd_rf1_sign_ctl_b(0 to 1)                     => f_dcd_rf1_sign_ctl_b(0 to 1)                      ,--i--fpic
        f_dcd_rf1_sgncpy_b                               => f_dcd_rf1_sgncpy_b                                ,--i--fpic
        f_dcd_rf1_nj_deno                                => f_dcd_rf1_nj_deno                                 ,--i--fpic
        f_dcd_rf1_mv_to_scr_b                            => f_dcd_rf1_mv_to_scr_b                             ,--i--fpic
        f_dcd_rf1_mv_from_scr_b                          => f_dcd_rf1_mv_from_scr_b                           ,--i--fpic
        f_dcd_rf1_compare_b                              => f_dcd_rf1_compare_b                               ,--i--fpic
        f_dcd_rf1_ordered_b                              => f_dcd_rf1_ordered_b                               ,--i--fpic
        f_alg_ex1_sign_frmw                              => f_alg_ex1_sign_frmw                               ,--i--fpic
        f_dcd_rf1_force_excp_dis                         => f_dcd_rf1_force_excp_dis                          ,--i--fpic
        f_pic_ex1_log2e                                  => f_pic_ex1_log2e                                   ,--i--fpic
        f_pic_ex1_pow2e                                  => f_pic_ex1_pow2e                                   ,--i--fpic
        f_fmt_ex1_bexpu_le126                            => f_fmt_ex1_bexpu_le126                             ,--i--fpic
        f_fmt_ex1_gt126                                  => f_fmt_ex1_gt126                                   ,--i--fpic
        f_fmt_ex1_ge128                                  => f_fmt_ex1_ge128                                   ,--i--fpic
        f_fmt_ex1_inf_and_beyond_sp                      => f_fmt_ex1_inf_and_beyond_sp                       ,--i--fpic
        f_fmt_ex1_sp_invalid                             => f_fmt_ex1_sp_invalid                              ,--i--fpic
        f_fmt_ex1_a_zero                                 => f_fmt_ex1_a_zero                                  ,--i--fpic
        f_fmt_ex1_a_expo_max                             => f_fmt_ex1_a_expo_max                              ,--i--fpic
        f_fmt_ex1_a_frac_zero                            => f_fmt_ex1_a_frac_zero                             ,--i--fpic
        f_fmt_ex1_a_frac_msb                             => f_fmt_ex1_a_frac_msb                              ,--i--fpic
        f_fmt_ex1_c_zero                                 => f_fmt_ex1_c_zero                                  ,--i--fpic
        f_fmt_ex1_c_expo_max                             => f_fmt_ex1_c_expo_max                              ,--i--fpic
        f_fmt_ex1_c_frac_zero                            => f_fmt_ex1_c_frac_zero                             ,--i--fpic
        f_fmt_ex1_c_frac_msb                             => f_fmt_ex1_c_frac_msb                              ,--i--fpic
        f_fmt_ex1_b_zero                                 => f_fmt_ex1_b_zero                                  ,--i--fpic
        f_fmt_ex1_b_expo_max                             => f_fmt_ex1_b_expo_max                              ,--i--fpic
        f_fmt_ex1_b_frac_zero                            => f_fmt_ex1_b_frac_zero                             ,--i--fpic
        f_fmt_ex1_b_frac_msb                             => f_fmt_ex1_b_frac_msb                              ,--i--fpic
        f_fmt_ex1_prod_zero                              => f_fmt_ex1_prod_zero                               ,--i--fpic
        f_fmt_ex2_pass_sign                              => f_fmt_ex2_pass_sign                               ,--i--fpic
        f_fmt_ex2_pass_msb                               => f_fmt_ex2_pass_msb                                ,--i--fpic
        f_fmt_ex1_b_frac_z32                             => f_fmt_ex1_b_frac_z32                              ,--i--fpic
        f_fmt_ex1_b_imp                                  => f_fmt_ex1_b_imp                                   ,--i--fpic
        f_eie_ex2_wd_ov                                  => f_eie_ex2_wd_ov                                   ,--i--fpic
        f_eie_ex2_dw_ov                                  => f_eie_ex2_dw_ov                                   ,--i--fpic
        f_eie_ex2_wd_ov_if                               => f_eie_ex2_wd_ov_if                                ,--i--fpic
        f_eie_ex2_dw_ov_if                               => f_eie_ex2_dw_ov_if                                ,--i--fpic
        f_eie_ex2_lt_bias                                => f_eie_ex2_lt_bias                                 ,--i--fpic
        f_eie_ex2_eq_bias_m1                             => f_eie_ex2_eq_bias_m1                              ,--i--fpic
        f_alg_ex2_sel_byp                                => f_alg_ex2_sel_byp                                 ,--i--fpic
        f_alg_ex2_effsub_eac_b                           => f_alg_ex2_effsub_eac_b                            ,--i--fpic
        f_alg_ex2_sh_unf                                 => f_alg_ex2_sh_unf                                  ,--i--fpic
        f_alg_ex2_sh_ovf                                 => f_alg_ex2_sh_ovf                                  ,--i--fpic
        f_alg_ex3_int_fr                                 => f_alg_ex3_int_fr                                  ,--i--fpic
        f_alg_ex3_int_fi                                 => f_alg_ex3_int_fi                                  ,--i--fpic
        f_eov_ex4_may_ovf                                => f_eov_ex4_may_ovf                                 ,--i--fpic
        f_add_ex4_fpcc_iu(0)                             => f_add_ex4_flag_lt                                 ,--o--fadd
        f_add_ex4_fpcc_iu(1)                             => f_add_ex4_flag_gt                                 ,--o--fadd
        f_add_ex4_fpcc_iu(2)                             => f_add_ex4_flag_eq                                 ,--o--fadd
        f_add_ex4_fpcc_iu(3)                             => f_add_ex4_flag_nan                                ,--o--fadd
        f_add_ex4_sign_carry                             => f_add_ex4_sign_carry                              ,--i--fpic
        f_dcd_rf1_div_beg                                => f_dcd_rf1_div_beg                                 ,--i--fpic
        f_dcd_rf1_sqrt_beg                               => f_dcd_rf1_sqrt_beg                                ,--i--fpic
        f_pic_ex5_fpr_wr_dis_b                           => f_pic_ex5_fpr_wr_dis_b                            ,--o--fpic
        f_add_ex4_to_int_ovf_wd(0 to 1)                  => f_add_ex4_to_int_ovf_wd(0 to 1)                   ,--i--fpic
        f_add_ex4_to_int_ovf_dw(0 to 1)                  => f_add_ex4_to_int_ovf_dw(0 to 1)                   ,--i--fpic
        f_pic_ex1_ftdiv                                  => f_pic_ex1_ftdiv                                   ,--o--fpic
        f_pic_ex1_flush_en_sp                            => f_pic_ex1_flush_en_sp                             ,--o--fpic
        f_pic_ex1_flush_en_dp                            => f_pic_ex1_flush_en_dp                             ,--o--fpic
        f_pic_ex1_rnd_to_int                             => f_pic_ex1_rnd_to_int                              ,--o--fpic

        f_pic_fmt_ex1_act                                => f_pic_fmt_ex1_act                                 ,--o--fpic
        f_pic_eie_ex1_act                                => f_pic_eie_ex1_act                                 ,--o--fpic
        f_pic_mul_ex1_act                                => f_pic_mul_ex1_act                                 ,--o--fpic
        f_pic_alg_ex1_act                                => f_pic_alg_ex1_act                                 ,--o--fpic
        f_pic_cr2_ex1_act                                => f_pic_cr2_ex1_act                                 ,--o--fpic
        f_pic_tbl_ex1_act                                => f_pic_tbl_ex1_act                                 ,--o--fpic

        f_pic_add_ex1_act_b                              => f_pic_add_ex1_act_b                               ,--o--fpic
        f_pic_lza_ex1_act_b                              => f_pic_lza_ex1_act_b                               ,--o--fpic
        f_pic_eov_ex2_act_b                              => f_pic_eov_ex2_act_b                               ,--o--fpic
        f_pic_nrm_ex3_act_b                              => f_pic_nrm_ex3_act_b                               ,--o--fpic
        f_pic_rnd_ex3_act_b                              => f_pic_rnd_ex3_act_b                               ,--o--fpic
        f_pic_scr_ex2_act_b                              => f_pic_scr_ex2_act_b                               ,--o--fpic
        f_pic_ex1_effsub_raw                             => f_pic_ex1_effsub_raw                              ,--o--fpic
        f_pic_ex3_sel_est                                => f_pic_ex3_sel_est                                 ,--o--fpic
        f_pic_ex1_from_integer                           => f_pic_ex1_from_integer                            ,--o--fpic
        f_pic_ex2_ue1                                    => f_pic_ex2_ue1                                     ,--o--fpic
        f_pic_ex2_frsp_ue1                               => f_pic_ex2_frsp_ue1                                ,--o--fpic
        f_pic_ex1_frsp_ue1                               => f_pic_ex1_frsp_ue1                                ,--o--fpic --wrong cycle (temporary)
        f_pic_ex1_fsel                                   => f_pic_ex1_fsel                                    ,--o--fpic
        f_pic_ex1_sh_ovf_do                              => f_pic_ex1_sh_ovf_do                               ,--o--fpic
        f_pic_ex1_sh_ovf_ig_b                            => f_pic_ex1_sh_ovf_ig_b                             ,--o--fpic
        f_pic_ex1_sh_unf_do                              => f_pic_ex1_sh_unf_do                               ,--o--fpic
        f_pic_ex1_sh_unf_ig_b                            => f_pic_ex1_sh_unf_ig_b                             ,--o--fpic
        f_pic_ex2_est_recip                              => f_pic_ex2_est_recip                               ,--o--fpic
        f_pic_ex2_est_rsqrt                              => f_pic_ex2_est_rsqrt                               ,--o--fpic
        f_pic_ex2_force_sel_bexp                         => f_pic_ex2_force_sel_bexp                          ,--o--fpic
        f_pic_ex2_lzo_dis_prod                           => f_pic_ex2_lzo_dis_prod                            ,--o--fpic
        f_pic_ex2_sp_b                                   => f_pic_ex2_sp_b                                    ,--o--fpic
        f_pic_ex2_sp_lzo                                 => f_pic_ex2_sp_lzo                                  ,--o--fpic
        f_pic_ex2_to_integer                             => f_pic_ex2_to_integer                              ,--o--fpic
        f_pic_ex2_prenorm                                => f_pic_ex2_prenorm                                 ,--o--fpic
        f_pic_ex2_b_valid                                => f_pic_ex2_b_valid                                 ,--i--fpic
        f_pic_ex2_rnd_nr                                 => f_pic_ex2_rnd_nr                                  ,--i--falg
        f_pic_ex2_rnd_inf_ok                             => f_pic_ex2_rnd_inf_ok                              ,--i--falg
        f_pic_ex2_math_bzer_b                            => f_pic_ex2_math_bzer_b                             ,--o--fpic
        f_pic_ex3_cmp_sgnneg                             => f_pic_ex3_cmp_sgnneg                              ,--o--fpic
        f_pic_ex3_cmp_sgnpos                             => f_pic_ex3_cmp_sgnpos                              ,--o--fpic
        f_pic_ex3_is_eq                                  => f_pic_ex3_is_eq                                   ,--o--fpic
        f_pic_ex3_is_gt                                  => f_pic_ex3_is_gt                                   ,--o--fpic
        f_pic_ex3_is_lt                                  => f_pic_ex3_is_lt                                   ,--o--fpic
        f_pic_ex3_is_nan                                 => f_pic_ex3_is_nan                                  ,--o--fpic
        f_pic_ex3_sp_b                                   => f_pic_ex3_sp_b                                    ,--o--fpic
        f_dcd_rf1_uc_mid                                 => f_dcd_rf1_uc_mid                                  ,--i--fpic
        f_dcd_rf1_uc_end                                 => f_dcd_rf1_uc_end                                  ,--i--fpic
        f_dcd_rf1_uc_special                             => f_dcd_rf1_uc_special                              ,--i--fpic
        f_mad_ex2_uc_a_expo_den_sp                       => f_mad_ex2_uc_a_expo_den_sp                        ,--i--fpic
        f_mad_ex2_uc_a_expo_den                          => f_mad_ex2_uc_a_expo_den                           ,--i--fpic
        f_dcd_ex2_uc_zx                                  => f_dcd_ex2_uc_zx                                   ,--i--fpic
        f_dcd_ex2_uc_vxidi                               => f_dcd_ex2_uc_vxidi                                ,--i--fpic
        f_dcd_ex2_uc_vxzdz                               => f_dcd_ex2_uc_vxzdz                                ,--i--fpic
        f_dcd_ex2_uc_vxsqrt                              => f_dcd_ex2_uc_vxsqrt                               ,--i--fpic
        f_dcd_ex2_uc_vxsnan                              => f_dcd_ex2_uc_vxsnan                               ,--i--fpic
        f_mad_ex3_uc_special                             => f_mad_ex3_uc_special                              ,--o--fpic
        f_mad_ex3_uc_zx                                  => f_mad_ex3_uc_zx                                   ,--o--fpic
        f_mad_ex3_uc_vxidi                               => f_mad_ex3_uc_vxidi                                ,--o--fpic
        f_mad_ex3_uc_vxzdz                               => f_mad_ex3_uc_vxzdz                                ,--o--fpic
        f_mad_ex3_uc_vxsqrt                              => f_mad_ex3_uc_vxsqrt                               ,--o--fpic
        f_mad_ex3_uc_vxsnan                              => f_mad_ex3_uc_vxsnan                               ,--o--fpic
        f_mad_ex3_uc_res_sign                            => f_mad_ex3_uc_res_sign                             ,--o--fpic
        f_mad_ex3_uc_round_mode(0 to 1)                  => f_mad_ex3_uc_round_mode(0 to 1)                   ,--o--fpic
        f_pic_ex4_byp_prod_nz                            => f_pic_ex4_byp_prod_nz                             ,--o--fpic
        f_pic_ex4_sel_est_b                              => f_pic_ex4_sel_est_b                               ,--o--fpic
        f_pic_ex4_nj_deno                                => f_pic_ex4_nj_deno                                 ,--o--fpic
        f_pic_ex4_oe                                     => f_pic_ex4_oe                                      ,--o--fpic
        f_pic_ex4_ov_en                                  => f_pic_ex4_ov_en                                   ,--o--fpic
        f_pic_ex4_ovf_en_oe0_b                           => f_pic_ex4_ovf_en_oe0_b                            ,--o--fpic
        f_pic_ex4_ovf_en_oe1_b                           => f_pic_ex4_ovf_en_oe1_b                            ,--o--fpic
        f_pic_ex4_quiet_b                                => f_pic_ex4_quiet_b                                 ,--o--fpic
        f_pic_ex4_rnd_inf_ok_b                           => f_pic_ex4_rnd_inf_ok_b                            ,--o--fpic
        f_pic_ex4_rnd_ni_b                               => f_pic_ex4_rnd_ni_b                                ,--o--fpic
        f_pic_ex4_rnd_nr_b                               => f_pic_ex4_rnd_nr_b                                ,--o--fpic
        f_pic_ex4_sel_fpscr_b                            => f_pic_ex4_sel_fpscr_b                             ,--o--fpic
        f_pic_ex4_sp_b                                   => f_pic_ex4_sp_b                                    ,--o--fpic
        f_pic_ex4_spec_inf_b                             => f_pic_ex4_spec_inf_b                              ,--o--fpic
        f_pic_ex4_spec_sel_k_e                           => f_pic_ex4_spec_sel_k_e                            ,--o--fpic
        f_pic_ex4_spec_sel_k_f                           => f_pic_ex4_spec_sel_k_f                            ,--o--fpic
        f_dcd_ex2_uc_inc_lsb                             => f_dcd_ex2_uc_inc_lsb                              ,--i--fpic
        f_dcd_ex2_uc_guard                               => f_dcd_ex2_uc_gs(0)                                ,--i--fpic
        f_dcd_ex2_uc_sticky                              => f_dcd_ex2_uc_gs(1)                                ,--i--fpic
        f_dcd_ex2_uc_gs_v                                => f_dcd_ex2_uc_gs_v                                 ,--i--fpic
        f_pic_ex5_uc_inc_lsb                             => f_pic_ex5_uc_inc_lsb                              ,--o--fpic
        f_pic_ex5_uc_guard                               => f_pic_ex5_uc_guard                                ,--o--fpic
        f_pic_ex5_uc_sticky                              => f_pic_ex5_uc_sticky                               ,--o--fpic
        f_pic_ex5_uc_g_v                                 => f_pic_ex5_uc_g_v                                  ,--o--fpic
        f_pic_ex5_uc_s_v                                 => f_pic_ex5_uc_s_v                                  ,--o--fpic
        f_pic_ex4_to_int_ov_all                          => f_pic_ex4_to_int_ov_all                           ,--o--fpic
        f_pic_ex4_to_integer_b                           => f_pic_ex4_to_integer_b                            ,--o--fpic
        f_pic_ex4_word_b                                 => f_pic_ex4_word_b                                  ,--o--fpic
        f_pic_ex4_uns_b                                  => f_pic_ex4_uns_b                                   ,--o--fpic
        f_pic_ex4_ue                                     => f_pic_ex4_ue                                      ,--o--fpic
        f_pic_ex4_uf_en                                  => f_pic_ex4_uf_en                                   ,--o--fpic
        f_pic_ex4_unf_en_ue0_b                           => f_pic_ex4_unf_en_ue0_b                            ,--o--fpic
        f_pic_ex4_unf_en_ue1_b                           => f_pic_ex4_unf_en_ue1_b                            ,--o--fpic
        f_pic_ex5_en_exact_zero                          => f_pic_ex5_en_exact_zero                           ,--o--fpic
        f_pic_ex5_compare_b                              => f_pic_ex5_compare_b                               ,--o--fpic
        f_pic_ex5_frsp                                   => f_pic_ex5_frsp                                    ,--o--fpic
        f_pic_ex5_fi_pipe_v_b                            => f_pic_ex5_fi_pipe_v_b                             ,--o--fpic
        f_pic_ex5_fi_spec_b                              => f_pic_ex5_fi_spec_b                               ,--o--fpic
        f_pic_ex5_flag_vxcvi_b                           => f_pic_ex5_flag_vxcvi_b                            ,--o--fpic
        f_pic_ex5_flag_vxidi_b                           => f_pic_ex5_flag_vxidi_b                            ,--o--fpic
        f_pic_ex5_flag_vximz_b                           => f_pic_ex5_flag_vximz_b                            ,--o--fpic
        f_pic_ex5_flag_vxisi_b                           => f_pic_ex5_flag_vxisi_b                            ,--o--fpic
        f_pic_ex5_flag_vxsnan_b                          => f_pic_ex5_flag_vxsnan_b                           ,--o--fpic
        f_pic_ex5_flag_vxsqrt_b                          => f_pic_ex5_flag_vxsqrt_b                           ,--o--fpic
        f_pic_ex5_flag_vxvc_b                            => f_pic_ex5_flag_vxvc_b                             ,--o--fpic
        f_pic_ex5_flag_vxzdz_b                           => f_pic_ex5_flag_vxzdz_b                            ,--o--fpic
        f_pic_ex5_flag_zx_b                              => f_pic_ex5_flag_zx_b                               ,--o--fpic
        f_pic_ex5_fprf_hold_b                            => f_pic_ex5_fprf_hold_b                             ,--o--fpic
        f_pic_ex5_fprf_pipe_v_b                          => f_pic_ex5_fprf_pipe_v_b                           ,--o--fpic
        f_pic_ex5_fprf_spec_b(0 to 4)                    => f_pic_ex5_fprf_spec_b(0 to 4)                     ,--o--fpic
        f_pic_ex5_fr_pipe_v_b                            => f_pic_ex5_fr_pipe_v_b                             ,--o--fpic
        f_pic_ex5_fr_spec_b                              => f_pic_ex5_fr_spec_b                               ,--o--fpic
        f_pic_ex5_invert_sign                            => f_pic_ex5_invert_sign                             ,--o--fpic
        f_pic_ex5_k_nan                                  => f_pic_ex5_k_nan                                   ,--o--fpic
        f_pic_ex5_k_inf                                  => f_pic_ex5_k_inf                                   ,--o--fpic
        f_pic_ex5_k_max                                  => f_pic_ex5_k_max                                   ,--o--fpic
        f_pic_ex5_k_zer                                  => f_pic_ex5_k_zer                                   ,--o--fpic
        f_pic_ex5_k_one                                  => f_pic_ex5_k_one                                   ,--o--fpic
        f_pic_ex5_k_int_maxpos                           => f_pic_ex5_k_int_maxpos                            ,--o--fpic
        f_pic_ex5_k_int_maxneg                           => f_pic_ex5_k_int_maxneg                            ,--o--fpic
        f_pic_ex5_k_int_zer                              => f_pic_ex5_k_int_zer                               ,--o--fpic
        f_pic_ex5_ox_pipe_v_b                            => f_pic_ex5_ox_pipe_v_b                             ,--o--fpic
        f_pic_ex5_round_sign                             => f_pic_ex5_round_sign                              ,--o--fpic
        f_pic_ex5_scr_upd_move_b                         => f_pic_ex5_scr_upd_move_b                          ,--o--fpic
        f_pic_ex5_scr_upd_pipe_b                         => f_pic_ex5_scr_upd_pipe_b                          ,--o--fpic
        f_pic_ex1_nj_deni                                => f_pic_ex1_nj_deni                                 ,--o--fpic
        f_dcd_rf1_nj_deni                                => f_dcd_rf1_nj_deni                                 ,--i--fpic
        f_pic_ex5_ux_pipe_v_b                            => f_pic_ex5_ux_pipe_v_b                            );--o--fpic
------------------------------------------------------------- fuq_pic.vhdl

fcr2 : entity WORK.fuq_cr2(fuq_cr2)  generic map( expand_type => expand_type) port map( -- fuq_cr2.vhdl
------------------------------------------------------------- fuq_cr2.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(1 to 7)              ,--i--
        mpw1_b                                           => mpw1_b(1 to 7)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 1)                   ,--i--
        thold_1                                          => perv_cr2_thold_1         ,--i--
        sg_1                                             => perv_cr2_sg_1            ,--i--
        fpu_enable                                       => perv_cr2_fpu_enable      ,--i--


        f_cr2_si                                         => scan_in(14)                            ,--i--fcr2
        f_cr2_so                                         => scan_out(14)                           ,--o--fcr2
        rf1_act                                          => f_dcd_rf1_act                          ,--i--fcr2
        ex1_act                                          => f_pic_cr2_ex1_act                      ,--i--fcr2
        rf1_thread_b(0 to 3)                             => rf1_thread_b(0 to 3)                   ,--i--fcr2
        f_dcd_ex6_cancel                                 => f_dcd_ex6_cancel                       ,--i--fcr2
        f_fmt_ex1_bop_byt(45 to 52)                      => f_fmt_ex1_bop_byt(45 to 52)            ,--i--fcr2 for mtfsf to shadow reg
        f_dcd_rf1_fpscr_bit_data_b(0 to 3)               => f_dcd_rf1_fpscr_bit_data_b(0 to 3)     ,--i--fcr2 data to write to nibble (other than mtfsf)
        f_dcd_rf1_fpscr_bit_mask_b(0 to 3)               => f_dcd_rf1_fpscr_bit_mask_b(0 to 3)     ,--i--fcr2 enable update of bit within the nibble
        f_dcd_rf1_fpscr_nib_mask_b(0 to 8)               => f_dcd_rf1_fpscr_nib_mask_b(0 to 8)     ,--i--fcr2 enable update of this nibble
        f_dcd_rf1_mtfsbx_b                               => f_dcd_rf1_mtfsbx_b                     ,--i--fcr2 fpscr set bit, reset bit
        f_dcd_rf1_mcrfs_b                                => f_dcd_rf1_mcrfs_b                      ,--i--fcr2 move fpscr field to cr and reset exceptions
        f_dcd_rf1_mtfsf_b                                => f_dcd_rf1_mtfsf_b                      ,--i--fcr2 move fpr data to fpscr
        f_dcd_rf1_mtfsfi_b                               => f_dcd_rf1_mtfsfi_b                     ,--i--fcr2 move immediate data to fpscr
        f_cr2_ex3_thread_b(0 to 3)                       => f_cr2_ex3_thread_b(0 to 3)             ,--o--fcr2
        f_cr2_ex3_fpscr_bit_data_b(0 to 3)               => f_cr2_ex3_fpscr_bit_data_b(0 to 3)     ,--o--fcr2 data to write to nibble (other than mtfsf)
        f_cr2_ex3_fpscr_bit_mask_b(0 to 3)               => f_cr2_ex3_fpscr_bit_mask_b(0 to 3)     ,--o--fcr2 enable update of bit within the nibble
        f_cr2_ex3_fpscr_nib_mask_b(0 to 8)               => f_cr2_ex3_fpscr_nib_mask_b(0 to 8)     ,--o--fcr2 enable update of this nibble
        f_cr2_ex3_mtfsbx_b                               => f_cr2_ex3_mtfsbx_b                     ,--o--fcr2 fpscr set bit, reset bit
        f_cr2_ex3_mcrfs_b                                => f_cr2_ex3_mcrfs_b                      ,--o--fcr2 move fpscr field to cr and reset exceptions
        f_cr2_ex3_mtfsf_b                                => f_cr2_ex3_mtfsf_b                      ,--o--fcr2 move fpr data to fpscr
        f_cr2_ex3_mtfsfi_b                               => f_cr2_ex3_mtfsfi_b                     ,--o--fcr2 move immediate data to fpscr
        f_cr2_ex5_fpscr_rd_dat(24 to 31)                 => f_cr2_ex5_fpscr_rd_dat(24 to 31)       ,--o--fcr2
        f_cr2_ex6_fpscr_rd_dat(24 to 31)                 => f_cr2_ex6_fpscr_rd_dat(24 to 31)       ,--o--fcr2
        f_cr2_ex1_fpscr_shadow(0 to 7)                   => f_cr2_ex1_fpscr_shadow(0 to 7)        );--o--fcr2
------------------------------------------------------------- fuq_cr2.vhdl



fscr : entity WORK.fuq_scr(fuq_scr) generic map( expand_type => expand_type) port map( 
------------------------------------------------------------- fuq_scr.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(4 to 7)              ,--i--
        mpw1_b                                           => mpw1_b(4 to 7)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 1)                   ,--i--
        thold_1                                          => perv_scr_thold_1         ,--i--
        sg_1                                             => perv_scr_sg_1            ,--i--
        fpu_enable                                       => perv_scr_fpu_enable      ,--i--

        f_scr_si                                         => scan_in(15)                                       ,--i--fscr
        f_scr_so                                         => scan_out(15)                                      ,--o--fscr
        ex2_act_b                                        => f_pic_scr_ex2_act_b                               ,--i--fscr
        f_cr2_ex3_thread_b(0 to 3)                       => f_cr2_ex3_thread_b(0 to 3)                        ,--i--fscr

        f_dcd_ex6_cancel                                 => f_dcd_ex6_cancel                       ,--i--fcr2

        f_pic_ex5_scr_upd_move_b                         => f_pic_ex5_scr_upd_move_b                          ,--i--fscr
        f_pic_ex5_scr_upd_pipe_b                         => f_pic_ex5_scr_upd_pipe_b                          ,--i--fscr
        f_pic_ex5_fprf_spec_b(0 to 4)                    => f_pic_ex5_fprf_spec_b(0 to 4)                     ,--i--fscr
        f_pic_ex5_compare_b                              => f_pic_ex5_compare_b                               ,--i--fscr
        f_pic_ex5_fprf_pipe_v_b                          => f_pic_ex5_fprf_pipe_v_b                           ,--i--fscr
        f_pic_ex5_fprf_hold_b                            => f_pic_ex5_fprf_hold_b                             ,--i--fscr
        f_pic_ex5_fi_spec_b                              => f_pic_ex5_fi_spec_b                               ,--i--fscr
        f_pic_ex5_fi_pipe_v_b                            => f_pic_ex5_fi_pipe_v_b                             ,--i--fscr
        f_pic_ex5_fr_spec_b                              => f_pic_ex5_fr_spec_b                               ,--i--fscr
        f_pic_ex5_fr_pipe_v_b                            => f_pic_ex5_fr_pipe_v_b                             ,--i--fscr
        f_pic_ex5_ox_spec_b                              => tiup                                              ,--i--fscr
        f_pic_ex5_ox_pipe_v_b                            => f_pic_ex5_ox_pipe_v_b                             ,--i--fscr
        f_pic_ex5_ux_spec_b                              => tiup                                              ,--i--fscr
        f_pic_ex5_ux_pipe_v_b                            => f_pic_ex5_ux_pipe_v_b                             ,--i--fscr
        f_pic_ex5_flag_vxsnan_b                          => f_pic_ex5_flag_vxsnan_b                           ,--i--fscr
        f_pic_ex5_flag_vxisi_b                           => f_pic_ex5_flag_vxisi_b                            ,--i--fscr
        f_pic_ex5_flag_vxidi_b                           => f_pic_ex5_flag_vxidi_b                            ,--i--fscr
        f_pic_ex5_flag_vxzdz_b                           => f_pic_ex5_flag_vxzdz_b                            ,--i--fscr
        f_pic_ex5_flag_vximz_b                           => f_pic_ex5_flag_vximz_b                            ,--i--fscr
        f_pic_ex5_flag_vxvc_b                            => f_pic_ex5_flag_vxvc_b                             ,--i--fscr
        f_pic_ex5_flag_vxsqrt_b                          => f_pic_ex5_flag_vxsqrt_b                           ,--i--fscr
        f_pic_ex5_flag_vxcvi_b                           => f_pic_ex5_flag_vxcvi_b                            ,--i--fscr
        f_pic_ex5_flag_zx_b                              => f_pic_ex5_flag_zx_b                               ,--i--fscr
        f_nrm_ex5_fpscr_wr_dat_dfp(0 to 3)               => f_nrm_ex5_fpscr_wr_dat_dfp(0 to 3)                ,--i--fscr
        f_nrm_ex5_fpscr_wr_dat(0 to 31)                  => f_nrm_ex5_fpscr_wr_dat(0 to 31)                   ,--i--fscr
        f_cr2_ex3_fpscr_bit_data_b(0 to 3)               => f_cr2_ex3_fpscr_bit_data_b(0 to 3)     ,--o--fscr data to write to nibble (other than mtfsf)
        f_cr2_ex3_fpscr_bit_mask_b(0 to 3)               => f_cr2_ex3_fpscr_bit_mask_b(0 to 3)     ,--o--fscr enable update of bit within the nibble
        f_cr2_ex3_fpscr_nib_mask_b(0 to 8)               => f_cr2_ex3_fpscr_nib_mask_b(0 to 8)     ,--o--fscr enable update of this nibble
        f_cr2_ex3_mtfsbx_b                               => f_cr2_ex3_mtfsbx_b                     ,--o--fscr fpscr set bit, reset bit
        f_cr2_ex3_mcrfs_b                                => f_cr2_ex3_mcrfs_b                      ,--o--fscr move fpscr field to cr and reset exceptions
        f_cr2_ex3_mtfsf_b                                => f_cr2_ex3_mtfsf_b                      ,--o--fscr move fpr data to fpscr
        f_cr2_ex3_mtfsfi_b                               => f_cr2_ex3_mtfsfi_b                     ,--o--fscr move immediate data to fpscr
        f_rnd_ex6_flag_up                                => f_rnd_ex6_flag_up                                 ,--i--fscr
        f_rnd_ex6_flag_fi                                => f_rnd_ex6_flag_fi                                 ,--i--fscr
        f_rnd_ex6_flag_ox                                => f_rnd_ex6_flag_ox                                 ,--i--fscr
        f_rnd_ex6_flag_den                               => f_rnd_ex6_flag_den                                ,--i--fscr
        f_rnd_ex6_flag_sgn                               => f_rnd_ex6_flag_sgn                                ,--i--fscr
        f_rnd_ex6_flag_inf                               => f_rnd_ex6_flag_inf                                ,--i--fscr
        f_rnd_ex6_flag_zer                               => f_rnd_ex6_flag_zer                                ,--i--fscr
        f_rnd_ex6_flag_ux                                => f_rnd_ex6_flag_ux                                 ,--i--fscr
        f_cr2_ex6_fpscr_rd_dat(24 to 31)                 => f_cr2_ex6_fpscr_rd_dat(24 to 31)                  ,--i--fscr
        f_cr2_ex5_fpscr_rd_dat(24 to 31)                 => f_cr2_ex5_fpscr_rd_dat(24 to 31)                  ,--i--fscr
        f_scr_ex5_fpscr_rd_dat(0 to 31)                  => f_scr_ex5_fpscr_rd_dat(0 to 31)                   ,--o--fscr
        f_scr_ex5_fpscr_rd_dat_dfp(0 to 3)               => f_scr_ex5_fpscr_rd_dat_dfp(0 to 3)                ,--o--fscr
        f_scr_ex7_cr_fld(0 to 3)                         => f_scr_ex7_cr_fld(0 to 3)                          ,--o--fscr
        f_scr_ex7_fx_thread0(0 to 3)                     => f_scr_ex7_fx_thread0(0 to 3)                      ,--o--fscr --UNUSED ??
        f_scr_ex7_fx_thread1(0 to 3)                     => f_scr_ex7_fx_thread1(0 to 3)                      ,--o--fscr --UNUSED ??
        f_scr_ex7_fx_thread2(0 to 3)                     => f_scr_ex7_fx_thread2(0 to 3)                      ,--o--fscr --UNUSED ??
        f_scr_ex7_fx_thread3(0 to 3)                     => f_scr_ex7_fx_thread3(0 to 3)                     );--o--fscr --UNUSED ??
------------------------------------------------------------- fuq_scr.vhdl


ftbe : entity WORK.fuq_tblexp(fuq_tblexp) generic map( expand_type => expand_type)  port map( -- exponent for table lookups
------------------------------------------------------------- fuq_tblexp.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(2 to 3)              ,--i--
        mpw1_b                                           => mpw1_b(2 to 3)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 0)                   ,--i--
        thold_1                                          => perv_tbe_thold_1         ,--i--
        sg_1                                             => perv_tbe_sg_1            ,--i--
        fpu_enable                                       => perv_tbe_fpu_enable      ,--i--

        si                                               => scan_in(16)                                       ,--i--ftbe
        so                                               => scan_out(16)                                      ,--o--ftbe
        ex1_act_b                                        => f_pic_lza_ex1_act_b                               ,--i--ftbe
        f_pic_ex2_ue1                                    => f_pic_ex2_ue1                                     ,--i--ftbe
        f_pic_ex2_sp_b                                   => f_pic_ex2_sp_b                                    ,--i--ftbe
        f_pic_ex2_est_recip                              => f_pic_ex2_est_recip                               ,--i--ftbe
        f_pic_ex2_est_rsqrt                              => f_pic_ex2_est_rsqrt                               ,--i--ftbe
        f_eie_ex2_tbl_expo(1 to 13)                      => f_eie_ex2_tbl_expo(1 to 13)                       ,--i--ftbe
        f_fmt_ex2_lu_den_recip                           => f_fmt_ex2_lu_den_recip                            ,--i--ftbe
        f_fmt_ex2_lu_den_rsqrto                          => f_fmt_ex2_lu_den_rsqrto                           ,--i--ftbe
        f_tbe_ex3_match_en_sp                            => f_tbe_ex3_match_en_sp                             ,--o--ftbe
        f_tbe_ex3_match_en_dp                            => f_tbe_ex3_match_en_dp                             ,--o--ftbe
        f_tbe_ex3_recip_2046                             => f_tbe_ex3_recip_2046                              ,--o--ftbe
        f_tbe_ex3_recip_2045                             => f_tbe_ex3_recip_2045                              ,--o--ftbe
        f_tbe_ex3_recip_2044                             => f_tbe_ex3_recip_2044                              ,--o--ftbe
        f_tbe_ex3_lu_sh                                  => f_tbe_ex3_lu_sh                                   ,--o--ftbe
        f_tbe_ex3_recip_ue1                              => f_tbe_ex3_recip_ue1                               ,--o--ftbe
        f_tbe_ex3_may_ov                                 => f_tbe_ex3_may_ov                                  ,--o--ftbe
        f_tbe_ex3_res_expo(1 to 13)                      => f_tbe_ex3_res_expo(1 to 13)                      );--o--ftbe

ftbl : entity WORK.fuq_tbllut(fuq_tbllut)  generic map( expand_type => expand_type) port map( 
------------------------------------------------------------- fuq_tbllut.vhdl
        vdd                                              => vdd                      ,--i--
        gnd                                              => gnd                      ,--i--
        nclk                                             => nclk                     ,--i--
        clkoff_b                                         => clkoff_b                 ,--i--
        act_dis                                          => act_dis                  ,--i--
        flush                                            => flush                    ,--i--
        --d_mode                                           => d_mode                   ,--i--
        delay_lclkr                                      => delay_lclkr(2 to 5)              ,--i--
        mpw1_b                                           => mpw1_b(2 to 5)                   ,--i--
        mpw2_b                                           => mpw2_b(0 to 1)                   ,--i--
        thold_1                                          => perv_tbl_thold_1         ,--i--
        sg_1                                             => perv_tbl_sg_1            ,--i--
        fpu_enable                                       => perv_tbl_fpu_enable      ,--i--

        si                                               => scan_in(17)                                       ,--i--ftbl
        so                                               => scan_out(17)                                      ,--o--ftbl
        ex1_act                                          => f_pic_tbl_ex1_act                                 ,--i--ftbl
        f_fmt_ex1_b_frac(1 to 6)                         => f_fmt_ex1_b_frac(1 to 6)                          ,--i--ftbl
        f_fmt_ex2_b_frac(7 to 22)                        => f_fmt_ex2_pass_frac(7 to 22)                      ,--i--ftbl
        f_tbe_ex2_expo_lsb                               => f_eie_ex2_tbl_expo(13)                            ,--i--ftbl
        f_tbe_ex2_est_recip                              => f_pic_ex2_est_recip                               ,--i--ftbl
        f_tbe_ex2_est_rsqrt                              => f_pic_ex2_est_rsqrt                               ,--i--ftbl
        f_tbe_ex3_recip_ue1                              => f_tbe_ex3_recip_ue1                               ,--i--ftbl
        f_tbe_ex3_lu_sh                                  => f_tbe_ex3_lu_sh                                   ,--i--ftbl
        f_tbe_ex3_match_en_sp                            => f_tbe_ex3_match_en_sp                             ,--i--ftbl
        f_tbe_ex3_match_en_dp                            => f_tbe_ex3_match_en_dp                             ,--i--ftbl
        f_tbe_ex3_recip_2046                             => f_tbe_ex3_recip_2046                              ,--i--ftbl
        f_tbe_ex3_recip_2045                             => f_tbe_ex3_recip_2045                              ,--i--ftbl
        f_tbe_ex3_recip_2044                             => f_tbe_ex3_recip_2044                              ,--i--ftbl
        f_tbl_ex5_est_frac(0 to 26)                      => f_tbl_ex5_est_frac(0 to 26)                       ,--o--ftbl
        f_tbl_ex4_unf_expo                               => f_tbl_ex4_unf_expo                                ,--o--ftbl
        f_tbl_ex5_recip_den                              => f_tbl_ex5_recip_den                              );--o--ftbl
------------------------------------------------------------- fuq_tbllut.vhdl



    ---------------------------------------------
    -- pervasive
    ---------------------------------------------

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
