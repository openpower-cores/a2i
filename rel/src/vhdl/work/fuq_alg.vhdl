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


 
entity fuq_alg is
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(

       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic_vector(1 to 3); -- tidn,
       mpw1_b                                    :in   std_ulogic_vector(1 to 3); -- tidn,
       mpw2_b                                    :in   std_ulogic_vector(0 to 0); -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;


       f_alg_si                  :in  std_ulogic; --perv
       f_alg_so                  :out std_ulogic; --perv
       rf1_act                   :in  std_ulogic; --act
       ex1_act                   :in  std_ulogic; --act

       f_byp_alg_ex1_b_expo      :in  std_ulogic_vector(1 to 13);
       f_byp_alg_ex1_a_expo      :in  std_ulogic_vector(1 to 13);
       f_byp_alg_ex1_c_expo      :in  std_ulogic_vector(1 to 13);
       f_byp_alg_ex1_b_frac      :in  std_ulogic_vector(0 to 52);
       f_byp_alg_ex1_b_sign      :in  std_ulogic; 

       f_fmt_ex1_prod_zero        :in  std_ulogic; -- valid and Zero (Madd/Mul)
       f_fmt_ex1_b_zero           :in  std_ulogic; -- valid and zero (could be denorm, so zero out B)
       f_fmt_ex1_pass_sel         :in  std_ulogic; 
       f_fmt_ex2_pass_frac        :in  std_ulogic_vector(0 to 52);

       f_dcd_rf1_sp               :in  std_ulogic;
       f_dcd_rf1_from_integer_b   :in  std_ulogic; -- K, spec, round
       f_dcd_rf1_to_integer_b     :in  std_ulogic; -- K, spec, round
       f_dcd_rf1_word_b           :in  std_ulogic;
       f_dcd_rf1_uns_b            :in  std_ulogic;
 
       f_pic_ex1_rnd_to_int       :in  std_ulogic;
       f_pic_ex1_frsp_ue1         :in  std_ulogic; -- K, spec, round
       f_pic_ex1_effsub_raw       :in  std_ulogic; --
       f_pic_ex1_sh_unf_ig_b      :in  std_ulogic; -- fcfid
       f_pic_ex1_sh_unf_do        :in  std_ulogic; -- (do not know why want this)
       f_pic_ex1_sh_ovf_ig_b      :in  std_ulogic; -- fcfid
       f_pic_ex1_sh_ovf_do        :in  std_ulogic; -- fsel, fpscr, fmr,
       f_pic_ex2_rnd_nr           :in  std_ulogic; --
       f_pic_ex2_rnd_inf_ok       :in  std_ulogic; -- pi/pos, ni/neg

       f_alg_ex1_sign_frmw        :out std_ulogic; -- sign bit for from_integer_word_signed
       f_alg_ex2_byp_nonflip      :out std_ulogic;
       f_alg_ex2_res              :out std_ulogic_vector(0 to 162); --sad3/add
       f_alg_ex2_sel_byp          :out std_ulogic; -- all eac selects off
       f_alg_ex2_effsub_eac_b     :out std_ulogic; -- includes cancelations
       f_alg_ex2_prod_z           :out std_ulogic;
       f_alg_ex2_sh_unf           :out std_ulogic; -- f_pic
       f_alg_ex2_sh_ovf           :out std_ulogic; -- f_pic
       f_alg_ex3_frc_sel_p1       :out std_ulogic; -- rounding converts
       f_alg_ex3_sticky           :out std_ulogic; -- part of eac control
       f_alg_ex3_int_fr           :out std_ulogic; -- f_pic
       f_alg_ex3_int_fi           :out std_ulogic  -- f_pic
);


end fuq_alg; -- ENTITY

architecture fuq_alg of fuq_alg is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal thold_0_b, thold_0, forcee  :std_ulogic;
    signal sg_0                           :std_ulogic;
    signal ex2_act                          :std_ulogic;
    signal spare_unused                     :std_ulogic_vector(0 to 3);
    ----------------------------------------
    signal act_so                           :std_ulogic_vector(0 to 4);--SCAN
    signal act_si                           :std_ulogic_vector(0 to 4);--SCAN
    signal ex1_ctl_so                       :std_ulogic_vector(0 to 4);--SCAN
    signal ex1_ctl_si                       :std_ulogic_vector(0 to 4);--SCAN
    signal ex2_shd_so, ex2_shd_si           :std_ulogic_vector(0 to 67);--SCAN
    signal ex2_shc_so, ex2_shc_si           :std_ulogic_vector(0 to 24);--SCAN
    signal ex2_ctl_so                       :std_ulogic_vector(0 to 14);--SCAN
    signal ex2_ctl_si                       :std_ulogic_vector(0 to 14);--SCAN
    signal ex3_ctl_so                       :std_ulogic_vector(0 to 10);--SCAN
    signal ex3_ctl_si                       :std_ulogic_vector(0 to 10);--SCAN
    ----------------------------------------
    signal ex1_from_integer       :std_ulogic;
    signal ex2_from_integer       :std_ulogic;
    signal ex1_to_integer         :std_ulogic;
    signal ex1_sel_special,  ex1_sel_special_b, ex2_sel_special_b       :std_ulogic;
    signal ex1_sh_ovf :std_ulogic;
    signal ex1_sh_unf_x , ex2_sh_unf_x   :std_ulogic;
    signal ex1_sel_byp_nonflip    :std_ulogic;
    signal ex1_sel_byp_nonflip_lze    :std_ulogic;
    signal ex1_from_integer_neg   :std_ulogic;
    signal ex1_integer_op         :std_ulogic;
    signal ex1_to_integer_neg     :std_ulogic;
    signal ex1_negate             :std_ulogic;
    signal ex1_effsub_alg         :std_ulogic;
    signal ex2_sh_unf             :std_ulogic;
    signal ex2_sel_byp            :std_ulogic;
    signal ex2_effsub_alg         :std_ulogic;
    signal ex2_prd_sel_pos_hi     :std_ulogic;
    signal ex2_prd_sel_neg_hi     :std_ulogic;
    signal ex2_prd_sel_pos_lo     :std_ulogic;
    signal ex2_prd_sel_neg_lo     :std_ulogic;
    signal ex2_prd_sel_pos_lohi   :std_ulogic;
    signal ex2_prd_sel_neg_lohi   :std_ulogic;
    signal ex2_byp_sel_pos        :std_ulogic;
    signal ex2_byp_sel_neg        :std_ulogic;
    signal ex2_byp_sel_byp_pos    :std_ulogic;
    signal ex2_byp_sel_byp_neg    :std_ulogic;
    signal ex2_b_sign             :std_ulogic;
    signal ex2_to_integer         :std_ulogic;
    signal ex1_sh_lvl2            :std_ulogic_vector(0 to 67)   ;
    signal ex2_sh_lvl2, ex2_sh_lvl2_b            :std_ulogic_vector(0 to 67)   ;
    signal ex2_bsha               :std_ulogic_vector(6 to 9)    ;
    signal ex2_sticky_en16_x      :std_ulogic_vector(0 to 4)    ;
    signal ex2_xthrm_6_ns_b :std_ulogic;
    signal ex2_xthrm_7_ns_b :std_ulogic;
    signal ex2_xthrm_8_b    :std_ulogic;
    signal ex2_xthrm_8a9_b  :std_ulogic;
    signal ex2_xthrm_8o9_b  :std_ulogic;
    signal ex2_xthrm7o8a9   :std_ulogic;
    signal ex2_xthrm7o8     :std_ulogic;
    signal ex2_xthrm7o8o9   :std_ulogic;
    signal ex2_xthrm7a8a9   :std_ulogic;
    signal ex2_xthrm_6_ns   :std_ulogic;
    signal ex2_ge176_b      :std_ulogic;
    signal ex2_ge160_b      :std_ulogic;
    signal ex2_ge144_b      :std_ulogic;
    signal ex2_ge128_b      :std_ulogic;
    signal ex2_ge112_b      :std_ulogic;
    signal ex1_bsha_6, ex1_bsha_7, ex1_bsha_8, ex1_bsha_9 :std_ulogic;
    signal ex2_bsha_pos :std_ulogic;
    signal ex2_sh_lvl3            :std_ulogic_vector(0 to 162)  ;    
    signal ex2_sticky_or16        :std_ulogic_vector(0 to 4)    ; 
    signal ex1_b_zero             :std_ulogic                   ;
    signal ex2_b_zero, ex2_b_zero_b           :std_ulogic                   ;

    signal ex1_dp :std_ulogic;

 signal ex2_byp_nonflip_lze :std_ulogic;
signal ex2_sel_byp_nonflip    :std_ulogic;
signal ex2_prod_zero             :std_ulogic;
signal ex2_sh_ovf_en, ex2_sh_unf_en, ex2_sh_unf_do :std_ulogic;
signal ex2_sh_ovf                    :std_ulogic;
signal ex2_integer_op          :std_ulogic;
signal ex2_negate                 :std_ulogic;
signal ex2_unf_bz                   :std_ulogic;
signal ex2_all1_x                :std_ulogic;
signal ex2_ovf_pz          :std_ulogic;
signal ex2_all1_y          :std_ulogic;
 signal ex2_sel_special :std_ulogic;
 signal rf1_from_integer , rf1_to_integer , rf1_dp :std_ulogic;
 signal rf1_uns, rf1_word, ex1_uns, ex1_word :std_ulogic;
 signal ex1_word_from, ex2_word_from :std_ulogic;
 signal ex2_rnd_to_int :std_ulogic;
 signal ex1_sign_from :std_ulogic;
 signal ex1_b_frac :std_ulogic_vector(0 to 52);  
 signal ex1_b_expo :std_ulogic_vector(1 to 13);  
 signal ex1_b_sign :std_ulogic;
 signal ex1_bsha_neg, ex2_bsha_neg : std_ulogic ;


    signal ex1_lvl1_shdcd000_b      :std_ulogic;
    signal ex1_lvl1_shdcd001_b      :std_ulogic;
    signal ex1_lvl1_shdcd002_b      :std_ulogic;
    signal ex1_lvl1_shdcd003_b      :std_ulogic;
    signal ex1_lvl2_shdcd000      :std_ulogic;
    signal ex1_lvl2_shdcd004      :std_ulogic;
    signal ex1_lvl2_shdcd008      :std_ulogic;
    signal ex1_lvl2_shdcd012      :std_ulogic;
    signal ex1_lvl3_shdcd000      :std_ulogic;
    signal ex1_lvl3_shdcd016      :std_ulogic;
    signal ex1_lvl3_shdcd032      :std_ulogic;
    signal ex1_lvl3_shdcd048      :std_ulogic;
    signal ex1_lvl3_shdcd064      :std_ulogic;
    signal ex1_lvl3_shdcd080      :std_ulogic;
    signal ex1_lvl3_shdcd096      :std_ulogic;
    signal ex1_lvl3_shdcd112      :std_ulogic;
    signal ex1_lvl3_shdcd128      :std_ulogic;
    signal ex1_lvl3_shdcd144      :std_ulogic;
    signal ex1_lvl3_shdcd160      :std_ulogic;
    signal ex1_lvl3_shdcd176      :std_ulogic;
    signal ex1_lvl3_shdcd192 :std_ulogic;-- -64
    signal ex1_lvl3_shdcd208 :std_ulogic;-- -48
    signal ex1_lvl3_shdcd224 :std_ulogic;-- -32
    signal ex1_lvl3_shdcd240 :std_ulogic;-- -16

 signal  ex2_lvl3_shdcd000 :std_ulogic;
 signal  ex2_lvl3_shdcd016 :std_ulogic;
 signal  ex2_lvl3_shdcd032 :std_ulogic;
 signal  ex2_lvl3_shdcd048 :std_ulogic;
 signal  ex2_lvl3_shdcd064 :std_ulogic;
 signal  ex2_lvl3_shdcd080 :std_ulogic;
 signal  ex2_lvl3_shdcd096 :std_ulogic;
 signal  ex2_lvl3_shdcd112 :std_ulogic;
 signal  ex2_lvl3_shdcd128 :std_ulogic;
 signal  ex2_lvl3_shdcd144 :std_ulogic;
 signal  ex2_lvl3_shdcd160 :std_ulogic;
 signal  ex2_lvl3_shdcd176 :std_ulogic;
 signal  ex2_lvl3_shdcd192 :std_ulogic;
 signal  ex2_lvl3_shdcd208 :std_ulogic;
 signal  ex2_lvl3_shdcd224 :std_ulogic;
 signal  ex2_lvl3_shdcd240 :std_ulogic;

 signal ex3_int_fr_nr1_b, ex3_int_fr_nr2_b, ex3_int_fr_ok_b :std_ulogic;
 signal ex3_int_fr :std_ulogic;
 signal ex3_sel_p1_0_b, ex3_sel_p1_1_b :std_ulogic;
 signal ex3_sticky_math     :std_ulogic;
 signal ex3_sticky_toint    :std_ulogic;
 signal ex3_sticky_toint_nr :std_ulogic;
 signal ex3_sticky_toint_ok :std_ulogic;
 signal ex3_frmneg_o_toneg  :std_ulogic;
 signal ex3_frmneg_o_topos  :std_ulogic;
 signal ex3_lsb_toint_nr    :std_ulogic;
 signal ex3_g_math          :std_ulogic;
 signal ex3_g_toint         :std_ulogic;
 signal ex3_g_toint_nr      :std_ulogic;
 signal ex3_g_toint_ok      :std_ulogic;
 signal ex2_frmneg          :std_ulogic;
 signal ex2_toneg           :std_ulogic;
 signal ex2_topos           :std_ulogic;
 signal ex2_frmneg_o_toneg  :std_ulogic;
 signal ex2_frmneg_o_topos  :std_ulogic;
 signal ex2_toint_gate_x    :std_ulogic;
 signal ex2_toint_gate_g    :std_ulogic;
 signal ex2_toint_gt_nr_x   :std_ulogic;
 signal ex2_toint_gt_nr_g   :std_ulogic;
 signal ex2_toint_gt_ok_x   :std_ulogic;
 signal ex2_toint_gt_ok_g   :std_ulogic;
 signal ex2_math_gate_x     :std_ulogic;
 signal ex2_math_gate_g     :std_ulogic;
 signal ex2_sticky_eac_x    :std_ulogic;
 signal ex2_sticky_math     :std_ulogic;
 signal ex2_sticky_toint    :std_ulogic;
 signal ex2_sticky_toint_nr :std_ulogic;
 signal ex2_sticky_toint_ok :std_ulogic;
 signal ex2_lsb_toint_nr    :std_ulogic;
 signal ex2_g_math          :std_ulogic;
 signal ex2_g_toint         :std_ulogic;
 signal ex2_g_toint_nr      :std_ulogic;
 signal ex2_g_toint_ok      :std_ulogic;
 signal ex2_sh16_162, ex2_sh16_163 :std_ulogic;
 signal alg_ex2_d1clk, alg_ex2_d2clk :std_ulogic;

 signal alg_ex2_lclk :clk_logic;

  signal ex2_bsha_b           :std_ulogic_vector(6 to 9);
  signal ex2_bsha_neg_b       :std_ulogic;
  signal ex2_sh_ovf_b         :std_ulogic;
  signal ex2_sh_unf_x_b       :std_ulogic;
  signal ex2_lvl3_shdcd000_b  :std_ulogic;
  signal ex2_lvl3_shdcd016_b  :std_ulogic;
  signal ex2_lvl3_shdcd032_b  :std_ulogic;
  signal ex2_lvl3_shdcd048_b  :std_ulogic;
  signal ex2_lvl3_shdcd064_b  :std_ulogic;
  signal ex2_lvl3_shdcd080_b  :std_ulogic;
  signal ex2_lvl3_shdcd096_b  :std_ulogic;
  signal ex2_lvl3_shdcd112_b  :std_ulogic;
  signal ex2_lvl3_shdcd128_b  :std_ulogic;
  signal ex2_lvl3_shdcd144_b  :std_ulogic;
  signal ex2_lvl3_shdcd160_b  :std_ulogic;
  signal ex2_lvl3_shdcd176_b  :std_ulogic;
  signal ex2_lvl3_shdcd192_b  :std_ulogic;
  signal ex2_lvl3_shdcd208_b  :std_ulogic;
  signal ex2_lvl3_shdcd224_b  :std_ulogic;
  signal ex2_lvl3_shdcd240_b  :std_ulogic;
  signal ex2_b_zero_l2_b           :std_ulogic;
  signal ex2_prod_zero_b           :std_ulogic;
  signal ex2_byp_nonflip_lze_b     :std_ulogic;
  signal ex2_sel_byp_nonflip_b     :std_ulogic;
  signal ex2_sh_unf_do_b           :std_ulogic;
  signal ex2_sh_unf_en_b           :std_ulogic;
  signal ex2_sh_ovf_en_b           :std_ulogic;
  signal ex2_effsub_alg_b          :std_ulogic;
  signal ex2_negate_b              :std_ulogic;
  signal ex2_b_sign_b              :std_ulogic;
  signal ex2_to_integer_b          :std_ulogic;
  signal ex2_from_integer_b        :std_ulogic;
  signal ex2_rnd_to_int_b          :std_ulogic;
  signal ex2_integer_op_b          :std_ulogic;
  signal ex2_word_from_b           :std_ulogic;

 signal unused :std_ulogic;

--==##############################################################
--# map block attributes
--==##############################################################

begin

   unused <= ex1_b_expo(1) or ex1_b_expo(2) or
             ex1_dp or --latch output
             ex2_lvl3_shdcd176 ;-- latch output

   ex1_b_frac(0 to 52) <=  f_byp_alg_ex1_b_frac(0 to 52); --RENAME
   ex1_b_sign          <=  f_byp_alg_ex1_b_sign ;         --RENAME
   ex1_b_expo(1 to 13) <=  f_byp_alg_ex1_b_expo(1 to 13); --RENAME

--==##############################################################
--# pervasive
--==##############################################################

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



--==##############################################################
--# act
--==##############################################################


    act_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type, needs_sreset => 0) port map ( 
        vd               => vdd,
        gd               => gnd,
        forcee => forcee,--i-- tidn,
        --d_mode           => d_mode       ,--i-- tiup,
        delay_lclkr      => delay_lclkr(2)  ,--i-- tidn,
        mpw1_b           => mpw1_b(2)       ,--i-- tidn,
        mpw2_b           => mpw2_b(0)       ,--i-- tidn,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => act_so  ,                      
        scin             => act_si  ,                    
        -------------------
         din(0)             => spare_unused(0),
         din(1)             => spare_unused(1),
         din(2)             => ex1_act,
         din(3)             => spare_unused(2),
         din(4)             => spare_unused(3),
        -------------------
        dout(0)             => spare_unused(0),
        dout(1)             => spare_unused(1),
        dout(2)             => ex2_act,
        dout(3)             => spare_unused(2) ,
        dout(4)             => spare_unused(3) );


    alg_ex2_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        delay_lclkr =>  delay_lclkr(2) ,-- tidn ,--in
        mpw1_b      =>  mpw1_b(2)      ,-- tidn ,--in
        mpw2_b      =>  mpw2_b(0)      ,-- tidn ,--in
        forcee => forcee,-- tidn ,--in
        nclk        =>  nclk                 ,--in
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        act         =>  ex1_act              ,--in
        sg          =>  sg_0                 ,--in
        thold_b     =>  thold_0_b            ,--in
        d1clk       =>  alg_ex2_d1clk        ,--out
        d2clk       =>  alg_ex2_d2clk        ,--out
        lclk        =>  alg_ex2_lclk        );--out




--==##############################################################
--# rf1 logic
--==##############################################################

  --#-------------------------------------------------------------
  --# shift amount calculation :start with exponent difference
  --#-------------------------------------------------------------


 
--==##############################################################
--# ex1 latches (from rf1 logic)
--==##############################################################



    rf1_from_integer    <= not f_dcd_rf1_from_integer_b ;
    rf1_to_integer      <= not f_dcd_rf1_to_integer_b ;
    rf1_dp              <= not f_dcd_rf1_sp ;
    rf1_word            <= not f_dcd_rf1_word_b ;
    rf1_uns             <= not f_dcd_rf1_uns_b ;


   ex1_ctl_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,--tidn,
      --d_mode           => d_mode       ,--tiup,
        delay_lclkr      => delay_lclkr(1)  ,--tidn,
        mpw1_b           => mpw1_b(1)       ,--tidn,
        mpw2_b           => mpw2_b(0)       ,--tidn,
        vd               => vdd          ,
        gd               => gnd          ,
        nclk             => nclk         , 
        thold_b          => thold_0_b    ,
        sg               => sg_0         , 
        act              => rf1_act      , 
        scout            => ex1_ctl_so   ,                      
        scin             => ex1_ctl_si   ,                    
        -----------------
        din(0)           => rf1_from_integer ,
        din(1)           => rf1_to_integer ,
        din(2)           => rf1_dp  ,
        din(3)           => rf1_word  ,
        din(4)           => rf1_uns  ,
        -----------------
        dout(0)          => ex1_from_integer ,
        dout(1)          => ex1_to_integer ,
        dout(2)          => ex1_dp    ,
        dout(3)          => ex1_word  ,
        dout(4)          => ex1_uns   );



--==##############################################################
--# ex1 logic
--==##############################################################

 sha: entity work.fuq_alg_add(fuq_alg_add) generic map (expand_type => expand_type) port map(
       vdd                           => vdd,
       gnd                           => gnd,
       f_byp_alg_ex1_b_expo(1 to 13) => f_byp_alg_ex1_b_expo ,--i--
       f_byp_alg_ex1_a_expo(1 to 13) => f_byp_alg_ex1_a_expo ,--i--
       f_byp_alg_ex1_c_expo(1 to 13) => f_byp_alg_ex1_c_expo ,--i--
  --   ex1_sel_special               => ex1_sel_special      ,--i--
       ex1_sel_special_b             => ex1_sel_special_b    ,--i--
       ex1_bsha_6_o                  => ex1_bsha_6           ,--o--
       ex1_bsha_7_o                  => ex1_bsha_7           ,--o--
       ex1_bsha_8_o                  => ex1_bsha_8           ,--o--
       ex1_bsha_9_o                  => ex1_bsha_9           ,--o--
       ex1_bsha_neg_o                => ex1_bsha_neg         ,--o--
       ex1_sh_ovf                    => ex1_sh_ovf           ,--o--
       ex1_sh_unf_x                  => ex1_sh_unf_x         ,--o--
       ex1_lvl1_shdcd000_b           => ex1_lvl1_shdcd000_b  ,--o--
       ex1_lvl1_shdcd001_b           => ex1_lvl1_shdcd001_b  ,--o--
       ex1_lvl1_shdcd002_b           => ex1_lvl1_shdcd002_b  ,--o--
       ex1_lvl1_shdcd003_b           => ex1_lvl1_shdcd003_b  ,--o--
       ex1_lvl2_shdcd000             => ex1_lvl2_shdcd000    ,--o--
       ex1_lvl2_shdcd004             => ex1_lvl2_shdcd004    ,--o--
       ex1_lvl2_shdcd008             => ex1_lvl2_shdcd008    ,--o--
       ex1_lvl2_shdcd012             => ex1_lvl2_shdcd012    ,--o--
       ex1_lvl3_shdcd000             => ex1_lvl3_shdcd000    ,--o--
       ex1_lvl3_shdcd016             => ex1_lvl3_shdcd016    ,--o--
       ex1_lvl3_shdcd032             => ex1_lvl3_shdcd032    ,--o--
       ex1_lvl3_shdcd048             => ex1_lvl3_shdcd048    ,--o--
       ex1_lvl3_shdcd064             => ex1_lvl3_shdcd064    ,--o--
       ex1_lvl3_shdcd080             => ex1_lvl3_shdcd080    ,--o--
       ex1_lvl3_shdcd096             => ex1_lvl3_shdcd096    ,--o--
       ex1_lvl3_shdcd112             => ex1_lvl3_shdcd112    ,--o--
       ex1_lvl3_shdcd128             => ex1_lvl3_shdcd128    ,--o--
       ex1_lvl3_shdcd144             => ex1_lvl3_shdcd144    ,--o--
       ex1_lvl3_shdcd160             => ex1_lvl3_shdcd160    ,--o--
       ex1_lvl3_shdcd176             => ex1_lvl3_shdcd176    ,--o--
       ex1_lvl3_shdcd192             => ex1_lvl3_shdcd192    ,--o--
       ex1_lvl3_shdcd208             => ex1_lvl3_shdcd208    ,--o--
       ex1_lvl3_shdcd224             => ex1_lvl3_shdcd224    ,--o--
       ex1_lvl3_shdcd240             => ex1_lvl3_shdcd240   );--o--

       ex1_sel_special   <= ex1_from_integer ;
       ex1_sel_special_b <= not ex1_from_integer ;


  --#-------------------------------------------------
  --# determine bypass selects, operand flip
  --#-------------------------------------------------

--//----------------------------------
--// ex1
--//----------------------------------

    ex1_sel_byp_nonflip_lze <=
               ( f_fmt_ex1_pass_sel   ) or -- nan pass
               ( f_pic_ex1_sh_ovf_do  )  ; -- fsel, fpscr, fmr,

    ex1_sel_byp_nonflip <=
               ( f_pic_ex1_frsp_ue1   ) or -- <<<< move all this stuff to ex2
               ( f_fmt_ex1_pass_sel   ) or -- nan pass
               ( f_pic_ex1_sh_ovf_do  )  ; -- fsel, fpscr, fmr,

    ex1_integer_op <= ex1_from_integer or  (ex1_to_integer and not f_pic_ex1_rnd_to_int);

    -- the negate for from_integer should only catch the last 64 bits (because it is not sign extended)

    f_alg_ex1_sign_frmw <= ex1_b_frac(21) ; -- output (for sign logic)

    ex1_sign_from <=
         (ex1_from_integer and     ex1_word and ex1_b_frac(21) ) or -- 32 from left 52 - 31 = 21
         (ex1_from_integer and not ex1_word and ex1_b_sign     );

    ex1_from_integer_neg <= ex1_from_integer and ex1_sign_from and not ex1_uns;

    ex1_word_from <= ex1_word and ex1_from_integer ;

    ex1_to_integer_neg   <= ex1_to_integer   and ex1_b_sign and not f_pic_ex1_rnd_to_int;
                       
    ex1_negate <=     f_pic_ex1_effsub_raw or -- subtract op
                      ex1_from_integer_neg or 
                      ex1_to_integer_neg   ;

    ex1_effsub_alg     <= f_pic_ex1_effsub_raw and not f_fmt_ex1_pass_sel;

    ex1_b_zero     <= f_fmt_ex1_b_zero;


   

    -- for sh_unf/b_zero effadd: alg_res = 00...00 (turn off all    selects)
    -- for sh_unf/b_zero effsub: alg_res = 11...11 (turn on  pos/neg selects)
    --
    --                           0:52  53:54   55:98   99:163
    -- to_int                      0     0       0     ssssss
    -- from_int                    0     0       0     ssssss
    -- bypass{nan,fmr}             d     0       ?     ??????
    -- sh_ov
    -- sh_unf
    -- effadd
    -- effsub

 --#---------------------------------------------------------------
 --# first 2 levels of shifting (1) 0/1/2/3  (2) 0/4/8/12
 --#---------------------------------------------------------------

 sh4: entity work.fuq_alg_sh4(fuq_alg_sh4) generic map (expand_type => expand_type) port map(
      ex1_lvl1_shdcd000_b   => ex1_lvl1_shdcd000_b   ,--i--
      ex1_lvl1_shdcd001_b   => ex1_lvl1_shdcd001_b   ,--i--
      ex1_lvl1_shdcd002_b   => ex1_lvl1_shdcd002_b   ,--i--
      ex1_lvl1_shdcd003_b   => ex1_lvl1_shdcd003_b   ,--i--
      ex1_lvl2_shdcd000     => ex1_lvl2_shdcd000     ,--i--
      ex1_lvl2_shdcd004     => ex1_lvl2_shdcd004     ,--i--
      ex1_lvl2_shdcd008     => ex1_lvl2_shdcd008     ,--i--
      ex1_lvl2_shdcd012     => ex1_lvl2_shdcd012     ,--i--
      ex1_sel_special       => ex1_sel_special       ,--i--
      ex1_b_sign            => ex1_b_sign            ,--i--
      ex1_b_expo(3 to 13)   => ex1_b_expo(3 to 13)   ,--i--
      ex1_b_frac(0 to 52)   => ex1_b_frac(0 to 52)   ,--i--
      ex1_sh_lvl2(0 to 67)  => ex1_sh_lvl2(0 to 67) );--o--

--==##############################################################
--# ex2 latches  (from ex1 logic)
--==##############################################################

    ex2_shd_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 68, btr => "NLI0001_X2_A12TH",  expand_type => expand_type,  needs_sreset => 0  ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK             => alg_ex2_lclk               ,-- lclk.clk
        D1CLK            => alg_ex2_d1clk              ,
        D2CLK            => alg_ex2_d2clk              ,
        SCANIN           => ex2_shd_si                 ,                    
        SCANOUT          => ex2_shd_so                 ,                      
        D                => ex1_sh_lvl2  (0 to 67)     ,
        QB               => ex2_sh_lvl2_b(0 to 67)    );

    ex2_sh_lvl2(0 to 67) <= not ex2_sh_lvl2_b(0 to 67) ;   


    ex2_shc_lat:  entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 25, btr => "NLI0001_X2_A12TH",  expand_type => expand_type,  needs_sreset => 0  ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK             => alg_ex2_lclk               ,-- lclk.clk
        D1CLK            => alg_ex2_d1clk              ,
        D2CLK            => alg_ex2_d2clk              ,
        SCANIN           => ex2_shc_si                 ,                    
        SCANOUT          => ex2_shc_so                 ,                      
        -------------------
         D(0)             => ex1_bsha_neg      ,
         D(1)             => ex1_sh_ovf        ,
         D(2)             => ex1_sh_unf_x      ,
         D(3)             => ex1_sel_special ,
         D(4)             => ex1_sel_special_b,
         D(5)             => ex1_bsha_6  ,
         D(6)             => ex1_bsha_7  ,
         D(7)             => ex1_bsha_8  ,
         D(8)             => ex1_bsha_9  ,
         D(9)             => ex1_lvl3_shdcd000 , 
         D(10)            => ex1_lvl3_shdcd016 ,
         D(11)            => ex1_lvl3_shdcd032 ,
         D(12)            => ex1_lvl3_shdcd048 ,
         D(13)            => ex1_lvl3_shdcd064 ,
         D(14)            => ex1_lvl3_shdcd080 ,
         D(15)            => ex1_lvl3_shdcd096 ,
         D(16)            => ex1_lvl3_shdcd112 ,
         D(17)            => ex1_lvl3_shdcd128 ,
         D(18)            => ex1_lvl3_shdcd144 ,
         D(19)            => ex1_lvl3_shdcd160 ,
         D(20)            => ex1_lvl3_shdcd176 ,
         D(21)            => ex1_lvl3_shdcd192 ,
         D(22)            => ex1_lvl3_shdcd208 ,
         D(23)            => ex1_lvl3_shdcd224 ,
         D(24)            => ex1_lvl3_shdcd240 ,
       ----------------------
         QB(0)            => ex2_bsha_neg_b       ,
         QB(1)            => ex2_sh_ovf_b         ,
         QB(2)            => ex2_sh_unf_x_b       ,
         QB(3)            => ex2_sel_special_b    ,
         QB(4)            => ex2_sel_special      ,
         QB(5)            => ex2_bsha_b(6)        ,
         QB(6)            => ex2_bsha_b(7)        ,
         QB(7)            => ex2_bsha_b(8)        ,
         QB(8)            => ex2_bsha_b(9)        ,
         QB(9)            => ex2_lvl3_shdcd000_b  , 
         QB(10)           => ex2_lvl3_shdcd016_b  ,
         QB(11)           => ex2_lvl3_shdcd032_b  ,
         QB(12)           => ex2_lvl3_shdcd048_b  ,
         QB(13)           => ex2_lvl3_shdcd064_b  ,
         QB(14)           => ex2_lvl3_shdcd080_b  ,
         QB(15)           => ex2_lvl3_shdcd096_b  ,
         QB(16)           => ex2_lvl3_shdcd112_b  ,
         QB(17)           => ex2_lvl3_shdcd128_b  ,
         QB(18)           => ex2_lvl3_shdcd144_b  ,
         QB(19)           => ex2_lvl3_shdcd160_b  ,
         QB(20)           => ex2_lvl3_shdcd176_b  ,
         QB(21)           => ex2_lvl3_shdcd192_b  ,
         QB(22)           => ex2_lvl3_shdcd208_b  ,
         QB(23)           => ex2_lvl3_shdcd224_b  ,
         QB(24)           => ex2_lvl3_shdcd240_b );


         ex2_bsha_neg         <= not ex2_bsha_neg_b       ;
         ex2_sh_ovf           <= not ex2_sh_ovf_b         ;
         ex2_sh_unf_x         <= not ex2_sh_unf_x_b       ;
         ex2_bsha(6)          <= not ex2_bsha_b(6)        ;
         ex2_bsha(7)          <= not ex2_bsha_b(7)        ;
         ex2_bsha(8)          <= not ex2_bsha_b(8)        ;
         ex2_bsha(9)          <= not ex2_bsha_b(9)        ;
         ex2_lvl3_shdcd000    <= not ex2_lvl3_shdcd000_b  ;
         ex2_lvl3_shdcd016    <= not ex2_lvl3_shdcd016_b  ;
         ex2_lvl3_shdcd032    <= not ex2_lvl3_shdcd032_b  ;
         ex2_lvl3_shdcd048    <= not ex2_lvl3_shdcd048_b  ;
         ex2_lvl3_shdcd064    <= not ex2_lvl3_shdcd064_b  ;
         ex2_lvl3_shdcd080    <= not ex2_lvl3_shdcd080_b  ;
         ex2_lvl3_shdcd096    <= not ex2_lvl3_shdcd096_b  ;
         ex2_lvl3_shdcd112    <= not ex2_lvl3_shdcd112_b  ;
         ex2_lvl3_shdcd128    <= not ex2_lvl3_shdcd128_b  ;
         ex2_lvl3_shdcd144    <= not ex2_lvl3_shdcd144_b  ;
         ex2_lvl3_shdcd160    <= not ex2_lvl3_shdcd160_b  ;
         ex2_lvl3_shdcd176    <= not ex2_lvl3_shdcd176_b  ;
         ex2_lvl3_shdcd192    <= not ex2_lvl3_shdcd192_b  ;
         ex2_lvl3_shdcd208    <= not ex2_lvl3_shdcd208_b  ;
         ex2_lvl3_shdcd224    <= not ex2_lvl3_shdcd224_b  ;
         ex2_lvl3_shdcd240    <= not ex2_lvl3_shdcd240_b  ;




    ex2_ctl_lat:  entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 15, btr => "NLI0001_X2_A12TH",  expand_type => expand_type,  needs_sreset => 0  ) port map ( 
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        LCLK             => alg_ex2_lclk               ,-- lclk.clk
        D1CLK            => alg_ex2_d1clk              ,
        D2CLK            => alg_ex2_d2clk              ,
        SCANIN           => ex2_ctl_si                 ,                    
        SCANOUT          => ex2_ctl_so                 ,                      
        -------------------
         D(0)             => ex1_b_zero                ,
         D(1)             => f_fmt_ex1_prod_zero       ,
         D(2)             => ex1_sel_byp_nonflip_lze   ,
         D(3)             => ex1_sel_byp_nonflip       ,
         D(4)             => f_pic_ex1_sh_unf_do       ,
         D(5)             => f_pic_ex1_sh_unf_ig_b     ,  
         D(6)             => f_pic_ex1_sh_ovf_ig_b     ,   
         D(7)             => ex1_effsub_alg            ,
         D(8)             => ex1_negate                ,
         D(9)             => ex1_b_sign                ,
         D(10)            => ex1_to_integer            ,
         D(11)            => ex1_from_integer          ,
         D(12)            => f_pic_ex1_rnd_to_int      ,
         D(13)            => ex1_integer_op            ,
         D(14)            => ex1_word_from             ,
        -------------------
         QB(0)            => ex2_b_zero_l2_b           ,
         QB(1)            => ex2_prod_zero_b           ,
         QB(2)            => ex2_byp_nonflip_lze_b     ,
         QB(3)            => ex2_sel_byp_nonflip_b     ,
         QB(4)            => ex2_sh_unf_do_b           ,
         QB(5)            => ex2_sh_unf_en_b           ,
         QB(6)            => ex2_sh_ovf_en_b           ,
         QB(7)            => ex2_effsub_alg_b          ,
         QB(8)            => ex2_negate_b              ,
         QB(9)            => ex2_b_sign_b              ,
         QB(10)           => ex2_to_integer_b          ,
         QB(11)           => ex2_from_integer_b        ,
         QB(12)           => ex2_rnd_to_int_b          ,
         QB(13)           => ex2_integer_op_b          ,
         QB(14)           => ex2_word_from_b          );


         ex2_b_zero             <= not ex2_b_zero_l2_b           ;
         ex2_prod_zero          <= not ex2_prod_zero_b           ;
         ex2_byp_nonflip_lze    <= not ex2_byp_nonflip_lze_b     ;
         ex2_sel_byp_nonflip    <= not ex2_sel_byp_nonflip_b     ;
         ex2_sh_unf_do          <= not ex2_sh_unf_do_b           ;
         ex2_sh_unf_en          <= not ex2_sh_unf_en_b           ;
         ex2_sh_ovf_en          <= not ex2_sh_ovf_en_b           ;
         ex2_effsub_alg         <= not ex2_effsub_alg_b          ;
         ex2_negate             <= not ex2_negate_b              ;
         ex2_b_sign             <= not ex2_b_sign_b              ;
         ex2_to_integer         <= not ex2_to_integer_b          ;
         ex2_from_integer       <= not ex2_from_integer_b        ;
         ex2_rnd_to_int         <= not ex2_rnd_to_int_b          ;
         ex2_integer_op         <= not ex2_integer_op_b          ;
         ex2_word_from          <= not ex2_word_from_b           ;




            --$$  sticky enable for 16 bit groups ------------------------
            --$$
            --$$ ex1_sticky_en16_x(0) <=
            --$$            (ex1_lvl3_shdcd176              ) or -- == 176
            --$$            (ex1_bsha( 6) and  ex1_bsha( 7) ) or -- >= 176
            --$$            (ex1_bsha( 6) and  ex1_bsha( 8) and  ex1_bsha( 9) ) ;  -- >= 176
            --$$ ex1_sticky_en16_x(1) <= ex1_sticky_en16_x(0) or  ex1_lvl3_shdcd160_x ;
            --$$ ex1_sticky_en16_x(2) <= ex1_sticky_en16_x(1) or  ex1_lvl3_shdcd144_x ;
            --$$ ex1_sticky_en16_x(3) <= ex1_sticky_en16_x(2) or  ex1_lvl3_shdcd128_x ;
            --$$ ex1_sticky_en16_x(4) <= ex1_sticky_en16_x(3) or  ex1_lvl3_shdcd112_x ;

            --------------------------------
            -- Sticky Bit Thermometer
            --------------------------------
            --    bhsa(6789)
            -- 176     1011   GE_176:  6 * (7 | (8*9) )
            -- 160     1010   GE_160:  6 * (7 | (8)   )
            -- 144     1001   GE_144   6 * (7 | (8|9) )
            -- 128     1000   GE_128:  6
            -- 112     0111   GE_112:  6 | (7 * (8*9) )

            ex2_xthrm_6_ns_b <= not( ex2_bsha(6) and ex2_sel_special_b );
            ex2_xthrm_7_ns_b <= not( ex2_bsha(7) and ex2_sel_special_b );
            ex2_xthrm_8_b    <= not( ex2_bsha(8) );
            ex2_xthrm_8a9_b  <= not( ex2_bsha(8) and ex2_bsha(9) );
            ex2_xthrm_8o9_b  <= not( ex2_bsha(8) or  ex2_bsha(9) );

            ex2_xthrm7o8a9   <= not( ex2_xthrm_7_ns_b and ex2_xthrm_8a9_b );
            ex2_xthrm7o8     <= not( ex2_xthrm_7_ns_b and ex2_xthrm_8_b   );
            ex2_xthrm7o8o9   <= not( ex2_xthrm_7_ns_b and ex2_xthrm_8o9_b );
            ex2_xthrm7a8a9   <= not( ex2_xthrm_7_ns_b or  ex2_xthrm_8a9_b );
            ex2_xthrm_6_ns   <= not( ex2_xthrm_6_ns_b );

            ex2_ge176_b      <= not( ex2_xthrm_6_ns and ex2_xthrm7o8a9 );
            ex2_ge160_b      <= not( ex2_xthrm_6_ns and ex2_xthrm7o8   );
            ex2_ge144_b      <= not( ex2_xthrm_6_ns and ex2_xthrm7o8o9 );
            ex2_ge128_b      <= not( ex2_xthrm_6_ns                    );
            ex2_ge112_b      <= not( ex2_xthrm_6_ns or  ex2_xthrm7a8a9 );

            ex2_sticky_en16_x(0) <= not ex2_ge176_b ;
            ex2_sticky_en16_x(1) <= not ex2_ge160_b ;
            ex2_sticky_en16_x(2) <= not ex2_ge144_b ;
            ex2_sticky_en16_x(3) <= not ex2_ge128_b ;
            ex2_sticky_en16_x(4) <= not ex2_ge112_b ;






 ex2_b_zero_b <= not ex2_b_zero ;


     f_alg_ex2_byp_nonflip   <=     ex2_byp_nonflip_lze ;
     f_alg_ex2_sel_byp       <=     ex2_sel_byp      ;--output-- all eac selects off
     f_alg_ex2_effsub_eac_b  <= not ex2_effsub_alg   ;--output-- includes cancelations
     f_alg_ex2_prod_z        <=     ex2_prod_zero    ;--output
     f_alg_ex2_sh_unf        <=     ex2_sh_unf       ;--output--f_pic--
     f_alg_ex2_sh_ovf        <=     ex2_ovf_pz       ;--output--f_pic--




--==##############################################################
--# ex2 logic
--==##############################################################

  --#-------------------------------------------------
  --# start sticky (passed 163 ... passed 162 for math, but need guard for fcti rounding)
  --#-------------------------------------------------

   or16: entity work.fuq_alg_or16(fuq_alg_or16) generic map (expand_type => expand_type) port map (
         ex2_sh_lvl2(0 to 67)      => ex2_sh_lvl2(0 to 67)      ,--i--
         ex2_sticky_or16(0 to 4)   => ex2_sticky_or16(0 to 4)  );--o--

  --#-------------------------------------------------
  --# finish shifting
  --#-------------------------------------------------
     -- this looks more like a 53:1 mux than a shifter to shrink it, and lower load on selects
     -- real implementation should be nand/nand/nor ... ?? integrate nor into latch ??

   sh16: entity work.fuq_alg_sh16(fuq_alg_sh16) generic map (expand_type => expand_type) port map (
         ex2_lvl3_shdcd000        => ex2_lvl3_shdcd000       ,--i--
         ex2_lvl3_shdcd016        => ex2_lvl3_shdcd016       ,--i--
         ex2_lvl3_shdcd032        => ex2_lvl3_shdcd032       ,--i--
         ex2_lvl3_shdcd048        => ex2_lvl3_shdcd048       ,--i--
         ex2_lvl3_shdcd064        => ex2_lvl3_shdcd064       ,--i--
         ex2_lvl3_shdcd080        => ex2_lvl3_shdcd080       ,--i--
         ex2_lvl3_shdcd096        => ex2_lvl3_shdcd096       ,--i--
         ex2_lvl3_shdcd112        => ex2_lvl3_shdcd112       ,--i--
         ex2_lvl3_shdcd128        => ex2_lvl3_shdcd128       ,--i--
         ex2_lvl3_shdcd144        => ex2_lvl3_shdcd144       ,--i--
         ex2_lvl3_shdcd160        => ex2_lvl3_shdcd160       ,--i--
         ex2_lvl3_shdcd192        => ex2_lvl3_shdcd192       ,--i--
         ex2_lvl3_shdcd208        => ex2_lvl3_shdcd208       ,--i--
         ex2_lvl3_shdcd224        => ex2_lvl3_shdcd224       ,--i--
         ex2_lvl3_shdcd240        => ex2_lvl3_shdcd240       ,--i--
         ex2_sel_special          => ex2_sel_special         ,--i--
         ex2_sh_lvl2(0 to 67)     => ex2_sh_lvl2(0 to 67)    ,--i-- [0:63] is also data for from integer
         ex2_sh16_162             => ex2_sh16_162            ,--o--
         ex2_sh16_163             => ex2_sh16_163            ,--o--
         ex2_sh_lvl3(0 to 162)    => ex2_sh_lvl3(0 to 162)  );--o--


 --==---------------------------------------------
 --== finish bypass controls
 --==----------------------------------------------

    ex2_ovf_pz     <= ex2_prod_zero or (ex2_sh_ovf and ex2_sh_ovf_en and not ex2_b_zero);
    ex2_sel_byp    <= ex2_sel_byp_nonflip or ex2_ovf_pz          ;
    ex2_all1_y     <= ex2_negate and ex2_ovf_pz ;
    ex2_all1_x     <= ex2_negate and ex2_unf_bz ;
    ex2_sh_unf     <= ex2_sh_unf_do or ( ex2_sh_unf_en and ex2_sh_unf_x and not ex2_prod_zero);                     
    ex2_unf_bz     <= ex2_b_zero    or   ex2_sh_unf ;




    ex2_byp_sel_byp_pos <=     
               ( ex2_sel_byp_nonflip                                                              ) or
               ( ex2_ovf_pz          and not ex2_integer_op and not ex2_negate and not ex2_unf_bz ) or 
               ( ex2_ovf_pz          and not ex2_integer_op and ex2_all1_x                        );

    ex2_byp_sel_byp_neg <= not ex2_sel_byp_nonflip and 
                               ex2_ovf_pz          and not ex2_integer_op and      ex2_negate ;

    ex2_byp_sel_pos     <=
               ( not ex2_sel_byp         and not ex2_integer_op and not ex2_negate and not ex2_unf_bz ) or 
               ( not ex2_sel_byp         and not ex2_integer_op and ex2_all1_x                        );
    ex2_byp_sel_neg     <=
               ( not ex2_sel_byp         and not ex2_integer_op and     ex2_negate                    );


    ex2_prd_sel_pos_hi    <= ex2_prd_sel_pos_lo and not ex2_integer_op ;
    ex2_prd_sel_neg_hi    <= ex2_prd_sel_neg_lo and not ex2_integer_op ;

    ex2_prd_sel_pos_lohi  <= ex2_prd_sel_pos_lo and not ex2_word_from ;
    ex2_prd_sel_neg_lohi  <= ex2_prd_sel_neg_lo and not ex2_word_from ;


    ex2_prd_sel_pos_lo  <=
               ( not ex2_sel_byp_nonflip and not ex2_ovf_pz and not ex2_unf_bz and not ex2_negate ) or  
               ( not ex2_sel_byp_nonflip and ex2_all1_x                                           ) or 
               ( not ex2_sel_byp_nonflip and ex2_all1_y                                           ) ; 
    ex2_prd_sel_neg_lo  <=
               ( not ex2_sel_byp_nonflip and                                           ex2_negate ) ;


  --#-------------------------------------------------
  --# bypass mux & operand flip
  --#-------------------------------------------------
  --# integer operation positions
  --#         32          32
  --#       99:130    131:162

   bymx: entity work.fuq_alg_bypmux(fuq_alg_bypmux) generic map (expand_type => expand_type) port map (
      ex2_byp_sel_byp_neg           => ex2_byp_sel_byp_neg             ,--i--
      ex2_byp_sel_byp_pos           => ex2_byp_sel_byp_pos             ,--i--
      ex2_byp_sel_neg               => ex2_byp_sel_neg                 ,--i--
      ex2_byp_sel_pos               => ex2_byp_sel_pos                 ,--i--
      ex2_prd_sel_neg_hi            => ex2_prd_sel_neg_hi              ,--i--
      ex2_prd_sel_neg_lo            => ex2_prd_sel_neg_lo              ,--i--
      ex2_prd_sel_neg_lohi          => ex2_prd_sel_neg_lohi            ,--i--
      ex2_prd_sel_pos_hi            => ex2_prd_sel_pos_hi              ,--i--
      ex2_prd_sel_pos_lo            => ex2_prd_sel_pos_lo              ,--i--
      ex2_prd_sel_pos_lohi          => ex2_prd_sel_pos_lohi            ,--i--
      ex2_sh_lvl3(0 to 162)         => ex2_sh_lvl3(0 to 162)           ,--i--
      f_fmt_ex2_pass_frac(0 to 52)  => f_fmt_ex2_pass_frac(0 to 52)    ,--i--
      f_alg_ex2_res(0 to 162)       => f_alg_ex2_res(0 to 162)        );--o--


  --#-------------------------------------------------
  --# finish sticky
  --#-------------------------------------------------

 ex2_frmneg          <= ex2_from_integer and   ex2_negate; --need +1 as part of negate
 ex2_toneg           <= (ex2_to_integer and not ex2_rnd_to_int and     ex2_b_sign) ; --reverse rounding for toint/neg
 ex2_topos           <= (ex2_to_integer and not ex2_rnd_to_int and not ex2_b_sign) or      ex2_rnd_to_int;
 ex2_frmneg_o_toneg  <= ex2_frmneg or ex2_toneg;
 ex2_frmneg_o_topos  <= ex2_frmneg or ex2_topos;

 ex2_math_gate_x     <= not ex2_sel_byp_nonflip and ex2_b_zero_b and  not ex2_ovf_pz      ;
 ex2_toint_gate_x    <= ex2_to_integer          and ex2_b_zero_b                          ;
 ex2_toint_gt_nr_x   <= ex2_to_integer          and ex2_b_zero_b and f_pic_ex2_rnd_nr     ;
 ex2_toint_gt_ok_x   <= ex2_to_integer          and ex2_b_zero_b and f_pic_ex2_rnd_inf_ok ;

 ex2_math_gate_g     <= not ex2_sel_byp_nonflip and  not ex2_ovf_pz and ex2_b_zero_b and (ex2_prd_sel_pos_lo or ex2_prd_sel_neg_lo);
 ex2_toint_gate_g    <= ex2_to_integer and not ex2_ovf_pz and not ex2_sh_unf and ex2_b_zero_b;
 ex2_toint_gt_nr_g   <= ex2_to_integer and not ex2_ovf_pz and not ex2_sh_unf and ex2_b_zero_b and f_pic_ex2_rnd_nr     ;
 ex2_toint_gt_ok_g   <= ex2_to_integer and not ex2_ovf_pz and not ex2_sh_unf and ex2_b_zero_b and f_pic_ex2_rnd_inf_ok ;

    ex2_bsha_pos <= not ex2_bsha_neg ;

    ex2_sticky_eac_x <= -- shift underflow enables all sticky
         ( (ex2_sh_unf or ex2_sticky_en16_x(0)) and  ex2_sticky_or16(0)  and ex2_bsha_pos  ) or  
         ( (ex2_sh_unf or ex2_sticky_en16_x(1)) and  ex2_sticky_or16(1)  and ex2_bsha_pos  ) or  
         ( (ex2_sh_unf or ex2_sticky_en16_x(2)) and  ex2_sticky_or16(2)  and ex2_bsha_pos  ) or  
         ( (ex2_sh_unf or ex2_sticky_en16_x(3)) and  ex2_sticky_or16(3)  and ex2_bsha_pos  ) or  
         ( (ex2_sh_unf or ex2_sticky_en16_x(4)) and  ex2_sticky_or16(4)  and ex2_bsha_pos  ) ;

    
 ex2_sticky_math     <= ex2_sticky_eac_x and ex2_math_gate_x ;
 ex2_sticky_toint    <= ex2_sticky_eac_x and ex2_toint_gate_x;
 ex2_sticky_toint_nr <= ex2_sticky_eac_x and ex2_toint_gt_nr_x;
 ex2_sticky_toint_ok <= ex2_sticky_eac_x and ex2_toint_gt_ok_x ;

                     -- round-to-int goes up if guard is ON (this fakes it out)
 ex2_lsb_toint_nr    <= (ex2_sh16_162 or ex2_rnd_to_int)       and ex2_toint_gt_nr_g ;

 ex2_g_math          <= ex2_sh16_163     and ex2_math_gate_g ;
 ex2_g_toint         <= ex2_sh16_163     and ex2_toint_gate_g; 
 ex2_g_toint_nr      <= ex2_sh16_163     and ex2_toint_gt_nr_g ;
 ex2_g_toint_ok      <= ex2_sh16_163     and ex2_toint_gt_ok_g ;



--==##############################################################
--# ex3 latches  (from ex2 logic)
--==##############################################################


  ex3_ctl_lat:  tri_rlmreg_p generic map (width=> 11, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,--tidn,
        delay_lclkr      => delay_lclkr(3)  ,--tidn,
        mpw1_b           => mpw1_b(3)       ,--tidn,
        mpw2_b           => mpw2_b(0)       ,--tidn,
        vd               => vdd          ,
        gd               => gnd          ,
        nclk             => nclk         , 
        thold_b          => thold_0_b    ,
        sg               => sg_0         , 
        act              => ex2_act      , 
        scout            => ex3_ctl_so   ,                      
        scin             => ex3_ctl_si   ,                    
        -----------------
         din(0)          => ex2_sticky_math     , 
         din(1)          => ex2_sticky_toint    ,
         din(2)          => ex2_sticky_toint_nr ,
         din(3)          => ex2_sticky_toint_ok ,
         din(4)          => ex2_frmneg_o_toneg  ,
         din(5)          => ex2_frmneg_o_topos  ,
         din(6)          => ex2_lsb_toint_nr    ,
         din(7)          => ex2_g_math          ,
         din(8)          => ex2_g_toint         ,
         din(9)          => ex2_g_toint_nr      ,
         din(10)         => ex2_g_toint_ok      ,
         ----------------
         dout(0)         => ex3_sticky_math     , 
         dout(1)         => ex3_sticky_toint    ,
         dout(2)         => ex3_sticky_toint_nr ,
         dout(3)         => ex3_sticky_toint_ok ,
         dout(4)         => ex3_frmneg_o_toneg  ,
         dout(5)         => ex3_frmneg_o_topos  ,
         dout(6)         => ex3_lsb_toint_nr    ,
         dout(7)         => ex3_g_math          ,
         dout(8)         => ex3_g_toint         ,
         dout(9)         => ex3_g_toint_nr      ,
         dout(10)        => ex3_g_toint_ok     ); 

--==##############################################################
--== ex3 logic
--==##############################################################

   f_alg_ex3_sticky        <= ex3_sticky_math  or ex3_g_math  ;--output--
   f_alg_ex3_int_fi        <= ex3_sticky_toint or ex3_g_toint ;--outpt--

   ex3_int_fr_nr1_b        <= not( ex3_g_toint_nr and ex3_sticky_toint_nr );
   ex3_int_fr_nr2_b        <= not( ex3_g_toint_nr and ex3_lsb_toint_nr    );
   ex3_int_fr_ok_b         <= not( ex3_g_toint_ok or  ex3_sticky_toint_ok );
   ex3_int_fr              <= not( ex3_int_fr_nr1_b and ex3_int_fr_nr2_b and ex3_int_fr_ok_b );
   f_alg_ex3_int_fr        <= ex3_int_fr     ;--output-- f_pic

   ex3_sel_p1_0_b          <= not( not ex3_int_fr and ex3_frmneg_o_toneg);
   ex3_sel_p1_1_b          <= not(     ex3_int_fr and ex3_frmneg_o_topos);
   f_alg_ex3_frc_sel_p1    <= not(ex3_sel_p1_0_b and ex3_sel_p1_1_b ) ;--output-- rounding converts

   
--==##############################################################
--# scan string
--==##############################################################

  ex1_ctl_si      (0 to 4)   <=   ex1_ctl_so      (1 to 4)   & f_alg_si  ;--SCAN
  ex2_shd_si      (0 to 67)  <=   ex2_shd_so  (1 to 67)      & ex1_ctl_so      (0) ;--SCAN
  ex2_shc_si      (0 to 24)  <=   ex2_shc_so  (1 to 24)      & ex2_shd_so      (0) ;--SCAN
  ex2_ctl_si      (0 to 14)  <=   ex2_ctl_so      (1 to 14)  & ex2_shc_so      (0) ;--SCAN
  ex3_ctl_si      (0 to 10)  <=   ex3_ctl_so      (1 to 10)  & ex2_ctl_so      (0) ;--SCAN
  act_si          (0 to 4)   <=   act_so          (1 to 4)   & ex3_ctl_so      (0) ;--SCAN
  f_alg_so                   <=     act_so          (0) ;--SCAN


end; -- fuq_alg ARCHITECTURE
