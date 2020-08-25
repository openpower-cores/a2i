-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--
--*****************************************************************************
--*
--*  TITLE: uc_hooks
--*
--*  NAME:  fuq_dcd_uc_hooks.vhdl
--*
--*  DESC:   This is for microcoded Divide and Square Root
--*
--*****************************************************************************




library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 

---------------------------------------------------------------------


entity fuq_dcd_uc_hooks is
generic(expand_type                    : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
   	nclk                                 	: in  clk_logic;                
        thold_0_b                             	: in  std_ulogic;
        sg_0                                	: in  std_ulogic;
        f_ucode_si                           	: in  std_ulogic;           
        forcee : in  std_ulogic; -- tidn,
        delay_lclkr                    : in  std_ulogic; -- tidn,
        mpw1_b                         : in  std_ulogic; -- tidn,
        mpw2_b                         : in  std_ulogic; -- tidn,
        vdd                                 	: inout power_logic;
        gnd                                 	: inout power_logic;
        msr_fp_act                              : in    std_ulogic;
        perr_sm_running                         : in    std_ulogic;
        ---------------------------------------------------------------
        iu_fu_rf0_instr_v                       : in  std_ulogic;                  
        iu_fu_rf0_instr                         : in  std_ulogic_vector(0 to 31);  
        iu_fu_rf0_ucfmul                        : in  std_ulogic;
        ucode_mode_rf0                  	: in  std_ulogic;                  
        f_mad_ex3_uc_round_mode                 : in  std_ulogic_vector(0 to 1);   
        rf0_instr_fra                           : in  std_ulogic_vector(0 to 5);   
        f_dcd_rf0_fra                           : out std_ulogic_vector(0 to 5);   
        iu_fu_rf0_ifar                          : in  std_ulogic_vector(58 to 61); 
        thread_id_rf0                           : in  std_ulogic_vector(0 to 3);   
        xu_rf0_flush                            : in  std_ulogic_vector(0 to 3);   
        xu_rf1_flush                            : in  std_ulogic_vector(0 to 3);
        xu_ex1_flush                            : in  std_ulogic_vector(0 to 3);
        xu_ex2_flush                            : in  std_ulogic_vector(0 to 3);
        xu_ex3_flush                            : in  std_ulogic_vector(0 to 3);
        xu_ex4_flush                            : in  std_ulogic_vector(0 to 3);
        xu_ex5_flush                            : in  std_ulogic_vector(0 to 3);
        f_mad_ex6_uc_sign, f_mad_ex6_uc_zero    : in  std_ulogic;                  
        f_mad_ex3_uc_special                    : in  std_ulogic;                  
        f_mad_ex3_uc_vxsnan                     : in  std_ulogic;                  
        f_mad_ex3_uc_zx                         : in  std_ulogic;                  
        f_mad_ex3_uc_vxidi                      : in  std_ulogic;                  
        f_mad_ex3_uc_vxzdz                      : in  std_ulogic;                  
        f_mad_ex3_uc_vxsqrt                     : in  std_ulogic;                  
        f_mad_ex3_uc_res_sign                   : in  std_ulogic;                  
        uc_ignore_flush_rf1                     : out std_ulogic;                  
        f_dcd_rf1_div_beg                       : out std_ulogic;                  
        f_dcd_rf1_sqrt_beg                      : out std_ulogic;                  
        f_dcd_rf1_uc_mid                        : out std_ulogic;                  
        f_dcd_rf1_uc_end                        : out std_ulogic;                  
        ex4_uc_special                          : out std_ulogic;   -- to block iterations in fuq_axu_fu_dep (is1)
        f_dcd_rf1_uc_special                    : out std_ulogic;                  
        f_dcd_rf1_uc_ft_pos                     : out std_ulogic;                  
        f_dcd_rf1_uc_ft_neg                     : out std_ulogic;                  
        f_dcd_rf1_uc_fa_pos                     : out std_ulogic;                  
        f_dcd_rf1_uc_fc_pos                     : out std_ulogic;                  
        f_dcd_rf1_uc_fb_pos                     : out std_ulogic;                  
        f_dcd_rf1_uc_fc_hulp                    : out std_ulogic;                  
        f_dcd_rf1_uc_fc_0_5                     : out std_ulogic;                  
        f_dcd_rf1_uc_fc_1_0                     : out std_ulogic;                  
        f_dcd_rf1_uc_fc_1_minus                 : out std_ulogic;                  
        f_dcd_rf1_uc_fb_1_0                     : out std_ulogic;                  
        f_dcd_rf1_uc_fb_0_75                    : out std_ulogic;                  
        f_dcd_rf1_uc_fb_0_5                     : out std_ulogic;                  
        f_dcd_rf1_uc_fa_dis_par                 : out std_ulogic;                  
        f_dcd_rf1_uc_fb_dis_par                 : out std_ulogic;                  
        f_dcd_rf1_uc_fc_dis_par                 : out std_ulogic;                  
        uc_op_rnd_v_rf1                         : out std_ulogic;                  
        uc_op_rnd_rf1                           : out std_ulogic_vector(0 to 1);   
        f_dcd_ex2_uc_inc_lsb                    : out std_ulogic;                  
        f_dcd_ex2_uc_gs_v                       : out std_ulogic;                  
        f_dcd_ex2_uc_gs                         : out std_ulogic_vector(0 to 1);   
        f_dcd_ex2_uc_vxsnan                     : out std_ulogic;                  
        f_dcd_ex2_uc_zx                         : out std_ulogic;                  
        f_dcd_ex2_uc_vxidi                      : out std_ulogic;                  
        f_dcd_ex2_uc_vxzdz                      : out std_ulogic;                  
        f_dcd_ex2_uc_vxsqrt                     : out std_ulogic;                  
        uc_hooks_rc_rf0                         : out std_ulogic;                  
        uc_hooks_debug                          : out std_ulogic_vector(0 to 55); 
        evnt_div_sqrt_ip                        : out std_ulogic_vector(0 to 3); 
        f_ucode_so                           	: out std_ulogic              
                                                               
);

  -- synopsys translate_off

  
 
   -- synopsys translate_on

end fuq_dcd_uc_hooks;


architecture fuq_dcd_uc_hooks of fuq_dcd_uc_hooks is
  
    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';



signal uc_sign_zero_t0, uc_scr_t0_ld, uc_scr_t0_l2, uc_scr_t0_scin, uc_scr_t0_scout   : std_ulogic_vector(0 to 11);
signal uc_sign_zero_t1, uc_scr_t1_ld, uc_scr_t1_l2, uc_scr_t1_scin, uc_scr_t1_scout   : std_ulogic_vector(0 to 11);
signal uc_sign_zero_t2, uc_scr_t2_ld, uc_scr_t2_l2, uc_scr_t2_scin, uc_scr_t2_scout   : std_ulogic_vector(0 to 11);
signal uc_sign_zero_t3, uc_scr_t3_ld, uc_scr_t3_l2, uc_scr_t3_scin, uc_scr_t3_scout   : std_ulogic_vector(0 to 11);
signal uc_scr_t0_upd, uc_scr_t1_upd, uc_scr_t2_upd, uc_scr_t3_upd : std_ulogic_vector(0 to 4);

signal uc_scr_wr, uc_scr_wr_rf0                          : std_ulogic;
signal uc_scr_sel, uc_scr_thread_rf0                     : std_ulogic_vector(0 to 1);

signal uc_scr_wr_pipe_rf1_scin, uc_scr_wr_pipe_rf1_scout : std_ulogic_vector(0 to 7);
signal uc_scr_wr_rf1                                     : std_ulogic;
signal uc_scr_sel_rf1, uc_scr_thread_rf1                 : std_ulogic_vector(0 to 1);

signal uc_scr_wr_pipe_ex1_scin, uc_scr_wr_pipe_ex1_scout : std_ulogic_vector(0 to 8);
signal uc_scr_wr_ex1                                     : std_ulogic;
signal uc_scr_sel_ex1, uc_scr_thread_ex1                 : std_ulogic_vector(0 to 1);

signal uc_scr_wr_pipe_ex2_scin, uc_scr_wr_pipe_ex2_scout : std_ulogic_vector(0 to 8);
signal uc_scr_wr_ex2                                     : std_ulogic;
signal uc_scr_sel_ex2, uc_scr_thread_ex2                 : std_ulogic_vector(0 to 1);

signal uc_scr_wr_pipe_ex3_scin, uc_scr_wr_pipe_ex3_scout : std_ulogic_vector(0 to 6);
signal uc_scr_wr_ex3                                     : std_ulogic;
signal uc_scr_sel_ex3, uc_scr_thread_ex3                 : std_ulogic_vector(0 to 1);

signal uc_scr_wr_pipe_ex4_scin, uc_scr_wr_pipe_ex4_scout : std_ulogic_vector(0 to 6);
signal uc_scr_wr_ex4                                     : std_ulogic;
signal uc_scr_sel_ex4, uc_scr_thread_ex4                 : std_ulogic_vector(0 to 1);

signal uc_scr_wr_pipe_ex5_scin, uc_scr_wr_pipe_ex5_scout : std_ulogic_vector(0 to 5);
signal uc_scr_wr_ex5                                     : std_ulogic;
signal uc_scr_sel_ex5, uc_scr_thread_ex5                 : std_ulogic_vector(0 to 1);

signal uc_scr_wr_pipe_ex6_scin, uc_scr_wr_pipe_ex6_scout : std_ulogic_vector(0 to 5);
signal uc_scr_wr_ex6                                     : std_ulogic;
signal uc_scr_sel_ex6, uc_scr_thread_ex6                 : std_ulogic_vector(0 to 1);

signal uc_scr_wr_rf1_l2                                  : std_ulogic;
signal uc_scr_wr_ex1_l2                                  : std_ulogic;
signal uc_scr_wr_ex2_l2                                  : std_ulogic;
signal uc_scr_wr_ex3_l2                                  : std_ulogic;
signal uc_scr_wr_ex4_l2                                  : std_ulogic;
signal uc_scr_wr_ex5_l2                                  : std_ulogic;

signal q1r_sign_rf0, q1r_zero_rf0                        : std_ulogic;
signal q1ulpr_zero_rf0                                   : std_ulogic;
signal q1_m_ulp_rf0                                      : std_ulogic;
signal uc_beg_rf0, uc_beg_rf0_v                          : std_ulogic;
signal uc_beg_rf1                                        : std_ulogic;
signal uc_beg_ex1                                        : std_ulogic;
signal uc_beg_ex2                                        : std_ulogic;
signal uc_beg_ex3                                        : std_ulogic;
signal uc_beg_ex4                                        : std_ulogic;
signal uc_end_rf0,        uc_end_rf0_v, uc_end_rf0_vf    : std_ulogic;
signal uc_normal_end_rf0, uc_normal_end_rf0_part         : std_ulogic;
signal uc_fa_pos                                         : std_ulogic;   
signal uc_fc_pos                                         : std_ulogic;   
signal uc_fc_pos_rf0                                     : std_ulogic;   
signal uc_fb_pos                                         : std_ulogic; 
signal uc_fc_hulp                                        : std_ulogic;
signal uc_fc_0_5                                         : std_ulogic;
signal uc_fc_1_0                                         : std_ulogic;
signal uc_fc_1_minus                                     : std_ulogic;
signal uc_fb_1_0                                         : std_ulogic; 
signal uc_fb_0_75                                        : std_ulogic; 
signal uc_fb_0_5                                         : std_ulogic; 
signal uc_op_rnd_v                                       : std_ulogic; 
signal uc_op_rnd                                         : std_ulogic_vector(0 to 1);     
signal uc_inc_lsb                                        : std_ulogic; 
signal uc_gs_v_rf0                                       : std_ulogic;
signal uc_1st_instr_ld                                   : std_ulogic_vector(0 to 3);
signal uc_1st_instr_l2                                   : std_ulogic_vector(0 to 3);
signal uc_1st_instr_scin                                 : std_ulogic_vector(0 to 3);
signal uc_1st_instr_scout                                : std_ulogic_vector(0 to 3);
signal uc_div_beg_rf0                                    : std_ulogic; 
signal uc_sqrt_beg_rf0                                   : std_ulogic;
signal uc_mid_rf0                                        : std_ulogic;
signal uc_div_beg_rf1                                    : std_ulogic;
signal uc_sqrt_beg_rf1                                   : std_ulogic;
signal pipe_rf1_scin                                     : std_ulogic_vector(0 to 21);
signal pipe_rf1_scout                                    : std_ulogic_vector(0 to 21);
signal fp_operation_rf0                                  : std_ulogic;
signal uc_special_cases_ex3                              : std_ulogic_vector(0 to 7);
signal uc_special_cases_t0_ex3                           : std_ulogic_vector(8 to 11);
signal uc_special_cases_t1_ex3                           : std_ulogic_vector(8 to 11);
signal uc_special_cases_t2_ex3                           : std_ulogic_vector(8 to 11);
signal uc_special_cases_t3_ex3                           : std_ulogic_vector(8 to 11);
signal uc_round_mode_ld                                  : std_ulogic_vector(0 to 7);
signal uc_round_mode_l2                                  : std_ulogic_vector(0 to 7);
signal uc_round_mode_scin                                : std_ulogic_vector(0 to 7);
signal uc_round_mode_scout                               : std_ulogic_vector(0 to 7);
signal uc_mid_rf1                                        : std_ulogic;
signal uc_end_rf1                                        : std_ulogic;
signal uc_end_rf1_v                                      : std_ulogic;
signal uc_end_ex1                                        : std_ulogic;
signal uc_end_ex2                                        : std_ulogic;
signal uc_end_ex3                                        : std_ulogic;
signal uc_end_ex4                                        : std_ulogic;
signal uc_end_ex5                                        : std_ulogic;
signal uc_end_rf1_l2                                     : std_ulogic;
signal uc_end_ex1_l2                                     : std_ulogic;
signal uc_end_ex2_l2                                     : std_ulogic;
signal uc_end_ex3_l2                                     : std_ulogic;
signal uc_end_ex4_l2                                     : std_ulogic;
signal uc_end_ex5_l2                                     : std_ulogic;
signal uc_end_ex6_l2                                     : std_ulogic;
signal uc_fa_pos_rf1                                     : std_ulogic;
signal uc_fc_pos_rf1                                     : std_ulogic;
signal uc_fb_pos_rf1                                     : std_ulogic;
signal uc_fc_hulp_rf1                                    : std_ulogic;
signal uc_fc_0_5_rf1                                     : std_ulogic;
signal uc_fc_1_0_rf1                                     : std_ulogic;
signal uc_fc_1_minus_rf1                                 : std_ulogic;
signal uc_fb_1_0_rf1                                     : std_ulogic;
signal uc_fb_0_75_rf1                                    : std_ulogic;
signal uc_fb_0_5_rf1                                     : std_ulogic;
signal uc_fa_dis_par_rf0, uc_fa_dis_par_rf1              : std_ulogic;
signal uc_fb_dis_par_rf0, uc_fb_dis_par_rf1              : std_ulogic;
signal uc_fc_dis_par_rf0, uc_fc_dis_par_rf1              : std_ulogic;
signal        uc_op_rnd_v_rf1_l2                         : std_ulogic;               
signal        uc_op_rnd_rf1_l2                           : std_ulogic_vector(0 to 1);

signal uc_inc_lsb_rf1                                    : std_ulogic; 
signal uc_gs_v_rf1                                       : std_ulogic;
signal special_rf1                                       : std_ulogic;
signal spare                                             : std_ulogic;
signal q1r_zero_ex2                                      : std_ulogic;
signal q1r_sign_ex2                                      : std_ulogic;
signal q1ulpr_sign_ex2                                   : std_ulogic;
signal q1ulpr_zero_ex2                                   : std_ulogic;
signal q1hulpr_sign_ex2                                  : std_ulogic;
signal uc_gs_ex2                                         : std_ulogic_vector(0 to 1);
signal uc_round_mode_ex2                                 : std_ulogic_vector(0 to 1);
signal uc_gs_v_ex1                                       : std_ulogic;
signal uc_gs_v_ex2                                       : std_ulogic;
signal uc_inc_lsb_ex1                                    : std_ulogic;
signal uc_inc_lsb_ex2                                    : std_ulogic;
signal res_sign_rf1                                      : std_ulogic;
signal uc_scr_wr_ex4_ld                                  : std_ulogic;
signal rf0_i                                             : std_ulogic_vector(0 to 31);
signal uc_fdiv_beg_rf0                                   : std_ulogic;
signal uc_fdivs_beg_rf0                                  : std_ulogic;
signal uc_fsqrt_beg_rf0                                  : std_ulogic;
signal uc_fsqrts_beg_rf0                                 : std_ulogic;
signal uc_op_rf0                                         : std_ulogic_vector(0 to 3);
signal q1_p_ulp_early_ld, q1_p_ulp_early_l2              : std_ulogic_vector(0 to 3);
signal q1_p_ulp_early_scin, q1_p_ulp_early_scout         : std_ulogic_vector(0 to 3);

signal rf1_ucfmul                                        : std_ulogic;

signal fmulx_uc_rf0, uc_dvsq_beg_rf0                     : std_ulogic;
signal uc_abort_rf0                                      : std_ulogic_vector(0 to 3);
signal rf0_instr_flush                                   : std_ulogic;
signal rf1_instr_flush                                   : std_ulogic;
signal ex1_instr_flush                                   : std_ulogic;
signal ex2_instr_flush                                   : std_ulogic;
signal ex3_instr_flush                                   : std_ulogic;
signal ex3_instr_flush_th                                : std_ulogic_vector(0 to 3);
signal ex4_instr_flush                                   : std_ulogic;
signal ex5_instr_flush                                   : std_ulogic;

 signal uc_scr_t0_fbk_x , uc_scr_t1_fbk_x , uc_scr_t2_fbk_x , uc_scr_t3_fbk_x :std_ulogic;
 signal uc_scr_t0_ld_x  , uc_scr_t1_ld_x  , uc_scr_t2_ld_x  , uc_scr_t3_ld_x  :std_ulogic_vector(0 to 11);

 signal uc_scr_t0_ld_x0_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t1_ld_x0_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t2_ld_x0_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t3_ld_x0_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t0_ld_x1_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t1_ld_x1_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t2_ld_x1_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t3_ld_x1_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t0_ld_x2_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t1_ld_x2_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t2_ld_x2_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t3_ld_x2_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t0_ld_x3_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t1_ld_x3_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t2_ld_x3_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t3_ld_x3_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t0_ld_x4_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t1_ld_x4_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t2_ld_x4_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t3_ld_x4_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t0_ld_xf_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t1_ld_xf_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t2_ld_xf_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t3_ld_xf_b  :std_ulogic_vector(0 to 11);
 signal uc_scr_t0_oth_b    :std_ulogic_vector(0 to 11);
 signal uc_scr_t1_oth_b    :std_ulogic_vector(0 to 11);
 signal uc_scr_t2_oth_b    :std_ulogic_vector(0 to 11);
 signal uc_scr_t3_oth_b    :std_ulogic_vector(0 to 11);


----------------------------------
signal uc_1st_v_th_b      :std_ulogic_vector(0 to 3);
signal fdiving_n1st_th    :std_ulogic_vector(0 to 3);
signal fdivsing_n1st_th   :std_ulogic_vector(0 to 3);
signal fsqrting_n1st_th   :std_ulogic_vector(0 to 3);
signal fsqrtsing_n1st_th  :std_ulogic_vector(0 to 3);
signal uc_mode_rf0_th     :std_ulogic_vector(0 to 3);
signal rf0_n1st_fdiving   :std_ulogic;
signal rf0_n1st_fdivsing  :std_ulogic;
signal rf0_n1st_fsqrting  :std_ulogic;
signal rf0_n1st_fsqrtsing :std_ulogic;
signal rf0_ifar_dcd       :std_ulogic_vector(1 to 12);
signal rf0_ifar_89        :std_ulogic;
signal rf0_ifar_45        :std_ulogic;
signal rf0_ifar_34        :std_ulogic;
signal rf0_ifar_78        :std_ulogic;
signal rf0_ifar_bc        :std_ulogic;
signal rf0_ifar_67        :std_ulogic;
signal rf0_ifar_ab        :std_ulogic;
signal rf0_ifar_ac        :std_ulogic;
signal rf0_ifar_57        :std_ulogic;
signal rf0_ifar_9b        :std_ulogic;
signal rf0_ifar_68        :std_ulogic;
signal rf0_ifar_abc       :std_ulogic;
signal rf0_ifar_567       :std_ulogic;
signal rf0_ifar_9ab       :std_ulogic;
signal rf0_ifar_678       :std_ulogic;
signal rf0_ifar_1245abc   :std_ulogic;
signal rf0_ifar_13456abc  :std_ulogic;
signal rf0_ifar_134567    :std_ulogic;
signal rf0_ifar_123c      :std_ulogic;
signal rf0_ifar_12        :std_ulogic;
signal rf0_ifar_13        :std_ulogic;

   signal q1_p_ulp_th :std_ulogic_vector(0 to 3);
   signal iu_fu_rf0_ucfmul_b :std_ulogic;
signal rf0_q1_p_ulp_mux0_b, rf0_q1_p_ulp_mux1_b, rf0_q1_p_ulp_mux :std_ulogic;
signal rf0_fra_fast_mux0_b, rf0_fra_fast_mux1_b, rf0_fra_fast_mux :std_ulogic_vector(4 to 4);
signal rf0_fra_fast_b, rf0_fra_fast :std_ulogic_vector(4 to 4);
 signal rf0_fra_fast_i_b, rf0_fra_fast_ii :std_ulogic_vector(4 to 4);

signal rf0_f2_dvsq , rf0_f2_dv , rf0_f2_sq , rf0_f2_mul :std_ulogic ;

 signal    spare_unused                    :  std_ulogic_vector(0 to 21);



begin

-- ucmode=0 on last iteration but uc_scr_t*_l2(7) won't have been cleared yet
uc_mid_rf0 <=  (uc_scr_t0_l2(7) and thread_id_rf0(0) and ucode_mode_rf0) or
               (uc_scr_t1_l2(7) and thread_id_rf0(1) and ucode_mode_rf0) or
               (uc_scr_t2_l2(7) and thread_id_rf0(2) and ucode_mode_rf0) or
               (uc_scr_t3_l2(7) and thread_id_rf0(3) and ucode_mode_rf0); 




-- update # of inputs and outputs   .i xx   .o xx
-- run "espvhdlexpand fuq_dcd_uc_hooks.vhdl > fuq_dcd_uc_hooks_new.vhdl" in a typescript to regenerate logic below table
--@@ ESPRESSO ABLE START @@
-- .i 9
-- .o 18
-- .ilb uc_1st_instr_rf0 fdiving_rf0 fdivsing_rf0 fsqrting_rf0 fsqrtsing_rf0 iu_fu_rf0_ifar(58)
-- iu_fu_rf0_ifar(59) iu_fu_rf0_ifar(60) iu_fu_rf0_ifar(61)
-- .ob uc_fa_pos uc_fc_pos uc_fb_pos uc_fc_0_5
-- uc_fc_hulp uc_fb_1_0 uc_fb_0_75 uc_fb_0_5 uc_fa_dis_par_rf0 uc_fb_dis_par_rf0 uc_fc_dis_par_rf0
-- uc_op_rnd_v uc_op_rnd(0) uc_op_rnd(1) uc_inc_lsb uc_scr_wr uc_scr_sel(0) uc_scr_sel(1)
-- .type fr
-- #
-- ##################################################################################################################################
-- #
-- #  uc_1st_instr_rf0                    # OUTPUTS ##################################################################################
-- #  |                                   0 1 2 3 4 5 6 7         8 9 10               11 12  13 14 15
-- #  |   fdiving_rf0                     uc_fa_pos                                     uc_op_rnd_v
-- #  |   | fdivsing_rf0                  | uc_fc_pos                                   | uc_op_rnd(0:1)
-- #  |   | |                             | | uc_fb_pos           uc_fa_dis_par_rf0     | |
-- #  |   | |  fsqrting_rf0               | | | uc_fc_0_5         | uc_fb_dis_par_rf0   | |
-- #  |   | |  | fsqrtsing_rf0            | | | | uc_fc_hulp      | | uc_fc_dis_par_rf0 | |  uc_inc_lsb
-- #  |   | |  | |                        | | | | | uc_fb_1_0     | | |                 | |  |
-- #  |   | |  | |  iu_fu_rf0_ifar        | | | | | | uc_fb_0_75  | | |                 | |  |   uc_scr_wr
-- #  |   | |  | |  |                     | | | | | | | uc_fb_0_5 | | |                 | |  |   | uc_scr_sel
-- #  |   | |  | |  |                     | | | | | | | |         | | |                 | |  |   | |
-- #  |   | |  | |  5566                  | | | | | | | |         | | |                 | |  |   | |
-- #  |   | |  | |  8901                  | | | | | | | |         | | |                 | |  |   | |
-- ########################################################################################################################################
-- #--------------------------------------------------------------------------------------------------------------------------- not div or sqrt
--    0   0 0  0 0  ----                  0 0 0 0 0 0 0 0         0 0 0                 0 -- 0   0 00
-- #--------------------------------------------------------------------------------------------------------------------------- shared
--    1   - -  - -  ----                  0 0 0 0 0 0 0 0         0 0 0                 0 00 0   0 00                             # fre for fdiv(s), frsqrte for fsqrt(s)		
-- #------ fdiv hooks --------------------------------------------------------------------------------------------------------- fdiv hooks
--    0   1 0  0 0  0001                  1 1 1 0 0 1 0 0         1 1 1                 1 00 0   0 00                             # fnmsub
--    0   1 0  0 0  0010                  1 1 0 0 0 0 0 0         1 0 1                 1 00 0   0 00                             # fmul		
--    0   1 0  0 0  0011                  0 0 1 0 0 0 0 1         0 1 1                 1 00 0   0 00                             # fmadd	
--    0   1 0  0 0  0100                  1 0 1 0 0 0 0 0         1 1 0                 1 00 0   0 00                             # fmadd	
--    0   1 0  0 0  0101                  1 0 1 0 0 0 0 0         1 1 0                 1 00 0   0 00                             # fnmsub
--    0   1 0  0 0  0110                  0 0 1 0 0 0 1 0         0 1 0                 1 00 0   0 00                             # fmadd	
--    0   1 0  0 0  0111                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   0 00                             # fmul		
--    0   1 0  0 0  1000                  0 0 0 0 0 0 0 0         0 0 0                 1 01 0   0 00                             # fmadd	
--    0   1 0  0 0  1001                  0 0 0 0 0 0 0 0         0 0 0                 1 01 1   0 00                             # fmadd	
--    0   1 0  0 0  1010                  1 0 1 0 0 0 0 0         1 1 0                 1 00 0   1 01                             # fnmsub
--    0   1 0  0 0  1011                  1 0 1 0 0 0 0 0         1 1 0                 1 00 0   1 10                             # fnmsub
--    0   1 0  0 0  1100                  1 0 1 0 1 0 0 0         1 1 1                 1 00 0   1 11                             # fnmsub
-- #  0   0 0  0 0  1101                  0 0 0 0 0 0 0 0         0 0 1                 0 -- 0   0 00                             # fmul_uc	
-- #------ fdivs hooks -------------------------------------------------------------------------------------------------------- fdivs hooks
--    0   0 1  0 0  0001                  1 1 1 0 0 1 0 0         1 1 1                 1 00 0   0 00                             # fnmsub
--    0   0 1  0 0  0010                  1 1 0 0 0 0 0 0         1 0 1                 1 00 0   0 00                             # fmul		
--    0   0 1  0 0  0011                  1 0 1 0 0 0 0 0         1 1 0                 1 01 0   0 00                             # fmadds	
--    0   0 1  0 0  0100                  1 0 1 0 0 0 0 0         1 1 0                 1 01 1   0 00                             # fmadds	
--    0   0 1  0 0  0101                  1 0 1 0 0 0 0 0         1 1 0                 1 00 0   1 01                             # fnmsub
--    0   0 1  0 0  0110                  1 0 1 0 0 0 0 0         1 1 0                 1 00 0   1 10                             # fnmsub
--    0   0 1  0 0  0111                  1 0 1 0 1 0 0 0         1 1 0                 1 00 0   1 11                             # fnmsub
-- #  0   0 0  0 0  1000                  0 0 0 0 0 0 0 0         0 0 0                 0 -- 0   0 00                             # fmuls_uc	
-- #------ fsqrt hooks -------------------------------------------------------------------------------------------------------- fsqrt hooks
--    0   0 0  1 0  0001                  0 1 0 1 0 0 0 0         0 0 1                 1 00 0   0 00                             # fmul		
--    0   0 0  1 0  0010                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   0 00                             # fmul		
--    0   0 0  1 0  0011                  0 0 1 0 0 0 0 1         0 1 1                 1 00 0   0 00                             # fnmsub
--    0   0 0  1 0  0100                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   0 00                             # fmadd	
--    0   0 0  1 0  0101                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   0 00                             # fmadd	
--    0   0 0  1 0  0110                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   0 00                             # fnmsub
--    0   0 0  1 0  0111                  0 0 0 0 0 0 0 0         0 0 0                 1 01 0   0 00                             # fmadd	
--    0   0 0  1 0  1000                  0 0 0 0 0 0 0 0         0 0 0                 1 01 1   0 00                             # fmadd	
--    0   0 0  1 0  1001                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   1 01                             # fnmsub
--    0   0 0  1 0  1010                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   1 10                             # fnmsub
--    0   0 0  1 0  1011                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   1 11                             # fnmsub
-- #  0   0 0  0 0  1100                  0 0 0 0 0 0 0 0         0 0 0                 0 -- 0   0 00                             # fmul_uc		
-- #------ fsqrts hooks ------------------------------------------------------------------------------------------------------- fsqrts hooks
--    0   0 0  0 1  0001                  0 1 0 1 0 0 0 0         0 0 1                 1 00 0   0 00                             # fmul		
--    0   0 0  0 1  0010                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   0 00                             # fmul		
--    0   0 0  0 1  0011                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   0 00                             # fnmsub
--    0   0 0  0 1  0100                  0 0 0 0 0 0 0 0         0 0 0                 1 01 0   0 00                             # fmadd	
--    0   0 0  0 1  0101                  0 0 0 0 0 0 0 0         0 0 0                 1 01 1   0 00                             # fmadd	
--    0   0 0  0 1  0110                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   1 01                             # fnmsub
--    0   0 0  0 1  0111                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   1 10                             # fnmsub
--    0   0 0  0 1  1000                  0 0 0 0 0 0 0 0         0 0 0                 1 00 0   1 11                             # fnmsub
-- #  0   0 0  0 0  1001                  0 0 0 0 0 0 0 0         0 0 0                 0 -- 0   0 00                             # fmuls_uc		
--
--
--
--
--
--
--
--
-- .e
--@@ ESPRESSO ABLE END @@

--///////////////////////////////////////////////////////////////////////
--// begin experiment
--///////////////////////////////////////////////////////////////////////

uc_1st_v_th_b(0) <= not( iu_fu_rf0_instr_v and uc_1st_instr_l2(0) );
uc_1st_v_th_b(1) <= not( iu_fu_rf0_instr_v and uc_1st_instr_l2(1) );
uc_1st_v_th_b(2) <= not( iu_fu_rf0_instr_v and uc_1st_instr_l2(2) );
uc_1st_v_th_b(3) <= not( iu_fu_rf0_instr_v and uc_1st_instr_l2(3) );


fdiving_n1st_th(0)   <= uc_scr_t0_l2(8)  and uc_1st_v_th_b(0) ;
fdiving_n1st_th(1)   <= uc_scr_t1_l2(8)  and uc_1st_v_th_b(1) ;
fdiving_n1st_th(2)   <= uc_scr_t2_l2(8)  and uc_1st_v_th_b(2) ;
fdiving_n1st_th(3)   <= uc_scr_t3_l2(8)  and uc_1st_v_th_b(3) ;
						    
fdivsing_n1st_th(0)  <= uc_scr_t0_l2(9)  and uc_1st_v_th_b(0) ;
fdivsing_n1st_th(1)  <= uc_scr_t1_l2(9)  and uc_1st_v_th_b(1) ;
fdivsing_n1st_th(2)  <= uc_scr_t2_l2(9)  and uc_1st_v_th_b(2) ;
fdivsing_n1st_th(3)  <= uc_scr_t3_l2(9)  and uc_1st_v_th_b(3) ;

fsqrting_n1st_th(0)  <= uc_scr_t0_l2(10) and uc_1st_v_th_b(0) ;
fsqrting_n1st_th(1)  <= uc_scr_t1_l2(10) and uc_1st_v_th_b(1) ;
fsqrting_n1st_th(2)  <= uc_scr_t2_l2(10) and uc_1st_v_th_b(2) ;
fsqrting_n1st_th(3)  <= uc_scr_t3_l2(10) and uc_1st_v_th_b(3) ;

fsqrtsing_n1st_th(0) <= uc_scr_t0_l2(11) and uc_1st_v_th_b(0) ;
fsqrtsing_n1st_th(1) <= uc_scr_t1_l2(11) and uc_1st_v_th_b(1) ;
fsqrtsing_n1st_th(2) <= uc_scr_t2_l2(11) and uc_1st_v_th_b(2) ;
fsqrtsing_n1st_th(3) <= uc_scr_t3_l2(11) and uc_1st_v_th_b(3) ;

uc_mode_rf0_th(0 to 3) <= thread_id_rf0(0 to 3) and (0 to 3=> ucode_mode_rf0 );


rf0_n1st_fdiving   <=  (uc_mode_rf0_th(0) and fdiving_n1st_th(0) ) or 
                       (uc_mode_rf0_th(1) and fdiving_n1st_th(1) ) or  
		  (uc_mode_rf0_th(2) and fdiving_n1st_th(2) ) or  
		  (uc_mode_rf0_th(3) and fdiving_n1st_th(3) ) ;

rf0_n1st_fdivsing  <=  (uc_mode_rf0_th(0) and fdivsing_n1st_th(0) ) or 
                       (uc_mode_rf0_th(1) and fdivsing_n1st_th(1) ) or  
	             (uc_mode_rf0_th(2) and fdivsing_n1st_th(2) ) or  
		   (uc_mode_rf0_th(3) and fdivsing_n1st_th(3) ) ;

rf0_n1st_fsqrting  <=  (uc_mode_rf0_th(0) and fsqrting_n1st_th(0) ) or 
                       (uc_mode_rf0_th(1) and fsqrting_n1st_th(1) ) or  
	             (uc_mode_rf0_th(2) and fsqrting_n1st_th(2) ) or  
		   (uc_mode_rf0_th(3) and fsqrting_n1st_th(3) ) ;

rf0_n1st_fsqrtsing <=  (uc_mode_rf0_th(0) and fsqrtsing_n1st_th(0) ) or 
                       (uc_mode_rf0_th(1) and fsqrtsing_n1st_th(1) ) or  
	             (uc_mode_rf0_th(2) and fsqrtsing_n1st_th(2) ) or  
		   (uc_mode_rf0_th(3) and fsqrtsing_n1st_th(3) ) ;



 rf0_ifar_dcd(1)  <= not iu_fu_rf0_ifar(58) and not iu_fu_rf0_ifar(59) and not iu_fu_rf0_ifar(60) and     iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(2)  <= not iu_fu_rf0_ifar(58) and not iu_fu_rf0_ifar(59) and     iu_fu_rf0_ifar(60) and not iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(3)  <= not iu_fu_rf0_ifar(58) and not iu_fu_rf0_ifar(59) and     iu_fu_rf0_ifar(60) and     iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(4)  <= not iu_fu_rf0_ifar(58) and     iu_fu_rf0_ifar(59) and not iu_fu_rf0_ifar(60) and not iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(5)  <= not iu_fu_rf0_ifar(58) and     iu_fu_rf0_ifar(59) and not iu_fu_rf0_ifar(60) and     iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(6)  <= not iu_fu_rf0_ifar(58) and     iu_fu_rf0_ifar(59) and     iu_fu_rf0_ifar(60) and not iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(7)  <= not iu_fu_rf0_ifar(58) and     iu_fu_rf0_ifar(59) and     iu_fu_rf0_ifar(60) and     iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(8)  <=     iu_fu_rf0_ifar(58) and not iu_fu_rf0_ifar(59) and not iu_fu_rf0_ifar(60) and not iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(9)  <=     iu_fu_rf0_ifar(58) and not iu_fu_rf0_ifar(59) and not iu_fu_rf0_ifar(60) and     iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(10) <=     iu_fu_rf0_ifar(58) and not iu_fu_rf0_ifar(59) and     iu_fu_rf0_ifar(60) and not iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(11) <=     iu_fu_rf0_ifar(58) and not iu_fu_rf0_ifar(59) and     iu_fu_rf0_ifar(60) and     iu_fu_rf0_ifar(61) ;
 rf0_ifar_dcd(12) <=     iu_fu_rf0_ifar(58) and     iu_fu_rf0_ifar(59) and not iu_fu_rf0_ifar(60) and not iu_fu_rf0_ifar(61) ;
 
 rf0_ifar_89       <= rf0_ifar_dcd(8)  or rf0_ifar_dcd(9)  ; 
 rf0_ifar_45       <= rf0_ifar_dcd(4)  or rf0_ifar_dcd(5)  ; 
 rf0_ifar_34       <= rf0_ifar_dcd(3)  or rf0_ifar_dcd(4)  ; 
 rf0_ifar_78       <= rf0_ifar_dcd(7)  or rf0_ifar_dcd(8)  ; 
 rf0_ifar_bc       <= rf0_ifar_dcd(11) or rf0_ifar_dcd(12) ; 
 rf0_ifar_67       <= rf0_ifar_dcd(6)  or rf0_ifar_dcd(7)  ; 
 rf0_ifar_ab       <= rf0_ifar_dcd(10) or rf0_ifar_dcd(11) ; 
 rf0_ifar_ac       <= rf0_ifar_dcd(10) or rf0_ifar_dcd(12) ; 
 rf0_ifar_57       <= rf0_ifar_dcd(5)  or rf0_ifar_dcd(7)  ; 
 rf0_ifar_9b       <= rf0_ifar_dcd(9)  or rf0_ifar_dcd(11) ; 
 rf0_ifar_68       <= rf0_ifar_dcd(6)  or rf0_ifar_dcd(8)  ; 
 rf0_ifar_abc      <= rf0_ifar_dcd(10) or rf0_ifar_dcd(11) or rf0_ifar_dcd(12)  ;  
 rf0_ifar_567      <= rf0_ifar_dcd(5)  or rf0_ifar_dcd(6)  or rf0_ifar_dcd(7)   ;  
 rf0_ifar_9ab      <= rf0_ifar_dcd(9)  or rf0_ifar_dcd(10) or rf0_ifar_dcd(11)  ;  
 rf0_ifar_678      <= rf0_ifar_dcd(6)  or rf0_ifar_dcd(7)  or rf0_ifar_dcd(8)   ;  
 rf0_ifar_1245abc  <= rf0_ifar_dcd(1)  or rf0_ifar_dcd(2) or rf0_ifar_dcd(4)  or rf0_ifar_dcd(5)                    or rf0_ifar_dcd(10) or rf0_ifar_dcd(11) or rf0_ifar_dcd(12);
 rf0_ifar_13456abc <= rf0_ifar_dcd(1)  or rf0_ifar_dcd(3) or rf0_ifar_dcd(4)  or rf0_ifar_dcd(5) or rf0_ifar_dcd(6) or rf0_ifar_dcd(10) or rf0_ifar_dcd(11) or rf0_ifar_dcd(12);
 rf0_ifar_134567   <= rf0_ifar_dcd(1)  or rf0_ifar_dcd(3) or rf0_ifar_dcd(4)  or rf0_ifar_dcd(5) or rf0_ifar_dcd(6) or rf0_ifar_dcd(7);
 rf0_ifar_123c     <= rf0_ifar_dcd(1)  or rf0_ifar_dcd(2) or rf0_ifar_dcd(12)  ;
 rf0_ifar_12       <= rf0_ifar_dcd(1)  or rf0_ifar_dcd(2)  ;
 rf0_ifar_13       <= rf0_ifar_dcd(1)  or rf0_ifar_dcd(3)  ;

------------------------------------------------------------------------

 uc_op_rnd_v <= 
   (rf0_n1st_fdiving   and  tiup        ) or 
   (rf0_n1st_fdivsing  and  tiup        ) or 
   (rf0_n1st_fsqrting  and  tiup        ) or 
   (rf0_n1st_fsqrtsing and  tiup        ) ;

 uc_op_rnd(0) <= '0';

 uc_op_rnd(1) <= 
   (rf0_n1st_fdiving   and  rf0_ifar_89 ) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_34 ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_78 ) or 
   (rf0_n1st_fsqrtsing and  rf0_ifar_45 ) ;
  
 uc_inc_lsb <= 
   (rf0_n1st_fdiving   and  rf0_ifar_dcd(9) ) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_dcd(4) ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_dcd(8) ) or 
   (rf0_n1st_fsqrtsing and  rf0_ifar_dcd(5) ) ;
  
 uc_scr_sel(0) <= 
   (rf0_n1st_fdiving   and  rf0_ifar_bc     ) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_67     ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_ab     ) or 
   (rf0_n1st_fsqrtsing and  rf0_ifar_78     ) ;
  
 uc_scr_sel(1) <= 
   (rf0_n1st_fdiving   and  rf0_ifar_ac     ) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_57     ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_9b     ) or 
   (rf0_n1st_fsqrtsing and  rf0_ifar_68     ) ;
  
 uc_scr_wr <= 
   (rf0_n1st_fdiving   and  rf0_ifar_abc    ) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_567    ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_9ab    ) or 
   (rf0_n1st_fsqrtsing and  rf0_ifar_678    ) ;
  
 uc_fa_dis_par_rf0 <=
   (rf0_n1st_fdiving   and  rf0_ifar_1245abc ) or 
   (rf0_n1st_fdivsing  and  tiup             ) or 
   (rf0_n1st_fsqrting  and  tidn             ) or 
   (rf0_n1st_fsqrtsing and  tidn             ) ;

 uc_fb_dis_par_rf0 <=
   (rf0_n1st_fdiving   and  rf0_ifar_13456abc  ) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_134567    ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_dcd(3)    ) or 
   (rf0_n1st_fsqrtsing and  tidn               ) ;

 uc_fc_dis_par_rf0 <=
   (rf0_n1st_fdiving   and  rf0_ifar_123c   ) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_12     ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_13     ) or 
   (rf0_n1st_fsqrtsing and  rf0_ifar_dcd(1) ) ;

 uc_fa_pos  <= 
   (rf0_n1st_fdiving   and  rf0_ifar_1245abc ) or 
   (rf0_n1st_fdivsing  and  tiup             ) or 
   (rf0_n1st_fsqrting  and  tidn             ) or 
   (rf0_n1st_fsqrtsing and  tidn             ) ;

 uc_fc_pos  <=            
   (rf0_n1st_fdiving   and  rf0_ifar_12      ) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_12      ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_dcd(1)  ) or 
   (rf0_n1st_fsqrtsing and  rf0_ifar_dcd(1)  ) ;

 uc_fb_pos  <=          
   (rf0_n1st_fdiving   and  rf0_ifar_13456abc) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_134567  ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_dcd(3)  ) or 
   (rf0_n1st_fsqrtsing and  tidn             ) ;

 uc_fc_0_5  <=        
   (rf0_n1st_fdiving   and  tidn             ) or 
   (rf0_n1st_fdivsing  and  tidn             ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_dcd(1)  ) or 
   (rf0_n1st_fsqrtsing and  rf0_ifar_dcd(1)  ) ;

 uc_fc_hulp <=   
   (rf0_n1st_fdiving   and  rf0_ifar_dcd(12) ) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_dcd(7)  ) or 
   (rf0_n1st_fsqrting  and  tidn             ) or 
   (rf0_n1st_fsqrtsing and  tidn             ) ;
    
 uc_fb_1_0  <=          
   (rf0_n1st_fdiving   and  rf0_ifar_dcd(1)  ) or 
   (rf0_n1st_fdivsing  and  rf0_ifar_dcd(1)  ) or 
   (rf0_n1st_fsqrting  and  tidn             ) or 
   (rf0_n1st_fsqrtsing and  tidn             ) ;

 uc_fb_0_75 <= 
   (rf0_n1st_fdiving   and  rf0_ifar_dcd(6)  ) or 
   (rf0_n1st_fdivsing  and  tidn             ) or 
   (rf0_n1st_fsqrting  and  tidn             ) or 
   (rf0_n1st_fsqrtsing and  tidn             ) ;

 uc_fb_0_5  <=
   (rf0_n1st_fdiving   and  rf0_ifar_dcd(3)  ) or 
   (rf0_n1st_fdivsing  and  tidn             ) or 
   (rf0_n1st_fsqrting  and  rf0_ifar_dcd(3)  ) or 
   (rf0_n1st_fsqrtsing and  tidn             ) ;






--///////////////////////////////////////////////////////////////////////
--// end experiment
--///////////////////////////////////////////////////////////////////////








uc_1st_instr_ld(0) <= uc_beg_rf0     when  iu_fu_rf0_instr_v='1' and uc_scr_thread_rf0 = "00"   else  
                      uc_1st_instr_l2(0);

uc_1st_instr_ld(1) <= uc_beg_rf0     when  iu_fu_rf0_instr_v='1' and uc_scr_thread_rf0 = "01"   else  
                      uc_1st_instr_l2(1);

uc_1st_instr_ld(2) <= uc_beg_rf0     when  iu_fu_rf0_instr_v='1' and uc_scr_thread_rf0 = "10"   else  
                      uc_1st_instr_l2(2);

uc_1st_instr_ld(3) <= uc_beg_rf0     when  iu_fu_rf0_instr_v='1' and uc_scr_thread_rf0 = "11"   else  
                      uc_1st_instr_l2(3);






-- this register is used to force the ifar to 0000 on the first instruction of a ucode routine (table lookup)
-- subsequent instructions will already have ifar = 1,2,3 etc.
   uc_1st_instr_reg:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 4)
    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_1st_instr_scin,
      scout    => uc_1st_instr_scout,
      ---------------------------------------------
      din(0 to 3)  => uc_1st_instr_ld,
                             
      ---------------------------------------------
      dout(0 to 3) => uc_1st_instr_l2

      ---------------------------------------------
      );

       



--
-- The first uc instruction of fdiv/fsqrt is fre or frsqrte,  otherwise abort, it could be a prenorm for a previous instr
uc_abort_rf0(0) <= uc_1st_instr_l2(0) and not((iu_fu_rf0_instr(26 to 28) = "110") and iu_fu_rf0_instr(30) = '0'); 
uc_abort_rf0(1) <= uc_1st_instr_l2(1) and not((iu_fu_rf0_instr(26 to 28) = "110") and iu_fu_rf0_instr(30) = '0'); 
uc_abort_rf0(2) <= uc_1st_instr_l2(2) and not((iu_fu_rf0_instr(26 to 28) = "110") and iu_fu_rf0_instr(30) = '0'); 
uc_abort_rf0(3) <= uc_1st_instr_l2(3) and not((iu_fu_rf0_instr(26 to 28) = "110") and iu_fu_rf0_instr(30) = '0'); 









uc_normal_end_rf0_part <= ((not uc_scr_t0_l2(0) and thread_id_rf0(0)) or 
                                      (not uc_scr_t1_l2(0) and thread_id_rf0(1)) or
                                      (not uc_scr_t2_l2(0) and thread_id_rf0(2)) or
                                      (not uc_scr_t3_l2(0) and thread_id_rf0(3)));

uc_normal_end_rf0  <= uc_end_rf0_v and  uc_normal_end_rf0_part; 



uc_gs_v_rf0 <= uc_normal_end_rf0;






uc_round_mode_ld(0 to 1) <= f_mad_ex3_uc_round_mode    when uc_scr_wr_ex3 = '1' and uc_scr_sel_ex3 = "00"  and uc_scr_thread_ex3 = "00"   else 
                            uc_round_mode_l2(0 to 1);

uc_round_mode_ld(2 to 3) <= f_mad_ex3_uc_round_mode    when uc_scr_wr_ex3 = '1' and uc_scr_sel_ex3 = "00"  and uc_scr_thread_ex3 = "01"   else 
                            uc_round_mode_l2(2 to 3);

uc_round_mode_ld(4 to 5) <= f_mad_ex3_uc_round_mode    when uc_scr_wr_ex3 = '1' and uc_scr_sel_ex3 = "00"  and uc_scr_thread_ex3 = "10"   else 
                            uc_round_mode_l2(4 to 5);

uc_round_mode_ld(6 to 7) <= f_mad_ex3_uc_round_mode    when uc_scr_wr_ex3 = '1' and uc_scr_sel_ex3 = "00"  and uc_scr_thread_ex3 = "11"   else 
                            uc_round_mode_l2(6 to 7);

   uc_round_mode_reg:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 8)
    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_round_mode_scin,
      scout    => uc_round_mode_scout,
      ---------------------------------------------
      din(0 to 7)  => uc_round_mode_ld,
                             
      ---------------------------------------------
      dout(0 to 7) => uc_round_mode_l2

      ---------------------------------------------
      );



uc_special_cases_ex3(0)       <= f_mad_ex3_uc_special;  -- '1' indicates special case (not handled by ucode)
uc_special_cases_ex3(1)       <= f_mad_ex3_uc_res_sign;  -- not really a special case but the cycle timing lines up here
uc_special_cases_ex3(2 to 7)  <= f_mad_ex3_uc_vxsnan & f_mad_ex3_uc_zx & f_mad_ex3_uc_vxidi & f_mad_ex3_uc_vxzdz & f_mad_ex3_uc_vxsqrt & '1';

uc_special_cases_t0_ex3(8 to 11) <= "0000" when  f_mad_ex3_uc_special='1'   else
                                    uc_scr_t0_l2(8 to 11);
uc_special_cases_t1_ex3(8 to 11) <= "0000" when  f_mad_ex3_uc_special='1'   else
                                    uc_scr_t1_l2(8 to 11);
uc_special_cases_t2_ex3(8 to 11) <= "0000" when  f_mad_ex3_uc_special='1'   else
                                    uc_scr_t2_l2(8 to 11);
uc_special_cases_t3_ex3(8 to 11) <= "0000" when  f_mad_ex3_uc_special='1'   else
                                    uc_scr_t3_l2(8 to 11);












uc_hooks_rc_rf0 <= '0'                   when uc_beg_rf0_v ='1' and perr_sm_running='0' else   
                   iu_fu_rf0_instr(31);


--//#################################################################################################
--//## flatten out the output mux
--//#################################################################################################

q1_p_ulp_th(0) <= q1_p_ulp_early_l2(0) and not uc_scr_t0_l2(0) ;
q1_p_ulp_th(1) <= q1_p_ulp_early_l2(1) and not uc_scr_t1_l2(0) ;
q1_p_ulp_th(2) <= q1_p_ulp_early_l2(2) and not uc_scr_t2_l2(0) ;
q1_p_ulp_th(3) <= q1_p_ulp_early_l2(3) and not uc_scr_t3_l2(0) ;

iu_fu_rf0_ucfmul_b <= not iu_fu_rf0_ucfmul ; 



u_q1pm0: rf0_q1_p_ulp_mux0_b  <= not( (thread_id_rf0(0) and q1_p_ulp_th(0)) or (thread_id_rf0(1) and q1_p_ulp_th(1))  ); 
u_q1pm1: rf0_q1_p_ulp_mux1_b  <= not( (thread_id_rf0(2) and q1_p_ulp_th(2)) or (thread_id_rf0(3) and q1_p_ulp_th(3))  ); 

u_q1pm:  rf0_q1_p_ulp_mux       <= not( rf0_q1_p_ulp_mux0_b and rf0_q1_p_ulp_mux1_b ) ;

u_afm0:  rf0_fra_fast_mux0_b(4) <= not( rf0_q1_p_ulp_mux and iu_fu_rf0_ucfmul   );
u_afm1:  rf0_fra_fast_mux1_b(4) <= not( rf0_instr_fra(4) and iu_fu_rf0_ucfmul_b );

u_afm:   rf0_fra_fast_mux(4)   <= not( rf0_fra_fast_mux0_b(4) and  rf0_fra_fast_mux1_b(4) );

u_afb:   rf0_fra_fast_b(4)     <= not( rf0_fra_fast_mux(4)  );
u_af:    rf0_fra_fast(4)       <= not( rf0_fra_fast_b(4) );
u_afi:   rf0_fra_fast_i_b(4)   <= not rf0_fra_fast(4)  ; 
u_afii:  rf0_fra_fast_ii(4)    <= not rf0_fra_fast_i_b(4);



         f_dcd_rf0_fra(0) <=     rf0_instr_fra(0) ;      
         f_dcd_rf0_fra(1) <=     rf0_instr_fra(1) ;      
         f_dcd_rf0_fra(2) <=     rf0_instr_fra(2) ;      
         f_dcd_rf0_fra(3) <=     rf0_instr_fra(3) ;      
         f_dcd_rf0_fra(4) <=     rf0_fra_fast_ii(4);     
         f_dcd_rf0_fra(5) <=     rf0_instr_fra(5) ;      









--//###################################################################################################

rf0_i(0 to 31) <= iu_fu_rf0_instr(0 to 31);

fp_operation_rf0   <= rf0_i(0) and rf0_i(1) and rf0_i(2) and                  rf0_i(4) and rf0_i(5) ;

rf0_f2_dvsq    <= rf0_i(26) and not rf0_i(27) and                       rf0_i(29) and not rf0_i(30) ;
rf0_f2_dv      <= rf0_i(26) and not rf0_i(27) and not rf0_i(28) and     rf0_i(29) and not rf0_i(30) ;
rf0_f2_sq      <= rf0_i(26) and not rf0_i(27) and     rf0_i(28) and     rf0_i(29) and not rf0_i(30) ;
rf0_f2_mul     <= rf0_i(26) and not rf0_i(27) and not rf0_i(28) and not rf0_i(29) and     rf0_i(30) ;


-- 3F = double     3B = single

uc_div_beg_rf0    <= fp_operation_rf0   and                  rf0_f2_dv   and iu_fu_rf0_instr_v ;-- 1 load to latch
uc_sqrt_beg_rf0   <= fp_operation_rf0   and                  rf0_f2_sq   and iu_fu_rf0_instr_v ;-- 1 load to latch
uc_fdiv_beg_rf0   <= fp_operation_rf0   and     rf0_i(3) and rf0_f2_dv     ;
uc_fdivs_beg_rf0  <= fp_operation_rf0   and not rf0_i(3) and rf0_f2_dv     ;
uc_fsqrt_beg_rf0  <= fp_operation_rf0   and     rf0_i(3) and rf0_f2_sq     ;
uc_fsqrts_beg_rf0 <= fp_operation_rf0   and not rf0_i(3) and rf0_f2_sq     ;
uc_dvsq_beg_rf0   <= fp_operation_rf0   and                  rf0_f2_dvsq   ;-- fdiv,fdivs,fsqrt,fsqrts
fmulx_uc_rf0      <= fp_operation_rf0   and                  rf0_f2_mul    ;-- fmuls, fmul



uc_beg_rf0   <= uc_dvsq_beg_rf0                        ;
uc_beg_rf0_v <= uc_dvsq_beg_rf0 and iu_fu_rf0_instr_v  ;
uc_end_rf0   <= fmulx_uc_rf0                           ;
uc_end_rf0_v <= fmulx_uc_rf0    and iu_fu_rf0_instr_v  ;
uc_end_rf0_vf <= fmulx_uc_rf0    and iu_fu_rf0_instr_v and not rf0_instr_flush  ;


uc_op_rf0(0) <= uc_fdiv_beg_rf0 ;
uc_op_rf0(1) <= uc_fdivs_beg_rf0 ;
uc_op_rf0(2) <= uc_fsqrt_beg_rf0 ;
uc_op_rf0(3) <= uc_fsqrts_beg_rf0;


-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------- uc_scr ---------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-- collect sign, zero, & rc info for ucode divide algorithm

   uc_sign_zero_t0(0 to 11) <= uc_scr_t0_l2(0 to 1) & f_mad_ex6_uc_sign & f_mad_ex6_uc_zero & uc_scr_t0_l2(4 to 11)    when uc_scr_sel_ex6 = "01"  else  -- save sign & zero
                               uc_scr_t0_l2(0 to 3) & f_mad_ex6_uc_sign & f_mad_ex6_uc_zero & uc_scr_t0_l2(6 to 11)    when uc_scr_sel_ex6 = "10"  else  -- save sign & zero
                               uc_scr_t0_l2(0 to 5) & f_mad_ex6_uc_sign & "00000"; --    last uc before the mult by 1

   uc_sign_zero_t1(0 to 11) <= uc_scr_t1_l2(0 to 1) & f_mad_ex6_uc_sign & f_mad_ex6_uc_zero & uc_scr_t1_l2(4 to 11)    when uc_scr_sel_ex6 = "01"  else  -- save sign & zero
                               uc_scr_t1_l2(0 to 3) & f_mad_ex6_uc_sign & f_mad_ex6_uc_zero & uc_scr_t1_l2(6 to 11)    when uc_scr_sel_ex6 = "10"  else  -- save sign & zero
                               uc_scr_t1_l2(0 to 5) & f_mad_ex6_uc_sign & "00000"; --    last uc before the mult by 1

   uc_sign_zero_t2(0 to 11) <= uc_scr_t2_l2(0 to 1) & f_mad_ex6_uc_sign & f_mad_ex6_uc_zero & uc_scr_t2_l2(4 to 11)    when uc_scr_sel_ex6 = "01"  else  -- save sign & zero
                               uc_scr_t2_l2(0 to 3) & f_mad_ex6_uc_sign & f_mad_ex6_uc_zero & uc_scr_t2_l2(6 to 11)    when uc_scr_sel_ex6 = "10"  else  -- save sign & zero
                               uc_scr_t2_l2(0 to 5) & f_mad_ex6_uc_sign & "00000"; --    last uc before the mult by 1

   uc_sign_zero_t3(0 to 11) <= uc_scr_t3_l2(0 to 1) & f_mad_ex6_uc_sign & f_mad_ex6_uc_zero & uc_scr_t3_l2(4 to 11)    when uc_scr_sel_ex6 = "01"  else  -- save sign & zero
                               uc_scr_t3_l2(0 to 3) & f_mad_ex6_uc_sign & f_mad_ex6_uc_zero & uc_scr_t3_l2(6 to 11)    when uc_scr_sel_ex6 = "10"  else  -- save sign & zero
                               uc_scr_t3_l2(0 to 5) & f_mad_ex6_uc_sign & "00000"; --    last uc before the mult by 1



   uc_scr_t0_upd(0)  <=  uc_1st_instr_l2(0) = '1' and uc_scr_t0_l2(7) = '0' and uc_scr_thread_rf1 = "00" ;-- clear bits 0:6 and latch rc of original ppc fdiv(s) or fsqrt(s) rc
   uc_scr_t1_upd(0)  <=  uc_1st_instr_l2(1) = '1' and uc_scr_t1_l2(7) = '0' and uc_scr_thread_rf1 = "01" ;-- clear bits 0:6 and latch rc of original ppc fdiv(s) or fsqrt(s) rc
   uc_scr_t2_upd(0)  <=  uc_1st_instr_l2(2) = '1' and uc_scr_t2_l2(7) = '0' and uc_scr_thread_rf1 = "10" ;-- clear bits 0:6 and latch rc of original ppc fdiv(s) or fsqrt(s) rc
   uc_scr_t3_upd(0)  <=  uc_1st_instr_l2(3) = '1' and uc_scr_t3_l2(7) = '0' and uc_scr_thread_rf1 = "11" ;-- clear bits 0:6 and latch rc of original ppc fdiv(s) or fsqrt(s) rc

   uc_scr_t0_upd(1)  <=  uc_end_ex6_l2                                                              and uc_scr_thread_ex6 = "00" ; -- clear bits 0:7 end of ucode
   uc_scr_t1_upd(1)  <=  uc_end_ex6_l2                                                              and uc_scr_thread_ex6 = "01" ; -- clear bits 0:7 end of ucode
   uc_scr_t2_upd(1)  <=  uc_end_ex6_l2                                                              and uc_scr_thread_ex6 = "10" ; -- clear bits 0:7 end of ucode
   uc_scr_t3_upd(1)  <=  uc_end_ex6_l2                                                              and uc_scr_thread_ex6 = "11" ; -- clear bits 0:7 end of ucode

   uc_scr_t0_upd(2)  <= ((not ucode_mode_rf0 and not uc_end_rf0) or uc_abort_rf0(0) ) and iu_fu_rf0_instr_v  and thread_id_rf0(0) ; -- clear bits 0:7 ppc instr
   uc_scr_t1_upd(2)  <= ((not ucode_mode_rf0 and not uc_end_rf0) or uc_abort_rf0(1) ) and iu_fu_rf0_instr_v  and thread_id_rf0(1) ; -- clear bits 0:7 ppc instr
   uc_scr_t2_upd(2)  <= ((not ucode_mode_rf0 and not uc_end_rf0) or uc_abort_rf0(2) ) and iu_fu_rf0_instr_v  and thread_id_rf0(2) ; -- clear bits 0:7 ppc instr
   uc_scr_t3_upd(2)  <= ((not ucode_mode_rf0 and not uc_end_rf0) or uc_abort_rf0(3) ) and iu_fu_rf0_instr_v  and thread_id_rf0(3) ; -- clear bits 0:7 ppc instr

   uc_scr_t0_upd(3)  <= uc_scr_wr_ex3_l2 and uc_scr_sel_ex3 = "00" and uc_scr_t0_l2(7) = '1' and uc_scr_thread_ex3 = "00" ; -- check for ugly ops, save final sig
   uc_scr_t1_upd(3)  <= uc_scr_wr_ex3_l2 and uc_scr_sel_ex3 = "00" and uc_scr_t1_l2(7) = '1' and uc_scr_thread_ex3 = "01" ; -- check for ugly ops, save final sig
   uc_scr_t2_upd(3)  <= uc_scr_wr_ex3_l2 and uc_scr_sel_ex3 = "00" and uc_scr_t2_l2(7) = '1' and uc_scr_thread_ex3 = "10" ; -- check for ugly ops, save final sig
   uc_scr_t3_upd(3)  <= uc_scr_wr_ex3_l2 and uc_scr_sel_ex3 = "00" and uc_scr_t3_l2(7) = '1' and uc_scr_thread_ex3 = "11" ; -- check for ugly ops, save final sig

   uc_scr_t0_upd(4)  <= uc_scr_wr_ex6 = '1'                      and uc_scr_t0_l2(0) = '0' and uc_scr_t0_l2(7) = '1' and uc_scr_thread_ex6 = "00" ;-- save sign & zero
   uc_scr_t1_upd(4)  <= uc_scr_wr_ex6 = '1'                      and uc_scr_t1_l2(0) = '0' and uc_scr_t1_l2(7) = '1' and uc_scr_thread_ex6 = "01" ;-- save sign & zero
   uc_scr_t2_upd(4)  <= uc_scr_wr_ex6 = '1'                      and uc_scr_t2_l2(0) = '0' and uc_scr_t2_l2(7) = '1' and uc_scr_thread_ex6 = "10" ;-- save sign & zero
   uc_scr_t3_upd(4)  <= uc_scr_wr_ex6 = '1'                      and uc_scr_t3_l2(0) = '0' and uc_scr_t3_l2(7) = '1' and uc_scr_thread_ex6 = "11" ;-- save sign & zero


   uc_scr_t0_fbk_x <= not( uc_scr_t0_upd(0) or uc_scr_t0_upd(1) or uc_scr_t0_upd(3) or uc_scr_t0_upd(4) );
   uc_scr_t1_fbk_x <= not( uc_scr_t1_upd(0) or uc_scr_t1_upd(1) or uc_scr_t1_upd(3) or uc_scr_t1_upd(4) );
   uc_scr_t2_fbk_x <= not( uc_scr_t2_upd(0) or uc_scr_t2_upd(1) or uc_scr_t2_upd(3) or uc_scr_t2_upd(4) );
   uc_scr_t3_fbk_x <= not( uc_scr_t3_upd(0) or uc_scr_t3_upd(1) or uc_scr_t3_upd(3) or uc_scr_t3_upd(4) );


   uc_scr_t0_ld_x(0 to 11) <= not( uc_scr_t0_ld_x0_b(0 to 11) and  uc_scr_t0_ld_x1_b(0 to 11) and uc_scr_t0_ld_x3_b(0 to 11) and uc_scr_t0_ld_x4_b(0 to 11) and uc_scr_t0_ld_xf_b(0 to 11) );
   uc_scr_t1_ld_x(0 to 11) <= not( uc_scr_t1_ld_x0_b(0 to 11) and  uc_scr_t1_ld_x1_b(0 to 11) and uc_scr_t1_ld_x3_b(0 to 11) and uc_scr_t1_ld_x4_b(0 to 11) and uc_scr_t1_ld_xf_b(0 to 11) );
   uc_scr_t2_ld_x(0 to 11) <= not( uc_scr_t2_ld_x0_b(0 to 11) and  uc_scr_t2_ld_x1_b(0 to 11) and uc_scr_t2_ld_x3_b(0 to 11) and uc_scr_t2_ld_x4_b(0 to 11) and uc_scr_t2_ld_xf_b(0 to 11) );
   uc_scr_t3_ld_x(0 to 11) <= not( uc_scr_t3_ld_x0_b(0 to 11) and  uc_scr_t3_ld_x1_b(0 to 11) and uc_scr_t3_ld_x3_b(0 to 11) and uc_scr_t3_ld_x4_b(0 to 11) and uc_scr_t3_ld_xf_b(0 to 11) );


  uc_scr_t0_ld_x0_b(0 to 11) <= not("00000001" & uc_scr_t0_l2(8 to 11)                              and (0 to 11 => uc_scr_t0_upd(0))) ; 
  uc_scr_t1_ld_x0_b(0 to 11) <= not("00000001" & uc_scr_t1_l2(8 to 11)                              and (0 to 11 => uc_scr_t1_upd(0))) ; 
  uc_scr_t2_ld_x0_b(0 to 11) <= not("00000001" & uc_scr_t2_l2(8 to 11)                              and (0 to 11 => uc_scr_t2_upd(0))) ; 
  uc_scr_t3_ld_x0_b(0 to 11) <= not("00000001" & uc_scr_t3_l2(8 to 11)                              and (0 to 11 => uc_scr_t3_upd(0))) ; 

  uc_scr_t0_ld_x1_b(0 to 11) <= not("000000000000"                                                  and (0 to 11 => uc_scr_t0_upd(1))) ;
  uc_scr_t1_ld_x1_b(0 to 11) <= not("000000000000"                                                  and (0 to 11 => uc_scr_t1_upd(1))) ; 
  uc_scr_t2_ld_x1_b(0 to 11) <= not("000000000000"                                                  and (0 to 11 => uc_scr_t2_upd(1))) ; 
  uc_scr_t3_ld_x1_b(0 to 11) <= not("000000000000"                                                  and (0 to 11 => uc_scr_t3_upd(1))) ; 

  uc_scr_t0_ld_x2_b(0 to 11) <= not("00000000" & uc_op_rf0(0 to 3)                                  and (0 to 11 => uc_scr_t0_upd(2))) ;
  uc_scr_t1_ld_x2_b(0 to 11) <= not("00000000" & uc_op_rf0(0 to 3)                                  and (0 to 11 => uc_scr_t1_upd(2))) ;
  uc_scr_t2_ld_x2_b(0 to 11) <= not("00000000" & uc_op_rf0(0 to 3)                                  and (0 to 11 => uc_scr_t2_upd(2))) ;
  uc_scr_t3_ld_x2_b(0 to 11) <= not("00000000" & uc_op_rf0(0 to 3)                                  and (0 to 11 => uc_scr_t3_upd(2))) ;

  uc_scr_t0_ld_x3_b(0 to 11) <= not(uc_special_cases_ex3(0 to 7) & uc_special_cases_t0_ex3(8 to 11) and (0 to 11 => uc_scr_t0_upd(3))) ;
  uc_scr_t1_ld_x3_b(0 to 11) <= not(uc_special_cases_ex3(0 to 7) & uc_special_cases_t1_ex3(8 to 11) and (0 to 11 => uc_scr_t1_upd(3))) ;
  uc_scr_t2_ld_x3_b(0 to 11) <= not(uc_special_cases_ex3(0 to 7) & uc_special_cases_t2_ex3(8 to 11) and (0 to 11 => uc_scr_t2_upd(3))) ;
  uc_scr_t3_ld_x3_b(0 to 11) <= not(uc_special_cases_ex3(0 to 7) & uc_special_cases_t3_ex3(8 to 11) and (0 to 11 => uc_scr_t3_upd(3))) ;

  uc_scr_t0_ld_x4_b(0 to 11) <= not(uc_sign_zero_t0(0 to 11)                                        and (0 to 11 => uc_scr_t0_upd(4))) ; 
  uc_scr_t1_ld_x4_b(0 to 11) <= not(uc_sign_zero_t1(0 to 11)                                        and (0 to 11 => uc_scr_t1_upd(4))) ; 
  uc_scr_t2_ld_x4_b(0 to 11) <= not(uc_sign_zero_t2(0 to 11)                                        and (0 to 11 => uc_scr_t2_upd(4))) ; 
  uc_scr_t3_ld_x4_b(0 to 11) <= not(uc_sign_zero_t3(0 to 11)                                        and (0 to 11 => uc_scr_t3_upd(4))) ; 

  uc_scr_t0_ld_xf_b(0 to 11) <= not(uc_scr_t0_l2(0 to 11)                                           and (0 to 11 => uc_scr_t0_fbk_x )) ;
  uc_scr_t1_ld_xf_b(0 to 11) <= not(uc_scr_t1_l2(0 to 11)                                           and (0 to 11 => uc_scr_t1_fbk_x )) ;
  uc_scr_t2_ld_xf_b(0 to 11) <= not(uc_scr_t2_l2(0 to 11)                                           and (0 to 11 => uc_scr_t2_fbk_x )) ;
  uc_scr_t3_ld_xf_b(0 to 11) <= not(uc_scr_t3_l2(0 to 11)                                           and (0 to 11 => uc_scr_t3_fbk_x )) ;

   uc_scr_t0_oth_b(0 to 11) <= not( (0 to 11 => not uc_scr_t0_upd(2) ) and uc_scr_t0_ld_x(0 to 11) );
   uc_scr_t1_oth_b(0 to 11) <= not( (0 to 11 => not uc_scr_t1_upd(2) ) and uc_scr_t1_ld_x(0 to 11) );
   uc_scr_t2_oth_b(0 to 11) <= not( (0 to 11 => not uc_scr_t2_upd(2) ) and uc_scr_t2_ld_x(0 to 11) );
   uc_scr_t3_oth_b(0 to 11) <= not( (0 to 11 => not uc_scr_t3_upd(2) ) and uc_scr_t3_ld_x(0 to 11) );

   uc_scr_t0_ld(0 to 11) <= not( uc_scr_t0_ld_x2_b(0 to 11) and uc_scr_t0_oth_b(0 to 11) );
   uc_scr_t1_ld(0 to 11) <= not( uc_scr_t1_ld_x2_b(0 to 11) and uc_scr_t1_oth_b(0 to 11) );
   uc_scr_t2_ld(0 to 11) <= not( uc_scr_t2_ld_x2_b(0 to 11) and uc_scr_t2_oth_b(0 to 11) );
   uc_scr_t3_ld(0 to 11) <= not( uc_scr_t3_ld_x2_b(0 to 11) and uc_scr_t3_oth_b(0 to 11) );
 
  


-- uc scr thread 0,1,2,3 ----------------------------------------------------------------
-- bit 0 = 0 indicates regular case
--  bit 1  final sign
--  bit 2  q1r_sign
--  bit 3  q1r_zero
--  bit 4  q1ulpr_sign
--  bit 5  q1ulpr_zero
--  bit 6  q1hulpr_sign
--  bit 7  divide or square root in progress
--  bit 8  fdiv
--  bit 9  fdivs
--  bit 10 fsqrt
--  bit 11 fsqrts
-- bit 0 = 1 indicates special case
--  bit 1 final sign (not used)
--  bit 2 NaN
--  bit 3 ZX
--  bit 4 VXIDI
--  bit 5 VXZDZ
--  bit 6
--  bit 7 divide or square root in progress
--  bit 8  fdiv
--  bit 9  fdivs
--  bit 10 fsqrt
--  bit 11 fsqrts

   uc_scr_t0_is2:  tri_rlmreg_p    generic map (init => 0, expand_type => expand_type, width => 12)    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_t0_scin,
      scout    => uc_scr_t0_scout,
      din(0 to 11)  => uc_scr_t0_ld,
      dout(0 to 11) => uc_scr_t0_l2      );

   uc_scr_t1_is2:  tri_rlmreg_p    generic map (init => 0, expand_type => expand_type, width => 12)    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_t1_scin,
      scout    => uc_scr_t1_scout,
      din(0 to 11)  => uc_scr_t1_ld,
      dout(0 to 11) => uc_scr_t1_l2      );

   uc_scr_t2_is2:  tri_rlmreg_p    generic map (init => 0, expand_type => expand_type, width => 12)    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_t2_scin,
      scout    => uc_scr_t2_scout,
      din(0 to 11)  => uc_scr_t2_ld,
      dout(0 to 11) => uc_scr_t2_l2      );

   uc_scr_t3_is2:  tri_rlmreg_p    generic map (init => 0, expand_type => expand_type, width => 12)    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_t3_scin,
      scout    => uc_scr_t3_scout,
      din(0 to 11)  => uc_scr_t3_ld,
      dout(0 to 11) => uc_scr_t3_l2      );



q1r_sign_rf0 <=  (uc_scr_t0_l2(2) and thread_id_rf0(0)) or
                 (uc_scr_t1_l2(2) and thread_id_rf0(1)) or
                 (uc_scr_t2_l2(2) and thread_id_rf0(2)) or
                 (uc_scr_t3_l2(2) and thread_id_rf0(3)); 

q1r_zero_rf0 <=    (uc_scr_t0_l2(3) and thread_id_rf0(0)) or
                   (uc_scr_t1_l2(3) and thread_id_rf0(1)) or
                   (uc_scr_t2_l2(3) and thread_id_rf0(2)) or
                   (uc_scr_t3_l2(3) and thread_id_rf0(3)); 


q1ulpr_zero_rf0 <=  (uc_scr_t0_l2(5) and thread_id_rf0(0)) or
                    (uc_scr_t1_l2(5) and thread_id_rf0(1)) or
                    (uc_scr_t2_l2(5) and thread_id_rf0(2)) or
                    (uc_scr_t3_l2(5) and thread_id_rf0(3));

ex4_uc_special <= ((uc_scr_t0_l2(0) and uc_scr_thread_ex4 = "00") or
                   (uc_scr_t1_l2(0) and uc_scr_thread_ex4 = "01") or 
                   (uc_scr_t2_l2(0) and uc_scr_thread_ex4 = "10") or 
                   (uc_scr_t3_l2(0) and uc_scr_thread_ex4 = "11") ) and not uc_end_ex4_l2 and not uc_beg_ex4  and not  perr_sm_running ; 


special_rf1  <=  (uc_scr_t0_l2(0) and uc_scr_thread_rf1 = "00") or    
                 (uc_scr_t1_l2(0) and uc_scr_thread_rf1 = "01") or
                 (uc_scr_t2_l2(0) and uc_scr_thread_rf1 = "10") or
                 (uc_scr_t3_l2(0) and uc_scr_thread_rf1 = "11");

f_dcd_ex2_uc_vxsnan <= ((uc_scr_t0_l2(0) and uc_scr_t0_l2(2) and uc_scr_thread_ex2 = "00") or   
                        (uc_scr_t1_l2(0) and uc_scr_t1_l2(2) and uc_scr_thread_ex2 = "01") or
                        (uc_scr_t2_l2(0) and uc_scr_t2_l2(2) and uc_scr_thread_ex2 = "10") or
                        (uc_scr_t3_l2(0) and uc_scr_t3_l2(2) and uc_scr_thread_ex2 = "11")) and not  perr_sm_running ; 


f_dcd_ex2_uc_zx    <= ((uc_scr_t0_l2(0) and uc_scr_t0_l2(3) and uc_scr_thread_ex2 = "00") or   
                       (uc_scr_t1_l2(0) and uc_scr_t1_l2(3) and uc_scr_thread_ex2 = "01") or
                       (uc_scr_t2_l2(0) and uc_scr_t2_l2(3) and uc_scr_thread_ex2 = "10") or
                       (uc_scr_t3_l2(0) and uc_scr_t3_l2(3) and uc_scr_thread_ex2 = "11")) and not  perr_sm_running ; 


f_dcd_ex2_uc_vxidi <= ((uc_scr_t0_l2(0) and uc_scr_t0_l2(4) and uc_scr_thread_ex2 = "00") or   
                       (uc_scr_t1_l2(0) and uc_scr_t1_l2(4) and uc_scr_thread_ex2 = "01") or
                       (uc_scr_t2_l2(0) and uc_scr_t2_l2(4) and uc_scr_thread_ex2 = "10") or
                       (uc_scr_t3_l2(0) and uc_scr_t3_l2(4) and uc_scr_thread_ex2 = "11")) and not  perr_sm_running ; 


f_dcd_ex2_uc_vxzdz <= ((uc_scr_t0_l2(0) and uc_scr_t0_l2(5) and uc_scr_thread_ex2 = "00") or   
                       (uc_scr_t1_l2(0) and uc_scr_t1_l2(5) and uc_scr_thread_ex2 = "01") or
                       (uc_scr_t2_l2(0) and uc_scr_t2_l2(5) and uc_scr_thread_ex2 = "10") or
                       (uc_scr_t3_l2(0) and uc_scr_t3_l2(5) and uc_scr_thread_ex2 = "11")) and not  perr_sm_running ; 


f_dcd_ex2_uc_vxsqrt <= ((uc_scr_t0_l2(0) and uc_scr_t0_l2(6) and uc_scr_thread_ex2 = "00") or  
                        (uc_scr_t1_l2(0) and uc_scr_t1_l2(6) and uc_scr_thread_ex2 = "01") or
                        (uc_scr_t2_l2(0) and uc_scr_t2_l2(6) and uc_scr_thread_ex2 = "10") or
                        (uc_scr_t3_l2(0) and uc_scr_t3_l2(6) and uc_scr_thread_ex2 = "11")) and not  perr_sm_running ; 


uc_scr_thread_rf0(0)     <= thread_id_rf0(2) or thread_id_rf0(3); 
uc_scr_thread_rf0(1)     <= thread_id_rf0(1) or thread_id_rf0(3); 

uc_fc_pos_rf0 <= uc_fc_pos or uc_end_rf0_v;


   pipe_rf1:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 22)
    port map (
      nclk     => nclk,                  act      => tiup,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => pipe_rf1_scin,
      scout    => pipe_rf1_scout,
      ---------------------------------------------
      din(00)        =>  uc_div_beg_rf0,
      din(01)        =>  uc_sqrt_beg_rf0,
      din(02)        =>  uc_mid_rf0,   -- 13 bit expt. overflow/underflow disable.  do not set fpscr.
      din(03)        =>  uc_end_rf0_vf,   -- 13 bit expt. overflow/underflow disable.  do not set fpscr.
      din(04)        =>  '0',
      din(05)        =>  uc_fa_pos,
      din(06)        =>  uc_fc_pos_rf0,
      din(07)        =>  uc_fb_pos,
      din(08)        =>  uc_fc_hulp,
      din(09)        =>  uc_fc_0_5,
      din(10)        =>  uc_fc_1_0,
      din(11)        =>  uc_fc_1_minus,
      din(12)        =>  uc_fb_1_0,
      din(13)        =>  uc_fb_0_75,
      din(14)        =>  uc_fb_0_5,
      din(15)        =>  uc_fa_dis_par_rf0,
      din(16)        =>  uc_fb_dis_par_rf0,
      din(17)        =>  uc_fc_dis_par_rf0,
      din(18)        =>  uc_op_rnd_v,
      din(19 to 20)  =>  uc_op_rnd(0 to 1),
      din(21)        =>  iu_fu_rf0_ucfmul,
      ---------------------------------------------
      dout(00)       =>  uc_div_beg_rf1,
      dout(01)       =>  uc_sqrt_beg_rf1,
      dout(02)       =>  uc_mid_rf1,
      dout(03)       =>  uc_end_rf1_l2,
      dout(04)       =>  spare,        
      dout(05)       =>  uc_fa_pos_rf1,
      dout(06)       =>  uc_fc_pos_rf1,
      dout(07)       =>  uc_fb_pos_rf1,
      dout(08)       =>  uc_fc_hulp_rf1,
      dout(09)       =>  uc_fc_0_5_rf1,
      dout(10)       =>  uc_fc_1_0_rf1,
      dout(11)       =>  uc_fc_1_minus_rf1,
      dout(12)       =>  uc_fb_1_0_rf1,
      dout(13)       =>  uc_fb_0_75_rf1,
      dout(14)       =>  uc_fb_0_5_rf1,
      dout(15)       =>  uc_fa_dis_par_rf1,
      dout(16)       =>  uc_fb_dis_par_rf1,
      dout(17)       =>  uc_fc_dis_par_rf1,
      dout(18)       =>  uc_op_rnd_v_rf1_l2,
      dout(19 to 20) =>  uc_op_rnd_rf1_l2(0 to 1),
      dout(21)       =>  rf1_ucfmul
      ---------------------------------------------
      );


rf0_instr_flush  <= ((thread_id_rf0(0) and xu_rf0_flush(0)) or
                     (thread_id_rf0(1) and xu_rf0_flush(1)) or
                     (thread_id_rf0(2) and xu_rf0_flush(2)) or
                     (thread_id_rf0(3) and xu_rf0_flush(3)) );

uc_scr_wr_rf0 <= (uc_scr_wr or uc_beg_rf0) and iu_fu_rf0_instr_v and not rf0_instr_flush;

-- uc_scr write pipe -----------------------------
   uc_scr_wr_pipe_rf1:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 8)
    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_wr_pipe_rf1_scin,
      scout    => uc_scr_wr_pipe_rf1_scout,
      ---------------------------------------------
      din(0)      => uc_scr_wr_rf0,
      din(1 to 2) => uc_scr_sel(0 to 1),
      din(3 to 4) => uc_scr_thread_rf0(0 to 1),
      din(5)      => uc_gs_v_rf0,
      din(6)      => uc_inc_lsb,
      din(7)      => uc_beg_rf0_v,
      ---------------------------------------------
      dout(0)      => uc_scr_wr_rf1_l2,
      dout(1 to 2) => uc_scr_sel_rf1(0 to 1),
      dout(3 to 4) => uc_scr_thread_rf1(0 to 1),
      dout(5)      => uc_gs_v_rf1,
      dout(6)      => uc_inc_lsb_rf1,
      dout(7)      => uc_beg_rf1
      ---------------------------------------------
      );

rf1_instr_flush  <= ((uc_scr_thread_rf1(0 to 1) = "00" and xu_rf1_flush(0)) or
                     (uc_scr_thread_rf1(0 to 1) = "01" and xu_rf1_flush(1)) or
                     (uc_scr_thread_rf1(0 to 1) = "10" and xu_rf1_flush(2)) or
                     (uc_scr_thread_rf1(0 to 1) = "11" and xu_rf1_flush(3)) );

uc_scr_wr_rf1 <= uc_scr_wr_rf1_l2 and not rf1_instr_flush;

uc_end_rf1_v  <= uc_end_rf1_l2 and not rf1_instr_flush;
uc_end_rf1    <= uc_end_rf1_l2;

   uc_scr_wr_pipe_ex1:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 9)
    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_wr_pipe_ex1_scin,
      scout    => uc_scr_wr_pipe_ex1_scout,
      ---------------------------------------------
      din(0)      => uc_scr_wr_rf1,
      din(1 to 2) => uc_scr_sel_rf1(0 to 1),
      din(3 to 4) => uc_scr_thread_rf1(0 to 1),
      din(5)      => uc_gs_v_rf1,
      din(6)      => uc_inc_lsb_rf1,
      din(7)      => uc_end_rf1_v,
      din(8)      => uc_beg_rf1,
      ---------------------------------------------
      dout(0)      => uc_scr_wr_ex1_l2,
      dout(1 to 2) => uc_scr_sel_ex1(0 to 1),
      dout(3 to 4) => uc_scr_thread_ex1(0 to 1),
      dout(5)      => uc_gs_v_ex1,
      dout(6)      => uc_inc_lsb_ex1,
      dout(7)      => uc_end_ex1_l2,
      dout(8)      => uc_beg_ex1
      ---------------------------------------------
      );

ex1_instr_flush  <= ((uc_scr_thread_ex1(0 to 1) = "00" and xu_ex1_flush(0)) or
                     (uc_scr_thread_ex1(0 to 1) = "01" and xu_ex1_flush(1)) or
                     (uc_scr_thread_ex1(0 to 1) = "10" and xu_ex1_flush(2)) or
                     (uc_scr_thread_ex1(0 to 1) = "11" and xu_ex1_flush(3)) );

uc_scr_wr_ex1 <= uc_scr_wr_ex1_l2 and not ex1_instr_flush;

uc_end_ex1    <= uc_end_ex1_l2 and not ex1_instr_flush;

-- uc_scr write pipe -----------------------------
   uc_scr_wr_pipe_ex2:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 9)
    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_wr_pipe_ex2_scin,
      scout    => uc_scr_wr_pipe_ex2_scout,
      ---------------------------------------------
      din(0)      => uc_scr_wr_ex1,
      din(1 to 2) => uc_scr_sel_ex1(0 to 1),
      din(3 to 4) => uc_scr_thread_ex1(0 to 1),
      din(5)      => uc_gs_v_ex1,
      din(6)      => uc_inc_lsb_ex1,
      din(7)      => uc_end_ex1,
      din(8)      => uc_beg_ex1,
      ---------------------------------------------
      dout(0)      => uc_scr_wr_ex2_l2,
      dout(1 to 2) => uc_scr_sel_ex2(0 to 1),
      dout(3 to 4) => uc_scr_thread_ex2(0 to 1),
      dout(5)      => uc_gs_v_ex2,
      dout(6)      => uc_inc_lsb_ex2,
      dout(7)      => uc_end_ex2_l2,
      dout(8)      => uc_beg_ex2
      ---------------------------------------------
      );

ex2_instr_flush  <= ((uc_scr_thread_ex2(0 to 1) = "00" and xu_ex2_flush(0)) or
                     (uc_scr_thread_ex2(0 to 1) = "01" and xu_ex2_flush(1)) or
                     (uc_scr_thread_ex2(0 to 1) = "10" and xu_ex2_flush(2)) or
                     (uc_scr_thread_ex2(0 to 1) = "11" and xu_ex2_flush(3)) );

uc_scr_wr_ex2 <= uc_scr_wr_ex2_l2 and not ex2_instr_flush;

uc_end_ex2    <= uc_end_ex2_l2 and not ex2_instr_flush;

-- uc_scr write pipe -----------------------------
   uc_scr_wr_pipe_ex3:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 7)
    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_wr_pipe_ex3_scin,
      scout    => uc_scr_wr_pipe_ex3_scout,
      ---------------------------------------------
      din(0)      => uc_scr_wr_ex2,
      din(1 to 2) => uc_scr_sel_ex2(0 to 1),
      din(3 to 4) => uc_scr_thread_ex2(0 to 1),
      din(5)      => uc_end_ex2,
      din(6)      => uc_beg_ex2,
      ---------------------------------------------
      dout(0)      => uc_scr_wr_ex3_l2,
      dout(1 to 2) => uc_scr_sel_ex3(0 to 1),
      dout(3 to 4) => uc_scr_thread_ex3(0 to 1),
      dout(5)      => uc_end_ex3_l2,
      dout(6)      => uc_beg_ex3
      ---------------------------------------------
      );


ex3_instr_flush_th(0) <= uc_scr_thread_ex3(0 to 1) = "00" and xu_ex3_flush(0) ;
ex3_instr_flush_th(1) <= uc_scr_thread_ex3(0 to 1) = "01" and xu_ex3_flush(1) ;
ex3_instr_flush_th(2) <= uc_scr_thread_ex3(0 to 1) = "10" and xu_ex3_flush(2) ;
ex3_instr_flush_th(3) <= uc_scr_thread_ex3(0 to 1) = "11" and xu_ex3_flush(3) ;

ex3_instr_flush  <= ex3_instr_flush_th(0) or
                    ex3_instr_flush_th(1) or 
                    ex3_instr_flush_th(2) or 
                    ex3_instr_flush_th(3) ;  

uc_scr_wr_ex3       <= uc_scr_wr_ex3_l2 and not ex3_instr_flush       ;

uc_end_ex3    <= uc_end_ex3_l2    and not ex3_instr_flush;

uc_scr_wr_ex4_ld <= uc_scr_wr_ex3 and (uc_scr_sel_ex3(0) or uc_scr_sel_ex3(1));  -- uc_scr_sel_ex2=00 only writes in ex3

-- uc_scr write pipe -----------------------------
   uc_scr_wr_pipe_ex4:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 7)
    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_wr_pipe_ex4_scin,
      scout    => uc_scr_wr_pipe_ex4_scout,
      ---------------------------------------------
      din(0)      => uc_scr_wr_ex4_ld,
      din(1 to 2) => uc_scr_sel_ex3(0 to 1),
      din(3 to 4) => uc_scr_thread_ex3(0 to 1),
      din(5)      => uc_end_ex3,
      din(6)      => uc_beg_ex3,
      ---------------------------------------------
      dout(0)      => uc_scr_wr_ex4_l2,
      dout(1 to 2) => uc_scr_sel_ex4(0 to 1),
      dout(3 to 4) => uc_scr_thread_ex4(0 to 1),
      dout(5)      => uc_end_ex4_l2,
      dout(6)      => uc_beg_ex4
      ---------------------------------------------
      );

ex4_instr_flush  <= ((uc_scr_thread_ex4(0 to 1) = "00" and xu_ex4_flush(0)) or
                     (uc_scr_thread_ex4(0 to 1) = "01" and xu_ex4_flush(1)) or
                     (uc_scr_thread_ex4(0 to 1) = "10" and xu_ex4_flush(2)) or
                     (uc_scr_thread_ex4(0 to 1) = "11" and xu_ex4_flush(3)) );

uc_scr_wr_ex4 <= uc_scr_wr_ex4_l2 and not ex4_instr_flush;

uc_end_ex4    <= uc_end_ex4_l2    and not ex4_instr_flush;

-- uc_scr write pipe -----------------------------
   uc_scr_wr_pipe_ex5:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 6)
    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_wr_pipe_ex5_scin,
      scout    => uc_scr_wr_pipe_ex5_scout,
      ---------------------------------------------
      din(0)      => uc_scr_wr_ex4,
      din(1 to 2) => uc_scr_sel_ex4(0 to 1),
      din(3 to 4) => uc_scr_thread_ex4(0 to 1),
      din(5)      => uc_end_ex4,
      ---------------------------------------------
      dout(0)      => uc_scr_wr_ex5_l2,
      dout(1 to 2) => uc_scr_sel_ex5(0 to 1),
      dout(3 to 4) => uc_scr_thread_ex5(0 to 1),
      dout(5)      => uc_end_ex5_l2
      ---------------------------------------------
      );

ex5_instr_flush  <= ((uc_scr_thread_ex5(0 to 1) = "00" and xu_ex5_flush(0)) or
                     (uc_scr_thread_ex5(0 to 1) = "01" and xu_ex5_flush(1)) or
                     (uc_scr_thread_ex5(0 to 1) = "10" and xu_ex5_flush(2)) or
                     (uc_scr_thread_ex5(0 to 1) = "11" and xu_ex5_flush(3)) );

uc_scr_wr_ex5 <= uc_scr_wr_ex5_l2 and not ex5_instr_flush;

uc_end_ex5    <= uc_end_ex5_l2    and not ex5_instr_flush;

-- uc_scr write pipe -----------------------------
   uc_scr_wr_pipe_ex6:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 6)
    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => uc_scr_wr_pipe_ex6_scin,
      scout    => uc_scr_wr_pipe_ex6_scout,
      ---------------------------------------------
      din(0)      => uc_scr_wr_ex5,
      din(1 to 2) => uc_scr_sel_ex5(0 to 1),
      din(3 to 4) => uc_scr_thread_ex5(0 to 1),
      din(5)      => uc_end_ex5,
      ---------------------------------------------
      dout(0)      => uc_scr_wr_ex6,
      dout(1 to 2) => uc_scr_sel_ex6(0 to 1),
      dout(3 to 4) => uc_scr_thread_ex6(0 to 1),
      dout(5)      => uc_end_ex6_l2
      ---------------------------------------------
      );



q1_p_ulp_early_ld(0) <=  (not uc_scr_t0_l2(3) and not uc_scr_t0_l2(4)) or  uc_scr_t0_l2(5);   

q1_p_ulp_early_ld(1) <=  (not uc_scr_t1_l2(3) and not uc_scr_t1_l2(4)) or  uc_scr_t1_l2(5);   

q1_p_ulp_early_ld(2) <=  (not uc_scr_t2_l2(3) and not uc_scr_t2_l2(4)) or  uc_scr_t2_l2(5);   

q1_p_ulp_early_ld(3) <=  (not uc_scr_t3_l2(3) and not uc_scr_t3_l2(4)) or  uc_scr_t3_l2(5);   


   q1_p_ulp_early:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, width => 4)
    port map (
      nclk     => nclk,                  act      => msr_fp_act,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,
      delay_lclkr => delay_lclkr,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,
      thold_b  => thold_0_b, sg       => sg_0,
      scin     => q1_p_ulp_early_scin,
      scout    => q1_p_ulp_early_scout,
      ---------------------------------------------
      din(0 to 3)  => q1_p_ulp_early_ld(0 to 3),
                             
      ---------------------------------------------
      dout(0 to 3) => q1_p_ulp_early_l2(0 to 3)

      ---------------------------------------------
      );









-- q1_p_ulp_rf0 selects s3 instead of s1
-- q1_m_ulp_rf0 changes  multiply by 3ff000... to 3fefffff...


--@@ ESPRESSO ABLE START @@
-- .i 4-- .o 3
-- .ilb q1r_zero_rf0 q1ulpr_zero_rf0  q1r_sign_rf0 q1ulpr_sign_rf0
-- .ob q1_p_ulp_rf0 q1_rf0 q1_m_ulp_rf0
-- .type fr
-- #
-- ###################################################################################################################
-- #
-- #       q1r_zero_rf0                          q1r_sign_rf0            q1_p_ulp_rf0
-- #       |  q1ulpr_zero_rf0                    |  q1ulpr_sign_rf0      |  q1_rf0
-- #       |  |                                  |  |                    |  |  q1_m_ulp_rf0
-- #       |  |                                  |  |                    |  |  |
-- ###################################################################################################################
--
--         0  1                                  -  -                    1  0  0
--         1  0                                  -  -                    0  1  0
--         0  0                                  0  0                    1  0  0
--         0  0                                  0  1                    0  1  0
--         0  0                                  1  1                    0  0  1
-- ###################################################################################################################
-- .e
--@@ ESPRESSO ABLE END @@

--@@ ESPRESSO OGIC START @@
-- logic generated on: Fri Jul 13 08:08:16 2007


q1_m_ulp_rf0 <= (not q1r_zero_rf0 and not q1ulpr_zero_rf0 and  q1r_sign_rf0);


--@@ ESPRESSO OGIC END @@


uc_fc_1_minus <=      q1_m_ulp_rf0 and uc_normal_end_rf0 ;      --    1 - 1/2 ulp   (3FEFFF...)
uc_fc_1_0     <=  not q1_m_ulp_rf0 and uc_end_rf0_v ;             --    1.0   (3FF000...)




 f_dcd_rf1_div_beg       <=      uc_div_beg_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_sqrt_beg      <=      uc_sqrt_beg_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_mid        <=      uc_mid_rf1 and not rf1_ucfmul and not  perr_sm_running ; 
 f_dcd_rf1_uc_end        <=      uc_end_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_special    <=      special_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fa_pos     <=      uc_fa_pos_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fc_pos     <=      uc_fc_pos_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fb_pos     <=      uc_fb_pos_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fc_hulp    <=      uc_fc_hulp_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fc_0_5     <=      uc_fc_0_5_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fc_1_0     <=      uc_fc_1_0_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fc_1_minus <=      uc_fc_1_minus_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fb_1_0     <=      uc_fb_1_0_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fb_0_75    <=      uc_fb_0_75_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fb_0_5     <=      uc_fb_0_5_rf1 and not  perr_sm_running ; 

 f_dcd_rf1_uc_fa_dis_par    <=      uc_fa_dis_par_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fb_dis_par    <=      uc_fb_dis_par_rf1 and not  perr_sm_running ; 
 f_dcd_rf1_uc_fc_dis_par    <=      uc_fc_dis_par_rf1 and not  perr_sm_running ; 

 uc_op_rnd_v_rf1            <=   uc_op_rnd_v_rf1_l2  and not  perr_sm_running ; 
 uc_op_rnd_rf1              <=   uc_op_rnd_rf1_l2   ;




 f_dcd_rf1_uc_ft_pos     <=  
                                 not res_sign_rf1  and not perr_sm_running when uc_end_rf1='1' and special_rf1='0' else 
                                 '0';

 f_dcd_rf1_uc_ft_neg     <=      
                                 res_sign_rf1  and not perr_sm_running    when uc_end_rf1='1' and special_rf1='0' else 
                                 '0';



res_sign_rf1 <=   (uc_scr_t0_l2(1) and uc_scr_thread_rf1 = "00") or 
                  (uc_scr_t1_l2(1) and uc_scr_thread_rf1 = "01") or
                  (uc_scr_t2_l2(1) and uc_scr_thread_rf1 = "10") or
                  (uc_scr_t3_l2(1) and uc_scr_thread_rf1 = "11");



q1r_sign_ex2 <=     (uc_scr_t0_l2(2) and uc_scr_thread_ex2 = "00") or 
                    (uc_scr_t1_l2(2) and uc_scr_thread_ex2 = "01") or
                    (uc_scr_t2_l2(2) and uc_scr_thread_ex2 = "10") or
                    (uc_scr_t3_l2(2) and uc_scr_thread_ex2 = "11");

q1r_zero_ex2 <=     (uc_scr_t0_l2(3) and uc_scr_thread_ex2 = "00") or 
                    (uc_scr_t1_l2(3) and uc_scr_thread_ex2 = "01") or
                    (uc_scr_t2_l2(3) and uc_scr_thread_ex2 = "10") or
                    (uc_scr_t3_l2(3) and uc_scr_thread_ex2 = "11"); 

q1ulpr_sign_ex2 <=  (uc_scr_t0_l2(4) and uc_scr_thread_ex2 = "00") or 
                    (uc_scr_t1_l2(4) and uc_scr_thread_ex2 = "01") or
                    (uc_scr_t2_l2(4) and uc_scr_thread_ex2 = "10") or
                    (uc_scr_t3_l2(4) and uc_scr_thread_ex2 = "11");

q1ulpr_zero_ex2 <=  (uc_scr_t0_l2(5) and uc_scr_thread_ex2 = "00") or 
                    (uc_scr_t1_l2(5) and uc_scr_thread_ex2 = "01") or
                    (uc_scr_t2_l2(5) and uc_scr_thread_ex2 = "10") or
                    (uc_scr_t3_l2(5) and uc_scr_thread_ex2 = "11");

q1hulpr_sign_ex2 <= (uc_scr_t0_l2(6) and uc_scr_thread_ex2 = "00") or 
                    (uc_scr_t1_l2(6) and uc_scr_thread_ex2 = "01") or 
                    (uc_scr_t2_l2(6) and uc_scr_thread_ex2 = "10") or 
                    (uc_scr_t3_l2(6) and uc_scr_thread_ex2 = "11");   

uc_round_mode_ex2(0) <= (uc_round_mode_l2(0) and uc_scr_thread_ex2 = "00") or 
                        (uc_round_mode_l2(2) and uc_scr_thread_ex2 = "01") or 
                        (uc_round_mode_l2(4) and uc_scr_thread_ex2 = "10") or 
                        (uc_round_mode_l2(6) and uc_scr_thread_ex2 = "11");
  
uc_round_mode_ex2(1) <= (uc_round_mode_l2(1) and uc_scr_thread_ex2 = "00") or 
                        (uc_round_mode_l2(3) and uc_scr_thread_ex2 = "01") or 
                        (uc_round_mode_l2(5) and uc_scr_thread_ex2 = "10") or 
                        (uc_round_mode_l2(7) and uc_scr_thread_ex2 = "11");   



--@@ ESPRESSO ABLE START @@
-- .i 7
-- .o 2
-- .ilb q1r_zero_ex2 q1ulpr_zero_ex2 uc_round_mode_ex2(0) uc_round_mode_ex2(1) q1r_sign_ex2 q1ulpr_sign_ex2 q1hulpr_sign_ex2
-- .ob uc_gs_ex2(0) uc_gs_ex2(1)
-- .type fr
-- #
-- ###################################################################################################################
-- #
-- #       q1r_zero_ex2       uc_round_mode_ex2  q1r_sign_ex2                                  uc_gs_ex2(0:1)
-- #       |  q1ulpr_zero_ex2 |                  |  q1ulpr_sign_ex2                            |
-- #       |  |               |                  |  |  q1hulpr_sign_ex2                        |
-- #       |  |               |                  |  |  |                                       |
-- ###################################################################################################################
--
--         0  1               --                 -  -  -                                       00
--         1  0               --                 -  -  -                                       00
--  # Nearest
--         0  0               00                 0  0  -                                       01
--         0  0               00                 0  1  0                                       11
--         0  0               00                 0  1  1                                       01
--         0  0               00                 1  1  -                                       11
--  # Zero
--         0  0               01                 -  -  -                                       01
--  # +Inf
--         0  0               10                 -  -  -                                       01
--  # -Inf
--         0  0               11                 -  -  -                                       01
-- ###################################################################################################################
-- .e
--@@ ESPRESSO ABLE END @@

--@@ ESPRESSO OGIC START @@
-- logic generated on: Thu Jul 19 13:06:53 2007
uc_gs_ex2(0) <= (not q1r_zero_ex2 and not q1ulpr_zero_ex2 and not uc_round_mode_ex2(0)
		 and not uc_round_mode_ex2(1) and  q1ulpr_sign_ex2
		 and not q1hulpr_sign_ex2) or
		(not q1r_zero_ex2 and not q1ulpr_zero_ex2
		 and not uc_round_mode_ex2(0) and not uc_round_mode_ex2(1)
		 and  q1r_sign_ex2);

uc_gs_ex2(1) <= (not q1r_zero_ex2 and not q1ulpr_zero_ex2);

--@@ ESPRESSO OGIC END @@



  
 f_dcd_ex2_uc_gs_v       <=      uc_gs_v_ex2  and not  perr_sm_running ; 
 f_dcd_ex2_uc_gs         <=      uc_gs_ex2(0 to 1); 
 f_dcd_ex2_uc_inc_lsb    <=      uc_inc_lsb_ex2  and not  perr_sm_running ; 


uc_ignore_flush_rf1 <= uc_div_beg_rf1 or uc_sqrt_beg_rf1;








-- when stage rf1 is valid the uc_scr will be sent out for the active thread
-- when stage rf0 and rf1 are not valid the uc_scr will be sent out for thread 0
-- when stage rf0 is valid and rf1 is not the stage 0 hook bits will be sent out

evnt_div_sqrt_ip(0 to 3) <= uc_scr_t0_l2(7) & uc_scr_t1_l2(7) & uc_scr_t2_l2(7) & uc_scr_t3_l2(7);


uc_hooks_debug( 0 to  7) <=   uc_scr_t0_l2(0 to 7);
uc_hooks_debug( 8 to 15) <=   uc_scr_t1_l2(0 to 7);
uc_hooks_debug(16 to 23) <=   uc_scr_t2_l2(0 to 7);
uc_hooks_debug(24 to 31) <=   uc_scr_t3_l2(0 to 7);

uc_hooks_debug(32 to 35) <=  uc_1st_instr_l2(0 to 3);
uc_hooks_debug(36)  <= uc_div_beg_rf1   ;
uc_hooks_debug(37)  <= uc_sqrt_beg_rf1  ;
uc_hooks_debug(38)  <= uc_mid_rf1       ;
uc_hooks_debug(39)  <= uc_end_rf1       ;
uc_hooks_debug(40)  <=  uc_fa_pos_rf1    ;
uc_hooks_debug(41)  <=  uc_fc_pos_rf1    ;
uc_hooks_debug(42)  <=  uc_fb_pos_rf1    ;
uc_hooks_debug(43)  <=  uc_fc_hulp_rf1   ;
uc_hooks_debug(44)  <=  uc_fc_0_5_rf1    ;
uc_hooks_debug(45)  <=  uc_fc_1_0_rf1      ;
uc_hooks_debug(46)  <=  uc_fc_1_minus_rf1  ;
uc_hooks_debug(47) <=  uc_fb_1_0_rf1      ;
uc_hooks_debug(48) <=  uc_fb_0_75_rf1     ;
uc_hooks_debug(49) <=  uc_fb_0_5_rf1      ;
uc_hooks_debug(50) <=  uc_op_rnd_v_rf1_l2    ;
uc_hooks_debug(51) <=  uc_op_rnd_rf1_l2(0)   ;
uc_hooks_debug(52) <=  uc_op_rnd_rf1_l2(1)   ;

uc_hooks_debug(53) <= uc_end_rf1_l2       ;
uc_hooks_debug(54 to 55) <= uc_scr_thread_ex1(0 to 1) ;


-- Unused Nets
spare_unused(0 to 19) <= rf0_i(6 to 25);
spare_unused(20)      <= rf0_i(31);
spare_unused(21)      <= spare;

-- scan ring connections

  uc_1st_instr_scin      <= f_ucode_si                   & uc_1st_instr_scout(0 to 2);
  uc_round_mode_scin      <= uc_1st_instr_scout(3)       & uc_round_mode_scout(0 to 6);
  uc_scr_t0_scin          <= uc_round_mode_scout(7)      & uc_scr_t0_scout(0 to 10);
  uc_scr_t1_scin          <= uc_scr_t0_scout(11)         & uc_scr_t1_scout(0 to 10);
  uc_scr_t2_scin          <= uc_scr_t1_scout(11)         & uc_scr_t2_scout(0 to 10);
  uc_scr_t3_scin          <= uc_scr_t2_scout(11)         & uc_scr_t3_scout(0 to 10); 
  uc_scr_wr_pipe_rf1_scin <= uc_scr_t3_scout(11)         & uc_scr_wr_pipe_rf1_scout(0 to 6);
  uc_scr_wr_pipe_ex1_scin <= uc_scr_wr_pipe_rf1_scout(7) & uc_scr_wr_pipe_ex1_scout(0 to 7);
  uc_scr_wr_pipe_ex2_scin <= uc_scr_wr_pipe_ex1_scout(8) & uc_scr_wr_pipe_ex2_scout(0 to 7);
  uc_scr_wr_pipe_ex3_scin <= uc_scr_wr_pipe_ex2_scout(8) & uc_scr_wr_pipe_ex3_scout(0 to 5);
  uc_scr_wr_pipe_ex4_scin <= uc_scr_wr_pipe_ex3_scout(6) & uc_scr_wr_pipe_ex4_scout(0 to 5);
  uc_scr_wr_pipe_ex5_scin <= uc_scr_wr_pipe_ex4_scout(6) & uc_scr_wr_pipe_ex5_scout(0 to 4);
  uc_scr_wr_pipe_ex6_scin <= uc_scr_wr_pipe_ex5_scout(5) & uc_scr_wr_pipe_ex6_scout(0 to 4);
  q1_p_ulp_early_scin     <= uc_scr_wr_pipe_ex6_scout(5) & q1_p_ulp_early_scout(0 to 2);
  pipe_rf1_scin           <= q1_p_ulp_early_scout(3) & pipe_rf1_scout(0 to 20);
  f_ucode_so              <= pipe_rf1_scout(21);



end fuq_dcd_uc_hooks;
