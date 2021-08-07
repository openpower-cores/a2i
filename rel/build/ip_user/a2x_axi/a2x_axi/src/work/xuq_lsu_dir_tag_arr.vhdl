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


library ibm, ieee, work, tri, support;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;


entity xuq_lsu_dir_tag_arr is
generic(expand_type     : integer := 2;         
        dc_size         : natural := 14;        
        cl_size         : natural := 6;         
        wayDataSize     : natural := 35;        
        parityBits      : natural := 4;         
	real_data_add	: integer := 42);	
   PORT (

     waddr			:in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size);		
     wdata			:in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     way_wen_a                  :in  std_ulogic;                        
     way_wen_b                  :in  std_ulogic;                        
     way_wen_c                  :in  std_ulogic;                        
     way_wen_d                  :in  std_ulogic;                        
     way_wen_e                  :in  std_ulogic;                        
     way_wen_f                  :in  std_ulogic;                        
     way_wen_g                  :in  std_ulogic;                        
     way_wen_h                  :in  std_ulogic;                        

     raddr_01			:in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size); 	
     raddr_23			:in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size); 	
     raddr_45			:in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size); 	
     raddr_67			:in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size); 	
     inj_parity_err             :in  std_ulogic;

     dir_arr_rd_addr_01         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_addr_23         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_addr_45         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_addr_67         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_data            :in  std_ulogic_vector(0 to 8*wayDataSize-1);

     dir_wr_way                 :out std_ulogic_vector(0 to 7);
     dir_arr_wr_addr            :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_wr_data            :out std_ulogic_vector(64-real_data_add to 64-real_data_add+wayDataSize-1);

     way_tag_a			:out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     way_tag_b			:out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     way_tag_c			:out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     way_tag_d			:out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     way_tag_e			:out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     way_tag_f			:out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     way_tag_g			:out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     way_tag_h			:out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));

     way_arr_par_a              :out std_ulogic_vector(0 to parityBits-1);
     way_arr_par_b              :out std_ulogic_vector(0 to parityBits-1);
     way_arr_par_c              :out std_ulogic_vector(0 to parityBits-1);
     way_arr_par_d              :out std_ulogic_vector(0 to parityBits-1);
     way_arr_par_e              :out std_ulogic_vector(0 to parityBits-1);
     way_arr_par_f              :out std_ulogic_vector(0 to parityBits-1);
     way_arr_par_g              :out std_ulogic_vector(0 to parityBits-1);
     way_arr_par_h              :out std_ulogic_vector(0 to parityBits-1);

     par_gen_a_1b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_a_2b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_b_1b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_b_2b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_c_1b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_c_2b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_d_1b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_d_2b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_e_1b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_e_2b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_f_1b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_f_2b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_g_1b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_g_2b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_h_1b               :out std_ulogic_vector(0 to parityBits-1);
     par_gen_h_2b               :out std_ulogic_vector(0 to parityBits-1)
   );
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_dir_tag_arr;
architecture xuq_lsu_dir_tag_arr of xuq_lsu_dir_tag_arr is


constant uprTagBit                      :natural := 64-real_data_add;
constant lwrTagBit                      :natural := 63-(dc_size-3);
constant tagSize                        :natural := lwrTagBit-uprTagBit+1;
constant parExtCalc                     :natural := 8 - (tagSize mod 8);
constant parBits                        :natural := (tagSize+parExtCalc) / 8;

signal wr_data                  :std_ulogic_vector(uprTagBit to lwrTagBit);
signal wr_wayA                  :std_ulogic;
signal wr_wayB                  :std_ulogic;
signal wr_wayC                  :std_ulogic;
signal wr_wayD                  :std_ulogic;
signal wr_wayE                  :std_ulogic;
signal wr_wayF                  :std_ulogic;
signal wr_wayG                  :std_ulogic;
signal wr_wayH                  :std_ulogic;
signal wr_way                   :std_ulogic_vector(0 to 7);
signal rd_wayA                  :std_ulogic_vector(uprTagBit to lwrTagBit);
signal rd_wayB                  :std_ulogic_vector(uprTagBit to lwrTagBit);
signal rd_wayC                  :std_ulogic_vector(uprTagBit to lwrTagBit);
signal rd_wayD                  :std_ulogic_vector(uprTagBit to lwrTagBit);
signal rd_wayE                  :std_ulogic_vector(uprTagBit to lwrTagBit);
signal rd_wayF                  :std_ulogic_vector(uprTagBit to lwrTagBit);
signal rd_wayG                  :std_ulogic_vector(uprTagBit to lwrTagBit);
signal rd_wayH                  :std_ulogic_vector(uprTagBit to lwrTagBit);
signal arr_rd_data              :std_ulogic_vector(0 to 8*wayDataSize-1);
signal arr_parity               :std_ulogic_vector(0 to parBits-1);
signal extra_byte_par           :std_ulogic_vector(0 to 7);
signal arr_wr_data              :std_ulogic_vector(uprTagBit to lwrTagBit+parBits);
signal rd_parA                  :std_ulogic_vector(0 to parBits-1);
signal rd_parB                  :std_ulogic_vector(0 to parBits-1);
signal rd_parC                  :std_ulogic_vector(0 to parBits-1);
signal rd_parD                  :std_ulogic_vector(0 to parBits-1);
signal rd_parE                  :std_ulogic_vector(0 to parBits-1);
signal rd_parF                  :std_ulogic_vector(0 to parBits-1);
signal rd_parG                  :std_ulogic_vector(0 to parBits-1);
signal rd_parH                  :std_ulogic_vector(0 to parBits-1);
signal extra_tagA_par           :std_ulogic_vector(0 to 7);
signal extra_tagB_par           :std_ulogic_vector(0 to 7);
signal extra_tagC_par           :std_ulogic_vector(0 to 7);
signal extra_tagD_par           :std_ulogic_vector(0 to 7);
signal extra_tagE_par           :std_ulogic_vector(0 to 7);
signal extra_tagF_par           :std_ulogic_vector(0 to 7);
signal extra_tagG_par           :std_ulogic_vector(0 to 7);
signal extra_tagH_par           :std_ulogic_vector(0 to 7);
signal par_genA_1stlvla         :std_ulogic_vector(0 to parBits-1);
signal par_genA_1stlvlb         :std_ulogic_vector(0 to parBits-1);
signal par_genA_1stlvlc         :std_ulogic_vector(0 to parBits-1);
signal par_genA_1stlvld         :std_ulogic_vector(0 to parBits-1);
signal parity_genA_1b           :std_ulogic_vector(0 to parBits-1);
signal parity_genA_2b           :std_ulogic_vector(0 to parBits-1);
signal par_genB_1stlvla         :std_ulogic_vector(0 to parBits-1);
signal par_genB_1stlvlb         :std_ulogic_vector(0 to parBits-1);
signal par_genB_1stlvlc         :std_ulogic_vector(0 to parBits-1);
signal par_genB_1stlvld         :std_ulogic_vector(0 to parBits-1);
signal parity_genB_1b           :std_ulogic_vector(0 to parBits-1);
signal parity_genB_2b           :std_ulogic_vector(0 to parBits-1);
signal par_genC_1stlvla         :std_ulogic_vector(0 to parBits-1);
signal par_genC_1stlvlb         :std_ulogic_vector(0 to parBits-1);
signal par_genC_1stlvlc         :std_ulogic_vector(0 to parBits-1);
signal par_genC_1stlvld         :std_ulogic_vector(0 to parBits-1);
signal parity_genC_1b           :std_ulogic_vector(0 to parBits-1);
signal parity_genC_2b           :std_ulogic_vector(0 to parBits-1);
signal par_genD_1stlvla         :std_ulogic_vector(0 to parBits-1);
signal par_genD_1stlvlb         :std_ulogic_vector(0 to parBits-1);
signal par_genD_1stlvlc         :std_ulogic_vector(0 to parBits-1);
signal par_genD_1stlvld         :std_ulogic_vector(0 to parBits-1);
signal parity_genD_1b           :std_ulogic_vector(0 to parBits-1);
signal parity_genD_2b           :std_ulogic_vector(0 to parBits-1);
signal par_genE_1stlvla         :std_ulogic_vector(0 to parBits-1);
signal par_genE_1stlvlb         :std_ulogic_vector(0 to parBits-1);
signal par_genE_1stlvlc         :std_ulogic_vector(0 to parBits-1);
signal par_genE_1stlvld         :std_ulogic_vector(0 to parBits-1);
signal parity_genE_1b           :std_ulogic_vector(0 to parBits-1);
signal parity_genE_2b           :std_ulogic_vector(0 to parBits-1);
signal par_genF_1stlvla         :std_ulogic_vector(0 to parBits-1);
signal par_genF_1stlvlb         :std_ulogic_vector(0 to parBits-1);
signal par_genF_1stlvlc         :std_ulogic_vector(0 to parBits-1);
signal par_genF_1stlvld         :std_ulogic_vector(0 to parBits-1);
signal parity_genF_1b           :std_ulogic_vector(0 to parBits-1);
signal parity_genF_2b           :std_ulogic_vector(0 to parBits-1);
signal par_genG_1stlvla         :std_ulogic_vector(0 to parBits-1);
signal par_genG_1stlvlb         :std_ulogic_vector(0 to parBits-1);
signal par_genG_1stlvlc         :std_ulogic_vector(0 to parBits-1);
signal par_genG_1stlvld         :std_ulogic_vector(0 to parBits-1);
signal parity_genG_1b           :std_ulogic_vector(0 to parBits-1);
signal parity_genG_2b           :std_ulogic_vector(0 to parBits-1);
signal par_genH_1stlvla         :std_ulogic_vector(0 to parBits-1);
signal par_genH_1stlvlb         :std_ulogic_vector(0 to parBits-1);
signal par_genH_1stlvlc         :std_ulogic_vector(0 to parBits-1);
signal par_genH_1stlvld         :std_ulogic_vector(0 to parBits-1);
signal parity_genH_1b           :std_ulogic_vector(0 to parBits-1);
signal parity_genH_2b           :std_ulogic_vector(0 to parBits-1);


begin


wr_wayA <= way_wen_a;
wr_wayB <= way_wen_b;
wr_wayC <= way_wen_c;
wr_wayD <= way_wen_d;
wr_wayE <= way_wen_e;
wr_wayF <= way_wen_f;
wr_wayG <= way_wen_g;
wr_wayH <= way_wen_h;
arr_rd_data <= dir_arr_rd_data;
wr_data <= wdata;


extra_byte : for t in 0 to 7 generate begin
  R0:if(t < (tagSize mod 8))  generate begin extra_byte_par(t) <= wr_data(uprTagBit+(8*(tagSize/8))+t);
  end generate;
  R1:if(t >= (tagSize mod 8)) generate begin extra_byte_par(t) <= '0';
  end generate;
end generate extra_byte;

par_gen : for i in 0 to (tagSize/8)-1 generate begin
  arr_parity(i) <= xor_reduce(wr_data(8*i+uprTagBit to 8*i+uprTagBit+7));
end generate par_gen;

par_gen_x : if (tagSize mod 8) /= 0 generate begin
  arr_parity(tagSize/8) <= xor_reduce(extra_byte_par);
end generate par_gen_x;

arr_wr_data <= wr_data & arr_parity;

wr_way <= wr_wayA & wr_wayB & wr_wayC & wr_wayD &
          wr_wayE & wr_wayF & wr_wayG & wr_wayH;


rd_wayA(uprTagBit)                <= arr_rd_data(0) xor inj_parity_err;
rd_wayA(uprTagBit+1 to lwrTagBit) <= arr_rd_data(1 to (0*wayDataSize)+tagSize-1);

rd_wayB <= arr_rd_data((1*wayDataSize) to (1*wayDataSize)+tagSize-1);
rd_wayC <= arr_rd_data((2*wayDataSize) to (2*wayDataSize)+tagSize-1);
rd_wayD <= arr_rd_data((3*wayDataSize) to (3*wayDataSize)+tagSize-1);
rd_wayE <= arr_rd_data((4*wayDataSize) to (4*wayDataSize)+tagSize-1);
rd_wayF <= arr_rd_data((5*wayDataSize) to (5*wayDataSize)+tagSize-1);
rd_wayG <= arr_rd_data((6*wayDataSize) to (6*wayDataSize)+tagSize-1);
rd_wayH <= arr_rd_data((7*wayDataSize) to (7*wayDataSize)+tagSize-1);

rd_parA <= arr_rd_data((0*wayDataSize)+tagSize to (0*wayDataSize)+tagSize+parBits-1);
rd_parB <= arr_rd_data((1*wayDataSize)+tagSize to (1*wayDataSize)+tagSize+parBits-1);
rd_parC <= arr_rd_data((2*wayDataSize)+tagSize to (2*wayDataSize)+tagSize+parBits-1);
rd_parD <= arr_rd_data((3*wayDataSize)+tagSize to (3*wayDataSize)+tagSize+parBits-1);
rd_parE <= arr_rd_data((4*wayDataSize)+tagSize to (4*wayDataSize)+tagSize+parBits-1);
rd_parF <= arr_rd_data((5*wayDataSize)+tagSize to (5*wayDataSize)+tagSize+parBits-1);
rd_parG <= arr_rd_data((6*wayDataSize)+tagSize to (6*wayDataSize)+tagSize+parBits-1);
rd_parH <= arr_rd_data((7*wayDataSize)+tagSize to (7*wayDataSize)+tagSize+parBits-1);


rdExtraByte : for t in 0 to 7 generate begin
  R0: if(t < (tagSize mod 8))  generate
  begin
    extra_tagA_par(t) <= rd_wayA(uprTagBit+(8*(tagSize/8))+t);
    extra_tagB_par(t) <= rd_wayB(uprTagBit+(8*(tagSize/8))+t);
    extra_tagC_par(t) <= rd_wayC(uprTagBit+(8*(tagSize/8))+t);
    extra_tagD_par(t) <= rd_wayD(uprTagBit+(8*(tagSize/8))+t);
    extra_tagE_par(t) <= rd_wayE(uprTagBit+(8*(tagSize/8))+t);
    extra_tagF_par(t) <= rd_wayF(uprTagBit+(8*(tagSize/8))+t);
    extra_tagG_par(t) <= rd_wayG(uprTagBit+(8*(tagSize/8))+t);
    extra_tagH_par(t) <= rd_wayH(uprTagBit+(8*(tagSize/8))+t);
  end generate;
  R1: if(t >= (tagSize mod 8)) generate
  begin
    extra_tagA_par(t) <= '0';
    extra_tagB_par(t) <= '0';
    extra_tagC_par(t) <= '0';
    extra_tagD_par(t) <= '0';
    extra_tagE_par(t) <= '0';
    extra_tagF_par(t) <= '0';
    extra_tagG_par(t) <= '0';
    extra_tagH_par(t) <= '0';
  end generate;
end generate rdExtraByte;

rdParGen : for i in 0 to (tagSize/8)-1 generate
begin

  parA1lvla : par_genA_1stlvla(i) <= not (rd_wayA(8*i+uprTagBit+0) xor rd_wayA(8*i+uprTagBit+1));
  parA1lvlb : par_genA_1stlvlb(i) <= not (rd_wayA(8*i+uprTagBit+2) xor rd_wayA(8*i+uprTagBit+3));
  parA1lvlc : par_genA_1stlvlc(i) <= not (rd_wayA(8*i+uprTagBit+4) xor rd_wayA(8*i+uprTagBit+5));
  parA1lvld : par_genA_1stlvld(i) <= not (rd_wayA(8*i+uprTagBit+6) xor rd_wayA(8*i+uprTagBit+7));
  parGenA1b : parity_genA_1b(i)   <= not (par_genA_1stlvla(i) xor par_genA_1stlvlb(i));
  parGenA2b : parity_genA_2b(i)   <= not (par_genA_1stlvlc(i) xor par_genA_1stlvld(i));

  parB1lvla : par_genB_1stlvla(i) <= not (rd_wayB(8*i+uprTagBit+0) xor rd_wayB(8*i+uprTagBit+1));
  parB1lvlb : par_genB_1stlvlb(i) <= not (rd_wayB(8*i+uprTagBit+2) xor rd_wayB(8*i+uprTagBit+3));
  parB1lvlc : par_genB_1stlvlc(i) <= not (rd_wayB(8*i+uprTagBit+4) xor rd_wayB(8*i+uprTagBit+5));
  parB1lvld : par_genB_1stlvld(i) <= not (rd_wayB(8*i+uprTagBit+6) xor rd_wayB(8*i+uprTagBit+7));
  parGenB1b : parity_genB_1b(i)   <= not (par_genB_1stlvla(i) xor par_genB_1stlvlb(i));
  parGenB2b : parity_genB_2b(i)   <= not (par_genB_1stlvlc(i) xor par_genB_1stlvld(i));

  parC1lvla : par_genC_1stlvla(i) <= not (rd_wayC(8*i+uprTagBit+0) xor rd_wayC(8*i+uprTagBit+1));
  parC1lvlb : par_genC_1stlvlb(i) <= not (rd_wayC(8*i+uprTagBit+2) xor rd_wayC(8*i+uprTagBit+3));
  parC1lvlc : par_genC_1stlvlc(i) <= not (rd_wayC(8*i+uprTagBit+4) xor rd_wayC(8*i+uprTagBit+5));
  parC1lvld : par_genC_1stlvld(i) <= not (rd_wayC(8*i+uprTagBit+6) xor rd_wayC(8*i+uprTagBit+7));
  parGenC1b : parity_genC_1b(i)   <= not (par_genC_1stlvla(i) xor par_genC_1stlvlb(i));
  parGenC2b : parity_genC_2b(i)   <= not (par_genC_1stlvlc(i) xor par_genC_1stlvld(i));

  parD1lvla : par_genD_1stlvla(i) <= not (rd_wayD(8*i+uprTagBit+0) xor rd_wayD(8*i+uprTagBit+1));
  parD1lvlb : par_genD_1stlvlb(i) <= not (rd_wayD(8*i+uprTagBit+2) xor rd_wayD(8*i+uprTagBit+3));
  parD1lvlc : par_genD_1stlvlc(i) <= not (rd_wayD(8*i+uprTagBit+4) xor rd_wayD(8*i+uprTagBit+5));
  parD1lvld : par_genD_1stlvld(i) <= not (rd_wayD(8*i+uprTagBit+6) xor rd_wayD(8*i+uprTagBit+7));
  parGenD1b : parity_genD_1b(i)   <= not (par_genD_1stlvla(i) xor par_genD_1stlvlb(i));
  parGenD2b : parity_genD_2b(i)   <= not (par_genD_1stlvlc(i) xor par_genD_1stlvld(i));

  parE1lvla : par_genE_1stlvla(i) <= not (rd_wayE(8*i+uprTagBit+0) xor rd_wayE(8*i+uprTagBit+1));
  parE1lvlb : par_genE_1stlvlb(i) <= not (rd_wayE(8*i+uprTagBit+2) xor rd_wayE(8*i+uprTagBit+3));
  parE1lvlc : par_genE_1stlvlc(i) <= not (rd_wayE(8*i+uprTagBit+4) xor rd_wayE(8*i+uprTagBit+5));
  parE1lvld : par_genE_1stlvld(i) <= not (rd_wayE(8*i+uprTagBit+6) xor rd_wayE(8*i+uprTagBit+7));
  parGenE1b : parity_genE_1b(i)   <= not (par_genE_1stlvla(i) xor par_genE_1stlvlb(i));
  parGenE2b : parity_genE_2b(i)   <= not (par_genE_1stlvlc(i) xor par_genE_1stlvld(i));

  parF1lvla : par_genF_1stlvla(i) <= not (rd_wayF(8*i+uprTagBit+0) xor rd_wayF(8*i+uprTagBit+1));
  parF1lvlb : par_genF_1stlvlb(i) <= not (rd_wayF(8*i+uprTagBit+2) xor rd_wayF(8*i+uprTagBit+3));
  parF1lvlc : par_genF_1stlvlc(i) <= not (rd_wayF(8*i+uprTagBit+4) xor rd_wayF(8*i+uprTagBit+5));
  parF1lvld : par_genF_1stlvld(i) <= not (rd_wayF(8*i+uprTagBit+6) xor rd_wayF(8*i+uprTagBit+7));
  parGenF1b : parity_genF_1b(i)   <= not (par_genF_1stlvla(i) xor par_genF_1stlvlb(i));
  parGenF2b : parity_genF_2b(i)   <= not (par_genF_1stlvlc(i) xor par_genF_1stlvld(i));

  parG1lvla : par_genG_1stlvla(i) <= not (rd_wayG(8*i+uprTagBit+0) xor rd_wayG(8*i+uprTagBit+1));
  parG1lvlb : par_genG_1stlvlb(i) <= not (rd_wayG(8*i+uprTagBit+2) xor rd_wayG(8*i+uprTagBit+3));
  parG1lvlc : par_genG_1stlvlc(i) <= not (rd_wayG(8*i+uprTagBit+4) xor rd_wayG(8*i+uprTagBit+5));
  parG1lvld : par_genG_1stlvld(i) <= not (rd_wayG(8*i+uprTagBit+6) xor rd_wayG(8*i+uprTagBit+7));
  parGenG1b : parity_genG_1b(i)   <= not (par_genG_1stlvla(i) xor par_genG_1stlvlb(i));
  parGenG2b : parity_genG_2b(i)   <= not (par_genG_1stlvlc(i) xor par_genG_1stlvld(i));

  parH1lvla : par_genH_1stlvla(i) <= not (rd_wayH(8*i+uprTagBit+0) xor rd_wayH(8*i+uprTagBit+1));
  parH1lvlb : par_genH_1stlvlb(i) <= not (rd_wayH(8*i+uprTagBit+2) xor rd_wayH(8*i+uprTagBit+3));
  parH1lvlc : par_genH_1stlvlc(i) <= not (rd_wayH(8*i+uprTagBit+4) xor rd_wayH(8*i+uprTagBit+5));
  parH1lvld : par_genH_1stlvld(i) <= not (rd_wayH(8*i+uprTagBit+6) xor rd_wayH(8*i+uprTagBit+7));
  parGenH1b : parity_genH_1b(i)   <= not (par_genH_1stlvla(i) xor par_genH_1stlvlb(i));
  parGenH2b : parity_genH_2b(i)   <= not (par_genH_1stlvlc(i) xor par_genH_1stlvld(i));
end generate rdParGen;

rdParGenx : if (tagSize mod 8) /= 0 generate
begin
  EparA1lvla : par_genA_1stlvla(parBits-1) <= not (extra_tagA_par(0) xor extra_tagA_par(1));
  EparA1lvlb : par_genA_1stlvlb(parBits-1) <= not (extra_tagA_par(2) xor extra_tagA_par(3));
  EparA1lvlc : par_genA_1stlvlc(parBits-1) <= not (extra_tagA_par(4) xor extra_tagA_par(5));
  EparA1lvld : par_genA_1stlvld(parBits-1) <= not (extra_tagA_par(6) xor extra_tagA_par(7));
  EparGenA1b : parity_genA_1b(parBits-1)   <= not (par_genA_1stlvla(parBits-1) xor par_genA_1stlvlb(parBits-1));
  EparGenA2b : parity_genA_2b(parBits-1)   <= not (par_genA_1stlvlc(parBits-1) xor par_genA_1stlvld(parBits-1));

  EparB1lvla : par_genB_1stlvla(parBits-1) <= not (extra_tagB_par(0) xor extra_tagB_par(1));
  EparB1lvlb : par_genB_1stlvlb(parBits-1) <= not (extra_tagB_par(2) xor extra_tagB_par(3));
  EparB1lvlc : par_genB_1stlvlc(parBits-1) <= not (extra_tagB_par(4) xor extra_tagB_par(5));
  EparB1lvld : par_genB_1stlvld(parBits-1) <= not (extra_tagB_par(6) xor extra_tagB_par(7));
  EparGenB1b : parity_genB_1b(parBits-1)   <= not (par_genB_1stlvla(parBits-1) xor par_genB_1stlvlb(parBits-1));
  EparGenB2b : parity_genB_2b(parBits-1)   <= not (par_genB_1stlvlc(parBits-1) xor par_genB_1stlvld(parBits-1));

  EparC1lvla : par_genC_1stlvla(parBits-1) <= not (extra_tagC_par(0) xor extra_tagC_par(1));
  EparC1lvlb : par_genC_1stlvlb(parBits-1) <= not (extra_tagC_par(2) xor extra_tagC_par(3));
  EparC1lvlc : par_genC_1stlvlc(parBits-1) <= not (extra_tagC_par(4) xor extra_tagC_par(5));
  EparC1lvld : par_genC_1stlvld(parBits-1) <= not (extra_tagC_par(6) xor extra_tagC_par(7));
  EparGenC1b : parity_genC_1b(parBits-1)   <= not (par_genC_1stlvla(parBits-1) xor par_genC_1stlvlb(parBits-1));
  EparGenC2b : parity_genC_2b(parBits-1)   <= not (par_genC_1stlvlc(parBits-1) xor par_genC_1stlvld(parBits-1));

  EparD1lvla : par_genD_1stlvla(parBits-1) <= not (extra_tagD_par(0) xor extra_tagD_par(1));
  EparD1lvlb : par_genD_1stlvlb(parBits-1) <= not (extra_tagD_par(2) xor extra_tagD_par(3));
  EparD1lvlc : par_genD_1stlvlc(parBits-1) <= not (extra_tagD_par(4) xor extra_tagD_par(5));
  EparD1lvld : par_genD_1stlvld(parBits-1) <= not (extra_tagD_par(6) xor extra_tagD_par(7));
  EparGenD1b : parity_genD_1b(parBits-1)   <= not (par_genD_1stlvla(parBits-1) xor par_genD_1stlvlb(parBits-1));
  EparGenD2b : parity_genD_2b(parBits-1)   <= not (par_genD_1stlvlc(parBits-1) xor par_genD_1stlvld(parBits-1));

  EparE1lvla : par_genE_1stlvla(parBits-1) <= not (extra_tagE_par(0) xor extra_tagE_par(1));
  EparE1lvlb : par_genE_1stlvlb(parBits-1) <= not (extra_tagE_par(2) xor extra_tagE_par(3));
  EparE1lvlc : par_genE_1stlvlc(parBits-1) <= not (extra_tagE_par(4) xor extra_tagE_par(5));
  EparE1lvld : par_genE_1stlvld(parBits-1) <= not (extra_tagE_par(6) xor extra_tagE_par(7));
  EparGenE1b : parity_genE_1b(parBits-1)   <= not (par_genE_1stlvla(parBits-1) xor par_genE_1stlvlb(parBits-1));
  EparGenE2b : parity_genE_2b(parBits-1)   <= not (par_genE_1stlvlc(parBits-1) xor par_genE_1stlvld(parBits-1));

  EparF1lvla : par_genF_1stlvla(parBits-1) <= not (extra_tagF_par(0) xor extra_tagF_par(1));
  EparF1lvlb : par_genF_1stlvlb(parBits-1) <= not (extra_tagF_par(2) xor extra_tagF_par(3));
  EparF1lvlc : par_genF_1stlvlc(parBits-1) <= not (extra_tagF_par(4) xor extra_tagF_par(5));
  EparF1lvld : par_genF_1stlvld(parBits-1) <= not (extra_tagF_par(6) xor extra_tagF_par(7));
  EparGenF1b : parity_genF_1b(parBits-1)   <= not (par_genF_1stlvla(parBits-1) xor par_genF_1stlvlb(parBits-1));
  EparGenF2b : parity_genF_2b(parBits-1)   <= not (par_genF_1stlvlc(parBits-1) xor par_genF_1stlvld(parBits-1));

  EparG1lvla : par_genG_1stlvla(parBits-1) <= not (extra_tagG_par(0) xor extra_tagG_par(1));
  EparG1lvlb : par_genG_1stlvlb(parBits-1) <= not (extra_tagG_par(2) xor extra_tagG_par(3));
  EparG1lvlc : par_genG_1stlvlc(parBits-1) <= not (extra_tagG_par(4) xor extra_tagG_par(5));
  EparG1lvld : par_genG_1stlvld(parBits-1) <= not (extra_tagG_par(6) xor extra_tagG_par(7));
  EparGenG1b : parity_genG_1b(parBits-1)   <= not (par_genG_1stlvla(parBits-1) xor par_genG_1stlvlb(parBits-1));
  EparGenG2b : parity_genG_2b(parBits-1)   <= not (par_genG_1stlvlc(parBits-1) xor par_genG_1stlvld(parBits-1));

  EparH1lvla : par_genH_1stlvla(parBits-1) <= not (extra_tagH_par(0) xor extra_tagH_par(1));
  EparH1lvlb : par_genH_1stlvlb(parBits-1) <= not (extra_tagH_par(2) xor extra_tagH_par(3));
  EparH1lvlc : par_genH_1stlvlc(parBits-1) <= not (extra_tagH_par(4) xor extra_tagH_par(5));
  EparH1lvld : par_genH_1stlvld(parBits-1) <= not (extra_tagH_par(6) xor extra_tagH_par(7));
  EparGenH1b : parity_genH_1b(parBits-1)   <= not (par_genH_1stlvla(parBits-1) xor par_genH_1stlvlb(parBits-1));
  EparGenH2b : parity_genH_2b(parBits-1)   <= not (par_genH_1stlvlc(parBits-1) xor par_genH_1stlvld(parBits-1));
end generate rdParGenx;



par_gen_a_1b <= parity_genA_1b;
par_gen_b_1b <= parity_genB_1b;
par_gen_c_1b <= parity_genC_1b;
par_gen_d_1b <= parity_genD_1b;
par_gen_e_1b <= parity_genE_1b;
par_gen_f_1b <= parity_genF_1b;
par_gen_g_1b <= parity_genG_1b;
par_gen_h_1b <= parity_genH_1b;
par_gen_a_2b <= parity_genA_2b;
par_gen_b_2b <= parity_genB_2b;
par_gen_c_2b <= parity_genC_2b;
par_gen_d_2b <= parity_genD_2b;
par_gen_e_2b <= parity_genE_2b;
par_gen_f_2b <= parity_genF_2b;
par_gen_g_2b <= parity_genG_2b;
par_gen_h_2b <= parity_genH_2b;


dir_wr_way         <= wr_way;
dir_arr_rd_addr_01 <= raddr_01;
dir_arr_rd_addr_23 <= raddr_23;
dir_arr_rd_addr_45 <= raddr_45;
dir_arr_rd_addr_67 <= raddr_67;
dir_arr_wr_addr    <= waddr;
dir_arr_wr_data    <= arr_wr_data;

way_tag_a <= rd_wayA;
way_tag_b <= rd_wayB;
way_tag_c <= rd_wayC;
way_tag_d <= rd_wayD;
way_tag_e <= rd_wayE;
way_tag_f <= rd_wayF;
way_tag_g <= rd_wayG;                 
way_tag_h <= rd_wayH;

way_arr_par_a <= rd_parA;
way_arr_par_b <= rd_parB;
way_arr_par_c <= rd_parC;
way_arr_par_d <= rd_parD;
way_arr_par_e <= rd_parE;
way_arr_par_f <= rd_parF;
way_arr_par_g <= rd_parG;
way_arr_par_h <= rd_parH;

end xuq_lsu_dir_tag_arr;

