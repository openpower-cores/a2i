-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--*****************************************************************************
--*
--*  TITLE: F_DP_FPR
--*
--*  NAME:  fuq_fpr.vhdl
--*
--*  DESC:   This is the Floating Point Register file
--*
--*****************************************************************************


library IEEE,ibm;
use IEEE.STD_LOGIC_1164.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_support.all;

library support; 
use support.power_logic_pkg.all;

library tri;  use tri.tri_latches_pkg.all;

entity fuq_fpr is
generic(
     expand_type                    : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(


     nclk                           : in  clk_logic;
     clkoff_b                       : in  std_ulogic; -- tiup
     act_dis                        : in  std_ulogic; -- ??tidn??
     flush                          : in  std_ulogic; -- ??tidn??
     delay_lclkra                    : in  std_ulogic_vector(0 to 1); -- tidn,
     delay_lclkrb                    : in  std_ulogic_vector(6 to 7); -- tidn,
     mpw1_ba                         : in  std_ulogic_vector(0 to 1); -- tidn,
     mpw1_bb                         : in  std_ulogic_vector(6 to 7); -- tidn,
     mpw2_b                         : in  std_ulogic_vector(0 to 1); -- tidn,
     abst_sl_thold_1                : in  std_ulogic;
     time_sl_thold_1                : in  std_ulogic;
     ary_nsl_thold_1                : in  std_ulogic;
     gptr_sl_thold_0                : in  std_ulogic;
     fce_1                          : in  std_ulogic;
     thold_1                        : in  std_ulogic;
     sg_1                           : in  std_ulogic;
     scan_dis_dc_b                  : in  std_ulogic;  
     scan_diag_dc                   : in  std_ulogic;
     lbist_en_dc                    : in  std_ulogic;
     an_ac_abist_mode_dc            : in  std_ulogic;
     an_ac_lbist_ary_wrt_thru_dc    : in  std_ulogic;
     f_dcd_msr_fp_act               : in  std_ulogic;

     iu_fu_rf0_fra_v                : in  std_ulogic;
     iu_fu_rf0_frb_v                : in  std_ulogic;
     iu_fu_rf0_frc_v                : in  std_ulogic;
     iu_fu_rf0_str_v                : in  std_ulogic;
     f_dcd_perr_sm_running          : in  std_ulogic;

     --bolt-on lbist
     pc_fu_bolt_sl_thold_3          : in  std_ulogic;
     pc_fu_bo_enable_3              : in  std_ulogic;
     pc_fu_bo_unload                : in  std_ulogic;
     pc_fu_bo_load                  : in  std_ulogic;
     pc_fu_bo_reset                 : in  std_ulogic;
     pc_fu_bo_shdata                : in  std_ulogic;
     pc_fu_bo_select                : in  std_ulogic_vector(0 to 1);
     fu_pc_bo_fail                  : out std_ulogic_vector(0 to 1);
     fu_pc_bo_diagout               : out std_ulogic_vector(0 to 1);

     -- BX scan repower
     bx_fu_rp_abst_scan_out   : in  std_ulogic;
     bx_rp_abst_scan_out      : out std_ulogic;
     rp_bx_abst_scan_in       : in  std_ulogic;
     rp_fu_bx_abst_scan_in    : out std_ulogic;
     rp_bx_func_scan_in       : in  std_ulogic_vector(0 to 1);
     rp_fu_bx_func_scan_in    : out std_ulogic_vector(0 to 1);
     bx_fu_rp_func_scan_out   : in  std_ulogic_vector(0 to 1);
     bx_rp_func_scan_out      : out std_ulogic_vector(0 to 1);

     f_fpr_si                       : in  std_ulogic;
     f_fpr_so                       : out std_ulogic;
     f_fpr_ab_si                    : in  std_ulogic;
     f_fpr_ab_so                    : out std_ulogic;
     time_scan_in                   : in  std_ulogic;
     time_scan_out                  : out std_ulogic;
     gptr_scan_in                   : in  std_ulogic;
     gptr_scan_out                  : out std_ulogic;
     vdd                            : inout power_logic;
     gnd                            : inout power_logic;
     -- ABIST
     pc_fu_abist_di_0               : in  std_ulogic_vector(0 to 3);
     pc_fu_abist_di_1               : in  std_ulogic_vector(0 to 3);
     pc_fu_abist_ena_dc             : in  std_ulogic;
     pc_fu_abist_grf_renb_0         : in  std_ulogic;
     pc_fu_abist_grf_renb_1         : in  std_ulogic;
     pc_fu_abist_grf_wenb_0         : in  std_ulogic;      
     pc_fu_abist_grf_wenb_1         : in  std_ulogic;      
     pc_fu_abist_raddr_0            : in  std_ulogic_vector(0 to 9);
     pc_fu_abist_raddr_1            : in  std_ulogic_vector(0 to 9);
     pc_fu_abist_raw_dc_b           : in  std_ulogic;
     pc_fu_abist_waddr_0            : in  std_ulogic_vector(0 to 9);
     pc_fu_abist_waddr_1            : in  std_ulogic_vector(0 to 9);
     pc_fu_abist_wl144_comp_ena     : in  std_ulogic;
     pc_fu_inj_regfile_parity       : in  std_ulogic_vector(0 to 3);

     -- Interface to IU
     f_dcd_rf0_tid                    : in  std_ulogic_vector(0 to 1);
     f_dcd_rf0_fra                    : in  std_ulogic_vector(0 to 5);
     f_dcd_rf0_frb                    : in  std_ulogic_vector(0 to 5);
     f_dcd_rf0_frc                    : in  std_ulogic_vector(0 to 5);
     iu_fu_rf0_ldst_tid               : in  std_ulogic_vector(0 to 1);
     iu_fu_rf0_ldst_tag               : in  std_ulogic_vector(0 to 8);
     ------------------------------------------------
     f_dcd_rf0_bypsel_a_res1        : in  std_ulogic;
     f_dcd_rf0_bypsel_b_res1        : in  std_ulogic;
     f_dcd_rf0_bypsel_c_res1        : in  std_ulogic;
     f_dcd_rf0_bypsel_s_res1        : in  std_ulogic;
     f_dcd_rf0_bypsel_a_load1       : in  std_ulogic;
     f_dcd_rf0_bypsel_b_load1       : in  std_ulogic;
     f_dcd_rf0_bypsel_c_load1       : in  std_ulogic;
     f_dcd_rf0_bypsel_s_load1       : in  std_ulogic;
     ------------------------------------------------
     f_dcd_ex5_frt_tid              : in  std_ulogic_vector(0 to 1);
     f_dcd_ex5_flush_int            : in  std_ulogic_vector(0 to 3);     
     f_dcd_ex6_frt_addr             : in  std_ulogic_vector(0 to 5);
     f_dcd_ex6_frt_tid              : in  std_ulogic_vector(0 to 1);
     f_dcd_ex6_frt_wen              : in  std_ulogic;
     f_rnd_ex6_res_expo             : in  std_ulogic_vector (1 to 13);
     f_rnd_ex6_res_frac             : in  std_ulogic_vector (0 to 52);
     f_rnd_ex6_res_sign             : in  std_ulogic ;
     ------------------------------------------------
     xu_fu_ex5_load_val               : in  std_ulogic_vector(0 to 3);
     xu_fu_ex5_load_tag               : in  std_ulogic_vector(0 to 8);
     xu_fu_ex6_load_data              : in  std_ulogic_vector(192 to 255);
     ------------------------------------------------
     f_fpr_ex7_load_addr            : out std_ulogic_vector(0 to 7);
     f_fpr_ex7_load_v               : out std_ulogic;
     f_fpr_ex7_load_sign            : out std_ulogic;
     f_fpr_ex7_load_expo            : out std_ulogic_vector(3 to 13);
     f_fpr_ex7_load_frac            : out std_ulogic_vector(0 to 52);
     f_fpr_rf1_s_sign               : out std_ulogic;
     f_fpr_rf1_s_expo               : out std_ulogic_vector(1 to 11) ;
     f_fpr_rf1_s_frac               : out std_ulogic_vector(0 to 52) ;
     f_fpr_rf1_a_sign               : out std_ulogic;
     f_fpr_rf1_a_expo               : out std_ulogic_vector(1 to 13) ;
     f_fpr_rf1_a_frac               : out std_ulogic_vector(0 to 52) ;
     f_fpr_rf1_c_sign               : out std_ulogic;
     f_fpr_rf1_c_expo               : out std_ulogic_vector(1 to 13) ;
     f_fpr_rf1_c_frac               : out std_ulogic_vector(0 to 52) ;
     f_fpr_rf1_b_sign               : out std_ulogic;
     f_fpr_rf1_b_expo               : out std_ulogic_vector(1 to 13) ;
     f_fpr_rf1_b_frac               : out std_ulogic_vector(0 to 52);
     f_fpr_ex1_s_expo_extra         : out std_ulogic;
     f_fpr_ex1_a_par                : out std_ulogic_vector(0 to 7);
     f_fpr_ex1_b_par                : out std_ulogic_vector(0 to 7);
     f_fpr_ex1_c_par                : out std_ulogic_vector(0 to 7);
     f_fpr_ex1_s_par                : out std_ulogic_vector(0 to 7)
);
     -- synopsys translate_off
     -- synopsys translate_on

end fuq_fpr;

architecture fuq_fpr of fuq_fpr is


-- ####################### SIGNALS ####################### --
signal  tilo                           : std_ulogic;
signal  tihi                           : std_ulogic;

signal  thold_0                        : std_ulogic;
signal  thold_0_b                      : std_ulogic;
signal  sg_0                           : std_ulogic;
signal  forcee                          : std_ulogic;
signal  ab_thold_0                     : std_ulogic;
signal  ab_thold_0_b                   : std_ulogic;
signal  ab_force                       : std_ulogic;
signal  time_force                     : std_ulogic;
signal  time_sl_thold_0                : std_ulogic;
signal  time_sl_thold_0_b              : std_ulogic;

signal    lcb_obs0_sg_0                  :   std_ulogic; 
signal    lcb_obs1_sg_0                  :   std_ulogic; 
signal    lcb_obs0_sl_thold_0            :   std_ulogic; 
signal    lcb_obs1_sl_thold_0            :   std_ulogic; 

signal  load_tid_enc                   : std_ulogic_vector(0 to 1);
signal  load_addr                      : std_ulogic_vector(0 to 7);
signal  load_wen                       : std_ulogic;
signal  ex7_load_data_raw              : std_ulogic_vector(0 to 63);
signal  ex7_load_sp_data_raw           : std_ulogic_vector(0 to 31);
signal  ex7_load_data                  : std_ulogic_vector(0 to 65);
signal  ex6_load_val                   : std_ulogic_vector(0 to 3);
signal  ex6_load_v                     : std_ulogic;
signal  ex6_load_tag                   : std_ulogic_vector(0 to 8);
signal  ex7_load_val                   : std_ulogic_vector(0 to 3);
signal  ex7_load_tag                   : std_ulogic_vector(0 to 8);
signal  perr_inject                    : std_ulogic_vector(0 to 3);
signal  ex6_ld_perr_inj                : std_ulogic;
signal  ex7_ld_perr_inj                : std_ulogic;
signal  ex5_targ_perr_inj              : std_ulogic;
signal  ex6_targ_perr_inj              : std_ulogic;

signal  load_data                      : std_ulogic_vector(0 to 65);
signal  load_data_parity               : std_ulogic_vector(0 to 7);
signal  load_data_parity_inj           : std_ulogic_vector(0 to 7);
signal  load_sp                        : std_ulogic;
signal  load_int                       : std_ulogic;
signal  load_sign_ext                  : std_ulogic;
signal  load_int_1up                   : std_ulogic;
signal  load_dp_exp_zero               : std_ulogic;
signal  load_sp_exp_zero               : std_ulogic;
signal  load_sp_exp_ones               : std_ulogic;
signal  load_sp_data                   : std_ulogic_vector(0 to 65);
signal  load_dp_data                   : std_ulogic_vector(0 to 65);

signal  rf0_fra_addr                   : std_ulogic_vector(0 to 7);
signal  rf0_frb_addr                   : std_ulogic_vector(0 to 7);
signal  rf0_frc_addr                   : std_ulogic_vector(0 to 7);
signal  rf0_frs_addr                   : std_ulogic_vector(0 to 7);

signal  frt_addr                       : std_ulogic_vector(0 to 7);
signal  frt_wen                        : std_ulogic;
signal  frt_data_parity                : std_ulogic_vector(0 to 7);



signal  rf1_fra                        : std_ulogic_vector(0 to 77);
signal  rf1_frb                        : std_ulogic_vector(0 to 77);
signal  rf1_frc                        : std_ulogic_vector(0 to 77);
signal  rf1_frs                        : std_ulogic_vector(0 to 77);
signal     rf1_bypsel_a_res1        :   std_ulogic;
signal     rf1_bypsel_b_res1        :   std_ulogic;
signal     rf1_bypsel_c_res1        :   std_ulogic;
signal     rf1_bypsel_s_res1        :   std_ulogic;

signal     rf1_bypsel_a_res1_nlb        :   std_ulogic;
signal     rf1_bypsel_b_res1_nlb        :   std_ulogic;
signal     rf1_bypsel_c_res1_nlb        :   std_ulogic;
signal     rf1_bypsel_s_res1_nlb        :   std_ulogic;
signal     rf1_bypsel_a_load1_nlb        :   std_ulogic;
signal     rf1_bypsel_b_load1_nlb        :   std_ulogic;
signal     rf1_bypsel_c_load1_nlb        :   std_ulogic;
signal     rf1_bypsel_s_load1_nlb        :   std_ulogic;

signal rf1_a_r0e_byp_r     :   std_ulogic;
signal rf1_c_r1e_byp_r     :   std_ulogic;
signal rf1_b_r0e_byp_r     :   std_ulogic;
signal rf1_s_r1e_byp_r     :   std_ulogic;
signal r0e_sel_lbist       :   std_ulogic;
signal r1e_sel_lbist       :   std_ulogic;

signal     rf1_bypsel_a_load1       :   std_ulogic;
signal     rf1_bypsel_b_load1       :   std_ulogic;
signal     rf1_bypsel_c_load1       :   std_ulogic;
signal     rf1_bypsel_s_load1       :   std_ulogic;
signal     ex1_dcd_si, ex1_dcd_so   :   std_ulogic_vector(0 to 7);

signal    abist_raddr_0            :   std_ulogic_vector(0 to 9);
signal    abist_raddr_1            :   std_ulogic_vector(0 to 9);
signal    abist_waddr_0            :   std_ulogic_vector(0 to 9);
signal    abist_waddr_1            :   std_ulogic_vector(0 to 9);
signal    ab_reg_si, ab_reg_so     :   std_ulogic_vector(0 to 52);

signal    abist_comp_en                  :   std_ulogic;  -- when abist tested
signal    r0e_abist_comp_en              :   std_ulogic;  -- when abist tested
signal    r1e_abist_comp_en              :   std_ulogic;  -- when abist tested
signal    Alcb_act_dis_dc                 :   std_ulogic;

signal     lcb_clkoff_dc_b                :   std_ulogic_vector(0 to 1);

signal    Alcb_d_mode_dc                  :   std_ulogic;

signal    Alcb_delay_lclkr_dc             :   std_ulogic_vector(0 to 4); --<lclk delay>

signal    lcb_delay_lclkr_dc             :   std_ulogic_vector(0 to 9); --<lclk delay>

signal    fce_0                          :   std_ulogic; 
signal    Alcb_mpw1_dc_b                  :   std_ulogic_vector(0 to 4); -- <clock shapg>
signal    Alcb_mpw2_dc_b                  :   std_ulogic;

signal    lcb_mpw1_dc_b                  :   std_ulogic_vector(1 to 9); -- <clock shapg>
signal    lcb_mpw2_dc_b                  :   std_ulogic;

signal    lcb_sg_0                       :   std_ulogic; 
signal    lcb_abst_sl_thold_0            :   std_ulogic;  
signal    ary_nsl_thold_0                :   std_ulogic;  
signal    Aclkoff_dc_b                    :   std_ulogic;
signal    Ad_mode_dc                      :   std_ulogic;


signal    r_scan_in_0                      :   std_ulogic;                 
signal    r_scan_out_0                     :  std_ulogic;   
signal    w_scan_in_0                      :   std_ulogic;                 
signal    w_scan_out_0                     :  std_ulogic;   
signal    r_scan_in_1                      :   std_ulogic;                 
signal    r_scan_out_1                     :  std_ulogic;   
signal    w_scan_in_1                      :   std_ulogic;                 
signal    w_scan_out_1                     :  std_ulogic;   
signal    r0e_fra_act                        :   std_ulogic;                 
signal    r0e_fra_en_func                    :   std_ulogic;                 
signal    r0e_frb_act                        :   std_ulogic;                 
signal    r0e_frb_en_func                    :   std_ulogic;                 
signal    r0e_en_abist                   :   std_ulogic;                 
signal    r0e_addr_abist                 :   std_ulogic_vector(0 to 7);   
signal    r1e_frc_act                        :   std_ulogic;                 
signal    r1e_frc_en_func                    :   std_ulogic;                 
signal    r1e_frs_act                        :   std_ulogic;                 
signal    r1e_frs_en_func                    :   std_ulogic;                 
signal    r1e_en_abist                   :   std_ulogic;                 
signal    r1e_addr_abist                 :   std_ulogic_vector(0 to 7);   
signal    w0e_act                        :   std_ulogic;                 
signal    w0e_en_func                    :   std_ulogic;                 
signal    w0e_en_abist                   :   std_ulogic;                 
signal    w0e_addr_func                  :   std_ulogic_vector(0 to 7);  
signal    w0e_addr_abist                 :   std_ulogic_vector(0 to 7);  
signal    w0e_data_func_f0               :   std_ulogic_vector(0 to 77); 
signal    w0e_data_func_f1               :   std_ulogic_vector(0 to 77); 
signal    w0e_data_abist                 :   std_ulogic_vector(0 to 3); 
signal    w0l_act                        :   std_ulogic;                 
signal    w0l_en_func                    :   std_ulogic;                 
signal    w0l_en_abist                   :   std_ulogic;                 
signal    w0l_addr_func                  :   std_ulogic_vector(0 to 7);  
signal    w0l_addr_abist                 :   std_ulogic_vector(0 to 7);  
signal    w0l_data_func_f0               :   std_ulogic_vector(0 to 77); 
signal    w0l_data_func_f1               :   std_ulogic_vector(0 to 77); 
signal    w0l_data_abist                 :   std_ulogic_vector(0 to 3);

signal    fra_data_out                         :   std_ulogic_vector(0 to 77);
signal    frb_data_out                         :   std_ulogic_vector(0 to 77);
signal    frc_data_out                         :   std_ulogic_vector(0 to 77);
signal    frs_data_out                         :   std_ulogic_vector(0 to 77);
signal    ex1_fra_par                          :   std_ulogic_vector(0 to 7);
signal    ex1_frb_par                          :   std_ulogic_vector(0 to 7);
signal    ex1_frc_par                          :   std_ulogic_vector(0 to 7);
signal    ex1_frs_par                          :   std_ulogic_vector(0 to 7);
signal    ex1_s_expo_extra                     :   std_ulogic;

signal    ex7_ldat_si  , ex7_ldat_so           :   std_ulogic_vector(0 to 63);
signal    ex7_lctl_si  , ex7_lctl_so           :   std_ulogic_vector(0 to 9);
signal    ex7_ldv_si   , ex7_ldv_so            :   std_ulogic_vector(0 to 3);
signal    ex6_ldv_si  ,  ex6_ldv_so           :   std_ulogic_vector(0 to 3);
signal    ex6_lctl_si  , ex6_lctl_so           :   std_ulogic_vector(0 to 13);
signal    ex1_par_si   , ex1_par_so            :   std_ulogic_vector(0 to 32);
 signal ld_par3239, ld_par3239_inj, ld_par4047, ld_par4855, ld_par5663, ld_par6163, ld_par6163_inj :std_ulogic; --ld_pgen_premux--
 signal ld_par0007    , ld_par0815 , ld_par1623 , ld_par2431 :std_ulogic;--ld_pgen_premux--
 signal ld_par32_3436 , ld_par3744 , ld_par4552 , ld_par5360 :std_ulogic;--ld_pgen_premux--
 signal load_dp_nint, load_dp_int , load_sp_all1 , load_sp_nall1 :std_ulogic;--ld_pgen_premux--

 signal      xu_fu_ex5_load_val_din               :   std_ulogic_vector(0 to 3);

signal     lcb_bolt_sl_thold_2                 : std_ulogic;
signal     lcb_bolt_sl_thold_1                 : std_ulogic;
signal     lcb_bolt_sl_thold_0                 : std_ulogic;
signal     pc_bo_enable_2                      : std_ulogic;

signal  SPARE_L2                       : std_ulogic_vector(0 to 7);
signal  spare_si,        spare_so      : std_ulogic_vector(0 to 7);
signal  time_SPARE_L2                  : std_ulogic_vector(0 to 1);
signal  time_spare_si,   time_spare_so : std_ulogic_vector(0 to 1);

signal fpr_time_si,fpr_time_so                 : std_ulogic_vector(0 to 1);
signal obs0_scan_in,obs0_scan_out              : std_ulogic_vector(0 to 1);
signal obs1_scan_in,obs1_scan_out              : std_ulogic_vector(0 to 1);

signal spare_unused : std_ulogic_vector(0 to 26);


signal abst_slat_d2clk : std_ulogic;
signal abst_slat_lclk  : clk_logic;
signal func_slat_d2clk : std_ulogic;
signal func_slat_lclk  : clk_logic;

----------------------------------------------------------------
begin

------------------------------------------------------------------------
-- Pervasive
    
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

    ab_thold_reg_0:  tri_plat  generic map (width => 4, expand_type => expand_type) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,  
         flush     => flush ,
         din(0)    => abst_sl_thold_1,
         din(1)    => time_sl_thold_1,
         din(2)    => ary_nsl_thold_1,
         din(3)    => fce_1,
         q(0)      => ab_thold_0,
         q(1)      => time_sl_thold_0,
         q(2)      => ary_nsl_thold_0,
         q(3)      => fce_0 );
 
    ab_lcbor_0: tri_lcbor generic map (expand_type => expand_type ) port map (
        clkoff_b     => clkoff_b,
        thold        => ab_thold_0,  
        sg           => sg_0,
        act_dis      => act_dis,
        forcee => ab_force,
        thold_b      => ab_thold_0_b );

    time_lcbor_0: tri_lcbor generic map (expand_type => expand_type ) port map (
        clkoff_b     => clkoff_b,
        thold        => time_sl_thold_0,  
        sg           => sg_0,
        act_dis      => act_dis,
        forcee => time_force,
        thold_b      => time_sl_thold_0_b );

    --bolt on lbist staging
    bo_thold_reg_0:  tri_plat  generic map (width => 4, expand_type => expand_type) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,  
         flush     => flush ,
         din(0)    => pc_fu_bolt_sl_thold_3,
         din(1)    => lcb_bolt_sl_thold_2,
         din(2)    => lcb_bolt_sl_thold_1,
         din(3)    => pc_fu_bo_enable_3,
         q(0)      => lcb_bolt_sl_thold_2,
         q(1)      => lcb_bolt_sl_thold_1,
         q(2)      => lcb_bolt_sl_thold_0,
         q(3)      => pc_bo_enable_2 );

------------------------------------------------------------------------
-- Act Latches


   tilo      <= '0';
   tihi      <= '1';

------------------------------------------------------------------------
-- Load Data


xu_fu_ex5_load_val_din(0 to 3) <= xu_fu_ex5_load_val(0 to 3) and not f_dcd_ex5_flush_int(0 to 3);

   ex6_ldv: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 4)
   port map (nclk    => nclk,
             act     => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkrb(6),
             mpw1_b      => mpw1_bb(6),
             mpw2_b      => mpw2_b(1),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => ex6_ldv_si(0 to 3),
             scout   => ex6_ldv_so(0 to 3),
             din(0 to 3)   => xu_fu_ex5_load_val_din(0 to 3)   ,
             dout(0 to 3)  => ex6_load_val(0 to 3)             );

   ex6_lctl: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 14)
   port map (nclk    => nclk,
             act     => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkrb(6),
             mpw1_b      => mpw1_bb(6),
             mpw2_b      => mpw2_b(1),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => ex6_lctl_si(0 to 13),
             scout   => ex6_lctl_so(0 to 13),
             din(0 to 8)   => xu_fu_ex5_load_tag(0 to 8)   ,
             din(9 to 12) => pc_fu_inj_regfile_parity(0 to 3),
             din(13)       => ex5_targ_perr_inj            ,
             dout(0 to 8) => ex6_load_tag(0 to 8)         ,
             dout(9 to 12) => perr_inject(0 to 3)         ,
             dout(13)       => ex6_targ_perr_inj           );

   ex6_load_v           <= ex6_load_val(0) or ex6_load_val(1) or ex6_load_val(2) or ex6_load_val(3);
   ex6_ld_perr_inj      <= or_reduce(perr_inject(0 to 3) and ex6_load_val(0 to 3));

   ex5_targ_perr_inj    <= (f_dcd_ex5_frt_tid="00" and perr_inject(0)) or
                           (f_dcd_ex5_frt_tid="01" and perr_inject(1)) or
                           (f_dcd_ex5_frt_tid="10" and perr_inject(2)) or
                           (f_dcd_ex5_frt_tid="11" and perr_inject(3));

   ex7_ldv: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 4)
   port map (nclk    => nclk,
             act     => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkrb(7),
             mpw1_b      => mpw1_bb(7),
             mpw2_b      => mpw2_b(1),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => ex7_ldv_si(0 to 3),
             scout   => ex7_ldv_so(0 to 3),
             din(0 to 3)   => ex6_load_val(0 to 3)   ,
             dout(0 to 3)  => ex7_load_val(0 to 3)   );

   ex7_lctl: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 10)
   port map (nclk    => nclk,
             act     => ex6_load_v,
             forcee => forcee,
             delay_lclkr => delay_lclkrb(7),
             mpw1_b      => mpw1_bb(7),
             mpw2_b      => mpw2_b(1),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => ex7_lctl_si(0 to 9),
             scout   => ex7_lctl_so(0 to 9),
             din(0 to 8)  => ex6_load_tag(0 to 8)   ,
             din(9)       => ex6_ld_perr_inj        ,
             dout(0 to 8) => ex7_load_tag(0 to 8)   ,
             dout(9)      => ex7_ld_perr_inj        );

   ex7_ldat: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 64, needs_sreset => 0)
   port map (nclk    => nclk,
             act     => ex6_load_v,
             forcee => forcee,
             delay_lclkr => delay_lclkrb(7),
             mpw1_b      => mpw1_bb(7),
             mpw2_b      => mpw2_b(1),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => ex7_ldat_si(0 to 63),
             scout   => ex7_ldat_so(0 to 63),
             din     => xu_fu_ex6_load_data(192 to 255)   ,
             dout    => ex7_load_data_raw(0 to 63) );


   load_tid_enc(0)     <= ex7_load_val(2) or ex7_load_val(3);
   load_tid_enc(1)     <= ex7_load_val(1) or ex7_load_val(3);

   load_addr(1 to 7)   <= ex7_load_tag(4 to 8) & load_tid_enc(0 to 1);

   load_sp             <= ex7_load_tag(0);  -- bit 0 of the tag indicates that the instr was an lfs*
   load_int            <= ex7_load_tag(1);  -- bit 1 is lfi*
   load_sign_ext       <= ex7_load_tag(2);  -- bit 1 is lfiwax

   load_wen            <= ex7_load_val(0) or ex7_load_val(1) or
                          ex7_load_val(2) or ex7_load_val(3)  ;

-- FPU LOADS
--
-- Double precision (DP) loads are straight forward.
-- To get rid of the mathematical discontinuity in the ieee number system,
-- We add the implicit bit and change the zero exponent from x000 to x001.
-- This needs to be undone when data is stored.
--
-- the spec says that Single Precision loads (SP) should be fully normalized
-- and converted to double format before storing.
-- there is not time to do that, so we take a short cut and deal with the problems
-- when the operand is used.
-- The Double precision exponent bias is 1023.
-- The Single precision exponent bias is  127.
-- The difference x380 is added to convert the exponent.
-- (actually no adder is needed)
--          x380 => "0_0011_1000_0000
--           SP             Dddd_dddd
--          if D=0   0_0011_1ddd_dddd    --> {D, !D, !D, !D}
--          if D=1   0_0100_0ddd_dddd    --> {D, !D, !D, !D}
--
-- also for SP -> SP_infinity is converted to DP infinity
--             -> (0) is converted to x381 (instead of x380) and the implicit bit is added.
-- so .... there are now 2 numbers that mean zero
--            1) (exp==x001) and (IMP_bit==0) and (FRAC==0)
--            2) (exp==x381) and (IMP_bit==0) and (FRAC==0)
-- the only time the SP load needs correcting (prenormalization) is
--           (exp==x381) and (IMP_bit==0) and (FRAC==0) <== SP denorm can be converted to DP norm.
--
--------------------------------------------------------------------------------------------------
-- INPUT LOAD DATA FORMAT  LdDin[0:63] :
--
--           lfd       lfs
--  [00:00] sign       [00:00] sign
--  [01:11] exponent   [01:08] exponent
--  [12:63] fraction   [09:31] fraction
-- -----------------------------------------------------------------------------------------------
-- OUTPUT LOAD DATA FORMAT ... add implicit bit
--
--          DP                                   |  SP
--  ---------------------------------------------|-------------------------------------------------
-- [00:00]  Din[00]                              |  Din[00]                           <--- Sgn
-- [01:01]  Din[01]                              |  Din[01]                           <--- exp[00]     //03
-- [02:02]  Din[02]                              | ~Din[01] | (Din[01:08]="11111111") <--- exp[01]     //04
-- [03:03]  Din[03]                              | ~Din[01] | (Din[01:08]="11111111") <--- exp[02]     //05
-- [04:04]  Din[04]                              | ~Din[01] | (Din[01:08]="11111111") <--- exp[03]     //06
-- [05:10]  Din[05:10]                           |  Din[02:07]                        <--- exp[04:09]  //07:12
-- [11:11]  Din[11] | (Din[01:11]="00000000000") |  Din[08] | (Din[01:08]="00000000") <--- exp[10]     //13
-- [12:12]           ~(Din[01:11]="00000000000") |           ~(Din[01:08]="00000000") <--- frac[00]    //imlicit bit
-- [13:35]  Din[12:34]                           |  Din[09:31]                        <--- frac[01:23]
-- [36:64]  Din[35:63]                           |  (0:28=>'0')                       <--- frac[24:52]
--  ---------------------------------------------|-------------------------------------------------
--------------------------------------------------------------------------------
-- LOAD FPU/FPR data format
--
-- Double-precision load: lfd*
--
-- Value Loaded  Internal Representation [sign exponent imp fraction]  Format name
-- ------------  ----------------------------------------------------  -----------
-- 0             x 00000000001 0 0000...                               Zero
-- Denormal      x 00000000001 0 xxxx...                               Denormal
-- Normal        x xxxxxxxxxxx 1 xxxx...                               Normal
-- Inf           x 11111111111 1 0000...                               Inf
-- NaN           x 11111111111 1 qxxx...                               NaN
--
-- Single-precision denormal form (SP_DENORM)
--  exp = 0x381, imp = 0, frac != 0 (frac == 0: SP_DENORM0)
--
-- Single-precision load: lfs*
--
-- Value Loaded  Internal Representation [sign exponent imp fraction]  Format name
-- ------------  ----------------------------------------------------  -----------
-- 0             x 01110000001 0 000000000000000000000000000...        SP_DENORM0
-- Denormal      x 01110000001 0 xxxxxxxxxxxxxxxxxxxxxxx0000...        SP_DENORM
-- Normal        x xXXXxxxxxxx 1 xxxxxxxxxxxxxxxxxxxxxxx0000...        Normal
-- Inf           x 11111111111 1 000000000000000000000000000...        Inf
-- NaN           x 11111111111 1 qxxxxxxxxxxxxxxxxxxxxxx0000...        NaN
--------------------------------------------------------------------------------
   -- Convert Incoming SP loads to DP format
   -- DP bias = 1023
   -- SP bias =  127
   -- diff = x380 => 0_0011_1000_0000
   --        SP             Dddd_dddd
   -- if D=0, 0_0011_1ddd_dddd -> {D,!D,!D,!D}
   -- if D=1, 0_0100_0ddd_dddd -> {D,!D,!D,!D}

   -- For lfiwax and lfiwzx, either set upper (32) to zeros or ones
   --load_int_zup  <= (load_int and load_sign_ext and not load_sp_data(0)) or (load_int and not load_sign_ext);
   load_int_1up  <=  load_int and load_sign_ext and     load_sp_data(0);

   -- Due to the XU rotator, all SP loads (words) are aligned to the right
   ex7_load_sp_data_raw(0 to 31) <= ex7_load_data_raw(32 to 63);

   load_dp_exp_zero       <= ex7_load_data_raw( 1 to 11)    = "00000000000";
   load_sp_exp_zero       <= ex7_load_sp_data_raw( 1 to 8) =    "00000000";
   load_sp_exp_ones       <= ex7_load_sp_data_raw( 1 to 8) =    "11111111";

   load_sp_data(0)        <=     ex7_load_sp_data_raw( 0);                     -- sign
   load_sp_data(1)        <=     tilo;                                         -- exp02
   load_sp_data(2)        <=     ex7_load_sp_data_raw( 1);                     -- exp03
   load_sp_data(3)        <= not ex7_load_sp_data_raw( 1) or load_sp_exp_ones; -- exp04
   load_sp_data(4)        <= not ex7_load_sp_data_raw( 1) or load_sp_exp_ones; -- exp05
   load_sp_data(5)        <= not ex7_load_sp_data_raw( 1) or load_sp_exp_ones; -- exp06
   load_sp_data(6 to 11)  <=     ex7_load_sp_data_raw( 2 to 7);                -- exp07-12
   load_sp_data(12)       <=     ex7_load_sp_data_raw( 8) or load_sp_exp_zero; -- exp13
   load_sp_data(13)       <=                             not load_sp_exp_zero; -- implicit
   load_sp_data(14 to 36) <=     ex7_load_sp_data_raw( 9 to 31);               -- frac01:23
   load_sp_data(37 to 65) <= (37 to 65 => tilo);                               -- frac24:52


   load_dp_data( 0)       <= (ex7_load_data_raw( 0)       and not                 load_int)  or              load_int_1up;  -- sign
   load_dp_data( 1)       <= tilo;                                                                                          -- exp02
   load_dp_data( 2 to 11) <= (ex7_load_data_raw( 1 to 10) and not  (1 to 10 =>    load_int)) or  (1 to 10 => load_int_1up); -- exp03-12
   load_dp_data(12)       <= (ex7_load_data_raw(11) or load_dp_exp_zero) or       load_int   or              load_int_1up;  -- exp13
   load_dp_data(13)       <= (                      not load_dp_exp_zero  and not load_int)  or              load_int_1up;  -- implicit
   load_dp_data(14 to 33) <= (ex7_load_data_raw(12 to 31) and not (14 to 33 =>    load_int)) or (14 to 33 => load_int_1up); -- fraction
   load_dp_data(34 to 65) <=  ex7_load_data_raw(32 to 63);                      -- fraction


   ex7_load_data(0 to 65) <= (load_dp_data(0 to 65)  and not (0 to 65 => load_sp)) or
                             (load_sp_data(0 to 65)  and     (0 to 65 => load_sp)) ;


   load_data(0 to 65)  <= ex7_load_data(0 to 65);



   ld_par0007 <=                           
                 ex7_load_data_raw( 0) xor 
                 ex7_load_data_raw( 1) xor 
                 ex7_load_data_raw( 2) xor 
                 ex7_load_data_raw( 3) xor 
                 ex7_load_data_raw( 4) xor 
                 ex7_load_data_raw( 5) xor 
                 ex7_load_data_raw( 6) xor 
                 ex7_load_data_raw( 7) ;   
   ld_par32_3436 <= 
                 ex7_load_data_raw(32) xor 
                 ex7_load_data_raw(34) xor 
                 ex7_load_data_raw(35) xor 
                 ex7_load_data_raw(36) ;   
   ld_par0815 <=                           
                 ex7_load_data_raw( 8) xor 
                 ex7_load_data_raw( 9) xor 
                 ex7_load_data_raw(10) xor 
                 ex7_load_data_raw(11) xor 
                 ex7_load_data_raw(12) xor 
                 ex7_load_data_raw(13) xor 
                 ex7_load_data_raw(14) xor 
                 ex7_load_data_raw(15) ;   
   ld_par3744 <=                           
                 ex7_load_data_raw(37) xor 
                 ex7_load_data_raw(38) xor 
                 ex7_load_data_raw(39) xor 
                 ex7_load_data_raw(40) xor 
                 ex7_load_data_raw(41) xor 
                 ex7_load_data_raw(42) xor 
                 ex7_load_data_raw(43) xor 
                 ex7_load_data_raw(44) ;   
   ld_par1623 <=                           
                 ex7_load_data_raw(16) xor 
                 ex7_load_data_raw(17) xor 
                 ex7_load_data_raw(18) xor 
                 ex7_load_data_raw(19) xor 
                 ex7_load_data_raw(20) xor 
                 ex7_load_data_raw(21) xor 
                 ex7_load_data_raw(22) xor 
                 ex7_load_data_raw(23) ;   
   ld_par4552 <=                           
                 ex7_load_data_raw(45) xor 
                 ex7_load_data_raw(46) xor 
                 ex7_load_data_raw(47) xor 
                 ex7_load_data_raw(48) xor 
                 ex7_load_data_raw(49) xor 
                 ex7_load_data_raw(50) xor 
                 ex7_load_data_raw(51) xor 
                 ex7_load_data_raw(52) ;   
   ld_par2431 <=                           
                 ex7_load_data_raw(24) xor 
                 ex7_load_data_raw(25) xor 
                 ex7_load_data_raw(26) xor 
                 ex7_load_data_raw(27) xor 
                 ex7_load_data_raw(28) xor 
                 ex7_load_data_raw(29) xor 
                 ex7_load_data_raw(30) xor 
                 ex7_load_data_raw(31) ;   
   ld_par5360 <=                           
                 ex7_load_data_raw(53) xor 
                 ex7_load_data_raw(54) xor 
                 ex7_load_data_raw(55) xor 
                 ex7_load_data_raw(56) xor 
                 ex7_load_data_raw(57) xor 
                 ex7_load_data_raw(58) xor 
                 ex7_load_data_raw(59) xor 
                 ex7_load_data_raw(60) ;   
   ld_par3239 <=                           
                 ex7_load_data_raw(32) xor 
                 ex7_load_data_raw(33) xor 
                 ex7_load_data_raw(34) xor 
                 ex7_load_data_raw(35) xor 
                 ex7_load_data_raw(36) xor 
                 ex7_load_data_raw(37) xor 
                 ex7_load_data_raw(38) xor 
                 ex7_load_data_raw(39) ;   
   ld_par3239_inj <=                           
                 ex7_load_data_raw(32) xor 
                 ex7_load_data_raw(33) xor 
                 ex7_load_data_raw(34) xor 
                 ex7_load_data_raw(35) xor 
                 ex7_load_data_raw(36) xor 
                 ex7_load_data_raw(37) xor 
                 ex7_load_data_raw(38) xor 
                 ex7_load_data_raw(39) xor 
                 ex7_ld_perr_inj       ;   
   ld_par4047 <=                           
                 ex7_load_data_raw(40) xor 
                 ex7_load_data_raw(41) xor 
                 ex7_load_data_raw(42) xor 
                 ex7_load_data_raw(43) xor 
                 ex7_load_data_raw(44) xor 
                 ex7_load_data_raw(45) xor 
                 ex7_load_data_raw(46) xor 
                 ex7_load_data_raw(47) ;   
   ld_par4855 <=                           
                 ex7_load_data_raw(48) xor 
                 ex7_load_data_raw(49) xor 
                 ex7_load_data_raw(50) xor 
                 ex7_load_data_raw(51) xor 
                 ex7_load_data_raw(52) xor 
                 ex7_load_data_raw(53) xor 
                 ex7_load_data_raw(54) xor 
                 ex7_load_data_raw(55) ;   
   ld_par5663 <=                           
                 ex7_load_data_raw(56) xor 
                 ex7_load_data_raw(57) xor 
                 ex7_load_data_raw(58) xor 
                 ex7_load_data_raw(59) xor 
                 ex7_load_data_raw(60) xor 
                 ex7_load_data_raw(61) xor 
                 ex7_load_data_raw(62) xor 
                 ex7_load_data_raw(63) ;   
   ld_par6163 <=                           
                 ex7_load_data_raw(61) xor 
                 ex7_load_data_raw(62) xor 
                 ex7_load_data_raw(63) ; 
   ld_par6163_inj <=                           
                 ex7_load_data_raw(61) xor 
                 ex7_load_data_raw(62) xor 
                 ex7_load_data_raw(63) xor 
                 ex7_ld_perr_inj       ;   

 load_dp_nint  <= not load_sp and not load_int         ;
 load_dp_int   <= not load_sp and     load_int         ;
 load_sp_all1  <=     load_sp and     load_sp_exp_ones ;
 load_sp_nall1 <=     load_sp and not load_sp_exp_ones ;

 load_data_parity(0) <= (    ld_par0007 and load_dp_nint) or (    ld_par32_3436 and load_sp_all1) or     
                                                             (not ld_par32_3436 and load_sp_nall1) ;  
 load_data_parity(1) <= (not ld_par0815 and load_dp_nint) or (not ld_par3744 and load_sp) or load_dp_int;
 load_data_parity(2) <= (    ld_par1623 and load_dp_nint) or (    ld_par4552 and load_sp);               
 load_data_parity(3) <= (    ld_par2431 and load_dp_nint) or (    ld_par5360 and load_sp);               
 load_data_parity(4) <= (    ld_par3239 and not load_sp ) or (    ld_par6163 and load_sp);               
 load_data_parity(5) <= (    ld_par4047 and not load_sp ) ;                                              
 load_data_parity(6) <= (    ld_par4855 and not load_sp ) ;                                              
 load_data_parity(7) <= (    ld_par5663 and not load_sp ) ;                                              

 load_data_parity_inj(0) <= (    ld_par0007 and load_dp_nint) or (    ld_par32_3436 and load_sp_all1) or     
                                                             (not ld_par32_3436 and load_sp_nall1) ;  
 load_data_parity_inj(1) <= (not ld_par0815 and load_dp_nint) or (not ld_par3744 and load_sp) or load_dp_int;
 load_data_parity_inj(2) <= (    ld_par1623 and load_dp_nint) or (    ld_par4552 and load_sp);               
 load_data_parity_inj(3) <= (    ld_par2431 and load_dp_nint) or (    ld_par5360 and load_sp);               
 load_data_parity_inj(4) <= (    ld_par3239_inj and not load_sp ) or (    ld_par6163_inj and load_sp);               
 load_data_parity_inj(5) <= (    ld_par4047 and not load_sp ) ;                                              
 load_data_parity_inj(6) <= (    ld_par4855 and not load_sp ) ;                                              
 load_data_parity_inj(7) <= (    ld_par5663 and not load_sp ) ;                                              




------------------------------------------------------------------------
-- Load Bypass

   f_fpr_ex7_load_sign          <= load_data(0);
   f_fpr_ex7_load_expo(3 to 13) <= load_data(2 to 12);
   f_fpr_ex7_load_frac(0 to 52) <= load_data(13 to 65);

------------------------------------------------------------------------
-- Target Data

   frt_addr(1 to 7)   <= f_dcd_ex6_frt_addr(1 to 5) & f_dcd_ex6_frt_tid(0 to 1);
   frt_wen            <= f_dcd_ex6_frt_wen;

   frt_data_parity(0)  <= f_rnd_ex6_res_sign     xor f_rnd_ex6_res_expo(2)  xor f_rnd_ex6_res_expo(3)  xor f_rnd_ex6_res_expo(4)  xor f_rnd_ex6_res_expo(5)  xor
                          f_rnd_ex6_res_expo(6)  xor f_rnd_ex6_res_expo(7)  xor f_rnd_ex6_res_expo(8)  xor f_rnd_ex6_res_expo(9) ;
   frt_data_parity(1)  <= f_rnd_ex6_res_expo(10) xor f_rnd_ex6_res_expo(11) xor f_rnd_ex6_res_expo(12) xor f_rnd_ex6_res_expo(13) xor f_rnd_ex6_res_frac(0) xor
                          f_rnd_ex6_res_frac(1)  xor f_rnd_ex6_res_frac(2)  xor f_rnd_ex6_res_frac(3)  xor f_rnd_ex6_res_frac(4) ;
   frt_data_parity(2)  <= f_rnd_ex6_res_frac(5)  xor f_rnd_ex6_res_frac(6)  xor f_rnd_ex6_res_frac(7)  xor f_rnd_ex6_res_frac(8)  xor
                          f_rnd_ex6_res_frac(9)  xor f_rnd_ex6_res_frac(10) xor f_rnd_ex6_res_frac(11) xor f_rnd_ex6_res_frac(12) ;
   frt_data_parity(3)  <= f_rnd_ex6_res_frac(13) xor f_rnd_ex6_res_frac(14) xor f_rnd_ex6_res_frac(15) xor f_rnd_ex6_res_frac(16) xor
                          f_rnd_ex6_res_frac(17) xor f_rnd_ex6_res_frac(18) xor f_rnd_ex6_res_frac(19) xor f_rnd_ex6_res_frac(20) ;
   frt_data_parity(4)  <= f_rnd_ex6_res_frac(21) xor f_rnd_ex6_res_frac(22) xor f_rnd_ex6_res_frac(23) xor f_rnd_ex6_res_frac(24) xor
                          f_rnd_ex6_res_frac(25) xor f_rnd_ex6_res_frac(26) xor f_rnd_ex6_res_frac(27) xor f_rnd_ex6_res_frac(28) ;
   frt_data_parity(5)  <= f_rnd_ex6_res_frac(29) xor f_rnd_ex6_res_frac(30) xor f_rnd_ex6_res_frac(31) xor f_rnd_ex6_res_frac(32) xor
                          f_rnd_ex6_res_frac(33) xor f_rnd_ex6_res_frac(34) xor f_rnd_ex6_res_frac(35) xor f_rnd_ex6_res_frac(36) ;
   frt_data_parity(6)  <= f_rnd_ex6_res_frac(37) xor f_rnd_ex6_res_frac(38) xor f_rnd_ex6_res_frac(39) xor f_rnd_ex6_res_frac(40) xor
                          f_rnd_ex6_res_frac(41) xor f_rnd_ex6_res_frac(42) xor f_rnd_ex6_res_frac(43) xor f_rnd_ex6_res_frac(44) ;
   frt_data_parity(7)  <= f_rnd_ex6_res_frac(45) xor f_rnd_ex6_res_frac(46) xor f_rnd_ex6_res_frac(47) xor f_rnd_ex6_res_frac(48) xor
                          f_rnd_ex6_res_frac(49) xor f_rnd_ex6_res_frac(50) xor f_rnd_ex6_res_frac(51) xor f_rnd_ex6_res_frac(52);


------------------------------------------------------------------------
-- Source Address

   rf0_fra_addr(1 to 7)   <= f_dcd_rf0_fra(1 to 5) & f_dcd_rf0_tid(0 to 1); --uc_hook
   rf0_frb_addr(1 to 7)   <= f_dcd_rf0_frb(1 to 5) & f_dcd_rf0_tid(0 to 1); 
   rf0_frc_addr(1 to 7)   <= f_dcd_rf0_frc(1 to 5) & f_dcd_rf0_tid(0 to 1);

   rf0_frs_addr(1 to 7)   <= iu_fu_rf0_ldst_tag(4 to 8) & iu_fu_rf0_ldst_tid(0 to 1);

   -- Microcode Scratch Registers
   rf0_fra_addr(0)        <= f_dcd_rf0_fra(0); -- uc_hook
   rf0_frb_addr(0)        <= f_dcd_rf0_frb(0);  
   rf0_frc_addr(0)        <= f_dcd_rf0_frc(0);

   frt_addr(0)            <= f_dcd_ex6_frt_addr(0);

   rf0_frs_addr(0)        <= iu_fu_rf0_ldst_tag(3);    -- Don't need to store from scratch regs?
   load_addr(0)           <= ex7_load_tag(3);          

   -- For bypass writethru compare
   f_fpr_ex7_load_addr(0 to 7) <= load_tid_enc(0 to 1) & load_addr(0) & ex7_load_tag(4 to 8);
   f_fpr_ex7_load_v            <= load_wen;

------------------------------------------------------------------------
-- RF0


------------------------------------------------------------------------
-- RF1



   w0e_act                <= load_wen;
   w0e_en_func            <= load_wen;
   w0e_addr_func(0 to 7)  <= load_addr(0 to 7);

   w0l_act                <= frt_wen;
   w0l_en_func            <= frt_wen;
   w0l_addr_func(0 to 7)  <= frt_addr (0 to 7);

   --parity(0 to 7)<= data(66 to 73)    0:7
   --"000"                              8:10
   --sign          <= data(0);          11
   --expo(1)                            12
   --expo(2 to 13) <= data(1 to 12);    13:24
   --frac(0 to 52) <= data(13 to 65);   25:77

   w0e_data_func_f0(0 to 77) <= load_data_parity_inj(0 to 7)  & "000" & load_data(0) & '0' & load_data(1 to 65);
   w0e_data_func_f1(0 to 77) <= load_data_parity(0 to 7)     & "000" & load_data(0) & '0' & load_data(1 to 65);

   w0l_data_func_f0(0 to 77) <= frt_data_parity(0 to 7) & "000" & f_rnd_ex6_res_sign & f_rnd_ex6_res_expo(1 to 13) & f_rnd_ex6_res_frac(0 to 52);
   w0l_data_func_f1(0 to 77) <= frt_data_parity(0 to 6) & (frt_data_parity(7) xor ex6_targ_perr_inj) & "000" & f_rnd_ex6_res_sign & f_rnd_ex6_res_expo(1 to 13) & f_rnd_ex6_res_frac(0 to 52);

   rf1_fra(0 to 77)     <= fra_data_out( 0 to 77);       --frac
   rf1_frb(0 to 77)     <= frb_data_out( 0 to 77);       --frac
   rf1_frc(0 to 77)     <= frc_data_out( 0 to 77);       --frac
   rf1_frs(0 to 77)     <= frs_data_out( 0 to 77);       --frac


   rf1_byp: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 8, needs_sreset => 0)
   port map (nclk    => nclk,
             act     => f_dcd_msr_fp_act,
             forcee => forcee,
             delay_lclkr => delay_lclkra(0),
             mpw1_b      => mpw1_ba(0),
             mpw2_b      => mpw2_b(0),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd      => vdd,
             gd      => gnd,
             scin    => ex1_dcd_si(0 to 7),
             scout   => ex1_dcd_so(0 to 7),
             din ( 0) => f_dcd_rf0_bypsel_a_res1   ,
             din ( 1) => f_dcd_rf0_bypsel_b_res1   ,
             din ( 2) => f_dcd_rf0_bypsel_c_res1   ,
             din ( 3) => f_dcd_rf0_bypsel_s_res1   ,
             din ( 4) => f_dcd_rf0_bypsel_a_load1   ,
             din ( 5) => f_dcd_rf0_bypsel_b_load1   ,
             din ( 6) => f_dcd_rf0_bypsel_c_load1   ,
             din ( 7) => f_dcd_rf0_bypsel_s_load1   ,

             dout( 0) => rf1_bypsel_a_res1   ,
             dout( 1) => rf1_bypsel_b_res1   ,
             dout( 2) => rf1_bypsel_c_res1   ,
             dout( 3) => rf1_bypsel_s_res1   ,
             dout( 4) => rf1_bypsel_a_load1   ,
             dout( 5) => rf1_bypsel_b_load1   ,
             dout( 6) => rf1_bypsel_c_load1   ,
             dout( 7) => rf1_bypsel_s_load1   );

 rf1_bypsel_a_res1_nlb   <= rf1_bypsel_a_res1  ;
 rf1_bypsel_b_res1_nlb   <= rf1_bypsel_b_res1  ;
 rf1_bypsel_c_res1_nlb   <= rf1_bypsel_c_res1  ;
 rf1_bypsel_s_res1_nlb   <= rf1_bypsel_s_res1  ;
 rf1_bypsel_a_load1_nlb  <= rf1_bypsel_a_load1 ;
 rf1_bypsel_b_load1_nlb  <= rf1_bypsel_b_load1 ;
 rf1_bypsel_c_load1_nlb  <= rf1_bypsel_c_load1 ;
 rf1_bypsel_s_load1_nlb  <= rf1_bypsel_s_load1 ;

 rf1_a_r0e_byp_r  <= not(rf1_bypsel_a_load1 or rf1_bypsel_a_res1) ;
 rf1_c_r1e_byp_r  <= not(rf1_bypsel_c_load1 or rf1_bypsel_c_res1) ;

 rf1_b_r0e_byp_r  <= not(rf1_bypsel_b_load1 or rf1_bypsel_b_res1) ;
 rf1_s_r1e_byp_r  <= not(rf1_bypsel_s_load1 or rf1_bypsel_s_res1) ; 



             
   -- Array Instantiation
   f0 : entity tri.tri_144x78_2r2w
   generic map (expand_type => expand_type)
   port map(
      vdd                            => vdd                            ,
      gnd                            => gnd                            ,
      nclk                           => nclk                           ,

      lcb_bolt_sl_thold_0            => lcb_bolt_sl_thold_0            ,
      pc_bo_enable_2                 => pc_bo_enable_2                 ,
      pc_bo_reset                    => pc_fu_bo_reset                 ,
      pc_bo_unload                   => pc_fu_bo_unload                ,
      pc_bo_load                     => pc_fu_bo_load                  ,
      pc_bo_shdata                   => pc_fu_bo_shdata                ,
      pc_bo_select                   => pc_fu_bo_select(0)             ,
      bo_pc_failout                  => fu_pc_bo_fail(0)               ,
      bo_pc_diagloop                 => fu_pc_bo_diagout(0)            ,

      tri_lcb_mpw1_dc_b              => mpw1_ba(0),      
      tri_lcb_mpw2_dc_b              => mpw2_b(0),      
      tri_lcb_delay_lclkr_dc         => delay_lclkra(0), 
      tri_lcb_clkoff_dc_b            => clkoff_b,    
      tri_lcb_act_dis_dc             => tilo,        
             
      abist_en                       => pc_fu_abist_ena_dc             ,
      abist_raw_dc_b                 => pc_fu_abist_raw_dc_b           ,
      r0e_abist_comp_en              => r0e_abist_comp_en              ,
      r1e_abist_comp_en              => r1e_abist_comp_en              ,
      lbist_en                       => an_ac_lbist_ary_wrt_thru_dc    , 
      lcb_act_dis_dc                 => Alcb_act_dis_dc                 ,
      lcb_clkoff_dc_b                => lcb_clkoff_dc_b                 ,
      lcb_d_mode_dc                  => Alcb_d_mode_dc                  ,
      lcb_delay_lclkr_dc             => lcb_delay_lclkr_dc             ,
      lcb_fce_0                      => fce_0                          ,
      lcb_mpw1_dc_b                  => lcb_mpw1_dc_b                  ,
      lcb_mpw2_dc_b                  => lcb_mpw2_dc_b                  ,
      lcb_scan_diag_dc               => scan_diag_dc                   ,
      lcb_scan_dis_dc_b              => scan_dis_dc_b                  ,
      lcb_sg_0                       => lcb_sg_0                       ,
      lcb_time_sg_0                  => lcb_sg_0                       ,
      lcb_abst_sl_thold_0            => lcb_abst_sl_thold_0            ,
      lcb_time_sl_thold_0            => time_sl_thold_0            ,
      lcb_obs0_sg_0                  => lcb_obs0_sg_0                  ,
      lcb_obs1_sg_0                  => lcb_obs1_sg_0                  ,
      lcb_obs0_sl_thold_0            => lcb_obs0_sl_thold_0            ,
      lcb_obs1_sl_thold_0            => lcb_obs1_sl_thold_0            ,
      lcb_ary_nsl_thold_0            => ary_nsl_thold_0                ,
      r_scan_in                      => r_scan_in_0                    ,
      r_scan_out                     => r_scan_out_0                   ,
      w_scan_in                      => w_scan_in_0                    ,
      w_scan_out                     => w_scan_out_0                   ,
      time_scan_in                   => fpr_time_si(0)                 ,
      time_scan_out                  => fpr_time_so(0)                 ,
      obs0_scan_in                   => obs0_scan_in(0)                ,
      obs0_scan_out                  => obs0_scan_out(0)               ,
      obs1_scan_in                   => obs1_scan_in(0)                ,
      obs1_scan_out                  => obs1_scan_out(0)               ,
      -- Read Port FRA
      r0e_act                        => r0e_fra_act                        ,
      r0e_en_func                    => r0e_fra_en_func                    ,
      r0e_en_abist                   => r0e_en_abist                   ,
      r0e_addr_func                  => rf0_fra_addr                   ,
      r0e_addr_abist                 => r0e_addr_abist                 ,
      r0e_data_out                   => fra_data_out                   ,
      r0e_byp_e                      => rf1_bypsel_a_load1_nlb       ,
      r0e_byp_l                      => rf1_bypsel_a_res1_nlb        ,
      r0e_byp_r                      => rf1_a_r0e_byp_r,       
      r0e_sel_lbist                  => r0e_sel_lbist                  ,
      -- Read Port FRC
      r1e_act                        => r1e_frc_act                        ,
      r1e_en_func                    => r1e_frc_en_func                    ,
      r1e_en_abist                   => r1e_en_abist                   ,
      r1e_addr_func                  => rf0_frc_addr                   ,
      r1e_addr_abist                 => r1e_addr_abist                 ,
      r1e_data_out                   => frc_data_out                   ,
      r1e_byp_e                      => rf1_bypsel_c_load1_nlb       ,
      r1e_byp_l                      => rf1_bypsel_c_res1_nlb        ,
      r1e_byp_r                      => rf1_c_r1e_byp_r,       
      r1e_sel_lbist                  => r1e_sel_lbist                  ,
      -- Write Ports
      w0e_act                        => w0e_act                        ,
      w0e_en_func                    => w0e_en_func                    ,
      w0e_en_abist                   => w0e_en_abist                   ,
      w0e_addr_func                  => w0e_addr_func                  ,
      w0e_addr_abist                 => w0e_addr_abist                 ,
      w0e_data_func                  => w0e_data_func_f0               ,
      w0e_data_abist                 => w0e_data_abist                 ,
      w0l_act                        => w0l_act                        ,
      w0l_en_func                    => w0l_en_func                    ,
      w0l_en_abist                   => w0l_en_abist                   ,
      w0l_addr_func                  => w0l_addr_func                  ,
      w0l_addr_abist                 => w0l_addr_abist                 ,
      w0l_data_func                  => w0l_data_func_f0               ,
      w0l_data_abist                 => w0l_data_abist                 
      );

   -- Array Instantiation
   f1 : entity tri.tri_144x78_2r2w
   generic map (expand_type => expand_type)
   port map(
      vdd                            => vdd                            ,
      gnd                            => gnd                            ,
      nclk                           => nclk                           ,

      lcb_bolt_sl_thold_0            => lcb_bolt_sl_thold_0            ,
      pc_bo_enable_2                 => pc_bo_enable_2                 ,
      pc_bo_reset                    => pc_fu_bo_reset                 ,
      pc_bo_unload                   => pc_fu_bo_unload                ,
      pc_bo_load                     => pc_fu_bo_load                  ,
      pc_bo_shdata                   => pc_fu_bo_shdata                ,
      pc_bo_select                   => pc_fu_bo_select(1)             ,
      bo_pc_failout                  => fu_pc_bo_fail(1)               ,
      bo_pc_diagloop                 => fu_pc_bo_diagout(1)            ,

      tri_lcb_mpw1_dc_b              => mpw1_ba(0),      
      tri_lcb_mpw2_dc_b              => mpw2_b(0),      
      tri_lcb_delay_lclkr_dc         => delay_lclkra(0), 
      tri_lcb_clkoff_dc_b            => clkoff_b,    
      tri_lcb_act_dis_dc             => tilo,        
      
      abist_en                       => pc_fu_abist_ena_dc             ,
      abist_raw_dc_b                 => pc_fu_abist_raw_dc_b           ,
      r0e_abist_comp_en              => r0e_abist_comp_en              ,
      r1e_abist_comp_en              => r1e_abist_comp_en              ,
      lbist_en                       => an_ac_lbist_ary_wrt_thru_dc    ,  
      lcb_act_dis_dc                 => Alcb_act_dis_dc                 ,
      lcb_clkoff_dc_b                => lcb_clkoff_dc_b                 ,
      lcb_d_mode_dc                  => Alcb_d_mode_dc                  ,
      lcb_delay_lclkr_dc             => lcb_delay_lclkr_dc             ,
      lcb_fce_0                      => fce_0                          ,
      lcb_mpw1_dc_b                  => lcb_mpw1_dc_b                  ,
      lcb_mpw2_dc_b                  => lcb_mpw2_dc_b                  ,
      lcb_scan_diag_dc               => scan_diag_dc                   ,
      lcb_scan_dis_dc_b              => scan_dis_dc_b                  ,
      lcb_sg_0                       => lcb_sg_0                       ,
      lcb_time_sg_0                  => lcb_sg_0                       ,
      lcb_abst_sl_thold_0            => lcb_abst_sl_thold_0            ,
      lcb_time_sl_thold_0            => time_sl_thold_0            ,
      lcb_obs0_sg_0                  => lcb_obs0_sg_0                  ,
      lcb_obs1_sg_0                  => lcb_obs1_sg_0                  ,
      lcb_obs0_sl_thold_0            => lcb_obs0_sl_thold_0            ,
      lcb_obs1_sl_thold_0            => lcb_obs1_sl_thold_0            ,
      lcb_ary_nsl_thold_0            => ary_nsl_thold_0                ,
      r_scan_in                      => r_scan_in_1                    ,
      r_scan_out                     => r_scan_out_1                   ,
      w_scan_in                      => w_scan_in_1                    ,
      w_scan_out                     => w_scan_out_1                   ,
      time_scan_in                   => fpr_time_si(1)                 ,
      time_scan_out                  => fpr_time_so(1)                 ,
      obs0_scan_in                   => obs0_scan_in(1)                ,
      obs0_scan_out                  => obs0_scan_out(1)               ,
      obs1_scan_in                   => obs1_scan_in(1)                ,
      obs1_scan_out                  => obs1_scan_out(1)               ,
      -- Read Port FRB
      r0e_act                        => r0e_frb_act                        ,
      r0e_en_func                    => r0e_frb_en_func                    ,
      r0e_en_abist                   => r0e_en_abist                   ,
      r0e_addr_func                  => rf0_frb_addr                   ,
      r0e_addr_abist                 => r0e_addr_abist                 ,
      r0e_data_out                   => frb_data_out                   ,
      r0e_byp_e                      => rf1_bypsel_b_load1_nlb       ,
      r0e_byp_l                      => rf1_bypsel_b_res1_nlb        ,
      r0e_byp_r                      => rf1_b_r0e_byp_r,  
      r0e_sel_lbist                  => r0e_sel_lbist                  ,
      -- Read Port FRS
      r1e_act                        => r1e_frs_act                        ,
      r1e_en_func                    => r1e_frs_en_func                    ,
      r1e_en_abist                   => r1e_en_abist                   ,
      r1e_addr_func                  => rf0_frs_addr                   ,
      r1e_addr_abist                 => r1e_addr_abist                 ,
      r1e_data_out                   => frs_data_out                   ,
      r1e_byp_e                      => rf1_bypsel_s_load1_nlb         ,
      r1e_byp_l                      => rf1_bypsel_s_res1_nlb          ,
      r1e_byp_r                      => rf1_s_r1e_byp_r,      
      r1e_sel_lbist                  => r1e_sel_lbist                  ,
      -- Write Ports
      w0e_act                        => w0e_act                        ,
      w0e_en_func                    => w0e_en_func                    ,
      w0e_en_abist                   => w0e_en_abist                   ,
      w0e_addr_func                  => w0e_addr_func                  ,
      w0e_addr_abist                 => w0e_addr_abist                 ,
      w0e_data_func                  => w0e_data_func_f1               ,
      w0e_data_abist                 => w0e_data_abist                 ,
      w0l_act                        => w0l_act                        ,
      w0l_en_func                    => w0l_en_func                    ,
      w0l_en_abist                   => w0l_en_abist                   ,
      w0l_addr_func                  => w0l_addr_func                  ,
      w0l_addr_abist                 => w0l_addr_abist                 ,
      w0l_data_func                  => w0l_data_func_f1               ,
      w0l_data_abist                 => w0l_data_abist                 
      );

   -- ABIST timing latches
   ab_reg: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 53, needs_sreset => 0)
   port map (nclk    => nclk,
             act     => pc_fu_abist_ena_dc,
             forcee => ab_force,
             delay_lclkr => delay_lclkra(0),
             mpw1_b      => mpw1_ba(0),
             mpw2_b      => mpw2_b(0),
             thold_b => ab_thold_0_b,
             sg      => sg_0,
             vd      => vdd,
             gd      => gnd,
             scin    => ab_reg_si(0 to 52),
             scout   => ab_reg_so(0 to 52),
             din ( 0 to  3) => pc_fu_abist_di_0(0 to 3)   ,
             din ( 4 to  7) => pc_fu_abist_di_1(0 to 3)   ,
             din (       8) => pc_fu_abist_grf_renb_0     ,
             din (       9) => pc_fu_abist_grf_renb_1     ,
             din (      10) => pc_fu_abist_grf_wenb_0     ,
             din (      11) => pc_fu_abist_grf_wenb_1     ,
             din (12 to 21) => pc_fu_abist_raddr_0(0 to 9),
             din (22 to 31) => pc_fu_abist_raddr_1(0 to 9),
             din (32 to 41) => pc_fu_abist_waddr_0(0 to 9),
             din (42 to 51) => pc_fu_abist_waddr_1(0 to 9),
             din (      52) => pc_fu_abist_wl144_comp_ena ,
             dout( 0 to  3) => w0e_data_abist(0 to 3)     ,
             dout( 4 to  7) => w0l_data_abist(0 to 3)     ,
             dout(       8) => r0e_en_abist               ,
             dout(       9) => r1e_en_abist               ,
             dout(      10) => w0e_en_abist               ,
             dout(      11) => w0l_en_abist               ,
             dout(12 to 21) =>       abist_raddr_0(0 to 9),
             dout(22 to 31) =>       abist_raddr_1(0 to 9),
             dout(32 to 41) =>       abist_waddr_0(0 to 9),
             dout(42 to 51) =>       abist_waddr_1(0 to 9),
             dout(      52) => abist_comp_en              );

lcbctrlA : entity tri.tri_lcbcntl_array_mac
  generic map( expand_type => expand_type )
  port map(
        vdd            => vdd,
        gnd            => gnd,
        sg             => sg_0,
        nclk           => nclk,
        scan_in        => gptr_scan_in,
        scan_diag_dc   => scan_diag_dc,
        thold          => gptr_sl_thold_0, --Connects to time thold
        clkoff_dc_b    => Aclkoff_dc_b,
        delay_lclkr_dc => Alcb_delay_lclkr_dc(0 to 4),
        act_dis_dc     => Alcb_act_dis_dc,
        d_mode_dc      => Ad_mode_dc,
        mpw1_dc_b      => Alcb_mpw1_dc_b(0 to 4),
        mpw2_dc_b      => Alcb_mpw2_dc_b,
        scan_out       => gptr_scan_out  -- Connects to time scan ring
       );



   lcb_mpw2_dc_b <= Alcb_mpw2_dc_b;

      --0 lcb_delay_lclkr_dc(0,2)	--> Are driving L2 LCBs
      --1 lcb_delay_lclkr_dc(1,3)	--> Are driving L1 LCBs
      --2 lcb_delay_lclkr_dc(4)	--> Is driving the late write clock LCB
      --3 lcb_delay_lclkr_dc(5:9)	--> Are driving nLCBs
      --Similar for mpw1 signals:
      --0 lcb_mpw1_dc_b(2)	--> unused
      --1 lcb_mpw1_dc_b(1,3)	--> Driving L1 LCBs
      --2 lcb_mpw1_dc_b(4)	--> Is driving the late write clock LCB
      --3 lcb_mpw1_dc_b(5:9)	--> Are driving nLCBs

   lcb_delay_lclkr_dc(0)      <= Alcb_delay_lclkr_dc(0) ;
   lcb_delay_lclkr_dc(1)      <= Alcb_delay_lclkr_dc(1) ;
   lcb_delay_lclkr_dc(2)      <= Alcb_delay_lclkr_dc(0) ;
   lcb_delay_lclkr_dc(3)      <= Alcb_delay_lclkr_dc(1) ;
   lcb_delay_lclkr_dc(4)      <= Alcb_delay_lclkr_dc(2) ;
   lcb_delay_lclkr_dc(5)      <= Alcb_delay_lclkr_dc(3) ;
   lcb_delay_lclkr_dc(6)      <= Alcb_delay_lclkr_dc(4) ;
   lcb_delay_lclkr_dc(7)      <= Alcb_delay_lclkr_dc(4) ;
   lcb_delay_lclkr_dc(8)      <= Alcb_delay_lclkr_dc(3) ;
   lcb_delay_lclkr_dc(9)      <= Alcb_delay_lclkr_dc(3) ;

   lcb_mpw1_dc_b(1)           <= Alcb_mpw1_dc_b     (1) ;
   lcb_mpw1_dc_b(2)           <= Alcb_mpw1_dc_b     (0) ;
   lcb_mpw1_dc_b(3)           <= Alcb_mpw1_dc_b     (1) ;
   lcb_mpw1_dc_b(4)           <= Alcb_mpw1_dc_b     (2) ;
   lcb_mpw1_dc_b(5)           <= Alcb_mpw1_dc_b     (3) ;
   lcb_mpw1_dc_b(6)           <= Alcb_mpw1_dc_b     (4) ;
   lcb_mpw1_dc_b(7)           <= Alcb_mpw1_dc_b     (4) ;
   lcb_mpw1_dc_b(8)           <= Alcb_mpw1_dc_b     (3) ;
   lcb_mpw1_dc_b(9)           <= Alcb_mpw1_dc_b     (3) ;

   lcb_obs0_sg_0                  <= sg_0                ;
   lcb_obs1_sg_0                  <= sg_0                ;
   lcb_obs0_sl_thold_0            <= ab_thold_0          ;
   lcb_obs1_sl_thold_0            <= ab_thold_0          ;

   -- Other inputs
    r0e_abist_comp_en              <= abist_comp_en;
    r1e_abist_comp_en              <= abist_comp_en;

    lcb_sg_0                       <= sg_0;
    lcb_abst_sl_thold_0            <= ab_thold_0;

    Alcb_d_mode_dc                  <= Ad_mode_dc;

    lcb_clkoff_dc_b                 <= Aclkoff_dc_b & Aclkoff_dc_b;

    r0e_frb_act                    <= iu_fu_rf0_frb_v or f_dcd_perr_sm_running or lbist_en_dc; --ports BC used by perrsm
    r0e_frb_en_func                <= iu_fu_rf0_frb_v or f_dcd_perr_sm_running or lbist_en_dc;
    r0e_fra_act                    <= iu_fu_rf0_fra_v or lbist_en_dc;
    r0e_fra_en_func                <= iu_fu_rf0_fra_v or lbist_en_dc;

    r1e_frs_act                    <= iu_fu_rf0_str_v or lbist_en_dc;
    r1e_frs_en_func                <= iu_fu_rf0_str_v or lbist_en_dc;
    r1e_frc_act                    <= iu_fu_rf0_frc_v or f_dcd_perr_sm_running or lbist_en_dc;
    r1e_frc_en_func                <= iu_fu_rf0_frc_v or f_dcd_perr_sm_running or lbist_en_dc;

    r0e_addr_abist(0 to 7)         <= abist_raddr_0(2 to 9); 
    r1e_addr_abist(0 to 7)         <= abist_raddr_1(2 to 9); 

    w0e_addr_abist(0 to 7)         <= abist_waddr_0(2 to 9); 
    w0l_addr_abist(0 to 7)         <= abist_waddr_1(2 to 9);

    r0e_sel_lbist                  <= an_ac_lbist_ary_wrt_thru_dc; 
    r1e_sel_lbist                  <= an_ac_lbist_ary_wrt_thru_dc; 

------------------------------------------------------------------------
-- Parity Checking


   ex1_par: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 33, needs_sreset => 0)
   port map (nclk    => nclk,
             act     => f_dcd_msr_fp_act,
             forcee => forcee,
             delay_lclkr => delay_lclkra(1),
             mpw1_b      => mpw1_ba(1),
             mpw2_b      => mpw2_b(0),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd      => vdd,
             gd      => gnd,
             scin    => ex1_par_si(0 to 32),
             scout   => ex1_par_so(0 to 32),
             din ( 0 to  7) => rf1_fra(0 to 7)   ,
             din ( 8 to 15) => rf1_frb(0 to 7)   ,
             din (16 to 23) => rf1_frc(0 to 7)   ,
             din (24 to 31) => rf1_frs(0 to 7)   ,
             din (32)       => rf1_frs(13)          ,

             dout( 0 to  7) => ex1_fra_par(0 to 7) ,
             dout( 8 to 15) => ex1_frb_par(0 to 7) ,
             dout(16 to 23) => ex1_frc_par(0 to 7) ,
             dout(24 to 31) => ex1_frs_par(0 to 7) ,
             dout(32)       => ex1_s_expo_extra    );


   f_fpr_ex1_a_par(0 to 7) <= ex1_fra_par(0 to 7);
   f_fpr_ex1_b_par(0 to 7) <= ex1_frb_par(0 to 7);
   f_fpr_ex1_c_par(0 to 7) <= ex1_frc_par(0 to 7);
   f_fpr_ex1_s_par(0 to 7) <= ex1_frs_par(0 to 7);


------------------------------------------------------------------------
-- Outputs

   --parity(0 to 7)<= data(66 to 73)    0:7
   --"000"                              8:10
   --sign          <= data(0);          11
   --expo(1)                            12
   --expo(2 to 13) <= data(1 to 12);    13:24
   --frac(0 to 52) <= data(13 to 65);   25:77

   f_fpr_rf1_a_sign           <= rf1_fra(11);
   f_fpr_rf1_a_expo(1 to 13)  <= rf1_fra(12 to 24);
   f_fpr_rf1_a_frac(0 to 52)  <= rf1_fra(25 to 77);
   f_fpr_rf1_c_sign           <= rf1_frc(11);
   f_fpr_rf1_c_expo(1 to 13)  <= rf1_frc(12 to 24);
   f_fpr_rf1_c_frac(0 to 52)  <= rf1_frc(25 to 77);
   f_fpr_rf1_b_sign           <= rf1_frb(11);
   f_fpr_rf1_b_expo(1 to 13)  <= rf1_frb(12 to 24);
   f_fpr_rf1_b_frac(0 to 52)  <= rf1_frb(25 to 77);

   f_fpr_rf1_s_sign           <=        rf1_frs(11);
   f_fpr_rf1_s_expo(1 to 11)  <=        rf1_frs(14 to 24);
   f_fpr_rf1_s_frac(0 to 52)  <=        rf1_frs(25 to 77);
   -- For Parity checking only, not used by store
   f_fpr_ex1_s_expo_extra     <=        ex1_s_expo_extra;



------------------------------------------------------------------------
-- Spare Latches

   spare_lat: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 8)
   port map (nclk    => nclk,
             act     => f_dcd_msr_fp_act,
             forcee => forcee,
             delay_lclkr => delay_lclkra(0),
             mpw1_b      => mpw1_ba(0),
             mpw2_b      => mpw2_b(0),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => spare_si(0 to 7),
             scout   => spare_so(0 to 7),
             din( 0 to  7)  => SPARE_L2(0 to 7) ,
            ---------------------------------------------
             dout( 0 to  7) => SPARE_L2(0 to 7)        
            ---------------------------------------------
             );

   spare_lat_time: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 2)
   port map (nclk    => nclk,
             act     => tihi,
             forcee => time_force,
             delay_lclkr => delay_lclkra(0),
             mpw1_b      => mpw1_ba(0),
             mpw2_b      => mpw2_b(0),
             thold_b => time_sl_thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => time_spare_si(0 to 1),
             scout   => time_spare_so(0 to 1),
             din( 0 to  1)  => time_SPARE_L2(0 to 1) ,
            ---------------------------------------------
             dout( 0 to  1) => time_SPARE_L2(0 to 1)        
            ---------------------------------------------
             );



lcbs_abst: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkra(0),
      nclk        => nclk,
      forcee => ab_force,
      thold_b     => ab_thold_0_b,
      dclk        => abst_slat_d2clk,
      lclk        => abst_slat_lclk );
bx_abst_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => abst_slat_d2clk,
              lclk  => abst_slat_lclk,
              scan_in(0)   => bx_fu_rp_abst_scan_out,
              scan_in(1)   => rp_bx_abst_scan_in,
              scan_out(0)  => bx_rp_abst_scan_out,
              scan_out(1)  => rp_fu_bx_abst_scan_in );


lcbs_func: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkra(0),
      nclk        => nclk,
      forcee => forcee,
      thold_b     => thold_0_b,
      dclk        => func_slat_d2clk,
      lclk        => func_slat_lclk );
bx_func_stg: tri_slat_scan  
   generic map (width => 4, init => "0000", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => func_slat_d2clk,
              lclk  => func_slat_lclk,
              scan_in(0 to 1)  => bx_fu_rp_func_scan_out,
              scan_in(2 to 3)  => rp_bx_func_scan_in,
              scan_out(0 to 1) => bx_rp_func_scan_out,
              scan_out(2 to 3) => rp_fu_bx_func_scan_in );

------------------------------------------------------------------------
-- Scan Chains



   ex7_ldat_si (0 to 63)                <= ex7_ldat_so (1 to 63) & f_fpr_si;
   ex7_ldv_si  (0 to 3)                 <= ex7_ldv_so  (1 to 3)  & ex7_ldat_so (0);
   ex7_lctl_si (0 to 9)                 <= ex7_lctl_so (1 to 9)  & ex7_ldv_so  (0);
   ex6_ldv_si  (0 to 3)                 <= ex6_ldv_so  (1 to 3)  & ex7_lctl_so (0);   
   ex6_lctl_si (0 to 13)                <= ex6_lctl_so (1 to 13) & ex6_ldv_so (0);   
   ex1_par_si  (0 to 32)                <= ex1_par_so  (1 to 32) & ex6_lctl_so(0);
   ex1_dcd_si(0 to 7)                   <= ex1_dcd_so  (1 to 7)  & ex1_par_so  (0);
   spare_si  (0 to 7)                   <= spare_so(1 to 7)      & ex1_dcd_so  (0);
   f_fpr_so                             <= spare_so  (0);

   ab_reg_si   (0 to 7)                 <= ab_reg_so   (1 to 7) & f_fpr_ab_si; --broke up for timing
   r_scan_in_0                          <= ab_reg_so(0);
   w_scan_in_0                          <= r_scan_out_0;
   r_scan_in_1                          <= w_scan_out_0;
   w_scan_in_1                          <= r_scan_out_1;
   obs0_scan_in(0 to 1)                 <= obs0_scan_out(1) & w_scan_out_1;
   obs1_scan_in(0 to 1)                 <= obs1_scan_out(1) & obs0_scan_out(0);

   ab_reg_si   (8 to 52)                <= ab_reg_so   (9 to 52) & obs1_scan_out(0);
   f_fpr_ab_so                          <= ab_reg_so(8);

   --Time scan ring
   time_spare_si(0)                     <= time_scan_in;
   fpr_time_si(0 to 1)                  <= fpr_time_so(1) & time_spare_so(0);
   time_spare_si(1)                     <= fpr_time_so(0);
   time_scan_out                        <= time_spare_so(1);

------------------------------------------------------------------------
-- Unused

   spare_unused( 0 to  2) <= iu_fu_rf0_ldst_tag(0 to 2);
   spare_unused( 3 to  5) <= rf1_fra(8 to 10);
   spare_unused( 6 to  8) <= rf1_frb(8 to 10);
   spare_unused( 9 to 11) <= rf1_frc(8 to 10);
   spare_unused(12 to 14) <= rf1_frs(8 to 10);

   spare_unused(15 to 16) <= abist_raddr_0(0 to 1);
   spare_unused(17 to 18) <= abist_raddr_1(0 to 1);
   spare_unused(19 to 20) <= abist_waddr_0(0 to 1);
   spare_unused(21 to 22) <= abist_waddr_1(0 to 1);

   spare_unused(23)       <= Alcb_mpw1_dc_b(4);
   spare_unused(24)       <= Alcb_delay_lclkr_dc(4);
   spare_unused(25)       <= rf1_frs(12);
   spare_unused(26)       <= an_ac_abist_mode_dc;


   
------------------------------------------------------------------------
-- END

end architecture fuq_fpr;
