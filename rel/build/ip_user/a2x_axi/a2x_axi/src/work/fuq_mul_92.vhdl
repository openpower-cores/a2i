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
library clib ;


entity fuq_mul_92 is
  generic(expand_type : integer := 2;  
          inst  : natural := 0        );  
  port(
    vdd              : inout power_logic;                  
    gnd              : inout power_logic;                  
    nclk            : in    clk_logic;  
    si              : in    std_ulogic;  
    so              : out   std_ulogic;  
    ex1_act         : in    std_ulogic;  
    lcb_delay_lclkr : in    std_ulogic;  
    lcb_mpw1_b      : in    std_ulogic;  
    lcb_mpw2_b      : in    std_ulogic;  
    thold_b         : in    std_ulogic;  
    forcee : in    std_ulogic;  
    lcb_sg          : in    std_ulogic;  
    c_frac          : in    std_ulogic_vector(0 to 53);   
    a_frac          : in    std_ulogic_vector(17 to 35);  
    hot_one_out     : out   std_ulogic;
    sum92           : out   std_ulogic_vector(2 to 74);
    car92           : out   std_ulogic_vector(1 to 74)
  );

-- synopsys translate_off







-- synopsys translate_on
end fuq_mul_92;  

architecture fuq_mul_92 of fuq_mul_92 is

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';

  signal s_neg        : std_ulogic_vector(0 to 8);
  signal s_x          : std_ulogic_vector(0 to 8);
  signal s_x2         : std_ulogic_vector(0 to 8);
  signal xtd_2_add    : std_ulogic_vector(0 to 7);
  signal hot_one_din, hot_one_out_b : std_ulogic;

  signal pp0_00       : std_ulogic_vector(2 to 60);
  signal pp0_01       : std_ulogic_vector(4 to 62);
  signal pp0_02       : std_ulogic_vector(6 to 64);
  signal pp0_03       : std_ulogic_vector(8 to 66);
  signal pp0_04       : std_ulogic_vector(10 to 68);
  signal pp0_05       : std_ulogic_vector(12 to 70);
  signal pp0_06       : std_ulogic_vector(14 to 72);
  signal pp0_07       : std_ulogic_vector(16 to 74);
  signal pp0_08       : std_ulogic_vector(17 to 74);  
  signal pp1_05       : std_ulogic_vector(14 to 74);  
  signal pp1_04       : std_ulogic_vector(15 to 74);  
  signal pp1_03       : std_ulogic_vector(8 to 70);   
  signal pp1_02       : std_ulogic_vector(9 to 68);   
  signal pp1_01       : std_ulogic_vector(2 to 64);   
  signal pp1_00       : std_ulogic_vector(3 to 62);   
  signal pp2_03       : std_ulogic_vector(8 to 74);   
  signal pp2_02       : std_ulogic_vector(13 to 74);  
  signal pp2_01       : std_ulogic_vector(2 to 68);   
  signal pp2_00       : std_ulogic_vector(2 to 64);   
  signal pp3_01       : std_ulogic_vector(2 to 74);   
  signal pp3_00       : std_ulogic_vector(1 to 74);   
  signal pp3_00_ko    : std_ulogic_vector(7 to 63);   
  signal pp3_01_q_b   : std_ulogic_vector(2 to 74);
  signal pp3_00_q_b   : std_ulogic_vector(1 to 74);

  signal pp3_lat_sum_so :std_ulogic_vector(0 to 72);         
  signal pp3_lat_car_so :std_ulogic_vector(0 to 70);
  signal mul92_d1clk, mul92_d2clk :std_ulogic ;
  signal mul92_lclk               :clk_logic ;

   signal unused :std_ulogic ;












begin

unused <=
 pp0_00(2)  or 
 pp0_00(3)  or 
 pp0_00(59) or 
 pp0_01(4)  or  pp0_01(61) or 
 pp0_02(63) or  pp0_02(6)  or 
 pp0_03(65) or  pp0_03(8)  or 
 pp0_04(10) or  pp0_04(67) or 
 pp0_05(12) or  pp0_05(69) or 
 pp0_06(14) or  pp0_06(71) or 
 pp0_07(16) or  pp0_07(73) or 
 pp1_00(60) or  pp1_00(61) or 
 pp1_01(63) or 
 pp1_02(66) or  pp1_02(67) or 
 pp1_03(69) or  pp1_03(8)  or 
 pp1_04(72) or  pp1_04(73) or 
 pp1_05(14) or 
 pp2_00(62) or  pp2_00(63) or 
 pp2_01(66) or  pp2_01(67) or 
 pp2_02(70) or  pp2_02(72) or  pp2_02(73) or 
 pp2_03(8)  or 
 pp3_00(68) or  pp3_00(70) or  pp3_00(72) or  pp3_00(73) ;


  bd_00: entity work.fuq_mul_bthdcd(fuq_mul_bthdcd)    port map (
      i0    => a_frac(17) ,  
      i1    => a_frac(18) ,  
      i2    => a_frac(19) ,  
      s_neg => s_neg(0) ,  
      s_x   => s_x(0) ,  
      s_x2  => s_x2(0));  

  bd_01: entity work.fuq_mul_bthdcd(fuq_mul_bthdcd)    port map (
      i0    => a_frac(19) ,  
      i1    => a_frac(20) ,  
      i2    => a_frac(21) ,  
      s_neg => s_neg(1) ,  
      s_x   => s_x(1) ,  
      s_x2  => s_x2(1));  

  bd_02: entity work.fuq_mul_bthdcd(fuq_mul_bthdcd)    port map (
      i0    => a_frac(21) ,  
      i1    => a_frac(22) ,  
      i2    => a_frac(23) ,  
      s_neg => s_neg(2) ,  
      s_x   => s_x(2) ,  
      s_x2  => s_x2(2));  

  bd_03: entity work.fuq_mul_bthdcd(fuq_mul_bthdcd)    port map (
      i0    => a_frac(23) ,  
      i1    => a_frac(24) ,  
      i2    => a_frac(25) ,  
      s_neg => s_neg(3) ,  
      s_x   => s_x(3) ,  
      s_x2  => s_x2(3));  

  bd_04: entity work.fuq_mul_bthdcd(fuq_mul_bthdcd)    port map (
      i0    => a_frac(25) ,  
      i1    => a_frac(26) ,  
      i2    => a_frac(27) ,  
      s_neg => s_neg(4) ,  
      s_x   => s_x(4) ,  
      s_x2  => s_x2(4));  

  bd_05: entity work.fuq_mul_bthdcd(fuq_mul_bthdcd)    port map (
      i0    => a_frac(27) ,  
      i1    => a_frac(28) ,  
      i2    => a_frac(29) ,  
      s_neg => s_neg(5) ,  
      s_x   => s_x(5) ,  
      s_x2  => s_x2(5));  

  bd_06: entity work.fuq_mul_bthdcd(fuq_mul_bthdcd)    port map (
      i0    => a_frac(29) ,  
      i1    => a_frac(30) ,  
      i2    => a_frac(31) ,  
      s_neg => s_neg(6) ,  
      s_x   => s_x(6) ,  
      s_x2  => s_x2(6));  

  bd_07: entity work.fuq_mul_bthdcd(fuq_mul_bthdcd)    port map (
      i0    => a_frac(31) ,  
      i1    => a_frac(32) ,  
      i2    => a_frac(33) ,  
      s_neg => s_neg(7) ,  
      s_x   => s_x(7) ,  
      s_x2  => s_x2(7));  

  bd_08: entity work.fuq_mul_bthdcd(fuq_mul_bthdcd)    port map (
      i0    => a_frac(33) ,  
      i1    => a_frac(34) ,  
      i2    => a_frac(35) ,  
      s_neg => s_neg(8) ,  
      s_x   => s_x(8) ,  
      s_x2  => s_x2(8));  







  pp0_00(2) <= tiup;
  pp0_00(3) <= xtd_2_add(0);
  
  sx_00_2: xtd_2_add(0) <= not(s_neg(0) and (s_x(0) or s_x2(0)) );

  bm_00: entity work.fuq_mul_bthrow(fuq_mul_bthrow)    port map (
      s_neg   => s_neg(0) ,  
      s_x     => s_x(0) ,  
      s_x2    => s_x2(0) ,  
      x       => c_frac(0 to 53) ,  
      q       => pp0_00(4 to 58) ,  
      hot_one => hot_one_din);  


  pp0_01(4) <= tiup;
  pp0_01(5) <= xtd_2_add(1);

  sx_01_2: xtd_2_add(1) <= not(s_neg(1) and (s_x(1) or s_x2(1)) );

  bm_01: entity work.fuq_mul_bthrow(fuq_mul_bthrow)    port map (
      s_neg   => s_neg(1) ,  
      s_x     => s_x(1) ,  
      s_x2    => s_x2(1) ,  
      x       => c_frac(0 to 53) ,  
      q       => pp0_01(6 to 60) ,  
      hot_one => pp0_00(60));  
  pp0_00(59) <= tidn;


  pp0_02(6) <= tiup;
  pp0_02(7) <= xtd_2_add(2);

  sx_02_2: xtd_2_add(2) <= not(s_neg(2) and (s_x(2) or s_x2(2)) );

  bm_02: entity work.fuq_mul_bthrow(fuq_mul_bthrow)    port map (
      s_neg   => s_neg(2) ,  
      s_x     => s_x(2) ,  
      s_x2    => s_x2(2) ,  
      x       => c_frac(0 to 53) ,  
      q       => pp0_02(8 to 62) ,  
      hot_one => pp0_01(62));  
  pp0_01(61) <= tidn;


  pp0_03(8) <= tiup;
  pp0_03(9) <= xtd_2_add(3);

  sx_03_2: xtd_2_add(3) <= not(s_neg(3) and (s_x(3) or s_x2(3)) );

  bm_03: entity work.fuq_mul_bthrow(fuq_mul_bthrow)    port map (
      s_neg   => s_neg(3) ,  
      s_x     => s_x(3) ,  
      s_x2    => s_x2(3) ,  
      x       => c_frac(0 to 53) ,  
      q       => pp0_03(10 to 64) ,  
      hot_one => pp0_02(64));  
  pp0_02(63) <= tidn;


  pp0_04(10) <= tiup;
  pp0_04(11) <= xtd_2_add(4);

  sx_04_2: xtd_2_add(4) <= not(s_neg(4) and (s_x(4) or s_x2(4)) );

  bm_04: entity work.fuq_mul_bthrow(fuq_mul_bthrow)    port map (
      s_neg   => s_neg(4) ,  
      s_x     => s_x(4) ,  
      s_x2    => s_x2(4) ,  
      x       => c_frac(0 to 53) ,  
      q       => pp0_04(12 to 66) ,  
      hot_one => pp0_03(66));  
  pp0_03(65) <= tidn;


  pp0_05(12) <= tiup;
  pp0_05(13) <= xtd_2_add(5);

  sx_05_2: xtd_2_add(5) <= not(s_neg(5) and (s_x(5) or s_x2(5)) );

  bm_05: entity work.fuq_mul_bthrow(fuq_mul_bthrow)    port map (
      s_neg   => s_neg(5) ,  
      s_x     => s_x(5) ,  
      s_x2    => s_x2(5) ,  
      x       => c_frac(0 to 53) ,  
      q       => pp0_05(14 to 68) ,  
      hot_one => pp0_04(68));  
  pp0_04(67) <= tidn;


  pp0_06(14) <= tiup;
  pp0_06(15) <= xtd_2_add(6);

  sx_06_2: xtd_2_add(6) <= not(s_neg(6) and (s_x(6) or s_x2(6)) );

  bm_06: entity work.fuq_mul_bthrow(fuq_mul_bthrow)    port map (
      s_neg   => s_neg(6) ,  
      s_x     => s_x(6) ,  
      s_x2    => s_x2(6) ,  
      x       => c_frac(0 to 53) ,  
      q       => pp0_06(16 to 70) ,  
      hot_one => pp0_05(70));  
  pp0_05(69) <= tidn;


  pp0_07(16) <= tiup;
  pp0_07(17) <= xtd_2_add(7);

  sx_07_2: xtd_2_add(7) <= not(s_neg(7) and (s_x(7) or s_x2(7)) );

  bm_07: entity work.fuq_mul_bthrow(fuq_mul_bthrow)    port map (
      s_neg   => s_neg(7) ,  
      s_x     => s_x(7) ,  
      s_x2    => s_x2(7) ,  
      x       => c_frac(0 to 53) ,  
      q       => pp0_07(18 to 72) ,  
      hot_one => pp0_06(72));  
  pp0_06(71) <= tidn;








 g0: if (inst = 0) generate
 begin 
              pp0_08(17) <= tidn ;                                    
              pp0_08(18) <= tiup ;                                    
     sx_08_2: pp0_08(19) <= not( s_neg(8) and ( s_x(8) or s_x2(8)) ); 
 end generate ;

 g1: if (inst = 1) generate
 begin 
              pp0_08(17) <= tidn ;                                    
              pp0_08(18) <= tiup ;                                    
     sx_08_2: pp0_08(19) <= not( s_neg(8) and ( s_x(8) or s_x2(8)) ); 
 end generate ;


 g2: if (inst = 2) generate
 begin 
     sx_08_0: pp0_08(17) <= not( s_neg(8) and ( s_x(8) or s_x2(8)) ); 
     sx_08_1: pp0_08(18) <=    ( s_neg(8) and ( s_x(8) or s_x2(8)) ); 
     sx_08_2: pp0_08(19) <=    ( s_neg(8) and ( s_x(8) or s_x2(8)) ); 
 end generate ;



  bm_08: entity work.fuq_mul_bthrow(fuq_mul_bthrow)    port map (
      s_neg   => s_neg(8) ,  
      s_x     => s_x(8) ,  
      s_x2    => s_x2(8) ,  
      x       => c_frac(0 to 53) ,  
      q       => pp0_08(20 to 74) ,  
      hot_one => pp0_07(74));  
  pp0_07(73) <= tidn;











  pp1_05(74) <= pp0_08(74);
  pp1_05(73) <= pp0_08(73);

  pp1_04(74) <= pp0_07(74);
  pp1_04(73) <= tidn;
  pp1_04(72) <= tidn;

  pp1_02_csa_72: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(72) ,  
      b   => pp0_07(72) ,  
      c   => pp0_06(72) ,  
      sum => pp1_05(72) ,  
      car => pp1_04(71));  
  pp1_02_csa_71: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp0_08(71) ,  
      b   => pp0_07(71) ,  
      sum => pp1_05(71) ,  
      car => pp1_04(70));  
  pp1_02_csa_70: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(70) ,  
      b   => pp0_07(70) ,  
      c   => pp0_06(70) ,  
      sum => pp1_05(70) ,  
      car => pp1_04(69));  
  pp1_02_csa_69: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(69) ,  
      b   => pp0_07(69) ,  
      c   => pp0_06(69) ,  
      sum => pp1_05(69) ,  
      car => pp1_04(68));  
  pp1_02_csa_68: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(68) ,  
      b   => pp0_07(68) ,  
      c   => pp0_06(68) ,  
      sum => pp1_05(68) ,  
      car => pp1_04(67));  
  pp1_02_csa_67: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(67) ,  
      b   => pp0_07(67) ,  
      c   => pp0_06(67) ,  
      sum => pp1_05(67) ,  
      car => pp1_04(66));  
  pp1_02_csa_66: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(66) ,  
      b   => pp0_07(66) ,  
      c   => pp0_06(66) ,  
      sum => pp1_05(66) ,  
      car => pp1_04(65));  
  pp1_02_csa_65: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(65) ,  
      b   => pp0_07(65) ,  
      c   => pp0_06(65) ,  
      sum => pp1_05(65) ,  
      car => pp1_04(64));  
  pp1_02_csa_64: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(64) ,  
      b   => pp0_07(64) ,  
      c   => pp0_06(64) ,  
      sum => pp1_05(64) ,  
      car => pp1_04(63));  
  pp1_02_csa_63: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(63) ,  
      b   => pp0_07(63) ,  
      c   => pp0_06(63) ,  
      sum => pp1_05(63) ,  
      car => pp1_04(62));  
  pp1_02_csa_62: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(62) ,  
      b   => pp0_07(62) ,  
      c   => pp0_06(62) ,  
      sum => pp1_05(62) ,  
      car => pp1_04(61));  
  pp1_02_csa_61: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(61) ,  
      b   => pp0_07(61) ,  
      c   => pp0_06(61) ,  
      sum => pp1_05(61) ,  
      car => pp1_04(60));  
  pp1_02_csa_60: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(60) ,  
      b   => pp0_07(60) ,  
      c   => pp0_06(60) ,  
      sum => pp1_05(60) ,  
      car => pp1_04(59));  
  pp1_02_csa_59: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(59) ,  
      b   => pp0_07(59) ,  
      c   => pp0_06(59) ,  
      sum => pp1_05(59) ,  
      car => pp1_04(58));  
  pp1_02_csa_58: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(58) ,  
      b   => pp0_07(58) ,  
      c   => pp0_06(58) ,  
      sum => pp1_05(58) ,  
      car => pp1_04(57));  
  pp1_02_csa_57: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(57) ,  
      b   => pp0_07(57) ,  
      c   => pp0_06(57) ,  
      sum => pp1_05(57) ,  
      car => pp1_04(56));  
  pp1_02_csa_56: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(56) ,  
      b   => pp0_07(56) ,  
      c   => pp0_06(56) ,  
      sum => pp1_05(56) ,  
      car => pp1_04(55));  
  pp1_02_csa_55: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(55) ,  
      b   => pp0_07(55) ,  
      c   => pp0_06(55) ,  
      sum => pp1_05(55) ,  
      car => pp1_04(54));  
  pp1_02_csa_54: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(54) ,  
      b   => pp0_07(54) ,  
      c   => pp0_06(54) ,  
      sum => pp1_05(54) ,  
      car => pp1_04(53));  
  pp1_02_csa_53: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(53) ,  
      b   => pp0_07(53) ,  
      c   => pp0_06(53) ,  
      sum => pp1_05(53) ,  
      car => pp1_04(52));  
  pp1_02_csa_52: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(52) ,  
      b   => pp0_07(52) ,  
      c   => pp0_06(52) ,  
      sum => pp1_05(52) ,  
      car => pp1_04(51));  
  pp1_02_csa_51: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(51) ,  
      b   => pp0_07(51) ,  
      c   => pp0_06(51) ,  
      sum => pp1_05(51) ,  
      car => pp1_04(50));  
  pp1_02_csa_50: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(50) ,  
      b   => pp0_07(50) ,  
      c   => pp0_06(50) ,  
      sum => pp1_05(50) ,  
      car => pp1_04(49));  
  pp1_02_csa_49: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(49) ,  
      b   => pp0_07(49) ,  
      c   => pp0_06(49) ,  
      sum => pp1_05(49) ,  
      car => pp1_04(48));  
  pp1_02_csa_48: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(48) ,  
      b   => pp0_07(48) ,  
      c   => pp0_06(48) ,  
      sum => pp1_05(48) ,  
      car => pp1_04(47));  
  pp1_02_csa_47: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(47) ,  
      b   => pp0_07(47) ,  
      c   => pp0_06(47) ,  
      sum => pp1_05(47) ,  
      car => pp1_04(46));  
  pp1_02_csa_46: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(46) ,  
      b   => pp0_07(46) ,  
      c   => pp0_06(46) ,  
      sum => pp1_05(46) ,  
      car => pp1_04(45));  
  pp1_02_csa_45: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(45) ,  
      b   => pp0_07(45) ,  
      c   => pp0_06(45) ,  
      sum => pp1_05(45) ,  
      car => pp1_04(44));  
  pp1_02_csa_44: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(44) ,  
      b   => pp0_07(44) ,  
      c   => pp0_06(44) ,  
      sum => pp1_05(44) ,  
      car => pp1_04(43));  
  pp1_02_csa_43: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(43) ,  
      b   => pp0_07(43) ,  
      c   => pp0_06(43) ,  
      sum => pp1_05(43) ,  
      car => pp1_04(42));  
  pp1_02_csa_42: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(42) ,  
      b   => pp0_07(42) ,  
      c   => pp0_06(42) ,  
      sum => pp1_05(42) ,  
      car => pp1_04(41));  
  pp1_02_csa_41: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(41) ,  
      b   => pp0_07(41) ,  
      c   => pp0_06(41) ,  
      sum => pp1_05(41) ,  
      car => pp1_04(40));  
  pp1_02_csa_40: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(40) ,  
      b   => pp0_07(40) ,  
      c   => pp0_06(40) ,  
      sum => pp1_05(40) ,  
      car => pp1_04(39));  
  pp1_02_csa_39: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(39) ,  
      b   => pp0_07(39) ,  
      c   => pp0_06(39) ,  
      sum => pp1_05(39) ,  
      car => pp1_04(38));  
  pp1_02_csa_38: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(38) ,  
      b   => pp0_07(38) ,  
      c   => pp0_06(38) ,  
      sum => pp1_05(38) ,  
      car => pp1_04(37));  
  pp1_02_csa_37: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(37) ,  
      b   => pp0_07(37) ,  
      c   => pp0_06(37) ,  
      sum => pp1_05(37) ,  
      car => pp1_04(36));  
  pp1_02_csa_36: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(36) ,  
      b   => pp0_07(36) ,  
      c   => pp0_06(36) ,  
      sum => pp1_05(36) ,  
      car => pp1_04(35));  
  pp1_02_csa_35: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(35) ,  
      b   => pp0_07(35) ,  
      c   => pp0_06(35) ,  
      sum => pp1_05(35) ,  
      car => pp1_04(34));  
  pp1_02_csa_34: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(34) ,  
      b   => pp0_07(34) ,  
      c   => pp0_06(34) ,  
      sum => pp1_05(34) ,  
      car => pp1_04(33));  
  pp1_02_csa_33: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(33) ,  
      b   => pp0_07(33) ,  
      c   => pp0_06(33) ,  
      sum => pp1_05(33) ,  
      car => pp1_04(32));  
  pp1_02_csa_32: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(32) ,  
      b   => pp0_07(32) ,  
      c   => pp0_06(32) ,  
      sum => pp1_05(32) ,  
      car => pp1_04(31));  
  pp1_02_csa_31: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(31) ,  
      b   => pp0_07(31) ,  
      c   => pp0_06(31) ,  
      sum => pp1_05(31) ,  
      car => pp1_04(30));  
  pp1_02_csa_30: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(30) ,  
      b   => pp0_07(30) ,  
      c   => pp0_06(30) ,  
      sum => pp1_05(30) ,  
      car => pp1_04(29));  
  pp1_02_csa_29: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(29) ,  
      b   => pp0_07(29) ,  
      c   => pp0_06(29) ,  
      sum => pp1_05(29) ,  
      car => pp1_04(28));  
  pp1_02_csa_28: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(28) ,  
      b   => pp0_07(28) ,  
      c   => pp0_06(28) ,  
      sum => pp1_05(28) ,  
      car => pp1_04(27));  
  pp1_02_csa_27: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(27) ,  
      b   => pp0_07(27) ,  
      c   => pp0_06(27) ,  
      sum => pp1_05(27) ,  
      car => pp1_04(26));  
  pp1_02_csa_26: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(26) ,  
      b   => pp0_07(26) ,  
      c   => pp0_06(26) ,  
      sum => pp1_05(26) ,  
      car => pp1_04(25));  
  pp1_02_csa_25: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(25) ,  
      b   => pp0_07(25) ,  
      c   => pp0_06(25) ,  
      sum => pp1_05(25) ,  
      car => pp1_04(24));  
  pp1_02_csa_24: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(24) ,  
      b   => pp0_07(24) ,  
      c   => pp0_06(24) ,  
      sum => pp1_05(24) ,  
      car => pp1_04(23));  
  pp1_02_csa_23: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(23) ,  
      b   => pp0_07(23) ,  
      c   => pp0_06(23) ,  
      sum => pp1_05(23) ,  
      car => pp1_04(22));  
  pp1_02_csa_22: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(22) ,  
      b   => pp0_07(22) ,  
      c   => pp0_06(22) ,  
      sum => pp1_05(22) ,  
      car => pp1_04(21));  
  pp1_02_csa_21: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(21) ,  
      b   => pp0_07(21) ,  
      c   => pp0_06(21) ,  
      sum => pp1_05(21) ,  
      car => pp1_04(20));  
  pp1_02_csa_20: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(20) ,  
      b   => pp0_07(20) ,  
      c   => pp0_06(20) ,  
      sum => pp1_05(20) ,  
      car => pp1_04(19));  
  pp1_02_csa_19: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(19) ,  
      b   => pp0_07(19) ,  
      c   => pp0_06(19) ,  
      sum => pp1_05(19) ,  
      car => pp1_04(18));  
  pp1_02_csa_18: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(18) ,  
      b   => pp0_07(18) ,  
      c   => pp0_06(18) ,  
      sum => pp1_05(18) ,  
      car => pp1_04(17));  
  pp1_02_csa_17: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_08(17) ,  
      b   => pp0_07(17) ,  
      c   => pp0_06(17) ,  
      sum => pp1_05(17) ,  
      car => pp1_04(16));  
  pp1_02_csa_16: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => tiup ,  
      b   => pp0_06(16) ,  
      sum => pp1_05(16) ,  
      car => pp1_04(15));  
  pp1_05(15) <= pp0_06(15);
  pp1_05(14) <= tiup;


  pp1_03(70) <= pp0_05(70);
  pp1_03(69) <= tidn;
  pp1_03(68) <= pp0_05(68);
  pp1_03(67) <= pp0_05(67);

  pp1_02(68) <= pp0_04(68);
  pp1_02(67) <= tidn;
  pp1_02(66) <= tidn;

  pp1_01_csa_66: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(66) ,  
      b   => pp0_04(66) ,  
      c   => pp0_03(66) ,  
      sum => pp1_03(66) ,  
      car => pp1_02(65));  
  pp1_01_csa_65: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp0_05(65) ,  
      b   => pp0_04(65) ,  
      sum => pp1_03(65) ,  
      car => pp1_02(64));  
  pp1_01_csa_64: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(64) ,  
      b   => pp0_04(64) ,  
      c   => pp0_03(64) ,  
      sum => pp1_03(64) ,  
      car => pp1_02(63));  
  pp1_01_csa_63: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(63) ,  
      b   => pp0_04(63) ,  
      c   => pp0_03(63) ,  
      sum => pp1_03(63) ,  
      car => pp1_02(62));  
  pp1_01_csa_62: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(62) ,  
      b   => pp0_04(62) ,  
      c   => pp0_03(62) ,  
      sum => pp1_03(62) ,  
      car => pp1_02(61));  
  pp1_01_csa_61: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(61) ,  
      b   => pp0_04(61) ,  
      c   => pp0_03(61) ,  
      sum => pp1_03(61) ,  
      car => pp1_02(60));  
  pp1_01_csa_60: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(60) ,  
      b   => pp0_04(60) ,  
      c   => pp0_03(60) ,  
      sum => pp1_03(60) ,  
      car => pp1_02(59));  
  pp1_01_csa_59: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(59) ,  
      b   => pp0_04(59) ,  
      c   => pp0_03(59) ,  
      sum => pp1_03(59) ,  
      car => pp1_02(58));  
  pp1_01_csa_58: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(58) ,  
      b   => pp0_04(58) ,  
      c   => pp0_03(58) ,  
      sum => pp1_03(58) ,  
      car => pp1_02(57));  
  pp1_01_csa_57: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(57) ,  
      b   => pp0_04(57) ,  
      c   => pp0_03(57) ,  
      sum => pp1_03(57) ,  
      car => pp1_02(56));  
  pp1_01_csa_56: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(56) ,  
      b   => pp0_04(56) ,  
      c   => pp0_03(56) ,  
      sum => pp1_03(56) ,  
      car => pp1_02(55));  
  pp1_01_csa_55: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(55) ,  
      b   => pp0_04(55) ,  
      c   => pp0_03(55) ,  
      sum => pp1_03(55) ,  
      car => pp1_02(54));  
  pp1_01_csa_54: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(54) ,  
      b   => pp0_04(54) ,  
      c   => pp0_03(54) ,  
      sum => pp1_03(54) ,  
      car => pp1_02(53));  
  pp1_01_csa_53: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(53) ,  
      b   => pp0_04(53) ,  
      c   => pp0_03(53) ,  
      sum => pp1_03(53) ,  
      car => pp1_02(52));  
  pp1_01_csa_52: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(52) ,  
      b   => pp0_04(52) ,  
      c   => pp0_03(52) ,  
      sum => pp1_03(52) ,  
      car => pp1_02(51));  
  pp1_01_csa_51: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(51) ,  
      b   => pp0_04(51) ,  
      c   => pp0_03(51) ,  
      sum => pp1_03(51) ,  
      car => pp1_02(50));  
  pp1_01_csa_50: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(50) ,  
      b   => pp0_04(50) ,  
      c   => pp0_03(50) ,  
      sum => pp1_03(50) ,  
      car => pp1_02(49));  
  pp1_01_csa_49: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(49) ,  
      b   => pp0_04(49) ,  
      c   => pp0_03(49) ,  
      sum => pp1_03(49) ,  
      car => pp1_02(48));  
  pp1_01_csa_48: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(48) ,  
      b   => pp0_04(48) ,  
      c   => pp0_03(48) ,  
      sum => pp1_03(48) ,  
      car => pp1_02(47));  
  pp1_01_csa_47: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(47) ,  
      b   => pp0_04(47) ,  
      c   => pp0_03(47) ,  
      sum => pp1_03(47) ,  
      car => pp1_02(46));  
  pp1_01_csa_46: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(46) ,  
      b   => pp0_04(46) ,  
      c   => pp0_03(46) ,  
      sum => pp1_03(46) ,  
      car => pp1_02(45));  
  pp1_01_csa_45: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(45) ,  
      b   => pp0_04(45) ,  
      c   => pp0_03(45) ,  
      sum => pp1_03(45) ,  
      car => pp1_02(44));  
  pp1_01_csa_44: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(44) ,  
      b   => pp0_04(44) ,  
      c   => pp0_03(44) ,  
      sum => pp1_03(44) ,  
      car => pp1_02(43));  
  pp1_01_csa_43: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(43) ,  
      b   => pp0_04(43) ,  
      c   => pp0_03(43) ,  
      sum => pp1_03(43) ,  
      car => pp1_02(42));  
  pp1_01_csa_42: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(42) ,  
      b   => pp0_04(42) ,  
      c   => pp0_03(42) ,  
      sum => pp1_03(42) ,  
      car => pp1_02(41));  
  pp1_01_csa_41: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(41) ,  
      b   => pp0_04(41) ,  
      c   => pp0_03(41) ,  
      sum => pp1_03(41) ,  
      car => pp1_02(40));  
  pp1_01_csa_40: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(40) ,  
      b   => pp0_04(40) ,  
      c   => pp0_03(40) ,  
      sum => pp1_03(40) ,  
      car => pp1_02(39));  
  pp1_01_csa_39: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(39) ,  
      b   => pp0_04(39) ,  
      c   => pp0_03(39) ,  
      sum => pp1_03(39) ,  
      car => pp1_02(38));  
  pp1_01_csa_38: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(38) ,  
      b   => pp0_04(38) ,  
      c   => pp0_03(38) ,  
      sum => pp1_03(38) ,  
      car => pp1_02(37));  
  pp1_01_csa_37: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(37) ,  
      b   => pp0_04(37) ,  
      c   => pp0_03(37) ,  
      sum => pp1_03(37) ,  
      car => pp1_02(36));  
  pp1_01_csa_36: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(36) ,  
      b   => pp0_04(36) ,  
      c   => pp0_03(36) ,  
      sum => pp1_03(36) ,  
      car => pp1_02(35));  
  pp1_01_csa_35: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(35) ,  
      b   => pp0_04(35) ,  
      c   => pp0_03(35) ,  
      sum => pp1_03(35) ,  
      car => pp1_02(34));  
  pp1_01_csa_34: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(34) ,  
      b   => pp0_04(34) ,  
      c   => pp0_03(34) ,  
      sum => pp1_03(34) ,  
      car => pp1_02(33));  
  pp1_01_csa_33: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(33) ,  
      b   => pp0_04(33) ,  
      c   => pp0_03(33) ,  
      sum => pp1_03(33) ,  
      car => pp1_02(32));  
  pp1_01_csa_32: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(32) ,  
      b   => pp0_04(32) ,  
      c   => pp0_03(32) ,  
      sum => pp1_03(32) ,  
      car => pp1_02(31));  
  pp1_01_csa_31: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(31) ,  
      b   => pp0_04(31) ,  
      c   => pp0_03(31) ,  
      sum => pp1_03(31) ,  
      car => pp1_02(30));  
  pp1_01_csa_30: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(30) ,  
      b   => pp0_04(30) ,  
      c   => pp0_03(30) ,  
      sum => pp1_03(30) ,  
      car => pp1_02(29));  
  pp1_01_csa_29: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(29) ,  
      b   => pp0_04(29) ,  
      c   => pp0_03(29) ,  
      sum => pp1_03(29) ,  
      car => pp1_02(28));  
  pp1_01_csa_28: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(28) ,  
      b   => pp0_04(28) ,  
      c   => pp0_03(28) ,  
      sum => pp1_03(28) ,  
      car => pp1_02(27));  
  pp1_01_csa_27: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(27) ,  
      b   => pp0_04(27) ,  
      c   => pp0_03(27) ,  
      sum => pp1_03(27) ,  
      car => pp1_02(26));  
  pp1_01_csa_26: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(26) ,  
      b   => pp0_04(26) ,  
      c   => pp0_03(26) ,  
      sum => pp1_03(26) ,  
      car => pp1_02(25));  
  pp1_01_csa_25: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(25) ,  
      b   => pp0_04(25) ,  
      c   => pp0_03(25) ,  
      sum => pp1_03(25) ,  
      car => pp1_02(24));  
  pp1_01_csa_24: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(24) ,  
      b   => pp0_04(24) ,  
      c   => pp0_03(24) ,  
      sum => pp1_03(24) ,  
      car => pp1_02(23));  
  pp1_01_csa_23: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(23) ,  
      b   => pp0_04(23) ,  
      c   => pp0_03(23) ,  
      sum => pp1_03(23) ,  
      car => pp1_02(22));  
  pp1_01_csa_22: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(22) ,  
      b   => pp0_04(22) ,  
      c   => pp0_03(22) ,  
      sum => pp1_03(22) ,  
      car => pp1_02(21));  
  pp1_01_csa_21: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(21) ,  
      b   => pp0_04(21) ,  
      c   => pp0_03(21) ,  
      sum => pp1_03(21) ,  
      car => pp1_02(20));  
  pp1_01_csa_20: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(20) ,  
      b   => pp0_04(20) ,  
      c   => pp0_03(20) ,  
      sum => pp1_03(20) ,  
      car => pp1_02(19));  
  pp1_01_csa_19: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(19) ,  
      b   => pp0_04(19) ,  
      c   => pp0_03(19) ,  
      sum => pp1_03(19) ,  
      car => pp1_02(18));  
  pp1_01_csa_18: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(18) ,  
      b   => pp0_04(18) ,  
      c   => pp0_03(18) ,  
      sum => pp1_03(18) ,  
      car => pp1_02(17));  
  pp1_01_csa_17: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(17) ,  
      b   => pp0_04(17) ,  
      c   => pp0_03(17) ,  
      sum => pp1_03(17) ,  
      car => pp1_02(16));  
  pp1_01_csa_16: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(16) ,  
      b   => pp0_04(16) ,  
      c   => pp0_03(16) ,  
      sum => pp1_03(16) ,  
      car => pp1_02(15));  
  pp1_01_csa_15: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(15) ,  
      b   => pp0_04(15) ,  
      c   => pp0_03(15) ,  
      sum => pp1_03(15) ,  
      car => pp1_02(14));  
  pp1_01_csa_14: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(14) ,  
      b   => pp0_04(14) ,  
      c   => pp0_03(14) ,  
      sum => pp1_03(14) ,  
      car => pp1_02(13));  
  pp1_01_csa_13: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_05(13) ,  
      b   => pp0_04(13) ,  
      c   => pp0_03(13) ,  
      sum => pp1_03(13) ,  
      car => pp1_02(12));  
  pp1_01_csa_12: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => tiup ,  
      b   => pp0_04(12) ,  
      c   => pp0_03(12) ,  
      sum => pp1_03(12) ,  
      car => pp1_02(11));  
  pp1_01_csa_11: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp0_04(11) ,  
      b   => pp0_03(11) ,  
      sum => pp1_03(11) ,  
      car => pp1_02(10));  
  pp1_01_csa_10: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => tiup ,  
      b   => pp0_03(10) ,  
      sum => pp1_03(10) ,  
      car => pp1_02(9));  
  pp1_03(9) <= pp0_03(9);
  pp1_03(8) <= tiup;




  pp1_01(64) <= pp0_02(64);
  pp1_01(63) <= tidn;
  pp1_01(62) <= pp0_02(62);
  pp1_01(61) <= pp0_02(61);

  pp1_00(62) <= pp0_01(62);
  pp1_00(61) <= tidn;
  pp1_00(60) <= tidn;

  pp1_00_csa_60: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(60) ,  
      b   => pp0_01(60) ,  
      c   => pp0_00(60) ,  
      sum => pp1_01(60) ,  
      car => pp1_00(59));  
  pp1_00_csa_59: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp0_02(59) ,  
      b   => pp0_01(59) ,  
      sum => pp1_01(59) ,  
      car => pp1_00(58));  
  pp1_00_csa_58: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(58) ,  
      b   => pp0_01(58) ,  
      c   => pp0_00(58) ,  
      sum => pp1_01(58) ,  
      car => pp1_00(57));  
  pp1_00_csa_57: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(57) ,  
      b   => pp0_01(57) ,  
      c   => pp0_00(57) ,  
      sum => pp1_01(57) ,  
      car => pp1_00(56));  
  pp1_00_csa_56: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(56) ,  
      b   => pp0_01(56) ,  
      c   => pp0_00(56) ,  
      sum => pp1_01(56) ,  
      car => pp1_00(55));  
  pp1_00_csa_55: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(55) ,  
      b   => pp0_01(55) ,  
      c   => pp0_00(55) ,  
      sum => pp1_01(55) ,  
      car => pp1_00(54));  
  pp1_00_csa_54: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(54) ,  
      b   => pp0_01(54) ,  
      c   => pp0_00(54) ,  
      sum => pp1_01(54) ,  
      car => pp1_00(53));  
  pp1_00_csa_53: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(53) ,  
      b   => pp0_01(53) ,  
      c   => pp0_00(53) ,  
      sum => pp1_01(53) ,  
      car => pp1_00(52));  
  pp1_00_csa_52: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(52) ,  
      b   => pp0_01(52) ,  
      c   => pp0_00(52) ,  
      sum => pp1_01(52) ,  
      car => pp1_00(51));  
  pp1_00_csa_51: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(51) ,  
      b   => pp0_01(51) ,  
      c   => pp0_00(51) ,  
      sum => pp1_01(51) ,  
      car => pp1_00(50));  
  pp1_00_csa_50: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(50) ,  
      b   => pp0_01(50) ,  
      c   => pp0_00(50) ,  
      sum => pp1_01(50) ,  
      car => pp1_00(49));  
  pp1_00_csa_49: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(49) ,  
      b   => pp0_01(49) ,  
      c   => pp0_00(49) ,  
      sum => pp1_01(49) ,  
      car => pp1_00(48));  
  pp1_00_csa_48: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(48) ,  
      b   => pp0_01(48) ,  
      c   => pp0_00(48) ,  
      sum => pp1_01(48) ,  
      car => pp1_00(47));  
  pp1_00_csa_47: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(47) ,  
      b   => pp0_01(47) ,  
      c   => pp0_00(47) ,  
      sum => pp1_01(47) ,  
      car => pp1_00(46));  
  pp1_00_csa_46: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(46) ,  
      b   => pp0_01(46) ,  
      c   => pp0_00(46) ,  
      sum => pp1_01(46) ,  
      car => pp1_00(45));  
  pp1_00_csa_45: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(45) ,  
      b   => pp0_01(45) ,  
      c   => pp0_00(45) ,  
      sum => pp1_01(45) ,  
      car => pp1_00(44));  
  pp1_00_csa_44: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(44) ,  
      b   => pp0_01(44) ,  
      c   => pp0_00(44) ,  
      sum => pp1_01(44) ,  
      car => pp1_00(43));  
  pp1_00_csa_43: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(43) ,  
      b   => pp0_01(43) ,  
      c   => pp0_00(43) ,  
      sum => pp1_01(43) ,  
      car => pp1_00(42));  
  pp1_00_csa_42: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(42) ,  
      b   => pp0_01(42) ,  
      c   => pp0_00(42) ,  
      sum => pp1_01(42) ,  
      car => pp1_00(41));  
  pp1_00_csa_41: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(41) ,  
      b   => pp0_01(41) ,  
      c   => pp0_00(41) ,  
      sum => pp1_01(41) ,  
      car => pp1_00(40));  
  pp1_00_csa_40: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(40) ,  
      b   => pp0_01(40) ,  
      c   => pp0_00(40) ,  
      sum => pp1_01(40) ,  
      car => pp1_00(39));  
  pp1_00_csa_39: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(39) ,  
      b   => pp0_01(39) ,  
      c   => pp0_00(39) ,  
      sum => pp1_01(39) ,  
      car => pp1_00(38));  
  pp1_00_csa_38: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(38) ,  
      b   => pp0_01(38) ,  
      c   => pp0_00(38) ,  
      sum => pp1_01(38) ,  
      car => pp1_00(37));  
  pp1_00_csa_37: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(37) ,  
      b   => pp0_01(37) ,  
      c   => pp0_00(37) ,  
      sum => pp1_01(37) ,  
      car => pp1_00(36));  
  pp1_00_csa_36: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(36) ,  
      b   => pp0_01(36) ,  
      c   => pp0_00(36) ,  
      sum => pp1_01(36) ,  
      car => pp1_00(35));  
  pp1_00_csa_35: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(35) ,  
      b   => pp0_01(35) ,  
      c   => pp0_00(35) ,  
      sum => pp1_01(35) ,  
      car => pp1_00(34));  
  pp1_00_csa_34: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(34) ,  
      b   => pp0_01(34) ,  
      c   => pp0_00(34) ,  
      sum => pp1_01(34) ,  
      car => pp1_00(33));  
  pp1_00_csa_33: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(33) ,  
      b   => pp0_01(33) ,  
      c   => pp0_00(33) ,  
      sum => pp1_01(33) ,  
      car => pp1_00(32));  
  pp1_00_csa_32: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(32) ,  
      b   => pp0_01(32) ,  
      c   => pp0_00(32) ,  
      sum => pp1_01(32) ,  
      car => pp1_00(31));  
  pp1_00_csa_31: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(31) ,  
      b   => pp0_01(31) ,  
      c   => pp0_00(31) ,  
      sum => pp1_01(31) ,  
      car => pp1_00(30));  
  pp1_00_csa_30: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(30) ,  
      b   => pp0_01(30) ,  
      c   => pp0_00(30) ,  
      sum => pp1_01(30) ,  
      car => pp1_00(29));  
  pp1_00_csa_29: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(29) ,  
      b   => pp0_01(29) ,  
      c   => pp0_00(29) ,  
      sum => pp1_01(29) ,  
      car => pp1_00(28));  
  pp1_00_csa_28: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(28) ,  
      b   => pp0_01(28) ,  
      c   => pp0_00(28) ,  
      sum => pp1_01(28) ,  
      car => pp1_00(27));  
  pp1_00_csa_27: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(27) ,  
      b   => pp0_01(27) ,  
      c   => pp0_00(27) ,  
      sum => pp1_01(27) ,  
      car => pp1_00(26));  
  pp1_00_csa_26: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(26) ,  
      b   => pp0_01(26) ,  
      c   => pp0_00(26) ,  
      sum => pp1_01(26) ,  
      car => pp1_00(25));  
  pp1_00_csa_25: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(25) ,  
      b   => pp0_01(25) ,  
      c   => pp0_00(25) ,  
      sum => pp1_01(25) ,  
      car => pp1_00(24));  
  pp1_00_csa_24: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(24) ,  
      b   => pp0_01(24) ,  
      c   => pp0_00(24) ,  
      sum => pp1_01(24) ,  
      car => pp1_00(23));  
  pp1_00_csa_23: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(23) ,  
      b   => pp0_01(23) ,  
      c   => pp0_00(23) ,  
      sum => pp1_01(23) ,  
      car => pp1_00(22));  
  pp1_00_csa_22: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(22) ,  
      b   => pp0_01(22) ,  
      c   => pp0_00(22) ,  
      sum => pp1_01(22) ,  
      car => pp1_00(21));  
  pp1_00_csa_21: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(21) ,  
      b   => pp0_01(21) ,  
      c   => pp0_00(21) ,  
      sum => pp1_01(21) ,  
      car => pp1_00(20));  
  pp1_00_csa_20: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(20) ,  
      b   => pp0_01(20) ,  
      c   => pp0_00(20) ,  
      sum => pp1_01(20) ,  
      car => pp1_00(19));  
  pp1_00_csa_19: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(19) ,  
      b   => pp0_01(19) ,  
      c   => pp0_00(19) ,  
      sum => pp1_01(19) ,  
      car => pp1_00(18));  
  pp1_00_csa_18: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(18) ,  
      b   => pp0_01(18) ,  
      c   => pp0_00(18) ,  
      sum => pp1_01(18) ,  
      car => pp1_00(17));  
  pp1_00_csa_17: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(17) ,  
      b   => pp0_01(17) ,  
      c   => pp0_00(17) ,  
      sum => pp1_01(17) ,  
      car => pp1_00(16));  
  pp1_00_csa_16: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(16) ,  
      b   => pp0_01(16) ,  
      c   => pp0_00(16) ,  
      sum => pp1_01(16) ,  
      car => pp1_00(15));  
  pp1_00_csa_15: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(15) ,  
      b   => pp0_01(15) ,  
      c   => pp0_00(15) ,  
      sum => pp1_01(15) ,  
      car => pp1_00(14));  
  pp1_00_csa_14: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(14) ,  
      b   => pp0_01(14) ,  
      c   => pp0_00(14) ,  
      sum => pp1_01(14) ,  
      car => pp1_00(13));  
  pp1_00_csa_13: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(13) ,  
      b   => pp0_01(13) ,  
      c   => pp0_00(13) ,  
      sum => pp1_01(13) ,  
      car => pp1_00(12));  
  pp1_00_csa_12: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(12) ,  
      b   => pp0_01(12) ,  
      c   => pp0_00(12) ,  
      sum => pp1_01(12) ,  
      car => pp1_00(11));  
  pp1_00_csa_11: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(11) ,  
      b   => pp0_01(11) ,  
      c   => pp0_00(11) ,  
      sum => pp1_01(11) ,  
      car => pp1_00(10));  
  pp1_00_csa_10: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(10) ,  
      b   => pp0_01(10) ,  
      c   => pp0_00(10) ,  
      sum => pp1_01(10) ,  
      car => pp1_00(9));  
  pp1_00_csa_09: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(9) ,  
      b   => pp0_01(9) ,  
      c   => pp0_00(9) ,  
      sum => pp1_01(9) ,  
      car => pp1_00(8));  
  pp1_00_csa_08: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(8) ,  
      b   => pp0_01(8) ,  
      c   => pp0_00(8) ,  
      sum => pp1_01(8) ,  
      car => pp1_00(7));  
  pp1_00_csa_07: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp0_02(7) ,  
      b   => pp0_01(7) ,  
      c   => pp0_00(7) ,  
      sum => pp1_01(7) ,  
      car => pp1_00(6));  
  pp1_00_csa_06: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => tiup ,  
      b   => pp0_01(6) ,  
      c   => pp0_00(6) ,  
      sum => pp1_01(6) ,  
      car => pp1_00(5));  
  pp1_00_csa_05: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp0_01(5) ,  
      b   => pp0_00(5) ,  
      sum => pp1_01(5) ,  
      car => pp1_00(4));  
  pp1_00_csa_04: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => tiup ,  
      b   => pp0_00(4) ,  
      sum => pp1_01(4) ,  
      car => pp1_00(3));  

 gg0: if (inst = 0) generate
     pp1_01(3) <= tidn  ; 
     pp1_01(2) <= tidn  ; 
 end generate ;

 gg1: if (inst = 1) generate
     pp1_01(3) <= pp0_00(3) ; 
     pp1_01(2) <= pp0_00(2) ; 
 end generate ;

 gg2: if (inst = 2) generate
     pp1_01(3) <= pp0_00(3) ; 
     pp1_01(2) <= pp0_00(2) ; 
 end generate ;






  pp2_03(74) <= pp1_05(74);
  pp2_03(73) <= pp1_05(73);
  pp2_03(72) <= pp1_05(72);
  pp2_03(71) <= pp1_05(71);

  pp2_02(74) <= pp1_04(74);
  pp2_02(73) <= tidn;
  pp2_02(72) <= tidn;
  pp2_02(71) <= pp1_04(71);
  pp2_02(70) <= tidn;

  pp2_01_csa_70: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(70) ,  
      b   => pp1_04(70) ,  
      c   => pp1_03(70) ,  
      sum => pp2_03(70) ,  
      car => pp2_02(69));  
  pp2_01_csa_69: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp1_05(69) ,  
      b   => pp1_04(69) ,  
      sum => pp2_03(69) ,  
      car => pp2_02(68));  
  pp2_01_csa_68: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(68) ,  
      b   => pp1_04(68) ,  
      c   => pp1_03(68) ,  
      sum => pp2_03(68) ,  
      car => pp2_02(67));  
  pp2_01_csa_67: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(67) ,  
      b   => pp1_04(67) ,  
      c   => pp1_03(67) ,  
      sum => pp2_03(67) ,  
      car => pp2_02(66));  
  pp2_01_csa_66: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(66) ,  
      b   => pp1_04(66) ,  
      c   => pp1_03(66) ,  
      sum => pp2_03(66) ,  
      car => pp2_02(65));  
  pp2_01_csa_65: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(65) ,  
      b   => pp1_04(65) ,  
      c   => pp1_03(65) ,  
      sum => pp2_03(65) ,  
      car => pp2_02(64));  
  pp2_01_csa_64: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(64) ,  
      b   => pp1_04(64) ,  
      c   => pp1_03(64) ,  
      sum => pp2_03(64) ,  
      car => pp2_02(63));  
  pp2_01_csa_63: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(63) ,  
      b   => pp1_04(63) ,  
      c   => pp1_03(63) ,  
      sum => pp2_03(63) ,  
      car => pp2_02(62));  
  pp2_01_csa_62: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(62) ,  
      b   => pp1_04(62) ,  
      c   => pp1_03(62) ,  
      sum => pp2_03(62) ,  
      car => pp2_02(61));  
  pp2_01_csa_61: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(61) ,  
      b   => pp1_04(61) ,  
      c   => pp1_03(61) ,  
      sum => pp2_03(61) ,  
      car => pp2_02(60));  
  pp2_01_csa_60: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(60) ,  
      b   => pp1_04(60) ,  
      c   => pp1_03(60) ,  
      sum => pp2_03(60) ,  
      car => pp2_02(59));  
  pp2_01_csa_59: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(59) ,  
      b   => pp1_04(59) ,  
      c   => pp1_03(59) ,  
      sum => pp2_03(59) ,  
      car => pp2_02(58));  
  pp2_01_csa_58: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(58) ,  
      b   => pp1_04(58) ,  
      c   => pp1_03(58) ,  
      sum => pp2_03(58) ,  
      car => pp2_02(57));  
  pp2_01_csa_57: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(57) ,  
      b   => pp1_04(57) ,  
      c   => pp1_03(57) ,  
      sum => pp2_03(57) ,  
      car => pp2_02(56));  
  pp2_01_csa_56: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(56) ,  
      b   => pp1_04(56) ,  
      c   => pp1_03(56) ,  
      sum => pp2_03(56) ,  
      car => pp2_02(55));  
  pp2_01_csa_55: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(55) ,  
      b   => pp1_04(55) ,  
      c   => pp1_03(55) ,  
      sum => pp2_03(55) ,  
      car => pp2_02(54));  
  pp2_01_csa_54: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(54) ,  
      b   => pp1_04(54) ,  
      c   => pp1_03(54) ,  
      sum => pp2_03(54) ,  
      car => pp2_02(53));  
  pp2_01_csa_53: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(53) ,  
      b   => pp1_04(53) ,  
      c   => pp1_03(53) ,  
      sum => pp2_03(53) ,  
      car => pp2_02(52));  
  pp2_01_csa_52: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(52) ,  
      b   => pp1_04(52) ,  
      c   => pp1_03(52) ,  
      sum => pp2_03(52) ,  
      car => pp2_02(51));  
  pp2_01_csa_51: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(51) ,  
      b   => pp1_04(51) ,  
      c   => pp1_03(51) ,  
      sum => pp2_03(51) ,  
      car => pp2_02(50));  
  pp2_01_csa_50: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(50) ,  
      b   => pp1_04(50) ,  
      c   => pp1_03(50) ,  
      sum => pp2_03(50) ,  
      car => pp2_02(49));  
  pp2_01_csa_49: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(49) ,  
      b   => pp1_04(49) ,  
      c   => pp1_03(49) ,  
      sum => pp2_03(49) ,  
      car => pp2_02(48));  
  pp2_01_csa_48: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(48) ,  
      b   => pp1_04(48) ,  
      c   => pp1_03(48) ,  
      sum => pp2_03(48) ,  
      car => pp2_02(47));  
  pp2_01_csa_47: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(47) ,  
      b   => pp1_04(47) ,  
      c   => pp1_03(47) ,  
      sum => pp2_03(47) ,  
      car => pp2_02(46));  
  pp2_01_csa_46: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(46) ,  
      b   => pp1_04(46) ,  
      c   => pp1_03(46) ,  
      sum => pp2_03(46) ,  
      car => pp2_02(45));  
  pp2_01_csa_45: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(45) ,  
      b   => pp1_04(45) ,  
      c   => pp1_03(45) ,  
      sum => pp2_03(45) ,  
      car => pp2_02(44));  
  pp2_01_csa_44: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(44) ,  
      b   => pp1_04(44) ,  
      c   => pp1_03(44) ,  
      sum => pp2_03(44) ,  
      car => pp2_02(43));  
  pp2_01_csa_43: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(43) ,  
      b   => pp1_04(43) ,  
      c   => pp1_03(43) ,  
      sum => pp2_03(43) ,  
      car => pp2_02(42));  
  pp2_01_csa_42: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(42) ,  
      b   => pp1_04(42) ,  
      c   => pp1_03(42) ,  
      sum => pp2_03(42) ,  
      car => pp2_02(41));  
  pp2_01_csa_41: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(41) ,  
      b   => pp1_04(41) ,  
      c   => pp1_03(41) ,  
      sum => pp2_03(41) ,  
      car => pp2_02(40));  
  pp2_01_csa_40: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(40) ,  
      b   => pp1_04(40) ,  
      c   => pp1_03(40) ,  
      sum => pp2_03(40) ,  
      car => pp2_02(39));  
  pp2_01_csa_39: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(39) ,  
      b   => pp1_04(39) ,  
      c   => pp1_03(39) ,  
      sum => pp2_03(39) ,  
      car => pp2_02(38));  
  pp2_01_csa_38: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(38) ,  
      b   => pp1_04(38) ,  
      c   => pp1_03(38) ,  
      sum => pp2_03(38) ,  
      car => pp2_02(37));  
  pp2_01_csa_37: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(37) ,  
      b   => pp1_04(37) ,  
      c   => pp1_03(37) ,  
      sum => pp2_03(37) ,  
      car => pp2_02(36));  
  pp2_01_csa_36: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(36) ,  
      b   => pp1_04(36) ,  
      c   => pp1_03(36) ,  
      sum => pp2_03(36) ,  
      car => pp2_02(35));  
  pp2_01_csa_35: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(35) ,  
      b   => pp1_04(35) ,  
      c   => pp1_03(35) ,  
      sum => pp2_03(35) ,  
      car => pp2_02(34));  
  pp2_01_csa_34: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(34) ,  
      b   => pp1_04(34) ,  
      c   => pp1_03(34) ,  
      sum => pp2_03(34) ,  
      car => pp2_02(33));  
  pp2_01_csa_33: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(33) ,  
      b   => pp1_04(33) ,  
      c   => pp1_03(33) ,  
      sum => pp2_03(33) ,  
      car => pp2_02(32));  
  pp2_01_csa_32: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(32) ,  
      b   => pp1_04(32) ,  
      c   => pp1_03(32) ,  
      sum => pp2_03(32) ,  
      car => pp2_02(31));  
  pp2_01_csa_31: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(31) ,  
      b   => pp1_04(31) ,  
      c   => pp1_03(31) ,  
      sum => pp2_03(31) ,  
      car => pp2_02(30));  
  pp2_01_csa_30: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(30) ,  
      b   => pp1_04(30) ,  
      c   => pp1_03(30) ,  
      sum => pp2_03(30) ,  
      car => pp2_02(29));  
  pp2_01_csa_29: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(29) ,  
      b   => pp1_04(29) ,  
      c   => pp1_03(29) ,  
      sum => pp2_03(29) ,  
      car => pp2_02(28));  
  pp2_01_csa_28: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(28) ,  
      b   => pp1_04(28) ,  
      c   => pp1_03(28) ,  
      sum => pp2_03(28) ,  
      car => pp2_02(27));  
  pp2_01_csa_27: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(27) ,  
      b   => pp1_04(27) ,  
      c   => pp1_03(27) ,  
      sum => pp2_03(27) ,  
      car => pp2_02(26));  
  pp2_01_csa_26: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(26) ,  
      b   => pp1_04(26) ,  
      c   => pp1_03(26) ,  
      sum => pp2_03(26) ,  
      car => pp2_02(25));  
  pp2_01_csa_25: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(25) ,  
      b   => pp1_04(25) ,  
      c   => pp1_03(25) ,  
      sum => pp2_03(25) ,  
      car => pp2_02(24));  
  pp2_01_csa_24: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(24) ,  
      b   => pp1_04(24) ,  
      c   => pp1_03(24) ,  
      sum => pp2_03(24) ,  
      car => pp2_02(23));  
  pp2_01_csa_23: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(23) ,  
      b   => pp1_04(23) ,  
      c   => pp1_03(23) ,  
      sum => pp2_03(23) ,  
      car => pp2_02(22));  
  pp2_01_csa_22: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(22) ,  
      b   => pp1_04(22) ,  
      c   => pp1_03(22) ,  
      sum => pp2_03(22) ,  
      car => pp2_02(21));  
  pp2_01_csa_21: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(21) ,  
      b   => pp1_04(21) ,  
      c   => pp1_03(21) ,  
      sum => pp2_03(21) ,  
      car => pp2_02(20));  
  pp2_01_csa_20: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(20) ,  
      b   => pp1_04(20) ,  
      c   => pp1_03(20) ,  
      sum => pp2_03(20) ,  
      car => pp2_02(19));  
  pp2_01_csa_19: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(19) ,  
      b   => pp1_04(19) ,  
      c   => pp1_03(19) ,  
      sum => pp2_03(19) ,  
      car => pp2_02(18));  
  pp2_01_csa_18: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(18) ,  
      b   => pp1_04(18) ,  
      c   => pp1_03(18) ,  
      sum => pp2_03(18) ,  
      car => pp2_02(17));  
  pp2_01_csa_17: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(17) ,  
      b   => pp1_04(17) ,  
      c   => pp1_03(17) ,  
      sum => pp2_03(17) ,  
      car => pp2_02(16));  
  pp2_01_csa_16: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(16) ,  
      b   => pp1_04(16) ,  
      c   => pp1_03(16) ,  
      sum => pp2_03(16) ,  
      car => pp2_02(15));  
  pp2_01_csa_15: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_05(15) ,  
      b   => pp1_04(15) ,  
      c   => pp1_03(15) ,  
      sum => pp2_03(15) ,  
      car => pp2_02(14));  
  pp2_01_csa_14: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => tiup ,  
      b   => pp1_03(14) ,  
      sum => pp2_03(14) ,  
      car => pp2_02(13));  
  pp2_03(13) <= pp1_03(13);
  pp2_03(12) <= pp1_03(12);
  pp2_03(11) <= pp1_03(11);
  pp2_03(10) <= pp1_03(10);
  pp2_03(9)  <= pp1_03(9);
  pp2_03(8)  <= tiup;



  pp2_01(68) <= pp1_02(68);
  pp2_01(67) <= tidn;
  pp2_01(66) <= tidn;
  pp2_01(65) <= pp1_02(65);
  pp2_01(64) <= pp1_02(64);
  pp2_01(63) <= pp1_02(63);

  pp2_00(64) <= pp1_01(64);
  pp2_00(63) <= tidn;
  pp2_00(62) <= tidn;

  pp2_00_csa_62: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(62) ,  
      b   => pp1_01(62) ,  
      c   => pp1_00(62) ,  
      sum => pp2_01(62) ,  
      car => pp2_00(61));  
  pp2_00_csa_61: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp1_02(61) ,  
      b   => pp1_01(61) ,  
      sum => pp2_01(61) ,  
      car => pp2_00(60));  
  pp2_00_csa_60: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp1_02(60) ,  
      b   => pp1_01(60) ,  
      sum => pp2_01(60) ,  
      car => pp2_00(59));  
  pp2_00_csa_59: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(59) ,  
      b   => pp1_01(59) ,  
      c   => pp1_00(59) ,  
      sum => pp2_01(59) ,  
      car => pp2_00(58));  
  pp2_00_csa_58: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(58) ,  
      b   => pp1_01(58) ,  
      c   => pp1_00(58) ,  
      sum => pp2_01(58) ,  
      car => pp2_00(57));  
  pp2_00_csa_57: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(57) ,  
      b   => pp1_01(57) ,  
      c   => pp1_00(57) ,  
      sum => pp2_01(57) ,  
      car => pp2_00(56));  
  pp2_00_csa_56: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(56) ,  
      b   => pp1_01(56) ,  
      c   => pp1_00(56) ,  
      sum => pp2_01(56) ,  
      car => pp2_00(55));  
  pp2_00_csa_55: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(55) ,  
      b   => pp1_01(55) ,  
      c   => pp1_00(55) ,  
      sum => pp2_01(55) ,  
      car => pp2_00(54));  
  pp2_00_csa_54: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(54) ,  
      b   => pp1_01(54) ,  
      c   => pp1_00(54) ,  
      sum => pp2_01(54) ,  
      car => pp2_00(53));  
  pp2_00_csa_53: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(53) ,  
      b   => pp1_01(53) ,  
      c   => pp1_00(53) ,  
      sum => pp2_01(53) ,  
      car => pp2_00(52));  
  pp2_00_csa_52: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(52) ,  
      b   => pp1_01(52) ,  
      c   => pp1_00(52) ,  
      sum => pp2_01(52) ,  
      car => pp2_00(51));  
  pp2_00_csa_51: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(51) ,  
      b   => pp1_01(51) ,  
      c   => pp1_00(51) ,  
      sum => pp2_01(51) ,  
      car => pp2_00(50));  
  pp2_00_csa_50: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(50) ,  
      b   => pp1_01(50) ,  
      c   => pp1_00(50) ,  
      sum => pp2_01(50) ,  
      car => pp2_00(49));  
  pp2_00_csa_49: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(49) ,  
      b   => pp1_01(49) ,  
      c   => pp1_00(49) ,  
      sum => pp2_01(49) ,  
      car => pp2_00(48));  
  pp2_00_csa_48: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(48) ,  
      b   => pp1_01(48) ,  
      c   => pp1_00(48) ,  
      sum => pp2_01(48) ,  
      car => pp2_00(47));  
  pp2_00_csa_47: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(47) ,  
      b   => pp1_01(47) ,  
      c   => pp1_00(47) ,  
      sum => pp2_01(47) ,  
      car => pp2_00(46));  
  pp2_00_csa_46: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(46) ,  
      b   => pp1_01(46) ,  
      c   => pp1_00(46) ,  
      sum => pp2_01(46) ,  
      car => pp2_00(45));  
  pp2_00_csa_45: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(45) ,  
      b   => pp1_01(45) ,  
      c   => pp1_00(45) ,  
      sum => pp2_01(45) ,  
      car => pp2_00(44));  
  pp2_00_csa_44: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(44) ,  
      b   => pp1_01(44) ,  
      c   => pp1_00(44) ,  
      sum => pp2_01(44) ,  
      car => pp2_00(43));  
  pp2_00_csa_43: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(43) ,  
      b   => pp1_01(43) ,  
      c   => pp1_00(43) ,  
      sum => pp2_01(43) ,  
      car => pp2_00(42));  
  pp2_00_csa_42: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(42) ,  
      b   => pp1_01(42) ,  
      c   => pp1_00(42) ,  
      sum => pp2_01(42) ,  
      car => pp2_00(41));  
  pp2_00_csa_41: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(41) ,  
      b   => pp1_01(41) ,  
      c   => pp1_00(41) ,  
      sum => pp2_01(41) ,  
      car => pp2_00(40));  
  pp2_00_csa_40: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(40) ,  
      b   => pp1_01(40) ,  
      c   => pp1_00(40) ,  
      sum => pp2_01(40) ,  
      car => pp2_00(39));  
  pp2_00_csa_39: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(39) ,  
      b   => pp1_01(39) ,  
      c   => pp1_00(39) ,  
      sum => pp2_01(39) ,  
      car => pp2_00(38));  
  pp2_00_csa_38: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(38) ,  
      b   => pp1_01(38) ,  
      c   => pp1_00(38) ,  
      sum => pp2_01(38) ,  
      car => pp2_00(37));  
  pp2_00_csa_37: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(37) ,  
      b   => pp1_01(37) ,  
      c   => pp1_00(37) ,  
      sum => pp2_01(37) ,  
      car => pp2_00(36));  
  pp2_00_csa_36: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(36) ,  
      b   => pp1_01(36) ,  
      c   => pp1_00(36) ,  
      sum => pp2_01(36) ,  
      car => pp2_00(35));  
  pp2_00_csa_35: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(35) ,  
      b   => pp1_01(35) ,  
      c   => pp1_00(35) ,  
      sum => pp2_01(35) ,  
      car => pp2_00(34));  
  pp2_00_csa_34: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(34) ,  
      b   => pp1_01(34) ,  
      c   => pp1_00(34) ,  
      sum => pp2_01(34) ,  
      car => pp2_00(33));  
  pp2_00_csa_33: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(33) ,  
      b   => pp1_01(33) ,  
      c   => pp1_00(33) ,  
      sum => pp2_01(33) ,  
      car => pp2_00(32));  
  pp2_00_csa_32: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(32) ,  
      b   => pp1_01(32) ,  
      c   => pp1_00(32) ,  
      sum => pp2_01(32) ,  
      car => pp2_00(31));  
  pp2_00_csa_31: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(31) ,  
      b   => pp1_01(31) ,  
      c   => pp1_00(31) ,  
      sum => pp2_01(31) ,  
      car => pp2_00(30));  
  pp2_00_csa_30: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(30) ,  
      b   => pp1_01(30) ,  
      c   => pp1_00(30) ,  
      sum => pp2_01(30) ,  
      car => pp2_00(29));  
  pp2_00_csa_29: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(29) ,  
      b   => pp1_01(29) ,  
      c   => pp1_00(29) ,  
      sum => pp2_01(29) ,  
      car => pp2_00(28));  
  pp2_00_csa_28: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(28) ,  
      b   => pp1_01(28) ,  
      c   => pp1_00(28) ,  
      sum => pp2_01(28) ,  
      car => pp2_00(27));  
  pp2_00_csa_27: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(27) ,  
      b   => pp1_01(27) ,  
      c   => pp1_00(27) ,  
      sum => pp2_01(27) ,  
      car => pp2_00(26));  
  pp2_00_csa_26: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(26) ,  
      b   => pp1_01(26) ,  
      c   => pp1_00(26) ,  
      sum => pp2_01(26) ,  
      car => pp2_00(25));  
  pp2_00_csa_25: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(25) ,  
      b   => pp1_01(25) ,  
      c   => pp1_00(25) ,  
      sum => pp2_01(25) ,  
      car => pp2_00(24));  
  pp2_00_csa_24: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(24) ,  
      b   => pp1_01(24) ,  
      c   => pp1_00(24) ,  
      sum => pp2_01(24) ,  
      car => pp2_00(23));  
  pp2_00_csa_23: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(23) ,  
      b   => pp1_01(23) ,  
      c   => pp1_00(23) ,  
      sum => pp2_01(23) ,  
      car => pp2_00(22));  
  pp2_00_csa_22: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(22) ,  
      b   => pp1_01(22) ,  
      c   => pp1_00(22) ,  
      sum => pp2_01(22) ,  
      car => pp2_00(21));  
  pp2_00_csa_21: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(21) ,  
      b   => pp1_01(21) ,  
      c   => pp1_00(21) ,  
      sum => pp2_01(21) ,  
      car => pp2_00(20));  
  pp2_00_csa_20: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(20) ,  
      b   => pp1_01(20) ,  
      c   => pp1_00(20) ,  
      sum => pp2_01(20) ,  
      car => pp2_00(19));  
  pp2_00_csa_19: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(19) ,  
      b   => pp1_01(19) ,  
      c   => pp1_00(19) ,  
      sum => pp2_01(19) ,  
      car => pp2_00(18));  
  pp2_00_csa_18: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(18) ,  
      b   => pp1_01(18) ,  
      c   => pp1_00(18) ,  
      sum => pp2_01(18) ,  
      car => pp2_00(17));  
  pp2_00_csa_17: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(17) ,  
      b   => pp1_01(17) ,  
      c   => pp1_00(17) ,  
      sum => pp2_01(17) ,  
      car => pp2_00(16));  
  pp2_00_csa_16: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(16) ,  
      b   => pp1_01(16) ,  
      c   => pp1_00(16) ,  
      sum => pp2_01(16) ,  
      car => pp2_00(15));  
  pp2_00_csa_15: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(15) ,  
      b   => pp1_01(15) ,  
      c   => pp1_00(15) ,  
      sum => pp2_01(15) ,  
      car => pp2_00(14));  
  pp2_00_csa_14: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(14) ,  
      b   => pp1_01(14) ,  
      c   => pp1_00(14) ,  
      sum => pp2_01(14) ,  
      car => pp2_00(13));  
  pp2_00_csa_13: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(13) ,  
      b   => pp1_01(13) ,  
      c   => pp1_00(13) ,  
      sum => pp2_01(13) ,  
      car => pp2_00(12));  
  pp2_00_csa_12: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(12) ,  
      b   => pp1_01(12) ,  
      c   => pp1_00(12) ,  
      sum => pp2_01(12) ,  
      car => pp2_00(11));  
  pp2_00_csa_11: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(11) ,  
      b   => pp1_01(11) ,  
      c   => pp1_00(11) ,  
      sum => pp2_01(11) ,  
      car => pp2_00(10));  
  pp2_00_csa_10: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(10) ,  
      b   => pp1_01(10) ,  
      c   => pp1_00(10) ,  
      sum => pp2_01(10) ,  
      car => pp2_00(9));  
  pp2_00_csa_09: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp1_02(9) ,  
      b   => pp1_01(9) ,  
      c   => pp1_00(9) ,  
      sum => pp2_01(9) ,  
      car => pp2_00(8));  
  pp2_00_csa_08: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp1_01(8) ,  
      b   => pp1_00(8) ,  
      sum => pp2_01(8) ,  
      car => pp2_00(7));  
  pp2_00_csa_07: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp1_01(7) ,  
      b   => pp1_00(7) ,  
      sum => pp2_01(7) ,  
      car => pp2_00(6));  
  pp2_00_csa_06: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp1_01(6) ,  
      b   => pp1_00(6) ,  
      sum => pp2_01(6) ,  
      car => pp2_00(5));  
  pp2_00_csa_05: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp1_01(5) ,  
      b   => pp1_00(5) ,  
      sum => pp2_01(5) ,  
      car => pp2_00(4));  
  pp2_00_csa_04: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp1_01(4) ,  
      b   => pp1_00(4) ,  
      sum => pp2_01(4) ,  
      car => pp2_00(3));  
  pp2_00_csa_03: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp1_01(3) ,  
      b   => pp1_00(3) ,  
      sum => pp2_01(3) ,  
      car => pp2_00(2));  
  pp2_01(2) <= pp1_01(2);








  pp3_01(74) <= pp2_03(74);
  pp3_01(73) <= pp2_03(73);
  pp3_01(72) <= pp2_03(72);
  pp3_01(71) <= pp2_03(71);
  pp3_01(70) <= pp2_03(70);
  pp3_01(69) <= pp2_03(69);

  pp3_00(74) <= pp2_02(74);
  pp3_00(73) <= tidn;
  pp3_00(72) <= tidn;
  pp3_00(71) <= pp2_02(71);
  pp3_00(70) <= tidn;
  pp3_00(69) <= pp2_02(69);
  pp3_00(68) <= tidn;

  pp3_00_csa_68: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(68) ,  
      b   => pp2_02(68) ,  
      c   => pp2_01(68) ,  
      sum => pp3_01(68) ,  
      car => pp3_00(67));  
  pp3_00_csa_67: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp2_03(67) ,  
      b   => pp2_02(67) ,  
      sum => pp3_01(67) ,  
      car => pp3_00(66));  
  pp3_00_csa_66: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp2_03(66) ,  
      b   => pp2_02(66) ,  
      sum => pp3_01(66) ,  
      car => pp3_00(65));  
  pp3_00_csa_65: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(65) ,  
      b   => pp2_02(65) ,  
      c   => pp2_01(65) ,  
      sum => pp3_01(65) ,  
      car => pp3_00(64));  
  pp3_00_csa_64: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(64) ,  
      b   => pp2_02(64) ,  
      c   => pp2_01(64) ,  
      d   => pp2_00(64) ,  
      ki  => tidn ,  
      ko  => pp3_00_ko(63) ,  
      sum => pp3_01(64) ,  
      car => pp3_00(63));  
  pp3_00_csa_63: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(63) ,  
      b   => pp2_02(63) ,  
      c   => pp2_01(63) ,  
      d   => tidn ,  
      ki  => pp3_00_ko(63) ,  
      ko  => pp3_00_ko(62) ,  
      sum => pp3_01(63) ,  
      car => pp3_00(62));  
  pp3_00_csa_62: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(62) ,  
      b   => pp2_02(62) ,  
      c   => pp2_01(62) ,  
      d   => tidn ,  
      ki  => pp3_00_ko(62) ,  
      ko  => pp3_00_ko(61) ,  
      sum => pp3_01(62) ,  
      car => pp3_00(61));  
  pp3_00_csa_61: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(61) ,  
      b   => pp2_02(61) ,  
      c   => pp2_01(61) ,  
      d   => pp2_00(61) ,  
      ki  => pp3_00_ko(61) ,  
      ko  => pp3_00_ko(60) ,  
      sum => pp3_01(61) ,  
      car => pp3_00(60));  
  pp3_00_csa_60: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(60) ,  
      b   => pp2_02(60) ,  
      c   => pp2_01(60) ,  
      d   => pp2_00(60) ,  
      ki  => pp3_00_ko(60) ,  
      ko  => pp3_00_ko(59) ,  
      sum => pp3_01(60) ,  
      car => pp3_00(59));  
  pp3_00_csa_59: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(59) ,  
      b   => pp2_02(59) ,  
      c   => pp2_01(59) ,  
      d   => pp2_00(59) ,  
      ki  => pp3_00_ko(59) ,  
      ko  => pp3_00_ko(58) ,  
      sum => pp3_01(59) ,  
      car => pp3_00(58));  
  pp3_00_csa_58: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(58) ,  
      b   => pp2_02(58) ,  
      c   => pp2_01(58) ,  
      d   => pp2_00(58) ,  
      ki  => pp3_00_ko(58) ,  
      ko  => pp3_00_ko(57) ,  
      sum => pp3_01(58) ,  
      car => pp3_00(57));  
  pp3_00_csa_57: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(57) ,  
      b   => pp2_02(57) ,  
      c   => pp2_01(57) ,  
      d   => pp2_00(57) ,  
      ki  => pp3_00_ko(57) ,  
      ko  => pp3_00_ko(56) ,  
      sum => pp3_01(57) ,  
      car => pp3_00(56));  
  pp3_00_csa_56: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(56) ,  
      b   => pp2_02(56) ,  
      c   => pp2_01(56) ,  
      d   => pp2_00(56) ,  
      ki  => pp3_00_ko(56) ,  
      ko  => pp3_00_ko(55) ,  
      sum => pp3_01(56) ,  
      car => pp3_00(55));  
  pp3_00_csa_55: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(55) ,  
      b   => pp2_02(55) ,  
      c   => pp2_01(55) ,  
      d   => pp2_00(55) ,  
      ki  => pp3_00_ko(55) ,  
      ko  => pp3_00_ko(54) ,  
      sum => pp3_01(55) ,  
      car => pp3_00(54));  
  pp3_00_csa_54: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(54) ,  
      b   => pp2_02(54) ,  
      c   => pp2_01(54) ,  
      d   => pp2_00(54) ,  
      ki  => pp3_00_ko(54) ,  
      ko  => pp3_00_ko(53) ,  
      sum => pp3_01(54) ,  
      car => pp3_00(53));  
  pp3_00_csa_53: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(53) ,  
      b   => pp2_02(53) ,  
      c   => pp2_01(53) ,  
      d   => pp2_00(53) ,  
      ki  => pp3_00_ko(53) ,  
      ko  => pp3_00_ko(52) ,  
      sum => pp3_01(53) ,  
      car => pp3_00(52));  
  pp3_00_csa_52: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(52) ,  
      b   => pp2_02(52) ,  
      c   => pp2_01(52) ,  
      d   => pp2_00(52) ,  
      ki  => pp3_00_ko(52) ,  
      ko  => pp3_00_ko(51) ,  
      sum => pp3_01(52) ,  
      car => pp3_00(51));  
  pp3_00_csa_51: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(51) ,  
      b   => pp2_02(51) ,  
      c   => pp2_01(51) ,  
      d   => pp2_00(51) ,  
      ki  => pp3_00_ko(51) ,  
      ko  => pp3_00_ko(50) ,  
      sum => pp3_01(51) ,  
      car => pp3_00(50));  
  pp3_00_csa_50: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(50) ,  
      b   => pp2_02(50) ,  
      c   => pp2_01(50) ,  
      d   => pp2_00(50) ,  
      ki  => pp3_00_ko(50) ,  
      ko  => pp3_00_ko(49) ,  
      sum => pp3_01(50) ,  
      car => pp3_00(49));  
  pp3_00_csa_49: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(49) ,  
      b   => pp2_02(49) ,  
      c   => pp2_01(49) ,  
      d   => pp2_00(49) ,  
      ki  => pp3_00_ko(49) ,  
      ko  => pp3_00_ko(48) ,  
      sum => pp3_01(49) ,  
      car => pp3_00(48));  
  pp3_00_csa_48: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(48) ,  
      b   => pp2_02(48) ,  
      c   => pp2_01(48) ,  
      d   => pp2_00(48) ,  
      ki  => pp3_00_ko(48) ,  
      ko  => pp3_00_ko(47) ,  
      sum => pp3_01(48) ,  
      car => pp3_00(47));  
  pp3_00_csa_47: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(47) ,  
      b   => pp2_02(47) ,  
      c   => pp2_01(47) ,  
      d   => pp2_00(47) ,  
      ki  => pp3_00_ko(47) ,  
      ko  => pp3_00_ko(46) ,  
      sum => pp3_01(47) ,  
      car => pp3_00(46));  
  pp3_00_csa_46: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(46) ,  
      b   => pp2_02(46) ,  
      c   => pp2_01(46) ,  
      d   => pp2_00(46) ,  
      ki  => pp3_00_ko(46) ,  
      ko  => pp3_00_ko(45) ,  
      sum => pp3_01(46) ,  
      car => pp3_00(45));  
  pp3_00_csa_45: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(45) ,  
      b   => pp2_02(45) ,  
      c   => pp2_01(45) ,  
      d   => pp2_00(45) ,  
      ki  => pp3_00_ko(45) ,  
      ko  => pp3_00_ko(44) ,  
      sum => pp3_01(45) ,  
      car => pp3_00(44));  
  pp3_00_csa_44: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(44) ,  
      b   => pp2_02(44) ,  
      c   => pp2_01(44) ,  
      d   => pp2_00(44) ,  
      ki  => pp3_00_ko(44) ,  
      ko  => pp3_00_ko(43) ,  
      sum => pp3_01(44) ,  
      car => pp3_00(43));  
  pp3_00_csa_43: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(43) ,  
      b   => pp2_02(43) ,  
      c   => pp2_01(43) ,  
      d   => pp2_00(43) ,  
      ki  => pp3_00_ko(43) ,  
      ko  => pp3_00_ko(42) ,  
      sum => pp3_01(43) ,  
      car => pp3_00(42));  
  pp3_00_csa_42: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(42) ,  
      b   => pp2_02(42) ,  
      c   => pp2_01(42) ,  
      d   => pp2_00(42) ,  
      ki  => pp3_00_ko(42) ,  
      ko  => pp3_00_ko(41) ,  
      sum => pp3_01(42) ,  
      car => pp3_00(41));  
  pp3_00_csa_41: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(41) ,  
      b   => pp2_02(41) ,  
      c   => pp2_01(41) ,  
      d   => pp2_00(41) ,  
      ki  => pp3_00_ko(41) ,  
      ko  => pp3_00_ko(40) ,  
      sum => pp3_01(41) ,  
      car => pp3_00(40));  
  pp3_00_csa_40: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(40) ,  
      b   => pp2_02(40) ,  
      c   => pp2_01(40) ,  
      d   => pp2_00(40) ,  
      ki  => pp3_00_ko(40) ,  
      ko  => pp3_00_ko(39) ,  
      sum => pp3_01(40) ,  
      car => pp3_00(39));  
  pp3_00_csa_39: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(39) ,  
      b   => pp2_02(39) ,  
      c   => pp2_01(39) ,  
      d   => pp2_00(39) ,  
      ki  => pp3_00_ko(39) ,  
      ko  => pp3_00_ko(38) ,  
      sum => pp3_01(39) ,  
      car => pp3_00(38));  
  pp3_00_csa_38: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(38) ,  
      b   => pp2_02(38) ,  
      c   => pp2_01(38) ,  
      d   => pp2_00(38) ,  
      ki  => pp3_00_ko(38) ,  
      ko  => pp3_00_ko(37) ,  
      sum => pp3_01(38) ,  
      car => pp3_00(37));  
  pp3_00_csa_37: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(37) ,  
      b   => pp2_02(37) ,  
      c   => pp2_01(37) ,  
      d   => pp2_00(37) ,  
      ki  => pp3_00_ko(37) ,  
      ko  => pp3_00_ko(36) ,  
      sum => pp3_01(37) ,  
      car => pp3_00(36));  
  pp3_00_csa_36: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(36) ,  
      b   => pp2_02(36) ,  
      c   => pp2_01(36) ,  
      d   => pp2_00(36) ,  
      ki  => pp3_00_ko(36) ,  
      ko  => pp3_00_ko(35) ,  
      sum => pp3_01(36) ,  
      car => pp3_00(35));  
  pp3_00_csa_35: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(35) ,  
      b   => pp2_02(35) ,  
      c   => pp2_01(35) ,  
      d   => pp2_00(35) ,  
      ki  => pp3_00_ko(35) ,  
      ko  => pp3_00_ko(34) ,  
      sum => pp3_01(35) ,  
      car => pp3_00(34));  
  pp3_00_csa_34: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(34) ,  
      b   => pp2_02(34) ,  
      c   => pp2_01(34) ,  
      d   => pp2_00(34) ,  
      ki  => pp3_00_ko(34) ,  
      ko  => pp3_00_ko(33) ,  
      sum => pp3_01(34) ,  
      car => pp3_00(33));  
  pp3_00_csa_33: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(33) ,  
      b   => pp2_02(33) ,  
      c   => pp2_01(33) ,  
      d   => pp2_00(33) ,  
      ki  => pp3_00_ko(33) ,  
      ko  => pp3_00_ko(32) ,  
      sum => pp3_01(33) ,  
      car => pp3_00(32));  
  pp3_00_csa_32: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(32) ,  
      b   => pp2_02(32) ,  
      c   => pp2_01(32) ,  
      d   => pp2_00(32) ,  
      ki  => pp3_00_ko(32) ,  
      ko  => pp3_00_ko(31) ,  
      sum => pp3_01(32) ,  
      car => pp3_00(31));  
  pp3_00_csa_31: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(31) ,  
      b   => pp2_02(31) ,  
      c   => pp2_01(31) ,  
      d   => pp2_00(31) ,  
      ki  => pp3_00_ko(31) ,  
      ko  => pp3_00_ko(30) ,  
      sum => pp3_01(31) ,  
      car => pp3_00(30));  
  pp3_00_csa_30: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(30) ,  
      b   => pp2_02(30) ,  
      c   => pp2_01(30) ,  
      d   => pp2_00(30) ,  
      ki  => pp3_00_ko(30) ,  
      ko  => pp3_00_ko(29) ,  
      sum => pp3_01(30) ,  
      car => pp3_00(29));  
  pp3_00_csa_29: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(29) ,  
      b   => pp2_02(29) ,  
      c   => pp2_01(29) ,  
      d   => pp2_00(29) ,  
      ki  => pp3_00_ko(29) ,  
      ko  => pp3_00_ko(28) ,  
      sum => pp3_01(29) ,  
      car => pp3_00(28));  
  pp3_00_csa_28: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(28) ,  
      b   => pp2_02(28) ,  
      c   => pp2_01(28) ,  
      d   => pp2_00(28) ,  
      ki  => pp3_00_ko(28) ,  
      ko  => pp3_00_ko(27) ,  
      sum => pp3_01(28) ,  
      car => pp3_00(27));  
  pp3_00_csa_27: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(27) ,  
      b   => pp2_02(27) ,  
      c   => pp2_01(27) ,  
      d   => pp2_00(27) ,  
      ki  => pp3_00_ko(27) ,  
      ko  => pp3_00_ko(26) ,  
      sum => pp3_01(27) ,  
      car => pp3_00(26));  
  pp3_00_csa_26: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(26) ,  
      b   => pp2_02(26) ,  
      c   => pp2_01(26) ,  
      d   => pp2_00(26) ,  
      ki  => pp3_00_ko(26) ,  
      ko  => pp3_00_ko(25) ,  
      sum => pp3_01(26) ,  
      car => pp3_00(25));  
  pp3_00_csa_25: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(25) ,  
      b   => pp2_02(25) ,  
      c   => pp2_01(25) ,  
      d   => pp2_00(25) ,  
      ki  => pp3_00_ko(25) ,  
      ko  => pp3_00_ko(24) ,  
      sum => pp3_01(25) ,  
      car => pp3_00(24));  
  pp3_00_csa_24: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(24) ,  
      b   => pp2_02(24) ,  
      c   => pp2_01(24) ,  
      d   => pp2_00(24) ,  
      ki  => pp3_00_ko(24) ,  
      ko  => pp3_00_ko(23) ,  
      sum => pp3_01(24) ,  
      car => pp3_00(23));  
  pp3_00_csa_23: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(23) ,  
      b   => pp2_02(23) ,  
      c   => pp2_01(23) ,  
      d   => pp2_00(23) ,  
      ki  => pp3_00_ko(23) ,  
      ko  => pp3_00_ko(22) ,  
      sum => pp3_01(23) ,  
      car => pp3_00(22));  
  pp3_00_csa_22: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(22) ,  
      b   => pp2_02(22) ,  
      c   => pp2_01(22) ,  
      d   => pp2_00(22) ,  
      ki  => pp3_00_ko(22) ,  
      ko  => pp3_00_ko(21) ,  
      sum => pp3_01(22) ,  
      car => pp3_00(21));  
  pp3_00_csa_21: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(21) ,  
      b   => pp2_02(21) ,  
      c   => pp2_01(21) ,  
      d   => pp2_00(21) ,  
      ki  => pp3_00_ko(21) ,  
      ko  => pp3_00_ko(20) ,  
      sum => pp3_01(21) ,  
      car => pp3_00(20));  
  pp3_00_csa_20: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(20) ,  
      b   => pp2_02(20) ,  
      c   => pp2_01(20) ,  
      d   => pp2_00(20) ,  
      ki  => pp3_00_ko(20) ,  
      ko  => pp3_00_ko(19) ,  
      sum => pp3_01(20) ,  
      car => pp3_00(19));  
  pp3_00_csa_19: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(19) ,  
      b   => pp2_02(19) ,  
      c   => pp2_01(19) ,  
      d   => pp2_00(19) ,  
      ki  => pp3_00_ko(19) ,  
      ko  => pp3_00_ko(18) ,  
      sum => pp3_01(19) ,  
      car => pp3_00(18));  
  pp3_00_csa_18: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(18) ,  
      b   => pp2_02(18) ,  
      c   => pp2_01(18) ,  
      d   => pp2_00(18) ,  
      ki  => pp3_00_ko(18) ,  
      ko  => pp3_00_ko(17) ,  
      sum => pp3_01(18) ,  
      car => pp3_00(17));  
  pp3_00_csa_17: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(17) ,  
      b   => pp2_02(17) ,  
      c   => pp2_01(17) ,  
      d   => pp2_00(17) ,  
      ki  => pp3_00_ko(17) ,  
      ko  => pp3_00_ko(16) ,  
      sum => pp3_01(17) ,  
      car => pp3_00(16));  
  pp3_00_csa_16: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(16) ,  
      b   => pp2_02(16) ,  
      c   => pp2_01(16) ,  
      d   => pp2_00(16) ,  
      ki  => pp3_00_ko(16) ,  
      ko  => pp3_00_ko(15) ,  
      sum => pp3_01(16) ,  
      car => pp3_00(15));  
  pp3_00_csa_15: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(15) ,  
      b   => pp2_02(15) ,  
      c   => pp2_01(15) ,  
      d   => pp2_00(15) ,  
      ki  => pp3_00_ko(15) ,  
      ko  => pp3_00_ko(14) ,  
      sum => pp3_01(15) ,  
      car => pp3_00(14));  
  pp3_00_csa_14: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(14) ,  
      b   => pp2_02(14) ,  
      c   => pp2_01(14) ,  
      d   => pp2_00(14) ,  
      ki  => pp3_00_ko(14) ,  
      ko  => pp3_00_ko(13) ,  
      sum => pp3_01(14) ,  
      car => pp3_00(13));  
  pp3_00_csa_13: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(13) ,  
      b   => pp2_02(13) ,  
      c   => pp2_01(13) ,  
      d   => pp2_00(13) ,  
      ki  => pp3_00_ko(13) ,  
      ko  => pp3_00_ko(12) ,  
      sum => pp3_01(13) ,  
      car => pp3_00(12));  
  pp3_00_csa_12: entity clib.c_prism_csa42     port map (
       vd  => vdd,
      gd  => gnd,
     a   => pp2_03(12) ,  
      b   => pp2_01(12) ,  
      c   => pp2_00(12) ,  
      d   => tidn ,  
      ki  => pp3_00_ko(12) ,  
      ko  => pp3_00_ko(11) ,  
      sum => pp3_01(12) ,  
      car => pp3_00(11));  
  pp3_00_csa_11: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(11) ,  
      b   => pp2_01(11) ,  
      c   => pp2_00(11) ,  
      d   => tidn ,  
      ki  => pp3_00_ko(11) ,  
      ko  => pp3_00_ko(10) ,  
      sum => pp3_01(11) ,  
      car => pp3_00(10));  
  pp3_00_csa_10: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(10) ,  
      b   => pp2_01(10) ,  
      c   => pp2_00(10) ,  
      d   => tidn ,  
      ki  => pp3_00_ko(10) ,  
      ko  => pp3_00_ko(9) ,  
      sum => pp3_01(10) ,  
      car => pp3_00(9));  
  pp3_00_csa_09: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_03(9) ,  
      b   => pp2_01(9) ,  
      c   => pp2_00(9) ,  
      d   => tidn ,  
      ki  => pp3_00_ko(9) ,  
      ko  => pp3_00_ko(8) ,  
      sum => pp3_01(9) ,  
      car => pp3_00(8));  
  pp3_00_csa_08: entity clib.c_prism_csa42     port map (
      vd  => vdd,
      gd  => gnd,
      a   => tiup ,  
      b   => pp2_01(8) ,  
      c   => pp2_00(8) ,  
      d   => tidn ,  
      ki  => pp3_00_ko(8) ,  
      ko  => pp3_00_ko(7) ,  
      sum => pp3_01(8) ,  
      car => pp3_00(7));  
  pp3_00_csa_07: entity clib.c_prism_csa32     port map (
      vd  => vdd,
      gd  => gnd,
      a   => pp2_01(7) ,  
      b   => pp2_00(7) ,  
      c   => pp3_00_ko(7) ,  
      sum => pp3_01(7) ,  
      car => pp3_00(6));  
  pp3_00_csa_06: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp2_01(6) ,  
      b   => pp2_00(6) ,  
      sum => pp3_01(6) ,  
      car => pp3_00(5));  
  pp3_00_csa_05: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp2_01(5) ,  
      b   => pp2_00(5) ,  
      sum => pp3_01(5) ,  
      car => pp3_00(4));  
  pp3_00_csa_04: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp2_01(4) ,  
      b   => pp2_00(4) ,  
      sum => pp3_01(4) ,  
      car => pp3_00(3));  
  pp3_00_csa_03: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp2_01(3) ,  
      b   => pp2_00(3) ,  
      sum => pp3_01(3) ,  
      car => pp3_00(2));  
  pp3_00_csa_02: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
      a   => pp2_01(2) ,  
      b   => pp2_00(2) ,  
      sum => pp3_01(2) ,  
      car => pp3_00(1));  




    mul92_lcb: tri_lcbnd generic map (expand_type => expand_type) port map (
        delay_lclkr =>  lcb_delay_lclkr    ,
        mpw1_b      =>  lcb_mpw1_b         ,
        mpw2_b      =>  lcb_mpw2_b         ,
        forcee => forcee,
        nclk        =>  nclk               ,
        vd          =>  vdd                 ,
        gd          =>  gnd                 ,
        act         =>  ex1_act            ,
        sg          =>  lcb_sg             ,
        thold_b     =>  thold_b            ,
        d1clk       =>  mul92_d1clk        ,
        d2clk       =>  mul92_d2clk        ,
        lclk        =>  mul92_lclk        );


    pp3_lat_sum:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 73, btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0    ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => mul92_lclk               ,
        D1CLK            => mul92_d1clk              ,
        D2CLK            => mul92_d2clk              ,
        SCANIN(0)        => si                       ,                    
        SCANIN(1 to 72)  => pp3_lat_sum_so(0 to 71)  ,                    
        SCANOUT          => pp3_lat_sum_so(0 to 72)  ,          
        D(0 to 72)       => pp3_01(2 to 74)          ,
        QB(0 to 72)      => pp3_01_q_b(2 to 74)     ); 

    pp3_lat_car:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 71, btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0    ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => mul92_lclk               ,
        D1CLK            => mul92_d1clk              ,
        D2CLK            => mul92_d2clk              ,
        SCANIN(0 to 69)  => pp3_lat_car_so(1 to 70)  ,                    
        SCANIN(70)       => pp3_lat_sum_so(72)       , 
        SCANOUT          => pp3_lat_car_so(0 to 70)  ,          
        D(0 to 66)       => pp3_00(1 to 67)  ,                                    
        D(67)            => pp3_00(69) ,      
        D(68)            => hot_one_din ,     
        D(69)            => pp3_00(71) ,                                                                             
        D(70)            => pp3_00(74) ,      
        QB(0 to 66)      => pp3_00_q_b(1 to 67)  ,                                    
        QB(67)           => pp3_00_q_b(69) ,      
        QB(68)           => hot_one_out_b ,     
        QB(69)           => pp3_00_q_b(71) ,                                                                             
        QB(70)           => pp3_00_q_b(74)  ) ;      



  pp3_00_q_b(68) <= tiup; 
  pp3_00_q_b(70) <= tiup; 
  pp3_00_q_b(72) <= tiup; 
  pp3_00_q_b(73) <= tiup; 
  hot_one_out <= not hot_one_out_b ;

  invo_s: sum92(2 to 74) <= not pp3_01_q_b(2 to 74); 
  invo_c: car92(1 to 74) <= not pp3_00_q_b(1 to 74); 


  so <= pp3_lat_car_so(0);  

end;  

