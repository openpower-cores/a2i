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
 library clib ;

entity fuq_alg_add is
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(

    vdd              : inout power_logic;                  
    gnd              : inout power_logic;                  

       f_byp_alg_ex1_b_expo      :in  std_ulogic_vector(1 to 13);
       f_byp_alg_ex1_a_expo      :in  std_ulogic_vector(1 to 13);
       f_byp_alg_ex1_c_expo      :in  std_ulogic_vector(1 to 13);

       ex1_sel_special_b         :in  std_ulogic ;

       ex1_bsha_6_o              :out std_ulogic ;
       ex1_bsha_7_o              :out std_ulogic ;
       ex1_bsha_8_o              :out std_ulogic ;
       ex1_bsha_9_o              :out std_ulogic ;

       ex1_bsha_neg_o            :out std_ulogic ;
       ex1_sh_ovf                :out std_ulogic ;
       ex1_sh_unf_x              :out std_ulogic ;


       ex1_lvl1_shdcd000_b       :out std_ulogic ;
       ex1_lvl1_shdcd001_b       :out std_ulogic ;
       ex1_lvl1_shdcd002_b       :out std_ulogic ;
       ex1_lvl1_shdcd003_b       :out std_ulogic ;

       ex1_lvl2_shdcd000         :out std_ulogic ;
       ex1_lvl2_shdcd004         :out std_ulogic ;
       ex1_lvl2_shdcd008         :out std_ulogic ;
       ex1_lvl2_shdcd012         :out std_ulogic ;

       ex1_lvl3_shdcd000         :out std_ulogic ;-- 0000  +000
       ex1_lvl3_shdcd016         :out std_ulogic ;-- 0001  +016
       ex1_lvl3_shdcd032         :out std_ulogic ;-- 0010  +032
       ex1_lvl3_shdcd048         :out std_ulogic ;-- 0011  +048
       ex1_lvl3_shdcd064         :out std_ulogic ;-- 0100  +064
       ex1_lvl3_shdcd080         :out std_ulogic ;-- 0101  +080
       ex1_lvl3_shdcd096         :out std_ulogic ;-- 0110  +096
       ex1_lvl3_shdcd112         :out std_ulogic ;-- 0111  +112
       ex1_lvl3_shdcd128         :out std_ulogic ;-- 1000  +128
       ex1_lvl3_shdcd144         :out std_ulogic ;-- 1001  +144
       ex1_lvl3_shdcd160         :out std_ulogic ;-- 1010  +160
       ex1_lvl3_shdcd176         :out std_ulogic ;-- 1011
       ex1_lvl3_shdcd192         :out std_ulogic ;-- 1100  -064
       ex1_lvl3_shdcd208         :out std_ulogic ;-- 1101  -048
       ex1_lvl3_shdcd224         :out std_ulogic ;-- 1110  -032
       ex1_lvl3_shdcd240         :out std_ulogic  -- 1111  -016
); -------------------------------------------------------------------



end fuq_alg_add; 

architecture fuq_alg_add of fuq_alg_add is

  constant tiup :std_ulogic := '1';
  constant tidn :std_ulogic := '0';
  signal ex1_bsha_sim_c :std_ulogic_vector(2 to 14); 
  signal ex1_bsha_sim_p :std_ulogic_vector(1 to 13);
  signal ex1_bsha_sim_g :std_ulogic_vector(2 to 13);
  signal ex1_bsha_sim   :std_ulogic_vector(1 to 13);

  signal ex1_b_expo_b :std_ulogic_vector(1 to 13);
  signal ex1_a_expo_b :std_ulogic_vector(2 to 13);
  signal ex1_c_expo_b :std_ulogic_vector(2 to 13);
  signal ex1_bsha_neg :std_ulogic;
  signal ex1_sh_ovf_b  :std_ulogic;
  signal ex1_alg_sx             :std_ulogic_vector(1 to 13)   ;
  signal ex1_alg_cx             :std_ulogic_vector(0 to 12)   ;
  signal ex1_alg_add_p          :std_ulogic_vector(1 to 12)   ;
  signal ex1_alg_add_g_b        :std_ulogic_vector(2 to 12)   ;
  signal ex1_alg_add_t_b        :std_ulogic_vector(2 to 11)   ;

  signal ex1_bsha_6_b   :std_ulogic;
  signal ex1_bsha_7_b   :std_ulogic;
  signal ex1_bsha_8_b   :std_ulogic;
  signal ex1_bsha_9_b   :std_ulogic;
  signal ex1_67_dcd00_b :std_ulogic;
  signal ex1_67_dcd01_b :std_ulogic;
  signal ex1_67_dcd10_b :std_ulogic;
  signal ex1_67_dcd11_b :std_ulogic;
  signal ex1_89_dcd00_b :std_ulogic;
  signal ex1_89_dcd01_b :std_ulogic;
  signal ex1_89_dcd10_b :std_ulogic;
  signal ex1_89_dcd11_b :std_ulogic;

  signal ex1_lv2_0pg0_b      :std_ulogic;
  signal ex1_lv2_0pg1_b      :std_ulogic;
  signal ex1_lv2_0pk0_b      :std_ulogic;
  signal ex1_lv2_0pk1_b      :std_ulogic;
  signal ex1_lv2_0pp0_b      :std_ulogic;
  signal ex1_lv2_0pp1_b      :std_ulogic;
  signal ex1_lv2_1pg0_b      :std_ulogic;
  signal ex1_lv2_1pg1_b      :std_ulogic;
  signal ex1_lv2_1pk0_b      :std_ulogic;
  signal ex1_lv2_1pk1_b      :std_ulogic;
  signal ex1_lv2_1pp0_b      :std_ulogic;
  signal ex1_lv2_1pp1_b      :std_ulogic;
  signal ex1_lv2_shdcd000    :std_ulogic;
  signal ex1_lv2_shdcd004    :std_ulogic;
  signal ex1_lv2_shdcd008    :std_ulogic;
  signal ex1_lv2_shdcd012    :std_ulogic;
  signal ex1_lvl2_shdcd000_b :std_ulogic;
  signal ex1_lvl2_shdcd004_b :std_ulogic;
  signal ex1_lvl2_shdcd008_b :std_ulogic;
  signal ex1_lvl2_shdcd012_b :std_ulogic;

  signal  ex1_alg_add_c_b :std_ulogic_vector(7 to 10);
  signal  ex1_g02_12         :std_ulogic;
  signal  ex1_g02_12_b       :std_ulogic;
  signal  ex1_bsha_13_b      :std_ulogic;
  signal  ex1_bsha_13        :std_ulogic;
  signal  ex1_bsha_12_b      :std_ulogic;
  signal  ex1_bsha_12        :std_ulogic;
  signal  ex1_lv2_ci11n_en_b :std_ulogic;
  signal  ex1_lv2_ci11p_en_b :std_ulogic;
  signal  ex1_lv2_ci11n_en   :std_ulogic;
  signal  ex1_lv2_ci11p_en   :std_ulogic;
  signal  ex1_g02_10         :std_ulogic;
  signal  ex1_t02_10         :std_ulogic;
  signal  ex1_g04_10_b       :std_ulogic;
  signal  ex1_lv2_g11_x      :std_ulogic;
  signal  ex1_lv2_g11_b      :std_ulogic;
  signal  ex1_lv2_g11        :std_ulogic;
  signal  ex1_lv2_k11_b      :std_ulogic;
  signal  ex1_lv2_k11        :std_ulogic;
  signal  ex1_lv2_p11_b      :std_ulogic;
  signal  ex1_lv2_p11        :std_ulogic;
  signal  ex1_lv2_p10_b      :std_ulogic;
  signal  ex1_lv2_p10        :std_ulogic;
  signal  ex1_g04_10  :std_ulogic;
  signal  ex1_g02_6   :std_ulogic;
  signal  ex1_g02_7   :std_ulogic;
  signal  ex1_g02_8   :std_ulogic;
  signal  ex1_g02_9   :std_ulogic;
  signal  ex1_t02_6   :std_ulogic;
  signal  ex1_t02_7   :std_ulogic;
  signal  ex1_t02_8   :std_ulogic;
  signal  ex1_t02_9   :std_ulogic;
  signal  ex1_g04_6_b :std_ulogic;
  signal  ex1_g04_7_b :std_ulogic;
  signal  ex1_g04_8_b :std_ulogic;
  signal  ex1_g04_9_b :std_ulogic;
  signal  ex1_t04_6_b :std_ulogic;
  signal  ex1_t04_7_b :std_ulogic;
  signal  ex1_t04_8_b :std_ulogic;
  signal  ex1_t04_9_b :std_ulogic;
  signal  ex1_g08_6   :std_ulogic;
  signal  ex1_g04_7   :std_ulogic;
  signal  ex1_g04_8   :std_ulogic;
  signal  ex1_g04_9   :std_ulogic;
  signal  ex1_t04_7   :std_ulogic;
  signal  ex1_t04_8   :std_ulogic;
  signal  ex1_t04_9   :std_ulogic;
  signal  ex1_bsha_6    :std_ulogic;
  signal  ex1_bsha_7    :std_ulogic;
  signal  ex1_bsha_8    :std_ulogic;
  signal  ex1_bsha_9    :std_ulogic;
  signal  ex1_g02_4    :std_ulogic;
  signal  ex1_g02_2    :std_ulogic;
  signal  ex1_t02_4    :std_ulogic;
  signal  ex1_t02_2    :std_ulogic;
  signal  ex1_g04_2_b  :std_ulogic;
  signal  ex1_t04_2_b  :std_ulogic;
  signal  ex1_ones_2t3_b :std_ulogic;
  signal  ex1_ones_4t5_b :std_ulogic;
  signal  ex1_ones_2t5   :std_ulogic;
  signal  ex1_ones_2t5_b :std_ulogic;
  signal  ex1_zero_2_b   :std_ulogic;
  signal  ex1_zero_3_b   :std_ulogic;
  signal  ex1_zero_4_b   :std_ulogic;
  signal  ex1_zero_5     :std_ulogic;
  signal  ex1_zero_5_b   :std_ulogic;
  signal  ex1_zero_2t3   :std_ulogic;
  signal  ex1_zero_4t5   :std_ulogic;
  signal  ex1_zero_2t5_b :std_ulogic;
  signal  pos_if_pco6   :std_ulogic;
  signal  pos_if_nco6   :std_ulogic;
  signal  pos_if_pco6_b :std_ulogic;
  signal  pos_if_nco6_b :std_ulogic;
  signal  unf_if_nco6_b :std_ulogic;
  signal  unf_if_pco6_b :std_ulogic;
  signal  ex1_g08_6_b   :std_ulogic;
  signal  ex1_bsha_pos  :std_ulogic;
  signal  ex1_bsha_6_i  :std_ulogic;
  signal  ex1_bsha_7_i  :std_ulogic;
  signal  ex1_bsha_8_i  :std_ulogic;
  signal  ex1_bsha_9_i  :std_ulogic;
  signal ex1_ack_s :std_ulogic_vector(1 to 13);
  signal ex1_ack_c :std_ulogic_vector(1 to 12);

 


begin

    -------------------------------------------------------
    -- FOR simulation only : will not generate any logic
    -------------------------------------------------------


    ex1_bsha_sim_p(1 to 12) <= ex1_alg_sx(1 to 12) xor ex1_alg_cx(1 to 12);
    ex1_bsha_sim_p(     13) <= ex1_alg_sx(     13) ;
    ex1_bsha_sim_g(2 to 12) <= ex1_alg_sx(2 to 12) and ex1_alg_cx(2 to 12);
    ex1_bsha_sim_g(13)      <= tidn;
    ex1_bsha_sim  (1 to 13) <= ex1_bsha_sim_p(1 to 13) xor ex1_bsha_sim_c(2 to 14);

    ex1_bsha_sim_c(14) <= tidn;
    ex1_bsha_sim_c(13) <= ex1_bsha_sim_g(13) or (ex1_bsha_sim_p(13) and ex1_bsha_sim_c(14) );
    ex1_bsha_sim_c(12) <= ex1_bsha_sim_g(12) or (ex1_bsha_sim_p(12) and ex1_bsha_sim_c(13) );
    ex1_bsha_sim_c(11) <= ex1_bsha_sim_g(11) or (ex1_bsha_sim_p(11) and ex1_bsha_sim_c(12) );
    ex1_bsha_sim_c(10) <= ex1_bsha_sim_g(10) or (ex1_bsha_sim_p(10) and ex1_bsha_sim_c(11) );
    ex1_bsha_sim_c( 9) <= ex1_bsha_sim_g( 9) or (ex1_bsha_sim_p( 9) and ex1_bsha_sim_c(10) );
    ex1_bsha_sim_c( 8) <= ex1_bsha_sim_g( 8) or (ex1_bsha_sim_p( 8) and ex1_bsha_sim_c( 9) );
    ex1_bsha_sim_c( 7) <= ex1_bsha_sim_g( 7) or (ex1_bsha_sim_p( 7) and ex1_bsha_sim_c( 8) );
    ex1_bsha_sim_c( 6) <= ex1_bsha_sim_g( 6) or (ex1_bsha_sim_p( 6) and ex1_bsha_sim_c( 7) );
    ex1_bsha_sim_c( 5) <= ex1_bsha_sim_g( 5) or (ex1_bsha_sim_p( 5) and ex1_bsha_sim_c( 6) );
    ex1_bsha_sim_c( 4) <= ex1_bsha_sim_g( 4) or (ex1_bsha_sim_p( 4) and ex1_bsha_sim_c( 5) );
    ex1_bsha_sim_c( 3) <= ex1_bsha_sim_g( 3) or (ex1_bsha_sim_p( 3) and ex1_bsha_sim_c( 4) );
    ex1_bsha_sim_c( 2) <= ex1_bsha_sim_g( 2) or (ex1_bsha_sim_p( 2) and ex1_bsha_sim_c( 3) );


--==##############################################################
--# ex1 logic
--==##############################################################
       -- for MADD operations SHA = (Ea+Ec+!Eb) + 1 -bias + 56
       --                           (Ea+Ec+!Eb) + 57 +!bias + 1
       --                           (Ea+Ec+!Eb) + 58 +!bias
       -- 0_0011_1111_1111  bias = 1023
       -- 1_1100_0000_0000 !bias
       --          11_1010 58
       -- -----------------------
       -- 1_1100_0011_1010  ( !bias + 58 )
       --
       -- leading bit [1] is a sign bit, but the compressor creates bit 0.
       -- 13 bits should be enough to hold the entire result, therefore throw away bit 0.


 a32_inv: ex1_a_expo_b(2 to 13) <= not f_byp_alg_ex1_a_expo(2 to 13);
 c32_inv: ex1_c_expo_b(2 to 13) <= not f_byp_alg_ex1_c_expo(2 to 13);
 b32_inv: ex1_b_expo_b(1 to 13) <= not f_byp_alg_ex1_b_expo(1 to 13); 

sx01:  ex1_ack_s( 1) <= not( f_byp_alg_ex1_a_expo( 1) xor  f_byp_alg_ex1_c_expo( 1) ); --K[ 1]==1
sx02:  ex1_ack_s( 2) <= not( f_byp_alg_ex1_a_expo( 2) xor  f_byp_alg_ex1_c_expo( 2) ); --K[ 2]==1
sx03:  ex1_ack_s( 3) <= not( f_byp_alg_ex1_a_expo( 3) xor  f_byp_alg_ex1_c_expo( 3) ); --K[ 3]==1
sx04:  ex1_ack_s( 4) <=    ( f_byp_alg_ex1_a_expo( 4) xor  f_byp_alg_ex1_c_expo( 4) ); --K[ 4]==0
sx05:  ex1_ack_s( 5) <=    ( f_byp_alg_ex1_a_expo( 5) xor  f_byp_alg_ex1_c_expo( 5) ); --K[ 5]==0
sx06:  ex1_ack_s( 6) <=    ( f_byp_alg_ex1_a_expo( 6) xor  f_byp_alg_ex1_c_expo( 6) ); --K[ 6]==0
sx07:  ex1_ack_s( 7) <=    ( f_byp_alg_ex1_a_expo( 7) xor  f_byp_alg_ex1_c_expo( 7) ); --K[ 7]==0
sx08:  ex1_ack_s( 8) <= not( f_byp_alg_ex1_a_expo( 8) xor  f_byp_alg_ex1_c_expo( 8) ); --K[ 8]==1
sx09:  ex1_ack_s( 9) <= not( f_byp_alg_ex1_a_expo( 9) xor  f_byp_alg_ex1_c_expo( 9) ); --K[ 9]==1  1
sx10:  ex1_ack_s(10) <= not( f_byp_alg_ex1_a_expo(10) xor  f_byp_alg_ex1_c_expo(10) ); --K[10]==1  1
sx11:  ex1_ack_s(11) <=    ( f_byp_alg_ex1_a_expo(11) xor  f_byp_alg_ex1_c_expo(11) ); --K[11]==0
sx12:  ex1_ack_s(12) <= not( f_byp_alg_ex1_a_expo(12) xor  f_byp_alg_ex1_c_expo(12) ); --K[12]==1
sx13:  ex1_ack_s(13) <=    ( f_byp_alg_ex1_a_expo(13) xor  f_byp_alg_ex1_c_expo(13) ); --K[13]==0



-- cx00: ex1_ack_c( 0) <= not( ex1_a_expo_b( 1) and  ex1_c_expo_b( 1) ); --K[ 1]==1 +or
 cx01: ex1_ack_c( 1) <= not( ex1_a_expo_b( 2) and  ex1_c_expo_b( 2) ); --K[ 2]==1 +or
 cx02: ex1_ack_c( 2) <= not( ex1_a_expo_b( 3) and  ex1_c_expo_b( 3) ); --K[ 3]==1 +or
 cx03: ex1_ack_c( 3) <= not( ex1_a_expo_b( 4) or   ex1_c_expo_b( 4) ); --K[ 4]==0 +and
 cx04: ex1_ack_c( 4) <= not( ex1_a_expo_b( 5) or   ex1_c_expo_b( 5) ); --K[ 5]==0 +and
 cx05: ex1_ack_c( 5) <= not( ex1_a_expo_b( 6) or   ex1_c_expo_b( 6) ); --K[ 6]==0 +and
 cx06: ex1_ack_c( 6) <= not( ex1_a_expo_b( 7) or   ex1_c_expo_b( 7) ); --K[ 7]==0 +and
 cx07: ex1_ack_c( 7) <= not( ex1_a_expo_b( 8) and  ex1_c_expo_b( 8) ); --K[ 8]==1 +or
 cx08: ex1_ack_c( 8) <= not( ex1_a_expo_b( 9) and  ex1_c_expo_b( 9) ); --K[ 9]==1 +or
 cx09: ex1_ack_c( 9) <= not( ex1_a_expo_b(10) and  ex1_c_expo_b(10) ); --K[10]==1 +or
 cx10: ex1_ack_c(10) <= not( ex1_a_expo_b(11) or   ex1_c_expo_b(11) ); --K[11]==0 +and
 cx11: ex1_ack_c(11) <= not( ex1_a_expo_b(12) and  ex1_c_expo_b(12) ); --K[12]==1 +or
 cx12: ex1_ack_c(12) <= not( ex1_a_expo_b(13) or   ex1_c_expo_b(13) ); --K[13]==0


 
  


sha32_01: entity clib.c_prism_csa32  port map( -- fuq_csa32s_h2 MLT32_X1_A12TH
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(1)   ,--i--
        b                =>            ex1_ack_s(1)   ,--i--
        c                =>            ex1_ack_c(1)   ,--i--
        sum              =>           ex1_alg_sx(1)   ,--o--
        car              =>           ex1_alg_cx(0)  );--o--
sha32_02: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(2)   ,--i--
        b                =>            ex1_ack_s(2)   ,--i--
        c                =>            ex1_ack_c(2)   ,--i--
        sum              =>           ex1_alg_sx(2)   ,--o--
        car              =>           ex1_alg_cx(1)  );--o--
sha32_03: entity clib.c_prism_csa32  port map(
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(3)   ,--i--
        b                =>            ex1_ack_s(3)   ,--i--
        c                =>            ex1_ack_c(3)   ,--i--
        sum              =>           ex1_alg_sx(3)   ,--o--
        car              =>           ex1_alg_cx(2)  );--o--
sha32_04: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(4)   ,--i--
        b                =>            ex1_ack_s(4)   ,--i--
        c                =>            ex1_ack_c(4)   ,--i--
        sum              =>           ex1_alg_sx(4)   ,--o--
        car              =>           ex1_alg_cx(3)  );--o--
sha32_05: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(5)   ,--i--
        b                =>            ex1_ack_s(5)   ,--i--
        c                =>            ex1_ack_c(5)   ,--i--
        sum              =>           ex1_alg_sx(5)   ,--o--
        car              =>           ex1_alg_cx(4)  );--o--
sha32_06: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(6)   ,--i--
        b                =>            ex1_ack_s(6)   ,--i--
        c                =>            ex1_ack_c(6)   ,--i--
        sum              =>           ex1_alg_sx(6)   ,--o--
        car              =>           ex1_alg_cx(5)  );--o--
sha32_07: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(7)   ,--i--
        b                =>            ex1_ack_s(7)   ,--i--
        c                =>            ex1_ack_c(7)   ,--i--
        sum              =>           ex1_alg_sx(7)   ,--o--
        car              =>           ex1_alg_cx(6)  );--o--
sha32_08: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(8)   ,--i--
        b                =>            ex1_ack_s(8)   ,--i--
        c                =>            ex1_ack_c(8)   ,--i--
        sum              =>           ex1_alg_sx(8)   ,--o--
        car              =>           ex1_alg_cx(7)  );--o--
sha32_09: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(9)   ,--i--
        b                =>            ex1_ack_s(9)   ,--i--
        c                =>            ex1_ack_c(9)   ,--i--
        sum              =>           ex1_alg_sx(9)   ,--o--
        car              =>           ex1_alg_cx(8)  );--o--
sha32_10: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(10)  ,--i--
        b                =>            ex1_ack_s(10)  ,--i--
        c                =>            ex1_ack_c(10)  ,--i--
        sum              =>           ex1_alg_sx(10)  ,--o--
        car              =>           ex1_alg_cx(9)  );--o--
sha32_11: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(11)  ,--i--
        b                =>            ex1_ack_s(11)  ,--i--
        c                =>            ex1_ack_c(11)  ,--i--
        sum              =>           ex1_alg_sx(11)  ,--o--
        car              =>           ex1_alg_cx(10) );--o--
sha32_12: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(12)  ,--i--
        b                =>            ex1_ack_s(12)  ,--i--
        c                =>            ex1_ack_c(12)  ,--i--
        sum              =>           ex1_alg_sx(12)  ,--o--
        car              =>           ex1_alg_cx(11) );--o--
sha32_13: entity clib.c_prism_csa32  port map( 
        vd               => vdd,
        gd               => gnd,
        a                =>         ex1_b_expo_b(13)  ,--i--
        b                =>            ex1_ack_s(13)  ,--i--
        c                =>            tidn           ,--i--
        sum              =>           ex1_alg_sx(13)  ,--o--
        car              =>           ex1_alg_cx(12) );--o--


       -- now finish the add (for sha==0 means shift 0)

p1_01: ex1_alg_add_p( 1)   <= ex1_alg_sx( 1) xor ex1_alg_cx( 1);
p1_02: ex1_alg_add_p( 2)   <= ex1_alg_sx( 2) xor ex1_alg_cx( 2);
p1_03: ex1_alg_add_p( 3)   <= ex1_alg_sx( 3) xor ex1_alg_cx( 3);
p1_04: ex1_alg_add_p( 4)   <= ex1_alg_sx( 4) xor ex1_alg_cx( 4);
p1_05: ex1_alg_add_p( 5)   <= ex1_alg_sx( 5) xor ex1_alg_cx( 5);
p1_06: ex1_alg_add_p( 6)   <= ex1_alg_sx( 6) xor ex1_alg_cx( 6);
p1_07: ex1_alg_add_p( 7)   <= ex1_alg_sx( 7) xor ex1_alg_cx( 7);
p1_08: ex1_alg_add_p( 8)   <= ex1_alg_sx( 8) xor ex1_alg_cx( 8);
p1_09: ex1_alg_add_p( 9)   <= ex1_alg_sx( 9) xor ex1_alg_cx( 9);
p1_10: ex1_alg_add_p(10)   <= ex1_alg_sx(10) xor ex1_alg_cx(10);
p1_11: ex1_alg_add_p(11)   <= ex1_alg_sx(11) xor ex1_alg_cx(11);
p1_12: ex1_alg_add_p(12)   <= ex1_alg_sx(12) xor ex1_alg_cx(12);


g1_02:  ex1_alg_add_g_b( 2) <= not( ex1_alg_sx( 2) and ex1_alg_cx( 2) );
g1_03:  ex1_alg_add_g_b( 3) <= not( ex1_alg_sx( 3) and ex1_alg_cx( 3) );
g1_04:  ex1_alg_add_g_b( 4) <= not( ex1_alg_sx( 4) and ex1_alg_cx( 4) );
g1_05:  ex1_alg_add_g_b( 5) <= not( ex1_alg_sx( 5) and ex1_alg_cx( 5) );
g1_06:  ex1_alg_add_g_b( 6) <= not( ex1_alg_sx( 6) and ex1_alg_cx( 6) );
g1_07:  ex1_alg_add_g_b( 7) <= not( ex1_alg_sx( 7) and ex1_alg_cx( 7) );
g1_08:  ex1_alg_add_g_b( 8) <= not( ex1_alg_sx( 8) and ex1_alg_cx( 8) );
g1_09:  ex1_alg_add_g_b( 9) <= not( ex1_alg_sx( 9) and ex1_alg_cx( 9) );
g1_10:  ex1_alg_add_g_b(10) <= not( ex1_alg_sx(10) and ex1_alg_cx(10) );
g1_11:  ex1_alg_add_g_b(11) <= not( ex1_alg_sx(11) and ex1_alg_cx(11) );
g1_12:  ex1_alg_add_g_b(12) <= not( ex1_alg_sx(12) and ex1_alg_cx(12) );

t1_02:  ex1_alg_add_t_b( 2) <= not( ex1_alg_sx( 2) or  ex1_alg_cx( 2) );
t1_03:  ex1_alg_add_t_b( 3) <= not( ex1_alg_sx( 3) or  ex1_alg_cx( 3) );
t1_04:  ex1_alg_add_t_b( 4) <= not( ex1_alg_sx( 4) or  ex1_alg_cx( 4) );
t1_05:  ex1_alg_add_t_b( 5) <= not( ex1_alg_sx( 5) or  ex1_alg_cx( 5) );
t1_06:  ex1_alg_add_t_b( 6) <= not( ex1_alg_sx( 6) or  ex1_alg_cx( 6) );
t1_07:  ex1_alg_add_t_b( 7) <= not( ex1_alg_sx( 7) or  ex1_alg_cx( 7) );
t1_08:  ex1_alg_add_t_b( 8) <= not( ex1_alg_sx( 8) or  ex1_alg_cx( 8) );
t1_09:  ex1_alg_add_t_b( 9) <= not( ex1_alg_sx( 9) or  ex1_alg_cx( 9) );
t1_10:  ex1_alg_add_t_b(10) <= not( ex1_alg_sx(10) or  ex1_alg_cx(10) );
t1_11:  ex1_alg_add_t_b(11) <= not( ex1_alg_sx(11) or  ex1_alg_cx(11) );

       -----------------------------------------------------------------------
       -- 12:13 are a decode group  (12,13) are known before adder starts )
       -----------------------------------------------------------------------

g2_12:   ex1_g02_12         <= not ex1_alg_add_g_b(12);  -- main carry chain
g2_12b:  ex1_g02_12_b       <= not ex1_g02_12 ;          -- main carry chain

res_13b: ex1_bsha_13_b      <= not ex1_alg_sx(13);       -- direct from compressor
res_13:  ex1_bsha_13        <= not ex1_bsha_13_b ;       -- to decoder  0/1/2/3
res_12b: ex1_bsha_12_b      <= not ex1_alg_add_p(12);
res_12:  ex1_bsha_12        <= not ex1_bsha_12_b ;       -- to decoder 0/1/2/3

ci11nb:  ex1_lv2_ci11n_en_b <= not( ex1_sel_special_b and ex1_g02_12_b  );
ci11pb:  ex1_lv2_ci11p_en_b <= not( ex1_sel_special_b and ex1_g02_12    );
ci11n:   ex1_lv2_ci11n_en   <= not( ex1_lv2_ci11n_en_b  ); -- to decoder 0/4/8/12
ci11p:   ex1_lv2_ci11p_en   <= not( ex1_lv2_ci11p_en_b  ); -- to decoder 0/4/8/12

       -----------------------------------------------------------------------
       -- 10:11 are a decode group, do not compute adder result (send signal direct to decode)
       -----------------------------------------------------------------------

g2_10: ex1_g02_10         <= not( ex1_alg_add_g_b(10) and (ex1_alg_add_t_b(10) or  ex1_alg_add_g_b(11)) );--main carry chain
t2_10: ex1_t02_10         <= not(                          ex1_alg_add_t_b(10) or  ex1_alg_add_t_b(11)  );--main carry chain
g4_10: ex1_g04_10_b       <= not( ex1_g02_10          or  (ex1_t02_10          and ex1_g02_12         ) );--main carry chain

g11x:  ex1_lv2_g11_x      <= not( ex1_alg_add_g_b(11) ); 
g11b:  ex1_lv2_g11_b      <= not( ex1_lv2_g11_x       ); 
g11:   ex1_lv2_g11        <= not( ex1_lv2_g11_b       ); -- to decoder 0/4/8/12
k11x:  ex1_lv2_k11_b      <= not( ex1_alg_add_t_b(11) );
k11:   ex1_lv2_k11        <= not( ex1_lv2_k11_b       ); -- to decoder 0/4/8/12
p11b:  ex1_lv2_p11_b      <= not( ex1_alg_add_p(11)   ); 
p11:   ex1_lv2_p11        <= not( ex1_lv2_p11_b       ); -- to decoder 0/4/8/12
p10b:  ex1_lv2_p10_b      <= not( ex1_alg_add_p(10)   ); -- to decoder 0/4/8/12
p10:   ex1_lv2_p10        <= not( ex1_lv2_p10_b       ); -- to decoder 0/4/8/12
      
       -----------------------------------------------------------------------
       -- 6:9 are a decode group, not used until next cycle: (get add result then decode)
       ------------------------------------------------------------------------

g4x_10: ex1_g04_10  <= not ex1_g04_10_b ; -- use this buffered of version to finish the local carry chain

g2_06: ex1_g02_6   <= not( ex1_alg_add_g_b(6) and (ex1_alg_add_t_b(6) or  ex1_alg_add_g_b(7)) );
g2_07: ex1_g02_7   <= not( ex1_alg_add_g_b(7) and (ex1_alg_add_t_b(7) or  ex1_alg_add_g_b(8)) );
g2_08: ex1_g02_8   <= not( ex1_alg_add_g_b(8) and (ex1_alg_add_t_b(8) or  ex1_alg_add_g_b(9)) );
g2_09: ex1_g02_9   <= not( ex1_alg_add_g_b(9)                                                 );
t2_06: ex1_t02_6   <= not(                         ex1_alg_add_t_b(6) or  ex1_alg_add_t_b(7)  );
t2_07: ex1_t02_7   <= not(                         ex1_alg_add_t_b(7) or  ex1_alg_add_t_b(8)  );
t2_08: ex1_t02_8   <= not(                         ex1_alg_add_t_b(8) or  ex1_alg_add_t_b(9)  );
t2_09: ex1_t02_9   <= not(                         ex1_alg_add_t_b(9)                         );

g4_06b: ex1_g04_6_b <= not( ex1_g02_6          or  (ex1_t02_6          and ex1_g02_8         ) );
g4_07b: ex1_g04_7_b <= not( ex1_g02_7          or  (ex1_t02_7          and ex1_g02_9         ) );
g4_08b: ex1_g04_8_b <= not( ex1_g02_8                                                          );
g4_09b: ex1_g04_9_b <= not( ex1_g02_9                                                          );
t4_06b: ex1_t04_6_b <= not(                         ex1_t02_6          and ex1_t02_8           );
t4_07b: ex1_t04_7_b <= not(                         ex1_t02_7          and ex1_t02_9           );
t4_08b: ex1_t04_8_b <= not(                                                ex1_t02_8           );
t4_09b: ex1_t04_9_b <= not(                                                ex1_t02_9           );

g8_06:  ex1_g08_6   <= not( ex1_g04_6_b        and (ex1_t04_6_b        or  ex1_g04_10_b      ) );--main carry chain
g4_07:  ex1_g04_7   <= not( ex1_g04_7_b );
g4_08:  ex1_g04_8   <= not( ex1_g04_8_b );
g4_09:  ex1_g04_9   <= not( ex1_g04_9_b );
t4_07:  ex1_t04_7   <= not( ex1_t04_7_b );
t4_08:  ex1_t04_8   <= not( ex1_t04_8_b );
t4_09:  ex1_t04_9   <= not( ex1_t04_9_b );
     
c07:   ex1_alg_add_c_b(7)  <= not( ex1_g04_7 or (ex1_t04_7 and ex1_g04_10) );
c08:   ex1_alg_add_c_b(8)  <= not( ex1_g04_8 or (ex1_t04_8 and ex1_g04_10) );
c09:   ex1_alg_add_c_b(9)  <= not( ex1_g04_9 or (ex1_t04_9 and ex1_g04_10) );
c10:   ex1_alg_add_c_b(10) <= not(                             ex1_g04_10 ); 

res_6: ex1_bsha_6  <= not( ex1_alg_add_p(6) xor ex1_alg_add_c_b(7)  );--to multiple of 16 decoder
res_7: ex1_bsha_7  <= not( ex1_alg_add_p(7) xor ex1_alg_add_c_b(8)  );--to multiple of 16 decoder
res_8: ex1_bsha_8  <= not( ex1_alg_add_p(8) xor ex1_alg_add_c_b(9)  );--to multiple of 16 decoder
res_9: ex1_bsha_9  <= not( ex1_alg_add_p(9) xor ex1_alg_add_c_b(10) );--to multiple of 16 decoder


res_6i:  ex1_bsha_6_i  <= not ex1_bsha_6 ;
res_7i:  ex1_bsha_7_i  <= not ex1_bsha_7 ;
res_8i:  ex1_bsha_8_i  <= not ex1_bsha_8 ;
res_9i:  ex1_bsha_9_i  <= not ex1_bsha_9 ;

res_6o:  ex1_bsha_6_o  <= not ex1_bsha_6_i ;
res_7o:  ex1_bsha_7_o  <= not ex1_bsha_7_i ;
res_8o:  ex1_bsha_8_o  <= not ex1_bsha_8_i ;
res_9o:  ex1_bsha_9_o  <= not ex1_bsha_9_i ;
    
       -------------------------------------------------------------------------
       -- Just need to know if  2/3/4/5 != 0000 for unf, produce that signal directly
       -------------------------------------------------------------------------

g2_02: ex1_g02_2    <= not( ex1_alg_add_g_b(2) and (ex1_alg_add_t_b(2) or  ex1_alg_add_g_b(3)) ); --for carry select
g2_04: ex1_g02_4    <= not( ex1_alg_add_g_b(4) and (ex1_alg_add_t_b(4) or  ex1_alg_add_g_b(5)) ); --for carry select

t2_02: ex1_t02_2    <= not(                        (ex1_alg_add_t_b(2) or  ex1_alg_add_t_b(3)) ); --for carry select
t2_04: ex1_t02_4    <= not( ex1_alg_add_g_b(4) and (ex1_alg_add_t_b(4) or  ex1_alg_add_t_b(5)) ); --for carry select

g4_02: ex1_g04_2_b  <= not( ex1_g02_2          or  (ex1_t02_2          and ex1_g02_4         ) ); --for carry select
t4_02: ex1_t04_2_b  <= not( ex1_g02_2          or  (ex1_t02_2          and ex1_t02_4         ) ); --for carry select


ones23:    ex1_ones_2t3_b <= not( ex1_alg_add_p(2) and ex1_alg_add_p(3) );-- for unf calculation
ones45:    ex1_ones_4t5_b <= not( ex1_alg_add_p(4) and ex1_alg_add_p(5) );-- for unf calculation
ones25:    ex1_ones_2t5   <= not( ex1_ones_2t3_b   or  ex1_ones_4t5_b   );-- for unf calculation
ones25_b:  ex1_ones_2t5_b <= not( ex1_ones_2t5 );

z2b:       ex1_zero_2_b   <= not( ex1_alg_add_p(2) xor ex1_alg_add_t_b(3)  );-- for unf calc
z3b:       ex1_zero_3_b   <= not( ex1_alg_add_p(3) xor ex1_alg_add_t_b(4)  );-- for unf calc
z4b:       ex1_zero_4_b   <= not( ex1_alg_add_p(4) xor ex1_alg_add_t_b(5)  );-- for unf calc
z5:        ex1_zero_5     <= not( ex1_alg_add_p(5)                         );-- for unf calc
z5b:       ex1_zero_5_b   <= not( ex1_zero_5                               );-- for unf calc
z23:       ex1_zero_2t3   <= not( ex1_zero_2_b     or  ex1_zero_3_b        );-- for unf calc
z45:       ex1_zero_4t5   <= not( ex1_zero_4_b     or  ex1_zero_5_b        );-- for unf calc
z25b:      ex1_zero_2t5_b <= not( ex1_zero_2t3     and ex1_zero_4t5        );-- for unf calc

       ----------------------------------------------------------------------------
       -- [1] is really the sign bit .. needed to indicate ovf/underflow
       -------------------------------------------------
       -- finish shift underflow
       -- if sha > 162 all the bits should become sticky and the aligner output should be zero
       -- from 163:255 the shifter does this, so just need to detect the upper bits

pco6:   pos_if_pco6   <=     ( ex1_alg_add_p(1) xor ex1_t04_2_b );
nco6:   pos_if_nco6   <=     ( ex1_alg_add_p(1) xor ex1_g04_2_b );
pco6b:  pos_if_pco6_b <= not pos_if_pco6 ;
nco6b:  pos_if_nco6_b <= not pos_if_nco6 ;

unifnc: unf_if_nco6_b <= not( pos_if_nco6 and  ex1_zero_2t5_b );
unifpc: unf_if_pco6_b <= not( pos_if_pco6 and  ex1_ones_2t5_b );

g8_06b: ex1_g08_6_b     <= not ex1_g08_6 ;
shap:   ex1_bsha_pos    <= not( (pos_if_pco6_b and ex1_g08_6) or (pos_if_nco6_b and ex1_g08_6_b) );-- same as neg
shovb:   ex1_sh_ovf_b   <= not( (pos_if_pco6_b and ex1_g08_6) or (pos_if_nco6_b and ex1_g08_6_b) );-- same as neg
shun:   ex1_sh_unf_x    <= not( (unf_if_pco6_b and ex1_g08_6) or (unf_if_nco6_b and ex1_g08_6_b) ); 
shan:   ex1_bsha_neg    <= not( ex1_bsha_pos );
shan2:  ex1_bsha_neg_o  <= not( ex1_bsha_pos );
shov:   ex1_sh_ovf      <= not( ex1_sh_ovf_b );


       --==-------------------------------------------------------------------------------
       --== decode for first level shifter (0/1/2/3)
       --==-------------------------------------------------------------------------------

d1_0:  ex1_lvl1_shdcd000_b <= not(  ex1_bsha_12_b and  ex1_bsha_13_b );
d1_1:  ex1_lvl1_shdcd001_b <= not(  ex1_bsha_12_b and  ex1_bsha_13   );
d1_2:  ex1_lvl1_shdcd002_b <= not(  ex1_bsha_12   and  ex1_bsha_13_b );
d1_3:  ex1_lvl1_shdcd003_b <= not(  ex1_bsha_12   and  ex1_bsha_13   );

       --==-------------------------------------------------------------------------------
       --== decode for second level shifter (0/4/8/12)
       --==-------------------------------------------------------------------------------
       -- ex1_lvl2_shdcd000 <= not ex1_bsha(10) and not ex1_bsha(11) ;
       -- ex1_lvl2_shdcd004 <= not ex1_bsha(10) and     ex1_bsha(11) ;
       -- ex1_lvl2_shdcd008 <=     ex1_bsha(10) and not ex1_bsha(11) ;
       -- ex1_lvl2_shdcd012 <=     ex1_bsha(10) and     ex1_bsha(11) ;
       ----------------------------------------------------------------------
       --   p10 (11) ci11  DCD           p10   (11) ci11 DCD
       --   !p    k    0   00             !p    k    0   00
       --   !P    p    0   01              p    g    0   00
       --   !p    g    0   10              P    p    1   00
       --
       --    p    k    0   10             !P    p    0   01
       --    P    p    0   11             !p    k    1   01
       --    p    g    0   00              p    g    1   01
       --
       --   !p    k    1   01             !p    g    0   10
       --   !P    p    1   10              p    k    0   10
       --   !p    g    1   11             !P    p    1   10
       --
       --    p    k    1   11              P    p    0   11
       --    P    p    1   00             !p    g    1   11
       --    p    g    1   01              p    k    1   11

d2_0pg0: ex1_lv2_0pg0_b <= not( ex1_lv2_p10_b and  ex1_lv2_g11 and  ex1_lv2_ci11n_en );
d2_0pg1: ex1_lv2_0pg1_b <= not( ex1_lv2_p10_b and  ex1_lv2_g11 and  ex1_lv2_ci11p_en );
d2_0pk0: ex1_lv2_0pk0_b <= not( ex1_lv2_p10_b and  ex1_lv2_k11 and  ex1_lv2_ci11n_en );
d2_0pk1: ex1_lv2_0pk1_b <= not( ex1_lv2_p10_b and  ex1_lv2_k11 and  ex1_lv2_ci11p_en );
d2_0pp0: ex1_lv2_0pp0_b <= not( ex1_lv2_p10_b and  ex1_lv2_p11 and  ex1_lv2_ci11n_en );
d2_0pp1: ex1_lv2_0pp1_b <= not( ex1_lv2_p10_b and  ex1_lv2_p11 and  ex1_lv2_ci11p_en );
d2_1pg0: ex1_lv2_1pg0_b <= not( ex1_lv2_p10   and  ex1_lv2_g11 and  ex1_lv2_ci11n_en );
d2_1pg1: ex1_lv2_1pg1_b <= not( ex1_lv2_p10   and  ex1_lv2_g11 and  ex1_lv2_ci11p_en );
d2_1pk0: ex1_lv2_1pk0_b <= not( ex1_lv2_p10   and  ex1_lv2_k11 and  ex1_lv2_ci11n_en );
d2_1pk1: ex1_lv2_1pk1_b <= not( ex1_lv2_p10   and  ex1_lv2_k11 and  ex1_lv2_ci11p_en );
d2_1pp0: ex1_lv2_1pp0_b <= not( ex1_lv2_p10   and  ex1_lv2_p11 and  ex1_lv2_ci11n_en );
d2_1pp1: ex1_lv2_1pp1_b <= not( ex1_lv2_p10   and  ex1_lv2_p11 and  ex1_lv2_ci11p_en );
      
d2_0:  ex1_lv2_shdcd000 <= not( ex1_lv2_0pk0_b and ex1_lv2_1pg0_b and ex1_lv2_1pp1_b );
d2_1:  ex1_lv2_shdcd004 <= not( ex1_lv2_0pp0_b and ex1_lv2_0pk1_b and ex1_lv2_1pg1_b );
d2_2:  ex1_lv2_shdcd008 <= not( ex1_lv2_0pg0_b and ex1_lv2_1pk0_b and ex1_lv2_0pp1_b );
d2_3:  ex1_lv2_shdcd012 <= not( ex1_lv2_1pp0_b and ex1_lv2_0pg1_b and ex1_lv2_1pk1_b );
       
i2_0:  ex1_lvl2_shdcd000_b <= not ex1_lv2_shdcd000;
i2_1:  ex1_lvl2_shdcd004_b <= not ex1_lv2_shdcd004;
i2_2:  ex1_lvl2_shdcd008_b <= not ex1_lv2_shdcd008;
i2_3:  ex1_lvl2_shdcd012_b <= not ex1_lv2_shdcd012;
       
ii2_0: ex1_lvl2_shdcd000 <= not ex1_lvl2_shdcd000_b;
ii2_1: ex1_lvl2_shdcd004 <= not ex1_lvl2_shdcd004_b;
ii2_2: ex1_lvl2_shdcd008 <= not ex1_lvl2_shdcd008_b;
ii2_3: ex1_lvl2_shdcd012 <= not ex1_lvl2_shdcd012_b;

       

       --==--------------------------------------------
       --== decode to control ex2 shifting
       --==--------------------------------------------

i3_6:  ex1_bsha_6_b <= not ex1_bsha_6 ;
i3_7:  ex1_bsha_7_b <= not ex1_bsha_7 ;
i3_8:  ex1_bsha_8_b <= not ex1_bsha_8 ;
i3_9:  ex1_bsha_9_b <= not ex1_bsha_9 ;

d67_0: ex1_67_dcd00_b <= not( ex1_bsha_6_b and ex1_bsha_7_b                  );
d67_1: ex1_67_dcd01_b <= not( ex1_bsha_6_b and ex1_bsha_7                    );
d67_2: ex1_67_dcd10_b <= not( ex1_bsha_6   and ex1_bsha_7_b                  );
d67_3: ex1_67_dcd11_b <= not( ex1_bsha_6   and ex1_bsha_7   and ex1_bsha_neg );

d89_0: ex1_89_dcd00_b <= not( ex1_bsha_8_b and ex1_bsha_9_b and ex1_sel_special_b );
d89_1: ex1_89_dcd01_b <= not( ex1_bsha_8_b and ex1_bsha_9   and ex1_sel_special_b );
d89_2: ex1_89_dcd10_b <= not( ex1_bsha_8   and ex1_bsha_9_b and ex1_sel_special_b );
d89_3: ex1_89_dcd11_b <= not( ex1_bsha_8   and ex1_bsha_9   and ex1_sel_special_b );

d3_00: ex1_lvl3_shdcd000 <= not(  ex1_67_dcd00_b or ex1_89_dcd00_b );-- 0000  +000
d3_01: ex1_lvl3_shdcd016 <= not(  ex1_67_dcd00_b or ex1_89_dcd01_b );-- 0001  +016
d3_02: ex1_lvl3_shdcd032 <= not(  ex1_67_dcd00_b or ex1_89_dcd10_b );-- 0010  +032
d3_03: ex1_lvl3_shdcd048 <= not(  ex1_67_dcd00_b or ex1_89_dcd11_b );-- 0011  +048
d3_04: ex1_lvl3_shdcd064 <= not(  ex1_67_dcd01_b or ex1_89_dcd00_b );-- 0100  +064
d3_05: ex1_lvl3_shdcd080 <= not(  ex1_67_dcd01_b or ex1_89_dcd01_b );-- 0101  +080
d3_06: ex1_lvl3_shdcd096 <= not(  ex1_67_dcd01_b or ex1_89_dcd10_b );-- 0110  +096
d3_07: ex1_lvl3_shdcd112 <= not(  ex1_67_dcd01_b or ex1_89_dcd11_b );-- 0111  +112
d3_08: ex1_lvl3_shdcd128 <= not(  ex1_67_dcd10_b or ex1_89_dcd00_b );-- 1000  +128
d3_09: ex1_lvl3_shdcd144 <= not(  ex1_67_dcd10_b or ex1_89_dcd01_b );-- 1001  +144
d3_10: ex1_lvl3_shdcd160 <= not(  ex1_67_dcd10_b or ex1_89_dcd10_b );-- 1010  +160
d3_11: ex1_lvl3_shdcd176 <= not(  ex1_67_dcd10_b or ex1_89_dcd11_b );-- 1011
d3_12: ex1_lvl3_shdcd192 <= not(  ex1_67_dcd11_b or ex1_89_dcd00_b );-- 1100  -064
d3_13: ex1_lvl3_shdcd208 <= not(  ex1_67_dcd11_b or ex1_89_dcd01_b );-- 1101  -048
d3_14: ex1_lvl3_shdcd224 <= not(  ex1_67_dcd11_b or ex1_89_dcd10_b );-- 1110  -032
d3_15: ex1_lvl3_shdcd240 <= not(  ex1_67_dcd11_b or ex1_89_dcd11_b );-- 1111  -016


end; -- fuq_alg_add ARCHITECTURE
