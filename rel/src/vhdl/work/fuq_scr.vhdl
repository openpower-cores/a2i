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



--//## some inputs and their latches can be droped (fr/fi always enabled together)
--//##                                             (ox/ux always enabled together)
--//## spec always sets fr=fi=ox=ux=0
--//##############################################################################

-- cyc ex4 NORM  :  fpscr_rd
-- cyc ex5 RND   :
-- cyc ex6 FPSCR :  fpscr_wr
--
--
-- FPSCR BIT DEFINITIONS
-- ---------------- status 3:12,21:23 resetable
-- [ 0] fx    exception transition 0->1  (except mtfs,mtfsi)
-- [ 1] fex   "or" of enabled exceptions
-- [ 2] vex   "or" of invalid exceptions
-- [ 3] ox
-- [ 4] ux
-- [ 5] zx
-- [ 6] xx
-- [ 7] vxsnan
-- [ 8] vxisi (inf-sub-inf)
-- [ 9] vxidi
-- [10] vxzdz
-- [11] vximz
-- [12] vxvc
-- [13] fr
-- [14] fi
-- [15] FPRF C
-- [16] FPRF fpcc(lt)
-- [17] FPRF fpcc(gt)
-- [18] FPRF fpcc(eq)
-- [19] FPRF fpcc(nan)
-- [20] RESERVED
-- [21] vx-soft
-- [22] vx-sqrt
-- [23] vx-vci
-- -------------- control
-- [24] ve
-- [25] oe
-- [26] ue
-- [27] ze
-- [28] xe
-- [29] non-ieee
-- [30:31] rnd_mode 00:nr 01:zr 02:pi 03:ni
-----------------
-- FPRF
-- 10001  QNAN     [0]  qnan | den | (sign*zero)
-- 01001 -INF      [1]  sign * !zero
-- 01000 -norm     [2] !sign * !zero * !qnan
-- 11000 -den      [3]  zero
-- 10010 -zero     [4]  inf   | qnan
-- 00010 +zero
-- 10100 +den
-- 00100 +norm
-- 00101 +inf
              
 
ENTITY fuq_scr IS 
generic(  expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
PORT( 
  
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic_vector(4 to 7); -- tidn,
       mpw1_b                                    :in   std_ulogic_vector(4 to 7); -- tidn,
       mpw2_b                                    :in   std_ulogic_vector(0 to 1); -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;


       f_scr_si                                 :in   std_ulogic                   ;-- perv
       f_scr_so                                 :out  std_ulogic                   ;-- perv
       ex2_act_b                                :in   std_ulogic                   ;-- act writes
       f_cr2_ex3_thread_b                       :in   std_ulogic_vector(0 to 3)    ;-- thread write
       f_pic_ex5_scr_upd_move_b                 :in   std_ulogic                   ;
       f_pic_ex5_scr_upd_pipe_b                 :in   std_ulogic                   ;
       f_dcd_ex6_cancel                         :in   std_ulogic                   ;

       f_pic_ex5_fprf_spec_b                     :in   std_ulogic_vector(0 to 4)    ;--FPRF for special cases
       f_pic_ex5_compare_b                       :in   std_ulogic                   ;
       f_pic_ex5_fprf_pipe_v_b                   :in   std_ulogic                   ;
       f_pic_ex5_fprf_hold_b                     :in   std_ulogic                   ;--compare
       f_pic_ex5_fi_spec_b                       :in   std_ulogic                   ;
       f_pic_ex5_fi_pipe_v_b                     :in   std_ulogic                   ;
       f_pic_ex5_fr_spec_b                       :in   std_ulogic                   ;
       f_pic_ex5_fr_pipe_v_b                     :in   std_ulogic                   ;
       f_pic_ex5_ox_spec_b                       :in   std_ulogic                   ;
       f_pic_ex5_ox_pipe_v_b                     :in   std_ulogic                   ;
       f_pic_ex5_ux_spec_b                       :in   std_ulogic                   ;
       f_pic_ex5_ux_pipe_v_b                     :in   std_ulogic                   ;
                                                
       f_pic_ex5_flag_vxsnan_b                   :in   std_ulogic                   ;--//# sig_nan
       f_pic_ex5_flag_vxisi_b                    :in   std_ulogic                   ;--//# inf_sub_inf
       f_pic_ex5_flag_vxidi_b                    :in   std_ulogic                   ;--//# inf_div_inf
       f_pic_ex5_flag_vxzdz_b                    :in   std_ulogic                   ;--//# zer_div_zer
       f_pic_ex5_flag_vximz_b                    :in   std_ulogic                   ;--//# inf_mul_zer
       f_pic_ex5_flag_vxvc_b                     :in   std_ulogic                   ;--//# inval_cmp
       f_pic_ex5_flag_vxsqrt_b                   :in   std_ulogic                   ;--//# inval_sqrt
       f_pic_ex5_flag_vxcvi_b                    :in   std_ulogic                   ;--//# inval_convert
       f_pic_ex5_flag_zx_b                       :in   std_ulogic                   ;--//# div_zer
       
       f_cr2_ex3_fpscr_bit_data_b                :in   std_ulogic_vector(0 to  3)   ;
       f_cr2_ex3_fpscr_bit_mask_b                :in   std_ulogic_vector(0 to  3)   ;
       f_cr2_ex3_fpscr_nib_mask_b                :in   std_ulogic_vector(0 to  8)   ;
       f_cr2_ex3_mcrfs_b                         :in   std_ulogic                   ;
       f_cr2_ex3_mtfsf_b                         :in   std_ulogic                   ;
       f_cr2_ex3_mtfsfi_b                        :in   std_ulogic                   ;
       f_cr2_ex3_mtfsbx_b                        :in   std_ulogic                   ;


       f_nrm_ex5_fpscr_wr_dat_dfp                :in   std_ulogic_vector(0 to 3) ;
       f_scr_ex5_fpscr_rd_dat_dfp                :out  std_ulogic_vector(0 to 3) ;
                        
       f_nrm_ex5_fpscr_wr_dat                    :in   std_ulogic_vector(0 to 31)   ;

       f_cr2_ex6_fpscr_rd_dat                    :in   std_ulogic_vector(24 to 31)  ;--//# for update
       f_cr2_ex5_fpscr_rd_dat                    :in   std_ulogic_vector(24 to 31)  ;--//# for mffs
       f_scr_ex5_fpscr_rd_dat                    :out  std_ulogic_vector(0 to 31)   ;--//# f_rnd
          
       f_rnd_ex6_flag_up                         :in   std_ulogic                   ;
       f_rnd_ex6_flag_fi                         :in   std_ulogic                   ;
       f_rnd_ex6_flag_ox                         :in   std_ulogic                   ;
       f_rnd_ex6_flag_den                        :in   std_ulogic                   ;
       f_rnd_ex6_flag_sgn                        :in   std_ulogic                   ;
       f_rnd_ex6_flag_inf                        :in   std_ulogic                   ;
       f_rnd_ex6_flag_zer                        :in   std_ulogic                   ;
       f_rnd_ex6_flag_ux                         :in   std_ulogic                   ;
    
       f_scr_ex7_cr_fld                          :out  std_ulogic_vector(0 to 3)    ;--//#iu
       f_scr_ex7_fx_thread0                      :out  std_ulogic_vector(0 to 3)    ;--//#iu
       f_scr_ex7_fx_thread1                      :out  std_ulogic_vector(0 to 3)    ;--//#iu
       f_scr_ex7_fx_thread2                      :out  std_ulogic_vector(0 to 3)    ;--//#iu
       f_scr_ex7_fx_thread3                      :out  std_ulogic_vector(0 to 3)     --//#iu
        

); -- end ports
 
 
 
end fuq_scr; -- ENTITY
 
 
architecture fuq_scr of fuq_scr is 
 
    constant tiup  :std_ulogic := '1';
    constant tidn  :std_ulogic := '0';
 
    signal sg_0                                  :std_ulogic                   ;
    signal thold_0_b , thold_0, forcee              :std_ulogic                   ;
    signal ex3_act                                 :std_ulogic                   ;
    signal ex2_act                                 :std_ulogic                   ;
    signal ex4_act                                 :std_ulogic                   ;
    signal ex5_act                                 :std_ulogic                   ;
    signal ex6_act                                 :std_ulogic                   ;
    signal ex6_th0_act                             :std_ulogic                   ;
    signal ex6_th1_act                             :std_ulogic                   ;
    signal ex6_th2_act                             :std_ulogic                   ;
    signal ex6_th3_act                             :std_ulogic                   ;
    signal ex6_th0_act_wocan                       :std_ulogic                   ;
    signal ex6_th1_act_wocan                       :std_ulogic                   ;
    signal ex6_th2_act_wocan                       :std_ulogic                   ;
    signal ex6_th3_act_wocan                       :std_ulogic                   ;
    signal act_spare_unused                        :std_ulogic_vector(0 to 3)    ;
    -------------------
    signal act_so                                  :std_ulogic_vector(0 to 13)   ;--SCAN
    signal act_si                                  :std_ulogic_vector(0 to 13)   ;--SCAN

    signal ex4_ctl_so                              :std_ulogic_vector(0 to 24)   ;--SCAN
    signal ex4_ctl_si                              :std_ulogic_vector(0 to 24)   ;--SCAN
    signal ex5_ctl_so                              :std_ulogic_vector(0 to 24)   ;--SCAN
    signal ex5_ctl_si                              :std_ulogic_vector(0 to 24)   ;--SCAN
    signal ex6_ctl_so                              :std_ulogic_vector(0 to 24)   ;--SCAN
    signal ex6_ctl_si                              :std_ulogic_vector(0 to 24)   ;--SCAN

    signal ex6_flag_so                             :std_ulogic_vector(0 to 24)   ;--SCAN
    signal ex6_flag_si                             :std_ulogic_vector(0 to 24)   ;--SCAN
    signal ex6_mvdat_so                            :std_ulogic_vector(0 to 27)   ;--SCAN
    signal ex6_mvdat_si                            :std_ulogic_vector(0 to 27)   ;--SCAN

    signal fpscr_th0_so                            :std_ulogic_vector(0 to 27)   ;--SCAN
    signal fpscr_th0_si                            :std_ulogic_vector(0 to 27)   ;--SCAN
    signal fpscr_th1_so                            :std_ulogic_vector(0 to 27)   ;--SCAN
    signal fpscr_th1_si                            :std_ulogic_vector(0 to 27)   ;--SCAN
    signal fpscr_th2_so                            :std_ulogic_vector(0 to 27)   ;--SCAN
    signal fpscr_th2_si                            :std_ulogic_vector(0 to 27)   ;--SCAN
    signal fpscr_th3_so                            :std_ulogic_vector(0 to 27)   ;--SCAN
    signal fpscr_th3_si                            :std_ulogic_vector(0 to 27)   ;--SCAN

    signal ex7_crf_so                              :std_ulogic_vector(0 to 3)    ;--SCAN
    signal ex7_crf_si                              :std_ulogic_vector(0 to 3)    ;--SCAN
    -------------------
    signal ex6_mrg                                 :std_ulogic_vector(0 to 23)   ;    
    signal ex6_mrg_dfp                             :std_ulogic_vector(0 to 3)   ;    
    signal ex6_fpscr_dfp_din                       :std_ulogic_vector(0 to 3)   ;    
    signal ex6_fpscr_din                           :std_ulogic_vector(0 to 23)   ;    
    signal ex6_cr_fld  , ex6_cr_fld_x              :std_ulogic_vector(0 to 3)    ;
    signal ex6_fpscr_move                          :std_ulogic_vector(0 to 23)   ;
    signal ex6_fpscr_pipe                          :std_ulogic_vector(0 to 23)   ;
    signal ex6_fpscr_move_dfp                      :std_ulogic_vector(0 to 3)   ;
    signal ex6_fpscr_pipe_dfp                      :std_ulogic_vector(0 to 3)   ;

    signal fpscr_dfp_th0                           :std_ulogic_vector(0 to 3)   ;
    signal fpscr_dfp_th1                           :std_ulogic_vector(0 to 3)   ;
    signal fpscr_dfp_th2                           :std_ulogic_vector(0 to 3)   ;
    signal fpscr_dfp_th3                           :std_ulogic_vector(0 to 3)   ;

    signal fpscr_th0                               :std_ulogic_vector(0 to 23)   ;
    signal fpscr_th1                               :std_ulogic_vector(0 to 23)   ;
    signal fpscr_th2                               :std_ulogic_vector(0 to 23)   ;
    signal fpscr_th3                               :std_ulogic_vector(0 to 23)   ;

    signal fpscr_rd_dat                            :std_ulogic_vector(0 to 31)   ;
    signal fpscr_rd_dat_dfp                        :std_ulogic_vector(0 to 3)    ;
    signal ex7_cr_fld                              :std_ulogic_vector(0 to 3)    ;
    signal ex6_fprf_pipe                           :std_ulogic_vector(0 to 4)    ;

    signal ex4_thread                              :std_ulogic_vector(0 to 3)    ;
    signal ex5_thread                              :std_ulogic_vector(0 to 3)    ;
    signal ex6_thread                              :std_ulogic_vector(0 to 3)    ;

    signal ex5_th0_act                             :std_ulogic                   ;
    signal ex5_th1_act                             :std_ulogic                   ;
    signal ex5_th2_act                             :std_ulogic                   ;
    signal ex5_th3_act                             :std_ulogic                   ;
    signal ex6_upd_move                            :std_ulogic                   ;
    signal ex6_upd_pipe                            :std_ulogic                   ;

    signal ex6_fprf_spec                           :std_ulogic_vector(0 to 4)    ; 
    signal ex6_compare                             :std_ulogic                   ;
    signal ex6_fprf_pipe_v                         :std_ulogic                   ;
    signal ex6_fprf_hold                           :std_ulogic                   ;
    signal ex6_fi_spec                             :std_ulogic                   ;
    signal ex6_fi_pipe_v                           :std_ulogic                   ;
    signal ex6_fr_spec                             :std_ulogic                   ;
    signal ex6_fr_pipe_v                           :std_ulogic                   ;
    signal ex6_ox_spec                             :std_ulogic                   ;
    signal ex6_ox_pipe_v                           :std_ulogic                   ;
    signal ex6_ux_spec                             :std_ulogic                   ;
    signal ex6_ux_pipe_v                           :std_ulogic                   ;
    signal ex6_mv_data                             :std_ulogic_vector(0 to 23)   ;
    signal ex6_mv_data_dfp                         :std_ulogic_vector(0 to 3)    ;
    signal ex6_mv_sel                              :std_ulogic_vector(0 to 23)   ;
    signal ex6_mv_sel_dfp                          :std_ulogic_vector(0 to 3)    ;

    signal ex6_flag_vxsnan                         :std_ulogic                   ;
    signal ex6_flag_vxisi                          :std_ulogic                   ;
    signal ex6_flag_vxidi                          :std_ulogic                   ;
    signal ex6_flag_vxzdz                          :std_ulogic                   ;
    signal ex6_flag_vximz                          :std_ulogic                   ;
    signal ex6_flag_vxvc                           :std_ulogic                   ;
    signal ex6_flag_vxsqrt                         :std_ulogic                   ;
    signal ex6_flag_vxcvi                          :std_ulogic                   ;
    signal ex6_flag_zx                             :std_ulogic                   ;
    signal ex6_fpscr_wr_dat                        :std_ulogic_vector(0 to 23)   ;
    signal ex6_fpscr_wr_dat_dfp                    :std_ulogic_vector(0 to 3)   ;
    signal ex6_new_excp                            :std_ulogic                   ;
    signal ex4_bit_data                            :std_ulogic_vector(0 to 3); 
    signal ex4_bit_mask                            :std_ulogic_vector(0 to 3); 
    signal ex4_nib_mask                            :std_ulogic_vector(0 to 8); 
    signal ex4_mcrfs                               :std_ulogic;             
    signal ex4_mtfsf                               :std_ulogic;             
    signal ex4_mtfsfi                              :std_ulogic;            
    signal ex4_mtfsbx                              :std_ulogic;            
    signal ex5_bit_data                            :std_ulogic_vector(0 to 3); 
    signal ex5_bit_mask                            :std_ulogic_vector(0 to 3); 
    signal ex5_nib_mask                            :std_ulogic_vector(0 to 8); 
    signal ex5_mcrfs                               :std_ulogic;             
    signal ex5_mtfsf                               :std_ulogic;             
    signal ex5_mtfsfi                              :std_ulogic;            
    signal ex5_mtfsbx                              :std_ulogic;            
    signal ex6_bit_data                            :std_ulogic_vector(0 to 3); 
    signal ex6_bit_mask                            :std_ulogic_vector(0 to 3); 
    signal ex6_nib_mask            :std_ulogic_vector(0 to 8); 
    signal ex6_mcrfs                               :std_ulogic;             
    signal ex6_mtfsf                               :std_ulogic;             
    signal ex6_mtfsfi                              :std_ulogic;            
    signal ex6_mtfsbx                              :std_ulogic;            
    signal unused_stuff                            :std_ulogic;
   signal ex5_scr_upd_move, ex5_scr_upd_pipe :std_ulogic ;
  signal ex3_thread         :std_ulogic_vector(0 to 3);
  signal ex3_fpscr_bit_data :std_ulogic_vector(0 to 3);
  signal ex3_fpscr_bit_mask :std_ulogic_vector(0 to 3);
  signal ex3_fpscr_nib_mask :std_ulogic_vector(0 to 8);
  signal ex3_mcrfs          :std_ulogic        ;
  signal ex3_mtfsf          :std_ulogic        ;
  signal ex3_mtfsfi         :std_ulogic        ;
  signal ex3_mtfsbx         :std_ulogic        ;
  signal  ex5_flag_vxsnan       :std_ulogic;
  signal  ex5_flag_vxisi        :std_ulogic;
  signal  ex5_flag_vxidi        :std_ulogic;
  signal  ex5_flag_vxzdz        :std_ulogic;
  signal  ex5_flag_vximz        :std_ulogic;
  signal  ex5_flag_vxvc         :std_ulogic;
  signal  ex5_flag_vxsqrt       :std_ulogic;
  signal  ex5_flag_vxcvi        :std_ulogic;
  signal  ex5_flag_zx           :std_ulogic;
  signal  ex5_fprf_spec         :std_ulogic_vector(0 to 4);
  signal  ex5_compare           :std_ulogic;
  signal  ex5_fprf_pipe_v       :std_ulogic;
  signal  ex5_fprf_hold         :std_ulogic;
  signal  ex5_fi_spec           :std_ulogic;
  signal  ex5_fi_pipe_v         :std_ulogic;
  signal  ex5_fr_spec           :std_ulogic;
  signal  ex5_fr_pipe_v         :std_ulogic;
  signal  ex5_ox_spec           :std_ulogic;
  signal  ex5_ox_pipe_v         :std_ulogic;
  signal  ex5_ux_spec           :std_ulogic;
  signal  ex5_ux_pipe_v         :std_ulogic;
  signal  ex6_upd_move_nmcrfs    :std_ulogic;


begin 


--//############################################
--//# pervasive
--//############################################
    
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

       
 
--//############################################
--//# ACT LATCHES
--//############################################

   ex2_act <= not ex2_act_b ;
   ex5_scr_upd_move <= not f_pic_ex5_scr_upd_move_b ;
   ex5_scr_upd_pipe <= not f_pic_ex5_scr_upd_pipe_b ;


    act_lat:  tri_rlmreg_p generic map (width=> 14, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(6)  ,
        mpw1_b           => mpw1_b(6)       ,
        mpw2_b           => mpw2_b(1)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => fpu_enable, 
        thold_b          => thold_0_b,
        sg               => sg_0,
        scout            => act_so   ,                     
        scin             => act_si   ,                   
        -------------------
        din(0)             => act_spare_unused(0),
        din(1)             => act_spare_unused(1),        
        din(2)             => ex2_act,
        din(3)             => ex3_act,
        din(4)             => ex4_act,
        din(5)             => ex5_act,
        din(6)             => ex5_th0_act ,     
        din(7)             => ex5_th1_act ,
        din(8)             => ex5_th2_act ,
        din(9)             => ex5_th3_act ,       
        din(10)            => ex5_scr_upd_move , 
        din(11)            => ex5_scr_upd_pipe ,
        din(12)            => act_spare_unused(2),
        din(13)            => act_spare_unused(3),
        -------------------
       dout(0)             => act_spare_unused(0),
       dout(1)             => act_spare_unused(1),
       dout(2)             => ex3_act,
       dout(3)             => ex4_act,
       dout(4)             => ex5_act,
       dout(5)             => ex6_act,        
       dout(6)             => ex6_th0_act_wocan ,     
       dout(7)             => ex6_th1_act_wocan ,
       dout(8)             => ex6_th2_act_wocan ,
       dout(9)             => ex6_th3_act_wocan ,
       dout(10)            => ex6_upd_move , 
       dout(11)            => ex6_upd_pipe ,
       dout(12)            => act_spare_unused(2) ,
       dout(13)            => act_spare_unused(3) );


    ex5_th0_act   <= ( ex5_thread(0) and ex5_act and ( ex5_scr_upd_move or ex5_scr_upd_pipe) ) ; 
    ex5_th1_act   <= ( ex5_thread(1) and ex5_act and ( ex5_scr_upd_move or ex5_scr_upd_pipe) ) ; 
    ex5_th2_act   <= ( ex5_thread(2) and ex5_act and ( ex5_scr_upd_move or ex5_scr_upd_pipe) ) ; 
    ex5_th3_act   <= ( ex5_thread(3) and ex5_act and ( ex5_scr_upd_move or ex5_scr_upd_pipe) ) ; 
    
    ex6_th0_act   <= ex6_th0_act_wocan and not f_dcd_ex6_cancel;
    ex6_th1_act   <= ex6_th1_act_wocan and not f_dcd_ex6_cancel;
    ex6_th2_act   <= ex6_th2_act_wocan and not f_dcd_ex6_cancel;
    ex6_th3_act   <= ex6_th3_act_wocan and not f_dcd_ex6_cancel;

--//##############################################
--//# EX4 latches
--//##############################################

     ex3_thread(0 to 3)         <= not f_cr2_ex3_thread_b(0 to 3)         ;
     ex3_fpscr_bit_data(0 to 3) <= not f_cr2_ex3_fpscr_bit_data_b(0 to 3) ;
     ex3_fpscr_bit_mask(0 to 3) <= not f_cr2_ex3_fpscr_bit_mask_b(0 to 3) ;
     ex3_fpscr_nib_mask(0 to 8) <= not f_cr2_ex3_fpscr_nib_mask_b(0 to 8) ;
     ex3_mcrfs                  <= not f_cr2_ex3_mcrfs_b                  ;
     ex3_mtfsf                  <= not f_cr2_ex3_mtfsf_b                  ;
     ex3_mtfsfi                 <= not f_cr2_ex3_mtfsfi_b                 ; 
     ex3_mtfsbx                 <= not f_cr2_ex3_mtfsbx_b                 ;

       

    ex4_ctl_lat:  tri_rlmreg_p generic map (width=> 25, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(4) ,
        mpw1_b           => mpw1_b(4)      ,
        mpw2_b           => mpw2_b(0)      ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => ex3_act ,
        thold_b          => thold_0_b,
        sg               => sg_0,
        scout            => ex4_ctl_so   ,                     
        scin             => ex4_ctl_si   ,                   
        -------------------
         din(0 to 3)        => ex3_thread(0 to 3)         ,
         din(4 to 7)        => ex3_fpscr_bit_data(0 to 3) ,
         din(8 to 11)       => ex3_fpscr_bit_mask(0 to 3) ,
         din(12 to 20)      => ex3_fpscr_nib_mask(0 to 8) ,
         din(21)            => ex3_mcrfs                  ,
         din(22)            => ex3_mtfsf                  ,
         din(23)            => ex3_mtfsfi                 , 
         din(24)            => ex3_mtfsbx                 ,
        -------------------
       dout(0 to 3)        => ex4_thread(0 to 3)   ,
       dout(4 to 7)        => ex4_bit_data(0 to 3) ,
       dout(8 to 11)       => ex4_bit_mask(0 to 3) ,
       dout(12 to 20)      => ex4_nib_mask(0 to 8) ,
       dout(21)            => ex4_mcrfs            ,
       dout(22)            => ex4_mtfsf            ,
       dout(23)            => ex4_mtfsfi           , 
       dout(24)            => ex4_mtfsbx          );


--//##############################################
--//# EX5 latches
--//##############################################

 
    ex5_ctl_lat:  tri_rlmreg_p generic map (width=> 25, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(5) ,
        mpw1_b           => mpw1_b(5)      ,
        mpw2_b           => mpw2_b(1)      ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => ex4_act ,
        thold_b          => thold_0_b,
        sg               => sg_0,
        scout            => ex5_ctl_so   ,                     
        scin             => ex5_ctl_si   ,                   
        -------------------
         din(0 to 3)        => ex4_thread(0 to 3)  ,
         din(4 to 7)        => ex4_bit_data(0 to 3),
         din(8 to 11)       => ex4_bit_mask(0 to 3),
         din(12 to 20)      => ex4_nib_mask(0 to 8),
         din(21)            => ex4_mcrfs           ,
         din(22)            => ex4_mtfsf           ,
         din(23)            => ex4_mtfsfi          , 
         din(24)            => ex4_mtfsbx          , 
        -------------------
       dout(0 to 3)        => ex5_thread(0 to 3)   ,
       dout(4 to 7)        => ex5_bit_data(0 to 3) ,
       dout(8 to 11)       => ex5_bit_mask(0 to 3) ,
       dout(12 to 20)      => ex5_nib_mask(0 to 8) ,
       dout(21)            => ex5_mcrfs            ,
       dout(22)            => ex5_mtfsf            ,
       dout(23)            => ex5_mtfsfi           ,
       dout(24)            => ex5_mtfsbx          ); 
 
--//##############################################
--//# EX6 latches
--//##############################################


    ex6_ctl_lat:  tri_rlmreg_p generic map (width=> 25, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(6) ,
        mpw1_b           => mpw1_b(6)      ,
        mpw2_b           => mpw2_b(1)      ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => ex5_act,
        thold_b          => thold_0_b,
        sg               => sg_0,
        scout            => ex6_ctl_so   ,                     
        scin             => ex6_ctl_si   ,                   
        -------------------
         din(0 to 3)        => ex5_thread(0 to 3),
         din(4 to 7)        => ex5_bit_data(0 to 3),
         din(8 to 11)       => ex5_bit_mask(0 to 3),
         din(12 to 20)      => ex5_nib_mask(0 to 8),
         din(21)            => ex5_mcrfs           ,
         din(22)            => ex5_mtfsf           ,
         din(23)            => ex5_mtfsfi          , 
         din(24)            => ex5_mtfsbx          , 
        -------------------
       dout(0 to 3)        => ex6_thread(0 to 3)   ,
       dout(4 to 7)        => ex6_bit_data(0 to 3) ,
       dout(8 to 11)       => ex6_bit_mask(0 to 3) ,
       dout(12 to 20)      => ex6_nib_mask(0 to 8) ,
       dout(21)            => ex6_mcrfs            ,
       dout(22)            => ex6_mtfsf            ,
       dout(23)            => ex6_mtfsfi           ,
       dout(24)            => ex6_mtfsbx          );


        ex5_flag_vxsnan       <= not f_pic_ex5_flag_vxsnan_b       ;
        ex5_flag_vxisi        <= not f_pic_ex5_flag_vxisi_b          ;
        ex5_flag_vxidi        <= not f_pic_ex5_flag_vxidi_b        ;
        ex5_flag_vxzdz        <= not f_pic_ex5_flag_vxzdz_b        ;
        ex5_flag_vximz        <= not f_pic_ex5_flag_vximz_b        ;
        ex5_flag_vxvc         <= not f_pic_ex5_flag_vxvc_b         ;
        ex5_flag_vxsqrt       <= not f_pic_ex5_flag_vxsqrt_b       ;
        ex5_flag_vxcvi        <= not f_pic_ex5_flag_vxcvi_b        ;
        ex5_flag_zx           <= not f_pic_ex5_flag_zx_b           ;
        ex5_fprf_spec(0 to 4) <= not f_pic_ex5_fprf_spec_b(0 to 4) ;
        ex5_compare           <= not f_pic_ex5_compare_b           ;
        ex5_fprf_pipe_v       <= not f_pic_ex5_fprf_pipe_v_b       ;
        ex5_fprf_hold         <= not f_pic_ex5_fprf_hold_b         ;
        ex5_fi_spec           <= not f_pic_ex5_fi_spec_b           ;
        ex5_fi_pipe_v         <= not f_pic_ex5_fi_pipe_v_b         ;
        ex5_fr_spec           <= not f_pic_ex5_fr_spec_b           ;
        ex5_fr_pipe_v         <= not f_pic_ex5_fr_pipe_v_b         ;
        ex5_ox_spec           <= not f_pic_ex5_ox_spec_b           ;
        ex5_ox_pipe_v         <= not f_pic_ex5_ox_pipe_v_b         ;
        ex5_ux_spec           <= not f_pic_ex5_ux_spec_b           ;
        ex5_ux_pipe_v         <= not f_pic_ex5_ux_pipe_v_b         ;


    ex6_flag_lat:  tri_rlmreg_p generic map (width=> 25, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(6) ,
        mpw1_b           => mpw1_b(6)      ,
        mpw2_b           => mpw2_b(1)      ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => ex5_act,
        thold_b          => thold_0_b,
        sg               => sg_0,
        scout            => ex6_flag_so  ,                      
        scin             => ex6_flag_si  ,                    
        -------------------
         din(0)             => ex5_flag_vxsnan       ,--//# sig_nan
         din(1)             => ex5_flag_vxisi        ,--//# inf_sub_inf
         din(2)             => ex5_flag_vxidi        ,--//# inf_div_inf
         din(3)             => ex5_flag_vxzdz        ,--//# zer_div_zer
         din(4)             => ex5_flag_vximz        ,--//# inf_mul_zer
         din(5)             => ex5_flag_vxvc         ,--//# inval_cmp
         din(6)             => ex5_flag_vxsqrt       ,--//# inval_sqrt
         din(7)             => ex5_flag_vxcvi        ,--//# inval_convert
         din(8)             => ex5_flag_zx           ,--//# div_zer
         din(9 to 13)       => ex5_fprf_spec(0 to 4) ,--FPRF/'0'FPCC for special cases
         din(14)            => ex5_compare           ,
         din(15)            => ex5_fprf_pipe_v       ,--fprf update exluding compare
         din(16)            => ex5_fprf_hold         ,--fprf update including compare
         din(17)            => ex5_fi_spec           ,
         din(18)            => ex5_fi_pipe_v         ,
         din(19)            => ex5_fr_spec           ,
         din(20)            => ex5_fr_pipe_v         ,
         din(21)            => ex5_ox_spec           ,
         din(22)            => ex5_ox_pipe_v         ,
         din(23)            => ex5_ux_spec           ,
         din(24)            => ex5_ux_pipe_v         ,
        -------------------
       dout(0)             => ex6_flag_vxsnan         ,--LAT--
       dout(1)             => ex6_flag_vxisi          ,--LAT--
       dout(2)             => ex6_flag_vxidi          ,--LAT--
       dout(3)             => ex6_flag_vxzdz          ,--LAT--
       dout(4)             => ex6_flag_vximz          ,--LAT--
       dout(5)             => ex6_flag_vxvc           ,--LAT--
       dout(6)             => ex6_flag_vxsqrt         ,--LAT--
       dout(7)             => ex6_flag_vxcvi          ,--LAT--
       dout(8)             => ex6_flag_zx             ,--LAT--
       dout(9 to 13)       => ex6_fprf_spec  (0 to 4) ,--LAT--
       dout(14)            => ex6_compare             ,--LAT--
       dout(15)            => ex6_fprf_pipe_v         ,--LAT--
       dout(16)            => ex6_fprf_hold           ,--LAT--
       dout(17)            => ex6_fi_spec             ,--LAT--
       dout(18)            => ex6_fi_pipe_v           ,--LAT--
       dout(19)            => ex6_fr_spec             ,--LAT--
       dout(20)            => ex6_fr_pipe_v           ,--LAT--
       dout(21)            => ex6_ox_spec             ,--LAT--
       dout(22)            => ex6_ox_pipe_v           ,--LAT--
       dout(23)            => ex6_ux_spec             ,--LAT--
       dout(24)            => ex6_ux_pipe_v          );--LAT--
        
              
   ex6_mvdat_lat:  tri_rlmreg_p generic map (width=> 28, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(6) ,
        mpw1_b           => mpw1_b(6)      ,
        mpw2_b           => mpw2_b(1)      ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => ex5_act,
        thold_b          => thold_0_b,
        sg               => sg_0,
        scout            => ex6_mvdat_so  ,                      
        scin             => ex6_mvdat_si  ,                    
        -------------------
        din(0 to 3)      => f_nrm_ex5_fpscr_wr_dat_dfp(0 to 3)  ,
        din(4 to 27)     => f_nrm_ex5_fpscr_wr_dat(0 to 23)  ,
        dout(0 to 3)     =>       ex6_fpscr_wr_dat_dfp(0 to 3) ,--LAT--
        dout(4 to 27)    =>       ex6_fpscr_wr_dat(0 to 23) );--LAT--
        

  
 

--//##############################################
--//# EX6 logic
--//##############################################

    --//#-----------------------------------------
    --//# select field for mcrfs
    --//#-----------------------------------------

    ex6_cr_fld_x(0 to 3) <=       
        (         ex6_mrg( 0 to  3)        and (0 to 3=> ex6_nib_mask(0) ) ) or 
        (         ex6_mrg( 4 to  7)        and (0 to 3=> ex6_nib_mask(1) ) ) or 
        (         ex6_mrg( 8 to 11)        and (0 to 3=> ex6_nib_mask(2) ) ) or 
        (         ex6_mrg(12 to 15)        and (0 to 3=> ex6_nib_mask(3) ) ) or 
        (         ex6_mrg(16 to 19)        and (0 to 3=> ex6_nib_mask(4) ) ) or 
        ( (tidn & ex6_mrg(21 to 23))       and (0 to 3=> ex6_nib_mask(5) ) ) or  --[20] is a reserved bit
        ( f_cr2_ex6_fpscr_rd_dat(24 to 27) and (0 to 3=> ex6_nib_mask(6) ) ) or 
        ( f_cr2_ex6_fpscr_rd_dat(28 to 31) and (0 to 3=> ex6_nib_mask(7) ) );

    ex6_upd_move_nmcrfs <= ex6_upd_move and not ex6_mcrfs ;

    ex6_cr_fld(0 to 3) <=
         ( ex6_mrg(0 to 3)       and (0 to 3 => not ex6_upd_move       and not ex6_upd_pipe) ) or   -- fmr
         ( ex6_cr_fld_x(0 to 3)  and (0 to 3 =>     ex6_mcrfs                              ) ) or  -- the old value
         ( ex6_fpscr_din(0 to 3) and (0 to 3 =>     ex6_upd_pipe                           ) ) or  -- what the math update will be
         ( ex6_fpscr_din(0 to 3) and (0 to 3 =>     ex6_upd_move_nmcrfs                    ) ) ;   -- what the math update will be


    --//#-----------------------------------------------------------------------
    --//# move to logic mtfsf mtfsfi mcrf mtfsb0 mtfsb1
    --//#-----------------------------------------------------------------------
      -- if mcrfs  : if nib_mask selects -> reset if (0,3:12,21:23) (bit mask=1111)
      -- if mtfsfi : if nib_mask selects -> load with bit data      (bit mask=1111)
      -- if mtfsf  : if nib_mask selects -> load with wr_data       (bit mask=1111)
      -- if mtfsb0 : if nib_mask selects -> load with bit data      (if bit mask)
      -- if mtfsb1 : if nib_mask selects -> load with bit_data      (if bit mask)


    ex6_mv_data_dfp(0 to 3) <= ( ex6_bit_data(0 to 3) and (0 to 3 => not ex6_mtfsf) ) or (ex6_fpscr_wr_dat_dfp(0 to  3) and (0 to 3 => ex6_mtfsf) );

    ex6_mv_data( 0 to  3) <= ( ex6_bit_data(0 to 3) and (0 to 3 => not ex6_mtfsf) ) or (ex6_fpscr_wr_dat( 0 to  3) and (0 to 3 => ex6_mtfsf) );
    ex6_mv_data( 4 to  7) <= ( ex6_bit_data(0 to 3) and (0 to 3 => not ex6_mtfsf) ) or (ex6_fpscr_wr_dat( 4 to  7) and (0 to 3 => ex6_mtfsf) );
    ex6_mv_data( 8 to 11) <= ( ex6_bit_data(0 to 3) and (0 to 3 => not ex6_mtfsf) ) or (ex6_fpscr_wr_dat( 8 to 11) and (0 to 3 => ex6_mtfsf) );
    ex6_mv_data(12 to 15) <= ( ex6_bit_data(0 to 3) and (0 to 3 => not ex6_mtfsf) ) or (ex6_fpscr_wr_dat(12 to 15) and (0 to 3 => ex6_mtfsf) );
    ex6_mv_data(16 to 19) <= ( ex6_bit_data(0 to 3) and (0 to 3 => not ex6_mtfsf) ) or (ex6_fpscr_wr_dat(16 to 19) and (0 to 3 => ex6_mtfsf) );
    ex6_mv_data(20 to 23) <= ( ex6_bit_data(0 to 3) and (0 to 3 => not ex6_mtfsf) ) or (ex6_fpscr_wr_dat(20 to 23) and (0 to 3 => ex6_mtfsf) );


    ex6_mv_sel_dfp(0) <= ex6_bit_mask(0) and ex6_nib_mask(8) ;
    ex6_mv_sel_dfp(1) <= ex6_bit_mask(1) and ex6_nib_mask(8) ;
    ex6_mv_sel_dfp(2) <= ex6_bit_mask(2) and ex6_nib_mask(8) ;
    ex6_mv_sel_dfp(3) <= ex6_bit_mask(3) and ex6_nib_mask(8) ;

    ex6_mv_sel( 0) <= ex6_bit_mask(0) and ex6_nib_mask(0) ; -- fx
    ex6_mv_sel( 1) <= tidn; --UNUSED                        -- fex
    ex6_mv_sel( 2) <= tidn; --UNUSED                        -- vx
    ex6_mv_sel( 3) <= ex6_bit_mask(3) and ex6_nib_mask(0) ; -- ox
    ex6_mv_sel( 4) <= ex6_bit_mask(0) and ex6_nib_mask(1) ; -- ux
    ex6_mv_sel( 5) <= ex6_bit_mask(1) and ex6_nib_mask(1) ; -- zx
    ex6_mv_sel( 6) <= ex6_bit_mask(2) and ex6_nib_mask(1) ; -- xx
    ex6_mv_sel( 7) <= ex6_bit_mask(3) and ex6_nib_mask(1) ; -- vxsnan
    ex6_mv_sel( 8) <= ex6_bit_mask(0) and ex6_nib_mask(2) ; -- vxisi
    ex6_mv_sel( 9) <= ex6_bit_mask(1) and ex6_nib_mask(2) ; -- vxidi
    ex6_mv_sel(10) <= ex6_bit_mask(2) and ex6_nib_mask(2) ; -- vxzdz
    ex6_mv_sel(11) <= ex6_bit_mask(3) and ex6_nib_mask(2) ; -- vximz
    ex6_mv_sel(12) <= ex6_bit_mask(0) and ex6_nib_mask(3) ; -- vxvc
    ex6_mv_sel(13) <= ex6_bit_mask(1) and ex6_nib_mask(3) and not ex6_mcrfs; -- fr
    ex6_mv_sel(14) <= ex6_bit_mask(2) and ex6_nib_mask(3) and not ex6_mcrfs; -- fi
    ex6_mv_sel(15) <= ex6_bit_mask(3) and ex6_nib_mask(3) and not ex6_mcrfs; -- FPRF C
    ex6_mv_sel(16) <= ex6_bit_mask(0) and ex6_nib_mask(4) and not ex6_mcrfs; -- FPRF fpcc(lt)
    ex6_mv_sel(17) <= ex6_bit_mask(1) and ex6_nib_mask(4) and not ex6_mcrfs; -- FPRF fpcc(gt)
    ex6_mv_sel(18) <= ex6_bit_mask(2) and ex6_nib_mask(4) and not ex6_mcrfs; -- FPRF fpcc(eq)
    ex6_mv_sel(19) <= ex6_bit_mask(3) and ex6_nib_mask(4) and not ex6_mcrfs; -- FPRF fpcc(nan)
    ex6_mv_sel(20) <= ex6_bit_mask(0) and ex6_nib_mask(5) and not ex6_mcrfs; -- RESERVED
    ex6_mv_sel(21) <= ex6_bit_mask(1) and ex6_nib_mask(5) ; -- vx-soft
    ex6_mv_sel(22) <= ex6_bit_mask(2) and ex6_nib_mask(5) ; -- vx-sqrt
    ex6_mv_sel(23) <= ex6_bit_mask(3) and ex6_nib_mask(5) ; -- vx-vci
      
    ex6_fpscr_move( 0) <=  (ex6_mrg( 0) and not ex6_mv_sel( 0)) or (ex6_mv_data(0) and ex6_mv_sel( 0) );
    ex6_fpscr_move( 1) <=  tidn; --//unused (from other bits after move/pipe selection)
    ex6_fpscr_move( 2) <=  tidn; --//unused (from other bits after move/pipe selection)
    ex6_fpscr_move( 3 to 23) <=  
          ( ex6_mrg(3 to 23)     and not ex6_mv_sel(3 to 23) ) or 
          ( ex6_mv_data(3 to 23) and     ex6_mv_sel(3 to 23) ) ;

    ex6_fpscr_move_dfp(0 to 3) <=  
          ( ex6_mrg_dfp(0 to 3)     and not ex6_mv_sel_dfp(0 to 3) ) or 
          ( ex6_mv_data_dfp(0 to 3) and     ex6_mv_sel_dfp(0 to 3) ) ;

    --//#------------------------------------------------------------------------
    --//# decode fprf field for pipe settings
    --//#------------------------------------------------------------------------
       -- FPRF
       -- 10001  QNAN     [0]  qnan | den | (sign*zero)
       -- 01001 -INF      [1]  sign * !zero
       -- 01000 -norm     [2] !sign * !zero * !qnan
       -- 11000 -den      [3]  zero
       -- 10010 -zero     [4]  inf   | qnan
       -- 00010 +zero
       -- 10100 +den
       -- 00100 +norm
       -- 00101 +inf

       ex6_fprf_pipe(0) <= (    f_rnd_ex6_flag_sgn and     f_rnd_ex6_flag_zer) or
                           (    f_rnd_ex6_flag_den and not f_rnd_ex6_flag_zer) ;

       ex6_fprf_pipe(1) <= (    f_rnd_ex6_flag_sgn and not f_rnd_ex6_flag_zer);
       ex6_fprf_pipe(2) <= (not f_rnd_ex6_flag_sgn and not f_rnd_ex6_flag_zer);
       ex6_fprf_pipe(3) <=  f_rnd_ex6_flag_zer;
       ex6_fprf_pipe(4) <=  f_rnd_ex6_flag_inf    ;
    
    --//#------------------------------------------------------------------------
    --//# functional updates (excp enable cases, special setting vs pipe setting)
    --//#------------------------------------------------------------------------
    
    ex6_fpscr_pipe( 0) <= ex6_mrg( 0) ; -- <sticky aspect> check 0->1 excp after selection for move/pipe
    ex6_fpscr_pipe( 1) <= tidn ; --// unused (from other bits after move/pipe selection)
    ex6_fpscr_pipe( 2) <= tidn ; --// unused (from other bits after move/pipe selection)
    ex6_fpscr_pipe( 3) <= ex6_mrg( 3)  or  --ox STICKY
                          ex6_ox_spec  or 
                         (ex6_ox_pipe_v and f_rnd_ex6_flag_ox );
    ex6_fpscr_pipe( 4) <= ex6_mrg( 4)  or      --ux STICKY
                          ex6_ux_spec  or
                         (ex6_ux_pipe_v and f_rnd_ex6_flag_ux );
    ex6_fpscr_pipe( 5) <= ex6_mrg( 5) or ex6_flag_zx       ; --sticky

    ex6_fpscr_pipe( 6) <= (ex6_mrg( 6)                         ) or -- ex6_fpscr_pipe(14); --sticky version of fi
                          (ex6_fi_spec                         ) or 
                          (ex6_fi_pipe_v and f_rnd_ex6_flag_fi );

    ex6_fpscr_pipe( 7) <= ex6_mrg( 7) or ex6_flag_vxsnan   ; --sticky
    ex6_fpscr_pipe( 8) <= ex6_mrg( 8) or ex6_flag_vxisi    ; --sticky
    ex6_fpscr_pipe( 9) <= ex6_mrg( 9) or ex6_flag_vxidi    ; --sticky
    ex6_fpscr_pipe(10) <= ex6_mrg(10) or ex6_flag_vxzdz    ; --sticky
    ex6_fpscr_pipe(11) <= ex6_mrg(11) or ex6_flag_vximz    ; --sticky
    ex6_fpscr_pipe(12) <= ex6_mrg(12) or ex6_flag_vxvc     ; --sticky


    ex6_fpscr_pipe(13) <=  --fr NOT sticky
                         (ex6_mrg(13)   and     ex6_compare    ) or 
                         (ex6_fr_spec                          ) or 
                         (ex6_fr_pipe_v and f_rnd_ex6_flag_up  );
    ex6_fpscr_pipe(14) <=  --fi NOT sticky
                         (ex6_mrg(14)   and     ex6_compare   ) or 
                         (ex6_fi_spec                         ) or 
                         (ex6_fi_pipe_v and f_rnd_ex6_flag_fi );



    ex6_fpscr_pipe(15) <=  --FPRF C    NOT sticky
                        (ex6_mrg(15)     and ex6_fprf_hold    ) or 
                        (ex6_mrg(15)     and ex6_compare      ) or 
                        (ex6_fprf_spec(0)                     ) or 
                        (ex6_fprf_pipe_v and ex6_fprf_pipe(0) ) ;


    ex6_fpscr_pipe(16) <=  --FPRF fpdd(lt)
                        (ex6_mrg(16)     and ex6_fprf_hold    ) or 
                        (ex6_fprf_spec(1)                     ) or 
                        (ex6_fprf_pipe_v and ex6_fprf_pipe(1) ) ;       
    ex6_fpscr_pipe(17) <=  --FPRF fpcc(gt)
                        (ex6_mrg(17)     and ex6_fprf_hold    ) or 
                        (ex6_fprf_spec(2)                     ) or 
                        (ex6_fprf_pipe_v and ex6_fprf_pipe(2) ) ;       
    ex6_fpscr_pipe(18) <=  --FPRF fpcc(eq)
                        (ex6_mrg(18)     and ex6_fprf_hold    ) or 
                        (ex6_fprf_spec(3)                     ) or 
                        (ex6_fprf_pipe_v and ex6_fprf_pipe(3) ) ;       
    ex6_fpscr_pipe(19) <= --FPRF fpcc(nan)
                        (ex6_mrg(19)     and ex6_fprf_hold    ) or 
                        (ex6_fprf_spec(4)                     ) or 
                        (ex6_fprf_pipe_v and ex6_fprf_pipe(4) ) ;

    ex6_fpscr_pipe(20) <= tidn        ; -- reseved bit <UNUSED>
    ex6_fpscr_pipe(21) <= ex6_mrg(21) ; -- VXSOFT
    ex6_fpscr_pipe(22) <= ex6_mrg(22) or ex6_flag_vxsqrt ;--sticky
    ex6_fpscr_pipe(23) <= ex6_mrg(23) or ex6_flag_vxcvi  ;--sticky

    ex6_fpscr_pipe_dfp(0 to 3) <= ex6_mrg_dfp(0 to 3);


    --//#------------------------------------------------------------------------
    --//# creating the funny or bits afer the selection
    --//#------------------------------------------------------------------------

   
    ex6_fpscr_dfp_din(0) <= (ex6_fpscr_move_dfp(0) and ex6_upd_move) or (ex6_fpscr_pipe_dfp(0) and ex6_upd_pipe) ;
    ex6_fpscr_dfp_din(1) <= (ex6_fpscr_move_dfp(1) and ex6_upd_move) or (ex6_fpscr_pipe_dfp(1) and ex6_upd_pipe) ;
    ex6_fpscr_dfp_din(2) <= (ex6_fpscr_move_dfp(2) and ex6_upd_move) or (ex6_fpscr_pipe_dfp(2) and ex6_upd_pipe) ;
    ex6_fpscr_dfp_din(3) <= (ex6_fpscr_move_dfp(3) and ex6_upd_move) or (ex6_fpscr_pipe_dfp(3) and ex6_upd_pipe) ;


    ex6_fpscr_din(23) <= (ex6_fpscr_move(23) and ex6_upd_move) or (ex6_fpscr_pipe(23) and ex6_upd_pipe) ;
    ex6_fpscr_din(22) <= (ex6_fpscr_move(22) and ex6_upd_move) or (ex6_fpscr_pipe(22) and ex6_upd_pipe) ;
    ex6_fpscr_din(21) <= (ex6_fpscr_move(21) and ex6_upd_move) or (ex6_fpscr_pipe(21) and ex6_upd_pipe) ;
    ex6_fpscr_din(20) <= tidn; -- reserved
    ex6_fpscr_din(19) <= (ex6_fpscr_move(19) and ex6_upd_move) or (ex6_fpscr_pipe(19) and ex6_upd_pipe) ;
    ex6_fpscr_din(18) <= (ex6_fpscr_move(18) and ex6_upd_move) or (ex6_fpscr_pipe(18) and ex6_upd_pipe) ;
    ex6_fpscr_din(17) <= (ex6_fpscr_move(17) and ex6_upd_move) or (ex6_fpscr_pipe(17) and ex6_upd_pipe) ;
    ex6_fpscr_din(16) <= (ex6_fpscr_move(16) and ex6_upd_move) or (ex6_fpscr_pipe(16) and ex6_upd_pipe) ;
    ex6_fpscr_din(15) <= (ex6_fpscr_move(15) and ex6_upd_move) or (ex6_fpscr_pipe(15) and ex6_upd_pipe) ;
    ex6_fpscr_din(14) <= (ex6_fpscr_move(14) and ex6_upd_move) or (ex6_fpscr_pipe(14) and ex6_upd_pipe) ;
    ex6_fpscr_din(13) <= (ex6_fpscr_move(13) and ex6_upd_move) or (ex6_fpscr_pipe(13) and ex6_upd_pipe) ;
    ex6_fpscr_din(12) <= (ex6_fpscr_move(12) and ex6_upd_move) or (ex6_fpscr_pipe(12) and ex6_upd_pipe) ;
    ex6_fpscr_din(11) <= (ex6_fpscr_move(11) and ex6_upd_move) or (ex6_fpscr_pipe(11) and ex6_upd_pipe) ;
    ex6_fpscr_din(10) <= (ex6_fpscr_move(10) and ex6_upd_move) or (ex6_fpscr_pipe(10) and ex6_upd_pipe) ;    
    ex6_fpscr_din( 9) <= (ex6_fpscr_move( 9) and ex6_upd_move) or (ex6_fpscr_pipe( 9) and ex6_upd_pipe) ;
    ex6_fpscr_din( 8) <= (ex6_fpscr_move( 8) and ex6_upd_move) or (ex6_fpscr_pipe( 8) and ex6_upd_pipe) ;
    ex6_fpscr_din( 7) <= (ex6_fpscr_move( 7) and ex6_upd_move) or (ex6_fpscr_pipe( 7) and ex6_upd_pipe) ;
    ex6_fpscr_din( 6) <= (ex6_fpscr_move( 6) and ex6_upd_move) or (ex6_fpscr_pipe( 6) and ex6_upd_pipe) ;
    ex6_fpscr_din( 5) <= (ex6_fpscr_move( 5) and ex6_upd_move) or (ex6_fpscr_pipe( 5) and ex6_upd_pipe) ;
    ex6_fpscr_din( 4) <= (ex6_fpscr_move( 4) and ex6_upd_move) or (ex6_fpscr_pipe( 4) and ex6_upd_pipe) ;
    ex6_fpscr_din( 3) <= (ex6_fpscr_move( 3) and ex6_upd_move) or (ex6_fpscr_pipe( 3) and ex6_upd_pipe) ;
    
    ex6_fpscr_din(2) <= -- or all invalid operation exceptions
           ex6_fpscr_din(7)  or -- vxsnan
           ex6_fpscr_din(8)  or -- vxisi
           ex6_fpscr_din(9)  or -- vxidi
           ex6_fpscr_din(10) or -- vxzdz
           ex6_fpscr_din(11) or -- vximx
           ex6_fpscr_din(12) or -- vxvc
           ex6_fpscr_din(21) or -- vxzdz
           ex6_fpscr_din(22) or -- vximx
           ex6_fpscr_din(23) ;  -- vxvc
    
    ex6_fpscr_din(1) <= -- masked or of all exception bits
         ( ex6_fpscr_din(2)  and f_cr2_ex6_fpscr_rd_dat(24) ) or  -- vx* / ve
         ( ex6_fpscr_din(3)  and f_cr2_ex6_fpscr_rd_dat(25) ) or  -- ox  / oe
         ( ex6_fpscr_din(4)  and f_cr2_ex6_fpscr_rd_dat(26) ) or  -- ux  / ue
         ( ex6_fpscr_din(5)  and f_cr2_ex6_fpscr_rd_dat(27) ) or  -- zx  / ze
         ( ex6_fpscr_din(6)  and f_cr2_ex6_fpscr_rd_dat(28) ) ;   -- xx  / xe
    
    ex6_fpscr_din( 0) <= 
       (ex6_fpscr_move( 0) and ex6_upd_move) or     
       (ex6_fpscr_pipe( 0) and ex6_upd_pipe) or 
       (ex6_new_excp       and not ex6_mtfsf and not ex6_mtfsfi );
       
   ex6_new_excp <= -- only check the exception bits
       (not ex6_mrg( 3) and ex6_fpscr_din( 3) ) or -- ox
       (not ex6_mrg( 4) and ex6_fpscr_din( 4) ) or -- ux
       (not ex6_mrg( 5) and ex6_fpscr_din( 5) ) or -- zx
       (not ex6_mrg( 6) and ex6_fpscr_din( 6) ) or -- xx
       (not ex6_mrg( 7) and ex6_fpscr_din( 7) ) or -- vxsnan
       (not ex6_mrg( 8) and ex6_fpscr_din( 8) ) or -- vxisi
       (not ex6_mrg( 9) and ex6_fpscr_din( 9) ) or -- vxidi
       (not ex6_mrg(10) and ex6_fpscr_din(10) ) or -- vxzdz
       (not ex6_mrg(11) and ex6_fpscr_din(11) ) or -- vximx
       (not ex6_mrg(12) and ex6_fpscr_din(12) ) or -- vxvc
       (not ex6_mrg(21) and ex6_fpscr_din(21) ) or -- vxzdz
       (not ex6_mrg(22) and ex6_fpscr_din(22) ) or -- vximx
       (not ex6_mrg(23) and ex6_fpscr_din(23) ) ;  -- vxvc
       
       
           
--//##############################################
--//# EX7 latches
--//##############################################
       
    
    fpscr_th0_lat:  tri_rlmreg_p generic map (width=> 28, expand_type => expand_type) port map (
        forcee => forcee,
        delay_lclkr      => delay_lclkr(7) ,
        mpw1_b           => mpw1_b(7)      ,
        mpw2_b           => mpw2_b(1)      ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex6_th0_act,
        scout            => fpscr_th0_so  ,                      
        scin             => fpscr_th0_si  ,                    
        -------------------
        din(0 to 3)      => ex6_fpscr_dfp_din(0 to 3),
        din(4 to 27)     => ex6_fpscr_din(0 to 23),
        dout(0 to 3)     => fpscr_dfp_th0(0 to 3) ,--LAT--
        dout(4 to 27)    => fpscr_th0(0 to 23) );--LAT--
       
    fpscr_th1_lat:  tri_rlmreg_p generic map (width=> 28, expand_type => expand_type) port map (
        forcee => forcee,
        delay_lclkr      => delay_lclkr(7) ,
        mpw1_b           => mpw1_b(7)      ,
        mpw2_b           => mpw2_b(1)      ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex6_th1_act,
        scout            => fpscr_th1_so  ,                      
        scin             => fpscr_th1_si  ,                    
        -------------------
        din(0 to 3)      => ex6_fpscr_dfp_din(0 to 3),
        din(4 to 27)     => ex6_fpscr_din(0 to 23),
        dout(0 to 3)     => fpscr_dfp_th1(0 to 3) ,--LAT--
        dout(4 to 27)    => fpscr_th1(0 to 23) );--LAT--
       
    fpscr_th2_lat:  tri_rlmreg_p generic map (width=> 28, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(7) ,
        mpw1_b           => mpw1_b(7)      ,
        mpw2_b           => mpw2_b(1)      ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex6_th2_act,
        scout            => fpscr_th2_so  ,                      
        scin             => fpscr_th2_si  ,                    
        -------------------
        din(0 to 3)      => ex6_fpscr_dfp_din(0 to 3),
        din(4 to 27)     => ex6_fpscr_din(0 to 23),
        dout(0 to 3)     => fpscr_dfp_th2(0 to 3) ,--LAT--
        dout(4 to 27)    => fpscr_th2(0 to 23) );--LAT--
       
    fpscr_th3_lat:  tri_rlmreg_p generic map (width=> 28, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(7) ,
        mpw1_b           => mpw1_b(7)      ,
        mpw2_b           => mpw2_b(1)      ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex6_th3_act,
        scout            => fpscr_th3_so  ,                      
        scin             => fpscr_th3_si  ,                    
        -------------------
        din(0 to 3)      => ex6_fpscr_dfp_din(0 to 3),
        din(4 to 27)     => ex6_fpscr_din(0 to 23),
        dout(0 to 3)     => fpscr_dfp_th3(0 to 3) ,--LAT--
        dout(4 to 27)    => fpscr_th3(0 to 23)   );--LAT--
       

    ex7_crf_lat:  tri_rlmreg_p generic map (width=> 4, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(7) ,
        mpw1_b           => mpw1_b(7)      ,
        mpw2_b           => mpw2_b(1)      ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => ex6_act,
        thold_b          => thold_0_b,
        sg               => sg_0,
        scout            => ex7_crf_so  ,                      
        scin             => ex7_crf_si  ,                    
        -------------------
         din                => ex6_cr_fld(0 to 3),
        dout                => ex7_cr_fld(0 to 3) );--LAT--
       
   
    f_scr_ex7_cr_fld(0 to 3)        <= ex7_cr_fld(0 to 3)   ;--output--//#iu
    f_scr_ex7_fx_thread0(0 to 3)    <= fpscr_th0(0 to 3)   ;--output--//#iu
    f_scr_ex7_fx_thread1(0 to 3)    <= fpscr_th1(0 to 3)   ;--output--//#iu
    f_scr_ex7_fx_thread2(0 to 3)    <= fpscr_th2(0 to 3)   ;--output--//#iu
    f_scr_ex7_fx_thread3(0 to 3)    <= fpscr_th3(0 to 3)   ;--output--//#iu
 
--//##############################################
--//# read fpscr (mixed cycles)
--//##############################################
 
    fpscr_rd_dat_dfp(0 to 3) <= -- write data to bit 20 is "0"
       ( fpscr_dfp_th0(0 to 3) and (0 to 3 => ex5_thread(0) ) ) or 
       ( fpscr_dfp_th1(0 to 3) and (0 to 3 => ex5_thread(1) ) ) or 
       ( fpscr_dfp_th2(0 to 3) and (0 to 3 => ex5_thread(2) ) ) or 
       ( fpscr_dfp_th3(0 to 3) and (0 to 3 => ex5_thread(3) ) ) ;
       
    fpscr_rd_dat(0 to 23) <= -- write data to bit 20 is "0"
       ( fpscr_th0(0 to 23) and (0 to 23 => ex5_thread(0) ) ) or 
       ( fpscr_th1(0 to 23) and (0 to 23 => ex5_thread(1) ) ) or 
       ( fpscr_th2(0 to 23) and (0 to 23 => ex5_thread(2) ) ) or 
       ( fpscr_th3(0 to 23) and (0 to 23 => ex5_thread(3) ) ) ;
       
    ex6_mrg_dfp(0 to 3) <= -- write data to bit 20 is "0"
       ( fpscr_dfp_th0(0 to 3) and (0 to 3 => ex6_thread(0) ) ) or 
       ( fpscr_dfp_th1(0 to 3) and (0 to 3 => ex6_thread(1) ) ) or 
       ( fpscr_dfp_th2(0 to 3) and (0 to 3 => ex6_thread(2) ) ) or 
       ( fpscr_dfp_th3(0 to 3) and (0 to 3 => ex6_thread(3) ) ) ;
       
    ex6_mrg(0 to 23) <= -- write data to bit 20 is "0"
       ( fpscr_th0(0 to 23) and (0 to 23 => ex6_thread(0) ) ) or 
       ( fpscr_th1(0 to 23) and (0 to 23 => ex6_thread(1) ) ) or 
       ( fpscr_th2(0 to 23) and (0 to 23 => ex6_thread(2) ) ) or 
       ( fpscr_th3(0 to 23) and (0 to 23 => ex6_thread(3) ) ) ;
       


    fpscr_rd_dat (24 to 31) <= f_cr2_ex5_fpscr_rd_dat(24 to 31) ;
    f_scr_ex5_fpscr_rd_dat(0 to 31)    <= fpscr_rd_dat(0 to 31)   ;--output--//#f_rnd
    f_scr_ex5_fpscr_rd_dat_dfp(0 to 3) <= fpscr_rd_dat_dfp(0 to 3) ;

--//############################################
--//# scan
--//############################################

   
    ex4_ctl_si    (0 to 24) <= ex4_ctl_so     (1 to 24) &  f_scr_si;
    ex5_ctl_si    (0 to 24) <= ex5_ctl_so     (1 to 24) &  ex4_ctl_so    (0); 
    ex6_ctl_si    (0 to 24) <= ex6_ctl_so     (1 to 24) &  ex5_ctl_so    (0); 
    ex6_flag_si   (0 to 24) <= ex6_flag_so    (1 to 24) &  ex6_ctl_so    (0); 
    ex6_mvdat_si  (0 to 27) <= ex6_mvdat_so   (1 to 27) &  ex6_flag_so   (0) ;                 
    fpscr_th0_si  (0 to 27) <= fpscr_th0_so   (1 to 27) &  ex6_mvdat_so  (0) ;
    fpscr_th1_si  (0 to 27) <= fpscr_th1_so   (1 to 27) &  fpscr_th0_so  (0) ;                     
    fpscr_th2_si  (0 to 27) <= fpscr_th2_so   (1 to 27) &  fpscr_th1_so  (0) ;                     
    fpscr_th3_si  (0 to 27) <= fpscr_th3_so   (1 to 27) &  fpscr_th2_so  (0) ;                     
    ex7_crf_si    (0 to 3)  <= ex7_crf_so     (1 to 3)  &  fpscr_th3_so  (0) ;                        
    act_si        (0 to 13) <= act_so         (1 to 13) &  ex7_crf_so    (0) ;
    f_scr_so                <= act_so  (0) ;
 

    unused_stuff <=
           or_reduce( f_nrm_ex5_fpscr_wr_dat(24 to 31) ) or 
           ex6_mtfsbx         or 
           ex6_fpscr_move(1)  or 
           ex6_fpscr_move(2)  or 
           ex6_fpscr_move(20) or 
           ex6_fpscr_pipe(1)  or 
           ex6_fpscr_pipe(2)  or 
           ex6_fpscr_pipe(20) or 
           ex6_mv_data(1)     or 
           ex6_mv_data(2)     or 
           ex6_mv_sel(1)      or 
           ex6_mv_sel(2) ;

end; -- fuq_scr ARCHITECTURE
