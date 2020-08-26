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


entity fuq_add is
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(

       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic_vector(3 to 4); -- tidn,
       mpw1_b                                    :in   std_ulogic_vector(3 to 4); -- tidn,
       mpw2_b                                    :in   std_ulogic_vector(0 to 0); -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;

       f_add_si                  :in  std_ulogic; --perv
       f_add_so                  :out std_ulogic; --perv
       ex1_act_b                 :in  std_ulogic; --act

       f_sa3_ex3_s                :in  std_ulogic_vector(0  to 162); -- data
       f_sa3_ex3_c                :in  std_ulogic_vector(53 to 161); -- data

       -- f_alg_ex2_sel_byp          :in  std_ulogic; -- all eac selects off
       f_alg_ex3_frc_sel_p1       :in  std_ulogic; -- rounding converts
       f_alg_ex3_sticky           :in  std_ulogic; -- part of eac control
       f_alg_ex2_effsub_eac_b     :in  std_ulogic; -- already shut off for algByp
       f_alg_ex2_prod_z           :in  std_ulogic;

       f_pic_ex3_is_gt            :in  std_ulogic; -- compare
       f_pic_ex3_is_lt            :in  std_ulogic; -- compare
       f_pic_ex3_is_eq            :in  std_ulogic; -- compare
       f_pic_ex3_is_nan           :in  std_ulogic; -- compare
       f_pic_ex3_cmp_sgnpos       :in  std_ulogic; -- compare
       f_pic_ex3_cmp_sgnneg       :in  std_ulogic; -- compare

       f_add_ex4_res              :out std_ulogic_vector(0 to 162); -- RESULT
       f_add_ex4_flag_nan         :out std_ulogic;                  -- compare for fpscr
       f_add_ex4_flag_gt          :out std_ulogic;                  -- compare for fpscr
       f_add_ex4_flag_lt          :out std_ulogic;                  -- compare for fpscr
       f_add_ex4_flag_eq          :out std_ulogic;                  -- compare for fpscr
       f_add_ex4_fpcc_iu          :out std_ulogic_vector(0 to 3);   -- compare for iu
       f_add_ex4_sign_carry       :out std_ulogic;                  -- select sign from product/addend
       f_add_ex4_to_int_ovf_wd    :out std_ulogic_vector(0 to 1);   -- raw data
       f_add_ex4_to_int_ovf_dw    :out std_ulogic_vector(0 to 1);   -- raw data
       f_add_ex4_sticky           :out std_ulogic                   -- for nrm

);


end fuq_add; -- ENTITY

architecture fuq_add of fuq_add is

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';

--//#################################
--//# sigdef : non-functional
--//#################################

  signal thold_0_b, thold_0    :std_ulogic;
  signal sg_0, forcee        :std_ulogic;

  signal ex1_act      :std_ulogic;
  signal ex2_act      :std_ulogic;
  signal ex3_act   :std_ulogic;

  signal act_si         :std_ulogic_vector(0 to 8);
  signal act_so         :std_ulogic_vector(0 to 8);
  signal ex4_res_so     :std_ulogic_vector(0 to 162);                      
  signal ex4_res_si     :std_ulogic_vector(0 to 162);                    
  signal ex4_cmp_so     :std_ulogic_vector(0 to 9);                      
  signal ex4_cmp_si     :std_ulogic_vector(0 to 9);                    

  signal spare_unused   :std_ulogic_vector(0 to 3);

--//#################################
--//# sigdef : functional
--//#################################

  signal ex3_s           :std_ulogic_vector( 0 to 162);
  signal ex3_c           :std_ulogic_vector(53 to 161);

  signal ex3_flag_nan       :std_ulogic;    
  signal ex3_flag_gt        :std_ulogic;   
  signal ex3_flag_lt        :std_ulogic;   
  signal ex3_flag_eq        :std_ulogic;   
  signal ex3_sign_carry     :std_ulogic; 

  signal ex3_inc_all1       :std_ulogic;
  signal ex3_inc_byt_c_glb  :std_ulogic_vector(1 to 6);
  signal ex3_inc_byt_c_glb_b  :std_ulogic_vector(1 to 6);
  signal ex3_inc_p1         :std_ulogic_vector(0 to 52);
  signal ex3_inc_p0         :std_ulogic_vector(0 to 52);

  signal ex3_s_p0           :std_ulogic_vector(53 to 162);
  signal ex3_s_p1           :std_ulogic_vector(53 to 162);
  signal ex3_res            :std_ulogic_vector(0 to 162);

  signal ex2_effsub         :std_ulogic;
  signal ex3_effsub         :std_ulogic;

  signal ex2_effadd_npz     :std_ulogic;
  signal ex2_effsub_npz     :std_ulogic;
  signal ex3_effsub_npz     :std_ulogic;
  signal ex3_effadd_npz     :std_ulogic;
  signal ex3_flip_inc_p0    :std_ulogic;
  signal ex3_flip_inc_p1    :std_ulogic;
  signal ex3_inc_sel_p0     :std_ulogic;
  signal ex3_inc_sel_p1     :std_ulogic;

  signal ex4_res, ex4_res_b , ex4_res_l2_b :std_ulogic_vector(0 to 162) ;
  signal ex4_flag_nan_b       :std_ulogic;    
  signal ex4_flag_gt_b        :std_ulogic;   
  signal ex4_flag_lt_b        :std_ulogic;   
  signal ex4_flag_eq_b        :std_ulogic;   
  signal ex4_fpcc_iu_b        :std_ulogic_vector(0 to 3) ;
  signal ex4_sign_carry_b     :std_ulogic; 
  signal ex4_sticky_b         :std_ulogic;

  signal ex3_g16  :std_ulogic_vector(0 to 6);
  signal ex3_t16  :std_ulogic_vector(0 to 6);
  signal ex3_g128, ex3_t128, ex3_g128_b, ex3_t128_b :std_ulogic_vector(1 to 6);
  signal ex3_inc_byt_c_b  :std_ulogic_vector(0 to 6);
  signal ex3_eac_sel_p0n, ex3_eac_sel_p0,  ex3_eac_sel_p1 : std_ulogic_vector(0 to 6);
  signal ex3_flag_nan_cp1, ex3_flag_gt_cp1, ex3_flag_lt_cp1, ex3_flag_eq_cp1 :std_ulogic;
  signal add_ex4_d1clk , add_ex4_d2clk  :std_ulogic ;
  signal add_ex4_lclk :clk_logic ;

 signal ex3_s_p0n, ex3_res_p0n_b, ex3_res_p0_b, ex3_res_p1_b :std_ulogic_vector(53 to 162);
 signal ex3_inc_p0_x, ex3_inc_p1_x, ex3_incx_p0_b, ex3_incx_p1_b :std_ulogic_vector(0 to 52);
 signal ex3_sel_a1, ex3_sel_a2, ex3_sel_a3 :std_ulogic_vector(53 to 162);




begin

--//################################################################
--//# pervasive
--//################################################################

    thold_reg_0:  tri_plat  generic map (expand_type => expand_type) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,  
         flush     => flush ,
         din(0)    => thold_1,   -- ?? need an lcb_or after this
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

    ex1_act        <= not ex1_act_b ;
    ex2_effsub     <= not f_alg_ex2_effsub_eac_b ;
    ex2_effsub_npz <= not f_alg_ex2_effsub_eac_b and not  f_alg_ex2_prod_z;
    ex2_effadd_npz <=     f_alg_ex2_effsub_eac_b and not  f_alg_ex2_prod_z;

    act_lat:  tri_rlmreg_p generic map (width=> 9, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,--i-- tidn,
        --d_mode           => d_mode       ,--i-- tiup,
        delay_lclkr      => delay_lclkr(3)  ,--i-- tidn,
        mpw1_b           => mpw1_b(3)       ,--i-- tidn,
        mpw2_b           => mpw2_b(0)       ,--i-- tidn,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        vd               => vdd,
        gd               => gnd,
        scout            => act_so  ,                      
        scin             => act_si  ,                    
        -------------------
        din(0)            => spare_unused(0),
        din(1)            => spare_unused(1),
        din(2)            => ex1_act,
        din(3)            => ex2_act,
        din(4)            => ex2_effsub ,
        din(5)            => ex2_effsub_npz,
        din(6)            => ex2_effadd_npz,
        din(7)            => spare_unused(2),
        din(8)            => spare_unused(3),
        -------------------
        dout(0)           => spare_unused(0),
        dout(1)           => spare_unused(1),
        dout(2)           => ex2_act,
        dout(3)           => ex3_act,
        dout(4)           => ex3_effsub ,
        dout(5)           => ex3_effsub_npz,
        dout(6)           => ex3_effadd_npz,
        dout(7)           => spare_unused(2) ,
        dout(8)           => spare_unused(3) );

    add_ex4_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        delay_lclkr =>  delay_lclkr(4) ,-- tidn ,--in
     -- --d_mode      =>  d_mode      ,-- tiup ,--in
        mpw1_b      =>  mpw1_b(4)      ,-- tidn ,--in
        mpw2_b      =>  mpw2_b(0)      ,-- tidn ,--in
        forcee => forcee,-- tidn ,--in
        nclk        =>  nclk                 ,--in
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        act         =>  ex3_act              ,--in
        sg          =>  sg_0                 ,--in
        thold_b     =>  thold_0_b            ,--in
        d1clk       =>  add_ex4_d1clk        ,--out
        d2clk       =>  add_ex4_d2clk        ,--out
        lclk        =>  add_ex4_lclk        );--out


--//################################################################
--//# ex3 logic
--//################################################################

        ex3_s(0 to 162)  <= f_sa3_ex3_s(0  to 162); 
        ex3_c(53 to 161) <= f_sa3_ex3_c(53 to 161);

  --ex3 incrementer-----------------------------------------

        --ex3 incr (global carry)---------------------------------

 all1: entity work.fuq_add_all1(fuq_add_all1) port map(
         ex3_inc_byt_c_b(0 to 6)      => ex3_inc_byt_c_b(0 to 6)      ,--i--
         ex3_inc_byt_c_glb(1 to 6)    => ex3_inc_byt_c_glb(1 to 6)    ,--o--
         ex3_inc_byt_c_glb_b(1 to 6)  => ex3_inc_byt_c_glb_b(1 to 6)  ,--o--
         ex3_inc_all1                 => ex3_inc_all1                );--o--
      
        --ex3 incr (byte sections) -------------------------------------------------

 inc8_6: entity work.fuq_loc8inc_lsb(fuq_loc8inc_lsb) port map(
      co_b         => ex3_inc_byt_c_b(6)          ,--o--
      x            => ex3_s     ( 48 to  52)      ,--i--
      s0           => ex3_inc_p0( 48 to  52)      ,--o--
      s1           => ex3_inc_p1( 48 to  52)     );--o--

 inc8_5: entity work.fuq_loc8inc(fuq_loc8inc) port map(
      ci           => ex3_inc_byt_c_glb(6)        ,--i--
      ci_b         => ex3_inc_byt_c_glb_b(6)      ,--i--
      co_b         => ex3_inc_byt_c_b(5)          ,--o--
      x            => ex3_s     ( 40 to  47)      ,--i--
      s0           => ex3_inc_p0( 40 to  47)      ,--o--
      s1           => ex3_inc_p1( 40 to  47)     );--o--

 inc8_4: entity work.fuq_loc8inc(fuq_loc8inc) port map(
      ci           => ex3_inc_byt_c_glb(5)        ,--i--
      ci_b         => ex3_inc_byt_c_glb_b(5)      ,--i--
      co_b         => ex3_inc_byt_c_b(4)          ,--o--
      x            => ex3_s     ( 32 to  39)      ,--i--
      s0           => ex3_inc_p0( 32 to  39)      ,--o--
      s1           => ex3_inc_p1( 32 to  39)     );--o--

 inc8_3: entity work.fuq_loc8inc(fuq_loc8inc) port map(
      ci           => ex3_inc_byt_c_glb(4)        ,--i--
      ci_b         => ex3_inc_byt_c_glb_b(4)      ,--i--
      co_b         => ex3_inc_byt_c_b(3)          ,--o--
      x            => ex3_s     ( 24 to  31)      ,--i--
      s0           => ex3_inc_p0( 24 to  31)      ,--o--
      s1           => ex3_inc_p1( 24 to  31)     );--o--

 inc8_2: entity work.fuq_loc8inc(fuq_loc8inc) port map(
      ci           => ex3_inc_byt_c_glb(3)        ,--i--
      ci_b         => ex3_inc_byt_c_glb_b(3)      ,--i--
      co_b         => ex3_inc_byt_c_b(2)          ,--o--
      x            => ex3_s     ( 16 to  23)      ,--i--
      s0           => ex3_inc_p0( 16 to  23)      ,--o--
      s1           => ex3_inc_p1( 16 to  23)     );--o--

 inc8_1: entity work.fuq_loc8inc(fuq_loc8inc) port map(
      ci           => ex3_inc_byt_c_glb(2)        ,--i--
      ci_b         => ex3_inc_byt_c_glb_b(2)      ,--i--
      co_b         => ex3_inc_byt_c_b(1)          ,--o--
      x            => ex3_s     (  8 to  15)      ,--i--
      s0           => ex3_inc_p0(  8 to  15)      ,--o--
      s1           => ex3_inc_p1(  8 to  15)     );--o--

 inc8_0: entity work.fuq_loc8inc(fuq_loc8inc) port map(
      ci           => ex3_inc_byt_c_glb(1)        ,--i--
      ci_b         => ex3_inc_byt_c_glb_b(1)      ,--i--
      co_b         => ex3_inc_byt_c_b(0)          ,--o--
      x            => ex3_s     (  0 to   7)      ,--i--
      s0           => ex3_inc_p0(  0 to   7)      ,--o--
      s1           => ex3_inc_p1(  0 to   7)     );--o--



  --ex3 adder-----------------------------------------------

        -- sum[53] is the raw aligner bit
        -- car[53] includes the bogous bit
        -- position 53 also includes a "1" to push out the bogous bit
        --
        -- [0:52] needs "111...111" to push out the bogous bit
        -- but the first co of [53] is supressed instead
        --
        -- ex3_53 => s53, c53, "1", ci : 2nd co : s53 * c53 * ci


        -- sums
        -- [0] 053:068
        -- [1] 069:084
        -- [2] 085:100
        -- [3] 101:116
        -- [4] 117:132
        -- [5] 133:148
        -- [6] 149:164 <162,"1","1">

 hc16_0: entity work.fuq_hc16pp_msb(fuq_hc16pp_msb) port map(
      x            => ex3_s( 53 to  68)         ,--i--
      y            => ex3_c( 53 to  68)         ,--i--
      ci0          => ex3_g128(1)               ,--i--
      ci0_b        => ex3_g128_b(1)             ,--i--
      ci1          => ex3_t128(1)               ,--i--
      ci1_b        => ex3_t128_b(1)             ,--i--
      s0           => ex3_s_p0( 53 to  68)      ,--o--
      s1           => ex3_s_p1( 53 to  68)      ,--o--
      g16          => ex3_g16(0)                ,--o--
      t16          => ex3_t16(0)               );--o--

 hc16_1: entity work.fuq_hc16pp(fuq_hc16pp) port map(
      x            => ex3_s( 69 to  84)         ,--i--
      y            => ex3_c( 69 to  84)         ,--i--
      ci0          => ex3_g128(2)               ,--i--
      ci0_b        => ex3_g128_b(2)             ,--i--
      ci1          => ex3_t128(2)               ,--i--
      ci1_b        => ex3_t128_b(2)             ,--i--
      s0           => ex3_s_p0( 69 to  84)      ,--o--
      s1           => ex3_s_p1( 69 to  84)      ,--o--
      g16          => ex3_g16(1)                ,--o--
      t16          => ex3_t16(1)               );--o--

 hc16_2: entity work.fuq_hc16pp(fuq_hc16pp) port map(
      x            => ex3_s( 85 to 100)         ,--i--
      y            => ex3_c( 85 to 100)         ,--i--
      ci0          => ex3_g128(3)               ,--i--
      ci0_b        => ex3_g128_b(3)             ,--i--
      ci1          => ex3_t128(3)               ,--i--
      ci1_b        => ex3_t128_b(3)             ,--i--
      s0           => ex3_s_p0( 85 to 100)      ,--o--
      s1           => ex3_s_p1( 85 to 100)      ,--o--
      g16          => ex3_g16(2)                ,--o--
      t16          => ex3_t16(2)               );--o--

 hc16_3: entity work.fuq_hc16pp(fuq_hc16pp) port map(
      x            => ex3_s(101 to 116)         ,--i--
      y            => ex3_c(101 to 116)         ,--i--
      ci0          => ex3_g128(4)               ,--i--
      ci0_b        => ex3_g128_b(4)             ,--i--
      ci1          => ex3_t128(4)               ,--i--
      ci1_b        => ex3_t128_b(4)             ,--i--
      s0           => ex3_s_p0(101 to 116)      ,--o--
      s1           => ex3_s_p1(101 to 116)      ,--o--
      g16          => ex3_g16(3)                ,--o--
      t16          => ex3_t16(3)               );--o--

 hc16_4: entity work.fuq_hc16pp(fuq_hc16pp) port map(
      x            => ex3_s(117 to 132)         ,--i--
      y            => ex3_c(117 to 132)         ,--i--
      ci0          => ex3_g128(5)               ,--i--
      ci0_b        => ex3_g128_b(5)             ,--i--
      ci1          => ex3_t128(5)               ,--i--
      ci1_b        => ex3_t128_b(5)             ,--i--
      s0           => ex3_s_p0(117 to 132)      ,--o--
      s1           => ex3_s_p1(117 to 132)      ,--o--
      g16          => ex3_g16(4)                ,--o--
      t16          => ex3_t16(4)               );--o--

 hc16_5: entity work.fuq_hc16pp(fuq_hc16pp) port map(
      x            => ex3_s(133 to 148)         ,--i--
      y            => ex3_c(133 to 148)         ,--i--
      ci0          => ex3_g128(6)               ,--i--
      ci0_b        => ex3_g128_b(6)             ,--i--
      ci1          => ex3_t128(6)               ,--i--
      ci1_b        => ex3_t128_b(6)             ,--i--
      s0           => ex3_s_p0(133 to 148)      ,--o--
      s1           => ex3_s_p1(133 to 148)      ,--o--
      g16          => ex3_g16(5)                ,--o--
      t16          => ex3_t16(5)               );--o--

 hc16_6: entity work.fuq_hc16pp_lsb(fuq_hc16pp_lsb) port map(
      x(0 to 13)   => ex3_s(149 to 162)         ,--i--
      y(0 to 12)   => ex3_c(149 to 161)         ,--i--
      s0           => ex3_s_p0(149 to 162)      ,--o--
      s1           => ex3_s_p1(149 to 162)      ,--o--
      g16          => ex3_g16(6)                ,--o--
      t16          => ex3_t16(6)               );--o--



  --------------------------------------------------
  -- EACMUX: incrementer bits
  --------------------------------------------------

  u_incmx_p0x: ex3_inc_p0_x(0 to 52) <= ex3_inc_p0(0 to 52) xor (0 to 52=> ex3_flip_inc_p0);
  u_incmx_p1x: ex3_inc_p1_x(0 to 52) <= ex3_inc_p1(0 to 52) xor (0 to 52=> ex3_flip_inc_p1);
  
  u_incmx_p0:  ex3_incx_p0_b(0 to 52) <= not( (0 to 52=> ex3_inc_sel_p0) and ex3_inc_p0_x(0 to 52)  );
  u_incmx_p1:  ex3_incx_p1_b(0 to 52) <= not( (0 to 52=> ex3_inc_sel_p1) and ex3_inc_p1_x(0 to 52)  );
  u_incmx:     ex3_res      (0 to 52) <= not( ex3_incx_p0_b(0 to 52) and ex3_incx_p1_b(0 to 52) );

  --------------------------------------------------
  -- EACMUX: adder bits
  --------------------------------------------------
 
  ex3_sel_a1(53 to 68)   <= (53 to 68   => ex3_eac_sel_p0n(0) ); --rename
  ex3_sel_a1(69 to 84)   <= (69 to 84   => ex3_eac_sel_p0n(1) ); --rename
  ex3_sel_a1(85 to 100)  <= (85 to 100  => ex3_eac_sel_p0n(2) ); --rename
  ex3_sel_a1(101 to 116) <= (101 to 116 => ex3_eac_sel_p0n(3) ); --rename
  ex3_sel_a1(117 to 132) <= (117 to 132 => ex3_eac_sel_p0n(4) ); --rename
  ex3_sel_a1(133 to 148) <= (133 to 148 => ex3_eac_sel_p0n(5) ); --rename
  ex3_sel_a1(149 to 162) <= (149 to 162 => ex3_eac_sel_p0n(6) ); --rename

  ex3_sel_a2(53 to 68)   <= (53 to 68   => ex3_eac_sel_p0(0) ); --rename
  ex3_sel_a2(69 to 84)   <= (69 to 84   => ex3_eac_sel_p0(1) ); --rename
  ex3_sel_a2(85 to 100)  <= (85 to 100  => ex3_eac_sel_p0(2) ); --rename
  ex3_sel_a2(101 to 116) <= (101 to 116 => ex3_eac_sel_p0(3) ); --rename
  ex3_sel_a2(117 to 132) <= (117 to 132 => ex3_eac_sel_p0(4) ); --rename
  ex3_sel_a2(133 to 148) <= (133 to 148 => ex3_eac_sel_p0(5) ); --rename
  ex3_sel_a2(149 to 162) <= (149 to 162 => ex3_eac_sel_p0(6) ); --rename

  ex3_sel_a3(53 to 68)   <= (53 to 68   => ex3_eac_sel_p1(0) ); --rename
  ex3_sel_a3(69 to 84)   <= (69 to 84   => ex3_eac_sel_p1(1) ); --rename
  ex3_sel_a3(85 to 100)  <= (85 to 100  => ex3_eac_sel_p1(2) ); --rename
  ex3_sel_a3(101 to 116) <= (101 to 116 => ex3_eac_sel_p1(3) ); --rename
  ex3_sel_a3(117 to 132) <= (117 to 132 => ex3_eac_sel_p1(4) ); --rename
  ex3_sel_a3(133 to 148) <= (133 to 148 => ex3_eac_sel_p1(5) ); --rename
  ex3_sel_a3(149 to 162) <= (149 to 162 => ex3_eac_sel_p1(6) ); --rename

  u_eacmx_i:  ex3_s_p0n    (53 to 162) <= not( ex3_s_p0(53 to 162) );
  u_eacmx_a1: ex3_res_p0n_b(53 to 162) <= not( ex3_sel_a1(53 to 162) and ex3_s_p0n(53 to 162) );
  u_eacmx_a2: ex3_res_p0_b (53 to 162) <= not( ex3_sel_a2(53 to 162) and ex3_s_p0(53 to 162)  );
  u_eacmx_a3: ex3_res_p1_b (53 to 162) <= not( ex3_sel_a3(53 to 162) and ex3_s_p1(53 to 162)  );
  u_eacmx:    ex3_res      (53 to 162) <= not( ex3_res_p0n_b(53 to 162) and ex3_res_p0_b(53 to 162) and ex3_res_p1_b(53 to 162) );
 

--=##################################################################################
--=# global carry chain, eac_selects, compare, sign_carry
--=##################################################################################

 glbc: entity work.fuq_add_glbc(fuq_add_glbc) port map(
         ex3_g16(0 to 6)         => ex3_g16(0 to 6)       ,--i--
         ex3_t16(0 to 6)         => ex3_t16(0 to 6)       ,--i--
         ex3_inc_all1            => ex3_inc_all1          ,--i--
         ex3_effsub              => ex3_effsub            ,--i--
         ex3_effsub_npz          => ex3_effsub_npz        ,--i--
         ex3_effadd_npz          => ex3_effadd_npz        ,--i--
         f_alg_ex3_frc_sel_p1    => f_alg_ex3_frc_sel_p1  ,--i--
         f_alg_ex3_sticky        => f_alg_ex3_sticky      ,--i--
         f_pic_ex3_is_nan        => f_pic_ex3_is_nan      ,--i--
         f_pic_ex3_is_gt         => f_pic_ex3_is_gt       ,--i--
         f_pic_ex3_is_lt         => f_pic_ex3_is_lt       ,--i--
         f_pic_ex3_is_eq         => f_pic_ex3_is_eq       ,--i--
         f_pic_ex3_cmp_sgnpos    => f_pic_ex3_cmp_sgnpos  ,--i--
         f_pic_ex3_cmp_sgnneg    => f_pic_ex3_cmp_sgnneg  ,--i--
         ex3_g128(1 to 6)        => ex3_g128(1 to 6)      ,--o--
         ex3_g128_b(1 to 6)      => ex3_g128_b(1 to 6)    ,--o--
         ex3_t128(1 to 6)        => ex3_t128(1 to 6)      ,--o--
         ex3_t128_b(1 to 6)      => ex3_t128_b(1 to 6)    ,--o--
         ex3_flip_inc_p0         => ex3_flip_inc_p0       ,--o--
         ex3_flip_inc_p1         => ex3_flip_inc_p1       ,--o--
         ex3_inc_sel_p0          => ex3_inc_sel_p0        ,--o--
         ex3_inc_sel_p1          => ex3_inc_sel_p1        ,--o--
         ex3_eac_sel_p0n(0 to 6) => ex3_eac_sel_p0n       ,--o--
         ex3_eac_sel_p0 (0 to 6) => ex3_eac_sel_p0        ,--o--
         ex3_eac_sel_p1 (0 to 6) => ex3_eac_sel_p1        ,--o--
         ex3_sign_carry          => ex3_sign_carry        ,--o--
         ex3_flag_nan_cp1        => ex3_flag_nan_cp1      ,--o-- duplicate lat driven by unique gate
         ex3_flag_gt_cp1         => ex3_flag_gt_cp1       ,--o-- duplicate lat driven by unique gate
         ex3_flag_lt_cp1         => ex3_flag_lt_cp1       ,--o-- duplicate lat driven by unique gate
         ex3_flag_eq_cp1         => ex3_flag_eq_cp1       ,--o-- duplicate lat driven by unique gate
         ex3_flag_nan            => ex3_flag_nan          ,--o--
         ex3_flag_gt             => ex3_flag_gt           ,--o--
         ex3_flag_lt             => ex3_flag_lt           ,--o--
         ex3_flag_eq             => ex3_flag_eq          );--o--



--//################################################################
--//# ex4 latches
--//################################################################

   ex4_res_hi_lat:  entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 53, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK           => add_ex4_lclk               ,-- lclk.clk
        D1CLK          => add_ex4_d1clk              ,
        D2CLK          => add_ex4_d2clk              ,
        SCANIN         => ex4_res_si(0 to 52)        ,                    
        SCANOUT        => ex4_res_so(0 to 52)        ,
        D              => ex3_res(0 to 52)           , 
        QB             => ex4_res_l2_b(0 to 52)     ); --LAT


   ex4_res_lo_lat: entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 110, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK           => add_ex4_lclk               ,-- lclk.clk
        D1CLK          => add_ex4_d1clk              ,
        D2CLK          => add_ex4_d2clk              ,
        SCANIN         => ex4_res_si(53 to 162)      ,                    
        SCANOUT        => ex4_res_so(53 to 162)      ,
        D               => ex3_res(53 to 162)        ,
        QB              => ex4_res_l2_b(53 to 162)  ); --LAT

              ex4_res  (0 to 162) <= not ex4_res_l2_b(0 to 162) ;    
a_oinv:       ex4_res_b(0 to 162) <= not ex4_res  (0 to 162);
a_obuf: f_add_ex4_res  (0 to 162) <= not ex4_res_b(0 to 162) ; -- output

   ex4_cmp_lat: entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 10, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK           => add_ex4_lclk               ,-- lclk.clk
        D1CLK          => add_ex4_d1clk              ,
        D2CLK          => add_ex4_d2clk              ,
        SCANIN         => ex4_cmp_si                 ,                    
        SCANOUT        => ex4_cmp_so                 ,
        D( 0)   => ex3_flag_lt        ,     
        D( 1)   => ex3_flag_lt_cp1    ,     
        D( 2)   => ex3_flag_gt        ,     
        D( 3)   => ex3_flag_gt_cp1    ,     
        D( 4)   => ex3_flag_eq        ,     
        D( 5)   => ex3_flag_eq_cp1    ,     
        D( 6)   => ex3_flag_nan       ,     
        D( 7)   => ex3_flag_nan_cp1   ,     
        D( 8)   => ex3_sign_carry     , 
        D( 9)   => f_alg_ex3_sticky   , 
        -------------------
        QB( 0)   => ex4_flag_lt_b        ,  --LAT
        QB( 1)   => ex4_fpcc_iu_b(0)     ,  --LAT
        QB( 2)   => ex4_flag_gt_b        ,  --LAT
        QB( 3)   => ex4_fpcc_iu_b(1)     ,  --LAT
        QB( 4)   => ex4_flag_eq_b        ,  --LAT
        QB( 5)   => ex4_fpcc_iu_b(2)     ,  --LAT
        QB( 6)   => ex4_flag_nan_b       ,  --LAT
        QB( 7)   => ex4_fpcc_iu_b(3)     ,  --LAT
        QB( 8)   => ex4_sign_carry_b     ,  --LAT
        QB( 9)   => ex4_sticky_b         ); --LAT


       f_add_ex4_flag_nan         <= not ex4_flag_nan_b        ;--output
       f_add_ex4_flag_gt          <= not ex4_flag_gt_b         ;--output
       f_add_ex4_flag_lt          <= not ex4_flag_lt_b         ;--output
       f_add_ex4_flag_eq          <= not ex4_flag_eq_b         ;--output
       f_add_ex4_fpcc_iu(0 to 3)  <= not ex4_fpcc_iu_b(0 to 3) ;--output
       f_add_ex4_sign_carry       <= not ex4_sign_carry_b      ;--output
       f_add_ex4_sticky           <= not ex4_sticky_b          ;--output


       f_add_ex4_to_int_ovf_wd(0) <= ex4_res(130)   ;
       f_add_ex4_to_int_ovf_wd(1) <= ex4_res(131)   ;
       f_add_ex4_to_int_ovf_dw(0) <= ex4_res(98)    ;
       f_add_ex4_to_int_ovf_dw(1) <= ex4_res(99)    ;

--//################################################################
--//# ex4 logic
--//################################################################



--//################################################################
--//# scan string
--//################################################################

  act_si  (0 to 8)       <= act_so  (1 to 8)       & f_add_si ;
  ex4_res_si  (0 to 162) <= ex4_res_so  (1 to 162) & act_so(0);
  ex4_cmp_si  (0 to 9)   <= ex4_cmp_so  (1 to 9)  & ex4_res_so(0);
  f_add_so               <= ex4_cmp_so  (0) ;

end; -- fuq_add ARCHITECTURE
