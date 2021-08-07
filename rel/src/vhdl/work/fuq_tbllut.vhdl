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


 
entity fuq_tbllut is
generic( expand_type               : integer := 2  );
port(
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic_vector(2 to 5); -- tidn,
       mpw1_b                                    :in   std_ulogic_vector(2 to 5); -- tidn,
       mpw2_b                                    :in   std_ulogic_vector(0 to 1); -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;


       si                        :in  std_ulogic; --perv
       so                        :out std_ulogic; --perv
       ex1_act                   :in  std_ulogic; --act
       ------------------------------
       f_fmt_ex1_b_frac          :in  std_ulogic_vector(1 to 6);
       f_fmt_ex2_b_frac          :in  std_ulogic_vector(7 to 22);
       f_tbe_ex2_expo_lsb        :in  std_ulogic;
       f_tbe_ex2_est_recip       :in  std_ulogic;
       f_tbe_ex2_est_rsqrt       :in  std_ulogic;
       f_tbe_ex3_recip_ue1       :in  std_ulogic ; 
       f_tbe_ex3_lu_sh           :in  std_ulogic;
       f_tbe_ex3_match_en_sp     :in  std_ulogic;
       f_tbe_ex3_match_en_dp     :in  std_ulogic;
       f_tbe_ex3_recip_2046      :in  std_ulogic;
       f_tbe_ex3_recip_2045      :in  std_ulogic;
       f_tbe_ex3_recip_2044      :in  std_ulogic;
       ------------------------------
       f_tbl_ex5_est_frac        :out  std_ulogic_vector(0 to 26); 
       f_tbl_ex4_unf_expo        :out  std_ulogic ; 
       f_tbl_ex5_recip_den       :out  std_ulogic --generates den flag
);


end fuq_tbllut; -- ENTITY

architecture fuq_tbllut of fuq_tbllut is

   constant tiup : std_ulogic := '1';
   constant tidn : std_ulogic := '0';

   signal ex4_unf_expo :std_ulogic ;
   signal ex2_f :std_ulogic_vector(1 to 6);
   signal ex2_sel_recip,          ex2_sel_rsqte, ex2_sel_rsqto : std_ulogic;
   signal ex2_est, ex2_est_recip, ex2_est_rsqte, ex2_est_rsqto :std_ulogic_vector(1 to 20);
   signal ex2_rng :std_ulogic_vector(6 to 20);
   signal ex2_rng_recip, ex2_rng_rsqte, ex2_rng_rsqto :std_ulogic_vector(6 to 20);

   signal thold_0_b, thold_0, forcee,  sg_0 :std_ulogic ;
   signal ex2_act, ex3_act, ex4_act :std_ulogic;
   signal spare_unused  :std_ulogic_vector(0 to 3);

   signal ex2_lut_so, ex2_lut_si :std_ulogic_vector(0 to 5);
   signal act_so,     act_si     :std_ulogic_vector(0 to 6);
   signal ex3_lut_e_so, ex3_lut_e_si :std_ulogic_vector(0 to 19);
   signal ex3_lut_r_so, ex3_lut_r_si :std_ulogic_vector(0 to 14);
   signal ex3_lut_b_so, ex3_lut_b_si :std_ulogic_vector(0 to 15);


   signal ex3_rng, ex3_rng_b :std_ulogic_vector(6 to 20);
   signal ex3_est, ex3_est_b :std_ulogic_vector(1 to 20);
   signal ex3_bop, ex3_bop_b :std_ulogic_vector(7 to 22);
   signal ex3_tbl_sum :std_ulogic_vector(0 to 36) ;
   signal ex3_tbl_car :std_ulogic_vector(0 to 35) ;
   signal ex4_tbl_sum :std_ulogic_vector(0 to 38) ;
   signal ex4_tbl_car :std_ulogic_vector(0 to 38) ;

   signal ex4_lut_so  , ex4_lut_si  :std_ulogic_vector(0 to 79);                   

   signal ex5_lut_so  , ex5_lut_si  :std_ulogic_vector(0 to 27) ;
   signal ex4_lu , ex4_lux :std_ulogic_vector(0 to 27) ;
   signal ex4_lu_nrm :std_ulogic_vector(0 to 26) ;
   signal ex5_lu :std_ulogic_vector(0 to 26); 

   signal lua_p :std_ulogic_vector(0 to 27);
   signal lua_t :std_ulogic_vector(1 to 37);
   signal lua_g :std_ulogic_vector(1 to 38);
  signal lua_g2 :std_ulogic_vector(1 to 38);
  signal lua_g4 :std_ulogic_vector(1 to 36);
  signal lua_g8 :std_ulogic_vector(1 to 32);
  signal lua_t2 :std_ulogic_vector(1 to 36);
  signal lua_t4 :std_ulogic_vector(1 to 32);
  signal lua_t8 :std_ulogic_vector(1 to 28);
  signal lua_gt8  :std_ulogic_vector(1 to 28);
  signal lua_s0_b :std_ulogic_vector(0 to 27);
  signal lua_s1_b :std_ulogic_vector(0 to 27);
  signal lua_g16 : std_ulogic_vector(0 to 3);
  signal lua_t16 : std_ulogic_vector(0 to 1);
  signal lua_c32 , lua_c24 , lua_c16 , lua_c08  :std_ulogic;
   signal ex4_recip_den, ex5_recip_den :std_ulogic ;
   signal ex4_lu_sh , ex4_recip_ue1,  ex4_recip_2044, ex4_recip_2046 , ex4_recip_2045 :std_ulogic;
   signal ex4_recip_2044_dp, ex4_recip_2046_dp , ex4_recip_2045_dp :std_ulogic;
   signal ex4_recip_2044_sp, ex4_recip_2046_sp , ex4_recip_2045_sp :std_ulogic;

   signal ex4_shlft_1, ex4_shlft_0, ex4_shrgt_1, ex4_shrgt_2 :std_ulogic;
   signal ex4_match_en_sp , ex4_match_en_dp :std_ulogic;
   signal tbl_ex3_d1clk, tbl_ex3_d2clk :std_ulogic;
   signal tbl_ex4_d1clk, tbl_ex4_d2clk :std_ulogic;
   signal tbl_ex3_lclk :clk_logic;
   signal tbl_ex4_lclk :clk_logic;
   signal unused :std_ulogic;
  signal ex4_tbl_sum_b           :std_ulogic_vector(0 to 36)  ;
  signal ex4_tbl_car_b           :std_ulogic_vector(0 to 35)  ;
  signal ex4_match_en_sp_b       :std_ulogic;
  signal ex4_match_en_dp_b       :std_ulogic;
  signal ex4_recip_2046_b        :std_ulogic;
  signal ex4_recip_2045_b        :std_ulogic;
  signal ex4_recip_2044_b        :std_ulogic;
  signal ex4_lu_sh_b             :std_ulogic;
  signal ex4_recip_ue1_b         :std_ulogic;

   signal  ex4_sp_chop_24,   ex4_sp_chop_23, ex4_sp_chop_22, ex4_sp_chop_21 :std_ulogic; 

 

begin

   unused <= or_reduce(lua_g8(29 to 31) )  or  or_reduce(lua_g4(33 to 35) ) ;

--==##############################################################
--= ex2 logic
--==##############################################################

    ex2_lut_lat: tri_rlmreg_p generic map (width=> 6, expand_type => expand_type) port map ( 
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
        scout            => ex2_lut_so  ,                      
        scin             => ex2_lut_si  ,                    
        -------------------
        din              => f_fmt_ex1_b_frac(1 to 6), 
        dout             => ex2_f(1 to 6)   );

--==##############################################################
--= ex2 logic
--==##############################################################

  --==###########################################
  --= rsqrt ev lookup table
  --==###########################################

ftbe: entity WORK.fuq_tblsqe(fuq_tblsqe)  generic map( expand_type => expand_type) port map(
      f(1 to 6)    => ex2_f(1 to 6)           ,--i--
      est(1 to 20) => ex2_est_rsqte(1 to 20)  ,--o--
      rng(6 to 20) => ex2_rng_rsqte(6 to 20) );--o--

  --==###########################################
  --= rsqrt od lookup table
  --==###########################################

ftbo: entity WORK.fuq_tblsqo(fuq_tblsqo)  generic map( expand_type => expand_type) port map( 
      f(1 to 6)    => ex2_f(1 to 6)           ,--i--
      est(1 to 20) => ex2_est_rsqto(1 to 20)  ,--o--
      rng(6 to 20) => ex2_rng_rsqto(6 to 20) );--o--

  --==###########################################
  --= recip lookup table
  --==###########################################

ftbr: entity WORK.fuq_tblres(fuq_tblres)  generic map( expand_type => expand_type) port map( 
      f(1 to 6)    => ex2_f(1 to 6)           ,--i--
      est(1 to 20) => ex2_est_recip(1 to 20)  ,--o--
      rng(6 to 20) => ex2_rng_recip(6 to 20) );--o--



  --==###########################################
  --= muxing
  --==###########################################

   ex2_sel_recip  <= f_tbe_ex2_est_recip;
   ex2_sel_rsqte  <= f_tbe_ex2_est_rsqrt and not f_tbe_ex2_expo_lsb ;
   ex2_sel_rsqto  <= f_tbe_ex2_est_rsqrt and     f_tbe_ex2_expo_lsb ;

   ex2_est(1 to 20) <= -- nand2 / nand3
        ( (1 to 20=> ex2_sel_recip) and ex2_est_recip(1 to 20)  ) or 
        ( (1 to 20=> ex2_sel_rsqte) and ex2_est_rsqte(1 to 20)  ) or 
        ( (1 to 20=> ex2_sel_rsqto) and ex2_est_rsqto(1 to 20)  ) ;


   ex2_rng(6 to 20) <= -- nand2 / nand3
        ( (6 to 20=> ex2_sel_recip ) and (       ex2_rng_recip(6 to 20))  ) or 
        ( (6 to 20=> ex2_sel_rsqte ) and (       ex2_rng_rsqte(6 to 20))  ) or
        ( (6 to 20=> ex2_sel_rsqto ) and (       ex2_rng_rsqto(6 to 20))  ) ;


--==##############################################################
--= ex3 latches
--==##############################################################

    ex3_lut_e_lat:  entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 20, btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0  ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK           => tbl_ex3_lclk               ,-- lclk.clk
        D1CLK          => tbl_ex3_d1clk              ,
        D2CLK          => tbl_ex3_d2clk              ,
        SCANIN         => ex3_lut_e_si               ,                    
        SCANOUT        => ex3_lut_e_so               ,
        D(0 to 19)     => ex2_est(1 to 20)           , --0:19
        QB(0 to 19)    => ex3_est_b(1 to 20)        ); --0:19

    ex3_lut_r_lat:  entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 15, btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 0  ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK           => tbl_ex3_lclk               ,-- lclk.clk
        D1CLK          => tbl_ex3_d1clk              ,
        D2CLK          => tbl_ex3_d2clk              ,
        SCANIN         => ex3_lut_r_si               ,                    
        SCANOUT        => ex3_lut_r_so               ,
        D(0 to 14)     => ex2_rng(6 to 20)           , --20:34
        QB(0 to 14)    => ex3_rng_b(6 to 20)        ); --20:34

    ex3_lut_b_lat:  entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 16, btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0  ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK           => tbl_ex3_lclk               ,-- lclk.clk
        D1CLK          => tbl_ex3_d1clk              ,
        D2CLK          => tbl_ex3_d2clk              ,
        SCANIN         => ex3_lut_b_si               ,                    
        SCANOUT        => ex3_lut_b_so               ,
        D(0 to 15)     => f_fmt_ex2_b_frac(7 to 22)  , --35:50
        QB(0 to 15)    => ex3_bop_b(7 to 22)        ); --35:50

   ex3_est(1 to 20) <= not ex3_est_b(1 to 20);
   ex3_rng(6 to 20) <= not ex3_rng_b(6 to 20);
   ex3_bop(7 to 22) <= not ex3_bop_b(7 to 22);


--==##############################################################
--= ex3 logic : multiply
--==##############################################################

ftbm: entity WORK.fuq_tblmul(fuq_tblmul)  generic map( expand_type => expand_type) port map(
      vdd              => vdd,
      gnd              => gnd,
      x(1 to 15)       => ex3_rng(6 to 20)        ,--i-- RECODED
      y(7 to 22)       => ex3_bop(7 to 22)        ,--i-- SHIFTED
      z(0)             => tiup                    ,--i--
      z(1 to 20)       => ex3_est(1 to 20)        ,--i--
      tbl_sum(0 to 36) => ex3_tbl_sum(0 to 36)    ,--o--
      tbl_car(0 to 35) => ex3_tbl_car(0 to 35)   );--o--

        
--==##############################################################
--= ex4 latches
--==##############################################################


    ex4_lut_lat:  entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 80, btr => "NLI0001_X2_A12TH", expand_type => expand_type , needs_sreset => 0 ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK           => tbl_ex4_lclk               ,-- lclk.clk
        D1CLK          => tbl_ex4_d1clk              ,
        D2CLK          => tbl_ex4_d2clk              ,
        SCANIN         => ex4_lut_si                 ,                    
        SCANOUT        => ex4_lut_so                 ,                      
        D(0 to 36)     => ex3_tbl_sum(0 to 36) ,
        D(37 to 72)    => ex3_tbl_car(0 to 35) ,
        D(73)          => f_tbe_ex3_match_en_sp ,
        D(74)          => f_tbe_ex3_match_en_dp ,
        D(75)          => f_tbe_ex3_recip_2046 ,
        D(76)          => f_tbe_ex3_recip_2045 ,
        D(77)          => f_tbe_ex3_recip_2044  ,
        D(78)          => f_tbe_ex3_lu_sh      ,
        D(79)          => f_tbe_ex3_recip_ue1 ,
        ------
        QB(0 to 36)     => ex4_tbl_sum_b(0 to 36) ,
        QB(37 to 72)    => ex4_tbl_car_b(0 to 35) ,
        QB(73)          => ex4_match_en_sp_b      ,
        QB(74)          => ex4_match_en_dp_b      ,
        QB(75)          => ex4_recip_2046_b       ,
        QB(76)          => ex4_recip_2045_b       ,
        QB(77)          => ex4_recip_2044_b       ,
        QB(78)          => ex4_lu_sh_b            ,
        QB(79)          => ex4_recip_ue1_b       );


        ex4_tbl_sum  (0 to 36)  <= not ex4_tbl_sum_b(0 to 36) ;
        ex4_tbl_car  (0 to 35)  <= not ex4_tbl_car_b(0 to 35) ;
        ex4_match_en_sp         <= not ex4_match_en_sp_b      ;
        ex4_match_en_dp         <= not ex4_match_en_dp_b      ;
        ex4_recip_2046          <= not ex4_recip_2046_b       ;
        ex4_recip_2045          <= not ex4_recip_2045_b       ;
        ex4_recip_2044          <= not ex4_recip_2044_b       ;
        ex4_lu_sh               <= not ex4_lu_sh_b            ;
        ex4_recip_ue1           <= not ex4_recip_ue1_b        ;




        ex4_tbl_sum(37) <= tidn;
        ex4_tbl_sum(38) <= tidn;

        ex4_tbl_car(36) <=  tidn; --tiup; -- the +1 in -mul = !mul + 1
        ex4_tbl_car(37) <=  tidn; --tiup; -- the +1 in -mul = !mul + 1
        ex4_tbl_car(38) <=  tidn; --tiup; -- the +1 in -mul = !mul + 1

--==##############################################################
--= ex4 logic : add
--==##############################################################
  -- all bits paricipate in the carry, but only upper bits of sum are returned

  -- P/G/T ------------------------------------------------------
  lua_p(0 to 27) <= ex4_tbl_sum(0 to 27) xor ex4_tbl_car(0 to 27);
  lua_t(1 to 37) <= ex4_tbl_sum(1 to 37)  or ex4_tbl_car(1 to 37);
  lua_g(1 to 38) <= ex4_tbl_sum(1 to 38) and ex4_tbl_car(1 to 38);

  -- LOCAL BYTE CARRY --------------------------------------------------


  lua_g2(38) <= lua_g(38) ; 
  lua_g2(37) <= lua_g(37) or (lua_t(37) and lua_g(38) ); 
  lua_g2(36) <= lua_g(36) or (lua_t(36) and lua_g(37) ); 
  lua_g2(35) <= lua_g(35) or (lua_t(35) and lua_g(36) ); 
  lua_g2(34) <= lua_g(34) or (lua_t(34) and lua_g(35) ); 
  lua_g2(33) <= lua_g(33) or (lua_t(33) and lua_g(34) ); 
  lua_g2(32) <= lua_g(32) or (lua_t(32) and lua_g(33) ); 
  lua_t2(36) <= lua_t(36) and lua_t(37) ; 
  lua_t2(35) <= lua_t(35) and lua_t(36) ; 
  lua_t2(34) <= lua_t(34) and lua_t(35) ; 
  lua_t2(33) <= lua_t(33) and lua_t(34) ; 
  lua_t2(32) <= lua_t(32) and lua_t(33) ; 
  lua_g4(36) <= lua_g2(36) or (lua_t2(36) and lua_g2(38) ); 
  lua_g4(35) <= lua_g2(35) or (lua_t2(35) and lua_g2(37) ); 
  lua_g4(34) <= lua_g2(34) or (lua_t2(34) and lua_g2(36) ); 
  lua_g4(33) <= lua_g2(33) or (lua_t2(33) and lua_g2(35) ); 
  lua_g4(32) <= lua_g2(32) or (lua_t2(32) and lua_g2(34) ); 
  lua_t4(32) <= lua_t2(32) and lua_t2(34) ; 
  lua_g8(32) <= lua_g4(32) or (lua_t4(32) and lua_g4(36) ); 
  

  

  lua_g2(31) <= lua_g(31) ; 
  lua_g2(30) <= lua_g(30) or (lua_t(30) and lua_g(31) ); 
  lua_g2(29) <= lua_g(29) or (lua_t(29) and lua_g(30) ); 
  lua_g2(28) <= lua_g(28) or (lua_t(28) and lua_g(29) ); 
  lua_g2(27) <= lua_g(27) or (lua_t(27) and lua_g(28) ); 
  lua_g2(26) <= lua_g(26) or (lua_t(26) and lua_g(27) ); 
  lua_g2(25) <= lua_g(25) or (lua_t(25) and lua_g(26) ); 
  lua_g2(24) <= lua_g(24) or (lua_t(24) and lua_g(25) ); 
  lua_t2(31) <= lua_t(31) ; 
  lua_t2(30) <= lua_t(30) and lua_t(31) ; 
  lua_t2(29) <= lua_t(29) and lua_t(30) ; 
  lua_t2(28) <= lua_t(28) and lua_t(29) ; 
  lua_t2(27) <= lua_t(27) and lua_t(28) ; 
  lua_t2(26) <= lua_t(26) and lua_t(27) ; 
  lua_t2(25) <= lua_t(25) and lua_t(26) ; 
  lua_t2(24) <= lua_t(24) and lua_t(25) ; 
  lua_g4(31) <= lua_g2(31) ; 
  lua_g4(30) <= lua_g2(30) ; 
  lua_g4(29) <= lua_g2(29) or (lua_t2(29) and lua_g2(31) ); 
  lua_g4(28) <= lua_g2(28) or (lua_t2(28) and lua_g2(30) ); 
  lua_g4(27) <= lua_g2(27) or (lua_t2(27) and lua_g2(29) ); 
  lua_g4(26) <= lua_g2(26) or (lua_t2(26) and lua_g2(28) ); 
  lua_g4(25) <= lua_g2(25) or (lua_t2(25) and lua_g2(27) ); 
  lua_g4(24) <= lua_g2(24) or (lua_t2(24) and lua_g2(26) ); 
  lua_t4(31) <= lua_t2(31) ; 
  lua_t4(30) <= lua_t2(30) ; 
  lua_t4(29) <= lua_t2(29) and lua_t2(31) ; 
  lua_t4(28) <= lua_t2(28) and lua_t2(30) ; 
  lua_t4(27) <= lua_t2(27) and lua_t2(29) ; 
  lua_t4(26) <= lua_t2(26) and lua_t2(28) ; 
  lua_t4(25) <= lua_t2(25) and lua_t2(27) ; 
  lua_t4(24) <= lua_t2(24) and lua_t2(26) ; 
  lua_g8(31) <= lua_g4(31) ; 
  lua_g8(30) <= lua_g4(30) ; 
  lua_g8(29) <= lua_g4(29) ; 
  lua_g8(28) <= lua_g4(28) ; 
  lua_g8(27) <= lua_g4(27) or (lua_t4(27) and lua_g4(31) ); 
  lua_g8(26) <= lua_g4(26) or (lua_t4(26) and lua_g4(30) ); 
  lua_g8(25) <= lua_g4(25) or (lua_t4(25) and lua_g4(29) ); 
  lua_g8(24) <= lua_g4(24) or (lua_t4(24) and lua_g4(28) ); 
  lua_t8(28) <= lua_t4(28) ; 
  lua_t8(27) <= lua_t4(27) and lua_t4(31) ; 
  lua_t8(26) <= lua_t4(26) and lua_t4(30) ; 
  lua_t8(25) <= lua_t4(25) and lua_t4(29) ; 
  lua_t8(24) <= lua_t4(24) and lua_t4(28) ; 
  

  

  lua_g2(23) <= lua_g(23) ; 
  lua_g2(22) <= lua_g(22) or (lua_t(22) and lua_g(23) ); 
  lua_g2(21) <= lua_g(21) or (lua_t(21) and lua_g(22) ); 
  lua_g2(20) <= lua_g(20) or (lua_t(20) and lua_g(21) ); 
  lua_g2(19) <= lua_g(19) or (lua_t(19) and lua_g(20) ); 
  lua_g2(18) <= lua_g(18) or (lua_t(18) and lua_g(19) ); 
  lua_g2(17) <= lua_g(17) or (lua_t(17) and lua_g(18) ); 
  lua_g2(16) <= lua_g(16) or (lua_t(16) and lua_g(17) ); 
  lua_t2(23) <= lua_t(23) ; 
  lua_t2(22) <= lua_t(22) and lua_t(23) ; 
  lua_t2(21) <= lua_t(21) and lua_t(22) ; 
  lua_t2(20) <= lua_t(20) and lua_t(21) ; 
  lua_t2(19) <= lua_t(19) and lua_t(20) ; 
  lua_t2(18) <= lua_t(18) and lua_t(19) ; 
  lua_t2(17) <= lua_t(17) and lua_t(18) ; 
  lua_t2(16) <= lua_t(16) and lua_t(17) ; 
  lua_g4(23) <= lua_g2(23) ; 
  lua_g4(22) <= lua_g2(22) ; 
  lua_g4(21) <= lua_g2(21) or (lua_t2(21) and lua_g2(23) ); 
  lua_g4(20) <= lua_g2(20) or (lua_t2(20) and lua_g2(22) ); 
  lua_g4(19) <= lua_g2(19) or (lua_t2(19) and lua_g2(21) ); 
  lua_g4(18) <= lua_g2(18) or (lua_t2(18) and lua_g2(20) ); 
  lua_g4(17) <= lua_g2(17) or (lua_t2(17) and lua_g2(19) ); 
  lua_g4(16) <= lua_g2(16) or (lua_t2(16) and lua_g2(18) ); 
  lua_t4(23) <= lua_t2(23) ; 
  lua_t4(22) <= lua_t2(22) ; 
  lua_t4(21) <= lua_t2(21) and lua_t2(23) ; 
  lua_t4(20) <= lua_t2(20) and lua_t2(22) ; 
  lua_t4(19) <= lua_t2(19) and lua_t2(21) ; 
  lua_t4(18) <= lua_t2(18) and lua_t2(20) ; 
  lua_t4(17) <= lua_t2(17) and lua_t2(19) ; 
  lua_t4(16) <= lua_t2(16) and lua_t2(18) ; 
  lua_g8(23) <= lua_g4(23) ; 
  lua_g8(22) <= lua_g4(22) ; 
  lua_g8(21) <= lua_g4(21) ; 
  lua_g8(20) <= lua_g4(20) ; 
  lua_g8(19) <= lua_g4(19) or (lua_t4(19) and lua_g4(23) ); 
  lua_g8(18) <= lua_g4(18) or (lua_t4(18) and lua_g4(22) ); 
  lua_g8(17) <= lua_g4(17) or (lua_t4(17) and lua_g4(21) ); 
  lua_g8(16) <= lua_g4(16) or (lua_t4(16) and lua_g4(20) ); 
  lua_t8(23) <= lua_t4(23) ; 
  lua_t8(22) <= lua_t4(22) ; 
  lua_t8(21) <= lua_t4(21) ; 
  lua_t8(20) <= lua_t4(20) ; 
  lua_t8(19) <= lua_t4(19) and lua_t4(23) ; 
  lua_t8(18) <= lua_t4(18) and lua_t4(22) ; 
  lua_t8(17) <= lua_t4(17) and lua_t4(21) ; 
  lua_t8(16) <= lua_t4(16) and lua_t4(20) ; 
  

  

  lua_g2(15) <= lua_g(15) ; 
  lua_g2(14) <= lua_g(14) or (lua_t(14) and lua_g(15) ); 
  lua_g2(13) <= lua_g(13) or (lua_t(13) and lua_g(14) ); 
  lua_g2(12) <= lua_g(12) or (lua_t(12) and lua_g(13) ); 
  lua_g2(11) <= lua_g(11) or (lua_t(11) and lua_g(12) ); 
  lua_g2(10) <= lua_g(10) or (lua_t(10) and lua_g(11) ); 
  lua_g2(9) <= lua_g(9) or (lua_t(9) and lua_g(10) ); 
  lua_g2(8) <= lua_g(8) or (lua_t(8) and lua_g(9) ); 
  lua_t2(15) <= lua_t(15) ; 
  lua_t2(14) <= lua_t(14) and lua_t(15) ; 
  lua_t2(13) <= lua_t(13) and lua_t(14) ; 
  lua_t2(12) <= lua_t(12) and lua_t(13) ; 
  lua_t2(11) <= lua_t(11) and lua_t(12) ; 
  lua_t2(10) <= lua_t(10) and lua_t(11) ; 
  lua_t2(9) <= lua_t(9) and lua_t(10) ; 
  lua_t2(8) <= lua_t(8) and lua_t(9) ; 
  lua_g4(15) <= lua_g2(15) ; 
  lua_g4(14) <= lua_g2(14) ; 
  lua_g4(13) <= lua_g2(13) or (lua_t2(13) and lua_g2(15) ); 
  lua_g4(12) <= lua_g2(12) or (lua_t2(12) and lua_g2(14) ); 
  lua_g4(11) <= lua_g2(11) or (lua_t2(11) and lua_g2(13) ); 
  lua_g4(10) <= lua_g2(10) or (lua_t2(10) and lua_g2(12) ); 
  lua_g4(9) <= lua_g2(9) or (lua_t2(9) and lua_g2(11) ); 
  lua_g4(8) <= lua_g2(8) or (lua_t2(8) and lua_g2(10) ); 
  lua_t4(15) <= lua_t2(15) ; 
  lua_t4(14) <= lua_t2(14) ; 
  lua_t4(13) <= lua_t2(13) and lua_t2(15) ; 
  lua_t4(12) <= lua_t2(12) and lua_t2(14) ; 
  lua_t4(11) <= lua_t2(11) and lua_t2(13) ; 
  lua_t4(10) <= lua_t2(10) and lua_t2(12) ; 
  lua_t4(9) <= lua_t2(9) and lua_t2(11) ; 
  lua_t4(8) <= lua_t2(8) and lua_t2(10) ; 
  lua_g8(15) <= lua_g4(15) ; 
  lua_g8(14) <= lua_g4(14) ; 
  lua_g8(13) <= lua_g4(13) ; 
  lua_g8(12) <= lua_g4(12) ; 
  lua_g8(11) <= lua_g4(11) or (lua_t4(11) and lua_g4(15) ); 
  lua_g8(10) <= lua_g4(10) or (lua_t4(10) and lua_g4(14) ); 
  lua_g8(9) <= lua_g4(9) or (lua_t4(9) and lua_g4(13) ); 
  lua_g8(8) <= lua_g4(8) or (lua_t4(8) and lua_g4(12) ); 
  lua_t8(15) <= lua_t4(15) ; 
  lua_t8(14) <= lua_t4(14) ; 
  lua_t8(13) <= lua_t4(13) ; 
  lua_t8(12) <= lua_t4(12) ; 
  lua_t8(11) <= lua_t4(11) and lua_t4(15) ; 
  lua_t8(10) <= lua_t4(10) and lua_t4(14) ; 
  lua_t8(9) <= lua_t4(9) and lua_t4(13) ; 
  lua_t8(8) <= lua_t4(8) and lua_t4(12) ; 
  

  

  lua_g2(7) <= lua_g(7) ; 
  lua_g2(6) <= lua_g(6) or (lua_t(6) and lua_g(7) ); 
  lua_g2(5) <= lua_g(5) or (lua_t(5) and lua_g(6) ); 
  lua_g2(4) <= lua_g(4) or (lua_t(4) and lua_g(5) ); 
  lua_g2(3) <= lua_g(3) or (lua_t(3) and lua_g(4) ); 
  lua_g2(2) <= lua_g(2) or (lua_t(2) and lua_g(3) ); 
  lua_g2(1) <= lua_g(1) or (lua_t(1) and lua_g(2) ); 
  lua_t2(7) <= lua_t(7) ; 
  lua_t2(6) <= lua_t(6) and lua_t(7) ; 
  lua_t2(5) <= lua_t(5) and lua_t(6) ; 
  lua_t2(4) <= lua_t(4) and lua_t(5) ; 
  lua_t2(3) <= lua_t(3) and lua_t(4) ; 
  lua_t2(2) <= lua_t(2) and lua_t(3) ; 
  lua_t2(1) <= lua_t(1) and lua_t(2) ; 
  lua_g4(7) <= lua_g2(7) ; 
  lua_g4(6) <= lua_g2(6) ; 
  lua_g4(5) <= lua_g2(5) or (lua_t2(5) and lua_g2(7) ); 
  lua_g4(4) <= lua_g2(4) or (lua_t2(4) and lua_g2(6) ); 
  lua_g4(3) <= lua_g2(3) or (lua_t2(3) and lua_g2(5) ); 
  lua_g4(2) <= lua_g2(2) or (lua_t2(2) and lua_g2(4) ); 
  lua_g4(1) <= lua_g2(1) or (lua_t2(1) and lua_g2(3) ); 
  lua_t4(7) <= lua_t2(7) ; 
  lua_t4(6) <= lua_t2(6) ; 
  lua_t4(5) <= lua_t2(5) and lua_t2(7) ; 
  lua_t4(4) <= lua_t2(4) and lua_t2(6) ; 
  lua_t4(3) <= lua_t2(3) and lua_t2(5) ; 
  lua_t4(2) <= lua_t2(2) and lua_t2(4) ; 
  lua_t4(1) <= lua_t2(1) and lua_t2(3) ; 
  lua_g8(7) <= lua_g4(7) ; 
  lua_g8(6) <= lua_g4(6) ; 
  lua_g8(5) <= lua_g4(5) ; 
  lua_g8(4) <= lua_g4(4) ; 
  lua_g8(3) <= lua_g4(3) or (lua_t4(3) and lua_g4(7) ); 
  lua_g8(2) <= lua_g4(2) or (lua_t4(2) and lua_g4(6) ); 
  lua_g8(1) <= lua_g4(1) or (lua_t4(1) and lua_g4(5) ); 
  lua_t8(7) <= lua_t4(7) ; 
  lua_t8(6) <= lua_t4(6) ; 
  lua_t8(5) <= lua_t4(5) ; 
  lua_t8(4) <= lua_t4(4) ; 
  lua_t8(3) <= lua_t4(3) and lua_t4(7) ; 
  lua_t8(2) <= lua_t4(2) and lua_t4(6) ; 
  lua_t8(1) <= lua_t4(1) and lua_t4(5) ; 
  


  -- CONDITIONL SUM ---------------------------------------------

  lua_gt8(1 to 28) <= lua_g8(1 to 28) or lua_t8(1 to 28);

  lua_s1_b(0 to 27) <= not( lua_p(0 to 27) xor lua_gt8(1 to 28) );
  lua_s0_b(0 to 27) <= not( lua_p(0 to 27) xor lua_g8(1 to 28) );


  -- BYTE SELECT ------------------------------
  -- ex4_lu(0 to 27) <= not( ex4_lu_p(0 to 27) xor ex4_lu_c(1 to 28) ); -- invert

  ex4_lu( 0) <= ( lua_s0_b( 0) and not lua_c08 ) or ( lua_s1_b( 0) and lua_c08 ) ;
  ex4_lu( 1) <= ( lua_s0_b( 1) and not lua_c08 ) or ( lua_s1_b( 1) and lua_c08 ) ;
  ex4_lu( 2) <= ( lua_s0_b( 2) and not lua_c08 ) or ( lua_s1_b( 2) and lua_c08 ) ;
  ex4_lu( 3) <= ( lua_s0_b( 3) and not lua_c08 ) or ( lua_s1_b( 3) and lua_c08 ) ;
  ex4_lu( 4) <= ( lua_s0_b( 4) and not lua_c08 ) or ( lua_s1_b( 4) and lua_c08 ) ;
  ex4_lu( 5) <= ( lua_s0_b( 5) and not lua_c08 ) or ( lua_s1_b( 5) and lua_c08 ) ;
  ex4_lu( 6) <= ( lua_s0_b( 6) and not lua_c08 ) or ( lua_s1_b( 6) and lua_c08 ) ;
  ex4_lu( 7) <= ( lua_s0_b( 7) and not lua_c08 ) or ( lua_s1_b( 7) and lua_c08 ) ;

  ex4_lu( 8) <= ( lua_s0_b( 8) and not lua_c16 ) or ( lua_s1_b( 8) and lua_c16 ) ;
  ex4_lu( 9) <= ( lua_s0_b( 9) and not lua_c16 ) or ( lua_s1_b( 9) and lua_c16 ) ;
  ex4_lu(10) <= ( lua_s0_b(10) and not lua_c16 ) or ( lua_s1_b(10) and lua_c16 ) ;
  ex4_lu(11) <= ( lua_s0_b(11) and not lua_c16 ) or ( lua_s1_b(11) and lua_c16 ) ;
  ex4_lu(12) <= ( lua_s0_b(12) and not lua_c16 ) or ( lua_s1_b(12) and lua_c16 ) ;
  ex4_lu(13) <= ( lua_s0_b(13) and not lua_c16 ) or ( lua_s1_b(13) and lua_c16 ) ;
  ex4_lu(14) <= ( lua_s0_b(14) and not lua_c16 ) or ( lua_s1_b(14) and lua_c16 ) ;
  ex4_lu(15) <= ( lua_s0_b(15) and not lua_c16 ) or ( lua_s1_b(15) and lua_c16 ) ;

  ex4_lu(16) <= ( lua_s0_b(16) and not lua_c24 ) or ( lua_s1_b(16) and lua_c24 ) ;
  ex4_lu(17) <= ( lua_s0_b(17) and not lua_c24 ) or ( lua_s1_b(17) and lua_c24 ) ;
  ex4_lu(18) <= ( lua_s0_b(18) and not lua_c24 ) or ( lua_s1_b(18) and lua_c24 ) ;
  ex4_lu(19) <= ( lua_s0_b(19) and not lua_c24 ) or ( lua_s1_b(19) and lua_c24 ) ;
  ex4_lu(20) <= ( lua_s0_b(20) and not lua_c24 ) or ( lua_s1_b(20) and lua_c24 ) ;
  ex4_lu(21) <= ( lua_s0_b(21) and not lua_c24 ) or ( lua_s1_b(21) and lua_c24 ) ;
  ex4_lu(22) <= ( lua_s0_b(22) and not lua_c24 ) or ( lua_s1_b(22) and lua_c24 ) ;
  ex4_lu(23) <= ( lua_s0_b(23) and not lua_c24 ) or ( lua_s1_b(23) and lua_c24 ) ;

  ex4_lu(24) <= ( lua_s0_b(24) and not lua_c32 ) or ( lua_s1_b(24) and lua_c32 ) ;
  ex4_lu(25) <= ( lua_s0_b(25) and not lua_c32 ) or ( lua_s1_b(25) and lua_c32 ) ;
  ex4_lu(26) <= ( lua_s0_b(26) and not lua_c32 ) or ( lua_s1_b(26) and lua_c32 ) ;
  ex4_lu(27) <= ( lua_s0_b(27) and not lua_c32 ) or ( lua_s1_b(27) and lua_c32 ) ;

  -- GLOBAL BYTE CARRY  ------------------------------


  lua_g16(3) <= lua_g8(32);
  lua_g16(2) <= lua_g8(24) or ( lua_t8(24) and lua_g8(32) );
  lua_g16(1) <= lua_g8(16) or ( lua_t8(16) and lua_g8(24) );
  lua_g16(0) <= lua_g8( 8) or ( lua_t8( 8) and lua_g8(16) );

  lua_t16(1) <= lua_t8(16) and lua_t8(24) ;
  lua_t16(0) <= lua_t8( 8) and lua_t8(16) ;

  lua_c32    <= lua_g16(3);
  lua_c24    <= lua_g16(2);
  lua_c16    <= lua_g16(1) or ( lua_t16(1) and lua_g16(3) );
  lua_c08    <= lua_g16(0) or ( lua_t16(0) and lua_g16(2) );

  -----------------------------------------------------------------
  -- normalize
  -----------------------------------------------------------------
      -- expo=2046 ==> imp=0 shift right 1
      -- expo=2045 ==> imp=0 shift right 0
      -- expo=other => imp=1 shift right 0 <normal reslts>
     ex4_recip_2044_dp <= ex4_recip_2044 and ex4_match_en_dp and not ex4_recip_ue1;
     ex4_recip_2045_dp <= ex4_recip_2045 and ex4_match_en_dp and not ex4_recip_ue1;
     ex4_recip_2046_dp <= ex4_recip_2046 and ex4_match_en_dp and not ex4_recip_ue1;

     ex4_recip_2044_sp <= ex4_recip_2044 and ex4_match_en_sp and not ex4_recip_ue1;
     ex4_recip_2045_sp <= ex4_recip_2045 and ex4_match_en_sp and not ex4_recip_ue1;
     ex4_recip_2046_sp <= ex4_recip_2046 and ex4_match_en_sp and not ex4_recip_ue1;



      -- lu_sh means : shift left one, and decr exponent (unless it will create a denorm exponent)

      ex4_recip_den  <=
                ex4_recip_2046_sp or                -- result in norm dp fmt, but set fpscr flag for sp unf
                ex4_recip_2045_sp or                -- result in norm dp fmt, but set fpscr flag for sp unf
               (ex4_lu_sh and ex4_recip_2044_sp) or -- result in norm dp fmt, but set fpscr flag for sp unf
                ex4_recip_2046_dp or -- use in round to set implicit bit
                ex4_recip_2045_dp or
               (ex4_lu_sh and ex4_recip_2044_dp); -- cannot shift left , denorm result

      


      -- by not denormalizing sp the fpscr(ux) is set even though the implicit bit is set
      -- divide does not want the denormed result
      ex4_unf_expo   <= -- for setting UX (same for ue=0, ue=1
                        (ex4_match_en_sp or ex4_match_en_dp) and -- leave SP normalized
                        (ex4_recip_2046 or ex4_recip_2045 or ( ex4_recip_2044 and ex4_lu_sh ) ); 

     f_tbl_ex4_unf_expo  <= ex4_unf_expo   ;--output--

      ex4_shlft_1 <= not ex4_recip_2046_dp and not ex4_recip_2045_dp and    (ex4_lu_sh and not ex4_recip_2044_dp);
      ex4_shlft_0 <= not ex4_recip_2046_dp and not ex4_recip_2045_dp and not(ex4_lu_sh and not ex4_recip_2044_dp);
      ex4_shrgt_1 <=                               ex4_recip_2045_dp ;
      ex4_shrgt_2 <=     ex4_recip_2046_dp ;


  -- the final sp result will be in dp_norm format for an sp_denorm.
  -- emulate the dropping of bits when an sp is shifted right then fitted into 23 frac bits.

 
     ex4_sp_chop_24 <= ex4_recip_2046_sp or ex4_recip_2045_sp or ex4_recip_2044_sp ;  
     ex4_sp_chop_23 <= ex4_recip_2046_sp or ex4_recip_2045_sp ;                       
     ex4_sp_chop_22 <= ex4_recip_2046_sp ;                                            
     ex4_sp_chop_21 <= tidn ;                                                         
     

     ex4_lux(0 to 20)    <= ex4_lu(0 to 20);                   
     ex4_lux(21)         <= ex4_lu(21) and not ex4_sp_chop_21; 
     ex4_lux(22)         <= ex4_lu(22) and not ex4_sp_chop_22; 
     ex4_lux(23)         <= ex4_lu(23) and not ex4_sp_chop_23; 
     ex4_lux(24)         <= ex4_lu(24) and not ex4_sp_chop_24; 
     ex4_lux(25 to 27)   <= ex4_lu(25 to 27) ;                 



      ex4_lu_nrm(0 to 26) <=                                                    
           ( (0 to 26=> ex4_shlft_1) and (              ex4_lux(1 to 27) ) ) or 
           ( (0 to 26=> ex4_shlft_0) and (              ex4_lux(0 to 26) ) ) or 
           ( (0 to 26=> ex4_shrgt_1) and (       tidn & ex4_lux(0 to 25) ) ) or 
           ( (0 to 26=> ex4_shrgt_2) and (tidn & tidn & ex4_lux(0 to 24) ) ) ;  



        

--==##############################################################
--= ex5 latches
--==##############################################################
        
    ex5_lut_lat: tri_rlmreg_p generic map (width=> 28, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(5)  ,
        mpw1_b           => mpw1_b(5)       ,
        mpw2_b           => mpw2_b(1)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => ex4_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex5_lut_so  ,                      
        scin             => ex5_lut_si  ,                    
        -------------------
        din(0 to 26)     => ex4_lu_nrm(0 to 26) ,
        din(27)          => ex4_recip_den   ,
        dout(0 to 26)    => ex5_lu(0 to 26) ,
        dout(27)         => ex5_recip_den );

       f_tbl_ex5_est_frac(0 to 26) <= ex5_lu(0 to 26);
       f_tbl_ex5_recip_den  <= ex5_recip_den ;


--==##############################################################
--= pervasive
--==##############################################################

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

--==##############################################################
--= act
--==##############################################################


    act_lat: tri_rlmreg_p  generic map (width=> 7, expand_type => expand_type) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(4)  ,
        mpw1_b           => mpw1_b(4)       ,
        mpw2_b           => mpw2_b(0)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => act_so  ,                      
        scin             => act_si  ,                    
        -------------------
        din(0)           => spare_unused(0),
        din(1)           => spare_unused(1),
        din(2)           => ex1_act,
        din(3)           => ex2_act,
        din(4)           => ex3_act,
        din(5)           => spare_unused(2),
        din(6)           => spare_unused(3),
        -------------------
        dout(0)          => spare_unused(0),
        dout(1)          => spare_unused(1),
        dout(2)          => ex2_act,
        dout(3)          => ex3_act,
        dout(4)          => ex4_act,
        dout(5)          => spare_unused(2) ,
        dout(6)          => spare_unused(3) );


    tbl_ex3_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        delay_lclkr =>  delay_lclkr(3) ,-- tidn ,--in
        mpw1_b      =>  mpw1_b(3)      ,-- tidn ,--in
        mpw2_b      =>  mpw2_b(0)      ,-- tidn ,--in
        forcee => forcee,-- tidn ,--in
        nclk        =>  nclk                 ,--in
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        act         =>  ex2_act              ,--in
        sg          =>  sg_0                 ,--in
        thold_b     =>  thold_0_b            ,--in
        d1clk       =>  tbl_ex3_d1clk        ,--out
        d2clk       =>  tbl_ex3_d2clk        ,--out
        lclk        =>  tbl_ex3_lclk        );--out

    tbl_ex4_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        delay_lclkr =>  delay_lclkr(4) ,-- tidn ,--in
        mpw1_b      =>  mpw1_b(4)      ,-- tidn ,--in
        mpw2_b      =>  mpw2_b(0)      ,-- tidn ,--in
        forcee => forcee,-- tidn ,--in
        nclk        =>  nclk                 ,--in
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        act         =>  ex3_act              ,--in
        sg          =>  sg_0                 ,--in
        thold_b     =>  thold_0_b            ,--in
        d1clk       =>  tbl_ex4_d1clk        ,--out
        d2clk       =>  tbl_ex4_d2clk        ,--out
        lclk        =>  tbl_ex4_lclk        );--out



--==##############################################################
--= scan string
--==##############################################################

  ex2_lut_si(0 to 5)     <= ex2_lut_so(1 to 5)    & si;
  ex3_lut_e_si(0 to 19)  <= ex3_lut_e_so(1 to 19) & ex2_lut_so(0);
  ex3_lut_r_si(0 to 14)  <= ex3_lut_r_so(1 to 14) & ex3_lut_e_so(0);
  ex3_lut_b_si(0 to 15)  <= ex3_lut_b_so(1 to 15) & ex3_lut_r_so(0);
  ex4_lut_si(0 to 79)    <= ex4_lut_so(1 to 79)   & ex3_lut_b_so(0);
  ex5_lut_si(0 to 27)    <= ex5_lut_so(1 to 27)   & ex4_lut_so(0);
  act_si(0 to 6)         <= act_so(1 to 6)        & ex5_lut_so(0);
  so                     <=                        act_so  (0) ;--SCAN


end; -- fuq_tbllut ARCHITECTURE
