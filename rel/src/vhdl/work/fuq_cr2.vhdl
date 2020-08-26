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


-- FPSCR BIT DEFINITIONS
-- -------------- control
-- [24] ve
-- [25] oe
-- [26] ue
-- [27] ze
-- [28] xe
-- [29] non-ieee
-- [30:31] rnd_mode 00:nr 01:zr 02:pi 03:ni
--
-- the rnd_mode must be read in ex2 of the using op
-- the rnd_mode is set in ex3 of the sending op (to_integer only)
-- there must be a 2 cycle bubble after update op
--
--  set   1  2  3
-- read   x  x  1  2

              
 
entity fuq_cr2 is 
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port( 

       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic_vector(1 to 7); -- tidn,
       mpw1_b                                    :in   std_ulogic_vector(1 to 7); -- tidn,
       mpw2_b                                    :in   std_ulogic_vector(0 to 1); -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;


       f_cr2_si                                 :in   std_ulogic                   ;-- perv
       f_cr2_so                                 :out  std_ulogic                   ;-- perv
       rf1_act                                  :in   std_ulogic                   ;-- HELP
       ex1_act                                  :in   std_ulogic                   ;-- act writes
       rf1_thread_b                             :in   std_ulogic_vector(0 to 3)    ;-- thread write
       f_dcd_ex6_cancel                         :in   std_ulogic                   ;--

       f_fmt_ex1_bop_byt                        :in  std_ulogic_vector(45 to 52); --for mtfsf to shadow reg
       f_dcd_rf1_fpscr_bit_data_b               :in  std_ulogic_vector(0 to 3);   --data to write to nibble (other than mtfsf)
       f_dcd_rf1_fpscr_bit_mask_b               :in  std_ulogic_vector(0 to 3);   --enable update of bit within the nibble
       f_dcd_rf1_fpscr_nib_mask_b               :in  std_ulogic_vector(0 to 8);   --enable update of this nibble
       f_dcd_rf1_mtfsbx_b                       :in  std_ulogic;                  --fpscr set bit, reset bit
       f_dcd_rf1_mcrfs_b                        :in  std_ulogic;                  --move fpscr field to cr and reset exceptions
       f_dcd_rf1_mtfsf_b                        :in  std_ulogic;                  --move fpr data to fpscr
       f_dcd_rf1_mtfsfi_b                       :in  std_ulogic;                  --move immediate data to fpscr

       f_cr2_ex3_thread_b                       :out  std_ulogic_vector(0 to 3)  ;--scr
       f_cr2_ex3_fpscr_bit_data_b               :out std_ulogic_vector(0 to 3);   --data to write to nibble (other than mtfsf)
       f_cr2_ex3_fpscr_bit_mask_b               :out std_ulogic_vector(0 to 3);   --enable update of bit within the nibble
       f_cr2_ex3_fpscr_nib_mask_b               :out std_ulogic_vector(0 to 8);   --enable update of this nibble
       f_cr2_ex3_mtfsbx_b                       :out std_ulogic;                  --fpscr set bit, reset bit
       f_cr2_ex3_mcrfs_b                        :out std_ulogic;                  --move fpscr field to cr and reset exceptions
       f_cr2_ex3_mtfsf_b                        :out std_ulogic;                  --move fpr data to fpscr
       f_cr2_ex3_mtfsfi_b                       :out std_ulogic;                  --move immediate data to fpscr

       f_cr2_ex5_fpscr_rd_dat                   :out  std_ulogic_vector(24 to 31); --scr
       f_cr2_ex6_fpscr_rd_dat                   :out  std_ulogic_vector(24 to 31); --scr
       f_cr2_ex1_fpscr_shadow                   :out  std_ulogic_vector(0 to 7)    --fpic


); -- end ports
 
 

end fuq_cr2; -- ENTITY
 
 
architecture fuq_cr2 of fuq_cr2 is 
 
  constant tiup :std_ulogic := '1';
  constant tidn :std_ulogic := '0';
 
 signal sg_0   :std_ulogic  ;
 signal thold_0_b , thold_0, forcee  :std_ulogic  ;
 signal ex6_th0_act  :std_ulogic  ;
 signal ex6_th1_act  :std_ulogic  ;
 signal ex6_th2_act  :std_ulogic  ;
 signal ex6_th3_act  :std_ulogic  ;
 signal ex2_act   :std_ulogic  ;
 signal ex3_act   :std_ulogic  ;
 signal ex4_act, ex5_act, ex6_act :std_ulogic  ;
 signal ex4_mv_to_op  :std_ulogic  ;
 signal ex5_mv_to_op  :std_ulogic  ;
 signal ex6_mv_to_op  :std_ulogic  ;
 
 signal ex1_thread   :std_ulogic_vector(0 to 3) ;
 signal ex2_thread   :std_ulogic_vector(0 to 3) ;
 signal ex3_thread   :std_ulogic_vector(0 to 3) ;
 signal ex4_thread   :std_ulogic_vector(0 to 3) ;
 signal ex5_thread   :std_ulogic_vector(0 to 3) ;
 signal ex6_thread   :std_ulogic_vector(0 to 3) ;
 signal act_spare_unused  :std_ulogic_vector(0 to 2) ;
 -------------------
 signal act_so   , act_si     :std_ulogic_vector(0 to 6) ;--SCAN
 signal ex1_ctl_so   , ex1_ctl_si    :std_ulogic_vector(0 to 33) ;--SCAN
 signal ex2_ctl_so   , ex2_ctl_si    :std_ulogic_vector(0 to 24) ;--SCAN
 signal ex3_ctl_so   , ex3_ctl_si    :std_ulogic_vector(0 to 24) ;--SCAN
 signal ex4_ctl_so   , ex4_ctl_si    :std_ulogic_vector(0 to 4) ;--SCAN
 signal ex5_ctl_so   , ex5_ctl_si    :std_ulogic_vector(0 to 4) ;--SCAN
 signal ex6_ctl_so   , ex6_ctl_si    :std_ulogic_vector(0 to 4) ;--SCAN
 signal shadow0_so   , shadow0_si    :std_ulogic_vector(0 to 7) ;--SCAN
 signal shadow1_so   , shadow1_si    :std_ulogic_vector(0 to 7) ;--SCAN
 signal shadow2_so   , shadow2_si    :std_ulogic_vector(0 to 7) ;--SCAN
 signal shadow3_so   , shadow3_si    :std_ulogic_vector(0 to 7) ;--SCAN
 signal shadow_byp2_so   , shadow_byp2_si    :std_ulogic_vector(0 to 7) ;--SCAN
 signal shadow_byp3_so   , shadow_byp3_si    :std_ulogic_vector(0 to 7) ;--SCAN
 signal shadow_byp4_so   , shadow_byp4_si    :std_ulogic_vector(0 to 7) ;--SCAN
 signal shadow_byp5_so   , shadow_byp5_si    :std_ulogic_vector(0 to 7) ;--SCAN
 signal shadow_byp6_so   , shadow_byp6_si    :std_ulogic_vector(0 to 7) ;--SCAN
 -------------------
 signal shadow0 :std_ulogic_vector(0 to 7) ;
 signal shadow1 :std_ulogic_vector(0 to 7) ;
 signal shadow2 :std_ulogic_vector(0 to 7) ;
 signal shadow3 :std_ulogic_vector(0 to 7) ;
 signal shadow_byp2 :std_ulogic_vector(0 to 7) ;
 signal shadow_byp3 :std_ulogic_vector(0 to 7) ;
 signal shadow_byp4 :std_ulogic_vector(0 to 7) ;
 signal shadow_byp5 :std_ulogic_vector(0 to 7) ;
 signal shadow_byp6 :std_ulogic_vector(0 to 7) ;
 signal shadow_byp2_din  :std_ulogic_vector(0 to 7) ;

 signal ex1_bit_sel  :std_ulogic_vector(0 to 7) ;
 signal ex1_fpscr_bit_data  :std_ulogic_vector(0 to 3);
 signal ex1_fpscr_bit_mask  :std_ulogic_vector(0 to 3);
 signal ex1_fpscr_nib_mask  :std_ulogic_vector(0 to 8);
 signal ex1_mtfsbx   :std_ulogic;
 signal ex1_mcrfs   :std_ulogic;
 signal ex1_mtfsf   :std_ulogic;
 signal ex1_mtfsfi   :std_ulogic;
 signal ex2_fpscr_bit_data  :std_ulogic_vector(0 to 3);
 signal ex2_fpscr_bit_mask  :std_ulogic_vector(0 to 3);
 signal ex2_fpscr_nib_mask  :std_ulogic_vector(0 to 8);
 signal ex2_mtfsbx   :std_ulogic;
 signal ex2_mcrfs   :std_ulogic;
 signal ex2_mtfsf   :std_ulogic;
 signal ex2_mtfsfi   :std_ulogic;

 signal ex3_fpscr_bit_data  :std_ulogic_vector(0 to 3);
 signal ex3_fpscr_bit_mask  :std_ulogic_vector(0 to 3);
 signal ex3_fpscr_nib_mask  :std_ulogic_vector(0 to 8);
 signal ex3_mtfsbx   :std_ulogic;
 signal ex3_mcrfs   :std_ulogic;
 signal ex3_mtfsf   :std_ulogic;
 signal ex3_mtfsfi   :std_ulogic;
 signal ex1_mv_to_op  :std_ulogic;
 signal ex2_mv_to_op  :std_ulogic;
 signal ex3_mv_to_op  :std_ulogic;
 signal ex1_fpscr_data  :std_ulogic_vector(0 to 7);
 signal rf1_thread :std_ulogic_vector(0 to 3); 
 signal rf1_rd_sel_0 ,   ex1_rd_sel_0  :std_ulogic;
 signal rf1_rd_sel_1 ,   ex1_rd_sel_1  :std_ulogic;
 signal rf1_rd_sel_2 ,   ex1_rd_sel_2  :std_ulogic;
 signal rf1_rd_sel_3 ,   ex1_rd_sel_3  :std_ulogic; 
 signal rf1_rd_sel_byp2, ex1_rd_sel_byp2 :std_ulogic;
 signal rf1_rd_sel_byp3, ex1_rd_sel_byp3 :std_ulogic;
 signal rf1_rd_sel_byp4, ex1_rd_sel_byp4 :std_ulogic;
 signal rf1_rd_sel_byp5, ex1_rd_sel_byp5 :std_ulogic;
 signal rf1_rd_sel_byp6, ex1_rd_sel_byp6 :std_ulogic;

 signal rf1_rd_sel_byp2_pri  :std_ulogic;
 signal rf1_rd_sel_byp3_pri  :std_ulogic;
 signal rf1_rd_sel_byp4_pri  :std_ulogic;
 signal rf1_rd_sel_byp5_pri  :std_ulogic;
 signal rf1_rd_sel_byp6_pri  :std_ulogic;

 signal ex1_fpscr_shadow_mux :std_ulogic_vector(0 to 7);
 signal rf1_thread_match_1 :std_ulogic;
 signal rf1_thread_match_2 :std_ulogic;
 signal rf1_thread_match_3 :std_ulogic;
 signal rf1_thread_match_4 :std_ulogic;
 signal rf1_thread_match_5 :std_ulogic;
 signal rf1_fpscr_bit_data :std_ulogic_vector(0 to 3) ;
 signal rf1_fpscr_bit_mask :std_ulogic_vector(0 to 3) ;
 signal rf1_fpscr_nib_mask :std_ulogic_vector(0 to 8) ;
 signal rf1_mtfsbx         :std_ulogic         ;
 signal rf1_mcrfs          :std_ulogic         ;
 signal rf1_mtfsf          :std_ulogic         ;
 signal rf1_mtfsfi         :std_ulogic         ;
 signal ex6_cancel :std_ulogic;
 signal ex6_fpscr_rd_dat_no_byp :std_ulogic_vector(24 to 31);


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


    act_lat:  tri_rlmreg_p generic map (width=> 7, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(6)     ,-- tidn,
        mpw1_b           => mpw1_b(6)          ,-- tidn,
        mpw2_b           => mpw2_b(1)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => fpu_enable, 
        scout            => act_so   ,                     
        scin             => act_si   ,                   
        -----------------
         din(0)             => act_spare_unused(0),
         din(1)             => act_spare_unused(1),        
         din(2)             => ex1_act,
         din(3)             => ex2_act,
         din(4)             => ex3_act,
         din(5)             => ex4_act,
         din(6)             => ex5_act,
        -------------------
        dout(0)             => act_spare_unused(0),
        dout(1)             => act_spare_unused(1),
        dout(2)             => ex2_act,
        dout(3)             => ex3_act,
        dout(4)             => ex4_act,
        dout(5)             => ex5_act ,
        dout(6)             => ex6_act  );

       
        act_spare_unused(2) <= rf1_act;

--//#############################################
--//## ex1 latches
--//#############################################

    rf1_thread(0 to 3)         <= not rf1_thread_b(0 to 3)              ;
    rf1_fpscr_bit_data(0 to 3) <= not f_dcd_rf1_fpscr_bit_data_b(0 to 3);
    rf1_fpscr_bit_mask(0 to 3) <= not f_dcd_rf1_fpscr_bit_mask_b(0 to 3);
    rf1_fpscr_nib_mask(0 to 8) <= not f_dcd_rf1_fpscr_nib_mask_b(0 to 8);
    rf1_mtfsbx                 <= not f_dcd_rf1_mtfsbx_b                ;
    rf1_mcrfs                  <= not f_dcd_rf1_mcrfs_b                 ;
    rf1_mtfsf                  <= not f_dcd_rf1_mtfsf_b                 ;
    rf1_mtfsfi                 <= not f_dcd_rf1_mtfsfi_b                ;


    ex1_ctl_lat:  tri_rlmreg_p generic map (width=> 34, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(1)     ,-- tidn,
        mpw1_b           => mpw1_b(1)          ,-- tidn,
        mpw2_b           => mpw2_b(0)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk            => nclk, 
        thold_b         => thold_0_b,
        sg              => sg_0, 
        act             => fpu_enable,   
        scout            => ex1_ctl_so   ,                     
        scin             => ex1_ctl_si   ,                   
        -------------------
         din(0 to 3)        => rf1_thread(0 to 3)        ,
         din(4 to 7)        => rf1_fpscr_bit_data(0 to 3),
         din(8 to 11)       => rf1_fpscr_bit_mask(0 to 3),
         din(12 to 20)      => rf1_fpscr_nib_mask(0 to 8),
         din(21)            => rf1_mtfsbx                ,
         din(22)            => rf1_mcrfs                 ,
         din(23)            => rf1_mtfsf                 ,
         din(24)            => rf1_mtfsfi                ,
         din(25)            => rf1_rd_sel_0 ,
         din(26)            => rf1_rd_sel_1 ,
         din(27)            => rf1_rd_sel_2 ,
         din(28)            => rf1_rd_sel_3 ,
         din(29)            => rf1_rd_sel_byp2_pri ,
         din(30)            => rf1_rd_sel_byp3_pri ,
         din(31)            => rf1_rd_sel_byp4_pri ,
         din(32)            => rf1_rd_sel_byp5_pri ,
         din(33)            => rf1_rd_sel_byp6_pri ,
        -------------------
        dout(0 to 3)        => ex1_thread(0 to 3)        ,
        dout(4 to 7)        => ex1_fpscr_bit_data(0 to 3),
        dout(8 to 11)       => ex1_fpscr_bit_mask(0 to 3),
        dout(12 to 20)      => ex1_fpscr_nib_mask(0 to 8),
        dout(21)            => ex1_mtfsbx                ,
        dout(22)            => ex1_mcrfs                 ,
        dout(23)            => ex1_mtfsf                 ,
        dout(24)            => ex1_mtfsfi                ,
        dout(25)            => ex1_rd_sel_0              ,
        dout(26)            => ex1_rd_sel_1              ,
        dout(27)            => ex1_rd_sel_2              ,
        dout(28)            => ex1_rd_sel_3              ,
        dout(29)            => ex1_rd_sel_byp2         ,
        dout(30)            => ex1_rd_sel_byp3         ,
        dout(31)            => ex1_rd_sel_byp4         ,
        dout(32)            => ex1_rd_sel_byp5         ,
        dout(33)            => ex1_rd_sel_byp6        );


--//#############################################
--//## ex2 latches
--//#############################################

    ex2_ctl_lat:  tri_rlmreg_p generic map (width=> 25, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(2)     ,-- tidn,
        mpw1_b           => mpw1_b(2)          ,-- tidn,
        mpw2_b           => mpw2_b(0)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => fpu_enable, 
        scout            => ex2_ctl_so   ,                     
        scin             => ex2_ctl_si   ,                   
        -------------------
         din(0 to 3)        => ex1_thread(0 to 3)          ,
         din(4 to 7)        => ex1_fpscr_bit_data(0 to 3)  ,
         din(8 to 11)       => ex1_fpscr_bit_mask(0 to 3)  ,
         din(12 to 20)      => ex1_fpscr_nib_mask(0 to 8)  ,
         din(21)            => ex1_mtfsbx                  ,
         din(22)            => ex1_mcrfs                   ,
         din(23)            => ex1_mtfsf                   ,
         din(24)            => ex1_mtfsfi                  ,
        -------------------
        dout(0 to 3)        => ex2_thread(0 to 3)          ,
        dout(4 to 7)        => ex2_fpscr_bit_data(0 to 3)  ,
        dout(8 to 11)       => ex2_fpscr_bit_mask(0 to 3)  ,
        dout(12 to 20)      => ex2_fpscr_nib_mask(0 to 8)  ,
        dout(21)            => ex2_mtfsbx                  ,
        dout(22)            => ex2_mcrfs                   ,
        dout(23)            => ex2_mtfsf                   ,
        dout(24)            => ex2_mtfsfi                 );


--//#############################################
--//## ex3 latches
--//#############################################

    ex3_ctl_lat:  tri_rlmreg_p generic map (width=> 25, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(3)     ,-- tidn,
        mpw1_b           => mpw1_b(3)          ,-- tidn,
        mpw2_b           => mpw2_b(0)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk            => nclk, 
        thold_b         => thold_0_b,
        sg              => sg_0, 
        act             => fpu_enable, 
        scout            => ex3_ctl_so   ,                     
        scin             => ex3_ctl_si   ,                   
        -------------------
         din(0 to 3)        => ex2_thread(0 to 3)          ,
         din(4 to 7)        => ex2_fpscr_bit_data(0 to 3)  ,
         din(8 to 11)       => ex2_fpscr_bit_mask(0 to 3)  ,
         din(12 to 20)      => ex2_fpscr_nib_mask(0 to 8)  ,
         din(21)            => ex2_mtfsbx                  ,
         din(22)            => ex2_mcrfs                   ,
         din(23)            => ex2_mtfsf                   ,
         din(24)            => ex2_mtfsfi                  ,
        -------------------
        dout(0 to 3)        => ex3_thread(0 to 3)          ,
        dout(4 to 7)        => ex3_fpscr_bit_data(0 to 3)  ,
        dout(8 to 11)       => ex3_fpscr_bit_mask(0 to 3)  ,
        dout(12 to 20)      => ex3_fpscr_nib_mask(0 to 8)  ,
        dout(21)            => ex3_mtfsbx                  ,
        dout(22)            => ex3_mcrfs                   ,
        dout(23)            => ex3_mtfsf                   ,
        dout(24)            => ex3_mtfsfi                  );

   f_cr2_ex3_thread_b(0 to 3)         <= not ex3_thread(0 to 3)        ;--output--
   f_cr2_ex3_fpscr_bit_data_b(0 to 3) <= not ex3_fpscr_bit_data(0 to 3);--output--
   f_cr2_ex3_fpscr_bit_mask_b(0 to 3) <= not ex3_fpscr_bit_mask(0 to 3);--output--
   f_cr2_ex3_fpscr_nib_mask_b(0 to 8) <= not ex3_fpscr_nib_mask(0 to 8);--output--
   f_cr2_ex3_mtfsbx_b                 <= not ex3_mtfsbx                ;--output--
   f_cr2_ex3_mcrfs_b                  <= not ex3_mcrfs                 ;--output--
   f_cr2_ex3_mtfsf_b                  <= not ex3_mtfsf                 ;--output--
   f_cr2_ex3_mtfsfi_b                 <= not ex3_mtfsfi                ;--output--



    ex4_ctl_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(4)     ,-- tidn,
        mpw1_b           => mpw1_b(4)          ,-- tidn,
        mpw2_b           => mpw2_b(0)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => fpu_enable, 
        scout            => ex4_ctl_so   ,                     
        scin             => ex4_ctl_si   ,                   
        -------------------
         din(0 to 3)        => ex3_thread(0 to 3)     ,
         din(4)             => ex3_mv_to_op           ,
        -------------------
        dout(0 to 3)        => ex4_thread(0 to 3)   ,
        dout(4)             => ex4_mv_to_op        );


    ex5_ctl_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type) port map (  
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(5)     ,-- tidn,
        mpw1_b           => mpw1_b(5)          ,-- tidn,
        mpw2_b           => mpw2_b(1)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => fpu_enable, 
        scout            => ex5_ctl_so   ,                     
        scin             => ex5_ctl_si   ,                   
        -------------------
         din(0 to 3)        => ex4_thread(0 to 3)   ,
         din(4)             => ex4_mv_to_op,
        -------------------
        dout(0 to 3)        => ex5_thread(0 to 3) ,
        dout(4)             => ex5_mv_to_op );

    ex6_ctl_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(6)     ,-- tidn,
        mpw1_b           => mpw1_b(6)          ,-- tidn,
        mpw2_b           => mpw2_b(1)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => fpu_enable, 
        scout            => ex6_ctl_so   ,                     
        scin             => ex6_ctl_si   ,                   
        -------------------
         din(0 to 3)     => ex5_thread(0 to 3)   ,
         din(4)          => ex5_mv_to_op , 
        dout(0 to 3)     => ex6_thread(0 to 3) ,
        dout(4)          => ex6_mv_to_op ); 

ex6_cancel <= f_dcd_ex6_cancel;

--//##############################################
--//# read mux for mffs instruction
--//##############################################

f_cr2_ex5_fpscr_rd_dat(24 to 31) <= -- output to rounder
   ( (24 to 31 => ex5_thread(0)) and shadow0(0 to 7) ) or 
   ( (24 to 31 => ex5_thread(1)) and shadow1(0 to 7) ) or 
   ( (24 to 31 => ex5_thread(2)) and shadow2(0 to 7) ) or 
   ( (24 to 31 => ex5_thread(3)) and shadow3(0 to 7) ) ;


ex6_fpscr_rd_dat_no_byp(24 to 31) <=                       
   ( (24 to 31 => ex6_thread(0)) and shadow0(0 to 7) ) or  
   ( (24 to 31 => ex6_thread(1)) and shadow1(0 to 7) ) or  
   ( (24 to 31 => ex6_thread(2)) and shadow2(0 to 7) ) or  
   ( (24 to 31 => ex6_thread(3)) and shadow3(0 to 7) ) ;   

f_cr2_ex6_fpscr_rd_dat(24 to 31)   <=                                            
   ( (24 to 31 =>     ex6_mv_to_op) and shadow_byp6(0 to 7)                ) or  
   ( (24 to 31 => not ex6_mv_to_op) and ex6_fpscr_rd_dat_no_byp(24 to 31)  ) ;   
   


--//##############################################
--//# fpscr write data / merge
--//##############################################

  ex1_bit_sel(0 to 3) <= ex1_fpscr_bit_mask(0 to 3) and (0 to 3 => ex1_mv_to_op and ex1_fpscr_nib_mask(6) );
  ex1_bit_sel(4 to 7) <= ex1_fpscr_bit_mask(0 to 3) and (0 to 3 => ex1_mv_to_op and ex1_fpscr_nib_mask(7) );

  ex1_fpscr_data(0 to 3) <=
         ( f_fmt_ex1_bop_byt(45 to 48)  and     (0 to 3=> ex1_mtfsf) ) or 
         ( ex1_fpscr_bit_data(0 to 3)   and not (0 to 3=> ex1_mtfsf) ) ;
  ex1_fpscr_data(4 to 7) <=
         ( f_fmt_ex1_bop_byt(49 to 52)  and     (0 to 3=> ex1_mtfsf) ) or 
         ( ex1_fpscr_bit_data(0 to 3)   and not (0 to 3=> ex1_mtfsf) ) ;

  shadow_byp2_din(0 to 7) <=  -- may not update all the bits
       (ex1_fpscr_shadow_mux(0 to 7) and not ex1_bit_sel(0 to 7) ) or
       (ex1_fpscr_data(0 to 7)       and     ex1_bit_sel(0 to 7) ) ;

--//##############################################
--//# read mux select generation (for pipeline control bits)
--//##############################################

  
  ex1_mv_to_op <= ex1_mtfsbx or ex1_mtfsf or ex1_mtfsfi ;
  ex2_mv_to_op <= ex2_mtfsbx or ex2_mtfsf or ex2_mtfsfi ;
  ex3_mv_to_op <= ex3_mtfsbx or ex3_mtfsf or ex3_mtfsfi ;
  

  rf1_thread_match_1 <=
      ( rf1_thread(0) and ex1_thread(0) ) or 
      ( rf1_thread(1) and ex1_thread(1) ) or 
      ( rf1_thread(2) and ex1_thread(2) ) or 
      ( rf1_thread(3) and ex1_thread(3) ) ;

  rf1_thread_match_2 <=
      ( rf1_thread(0) and ex2_thread(0) ) or 
      ( rf1_thread(1) and ex2_thread(1) ) or 
      ( rf1_thread(2) and ex2_thread(2) ) or 
      ( rf1_thread(3) and ex2_thread(3) ) ;

  rf1_thread_match_3 <=
      ( rf1_thread(0) and ex3_thread(0) ) or 
      ( rf1_thread(1) and ex3_thread(1) ) or 
      ( rf1_thread(2) and ex3_thread(2) ) or 
      ( rf1_thread(3) and ex3_thread(3) ) ;

  rf1_thread_match_4 <=
      ( rf1_thread(0) and ex4_thread(0) ) or 
      ( rf1_thread(1) and ex4_thread(1) ) or 
      ( rf1_thread(2) and ex4_thread(2) ) or 
      ( rf1_thread(3) and ex4_thread(3) ) ;

  rf1_thread_match_5 <=                       
      ( rf1_thread(0) and ex5_thread(0) ) or  
      ( rf1_thread(1) and ex5_thread(1) ) or  
      ( rf1_thread(2) and ex5_thread(2) ) or  
      ( rf1_thread(3) and ex5_thread(3) ) ;   

  rf1_rd_sel_byp2 <= rf1_thread_match_1 and ex1_mv_to_op ;
  rf1_rd_sel_byp3 <= rf1_thread_match_2 and ex2_mv_to_op ;
  rf1_rd_sel_byp4 <= rf1_thread_match_3 and ex3_mv_to_op ;
  rf1_rd_sel_byp5 <= rf1_thread_match_4 and ex4_mv_to_op ;
  rf1_rd_sel_byp6 <= rf1_thread_match_5 and ex5_mv_to_op ;

  rf1_rd_sel_0 <= rf1_thread(0) and not rf1_rd_sel_byp2 and not rf1_rd_sel_byp3 and not rf1_rd_sel_byp4 and not rf1_rd_sel_byp5  and not rf1_rd_sel_byp6 ;
  rf1_rd_sel_1 <= rf1_thread(1) and not rf1_rd_sel_byp2 and not rf1_rd_sel_byp3 and not rf1_rd_sel_byp4 and not rf1_rd_sel_byp5  and not rf1_rd_sel_byp6 ;
  rf1_rd_sel_2 <= rf1_thread(2) and not rf1_rd_sel_byp2 and not rf1_rd_sel_byp3 and not rf1_rd_sel_byp4 and not rf1_rd_sel_byp5  and not rf1_rd_sel_byp6 ;
  rf1_rd_sel_3 <= rf1_thread(3) and not rf1_rd_sel_byp2 and not rf1_rd_sel_byp3 and not rf1_rd_sel_byp4 and not rf1_rd_sel_byp5  and not rf1_rd_sel_byp6 ;


  rf1_rd_sel_byp2_pri <=     rf1_rd_sel_byp2;
  rf1_rd_sel_byp3_pri <= not rf1_rd_sel_byp2 and     rf1_rd_sel_byp3;
  rf1_rd_sel_byp4_pri <= not rf1_rd_sel_byp2 and not rf1_rd_sel_byp3 and     rf1_rd_sel_byp4;
  rf1_rd_sel_byp5_pri <= not rf1_rd_sel_byp2 and not rf1_rd_sel_byp3 and not rf1_rd_sel_byp4 and     rf1_rd_sel_byp5;
  rf1_rd_sel_byp6_pri <= not rf1_rd_sel_byp2 and not rf1_rd_sel_byp3 and not rf1_rd_sel_byp4 and not rf1_rd_sel_byp5 and rf1_rd_sel_byp6 ;


--//##############################################
--//# read mux for pipeline control bits
--//##############################################

  ex1_fpscr_shadow_mux(0 to 7) <=
        ( (0 to 7 => ex1_rd_sel_0)    and  shadow0    (0 to 7) ) or 
        ( (0 to 7 => ex1_rd_sel_1)    and  shadow1    (0 to 7) ) or 
        ( (0 to 7 => ex1_rd_sel_2)    and  shadow2    (0 to 7) ) or 
        ( (0 to 7 => ex1_rd_sel_3)    and  shadow3    (0 to 7) ) or 
        ( (0 to 7 => ex1_rd_sel_byp2) and  shadow_byp2(0 to 7) ) or 
        ( (0 to 7 => ex1_rd_sel_byp3) and  shadow_byp3(0 to 7) ) or 
        ( (0 to 7 => ex1_rd_sel_byp4) and  shadow_byp4(0 to 7) ) or 
        ( (0 to 7 => ex1_rd_sel_byp5) and  shadow_byp5(0 to 7) ) or 
        ( (0 to 7 => ex1_rd_sel_byp6) and  shadow_byp6(0 to 7) ) ;  

   f_cr2_ex1_fpscr_shadow(0 to 7) <= ex1_fpscr_shadow_mux(0 to 7);

           
--//##############################################
--//# latches
--//##############################################

    shadow_byp2_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(2)     ,-- tidn,
        mpw1_b           => mpw1_b(2)          ,-- tidn,
        mpw2_b           => mpw2_b(0)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk            => nclk, 
        thold_b         => thold_0_b,
        sg              => sg_0, 
        act             => ex1_act, 
        scout            => shadow_byp2_so  ,                      
        scin             => shadow_byp2_si  ,                    
        ------------------
        din              => shadow_byp2_din(0 to 7),
        dout             => shadow_byp2    (0 to 7) );--LAT--

    shadow_byp3_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(3)     ,-- tidn,
        mpw1_b           => mpw1_b(3)          ,-- tidn,
        mpw2_b           => mpw2_b(0)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk            => nclk, 
        thold_b         => thold_0_b,
        sg              => sg_0, 
        act             => ex2_act, 
        scout            => shadow_byp3_so  ,                  
        scin             => shadow_byp3_si  ,                    
        -------------------
        din              => shadow_byp2(0 to 7),
        dout             => shadow_byp3(0 to 7) );--LAT--

    shadow_byp4_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(4)     ,-- tidn,
        mpw1_b           => mpw1_b(4)          ,-- tidn,
        mpw2_b           => mpw2_b(0)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex3_act, 
        scout            => shadow_byp4_so  ,                      
        scin             => shadow_byp4_si  ,                    
        -------------------
        din              => shadow_byp3(0 to 7),
        dout             => shadow_byp4(0 to 7) );--LAT--

    shadow_byp5_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(5)     ,-- tidn,
        mpw1_b           => mpw1_b(5)          ,-- tidn,
        mpw2_b           => mpw2_b(1)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex4_act, 
        scout            => shadow_byp5_so  ,                      
        scin             => shadow_byp5_si  ,                    
        -------------------
        din              => shadow_byp4(0 to 7),
        dout             => shadow_byp5(0 to 7) );--LAT--

    shadow_byp6_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map (  
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(6)     ,-- tidn,
        mpw1_b           => mpw1_b(6)          ,-- tidn,
        mpw2_b           => mpw2_b(1)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex5_act,  
        scout            => shadow_byp6_so  ,                      
        scin             => shadow_byp6_si  ,                    
        din              => shadow_byp5(0 to 7), 
        dout             => shadow_byp6(0 to 7) );

        ex6_th0_act <= ex6_act and ex6_thread(0) and not ex6_cancel and ex6_mv_to_op ; 
        ex6_th1_act <= ex6_act and ex6_thread(1) and not ex6_cancel and ex6_mv_to_op ; 
        ex6_th2_act <= ex6_act and ex6_thread(2) and not ex6_cancel and ex6_mv_to_op ; 
        ex6_th3_act <= ex6_act and ex6_thread(3) and not ex6_cancel and ex6_mv_to_op ; 



    shadow0_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(7)     ,-- tidn,
        mpw1_b           => mpw1_b(7)          ,-- tidn,
        mpw2_b           => mpw2_b(1)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex6_th0_act,  
        scout            => shadow0_so  ,                      
        scin             => shadow0_si  ,                    
        -------------------
        din              => shadow_byp6(0 to 7), 
        dout             => shadow0(0 to 7) );--LAT--
       
    shadow1_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(7)     ,-- tidn,
        mpw1_b           => mpw1_b(7)          ,-- tidn,
        mpw2_b           => mpw2_b(1)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex6_th1_act,  
        scout            => shadow1_so  ,                      
        scin             => shadow1_si  ,                    
        -------------------
        din              => shadow_byp6(0 to 7), 
        dout             => shadow1(0 to 7) );--LAT--
       
    shadow2_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(7)     ,-- tidn,
        mpw1_b           => mpw1_b(7)          ,-- tidn,
        mpw2_b           => mpw2_b(1)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex6_th2_act,  
        scout            => shadow2_so  ,                      
        scin             => shadow2_si  ,                    
        -------------------
        din              => shadow_byp6(0 to 7), 
        dout             => shadow2(0 to 7) );--LAT--
       
    shadow3_lat:  tri_rlmreg_p generic map (width=> 8, expand_type => expand_type) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(7)     ,-- tidn,
        mpw1_b           => mpw1_b(7)          ,-- tidn,
        mpw2_b           => mpw2_b(1)          ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex6_th3_act,  
        scout            => shadow3_so  ,                      
        scin             => shadow3_si  ,                    
        -------------------
        din              => shadow_byp6(0 to 7), 
        dout             => shadow3(0 to 7) );--LAT--


       
--//############################################
--//# scan
--//############################################


    ex1_ctl_si      (0 to 33) <= ex1_ctl_so      (1 to 33) & f_cr2_si ;
    ex2_ctl_si      (0 to 24) <= ex2_ctl_so      (1 to 24) & ex1_ctl_so  (0);
    ex3_ctl_si      (0 to 24) <= ex3_ctl_so      (1 to 24) & ex2_ctl_so  (0);
    ex4_ctl_si      (0 to 4)  <= ex4_ctl_so      (1 to 4)  & ex3_ctl_so  (0);
    ex5_ctl_si      (0 to 4)  <= ex5_ctl_so      (1 to 4)  & ex4_ctl_so  (0); 
    ex6_ctl_si      (0 to 4)  <= ex6_ctl_so      (1 to 4)  & ex5_ctl_so  (0); 
    shadow0_si      (0 to 7)  <= shadow0_so      (1 to 7)  & ex6_ctl_so  (0); 
    shadow1_si      (0 to 7)  <= shadow1_so      (1 to 7)  & shadow0_so  (0);
    shadow2_si      (0 to 7)  <= shadow2_so      (1 to 7)  & shadow1_so  (0);
    shadow3_si      (0 to 7)  <= shadow3_so      (1 to 7)  & shadow2_so  (0);
    shadow_byp2_si  (0 to 7)  <= shadow_byp2_so  (1 to 7)  & shadow3_so  (0);
    shadow_byp3_si  (0 to 7)  <= shadow_byp3_so  (1 to 7)  & shadow_byp2_so  (0);
    shadow_byp4_si  (0 to 7)  <= shadow_byp4_so  (1 to 7)  & shadow_byp3_so  (0);
    shadow_byp5_si  (0 to 7)  <= shadow_byp5_so  (1 to 7)  & shadow_byp4_so  (0);
    shadow_byp6_si  (0 to 7)  <= shadow_byp6_so  (1 to 7)  & shadow_byp5_so  (0); 
    act_si          (0 to 6)  <= act_so          (1 to 6)  & shadow_byp6_so  (0);  
    f_cr2_so                  <=  act_so  (0) ;
 


end; -- fuq_cr2 ARCHITECTURE
