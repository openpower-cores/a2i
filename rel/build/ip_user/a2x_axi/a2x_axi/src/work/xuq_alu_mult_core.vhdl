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



entity xuq_alu_mult_core is    generic ( expand_type: integer := 2  );   port (

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

        ex2_act                         :in std_ulogic; 
        ex3_act                         :in std_ulogic; 

        ex2_bs_lo_sign                  :in  std_ulogic;                 
        ex2_bd_lo_sign                  :in  std_ulogic;                 
        ex2_bd_lo                       :in  std_ulogic_vector(0 to 31); 
        ex2_bs_lo                       :in  std_ulogic_vector(0 to 31); 

        ex3_recycle_s                   :in  std_ulogic_vector(196 to 264); 
        ex3_recycle_c                   :in  std_ulogic_vector(196 to 263); 

        ex4_pp5_0s_out                  :out std_ulogic_vector(196 to 264); 
        ex4_pp5_0c_out                  :out std_ulogic_vector(196 to 263)  
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


 bd_00: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo_sign            ,
     i1      => ex2_bd_lo(0)              ,
     i2      => ex2_bd_lo(1)              ,
     s_neg   => ex2_bd_neg(0)             ,
     s_x     => ex2_bd_sh0(0)             ,
     s_x2    => ex2_bd_sh1(0)            );
 bd_01: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(1)              ,
     i1      => ex2_bd_lo(2)              ,
     i2      => ex2_bd_lo(3)              ,
     s_neg   => ex2_bd_neg(1)             ,
     s_x     => ex2_bd_sh0(1)             ,
     s_x2    => ex2_bd_sh1(1)            );
 bd_02: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(3)              ,
     i1      => ex2_bd_lo(4)              ,
     i2      => ex2_bd_lo(5)              ,
     s_neg   => ex2_bd_neg(2)             ,
     s_x     => ex2_bd_sh0(2)             ,
     s_x2    => ex2_bd_sh1(2)            );
 bd_03: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(5)              ,
     i1      => ex2_bd_lo(6)              ,
     i2      => ex2_bd_lo(7)              ,
     s_neg   => ex2_bd_neg(3)             ,
     s_x     => ex2_bd_sh0(3)             ,
     s_x2    => ex2_bd_sh1(3)            );
 bd_04: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(7)              ,
     i1      => ex2_bd_lo(8)              ,
     i2      => ex2_bd_lo(9)              ,
     s_neg   => ex2_bd_neg(4)             ,
     s_x     => ex2_bd_sh0(4)             ,
     s_x2    => ex2_bd_sh1(4)            );
 bd_05: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(9)              ,
     i1      => ex2_bd_lo(10)             ,
     i2      => ex2_bd_lo(11)             ,
     s_neg   => ex2_bd_neg(5)             ,
     s_x     => ex2_bd_sh0(5)             ,
     s_x2    => ex2_bd_sh1(5)            );
 bd_06: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(11)             ,
     i1      => ex2_bd_lo(12)             ,
     i2      => ex2_bd_lo(13)             ,
     s_neg   => ex2_bd_neg(6)             ,
     s_x     => ex2_bd_sh0(6)             ,
     s_x2    => ex2_bd_sh1(6)            );
 bd_07: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(13)             ,
     i1      => ex2_bd_lo(14)             ,
     i2      => ex2_bd_lo(15)             ,
     s_neg   => ex2_bd_neg(7)             ,
     s_x     => ex2_bd_sh0(7)             ,
     s_x2    => ex2_bd_sh1(7)            );
 bd_08: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(15)             ,
     i1      => ex2_bd_lo(16)             ,
     i2      => ex2_bd_lo(17)             ,
     s_neg   => ex2_bd_neg(8)             ,
     s_x     => ex2_bd_sh0(8)             ,
     s_x2    => ex2_bd_sh1(8)            );
 bd_09: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(17)             ,
     i1      => ex2_bd_lo(18)             ,
     i2      => ex2_bd_lo(19)             ,
     s_neg   => ex2_bd_neg(9)             ,
     s_x     => ex2_bd_sh0(9)             ,
     s_x2    => ex2_bd_sh1(9)            );
 bd_10: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(19)             ,
     i1      => ex2_bd_lo(20)             ,
     i2      => ex2_bd_lo(21)             ,
     s_neg   => ex2_bd_neg(10)            ,
     s_x     => ex2_bd_sh0(10)            ,
     s_x2    => ex2_bd_sh1(10)           );
 bd_11: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(21)             ,
     i1      => ex2_bd_lo(22)             ,
     i2      => ex2_bd_lo(23)             ,
     s_neg   => ex2_bd_neg(11)            ,
     s_x     => ex2_bd_sh0(11)            ,
     s_x2    => ex2_bd_sh1(11)           );
 bd_12: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(23)             ,
     i1      => ex2_bd_lo(24)             ,
     i2      => ex2_bd_lo(25)             ,
     s_neg   => ex2_bd_neg(12)            ,
     s_x     => ex2_bd_sh0(12)            ,
     s_x2    => ex2_bd_sh1(12)           );
 bd_13: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(25)             ,
     i1      => ex2_bd_lo(26)             ,
     i2      => ex2_bd_lo(27)             ,
     s_neg   => ex2_bd_neg(13)            ,
     s_x     => ex2_bd_sh0(13)            ,
     s_x2    => ex2_bd_sh1(13)           );
 bd_14: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(27)             ,
     i1      => ex2_bd_lo(28)             ,
     i2      => ex2_bd_lo(29)             ,
     s_neg   => ex2_bd_neg(14)            ,
     s_x     => ex2_bd_sh0(14)            ,
     s_x2    => ex2_bd_sh1(14)           );
 bd_15: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(29)             ,
     i1      => ex2_bd_lo(30)             ,
     i2      => ex2_bd_lo(31)             ,
     s_neg   => ex2_bd_neg(15)            ,
     s_x     => ex2_bd_sh0(15)            ,
     s_x2    => ex2_bd_sh1(15)           );
 bd_16: entity work.xuq_alu_mult_boothdcd port map (
     i0      => ex2_bd_lo(31)             ,
     i1      => tidn                      ,
     i2      => tidn                      ,
     s_neg   => ex2_bd_neg(16)            ,
     s_x     => ex2_bd_sh0(16)            ,
     s_x2    => ex2_bd_sh1(16)           );


br_00: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(0)             ,
     s_x          => ex2_bd_sh0(0)             ,
     s_x2         => ex2_bd_sh1(0)             ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_00_out(0 to 32)    ,
     hot_one      => ex2_hot_one(0)           );
 br_01: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(1)             ,
     s_x          => ex2_bd_sh0(1)             ,
     s_x2         => ex2_bd_sh1(1)             ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_01_out(0 to 32)    ,
     hot_one      => ex2_hot_one(1)           );
 br_02: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(2)             ,
     s_x          => ex2_bd_sh0(2)             ,
     s_x2         => ex2_bd_sh1(2)             ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_02_out(0 to 32)    ,
     hot_one      => ex2_hot_one(2)           );
 br_03: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(3)             ,
     s_x          => ex2_bd_sh0(3)             ,
     s_x2         => ex2_bd_sh1(3)             ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_03_out(0 to 32)    ,
     hot_one      => ex2_hot_one(3)           );
 br_04: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(4)             ,
     s_x          => ex2_bd_sh0(4)             ,
     s_x2         => ex2_bd_sh1(4)             ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_04_out(0 to 32)    ,
     hot_one      => ex2_hot_one(4)           );
 br_05: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(5)             ,
     s_x          => ex2_bd_sh0(5)             ,
     s_x2         => ex2_bd_sh1(5)             ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_05_out(0 to 32)    ,
     hot_one      => ex2_hot_one(5)           );
 br_06: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(6)             ,
     s_x          => ex2_bd_sh0(6)             ,
     s_x2         => ex2_bd_sh1(6)             ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_06_out(0 to 32)    ,
     hot_one      => ex2_hot_one(6)           );
 br_07: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(7)             ,
     s_x          => ex2_bd_sh0(7)             ,
     s_x2         => ex2_bd_sh1(7)             ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_07_out(0 to 32)    ,
     hot_one      => ex2_hot_one(7)           );
 br_08: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(8)             ,
     s_x          => ex2_bd_sh0(8)             ,
     s_x2         => ex2_bd_sh1(8)             ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_08_out(0 to 32)    ,
     hot_one      => ex2_hot_one(8)           );
 br_09: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(9)             ,
     s_x          => ex2_bd_sh0(9)             ,
     s_x2         => ex2_bd_sh1(9)             ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_09_out(0 to 32)    ,
     hot_one      => ex2_hot_one(9)           );
 br_10: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(10)            ,
     s_x          => ex2_bd_sh0(10)            ,
     s_x2         => ex2_bd_sh1(10)            ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_10_out(0 to 32)    ,
     hot_one      => ex2_hot_one(10)          );
 br_11: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(11)            ,
     s_x          => ex2_bd_sh0(11)            ,
     s_x2         => ex2_bd_sh1(11)            ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_11_out(0 to 32)    ,
     hot_one      => ex2_hot_one(11)          );
 br_12: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(12)            ,
     s_x          => ex2_bd_sh0(12)            ,
     s_x2         => ex2_bd_sh1(12)            ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_12_out(0 to 32)    ,
     hot_one      => ex2_hot_one(12)          );
 br_13: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(13)            ,
     s_x          => ex2_bd_sh0(13)            ,
     s_x2         => ex2_bd_sh1(13)            ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_13_out(0 to 32)    ,
     hot_one      => ex2_hot_one(13)          );
 br_14: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(14)            ,
     s_x          => ex2_bd_sh0(14)            ,
     s_x2         => ex2_bd_sh1(14)            ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_14_out(0 to 32)    ,
     hot_one      => ex2_hot_one(14)          );
 br_15: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(15)            ,
     s_x          => ex2_bd_sh0(15)            ,
     s_x2         => ex2_bd_sh1(15)            ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_15_out(0 to 32)    ,
     hot_one      => ex2_hot_one(15)          );
 br_16: entity work.xuq_alu_mult_boothrow port map (
     vdd          => vdd,
     gnd          => gnd,
     s_neg        => ex2_bd_neg(16)            ,
     s_x          => ex2_bd_sh0(16)            ,
     s_x2         => ex2_bd_sh1(16)            ,
     sign_bit_adj => ex2_bs_lo_sign            ,
     x            => ex2_bs_lo(0 to 31)        ,
     q            => ex2_br_16_out(0 to 32)    ,
     hot_one      => ex2_hot_one(16)          );







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



  u_br_00_add: ex2_br_00_add   <= not( ex2_br_00_sign_xor and (ex2_bd_sh0(0)  or ex2_bd_sh1(0)  ) ) ;  
  u_br_01_add: ex2_br_01_add   <= not( ex2_br_01_sign_xor and (ex2_bd_sh0(1)  or ex2_bd_sh1(1)  ) ) ;  
  u_br_02_add: ex2_br_02_add   <= not( ex2_br_02_sign_xor and (ex2_bd_sh0(2)  or ex2_bd_sh1(2)  ) ) ;  
  u_br_03_add: ex2_br_03_add   <= not( ex2_br_03_sign_xor and (ex2_bd_sh0(3)  or ex2_bd_sh1(3)  ) ) ;  
  u_br_04_add: ex2_br_04_add   <= not( ex2_br_04_sign_xor and (ex2_bd_sh0(4)  or ex2_bd_sh1(4)  ) ) ;  
  u_br_05_add: ex2_br_05_add   <= not( ex2_br_05_sign_xor and (ex2_bd_sh0(5)  or ex2_bd_sh1(5)  ) ) ;  
  u_br_06_add: ex2_br_06_add   <= not( ex2_br_06_sign_xor and (ex2_bd_sh0(6)  or ex2_bd_sh1(6)  ) ) ;  
  u_br_07_add: ex2_br_07_add   <= not( ex2_br_07_sign_xor and (ex2_bd_sh0(7)  or ex2_bd_sh1(7)  ) ) ;  
  u_br_08_add: ex2_br_08_add   <= not( ex2_br_08_sign_xor and (ex2_bd_sh0(8)  or ex2_bd_sh1(8)  ) ) ;  
  u_br_09_add: ex2_br_09_add   <= not( ex2_br_09_sign_xor and (ex2_bd_sh0(9)  or ex2_bd_sh1(9)  ) ) ;  
  u_br_10_add: ex2_br_10_add   <= not( ex2_br_10_sign_xor and (ex2_bd_sh0(10) or ex2_bd_sh1(10) ) ) ;  
  u_br_11_add: ex2_br_11_add   <= not( ex2_br_11_sign_xor and (ex2_bd_sh0(11) or ex2_bd_sh1(11) ) ) ;  
  u_br_12_add: ex2_br_12_add   <= not( ex2_br_12_sign_xor and (ex2_bd_sh0(12) or ex2_bd_sh1(12) ) ) ;  
  u_br_13_add: ex2_br_13_add   <= not( ex2_br_13_sign_xor and (ex2_bd_sh0(13) or ex2_bd_sh1(13) ) ) ;  
  u_br_14_add: ex2_br_14_add   <= not( ex2_br_14_sign_xor and (ex2_bd_sh0(14) or ex2_bd_sh1(14) ) ) ;  
  u_br_15_add: ex2_br_15_add   <= not( ex2_br_15_sign_xor and (ex2_bd_sh0(15) or ex2_bd_sh1(15) ) ) ;  
  u_br_16_add: ex2_br_16_add   <= not( ex2_br_16_sign_xor and (ex2_bd_sh0(16) or ex2_bd_sh1(16) ) ) ;  
  u_br_16_sub: ex2_br_16_sub   <=      ex2_br_16_sign_xor and (ex2_bd_sh0(16) or ex2_bd_sh1(16) )   ;  



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







 ex2_pp1_0s(236)                  <= ex2_pp0_01(236)                  ; 
 ex2_pp1_0s(235)                  <= tidn                             ; 
 ex2_pp1_0c(234)                  <= ex2_pp0_01(234)                  ; 
 ex2_pp1_0s(234)                  <= ex2_pp0_00(234)                  ; 
 ex2_pp1_0c(233)                  <= tidn                            ; 
 ex2_pp1_0s(233)                  <= ex2_pp0_01(233)                  ; 
 ex2_pp1_0c(232)                  <= tidn                             ; 


    csa1_0_232: entity clib.c_prism_csa32 port map( 
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_00(232)                   ,
        b            => ex2_pp0_01(232)                   ,
        c            => ex2_pp0_17(232)                   ,
        sum          => ex2_pp1_0s(232)                   ,
        car          => ex2_pp1_0c(231)                  );
    csa1_0_231: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(231)                   ,
        b            => ex2_pp0_01(231)                   ,
        sum          => ex2_pp1_0s(231)                   ,
        car          => ex2_pp1_0c(230)                  );
    csa1_0_230: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(230)                   ,
        b            => ex2_pp0_01(230)                   ,
        sum          => ex2_pp1_0s(230)                   ,
        car          => ex2_pp1_0c(229)                  );
    csa1_0_229: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(229)                   ,
        b            => ex2_pp0_01(229)                   ,
        sum          => ex2_pp1_0s(229)                   ,
        car          => ex2_pp1_0c(228)                  );
    csa1_0_228: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(228)                   ,
        b            => ex2_pp0_01(228)                   ,
        sum          => ex2_pp1_0s(228)                   ,
        car          => ex2_pp1_0c(227)                  );
    csa1_0_227: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(227)                   ,
        b            => ex2_pp0_01(227)                   ,
        sum          => ex2_pp1_0s(227)                   ,
        car          => ex2_pp1_0c(226)                  );
    csa1_0_226: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(226)                   ,
        b            => ex2_pp0_01(226)                   ,
        sum          => ex2_pp1_0s(226)                   ,
        car          => ex2_pp1_0c(225)                  );
    csa1_0_225: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(225)                   ,
        b            => ex2_pp0_01(225)                   ,
        sum          => ex2_pp1_0s(225)                   ,
        car          => ex2_pp1_0c(224)                  );
    csa1_0_224: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(224)                   ,
        b            => ex2_pp0_01(224)                   ,
        sum          => ex2_pp1_0s(224)                   ,
        car          => ex2_pp1_0c(223)                  );
    csa1_0_223: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(223)                   ,
        b            => ex2_pp0_01(223)                   ,
        sum          => ex2_pp1_0s(223)                   ,
        car          => ex2_pp1_0c(222)                  );
    csa1_0_222: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(222)                   ,
        b            => ex2_pp0_01(222)                   ,
        sum          => ex2_pp1_0s(222)                   ,
        car          => ex2_pp1_0c(221)                  );
    csa1_0_221: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(221)                   ,
        b            => ex2_pp0_01(221)                   ,
        sum          => ex2_pp1_0s(221)                   ,
        car          => ex2_pp1_0c(220)                  );
    csa1_0_220: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(220)                   ,
        b            => ex2_pp0_01(220)                   ,
        sum          => ex2_pp1_0s(220)                   ,
        car          => ex2_pp1_0c(219)                  );
    csa1_0_219: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(219)                   ,
        b            => ex2_pp0_01(219)                   ,
        sum          => ex2_pp1_0s(219)                   ,
        car          => ex2_pp1_0c(218)                  );
    csa1_0_218: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(218)                   ,
        b            => ex2_pp0_01(218)                   ,
        sum          => ex2_pp1_0s(218)                   ,
        car          => ex2_pp1_0c(217)                  );
    csa1_0_217: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(217)                   ,
        b            => ex2_pp0_01(217)                   ,
        sum          => ex2_pp1_0s(217)                   ,
        car          => ex2_pp1_0c(216)                  );
    csa1_0_216: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(216)                   ,
        b            => ex2_pp0_01(216)                   ,
        sum          => ex2_pp1_0s(216)                   ,
        car          => ex2_pp1_0c(215)                  );
    csa1_0_215: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(215)                   ,
        b            => ex2_pp0_01(215)                   ,
        sum          => ex2_pp1_0s(215)                   ,
        car          => ex2_pp1_0c(214)                  );
    csa1_0_214: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(214)                   ,
        b            => ex2_pp0_01(214)                   ,
        sum          => ex2_pp1_0s(214)                   ,
        car          => ex2_pp1_0c(213)                  );
    csa1_0_213: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(213)                   ,
        b            => ex2_pp0_01(213)                   ,
        sum          => ex2_pp1_0s(213)                   ,
        car          => ex2_pp1_0c(212)                  );
    csa1_0_212: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(212)                   ,
        b            => ex2_pp0_01(212)                   ,
        sum          => ex2_pp1_0s(212)                   ,
        car          => ex2_pp1_0c(211)                  );
    csa1_0_211: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(211)                   ,
        b            => ex2_pp0_01(211)                   ,
        sum          => ex2_pp1_0s(211)                   ,
        car          => ex2_pp1_0c(210)                  );
    csa1_0_210: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(210)                   ,
        b            => ex2_pp0_01(210)                   ,
        sum          => ex2_pp1_0s(210)                   ,
        car          => ex2_pp1_0c(209)                  );
    csa1_0_209: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(209)                   ,
        b            => ex2_pp0_01(209)                   ,
        sum          => ex2_pp1_0s(209)                   ,
        car          => ex2_pp1_0c(208)                  );
    csa1_0_208: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(208)                   ,
        b            => ex2_pp0_01(208)                   ,
        sum          => ex2_pp1_0s(208)                   ,
        car          => ex2_pp1_0c(207)                  );
    csa1_0_207: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(207)                   ,
        b            => ex2_pp0_01(207)                   ,
        sum          => ex2_pp1_0s(207)                   ,
        car          => ex2_pp1_0c(206)                  );
    csa1_0_206: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(206)                   ,
        b            => ex2_pp0_01(206)                   ,
        sum          => ex2_pp1_0s(206)                   ,
        car          => ex2_pp1_0c(205)                  );
    csa1_0_205: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(205)                   ,
        b            => ex2_pp0_01(205)                   ,
        sum          => ex2_pp1_0s(205)                   ,
        car          => ex2_pp1_0c(204)                  );
    csa1_0_204: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(204)                   ,
        b            => ex2_pp0_01(204)                   ,
        sum          => ex2_pp1_0s(204)                   ,
        car          => ex2_pp1_0c(203)                  );
    csa1_0_203: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(203)                   ,
        b            => ex2_pp0_01(203)                   ,
        sum          => ex2_pp1_0s(203)                   ,
        car          => ex2_pp1_0c(202)                  );
    csa1_0_202: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(202)                   ,
        b            => ex2_pp0_01(202)                   ,
        sum          => ex2_pp1_0s(202)                   ,
        car          => ex2_pp1_0c(201)                  );
    csa1_0_201: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(201)                   ,
        b            => ex2_pp0_01(201)                   ,
        sum          => ex2_pp1_0s(201)                   ,
        car          => ex2_pp1_0c(200)                  );
    csa1_0_200: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_00(200)                   ,
        b            => ex2_pp0_01(200)                   ,
        sum          => ex2_pp1_0s(200)                   ,
        car          => ex2_pp1_0c(199)                  );
 ex2_pp1_0s(199)                  <= ex2_pp0_00(199)                  ; 
 ex2_pp1_0s(198)                  <= ex2_pp0_00(198)                  ; 






 ex2_pp1_1s(242)                  <= ex2_pp0_04(242)                  ; 
 ex2_pp1_1s(241)                  <= tidn                             ; 
 ex2_pp1_1c(240)                  <= ex2_pp0_04(240)                  ; 
 ex2_pp1_1s(240)                  <= ex2_pp0_03(240)                  ; 
 ex2_pp1_1c(239)                  <= tidn                            ; 
 ex2_pp1_1s(239)                  <= ex2_pp0_04(239)                  ; 
 ex2_pp1_1c(238)                  <= tidn                             ; 
    csa1_1_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(238)                   ,
        b            => ex2_pp0_03(238)                   ,
        c            => ex2_pp0_04(238)                   ,
        sum          => ex2_pp1_1s(238)                   ,
        car          => ex2_pp1_1c(237)                  );
    csa1_1_237: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_03(237)                   ,
        b            => ex2_pp0_04(237)                   ,
        sum          => ex2_pp1_1s(237)                   ,
        car          => ex2_pp1_1c(236)                  );
    csa1_1_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(236)                   ,
        b            => ex2_pp0_03(236)                   ,
        c            => ex2_pp0_04(236)                   ,
        sum          => ex2_pp1_1s(236)                   ,
        car          => ex2_pp1_1c(235)                  );
    csa1_1_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(235)                   ,
        b            => ex2_pp0_03(235)                   ,
        c            => ex2_pp0_04(235)                   ,
        sum          => ex2_pp1_1s(235)                   ,
        car          => ex2_pp1_1c(234)                  );
    csa1_1_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(234)                   ,
        b            => ex2_pp0_03(234)                   ,
        c            => ex2_pp0_04(234)                   ,
        sum          => ex2_pp1_1s(234)                   ,
        car          => ex2_pp1_1c(233)                  );
    csa1_1_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(233)                   ,
        b            => ex2_pp0_03(233)                   ,
        c            => ex2_pp0_04(233)                   ,
        sum          => ex2_pp1_1s(233)                   ,
        car          => ex2_pp1_1c(232)                  );
    csa1_1_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(232)                   ,
        b            => ex2_pp0_03(232)                   ,
        c            => ex2_pp0_04(232)                   ,
        sum          => ex2_pp1_1s(232)                   ,
        car          => ex2_pp1_1c(231)                  );
    csa1_1_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(231)                   ,
        b            => ex2_pp0_03(231)                   ,
        c            => ex2_pp0_04(231)                   ,
        sum          => ex2_pp1_1s(231)                   ,
        car          => ex2_pp1_1c(230)                  );
    csa1_1_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(230)                   ,
        b            => ex2_pp0_03(230)                   ,
        c            => ex2_pp0_04(230)                   ,
        sum          => ex2_pp1_1s(230)                   ,
        car          => ex2_pp1_1c(229)                  );
    csa1_1_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(229)                   ,
        b            => ex2_pp0_03(229)                   ,
        c            => ex2_pp0_04(229)                   ,
        sum          => ex2_pp1_1s(229)                   ,
        car          => ex2_pp1_1c(228)                  );
    csa1_1_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(228)                   ,
        b            => ex2_pp0_03(228)                   ,
        c            => ex2_pp0_04(228)                   ,
        sum          => ex2_pp1_1s(228)                   ,
        car          => ex2_pp1_1c(227)                  );
    csa1_1_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(227)                   ,
        b            => ex2_pp0_03(227)                   ,
        c            => ex2_pp0_04(227)                   ,
        sum          => ex2_pp1_1s(227)                   ,
        car          => ex2_pp1_1c(226)                  );
    csa1_1_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(226)                   ,
        b            => ex2_pp0_03(226)                   ,
        c            => ex2_pp0_04(226)                   ,
        sum          => ex2_pp1_1s(226)                   ,
        car          => ex2_pp1_1c(225)                  );
    csa1_1_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(225)                   ,
        b            => ex2_pp0_03(225)                   ,
        c            => ex2_pp0_04(225)                   ,
        sum          => ex2_pp1_1s(225)                   ,
        car          => ex2_pp1_1c(224)                  );
    csa1_1_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(224)                   ,
        b            => ex2_pp0_03(224)                   ,
        c            => ex2_pp0_04(224)                   ,
        sum          => ex2_pp1_1s(224)                   ,
        car          => ex2_pp1_1c(223)                  );
    csa1_1_223: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(223)                   ,
        b            => ex2_pp0_03(223)                   ,
        c            => ex2_pp0_04(223)                   ,
        sum          => ex2_pp1_1s(223)                   ,
        car          => ex2_pp1_1c(222)                  );
    csa1_1_222: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(222)                   ,
        b            => ex2_pp0_03(222)                   ,
        c            => ex2_pp0_04(222)                   ,
        sum          => ex2_pp1_1s(222)                   ,
        car          => ex2_pp1_1c(221)                  );
    csa1_1_221: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(221)                   ,
        b            => ex2_pp0_03(221)                   ,
        c            => ex2_pp0_04(221)                   ,
        sum          => ex2_pp1_1s(221)                   ,
        car          => ex2_pp1_1c(220)                  );
    csa1_1_220: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(220)                   ,
        b            => ex2_pp0_03(220)                   ,
        c            => ex2_pp0_04(220)                   ,
        sum          => ex2_pp1_1s(220)                   ,
        car          => ex2_pp1_1c(219)                  );
    csa1_1_219: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(219)                   ,
        b            => ex2_pp0_03(219)                   ,
        c            => ex2_pp0_04(219)                   ,
        sum          => ex2_pp1_1s(219)                   ,
        car          => ex2_pp1_1c(218)                  );
    csa1_1_218: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(218)                   ,
        b            => ex2_pp0_03(218)                   ,
        c            => ex2_pp0_04(218)                   ,
        sum          => ex2_pp1_1s(218)                   ,
        car          => ex2_pp1_1c(217)                  );
    csa1_1_217: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(217)                   ,
        b            => ex2_pp0_03(217)                   ,
        c            => ex2_pp0_04(217)                   ,
        sum          => ex2_pp1_1s(217)                   ,
        car          => ex2_pp1_1c(216)                  );
    csa1_1_216: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(216)                   ,
        b            => ex2_pp0_03(216)                   ,
        c            => ex2_pp0_04(216)                   ,
        sum          => ex2_pp1_1s(216)                   ,
        car          => ex2_pp1_1c(215)                  );
    csa1_1_215: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(215)                   ,
        b            => ex2_pp0_03(215)                   ,
        c            => ex2_pp0_04(215)                   ,
        sum          => ex2_pp1_1s(215)                   ,
        car          => ex2_pp1_1c(214)                  );
    csa1_1_214: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(214)                   ,
        b            => ex2_pp0_03(214)                   ,
        c            => ex2_pp0_04(214)                   ,
        sum          => ex2_pp1_1s(214)                   ,
        car          => ex2_pp1_1c(213)                  );
    csa1_1_213: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(213)                   ,
        b            => ex2_pp0_03(213)                   ,
        c            => ex2_pp0_04(213)                   ,
        sum          => ex2_pp1_1s(213)                   ,
        car          => ex2_pp1_1c(212)                  );
    csa1_1_212: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(212)                   ,
        b            => ex2_pp0_03(212)                   ,
        c            => ex2_pp0_04(212)                   ,
        sum          => ex2_pp1_1s(212)                   ,
        car          => ex2_pp1_1c(211)                  );
    csa1_1_211: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(211)                   ,
        b            => ex2_pp0_03(211)                   ,
        c            => ex2_pp0_04(211)                   ,
        sum          => ex2_pp1_1s(211)                   ,
        car          => ex2_pp1_1c(210)                  );
    csa1_1_210: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(210)                   ,
        b            => ex2_pp0_03(210)                   ,
        c            => ex2_pp0_04(210)                   ,
        sum          => ex2_pp1_1s(210)                   ,
        car          => ex2_pp1_1c(209)                  );
    csa1_1_209: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(209)                   ,
        b            => ex2_pp0_03(209)                   ,
        c            => ex2_pp0_04(209)                   ,
        sum          => ex2_pp1_1s(209)                   ,
        car          => ex2_pp1_1c(208)                  );
    csa1_1_208: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(208)                   ,
        b            => ex2_pp0_03(208)                   ,
        c            => ex2_pp0_04(208)                   ,
        sum          => ex2_pp1_1s(208)                   ,
        car          => ex2_pp1_1c(207)                  );
    csa1_1_207: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(207)                   ,
        b            => ex2_pp0_03(207)                   ,
        c            => ex2_pp0_04(207)                   ,
        sum          => ex2_pp1_1s(207)                   ,
        car          => ex2_pp1_1c(206)                  );
    csa1_1_206: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_02(206)                   ,
        b            => ex2_pp0_03(206)                   ,
        c            => ex2_pp0_04(206)                   ,
        sum          => ex2_pp1_1s(206)                   ,
        car          => ex2_pp1_1c(205)                  );
    csa1_1_205: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_02(205)                   ,
        b            => ex2_pp0_03(205)                   ,
        sum          => ex2_pp1_1s(205)                   ,
        car          => ex2_pp1_1c(204)                  );
    csa1_1_204: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_02(204)                   ,
        b            => ex2_pp0_03(204)                   ,
        sum          => ex2_pp1_1s(204)                   ,
        car          => ex2_pp1_1c(203)                  );
 ex2_pp1_1s(203)                  <= ex2_pp0_02(203)                  ; 
 ex2_pp1_1s(202)                  <= ex2_pp0_02(202)                  ; 




 ex2_pp1_2s(248)                  <= ex2_pp0_07(248)                  ; 
 ex2_pp1_2s(247)                  <= tidn                             ; 
 ex2_pp1_2c(246)                  <= ex2_pp0_07(246)                  ; 
 ex2_pp1_2s(246)                  <= ex2_pp0_06(246)                  ; 
 ex2_pp1_2c(245)                  <= tidn                            ; 
 ex2_pp1_2s(245)                  <= ex2_pp0_07(245)                  ; 
 ex2_pp1_2c(244)                  <= tidn                             ; 
    csa1_2_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(244)                   ,
        b            => ex2_pp0_06(244)                   ,
        c            => ex2_pp0_07(244)                   ,
        sum          => ex2_pp1_2s(244)                   ,
        car          => ex2_pp1_2c(243)                  );
    csa1_2_243: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_06(243)                   ,
        b            => ex2_pp0_07(243)                   ,
        sum          => ex2_pp1_2s(243)                   ,
        car          => ex2_pp1_2c(242)                  );
    csa1_2_242: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(242)                   ,
        b            => ex2_pp0_06(242)                   ,
        c            => ex2_pp0_07(242)                   ,
        sum          => ex2_pp1_2s(242)                   ,
        car          => ex2_pp1_2c(241)                  );
    csa1_2_241: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(241)                   ,
        b            => ex2_pp0_06(241)                   ,
        c            => ex2_pp0_07(241)                   ,
        sum          => ex2_pp1_2s(241)                   ,
        car          => ex2_pp1_2c(240)                  );
    csa1_2_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(240)                   ,
        b            => ex2_pp0_06(240)                   ,
        c            => ex2_pp0_07(240)                   ,
        sum          => ex2_pp1_2s(240)                   ,
        car          => ex2_pp1_2c(239)                  );
    csa1_2_239: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(239)                   ,
        b            => ex2_pp0_06(239)                   ,
        c            => ex2_pp0_07(239)                   ,
        sum          => ex2_pp1_2s(239)                   ,
        car          => ex2_pp1_2c(238)                  );
    csa1_2_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(238)                   ,
        b            => ex2_pp0_06(238)                   ,
        c            => ex2_pp0_07(238)                   ,
        sum          => ex2_pp1_2s(238)                   ,
        car          => ex2_pp1_2c(237)                  );
    csa1_2_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(237)                   ,
        b            => ex2_pp0_06(237)                   ,
        c            => ex2_pp0_07(237)                   ,
        sum          => ex2_pp1_2s(237)                   ,
        car          => ex2_pp1_2c(236)                  );
    csa1_2_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(236)                   ,
        b            => ex2_pp0_06(236)                   ,
        c            => ex2_pp0_07(236)                   ,
        sum          => ex2_pp1_2s(236)                   ,
        car          => ex2_pp1_2c(235)                  );
    csa1_2_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(235)                   ,
        b            => ex2_pp0_06(235)                   ,
        c            => ex2_pp0_07(235)                   ,
        sum          => ex2_pp1_2s(235)                   ,
        car          => ex2_pp1_2c(234)                  );
    csa1_2_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(234)                   ,
        b            => ex2_pp0_06(234)                   ,
        c            => ex2_pp0_07(234)                   ,
        sum          => ex2_pp1_2s(234)                   ,
        car          => ex2_pp1_2c(233)                  );
    csa1_2_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(233)                   ,
        b            => ex2_pp0_06(233)                   ,
        c            => ex2_pp0_07(233)                   ,
        sum          => ex2_pp1_2s(233)                   ,
        car          => ex2_pp1_2c(232)                  );
    csa1_2_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(232)                   ,
        b            => ex2_pp0_06(232)                   ,
        c            => ex2_pp0_07(232)                   ,
        sum          => ex2_pp1_2s(232)                   ,
        car          => ex2_pp1_2c(231)                  );
    csa1_2_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(231)                   ,
        b            => ex2_pp0_06(231)                   ,
        c            => ex2_pp0_07(231)                   ,
        sum          => ex2_pp1_2s(231)                   ,
        car          => ex2_pp1_2c(230)                  );
    csa1_2_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(230)                   ,
        b            => ex2_pp0_06(230)                   ,
        c            => ex2_pp0_07(230)                   ,
        sum          => ex2_pp1_2s(230)                   ,
        car          => ex2_pp1_2c(229)                  );
    csa1_2_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(229)                   ,
        b            => ex2_pp0_06(229)                   ,
        c            => ex2_pp0_07(229)                   ,
        sum          => ex2_pp1_2s(229)                   ,
        car          => ex2_pp1_2c(228)                  );
    csa1_2_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(228)                   ,
        b            => ex2_pp0_06(228)                   ,
        c            => ex2_pp0_07(228)                   ,
        sum          => ex2_pp1_2s(228)                   ,
        car          => ex2_pp1_2c(227)                  );
    csa1_2_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(227)                   ,
        b            => ex2_pp0_06(227)                   ,
        c            => ex2_pp0_07(227)                   ,
        sum          => ex2_pp1_2s(227)                   ,
        car          => ex2_pp1_2c(226)                  );
    csa1_2_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(226)                   ,
        b            => ex2_pp0_06(226)                   ,
        c            => ex2_pp0_07(226)                   ,
        sum          => ex2_pp1_2s(226)                   ,
        car          => ex2_pp1_2c(225)                  );
    csa1_2_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(225)                   ,
        b            => ex2_pp0_06(225)                   ,
        c            => ex2_pp0_07(225)                   ,
        sum          => ex2_pp1_2s(225)                   ,
        car          => ex2_pp1_2c(224)                  );
    csa1_2_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(224)                   ,
        b            => ex2_pp0_06(224)                   ,
        c            => ex2_pp0_07(224)                   ,
        sum          => ex2_pp1_2s(224)                   ,
        car          => ex2_pp1_2c(223)                  );
    csa1_2_223: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(223)                   ,
        b            => ex2_pp0_06(223)                   ,
        c            => ex2_pp0_07(223)                   ,
        sum          => ex2_pp1_2s(223)                   ,
        car          => ex2_pp1_2c(222)                  );
    csa1_2_222: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(222)                   ,
        b            => ex2_pp0_06(222)                   ,
        c            => ex2_pp0_07(222)                   ,
        sum          => ex2_pp1_2s(222)                   ,
        car          => ex2_pp1_2c(221)                  );
    csa1_2_221: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(221)                   ,
        b            => ex2_pp0_06(221)                   ,
        c            => ex2_pp0_07(221)                   ,
        sum          => ex2_pp1_2s(221)                   ,
        car          => ex2_pp1_2c(220)                  );
    csa1_2_220: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(220)                   ,
        b            => ex2_pp0_06(220)                   ,
        c            => ex2_pp0_07(220)                   ,
        sum          => ex2_pp1_2s(220)                   ,
        car          => ex2_pp1_2c(219)                  );
    csa1_2_219: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(219)                   ,
        b            => ex2_pp0_06(219)                   ,
        c            => ex2_pp0_07(219)                   ,
        sum          => ex2_pp1_2s(219)                   ,
        car          => ex2_pp1_2c(218)                  );
    csa1_2_218: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(218)                   ,
        b            => ex2_pp0_06(218)                   ,
        c            => ex2_pp0_07(218)                   ,
        sum          => ex2_pp1_2s(218)                   ,
        car          => ex2_pp1_2c(217)                  );
    csa1_2_217: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(217)                   ,
        b            => ex2_pp0_06(217)                   ,
        c            => ex2_pp0_07(217)                   ,
        sum          => ex2_pp1_2s(217)                   ,
        car          => ex2_pp1_2c(216)                  );
    csa1_2_216: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(216)                   ,
        b            => ex2_pp0_06(216)                   ,
        c            => ex2_pp0_07(216)                   ,
        sum          => ex2_pp1_2s(216)                   ,
        car          => ex2_pp1_2c(215)                  );
    csa1_2_215: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(215)                   ,
        b            => ex2_pp0_06(215)                   ,
        c            => ex2_pp0_07(215)                   ,
        sum          => ex2_pp1_2s(215)                   ,
        car          => ex2_pp1_2c(214)                  );
    csa1_2_214: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(214)                   ,
        b            => ex2_pp0_06(214)                   ,
        c            => ex2_pp0_07(214)                   ,
        sum          => ex2_pp1_2s(214)                   ,
        car          => ex2_pp1_2c(213)                  );
    csa1_2_213: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(213)                   ,
        b            => ex2_pp0_06(213)                   ,
        c            => ex2_pp0_07(213)                   ,
        sum          => ex2_pp1_2s(213)                   ,
        car          => ex2_pp1_2c(212)                  );
    csa1_2_212: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_05(212)                   ,
        b            => ex2_pp0_06(212)                   ,
        c            => ex2_pp0_07(212)                   ,
        sum          => ex2_pp1_2s(212)                   ,
        car          => ex2_pp1_2c(211)                  );
    csa1_2_211: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_05(211)                   ,
        b            => ex2_pp0_06(211)                   ,
        sum          => ex2_pp1_2s(211)                   ,
        car          => ex2_pp1_2c(210)                  );
    csa1_2_210: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_05(210)                   ,
        b            => ex2_pp0_06(210)                   ,
        sum          => ex2_pp1_2s(210)                   ,
        car          => ex2_pp1_2c(209)                  );
 ex2_pp1_2s(209)                  <= ex2_pp0_05(209)                  ; 
 ex2_pp1_2s(208)                  <= ex2_pp0_05(208)                  ; 





 ex2_pp1_3s(254)                  <= ex2_pp0_10(254)                  ; 
 ex2_pp1_3s(253)                  <= tidn                             ; 
 ex2_pp1_3c(252)                  <= ex2_pp0_10(252)                  ; 
 ex2_pp1_3s(252)                  <= ex2_pp0_09(252)                  ; 
 ex2_pp1_3c(251)                  <= tidn                            ; 
 ex2_pp1_3s(251)                  <= ex2_pp0_10(251)                  ; 
 ex2_pp1_3c(250)                  <= tidn                             ; 
    csa1_3_250: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(250)                   ,
        b            => ex2_pp0_09(250)                   ,
        c            => ex2_pp0_10(250)                   ,
        sum          => ex2_pp1_3s(250)                   ,
        car          => ex2_pp1_3c(249)                  );
    csa1_3_249: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_09(249)                   ,
        b            => ex2_pp0_10(249)                   ,
        sum          => ex2_pp1_3s(249)                   ,
        car          => ex2_pp1_3c(248)                  );
    csa1_3_248: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(248)                   ,
        b            => ex2_pp0_09(248)                   ,
        c            => ex2_pp0_10(248)                   ,
        sum          => ex2_pp1_3s(248)                   ,
        car          => ex2_pp1_3c(247)                  );
    csa1_3_247: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(247)                   ,
        b            => ex2_pp0_09(247)                   ,
        c            => ex2_pp0_10(247)                   ,
        sum          => ex2_pp1_3s(247)                   ,
        car          => ex2_pp1_3c(246)                  );
    csa1_3_246: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(246)                   ,
        b            => ex2_pp0_09(246)                   ,
        c            => ex2_pp0_10(246)                   ,
        sum          => ex2_pp1_3s(246)                   ,
        car          => ex2_pp1_3c(245)                  );
    csa1_3_245: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(245)                   ,
        b            => ex2_pp0_09(245)                   ,
        c            => ex2_pp0_10(245)                   ,
        sum          => ex2_pp1_3s(245)                   ,
        car          => ex2_pp1_3c(244)                  );
    csa1_3_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(244)                   ,
        b            => ex2_pp0_09(244)                   ,
        c            => ex2_pp0_10(244)                   ,
        sum          => ex2_pp1_3s(244)                   ,
        car          => ex2_pp1_3c(243)                  );
    csa1_3_243: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(243)                   ,
        b            => ex2_pp0_09(243)                   ,
        c            => ex2_pp0_10(243)                   ,
        sum          => ex2_pp1_3s(243)                   ,
        car          => ex2_pp1_3c(242)                  );
    csa1_3_242: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(242)                   ,
        b            => ex2_pp0_09(242)                   ,
        c            => ex2_pp0_10(242)                   ,
        sum          => ex2_pp1_3s(242)                   ,
        car          => ex2_pp1_3c(241)                  );
    csa1_3_241: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(241)                   ,
        b            => ex2_pp0_09(241)                   ,
        c            => ex2_pp0_10(241)                   ,
        sum          => ex2_pp1_3s(241)                   ,
        car          => ex2_pp1_3c(240)                  );
    csa1_3_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(240)                   ,
        b            => ex2_pp0_09(240)                   ,
        c            => ex2_pp0_10(240)                   ,
        sum          => ex2_pp1_3s(240)                   ,
        car          => ex2_pp1_3c(239)                  );
    csa1_3_239: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(239)                   ,
        b            => ex2_pp0_09(239)                   ,
        c            => ex2_pp0_10(239)                   ,
        sum          => ex2_pp1_3s(239)                   ,
        car          => ex2_pp1_3c(238)                  );
    csa1_3_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(238)                   ,
        b            => ex2_pp0_09(238)                   ,
        c            => ex2_pp0_10(238)                   ,
        sum          => ex2_pp1_3s(238)                   ,
        car          => ex2_pp1_3c(237)                  );
    csa1_3_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(237)                   ,
        b            => ex2_pp0_09(237)                   ,
        c            => ex2_pp0_10(237)                   ,
        sum          => ex2_pp1_3s(237)                   ,
        car          => ex2_pp1_3c(236)                  );
    csa1_3_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(236)                   ,
        b            => ex2_pp0_09(236)                   ,
        c            => ex2_pp0_10(236)                   ,
        sum          => ex2_pp1_3s(236)                   ,
        car          => ex2_pp1_3c(235)                  );
    csa1_3_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(235)                   ,
        b            => ex2_pp0_09(235)                   ,
        c            => ex2_pp0_10(235)                   ,
        sum          => ex2_pp1_3s(235)                   ,
        car          => ex2_pp1_3c(234)                  );
    csa1_3_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(234)                   ,
        b            => ex2_pp0_09(234)                   ,
        c            => ex2_pp0_10(234)                   ,
        sum          => ex2_pp1_3s(234)                   ,
        car          => ex2_pp1_3c(233)                  );
    csa1_3_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(233)                   ,
        b            => ex2_pp0_09(233)                   ,
        c            => ex2_pp0_10(233)                   ,
        sum          => ex2_pp1_3s(233)                   ,
        car          => ex2_pp1_3c(232)                  );
    csa1_3_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(232)                   ,
        b            => ex2_pp0_09(232)                   ,
        c            => ex2_pp0_10(232)                   ,
        sum          => ex2_pp1_3s(232)                   ,
        car          => ex2_pp1_3c(231)                  );
    csa1_3_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(231)                   ,
        b            => ex2_pp0_09(231)                   ,
        c            => ex2_pp0_10(231)                   ,
        sum          => ex2_pp1_3s(231)                   ,
        car          => ex2_pp1_3c(230)                  );
    csa1_3_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(230)                   ,
        b            => ex2_pp0_09(230)                   ,
        c            => ex2_pp0_10(230)                   ,
        sum          => ex2_pp1_3s(230)                   ,
        car          => ex2_pp1_3c(229)                  );
    csa1_3_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(229)                   ,
        b            => ex2_pp0_09(229)                   ,
        c            => ex2_pp0_10(229)                   ,
        sum          => ex2_pp1_3s(229)                   ,
        car          => ex2_pp1_3c(228)                  );
    csa1_3_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(228)                   ,
        b            => ex2_pp0_09(228)                   ,
        c            => ex2_pp0_10(228)                   ,
        sum          => ex2_pp1_3s(228)                   ,
        car          => ex2_pp1_3c(227)                  );
    csa1_3_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(227)                   ,
        b            => ex2_pp0_09(227)                   ,
        c            => ex2_pp0_10(227)                   ,
        sum          => ex2_pp1_3s(227)                   ,
        car          => ex2_pp1_3c(226)                  );
    csa1_3_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(226)                   ,
        b            => ex2_pp0_09(226)                   ,
        c            => ex2_pp0_10(226)                   ,
        sum          => ex2_pp1_3s(226)                   ,
        car          => ex2_pp1_3c(225)                  );
    csa1_3_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(225)                   ,
        b            => ex2_pp0_09(225)                   ,
        c            => ex2_pp0_10(225)                   ,
        sum          => ex2_pp1_3s(225)                   ,
        car          => ex2_pp1_3c(224)                  );
    csa1_3_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(224)                   ,
        b            => ex2_pp0_09(224)                   ,
        c            => ex2_pp0_10(224)                   ,
        sum          => ex2_pp1_3s(224)                   ,
        car          => ex2_pp1_3c(223)                  );
    csa1_3_223: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(223)                   ,
        b            => ex2_pp0_09(223)                   ,
        c            => ex2_pp0_10(223)                   ,
        sum          => ex2_pp1_3s(223)                   ,
        car          => ex2_pp1_3c(222)                  );
    csa1_3_222: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(222)                   ,
        b            => ex2_pp0_09(222)                   ,
        c            => ex2_pp0_10(222)                   ,
        sum          => ex2_pp1_3s(222)                   ,
        car          => ex2_pp1_3c(221)                  );
    csa1_3_221: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(221)                   ,
        b            => ex2_pp0_09(221)                   ,
        c            => ex2_pp0_10(221)                   ,
        sum          => ex2_pp1_3s(221)                   ,
        car          => ex2_pp1_3c(220)                  );
    csa1_3_220: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(220)                   ,
        b            => ex2_pp0_09(220)                   ,
        c            => ex2_pp0_10(220)                   ,
        sum          => ex2_pp1_3s(220)                   ,
        car          => ex2_pp1_3c(219)                  );
    csa1_3_219: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(219)                   ,
        b            => ex2_pp0_09(219)                   ,
        c            => ex2_pp0_10(219)                   ,
        sum          => ex2_pp1_3s(219)                   ,
        car          => ex2_pp1_3c(218)                  );
    csa1_3_218: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_08(218)                   ,
        b            => ex2_pp0_09(218)                   ,
        c            => ex2_pp0_10(218)                   ,
        sum          => ex2_pp1_3s(218)                   ,
        car          => ex2_pp1_3c(217)                  );
    csa1_3_217: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_08(217)                   ,
        b            => ex2_pp0_09(217)                   ,
        sum          => ex2_pp1_3s(217)                   ,
        car          => ex2_pp1_3c(216)                  );
    csa1_3_216: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_08(216)                   ,
        b            => ex2_pp0_09(216)                   ,
        sum          => ex2_pp1_3s(216)                   ,
        car          => ex2_pp1_3c(215)                  );
 ex2_pp1_3s(215)                  <= ex2_pp0_08(215)                  ; 
 ex2_pp1_3s(214)                  <= ex2_pp0_08(214)                  ; 




 ex2_pp1_4s(260)                  <= ex2_pp0_13(260)                  ; 
 ex2_pp1_4s(259)                  <= tidn                             ; 
 ex2_pp1_4c(258)                  <= ex2_pp0_13(258)                  ; 
 ex2_pp1_4s(258)                  <= ex2_pp0_12(258)                  ; 
 ex2_pp1_4c(257)                  <= tidn                            ; 
 ex2_pp1_4s(257)                  <= ex2_pp0_13(257)                  ; 
 ex2_pp1_4c(256)                  <= tidn                             ; 
    csa1_4_256: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(256)                   ,
        b            => ex2_pp0_12(256)                   ,
        c            => ex2_pp0_13(256)                   ,
        sum          => ex2_pp1_4s(256)                   ,
        car          => ex2_pp1_4c(255)                  );
    csa1_4_255: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_12(255)                   ,
        b            => ex2_pp0_13(255)                   ,
        sum          => ex2_pp1_4s(255)                   ,
        car          => ex2_pp1_4c(254)                  );
    csa1_4_254: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(254)                   ,
        b            => ex2_pp0_12(254)                   ,
        c            => ex2_pp0_13(254)                   ,
        sum          => ex2_pp1_4s(254)                   ,
        car          => ex2_pp1_4c(253)                  );
    csa1_4_253: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(253)                   ,
        b            => ex2_pp0_12(253)                   ,
        c            => ex2_pp0_13(253)                   ,
        sum          => ex2_pp1_4s(253)                   ,
        car          => ex2_pp1_4c(252)                  );
    csa1_4_252: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(252)                   ,
        b            => ex2_pp0_12(252)                   ,
        c            => ex2_pp0_13(252)                   ,
        sum          => ex2_pp1_4s(252)                   ,
        car          => ex2_pp1_4c(251)                  );
    csa1_4_251: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(251)                   ,
        b            => ex2_pp0_12(251)                   ,
        c            => ex2_pp0_13(251)                   ,
        sum          => ex2_pp1_4s(251)                   ,
        car          => ex2_pp1_4c(250)                  );
    csa1_4_250: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(250)                   ,
        b            => ex2_pp0_12(250)                   ,
        c            => ex2_pp0_13(250)                   ,
        sum          => ex2_pp1_4s(250)                   ,
        car          => ex2_pp1_4c(249)                  );
    csa1_4_249: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(249)                   ,
        b            => ex2_pp0_12(249)                   ,
        c            => ex2_pp0_13(249)                   ,
        sum          => ex2_pp1_4s(249)                   ,
        car          => ex2_pp1_4c(248)                  );
    csa1_4_248: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(248)                   ,
        b            => ex2_pp0_12(248)                   ,
        c            => ex2_pp0_13(248)                   ,
        sum          => ex2_pp1_4s(248)                   ,
        car          => ex2_pp1_4c(247)                  );
    csa1_4_247: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(247)                   ,
        b            => ex2_pp0_12(247)                   ,
        c            => ex2_pp0_13(247)                   ,
        sum          => ex2_pp1_4s(247)                   ,
        car          => ex2_pp1_4c(246)                  );
    csa1_4_246: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(246)                   ,
        b            => ex2_pp0_12(246)                   ,
        c            => ex2_pp0_13(246)                   ,
        sum          => ex2_pp1_4s(246)                   ,
        car          => ex2_pp1_4c(245)                  );
    csa1_4_245: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(245)                   ,
        b            => ex2_pp0_12(245)                   ,
        c            => ex2_pp0_13(245)                   ,
        sum          => ex2_pp1_4s(245)                   ,
        car          => ex2_pp1_4c(244)                  );
    csa1_4_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(244)                   ,
        b            => ex2_pp0_12(244)                   ,
        c            => ex2_pp0_13(244)                   ,
        sum          => ex2_pp1_4s(244)                   ,
        car          => ex2_pp1_4c(243)                  );
    csa1_4_243: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(243)                   ,
        b            => ex2_pp0_12(243)                   ,
        c            => ex2_pp0_13(243)                   ,
        sum          => ex2_pp1_4s(243)                   ,
        car          => ex2_pp1_4c(242)                  );
    csa1_4_242: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(242)                   ,
        b            => ex2_pp0_12(242)                   ,
        c            => ex2_pp0_13(242)                   ,
        sum          => ex2_pp1_4s(242)                   ,
        car          => ex2_pp1_4c(241)                  );
    csa1_4_241: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(241)                   ,
        b            => ex2_pp0_12(241)                   ,
        c            => ex2_pp0_13(241)                   ,
        sum          => ex2_pp1_4s(241)                   ,
        car          => ex2_pp1_4c(240)                  );
    csa1_4_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(240)                   ,
        b            => ex2_pp0_12(240)                   ,
        c            => ex2_pp0_13(240)                   ,
        sum          => ex2_pp1_4s(240)                   ,
        car          => ex2_pp1_4c(239)                  );
    csa1_4_239: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(239)                   ,
        b            => ex2_pp0_12(239)                   ,
        c            => ex2_pp0_13(239)                   ,
        sum          => ex2_pp1_4s(239)                   ,
        car          => ex2_pp1_4c(238)                  );
    csa1_4_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(238)                   ,
        b            => ex2_pp0_12(238)                   ,
        c            => ex2_pp0_13(238)                   ,
        sum          => ex2_pp1_4s(238)                   ,
        car          => ex2_pp1_4c(237)                  );
    csa1_4_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(237)                   ,
        b            => ex2_pp0_12(237)                   ,
        c            => ex2_pp0_13(237)                   ,
        sum          => ex2_pp1_4s(237)                   ,
        car          => ex2_pp1_4c(236)                  );
    csa1_4_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(236)                   ,
        b            => ex2_pp0_12(236)                   ,
        c            => ex2_pp0_13(236)                   ,
        sum          => ex2_pp1_4s(236)                   ,
        car          => ex2_pp1_4c(235)                  );
    csa1_4_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(235)                   ,
        b            => ex2_pp0_12(235)                   ,
        c            => ex2_pp0_13(235)                   ,
        sum          => ex2_pp1_4s(235)                   ,
        car          => ex2_pp1_4c(234)                  );
    csa1_4_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(234)                   ,
        b            => ex2_pp0_12(234)                   ,
        c            => ex2_pp0_13(234)                   ,
        sum          => ex2_pp1_4s(234)                   ,
        car          => ex2_pp1_4c(233)                  );
    csa1_4_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(233)                   ,
        b            => ex2_pp0_12(233)                   ,
        c            => ex2_pp0_13(233)                   ,
        sum          => ex2_pp1_4s(233)                   ,
        car          => ex2_pp1_4c(232)                  );
    csa1_4_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(232)                   ,
        b            => ex2_pp0_12(232)                   ,
        c            => ex2_pp0_13(232)                   ,
        sum          => ex2_pp1_4s(232)                   ,
        car          => ex2_pp1_4c(231)                  );
    csa1_4_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(231)                   ,
        b            => ex2_pp0_12(231)                   ,
        c            => ex2_pp0_13(231)                   ,
        sum          => ex2_pp1_4s(231)                   ,
        car          => ex2_pp1_4c(230)                  );
    csa1_4_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(230)                   ,
        b            => ex2_pp0_12(230)                   ,
        c            => ex2_pp0_13(230)                   ,
        sum          => ex2_pp1_4s(230)                   ,
        car          => ex2_pp1_4c(229)                  );
    csa1_4_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(229)                   ,
        b            => ex2_pp0_12(229)                   ,
        c            => ex2_pp0_13(229)                   ,
        sum          => ex2_pp1_4s(229)                   ,
        car          => ex2_pp1_4c(228)                  );
    csa1_4_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(228)                   ,
        b            => ex2_pp0_12(228)                   ,
        c            => ex2_pp0_13(228)                   ,
        sum          => ex2_pp1_4s(228)                   ,
        car          => ex2_pp1_4c(227)                  );
    csa1_4_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(227)                   ,
        b            => ex2_pp0_12(227)                   ,
        c            => ex2_pp0_13(227)                   ,
        sum          => ex2_pp1_4s(227)                   ,
        car          => ex2_pp1_4c(226)                  );
    csa1_4_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(226)                   ,
        b            => ex2_pp0_12(226)                   ,
        c            => ex2_pp0_13(226)                   ,
        sum          => ex2_pp1_4s(226)                   ,
        car          => ex2_pp1_4c(225)                  );
    csa1_4_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(225)                   ,
        b            => ex2_pp0_12(225)                   ,
        c            => ex2_pp0_13(225)                   ,
        sum          => ex2_pp1_4s(225)                   ,
        car          => ex2_pp1_4c(224)                  );
    csa1_4_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_11(224)                   ,
        b            => ex2_pp0_12(224)                   ,
        c            => ex2_pp0_13(224)                   ,
        sum          => ex2_pp1_4s(224)                   ,
        car          => ex2_pp1_4c(223)                  );
    csa1_4_223: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_11(223)                   ,
        b            => ex2_pp0_12(223)                   ,
        sum          => ex2_pp1_4s(223)                   ,
        car          => ex2_pp1_4c(222)                  );
    csa1_4_222: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_11(222)                   ,
        b            => ex2_pp0_12(222)                   ,
        sum          => ex2_pp1_4s(222)                   ,
        car          => ex2_pp1_4c(221)                  );
 ex2_pp1_4s(221)                  <= ex2_pp0_11(221)                  ; 
 ex2_pp1_4s(220)                  <= ex2_pp0_11(220)                  ; 



 ex2_pp1_5c(264)                  <= ex2_pp0_16(264)                  ; 
 ex2_pp1_5s(264)                  <= ex2_pp0_15(264)                  ; 
 ex2_pp1_5c(263)                  <= tidn                            ; 
 ex2_pp1_5s(263)                  <= ex2_pp0_16(263)                  ; 
 ex2_pp1_5c(262)                  <= tidn                             ; 
    csa1_5_262: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(262)                   ,
        b            => ex2_pp0_15(262)                   ,
        c            => ex2_pp0_16(262)                   ,
        sum          => ex2_pp1_5s(262)                   ,
        car          => ex2_pp1_5c(261)                  );
    csa1_5_261: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_15(261)                   ,
        b            => ex2_pp0_16(261)                   ,
        sum          => ex2_pp1_5s(261)                   ,
        car          => ex2_pp1_5c(260)                  );
    csa1_5_260: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(260)                   ,
        b            => ex2_pp0_15(260)                   ,
        c            => ex2_pp0_16(260)                   ,
        sum          => ex2_pp1_5s(260)                   ,
        car          => ex2_pp1_5c(259)                  );
    csa1_5_259: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(259)                   ,
        b            => ex2_pp0_15(259)                   ,
        c            => ex2_pp0_16(259)                   ,
        sum          => ex2_pp1_5s(259)                   ,
        car          => ex2_pp1_5c(258)                  );
    csa1_5_258: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(258)                   ,
        b            => ex2_pp0_15(258)                   ,
        c            => ex2_pp0_16(258)                   ,
        sum          => ex2_pp1_5s(258)                   ,
        car          => ex2_pp1_5c(257)                  );
    csa1_5_257: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(257)                   ,
        b            => ex2_pp0_15(257)                   ,
        c            => ex2_pp0_16(257)                   ,
        sum          => ex2_pp1_5s(257)                   ,
        car          => ex2_pp1_5c(256)                  );
    csa1_5_256: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(256)                   ,
        b            => ex2_pp0_15(256)                   ,
        c            => ex2_pp0_16(256)                   ,
        sum          => ex2_pp1_5s(256)                   ,
        car          => ex2_pp1_5c(255)                  );
    csa1_5_255: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(255)                   ,
        b            => ex2_pp0_15(255)                   ,
        c            => ex2_pp0_16(255)                   ,
        sum          => ex2_pp1_5s(255)                   ,
        car          => ex2_pp1_5c(254)                  );
    csa1_5_254: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(254)                   ,
        b            => ex2_pp0_15(254)                   ,
        c            => ex2_pp0_16(254)                   ,
        sum          => ex2_pp1_5s(254)                   ,
        car          => ex2_pp1_5c(253)                  );
    csa1_5_253: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(253)                   ,
        b            => ex2_pp0_15(253)                   ,
        c            => ex2_pp0_16(253)                   ,
        sum          => ex2_pp1_5s(253)                   ,
        car          => ex2_pp1_5c(252)                  );
    csa1_5_252: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(252)                   ,
        b            => ex2_pp0_15(252)                   ,
        c            => ex2_pp0_16(252)                   ,
        sum          => ex2_pp1_5s(252)                   ,
        car          => ex2_pp1_5c(251)                  );
    csa1_5_251: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(251)                   ,
        b            => ex2_pp0_15(251)                   ,
        c            => ex2_pp0_16(251)                   ,
        sum          => ex2_pp1_5s(251)                   ,
        car          => ex2_pp1_5c(250)                  );
    csa1_5_250: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(250)                   ,
        b            => ex2_pp0_15(250)                   ,
        c            => ex2_pp0_16(250)                   ,
        sum          => ex2_pp1_5s(250)                   ,
        car          => ex2_pp1_5c(249)                  );
    csa1_5_249: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(249)                   ,
        b            => ex2_pp0_15(249)                   ,
        c            => ex2_pp0_16(249)                   ,
        sum          => ex2_pp1_5s(249)                   ,
        car          => ex2_pp1_5c(248)                  );
    csa1_5_248: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(248)                   ,
        b            => ex2_pp0_15(248)                   ,
        c            => ex2_pp0_16(248)                   ,
        sum          => ex2_pp1_5s(248)                   ,
        car          => ex2_pp1_5c(247)                  );
    csa1_5_247: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(247)                   ,
        b            => ex2_pp0_15(247)                   ,
        c            => ex2_pp0_16(247)                   ,
        sum          => ex2_pp1_5s(247)                   ,
        car          => ex2_pp1_5c(246)                  );
    csa1_5_246: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(246)                   ,
        b            => ex2_pp0_15(246)                   ,
        c            => ex2_pp0_16(246)                   ,
        sum          => ex2_pp1_5s(246)                   ,
        car          => ex2_pp1_5c(245)                  );
    csa1_5_245: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(245)                   ,
        b            => ex2_pp0_15(245)                   ,
        c            => ex2_pp0_16(245)                   ,
        sum          => ex2_pp1_5s(245)                   ,
        car          => ex2_pp1_5c(244)                  );
    csa1_5_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(244)                   ,
        b            => ex2_pp0_15(244)                   ,
        c            => ex2_pp0_16(244)                   ,
        sum          => ex2_pp1_5s(244)                   ,
        car          => ex2_pp1_5c(243)                  );
    csa1_5_243: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(243)                   ,
        b            => ex2_pp0_15(243)                   ,
        c            => ex2_pp0_16(243)                   ,
        sum          => ex2_pp1_5s(243)                   ,
        car          => ex2_pp1_5c(242)                  );
    csa1_5_242: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(242)                   ,
        b            => ex2_pp0_15(242)                   ,
        c            => ex2_pp0_16(242)                   ,
        sum          => ex2_pp1_5s(242)                   ,
        car          => ex2_pp1_5c(241)                  );
    csa1_5_241: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(241)                   ,
        b            => ex2_pp0_15(241)                   ,
        c            => ex2_pp0_16(241)                   ,
        sum          => ex2_pp1_5s(241)                   ,
        car          => ex2_pp1_5c(240)                  );
    csa1_5_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(240)                   ,
        b            => ex2_pp0_15(240)                   ,
        c            => ex2_pp0_16(240)                   ,
        sum          => ex2_pp1_5s(240)                   ,
        car          => ex2_pp1_5c(239)                  );
    csa1_5_239: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(239)                   ,
        b            => ex2_pp0_15(239)                   ,
        c            => ex2_pp0_16(239)                   ,
        sum          => ex2_pp1_5s(239)                   ,
        car          => ex2_pp1_5c(238)                  );
    csa1_5_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(238)                   ,
        b            => ex2_pp0_15(238)                   ,
        c            => ex2_pp0_16(238)                   ,
        sum          => ex2_pp1_5s(238)                   ,
        car          => ex2_pp1_5c(237)                  );
    csa1_5_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(237)                   ,
        b            => ex2_pp0_15(237)                   ,
        c            => ex2_pp0_16(237)                   ,
        sum          => ex2_pp1_5s(237)                   ,
        car          => ex2_pp1_5c(236)                  );
    csa1_5_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(236)                   ,
        b            => ex2_pp0_15(236)                   ,
        c            => ex2_pp0_16(236)                   ,
        sum          => ex2_pp1_5s(236)                   ,
        car          => ex2_pp1_5c(235)                  );
    csa1_5_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(235)                   ,
        b            => ex2_pp0_15(235)                   ,
        c            => ex2_pp0_16(235)                   ,
        sum          => ex2_pp1_5s(235)                   ,
        car          => ex2_pp1_5c(234)                  );
    csa1_5_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(234)                   ,
        b            => ex2_pp0_15(234)                   ,
        c            => ex2_pp0_16(234)                   ,
        sum          => ex2_pp1_5s(234)                   ,
        car          => ex2_pp1_5c(233)                  );
    csa1_5_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(233)                   ,
        b            => ex2_pp0_15(233)                   ,
        c            => ex2_pp0_16(233)                   ,
        sum          => ex2_pp1_5s(233)                   ,
        car          => ex2_pp1_5c(232)                  );
    csa1_5_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(232)                   ,
        b            => ex2_pp0_15(232)                   ,
        c            => ex2_pp0_16(232)                   ,
        sum          => ex2_pp1_5s(232)                   ,
        car          => ex2_pp1_5c(231)                  );
    csa1_5_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(231)                   ,
        b            => ex2_pp0_15(231)                   ,
        c            => ex2_pp0_16(231)                   ,
        sum          => ex2_pp1_5s(231)                   ,
        car          => ex2_pp1_5c(230)                  );
    csa1_5_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(230)                   ,
        b            => ex2_pp0_15(230)                   ,
        c            => ex2_pp0_16(230)                   ,
        sum          => ex2_pp1_5s(230)                   ,
        car          => ex2_pp1_5c(229)                  );
    csa1_5_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp0_14(229)                   ,
        b            => ex2_pp0_15(229)                   ,
        c            => ex2_pp0_16(229)                   ,
        sum          => ex2_pp1_5s(229)                   ,
        car          => ex2_pp1_5c(228)                  );
    csa1_5_228: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp0_14(228)                   ,
        b            => ex2_pp0_15(228)                   ,
        sum          => ex2_pp1_5s(228)                   ,
        car          => ex2_pp1_5c(227)                  );
 ex2_pp1_5s(227)                  <= ex2_pp0_14(227)                  ; 
 ex2_pp1_5s(226)                  <= ex2_pp0_14(226)                  ; 








 ex2_pp2_0s(242)                  <= ex2_pp1_1s(242)                  ; 
 ex2_pp2_0s(241)                  <= tidn                             ; 
 ex2_pp2_0c(240)                  <= ex2_pp1_1s(240)                  ; 
 ex2_pp2_0s(240)                  <= ex2_pp1_1c(240)                  ; 
 ex2_pp2_0c(239)                  <= tidn                             ; 
 ex2_pp2_0s(239)                  <= ex2_pp1_1s(239)                  ; 
 ex2_pp2_0c(238)                  <= tidn                             ; 
 ex2_pp2_0s(238)                  <= ex2_pp1_1s(238)                  ; 
 ex2_pp2_0c(237)                  <= ex2_pp1_1s(237)                  ; 
 ex2_pp2_0s(237)                  <= ex2_pp1_1c(237)                  ; 
 ex2_pp2_0c(236)                  <= tidn                             ; 
    csa2_0_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0s(236)                   ,
        b            => ex2_pp1_1c(236)                   ,
        c            => ex2_pp1_1s(236)                   ,
        sum          => ex2_pp2_0s(236)                   ,
        car          => ex2_pp2_0c(235)                  );
    csa2_0_235: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_1c(235)                   ,
        b            => ex2_pp1_1s(235)                   ,
        sum          => ex2_pp2_0s(235)                   ,
        car          => ex2_pp2_0c(234)                  );
 ex2_pp2_0k(234)                  <= tidn                             ; 
    csa2_0_234: entity clib.c_prism_csa42 port map( 
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(234)                   ,
        b            => ex2_pp1_0s(234)                   ,
        c            => ex2_pp1_1c(234)                   ,
        d            => ex2_pp1_1s(234)                   ,
        ki           => ex2_pp2_0k(234)                   ,
        ko           => ex2_pp2_0k(233)                   ,
        sum          => ex2_pp2_0s(234)                   ,
        car          => ex2_pp2_0c(233)                  );
    csa2_0_233: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0s(233)                   ,
        b            => ex2_pp1_1c(233)                   ,
        c            => ex2_pp1_1s(233)                   ,
        d            => tidn                              ,
        ki           => ex2_pp2_0k(233)                   ,
        ko           => ex2_pp2_0k(232)                   ,
        sum          => ex2_pp2_0s(233)                   ,
        car          => ex2_pp2_0c(232)                  );
    csa2_0_232: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0s(232)                   ,
        b            => ex2_pp1_1c(232)                   ,
        c            => ex2_pp1_1s(232)                   ,
        d            => tidn                              ,
        ki           => ex2_pp2_0k(232)                   ,
        ko           => ex2_pp2_0k(231)                   ,
        sum          => ex2_pp2_0s(232)                   ,
        car          => ex2_pp2_0c(231)                  );
    csa2_0_231: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(231)                   ,
        b            => ex2_pp1_0s(231)                   ,
        c            => ex2_pp1_1c(231)                   ,
        d            => ex2_pp1_1s(231)                   ,
        ki           => ex2_pp2_0k(231)                   ,
        ko           => ex2_pp2_0k(230)                   ,
        sum          => ex2_pp2_0s(231)                   ,
        car          => ex2_pp2_0c(230)                  );
    csa2_0_230: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(230)                   ,
        b            => ex2_pp1_0s(230)                   ,
        c            => ex2_pp1_1c(230)                   ,
        d            => ex2_pp1_1s(230)                   ,
        ki           => ex2_pp2_0k(230)                   ,
        ko           => ex2_pp2_0k(229)                   ,
        sum          => ex2_pp2_0s(230)                   ,
        car          => ex2_pp2_0c(229)                  );
    csa2_0_229: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(229)                   ,
        b            => ex2_pp1_0s(229)                   ,
        c            => ex2_pp1_1c(229)                   ,
        d            => ex2_pp1_1s(229)                   ,
        ki           => ex2_pp2_0k(229)                   ,
        ko           => ex2_pp2_0k(228)                   ,
        sum          => ex2_pp2_0s(229)                   ,
        car          => ex2_pp2_0c(228)                  );
    csa2_0_228: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(228)                   ,
        b            => ex2_pp1_0s(228)                   ,
        c            => ex2_pp1_1c(228)                   ,
        d            => ex2_pp1_1s(228)                   ,
        ki           => ex2_pp2_0k(228)                   ,
        ko           => ex2_pp2_0k(227)                   ,
        sum          => ex2_pp2_0s(228)                   ,
        car          => ex2_pp2_0c(227)                  );
    csa2_0_227: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(227)                   ,
        b            => ex2_pp1_0s(227)                   ,
        c            => ex2_pp1_1c(227)                   ,
        d            => ex2_pp1_1s(227)                   ,
        ki           => ex2_pp2_0k(227)                   ,
        ko           => ex2_pp2_0k(226)                   ,
        sum          => ex2_pp2_0s(227)                   ,
        car          => ex2_pp2_0c(226)                  );
    csa2_0_226: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(226)                   ,
        b            => ex2_pp1_0s(226)                   ,
        c            => ex2_pp1_1c(226)                   ,
        d            => ex2_pp1_1s(226)                   ,
        ki           => ex2_pp2_0k(226)                   ,
        ko           => ex2_pp2_0k(225)                   ,
        sum          => ex2_pp2_0s(226)                   ,
        car          => ex2_pp2_0c(225)                  );
    csa2_0_225: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(225)                   ,
        b            => ex2_pp1_0s(225)                   ,
        c            => ex2_pp1_1c(225)                   ,
        d            => ex2_pp1_1s(225)                   ,
        ki           => ex2_pp2_0k(225)                   ,
        ko           => ex2_pp2_0k(224)                   ,
        sum          => ex2_pp2_0s(225)                   ,
        car          => ex2_pp2_0c(224)                  );
    csa2_0_224: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(224)                   ,
        b            => ex2_pp1_0s(224)                   ,
        c            => ex2_pp1_1c(224)                   ,
        d            => ex2_pp1_1s(224)                   ,
        ki           => ex2_pp2_0k(224)                   ,
        ko           => ex2_pp2_0k(223)                   ,
        sum          => ex2_pp2_0s(224)                   ,
        car          => ex2_pp2_0c(223)                  );
    csa2_0_223: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(223)                   ,
        b            => ex2_pp1_0s(223)                   ,
        c            => ex2_pp1_1c(223)                   ,
        d            => ex2_pp1_1s(223)                   ,
        ki           => ex2_pp2_0k(223)                   ,
        ko           => ex2_pp2_0k(222)                   ,
        sum          => ex2_pp2_0s(223)                   ,
        car          => ex2_pp2_0c(222)                  );
    csa2_0_222: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(222)                   ,
        b            => ex2_pp1_0s(222)                   ,
        c            => ex2_pp1_1c(222)                   ,
        d            => ex2_pp1_1s(222)                   ,
        ki           => ex2_pp2_0k(222)                   ,
        ko           => ex2_pp2_0k(221)                   ,
        sum          => ex2_pp2_0s(222)                   ,
        car          => ex2_pp2_0c(221)                  );
    csa2_0_221: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(221)                   ,
        b            => ex2_pp1_0s(221)                   ,
        c            => ex2_pp1_1c(221)                   ,
        d            => ex2_pp1_1s(221)                   ,
        ki           => ex2_pp2_0k(221)                   ,
        ko           => ex2_pp2_0k(220)                   ,
        sum          => ex2_pp2_0s(221)                   ,
        car          => ex2_pp2_0c(220)                  );
    csa2_0_220: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(220)                   ,
        b            => ex2_pp1_0s(220)                   ,
        c            => ex2_pp1_1c(220)                   ,
        d            => ex2_pp1_1s(220)                   ,
        ki           => ex2_pp2_0k(220)                   ,
        ko           => ex2_pp2_0k(219)                   ,
        sum          => ex2_pp2_0s(220)                   ,
        car          => ex2_pp2_0c(219)                  );
    csa2_0_219: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(219)                   ,
        b            => ex2_pp1_0s(219)                   ,
        c            => ex2_pp1_1c(219)                   ,
        d            => ex2_pp1_1s(219)                   ,
        ki           => ex2_pp2_0k(219)                   ,
        ko           => ex2_pp2_0k(218)                   ,
        sum          => ex2_pp2_0s(219)                   ,
        car          => ex2_pp2_0c(218)                  );
    csa2_0_218: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(218)                   ,
        b            => ex2_pp1_0s(218)                   ,
        c            => ex2_pp1_1c(218)                   ,
        d            => ex2_pp1_1s(218)                   ,
        ki           => ex2_pp2_0k(218)                   ,
        ko           => ex2_pp2_0k(217)                   ,
        sum          => ex2_pp2_0s(218)                   ,
        car          => ex2_pp2_0c(217)                  );
    csa2_0_217: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(217)                   ,
        b            => ex2_pp1_0s(217)                   ,
        c            => ex2_pp1_1c(217)                   ,
        d            => ex2_pp1_1s(217)                   ,
        ki           => ex2_pp2_0k(217)                   ,
        ko           => ex2_pp2_0k(216)                   ,
        sum          => ex2_pp2_0s(217)                   ,
        car          => ex2_pp2_0c(216)                  );
    csa2_0_216: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(216)                   ,
        b            => ex2_pp1_0s(216)                   ,
        c            => ex2_pp1_1c(216)                   ,
        d            => ex2_pp1_1s(216)                   ,
        ki           => ex2_pp2_0k(216)                   ,
        ko           => ex2_pp2_0k(215)                   ,
        sum          => ex2_pp2_0s(216)                   ,
        car          => ex2_pp2_0c(215)                  );
    csa2_0_215: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(215)                   ,
        b            => ex2_pp1_0s(215)                   ,
        c            => ex2_pp1_1c(215)                   ,
        d            => ex2_pp1_1s(215)                   ,
        ki           => ex2_pp2_0k(215)                   ,
        ko           => ex2_pp2_0k(214)                   ,
        sum          => ex2_pp2_0s(215)                   ,
        car          => ex2_pp2_0c(214)                  );
    csa2_0_214: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(214)                   ,
        b            => ex2_pp1_0s(214)                   ,
        c            => ex2_pp1_1c(214)                   ,
        d            => ex2_pp1_1s(214)                   ,
        ki           => ex2_pp2_0k(214)                   ,
        ko           => ex2_pp2_0k(213)                   ,
        sum          => ex2_pp2_0s(214)                   ,
        car          => ex2_pp2_0c(213)                  );
    csa2_0_213: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(213)                   ,
        b            => ex2_pp1_0s(213)                   ,
        c            => ex2_pp1_1c(213)                   ,
        d            => ex2_pp1_1s(213)                   ,
        ki           => ex2_pp2_0k(213)                   ,
        ko           => ex2_pp2_0k(212)                   ,
        sum          => ex2_pp2_0s(213)                   ,
        car          => ex2_pp2_0c(212)                  );
    csa2_0_212: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(212)                   ,
        b            => ex2_pp1_0s(212)                   ,
        c            => ex2_pp1_1c(212)                   ,
        d            => ex2_pp1_1s(212)                   ,
        ki           => ex2_pp2_0k(212)                   ,
        ko           => ex2_pp2_0k(211)                   ,
        sum          => ex2_pp2_0s(212)                   ,
        car          => ex2_pp2_0c(211)                  );
    csa2_0_211: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(211)                   ,
        b            => ex2_pp1_0s(211)                   ,
        c            => ex2_pp1_1c(211)                   ,
        d            => ex2_pp1_1s(211)                   ,
        ki           => ex2_pp2_0k(211)                   ,
        ko           => ex2_pp2_0k(210)                   ,
        sum          => ex2_pp2_0s(211)                   ,
        car          => ex2_pp2_0c(210)                  );
    csa2_0_210: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(210)                   ,
        b            => ex2_pp1_0s(210)                   ,
        c            => ex2_pp1_1c(210)                   ,
        d            => ex2_pp1_1s(210)                   ,
        ki           => ex2_pp2_0k(210)                   ,
        ko           => ex2_pp2_0k(209)                   ,
        sum          => ex2_pp2_0s(210)                   ,
        car          => ex2_pp2_0c(209)                  );
    csa2_0_209: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(209)                   ,
        b            => ex2_pp1_0s(209)                   ,
        c            => ex2_pp1_1c(209)                   ,
        d            => ex2_pp1_1s(209)                   ,
        ki           => ex2_pp2_0k(209)                   ,
        ko           => ex2_pp2_0k(208)                   ,
        sum          => ex2_pp2_0s(209)                   ,
        car          => ex2_pp2_0c(208)                  );
    csa2_0_208: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(208)                   ,
        b            => ex2_pp1_0s(208)                   ,
        c            => ex2_pp1_1c(208)                   ,
        d            => ex2_pp1_1s(208)                   ,
        ki           => ex2_pp2_0k(208)                   ,
        ko           => ex2_pp2_0k(207)                   ,
        sum          => ex2_pp2_0s(208)                   ,
        car          => ex2_pp2_0c(207)                  );
    csa2_0_207: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(207)                   ,
        b            => ex2_pp1_0s(207)                   ,
        c            => ex2_pp1_1c(207)                   ,
        d            => ex2_pp1_1s(207)                   ,
        ki           => ex2_pp2_0k(207)                   ,
        ko           => ex2_pp2_0k(206)                   ,
        sum          => ex2_pp2_0s(207)                   ,
        car          => ex2_pp2_0c(206)                  );
    csa2_0_206: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(206)                   ,
        b            => ex2_pp1_0s(206)                   ,
        c            => ex2_pp1_1c(206)                   ,
        d            => ex2_pp1_1s(206)                   ,
        ki           => ex2_pp2_0k(206)                   ,
        ko           => ex2_pp2_0k(205)                   ,
        sum          => ex2_pp2_0s(206)                   ,
        car          => ex2_pp2_0c(205)                  );
    csa2_0_205: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(205)                   ,
        b            => ex2_pp1_0s(205)                   ,
        c            => ex2_pp1_1c(205)                   ,
        d            => ex2_pp1_1s(205)                   ,
        ki           => ex2_pp2_0k(205)                   ,
        ko           => ex2_pp2_0k(204)                   ,
        sum          => ex2_pp2_0s(205)                   ,
        car          => ex2_pp2_0c(204)                  );
    csa2_0_204: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(204)                   ,
        b            => ex2_pp1_0s(204)                   ,
        c            => ex2_pp1_1c(204)                   ,
        d            => ex2_pp1_1s(204)                   ,
        ki           => ex2_pp2_0k(204)                   ,
        ko           => ex2_pp2_0k(203)                   ,
        sum          => ex2_pp2_0s(204)                   ,
        car          => ex2_pp2_0c(203)                  );
    csa2_0_203: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(203)                   ,
        b            => ex2_pp1_0s(203)                   ,
        c            => ex2_pp1_1c(203)                   ,
        d            => ex2_pp1_1s(203)                   ,
        ki           => ex2_pp2_0k(203)                   ,
        ko           => ex2_pp2_0k(202)                   ,
        sum          => ex2_pp2_0s(203)                   ,
        car          => ex2_pp2_0c(202)                  );
    csa2_0_202: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(202)                   ,
        b            => ex2_pp1_0s(202)                   ,
        c            => ex2_pp1_1s(202)                   ,
        d            => tidn                              ,
        ki           => ex2_pp2_0k(202)                   ,
        ko           => ex2_pp2_0k(201)                   ,
        sum          => ex2_pp2_0s(202)                   ,
        car          => ex2_pp2_0c(201)                  );
    csa2_0_201: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_0c(201)                   ,
        b            => ex2_pp1_0s(201)                   ,
        c            => ex2_pp2_0k(201)                   ,
        sum          => ex2_pp2_0s(201)                   ,
        car          => ex2_pp2_0c(200)                  );
    csa2_0_200: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_0c(200)                   ,
        b            => ex2_pp1_0s(200)                   ,
        sum          => ex2_pp2_0s(200)                   ,
        car          => ex2_pp2_0c(199)                  );
    csa2_0_199: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_0c(199)                   ,
        b            => ex2_pp1_0s(199)                   ,
        sum          => ex2_pp2_0s(199)                   ,
        car          => ex2_pp2_0c(198)                  );
 ex2_pp2_0s(198)                  <= ex2_pp1_0s(198)                  ; 



 ex2_pp2_1s(254)                  <= ex2_pp1_3s(254)                  ; 
 ex2_pp2_1s(253)                  <= tidn                             ; 
 ex2_pp2_1c(252)                  <= ex2_pp1_3s(252)                  ; 
 ex2_pp2_1s(252)                  <= ex2_pp1_3c(252)                  ; 
 ex2_pp2_1c(251)                  <= tidn                             ; 
 ex2_pp2_1s(251)                  <= ex2_pp1_3s(251)                  ; 
 ex2_pp2_1c(250)                  <= tidn                             ; 
 ex2_pp2_1s(250)                  <= ex2_pp1_3s(250)                  ; 
 ex2_pp2_1c(249)                  <= ex2_pp1_3s(249)                  ; 
 ex2_pp2_1s(249)                  <= ex2_pp1_3c(249)                  ; 
 ex2_pp2_1c(248)                  <= tidn                             ; 
    csa2_1_248: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2s(248)                   ,
        b            => ex2_pp1_3c(248)                   ,
        c            => ex2_pp1_3s(248)                   ,
        sum          => ex2_pp2_1s(248)                   ,
        car          => ex2_pp2_1c(247)                  );
    csa2_1_247: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_3c(247)                   ,
        b            => ex2_pp1_3s(247)                   ,
        sum          => ex2_pp2_1s(247)                   ,
        car          => ex2_pp2_1c(246)                  );
 ex2_pp2_1k(246)                  <= tidn                             ; 
    csa2_1_246: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(246)                   ,
        b            => ex2_pp1_2s(246)                   ,
        c            => ex2_pp1_3c(246)                   ,
        d            => ex2_pp1_3s(246)                   ,
        ki           => ex2_pp2_1k(246)                   ,
        ko           => ex2_pp2_1k(245)                   ,
        sum          => ex2_pp2_1s(246)                   ,
        car          => ex2_pp2_1c(245)                  );
    csa2_1_245: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2s(245)                   ,
        b            => ex2_pp1_3c(245)                   ,
        c            => ex2_pp1_3s(245)                   ,
        d            => tidn                              ,
        ki           => ex2_pp2_1k(245)                   ,
        ko           => ex2_pp2_1k(244)                   ,
        sum          => ex2_pp2_1s(245)                   ,
        car          => ex2_pp2_1c(244)                  );
    csa2_1_244: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2s(244)                   ,
        b            => ex2_pp1_3c(244)                   ,
        c            => ex2_pp1_3s(244)                   ,
        d            => tidn                              ,
        ki           => ex2_pp2_1k(244)                   ,
        ko           => ex2_pp2_1k(243)                   ,
        sum          => ex2_pp2_1s(244)                   ,
        car          => ex2_pp2_1c(243)                  );
    csa2_1_243: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(243)                   ,
        b            => ex2_pp1_2s(243)                   ,
        c            => ex2_pp1_3c(243)                   ,
        d            => ex2_pp1_3s(243)                   ,
        ki           => ex2_pp2_1k(243)                   ,
        ko           => ex2_pp2_1k(242)                   ,
        sum          => ex2_pp2_1s(243)                   ,
        car          => ex2_pp2_1c(242)                  );
    csa2_1_242: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(242)                   ,
        b            => ex2_pp1_2s(242)                   ,
        c            => ex2_pp1_3c(242)                   ,
        d            => ex2_pp1_3s(242)                   ,
        ki           => ex2_pp2_1k(242)                   ,
        ko           => ex2_pp2_1k(241)                   ,
        sum          => ex2_pp2_1s(242)                   ,
        car          => ex2_pp2_1c(241)                  );
    csa2_1_241: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(241)                   ,
        b            => ex2_pp1_2s(241)                   ,
        c            => ex2_pp1_3c(241)                   ,
        d            => ex2_pp1_3s(241)                   ,
        ki           => ex2_pp2_1k(241)                   ,
        ko           => ex2_pp2_1k(240)                   ,
        sum          => ex2_pp2_1s(241)                   ,
        car          => ex2_pp2_1c(240)                  );
    csa2_1_240: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(240)                   ,
        b            => ex2_pp1_2s(240)                   ,
        c            => ex2_pp1_3c(240)                   ,
        d            => ex2_pp1_3s(240)                   ,
        ki           => ex2_pp2_1k(240)                   ,
        ko           => ex2_pp2_1k(239)                   ,
        sum          => ex2_pp2_1s(240)                   ,
        car          => ex2_pp2_1c(239)                  );
    csa2_1_239: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(239)                   ,
        b            => ex2_pp1_2s(239)                   ,
        c            => ex2_pp1_3c(239)                   ,
        d            => ex2_pp1_3s(239)                   ,
        ki           => ex2_pp2_1k(239)                   ,
        ko           => ex2_pp2_1k(238)                   ,
        sum          => ex2_pp2_1s(239)                   ,
        car          => ex2_pp2_1c(238)                  );
    csa2_1_238: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(238)                   ,
        b            => ex2_pp1_2s(238)                   ,
        c            => ex2_pp1_3c(238)                   ,
        d            => ex2_pp1_3s(238)                   ,
        ki           => ex2_pp2_1k(238)                   ,
        ko           => ex2_pp2_1k(237)                   ,
        sum          => ex2_pp2_1s(238)                   ,
        car          => ex2_pp2_1c(237)                  );
    csa2_1_237: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(237)                   ,
        b            => ex2_pp1_2s(237)                   ,
        c            => ex2_pp1_3c(237)                   ,
        d            => ex2_pp1_3s(237)                   ,
        ki           => ex2_pp2_1k(237)                   ,
        ko           => ex2_pp2_1k(236)                   ,
        sum          => ex2_pp2_1s(237)                   ,
        car          => ex2_pp2_1c(236)                  );
    csa2_1_236: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(236)                   ,
        b            => ex2_pp1_2s(236)                   ,
        c            => ex2_pp1_3c(236)                   ,
        d            => ex2_pp1_3s(236)                   ,
        ki           => ex2_pp2_1k(236)                   ,
        ko           => ex2_pp2_1k(235)                   ,
        sum          => ex2_pp2_1s(236)                   ,
        car          => ex2_pp2_1c(235)                  );
    csa2_1_235: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(235)                   ,
        b            => ex2_pp1_2s(235)                   ,
        c            => ex2_pp1_3c(235)                   ,
        d            => ex2_pp1_3s(235)                   ,
        ki           => ex2_pp2_1k(235)                   ,
        ko           => ex2_pp2_1k(234)                   ,
        sum          => ex2_pp2_1s(235)                   ,
        car          => ex2_pp2_1c(234)                  );
    csa2_1_234: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(234)                   ,
        b            => ex2_pp1_2s(234)                   ,
        c            => ex2_pp1_3c(234)                   ,
        d            => ex2_pp1_3s(234)                   ,
        ki           => ex2_pp2_1k(234)                   ,
        ko           => ex2_pp2_1k(233)                   ,
        sum          => ex2_pp2_1s(234)                   ,
        car          => ex2_pp2_1c(233)                  );
    csa2_1_233: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(233)                   ,
        b            => ex2_pp1_2s(233)                   ,
        c            => ex2_pp1_3c(233)                   ,
        d            => ex2_pp1_3s(233)                   ,
        ki           => ex2_pp2_1k(233)                   ,
        ko           => ex2_pp2_1k(232)                   ,
        sum          => ex2_pp2_1s(233)                   ,
        car          => ex2_pp2_1c(232)                  );
    csa2_1_232: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(232)                   ,
        b            => ex2_pp1_2s(232)                   ,
        c            => ex2_pp1_3c(232)                   ,
        d            => ex2_pp1_3s(232)                   ,
        ki           => ex2_pp2_1k(232)                   ,
        ko           => ex2_pp2_1k(231)                   ,
        sum          => ex2_pp2_1s(232)                   ,
        car          => ex2_pp2_1c(231)                  );
    csa2_1_231: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(231)                   ,
        b            => ex2_pp1_2s(231)                   ,
        c            => ex2_pp1_3c(231)                   ,
        d            => ex2_pp1_3s(231)                   ,
        ki           => ex2_pp2_1k(231)                   ,
        ko           => ex2_pp2_1k(230)                   ,
        sum          => ex2_pp2_1s(231)                   ,
        car          => ex2_pp2_1c(230)                  );
    csa2_1_230: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(230)                   ,
        b            => ex2_pp1_2s(230)                   ,
        c            => ex2_pp1_3c(230)                   ,
        d            => ex2_pp1_3s(230)                   ,
        ki           => ex2_pp2_1k(230)                   ,
        ko           => ex2_pp2_1k(229)                   ,
        sum          => ex2_pp2_1s(230)                   ,
        car          => ex2_pp2_1c(229)                  );
    csa2_1_229: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(229)                   ,
        b            => ex2_pp1_2s(229)                   ,
        c            => ex2_pp1_3c(229)                   ,
        d            => ex2_pp1_3s(229)                   ,
        ki           => ex2_pp2_1k(229)                   ,
        ko           => ex2_pp2_1k(228)                   ,
        sum          => ex2_pp2_1s(229)                   ,
        car          => ex2_pp2_1c(228)                  );
    csa2_1_228: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(228)                   ,
        b            => ex2_pp1_2s(228)                   ,
        c            => ex2_pp1_3c(228)                   ,
        d            => ex2_pp1_3s(228)                   ,
        ki           => ex2_pp2_1k(228)                   ,
        ko           => ex2_pp2_1k(227)                   ,
        sum          => ex2_pp2_1s(228)                   ,
        car          => ex2_pp2_1c(227)                  );
    csa2_1_227: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(227)                   ,
        b            => ex2_pp1_2s(227)                   ,
        c            => ex2_pp1_3c(227)                   ,
        d            => ex2_pp1_3s(227)                   ,
        ki           => ex2_pp2_1k(227)                   ,
        ko           => ex2_pp2_1k(226)                   ,
        sum          => ex2_pp2_1s(227)                   ,
        car          => ex2_pp2_1c(226)                  );
    csa2_1_226: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(226)                   ,
        b            => ex2_pp1_2s(226)                   ,
        c            => ex2_pp1_3c(226)                   ,
        d            => ex2_pp1_3s(226)                   ,
        ki           => ex2_pp2_1k(226)                   ,
        ko           => ex2_pp2_1k(225)                   ,
        sum          => ex2_pp2_1s(226)                   ,
        car          => ex2_pp2_1c(225)                  );
    csa2_1_225: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(225)                   ,
        b            => ex2_pp1_2s(225)                   ,
        c            => ex2_pp1_3c(225)                   ,
        d            => ex2_pp1_3s(225)                   ,
        ki           => ex2_pp2_1k(225)                   ,
        ko           => ex2_pp2_1k(224)                   ,
        sum          => ex2_pp2_1s(225)                   ,
        car          => ex2_pp2_1c(224)                  );
    csa2_1_224: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(224)                   ,
        b            => ex2_pp1_2s(224)                   ,
        c            => ex2_pp1_3c(224)                   ,
        d            => ex2_pp1_3s(224)                   ,
        ki           => ex2_pp2_1k(224)                   ,
        ko           => ex2_pp2_1k(223)                   ,
        sum          => ex2_pp2_1s(224)                   ,
        car          => ex2_pp2_1c(223)                  );
    csa2_1_223: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(223)                   ,
        b            => ex2_pp1_2s(223)                   ,
        c            => ex2_pp1_3c(223)                   ,
        d            => ex2_pp1_3s(223)                   ,
        ki           => ex2_pp2_1k(223)                   ,
        ko           => ex2_pp2_1k(222)                   ,
        sum          => ex2_pp2_1s(223)                   ,
        car          => ex2_pp2_1c(222)                  );
    csa2_1_222: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(222)                   ,
        b            => ex2_pp1_2s(222)                   ,
        c            => ex2_pp1_3c(222)                   ,
        d            => ex2_pp1_3s(222)                   ,
        ki           => ex2_pp2_1k(222)                   ,
        ko           => ex2_pp2_1k(221)                   ,
        sum          => ex2_pp2_1s(222)                   ,
        car          => ex2_pp2_1c(221)                  );
    csa2_1_221: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(221)                   ,
        b            => ex2_pp1_2s(221)                   ,
        c            => ex2_pp1_3c(221)                   ,
        d            => ex2_pp1_3s(221)                   ,
        ki           => ex2_pp2_1k(221)                   ,
        ko           => ex2_pp2_1k(220)                   ,
        sum          => ex2_pp2_1s(221)                   ,
        car          => ex2_pp2_1c(220)                  );
    csa2_1_220: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(220)                   ,
        b            => ex2_pp1_2s(220)                   ,
        c            => ex2_pp1_3c(220)                   ,
        d            => ex2_pp1_3s(220)                   ,
        ki           => ex2_pp2_1k(220)                   ,
        ko           => ex2_pp2_1k(219)                   ,
        sum          => ex2_pp2_1s(220)                   ,
        car          => ex2_pp2_1c(219)                  );
    csa2_1_219: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(219)                   ,
        b            => ex2_pp1_2s(219)                   ,
        c            => ex2_pp1_3c(219)                   ,
        d            => ex2_pp1_3s(219)                   ,
        ki           => ex2_pp2_1k(219)                   ,
        ko           => ex2_pp2_1k(218)                   ,
        sum          => ex2_pp2_1s(219)                   ,
        car          => ex2_pp2_1c(218)                  );
    csa2_1_218: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(218)                   ,
        b            => ex2_pp1_2s(218)                   ,
        c            => ex2_pp1_3c(218)                   ,
        d            => ex2_pp1_3s(218)                   ,
        ki           => ex2_pp2_1k(218)                   ,
        ko           => ex2_pp2_1k(217)                   ,
        sum          => ex2_pp2_1s(218)                   ,
        car          => ex2_pp2_1c(217)                  );
    csa2_1_217: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(217)                   ,
        b            => ex2_pp1_2s(217)                   ,
        c            => ex2_pp1_3c(217)                   ,
        d            => ex2_pp1_3s(217)                   ,
        ki           => ex2_pp2_1k(217)                   ,
        ko           => ex2_pp2_1k(216)                   ,
        sum          => ex2_pp2_1s(217)                   ,
        car          => ex2_pp2_1c(216)                  );
    csa2_1_216: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(216)                   ,
        b            => ex2_pp1_2s(216)                   ,
        c            => ex2_pp1_3c(216)                   ,
        d            => ex2_pp1_3s(216)                   ,
        ki           => ex2_pp2_1k(216)                   ,
        ko           => ex2_pp2_1k(215)                   ,
        sum          => ex2_pp2_1s(216)                   ,
        car          => ex2_pp2_1c(215)                  );
    csa2_1_215: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(215)                   ,
        b            => ex2_pp1_2s(215)                   ,
        c            => ex2_pp1_3c(215)                   ,
        d            => ex2_pp1_3s(215)                   ,
        ki           => ex2_pp2_1k(215)                   ,
        ko           => ex2_pp2_1k(214)                   ,
        sum          => ex2_pp2_1s(215)                   ,
        car          => ex2_pp2_1c(214)                  );
    csa2_1_214: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(214)                   ,
        b            => ex2_pp1_2s(214)                   ,
        c            => ex2_pp1_3s(214)                   ,
        d            => tidn                              ,
        ki           => ex2_pp2_1k(214)                   ,
        ko           => ex2_pp2_1k(213)                   ,
        sum          => ex2_pp2_1s(214)                   ,
        car          => ex2_pp2_1c(213)                  );
    csa2_1_213: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_2c(213)                   ,
        b            => ex2_pp1_2s(213)                   ,
        c            => ex2_pp2_1k(213)                   ,
        sum          => ex2_pp2_1s(213)                   ,
        car          => ex2_pp2_1c(212)                  );
    csa2_1_212: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_2c(212)                   ,
        b            => ex2_pp1_2s(212)                   ,
        sum          => ex2_pp2_1s(212)                   ,
        car          => ex2_pp2_1c(211)                  );
    csa2_1_211: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_2c(211)                   ,
        b            => ex2_pp1_2s(211)                   ,
        sum          => ex2_pp2_1s(211)                   ,
        car          => ex2_pp2_1c(210)                  );
    csa2_1_210: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_2c(210)                   ,
        b            => ex2_pp1_2s(210)                   ,
        sum          => ex2_pp2_1s(210)                   ,
        car          => ex2_pp2_1c(209)                  );
    csa2_1_209: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_2c(209)                   ,
        b            => ex2_pp1_2s(209)                   ,
        sum          => ex2_pp2_1s(209)                   ,
        car          => ex2_pp2_1c(208)                  );
 ex2_pp2_1s(208)                  <= ex2_pp1_2s(208)                  ; 




    csa2_2_264: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_5c(264)                   ,
        b            => ex2_pp1_5s(264)                   ,
        sum          => ex2_pp2_2s(264)                   ,
        car          => ex2_pp2_2c(263)                  );
 ex2_pp2_2s(263)                  <= ex2_pp1_5s(263)                  ; 
 ex2_pp2_2c(262)                  <= tidn                             ; 
 ex2_pp2_2s(262)                  <= ex2_pp1_5s(262)                  ; 
 ex2_pp2_2c(261)                  <= ex2_pp1_5s(261)                  ; 
 ex2_pp2_2s(261)                  <= ex2_pp1_5c(261)                  ; 
 ex2_pp2_2c(260)                  <= tidn                             ; 
    csa2_2_260: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4s(260)                   ,
        b            => ex2_pp1_5c(260)                   ,
        c            => ex2_pp1_5s(260)                   ,
        sum          => ex2_pp2_2s(260)                   ,
        car          => ex2_pp2_2c(259)                  );
    csa2_2_259: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_5c(259)                   ,
        b            => ex2_pp1_5s(259)                   ,
        sum          => ex2_pp2_2s(259)                   ,
        car          => ex2_pp2_2c(258)                  );
 ex2_pp2_2k(258)                  <= tidn                             ; 
    csa2_2_258: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(258)                   ,
        b            => ex2_pp1_4s(258)                   ,
        c            => ex2_pp1_5c(258)                   ,
        d            => ex2_pp1_5s(258)                   ,
        ki           => ex2_pp2_2k(258)                   ,
        ko           => ex2_pp2_2k(257)                   ,
        sum          => ex2_pp2_2s(258)                   ,
        car          => ex2_pp2_2c(257)                  );
    csa2_2_257: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4s(257)                   ,
        b            => ex2_pp1_5c(257)                   ,
        c            => ex2_pp1_5s(257)                   ,
        d            => tidn                              ,
        ki           => ex2_pp2_2k(257)                   ,
        ko           => ex2_pp2_2k(256)                   ,
        sum          => ex2_pp2_2s(257)                   ,
        car          => ex2_pp2_2c(256)                  );
    csa2_2_256: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4s(256)                   ,
        b            => ex2_pp1_5c(256)                   ,
        c            => ex2_pp1_5s(256)                   ,
        d            => tidn                              ,
        ki           => ex2_pp2_2k(256)                   ,
        ko           => ex2_pp2_2k(255)                   ,
        sum          => ex2_pp2_2s(256)                   ,
        car          => ex2_pp2_2c(255)                  );
    csa2_2_255: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(255)                   ,
        b            => ex2_pp1_4s(255)                   ,
        c            => ex2_pp1_5c(255)                   ,
        d            => ex2_pp1_5s(255)                   ,
        ki           => ex2_pp2_2k(255)                   ,
        ko           => ex2_pp2_2k(254)                   ,
        sum          => ex2_pp2_2s(255)                   ,
        car          => ex2_pp2_2c(254)                  );
    csa2_2_254: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(254)                   ,
        b            => ex2_pp1_4s(254)                   ,
        c            => ex2_pp1_5c(254)                   ,
        d            => ex2_pp1_5s(254)                   ,
        ki           => ex2_pp2_2k(254)                   ,
        ko           => ex2_pp2_2k(253)                   ,
        sum          => ex2_pp2_2s(254)                   ,
        car          => ex2_pp2_2c(253)                  );
    csa2_2_253: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(253)                   ,
        b            => ex2_pp1_4s(253)                   ,
        c            => ex2_pp1_5c(253)                   ,
        d            => ex2_pp1_5s(253)                   ,
        ki           => ex2_pp2_2k(253)                   ,
        ko           => ex2_pp2_2k(252)                   ,
        sum          => ex2_pp2_2s(253)                   ,
        car          => ex2_pp2_2c(252)                  );
    csa2_2_252: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(252)                   ,
        b            => ex2_pp1_4s(252)                   ,
        c            => ex2_pp1_5c(252)                   ,
        d            => ex2_pp1_5s(252)                   ,
        ki           => ex2_pp2_2k(252)                   ,
        ko           => ex2_pp2_2k(251)                   ,
        sum          => ex2_pp2_2s(252)                   ,
        car          => ex2_pp2_2c(251)                  );
    csa2_2_251: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(251)                   ,
        b            => ex2_pp1_4s(251)                   ,
        c            => ex2_pp1_5c(251)                   ,
        d            => ex2_pp1_5s(251)                   ,
        ki           => ex2_pp2_2k(251)                   ,
        ko           => ex2_pp2_2k(250)                   ,
        sum          => ex2_pp2_2s(251)                   ,
        car          => ex2_pp2_2c(250)                  );
    csa2_2_250: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(250)                   ,
        b            => ex2_pp1_4s(250)                   ,
        c            => ex2_pp1_5c(250)                   ,
        d            => ex2_pp1_5s(250)                   ,
        ki           => ex2_pp2_2k(250)                   ,
        ko           => ex2_pp2_2k(249)                   ,
        sum          => ex2_pp2_2s(250)                   ,
        car          => ex2_pp2_2c(249)                  );
    csa2_2_249: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(249)                   ,
        b            => ex2_pp1_4s(249)                   ,
        c            => ex2_pp1_5c(249)                   ,
        d            => ex2_pp1_5s(249)                   ,
        ki           => ex2_pp2_2k(249)                   ,
        ko           => ex2_pp2_2k(248)                   ,
        sum          => ex2_pp2_2s(249)                   ,
        car          => ex2_pp2_2c(248)                  );
    csa2_2_248: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(248)                   ,
        b            => ex2_pp1_4s(248)                   ,
        c            => ex2_pp1_5c(248)                   ,
        d            => ex2_pp1_5s(248)                   ,
        ki           => ex2_pp2_2k(248)                   ,
        ko           => ex2_pp2_2k(247)                   ,
        sum          => ex2_pp2_2s(248)                   ,
        car          => ex2_pp2_2c(247)                  );
    csa2_2_247: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(247)                   ,
        b            => ex2_pp1_4s(247)                   ,
        c            => ex2_pp1_5c(247)                   ,
        d            => ex2_pp1_5s(247)                   ,
        ki           => ex2_pp2_2k(247)                   ,
        ko           => ex2_pp2_2k(246)                   ,
        sum          => ex2_pp2_2s(247)                   ,
        car          => ex2_pp2_2c(246)                  );
    csa2_2_246: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(246)                   ,
        b            => ex2_pp1_4s(246)                   ,
        c            => ex2_pp1_5c(246)                   ,
        d            => ex2_pp1_5s(246)                   ,
        ki           => ex2_pp2_2k(246)                   ,
        ko           => ex2_pp2_2k(245)                   ,
        sum          => ex2_pp2_2s(246)                   ,
        car          => ex2_pp2_2c(245)                  );
    csa2_2_245: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(245)                   ,
        b            => ex2_pp1_4s(245)                   ,
        c            => ex2_pp1_5c(245)                   ,
        d            => ex2_pp1_5s(245)                   ,
        ki           => ex2_pp2_2k(245)                   ,
        ko           => ex2_pp2_2k(244)                   ,
        sum          => ex2_pp2_2s(245)                   ,
        car          => ex2_pp2_2c(244)                  );
    csa2_2_244: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(244)                   ,
        b            => ex2_pp1_4s(244)                   ,
        c            => ex2_pp1_5c(244)                   ,
        d            => ex2_pp1_5s(244)                   ,
        ki           => ex2_pp2_2k(244)                   ,
        ko           => ex2_pp2_2k(243)                   ,
        sum          => ex2_pp2_2s(244)                   ,
        car          => ex2_pp2_2c(243)                  );
    csa2_2_243: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(243)                   ,
        b            => ex2_pp1_4s(243)                   ,
        c            => ex2_pp1_5c(243)                   ,
        d            => ex2_pp1_5s(243)                   ,
        ki           => ex2_pp2_2k(243)                   ,
        ko           => ex2_pp2_2k(242)                   ,
        sum          => ex2_pp2_2s(243)                   ,
        car          => ex2_pp2_2c(242)                  );
    csa2_2_242: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(242)                   ,
        b            => ex2_pp1_4s(242)                   ,
        c            => ex2_pp1_5c(242)                   ,
        d            => ex2_pp1_5s(242)                   ,
        ki           => ex2_pp2_2k(242)                   ,
        ko           => ex2_pp2_2k(241)                   ,
        sum          => ex2_pp2_2s(242)                   ,
        car          => ex2_pp2_2c(241)                  );
    csa2_2_241: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(241)                   ,
        b            => ex2_pp1_4s(241)                   ,
        c            => ex2_pp1_5c(241)                   ,
        d            => ex2_pp1_5s(241)                   ,
        ki           => ex2_pp2_2k(241)                   ,
        ko           => ex2_pp2_2k(240)                   ,
        sum          => ex2_pp2_2s(241)                   ,
        car          => ex2_pp2_2c(240)                  );
    csa2_2_240: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(240)                   ,
        b            => ex2_pp1_4s(240)                   ,
        c            => ex2_pp1_5c(240)                   ,
        d            => ex2_pp1_5s(240)                   ,
        ki           => ex2_pp2_2k(240)                   ,
        ko           => ex2_pp2_2k(239)                   ,
        sum          => ex2_pp2_2s(240)                   ,
        car          => ex2_pp2_2c(239)                  );
    csa2_2_239: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(239)                   ,
        b            => ex2_pp1_4s(239)                   ,
        c            => ex2_pp1_5c(239)                   ,
        d            => ex2_pp1_5s(239)                   ,
        ki           => ex2_pp2_2k(239)                   ,
        ko           => ex2_pp2_2k(238)                   ,
        sum          => ex2_pp2_2s(239)                   ,
        car          => ex2_pp2_2c(238)                  );
    csa2_2_238: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(238)                   ,
        b            => ex2_pp1_4s(238)                   ,
        c            => ex2_pp1_5c(238)                   ,
        d            => ex2_pp1_5s(238)                   ,
        ki           => ex2_pp2_2k(238)                   ,
        ko           => ex2_pp2_2k(237)                   ,
        sum          => ex2_pp2_2s(238)                   ,
        car          => ex2_pp2_2c(237)                  );
    csa2_2_237: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(237)                   ,
        b            => ex2_pp1_4s(237)                   ,
        c            => ex2_pp1_5c(237)                   ,
        d            => ex2_pp1_5s(237)                   ,
        ki           => ex2_pp2_2k(237)                   ,
        ko           => ex2_pp2_2k(236)                   ,
        sum          => ex2_pp2_2s(237)                   ,
        car          => ex2_pp2_2c(236)                  );
    csa2_2_236: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(236)                   ,
        b            => ex2_pp1_4s(236)                   ,
        c            => ex2_pp1_5c(236)                   ,
        d            => ex2_pp1_5s(236)                   ,
        ki           => ex2_pp2_2k(236)                   ,
        ko           => ex2_pp2_2k(235)                   ,
        sum          => ex2_pp2_2s(236)                   ,
        car          => ex2_pp2_2c(235)                  );
    csa2_2_235: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(235)                   ,
        b            => ex2_pp1_4s(235)                   ,
        c            => ex2_pp1_5c(235)                   ,
        d            => ex2_pp1_5s(235)                   ,
        ki           => ex2_pp2_2k(235)                   ,
        ko           => ex2_pp2_2k(234)                   ,
        sum          => ex2_pp2_2s(235)                   ,
        car          => ex2_pp2_2c(234)                  );
    csa2_2_234: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(234)                   ,
        b            => ex2_pp1_4s(234)                   ,
        c            => ex2_pp1_5c(234)                   ,
        d            => ex2_pp1_5s(234)                   ,
        ki           => ex2_pp2_2k(234)                   ,
        ko           => ex2_pp2_2k(233)                   ,
        sum          => ex2_pp2_2s(234)                   ,
        car          => ex2_pp2_2c(233)                  );
    csa2_2_233: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(233)                   ,
        b            => ex2_pp1_4s(233)                   ,
        c            => ex2_pp1_5c(233)                   ,
        d            => ex2_pp1_5s(233)                   ,
        ki           => ex2_pp2_2k(233)                   ,
        ko           => ex2_pp2_2k(232)                   ,
        sum          => ex2_pp2_2s(233)                   ,
        car          => ex2_pp2_2c(232)                  );
    csa2_2_232: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(232)                   ,
        b            => ex2_pp1_4s(232)                   ,
        c            => ex2_pp1_5c(232)                   ,
        d            => ex2_pp1_5s(232)                   ,
        ki           => ex2_pp2_2k(232)                   ,
        ko           => ex2_pp2_2k(231)                   ,
        sum          => ex2_pp2_2s(232)                   ,
        car          => ex2_pp2_2c(231)                  );
    csa2_2_231: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(231)                   ,
        b            => ex2_pp1_4s(231)                   ,
        c            => ex2_pp1_5c(231)                   ,
        d            => ex2_pp1_5s(231)                   ,
        ki           => ex2_pp2_2k(231)                   ,
        ko           => ex2_pp2_2k(230)                   ,
        sum          => ex2_pp2_2s(231)                   ,
        car          => ex2_pp2_2c(230)                  );
    csa2_2_230: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(230)                   ,
        b            => ex2_pp1_4s(230)                   ,
        c            => ex2_pp1_5c(230)                   ,
        d            => ex2_pp1_5s(230)                   ,
        ki           => ex2_pp2_2k(230)                   ,
        ko           => ex2_pp2_2k(229)                   ,
        sum          => ex2_pp2_2s(230)                   ,
        car          => ex2_pp2_2c(229)                  );
    csa2_2_229: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(229)                   ,
        b            => ex2_pp1_4s(229)                   ,
        c            => ex2_pp1_5c(229)                   ,
        d            => ex2_pp1_5s(229)                   ,
        ki           => ex2_pp2_2k(229)                   ,
        ko           => ex2_pp2_2k(228)                   ,
        sum          => ex2_pp2_2s(229)                   ,
        car          => ex2_pp2_2c(228)                  );
    csa2_2_228: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(228)                   ,
        b            => ex2_pp1_4s(228)                   ,
        c            => ex2_pp1_5c(228)                   ,
        d            => ex2_pp1_5s(228)                   ,
        ki           => ex2_pp2_2k(228)                   ,
        ko           => ex2_pp2_2k(227)                   ,
        sum          => ex2_pp2_2s(228)                   ,
        car          => ex2_pp2_2c(227)                  );
    csa2_2_227: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(227)                   ,
        b            => ex2_pp1_4s(227)                   ,
        c            => ex2_pp1_5c(227)                   ,
        d            => ex2_pp1_5s(227)                   ,
        ki           => ex2_pp2_2k(227)                   ,
        ko           => ex2_pp2_2k(226)                   ,
        sum          => ex2_pp2_2s(227)                   ,
        car          => ex2_pp2_2c(226)                  );
    csa2_2_226: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(226)                   ,
        b            => ex2_pp1_4s(226)                   ,
        c            => ex2_pp1_5s(226)                   ,
        d            => tidn                              ,
        ki           => ex2_pp2_2k(226)                   ,
        ko           => ex2_pp2_2k(225)                   ,
        sum          => ex2_pp2_2s(226)                   ,
        car          => ex2_pp2_2c(225)                  );
    csa2_2_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex2_pp1_4c(225)                   ,
        b            => ex2_pp1_4s(225)                   ,
        c            => ex2_pp2_2k(225)                   ,
        sum          => ex2_pp2_2s(225)                   ,
        car          => ex2_pp2_2c(224)                  );
    csa2_2_224: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_4c(224)                   ,
        b            => ex2_pp1_4s(224)                   ,
        sum          => ex2_pp2_2s(224)                   ,
        car          => ex2_pp2_2c(223)                  );
    csa2_2_223: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_4c(223)                   ,
        b            => ex2_pp1_4s(223)                   ,
        sum          => ex2_pp2_2s(223)                   ,
        car          => ex2_pp2_2c(222)                  );
    csa2_2_222: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_4c(222)                   ,
        b            => ex2_pp1_4s(222)                   ,
        sum          => ex2_pp2_2s(222)                   ,
        car          => ex2_pp2_2c(221)                  );
    csa2_2_221: entity work.xuq_alu_mult_csa22 port map(
        a            => ex2_pp1_4c(221)                   ,
        b            => ex2_pp1_4s(221)                   ,
        sum          => ex2_pp2_2s(221)                   ,
        car          => ex2_pp2_2c(220)                  );
 ex2_pp2_2s(220)                  <= ex2_pp1_4s(220)                  ; 





  ex3_pp2_0s_din(198 to 242) <= ex2_pp2_0s(198 to 242) ;
  ex3_pp2_0c_din(198 to 240) <= ex2_pp2_0c(198 to 240) ;
  ex3_pp2_1s_din(208 to 254) <= ex2_pp2_1s(208 to 254) ;
  ex3_pp2_1c_din(208 to 252) <= ex2_pp2_1c(208 to 252) ;
  ex3_pp2_2s_din(220 to 264) <= ex2_pp2_2s(220 to 264) ;
  ex3_pp2_2c_din(220 to 263) <= ex2_pp2_2c(220 to 263) ;



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









 ex3_pp3_0s(252)                  <= ex3_pp2_1c(252)                  ; 
 ex3_pp3_0s(251)                  <= tidn                             ; 
 ex3_pp3_0s(250)                  <= tidn                             ; 
 ex3_pp3_0s(249)                  <= ex3_pp2_1c(249)                  ; 
 ex3_pp3_0s(248)                  <= tidn                             ; 
 ex3_pp3_0s(247)                  <= ex3_pp2_1c(247)                  ; 
 ex3_pp3_0s(246)                  <= ex3_pp2_1c(246)                  ; 
 ex3_pp3_0s(245)                  <= ex3_pp2_1c(245)                  ; 
 ex3_pp3_0s(244)                  <= ex3_pp2_1c(244)                  ; 
 ex3_pp3_0s(243)                  <= ex3_pp2_1c(243)                  ; 
 ex3_pp3_0c(242)                  <= ex3_pp2_1c(242)                  ; 
 ex3_pp3_0s(242)                  <= ex3_pp2_0s(242)                  ; 
 ex3_pp3_0c(241)                  <= tidn                             ; 
 ex3_pp3_0s(241)                  <= ex3_pp2_1c(241)                  ; 
 ex3_pp3_0c(240)                  <= tidn                             ; 
    csa3_0_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(240)                   ,
        b            => ex3_pp2_0s(240)                   ,
        c            => ex3_pp2_1c(240)                   ,
        sum          => ex3_pp3_0s(240)                   ,
        car          => ex3_pp3_0c(239)                  );
    csa3_0_239: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0s(239)                   ,
        b            => ex3_pp2_1c(239)                   ,
        sum          => ex3_pp3_0s(239)                   ,
        car          => ex3_pp3_0c(238)                  );
    csa3_0_238: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0s(238)                   ,
        b            => ex3_pp2_1c(238)                   ,
        sum          => ex3_pp3_0s(238)                   ,
        car          => ex3_pp3_0c(237)                  );
    csa3_0_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(237)                   ,
        b            => ex3_pp2_0s(237)                   ,
        c            => ex3_pp2_1c(237)                   ,
        sum          => ex3_pp3_0s(237)                   ,
        car          => ex3_pp3_0c(236)                  );
    csa3_0_236: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0s(236)                   ,
        b            => ex3_pp2_1c(236)                   ,
        sum          => ex3_pp3_0s(236)                   ,
        car          => ex3_pp3_0c(235)                  );
    csa3_0_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(235)                   ,
        b            => ex3_pp2_0s(235)                   ,
        c            => ex3_pp2_1c(235)                   ,
        sum          => ex3_pp3_0s(235)                   ,
        car          => ex3_pp3_0c(234)                  );
    csa3_0_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(234)                   ,
        b            => ex3_pp2_0s(234)                   ,
        c            => ex3_pp2_1c(234)                   ,
        sum          => ex3_pp3_0s(234)                   ,
        car          => ex3_pp3_0c(233)                  );
    csa3_0_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(233)                   ,
        b            => ex3_pp2_0s(233)                   ,
        c            => ex3_pp2_1c(233)                   ,
        sum          => ex3_pp3_0s(233)                   ,
        car          => ex3_pp3_0c(232)                  );
    csa3_0_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(232)                   ,
        b            => ex3_pp2_0s(232)                   ,
        c            => ex3_pp2_1c(232)                   ,
        sum          => ex3_pp3_0s(232)                   ,
        car          => ex3_pp3_0c(231)                  );
    csa3_0_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(231)                   ,
        b            => ex3_pp2_0s(231)                   ,
        c            => ex3_pp2_1c(231)                   ,
        sum          => ex3_pp3_0s(231)                   ,
        car          => ex3_pp3_0c(230)                  );
    csa3_0_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(230)                   ,
        b            => ex3_pp2_0s(230)                   ,
        c            => ex3_pp2_1c(230)                   ,
        sum          => ex3_pp3_0s(230)                   ,
        car          => ex3_pp3_0c(229)                  );
    csa3_0_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(229)                   ,
        b            => ex3_pp2_0s(229)                   ,
        c            => ex3_pp2_1c(229)                   ,
        sum          => ex3_pp3_0s(229)                   ,
        car          => ex3_pp3_0c(228)                  );
    csa3_0_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(228)                   ,
        b            => ex3_pp2_0s(228)                   ,
        c            => ex3_pp2_1c(228)                   ,
        sum          => ex3_pp3_0s(228)                   ,
        car          => ex3_pp3_0c(227)                  );
    csa3_0_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(227)                   ,
        b            => ex3_pp2_0s(227)                   ,
        c            => ex3_pp2_1c(227)                   ,
        sum          => ex3_pp3_0s(227)                   ,
        car          => ex3_pp3_0c(226)                  );
    csa3_0_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(226)                   ,
        b            => ex3_pp2_0s(226)                   ,
        c            => ex3_pp2_1c(226)                   ,
        sum          => ex3_pp3_0s(226)                   ,
        car          => ex3_pp3_0c(225)                  );
    csa3_0_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(225)                   ,
        b            => ex3_pp2_0s(225)                   ,
        c            => ex3_pp2_1c(225)                   ,
        sum          => ex3_pp3_0s(225)                   ,
        car          => ex3_pp3_0c(224)                  );
    csa3_0_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(224)                   ,
        b            => ex3_pp2_0s(224)                   ,
        c            => ex3_pp2_1c(224)                   ,
        sum          => ex3_pp3_0s(224)                   ,
        car          => ex3_pp3_0c(223)                  );
    csa3_0_223: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(223)                   ,
        b            => ex3_pp2_0s(223)                   ,
        c            => ex3_pp2_1c(223)                   ,
        sum          => ex3_pp3_0s(223)                   ,
        car          => ex3_pp3_0c(222)                  );
    csa3_0_222: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(222)                   ,
        b            => ex3_pp2_0s(222)                   ,
        c            => ex3_pp2_1c(222)                   ,
        sum          => ex3_pp3_0s(222)                   ,
        car          => ex3_pp3_0c(221)                  );
    csa3_0_221: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(221)                   ,
        b            => ex3_pp2_0s(221)                   ,
        c            => ex3_pp2_1c(221)                   ,
        sum          => ex3_pp3_0s(221)                   ,
        car          => ex3_pp3_0c(220)                  );
    csa3_0_220: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(220)                   ,
        b            => ex3_pp2_0s(220)                   ,
        c            => ex3_pp2_1c(220)                   ,
        sum          => ex3_pp3_0s(220)                   ,
        car          => ex3_pp3_0c(219)                  );
    csa3_0_219: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(219)                   ,
        b            => ex3_pp2_0s(219)                   ,
        c            => ex3_pp2_1c(219)                   ,
        sum          => ex3_pp3_0s(219)                   ,
        car          => ex3_pp3_0c(218)                  );
    csa3_0_218: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(218)                   ,
        b            => ex3_pp2_0s(218)                   ,
        c            => ex3_pp2_1c(218)                   ,
        sum          => ex3_pp3_0s(218)                   ,
        car          => ex3_pp3_0c(217)                  );
    csa3_0_217: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(217)                   ,
        b            => ex3_pp2_0s(217)                   ,
        c            => ex3_pp2_1c(217)                   ,
        sum          => ex3_pp3_0s(217)                   ,
        car          => ex3_pp3_0c(216)                  );
    csa3_0_216: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(216)                   ,
        b            => ex3_pp2_0s(216)                   ,
        c            => ex3_pp2_1c(216)                   ,
        sum          => ex3_pp3_0s(216)                   ,
        car          => ex3_pp3_0c(215)                  );
    csa3_0_215: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(215)                   ,
        b            => ex3_pp2_0s(215)                   ,
        c            => ex3_pp2_1c(215)                   ,
        sum          => ex3_pp3_0s(215)                   ,
        car          => ex3_pp3_0c(214)                  );
    csa3_0_214: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(214)                   ,
        b            => ex3_pp2_0s(214)                   ,
        c            => ex3_pp2_1c(214)                   ,
        sum          => ex3_pp3_0s(214)                   ,
        car          => ex3_pp3_0c(213)                  );
    csa3_0_213: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(213)                   ,
        b            => ex3_pp2_0s(213)                   ,
        c            => ex3_pp2_1c(213)                   ,
        sum          => ex3_pp3_0s(213)                   ,
        car          => ex3_pp3_0c(212)                  );
    csa3_0_212: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(212)                   ,
        b            => ex3_pp2_0s(212)                   ,
        c            => ex3_pp2_1c(212)                   ,
        sum          => ex3_pp3_0s(212)                   ,
        car          => ex3_pp3_0c(211)                  );
    csa3_0_211: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(211)                   ,
        b            => ex3_pp2_0s(211)                   ,
        c            => ex3_pp2_1c(211)                   ,
        sum          => ex3_pp3_0s(211)                   ,
        car          => ex3_pp3_0c(210)                  );
    csa3_0_210: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(210)                   ,
        b            => ex3_pp2_0s(210)                   ,
        c            => ex3_pp2_1c(210)                   ,
        sum          => ex3_pp3_0s(210)                   ,
        car          => ex3_pp3_0c(209)                  );
    csa3_0_209: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(209)                   ,
        b            => ex3_pp2_0s(209)                   ,
        c            => ex3_pp2_1c(209)                   ,
        sum          => ex3_pp3_0s(209)                   ,
        car          => ex3_pp3_0c(208)                  );
    csa3_0_208: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_0c(208)                   ,
        b            => ex3_pp2_0s(208)                   ,
        c            => ex3_pp2_1c(208)                   ,
        sum          => ex3_pp3_0s(208)                   ,
        car          => ex3_pp3_0c(207)                  );
    csa3_0_207: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(207)                   ,
        b            => ex3_pp2_0s(207)                   ,
        sum          => ex3_pp3_0s(207)                   ,
        car          => ex3_pp3_0c(206)                  );
    csa3_0_206: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(206)                   ,
        b            => ex3_pp2_0s(206)                   ,
        sum          => ex3_pp3_0s(206)                   ,
        car          => ex3_pp3_0c(205)                  );
    csa3_0_205: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(205)                   ,
        b            => ex3_pp2_0s(205)                   ,
        sum          => ex3_pp3_0s(205)                   ,
        car          => ex3_pp3_0c(204)                  );
    csa3_0_204: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(204)                   ,
        b            => ex3_pp2_0s(204)                   ,
        sum          => ex3_pp3_0s(204)                   ,
        car          => ex3_pp3_0c(203)                  );
    csa3_0_203: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(203)                   ,
        b            => ex3_pp2_0s(203)                   ,
        sum          => ex3_pp3_0s(203)                   ,
        car          => ex3_pp3_0c(202)                  );
    csa3_0_202: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(202)                   ,
        b            => ex3_pp2_0s(202)                   ,
        sum          => ex3_pp3_0s(202)                   ,
        car          => ex3_pp3_0c(201)                  );
    csa3_0_201: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(201)                   ,
        b            => ex3_pp2_0s(201)                   ,
        sum          => ex3_pp3_0s(201)                   ,
        car          => ex3_pp3_0c(200)                  );
    csa3_0_200: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(200)                   ,
        b            => ex3_pp2_0s(200)                   ,
        sum          => ex3_pp3_0s(200)                   ,
        car          => ex3_pp3_0c(199)                  );
    csa3_0_199: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(199)                   ,
        b            => ex3_pp2_0s(199)                   ,
        sum          => ex3_pp3_0s(199)                   ,
        car          => ex3_pp3_0c(198)                  );
    csa3_0_198: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_0c(198)                   ,
        b            => ex3_pp2_0s(198)                   ,
        sum          => ex3_pp3_0s(198)                   ,
        car          => ex3_pp3_0c(197)                  );



 ex3_pp3_1s(264)                  <= ex3_pp2_2s(264)                  ; 
    csa3_1_263: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_2c(263)                   ,
        b            => ex3_pp2_2s(263)                   ,
        sum          => ex3_pp3_1s(263)                   ,
        car          => ex3_pp3_1c(262)                  );
 ex3_pp3_1s(262)                  <= ex3_pp2_2s(262)                  ; 
 ex3_pp3_1c(261)                  <= ex3_pp2_2s(261)                  ; 
 ex3_pp3_1s(261)                  <= ex3_pp2_2c(261)                  ; 
 ex3_pp3_1c(260)                  <= tidn                             ; 
 ex3_pp3_1s(260)                  <= ex3_pp2_2s(260)                  ; 
 ex3_pp3_1c(259)                  <= ex3_pp2_2s(259)                  ; 
 ex3_pp3_1s(259)                  <= ex3_pp2_2c(259)                  ; 
 ex3_pp3_1c(258)                  <= ex3_pp2_2s(258)                  ; 
 ex3_pp3_1s(258)                  <= ex3_pp2_2c(258)                  ; 
 ex3_pp3_1c(257)                  <= ex3_pp2_2s(257)                  ; 
 ex3_pp3_1s(257)                  <= ex3_pp2_2c(257)                  ; 
 ex3_pp3_1c(256)                  <= ex3_pp2_2s(256)                  ; 
 ex3_pp3_1s(256)                  <= ex3_pp2_2c(256)                  ; 
 ex3_pp3_1c(255)                  <= ex3_pp2_2s(255)                  ; 
 ex3_pp3_1s(255)                  <= ex3_pp2_2c(255)                  ; 
 ex3_pp3_1c(254)                  <= tidn                             ; 
    csa3_1_254: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(254)                   ,
        b            => ex3_pp2_2c(254)                   ,
        c            => ex3_pp2_2s(254)                   ,
        sum          => ex3_pp3_1s(254)                   ,
        car          => ex3_pp3_1c(253)                  );
    csa3_1_253: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp2_2c(253)                   ,
        b            => ex3_pp2_2s(253)                   ,
        sum          => ex3_pp3_1s(253)                   ,
        car          => ex3_pp3_1c(252)                  );
    csa3_1_252: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(252)                   ,
        b            => ex3_pp2_2c(252)                   ,
        c            => ex3_pp2_2s(252)                   ,
        sum          => ex3_pp3_1s(252)                   ,
        car          => ex3_pp3_1c(251)                  );
    csa3_1_251: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(251)                   ,
        b            => ex3_pp2_2c(251)                   ,
        c            => ex3_pp2_2s(251)                   ,
        sum          => ex3_pp3_1s(251)                   ,
        car          => ex3_pp3_1c(250)                  );
    csa3_1_250: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(250)                   ,
        b            => ex3_pp2_2c(250)                   ,
        c            => ex3_pp2_2s(250)                   ,
        sum          => ex3_pp3_1s(250)                   ,
        car          => ex3_pp3_1c(249)                  );
    csa3_1_249: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(249)                   ,
        b            => ex3_pp2_2c(249)                   ,
        c            => ex3_pp2_2s(249)                   ,
        sum          => ex3_pp3_1s(249)                   ,
        car          => ex3_pp3_1c(248)                  );
    csa3_1_248: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(248)                   ,
        b            => ex3_pp2_2c(248)                   ,
        c            => ex3_pp2_2s(248)                   ,
        sum          => ex3_pp3_1s(248)                   ,
        car          => ex3_pp3_1c(247)                  );
    csa3_1_247: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(247)                   ,
        b            => ex3_pp2_2c(247)                   ,
        c            => ex3_pp2_2s(247)                   ,
        sum          => ex3_pp3_1s(247)                   ,
        car          => ex3_pp3_1c(246)                  );
    csa3_1_246: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(246)                   ,
        b            => ex3_pp2_2c(246)                   ,
        c            => ex3_pp2_2s(246)                   ,
        sum          => ex3_pp3_1s(246)                   ,
        car          => ex3_pp3_1c(245)                  );
    csa3_1_245: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(245)                   ,
        b            => ex3_pp2_2c(245)                   ,
        c            => ex3_pp2_2s(245)                   ,
        sum          => ex3_pp3_1s(245)                   ,
        car          => ex3_pp3_1c(244)                  );
    csa3_1_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(244)                   ,
        b            => ex3_pp2_2c(244)                   ,
        c            => ex3_pp2_2s(244)                   ,
        sum          => ex3_pp3_1s(244)                   ,
        car          => ex3_pp3_1c(243)                  );
    csa3_1_243: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(243)                   ,
        b            => ex3_pp2_2c(243)                   ,
        c            => ex3_pp2_2s(243)                   ,
        sum          => ex3_pp3_1s(243)                   ,
        car          => ex3_pp3_1c(242)                  );
    csa3_1_242: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(242)                   ,
        b            => ex3_pp2_2c(242)                   ,
        c            => ex3_pp2_2s(242)                   ,
        sum          => ex3_pp3_1s(242)                   ,
        car          => ex3_pp3_1c(241)                  );
    csa3_1_241: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(241)                   ,
        b            => ex3_pp2_2c(241)                   ,
        c            => ex3_pp2_2s(241)                   ,
        sum          => ex3_pp3_1s(241)                   ,
        car          => ex3_pp3_1c(240)                  );
    csa3_1_240: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(240)                   ,
        b            => ex3_pp2_2c(240)                   ,
        c            => ex3_pp2_2s(240)                   ,
        sum          => ex3_pp3_1s(240)                   ,
        car          => ex3_pp3_1c(239)                  );
    csa3_1_239: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(239)                   ,
        b            => ex3_pp2_2c(239)                   ,
        c            => ex3_pp2_2s(239)                   ,
        sum          => ex3_pp3_1s(239)                   ,
        car          => ex3_pp3_1c(238)                  );
    csa3_1_238: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(238)                   ,
        b            => ex3_pp2_2c(238)                   ,
        c            => ex3_pp2_2s(238)                   ,
        sum          => ex3_pp3_1s(238)                   ,
        car          => ex3_pp3_1c(237)                  );
    csa3_1_237: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(237)                   ,
        b            => ex3_pp2_2c(237)                   ,
        c            => ex3_pp2_2s(237)                   ,
        sum          => ex3_pp3_1s(237)                   ,
        car          => ex3_pp3_1c(236)                  );
    csa3_1_236: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(236)                   ,
        b            => ex3_pp2_2c(236)                   ,
        c            => ex3_pp2_2s(236)                   ,
        sum          => ex3_pp3_1s(236)                   ,
        car          => ex3_pp3_1c(235)                  );
    csa3_1_235: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(235)                   ,
        b            => ex3_pp2_2c(235)                   ,
        c            => ex3_pp2_2s(235)                   ,
        sum          => ex3_pp3_1s(235)                   ,
        car          => ex3_pp3_1c(234)                  );
    csa3_1_234: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(234)                   ,
        b            => ex3_pp2_2c(234)                   ,
        c            => ex3_pp2_2s(234)                   ,
        sum          => ex3_pp3_1s(234)                   ,
        car          => ex3_pp3_1c(233)                  );
    csa3_1_233: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(233)                   ,
        b            => ex3_pp2_2c(233)                   ,
        c            => ex3_pp2_2s(233)                   ,
        sum          => ex3_pp3_1s(233)                   ,
        car          => ex3_pp3_1c(232)                  );
    csa3_1_232: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(232)                   ,
        b            => ex3_pp2_2c(232)                   ,
        c            => ex3_pp2_2s(232)                   ,
        sum          => ex3_pp3_1s(232)                   ,
        car          => ex3_pp3_1c(231)                  );
    csa3_1_231: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(231)                   ,
        b            => ex3_pp2_2c(231)                   ,
        c            => ex3_pp2_2s(231)                   ,
        sum          => ex3_pp3_1s(231)                   ,
        car          => ex3_pp3_1c(230)                  );
    csa3_1_230: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(230)                   ,
        b            => ex3_pp2_2c(230)                   ,
        c            => ex3_pp2_2s(230)                   ,
        sum          => ex3_pp3_1s(230)                   ,
        car          => ex3_pp3_1c(229)                  );
    csa3_1_229: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(229)                   ,
        b            => ex3_pp2_2c(229)                   ,
        c            => ex3_pp2_2s(229)                   ,
        sum          => ex3_pp3_1s(229)                   ,
        car          => ex3_pp3_1c(228)                  );
    csa3_1_228: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(228)                   ,
        b            => ex3_pp2_2c(228)                   ,
        c            => ex3_pp2_2s(228)                   ,
        sum          => ex3_pp3_1s(228)                   ,
        car          => ex3_pp3_1c(227)                  );
    csa3_1_227: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(227)                   ,
        b            => ex3_pp2_2c(227)                   ,
        c            => ex3_pp2_2s(227)                   ,
        sum          => ex3_pp3_1s(227)                   ,
        car          => ex3_pp3_1c(226)                  );
    csa3_1_226: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(226)                   ,
        b            => ex3_pp2_2c(226)                   ,
        c            => ex3_pp2_2s(226)                   ,
        sum          => ex3_pp3_1s(226)                   ,
        car          => ex3_pp3_1c(225)                  );
    csa3_1_225: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(225)                   ,
        b            => ex3_pp2_2c(225)                   ,
        c            => ex3_pp2_2s(225)                   ,
        sum          => ex3_pp3_1s(225)                   ,
        car          => ex3_pp3_1c(224)                  );
    csa3_1_224: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(224)                   ,
        b            => ex3_pp2_2c(224)                   ,
        c            => ex3_pp2_2s(224)                   ,
        sum          => ex3_pp3_1s(224)                   ,
        car          => ex3_pp3_1c(223)                  );
    csa3_1_223: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(223)                   ,
        b            => ex3_pp2_2c(223)                   ,
        c            => ex3_pp2_2s(223)                   ,
        sum          => ex3_pp3_1s(223)                   ,
        car          => ex3_pp3_1c(222)                  );
    csa3_1_222: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(222)                   ,
        b            => ex3_pp2_2c(222)                   ,
        c            => ex3_pp2_2s(222)                   ,
        sum          => ex3_pp3_1s(222)                   ,
        car          => ex3_pp3_1c(221)                  );
    csa3_1_221: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(221)                   ,
        b            => ex3_pp2_2c(221)                   ,
        c            => ex3_pp2_2s(221)                   ,
        sum          => ex3_pp3_1s(221)                   ,
        car          => ex3_pp3_1c(220)                  );
    csa3_1_220: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp2_1s(220)                   ,
        b            => ex3_pp2_2c(220)                   ,
        c            => ex3_pp2_2s(220)                   ,
        sum          => ex3_pp3_1s(220)                   ,
        car          => ex3_pp3_1c(219)                  );
 ex3_pp3_1s(219)                  <= ex3_pp2_1s(219)                  ; 
 ex3_pp3_1s(218)                  <= ex3_pp2_1s(218)                  ; 
 ex3_pp3_1s(217)                  <= ex3_pp2_1s(217)                  ; 
 ex3_pp3_1s(216)                  <= ex3_pp2_1s(216)                  ; 
 ex3_pp3_1s(215)                  <= ex3_pp2_1s(215)                  ; 
 ex3_pp3_1s(214)                  <= ex3_pp2_1s(214)                  ; 
 ex3_pp3_1s(213)                  <= ex3_pp2_1s(213)                  ; 
 ex3_pp3_1s(212)                  <= ex3_pp2_1s(212)                  ; 
 ex3_pp3_1s(211)                  <= ex3_pp2_1s(211)                  ; 
 ex3_pp3_1s(210)                  <= ex3_pp2_1s(210)                  ; 
 ex3_pp3_1s(209)                  <= ex3_pp2_1s(209)                  ; 
 ex3_pp3_1s(208)                  <= ex3_pp2_1s(208)                  ; 







 ex3_pp4_0s(264)                  <= ex3_pp3_1s(264)                  ; 
 ex3_pp4_0s(263)                  <= ex3_pp3_1s(263)                  ; 
 ex3_pp4_0c(262)                  <= ex3_pp3_1s(262)                  ; 
 ex3_pp4_0s(262)                  <= ex3_pp3_1c(262)                  ; 
 ex3_pp4_0c(261)                  <= ex3_pp3_1s(261)                  ; 
 ex3_pp4_0s(261)                  <= ex3_pp3_1c(261)                  ; 
 ex3_pp4_0c(260)                  <= tidn                             ; 
 ex3_pp4_0s(260)                  <= ex3_pp3_1s(260)                  ; 
 ex3_pp4_0c(259)                  <= ex3_pp3_1s(259)                  ; 
 ex3_pp4_0s(259)                  <= ex3_pp3_1c(259)                  ; 
 ex3_pp4_0c(258)                  <= ex3_pp3_1s(258)                  ; 
 ex3_pp4_0s(258)                  <= ex3_pp3_1c(258)                  ; 
 ex3_pp4_0c(257)                  <= ex3_pp3_1s(257)                  ; 
 ex3_pp4_0s(257)                  <= ex3_pp3_1c(257)                  ; 
 ex3_pp4_0c(256)                  <= ex3_pp3_1s(256)                  ; 
 ex3_pp4_0s(256)                  <= ex3_pp3_1c(256)                  ; 
 ex3_pp4_0c(255)                  <= ex3_pp3_1s(255)                  ; 
 ex3_pp4_0s(255)                  <= ex3_pp3_1c(255)                  ; 
 ex3_pp4_0c(254)                  <= tidn                             ; 
 ex3_pp4_0s(254)                  <= ex3_pp3_1s(254)                  ; 
 ex3_pp4_0c(253)                  <= ex3_pp3_1s(253)                  ; 
 ex3_pp4_0s(253)                  <= ex3_pp3_1c(253)                  ; 
 ex3_pp4_0c(252)                  <= tidn                             ; 
    csa4_0_252: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(252)                   ,
        b            => ex3_pp3_1c(252)                   ,
        c            => ex3_pp3_1s(252)                   ,
        sum          => ex3_pp4_0s(252)                   ,
        car          => ex3_pp4_0c(251)                  );
    csa4_0_251: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_1c(251)                   ,
        b            => ex3_pp3_1s(251)                   ,
        sum          => ex3_pp4_0s(251)                   ,
        car          => ex3_pp4_0c(250)                  );
    csa4_0_250: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_1c(250)                   ,
        b            => ex3_pp3_1s(250)                   ,
        sum          => ex3_pp4_0s(250)                   ,
        car          => ex3_pp4_0c(249)                  );
    csa4_0_249: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(249)                   ,
        b            => ex3_pp3_1c(249)                   ,
        c            => ex3_pp3_1s(249)                   ,
        sum          => ex3_pp4_0s(249)                   ,
        car          => ex3_pp4_0c(248)                  );
    csa4_0_248: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_1c(248)                   ,
        b            => ex3_pp3_1s(248)                   ,
        sum          => ex3_pp4_0s(248)                   ,
        car          => ex3_pp4_0c(247)                  );
    csa4_0_247: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(247)                   ,
        b            => ex3_pp3_1c(247)                   ,
        c            => ex3_pp3_1s(247)                   ,
        sum          => ex3_pp4_0s(247)                   ,
        car          => ex3_pp4_0c(246)                  );
    csa4_0_246: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(246)                   ,
        b            => ex3_pp3_1c(246)                   ,
        c            => ex3_pp3_1s(246)                   ,
        sum          => ex3_pp4_0s(246)                   ,
        car          => ex3_pp4_0c(245)                  );
    csa4_0_245: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(245)                   ,
        b            => ex3_pp3_1c(245)                   ,
        c            => ex3_pp3_1s(245)                   ,
        sum          => ex3_pp4_0s(245)                   ,
        car          => ex3_pp4_0c(244)                  );
    csa4_0_244: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(244)                   ,
        b            => ex3_pp3_1c(244)                   ,
        c            => ex3_pp3_1s(244)                   ,
        sum          => ex3_pp4_0s(244)                   ,
        car          => ex3_pp4_0c(243)                  );
    csa4_0_243: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(243)                   ,
        b            => ex3_pp3_1c(243)                   ,
        c            => ex3_pp3_1s(243)                   ,
        sum          => ex3_pp4_0s(243)                   ,
        car          => ex3_pp4_0c(242)                  );
 ex3_pp4_0k(242)                  <= tidn                             ; 
    csa4_0_242: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(242)                   ,
        b            => ex3_pp3_0s(242)                   ,
        c            => ex3_pp3_1c(242)                   ,
        d            => ex3_pp3_1s(242)                   ,
        ki           => ex3_pp4_0k(242)                   ,
        ko           => ex3_pp4_0k(241)                   ,
        sum          => ex3_pp4_0s(242)                   ,
        car          => ex3_pp4_0c(241)                  );
    csa4_0_241: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(241)                   ,
        b            => ex3_pp3_1c(241)                   ,
        c            => ex3_pp3_1s(241)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(241)                   ,
        ko           => ex3_pp4_0k(240)                   ,
        sum          => ex3_pp4_0s(241)                   ,
        car          => ex3_pp4_0c(240)                  );
    csa4_0_240: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0s(240)                   ,
        b            => ex3_pp3_1c(240)                   ,
        c            => ex3_pp3_1s(240)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(240)                   ,
        ko           => ex3_pp4_0k(239)                   ,
        sum          => ex3_pp4_0s(240)                   ,
        car          => ex3_pp4_0c(239)                  );
    csa4_0_239: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(239)                   ,
        b            => ex3_pp3_0s(239)                   ,
        c            => ex3_pp3_1c(239)                   ,
        d            => ex3_pp3_1s(239)                   ,
        ki           => ex3_pp4_0k(239)                   ,
        ko           => ex3_pp4_0k(238)                   ,
        sum          => ex3_pp4_0s(239)                   ,
        car          => ex3_pp4_0c(238)                  );
    csa4_0_238: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(238)                   ,
        b            => ex3_pp3_0s(238)                   ,
        c            => ex3_pp3_1c(238)                   ,
        d            => ex3_pp3_1s(238)                   ,
        ki           => ex3_pp4_0k(238)                   ,
        ko           => ex3_pp4_0k(237)                   ,
        sum          => ex3_pp4_0s(238)                   ,
        car          => ex3_pp4_0c(237)                  );
    csa4_0_237: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(237)                   ,
        b            => ex3_pp3_0s(237)                   ,
        c            => ex3_pp3_1c(237)                   ,
        d            => ex3_pp3_1s(237)                   ,
        ki           => ex3_pp4_0k(237)                   ,
        ko           => ex3_pp4_0k(236)                   ,
        sum          => ex3_pp4_0s(237)                   ,
        car          => ex3_pp4_0c(236)                  );
    csa4_0_236: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(236)                   ,
        b            => ex3_pp3_0s(236)                   ,
        c            => ex3_pp3_1c(236)                   ,
        d            => ex3_pp3_1s(236)                   ,
        ki           => ex3_pp4_0k(236)                   ,
        ko           => ex3_pp4_0k(235)                   ,
        sum          => ex3_pp4_0s(236)                   ,
        car          => ex3_pp4_0c(235)                  );
    csa4_0_235: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(235)                   ,
        b            => ex3_pp3_0s(235)                   ,
        c            => ex3_pp3_1c(235)                   ,
        d            => ex3_pp3_1s(235)                   ,
        ki           => ex3_pp4_0k(235)                   ,
        ko           => ex3_pp4_0k(234)                   ,
        sum          => ex3_pp4_0s(235)                   ,
        car          => ex3_pp4_0c(234)                  );
    csa4_0_234: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(234)                   ,
        b            => ex3_pp3_0s(234)                   ,
        c            => ex3_pp3_1c(234)                   ,
        d            => ex3_pp3_1s(234)                   ,
        ki           => ex3_pp4_0k(234)                   ,
        ko           => ex3_pp4_0k(233)                   ,
        sum          => ex3_pp4_0s(234)                   ,
        car          => ex3_pp4_0c(233)                  );
    csa4_0_233: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(233)                   ,
        b            => ex3_pp3_0s(233)                   ,
        c            => ex3_pp3_1c(233)                   ,
        d            => ex3_pp3_1s(233)                   ,
        ki           => ex3_pp4_0k(233)                   ,
        ko           => ex3_pp4_0k(232)                   ,
        sum          => ex3_pp4_0s(233)                   ,
        car          => ex3_pp4_0c(232)                  );
    csa4_0_232: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(232)                   ,
        b            => ex3_pp3_0s(232)                   ,
        c            => ex3_pp3_1c(232)                   ,
        d            => ex3_pp3_1s(232)                   ,
        ki           => ex3_pp4_0k(232)                   ,
        ko           => ex3_pp4_0k(231)                   ,
        sum          => ex3_pp4_0s(232)                   ,
        car          => ex3_pp4_0c(231)                  );
    csa4_0_231: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(231)                   ,
        b            => ex3_pp3_0s(231)                   ,
        c            => ex3_pp3_1c(231)                   ,
        d            => ex3_pp3_1s(231)                   ,
        ki           => ex3_pp4_0k(231)                   ,
        ko           => ex3_pp4_0k(230)                   ,
        sum          => ex3_pp4_0s(231)                   ,
        car          => ex3_pp4_0c(230)                  );
    csa4_0_230: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(230)                   ,
        b            => ex3_pp3_0s(230)                   ,
        c            => ex3_pp3_1c(230)                   ,
        d            => ex3_pp3_1s(230)                   ,
        ki           => ex3_pp4_0k(230)                   ,
        ko           => ex3_pp4_0k(229)                   ,
        sum          => ex3_pp4_0s(230)                   ,
        car          => ex3_pp4_0c(229)                  );
    csa4_0_229: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(229)                   ,
        b            => ex3_pp3_0s(229)                   ,
        c            => ex3_pp3_1c(229)                   ,
        d            => ex3_pp3_1s(229)                   ,
        ki           => ex3_pp4_0k(229)                   ,
        ko           => ex3_pp4_0k(228)                   ,
        sum          => ex3_pp4_0s(229)                   ,
        car          => ex3_pp4_0c(228)                  );
    csa4_0_228: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(228)                   ,
        b            => ex3_pp3_0s(228)                   ,
        c            => ex3_pp3_1c(228)                   ,
        d            => ex3_pp3_1s(228)                   ,
        ki           => ex3_pp4_0k(228)                   ,
        ko           => ex3_pp4_0k(227)                   ,
        sum          => ex3_pp4_0s(228)                   ,
        car          => ex3_pp4_0c(227)                  );
    csa4_0_227: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(227)                   ,
        b            => ex3_pp3_0s(227)                   ,
        c            => ex3_pp3_1c(227)                   ,
        d            => ex3_pp3_1s(227)                   ,
        ki           => ex3_pp4_0k(227)                   ,
        ko           => ex3_pp4_0k(226)                   ,
        sum          => ex3_pp4_0s(227)                   ,
        car          => ex3_pp4_0c(226)                  );
    csa4_0_226: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(226)                   ,
        b            => ex3_pp3_0s(226)                   ,
        c            => ex3_pp3_1c(226)                   ,
        d            => ex3_pp3_1s(226)                   ,
        ki           => ex3_pp4_0k(226)                   ,
        ko           => ex3_pp4_0k(225)                   ,
        sum          => ex3_pp4_0s(226)                   ,
        car          => ex3_pp4_0c(225)                  );
    csa4_0_225: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(225)                   ,
        b            => ex3_pp3_0s(225)                   ,
        c            => ex3_pp3_1c(225)                   ,
        d            => ex3_pp3_1s(225)                   ,
        ki           => ex3_pp4_0k(225)                   ,
        ko           => ex3_pp4_0k(224)                   ,
        sum          => ex3_pp4_0s(225)                   ,
        car          => ex3_pp4_0c(224)                  );
    csa4_0_224: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(224)                   ,
        b            => ex3_pp3_0s(224)                   ,
        c            => ex3_pp3_1c(224)                   ,
        d            => ex3_pp3_1s(224)                   ,
        ki           => ex3_pp4_0k(224)                   ,
        ko           => ex3_pp4_0k(223)                   ,
        sum          => ex3_pp4_0s(224)                   ,
        car          => ex3_pp4_0c(223)                  );
    csa4_0_223: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(223)                   ,
        b            => ex3_pp3_0s(223)                   ,
        c            => ex3_pp3_1c(223)                   ,
        d            => ex3_pp3_1s(223)                   ,
        ki           => ex3_pp4_0k(223)                   ,
        ko           => ex3_pp4_0k(222)                   ,
        sum          => ex3_pp4_0s(223)                   ,
        car          => ex3_pp4_0c(222)                  );
    csa4_0_222: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(222)                   ,
        b            => ex3_pp3_0s(222)                   ,
        c            => ex3_pp3_1c(222)                   ,
        d            => ex3_pp3_1s(222)                   ,
        ki           => ex3_pp4_0k(222)                   ,
        ko           => ex3_pp4_0k(221)                   ,
        sum          => ex3_pp4_0s(222)                   ,
        car          => ex3_pp4_0c(221)                  );
    csa4_0_221: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(221)                   ,
        b            => ex3_pp3_0s(221)                   ,
        c            => ex3_pp3_1c(221)                   ,
        d            => ex3_pp3_1s(221)                   ,
        ki           => ex3_pp4_0k(221)                   ,
        ko           => ex3_pp4_0k(220)                   ,
        sum          => ex3_pp4_0s(221)                   ,
        car          => ex3_pp4_0c(220)                  );
    csa4_0_220: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(220)                   ,
        b            => ex3_pp3_0s(220)                   ,
        c            => ex3_pp3_1c(220)                   ,
        d            => ex3_pp3_1s(220)                   ,
        ki           => ex3_pp4_0k(220)                   ,
        ko           => ex3_pp4_0k(219)                   ,
        sum          => ex3_pp4_0s(220)                   ,
        car          => ex3_pp4_0c(219)                  );
    csa4_0_219: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(219)                   ,
        b            => ex3_pp3_0s(219)                   ,
        c            => ex3_pp3_1c(219)                   ,
        d            => ex3_pp3_1s(219)                   ,
        ki           => ex3_pp4_0k(219)                   ,
        ko           => ex3_pp4_0k(218)                   ,
        sum          => ex3_pp4_0s(219)                   ,
        car          => ex3_pp4_0c(218)                  );
    csa4_0_218: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(218)                   ,
        b            => ex3_pp3_0s(218)                   ,
        c            => ex3_pp3_1s(218)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(218)                   ,
        ko           => ex3_pp4_0k(217)                   ,
        sum          => ex3_pp4_0s(218)                   ,
        car          => ex3_pp4_0c(217)                  );
    csa4_0_217: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(217)                   ,
        b            => ex3_pp3_0s(217)                   ,
        c            => ex3_pp3_1s(217)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(217)                   ,
        ko           => ex3_pp4_0k(216)                   ,
        sum          => ex3_pp4_0s(217)                   ,
        car          => ex3_pp4_0c(216)                  );
    csa4_0_216: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(216)                   ,
        b            => ex3_pp3_0s(216)                   ,
        c            => ex3_pp3_1s(216)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(216)                   ,
        ko           => ex3_pp4_0k(215)                   ,
        sum          => ex3_pp4_0s(216)                   ,
        car          => ex3_pp4_0c(215)                  );
    csa4_0_215: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(215)                   ,
        b            => ex3_pp3_0s(215)                   ,
        c            => ex3_pp3_1s(215)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(215)                   ,
        ko           => ex3_pp4_0k(214)                   ,
        sum          => ex3_pp4_0s(215)                   ,
        car          => ex3_pp4_0c(214)                  );
    csa4_0_214: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(214)                   ,
        b            => ex3_pp3_0s(214)                   ,
        c            => ex3_pp3_1s(214)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(214)                   ,
        ko           => ex3_pp4_0k(213)                   ,
        sum          => ex3_pp4_0s(214)                   ,
        car          => ex3_pp4_0c(213)                  );
    csa4_0_213: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(213)                   ,
        b            => ex3_pp3_0s(213)                   ,
        c            => ex3_pp3_1s(213)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(213)                   ,
        ko           => ex3_pp4_0k(212)                   ,
        sum          => ex3_pp4_0s(213)                   ,
        car          => ex3_pp4_0c(212)                  );
    csa4_0_212: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(212)                   ,
        b            => ex3_pp3_0s(212)                   ,
        c            => ex3_pp3_1s(212)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(212)                   ,
        ko           => ex3_pp4_0k(211)                   ,
        sum          => ex3_pp4_0s(212)                   ,
        car          => ex3_pp4_0c(211)                  );
    csa4_0_211: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(211)                   ,
        b            => ex3_pp3_0s(211)                   ,
        c            => ex3_pp3_1s(211)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(211)                   ,
        ko           => ex3_pp4_0k(210)                   ,
        sum          => ex3_pp4_0s(211)                   ,
        car          => ex3_pp4_0c(210)                  );
    csa4_0_210: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(210)                   ,
        b            => ex3_pp3_0s(210)                   ,
        c            => ex3_pp3_1s(210)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(210)                   ,
        ko           => ex3_pp4_0k(209)                   ,
        sum          => ex3_pp4_0s(210)                   ,
        car          => ex3_pp4_0c(209)                  );
    csa4_0_209: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(209)                   ,
        b            => ex3_pp3_0s(209)                   ,
        c            => ex3_pp3_1s(209)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(209)                   ,
        ko           => ex3_pp4_0k(208)                   ,
        sum          => ex3_pp4_0s(209)                   ,
        car          => ex3_pp4_0c(208)                  );
    csa4_0_208: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(208)                   ,
        b            => ex3_pp3_0s(208)                   ,
        c            => ex3_pp3_1s(208)                   ,
        d            => tidn                              ,
        ki           => ex3_pp4_0k(208)                   ,
        ko           => ex3_pp4_0k(207)                   ,
        sum          => ex3_pp4_0s(208)                   ,
        car          => ex3_pp4_0c(207)                  );
    csa4_0_207: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp3_0c(207)                   ,
        b            => ex3_pp3_0s(207)                   ,
        c            => ex3_pp4_0k(207)                   ,
        sum          => ex3_pp4_0s(207)                   ,
        car          => ex3_pp4_0c(206)                  );
    csa4_0_206: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(206)                   ,
        b            => ex3_pp3_0s(206)                   ,
        sum          => ex3_pp4_0s(206)                   ,
        car          => ex3_pp4_0c(205)                  );
    csa4_0_205: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(205)                   ,
        b            => ex3_pp3_0s(205)                   ,
        sum          => ex3_pp4_0s(205)                   ,
        car          => ex3_pp4_0c(204)                  );
    csa4_0_204: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(204)                   ,
        b            => ex3_pp3_0s(204)                   ,
        sum          => ex3_pp4_0s(204)                   ,
        car          => ex3_pp4_0c(203)                  );
    csa4_0_203: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(203)                   ,
        b            => ex3_pp3_0s(203)                   ,
        sum          => ex3_pp4_0s(203)                   ,
        car          => ex3_pp4_0c(202)                  );
    csa4_0_202: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(202)                   ,
        b            => ex3_pp3_0s(202)                   ,
        sum          => ex3_pp4_0s(202)                   ,
        car          => ex3_pp4_0c(201)                  );
    csa4_0_201: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(201)                   ,
        b            => ex3_pp3_0s(201)                   ,
        sum          => ex3_pp4_0s(201)                   ,
        car          => ex3_pp4_0c(200)                  );
    csa4_0_200: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(200)                   ,
        b            => ex3_pp3_0s(200)                   ,
        sum          => ex3_pp4_0s(200)                   ,
        car          => ex3_pp4_0c(199)                  );
    csa4_0_199: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(199)                   ,
        b            => ex3_pp3_0s(199)                   ,
        sum          => ex3_pp4_0s(199)                   ,
        car          => ex3_pp4_0c(198)                  );
    csa4_0_198: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp3_0c(198)                   ,
        b            => ex3_pp3_0s(198)                   ,
        sum          => ex3_pp4_0s(198)                   ,
        car          => ex3_pp4_0c(197)                  );
 ex3_pp4_0s(197)                  <= ex3_pp3_0c(197)                  ; 









    csa5_0_264: entity work.xuq_alu_mult_csa22 port map(
        a            => ex3_pp4_0s(264)                   ,
        b            => ex3_recycle_s(264)                ,
        sum          => ex3_pp5_0s(264)                   ,
        car          => ex3_pp5_0c(263)                  );
    csa5_0_263: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0s(263)                   ,
        b            => ex3_recycle_c(263)                ,
        c            => ex3_recycle_s(263)                ,
        sum          => ex3_pp5_0s(263)                   ,
        car          => ex3_pp5_0c(262)                  );
 ex3_pp5_0k(262)                  <= tidn                             ; 
    csa5_0_262: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(262)                   ,
        b            => ex3_pp4_0s(262)                   ,
        c            => ex3_recycle_c(262)                ,
        d            => ex3_recycle_s(262)                ,
        ki           => ex3_pp5_0k(262)                   ,
        ko           => ex3_pp5_0k(261)                   ,
        sum          => ex3_pp5_0s(262)                   ,
        car          => ex3_pp5_0c(261)                  );
    csa5_0_261: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(261)                   ,
        b            => ex3_pp4_0s(261)                   ,
        c            => ex3_recycle_c(261)                ,
        d            => ex3_recycle_s(261)                ,
        ki           => ex3_pp5_0k(261)                   ,
        ko           => ex3_pp5_0k(260)                   ,
        sum          => ex3_pp5_0s(261)                   ,
        car          => ex3_pp5_0c(260)                  );
    csa5_0_260: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0s(260)                   ,
        b            => ex3_recycle_c(260)                ,
        c            => ex3_recycle_s(260)                ,
        d            => tidn                              ,
        ki           => ex3_pp5_0k(260)                   ,
        ko           => ex3_pp5_0k(259)                   ,
        sum          => ex3_pp5_0s(260)                   ,
        car          => ex3_pp5_0c(259)                  );
    csa5_0_259: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(259)                   ,
        b            => ex3_pp4_0s(259)                   ,
        c            => ex3_recycle_c(259)                ,
        d            => ex3_recycle_s(259)                ,
        ki           => ex3_pp5_0k(259)                   ,
        ko           => ex3_pp5_0k(258)                   ,
        sum          => ex3_pp5_0s(259)                   ,
        car          => ex3_pp5_0c(258)                  );
    csa5_0_258: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(258)                   ,
        b            => ex3_pp4_0s(258)                   ,
        c            => ex3_recycle_c(258)                ,
        d            => ex3_recycle_s(258)                ,
        ki           => ex3_pp5_0k(258)                   ,
        ko           => ex3_pp5_0k(257)                   ,
        sum          => ex3_pp5_0s(258)                   ,
        car          => ex3_pp5_0c(257)                  );
    csa5_0_257: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(257)                   ,
        b            => ex3_pp4_0s(257)                   ,
        c            => ex3_recycle_c(257)                ,
        d            => ex3_recycle_s(257)                ,
        ki           => ex3_pp5_0k(257)                   ,
        ko           => ex3_pp5_0k(256)                   ,
        sum          => ex3_pp5_0s(257)                   ,
        car          => ex3_pp5_0c(256)                  );
    csa5_0_256: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(256)                   ,
        b            => ex3_pp4_0s(256)                   ,
        c            => ex3_recycle_c(256)                ,
        d            => ex3_recycle_s(256)                ,
        ki           => ex3_pp5_0k(256)                   ,
        ko           => ex3_pp5_0k(255)                   ,
        sum          => ex3_pp5_0s(256)                   ,
        car          => ex3_pp5_0c(255)                  );
    csa5_0_255: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(255)                   ,
        b            => ex3_pp4_0s(255)                   ,
        c            => ex3_recycle_c(255)                ,
        d            => ex3_recycle_s(255)                ,
        ki           => ex3_pp5_0k(255)                   ,
        ko           => ex3_pp5_0k(254)                   ,
        sum          => ex3_pp5_0s(255)                   ,
        car          => ex3_pp5_0c(254)                  );
    csa5_0_254: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0s(254)                   ,
        b            => ex3_recycle_c(254)                ,
        c            => ex3_recycle_s(254)                ,
        d            => tidn                              ,
        ki           => ex3_pp5_0k(254)                   ,
        ko           => ex3_pp5_0k(253)                   ,
        sum          => ex3_pp5_0s(254)                   ,
        car          => ex3_pp5_0c(253)                  );
    csa5_0_253: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(253)                   ,
        b            => ex3_pp4_0s(253)                   ,
        c            => ex3_recycle_c(253)                ,
        d            => ex3_recycle_s(253)                ,
        ki           => ex3_pp5_0k(253)                   ,
        ko           => ex3_pp5_0k(252)                   ,
        sum          => ex3_pp5_0s(253)                   ,
        car          => ex3_pp5_0c(252)                  );
    csa5_0_252: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0s(252)                   ,
        b            => ex3_recycle_c(252)                ,
        c            => ex3_recycle_s(252)                ,
        d            => tidn                              ,
        ki           => ex3_pp5_0k(252)                   ,
        ko           => ex3_pp5_0k(251)                   ,
        sum          => ex3_pp5_0s(252)                   ,
        car          => ex3_pp5_0c(251)                  );
    csa5_0_251: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(251)                   ,
        b            => ex3_pp4_0s(251)                   ,
        c            => ex3_recycle_c(251)                ,
        d            => ex3_recycle_s(251)                ,
        ki           => ex3_pp5_0k(251)                   ,
        ko           => ex3_pp5_0k(250)                   ,
        sum          => ex3_pp5_0s(251)                   ,
        car          => ex3_pp5_0c(250)                  );
    csa5_0_250: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(250)                   ,
        b            => ex3_pp4_0s(250)                   ,
        c            => ex3_recycle_c(250)                ,
        d            => ex3_recycle_s(250)                ,
        ki           => ex3_pp5_0k(250)                   ,
        ko           => ex3_pp5_0k(249)                   ,
        sum          => ex3_pp5_0s(250)                   ,
        car          => ex3_pp5_0c(249)                  );
    csa5_0_249: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(249)                   ,
        b            => ex3_pp4_0s(249)                   ,
        c            => ex3_recycle_c(249)                ,
        d            => ex3_recycle_s(249)                ,
        ki           => ex3_pp5_0k(249)                   ,
        ko           => ex3_pp5_0k(248)                   ,
        sum          => ex3_pp5_0s(249)                   ,
        car          => ex3_pp5_0c(248)                  );
    csa5_0_248: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(248)                   ,
        b            => ex3_pp4_0s(248)                   ,
        c            => ex3_recycle_c(248)                ,
        d            => ex3_recycle_s(248)                ,
        ki           => ex3_pp5_0k(248)                   ,
        ko           => ex3_pp5_0k(247)                   ,
        sum          => ex3_pp5_0s(248)                   ,
        car          => ex3_pp5_0c(247)                  );
    csa5_0_247: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(247)                   ,
        b            => ex3_pp4_0s(247)                   ,
        c            => ex3_recycle_c(247)                ,
        d            => ex3_recycle_s(247)                ,
        ki           => ex3_pp5_0k(247)                   ,
        ko           => ex3_pp5_0k(246)                   ,
        sum          => ex3_pp5_0s(247)                   ,
        car          => ex3_pp5_0c(246)                  );
    csa5_0_246: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(246)                   ,
        b            => ex3_pp4_0s(246)                   ,
        c            => ex3_recycle_c(246)                ,
        d            => ex3_recycle_s(246)                ,
        ki           => ex3_pp5_0k(246)                   ,
        ko           => ex3_pp5_0k(245)                   ,
        sum          => ex3_pp5_0s(246)                   ,
        car          => ex3_pp5_0c(245)                  );
    csa5_0_245: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(245)                   ,
        b            => ex3_pp4_0s(245)                   ,
        c            => ex3_recycle_c(245)                ,
        d            => ex3_recycle_s(245)                ,
        ki           => ex3_pp5_0k(245)                   ,
        ko           => ex3_pp5_0k(244)                   ,
        sum          => ex3_pp5_0s(245)                   ,
        car          => ex3_pp5_0c(244)                  );
    csa5_0_244: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(244)                   ,
        b            => ex3_pp4_0s(244)                   ,
        c            => ex3_recycle_c(244)                ,
        d            => ex3_recycle_s(244)                ,
        ki           => ex3_pp5_0k(244)                   ,
        ko           => ex3_pp5_0k(243)                   ,
        sum          => ex3_pp5_0s(244)                   ,
        car          => ex3_pp5_0c(243)                  );
    csa5_0_243: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(243)                   ,
        b            => ex3_pp4_0s(243)                   ,
        c            => ex3_recycle_c(243)                ,
        d            => ex3_recycle_s(243)                ,
        ki           => ex3_pp5_0k(243)                   ,
        ko           => ex3_pp5_0k(242)                   ,
        sum          => ex3_pp5_0s(243)                   ,
        car          => ex3_pp5_0c(242)                  );
    csa5_0_242: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(242)                   ,
        b            => ex3_pp4_0s(242)                   ,
        c            => ex3_recycle_c(242)                ,
        d            => ex3_recycle_s(242)                ,
        ki           => ex3_pp5_0k(242)                   ,
        ko           => ex3_pp5_0k(241)                   ,
        sum          => ex3_pp5_0s(242)                   ,
        car          => ex3_pp5_0c(241)                  );
    csa5_0_241: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(241)                   ,
        b            => ex3_pp4_0s(241)                   ,
        c            => ex3_recycle_c(241)                ,
        d            => ex3_recycle_s(241)                ,
        ki           => ex3_pp5_0k(241)                   ,
        ko           => ex3_pp5_0k(240)                   ,
        sum          => ex3_pp5_0s(241)                   ,
        car          => ex3_pp5_0c(240)                  );
    csa5_0_240: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(240)                   ,
        b            => ex3_pp4_0s(240)                   ,
        c            => ex3_recycle_c(240)                ,
        d            => ex3_recycle_s(240)                ,
        ki           => ex3_pp5_0k(240)                   ,
        ko           => ex3_pp5_0k(239)                   ,
        sum          => ex3_pp5_0s(240)                   ,
        car          => ex3_pp5_0c(239)                  );
    csa5_0_239: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(239)                   ,
        b            => ex3_pp4_0s(239)                   ,
        c            => ex3_recycle_c(239)                ,
        d            => ex3_recycle_s(239)                ,
        ki           => ex3_pp5_0k(239)                   ,
        ko           => ex3_pp5_0k(238)                   ,
        sum          => ex3_pp5_0s(239)                   ,
        car          => ex3_pp5_0c(238)                  );
    csa5_0_238: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(238)                   ,
        b            => ex3_pp4_0s(238)                   ,
        c            => ex3_recycle_c(238)                ,
        d            => ex3_recycle_s(238)                ,
        ki           => ex3_pp5_0k(238)                   ,
        ko           => ex3_pp5_0k(237)                   ,
        sum          => ex3_pp5_0s(238)                   ,
        car          => ex3_pp5_0c(237)                  );
    csa5_0_237: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(237)                   ,
        b            => ex3_pp4_0s(237)                   ,
        c            => ex3_recycle_c(237)                ,
        d            => ex3_recycle_s(237)                ,
        ki           => ex3_pp5_0k(237)                   ,
        ko           => ex3_pp5_0k(236)                   ,
        sum          => ex3_pp5_0s(237)                   ,
        car          => ex3_pp5_0c(236)                  );
    csa5_0_236: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(236)                   ,
        b            => ex3_pp4_0s(236)                   ,
        c            => ex3_recycle_c(236)                ,
        d            => ex3_recycle_s(236)                ,
        ki           => ex3_pp5_0k(236)                   ,
        ko           => ex3_pp5_0k(235)                   ,
        sum          => ex3_pp5_0s(236)                   ,
        car          => ex3_pp5_0c(235)                  );
    csa5_0_235: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(235)                   ,
        b            => ex3_pp4_0s(235)                   ,
        c            => ex3_recycle_c(235)                ,
        d            => ex3_recycle_s(235)                ,
        ki           => ex3_pp5_0k(235)                   ,
        ko           => ex3_pp5_0k(234)                   ,
        sum          => ex3_pp5_0s(235)                   ,
        car          => ex3_pp5_0c(234)                  );
    csa5_0_234: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(234)                   ,
        b            => ex3_pp4_0s(234)                   ,
        c            => ex3_recycle_c(234)                ,
        d            => ex3_recycle_s(234)                ,
        ki           => ex3_pp5_0k(234)                   ,
        ko           => ex3_pp5_0k(233)                   ,
        sum          => ex3_pp5_0s(234)                   ,
        car          => ex3_pp5_0c(233)                  );
    csa5_0_233: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(233)                   ,
        b            => ex3_pp4_0s(233)                   ,
        c            => ex3_recycle_c(233)                ,
        d            => ex3_recycle_s(233)                ,
        ki           => ex3_pp5_0k(233)                   ,
        ko           => ex3_pp5_0k(232)                   ,
        sum          => ex3_pp5_0s(233)                   ,
        car          => ex3_pp5_0c(232)                  );
    csa5_0_232: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(232)                   ,
        b            => ex3_pp4_0s(232)                   ,
        c            => ex3_recycle_c(232)                ,
        d            => ex3_recycle_s(232)                ,
        ki           => ex3_pp5_0k(232)                   ,
        ko           => ex3_pp5_0k(231)                   ,
        sum          => ex3_pp5_0s(232)                   ,
        car          => ex3_pp5_0c(231)                  );
    csa5_0_231: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(231)                   ,
        b            => ex3_pp4_0s(231)                   ,
        c            => ex3_recycle_c(231)                ,
        d            => ex3_recycle_s(231)                ,
        ki           => ex3_pp5_0k(231)                   ,
        ko           => ex3_pp5_0k(230)                   ,
        sum          => ex3_pp5_0s(231)                   ,
        car          => ex3_pp5_0c(230)                  );
    csa5_0_230: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(230)                   ,
        b            => ex3_pp4_0s(230)                   ,
        c            => ex3_recycle_c(230)                ,
        d            => ex3_recycle_s(230)                ,
        ki           => ex3_pp5_0k(230)                   ,
        ko           => ex3_pp5_0k(229)                   ,
        sum          => ex3_pp5_0s(230)                   ,
        car          => ex3_pp5_0c(229)                  );
    csa5_0_229: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(229)                   ,
        b            => ex3_pp4_0s(229)                   ,
        c            => ex3_recycle_c(229)                ,
        d            => ex3_recycle_s(229)                ,
        ki           => ex3_pp5_0k(229)                   ,
        ko           => ex3_pp5_0k(228)                   ,
        sum          => ex3_pp5_0s(229)                   ,
        car          => ex3_pp5_0c(228)                  );
    csa5_0_228: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(228)                   ,
        b            => ex3_pp4_0s(228)                   ,
        c            => ex3_recycle_c(228)                ,
        d            => ex3_recycle_s(228)                ,
        ki           => ex3_pp5_0k(228)                   ,
        ko           => ex3_pp5_0k(227)                   ,
        sum          => ex3_pp5_0s(228)                   ,
        car          => ex3_pp5_0c(227)                  );
    csa5_0_227: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(227)                   ,
        b            => ex3_pp4_0s(227)                   ,
        c            => ex3_recycle_c(227)                ,
        d            => ex3_recycle_s(227)                ,
        ki           => ex3_pp5_0k(227)                   ,
        ko           => ex3_pp5_0k(226)                   ,
        sum          => ex3_pp5_0s(227)                   ,
        car          => ex3_pp5_0c(226)                  );
    csa5_0_226: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(226)                   ,
        b            => ex3_pp4_0s(226)                   ,
        c            => ex3_recycle_c(226)                ,
        d            => ex3_recycle_s(226)                ,
        ki           => ex3_pp5_0k(226)                   ,
        ko           => ex3_pp5_0k(225)                   ,
        sum          => ex3_pp5_0s(226)                   ,
        car          => ex3_pp5_0c(225)                  );
    csa5_0_225: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(225)                   ,
        b            => ex3_pp4_0s(225)                   ,
        c            => ex3_recycle_c(225)                ,
        d            => ex3_recycle_s(225)                ,
        ki           => ex3_pp5_0k(225)                   ,
        ko           => ex3_pp5_0k(224)                   ,
        sum          => ex3_pp5_0s(225)                   ,
        car          => ex3_pp5_0c(224)                  );
    csa5_0_224: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(224)                   ,
        b            => ex3_pp4_0s(224)                   ,
        c            => ex3_recycle_c(224)                ,
        d            => ex3_recycle_s(224)                ,
        ki           => ex3_pp5_0k(224)                   ,
        ko           => ex3_pp5_0k(223)                   ,
        sum          => ex3_pp5_0s(224)                   ,
        car          => ex3_pp5_0c(223)                  );
    csa5_0_223: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(223)                   ,
        b            => ex3_pp4_0s(223)                   ,
        c            => ex3_recycle_c(223)                ,
        d            => ex3_recycle_s(223)                ,
        ki           => ex3_pp5_0k(223)                   ,
        ko           => ex3_pp5_0k(222)                   ,
        sum          => ex3_pp5_0s(223)                   ,
        car          => ex3_pp5_0c(222)                  );
    csa5_0_222: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(222)                   ,
        b            => ex3_pp4_0s(222)                   ,
        c            => ex3_recycle_c(222)                ,
        d            => ex3_recycle_s(222)                ,
        ki           => ex3_pp5_0k(222)                   ,
        ko           => ex3_pp5_0k(221)                   ,
        sum          => ex3_pp5_0s(222)                   ,
        car          => ex3_pp5_0c(221)                  );
    csa5_0_221: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(221)                   ,
        b            => ex3_pp4_0s(221)                   ,
        c            => ex3_recycle_c(221)                ,
        d            => ex3_recycle_s(221)                ,
        ki           => ex3_pp5_0k(221)                   ,
        ko           => ex3_pp5_0k(220)                   ,
        sum          => ex3_pp5_0s(221)                   ,
        car          => ex3_pp5_0c(220)                  );
    csa5_0_220: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(220)                   ,
        b            => ex3_pp4_0s(220)                   ,
        c            => ex3_recycle_c(220)                ,
        d            => ex3_recycle_s(220)                ,
        ki           => ex3_pp5_0k(220)                   ,
        ko           => ex3_pp5_0k(219)                   ,
        sum          => ex3_pp5_0s(220)                   ,
        car          => ex3_pp5_0c(219)                  );
    csa5_0_219: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(219)                   ,
        b            => ex3_pp4_0s(219)                   ,
        c            => ex3_recycle_c(219)                ,
        d            => ex3_recycle_s(219)                ,
        ki           => ex3_pp5_0k(219)                   ,
        ko           => ex3_pp5_0k(218)                   ,
        sum          => ex3_pp5_0s(219)                   ,
        car          => ex3_pp5_0c(218)                  );
    csa5_0_218: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(218)                   ,
        b            => ex3_pp4_0s(218)                   ,
        c            => ex3_recycle_c(218)                ,
        d            => ex3_recycle_s(218)                ,
        ki           => ex3_pp5_0k(218)                   ,
        ko           => ex3_pp5_0k(217)                   ,
        sum          => ex3_pp5_0s(218)                   ,
        car          => ex3_pp5_0c(217)                  );
    csa5_0_217: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(217)                   ,
        b            => ex3_pp4_0s(217)                   ,
        c            => ex3_recycle_c(217)                ,
        d            => ex3_recycle_s(217)                ,
        ki           => ex3_pp5_0k(217)                   ,
        ko           => ex3_pp5_0k(216)                   ,
        sum          => ex3_pp5_0s(217)                   ,
        car          => ex3_pp5_0c(216)                  );
    csa5_0_216: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(216)                   ,
        b            => ex3_pp4_0s(216)                   ,
        c            => ex3_recycle_c(216)                ,
        d            => ex3_recycle_s(216)                ,
        ki           => ex3_pp5_0k(216)                   ,
        ko           => ex3_pp5_0k(215)                   ,
        sum          => ex3_pp5_0s(216)                   ,
        car          => ex3_pp5_0c(215)                  );
    csa5_0_215: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(215)                   ,
        b            => ex3_pp4_0s(215)                   ,
        c            => ex3_recycle_c(215)                ,
        d            => ex3_recycle_s(215)                ,
        ki           => ex3_pp5_0k(215)                   ,
        ko           => ex3_pp5_0k(214)                   ,
        sum          => ex3_pp5_0s(215)                   ,
        car          => ex3_pp5_0c(214)                  );
    csa5_0_214: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(214)                   ,
        b            => ex3_pp4_0s(214)                   ,
        c            => ex3_recycle_c(214)                ,
        d            => ex3_recycle_s(214)                ,
        ki           => ex3_pp5_0k(214)                   ,
        ko           => ex3_pp5_0k(213)                   ,
        sum          => ex3_pp5_0s(214)                   ,
        car          => ex3_pp5_0c(213)                  );
    csa5_0_213: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(213)                   ,
        b            => ex3_pp4_0s(213)                   ,
        c            => ex3_recycle_c(213)                ,
        d            => ex3_recycle_s(213)                ,
        ki           => ex3_pp5_0k(213)                   ,
        ko           => ex3_pp5_0k(212)                   ,
        sum          => ex3_pp5_0s(213)                   ,
        car          => ex3_pp5_0c(212)                  );
    csa5_0_212: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(212)                   ,
        b            => ex3_pp4_0s(212)                   ,
        c            => ex3_recycle_c(212)                ,
        d            => ex3_recycle_s(212)                ,
        ki           => ex3_pp5_0k(212)                   ,
        ko           => ex3_pp5_0k(211)                   ,
        sum          => ex3_pp5_0s(212)                   ,
        car          => ex3_pp5_0c(211)                  );
    csa5_0_211: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(211)                   ,
        b            => ex3_pp4_0s(211)                   ,
        c            => ex3_recycle_c(211)                ,
        d            => ex3_recycle_s(211)                ,
        ki           => ex3_pp5_0k(211)                   ,
        ko           => ex3_pp5_0k(210)                   ,
        sum          => ex3_pp5_0s(211)                   ,
        car          => ex3_pp5_0c(210)                  );
    csa5_0_210: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(210)                   ,
        b            => ex3_pp4_0s(210)                   ,
        c            => ex3_recycle_c(210)                ,
        d            => ex3_recycle_s(210)                ,
        ki           => ex3_pp5_0k(210)                   ,
        ko           => ex3_pp5_0k(209)                   ,
        sum          => ex3_pp5_0s(210)                   ,
        car          => ex3_pp5_0c(209)                  );
    csa5_0_209: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(209)                   ,
        b            => ex3_pp4_0s(209)                   ,
        c            => ex3_recycle_c(209)                ,
        d            => ex3_recycle_s(209)                ,
        ki           => ex3_pp5_0k(209)                   ,
        ko           => ex3_pp5_0k(208)                   ,
        sum          => ex3_pp5_0s(209)                   ,
        car          => ex3_pp5_0c(208)                  );
    csa5_0_208: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(208)                   ,
        b            => ex3_pp4_0s(208)                   ,
        c            => ex3_recycle_c(208)                ,
        d            => ex3_recycle_s(208)                ,
        ki           => ex3_pp5_0k(208)                   ,
        ko           => ex3_pp5_0k(207)                   ,
        sum          => ex3_pp5_0s(208)                   ,
        car          => ex3_pp5_0c(207)                  );
    csa5_0_207: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(207)                   ,
        b            => ex3_pp4_0s(207)                   ,
        c            => ex3_recycle_c(207)                ,
        d            => ex3_recycle_s(207)                ,
        ki           => ex3_pp5_0k(207)                   ,
        ko           => ex3_pp5_0k(206)                   ,
        sum          => ex3_pp5_0s(207)                   ,
        car          => ex3_pp5_0c(206)                  );
    csa5_0_206: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(206)                   ,
        b            => ex3_pp4_0s(206)                   ,
        c            => ex3_recycle_c(206)                ,
        d            => ex3_recycle_s(206)                ,
        ki           => ex3_pp5_0k(206)                   ,
        ko           => ex3_pp5_0k(205)                   ,
        sum          => ex3_pp5_0s(206)                   ,
        car          => ex3_pp5_0c(205)                  );
    csa5_0_205: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(205)                   ,
        b            => ex3_pp4_0s(205)                   ,
        c            => ex3_recycle_c(205)                ,
        d            => ex3_recycle_s(205)                ,
        ki           => ex3_pp5_0k(205)                   ,
        ko           => ex3_pp5_0k(204)                   ,
        sum          => ex3_pp5_0s(205)                   ,
        car          => ex3_pp5_0c(204)                  );
    csa5_0_204: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(204)                   ,
        b            => ex3_pp4_0s(204)                   ,
        c            => ex3_recycle_c(204)                ,
        d            => ex3_recycle_s(204)                ,
        ki           => ex3_pp5_0k(204)                   ,
        ko           => ex3_pp5_0k(203)                   ,
        sum          => ex3_pp5_0s(204)                   ,
        car          => ex3_pp5_0c(203)                  );
    csa5_0_203: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(203)                   ,
        b            => ex3_pp4_0s(203)                   ,
        c            => ex3_recycle_c(203)                ,
        d            => ex3_recycle_s(203)                ,
        ki           => ex3_pp5_0k(203)                   ,
        ko           => ex3_pp5_0k(202)                   ,
        sum          => ex3_pp5_0s(203)                   ,
        car          => ex3_pp5_0c(202)                  );
    csa5_0_202: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(202)                   ,
        b            => ex3_pp4_0s(202)                   ,
        c            => ex3_recycle_c(202)                ,
        d            => ex3_recycle_s(202)                ,
        ki           => ex3_pp5_0k(202)                   ,
        ko           => ex3_pp5_0k(201)                   ,
        sum          => ex3_pp5_0s(202)                   ,
        car          => ex3_pp5_0c(201)                  );
    csa5_0_201: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(201)                   ,
        b            => ex3_pp4_0s(201)                   ,
        c            => ex3_recycle_c(201)                ,
        d            => ex3_recycle_s(201)                ,
        ki           => ex3_pp5_0k(201)                   ,
        ko           => ex3_pp5_0k(200)                   ,
        sum          => ex3_pp5_0s(201)                   ,
        car          => ex3_pp5_0c(200)                  );
    csa5_0_200: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(200)                   ,
        b            => ex3_pp4_0s(200)                   ,
        c            => ex3_recycle_c(200)                ,
        d            => ex3_recycle_s(200)                ,
        ki           => ex3_pp5_0k(200)                   ,
        ko           => ex3_pp5_0k(199)                   ,
        sum          => ex3_pp5_0s(200)                   ,
        car          => ex3_pp5_0c(199)                  );
    csa5_0_199: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(199)                   ,
        b            => ex3_pp4_0s(199)                   ,
        c            => ex3_recycle_c(199)                ,
        d            => ex3_recycle_s(199)                ,
        ki           => ex3_pp5_0k(199)                   ,
        ko           => ex3_pp5_0k(198)                   ,
        sum          => ex3_pp5_0s(199)                   ,
        car          => ex3_pp5_0c(198)                  );
    csa5_0_198: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(198)                   ,
        b            => ex3_pp4_0s(198)                   ,
        c            => ex3_recycle_c(198)                ,
        d            => ex3_recycle_s(198)                ,
        ki           => ex3_pp5_0k(198)                   ,
        ko           => ex3_pp5_0k(197)                   ,
        sum          => ex3_pp5_0s(198)                   ,
        car          => ex3_pp5_0c(197)                  );
    csa5_0_197: entity clib.c_prism_csa42 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_pp4_0c(197)                   ,
        b            => ex3_pp4_0s(197)                   ,
        c            => ex3_recycle_c(197)                ,
        d            => ex3_recycle_s(197)                ,
        ki           => ex3_pp5_0k(197)                   ,
        ko           => ex3_pp5_0k(196)                   ,
        sum          => ex3_pp5_0s(197)                   ,
        car          => ex3_pp5_0c(196)                  );
    csa5_0_196: entity clib.c_prism_csa32 port map(
        vd           => vdd,
        gd           => gnd,
        a            => ex3_recycle_c(196)                ,
        b            => ex3_recycle_s(196)                ,
        c            => ex3_pp5_0k(196)                   ,
        sum          => ex3_pp5_0s(196)                   ,
        car          => ex3_pp5_0c(195)                  );




   ex4_pp5_0s_din(196 to 264) <= ex3_pp5_0s(196 to 264);
   ex4_pp5_0c_din(196 to 263) <= ex3_pp5_0c(196 to 263);


  u_sum_qi: ex4_pp5_0s(196 to 264) <= not ex4_pp5_0s_q_b(196 to 264) ;
  u_car_qi: ex4_pp5_0c(196 to 263) <= not ex4_pp5_0c_q_b(196 to 263) ;

  ex4_pp5_0s_out(196 to 264) <= ex4_pp5_0s(196 to 264) ; 
  ex4_pp5_0c_out(196 to 263) <= ex4_pp5_0c(196 to 263) ; 




    ex3_lcb: tri_lcbnd generic map (expand_type => expand_type) port map (
        delay_lclkr =>  delay_lclkr_dc     ,
        mpw1_b      =>  mpw1_dc_b          ,
        mpw2_b      =>  mpw2_dc_b          ,
        forcee =>  func_sl_force      ,
        nclk        =>  nclk               ,
        vd          =>  vdd                ,
        gd          =>  gnd                ,
        act         =>  ex2_act            ,
        sg          =>  sg_0               ,
        thold_b     =>  func_sl_thold_0_b  ,
        d1clk       =>  ex3_d1clk          ,
        d2clk       =>  ex3_d2clk          ,
        lclk        =>  ex3_lclk          );

    ex4_lcb: tri_lcbnd generic map (expand_type => expand_type) port map (
        delay_lclkr =>  delay_lclkr_dc     ,
        mpw1_b      =>  mpw1_dc_b          ,
        mpw2_b      =>  mpw2_dc_b          ,
        forcee =>  func_sl_force      ,
        nclk        =>  nclk               ,
        vd          =>  vdd                ,
        gd          =>  gnd                ,
        act         =>  ex3_act            ,
        sg          =>  sg_0               ,
        thold_b     =>  func_sl_thold_0_b  ,
        d1clk       =>  ex4_d1clk          ,
        d2clk       =>  ex4_d2clk          ,
        lclk        =>  ex4_lclk          );



    ex3_pp2_0s_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 45,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 45=>'0')) port map (
        VD               => vdd                          ,
        GD               => gnd                          ,
        LCLK             => ex3_lclk                     ,
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_0s_lat_si            ,
        SCANOUT          => ex3_pp2_0s_lat_so            ,
        D                => ex3_pp2_0s_din(198 to 242)   ,
        QB               => ex3_pp2_0s_q_b(198 to 242)  );
    ex3_pp2_0c_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 43,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 43=>'0')   ) port map (
        VD               => vdd                          ,
        GD               => gnd                          ,
        LCLK             => ex3_lclk                     ,
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_0c_lat_si            ,
        SCANOUT          => ex3_pp2_0c_lat_so            ,
        D                => ex3_pp2_0c_din(198 to 240)   ,
        QB               => ex3_pp2_0c_q_b(198 to 240)  );

    ex3_pp2_1s_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 47,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 47=>'0')   ) port map (
        VD               => vdd                          ,
        GD               => gnd                          ,
        LCLK             => ex3_lclk                     ,
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_1s_lat_si            ,
        SCANOUT          => ex3_pp2_1s_lat_so            ,
        D                => ex3_pp2_1s_din(208 to 254)   ,
        QB               => ex3_pp2_1s_q_b(208 to 254)  );

    ex3_pp2_1c_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 45,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 45=>'0')   ) port map (
        VD               => vdd                          ,
        GD               => gnd                          ,
        LCLK             => ex3_lclk                     ,
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_1c_lat_si            ,
        SCANOUT          => ex3_pp2_1c_lat_so            ,
        D                => ex3_pp2_1c_din(208 to 252)   ,
        QB               => ex3_pp2_1c_q_b(208 to 252)  );

    ex3_pp2_2s_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 45,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 45=>'0')   ) port map (
        VD               => vdd                          ,
        GD               => gnd                          ,
        LCLK             => ex3_lclk                     ,
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_2s_lat_si            ,
        SCANOUT          => ex3_pp2_2s_lat_so            ,
        D                => ex3_pp2_2s_din(220 to 264)   ,
        QB               => ex3_pp2_2s_q_b(220 to 264)  );

    ex3_pp2_2c_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 44,btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 44=>'0')   ) port map (
        VD               => vdd                          ,
        GD               => gnd                          ,
        LCLK             => ex3_lclk                     ,
        D1CLK            => ex3_d1clk                    ,
        D2CLK            => ex3_d2clk                    ,
        SCANIN           => ex3_pp2_2c_lat_si            ,
        SCANOUT          => ex3_pp2_2c_lat_so            ,
        D                => ex3_pp2_2c_din(220 to 263)   ,
        QB               => ex3_pp2_2c_q_b(220 to 263)  );


    ex4_pp5_0s_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 69,btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 69=>'0')   ) port map (
        VD               => vdd                          ,
        GD               => gnd                          ,
        LCLK             => ex4_lclk                     ,
        D1CLK            => ex4_d1clk                    ,
        D2CLK            => ex4_d2clk                    ,
        SCANIN           => ex4_pp5_0s_lat_si            ,
        SCANOUT          => ex4_pp5_0s_lat_so            ,
        D                => ex4_pp5_0s_din(196 to 264)   ,
        QB               => ex4_pp5_0s_q_b(196 to 264)  );

    ex4_pp5_0c_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 68,btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0, init=>(1 to 68=>'0')   ) port map (
        VD               => vdd                          ,
        GD               => gnd                          ,
        LCLK             => ex4_lclk                     ,
        D1CLK            => ex4_d1clk                    ,
        D2CLK            => ex4_d2clk                    ,
        SCANIN           => ex4_pp5_0c_lat_si            ,
        SCANOUT          => ex4_pp5_0c_lat_so            ,
        D                => ex4_pp5_0c_din(196 to 263)   ,
        QB               => ex4_pp5_0c_q_b(196 to 263)  );






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

