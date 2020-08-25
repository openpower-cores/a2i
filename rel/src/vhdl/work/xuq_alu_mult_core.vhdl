-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


LIBRARY ieee;       USE ieee.std_logic_1164.all;
                    USE ieee.numeric_std.all;
LIBRARY ibm;        
                    USE ibm.std_ulogic_support.all;
                    USE ibm.std_ulogic_unsigned.all;
                    USE ibm.std_ulogic_function_support.all;
LIBRARY support;    
                    USE support.power_logic_pkg.all;
LIBRARY tri;        USE tri.tri_latches_pkg.all;
LIBRARY clib ;
LIBRARY work;       USE work.xuq_pkg.all;

-- #####################################################################
-- ## multiplier with intermediate latches and output latches.
-- ## feedback so that 4 32bit multiplies emulate a 64 bit multiply
-- #####################################################################


entity xuq_alu_mult_core is    generic ( expand_type: integer := 2  );   port (

        -- Pervasive ---------------------------------------
        nclk                            :in clk_logic;
        vdd                             :inout power_logic;
        gnd                             :inout power_logic;
        delay_lclkr_dc                  :in std_ulogic;
        mpw1_dc_b                       :in std_ulogic;
        mpw2_dc_b                       :in std_ulogic;
        func_sl_force                   :in std_ulogic;
        func_sl_thold_0_b               :in std_ulogic;
        sg_0                            :in std_ulogic;
        scan_in                         :in std_ulogic;
        scan_out                        :out std_ulogic;

        ex2_act                         :in std_ulogic; -- for latches at end of first  multiply cycle
        ex3_act                         :in std_ulogic; -- for latches at end of second multiply cycle

        -- Numbers to multiply (with seperate sign bit) ---------------------------
        ex2_bs_lo_sign                  :in  std_ulogic;                 -- input data to multiply
        ex2_bd_lo_sign                  :in  std_ulogic;                 -- input data to multiply
        ex2_bd_lo                       :in  std_ulogic_vector(0 to 31); -- input data to multiply
        ex2_bs_lo                       :in  std_ulogic_vector(0 to 31); -- input data to multiply

        -- Feedback recirculation for multiple cycle multiply ---------------------
        ex3_recycle_s                   :in  std_ulogic_vector(196 to 264); --compressor feedback
        ex3_recycle_c                   :in  std_ulogic_vector(196 to 263); --compressor feedback

        -- result vectors ---------------(adder 0:63 uses my number 200:263)
        ex4_pp5_0s_out                  :out std_ulogic_vector(196 to 264); -- compressor output to adder
        ex4_pp5_0c_out                  :out std_ulogic_vector(196 to 263)  -- compressor output to adder
    );
    --  synopsys translate_off
    --  synopsys translate_on
end xuq_alu_mult_core;

architecture xuq_alu_mult_core of xuq_alu_mult_core is
    constant tiup                       : std_ulogic := '1';
    constant tidn                       : std_ulogic := '0';

    signal ex3_d1clk, ex4_d1clk  :std_ulogic ;
    signal ex3_d2clk, ex4_d2clk  :std_ulogic ;
    signal ex3_lclk , ex4_lclk   :clk_logic  ;


   signal ex3_pp2_0c_din, ex3_pp2_0c,                                 ex3_pp2_0c_q_b, ex3_pp2_0c_lat_so , ex3_pp2_0c_lat_si  :std_ulogic_vector(198 to 240) ;
   signal ex3_pp2_0s_din, ex3_pp2_0s,                                 ex3_pp2_0s_q_b, ex3_pp2_0s_lat_so , ex3_pp2_0s_lat_si  :std_ulogic_vector(198 to 242) ;
   signal ex3_pp2_1c_din, ex3_pp2_1c, ex3_pp2_1c_x,  ex3_pp2_1c_x_b,  ex3_pp2_1c_q_b, ex3_pp2_1c_lat_so , ex3_pp2_1c_lat_si  :std_ulogic_vector(208 to 252) ;
   signal ex3_pp2_1s_din, ex3_pp2_1s, ex3_pp2_1s_x,  ex3_pp2_1s_x_b,  ex3_pp2_1s_q_b, ex3_pp2_1s_lat_so , ex3_pp2_1s_lat_si  :std_ulogic_vector(208 to 254) ;
   signal ex3_pp2_2c_din, ex3_pp2_2c, ex3_pp2_2c_x,  ex3_pp2_2c_x_b,  ex3_pp2_2c_q_b, ex3_pp2_2c_lat_so , ex3_pp2_2c_lat_si  :std_ulogic_vector(220 to 263) ;
   signal ex3_pp2_2s_din, ex3_pp2_2s, ex3_pp2_2s_x,  ex3_pp2_2s_x_b,  ex3_pp2_2s_q_b, ex3_pp2_2s_lat_so , ex3_pp2_2s_lat_si  :std_ulogic_vector(220 to 264) ;


   signal ex4_pp5_0s_din, ex4_pp5_0s, ex4_pp5_0s_q_b, ex4_pp5_0s_lat_so , ex4_pp5_0s_lat_si  :std_ulogic_vector(196 to 264);
   signal ex4_pp5_0c_din, ex4_pp5_0c, ex4_pp5_0c_q_b, ex4_pp5_0c_lat_so , ex4_pp5_0c_lat_si  :std_ulogic_vector(196 to 263);

   signal ex2_bd_neg, ex2_bd_sh0, ex2_bd_sh1 :std_ulogic_vector(0 to 16) ;

   signal ex2_br_00_out :std_ulogic_vector(0 to 32);
   signal ex2_br_01_out :std_ulogic_vector(0 to 32);
   signal ex2_br_02_out :std_ulogic_vector(0 to 32);
   signal ex2_br_03_out :std_ulogic_vector(0 to 32);
   signal ex2_br_04_out :std_ulogic_vector(0 to 32);
   signal ex2_br_05_out :std_ulogic_vector(0 to 32);
   signal ex2_br_06_out :std_ulogic_vector(0 to 32);
   signal ex2_br_07_out :std_ulogic_vector(0 to 32);
   signal ex2_br_08_out :std_ulogic_vector(0 to 32);
   signal ex2_br_09_out :std_ulogic_vector(0 to 32);
   signal ex2_br_10_out :std_ulogic_vector(0 to 32);
   signal ex2_br_11_out :std_ulogic_vector(0 to 32);
   signal ex2_br_12_out :std_ulogic_vector(0 to 32);
   signal ex2_br_13_out :std_ulogic_vector(0 to 32);
   signal ex2_br_14_out :std_ulogic_vector(0 to 32);
   signal ex2_br_15_out :std_ulogic_vector(0 to 32);
   signal ex2_br_16_out :std_ulogic_vector(0 to 32);
   signal ex2_hot_one   :std_ulogic_vector(0 to 16);


  signal ex2_pp1_0c  :std_ulogic_vector(199 to 234) ;
  signal ex2_pp1_0s  :std_ulogic_vector(198 to 236) ;
  signal ex2_pp1_1c  :std_ulogic_vector(203 to 240) ;
  signal ex2_pp1_1s  :std_ulogic_vector(202 to 242) ;
  signal ex2_pp1_2c  :std_ulogic_vector(209 to 246) ;
  signal ex2_pp1_2s  :std_ulogic_vector(208 to 248) ;
  signal ex2_pp1_3c  :std_ulogic_vector(215 to 252) ;
  signal ex2_pp1_3s  :std_ulogic_vector(214 to 254) ;
  signal ex2_pp1_4c  :std_ulogic_vector(221 to 258) ;
  signal ex2_pp1_4s  :std_ulogic_vector(220 to 260) ;
  signal ex2_pp1_5c  :std_ulogic_vector(227 to 264) ;
  signal ex2_pp1_5s  :std_ulogic_vector(226 to 264) ;






  signal ex2_pp2_0c        :std_ulogic_vector(198 to 240) ;
  signal ex2_pp2_0s        :std_ulogic_vector(198 to 242) ;
  signal ex2_pp2_1c        :std_ulogic_vector(208 to 252) ;
  signal ex2_pp2_1s        :std_ulogic_vector(208 to 254) ;
  signal ex2_pp2_2c        :std_ulogic_vector(220 to 263) ;
  signal ex2_pp2_2s        :std_ulogic_vector(220 to 264) ;

  signal ex2_pp2_0k        :std_ulogic_vector(201 to 234) ;
  signal ex2_pp2_1k        :std_ulogic_vector(213 to 246) ;
  signal ex2_pp2_2k        :std_ulogic_vector(225 to 258) ;


  signal ex3_pp3_0c :std_ulogic_vector(197 to 242) ;
  signal ex3_pp3_0s :std_ulogic_vector(198 to 252) ;
  signal ex3_pp3_1c :std_ulogic_vector(219 to 262) ;
  signal ex3_pp3_1s :std_ulogic_vector(208 to 264) ;

  signal ex3_pp4_0k :std_ulogic_vector(207 to 242);
  signal ex3_pp4_0c :std_ulogic_vector(197 to 262);
  signal ex3_pp4_0s :std_ulogic_vector(197 to 264);

  signal ex3_pp5_0k :std_ulogic_vector(196 to 262);
  signal ex3_pp5_0c :std_ulogic_vector(195 to 263);
  signal ex3_pp5_0s :std_ulogic_vector(196 to 264);
  signal ex2_br_00_add   :std_ulogic;
  signal ex2_br_01_add   :std_ulogic;
  signal ex2_br_02_add   :std_ulogic;
  signal ex2_br_03_add   :std_ulogic;
  signal ex2_br_04_add   :std_ulogic;
  signal ex2_br_05_add   :std_ulogic;
  signal ex2_br_06_add   :std_ulogic;
  signal ex2_br_07_add   :std_ulogic;
  signal ex2_br_08_add   :std_ulogic;
  signal ex2_br_09_add   :std_ulogic;
  signal ex2_br_10_add   :std_ulogic;
  signal ex2_br_11_add   :std_ulogic;
  signal ex2_br_12_add   :std_ulogic;
  signal ex2_br_13_add   :std_ulogic;
  signal ex2_br_14_add   :std_ulogic;
  signal ex2_br_15_add   :std_ulogic;
  signal ex2_br_16_add   :std_ulogic;
  signal ex2_br_16_sub   :std_ulogic;

  signal ex2_pp0_00 :std_ulogic_vector(198 to 234) ;
  signal ex2_pp0_01 :std_ulogic_vector(200 to 236) ;
  signal ex2_pp0_02 :std_ulogic_vector(202 to 238) ;
  signal ex2_pp0_03 :std_ulogic_vector(204 to 240) ;
  signal ex2_pp0_04 :std_ulogic_vector(206 to 242) ;
  signal ex2_pp0_05 :std_ulogic_vector(208 to 244) ;
  signal ex2_pp0_06 :std_ulogic_vector(210 to 246) ;
  signal ex2_pp0_07 :std_ulogic_vector(212 to 248) ;
  signal ex2_pp0_08 :std_ulogic_vector(214 to 250) ;
  signal ex2_pp0_09 :std_ulogic_vector(216 to 252) ;
  signal ex2_pp0_10 :std_ulogic_vector(218 to 254) ;
  signal ex2_pp0_11 :std_ulogic_vector(220 to 256) ;
  signal ex2_pp0_12 :std_ulogic_vector(222 to 258) ;
  signal ex2_pp0_13 :std_ulogic_vector(224 to 260) ;
  signal ex2_pp0_14 :std_ulogic_vector(226 to 262) ;
  signal ex2_pp0_15 :std_ulogic_vector(228 to 264) ;
  signal ex2_pp0_16 :std_ulogic_vector(229 to 264) ;
  signal ex2_pp0_17 :std_ulogic_vector(232 to 232) ;

  signal ex2_br_00_sign_xor :std_ulogic;
  signal ex2_br_01_sign_xor :std_ulogic;
  signal ex2_br_02_sign_xor :std_ulogic;
  signal ex2_br_03_sign_xor :std_ulogic;
  signal ex2_br_04_sign_xor :std_ulogic;
  signal ex2_br_05_sign_xor :std_ulogic;
  signal ex2_br_06_sign_xor :std_ulogic;
  signal ex2_br_07_sign_xor :std_ulogic;
  signal ex2_br_08_sign_xor :std_ulogic;
  signal ex2_br_09_sign_xor :std_ulogic;
  signal ex2_br_10_sign_xor :std_ulogic;
  signal ex2_br_11_sign_xor :std_ulogic;
  signal ex2_br_12_sign_xor :std_ulogic;
  signal ex2_br_13_sign_xor :std_ulogic;
  signal ex2_br_14_sign_xor :std_ulogic;
  signal ex2_br_15_sign_xor :std_ulogic;
  signal ex2_br_16_sign_xor :std_ulogic;


  signal version :std_ulogic_vector(0 to 7) ;
  
begin

 version <= "00010001" ;

       --***********************************
       --** booth decoders
       --***********************************

 bd_00: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo_sign            ,--i--
     i1      => ex2_bd_lo(0)              ,--i--
     i2      => ex2_bd_lo(1)              ,--i--
     s_neg   => ex2_bd_neg(0)             ,--o--
     s_x     => ex2_bd_sh0(0)             ,--o--
     s_x2    => ex2_bd_sh1(0)            );--o--
 bd_01: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(1)              ,--i--
     i1      => ex2_bd_lo(2)              ,--i--
     i2      => ex2_bd_lo(3)              ,--i--
     s_neg   => ex2_bd_neg(1)             ,--o--
     s_x     => ex2_bd_sh0(1)             ,--o--
     s_x2    => ex2_bd_sh1(1)            );--o--
 bd_02: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(3)              ,--i--
     i1      => ex2_bd_lo(4)              ,--i--
     i2      => ex2_bd_lo(5)              ,--i--
     s_neg   => ex2_bd_neg(2)             ,--o--
     s_x     => ex2_bd_sh0(2)             ,--o--
     s_x2    => ex2_bd_sh1(2)            );--o--
 bd_03: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(5)              ,--i--
     i1      => ex2_bd_lo(6)              ,--i--
     i2      => ex2_bd_lo(7)              ,--i--
     s_neg   => ex2_bd_neg(3)             ,--o--
     s_x     => ex2_bd_sh0(3)             ,--o--
     s_x2    => ex2_bd_sh1(3)            );--o--
 bd_04: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(7)              ,--i--
     i1      => ex2_bd_lo(8)              ,--i--
     i2      => ex2_bd_lo(9)              ,--i--
     s_neg   => ex2_bd_neg(4)             ,--o--
     s_x     => ex2_bd_sh0(4)             ,--o--
     s_x2    => ex2_bd_sh1(4)            );--o--
 bd_05: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(9)              ,--i--
     i1      => ex2_bd_lo(10)             ,--i--
     i2      => ex2_bd_lo(11)             ,--i--
     s_neg   => ex2_bd_neg(5)             ,--o--
     s_x     => ex2_bd_sh0(5)             ,--o--
     s_x2    => ex2_bd_sh1(5)            );--o--
 bd_06: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(11)             ,--i--
     i1      => ex2_bd_lo(12)             ,--i--
     i2      => ex2_bd_lo(13)             ,--i--
     s_neg   => ex2_bd_neg(6)             ,--o--
     s_x     => ex2_bd_sh0(6)             ,--o--
     s_x2    => ex2_bd_sh1(6)            );--o--
 bd_07: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(13)             ,--i--
     i1      => ex2_bd_lo(14)             ,--i--
     i2      => ex2_bd_lo(15)             ,--i--
     s_neg   => ex2_bd_neg(7)             ,--o--
     s_x     => ex2_bd_sh0(7)             ,--o--
     s_x2    => ex2_bd_sh1(7)            );--o--
 bd_08: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(15)             ,--i--
     i1      => ex2_bd_lo(16)             ,--i--
     i2      => ex2_bd_lo(17)             ,--i--
     s_neg   => ex2_bd_neg(8)             ,--o--
     s_x     => ex2_bd_sh0(8)             ,--o--
     s_x2    => ex2_bd_sh1(8)            );--o--
 bd_09: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(17)             ,--i--
     i1      => ex2_bd_lo(18)             ,--i--
     i2      => ex2_bd_lo(19)             ,--i--
     s_neg   => ex2_bd_neg(9)             ,--o--
     s_x     => ex2_bd_sh0(9)             ,--o--
     s_x2    => ex2_bd_sh1(9)            );--o--
 bd_10: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(19)             ,--i--
     i1      => ex2_bd_lo(20)             ,--i--
     i2      => ex2_bd_lo(21)             ,--i--
     s_neg   => ex2_bd_neg(10)            ,--o--
     s_x     => ex2_bd_sh0(10)            ,--o--
     s_x2    => ex2_bd_sh1(10)           );--o--
 bd_11: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(21)             ,--i--
     i1      => ex2_bd_lo(22)             ,--i--
     i2      => ex2_bd_lo(23)             ,--i--
     s_neg   => ex2_bd_neg(11)            ,--o--
     s_x     => ex2_bd_sh0(11)            ,--o--
     s_x2    => ex2_bd_sh1(11)           );--o--
 bd_12: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(23)             ,--i--
     i1      => ex2_bd_lo(24)             ,--i--
     i2      => ex2_bd_lo(25)             ,--i--
     s_neg   => ex2_bd_neg(12)            ,--o--
     s_x     => ex2_bd_sh0(12)            ,--o--
     s_x2    => ex2_bd_sh1(12)           );--o--
 bd_13: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(25)             ,--i--
     i1      => ex2_bd_lo(26)             ,--i--
     i2      => ex2_bd_lo(27)             ,--i--
     s_neg   => ex2_bd_neg(13)            ,--o--
     s_x     => ex2_bd_sh0(13)            ,--o--
     s_x2    => ex2_bd_sh1(13)           );--o--
 bd_14: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(27)             ,--i--
     i1      => ex2_bd_lo(28)             ,--i--
     i2      => ex2_bd_lo(29)             ,--i--
     s_neg   => ex2_bd_neg(14)            ,--o--
     s_x     => ex2_bd_sh0(14)            ,--o--
     s_x2    => ex2_bd_sh1(14)           );--o--
 bd_15: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(29)             ,--i--
     i1      => ex2_bd_lo(30)             ,--i--
     i2      => ex2_bd_lo(31)             ,--i--
     s_neg   => ex2_bd_neg(15)            ,--o--
     s_x     => ex2_bd_sh0(15)            ,--o--
     s_x2    => ex2_bd_sh1(15)           );--o--
 bd_16: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(31)             ,--i--
     i1      => tidn                      ,--i--
     i2      => tidn                      ,--i--
     s_neg   => ex2_bd_neg(16)            ,--o--
     s_x     => ex2_bd_sh0(16)            ,--o--
     s_x2    => ex2_bd_sh1(16)           );--o--

       --***********************************
       --** booth muxes
       --***********************************

br_00: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(0)             ,--i--
     s_x          => ex2_bd_sh0(0)             ,--i--
     s_x2         => ex2_bd_sh1(0)             ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_00_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(0)           );--o--
 br_01: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(1)             ,--i--
     s_x          => ex2_bd_sh0(1)             ,--i--
     s_x2         => ex2_bd_sh1(1)             ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_01_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(1)           );--o--
 br_02: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(2)             ,--i--
     s_x          => ex2_bd_sh0(2)             ,--i--
     s_x2         => ex2_bd_sh1(2)             ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_02_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(2)           );--o--
 br_03: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(3)             ,--i--
     s_x          => ex2_bd_sh0(3)             ,--i--
     s_x2         => ex2_bd_sh1(3)             ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_03_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(3)           );--o--
 br_04: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(4)             ,--i--
     s_x          => ex2_bd_sh0(4)             ,--i--
     s_x2         => ex2_bd_sh1(4)             ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_04_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(4)           );--o--
 br_05: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(5)             ,--i--
     s_x          => ex2_bd_sh0(5)             ,--i--
     s_x2         => ex2_bd_sh1(5)             ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_05_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(5)           );--o--
 br_06: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(6)             ,--i--
     s_x          => ex2_bd_sh0(6)             ,--i--
     s_x2         => ex2_bd_sh1(6)             ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_06_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(6)           );--o--
 br_07: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(7)             ,--i--
     s_x          => ex2_bd_sh0(7)             ,--i--
     s_x2         => ex2_bd_sh1(7)             ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_07_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(7)           );--o--
 br_08: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(8)             ,--i--
     s_x          => ex2_bd_sh0(8)             ,--i--
     s_x2         => ex2_bd_sh1(8)             ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_08_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(8)           );--o--
 br_09: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(9)             ,--i--
     s_x          => ex2_bd_sh0(9)             ,--i--
     s_x2         => ex2_bd_sh1(9)             ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_09_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(9)           );--o--
 br_10: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(10)            ,--i--
     s_x          => ex2_bd_sh0(10)            ,--i--
     s_x2         => ex2_bd_sh1(10)            ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_10_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(10)          );--o--
 br_11: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(11)            ,--i--
     s_x          => ex2_bd_sh0(11)            ,--i--
     s_x2         => ex2_bd_sh1(11)            ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_11_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(11)          );--o--
 br_12: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(12)            ,--i--
     s_x          => ex2_bd_sh0(12)            ,--i--
     s_x2         => ex2_bd_sh1(12)            ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_12_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(12)          );--o--
 br_13: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(13)            ,--i--
     s_x          => ex2_bd_sh0(13)            ,--i--
     s_x2         => ex2_bd_sh1(13)            ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_13_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(13)          );--o--
 br_14: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(14)            ,--i--
     s_x          => ex2_bd_sh0(14)            ,--i--
     s_x2         => ex2_bd_sh1(14)            ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_14_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(14)          );--o--
 br_15: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(15)            ,--i--
     s_x          => ex2_bd_sh0(15)            ,--i--
     s_x2         => ex2_bd_sh1(15)            ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_15_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(15)          );--o--
 br_16: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(16)            ,--i--
     s_x          => ex2_bd_sh0(16)            ,--i--
     s_x2         => ex2_bd_sh1(16)            ,--i--
     sign_bit_adj => ex2_bs_lo_sign            ,--i--
     x            => ex2_bs_lo(0 to 31)        ,--i--
     q            => ex2_br_16_out(0 to 32)    ,--o--
     hot_one      => ex2_hot_one(16)          );--o--







  u_br_00_sx: ex2_br_00_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(0) ;
  u_br_01_sx: ex2_br_01_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(1) ;
  u_br_02_sx: ex2_br_02_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(2) ;
  u_br_03_sx: ex2_br_03_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(3) ;
  u_br_04_sx: ex2_br_04_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(4) ;
  u_br_05_sx: ex2_br_05_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(5) ;
  u_br_06_sx: ex2_br_06_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(6) ;
  u_br_07_sx: ex2_br_07_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(7) ;
  u_br_08_sx: ex2_br_08_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(8) ;
  u_br_09_sx: ex2_br_09_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(9) ;
  u_br_10_sx: ex2_br_10_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(10) ;
  u_br_11_sx: ex2_br_11_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(11) ;
  u_br_12_sx: ex2_br_12_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(12) ;
  u_br_13_sx: ex2_br_13_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(13) ;
  u_br_14_sx: ex2_br_14_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(14) ;
  u_br_15_sx: ex2_br_15_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(15) ;
  u_br_16_sx: ex2_br_16_sign_xor <= ex2_bs_lo_sign xor ex2_bd_neg(16) ;



  u_br_00_add: ex2_br_00_add   <= not( ex2_br_00_sign_xor and (ex2_bd_sh0(0)  or ex2_bd_sh1(0)  ) ) ;  -- add
  u_br_01_add: ex2_br_01_add   <= not( ex2_br_01_sign_xor and (ex2_bd_sh0(1)  or ex2_bd_sh1(1)  ) ) ;  -- add
  u_br_02_add: ex2_br_02_add   <= not( ex2_br_02_sign_xor and (ex2_bd_sh0(2)  or ex2_bd_sh1(2)  ) ) ;  -- add
  u_br_03_add: ex2_br_03_add   <= not( ex2_br_03_sign_xor and (ex2_bd_sh0(3)  or ex2_bd_sh1(3)  ) ) ;  -- add
  u_br_04_add: ex2_br_04_add   <= not( ex2_br_04_sign_xor and (ex2_bd_sh0(4)  or ex2_bd_sh1(4)  ) ) ;  -- add
  u_br_05_add: ex2_br_05_add   <= not( ex2_br_05_sign_xor and (ex2_bd_sh0(5)  or ex2_bd_sh1(5)  ) ) ;  -- add
  u_br_06_add: ex2_br_06_add   <= not( ex2_br_06_sign_xor and (ex2_bd_sh0(6)  or ex2_bd_sh1(6)  ) ) ;  -- add
  u_br_07_add: ex2_br_07_add   <= not( ex2_br_07_sign_xor and (ex2_bd_sh0(7)  or ex2_bd_sh1(7)  ) ) ;  -- add
  u_br_08_add: ex2_br_08_add   <= not( ex2_br_08_sign_xor and (ex2_bd_sh0(8)  or ex2_bd_sh1(8)  ) ) ;  -- add
  u_br_09_add: ex2_br_09_add   <= not( ex2_br_09_sign_xor and (ex2_bd_sh0(9)  or ex2_bd_sh1(9)  ) ) ;  -- add
  u_br_10_add: ex2_br_10_add   <= not( ex2_br_10_sign_xor and (ex2_bd_sh0(10) or ex2_bd_sh1(10) ) ) ;  -- add
  u_br_11_add: ex2_br_11_add   <= not( ex2_br_11_sign_xor and (ex2_bd_sh0(11) or ex2_bd_sh1(11) ) ) ;  -- add
  u_br_12_add: ex2_br_12_add   <= not( ex2_br_12_sign_xor and (ex2_bd_sh0(12) or ex2_bd_sh1(12) ) ) ;  -- add
  u_br_13_add: ex2_br_13_add   <= not( ex2_br_13_sign_xor and (ex2_bd_sh0(13) or ex2_bd_sh1(13) ) ) ;  -- add
  u_br_14_add: ex2_br_14_add   <= not( ex2_br_14_sign_xor and (ex2_bd_sh0(14) or ex2_bd_sh1(14) ) ) ;  -- add
  u_br_15_add: ex2_br_15_add   <= not( ex2_br_15_sign_xor and (ex2_bd_sh0(15) or ex2_bd_sh1(15) ) ) ;  -- add
  u_br_16_add: ex2_br_16_add   <= not( ex2_br_16_sign_xor and (ex2_bd_sh0(16) or ex2_bd_sh1(16) ) ) ;  -- add
  u_br_16_sub: ex2_br_16_sub   <=      ex2_br_16_sign_xor and (ex2_bd_sh0(16) or ex2_bd_sh1(16) )   ;  -- sub



  ex2_pp0_00(198)          <= tiup                     ;
  ex2_pp0_00(199)          <= ex2_br_00_add            ;
  ex2_pp0_00(200 to 232)   <= ex2_br_00_out(0 to 32)   ;
  ex2_pp0_00(233)          <= tidn                     ;
  ex2_pp0_00(234)          <= ex2_hot_one(1)           ;

  ex2_pp0_01(200)          <= tiup                     ;
  ex2_pp0_01(201)          <= ex2_br_01_add            ;
  ex2_pp0_01(202 to 234)   <= ex2_br_01_out(0 to 32)   ;
  ex2_pp0_01(235)          <= tidn                     ;
  ex2_pp0_01(236)          <= ex2_hot_one(2)           ;

  ex2_pp0_02(202)          <= tiup                     ;
  ex2_pp0_02(203)          <= ex2_br_02_add            ;
  ex2_pp0_02(204 to 236)   <= ex2_br_02_out(0 to 32)   ;
  ex2_pp0_02(237)          <= tidn                     ;
  ex2_pp0_02(238)          <= ex2_hot_one(3)           ;

  ex2_pp0_03(204)          <= tiup                     ;
  ex2_pp0_03(205)          <= ex2_br_03_add            ;
  ex2_pp0_03(206 to 238)   <= ex2_br_03_out(0 to 32)   ;
  ex2_pp0_03(239)          <= tidn                     ;
  ex2_pp0_03(240)          <= ex2_hot_one(4)           ;

  ex2_pp0_04(206)          <= tiup                     ;
  ex2_pp0_04(207)          <= ex2_br_04_add            ;
  ex2_pp0_04(208 to 240)   <= ex2_br_04_out(0 to 32)   ;
  ex2_pp0_04(241)          <= tidn                     ;
  ex2_pp0_04(242)          <= ex2_hot_one(5)           ;

  ex2_pp0_05(208)          <= tiup                     ;
  ex2_pp0_05(209)          <= ex2_br_05_add            ;
  ex2_pp0_05(210 to 242)   <= ex2_br_05_out(0 to 32)   ;
  ex2_pp0_05(243)          <= tidn                     ;
  ex2_pp0_05(244)          <= ex2_hot_one(6)           ;

  ex2_pp0_06(210)          <= tiup                     ;
  ex2_pp0_06(211)          <= ex2_br_06_add            ;
  ex2_pp0_06(212 to 244)   <= ex2_br_06_out(0 to 32)   ;
  ex2_pp0_06(245)          <= tidn                     ;
  ex2_pp0_06(246)          <= ex2_hot_one(7)           ;

  ex2_pp0_07(212)          <= tiup                     ;
  ex2_pp0_07(213)          <= ex2_br_07_add            ;
  ex2_pp0_07(214 to 246)   <= ex2_br_07_out(0 to 32)   ;
  ex2_pp0_07(247)          <= tidn                     ;
  ex2_pp0_07(248)          <= ex2_hot_one(8)           ;

  ex2_pp0_08(214)          <= tiup                     ;
  ex2_pp0_08(215)          <= ex2_br_08_add            ;
  ex2_pp0_08(216 to 248)   <= ex2_br_08_out(0 to 32)   ;
  ex2_pp0_08(249)          <= tidn                     ;
  ex2_pp0_08(250)          <= ex2_hot_one(9)           ;

  ex2_pp0_09(216)          <= tiup                     ;
  ex2_pp0_09(217)          <= ex2_br_09_add            ;
  ex2_pp0_09(218 to 250)   <= ex2_br_09_out(0 to 32)   ;
  ex2_pp0_09(251)          <= tidn                     ;
  ex2_pp0_09(252)          <= ex2_hot_one(10)          ;

  ex2_pp0_10(218)          <= tiup                     ;
  ex2_pp0_10(219)          <= ex2_br_10_add            ;
  ex2_pp0_10(220 to 252)   <= ex2_br_10_out(0 to 32)   ;
  ex2_pp0_10(253)          <= tidn                     ;
  ex2_pp0_10(254)          <= ex2_hot_one(11)          ;

  ex2_pp0_11(220)          <= tiup                     ;
  ex2_pp0_11(221)          <= ex2_br_11_add            ;
  ex2_pp0_11(222 to 254)   <= ex2_br_11_out(0 to 32)   ;
  ex2_pp0_11(255)          <= tidn                     ;
  ex2_pp0_11(256)          <= ex2_hot_one(12)          ;

  ex2_pp0_12(222)          <= tiup                     ;
  ex2_pp0_12(223)          <= ex2_br_12_add            ;
  ex2_pp0_12(224 to 256)   <= ex2_br_12_out(0 to 32)   ;
  ex2_pp0_12(257)          <= tidn                     ;
  ex2_pp0_12(258)          <= ex2_hot_one(13)          ;

  ex2_pp0_13(224)          <= tiup                     ;
  ex2_pp0_13(225)          <= ex2_br_13_add            ;
  ex2_pp0_13(226 to 258)   <= ex2_br_13_out(0 to 32)   ;
  ex2_pp0_13(259)          <= tidn                     ;
  ex2_pp0_13(260)          <= ex2_hot_one(14)          ;

  ex2_pp0_14(226)          <= tiup                     ;
  ex2_pp0_14(227)          <= ex2_br_14_add            ;
  ex2_pp0_14(228 to 260)   <= ex2_br_14_out(0 to 32)   ;
  ex2_pp0_14(261)          <= tidn                     ;
  ex2_pp0_14(262)          <= ex2_hot_one(15)          ;

  ex2_pp0_15(228)          <= tiup                     ;
  ex2_pp0_15(229)          <= ex2_br_15_add            ;
  ex2_pp0_15(230 to 262)   <= ex2_br_15_out(0 to 32)   ;
  ex2_pp0_15(263)          <= tidn                     ;
  ex2_pp0_15(264)          <= ex2_hot_one(16)          ;

  ex2_pp0_16(229)          <= ex2_br_16_add            ;
  ex2_pp0_16(230)          <= ex2_br_16_sub            ;
  ex2_pp0_16(231)          <= ex2_br_16_sub            ;
  ex2_pp0_16(232 to 264)   <= ex2_br_16_out(0 to 32)   ;

  ex2_pp0_17(232)          <= ex2_hot_one(0)           ;




       --***********************************
       --** compression level 1
       --***********************************
--===    g1 : for i in 196 to 264 generate
--===        csa1_0: entity work.c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
--===           a       => ex2_pp0_17(i)     ,--i--
--===           b       => ex2_pp0_00(i)     ,--i--
--===           c       => ex2_pp0_01(i)     ,--i--
--===           sum     => ex2_pp1_0s(i)     ,--o--
--===           car     => ex2_pp1_0cex2_pp1_0c(23(i-1)  );--o--
--===        csa1_1: entity work.c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
--===           a       => ex2_pp0_02(i)     ,--i--
--===           b       => ex2_pp0_03(i)     ,--i--
--===           c       => ex2_pp0_04(i)     ,--i--
--===           sum     => ex2_pp1_1s(i)     ,--o--
--===           car     => ex2_pp1_1c(i-1)  );--o--
--===        csa1_2: entity work.c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
--===           a       => ex2_pp0_05(i)     ,--i--
--===           b       => ex2_pp0_06(i)     ,--i--
--===           c       => ex2_pp0_07(i)     ,--i--
--===           sum     => ex2_pp1_2s(i)     ,--o--
--===           car     => ex2_pp1_2c(i-1)  );--o--
--===        csa1_3: entity work.c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
--===           a       => ex2_pp0_08(i)     ,--i--
--===           b       => ex2_pp0_09(i)     ,--i--
--===           c       => ex2_pp0_10(i)     ,--i--
--===           sum     => ex2_pp1_3s(i)     ,--o--
--===           car     => ex2_pp1_3c(i-1)  );--o--
--===        csa1_4: entity work.c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
--===           a       => ex2_pp0_11(i)     ,--i--
--===           b       => ex2_pp0_12(i)     ,--i--
--===           c       => ex2_pp0_13(i)     ,--i--
--===           sum     => ex2_pp1_4s(i)     ,--o--
--===           car     => ex2_pp1_4c(i-1)  );--o--
--===        csa1_5: entity work.c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
--===           a       => ex2_pp0_14(i)     ,--i--
--===           b       => ex2_pp0_15(i)     ,--i--
--===           c       => ex2_pp0_16(i)     ,--i--
--===           sum     => ex2_pp1_5s(i)     ,--o--
--===           car     => ex2_pp1_5c(i-1)  );--o--
--===    end generate;
--===       ex2_pp1_0c(264) <= tidn ;
--===       ex2_pp1_1c(264) <= tidn ;
--===       ex2_pp1_2c(264) <= tidn ;
--===       ex2_pp1_3c(264) <= tidn ;
--===       ex2_pp1_4c(264) <= tidn ;
--===       ex2_pp1_5c(264) <= tidn ;


  ------- <csa1_0> -----

 ex2_pp1_0s(236)                  <= ex2_pp0_01(236)                  ; --pass_s
 ex2_pp1_0s(235)                  <= tidn                             ; --pass_none
 ex2_pp1_0c(234)                  <= ex2_pp0_01(234)                  ; --pass_cs
 ex2_pp1_0s(234)                  <= ex2_pp0_00(234)                  ; --pass_cs
 ex2_pp1_0c(233)                  <= tidn                            ; --pass_s
 ex2_pp1_0s(233)                  <= ex2_pp0_01(233)                  ; --pass_s
 ex2_pp1_0c(232)                  <= tidn                             ; --wr_csa32

--  pp1_02_csa_71: entity work.fuq_csa22_h2(fuq_csa22_h2)    port map (
--  clib.c_prism_csa22  work.xuq_alu_mult_csa22

    csa1_0_232: entity clib.c_prism_csa32 port map( -- MLT32_X1_A12TH
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_00(232)                   ,--i--
        b            => ex2_pp0_01(232)                   ,--i--
        c            => ex2_pp0_17(232)                   ,--i--
        sum          => ex2_pp1_0s(232)                   ,--o--
        car          => ex2_pp1_0c(231)                  );--o--
    csa1_0_231: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(231)                   ,--i--
        b            => ex2_pp0_01(231)                   ,--i--
        sum          => ex2_pp1_0s(231)                   ,--o--
        car          => ex2_pp1_0c(230)                  );--o--
    csa1_0_230: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(230)                   ,--i--
        b            => ex2_pp0_01(230)                   ,--i--
        sum          => ex2_pp1_0s(230)                   ,--o--
        car          => ex2_pp1_0c(229)                  );--o--
    csa1_0_229: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(229)                   ,--i--
        b            => ex2_pp0_01(229)                   ,--i--
        sum          => ex2_pp1_0s(229)                   ,--o--
        car          => ex2_pp1_0c(228)                  );--o--
    csa1_0_228: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(228)                   ,--i--
        b            => ex2_pp0_01(228)                   ,--i--
        sum          => ex2_pp1_0s(228)                   ,--o--
        car          => ex2_pp1_0c(227)                  );--o--
    csa1_0_227: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(227)                   ,--i--
        b            => ex2_pp0_01(227)                   ,--i--
        sum          => ex2_pp1_0s(227)                   ,--o--
        car          => ex2_pp1_0c(226)                  );--o--
    csa1_0_226: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(226)                   ,--i--
        b            => ex2_pp0_01(226)                   ,--i--
        sum          => ex2_pp1_0s(226)                   ,--o--
        car          => ex2_pp1_0c(225)                  );--o--
    csa1_0_225: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(225)                   ,--i--
        b            => ex2_pp0_01(225)                   ,--i--
        sum          => ex2_pp1_0s(225)                   ,--o--
        car          => ex2_pp1_0c(224)                  );--o--
    csa1_0_224: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(224)                   ,--i--
        b            => ex2_pp0_01(224)                   ,--i--
        sum          => ex2_pp1_0s(224)                   ,--o--
        car          => ex2_pp1_0c(223)                  );--o--
    csa1_0_223: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(223)                   ,--i--
        b            => ex2_pp0_01(223)                   ,--i--
        sum          => ex2_pp1_0s(223)                   ,--o--
        car          => ex2_pp1_0c(222)                  );--o--
    csa1_0_222: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(222)                   ,--i--
        b            => ex2_pp0_01(222)                   ,--i--
        sum          => ex2_pp1_0s(222)                   ,--o--
        car          => ex2_pp1_0c(221)                  );--o--
    csa1_0_221: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(221)                   ,--i--
        b            => ex2_pp0_01(221)                   ,--i--
        sum          => ex2_pp1_0s(221)                   ,--o--
        car          => ex2_pp1_0c(220)                  );--o--
    csa1_0_220: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(220)                   ,--i--
        b            => ex2_pp0_01(220)                   ,--i--
        sum          => ex2_pp1_0s(220)                   ,--o--
        car          => ex2_pp1_0c(219)                  );--o--
    csa1_0_219: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(219)                   ,--i--
        b            => ex2_pp0_01(219)                   ,--i--
        sum          => ex2_pp1_0s(219)                   ,--o--
        car          => ex2_pp1_0c(218)                  );--o--
    csa1_0_218: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(218)                   ,--i--
        b            => ex2_pp0_01(218)                   ,--i--
        sum          => ex2_pp1_0s(218)                   ,--o--
        car          => ex2_pp1_0c(217)                  );--o--
    csa1_0_217: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(217)                   ,--i--
        b            => ex2_pp0_01(217)                   ,--i--
        sum          => ex2_pp1_0s(217)                   ,--o--
        car          => ex2_pp1_0c(216)                  );--o--
    csa1_0_216: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(216)                   ,--i--
        b            => ex2_pp0_01(216)                   ,--i--
        sum          => ex2_pp1_0s(216)                   ,--o--
        car          => ex2_pp1_0c(215)                  );--o--
    csa1_0_215: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(215)                   ,--i--
        b            => ex2_pp0_01(215)                   ,--i--
        sum          => ex2_pp1_0s(215)                   ,--o--
        car          => ex2_pp1_0c(214)                  );--o--
    csa1_0_214: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(214)                   ,--i--
        b            => ex2_pp0_01(214)                   ,--i--
        sum          => ex2_pp1_0s(214)                   ,--o--
        car          => ex2_pp1_0c(213)                  );--o--
    csa1_0_213: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(213)                   ,--i--
        b            => ex2_pp0_01(213)                   ,--i--
        sum          => ex2_pp1_0s(213)                   ,--o--
        car          => ex2_pp1_0c(212)                  );--o--
    csa1_0_212: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(212)                   ,--i--
        b            => ex2_pp0_01(212)                   ,--i--
        sum          => ex2_pp1_0s(212)                   ,--o--
        car          => ex2_pp1_0c(211)                  );--o--
    csa1_0_211: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(211)                   ,--i--
        b            => ex2_pp0_01(211)                   ,--i--
        sum          => ex2_pp1_0s(211)                   ,--o--
        car          => ex2_pp1_0c(210)                  );--o--
    csa1_0_210: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(210)                   ,--i--
        b            => ex2_pp0_01(210)                   ,--i--
        sum          => ex2_pp1_0s(210)                   ,--o--
        car          => ex2_pp1_0c(209)                  );--o--
    csa1_0_209: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(209)                   ,--i--
        b            => ex2_pp0_01(209)                   ,--i--
        sum          => ex2_pp1_0s(209)                   ,--o--
        car          => ex2_pp1_0c(208)                  );--o--
    csa1_0_208: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(208)                   ,--i--
        b            => ex2_pp0_01(208)                   ,--i--
        sum          => ex2_pp1_0s(208)                   ,--o--
        car          => ex2_pp1_0c(207)                  );--o--
    csa1_0_207: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(207)                   ,--i--
        b            => ex2_pp0_01(207)                   ,--i--
        sum          => ex2_pp1_0s(207)                   ,--o--
        car          => ex2_pp1_0c(206)                  );--o--
    csa1_0_206: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(206)                   ,--i--
        b            => ex2_pp0_01(206)                   ,--i--
        sum          => ex2_pp1_0s(206)                   ,--o--
        car          => ex2_pp1_0c(205)                  );--o--
    csa1_0_205: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(205)                   ,--i--
        b            => ex2_pp0_01(205)                   ,--i--
        sum          => ex2_pp1_0s(205)                   ,--o--
        car          => ex2_pp1_0c(204)                  );--o--
    csa1_0_204: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(204)                   ,--i--
        b            => ex2_pp0_01(204)                   ,--i--
        sum          => ex2_pp1_0s(204)                   ,--o--
        car          => ex2_pp1_0c(203)                  );--o--
    csa1_0_203: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(203)                   ,--i--
        b            => ex2_pp0_01(203)                   ,--i--
        sum          => ex2_pp1_0s(203)                   ,--o--
        car          => ex2_pp1_0c(202)                  );--o--
    csa1_0_202: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(202)                   ,--i--
        b            => ex2_pp0_01(202)                   ,--i--
        sum          => ex2_pp1_0s(202)                   ,--o--
        car          => ex2_pp1_0c(201)                  );--o--
    csa1_0_201: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(201)                   ,--i--
        b            => ex2_pp0_01(201)                   ,--i--
        sum          => ex2_pp1_0s(201)                   ,--o--
        car          => ex2_pp1_0c(200)                  );--o--
    csa1_0_200: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(200)                   ,--i--
        b            => ex2_pp0_01(200)                   ,--i--
        sum          => ex2_pp1_0s(200)                   ,--o--
        car          => ex2_pp1_0c(199)                  );--o--
 ex2_pp1_0s(199)                  <= ex2_pp0_00(199)                  ; --pass_x_s
 ex2_pp1_0s(198)                  <= ex2_pp0_00(198)                  ; --pass_s





 ------- <csa1_1> -----

 ex2_pp1_1s(242)                  <= ex2_pp0_04(242)                  ; --pass_s
 ex2_pp1_1s(241)                  <= tidn                             ; --pass_none
 ex2_pp1_1c(240)                  <= ex2_pp0_04(240)                  ; --pass_cs
 ex2_pp1_1s(240)                  <= ex2_pp0_03(240)                  ; --pass_cs
 ex2_pp1_1c(239)                  <= tidn                            ; --pass_s
 ex2_pp1_1s(239)                  <= ex2_pp0_04(239)                  ; --pass_s
 ex2_pp1_1c(238)                  <= tidn                             ; --wr_csa32
    csa1_1_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(238)                   ,--i--
        b            => ex2_pp0_03(238)                   ,--i--
        c            => ex2_pp0_04(238)                   ,--i--
        sum          => ex2_pp1_1s(238)                   ,--o--
        car          => ex2_pp1_1c(237)                  );--o--
    csa1_1_237: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_03(237)                   ,--i--
        b            => ex2_pp0_04(237)                   ,--i--
        sum          => ex2_pp1_1s(237)                   ,--o--
        car          => ex2_pp1_1c(236)                  );--o--
    csa1_1_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(236)                   ,--i--
        b            => ex2_pp0_03(236)                   ,--i--
        c            => ex2_pp0_04(236)                   ,--i--
        sum          => ex2_pp1_1s(236)                   ,--o--
        car          => ex2_pp1_1c(235)                  );--o--
    csa1_1_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(235)                   ,--i--
        b            => ex2_pp0_03(235)                   ,--i--
        c            => ex2_pp0_04(235)                   ,--i--
        sum          => ex2_pp1_1s(235)                   ,--o--
        car          => ex2_pp1_1c(234)                  );--o--
    csa1_1_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(234)                   ,--i--
        b            => ex2_pp0_03(234)                   ,--i--
        c            => ex2_pp0_04(234)                   ,--i--
        sum          => ex2_pp1_1s(234)                   ,--o--
        car          => ex2_pp1_1c(233)                  );--o--
    csa1_1_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(233)                   ,--i--
        b            => ex2_pp0_03(233)                   ,--i--
        c            => ex2_pp0_04(233)                   ,--i--
        sum          => ex2_pp1_1s(233)                   ,--o--
        car          => ex2_pp1_1c(232)                  );--o--
    csa1_1_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(232)                   ,--i--
        b            => ex2_pp0_03(232)                   ,--i--
        c            => ex2_pp0_04(232)                   ,--i--
        sum          => ex2_pp1_1s(232)                   ,--o--
        car          => ex2_pp1_1c(231)                  );--o--
    csa1_1_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(231)                   ,--i--
        b            => ex2_pp0_03(231)                   ,--i--
        c            => ex2_pp0_04(231)                   ,--i--
        sum          => ex2_pp1_1s(231)                   ,--o--
        car          => ex2_pp1_1c(230)                  );--o--
    csa1_1_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(230)                   ,--i--
        b            => ex2_pp0_03(230)                   ,--i--
        c            => ex2_pp0_04(230)                   ,--i--
        sum          => ex2_pp1_1s(230)                   ,--o--
        car          => ex2_pp1_1c(229)                  );--o--
    csa1_1_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(229)                   ,--i--
        b            => ex2_pp0_03(229)                   ,--i--
        c            => ex2_pp0_04(229)                   ,--i--
        sum          => ex2_pp1_1s(229)                   ,--o--
        car          => ex2_pp1_1c(228)                  );--o--
    csa1_1_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(228)                   ,--i--
        b            => ex2_pp0_03(228)                   ,--i--
        c            => ex2_pp0_04(228)                   ,--i--
        sum          => ex2_pp1_1s(228)                   ,--o--
        car          => ex2_pp1_1c(227)                  );--o--
    csa1_1_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(227)                   ,--i--
        b            => ex2_pp0_03(227)                   ,--i--
        c            => ex2_pp0_04(227)                   ,--i--
        sum          => ex2_pp1_1s(227)                   ,--o--
        car          => ex2_pp1_1c(226)                  );--o--
    csa1_1_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(226)                   ,--i--
        b            => ex2_pp0_03(226)                   ,--i--
        c            => ex2_pp0_04(226)                   ,--i--
        sum          => ex2_pp1_1s(226)                   ,--o--
        car          => ex2_pp1_1c(225)                  );--o--
    csa1_1_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(225)                   ,--i--
        b            => ex2_pp0_03(225)                   ,--i--
        c            => ex2_pp0_04(225)                   ,--i--
        sum          => ex2_pp1_1s(225)                   ,--o--
        car          => ex2_pp1_1c(224)                  );--o--
    csa1_1_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(224)                   ,--i--
        b            => ex2_pp0_03(224)                   ,--i--
        c            => ex2_pp0_04(224)                   ,--i--
        sum          => ex2_pp1_1s(224)                   ,--o--
        car          => ex2_pp1_1c(223)                  );--o--
    csa1_1_223: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(223)                   ,--i--
        b            => ex2_pp0_03(223)                   ,--i--
        c            => ex2_pp0_04(223)                   ,--i--
        sum          => ex2_pp1_1s(223)                   ,--o--
        car          => ex2_pp1_1c(222)                  );--o--
    csa1_1_222: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(222)                   ,--i--
        b            => ex2_pp0_03(222)                   ,--i--
        c            => ex2_pp0_04(222)                   ,--i--
        sum          => ex2_pp1_1s(222)                   ,--o--
        car          => ex2_pp1_1c(221)                  );--o--
    csa1_1_221: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(221)                   ,--i--
        b            => ex2_pp0_03(221)                   ,--i--
        c            => ex2_pp0_04(221)                   ,--i--
        sum          => ex2_pp1_1s(221)                   ,--o--
        car          => ex2_pp1_1c(220)                  );--o--
    csa1_1_220: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(220)                   ,--i--
        b            => ex2_pp0_03(220)                   ,--i--
        c            => ex2_pp0_04(220)                   ,--i--
        sum          => ex2_pp1_1s(220)                   ,--o--
        car          => ex2_pp1_1c(219)                  );--o--
    csa1_1_219: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(219)                   ,--i--
        b            => ex2_pp0_03(219)                   ,--i--
        c            => ex2_pp0_04(219)                   ,--i--
        sum          => ex2_pp1_1s(219)                   ,--o--
        car          => ex2_pp1_1c(218)                  );--o--
    csa1_1_218: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(218)                   ,--i--
        b            => ex2_pp0_03(218)                   ,--i--
        c            => ex2_pp0_04(218)                   ,--i--
        sum          => ex2_pp1_1s(218)                   ,--o--
        car          => ex2_pp1_1c(217)                  );--o--
    csa1_1_217: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(217)                   ,--i--
        b            => ex2_pp0_03(217)                   ,--i--
        c            => ex2_pp0_04(217)                   ,--i--
        sum          => ex2_pp1_1s(217)                   ,--o--
        car          => ex2_pp1_1c(216)                  );--o--
    csa1_1_216: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(216)                   ,--i--
        b            => ex2_pp0_03(216)                   ,--i--
        c            => ex2_pp0_04(216)                   ,--i--
        sum          => ex2_pp1_1s(216)                   ,--o--
        car          => ex2_pp1_1c(215)                  );--o--
    csa1_1_215: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(215)                   ,--i--
        b            => ex2_pp0_03(215)                   ,--i--
        c            => ex2_pp0_04(215)                   ,--i--
        sum          => ex2_pp1_1s(215)                   ,--o--
        car          => ex2_pp1_1c(214)                  );--o--
    csa1_1_214: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(214)                   ,--i--
        b            => ex2_pp0_03(214)                   ,--i--
        c            => ex2_pp0_04(214)                   ,--i--
        sum          => ex2_pp1_1s(214)                   ,--o--
        car          => ex2_pp1_1c(213)                  );--o--
    csa1_1_213: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(213)                   ,--i--
        b            => ex2_pp0_03(213)                   ,--i--
        c            => ex2_pp0_04(213)                   ,--i--
        sum          => ex2_pp1_1s(213)                   ,--o--
        car          => ex2_pp1_1c(212)                  );--o--
    csa1_1_212: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(212)                   ,--i--
        b            => ex2_pp0_03(212)                   ,--i--
        c            => ex2_pp0_04(212)                   ,--i--
        sum          => ex2_pp1_1s(212)                   ,--o--
        car          => ex2_pp1_1c(211)                  );--o--
    csa1_1_211: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(211)                   ,--i--
        b            => ex2_pp0_03(211)                   ,--i--
        c            => ex2_pp0_04(211)                   ,--i--
        sum          => ex2_pp1_1s(211)                   ,--o--
        car          => ex2_pp1_1c(210)                  );--o--
    csa1_1_210: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(210)                   ,--i--
        b            => ex2_pp0_03(210)                   ,--i--
        c            => ex2_pp0_04(210)                   ,--i--
        sum          => ex2_pp1_1s(210)                   ,--o--
        car          => ex2_pp1_1c(209)                  );--o--
    csa1_1_209: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(209)                   ,--i--
        b            => ex2_pp0_03(209)                   ,--i--
        c            => ex2_pp0_04(209)                   ,--i--
        sum          => ex2_pp1_1s(209)                   ,--o--
        car          => ex2_pp1_1c(208)                  );--o--
    csa1_1_208: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(208)                   ,--i--
        b            => ex2_pp0_03(208)                   ,--i--
        c            => ex2_pp0_04(208)                   ,--i--
        sum          => ex2_pp1_1s(208)                   ,--o--
        car          => ex2_pp1_1c(207)                  );--o--
    csa1_1_207: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(207)                   ,--i--
        b            => ex2_pp0_03(207)                   ,--i--
        c            => ex2_pp0_04(207)                   ,--i--
        sum          => ex2_pp1_1s(207)                   ,--o--
        car          => ex2_pp1_1c(206)                  );--o--
    csa1_1_206: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(206)                   ,--i--
        b            => ex2_pp0_03(206)                   ,--i--
        c            => ex2_pp0_04(206)                   ,--i--
        sum          => ex2_pp1_1s(206)                   ,--o--
        car          => ex2_pp1_1c(205)                  );--o--
    csa1_1_205: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_02(205)                   ,--i--
        b            => ex2_pp0_03(205)                   ,--i--
        sum          => ex2_pp1_1s(205)                   ,--o--
        car          => ex2_pp1_1c(204)                  );--o--
    csa1_1_204: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_02(204)                   ,--i--
        b            => ex2_pp0_03(204)                   ,--i--
        sum          => ex2_pp1_1s(204)                   ,--o--
        car          => ex2_pp1_1c(203)                  );--o--
 ex2_pp1_1s(203)                  <= ex2_pp0_02(203)                  ; --pass_x_s
 ex2_pp1_1s(202)                  <= ex2_pp0_02(202)                  ; --pass_s



 ------- <csa1_2> -----

 ex2_pp1_2s(248)                  <= ex2_pp0_07(248)                  ; --pass_s
 ex2_pp1_2s(247)                  <= tidn                             ; --pass_none
 ex2_pp1_2c(246)                  <= ex2_pp0_07(246)                  ; --pass_cs
 ex2_pp1_2s(246)                  <= ex2_pp0_06(246)                  ; --pass_cs
 ex2_pp1_2c(245)                  <= tidn                            ; --pass_s
 ex2_pp1_2s(245)                  <= ex2_pp0_07(245)                  ; --pass_s
 ex2_pp1_2c(244)                  <= tidn                             ; --wr_csa32
    csa1_2_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(244)                   ,--i--
        b            => ex2_pp0_06(244)                   ,--i--
        c            => ex2_pp0_07(244)                   ,--i--
        sum          => ex2_pp1_2s(244)                   ,--o--
        car          => ex2_pp1_2c(243)                  );--o--
    csa1_2_243: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_06(243)                   ,--i--
        b            => ex2_pp0_07(243)                   ,--i--
        sum          => ex2_pp1_2s(243)                   ,--o--
        car          => ex2_pp1_2c(242)                  );--o--
    csa1_2_242: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(242)                   ,--i--
        b            => ex2_pp0_06(242)                   ,--i--
        c            => ex2_pp0_07(242)                   ,--i--
        sum          => ex2_pp1_2s(242)                   ,--o--
        car          => ex2_pp1_2c(241)                  );--o--
    csa1_2_241: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(241)                   ,--i--
        b            => ex2_pp0_06(241)                   ,--i--
        c            => ex2_pp0_07(241)                   ,--i--
        sum          => ex2_pp1_2s(241)                   ,--o--
        car          => ex2_pp1_2c(240)                  );--o--
    csa1_2_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(240)                   ,--i--
        b            => ex2_pp0_06(240)                   ,--i--
        c            => ex2_pp0_07(240)                   ,--i--
        sum          => ex2_pp1_2s(240)                   ,--o--
        car          => ex2_pp1_2c(239)                  );--o--
    csa1_2_239: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(239)                   ,--i--
        b            => ex2_pp0_06(239)                   ,--i--
        c            => ex2_pp0_07(239)                   ,--i--
        sum          => ex2_pp1_2s(239)                   ,--o--
        car          => ex2_pp1_2c(238)                  );--o--
    csa1_2_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(238)                   ,--i--
        b            => ex2_pp0_06(238)                   ,--i--
        c            => ex2_pp0_07(238)                   ,--i--
        sum          => ex2_pp1_2s(238)                   ,--o--
        car          => ex2_pp1_2c(237)                  );--o--
    csa1_2_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(237)                   ,--i--
        b            => ex2_pp0_06(237)                   ,--i--
        c            => ex2_pp0_07(237)                   ,--i--
        sum          => ex2_pp1_2s(237)                   ,--o--
        car          => ex2_pp1_2c(236)                  );--o--
    csa1_2_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(236)                   ,--i--
        b            => ex2_pp0_06(236)                   ,--i--
        c            => ex2_pp0_07(236)                   ,--i--
        sum          => ex2_pp1_2s(236)                   ,--o--
        car          => ex2_pp1_2c(235)                  );--o--
    csa1_2_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(235)                   ,--i--
        b            => ex2_pp0_06(235)                   ,--i--
        c            => ex2_pp0_07(235)                   ,--i--
        sum          => ex2_pp1_2s(235)                   ,--o--
        car          => ex2_pp1_2c(234)                  );--o--
    csa1_2_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(234)                   ,--i--
        b            => ex2_pp0_06(234)                   ,--i--
        c            => ex2_pp0_07(234)                   ,--i--
        sum          => ex2_pp1_2s(234)                   ,--o--
        car          => ex2_pp1_2c(233)                  );--o--
    csa1_2_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(233)                   ,--i--
        b            => ex2_pp0_06(233)                   ,--i--
        c            => ex2_pp0_07(233)                   ,--i--
        sum          => ex2_pp1_2s(233)                   ,--o--
        car          => ex2_pp1_2c(232)                  );--o--
    csa1_2_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(232)                   ,--i--
        b            => ex2_pp0_06(232)                   ,--i--
        c            => ex2_pp0_07(232)                   ,--i--
        sum          => ex2_pp1_2s(232)                   ,--o--
        car          => ex2_pp1_2c(231)                  );--o--
    csa1_2_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(231)                   ,--i--
        b            => ex2_pp0_06(231)                   ,--i--
        c            => ex2_pp0_07(231)                   ,--i--
        sum          => ex2_pp1_2s(231)                   ,--o--
        car          => ex2_pp1_2c(230)                  );--o--
    csa1_2_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(230)                   ,--i--
        b            => ex2_pp0_06(230)                   ,--i--
        c            => ex2_pp0_07(230)                   ,--i--
        sum          => ex2_pp1_2s(230)                   ,--o--
        car          => ex2_pp1_2c(229)                  );--o--
    csa1_2_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(229)                   ,--i--
        b            => ex2_pp0_06(229)                   ,--i--
        c            => ex2_pp0_07(229)                   ,--i--
        sum          => ex2_pp1_2s(229)                   ,--o--
        car          => ex2_pp1_2c(228)                  );--o--
    csa1_2_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(228)                   ,--i--
        b            => ex2_pp0_06(228)                   ,--i--
        c            => ex2_pp0_07(228)                   ,--i--
        sum          => ex2_pp1_2s(228)                   ,--o--
        car          => ex2_pp1_2c(227)                  );--o--
    csa1_2_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(227)                   ,--i--
        b            => ex2_pp0_06(227)                   ,--i--
        c            => ex2_pp0_07(227)                   ,--i--
        sum          => ex2_pp1_2s(227)                   ,--o--
        car          => ex2_pp1_2c(226)                  );--o--
    csa1_2_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(226)                   ,--i--
        b            => ex2_pp0_06(226)                   ,--i--
        c            => ex2_pp0_07(226)                   ,--i--
        sum          => ex2_pp1_2s(226)                   ,--o--
        car          => ex2_pp1_2c(225)                  );--o--
    csa1_2_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(225)                   ,--i--
        b            => ex2_pp0_06(225)                   ,--i--
        c            => ex2_pp0_07(225)                   ,--i--
        sum          => ex2_pp1_2s(225)                   ,--o--
        car          => ex2_pp1_2c(224)                  );--o--
    csa1_2_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(224)                   ,--i--
        b            => ex2_pp0_06(224)                   ,--i--
        c            => ex2_pp0_07(224)                   ,--i--
        sum          => ex2_pp1_2s(224)                   ,--o--
        car          => ex2_pp1_2c(223)                  );--o--
    csa1_2_223: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(223)                   ,--i--
        b            => ex2_pp0_06(223)                   ,--i--
        c            => ex2_pp0_07(223)                   ,--i--
        sum          => ex2_pp1_2s(223)                   ,--o--
        car          => ex2_pp1_2c(222)                  );--o--
    csa1_2_222: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(222)                   ,--i--
        b            => ex2_pp0_06(222)                   ,--i--
        c            => ex2_pp0_07(222)                   ,--i--
        sum          => ex2_pp1_2s(222)                   ,--o--
        car          => ex2_pp1_2c(221)                  );--o--
    csa1_2_221: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(221)                   ,--i--
        b            => ex2_pp0_06(221)                   ,--i--
        c            => ex2_pp0_07(221)                   ,--i--
        sum          => ex2_pp1_2s(221)                   ,--o--
        car          => ex2_pp1_2c(220)                  );--o--
    csa1_2_220: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(220)                   ,--i--
        b            => ex2_pp0_06(220)                   ,--i--
        c            => ex2_pp0_07(220)                   ,--i--
        sum          => ex2_pp1_2s(220)                   ,--o--
        car          => ex2_pp1_2c(219)                  );--o--
    csa1_2_219: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(219)                   ,--i--
        b            => ex2_pp0_06(219)                   ,--i--
        c            => ex2_pp0_07(219)                   ,--i--
        sum          => ex2_pp1_2s(219)                   ,--o--
        car          => ex2_pp1_2c(218)                  );--o--
    csa1_2_218: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(218)                   ,--i--
        b            => ex2_pp0_06(218)                   ,--i--
        c            => ex2_pp0_07(218)                   ,--i--
        sum          => ex2_pp1_2s(218)                   ,--o--
        car          => ex2_pp1_2c(217)                  );--o--
    csa1_2_217: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(217)                   ,--i--
        b            => ex2_pp0_06(217)                   ,--i--
        c            => ex2_pp0_07(217)                   ,--i--
        sum          => ex2_pp1_2s(217)                   ,--o--
        car          => ex2_pp1_2c(216)                  );--o--
    csa1_2_216: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(216)                   ,--i--
        b            => ex2_pp0_06(216)                   ,--i--
        c            => ex2_pp0_07(216)                   ,--i--
        sum          => ex2_pp1_2s(216)                   ,--o--
        car          => ex2_pp1_2c(215)                  );--o--
    csa1_2_215: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(215)                   ,--i--
        b            => ex2_pp0_06(215)                   ,--i--
        c            => ex2_pp0_07(215)                   ,--i--
        sum          => ex2_pp1_2s(215)                   ,--o--
        car          => ex2_pp1_2c(214)                  );--o--
    csa1_2_214: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(214)                   ,--i--
        b            => ex2_pp0_06(214)                   ,--i--
        c            => ex2_pp0_07(214)                   ,--i--
        sum          => ex2_pp1_2s(214)                   ,--o--
        car          => ex2_pp1_2c(213)                  );--o--
    csa1_2_213: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(213)                   ,--i--
        b            => ex2_pp0_06(213)                   ,--i--
        c            => ex2_pp0_07(213)                   ,--i--
        sum          => ex2_pp1_2s(213)                   ,--o--
        car          => ex2_pp1_2c(212)                  );--o--
    csa1_2_212: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(212)                   ,--i--
        b            => ex2_pp0_06(212)                   ,--i--
        c            => ex2_pp0_07(212)                   ,--i--
        sum          => ex2_pp1_2s(212)                   ,--o--
        car          => ex2_pp1_2c(211)                  );--o--
    csa1_2_211: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_05(211)                   ,--i--
        b            => ex2_pp0_06(211)                   ,--i--
        sum          => ex2_pp1_2s(211)                   ,--o--
        car          => ex2_pp1_2c(210)                  );--o--
    csa1_2_210: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_05(210)                   ,--i--
        b            => ex2_pp0_06(210)                   ,--i--
        sum          => ex2_pp1_2s(210)                   ,--o--
        car          => ex2_pp1_2c(209)                  );--o--
 ex2_pp1_2s(209)                  <= ex2_pp0_05(209)                  ; --pass_x_s
 ex2_pp1_2s(208)                  <= ex2_pp0_05(208)                  ; --pass_s




 ------- <csa1_3> -----

 ex2_pp1_3s(254)                  <= ex2_pp0_10(254)                  ; --pass_s
 ex2_pp1_3s(253)                  <= tidn                             ; --pass_none
 ex2_pp1_3c(252)                  <= ex2_pp0_10(252)                  ; --pass_cs
 ex2_pp1_3s(252)                  <= ex2_pp0_09(252)                  ; --pass_cs
 ex2_pp1_3c(251)                  <= tidn                            ; --pass_s
 ex2_pp1_3s(251)                  <= ex2_pp0_10(251)                  ; --pass_s
 ex2_pp1_3c(250)                  <= tidn                             ; --wr_csa32
    csa1_3_250: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(250)                   ,--i--
        b            => ex2_pp0_09(250)                   ,--i--
        c            => ex2_pp0_10(250)                   ,--i--
        sum          => ex2_pp1_3s(250)                   ,--o--
        car          => ex2_pp1_3c(249)                  );--o--
    csa1_3_249: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_09(249)                   ,--i--
        b            => ex2_pp0_10(249)                   ,--i--
        sum          => ex2_pp1_3s(249)                   ,--o--
        car          => ex2_pp1_3c(248)                  );--o--
    csa1_3_248: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(248)                   ,--i--
        b            => ex2_pp0_09(248)                   ,--i--
        c            => ex2_pp0_10(248)                   ,--i--
        sum          => ex2_pp1_3s(248)                   ,--o--
        car          => ex2_pp1_3c(247)                  );--o--
    csa1_3_247: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(247)                   ,--i--
        b            => ex2_pp0_09(247)                   ,--i--
        c            => ex2_pp0_10(247)                   ,--i--
        sum          => ex2_pp1_3s(247)                   ,--o--
        car          => ex2_pp1_3c(246)                  );--o--
    csa1_3_246: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(246)                   ,--i--
        b            => ex2_pp0_09(246)                   ,--i--
        c            => ex2_pp0_10(246)                   ,--i--
        sum          => ex2_pp1_3s(246)                   ,--o--
        car          => ex2_pp1_3c(245)                  );--o--
    csa1_3_245: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(245)                   ,--i--
        b            => ex2_pp0_09(245)                   ,--i--
        c            => ex2_pp0_10(245)                   ,--i--
        sum          => ex2_pp1_3s(245)                   ,--o--
        car          => ex2_pp1_3c(244)                  );--o--
    csa1_3_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(244)                   ,--i--
        b            => ex2_pp0_09(244)                   ,--i--
        c            => ex2_pp0_10(244)                   ,--i--
        sum          => ex2_pp1_3s(244)                   ,--o--
        car          => ex2_pp1_3c(243)                  );--o--
    csa1_3_243: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(243)                   ,--i--
        b            => ex2_pp0_09(243)                   ,--i--
        c            => ex2_pp0_10(243)                   ,--i--
        sum          => ex2_pp1_3s(243)                   ,--o--
        car          => ex2_pp1_3c(242)                  );--o--
    csa1_3_242: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(242)                   ,--i--
        b            => ex2_pp0_09(242)                   ,--i--
        c            => ex2_pp0_10(242)                   ,--i--
        sum          => ex2_pp1_3s(242)                   ,--o--
        car          => ex2_pp1_3c(241)                  );--o--
    csa1_3_241: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(241)                   ,--i--
        b            => ex2_pp0_09(241)                   ,--i--
        c            => ex2_pp0_10(241)                   ,--i--
        sum          => ex2_pp1_3s(241)                   ,--o--
        car          => ex2_pp1_3c(240)                  );--o--
    csa1_3_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(240)                   ,--i--
        b            => ex2_pp0_09(240)                   ,--i--
        c            => ex2_pp0_10(240)                   ,--i--
        sum          => ex2_pp1_3s(240)                   ,--o--
        car          => ex2_pp1_3c(239)                  );--o--
    csa1_3_239: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(239)                   ,--i--
        b            => ex2_pp0_09(239)                   ,--i--
        c            => ex2_pp0_10(239)                   ,--i--
        sum          => ex2_pp1_3s(239)                   ,--o--
        car          => ex2_pp1_3c(238)                  );--o--
    csa1_3_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(238)                   ,--i--
        b            => ex2_pp0_09(238)                   ,--i--
        c            => ex2_pp0_10(238)                   ,--i--
        sum          => ex2_pp1_3s(238)                   ,--o--
        car          => ex2_pp1_3c(237)                  );--o--
    csa1_3_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(237)                   ,--i--
        b            => ex2_pp0_09(237)                   ,--i--
        c            => ex2_pp0_10(237)                   ,--i--
        sum          => ex2_pp1_3s(237)                   ,--o--
        car          => ex2_pp1_3c(236)                  );--o--
    csa1_3_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(236)                   ,--i--
        b            => ex2_pp0_09(236)                   ,--i--
        c            => ex2_pp0_10(236)                   ,--i--
        sum          => ex2_pp1_3s(236)                   ,--o--
        car          => ex2_pp1_3c(235)                  );--o--
    csa1_3_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(235)                   ,--i--
        b            => ex2_pp0_09(235)                   ,--i--
        c            => ex2_pp0_10(235)                   ,--i--
        sum          => ex2_pp1_3s(235)                   ,--o--
        car          => ex2_pp1_3c(234)                  );--o--
    csa1_3_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(234)                   ,--i--
        b            => ex2_pp0_09(234)                   ,--i--
        c            => ex2_pp0_10(234)                   ,--i--
        sum          => ex2_pp1_3s(234)                   ,--o--
        car          => ex2_pp1_3c(233)                  );--o--
    csa1_3_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(233)                   ,--i--
        b            => ex2_pp0_09(233)                   ,--i--
        c            => ex2_pp0_10(233)                   ,--i--
        sum          => ex2_pp1_3s(233)                   ,--o--
        car          => ex2_pp1_3c(232)                  );--o--
    csa1_3_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(232)                   ,--i--
        b            => ex2_pp0_09(232)                   ,--i--
        c            => ex2_pp0_10(232)                   ,--i--
        sum          => ex2_pp1_3s(232)                   ,--o--
        car          => ex2_pp1_3c(231)                  );--o--
    csa1_3_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(231)                   ,--i--
        b            => ex2_pp0_09(231)                   ,--i--
        c            => ex2_pp0_10(231)                   ,--i--
        sum          => ex2_pp1_3s(231)                   ,--o--
        car          => ex2_pp1_3c(230)                  );--o--
    csa1_3_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(230)                   ,--i--
        b            => ex2_pp0_09(230)                   ,--i--
        c            => ex2_pp0_10(230)                   ,--i--
        sum          => ex2_pp1_3s(230)                   ,--o--
        car          => ex2_pp1_3c(229)                  );--o--
    csa1_3_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(229)                   ,--i--
        b            => ex2_pp0_09(229)                   ,--i--
        c            => ex2_pp0_10(229)                   ,--i--
        sum          => ex2_pp1_3s(229)                   ,--o--
        car          => ex2_pp1_3c(228)                  );--o--
    csa1_3_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(228)                   ,--i--
        b            => ex2_pp0_09(228)                   ,--i--
        c            => ex2_pp0_10(228)                   ,--i--
        sum          => ex2_pp1_3s(228)                   ,--o--
        car          => ex2_pp1_3c(227)                  );--o--
    csa1_3_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(227)                   ,--i--
        b            => ex2_pp0_09(227)                   ,--i--
        c            => ex2_pp0_10(227)                   ,--i--
        sum          => ex2_pp1_3s(227)                   ,--o--
        car          => ex2_pp1_3c(226)                  );--o--
    csa1_3_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(226)                   ,--i--
        b            => ex2_pp0_09(226)                   ,--i--
        c            => ex2_pp0_10(226)                   ,--i--
        sum          => ex2_pp1_3s(226)                   ,--o--
        car          => ex2_pp1_3c(225)                  );--o--
    csa1_3_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(225)                   ,--i--
        b            => ex2_pp0_09(225)                   ,--i--
        c            => ex2_pp0_10(225)                   ,--i--
        sum          => ex2_pp1_3s(225)                   ,--o--
        car          => ex2_pp1_3c(224)                  );--o--
    csa1_3_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(224)                   ,--i--
        b            => ex2_pp0_09(224)                   ,--i--
        c            => ex2_pp0_10(224)                   ,--i--
        sum          => ex2_pp1_3s(224)                   ,--o--
        car          => ex2_pp1_3c(223)                  );--o--
    csa1_3_223: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(223)                   ,--i--
        b            => ex2_pp0_09(223)                   ,--i--
        c            => ex2_pp0_10(223)                   ,--i--
        sum          => ex2_pp1_3s(223)                   ,--o--
        car          => ex2_pp1_3c(222)                  );--o--
    csa1_3_222: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(222)                   ,--i--
        b            => ex2_pp0_09(222)                   ,--i--
        c            => ex2_pp0_10(222)                   ,--i--
        sum          => ex2_pp1_3s(222)                   ,--o--
        car          => ex2_pp1_3c(221)                  );--o--
    csa1_3_221: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(221)                   ,--i--
        b            => ex2_pp0_09(221)                   ,--i--
        c            => ex2_pp0_10(221)                   ,--i--
        sum          => ex2_pp1_3s(221)                   ,--o--
        car          => ex2_pp1_3c(220)                  );--o--
    csa1_3_220: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(220)                   ,--i--
        b            => ex2_pp0_09(220)                   ,--i--
        c            => ex2_pp0_10(220)                   ,--i--
        sum          => ex2_pp1_3s(220)                   ,--o--
        car          => ex2_pp1_3c(219)                  );--o--
    csa1_3_219: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(219)                   ,--i--
        b            => ex2_pp0_09(219)                   ,--i--
        c            => ex2_pp0_10(219)                   ,--i--
        sum          => ex2_pp1_3s(219)                   ,--o--
        car          => ex2_pp1_3c(218)                  );--o--
    csa1_3_218: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(218)                   ,--i--
        b            => ex2_pp0_09(218)                   ,--i--
        c            => ex2_pp0_10(218)                   ,--i--
        sum          => ex2_pp1_3s(218)                   ,--o--
        car          => ex2_pp1_3c(217)                  );--o--
    csa1_3_217: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_08(217)                   ,--i--
        b            => ex2_pp0_09(217)                   ,--i--
        sum          => ex2_pp1_3s(217)                   ,--o--
        car          => ex2_pp1_3c(216)                  );--o--
    csa1_3_216: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_08(216)                   ,--i--
        b            => ex2_pp0_09(216)                   ,--i--
        sum          => ex2_pp1_3s(216)                   ,--o--
        car          => ex2_pp1_3c(215)                  );--o--
 ex2_pp1_3s(215)                  <= ex2_pp0_08(215)                  ; --pass_x_s
 ex2_pp1_3s(214)                  <= ex2_pp0_08(214)                  ; --pass_s



 ------- <csa1_4> -----

 ex2_pp1_4s(260)                  <= ex2_pp0_13(260)                  ; --pass_s
 ex2_pp1_4s(259)                  <= tidn                             ; --pass_none
 ex2_pp1_4c(258)                  <= ex2_pp0_13(258)                  ; --pass_cs
 ex2_pp1_4s(258)                  <= ex2_pp0_12(258)                  ; --pass_cs
 ex2_pp1_4c(257)                  <= tidn                            ; --pass_s
 ex2_pp1_4s(257)                  <= ex2_pp0_13(257)                  ; --pass_s
 ex2_pp1_4c(256)                  <= tidn                             ; --wr_csa32
    csa1_4_256: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(256)                   ,--i--
        b            => ex2_pp0_12(256)                   ,--i--
        c            => ex2_pp0_13(256)                   ,--i--
        sum          => ex2_pp1_4s(256)                   ,--o--
        car          => ex2_pp1_4c(255)                  );--o--
    csa1_4_255: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_12(255)                   ,--i--
        b            => ex2_pp0_13(255)                   ,--i--
        sum          => ex2_pp1_4s(255)                   ,--o--
        car          => ex2_pp1_4c(254)                  );--o--
    csa1_4_254: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(254)                   ,--i--
        b            => ex2_pp0_12(254)                   ,--i--
        c            => ex2_pp0_13(254)                   ,--i--
        sum          => ex2_pp1_4s(254)                   ,--o--
        car          => ex2_pp1_4c(253)                  );--o--
    csa1_4_253: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(253)                   ,--i--
        b            => ex2_pp0_12(253)                   ,--i--
        c            => ex2_pp0_13(253)                   ,--i--
        sum          => ex2_pp1_4s(253)                   ,--o--
        car          => ex2_pp1_4c(252)                  );--o--
    csa1_4_252: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(252)                   ,--i--
        b            => ex2_pp0_12(252)                   ,--i--
        c            => ex2_pp0_13(252)                   ,--i--
        sum          => ex2_pp1_4s(252)                   ,--o--
        car          => ex2_pp1_4c(251)                  );--o--
    csa1_4_251: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(251)                   ,--i--
        b            => ex2_pp0_12(251)                   ,--i--
        c            => ex2_pp0_13(251)                   ,--i--
        sum          => ex2_pp1_4s(251)                   ,--o--
        car          => ex2_pp1_4c(250)                  );--o--
    csa1_4_250: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(250)                   ,--i--
        b            => ex2_pp0_12(250)                   ,--i--
        c            => ex2_pp0_13(250)                   ,--i--
        sum          => ex2_pp1_4s(250)                   ,--o--
        car          => ex2_pp1_4c(249)                  );--o--
    csa1_4_249: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(249)                   ,--i--
        b            => ex2_pp0_12(249)                   ,--i--
        c            => ex2_pp0_13(249)                   ,--i--
        sum          => ex2_pp1_4s(249)                   ,--o--
        car          => ex2_pp1_4c(248)                  );--o--
    csa1_4_248: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(248)                   ,--i--
        b            => ex2_pp0_12(248)                   ,--i--
        c            => ex2_pp0_13(248)                   ,--i--
        sum          => ex2_pp1_4s(248)                   ,--o--
        car          => ex2_pp1_4c(247)                  );--o--
    csa1_4_247: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(247)                   ,--i--
        b            => ex2_pp0_12(247)                   ,--i--
        c            => ex2_pp0_13(247)                   ,--i--
        sum          => ex2_pp1_4s(247)                   ,--o--
        car          => ex2_pp1_4c(246)                  );--o--
    csa1_4_246: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(246)                   ,--i--
        b            => ex2_pp0_12(246)                   ,--i--
        c            => ex2_pp0_13(246)                   ,--i--
        sum          => ex2_pp1_4s(246)                   ,--o--
        car          => ex2_pp1_4c(245)                  );--o--
    csa1_4_245: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(245)                   ,--i--
        b            => ex2_pp0_12(245)                   ,--i--
        c            => ex2_pp0_13(245)                   ,--i--
        sum          => ex2_pp1_4s(245)                   ,--o--
        car          => ex2_pp1_4c(244)                  );--o--
    csa1_4_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(244)                   ,--i--
        b            => ex2_pp0_12(244)                   ,--i--
        c            => ex2_pp0_13(244)                   ,--i--
        sum          => ex2_pp1_4s(244)                   ,--o--
        car          => ex2_pp1_4c(243)                  );--o--
    csa1_4_243: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(243)                   ,--i--
        b            => ex2_pp0_12(243)                   ,--i--
        c            => ex2_pp0_13(243)                   ,--i--
        sum          => ex2_pp1_4s(243)                   ,--o--
        car          => ex2_pp1_4c(242)                  );--o--
    csa1_4_242: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(242)                   ,--i--
        b            => ex2_pp0_12(242)                   ,--i--
        c            => ex2_pp0_13(242)                   ,--i--
        sum          => ex2_pp1_4s(242)                   ,--o--
        car          => ex2_pp1_4c(241)                  );--o--
    csa1_4_241: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(241)                   ,--i--
        b            => ex2_pp0_12(241)                   ,--i--
        c            => ex2_pp0_13(241)                   ,--i--
        sum          => ex2_pp1_4s(241)                   ,--o--
        car          => ex2_pp1_4c(240)                  );--o--
    csa1_4_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(240)                   ,--i--
        b            => ex2_pp0_12(240)                   ,--i--
        c            => ex2_pp0_13(240)                   ,--i--
        sum          => ex2_pp1_4s(240)                   ,--o--
        car          => ex2_pp1_4c(239)                  );--o--
    csa1_4_239: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(239)                   ,--i--
        b            => ex2_pp0_12(239)                   ,--i--
        c            => ex2_pp0_13(239)                   ,--i--
        sum          => ex2_pp1_4s(239)                   ,--o--
        car          => ex2_pp1_4c(238)                  );--o--
    csa1_4_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(238)                   ,--i--
        b            => ex2_pp0_12(238)                   ,--i--
        c            => ex2_pp0_13(238)                   ,--i--
        sum          => ex2_pp1_4s(238)                   ,--o--
        car          => ex2_pp1_4c(237)                  );--o--
    csa1_4_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(237)                   ,--i--
        b            => ex2_pp0_12(237)                   ,--i--
        c            => ex2_pp0_13(237)                   ,--i--
        sum          => ex2_pp1_4s(237)                   ,--o--
        car          => ex2_pp1_4c(236)                  );--o--
    csa1_4_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(236)                   ,--i--
        b            => ex2_pp0_12(236)                   ,--i--
        c            => ex2_pp0_13(236)                   ,--i--
        sum          => ex2_pp1_4s(236)                   ,--o--
        car          => ex2_pp1_4c(235)                  );--o--
    csa1_4_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(235)                   ,--i--
        b            => ex2_pp0_12(235)                   ,--i--
        c            => ex2_pp0_13(235)                   ,--i--
        sum          => ex2_pp1_4s(235)                   ,--o--
        car          => ex2_pp1_4c(234)                  );--o--
    csa1_4_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(234)                   ,--i--
        b            => ex2_pp0_12(234)                   ,--i--
        c            => ex2_pp0_13(234)                   ,--i--
        sum          => ex2_pp1_4s(234)                   ,--o--
        car          => ex2_pp1_4c(233)                  );--o--
    csa1_4_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(233)                   ,--i--
        b            => ex2_pp0_12(233)                   ,--i--
        c            => ex2_pp0_13(233)                   ,--i--
        sum          => ex2_pp1_4s(233)                   ,--o--
        car          => ex2_pp1_4c(232)                  );--o--
    csa1_4_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(232)                   ,--i--
        b            => ex2_pp0_12(232)                   ,--i--
        c            => ex2_pp0_13(232)                   ,--i--
        sum          => ex2_pp1_4s(232)                   ,--o--
        car          => ex2_pp1_4c(231)                  );--o--
    csa1_4_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(231)                   ,--i--
        b            => ex2_pp0_12(231)                   ,--i--
        c            => ex2_pp0_13(231)                   ,--i--
        sum          => ex2_pp1_4s(231)                   ,--o--
        car          => ex2_pp1_4c(230)                  );--o--
    csa1_4_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(230)                   ,--i--
        b            => ex2_pp0_12(230)                   ,--i--
        c            => ex2_pp0_13(230)                   ,--i--
        sum          => ex2_pp1_4s(230)                   ,--o--
        car          => ex2_pp1_4c(229)                  );--o--
    csa1_4_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(229)                   ,--i--
        b            => ex2_pp0_12(229)                   ,--i--
        c            => ex2_pp0_13(229)                   ,--i--
        sum          => ex2_pp1_4s(229)                   ,--o--
        car          => ex2_pp1_4c(228)                  );--o--
    csa1_4_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(228)                   ,--i--
        b            => ex2_pp0_12(228)                   ,--i--
        c            => ex2_pp0_13(228)                   ,--i--
        sum          => ex2_pp1_4s(228)                   ,--o--
        car          => ex2_pp1_4c(227)                  );--o--
    csa1_4_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(227)                   ,--i--
        b            => ex2_pp0_12(227)                   ,--i--
        c            => ex2_pp0_13(227)                   ,--i--
        sum          => ex2_pp1_4s(227)                   ,--o--
        car          => ex2_pp1_4c(226)                  );--o--
    csa1_4_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(226)                   ,--i--
        b            => ex2_pp0_12(226)                   ,--i--
        c            => ex2_pp0_13(226)                   ,--i--
        sum          => ex2_pp1_4s(226)                   ,--o--
        car          => ex2_pp1_4c(225)                  );--o--
    csa1_4_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(225)                   ,--i--
        b            => ex2_pp0_12(225)                   ,--i--
        c            => ex2_pp0_13(225)                   ,--i--
        sum          => ex2_pp1_4s(225)                   ,--o--
        car          => ex2_pp1_4c(224)                  );--o--
    csa1_4_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(224)                   ,--i--
        b            => ex2_pp0_12(224)                   ,--i--
        c            => ex2_pp0_13(224)                   ,--i--
        sum          => ex2_pp1_4s(224)                   ,--o--
        car          => ex2_pp1_4c(223)                  );--o--
    csa1_4_223: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_11(223)                   ,--i--
        b            => ex2_pp0_12(223)                   ,--i--
        sum          => ex2_pp1_4s(223)                   ,--o--
        car          => ex2_pp1_4c(222)                  );--o--
    csa1_4_222: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_11(222)                   ,--i--
        b            => ex2_pp0_12(222)                   ,--i--
        sum          => ex2_pp1_4s(222)                   ,--o--
        car          => ex2_pp1_4c(221)                  );--o--
 ex2_pp1_4s(221)                  <= ex2_pp0_11(221)                  ; --pass_x_s
 ex2_pp1_4s(220)                  <= ex2_pp0_11(220)                  ; --pass_s


 ------- <csa1_5> -----

 ex2_pp1_5c(264)                  <= ex2_pp0_16(264)                  ; --pass_cs
 ex2_pp1_5s(264)                  <= ex2_pp0_15(264)                  ; --pass_cs
 ex2_pp1_5c(263)                  <= tidn                            ; --pass_s
 ex2_pp1_5s(263)                  <= ex2_pp0_16(263)                  ; --pass_s
 ex2_pp1_5c(262)                  <= tidn                             ; --wr_csa32
    csa1_5_262: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(262)                   ,--i--
        b            => ex2_pp0_15(262)                   ,--i--
        c            => ex2_pp0_16(262)                   ,--i--
        sum          => ex2_pp1_5s(262)                   ,--o--
        car          => ex2_pp1_5c(261)                  );--o--
    csa1_5_261: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_15(261)                   ,--i--
        b            => ex2_pp0_16(261)                   ,--i--
        sum          => ex2_pp1_5s(261)                   ,--o--
        car          => ex2_pp1_5c(260)                  );--o--
    csa1_5_260: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(260)                   ,--i--
        b            => ex2_pp0_15(260)                   ,--i--
        c            => ex2_pp0_16(260)                   ,--i--
        sum          => ex2_pp1_5s(260)                   ,--o--
        car          => ex2_pp1_5c(259)                  );--o--
    csa1_5_259: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(259)                   ,--i--
        b            => ex2_pp0_15(259)                   ,--i--
        c            => ex2_pp0_16(259)                   ,--i--
        sum          => ex2_pp1_5s(259)                   ,--o--
        car          => ex2_pp1_5c(258)                  );--o--
    csa1_5_258: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(258)                   ,--i--
        b            => ex2_pp0_15(258)                   ,--i--
        c            => ex2_pp0_16(258)                   ,--i--
        sum          => ex2_pp1_5s(258)                   ,--o--
        car          => ex2_pp1_5c(257)                  );--o--
    csa1_5_257: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(257)                   ,--i--
        b            => ex2_pp0_15(257)                   ,--i--
        c            => ex2_pp0_16(257)                   ,--i--
        sum          => ex2_pp1_5s(257)                   ,--o--
        car          => ex2_pp1_5c(256)                  );--o--
    csa1_5_256: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(256)                   ,--i--
        b            => ex2_pp0_15(256)                   ,--i--
        c            => ex2_pp0_16(256)                   ,--i--
        sum          => ex2_pp1_5s(256)                   ,--o--
        car          => ex2_pp1_5c(255)                  );--o--
    csa1_5_255: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(255)                   ,--i--
        b            => ex2_pp0_15(255)                   ,--i--
        c            => ex2_pp0_16(255)                   ,--i--
        sum          => ex2_pp1_5s(255)                   ,--o--
        car          => ex2_pp1_5c(254)                  );--o--
    csa1_5_254: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(254)                   ,--i--
        b            => ex2_pp0_15(254)                   ,--i--
        c            => ex2_pp0_16(254)                   ,--i--
        sum          => ex2_pp1_5s(254)                   ,--o--
        car          => ex2_pp1_5c(253)                  );--o--
    csa1_5_253: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(253)                   ,--i--
        b            => ex2_pp0_15(253)                   ,--i--
        c            => ex2_pp0_16(253)                   ,--i--
        sum          => ex2_pp1_5s(253)                   ,--o--
        car          => ex2_pp1_5c(252)                  );--o--
    csa1_5_252: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(252)                   ,--i--
        b            => ex2_pp0_15(252)                   ,--i--
        c            => ex2_pp0_16(252)                   ,--i--
        sum          => ex2_pp1_5s(252)                   ,--o--
        car          => ex2_pp1_5c(251)                  );--o--
    csa1_5_251: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(251)                   ,--i--
        b            => ex2_pp0_15(251)                   ,--i--
        c            => ex2_pp0_16(251)                   ,--i--
        sum          => ex2_pp1_5s(251)                   ,--o--
        car          => ex2_pp1_5c(250)                  );--o--
    csa1_5_250: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(250)                   ,--i--
        b            => ex2_pp0_15(250)                   ,--i--
        c            => ex2_pp0_16(250)                   ,--i--
        sum          => ex2_pp1_5s(250)                   ,--o--
        car          => ex2_pp1_5c(249)                  );--o--
    csa1_5_249: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(249)                   ,--i--
        b            => ex2_pp0_15(249)                   ,--i--
        c            => ex2_pp0_16(249)                   ,--i--
        sum          => ex2_pp1_5s(249)                   ,--o--
        car          => ex2_pp1_5c(248)                  );--o--
    csa1_5_248: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(248)                   ,--i--
        b            => ex2_pp0_15(248)                   ,--i--
        c            => ex2_pp0_16(248)                   ,--i--
        sum          => ex2_pp1_5s(248)                   ,--o--
        car          => ex2_pp1_5c(247)                  );--o--
    csa1_5_247: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(247)                   ,--i--
        b            => ex2_pp0_15(247)                   ,--i--
        c            => ex2_pp0_16(247)                   ,--i--
        sum          => ex2_pp1_5s(247)                   ,--o--
        car          => ex2_pp1_5c(246)                  );--o--
    csa1_5_246: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(246)                   ,--i--
        b            => ex2_pp0_15(246)                   ,--i--
        c            => ex2_pp0_16(246)                   ,--i--
        sum          => ex2_pp1_5s(246)                   ,--o--
        car          => ex2_pp1_5c(245)                  );--o--
    csa1_5_245: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(245)                   ,--i--
        b            => ex2_pp0_15(245)                   ,--i--
        c            => ex2_pp0_16(245)                   ,--i--
        sum          => ex2_pp1_5s(245)                   ,--o--
        car          => ex2_pp1_5c(244)                  );--o--
    csa1_5_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(244)                   ,--i--
        b            => ex2_pp0_15(244)                   ,--i--
        c            => ex2_pp0_16(244)                   ,--i--
        sum          => ex2_pp1_5s(244)                   ,--o--
        car          => ex2_pp1_5c(243)                  );--o--
    csa1_5_243: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(243)                   ,--i--
        b            => ex2_pp0_15(243)                   ,--i--
        c            => ex2_pp0_16(243)                   ,--i--
        sum          => ex2_pp1_5s(243)                   ,--o--
        car          => ex2_pp1_5c(242)                  );--o--
    csa1_5_242: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(242)                   ,--i--
        b            => ex2_pp0_15(242)                   ,--i--
        c            => ex2_pp0_16(242)                   ,--i--
        sum          => ex2_pp1_5s(242)                   ,--o--
        car          => ex2_pp1_5c(241)                  );--o--
    csa1_5_241: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(241)                   ,--i--
        b            => ex2_pp0_15(241)                   ,--i--
        c            => ex2_pp0_16(241)                   ,--i--
        sum          => ex2_pp1_5s(241)                   ,--o--
        car          => ex2_pp1_5c(240)                  );--o--
    csa1_5_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(240)                   ,--i--
        b            => ex2_pp0_15(240)                   ,--i--
        c            => ex2_pp0_16(240)                   ,--i--
        sum          => ex2_pp1_5s(240)                   ,--o--
        car          => ex2_pp1_5c(239)                  );--o--
    csa1_5_239: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(239)                   ,--i--
        b            => ex2_pp0_15(239)                   ,--i--
        c            => ex2_pp0_16(239)                   ,--i--
        sum          => ex2_pp1_5s(239)                   ,--o--
        car          => ex2_pp1_5c(238)                  );--o--
    csa1_5_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(238)                   ,--i--
        b            => ex2_pp0_15(238)                   ,--i--
        c            => ex2_pp0_16(238)                   ,--i--
        sum          => ex2_pp1_5s(238)                   ,--o--
        car          => ex2_pp1_5c(237)                  );--o--
    csa1_5_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(237)                   ,--i--
        b            => ex2_pp0_15(237)                   ,--i--
        c            => ex2_pp0_16(237)                   ,--i--
        sum          => ex2_pp1_5s(237)                   ,--o--
        car          => ex2_pp1_5c(236)                  );--o--
    csa1_5_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(236)                   ,--i--
        b            => ex2_pp0_15(236)                   ,--i--
        c            => ex2_pp0_16(236)                   ,--i--
        sum          => ex2_pp1_5s(236)                   ,--o--
        car          => ex2_pp1_5c(235)                  );--o--
    csa1_5_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(235)                   ,--i--
        b            => ex2_pp0_15(235)                   ,--i--
        c            => ex2_pp0_16(235)                   ,--i--
        sum          => ex2_pp1_5s(235)                   ,--o--
        car          => ex2_pp1_5c(234)                  );--o--
    csa1_5_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(234)                   ,--i--
        b            => ex2_pp0_15(234)                   ,--i--
        c            => ex2_pp0_16(234)                   ,--i--
        sum          => ex2_pp1_5s(234)                   ,--o--
        car          => ex2_pp1_5c(233)                  );--o--
    csa1_5_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(233)                   ,--i--
        b            => ex2_pp0_15(233)                   ,--i--
        c            => ex2_pp0_16(233)                   ,--i--
        sum          => ex2_pp1_5s(233)                   ,--o--
        car          => ex2_pp1_5c(232)                  );--o--
    csa1_5_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(232)                   ,--i--
        b            => ex2_pp0_15(232)                   ,--i--
        c            => ex2_pp0_16(232)                   ,--i--
        sum          => ex2_pp1_5s(232)                   ,--o--
        car          => ex2_pp1_5c(231)                  );--o--
    csa1_5_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(231)                   ,--i--
        b            => ex2_pp0_15(231)                   ,--i--
        c            => ex2_pp0_16(231)                   ,--i--
        sum          => ex2_pp1_5s(231)                   ,--o--
        car          => ex2_pp1_5c(230)                  );--o--
    csa1_5_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(230)                   ,--i--
        b            => ex2_pp0_15(230)                   ,--i--
        c            => ex2_pp0_16(230)                   ,--i--
        sum          => ex2_pp1_5s(230)                   ,--o--
        car          => ex2_pp1_5c(229)                  );--o--
    csa1_5_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(229)                   ,--i--
        b            => ex2_pp0_15(229)                   ,--i--
        c            => ex2_pp0_16(229)                   ,--i--
        sum          => ex2_pp1_5s(229)                   ,--o--
        car          => ex2_pp1_5c(228)                  );--o--
    csa1_5_228: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_14(228)                   ,--i--
        b            => ex2_pp0_15(228)                   ,--i--
        sum          => ex2_pp1_5s(228)                   ,--o--
        car          => ex2_pp1_5c(227)                  );--o--
 ex2_pp1_5s(227)                  <= ex2_pp0_14(227)                  ; --pass_x_s
 ex2_pp1_5s(226)                  <= ex2_pp0_14(226)                  ; --pass_s



       --***********************************
       --** compression level 2
       --***********************************

    -- g2 : for i in 196 to 264 generate

        -- csa2_0: entity work.c_prism_csa42 generic map( btr => "MLT42_X1_A12TH" ) port map(
        --    a    => ex2_pp1_0s(i)                          ,--i--
        --    b    => ex2_pp1_0c(i)                          ,--i--
        --    c    => ex2_pp1_1s(i)                          ,--i--
        --    d    => ex2_pp1_1c(i)                          ,--i--
        --    ki   => ex2_pp2_0k(i)                          ,--i--
        --    ko   => ex2_pp2_0k(i - 1)                      ,--o--
        --    sum  => ex2_pp2_0s(i)                          ,--o--
        --    car  => ex2_pp2_0c(i - 1)                     );--o--
        --
        -- csa2_1: entity work.c_prism_csa42 generic map( btr => "MLT42_X1_A12TH" ) port map(
        --    a    => ex2_pp1_2s(i)                          ,--i--
        --    b    => ex2_pp1_2c(i)                          ,--i--
        --    c    => ex2_pp1_3s(i)                          ,--i--
        --    d    => ex2_pp1_3c(i)                          ,--i--
        --    ki   => ex2_pp2_1k(i)                          ,--i--
        --    ko   => ex2_pp2_1k(i - 1)                      ,--o--
        --    sum  => ex2_pp2_1s(i)                          ,--o--
        --    car  => ex2_pp2_1c(i - 1)                     );--o--
        --
        -- csa2_2: entity work.c_prism_csa42 generic map( btr => "MLT42_X1_A12TH" ) port map(
        --    a    => ex2_pp1_4s(i)                          ,--i--
        --    b    => ex2_pp1_4c(i)                          ,--i--
        --    c    => ex2_pp1_5s(i)                          ,--i--
        --    d    => ex2_pp1_5c(i)                          ,--i--
        --    ki   => ex2_pp2_2k(i)                          ,--i--
        --    ko   => ex2_pp2_2k(i - 1)                      ,--o--
        --    sum  => ex2_pp2_2s(i)                          ,--o--
        --    car  => ex2_pp2_2c(i - 1)                     );--o--
        --
   -- end generate;


 ------- <csa2_0> -----

 ex2_pp2_0s(242)                  <= ex2_pp1_1s(242)                  ; --pass_s
 ex2_pp2_0s(241)                  <= tidn                             ; --pass_none
 ex2_pp2_0c(240)                  <= ex2_pp1_1s(240)                  ; --pass_cs
 ex2_pp2_0s(240)                  <= ex2_pp1_1c(240)                  ; --pass_cs
 ex2_pp2_0c(239)                  <= tidn                             ; --pass_s
 ex2_pp2_0s(239)                  <= ex2_pp1_1s(239)                  ; --pass_s
 ex2_pp2_0c(238)                  <= tidn                             ; --pass_s
 ex2_pp2_0s(238)                  <= ex2_pp1_1s(238)                  ; --pass_s
 ex2_pp2_0c(237)                  <= ex2_pp1_1s(237)                  ; --pass_cs
 ex2_pp2_0s(237)                  <= ex2_pp1_1c(237)                  ; --pass_cs
 ex2_pp2_0c(236)                  <= tidn                             ; --wr_csa32
    csa2_0_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0s(236)                   ,--i--
        b            => ex2_pp1_1c(236)                   ,--i--
        c            => ex2_pp1_1s(236)                   ,--i--
        sum          => ex2_pp2_0s(236)                   ,--o--
        car          => ex2_pp2_0c(235)                  );--o--
    csa2_0_235: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_1c(235)                   ,--i--
        b            => ex2_pp1_1s(235)                   ,--i--
        sum          => ex2_pp2_0s(235)                   ,--o--
        car          => ex2_pp2_0c(234)                  );--o--
 ex2_pp2_0k(234)                  <= tidn                             ; --start_k
    csa2_0_234: entity clib.c_prism_csa42 port map( -- MLT42_X1_A12TH
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(234)                   ,--i--
        b            => ex2_pp1_0s(234)                   ,--i--
        c            => ex2_pp1_1c(234)                   ,--i--
        d            => ex2_pp1_1s(234)                   ,--i--
        ki           => ex2_pp2_0k(234)                   ,--i--
        ko           => ex2_pp2_0k(233)                   ,--o--
        sum          => ex2_pp2_0s(234)                   ,--o--
        car          => ex2_pp2_0c(233)                  );--o--
    csa2_0_233: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0s(233)                   ,--i--
        b            => ex2_pp1_1c(233)                   ,--i--
        c            => ex2_pp1_1s(233)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex2_pp2_0k(233)                   ,--i--
        ko           => ex2_pp2_0k(232)                   ,--o--
        sum          => ex2_pp2_0s(233)                   ,--o--
        car          => ex2_pp2_0c(232)                  );--o--
    csa2_0_232: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0s(232)                   ,--i--
        b            => ex2_pp1_1c(232)                   ,--i--
        c            => ex2_pp1_1s(232)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex2_pp2_0k(232)                   ,--i--
        ko           => ex2_pp2_0k(231)                   ,--o--
        sum          => ex2_pp2_0s(232)                   ,--o--
        car          => ex2_pp2_0c(231)                  );--o--
    csa2_0_231: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(231)                   ,--i--
        b            => ex2_pp1_0s(231)                   ,--i--
        c            => ex2_pp1_1c(231)                   ,--i--
        d            => ex2_pp1_1s(231)                   ,--i--
        ki           => ex2_pp2_0k(231)                   ,--i--
        ko           => ex2_pp2_0k(230)                   ,--o--
        sum          => ex2_pp2_0s(231)                   ,--o--
        car          => ex2_pp2_0c(230)                  );--o--
    csa2_0_230: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(230)                   ,--i--
        b            => ex2_pp1_0s(230)                   ,--i--
        c            => ex2_pp1_1c(230)                   ,--i--
        d            => ex2_pp1_1s(230)                   ,--i--
        ki           => ex2_pp2_0k(230)                   ,--i--
        ko           => ex2_pp2_0k(229)                   ,--o--
        sum          => ex2_pp2_0s(230)                   ,--o--
        car          => ex2_pp2_0c(229)                  );--o--
    csa2_0_229: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(229)                   ,--i--
        b            => ex2_pp1_0s(229)                   ,--i--
        c            => ex2_pp1_1c(229)                   ,--i--
        d            => ex2_pp1_1s(229)                   ,--i--
        ki           => ex2_pp2_0k(229)                   ,--i--
        ko           => ex2_pp2_0k(228)                   ,--o--
        sum          => ex2_pp2_0s(229)                   ,--o--
        car          => ex2_pp2_0c(228)                  );--o--
    csa2_0_228: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(228)                   ,--i--
        b            => ex2_pp1_0s(228)                   ,--i--
        c            => ex2_pp1_1c(228)                   ,--i--
        d            => ex2_pp1_1s(228)                   ,--i--
        ki           => ex2_pp2_0k(228)                   ,--i--
        ko           => ex2_pp2_0k(227)                   ,--o--
        sum          => ex2_pp2_0s(228)                   ,--o--
        car          => ex2_pp2_0c(227)                  );--o--
    csa2_0_227: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(227)                   ,--i--
        b            => ex2_pp1_0s(227)                   ,--i--
        c            => ex2_pp1_1c(227)                   ,--i--
        d            => ex2_pp1_1s(227)                   ,--i--
        ki           => ex2_pp2_0k(227)                   ,--i--
        ko           => ex2_pp2_0k(226)                   ,--o--
        sum          => ex2_pp2_0s(227)                   ,--o--
        car          => ex2_pp2_0c(226)                  );--o--
    csa2_0_226: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(226)                   ,--i--
        b            => ex2_pp1_0s(226)                   ,--i--
        c            => ex2_pp1_1c(226)                   ,--i--
        d            => ex2_pp1_1s(226)                   ,--i--
        ki           => ex2_pp2_0k(226)                   ,--i--
        ko           => ex2_pp2_0k(225)                   ,--o--
        sum          => ex2_pp2_0s(226)                   ,--o--
        car          => ex2_pp2_0c(225)                  );--o--
    csa2_0_225: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(225)                   ,--i--
        b            => ex2_pp1_0s(225)                   ,--i--
        c            => ex2_pp1_1c(225)                   ,--i--
        d            => ex2_pp1_1s(225)                   ,--i--
        ki           => ex2_pp2_0k(225)                   ,--i--
        ko           => ex2_pp2_0k(224)                   ,--o--
        sum          => ex2_pp2_0s(225)                   ,--o--
        car          => ex2_pp2_0c(224)                  );--o--
    csa2_0_224: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(224)                   ,--i--
        b            => ex2_pp1_0s(224)                   ,--i--
        c            => ex2_pp1_1c(224)                   ,--i--
        d            => ex2_pp1_1s(224)                   ,--i--
        ki           => ex2_pp2_0k(224)                   ,--i--
        ko           => ex2_pp2_0k(223)                   ,--o--
        sum          => ex2_pp2_0s(224)                   ,--o--
        car          => ex2_pp2_0c(223)                  );--o--
    csa2_0_223: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(223)                   ,--i--
        b            => ex2_pp1_0s(223)                   ,--i--
        c            => ex2_pp1_1c(223)                   ,--i--
        d            => ex2_pp1_1s(223)                   ,--i--
        ki           => ex2_pp2_0k(223)                   ,--i--
        ko           => ex2_pp2_0k(222)                   ,--o--
        sum          => ex2_pp2_0s(223)                   ,--o--
        car          => ex2_pp2_0c(222)                  );--o--
    csa2_0_222: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(222)                   ,--i--
        b            => ex2_pp1_0s(222)                   ,--i--
        c            => ex2_pp1_1c(222)                   ,--i--
        d            => ex2_pp1_1s(222)                   ,--i--
        ki           => ex2_pp2_0k(222)                   ,--i--
        ko           => ex2_pp2_0k(221)                   ,--o--
        sum          => ex2_pp2_0s(222)                   ,--o--
        car          => ex2_pp2_0c(221)                  );--o--
    csa2_0_221: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(221)                   ,--i--
        b            => ex2_pp1_0s(221)                   ,--i--
        c            => ex2_pp1_1c(221)                   ,--i--
        d            => ex2_pp1_1s(221)                   ,--i--
        ki           => ex2_pp2_0k(221)                   ,--i--
        ko           => ex2_pp2_0k(220)                   ,--o--
        sum          => ex2_pp2_0s(221)                   ,--o--
        car          => ex2_pp2_0c(220)                  );--o--
    csa2_0_220: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(220)                   ,--i--
        b            => ex2_pp1_0s(220)                   ,--i--
        c            => ex2_pp1_1c(220)                   ,--i--
        d            => ex2_pp1_1s(220)                   ,--i--
        ki           => ex2_pp2_0k(220)                   ,--i--
        ko           => ex2_pp2_0k(219)                   ,--o--
        sum          => ex2_pp2_0s(220)                   ,--o--
        car          => ex2_pp2_0c(219)                  );--o--
    csa2_0_219: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(219)                   ,--i--
        b            => ex2_pp1_0s(219)                   ,--i--
        c            => ex2_pp1_1c(219)                   ,--i--
        d            => ex2_pp1_1s(219)                   ,--i--
        ki           => ex2_pp2_0k(219)                   ,--i--
        ko           => ex2_pp2_0k(218)                   ,--o--
        sum          => ex2_pp2_0s(219)                   ,--o--
        car          => ex2_pp2_0c(218)                  );--o--
    csa2_0_218: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(218)                   ,--i--
        b            => ex2_pp1_0s(218)                   ,--i--
        c            => ex2_pp1_1c(218)                   ,--i--
        d            => ex2_pp1_1s(218)                   ,--i--
        ki           => ex2_pp2_0k(218)                   ,--i--
        ko           => ex2_pp2_0k(217)                   ,--o--
        sum          => ex2_pp2_0s(218)                   ,--o--
        car          => ex2_pp2_0c(217)                  );--o--
    csa2_0_217: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(217)                   ,--i--
        b            => ex2_pp1_0s(217)                   ,--i--
        c            => ex2_pp1_1c(217)                   ,--i--
        d            => ex2_pp1_1s(217)                   ,--i--
        ki           => ex2_pp2_0k(217)                   ,--i--
        ko           => ex2_pp2_0k(216)                   ,--o--
        sum          => ex2_pp2_0s(217)                   ,--o--
        car          => ex2_pp2_0c(216)                  );--o--
    csa2_0_216: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(216)                   ,--i--
        b            => ex2_pp1_0s(216)                   ,--i--
        c            => ex2_pp1_1c(216)                   ,--i--
        d            => ex2_pp1_1s(216)                   ,--i--
        ki           => ex2_pp2_0k(216)                   ,--i--
        ko           => ex2_pp2_0k(215)                   ,--o--
        sum          => ex2_pp2_0s(216)                   ,--o--
        car          => ex2_pp2_0c(215)                  );--o--
    csa2_0_215: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(215)                   ,--i--
        b            => ex2_pp1_0s(215)                   ,--i--
        c            => ex2_pp1_1c(215)                   ,--i--
        d            => ex2_pp1_1s(215)                   ,--i--
        ki           => ex2_pp2_0k(215)                   ,--i--
        ko           => ex2_pp2_0k(214)                   ,--o--
        sum          => ex2_pp2_0s(215)                   ,--o--
        car          => ex2_pp2_0c(214)                  );--o--
    csa2_0_214: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(214)                   ,--i--
        b            => ex2_pp1_0s(214)                   ,--i--
        c            => ex2_pp1_1c(214)                   ,--i--
        d            => ex2_pp1_1s(214)                   ,--i--
        ki           => ex2_pp2_0k(214)                   ,--i--
        ko           => ex2_pp2_0k(213)                   ,--o--
        sum          => ex2_pp2_0s(214)                   ,--o--
        car          => ex2_pp2_0c(213)                  );--o--
    csa2_0_213: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(213)                   ,--i--
        b            => ex2_pp1_0s(213)                   ,--i--
        c            => ex2_pp1_1c(213)                   ,--i--
        d            => ex2_pp1_1s(213)                   ,--i--
        ki           => ex2_pp2_0k(213)                   ,--i--
        ko           => ex2_pp2_0k(212)                   ,--o--
        sum          => ex2_pp2_0s(213)                   ,--o--
        car          => ex2_pp2_0c(212)                  );--o--
    csa2_0_212: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(212)                   ,--i--
        b            => ex2_pp1_0s(212)                   ,--i--
        c            => ex2_pp1_1c(212)                   ,--i--
        d            => ex2_pp1_1s(212)                   ,--i--
        ki           => ex2_pp2_0k(212)                   ,--i--
        ko           => ex2_pp2_0k(211)                   ,--o--
        sum          => ex2_pp2_0s(212)                   ,--o--
        car          => ex2_pp2_0c(211)                  );--o--
    csa2_0_211: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(211)                   ,--i--
        b            => ex2_pp1_0s(211)                   ,--i--
        c            => ex2_pp1_1c(211)                   ,--i--
        d            => ex2_pp1_1s(211)                   ,--i--
        ki           => ex2_pp2_0k(211)                   ,--i--
        ko           => ex2_pp2_0k(210)                   ,--o--
        sum          => ex2_pp2_0s(211)                   ,--o--
        car          => ex2_pp2_0c(210)                  );--o--
    csa2_0_210: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(210)                   ,--i--
        b            => ex2_pp1_0s(210)                   ,--i--
        c            => ex2_pp1_1c(210)                   ,--i--
        d            => ex2_pp1_1s(210)                   ,--i--
        ki           => ex2_pp2_0k(210)                   ,--i--
        ko           => ex2_pp2_0k(209)                   ,--o--
        sum          => ex2_pp2_0s(210)                   ,--o--
        car          => ex2_pp2_0c(209)                  );--o--
    csa2_0_209: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(209)                   ,--i--
        b            => ex2_pp1_0s(209)                   ,--i--
        c            => ex2_pp1_1c(209)                   ,--i--
        d            => ex2_pp1_1s(209)                   ,--i--
        ki           => ex2_pp2_0k(209)                   ,--i--
        ko           => ex2_pp2_0k(208)                   ,--o--
        sum          => ex2_pp2_0s(209)                   ,--o--
        car          => ex2_pp2_0c(208)                  );--o--
    csa2_0_208: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(208)                   ,--i--
        b            => ex2_pp1_0s(208)                   ,--i--
        c            => ex2_pp1_1c(208)                   ,--i--
        d            => ex2_pp1_1s(208)                   ,--i--
        ki           => ex2_pp2_0k(208)                   ,--i--
        ko           => ex2_pp2_0k(207)                   ,--o--
        sum          => ex2_pp2_0s(208)                   ,--o--
        car          => ex2_pp2_0c(207)                  );--o--
    csa2_0_207: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(207)                   ,--i--
        b            => ex2_pp1_0s(207)                   ,--i--
        c            => ex2_pp1_1c(207)                   ,--i--
        d            => ex2_pp1_1s(207)                   ,--i--
        ki           => ex2_pp2_0k(207)                   ,--i--
        ko           => ex2_pp2_0k(206)                   ,--o--
        sum          => ex2_pp2_0s(207)                   ,--o--
        car          => ex2_pp2_0c(206)                  );--o--
    csa2_0_206: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(206)                   ,--i--
        b            => ex2_pp1_0s(206)                   ,--i--
        c            => ex2_pp1_1c(206)                   ,--i--
        d            => ex2_pp1_1s(206)                   ,--i--
        ki           => ex2_pp2_0k(206)                   ,--i--
        ko           => ex2_pp2_0k(205)                   ,--o--
        sum          => ex2_pp2_0s(206)                   ,--o--
        car          => ex2_pp2_0c(205)                  );--o--
    csa2_0_205: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(205)                   ,--i--
        b            => ex2_pp1_0s(205)                   ,--i--
        c            => ex2_pp1_1c(205)                   ,--i--
        d            => ex2_pp1_1s(205)                   ,--i--
        ki           => ex2_pp2_0k(205)                   ,--i--
        ko           => ex2_pp2_0k(204)                   ,--o--
        sum          => ex2_pp2_0s(205)                   ,--o--
        car          => ex2_pp2_0c(204)                  );--o--
    csa2_0_204: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(204)                   ,--i--
        b            => ex2_pp1_0s(204)                   ,--i--
        c            => ex2_pp1_1c(204)                   ,--i--
        d            => ex2_pp1_1s(204)                   ,--i--
        ki           => ex2_pp2_0k(204)                   ,--i--
        ko           => ex2_pp2_0k(203)                   ,--o--
        sum          => ex2_pp2_0s(204)                   ,--o--
        car          => ex2_pp2_0c(203)                  );--o--
    csa2_0_203: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(203)                   ,--i--
        b            => ex2_pp1_0s(203)                   ,--i--
        c            => ex2_pp1_1c(203)                   ,--i--
        d            => ex2_pp1_1s(203)                   ,--i--
        ki           => ex2_pp2_0k(203)                   ,--i--
        ko           => ex2_pp2_0k(202)                   ,--o--
        sum          => ex2_pp2_0s(203)                   ,--o--
        car          => ex2_pp2_0c(202)                  );--o--
    csa2_0_202: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(202)                   ,--i--
        b            => ex2_pp1_0s(202)                   ,--i--
        c            => ex2_pp1_1s(202)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex2_pp2_0k(202)                   ,--i--
        ko           => ex2_pp2_0k(201)                   ,--o--
        sum          => ex2_pp2_0s(202)                   ,--o--
        car          => ex2_pp2_0c(201)                  );--o--
    csa2_0_201: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(201)                   ,--i--
        b            => ex2_pp1_0s(201)                   ,--i--
        c            => ex2_pp2_0k(201)                   ,--i--
        sum          => ex2_pp2_0s(201)                   ,--o--
        car          => ex2_pp2_0c(200)                  );--o--
    csa2_0_200: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_0c(200)                   ,--i--
        b            => ex2_pp1_0s(200)                   ,--i--
        sum          => ex2_pp2_0s(200)                   ,--o--
        car          => ex2_pp2_0c(199)                  );--o--
    csa2_0_199: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_0c(199)                   ,--i--
        b            => ex2_pp1_0s(199)                   ,--i--
        sum          => ex2_pp2_0s(199)                   ,--o--
        car          => ex2_pp2_0c(198)                  );--o--
 ex2_pp2_0s(198)                  <= ex2_pp1_0s(198)                  ; --pass_x_s


 ------- <csa2_1> -----

 ex2_pp2_1s(254)                  <= ex2_pp1_3s(254)                  ; --pass_s
 ex2_pp2_1s(253)                  <= tidn                             ; --pass_none
 ex2_pp2_1c(252)                  <= ex2_pp1_3s(252)                  ; --pass_cs
 ex2_pp2_1s(252)                  <= ex2_pp1_3c(252)                  ; --pass_cs
 ex2_pp2_1c(251)                  <= tidn                             ; --pass_s
 ex2_pp2_1s(251)                  <= ex2_pp1_3s(251)                  ; --pass_s
 ex2_pp2_1c(250)                  <= tidn                             ; --pass_s
 ex2_pp2_1s(250)                  <= ex2_pp1_3s(250)                  ; --pass_s
 ex2_pp2_1c(249)                  <= ex2_pp1_3s(249)                  ; --pass_cs
 ex2_pp2_1s(249)                  <= ex2_pp1_3c(249)                  ; --pass_cs
 ex2_pp2_1c(248)                  <= tidn                             ; --wr_csa32
    csa2_1_248: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2s(248)                   ,--i--
        b            => ex2_pp1_3c(248)                   ,--i--
        c            => ex2_pp1_3s(248)                   ,--i--
        sum          => ex2_pp2_1s(248)                   ,--o--
        car          => ex2_pp2_1c(247)                  );--o--
    csa2_1_247: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_3c(247)                   ,--i--
        b            => ex2_pp1_3s(247)                   ,--i--
        sum          => ex2_pp2_1s(247)                   ,--o--
        car          => ex2_pp2_1c(246)                  );--o--
 ex2_pp2_1k(246)                  <= tidn                             ; --start_k
    csa2_1_246: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(246)                   ,--i--
        b            => ex2_pp1_2s(246)                   ,--i--
        c            => ex2_pp1_3c(246)                   ,--i--
        d            => ex2_pp1_3s(246)                   ,--i--
        ki           => ex2_pp2_1k(246)                   ,--i--
        ko           => ex2_pp2_1k(245)                   ,--o--
        sum          => ex2_pp2_1s(246)                   ,--o--
        car          => ex2_pp2_1c(245)                  );--o--
    csa2_1_245: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2s(245)                   ,--i--
        b            => ex2_pp1_3c(245)                   ,--i--
        c            => ex2_pp1_3s(245)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex2_pp2_1k(245)                   ,--i--
        ko           => ex2_pp2_1k(244)                   ,--o--
        sum          => ex2_pp2_1s(245)                   ,--o--
        car          => ex2_pp2_1c(244)                  );--o--
    csa2_1_244: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2s(244)                   ,--i--
        b            => ex2_pp1_3c(244)                   ,--i--
        c            => ex2_pp1_3s(244)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex2_pp2_1k(244)                   ,--i--
        ko           => ex2_pp2_1k(243)                   ,--o--
        sum          => ex2_pp2_1s(244)                   ,--o--
        car          => ex2_pp2_1c(243)                  );--o--
    csa2_1_243: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(243)                   ,--i--
        b            => ex2_pp1_2s(243)                   ,--i--
        c            => ex2_pp1_3c(243)                   ,--i--
        d            => ex2_pp1_3s(243)                   ,--i--
        ki           => ex2_pp2_1k(243)                   ,--i--
        ko           => ex2_pp2_1k(242)                   ,--o--
        sum          => ex2_pp2_1s(243)                   ,--o--
        car          => ex2_pp2_1c(242)                  );--o--
    csa2_1_242: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(242)                   ,--i--
        b            => ex2_pp1_2s(242)                   ,--i--
        c            => ex2_pp1_3c(242)                   ,--i--
        d            => ex2_pp1_3s(242)                   ,--i--
        ki           => ex2_pp2_1k(242)                   ,--i--
        ko           => ex2_pp2_1k(241)                   ,--o--
        sum          => ex2_pp2_1s(242)                   ,--o--
        car          => ex2_pp2_1c(241)                  );--o--
    csa2_1_241: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(241)                   ,--i--
        b            => ex2_pp1_2s(241)                   ,--i--
        c            => ex2_pp1_3c(241)                   ,--i--
        d            => ex2_pp1_3s(241)                   ,--i--
        ki           => ex2_pp2_1k(241)                   ,--i--
        ko           => ex2_pp2_1k(240)                   ,--o--
        sum          => ex2_pp2_1s(241)                   ,--o--
        car          => ex2_pp2_1c(240)                  );--o--
    csa2_1_240: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(240)                   ,--i--
        b            => ex2_pp1_2s(240)                   ,--i--
        c            => ex2_pp1_3c(240)                   ,--i--
        d            => ex2_pp1_3s(240)                   ,--i--
        ki           => ex2_pp2_1k(240)                   ,--i--
        ko           => ex2_pp2_1k(239)                   ,--o--
        sum          => ex2_pp2_1s(240)                   ,--o--
        car          => ex2_pp2_1c(239)                  );--o--
    csa2_1_239: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(239)                   ,--i--
        b            => ex2_pp1_2s(239)                   ,--i--
        c            => ex2_pp1_3c(239)                   ,--i--
        d            => ex2_pp1_3s(239)                   ,--i--
        ki           => ex2_pp2_1k(239)                   ,--i--
        ko           => ex2_pp2_1k(238)                   ,--o--
        sum          => ex2_pp2_1s(239)                   ,--o--
        car          => ex2_pp2_1c(238)                  );--o--
    csa2_1_238: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(238)                   ,--i--
        b            => ex2_pp1_2s(238)                   ,--i--
        c            => ex2_pp1_3c(238)                   ,--i--
        d            => ex2_pp1_3s(238)                   ,--i--
        ki           => ex2_pp2_1k(238)                   ,--i--
        ko           => ex2_pp2_1k(237)                   ,--o--
        sum          => ex2_pp2_1s(238)                   ,--o--
        car          => ex2_pp2_1c(237)                  );--o--
    csa2_1_237: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(237)                   ,--i--
        b            => ex2_pp1_2s(237)                   ,--i--
        c            => ex2_pp1_3c(237)                   ,--i--
        d            => ex2_pp1_3s(237)                   ,--i--
        ki           => ex2_pp2_1k(237)                   ,--i--
        ko           => ex2_pp2_1k(236)                   ,--o--
        sum          => ex2_pp2_1s(237)                   ,--o--
        car          => ex2_pp2_1c(236)                  );--o--
    csa2_1_236: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(236)                   ,--i--
        b            => ex2_pp1_2s(236)                   ,--i--
        c            => ex2_pp1_3c(236)                   ,--i--
        d            => ex2_pp1_3s(236)                   ,--i--
        ki           => ex2_pp2_1k(236)                   ,--i--
        ko           => ex2_pp2_1k(235)                   ,--o--
        sum          => ex2_pp2_1s(236)                   ,--o--
        car          => ex2_pp2_1c(235)                  );--o--
    csa2_1_235: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(235)                   ,--i--
        b            => ex2_pp1_2s(235)                   ,--i--
        c            => ex2_pp1_3c(235)                   ,--i--
        d            => ex2_pp1_3s(235)                   ,--i--
        ki           => ex2_pp2_1k(235)                   ,--i--
        ko           => ex2_pp2_1k(234)                   ,--o--
        sum          => ex2_pp2_1s(235)                   ,--o--
        car          => ex2_pp2_1c(234)                  );--o--
    csa2_1_234: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(234)                   ,--i--
        b            => ex2_pp1_2s(234)                   ,--i--
        c            => ex2_pp1_3c(234)                   ,--i--
        d            => ex2_pp1_3s(234)                   ,--i--
        ki           => ex2_pp2_1k(234)                   ,--i--
        ko           => ex2_pp2_1k(233)                   ,--o--
        sum          => ex2_pp2_1s(234)                   ,--o--
        car          => ex2_pp2_1c(233)                  );--o--
    csa2_1_233: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(233)                   ,--i--
        b            => ex2_pp1_2s(233)                   ,--i--
        c            => ex2_pp1_3c(233)                   ,--i--
        d            => ex2_pp1_3s(233)                   ,--i--
        ki           => ex2_pp2_1k(233)                   ,--i--
        ko           => ex2_pp2_1k(232)                   ,--o--
        sum          => ex2_pp2_1s(233)                   ,--o--
        car          => ex2_pp2_1c(232)                  );--o--
    csa2_1_232: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(232)                   ,--i--
        b            => ex2_pp1_2s(232)                   ,--i--
        c            => ex2_pp1_3c(232)                   ,--i--
        d            => ex2_pp1_3s(232)                   ,--i--
        ki           => ex2_pp2_1k(232)                   ,--i--
        ko           => ex2_pp2_1k(231)                   ,--o--
        sum          => ex2_pp2_1s(232)                   ,--o--
        car          => ex2_pp2_1c(231)                  );--o--
    csa2_1_231: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(231)                   ,--i--
        b            => ex2_pp1_2s(231)                   ,--i--
        c            => ex2_pp1_3c(231)                   ,--i--
        d            => ex2_pp1_3s(231)                   ,--i--
        ki           => ex2_pp2_1k(231)                   ,--i--
        ko           => ex2_pp2_1k(230)                   ,--o--
        sum          => ex2_pp2_1s(231)                   ,--o--
        car          => ex2_pp2_1c(230)                  );--o--
    csa2_1_230: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(230)                   ,--i--
        b            => ex2_pp1_2s(230)                   ,--i--
        c            => ex2_pp1_3c(230)                   ,--i--
        d            => ex2_pp1_3s(230)                   ,--i--
        ki           => ex2_pp2_1k(230)                   ,--i--
        ko           => ex2_pp2_1k(229)                   ,--o--
        sum          => ex2_pp2_1s(230)                   ,--o--
        car          => ex2_pp2_1c(229)                  );--o--
    csa2_1_229: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(229)                   ,--i--
        b            => ex2_pp1_2s(229)                   ,--i--
        c            => ex2_pp1_3c(229)                   ,--i--
        d            => ex2_pp1_3s(229)                   ,--i--
        ki           => ex2_pp2_1k(229)                   ,--i--
        ko           => ex2_pp2_1k(228)                   ,--o--
        sum          => ex2_pp2_1s(229)                   ,--o--
        car          => ex2_pp2_1c(228)                  );--o--
    csa2_1_228: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(228)                   ,--i--
        b            => ex2_pp1_2s(228)                   ,--i--
        c            => ex2_pp1_3c(228)                   ,--i--
        d            => ex2_pp1_3s(228)                   ,--i--
        ki           => ex2_pp2_1k(228)                   ,--i--
        ko           => ex2_pp2_1k(227)                   ,--o--
        sum          => ex2_pp2_1s(228)                   ,--o--
        car          => ex2_pp2_1c(227)                  );--o--
    csa2_1_227: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(227)                   ,--i--
        b            => ex2_pp1_2s(227)                   ,--i--
        c            => ex2_pp1_3c(227)                   ,--i--
        d            => ex2_pp1_3s(227)                   ,--i--
        ki           => ex2_pp2_1k(227)                   ,--i--
        ko           => ex2_pp2_1k(226)                   ,--o--
        sum          => ex2_pp2_1s(227)                   ,--o--
        car          => ex2_pp2_1c(226)                  );--o--
    csa2_1_226: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(226)                   ,--i--
        b            => ex2_pp1_2s(226)                   ,--i--
        c            => ex2_pp1_3c(226)                   ,--i--
        d            => ex2_pp1_3s(226)                   ,--i--
        ki           => ex2_pp2_1k(226)                   ,--i--
        ko           => ex2_pp2_1k(225)                   ,--o--
        sum          => ex2_pp2_1s(226)                   ,--o--
        car          => ex2_pp2_1c(225)                  );--o--
    csa2_1_225: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(225)                   ,--i--
        b            => ex2_pp1_2s(225)                   ,--i--
        c            => ex2_pp1_3c(225)                   ,--i--
        d            => ex2_pp1_3s(225)                   ,--i--
        ki           => ex2_pp2_1k(225)                   ,--i--
        ko           => ex2_pp2_1k(224)                   ,--o--
        sum          => ex2_pp2_1s(225)                   ,--o--
        car          => ex2_pp2_1c(224)                  );--o--
    csa2_1_224: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(224)                   ,--i--
        b            => ex2_pp1_2s(224)                   ,--i--
        c            => ex2_pp1_3c(224)                   ,--i--
        d            => ex2_pp1_3s(224)                   ,--i--
        ki           => ex2_pp2_1k(224)                   ,--i--
        ko           => ex2_pp2_1k(223)                   ,--o--
        sum          => ex2_pp2_1s(224)                   ,--o--
        car          => ex2_pp2_1c(223)                  );--o--
    csa2_1_223: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(223)                   ,--i--
        b            => ex2_pp1_2s(223)                   ,--i--
        c            => ex2_pp1_3c(223)                   ,--i--
        d            => ex2_pp1_3s(223)                   ,--i--
        ki           => ex2_pp2_1k(223)                   ,--i--
        ko           => ex2_pp2_1k(222)                   ,--o--
        sum          => ex2_pp2_1s(223)                   ,--o--
        car          => ex2_pp2_1c(222)                  );--o--
    csa2_1_222: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(222)                   ,--i--
        b            => ex2_pp1_2s(222)                   ,--i--
        c            => ex2_pp1_3c(222)                   ,--i--
        d            => ex2_pp1_3s(222)                   ,--i--
        ki           => ex2_pp2_1k(222)                   ,--i--
        ko           => ex2_pp2_1k(221)                   ,--o--
        sum          => ex2_pp2_1s(222)                   ,--o--
        car          => ex2_pp2_1c(221)                  );--o--
    csa2_1_221: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(221)                   ,--i--
        b            => ex2_pp1_2s(221)                   ,--i--
        c            => ex2_pp1_3c(221)                   ,--i--
        d            => ex2_pp1_3s(221)                   ,--i--
        ki           => ex2_pp2_1k(221)                   ,--i--
        ko           => ex2_pp2_1k(220)                   ,--o--
        sum          => ex2_pp2_1s(221)                   ,--o--
        car          => ex2_pp2_1c(220)                  );--o--
    csa2_1_220: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(220)                   ,--i--
        b            => ex2_pp1_2s(220)                   ,--i--
        c            => ex2_pp1_3c(220)                   ,--i--
        d            => ex2_pp1_3s(220)                   ,--i--
        ki           => ex2_pp2_1k(220)                   ,--i--
        ko           => ex2_pp2_1k(219)                   ,--o--
        sum          => ex2_pp2_1s(220)                   ,--o--
        car          => ex2_pp2_1c(219)                  );--o--
    csa2_1_219: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(219)                   ,--i--
        b            => ex2_pp1_2s(219)                   ,--i--
        c            => ex2_pp1_3c(219)                   ,--i--
        d            => ex2_pp1_3s(219)                   ,--i--
        ki           => ex2_pp2_1k(219)                   ,--i--
        ko           => ex2_pp2_1k(218)                   ,--o--
        sum          => ex2_pp2_1s(219)                   ,--o--
        car          => ex2_pp2_1c(218)                  );--o--
    csa2_1_218: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(218)                   ,--i--
        b            => ex2_pp1_2s(218)                   ,--i--
        c            => ex2_pp1_3c(218)                   ,--i--
        d            => ex2_pp1_3s(218)                   ,--i--
        ki           => ex2_pp2_1k(218)                   ,--i--
        ko           => ex2_pp2_1k(217)                   ,--o--
        sum          => ex2_pp2_1s(218)                   ,--o--
        car          => ex2_pp2_1c(217)                  );--o--
    csa2_1_217: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(217)                   ,--i--
        b            => ex2_pp1_2s(217)                   ,--i--
        c            => ex2_pp1_3c(217)                   ,--i--
        d            => ex2_pp1_3s(217)                   ,--i--
        ki           => ex2_pp2_1k(217)                   ,--i--
        ko           => ex2_pp2_1k(216)                   ,--o--
        sum          => ex2_pp2_1s(217)                   ,--o--
        car          => ex2_pp2_1c(216)                  );--o--
    csa2_1_216: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(216)                   ,--i--
        b            => ex2_pp1_2s(216)                   ,--i--
        c            => ex2_pp1_3c(216)                   ,--i--
        d            => ex2_pp1_3s(216)                   ,--i--
        ki           => ex2_pp2_1k(216)                   ,--i--
        ko           => ex2_pp2_1k(215)                   ,--o--
        sum          => ex2_pp2_1s(216)                   ,--o--
        car          => ex2_pp2_1c(215)                  );--o--
    csa2_1_215: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(215)                   ,--i--
        b            => ex2_pp1_2s(215)                   ,--i--
        c            => ex2_pp1_3c(215)                   ,--i--
        d            => ex2_pp1_3s(215)                   ,--i--
        ki           => ex2_pp2_1k(215)                   ,--i--
        ko           => ex2_pp2_1k(214)                   ,--o--
        sum          => ex2_pp2_1s(215)                   ,--o--
        car          => ex2_pp2_1c(214)                  );--o--
    csa2_1_214: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(214)                   ,--i--
        b            => ex2_pp1_2s(214)                   ,--i--
        c            => ex2_pp1_3s(214)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex2_pp2_1k(214)                   ,--i--
        ko           => ex2_pp2_1k(213)                   ,--o--
        sum          => ex2_pp2_1s(214)                   ,--o--
        car          => ex2_pp2_1c(213)                  );--o--
    csa2_1_213: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(213)                   ,--i--
        b            => ex2_pp1_2s(213)                   ,--i--
        c            => ex2_pp2_1k(213)                   ,--i--
        sum          => ex2_pp2_1s(213)                   ,--o--
        car          => ex2_pp2_1c(212)                  );--o--
    csa2_1_212: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_2c(212)                   ,--i--
        b            => ex2_pp1_2s(212)                   ,--i--
        sum          => ex2_pp2_1s(212)                   ,--o--
        car          => ex2_pp2_1c(211)                  );--o--
    csa2_1_211: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_2c(211)                   ,--i--
        b            => ex2_pp1_2s(211)                   ,--i--
        sum          => ex2_pp2_1s(211)                   ,--o--
        car          => ex2_pp2_1c(210)                  );--o--
    csa2_1_210: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_2c(210)                   ,--i--
        b            => ex2_pp1_2s(210)                   ,--i--
        sum          => ex2_pp2_1s(210)                   ,--o--
        car          => ex2_pp2_1c(209)                  );--o--
    csa2_1_209: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_2c(209)                   ,--i--
        b            => ex2_pp1_2s(209)                   ,--i--
        sum          => ex2_pp2_1s(209)                   ,--o--
        car          => ex2_pp2_1c(208)                  );--o--
 ex2_pp2_1s(208)                  <= ex2_pp1_2s(208)                  ; --pass_x_s



 ------- <csa2_2> -----

    csa2_2_264: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_5c(264)                   ,--i--
        b            => ex2_pp1_5s(264)                   ,--i--
        sum          => ex2_pp2_2s(264)                   ,--o--
        car          => ex2_pp2_2c(263)                  );--o--
 ex2_pp2_2s(263)                  <= ex2_pp1_5s(263)                  ; --pass_x_s
 ex2_pp2_2c(262)                  <= tidn                             ; --pass_s
 ex2_pp2_2s(262)                  <= ex2_pp1_5s(262)                  ; --pass_s
 ex2_pp2_2c(261)                  <= ex2_pp1_5s(261)                  ; --pass_cs
 ex2_pp2_2s(261)                  <= ex2_pp1_5c(261)                  ; --pass_cs
 ex2_pp2_2c(260)                  <= tidn                             ; --wr_csa32
    csa2_2_260: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4s(260)                   ,--i--
        b            => ex2_pp1_5c(260)                   ,--i--
        c            => ex2_pp1_5s(260)                   ,--i--
        sum          => ex2_pp2_2s(260)                   ,--o--
        car          => ex2_pp2_2c(259)                  );--o--
    csa2_2_259: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_5c(259)                   ,--i--
        b            => ex2_pp1_5s(259)                   ,--i--
        sum          => ex2_pp2_2s(259)                   ,--o--
        car          => ex2_pp2_2c(258)                  );--o--
 ex2_pp2_2k(258)                  <= tidn                             ; --start_k
    csa2_2_258: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(258)                   ,--i--
        b            => ex2_pp1_4s(258)                   ,--i--
        c            => ex2_pp1_5c(258)                   ,--i--
        d            => ex2_pp1_5s(258)                   ,--i--
        ki           => ex2_pp2_2k(258)                   ,--i--
        ko           => ex2_pp2_2k(257)                   ,--o--
        sum          => ex2_pp2_2s(258)                   ,--o--
        car          => ex2_pp2_2c(257)                  );--o--
    csa2_2_257: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4s(257)                   ,--i--
        b            => ex2_pp1_5c(257)                   ,--i--
        c            => ex2_pp1_5s(257)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex2_pp2_2k(257)                   ,--i--
        ko           => ex2_pp2_2k(256)                   ,--o--
        sum          => ex2_pp2_2s(257)                   ,--o--
        car          => ex2_pp2_2c(256)                  );--o--
    csa2_2_256: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4s(256)                   ,--i--
        b            => ex2_pp1_5c(256)                   ,--i--
        c            => ex2_pp1_5s(256)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex2_pp2_2k(256)                   ,--i--
        ko           => ex2_pp2_2k(255)                   ,--o--
        sum          => ex2_pp2_2s(256)                   ,--o--
        car          => ex2_pp2_2c(255)                  );--o--
    csa2_2_255: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(255)                   ,--i--
        b            => ex2_pp1_4s(255)                   ,--i--
        c            => ex2_pp1_5c(255)                   ,--i--
        d            => ex2_pp1_5s(255)                   ,--i--
        ki           => ex2_pp2_2k(255)                   ,--i--
        ko           => ex2_pp2_2k(254)                   ,--o--
        sum          => ex2_pp2_2s(255)                   ,--o--
        car          => ex2_pp2_2c(254)                  );--o--
    csa2_2_254: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(254)                   ,--i--
        b            => ex2_pp1_4s(254)                   ,--i--
        c            => ex2_pp1_5c(254)                   ,--i--
        d            => ex2_pp1_5s(254)                   ,--i--
        ki           => ex2_pp2_2k(254)                   ,--i--
        ko           => ex2_pp2_2k(253)                   ,--o--
        sum          => ex2_pp2_2s(254)                   ,--o--
        car          => ex2_pp2_2c(253)                  );--o--
    csa2_2_253: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(253)                   ,--i--
        b            => ex2_pp1_4s(253)                   ,--i--
        c            => ex2_pp1_5c(253)                   ,--i--
        d            => ex2_pp1_5s(253)                   ,--i--
        ki           => ex2_pp2_2k(253)                   ,--i--
        ko           => ex2_pp2_2k(252)                   ,--o--
        sum          => ex2_pp2_2s(253)                   ,--o--
        car          => ex2_pp2_2c(252)                  );--o--
    csa2_2_252: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(252)                   ,--i--
        b            => ex2_pp1_4s(252)                   ,--i--
        c            => ex2_pp1_5c(252)                   ,--i--
        d            => ex2_pp1_5s(252)                   ,--i--
        ki           => ex2_pp2_2k(252)                   ,--i--
        ko           => ex2_pp2_2k(251)                   ,--o--
        sum          => ex2_pp2_2s(252)                   ,--o--
        car          => ex2_pp2_2c(251)                  );--o--
    csa2_2_251: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(251)                   ,--i--
        b            => ex2_pp1_4s(251)                   ,--i--
        c            => ex2_pp1_5c(251)                   ,--i--
        d            => ex2_pp1_5s(251)                   ,--i--
        ki           => ex2_pp2_2k(251)                   ,--i--
        ko           => ex2_pp2_2k(250)                   ,--o--
        sum          => ex2_pp2_2s(251)                   ,--o--
        car          => ex2_pp2_2c(250)                  );--o--
    csa2_2_250: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(250)                   ,--i--
        b            => ex2_pp1_4s(250)                   ,--i--
        c            => ex2_pp1_5c(250)                   ,--i--
        d            => ex2_pp1_5s(250)                   ,--i--
        ki           => ex2_pp2_2k(250)                   ,--i--
        ko           => ex2_pp2_2k(249)                   ,--o--
        sum          => ex2_pp2_2s(250)                   ,--o--
        car          => ex2_pp2_2c(249)                  );--o--
    csa2_2_249: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(249)                   ,--i--
        b            => ex2_pp1_4s(249)                   ,--i--
        c            => ex2_pp1_5c(249)                   ,--i--
        d            => ex2_pp1_5s(249)                   ,--i--
        ki           => ex2_pp2_2k(249)                   ,--i--
        ko           => ex2_pp2_2k(248)                   ,--o--
        sum          => ex2_pp2_2s(249)                   ,--o--
        car          => ex2_pp2_2c(248)                  );--o--
    csa2_2_248: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(248)                   ,--i--
        b            => ex2_pp1_4s(248)                   ,--i--
        c            => ex2_pp1_5c(248)                   ,--i--
        d            => ex2_pp1_5s(248)                   ,--i--
        ki           => ex2_pp2_2k(248)                   ,--i--
        ko           => ex2_pp2_2k(247)                   ,--o--
        sum          => ex2_pp2_2s(248)                   ,--o--
        car          => ex2_pp2_2c(247)                  );--o--
    csa2_2_247: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(247)                   ,--i--
        b            => ex2_pp1_4s(247)                   ,--i--
        c            => ex2_pp1_5c(247)                   ,--i--
        d            => ex2_pp1_5s(247)                   ,--i--
        ki           => ex2_pp2_2k(247)                   ,--i--
        ko           => ex2_pp2_2k(246)                   ,--o--
        sum          => ex2_pp2_2s(247)                   ,--o--
        car          => ex2_pp2_2c(246)                  );--o--
    csa2_2_246: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(246)                   ,--i--
        b            => ex2_pp1_4s(246)                   ,--i--
        c            => ex2_pp1_5c(246)                   ,--i--
        d            => ex2_pp1_5s(246)                   ,--i--
        ki           => ex2_pp2_2k(246)                   ,--i--
        ko           => ex2_pp2_2k(245)                   ,--o--
        sum          => ex2_pp2_2s(246)                   ,--o--
        car          => ex2_pp2_2c(245)                  );--o--
    csa2_2_245: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(245)                   ,--i--
        b            => ex2_pp1_4s(245)                   ,--i--
        c            => ex2_pp1_5c(245)                   ,--i--
        d            => ex2_pp1_5s(245)                   ,--i--
        ki           => ex2_pp2_2k(245)                   ,--i--
        ko           => ex2_pp2_2k(244)                   ,--o--
        sum          => ex2_pp2_2s(245)                   ,--o--
        car          => ex2_pp2_2c(244)                  );--o--
    csa2_2_244: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(244)                   ,--i--
        b            => ex2_pp1_4s(244)                   ,--i--
        c            => ex2_pp1_5c(244)                   ,--i--
        d            => ex2_pp1_5s(244)                   ,--i--
        ki           => ex2_pp2_2k(244)                   ,--i--
        ko           => ex2_pp2_2k(243)                   ,--o--
        sum          => ex2_pp2_2s(244)                   ,--o--
        car          => ex2_pp2_2c(243)                  );--o--
    csa2_2_243: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(243)                   ,--i--
        b            => ex2_pp1_4s(243)                   ,--i--
        c            => ex2_pp1_5c(243)                   ,--i--
        d            => ex2_pp1_5s(243)                   ,--i--
        ki           => ex2_pp2_2k(243)                   ,--i--
        ko           => ex2_pp2_2k(242)                   ,--o--
        sum          => ex2_pp2_2s(243)                   ,--o--
        car          => ex2_pp2_2c(242)                  );--o--
    csa2_2_242: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(242)                   ,--i--
        b            => ex2_pp1_4s(242)                   ,--i--
        c            => ex2_pp1_5c(242)                   ,--i--
        d            => ex2_pp1_5s(242)                   ,--i--
        ki           => ex2_pp2_2k(242)                   ,--i--
        ko           => ex2_pp2_2k(241)                   ,--o--
        sum          => ex2_pp2_2s(242)                   ,--o--
        car          => ex2_pp2_2c(241)                  );--o--
    csa2_2_241: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(241)                   ,--i--
        b            => ex2_pp1_4s(241)                   ,--i--
        c            => ex2_pp1_5c(241)                   ,--i--
        d            => ex2_pp1_5s(241)                   ,--i--
        ki           => ex2_pp2_2k(241)                   ,--i--
        ko           => ex2_pp2_2k(240)                   ,--o--
        sum          => ex2_pp2_2s(241)                   ,--o--
        car          => ex2_pp2_2c(240)                  );--o--
    csa2_2_240: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(240)                   ,--i--
        b            => ex2_pp1_4s(240)                   ,--i--
        c            => ex2_pp1_5c(240)                   ,--i--
        d            => ex2_pp1_5s(240)                   ,--i--
        ki           => ex2_pp2_2k(240)                   ,--i--
        ko           => ex2_pp2_2k(239)                   ,--o--
        sum          => ex2_pp2_2s(240)                   ,--o--
        car          => ex2_pp2_2c(239)                  );--o--
    csa2_2_239: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(239)                   ,--i--
        b            => ex2_pp1_4s(239)                   ,--i--
        c            => ex2_pp1_5c(239)                   ,--i--
        d            => ex2_pp1_5s(239)                   ,--i--
        ki           => ex2_pp2_2k(239)                   ,--i--
        ko           => ex2_pp2_2k(238)                   ,--o--
        sum          => ex2_pp2_2s(239)                   ,--o--
        car          => ex2_pp2_2c(238)                  );--o--
    csa2_2_238: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(238)                   ,--i--
        b            => ex2_pp1_4s(238)                   ,--i--
        c            => ex2_pp1_5c(238)                   ,--i--
        d            => ex2_pp1_5s(238)                   ,--i--
        ki           => ex2_pp2_2k(238)                   ,--i--
        ko           => ex2_pp2_2k(237)                   ,--o--
        sum          => ex2_pp2_2s(238)                   ,--o--
        car          => ex2_pp2_2c(237)                  );--o--
    csa2_2_237: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(237)                   ,--i--
        b            => ex2_pp1_4s(237)                   ,--i--
        c            => ex2_pp1_5c(237)                   ,--i--
        d            => ex2_pp1_5s(237)                   ,--i--
        ki           => ex2_pp2_2k(237)                   ,--i--
        ko           => ex2_pp2_2k(236)                   ,--o--
        sum          => ex2_pp2_2s(237)                   ,--o--
        car          => ex2_pp2_2c(236)                  );--o--
    csa2_2_236: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(236)                   ,--i--
        b            => ex2_pp1_4s(236)                   ,--i--
        c            => ex2_pp1_5c(236)                   ,--i--
        d            => ex2_pp1_5s(236)                   ,--i--
        ki           => ex2_pp2_2k(236)                   ,--i--
        ko           => ex2_pp2_2k(235)                   ,--o--
        sum          => ex2_pp2_2s(236)                   ,--o--
        car          => ex2_pp2_2c(235)                  );--o--
    csa2_2_235: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(235)                   ,--i--
        b            => ex2_pp1_4s(235)                   ,--i--
        c            => ex2_pp1_5c(235)                   ,--i--
        d            => ex2_pp1_5s(235)                   ,--i--
        ki           => ex2_pp2_2k(235)                   ,--i--
        ko           => ex2_pp2_2k(234)                   ,--o--
        sum          => ex2_pp2_2s(235)                   ,--o--
        car          => ex2_pp2_2c(234)                  );--o--
    csa2_2_234: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(234)                   ,--i--
        b            => ex2_pp1_4s(234)                   ,--i--
        c            => ex2_pp1_5c(234)                   ,--i--
        d            => ex2_pp1_5s(234)                   ,--i--
        ki           => ex2_pp2_2k(234)                   ,--i--
        ko           => ex2_pp2_2k(233)                   ,--o--
        sum          => ex2_pp2_2s(234)                   ,--o--
        car          => ex2_pp2_2c(233)                  );--o--
    csa2_2_233: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(233)                   ,--i--
        b            => ex2_pp1_4s(233)                   ,--i--
        c            => ex2_pp1_5c(233)                   ,--i--
        d            => ex2_pp1_5s(233)                   ,--i--
        ki           => ex2_pp2_2k(233)                   ,--i--
        ko           => ex2_pp2_2k(232)                   ,--o--
        sum          => ex2_pp2_2s(233)                   ,--o--
        car          => ex2_pp2_2c(232)                  );--o--
    csa2_2_232: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(232)                   ,--i--
        b            => ex2_pp1_4s(232)                   ,--i--
        c            => ex2_pp1_5c(232)                   ,--i--
        d            => ex2_pp1_5s(232)                   ,--i--
        ki           => ex2_pp2_2k(232)                   ,--i--
        ko           => ex2_pp2_2k(231)                   ,--o--
        sum          => ex2_pp2_2s(232)                   ,--o--
        car          => ex2_pp2_2c(231)                  );--o--
    csa2_2_231: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(231)                   ,--i--
        b            => ex2_pp1_4s(231)                   ,--i--
        c            => ex2_pp1_5c(231)                   ,--i--
        d            => ex2_pp1_5s(231)                   ,--i--
        ki           => ex2_pp2_2k(231)                   ,--i--
        ko           => ex2_pp2_2k(230)                   ,--o--
        sum          => ex2_pp2_2s(231)                   ,--o--
        car          => ex2_pp2_2c(230)                  );--o--
    csa2_2_230: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(230)                   ,--i--
        b            => ex2_pp1_4s(230)                   ,--i--
        c            => ex2_pp1_5c(230)                   ,--i--
        d            => ex2_pp1_5s(230)                   ,--i--
        ki           => ex2_pp2_2k(230)                   ,--i--
        ko           => ex2_pp2_2k(229)                   ,--o--
        sum          => ex2_pp2_2s(230)                   ,--o--
        car          => ex2_pp2_2c(229)                  );--o--
    csa2_2_229: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(229)                   ,--i--
        b            => ex2_pp1_4s(229)                   ,--i--
        c            => ex2_pp1_5c(229)                   ,--i--
        d            => ex2_pp1_5s(229)                   ,--i--
        ki           => ex2_pp2_2k(229)                   ,--i--
        ko           => ex2_pp2_2k(228)                   ,--o--
        sum          => ex2_pp2_2s(229)                   ,--o--
        car          => ex2_pp2_2c(228)                  );--o--
    csa2_2_228: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(228)                   ,--i--
        b            => ex2_pp1_4s(228)                   ,--i--
        c            => ex2_pp1_5c(228)                   ,--i--
        d            => ex2_pp1_5s(228)                   ,--i--
        ki           => ex2_pp2_2k(228)                   ,--i--
        ko           => ex2_pp2_2k(227)                   ,--o--
        sum          => ex2_pp2_2s(228)                   ,--o--
        car          => ex2_pp2_2c(227)                  );--o--
    csa2_2_227: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(227)                   ,--i--
        b            => ex2_pp1_4s(227)                   ,--i--
        c            => ex2_pp1_5c(227)                   ,--i--
        d            => ex2_pp1_5s(227)                   ,--i--
        ki           => ex2_pp2_2k(227)                   ,--i--
        ko           => ex2_pp2_2k(226)                   ,--o--
        sum          => ex2_pp2_2s(227)                   ,--o--
        car          => ex2_pp2_2c(226)                  );--o--
    csa2_2_226: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(226)                   ,--i--
        b            => ex2_pp1_4s(226)                   ,--i--
        c            => ex2_pp1_5s(226)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex2_pp2_2k(226)                   ,--i--
        ko           => ex2_pp2_2k(225)                   ,--o--
        sum          => ex2_pp2_2s(226)                   ,--o--
        car          => ex2_pp2_2c(225)                  );--o--
    csa2_2_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(225)                   ,--i--
        b            => ex2_pp1_4s(225)                   ,--i--
        c            => ex2_pp2_2k(225)                   ,--i--
        sum          => ex2_pp2_2s(225)                   ,--o--
        car          => ex2_pp2_2c(224)                  );--o--
    csa2_2_224: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_4c(224)                   ,--i--
        b            => ex2_pp1_4s(224)                   ,--i--
        sum          => ex2_pp2_2s(224)                   ,--o--
        car          => ex2_pp2_2c(223)                  );--o--
    csa2_2_223: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_4c(223)                   ,--i--
        b            => ex2_pp1_4s(223)                   ,--i--
        sum          => ex2_pp2_2s(223)                   ,--o--
        car          => ex2_pp2_2c(222)                  );--o--
    csa2_2_222: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_4c(222)                   ,--i--
        b            => ex2_pp1_4s(222)                   ,--i--
        sum          => ex2_pp2_2s(222)                   ,--o--
        car          => ex2_pp2_2c(221)                  );--o--
    csa2_2_221: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_4c(221)                   ,--i--
        b            => ex2_pp1_4s(221)                   ,--i--
        sum          => ex2_pp2_2s(221)                   ,--o--
        car          => ex2_pp2_2c(220)                  );--o--
 ex2_pp2_2s(220)                  <= ex2_pp1_4s(220)                  ; --pass_x_s

-----------------------------------------------
-----------------------------------------------
-----------------------------------------------




  ex3_pp2_0s_din(198 to 242) <= ex2_pp2_0s(198 to 242) ;
  ex3_pp2_0c_din(198 to 240) <= ex2_pp2_0c(198 to 240) ;
  ex3_pp2_1s_din(208 to 254) <= ex2_pp2_1s(208 to 254) ;
  ex3_pp2_1c_din(208 to 252) <= ex2_pp2_1c(208 to 252) ;
  ex3_pp2_2s_din(220 to 264) <= ex2_pp2_2s(220 to 264) ;
  ex3_pp2_2c_din(220 to 263) <= ex2_pp2_2c(220 to 263) ;


--==================================================================================
--== EX3 ( finish compression <6:2> , feedback compression with previous result )
--==================================================================================

  u_0s_qi: ex3_pp2_0s      (198 to 242) <= not ex3_pp2_0s_q_b(198 to 242) ;
  u_0c_qi: ex3_pp2_0c      (198 to 240) <= not ex3_pp2_0c_q_b(198 to 240) ;

  u_1s_qi:   ex3_pp2_1s_x  (208 to 254) <= not ex3_pp2_1s_q_b(208 to 254) ;
  u_1c_qi:   ex3_pp2_1c_x  (208 to 252) <= not ex3_pp2_1c_q_b(208 to 252) ;
  u_2s_qi:   ex3_pp2_2s_x  (220 to 264) <= not ex3_pp2_2s_q_b(220 to 264) ;
  u_2c_qi:   ex3_pp2_2c_x  (220 to 263) <= not ex3_pp2_2c_q_b(220 to 263) ;

  u_1s_mini: ex3_pp2_1s_x_b(208 to 254) <= not ex3_pp2_1s_x  (208 to 254) ;
  u_1c_mini: ex3_pp2_1c_x_b(208 to 252) <= not ex3_pp2_1c_x  (208 to 252) ;
  u_2s_mini: ex3_pp2_2s_x_b(220 to 264) <= not ex3_pp2_2s_x  (220 to 264) ;
  u_2c_mini: ex3_pp2_2c_x_b(220 to 263) <= not ex3_pp2_2c_x  (220 to 263) ;

  u_1s_mind: ex3_pp2_1s    (208 to 254) <= not ex3_pp2_1s_x_b(208 to 254) ;
  u_1c_mind: ex3_pp2_1c    (208 to 252) <= not ex3_pp2_1c_x_b(208 to 252) ;
  u_2s_mind: ex3_pp2_2s    (220 to 264) <= not ex3_pp2_2s_x_b(220 to 264) ;
  u_2c_mind: ex3_pp2_2c    (220 to 263) <= not ex3_pp2_2c_x_b(220 to 263) ;








       --***********************************
       --** compression level 3
       --***********************************

    -- g3 : for i in 196 to 264 generate
        --
        -- csa3_0: entity work.c_prism_csa32 port map(
        --    a       => ex3_pp2_0s(i)      ,--i--
        --    b       => ex3_pp2_0c(i)      ,--i--
        --    c       => ex3_pp2_1s(i)      ,--i--
        --    sum     => ex3_pp3_0s(i)      ,--o--
        --    car     => ex3_pp3_0c(i-1)   );--o--
        --
        -- csa3_1: entity work.c_prism_csa32 port map(
        --   a       => ex3_pp2_1c(i)      ,--i--
        --   b       => ex3_pp2_2s(i)      ,--i--
        --   c       => ex3_pp2_2c(i)      ,--i--
        --   sum     => ex3_pp3_1s(i)      ,--o--
        --   car     => ex3_pp3_1c(i-1)   );--o--
        --
    -- end generate;


 ------- <csa3_0> -----

 ex3_pp3_0s(252)                  <= ex3_pp2_1c(252)                  ; --pass_s
 ex3_pp3_0s(251)                  <= tidn                             ; --pass_none
 ex3_pp3_0s(250)                  <= tidn                             ; --pass_none
 ex3_pp3_0s(249)                  <= ex3_pp2_1c(249)                  ; --pass_s
 ex3_pp3_0s(248)                  <= tidn                             ; --pass_none
 ex3_pp3_0s(247)                  <= ex3_pp2_1c(247)                  ; --pass_s
 ex3_pp3_0s(246)                  <= ex3_pp2_1c(246)                  ; --pass_s
 ex3_pp3_0s(245)                  <= ex3_pp2_1c(245)                  ; --pass_s
 ex3_pp3_0s(244)                  <= ex3_pp2_1c(244)                  ; --pass_s
 ex3_pp3_0s(243)                  <= ex3_pp2_1c(243)                  ; --pass_s
 ex3_pp3_0c(242)                  <= ex3_pp2_1c(242)                  ; --pass_cs
 ex3_pp3_0s(242)                  <= ex3_pp2_0s(242)                  ; --pass_cs
 ex3_pp3_0c(241)                  <= tidn                             ; --pass_s
 ex3_pp3_0s(241)                  <= ex3_pp2_1c(241)                  ; --pass_s
 ex3_pp3_0c(240)                  <= tidn                             ; --wr_csa32
    csa3_0_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(240)                   ,--i--
        b            => ex3_pp2_0s(240)                   ,--i--
        c            => ex3_pp2_1c(240)                   ,--i--
        sum          => ex3_pp3_0s(240)                   ,--o--
        car          => ex3_pp3_0c(239)                  );--o--
    csa3_0_239: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0s(239)                   ,--i--
        b            => ex3_pp2_1c(239)                   ,--i--
        sum          => ex3_pp3_0s(239)                   ,--o--
        car          => ex3_pp3_0c(238)                  );--o--
    csa3_0_238: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0s(238)                   ,--i--
        b            => ex3_pp2_1c(238)                   ,--i--
        sum          => ex3_pp3_0s(238)                   ,--o--
        car          => ex3_pp3_0c(237)                  );--o--
    csa3_0_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(237)                   ,--i--
        b            => ex3_pp2_0s(237)                   ,--i--
        c            => ex3_pp2_1c(237)                   ,--i--
        sum          => ex3_pp3_0s(237)                   ,--o--
        car          => ex3_pp3_0c(236)                  );--o--
    csa3_0_236: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0s(236)                   ,--i--
        b            => ex3_pp2_1c(236)                   ,--i--
        sum          => ex3_pp3_0s(236)                   ,--o--
        car          => ex3_pp3_0c(235)                  );--o--
    csa3_0_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(235)                   ,--i--
        b            => ex3_pp2_0s(235)                   ,--i--
        c            => ex3_pp2_1c(235)                   ,--i--
        sum          => ex3_pp3_0s(235)                   ,--o--
        car          => ex3_pp3_0c(234)                  );--o--
    csa3_0_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(234)                   ,--i--
        b            => ex3_pp2_0s(234)                   ,--i--
        c            => ex3_pp2_1c(234)                   ,--i--
        sum          => ex3_pp3_0s(234)                   ,--o--
        car          => ex3_pp3_0c(233)                  );--o--
    csa3_0_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(233)                   ,--i--
        b            => ex3_pp2_0s(233)                   ,--i--
        c            => ex3_pp2_1c(233)                   ,--i--
        sum          => ex3_pp3_0s(233)                   ,--o--
        car          => ex3_pp3_0c(232)                  );--o--
    csa3_0_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(232)                   ,--i--
        b            => ex3_pp2_0s(232)                   ,--i--
        c            => ex3_pp2_1c(232)                   ,--i--
        sum          => ex3_pp3_0s(232)                   ,--o--
        car          => ex3_pp3_0c(231)                  );--o--
    csa3_0_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(231)                   ,--i--
        b            => ex3_pp2_0s(231)                   ,--i--
        c            => ex3_pp2_1c(231)                   ,--i--
        sum          => ex3_pp3_0s(231)                   ,--o--
        car          => ex3_pp3_0c(230)                  );--o--
    csa3_0_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(230)                   ,--i--
        b            => ex3_pp2_0s(230)                   ,--i--
        c            => ex3_pp2_1c(230)                   ,--i--
        sum          => ex3_pp3_0s(230)                   ,--o--
        car          => ex3_pp3_0c(229)                  );--o--
    csa3_0_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(229)                   ,--i--
        b            => ex3_pp2_0s(229)                   ,--i--
        c            => ex3_pp2_1c(229)                   ,--i--
        sum          => ex3_pp3_0s(229)                   ,--o--
        car          => ex3_pp3_0c(228)                  );--o--
    csa3_0_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(228)                   ,--i--
        b            => ex3_pp2_0s(228)                   ,--i--
        c            => ex3_pp2_1c(228)                   ,--i--
        sum          => ex3_pp3_0s(228)                   ,--o--
        car          => ex3_pp3_0c(227)                  );--o--
    csa3_0_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(227)                   ,--i--
        b            => ex3_pp2_0s(227)                   ,--i--
        c            => ex3_pp2_1c(227)                   ,--i--
        sum          => ex3_pp3_0s(227)                   ,--o--
        car          => ex3_pp3_0c(226)                  );--o--
    csa3_0_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(226)                   ,--i--
        b            => ex3_pp2_0s(226)                   ,--i--
        c            => ex3_pp2_1c(226)                   ,--i--
        sum          => ex3_pp3_0s(226)                   ,--o--
        car          => ex3_pp3_0c(225)                  );--o--
    csa3_0_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(225)                   ,--i--
        b            => ex3_pp2_0s(225)                   ,--i--
        c            => ex3_pp2_1c(225)                   ,--i--
        sum          => ex3_pp3_0s(225)                   ,--o--
        car          => ex3_pp3_0c(224)                  );--o--
    csa3_0_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(224)                   ,--i--
        b            => ex3_pp2_0s(224)                   ,--i--
        c            => ex3_pp2_1c(224)                   ,--i--
        sum          => ex3_pp3_0s(224)                   ,--o--
        car          => ex3_pp3_0c(223)                  );--o--
    csa3_0_223: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(223)                   ,--i--
        b            => ex3_pp2_0s(223)                   ,--i--
        c            => ex3_pp2_1c(223)                   ,--i--
        sum          => ex3_pp3_0s(223)                   ,--o--
        car          => ex3_pp3_0c(222)                  );--o--
    csa3_0_222: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(222)                   ,--i--
        b            => ex3_pp2_0s(222)                   ,--i--
        c            => ex3_pp2_1c(222)                   ,--i--
        sum          => ex3_pp3_0s(222)                   ,--o--
        car          => ex3_pp3_0c(221)                  );--o--
    csa3_0_221: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(221)                   ,--i--
        b            => ex3_pp2_0s(221)                   ,--i--
        c            => ex3_pp2_1c(221)                   ,--i--
        sum          => ex3_pp3_0s(221)                   ,--o--
        car          => ex3_pp3_0c(220)                  );--o--
    csa3_0_220: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(220)                   ,--i--
        b            => ex3_pp2_0s(220)                   ,--i--
        c            => ex3_pp2_1c(220)                   ,--i--
        sum          => ex3_pp3_0s(220)                   ,--o--
        car          => ex3_pp3_0c(219)                  );--o--
    csa3_0_219: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(219)                   ,--i--
        b            => ex3_pp2_0s(219)                   ,--i--
        c            => ex3_pp2_1c(219)                   ,--i--
        sum          => ex3_pp3_0s(219)                   ,--o--
        car          => ex3_pp3_0c(218)                  );--o--
    csa3_0_218: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(218)                   ,--i--
        b            => ex3_pp2_0s(218)                   ,--i--
        c            => ex3_pp2_1c(218)                   ,--i--
        sum          => ex3_pp3_0s(218)                   ,--o--
        car          => ex3_pp3_0c(217)                  );--o--
    csa3_0_217: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(217)                   ,--i--
        b            => ex3_pp2_0s(217)                   ,--i--
        c            => ex3_pp2_1c(217)                   ,--i--
        sum          => ex3_pp3_0s(217)                   ,--o--
        car          => ex3_pp3_0c(216)                  );--o--
    csa3_0_216: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(216)                   ,--i--
        b            => ex3_pp2_0s(216)                   ,--i--
        c            => ex3_pp2_1c(216)                   ,--i--
        sum          => ex3_pp3_0s(216)                   ,--o--
        car          => ex3_pp3_0c(215)                  );--o--
    csa3_0_215: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(215)                   ,--i--
        b            => ex3_pp2_0s(215)                   ,--i--
        c            => ex3_pp2_1c(215)                   ,--i--
        sum          => ex3_pp3_0s(215)                   ,--o--
        car          => ex3_pp3_0c(214)                  );--o--
    csa3_0_214: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(214)                   ,--i--
        b            => ex3_pp2_0s(214)                   ,--i--
        c            => ex3_pp2_1c(214)                   ,--i--
        sum          => ex3_pp3_0s(214)                   ,--o--
        car          => ex3_pp3_0c(213)                  );--o--
    csa3_0_213: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(213)                   ,--i--
        b            => ex3_pp2_0s(213)                   ,--i--
        c            => ex3_pp2_1c(213)                   ,--i--
        sum          => ex3_pp3_0s(213)                   ,--o--
        car          => ex3_pp3_0c(212)                  );--o--
    csa3_0_212: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(212)                   ,--i--
        b            => ex3_pp2_0s(212)                   ,--i--
        c            => ex3_pp2_1c(212)                   ,--i--
        sum          => ex3_pp3_0s(212)                   ,--o--
        car          => ex3_pp3_0c(211)                  );--o--
    csa3_0_211: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(211)                   ,--i--
        b            => ex3_pp2_0s(211)                   ,--i--
        c            => ex3_pp2_1c(211)                   ,--i--
        sum          => ex3_pp3_0s(211)                   ,--o--
        car          => ex3_pp3_0c(210)                  );--o--
    csa3_0_210: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(210)                   ,--i--
        b            => ex3_pp2_0s(210)                   ,--i--
        c            => ex3_pp2_1c(210)                   ,--i--
        sum          => ex3_pp3_0s(210)                   ,--o--
        car          => ex3_pp3_0c(209)                  );--o--
    csa3_0_209: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(209)                   ,--i--
        b            => ex3_pp2_0s(209)                   ,--i--
        c            => ex3_pp2_1c(209)                   ,--i--
        sum          => ex3_pp3_0s(209)                   ,--o--
        car          => ex3_pp3_0c(208)                  );--o--
    csa3_0_208: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(208)                   ,--i--
        b            => ex3_pp2_0s(208)                   ,--i--
        c            => ex3_pp2_1c(208)                   ,--i--
        sum          => ex3_pp3_0s(208)                   ,--o--
        car          => ex3_pp3_0c(207)                  );--o--
    csa3_0_207: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(207)                   ,--i--
        b            => ex3_pp2_0s(207)                   ,--i--
        sum          => ex3_pp3_0s(207)                   ,--o--
        car          => ex3_pp3_0c(206)                  );--o--
    csa3_0_206: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(206)                   ,--i--
        b            => ex3_pp2_0s(206)                   ,--i--
        sum          => ex3_pp3_0s(206)                   ,--o--
        car          => ex3_pp3_0c(205)                  );--o--
    csa3_0_205: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(205)                   ,--i--
        b            => ex3_pp2_0s(205)                   ,--i--
        sum          => ex3_pp3_0s(205)                   ,--o--
        car          => ex3_pp3_0c(204)                  );--o--
    csa3_0_204: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(204)                   ,--i--
        b            => ex3_pp2_0s(204)                   ,--i--
        sum          => ex3_pp3_0s(204)                   ,--o--
        car          => ex3_pp3_0c(203)                  );--o--
    csa3_0_203: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(203)                   ,--i--
        b            => ex3_pp2_0s(203)                   ,--i--
        sum          => ex3_pp3_0s(203)                   ,--o--
        car          => ex3_pp3_0c(202)                  );--o--
    csa3_0_202: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(202)                   ,--i--
        b            => ex3_pp2_0s(202)                   ,--i--
        sum          => ex3_pp3_0s(202)                   ,--o--
        car          => ex3_pp3_0c(201)                  );--o--
    csa3_0_201: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(201)                   ,--i--
        b            => ex3_pp2_0s(201)                   ,--i--
        sum          => ex3_pp3_0s(201)                   ,--o--
        car          => ex3_pp3_0c(200)                  );--o--
    csa3_0_200: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(200)                   ,--i--
        b            => ex3_pp2_0s(200)                   ,--i--
        sum          => ex3_pp3_0s(200)                   ,--o--
        car          => ex3_pp3_0c(199)                  );--o--
    csa3_0_199: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(199)                   ,--i--
        b            => ex3_pp2_0s(199)                   ,--i--
        sum          => ex3_pp3_0s(199)                   ,--o--
        car          => ex3_pp3_0c(198)                  );--o--
    csa3_0_198: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(198)                   ,--i--
        b            => ex3_pp2_0s(198)                   ,--i--
        sum          => ex3_pp3_0s(198)                   ,--o--
        car          => ex3_pp3_0c(197)                  );--o--


 ------- <csa3_1> -----

 ex3_pp3_1s(264)                  <= ex3_pp2_2s(264)                  ; --pass_s
    csa3_1_263: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_2c(263)                   ,--i--
        b            => ex3_pp2_2s(263)                   ,--i--
        sum          => ex3_pp3_1s(263)                   ,--o--
        car          => ex3_pp3_1c(262)                  );--o--
 ex3_pp3_1s(262)                  <= ex3_pp2_2s(262)                  ; --pass_x_s
 ex3_pp3_1c(261)                  <= ex3_pp2_2s(261)                  ; --pass_cs
 ex3_pp3_1s(261)                  <= ex3_pp2_2c(261)                  ; --pass_cs
 ex3_pp3_1c(260)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(260)                  <= ex3_pp2_2s(260)                  ; --pass_s
 ex3_pp3_1c(259)                  <= ex3_pp2_2s(259)                  ; --pass_cs
 ex3_pp3_1s(259)                  <= ex3_pp2_2c(259)                  ; --pass_cs
 ex3_pp3_1c(258)                  <= ex3_pp2_2s(258)                  ; --pass_cs
 ex3_pp3_1s(258)                  <= ex3_pp2_2c(258)                  ; --pass_cs
 ex3_pp3_1c(257)                  <= ex3_pp2_2s(257)                  ; --pass_cs
 ex3_pp3_1s(257)                  <= ex3_pp2_2c(257)                  ; --pass_cs
 ex3_pp3_1c(256)                  <= ex3_pp2_2s(256)                  ; --pass_cs
 ex3_pp3_1s(256)                  <= ex3_pp2_2c(256)                  ; --pass_cs
 ex3_pp3_1c(255)                  <= ex3_pp2_2s(255)                  ; --pass_cs
 ex3_pp3_1s(255)                  <= ex3_pp2_2c(255)                  ; --pass_cs
 ex3_pp3_1c(254)                  <= tidn                             ; --wr_csa32
    csa3_1_254: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(254)                   ,--i--
        b            => ex3_pp2_2c(254)                   ,--i--
        c            => ex3_pp2_2s(254)                   ,--i--
        sum          => ex3_pp3_1s(254)                   ,--o--
        car          => ex3_pp3_1c(253)                  );--o--
    csa3_1_253: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_2c(253)                   ,--i--
        b            => ex3_pp2_2s(253)                   ,--i--
        sum          => ex3_pp3_1s(253)                   ,--o--
        car          => ex3_pp3_1c(252)                  );--o--
    csa3_1_252: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(252)                   ,--i--
        b            => ex3_pp2_2c(252)                   ,--i--
        c            => ex3_pp2_2s(252)                   ,--i--
        sum          => ex3_pp3_1s(252)                   ,--o--
        car          => ex3_pp3_1c(251)                  );--o--
    csa3_1_251: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(251)                   ,--i--
        b            => ex3_pp2_2c(251)                   ,--i--
        c            => ex3_pp2_2s(251)                   ,--i--
        sum          => ex3_pp3_1s(251)                   ,--o--
        car          => ex3_pp3_1c(250)                  );--o--
    csa3_1_250: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(250)                   ,--i--
        b            => ex3_pp2_2c(250)                   ,--i--
        c            => ex3_pp2_2s(250)                   ,--i--
        sum          => ex3_pp3_1s(250)                   ,--o--
        car          => ex3_pp3_1c(249)                  );--o--
    csa3_1_249: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(249)                   ,--i--
        b            => ex3_pp2_2c(249)                   ,--i--
        c            => ex3_pp2_2s(249)                   ,--i--
        sum          => ex3_pp3_1s(249)                   ,--o--
        car          => ex3_pp3_1c(248)                  );--o--
    csa3_1_248: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(248)                   ,--i--
        b            => ex3_pp2_2c(248)                   ,--i--
        c            => ex3_pp2_2s(248)                   ,--i--
        sum          => ex3_pp3_1s(248)                   ,--o--
        car          => ex3_pp3_1c(247)                  );--o--
    csa3_1_247: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(247)                   ,--i--
        b            => ex3_pp2_2c(247)                   ,--i--
        c            => ex3_pp2_2s(247)                   ,--i--
        sum          => ex3_pp3_1s(247)                   ,--o--
        car          => ex3_pp3_1c(246)                  );--o--
    csa3_1_246: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(246)                   ,--i--
        b            => ex3_pp2_2c(246)                   ,--i--
        c            => ex3_pp2_2s(246)                   ,--i--
        sum          => ex3_pp3_1s(246)                   ,--o--
        car          => ex3_pp3_1c(245)                  );--o--
    csa3_1_245: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(245)                   ,--i--
        b            => ex3_pp2_2c(245)                   ,--i--
        c            => ex3_pp2_2s(245)                   ,--i--
        sum          => ex3_pp3_1s(245)                   ,--o--
        car          => ex3_pp3_1c(244)                  );--o--
    csa3_1_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(244)                   ,--i--
        b            => ex3_pp2_2c(244)                   ,--i--
        c            => ex3_pp2_2s(244)                   ,--i--
        sum          => ex3_pp3_1s(244)                   ,--o--
        car          => ex3_pp3_1c(243)                  );--o--
    csa3_1_243: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(243)                   ,--i--
        b            => ex3_pp2_2c(243)                   ,--i--
        c            => ex3_pp2_2s(243)                   ,--i--
        sum          => ex3_pp3_1s(243)                   ,--o--
        car          => ex3_pp3_1c(242)                  );--o--
    csa3_1_242: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(242)                   ,--i--
        b            => ex3_pp2_2c(242)                   ,--i--
        c            => ex3_pp2_2s(242)                   ,--i--
        sum          => ex3_pp3_1s(242)                   ,--o--
        car          => ex3_pp3_1c(241)                  );--o--
    csa3_1_241: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(241)                   ,--i--
        b            => ex3_pp2_2c(241)                   ,--i--
        c            => ex3_pp2_2s(241)                   ,--i--
        sum          => ex3_pp3_1s(241)                   ,--o--
        car          => ex3_pp3_1c(240)                  );--o--
    csa3_1_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(240)                   ,--i--
        b            => ex3_pp2_2c(240)                   ,--i--
        c            => ex3_pp2_2s(240)                   ,--i--
        sum          => ex3_pp3_1s(240)                   ,--o--
        car          => ex3_pp3_1c(239)                  );--o--
    csa3_1_239: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(239)                   ,--i--
        b            => ex3_pp2_2c(239)                   ,--i--
        c            => ex3_pp2_2s(239)                   ,--i--
        sum          => ex3_pp3_1s(239)                   ,--o--
        car          => ex3_pp3_1c(238)                  );--o--
    csa3_1_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(238)                   ,--i--
        b            => ex3_pp2_2c(238)                   ,--i--
        c            => ex3_pp2_2s(238)                   ,--i--
        sum          => ex3_pp3_1s(238)                   ,--o--
        car          => ex3_pp3_1c(237)                  );--o--
    csa3_1_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(237)                   ,--i--
        b            => ex3_pp2_2c(237)                   ,--i--
        c            => ex3_pp2_2s(237)                   ,--i--
        sum          => ex3_pp3_1s(237)                   ,--o--
        car          => ex3_pp3_1c(236)                  );--o--
    csa3_1_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(236)                   ,--i--
        b            => ex3_pp2_2c(236)                   ,--i--
        c            => ex3_pp2_2s(236)                   ,--i--
        sum          => ex3_pp3_1s(236)                   ,--o--
        car          => ex3_pp3_1c(235)                  );--o--
    csa3_1_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(235)                   ,--i--
        b            => ex3_pp2_2c(235)                   ,--i--
        c            => ex3_pp2_2s(235)                   ,--i--
        sum          => ex3_pp3_1s(235)                   ,--o--
        car          => ex3_pp3_1c(234)                  );--o--
    csa3_1_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(234)                   ,--i--
        b            => ex3_pp2_2c(234)                   ,--i--
        c            => ex3_pp2_2s(234)                   ,--i--
        sum          => ex3_pp3_1s(234)                   ,--o--
        car          => ex3_pp3_1c(233)                  );--o--
    csa3_1_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(233)                   ,--i--
        b            => ex3_pp2_2c(233)                   ,--i--
        c            => ex3_pp2_2s(233)                   ,--i--
        sum          => ex3_pp3_1s(233)                   ,--o--
        car          => ex3_pp3_1c(232)                  );--o--
    csa3_1_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(232)                   ,--i--
        b            => ex3_pp2_2c(232)                   ,--i--
        c            => ex3_pp2_2s(232)                   ,--i--
        sum          => ex3_pp3_1s(232)                   ,--o--
        car          => ex3_pp3_1c(231)                  );--o--
    csa3_1_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(231)                   ,--i--
        b            => ex3_pp2_2c(231)                   ,--i--
        c            => ex3_pp2_2s(231)                   ,--i--
        sum          => ex3_pp3_1s(231)                   ,--o--
        car          => ex3_pp3_1c(230)                  );--o--
    csa3_1_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(230)                   ,--i--
        b            => ex3_pp2_2c(230)                   ,--i--
        c            => ex3_pp2_2s(230)                   ,--i--
        sum          => ex3_pp3_1s(230)                   ,--o--
        car          => ex3_pp3_1c(229)                  );--o--
    csa3_1_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(229)                   ,--i--
        b            => ex3_pp2_2c(229)                   ,--i--
        c            => ex3_pp2_2s(229)                   ,--i--
        sum          => ex3_pp3_1s(229)                   ,--o--
        car          => ex3_pp3_1c(228)                  );--o--
    csa3_1_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(228)                   ,--i--
        b            => ex3_pp2_2c(228)                   ,--i--
        c            => ex3_pp2_2s(228)                   ,--i--
        sum          => ex3_pp3_1s(228)                   ,--o--
        car          => ex3_pp3_1c(227)                  );--o--
    csa3_1_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(227)                   ,--i--
        b            => ex3_pp2_2c(227)                   ,--i--
        c            => ex3_pp2_2s(227)                   ,--i--
        sum          => ex3_pp3_1s(227)                   ,--o--
        car          => ex3_pp3_1c(226)                  );--o--
    csa3_1_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(226)                   ,--i--
        b            => ex3_pp2_2c(226)                   ,--i--
        c            => ex3_pp2_2s(226)                   ,--i--
        sum          => ex3_pp3_1s(226)                   ,--o--
        car          => ex3_pp3_1c(225)                  );--o--
    csa3_1_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(225)                   ,--i--
        b            => ex3_pp2_2c(225)                   ,--i--
        c            => ex3_pp2_2s(225)                   ,--i--
        sum          => ex3_pp3_1s(225)                   ,--o--
        car          => ex3_pp3_1c(224)                  );--o--
    csa3_1_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(224)                   ,--i--
        b            => ex3_pp2_2c(224)                   ,--i--
        c            => ex3_pp2_2s(224)                   ,--i--
        sum          => ex3_pp3_1s(224)                   ,--o--
        car          => ex3_pp3_1c(223)                  );--o--
    csa3_1_223: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(223)                   ,--i--
        b            => ex3_pp2_2c(223)                   ,--i--
        c            => ex3_pp2_2s(223)                   ,--i--
        sum          => ex3_pp3_1s(223)                   ,--o--
        car          => ex3_pp3_1c(222)                  );--o--
    csa3_1_222: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(222)                   ,--i--
        b            => ex3_pp2_2c(222)                   ,--i--
        c            => ex3_pp2_2s(222)                   ,--i--
        sum          => ex3_pp3_1s(222)                   ,--o--
        car          => ex3_pp3_1c(221)                  );--o--
    csa3_1_221: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(221)                   ,--i--
        b            => ex3_pp2_2c(221)                   ,--i--
        c            => ex3_pp2_2s(221)                   ,--i--
        sum          => ex3_pp3_1s(221)                   ,--o--
        car          => ex3_pp3_1c(220)                  );--o--
    csa3_1_220: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(220)                   ,--i--
        b            => ex3_pp2_2c(220)                   ,--i--
        c            => ex3_pp2_2s(220)                   ,--i--
        sum          => ex3_pp3_1s(220)                   ,--o--
        car          => ex3_pp3_1c(219)                  );--o--
 ex3_pp3_1s(219)                  <= ex3_pp2_1s(219)                  ; --pass_x_s
 --ex3_pp3_1c(218)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(218)                  <= ex3_pp2_1s(218)                  ; --pass_s
 --ex3_pp3_1c(217)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(217)                  <= ex3_pp2_1s(217)                  ; --pass_s
 --ex3_pp3_1c(216)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(216)                  <= ex3_pp2_1s(216)                  ; --pass_s
 --ex3_pp3_1c(215)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(215)                  <= ex3_pp2_1s(215)                  ; --pass_s
 --ex3_pp3_1c(214)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(214)                  <= ex3_pp2_1s(214)                  ; --pass_s
 --ex3_pp3_1c(213)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(213)                  <= ex3_pp2_1s(213)                  ; --pass_s
 --ex3_pp3_1c(212)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(212)                  <= ex3_pp2_1s(212)                  ; --pass_s
 --ex3_pp3_1c(211)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(211)                  <= ex3_pp2_1s(211)                  ; --pass_s
 --ex3_pp3_1c(210)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(210)                  <= ex3_pp2_1s(210)                  ; --pass_s
 --ex3_pp3_1c(209)                  <= tidn                             ; --pass_s
 ex3_pp3_1s(209)                  <= ex3_pp2_1s(209)                  ; --pass_s
 ex3_pp3_1s(208)                  <= ex3_pp2_1s(208)                  ; --pass_s


       --***********************************
       --** compression level 4
       --***********************************

--    g4 : for i in 196 to 264 generate
--        csa4_0: entity work.c_prism_csa42 port map(
--            a    => ex3_pp3_0s(i)                          ,--i--
--            b    => ex3_pp3_0c(i)                          ,--i--
--            c    => ex3_pp3_1s(i)                          ,--i--
--            d    => ex3_pp3_1c(i)                          ,--i--
--            ki   => ex3_pp4_0k(i)                          ,--i--
--            ko   => ex3_pp4_0k(i - 1)                      ,--o--
--            sum  => ex3_pp4_0s(i)                          ,--o--
--            car  => ex3_pp4_0c(i - 1)                     );--o--
--    end generate;
--       ex3_pp4_0k(264) <= tidn ;
--       ex3_pp4_0c(264) <= tidn ;



 ------- <csa4_0> -----

 ex3_pp4_0s(264)                  <= ex3_pp3_1s(264)                  ; --pass_s
 ex3_pp4_0s(263)                  <= ex3_pp3_1s(263)                  ; --pass_s
 ex3_pp4_0c(262)                  <= ex3_pp3_1s(262)                  ; --pass_cs
 ex3_pp4_0s(262)                  <= ex3_pp3_1c(262)                  ; --pass_cs
 ex3_pp4_0c(261)                  <= ex3_pp3_1s(261)                  ; --pass_cs
 ex3_pp4_0s(261)                  <= ex3_pp3_1c(261)                  ; --pass_cs
 ex3_pp4_0c(260)                  <= tidn                             ; --pass_s
 ex3_pp4_0s(260)                  <= ex3_pp3_1s(260)                  ; --pass_s
 ex3_pp4_0c(259)                  <= ex3_pp3_1s(259)                  ; --pass_cs
 ex3_pp4_0s(259)                  <= ex3_pp3_1c(259)                  ; --pass_cs
 ex3_pp4_0c(258)                  <= ex3_pp3_1s(258)                  ; --pass_cs
 ex3_pp4_0s(258)                  <= ex3_pp3_1c(258)                  ; --pass_cs
 ex3_pp4_0c(257)                  <= ex3_pp3_1s(257)                  ; --pass_cs
 ex3_pp4_0s(257)                  <= ex3_pp3_1c(257)                  ; --pass_cs
 ex3_pp4_0c(256)                  <= ex3_pp3_1s(256)                  ; --pass_cs
 ex3_pp4_0s(256)                  <= ex3_pp3_1c(256)                  ; --pass_cs
 ex3_pp4_0c(255)                  <= ex3_pp3_1s(255)                  ; --pass_cs
 ex3_pp4_0s(255)                  <= ex3_pp3_1c(255)                  ; --pass_cs
 ex3_pp4_0c(254)                  <= tidn                             ; --pass_s
 ex3_pp4_0s(254)                  <= ex3_pp3_1s(254)                  ; --pass_s
 ex3_pp4_0c(253)                  <= ex3_pp3_1s(253)                  ; --pass_cs
 ex3_pp4_0s(253)                  <= ex3_pp3_1c(253)                  ; --pass_cs
 ex3_pp4_0c(252)                  <= tidn                             ; --wr_csa32
    csa4_0_252: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(252)                   ,--i--
        b            => ex3_pp3_1c(252)                   ,--i--
        c            => ex3_pp3_1s(252)                   ,--i--
        sum          => ex3_pp4_0s(252)                   ,--o--
        car          => ex3_pp4_0c(251)                  );--o--
    csa4_0_251: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_1c(251)                   ,--i--
        b            => ex3_pp3_1s(251)                   ,--i--
        sum          => ex3_pp4_0s(251)                   ,--o--
        car          => ex3_pp4_0c(250)                  );--o--
    csa4_0_250: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_1c(250)                   ,--i--
        b            => ex3_pp3_1s(250)                   ,--i--
        sum          => ex3_pp4_0s(250)                   ,--o--
        car          => ex3_pp4_0c(249)                  );--o--
    csa4_0_249: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(249)                   ,--i--
        b            => ex3_pp3_1c(249)                   ,--i--
        c            => ex3_pp3_1s(249)                   ,--i--
        sum          => ex3_pp4_0s(249)                   ,--o--
        car          => ex3_pp4_0c(248)                  );--o--
    csa4_0_248: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_1c(248)                   ,--i--
        b            => ex3_pp3_1s(248)                   ,--i--
        sum          => ex3_pp4_0s(248)                   ,--o--
        car          => ex3_pp4_0c(247)                  );--o--
    csa4_0_247: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(247)                   ,--i--
        b            => ex3_pp3_1c(247)                   ,--i--
        c            => ex3_pp3_1s(247)                   ,--i--
        sum          => ex3_pp4_0s(247)                   ,--o--
        car          => ex3_pp4_0c(246)                  );--o--
    csa4_0_246: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(246)                   ,--i--
        b            => ex3_pp3_1c(246)                   ,--i--
        c            => ex3_pp3_1s(246)                   ,--i--
        sum          => ex3_pp4_0s(246)                   ,--o--
        car          => ex3_pp4_0c(245)                  );--o--
    csa4_0_245: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(245)                   ,--i--
        b            => ex3_pp3_1c(245)                   ,--i--
        c            => ex3_pp3_1s(245)                   ,--i--
        sum          => ex3_pp4_0s(245)                   ,--o--
        car          => ex3_pp4_0c(244)                  );--o--
    csa4_0_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(244)                   ,--i--
        b            => ex3_pp3_1c(244)                   ,--i--
        c            => ex3_pp3_1s(244)                   ,--i--
        sum          => ex3_pp4_0s(244)                   ,--o--
        car          => ex3_pp4_0c(243)                  );--o--
    csa4_0_243: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(243)                   ,--i--
        b            => ex3_pp3_1c(243)                   ,--i--
        c            => ex3_pp3_1s(243)                   ,--i--
        sum          => ex3_pp4_0s(243)                   ,--o--
        car          => ex3_pp4_0c(242)                  );--o--
 ex3_pp4_0k(242)                  <= tidn                             ; --start_k
    csa4_0_242: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(242)                   ,--i--
        b            => ex3_pp3_0s(242)                   ,--i--
        c            => ex3_pp3_1c(242)                   ,--i--
        d            => ex3_pp3_1s(242)                   ,--i--
        ki           => ex3_pp4_0k(242)                   ,--i--
        ko           => ex3_pp4_0k(241)                   ,--o--
        sum          => ex3_pp4_0s(242)                   ,--o--
        car          => ex3_pp4_0c(241)                  );--o--
    csa4_0_241: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(241)                   ,--i--
        b            => ex3_pp3_1c(241)                   ,--i--
        c            => ex3_pp3_1s(241)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(241)                   ,--i--
        ko           => ex3_pp4_0k(240)                   ,--o--
        sum          => ex3_pp4_0s(241)                   ,--o--
        car          => ex3_pp4_0c(240)                  );--o--
    csa4_0_240: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(240)                   ,--i--
        b            => ex3_pp3_1c(240)                   ,--i--
        c            => ex3_pp3_1s(240)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(240)                   ,--i--
        ko           => ex3_pp4_0k(239)                   ,--o--
        sum          => ex3_pp4_0s(240)                   ,--o--
        car          => ex3_pp4_0c(239)                  );--o--
    csa4_0_239: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(239)                   ,--i--
        b            => ex3_pp3_0s(239)                   ,--i--
        c            => ex3_pp3_1c(239)                   ,--i--
        d            => ex3_pp3_1s(239)                   ,--i--
        ki           => ex3_pp4_0k(239)                   ,--i--
        ko           => ex3_pp4_0k(238)                   ,--o--
        sum          => ex3_pp4_0s(239)                   ,--o--
        car          => ex3_pp4_0c(238)                  );--o--
    csa4_0_238: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(238)                   ,--i--
        b            => ex3_pp3_0s(238)                   ,--i--
        c            => ex3_pp3_1c(238)                   ,--i--
        d            => ex3_pp3_1s(238)                   ,--i--
        ki           => ex3_pp4_0k(238)                   ,--i--
        ko           => ex3_pp4_0k(237)                   ,--o--
        sum          => ex3_pp4_0s(238)                   ,--o--
        car          => ex3_pp4_0c(237)                  );--o--
    csa4_0_237: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(237)                   ,--i--
        b            => ex3_pp3_0s(237)                   ,--i--
        c            => ex3_pp3_1c(237)                   ,--i--
        d            => ex3_pp3_1s(237)                   ,--i--
        ki           => ex3_pp4_0k(237)                   ,--i--
        ko           => ex3_pp4_0k(236)                   ,--o--
        sum          => ex3_pp4_0s(237)                   ,--o--
        car          => ex3_pp4_0c(236)                  );--o--
    csa4_0_236: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(236)                   ,--i--
        b            => ex3_pp3_0s(236)                   ,--i--
        c            => ex3_pp3_1c(236)                   ,--i--
        d            => ex3_pp3_1s(236)                   ,--i--
        ki           => ex3_pp4_0k(236)                   ,--i--
        ko           => ex3_pp4_0k(235)                   ,--o--
        sum          => ex3_pp4_0s(236)                   ,--o--
        car          => ex3_pp4_0c(235)                  );--o--
    csa4_0_235: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(235)                   ,--i--
        b            => ex3_pp3_0s(235)                   ,--i--
        c            => ex3_pp3_1c(235)                   ,--i--
        d            => ex3_pp3_1s(235)                   ,--i--
        ki           => ex3_pp4_0k(235)                   ,--i--
        ko           => ex3_pp4_0k(234)                   ,--o--
        sum          => ex3_pp4_0s(235)                   ,--o--
        car          => ex3_pp4_0c(234)                  );--o--
    csa4_0_234: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(234)                   ,--i--
        b            => ex3_pp3_0s(234)                   ,--i--
        c            => ex3_pp3_1c(234)                   ,--i--
        d            => ex3_pp3_1s(234)                   ,--i--
        ki           => ex3_pp4_0k(234)                   ,--i--
        ko           => ex3_pp4_0k(233)                   ,--o--
        sum          => ex3_pp4_0s(234)                   ,--o--
        car          => ex3_pp4_0c(233)                  );--o--
    csa4_0_233: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(233)                   ,--i--
        b            => ex3_pp3_0s(233)                   ,--i--
        c            => ex3_pp3_1c(233)                   ,--i--
        d            => ex3_pp3_1s(233)                   ,--i--
        ki           => ex3_pp4_0k(233)                   ,--i--
        ko           => ex3_pp4_0k(232)                   ,--o--
        sum          => ex3_pp4_0s(233)                   ,--o--
        car          => ex3_pp4_0c(232)                  );--o--
    csa4_0_232: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(232)                   ,--i--
        b            => ex3_pp3_0s(232)                   ,--i--
        c            => ex3_pp3_1c(232)                   ,--i--
        d            => ex3_pp3_1s(232)                   ,--i--
        ki           => ex3_pp4_0k(232)                   ,--i--
        ko           => ex3_pp4_0k(231)                   ,--o--
        sum          => ex3_pp4_0s(232)                   ,--o--
        car          => ex3_pp4_0c(231)                  );--o--
    csa4_0_231: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(231)                   ,--i--
        b            => ex3_pp3_0s(231)                   ,--i--
        c            => ex3_pp3_1c(231)                   ,--i--
        d            => ex3_pp3_1s(231)                   ,--i--
        ki           => ex3_pp4_0k(231)                   ,--i--
        ko           => ex3_pp4_0k(230)                   ,--o--
        sum          => ex3_pp4_0s(231)                   ,--o--
        car          => ex3_pp4_0c(230)                  );--o--
    csa4_0_230: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(230)                   ,--i--
        b            => ex3_pp3_0s(230)                   ,--i--
        c            => ex3_pp3_1c(230)                   ,--i--
        d            => ex3_pp3_1s(230)                   ,--i--
        ki           => ex3_pp4_0k(230)                   ,--i--
        ko           => ex3_pp4_0k(229)                   ,--o--
        sum          => ex3_pp4_0s(230)                   ,--o--
        car          => ex3_pp4_0c(229)                  );--o--
    csa4_0_229: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(229)                   ,--i--
        b            => ex3_pp3_0s(229)                   ,--i--
        c            => ex3_pp3_1c(229)                   ,--i--
        d            => ex3_pp3_1s(229)                   ,--i--
        ki           => ex3_pp4_0k(229)                   ,--i--
        ko           => ex3_pp4_0k(228)                   ,--o--
        sum          => ex3_pp4_0s(229)                   ,--o--
        car          => ex3_pp4_0c(228)                  );--o--
    csa4_0_228: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(228)                   ,--i--
        b            => ex3_pp3_0s(228)                   ,--i--
        c            => ex3_pp3_1c(228)                   ,--i--
        d            => ex3_pp3_1s(228)                   ,--i--
        ki           => ex3_pp4_0k(228)                   ,--i--
        ko           => ex3_pp4_0k(227)                   ,--o--
        sum          => ex3_pp4_0s(228)                   ,--o--
        car          => ex3_pp4_0c(227)                  );--o--
    csa4_0_227: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(227)                   ,--i--
        b            => ex3_pp3_0s(227)                   ,--i--
        c            => ex3_pp3_1c(227)                   ,--i--
        d            => ex3_pp3_1s(227)                   ,--i--
        ki           => ex3_pp4_0k(227)                   ,--i--
        ko           => ex3_pp4_0k(226)                   ,--o--
        sum          => ex3_pp4_0s(227)                   ,--o--
        car          => ex3_pp4_0c(226)                  );--o--
    csa4_0_226: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(226)                   ,--i--
        b            => ex3_pp3_0s(226)                   ,--i--
        c            => ex3_pp3_1c(226)                   ,--i--
        d            => ex3_pp3_1s(226)                   ,--i--
        ki           => ex3_pp4_0k(226)                   ,--i--
        ko           => ex3_pp4_0k(225)                   ,--o--
        sum          => ex3_pp4_0s(226)                   ,--o--
        car          => ex3_pp4_0c(225)                  );--o--
    csa4_0_225: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(225)                   ,--i--
        b            => ex3_pp3_0s(225)                   ,--i--
        c            => ex3_pp3_1c(225)                   ,--i--
        d            => ex3_pp3_1s(225)                   ,--i--
        ki           => ex3_pp4_0k(225)                   ,--i--
        ko           => ex3_pp4_0k(224)                   ,--o--
        sum          => ex3_pp4_0s(225)                   ,--o--
        car          => ex3_pp4_0c(224)                  );--o--
    csa4_0_224: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(224)                   ,--i--
        b            => ex3_pp3_0s(224)                   ,--i--
        c            => ex3_pp3_1c(224)                   ,--i--
        d            => ex3_pp3_1s(224)                   ,--i--
        ki           => ex3_pp4_0k(224)                   ,--i--
        ko           => ex3_pp4_0k(223)                   ,--o--
        sum          => ex3_pp4_0s(224)                   ,--o--
        car          => ex3_pp4_0c(223)                  );--o--
    csa4_0_223: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(223)                   ,--i--
        b            => ex3_pp3_0s(223)                   ,--i--
        c            => ex3_pp3_1c(223)                   ,--i--
        d            => ex3_pp3_1s(223)                   ,--i--
        ki           => ex3_pp4_0k(223)                   ,--i--
        ko           => ex3_pp4_0k(222)                   ,--o--
        sum          => ex3_pp4_0s(223)                   ,--o--
        car          => ex3_pp4_0c(222)                  );--o--
    csa4_0_222: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(222)                   ,--i--
        b            => ex3_pp3_0s(222)                   ,--i--
        c            => ex3_pp3_1c(222)                   ,--i--
        d            => ex3_pp3_1s(222)                   ,--i--
        ki           => ex3_pp4_0k(222)                   ,--i--
        ko           => ex3_pp4_0k(221)                   ,--o--
        sum          => ex3_pp4_0s(222)                   ,--o--
        car          => ex3_pp4_0c(221)                  );--o--
    csa4_0_221: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(221)                   ,--i--
        b            => ex3_pp3_0s(221)                   ,--i--
        c            => ex3_pp3_1c(221)                   ,--i--
        d            => ex3_pp3_1s(221)                   ,--i--
        ki           => ex3_pp4_0k(221)                   ,--i--
        ko           => ex3_pp4_0k(220)                   ,--o--
        sum          => ex3_pp4_0s(221)                   ,--o--
        car          => ex3_pp4_0c(220)                  );--o--
    csa4_0_220: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(220)                   ,--i--
        b            => ex3_pp3_0s(220)                   ,--i--
        c            => ex3_pp3_1c(220)                   ,--i--
        d            => ex3_pp3_1s(220)                   ,--i--
        ki           => ex3_pp4_0k(220)                   ,--i--
        ko           => ex3_pp4_0k(219)                   ,--o--
        sum          => ex3_pp4_0s(220)                   ,--o--
        car          => ex3_pp4_0c(219)                  );--o--
    csa4_0_219: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(219)                   ,--i--
        b            => ex3_pp3_0s(219)                   ,--i--
        c            => ex3_pp3_1c(219)                   ,--i--
        d            => ex3_pp3_1s(219)                   ,--i--
        ki           => ex3_pp4_0k(219)                   ,--i--
        ko           => ex3_pp4_0k(218)                   ,--o--
        sum          => ex3_pp4_0s(219)                   ,--o--
        car          => ex3_pp4_0c(218)                  );--o--
    csa4_0_218: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(218)                   ,--i--
        b            => ex3_pp3_0s(218)                   ,--i--
        c            => ex3_pp3_1s(218)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(218)                   ,--i--
        ko           => ex3_pp4_0k(217)                   ,--o--
        sum          => ex3_pp4_0s(218)                   ,--o--
        car          => ex3_pp4_0c(217)                  );--o--
    csa4_0_217: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(217)                   ,--i--
        b            => ex3_pp3_0s(217)                   ,--i--
        c            => ex3_pp3_1s(217)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(217)                   ,--i--
        ko           => ex3_pp4_0k(216)                   ,--o--
        sum          => ex3_pp4_0s(217)                   ,--o--
        car          => ex3_pp4_0c(216)                  );--o--
    csa4_0_216: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(216)                   ,--i--
        b            => ex3_pp3_0s(216)                   ,--i--
        c            => ex3_pp3_1s(216)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(216)                   ,--i--
        ko           => ex3_pp4_0k(215)                   ,--o--
        sum          => ex3_pp4_0s(216)                   ,--o--
        car          => ex3_pp4_0c(215)                  );--o--
    csa4_0_215: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(215)                   ,--i--
        b            => ex3_pp3_0s(215)                   ,--i--
        c            => ex3_pp3_1s(215)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(215)                   ,--i--
        ko           => ex3_pp4_0k(214)                   ,--o--
        sum          => ex3_pp4_0s(215)                   ,--o--
        car          => ex3_pp4_0c(214)                  );--o--
    csa4_0_214: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(214)                   ,--i--
        b            => ex3_pp3_0s(214)                   ,--i--
        c            => ex3_pp3_1s(214)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(214)                   ,--i--
        ko           => ex3_pp4_0k(213)                   ,--o--
        sum          => ex3_pp4_0s(214)                   ,--o--
        car          => ex3_pp4_0c(213)                  );--o--
    csa4_0_213: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(213)                   ,--i--
        b            => ex3_pp3_0s(213)                   ,--i--
        c            => ex3_pp3_1s(213)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(213)                   ,--i--
        ko           => ex3_pp4_0k(212)                   ,--o--
        sum          => ex3_pp4_0s(213)                   ,--o--
        car          => ex3_pp4_0c(212)                  );--o--
    csa4_0_212: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(212)                   ,--i--
        b            => ex3_pp3_0s(212)                   ,--i--
        c            => ex3_pp3_1s(212)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(212)                   ,--i--
        ko           => ex3_pp4_0k(211)                   ,--o--
        sum          => ex3_pp4_0s(212)                   ,--o--
        car          => ex3_pp4_0c(211)                  );--o--
    csa4_0_211: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(211)                   ,--i--
        b            => ex3_pp3_0s(211)                   ,--i--
        c            => ex3_pp3_1s(211)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(211)                   ,--i--
        ko           => ex3_pp4_0k(210)                   ,--o--
        sum          => ex3_pp4_0s(211)                   ,--o--
        car          => ex3_pp4_0c(210)                  );--o--
    csa4_0_210: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(210)                   ,--i--
        b            => ex3_pp3_0s(210)                   ,--i--
        c            => ex3_pp3_1s(210)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(210)                   ,--i--
        ko           => ex3_pp4_0k(209)                   ,--o--
        sum          => ex3_pp4_0s(210)                   ,--o--
        car          => ex3_pp4_0c(209)                  );--o--
    csa4_0_209: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(209)                   ,--i--
        b            => ex3_pp3_0s(209)                   ,--i--
        c            => ex3_pp3_1s(209)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(209)                   ,--i--
        ko           => ex3_pp4_0k(208)                   ,--o--
        sum          => ex3_pp4_0s(209)                   ,--o--
        car          => ex3_pp4_0c(208)                  );--o--
    csa4_0_208: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(208)                   ,--i--
        b            => ex3_pp3_0s(208)                   ,--i--
        c            => ex3_pp3_1s(208)                   ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp4_0k(208)                   ,--i--
        ko           => ex3_pp4_0k(207)                   ,--o--
        sum          => ex3_pp4_0s(208)                   ,--o--
        car          => ex3_pp4_0c(207)                  );--o--
    csa4_0_207: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(207)                   ,--i--
        b            => ex3_pp3_0s(207)                   ,--i--
        c            => ex3_pp4_0k(207)                   ,--i--
        sum          => ex3_pp4_0s(207)                   ,--o--
        car          => ex3_pp4_0c(206)                  );--o--
    csa4_0_206: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(206)                   ,--i--
        b            => ex3_pp3_0s(206)                   ,--i--
        sum          => ex3_pp4_0s(206)                   ,--o--
        car          => ex3_pp4_0c(205)                  );--o--
    csa4_0_205: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(205)                   ,--i--
        b            => ex3_pp3_0s(205)                   ,--i--
        sum          => ex3_pp4_0s(205)                   ,--o--
        car          => ex3_pp4_0c(204)                  );--o--
    csa4_0_204: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(204)                   ,--i--
        b            => ex3_pp3_0s(204)                   ,--i--
        sum          => ex3_pp4_0s(204)                   ,--o--
        car          => ex3_pp4_0c(203)                  );--o--
    csa4_0_203: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(203)                   ,--i--
        b            => ex3_pp3_0s(203)                   ,--i--
        sum          => ex3_pp4_0s(203)                   ,--o--
        car          => ex3_pp4_0c(202)                  );--o--
    csa4_0_202: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(202)                   ,--i--
        b            => ex3_pp3_0s(202)                   ,--i--
        sum          => ex3_pp4_0s(202)                   ,--o--
        car          => ex3_pp4_0c(201)                  );--o--
    csa4_0_201: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(201)                   ,--i--
        b            => ex3_pp3_0s(201)                   ,--i--
        sum          => ex3_pp4_0s(201)                   ,--o--
        car          => ex3_pp4_0c(200)                  );--o--
    csa4_0_200: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(200)                   ,--i--
        b            => ex3_pp3_0s(200)                   ,--i--
        sum          => ex3_pp4_0s(200)                   ,--o--
        car          => ex3_pp4_0c(199)                  );--o--
    csa4_0_199: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(199)                   ,--i--
        b            => ex3_pp3_0s(199)                   ,--i--
        sum          => ex3_pp4_0s(199)                   ,--o--
        car          => ex3_pp4_0c(198)                  );--o--
    csa4_0_198: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(198)                   ,--i--
        b            => ex3_pp3_0s(198)                   ,--i--
        sum          => ex3_pp4_0s(198)                   ,--o--
        car          => ex3_pp4_0c(197)                  );--o--
 ex3_pp4_0s(197)                  <= ex3_pp3_0c(197)                  ; --pass_x_s




       --***********************************
       --** compression recycle
       --***********************************

--    g5 : for i in 196 to 264 generate
--
--        csa5_0: entity work.c_prism_csa42 port map(
--            a    => ex3_pp4_0s(i)                          ,--i--
--            b    => ex3_pp4_0c(i)                          ,--i--
--            c    => ex3_recycle_s(i)                       ,--i--
--            d    => ex3_recycle_c(i)                       ,--i--
--            ki   => ex3_pp5_0k(i)                          ,--i--
--            ko   => ex3_pp5_0k(i - 1)                      ,--o--
--            sum  => ex3_pp5_0s(i)                          ,--o--
--            car  => ex3_pp5_0c(i - 1)                     );--o--
--
--    end generate;
--
--       ex3_pp5_0k(264) <= tidn ;
--       ex3_pp5_0c(264) <= tidn ;



 ------- <csa5_0> -----

    csa5_0_264: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp4_0s(264)                   ,--i--
        b            => ex3_recycle_s(264)                ,--i--
        sum          => ex3_pp5_0s(264)                   ,--o--
        car          => ex3_pp5_0c(263)                  );--o--
    csa5_0_263: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0s(263)                   ,--i--
        b            => ex3_recycle_c(263)                ,--i--
        c            => ex3_recycle_s(263)                ,--i--
        sum          => ex3_pp5_0s(263)                   ,--o--
        car          => ex3_pp5_0c(262)                  );--o--
 ex3_pp5_0k(262)                  <= tidn                             ; --start_k
    csa5_0_262: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(262)                   ,--i--
        b            => ex3_pp4_0s(262)                   ,--i--
        c            => ex3_recycle_c(262)                ,--i--
        d            => ex3_recycle_s(262)                ,--i--
        ki           => ex3_pp5_0k(262)                   ,--i--
        ko           => ex3_pp5_0k(261)                   ,--o--
        sum          => ex3_pp5_0s(262)                   ,--o--
        car          => ex3_pp5_0c(261)                  );--o--
    csa5_0_261: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(261)                   ,--i--
        b            => ex3_pp4_0s(261)                   ,--i--
        c            => ex3_recycle_c(261)                ,--i--
        d            => ex3_recycle_s(261)                ,--i--
        ki           => ex3_pp5_0k(261)                   ,--i--
        ko           => ex3_pp5_0k(260)                   ,--o--
        sum          => ex3_pp5_0s(261)                   ,--o--
        car          => ex3_pp5_0c(260)                  );--o--
    csa5_0_260: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0s(260)                   ,--i--
        b            => ex3_recycle_c(260)                ,--i--
        c            => ex3_recycle_s(260)                ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp5_0k(260)                   ,--i--
        ko           => ex3_pp5_0k(259)                   ,--o--
        sum          => ex3_pp5_0s(260)                   ,--o--
        car          => ex3_pp5_0c(259)                  );--o--
    csa5_0_259: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(259)                   ,--i--
        b            => ex3_pp4_0s(259)                   ,--i--
        c            => ex3_recycle_c(259)                ,--i--
        d            => ex3_recycle_s(259)                ,--i--
        ki           => ex3_pp5_0k(259)                   ,--i--
        ko           => ex3_pp5_0k(258)                   ,--o--
        sum          => ex3_pp5_0s(259)                   ,--o--
        car          => ex3_pp5_0c(258)                  );--o--
    csa5_0_258: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(258)                   ,--i--
        b            => ex3_pp4_0s(258)                   ,--i--
        c            => ex3_recycle_c(258)                ,--i--
        d            => ex3_recycle_s(258)                ,--i--
        ki           => ex3_pp5_0k(258)                   ,--i--
        ko           => ex3_pp5_0k(257)                   ,--o--
        sum          => ex3_pp5_0s(258)                   ,--o--
        car          => ex3_pp5_0c(257)                  );--o--
    csa5_0_257: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(257)                   ,--i--
        b            => ex3_pp4_0s(257)                   ,--i--
        c            => ex3_recycle_c(257)                ,--i--
        d            => ex3_recycle_s(257)                ,--i--
        ki           => ex3_pp5_0k(257)                   ,--i--
        ko           => ex3_pp5_0k(256)                   ,--o--
        sum          => ex3_pp5_0s(257)                   ,--o--
        car          => ex3_pp5_0c(256)                  );--o--
    csa5_0_256: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(256)                   ,--i--
        b            => ex3_pp4_0s(256)                   ,--i--
        c            => ex3_recycle_c(256)                ,--i--
        d            => ex3_recycle_s(256)                ,--i--
        ki           => ex3_pp5_0k(256)                   ,--i--
        ko           => ex3_pp5_0k(255)                   ,--o--
        sum          => ex3_pp5_0s(256)                   ,--o--
        car          => ex3_pp5_0c(255)                  );--o--
    csa5_0_255: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(255)                   ,--i--
        b            => ex3_pp4_0s(255)                   ,--i--
        c            => ex3_recycle_c(255)                ,--i--
        d            => ex3_recycle_s(255)                ,--i--
        ki           => ex3_pp5_0k(255)                   ,--i--
        ko           => ex3_pp5_0k(254)                   ,--o--
        sum          => ex3_pp5_0s(255)                   ,--o--
        car          => ex3_pp5_0c(254)                  );--o--
    csa5_0_254: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0s(254)                   ,--i--
        b            => ex3_recycle_c(254)                ,--i--
        c            => ex3_recycle_s(254)                ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp5_0k(254)                   ,--i--
        ko           => ex3_pp5_0k(253)                   ,--o--
        sum          => ex3_pp5_0s(254)                   ,--o--
        car          => ex3_pp5_0c(253)                  );--o--
    csa5_0_253: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(253)                   ,--i--
        b            => ex3_pp4_0s(253)                   ,--i--
        c            => ex3_recycle_c(253)                ,--i--
        d            => ex3_recycle_s(253)                ,--i--
        ki           => ex3_pp5_0k(253)                   ,--i--
        ko           => ex3_pp5_0k(252)                   ,--o--
        sum          => ex3_pp5_0s(253)                   ,--o--
        car          => ex3_pp5_0c(252)                  );--o--
    csa5_0_252: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0s(252)                   ,--i--
        b            => ex3_recycle_c(252)                ,--i--
        c            => ex3_recycle_s(252)                ,--i--
        d            => tidn                              ,--i--
        ki           => ex3_pp5_0k(252)                   ,--i--
        ko           => ex3_pp5_0k(251)                   ,--o--
        sum          => ex3_pp5_0s(252)                   ,--o--
        car          => ex3_pp5_0c(251)                  );--o--
    csa5_0_251: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(251)                   ,--i--
        b            => ex3_pp4_0s(251)                   ,--i--
        c            => ex3_recycle_c(251)                ,--i--
        d            => ex3_recycle_s(251)                ,--i--
        ki           => ex3_pp5_0k(251)                   ,--i--
        ko           => ex3_pp5_0k(250)                   ,--o--
        sum          => ex3_pp5_0s(251)                   ,--o--
        car          => ex3_pp5_0c(250)                  );--o--
    csa5_0_250: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(250)                   ,--i--
        b            => ex3_pp4_0s(250)                   ,--i--
        c            => ex3_recycle_c(250)                ,--i--
        d            => ex3_recycle_s(250)                ,--i--
        ki           => ex3_pp5_0k(250)                   ,--i--
        ko           => ex3_pp5_0k(249)                   ,--o--
        sum          => ex3_pp5_0s(250)                   ,--o--
        car          => ex3_pp5_0c(249)                  );--o--
    csa5_0_249: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(249)                   ,--i--
        b            => ex3_pp4_0s(249)                   ,--i--
        c            => ex3_recycle_c(249)                ,--i--
        d            => ex3_recycle_s(249)                ,--i--
        ki           => ex3_pp5_0k(249)                   ,--i--
        ko           => ex3_pp5_0k(248)                   ,--o--
        sum          => ex3_pp5_0s(249)                   ,--o--
        car          => ex3_pp5_0c(248)                  );--o--
    csa5_0_248: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(248)                   ,--i--
        b            => ex3_pp4_0s(248)                   ,--i--
        c            => ex3_recycle_c(248)                ,--i--
        d            => ex3_recycle_s(248)                ,--i--
        ki           => ex3_pp5_0k(248)                   ,--i--
        ko           => ex3_pp5_0k(247)                   ,--o--
        sum          => ex3_pp5_0s(248)                   ,--o--
        car          => ex3_pp5_0c(247)                  );--o--
    csa5_0_247: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(247)                   ,--i--
        b            => ex3_pp4_0s(247)                   ,--i--
        c            => ex3_recycle_c(247)                ,--i--
        d            => ex3_recycle_s(247)                ,--i--
        ki           => ex3_pp5_0k(247)                   ,--i--
        ko           => ex3_pp5_0k(246)                   ,--o--
        sum          => ex3_pp5_0s(247)                   ,--o--
        car          => ex3_pp5_0c(246)                  );--o--
    csa5_0_246: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(246)                   ,--i--
        b            => ex3_pp4_0s(246)                   ,--i--
        c            => ex3_recycle_c(246)                ,--i--
        d            => ex3_recycle_s(246)                ,--i--
        ki           => ex3_pp5_0k(246)                   ,--i--
        ko           => ex3_pp5_0k(245)                   ,--o--
        sum          => ex3_pp5_0s(246)                   ,--o--
        car          => ex3_pp5_0c(245)                  );--o--
    csa5_0_245: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(245)                   ,--i--
        b            => ex3_pp4_0s(245)                   ,--i--
        c            => ex3_recycle_c(245)                ,--i--
        d            => ex3_recycle_s(245)                ,--i--
        ki           => ex3_pp5_0k(245)                   ,--i--
        ko           => ex3_pp5_0k(244)                   ,--o--
        sum          => ex3_pp5_0s(245)                   ,--o--
        car          => ex3_pp5_0c(244)                  );--o--
    csa5_0_244: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(244)                   ,--i--
        b            => ex3_pp4_0s(244)                   ,--i--
        c            => ex3_recycle_c(244)                ,--i--
        d            => ex3_recycle_s(244)                ,--i--
        ki           => ex3_pp5_0k(244)                   ,--i--
        ko           => ex3_pp5_0k(243)                   ,--o--
        sum          => ex3_pp5_0s(244)                   ,--o--
        car          => ex3_pp5_0c(243)                  );--o--
    csa5_0_243: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(243)                   ,--i--
        b            => ex3_pp4_0s(243)                   ,--i--
        c            => ex3_recycle_c(243)                ,--i--
        d            => ex3_recycle_s(243)                ,--i--
        ki           => ex3_pp5_0k(243)                   ,--i--
        ko           => ex3_pp5_0k(242)                   ,--o--
        sum          => ex3_pp5_0s(243)                   ,--o--
        car          => ex3_pp5_0c(242)                  );--o--
    csa5_0_242: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(242)                   ,--i--
        b            => ex3_pp4_0s(242)                   ,--i--
        c            => ex3_recycle_c(242)                ,--i--
        d            => ex3_recycle_s(242)                ,--i--
        ki           => ex3_pp5_0k(242)                   ,--i--
        ko           => ex3_pp5_0k(241)                   ,--o--
        sum          => ex3_pp5_0s(242)                   ,--o--
        car          => ex3_pp5_0c(241)                  );--o--
    csa5_0_241: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(241)                   ,--i--
        b            => ex3_pp4_0s(241)                   ,--i--
        c            => ex3_recycle_c(241)                ,--i--
        d            => ex3_recycle_s(241)                ,--i--
        ki           => ex3_pp5_0k(241)                   ,--i--
        ko           => ex3_pp5_0k(240)                   ,--o--
        sum          => ex3_pp5_0s(241)                   ,--o--
        car          => ex3_pp5_0c(240)                  );--o--
    csa5_0_240: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(240)                   ,--i--
        b            => ex3_pp4_0s(240)                   ,--i--
        c            => ex3_recycle_c(240)                ,--i--
        d            => ex3_recycle_s(240)                ,--i--
        ki           => ex3_pp5_0k(240)                   ,--i--
        ko           => ex3_pp5_0k(239)                   ,--o--
        sum          => ex3_pp5_0s(240)                   ,--o--
        car          => ex3_pp5_0c(239)                  );--o--
    csa5_0_239: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(239)                   ,--i--
        b            => ex3_pp4_0s(239)                   ,--i--
        c            => ex3_recycle_c(239)                ,--i--
        d            => ex3_recycle_s(239)                ,--i--
        ki           => ex3_pp5_0k(239)                   ,--i--
        ko           => ex3_pp5_0k(238)                   ,--o--
        sum          => ex3_pp5_0s(239)                   ,--o--
        car          => ex3_pp5_0c(238)                  );--o--
    csa5_0_238: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(238)                   ,--i--
        b            => ex3_pp4_0s(238)                   ,--i--
        c            => ex3_recycle_c(238)                ,--i--
        d            => ex3_recycle_s(238)                ,--i--
        ki           => ex3_pp5_0k(238)                   ,--i--
        ko           => ex3_pp5_0k(237)                   ,--o--
        sum          => ex3_pp5_0s(238)                   ,--o--
        car          => ex3_pp5_0c(237)                  );--o--
    csa5_0_237: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(237)                   ,--i--
        b            => ex3_pp4_0s(237)                   ,--i--
        c            => ex3_recycle_c(237)                ,--i--
        d            => ex3_recycle_s(237)                ,--i--
        ki           => ex3_pp5_0k(237)                   ,--i--
        ko           => ex3_pp5_0k(236)                   ,--o--
        sum          => ex3_pp5_0s(237)                   ,--o--
        car          => ex3_pp5_0c(236)                  );--o--
    csa5_0_236: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(236)                   ,--i--
        b            => ex3_pp4_0s(236)                   ,--i--
        c            => ex3_recycle_c(236)                ,--i--
        d            => ex3_recycle_s(236)                ,--i--
        ki           => ex3_pp5_0k(236)                   ,--i--
        ko           => ex3_pp5_0k(235)                   ,--o--
        sum          => ex3_pp5_0s(236)                   ,--o--
        car          => ex3_pp5_0c(235)                  );--o--
    csa5_0_235: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(235)                   ,--i--
        b            => ex3_pp4_0s(235)                   ,--i--
        c            => ex3_recycle_c(235)                ,--i--
        d            => ex3_recycle_s(235)                ,--i--
        ki           => ex3_pp5_0k(235)                   ,--i--
        ko           => ex3_pp5_0k(234)                   ,--o--
        sum          => ex3_pp5_0s(235)                   ,--o--
        car          => ex3_pp5_0c(234)                  );--o--
    csa5_0_234: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(234)                   ,--i--
        b            => ex3_pp4_0s(234)                   ,--i--
        c            => ex3_recycle_c(234)                ,--i--
        d            => ex3_recycle_s(234)                ,--i--
        ki           => ex3_pp5_0k(234)                   ,--i--
        ko           => ex3_pp5_0k(233)                   ,--o--
        sum          => ex3_pp5_0s(234)                   ,--o--
        car          => ex3_pp5_0c(233)                  );--o--
    csa5_0_233: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(233)                   ,--i--
        b            => ex3_pp4_0s(233)                   ,--i--
        c            => ex3_recycle_c(233)                ,--i--
        d            => ex3_recycle_s(233)                ,--i--
        ki           => ex3_pp5_0k(233)                   ,--i--
        ko           => ex3_pp5_0k(232)                   ,--o--
        sum          => ex3_pp5_0s(233)                   ,--o--
        car          => ex3_pp5_0c(232)                  );--o--
    csa5_0_232: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(232)                   ,--i--
        b            => ex3_pp4_0s(232)                   ,--i--
        c            => ex3_recycle_c(232)                ,--i--
        d            => ex3_recycle_s(232)                ,--i--
        ki           => ex3_pp5_0k(232)                   ,--i--
        ko           => ex3_pp5_0k(231)                   ,--o--
        sum          => ex3_pp5_0s(232)                   ,--o--
        car          => ex3_pp5_0c(231)                  );--o--
    csa5_0_231: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(231)                   ,--i--
        b            => ex3_pp4_0s(231)                   ,--i--
        c            => ex3_recycle_c(231)                ,--i--
        d            => ex3_recycle_s(231)                ,--i--
        ki           => ex3_pp5_0k(231)                   ,--i--
        ko           => ex3_pp5_0k(230)                   ,--o--
        sum          => ex3_pp5_0s(231)                   ,--o--
        car          => ex3_pp5_0c(230)                  );--o--
    csa5_0_230: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(230)                   ,--i--
        b            => ex3_pp4_0s(230)                   ,--i--
        c            => ex3_recycle_c(230)                ,--i--
        d            => ex3_recycle_s(230)                ,--i--
        ki           => ex3_pp5_0k(230)                   ,--i--
        ko           => ex3_pp5_0k(229)                   ,--o--
        sum          => ex3_pp5_0s(230)                   ,--o--
        car          => ex3_pp5_0c(229)                  );--o--
    csa5_0_229: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(229)                   ,--i--
        b            => ex3_pp4_0s(229)                   ,--i--
        c            => ex3_recycle_c(229)                ,--i--
        d            => ex3_recycle_s(229)                ,--i--
        ki           => ex3_pp5_0k(229)                   ,--i--
        ko           => ex3_pp5_0k(228)                   ,--o--
        sum          => ex3_pp5_0s(229)                   ,--o--
        car          => ex3_pp5_0c(228)                  );--o--
    csa5_0_228: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(228)                   ,--i--
        b            => ex3_pp4_0s(228)                   ,--i--
        c            => ex3_recycle_c(228)                ,--i--
        d            => ex3_recycle_s(228)                ,--i--
        ki           => ex3_pp5_0k(228)                   ,--i--
        ko           => ex3_pp5_0k(227)                   ,--o--
        sum          => ex3_pp5_0s(228)                   ,--o--
        car          => ex3_pp5_0c(227)                  );--o--
    csa5_0_227: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(227)                   ,--i--
        b            => ex3_pp4_0s(227)                   ,--i--
        c            => ex3_recycle_c(227)                ,--i--
        d            => ex3_recycle_s(227)                ,--i--
        ki           => ex3_pp5_0k(227)                   ,--i--
        ko           => ex3_pp5_0k(226)                   ,--o--
        sum          => ex3_pp5_0s(227)                   ,--o--
        car          => ex3_pp5_0c(226)                  );--o--
    csa5_0_226: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(226)                   ,--i--
        b            => ex3_pp4_0s(226)                   ,--i--
        c            => ex3_recycle_c(226)                ,--i--
        d            => ex3_recycle_s(226)                ,--i--
        ki           => ex3_pp5_0k(226)                   ,--i--
        ko           => ex3_pp5_0k(225)                   ,--o--
        sum          => ex3_pp5_0s(226)                   ,--o--
        car          => ex3_pp5_0c(225)                  );--o--
    csa5_0_225: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(225)                   ,--i--
        b            => ex3_pp4_0s(225)                   ,--i--
        c            => ex3_recycle_c(225)                ,--i--
        d            => ex3_recycle_s(225)                ,--i--
        ki           => ex3_pp5_0k(225)                   ,--i--
        ko           => ex3_pp5_0k(224)                   ,--o--
        sum          => ex3_pp5_0s(225)                   ,--o--
        car          => ex3_pp5_0c(224)                  );--o--
    csa5_0_224: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(224)                   ,--i--
        b            => ex3_pp4_0s(224)                   ,--i--
        c            => ex3_recycle_c(224)                ,--i--
        d            => ex3_recycle_s(224)                ,--i--
        ki           => ex3_pp5_0k(224)                   ,--i--
        ko           => ex3_pp5_0k(223)                   ,--o--
        sum          => ex3_pp5_0s(224)                   ,--o--
        car          => ex3_pp5_0c(223)                  );--o--
    csa5_0_223: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(223)                   ,--i--
        b            => ex3_pp4_0s(223)                   ,--i--
        c            => ex3_recycle_c(223)                ,--i--
        d            => ex3_recycle_s(223)                ,--i--
        ki           => ex3_pp5_0k(223)                   ,--i--
        ko           => ex3_pp5_0k(222)                   ,--o--
        sum          => ex3_pp5_0s(223)                   ,--o--
        car          => ex3_pp5_0c(222)                  );--o--
    csa5_0_222: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(222)                   ,--i--
        b            => ex3_pp4_0s(222)                   ,--i--
        c            => ex3_recycle_c(222)                ,--i--
        d            => ex3_recycle_s(222)                ,--i--
        ki           => ex3_pp5_0k(222)                   ,--i--
        ko           => ex3_pp5_0k(221)                   ,--o--
        sum          => ex3_pp5_0s(222)                   ,--o--
        car          => ex3_pp5_0c(221)                  );--o--
    csa5_0_221: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(221)                   ,--i--
        b            => ex3_pp4_0s(221)                   ,--i--
        c            => ex3_recycle_c(221)                ,--i--
        d            => ex3_recycle_s(221)                ,--i--
        ki           => ex3_pp5_0k(221)                   ,--i--
        ko           => ex3_pp5_0k(220)                   ,--o--
        sum          => ex3_pp5_0s(221)                   ,--o--
        car          => ex3_pp5_0c(220)                  );--o--
    csa5_0_220: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(220)                   ,--i--
        b            => ex3_pp4_0s(220)                   ,--i--
        c            => ex3_recycle_c(220)                ,--i--
        d            => ex3_recycle_s(220)                ,--i--
        ki           => ex3_pp5_0k(220)                   ,--i--
        ko           => ex3_pp5_0k(219)                   ,--o--
        sum          => ex3_pp5_0s(220)                   ,--o--
        car          => ex3_pp5_0c(219)                  );--o--
    csa5_0_219: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(219)                   ,--i--
        b            => ex3_pp4_0s(219)                   ,--i--
        c            => ex3_recycle_c(219)                ,--i--
        d            => ex3_recycle_s(219)                ,--i--
        ki           => ex3_pp5_0k(219)                   ,--i--
        ko           => ex3_pp5_0k(218)                   ,--o--
        sum          => ex3_pp5_0s(219)                   ,--o--
        car          => ex3_pp5_0c(218)                  );--o--
    csa5_0_218: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(218)                   ,--i--
        b            => ex3_pp4_0s(218)                   ,--i--
        c            => ex3_recycle_c(218)                ,--i--
        d            => ex3_recycle_s(218)                ,--i--
        ki           => ex3_pp5_0k(218)                   ,--i--
        ko           => ex3_pp5_0k(217)                   ,--o--
        sum          => ex3_pp5_0s(218)                   ,--o--
        car          => ex3_pp5_0c(217)                  );--o--
    csa5_0_217: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(217)                   ,--i--
        b            => ex3_pp4_0s(217)                   ,--i--
        c            => ex3_recycle_c(217)                ,--i--
        d            => ex3_recycle_s(217)                ,--i--
        ki           => ex3_pp5_0k(217)                   ,--i--
        ko           => ex3_pp5_0k(216)                   ,--o--
        sum          => ex3_pp5_0s(217)                   ,--o--
        car          => ex3_pp5_0c(216)                  );--o--
    csa5_0_216: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(216)                   ,--i--
        b            => ex3_pp4_0s(216)                   ,--i--
        c            => ex3_recycle_c(216)                ,--i--
        d            => ex3_recycle_s(216)                ,--i--
        ki           => ex3_pp5_0k(216)                   ,--i--
        ko           => ex3_pp5_0k(215)                   ,--o--
        sum          => ex3_pp5_0s(216)                   ,--o--
        car          => ex3_pp5_0c(215)                  );--o--
    csa5_0_215: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(215)                   ,--i--
        b            => ex3_pp4_0s(215)                   ,--i--
        c            => ex3_recycle_c(215)                ,--i--
        d            => ex3_recycle_s(215)                ,--i--
        ki           => ex3_pp5_0k(215)                   ,--i--
        ko           => ex3_pp5_0k(214)                   ,--o--
        sum          => ex3_pp5_0s(215)                   ,--o--
        car          => ex3_pp5_0c(214)                  );--o--
    csa5_0_214: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(214)                   ,--i--
        b            => ex3_pp4_0s(214)                   ,--i--
        c            => ex3_recycle_c(214)                ,--i--
        d            => ex3_recycle_s(214)                ,--i--
        ki           => ex3_pp5_0k(214)                   ,--i--
        ko           => ex3_pp5_0k(213)                   ,--o--
        sum          => ex3_pp5_0s(214)                   ,--o--
        car          => ex3_pp5_0c(213)                  );--o--
    csa5_0_213: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(213)                   ,--i--
        b            => ex3_pp4_0s(213)                   ,--i--
        c            => ex3_recycle_c(213)                ,--i--
        d            => ex3_recycle_s(213)                ,--i--
        ki           => ex3_pp5_0k(213)                   ,--i--
        ko           => ex3_pp5_0k(212)                   ,--o--
        sum          => ex3_pp5_0s(213)                   ,--o--
        car          => ex3_pp5_0c(212)                  );--o--
    csa5_0_212: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(212)                   ,--i--
        b            => ex3_pp4_0s(212)                   ,--i--
        c            => ex3_recycle_c(212)                ,--i--
        d            => ex3_recycle_s(212)                ,--i--
        ki           => ex3_pp5_0k(212)                   ,--i--
        ko           => ex3_pp5_0k(211)                   ,--o--
        sum          => ex3_pp5_0s(212)                   ,--o--
        car          => ex3_pp5_0c(211)                  );--o--
    csa5_0_211: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(211)                   ,--i--
        b            => ex3_pp4_0s(211)                   ,--i--
        c            => ex3_recycle_c(211)                ,--i--
        d            => ex3_recycle_s(211)                ,--i--
        ki           => ex3_pp5_0k(211)                   ,--i--
        ko           => ex3_pp5_0k(210)                   ,--o--
        sum          => ex3_pp5_0s(211)                   ,--o--
        car          => ex3_pp5_0c(210)                  );--o--
    csa5_0_210: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(210)                   ,--i--
        b            => ex3_pp4_0s(210)                   ,--i--
        c            => ex3_recycle_c(210)                ,--i--
        d            => ex3_recycle_s(210)                ,--i--
        ki           => ex3_pp5_0k(210)                   ,--i--
        ko           => ex3_pp5_0k(209)                   ,--o--
        sum          => ex3_pp5_0s(210)                   ,--o--
        car          => ex3_pp5_0c(209)                  );--o--
    csa5_0_209: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(209)                   ,--i--
        b            => ex3_pp4_0s(209)                   ,--i--
        c            => ex3_recycle_c(209)                ,--i--
        d            => ex3_recycle_s(209)                ,--i--
        ki           => ex3_pp5_0k(209)                   ,--i--
        ko           => ex3_pp5_0k(208)                   ,--o--
        sum          => ex3_pp5_0s(209)                   ,--o--
        car          => ex3_pp5_0c(208)                  );--o--
    csa5_0_208: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(208)                   ,--i--
        b            => ex3_pp4_0s(208)                   ,--i--
        c            => ex3_recycle_c(208)                ,--i--
        d            => ex3_recycle_s(208)                ,--i--
        ki           => ex3_pp5_0k(208)                   ,--i--
        ko           => ex3_pp5_0k(207)                   ,--o--
        sum          => ex3_pp5_0s(208)                   ,--o--
        car          => ex3_pp5_0c(207)                  );--o--
    csa5_0_207: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(207)                   ,--i--
        b            => ex3_pp4_0s(207)                   ,--i--
        c            => ex3_recycle_c(207)                ,--i--
        d            => ex3_recycle_s(207)                ,--i--
        ki           => ex3_pp5_0k(207)                   ,--i--
        ko           => ex3_pp5_0k(206)                   ,--o--
        sum          => ex3_pp5_0s(207)                   ,--o--
        car          => ex3_pp5_0c(206)                  );--o--
    csa5_0_206: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(206)                   ,--i--
        b            => ex3_pp4_0s(206)                   ,--i--
        c            => ex3_recycle_c(206)                ,--i--
        d            => ex3_recycle_s(206)                ,--i--
        ki           => ex3_pp5_0k(206)                   ,--i--
        ko           => ex3_pp5_0k(205)                   ,--o--
        sum          => ex3_pp5_0s(206)                   ,--o--
        car          => ex3_pp5_0c(205)                  );--o--
    csa5_0_205: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(205)                   ,--i--
        b            => ex3_pp4_0s(205)                   ,--i--
        c            => ex3_recycle_c(205)                ,--i--
        d            => ex3_recycle_s(205)                ,--i--
        ki           => ex3_pp5_0k(205)                   ,--i--
        ko           => ex3_pp5_0k(204)                   ,--o--
        sum          => ex3_pp5_0s(205)                   ,--o--
        car          => ex3_pp5_0c(204)                  );--o--
    csa5_0_204: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(204)                   ,--i--
        b            => ex3_pp4_0s(204)                   ,--i--
        c            => ex3_recycle_c(204)                ,--i--
        d            => ex3_recycle_s(204)                ,--i--
        ki           => ex3_pp5_0k(204)                   ,--i--
        ko           => ex3_pp5_0k(203)                   ,--o--
        sum          => ex3_pp5_0s(204)                   ,--o--
        car          => ex3_pp5_0c(203)                  );--o--
    csa5_0_203: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(203)                   ,--i--
        b            => ex3_pp4_0s(203)                   ,--i--
        c            => ex3_recycle_c(203)                ,--i--
        d            => ex3_recycle_s(203)                ,--i--
        ki           => ex3_pp5_0k(203)                   ,--i--
        ko           => ex3_pp5_0k(202)                   ,--o--
        sum          => ex3_pp5_0s(203)                   ,--o--
        car          => ex3_pp5_0c(202)                  );--o--
    csa5_0_202: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(202)                   ,--i--
        b            => ex3_pp4_0s(202)                   ,--i--
        c            => ex3_recycle_c(202)                ,--i--
        d            => ex3_recycle_s(202)                ,--i--
        ki           => ex3_pp5_0k(202)                   ,--i--
        ko           => ex3_pp5_0k(201)                   ,--o--
        sum          => ex3_pp5_0s(202)                   ,--o--
        car          => ex3_pp5_0c(201)                  );--o--
    csa5_0_201: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(201)                   ,--i--
        b            => ex3_pp4_0s(201)                   ,--i--
        c            => ex3_recycle_c(201)                ,--i--
        d            => ex3_recycle_s(201)                ,--i--
        ki           => ex3_pp5_0k(201)                   ,--i--
        ko           => ex3_pp5_0k(200)                   ,--o--
        sum          => ex3_pp5_0s(201)                   ,--o--
        car          => ex3_pp5_0c(200)                  );--o--
    csa5_0_200: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(200)                   ,--i--
        b            => ex3_pp4_0s(200)                   ,--i--
        c            => ex3_recycle_c(200)                ,--i--
        d            => ex3_recycle_s(200)                ,--i--
        ki           => ex3_pp5_0k(200)                   ,--i--
        ko           => ex3_pp5_0k(199)                   ,--o--
        sum          => ex3_pp5_0s(200)                   ,--o--
        car          => ex3_pp5_0c(199)                  );--o--
    csa5_0_199: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(199)                   ,--i--
        b            => ex3_pp4_0s(199)                   ,--i--
        c            => ex3_recycle_c(199)                ,--i--
        d            => ex3_recycle_s(199)                ,--i--
        ki           => ex3_pp5_0k(199)                   ,--i--
        ko           => ex3_pp5_0k(198)                   ,--o--
        sum          => ex3_pp5_0s(199)                   ,--o--
        car          => ex3_pp5_0c(198)                  );--o--
    csa5_0_198: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(198)                   ,--i--
        b            => ex3_pp4_0s(198)                   ,--i--
        c            => ex3_recycle_c(198)                ,--i--
        d            => ex3_recycle_s(198)                ,--i--
        ki           => ex3_pp5_0k(198)                   ,--i--
        ko           => ex3_pp5_0k(197)                   ,--o--
        sum          => ex3_pp5_0s(198)                   ,--o--
        car          => ex3_pp5_0c(197)                  );--o--
    csa5_0_197: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(197)                   ,--i--
        b            => ex3_pp4_0s(197)                   ,--i--
        c            => ex3_recycle_c(197)                ,--i--
        d            => ex3_recycle_s(197)                ,--i--
        ki           => ex3_pp5_0k(197)                   ,--i--
        ko           => ex3_pp5_0k(196)                   ,--o--
        sum          => ex3_pp5_0s(197)                   ,--o--
        car          => ex3_pp5_0c(196)                  );--o--
    csa5_0_196: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_recycle_c(196)                ,--i--
        b            => ex3_recycle_s(196)                ,--i--
        c            => ex3_pp5_0k(196)                   ,--i--
        sum          => ex3_pp5_0s(196)                   ,--o--
        car          => ex3_pp5_0c(195)                  );--o--




   ex4_pp5_0s_din(196 to 264) <= ex3_pp5_0s(196 to 264);
   ex4_pp5_0c_din(196 to 263) <= ex3_pp5_0c(196 to 263);

--==================================================================================
--== EX4 (adder ... 64 bit) part of overflow detection
--==================================================================================

  u_sum_qi: ex4_pp5_0s(196 to 264) <= not ex4_pp5_0s_q_b(196 to 264) ;
  u_car_qi: ex4_pp5_0c(196 to 263) <= not ex4_pp5_0c_q_b(196 to 263) ;

  ex4_pp5_0s_out(196 to 264) <= ex4_pp5_0s(196 to 264) ; --output--
  ex4_pp5_0c_out(196 to 263) <= ex4_pp5_0c(196 to 263) ; --output--


--==================================================================================
--== Pervasive stuff
--==================================================================================


    ex3_lcb: tri_lcbnd generic map (expand_type => expand_type) port map (
        delay_lclkr =>  delay_lclkr_dc     ,--in -- tidn ,
        mpw1_b      =>  mpw1_dc_b          ,--in -- tidn ,
        mpw2_b      =>  mpw2_dc_b          ,--in -- tidn ,
        forcee =>  func_sl_force      ,--in -- tidn ,
        nclk        =>  nclk               ,--in
        vd          =>  vdd                ,--inout
        gd          =>  gnd                ,--inout
        act         =>  ex2_act            ,--in
        sg          =>  sg_0               ,--in
        thold_b     =>  func_sl_thold_0_b  ,--in
        d1clk       =>  ex3_d1clk          ,--out
        d2clk       =>  ex3_d2clk          ,--out
        lclk        =>  ex3_lclk          );--out

    ex4_lcb: tri_lcbnd generic map (expand_type => expand_type) port map (
        delay_lclkr =>  delay_lclkr_dc     ,--in -- tidn ,
        mpw1_b      =>  mpw1_dc_b          ,--in -- tidn ,
        mpw2_b      =>  mpw2_dc_b          ,--in -- tidn ,
        forcee =>  func_sl_force      ,--in -- tidn ,
        nclk        =>  nclk               ,--in
        vd          =>  vdd                ,--inout
        gd          =>  gnd                ,--inout
        act         =>  ex3_act            ,--in
        sg          =>  sg_0               ,--in
        thold_b     =>  func_sl_thold_0_b  ,--in
        d1clk       =>  ex4_d1clk          ,--out
        d2clk       =>  ex4_d2clk          ,--out
        lclk        =>  ex4_lclk          );--out

--==================================================================================
--== Latches
--==================================================================================


    ex3_pp2_0s_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 45,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 45=>'0')) port map (
        VD               => vdd                          ,--inout
        GD               => gnd                          ,--inout
        LCLK             => ex3_lclk                     ,--lclk.clk
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_0s_lat_si            ,
        SCANOUT          => ex3_pp2_0s_lat_so            ,
        D                => ex3_pp2_0s_din(198 to 242)   ,
        QB               => ex3_pp2_0s_q_b(198 to 242)  );
    ex3_pp2_0c_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 43,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 43=>'0')   ) port map (
        VD               => vdd                          ,--inout
        GD               => gnd                          ,--inout
        LCLK             => ex3_lclk                     ,--lclk.clk
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_0c_lat_si            ,
        SCANOUT          => ex3_pp2_0c_lat_so            ,
        D                => ex3_pp2_0c_din(198 to 240)   ,
        QB               => ex3_pp2_0c_q_b(198 to 240)  );

    ex3_pp2_1s_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 47,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 47=>'0')   ) port map (
        VD               => vdd                          ,--inout
        GD               => gnd                          ,--inout
        LCLK             => ex3_lclk                     ,--lclk.clk
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_1s_lat_si            ,
        SCANOUT          => ex3_pp2_1s_lat_so            ,
        D                => ex3_pp2_1s_din(208 to 254)   ,
        QB               => ex3_pp2_1s_q_b(208 to 254)  );

    ex3_pp2_1c_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 45,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 45=>'0')   ) port map (
        VD               => vdd                          ,--inout
        GD               => gnd                          ,--inout
        LCLK             => ex3_lclk                     ,--lclk.clk
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_1c_lat_si            ,
        SCANOUT          => ex3_pp2_1c_lat_so            ,
        D                => ex3_pp2_1c_din(208 to 252)   ,
        QB               => ex3_pp2_1c_q_b(208 to 252)  );

    ex3_pp2_2s_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 45,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 45=>'0')   ) port map (
        VD               => vdd                          ,--inout
        GD               => gnd                          ,--inout
        LCLK             => ex3_lclk                     ,--lclk.clk
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_2s_lat_si            ,
        SCANOUT          => ex3_pp2_2s_lat_so            ,
        D                => ex3_pp2_2s_din(220 to 264)   ,
        QB               => ex3_pp2_2s_q_b(220 to 264)  );

    ex3_pp2_2c_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 44,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 44=>'0')   ) port map (
        VD               => vdd                          ,--inout
        GD               => gnd                          ,--inout
        LCLK             => ex3_lclk                     ,--lclk.clk
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_2c_lat_si            ,
        SCANOUT          => ex3_pp2_2c_lat_so            ,
        D                => ex3_pp2_2c_din(220 to 263)   ,
        QB               => ex3_pp2_2c_q_b(220 to 263)  );


    ex4_pp5_0s_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 69,btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 69=>'0')   ) port map (
        VD               => vdd                          ,--inout
        GD               => gnd                          ,--inout
        LCLK             => ex4_lclk                     ,--lclk.clk
        D1CLK            => ex4_d1clk                    ,
        D2CLK            => ex4_d2clk                    ,
        SCANIN           => ex4_pp5_0s_lat_si            ,
        SCANOUT          => ex4_pp5_0s_lat_so            ,
        D                => ex4_pp5_0s_din(196 to 264)   ,
        QB               => ex4_pp5_0s_q_b(196 to 264)  );

    ex4_pp5_0c_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 68,btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 68=>'0')   ) port map (
        VD               => vdd                          ,--inout
        GD               => gnd                          ,--inout
        LCLK             => ex4_lclk                     ,--lclk.clk
        D1CLK            => ex4_d1clk                    ,
        D2CLK            => ex4_d2clk                    ,
        SCANIN           => ex4_pp5_0c_lat_si            ,
        SCANOUT          => ex4_pp5_0c_lat_so            ,
        D                => ex4_pp5_0c_din(196 to 263)   ,
        QB               => ex4_pp5_0c_q_b(196 to 263)  );



--==================================================================================
--== scan string  (serpentine)
--==================================================================================



   ex3_pp2_0s_lat_si(198 to 242) <= scan_in &                ex3_pp2_0s_lat_so(198 to 241)  ;
   ex3_pp2_0c_lat_si(198 to 240) <=                          ex3_pp2_0c_lat_so(199 to 240) & ex3_pp2_0s_lat_so(242);
   ex3_pp2_1s_lat_si(208 to 254) <= ex3_pp2_0c_lat_so(198) & ex3_pp2_1s_lat_so(208 to 253);
   ex3_pp2_1c_lat_si(208 to 252) <=                          ex3_pp2_1c_lat_so(209 to 252) & ex3_pp2_1s_lat_so(254);
   ex3_pp2_2s_lat_si(220 to 264) <= ex3_pp2_1c_lat_so(208) & ex3_pp2_2s_lat_so(220 to 263);
   ex3_pp2_2c_lat_si(220 to 263) <=                          ex3_pp2_2c_lat_so(221 to 263) & ex3_pp2_2s_lat_so(264);

   ex4_pp5_0s_lat_si(196 to 264) <= ex3_pp2_2c_lat_so(220) & ex4_pp5_0s_lat_so(196 to 263);
   ex4_pp5_0c_lat_si(196 to 263) <=                          ex4_pp5_0c_lat_so(197 to 263) & ex4_pp5_0s_lat_so(264);

   scan_out <=                      ex4_pp5_0c_lat_so(196) ;
   
   
   mark_unused(ex2_pp1_1s(241));
   mark_unused(ex2_pp1_1c(238));
   mark_unused(ex2_pp1_1c(239));
   mark_unused(ex2_pp1_2s(247));
   mark_unused(ex2_pp1_2c(244));
   mark_unused(ex2_pp1_2c(245));
   mark_unused(ex2_pp1_3s(253));
   mark_unused(ex2_pp1_3c(250));
   mark_unused(ex2_pp1_3c(251));
   mark_unused(ex2_pp1_4s(259));
   mark_unused(ex2_pp1_4c(256));
   mark_unused(ex2_pp1_4c(257));
   mark_unused(ex2_pp1_5c(262));
   mark_unused(ex2_pp1_5c(263));
   mark_unused(ex3_pp2_0s(241));
   mark_unused(ex3_pp2_0c(236));
   mark_unused(ex3_pp2_0c(238));
   mark_unused(ex3_pp2_0c(239));
   mark_unused(ex3_pp2_1s(253));
   mark_unused(ex3_pp2_1c(248));
   mark_unused(ex3_pp2_1c(250));
   mark_unused(ex3_pp2_1c(251));
   mark_unused(ex3_pp2_2c(260));
   mark_unused(ex3_pp2_2c(262));
   mark_unused(ex3_pp2_1s_x(253));
   mark_unused(ex3_pp2_1c_x(248));
   mark_unused(ex3_pp2_1c_x(250));
   mark_unused(ex3_pp2_1c_x(251));
   mark_unused(ex3_pp2_2c_x(260));
   mark_unused(ex3_pp2_2c_x(262));
   mark_unused(ex3_pp2_1s_x_b(253));
   mark_unused(ex3_pp2_1c_x_b(248));
   mark_unused(ex3_pp2_1c_x_b(250));
   mark_unused(ex3_pp2_1c_x_b(251));
   mark_unused(ex3_pp2_2c_x_b(260));
   mark_unused(ex3_pp2_2c_x_b(262));
   mark_unused(ex3_pp3_0s(248));
   mark_unused(ex3_pp3_0s(250));
   mark_unused(ex3_pp3_0s(251));
   mark_unused(ex3_pp3_0c(240));
   mark_unused(ex3_pp3_0c(241));
   mark_unused(ex3_pp3_1c(254));
   mark_unused(ex3_pp3_1c(260));
   mark_unused(ex3_pp4_0c(252));
   mark_unused(ex3_pp4_0c(254));
   mark_unused(ex3_pp4_0c(260));
   mark_unused(ex2_pp1_0c(232));
   mark_unused(ex2_pp1_0c(233));
   mark_unused(ex2_pp0_00(233));
   mark_unused(ex2_pp0_01(235));
   mark_unused(ex2_pp0_02(237));
   mark_unused(ex2_pp0_03(239));
   mark_unused(ex2_pp0_04(241));
   mark_unused(ex2_pp0_05(243));
   mark_unused(ex2_pp0_06(245));
   mark_unused(ex2_pp0_07(247));
   mark_unused(ex2_pp0_08(249));
   mark_unused(ex2_pp0_09(251));
   mark_unused(ex2_pp0_10(253));
   mark_unused(ex2_pp0_11(255));
   mark_unused(ex2_pp0_12(257));
   mark_unused(ex2_pp0_13(259));
   mark_unused(ex2_pp0_14(261));
   mark_unused(ex2_pp0_15(263));
   mark_unused(ex2_pp1_0s(235));
   mark_unused(ex3_pp5_0c(195));
   mark_unused(version(0 to 7));



end architecture xuq_alu_mult_core;


